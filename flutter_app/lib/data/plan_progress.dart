import '../models/attempt_record.dart';
import '../models/study_plan.dart';
import 'attempt_presented.dart';

/// 플랜 항목별 완료 여부(순수). 수동 오버라이드 우선, 없으면 자동 감지.
/// 반복형(mockExam/weakExam/finalReview)은 횟수 기반: 같은 타입 항목을
/// 날짜·id 순으로 정렬해 실제 응시 횟수만큼 앞에서부터 완료 처리.
///
/// 한계(MVP): 수동 오버라이드된 반복형 항목은 자동 순위 계산에서 제외된다.
/// 즉 manual=true 오버라이드가 있으면 자동 완료 항목이 실제 응시 횟수를 초과할 수 있다
/// (예: 응시 1회 + m0 수동 완료 → m0·m1 모두 done). UI는 진행률 표시 시 유의.
Map<String, bool> computePlanDone(
  StudyPlan plan, {
  required Map<String, bool> manual,
  required Set<String> viewedTaskIds,
  required List<AttemptRecord> history,
}) {
  final cert = plan.certCode;
  final hist = history.where((r) => r.certId == cert).toList();

  int byExamId(String examId) => hist.where((r) => r.examId == examId).length;
  final rankCount = <PlanItemType, int>{
    PlanItemType.mockExam: byExamId('exam:$cert-mock'),
    PlanItemType.weakExam: byExamId('exam:$cert-weak'),
    PlanItemType.finalReview: hist.where((r) => r.mode == 'review').length,
  };

  bool quizDone(String? refId) =>
      refId != null &&
      hist.any((r) => r.mode == 'practice' && taskFromExamId(r.examId) == refId);

  final sorted = [...plan.items]
    ..sort((a, b) {
      final c = a.dateIso.compareTo(b.dateIso);
      return c != 0 ? c : a.id.compareTo(b.id);
    });

  final seen = <PlanItemType, int>{};
  final result = <String, bool>{};
  for (final it in sorted) {
    final m = manual[it.id];
    if (m != null) {
      result[it.id] = m;
      continue;
    }
    switch (it.type) {
      case PlanItemType.doc:
        result[it.id] = it.refId != null && viewedTaskIds.contains(it.refId);
      case PlanItemType.quiz:
        result[it.id] = quizDone(it.refId);
      case PlanItemType.mockExam:
      case PlanItemType.weakExam:
      case PlanItemType.finalReview:
        final rank = seen[it.type] ?? 0;
        seen[it.type] = rank + 1;
        result[it.id] = rank < (rankCount[it.type] ?? 0);
    }
  }
  return result;
}

/// 밀림: 미완 + 배정일이 오늘보다 과거.
bool isOverdue(PlanItem item, String todayIso, bool done) =>
    !done && item.dateIso.compareTo(todayIso) < 0;
