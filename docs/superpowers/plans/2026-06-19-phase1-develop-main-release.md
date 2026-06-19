# Phase 1 — 멀티 일정 develop→main 릴리스 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans (inline). **git/릴리스 작업이라 서브에이전트 위임 금지**(메모리 `subagent-git-branch-pollution`) — 컨트롤러 직접 실행. Steps use checkbox (`- [ ]`).

**Goal:** develop에 머지된 멀티 일정(PR#30)을 main에 릴리스하고 라이브로 확인한다.

**상황 (2026-06-19 실측):**
- `origin/main` = `2343260` (PR#29 `develop→main`). **C-중량 Phase2 + SAA 드래프트는 이미 main 릴리스됨**(라이브).
- `origin/develop` = `83d1fe7` (PR#30 멀티 일정 머지).
- `git log origin/main..origin/develop` = **멀티 일정 커밋만** → 남은 릴리스 = 멀티 일정 1건.
- `git log origin/develop..origin/feat/multi-plan-schedule` = 비어있음 → A 누락 0.

**이미 완료(원래 plan에서 제거된 단계):** A 검증·최신 develop 정합·A→develop 머지 = PR#30. C-중량 Phase2·SAA 드래프트 main 릴리스 = PR#29.

**Architecture:** 릴리스 전 develop 실측·검증 → develop→main PR → Pages 배포 → 라이브 dogfood. **코드 변경 없음**(이미 머지·CI 통과된 멀티 일정을 릴리스만).

**Tech Stack:** Flutter(`flutter test`/`analyze`, PowerShell), git, `gh` CLI, gstack browse(dogfood).

## Global Constraints

- flutter 명령은 **`flutter_app/` 기준 PowerShell**. Git Bash 금지(`--base-href` 변형, 메모리 `flutter-build-web-powershell`).
- **main 직접 커밋·push 금지. develop 경유 PR.** (git-branch-flow)
- **되돌리기 어려운 외부 작용(main 릴리스·배포)은 실행 직전 사용자 확인.**
- **릴리스 전 실측 검증 필수**(메모리 `stacked-pr-merge-order-race`).
- git 조작은 컨트롤러 직접(서브에이전트 위임 금지).
- 게이트: `flutter test` 전부 그린 · `flutter analyze` 신규 0건(기존 잔존 3건 = plan_agenda cacheExtent · sync_controller_test 2건 허용).
- CI/배포 대기는 `gh run watch`/`gh pr checks --watch` 블로킹 CLI로(sleep 폴링 금지 — 메모리 `harness-background-sleep-loops`).

---

### Task 1: 릴리스 전 develop 검증·실측

남은 릴리스 대상이 멀티 일정뿐이고 develop이 그린인지 확인한다.

**Interfaces:**
- Produces: develop의 그린 테스트 카운트(`N_dev`) — Task 3 dogfood 후 회귀 판정 기준.

- [ ] **Step 1: fetch + 남은 릴리스 대상 확인**

Run (Bash):
```bash
git fetch origin && git log origin/main..origin/develop --oneline
```
Expected: 멀티 일정 커밋만(PR#30 머지 `83d1fe7` + 멀티 일정 9커밋 + spec/plan 문서 `ad7d543`/`97ab3e7`/`400f046`). C-중량/SAA 커밋이 보이면 안 됨(이미 main에 있음).

- [ ] **Step 2: A 누락 0 확인**

Run (Bash):
```bash
git log origin/develop..origin/feat/multi-plan-schedule --oneline
```
Expected: **빈 출력**(멀티 일정이 develop에 온전히 반영).

- [ ] **Step 3: develop 테스트·분석 실측**

Run (PowerShell):
```powershell
git checkout develop; git pull origin develop
cd flutter_app; flutter test
```
Expected: `All tests passed!`. **그린 카운트를 `N_dev`로 기록.**

Run (PowerShell):
```powershell
flutter analyze
```
Expected: 신규 0건(기존 잔존 3건만).

- [ ] **Step 4: 게이트**

통과(멀티 일정만 릴리스 대상 + 누락 0 + 그린 + analyze 0) → Task 2. 실패 시 STOP, 원인 규명(절대조건 3). develop 테스트 실패면 멀티 일정 머지에 회귀가 있는 것 → 릴리스 보류, systematic-debugging.

---

### Task 2: develop → main PR · 머지 · 배포

- [ ] **Step 1: 릴리스 PR 생성**

Run (Bash):
```bash
gh pr create --base main --head develop \
  --title "release: 멀티 일정 학습 스케줄" \
  --body "$(cat <<'EOF'
## 릴리스 내용
멀티 일정 학습 스케줄(PR#30) — 자격증당 여러 독립 일정(자동/수동·목록·선택·삭제) + 일정별 진행.

(C-중량 Phase2·SAA 드래프트는 PR#29로 이미 릴리스됨 — 이번 릴리스 범위 아님.)

## 검증
- 릴리스 전 실측: main..develop = 멀티 일정만, A 누락 0
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

- [ ] **Step 3: 사용자 확인 게이트 (라이브 배포)**

**main 머지 = 즉시 라이브 배포(Pages).** **사용자에게 "멀티 일정을 main에 릴리스(라이브 배포)할까요?" 명시적 확인**을 받는다. 승인 전까지 머지 금지.

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
Expected: `pages.yml`(pub get → build web → deploy) 성공.

---

### Task 3: 라이브 dogfood

라이브: https://velkaressiablutkrone.github.io/aws-docs/ . gstack browse로 확인. 함정 주의(메모리 `flutter-web-dogfood-browse`): canvaskit 스크린샷 기반, taskId `clf-t1-1` 형식, 해시 goto≠리로드.

- [ ] **Step 1: 홈 로드 + 콘솔 에러 확인**

`https://velkaressiablutkrone.github.io/aws-docs/` 접속. Expected: 홈 렌더, 콘솔 에러 0(기존 Noto 한자 폴백 경고만 허용).

- [ ] **Step 2: 멀티 일정 동작(이번 릴리스 핵심)**

`#/cert/CLF-C02` → 학습 일정(plan) 진입. Expected: 일정 목록 화면(없으면 생성 폼). 자동/수동 생성 → 목록 카드 노출 → 카드 탭 → 어젠다(체크박스 진행) → 삭제 시 진행 초기화.

- [ ] **Step 3: 기릴리스 회귀 확인**

C-중량 Phase2: `#/cert/CLF-C02/report` 약점 개념 칩 렌더·딥링크 동작. SAA: `#/cert/SAA-C03` 모의고사 카드 미노출(verified:false). Expected: 둘 다 정상(멀티 일정 릴리스가 회귀를 안 냄).

- [ ] **Step 4: 최종 보고 + 문서 갱신**

dogfood 결과 요약. 이상 없으면 Phase 1 완료 — HANDOFF.md·WORKLIST.md를 "멀티 일정 릴리스됨"으로 갱신(별도 docs 커밋). 이상 발견 시 STOP, 원인 규명.

---

## Self-Review

- **현실 정합**: 원래 plan Task 1~3(A 검증·정합·머지)은 PR#30으로 완료됨을 실측 확인해 제거. C-중량/SAA는 PR#29 릴리스 확인해 범위에서 제외. 남은 릴리스(멀티 일정)만 3 Task로.
- **실측 검증**: Task 1 Step 1·2가 `git log` 범위로 릴리스 대상·누락을 확인(stacked-PR 교훈).
- **되돌리기 어려운 작용 게이트**: Task 2 Step 3(main 릴리스)에 사용자 확인.
- **No Placeholders**: 모든 step에 실제 명령·기대 출력. 카운트는 `N_dev`로 실행 시 기록.
- **회귀 가드**: Task 3 Step 3이 기릴리스 기능(C-중량/SAA)의 회귀를 dogfood로 확인.

## 비범위
- Phase 2(① SAA 검수 전용 뷰)·Phase 3(③ 섹션 앵커)는 이 plan 밖. 각자 brainstorm → spec → plan.
- 멀티 일정 후속(문서 열람 자동 마킹·기간 겹침 배지 등 Part 2 비범위).
