# 학습 오디오 loudness 정규화 (③ 음질) — 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `gen_lecture_audio.py`의 synthesize에 ffmpeg `loudnorm` 2-pass(-16 LUFS) 단계를 추가해 CLF 강의 mp3의 문서 간 볼륨을 균일하게 한다.

**Architecture:** Polly 합성 mp3를 ffmpeg `loudnorm` 2-pass로 in-place 정규화한다. pass1 측정 JSON 파싱은 순수 함수 `_parse_loudnorm_json`(단위 테스트), 실제 정규화는 `_loudnorm_2pass`(subprocess). 기본 on, `--skip-loudnorm` 탈출구. Dart/lib·pubspec 무변경.

**Tech Stack:** Python 3 (`py` 런처), ffmpeg, Amazon Polly. 도구 자체 검증은 `--self-test`(assert 기반, pytest 아님).

## Global Constraints

- 모든 명령은 `flutter_app/` 디렉터리 기준. Windows는 `py` 런처(`python`은 Store alias 깨짐).
- 도구 검증: `py tool/gen_lecture_audio.py --self-test`(현재 "self-test OK"가 기준선 — 깨지면 안 됨).
- TDD: 새 동작은 `--self-test`에 실패하는 assert를 먼저 추가하고 구현으로 통과시킨다(절대조건 2).
- 커밋 직전 `git branch --show-current`로 `feat/audio-loudness` 확인(§5 공유 워킹트리).
- ffmpeg는 loudnorm 실행에만 필요. `_parse_loudnorm_json` 단위 테스트는 문자열 파싱이라 ffmpeg 불필요. self-test는 ffmpeg 미설치 시 loudnorm 실행 부분을 skip 로그로 넘긴다.
- **Dart/lib·pubspec 무변경** — `flutter test`/`flutter analyze`는 이 작업과 무관(현 상태 유지).

---

## File Structure

- **Modify** `flutter_app/tool/gen_lecture_audio.py` (단일 파일):
  - `_parse_loudnorm_json` 순수 함수 추가(ffmpeg pass1 stderr → 측정 dict)
  - `_loudnorm_2pass` 추가(subprocess 2-pass in-place 정규화)
  - `run_synthesize`에 ffmpeg 가용성 검사 + loudnorm 단계 통합
  - argparse synthesize 서브커맨드에 `--skip-loudnorm`
  - `build_audio_meta` return에 `loudness` 메타
  - `--self-test`에 파싱 assert + ffmpeg 조건부 skip 로그

---

### Task 1: `_parse_loudnorm_json` 순수 함수 + self-test assert

**Files:**
- Modify: `flutter_app/tool/gen_lecture_audio.py` (함수 추가 + self-test 블록에 assert)

**Interfaces:**
- Produces: `_parse_loudnorm_json(stderr_text: str) -> dict` — ffmpeg `loudnorm` pass1 stderr에서 마지막 JSON 블록을 파싱해 dict 반환. Task 2의 `_loudnorm_2pass`가 사용.

- [ ] **Step 1: Write the failing assert (self-test)**

`main()`의 self-test 블록에서 `print("self-test OK")` 바로 위에 추가:
```python
    # loudnorm pass1 JSON 파싱(순수)
    _ln = _parse_loudnorm_json(
        'ffmpeg noise\n[Parsed_loudnorm_0 @ 0x1] \n'
        '{\n  "input_i" : "-19.43",\n  "input_tp" : "-3.21",\n'
        '  "input_lra" : "7.40",\n  "input_thresh" : "-29.83",\n'
        '  "target_offset" : "0.50"\n}\ntrailing log\n')
    assert _ln["input_i"] == "-19.43", _ln
    assert _ln["target_offset"] == "0.50", _ln
```

- [ ] **Step 2: Run self-test to verify it fails**

Run: `py tool/gen_lecture_audio.py --self-test`
Expected: `NameError: name '_parse_loudnorm_json' is not defined` (함수 미정의).

- [ ] **Step 3: Implement `_parse_loudnorm_json`**

`_content_type` 함수 위(또는 `build_audio_meta` 근처, 다른 `_`-헬퍼 옆)에 추가:
```python
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
```
(`json`은 파일 상단에서 이미 import됨.)

- [ ] **Step 4: Run self-test to verify it passes**

Run: `py tool/gen_lecture_audio.py --self-test`
Expected: `self-test OK`.

- [ ] **Step 5: Commit**

```bash
git add flutter_app/tool/gen_lecture_audio.py
git commit -m "feat(audio): loudnorm pass1 JSON 파싱 순수 함수 _parse_loudnorm_json"
```

---

### Task 2: loudnorm 2-pass 통합 (`_loudnorm_2pass` + synthesize + argparse + meta)

**Files:**
- Modify: `flutter_app/tool/gen_lecture_audio.py`

**Interfaces:**
- Consumes: `_parse_loudnorm_json`(Task 1).
- Produces: `_loudnorm_2pass(path: Path, target_i=-16.0, tp=-1.5, lra=11.0) -> None`(in-place 정규화), synthesize `--skip-loudnorm` 플래그, audio_meta `loudness` 키.

- [ ] **Step 1: Implement `_loudnorm_2pass`**

`_parse_loudnorm_json` 아래에 추가:
```python
def _loudnorm_2pass(path: Path, target_i: float = -16.0,
                    tp: float = -1.5, lra: float = 11.0) -> None:
    """ffmpeg loudnorm 2-pass로 mp3를 in-place 정규화(EBU R128)."""
    import shutil
    import subprocess

    if shutil.which("ffmpeg") is None:
        raise RuntimeError("ffmpeg를 찾을 수 없습니다(loudnorm 필요).")
    base = f"loudnorm=I={target_i}:TP={tp}:LRA={lra}"
    p1 = subprocess.run(
        ["ffmpeg", "-hide_banner", "-i", str(path),
         "-af", base + ":print_format=json", "-f", "null", "-"],
        capture_output=True, text=True)
    m = _parse_loudnorm_json(p1.stderr)
    af2 = (base
           + f":measured_I={m['input_i']}:measured_TP={m['input_tp']}"
           + f":measured_LRA={m['input_lra']}:measured_thresh={m['input_thresh']}"
           + f":offset={m['target_offset']}:linear=true:print_format=summary")
    tmp = path.with_name(path.stem + ".norm" + path.suffix)
    subprocess.run(
        ["ffmpeg", "-hide_banner", "-y", "-i", str(path), "-af", af2, str(tmp)],
        capture_output=True, text=True, check=True)
    tmp.replace(path)
```

- [ ] **Step 2: Add `--skip-loudnorm` to synthesize argparse**

`main()`의 synthesize 서브파서(`sy = sub.add_parser("synthesize", ...)` 블록, `sy.add_argument("--max-chars", ...)` 다음 줄)에 추가:
```python
    sy.add_argument("--skip-loudnorm", action="store_true",
                    help="loudness 정규화를 건너뜀(ffmpeg 불필요, 품질 저하 경고)")
```

- [ ] **Step 3: Integrate into `run_synthesize`**

`run_synthesize`에서 `synthesize_polly(...)` 호출 다음, `id3 = _id3_count(args.out)` 줄 앞에 삽입:
```python
    if not args.skip_loudnorm:
        import shutil
        if shutil.which("ffmpeg") is None:
            sys.exit("ffmpeg가 필요합니다(loudness 정규화). 설치하거나 "
                     "--skip-loudnorm을 쓰세요.")
        _loudnorm_2pass(args.out)
        print("[loudnorm] -16 LUFS 정규화 완료", file=sys.stderr)
    else:
        print("[loudnorm] --skip-loudnorm: 정규화 건너뜀", file=sys.stderr)
```

- [ ] **Step 4: Add `loudness` to `build_audio_meta`**

`build_audio_meta`의 return dict에서 `"script": {...}` 항목 **앞에** 추가:
```python
        "loudness": {
            "targetLufs": -16,
            "normalized": not getattr(args, "skip_loudnorm", False),
        },
```

- [ ] **Step 5: Add ffmpeg-conditional self-test branch**

`main()` self-test 블록에서 Task 1의 파싱 assert 다음, `print("self-test OK")` 앞에 추가:
```python
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
            _loudnorm_2pass(_tone)
            assert _tone.exists() and _tone.stat().st_size > 0, "loudnorm 출력 없음"
            assert _id3_count(_tone) <= 1, "loudnorm 출력 ID3 다중"
        print("[self-test] loudnorm 실행 경로 OK", file=sys.stderr)
    else:
        print("[self-test] ffmpeg 없음 — loudnorm 실행 경로 skip", file=sys.stderr)
```

- [ ] **Step 6: Run self-test**

Run: `py tool/gen_lecture_audio.py --self-test`
Expected: `self-test OK`. ffmpeg 있으면 `[self-test] loudnorm 실행 경로 OK`, 없으면 `skip` 로그.

- [ ] **Step 7: Commit**

```bash
git add flutter_app/tool/gen_lecture_audio.py
git commit -m "feat(audio): synthesize에 ffmpeg loudnorm 2-pass(-16 LUFS) 통합 + --skip-loudnorm + audio_meta loudness"
```

---

## Self-Review

**1. Spec coverage:**
- ffmpeg loudnorm 2-pass, -16 LUFS → Task 2 `_loudnorm_2pass`(I=-16/TP=-1.5/LRA=11). ✓
- `_parse_loudnorm_json` 순수 함수 + 단위 테스트 → Task 1. ✓
- synthesize 통합(Polly 후 loudnorm) → Task 2 Step 3. ✓
- ffmpeg 미설치 처리(에러 + `--skip-loudnorm`) → Task 2 Step 2·3. ✓
- audio_meta `loudness: {targetLufs, normalized}` → Task 2 Step 4. ✓
- ID3 1개 확인 → Task 2 Step 5 self-test assert(`_id3_count <= 1`) + 기존 `run_synthesize`의 `[ID3]` 출력. ✓
- self-test ffmpeg 조건부 → Task 2 Step 5. ✓
- 재검수 불필요(script/reviewStatus 불변) → 코드가 script.json·reviewStatus를 건드리지 않음(loudnorm은 mp3만). ✓

**2. Placeholder scan:** 모든 스텝에 실제 코드. TODO/TBD 없음. ✓

**3. Type consistency:** `_parse_loudnorm_json(str)->dict`(Task1) ↔ Task2에서 `m = _parse_loudnorm_json(p1.stderr)`, `m['input_i']` 등 사용 일치. `_loudnorm_2pass(Path)`(Task2 정의) ↔ Step3·5 호출 일치. `args.skip_loudnorm`(Step2 정의) ↔ Step3·4 사용 일치. ✓

## 비목표 (별도)

사용자의 ffmpeg 설치·CLF 19문서 재합성·청취 / PCM 무손실 / Polly SampleRate / ④ 환각 가드. 정본 spec: `docs/superpowers/specs/2026-06-26-audio-loudness-normalization-design.md`.
