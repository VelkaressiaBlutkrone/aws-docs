# 오디오 LLM 재강의 파일럿 (Stage B, clf-t1-1) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** clf-t1-1 한 문서의 본문 세그먼트 `scriptText`를 LLM으로 대화체+비유/예시 풍부화하되 사실 보존, AI 사실검증 + 사람 승인 후 재합성한다. 품질·검수부담 실측이 목적.

**Architecture:** 도구 코드 변경 없는 **콘텐츠 운영** 작업이다. 세션 내 서브에이전트가 clf-t1-1 script.json의 비-skip·비-heading·비-connector·비-table 세그먼트(19개) scriptText를 in-place 풍부화 → 별도 AI 검증 에이전트가 사실 대조 → gate(토큰보존·기호) → 사람 승인 → 재합성 → reviewStatus flip. 세그먼트 경계 유지라 기존 gate·chapters·앱 무변경.

**Tech Stack:** Python `gen_lecture_audio.py`(gate/synthesize, **코드 무변경**), Amazon Polly, ffprobe+ffmpeg, 세션 서브에이전트(풍부화·검증).

## Global Constraints

- 모든 명령은 `flutter_app/` 기준. Windows `py` 런처. `PYTHONIOENCODING=utf-8`.
- **도구 코드(gen_lecture_audio.py)·Dart·앱 무변경.** 변경 대상은 `clf-t1-1/script.json`(scriptText·reviewStatus)·`lecture.mp3`·`audio_meta.json`뿐.
- 풍부화 대상 필터: `not skip and kind not in {heading, connector, table} and scriptText`. (heading=제목 원문 유지, connector=A2, table=audioSummary, skip=A1 스캐폴딩.)
- **사실 보존 불변식**: 풍부화본은 그 세그먼트 `sourceExcerpt`의 약어·수치·핵심 주장 보존, **원문에 없는 새 시험 사실 단정 금지**(비유는 설명용 예시). 평문(기호 `→≠↓§|`·URL·마크다운 금지)·합니다체·원문 ~2배 이내.
- 재합성: ffprobe+ffmpeg 필요. PATH: `C:/Users/deepe/AppData/Local/Microsoft/WinGet/Packages/Gyan.FFmpeg_*/ffmpeg-*/bin`.
- **사람 최종승인 게이트**: 시험 콘텐츠라 AI검증 PASS 후에도 사용자 사인 전엔 reviewStatus flip 금지(청취 후 flip).
- 다른 세션 untracked 파일 절대 git add 금지.
- 커밋 직전 `git branch --show-current`로 `feat/audio-instructor-pilot-stage-b` 확인.

---

### Task 1: clf-t1-1 본문 세그먼트 풍부화

**Files:**
- Modify: `flutter_app/assets/audio/clf/clf-t1-1/script.json` (대상 19세그먼트 scriptText + top-level reviewStatus).

**Deliverable:** 풍부화된 script.json(대상 세그먼트 scriptText 교체, reviewStatus=needs_human_review). 도구·gate는 Task 3.

- [ ] **Step 1: 풍부화 전 백업 스냅샷(롤백용)**

```bash
cd flutter_app
cp assets/audio/clf/clf-t1-1/script.json "C:/Users/deepe/AppData/Local/Temp/claude/D--workspace-awc-docs/9cbd3fa8-0365-4606-b38b-42ffd836827a/scratchpad/clf-t1-1-script.pre-b.json"
```

- [ ] **Step 2: 풍부화 서브에이전트 디스패치**

서브에이전트(general-purpose, sonnet)에게:
- 읽기: `flutter_app/assets/audio/clf/clf-t1-1/script.json`.
- 대상: `not skip and kind not in {heading,connector,table} and scriptText` 세그먼트(약 19개).
- 각 대상의 `scriptText`를 다음 규칙으로 풍부화해 **그 세그먼트 scriptText만 교체**(다른 필드·세그먼트 불변, 배열 순서·개수 불변):
  - (a) 대화체로 자연스럽게(합니다체), (b) 이해를 돕는 **짧은 비유/예시 1개**를 자연스러운 곳에만(억지로 모든 세그먼트에 넣지 말 것), (c) **`sourceExcerpt`의 약어·수치·핵심 주장 보존**, (d) **원문에 없는 새 시험 사실 단정 금지**(비유는 설명용 예시일 뿐 새 사실을 만들지 않음), (e) 평문(기호 `→≠↓§|`·URL·마크다운·괄호부연 남발 금지)·원문 ~2배 이내, (f) 영문 약어는 한글 발음 표기 관례 유지(예 AWS→에이더블유에스).
  - 파일을 직접 Write로 갱신(json indent=2, ensure_ascii=False, 끝 개행). top-level `reviewStatus`를 `needs_human_review`로.
- 보고: 풍부화한 세그먼트 수 + 변경 요약을 `.git/sdd/task-b1-report.md`에 Write.
- 범위잠금: 이 작업만, scriptText 외 변경 금지, 새 사실 추측 금지.

- [ ] **Step 3: 구조 무결성 직접 검증(컨트롤러)**

```bash
PYTHONIOENCODING=utf-8 py - <<'PY'
import json
pre=json.load(open("C:/Users/deepe/AppData/Local/Temp/claude/D--workspace-awc-docs/9cbd3fa8-0365-4606-b38b-42ffd836827a/scratchpad/clf-t1-1-script.pre-b.json",encoding='utf-8'))
cur=json.load(open('assets/audio/clf/clf-t1-1/script.json',encoding='utf-8'))
ps,cs=pre['segments'],cur['segments']
assert len(ps)==len(cs), f"세그먼트 수 변동 {len(ps)}->{len(cs)}"
changed=0; bad=[]
for a,b in zip(ps,cs):
    for k in ('id','kind','sourceExcerpt','skip'):
        if a.get(k)!=b.get(k): bad.append(f"{a['id']}:{k} 변경")
    if a.get('scriptText')!=b.get('scriptText'): changed+=1
print("불변필드 위반:", bad or "없음")
print("scriptText 변경 세그먼트:", changed, "| reviewStatus:", cur.get('reviewStatus'))
PY
```
Expected: 불변필드 위반 없음(id/kind/sourceExcerpt/skip 보존), scriptText 변경 ≈19, reviewStatus=needs_human_review. (위반 시 백업 복원 후 재디스패치.)

- [ ] **Step 4: 커밋**

```bash
git branch --show-current
git add flutter_app/assets/audio/clf/clf-t1-1/script.json
git commit -m "feat(audio): clf-t1-1 본문 세그먼트 LLM 풍부화(Stage B 파일럿, 대화체+비유)"
```

---

### Task 2: AI 사실검증

**Deliverable:** 세그먼트별 사실검증 리포트. 플래그 0(또는 재작업 후 0).

- [ ] **Step 1: 검증 서브에이전트 디스패치**

서브에이전트(general-purpose, opus — 사실 판단)에게:
- 읽기: `flutter_app/assets/audio/clf/clf-t1-1/script.json`.
- 대상: Task 1에서 풍부화된 세그먼트(scriptText가 sourceExcerpt와 다른 비-skip 본문).
- 각 세그먼트의 풍부화 `scriptText`를 그 `sourceExcerpt`(검증된 원문)와 대조해 다음을 **플래그**:
  - 원문이 뒷받침하지 않는 **사실 단정**(없던 수치·서비스명·인과·"항상/모두" 류 과일반화),
  - **틀린 비유/예시**(개념을 오도),
  - 원문 수치·약어 **변경/누락**.
- 출력: 플래그 목록(`seg id | 문제 유형 | 원문 근거 | 제안`) 또는 `PASS`. 반드시 `.git/sdd/task-b2-verify.md`에 Write. 코드·파일 수정 금지(검증만).

- [ ] **Step 2: 플래그 처리(있으면)**

`.git/sdd/task-b2-verify.md` 읽기. 플래그가 있으면 그 세그먼트만 Task 1 풍부화 서브에이전트에 **재작업 지시**(플래그 내용 제공) → script.json 갱신 → Step 1 재검증. 플래그 0까지 반복(최대 2회). 컨트롤러가 직접 플래그를 읽고 판단(서브에이전트 보고 맹신 금지).

- [ ] **Step 3: 커밋(재작업 있었으면)**

```bash
git add flutter_app/assets/audio/clf/clf-t1-1/script.json
git commit -m "fix(audio): clf-t1-1 풍부화 사실검증 반영(플래그 해소)"
```
(재작업 없으면 스킵.)

---

### Task 3: 도구 gate 검증

**Deliverable:** gate PASS(토큰보존·기호 0).

- [ ] **Step 1: gate + 기호/토큰 직접 검증**

```bash
cd flutter_app
export PATH="<ffmpeg bin>:$PATH"
PYTHONIOENCODING=utf-8 py tool/gen_lecture_audio.py gate --script assets/audio/clf/clf-t1-1/script.json --audio-meta assets/audio/clf/clf-t1-1/audio_meta.json --lexicon tool/lexicon.json 2>&1 | tail -3
echo "=== self-test(도구 무변경 확인) ===" && py tool/gen_lecture_audio.py --self-test 2>&1 | tail -1
```
Expected: `[gate] PASS`(토큰보존 hard 0 — 풍부화가 원문 약어·수치 보존; 기호/URL/링크 0). self-test OK(도구 코드 무변경).
(gate FAIL 시: 메시지의 seg를 Task 1/2로 되돌려 수정 후 재검증 — 절대조건 3.)

---

### Task 4: 재합성·사람승인·배포 (운영)

**전제:** ffprobe+ffmpeg PATH, AWS 자격, 브랜치=`feat/audio-instructor-pilot-stage-b`.

- [ ] **Step 1: 재합성**

```bash
export PATH="<ffmpeg bin>:$PATH"; export PYTHONIOENCODING=utf-8
py tool/gen_lecture_audio.py synthesize --script assets/audio/clf/clf-t1-1/script.json --out assets/audio/clf/clf-t1-1/lecture.mp3 2>&1 | tail -4
```
Expected: `[완료]`, loudnorm OK, ID3 1개.

- [ ] **Step 2: gate(재합성 후 audio_meta 포함)·chapters 확인**

```bash
PYTHONIOENCODING=utf-8 py tool/gen_lecture_audio.py gate --script assets/audio/clf/clf-t1-1/script.json --audio-meta assets/audio/clf/clf-t1-1/audio_meta.json --lexicon tool/lexicon.json 2>&1 | tail -1
PYTHONIOENCODING=utf-8 py -c "import json;m=json.load(open('assets/audio/clf/clf-t1-1/audio_meta.json',encoding='utf-8'));fr=[c['fraction'] for c in m['chapters']];print('chapters',len(fr),'단조',all(fr[i]<fr[i+1] for i in range(len(fr)-1)),'reviewStatus',m['reviewStatus'])"
```
Expected: gate PASS, chapters 단조, reviewStatus=needs_human_review(아직 미승인).

- [ ] **Step 3: 사람 검토·승인 게이트(사용자)**

사용자에게 풍부화 결과(`.git/sdd/task-b1-report.md` + 재합성 mp3 청취)와 AI검증(`.git/sdd/task-b2-verify.md`)을 제시. **사용자가 (a) 강의 품질 (b) 사실 정확성을 확인하고 승인**해야 다음 단계. (시험 콘텐츠 — 사람 최종 책임.) 미승인 시 여기서 정지하고 피드백 반영.

- [ ] **Step 4: reviewStatus flip(승인 후에만)**

```bash
FLIP="C:/Users/deepe/AppData/Local/Temp/claude/D--workspace-awc-docs/9cbd3fa8-0365-4606-b38b-42ffd836827a/scratchpad/reapprove_audio_meta.py"
PYTHONIOENCODING=utf-8 py "$FLIP" assets/audio/clf/clf-t1-1/audio_meta.json assets/audio/clf/clf-t1-1/script.json
```
Expected: audio_meta(top+script)·script.json reviewStatus=approved.

- [ ] **Step 5: 앱 게이트**

```bash
flutter test 2>&1 | tail -2        # 776 그린(동기화 테스트 — clf-t1-1 meta approved)
flutter analyze 2>&1 | tail -4     # 신규 0
```
PowerShell: `flutter build web --release --base-href /aws-docs/ --dart-define=audio_lecture=true`
Expected: test 그린, analyze 신규 0, web 빌드 성공.

- [ ] **Step 6: 커밋·PR**

```bash
git branch --show-current
git add flutter_app/assets/audio/clf/clf-t1-1/lecture.mp3 flutter_app/assets/audio/clf/clf-t1-1/audio_meta.json flutter_app/assets/audio/clf/clf-t1-1/script.json
git diff --cached --name-only | grep -cE "_apply_review|_corpus_scan|review_notes"   # 0
git commit -m "feat(audio): clf-t1-1 Stage B 파일럿 재합성(풍부화 본문, 사실검증·승인)"
```
REQUIRED SUB-SKILL: `superpowers:finishing-a-development-branch` → 옵션 2(develop PR).

- [ ] **Step 7: 파일럿 회고(확대 결정)**

품질(강의다움)·검수부담(사람 시간)·환각 빈도(Task 2 플래그 수)를 1~2줄로 기록 → 18문서 확대 가치·도구화(Claude API 서브커맨드)·저장 신규필드 분리 여부를 사용자와 결정.

---

## Self-Review

**1. Spec coverage:**
- 세그먼트별 풍부화(대화체+비유, 사실보존, 평문, heading/connector/table/skip 제외) → Task 1. ✓
- AI 사실검증(원문 미뒷받침 플래그) → Task 2. ✓
- 사람 최종승인 → Task 4 Step 3. ✓
- scriptText 교체·sourceExcerpt 유지·gate 토큰보존 → Task 1(교체)·Task 3(gate). ✓
- 앱·도구 무변경·chapters 불변 → Global Constraints·Task 3 self-test·Task 4 Step2. ✓
- 재합성·청취후 flip → Task 4. ✓
- 파일럿 후 확대 결정 → Task 4 Step 7. ✓

**2. Placeholder scan:** 운영 작업이라 코드 TDD 대신 검증 명령. 모든 스텝 실제 명령/대조. FLIP·ffmpeg 경로만 환경의존. TODO/TBD 없음. ✓

**3. 일관성:** 풍부화 대상 필터(non-skip·kind∉{heading,connector,table}·scriptText)가 Task 1·2·spec 동일. reviewStatus 흐름(needs_human_review→승인후 approved) 일관. ✓

## 범위 / 비목표

- 범위: clf-t1-1 1문서 풍부화·검증·승인·재합성. **도구/Dart/앱 무변경.**
- 비목표(YAGNI): 18문서·도구화(enrich API)·섹션통째 재구성·신규 저장필드(확대 시 결정).

## 정본·관련

- 설계: `docs/superpowers/specs/2026-06-29-audio-instructor-pilot-stage-b-design.md`(APPROVED)
- 코드(무변경): `flutter_app/tool/gen_lecture_audio.py`(gate_script L473·토큰보존 L496·synthesize)
- 패턴: 재합성·청취후 flip [[audio-section-timestamps-shipped]] · 상위 [[audio-instructor-script-planned]]
