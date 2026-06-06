# cert-wide 통합 모의고사 설계 (Spec 2)

- **상태:** 설계 승인됨 (2026-06-06). 구현 계획(writing-plans) 대기.
- **범위:** 자격증 전체 문항 풀에서 도메인 가중으로 N문항을 샘플링해 출제하는 통합 모의고사. 라우트 `/cert/:code/exam`과 랜딩 진입점은 Spec 1에서 예약됨(`CertExamPage`가 현재 "준비 중" placeholder). 본 스펙이 그 placeholder를 실제 기능으로 대체한다. 첫 대상은 **CLF-C02**(유일한 콘텐츠 보유 자격증)이나, 로직은 자격증 일반으로 작성한다.
- **대상 코드베이스:** `aws-docs/flutter_app` (Flutter Web, GitHub Pages 배포, base-href `/aws-docs/`).
- **브랜드 제약:** `DESIGN.md` "조용한 레퍼런스" + "정직함의 시각화". 새 디자인 언어 금지, 기존 테마 토큰·위젯 재사용. 검증 문항(`verified:true`)만 출제.

## 1. 목표 & 성공 기준

자격증의 **모든 Task 검증 문항을 하나의 풀로 합쳐**, 실제 시험 블루프린트(도메인 비중)를 반영해 N문항을 출제하고 채점하는 통합 모의고사를 제공한다.

성공 기준:
- `/cert/CLF-C02/exam` 진입 → 시작 화면(문항 수·시간·도메인 비중·합격선) → '시작' → 도메인 가중으로 65문항이 출제된다.
- 출제 문항은 **검증 문항 풀(현재 130개)**에서만 나오며, 도메인 분포가 공식 비중(24/30/34/12%)에 근사한다.
- 진행 중 새로고침/뒤로가기 후 재진입 시 **같은 시험(동일 문항·순서·진행 상태)**이 복원된다.
- 제출 시 채점 결과(정답 수·플래그·문항별 해설)가 표시되고 이력에 기록된다.
- 기존 Task별 시험(`/cert/:code/study/:taskId/exam`)과 그 세션·테스트가 영향받지 않는다.
- async 페이지 위젯 렌더 테스트 없이(메모리의 SelectionArea 함정 회피) 핵심 로직이 단위 테스트로 검증된다.

## 2. 현재 상태 (재사용 자산 & 갭)

**재사용 자산:**
- **`ExamView`** (`lib/pages/exam_page.dart:19`): 모델 주입식 시험 러너. `QuestionBank` + `certId`/`taskId`/`startedAt`/`durationSec` + 초기 상태(index/picked/flagged) + 콜백(`onChanged`/`onFinished`/`onExit`)을 받음. 자산·localStorage 무의존, 타이머·문항 그리드·플래그·제출 다이얼로그·결과(`ResultsView`)·자동 제출 전부 구현됨. **샘플링된 subset을 `QuestionBank`로 만들어 주입하면 그대로 동작.**
- **`ExamPage`** (`lib/pages/exam_page.dart:425`): Task 1개용 얇은 로더(뱅크 1개 로드 + 시험 메타 + 세션 복원 → `ExamView` 주입). 본 스펙 로더의 패턴 원본.
- **`examDurationSec`** (`lib/models/exam_session.dart:75`): `durationMinutes`/`scored`/`unscored`/`count`로 문항당 페이스 자동 환산. N문항이면 그대로 스케일.
- **`content_index.dart`**: `contentFor(code)`(`:202`)로 자격증의 모든 `ContentEntry`(각 `questionsAsset`+`domain`) 열거. `certContentSummary`(`:209`)로 총 검증 문항 수.
- **exam guide JSON**: `assets/exam_guides/CLF-C02.json`에 `overview`(passingScore 700·scored 50·unscored 15·duration 90) + 도메인별 `weightPct`(`ExamDomain`, `lib/models/exam_guide.dart:54`).
- **`ExamSessionStore`**(`lib/data/exam_session_store.dart:7`) / **`HistoryStore`**(`lib/data/history_store.dart:10`): examId 키 영속화 / 응시 이력 기록.

**갭 (본 스펙이 채움):**
1. 자격증 전체 뱅크 병합 + 도메인 가중 N문항 샘플링 로직(없음).
2. 샘플 시험의 세션 복원: 현재 `ExamSession`은 출제 ID 목록을 직접 보존하지 않음 — 복원 시 동일 샘플 재현 불가(아래 §6).
3. `CertExamPage` 실제 구현(현재 placeholder, `lib/pages/cert_exam_page.dart:8`).

## 3. 시험 사양 (CLF-C02)

공식 메타(`assets/exam_guides/CLF-C02.json` 검증): 합격선 **700/1000**, **65문항**(채점 50 + 비채점 15), **90분**, 도메인 비중 **D1 24 · D2 30 · D3 34 · D4 12%**.

- **문항 수 N = 65** (실전 동일). 시간 = `examDurationSec(durationMinutes:90, scored:50, unscored:15, count:65)` = 90분.
- **도메인 가중 배분**(largest-remainder로 합=N 보정): 65 → **D1 16 · D2 19 · D3 22 · D4 8**.
- **풀 용량**(검증 문항, content_index 기준): D1 27 · D2 31 · D3 51 · D4 21 (합 130). 모든 도메인이 배분량 초과 보유 → 부족 없음.
- 비채점 문항 구분은 출제하지 않음(전 문항 채점). 결과는 기존 ExamView처럼 정답률 표시 + "실제 합격선은 1000점 환산 700점" 주석 유지(정밀 환산은 범위 밖, §10).

## 4. 컴포넌트 (작고 격리된 단위)

### 4.1 `lib/data/mock_exam.dart` (신규, 순수 Dart — Flutter 무의존)
단위 테스트 가능한 순수 함수 모음. async 위젯 렌더 없이 전량 검증.
- `Map<int,int> allocateByWeight(Map<int,int> weightByDomain, int n)` — 도메인→출제 수. floor 후 잔여를 fractional 큰 순(largest-remainder)으로 +1. 합 == n 보장.
- `List<Question> buildMockExam({required Map<int,List<Question>> poolByDomain, required Map<int,int> weightByDomain, required int n, required Random rng})` — 도메인별 배분량만큼 셔플·추출 → 합쳐 최종 셔플한 순서 리스트 반환. **`rng` 주입**으로 결정성 확보.
- **풀 부족 폴백:** 특정 도메인 풀 < 배분량이면 가능한 만큼 취하고 부족분은 잔여 도메인 풀에서 보충(총 N 유지, 풀 총량 < N이면 가능한 최대).

### 4.2 `ExamSession` 확장 (`lib/models/exam_session.dart`)
- 필드 추가: `final List<String> questionIds;` (기본 `const []`). `toJson`/`fromJson` 하위호환(누락 시 `[]`).
- 의미: 이 세션이 출제한 문항 ID를 **순서대로** 보존 → 복원 시 동일 시험 재구성의 단일 소스.

### 4.3 `ExamView` 재사용 + 1줄 추가 (`lib/pages/exam_page.dart`)
- `_session()`(`:102`)에 `questionIds: _qs.map((q) => q.id).toList()` 한 줄 추가 → 모든 시험(Task·통합)이 출제 순서를 세션에 보존. 기존 Task 시험 복원은 여전히 `bankFingerprint` 매칭을 사용하므로 영향 없음(추가 필드는 무해).
- 그 외 ExamView 로직·UI **무수정**.

### 4.4 `CertExamPage` 재작성 (`lib/pages/cert_exam_page.dart`)
placeholder를 로더+시작화면+복원으로 대체. `ExamPage` 패턴 미러.
- 입력: `Certification cert`(라우터가 이미 주입, `app_router.dart:31`).
- examId/식별자: 합성 `taskId = '<code>-mock'` → examId `exam:<code>-mock`(예: `exam:CLF-C02-mock`). certId = code. Task 시험(`exam:clf-t2-1` 등)과 키 충돌 없음.

## 5. 데이터 흐름 & 생명주기

1. **로드:** `contentFor(code)`의 모든 `questionsAsset`를 `Future.wait`로 로드 → `QuestionBank.fromJson`(검증 문항만) → `Map<int domain, List<Question>>` 풀로 병합. exam guide `overview`/`weightPct` 로드(없으면 균등 폴백).
2. **복원 판정:** `store.load('exam:<code>-mock')` →
   - 세션 존재 ∧ `!submitted` ∧ `questionIds` 비어있지 않음 ∧ **모든 id가 현재 풀에 존재** ∧ 개수 일치 → **복원**: id 순서대로 `Question` 재구성 → 합성 `QuestionBank` → ExamView에 index/picked/flagged 주입, `restored:true`.
   - 아니면(없음/제출됨/콘텐츠 개정으로 id 불일치) → 기존 세션 clear → **시작 화면**.
3. **시작:** '시작' 클릭 시 `buildMockExam(...)`로 샘플 → 합성 `QuestionBank` → `startedAt = now`, `durationSec = examDurationSec(...)` → ExamView 마운트(타이머 시작).
4. **진행:** ExamView `onChanged` → `store.save`(questionIds 포함).
5. **제출:** ExamView `onFinished(AttemptRecord)` → `HistoryStore.add` + `store.clear`. 결과 화면(기존 `ResultsView`).
6. **합성 QuestionBank:** `QuestionBank(examGuideTaskId:'<code>-mock', taskTitle:'통합 모의고사', certCode:code, domain:0, questions: sampled)`.

## 6. 세션 복원 메커니즘 (핵심 결정)

샘플링은 매 응시 랜덤이라, 진행 중 새로고침 시 "같은 시험" 재현이 필요하다. picked/flagged/index가 **인덱스 기반**이므로 출제 문항 집합 **+ 순서**가 동일해야 정합한다.

- **채택: 출제 ID 명시 보존(§4.2).** 세션에 `questionIds`를 순서대로 저장하고, 복원 시 풀에서 ID로 재구성·검증. 모든 id가 풀에 존재하고 개수가 맞을 때만 복원, 아니면 폐기 후 새 시험. 콘텐츠 개정(문항 삭제/verified 회수) 시 자동으로 안전하게 무효화 → 브랜드 "정직함"의 복원 무결성 보장.
- 기각: (B) seed+N 재샘플 — 풀 변경 시 동일 시드가 다른 샘플 생성 → 픽 인덱스 어긋나 정답 오표시. (C) `bankFingerprint`(이미 `len:id,…` 포함) 문자열 파싱 — 무결성·재구성 두 용도 혼탁, 파싱 취약.
- 참고: `bankFingerprint`는 그대로 유지(Task 시험의 개정 감지). 통합 시험 복원은 `questionIds`에 의존.

## 7. 시작 화면 (CertExamPage 내 상태)

기존 테마 토큰·위젯으로 구성(새 디자인 언어 없음):
- 문항 수(65) · 제한 시간(90분) · 도메인 비중(D1 24 · D2 30 · D3 34 · D4 12%) · 합격선(700/1000) 안내.
- **'시작'** 버튼 → 샘플링 후 ExamView 마운트(타이머 이때 시작).
- 진행 중(복원 가능) 세션이 있으면 **'이어서 풀기'**(복원) + **'새로 시작'**(기존 세션 clear 후 재샘플) 동시 제공.
- 풀이 비었으면(검증 문항 0) "검증된 문항이 아직 없습니다" 안내 + 학습 콘텐츠로 이동.

## 8. 엣지/에러

- 알 수 없는 `code`: 라우터가 이미 `/`로 redirect(`app_router.dart`). 진입 시 추가 가드 불필요.
- 뱅크 로드 실패(개별 자산): 해당 뱅크 제외하고 진행. 전체 실패/풀=0 → "검증 문항 없음" 안내.
- 풀 총량 < N: 가능한 최대 문항으로 진행(§4.1 폴백). 시간은 실제 count로 환산.
- 손상 세션 / questionIds 불일치: 조용히 폐기(기존 ExamPage 폴백과 동일 정책).
- 타이머 만료: 기존 ExamView 자동 제출 재사용.
- base-href `/aws-docs/` + hash 전략: 라우트 추가 없음(`/cert/:code/exam`는 Spec 1에 이미 존재) → CI 변경 불필요.

## 9. 테스트 (TDD · SelectionArea 함정 회피)

- **신규 단위 `mock_exam_test.dart`:** `allocateByWeight` 합=N·도메인별 정확·잔여 배분; `buildMockExam` 도메인 분포·풀부족 폴백·동일 `rng` seed 결정성·출제 문항이 전부 풀 소속.
- **`exam_session_test`(확장):** `questionIds` 직렬화 라운드트립; 누락 JSON → `[]` 하위호환.
- **신규 복원 단위:** questionIds → 풀 재구성 시 순서·picked/flagged 인덱스 정합; id 불일치 시 복원 거부.
- **ExamView:** 기존 `exam_view_test.dart`(model-injected)로 채점·플래그 커버. 통합 시험은 샘플된 `QuestionBank` 주입이라 동일 경로.
- **라우팅:** `app_router_test`에 `/cert/:code/exam` → (해석 성공) 경로만 검증. **async `CertExamPage` 위젯 렌더 단언 금지**(RenderBox 크래시) — 해석/리다이렉트만.
- **의존성:** 신규 런타임 패키지 없음(dart:math `Random`만). 구현 시 관련 API는 Context7로 확인(전역 규칙).

## 10. 범위 밖 (YAGNI / 후속)

- 보기(option) 순서 셔플 — picked 인덱스 매핑 변경 필요, 별도 작업.
- 1000점 정밀 환산 점수 — 현 정답률 표시 + 주석 유지.
- 응시 이력 표시 UI — 현재 이력을 표시하는 화면이 없음(기록만). 통합 시험도 기록만.
- 다중 자격증 통합 시험 — 로직은 일반화하되 콘텐츠는 CLF-C02만 존재.
- 응시 시 문항 수 선택(25/45/65) — 본 스펙은 고정 65.
- 채점/비채점 문항 분리 출제.

## 11. 결정 로그 (브레인스토밍 2026-06-06)

| 결정 | 선택 | 근거 |
|---|---|---|
| 문항 수/길이 | 실전 동일 65문항·90분 | 실전 감각. 풀 130으로 충분(두 응시 ~50% 중복은 수용) |
| 출제 분포 | 공식 도메인 비중 가중 | 실제 블루프린트 반영, exam guide `weightPct` 재사용 |
| 시작 방식 | 시작 화면 먼저 | 긴 시험에서 준비 전 타이머 소모 방지 + 복원 안내 지점 |
| 세션 복원 | 출제 ID 명시 보존(A) | 콘텐츠 개정에 안전·테스트 용이. seed/fingerprint 방식의 오표시 위험 회피 |
| ExamView 재사용 | 1줄 추가(questionIds 보존) | 합성 QuestionBank 주입으로 러너 전체 재사용, 복원만 보강 |
| examId | `exam:<code>-mock` | Task 시험 세션과 키 분리, mode 'exam' 재사용 |
| 재응시 | 제출 후 재진입 → 새 랜덤 샘플 | 모의고사 반복 학습의 자연스러운 기대 |
| 샘플러 위치 | 순수 모듈 `mock_exam.dart` | async 위젯 테스트 함정 회피, 결정적 단위 테스트 |
