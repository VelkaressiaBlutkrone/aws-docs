# 오디오 대본 스캐폴딩 제거 (Stage A1) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** CLF 오디오 대본이 낭독하던 **문서-상단 메타 문단**과 **학습목표 체크리스트 블록**을 `skip` 표시해 더는 소리내어 읽지 않게 한다(19문서). 데이터 계약(chapters fraction·앱)은 무변경.

**Architecture:** 순수 함수 `mark_scaffolding(segments)`가 19문서 실스캔으로 확정한 2개 패턴에 `skip=True`를 표시한다(결정적, AI 없음). 신규 서브커맨드 `descaffold`가 기존 script.json에 in-place 적용(generate 재실행 없이 — 수동 audioSummary 보존). 적용 후 19문서 재합성 → 청취 → reviewStatus 재승인. `skip`은 이미 `script_to_speech`(L415)·`split_sections`가 음성에서 제외하므로 합성 경로 변경 불필요.

**Tech Stack:** Python 3(`py` 런처), `gen_lecture_audio.py`, Amazon Polly(Seoyeon neural), ffprobe+ffmpeg(재합성).

## Global Constraints

- 모든 명령은 `flutter_app/` 디렉터리 기준. Windows는 `py` 런처(`python`은 Store alias 깨짐).
- 도구 검증: `py tool/gen_lecture_audio.py --self-test`(현재 "self-test OK"가 기준선 — 깨지면 안 됨).
- TDD: 새 동작은 `--self-test`에 실패하는 assert를 먼저 추가하고 구현으로 통과시킨다(절대조건 2).
- 커밋 직전 `git branch --show-current`로 의도 브랜치 확인(CLAUDE.md §5 공유 워킹트리).
- 재합성엔 **ffprobe+ffmpeg 설치 필수**(`_audio_duration_ms` 없으면 RuntimeError, loudnorm 없으면 sys.exit). PATH 예: `C:/Users/deepe/AppData/Local/Microsoft/WinGet/Packages/Gyan.FFmpeg_*/ffmpeg-*/bin`.
- **재승인은 변경 음성 → 청취 후 flip**(설계 F2): Stage A1은 들리는 음성을 바꾸므로 "음성 동일 자동 flip" 적용 불가. 표본(≥3문서, clf-t1-1 포함) 청취 후 reviewStatus를 approved로 flip.
- 다른 세션 untracked 파일(`assets/audio/clf/_*`, `clf-t1-1/review_notes.*`) **절대 git add 금지**.
- 휴리스틱 패턴은 CLF 학습문서 템플릿 전용 문자열("커버하는 공식 Task", "학습 목표 체크리스트"). 비-CLF 콘텐츠엔 미적용(YAGNI).

**스캔 근거(블로킹 C1 종결, 19문서 실측):**
- 메타 문단: 19/19 seg001=paragraph, scriptText가 `"커버하는 공식 Task"`로 시작(도메인·퍼센트·문서ID·"1:1 매핑" 포함).
- 체크리스트: 19/19 seg002=heading `"## ✅ 학습 목표 체크리스트"` → 다음 헤딩 전까지(seg003 intro, seg004 불릿).
- `(clf-tX-Y)` 멘션은 **오직 seg001에만** — 본문 정당 교차참조 0건(오탐 위험 음성). `"할 수 있다"`는 본문(seg035·seg044)에도 있어 키로 부적합 → **헤딩+구조 위치로만 키잉**.

---

### Task 1: 순수 함수 `mark_scaffolding`

**Files:**
- Modify: `flutter_app/tool/gen_lecture_audio.py` (함수 추가 + self-test 블록에 assert)

**Interfaces:**
- Produces: `mark_scaffolding(segments: list[dict]) -> int` — segments를 in-place 수정(`skip=True` 표시), 새로 표시한 개수 반환. 멱등(이미 skip이면 미카운트).

- [ ] **Step 1: 실패하는 self-test 추가**

`main()`의 self-test 블록에서 `print("self-test OK")` 바로 위에 추가:
```python
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
```

- [ ] **Step 2: self-test 실패 확인**

Run: `py tool/gen_lecture_audio.py --self-test`
Expected: `NameError: name 'mark_scaffolding' is not defined`.

- [ ] **Step 3: 함수 구현**

`split_sections` 정의 근처(다른 순수 함수 옆, 예 `chapters_from_segments` 아래)에 추가:
```python
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
```

- [ ] **Step 4: self-test 통과 확인**

Run: `py tool/gen_lecture_audio.py --self-test`
Expected: `self-test OK`.

- [ ] **Step 5: 커밋**

```bash
git add flutter_app/tool/gen_lecture_audio.py
git commit -m "feat(audio): mark_scaffolding(메타·체크리스트 skip 표시) 순수 함수"
```

---

### Task 2: `descaffold` 서브커맨드

**Files:**
- Modify: `flutter_app/tool/gen_lecture_audio.py` (run_descaffold + 서브파서 배선 + self-test)

**Interfaces:**
- Consumes: `mark_scaffolding`(Task 1).
- Produces: `run_descaffold(args)` — `args.script`(Path) script.json을 읽어 `mark_scaffolding` 적용, 표시가 있으면 top-level `reviewStatus`를 `"needs_human_review"`로 내리고 다시 쓴다. CLI: `descaffold --script <path>`.

- [ ] **Step 1: 실패하는 self-test 추가**

self-test 블록에서 Task 1 assert 다음, `print("self-test OK")` 앞에 추가:
```python
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
```

- [ ] **Step 2: self-test 실패 확인**

Run: `py tool/gen_lecture_audio.py --self-test`
Expected: `NameError: name 'run_descaffold' is not defined`.

- [ ] **Step 3: run_descaffold 구현**

`run_chapters`(L545 근처) 옆에 추가:
```python
def run_descaffold(args) -> None:
    script = json.loads(args.script.read_text(encoding="utf-8"))
    marked = mark_scaffolding(script["segments"])
    if marked:
        script["reviewStatus"] = "needs_human_review"  # 내용 변경 → 재검수 필요
    write_json(args.script, script)
    print(f"[descaffold] {marked}개 세그먼트 skip 표시 → {args.script}",
          file=sys.stderr)
```

- [ ] **Step 4: 서브파서 배선**

`main()`의 `ch = sub.add_parser("chapters", …)` 블록 다음(L1322 뒤)에 추가:
```python
    de = sub.add_parser("descaffold",
                        help="스캐폴딩(메타·체크리스트) 세그먼트 skip 표시")
    de.add_argument("--script", type=Path, required=True)
```
그리고 dispatch에서 `elif args.cmd == "chapters":` 블록 다음(L1334 뒤)에 추가:
```python
    elif args.cmd == "descaffold":
        run_descaffold(args)
```
그리고 `ap.error(...)` 메시지(L1336)를 갱신:
```python
        ap.error("서브커맨드(generate/synthesize/gate/chapters/descaffold) 또는 --self-test 가 필요합니다.")
```

- [ ] **Step 5: self-test 통과 확인**

Run: `py tool/gen_lecture_audio.py --self-test`
Expected: `self-test OK`.

- [ ] **Step 6: 커밋**

```bash
git add flutter_app/tool/gen_lecture_audio.py
git commit -m "feat(audio): descaffold 서브커맨드(기존 script.json에 스캐폴딩 skip 적용)"
```

---

### Task 3: 19문서 적용·재합성·재승인 (운영)

**Files:**
- Modify(생성물): `flutter_app/assets/audio/clf/clf-*/script.json`(skip·reviewStatus), `clf-*/lecture.mp3`, `clf-*/audio_meta.json`(전 19문서).

**전제 확인:** ffprobe+ffmpeg PATH, AWS 자격(`~/.aws`), 브랜치 = 의도 브랜치.

- [ ] **Step 1: 19문서 descaffold 적용**

```bash
cd flutter_app
for d in assets/audio/clf/clf-*/; do
  py tool/gen_lecture_audio.py descaffold --script "${d}script.json"
done
```
Expected: 각 문서 `[descaffold] N개 세그먼트 skip 표시`(N≥4 예상: 메타1 + 체크리스트블록≥3).

- [ ] **Step 2: skip 적용 검증(직접 확인)**

```bash
PYTHONIOENCODING=utf-8 py - <<'PY'
import json, glob, os
for p in sorted(glob.glob('assets/audio/clf/clf-*/script.json')):
    s = json.load(open(p, encoding='utf-8'))
    segs = s['segments']
    meta = next((g for g in segs if g['kind']=='paragraph' and (g.get('scriptText') or '').startswith('커버하는 공식 Task')), None)
    chk = next((g for g in segs if g['kind']=='heading' and '학습 목표 체크리스트' in (g.get('sourceExcerpt') or '')), None)
    d = os.path.basename(os.path.dirname(p))
    ok = (meta and meta['skip']) and (chk and chk['skip'])
    print(f"{d}: meta.skip={meta and meta['skip']} chk.skip={chk and chk['skip']} review={s.get('reviewStatus')} {'OK' if ok else '<<<'}")
PY
```
Expected: 19문서 모두 meta.skip=True, chk.skip=True, review=needs_human_review.

- [ ] **Step 3: 19문서 재합성**

ffmpeg/ffprobe를 PATH에 올리고(Global Constraints 경로) 순차 재합성:
```bash
export PATH="<ffmpeg bin>:$PATH"; export PYTHONIOENCODING=utf-8
for d in assets/audio/clf/clf-*/; do
  py tool/gen_lecture_audio.py synthesize --script "${d}script.json" --out "${d}lecture.mp3"
done
```
Expected: 각 문서 `[완료]`, loudnorm OK, ID3 1개. (긴 작업 — 백그라운드 권장.)

- [ ] **Step 4: 전수 gate**

```bash
export PATH="<ffmpeg bin>:$PATH"
pass=0; for d in assets/audio/clf/clf-*/; do
  py tool/gen_lecture_audio.py gate --script "${d}script.json" --audio-meta "${d}audio_meta.json" --lexicon tool/lexicon.json 2>&1 | grep -q PASS && pass=$((pass+1)) || echo "FAIL ${d}"
done; echo "gate PASS=$pass/19"
```
Expected: `gate PASS=19/19`.

- [ ] **Step 5: 표본 청취(스캐폴딩 제거 확인 — F2)**

clf-t1-1·clf-t2-1·clf-t3-1(최소 3문서)의 `lecture.mp3`를 직접 재생해 (a) "커버하는 공식 Task / 씨엘에프 씨 공이 / (clf-…) / 1:1 매핑" 낭독이 **사라졌는지**, (b) "학습 목표 체크리스트" 낭독이 사라졌는지, (c) 첫 실내용 헤딩부터 자연스럽게 시작하는지 귀로 확인.
Expected: 스캐폴딩 낭독 없음, 음성 정상. (이상 시 멈추고 원인 분석 — 절대조건 3.)

- [ ] **Step 6: reviewStatus 재승인 flip(19문서, script.json + audio_meta)**

청취 통과 후에만 실행. 기존 헬퍼 재사용(top-level reviewStatus를 approved로; audio_meta는 중첩 script.reviewStatus도):
```bash
FLIP="C:/Users/deepe/AppData/Local/Temp/.../reapprove_audio_meta.py"  # write_json 동일 포맷, top(+중첩 script) reviewStatus=approved
for d in assets/audio/clf/clf-*/; do
  py "$FLIP" "${d}audio_meta.json" "${d}script.json"
done
```
Expected: 각 문서 audio_meta(top+script)·script.json reviewStatus=approved.
(헬퍼 부재 시: 두 파일의 top-level `reviewStatus`와 audio_meta의 `script.reviewStatus`를 `"approved"`로 set, write_json 포맷 `indent=2, ensure_ascii=False, +"\n"` 유지.)

- [ ] **Step 7: 전체 테스트·분석·빌드 게이트**

```bash
flutter test 2>&1 | tail -3        # 776+ 전부 그린(동기화 테스트 audioApproved↔meta 포함)
flutter analyze 2>&1 | tail -5     # 신규 0(기존 잔존 3)
```
PowerShell로 web 빌드:
`flutter build web --release --base-href /aws-docs/ --dart-define=audio_lecture=true`
Expected: test 그린, analyze 신규 0, web 빌드 성공.

- [ ] **Step 8: 커밋(다른 세션 untracked 제외)**

```bash
git branch --show-current   # 의도 브랜치 확인
git add flutter_app/assets/audio/clf/clf-*/script.json flutter_app/assets/audio/clf/clf-*/audio_meta.json flutter_app/assets/audio/clf/clf-*/lecture.mp3
git diff --cached --name-only | grep -cE "_apply_review|_corpus_scan|review_notes"   # 0이어야 함
git commit -m "feat(audio): CLF 19문서 스캐폴딩 낭독 제거(메타·체크리스트 skip) 재합성"
```

- [ ] **Step 9: develop PR**

REQUIRED SUB-SKILL: `superpowers:finishing-a-development-branch` → 옵션 2(Push + develop PR). 브랜치 전략상 develop은 PR 전용.

---

## Self-Review

**1. Spec coverage(설계 Stage A1 부분):**
- 스캐폴딩 감지(휴리스틱) → Task 1 `mark_scaffolding`(19문서 실스캔 근거). ✓
- 기존 script.json에 적용(generate 재실행 없이, 수동 audioSummary 보존) → Task 2 `descaffold`. ✓
- 19문서 재합성·gate·재승인 → Task 3. ✓
- 블로킹 C1(실스캔 휴리스틱+오탐 안전망=헤딩/구조 키잉, `(clf-)` 본문 0건) → Global Constraints 스캔근거. ✓
- 블로킹 F1(ffprobe+ffmpeg) → Global Constraints + Task 3 전제. ✓
- 블로킹 F2(변경음성 → 청취후 flip) → Task 3 Step 5→6 순서. ✓
- 블로킹 C6(마커 탈출구=신규 파서) → **이 계획 범위 밖**(A1은 휴리스틱만; 마커는 A2/후속). 명시. ✓
- 블로킹 C5(연결조직 템플릿)·C3(삽입문 평문) → **Stage A2(별도 계획)**. A1은 삽입 없음(skip만)이라 무관. ✓
- chapters fraction(C2): skip은 비앵커 헤딩/메타라 앵커 경계 불변, fraction 값만 섹션길이 변화로 재계산(정상). 앱·chapters 스키마 무변경. ✓

**2. Placeholder scan:** 모든 스텝 실제 코드·명령. Task 3 Step 6의 FLIP 경로만 환경 의존(헬퍼 부재 시 대체 지침 병기). TODO/TBD 없음. ✓

**3. Type consistency:** `mark_scaffolding(segments)->int`가 Task 1 정의·Task 2 호출에서 일치. `run_descaffold(args)` args.script(Path) 일관. self-test의 segment dict 키(kind/sourceExcerpt/scriptText/skip)가 실제 스키마와 일치. ✓

## 범위 / 후속(비목표)

- 범위: 스캐폴딩 2블록 skip + 19문서 재합성·재승인. **Dart/앱 무변경.**
- 비목표(후속 Stage A2): 도입/전환/마무리 **연결 조직**(템플릿·위치·"네비게이션만" 불변식, 삽입문 평문규칙), 마커 탈출구(`<!-- audio: … -->` 신규 파서). Assignment 청취가 톤을 확정한 뒤 별도 계획.
- 알려진 한계: A1은 실증된 2개 스캐폴딩 블록만 제거. 청취에서 추가 스캐폴딩(예 문서 말미 참조·셀프체크)이 발견되면 후속에서 규칙 확장.

## 정본·관련

- 설계: `docs/superpowers/specs/2026-06-29-audio-instructor-script-design.md`(APPROVED)
- 코드: `flutter_app/tool/gen_lecture_audio.py`(`script_to_speech` L411·skip 처리, `split_sections`, `run_synthesize`, gate, 서브파서 L1300+)
- 패턴: 재합성·재승인(reviewStatus 리셋→청취후 flip) [[audio-section-timestamps-shipped]]; generate 덮어쓰기 함정 [[content-review-pipeline-planned]]
