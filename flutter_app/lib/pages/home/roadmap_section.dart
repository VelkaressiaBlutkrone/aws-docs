import 'package:flutter/material.dart';

import '../../data/site_data.dart';
import '../../models/certification.dart';
import '../../theme/app_theme.dart';
import 'home_bits.dart';

/// 자격증별 학습 로드맵(수직 단계 카드, PR4 분해 — home_page.dart에서 이동).
class RoadmapSection extends StatelessWidget {
  const RoadmapSection({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeBand(
      title: '자격증별 학습 로드맵',
      meta: '${certifications.length}개 로드맵',
      child: Column(
        children: [
          for (final cert in certifications)
            Padding(
              padding: const EdgeInsets.only(bottom: Gap.lg),
              child: _RoadmapCard(cert: cert),
            ),
        ],
      ),
    );
  }
}

class _RoadmapCard extends StatelessWidget {
  const _RoadmapCard({required this.cert});
  final Certification cert;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Gap.xl),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomePill(label: cert.code, tone: PillTone.code),
          const SizedBox(height: Gap.sm),
          Text(cert.title, style: t.titleLarge),
          const SizedBox(height: Gap.xs),
          Text(cert.audience, style: t.bodyMedium),
          const SizedBox(height: Gap.lg),
          for (var i = 0; i < cert.roadmap.length; i++)
            _Step(index: i + 1, text: cert.roadmap[i]),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.index, required this.text});
  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: c.accentWeak,
              borderRadius: BorderRadius.circular(Radii.full),
              border: Border.all(color: c.accent.withValues(alpha: 0.4)),
            ),
            alignment: Alignment.center,
            child: Text('$index',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800, fontVariations: Wght.w800,
                    color: c.accentStrong)),
          ),
          const SizedBox(width: Gap.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text(text,
                  style: t.bodyLarge?.copyWith(fontSize: 15, height: 1.5)),
            ),
          ),
        ],
      ),
    );
  }
}
