/// 한 응시의 오답 개념(비정규화) — stale 문항에도 개념 보존(report 개념 집계용).
class WrongSkill {
  const WrongSkill(
      {required this.skill, required this.section, required this.taskId});
  final String skill;
  final String section; // 학습문서 섹션 앵커 id (없으면 '')
  final String taskId; // examGuideTaskId

  Map<String, dynamic> toJson() =>
      {'skill': skill, 'section': section, 'taskId': taskId};

  factory WrongSkill.fromJson(Map<String, dynamic> j) => WrongSkill(
        skill: (j['skill'] ?? '').toString(),
        section: (j['section'] ?? '').toString(),
        taskId: (j['taskId'] ?? '').toString(),
      );
}

/// 응시 이력 레코드 — 설계 D14 스키마(+ mode 확장).
class AttemptRecord {
  const AttemptRecord({
    required this.certId,
    required this.examId,
    required this.mode,
    required this.date,
    required this.correct,
    required this.total,
    required this.wrongQuestionIds,
    required this.flaggedQuestionIds,
    this.presentedQuestionIds = const [],
    this.wrongSkills = const [],
    required this.durationSpentSec,
  });

  final String certId;
  final String examId; // 연습: 'practice:<taskId>'
  final String mode; // 'practice' | 'exam'
  final String date; // ISO-8601
  final int correct;
  final int total;
  final List<String> wrongQuestionIds;
  final List<String> flaggedQuestionIds;

  /// 그 응시에 출제된 전체 문항 ID(약점 파생용). 레거시 레코드는 빈 리스트.
  final List<String> presentedQuestionIds;

  /// 오답 개념(비정규화). 레거시 레코드는 빈 리스트.
  final List<WrongSkill> wrongSkills;
  final int durationSpentSec;

  Map<String, dynamic> toJson() => {
        'certId': certId,
        'examId': examId,
        'mode': mode,
        'date': date,
        'correct': correct,
        'total': total,
        'wrongQuestionIds': wrongQuestionIds,
        'flaggedQuestionIds': flaggedQuestionIds,
        'presentedQuestionIds': presentedQuestionIds,
        'wrongSkills': [for (final w in wrongSkills) w.toJson()],
        'durationSpentSec': durationSpentSec,
      };

  factory AttemptRecord.fromJson(Map<String, dynamic> j) => AttemptRecord(
        certId: (j['certId'] ?? '').toString(),
        examId: (j['examId'] ?? '').toString(),
        mode: (j['mode'] ?? 'practice').toString(),
        date: (j['date'] ?? '').toString(),
        correct: (j['correct'] as num?)?.toInt() ?? 0,
        total: (j['total'] as num?)?.toInt() ?? 0,
        wrongQuestionIds: ((j['wrongQuestionIds'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
        flaggedQuestionIds: ((j['flaggedQuestionIds'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
        presentedQuestionIds: ((j['presentedQuestionIds'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
        wrongSkills: ((j['wrongSkills'] as List?) ?? const [])
            .map((e) => WrongSkill.fromJson(e as Map<String, dynamic>))
            .toList(),
        durationSpentSec: (j['durationSpentSec'] as num?)?.toInt() ?? 0,
      );
}
