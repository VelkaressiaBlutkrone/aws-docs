# 학습 루프 · E2 약점 리포트 설계

- **상태:** 설계 승인됨 (2026-06-07, 브레인스토밍). 구현 계획(writing-plans) 대기.
- **범위:** 학습 루프 Phase 1의 **E2(Task별 약점 리포트 + 처방)**. E1(오답노트) 완료 위에 적층.
- **대상 코드베이스:** `flutter_app`(Flutter Web, go_router 해시 라우팅, GitHub Pages 배포).
- **브랜드 제약:** `DESIGN.md` "조용한 레퍼런스 + 정직함". 새 디자인 언어 금지, 기존 테마 토큰·위젯 재사용.

## 1. 목표 & 성공 기준

응시 이력을 **처방전**으로 바꾼다: 자격증의 Task별 정답률을 한 표로 보여주고, 약한 Task(<70%)에 해당 학습문서 링크를 걸어 "무엇을 더 공부할지"를 가리킨다.

성공 기준:
- 사용자가 cert별 **Task별 정답률 표**를 한곳에서 본다.
- **정답률 70% 미만 Task**에 학습문서 앵커 링크("처방")가 노출된다.
- 아직 안 푼 Task는 **"미응시"**로 정직하게 구분된다.
- 복습(`review`) 재응시가 정답률을 부풀리지 않는다(연습+시험만 집계).

## 2. 현재 상태 (소비 대상)

- `AttemptRecord`(`lib/models/attempt_record.dart`): `certId, examId, mode('practice'|'exam'|'review'), date(ISO), correct, total, wrongQuestionIds, flaggedQuestionIds, presentedQuestionIds, durationSpentSec`. (E1a에서 `presentedQuestionIds` 추가됨.)
- `HistoryStore`(`lib/data/history_store.dart`): `all()`/`add()`, 손상 시 `[]`.
- `WrongAnswerIndex`(`lib/data/wrong_answer_index.dart`, E1): 순수 집계. 내부에 "한 응시의 출제 문항 집합" 해석(presentedQuestionIds + 레거시 폴백: `examId`의 Task 현재 뱅크) + `examId→taskId` 파서를 가짐.
- Task↔문항: 문항 ID가 Task를 인코딩(`clf-t2-1-q3`→`clf-t2-1`). `kContentIndex`(`lib/data/content_index.dart`)가 Task→뱅크 자산·제목·도메인 매핑. 학습문서 라우트 = `/cert/:code/study/:taskId`.
- 진입/소비 화면: cert 상세(`cert_detail_page.dart`), 오답노트(`review_page.dart`). E2가 두 번째 리포트 소비자.

## 3. 집계 레이어 — `TaskScoreReport` (순수 모듈)

신규 `lib/data/task_score_report.dart`. 자산 로드는 호출측 책임(순수 유지).

### 3.1 입력
- `certId`, `List<AttemptRecord> history`, `Map<String,String> taskByQuestionId`(현재 뱅크 문항ID→TaskID), `List<String> taskOrder`(콘텐츠 순 Task ID 목록, 미응시 Task까지 표에 포함하기 위함).

### 3.2 규칙
- **모드 필터:** `mode=='review'` 레코드는 **제외**. practice/exam만 집계(정직함, E1 §6과 일관).
- **출제 집합 해석:** E1과 **동일 규칙 재사용** — `presentedQuestionIds`가 있으면 그대로, 없으면(레거시) `examId`의 Task 현재 뱅크 전체로 폴백, 불가하면(`*-mock` 등) 오답만. 드리프트 방지를 위해 이 해석과 `examId→taskId` 파서를 **공유 헬퍼로 추출**(아래 §6)해 `WrongAnswerIndex`·`TaskScoreReport`가 함께 사용한다.
- **문항별 최신 결과:** date 오름차순으로 각 문항의 정/오답을 갱신 → 마지막 값이 그 문항의 "최신 결과". 현재 뱅크에 없는 문항(stale)은 제외.
- **Task 집계:** 각 Task에 대해
  - `total` = `taskByQuestionId`에서 그 Task에 속한 문항 수(현재 검증 뱅크 기준).
  - `attempted` = 최신 결과가 있는(= 한 번이라도 practice/exam에서 출제된) 문항 수.
  - `correct` = 최신 결과가 정답인 문항 수.
  - `rate` = `attempted == 0 ? null : correct / attempted` (null = 미응시).
  - `status` = `attempted==0` → `unattempted`, `rate < 0.7` → `weak`, else `ok`.

### 3.3 출력 타입(초안)
```
enum TaskStatus { unattempted, weak, ok }

class TaskScore {
  final String taskId;
  final int total;        // 현재 뱅크 문항 수
  final int attempted;    // 최신 결과 보유 문항 수
  final int correct;      // 최신 정답 문항 수
  final double? rate;     // null = 미응시
  final TaskStatus status;
}

class TaskScoreReport {
  final List<TaskScore> tasks;   // taskOrder 순
  // 요약(응시 문항 기준): 전체 attempted/correct 합산
  int get attemptedTotal;
  int get correctTotal;
  double? get overallRate;       // attemptedTotal==0 ? null : correctTotal/attemptedTotal
  bool get hasAnyAttempt;        // attemptedTotal > 0
}
```
- `TaskScoreReport.build({certId, history, taskByQuestionId, taskOrder})` 팩토리.
- 임계값 `0.7`은 상수로 노출(`kWeakThreshold`)해 표시·테스트에서 공유.

## 4. UI — `ReportPage`

`lib/pages/report_page.dart`. 로더는 `ReviewListPage`/`CertExamPage` 패턴(19뱅크 로드 → `taskByQuestionId`·`taskOrder` → 이력과 함께 `TaskScoreReport.build`).

- **AppBar:** `${cert.title} · 약점 리포트`.
- **요약 헤더:** `hasAnyAttempt`면 "전체 정답률 NN% · 응시 문항 A/총 M"(또는 응시 회차 수). 정직 톤.
- **Task 표(콘텐츠 순):** 행마다 `Task X.Y · 제목` + 우측 상태:
  - **ok(≥70%):** `정답률 NN%` (correct 톤).
  - **weak(<70%):** `정답률 NN%` (wrong 톤 강조) + **"학습문서 →"** 링크(`context.push('/cert/:code/study/:taskId')`) = 처방.
  - **미응시:** `미응시` (muted), 링크 없음.
  - 보조: `응시 attempted/total 문항`.
- **빈 상태**(`!hasAnyAttempt`): "모의고사나 연습을 풀면 Task별 약점이 여기 표시됩니다." (오답노트 빈 상태와 동일 톤.)
- 기존 위젯/토큰만 사용: `PrimaryButton`/카드 컨테이너 패턴, `context.c`, `Gap`/`Radii`. 새 색·폰트 없음.

### 4.1 라우트
- `/cert/:code/report` 추가(`cert/:code` 하위, `exam`·`review` 옆). 상위 `cert/:code` redirect가 잘못된 코드를 `/`로 보내므로 별도 가드 불필요.

### 4.2 진입(cert 상세)
- `cert_detail_page.dart` 학습 콘텐츠 섹션에 **"약점 리포트"** 진입 추가(콘텐츠 존재 시 노출, accent 톤). 오답노트 진입(wrong 톤)과 시각적으로 구분. cert 상세는 추가 집계 불필요(진입 버튼만; 표는 ReportPage가 계산).

## 5. 자격증 일반화 (Task 매핑 없는 cert 강등)
- E2는 Task 매핑(= `content_index`에 Task 등록)이 있는 cert에서만 Task별 표가 의미를 가진다. 현재 CLF만 매핑 보유.
- 매핑 없는 cert: `taskOrder`/`taskByQuestionId`가 비어 표가 빈다 → ReportPage는 빈 상태만. (별도 "전체 점수 강등 뷰"는 본 스펙 범위 밖 — 비-CLF 콘텐츠 단계에서 다룸.) 진입 버튼은 콘텐츠가 있는 cert에만 노출되므로 실사용상 CLF에서만 보인다.

## 6. 공유 헬퍼 리팩터 (드리프트 방지)
- E1의 `WrongAnswerIndex` 내부 private 로직 `_presentedOf`·`_taskFromExamId`를 **모듈 최상위 순수 함수**로 추출(같은 파일에 노출하거나 작은 `lib/data/attempt_presented.dart`로 분리):
  - `Iterable<String> resolvePresented(AttemptRecord r, Map<String,String> taskByQuestionId)`
  - `String? taskFromExamId(String examId)`
- `WrongAnswerIndex`와 `TaskScoreReport`가 동일 함수를 사용 → "무엇이 출제됐나" 정의가 한 곳. **기존 9개 `WrongAnswerIndex` 테스트는 green 유지**(동작 동일, 내부 호출처만 변경).

## 7. 엣지 / 에러
- 이력 0건 → 빈 상태.
- 손상 history → `HistoryStore`가 `[]`.
- 뱅크 로드 실패(개별) → 무시하고 나머지로 진행(기존 로더 패턴).
- 현재 뱅크에 없는 문항(개정 삭제) → 집계 제외.
- review-only 이력만 있는 문항 → practice/exam 결과 없음 → 해당 문항 attempted 미포함(미응시 취급) = 정직.
- `total==0`인 Task(콘텐츠는 있으나 검증 문항 0) → `attempted` 0 → 미응시.

## 8. 테스트
- **`TaskScoreReport` 단위 테스트**(순수, `MemoryBackend` 불필요 — 직접 레코드 주입):
  - 문항별 최신 결과 평균(오답→정답 갱신 시 정답 반영).
  - **review 제외**(review 정답이 rate에 영향 없음).
  - 미응시 Task(`rate==null`, status unattempted).
  - 70% 경계(정확히 0.7=ok, 미만=weak).
  - stale 문항 제외.
  - 레거시 폴백(presented 빈 값 → examId Task 현재 뱅크).
  - `overallRate`/`hasAnyAttempt` 집계.
- **`WrongAnswerIndex` 회귀:** 공유 헬퍼 추출 후 기존 9테스트 green.
- **라우팅:** 잘못된 cert report 경로 → `/` redirect(app_router_test 패턴). ReportPage 렌더 테스트 금지(SelectionArea 함정).
- **dogfood:** 오답 이력 주입 → cert 상세 "약점 리포트" 진입 → 표(weak 행 wrong 톤 + 학습문서 링크, ok 행, 미응시 행) → 링크가 학습문서로 이동.

## 9. 범위 밖 (YAGNI / 후속)
- 도메인 단위 롤업/그래프(차트). 표만.
- 1000점 환산 점수(정답률만).
- 비-CLF "전체 점수 강등 뷰"(별도, 비-CLF 콘텐츠 단계).
- 시간 경과 추세(회차별 추이 그래프).
- E5 진행률·E6 가중 모의고사(Phase 2).

## 10. 결정 로그 (브레인스토밍 2026-06-07)

| 결정 | 선택 | 근거 |
|---|---|---|
| 배치 | 별도 `/cert/:code/report` 페이지 + cert 상세 진입 | 관심사 분리, cert 상세 비대화 방지 |
| 정답률 정의 | 문항별 최신 결과 평균(연습+시험, review 제외) | 최근 실력 반영, 복습 재응시로 부풀지 않음(정직) |
| 미응시 Task | "미응시"로 표시(0%와 구분) | 정직 + 전체 Task 커버리지 유도 |
| 처방 | weak(<70%) 행에 학습문서 앵커 링크 | 점수를 행동(공부)으로 연결 |
| 출제 해석 | E1 헬퍼 공유(추출) | "무엇이 출제됐나" 정의 단일화, 드리프트 방지 |
