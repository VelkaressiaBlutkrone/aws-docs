# E1 오답노트 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.
>
> **커밋 주의:** 이 프로젝트는 "커밋은 사용자가 요청할 때만" 규칙을 따릅니다. 각 Task의 커밋 스텝은 사용자가 커밋을 승인했을 때만 실행하세요. 미승인 시 변경만 남기고 다음 Task로 진행.

**Goal:** 응시 이력의 오답을 cert별로 모아 연습형으로 재응시하고, 같은 문항을 연속 2회 맞히면 노트에서 졸업시키는 "오답노트" 기능(E1)을 구현한다.

**Architecture:** `AttemptRecord`에 `presentedQuestionIds`를 추가해 append-only 로그를 단일 진실 공급원으로 유지. 순수 모듈 `WrongAnswerIndex`가 로그에서 문항별 약점/마스터 상태를 파생. UI는 기존 `QuizView`를 `mode` 파라미터로 재사용(별도 러너 위젯 없음)하고, cert 상세 페이지에서 진입.

**Tech Stack:** Flutter Web (Dart 3.10), `flutter_test`, localStorage 백엔드(`KvBackend`), 기존 `quiz_widgets`·테마 토큰.

작업 디렉터리: 모든 경로는 `aws-docs/flutter_app/` 기준. 명령은 그 디렉터리에서 PowerShell로 실행.

---

## File Structure

**생성:**
- `lib/data/wrong_answer_index.dart` — 순수 집계(약점/마스터 파생). 의존: `attempt_record.dart`만.
- `lib/data/review_loader.dart` — 비동기 글루(뱅크+이력 로드 → 인덱스). 의존: rootBundle·content_index·history_store·question·wrong_answer_index.
- `lib/pages/review_page.dart` — `ReviewListPage`(cert별 오답 목록) + 내부 복습 러너 호스트. 의존: review_loader·quiz_page(QuizView)·quiz_widgets·theme.
- `test/wrong_answer_index_test.dart` — 순수 단위 테스트.
- `test/review_page_test.dart` — 위젯 테스트(빈 상태·약점 목록).

**수정:**
- `lib/models/attempt_record.dart` — `presentedQuestionIds` 필드 추가(하위호환).
- `lib/pages/quiz_page.dart` — `QuizView`에 `mode` 파라미터 + `presentedQuestionIds` 기록.
- `lib/pages/exam_page.dart` — `ExamView._submit`에 `presentedQuestionIds` 기록.
- `lib/pages/cert_detail_page.dart` — Task별 "오답 N" 배지 + "오답노트" 진입.
- `test/quiz_view_test.dart` — `presentedQuestionIds`·`mode:'review'` 단언 추가.
- `test/exam_view_test.dart` — `presentedQuestionIds` 단언 추가.

---

## Task 1: AttemptRecord에 presentedQuestionIds 추가

**Files:**
- Modify: `lib/models/attempt_record.dart`
- Test: `test/attempt_record_test.dart` (create)

- [ ] **Step 1: 실패 테스트 작성**

Create `test/attempt_record_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/models/attempt_record.dart';

void main() {
  test('presentedQuestionIds 왕복 + 레거시(필드 없음) 기본값 []', () {
    const r = AttemptRecord(
      certId: 'CLF-C02',
      examId: 'practice:clf-t1-1',
      mode: 'practice',
      date: '2026-06-06T00:00:00.000',
      correct: 1,
      total: 2,
      wrongQuestionIds: ['clf-t1-1-q2'],
      flaggedQuestionIds: [],
      durationSpentSec: 30,
      presentedQuestionIds: ['clf-t1-1-q1', 'clf-t1-1-q2'],
    );
    final round = AttemptRecord.fromJson(r.toJson());
    expect(round.presentedQuestionIds, ['clf-t1-1-q1', 'clf-t1-1-q2']);

    // 레거시: presentedQuestionIds 키가 없는 JSON
    final legacy = AttemptRecord.fromJson({
      'certId': 'CLF-C02',
      'examId': 'practice:clf-t1-1',
      'mode': 'practice',
      'date': '2026-06-06T00:00:00.000',
      'correct': 1,
      'total': 2,
      'wrongQuestionIds': ['clf-t1-1-q2'],
      'flaggedQuestionIds': <String>[],
      'durationSpentSec': 30,
    });
    expect(legacy.presentedQuestionIds, isEmpty);
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `flutter test test/attempt_record_test.dart`
Expected: FAIL (`presentedQuestionIds` 명명 인자/게터 없음 → 컴파일 에러).

- [ ] **Step 3: 최소 구현**

`lib/models/attempt_record.dart`에서 생성자에 필드 추가(`durationSpentSec` 다음):

```dart
    required this.durationSpentSec,
    this.presentedQuestionIds = const [],
  });
```

필드 선언 추가(`durationSpentSec` 선언 다음):

```dart
  final int durationSpentSec;
  final List<String> presentedQuestionIds; // 그 응시에 출제된 전체 문항 ID(파생용)
```

`toJson()` 맵에 추가(`durationSpentSec` 항목 다음):

```dart
        'durationSpentSec': durationSpentSec,
        'presentedQuestionIds': presentedQuestionIds,
      };
```

`fromJson`에 파싱 추가(`durationSpentSec` 줄 다음, 닫는 `);` 전):

```dart
        durationSpentSec: (j['durationSpentSec'] as num?)?.toInt() ?? 0,
        presentedQuestionIds: ((j['presentedQuestionIds'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
      );
```

- [ ] **Step 4: 테스트 통과 확인**

Run: `flutter test test/attempt_record_test.dart`
Expected: PASS.

- [ ] **Step 5: 회귀 확인**

Run: `flutter test`
Expected: 기존 21개 + 신규 1개 모두 PASS(추가 필드는 가산·하위호환).

- [ ] **Step 6: 커밋(사용자 승인 시)**

```bash
git add lib/models/attempt_record.dart test/attempt_record_test.dart
git commit -m "feat(history): AttemptRecord에 presentedQuestionIds 추가(하위호환)"
```

---

## Task 2: QuizView에 mode 파라미터 + presentedQuestionIds 기록

QuizView를 연습/복습 양쪽에 재사용한다(`mode` 기본값 'practice'). examId 접두사와 AttemptRecord.mode가 `mode`를 따른다.

**Files:**
- Modify: `lib/pages/quiz_page.dart`
- Test: `test/quiz_view_test.dart`

- [ ] **Step 1: 실패 테스트 추가**

`test/quiz_view_test.dart`에 새 테스트 추가(기존 `main()` 안, 기존 테스트 뒤). 기존 파일의 import·헬퍼(QuestionBank 생성 등)를 그대로 사용한다. 두 문항 뱅크를 만들고 1번 정답·2번 오답으로 끝내 기록을 검사:

```dart
  testWidgets('mode:review 응시는 examId/ mode/ presentedQuestionIds를 기록한다',
      (tester) async {
    final bank = QuestionBank(
      examGuideTaskId: 'clf-t1-1',
      taskTitle: 't',
      certCode: 'CLF-C02',
      domain: 1,
      questions: const [
        Question(
          id: 'clf-t1-1-q1',
          examGuideTaskId: 'clf-t1-1',
          stem: 'Q1',
          options: ['a', 'b'],
          correct: 0,
          explanation: 'e',
          wrongExplanations: {},
          sources: [],
          verified: true,
        ),
        Question(
          id: 'clf-t1-1-q2',
          examGuideTaskId: 'clf-t1-1',
          stem: 'Q2',
          options: ['a', 'b'],
          correct: 0,
          explanation: 'e',
          wrongExplanations: {},
          sources: [],
          verified: true,
        ),
      ],
    );
    AttemptRecord? rec;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: QuizView(
          bank: bank,
          certId: 'CLF-C02',
          mode: 'review',
          onFinished: (r) => rec = r,
        ),
      ),
    ));

    // Q1: 정답(a=index0) 선택 → 확인 → 다음
    await tester.tap(find.text('a').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    // Q2: 오답(b=index1) 선택 → 확인 → 결과 보기
    await tester.tap(find.text('b').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('결과 보기'));
    await tester.pumpAndSettle();

    expect(rec, isNotNull);
    expect(rec!.mode, 'review');
    expect(rec!.examId, 'review:clf-t1-1');
    expect(rec!.presentedQuestionIds, ['clf-t1-1-q1', 'clf-t1-1-q2']);
    expect(rec!.wrongQuestionIds, ['clf-t1-1-q2']);
  });
```

필요한 import가 없으면 추가: `import 'package:aws_docs/models/attempt_record.dart';`, `import 'package:aws_docs/models/question.dart';`, `import 'package:aws_docs/theme/app_theme.dart';`.

- [ ] **Step 2: 테스트 실패 확인**

Run: `flutter test test/quiz_view_test.dart`
Expected: FAIL (`mode` 명명 인자 없음 → 컴파일 에러).

- [ ] **Step 3: 최소 구현**

`lib/pages/quiz_page.dart`의 `QuizView` 생성자에 `mode` 추가:

```dart
  const QuizView({
    super.key,
    required this.bank,
    required this.certId,
    this.mode = 'practice',
    this.onFinished,
  });

  final QuestionBank bank;
  final String certId;
  final String mode;
  final void Function(AttemptRecord)? onFinished;
```

`_QuizViewState._finish()`의 `AttemptRecord` 생성을 교체:

```dart
    widget.onFinished?.call(AttemptRecord(
      certId: widget.certId,
      examId: '${widget.mode}:${widget.bank.examGuideTaskId}',
      mode: widget.mode,
      date: DateTime.now().toIso8601String(),
      correct: correct,
      total: _qs.length,
      wrongQuestionIds: wrong,
      flaggedQuestionIds: const [],
      durationSpentSec: DateTime.now().difference(_startedAt).inSeconds,
      presentedQuestionIds: _qs.map((q) => q.id).toList(),
    ));
```

- [ ] **Step 4: 테스트 통과 확인**

Run: `flutter test test/quiz_view_test.dart`
Expected: PASS(기존 practice 테스트 + 신규 review 테스트).

- [ ] **Step 5: 커밋(사용자 승인 시)**

```bash
git add lib/pages/quiz_page.dart test/quiz_view_test.dart
git commit -m "feat(quiz): QuizView mode 파라미터 + presentedQuestionIds 기록(복습 재사용)"
```

---

## Task 3: ExamView에 presentedQuestionIds 기록

**Files:**
- Modify: `lib/pages/exam_page.dart`
- Test: `test/exam_view_test.dart`

- [ ] **Step 1: 실패 단언 추가**

`test/exam_view_test.dart`의 기존 "정답 선택 후 제출 → 채점" 테스트에서, `onFinished`로 받은 레코드를 검사하는 부분에 단언을 추가한다. 기록 변수를 `AttemptRecord? rec;`로 캡처하고 제출 후:

```dart
    expect(rec!.presentedQuestionIds, isNotEmpty);
    expect(rec!.presentedQuestionIds.length, rec!.total);
```

(기존 테스트가 이미 onFinished 레코드를 변수로 받고 있으면 그 변수를 사용. 없으면 `onFinished: (r) => rec = r`로 연결.)

- [ ] **Step 2: 테스트 실패 확인**

Run: `flutter test test/exam_view_test.dart`
Expected: FAIL (`presentedQuestionIds`가 비어 있음 → 단언 실패).

- [ ] **Step 3: 최소 구현**

`lib/pages/exam_page.dart`의 `_ExamViewState._submit()`에서 `AttemptRecord` 생성에 한 줄 추가(`durationSpentSec` 항목 다음):

```dart
      durationSpentSec: spent > widget.durationSec ? widget.durationSec : spent,
      presentedQuestionIds: _qs.map((q) => q.id).toList(),
    ));
```

- [ ] **Step 4: 테스트 통과 확인**

Run: `flutter test test/exam_view_test.dart`
Expected: PASS.

- [ ] **Step 5: 커밋(사용자 승인 시)**

```bash
git add lib/pages/exam_page.dart test/exam_view_test.dart
git commit -m "feat(exam): ExamView가 presentedQuestionIds 기록"
```

---

## Task 4: WrongAnswerIndex 순수 모듈 + WrongEntry

**Files:**
- Create: `lib/data/wrong_answer_index.dart`
- Test: `test/wrong_answer_index_test.dart`

- [ ] **Step 1: 실패 테스트 작성**

Create `test/wrong_answer_index_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/models/attempt_record.dart';
import 'package:aws_docs/data/wrong_answer_index.dart';

AttemptRecord _a(String examId, List<String> presented, List<String> wrong,
        {String date = '2026-06-06T00:00:00.000'}) =>
    AttemptRecord(
      certId: 'CLF-C02',
      examId: examId,
      mode: examId.split(':').first,
      date: date,
      correct: presented.length - wrong.length,
      total: presented.length,
      wrongQuestionIds: wrong,
      flaggedQuestionIds: const [],
      durationSpentSec: 0,
      presentedQuestionIds: presented,
    );

const _taskBank = {
  'clf-t1-1': ['clf-t1-1-q1', 'clf-t1-1-q2'],
};
const _taskCert = {'clf-t1-1': 'CLF-C02'};

void main() {
  test('한 번 틀리면 weak, 미졸업', () {
    final idx = WrongAnswerIndex.build(
      attempts: [
        _a('practice:clf-t1-1', ['clf-t1-1-q1', 'clf-t1-1-q2'], ['clf-t1-1-q1']),
      ],
      taskBank: _taskBank,
      taskCert: _taskCert,
    );
    final weak = idx.weakFor('CLF-C02');
    expect(weak.map((e) => e.questionId), ['clf-t1-1-q1']);
    expect(weak.single.mastered, isFalse);
    expect(weak.single.consecutiveCorrect, 0);
  });

  test('연속 2회 정답이면 졸업(mastered → weak 목록에서 제외)', () {
    final idx = WrongAnswerIndex.build(
      attempts: [
        _a('practice:clf-t1-1', ['clf-t1-1-q1', 'clf-t1-1-q2'], ['clf-t1-1-q1'],
            date: '2026-06-01T00:00:00.000'),
        _a('review:clf-t1-1', ['clf-t1-1-q1'], const [],
            date: '2026-06-02T00:00:00.000'),
        _a('review:clf-t1-1', ['clf-t1-1-q1'], const [],
            date: '2026-06-03T00:00:00.000'),
      ],
      taskBank: _taskBank,
      taskCert: _taskCert,
    );
    expect(idx.weakFor('CLF-C02'), isEmpty);
  });

  test('정답 1회만으론 미졸업(streak=1)', () {
    final idx = WrongAnswerIndex.build(
      attempts: [
        _a('practice:clf-t1-1', ['clf-t1-1-q1', 'clf-t1-1-q2'], ['clf-t1-1-q1'],
            date: '2026-06-01T00:00:00.000'),
        _a('review:clf-t1-1', ['clf-t1-1-q1'], const [],
            date: '2026-06-02T00:00:00.000'),
      ],
      taskBank: _taskBank,
      taskCert: _taskCert,
    );
    final weak = idx.weakFor('CLF-C02');
    expect(weak.single.questionId, 'clf-t1-1-q1');
    expect(weak.single.consecutiveCorrect, 1);
  });

  test('레거시(presentedQuestionIds 없음)는 현재 뱅크로 폴백', () {
    final legacy = AttemptRecord.fromJson({
      'certId': 'CLF-C02',
      'examId': 'practice:clf-t1-1',
      'mode': 'practice',
      'date': '2026-06-01T00:00:00.000',
      'correct': 1,
      'total': 2,
      'wrongQuestionIds': ['clf-t1-1-q2'],
      'flaggedQuestionIds': <String>[],
      'durationSpentSec': 0,
    });
    final idx = WrongAnswerIndex.build(
      attempts: [legacy],
      taskBank: _taskBank,
      taskCert: _taskCert,
    );
    expect(idx.weakFor('CLF-C02').map((e) => e.questionId), ['clf-t1-1-q2']);
  });

  test('현재 뱅크에 없는 문항은 제외', () {
    final idx = WrongAnswerIndex.build(
      attempts: [
        _a('practice:clf-t1-1', ['clf-t1-1-q9'], ['clf-t1-1-q9']),
      ],
      taskBank: _taskBank,
      taskCert: _taskCert,
    );
    expect(idx.weakFor('CLF-C02'), isEmpty);
  });

  test('weakCountByTask 집계', () {
    final idx = WrongAnswerIndex.build(
      attempts: [
        _a('practice:clf-t1-1', ['clf-t1-1-q1', 'clf-t1-1-q2'],
            ['clf-t1-1-q1', 'clf-t1-1-q2']),
      ],
      taskBank: _taskBank,
      taskCert: _taskCert,
    );
    expect(idx.weakCountByTask('CLF-C02'), {'clf-t1-1': 2});
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `flutter test test/wrong_answer_index_test.dart`
Expected: FAIL (`wrong_answer_index.dart` 없음 → 컴파일 에러).

- [ ] **Step 3: 구현 작성**

Create `lib/data/wrong_answer_index.dart`:

```dart
import '../models/attempt_record.dart';

/// 오답노트 한 항목(문항 단위 약점 상태). 순수 계산 결과.
class WrongEntry {
  const WrongEntry({
    required this.questionId,
    required this.taskId,
    required this.certId,
    required this.wrongCount,
    required this.consecutiveCorrect,
    required this.lastSeen,
    required this.mastered,
  });

  final String questionId;
  final String taskId;
  final String certId;
  final int wrongCount;
  final int consecutiveCorrect;
  final String lastSeen; // ISO-8601, 마지막 출제 date
  final bool mastered;

  bool get weak => !mastered;
}

/// append-only 응시 로그에서 문항별 약점/마스터 상태를 파생하는 순수 인덱스.
///
/// 규칙: 한 번이라도 틀린 문항만 대상. 가장 최근 2회 출제가 모두 정답이면
/// `mastered`(졸업), 아니면 `weak`. "출제된 응시"는 그 문항이
/// presentedQuestionIds에 포함된 AttemptRecord 1건(레거시는 현재 뱅크로 폴백).
class WrongAnswerIndex {
  WrongAnswerIndex._(this._entries);
  final List<WrongEntry> _entries;

  factory WrongAnswerIndex.build({
    required List<AttemptRecord> attempts,
    required Map<String, List<String>> taskBank,
    required Map<String, String> taskCert,
  }) {
    final timeline = <String, List<bool>>{}; // qid -> 정/오답(true=correct) 시간순
    final taskOf = <String, String>{};
    final lastSeen = <String, String>{};

    final sorted = [...attempts]..sort((a, b) => a.date.compareTo(b.date));
    for (final a in sorted) {
      final taskId = _taskFromExamId(a.examId);
      if (taskId == null) continue;
      final bank = taskBank[taskId];
      if (bank == null) continue;
      final bankSet = bank.toSet();
      final presented = a.presentedQuestionIds.isNotEmpty
          ? a.presentedQuestionIds
          : bank; // 레거시 폴백
      final wrong = a.wrongQuestionIds.toSet();
      for (final qid in presented) {
        if (!bankSet.contains(qid)) continue; // 삭제·비검증 문항 제외
        taskOf[qid] = taskId;
        lastSeen[qid] = a.date;
        (timeline[qid] ??= <bool>[]).add(!wrong.contains(qid));
      }
    }

    final entries = <WrongEntry>[];
    timeline.forEach((qid, outcomes) {
      final wrongCount = outcomes.where((c) => !c).length;
      if (wrongCount == 0) return; // 틀린 적 없으면 노트 대상 아님
      var streak = 0;
      for (var i = outcomes.length - 1; i >= 0 && outcomes[i]; i--) {
        streak++;
      }
      final taskId = taskOf[qid]!;
      entries.add(WrongEntry(
        questionId: qid,
        taskId: taskId,
        certId: taskCert[taskId] ?? '',
        wrongCount: wrongCount,
        consecutiveCorrect: streak,
        lastSeen: lastSeen[qid] ?? '',
        mastered: streak >= 2,
      ));
    });
    return WrongAnswerIndex._(entries);
  }

  /// 해당 cert(옵션: 특정 task)의 weak 문항.
  List<WrongEntry> weakFor(String certId, {String? taskId}) => _entries
      .where((e) =>
          e.weak &&
          e.certId == certId &&
          (taskId == null || e.taskId == taskId))
      .toList();

  /// 해당 cert의 Task별 weak 개수(배지용). weak 0인 Task는 키 없음.
  Map<String, int> weakCountByTask(String certId) {
    final m = <String, int>{};
    for (final e in _entries) {
      if (e.weak && e.certId == certId) {
        m[e.taskId] = (m[e.taskId] ?? 0) + 1;
      }
    }
    return m;
  }

  static String? _taskFromExamId(String examId) {
    final i = examId.indexOf(':');
    if (i < 0 || i == examId.length - 1) return null;
    return examId.substring(i + 1);
  }
}
```

- [ ] **Step 4: 테스트 통과 확인**

Run: `flutter test test/wrong_answer_index_test.dart`
Expected: PASS(6 케이스).

- [ ] **Step 5: 커밋(사용자 승인 시)**

```bash
git add lib/data/wrong_answer_index.dart test/wrong_answer_index_test.dart
git commit -m "feat(review): WrongAnswerIndex 순수 집계(약점/마스터 파생)"
```

---

## Task 5: review_loader (뱅크+이력 → 인덱스 글루)

순수 인덱스에 줄 데이터를 모으는 얇은 비동기 글루. 단위 테스트는 Task 6의 위젯 테스트가 실자산으로 커버.

**Files:**
- Create: `lib/data/review_loader.dart`

- [ ] **Step 1: 구현 작성**

Create `lib/data/review_loader.dart`:

```dart
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/question.dart';
import 'content_index.dart';
import 'history_store.dart';
import 'wrong_answer_index.dart';

/// 오답노트 화면에 필요한 데이터 묶음.
class ReviewData {
  const ReviewData({required this.index, required this.banks});
  final WrongAnswerIndex index;
  final Map<String, QuestionBank> banks; // taskId -> 전체(검증) 뱅크
}

/// 해당 cert의 모든 Task 뱅크 + 응시 이력을 읽어 인덱스를 만든다.
/// QuestionBank.fromJson은 verified 문항만 남기므로 taskBank는 검증 ID 목록.
Future<ReviewData> loadReviewData(String certCode, {HistoryStore? history}) async {
  final entries = contentFor(certCode);
  final banks = <String, QuestionBank>{};
  final taskBank = <String, List<String>>{};
  final taskCert = <String, String>{};
  for (final e in entries) {
    try {
      final raw = await rootBundle.loadString(e.questionsAsset);
      final bank =
          QuestionBank.fromJson(json.decode(raw) as Map<String, dynamic>);
      banks[e.taskId] = bank;
      taskBank[e.taskId] = bank.questions.map((q) => q.id).toList();
      taskCert[e.taskId] = e.certCode;
    } catch (_) {
      // 로드 실패 Task는 건너뜀
    }
  }
  final attempts = (history ?? HistoryStore()).all();
  final index = WrongAnswerIndex.build(
    attempts: attempts,
    taskBank: taskBank,
    taskCert: taskCert,
  );
  return ReviewData(index: index, banks: banks);
}
```

- [ ] **Step 2: 컴파일 확인**

Run: `flutter analyze lib/data/review_loader.dart`
Expected: "No issues found!"

- [ ] **Step 3: 커밋(사용자 승인 시)**

```bash
git add lib/data/review_loader.dart
git commit -m "feat(review): review_loader(뱅크+이력 → WrongAnswerIndex)"
```

---

## Task 6: ReviewListPage + 복습 러너 호스트

cert별 오답 목록. Task 그룹마다 weak 수 + "복습 시작" → weak 문항만 담은 합성 뱅크로 `QuizView(mode:'review')` 실행. 복귀 시 목록 갱신(졸업 반영).

**Files:**
- Create: `lib/pages/review_page.dart`
- Test: `test/review_page_test.dart`

- [ ] **Step 1: 실패 테스트 작성**

Create `test/review_page_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/history_store.dart';
import 'package:aws_docs/models/attempt_record.dart';
import 'package:aws_docs/pages/review_page.dart';
import 'package:aws_docs/theme/app_theme.dart';

void main() {
  testWidgets('오답 없으면 빈 상태 안내', (tester) async {
    final history = HistoryStore(backend: MemoryBackend());
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: ReviewListPage(
          certCode: 'CLF-C02', certTitle: 'AWS CCP', history: history),
    ));
    await tester.pumpAndSettle();
    expect(find.textContaining('아직 오답이 없습니다'), findsOneWidget);
  });

  testWidgets('오답이 있으면 해당 Task 행과 weak 수 표시', (tester) async {
    final history = HistoryStore(backend: MemoryBackend());
    history.add(const AttemptRecord(
      certId: 'CLF-C02',
      examId: 'practice:clf-t1-1',
      mode: 'practice',
      date: '2026-06-06T00:00:00.000',
      correct: 0,
      total: 1,
      wrongQuestionIds: ['clf-t1-1-q1'],
      flaggedQuestionIds: [],
      durationSpentSec: 10,
      presentedQuestionIds: ['clf-t1-1-q1'],
    ));
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: ReviewListPage(
          certCode: 'CLF-C02', certTitle: 'AWS CCP', history: history),
    ));
    await tester.pumpAndSettle();
    expect(find.text('복습 시작'), findsOneWidget);
    expect(find.textContaining('오답 1'), findsWidgets);
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `flutter test test/review_page_test.dart`
Expected: FAIL (`review_page.dart` 없음).

- [ ] **Step 3: 구현 작성**

Create `lib/pages/review_page.dart`:

```dart
import 'package:flutter/material.dart';

import '../data/history_store.dart';
import '../data/review_loader.dart';
import '../models/question.dart';
import '../theme/app_theme.dart';
import 'quiz_page.dart';

/// cert별 오답노트 목록. Task 그룹별 weak 수 + 복습 진입.
class ReviewListPage extends StatefulWidget {
  const ReviewListPage({
    super.key,
    required this.certCode,
    required this.certTitle,
    this.history,
  });

  final String certCode;
  final String certTitle;
  final HistoryStore? history; // 테스트 주입용

  @override
  State<ReviewListPage> createState() => _ReviewListPageState();
}

class _ReviewListPageState extends State<ReviewListPage> {
  late Future<ReviewData> _future = _load();

  Future<ReviewData> _load() =>
      loadReviewData(widget.certCode, history: widget.history);

  void _reload() => setState(() => _future = _load());

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
        title: Text('${widget.certTitle} · 오답노트',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      body: FutureBuilder<ReviewData>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError || snap.data == null) {
            return Center(
                child: Text('오답을 불러오지 못했습니다.',
                    style: TextStyle(color: c.textMuted)));
          }
          final data = snap.data!;
          final counts = data.index.weakCountByTask(widget.certCode);
          final tasks = data.banks.keys
              .where((t) => (counts[t] ?? 0) > 0)
              .toList()
            ..sort();
          if (tasks.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(Gap.xl),
                child: Text('아직 오답이 없습니다 — 연습/시험을 풀면 여기 모입니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: c.textMuted)),
              ),
            );
          }
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: Layout.exam),
              child: ListView(
                padding: const EdgeInsets.all(Gap.xl),
                children: [
                  for (final taskId in tasks)
                    _TaskRow(
                      taskId: taskId,
                      title: data.banks[taskId]!.taskTitle,
                      weak: counts[taskId]!,
                      onTap: () => _startReview(data, taskId),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _startReview(ReviewData data, String taskId) async {
    final weakIds = data.index
        .weakFor(widget.certCode, taskId: taskId)
        .map((e) => e.questionId)
        .toSet();
    final full = data.banks[taskId]!;
    final bank = QuestionBank(
      examGuideTaskId: full.examGuideTaskId,
      taskTitle: full.taskTitle,
      certCode: full.certCode,
      domain: full.domain,
      questions:
          full.questions.where((q) => weakIds.contains(q.id)).toList(),
    );
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _ReviewRunnerPage(
          bank: bank, certId: widget.certCode, history: widget.history),
    ));
    if (mounted) _reload(); // 복습 후 졸업 반영
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.taskId,
    required this.title,
    required this.weak,
    required this.onTap,
  });
  final String taskId;
  final String title;
  final int weak;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    final no = taskId.replaceAll('clf-t', '').replaceAll('-', '.');
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.md),
        child: Container(
          padding: const EdgeInsets.all(Gap.lg),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(Radii.md),
            border: Border.all(color: c.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Task $no · $title', style: t.titleMedium),
                    const SizedBox(height: Gap.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                          color: c.wrongWeak,
                          borderRadius: BorderRadius.circular(Radii.full)),
                      child: Text('오답 $weak',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: c.wrong)),
                    ),
                  ],
                ),
              ),
              Text('복습 시작',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: c.accent)),
            ],
          ),
        ),
      ),
    );
  }
}

/// 합성 weak 뱅크를 QuizView(mode:'review')로 실행하는 호스트.
class _ReviewRunnerPage extends StatelessWidget {
  const _ReviewRunnerPage({
    required this.bank,
    required this.certId,
    this.history,
  });
  final QuestionBank bank;
  final String certId;
  final HistoryStore? history;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final store = history ?? HistoryStore();
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: Border(bottom: BorderSide(color: c.border)),
        title: const Text('오답 복습',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Layout.exam),
          child: QuizView(
            bank: bank,
            certId: certId,
            mode: 'review',
            onFinished: store.add,
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: 테스트 통과 확인**

Run: `flutter test test/review_page_test.dart`
Expected: PASS(빈 상태 + 약점 목록).

- [ ] **Step 5: 커밋(사용자 승인 시)**

```bash
git add lib/pages/review_page.dart test/review_page_test.dart
git commit -m "feat(review): ReviewListPage + QuizView(mode:review) 재사용 러너"
```

---

## Task 7: cert 상세 페이지 통합 (오답 N 배지 + 오답노트 진입)

**Files:**
- Modify: `lib/pages/cert_detail_page.dart`

- [ ] **Step 1: _load가 weakCountByTask도 반환하도록 확장**

`cert_detail_page.dart` 상단의 typedef와 import 수정:

```dart
import '../data/content_index.dart';
import '../data/review_loader.dart';
import '../models/certification.dart';
import '../models/exam_guide.dart';
import '../theme/app_theme.dart';
import 'review_page.dart';
import 'study_doc_page.dart';

typedef _Loaded = ({
  ExamGuide? guide,
  ExamSummary? summary,
  Map<String, int> weakByTask,
});
```

`_load()`의 마지막 `return`을 교체(리뷰 인덱스 추가 로드):

```dart
    Map<String, int> weakByTask = const {};
    try {
      final data = await loadReviewData(cert.code);
      weakByTask = data.index.weakCountByTask(cert.code);
    } catch (_) {}
    return (guide: guide, summary: summary, weakByTask: weakByTask);
```

- [ ] **Step 2: 빌더가 weakByTask를 _LearningContent로 전달 + 오답노트 진입**

`build`의 FutureBuilder 내부에서 `_LearningContent(entries: ...)` 호출을 교체:

```dart
                          if (contentFor(cert.code).isNotEmpty)
                            _LearningContent(
                              entries: contentFor(cert.code),
                              weakByTask: snap.data?.weakByTask ?? const {},
                              certCode: cert.code,
                              certTitle: cert.title,
                            ),
```

- [ ] **Step 3: _LearningContent에 배지 + 진입 추가**

`_LearningContent`를 교체:

```dart
class _LearningContent extends StatelessWidget {
  const _LearningContent({
    required this.entries,
    required this.weakByTask,
    required this.certCode,
    required this.certTitle,
  });
  final List<ContentEntry> entries;
  final Map<String, int> weakByTask;
  final String certCode;
  final String certTitle;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    final totalWeak = weakByTask.values.fold<int>(0, (s, v) => s + v);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: Gap.xl2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.menu_book_outlined, size: 18, color: c.accent),
            const SizedBox(width: 8),
            Text('학습 콘텐츠 · 검증 문항', style: t.headlineSmall),
          ]),
          const SizedBox(height: 4),
          Text('AWS 공식 출처로 검증한 한국어 학습문서와 연습 문제.',
              style: t.bodyMedium),
          if (totalWeak > 0) ...[
            const SizedBox(height: Gap.md),
            InkWell(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ReviewListPage(
                      certCode: certCode, certTitle: certTitle))),
              borderRadius: BorderRadius.circular(Radii.sm),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: Gap.lg, vertical: Gap.md),
                decoration: BoxDecoration(
                  color: c.wrongWeak,
                  borderRadius: BorderRadius.circular(Radii.sm),
                  border: Border.all(color: c.wrong.withValues(alpha: 0.35)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.replay, size: 18, color: c.wrong),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('오답노트 · 복습할 문항 $totalWeak개',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: c.wrong)),
                    ),
                    Text('→',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: c.wrong)),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: Gap.lg),
          for (final e in entries)
            Padding(
              padding: const EdgeInsets.only(bottom: Gap.md),
              child: InkWell(
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => StudyDocPage(entry: e))),
                borderRadius: BorderRadius.circular(Radii.md),
                child: Container(
                  padding: const EdgeInsets.all(Gap.lg),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(Radii.md),
                    border: Border.all(color: c.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Task ${e.taskId.replaceAll('clf-t', '').replaceAll('-', '.')} · ${e.title}',
                                style: t.titleMedium),
                            const SizedBox(height: Gap.xs),
                            Wrap(
                              spacing: Gap.xs,
                              runSpacing: Gap.xs,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                      color: c.correctWeak,
                                      borderRadius:
                                          BorderRadius.circular(Radii.full)),
                                  child: Text('검증 문항 ${e.questionCount}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: c.correct)),
                                ),
                                if ((weakByTask[e.taskId] ?? 0) > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                        color: c.wrongWeak,
                                        borderRadius:
                                            BorderRadius.circular(Radii.full)),
                                    child: Text('오답 ${weakByTask[e.taskId]}',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: c.wrong)),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Text('학습문서 →',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: c.accent)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: analyze + 전체 테스트**

Run: `flutter analyze`
Expected: "No issues found!"

Run: `flutter test`
Expected: 모든 테스트 PASS.

- [ ] **Step 5: 커밋(사용자 승인 시)**

```bash
git add lib/pages/cert_detail_page.dart
git commit -m "feat(review): cert 상세에 오답 N 배지 + 오답노트 진입"
```

---

## Task 8: 최종 검증

**Files:** (없음 — 검증만)

- [ ] **Step 1: 정적 분석**

Run: `flutter analyze`
Expected: "No issues found!"

- [ ] **Step 2: 전체 테스트**

Run: `flutter test`
Expected: 모든 테스트 PASS(기존 21 + 신규: attempt_record 1, quiz_view +1, exam_view 단언, wrong_answer_index 6, review_page 2).

- [ ] **Step 3: 웹 릴리스 빌드(배포 동등성)**

Run: `flutter build web --release --base-href /aws-docs/`
Expected: "✓ Built build\web"

- [ ] **Step 4: 수동 스모크(권장)**

`flutter run -d chrome` 후: 학습문서 → 연습 문제에서 일부러 오답 → cert 상세로 돌아가 "오답 N" 배지·"오답노트" 진입 확인 → 복습 → 같은 문항 2회 정답 → 졸업(목록에서 사라짐) 확인.

- [ ] **Step 5: 커밋(사용자 승인 시)**

```bash
git add -A
git commit -m "chore(review): E1 오답노트 최종 검증"
```

---

## Self-Review (작성자 점검)

**1. 스펙 커버리지:**
- §2 데이터 모델(presentedQuestionIds) → Task 1·2·3 ✓
- §3 WrongAnswerIndex(weak/mastered, 레거시 폴백, 삭제 문항 제외) → Task 4 ✓
- §4 UI(cert 상세 배지·오답노트 진입·ReviewListPage·연습형 러너) → Task 6·7 ✓
- §4 복습=QuizView 재사용(mode) → Task 2·6 ✓
- §6 mode:'review' 기록·헤드라인 정답률 미반영 → Task 2(기록), E2에서 소비(범위 밖) ✓
- §7 엣지(빈 상태·손상 history·삭제 문항) → Task 4·6 ✓
- §8 테스트 → 각 Task의 테스트 스텝 ✓

**2. Placeholder 스캔:** TBD/TODO 없음. 모든 코드 스텝에 실제 코드 포함.

**3. 타입 일관성:** `presentedQuestionIds`(List<String>), `QuizView.mode`(String, 기본 'practice'), `WrongAnswerIndex.build({attempts, taskBank, taskCert})`, `WrongEntry{questionId,taskId,certId,wrongCount,consecutiveCorrect,lastSeen,mastered,weak}`, `loadReviewData(certCode,{history})→ReviewData{index,banks}`, `ReviewListPage{certCode,certTitle,history?}` — Task 전반에서 일치.

**미해결 참고(실행 시 확인):**
- `AppTheme.light` 명칭이 실제 테마 게터와 일치하는지 위젯 테스트 작성 시 확인(`app_theme.dart` 참조). 다르면 테스트의 `theme:` 인자를 실제 게터로 교체.
- 위젯 테스트의 rootBundle 자산 로드(`flutter test`)가 동작하는지 Task 6 Step 4에서 확인. 문제 시 `TestWidgetsFlutterBinding.ensureInitialized()` 추가 또는 실자산 대신 주입형으로 조정.
