# 학습 오디오 환각 가드(④ 대본 원문 토큰 보존) 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `gen_lecture_audio.py`의 `gate`가 각 seg에서 원문(`sourceExcerpt`)의 핵심 토큰(lexicon 약어·수치)이 대본(table=`audioSummary`, 그 외=`scriptText`)에 보존됐는지 자동 검출한다.

**Architecture:** 순수 함수 `check_token_preservation(source, target, lexicon) -> (hard, soft)`를 추가하고, `gate_script`에 `lexicon` 인자를 더해 비-skip seg마다 호출·누적한다. `run_gate`는 `--lexicon`(기본 `tool/lexicon.json`)을 로드해 전달한다. 약어 누락=hard, 수치 누락=soft. Dart/lib·pubspec 무변경, 문자열 검사뿐이라 네트워크·ffmpeg 불필요.

**Tech Stack:** Python 3(표준 라이브러리 `re`/`json`/`pathlib`), 단일 파일 `flutter_app/tool/gen_lecture_audio.py`, 검증은 `--self-test`.

## Global Constraints

- 모든 명령은 `flutter_app/` 기준. 도구 self-test: `cd flutter_app && py tool/gen_lecture_audio.py --self-test` 그린.
- 범위: `gen_lecture_audio.py`의 `check_token_preservation` + gate 통합 + `--lexicon` + self-test **만**. Dart/lib·pubspec **무변경**.
- 비목표: LLM 생성 대비 가드 / 서비스 풀네임 매칭 / 수치 한글 수사 정밀 매칭 / 19문서 재검토·audioSummary 보완(사용자 몫).
- 추측 금지: 시그니처·패턴은 본 계획에 명시된 기존 코드와 일치시킨다. 토큰 검출 단어경계 패턴은 `apply_lexicon`과 동일(`(?<![0-9A-Za-z])` + `re.escape(key)` + `(?![0-9A-Za-z])`).
- 하위호환: `gate_script`의 `lexicon` 인자는 기본값 `None`이며, `None`/빈 dict이면 토큰 검사를 **건너뛴다**(기존 self-test 호출이 lexicon 없이 `gate_script({...})`를 부른다).

---

## File Structure

- `flutter_app/tool/gen_lecture_audio.py` (Modify only)
  - 추가: 모듈 상수 `_NUM_RE`, 헬퍼 `_lexicon_say_forms(...)`, 순수 함수 `check_token_preservation(...)` — `apply_lexicon`(270행) 근처/뒤.
  - 수정: `gate_script(script)` → `gate_script(script, lexicon=None)` (423행), 루프 말미에 토큰 보존 블록 추가.
  - 수정: `run_gate(args)` (463행) — lexicon 로드 후 `gate_script(script, lex)` 호출, 빈 lexicon 경고.
  - 수정: gate 서브파서 `ga` (1006~1009행) — `ga.add_argument("--lexicon", type=Path)`.
  - 수정: `_self_test()` (749행) — Task 1·Task 2의 assert 블록 추가.

테스트는 별도 파일 없이 `_self_test()` 인라인 assert(도구의 기존 관례 — `gate_script`/`apply_lexicon`도 동일 방식).

---

## Task 1: `check_token_preservation` 순수 함수 + self-test

**Files:**
- Modify: `flutter_app/tool/gen_lecture_audio.py` (`apply_lexicon` 함수 뒤, 약 297행 직후에 신규 정의 삽입)
- Test: `flutter_app/tool/gen_lecture_audio.py` 내 `_self_test()` (약 951행, loudnorm 블록 앞)

**Interfaces:**
- Consumes: 기존 `import re`(파일 상단에 이미 존재). lexicon entry 구조 = `{"say": str}` 또는 `{"firstSay": str, "thenSay": str}`(선택적 `say`).
- Produces:
  - `check_token_preservation(source: str, target: str, lexicon: dict) -> tuple[list[str], list[str]]` — 반환 `(hard, soft)`. hard 항목 형식 `"약어 누락: {key}({say})"`, soft 항목 형식 `"수치 누락: {num}"`.
  - `_lexicon_say_forms(entry: dict, key: str) -> list[str]` — 검출용 발음 후보 목록.
  - 모듈 상수 `_NUM_RE`(컴파일된 정규식).

- [ ] **Step 1: 실패하는 self-test 추가**

`_self_test()`의 loudnorm pass1 JSON 파싱 블록(`# loudnorm pass1 JSON 파싱(순수)` 주석, 약 953행) **바로 앞**에 아래 블록을 삽입한다:

```python
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
```

- [ ] **Step 2: 실패 확인**

Run: `cd flutter_app && py tool/gen_lecture_audio.py --self-test`
Expected: FAIL — `NameError: name 'check_token_preservation' is not defined`

- [ ] **Step 3: 순수 함수 구현**

`apply_lexicon` 함수 정의가 끝나는 지점(약 297행, `return text, issues` 다음 빈 줄) **뒤에** 아래를 삽입한다:

```python
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
```

- [ ] **Step 4: 통과 확인**

Run: `cd flutter_app && py tool/gen_lecture_audio.py --self-test`
Expected: PASS — 마지막 줄 `self-test OK`, 중간에 `[self-test] check_token_preservation OK`

- [ ] **Step 5: 커밋**

커밋 직전 `git branch --show-current`로 `feat/audio-hallucination-guard` 확인 후:

```bash
git add flutter_app/tool/gen_lecture_audio.py
git commit -m "feat(audio): 환각 가드 순수함수 check_token_preservation(약어 hard/수치 soft)"
```

---

## Task 2: gate 통합 + `--lexicon` + self-test

**Files:**
- Modify: `flutter_app/tool/gen_lecture_audio.py`
  - `gate_script` 시그니처·루프 (약 423~446행)
  - `run_gate` (약 463~465행)
  - gate 서브파서 `ga` (약 1006~1009행)
  - `_self_test()` gate 블록 뒤 (약 952행)

**Interfaces:**
- Consumes (Task 1에서):
  - `check_token_preservation(source, target, lexicon) -> tuple[list[str], list[str]]`
  - 기존 `load_lexicon(path) -> dict`(258행, `path=None`이면 `tool/lexicon.json`, 미존재 시 `{}`).
- Produces:
  - `gate_script(script: dict, lexicon: dict | None = None) -> tuple` — `lexicon`이 truthy일 때만 비-skip seg에서 토큰 검사. hard/soft 항목은 `f"{sid}: {msg}"` 형식.

- [ ] **Step 1: 실패하는 self-test 추가**

`_self_test()`의 Task 6 gate 블록 마지막 단언(`assert len(gate_audio_meta(bad_meta, None)) == 2, ...`, 약 951행) **바로 뒤**에 아래 블록을 삽입한다:

```python
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
```

- [ ] **Step 2: 실패 확인**

Run: `cd flutter_app && py tool/gen_lecture_audio.py --self-test`
Expected: FAIL — `gate_script() takes 1 positional argument but 2 were given` (또는 약어 누락 미검출 AssertionError)

- [ ] **Step 3: `gate_script` 시그니처·루프 수정**

`def gate_script(script: dict) -> tuple:`(423행)를 아래로 바꾼다:

```python
def gate_script(script: dict, lexicon: dict | None = None) -> tuple:
```

그리고 루프 내 `for iss in seg.get("issues", []):` 블록(443~445행, soft 누적) **다음**, `return hard, soft` **앞**에 아래를 추가한다:

```python
        if lexicon and not seg.get("skip"):                  # ④ 원문 토큰 보존
            target = (seg.get("audioSummary") if seg.get("kind") == "table"
                      else seg.get("scriptText")) or ""
            source = seg.get("sourceExcerpt") or ""
            if source and target:
                th, ts = check_token_preservation(source, target, lexicon)
                hard += [f"{sid}: {m}" for m in th]
                soft += [f"{sid}: {m}" for m in ts]
```

- [ ] **Step 4: `run_gate` lexicon 로드 연결**

`run_gate`(463행)에서 다음 줄을:

```python
    script = json.loads(args.script.read_text(encoding="utf-8"))
    hard, soft = gate_script(script)
```

아래로 바꾼다:

```python
    script = json.loads(args.script.read_text(encoding="utf-8"))
    lex = load_lexicon(args.lexicon)
    if not lex:
        print("  (lexicon 없음 — 토큰 보존 검사 skip)", file=sys.stderr)
    hard, soft = gate_script(script, lex)
```

- [ ] **Step 5: gate 서브파서에 `--lexicon` 추가**

gate 서브파서 블록(1006~1009행)의 `ga.add_argument("--audio-meta", type=Path)` **다음 줄**에 추가한다:

```python
    ga.add_argument("--lexicon", type=Path)
```

- [ ] **Step 6: 통과 확인**

Run: `cd flutter_app && py tool/gen_lecture_audio.py --self-test`
Expected: PASS — `[self-test] gate 토큰 통합 OK` 출력, 마지막 `self-test OK`

- [ ] **Step 7: 커밋**

커밋 직전 `git branch --show-current`로 `feat/audio-hallucination-guard` 확인 후:

```bash
git add flutter_app/tool/gen_lecture_audio.py
git commit -m "feat(audio): gate에 토큰 보존 검사 통합 + --lexicon(기본 tool/lexicon.json)"
```

---

## 통합 검증(구현 후, 사용자 몫과 분리)

구현·커밋 완료 후 컨트롤러가 직접 실행해 확인한다(에이전트 보고 신뢰 금지):

```bash
cd flutter_app
py tool/gen_lecture_audio.py --self-test          # 전체 그린(self-test OK)
git log --oneline -3                               # 커밋 2개·브랜치 범위 확인
git diff --stat 20dab3f..HEAD                      # gen_lecture_audio.py만 변경됐는지
```

- `flutter analyze`/`flutter test`는 **불필요**(Dart 무변경, 도구만 수정). 단, PR 전 `git status`로 의도치 않은 파일(다른 세션의 clf untracked)이 스테이징되지 않았는지 확인.
- **19문서 실제 gate 재실행으로 기존 약어 누락 발견·보완은 사용자 몫**(spec "기존 19문서 영향"). 본 계획 범위 아님.

## Self-Review (작성자 점검 결과)

1. **Spec coverage:** 컴포넌트 1(순수 함수)=Task 1; 컴포넌트 2(gate 통합)=Task 2 Step 3; 컴포넌트 3(`--lexicon` 로드)=Task 2 Step 4·5. 검출 규칙(약어 hard/수치 soft, seg별, table=audioSummary)·테스트 전략(self-test)·비목표 모두 반영.
2. **Placeholder scan:** 모든 코드 step에 실제 코드·정확한 명령·기대 출력 명시. TBD/TODO 없음.
3. **Type consistency:** `check_token_preservation(source,target,lexicon)->(hard,soft)`가 Task 1 정의와 Task 2 호출에서 일치. `gate_script(script, lexicon=None)` 기본값이 기존 무인자 호출(934행·Task2 hard_n)과 호환. `load_lexicon`/`_lexicon_say_forms`/`_NUM_RE` 명칭 일관.
