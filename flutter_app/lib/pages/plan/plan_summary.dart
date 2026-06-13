import '../../data/plan_scheduler.dart';
import '../../models/study_plan.dart';

/// 어젠다 헤더용 순수 요약(PR4 분해 — plan_page.dart에서 이동,
/// plan_page가 re-export해 기존 테스트 import 경로 유지).
class PlanSummary {
  const PlanSummary(
      {required this.total, required this.done, required this.percent, required this.daysLeft});
  final int total;
  final int done;
  final int percent;
  final int daysLeft;
}

PlanSummary planSummary(StudyPlan plan, Map<String, bool> done, String todayIso) {
  final total = plan.items.length;
  final d = plan.items.where((i) => done[i.id] == true).length;
  final pct = total == 0 ? 0 : (d / total * 100).round();
  final left = daysBetween(todayIso, plan.endIso);
  return PlanSummary(total: total, done: d, percent: pct, daysLeft: left < 0 ? 0 : left);
}
