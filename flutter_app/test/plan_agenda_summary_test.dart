import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/models/study_plan.dart';
import 'package:aws_docs/pages/plan_page.dart' show planSummary, PlanSummary;

PlanItem _it(String id, {String date = '2026-06-12'}) => PlanItem(
    id: id, dateIso: date, type: PlanItemType.doc, phase: PlanPhase.learn);

void main() {
  test('진행률·남은 일수·완료수', () {
    final plan = StudyPlan(
      certCode: 'CLF-C02', startIso: '2026-06-10', endIso: '2026-06-24',
      mode: PlanMode.examDate, createdIso: '2026-06-10',
      items: [_it('a'), _it('b'), _it('c', date: '2026-06-13')],
    );
    final s = planSummary(plan, {'a': true, 'b': false, 'c': true}, '2026-06-12');
    expect(s.total, 3);
    expect(s.done, 2);
    expect(s.percent, 67); // round(2/3*100)
    expect(s.daysLeft, 12); // 6/24 - 6/12
  });

  test('빈 플랜은 0%', () {
    final plan = StudyPlan(
      certCode: 'CLF-C02', startIso: '2026-06-10', endIso: '2026-06-10',
      mode: PlanMode.period, createdIso: '2026-06-10', items: const []);
    final s = planSummary(plan, const {}, '2026-06-10');
    expect(s.percent, 0);
    expect(s.daysLeft, 0);
  });

  test('만료된 플랜은 daysLeft=0', () {
    final plan = StudyPlan(
      certCode: 'CLF-C02', startIso: '2026-06-01', endIso: '2026-06-09',
      mode: PlanMode.period, createdIso: '2026-06-01', items: [_it('a')]);
    final s = planSummary(plan, const {}, '2026-06-10');
    expect(s.daysLeft, 0);
  });

  test('전부 완료면 100%', () {
    final plan = StudyPlan(
      certCode: 'CLF-C02', startIso: '2026-06-10', endIso: '2026-06-24',
      mode: PlanMode.period, createdIso: '2026-06-10',
      items: [_it('a'), _it('b')]);
    final s = planSummary(plan, {'a': true, 'b': true}, '2026-06-12');
    expect(s.percent, 100);
    expect(s.done, 2);
  });
}
