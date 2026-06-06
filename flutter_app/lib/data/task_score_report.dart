import '../models/attempt_record.dart';
import 'attempt_presented.dart';

/// 약점 임계값 — 정답률 70% 미만이면 weak(처방 대상).
const double kWeakThreshold = 0.7;

enum TaskStatus { unattempted, weak, ok }

/// 한 Task의 정답률 요약(문항별 최신 결과 기준).
class TaskScore {
  const TaskScore({
    required this.taskId,
    required this.total,
    required this.attempted,
    required this.correct,
    required this.rate,
    required this.status,
  });
  final String taskId;
  final int total; // 현재 검증 뱅크 문항 수
  final int attempted; // 최신 결과 보유(연습/시험 출제된) 문항 수
  final int correct; // 최신 결과가 정답인 문항 수
  final double? rate; // null = 미응시
  final TaskStatus status;
}

/// 응시 이력에서 Task별 정답률을 파생하는 순수 리포트. review 모드 제외.
/// 자산 로드는 호출측 책임([taskByQuestionId]·[taskOrder]는 현재 뱅크에서 구성).
class TaskScoreReport {
  TaskScoreReport._(this.tasks);
  final List<TaskScore> tasks; // taskOrder 순

  factory TaskScoreReport.build({
    required String certId,
    required List<AttemptRecord> history,
    required Map<String, String> taskByQuestionId,
    required List<String> taskOrder,
  }) {
    final records = history
        .where((r) => r.certId == certId && r.mode != 'review')
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    // 문항별 최신 결과(date 오름차순 마지막 값이 최신).
    final latest = <String, bool>{}; // qid -> 정답?
    for (final r in records) {
      final wrongSet = r.wrongQuestionIds.toSet();
      for (final qid in resolvePresented(r, taskByQuestionId)) {
        if (!taskByQuestionId.containsKey(qid)) continue; // stale 제외
        latest[qid] = !wrongSet.contains(qid);
      }
    }

    // Task별 total(현재 뱅크) 집계.
    final totalByTask = <String, int>{};
    taskByQuestionId.forEach((qid, taskId) {
      totalByTask[taskId] = (totalByTask[taskId] ?? 0) + 1;
    });

    final scores = <TaskScore>[];
    for (final taskId in taskOrder) {
      final qids = [
        for (final e in taskByQuestionId.entries)
          if (e.value == taskId) e.key,
      ];
      var attempted = 0;
      var correct = 0;
      for (final qid in qids) {
        final res = latest[qid];
        if (res == null) continue;
        attempted++;
        if (res) correct++;
      }
      final double? rate = attempted == 0 ? null : correct / attempted;
      final TaskStatus status = attempted == 0
          ? TaskStatus.unattempted
          : (rate! < kWeakThreshold ? TaskStatus.weak : TaskStatus.ok);
      scores.add(TaskScore(
        taskId: taskId,
        total: totalByTask[taskId] ?? 0,
        attempted: attempted,
        correct: correct,
        rate: rate,
        status: status,
      ));
    }
    return TaskScoreReport._(scores);
  }

  int get attemptedTotal => tasks.fold(0, (a, t) => a + t.attempted);
  int get correctTotal => tasks.fold(0, (a, t) => a + t.correct);
  bool get hasAnyAttempt => attemptedTotal > 0;
  double? get overallRate =>
      attemptedTotal == 0 ? null : correctTotal / attemptedTotal;
}
