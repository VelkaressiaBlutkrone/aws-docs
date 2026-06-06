import 'package:flutter/material.dart';

import '../models/question.dart';
import '../theme/app_theme.dart';

/// 보기 카드 상태(연습: 공개 후 correct/wrong / 시험: 항상 idle).
enum OptState { idle, correct, wrong }

class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    required this.text,
    required this.selected,
    required this.state,
    required this.onTap,
  });
  final String text;
  final bool selected;
  final OptState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    late Color border;
    late Color bg;
    switch (state) {
      case OptState.correct:
        border = c.correct;
        bg = c.correctWeak;
      case OptState.wrong:
        border = c.wrong;
        bg = c.wrongWeak;
      case OptState.idle:
        border = selected ? c.accent : c.border;
        bg = selected ? c.accentWeak : c.surface;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.md),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(Gap.md),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(Radii.md),
            border: Border.all(color: border, width: selected ? 2 : 1),
          ),
          child: Text(text,
              style: TextStyle(fontSize: 15, height: 1.5, color: c.text)),
        ),
      ),
    );
  }
}

class ExplainBox extends StatelessWidget {
  const ExplainBox({
    super.key,
    required this.bg,
    required this.bar,
    required this.label,
    required this.text,
  });
  final Color bg;
  final Color bar;
  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Gap.md),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(Radii.sm),
        border: Border(left: BorderSide(color: bar, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w800, color: bar)),
          const SizedBox(height: Gap.xs),
          Text(text, style: TextStyle(fontSize: 15, height: 1.6, color: c.text)),
        ],
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Radii.sm),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: Gap.lg),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? c.accent : c.surface2,
          borderRadius: BorderRadius.circular(Radii.sm),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: enabled ? c.onAccent : c.textFaint)),
      ),
    );
  }
}

/// 결과 화면(연습·시험 공유). [flagged]·[subtitle]은 시험 모드에서만 전달.
class ResultsView extends StatelessWidget {
  const ResultsView({
    super.key,
    required this.bank,
    required this.picked,
    this.flagged = const {},
    this.subtitle,
  });
  final QuestionBank bank;
  final Map<int, int> picked;
  final Set<int> flagged;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    final qs = bank.questions;
    var correct = 0;
    for (var k = 0; k < qs.length; k++) {
      if (picked[k] == qs[k].correct) correct++;
    }
    final pct = qs.isEmpty ? 0 : (correct * 100 / qs.length).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('결과', style: t.headlineSmall),
        const SizedBox(height: Gap.sm),
        Text('$correct / ${qs.length}  ·  $pct%',
            style: t.displayMedium?.copyWith(color: c.accent)),
        if (subtitle != null) ...[
          const SizedBox(height: Gap.xs),
          Text(subtitle!, style: t.bodyMedium),
        ],
        const SizedBox(height: Gap.xl),
        for (var k = 0; k < qs.length; k++)
          ResultCard(
              index: k,
              q: qs[k],
              pickedIndex: picked[k],
              flagged: flagged.contains(k)),
      ],
    );
  }
}

/// 결과 화면의 문항별 복기 카드: stem + 내 답/정답 + 해설 재표시.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.index,
    required this.q,
    required this.pickedIndex,
    this.flagged = false,
  });
  final int index;
  final Question q;
  final int? pickedIndex;
  final bool flagged;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    final isCorrect = pickedIndex == q.correct;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: Gap.md),
      padding: const EdgeInsets.all(Gap.md),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(isCorrect ? Icons.check_circle : Icons.cancel,
                  size: 18, color: isCorrect ? c.correct : c.wrong),
              const SizedBox(width: Gap.sm),
              Expanded(
                  child: Text('${index + 1}. ${q.stem}',
                      style: t.bodyLarge
                          ?.copyWith(fontSize: 15, fontWeight: FontWeight.w700))),
              if (flagged)
                Padding(
                  padding: const EdgeInsets.only(left: Gap.sm),
                  child: Icon(Icons.flag, size: 16, color: c.warning),
                ),
            ],
          ),
          const SizedBox(height: Gap.sm),
          if (pickedIndex == null)
            _answerLine(context, '내 답', '(미응답)', c.wrong)
          else if (!isCorrect)
            _answerLine(context, '내 답', q.options[pickedIndex!], c.wrong),
          _answerLine(context, '정답', q.options[q.correct], c.correct),
          const SizedBox(height: Gap.xs),
          Text(q.explanation,
              style: t.bodyMedium?.copyWith(color: c.text, height: 1.6)),
          if (pickedIndex != null &&
              !isCorrect &&
              q.wrongExplanations[pickedIndex!] != null) ...[
            const SizedBox(height: Gap.xs),
            Text(q.wrongExplanations[pickedIndex!]!,
                style: t.bodyMedium?.copyWith(color: c.wrong, height: 1.6)),
          ],
        ],
      ),
    );
  }

  Widget _answerLine(
      BuildContext context, String label, String text, Color color) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.xs2),
      child: Text.rich(TextSpan(children: [
        TextSpan(
            text: '$label  ',
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w800, color: color)),
        TextSpan(
            text: text,
            style: TextStyle(fontSize: 14, color: c.text, height: 1.5)),
      ])),
    );
  }
}
