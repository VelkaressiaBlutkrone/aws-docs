import 'question.dart';

/// 진행 중 시험 세션(localStorage 복원 대상). 스펙 §4.
class ExamSession {
  const ExamSession({
    required this.examId,
    required this.certId,
    required this.taskId,
    required this.startedAtIso,
    required this.durationSec,
    required this.index,
    required this.picked,
    required this.flagged,
    required this.bankFingerprint,
    this.questionIds = const [],
    this.optionOrders = const {},
    required this.submitted,
  });

  final String examId; // 'exam:<taskId>'
  final String certId;
  final String taskId;
  final String startedAtIso; // ISO-8601 시작 벽시계 기준점
  final int durationSec;
  final int index;
  final Map<int, int> picked; // 문항 → 선택 보기
  final List<int> flagged;
  final String bankFingerprint;
  final List<String> questionIds; // 통합 모의고사 출제 문항 ID(순서) — 복원용
  final Map<String, List<int>> optionOrders; // 문항 ID → 선택지 표시 순서(원본 인덱스 순열) — 셔플 복원용(스펙 §3.3)
  final bool submitted;

  Map<String, dynamic> toJson() => {
        'examId': examId,
        'certId': certId,
        'taskId': taskId,
        'startedAtIso': startedAtIso,
        'durationSec': durationSec,
        'index': index,
        'picked': picked.map((k, v) => MapEntry(k.toString(), v)),
        'flagged': flagged,
        'bankFingerprint': bankFingerprint,
        'questionIds': questionIds,
        'optionOrders': optionOrders,
        'submitted': submitted,
      };

  factory ExamSession.fromJson(Map<String, dynamic> j) {
    final picked = <int, int>{};
    final rawP = j['picked'];
    if (rawP is Map) {
      rawP.forEach((k, v) {
        final ki = int.tryParse(k.toString());
        final vi = (v as num?)?.toInt();
        if (ki != null && vi != null) picked[ki] = vi;
      });
    }
    final orders = <String, List<int>>{};
    final rawO = j['optionOrders'];
    if (rawO is Map) {
      rawO.forEach((k, v) {
        if (v is List) {
          orders[k.toString()] =
              v.whereType<num>().map((e) => e.toInt()).toList();
        }
      });
    }
    return ExamSession(
      examId: (j['examId'] ?? '').toString(),
      certId: (j['certId'] ?? '').toString(),
      taskId: (j['taskId'] ?? '').toString(),
      startedAtIso: (j['startedAtIso'] ?? '').toString(),
      durationSec: (j['durationSec'] as num?)?.toInt() ?? 0,
      index: (j['index'] as num?)?.toInt() ?? 0,
      picked: picked,
      flagged: ((j['flagged'] as List?) ?? const [])
          .whereType<num>()
          .map((e) => e.toInt())
          .toList(),
      bankFingerprint: (j['bankFingerprint'] ?? '').toString(),
      questionIds: ((j['questionIds'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      optionOrders: orders,
      submitted: j['submitted'] == true,
    );
  }
}

/// 문제은행 지문(문항 수 + ID 목록) — 콘텐츠 개정 감지용.
String bankFingerprint(QuestionBank bank) =>
    '${bank.questions.length}:${bank.questions.map((q) => q.id).join(',')}';

/// 실전 비례 페이스. 공식 메타 누락 시 폴백 84s/문항.
int examDurationSec({
  required int? durationMinutes,
  required int? scored,
  required int? unscored,
  required int count,
}) {
  if (durationMinutes == null && scored == null && unscored == null) {
    return (84.0 * count).round();
  }
  final total = (scored ?? 50) + (unscored ?? 15);
  final perQ = total > 0 ? (durationMinutes ?? 90) * 60 / total : 84.0;
  return (perQ * count).round();
}
