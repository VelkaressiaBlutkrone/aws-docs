import '../models/attempt_record.dart';

/// 약점 리포트의 "놓친 개념" 한 항목.
class MissedConcept {
  const MissedConcept({required this.skill, required this.section});
  final String skill;
  final String section; // 학습문서 섹션 앵커 id (없으면 ''). 딥링크용.
}

/// cert의 비-review 응시에서 Task별 놓친 개념을 누적 집계(skill 기준 dedup,
/// 첫 section 유지). 레코드의 wrongSkills가 있으면 그것을, 없으면(레거시)
/// wrongQuestionIds를 [questionMeta](라이브 뱅크)로 조인. 키=taskId.
Map<String, List<MissedConcept>> buildConceptReport({
  required String certId,
  required List<AttemptRecord> history,
  required Map<String, ({String taskId, String skill, String section})>
      questionMeta,
}) {
  final byTask = <String, List<MissedConcept>>{};
  final seen = <String, Set<String>>{}; // taskId -> 본 skill 집합(dedup)

  void add(String taskId, String skill, String section) {
    if (skill.isEmpty) return;
    final s = seen.putIfAbsent(taskId, () => <String>{});
    if (!s.add(skill)) return; // 이미 본 개념
    byTask
        .putIfAbsent(taskId, () => <MissedConcept>[])
        .add(MissedConcept(skill: skill, section: section));
  }

  for (final r in history) {
    if (r.certId != certId || r.mode == 'review') continue;
    if (r.wrongSkills.isNotEmpty) {
      for (final w in r.wrongSkills) {
        add(w.taskId, w.skill, w.section);
      }
    } else {
      for (final qid in r.wrongQuestionIds) {
        final m = questionMeta[qid];
        if (m != null) add(m.taskId, m.skill, m.section);
      }
    }
  }
  return byTask;
}
