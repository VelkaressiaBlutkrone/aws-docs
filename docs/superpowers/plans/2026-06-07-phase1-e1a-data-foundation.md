# Phase 1 · E1a — 오답노트 데이터 기반 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 오답노트(E1)의 순수 데이터 기반을 만든다 — `AttemptRecord.presentedQuestionIds` 추가, 연습·시험 작성자가 이를 기록, 그리고 이력에서 약점/졸업을 파생하는 순수 `WrongAnswerIndex` 집계 모듈. **UI 없음, 전부 단위/위젯 테스트로 검증.**

**Architecture:** `AttemptRecord`에 하위호환 필드 `presentedQuestionIds` 추가(누락 시 `const []`). `QuizView._finish`·`ExamView._submit`가 출제 문항 ID를 채워 기록(통합 모의고사는 `ExamView`를 재사용하므로 자동 포함). 신규 순수 모듈 `WrongAnswerIndex`가 `List<AttemptRecord>` + 현재 뱅크의 `(문항ID→TaskID)` 맵을 입력받아, "한 번이라도 틀린" 문항의 정/오답 타임라인을 date 오름차순으로 구성하고 **서로 다른 응시에서 연속 2회 정답 → mastered(졸업)** 규칙으로 weak/mastered를 판정한다. 자산 로드는 호출측 책임(인덱스는 순수 유지).

**Tech Stack:** Flutter (Dart), 기존 테스트 패턴(`flutter_test` + `MemoryBackend`). 외부 의존 추가 없음.

**경로:** 코드 = `D:\workspace\awc-docs\flutter_app`(git 루트 바로 아래). flutter 명령은 **PowerShell**로 `flutter_app`에서. git은 **절대 `-C D:/workspace/awc-docs`** (PowerShell Set-Location이 Bash cwd까지 바꾸므로).

**스펙:** `docs/superpowers/specs/2026-06-06-learning-loop-e1-design.md` §3·§4 + 로드맵 `2026-06-07-work-priority-roadmap-design.md` §4. **E1b(복습 UI)는 별도 계획.**

---

## 데이터 계약 (이 계획에서 확정 — 후속 Task가 참조)

- `AttemptRecord.presentedQuestionIds: List<String>` — 그 응시에 **출제된 전체 문항 ID**(순서 무관, 집계는 set 의미로 사용). 누락(레거시)=`const []`.
- 파생 규칙: 한 응시에서 문항의 정답 여부 = `presentedQuestionIds`에 포함 && `wrongQuestionIds`에 **미포함** → 정답.
- 레거시 폴백(`presentedQuestionIds` 빈 경우): `examId`(`practice:<task>`/`exam:<task>`/`review:<task>`)에서 task 유추 → 그 Task의 현재 뱅크 문항 전체가 출제됐다고 간주. 유추 불가(`*-mock` 등 `:` 뒤가 `-mock`로 끝나거나 `:` 없음)이면 그 응시의 `wrongQuestionIds`만 출제로 인정(정답 추정 안 함 = 정직).
- `WrongStatus { weak, mastered }`, mastered = 첫 오답 이후 **마지막 연속 정답 ≥ 2**.
- `WrongEntry { questionId, taskId, certId, wrongCount, consecutiveCorrect, lastSeen, status }`.
- `WrongAnswerIndex.build({certId, history, taskByQuestionId})` → `.entries` / `.weakByTask()` / `.weakEntries([taskId])`.

---

## Task 1: `AttemptRecord`에 `presentedQuestionIds` 추가 (하위호환)

**Files:**
- Modify: `flutter_app/lib/models/attempt_record.dart`
- Test: `flutter_app/test/history_store_test.dart`

- [ ] **Step 1: 기준선 — 기존 테스트 green 확인**

PowerShell, `flutter_app`에서:
```
flutter test
```
Expected: All tests passed (41).

- [ ] **Step 2: 실패하는 테스트 추가 — presentedQuestionIds 왕복 + 레거시 기본값**

`flutter_app/test/history_store_test.dart`의 `main()` 안, 첫 `test(...)` 위 또는 아래에 추가:
```dart
  test('presentedQuestionIds JSON 왕복 + 레거시 누락은 빈 리스트', () {
    const r = AttemptRecord(
      certId: 'CLF-C02',
      examId: 'practice:clf-t2-1',
      mode: 'practice',
      date: '2026-06-06T00:00:00.000',
      correct: 4,
      total: 5,
      wrongQuestionIds: ['clf-t2-1-q3'],
      flaggedQuestionIds: [],
      presentedQuestionIds: ['clf-t2-1-q1', 'clf-t2-1-q3'],
      durationSpentSec: 120,
    );
    final back = AttemptRecord.fromJson(r.toJson());
    expect(back.presentedQuestionIds, ['clf-t2-1-q1', 'clf-t2-1-q3']);

    // 레거시: presentedQuestionIds 키가 없는 JSON → 빈 리스트
    final legacy = AttemptRecord.fromJson({
      'certId': 'CLF-C02',
      'examId': 'practice:clf-t2-1',
      'mode': 'practice',
      'date': '2026-06-06T00:00:00.000',
      'correct': 4,
      'total': 5,
      'wrongQuestionIds': ['clf-t2-1-q3'],
      'flaggedQuestionIds': <String>[],
      'durationSpentSec': 120,
    });
    expect(legacy.presentedQuestionIds, isEmpty);
  });
```

- [ ] **Step 3: 테스트 실패 확인**

Run: `flutter test test/history_store_test.dart`
Expected: 컴파일 실패 — `presentedQuestionIds` named parameter가 `AttemptRecord`에 없음.

- [ ] **Step 4: 모델에 필드 추가**

`flutter_app/lib/models/attempt_record.dart`:

생성자에 `flaggedQuestionIds` 줄 아래로 추가:
```dart
    required this.flaggedQuestionIds,
    this.presentedQuestionIds = const [],
    required this.durationSpentSec,
```

필드 선언 `final List<String> flaggedQuestionIds;` 아래에 추가:
```dart
  final List<String> flaggedQuestionIds;

  /// 그 응시에 출제된 전체 문항 ID(약점 파생용). 레거시 레코드는 빈 리스트.
  final List<String> presentedQuestionIds;
```

`toJson()`의 `'flaggedQuestionIds': flaggedQuestionIds,` 아래에 추가:
```dart
        'flaggedQuestionIds': flaggedQuestionIds,
        'presentedQuestionIds': presentedQuestionIds,
```

`fromJson`의 `flaggedQuestionIds: ...` 매핑 아래에 추가:
```dart
        flaggedQuestionIds: ((j['flaggedQuestionIds'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
        presentedQuestionIds: ((j['presentedQuestionIds'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
```

- [ ] **Step 5: 테스트 통과 확인**

Run: `flutter test test/history_store_test.dart`
Expected: PASS(왕복·레거시 모두). 기존 'AttemptRecord JSON 왕복' 테스트도 green 유지(필드 옵셔널이라 영향 없음).

- [ ] **Step 6: 커밋**

git 루트에서:
```
git -C D:/workspace/awc-docs add flutter_app/lib/models/attempt_record.dart flutter_app/test/history_store_test.dart
git -C D:/workspace/awc-docs commit -m "feat: AttemptRecord.presentedQuestionIds 추가(하위호환, 약점 파생 토대)"
```

---

## Task 2: 작성자(QuizView·ExamView)가 presentedQuestionIds 기록

연습(`QuizView`)·시험(`ExamView`) 종료 시 출제된 전체 문항 ID를 레코드에 채운다. 통합 모의고사는 `ExamView`를 재사용하므로 자동 포함된다.

**Files:**
- Modify: `flutter_app/lib/pages/quiz_page.dart` (`QuizView._finish`)
- Modify: `flutter_app/lib/pages/exam_page.dart` (`_ExamViewState._submit`)
- Test: `flutter_app/test/quiz_view_test.dart`, `flutter_app/test/exam_view_test.dart`

- [ ] **Step 1: 실패하는 테스트 추가 — QuizView가 출제 ID 기록**

`flutter_app/test/quiz_view_test.dart`의 마지막 `expect` 블록(`expect(finished!.wrongQuestionIds, isEmpty);` 아래)에 추가:
```dart
    expect(finished!.presentedQuestionIds, ['q1']);
```

- [ ] **Step 2: 실패하는 테스트 추가 — ExamView가 출제 ID 기록**

`flutter_app/test/exam_view_test.dart`의 '정답 선택 후 제출 → 채점, flagged 기록' 테스트에서 `expect(finished!.flaggedQuestionIds, ['q1']);` 아래에 추가:
```dart
    expect(finished!.presentedQuestionIds, ['q1', 'q2']);
```

- [ ] **Step 3: 테스트 실패 확인**

Run: `flutter test test/quiz_view_test.dart test/exam_view_test.dart`
Expected: 두 테스트 FAIL — `presentedQuestionIds`가 비어 있음(기본값 `const []`).

- [ ] **Step 4: QuizView._finish 갱신**

`flutter_app/lib/pages/quiz_page.dart`의 `_finish()` 안, `widget.onFinished?.call(AttemptRecord(` 호출에서 `flaggedQuestionIds: const [],` 아래에 추가:
```dart
      flaggedQuestionIds: const [],
      presentedQuestionIds: [for (final q in _qs) q.id],
```

- [ ] **Step 5: ExamView._submit 갱신**

`flutter_app/lib/pages/exam_page.dart`의 `_submit({required bool auto})` 안, `widget.onFinished?.call(AttemptRecord(` 호출에서 `flaggedQuestionIds: flaggedIds,` 아래에 추가:
```dart
      flaggedQuestionIds: flaggedIds,
      presentedQuestionIds: [for (final q in _qs) q.id],
```

- [ ] **Step 6: 테스트 통과 + 전체 회귀 확인**

Run:
```
flutter test
```
Expected: All tests passed(43 — Task 1에서 +1, Task 2는 기존 테스트에 expect만 추가라 개수 동일하게 41→… 실제로는 Task1 신규 1건만 추가되어 42. 카운트는 "모두 green"이 본질). analyze도 확인:
```
flutter analyze
```
Expected: No issues found!

- [ ] **Step 7: 커밋**

git 루트에서:
```
git -C D:/workspace/awc-docs add flutter_app/lib/pages/quiz_page.dart flutter_app/lib/pages/exam_page.dart flutter_app/test/quiz_view_test.dart flutter_app/test/exam_view_test.dart
git -C D:/workspace/awc-docs commit -m "feat: 연습/시험 종료 시 presentedQuestionIds 기록(통합 모의고사 포함)"
```

---

## Task 3: `WrongAnswerIndex` 순수 집계 모듈

이력에서 "한 번이라도 틀린" 문항의 약점/졸업 상태를 파생하는 순수 함수 모듈. 자산 로드 없음(호출측이 `taskByQuestionId`를 주입).

**Files:**
- Create: `flutter_app/lib/data/wrong_answer_index.dart`
- Test: `flutter_app/test/wrong_answer_index_test.dart`

- [ ] **Step 1: 실패하는 테스트 작성**

`flutter_app/test/wrong_answer_index_test.dart` 생성:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/models/attempt_record.dart';
import 'package:aws_docs/data/wrong_answer_index.dart';

// 현재 뱅크: 문항ID -> TaskID (개정으로 사라진 문항은 이 맵에서 빠짐).
const _tasks = {
  'clf-t2-1-q1': 'clf-t2-1',
  'clf-t2-1-q2': 'clf-t2-1',
  'clf-t2-1-q3': 'clf-t2-1',
  'clf-t3-1-q1': 'clf-t3-1',
};

AttemptRecord _rec({
  required String examId,
  required String date,
  required List<String> presented,
  required List<String> wrong,
  String mode = 'practice',
}) =>
    AttemptRecord(
      certId: 'CLF-C02',
      examId: examId,
      mode: mode,
      date: date,
      correct: presented.length - wrong.length,
      total: presented.length,
      wrongQuestionIds: wrong,
      flaggedQuestionIds: const [],
      presentedQuestionIds: presented,
      durationSpentSec: 60,
    );

void main() {
  test('한 번도 틀리지 않은 문항은 노트에 없음', () {
    final idx = WrongAnswerIndex.build(
      certId: 'CLF-C02',
      taskByQuestionId: _tasks,
      history: [
        _rec(examId: 'practice:clf-t2-1', date: '2026-06-01',
            presented: ['clf-t2-1-q1', 'clf-t2-1-q2'], wrong: []),
      ],
    );
    expect(idx.entries, isEmpty);
    expect(idx.weakByTask(), isEmpty);
  });

  test('첫 오답 후 미졸업 → weak', () {
    final idx = WrongAnswerIndex.build(
      certId: 'CLF-C02',
      taskByQuestionId: _tasks,
      history: [
        _rec(examId: 'practice:clf-t2-1', date: '2026-06-01',
            presented: ['clf-t2-1-q1'], wrong: ['clf-t2-1-q1']),
      ],
    );
    expect(idx.weakEntries().map((e) => e.questionId), ['clf-t2-1-q1']);
    expect(idx.weakByTask(), {'clf-t2-1': 1});
    expect(idx.entries.single.status, WrongStatus.weak);
    expect(idx.entries.single.wrongCount, 1);
    expect(idx.entries.single.consecutiveCorrect, 0);
  });

  test('서로 다른 응시 2회 연속 정답 → mastered(졸업)', () {
    final idx = WrongAnswerIndex.build(
      certId: 'CLF-C02',
      taskByQuestionId: _tasks,
      history: [
        _rec(examId: 'practice:clf-t2-1', date: '2026-06-01',
            presented: ['clf-t2-1-q1'], wrong: ['clf-t2-1-q1']), // 오답
        _rec(examId: 'review:clf-t2-1', date: '2026-06-02', mode: 'review',
            presented: ['clf-t2-1-q1'], wrong: []), // 정답 1
        _rec(examId: 'review:clf-t2-1', date: '2026-06-03', mode: 'review',
            presented: ['clf-t2-1-q1'], wrong: []), // 정답 2 → 졸업
      ],
    );
    expect(idx.entries.single.status, WrongStatus.mastered);
    expect(idx.entries.single.consecutiveCorrect, 2);
    expect(idx.weakByTask(), isEmpty); // 졸업이라 weak 0
    expect(idx.weakEntries(), isEmpty);
  });

  test('1회만 정답이면 아직 weak (졸업 아님)', () {
    final idx = WrongAnswerIndex.build(
      certId: 'CLF-C02',
      taskByQuestionId: _tasks,
      history: [
        _rec(examId: 'practice:clf-t2-1', date: '2026-06-01',
            presented: ['clf-t2-1-q1'], wrong: ['clf-t2-1-q1']),
        _rec(examId: 'review:clf-t2-1', date: '2026-06-02', mode: 'review',
            presented: ['clf-t2-1-q1'], wrong: []),
      ],
    );
    expect(idx.entries.single.status, WrongStatus.weak);
    expect(idx.entries.single.consecutiveCorrect, 1);
  });

  test('정답 후 재오답 → 연속정답 리셋(weak)', () {
    final idx = WrongAnswerIndex.build(
      certId: 'CLF-C02',
      taskByQuestionId: _tasks,
      history: [
        _rec(examId: 'practice:clf-t2-1', date: '2026-06-01',
            presented: ['clf-t2-1-q1'], wrong: ['clf-t2-1-q1']),
        _rec(examId: 'review:clf-t2-1', date: '2026-06-02', mode: 'review',
            presented: ['clf-t2-1-q1'], wrong: []),
        _rec(examId: 'practice:clf-t2-1', date: '2026-06-03',
            presented: ['clf-t2-1-q1'], wrong: ['clf-t2-1-q1']), // 다시 오답
      ],
    );
    expect(idx.entries.single.status, WrongStatus.weak);
    expect(idx.entries.single.wrongCount, 2);
    expect(idx.entries.single.consecutiveCorrect, 0);
  });

  test('현재 뱅크에 없는(개정 삭제) 문항은 제외', () {
    final idx = WrongAnswerIndex.build(
      certId: 'CLF-C02',
      taskByQuestionId: _tasks,
      history: [
        _rec(examId: 'practice:clf-t2-1', date: '2026-06-01',
            presented: ['clf-t2-1-q9'], wrong: ['clf-t2-1-q9']), // q9 = 삭제됨
      ],
    );
    expect(idx.entries, isEmpty);
  });

  test('레거시 레코드(presented 빈 값) → examId의 Task 현재 뱅크를 출제로 폴백', () {
    // presented 비어 있고 q2만 오답 → q1/q3는 정답으로 간주(같은 Task 출제).
    final idx = WrongAnswerIndex.build(
      certId: 'CLF-C02',
      taskByQuestionId: _tasks,
      history: [
        _rec(examId: 'practice:clf-t2-1', date: '2026-06-01',
            presented: [], wrong: ['clf-t2-1-q2']),
      ],
    );
    expect(idx.weakEntries().map((e) => e.questionId), ['clf-t2-1-q2']);
    expect(idx.entries.single.wrongCount, 1);
  });

  test('다른 certId 레코드는 무시', () {
    final other = AttemptRecord(
      certId: 'SAA-C03', examId: 'practice:saa-x', mode: 'practice',
      date: '2026-06-01', correct: 0, total: 1,
      wrongQuestionIds: const ['clf-t2-1-q1'], flaggedQuestionIds: const [],
      presentedQuestionIds: const ['clf-t2-1-q1'], durationSpentSec: 1,
    );
    final idx = WrongAnswerIndex.build(
      certId: 'CLF-C02', taskByQuestionId: _tasks, history: [other],
    );
    expect(idx.entries, isEmpty);
  });

  test('weakByTask는 Task별 weak 수 집계, lastSeen은 마지막 출제일', () {
    final idx = WrongAnswerIndex.build(
      certId: 'CLF-C02',
      taskByQuestionId: _tasks,
      history: [
        _rec(examId: 'practice:clf-t2-1', date: '2026-06-01',
            presented: ['clf-t2-1-q1', 'clf-t2-1-q2'],
            wrong: ['clf-t2-1-q1', 'clf-t2-1-q2']),
        _rec(examId: 'practice:clf-t3-1', date: '2026-06-05',
            presented: ['clf-t3-1-q1'], wrong: ['clf-t3-1-q1']),
      ],
    );
    expect(idx.weakByTask(), {'clf-t2-1': 2, 'clf-t3-1': 1});
    final t3 = idx.weakEntries('clf-t3-1').single;
    expect(t3.lastSeen, '2026-06-05');
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `flutter test test/wrong_answer_index_test.dart`
Expected: 컴파일 실패 — `wrong_answer_index.dart` 없음.

- [ ] **Step 3: 모듈 구현**

`flutter_app/lib/data/wrong_answer_index.dart` 생성:
```dart
import '../models/attempt_record.dart';

/// 약점 문항 상태: weak(미졸업) / mastered(서로 다른 응시 연속 2회 정답으로 졸업).
enum WrongStatus { weak, mastered }

/// 한 문항의 약점 파생 결과.
class WrongEntry {
  const WrongEntry({
    required this.questionId,
    required this.taskId,
    required this.certId,
    required this.wrongCount,
    required this.consecutiveCorrect,
    required this.lastSeen,
    required this.status,
  });
  final String questionId;
  final String taskId;
  final String certId;
  final int wrongCount;
  final int consecutiveCorrect;
  final String lastSeen; // 마지막으로 출제된 응시의 date(ISO)
  final WrongStatus status;
}

/// 응시 이력에서 "한 번이라도 틀린" 문항의 약점/졸업 상태를 파생하는 순수 인덱스.
/// 자산 로드는 호출측 책임 — [taskByQuestionId]는 현재 뱅크의 (문항ID→TaskID) 맵.
/// 이 맵에 없는 문항 = 개정으로 사라짐 → 결과에서 제외.
class WrongAnswerIndex {
  WrongAnswerIndex._(this.entries);

  /// "한 번이라도 틀린" 문항만. weak/mastered 모두 포함.
  final List<WrongEntry> entries;

  factory WrongAnswerIndex.build({
    required String certId,
    required List<AttemptRecord> history,
    required Map<String, String> taskByQuestionId,
  }) {
    final records = history.where((r) => r.certId == certId).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    // 문항별 정/오답 타임라인(date 오름차순) + 마지막 출제일.
    final timeline = <String, List<bool>>{}; // qid -> [correct?...]
    final lastSeen = <String, String>{};
    for (final r in records) {
      final wrongSet = r.wrongQuestionIds.toSet();
      for (final qid in _presentedOf(r, taskByQuestionId)) {
        if (!taskByQuestionId.containsKey(qid)) continue; // stale 제외
        (timeline[qid] ??= <bool>[]).add(!wrongSet.contains(qid));
        lastSeen[qid] = r.date;
      }
    }

    final entries = <WrongEntry>[];
    timeline.forEach((qid, results) {
      final wrongCount = results.where((ok) => !ok).length;
      if (wrongCount == 0) return; // 틀린 적 없으면 노트 대상 아님
      var consec = 0;
      for (var i = results.length - 1; i >= 0 && results[i]; i--) {
        consec++;
      }
      entries.add(WrongEntry(
        questionId: qid,
        taskId: taskByQuestionId[qid]!,
        certId: certId,
        wrongCount: wrongCount,
        consecutiveCorrect: consec,
        lastSeen: lastSeen[qid]!,
        status: consec >= 2 ? WrongStatus.mastered : WrongStatus.weak,
      ));
    });
    return WrongAnswerIndex._(entries);
  }

  /// Task별 weak 문항 수(배지용). mastered는 세지 않음.
  Map<String, int> weakByTask() {
    final m = <String, int>{};
    for (final e in entries) {
      if (e.status == WrongStatus.weak) {
        m[e.taskId] = (m[e.taskId] ?? 0) + 1;
      }
    }
    return m;
  }

  /// weak 엔트리(복습 큐). [taskId] 지정 시 해당 Task만.
  List<WrongEntry> weakEntries([String? taskId]) => [
        for (final e in entries)
          if (e.status == WrongStatus.weak &&
              (taskId == null || e.taskId == taskId))
            e,
      ];

  /// 한 응시에 출제된 문항 ID 집합. presentedQuestionIds가 있으면 그대로,
  /// 없으면(레거시) examId의 Task 현재 뱅크 전체로 폴백, 그것도 불가하면 오답만.
  static Iterable<String> _presentedOf(
      AttemptRecord r, Map<String, String> taskByQuestionId) {
    if (r.presentedQuestionIds.isNotEmpty) return r.presentedQuestionIds;
    final task = _taskFromExamId(r.examId);
    if (task == null) return r.wrongQuestionIds;
    final taskQs = [
      for (final e in taskByQuestionId.entries)
        if (e.value == task) e.key,
    ];
    return taskQs.isEmpty ? r.wrongQuestionIds : taskQs;
  }

  /// 'practice:clf-t2-1' / 'exam:clf-t2-1' / 'review:clf-t2-1' → 'clf-t2-1'.
  /// 통합 모의고사('exam:CLF-C02-mock')처럼 단일 Task가 아니면 null.
  static String? _taskFromExamId(String examId) {
    final i = examId.indexOf(':');
    if (i < 0) return null;
    final rest = examId.substring(i + 1);
    if (rest.isEmpty || rest.endsWith('-mock')) return null;
    return rest;
  }
}
```

- [ ] **Step 4: 테스트 통과 확인**

Run: `flutter test test/wrong_answer_index_test.dart`
Expected: 모든 테스트 PASS(9건).

- [ ] **Step 5: analyze + 전체 테스트**

PowerShell, `flutter_app`에서:
```
flutter analyze
flutter test
```
Expected: No issues found! / All tests passed.

- [ ] **Step 6: 커밋**

git 루트에서:
```
git -C D:/workspace/awc-docs add flutter_app/lib/data/wrong_answer_index.dart flutter_app/test/wrong_answer_index_test.dart
git -C D:/workspace/awc-docs commit -m "feat: WrongAnswerIndex 순수 집계 모듈(약점/졸업 파생, 9테스트)"
```

---

## Task 4: E1a 게이트 검증 + 핸드오프

**Files:** 핸드오프/메모리만.

- [ ] **Step 1: analyze + 전체 테스트 + 릴리스 빌드**

PowerShell, `flutter_app`에서:
```
flutter analyze
flutter test
flutter build web --release --base-href /aws-docs/
```
Expected: analyze 무결 · 전체 테스트 green(기존 41 + 신규: AttemptRecord 1, WrongAnswerIndex 9 = 51) · 빌드 성공.

- [ ] **Step 2: 핸드오프·메모리 현행화**

`docs/plans/2026-06-06-session-handoff.md`에 E1a 완료(데이터 기반: presentedQuestionIds·WrongAnswerIndex) 기록, 다음 = E1b(복습 UI). 크로스세션 메모리 `work-priority-roadmap-phase0.md`(또는 신규 E1 메모리)에 한 줄 반영. 커밋:
```
git -C D:/workspace/awc-docs add docs/plans/2026-06-06-session-handoff.md
git -C D:/workspace/awc-docs commit -m "docs: E1a 데이터 기반 완료 핸드오프 현행화(다음=E1b 복습 UI)"
```

- [ ] **Step 3: push 여부는 사용자 확인 후 (finishing-a-development-branch)**

---

## Self-Review (작성자 점검 완료)

- **스펙 커버리지:** E1 설계 §3.1(presentedQuestionIds)=Task 1, §3 작성자 갱신=Task 2, §4(WrongAnswerIndex: weak/mastered·weakByTask·weakEntries·stale 제외·레거시 폴백)=Task 3. UI(§5 ReviewView/ReviewListPage/배지)는 **E1b 별도 계획**으로 명시 분리.
- **플레이스홀더 스캔:** TBD/TODO 없음. 모든 코드 스텝에 실제 코드.
- **타입 일관성:** `WrongStatus`/`WrongEntry`/`WrongAnswerIndex.build({certId, history, taskByQuestionId})`/`weakByTask()`/`weakEntries([taskId])` 시그니처가 테스트(Task 3 Step 1)와 구현(Step 3)에서 동일. `AttemptRecord(presentedQuestionIds: ...)` named param이 Task 1 정의와 Task 2·3 사용에서 일치. 작성자는 `[for (final q in _qs) q.id]`로 출제 순서 보존.
- **회귀:** Task 1 필드 옵셔널(기본 `const []`) → 기존 직렬화/테스트 무영향. Task 2는 기존 테스트에 expect만 추가. Task 3은 순수 신규 모듈.
- **테스트 함정 회피:** 모두 순수 단위/모델주입 테스트 — SelectionArea 로더 페이지 렌더 없음. (UI 렌더는 E1b에서 ReviewView 모델주입 + dogfood.)
