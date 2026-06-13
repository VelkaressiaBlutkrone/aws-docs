import 'package:flutter/material.dart';

import '../../models/certification.dart';
import '../../theme/app_theme.dart';
import '../../widgets/badges.dart';
import '../../widgets/focus_ring.dart';
import 'home_bits.dart';

/// 콘텐츠 보유 자격증 진입 카드 — 학습문서/모의고사/일정 3개 섹션 공용
/// (PR4 분해 — home_page.dart에서 이동).
class ContentCertCard extends StatelessWidget {
  const ContentCertCard({
    super.key,
    required this.cert,
    required this.summaryLabel,
    required this.cta,
    required this.onTap,
    this.viewedBadge,
  });
  final Certification cert;
  final String summaryLabel;
  final String cta;
  final VoidCallback onTap;
  final String? viewedBadge; // 예: '열람 5/19' — null이면 미표시

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    return FocusTap(
      onTap: onTap,
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(Gap.lg),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(color: c.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(cert.title, style: t.titleMedium),
            const SizedBox(height: Gap.sm),
            AppBadge(
                label: summaryLabel,
                bg: c.surface2,
                fg: c.textMuted,
                strong: false),
            if (viewedBadge != null) ...[
              const SizedBox(height: Gap.xs),
              AppBadge(
                  label: viewedBadge!,
                  bg: c.accentWeak,
                  fg: c.accentStrong),
            ],
            const SizedBox(height: Gap.md),
            Text(cta,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700, fontVariations: Wght.w700,
                    color: c.accent)),
          ],
        ),
      ),
    );
  }
}

/// 콘텐츠 미보유 자격증을 "준비 중" 코드 칩으로 묶음.
class PendingGroup extends StatelessWidget {
  const PendingGroup({super.key, required this.certs});
  final List<Certification> certs;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Gap.lg),
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: BorderRadius.circular(Radii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('준비 중',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800, fontVariations: Wght.w800,
                  color: c.textMuted)),
          const SizedBox(height: Gap.sm),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [for (final cert in certs) HomeChip(label: cert.code)],
          ),
        ],
      ),
    );
  }
}
