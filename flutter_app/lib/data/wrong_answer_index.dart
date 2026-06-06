import '../models/attempt_record.dart';
import 'attempt_presented.dart';

/// 약점 문항 상태: weak(미졸업) / mastered(서로 다른 응시 연속 2회 정답으로 졸업).
enum WrongStatus { weak, mastered }

/// 한 문항의 약점 파생 결과.
class WrongEntry {
  const WrongEntry({
    required this.questionId,
    required this.taskId,
    required this.certId,
    required this.wrongCount,
    required this.consecutiveCorrect,
    required this.lastSeen,
    required this.status,
  });
  final String questionId;
  final String taskId;
  final String certId;
  final int wrongCount;
  final int consecutiveCorrect;
  final String lastSeen; // 마지막으로 출제된 응시의 date(ISO)
  final WrongStatus status;
}

/// 응시 이력에서 "한 번이라도 틀린" 문항의 약점/졸업 상태를 파생하는 순수 인덱스.
/// 자산 로드는 호출측 책임 — [taskByQuestionId]는 현재 뱅크의 (문항ID→TaskID) 맵.
/// 이 맵에 없는 문항 = 개정으로 사라짐 → 결과에서 제외.
class WrongAnswerIndex {
  WrongAnswerIndex._(this.entries);

  /// "한 번이라도 틀린" 문항만. weak/mastered 모두 포함.
  final List<WrongEntry> entries;

  factory WrongAnswerIndex.build({
    required String certId,
    required List<AttemptRecord> history,
    required Map<String, String> taskByQuestionId,
  }) {
    final records = history.where((r) => r.certId == certId).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    // 문항별 정/오답 타임라인(date 오름차순) + 마지막 출제일.
    final timeline = <String, List<bool>>{}; // qid -> [correct?...]
    final lastSeen = <String, String>{};
    for (final r in records) {
      final wrongSet = r.wrongQuestionIds.toSet();
      for (final qid in resolvePresented(r, taskByQuestionId)) {
        if (!taskByQuestionId.containsKey(qid)) continue; // stale 제외
        (timeline[qid] ??= <bool>[]).add(!wrongSet.contains(qid));
        lastSeen[qid] = r.date;
      }
    }

    final entries = <WrongEntry>[];
    timeline.forEach((qid, results) {
      final wrongCount = results.where((ok) => !ok).length;
      if (wrongCount == 0) return; // 틀린 적 없으면 노트 대상 아님
      var consec = 0;
      for (var i = results.length - 1; i >= 0 && results[i]; i--) {
        consec++;
      }
      entries.add(WrongEntry(
        questionId: qid,
        taskId: taskByQuestionId[qid]!,
        certId: certId,
        wrongCount: wrongCount,
        consecutiveCorrect: consec,
        lastSeen: lastSeen[qid]!,
        status: consec >= 2 ? WrongStatus.mastered : WrongStatus.weak,
      ));
    });
    return WrongAnswerIndex._(entries);
  }

  /// Task별 weak 문항 수(배지용). mastered는 세지 않음.
  Map<String, int> weakByTask() {
    final m = <String, int>{};
    for (final e in entries) {
      if (e.status == WrongStatus.weak) {
        m[e.taskId] = (m[e.taskId] ?? 0) + 1;
      }
    }
    return m;
  }

  /// weak 엔트리(복습 큐). [taskId] 지정 시 해당 Task만.
  List<WrongEntry> weakEntries([String? taskId]) => [
        for (final e in entries)
          if (e.status == WrongStatus.weak &&
              (taskId == null || e.taskId == taskId))
            e,
      ];

}
