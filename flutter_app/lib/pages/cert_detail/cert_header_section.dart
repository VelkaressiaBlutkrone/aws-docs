import 'package:flutter/material.dart';

import '../../models/certification.dart';
import '../../models/exam_guide.dart';
import '../../theme/app_theme.dart';
import 'cert_detail_bits.dart';

/// 자격증 헤더(레벨·타이틀·대상·공식 팩트 필) — PR4 분해로
/// cert_detail_page.dart에서 이동.
class CertHeaderSection extends StatelessWidget {
  const CertHeaderSection({super.key, required this.cert, required this.guide});
  final Certification cert;
  final ExamGuide? guide;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    final o = guide?.overview;
    final facts = <String>[
      if (o?.passingScore != null) '합격 ${o!.passingScore}/1000',
      if (o?.scoredQuestions != null)
        '채점 ${o!.scoredQuestions}문항${o.unscoredQuestions != null ? ' (+비채점 ${o.unscoredQuestions})' : ''}',
      if (o?.durationMinutes != null) '${o!.durationMinutes}분',
      if (guide != null)
        '도메인 ${guide!.domains.length} · Task ${guide!.taskCount}',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          cert.level.short,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800, fontVariations: Wght.w800,
            letterSpacing: 0.6,
            color: c.accent,
          ),
        ),
        const SizedBox(height: Gap.sm),
        Text(cert.title, style: t.headlineMedium),
        const SizedBox(height: Gap.sm),
        Text(cert.audience, style: t.bodyMedium),
        if (facts.isNotEmpty) ...[
          const SizedBox(height: Gap.lg),
          Wrap(
            spacing: Gap.sm,
            runSpacing: Gap.sm,
            children: [for (final f in facts) FactPill(f)],
          ),
        ],
        const SizedBox(height: Gap.xl2),
      ],
    );
  }
}
