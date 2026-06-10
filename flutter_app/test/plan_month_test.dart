import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/models/study_plan.dart';
import 'package:aws_docs/data/plan_month.dart';

PlanItem _it(String id, String date) => PlanItem(
    id: id, dateIso: date, type: PlanItemType.doc, phase: PlanPhase.learn);

StudyPlan _plan(List<PlanItem> items, {String start = '2026-06-10', String end = '2026-06-24', PlanMode mode = PlanMode.period}) =>
    StudyPlan(certCode: 'CLF-C02', startIso: start, endIso: end, mode: mode, createdIso: start, items: items);

void main() {
  test('한 달 안에 드는 플랜은 블록 1개, 일~토 7열', () {
    final plan = _plan([_it('a', '2026-06-10'), _it('b', '2026-06-10'), _it('c', '2026-06-13')]);
    final blocks = planMonthBlocks(plan, {'a': true, 'b': false, 'c': false});
    expect(blocks.length, 1);
    expect(blocks.first.year, 2026);
    expect(blocks.first.month, 6);
    for (final w in blocks.first.weeks) {
      expect(w.length, 7); // 모든 주는 7칸
    }
    // 기간 내 날들의 total 합 == 항목 수
    final inRangeTotal = blocks.expand((b) => b.weeks).expand((w) => w)
        .where((d) => d.dateIso != null && d.inRange).fold<int>(0, (s, d) => s + d.total);
    expect(inRangeTotal, 3);
    // 6/10 칸: total 2, done 1
    final d10 = blocks.expand((b) => b.weeks).expand((w) => w).firstWhere((d) => d.dateIso == '2026-06-10');
    expect(d10.total, 2);
    expect(d10.done, 1);
    expect(d10.inRange, isTrue);
  });

  test('기간 밖 같은 달 날짜는 inRange=false, 패딩 칸은 dateIso=null', () {
    final plan = _plan([_it('a', '2026-06-10')]);
    final cells = planMonthBlocks(plan, const {}).expand((b) => b.weeks).expand((w) => w).toList();
    final d05 = cells.firstWhere((d) => d.dateIso == '2026-06-05'); // 6월이지만 기간(6/10~) 밖
    expect(d05.inRange, isFalse);
    expect(d05.total, 0);
    expect(cells.any((d) => d.dateIso == null), isTrue); // 1일 앞 패딩 존재
  });

  test('여러 달에 걸치면 블록도 여러 개', () {
    final plan = _plan([_it('a', '2026-06-28'), _it('b', '2026-07-02')], start: '2026-06-25', end: '2026-07-05');
    final blocks = planMonthBlocks(plan, const {});
    expect(blocks.length, 2);
    expect(blocks[0].month, 6);
    expect(blocks[1].month, 7);
  });

  test('examDate 모드는 시험 전날까지가 기간', () {
    final plan = _plan([_it('a', '2026-06-23')], start: '2026-06-10', end: '2026-06-24', mode: PlanMode.examDate);
    final cells = planMonthBlocks(plan, const {}).expand((b) => b.weeks).expand((w) => w).toList();
    expect(cells.firstWhere((d) => d.dateIso == '2026-06-23').inRange, isTrue);  // 마지막 학습일
    expect(cells.firstWhere((d) => d.dateIso == '2026-06-24').inRange, isFalse); // 시험일은 기간 밖
  });

  test('연도 경계(12월→1월)도 블록 2개로 롤오버', () {
    final plan = _plan(
      [_it('a', '2026-12-30'), _it('b', '2027-01-02')],
      start: '2026-12-28', end: '2027-01-05');
    final blocks = planMonthBlocks(plan, const {});
    expect(blocks.length, 2);
    expect(blocks[0].year, 2026);
    expect(blocks[0].month, 12);
    expect(blocks[1].year, 2027);
    expect(blocks[1].month, 1);
    // 모든 주는 7칸
    for (final b in blocks) {
      for (final w in b.weeks) {
        expect(w.length, 7);
      }
    }
  });
}
