import '../models/attempt_record.dart';

/// 한 응시에 출제된 문항 ID 집합. presentedQuestionIds가 있으면 그대로,
/// 없으면(레거시) examId의 Task 현재 뱅크 전체로 폴백, 그것도 불가하면 오답만.
/// E1(WrongAnswerIndex)·E2(TaskScoreReport)가 공유 — "무엇이 출제됐나" 정의 단일화.
Iterable<String> resolvePresented(
    AttemptRecord r, Map<String, String> taskByQuestionId) {
  if (r.presentedQuestionIds.isNotEmpty) return r.presentedQuestionIds;
  final task = taskFromExamId(r.examId);
  if (task == null) return r.wrongQuestionIds;
  final taskQs = [
    for (final e in taskByQuestionId.entries)
      if (e.value == task) e.key,
  ];
  return taskQs.isEmpty ? r.wrongQuestionIds : taskQs;
}

/// 'practice:clf-t2-1' / 'exam:clf-t2-1' / 'review:clf-t2-1' → 'clf-t2-1'.
/// 통합 모의고사('exam:CLF-C02-mock')처럼 단일 Task가 아니면 null.
String? taskFromExamId(String examId) {
  final i = examId.indexOf(':');
  if (i < 0) return null;
  final rest = examId.substring(i + 1);
  if (rest.isEmpty || rest.endsWith('-mock')) return null;
  return rest;
}
