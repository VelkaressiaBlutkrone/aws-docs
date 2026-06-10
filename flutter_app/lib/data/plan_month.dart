import '../models/study_plan.dart';
import 'plan_scheduler.dart' show addDays, daysBetween;

/// 월 그리드 한 칸. dateIso==null이면 빈 패딩 칸.
class MonthDay {
  const MonthDay({this.dateIso, required this.inRange, required this.total, required this.done});
  final String? dateIso;
  final bool inRange; // 플랜 기간 [start, lastDay] 내
  final int total;    // 그 날 항목 수
  final int done;     // 그 날 완료 수
}

/// 한 달 블록 — 일~토 7열 주(week) 리스트.
class MonthBlock {
  const MonthBlock({required this.year, required this.month, required this.weeks});
  final int year;
  final int month;
  final List<List<MonthDay>> weeks;
}

DateTime _d(String iso) {
  final p = iso.split('-');
  return DateTime.utc(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
}

/// 플랜 기간이 걸치는 달들을 일~토 7열 그리드로(순수·결정적).
List<MonthBlock> planMonthBlocks(StudyPlan plan, Map<String, bool> done) {
  final lastDay = plan.mode == PlanMode.examDate ? addDays(plan.endIso, -1) : plan.endIso;
  if (plan.startIso.isEmpty || plan.endIso.isEmpty || daysBetween(plan.startIso, lastDay) < 0) {
    return const [];
  }

  // 날짜별 total/done 집계.
  final totalByDate = <String, int>{};
  final doneByDate = <String, int>{};
  for (final it in plan.items) {
    totalByDate[it.dateIso] = (totalByDate[it.dateIso] ?? 0) + 1;
    if (done[it.id] == true) doneByDate[it.dateIso] = (doneByDate[it.dateIso] ?? 0) + 1;
  }

  String isoStr(int y, int m, int d) =>
      '${y.toString().padLeft(4, '0')}-${m.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}';

  final startD = _d(plan.startIso);
  final lastD = _d(lastDay);

  final blocks = <MonthBlock>[];
  var y = startD.year, m = startD.month;
  while (y < lastD.year || (y == lastD.year && m <= lastD.month)) {
    final daysInMonth = DateTime.utc(y, m + 1, 0).day;
    final leadPad = DateTime.utc(y, m, 1).weekday % 7; // Mon=1..Sun=7 → Sun=0..Sat=6
    final cells = <MonthDay>[];
    for (var i = 0; i < leadPad; i++) {
      cells.add(const MonthDay(dateIso: null, inRange: false, total: 0, done: 0));
    }
    for (var day = 1; day <= daysInMonth; day++) {
      final iso = isoStr(y, m, day);
      final inRange = iso.compareTo(plan.startIso) >= 0 && iso.compareTo(lastDay) <= 0;
      cells.add(MonthDay(
        dateIso: iso,
        inRange: inRange,
        total: totalByDate[iso] ?? 0,
        done: doneByDate[iso] ?? 0,
      ));
    }
    while (cells.length % 7 != 0) {
      cells.add(const MonthDay(dateIso: null, inRange: false, total: 0, done: 0));
    }
    final weeks = <List<MonthDay>>[];
    for (var i = 0; i < cells.length; i += 7) {
      weeks.add(cells.sublist(i, i + 7));
    }
    blocks.add(MonthBlock(year: y, month: m, weeks: weeks));

    m++;
    if (m > 12) { m = 1; y++; }
  }
  return blocks;
}
