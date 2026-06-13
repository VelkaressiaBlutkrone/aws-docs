import 'package:flutter/material.dart';

import '../../data/site_data.dart';
import '../../theme/app_theme.dart';
import 'home_bits.dart';

/// 목표별 추천 순서 카드(PR4 분해 — home_page.dart에서 이동).
class PathsSection extends StatelessWidget {
  const PathsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    return HomeBand(
      title: '추천 순서',
      meta: '목표별 기본 경로',
      child: Wrap(
        spacing: Gap.lg,
        runSpacing: Gap.lg,
        children: [
          for (final p in recommendedPaths)
            Container(
              width: 360,
              padding: const EdgeInsets.all(Gap.lg),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(Radii.md),
                border: Border.all(color: c.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.title, style: t.titleMedium),
                  const SizedBox(height: Gap.sm),
                  Text(p.steps.join('  →  '),
                      style: t.bodyMedium?.copyWith(
                          fontFeatures: const [], color: c.textMuted)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
