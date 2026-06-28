/// 문서내 제목별 타임스탬프(추정) — audio_meta.json의 chapters를 파싱하고,
/// 헤딩 시크포인트의 시각·노출을 계산하는 순수 로직. fraction(0~1)에 런타임
/// duration을 곱해 시각을 구한다(절대 ms 비저장 — 실측 길이에 적응).
/// 설계: docs/superpowers/specs/2026-06-28-audio-section-timestamps-design.md
library;

class Chapter {
  const Chapter({
    required this.anchor,
    required this.title,
    required this.level,
    required this.fraction,
  });

  final String anchor;
  final String title;
  final int level;
  final double fraction;
}

/// audio_meta.json 맵에서 chapters 파싱. 없거나 형식 불일치면 빈 리스트.
List<Chapter> parseChapters(Map<String, dynamic> audioMeta) {
  final raw = audioMeta['chapters'];
  if (raw is! List) return const <Chapter>[];
  final out = <Chapter>[];
  for (final e in raw) {
    if (e is! Map) continue;
    final anchor = e['anchor'];
    final fraction = e['fraction'];
    if (anchor is! String || fraction is! num) continue;
    out.add(Chapter(
      anchor: anchor,
      title: (e['title'] as String?) ?? anchor,
      level: (e['level'] as num?)?.toInt() ?? 2,
      fraction: fraction.toDouble(),
    ));
  }
  return out;
}

/// fraction(0~1) × duration → 시크 밀리초.
int chapterSeekMs(double fraction, Duration duration) =>
    (fraction * duration.inMilliseconds).round();

/// 헤딩 시크포인트 노출 게이트(순수).
bool shouldShowHeadingSeek({
  required bool enabled,
  required bool approved,
  required bool isCurrentTrack,
  required bool hasDuration,
  required bool hasFraction,
}) =>
    enabled && approved && isCurrentTrack && hasDuration && hasFraction;
