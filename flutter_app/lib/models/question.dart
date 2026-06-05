import 'study_content.dart' show StudySource;

class Question {
  const Question({
    required this.id,
    required this.examGuideTaskId,
    required this.stem,
    required this.options,
    required this.correct,
    required this.explanation,
    required this.wrongExplanations,
    required this.sources,
    required this.verified,
    this.skill = '',
    this.difficulty = '',
  });

  final String id;
  final String examGuideTaskId;
  final String skill;
  final String difficulty;
  final String stem;
  final List<String> options;
  final int correct; // 0-base
  final String explanation;
  final Map<int, String> wrongExplanations;
  final List<StudySource> sources;
  final bool verified;

  factory Question.fromJson(Map<String, dynamic> j) {
    final we = <int, String>{};
    final rawWe = j['wrongExplanations'];
    if (rawWe is Map) {
      rawWe.forEach((k, v) {
        final ki = int.tryParse(k.toString());
        if (ki != null) we[ki] = v.toString();
      });
    }
    return Question(
      id: (j['id'] ?? '').toString(),
      examGuideTaskId: (j['examGuideTaskId'] ?? '').toString(),
      skill: (j['skill'] ?? '').toString(),
      difficulty: (j['difficulty'] ?? '').toString(),
      stem: (j['stem'] ?? '').toString(),
      options: ((j['options'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      correct: (j['correct'] as num?)?.toInt() ?? -1,
      explanation: (j['explanation'] ?? '').toString(),
      wrongExplanations: we,
      sources: ((j['sources'] as List?) ?? const [])
          .map((e) => StudySource.fromJson(e as Map<String, dynamic>))
          .toList(),
      verified: j['verified'] == true,
    );
  }
}

class QuestionBank {
  const QuestionBank({
    required this.examGuideTaskId,
    required this.taskTitle,
    required this.certCode,
    required this.domain,
    required this.questions,
  });

  final String examGuideTaskId;
  final String taskTitle;
  final String certCode;
  final int domain;
  final List<Question> questions;

  factory QuestionBank.fromJson(Map<String, dynamic> j) => QuestionBank(
        examGuideTaskId: (j['examGuideTaskId'] ?? '').toString(),
        taskTitle: (j['taskTitle'] ?? '').toString(),
        certCode: (j['certCode'] ?? '').toString(),
        domain: (j['domain'] as num?)?.toInt() ?? 0,
        questions: ((j['questions'] as List?) ?? const [])
            .map((e) => Question.fromJson(e as Map<String, dynamic>))
            .where((q) => q.verified) // verified 게이트: 비검증 비노출
            .toList(),
      );
}
