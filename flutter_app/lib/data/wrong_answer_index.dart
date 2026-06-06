import '../models/attempt_record.dart';

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
      for (final qid in _presentedOf(r, taskByQuestionId)) {
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

  /// 한 응시에 출제된 문항 ID 집합. presentedQuestionIds가 있으면 그대로,
  /// 없으면(레거시) examId의 Task 현재 뱅크 전체로 폴백, 그것도 불가하면 오답만.
  static Iterable<String> _presentedOf(
      AttemptRecord r, Map<String, String> taskByQuestionId) {
    if (r.presentedQuestionIds.isNotEmpty) return r.presentedQuestionIds;
    final task = _taskFromExamId(r.examId);
    if (task == null) return r.wrongQuestionIds;
    final taskQs = [
      for (final e in taskByQuestionId.entries)
        if (e.value == task) e.key,
    ];
    return taskQs.isEmpty ? r.wrongQuestionIds : taskQs;
  }

  /// 'practice:clf-t2-1' / 'exam:clf-t2-1' / 'review:clf-t2-1' → 'clf-t2-1'.
  /// 통합 모의고사('exam:CLF-C02-mock')처럼 단일 Task가 아니면 null.
  static String? _taskFromExamId(String examId) {
    final i = examId.indexOf(':');
    if (i < 0) return null;
    final rest = examId.substring(i + 1);
    if (rest.isEmpty || rest.endsWith('-mock')) return null;
    return rest;
  }
}
