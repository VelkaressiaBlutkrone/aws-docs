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
        durationSpentSec: (j['durationSpentSec'] as num?)?.toInt() ?? 0,
      );
}
