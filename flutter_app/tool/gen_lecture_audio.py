#!/usr/bin/env python3
"""학습 문서(.md) 1개 → 한국어 오디오 강의(mp3) 생성 — 주머니 라디오 M1 T6 임시 픽스처.

T4(미니 플레이어 진입점)가 재생할 "실물" mp3 1개를 만든다. 대본 자동 생성·
환각 가드는 M2이므로 마크다운을 거칠게 평문으로 정제해 읽는다(검증정책 A: 충실
변환·무검수 — 공개 전 사람 검수는 별도). 정제 규칙은 보정 문서
docs/superpowers/specs/2026-06-21-clf-t1-1-tts-audio-correction.md 를 따른다.

정제(markdown_to_speech_text):
  - 제외: frontmatter, 코드 펜스, 표(| ...), 수평선, HTML 주석/이미지, 이모지
  - 제외(섹션): "출처"·"자가 점검" 헤딩 이후 전부, <details> 블록(정답 보기)  [P0-3·P0-5]
  - 변환: → = + ≠ ↓ § vs 를 음성 어구로  [P0-2]
  - 보존: 단어 내부 _(snake_case, 예: ko_kr) — 강조 제거는 *,` 만  [P0-3]
품질 게이트(quality_issues): 정제 후에도 남은 URL·기호·정답보기·링크·고아부호를
  검출한다. M1 픽스처는 경고만 하고 생성은 진행한다(재생 게이트 ≠ 콘텐츠 검수 게이트).

엔진(--engine):
  polly  (기본) — Amazon Polly. mp3 직접 출력(ffmpeg 불필요), 한국어 Seoyeon/Jihye.
                  AWS 자격증명 필요. 6000자 이내면 단일 요청 → ID3 1개(청크 concat 회피, P0-1).
  melotts        — MeloTTS-Korean(MIT, 로컬). Windows는 한국어 G2P(eunjeon) 빌드가 까다롭다.

사용:
  py tool/gen_lecture_audio.py --self-test
  py tool/gen_lecture_audio.py --md <문서> --out <mp3> --dry-run
  py tool/gen_lecture_audio.py --md <문서> --out <mp3> --meta-only
  py tool/gen_lecture_audio.py --md assets/content/clf/t1-1.md \
     --out assets/audio/clf/clf-t1-1/lecture.mp3
"""
import argparse
from datetime import datetime, timezone
import hashlib
import json
import re
import sys
import tempfile
from pathlib import Path

# Windows 콘솔(cp949) 등 비-UTF-8 stdout에서도 한글·기호를 깨짐 없이 출력.
for _stream in (sys.stdout, sys.stderr):
    try:
        _stream.reconfigure(encoding="utf-8")
    except (AttributeError, ValueError):
        pass

# 이모지·픽토그램(TTS 부적합) — 화살표(→)·부등호(≠) 등 '기호'는 _convert_symbols가 처리.
_EMOJI = re.compile(
    r"[\U0001F000-\U0001FAFF\U00002600-\U000027BF"
    r"\U00002B00-\U00002BFF\U0000FE0F\U0000200D\U0000274C\U00002705]")


def _convert_symbols(s: str) -> str:
    """수식·화살표 기호를 음성 어구로 변환(P0-2). 완벽한 문장화는 M2 사람 보정."""
    s = re.sub(r"\s*↓", " 감소", s)
    s = re.sub(r"\s*↑", " 증가", s)
    s = re.sub(r"\(\s*≠\s*([^)]+?)\s*\)", r"(\1 아님)", s)  # (≠ 고가용성) → (고가용성 아님)
    s = re.sub(r"\s*≠\s*", " 와 다름 ", s)
    s = re.sub(r"\s*→\s*", ", ", s)  # 화살표 → 쉼표(멈춤)
    s = re.sub(r"\s*=\s*", ", 즉 ", s)  # 'A = B' → 'A, 즉 B'(한국어 은/는 자동화 회피)
    s = re.sub(r"\s*\+\s*", " 그리고 ", s)
    s = re.sub(r"\bvs\.?\b", " 대 ", s)
    s = re.sub(r"§\s*(\d+)", r"\1번", s)  # §3 → 3번
    s = re.sub(r"§", "", s)
    return s


def markdown_to_speech_text(md: str) -> str:
    """마크다운 → 음성용 평문(거친 정제, M1 임시)."""
    out: list[str] = []
    in_code = False
    in_frontmatter = False
    in_details = False
    skip_rest = False
    for i, raw in enumerate(md.splitlines()):
        s = raw.strip()
        if skip_rest:
            continue
        # YAML frontmatter (--- ... ---) — 파일 맨 앞에서만.
        if i == 0 and s == "---":
            in_frontmatter = True
            continue
        if in_frontmatter:
            if s == "---":
                in_frontmatter = False
            continue
        # <details> 블록(정답 보기 등) 통째 제외 (P0-5).
        if "<details" in s:
            in_details = True
        if in_details:
            if "</details>" in s:
                in_details = False
            continue
        # 코드 펜스 — 내부 제외.
        if s.startswith("```"):
            in_code = not in_code
            continue
        if in_code:
            continue
        # 표 행·빈 줄·HTML 주석·이미지·수평선 제외.
        if s.startswith("|") or not s or s.startswith("<!--") or s.startswith("!["):
            continue
        if re.fullmatch(r"([-*_])\1{2,}", s):
            continue
        # 헤딩: "출처"·"자가 점검" 섹션은 이후 전부 제외 (P0-3·P0-5).
        if s.startswith("#"):
            htext = re.sub(r"^#{1,6}\s*", "", s)
            htext = re.sub(r"\s*\{#[^}]*\}\s*$", "", htext)
            htext = _EMOJI.sub("", htext).strip()
            if "출처" in htext or "자가 점검" in htext or "자가점검" in htext:
                skip_rest = True
                continue
            s = htext
        else:
            # 리스트·인용·체크박스 마커.
            s = re.sub(r"^[-*+]\s+", "", s)
            s = re.sub(r"^\d+\.\s+", "", s)
            s = re.sub(r"^>\s*", "", s)
            s = re.sub(r"^\[[ xX]\]\s*", "", s)
        # 공통 인라인 정리.
        s = re.sub(r"\s*\{#[^}]*\}\s*$", "", s)          # 잔여 {#anchor}
        s = re.sub(r"!\[[^\]]*\]\([^)]*\)", "", s)         # 이미지
        s = re.sub(r"\[([^\]]+)\]\([^)]*\)", r"\1", s)     # 링크 → 텍스트
        s = re.sub(r"<[^>]+>", "", s)                       # HTML 태그
        s = re.sub(r"[*`]+", "", s)                         # 강조(별표·백틱만 — _ 보존)
        s = _EMOJI.sub("", s)                               # 이모지
        s = _convert_symbols(s)                             # 기호 → 어구
        # 공백·고아 문장부호 정리.
        s = re.sub(r"\s{2,}", " ", s)
        s = re.sub(r"\s+([.,)\]])", r"\1", s)              # 부호 앞 공백
        s = re.sub(r"([(\[])\s+", r"\1", s)                # 여는 괄호 뒤 공백
        s = re.sub(r",\s*\.", ".", s)                       # ", ." → "."
        s = re.sub(r"([.,])\1+", r"\1", s)                 # 연속 동일 부호
        s = s.strip().strip(",")
        if s and not re.fullmatch(r"[.,\-\s]*", s):        # 고아 부호만인 줄 제외
            out.append(s)
    return "\n".join(out)


def _clean_inline(s: str) -> str:
    """한 줄/문단 텍스트의 인라인 마크다운·기호를 음성 평문으로 정리(scriptText용)."""
    s = re.sub(r"\s*\{#[^}]*\}\s*$", "", s)
    s = re.sub(r"!\[[^\]]*\]\([^)]*\)", "", s)
    s = re.sub(r"\[([^\]]+)\]\([^)]*\)", r"\1", s)
    s = re.sub(r"<[^>]+>", "", s)
    s = re.sub(r"[*`]+", "", s)
    s = _EMOJI.sub("", s)
    s = _convert_symbols(s)
    s = re.sub(r"\s{2,}", " ", s)
    s = re.sub(r"\s+([.,)\]])", r"\1", s)
    s = re.sub(r"([(\[])\s+", r"\1", s)
    s = re.sub(r",\s*\.", ".", s)
    s = re.sub(r"([.,])\1+", r"\1", s)
    return s.strip().strip(",")


def _strip_list_markers(s: str) -> str:
    """리스트·인용·체크박스 줄머리 마커 제거."""
    s = re.sub(r"^[-*+]\s+", "", s)
    s = re.sub(r"^\d+\.\s+", "", s)
    s = re.sub(r"^>\s*", "", s)
    s = re.sub(r"^\[[ xX]\]\s*", "", s)
    return s


def parse_segments(md: str) -> list[dict]:
    """md를 segment dict 리스트로 분해. kind 분류 + scriptText 정제(발음사전·표요약 제외)."""
    segs: list[dict] = []

    def _add(kind, excerpt, script, *, skip=False, audio_summary=None, issues=None):
        segs.append({
            "id": f"seg{len(segs):03d}",
            "kind": kind,
            "sourceExcerpt": excerpt.strip(),
            "scriptText": script,
            "audioSummary": audio_summary,
            "skip": skip,
            "issues": list(issues or []),
        })

    lines = md.splitlines()
    n = len(lines)
    i = 0
    if i < n and lines[i].strip() == "---":            # frontmatter
        i += 1
        while i < n and lines[i].strip() != "---":
            i += 1
        i += 1
    in_selfcheck = False
    while i < n:
        s = lines[i].strip()
        if not s:
            i += 1
            continue
        if s.startswith("```"):                          # 코드펜스 제외
            i += 1
            while i < n and not lines[i].strip().startswith("```"):
                i += 1
            i += 1
            continue
        if (re.fullmatch(r"([-*_])\1{2,}", s) or s.startswith("<!--")
                or s.startswith("![")):                  # 수평선·주석·이미지
            i += 1
            continue
        if "<details" in s:                              # 정답 보기 블록
            block = [lines[i]]
            i += 1
            while i < n and "</details>" not in lines[i]:
                block.append(lines[i])
                i += 1
            if i < n:
                block.append(lines[i])
                i += 1
            _add("selfcheck", "\n".join(block), "", skip=True)
            continue
        if s.startswith("#"):                            # 헤딩
            htext = re.sub(r"^#{1,6}\s*", "", s)
            htext = re.sub(r"\s*\{#[^}]*\}\s*$", "", htext)
            htext = _EMOJI.sub("", htext).strip()
            if "출처" in htext:                           # 출처 헤딩 → 이후 전부 source/skip
                _add("source", "\n".join(lines[i:]), "", skip=True)
                break
            if "자가 점검" in htext or "자가점검" in htext:
                _add("selfcheck", s, "", skip=True)
                in_selfcheck = True
                i += 1
                continue
            if in_selfcheck:
                _add("selfcheck", s, "", skip=True)
                i += 1
                continue
            _add("heading", s, _clean_inline(htext))
            i += 1
            continue
        if s.startswith("|"):                            # 표 블록
            tbl = []
            while i < n and lines[i].strip().startswith("|"):
                tbl.append(lines[i].strip())
                i += 1
            summary, tissues = table_to_summary(tbl)
            _add("table", "\n".join(tbl), "",
                 audio_summary=summary, issues=tissues)
            continue
        # 문단(연속 비빈 줄). 자가점검 구간이면 skip 본문.
        para = []
        while (i < n and lines[i].strip()
               and not lines[i].strip().startswith(("#", "|", "```", "<details"))):
            para.append(_strip_list_markers(lines[i].strip()))
            i += 1
        excerpt = " ".join(para)
        if in_selfcheck:
            _add("selfcheck", excerpt, "", skip=True)
            continue
        script = _clean_inline(excerpt)
        if script:
            _add("paragraph", excerpt, script)
    return segs


def load_lexicon(path) -> dict:
    """발음사전 entries dict 로드. path=None이면 도구 옆 lexicon.json."""
    if path is None:
        path = Path(__file__).with_name("lexicon.json")
    else:
        path = Path(path)
    if not path.exists():
        return {}
    data = json.loads(path.read_text(encoding="utf-8"))
    return data.get("entries", {})


def apply_lexicon(text: str, lexicon: dict, seen: set) -> tuple[str, list[str]]:
    """사전 치환(첫 등장/이후, 단어 경계). 반환: (치환 text, 미등록 토큰 issues)."""
    issues: list[str] = []
    # 긴 키부터 치환(예: 'CLF-C02'가 'C'보다 먼저).
    for key in sorted(lexicon, key=len, reverse=True):
        entry = lexicon[key]
        pattern = r"(?<![0-9A-Za-z])" + re.escape(key) + r"(?![0-9A-Za-z])"
        if not re.search(pattern, text):
            continue
        if "firstSay" in entry or "thenSay" in entry:
            first = entry.get("firstSay", entry.get("say", key))
            later = entry.get("thenSay", entry.get("say", key))

            def _repl(_m, _k=key, _first=first, _later=later):
                if _k in seen:
                    return _later
                seen.add(_k)
                return _first
            text = re.sub(pattern, _repl, text)
        else:
            text = re.sub(pattern, entry.get("say", key), text)
            seen.add(key)
    # 발음 치환으로 생긴 "X(X)" 중복 괄호 제거(예: 온디맨드(on-demand)→온디맨드(온디맨드)→온디맨드).
    text = re.sub(r"([^\s()]+(?:\s[^\s()]+)*)\(\1\)", r"\1", text)
    # 남은 영문 대문자 토큰(2자 이상) → 미등록 경고.
    for tok in sorted(set(re.findall(r"(?<![0-9A-Za-z])[A-Z][A-Z0-9]{1,}(?![0-9A-Za-z])", text))):
        issues.append(f"unmapped-token: {tok}")
    return text, issues


# 수치 토큰: 앞에 영문/숫자가 붙지 않은 독립 숫자만(약어 내부 숫자 'CLF-C02'의 02 제외).
_NUM_RE = re.compile(r"(?<![A-Za-z0-9])\d+(?:[.,]\d+)?%?")


def _lexicon_say_forms(entry: dict, key: str) -> list[str]:
    """검출용 발음 후보(say 또는 firstSay/thenSay). 빈 값 제거."""
    if "firstSay" in entry or "thenSay" in entry:
        forms = [entry.get("firstSay"), entry.get("thenSay"), entry.get("say")]
    else:
        forms = [entry.get("say", key)]
    return [f for f in forms if f]


def check_token_preservation(source: str, target: str,
                             lexicon: dict) -> tuple[list[str], list[str]]:
    """source 원문의 핵심 토큰이 target 대본에 보존됐는지 검사.
    약어(lexicon 등록) 누락=hard, 수치 누락=soft. 반환 (hard, soft)."""
    hard: list[str] = []
    soft: list[str] = []
    for key in sorted(lexicon, key=len, reverse=True):       # 긴 키 우선(apply_lexicon과 동일)
        pattern = r"(?<![0-9A-Za-z])" + re.escape(key) + r"(?![0-9A-Za-z])"
        if not re.search(pattern, source):
            continue
        says = _lexicon_say_forms(lexicon[key], key)
        if says and not any(say in target for say in says):
            hard.append(f"약어 누락: {key}({says[0]})")
    for num in dict.fromkeys(_NUM_RE.findall(source)):        # 순서 보존 dedupe
        if num not in target:
            soft.append(f"수치 누락: {num}")
    return hard, soft


def table_to_summary(table_lines: list[str]) -> tuple:
    """마크다운 표 → (audioSummary, issues). 2열만 초벌 생성, 그 외 None."""
    rows = []
    for ln in table_lines:
        cells = [c.strip() for c in ln.strip().strip("|").split("|")]
        if cells and all(re.fullmatch(r":?-{3,}:?", c or "x") for c in cells):
            continue  # 구분행(|---|---|)
        rows.append(cells)
    if len(rows) < 2:
        return None, ["table-needs-summary"]
    if len(rows[0]) != 2:                       # 헤더 폭으로 열 수 판정
        return None, ["table-needs-summary"]
    parts = []
    for r in rows[1:]:                          # 헤더 제외 본문
        if len(r) >= 2 and r[0] and r[1]:
            parts.append(f"{_clean_inline(r[0])}은 {_clean_inline(r[1])}입니다.")
    if not parts:
        return None, ["table-needs-summary"]
    return " ".join(parts), ["table-summary-draft"]


def build_script_json(md: str, *, doc_id: str, source_asset: str,
                      lexicon: dict) -> dict:
    """parse_segments + 발음사전 치환 + (표는 audioSummary 치환) → schemaVersion 2 dict."""
    segs = parse_segments(md)
    seen: set = set()
    for seg in segs:
        if seg["scriptText"]:
            seg["scriptText"], li = apply_lexicon(seg["scriptText"], lexicon, seen)
            seg["issues"] = list(dict.fromkeys(seg["issues"] + li))
        if seg.get("audioSummary"):
            seg["audioSummary"], li = apply_lexicon(seg["audioSummary"], lexicon, seen)
            seg["issues"] = list(dict.fromkeys(seg["issues"] + li))
    lex_hash = hashlib.sha256(
        json.dumps(lexicon, ensure_ascii=False, sort_keys=True).encode("utf-8")
    ).hexdigest()[:12]
    return {
        "schemaVersion": 2,
        "docId": doc_id,
        "sourceAsset": source_asset,
        "sourceHash": hashlib.sha256(md.encode("utf-8")).hexdigest(),
        "lexiconVersion": lex_hash,
        "generatedAt": _utc_now(),
        "reviewStatus": "needs_human_review",
        "segments": segs,
    }


def review_checklist_md(doc_id: str) -> str:
    """청취 검수표 템플릿(사람이 작성)."""
    return (
        f"# 청취 검수표 — {doc_id}\n\n"
        "- [ ] 표 핵심 정보가 음성에 포함됐다.\n"
        "- [ ] 약어 발음이 자연스럽다.\n"
        "- [ ] 출처 URL을 읽지 않는다.\n"
        "- [ ] 자가 점검 음성 흐름이 자연스럽다.\n"
        "- [ ] 첫 20초가 헤더 낭독이 아니다.\n"
        "- [ ] 청크 경계 끊김·메타 재해석이 없다.\n"
        "- [ ] 사실 정확성: 고유명사·서비스명·수치가 원문과 일치한다.\n\n"
        "reviewer: ____________   날짜: ____________\n\n"
        "승인 시 script.json·audio_meta.json의 reviewStatus를 approved로 수동 변경한다.\n"
    )


def run_generate(args) -> None:
    md = args.md.read_text(encoding="utf-8")
    doc_id = args.doc_id or args.out_dir.name
    script = build_script_json(
        md, doc_id=doc_id, source_asset=_asset_path(args.md),
        lexicon=load_lexicon(args.lexicon))
    write_json(args.out_dir / "script.json", script)
    (args.out_dir).mkdir(parents=True, exist_ok=True)
    (args.out_dir / "review_checklist.md").write_text(
        review_checklist_md(doc_id), encoding="utf-8")
    n_issues = sum(len(s["issues"]) for s in script["segments"])
    print(f"[generate] {len(script['segments'])} segments, "
          f"{n_issues} issues → {args.out_dir / 'script.json'}", file=sys.stderr)


def script_to_speech(script: dict) -> str:
    """script.json → 합성용 평문. skip 제외, table은 audioSummary, 그 외 scriptText."""
    parts: list[str] = []
    for s in script["segments"]:
        if s.get("skip"):
            continue
        if s["kind"] == "table":
            if s.get("audioSummary"):
                parts.append(s["audioSummary"])
        elif s.get("scriptText"):
            parts.append(s["scriptText"])
    return "\n".join(parts)


def run_synthesize(args) -> None:
    import tempfile
    script = json.loads(args.script.read_text(encoding="utf-8"))
    sections = split_sections(script["segments"])
    if not any(s["speech"].strip() for s in sections):
        sys.exit("script.json에 합성할 scriptText가 없습니다.")
    max_chars = args.max_chars or 2900
    final = bytearray()
    durations_ms: list[int] = []
    with tempfile.TemporaryDirectory() as td:
        for i, sec in enumerate(sections):
            sp = sec["speech"]
            if not sp.strip():
                durations_ms.append(0)
                continue
            chunks = chunk_text(sp, max_chars)
            data = _synthesize_chunks_to_bytes(
                chunks, args.voice, args.polly_engine, args.region)
            tmp = Path(td) / f"sec{i}.mp3"
            tmp.write_bytes(data)
            durations_ms.append(_audio_duration_ms(tmp))
            final += data if not final else _strip_id3v2(data)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_bytes(bytes(final))
    print(f"[synthesize] {len(sections)}섹션 → {args.out}", file=sys.stderr)
    if not args.skip_loudnorm:
        import shutil
        if shutil.which("ffmpeg") is None:
            sys.exit("ffmpeg가 필요합니다(loudness 정규화). 설치하거나 "
                     "--skip-loudnorm을 쓰세요.")
        _loudnorm_2pass(args.out)
        print("[loudnorm] -16 LUFS 정규화 완료", file=sys.stderr)
    else:
        print("[loudnorm] --skip-loudnorm: 정규화 건너뜀", file=sys.stderr)
    id3 = _id3_count(args.out)
    print(f"[ID3] {id3}개 — {'OK' if id3 <= 1 else '다중'}", file=sys.stderr)
    speech_all = "\n".join(s["speech"] for s in sections if s["speech"])
    meta = build_audio_meta(
        md_path=args.script, audio_path=args.out, doc_id=script["docId"],
        speech=speech_all, chunks=[], issues=[], args=args, mode="synthesized",
        chapters=chapters_from_section_durations(sections, durations_ms))
    meta["source"] = {"asset": script.get("sourceAsset"),
                      "sha256": script.get("sourceHash")}
    meta["script"]["reviewStatus"] = script.get("reviewStatus", "needs_human_review")
    write_json(args.out.with_name("audio_meta.json"), meta)
    print(f"[완료] {args.out}", file=sys.stderr)


def gate_script(script: dict, lexicon: dict | None = None) -> tuple:
    """script.json 정적 검사. 반환 (hard, soft) 메시지 목록."""
    hard: list[str] = []
    soft: list[str] = []
    for seg in script["segments"]:
        sid = seg.get("id", "?")
        txt = (seg.get("scriptText") or "") + " " + (seg.get("audioSummary") or "")
        if re.search(r"https?://", txt):
            hard.append(f"{sid}: URL 잔존")
        for sym in ("→", "≠", "↓", "§", "|"):
            if sym in txt:
                hard.append(f"{sid}: 기호 {sym}")
        if "정답 보기" in txt:
            hard.append(f"{sid}: 정답 보기 잔존")
        if re.search(r"\]\(", txt):
            hard.append(f"{sid}: 마크다운 링크 잔존")
        if seg.get("kind") == "table" and not seg.get("skip") and not seg.get("audioSummary"):
            hard.append(f"{sid}: table에 audioSummary 또는 skip 필요")
        if seg.get("kind") == "source" and not seg.get("skip"):
            hard.append(f"{sid}: source는 skip=true 필요")
        for iss in seg.get("issues", []):
            if str(iss).startswith("unmapped-token"):
                soft.append(f"{sid}: {iss}")
        if lexicon and not seg.get("skip"):                  # ④ 원문 토큰 보존
            target = (seg.get("audioSummary") if seg.get("kind") == "table"
                      else seg.get("scriptText")) or ""
            source = seg.get("sourceExcerpt") or ""
            if source and target:
                th, ts = check_token_preservation(source, target, lexicon)
                hard += [f"{sid}: {m}" for m in th]
                soft += [f"{sid}: {m}" for m in ts]
    return hard, soft


def gate_audio_meta(meta: dict, current_md_sha) -> list:
    """audio_meta.json 검사(hard만)."""
    hard: list[str] = []
    audio = meta.get("audio", {})
    checks = audio.get("containerChecks", {})
    if audio.get("contentType") != "audio/mpeg":
        hard.append(f"contentType={audio.get('contentType')} (audio/mpeg 필요)")
    if checks.get("id3Count") != 1:
        hard.append(f"id3Count={checks.get('id3Count')} (1 필요)")
    if current_md_sha and meta.get("source", {}).get("sha256") != current_md_sha:
        hard.append("stale: source.sha256 != 현재 md")
    return hard


def run_gate(args) -> None:
    script = json.loads(args.script.read_text(encoding="utf-8"))
    lex = load_lexicon(args.lexicon)
    if not lex:
        print("  (lexicon 없음 — 토큰 보존 검사 skip)", file=sys.stderr)
    hard, soft = gate_script(script, lex)
    cur_sha = None
    if args.md and args.md.exists():
        cur_sha = hashlib.sha256(
            args.md.read_text(encoding="utf-8").encode("utf-8")).hexdigest()
        if script.get("sourceHash") != cur_sha:
            hard.append("stale: script.sourceHash != 현재 md")
    if args.audio_meta and args.audio_meta.exists():
        meta = json.loads(args.audio_meta.read_text(encoding="utf-8"))
        hard += gate_audio_meta(meta, cur_sha)
    for h in hard:
        print(f"  HARD {h}", file=sys.stderr)
    for s in soft:
        print(f"  soft {s}", file=sys.stderr)
    if hard:
        sys.exit(f"[gate] FAIL — hard {len(hard)}개")
    print(f"[gate] PASS (soft {len(soft)}개)", file=sys.stderr)


def run_chapters(args) -> None:
    script = json.loads(args.script.read_text(encoding="utf-8"))
    meta = json.loads(args.audio_meta.read_text(encoding="utf-8"))
    meta["chapters"] = chapters_from_segments(script["segments"])
    write_json(args.audio_meta, meta)
    print(f"[chapters] {len(meta['chapters'])}개 → {args.audio_meta}",
          file=sys.stderr)


def run_descaffold(args) -> None:
    script = json.loads(args.script.read_text(encoding="utf-8"))
    marked = mark_scaffolding(script["segments"])
    if marked:
        script["reviewStatus"] = "needs_human_review"  # 내용 변경 → 재검수 필요
    write_json(args.script, script)
    print(f"[descaffold] {marked}개 세그먼트 skip 표시 → {args.script}",
          file=sys.stderr)


def run_connectors(args) -> None:
    script = json.loads(args.script.read_text(encoding="utf-8"))
    segs = script["segments"]
    title = next((s.get("scriptText", "") for s in segs
                  if s.get("kind") == "heading"), "")
    added = insert_connectors(segs, title)
    if added:
        script["reviewStatus"] = "needs_human_review"
    write_json(args.script, script)
    print(f"[connectors] {added}개 연결문 삽입 → {args.script}", file=sys.stderr)


def quality_issues(text: str) -> list[str]:
    """정제 후에도 남은 음성 부적합 요소 검출(dry-run 품질 게이트). 빈 리스트면 통과."""
    issues: list[str] = []
    if re.search(r"https?://", text):
        issues.append("URL 잔존")
    for sym in ("→", "≠", "↓", "↑", "§", "|", "="):
        if sym in text:
            issues.append(f"기호 잔존: {sym}")
    if "정답 보기" in text:
        issues.append("정답 보기 잔존")
    if ".questions.json" in text:
        issues.append("questions.json 경로 잔존")
    if re.search(r"\]\(", text):
        issues.append("마크다운 링크 잔존")
    if re.search(r"(?:^|[\s])[.,]\s*[.,]|^\s*[.,]\s*$", text, re.M):
        issues.append("고아 문장부호")
    return issues


def chunk_text(text: str, max_chars: int) -> list[str]:
    """긴 텍스트를 문장 경계로 청크 분할(엔진 요청 한도/안정성 회피)."""
    sentences = re.split(r"(?<=[.!?。])\s+|\n+", text)
    chunks: list[str] = []
    cur = ""
    for sent in sentences:
        sent = sent.strip()
        if not sent:
            continue
        if cur and len(cur) + len(sent) + 1 > max_chars:
            chunks.append(cur)
            cur = sent
        else:
            cur = f"{cur} {sent}".strip()
    if cur:
        chunks.append(cur)
    return chunks


def _utc_now() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="seconds").replace(
        "+00:00", "Z")


def _sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def _asset_path(path: Path) -> str:
    """앱 asset 경로처럼 보이면 assets/... 형태로 축약한다."""
    parts = path.as_posix().split("/")
    if "assets" in parts:
        return "/".join(parts[parts.index("assets"):])
    return path.as_posix()


def _id3_count(path: Path) -> int:
    if path.suffix.lower() != ".mp3":
        return 0
    data = path.read_bytes()
    count = 0
    start = 0
    while True:
        idx = data.find(b"ID3", start)
        if idx < 0:
            return count
        if _is_id3v2_header(data[idx:idx + 10]):
            count += 1
        start = idx + 1


def _is_id3v2_header(header: bytes) -> bool:
    """Return true for real ID3v2 headers, not incidental audio bytes."""
    if len(header) < 10 or header[:3] != b"ID3":
        return False
    major, revision, flags = header[3], header[4], header[5]
    if major not in (2, 3, 4) or revision == 0xFF:
        return False
    if flags & 0x0F:
        return False
    return all(byte < 0x80 for byte in header[6:10])


def _parse_loudnorm_json(stderr_text: str) -> dict:
    """ffmpeg loudnorm pass1 stderr에서 측정 JSON 블록을 파싱한다.

    ffmpeg는 `-af loudnorm=...:print_format=json`을 쓰면 stderr 끝에
    {"input_i": "...", "input_tp": "...", "input_lra": "...",
     "input_thresh": "...", "target_offset": "..."} 블록을 출력한다.
    로그가 앞뒤로 섞이므로 마지막 중괄호 쌍을 잘라 json.loads 한다.
    """
    start = stderr_text.rfind("{")
    end = stderr_text.rfind("}")
    if start < 0 or end < 0 or end < start:
        raise ValueError("loudnorm JSON 블록을 찾지 못했습니다")
    return json.loads(stderr_text[start:end + 1])


def _audio_duration_ms(path: Path) -> int:
    """ffprobe로 오디오 길이(ms). ffprobe 없으면 종료."""
    import shutil
    import subprocess
    if shutil.which("ffprobe") is None:
        raise RuntimeError("ffprobe를 찾을 수 없습니다(섹션 길이 측정 필요).")
    out = subprocess.run(
        ["ffprobe", "-v", "error", "-show_entries", "format=duration",
         "-of", "default=noprint_wrappers=1:nokey=1", str(path)],
        capture_output=True, text=True, check=True).stdout.strip()
    return round(float(out) * 1000)


def _loudnorm_2pass(path: Path, target_i: float = -16.0,
                    tp: float = -1.5, lra: float = 11.0,
                    ar: int = 24000, br: str = "48k") -> None:
    """ffmpeg loudnorm 2-pass로 mp3를 in-place 정규화(EBU R128).
    ar/br로 출력 샘플레이트·비트레이트를 원본(Polly neural 24kHz/48k)에 맞춘다
    — loudnorm 필터는 기본 48kHz로 업샘플해 음성 mp3를 불필요하게 키운다."""
    import shutil
    import subprocess

    if shutil.which("ffmpeg") is None:
        raise RuntimeError("ffmpeg를 찾을 수 없습니다(loudnorm 필요).")
    base = f"loudnorm=I={target_i}:TP={tp}:LRA={lra}"
    p1 = subprocess.run(
        ["ffmpeg", "-hide_banner", "-i", str(path),
         "-af", base + ":print_format=json", "-f", "null", "-"],
        capture_output=True, text=True)
    if p1.returncode != 0:
        raise RuntimeError(
            f"ffmpeg loudnorm pass1 실패(rc={p1.returncode}):\n{p1.stderr[-1000:]}")
    m = _parse_loudnorm_json(p1.stderr)
    af2 = (base
           + f":measured_I={m['input_i']}:measured_TP={m['input_tp']}"
           + f":measured_LRA={m['input_lra']}:measured_thresh={m['input_thresh']}"
           + f":offset={m['target_offset']}:linear=true:print_format=summary")
    tmp = path.with_name(path.stem + ".norm" + path.suffix)
    subprocess.run(
        ["ffmpeg", "-hide_banner", "-y", "-i", str(path), "-af", af2,
         "-ar", str(ar), "-b:a", br, str(tmp)],
        capture_output=True, text=True, check=True)
    tmp.replace(path)


def _segment_speech(seg: dict) -> str:
    """세그먼트의 발음 텍스트(table=audioSummary, 그 외 scriptText)."""
    if seg.get("skip"):
        return ""
    text = (seg.get("audioSummary") if seg.get("kind") == "table"
            else seg.get("scriptText")) or ""
    return text.strip()


def chapters_from_segments(segments: list[dict]) -> list[dict]:
    """헤딩별 오디오 위치 추정 — 직전까지 누적 발음 글자수 ÷ 총 발음 글자수(fraction).
    글자수는 공백 제외(len(speech.replace(' ', ''))). 앵커 없는 헤딩은 제외.
    반환 [{anchor,title,level,fraction}](선언 순서)."""
    def _char_count(speech: str) -> int:
        return len(speech.replace(" ", ""))

    total = sum(_char_count(_segment_speech(s)) for s in segments)
    chapters: list[dict] = []
    acc = 0
    for seg in segments:
        speech = _segment_speech(seg)
        if seg.get("kind") == "heading" and speech:
            src = seg.get("sourceExcerpt") or ""
            m = re.search(r"\{#([^}]+)\}", src)
            hm = re.match(r"\s*(#{1,6})", src)
            if m and hm:
                chapters.append({
                    "anchor": m.group(1),
                    "title": speech,
                    "level": len(hm.group(1)),
                    "fraction": (acc / total) if total else 0.0,
                })
        acc += _char_count(speech)
    return chapters


_SCAFFOLD_META_PREFIX = "커버하는 공식 Task"
_SCAFFOLD_CHECKLIST = "학습 목표 체크리스트"


def mark_scaffolding(segments: list[dict]) -> int:
    """오디오 스캐폴딩 세그먼트에 skip=True 표시(낭독 제외). 반환: 새로 표시한 수.

    규칙(CLF 학습문서 템플릿, 19문서 실스캔 근거):
      1) 문서-상단 메타 문단: kind=='paragraph' 이고 scriptText가
         '커버하는 공식 Task'로 시작(도메인·퍼센트·문서ID·1:1 매핑 포함).
      2) 학습목표 체크리스트 블록: sourceExcerpt에 '학습 목표 체크리스트'를 가진
         heading + 그 다음 heading 전까지의 모든 세그먼트.
    이미 skip=True면 건너뜀(멱등)."""
    marked = 0
    i = 0
    n = len(segments)
    while i < n:
        s = segments[i]
        if (s.get("kind") == "paragraph"
                and (s.get("scriptText") or "").startswith(_SCAFFOLD_META_PREFIX)):
            if not s.get("skip"):
                s["skip"] = True
                marked += 1
            i += 1
            continue
        if (s.get("kind") == "heading"
                and _SCAFFOLD_CHECKLIST in (s.get("sourceExcerpt") or "")):
            if not s.get("skip"):
                s["skip"] = True
                marked += 1
            j = i + 1
            while j < n and segments[j].get("kind") != "heading":
                if not segments[j].get("skip"):
                    segments[j]["skip"] = True
                    marked += 1
                j += 1
            i = j
            continue
        i += 1
    return marked


def _has_batchim(word: str) -> bool:
    """마지막 글자가 Hangul 음절이고 받침이 있으면 True. 비-Hangul/빈 문자열은 False."""
    if not word:
        return False
    ch = word[-1]
    if not ("가" <= ch <= "힣"):
        return False
    return (ord(ch) - 0xAC00) % 28 != 0


def _josa_eul(word: str) -> str:
    """목적격 조사 을/를."""
    return "을" if _has_batchim(word) else "를"


def _josa_ro(word: str) -> str:
    """부사격 조사 으로/로(받침 없거나 ㄹ받침이면 '로')."""
    if not word:
        return "로"
    ch = word[-1]
    if not ("가" <= ch <= "힣"):
        return "로"
    jong = (ord(ch) - 0xAC00) % 28
    return "로" if jong in (0, 8) else "으로"


_ANCHOR_RE = re.compile(r"\{#[^}]+\}")


def _intro_text(title: str, idx: int) -> str:
    eul = _josa_eul(title)
    return [
        f"이번 강의에서는 {title}{eul} 다룹니다.",
        f"{title}, 지금부터 함께 살펴보겠습니다.",
        f"이번 시간에는 {title}{eul} 짚어 보겠습니다.",
    ][idx % 3]


def _transition_text(sec: str, idx: int) -> str:
    eul = _josa_eul(sec)
    ro = _josa_ro(sec)
    return [
        f"다음으로 {sec}{eul} 살펴보겠습니다.",
        f"이어서 {sec}{ro} 넘어가겠습니다.",
        f"이번에는 {sec}입니다.",
        f"계속해서 {sec}{eul} 보겠습니다.",
    ][idx % 4]


def _outro_text(idx: int) -> str:
    return [
        "여기까지가 이 주제의 핵심입니다.",
        "이상으로 이번 강의를 마칩니다.",
        "핵심은 여기까지입니다. 수고하셨습니다.",
    ][idx % 3]


def _clean_section_title(title: str) -> str:
    """헤딩 원문에서 음성용 섹션 제목 추출: 선행 번호(N)) 제거,
    첫 em-dash(—) 앞까지, 괄호 부연 제거, 중점(·)→쉼표."""
    t = re.sub(r"^\s*\d+\)\s*", "", title)
    t = re.split(r"\s*—\s*", t, maxsplit=1)[0]
    t = re.sub(r"\s*\([^)]*\)", "", t)
    t = re.sub(r"\s*·\s*", ", ", t)
    t = t.strip().strip(",").strip()
    return t or re.sub(r"^\s*\d+\)\s*", "", title).strip()


def _mk_connector(n: int, text: str) -> dict:
    return {"id": f"con{n:03d}", "kind": "connector", "sourceExcerpt": "",
            "scriptText": text, "audioSummary": None, "skip": False, "issues": []}


def insert_connectors(segments: list[dict], title: str) -> int:
    """강의 연결 멘트(도입1 + 앵커 섹션 전환N + 마무리1)를 결정적 회전 템플릿으로
    삽입한다. 삽입 세그먼트는 kind='connector', sourceExcerpt='' (gate 토큰검사 스킵),
    순수 네비게이션 평문. 반환: 삽입 수. 멱등(이미 connector 있으면 0)."""
    if any(s.get("kind") == "connector" for s in segments):
        return 0

    def _speaks(s: dict) -> bool:
        return (not s.get("skip")) and bool(s.get("scriptText") or s.get("audioSummary"))

    speak_idx = [i for i, s in enumerate(segments) if _speaks(s)]
    if not speak_idx:
        return 0
    first_i, last_i = speak_idx[0], speak_idx[-1]
    rot = len(title)  # 도입·마무리 회전 키(문서별 결정적)
    out: list[dict] = []
    cnt = 0
    anchor_n = 0
    for i, s in enumerate(segments):
        if (s.get("kind") == "heading" and not s.get("skip")
                and _ANCHOR_RE.search(s.get("sourceExcerpt") or "")):
            out.append(_mk_connector(cnt, _transition_text(_clean_section_title(s.get("scriptText") or ""), anchor_n)))
            cnt += 1
            anchor_n += 1
        out.append(s)
        if i == first_i:
            out.append(_mk_connector(cnt, _intro_text(title, rot)))
            cnt += 1
        if i == last_i:
            out.append(_mk_connector(cnt, _outro_text(rot)))
            cnt += 1
    segments[:] = out
    return cnt


def split_sections(segments: list[dict]) -> list[dict]:
    """비-skip 세그먼트를 앵커 있는 heading 경계로 섹션 분할.
    section = {anchor, title, level, speech}. intro(첫 앵커 헤딩 전)는 anchor=None.
    앵커 없는 헤딩은 경계가 아니라 현재 섹션 본문에 포함.
    불변식: '\\n'.join(빈 아닌 섹션 speech) == script_to_speech."""
    sections: list[dict] = []
    cur = {"anchor": None, "title": None, "level": None, "parts": []}
    for seg in segments:
        speech = _segment_speech(seg)
        if seg.get("kind") == "heading" and speech:
            src = seg.get("sourceExcerpt") or ""
            m = re.search(r"\{#([^}]+)\}", src)
            hm = re.match(r"\s*(#{1,6})", src)
            if m and hm:
                sections.append(cur)
                cur = {"anchor": m.group(1), "title": speech,
                       "level": len(hm.group(1)), "parts": [speech]}
                continue
        if speech:
            cur["parts"].append(speech)
    sections.append(cur)
    for sec in sections:
        sec["speech"] = "\n".join(sec.pop("parts"))
    return sections


def chapters_from_section_durations(sections: list[dict],
                                    durations_ms: list[int]) -> list[dict]:
    """섹션별 실측 길이 → 앵커 있는 섹션마다 {anchor,title,level,fraction}.
    fraction = 누적 시작 ms ÷ Σ길이(total 0이면 0.0)."""
    total = sum(durations_ms)
    chapters: list[dict] = []
    acc = 0
    for sec, dur in zip(sections, durations_ms):
        if sec.get("anchor"):
            chapters.append({
                "anchor": sec["anchor"],
                "title": sec["title"],
                "level": sec["level"],
                "fraction": (acc / total) if total else 0.0,
            })
        acc += dur
    return chapters


def _content_type(path: Path) -> str:
    return {
        ".mp3": "audio/mpeg",
        ".wav": "audio/wav",
    }.get(path.suffix.lower(), "application/octet-stream")


def build_audio_meta(
    *,
    md_path: Path,
    audio_path: Path,
    doc_id: str,
    speech: str,
    chunks: list[str],
    issues: list[str],
    args: argparse.Namespace,
    mode: str,
    chapters: list | None = None,
) -> dict:
    """M1 T9: 오디오 옆에 남기는 최소 {docId, sourceHash} 메타."""
    id3_count = _id3_count(audio_path)
    unique_issues = list(dict.fromkeys(issues))
    return {
        "schemaVersion": 1,
        "docId": doc_id,
        "generatedAt": _utc_now(),
        "mode": mode,
        "reviewStatus": "needs_human_review",
        "source": {
            "asset": _asset_path(md_path),
            "sha256": _sha256_file(md_path),
        },
        "audio": {
            "src": _asset_path(audio_path),
            "file": audio_path.name,
            "sizeBytes": audio_path.stat().st_size,
            "sha256": _sha256_file(audio_path),
            "contentType": _content_type(audio_path),
            "containerChecks": {
                "id3Count": id3_count,
                "midFileId3Allowed": False,
                "ok": audio_path.suffix.lower() != ".mp3" or id3_count <= 1,
            },
        },
        "loudness": {
            "targetLufs": -16,
            "normalized": not getattr(args, "skip_loudnorm", False),
        },
        "script": {
            "speechChars": len(speech),
            "chunkCount": len(chunks),
            "qualityIssues": unique_issues,
            "reviewStatus": "needs_human_review",
        },
        "chapters": chapters or [],
        "generator": {
            "tool": "flutter_app/tool/gen_lecture_audio.py",
            "engine": args.engine,
            "voice": args.voice if args.engine == "polly" else None,
            "pollyEngine": args.polly_engine if args.engine == "polly" else None,
            "region": args.region if args.engine == "polly" else None,
            "maxChars": args.max_chars,
        },
    }


def write_json(path: Path, data: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        json.dumps(data, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def _strip_id3v2(data: bytes) -> bytes:
    """선행 ID3v2 태그 제거(없으면 그대로). size는 synchsafe(7비트×4).
    청크 mp3 연결 시 첫 청크 외 ID3를 떼어 파일에 ID3 1개만 남긴다(P0-1)."""
    if len(data) >= 10 and data[:3] == b"ID3":
        size = (data[6] << 21) | (data[7] << 14) | (data[8] << 7) | data[9]
        return data[10 + size:]
    return data


def _synthesize_chunks_to_bytes(chunks, voice: str, engine: str,
                                region: str) -> bytes:
    """청크별 Polly mp3 → 1개 bytes(첫 청크 외 ID3v2 strip)."""
    import boto3
    polly = boto3.client("polly", region_name=region)
    buf = bytearray()
    for i, chunk in enumerate(chunks):
        resp = polly.synthesize_speech(
            Text=chunk, OutputFormat="mp3",
            VoiceId=voice, Engine=engine, LanguageCode="ko-KR",
        )
        data = resp["AudioStream"].read()
        buf += data if i == 0 else _strip_id3v2(data)
        print(f"  Polly {i + 1}/{len(chunks)}", file=sys.stderr)
    return bytes(buf)


def synthesize_polly(chunks, out_path: Path, voice: str, engine: str,
                     region: str) -> None:
    """Amazon Polly로 청크별 mp3 합성 → 1개 파일(ffmpeg 불필요). neural은 요청당
    3000자 한도라 여러 청크가 될 수 있어, 첫 청크 외 ID3v2를 떼어 ID3를 1개로 유지(P0-1)."""
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_bytes(_synthesize_chunks_to_bytes(chunks, voice, engine, region))


def synthesize_melotts(chunks, out_path: Path, speed: float, device: str) -> None:
    """MeloTTS-Korean으로 청크별 합성 → 이어붙여 1개 파일. .mp3면 ffmpeg 변환."""
    import subprocess
    import tempfile

    from melo.api import TTS
    import numpy as np
    import soundfile as sf

    model = TTS(language="KR", device=device)
    speaker_id = model.hps.data.spk2id["KR"]
    sr = model.hps.data.sampling_rate

    with tempfile.TemporaryDirectory() as td:
        segments: list = []
        for i, chunk in enumerate(chunks):
            wav_path = Path(td) / f"{i:04d}.wav"
            model.tts_to_file(chunk, speaker_id, str(wav_path), speed=speed)
            audio, _ = sf.read(str(wav_path))
            segments.append(audio)
            segments.append(np.zeros(int(sr * 0.3)))
            print(f"  합성 {i + 1}/{len(chunks)}", file=sys.stderr)
        merged = np.concatenate(segments)
        out_path.parent.mkdir(parents=True, exist_ok=True)
        if out_path.suffix.lower() == ".mp3":
            merged_wav = Path(td) / "merged.wav"
            sf.write(str(merged_wav), merged, sr)
            subprocess.run(
                ["ffmpeg", "-y", "-i", str(merged_wav),
                 "-codec:a", "libmp3lame", "-b:a", "128k", str(out_path)],
                check=True)
        else:
            sf.write(str(out_path), merged, sr)


def _self_test() -> None:
    """정제·게이트·청크 로직 검증(엔진 불필요)."""
    md = (
        "---\nname: x\n---\n"
        "# 제목입니다 {#intro}\n\n"
        "본문 문장입니다.\n\n"
        "```dart\nvoid main() {}\n```\n\n"
        "| 열A | 열B |\n| --- | --- |\n\n"
        "- 목록 [링크](https://x)\n"
        "**강조** 텍스트입니다.\n\n"
        "고정비 → 변동비 전환.\n"
        "클라우드 = 온디맨드 + 종량.\n"
        "비용이 단가↓ 됩니다.\n"
        "탄력성(≠ 고가용성) 구분.\n"
        "식별자 ko_kr 보존.\n"
        "## 🧪 자가 점검\n\n"
        "**Q1.** 질문입니까?\n\n"
        "<details><summary>정답 보기</summary>\n\n"
        "비밀 정답입니다.\n</details>\n\n"
        "### 📌 출처 (verified)\n\n"
        "1. 자료 — https://aws.amazon.com/x/\n"
    )
    out = markdown_to_speech_text(md)
    # 기본 정제
    assert "제목입니다" in out, out
    assert "본문 문장입니다." in out, out
    assert "void main" not in out, f"코드: {out}"
    assert "열A" not in out, f"표: {out}"
    assert "목록 링크" in out, f"링크: {out}"
    assert "강조 텍스트입니다." in out and "*" not in out, f"강조: {out}"
    # P0-3: 출처·URL 제외, snake_case _ 보존
    assert "http" not in out and "aws.amazon" not in out, f"URL 누출: {out}"
    assert "출처" not in out, f"출처 섹션 누출: {out}"
    assert "ko_kr" in out, f"snake_case 보존: {out}"
    # P0-5: 자가점검·정답보기 제외
    assert "정답 보기" not in out, f"정답보기 누출: {out}"
    assert "비밀 정답" not in out, f"정답 내용 누출: {out}"
    assert "질문입니까" not in out, f"자가점검 누출: {out}"
    # P0-2: 기호 변환(잔존 0)
    for sym in ("→", "=", "↓", "≠", "+", "§"):
        assert sym not in out, f"기호 잔존 {sym}: {out}"
    assert "감소" in out, f"↓→감소: {out}"
    # 품질 게이트
    assert quality_issues(out) == [], f"정제 결과 게이트 이슈: {quality_issues(out)}"
    assert any("URL" in i for i in quality_issues("자료 https://x.com 보기")), "URL 미검출"
    assert any("→" in i for i in quality_issues("A → B")), "화살표 미검출"
    assert any("정답 보기" in i for i in quality_issues("정답 보기 여기")), "정답보기 미검출"
    assert any("|" in i for i in quality_issues("| 표 행 |")), "표 미검출"
    # 청크
    chunks = chunk_text("가나다라. 마바사아. 자차카타.", max_chars=10)
    assert len(chunks) >= 2, f"청크: {chunks}"
    # ID3v2 스트립(청크 연결 시 ID3 1개 유지, P0-1)
    framed = b"\xff\xfbAUDIO"
    tagged = b"ID3" + bytes([3, 0, 0, 0, 0, 0, 5]) + b"XXXXX" + framed
    assert _strip_id3v2(tagged) == framed, "ID3 제거 실패"
    assert _strip_id3v2(framed) == framed, "ID3 없을 때 보존 실패"
    # T9 메타 sidecar
    with tempfile.TemporaryDirectory() as td:
        root = Path(td)
        md_path = root / "assets" / "content" / "clf" / "t1-1.md"
        audio_path = root / "assets" / "audio" / "clf" / "clf-t1-1" / "lecture.mp3"
        md_path.parent.mkdir(parents=True)
        audio_path.parent.mkdir(parents=True)
        md_path.write_text("# 테스트\n\n본문입니다.\n", encoding="utf-8")
        audio_path.write_bytes(tagged + b"\xff\xfbID3")
        assert _id3_count(audio_path) == 1, "가짜 ID3 바이트 오검출"
        fake_args = argparse.Namespace(
            engine="polly",
            voice="Seoyeon",
            polly_engine="neural",
            region="ap-northeast-2",
            max_chars=0,
        )
        meta = build_audio_meta(
            md_path=md_path,
            audio_path=audio_path,
            doc_id="clf-t1-1",
            speech="테스트",
            chunks=["테스트"],
            issues=["URL 잔존", "URL 잔존"],
            args=fake_args,
            mode="self-test",
        )
        assert meta["docId"] == "clf-t1-1", meta
        assert meta["source"]["asset"] == "assets/content/clf/t1-1.md", meta
        assert len(meta["source"]["sha256"]) == 64, meta
        assert meta["audio"]["src"] == "assets/audio/clf/clf-t1-1/lecture.mp3", meta
        assert meta["audio"]["containerChecks"]["id3Count"] == 1, meta
        assert meta["audio"]["containerChecks"]["ok"] is True, meta
        assert meta["script"]["qualityIssues"] == ["URL 잔존"], meta

    # Task 1: segment 파서
    seg_md = (
        "---\nname: x\n---\n"
        "# 제목입니다 {#intro}\n\n"
        "첫 문단입니다. 둘째 문장.\n\n"
        "- 목록 [링크](https://x) 항목\n\n"
        "| 열A | 열B |\n| --- | --- |\n| 가 | 나 |\n\n"
        "## 🧪 자가 점검\n\n"
        "**Q1.** 질문입니까?\n\n"
        "<details><summary>정답 보기</summary>\n비밀.\n</details>\n\n"
        "### 📌 출처\n\n1. 자료 https://aws.amazon.com/x/\n"
    )
    segs = parse_segments(seg_md)
    kinds = [g["kind"] for g in segs]
    assert kinds[0] == "heading" and segs[0]["scriptText"] == "제목입니다", segs[0]
    assert any(g["kind"] == "paragraph" and "첫 문단입니다" in g["scriptText"] for g in segs), segs
    assert any(g["kind"] == "paragraph" and "목록 링크 항목" in g["scriptText"] for g in segs), segs
    tbl = [g for g in segs if g["kind"] == "table"]
    assert len(tbl) == 1 and tbl[0]["skip"] is False and tbl[0]["audioSummary"] == "가은 나입니다.", tbl
    assert "| 열A" in tbl[0]["sourceExcerpt"], tbl[0]
    sc = [g for g in segs if g["kind"] == "selfcheck"]
    assert sc and all(g["skip"] for g in sc), sc
    assert all("질문입니까" not in g["scriptText"] for g in segs), "selfcheck 본문 누출"
    src = [g for g in segs if g["kind"] == "source"]
    assert src and all(g["skip"] for g in src), src
    assert all("aws.amazon" not in g["scriptText"] for g in segs), "URL 누출"
    assert all(g["id"] == f"seg{n:03d}" for n, g in enumerate(segs)), [g["id"] for g in segs]

    # Task 2: 발음사전
    lex = {
        "AWS": {"say": "에이더블유에스"},
        "AZ": {"firstSay": "가용 영역", "thenSay": "에이제트"},
    }
    seen: set[str] = set()
    t1, i1 = apply_lexicon("AWS는 좋다", lex, seen)
    assert t1 == "에이더블유에스는 좋다", t1
    t2, _ = apply_lexicon("AZ 하나, AZ 둘", lex, seen)
    assert t2 == "가용 영역 하나, 에이제트 둘", t2          # 첫 등장/이후
    _, i3 = apply_lexicon("EC2 인스턴스", lex, seen)
    assert any("EC2" in x for x in i3), i3                   # 미등록 토큰 경고
    t4, _ = apply_lexicon("AWSomeness", lex, set())
    assert t4 == "AWSomeness", t4                            # 단어 경계(부분 매칭 금지)
    t5, _ = apply_lexicon("온디맨드(on-demand) 방식", {"on-demand": {"say": "온디맨드"}}, set())
    assert t5 == "온디맨드 방식", t5  # 발음 치환 중복 괄호 제거
    t6, _ = apply_lexicon("가용 영역(AZ)", {"AZ": {"firstSay": "가용 영역", "thenSay": "에이제트"}}, set())
    assert t6 == "가용 영역", t6  # 공백 포함 중복 괄호 제거
    loaded = load_lexicon(None)
    assert "AWS" in loaded and loaded["AWS"]["say"], loaded   # 시드 로드
    assert "ERP" in loaded and loaded["ERP"]["say"] == "이아르피", loaded  # ERP 영구 추가

    # Task 3: 표 audioSummary
    s2, is2 = table_to_summary(["| 용어 | 설명 |", "| --- | --- |", "| 온프레미스 | 직접 운영 |"])
    assert s2 == "온프레미스은 직접 운영입니다." and is2 == ["table-summary-draft"], (s2, is2)
    s3, is3 = table_to_summary(["| A | B | C |", "| - | - | - |", "| 1 | 2 | 3 |"])
    assert s3 is None and is3 == ["table-needs-summary"], (s3, is3)
    segs2 = parse_segments("| 용어 | 설명 |\n| --- | --- |\n| 가 | 나 |\n")
    t = [g for g in segs2 if g["kind"] == "table"][0]
    assert t["audioSummary"] == "가은 나입니다." and t["issues"] == ["table-summary-draft"], t

    # Task 4: build_script_json
    sj = build_script_json("# 제목\n\n본문입니다.\n", doc_id="clf-t1-1",
                           source_asset="assets/content/clf/t1-1.md", lexicon={})
    assert sj["schemaVersion"] == 2 and sj["docId"] == "clf-t1-1", sj
    assert sj["reviewStatus"] == "needs_human_review", sj
    assert len(sj["sourceHash"]) == 64 and len(sj["segments"]) >= 2, sj
    assert sj["segments"][0]["kind"] == "heading", sj["segments"][0]
    # 발음사전 적용이 scriptText에 반영
    sj2 = build_script_json("본문 AWS 설명.\n", doc_id="d",
                            source_asset="a", lexicon={"AWS": {"say": "에이더블유에스"}})
    assert any("에이더블유에스" in s["scriptText"] for s in sj2["segments"]), sj2
    # run_generate가 파일 2개 생성
    with tempfile.TemporaryDirectory() as td:
        root = Path(td)
        md_p = root / "t1-1.md"; md_p.write_text("# 제목\n\n본문.\n", encoding="utf-8")
        out_d = root / "clf-t1-1"
        gen_args = argparse.Namespace(md=md_p, out_dir=out_d, doc_id="clf-t1-1", lexicon=None)
        run_generate(gen_args)
        assert (out_d / "script.json").exists(), "script.json 미생성"
        assert (out_d / "review_checklist.md").exists(), "검수표 미생성"
        loaded = json.loads((out_d / "script.json").read_text(encoding="utf-8"))
        assert loaded["reviewStatus"] == "needs_human_review", loaded

    # Task 5: script_to_speech (skip 제외, table=audioSummary, md 무시)
    sp = script_to_speech({"segments": [
        {"kind": "heading", "scriptText": "제목", "skip": False, "audioSummary": None},
        {"kind": "selfcheck", "scriptText": "비밀", "skip": True, "audioSummary": None},
        {"kind": "table", "scriptText": "", "audioSummary": "요약입니다.", "skip": False},
        {"kind": "source", "scriptText": "url", "skip": True, "audioSummary": None},
    ]})
    assert "제목" in sp and "요약입니다." in sp, sp
    assert "비밀" not in sp and "url" not in sp, sp
    assert sp.count("\n") == 1, sp

    # Task 6: 정적 게이트
    hard, soft = gate_script({"segments": [
        {"id": "s0", "kind": "paragraph", "scriptText": "정상 문장.", "skip": False, "issues": []},
        {"id": "s1", "kind": "paragraph", "scriptText": "보기 https://x", "skip": False, "issues": []},
        {"id": "s2", "kind": "table", "scriptText": "", "audioSummary": None, "skip": False, "issues": []},
        {"id": "s3", "kind": "source", "scriptText": "x", "skip": False, "issues": []},
        {"id": "s4", "kind": "paragraph", "scriptText": "토큰", "skip": False,
         "issues": ["unmapped-token: EC2"]},
    ]})
    assert any("URL" in x for x in hard) and any("table" in x for x in hard), hard
    assert any("source" in x for x in hard), hard
    assert any("EC2" in x for x in soft) and not any("EC2" in x for x in hard), (hard, soft)
    ok_meta = {"audio": {"contentType": "audio/mpeg",
                         "containerChecks": {"id3Count": 1}}, "source": {"sha256": "abc"}}
    assert gate_audio_meta(ok_meta, "abc") == [], gate_audio_meta(ok_meta, "abc")
    assert any("stale" in x for x in gate_audio_meta(ok_meta, "zzz")), "stale 미검출"
    bad_meta = {"audio": {"contentType": "text/plain",
                          "containerChecks": {"id3Count": 3}}, "source": {"sha256": "abc"}}
    assert len(gate_audio_meta(bad_meta, None)) == 2, gate_audio_meta(bad_meta, None)

    # ④ gate 통합: lexicon 전달 시 seg별 토큰 보존 검사
    g_lex = {"EC2": {"say": "이씨투"}}
    hard_g, _soft_g = gate_script({"segments": [
        {"id": "s0", "kind": "paragraph", "sourceExcerpt": "EC2 설명",
         "scriptText": "설명만 있다", "audioSummary": None, "skip": False, "issues": []},
    ]}, g_lex)
    assert any("s0" in x and "EC2" in x for x in hard_g), hard_g     # 약어 누락 hard
    # table seg는 audioSummary를 대본으로 검사
    hard_t, _ = gate_script({"segments": [
        {"id": "s1", "kind": "table", "sourceExcerpt": "EC2 표",
         "scriptText": "", "audioSummary": "이씨투 표입니다.", "skip": False, "issues": []},
    ]}, g_lex)
    assert not any("EC2" in x for x in hard_t), hard_t               # audioSummary에 보존 → 통과
    # lexicon 없으면(None) 토큰 검사 skip(기존 호출 호환)
    hard_n, _ = gate_script({"segments": [
        {"id": "s0", "kind": "paragraph", "sourceExcerpt": "EC2 설명",
         "scriptText": "설명만 있다", "audioSummary": None, "skip": False, "issues": []},
    ]})
    assert not any("EC2" in x for x in hard_n), hard_n
    # skip seg는 토큰 검사 제외
    hard_s, _ = gate_script({"segments": [
        {"id": "s9", "kind": "source", "sourceExcerpt": "EC2", "scriptText": "x",
         "audioSummary": None, "skip": True, "issues": []},
    ]}, g_lex)
    assert not any("EC2" in x for x in hard_s), hard_s
    print("[self-test] gate 토큰 통합 OK", file=sys.stderr)

    # ④ 환각 가드: check_token_preservation(순수)
    lex_g = {"EC2": {"say": "이씨투"},
             "AZ": {"firstSay": "가용 영역", "thenSay": "에이제트"}}
    h, s = check_token_preservation("EC2는 11% 빠르다", "이씨투는 11% 빠르다", lex_g)
    assert h == [] and s == [], (h, s)                       # 약어·수치 보존
    h, s = check_token_preservation("EC2 인스턴스", "인스턴스만 있다", lex_g)
    assert any("EC2" in x for x in h) and s == [], (h, s)    # 약어 누락=hard
    h, s = check_token_preservation("가용량 99% 보장", "가용량 보장", lex_g)
    assert h == [] and any("99%" in x for x in s), (h, s)    # 수치 누락=soft
    h, s = check_token_preservation("AZ 배치", "에이제트 배치", lex_g)
    assert h == [] and s == [], (h, s)                       # firstSay/thenSay 후보 매칭
    h, s = check_token_preservation("CLF-C02 시험", "씨엘에프 씨 공이 시험",
                                    {"CLF-C02": {"say": "씨엘에프 씨 공이"}})
    assert h == [] and s == [], (h, s)                       # 약어 내부 숫자(02)는 수치 오탐 아님
    print("[self-test] check_token_preservation OK", file=sys.stderr)

    # 제목 타임스탬프 fraction 계산
    _segs = [
        {"id": "s0", "kind": "paragraph", "scriptText": "가나다라", "skip": False,
         "sourceExcerpt": "가나다라"},
        {"id": "s1", "kind": "heading", "scriptText": "첫 제목", "skip": False,
         "sourceExcerpt": "## 첫 제목 {#first}"},
        {"id": "s2", "kind": "paragraph", "scriptText": "마바사", "skip": False,
         "sourceExcerpt": "마바사"},
        {"id": "s3", "kind": "heading", "scriptText": "둘째", "skip": False,
         "sourceExcerpt": "### 둘째 {#second}"},
        {"id": "s4", "kind": "source", "scriptText": "", "skip": True,
         "sourceExcerpt": "출처"},
        {"id": "s5", "kind": "heading", "scriptText": "앵커없음", "skip": False,
         "sourceExcerpt": "## 앵커없음"},
    ]
    _ch = chapters_from_segments(_segs)
    assert [c["anchor"] for c in _ch] == ["first", "second"], _ch  # 앵커없음 제외
    assert _ch[0]["level"] == 2 and _ch[1]["level"] == 3, _ch
    assert _ch[0]["title"] == "첫 제목", _ch
    # 총 발음 글자수 = 4(가나다라)+3(첫제목)+3(마바사)+2(둘째)+4(앵커없음)=16
    # first 직전 누적=4 → 4/16=0.25; second 직전 누적=4+3+3=10 → 10/16=0.625
    assert abs(_ch[0]["fraction"] - 0.25) < 1e-9, _ch
    assert abs(_ch[1]["fraction"] - 0.625) < 1e-9, _ch
    assert chapters_from_segments([]) == [], "빈 입력"
    print("[self-test] chapters_from_segments OK", file=sys.stderr)

    # split_sections: 앵커 헤딩 경계 + intro + 불변식
    _segs2 = [
        {"id": "s0", "kind": "paragraph", "scriptText": "인트로 본문", "skip": False,
         "sourceExcerpt": "인트로 본문"},
        {"id": "s1", "kind": "heading", "scriptText": "첫 장", "skip": False,
         "sourceExcerpt": "## 첫 장 {#a}"},
        {"id": "s2", "kind": "paragraph", "scriptText": "에이 본문", "skip": False,
         "sourceExcerpt": "에이 본문"},
        {"id": "s3", "kind": "heading", "scriptText": "소제목", "skip": False,
         "sourceExcerpt": "### 소제목"},  # 앵커 없음 → 경계 아님
        {"id": "s4", "kind": "heading", "scriptText": "둘째 장", "skip": False,
         "sourceExcerpt": "## 둘째 장 {#b}"},
        {"id": "s5", "kind": "source", "scriptText": "", "skip": True,
         "sourceExcerpt": "출처"},
    ]
    _secs = split_sections(_segs2)
    assert [s["anchor"] for s in _secs] == [None, "a", "b"], _secs  # intro + 앵커 2
    assert _secs[1]["title"] == "첫 장" and _secs[1]["level"] == 2, _secs
    # 앵커 없는 "소제목"은 섹션 a에 포함(경계 아님)
    assert "소제목" in _secs[1]["speech"], _secs[1]
    # 불변식: 빈 아닌 섹션 speech 이으면 script_to_speech와 동일
    _joined = "\n".join(s["speech"] for s in _secs if s["speech"])
    assert _joined == script_to_speech({"segments": _segs2}), (_joined,)
    print("[self-test] split_sections OK", file=sys.stderr)

    # loudnorm pass1 JSON 파싱(순수)
    _ln = _parse_loudnorm_json(
        'ffmpeg noise\n[Parsed_loudnorm_0 @ 0x1] \n'
        '{\n  "input_i" : "-19.43",\n  "input_tp" : "-3.21",\n'
        '  "input_lra" : "7.40",\n  "input_thresh" : "-29.83",\n'
        '  "target_offset" : "0.50"\n}\ntrailing log\n')
    assert _ln["input_i"] == "-19.43", _ln
    assert _ln["target_offset"] == "0.50", _ln

    # loudnorm 실행 경로: ffmpeg 가용 시 짧은 톤 mp3를 정규화해 출력/ID3 확인.
    import shutil as _sh
    if _sh.which("ffmpeg"):
        import subprocess as _sp
        import tempfile as _tf
        with _tf.TemporaryDirectory() as _td:
            _tone = Path(_td) / "tone.mp3"
            _sp.run(["ffmpeg", "-hide_banner", "-y", "-f", "lavfi",
                     "-i", "sine=frequency=440:duration=1", str(_tone)],
                    capture_output=True, text=True, check=True)
            assert _audio_duration_ms(_tone) >= 900, _audio_duration_ms(_tone)  # ~1s 톤
            _loudnorm_2pass(_tone)
            assert _tone.exists() and _tone.stat().st_size > 0, "loudnorm 출력 없음"
            assert _id3_count(_tone) <= 1, "loudnorm 출력 ID3 다중"
            _sr = _sp.run(
                ["ffprobe", "-v", "error", "-select_streams", "a:0",
                 "-show_entries", "stream=sample_rate", "-of",
                 "default=noprint_wrappers=1:nokey=1", str(_tone)],
                capture_output=True, text=True).stdout.strip()
            assert _sr == "24000", f"loudnorm 출력 samplerate={_sr} (24000 기대)"
        print("[self-test] loudnorm 실행 경로 OK", file=sys.stderr)
    else:
        print("[self-test] ffmpeg 없음 — loudnorm 실행 경로 skip", file=sys.stderr)

    # build_audio_meta가 chapters를 싣는다
    import tempfile as _tf2
    with _tf2.TemporaryDirectory() as _td2:
        _md = Path(_td2) / "m.md"; _md.write_text("# 제목 {#x}\n본문", encoding="utf-8")
        _mp = Path(_td2) / "a.mp3"; _mp.write_bytes(b"\xff\xfb\x00")
        _args = argparse.Namespace(engine="polly", voice="Seoyeon",
                                   polly_engine="neural", skip_loudnorm=True,
                                   region="ap-northeast-2", max_chars=0)
        _meta = build_audio_meta(md_path=_md, audio_path=_mp, doc_id="d",
                                 speech="x", chunks=["x"], issues=[], args=_args,
                                 mode="test",
                                 chapters=[{"anchor": "x", "title": "제목",
                                            "level": 1, "fraction": 0.0}])
        assert _meta["chapters"][0]["anchor"] == "x", _meta
    print("[self-test] build_audio_meta chapters OK", file=sys.stderr)

    # chapters_from_section_durations: 누적 시작/총합
    _secs3 = [
        {"anchor": None, "title": None, "level": None, "speech": "intro"},
        {"anchor": "a", "title": "A", "level": 2, "speech": "x"},
        {"anchor": "b", "title": "B", "level": 2, "speech": "y"},
    ]
    _durs = [1000, 3000, 6000]  # total 10000; a 시작=1000→0.1; b 시작=4000→0.4
    _ch2 = chapters_from_section_durations(_secs3, _durs)
    assert [c["anchor"] for c in _ch2] == ["a", "b"], _ch2  # intro 제외
    assert abs(_ch2[0]["fraction"] - 0.1) < 1e-9, _ch2
    assert abs(_ch2[1]["fraction"] - 0.4) < 1e-9, _ch2
    assert chapters_from_section_durations(_secs3, [0, 0, 0])[0]["fraction"] == 0.0
    print("[self-test] chapters_from_section_durations OK", file=sys.stderr)

    # Stage A1: 스캐폴딩 skip 표시(순수)
    _scaf = [
        {"id": "seg000", "kind": "heading",
         "sourceExcerpt": "# 제목", "scriptText": "제목", "skip": False},
        {"id": "seg001", "kind": "paragraph",
         "sourceExcerpt": "**커버하는 공식 Task** — CLF-C02 …",
         "scriptText": "커버하는 공식 Task — 씨엘에프 씨 공이 · 도메인 1", "skip": False},
        {"id": "seg002", "kind": "heading",
         "sourceExcerpt": "## ✅ 학습 목표 체크리스트",
         "scriptText": "학습 목표 체크리스트", "skip": False},
        {"id": "seg003", "kind": "paragraph",
         "sourceExcerpt": "이 문서를 끝내면 …",
         "scriptText": "이 문서를 끝내면 다음을 스스로 설명할 수 있어야 합니다.", "skip": False},
        {"id": "seg004", "kind": "paragraph",
         "sourceExcerpt": "… 할 수 있다 …",
         "scriptText": "클라우드 컴퓨팅의 정의를 말할 수 있다", "skip": False},
        {"id": "seg005", "kind": "heading",
         "sourceExcerpt": "## 왜 중요한가", "scriptText": "왜 중요한가", "skip": False},
        {"id": "seg006", "kind": "paragraph",
         "sourceExcerpt": "본문에서 설명할 수 있다는 표현",
         "scriptText": "이 개념은 실무에서 바로 적용할 수 있다", "skip": False},
    ]
    _n = mark_scaffolding(_scaf)
    assert _n == 4, _n                                   # seg001 + seg002·003·004
    assert _scaf[1]["skip"] and _scaf[2]["skip"], _scaf  # 메타·체크리스트헤딩
    assert _scaf[3]["skip"] and _scaf[4]["skip"], _scaf  # 체크리스트 블록
    assert not _scaf[0]["skip"], _scaf                   # 일반 제목 유지
    assert not _scaf[5]["skip"], _scaf                   # 다음 헤딩에서 블록 종료
    assert not _scaf[6]["skip"], _scaf                   # '할 수 있다' 본문 오탐 안 함
    assert mark_scaffolding(_scaf) == 0, "멱등 위반"     # 재적용 0

    # Stage A1: descaffold 서브커맨드 I/O(임시 파일)
    import tempfile as _tf
    from types import SimpleNamespace as _NS
    _doc = {"schemaVersion": 2, "docId": "x", "reviewStatus": "approved",
            "segments": [
                {"id": "seg000", "kind": "paragraph",
                 "sourceExcerpt": "**커버하는 공식 Task** — …",
                 "scriptText": "커버하는 공식 Task — 도메인 1", "skip": False},
                {"id": "seg001", "kind": "heading",
                 "sourceExcerpt": "## 본문", "scriptText": "본문", "skip": False},
            ]}
    with _tf.TemporaryDirectory() as _d:
        _p = Path(_d) / "script.json"
        write_json(_p, _doc)
        run_descaffold(_NS(script=_p))
        _r = json.loads(_p.read_text(encoding="utf-8"))
    assert _r["segments"][0]["skip"] is True, _r
    assert _r["segments"][1]["skip"] is False, _r
    assert _r["reviewStatus"] == "needs_human_review", _r
    print("[self-test] descaffold I/O OK", file=sys.stderr)

    # Stage A2: josa 헬퍼(순수)
    assert _josa_eul("이점") == "을", _josa_eul("이점")      # 점 받침 ㅁ
    assert _josa_eul("핵심 개념") == "을"                    # 념 받침 ㅁ
    assert _josa_eul("인프라") == "를"                       # 라 받침 없음
    assert _josa_eul("AWS") == "를"                          # 비-Hangul 끝
    assert _josa_ro("이점") == "으로"                        # 받침 ㅁ(≠0,≠8)
    assert _josa_ro("인프라") == "로"                        # 받침 없음
    assert _josa_ro("서울") == "로"                          # 받침 ㄹ(=8)

    # Stage A2: 섹션 제목 정제
    assert _clean_section_title("2) 클라우드의 핵심 이점 (시험 핵심)") == "클라우드의 핵심 이점"
    assert _clean_section_title("3) 고가용성 · 탄력성 · 민첩성 — 헷갈리지 않기") == "고가용성, 탄력성, 민첩성"
    assert _clean_section_title("핵심 개념") == "핵심 개념"
    assert _clean_section_title("탄력성으로 비용 최적화 — Auto Scaling (보강)") == "탄력성으로 비용 최적화"

    # Stage A2: insert_connectors(도입1+앵커전환N+마무리1)
    _csegs = [
        {"id": "seg000", "kind": "heading", "sourceExcerpt": "# 클라우드의 이점",
         "scriptText": "클라우드의 이점", "skip": False},
        {"id": "seg001", "kind": "paragraph", "sourceExcerpt": "커버하는…",
         "scriptText": "메타", "skip": True},
        {"id": "seg002", "kind": "heading", "sourceExcerpt": "## 왜 중요한가",
         "scriptText": "왜 중요한가", "skip": False},
        {"id": "seg003", "kind": "paragraph", "sourceExcerpt": "본문",
         "scriptText": "본문1", "skip": False},
        {"id": "seg004", "kind": "heading", "sourceExcerpt": "## 핵심 개념 {#core}",
         "scriptText": "핵심 개념", "skip": False},
        {"id": "seg005", "kind": "paragraph", "sourceExcerpt": "본문",
         "scriptText": "본문2", "skip": False},
        {"id": "seg006", "kind": "heading", "sourceExcerpt": "## 글로벌 인프라 {#infra}",
         "scriptText": "글로벌 인프라", "skip": False},
        {"id": "seg007", "kind": "paragraph", "sourceExcerpt": "본문",
         "scriptText": "본문3", "skip": False},
    ]
    _added = insert_connectors(_csegs, "클라우드의 이점")
    assert _added == 4, _added                               # 도입1+전환2(core·infra)+마무리1
    _conn = [s for s in _csegs if s["kind"] == "connector"]
    assert len(_conn) == 4
    assert all(s["sourceExcerpt"] == "" and s["skip"] is False for s in _conn), _conn
    _ctexts = [s["scriptText"] for s in _conn]
    # 도입: len("클라우드의 이점")=8 %3=2 → "짚어 보겠습니다"
    assert any("짚어 보겠습니다" in t for t in _ctexts), _ctexts
    # 전환: core(0%4=0) "다음으로 핵심 개념을 살펴보겠습니다", infra(1%4=1) "이어서 글로벌 인프라로 넘어가겠습니다"
    assert "다음으로 핵심 개념을 살펴보겠습니다." in _ctexts, _ctexts
    assert "이어서 글로벌 인프라로 넘어가겠습니다." in _ctexts, _ctexts
    # 마무리: 8%3=2 → "수고하셨습니다"
    assert any("수고하셨습니다" in t for t in _ctexts), _ctexts
    # 전환은 앵커 heading 직전
    _ic = next(i for i, s in enumerate(_csegs) if s.get("scriptText") == "핵심 개념")
    assert _csegs[_ic - 1]["kind"] == "connector" and "핵심 개념" in _csegs[_ic - 1]["scriptText"]
    # 멱등
    assert insert_connectors(_csegs, "클라우드의 이점") == 0, "멱등 위반"

    # Stage A2: connectors 서브커맨드 I/O
    import tempfile as _tf2
    from types import SimpleNamespace as _NS2
    _cdoc = {"schemaVersion": 2, "docId": "x", "reviewStatus": "approved", "segments": [
        {"id": "seg000", "kind": "heading", "sourceExcerpt": "# 제목",
         "scriptText": "제목", "skip": False},
        {"id": "seg001", "kind": "heading", "sourceExcerpt": "## 본문 {#a}",
         "scriptText": "본문", "skip": False},
    ]}
    with _tf2.TemporaryDirectory() as _d2:
        _p2 = Path(_d2) / "script.json"
        write_json(_p2, _cdoc)
        run_connectors(_NS2(script=_p2))
        _r2 = json.loads(_p2.read_text(encoding="utf-8"))
    assert any(s["kind"] == "connector" for s in _r2["segments"]), _r2
    assert _r2["reviewStatus"] == "needs_human_review", _r2

    print("self-test OK")


def main() -> None:
    ap = argparse.ArgumentParser(
        description="학습문서 오디오 검수 파이프라인 (generate/synthesize/gate)")
    ap.add_argument("--self-test", action="store_true")
    sub = ap.add_subparsers(dest="cmd")

    g = sub.add_parser("generate", help="md → script.json + review_checklist.md")
    g.add_argument("--md", type=Path, required=True)
    g.add_argument("--out-dir", type=Path, required=True)
    g.add_argument("--doc-id")
    g.add_argument("--lexicon", type=Path)

    sy = sub.add_parser("synthesize", help="script.json → mp3 + audio_meta.json")
    sy.add_argument("--script", type=Path, required=True)
    sy.add_argument("--out", type=Path, required=True)
    sy.add_argument("--engine", default="polly")
    sy.add_argument("--voice", default="Seoyeon")
    sy.add_argument("--polly-engine", default="neural",
                    choices=["standard", "neural", "generative"])
    sy.add_argument("--region", default="ap-northeast-2")
    sy.add_argument("--max-chars", type=int, default=0)
    sy.add_argument("--skip-loudnorm", action="store_true",
                    help="loudness 정규화를 건너뜀(ffmpeg 불필요, 품질 저하 경고)")

    ga = sub.add_parser("gate", help="script.json/audio_meta 정적 검증")
    ga.add_argument("--script", type=Path, required=True)
    ga.add_argument("--md", type=Path)
    ga.add_argument("--audio-meta", type=Path)
    ga.add_argument("--lexicon", type=Path)

    ch = sub.add_parser("chapters",
                        help="script.json → audio_meta.json chapters 갱신(재합성 없음)")
    ch.add_argument("--script", type=Path, required=True)
    ch.add_argument("--audio-meta", type=Path, required=True)

    de = sub.add_parser("descaffold",
                        help="스캐폴딩(메타·체크리스트) 세그먼트 skip 표시")
    de.add_argument("--script", type=Path, required=True)

    co = sub.add_parser("connectors",
                        help="강의 연결문(도입·전환·마무리) 삽입")
    co.add_argument("--script", type=Path, required=True)

    args = ap.parse_args()
    if args.self_test:
        _self_test()
        return
    if args.cmd == "generate":
        run_generate(args)
    elif args.cmd == "synthesize":
        run_synthesize(args)
    elif args.cmd == "gate":
        run_gate(args)
    elif args.cmd == "chapters":
        run_chapters(args)
    elif args.cmd == "descaffold":
        run_descaffold(args)
    elif args.cmd == "connectors":
        run_connectors(args)
    else:
        ap.error("서브커맨드(generate/synthesize/gate/chapters/descaffold/connectors) 또는 --self-test 가 필요합니다.")


if __name__ == "__main__":
    main()
