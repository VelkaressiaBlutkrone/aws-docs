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
    final tasks = {for (var i = 1; i <= 10; i++) 'clf-t9-1-q$i': 'clf-t9-1'};
    final qs = tasks.keys.toList();
    final r = TaskScoreReport.build(
      certId: 'CLF-C02', taskByQuestionId: tasks, taskOrder: const ['clf-t9-1'],
      history: [
        _rec(examId: 'practice:clf-t9-1', date: '2026-06-01',
            presented: qs, wrong: qs.sublist(7)), // 마지막 3개 오답 → 7/10
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
            presented: ['clf-t2-1-q1'], wrong: ['clf-t2-1-q1']),
        AttemptRecord(
            certId: 'SAA-C03', examId: 'practice:x', mode: 'practice',
            date: '2026-06-03', correct: 1, total: 1,
            wrongQuestionIds: const [], flaggedQuestionIds: const [],
            presentedQuestionIds: const ['clf-t2-1-q2'], durationSpentSec: 1),
      ],
    );
    // SAA 레코드의 clf-t2-1-q2는 certId 불일치라 미반영 → q1만(오답)
    final t = _byId(r, 'clf-t2-1');
    expect(t.attempted, 1);
    expect(t.correct, 0);
  });
}
