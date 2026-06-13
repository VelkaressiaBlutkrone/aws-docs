import 'package:flutter/material.dart';

import '../../models/certification.dart';
import '../../models/exam_guide.dart';
import '../../theme/app_theme.dart';
import 'cert_detail_bits.dart';

/// 공식 Exam Guide 원문 섹션(도메인 아코디언) — PR4 분해로
/// cert_detail_page.dart에서 이동.
class OfficialGuideSection extends StatelessWidget {
  const OfficialGuideSection({super.key, required this.guide});
  final ExamGuide guide;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.verified_outlined, size: 18, color: c.text),
            const SizedBox(width: 8),
            Text('공식 시험 가이드', style: t.headlineSmall),
          ],
        ),
        const SizedBox(height: 4),
        Text('AWS 공식 Exam Guide의 도메인·과제·세부 항목 (한국어).', style: t.bodyMedium),
        const SizedBox(height: Gap.xl),
        for (final d in guide.domains) _DomainCard(domain: d),
        const SizedBox(height: Gap.lg),
        Text(
          '출처: ${guide.sourceUrl}',
          style: TextStyle(
            fontSize: 11,
            color: c.textFaint,
            fontFamily: AppTheme.monoFamily,
          ),
        ),
      ],
    );
  }
}

class _DomainCard extends StatelessWidget {
  const _DomainCard({required this.domain});
  final ExamDomain domain;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: Gap.lg),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: c.border),
      ),
      // 장식 Container가 Scaffold의 Material을 가리면 ExpansionTile(ListTile)의
      // 잉크가 장식 밑에 그려져 보이지 않는다(디버그 단언). 투명 Material을
      // 장식 위에 깔아 잉크를 그 위에 그린다 — 시각 동일, 단언 해소.
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(Radii.lg),
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
          initiallyExpanded: domain.no == 1,
          tilePadding: const EdgeInsets.symmetric(
            horizontal: Gap.xl,
            vertical: Gap.xs,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(Gap.xl, 0, Gap.xl, Gap.lg),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          title: Row(
            children: [
              Expanded(
                child: Text(
                  '도메인 ${domain.no}. ${domain.name}',
                  style: t.titleMedium,
                ),
              ),
              const SizedBox(width: Gap.sm),
              WeightPill(domain.weightPct),
            ],
          ),
            children: [
              for (final task in domain.tasks) _TaskBlock(task: task)
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskBlock extends StatelessWidget {
  const _TaskBlock({required this.task});
  final ExamTask task;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(top: Gap.md),
      padding: const EdgeInsets.all(Gap.lg),
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: BorderRadius.circular(Radii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Task ${task.no}',
                style: TextStyle(
                  fontFamily: AppTheme.monoFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w700, fontVariations: Wght.w700,
                  color: c.accent,
                ),
              ),
              const SizedBox(width: Gap.sm),
              Expanded(
                child: Text(
                  task.title,
                  style: t.titleMedium?.copyWith(fontSize: 15),
                ),
              ),
            ],
          ),
          if (task.knowledge.isNotEmpty) ...[
            const SizedBox(height: Gap.md),
            const SubLabel('지식'),
            for (final k in task.knowledge) Bullet(k, color: c.info),
          ],
          if (task.skills.isNotEmpty) ...[
            const SizedBox(height: Gap.md),
            SubLabel(task.knowledge.isEmpty ? '세부 항목' : '기술'),
            for (final s in task.skills) Bullet(s, color: c.accent),
          ],
        ],
      ),
    );
  }
}

class GuideMissing extends StatelessWidget {
  const GuideMissing({super.key, required this.cert});
  final Certification cert;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Gap.xl),
      decoration: BoxDecoration(
        color: c.warningWeak,
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: c.warning.withValues(alpha: 0.35)),
      ),
      child: Text(
        '이 자격증의 공식 가이드 본문은 아직 준비 중입니다.',
        style: TextStyle(color: c.text),
      ),
    );
  }
}
