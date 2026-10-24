# 시험 세션 문항 스냅샷 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 진행 중인 시험이 콘텐츠 릴리스를 가로질러도 시작 시점 문항·보기·채점·해설 그대로 끝까지 유지된다.

**Architecture:** 세션이 출제 문항 전체를 스냅샷으로 들고 가서 복원이 에셋을 전혀 읽지 않게 한다. 불변부(스냅샷)와 가변부(진행)를 **다른 키**로 나눠 매 탭마다 112 KB를 다시 쓰지 않고, 둘을 **세대 nonce**로 짝지어 키 분리가 만드는 손상 채널을 막는다. 개정 감지는 설계 단계에서 기각됐다.

**Tech Stack:** Flutter Web (Dart), `KvBackend`(웹=localStorage / VM·테스트=메모리), `flutter_test`

**Spec:** `docs/superpowers/specs/2026-10-24-exam-session-snapshot-design.md`

## Global Constraints

- `flutter analyze` **0건**, `flutter test` 전부 통과. 수치 정본은 `CLAUDE.md` 빌드·테스트 절 — 테스트가 늘면 **그 줄을 같이 고친다**
- 모든 명령은 `flutter_app/` 기준. 단일 파일은 `flutter test test/<파일>.dart`
- **Test-First**(CLAUDE.md 절대 조건 2): 실패 테스트 선작성 → 실패 확인 → 최소 구현 → 통과 확인 → 커밋
- 커밋 직전 `git branch --show-current`로 의도한 브랜치 확인(CLAUDE.md 절대 조건 5 — 공유 워킹트리)
- **스냅샷은 `verified` 게이트보다 우선한다.** 스냅샷 역직렬화는 `QuestionBank.fromJson`을 쓰면 안 된다 — 그 생성자가 `.where((q) => q.verified)`로 거른다(`lib/models/question.dart:113`)
- **`KvBackend`에는 삭제 API가 없다.** 삭제는 빈 문자열 쓰기이고 `load`가 빈 문자열을 null로 본다(`exam_session_store.dart`)
- **정리(GC)는 시간 만료분만.** `startedAtIso + durationSec`이 지난 세션만 지운다. 개수 상한·TTL 금지 — 반목표 위반
- 에셋을 읽는 페이지를 한 테스트 파일에서 두 번 이상 렌더하면 `rootBundle` 캐시로 다음 테스트가 **예외 없이 멈춘다** → `setUp(rootBundle.clear)`
- `pumpAndSettle`의 첫 인자는 타임아웃이 아니라 펌프 간격(기본 타임아웃 10분) — 진단 시 3번째 인자로 짧은 타임아웃을 명시

## Review Focus

스펙이 함의하지만 어느 Task의 테스트도 직접 건드리지 않는 입력·실패 모드 다섯. 각 줄의 테스트는 해당 Task에 넣었다.

1. **스냅샷 쓰기가 쿼터로 실패** — 시험 시작이 막히면 안 된다(반목표). 저장만 포기하고 시험은 진행 → **Task 5·6**
2. **손상된 스냅샷 JSON** — `load`가 null로 무시하고 새 시험으로 시작 → **Task 3**
3. **스냅샷만 있고 진행 키 없음** — `ExamPage` 첫 상호작용 전 이탈, `CertExamPage` 시작 직후. index 0·무선택으로 복원 → **Task 3**
4. **`picked` 인덱스가 스냅샷 보기 개수를 벗어남**(손상·개정 잔재) — 그 응답을 버리고 미선택으로 복원 → **Task 2**
5. **복원 시점에 이미 시간 만료** — 복원되자마자 자동 제출되고, 그런 세션만 GC 대상 → **Task 3**

---

## File Structure

| 파일 | 책임 |
|---|---|
| `lib/models/study_content.dart` (수정) | `StudySource.toJson` |
| `lib/models/question.dart` (수정) | `Question.toJson` |
| `lib/models/exam_snapshot.dart` (신규) | `ExamSnapshot`·`ExamProgress` 모델 + 직렬화 + 필터 없는 역직렬화 |
| `lib/data/exam_session_store.dart` (수정) | 두 키 읽기·쓰기·nonce 짝 검증·만료 정리 |
| `lib/pages/exam/exam_view.dart` (수정) | `onChanged`가 진행만 통지 |
| `lib/pages/exam_page.dart` (수정) | Task 시험: 첫 상호작용 시 스냅샷 쓰기 + 스냅샷 복원 |
| `lib/pages/cert_exam_page.dart` (수정) | 통합·약점: 시작 시 스냅샷 쓰기 + 복원 + 게이트 순서 재배치 |

`ExamSession`은 `exam_session.dart`에 남겨 둔다(구포맷 판별용). `bankFingerprint`·`examDurationSec`도 같은 파일에 유지 — `examDurationSec`은 계속 쓰이고, `bankFingerprint`는 Task 7에서 판단한다.

---

### Task 1: 문항 직렬화 기반

**Files:**
- Modify: `flutter_app/lib/models/study_content.dart` (`StudySource`, 5-14행)
- Modify: `flutter_app/lib/models/question.dart` (`Question`, 3-89행)
- Test: `flutter_app/test/question_serialization_test.dart` (신규)

**Interfaces:**
- Consumes: 없음
- Produces: `Map<String, dynamic> StudySource.toJson()` · `Map<String, dynamic> Question.toJson()`

`Question.fromJson(q.toJson())`이 모든 필드에서 원본과 같아야 한다. `wrongExplanations`는 `Map<int, String>`이고 JSON 키는 문자열이 되므로 `fromJson`의 기존 `int.tryParse` 복원 경로와 맞물려야 한다.

- [ ] **Step 1: 실패 테스트 작성**

```dart
// test/question_serialization_test.dart
test('Question 라운드트립: 모든 필드 보존', () {
  const q = Question(
    id: 'q1', examGuideTaskId: 'clf-t2-3', skill: '최소 권한',
    section: 'iam', difficulty: 'medium',
    stem: '루트 전용 작업은?', options: ['EC2 시작', '계정 해지'], correct: 1,
    explanation: '계정 해지는 루트 전용.',
    wrongExplanations: {0: 'EC2는 일상.'},
    sources: [StudySource(title: 'IAM', url: 'https://docs.aws.amazon.com/iam/')],
    verified: true,
  );
  final back = Question.fromJson(q.toJson());
  expect(back.id, q.id);
  expect(back.skill, q.skill);
  expect(back.section, q.section);
  expect(back.difficulty, q.difficulty);
  expect(back.stem, q.stem);
  expect(back.options, q.options);
  expect(back.correct, q.correct);
  expect(back.explanation, q.explanation);
  expect(back.wrongExplanations, q.wrongExplanations); // int 키 복원
  expect(back.sources.single.url, q.sources.single.url);
  expect(back.verified, isTrue);
});

test('verified:false도 toJson/fromJson에서 보존된다', () {
  // 스냅샷은 철회 문항을 그대로 들고 가야 하므로 이 플래그가 살아야 한다.
  final back = Question.fromJson(_q(verified: false).toJson());
  expect(back.verified, isFalse);
});
```

- [ ] **Step 2: 실패 확인**

Run: `cd flutter_app && flutter test test/question_serialization_test.dart`
Expected: FAIL — `The method 'toJson' isn't defined for the type 'Question'`

- [ ] **Step 3: `toJson` 구현**

`StudySource.toJson()`은 `title`·`url`. `Question.toJson()`은 12개 필드 전부, `wrongExplanations` 키는 문자열로, `sources`는 `toJson()` 목록으로.

- [ ] **Step 4: 통과 확인**

Run: `cd flutter_app && flutter test test/question_serialization_test.dart`
Expected: PASS

- [ ] **Step 5: 커밋**

```bash
git add flutter_app/lib/models/study_content.dart flutter_app/lib/models/question.dart flutter_app/test/question_serialization_test.dart
git commit -m "feat(models): Question·StudySource toJson — 스냅샷 직렬화 기반"
```

---

### Task 2: 스냅샷·진행 모델

**Files:**
- Create: `flutter_app/lib/models/exam_snapshot.dart`
- Test: `flutter_app/test/exam_snapshot_test.dart` (신규)

**Interfaces:**
- Consumes: `Question.toJson()`·`Question.fromJson()` (Task 1)
- Produces:
  - `class ExamSnapshot { final String examId, certId, taskId, nonce, startedAtIso; final int durationSec; final List<Question> questions; Map<String,dynamic> toJson(); factory ExamSnapshot.fromJson(Map<String,dynamic>); }`
  - `class ExamProgress { final String examId, nonce; final int index; final Map<int,int> picked; final List<int> flagged; Map<String,dynamic> toJson(); factory ExamProgress.fromJson(Map<String,dynamic>); }`
  - `ExamProgress sanitizeProgress(ExamProgress p, List<Question> questions)` — 범위를 벗어난 응답·플래그를 버린다

⚠️ **역직렬화는 `QuestionBank.fromJson`을 거치지 않는다.** 문항 목록을 `Question.fromJson`으로 직접 복원해 `verified` 필터를 타지 않게 한다(스펙 §4.2).

- [ ] **Step 1: 실패 테스트 작성**

```dart
test('ExamSnapshot 라운드트립 — 문항·순서·nonce 보존', () { /* toJson→fromJson, questions[i].id 순서 동일, nonce 동일 */ });

test('⚠️ 철회 문항도 스냅샷에서 살아남는다(verified 게이트 우선)', () {
  // QuestionBank.fromJson 을 타면 .where((q) => q.verified) 로 사라진다.
  final snap = ExamSnapshot.fromJson(_snapshotWith(verified: false).toJson());
  expect(snap.questions.length, 2, reason: '스냅샷은 verified 게이트보다 우선한다');
});

test('ExamProgress 라운드트립 — picked 문자열 키 복원', () { /* {0:1} 왕복 */ });

test('sanitizeProgress: 보기 개수를 벗어난 응답을 버린다', () {
  // Review Focus 4 — 2지선다 문항에 picked {0: 5} 가 들어온 경우
  final clean = sanitizeProgress(_progress(picked: {0: 5, 1: 0}), _twoOptionQs());
  expect(clean.picked.containsKey(0), isFalse);
  expect(clean.picked[1], 0);
});

test('sanitizeProgress: 문항 수를 벗어난 index·flagged를 접는다', () { /* index clamp, flagged 필터 */ });
```

- [ ] **Step 2: 실패 확인** — Run: `flutter test test/exam_snapshot_test.dart` / Expected: FAIL (파일·타입 없음)
- [ ] **Step 3: `lib/models/exam_snapshot.dart` 구현** — 위 Produces의 시그니처대로. `sanitizeProgress`는 `picked`에서 `value >= options.length`인 항목 제거, `index`는 `clamp(0, questions.length-1)`, `flagged`는 범위 밖 제거.
- [ ] **Step 4: 통과 확인** — Expected: PASS
- [ ] **Step 5: 커밋** — `feat(models): ExamSnapshot·ExamProgress — 필터 없는 역직렬화 + 진행 정화`

---

### Task 3: 두 키 저장소

**Files:**
- Modify: `flutter_app/lib/data/exam_session_store.dart`
- Test: `flutter_app/test/exam_snapshot_store_test.dart` (신규)

**Interfaces:**
- Consumes: `ExamSnapshot`·`ExamProgress`·`sanitizeProgress` (Task 2)
- Produces (`ExamSessionStore`에 추가):
  - `void saveSnapshot(ExamSnapshot s)` · `ExamSnapshot? loadSnapshot(String examId)`
  - `void saveProgress(ExamProgress p)` · `ExamProgress? loadProgress(String examId)`
  - `({ExamSnapshot snapshot, ExamProgress progress})? loadRun(String examId, {DateTime Function()? now})` — 짝 검증·정화까지 끝난 복원 결과. 스냅샷이 없으면 `null`
  - `int clearExpired({DateTime Function()? now})` — 만료 세션 정리, 지운 수 반환

키는 `awsdocs.examSnapshot.v1:$examId` · `awsdocs.examProgress.v1:$examId`. 기존 `awsdocs.examSession.v1:` 키는 Task 5·6에서 구포맷으로 판별해 비운다.

`loadRun`은 스냅샷이 있으면 항상 복원한다. 진행 키가 없거나 nonce가 다르면 **index 0·무선택 진행**을 만들어 돌려준다(폐기하지 않는다). 만료 여부로는 거르지 않는다 — 만료 세션은 복원 직후 `ExamView`가 자동 제출한다.

- [ ] **Step 1: 실패 테스트 작성**

```dart
test('스냅샷·진행 왕복 후 loadRun이 둘을 짝지어 돌려준다', () { /* 같은 nonce */ });

test('⚠️ nonce 불일치: 진행을 버리고 index 0·무선택으로 복원', () {
  // Review Focus — 키 분리가 만드는 손상 채널
  store.saveSnapshot(_snap(nonce: 'B'));
  store.saveProgress(_prog(nonce: 'A', index: 7, picked: {3: 1}));
  final run = store.loadRun(examId)!;
  expect(run.progress.index, 0);
  expect(run.progress.picked, isEmpty);
});

test('⚠️ 스냅샷만 있고 진행 키 없음 → index 0·무선택 복원', () { /* Review Focus 3 */ });

test('⚠️ 손상된 스냅샷 JSON → loadRun null(새 시험)', () {
  backend.write('awsdocs.examSnapshot.v1:$examId', '{깨진');
  expect(store.loadRun(examId), isNull); // Review Focus 2
});

test('진행 키만 있고 스냅샷 없음 → null', () { /* 부분 손상도 새 시험으로 */ });

test('loadRun은 벗어난 picked를 정화해서 돌려준다', () { /* sanitizeProgress 경유 */ });

test('⚠️ 만료 세션도 loadRun은 복원한다(자동 제출은 ExamView 몫)', () {
  // Review Focus 5 — 저장소가 거르면 사용자는 결과를 못 본다
  expect(store.loadRun(examId, now: () => _after(start, durationSec + 60)), isNotNull);
});

test('clearExpired: 만료분만 지우고 살아 있는 세션은 남긴다', () {
  // 반목표 — 살아 있는 시험을 지우면 안 된다
  expect(store.clearExpired(now: ...), 1);
  expect(store.loadRun(aliveExamId), isNotNull);
});
```

- [ ] **Step 2: 실패 확인** — Expected: FAIL (`saveSnapshot` 미정의)
- [ ] **Step 3: 저장소 구현** — 위 시그니처대로. `clearExpired`는 `keys()`를 스냅샷 접두사로 훑어 `startedAtIso + durationSec < now`인 것만 두 키 모두 비운다.
- [ ] **Step 4: 통과 확인** — Expected: PASS
- [ ] **Step 5: 커밋** — `feat(data): 스냅샷·진행 2키 저장소 + nonce 짝 검증 + 만료 정리`

---

### Task 4: ExamView가 진행만 통지한다

**Files:**
- Modify: `flutter_app/lib/pages/exam/exam_view.dart` (`_session`·`_persist`·`onChanged`)
- Modify: `flutter_app/test/exam_view_test.dart` (기존 13 케이스의 `onChanged` 단언)
- Test: 같은 파일

**Interfaces:**
- Consumes: `ExamProgress` (Task 2)
- Produces:
  - `ExamView({..., void Function(ExamProgress)? onChanged, String? runNonce, ...})` — `sessionFingerprint`·`optionOrders` 파라미터 제거
  - `void recordFinishedAttempt(AttemptRecord r, {required HistoryStore history, required ExamSessionStore sessions, required String examId})` — 시그니처 유지, **두 키를 모두 비우도록** 변경

`ExamView`는 더 이상 `ExamSession`을 만들지 않는다. `_persist()`는 `index`·`picked`·`flagged`와 주입받은 `runNonce`만 담은 `ExamProgress`를 넘긴다. `submitted`는 담지 않는다 — 앱이 저장한 적이 없는 필드다(스펙 §4.4.2). 시간 만료 자동 제출·결과 화면 동작은 그대로다.

⚠️ **제출 시 삭제**(스펙 §4.6): 현행 `recordFinishedAttempt`는 `sessions.clear(examId)` 한 번으로 끝났지만 키가 둘이 됐으므로 **스냅샷·진행을 모두** 비워야 한다. 한쪽만 지우면 다음 입장에서 반쪽 상태를 만난다.

- [ ] **Step 1: 실패 테스트 작성** — 기존 "onChanged 세션에 출제 문항 ID가 순서대로 담긴다"를 **진행 통지**로 바꾼다.

```dart
test('onChanged는 진행만 통지한다(문항 목록·지문 없음)', () {
  // ExamProgress에는 questions가 없다 — 스냅샷이 이미 들고 있다.
  expect(saved!.nonce, 'run-1');
  expect(saved!.picked, {0: 1});
});

test('제출 시 스냅샷과 진행을 모두 비운다', () {
  // 스펙 §4.6 — 한쪽만 지우면 다음 입장에서 반쪽 상태를 만난다
  recordFinishedAttempt(rec, history: h, sessions: store, examId: examId);
  expect(store.loadSnapshot(examId), isNull);
  expect(store.loadProgress(examId), isNull);
});

test('기록 저장이 실패해도 두 키는 정리된다', () {
  // 기존 계약 유지(try/finally) — 쿼터 백엔드로 history.add가 던져도 clear는 돈다
  expect(() => recordFinishedAttempt(rec, history: quotaH, sessions: store, examId: examId),
      throwsA(isA<StateError>()));
  expect(store.loadSnapshot(examId), isNull);
});
```

- [ ] **Step 2: 실패 확인** — Run: `flutter test test/exam_view_test.dart` / Expected: FAIL (타입 불일치)
- [ ] **Step 3: `ExamView` 배선 변경** — `onChanged` 타입 교체, `runNonce` 추가, `_session()` 제거.
- [ ] **Step 4: 통과 확인** — `flutter test test/exam_view_test.dart` 전부 PASS
- [ ] **Step 5: 커밋** — `refactor(exam): ExamView가 ExamProgress만 통지`

---

### Task 5: ExamPage — 첫 상호작용 시 스냅샷

**Files:**
- Modify: `flutter_app/lib/pages/exam_page.dart` (`_ExamPageState._load`, 46-140행 부근)
- Test: `flutter_app/test/exam_page_snapshot_test.dart` (신규)

**Interfaces:**
- Consumes: `loadRun`·`saveSnapshot`·`saveProgress` (Task 3), `ExamView.runNonce` (Task 4)
- Produces: 없음(페이지)

`_load()`는 먼저 `loadRun(examId)`을 본다. 있으면 **에셋을 읽지 않고** 스냅샷으로 `ExamView`를 띄운다. 없으면 현행대로 차출·셔플한 뒤 스냅샷을 **메모리에만** 들고, `ExamView`의 **첫 `onChanged`에서** 스냅샷+진행을 함께 쓴다(스펙 §4.5 — 진입만 하고 이탈하면 세션 없음). 구포맷 `awsdocs.examSession.v1:` 키가 있으면 비운다.

- [ ] **Step 1: 실패 테스트 작성**

```dart
setUp(rootBundle.clear); // 전역 제약

testWidgets('⚠️ 릴리스를 가로질러도 스냅샷 문항이 유지된다', () async {
  // 스냅샷에 에셋과 다른 stem을 심고 렌더 → 스냅샷 쪽 문구가 보인다
  expect(find.text('스냅샷 전용 문항'), findsOneWidget);
});

testWidgets('진입만 하고 상호작용이 없으면 스냅샷을 쓰지 않는다', () async {
  expect(store.loadSnapshot(examId), isNull); // 스펙 §4.5
});

testWidgets('첫 응답에서 스냅샷과 진행이 함께 저장된다', () async { /* 둘 다 non-null, 같은 nonce */ });

testWidgets('⚠️ 스냅샷 쓰기가 실패해도 시험은 진행된다', () async {
  // 반목표 — 쿼터 초과 백엔드. 문항이 그대로 보이고 예외가 사용자에게 닿지 않는다
  expect(find.textContaining('문항'), findsWidgets);
});

testWidgets('구포맷 examSession 키는 복원하지 않고 비운다', () async { /* §4.8 */ });

testWidgets('⚠️ 스냅샷은 시험 중 다시 쓰이지 않는다', () async {
  // 스펙 §4.4의 존재 이유 — 이게 깨지면 매 탭 112 KB를 다시 쓴다.
  // 쓰기 횟수를 세는 KvBackend로 여러 번 응답·이동한 뒤 확인한다.
  expect(counting.writeCount('awsdocs.examSnapshot.v1:$examId'), 1);
  expect(counting.writeCount('awsdocs.examProgress.v1:$examId'),
      greaterThan(1));
});
```

**쓰기 횟수 계측 백엔드**는 이 테스트 파일에 둔다 — `MemoryBackend`를 상속해 `write`에서 키별 호출 수를 센다(`test/exam_view_test.dart`의 `_QuotaOnHistory`가 같은 상속 패턴의 선례다).

- [ ] **Step 2: 실패 확인** — Expected: FAIL
- [ ] **Step 3: `_load()`·저장 시점 구현** — 위 서술대로. 쓰기 실패는 잡아서 삼키되 시험은 계속한다(복원만 포기).
- [ ] **Step 4: 통과 확인** — Expected: PASS
- [ ] **Step 5: 커밋** — `feat(exam): ExamPage 스냅샷 복원 + 첫 상호작용 시 저장`

---

### Task 6: CertExamPage — 시작 시 스냅샷 + 게이트 순서

**Files:**
- Modify: `flutter_app/lib/pages/cert_exam_page.dart` (`_load` 46-160행, `_startFresh`, `_resume`, `_startScreen`)
- Modify: `flutter_app/test/cert_exam_restore_test.dart` (기존 4분기 — 복원 계약이 바뀐다)
- Test: 같은 파일

**Interfaces:**
- Consumes: Task 3·4의 전부
- Produces: 없음(페이지)

두 가지를 바꾼다. ① 시작 버튼에서 스냅샷을 1회 쓰고, 복원은 `loadRun`만 본다. ② **게이트 순서 재배치**(스펙 §4.3) — `loadRun`을 먼저 보고, capacity·약점 횟수 게이트는 **새 시험 시작 경로에만** 적용한다. 게이트 화면에도 진행 중 시험이 있으면 "이어서 풀기"를 띄운다.

기존 4분기 테스트는 `optionOrders`·ID 대조 기반이라 더 이상 성립하지 않는다 — 스냅샷 기준으로 다시 쓴다.

- [ ] **Step 1: 실패 테스트 작성**

```dart
testWidgets('⚠️ capacity가 not-ready로 뒤집혀도 진행 중 시험은 살아남는다', () async {
  // 스펙 §4.3 — 문항을 내리는 릴리스가 세션을 지우면 안 된다
  expect(find.text('이어서 풀기'), findsOneWidget);
});

testWidgets('새 시험 시작은 여전히 게이트에 막힌다', () async {
  expect(find.text('시작'), findsNothing);
});

testWidgets('시작 버튼이 스냅샷을 1회 쓴다', () async { /* loadSnapshot non-null */ });

testWidgets('⚠️ 스냅샷 문항이 현재 에셋과 달라도 그대로 출제된다', () async { /* 릴리스 가로지르기 */ });

testWidgets('구포맷 세션은 복원하지 않고 새 시험 시작', () async { /* §4.8 */ });

testWidgets('⚠️ 스냅샷 쓰기 실패해도 시험 시작이 막히지 않는다', () async { /* 반목표 */ });
```

- [ ] **Step 2: 실패 확인** — Run: `flutter test test/cert_exam_restore_test.dart` / Expected: FAIL
- [ ] **Step 3: `_load()` 순서 재배치 + 스냅샷 배선 구현**
- [ ] **Step 4: 통과 확인** — Expected: PASS
- [ ] **Step 5: 커밋** — `feat(exam): CertExamPage 스냅샷 복원 + 게이트는 새 시험에만`

---

### Task 7: 죽은 복원 체인 정리 + 기준선 갱신

**Files:**
- Modify: `flutter_app/lib/models/exam_session.dart` · `flutter_app/lib/data/mock_exam.dart`
- Modify: `flutter_app/test/exam_session_test.dart` · `flutter_app/test/mock_exam_test.dart`
- Modify: `CLAUDE.md` (기준선 수치 한 줄)

**Interfaces:**
- Consumes: Task 5·6 완료 후의 실제 호출처
- Produces: 없음

복원 경로에서 빠진 `bankFingerprint`·`restoreOrdered`·`ordersCoverQuestions`·`ExamSession.optionOrders`의 **잔존 호출처를 실측**(`grep -rn` 으로 `lib/`·`test/`)한 뒤 제거 여부를 판단한다. `examDurationSec`은 계속 쓰이므로 유지. 쓰이지 않게 된 것만 지우고, 지운 만큼 테스트도 정리한다.

- [ ] **Step 1: 잔존 호출처 실측**

Run: `cd flutter_app && grep -rn 'bankFingerprint\|restoreOrdered\|ordersCoverQuestions\|optionOrders' lib/ test/`
남은 참조를 표로 적고, 각각 유지/제거를 판단한다(판단 근거를 커밋 메시지에 남긴다).

- [ ] **Step 2: 제거 대상에 대해 실패 테스트 → 제거** — 쓰이지 않는 심볼은 테스트에서 먼저 지우고 `flutter analyze`가 미사용을 집게 한다.
- [ ] **Step 3: 전체 게이트**

Run: `cd flutter_app && flutter analyze && flutter test`
Expected: analyze `No issues found!` · 전부 통과

- [ ] **Step 4: 기준선 갱신** — `CLAUDE.md` 빌드·테스트 절의 테스트 수를 실측값으로 고친다(정본 한 곳).
- [ ] **Step 5: 웹 릴리스 빌드 확인**

Run(PowerShell): `cd flutter_app; flutter build web --release --base-href /aws-docs/`
Expected: `√ Built build\web`, `index.html`에 `<base href="/aws-docs/">`

- [ ] **Step 6: 커밋** — `refactor(exam): 스냅샷 도입으로 불필요해진 복원 검증 체인 정리`

---

## PR 분할

CLAUDE.md 절대 조건 6(최소 단위)에 따라 `develop` 대상 PR을 셋으로 나눈다.

| PR | Task | 라이브 영향 |
|---|---|---|
| PR1 모델·저장소 | 1·2·3 | 없음(새 코드, 호출처 없음) |
| PR2 배선 | 4·5·6 | **있음** — 복원 동작이 바뀐다 |
| PR3 정리 | 7 | 없음 |

PR2가 라이브에 닿으므로 릴리스 전 라이브 실측(index 200 + 학습문서 바이트 대조)을 붙인다.
