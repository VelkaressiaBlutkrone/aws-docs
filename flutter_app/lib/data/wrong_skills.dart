import '../models/attempt_record.dart';
import '../models/question.dart';

/// 오답(picked≠correct 또는 미응답)이며 개념(skill) 태그가 있는 문항을
/// WrongSkill로 변환. 정답·무태그 문항은 제외. AttemptRecord 생성 시 사용.
List<WrongSkill> buildWrongSkills(List<Question> qs, Map<int, int> picked) {
  final out = <WrongSkill>[];
  for (var k = 0; k < qs.length; k++) {
    final q = qs[k];
    final isWrong = picked[k] != q.correct; // 미응답(null)도 오답
    if (isWrong && q.skill.isNotEmpty) {
      out.add(WrongSkill(
          skill: q.skill, section: q.section, taskId: q.examGuideTaskId));
    }
  }
  return out;
}
