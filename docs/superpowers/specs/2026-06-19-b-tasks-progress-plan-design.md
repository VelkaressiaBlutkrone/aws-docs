# B 작업 진행 계획 — 설계 spec

- 날짜: 2026-06-19
- 상태: 설계 승인 → 구현 plan 입력 대기 (writing-plans)
- 출처: [WORKLIST.md](../../../WORKLIST.md) §B (다음 작업 우선순위)
- 영향 범위: 릴리스 절차(develop→main) · `feat/multi-plan-schedule` · SAA 문항 뱅크(`assets/content/saa/`) · 학습문서 섹션 앵커

## 1. 배경 / 목표

[WORKLIST.md](../../../WORKLIST.md) §B의 세 작업을 **파이프라인**으로 진행한다.

- **①** SAA-C03 360문항(전부 `verified:false` 드래프트) 사람 검수 → `verified:true` flip
- **②** develop → main 릴리스 (현재 main=PR#8, develop은 그보다 앞섬: C-중량 Phase2 + SAA 드래프트)
- **③** 학습문서 `{#id}` 섹션 앵커 점진 채움

세 작업은 **성격·행위자가 다르다**: ①은 사람 검수가 본질(AI flip 금지 철칙), ②는 즉시 실행 가능하며 멀티 일정(A)과 묶임, ③은 graceful 폴백이 있어 비차단 점진 작업. 이 계획은 **첫 타자 ②(+A)를 상세 설계**하고, ①③은 방향·게이트만 잡는다(각자 상세는 별도 brainstorm 사이클).

## 2. 결정 사항 (확정)

| 항목 | 결정 |
|---|---|
| 계획 범위 | 전체 순서 + 첫 타자(②) 상세 |
| 첫 타자 | ② 릴리스 = A 검증 → develop 머지 → develop 전체를 main 릴리스 (멀티 일정도 라이브) |
| ① 보조 범위 | **검수 전용 뷰**(문항 나열·체크·메모·flip 토글) + 기계적 플래그 + flip 절차·동기화. 검수 판단·flip 결정은 사용자 몫 |
| ③ 위치 | 점진, 병렬 (① 검수 대기시간 활용) |
| 진행 시퀀스 | 파이프라인(병렬) |

## 3. 전체 시퀀스 (파이프라인)

```
Phase 1 [나, 즉시]      ②+A 릴리스 ──────────────┐
                                                  ▼
Phase 2 [나]            ① 검수 전용 뷰 구축 ──────┐
                                                  ▼
Phase 3 [병렬]   ┌─ 사용자: SAA 검수(장기) ──→ 배치 완료마다 ─→ 나: flip·동기화
                 └─ 나: ③ 섹션 앵커 점진(검수 대기시간 활용)
```

핵심: ① 검수(사용자 장기 작업)와 ③ 앵커(내 작업)가 **독립적이라 병렬** → 대기시간 0.

## 4. Phase 1 — ②+A 릴리스 (상세)

> **2026-06-19 실측 정정:** 이 설계 작성 직후 확인 결과, A는 PR#30으로 develop에 이미 머지됐고 C-중량 Phase2·SAA 드래프트는 PR#29로 이미 main 릴리스됨. **남은 Phase 1 = 멀티 일정 develop→main 릴리스만.** 실행 plan은 이 현실을 반영해 단순화됨(`docs/superpowers/plans/2026-06-19-phase1-develop-main-release.md`). 아래 4a·4b는 설계 기록으로 보존.

### 4a. A(멀티 일정) 검증
- `feat/multi-plan-schedule`에서 `flutter test` 전체 그린 + `flutter analyze` 신규 0건을 **눈으로 확인**(종료조건, 현재 미검증).
- 실패 시 TDD(절대조건 2)로 수정 후 재확인. 막히면 §7 리스크 폴백으로.

### 4b. A → develop 머지
- `feat/multi-plan-schedule` → `develop` PR (git-branch-flow 준수, main 직접 금지).
- ⚠️ **develop이 분기 후 진행됨**(`3d178e1 → 83d1fe7`, 2026-06-19 fetch에서 확인) → 머지 전 최신 develop과의 충돌·정합 확인.
- CI 녹색 확인 후 머지.

### 4c. develop → main 릴리스 (실측 검증 필수)
- **stacked-PR 교훈 적용**(메모리 `stacked-pr-merge-order-race`): claimed 산출물이 실제 develop에 있는지 직접 확인.
  - `git log origin/develop..origin/<feature>`가 비었는지 — PR#21(C-중량 Phase2) · PR#22~25(SAA 드래프트) · A.
  - `flutter test` 카운트가 기준선과 일치하는지 (불일치 = 누락 신호).
- `develop` → `main` PR → CI 녹색 → 머지 → Pages 자동 배포.
- **라이브 dogfood**: C-중량 Phase2(약점 리포트 개념 칩·섹션 딥링크) 동작 · 멀티 일정 동작 · SAA는 화면 변화 0 확인(`verified:false`).

## 5. Phase 2 — ① 검수 전용 뷰 (방향)

- **산출물**: 검수 전용 화면/스크립트 — `verified` 무시하고 전체 표시, 문항 나열·체크·메모·flip 토글.
- **기계적 플래그**(품질 판단 아님): 정답 인덱스 쏠림 · `wrongExplanations` 키 누락/불일치 · 출처 URL 범위 이탈 · `options`≠4 등. 기존 `test/saa_questions_test.dart` 가드를 확장.
- **flip 절차**: 검수 완료 Task → `verified:true` + `content_index.dart` questionCount 동기화 + 밀도 가드·테스트 갱신. 동기화 함정은 메모리 `question-bank-verified-workflow` 참조.
- **철칙**: AI flip 금지, 품질 판단은 사용자.
- ※ **상세 구현은 별도 brainstorm 사이클** — 이 계획은 틀·게이트만.

## 6. Phase 3 — ③ 섹션 앵커 (방향, 병렬)

- 사용자 검수 대기 중 진행. 학습문서 `{#id}` 앵커 점진 채움(C-중량은 `clf-t1-1`만 시드).
- graceful 폴백(앵커 없으면 문서 최상단)이 있어 비차단 → 우선순위·범위는 점진적으로.

## 7. 게이트 / 비범위 / 리스크

### 게이트
- 각 단계 `flutter test` 그린 · `flutter analyze` 신규 0건.
- 릴리스: CI 녹색 + 실측 검증(§4c) + 라이브 dogfood.
- 브랜치: main 직접 금지, develop 경유 PR (git-branch-flow).

### 비범위 (YAGNI)
- ① 검수 뷰 상세 구현 (별도 사이클).
- ③ 전 문서 앵커 일괄 (점진).
- 멀티 일정 후속 — 문서 열람 시 일정 진행 자동 마킹, 기간 겹침 배지 등 (Part 2 비범위).

### 리스크 / 폴백
- **A 검증 실패** → 릴리스 지연 대신 **A 제외하고 develop만 릴리스**(C-중량 Phase2 우선 라이브) 후 A를 별도 트랙으로.
- **stacked-PR 누락** → §4c 실측 검증 절차로 완화.
- **develop 분기 후 진행**(`83d1fe7`) → 4b·4c에서 최신 develop 재확인.

## 8. 다음 단계
writing-plans 스킬로 Phase 1(②+A 릴리스)의 구현 plan을 작성한다. Phase 2·3은 방향만 잡혔으므로, 착수 시점에 각자 brainstorm → spec → plan 사이클을 별도로 돈다.
