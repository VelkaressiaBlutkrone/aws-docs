import '../models/attempt_record.dart';

/// 학습 진행률 순수 파생: 열람 문서 수(현재 인덱스 기준) + 최고 정답률 + 마지막 응시일.
/// 자산/스토어 로드는 호출측 책임 — 모듈은 입력만으로 계산.
class StudyProgress {
  const StudyProgress({
    required this.viewedCount,
    required this.totalDocs,
    required this.bestRatePct,
    required this.lastAttemptIso,
  });

  final int viewedCount; // 현재 인덱스에 존재하는 열람 Task 수(stale 제외)
  final int totalDocs; // 현재 인덱스 총 문서 수
  final int? bestRatePct; // 비-review 이력 최고 정답률(%), 없으면 null
  final String? lastAttemptIso; // 마지막 비-review 응시일(ISO), 없으면 null

  bool get hasAny => viewedCount > 0 || bestRatePct != null;

  factory StudyProgress.build({
    required String certId,
    required List<String> allTaskIds,
    required Set<String> viewedTaskIds,
    required List<AttemptRecord> history,
  }) {
    final all = allTaskIds.toSet();
    final viewedCount = viewedTaskIds.where(all.contains).length;

    int? bestPct;
    String? lastIso;
    for (final r in history) {
      if (r.certId != certId || r.mode == 'review' || r.total <= 0) continue;
      final pct = (r.correct / r.total * 100).round();
      if (bestPct == null || pct > bestPct) bestPct = pct;
      if (lastIso == null || r.date.compareTo(lastIso) > 0) lastIso = r.date;
    }

    return StudyProgress(
      viewedCount: viewedCount,
      totalDocs: allTaskIds.length,
      bestRatePct: bestPct,
      lastAttemptIso: lastIso,
    );
  }
}
