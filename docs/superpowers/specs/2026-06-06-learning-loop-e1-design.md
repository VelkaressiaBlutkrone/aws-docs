# 학습 루프 #3 — E1 오답노트 설계

- **상태:** 설계 승인됨 (2026-06-06). 구현 계획(writing-plans) 대기.
- **범위:** 하위 프로젝트 #3 학습 루프의 **E1(오답노트 + 재응시)**. E2 약점 리포트는 후속 sub-project.
- **대상 코드베이스:** `aws-docs/flutter_app` (Flutter Web, GitHub Pages 배포).
- **브랜드 제약:** `DESIGN.md` "조용한 레퍼런스" + "정직함". 새 디자인 언어 금지, 기존 테마 토큰·위젯 재사용.

## 1. 목표 & 성공 기준

이력에 쌓인 오답을 소비해 **학습 루프를 닫는다**: 틀린 문항을 모아 → 연습형으로 재응시 → **연속 2회 정답으로 졸업**.

성공 기준:
- 사용자가 cert별/Task별 오답(weak)을 한곳에서 본다.
- weak 문항을 연습형(즉시 피드백)으로 재응시한다.
- 같은 문항을 연속 2회 맞히면 노트에서 졸업(사라짐)하는 것을 확인한다.
- 헤드라인 연습/시험 정답률은 복습으로 인해 부풀지 않는다(정직함).

## 2. 현재 상태 (소비 대상)

- `AttemptRecord`(`lib/models/attempt_record.dart`): `certId, examId, mode('practice'|'exam'), date(ISO), correct, total, wrongQuestionIds, flaggedQuestionIds, durationSpentSec`.
- `HistoryStore`(`lib/data/history_store.dart`): `awsdocs.history.v1` 키에 append-only 로그. `all()` / `add()`. 손상 시 `[]`.
- 작성자: `QuizView`(`practice:<taskId>`), `ExamView`(`exam:<taskId>`)가 종료 시 `add()`.
- **소비자(읽어서 표시) 없음** — E1이 첫 소비자(그린필드).
- 질문 ID가 Task를 인코딩: `clf-t2-1-q3` → Task `clf-t2-1`. `kContentIndex`(`lib/data/content_index.dart`)가 Task→뱅크 자산을 매핑.

## 3. 데이터 모델 (접근 A: presentedQuestionIds + 순수 파생)

### 3.1 AttemptRecord 확장
- 신규 필드 `presentedQuestionIds: List<String>` — 그 응시에 **출제된 전체 문항 ID**.
- 파생 규칙: `정답 ID = presentedQuestionIds − wrongQuestionIds`.
- `toJson`/`fromJson` 갱신. **하위 호환:** 필드 누락 시 `const []`.
- 작성자 갱신:
  - `QuizView` / `ExamView`: `presentedQuestionIds = bank.questions.map(id)` (출제된 뱅크 전체).
  - 신규 `ReviewView`: `presentedQuestionIds = 복습 큐 ID(부분집합)`.

### 3.2 레거시 폴백
- `presentedQuestionIds`가 빈 레거시 레코드: 집계 시 "해당 Task의 **현재 뱅크 검증 문항 = 출제**"로 폴백. 기존 이력도 사용 가능(근사).

## 4. 집계 레이어 — WrongAnswerIndex

- 신규 순수 모듈 `lib/data/wrong_answer_index.dart`.
- 입력: `List<AttemptRecord>` + Task→뱅크 조회(자산 로드는 호출측에서, 인덱스는 순수 함수로 유지).
- 각 "한 번이라도 오답이었던" 문항에 대해:
  - 출제된 응시들에서 정/오답 타임라인을 **date 오름차순** 구성.
  - `wrongCount` = 오답 횟수, `consecutiveCorrect` = 마지막 연속 정답 수, `lastSeen` = 마지막 출제 date.
  - **상태:** 첫 오답 이후 마지막 2회 출제가 모두 정답 → `mastered`, 아니면 `weak`.
  - 주의: "출제된 응시" = 그 문항이 `presentedQuestionIds`에 포함된 각 `AttemptRecord` 1건. 따라서 **"연속 2회 정답"은 서로 다른 2번의 응시/세션**에서의 정답을 뜻함(한 세션 안에서 2회가 아님).
- 출력 타입(초안):
  - `WrongEntry { questionId, taskId, certId, wrongCount, consecutiveCorrect, lastSeen, status }`
  - `weakByTask(certId) -> Map<taskId, int>` (cert 상세 배지용)
  - `weakEntries(certId, [taskId]) -> List<WrongEntry>` (복습 큐 구성용, weak만)
- "현재 뱅크에 없는 문항"(삭제·비검증)은 결과에서 제외.

## 5. UI / 진입

- **cert 상세 페이지**(`lib/pages/cert_detail_page.dart`):
  - Task 행마다 **"오답 N" 배지**(N = `weakByTask`의 해당 Task 값, 0이면 숨김). 기존 배지 체계(DESIGN.md §Brand Rules)와 동일 톤.
  - cert 레벨 **"오답노트"** 진입(버튼/섹션) → `ReviewListPage`.
- **`ReviewListPage`**(신규, cert별):
  - weak 문항을 Task별로 묶어 표시(Task 순서). 각 그룹: weak 수 + "복습 시작".
  - **복습은 Task 그룹 단위로 시작(MVP).** 한 cert 내 여러 Task 통합 복습은 범위 밖(§9).
  - 빈 상태: "아직 오답이 없습니다 — 연습/시험을 풀면 여기 모입니다."
- **`ReviewView`**(신규, 연습형 러너):
  - 선택한 weak 문항을 하나씩, **즉시 공개 + 해설 + "왜 아닌가"**.
  - 기존 `quiz_widgets.dart`(`OptionTile`·`ExplainBox`·`ResultsView`)·테마 토큰(`context.c`) 재사용. 새 디자인 언어 없음.
  - 종료 시 `AttemptRecord(mode:'review', examId:'review:<taskId>', presentedQuestionIds: 큐, wrongQuestionIds: 이번에 틀린 것)` 기록.

## 6. 복습 동작 & 정직함

- 복습 = **연습형(즉시 피드백), 타이머 없음.** 목표는 학습.
- 복습 응시는 `mode:'review'`로 기록 → 마스터(2연속 정답) 누적.
- **헤드라인 연습/시험 정답률엔 미반영**: 집계·통계에서 `mode=='review'`는 별도 취급(이미 본 문항 재응시가 통계를 부풀리면 안 됨). E2에서 복습 활동은 따로 표기.
- 졸업한 문항은 노트에서 빠지되 history는 보존(가역적·정직).

## 7. 엣지/에러

- 오답 없음 → 빈 상태.
- 손상 history → `HistoryStore`가 `[]` 반환(현행).
- history에 있으나 현재 뱅크에 없는 문항 → 스킵.
- 응시 간 뱅크 변경 → "첫 오답 이후" + `presentedQuestionIds`로 견고.
- 복습 큐가 도중에 비는 경우(전부 졸업) → 완료 상태/빈 상태 처리.

## 8. 테스트

- **`WrongAnswerIndex` 단위 테스트**(순수 함수 + `MemoryBackend`, 기존 패턴):
  - weak 판별(첫 오답 후 미졸업).
  - 2연속 정답 졸업 — 연습·시험·**복습 부분집합** 혼합 타임라인 포함.
  - 레거시 레코드 폴백(현재 뱅크=출제).
  - `weakByTask` 집계 수.
  - 뱅크에서 사라진 문항 스킵.
- **`ReviewView` 위젯 테스트:** weak 문항 제시 → 응답 → 공개 → 종료 시 `mode:'review'` 레코드 기록.
- **회귀:** 기존 21개 테스트 그린 유지. `AttemptRecord` 변경은 가산·하위호환이어야 함.

## 9. 범위 밖 (YAGNI / 후속)

- E2 약점 리포트(별도 sub-project).
- 플래그(`flaggedQuestionIds`) 복습.
- history 초기화/리셋 UI.
- 한 cert 내 여러 Task 통합 복습("전체 복습") — MVP는 Task별 복습만.
- cert 전역(다중 cert 통합) 복습.
- 간격 반복(spaced repetition) 스케줄링.

## 10. 결정 로그 (브레인스토밍 2026-06-06)

| 결정 | 선택 | 근거 |
|---|---|---|
| 스펙 범위 | E1 먼저, E2 후속 | 더 작고 빠른 첫 출시, "루프를 닫는" 핵심 우선 |
| 마스터 규칙 | 연속 2회 정답 졸업 | 우연한 정답 배제 |
| 진입점 | cert 상세 페이지 + Task별 "오답 N" 배지 | 앱이 cert 중심, 맥락적·확장 용이 |
| 복습 큐 구성 | 오답만 | 이름·MVP 범위에 부합(플래그는 후속) |
| 데이터 모델 | A: presentedQuestionIds + 순수 파생 | 로그 단일 진실, 마스터 규칙 견고, E2 토대 |
| 복습 통계 | mode:'review' 분리, 헤드라인 정답률 미반영 | 정직함(재응시가 통계 부풀림 방지) |
