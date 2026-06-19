import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/models/attempt_record.dart';
import 'package:aws_docs/models/study_plan.dart';
import 'package:aws_docs/data/plan_progress.dart';

AttemptRecord _rec(String examId,
        {String mode = 'exam', String cert = 'CLF-C02'}) =>
    AttemptRecord(
      certId: cert,
      examId: examId,
      mode: mode,
      date: '2026-06-15T10:00:00.000',
      correct: 1,
      total: 1,
      wrongQuestionIds: const [],
      flaggedQuestionIds: const [],
      durationSpentSec: 60,
    );

PlanItem _it(String id, PlanItemType type,
        {String? ref, String date = '2026-06-12'}) =>
    PlanItem(id: id, dateIso: date, type: type, phase: PlanPhase.learn, refId: ref);

StudyPlan _plan(List<PlanItem> items) => StudyPlan(
      certCode: 'CLF-C02',
      startIso: '2026-06-10',
      endIso: '2026-06-24',
      mode: PlanMode.period,
      createdIso: '2026-06-10',
      items: items,
    );

void main() {
  test('doc는 done 집합으로만 완료(전역 열람과 독립)', () {
    final plan = _plan([
      _it('d1', PlanItemType.doc, ref: 'clf-t1-1'),
      _it('d2', PlanItemType.doc, ref: 'clf-t1-2'),
    ]);
    final done = computePlanDone(plan, done: {'d1'}, history: const []);
    expect(done['d1'], isTrue);
    expect(done['d2'], isFalse);
  });

  test('quiz는 done 또는 연습 이력으로 완료(done 우선)', () {
    final plan = _plan([
      _it('q1', PlanItemType.quiz, ref: 'clf-t1-1'),
      _it('q2', PlanItemType.quiz, ref: 'clf-t1-2'),
    ]);
    final done = computePlanDone(plan,
        done: const {}, history: [_rec('practice:clf-t1-1', mode: 'practice')]);
    expect(done['q1'], isTrue); // 연습 이력 폴백
    expect(done['q2'], isFalse);
    final done2 = computePlanDone(plan, done: {'q2'}, history: const []);
    expect(done2['q2'], isTrue); // done 우선
  });

  test('모의고사는 횟수 기반(done 없을 때): 응시 2회면 앞 2개', () {
    final plan = _plan([
      _it('m0', PlanItemType.mockExam, date: '2026-06-18'),
      _it('m1', PlanItemType.mockExam, date: '2026-06-19'),
      _it('m2', PlanItemType.mockExam, date: '2026-06-20'),
    ]);
    final done = computePlanDone(plan,
        done: const {},
        history: [_rec('exam:CLF-C02-mock'), _rec('exam:CLF-C02-mock')]);
    expect(done['m0'], isTrue);
    expect(done['m1'], isTrue);
    expect(done['m2'], isFalse);
  });

  test('weakExam·finalReview 자동 감지', () {
    final plan = _plan([
      _it('w', PlanItemType.weakExam, date: '2026-06-22'),
      _it('fr', PlanItemType.finalReview, date: '2026-06-23'),
    ]);
    final done = computePlanDone(plan, done: const {}, history: [
      _rec('exam:CLF-C02-weak'),
      _rec('review:clf-t1-1', mode: 'review')
    ]);
    expect(done['w'], isTrue);
    expect(done['fr'], isTrue);
  });

  test('done이 시험류 자동 감지보다 우선', () {
    final plan = _plan([_it('m0', PlanItemType.mockExam, date: '2026-06-18')]);
    final done = computePlanDone(plan, done: {'m0'}, history: const []);
    expect(done['m0'], isTrue); // 응시 0이지만 done 우선
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
    expect(r.today, 1); // c
    expect(r.overdue, 1); // a
  });

  test('플랜 생성 전 응시는 카운트 안 함(사전 이력 오염 방지)', () {
    final plan = _plan([_it('m0', PlanItemType.mockExam, date: '2026-06-18')]);
    final before = computePlanDone(plan, done: const {}, history: [
      AttemptRecord(
          certId: 'CLF-C02',
          examId: 'exam:CLF-C02-mock',
          mode: 'exam',
          date: '2026-06-05T10:00:00.000',
          correct: 1,
          total: 1,
          wrongQuestionIds: const [],
          flaggedQuestionIds: const [],
          durationSpentSec: 60),
    ]);
    expect(before['m0'], isFalse); // 생성(6/10) 전(6/5) → 미카운트

    final after = computePlanDone(plan, done: const {}, history: [
      AttemptRecord(
          certId: 'CLF-C02',
          examId: 'exam:CLF-C02-mock',
          mode: 'exam',
          date: '2026-06-12T10:00:00.000',
          correct: 1,
          total: 1,
          wrongQuestionIds: const [],
          flaggedQuestionIds: const [],
          durationSpentSec: 60),
    ]);
    expect(after['m0'], isTrue); // 생성 후(6/12) → 카운트
  });
}
