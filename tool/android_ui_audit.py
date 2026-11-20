#!/usr/bin/env python3
"""A6 모바일 사용성 판정 — Android 화면의 레이아웃 결함을 접근성 노드 좌표로 센다.

`docs/audits/2026-11-19-a6-mobile-usability-audit.md` 의 「판정 방법」을 재현 가능하게
만든 것이다. 그 감사는 스크린샷을 눈으로 보는 대신 `adb shell uiautomator dump` 의
좌표로 자동 판정했는데, **그 스크립트가 커밋되지 않아** 같은 수치를 다시 낼 수 없었다
(2026-11-20 정정). 측정 도구는 커밋하거나, 커밋하지 않았다고 적는다.

## 무엇을 판정하고 무엇을 판정하지 않는가

판정(`VERDICT_KEYS`)은 **노드 좌표로 참·거짓이 갈리는 것**만이다.

- `offscreen` — 클릭 가능 요소가 화면과 교집합이 없다(= 닿을 수 없다).
- `clickable_overlap` — 형제 관계의 클릭 가능 요소가 겹친다(= 어느 쪽이 먹는지 모른다).
  ⚠️ 조상-자손은 **정상적으로** 겹치므로 제외한다(그 제외가 self-test 의 대조군이다).
- `statusbar_intrusion` — 클릭 가능 요소가 상태바 아래로 들어간다.

⚠️⚠️ **터치 타깃은 판정하지 않는다**(A6-1 정정). `uiautomator` 가 보는 노드는
`FocusRing` 의 패딩을 포함하는데 그 띠는 `InkWell` 밖이라 **눌리지 않고**, 반대로
`Semantics` 가 `TouchTarget` **바깥**이면 노드가 48dp 로 커진다. 같은 수정인데 노드
수치가 위젯마다 갈렸다 — 2026-11-19 실측에서 출처 칩은 48.0dp 로, 테마 토글·CTA 는
44.2dp 로 보였지만 **실제로 눌러 보면 셋 다 48dp 안에서 먹었다.** 그래서 이 값은
`INFO_KEYS` 로 기록만 하고, 판정은 렌더 트리를 직접 재는 `touch_target_test.dart` 가 한다.

⚠️ **내비 바 침범도 판정하지 않는다**(A6-2 정정). 침범량이 조건과 무관하게 늘 inset
전체인 것은 **스크롤 콘텐츠가 뷰포트 끝까지 그려지는 정상 동작**이고, 제스처 바 안쪽을
눌러도 탭이 먹는다(시스템이 가로채는 것은 스와이프뿐이다). 진짜 결함인 「스크롤 끝
여백」은 `scroll_bottom_inset_test.dart` 가 지킨다.

## 쓰는 법

    py tool/android_ui_audit.py --self-test
    py tool/android_ui_audit.py dump --label home --expect "AWS 자격증"
    py tool/android_ui_audit.py report build/android_ui_audit/*.json

⚠️ `adb` 는 **Python 에서 직접** 부른다 — Git Bash(MSYS)를 거치면 `/sdcard/ui.xml` 이
`C:/Program Files/Git/sdcard/ui.xml` 로 변형돼 0바이트 파일이 나온다(실측).

⚠️ `--expect` 로 **그 화면에 도달했는지 먼저 단정**한다. 도달하지 않은 화면에서 나온
「위반 0건」은 결과가 아니라 측정 실패다(알려진 양성 대조군 없는 0건은 결과가 아니다).

⚠️ `uiautomator` 는 **시스템 내비게이션 바도 노드로 보고한다**(`[0,2274][1080,2400]`).
앱 패키지(`--package`)가 아닌 노드는 세지 않는다.
"""

from __future__ import annotations

import argparse
import glob
import json
import os
import pathlib
import re
import subprocess
import sys
import xml.etree.ElementTree as ET

# 이 환경의 콘솔은 cp949 라 한국어·이모지 출력에서 죽는다(실측). 쓰기 전에 바꿔 둔다.
for _s in (sys.stdout, sys.stderr):
    try:
        _s.reconfigure(encoding="utf-8", errors="replace")
    except AttributeError:  # pragma: no cover - Python 3.6 이하
        pass

# --- 판정 대상과 참고 대상의 가름 (test/android_ui_audit_tool_test.dart 가 단정한다) ---
VERDICT_KEYS = ("offscreen", "clickable_overlap", "statusbar_intrusion")
INFO_KEYS = ("tap_target_under_48dp", "navbar_intrusion")

# 임계값은 dp 다 — px 환산은 기기 density 로 한다(1dp = density/160 px).
TAP_TARGET_MIN_DP = 48  # Material 최소 터치 타깃
STATUS_BAR_DP = 24
NAV_BAR_3BUTTON_DP = 48  # 3버튼 내비. 제스처 바는 24dp 지만 실제로 가리는 것은 3버튼이다.
HEADER_SHELL_DP = 56  # AppHeaderShell.height (lib/widgets/app_header.dart) 와 같아야 한다

DEFAULT_PACKAGE = "kr.ai.leva.awsdocs"
DEFAULT_OUT = "build/android_ui_audit"
_DEVICE_XML = "/sdcard/android_ui_audit.xml"


# --------------------------------------------------------------------------- adb


def _adb(args: list[str], *, serial: str | None = None, text: bool = True):
    """adb 를 셸 없이 직접 부른다(MSYS 경로 변형 회피)."""
    cmd = ["adb"]
    if serial:
        cmd += ["-s", serial]
    cmd += args
    return subprocess.run(cmd, capture_output=True, text=text, check=False)


def _adb_out(args: list[str], *, serial: str | None = None) -> str:
    r = _adb(args, serial=serial)
    if r.returncode != 0:
        raise RuntimeError(f"adb {' '.join(args)} 실패: {r.stderr.strip()}")
    return r.stdout


# ----------------------------------------------------------------------- metrics


def screen_metrics(serial: str | None = None, rotation: int = 0) -> dict:
    """화면 크기·밀도. Override 가 있으면 그것이 실제 값이다(`wm size`·`wm density`).

    ⚠️ **`wm size` 는 물리 크기만 준다** — 가로로 돌려도 `1080x2400` 이다. 그대로
    쓰면 가로에서 오른쪽 요소가 전부 「화면 밖」으로 잡힌다(2026-11-20 실측 거짓
    양성). `rotation`(uiautomator XML 루트의 속성, 1·3 이 가로)으로 교환한다.
    """
    size_out = _adb_out(["shell", "wm", "size"], serial=serial)
    den_out = _adb_out(["shell", "wm", "density"], serial=serial)

    def _pick(out: str, pattern: str) -> str | None:
        found = re.findall(pattern, out)
        return found[-1] if found else None

    size = _pick(size_out, r"size:\s*(\d+x\d+)")
    density = _pick(den_out, r"density:\s*(\d+)")
    if not size or not density:
        raise RuntimeError(f"화면 메트릭을 읽지 못했다:\n{size_out}\n{den_out}")
    w, h = (int(v) for v in size.split("x"))
    if rotation in (1, 3):
        w, h = h, w
    dpi = int(density)
    scale = dpi / 160.0
    return {
        "rotation": rotation,
        "width_px": w,
        "height_px": h,
        "dpi": dpi,
        "scale": scale,
        "width_dp": round(w / scale, 1),
        "height_dp": round(h / scale, 1),
        "status_bar_px": round(STATUS_BAR_DP * scale),
        "nav_bar_px": round(NAV_BAR_3BUTTON_DP * scale),
        "tap_target_min_px": round(TAP_TARGET_MIN_DP * scale),
        "header_px": round((STATUS_BAR_DP + HEADER_SHELL_DP) * scale),
    }


# -------------------------------------------------------------------- node model

_BOUNDS = re.compile(r"\[(-?\d+),(-?\d+)\]\[(-?\d+),(-?\d+)\]")


class Node:
    __slots__ = ("label", "cls", "package", "clickable", "box", "path", "in_scroll")

    def __init__(self, label, cls, package, clickable, box, path, in_scroll=False):
        self.label = label
        self.cls = cls
        self.package = package
        self.clickable = clickable
        self.box = box  # (x1, y1, x2, y2)
        self.path = path  # 트리 경로 — 조상-자손 판정에 쓴다
        # `scrollable` 컨테이너의 자손인가 — 스크롤 콘텐츠는 상태바·헤더 뒤를
        # 지나는 것이 정상이므로 침범 판정에서 뺀다(DESIGN.md System bars).
        self.in_scroll = in_scroll

    @property
    def w(self) -> int:
        return self.box[2] - self.box[0]

    @property
    def h(self) -> int:
        return self.box[3] - self.box[1]

    def as_dict(self) -> dict:
        return {
            "label": self.label,
            "class": self.cls,
            "clickable": self.clickable,
            "bounds": list(self.box),
            "w": self.w,
            "h": self.h,
        }

    def __repr__(self) -> str:  # pragma: no cover - 진단용
        return f"Node({self.label!r}, {self.box})"


def parse_rotation(xml_text: str) -> int:
    """uiautomator XML 루트의 `rotation`(0·2 세로, 1·3 가로)."""
    m = re.search(r'<hierarchy[^>]*\brotation="(\d)"', xml_text)
    return int(m.group(1)) if m else 0


def parse_nodes(xml_text: str) -> list[Node]:
    """uiautomator XML → 노드 목록. 트리 경로를 함께 들고 온다."""
    root = ET.fromstring(xml_text)
    out: list[Node] = []

    def walk(el, path: str, in_scroll: bool = False):
        for i, child in enumerate(el):
            here = f"{path}/{i}"
            scrolls = in_scroll or child.attrib.get("scrollable") == "true"
            b = _BOUNDS.match(child.attrib.get("bounds", ""))
            if b:
                label = (
                    child.attrib.get("content-desc")
                    or child.attrib.get("text")
                    or child.attrib.get("resource-id")
                    or ""
                )
                out.append(
                    Node(
                        label=label.strip(),
                        cls=child.attrib.get("class", ""),
                        package=child.attrib.get("package", ""),
                        clickable=child.attrib.get("clickable") == "true",
                        box=tuple(int(g) for g in b.groups()),
                        path=here,
                        in_scroll=in_scroll,  # 컨테이너 자신은 고정으로 본다
                    )
                )
            walk(child, here, scrolls)

    walk(root, "")
    return out


def _intersects(a, b) -> bool:
    return a[0] < b[2] and b[0] < a[2] and a[1] < b[3] and b[1] < a[3]


def _is_ancestor(a: Node, b: Node) -> bool:
    return b.path.startswith(a.path + "/") or a.path.startswith(b.path + "/")


def _in_header(n: Node, header_px: int) -> bool:
    """고정 헤더(상태바 + AppHeaderShell) 안에 완전히 들어가는 노드.

    ⚠️ 헤더는 글래스라 **스크롤 콘텐츠가 그 뒤를 지나간다**(설계 — `cert_exam_page.dart`
    의 「글래스 헤더가 덮는」 주석, `headerScrollInset` 은 상태바+헤더+24dp 에서 시작할
    뿐 그 뒤를 막지 않는다). 2026-11-20 실측: 겹친 영역(뒤로 버튼 중심)을 탭하면
    **헤더가 받는다**(홈으로 이동). 시각과 탭이 일치하는 정상 동작이므로 겹침으로
    세면 거짓 양성이다 — A6-2 의 「내비 침범은 정상 동작」과 같은 계열이다.
    """
    return n.box[3] <= header_px


# ------------------------------------------------------------------------ audit


def audit(nodes: list[Node], metrics: dict, *, package: str = DEFAULT_PACKAGE) -> dict:
    """판정 셋 + 참고 둘. 앱 패키지가 아닌 노드(시스템 UI)는 세지 않는다."""
    app = [n for n in nodes if not package or n.package == package]
    clickable = [n for n in app if n.clickable]
    w, h = metrics["width_px"], metrics["height_px"]
    screen = (0, 0, w, h)

    offscreen = [n for n in clickable if not _intersects(n.box, screen)]

    header_px = metrics.get("header_px", 0)
    overlap = []
    for i, a in enumerate(clickable):
        for b in clickable[i + 1 :]:
            if _is_ancestor(a, b):
                continue  # 조상-자손은 정상적으로 겹친다
            # 레이어가 다르면 정상이다 — 고정 요소가 위에 그려지고 탭도 받는다
            # (2026-11-20 실측). 스크롤 컨테이너 소속 여부가 1차 구분자이고,
            # 그 정보가 없는 화면을 위해 헤더 영역도 본다.
            if a.in_scroll != b.in_scroll:
                continue
            if _in_header(a, header_px) != _in_header(b, header_px):
                continue
            if _intersects(a.box, b.box):
                overlap.append((a, b))

    sb = metrics["status_bar_px"]
    # 스크롤 콘텐츠가 상태바 뒤를 지나는 것은 정상이다 — 고정 요소만 센다.
    statusbar = [n for n in clickable if not n.in_scroll and n.box[1] < sb]

    tap_min = metrics["tap_target_min_px"]
    small = [n for n in clickable if n.w < tap_min or n.h < tap_min]
    nav_top = h - metrics["nav_bar_px"]
    nav = [n for n in clickable if n.box[3] > nav_top]

    return {
        "counts": {
            "nodes_total": len(nodes),
            "nodes_app": len(app),
            "clickable": len(clickable),
        },
        "verdicts": {
            "offscreen": [n.as_dict() for n in offscreen],
            "clickable_overlap": [
                {"a": a.as_dict(), "b": b.as_dict()} for a, b in overlap
            ],
            "statusbar_intrusion": [n.as_dict() for n in statusbar],
        },
        "info": {
            "tap_target_under_48dp": [n.as_dict() for n in small],
            "navbar_intrusion": [n.as_dict() for n in nav],
        },
    }


def reached(nodes: list[Node], expects: list[str]) -> dict:
    """`--expect` 문자열이 화면에 있는지 — 「도달했다」의 대조군."""
    haystack = "\n".join(f"{n.label}\t{n.cls}" for n in nodes)
    found = {e: (e in haystack) for e in expects}
    return {"expects": found, "ok": all(found.values()) if expects else None}


def verdict_total(result: dict) -> int:
    return sum(len(result["verdicts"][k]) for k in VERDICT_KEYS)


# ------------------------------------------------------------------------- dump


def cmd_dump(args) -> int:
    serial = args.serial
    _adb(["shell", "rm", "-f", _DEVICE_XML], serial=serial)
    r = _adb(["shell", "uiautomator", "dump", _DEVICE_XML], serial=serial)
    if r.returncode != 0:
        print(f"uiautomator dump 실패: {r.stderr.strip()}", file=sys.stderr)
        return 2
    raw = _adb(["exec-out", "cat", _DEVICE_XML], serial=serial, text=False)
    if raw.returncode != 0 or not raw.stdout:
        print("XML 을 가져오지 못했다(0바이트) — 셸 경로 변형을 의심한다", file=sys.stderr)
        return 2
    xml_text = raw.stdout.decode("utf-8", errors="replace")

    # 회전을 먼저 읽어야 가로에서 폭·높이가 맞는다(위 screen_metrics 의 경고).
    metrics = screen_metrics(serial, rotation=parse_rotation(xml_text))
    nodes = parse_nodes(xml_text)
    result = audit(nodes, metrics, package=args.package)
    result["label"] = args.label
    result["metrics"] = metrics
    result["package"] = args.package
    result["reached"] = reached(nodes, args.expect or [])

    out_dir = pathlib.Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)
    (out_dir / f"{args.label}.xml").write_text(xml_text, encoding="utf-8")
    json_path = out_dir / f"{args.label}.json"
    json_path.write_text(
        json.dumps(result, ensure_ascii=False, indent=2), encoding="utf-8"
    )

    _print_one(result)
    print(f"\n저장: {json_path}")

    if result["reached"]["ok"] is False:
        missing = [k for k, v in result["reached"]["expects"].items() if not v]
        print(f"\n⚠️ 도달 확인 실패 — 화면에 없는 문자열: {missing}", file=sys.stderr)
        print("   이 상태의 「위반 0건」은 결과가 아니다.", file=sys.stderr)
        return 3
    return 1 if verdict_total(result) else 0


def _print_one(result: dict) -> None:
    m = result["metrics"]
    c = result["counts"]
    print(f"[{result.get('label', '?')}] {m['width_px']}x{m['height_px']} @{m['dpi']}dpi "
          f"= {m['width_dp']}x{m['height_dp']}dp · 1dp={m['scale']:.3f}px")
    print(f"  노드 {c['nodes_total']} (앱 {c['nodes_app']}) · 클릭 가능 {c['clickable']}")
    rc = result.get("reached") or {}
    if rc.get("expects"):
        marks = " ".join(
            ("✅" if v else "❌") + k for k, v in rc["expects"].items()
        )
        print(f"  도달: {marks}")
    print("  판정:")
    for k in VERDICT_KEYS:
        items = result["verdicts"][k]
        mark = "✅" if not items else "🔴"
        print(f"    {mark} {k}: {len(items)}건")
        for it in items[:5]:
            if k == "clickable_overlap":
                print(f"       {it['a']['label'][:28]!r} ∩ {it['b']['label'][:28]!r}")
            else:
                print(f"       {it['label'][:40]!r} {it['bounds']}")
    print("  참고(판정 아님):")
    for k in INFO_KEYS:
        items = result["info"][k]
        print(f"    · {k}: {len(items)}건")


def cmd_report(args) -> int:
    paths: list[str] = []
    for pattern in args.paths:
        paths.extend(sorted(glob.glob(pattern)))
    if not paths:
        print("읽을 JSON 이 없다", file=sys.stderr)
        return 2
    rows = []
    bad = 0
    for p in paths:
        r = json.loads(pathlib.Path(p).read_text(encoding="utf-8"))
        total = verdict_total(r)
        bad += 1 if total else 0
        rows.append(
            (
                r.get("label", os.path.basename(p)),
                f"{r['metrics']['width_dp']}x{r['metrics']['height_dp']}",
                r["counts"]["clickable"],
                "ok" if (r.get("reached") or {}).get("ok") is not False else "MISS",
                len(r["verdicts"]["offscreen"]),
                len(r["verdicts"]["clickable_overlap"]),
                len(r["verdicts"]["statusbar_intrusion"]),
                len(r["info"]["tap_target_under_48dp"]),
                len(r["info"]["navbar_intrusion"]),
            )
        )
    head = ("화면", "dp", "클릭", "도달", "밖", "겹침", "상태바", "(48미달)", "(내비)")
    widths = [max(len(str(h)), *(len(str(r[i])) for r in rows)) for i, h in enumerate(head)]
    print(" | ".join(str(h).ljust(widths[i]) for i, h in enumerate(head)))
    print("-+-".join("-" * w for w in widths))
    for r in rows:
        print(" | ".join(str(v).ljust(widths[i]) for i, v in enumerate(r)))
    print(f"\n{len(rows)}화면 · 판정 위반이 있는 화면 {bad}개")
    return 1 if bad else 0


# --------------------------------------------------------------------- self-test


def _synth(label, box, *, clickable=True, path="/0", package=DEFAULT_PACKAGE,
           in_scroll=False):
    return Node(label, "android.view.View", package, clickable, box, path, in_scroll)


def cmd_self_test(_args) -> int:
    """판정 로직을 합성 입력으로 검증한다. 대조군이 없으면 0건이 결과가 아니다."""
    m = {
        "width_px": 1080,
        "height_px": 2400,
        "dpi": 420,
        "scale": 2.625,
        "status_bar_px": 63,
        "nav_bar_px": 126,
        "tap_target_min_px": 126,
        "header_px": 210,  # (24 + 56) * 2.625
    }
    fails: list[str] = []

    def check(name: str, got, want):
        if got != want:
            fails.append(f"{name}: {got} != {want}")

    # ① 깨끗한 화면 — 전부 0 (이 행이 없으면 아래 양성들이 "늘 1"인지 구별되지 않는다)
    clean = [
        _synth("상단", (0, 100, 1080, 226), path="/0"),
        _synth("하단", (0, 400, 1080, 526), path="/1"),
    ]
    r = audit(clean, m)
    check("clean/offscreen", len(r["verdicts"]["offscreen"]), 0)
    check("clean/overlap", len(r["verdicts"]["clickable_overlap"]), 0)
    check("clean/statusbar", len(r["verdicts"]["statusbar_intrusion"]), 0)
    check("clean/tap", len(r["info"]["tap_target_under_48dp"]), 0)
    check("clean/nav", len(r["info"]["navbar_intrusion"]), 0)

    # ② 화면과 교집합이 없는 클릭 대상 → offscreen 1
    r = audit(clean + [_synth("밖", (1200, 100, 1400, 226), path="/2")], m)
    check("offscreen/hit", len(r["verdicts"]["offscreen"]), 1)

    # ③ 형제끼리 겹치면 overlap 1
    r = audit(
        [
            _synth("A", (0, 100, 600, 226), path="/0"),
            _synth("B", (500, 100, 1080, 226), path="/1"),
        ],
        m,
    )
    check("overlap/hit", len(r["verdicts"]["clickable_overlap"]), 1)

    # ④ 대조군 — 조상-자손은 겹쳐도 위반이 아니다
    r = audit(
        [
            _synth("부모", (0, 100, 1080, 300), path="/0"),
            _synth("자식", (20, 120, 400, 280), path="/0/1"),
        ],
        m,
    )
    check("overlap/ancestor-exempt", len(r["verdicts"]["clickable_overlap"]), 0)

    # ⑤ 상태바 침범
    r = audit([_synth("위", (0, 10, 1080, 136), path="/0")], m)
    check("statusbar/hit", len(r["verdicts"]["statusbar_intrusion"]), 1)

    # ⑥ 대조군 — 48dp 미달은 **참고**에만 올라가고 판정은 0 이다 (A6-1 정정의 보존)
    r = audit([_synth("작은", (0, 200, 90, 290), path="/0")], m)
    check("tap/info-only", len(r["info"]["tap_target_under_48dp"]), 1)
    check("tap/not-a-verdict", verdict_total(r), 0)

    # ⑦ 대조군 — 내비 침범도 참고에만 올라간다 (A6-2 정정의 보존)
    r = audit([_synth("바닥", (0, 2280, 1080, 2400), path="/0")], m)
    check("nav/info-only", len(r["info"]["navbar_intrusion"]), 1)
    check("nav/not-a-verdict", verdict_total(r), 0)

    # ⑧ 시스템 UI 노드는 세지 않는다 (uiautomator 가 내비 바를 노드로 보고한다)
    r = audit(
        [_synth("navbar", (0, 2274, 1080, 2400), path="/0", package="com.android.systemui")],
        m,
    )
    check("system/excluded", r["counts"]["clickable"], 0)

    # ⑨ 도달 확인 — 있는 문자열과 없는 문자열
    rc = reached(clean, ["상단", "없는문자열"])
    check("reached/ok", rc["ok"], False)
    check("reached/found", rc["expects"]["상단"], True)

    # ⑪ 고정 헤더 소속과 스크롤 콘텐츠가 겹치면 면제 (2026-11-20 실측으로 추가)
    r = audit(
        [
            _synth("뒤로", (76, 80, 176, 190), path="/0"),  # box[3]=190 <= 210
            _synth("카드", (63, 104, 1017, 256), path="/1"),  # 헤더 밖까지 뻗는다
        ],
        m,
    )
    check("overlap/header-exempt", len(r["verdicts"]["clickable_overlap"]), 0)

    # ⑫ 대조군 — 둘 다 헤더 안이면 헤더 내부의 진짜 겹침이므로 센다
    r = audit(
        [
            _synth("뒤로", (76, 80, 176, 190), path="/0"),
            _synth("메뉴", (150, 80, 260, 190), path="/1"),
        ],
        m,
    )
    check("overlap/inside-header-counted", len(r["verdicts"]["clickable_overlap"]), 1)

    # ⑩ XML 파싱 왕복
    nodes = parse_nodes(
        '<hierarchy rotation="0">'
        '<node class="android.widget.FrameLayout" package="kr.ai.leva.awsdocs"'
        ' bounds="[0,0][1080,2400]" clickable="false">'
        '<node class="android.view.View" package="kr.ai.leva.awsdocs"'
        ' content-desc="홈" bounds="[10,20][136,146]" clickable="true"/>'
        "</node></hierarchy>"
    )
    check("parse/count", len(nodes), 2)
    check("parse/label", nodes[1].label, "홈")
    check("parse/clickable", nodes[1].clickable, True)
    check("parse/box", nodes[1].box, (10, 20, 136, 146))

    # ⑭ 스크롤 콘텐츠가 상태바 뒤를 지나는 것은 정상 / 고정 요소는 잡힌다
    r = audit([_synth("지나가는 카드", (0, 10, 1080, 136), path="/0", in_scroll=True)], m)
    check("statusbar/scroll-exempt", len(r["verdicts"]["statusbar_intrusion"]), 0)
    r = audit([_synth("고정 버튼", (0, 10, 1080, 136), path="/0")], m)
    check("statusbar/fixed-counted", len(r["verdicts"]["statusbar_intrusion"]), 1)

    # ⑮ 레이어가 다르면(고정 ↔ 스크롤) 겹침 면제 — 헤더 영역 밖에서도 성립한다
    r = audit(
        [
            _synth("고정 FAB", (800, 900, 1000, 1100), path="/0"),
            _synth("지나가는 행", (63, 950, 1017, 1050), path="/1", in_scroll=True),
        ],
        m,
    )
    check("overlap/layer-exempt", len(r["verdicts"]["clickable_overlap"]), 0)

    # ⑯ 대조군 — 같은 레이어(둘 다 스크롤 콘텐츠)면 센다
    r = audit(
        [
            _synth("행 A", (63, 950, 600, 1050), path="/0", in_scroll=True),
            _synth("행 B", (500, 950, 1017, 1050), path="/1", in_scroll=True),
        ],
        m,
    )
    check("overlap/same-layer-counted", len(r["verdicts"]["clickable_overlap"]), 1)

    # ⑰ XML 의 scrollable 이 자손에게 전파된다
    ns = parse_nodes(
        '<hierarchy rotation="0">'
        '<node class="android.view.View" package="kr.ai.leva.awsdocs"'
        ' content-desc="헤더" bounds="[0,0][1080,200]" clickable="true"/>'
        '<node class="android.widget.ScrollView" package="kr.ai.leva.awsdocs"'
        ' bounds="[0,0][1080,2400]" scrollable="true" clickable="false">'
        '<node class="android.view.View" package="kr.ai.leva.awsdocs"'
        ' content-desc="행" bounds="[0,300][1080,400]" clickable="true"/>'
        "</node></hierarchy>"
    )
    by = {n.label: n for n in ns if n.label}
    check("scroll/header-fixed", by["헤더"].in_scroll, False)
    check("scroll/row-in-scroll", by["행"].in_scroll, True)

    # ⑬ 회전 파싱 — 가로에서 폭·높이를 바꾸지 않으면 오른쪽 요소가 전부 「화면 밖」이 된다
    check("rotation/portrait", parse_rotation('<hierarchy rotation="0">'), 0)
    check("rotation/landscape", parse_rotation('<hierarchy index="0" rotation="1">'), 1)
    check("rotation/missing", parse_rotation("<hierarchy>"), 0)

    if fails:
        print("self-test 실패:")
        for f in fails:
            print(f"  - {f}")
        return 1
    print("self-test 통과 — 17개 묶음(대조군 11 포함)")
    return 0


# ------------------------------------------------------------------------- main


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(
        prog="android_ui_audit",
        description="Android 화면의 레이아웃 결함을 접근성 노드 좌표로 센다 (A6).",
    )
    p.add_argument("--self-test", action="store_true", help="합성 입력으로 판정 로직 검증")
    sub = p.add_subparsers(dest="cmd")

    d = sub.add_parser("dump", help="현재 화면을 덤프해 판정한다")
    d.add_argument("--label", required=True, help="화면 이름(파일명이 된다)")
    d.add_argument(
        "--expect",
        action="append",
        help="그 화면에 있어야 하는 문자열(도달 대조군, 여러 번 가능)",
    )
    d.add_argument("--package", default=DEFAULT_PACKAGE)
    d.add_argument("--out", default=DEFAULT_OUT)
    d.add_argument("--serial", default=None, help="adb -s 대상")
    d.set_defaults(func=cmd_dump)

    r = sub.add_parser("report", help="덤프 JSON 들을 표로")
    r.add_argument("paths", nargs="+")
    r.set_defaults(func=cmd_report)

    args = p.parse_args(argv)
    if args.self_test:
        return cmd_self_test(args)
    if not getattr(args, "func", None):
        p.print_help()
        return 2
    return args.func(args)


if __name__ == "__main__":
    sys.exit(main())
