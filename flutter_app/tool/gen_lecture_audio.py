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
            _add("table", "\n".join(tbl), "",
                 audio_summary=None, issues=["table-needs-summary"])
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
    # 남은 영문 대문자 토큰(2자 이상) → 미등록 경고.
    for tok in sorted(set(re.findall(r"(?<![0-9A-Za-z])[A-Z][A-Z0-9]{1,}(?![0-9A-Za-z])", text))):
        issues.append(f"unmapped-token: {tok}")
    return text, issues


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
    return path.read_bytes().count(b"ID3")


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
        "script": {
            "speechChars": len(speech),
            "chunkCount": len(chunks),
            "qualityIssues": unique_issues,
            "reviewStatus": "needs_human_review",
        },
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


def synthesize_polly(chunks, out_path: Path, voice: str, engine: str,
                     region: str) -> None:
    """Amazon Polly로 청크별 mp3 합성 → 1개 파일(ffmpeg 불필요). neural은 요청당
    3000자 한도라 여러 청크가 될 수 있어, 첫 청크 외 ID3v2를 떼어 ID3를 1개로 유지(P0-1)."""
    import boto3

    polly = boto3.client("polly", region_name=region)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    buf = bytearray()
    for i, chunk in enumerate(chunks):
        resp = polly.synthesize_speech(
            Text=chunk, OutputFormat="mp3",
            VoiceId=voice, Engine=engine, LanguageCode="ko-KR",
        )
        data = resp["AudioStream"].read()
        buf += data if i == 0 else _strip_id3v2(data)
        print(f"  Polly {i + 1}/{len(chunks)}", file=sys.stderr)
    out_path.write_bytes(bytes(buf))


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
        audio_path.write_bytes(b"ID3" + b"\x00" * 10 + framed)
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
    assert len(tbl) == 1 and tbl[0]["skip"] is False and tbl[0]["audioSummary"] is None, tbl
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
    loaded = load_lexicon(None)
    assert "AWS" in loaded and loaded["AWS"]["say"], loaded   # 시드 로드
    print("self-test OK")


def main() -> None:
    ap = argparse.ArgumentParser(
        description="학습문서 .md → 한국어 강의 mp3 (주머니 라디오 M1 T6 임시)")
    ap.add_argument("--md", type=Path, help="입력 학습문서 .md")
    ap.add_argument("--out", type=Path, help="출력 경로(.mp3 또는 .wav)")
    ap.add_argument("--doc-id", help="오디오 문서 ID(기본: 출력 폴더명)")
    ap.add_argument("--meta-out", type=Path,
                    help="audio_meta.json 출력 경로(기본: out 옆 audio_meta.json)")
    ap.add_argument("--meta-only", action="store_true",
                    help="합성 없이 기존 --out 파일에서 audio_meta.json만 생성")
    ap.add_argument("--engine", choices=["polly", "melotts"], default="polly")
    ap.add_argument("--voice", default="Seoyeon", help="Polly 음성(Seoyeon/Jihye)")
    ap.add_argument("--polly-engine", default="neural",
                    choices=["standard", "neural", "generative"])
    ap.add_argument("--region", default="ap-northeast-2", help="Polly 리전")
    ap.add_argument("--speed", type=float, default=1.0, help="MeloTTS 속도")
    ap.add_argument("--device", default="cpu", help="MeloTTS cpu 또는 cuda:0")
    ap.add_argument("--max-chars", type=int, default=0,
                    help="청크 최대 길이(0=엔진 기본: polly 5500 / melotts 300)")
    ap.add_argument("--dry-run", action="store_true",
                    help="합성 없이 정제 대본 + 품질 게이트만 출력(엔진 불필요)")
    ap.add_argument("--self-test", action="store_true")
    args = ap.parse_args()

    if args.self_test:
        _self_test()
        return
    if not args.md or not args.out:
        ap.error("--md 와 --out 은 필수입니다(또는 --self-test).")
    if not args.md.exists():
        sys.exit(f"입력 파일 없음: {args.md}")
    if args.meta_only and not args.out.exists():
        sys.exit(f"--meta-only 에 필요한 기존 오디오 파일 없음: {args.out}")

    # Polly neural은 요청당 3000자 한도 → 여유를 둬 2900자로 분할.
    max_chars = args.max_chars or (2900 if args.engine == "polly" else 300)

    md = args.md.read_text(encoding="utf-8")
    speech = markdown_to_speech_text(md)
    chunks = chunk_text(speech, max_chars)
    print(f"[정제] {len(speech)}자 → {len(chunks)}개 청크 (engine={args.engine})",
          file=sys.stderr)

    # 품질 게이트 — M1 픽스처는 경고만(재생 게이트 ≠ 콘텐츠 검수 게이트).
    issues = quality_issues(speech)
    if issues:
        print(f"[품질 게이트] {len(issues)}개 이슈 — 검수 전 픽스처(공개 전 사람 검수 필요):",
              file=sys.stderr)
        for it in dict.fromkeys(issues):  # 중복 제거, 순서 유지
            print(f"  - {it}", file=sys.stderr)
    else:
        print("[품질 게이트] 통과(이슈 0)", file=sys.stderr)

    if args.dry_run:
        for i, c in enumerate(chunks):
            print(f"\n--- 청크 {i} ({len(c)}자) ---\n{c}")
        print("\n[dry-run] 합성 생략.", file=sys.stderr)
        return

    doc_id = args.doc_id or args.out.parent.name
    meta_out = args.meta_out or args.out.with_name("audio_meta.json")

    if args.meta_only:
        write_json(meta_out, build_audio_meta(
            md_path=args.md,
            audio_path=args.out,
            doc_id=doc_id,
            speech=speech,
            chunks=chunks,
            issues=issues,
            args=args,
            mode="meta-only",
        ))
        print(f"[메타] {meta_out}", file=sys.stderr)
        return

    if args.engine == "polly":
        synthesize_polly(chunks, args.out, args.voice, args.polly_engine, args.region)
    else:
        synthesize_melotts(chunks, args.out, args.speed, args.device)

    # P0-1 게이트: 최종 mp3의 ID3는 1개만 허용(청크 단순 연결 탐지).
    if args.out.suffix.lower() == ".mp3":
        id3 = _id3_count(args.out)
        flag = "OK" if id3 <= 1 else "다중 — 청크 연결됨(단일 요청 권장)"
        print(f"[ID3] {id3}개 — {flag}", file=sys.stderr)
    write_json(meta_out, build_audio_meta(
        md_path=args.md,
        audio_path=args.out,
        doc_id=doc_id,
        speech=speech,
        chunks=chunks,
        issues=issues,
        args=args,
        mode="synthesized",
    ))
    print(f"[메타] {meta_out}", file=sys.stderr)
    print(f"[완료] {args.out}", file=sys.stderr)


if __name__ == "__main__":
    main()
