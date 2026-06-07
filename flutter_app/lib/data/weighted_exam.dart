import '../models/attempt_record.dart';
import 'task_score_report.dart';

/// 약점 집중 모의고사 활성 게이트: 비-review 응시 최소 횟수.
const int kWeightedExamMinAttempts = 3;

/// 가중 기본값 — floor: 전 Task 최소 출제 보장, scale: 오답률 1.0당 가산.
const int kWeightFloor = 10;
const int kWeightScale = 100;

/// Task별 출제 가중 = floor + round((1 - 정답률) * scale).
/// 미응시 Task는 floor만(약점 근거 없음 → 과대 가중 방지, 출제는 유지).
/// 모든 Task ≥ floor → 전 Task 노출 보장.
Map<String, int> weightByTaskFromReport(
  TaskScoreReport report, {
  int scale = kWeightScale,
  int floor = kWeightFloor,
}) {
  final w = <String, int>{};
  for (final t in report.tasks) {
    final rate = t.rate;
    if (rate == null) {
      w[t.taskId] = floor; // 미응시
    } else {
      w[t.taskId] = floor + ((1 - rate) * scale).round();
    }
  }
  return w;
}

/// 해당 자격증의 비-review 응시 횟수(게이트 판정용).
int nonReviewAttemptCount(String certId, List<AttemptRecord> history) =>
    history.where((r) => r.certId == certId && r.mode != 'review').length;

/// 약점 집중 모의고사 활성 여부(응시 3회+).
bool weightedExamUnlocked(String certId, List<AttemptRecord> history) =>
    nonReviewAttemptCount(certId, history) >= kWeightedExamMinAttempts;
