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
/// 자동 감지는 플랜 생성일(createdIso) 이후 응시만 카운트한다(doc 열람 제외 — 타임스탬프 없음).
Map<String, bool> computePlanDone(
  StudyPlan plan, {
  required Set<String> done,
  required List<AttemptRecord> history,
}) {
  final cert = plan.certCode;
  // 플랜 생성일 이후 응시만 카운트(사전 학습 이력이 항목을 미리 완료 처리하지 않도록).
  // doc는 ViewedDocsStore에 타임스탬프가 없어 날짜 게이팅 불가(열람=완료).
  final hist = history
      .where((r) => r.certId == cert && r.date.compareTo(plan.createdIso) >= 0)
      .toList();

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
    if (done.contains(it.id)) {
      result[it.id] = true;
      continue;
    }
    switch (it.type) {
      case PlanItemType.doc:
        // done 아니면 미완 — 전역 열람과 독립(일정별 진행, PlanProgressStore).
        result[it.id] = false;
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

/// 플랜의 '오늘 할 일'·'밀림(지난)' 개수(미완 항목 기준). 순수.
({int today, int overdue}) planDueCounts(
    StudyPlan plan, Map<String, bool> done, String todayIso) {
  var t = 0, o = 0;
  for (final it in plan.items) {
    if (done[it.id] == true) continue;
    final cmp = it.dateIso.compareTo(todayIso);
    if (cmp == 0) {
      t++;
    } else if (cmp < 0) {
      o++;
    }
  }
  return (today: t, overdue: o);
}
