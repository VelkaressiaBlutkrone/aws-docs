# Phase 2 설계 — E5 학습 진행률 + E6 약점 가중 모의고사

> 상태: APPROVED (brainstorm 2026-06-07) · 다음 = writing-plans
> 로드맵: `docs/superpowers/specs/2026-06-07-work-priority-roadmap-design.md` Phase 2
> 원안: `docs/designs/clf-learning-loop.md` E5·E6 절

## 목적

학습 루프의 마지막 두 조각. **E5**는 "얼마나 봤고 얼마나 푸는가"를 정직하게 보여줘 재방문 동기를 만든다. **E6**는 누적 약점을 다음 모의고사 출제에 반영해 적응형 학습의 첫 조각을 완성한다. 둘 다 localStorage + 기존 데이터(D13 Task 매핑 · D14 응시 이력) 위에서 동작하며 서버·아키텍처 변경이 없다.

두 기능은 독립적이지만 한 스펙·한 Phase로 묶어 "재방문 동기(E5) + 적응형(E6)"을 한 흐름으로 완결한다.

## 확정 결정 (brainstorm)

| # | 결정 | 값 |
|---|------|-----|
| D1 | 범위 | E5 + E6 한 스펙·한 플랜, 순차 구현 |
| D2 | E5 "열람" 정의 | **방문 = 열람** (StudyDocPage 진입 시 기록). 스크롤/체류는 구분 안 함 — 정직 표기로 보완 |
| D3 | E5 진행률 노출 | **랜딩 콘텐츠 카드 배지 + cert 상세 배너** 둘 다 |
| D4 | E6 구성 | 기존 통합 모의고사와 **별도 진입 버튼**("약점 집중 모의고사") |
| D5 | E6 성격 | **실전형** — 통합과 동일 문항 수·시간, 출제 확률만 약점 Task에 가중 |
| D6 | E6 가중 단위 | **Task별 누적 오답률 비례**(전 Task 최소 가중 보장) |
| D7 | E6 게이트 | 비-review 응시 **3회+** 누적 시 활성 |

## E5 — 학습 진행률

### 데이터 레이어

**`lib/data/viewed_docs_store.dart` (신규 스토어)**
- 키 `awsdocs.viewed.v1`, 값 `{certId: [taskId, ...]}` (Task ID는 set 의미, 중복 없음).
- `local_kv`의 `KvBackend` 주입(테스트는 `MemoryBackend`) — `HistoryStore`·`ExamSessionStore`와 동일 패턴.
- API: `Set<String> viewed(String certId)`, `void markViewed(String certId, String taskId)`(이미 있으면 무변경).
- 멀티탭: last-write-wins. storage 이벤트 동기화 없음(원안 §4 — 1인 사용 단계 과잉).
- 손상 데이터(JSON 파싱 실패)는 빈 결과로 무시(`HistoryStore.all()` 선례).

**`lib/data/study_progress.dart` (신규 순수 모듈)**
```dart
class StudyProgress {
  final int viewedCount;       // 현재 인덱스에 존재하는 열람 Task 수(stale 제외)
  final int totalDocs;         // contentFor(cert).length
  final int? bestRatePct;      // 비-review 이력 최고 정답률(%), 없으면 null
  final String? lastAttemptIso;// 마지막 비-review 응시일(ISO), 없으면 null
  bool get hasAny => viewedCount > 0 || bestRatePct != null;

  factory StudyProgress.build({
    required String certId,
    required List<String> allTaskIds,      // 현재 content index의 Task 순서
    required Set<String> viewedTaskIds,    // ViewedDocsStore.viewed(certId)
    required List<AttemptRecord> history,
  });
}
```
- `viewedCount` = `viewedTaskIds ∩ allTaskIds` 크기(개정으로 사라진 Task ID는 분모·분자 모두에서 제외 → 분자 ≤ 분모 보장).
- `bestRatePct` = 비-review(`mode != 'review'`) 레코드 중 `correct/total` 최대값을 백분율 반올림. total 0 레코드는 제외.
- `lastAttemptIso` = 비-review 레코드의 최대 `date`.
- 호출측(페이지)이 자산 로드·스토어 읽기를 담당, 모듈은 순수.

### UI

**랜딩 (`home_page.dart` `_ContentCertCard`)**
- '학습 문서' 섹션 카드(`summaryLabel` 칩 아래)에 `열람 N/총` 배지 추가. **열람 0이면 배지 비노출**(원안 빈 상태: 0% 부담 주지 않음).
- '모의고사' 섹션 카드는 진행률 배지 없음(중복 회피) — 진행률은 학습문서 카드에만.
- `_ContentCertCard`에 옵셔널 `progress` 파라미터 추가(없으면 기존 렌더 그대로 — 모의고사 카드 호환).
- 진행률 산출: `_StudyDocsSection`이 `ViewedDocsStore` + `HistoryStore`를 읽어 `StudyProgress`를 카드별로 구성. (랜딩은 동기 데이터만 — 스토어는 동기 read라 `FutureBuilder` 불필요.)

**cert 상세 (`cert_detail_page.dart`)**
- `_load()`가 이미 뱅크를 로드하므로 거기서 `viewedTaskIds`·`history`로 `StudyProgress`를 함께 구성해 `_Loaded`에 추가.
- `_LearningContent` 섹션 상단(약점 리포트 진입 위)에 진행률 배너:
  - `열람 N/총 문서 · 최고 정답률 X% · 마지막 응시 YYYY-MM-DD`
  - 미응시 항목은 생략(예: 이력 0이면 "최고 정답률"·"마지막 응시" 비표시, 열람만).
  - `hasAny == false`면 배너 전체 비노출(빈 상태).
  - 정직 툴팁: 분모 옆 ⓘ "학습 자료가 추가되면 진도율이 변할 수 있습니다".

**열람 기록 (`study_doc_page.dart`)**
- `StudyDocPage`를 `StatefulWidget`으로 전환. `initState`에서 `ViewedDocsStore().markViewed(entry.certCode, entry.taskId)` 1회 호출(방문 = 열람). 렌더·로직과 분리된 부수효과.

## E6 — 약점 가중 모의고사

### 데이터 레이어

**`lib/data/mock_exam.dart` 일반화 (기존 수정)**
- `allocateByWeight`·`buildMockExam`·`groupByDomain`을 키 타입 비의존으로 일반화:
  - `Map<K, int> allocateByWeight<K>(Map<K, int> weightByKey, int n)`
  - `List<Question> buildSampledExam<K>({required Map<K, List<Question>> poolByKey, required Map<K, int> weightByKey, required int n, required Random rng})`
  - 기존 `buildMockExam`(도메인)은 `buildSampledExam<int>`로 위임하는 얇은 별칭으로 유지하거나, 호출측을 `buildSampledExam`로 직접 교체. **도메인 통합 모의고사 동작은 불변** — 기존 `mock_exam_test`의 도메인 케이스가 회귀 가드.
- `groupByDomain`은 유지. Task 그룹은 페이지에서 `{taskId: questions}`로 직접 구성(뱅크 1개 = Task 1개라 자명).

**`lib/data/weighted_exam.dart` (신규 순수 모듈)**
```dart
/// Task별 출제 가중 = floor + round((1 - 정답률) * scale).
/// 미응시 Task는 floor만 부여(약점 근거 없음 → 과대 가중 방지, 출제는 유지).
Map<String, int> weightByTaskFromReport(
  TaskScoreReport report, {
  int scale = 100,
  int floor = 10,
});
```
- 규칙(정직·약점 집중 균형):
  - **응시한 Task**: `weight = floor + round((1 - rate) * scale)`. 오답률이 높을수록 큰 가중.
  - **미응시 Task**(`status == unattempted`): `weight = floor`(최소 가중만). 약점 근거가 없으므로 과대 가중 금지하되 출제에서 배제하지도 않음(전 Task 노출 유지).
  - 모든 Task가 `floor` 이상 → 전 Task 출제 보장(원안 "최소 가중치 보장").
- 순수 — `TaskScoreReport`만 입력. 페이지가 report를 구성해 전달.

**게이트 헬퍼 (`lib/data/weighted_exam.dart`에 동거 또는 기존 모듈)**
```dart
int nonReviewAttemptCount(String certId, List<AttemptRecord> history);
bool weightedExamUnlocked(String certId, List<AttemptRecord> history); // count >= 3
```
- 3회 기준은 `const kWeightedExamMinAttempts = 3`.

### UI / 라우팅

**라우트**: `/cert/:code/exam/weak` 신규. `app_router.dart`에 등록(redirect 가드는 기존 cert 라우트와 동일 패턴).

**`CertExamPage` 파라미터화 (`cert_exam_page.dart`)**
- `final bool weighted;`(기본 false) 추가.
- `weighted == false`: 현행 그대로(도메인 풀·도메인 가중·세션 `exam:<code>-mock`·제목 "통합 모의고사").
- `weighted == true`:
  - 풀 = `{taskId: bank.questions}` Task 그룹.
  - 가중 = `weightByTaskFromReport(TaskScoreReport.build(...))`.
  - 샘플링 = `buildSampledExam<String>`.
  - 세션 키 = `exam:<code>-weak`(통합과 분리, 복원도 독립).
  - 제목 = "약점 집중 모의고사". 시작 화면 안내 = "지금까지 자주 틀린 Task가 더 자주 출제됩니다."
  - 문항 수·타이머·합격선·복원·제출·이력 기록은 통합과 **동일 로직 재사용**(실전형).
- `taskFromExamId`(`attempt_presented.dart`): 접미사 판정을 `-mock`뿐 아니라 집계 시험 일반으로 확장 → `-weak`도 단일 Task 아님(null). (실사용에선 `presentedQuestionIds`가 기록되어 폴백에 도달하지 않지만 정의 일관성 유지.)

**진입 버튼 (게이트 포함)**
- cert 상세 `_LearningContent`: 약점 리포트 진입 근처에 "약점 집중 모의고사" 진입 추가.
  - `weightedExamUnlocked == true`: accent 톤 진입 → `/cert/:code/exam/weak`.
  - `false`: 잠김 표시(muted) + "응시 기록이 3회 쌓이면 열립니다 (현재 N/3)".
- 랜딩 '모의고사' 섹션: 통합 모의고사 카드 옆/아래에 약점 집중 진입(잠김 시 동일 메시지). 잠김 상태도 존재를 보여줘 동기 부여.

### E2/E6 강등 규칙 (원안 유지)

`examGuide` Task 매핑이 있는 자격증(CLF)만 Task 가중·약점 집중 활성. 매핑 없는 자격증은 약점 집중 버튼 비노출(균등 통합 모의고사만). 현재 콘텐츠 보유 = CLF뿐이라 즉시 영향은 없으나 분기 규칙으로 명문화.

## 테스트 전략

SelectionArea + 비동기 로더 페이지는 위젯 렌더 테스트 시 크래시(메모리: `flutter-selectionarea-widget-test-pitfall`). **렌더 스모크 금지.** 커버리지:

**순수 모듈 단위테스트 (신규)**
- `study_progress_test.dart`: 열람∩인덱스(stale 제외, 분자≤분모), best/last 산출, 빈 상태(`hasAny`), review 제외.
- `weighted_exam_test.dart`:
  - `weightByTaskFromReport` — weak Task 가중 > ok Task > (미응시 = floor), 전 Task ≥ floor.
  - `nonReviewAttemptCount`/`weightedExamUnlocked` — 2회 잠김·3회 해제, review 미포함.
- `mock_exam_test.dart` 확장: 기존 도메인 케이스 **회귀 유지** + `buildSampledExam<String>` Task 케이스(합 == n, 풀 부족 보충, 결정적 rng).
- `attempt_presented` 테스트(있으면)에 `-weak` null 케이스 추가.

**스토어 테스트 (신규)**
- `viewed_docs_store_test.dart`: markViewed 멱등, 자격증 분리, 손상 데이터 빈 결과(MemoryBackend).

**라우팅 redirect 테스트**
- `/cert/:code/exam/weak`가 HomePage/에러로 새지 않고 해석되는지(부모 스택 렌더 금지 함정 준수 — redirect만 검증).

**headless dogfood (PowerShell + gstack)**
- 진행률: 학습문서 방문 → cert 상세 배너 `열람 1/19`·랜딩 배지 갱신.
- E6 게이트: 이력 <3회 잠김 메시지 → 3회 후 진입 → 약점 Task 가중 출제 확인.

## 구현 순서 (플랜에서 Task로 분해)

1. **E5 데이터** — `ViewedDocsStore` + `StudyProgress` + 테스트.
2. **E5 UI** — StudyDocPage 마킹 + cert 상세 배너 + 랜딩 배지.
3. **E6 데이터** — `mock_exam` 일반화(회귀) + `weighted_exam`(가중·게이트) + 테스트.
4. **E6 UI/라우팅** — 라우트 + `CertExamPage` weighted 모드 + 진입 버튼(게이트) + redirect 테스트.
5. **검증·dogfood·배포** — analyze·전체 테스트·릴리스 빌드·headless dogfood → main 커밋·push.

각 단계 TDD(순수 모듈은 테스트 선행). 디자인 변경은 DESIGN.md 토큰·기존 카드 패턴 준수(새 색/그라데이션 금지).

## 비목표 (YAGNI)

- 스크롤 깊이·체류 시간 기반 열람 판정(방문으로 충분).
- 1000점 환산 점수(정답률 표기 유지).
- storage 이벤트 멀티탭 동기화.
- 비-CLF 자격증 Task 태깅(CLF 합격 후 콘텐츠 작업).
- 가중 알고리즘 튜닝 UI(scale/floor 노출) — 상수로 고정.
