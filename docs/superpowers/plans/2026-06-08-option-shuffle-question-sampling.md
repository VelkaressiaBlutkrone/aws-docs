# 선택지 셔플 + 문항 랜덤 차출 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 정답 88.5% A-쏠림과 "연습=시험 동일 내용" 문제를 선택지 셔플 + 5문항 랜덤 차출로 해결한다.

**Architecture:** 데이터 계층 순수 변환 — `Question.withOptionOrder(order)`로 옵션·정답·오답해설을 함께 재매핑하고, 얇은 로더(QuizPage/ExamPage/CertExamPage/ReviewListPage)에서 차출·셔플을 적용한다. 시험 복원은 `ExamSession.optionOrders`(문항 ID → 표시 순서)를 명시 저장해 재현한다. 화면/채점/기록 파이프라인은 무수정.

**Tech Stack:** Flutter Web (Dart), flutter_test. 스펙: `docs/superpowers/specs/2026-06-08-option-shuffle-question-sampling-design.md`

**작업 디렉터리:** 모든 명령은 `flutter_app/`에서 실행 (`cd flutter_app`)

**스펙 대비 의도적 변경 1건:** 스펙 §3.1의 "assert + 원본 반환" 중 assert는 제외한다.
`flutter test`는 assert 활성 상태로 돌아 방어 경로가 테스트 불가능해지고, 손상된 localStorage
복원 시 디버그 크래시보다 "셔플 미적용 + 원본 유지"가 올바른 거동이기 때문. 방어적 원본 반환만 구현.

---

## 파일 구조

| 파일 | 작업 | 책임 |
|---|---|---|
| `lib/models/question.dart` | 수정 | `withOptionOrder` — 순서 적용(결정적, 순수) |
| `lib/data/mock_exam.dart` | 수정 | `taskSampleCount`·`samplePool`·`randomOptionOrders`·`applyOptionOrders`·`ordersCoverQuestions` — 차출·순서 생성(랜덤) |
| `lib/models/exam_session.dart` | 수정 | `optionOrders` 필드 + JSON 직렬화 |
| `lib/pages/exam_page.dart` | 수정 | ExamView 파라미터 2개 추가, ExamPage 로더에 차출+셔플+ID기반 복원 |
| `lib/pages/quiz_page.dart` | 수정 | StatefulWidget 전환(재샘플링 방지) + 차출+셔플 |
| `lib/pages/cert_exam_page.dart` | 수정 | fresh에 셔플 추가, resume에 순서 재적용 |
| `lib/pages/review_page.dart` | 수정 | 복습 큐 선택지 셔플 |
| `test/question_model_test.dart` | 수정 | withOptionOrder 단위 테스트 |
| `test/mock_exam_test.dart` | 수정 | 차출·순서 헬퍼 단위 테스트 + 분포 스모크 |
| `test/exam_session_test.dart` | 수정 | optionOrders 직렬화 왕복 |
| `test/exam_view_test.dart` | 수정 | 세션 기록(optionOrders·지문 주입) 위젯 테스트 |

---

### Task 1: `Question.withOptionOrder` — 순서 적용 순수 변환

**Files:**
- Modify: `flutter_app/lib/models/question.dart` (Question 클래스 끝, `fromJson` 뒤)
- Test: `flutter_app/test/question_model_test.dart`

- [ ] **Step 1: 실패하는 테스트 작성**

`test/question_model_test.dart`의 `main()` 끝에 추가:

```dart
  group('withOptionOrder', () {
    const q = Question(
      id: 'q1',
      examGuideTaskId: 't',
      stem: 's',
      options: ['A', 'B', 'C', 'D'],
      correct: 0,
      explanation: 'e',
      wrongExplanations: {1: 'w1', 3: 'w3'},
      sources: [],
      verified: true,
    );

    test('옵션·correct·wrongExplanations를 함께 재매핑한다', () {
      // order = 표시 순서대로 나열한 원본 인덱스: 표시0=원본2, 표시1=원본0 …
      final r = q.withOptionOrder([2, 0, 3, 1]);
      expect(r.options, ['C', 'A', 'D', 'B']);
      expect(r.correct, 1); // 원본 0번(A)이 표시 1번으로
      expect(r.options[r.correct], 'A'); // 정답 텍스트 보존
      expect(r.wrongExplanations, {3: 'w1', 2: 'w3'});
      expect(r.id, 'q1'); // 메타 보존
    });

    test('원본은 불변이다', () {
      q.withOptionOrder([3, 2, 1, 0]);
      expect(q.options, ['A', 'B', 'C', 'D']);
      expect(q.correct, 0);
      expect(q.wrongExplanations, {1: 'w1', 3: 'w3'});
    });

    test('잘못된 순열이면 원본을 그대로 반환한다(방어)', () {
      expect(identical(q.withOptionOrder([0, 0, 1, 2]), q), isTrue); // 중복
      expect(identical(q.withOptionOrder([0, 1, 2]), q), isTrue); // 길이
      expect(identical(q.withOptionOrder([0, 1, 2, 4]), q), isTrue); // 범위 밖
    });

    test('항등 순열은 동일 내용을 반환한다', () {
      final r = q.withOptionOrder([0, 1, 2, 3]);
      expect(r.options, q.options);
      expect(r.correct, q.correct);
    });
  });
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `cd flutter_app; flutter test test/question_model_test.dart`
Expected: FAIL — `The method 'withOptionOrder' isn't defined for the type 'Question'`

- [ ] **Step 3: 구현**

`lib/models/question.dart`의 `Question` 클래스 안, `fromJson` 팩토리 뒤에 추가:

```dart
  /// [order] = 표시 순서대로 나열한 원본 인덱스 순열(예: [2,0,3,1]).
  /// options 재배열 + correct 재매핑 + wrongExplanations 키 재매핑한 새 Question 반환.
  /// 유효하지 않은 순열(길이 불일치·중복·범위 밖)이면 원본을 그대로 반환한다
  /// — 손상된 복원 데이터로 답이 어긋나는 것보다 셔플 미적용이 안전(스펙 §3.1).
  Question withOptionOrder(List<int> order) {
    final n = options.length;
    final valid = order.length == n &&
        order.toSet().length == n &&
        order.every((i) => i >= 0 && i < n);
    if (!valid) return this;
    return Question(
      id: id,
      examGuideTaskId: examGuideTaskId,
      skill: skill,
      difficulty: difficulty,
      stem: stem,
      options: [for (final i in order) options[i]],
      correct: order.indexOf(correct),
      explanation: explanation,
      wrongExplanations: {
        for (final e in wrongExplanations.entries)
          if (order.contains(e.key)) order.indexOf(e.key): e.value,
      },
      sources: sources,
      verified: verified,
    );
  }
```

- [ ] **Step 4: 테스트 통과 확인**

Run: `cd flutter_app; flutter test test/question_model_test.dart`
Expected: PASS (전체)

- [ ] **Step 5: Commit**

```bash
git add flutter_app/lib/models/question.dart flutter_app/test/question_model_test.dart
git commit -m "feat: Question.withOptionOrder — 선택지 순서 적용 순수 변환"
```

---

### Task 2: 차출·순서 생성 헬퍼 (`mock_exam.dart`)

**Files:**
- Modify: `flutter_app/lib/data/mock_exam.dart` (파일 끝에 추가)
- Test: `flutter_app/test/mock_exam_test.dart`

- [ ] **Step 1: 실패하는 테스트 작성**

`test/mock_exam_test.dart`의 `main()` 끝에 추가 (`_q` 헬퍼는 파일 상단에 이미 존재 — options 4개, correct 0):

```dart
  test('samplePool: n < 풀이면 n개·중복 없음·풀 소속·결정적', () {
    final pool = [for (var i = 0; i < 9; i++) _q('q$i', 1)];
    final a = samplePool(pool, 5, Random(7));
    final b = samplePool(pool, 5, Random(7));
    expect(a.length, 5);
    expect(a.map((q) => q.id).toSet().length, 5);
    expect(a.every((q) => pool.any((p) => p.id == q.id)), isTrue);
    expect(a.map((q) => q.id).toList(), b.map((q) => q.id).toList()); // 결정적
  });

  test('samplePool: 풀 ≤ n이면 전부 반환', () {
    final pool = [for (var i = 0; i < 4; i++) _q('q$i', 1)];
    final r = samplePool(pool, taskSampleCount, Random(1));
    expect(r.map((q) => q.id).toSet(), {'q0', 'q1', 'q2', 'q3'});
  });

  test('randomOptionOrders: 문항별 유효 순열 생성', () {
    final pool = [for (var i = 0; i < 6; i++) _q('q$i', 1)];
    final orders = randomOptionOrders(pool, Random(3));
    expect(orders.length, 6);
    for (final q in pool) {
      expect(orders[q.id]!.toSet(), {0, 1, 2, 3}); // 완전한 순열
    }
  });

  test('applyOptionOrders: 정답 텍스트 보존, 순서 없는 문항은 그대로', () {
    final pool = [_q('a', 1), _q('b', 1)];
    final shuffled = applyOptionOrders(pool, {
      'a': [3, 2, 1, 0],
    });
    expect(shuffled[0].correct, 3); // 원본 0번이 표시 3번으로
    expect(shuffled[0].options[3], pool[0].options[0]); // 정답 텍스트 보존
    expect(identical(shuffled[1], pool[1]), isTrue); // 순서 없음 → 원본
  });

  test('ordersCoverQuestions: 누락·길이 불일치 감지', () {
    final pool = [_q('a', 1), _q('b', 1)];
    final ok = randomOptionOrders(pool, Random(1));
    expect(ordersCoverQuestions(pool, ok), isTrue);
    expect(ordersCoverQuestions(pool, {'a': ok['a']!}), isFalse); // b 누락
    expect(
        ordersCoverQuestions(pool, {'a': ok['a']!, 'b': const [0, 1]}),
        isFalse); // 길이 불일치
    expect(ordersCoverQuestions(pool, const {}), isFalse); // 구버전 세션
  });

  test('분포 스모크: 셔플 후 정답 위치가 단일 인덱스에 95% 이상 몰리지 않는다', () {
    // 현재 데이터의 A-쏠림 재현: 전부 correct=0인 130문항
    final pool = [for (var i = 0; i < 130; i++) _q('q$i', 1)];
    final shuffled =
        applyOptionOrders(pool, randomOptionOrders(pool, Random(5)));
    final dist = <int, int>{};
    for (final q in shuffled) {
      dist[q.correct] = (dist[q.correct] ?? 0) + 1;
    }
    expect(dist.values.every((c) => c < 130 * 0.95), isTrue);
    expect(dist.keys.length, greaterThan(1)); // 한 위치 독점 아님
  });
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `cd flutter_app; flutter test test/mock_exam_test.dart`
Expected: FAIL — `'samplePool' isn't defined` 등

- [ ] **Step 3: 구현**

`lib/data/mock_exam.dart` 파일 끝에 추가:

```dart
/// Task 연습/시험 차출 수(스펙 §2). 풀이 이보다 작으면 전부 출제.
const taskSampleCount = 5;

/// 풀에서 n개 무작위 차출. 풀 ≤ n이면 전부. 반환 순서도 섞인다. [rng] 주입으로 결정적.
List<Question> samplePool(List<Question> pool, int n, Random rng) {
  final copy = [...pool]..shuffle(rng);
  return n < copy.length ? copy.sublist(0, n) : copy;
}

/// 문항별 선택지 표시 순서를 무작위 생성(questionId → 원본 인덱스 순열).
/// 생성(랜덤)과 적용(applyOptionOrders, 결정적)을 분리 — 복원·테스트 용이(스펙 §3.1).
Map<String, List<int>> randomOptionOrders(
    Iterable<Question> questions, Random rng) {
  final out = <String, List<int>>{};
  for (final q in questions) {
    out[q.id] = [for (var i = 0; i < q.options.length; i++) i]..shuffle(rng);
  }
  return out;
}

/// 생성/저장된 표시 순서를 적용. 순서가 없는 문항은 그대로 둔다.
List<Question> applyOptionOrders(
        List<Question> questions, Map<String, List<int>> orders) =>
    [
      for (final q in questions)
        orders[q.id] == null ? q : q.withOptionOrder(orders[q.id]!)
    ];

/// 복원 전 검증: 모든 문항에 길이가 맞는 표시 순서가 있는가(스펙 §3.3).
/// 구버전 세션(optionOrders 없음)은 여기서 걸러져 새 시험으로 시작된다.
bool ordersCoverQuestions(
        List<Question> questions, Map<String, List<int>> orders) =>
    questions.every((q) => orders[q.id]?.length == q.options.length);
```

- [ ] **Step 4: 테스트 통과 확인**

Run: `cd flutter_app; flutter test test/mock_exam_test.dart`
Expected: PASS (전체)

- [ ] **Step 5: Commit**

```bash
git add flutter_app/lib/data/mock_exam.dart flutter_app/test/mock_exam_test.dart
git commit -m "feat: samplePool·randomOptionOrders·applyOptionOrders — 차출/셔플 순수 헬퍼"
```

---

### Task 3: `ExamSession.optionOrders` — 복원용 명시 저장

**Files:**
- Modify: `flutter_app/lib/models/exam_session.dart`
- Test: `flutter_app/test/exam_session_test.dart`

- [ ] **Step 1: 실패하는 테스트 작성**

`test/exam_session_test.dart`의 `main()` 끝에 추가:

```dart
  test('optionOrders 직렬화 왕복 + 구버전(필드 없음) 빈 맵', () {
    const s = ExamSession(
      examId: 'exam:clf-t2-3',
      certId: 'CLF-C02',
      taskId: 'clf-t2-3',
      startedAtIso: '2026-06-08T00:00:00.000',
      durationSec: 420,
      index: 0,
      picked: {},
      flagged: [],
      bankFingerprint: 'fp',
      submitted: false,
      questionIds: ['q1', 'q2'],
      optionOrders: {
        'q1': [2, 0, 3, 1],
        'q2': [1, 0],
      },
    );
    final back = ExamSession.fromJson(s.toJson());
    expect(back.optionOrders, {
      'q1': [2, 0, 3, 1],
      'q2': [1, 0],
    });
    // 구버전 JSON(optionOrders 없음) → 빈 맵
    final old = ExamSession.fromJson({'examId': 'x'});
    expect(old.optionOrders, isEmpty);
  });

  test('fromJson은 손상된 optionOrders 항목을 건너뛴다(방어적)', () {
    final back = ExamSession.fromJson({
      'examId': 'exam:x',
      'optionOrders': {
        'q1': [1, 0],
        'q2': 'broken', // 리스트 아님 → 스킵
      },
    });
    expect(back.optionOrders, {
      'q1': [1, 0],
    });
  });
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `cd flutter_app; flutter test test/exam_session_test.dart`
Expected: FAIL — `No named parameter with the name 'optionOrders'`

- [ ] **Step 3: 구현**

`lib/models/exam_session.dart` 수정 — 생성자에 파라미터 추가 (`questionIds` 줄 다음):

```dart
    this.questionIds = const [],
    this.optionOrders = const {},
```

필드 선언 추가 (`questionIds` 필드 다음):

```dart
  final List<String> questionIds; // 통합 모의고사 출제 문항 ID(순서) — 복원용
  final Map<String, List<int>> optionOrders; // 문항 ID → 선택지 표시 순서(원본 인덱스 순열) — 셔플 복원용(스펙 §3.3)
```

`toJson()`에 추가 (`'questionIds': questionIds,` 줄 다음):

```dart
        'optionOrders': optionOrders,
```

`fromJson`에 파싱 추가 (`picked` 파싱 블록 다음, return 전):

```dart
    final orders = <String, List<int>>{};
    final rawO = j['optionOrders'];
    if (rawO is Map) {
      rawO.forEach((k, v) {
        if (v is List) {
          orders[k.toString()] =
              v.whereType<num>().map((e) => e.toInt()).toList();
        }
      });
    }
```

return의 `questionIds:` 다음에:

```dart
      optionOrders: orders,
```

- [ ] **Step 4: 테스트 통과 확인**

Run: `cd flutter_app; flutter test test/exam_session_test.dart`
Expected: PASS (전체)

- [ ] **Step 5: Commit**

```bash
git add flutter_app/lib/models/exam_session.dart flutter_app/test/exam_session_test.dart
git commit -m "feat: ExamSession.optionOrders — 선택지 순서 명시 저장(복원용)"
```

---

### Task 4: ExamView 파라미터 — `optionOrders` 기록 + 지문 주입

**Files:**
- Modify: `flutter_app/lib/pages/exam_page.dart` (ExamView 클래스, 18-114행 부근)
- Test: `flutter_app/test/exam_view_test.dart`

- [ ] **Step 1: 실패하는 테스트 작성**

`test/exam_view_test.dart`의 `main()` 끝에 추가 (`_bank()`·`_host()` 헬퍼는 파일 상단에 존재, 문항 q1·q2는 옵션 2개):

```dart
  testWidgets('세션에 optionOrders와 주입된 전체 뱅크 지문이 기록된다', (tester) async {
    ExamSession? saved;
    final started = DateTime(2026, 6, 8);
    await tester.pumpWidget(_host(ExamView(
      bank: _bank(),
      certId: 'CLF-C02',
      taskId: 'clf-t2-3',
      startedAt: started,
      durationSec: 600,
      optionOrders: const {
        'q1': [1, 0],
        'q2': [0, 1],
      },
      sessionFingerprint: 'fp-full-bank',
      now: () => started.add(const Duration(seconds: 5)),
      onChanged: (s) => saved = s,
    )));
    await tester.pump();

    await tester.tap(find.text('계정 해지')); // 선택 → onChanged 발화
    await tester.pump();

    expect(saved, isNotNull);
    expect(saved!.optionOrders, {
      'q1': [1, 0],
      'q2': [0, 1],
    });
    expect(saved!.bankFingerprint, 'fp-full-bank'); // 주입 지문 우선
  });
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `cd flutter_app; flutter test test/exam_view_test.dart`
Expected: FAIL — `No named parameter with the name 'optionOrders'`

- [ ] **Step 3: 구현**

`lib/pages/exam_page.dart`의 `ExamView` 생성자에 파라미터 추가 (`this.restored = false,` 다음):

```dart
    this.optionOrders = const {},
    this.sessionFingerprint,
```

필드 추가 (`final bool restored;` 다음):

```dart
  /// 세션에 기록할 문항별 선택지 표시 순서(복원용). 셔플 미적용 호출부는 빈 맵.
  final Map<String, List<int>> optionOrders;

  /// 세션에 기록할 뱅크 지문. null이면 표시 뱅크에서 계산.
  /// 차출 시험은 표시 뱅크(5문항)가 아니라 전체 뱅크 지문으로 개정을 감지해야 하므로 주입한다.
  final String? sessionFingerprint;
```

`_ExamViewState._session()`의 `bankFingerprint:`와 `questionIds:` 줄을 다음으로 교체:

```dart
        bankFingerprint:
            widget.sessionFingerprint ?? bankFingerprint(widget.bank),
        questionIds: _qs.map((q) => q.id).toList(),
        optionOrders: widget.optionOrders,
```

- [ ] **Step 4: 테스트 통과 확인**

Run: `cd flutter_app; flutter test test/exam_view_test.dart`
Expected: PASS (기존 5개 + 신규 1개)

- [ ] **Step 5: Commit**

```bash
git add flutter_app/lib/pages/exam_page.dart flutter_app/test/exam_view_test.dart
git commit -m "feat: ExamView optionOrders·sessionFingerprint — 셔플 세션 기록 지원"
```

---

### Task 5: ExamPage 로더 — 차출+셔플+ID 기반 복원

**Files:**
- Modify: `flutter_app/lib/pages/exam_page.dart` (ExamPage `_load()` 442-499행, ExamView 호출부 535행 부근, `_ExamLoad` 560-577행, import)

위젯 테스트 없음(로더는 rootBundle 자산 의존 — 기존 패턴상 ExamPage 로더는 직접 테스트하지 않고
순수 로직은 Task 1-3 테스트가, 동작은 Task 9 수동 스모크가 커버).

- [ ] **Step 1: import 추가**

파일 상단 import에 추가 (`import 'dart:convert';` 다음):

```dart
import 'dart:math';
```

상대 import 블록에 추가 (`import '../data/history_store.dart';` 다음):

```dart
import '../data/mock_exam.dart';
```

- [ ] **Step 2: `_load()` 본문 교체**

`_ExamPageState._load()` 전체를 다음으로 교체:

```dart
  Future<_ExamLoad> _load() async {
    final qRaw = await rootBundle.loadString(widget.entry.questionsAsset);
    final fullBank =
        QuestionBank.fromJson(json.decode(qRaw) as Map<String, dynamic>);

    ExamOverview? overview;
    try {
      final gRaw = await rootBundle
          .loadString('assets/exam_guides/${widget.entry.certCode}.json');
      overview =
          ExamGuide.fromJson(json.decode(gRaw) as Map<String, dynamic>).overview;
    } catch (_) {
      overview = null; // 메타 없으면 폴백 페이스(examDurationSec)
    }

    final examId = _examId;
    final fp = bankFingerprint(fullBank);
    final existing = _store.load(examId);

    // 복원 조건: 미제출 + 전체 뱅크 지문 일치 + 차출 ID 전부 존재 + 선택지 순서 완비(스펙 §3.3).
    // 구버전 세션(optionOrders 없음)은 ordersCoverQuestions에서 걸러져 새 시험으로 시작.
    List<Question>? restoredQs;
    if (existing != null &&
        !existing.submitted &&
        existing.bankFingerprint == fp) {
      final ordered =
          restoreOrdered(existing.questionIds, indexById(fullBank.questions));
      if (ordered != null &&
          ordersCoverQuestions(ordered, existing.optionOrders)) {
        restoredQs = applyOptionOrders(ordered, existing.optionOrders);
      }
    }

    final DateTime startedAt;
    final int durationSec;
    final int initialIndex;
    final Map<int, int> initialPicked;
    final Set<int> initialFlagged;
    final List<Question> presented;
    final Map<String, List<int>> optionOrders;
    if (restoredQs != null) {
      presented = restoredQs;
      optionOrders = existing!.optionOrders;
      // 손상된 startedAt이면 now로 폴백(타이머 리셋 가능 — 정상 흐름에선 항상 기록됨).
      startedAt = DateTime.tryParse(existing.startedAtIso) ?? DateTime.now();
      durationSec = existing.durationSec;
      initialIndex = existing.index;
      initialPicked = existing.picked;
      initialFlagged = existing.flagged.toSet();
    } else {
      if (existing != null) _store.clear(examId); // 개정/제출/구버전 세션 폐기
      final rng = Random();
      final sampled = samplePool(fullBank.questions, taskSampleCount, rng);
      optionOrders = randomOptionOrders(sampled, rng);
      presented = applyOptionOrders(sampled, optionOrders);
      startedAt = DateTime.now();
      durationSec = examDurationSec(
        durationMinutes: overview?.durationMinutes,
        scored: overview?.scoredQuestions,
        unscored: overview?.unscoredQuestions,
        count: presented.length, // 차출 수 기준 — 시간 자동 단축
      );
      initialIndex = 0;
      initialPicked = const {};
      initialFlagged = const {};
    }

    return _ExamLoad(
      bank: QuestionBank(
        examGuideTaskId: fullBank.examGuideTaskId,
        taskTitle: fullBank.taskTitle,
        certCode: fullBank.certCode,
        domain: fullBank.domain,
        questions: presented,
      ),
      fullBankFingerprint: fp,
      optionOrders: optionOrders,
      startedAt: startedAt,
      durationSec: durationSec,
      initialIndex: initialIndex,
      initialPicked: initialPicked,
      initialFlagged: initialFlagged,
      restored: restoredQs != null,
    );
  }
```

- [ ] **Step 3: `_ExamLoad` 확장**

`_ExamLoad` 클래스(파일 끝)를 다음으로 교체:

```dart
/// 로드 결과(표시 뱅크 = 차출+셔플 적용 / 지문·순서는 세션 기록용).
class _ExamLoad {
  const _ExamLoad({
    required this.bank,
    required this.fullBankFingerprint,
    required this.optionOrders,
    required this.startedAt,
    required this.durationSec,
    required this.initialIndex,
    required this.initialPicked,
    required this.initialFlagged,
    required this.restored,
  });
  final QuestionBank bank;
  final String fullBankFingerprint;
  final Map<String, List<int>> optionOrders;
  final DateTime startedAt;
  final int durationSec;
  final int initialIndex;
  final Map<int, int> initialPicked;
  final Set<int> initialFlagged;
  final bool restored;
}
```

- [ ] **Step 4: ExamView 호출부에 신규 파라미터 전달**

`_ExamPageState.build()`의 `ExamView(` 호출에서 `restored: data.restored,` 다음에 추가:

```dart
                optionOrders: data.optionOrders,
                sessionFingerprint: data.fullBankFingerprint,
```

- [ ] **Step 5: 분석·전체 테스트**

Run: `cd flutter_app; flutter analyze; flutter test`
Expected: analyze 이슈 0, 테스트 전체 PASS

- [ ] **Step 6: Commit**

```bash
git add flutter_app/lib/pages/exam_page.dart
git commit -m "feat: Task 시험 5문항 차출+선택지 셔플, ID 기반 세션 복원"
```

---

### Task 6: QuizPage — StatefulWidget 전환 + 차출+셔플

**Files:**
- Modify: `flutter_app/lib/pages/quiz_page.dart` (QuizPage 클래스 14-68행, import)

**중요:** 현재 QuizPage는 StatelessWidget이고 `FutureBuilder(future: _load())`로 빌드마다 새
Future를 만든다. 지금은 결과가 항상 같아 무해하지만, 랜덤 차출 도입 후엔 리빌드(테마 전환 등)
시 풀이 중 문항이 바뀌는 버그가 된다. `late final Future`를 갖는 StatefulWidget으로 전환한다.

- [ ] **Step 1: import 추가**

`import 'dart:convert';` 다음에:

```dart
import 'dart:math';
```

`import '../data/history_store.dart';` 다음에:

```dart
import '../data/mock_exam.dart';
```

- [ ] **Step 2: QuizPage 클래스 교체**

`QuizPage` 클래스 전체(StatelessWidget, 14-68행)를 다음으로 교체 (`QuizView` 이하는 무변경):

```dart
/// 얇은 로더: 자산에서 QuestionBank를 읽어 5문항 차출+선택지 셔플 후 QuizView에 주입.
class QuizPage extends StatefulWidget {
  const QuizPage({super.key, required this.entry});
  final ContentEntry entry;

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  // late final: 리빌드 시 재샘플링 방지 — 풀이 중 문항이 바뀌면 안 된다.
  late final Future<QuestionBank> _future = _load();

  Future<QuestionBank> _load() async {
    final raw = await rootBundle.loadString(widget.entry.questionsAsset);
    final bank =
        QuestionBank.fromJson(json.decode(raw) as Map<String, dynamic>);
    final rng = Random();
    final sampled = samplePool(bank.questions, taskSampleCount, rng);
    final shuffled =
        applyOptionOrders(sampled, randomOptionOrders(sampled, rng));
    return QuestionBank(
      examGuideTaskId: bank.examGuideTaskId,
      taskTitle: bank.taskTitle,
      certCode: bank.certCode,
      domain: bank.domain,
      questions: shuffled,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: Border(bottom: BorderSide(color: c.border)),
        title: Text('${widget.entry.title} · 연습 문제',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      body: FutureBuilder<QuestionBank>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
                child: Text('문항을 불러오지 못했습니다.',
                    style: TextStyle(color: c.textMuted)));
          }
          final bank = snap.data;
          if (bank == null || bank.questions.isEmpty) {
            return Center(
                child: Text('검증된 연습 문제가 아직 없습니다.',
                    style: TextStyle(color: c.textMuted)));
          }
          final store = HistoryStore();
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: Layout.exam),
              child: QuizView(
                bank: bank,
                certId: widget.entry.certForHistory,
                onFinished: store.add,
              ),
            ),
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 3: 분석·전체 테스트**

Run: `cd flutter_app; flutter analyze; flutter test`
Expected: analyze 이슈 0, 테스트 전체 PASS

- [ ] **Step 4: Commit**

```bash
git add flutter_app/lib/pages/quiz_page.dart
git commit -m "feat: Task 연습 5문항 차출+선택지 셔플 (StatefulWidget 전환으로 재샘플링 방지)"
```

---

### Task 7: CertExamPage — fresh 셔플 + resume 순서 재적용

**Files:**
- Modify: `flutter_app/lib/pages/cert_exam_page.dart` (`_load()` 95-105행, `_startFresh` 121-144행, `_examView` 183-213행, `_RunParams` 335-357행)

- [ ] **Step 1: `_load()` 복원 블록 교체**

95-105행의 복원 블록을 다음으로 교체:

```dart
    // 복원 가능한 진행 세션? — 문항 ID 복원 + 선택지 순서 완비 검증(스펙 §3.3)
    final existing = _store.load(_examId);
    _Restorable? restorable;
    if (existing != null && !existing.submitted) {
      final restored = restoreOrdered(existing.questionIds, byId);
      if (restored == null ||
          !ordersCoverQuestions(restored, existing.optionOrders)) {
        _store.clear(_examId); // 개정/불일치/구버전 폐기
      } else {
        restorable = _Restorable(
            existing, applyOptionOrders(restored, existing.optionOrders));
      }
    }
```

- [ ] **Step 2: `_startFresh` 교체**

```dart
  void _startFresh(_MockLoad d) {
    _store.clear(_examId);
    final rng = Random();
    final sampled = widget.weighted
        ? buildSampledExam<String>(
            poolByKey: d.taskPool,
            weightByKey: d.taskWeights,
            n: _targetN(d.overview),
            rng: rng,
          )
        : buildMockExam(
            poolByDomain: d.pool,
            weightByDomain: d.weights,
            n: _targetN(d.overview),
            rng: rng,
          );
    final orders = randomOptionOrders(sampled, rng); // 선택지 셔플(스펙 §3.2)
    final questions = applyOptionOrders(sampled, orders);
    final startedAt = DateTime.now();
    final durationSec = examDurationSec(
      durationMinutes: d.overview?.durationMinutes,
      scored: d.overview?.scoredQuestions,
      unscored: d.overview?.unscoredQuestions,
      count: questions.length,
    );
    setState(() =>
        _running = _RunParams.fresh(questions, orders, startedAt, durationSec));
  }
```

- [ ] **Step 3: `_RunParams`에 optionOrders 추가**

`_RunParams` 클래스를 다음으로 교체:

```dart
/// ExamView에 주입할 실행 파라미터(새 시험 / 복원).
class _RunParams {
  final List<Question> questions;
  final Map<String, List<int>> optionOrders;
  final DateTime startedAt;
  final int durationSec;
  final int index;
  final Map<int, int> picked;
  final Set<int> flagged;
  final bool restored;

  _RunParams.fresh(
      this.questions, this.optionOrders, this.startedAt, this.durationSec)
      : index = 0,
        picked = const <int, int>{},
        flagged = const <int>{},
        restored = false;

  _RunParams.restored(ExamSession s, this.questions)
      : optionOrders = s.optionOrders,
        startedAt = DateTime.tryParse(s.startedAtIso) ?? DateTime.now(),
        durationSec = s.durationSec,
        index = s.index,
        picked = s.picked,
        flagged = s.flagged.toSet(),
        restored = true;
}
```

- [ ] **Step 4: `_examView`에 optionOrders 전달**

`ExamView(` 호출에서 `restored: r.restored,` 다음에 추가:

```dart
          optionOrders: r.optionOrders,
```

(통합 모의고사 복원은 지문 검사를 쓰지 않으므로 `sessionFingerprint`는 전달하지 않음 — null이면
기존처럼 표시 뱅크에서 계산되고, 복원은 `restoreOrdered` ID 검증이 담당. 기존 동작 유지.)

- [ ] **Step 5: 분석·전체 테스트**

Run: `cd flutter_app; flutter analyze; flutter test`
Expected: analyze 이슈 0, 테스트 전체 PASS

- [ ] **Step 6: Commit**

```bash
git add flutter_app/lib/pages/cert_exam_page.dart
git commit -m "feat: 통합/약점 모의고사 선택지 셔플 + 복원 시 순서 재적용"
```

---

### Task 8: ReviewListPage — 복습 큐 선택지 셔플

**Files:**
- Modify: `flutter_app/lib/pages/review_page.dart` (`_startTask` 65-72행, import)

- [ ] **Step 1: import 추가**

`import 'dart:convert';` 다음에:

```dart
import 'dart:math';
```

`import '../data/history_store.dart';` 다음에:

```dart
import '../data/mock_exam.dart';
```

- [ ] **Step 2: `_startTask` 교체**

```dart
  void _startTask(_ReviewLoad d, String taskId) {
    final queue = [
      for (final e in d.index.weakEntries(taskId))
        if (d.byId[e.questionId] != null) d.byId[e.questionId]!,
    ];
    if (queue.isEmpty) return;
    final rng = Random();
    // 차출 없이 weak 전부 + 선택지만 셔플(스펙 §3.2). 세션 저장 없음 → 매 회차 자유 셔플.
    final shuffled = applyOptionOrders(queue, randomOptionOrders(queue, rng));
    setState(() => _running = _ReviewRun(taskId, shuffled));
  }
```

- [ ] **Step 3: 분석·전체 테스트**

Run: `cd flutter_app; flutter analyze; flutter test`
Expected: analyze 이슈 0, 테스트 전체 PASS

- [ ] **Step 4: Commit**

```bash
git add flutter_app/lib/pages/review_page.dart
git commit -m "feat: 오답노트 복습 선택지 셔플"
```

---

### Task 9: 최종 검증 — 분석·전체 테스트·수동 스모크

**Files:** 없음 (검증만)

- [ ] **Step 1: 정적 분석 + 전체 테스트**

Run: `cd flutter_app; flutter analyze; flutter test`
Expected: `No issues found!` + 전체 테스트 PASS (기존 78개 + 신규 ~10개)

- [ ] **Step 2: 수동 스모크 (Chrome)**

Run: `cd flutter_app; flutter run -d chrome`

체크리스트:
1. CLF 자격증 → 아무 Task → **연습 문제**: 5문항만 출제되는가, 정답 위치가 다양한가,
   "왜 아닌가" 오답해설이 고른 보기와 맞는가
2. 같은 Task 연습을 다시 진입: 문항 조합/순서가 달라지는가
3. **시험 모드**: 5문항·제한시간 ~7분(84s×5)인가 → 2문항 풀고 **새로고침** →
   "이전 진행을 복원했습니다" + 같은 문항·같은 보기 순서·답 보존되는가
4. **통합 모의고사**: 시작 → 보기 순서가 셔플되어 있는가 → 새로고침 복원 동일성
5. **오답노트**: 일부러 틀린 뒤 복습 진입 → 보기 순서 셔플 확인
6. 결과 화면: 점수·해설·오답 표기가 고른 보기와 일치하는가

- [ ] **Step 3: README 학습 루프 설명 확인**

`README.md`의 기능 설명은 출제 방식 상세를 다루지 않으므로 무변경. 단, 확인 차 검토.

- [ ] **Step 4: Commit (잔여 변경이 있을 때만)**

```bash
git status --short
# 변경 없으면 커밋 생략
```

---

## Self-Review 결과

- **스펙 커버리지:** §3.1 withOptionOrder → Task 1 / §3.2 samplePool·적용표 4행(연습·시험·모의고사·오답노트) → Task 2·5·6·7·8 / §3.3 optionOrders·복원 통일·구버전 폐기 → Task 3·4·5·7 / §3.4 데이터 흐름 → Task 5 / §4 테스트 1-5 → Task 1·2·3·4(+분포 스모크는 Task 2)
- **타입 일관성:** `optionOrders: Map<String, List<int>>`, `samplePool(List<Question>, int, Random)`, `withOptionOrder(List<int>)` — 전 Task 동일 시그니처 확인
- **의도적 스펙 변경:** assert 제외(문서 상단 명기)
