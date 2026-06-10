import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/models/attempt_record.dart';
import 'package:aws_docs/models/study_plan.dart';
import 'package:aws_docs/data/plan_progress.dart';

AttemptRecord _rec(String examId, {String mode = 'exam', String cert = 'CLF-C02'}) =>
    AttemptRecord(
      certId: cert, examId: examId, mode: mode, date: '2026-06-15T10:00:00.000',
      correct: 1, total: 1, wrongQuestionIds: const [], flaggedQuestionIds: const [],
      durationSpentSec: 60,
    );

PlanItem _it(String id, PlanItemType type, {String? ref, String date = '2026-06-12'}) =>
    PlanItem(id: id, dateIso: date, type: type, phase: PlanPhase.learn, refId: ref);

StudyPlan _plan(List<PlanItem> items) => StudyPlan(
      certCode: 'CLF-C02', startIso: '2026-06-10', endIso: '2026-06-24',
      mode: PlanMode.period, createdIso: '2026-06-10', items: items,
    );

void main() {
  test('doc는 열람으로, quiz는 연습 이력으로 자동 완료', () {
    final plan = _plan([
      _it('d1', PlanItemType.doc, ref: 'clf-t1-1'),
      _it('d2', PlanItemType.doc, ref: 'clf-t1-2'),
      _it('q1', PlanItemType.quiz, ref: 'clf-t1-1'),
    ]);
    final done = computePlanDone(plan,
      manual: const {},
      viewedTaskIds: {'clf-t1-1'},
      history: [_rec('practice:clf-t1-1', mode: 'practice')],
    );
    expect(done['d1'], isTrue);
    expect(done['d2'], isFalse);
    expect(done['q1'], isTrue);
  });

  test('모의고사는 횟수 기반: 응시 2회면 앞 2개만 완료', () {
    final plan = _plan([
      _it('m0', PlanItemType.mockExam, date: '2026-06-18'),
      _it('m1', PlanItemType.mockExam, date: '2026-06-19'),
      _it('m2', PlanItemType.mockExam, date: '2026-06-20'),
    ]);
    final done = computePlanDone(plan,
      manual: const {}, viewedTaskIds: const {},
      history: [_rec('exam:CLF-C02-mock'), _rec('exam:CLF-C02-mock')],
    );
    expect(done['m0'], isTrue);
    expect(done['m1'], isTrue);
    expect(done['m2'], isFalse);
  });

  test('수동 오버라이드가 자동을 덮어씀', () {
    final plan = _plan([_it('d1', PlanItemType.doc, ref: 'clf-t1-1')]);
    final done = computePlanDone(plan,
      manual: const {'d1': true}, viewedTaskIds: const {}, history: const []);
    expect(done['d1'], isTrue);
  });

  test('weakExam·finalReview 자동 감지', () {
    final plan = _plan([
      _it('w', PlanItemType.weakExam, date: '2026-06-22'),
      _it('fr', PlanItemType.finalReview, date: '2026-06-23'),
    ]);
    final done = computePlanDone(plan,
      manual: const {}, viewedTaskIds: const {},
      history: [_rec('exam:CLF-C02-weak'), _rec('review:clf-t1-1', mode: 'review')]);
    expect(done['w'], isTrue);
    expect(done['fr'], isTrue);
  });

  test('manual=false는 랭크 슬롯을 소비하지 않음 — 뒤 항목이 자동 완료', () {
    final plan = _plan([
      _it('m0', PlanItemType.mockExam, date: '2026-06-18'),
      _it('m1', PlanItemType.mockExam, date: '2026-06-19'),
      _it('m2', PlanItemType.mockExam, date: '2026-06-20'),
    ]);
    final done = computePlanDone(plan,
      manual: const {'m1': false},
      viewedTaskIds: const {},
      history: [
        _rec('exam:CLF-C02-mock'),
        _rec('exam:CLF-C02-mock'),
        _rec('exam:CLF-C02-mock'),
      ],
    );
    expect(done['m0'], isTrue); // rank 0 < 3
    expect(done['m1'], isFalse); // 수동 강제 미완
    expect(done['m2'], isTrue); // rank 1 < 3
  });

  test('isOverdue: 미완 + 과거', () {
    final it = _it('d1', PlanItemType.doc, date: '2026-06-12');
    expect(isOverdue(it, '2026-06-15', false), isTrue);
    expect(isOverdue(it, '2026-06-15', true), isFalse);
    expect(isOverdue(it, '2026-06-10', false), isFalse);
    expect(isOverdue(it, '2026-06-12', false), isFalse); // 당일은 밀림 아님
  });

  test('planDueCounts: 오늘·밀림 미완만 카운트', () {
    final plan = _plan([
      _it('a', PlanItemType.doc, date: '2026-06-09'), // 과거 → 밀림
      _it('b', PlanItemType.doc, date: '2026-06-10'), // 오늘
      _it('c', PlanItemType.doc, date: '2026-06-10'), // 오늘
      _it('d', PlanItemType.doc, date: '2026-06-11'), // 미래(제외)
    ]);
    final r = planDueCounts(plan, {'b': true}, '2026-06-10'); // b 완료
    expect(r.today, 1);   // c (b는 완료라 제외)
    expect(r.overdue, 1); // a
  });

  test('플랜 생성 전 응시는 카운트 안 함(사전 이력 오염 방지)', () {
    final plan = _plan([
      _it('m0', PlanItemType.mockExam, date: '2026-06-18'),
    ]);
    // plan.createdIso = '2026-06-10' (from _plan helper)
    final before = computePlanDone(plan,
      manual: const {}, viewedTaskIds: const {},
      history: [
        AttemptRecord(
          certId: 'CLF-C02', examId: 'exam:CLF-C02-mock', mode: 'exam',
          date: '2026-06-05T10:00:00.000', correct: 1, total: 1,
          wrongQuestionIds: const [], flaggedQuestionIds: const [], durationSpentSec: 60),
      ],
    );
    expect(before['m0'], isFalse); // 생성(6/10) 전(6/5) 응시 → 미카운트

    final after = computePlanDone(plan,
      manual: const {}, viewedTaskIds: const {},
      history: [
        AttemptRecord(
          certId: 'CLF-C02', examId: 'exam:CLF-C02-mock', mode: 'exam',
          date: '2026-06-12T10:00:00.000', correct: 1, total: 1,
          wrongQuestionIds: const [], flaggedQuestionIds: const [], durationSpentSec: 60),
      ],
    );
    expect(after['m0'], isTrue); // 생성 후(6/12) 응시 → 카운트
  });
}
