---
status: APPROVED (사용자 승인 2026-06-06 세션 3)
sub_project: "2/4 — E3 실전 타이머·자동제출·세션복원 + E4 문항 플래그"
parent_design: docs/designs/clf-learning-loop.md
foundation_spec: docs/designs/2026-06-06-clf-learning-loop-foundation-spec.md
created: 2026-06-06
generated_by: superpowers:brainstorming
---

# CLF 학습 루프 — 하위 프로젝트 #2 스펙 (시험 모드: 타이머·자동제출·세션복원·플래그)

## 0. 한 줄 목표

검증 콘텐츠가 있는 CLF Task를 **"시험처럼"** 풀 수 있다 — 실전 페이스 카운트다운 타이머 + 자유 네비게이션 + 문항 플래그 + 제출 전까지 정답 비공개 + 제출 시 채점·복기, 그리고 **새로고침/탭 닫기 후에도 응답·플래그·경과시간이 완전 복원**된다. 기존 "연습 모드"(즉시 공개)는 그대로 둔다.

## 1. 배경 / 맥락

- 스택: **Flutter Web / Dart**. 토큰은 `app_theme.dart`(`context.c`/`Gap`/`Radii`/`Layout`). 라이트 기본 + 다크.
- 하위 프로젝트 #1(기반)에서 만들어진 것: 학습문서 렌더러, **연습 모드** 퀴즈 러너(`QuizView`: 한 문항씩 "확인"→정답·해설 즉시 공개→"다음"), 이력 저장(`HistoryStore`/`AttemptRecord` = D14), 진입 동선(`CertDetailPage`→`StudyDocPage`→`QuizPage`).
- **이미 준비된 자리:** `AttemptRecord`에 `mode`('practice'|'exam')·`flaggedQuestionIds`·`durationSpentSec` 필드가 존재(현재 연습은 mode='practice', flagged=[]로 기록). `Layout.exam`(시험 본문 폭). 공식 시험 메타 `ExamOverview{passingScore, scoredQuestions, unscoredQuestions, durationMinutes}`가 `assets/exam_guides/{code}.json`에서 로드되어 상세 페이지에 이미 표시 중.
- 이 스펙은 CEO 플랜(`clf-learning-loop.md`)의 **E3·E4**를 구현한다. E6(약점 가중 모의고사, #4)이 같은 `ExamView`에 **교차-Task 풀**을 주입해 재사용할 토대다.

## 2. 범위

### 2.1 포함 (#2)
- **시험 모드 러너** `ExamView`: 자유 네비게이션(이전/다음 + 문항 그리드 점프), 제출 전 정답·해설 **비공개**, 채점은 제출 시 1회.
- **E3 타이머:** 실전 비례 페이스 카운트다운(공식 메타 출처). 벽시계 기준 경과시간.
- **E3 자동 제출:** 시간 소진 시 자동 제출, 미응답 = 오답. 자동·수동 경합은 제출 가드로 1회만.
- **E3 세션 복원:** 진행 중 세션(시작시각·응답·플래그·현재 위치)을 localStorage에 변경마다 저장 → 복귀 시 완전 복원. 복원 시 이미 만료면 즉시 자동 제출.
- **E4 플래그:** 응시 중 문항 토글, 그리드에 플래그 표시·점프, 제출 전 미검토 플래그 경고. 제출 시 `flaggedQuestionIds`로 이력 기록(→ #3 오답노트에서 재검토 가능).
- **진입:** `StudyDocPage`에 "시험처럼 풀기 (N문항 · ~M분)" CTA 추가(기존 "연습 문제 풀기" 옆).
- **리팩터(타깃):** 공유 위젯을 `quiz_widgets.dart`로 추출, KV 백엔드를 `local_kv.dart`로 승격.
- 검증: `flutter analyze`(0) · 단위/위젯 테스트 · `flutter test` · `flutter build web` 성공.

### 2.2 제외 (→ 후속)
- **교차-Task 풀 / 약점 가중 출제**(E6) → #4. 이번 `ExamView`는 단일 Task 문제은행에만 적용(구조는 풀 주입 가능하게).
- **오답 노트(E1)·약점 리포트(E2)** → #3. 이번엔 `flaggedQuestionIds` *기록*까지만(소비는 #3).
- **자격증 카드 진행률(E5)** → #4.
- 멀티탭 storage 이벤트 동기화 — 구현 안 함(아래 §7, CEO express: last-write-wins).

### 2.3 비목표 (YAGNI)
- 라우터 패키지·외부 타이머/상태관리 패키지 도입 안 함(`Timer.periodic` + `setState` + 기존 `Navigator.push`).
- 서버·계정 동기화 안 함(전부 localStorage).
- 다중 동시 시험 세션 관리 안 함(활성 세션은 examId별 1건; 키로 격리).

## 3. 아키텍처

### 3.1 새 파일 / 수정 파일

| 파일 | 책임 | 비고 |
|---|---|---|
| `lib/models/exam_session.dart` | `ExamSession`(진행 중 시험 상태) + JSON 직렬화 | 신규 |
| `lib/data/local_kv.dart` | `HistoryBackend`/`MemoryBackend`/`WebBackend` + 조건부 import(stub/web) | **이동**(현재 history_store.dart) |
| `lib/data/exam_session_store.dart` | 활성 세션 `load(examId)`/`save(session)`/`clear(examId)` | 신규, 백엔드 주입 |
| `lib/content/quiz_widgets.dart` | `OptionTile`/`PrimaryButton`/`ExplainBox`/`ResultsView`/`ResultCard` | **추출**(연습·시험 공유) |
| `lib/pages/exam_page.dart` | `ExamPage`(로더+복원) + `ExamView`(타이머 러너) | 신규 |
| `lib/data/history_store.dart` | 백엔드를 `local_kv.dart`에서 import | 수정(동작 불변) |
| `lib/pages/quiz_page.dart` | 추출 위젯 사용으로 정리 | 수정(연습 동작 불변) |
| `lib/pages/study_doc_page.dart` | "시험처럼 풀기" CTA 추가 | 수정 |
| `web_backend_stub.dart` / `web_backend_web.dart` | 그대로 `lib/data/`에 유지. 조건부 import 선언만 `local_kv.dart`로 이전 | 유지(이동 없음) |

> **격리 규칙(유지):** 페이지는 얇은 로더(`FutureBuilder`), 실제 로직은 모델 주입식 view(`ExamView`)가 한다. `ExamView`는 자산/localStorage가 아니라 **주입된 `QuestionBank` + 콜백 + (테스트용) 클록**에만 의존 → 위젯 테스트가 시간을 구동.

### 3.2 데이터 흐름
```
StudyDocPage
  ├─ "연습 문제 풀기" ─push─▶ QuizPage(기존, 즉시 공개)
  └─ "시험처럼 풀기"  ─push─▶ ExamPage
        ├─ 자산 로드: QuestionBank(questions.json) + ExamOverview(exam_guides/{code}.json)
        ├─ ExamSessionStore.load('exam:<taskId>')  ── 미제출 세션 있으면 복원(fingerprint 검사)
        └─ ExamView(bank, durationSec, startedAt, restored?)
              ├─ 변경(pick/flag/nav)마다 ─▶ ExamSessionStore.save(...)
              ├─ Timer.periodic(1s): 남은시간 = durationSec - (now - startedAt)  ≤0 ─▶ 자동 제출
              └─ 제출(수동/자동, 가드 1회)
                   ├─▶ HistoryStore.add(AttemptRecord(mode:'exam', flaggedQuestionIds, durationSpentSec))
                   ├─▶ ExamSessionStore.clear('exam:<taskId>')
                   └─▶ ResultsView(점수 + 합격선 참조 + 문항별 복기 + 플래그 표시)
```

## 4. 데이터 모델 — `ExamSession`

```dart
class ExamSession {
  final String examId;        // 'exam:<taskId>'  (예: 'exam:clf-t2-3')
  final String certId;        // 'CLF-C02'
  final String taskId;        // 'clf-t2-3'
  final String startedAtIso;  // 시작 벽시계 기준점(ISO-8601)
  final int durationSec;      // 이 세션의 총 제한시간(아래 §5 공식)
  final int index;            // 현재 보고 있는 문항
  final Map<int, int> picked; // 문항 인덱스 → 선택 보기 인덱스
  final List<int> flagged;    // 플래그된 문항 인덱스(정렬 보관)
  final String bankFingerprint; // '<questionCount>:<id0,id1,...>' — 콘텐츠 개정 감지
  final bool submitted;       // 제출 완료 여부(복원 시 무시 트리거)
}
```
- 저장 키: `awsdocs.examSession.v1:<examId>` (이력 키 `awsdocs.history.v1`와 별개).
- `toJson`/`fromJson`: `picked`는 문자열 키 맵으로 직렬화(JSON 객체 키는 문자열) 후 `int.parse` 복원. 손상 데이터는 `null` 반환(방어적).

## 5. 타이머 사양 (E3)

- **출처:** 해당 자격증의 `ExamOverview`(이미 로드됨).
- **페이스 공식:**
  ```
  totalOfficial = (scoredQuestions ?? 50) + (unscoredQuestions ?? 15)   // CLF: 65
  perQuestionSec = (durationMinutes ?? 90) * 60 / totalOfficial          // CLF: ≈ 83.08s
  durationSec    = (perQuestionSec * bank.questions.length).round()      // 7문항 ≈ 581s(9.7분)
  ```
  - 필드가 모두 null인 자격증(메타 누락)은 폴백 `perQuestionSec = 84`(≈ CLF 페이스). CLF는 메타가 있으므로 실측 적용.
- **벽시계 경과:** 남은시간 = `durationSec - (now - startedAtUtc)`. `startedAt`은 세션 최초 생성 시 1회 고정 → **새로고침으로 시간 벌기 불가**.
- **틱:** `Timer.periodic(const Duration(seconds: 1))`로 남은시간 갱신·표시. `dispose()`에서 반드시 `cancel()`(고스트 타이머 방지). 위젯 트리에서 벗어나면 틱 중단.
- **표시:** 상단 고정 카운트다운 `mm:ss`(JetBrainsMono, tabular). 잔여 ≤10%면 `c.warning` 색 + 약한 강조. 0 도달 시 자동 제출.
- **자동 제출:** 남은시간 ≤0 → `_submit(auto:true)`. 미응답 문항은 채점에서 오답(정답과 불일치 처리) → `wrongQuestionIds`에 포함.
- **제출 가드:** `bool _submitted` 플래그. 자동·수동 제출 첫 호출만 실행, 이후 무시(경합 1회 보장).

## 6. `ExamView` 상태 기계 / UX

- 상태: `index`, `Map<int,int> picked`, `Set<int> flagged`, `bool _submitted`, `Timer? _ticker`, `Duration _remaining`.
- **문항 화면:** stem + 보기 선택 카드(`OptionTile`, idle/selected만 — **정답 색 없음**). 하단: ◀ 이전 / 플래그 토글 / 다음 ▶. 마지막 문항이면 "제출".
- **문항 그리드(상단 바 아래 번호 칩 한 줄):** 1..N 번호 칩 — 응답함(채움)·플래그(마커)·현재(테두리) 상태 구분, 탭으로 점프. 문항 수가 적어(5~7) 한 줄로 충분. "플래그만 보기" 토글.
- **제출:** "제출" 또는 그리드의 제출 버튼 → 미검토 플래그가 있으면 다이얼로그 **"플래그한 문항 N개가 남아 있습니다. 그래도 제출할까요?"**(계속/취소). 확정 시 채점.
- **채점:** `correct = Σ(picked[k] == qs[k].correct)`, 미응답·오답은 `wrongQuestionIds`. `flaggedQuestionIds = flagged 정렬`. `durationSpentSec = min(durationSec, now - startedAt)`.
- **결과:** `ResultsView` 재사용 — 점수 `c/total · pct%`, **합격선 참조**("실전 합격 기준 ≈ 70%" 한 줄, passingScore 기반), 문항별 복기(`ResultCard`: 내 답/정답/해설/오답해설), **플래그였던 문항 배지** 표시. "다시 시험" / "학습문서로".
- **연습과의 차이 요약:** 연습=문항별 즉시 공개·뒤로 없음·타이머 없음 / 시험=제출 전 비공개·자유 네비·타이머·플래그·복원.

## 7. 세션 영속화 / 복원

- **저장 시점:** pick/flag/navigate 등 상태 변경마다 `ExamSessionStore.save(session(submitted:false))`. (CEO: 응답 변경 시마다.)
- **복원:** `ExamPage` 진입 시 `load('exam:<taskId>')`:
  - 세션 없음 → 새 시작(startedAt=now, durationSec=§5).
  - 세션 있음 & `submitted:false`:
    - `bankFingerprint` **불일치**(콘텐츠 개정으로 문항 수/ID 변경) → 세션 폐기 후 새 시작(데이터 정합 우선).
    - 일치 → index/picked/flagged/startedAt/durationSec 복원. 남은시간 ≤0이면 **즉시 자동 제출**(시간 벌기 차단). 상단에 가벼운 "이전 진행을 복원했습니다" 노트(1회).
- **제출 후:** `clear('exam:<taskId>')`로 활성 세션 제거(이력에는 `AttemptRecord` 1건 남음).
- **멀티탭:** last-write-wins. 같은 examId를 두 탭이 쓰면 마지막 저장이 승리. storage 이벤트 동기화·충돌 안내 없음(1인 사용 단계, CEO express).

## 8. 진입 동선

- `StudyDocPage` 하단 CTA를 **2개**로: 기존 "연습 문제 풀기 (N문항)" + 신규 "시험처럼 풀기 (N문항 · ~M분)". `M = (durationSec/60).round()`(라벨용 추정, 실제 시간은 ExamView가 정밀 계산).
- `entry.questionCount <= 0`이면 두 CTA 모두 숨김(기존 규칙 유지).
- `CertDetailPage`의 콘텐츠 카드(§9.1 foundation)는 이번 범위 밖(StudyDocPage 진입으로 충분).

## 9. 에러 / 빈 상태 / 엣지

- 자산 로드 실패: "콘텐츠를 불러오지 못했습니다" + 재시도(기존 패턴).
- 검증 문항 0개: 시험 CTA 비노출(가짜 자신감 방지 — foundation §10 일관).
- 시험 메타(`ExamOverview`) 없음/durationMinutes null: §5 폴백 페이스로 진행(시험 자체는 가능).
- 복원 세션의 `picked` 인덱스가 보기 범위를 벗어남(개정): fingerprint 단계에서 이미 폐기되므로 도달 불가(이중 안전: 채점 시 범위 검사).

## 10. 테스트 전략 (완료 기준)

- `test/exam_session_test.dart`:
  - `ExamSession` JSON 왕복(picked 문자열키 복원, flagged 보존).
  - `ExamSessionStore` save→load 동일, clear 후 null, 손상 데이터 → null.
  - fingerprint 헬퍼: 같은 bank 동일 값, 문항 변경 시 다른 값.
- `test/exam_view_test.dart`(모델 + 주입 클록):
  - 플래그 토글 → 그리드 반영 + save 호출.
  - 미응답 포함 채점: 미응답=오답, `wrongQuestionIds`/`flaggedQuestionIds` 정확.
  - **자동 제출:** 주입 클록을 durationSec 이후로 전진 → 1회 자동 제출, 결과 진입.
  - **제출 가드:** 자동+수동 동시 트리거 시 `onFinished` 1회만.
  - 미검토 플래그 경고 다이얼로그 노출/확정 흐름.
- 회귀: 기존 `quiz_view_test.dart`(연습)·`history_store_test.dart` 통과 유지(위젯 추출·백엔드 이동 후).
- `flutter analyze`(0) · `flutter test` · `flutter build web --release --base-href /aws-docs/`.

> **주입 클록 계약:** `ExamView`는 `DateTime Function() now`(기본 `DateTime.now`)와 `int durationSec`, `DateTime startedAt`을 받는다. 테스트는 `now`를 제어해 실제 대기 없이 만료/복원-만료를 검증한다. `Timer.periodic`은 위젯 생명주기에만 쓰고, 만료 판정은 `now()` 비교로 한다(테스트 결정성).

## 11. 리스크 / 완화

| 리스크 | 완화 |
|---|---|
| 고스트 타이머(여러 `Timer` 누적) | `dispose`에서 cancel, 단일 `_ticker` 보유 |
| 자동·수동 제출 이중 기록 | `_submitted` 가드 1회 보장 + 테스트 |
| 새로고침으로 시간 벌기 | 경과시간 = 저장된 `startedAt` 대비 벽시계, 복원 시 만료면 즉시 제출 |
| 콘텐츠 개정으로 stale 세션 | `bankFingerprint` 불일치 시 세션 폐기 |
| 위젯 추출이 연습 모드 깨뜨림 | 공개 API 동일하게 추출 + 기존 `quiz_view_test` 회귀 통과 |
| `package:web` 이동이 VM 테스트 깨뜨림 | 조건부 import(stub/web) 그대로 `local_kv.dart`로 이동(검증된 패턴) |
| DESIGN.md 이탈(하드코딩) | 색·간격 전부 `context.c`/`Gap`/`Radii`/`Layout` 토큰만 |

## 12. 파일별 구현 요약 (plan 입력)

1. `local_kv.dart`로 백엔드 추출 + `history_store.dart` import 교체(+회귀 테스트 green).
2. `quiz_widgets.dart`로 공유 위젯 추출 + `quiz_page.dart` 정리(+회귀 테스트 green).
3. `exam_session.dart` 모델(+JSON) — TDD.
4. `exam_session_store.dart`(+fingerprint 헬퍼) — TDD.
5. `exam_page.dart`의 `ExamView`(타이머·네비·플래그·자동제출·가드, 주입 클록) — TDD.
6. `exam_page.dart`의 `ExamPage`(로더+복원 배선).
7. `study_doc_page.dart` "시험처럼 풀기" CTA.
8. analyze / test / build web.

## 13. 디자인 토큰 규율

- 모든 색·간격은 `context.c`/`Gap`/`Radii`/`Layout` 토큰. 카운트다운·플래그 마커도 토큰 색(`accent`/`warning`/`border`). 모션 150–250ms.
- 시험 모드는 "조용한 레퍼런스" 브랜드 유지 — 압박 연출 과장 금지(타이머는 정보로 표시, 빨강 점멸 같은 자극 금지). 취업/DIO 맥락 무관.
