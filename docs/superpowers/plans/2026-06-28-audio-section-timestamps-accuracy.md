# 제목 타임스탬프 정확화(섹션 길이) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `audio_meta.chapters`의 `fraction`을 글자수 추정 → 실제 오디오 섹션 길이(ffprobe) 기반 정확값으로 업그레이드한다(앱 무변경, 도구·19문서 재합성만).

**Architecture:** `synthesize`를 제목(앵커 heading) 경계 섹션 단위로 재구조화 — 섹션마다 Polly 합성·`ffprobe` 길이 측정 후 concat, 누적 길이로 `fraction = 시작/Σ길이` 계산. 순수 함수 `split_sections`·`chapters_from_section_durations`로 분할·조립을 단위 테스트한다. `audio_meta.chapters` 스키마(fraction)는 그대로라 앱은 변경 없음.

**Tech Stack:** Python(`gen_lecture_audio.py`), Amazon Polly(boto3), ffmpeg/ffprobe. 검증 `--self-test`, 19문서 재합성은 PowerShell.

## Global Constraints

- 모든 명령은 `flutter_app/` 기준. Python은 `py`, Flutter는 `flutter`. 도구 게이트: `py tool/gen_lecture_audio.py --self-test` 그린.
- TDD: 순수 함수는 실패 self-test 선작성 → 구현 → 통과 → 커밋. (run_synthesize는 Polly·ffmpeg 의존이라 self-test 대신 1문서 실측으로 검증 — Task 4.)
- **데이터 계약 불변**: `audio_meta.json`의 `chapters: [{anchor,title,level,fraction}]` 스키마 그대로. **Dart/앱 무변경**(앱·테스트 수정 금지).
- **섹션 경계 = 앵커 있는 heading**(`sourceExcerpt`에 `{#id}` + 선행 `#` 둘 다). intro(첫 앵커 헤딩 전)는 anchor=None 섹션. 앵커 없는 헤딩은 경계가 아니며 현재 섹션에 포함.
- **fraction = 누적 시작 ms ÷ Σ섹션길이**(self-consistent; total 0이면 0.0). 앵커 있는 섹션만 chapters에 emit.
- **불변식**: `"\n".join(빈 아닌 섹션 speech) == script_to_speech(script)`(음성 누락·중복 없음). self-test 가드.
- 발음 텍스트 = `_segment_speech`(table=audioSummary, 그 외 scriptText, skip은 "")(기존 #85 함수 재사용).
- loudnorm/24kHz 비트레이트는 기존 유지(길이 불변 → fraction 안정).
- 19문서 재합성: 음성 내용 동일(같은 세그먼트·voice — 청킹만 다름) → 재청취 없이 `audio_meta` top-level+script reviewStatus를 approved로 재전환(loudness 패턴, content_index 동기화 통과).
- 커밋 직전 `git branch --show-current`로 `feat/audio-section-timestamps-accuracy` 확인. 다른 세션 untracked(`assets/audio/clf/_*`, `clf-t1-1/review_notes.*`) 절대 `git add` 금지.
- 비목표(YAGNI): Polly speech-mark · 앵커 없는 헤딩 타임스탬프 · 챕터 UI 변경 · 추정 `chapters` 서브커맨드 제거(유지).

## File Structure

- Modify `flutter_app/tool/gen_lecture_audio.py` — `split_sections`·`chapters_from_section_durations`(순수), `_audio_duration_ms`·`_synthesize_chunks_to_bytes` 헬퍼, `run_synthesize` 재구조화, self-test.
- (Task 4 운영) `flutter_app/assets/audio/clf/clf-t*/{lecture.mp3,audio_meta.json}` 재생성.

---

## Task 1: split_sections 순수 함수

**Files:**
- Modify: `flutter_app/tool/gen_lecture_audio.py`(`split_sections` + self-test)

**Interfaces:**
- Consumes: `_segment_speech`(seg)(기존 #85), `script_to_speech`(script)(기존).
- Produces: `split_sections(segments: list[dict]) -> list[dict]` — `[{anchor: str|None, title: str|None, level: int|None, speech: str}]`.

- [ ] **Step 1: 실패 self-test 추가**

`_self_test()`의 `chapters_from_segments` 단언 블록 근처에 추가:

```python
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
```

- [ ] **Step 2: 실패 확인**

Run: `cd flutter_app && py tool/gen_lecture_audio.py --self-test`
Expected: FAIL — `split_sections` 미정의.

- [ ] **Step 3: 구현**

`chapters_from_segments` 정의 뒤에 추가:

```python
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
```

- [ ] **Step 4: 통과 확인**

Run: `cd flutter_app && py tool/gen_lecture_audio.py --self-test`
Expected: PASS — `[self-test] split_sections OK`, 마지막 `self-test OK`.

- [ ] **Step 5: 커밋**

```bash
git add flutter_app/tool/gen_lecture_audio.py
git commit -m "feat(audio): split_sections(앵커 헤딩 경계 섹션 분할) 순수 함수"
```

---

## Task 2: chapters_from_section_durations 순수 함수

**Files:**
- Modify: `flutter_app/tool/gen_lecture_audio.py`(`chapters_from_section_durations` + self-test)

**Interfaces:**
- Consumes: `split_sections` 출력(Task 1).
- Produces: `chapters_from_section_durations(sections: list[dict], durations_ms: list[int]) -> list[dict]` — `[{anchor,title,level,fraction}]`(앵커 있는 섹션만).

- [ ] **Step 1: 실패 self-test 추가**

`_self_test()`에 추가:

```python
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
```

- [ ] **Step 2: 실패 확인**

Run: `cd flutter_app && py tool/gen_lecture_audio.py --self-test`
Expected: FAIL — `chapters_from_section_durations` 미정의.

- [ ] **Step 3: 구현**

`split_sections` 뒤에 추가:

```python
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
```

- [ ] **Step 4: 통과 확인**

Run: `cd flutter_app && py tool/gen_lecture_audio.py --self-test`
Expected: PASS — `[self-test] chapters_from_section_durations OK`.

- [ ] **Step 5: 커밋**

```bash
git add flutter_app/tool/gen_lecture_audio.py
git commit -m "feat(audio): chapters_from_section_durations(섹션 길이→정확 fraction) 순수 함수"
```

---

## Task 3: synthesize 섹션 재구조화 + ffprobe 길이

**Files:**
- Modify: `flutter_app/tool/gen_lecture_audio.py`(`_audio_duration_ms`·`_synthesize_chunks_to_bytes` 헬퍼, `run_synthesize` 재구조화, self-test ffprobe)

**Interfaces:**
- Consumes: `split_sections`·`chapters_from_section_durations`(Task 1·2), 기존 `chunk_text`·`_strip_id3v2`·`_loudnorm_2pass`·`build_audio_meta`.
- Produces: `_audio_duration_ms(path: Path) -> int`, `_synthesize_chunks_to_bytes(chunks, voice, engine, region) -> bytes`. `run_synthesize`가 섹션별 합성·ffprobe·concat·정확 chapters로 동작.

- [ ] **Step 1: 실패 self-test 추가(ffprobe 헬퍼)**

`_self_test()`의 loudnorm 실행 경로 블록(ffmpeg 가용 시) 안, 톤 생성 직후에 추가:

```python
            assert _audio_duration_ms(_tone) >= 900, _audio_duration_ms(_tone)  # ~1s 톤
```

(loudnorm self-test가 이미 `if _sh.which("ffmpeg")` 안에서 1초 사인 톤 `_tone`을 만든다 — 그 톤으로 ffprobe 길이 ≈1000ms 확인.)

- [ ] **Step 2: 실패 확인**

Run: `cd flutter_app && py tool/gen_lecture_audio.py --self-test`
Expected: FAIL — `_audio_duration_ms` 미정의(ffmpeg 있는 환경) 또는 NameError.

- [ ] **Step 3: 헬퍼 + run_synthesize 재구조화**

`_loudnorm_2pass` 부근에 ffprobe 헬퍼 추가:

```python
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
```

`synthesize_polly`를 바이트 반환 헬퍼로 분리 — 기존 `synthesize_polly` 본문(boto3 polly·청크 루프·ID3 strip)을 아래 `_synthesize_chunks_to_bytes`로 옮기고, `synthesize_polly`는 thin wrapper로 둔다(다른 호출부 호환):

```python
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
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_bytes(_synthesize_chunks_to_bytes(chunks, voice, engine, region))
```

`run_synthesize`를 섹션 기반으로 교체(기존 speech/chunks 흐름 → 섹션 루프):

```python
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
```

(주의: 기존 `run_synthesize`가 `chapters_from_segments`로 chapters를 채웠는데, 이제 `chapters_from_section_durations`(정확)로 바뀐다. `script_to_speech`는 더 이상 run_synthesize에서 직접 호출하지 않으나 함수 자체는 self-test 불변식 검증에 쓰이므로 그대로 둔다. `build_audio_meta`의 `chunks=[]` — script.chunkCount는 0이 되나 정보용 필드라 무해.)

- [ ] **Step 4: 통과 확인 + 분석**

Run: `cd flutter_app && py tool/gen_lecture_audio.py --self-test`
Expected: PASS(ffmpeg 있으면 `_audio_duration_ms` 톤 ≈1000ms 단언 포함; 없으면 그 단언은 skip 블록이라 미실행).

Run: `cd flutter_app && py -c "import ast; ast.parse(open('tool/gen_lecture_audio.py',encoding='utf-8').read()); print('syntax OK')"`
Expected: `syntax OK`.

- [ ] **Step 5: 커밋**

```bash
git add flutter_app/tool/gen_lecture_audio.py
git commit -m "feat(audio): synthesize 섹션 재구조화 + ffprobe 길이로 정확 chapters fraction"
```

---

## Task 4: 1문서 선검증 + 19문서 재합성·재승인 (운영)

**선행:** ffmpeg/ffprobe + Polly 자격증명 필요. 명령은 PowerShell(Git Bash 금지 — 경로/네트워크). 이 Task는 Polly 과금이 발생한다.

**Files:**
- Modify: `flutter_app/assets/audio/clf/clf-t*/{lecture.mp3,audio_meta.json}`(19문서 재생성)

- [ ] **Step 1: 1문서 선검증(clf-t1-1)**

PowerShell:
```powershell
cd D:\workspace\awc-docs\flutter_app
$bin="C:\Users\deepe\AppData\Local\Microsoft\WinGet\Packages\Gyan.FFmpeg_Microsoft.Winget.Source_8wekyb3d8bbwe\ffmpeg-8.1.1-full_build\bin"
$env:PATH="$bin;$env:PATH"
py tool/gen_lecture_audio.py synthesize --script assets/audio/clf/clf-t1-1/script.json --out assets/audio/clf/clf-t1-1/lecture.mp3
```
검증(PowerShell):
- `ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 assets/audio/clf/clf-t1-1/lecture.mp3` 로 최종 길이 확인.
- `py -c "import json;m=json.load(open('assets/audio/clf/clf-t1-1/audio_meta.json',encoding='utf-8'));cs=m['chapters'];print(len(cs));print([round(c['fraction'],3) for c in cs]);assert all(0<=c['fraction']<1 for c in cs);assert cs==sorted(cs,key=lambda c:c['fraction'])"` — fraction 단조·[0,1) 확인.
- `py tool/gen_lecture_audio.py gate --script assets/audio/clf/clf-t1-1/script.json --audio-meta assets/audio/clf/clf-t1-1/audio_meta.json` → PASS.
기대: chapters fraction이 추정값과 달라지되 단조·[0,1), gate PASS. (이상 시 STOP — 컨트롤러에 보고.)

- [ ] **Step 2: 19문서 재합성**

PowerShell(위 `$env:PATH` 유지):
```powershell
Get-ChildItem assets/audio/clf -Directory | Where-Object { $_.Name -like 'clf-t*' } | ForEach-Object {
  $d=$_.Name
  py tool/gen_lecture_audio.py synthesize --script "assets/audio/clf/$d/script.json" --out "assets/audio/clf/$d/lecture.mp3"
}
```
기대: 각 문서 `[완료]`. (clf-t1-1은 Step 1에서 이미 됨 — 재실행 무해.)

- [ ] **Step 3: reviewStatus 재승인(내용 불변)**

재합성으로 audio_meta top-level reviewStatus가 needs_human_review로 리셋됨. 음성 내용 동일이라 재청취 없이 approved 재전환(PowerShell):
```powershell
py - <<'PY'
import json, pathlib
clf = pathlib.Path("assets/audio/clf")
for d in sorted(p for p in clf.iterdir() if p.is_dir() and p.name.startswith("clf-t")):
    amp = d/"audio_meta.json"
    m = json.loads(amp.read_text(encoding="utf-8"))
    if m.get("script",{}).get("reviewStatus")=="approved":
        m["reviewStatus"]="approved"
        amp.write_text(json.dumps(m,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
        print("approved", d.name)
PY
```
(script.reviewStatus는 synthesize가 script.json 값(approved)을 옮기므로 이미 approved. top-level만 재전환.)

- [ ] **Step 4: 전체 검증**

PowerShell/일반:
- `flutter test test/content_index_test.dart` → PASS(audioApproved↔audio_meta 동기화: top+script approved+mp3).
- 19문서 `gate --audio-meta` 일괄 PASS(reviewStatus 3필드 approved·id3=1).
- `flutter test`(전체)·`flutter analyze`(신규 0) — 앱 무변경이라 자명하나 확인.
- `flutter build web --dart-define=audio_lecture=true` 성공.

- [ ] **Step 5: 커밋**

```bash
git add flutter_app/assets/audio/clf/clf-t*/lecture.mp3 flutter_app/assets/audio/clf/clf-t*/audio_meta.json
git commit -m "chore(audio): CLF19 재합성 — 섹션 길이 기반 정확 제목 타임스탬프(chapters fraction)"
```

---

## Self-Review (작성자 점검 결과)

1. **Spec coverage:** §1 섹션 분할 = Task 1. §2 synthesize 재구조화·ffprobe·정확 fraction = Task 2(조립 순수)+Task 3(합성). §3 데이터 계약 유지 = 전 태스크 fraction 스키마 불변(앱 무변경). §운영 19문서 재합성·재승인 = Task 4. §4 1문서 선검증 = Task 4 Step 1. §5 추정 fallback 유지 = `chapters_from_segments`·`chapters` 서브커맨드 미삭제(건드리지 않음). 누락 없음.
2. **Placeholder scan:** 모든 step에 실제 코드·명령·기대 출력. TBD/TODO 없음. Task 4는 Polly 과금·PowerShell 의존을 명시(운영 태스크).
3. **Type consistency:** `split_sections -> [{anchor,title,level,speech}]`(Task 1) ↔ `chapters_from_section_durations(sections, durations_ms)`(Task 2)가 anchor/title/level 사용 ↔ `run_synthesize`가 `chapters_from_section_durations(sections, durations_ms)` 호출(Task 3) 일치. `_segment_speech`·`script_to_speech`·`chunk_text`·`_strip_id3v2`·`_loudnorm_2pass`·`build_audio_meta`(기존) 시그니처 그대로. `audio_meta.chapters` 스키마 `{anchor,title,level,fraction}`는 #85와 동일(앱 무변경).
