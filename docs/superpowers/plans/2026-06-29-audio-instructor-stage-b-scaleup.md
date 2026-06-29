# 오디오 LLM 재강의 확대 (Stage B 도구화: enrich/verify + 신규필드) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** clf-t1-1 파일럿(세션 수작업)을 재현·일괄화하는 인프라를 만든다 — 풍부화본을 `enrichedScriptText` 신규필드로 분리 저장하고, `enrich`(Claude API)·`verify`(LLM 사실대조) 서브커맨드를 추가하며, clf-t1-1을 신규필드로 마이그레이션한다.

**Architecture:** `gen_lecture_audio.py`에 발화소스 우선순위(enriched 우선)를 단일 헬퍼로 일원화하고, 그 위에 enrich/verify 서브커맨드를 기존 argparse 패턴으로 얹는다. API 호출은 boto3처럼 함수 내부 지연 import라 도구의 결정적 `--self-test`는 네트워크를 타지 않는다(순수 함수만 검증). 세그먼트 경계·앵커 불변이라 chapters/split_sections/앱/테스트는 무변경.

**Tech Stack:** Python `gen_lecture_audio.py`(argparse 서브커맨드 + `--self-test`), `anthropic` SDK(신규 의존성, `ANTHROPIC_API_KEY` env), Amazon Polly(기존), Flutter test/analyze(앱 회귀).

## Global Constraints

- 모든 명령은 `flutter_app/` 기준. Windows `py` 런처. `PYTHONIOENCODING=utf-8`.
- 도구 검증의 SSOT는 `py tool/gen_lecture_audio.py --self-test`다(Python 단위테스트 파일 없음). **신규 로직은 `_self_test()`에 케이스를 먼저 추가해 실패를 확인한 뒤 구현**(절대조건 2 Test-First의 이 레포 형태).
- **`--self-test`는 결정적·네트워크 없음을 유지한다.** enrich/verify의 Claude API 호출은 self-test에서 절대 호출하지 않는다(순수 함수 — 대상 필터·머지·파싱·발화소스·리포트만 검증). API 래퍼는 함수 내부 지연 `import anthropic`(기존 `_synthesize_chunks_to_bytes`의 `import boto3` 패턴).
- 발화소스 규칙(이 작업의 핵심 불변식): table → `audioSummary`, 그 외 비-skip → `enrichedScriptText` 있으면 그것, 없으면 `scriptText`. `enrichedScriptText`는 선택 필드(없으면 기존과 100% 동일 동작 = 하위호환).
- 모델 ID: 풍부화·검증 기본 `claude-opus-4-8`(Opus 4.8). `--model`로 교체(예 풍부화만 `claude-sonnet-4-6`).
- 앱/Dart 무변경. 변경은 `flutter_app/tool/gen_lecture_audio.py`와 `clf-t1-1` 산출물(`script.json`)뿐. 마이그레이션 스크립트는 `flutter_app/assets/audio/clf/` 보조 `.py`(일회성, repo 등록 금지).
- 다른 세션 untracked 파일(`_apply_review.py`·`_corpus_scan_report.md`·`review_notes.*` 등) 절대 `git add` 금지.
- 커밋 직전 항상 `git branch --show-current`로 `feat/audio-instructor-pilot-stage-b` 확인(공유 워킹트리 — CLAUDE.md §5).

---

### Task 1: enrichedScriptText 발화 우선순위 일원화

발화소스 결정이 세 곳(`_segment_speech` L722·`script_to_speech` L411·`gate_script` L479/L497)에 중복돼 있다. 단일 헬퍼 `_spoken_body`로 DRY 처리하고 enriched 우선순위를 도입한다. 이 Task만으로 "enrichedScriptText가 있으면 발화·게이트가 그것을 기준으로 한다"가 완성된다(아직 그 필드를 만드는 도구는 없음 — Task 2).

**Files:**
- Modify: `flutter_app/tool/gen_lecture_audio.py` (`_spoken_body` 신규, `_segment_speech`·`script_to_speech`·`gate_script` 수정, `_self_test` 케이스 추가)

**Interfaces:**
- Produces:
  - `_spoken_body(seg: dict) -> str` — table 외 세그먼트 발화 본문: `seg.get("enrichedScriptText") or seg.get("scriptText") or ""`.
  - `_segment_speech(seg)`·`script_to_speech(script)`·`gate_script(script, lexicon)` 시그니처 불변, 동작만 enriched 우선으로 확장.

- [ ] **Step 1: 실패 케이스를 `_self_test()`에 먼저 추가**

`_self_test()`의 청크 검증 줄(`chunks = chunk_text(...)`) **바로 앞**에 삽입:

```python
    # --- Stage B: enrichedScriptText 발화 우선순위 ---
    assert _spoken_body({"scriptText": "원문", "enrichedScriptText": "강의본"}) == "강의본"
    assert _spoken_body({"scriptText": "원문"}) == "원문"
    assert _spoken_body({}) == ""
    assert _segment_speech({"kind": "paragraph", "scriptText": "원문",
                            "enrichedScriptText": "강의본"}) == "강의본"
    assert _segment_speech({"kind": "paragraph", "scriptText": "원문"}) == "원문"
    assert _segment_speech({"kind": "table", "audioSummary": "요약",
                            "enrichedScriptText": "무시"}) == "요약"
    assert _segment_speech({"kind": "paragraph", "scriptText": "원문",
                            "enrichedScriptText": "강의본", "skip": True}) == ""
    _sts = script_to_speech({"segments": [
        {"kind": "paragraph", "scriptText": "원문", "enrichedScriptText": "강의본"},
        {"kind": "table", "audioSummary": "표요약"},
    ]})
    assert _sts == "강의본\n표요약", _sts
    # gate: enriched 기준 토큰보존(원문 약어가 enriched에 없으면 hard)
    _gh, _gs = gate_script(
        {"segments": [{"id": "s1", "kind": "paragraph",
                       "sourceExcerpt": "EC2를 제공합니다",
                       "scriptText": "이씨투를 제공합니다",
                       "enrichedScriptText": "이것을 제공합니다"}]},
        {"EC2": {"say": "이씨투"}})
    assert any("EC2" in h for h in _gh), _gh
```

- [ ] **Step 2: self-test 실패 확인**

Run: `cd flutter_app && PYTHONIOENCODING=utf-8 py tool/gen_lecture_audio.py --self-test`
Expected: FAIL — `NameError: name '_spoken_body' is not defined` (또는 enriched 무시로 AssertionError).

- [ ] **Step 3: `_spoken_body` 헬퍼 추가**

`_segment_speech`(L722) 정의 **바로 앞**에 삽입:

```python
def _spoken_body(seg: dict) -> str:
    """table 외 세그먼트의 발화 본문: enrichedScriptText 우선, 없으면 scriptText."""
    return seg.get("enrichedScriptText") or seg.get("scriptText") or ""
```

- [ ] **Step 4: `_segment_speech` 수정**

L726-727의 `else seg.get("scriptText")`를 `_spoken_body(seg)`로:

```python
def _segment_speech(seg: dict) -> str:
    """세그먼트의 발음 텍스트(table=audioSummary, 그 외 enriched|scriptText)."""
    if seg.get("skip"):
        return ""
    text = (seg.get("audioSummary") if seg.get("kind") == "table"
            else _spoken_body(seg)) or ""
    return text.strip()
```

- [ ] **Step 5: `script_to_speech` 수정**

L417-421의 table/elif 블록을 교체:

```python
        if s["kind"] == "table":
            if s.get("audioSummary"):
                parts.append(s["audioSummary"])
        else:
            body = _spoken_body(s)
            if body:
                parts.append(body)
```

- [ ] **Step 6: `gate_script` 발화소스 반영**

L478-479의 `txt` 계산과 L497-499의 `target` 계산을 발화소스 기준으로:

```python
        sid = seg.get("id", "?")
        body = _spoken_body(seg)
        txt = body + " " + (seg.get("audioSummary") or "")
```
그리고 토큰보존 블록(L497-499):
```python
            target = (seg.get("audioSummary") if seg.get("kind") == "table"
                      else body) or ""
```

- [ ] **Step 7: self-test 통과 확인**

Run: `cd flutter_app && PYTHONIOENCODING=utf-8 py tool/gen_lecture_audio.py --self-test`
Expected: PASS (모든 assert 통과, 기존 케이스 회귀 없음).

- [ ] **Step 8: 기존 19문서 발화 무변 확인(하위호환)**

Run:
```bash
cd flutter_app
PYTHONIOENCODING=utf-8 py tool/gen_lecture_audio.py gate --script assets/audio/clf/clf-t1-1/script.json --lexicon tool/lexicon.json 2>&1 | tail -1
```
Expected: `[gate] PASS` — clf-t1-1엔 아직 enrichedScriptText가 없어(현재 scriptText=풍부화본) 동작 불변.

- [ ] **Step 9: 커밋**

```bash
git branch --show-current   # feat/audio-instructor-pilot-stage-b 확인
git add flutter_app/tool/gen_lecture_audio.py
git commit -m "feat(audio): enrichedScriptText 발화 우선순위 일원화(_spoken_body)"
```

---

### Task 2: `enrich` 서브커맨드 (Claude API 풍부화)

대상 세그먼트를 Claude API로 풍부화해 `enrichedScriptText`에 머지한다. 순수 함수(대상 필터·머지·리포트)는 self-test로 검증하고, API 호출만 지연 import 래퍼로 분리한다.

**Files:**
- Modify: `flutter_app/tool/gen_lecture_audio.py` (`ENRICH_SYSTEM` 상수, `enrich_targets`·`build_enrich_user`·`merge_enriched`·`enrich_report`·`call_claude_text`·`run_enrich` 신규, argparse 등록, `_self_test` 케이스)

**Interfaces:**
- Consumes: `apply_lexicon(text, lexicon, seen)`(L270), `load_lexicon(path)`(L258), `_spoken_body`(Task 1).
- Produces:
  - `enrich_targets(script: dict) -> list[dict]` — `not skip and kind not in {heading,connector,table} and scriptText`인 세그먼트.
  - `merge_enriched(script: dict, results: dict[str,str], lexicon: dict) -> int` — `results[seg_id]`를 `apply_lexicon` 발음치환 후 `enrichedScriptText`에 머지, 머지 수 반환. top-level은 건드리지 않음(호출부가 reviewStatus 설정).
  - `enrich_report(script: dict, results: dict[str,str]) -> str` — 풍부화 수·비유 후보·신규 영문 토큰·청취 권장 대상 마크다운.
  - `call_claude_text(system: str, user: str, model: str) -> str` — Claude API 1회 호출 → 텍스트.
  - `run_enrich(args)` — `--script/--model/--only/--dry-run` 처리.

- [ ] **Step 1: 실패 케이스를 `_self_test()`에 추가**

Task 1 케이스 블록 다음에 삽입:

```python
    # --- Stage B: enrich 순수 함수 ---
    _escript = {"segments": [
        {"id": "h", "kind": "heading", "scriptText": "제목"},
        {"id": "p1", "kind": "paragraph", "scriptText": "본문1", "sourceExcerpt": "x"},
        {"id": "c", "kind": "connector", "scriptText": "전환"},
        {"id": "t", "kind": "table", "scriptText": "", "audioSummary": "요약"},
        {"id": "s", "kind": "paragraph", "scriptText": "스킵", "skip": True},
        {"id": "p2", "kind": "list", "scriptText": "본문2", "sourceExcerpt": "y"},
    ]}
    assert [s["id"] for s in enrich_targets(_escript)] == ["p1", "p2"], \
        [s["id"] for s in enrich_targets(_escript)]
    _mn = merge_enriched(_escript, {"p1": "AWS 강의입니다"}, {"AWS": {"say": "에이더블유에스"}})
    _p1 = next(s for s in _escript["segments"] if s["id"] == "p1")
    assert _mn == 1 and _p1["enrichedScriptText"] == "에이더블유에스 강의입니다", _p1
    assert "에이더블유에스 강의입니다" in enrich_report(_escript, {"p1": "에이더블유에스 강의입니다"})
```

- [ ] **Step 2: self-test 실패 확인**

Run: `cd flutter_app && PYTHONIOENCODING=utf-8 py tool/gen_lecture_audio.py --self-test`
Expected: FAIL — `NameError: name 'enrich_targets' is not defined`.

- [ ] **Step 3: `ENRICH_SYSTEM` 상수 + 순수 함수 구현**

`run_connectors`(L564) 정의 **뒤**에 추가:

```python
ENRICH_SYSTEM = (
    "당신은 AWS 자격증 강의 대본을 다듬는 한국어 강사입니다. 주어진 세그먼트의 "
    "현재 대본을 더 '강의처럼' 풀어 씁니다. 규칙:\n"
    "(a) 합니다체 대화체로 자연스럽게.\n"
    "(b) 이해를 돕는 짧은 비유나 예시를 1개만, 자연스러운 곳에만 넣습니다. "
    "억지로 모든 세그먼트에 넣지 마십시오.\n"
    "(c) 원문(sourceExcerpt)의 약어·수치·핵심 주장을 반드시 보존합니다.\n"
    "(d) 원문에 없는 새로운 시험 사실을 단정하지 마십시오. 비유는 설명용 예시일 "
    "뿐이며 새 사실을 만들지 않습니다.\n"
    "(e) 평문만 씁니다. 기호(→ ≠ ↓ § |)·URL·마크다운·괄호 부연 남발 금지. "
    "원문 길이의 약 2배 이내.\n"
    "(f) 영문 약어는 한글 발음으로 적습니다(예: AWS→에이더블유에스, EC2→이씨투).\n"
    "출력은 풍부화된 대본 텍스트만. 설명·머리말·따옴표 없이 본문만 반환합니다."
)


def build_enrich_user(seg: dict) -> str:
    return (f"[원문 sourceExcerpt]\n{seg.get('sourceExcerpt', '')}\n\n"
            f"[현재 대본 scriptText]\n{seg.get('scriptText', '')}\n\n"
            f"위 세그먼트를 규칙대로 풍부화한 대본만 반환하세요.")


def enrich_targets(script: dict) -> list:
    return [s for s in script["segments"]
            if not s.get("skip")
            and s.get("kind") not in ("heading", "connector", "table")
            and s.get("scriptText")]


def merge_enriched(script: dict, results: dict, lexicon: dict) -> int:
    seen: set = set()
    n = 0
    for s in script["segments"]:
        if s["id"] in results and results[s["id"]].strip():
            text, li = apply_lexicon(results[s["id"]].strip(), lexicon, seen)
            s["enrichedScriptText"] = text
            s["issues"] = list(dict.fromkeys(s.get("issues", []) + li))
            n += 1
    return n


def enrich_report(script: dict, results: dict) -> str:
    lines = [f"# enrich 리포트 — {script.get('docId', '?')}", "",
             f"풍부화 세그먼트: {len(results)}개", "",
             "## 사람 청취 권장 대상(비유/예시·신규 영문 의심)", ""]
    for s in script["segments"]:
        if s["id"] not in results:
            continue
        body = results[s["id"]]
        toks = sorted(set(re.findall(r"(?<![0-9A-Za-z])[A-Z][A-Z0-9]{1,}(?![0-9A-Za-z])", body)))
        hint = []
        if any(w in body for w in ("마치", "처럼", "비유하자면", "예를 들")):
            hint.append("비유/예시")
        if toks:
            hint.append("영문잔재:" + ",".join(toks))
        if hint:
            lines.append(f"- {s['id']}: {' · '.join(hint)}")
    lines.append("")
    lines.append("## Before/After")
    for s in script["segments"]:
        if s["id"] in results:
            lines += [f"### {s['id']}", f"- before: {s.get('scriptText','')}",
                      f"- after: {results[s['id']]}", ""]
    return "\n".join(lines).rstrip() + "\n"


def call_claude_text(system: str, user: str, model: str) -> str:
    import anthropic  # 지연 import(네트워크 — self-test 미호출)
    client = anthropic.Anthropic()  # ANTHROPIC_API_KEY env
    resp = client.messages.create(
        model=model, max_tokens=2000, system=system,
        messages=[{"role": "user", "content": user}])
    return "".join(b.text for b in resp.content if b.type == "text").strip()
```
> 구현자 주의: anthropic SDK의 `messages.create` 형태는 변경될 수 있으니 작성 시 claude-api 스킬 또는 context7로 현행 시그니처를 확인할 것(이 레포 글로벌 규칙).

- [ ] **Step 4: `run_enrich` + argparse 등록**

`run_enrich` 추가(순수 함수 뒤):

```python
def run_enrich(args) -> None:
    script = json.loads(args.script.read_text(encoding="utf-8"))
    lex = load_lexicon(args.lexicon)
    targets = enrich_targets(script)
    only = set(args.only.split(",")) if args.only else None
    if only:
        targets = [s for s in targets if s["id"] in only]
    print(f"[enrich] 대상 {len(targets)}개"
          + (f" (--only {sorted(only)})" if only else ""), file=sys.stderr)
    if args.dry_run:
        for s in targets:
            print(f"  - {s['id']} ({s['kind']})", file=sys.stderr)
        print("[enrich] --dry-run: API 호출 없음", file=sys.stderr)
        return
    results: dict = {}
    for s in targets:
        txt = call_claude_text(ENRICH_SYSTEM, build_enrich_user(s), args.model)
        results[s["id"]] = txt
        print(f"  enriched {s['id']} ({len(txt)}자)", file=sys.stderr)
    n = merge_enriched(script, results, lex)
    script["reviewStatus"] = "needs_human_review"
    write_json(args.script, script)
    report = args.script.parent / "enrich_report.md"
    report.write_text(enrich_report(script, results), encoding="utf-8")
    print(f"[enrich] {n}개 머지 → {args.script} · 리포트 {report}", file=sys.stderr)
```
`main()`의 `co = sub.add_parser("connectors" ...)` 블록 **뒤**에 등록:
```python
    en = sub.add_parser("enrich", help="대상 세그먼트를 Claude API로 풍부화(enrichedScriptText)")
    en.add_argument("--script", type=Path, required=True)
    en.add_argument("--model", default="claude-opus-4-8")
    en.add_argument("--only", help="쉼표구분 seg id만 풍부화(재작업용)")
    en.add_argument("--dry-run", action="store_true", help="API 호출 없이 대상만 출력")
    en.add_argument("--lexicon", type=Path)
```
디스패치(`elif args.cmd == "connectors":` 뒤):
```python
    elif args.cmd == "enrich":
        run_enrich(args)
```
그리고 `ap.error(...)` 메시지의 서브커맨드 목록에 `enrich` 추가.

- [ ] **Step 5: self-test 통과 확인**

Run: `cd flutter_app && PYTHONIOENCODING=utf-8 py tool/gen_lecture_audio.py --self-test`
Expected: PASS.

- [ ] **Step 6: anthropic 의존성 설치 + --dry-run 경로 확인**

```bash
cd flutter_app
py -m pip install anthropic 2>&1 | tail -1
PYTHONIOENCODING=utf-8 py tool/gen_lecture_audio.py enrich --script assets/audio/clf/clf-t1-1/script.json --dry-run 2>&1 | tail -6
```
Expected: clf-t1-1 대상 세그먼트(약 19개) 목록 + `--dry-run: API 호출 없음`. (clf-t1-1은 현재 scriptText=풍부화본이라 대상에 잡히지만, 마이그레이션은 Task 4 — 여기선 경로만 확인.)

- [ ] **Step 7: 커밋**

```bash
git branch --show-current
git add flutter_app/tool/gen_lecture_audio.py
git commit -m "feat(audio): enrich 서브커맨드(Claude API 세그먼트 풍부화·신규필드 머지)"
```

---

### Task 3: `verify` 서브커맨드 (LLM 사실대조)

풍부화본을 원문과 대조해 환각/틀린 비유/토큰 변경을 플래그한다. 파싱은 순수 함수(self-test), API 호출은 Task 2 래퍼 재사용.

**Files:**
- Modify: `flutter_app/tool/gen_lecture_audio.py` (`VERIFY_SYSTEM` 상수, `build_verify_user`·`parse_verify_response`·`run_verify` 신규, argparse 등록, `_self_test` 케이스)

**Interfaces:**
- Consumes: `call_claude_text`(Task 2), `_spoken_body`(Task 1).
- Produces:
  - `parse_verify_response(text: str) -> list[dict]` — `seg\w+ | 유형 | 근거 | 제안` 형식 라인을 `{seg,type,basis,fix}`로. 플래그 라인 없으면 `[]`(=PASS).
  - `run_verify(args)` — `--script/--model`, enriched 세그먼트만 대조, 리포트 + 종료코드(플래그 있으면 non-zero).

- [ ] **Step 1: 실패 케이스를 `_self_test()`에 추가**

Task 2 케이스 뒤에 삽입:

```python
    # --- Stage B: verify 응답 파싱 ---
    assert parse_verify_response("VERDICT: PASS\n근거 없음, 모두 일치") == []
    _vf = parse_verify_response(
        "seg005 | 사실단정 | 원문 미뒷받침 | 삭제 권장\n무관한 줄")
    assert len(_vf) == 1 and _vf[0]["seg"] == "seg005" \
        and _vf[0]["type"] == "사실단정", _vf
```

- [ ] **Step 2: self-test 실패 확인**

Run: `cd flutter_app && PYTHONIOENCODING=utf-8 py tool/gen_lecture_audio.py --self-test`
Expected: FAIL — `NameError: name 'parse_verify_response' is not defined`.

- [ ] **Step 3: 상수 + 순수 함수 + `run_verify` 구현**

Task 2 `run_enrich` 뒤에 추가:

```python
VERIFY_SYSTEM = (
    "당신은 AWS 자격증 콘텐츠 사실검증자입니다. 풍부화된 강의 대본이 검증된 원문에 "
    "충실한지 세그먼트별로 점검합니다. 다음을 플래그하십시오: 원문이 뒷받침하지 않는 "
    "사실 단정(없던 수치·서비스명·인과·'항상/모두' 과일반화), 개념을 오도하는 틀린 비유, "
    "원문 수치·약어의 변경/누락.\n"
    "문제가 있으면 각 줄을 정확히 '세그먼트id | 유형 | 원문 근거 | 제안' 형식으로 "
    "출력하십시오(세그먼트id는 seg로 시작). 문제가 없으면 'PASS'만 출력하십시오."
)

_VERIFY_FLAG_RE = re.compile(r"^\s*(seg\w+)\s*\|")


def build_verify_user(seg: dict) -> str:
    return (f"세그먼트 {seg['id']}\n[검증된 원문 sourceExcerpt]\n"
            f"{seg.get('sourceExcerpt', '')}\n\n[풍부화 대본]\n{_spoken_body(seg)}\n")


def parse_verify_response(text: str) -> list:
    flags = []
    for ln in text.splitlines():
        if _VERIFY_FLAG_RE.match(ln):
            cells = [c.strip() for c in ln.split("|")]
            flags.append({"seg": cells[0],
                          "type": cells[1] if len(cells) > 1 else "",
                          "basis": cells[2] if len(cells) > 2 else "",
                          "fix": cells[3] if len(cells) > 3 else ""})
    return flags


def run_verify(args) -> None:
    script = json.loads(args.script.read_text(encoding="utf-8"))
    targets = [s for s in script["segments"]
               if s.get("enrichedScriptText") and not s.get("skip")]
    print(f"[verify] 대상 {len(targets)}개", file=sys.stderr)
    all_flags = []
    for s in targets:
        resp = call_claude_text(VERIFY_SYSTEM, build_verify_user(s), args.model)
        all_flags += parse_verify_response(resp)
    out = args.script.parent / "enrich_verify.md"
    if all_flags:
        body = "\n".join(f"- {f['seg']} | {f['type']} | {f['basis']} | {f['fix']}"
                         for f in all_flags)
        out.write_text(f"# verify FAIL — {len(all_flags)} flags\n\n{body}\n",
                       encoding="utf-8")
        for f in all_flags:
            print(f"  FLAG {f['seg']} | {f['type']}", file=sys.stderr)
        sys.exit(f"[verify] FAIL — {len(all_flags)} flags → {out}")
    out.write_text("# verify PASS\n\n플래그 없음.\n", encoding="utf-8")
    print(f"[verify] PASS → {out}", file=sys.stderr)
```
argparse 등록(`en = ...enrich` 블록 뒤):
```python
    ve = sub.add_parser("verify", help="풍부화본 사실검증(원문 대조 플래그)")
    ve.add_argument("--script", type=Path, required=True)
    ve.add_argument("--model", default="claude-opus-4-8")
```
디스패치(`elif args.cmd == "enrich":` 뒤):
```python
    elif args.cmd == "verify":
        run_verify(args)
```
`ap.error(...)` 서브커맨드 목록에 `verify` 추가.

- [ ] **Step 4: self-test 통과 확인**

Run: `cd flutter_app && PYTHONIOENCODING=utf-8 py tool/gen_lecture_audio.py --self-test`
Expected: PASS.

- [ ] **Step 5: 커밋**

```bash
git branch --show-current
git add flutter_app/tool/gen_lecture_audio.py
git commit -m "feat(audio): verify 서브커맨드(풍부화본 LLM 사실대조·플래그 게이트)"
```

---

### Task 4: clf-t1-1 마이그레이션 (scriptText 덮어쓰기 → 신규필드)

파일럿이 clf-t1-1의 `scriptText`를 풍부화본으로 덮어썼다. 원문 평문을 git 직전 커밋에서 복원해 `scriptText`로 되돌리고, 풍부화본을 `enrichedScriptText`로 옮긴다. 발화소스가 enriched 우선이라 **음성은 바이트 동일** → 재합성 불필요.

**Files:**
- Create(일회성, repo 등록 금지): `flutter_app/assets/audio/clf/_migrate_t1_1_enriched.py`
- Modify: `flutter_app/assets/audio/clf/clf-t1-1/script.json`

**Interfaces:**
- Consumes: `_segment_speech`(Task 1) — 마이그레이션 전후 발화 동일 검증.
- 풍부화 직전 커밋 = `9deed07^`(커밋 `9deed07`="본문 세그먼트 LLM 풍부화"의 부모).

- [ ] **Step 1: 원문 평문 존재 확인**

```bash
cd flutter_app
git show 9deed07^:flutter_app/assets/audio/clf/clf-t1-1/script.json | PYTHONIOENCODING=utf-8 py -c "import sys,json;d=json.load(sys.stdin);print('segments',len(d['segments']));print([s['id'] for s in d['segments'] if s['kind']=='paragraph'][:3])"
```
Expected: segments 수 출력 + paragraph id 목록(원문 평문 scriptText 보유 확인).

- [ ] **Step 2: 마이그레이션 스크립트 작성**

`flutter_app/assets/audio/clf/_migrate_t1_1_enriched.py`:

```python
# -*- coding: utf-8 -*-
"""일회성: clf-t1-1 풍부화본(scriptText)을 enrichedScriptText로 옮기고
원문 평문 scriptText를 풍부화 직전 커밋(9deed07^)에서 복원한다.
발화소스(enriched 우선)는 불변이라 음성은 동일 — repo 등록 금지."""
import json
import subprocess
import sys
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8")
REL = "flutter_app/assets/audio/clf/clf-t1-1/script.json"
PATH = Path("D:/workspace/awc-docs") / REL
PARENT = "9deed07^"

old = json.loads(subprocess.check_output(
    ["git", "show", f"{PARENT}:{REL}"], cwd="D:/workspace/awc-docs"))
old_text = {s["id"]: (s.get("scriptText") or "") for s in old["segments"]}
cur = json.loads(PATH.read_text(encoding="utf-8"))

moved = 0
for s in cur["segments"]:
    if s.get("skip") or s["kind"] in ("heading", "connector", "table"):
        continue
    enr = s.get("scriptText") or ""
    orig = old_text.get(s["id"], "")
    if orig and enr and orig != enr:
        s["enrichedScriptText"] = enr
        s["scriptText"] = orig
        moved += 1

PATH.write_text(json.dumps(cur, ensure_ascii=False, indent=2) + "\n",
                encoding="utf-8")
print(f"moved {moved} segments → enrichedScriptText (scriptText=원문 복원)")
```

- [ ] **Step 3: 마이그레이션 전 발화 스냅샷**

```bash
cd flutter_app
PYTHONIOENCODING=utf-8 py -c "import json;from tool.gen_lecture_audio import _segment_speech;d=json.load(open('assets/audio/clf/clf-t1-1/script.json',encoding='utf-8'));print('\n'.join(_segment_speech(s) for s in d['segments']))" > "C:/Users/deepe/AppData/Local/Temp/claude/D--workspace-awc-docs/4426b40c-2f20-423a-acf8-0a7fda0752ed/scratchpad/speech_before.txt"
```

- [ ] **Step 4: 마이그레이션 실행 + 발화 동일 검증**

```bash
cd flutter_app
PYTHONIOENCODING=utf-8 py assets/audio/clf/_migrate_t1_1_enriched.py
PYTHONIOENCODING=utf-8 py -c "import json;from tool.gen_lecture_audio import _segment_speech;d=json.load(open('assets/audio/clf/clf-t1-1/script.json',encoding='utf-8'));print('\n'.join(_segment_speech(s) for s in d['segments']))" > "C:/Users/deepe/AppData/Local/Temp/claude/D--workspace-awc-docs/4426b40c-2f20-423a-acf8-0a7fda0752ed/scratchpad/speech_after.txt"
diff "C:/Users/deepe/AppData/Local/Temp/claude/D--workspace-awc-docs/4426b40c-2f20-423a-acf8-0a7fda0752ed/scratchpad/speech_before.txt" "C:/Users/deepe/AppData/Local/Temp/claude/D--workspace-awc-docs/4426b40c-2f20-423a-acf8-0a7fda0752ed/scratchpad/speech_after.txt" && echo "발화 동일 — 음성 무변"
```
Expected: `moved N segments`, diff 없음, `발화 동일 — 음성 무변`. (다르면 절대조건 3: 원인 규명 후 수정.)

- [ ] **Step 5: gate PASS + 신규필드 확인**

```bash
cd flutter_app
PYTHONIOENCODING=utf-8 py tool/gen_lecture_audio.py gate --script assets/audio/clf/clf-t1-1/script.json --lexicon tool/lexicon.json 2>&1 | tail -1
PYTHONIOENCODING=utf-8 py -c "import json;d=json.load(open('assets/audio/clf/clf-t1-1/script.json',encoding='utf-8'));e=[s for s in d['segments'] if s.get('enrichedScriptText')];print('enriched',len(e),'reviewStatus',d.get('reviewStatus'))"
```
Expected: `[gate] PASS`, enriched ≈19, reviewStatus=approved(음성 무변 = 재승인 불필요).

- [ ] **Step 6: 커밋(스크립트 제외, script.json만)**

```bash
git branch --show-current
git add flutter_app/assets/audio/clf/clf-t1-1/script.json
git diff --cached --name-only | grep -E "_migrate|_apply_review|_corpus_scan|review_notes" && echo "STOP: 보조파일 포함됨" || echo "OK: script.json만"
git commit -m "refactor(audio): clf-t1-1 풍부화본을 enrichedScriptText로 분리(원문 scriptText 복원, 음성 무변)"
```
Expected: `OK: script.json만` 후 커밋. (`_migrate_*.py`는 untracked로 남김 — repo 등록 금지.)

---

### Task 5: 통합 게이트 + 실적용 검증

도구 전체가 결정적으로 통과하고 앱이 회귀 없는지 확인한 뒤, enrich를 안전 경로(dry-run 또는 선행작업 끝난 1문서)로 실적용한다.

**Files:** (검증 전용 — 코드 변경 없음)

- [ ] **Step 1: 도구 self-test + clf-t1-1 gate**

```bash
cd flutter_app
PYTHONIOENCODING=utf-8 py tool/gen_lecture_audio.py --self-test 2>&1 | tail -1
PYTHONIOENCODING=utf-8 py tool/gen_lecture_audio.py gate --script assets/audio/clf/clf-t1-1/script.json --audio-meta assets/audio/clf/clf-t1-1/audio_meta.json --lexicon tool/lexicon.json 2>&1 | tail -1
```
Expected: self-test PASS, `[gate] PASS`.

- [ ] **Step 2: enrich/verify 인터페이스 스모크(API 미호출)**

```bash
cd flutter_app
PYTHONIOENCODING=utf-8 py tool/gen_lecture_audio.py enrich --script assets/audio/clf/clf-t1-1/script.json --dry-run 2>&1 | tail -3
PYTHONIOENCODING=utf-8 py tool/gen_lecture_audio.py verify --help 2>&1 | tail -2
```
Expected: enrich dry-run 대상 목록 출력(마이그레이션 후엔 scriptText=원문이므로 대상=원문 세그먼트), verify --help 정상.

- [ ] **Step 3: 실 API 적용(조건부)**

선행작업(발음사전·audioSummary·generate gate 통과)이 끝난 문서가 있으면 그 1문서에:
```bash
cd flutter_app
PYTHONIOENCODING=utf-8 py tool/gen_lecture_audio.py enrich --script assets/audio/clf/<doc>/script.json 2>&1 | tail -4
PYTHONIOENCODING=utf-8 py tool/gen_lecture_audio.py verify --script assets/audio/clf/<doc>/script.json 2>&1 | tail -4
```
Expected: enrich 머지 + 리포트, verify PASS(또는 `--only`로 재작업 후 PASS). **선행작업 끝난 문서가 없으면 이 Step은 skip하고 Step 2의 dry-run으로 경로검증을 갈음**(18문서 선행작업은 본 플랜 비목표 — log로 skip 명시).

- [ ] **Step 4: 앱 회귀 게이트**

```bash
cd flutter_app
flutter test 2>&1 | tail -2
flutter analyze 2>&1 | tail -4
```
Expected: test 그린(enrichedScriptText는 추가 필드 — Dart 스키마/동기화 테스트 무영향), analyze 신규 0(기존 잔존 3건 외).

- [ ] **Step 5: 웹 빌드(PowerShell)**

PowerShell: `flutter build web --release --base-href /aws-docs/ --dart-define=audio_lecture=true`
Expected: 빌드 성공([[flutter-build-web-powershell]] — Git Bash 금지).

- [ ] **Step 6: 마무리 — finishing-a-development-branch**

REQUIRED SUB-SKILL: `superpowers:finishing-a-development-branch` → 옵션 2(develop PR). 브랜치 전략상 `develop` 대상 PR(작업 브랜치 → develop). 다른 세션 untracked 파일 미포함 확인.

---

## Self-Review

**1. Spec coverage:**
- A 신규필드 발화 우선순위 → Task 1. ✓
- B `enrich`(API·프롬프트 상수·머지·--dry-run/--only·리포트) → Task 2. ✓
- C `verify`(LLM 대조·리포트·종료코드) → Task 3. ✓
- D 청취 위험기반 → enrich_report가 청취 권장 대상 산출(Task 2 Step 3), 운영 절차는 spec §D(실행 시 적용). ✓
- E gate/self-test 갱신 → Task 1 Step 6(gate), Task 1~3 self-test 케이스. ✓
- F clf-t1-1 마이그레이션 → Task 4. ✓
- 실적용 검증(조건부) → Task 5 Step 2~3. ✓

**2. Placeholder scan:** 모든 코드 스텝에 실제 코드·명령·기대출력. `<doc>`는 조건부 실적용의 가변 인자(Step 3에 skip 분기 명시)라 placeholder 아님. TODO/TBD 없음. ✓

**3. Type consistency:** `_spoken_body`(Task 1)를 Task 3 `build_verify_user`가 사용 — 시그니처 일치. `call_claude_text(system,user,model)`(Task 2)를 Task 3 `run_verify`가 동일 시그니처로 호출. `enrich_targets`/`merge_enriched`/`parse_verify_response` 반환형이 self-test·run_* 사용처와 일치. 모델 기본값 `claude-opus-4-8` Task 2·3 동일. ✓

## 범위 / 비목표

- 범위: 신규필드 발화 일원화 + enrich/verify 서브커맨드 + clf-t1-1 마이그레이션 + 통합/조건부 실적용 검증.
- 비목표(YAGNI): 18문서 전량 enrich·합성, 18문서 선행작업(발음사전·audioSummary, [[content-review-pipeline]] 영역), 세션/`--api` 이중경로, 섹션 통째 재구성, 비-CLF.

## 정본·관련

- 설계: `docs/superpowers/specs/2026-06-29-audio-instructor-stage-b-scaleup-design.md`(APPROVED)
- 선행 파일럿: `docs/superpowers/plans/2026-06-29-audio-instructor-pilot-stage-b.md`
- 코드: `flutter_app/tool/gen_lecture_audio.py`(`_segment_speech` L722·`script_to_speech` L411·`gate_script` L473·`apply_lexicon` L270·`main` L1583·`_self_test` L1097)
- 재합성·청취후 flip 패턴(확대 운영 시): [[audio-section-timestamps-shipped]]
