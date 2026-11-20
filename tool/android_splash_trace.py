#!/usr/bin/env python3
"""Android 콜드 스타트의 **스플래시 색 전환**을 프레임 단위로 재는 측정 도구 (A6-4).

왜 별 도구인가: `tool/android_ui_audit.py` 는 접근성 노드 좌표로 레이아웃을 판정하는데,
스플래시는 **노드가 없는 단색 화면**이라 그 방식으로는 아무것도 보이지 않는다. 여기서
재는 것은 「시스템 스플래시 색 → Flutter 첫 프레임 색」 전환이고, 그것은 녹화 프레임의
색으로만 보인다.

왜 `screencap` 루프가 아닌가: raw 전송이 캡처당 ~800ms 라 2초 안에 끝나는 전환을 놓친다
(2026-11-20 실측 — 그 간격으로는 1,867ms 다크 구간의 경계를 못 집었다). `screenrecord` 는
기기에서 녹화해 프레임 손실이 없다.

⚠️ 판정 지점은 **상단(540,350)·하단(540,2100) 100x100 평균 두 곳**이고, 그 둘이 같은 색일
때만 「단색 전체화면」으로 센다. 런처 화면과 앱 콘텐츠 화면은 두 지점이 다르므로 자동으로
빠진다 — 그래서 **첫 단색 구간이 스플래시**다.

⚠️ 알려진 한계: 이 측정은 **다음** 콜드 스타트에 적용되는 `setSplashScreenTheme` 을 보려는
것이므로, 테마를 바꾼 뒤에는 `onPause`(홈 키)를 거친 다음에 재야 한다. `matrix` 가 그
순서를 지킨다.

사용법:
    py tool/android_splash_trace.py trace --label r2 [--expect LIGHT]
    py tool/android_splash_trace.py matrix       # 다섯 조합 전부(앱 테마를 직접 토글한다)
    py tool/android_splash_trace.py --self-test  # 구간 추출 로직만 검증(기기 불필요)

전제: adb 와 ffmpeg 가 PATH 에 있거나 아래 상수 경로에 있어야 한다. 기기 하나가 붙어 있고
앱이 설치돼 있어야 한다. 판정의 정본은 `docs/audits/2026-11-19-a6-mobile-usability-audit.md`.
"""
from __future__ import annotations

import argparse
import os
import re
import shutil
import struct
import subprocess
import sys
import tempfile
import time

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

DEFAULT_PACKAGE = "kr.ai.leva.awsdocs"

# 앱의 라이트·다크 배경(DESIGN.md / web index.html 의 theme-color 와 같은 값).
LIGHT = (251, 250, 248)  # #FBFAF8
DARK = (20, 24, 31)      # #14181F
# 압축 손실을 감안한 허용 오차. 30fps H.264 에서 단색면이 ±5 안쪽으로 흔들린다(실측).
TOL = 6

_SDK = os.path.expandvars(r"%LOCALAPPDATA%\Android\Sdk")
_ADB_FALLBACK = os.path.join(_SDK, "platform-tools", "adb.exe")


def _tool(name: str, fallback: str | None = None) -> str:
    found = shutil.which(name)
    if found:
        return found
    if fallback and os.path.exists(fallback):
        return fallback
    raise SystemExit(f"{name} 을 찾지 못했다 — PATH 에 넣거나 경로를 지정하라")


def _adb(*args: str, serial: str | None = None) -> subprocess.CompletedProcess:
    cmd = [_tool("adb", _ADB_FALLBACK)]
    if serial:
        cmd += ["-s", serial]
    # ⚠️ MSYS(Git Bash)가 `/sdcard/...` 를 Windows 경로로 변형하므로 셸을 거치지 않는다.
    return subprocess.run(cmd + list(args), capture_output=True)


def near(c, ref, tol: int = TOL) -> bool:
    return all(abs(c[i] - ref[i]) <= tol for i in range(3))


def tag(c) -> str:
    """색을 앱 테마 이름으로 분류한다. 모르는 색은 그대로 보여 준다."""
    if near(c, LIGHT):
        return "LIGHT"
    if near(c, DARK):
        return "DARK"
    if near(c, (0, 0, 0), 8):
        return "BLACK"      # NormalTheme 의 Theme.Black colorBackground
    if near(c, (255, 255, 255), 8):
        return "WHITE"      # NormalTheme 의 Theme.Light colorBackground
    return f"other{c}"


def solid_runs(frames, *, min_ms: int = 60) -> list[list]:
    """(ms, top, low) 프레임들에서 **단색 전체화면** 구간만 추린다.

    두 지점이 다른 프레임(런처·앱 콘텐츠)은 버리고, 같은 분류가 이어지면 한 구간으로 묶는다.
    `min_ms` 미만은 전환 프레임이라 버린다.
    """
    runs: list[list] = []
    for ms, top, low in frames:
        if not near(top, low, 10):
            continue
        t = tag(top)
        if runs and runs[-1][0] == t:
            runs[-1][2] = ms
        else:
            runs.append([t, ms, ms])
    return [r for r in runs if r[2] - r[1] >= min_ms]


def _frames_from_mp4(mp4: str) -> list[tuple[int, tuple, tuple]]:
    fc = ("[0:v]crop=100:100:490:300,scale=1:1[a];"
          "[0:v]crop=100:100:490:2050,scale=1:1[b];[a][b]vstack[v]")
    p = subprocess.run([_tool("ffmpeg"), "-v", "error", "-i", mp4,
                        "-filter_complex", fc, "-map", "[v]", "-r", "30",
                        "-f", "rawvideo", "-pix_fmt", "rgb24", "-"],
                       capture_output=True)
    buf = p.stdout
    if not buf:
        raise SystemExit(f"ffmpeg 가 프레임을 내지 못했다: {p.stderr[:300]!r}")
    out = []
    for i in range(len(buf) // 6):
        out.append((i * 1000 // 30,
                    tuple(buf[i * 6:i * 6 + 3]),
                    tuple(buf[i * 6 + 3:i * 6 + 6])))
    return out


def cold_trace(*, package: str, serial: str | None, outdir: str,
               label: str, seconds: int = 8) -> list[list]:
    """앱을 강제 종료하고 콜드 스타트하며 녹화 → 단색 구간 목록."""
    _adb("shell", "am", "force-stop", package, serial=serial)
    time.sleep(1.5)
    mp4 = os.path.join(outdir, f"{label}.mp4")
    adb_bin = _tool("adb", _ADB_FALLBACK)
    cmd = [adb_bin] + (["-s", serial] if serial else [])
    rec = subprocess.Popen(cmd + ["shell", "screenrecord", "--time-limit", str(seconds),
                                  "--bit-rate", "12000000", "/sdcard/_splash_trace.mp4"],
                           stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    time.sleep(2.0)  # 녹화가 실제로 시작되기를 기다린다(그 전에 start 하면 앞부분을 놓친다)
    _adb("shell", "am", "start", "-n", f"{package}/.MainActivity", serial=serial)
    rec.wait(timeout=seconds + 30)
    time.sleep(1.0)
    _adb("pull", "/sdcard/_splash_trace.mp4", mp4, serial=serial)
    _adb("shell", "rm", "/sdcard/_splash_trace.mp4", serial=serial)
    return solid_runs(_frames_from_mp4(mp4))


def app_theme_now(*, serial: str | None) -> str:
    """떠 있는 앱의 배경색으로 현재 테마를 판정한다(헤더 아래 지점)."""
    raw = _adb("exec-out", "screencap", serial=serial).stdout
    w, h, _fmt, _cs = struct.unpack("<IIII", raw[:16])
    px = raw[16:]
    o = (300 * w + w // 2) * 4
    return tag((px[o], px[o + 1], px[o + 2]))


def _theme_button(*, serial: str | None):
    _adb("shell", "uiautomator", "dump", "/sdcard/_splash_ui.xml", serial=serial)
    xml = _adb("shell", "cat", "/sdcard/_splash_ui.xml",
               serial=serial).stdout.decode("utf-8", "replace")
    _adb("shell", "rm", "/sdcard/_splash_ui.xml", serial=serial)
    for m in re.finditer(r'content-desc="([^"]*)"[^>]*?clickable="true"'
                         r'[^>]*?bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"', xml):
        if re.search("다크 모드|라이트 모드", m.group(1)):
            x1, y1, x2, y2 = (int(m.group(i)) for i in range(2, 6))
            return m.group(1), (x1 + x2) // 2, (y1 + y2) // 2
    return None, None, None


def ensure_app_theme(want: str, *, package: str, serial: str | None) -> bool:
    """앱 테마를 want('LIGHT'|'DARK')로 맞추고 **홈 키로 onPause 를 일으킨다**.

    ⚠️ 토글 버튼의 라벨은 **현재 상태의 반대**를 가리킨다(라이트면 「다크 모드」). 그래서
    라벨로 상태를 추정하지 않고 **배경색으로 확인**한다 — 2026-11-20 1차 측정이 그 추정
    때문에 「앱이 라이트」라고 잘못 읽었다.
    """
    _adb("shell", "am", "start", "-n", f"{package}/.MainActivity", serial=serial)
    time.sleep(4.0)
    now = app_theme_now(serial=serial)
    if now != want:
        desc, x, y = _theme_button(serial=serial)
        if x is None:
            print(f"   !! 테마 토글 버튼을 찾지 못했다(현재 {now})")
            return False
        print(f"   토글: 현재={now} 버튼={desc!r} at ({x},{y})")
        _adb("shell", "input", "tap", str(x), str(y), serial=serial)
        time.sleep(2.0)
        now = app_theme_now(serial=serial)
    # setSplashScreenTheme 은 onCreate·onPause 에서 불린다 — 홈 키로 저장을 확실히 한다.
    _adb("shell", "input", "keyevent", "KEYCODE_HOME", serial=serial)
    time.sleep(2.0)
    return now == want


def _print_runs(runs: list[list], expect: str | None) -> bool:
    for t, a, b in runs:
        print(f"      {a:>5}~{b:<5}ms ({b - a:>4}ms)  {t}")
    splash = runs[0][0] if runs else "(없음)"
    if expect is None:
        print(f"      => 스플래시={splash}")
        return True
    ok = splash == expect
    print(f"      => 스플래시={splash} 기대={expect}  [{'OK' if ok else 'MISMATCH'}]")
    return ok


def cmd_trace(args) -> int:
    outdir = args.outdir or tempfile.mkdtemp(prefix="splash_trace_")
    os.makedirs(outdir, exist_ok=True)
    runs = cold_trace(package=args.package, serial=args.serial,
                      outdir=outdir, label=args.label)
    print(f"### {args.label}  (mp4: {outdir})")
    return 0 if _print_runs(runs, args.expect) else 1


def cmd_matrix(args) -> int:
    """다섯 조합. 시스템 다크 모드를 바꾸고 앱 테마를 토글하며 잰다.

    ⚠️ 끝나면 시스템 다크 모드가 **라이트**로 남는다(마지막 단계) — 측정 뒤에 되돌린다.
    """
    outdir = args.outdir or tempfile.mkdtemp(prefix="splash_trace_")
    os.makedirs(outdir, exist_ok=True)
    pkg, serial = args.package, args.serial
    results: dict[str, bool] = {}

    def step(key, label, note, expect, *, want_theme=None, system=None):
        if system is not None:
            _adb("shell", "cmd", "uimode", "night", system, serial=serial)
            time.sleep(1.5)
            print(f"\n시스템: {'다크' if system == 'yes' else '라이트'}")
        ok_theme = True
        if want_theme is not None:
            print(f"[앱 테마를 {want_theme} 로 맞춘다]")
            ok_theme = ensure_app_theme(want_theme, package=pkg, serial=serial)
        runs = cold_trace(package=pkg, serial=serial, outdir=outdir, label=label)
        print(f"\n### {label} — {note}")
        results[key] = _print_runs(runs, expect) and ok_theme

    # 1) 저장값이 없는 첫 실행은 시스템 테마를 따른다(알려진 한계 — 고칠 수 없다).
    step("1 첫 실행(한계)", "r1-first",
         "저장값 없음 — 설치 직후 첫 실행", "DARK", system="yes")
    # 2~5) 저장값을 따라야 하는 네 조합.
    step("2 시스템다크+앱라이트", "r2-sysdark-applight",
         "시스템 다크 + 앱 라이트", "LIGHT", want_theme="LIGHT")
    step("3 시스템다크+앱다크", "r3-sysdark-appdark",
         "시스템 다크 + 앱 다크", "DARK", want_theme="DARK")
    step("4 시스템라이트+앱다크", "r4-syslight-appdark",
         "시스템 라이트 + 앱 다크 — 저장값을 따라야 한다", "DARK", system="no")
    step("5 시스템라이트+앱라이트", "r5-syslight-applight",
         "시스템 라이트 + 앱 라이트", "LIGHT", want_theme="LIGHT")

    print("\n## 요약")
    for k, v in results.items():
        print(f"   {'OK  ' if v else 'FAIL'}  {k}")
    print(f"\nmp4: {outdir}")
    return 0 if all(results.values()) else 1


def cmd_self_test(_args) -> int:
    """구간 추출 로직을 합성 프레임으로 검증한다(기기·ffmpeg 불필요)."""
    fails: list[str] = []

    def check(name, cond):
        if not cond:
            fails.append(name)

    # 색 분류
    check("LIGHT 분류", tag(LIGHT) == "LIGHT")
    check("DARK 분류", tag(DARK) == "DARK")
    check("압축 오차 허용", tag((249, 249, 247)) == "LIGHT")
    check("검정은 LIGHT/DARK 가 아니다", tag((0, 0, 0)) == "BLACK")
    # ⚠️ 대조군 — 다크(#14181F)와 순흑(#000000)을 섞으면 A6-4 의 1차 수정 전·후를
    # 구별하지 못한다. 둘은 반드시 다른 분류여야 한다.
    check("다크와 순흑을 가른다", tag(DARK) != tag((0, 0, 0)))

    # 단색 구간: 두 지점이 같은 프레임만, 60ms 미만은 버린다
    def f(ms, top, low):
        return (ms, top, low)

    frames = [f(i * 33, DARK, DARK) for i in range(10)]          # 0~297ms DARK
    frames += [f(300 + i * 33, LIGHT, LIGHT) for i in range(10)]  # 300~597ms LIGHT
    runs = solid_runs(frames)
    check("두 구간으로 쪼갠다", [r[0] for r in runs] == ["DARK", "LIGHT"])
    check("구간 경계", runs[0][1] == 0 and runs[1][1] == 300)

    # 런처 화면(두 지점이 다르다)은 빠진다
    mixed = [f(i * 33, (168, 189, 223), (17, 18, 27)) for i in range(10)]
    check("런처 화면은 단색이 아니다", solid_runs(mixed) == [])

    # 짧은 전환 프레임은 빠진다
    blip = ([f(0, DARK, DARK)] + [f(33, (120, 120, 120), (120, 120, 120))]
            + [f(66 + i * 33, LIGHT, LIGHT) for i in range(10)])
    check("전환 프레임을 버린다", [r[0] for r in solid_runs(blip)] == ["LIGHT"])

    print("self-test:", "PASS" if not fails else f"FAIL {fails}")
    return 0 if not fails else 1


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--self-test", action="store_true", help="판정 로직만 검증한다")
    p.add_argument("--package", default=DEFAULT_PACKAGE)
    p.add_argument("--serial", default=None, help="adb -s 대상")
    p.add_argument("--outdir", default=None, help="mp4 를 둘 디렉터리")
    sub = p.add_subparsers(dest="cmd")

    t = sub.add_parser("trace", help="콜드 스타트 한 번을 잰다")
    t.add_argument("--label", default="trace")
    t.add_argument("--expect", choices=["LIGHT", "DARK", "BLACK", "WHITE"], default=None)
    t.set_defaults(func=cmd_trace)

    m = sub.add_parser("matrix", help="다섯 조합을 잰다")
    m.set_defaults(func=cmd_matrix)

    args = p.parse_args(argv)
    if args.self_test:
        return cmd_self_test(args)
    if not getattr(args, "func", None):
        p.print_help()
        return 2
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
