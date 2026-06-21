#!/usr/bin/env python3
"""학습 문서(.md) 1개 → 한국어 오디오 강의(mp3) 생성 — 주머니 라디오 M1 T6 임시 픽스처.

T4(미니 플레이어 진입점)가 재생할 "실물" mp3 1개를 만든다. 대본 자동 생성·
환각 가드는 M2이므로, 이 스크립트는 마크다운을 거칠게 평문으로 정제해 그대로
읽는다(검증정책 A: 충실 변환·무검수 — 공개 전 사람 검수는 별도). 표·코드 블록은
음성에서 제외한다(미니 플레이어 카피 "표나 코드는 화면에서 확인해야 합니다"와 일치).

엔진: MeloTTS-Korean (MIT — 생성물 공개 재배포 자유, GitHub Pages 배포에 안전).
  ※ Kokoro는 한국어 voice 미제공(공식 README·VOICES.md 확인)이라 제외.
출력: 24kHz wav를 이어붙여 1개 파일(1A = 문서당 1개 합친 파일). .mp3면 ffmpeg 변환.

설치(공식 https://github.com/myshell-ai/MeloTTS/blob/main/docs/install.md):
  git clone https://github.com/myshell-ai/MeloTTS.git && cd MeloTTS
  pip install -e .
  python -m unidic download
  pip install soundfile numpy        # (이 스크립트 추가 의존)
  # mp3 출력 시 시스템에 ffmpeg 필요(.wav로 받으면 불필요)

사용:
  # 1) 엔진 설치 전 — 정제된 대본 텍스트만 확인(눈으로 검증)
  python tool/gen_lecture_audio.py --md assets/content/clf/t1-1.md --out x.mp3 --dry-run
  # 2) 정제 로직 자체 검증(엔진 불필요)
  python tool/gen_lecture_audio.py --self-test
  # 3) 실제 생성
  python tool/gen_lecture_audio.py \
    --md assets/content/clf/t1-1.md \
    --out assets/audio/clf/clf-t1-1/lecture.mp3
"""
import argparse
import re
import subprocess
import sys
import tempfile
from pathlib import Path

# Windows 콘솔(cp949) 등 비-UTF-8 stdout에서도 한글·기호(—, →)를 깨짐 없이 출력.
for _stream in (sys.stdout, sys.stderr):
    try:
        _stream.reconfigure(encoding="utf-8")
    except (AttributeError, ValueError):
        pass


def markdown_to_speech_text(md: str) -> str:
    """마크다운 → 음성용 평문(거친 정제, M1 임시).

    제외: YAML frontmatter, 코드 펜스(```), 표(| ... |), HTML 태그/주석, 이미지.
    정리: 헤딩 기호와 {#anchor}, 리스트·인용 기호, 링크는 텍스트만, 강조 기호 제거.
    M2에서 정교한 강사 대본 생성(study_content 파서 동등 분절)으로 대체한다.
    """
    out: list[str] = []
    in_code = False
    in_frontmatter = False
    for i, raw in enumerate(md.splitlines()):
        s = raw.strip()
        # YAML frontmatter (--- ... ---) — 파일 맨 앞에서만.
        if i == 0 and s == "---":
            in_frontmatter = True
            continue
        if in_frontmatter:
            if s == "---":
                in_frontmatter = False
            continue
        # 코드 펜스 토글 — 내부는 통째로 제외.
        if s.startswith("```"):
            in_code = not in_code
            continue
        if in_code:
            continue
        # 표 행 제외(파이프로 시작).
        if s.startswith("|"):
            continue
        # 빈 줄·HTML 주석·이미지 제외.
        if not s or s.startswith("<!--") or s.startswith("!["):
            continue
        # 수평선(---, ***, ___) 제외 — "대시 대시 대시"로 읽히는 것 방지.
        if re.fullmatch(r"([-*_])\1{2,}", s):
            continue
        # 헤딩 기호와 {#anchor} 제거.
        s = re.sub(r"^#{1,6}\s*", "", s)
        s = re.sub(r"\s*\{#[^}]*\}\s*$", "", s)
        # 리스트·인용 기호, 체크박스 마커([ ]/[x]).
        s = re.sub(r"^[-*+]\s+", "", s)
        s = re.sub(r"^\d+\.\s+", "", s)
        s = re.sub(r"^>\s*", "", s)
        s = re.sub(r"^\[[ xX]\]\s*", "", s)
        # 이미지·링크: 이미지 제거, 링크는 표시 텍스트만.
        s = re.sub(r"!\[[^\]]*\]\([^)]*\)", "", s)
        s = re.sub(r"\[([^\]]+)\]\([^)]*\)", r"\1", s)
        # HTML 태그(<details>/<summary> 등) 제거.
        s = re.sub(r"<[^>]+>", "", s)
        # 인라인 강조·코드 기호 제거.
        s = re.sub(r"[*_`]+", "", s)
        # 이모지·픽토그램 제거(TTS 부적합 — 화살표 →는 의미 표지라 유지).
        s = re.sub(
            r"[\U0001F000-\U0001FAFF\U00002600-\U000027BF"
            r"\U00002B00-\U00002BFF\U0000FE0F\U0000200D]",
            "", s)
        s = re.sub(r"\s{2,}", " ", s).strip()
        if s:
            out.append(s)
    return "\n".join(out)


def chunk_text(text: str, max_chars: int = 300) -> list[str]:
    """긴 합성 불안정 회피 — 문장 경계로 청크 분할(한국어 종결/문장부호 기준)."""
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


def synthesize(chunks: list[str], out_path: Path, speed: float, device: str) -> None:
    """MeloTTS-Korean으로 청크별 합성 → 이어붙여 1개 파일. .mp3면 ffmpeg 변환."""
    from melo.api import TTS  # 무거운 import는 실제 합성 시에만.
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
            segments.append(np.zeros(int(sr * 0.3)))  # 청크 사이 0.3초 호흡.
            print(f"  합성 {i + 1}/{len(chunks)}", file=sys.stderr)
        merged = np.concatenate(segments)

        out_path.parent.mkdir(parents=True, exist_ok=True)
        if out_path.suffix.lower() == ".mp3":
            merged_wav = Path(td) / "merged.wav"
            sf.write(str(merged_wav), merged, sr)
            subprocess.run(
                ["ffmpeg", "-y", "-i", str(merged_wav),
                 "-codec:a", "libmp3lame", "-b:a", "128k", str(out_path)],
                check=True,
            )
        else:
            sf.write(str(out_path), merged, sr)


def _self_test() -> None:
    """정제·청크 로직 검증(엔진 불필요)."""
    md = (
        "---\nname: x\ndomain: 1\n---\n"
        "# 제목입니다 {#intro}\n\n"
        "본문 문장입니다. 두 번째 문장입니다.\n\n"
        "```dart\nvoid main() {}\n```\n\n"
        "| 열A | 열B |\n| --- | --- |\n| 1 | 2 |\n\n"
        "- 목록 항목 [링크](https://x)\n"
        "<details><summary>요약</summary>\n"
        "**강조** 텍스트입니다.\n\n"
        "## ✅ 체크리스트 {#c}\n\n"
        "---\n\n"
        "- [ ] 첫 항목입니다\n"
        "🎯 이모지 본문입니다.\n"
    )
    out = markdown_to_speech_text(md)
    assert "제목입니다" in out, out
    assert "본문 문장입니다." in out, out
    assert "void main" not in out, f"코드블록 누출: {out}"
    assert "열A" not in out, f"표 누출: {out}"
    assert "name: x" not in out, f"frontmatter 누출: {out}"
    assert "목록 항목 링크" in out, f"링크 텍스트 처리: {out}"
    assert "요약" in out and "<" not in out, f"HTML 태그 처리: {out}"
    assert "#" not in out and "{#intro}" not in out, f"헤딩/앵커 처리: {out}"
    assert "*" not in out and "강조 텍스트입니다." in out, f"강조 처리: {out}"
    assert "✅" not in out and "🎯" not in out, f"이모지 제거: {out}"
    assert "체크리스트" in out and "첫 항목입니다" in out, f"헤딩/항목 텍스트 보존: {out}"
    assert "[ ]" not in out, f"체크박스 마커 제거: {out}"
    assert not any(ln.strip() in ("---", "***", "___") for ln in out.split("\n")), \
        f"수평선 제거: {out}"

    chunks = chunk_text("가나다라. 마바사아. 자차카타.", max_chars=10)
    assert len(chunks) >= 2, f"청크 분할: {chunks}"
    assert all(len(c) <= 20 for c in chunks), f"청크 길이: {chunks}"
    print("self-test OK")


def main() -> None:
    ap = argparse.ArgumentParser(
        description="학습문서 .md → 한국어 강의 mp3 (주머니 라디오 M1 T6 임시)")
    ap.add_argument("--md", type=Path, help="입력 학습문서 .md")
    ap.add_argument("--out", type=Path, help="출력 경로(.mp3 또는 .wav)")
    ap.add_argument("--speed", type=float, default=1.0)
    ap.add_argument("--device", default="cpu", help="cpu 또는 cuda:0")
    ap.add_argument("--max-chars", type=int, default=300, help="청크 최대 길이")
    ap.add_argument("--dry-run", action="store_true",
                    help="합성 없이 정제된 대본만 출력(엔진 설치 전 검증)")
    ap.add_argument("--self-test", action="store_true",
                    help="정제·청크 로직 검증(엔진 불필요)")
    args = ap.parse_args()

    if args.self_test:
        _self_test()
        return

    if not args.md or not args.out:
        ap.error("--md 와 --out 은 필수입니다(또는 --self-test).")
    if not args.md.exists():
        sys.exit(f"입력 파일 없음: {args.md}")

    md = args.md.read_text(encoding="utf-8")
    speech = markdown_to_speech_text(md)
    chunks = chunk_text(speech, args.max_chars)
    print(f"[정제] {len(speech)}자 → {len(chunks)}개 청크", file=sys.stderr)

    if args.dry_run:
        for i, c in enumerate(chunks):
            print(f"\n--- 청크 {i} ({len(c)}자) ---\n{c}")
        print("\n[dry-run] 합성 생략. 위 텍스트가 음성이 됩니다.", file=sys.stderr)
        return

    synthesize(chunks, args.out, speed=args.speed, device=args.device)
    print(f"[완료] {args.out}", file=sys.stderr)


if __name__ == "__main__":
    main()
