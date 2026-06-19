# 멀티 일정 학습 스케줄 재설계 — 설계 spec

- 날짜: 2026-06-19
- 상태: 설계 승인 → 구현 plan 입력 대기
- 영향 모듈: `models/study_plan`, `data/study_plan_store`, `data/plan_scheduler`, `data/plan_progress`, `data/viewed_docs_store`, `data/study_reset`, `pages/plan_page`, `pages/plan/plan_agenda`, `pages/plan/plan_create_form`

## 1. 배경 / 문제

현재 학습 일정은 **자격증당 단일 plan**이다(`StudyPlanStore`가 `certCode`를 키로 덮어쓰기). `buildPlan`이 한 일정에 학습45 / 연습20 / 모의20 / 보강15(%)를 자동 분배한다.

- **문제 #1 — 여러 일정 불가**: 한 자격증에 일정을 하나만 둘 수 있다. 사용자는 "오늘부터 1주는 문서 A~B, 다음 3일은 연습, 다음 1주는 문서 C~D, 마지막은 모의고사"처럼 **구간별로 다른 학습 블록**을 만들고 싶어 한다.
- **문제 #2 — 다시 만들기 시 진도 유지**: "다시 만들기"는 plan만 덮어쓰고 진도는 건드리지 않는다. 진도는 `ViewedDocsStore`(열람)·`HistoryStore`(응시)·`PlanCheckStore`(수동 체크)에 **자격증 전역으로 별도 저장**돼, 일정을 다시 만들어도 완료 표시가 유지된다 → "다시 만든 의미가 없다".

## 2. 목표

- 자격증당 **여러 독립 일정** (추가 / 삭제 / 편집)
- 각 일정 = **기간 + 유형 + Task 범위**
- **일정별 독립 진행** — 일정 삭제/교체 시 그 일정 진행만 초기화
- **자동 + 수동** 생성 둘 다 지원

## 3. 결정 사항 (확정)

| 항목 | 결정 |
|---|---|
| 일정 형태 | 자격증당 독립 일정 N개 (cert → plan 리스트) |
| 일정 구성 | 기간 + 유형(문서/연습/모의/약점/점검) + Task 다중 선택 범위 |
| 진행 추적 | 일정별 독립 (planId 스코프) |
| 초기화 범위 | 일정 진행만 리셋 — 전역 열람·오답노트·응시이력은 보존 |
| 자동/수동 | 둘 다 지원 (한 일정은 auto 또는 manual, 혼합 아님) |
| 어젠다 표시 | 일정 목록 → 선택 |
| 기간 겹침 | 허용 (안내만, 차단하지 않음) |
| 기존 데이터 | 단일 plan → 리스트 첫 요소로 자동 마이그레이션 |

## 4. 데이터 모델

### StudyPlan (확장)
```
StudyPlan {
  id: String              // 신규 — 일정 고유 ID(진행 스코프 키)
  label: String           // 표시명 (예: "1주차 문서", "연습 스프린트")
  startIso, endIso: String
  source: auto | manual   // 생성 방식(편집 UI 분기)
  // manual 전용:
  planType: docs | practice | mockExam | weakExam | finalReview
  taskIds: List<String>   // docs·practice일 때 선택한 Task
  // 공통:
  items: List<PlanItem>   // 자동=buildPlan 결과, 수동=빌더 생성. 어젠다·진행의 단위
}
```
자동·수동 모두 최종적으로 `items`로 환원된다 → 어젠다·진행 로직은 통일된 `items` 위에서 동작한다. `PlanItem.id`는 planId를 포함해 일정 간 충돌이 없어야 한다(예: `{planId}:{type}:{refId}:{i}`).

### 저장소
- `StudyPlanStore`: `certCode → List<StudyPlan>` (현재 단일 → 리스트). 신규 키 `awsdocs.plan.v2`.
- 신규 `PlanProgressStore`: `planId → Set<itemId>`(완료 항목). 일정별 격리, 일정 삭제 시 해당 planId 엔트리 제거.

## 5. 동작

### 생성
- **추천 자동 생성**: 현재 생성 폼(기간/모드) + `buildPlan` → `source:auto` 일정 1개. 기존 흐름 보존.
- **직접 추가**: 유형 선택 → 기간 → (문서·연습이면) Task 다중 체크 → 빌더가 해당 유형 `items` 생성 → `source:manual` 일정 1개.

### 진행 판정 (일정별 독립)
- 일정 item 완료 = `PlanProgressStore[planId]`에 itemId가 있을 때.
- **문서 항목**: 그 일정 어젠다에서 문서를 열면(planId·itemId 전달) 해당 일정 진행에 자동 완료 추가 + 전역 `ViewedDocsStore`에도 열람 기록. **전역 열람은 일정 완료 판정에 사용하지 않는다**(독립성 보장 — #2의 핵심).
- **퀴즈/모의 항목**: 응시 시 전역 `HistoryStore` 기록 + 해당 planId item 완료.
- **수동 체크**: 어젠다 체크박스 → `PlanProgressStore` 토글.

### 초기화 / 삭제
- 일정 삭제·교체 = `PlanProgressStore.clearPlan(planId)`. **전역 `ViewedDocsStore`·`HistoryStore`·오답노트는 보존** → 새 일정은 미완료로 시작하되 "실제 본 문서"와 학습 자산은 유지.

## 6. UI

- **어젠다 화면**: 자격증의 일정 **목록**(카드: 라벨·기간·유형·진행률) → 탭하면 그 일정의 날짜별 어젠다(현재 `PlanAgenda` 재사용, 진행은 planId 스코프).
- **생성 진입**: "추천 자동 생성" + "직접 추가" 두 경로.
- **편집/삭제**: 일정 카드의 액션.
- 구체 레이아웃·간격·모션은 `DESIGN.md`를 따르며 구현(designer) 단계에서 확정한다.

## 7. 마이그레이션
- `awsdocs.plan.v1`(단일 `{ certCode: plan }`) → `awsdocs.plan.v2`(`{ certCode: [plan] }`). 첫 로드 시 자동 변환: 기존 단일 plan을 리스트의 첫 요소로 옮기고 `id`/`label`을 부여하며 `source: auto`로 표시한다. 기존 진행(PlanCheck 등)은 그 일정 planId로 이관.

## 8. 테스트 전략 (TDD — 절대조건 2)
- **단위**: 모델 직렬화(round-trip), store 리스트 CRUD, `PlanProgressStore` planId 격리(한 일정 삭제가 다른 일정 진행에 영향 없음), 진행 판정 planId 스코프, v1→v2 마이그레이션.
- **위젯**: 일정 목록→선택 전환, 생성 폼. (`PlanAgenda`는 `SelectionArea`를 쓰지 않아 위젯 테스트 가능 — `StudyDocPage`와 달리 RenderBox 제약 없음.)
- 각 변경은 실패 테스트 선작성 후 최소 구현.

## 9. 비범위 (YAGNI)
- 한 일정 내 자동+수동 혼합 (일정은 auto 또는 manual 중 하나).
- 일정 간 의존/순서 강제, 일정 공유·내보내기.
- 기간 겹침 차단·자동 조정 (겹침은 허용, 안내만).

## 10. 구현 단계 (writing-plans 입력)
1. 모델·store 리스트화 + v1→v2 마이그레이션
2. `PlanProgressStore` + 진행 판정 planId 스코프 전환
3. 어젠다 목록 → 선택 화면
4. 수동 생성(유형 + Task 빌더)
5. 자동 생성 통합 + 일정 삭제 시 진행 초기화 연결
