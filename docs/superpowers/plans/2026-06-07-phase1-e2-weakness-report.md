# Phase 1 · E2 — 약점 리포트 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 응시 이력을 처방전으로 — Task별 정답률 표(연습+시험, 복습 제외, 문항별 최신 결과 평균)를 `/cert/:code/report`에 보여주고, 약한 Task(<70%)에 학습문서 앵커 링크를 건다. 미응시 Task는 "미응시"로 구분.

**Architecture:** E1의 "출제 해석" 로직(presentedQuestionIds + 레거시 폴백 + examId→taskId)을 공유 헬퍼 `lib/data/attempt_presented.dart`로 추출하고 `WrongAnswerIndex`가 이를 쓰도록 변경(동작 동일, 9테스트 green). 신규 순수 모듈 `TaskScoreReport`가 이력 + `taskByQuestionId` + `taskOrder`로 Task별 최신-결과 정답률을 파생. 신규 `ReportPage`(로더, ReviewListPage 패턴)가 19뱅크 로드 후 표를 렌더. cert 상세에 "약점 리포트" 진입 추가. 라우트 `/cert/:code/report`.

**Tech Stack:** Flutter (Dart), go_router, 기존 `quiz_widgets`·테마 토큰 재사용. 외부 의존 추가 없음.

**경로:** 코드 = `D:\workspace\awc-docs\flutter_app`. flutter는 **PowerShell**로 `flutter_app`에서. git은 **`cd /d/workspace/awc-docs`**(Bash) 또는 절대 `-C`.

**스펙:** `docs/superpowers/specs/2026-06-07-learning-loop-e2-design.md`. **선행:** E1 완료(`wrong_answer_index.dart`, `presentedQuestionIds`, `review_page.dart`).

**테스트 함정:** `ReportPage`·`CertDetailPage`는 비동기 로더(+SelectionArea) → 렌더 테스트 금지. 순수 모듈은 단위 테스트, 페이지는 라우팅 redirect 테스트 + dogfood.

---

## 데이터 계약 (이 계획에서 확정)

- 공유 헬퍼(`lib/data/attempt_presented.dart`):
  - `Iterable<String> resolvePresented(AttemptRecord r, Map<String,String> taskByQuestionId)`
  - `String? taskFromExamId(String examId)`
- `TaskStatus { unattempted, weak, ok }`, `const double kWeakThreshold = 0.7;`
- `TaskScore { taskId, total, attempted, correct, rate(double?), status }`
- `TaskScoreReport.build({certId, history, taskByQuestionId, taskOrder})` → `.tasks`(taskOrder 순), `.attemptedTotal`, `.correctTotal`, `.overallRate`(double?), `.hasAnyAttempt`.
- 집계: `mode=='review'` 제외. 문항별 최신 결과(date 오름차순 마지막). rate = attempted==0 ? null : correct/attempted. status = attempted==0 ? unattempted : rate < kWeakThreshold ? weak : ok.

---

## Task 1: 공유 헬퍼 추출 (`attempt_presented.dart`) + WrongAnswerIndex 전환

E1 `WrongAnswerIndex`의 private `_presentedOf`/`_taskFromExamId`를 공유 모듈로 옮기고, `WrongAnswerIndex`가 이를 사용하도록 변경. **동작 동일 — 기존 9테스트 green이 검증.**

**Files:**
- Create: `flutter_app/lib/data/attempt_presented.dart`
- Modify: `flutter_app/lib/data/wrong_answer_index.dart`

- [ ] **Step 1: 기준선 — WrongAnswerIndex 테스트 green 확인**

PowerShell, `flutter_app`에서:
```
flutter test test/wrong_answer_index_test.dart
```
Expected: 9 테스트 PASS.

- [ ] **Step 2: 공유 헬퍼 모듈 생성**

`flutter_app/lib/data/attempt_presented.dart` 생성:
```dart
import '../models/attempt_record.dart';

/// 한 응시에 출제된 문항 ID 집합. presentedQuestionIds가 있으면 그대로,
/// 없으면(레거시) examId의 Task 현재 뱅크 전체로 폴백, 그것도 불가하면 오답만.
/// E1(WrongAnswerIndex)·E2(TaskScoreReport)가 공유 — "무엇이 출제됐나" 정의 단일화.
Iterable<String> resolvePresented(
    AttemptRecord r, Map<String, String> taskByQuestionId) {
  if (r.presentedQuestionIds.isNotEmpty) return r.presentedQuestionIds;
  final task = taskFromExamId(r.examId);
  if (task == null) return r.wrongQuestionIds;
  final taskQs = [
    for (final e in taskByQuestionId.entries)
      if (e.value == task) e.key,
  ];
  return taskQs.isEmpty ? r.wrongQuestionIds : taskQs;
}

/// 'practice:clf-t2-1' / 'exam:clf-t2-1' / 'review:clf-t2-1' → 'clf-t2-1'.
/// 통합 모의고사('exam:CLF-C02-mock')처럼 단일 Task가 아니면 null.
String? taskFromExamId(String examId) {
  final i = examId.indexOf(':');
  if (i < 0) return null;
  final rest = examId.substring(i + 1);
  if (rest.isEmpty || rest.endsWith('-mock')) return null;
  return rest;
}
```

- [ ] **Step 3: WrongAnswerIndex가 공유 헬퍼를 쓰도록 변경**

`flutter_app/lib/data/wrong_answer_index.dart`:

상단 import 추가:
```dart
import '../models/attempt_record.dart';
import 'attempt_presented.dart';
```

`build` 내부의 `for (final qid in _presentedOf(r, taskByQuestionId))`를 다음으로 교체:
```dart
      for (final qid in resolvePresented(r, taskByQuestionId)) {
```

파일 하단의 private static 메서드 `_presentedOf`와 `_taskFromExamId` **두 개를 삭제**(공유 헬퍼로 대체됨).

- [ ] **Step 4: WrongAnswerIndex 테스트 green 확인(회귀 0)**

Run: `flutter test test/wrong_answer_index_test.dart`
Expected: 9 테스트 PASS(동작 동일). analyze:
```
flutter analyze
```
Expected: 미사용 메서드/임포트 경고 없음, 이슈 0.

- [ ] **Step 5: 커밋**

```
cd /d/workspace/awc-docs && git add flutter_app/lib/data/attempt_presented.dart flutter_app/lib/data/wrong_answer_index.dart && git commit -m "refactor: 출제 해석 로직을 attempt_presented 공유 헬퍼로 추출(E1/E2 공용)"
```

---

## Task 2: `TaskScoreReport` 순수 집계 모듈

**Files:**
- Create: `flutter_app/lib/data/task_score_report.dart`
- Test: `flutter_app/test/task_score_report_test.dart`

- [ ] **Step 1: 실패하는 테스트 작성**

`flutter_app/test/task_score_report_test.dart` 생성:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/models/attempt_record.dart';
import 'package:aws_docs/data/task_score_report.dart';

const _tasks = {
  'clf-t2-1-q1': 'clf-t2-1',
  'clf-t2-1-q2': 'clf-t2-1',
  'clf-t2-1-q3': 'clf-t2-1',
  'clf-t3-1-q1': 'clf-t3-1',
};
const _order = ['clf-t2-1', 'clf-t3-1'];

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

TaskScore _byId(TaskScoreReport r, String taskId) =>
    r.tasks.firstWhere((t) => t.taskId == taskId);

void main() {
  test('이력 없으면 모든 Task 미응시 + hasAnyAttempt=false', () {
    final r = TaskScoreReport.build(
      certId: 'CLF-C02', history: const [], taskByQuestionId: _tasks,
      taskOrder: _order,
    );
    expect(r.tasks.map((t) => t.taskId), _order); // taskOrder 순
    expect(r.tasks.every((t) => t.status == TaskStatus.unattempted), isTrue);
    expect(_byId(r, 'clf-t2-1').rate, isNull);
    expect(r.hasAnyAttempt, isFalse);
    expect(r.overallRate, isNull);
  });

  test('문항별 최신 결과 평균 — 오답 후 정답이면 정답으로 갱신', () {
    final r = TaskScoreReport.build(
      certId: 'CLF-C02', taskByQuestionId: _tasks, taskOrder: _order,
      history: [
        _rec(examId: 'practice:clf-t2-1', date: '2026-06-01',
            presented: ['clf-t2-1-q1', 'clf-t2-1-q2'],
            wrong: ['clf-t2-1-q1', 'clf-t2-1-q2']), // 둘 다 오답
        _rec(examId: 'exam:clf-t2-1', date: '2026-06-02',
            presented: ['clf-t2-1-q1', 'clf-t2-1-q2'],
            wrong: ['clf-t2-1-q2']), // q1 정답으로 갱신, q2 여전히 오답
      ],
    );
    final t = _byId(r, 'clf-t2-1');
    expect(t.attempted, 2);
    expect(t.correct, 1); // q1 최신=정답, q2 최신=오답
    expect(t.rate, closeTo(0.5, 1e-9));
    expect(t.status, TaskStatus.weak);
  });

  test('review 모드는 정답률에 미반영', () {
    final r = TaskScoreReport.build(
      certId: 'CLF-C02', taskByQuestionId: _tasks, taskOrder: _order,
      history: [
        _rec(examId: 'practice:clf-t2-1', date: '2026-06-01',
            presented: ['clf-t2-1-q1'], wrong: ['clf-t2-1-q1']), // 오답
        _rec(examId: 'review:clf-t2-1', date: '2026-06-02', mode: 'review',
            presented: ['clf-t2-1-q1'], wrong: []), // 복습 정답 — 무시돼야
      ],
    );
    final t = _byId(r, 'clf-t2-1');
    expect(t.attempted, 1);
    expect(t.correct, 0); // 복습 정답 미반영 → 최신 결과는 practice 오답
    expect(t.status, TaskStatus.weak);
  });

  test('70% 경계 — 정확히 0.7은 ok, 미만은 weak', () {
    // 10문항 맵
    final tasks = {for (var i = 1; i <= 10; i++) 'clf-t9-1-q$i': 'clf-t9-1'};
    final qs = tasks.keys.toList();
    // 7정답 3오답 = 0.7 → ok
    final r = TaskScoreReport.build(
      certId: 'CLF-C02', taskByQuestionId: tasks, taskOrder: const ['clf-t9-1'],
      history: [
        _rec(examId: 'practice:clf-t9-1', date: '2026-06-01',
            presented: qs, wrong: qs.sublist(7)), // 마지막 3개 오답
      ],
    );
    final t = _byId(r, 'clf-t9-1');
    expect(t.rate, closeTo(0.7, 1e-9));
    expect(t.status, TaskStatus.ok);
  });

  test('미응시 문항은 attempted에서 제외(부분 응시)', () {
    final r = TaskScoreReport.build(
      certId: 'CLF-C02', taskByQuestionId: _tasks, taskOrder: _order,
      history: [
        _rec(examId: 'practice:clf-t2-1', date: '2026-06-01',
            presented: ['clf-t2-1-q1'], wrong: []), // q1만 응시·정답
      ],
    );
    final t = _byId(r, 'clf-t2-1');
    expect(t.total, 3);
    expect(t.attempted, 1);
    expect(t.correct, 1);
    expect(t.rate, closeTo(1.0, 1e-9));
    expect(t.status, TaskStatus.ok);
  });

  test('현재 뱅크에 없는 문항은 제외', () {
    final r = TaskScoreReport.build(
      certId: 'CLF-C02', taskByQuestionId: _tasks, taskOrder: _order,
      history: [
        _rec(examId: 'practice:clf-t2-1', date: '2026-06-01',
            presented: ['clf-t2-1-q9'], wrong: ['clf-t2-1-q9']), // q9 = 삭제됨
      ],
    );
    expect(_byId(r, 'clf-t2-1').attempted, 0);
    expect(_byId(r, 'clf-t2-1').status, TaskStatus.unattempted);
  });

  test('레거시 폴백 — presented 빈 값은 examId Task 현재 뱅크 출제로 간주', () {
    final r = TaskScoreReport.build(
      certId: 'CLF-C02', taskByQuestionId: _tasks, taskOrder: _order,
      history: [
        _rec(examId: 'practice:clf-t2-1', date: '2026-06-01',
            presented: [], wrong: ['clf-t2-1-q2']), // q1,q3 정답 / q2 오답
      ],
    );
    final t = _byId(r, 'clf-t2-1');
    expect(t.attempted, 3);
    expect(t.correct, 2);
  });

  test('overallRate/hasAnyAttempt 집계', () {
    final r = TaskScoreReport.build(
      certId: 'CLF-C02', taskByQuestionId: _tasks, taskOrder: _order,
      history: [
        _rec(examId: 'practice:clf-t2-1', date: '2026-06-01',
            presented: ['clf-t2-1-q1', 'clf-t2-1-q2'],
            wrong: ['clf-t2-1-q2']), // 1/2
        _rec(examId: 'practice:clf-t3-1', date: '2026-06-02',
            presented: ['clf-t3-1-q1'], wrong: []), // 1/1
      ],
    );
    expect(r.hasAnyAttempt, isTrue);
    expect(r.attemptedTotal, 3);
    expect(r.correctTotal, 2);
    expect(r.overallRate, closeTo(2 / 3, 1e-9));
  });

  test('다른 certId 이력은 무시', () {
    final r = TaskScoreReport.build(
      certId: 'CLF-C02', taskByQuestionId: _tasks, taskOrder: _order,
      history: [
        _rec(examId: 'practice:clf-t2-1', date: '2026-06-01',
            presented: ['clf-t2-1-q1'], wrong: ['clf-t2-1-q1'])
          ..toString(),
      ]..add(AttemptRecord(
          certId: 'SAA-C03', examId: 'practice:x', mode: 'practice',
          date: '2026-06-03', correct: 1, total: 1,
          wrongQuestionIds: const [], flaggedQuestionIds: const [],
          presentedQuestionIds: const ['clf-t2-1-q2'], durationSpentSec: 1)),
    );
    // SAA 레코드의 clf-t2-1-q2는 certId 불일치라 미반영 → q2는 미응시
    final t = _byId(r, 'clf-t2-1');
    expect(t.attempted, 1); // q1만(오답)
    expect(t.correct, 0);
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `flutter test test/task_score_report_test.dart`
Expected: 컴파일 실패 — `task_score_report.dart` 없음.

- [ ] **Step 3: 모듈 구현**

`flutter_app/lib/data/task_score_report.dart` 생성:
```dart
import '../models/attempt_record.dart';
import 'attempt_presented.dart';

/// 약점 임계값 — 정답률 70% 미만이면 weak(처방 대상).
const double kWeakThreshold = 0.7;

enum TaskStatus { unattempted, weak, ok }

/// 한 Task의 정답률 요약(문항별 최신 결과 기준).
class TaskScore {
  const TaskScore({
    required this.taskId,
    required this.total,
    required this.attempted,
    required this.correct,
    required this.rate,
    required this.status,
  });
  final String taskId;
  final int total; // 현재 검증 뱅크 문항 수
  final int attempted; // 최신 결과 보유(연습/시험 출제된) 문항 수
  final int correct; // 최신 결과가 정답인 문항 수
  final double? rate; // null = 미응시
  final TaskStatus status;
}

/// 응시 이력에서 Task별 정답률을 파생하는 순수 리포트. review 모드 제외.
/// 자산 로드는 호출측 책임([taskByQuestionId]·[taskOrder]는 현재 뱅크에서 구성).
class TaskScoreReport {
  TaskScoreReport._(this.tasks);
  final List<TaskScore> tasks; // taskOrder 순

  factory TaskScoreReport.build({
    required String certId,
    required List<AttemptRecord> history,
    required Map<String, String> taskByQuestionId,
    required List<String> taskOrder,
  }) {
    final records = history
        .where((r) => r.certId == certId && r.mode != 'review')
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    // 문항별 최신 결과(date 오름차순 마지막 값이 최신).
    final latest = <String, bool>{}; // qid -> 정답?
    for (final r in records) {
      final wrongSet = r.wrongQuestionIds.toSet();
      for (final qid in resolvePresented(r, taskByQuestionId)) {
        if (!taskByQuestionId.containsKey(qid)) continue; // stale 제외
        latest[qid] = !wrongSet.contains(qid);
      }
    }

    // Task별 total(현재 뱅크) 집계.
    final totalByTask = <String, int>{};
    taskByQuestionId.forEach((qid, taskId) {
      totalByTask[taskId] = (totalByTask[taskId] ?? 0) + 1;
    });

    final scores = <TaskScore>[];
    for (final taskId in taskOrder) {
      final qids = [
        for (final e in taskByQuestionId.entries)
          if (e.value == taskId) e.key,
      ];
      var attempted = 0;
      var correct = 0;
      for (final qid in qids) {
        final res = latest[qid];
        if (res == null) continue;
        attempted++;
        if (res) correct++;
      }
      final double? rate = attempted == 0 ? null : correct / attempted;
      final TaskStatus status = attempted == 0
          ? TaskStatus.unattempted
          : (rate! < kWeakThreshold ? TaskStatus.weak : TaskStatus.ok);
      scores.add(TaskScore(
        taskId: taskId,
        total: totalByTask[taskId] ?? 0,
        attempted: attempted,
        correct: correct,
        rate: rate,
        status: status,
      ));
    }
    return TaskScoreReport._(scores);
  }

  int get attemptedTotal =>
      tasks.fold(0, (a, t) => a + t.attempted);
  int get correctTotal => tasks.fold(0, (a, t) => a + t.correct);
  bool get hasAnyAttempt => attemptedTotal > 0;
  double? get overallRate =>
      attemptedTotal == 0 ? null : correctTotal / attemptedTotal;
}
```

- [ ] **Step 4: 테스트 통과 확인**

Run: `flutter test test/task_score_report_test.dart`
Expected: 모든 테스트 PASS(9건).

- [ ] **Step 5: analyze + 전체 테스트**

```
flutter analyze
flutter test
```
Expected: 이슈 0, 전체 green.

- [ ] **Step 6: 커밋**

```
cd /d/workspace/awc-docs && git add flutter_app/lib/data/task_score_report.dart flutter_app/test/task_score_report_test.dart && git commit -m "feat: TaskScoreReport 순수 집계(문항별 최신결과 평균, review 제외, 9테스트)"
```

---

## Task 3: `ReportPage` + 라우트

**Files:**
- Create: `flutter_app/lib/pages/report_page.dart`
- Modify: `flutter_app/lib/app_router.dart`
- Test: `flutter_app/test/app_router_test.dart`

- [ ] **Step 1: `report_page.dart` 작성**

`flutter_app/lib/pages/report_page.dart` 생성:
```dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:go_router/go_router.dart';

import '../data/content_index.dart';
import '../data/history_store.dart';
import '../data/task_score_report.dart';
import '../models/certification.dart';
import '../models/question.dart';
import '../theme/app_theme.dart';

/// 약점 리포트: cert의 Task별 정답률 표 + 70% 미만 Task 학습문서 처방.
class ReportPage extends StatefulWidget {
  const ReportPage({super.key, required this.cert});
  final Certification cert;

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final _history = HistoryStore();
  late final Future<_ReportLoad> _future = _load();

  Future<_ReportLoad> _load() async {
    final entries = contentFor(widget.cert.code);
    final taskByQuestionId = <String, String>{};
    final taskTitleById = <String, String>{};
    final taskOrder = <String>[];
    for (final e in entries) {
      taskTitleById[e.taskId] = e.title;
      taskOrder.add(e.taskId);
      try {
        final raw = await rootBundle.loadString(e.questionsAsset);
        final bank =
            QuestionBank.fromJson(json.decode(raw) as Map<String, dynamic>);
        for (final q in bank.questions) {
          taskByQuestionId[q.id] = e.taskId;
        }
      } catch (_) {}
    }
    final report = TaskScoreReport.build(
      certId: widget.cert.code,
      history: _history.all(),
      taskByQuestionId: taskByQuestionId,
      taskOrder: taskOrder,
    );
    return _ReportLoad(report: report, taskTitleById: taskTitleById);
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
        title: Text('${widget.cert.title} · 약점 리포트',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      body: FutureBuilder<_ReportLoad>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snap.data;
          if (snap.hasError || data == null) {
            return Center(
                child: Text('리포트를 불러오지 못했습니다.',
                    style: TextStyle(color: c.textMuted)));
          }
          return _body(data);
        },
      ),
    );
  }

  Widget _body(_ReportLoad d) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    final r = d.report;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Gap.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('약점 리포트', style: t.headlineSmall),
              const SizedBox(height: Gap.sm),
              Text('연습·시험에서의 문항별 최신 결과로 Task별 정답률을 계산합니다(복습 제외).',
                  style: t.bodyMedium),
              const SizedBox(height: Gap.lg),
              if (!r.hasAnyAttempt)
                _empty(c, t)
              else ...[
                _summary(c, t, r),
                const SizedBox(height: Gap.lg),
                for (final s in r.tasks) _row(c, t, d, s),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _empty(AppColors c, TextTheme t) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Gap.xl),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(color: c.border),
        ),
        child: Text('모의고사나 연습을 풀면 Task별 약점이 여기 표시됩니다.',
            style: t.bodyMedium?.copyWith(color: c.text)),
      );

  Widget _summary(AppColors c, TextTheme t, TaskScoreReport r) {
    final pct = ((r.overallRate ?? 0) * 100).round();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Gap.lg),
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          Text('전체 정답률',
              style: t.labelLarge?.copyWith(color: c.textMuted)),
          const SizedBox(width: Gap.md),
          Text('$pct%',
              style: t.titleLarge?.copyWith(
                  color: c.accent,
                  fontFamily: AppTheme.monoFamily)),
          const Spacer(),
          Text('응시 ${r.correctTotal}/${r.attemptedTotal} 문항',
              style: t.labelLarge?.copyWith(color: c.textMuted)),
        ],
      ),
    );
  }

  Widget _row(AppColors c, TextTheme t, _ReportLoad d, TaskScore s) {
    final title = d.taskTitleById[s.taskId] ?? s.taskId;
    final isWeak = s.status == TaskStatus.weak;
    final isUnattempted = s.status == TaskStatus.unattempted;
    final Color tone = isUnattempted
        ? c.textFaint
        : (isWeak ? c.wrong : c.correct);
    final String rateLabel = isUnattempted
        ? '미응시'
        : '정답률 ${((s.rate ?? 0) * 100).round()}%';
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.sm),
      child: Container(
        padding: const EdgeInsets.all(Gap.lg),
        decoration: BoxDecoration(
          color: isWeak ? c.wrongWeak : c.surface,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(color: isWeak ? c.wrong.withValues(alpha: 0.35) : c.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: t.titleMedium)),
                const SizedBox(width: Gap.md),
                Text(rateLabel,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: tone)),
              ],
            ),
            const SizedBox(height: Gap.xs),
            Row(
              children: [
                Text(
                    isUnattempted
                        ? '총 ${s.total}문항'
                        : '응시 ${s.attempted}/${s.total}문항',
                    style: t.labelSmall?.copyWith(color: c.textFaint)),
                const Spacer(),
                if (isWeak)
                  InkWell(
                    onTap: () => context
                        .push('/cert/${widget.cert.code}/study/${s.taskId}'),
                    child: Text('학습문서 →',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: c.accent)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 로드 결과(리포트 + Task 제목 조회).
class _ReportLoad {
  const _ReportLoad({required this.report, required this.taskTitleById});
  final TaskScoreReport report;
  final Map<String, String> taskTitleById;
}
```

- [ ] **Step 2: 라우트 추가**

`flutter_app/lib/app_router.dart` import 추가:
```dart
import 'pages/report_page.dart';
```
`cert/:code`의 `routes:`에서 `review` GoRoute 다음에 추가:
```dart
                GoRoute(
                  path: 'report',
                  builder: (context, state) =>
                      ReportPage(cert: certByCode(state.pathParameters['code']!)!),
                ),
```

- [ ] **Step 3: 라우팅 테스트 추가(redirect만)**

`flutter_app/test/app_router_test.dart`에 추가:
```dart
  testWidgets('잘못된 cert report 경로 → "/"로 redirect', (tester) async {
    await tester.pumpWidget(_app('/cert/NOPE/report'));
    await tester.pump();
    expect(find.byType(HomePage), findsOneWidget);
  });
```

- [ ] **Step 4: analyze + 전체 테스트**

```
flutter analyze
flutter test
```
Expected: 이슈 0, 전체 green.

- [ ] **Step 5: 커밋**

```
cd /d/workspace/awc-docs && git add flutter_app/lib/pages/report_page.dart flutter_app/lib/app_router.dart flutter_app/test/app_router_test.dart && git commit -m "feat: 약점 리포트 ReportPage + /cert/:code/report 라우트"
```

---

## Task 4: cert 상세 "약점 리포트" 진입

**Files:**
- Modify: `flutter_app/lib/pages/cert_detail_page.dart`

- [ ] **Step 1: 학습 콘텐츠 섹션에 약점 리포트 진입 추가**

`_LearningContent.build`에서 오답노트 진입(`if (weakByTask.values.fold(...) > 0) ...`) **바로 위**에, 콘텐츠가 있으면 항상 노출되는 약점 리포트 진입을 추가. 오답노트 진입 Padding 직전에 삽입:
```dart
          Padding(
            padding: const EdgeInsets.only(top: Gap.xs),
            child: InkWell(
              onTap: () =>
                  context.push('/cert/${entries.first.certCode}/report'),
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
                    Icon(Icons.insights_outlined, size: 18, color: c.accent),
                    const SizedBox(width: Gap.sm),
                    Expanded(
                      child: Text('약점 리포트 · Task별 정답률 보기',
                          style: t.titleMedium?.copyWith(color: c.text)),
                    ),
                    Text('리포트 →',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: c.accent)),
                  ],
                ),
              ),
            ),
          ),
```
(주의: 이 블록은 `for (final e in entries) ...` 루프 **뒤**, 오답노트 진입 `if (...)` **앞**에 위치. `t`·`c`는 `_LearningContent.build` 상단에서 이미 정의됨.)

- [ ] **Step 2: analyze + 전체 테스트**

```
flutter analyze
flutter test
```
Expected: 이슈 0, 전체 green.

- [ ] **Step 3: 커밋**

```
cd /d/workspace/awc-docs && git add flutter_app/lib/pages/cert_detail_page.dart && git commit -m "feat: cert 상세에 약점 리포트 진입 추가"
```

---

## Task 5: 게이트 검증 + dogfood + 핸드오프

- [ ] **Step 1: analyze + 전체 테스트 + 릴리스 빌드**

PowerShell, `flutter_app`에서:
```
flutter analyze
flutter test
flutter build web --release --base-href /aws-docs/
```
Expected: analyze 무결 · 전체 green(E1 53 + TaskScoreReport 9 ≈ 63, "모두 green"이 본질) · 빌드 성공.

- [ ] **Step 2: headless dogfood**

PowerShell, `flutter_app`에서:
```
flutter build web --base-href /
py -m http.server 5151 --directory build\web   # 별도 창/백그라운드
```
gstack browse(또는 수동)로:
1. 오답 이력 주입(localStorage `awsdocs.history.v1`): t2-1 일부 오답 + 다른 Task 정답 1건.
2. `http://localhost:5151/#/cert/CLF-C02` → 학습 콘텐츠 섹션에 **"약점 리포트 · Task별 정답률 보기"** 진입 노출.
3. 진입 → `/report`: 요약(전체 정답률) + Task 표 — weak Task는 wrong 톤 + **"학습문서 →"**, ok는 correct 톤, 미응시는 muted.
4. weak 행 "학습문서 →" 클릭 → 해당 `/cert/CLF-C02/study/:taskId`로 이동.
5. 이력 비우고 재방문 → 빈 상태 메시지.

dogfood 불가 시 Step 1로 최소 게이트, 수동 확인 메모.

- [ ] **Step 3: 핸드오프·메모리 현행화**

`docs/plans/2026-06-06-session-handoff.md`: E2(약점 리포트) 완료, Phase 1(E1+E2) 종료, 다음 = Phase 2(E5 진행률 + E6 가중 모의고사). 메모리(`work-priority-roadmap-phase0.md`) 반영. 커밋:
```
cd /d/workspace/awc-docs && git add docs/plans/2026-06-06-session-handoff.md && git commit -m "docs: E2 약점 리포트 완료 핸드오프 현행화(Phase 1 종료, 다음=Phase 2)"
```

- [ ] **Step 4: push는 finishing-a-development-branch로 사용자 확인 후**

---

## Self-Review (작성자 점검 완료)

- **스펙 커버리지:** §3 집계(문항별 최신결과·review 제외·미응시·70%·stale·레거시)=Task 2, §6 공유 헬퍼=Task 1, §4 ReportPage(요약·표·weak 링크·빈 상태)=Task 3, §4.1 라우트=Task 3, §4.2 cert 상세 진입=Task 4. §5 강등=빈 상태로 처리(매핑 없으면 빈 표)=Task 3 빈 상태. §8 테스트 분담 반영.
- **플레이스홀더 스캔:** TBD/TODO 없음. 모든 코드 스텝에 실제 코드.
- **타입 일관성:** `resolvePresented`/`taskFromExamId`가 Task 1 정의·Task 2 사용에서 일치. `TaskStatus`/`TaskScore`/`TaskScoreReport.build({certId, history, taskByQuestionId, taskOrder})`/`overallRate`/`hasAnyAttempt`/`attemptedTotal`/`correctTotal`가 테스트(Task 2 Step 1)·구현(Step 3)·ReportPage(Task 3)에서 동일. `kWeakThreshold` 공유. `ReportPage(cert:)` 생성자가 라우트 빌더와 일치.
- **회귀:** Task 1은 동작 보존 리팩터(9테스트가 가드). Task 3·4는 신규 화면/진입(기존 테스트 무영향). cert 상세 진입은 콘텐츠 존재 시 노출(빈 cert 영향 없음).
- **테스트 함정:** 순수 모듈만 단위 테스트. ReportPage/CertDetailPage는 라우팅 redirect + dogfood. SelectionArea 렌더 금지 준수.
