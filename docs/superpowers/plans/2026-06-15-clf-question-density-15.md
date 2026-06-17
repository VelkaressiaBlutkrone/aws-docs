# CLF 문항 밀도 ≥15 심화 구현 플랜

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** CLF-C02 19개 Task를 각 12 → 15 verified 문항으로 끌어올린다(+57: 원리형 19 · 함정 혼동형 19 · 미커버 보완 19).

**Architecture:** 검증된 콘텐츠 파이프라인(드래프터 → AI 리뷰어 → 컨트롤러 실측 → **사람 검수 게이트** → flip)을 도메인 4배치로 직렬 실행한다. 신규 문항은 `verified:false`로 삽입돼 라이브·테스트 카운트에 영향을 주지 않으므로(런타임 게이트가 verified만 노출) 검수 통과 후에만 `verified:true`로 뒤집고 `content_index.dart`의 `questionCount`를 올린다. 모든 문항은 해당 고도화 학습문서의 본문·🧠 원리 블록·⚠️ 함정·frontmatter 출처 범위 안에서만 출제해 학습문서 사후 보강을 구조적으로 0건으로 만든다.

**Tech Stack:** Flutter Web(Dart) · JSON 문항 뱅크(`assets/content/clf/t*.questions.json`) · 정적 인덱스(`lib/data/content_index.dart`) · `flutter test` 회귀 가드 · 서브에이전트(드래프터 sonnet · 리뷰어 sonnet).

**근거 스펙:** `docs/superpowers/specs/2026-06-12-clf-question-density-15-design.md` (설계 승인됨). 본 플랜은 그 스펙의 §4~§7을 단계화한 것이다.

---

## ⚠️ 실행 전 결정 필요 (브랜치 전략)

스펙 §6.4와 레포 git 이력은 `feat/clf-q15-d{N}` → **`main` 직접 머지(`--no-ff`)**를 쓴다. 그러나 전역 규칙 `~/.claude/rules/git-branch-flow.md`는 **`develop` 경유 2단계 PR**(작업 브랜치 → develop → main)을 요구하며, 현재 레포에는 `develop` 브랜치가 없다.

**이 충돌은 실행 시작 전에 사용자가 결정한다.** 본 플랜의 머지 단계는 두 경로 모두를 명시한다(아래 각 배치의 "머지" 스텝 참조). 기본값은 전역 규칙 우선(`develop` 경유)이며, 사용자가 스펙대로 `main` 직접 머지를 택하면 해당 스텝의 (B) 경로를 따른다.

---

## 핵심 사실 (실측 2026-06-15)

- 19개 Task 전부 정확히 **12 verified**, 문항 연번 `q1`~`q12` (구멍 없음). 신규 문항 id는 `clf-tX-Y-q13`·`q14`·`q15`.
- 문항 스키마(`t*.questions.json`의 `questions[]` 원소): `id` · `examGuideTaskId` · `skill` · `difficulty`(`foundational`|`applied`) · `stem` · `options`(정확히 4개) · `correct`(0~3) · `explanation` · `wrongExplanations`(**JSON 키는 문자열** `"1"`/`"2"`/`"3"` — 정답 인덱스 제외 3개) · `sources`(`[{title,url}]`, 비어있지 않음) · `verified`(bool).
- `content_index.dart`: `kContentIndex['CLF-C02']`에 19개 `ContentEntry`, 각 `questionCount: 12`. task별 `questionsAsset` 경로가 고유 앵커.
- 회귀 가드 `test/question_model_test.dart`: **t2-1 한 파일만** 로드해 `rawVerified >= 12` 단언(라인 18). 밀도 가드는 단일 파일 표본임에 유의.
- 정합 테스트 `test/content_index_test.dart`: `certContentSummary('CLF-C02').questions == Σ questionCount`. **자기참조적**(둘 다 questionCount에서 파생) → 실제 JSON verified 수와의 교차검증은 **컨트롤러 수동 grep 카운트가 담당**(아래 검증 스텝).
- 도메인 배치: D1=t1-1..t1-4(4) · D2=t2-1..t2-4(4) · D3=t3-1..t3-8(8) · D4=t4-1..t4-3(3).
- 출제 소재 원천(task당): 고도화 문서 `assets/content/clf/tX-Y.md`(섹션 `## 📖 핵심 개념`의 `### N)` 서브섹션마다 `> 🧠 원리:` 블록 · `## ⚠️ 흔한 함정` · `## 🧪 자가 점검`) + 공식 가이드 `assets/exam_guides/CLF-C02.json`(`domains[].tasks[]`의 `no`/`skills[]`; task `no` "1.1" ↔ `clf-t1-1`).

---

## 재사용 절차 (각 배치가 호출 — 전문 1회 정의)

### 절차 A: 드래프터 디스패치 (task 1개당, 서브에이전트)

각 task(`clf-tX-Y`)에 대해 아래 프롬프트로 서브에이전트 1개를 띄운다. 배치 내 task들은 **병렬 디스패치 가능**(서로 다른 파일, 공유 상태 없음). `oh-my-claudecode:executor`(sonnet) 또는 기본 에이전트 사용.

> **[드래프터 — clf-tX-Y 문항 3개 초안]**
> 이 작업(Task: clf-tX-Y 초안)만 수행하라. 끝나면 보고하고 정지하라. 다른 task로 진행하거나 명세에 없는 코드를 임의 구현하지 말라. 명세가 부족하면 멈추고 `NEEDS_CONTEXT`로 보고하라.
>
> **입력으로 반드시 읽을 파일:**
> - `flutter_app/assets/content/clf/tX-Y.md` (고도화 학습문서 — 출제 소재의 유일 원천)
> - `flutter_app/assets/content/clf/tX-Y.questions.json` (기존 12문항 — 중복 회피 대조)
> - `flutter_app/assets/exam_guides/CLF-C02.json` 중 task no "X.Y" 항목의 `skills[]` (미커버 보완 소재)
>
> **산출:** `tX-Y.questions.json`의 `questions` 배열 **끝에** 3개 객체를 추가한다(기존 12개 수정 금지). 각 객체 스키마:
> - `id`: `clf-tX-Y-q13`, `clf-tX-Y-q14`, `clf-tX-Y-q15` 순서(기존 최대 연번 q12 다음 — 파일에서 실측 확인 후 연번).
> - `examGuideTaskId`: `clf-tX-Y`.
> - `skill`: 해당 문항이 겨냥하는 세부 스킬(한글 짧은 구).
> - `difficulty`: 원리형·함정형은 `"applied"`, 미커버 보완은 `"foundational"` 또는 `"applied"`.
> - `stem`/`options`(정확히 4개)/`correct`(0~3)/`explanation`/`wrongExplanations`(**문자열 키**, 정답 인덱스 제외 3개 — "왜 틀렸는지 + 어떤 혼동을 노렸는지")/`sources`(해당 문서 frontmatter `sources` 범위 내, `[{title,url}]`).
> - `verified`: **false** (반드시 false. true 금지 — 사람 검수 전).
>
> **3문항 유형(각 1개):**
> 1. **원리형(applied):** 문서의 한 `> 🧠 원리:` 블록 원리를 **새 시나리오에 적용**해 판단을 묻는다. 문서 `## 🧪 자가 점검` 문항 전체 및 기존 12문항과 **소재·각도 중복 금지**. 원리 블록 문장을 그대로 재진술하지 말 것.
> 2. **함정 혼동형(applied):** 문서 `## ⚠️ 흔한 함정`의 한 통념을 **매력적 오답**으로 배치한 시나리오. 함정의 교정 논리가 정답 해설의 근거가 되게 한다.
> 3. **미커버 보완:** 공식 가이드 task "X.Y" `skills[]` 중 기존 12문항이 안 다룬 소재. **문서 범위에 없으면 같은 문서의 저커버 소재로 대체**하고(새 개념 도입 금지) 그 사유를 보고에 기록한다.
>
> **제약:** 사실 진술은 문서 본문·원리 블록·함정·frontmatter 출처 범위 내에서만(무출처 수치·내부 구현 단정·설계 의도 단정 금지). 보기 4개는 길이·톤 균형(정답 티 금지). CLF 난이도(기초 개념의 적용) 상한 — 학술적 깊이로 가지 말 것.
>
> **완료 전 자체 검증(보고에 결과 포함):** ① 추가 후 해당 파일 `verified:false` 정확히 3개·`verified:true` 12개 유지 ② JSON 파스 가능 ③ `cd flutter_app && flutter test test/question_model_test.dart` 그린(초안은 verified:false라 카운트 불변).
>
> **보고 형식:** 추가한 3문항의 id·유형·겨냥 소재(문서 § 위치)·미커버 대체 여부. 끝나면 정지.

배치 내 모든 task 초안 완료 후 커밋(컨트롤러가 수행):
```bash
cd flutter_app && git add assets/content/clf/
git commit -m "feat(content): clf D{N} 문항 +3씩 초안 — 원리·함정·보완 (verified:false, 검수 전)"
```

### 절차 B: 통합 AI 리뷰어 디스패치 (배치 1개당, 서브에이전트, 수정 권한)

배치의 모든 초안이 커밋된 후, 리뷰어 1개를 띄운다. `oh-my-claudecode:code-reviewer`는 코드용이므로 여기서는 기본 에이전트(수정 권한 보유)를 사용.

> **[리뷰어 — clf D{N} 초안 문항 검토·수정]**
> 이 작업(D{N} 배치 초안 리뷰)만 수행하라. 끝나면 보고하고 정지하라. 다른 배치로 진행하거나 명세 밖 변경을 하지 말라. 판단이 안 서는 경계 사례는 직접 수정하지 말고 **게이트 플래그로 보고**하라.
>
> **대상:** D{N} 배치 task들의 `verified:false` 신규 문항(각 파일 q13~q15). 각 task의 학습문서 `tX-Y.md`와 공식 가이드를 대조.
>
> **검토·수정 항목(위반 시 직접 수정 후 보고):**
> 1. **사실 정확성:** 문서·`sources` URL 대조. 범위 밖 사실 진술은 제거 또는 보수화.
> 2. **범위 이탈:** 문서에 없는 개념 도입 → 문서 내 소재로 교체.
> 3. **중복:** 기존 12문항 + 문서 자가 점검 문항 전수 대조. 정답 포인트·stem 소재 중복 → 각도 변경.
> 4. **오답 매력도·해설 품질:** 오답이 너무 뻔하면 강화. `wrongExplanations`가 "왜 틀림 + 어떤 혼동" 둘 다 담는지.
> 5. **스키마·id:** options 4개·correct 범위·wrongExplanations 문자열 키 3개(정답 제외)·sources 비어있지 않음·id 연번·`verified:false` 유지.
>
> **완료 전 검증:** `cd flutter_app && flutter test` 전체 그린. 수정 사항 커밋:
> `git commit -m "fix(content): clf D{N} 문항 리뷰 반영 — <요지>"`
>
> **보고 형식:** task별 수정 요지 + 게이트 플래그(경계 사례) 목록. 끝나면 정지.

### 절차 C: 컨트롤러 실측 (배치 1개당, 직접 수행 — 서브에이전트 보고 불신)

```bash
cd flutter_app
# 1) 배치 각 파일 verified 카운트: false=3, true=12 여야 함
for f in assets/content/clf/t{N}-*.questions.json; do \
  echo "$f true=$(grep -c '"verified": true' $f) false=$(grep -c '"verified": false' $f)"; done
# 2) JSON 파스 가능 + id 중복 없음 (배치 파일들)
# 3) 전체 테스트 그린
flutter test
# 4) 리뷰어 fix 디프 스팟 체크
git log --oneline -5
git diff HEAD~2 -- assets/content/clf/ | head -100
```
기대: 각 파일 `true=12 false=3`, `flutter test` All passed, 리뷰어가 기존 12문항을 건드리지 않았을 것.

### 절차 D: 검수 파일 추출 + STOP 게이트

```bash
cd flutter_app
# 신규 verified:false 문항만 모아 검수용 JSON 추출 (문항별 근거 문서 § 병기는 드래프터 보고에서 수기 취합)
node -e "const fs=require('fs');const g=require('glob');let out=[];for(const f of fs.readdirSync('assets/content/clf').filter(x=>/^t{N}-.*\.questions\.json$/.test(x))){const j=JSON.parse(fs.readFileSync('assets/content/clf/'+f));out.push(...j.questions.filter(q=>q.verified===false).map(q=>({file:f,...q})));}fs.writeFileSync('D:/workspace/clf-d{N}-q15-drafts_for_review.json',JSON.stringify(out,null,2));console.log('추출:',out.length,'문항');"
```
**STOP — 사람 검수.** 추출 파일 `D:\workspace\clf-d{N}-q15-drafts_for_review.json`을 사용자가 검토하고 피드백을 줄 때까지 **다음 스텝(flip) 진행 금지.**

### 절차 E: flip + questionCount 상향 + 커밋 (검수 피드백 반영 후)

1. 검수 피드백을 해당 문항에 반영(수정/삭제). 통과 문항만 `"verified": false` → `"verified": true`로 변경.
2. 배치 각 task의 `content_index.dart` `questionCount: 12` → `15` (아래 task별 정확한 앵커 사용).
3. `cd flutter_app && flutter test` 그린(content_index_test 정합 포함).
4. 컨트롤러 재실측: 각 파일 `true=15 false=0`.
5. 커밋: `git commit -m "chore(content): clf D{N} 문항 검수 반영 — Task당 15 verified"`

---

## Task 0: 사전 베이스라인 확인

**Files:** 없음(읽기·검증만)

- [ ] **Step 1: 작업 브랜치 분기 (전역 규칙 기준)**

`develop` 부재 시 먼저 생성(전역 규칙). 사용자가 스펙대로 main 직접 머지를 택했으면 (B)로:
```bash
# (A) 전역 규칙: develop 경유
git rev-parse --verify develop 2>/dev/null || (git checkout -b develop main && git push -u origin develop)
git checkout develop && git checkout -b feat/clf-q15-d1
# (B) 스펙 경로: main에서 직접
# git checkout main && git checkout -b feat/clf-q15-d1
```

- [ ] **Step 2: 베이스라인 그린 확인**

Run: `cd flutter_app && flutter test`
Expected: `All tests passed!` (현재 499 케이스 기준)

- [ ] **Step 3: 베이스라인 문항 수 확인**

Run:
```bash
cd flutter_app && for f in assets/content/clf/t*.questions.json; do echo "$(basename $f) $(grep -c '"verified": true' $f)"; done
```
Expected: 19개 전부 `12`.

---

## Task 1: D1 배치 (t1-1 ~ t1-4) — +12문항

**Files:**
- Modify: `flutter_app/assets/content/clf/t1-1.questions.json` ~ `t1-4.questions.json` (각 q13~q15 추가)
- Modify: `flutter_app/lib/data/content_index.dart` (t1-1~t1-4의 questionCount 12→15, flip 후)
- Review artifact: `D:\workspace\clf-d1-q15-drafts_for_review.json`

- [ ] **Step 1: 브랜치 확인** — `feat/clf-q15-d1` 위인지 `git branch --show-current`로 확인.

- [ ] **Step 2: 드래프터 4개 디스패치(병렬)** — 절차 A를 t1-1·t1-2·t1-3·t1-4에 적용(`X-Y` = `1-1`..`1-4`).

- [ ] **Step 3: 초안 커밋** — 절차 A 하단 커밋(D{N}=D1).

- [ ] **Step 4: 리뷰어 디스패치** — 절차 B(D{N}=D1).

- [ ] **Step 5: 컨트롤러 실측** — 절차 C(`t{N}` = `t1`). 기대: t1-1~t1-4 각 `true=12 false=3`, 테스트 그린.

- [ ] **Step 6: 검수 파일 추출 + STOP** — 절차 D(`{N}`=1, glob `^t1-`). **사람 검수 대기.**

- [ ] **Step 7: flip + questionCount 상향** — 절차 E. content_index.dart 편집(4곳):

```
// t1-1
  questionsAsset: 'assets/content/clf/t1-1.questions.json',
  questionCount: 12,   →   questionCount: 15,
// t1-2
  questionsAsset: 'assets/content/clf/t1-2.questions.json',
  questionCount: 12,   →   questionCount: 15,
// t1-3
  questionsAsset: 'assets/content/clf/t1-3.questions.json',
  questionCount: 12,   →   questionCount: 15,
// t1-4
  questionsAsset: 'assets/content/clf/t1-4.questions.json',
  questionCount: 12,   →   questionCount: 15,
```
(각 task는 `questionsAsset` 줄 + 바로 다음 `questionCount` 줄을 2줄 앵커로 묶어 편집 — 경로가 고유하므로 안전.)

- [ ] **Step 8: 테스트 + 실측** — `cd flutter_app && flutter test` 그린; t1-1~t1-4 각 `true=15 false=0`.

- [ ] **Step 9: 커밋** — `git commit -m "chore(content): clf D1 문항 검수 반영 — Task당 15 verified"`

- [ ] **Step 10: 머지**
```bash
# (A) 전역 규칙: develop으로 PR → 머지 → 브랜치 삭제
gh pr create --base develop --head feat/clf-q15-d1 --title "clf D1 문항 ≥15" --body "스펙 2026-06-12 §6. 검수 반영 완료."
# CI 그린 확인 후 머지(merge commit). 머지 후:
git checkout develop && git pull && git branch -d feat/clf-q15-d1
# (B) 스펙 경로: main 직접 머지
# git checkout main && git merge --no-ff feat/clf-q15-d1 && flutter test && git push && git branch -d feat/clf-q15-d1
```

---

## Task 2: D2 배치 (t2-1 ~ t2-4) — +12문항

**Files:**
- Modify: `flutter_app/assets/content/clf/t2-1.questions.json` ~ `t2-4.questions.json`
- Modify: `flutter_app/lib/data/content_index.dart` (t2-1~t2-4 questionCount 12→15)
- Review artifact: `D:\workspace\clf-d2-q15-drafts_for_review.json`

- [ ] **Step 1: 브랜치 분기** — `git checkout develop && git checkout -b feat/clf-q15-d2` (스펙 경로면 main에서).

- [ ] **Step 2: 드래프터 4개 디스패치(병렬)** — 절차 A를 `2-1`..`2-4`에 적용.

- [ ] **Step 3: 초안 커밋** — 절차 A 커밋(D2).

- [ ] **Step 4: 리뷰어 디스패치** — 절차 B(D2).

- [ ] **Step 5: 컨트롤러 실측** — 절차 C(`t{N}`=`t2`). 기대: t2-1~t2-4 각 `true=12 false=3`.

- [ ] **Step 6: 검수 파일 추출 + STOP** — 절차 D(`{N}`=2, glob `^t2-`). **사람 검수 대기.**

- [ ] **Step 7: flip + questionCount 상향** — 절차 E. content_index.dart 편집(4곳, t2-1~t2-4의 `questionsAsset`+`questionCount` 2줄 앵커, 12→15).

- [ ] **Step 8: 테스트 + 실측** — `flutter test` 그린; t2-1~t2-4 각 `true=15 false=0`.

> **주의:** 회귀 가드 `test/question_model_test.dart`가 **t2-1**을 로드한다. flip 후 t2-1 verified=15이므로 `>= 12` 단언은 계속 통과(가드 상향은 D4 Step에서).

- [ ] **Step 9: 커밋** — `git commit -m "chore(content): clf D2 문항 검수 반영 — Task당 15 verified"`

- [ ] **Step 10: 머지** — Task 1 Step 10과 동일 경로(브랜치명 `feat/clf-q15-d2`).

---

## Task 3: D3 배치 (t3-1 ~ t3-8) — +24문항 (최대 배치)

**Files:**
- Modify: `flutter_app/assets/content/clf/t3-1.questions.json` ~ `t3-8.questions.json`
- Modify: `flutter_app/lib/data/content_index.dart` (t3-1~t3-8 questionCount 12→15)
- Review artifact: `D:\workspace\clf-d3-q15-drafts_for_review.json`

- [ ] **Step 1: 브랜치 분기** — `feat/clf-q15-d3`.

- [ ] **Step 2: 드래프터 8개 디스패치** — 절차 A를 `3-1`..`3-8`에 적용. 병렬 동시성 한계(주 환경 ~10)를 넘지 않으므로 8개 동시 가능하나, 검수 부담이 최대 배치임을 인지(스펙 §9 리스크).

- [ ] **Step 3: 초안 커밋** — 절차 A 커밋(D3).

- [ ] **Step 4: 리뷰어 디스패치** — 절차 B(D3). 8개 task 전수 대조라 리뷰 분량 최대.

- [ ] **Step 5: 컨트롤러 실측** — 절차 C(`t{N}`=`t3`). 기대: t3-1~t3-8 각 `true=12 false=3`.

- [ ] **Step 6: 검수 파일 추출 + STOP** — 절차 D(`{N}`=3, glob `^t3-`). **사람 검수 대기.**

- [ ] **Step 7: flip + questionCount 상향** — 절차 E. content_index.dart 편집(8곳, t3-1~t3-8).

- [ ] **Step 8: 테스트 + 실측** — `flutter test` 그린; t3-1~t3-8 각 `true=15 false=0`.

- [ ] **Step 9: 커밋** — `git commit -m "chore(content): clf D3 문항 검수 반영 — Task당 15 verified"`

- [ ] **Step 10: 머지** — 동일 경로(`feat/clf-q15-d3`).

---

## Task 4: D4 배치 (t4-1 ~ t4-3) — +9문항 + 밀도 가드 상향

**Files:**
- Modify: `flutter_app/assets/content/clf/t4-1.questions.json` ~ `t4-3.questions.json`
- Modify: `flutter_app/lib/data/content_index.dart` (t4-1~t4-3 questionCount 12→15)
- Modify: `flutter_app/test/question_model_test.dart:18` (밀도 가드 12→15)
- Review artifact: `D:\workspace\clf-d4-q15-drafts_for_review.json`

- [ ] **Step 1: 브랜치 분기** — `feat/clf-q15-d4`.

- [ ] **Step 2: 드래프터 3개 디스패치(병렬)** — 절차 A를 `4-1`..`4-3`에 적용.

- [ ] **Step 3: 초안 커밋** — 절차 A 커밋(D4).

- [ ] **Step 4: 리뷰어 디스패치** — 절차 B(D4).

- [ ] **Step 5: 컨트롤러 실측** — 절차 C(`t{N}`=`t4`). 기대: t4-1~t4-3 각 `true=12 false=3`.

- [ ] **Step 6: 검수 파일 추출 + STOP** — 절차 D(`{N}`=4, glob `^t4-`). **사람 검수 대기.**

- [ ] **Step 7: flip + questionCount 상향** — 절차 E. content_index.dart 편집(3곳, t4-1~t4-3).

- [ ] **Step 8: 밀도 가드 상향**

`test/question_model_test.dart` 라인 18을 수정:
```dart
    expect(rawVerified, greaterThanOrEqualTo(12)); // 밀도 목표(Task당 ≥12 verified)
```
→
```dart
    expect(rawVerified, greaterThanOrEqualTo(15)); // 밀도 목표(Task당 ≥15 verified)
```

- [ ] **Step 9: 테스트 + 실측** — `cd flutter_app && flutter test` 그린(상향된 가드 포함); t4-1~t4-3 각 `true=15 false=0`. 전 19개 task `true=15` 최종 확인:
```bash
cd flutter_app && for f in assets/content/clf/t*.questions.json; do echo "$(basename $f) $(grep -c '"verified": true' $f)"; done
```
Expected: 19개 전부 `15`.

- [ ] **Step 10: 커밋** — `git commit -m "chore(content): clf D4 문항 검수 반영 + 밀도 가드 ≥15 상향 — 19 Task 전부 15 verified"`

- [ ] **Step 11: 머지 + 릴리스**
```bash
# (A) 전역 규칙: feat → develop 머지 후, 릴리스로 develop → main PR
gh pr create --base develop --head feat/clf-q15-d4 --title "clf D4 문항 ≥15 + 가드 상향" --body "스펙 2026-06-12 완료."
# 머지 후 릴리스 PR:
gh pr create --base main --head develop --title "release: CLF 문항 밀도 ≥15 (D1~D4)" --body "19 Task 전부 15 verified."
# (B) 스펙 경로: main 직접 머지
# git checkout main && git merge --no-ff feat/clf-q15-d4 && flutter test && git push
```
push = GitHub Pages 자동 배포(`.github/workflows/pages.yml`). 배포 후 라이브에서 한 task 모의고사/문항 수 dogfood 확인.

---

## Task 5: 핸드오프·문서 갱신

**Files:**
- Modify: `HANDOFF.md`
- Modify: `docs/superpowers/specs/2026-06-12-clf-question-density-15-design.md` (상태 → 완료)

- [ ] **Step 1: 스펙 상태 갱신** — 스펙 라인 4 `상태: 설계 승인됨(브레인스토밍) → 구현 플랜 대기` → `상태: 완료 — D1~D4 배포(YYYY-MM-DD), 19 Task 전부 15 verified, 밀도 가드 ≥15`.

- [ ] **Step 2: HANDOFF.md 갱신** — §0/§2에서 백로그 ① 완료 기록(285 verified, 난이도 applied 회복), 다음 후보를 ②SAA-C03 문항 / ③C-중량으로 정리.

- [ ] **Step 3: 메모리 갱신** — `[[question-bank-verified-workflow]]`·`[[content-density-loop]]`에 D1~D4 실적 1줄 반영.

- [ ] **Step 4: 커밋** — `git commit -m "docs(handoff): CLF 문항 밀도 ≥15 완료 기록 — 다음 ②SAA/③C-중량"`

---

## Self-Review (작성자 체크)

- **스펙 커버리지:** §2 목표(19×15, applied 회복, 문서 보강 0, verified=사람) → Task 1~4 + 드래프터/리뷰어 제약으로 커버. §4 문항 규칙 → 절차 A. §5 파이프라인 → 절차 A·B·C. §6 4배치 게이트 → Task 1~4 + 절차 D·E. §7 가드 상향 → Task 4 Step 8. §8 비범위(SAA/C-중량/앱코드) → 본 플랜 미포함(Task 5에서 다음 후보로만 기록).
- **플레이스홀더:** content_index 편집·가드 편집·검증 명령·커밋 메시지는 구체값. 문항 본문은 드래프터 산출물(설계상 실행 시 생성 — 플랜은 입력·제약·검증을 구체화).
- **타입/명명 일관:** `questionCount`·`verified`·`wrongExplanations`(문자열 키)·id `clf-tX-Y-q13..15`·브랜치 `feat/clf-q15-d{1..4}` 전 task 일관.
- **열린 항목:** 브랜치 전략(develop vs main 직접) — 실행 전 사용자 결정(상단 ⚠️ 블록).
