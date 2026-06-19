# Phase 1 — develop→main 릴리스 (+멀티 일정 A 검증·머지) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans (inline, 권장) to implement this plan task-by-task. **이 plan은 git/릴리스 작업이라 서브에이전트 위임을 금지한다**(메모리 `subagent-git-branch-pollution`) — 컨트롤러가 직접 실행한다. Steps use checkbox (`- [ ]`) syntax.

**Goal:** 멀티 일정 A를 검증·develop 머지한 뒤, develop(C-중량 Phase2 + SAA 드래프트 + A)을 실측 검증 후 main에 릴리스하고 라이브로 확인한다.

**Architecture:** 릴리스 파이프라인 — A 검증 → 최신 develop 정합 → A→develop PR → 릴리스 전 실측 → develop→main PR → Pages 배포 → 라이브 dogfood. 코드 변경은 A 검증에서 결함이 나올 때만(그땐 STOP 후 systematic-debugging); 나머지는 git·CI·검증 작업이다.

**Tech Stack:** Flutter(`flutter test`/`analyze`, PowerShell), git, `gh` CLI, gstack browse(dogfood).

## Global Constraints

- flutter 명령은 **`flutter_app/` 기준 PowerShell**로 실행한다. Git Bash 금지(`--base-href` 경로 변형, 메모리 `flutter-build-web-powershell`).
- **main 직접 커밋·push 금지. develop 경유 PR.** (git-branch-flow)
- **되돌리기 어려운 외부 작용(PR 머지·main 릴리스·배포)은 실행 직전 사용자 확인**을 받는다.
- **릴리스 전 실측 검증 필수**: claimed 산출물이 실제 origin/develop에 있는지 직접 확인(메모리 `stacked-pr-merge-order-race`).
- git 조작은 컨트롤러가 직접 한다(서브에이전트 위임 금지).
- 검증 게이트: `flutter test` 전부 그린 · `flutter analyze` 신규 0건(기존 잔존 3건 = plan_agenda cacheExtent · sync_controller_test 2건은 허용).
- CI/배포 대기는 `gh run watch` 같은 블로킹 CLI로(sleep 폴링 루프 금지 — 메모리 `harness-background-sleep-loops`).

---

### Task 1: 멀티 일정(A) 종료조건 검증

대상 브랜치: `feat/multi-plan-schedule`. 코드 변경 없음(검증만). 종료조건이 충족되는지 눈으로 확인한다.

**Interfaces:**
- Produces: A의 현재 그린 테스트 카운트(`N_A`) — Task 4의 릴리스 실측에서 기준선으로 재사용.

- [ ] **Step 1: 브랜치 체크아웃 + 워킹트리 클린 확인**

Run (Bash):
```bash
git checkout feat/multi-plan-schedule && git status
```
Expected: `On branch feat/multi-plan-schedule`, `nothing to commit, working tree clean`.

- [ ] **Step 2: 전체 테스트 실행**

Run (PowerShell):
```powershell
cd flutter_app; flutter test
```
Expected: `All tests passed!`. **출력의 그린 카운트를 `N_A`로 기록한다**(예: "+NNN").

- [ ] **Step 3: 정적 분석 실행**

Run (PowerShell):
```powershell
flutter analyze
```
Expected: 신규 0건. 기존 잔존 3건(plan_agenda cacheExtent · sync_controller_test 2건) 외 새 항목이 보이면 게이트 실패.

- [ ] **Step 4: 게이트 판정**

- 통과(테스트 그린 + analyze 신규 0) → Task 2.
- 실패 → **STOP.** 추측으로 고치지 않는다(절대조건 3). 원인을 systematic-debugging으로 규명하고 TDD로 수정한다(이 plan의 범위 밖 — 별도 디버깅 사이클). 수정 불가/지연이면 §리스크 폴백(A 제외, develop만 릴리스 = Task 4부터 A 빼고 진행)을 사용자와 결정.

---

### Task 2: A를 최신 develop에 정합

develop이 분기 후 진행됨(`3d178e1 → 83d1fe7`, 2026-06-19 fetch 확인). A를 develop에 머지하기 전에 최신 develop을 A에 병합해 충돌·정합을 먼저 해소한다.

- [ ] **Step 1: 최신 develop fetch**

Run (Bash):
```bash
git fetch origin develop && git log --oneline -1 origin/develop
```
Expected: `origin/develop` tip 출력(최소 `83d1fe7` 이상). tip SHA를 기록.

- [ ] **Step 2: develop을 A에 병합**

Run (Bash):
```bash
git checkout feat/multi-plan-schedule && git merge origin/develop
```
Expected: 충돌 없으면 merge 커밋 생성 또는 fast-forward. **충돌이 나면 STOP** — 충돌 파일을 직접 정독해 해소(추측 금지). 해소 후 `git add <파일> && git commit`.

- [ ] **Step 3: 병합 후 재검증**

Run (PowerShell):
```powershell
cd flutter_app; flutter test; flutter analyze
```
Expected: `All tests passed!`(카운트 ≥ `N_A`, 병합으로 develop 테스트가 합쳐지면 증가 가능) · analyze 신규 0건.

- [ ] **Step 4: 게이트**

통과 → Task 3. 실패 → STOP, 원인 규명(병합으로 드러난 충돌·회귀). 새 그린 카운트를 `N_A'`로 갱신 기록.

---

### Task 3: A → develop PR · 머지

- [ ] **Step 1: 브랜치 push**

Run (Bash):
```bash
git push -u origin feat/multi-plan-schedule
```
Expected: push 성공(또는 already up-to-date + 병합 커밋 반영).

- [ ] **Step 2: develop PR 생성**

Run (Bash):
```bash
gh pr create --base develop --head feat/multi-plan-schedule \
  --title "feat(plan): 멀티 일정 학습 스케줄(자동/수동·목록·일정별 진행)" \
  --body "$(cat <<'EOF'
## 요약
자격증당 여러 독립 학습 일정(자동/수동 생성·목록·선택·삭제) + 일정별 진행.

- 데이터(Part 1): StudyPlan 확장·planId itemId·StudyPlanStore 리스트화(v1→v2 마이그레이션)·PlanProgressStore·computePlanDone planId 스코프
- UI(Part 2): plan_page 일정 목록→선택·PlanAgenda planId 진행·자동/수동 생성 폼·home 합산

## 검증
- flutter test 전체 그린 · flutter analyze 신규 0건
- spec: docs/designs/2026-06-19-multi-plan-study-schedule-spec.md
- plan: docs/plans/2026-06-19-multi-plan-schedule-part1-data.md · part2-ui.md

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```
Expected: PR URL 출력.

- [ ] **Step 2.5: 멀티 일정 spec/plan 문서가 PR에 포함됐는지 확인**

Run (Bash):
```bash
git diff --name-only origin/develop...feat/multi-plan-schedule | grep -E "multi-plan"
```
Expected: `docs/designs/2026-06-19-multi-plan-study-schedule-spec.md` · `docs/plans/2026-06-19-multi-plan-schedule-part1-data.md` · `part2-ui.md`가 목록에 있음(WORKLIST.md의 링크가 develop 머지 후 유효해짐).

- [ ] **Step 3: CI 녹색 대기**

Run (Bash):
```bash
gh pr checks --watch
```
Expected: 모든 체크 pass.

- [ ] **Step 4: 사용자 확인 게이트(머지)**

머지는 되돌리기 번거롭다. **사용자에게 "A를 develop에 머지할까요?" 확인을 받는다.** 승인 전까지 머지하지 않는다.

- [ ] **Step 5: 머지**

Run (Bash):
```bash
gh pr merge --merge --delete-branch=false
```
Expected: Merged.

- [ ] **Step 6: 머지 실측**

Run (Bash):
```bash
git fetch origin develop && git log origin/develop..origin/feat/multi-plan-schedule --oneline
```
Expected: **빈 출력**(A가 develop에 온전히 반영 = stacked-PR 누락 없음).

---

### Task 4: 릴리스 전 실측 검증 (develop → main)

main(PR#8, `32e0dc4`) 대비 develop에 쌓인 claimed 산출물이 실제로 develop에 있는지 직접 확인한다.

- [ ] **Step 1: 전체 fetch**

Run (Bash):
```bash
git fetch origin
```

- [ ] **Step 2: claimed 산출물의 develop 반영 확인**

Run (Bash):
```bash
for b in feat/concept-report feat/saa-q-d1 feat/saa-q-d2 feat/saa-q-d3 feat/saa-q-d4 feat/multi-plan-schedule; do
  echo "== $b =="; git log origin/develop..origin/$b --oneline
done
```
Expected: **모든 브랜치에서 빈 출력**(전부 develop에 머지됨). 비어있지 않은 브랜치가 있으면 그 변경이 develop에 누락된 것 → STOP, 복구 PR 먼저(메모리 `stacked-pr-merge-order-race`).

- [ ] **Step 3: main 대비 develop 릴리스 내용 일람**

Run (Bash):
```bash
git log origin/main..origin/develop --oneline
```
Expected: PR#21(C-중량 Phase2) · PR#22~25(SAA 드래프트) · 멀티 일정 · 기타(`83d1fe7` 포함) 커밋이 보임. 릴리스에 들어갈 내용을 사용자에게 요약 보고.

- [ ] **Step 4: develop 테스트 카운트 실측**

Run (PowerShell):
```powershell
git checkout develop; git pull origin develop
cd flutter_app; flutter test; flutter analyze
```
Expected: `All tests passed!`(카운트가 Task 2의 `N_A'`와 정합 — 멀티 일정 머지가 반영된 수). analyze 신규 0건. **불일치 = 누락 신호 → STOP.**

- [ ] **Step 5: 게이트**

전부 통과 → Task 5.

---

### Task 5: develop → main PR · 머지 · 배포

- [ ] **Step 1: 릴리스 PR 생성**

Run (Bash):
```bash
gh pr create --base main --head develop \
  --title "release: C-중량 Phase2 + SAA 문항 드래프트 + 멀티 일정" \
  --body "$(cat <<'EOF'
## 릴리스 내용
- C-중량 개념→섹션 앵커 딥링크 Phase 2 (약점 리포트 개념 칩) — 라이브 노출
- SAA-C03 문항 360개 드래프트(verified:false) — 화면 변화 없음(가드 테스트 동반)
- 멀티 일정 학습 스케줄 — 라이브 노출

## 검증
- 릴리스 전 실측 검증 완료(claimed 산출물 develop 반영 확인)
- flutter test 전체 그린 · flutter analyze 신규 0건

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```
Expected: PR URL 출력.

- [ ] **Step 2: CI 녹색 대기**

Run (Bash):
```bash
gh pr checks --watch
```
Expected: 모든 체크 pass.

- [ ] **Step 3: 사용자 확인 게이트(라이브 배포)**

**main 머지 = 즉시 라이브 배포(Pages).** 되돌리기 어려운 외부 작용이다. **사용자에게 "main에 릴리스(라이브 배포)할까요?" 명시적 확인**을 받는다. 승인 전까지 머지하지 않는다.

- [ ] **Step 4: 머지**

Run (Bash):
```bash
gh pr merge --merge
```
Expected: Merged.

- [ ] **Step 5: Pages 배포 대기**

Run (Bash):
```bash
gh run watch
```
Expected: `pages.yml`(pub get → build web → deploy) 워크플로 성공.

---

### Task 6: 라이브 dogfood

라이브: https://velkaressiablutkrone.github.io/aws-docs/ . gstack browse로 확인한다. 함정 주의(메모리 `flutter-web-dogfood-browse`): canvaskit이라 스크린샷 기반 검증, taskId는 `clf-t1-1` 형식, 해시 goto는 풀 리로드 아님.

- [ ] **Step 1: 홈 로드 + 콘솔 에러 확인**

gstack browse로 `https://velkaressiablutkrone.github.io/aws-docs/` 접속. Expected: 홈 렌더, 콘솔 에러 0(기존 Noto 한자 폴백 경고만 허용).

- [ ] **Step 2: C-중량 Phase2 — 약점 리포트 개념 칩**

`#/cert/CLF-C02/report` 접속. Expected: 약점 Task별 "놓친 개념" 칩 렌더. 칩 클릭 → `#/cert/CLF-C02/study/clf-t1-1?at=<section>`로 섹션 딥링크(헤더 보정 스크롤). 미존재 앵커는 문서 최상단 폴백.

- [ ] **Step 3: 멀티 일정 동작**

`#/cert/CLF-C02` → 학습 일정(plan) 진입. Expected: 일정 목록 화면(없으면 생성 폼). 자동/수동 생성 → 목록 카드 노출 → 카드 탭 → 어젠다(체크박스 진행) → 삭제 시 진행 초기화.

- [ ] **Step 4: SAA 화면 변화 0 확인**

`#/cert/SAA-C03` 접속. Expected: 학습문서 24개 노출, **모의고사 카드·문항 배지 미노출**(360 드래프트는 `verified:false`라 게이트로 숨김). "문항 준비 중" 상태 유지.

- [ ] **Step 5: 최종 보고**

dogfood 결과(스크린샷·콘솔)를 요약. 이상 발견 시 STOP하고 원인 규명. 이상 없으면 Phase 1 완료 — HANDOFF.md·WORKLIST.md를 릴리스 반영 상태로 갱신(별도 docs 커밋).

---

## Self-Review

- **Spec 커버리지(§4 Phase 1)**: 4a 검증(Task 1) · 4b develop 머지(Task 2 정합 + Task 3 PR/머지) · 4c 실측 검증·릴리스(Task 4·5) · 라이브 dogfood(Task 6). spec §4 전 항목 커버.
- **develop 갱신 반영**: `83d1fe7`을 Task 2(정합)·Task 4(실측)에서 다룸.
- **리스크 폴백**: Task 1 Step 4·Task 2 Step 4에서 A 검증 실패 시 STOP + "A 제외, develop만 릴리스"(Task 4부터 A 빼고) 분기를 명시. spec §7 정합.
- **되돌리기 어려운 작용 게이트**: Task 3 Step 4(develop 머지)·Task 5 Step 3(main 릴리스)에 사용자 확인 게이트.
- **실측 검증**: Task 3 Step 6·Task 4 Step 2가 `git log origin/develop..origin/<feature>` 빈 출력으로 누락 0 확인.
- **No Placeholders**: 모든 step에 실제 명령·기대 출력. 카운트는 `N_A`/`N_A'`로 실행 시 기록(하드코딩 추측 회피).
- **타입/명령 일관성**: 브랜치명(`feat/multi-plan-schedule`)·릴리스 경로(develop→main)·검증 명령(`flutter test`/`analyze`)이 Task 간 일치.

## 비범위
- Phase 2(① SAA 검수 전용 뷰)·Phase 3(③ 섹션 앵커)는 이 plan 밖. 각자 착수 시점에 brainstorm → spec → plan.
- A 검증에서 결함 발견 시의 구체 수정(systematic-debugging 별도 사이클).
