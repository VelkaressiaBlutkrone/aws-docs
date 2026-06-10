# 학습 일정/달력 — 설계 스펙

작성일: 2026-06-10
상태: 설계 승인됨(브레인스토밍) → 구현 플랜 대기
브랜치: `feat/study-plan-calendar`

자격증 시험일 또는 학습 기간을 정하면, 그 기간에 학습문서·연습퀴즈·모의고사를 **단계형으로 분배**해
**어젠다 달력**에 표기하고, 일정대로 진행하는지 **하이브리드로 추적**하는 기능.

---

## 1. 배경 · 목표

지금 앱은 콘텐츠(문서·문항)·학습 루프(오답노트·약점 리포트·진행률·약점 모의고사)는 있으나,
**"언제 무엇을 공부할지"의 시간 축이 없다.** 사용자는 시험일까지 무엇을 어떤 순서로 할지 스스로 짜야 한다.

목표: 사용자가 **대상 자격증 + 기간(또는 시험일)** 만 정하면, 앱이 **검증된 콘텐츠를 단계형으로 자동 분배**하고
달력으로 보여 주며, **이미 가진 열람·응시 데이터로 진행을 자동 감지**(+수동 보정)해 일정 준수를 돕는다.

비-목표(이번 작업 아님): 학습 효과 자체의 향상(그건 콘텐츠 밀도 작업). 이 기능은 **시간 구조화·동기 유지** 도구다.

---

## 2. 핵심 결정 (브레인스토밍 확정)

| # | 결정 | 값 | 근거 |
|---|---|---|---|
| D1 | 플랜 범위 | **자격증별 단일 활성 플랜** | 앱의 진행률·리포트·모의고사가 전부 cert 단위 → 모델·UI 단순. 다중 자격증 타임라인은 콘텐츠 준비도(현재 CLF만 완비) 대비 과설계. |
| D2 | 분배 전략 | **단계형: 학습→연습→모의고사→약점보강** | 실제 시험 대비 흐름과 일치. 전 범위 학습 후 모의고사 배치가 자연스럽고, 약점 집중 모의고사 잠금해제(비-review 3회) 게이트와도 맞물림. |
| D3 | 진행 추적 | **하이브리드(자동 감지 + 수동 보정)** | `ViewedDocsStore`·`HistoryStore` 재사용으로 자동 감지, 오프라인 학습·예외는 수동 토글. |
| D4 | 달력 UI | **어젠다 리스트(주) + 월 그리드(보조 "월 펼치기")** | DESIGN.md 반마케팅·절제 + 모바일 반응형에 어젠다가 적합. 월뷰는 동일 데이터 재사용 토글. |
| D5 | 단계 비율 | **학습 45% / 연습 20% / 모의고사 20% / 약점·점검 15%** | 학습에 가장 큰 비중, 끝으로 갈수록 평가·보강. (엔진 상수, 추후 조정 가능) |
| D6 | 재분배 | **MVP 포함(수동 트리거)** | 밀림이 생기는 순간 정적 일정은 쓸모가 떨어짐. 자동 재분배는 안 하고 사용자 명시 동작으로. |

---

## 3. 범위 (MVP) · 비범위

### MVP 포함
- 자격증별 단일 플랜 생성/편집/삭제 (시험일 또는 기간 입력).
- 단계형 분배 엔진(순수 함수, 결정적).
- 어젠다 달력 뷰(오늘 강조, 밀림 표시, 단계 색, D-day·진행률 요약).
- 하이브리드 진행 추적(자동 감지 + 수동 체크/해제).
- "오늘부터 재분배"(미완 항목을 남은 일수에 재배치).
- 콘텐츠 준비도 고지(문항 없는 자격증은 문서 읽기만).

### MVP 내, 분리 가능한 후속 증분
- **월 그리드 "월 펼치기"** 뷰 — 어젠다와 동일 `PlanItem` 소스를 월 격자로. 어젠다 먼저 출고 후 추가.

### 비범위(YAGNI — 후속 후보로만 기록)
- 다중 자격증 순차 타임라인.
- 서버 동기화·푸시 알림(웹·로컬 전용이라 불가).
- 시간대(아침/저녁) 단위 배치, 하루 내 항목 순서.
- 외부 캘린더 내보내기(ICS), 리마인더 이메일.
- 휴식일(주말 제외 등) 커스터마이즈 — 균등 배치 후 사용자가 수동 보정으로 대체.

---

## 4. 데이터 모델

`lib/models/study_plan.dart`

```
enum PlanItemType { doc, quiz, mockExam, weakExam, finalReview }
// finalReview = 마지막 '최종 점검'. 앱의 history 'review'(오답노트) 모드와 이름 충돌 회피.
// 탭 시 /cert/:code/review(오답노트 마지막 점검)로 이동.
enum PlanPhase    { learn, practice, mock, reinforce }
enum PlanMode     { examDate, period }   // 종료 정의 방식

class PlanItem {
  final String id;          // 결정적: '<certCode>:<type>:<refId>:<seq>'
  final String dateIso;     // 배정일 'YYYY-MM-DD'
  final PlanItemType type;
  final String? refId;      // doc/quiz=taskId, 시험류=null
  final PlanPhase phase;
}

class StudyPlan {
  final String certCode;
  final String startIso;    // 'YYYY-MM-DD'
  final String endIso;      // examDate=시험일, period=학습 종료일
  final PlanMode mode;
  final String createdIso;
  final List<PlanItem> items;
  // fromJson/toJson — 손상 필드는 안전 기본값(기존 모델 관례)
}
```

- 날짜는 **로컬 날짜(YYYY-MM-DD) 문자열**로만 다룬다(시·분 없음). 비교·차이는 날짜 단위.
- `PlanItem.id`는 결정적 → 수동 체크 오버라이드 키로 안정적.

---

## 5. 저장소 (로컬, 기존 `local_kv` 패턴)

`lib/data/study_plan_store.dart`
- 키 `awsdocs.plan.v1` → `{ certCode: StudyPlan(json) }`.
- `StudyPlan? planFor(certCode)`, `void save(StudyPlan)`, `void clearCert(certCode)`, `void clearAll()`.
- 손상 데이터는 빈 결과(기존 `ViewedDocsStore`/`HistoryStore` 선례).

`lib/data/plan_check_store.dart`
- 키 `awsdocs.plan.checks.v1` → `{ certCode: { planItemId: bool } }`(수동 오버라이드, true=완료/false=미완 강제).
- `bool? override(certCode, itemId)`, `void set(certCode, itemId, bool?)`(null=오버라이드 해제→자동 감지로 복귀), `void clearCert(certCode)`.
- `study_reset.dart`의 cert 초기화에 두 저장소의 `clearCert` 연결(기존 리셋 동선과 일관).

---

## 6. 분배 엔진 — 순수 함수

`lib/data/plan_scheduler.dart` — 부작용 없음·결정적(기존 `TaskScoreReport`·`StudyProgress`·`weighted_exam` 선례).

```
class PlanBuildResult { final List<PlanItem> items; final List<String> warnings; }

PlanBuildResult buildPlan({
  required String certCode,
  required List<ContentEntry> content,  // 해당 cert, 콘텐츠 순서
  required String startIso,
  required String endIso,
  required PlanMode mode,
});
```

### 알고리즘
1. **학습 창(window) 산정**: `examDate` 모드면 마지막 학습일 = 시험 전날, 시험일은 별도 D-day 마커(항목 아님).
   `period` 모드면 마지막 학습일 = `endIso`. `windowDays = lastDay - startIso + 1`(≥1).
2. **단계 일수 분할**: `windowDays`를 45/20/20/15로 4구간 연속 분할(반올림, 합 보존). 짧으면 뒤 단계가 0일로 접힐 수 있음 → 그 단계 항목은 직전 가능한 날로 밀어 배치.
3. **단계별 항목 생성**:
   - **learn**: 문서(모든 `ContentEntry`) → `doc` 항목, 콘텐츠 순서.
   - **practice**: `hasQuestions`인 Task별 `quiz` 항목.
   - **mock**: 통합 모의고사 `mockExam` 항목 **N회**, `N = clamp(mock구간일수/2, 3, 6)` — **최소 3회로 약점 모의고사 게이트(`kWeightedExamMinAttempts`=3) 충족**.
   - **reinforce**: `weakExam` 1회(구간 초입) + 마지막 학습일에 `finalReview` 1회.
   - 문항 0 자격증(SAA/SOA): practice/mock/reinforce가 비어 learn만 생성 → 경고 추가.
4. **구간 내 균등 배치**: 항목 K개를 구간 D일에 `day(i) = 구간시작 + floor(i*D/K)`(K>0). 결정적.
5. **타당성 경고**: 총항목 > `windowDays`면 `"하루 평균 X개 — 일정이 빡빡합니다"`. `windowDays`가 훨씬 길면 빈 날 자연 발생(정상).

### 경계
- `windowDays==1`: 모든 항목이 그 하루에(경고와 함께).
- 빈 콘텐츠: 빈 items + 경고.
- `endIso < startIso`: 호출측(생성 UI)에서 차단, 엔진은 방어적으로 빈 결과+경고.

---

## 7. 진행 추적 — 하이브리드

`lib/data/plan_progress.dart` — 순수 파생(자산/스토어는 호출측 주입).

```
bool planItemDone(PlanItem item, {
  required bool? manualOverride,        // PlanCheckStore
  required Set<String> viewedTaskIds,   // ViewedDocsStore
  required List<AttemptRecord> history, // HistoryStore
});
```

우선순위:
1. `manualOverride != null` → 그 값(수동이 자동을 덮어씀).
2. 자동 감지(타입별):
   - `doc`: `viewedTaskIds.contains(refId)` — **날짜 게이팅 없음**(ViewedDocsStore에 타임스탬프 없음, 열람=완료).
   - `mockExam`: history에 `mode=='exam'`(통합) 응시가 **`plan.createdIso` 이후** 1건+.
   - `weakExam`: history에 약점 모드 응시가 **`plan.createdIso` 이후** 1건+.
   - `quiz`: history에 그 Task의 연습 응시가 **`plan.createdIso` 이후** — **best-effort**(연습 이력의 Task 식별이 모호하면 false; 사용자는 항상 수동 체크 가능).
   - `finalReview`: history에 `mode=='review'`(오답노트) 응시가 **`plan.createdIso` 이후** 1건+, 없으면 수동.
- **밀림(overdue)**: `!done && item.dateIso < 오늘`. 어젠다 상단에 모아 표시.
- **진행률**: `done 수 / 전체 항목 수`.

> 자동 감지 granularity는 정직하게: doc·mockExam·weakExam은 기존 데이터로 신뢰성 있게 감지, quiz는 best-effort + 수동 보정.

---

## 8. UI · 라우트

### 라우트
- `/cert/:code/plan` — 플랜 화면(없으면 생성 진입, 있으면 어젠다).
- 진입점: `cert_detail_page`에 "학습 일정" 카드/버튼 추가. (홈 진행률 카드 연계는 후속.)

### 플랜 생성/편집 화면
- 입력: **시험일** 또는 **기간(시작·종료)** 토글. 시작 기본=오늘.
- 미리보기: `buildPlan` 결과 요약(단계별 항목 수, 하루 평균, 타당성 경고) → 저장.
- 편집 시 기존 플랜 갱신(재분배). 삭제는 `reset_dialog`/`study_reset` 패턴.

### 어젠다 뷰(주 화면)
- 상단 요약: D-day, 진행률 막대, 단계 범례.
- 본문: 날짜별 카드(오늘 강조=틸, 밀림=빨강 `c.wrong`, 단계 색 점). 각 항목 = 타입 태그 + 제목 + 체크박스(수동 토글) + 탭 시 해당 문서/퀴즈/모의고사로 이동.
- 빈 날은 옅게. 밀림 항목 묶음 + "오늘부터 재분배" 액션.

### 월 펼치기(보조 증분)
- 동일 `PlanItem` 리스트를 월 격자로(셀=날짜, 단계 색 점·항목 수). 어젠다와 토글.

### DESIGN.md 준수
- 액센트(틸 `#0E8175`)는 오늘·시험일·주 동작에만(드물게). 그라데이션·3단 아이콘 CTA·스톡 금지.
- 8px 베이스 간격, Pretendard/JetBrains Mono. `app_theme`의 `AppColors` 사용. 라이트 기본 + 다크 대응.
- 시각 결정은 변경 전 DESIGN.md 재확인.

---

## 9. 적응 — 재분배

- 밀림 항목을 어젠다 상단에 모아 표기.
- **"오늘부터 재분배"** — `redistribute(plan, todayIso, doneItemIds)`: 완료 항목은 날짜 그대로 보존하고, **미완(자동·수동 통합) 항목만** `오늘 ~ endIso` 창에 단계 순서를 유지한 채 §6.4 균등 배치 로직으로 재배치. `buildPlan` 전체 재호출(완료 이력 무시)이 아님. 사용자 명시 동작(자동 안 함).
- 시험일이 지난 플랜: 어젠다에 "기간 종료" 배너 + 새 플랜/연장 안내.

---

## 10. 콘텐츠 준비도 처리

- CLF-C02: 문서 19 + Task 퀴즈 19 + 모의고사 → 풀 단계형.
- SAA-C03(문서 24)·SOA-C03(문서 20): `questionCount==0` → **문서 읽기만** 분배 + 생성 화면에 정직한 고지:
  `"이 자격증은 아직 검증 문항이 없어 문서 읽기 일정만 생성됩니다(퀴즈·모의고사 제외)."`
- 게이트는 `ContentEntry.hasQuestions`·`certHasVerifiedQuestions`를 단일 진실로 사용(중복 판정 금지).

---

## 11. 테스트 (기존 25개 테스트 패턴 따름)

순수 로직 위주 — 위젯 테스트는 최소.
- `plan_scheduler_test`: 단계 비율 분할; 균등 배치 결정성; mock 최소 3회 게이트; docs-only 자격증(learn만+경고); 짧은 기간 경고; 경계(1일·빈 콘텐츠·역전 날짜).
- `plan_progress_test`: 수동 오버라이드 우선; doc/mockExam/weakExam 자동 감지; 밀림 판정(날짜 경계); 진행률 계산.
- `study_plan_store_test` / `plan_check_store_test`: 라운드트립; 손상 데이터 → 빈 결과; clearCert 격리.
- `study_plan_model_test`: fromJson/toJson 왕복, 결손 필드 기본값.
- 회귀: `study_reset`가 플랜·체크 저장소까지 초기화하는지.

---

## 12. 구현 증분 순서 (→ 구현 플랜 매핑)

1. 모델 + 두 저장소 (+ 단위 테스트).
2. 분배 엔진 `buildPlan` (+ 단위 테스트). **여기까지 UI 없이 로직 검증.**
3. 진행 추적 `plan_progress` (+ 테스트).
4. 라우트 + 생성/편집 화면(미리보기·타당성 경고).
5. 어젠다 뷰(추적·이동·체크 연결) + `cert_detail` 진입점.
6. 재분배 액션.
7. `study_reset` 연동.
8. (후속 증분) 월 펼치기 뷰.

각 단계 끝에 `flutter analyze lib && flutter test`.

---

## 13. 미해결 · 후속

- 단계 비율(45/20/20/15)·mock 횟수(3~6)는 실제 사용 후 조정 가능한 상수.
- 홈 화면 진입점/오늘의 할 일 위젯은 어젠다 안정화 후.
- `quiz` 자동 감지 정밀화(연습 이력의 Task 식별)는 best-effort에서 시작, 필요 시 강화.
- 월 펼치기는 어젠다 검증 후 별도 증분.
