# 설계: 선택지 셔플 + 문항 랜덤 차출

- **날짜:** 2026-06-08
- **상태:** 승인됨 (/superpowers:brainstorming, 방식 B)
- **범위:** 엔진(코드)만. 문항 풀 확대(콘텐츠 생산)는 별도 작업으로 분리

## 1. 문제

측정 데이터로 확인된 두 가지 결함:

1. **정답 A 쏠림** — CLF-C02 130문항 중 88.5%(115개)가 정답 인덱스 0. 선택지는 JSON 순서
   그대로 렌더되므로(셔플 코드 부재) A만 찍어도 88점. 측정 도구로서 기능 상실.
2. **연습 = 시험 동일** — Task 연습(`QuizPage`)과 Task 시험(`ExamPage`)이 같은
   `<taskId>.questions.json` 전체를 같은 순서로 출제. 두 모드가 사실상 같은 경험.

## 2. 결정 요약

| 항목 | 결정 |
|---|---|
| 셔플 방식 | 데이터 계층 순수 변환 (방식 B) — 표시 계층 셔플(A)·JSON 재배치(C) 기각 |
| 차출 수 | Task 연습/시험 모두 풀에서 **5문항 고정 차출** (풀 ≤ 5면 전부) |
| 셔플 적용 범위 | **모든 화면** — Task 연습·Task 시험·통합 모의고사·약점 모의고사·오답노트 |
| 시험 복원 | 시드 재셔플 대신 **명시적 순서 저장** (`optionOrders`) |

## 3. 설계

### 3.1 선택지 셔플 — 모델 계층 순수 변환

`Question`(`lib/models/question.dart`)에 순수 메서드 추가:

```dart
/// order = 표시 순서대로 나열한 원본 인덱스 (예: [2,0,3,1]).
/// options 재배열 + correct 재매핑 + wrongExplanations 키 재매핑한 새 Question 반환.
Question withOptionOrder(List<int> order)
```

- **순서 생성(랜덤)과 적용(결정적)을 분리.** 적용은 순수 함수 → 테스트·복원 용이
- 헬퍼(순수 로직의 집 `lib/data/mock_exam.dart`):
  - `List<Question> shuffleOptions(List<Question> qs, Random rng)` — 문항별 랜덤 순서 생성·적용
- 잘못된 order(길이 불일치, 중복, 범위 밖)는 assert + 원본 반환으로 방어

이후 파이프라인(QuizView·ExamView·ResultsView·해설·기록)은 전부 `q.correct` /
`q.wrongExplanations[picked]` 기준이므로 **수정 없이** 동작한다.

### 3.2 문항 차출 — Task 연습/시험 5문항

`lib/data/mock_exam.dart`에 순수 함수 추가:

```dart
/// 풀에서 n개 랜덤 차출. 풀 ≤ n이면 전부. 반환 순서도 셔플됨.
List<Question> samplePool(List<Question> pool, int n, Random rng)
```

적용 지점 (모두 기존 "얇은 로더" 패턴 유지):

| 화면 | 차출 | 선택지 셔플 |
|---|---|---|
| Task 연습 `QuizPage._load` | ✅ 5문항 | ✅ |
| Task 시험 `ExamPage._load` | ✅ 5문항 | ✅ |
| 통합/약점 모의고사 `cert_exam_page` | 기존 `buildSampledExam` 유지 | ✅ 추가 |
| 오답노트 `ReviewListPage` | 없음 (weak 전부) | ✅ |

- 시험 시간: `examDurationSec(count:)`가 문항 수 비례이므로 자동 단축 — 코드 변경 없음
- 응시 기록(`presentedQuestionIds`)·오답노트·약점 리포트·가중 모의고사는 전부 **문항 ID
  기준**이라 무영향
- 자격증 상세의 "검증 문항 N" 배지는 풀 크기 기준 유지 (출제 수와 무관)

### 3.3 시험 새로고침 복원 — 명시적 순서 저장

시드 저장 방식은 기각: 복원 시 재셔플이 한 번이라도 다르게 동작하면(시험 중 앱 재배포로
RNG 구현 변경 등) `picked`(위치 인덱스)가 **다른 보기를 가리키는 무성 데이터 손상**이
발생한다. 명시적 저장은 이를 원천 차단한다.

- `ExamSession`(`lib/models/exam_session.dart`)에 필드 추가:
  ```dart
  final Map<String, List<int>> optionOrders; // questionId → 표시 순서(원본 인덱스)
  ```
  JSON 직렬화 포함. 65문항 × 4 int — localStorage 부담 없음
- **Task 시험 복원 흐름 변경**: 차출 도입으로 "풀 뱅크 + fingerprint" 복원이 불가능해지므로
  통합 모의고사와 같은 방식으로 통일 —
  `questionIds` + `restoreOrdered()` 로 차출 문항 복원 후 각 문항에
  `withOptionOrder(session.optionOrders[id])` 재적용
- **통합/약점 모의고사 복원**(`cert_exam_page._resume`)도 동일하게 `restoreOrdered()` 뒤에
  `optionOrders` 재적용 단계 추가 — 두 시험 화면이 같은 복원 레시피 공유
- `bankFingerprint`는 지금처럼 콘텐츠 개정 감지 담당 (개정 시 세션 폐기 — 기존 동작 유지)
- 구버전 세션(`optionOrders` 없음)은 복원 거부 → 새 시험 시작 (1회성 마이그레이션 비용)
- 연습·오답노트는 세션 저장이 없으므로 매 응시 자유 셔플

### 3.4 데이터 흐름 (시험 fresh → 복원)

```
fresh:  bank 로드 → samplePool(bank.questions, 5, rng)
        → shuffleOptions(sampled, rng) → ExamView
        → 세션 저장: questionIds + optionOrders(문항별 순서)

restore: bank 로드 → fingerprint 일치 확인
        → restoreOrdered(session.questionIds, byId)
        → 문항별 withOptionOrder(session.optionOrders[id]) → ExamView
```

## 4. 테스트 전략

기존 패턴(순수 로직 단위 테스트 + 모델 주입 위젯 테스트) 유지:

1. `question_model_test` — `withOptionOrder`: 옵션·correct·wrongExplanations 재매핑 정확성,
   원본 불변, 잘못된 order 방어
2. `mock_exam_test` — `samplePool`: n > 풀이면 전부 반환, 결정적 rng로 차출·순서 검증;
   `shuffleOptions`: 결정적 rng로 재매핑 일관성
3. `exam_session_test` — `optionOrders` 직렬화 왕복, 구버전 세션(필드 없음) 처리
4. `exam_view_test` — 차출+셔플 뱅크로 복원 시 동일 문항·동일 보기 순서 재현
5. 분포 스모크(선택) — 셔플 후 정답 위치가 단일 인덱스에 95% 이상 몰리지 않음

## 5. 비범위 (이번 작업에서 하지 않음)

- CLF/SAA 문항 풀 확대 (콘텐츠 생산 — 별도 작업)
- JSON 원본의 정답 위치 재배치 (런타임 셔플로 불필요)
- 최근 출제 문항 회피(스마트 로테이션) — 풀 6~9개에서는 중복이 불가피, YAGNI
