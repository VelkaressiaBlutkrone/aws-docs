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
    this.section = '',
    this.difficulty = '',
  });

  final String id;
  final String examGuideTaskId;
  final String skill;
  final String section; // 학습문서 섹션 앵커 id (딥링크). 없으면 ''.
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
      section: (j['section'] ?? '').toString(),
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

  /// [order] = 표시 순서대로 나열한 원본 인덱스 순열(예: [2,0,3,1]).
  /// options 재배열 + correct 재매핑 + wrongExplanations 키 재매핑한 새 Question 반환.
  /// 유효하지 않은 순열(길이 불일치·중복·범위 밖)이면 원본을 그대로 반환한다
  /// — 손상된 복원 데이터로 답이 어긋나는 것보다 셔플 미적용이 안전(스펙 §3.1).
  Question withOptionOrder(List<int> order) {
    final n = options.length;
    final valid = order.length == n &&
        order.toSet().length == n &&
        order.every((i) => i >= 0 && i < n);
    if (!valid) return this;
    return Question(
      id: id,
      examGuideTaskId: examGuideTaskId,
      skill: skill,
      section: section,
      difficulty: difficulty,
      stem: stem,
      options: [for (final i in order) options[i]],
      correct: order.indexOf(correct),
      explanation: explanation,
      wrongExplanations: {
        for (final e in wrongExplanations.entries)
          if (order.contains(e.key)) order.indexOf(e.key): e.value,
      },
      sources: sources,
      verified: verified,
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
