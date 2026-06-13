import 'package:flutter/material.dart';

import '../../models/exam_guide.dart';
import '../../theme/app_theme.dart';
import 'cert_detail_bits.dart';

/// 한국어 학습 요약본 — 공식 가이드 원문과 명확히 구분되는 블록.
/// (PR4 분해 — cert_detail_page.dart에서 이동.)
class SummaryBlock extends StatelessWidget {
  const SummaryBlock({super.key, required this.summary});
  final ExamSummary summary;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: Gap.xl2),
      padding: const EdgeInsets.all(Gap.xl),
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.translate, size: 16, color: c.accent),
              const SizedBox(width: 6),
              Text(
                '한국어 학습 요약본',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800, fontVariations: Wght.w800,
                  letterSpacing: 0.4,
                  color: c.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: Gap.md),
          Text(summary.purpose, style: t.bodyLarge?.copyWith(fontSize: 16)),
          const SizedBox(height: Gap.sm),
          Text(summary.audience, style: t.bodyMedium),
          const SizedBox(height: Gap.lg),
          _MiniList(label: '우선 학습 포인트', items: summary.priorityPoints),
          const SizedBox(height: Gap.md),
          _MiniList(label: '시험 범위가 아닌 항목', items: summary.outOfScope),
          const SizedBox(height: Gap.md),
          _MiniList(label: '활용 방법', items: ExamSummary.howToUse),
          const SizedBox(height: Gap.md),
          Text(
            '비공식 학습 요약본 · 최신 세부 항목은 공식 안내서를 확인하세요.',
            style: TextStyle(fontSize: 12, color: c.textFaint),
          ),
        ],
      ),
    );
  }
}

class _MiniList extends StatelessWidget {
  const _MiniList({required this.label, required this.items});
  final String label;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800, fontVariations: Wght.w800,
            color: c.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        for (final it in items) Bullet(it, color: c.accent),
      ],
    );
  }
}
