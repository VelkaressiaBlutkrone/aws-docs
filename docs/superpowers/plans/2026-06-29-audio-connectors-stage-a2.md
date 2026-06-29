# 오디오 대본 연결 조직 (Stage A2) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** CLF 오디오 대본에 강의 흐름을 위한 **결정적 회전 템플릿** 연결 멘트(도입 1 + 앵커 섹션 전환 N + 마무리 1)를 삽입한다(19문서). 데이터 계약(chapters fraction)·앱 무변경.

**Architecture:** josa 헬퍼(받침 계산)와 회전 템플릿으로 연결문을 만드는 순수 함수 `insert_connectors(segments, title)`가 새 `kind:"connector"` 세그먼트를 삽입한다(`sourceExcerpt=""` → gate 토큰검사 스킵, 평문 → 기호/URL 규칙 통과, 순수 네비게이션 → 사실 무첨가). 신규 `connectors` 서브커맨드가 기존 script.json에 적용(A1 `descaffold`와 동일 구조). 적용 후 19문서 재합성 → 청취 → reviewStatus flip.

**Tech Stack:** Python 3(`py` 런처), `gen_lecture_audio.py`, Amazon Polly(Seoyeon neural), ffprobe+ffmpeg(재합성).

## Global Constraints

- 모든 명령은 `flutter_app/` 디렉터리 기준. Windows는 `py` 런처.
- 도구 검증: `py tool/gen_lecture_audio.py --self-test`(현재 "self-test OK"가 기준선).
- TDD: 새 동작은 `--self-test`에 실패 assert 먼저 → 구현으로 통과(절대조건 2).
- 커밋 직전 `git branch --show-current`로 `feat/audio-connectors-stage-a` 확인(공유 워킹트리 §5).
- 재합성엔 ffprobe+ffmpeg 설치 필수. PATH: `C:/Users/deepe/AppData/Local/Microsoft/WinGet/Packages/Gyan.FFmpeg_*/ffmpeg-*/bin`.
- **재승인은 변경 음성 → 청취 후 flip**: A2는 들리는 음성을 바꾸므로 표본(≥3문서) 청취 후 reviewStatus를 approved로 flip.
- 다른 세션 untracked 파일(`assets/audio/clf/_*`, `clf-t1-1/review_notes.*`) **절대 git add 금지**.
- **삽입문 불변식**: 순수 네비게이션(사실주장 금지) · 평문(기호 `→≠↓§|`·URL·`](` 금지) · josa 정확.

**검증된 통합점(코드 확인):**
- `gate_script`(L473-504): kind 화이트리스트 없음. `source==""`면 토큰보존 검사 스킵(L500 `if source and target`). table/source 규칙은 해당 kind만. → `kind:"connector"`+`sourceExcerpt:""` 안전.
- `script_to_speech`(L411)·`_segment_speech`: 비-table·비-skip·scriptText면 발화. connector 발화됨.
- `split_sections`: 앵커 heading만 경계. connector(비-heading)는 직전 섹션에 포함 → 앵커 경계·chapters 불변.

---

### Task 1: josa 헬퍼 (순수)

**Files:**
- Modify: `flutter_app/tool/gen_lecture_audio.py` (헬퍼 추가 + self-test assert)

**Interfaces:**
- Produces: `_josa_eul(word: str) -> str`("을"/"를"), `_josa_ro(word: str) -> str`("으로"/"로"). 마지막 Hangul 음절 받침으로 결정. 비-Hangul 끝이면 받침 없음 취급("를"/"로").

- [ ] **Step 1: 실패 self-test 추가**

`main()` self-test 블록의 `print("self-test OK")` 바로 위에 추가:
```python
    # Stage A2: josa 헬퍼(순수)
    assert _josa_eul("이점") == "을", _josa_eul("이점")      # 점 받침 ㅁ
    assert _josa_eul("핵심 개념") == "을"                    # 념 받침 ㅁ
    assert _josa_eul("인프라") == "를"                       # 라 받침 없음
    assert _josa_eul("AWS") == "를"                          # 비-Hangul 끝
    assert _josa_ro("이점") == "으로"                        # 받침 ㅁ(≠0,≠8)
    assert _josa_ro("인프라") == "로"                        # 받침 없음
    assert _josa_ro("서울") == "로"                          # 받침 ㄹ(=8)
```

- [ ] **Step 2: self-test 실패 확인**

Run: `py tool/gen_lecture_audio.py --self-test`
Expected: `NameError: name '_josa_eul' is not defined`.

- [ ] **Step 3: 헬퍼 구현**

`mark_scaffolding`(L775 근처) 아래에 추가:
```python
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
```

- [ ] **Step 4: self-test 통과 확인**

Run: `py tool/gen_lecture_audio.py --self-test`
Expected: `self-test OK`.

- [ ] **Step 5: 커밋**

```bash
git add flutter_app/tool/gen_lecture_audio.py
git commit -m "feat(audio): josa 헬퍼(_josa_eul·_josa_ro 받침 계산) 순수 함수"
```

---

### Task 2: `insert_connectors` (순수)

**Files:**
- Modify: `flutter_app/tool/gen_lecture_audio.py` (템플릿 헬퍼 + insert_connectors + self-test)

**Interfaces:**
- Consumes: `_josa_eul`, `_josa_ro`(Task 1).
- Produces: `insert_connectors(segments: list[dict], title: str) -> int` — segments를 in-place 수정(연결 세그먼트 삽입), 삽입 수 반환. 멱등(이미 connector 있으면 0). 삽입 세그먼트: `{id:"conNNN", kind:"connector", sourceExcerpt:"", scriptText:<문구>, audioSummary:None, skip:False, issues:[]}`.

- [ ] **Step 1: 실패 self-test 추가**

self-test 블록에서 Task 1 assert 다음, `print("self-test OK")` 앞에 추가:
```python
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
```

- [ ] **Step 2: self-test 실패 확인**

Run: `py tool/gen_lecture_audio.py --self-test`
Expected: `NameError: name 'insert_connectors' is not defined`.

- [ ] **Step 3: 구현**

Task 1 헬퍼 아래에 추가:
```python
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
            out.append(_mk_connector(cnt, _transition_text(s.get("scriptText") or "", anchor_n)))
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
```

- [ ] **Step 4: self-test 통과 확인**

Run: `py tool/gen_lecture_audio.py --self-test`
Expected: `self-test OK`.

- [ ] **Step 5: 커밋**

```bash
git add flutter_app/tool/gen_lecture_audio.py
git commit -m "feat(audio): insert_connectors(도입·앵커전환·마무리 회전템플릿) 순수 함수"
```

---

### Task 3: `connectors` 서브커맨드

**Files:**
- Modify: `flutter_app/tool/gen_lecture_audio.py` (run_connectors + 서브파서 배선 + self-test)

**Interfaces:**
- Consumes: `insert_connectors`(Task 2), 기존 `write_json`.
- Produces: `run_connectors(args)` — `args.script` script.json에 insert_connectors 적용(title=첫 heading scriptText), 삽입 있으면 top-level `reviewStatus="needs_human_review"`. CLI: `connectors --script <path>`.

- [ ] **Step 1: 실패 self-test 추가**

self-test 블록에서 Task 2 assert 다음, `print("self-test OK")` 앞에 추가:
```python
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
```

- [ ] **Step 2: self-test 실패 확인**

Run: `py tool/gen_lecture_audio.py --self-test`
Expected: `NameError: name 'run_connectors' is not defined`.

- [ ] **Step 3: run_connectors 구현**

`run_descaffold` 아래에 추가:
```python
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
```

- [ ] **Step 4: 서브파서 배선**

`main()`의 `de = sub.add_parser("descaffold", …)` 블록 다음에 추가:
```python
    co = sub.add_parser("connectors",
                        help="강의 연결문(도입·전환·마무리) 삽입")
    co.add_argument("--script", type=Path, required=True)
```
dispatch에서 `elif args.cmd == "descaffold":` 블록 다음에 추가:
```python
    elif args.cmd == "connectors":
        run_connectors(args)
```
`ap.error(...)` 메시지를 갱신:
```python
        ap.error("서브커맨드(generate/synthesize/gate/chapters/descaffold/connectors) 또는 --self-test 가 필요합니다.")
```

- [ ] **Step 5: self-test 통과 확인**

Run: `py tool/gen_lecture_audio.py --self-test`
Expected: `self-test OK`.

- [ ] **Step 6: 커밋**

```bash
git add flutter_app/tool/gen_lecture_audio.py
git commit -m "feat(audio): connectors 서브커맨드(기존 script.json에 연결문 삽입)"
```

---

### Task 4: 19문서 적용·재합성·재승인 (운영)

**Files:**
- Modify(생성물): `flutter_app/assets/audio/clf/clf-*/script.json`(connector 세그먼트·reviewStatus), `clf-*/lecture.mp3`, `clf-*/audio_meta.json`(전 19문서).

**전제:** ffprobe+ffmpeg PATH, AWS 자격(`~/.aws`), 브랜치=`feat/audio-connectors-stage-a`.

- [ ] **Step 1: 19문서 connectors 적용**

```bash
cd flutter_app
for d in assets/audio/clf/clf-*/; do
  PYTHONIOENCODING=utf-8 py tool/gen_lecture_audio.py connectors --script "${d}script.json"
done
```
Expected: 각 문서 `[connectors] N개 연결문 삽입`(N = 도입1 + 앵커수 + 마무리1).

- [ ] **Step 2: 무비용 검증(연결문 존재·스캐폴딩 0·기호 0)**

```bash
PYTHONIOENCODING=utf-8 py - <<'PY'
import json, glob, os, importlib.util
spec = importlib.util.spec_from_file_location("gen", "tool/gen_lecture_audio.py")
gen = importlib.util.module_from_spec(spec); spec.loader.exec_module(gen)
bad = []
for p in sorted(glob.glob('assets/audio/clf/clf-*/script.json')):
    s = json.load(open(p, encoding='utf-8')); d = os.path.basename(os.path.dirname(p))
    sp = gen.script_to_speech(s)
    if not any(x in sp for x in ("살펴보겠습니다", "넘어가겠습니다", "입니다", "보겠습니다")):
        bad.append(f"{d}: 연결문 없음")
    for sc in ("커버하는 공식 Task", "학습 목표 체크리스트"):
        if sc in sp: bad.append(f"{d}: 스캐폴딩 {sc} 재등장")
    for sym in ("→", "≠", "↓", "§", "|"):
        if sym in sp: bad.append(f"{d}: 기호 {sym}")
print("이상:", bad if bad else "없음 — 19문서 연결문 존재·스캐폴딩0·기호0")
PY
```
Expected: `없음`.

- [ ] **Step 3: 19문서 재합성**

```bash
export PATH="<ffmpeg bin>:$PATH"; export PYTHONIOENCODING=utf-8
for d in assets/audio/clf/clf-*/; do
  py tool/gen_lecture_audio.py synthesize --script "${d}script.json" --out "${d}lecture.mp3"
done
```
Expected: 각 `[완료]`, loudnorm OK, ID3 1개. (백그라운드 권장.)

- [ ] **Step 4: 전수 gate**

```bash
export PATH="<ffmpeg bin>:$PATH"
pass=0; for d in assets/audio/clf/clf-*/; do
  py tool/gen_lecture_audio.py gate --script "${d}script.json" --audio-meta "${d}audio_meta.json" --lexicon tool/lexicon.json 2>&1 | grep -q PASS && pass=$((pass+1)) || echo "FAIL ${d}"
done; echo "gate PASS=$pass/19"
```
Expected: `gate PASS=19/19`.

- [ ] **Step 5: 표본 청취**

clf-t1-1·clf-t2-1·clf-t3-1(≥3문서) 재생: 도입("이번 강의에서는…"/"짚어 보겠습니다")·전환("다음으로 …")·마무리("수고하셨습니다" 등)이 자연스럽게 들리고 josa가 맞는지, 스캐폴딩 낭독 없음 확인.
Expected: 연결문 자연스러움·josa 정확·스캐폴딩 0. (이상 시 멈추고 원인 분석.)

- [ ] **Step 6: reviewStatus 재승인 flip(19문서)**

청취 통과 후에만. 기존 헬퍼 재사용:
```bash
FLIP="C:/Users/deepe/AppData/Local/Temp/.../reapprove_audio_meta.py"
for d in assets/audio/clf/clf-*/; do
  py "$FLIP" "${d}audio_meta.json" "${d}script.json"
done
```
Expected: 각 문서 audio_meta(top+script)·script.json reviewStatus=approved.
(헬퍼 부재 시: 두 파일 top-level `reviewStatus`와 audio_meta의 `script.reviewStatus`를 `"approved"`로 set, write_json 포맷 유지.)

- [ ] **Step 7: 테스트·분석·빌드 게이트**

```bash
flutter test 2>&1 | tail -3        # 776+ 그린(동기화 테스트 포함)
flutter analyze 2>&1 | tail -5     # 신규 0(기존 잔존 3)
```
PowerShell web 빌드: `flutter build web --release --base-href /aws-docs/ --dart-define=audio_lecture=true`
Expected: test 그린, analyze 신규 0, web 빌드 성공.

- [ ] **Step 8: 커밋(다른 세션 untracked 제외)**

```bash
git branch --show-current   # 의도 브랜치 확인
git add flutter_app/assets/audio/clf/clf-*/script.json flutter_app/assets/audio/clf/clf-*/audio_meta.json flutter_app/assets/audio/clf/clf-*/lecture.mp3
git diff --cached --name-only | grep -cE "_apply_review|_corpus_scan|review_notes"   # 0
git commit -m "feat(audio): CLF 19문서 강의 연결문(도입·전환·마무리) 삽입 재합성"
```

- [ ] **Step 9: develop PR**

REQUIRED SUB-SKILL: `superpowers:finishing-a-development-branch` → 옵션 2(Push + develop PR).

---

## Self-Review

**1. Spec coverage:**
- josa 헬퍼 → Task 1. ✓
- insert_connectors(도입·앵커전환·마무리·회전·삽입세그먼트 sourceExcerpt""·멱등) → Task 2. ✓
- connectors 서브커맨드(reviewStatus 강등) → Task 3. ✓
- 19문서 적용·재합성·재승인 → Task 4. ✓
- 삽입문 불변식(네비게이션·평문·josa) → Task 2 템플릿(사실 무첨가·기호 없음) + Global Constraints + Task 4 Step2 기호 검증. ✓
- gate 안전(connector+빈source) → Global Constraints 검증된 통합점(L500). ✓
- chapters/앱 무변경 → connector 비앵커 → split_sections 경계 불변. ✓
- ffprobe+ffmpeg·청취후flip → Global Constraints + Task 4. ✓

**2. Placeholder scan:** 모든 스텝 실제 코드·명령. Task 4 FLIP 경로만 환경의존(대체 지침 병기). TODO/TBD 없음. ✓

**3. Type consistency:** `_josa_eul/_josa_ro(str)->str`(T1 정의·T2 사용 일치). `insert_connectors(segments,title)->int`(T2 정의·T3 호출 일치). `run_connectors(args)` args.script(Path). connector 세그먼트 dict 키(id/kind/sourceExcerpt/scriptText/audioSummary/skip/issues) 실제 스키마 일치. ✓

## 범위 / 비목표

- 범위: josa 헬퍼·insert_connectors·connectors 서브커맨드 + self-test + 19문서 재합성·재승인. **Dart/앱 무변경.**
- 비목표(YAGNI): LLM 연결문 · 비앵커 헤딩 전환 · 본문 재저작(Stage B) · 마커 탈출구.

## 정본·관련

- 설계: `docs/superpowers/specs/2026-06-29-audio-connectors-stage-a2-design.md`(APPROVED)
- 선행: A1 [[audio-instructor-script-planned]] · 코드 `flutter_app/tool/gen_lecture_audio.py`(`script_to_speech`·gate_script L473·`split_sections`·`descaffold`·`mark_scaffolding`)
- 재합성·재승인: [[audio-section-timestamps-shipped]]
