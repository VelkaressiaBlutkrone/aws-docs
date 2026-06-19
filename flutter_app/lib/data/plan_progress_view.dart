import '../models/attempt_record.dart';
import '../models/study_plan.dart';
import 'plan_progress.dart';
import 'plan_progress_store.dart';

/// 일정별 진행(PlanProgressStore)을 computePlanDone에 연결하는 공통 헬퍼.
/// home 요약·배너·어젠다가 planId 스코프 진행을 일관되게 계산하도록 한다.
Map<String, bool> planDone(
  StudyPlan plan,
  PlanProgressStore progress,
  List<AttemptRecord> history,
) =>
    computePlanDone(plan, done: progress.donePlan(plan.id), history: history);
