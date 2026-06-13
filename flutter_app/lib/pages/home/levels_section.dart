import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/site_data.dart';
import '../../models/certification.dart';
import '../../theme/app_theme.dart';
import '../../widgets/focus_ring.dart';
import 'home_bits.dart';

/// 단계(레벨)별 자격증 카드 그리드(PR4 분해 — home_page.dart에서 이동).
class LevelsSection extends StatelessWidget {
  const LevelsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final level in certificationLevels)
          HomeBand(
            title: level.heading,
            meta:
                '${certifications.where((cert) => cert.level == level).length}개 자격증',
            child: Wrap(
              spacing: Gap.lg,
              runSpacing: Gap.lg,
              children: [
                for (final cert
                    in certifications.where((cert) => cert.level == level))
                  _CertCard(cert: cert),
              ],
            ),
          ),
      ],
    );
  }
}

class _CertCard extends StatelessWidget {
  const _CertCard({required this.cert});
  final Certification cert;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    return FocusTap(
      onTap: () => context.push('/cert/${cert.code}'),
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(Gap.lg),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(color: c.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                HomePill(label: cert.level.short, tone: PillTone.level),
                const SizedBox(width: Gap.sm),
                HomePill(label: cert.code, tone: PillTone.code),
              ],
            ),
            const SizedBox(height: Gap.md),
            Text(cert.title, style: t.titleMedium),
            const SizedBox(height: Gap.xs),
            Text(cert.audience, style: t.bodyMedium),
            const SizedBox(height: Gap.md),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [for (final f in cert.focus) HomeChip(label: f)],
            ),
            const SizedBox(height: Gap.md),
            const HomeLinkText(label: '공식 가이드 보기 →'),
          ],
        ),
      ),
    );
  }
}
