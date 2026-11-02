import 'package:flutter/material.dart';

import '../models/question.dart';
import '../theme/app_theme.dart';
import '../widgets/focus_ring.dart';

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
    // 선택·채점 상태가 색으로만 전달되면 스크린리더에는 "텍스트, 버튼"으로만
    // 읽힌다(리뷰 M-7). 라디오처럼 **배타 그룹 + 선택 상태**로 노출하고,
    // 채점 뒤에는 정답·오답을 라벨에 담는다. 가드는 `exam_a11y_semantics_test.dart`.
    final stateSuffix = switch (state) {
      OptState.correct => ', 정답',
      OptState.wrong => ', 오답',
      OptState.idle => '',
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.sm),
      // 인셋 링(DT4): 선택지는 키보드(Tab→Enter/Space)로도 답할 수 있어야 한다.
      child: InsetFocusRing(
        child: Semantics(
          label: '$text$stateSuffix',
          selected: selected,
          inMutuallyExclusiveGroup: true,
          button: onTap != null,
          onTap: onTap,
          excludeSemantics: true,
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
                  fontSize: 12, fontWeight: FontWeight.w800, fontVariations: Wght.w800, color: bar)),
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
    return InsetFocusRing(
      borderRadius: BorderRadius.circular(Radii.sm),
      child: InkWell(
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
                  fontWeight: FontWeight.w700, fontVariations: Wght.w700,
                  color: enabled ? c.onAccent : c.textFaint)),
        ),
      ),
    );
  }
}

/// 결과 복기 필터(UX-5). 기본은 [wrong] — 오답이 있을 때.
enum ResultFilter { all, wrong, flagged }

/// 결과 복기 필터 칩. 선택 상태는 액센트 톤으로(DESIGN.md — 칩은 full radius).
class _FilterChip extends StatelessWidget {
  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return InsetFocusRing(
      borderRadius: BorderRadius.circular(Radii.full),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.full),
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: Gap.lg),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? c.accentWeak : c.surface,
            borderRadius: BorderRadius.circular(Radii.full),
            border: Border.all(color: selected ? c.accent : c.border),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700, fontVariations: Wght.w700,
                  color: selected ? c.accentStrong : c.textMuted)),
        ),
      ),
    );
  }
}

/// 결과 화면(연습·시험 공유). [flagged]·[subtitle]은 시험 모드에서만 전달.
class ResultsView extends StatefulWidget {
  const ResultsView({
    super.key,
    required this.bank,
    required this.picked,
    this.flagged = const {},
    this.subtitle,
    this.onOpenStudy,
  });
  final QuestionBank bank;
  final Map<int, int> picked;
  final Set<int> flagged;
  final String? subtitle;

  /// 오답 카드의 개념 라벨 → 해당 Task 학습문서의 섹션 이동. null이면 링크 숨김.
  final void Function(String taskId, String section)? onOpenStudy;

  @override
  State<ResultsView> createState() => _ResultsViewState();
}

class _ResultsViewState extends State<ResultsView> {
  ResultFilter? _filter; // null = 아직 고르지 않음 → 기본값을 계산해 쓴다

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    final qs = widget.bank.questions;
    final isWrong = [
      for (var k = 0; k < qs.length; k++) widget.picked[k] != qs[k].correct,
    ]; // 미응답(null)도 오답
    final wrongCount = isWrong.where((w) => w).length;
    final correct = qs.length - wrongCount;
    final pct = qs.isEmpty ? 0 : (correct * 100 / qs.length).round();
    final flaggedCount =
        widget.flagged.where((k) => k >= 0 && k < qs.length).length;

    // 오답이 있으면 오답부터 보여 준다 — 65장을 훑어 오답을 찾게 하지 않는다.
    final filter =
        _filter ?? (wrongCount == 0 ? ResultFilter.all : ResultFilter.wrong);

    // 필터가 집합을 실제로 가르지 못하면 칩을 그리지 않는다 — 고를 것이 없는
    // 선택지는 정보가 아니라 소음이다(전부 정답, 또는 전부 오답에 플래그 없음).
    final showChips =
        wrongCount > 0 && (wrongCount < qs.length || flaggedCount > 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('결과', style: t.headlineSmall),
        const SizedBox(height: Gap.sm),
        Text('$correct / ${qs.length}  ·  $pct%',
            style: t.displayMedium?.copyWith(color: c.accent)),
        if (widget.subtitle != null) ...[
          const SizedBox(height: Gap.xs),
          Text(widget.subtitle!, style: t.bodyMedium),
        ],
        if (showChips) ...[
          const SizedBox(height: Gap.lg),
          Wrap(
            spacing: Gap.sm,
            runSpacing: Gap.sm,
            children: [
              _FilterChip(
                  label: '전체 ${qs.length}',
                  selected: filter == ResultFilter.all,
                  onTap: () => setState(() => _filter = ResultFilter.all)),
              _FilterChip(
                  label: '오답 $wrongCount',
                  selected: filter == ResultFilter.wrong,
                  onTap: () => setState(() => _filter = ResultFilter.wrong)),
              if (flaggedCount > 0)
                _FilterChip(
                    label: '플래그 $flaggedCount',
                    selected: filter == ResultFilter.flagged,
                    onTap: () =>
                        setState(() => _filter = ResultFilter.flagged)),
            ],
          ),
        ],
        const SizedBox(height: Gap.xl),
        for (var k = 0; k < qs.length; k++)
          if (switch (filter) {
            ResultFilter.all => true,
            ResultFilter.wrong => isWrong[k],
            ResultFilter.flagged => widget.flagged.contains(k),
          })
            ResultCard(
                index: k,
                q: qs[k],
                pickedIndex: widget.picked[k],
                flagged: widget.flagged.contains(k),
                // 오답이 하나라도 있을 때만 정답 카드를 접는다 — 전부 정답인 결과의
                // 할 일은 분류가 아니라 복기다(연습 퀴즈 스펙 §9.3).
                collapseWhenCorrect: wrongCount > 0,
                onOpenStudy: widget.onOpenStudy),
      ],
    );
  }
}

/// 결과 화면의 문항별 복기 카드: stem + 내 답/정답 + 해설 재표시.
class ResultCard extends StatefulWidget {
  const ResultCard({
    super.key,
    required this.index,
    required this.q,
    required this.pickedIndex,
    this.flagged = false,
    this.onOpenStudy,
    this.collapseWhenCorrect = false,
  });
  final int index;
  final Question q;
  final int? pickedIndex;
  final bool flagged;

  /// 오답이고 개념(skill) 태그가 있을 때 학습문서 섹션으로 보내는 콜백. null이면 링크 숨김.
  final void Function(String taskId, String section)? onOpenStudy;

  /// **정답일 때** 접은 채 시작할지(UX-5·M-10). 호출자는 오답이 하나라도 있을 때만 켠다
  /// — 전부 정답인 결과 화면의 할 일은 분류가 아니라 복기이고, 그때 카드를 접으면
  /// 스펙 §9.3이 약속한 "정답 라벨 + 해설 재표시"가 사라진다.
  final bool collapseWhenCorrect;

  @override
  State<ResultCard> createState() => _ResultCardState();
}

class _ResultCardState extends State<ResultCard> {
  /// 접을 수 있는 카드는 접힌 채 시작한다 — 머리글만 그리므로 "전체" 복기에서도
  /// 대부분이 가볍다. 오답 카드는 복기해야 하는 쪽이라 접지 않는다.
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    final q = widget.q;
    final index = widget.index;
    final flagged = widget.flagged;
    final onOpenStudy = widget.onOpenStudy;
    final pickedIndex = widget.pickedIndex;
    final isCorrect = pickedIndex == q.correct;
    final collapsible = isCorrect && widget.collapseWhenCorrect;
    final open = !collapsible || _expanded;

    final header = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(isCorrect ? Icons.check_circle : Icons.cancel,
            size: 18, color: isCorrect ? c.correct : c.wrong),
        const SizedBox(width: Gap.sm),
        Expanded(
            child: Text('${index + 1}. ${q.stem}',
                style: t.bodyLarge
                    ?.copyWith(fontSize: 15, fontWeight: FontWeight.w700, fontVariations: Wght.w700))),
        if (flagged)
          Padding(
            padding: const EdgeInsets.only(left: Gap.sm),
            child: Icon(Icons.flag, size: 16, color: c.warning),
          ),
        if (collapsible)
          Padding(
            padding: const EdgeInsets.only(left: Gap.sm),
            child: Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                size: 18, color: c.textMuted),
          ),
      ],
    );

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
          if (collapsible)
            InsetFocusRing(
              borderRadius: BorderRadius.circular(Radii.sm),
              child: InkWell(
                onTap: () => setState(() => _expanded = !_expanded),
                borderRadius: BorderRadius.circular(Radii.sm),
                child: header,
              ),
            )
          else
            header,
          if (open) ...[
          const SizedBox(height: Gap.sm),
          if (pickedIndex == null)
            _answerLine(context, '내 답', '(미응답)', c.wrong)
          else if (!isCorrect)
            _answerLine(context, '내 답', q.options[pickedIndex], c.wrong),
          _answerLine(context, '정답', q.options[q.correct], c.correct),
          const SizedBox(height: Gap.xs),
          Text(q.explanation,
              style: t.bodyMedium?.copyWith(color: c.text, height: 1.6)),
          if (pickedIndex != null &&
              !isCorrect &&
              q.wrongExplanations[pickedIndex] != null) ...[
            const SizedBox(height: Gap.xs),
            Text(q.wrongExplanations[pickedIndex]!,
                style: t.bodyMedium?.copyWith(color: c.wrong, height: 1.6)),
          ],
          // 처방(C-경량): 오답이고 개념 태그가 있으면 개념 라벨 + 학습문서 링크.
          // 정답 문항·무태그 문항은 표시하지 않는다.
          if (!isCorrect && q.skill.isNotEmpty) ...[
            const SizedBox(height: Gap.md),
            _ConceptCue(
              skill: q.skill,
              onOpenStudy: onOpenStudy == null
                  ? null
                  : () => onOpenStudy(q.examGuideTaskId, q.section),
            ),
          ],
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
                fontSize: 12, fontWeight: FontWeight.w800, fontVariations: Wght.w800, color: color)),
        TextSpan(
            text: text,
            style: TextStyle(fontSize: 14, color: c.text, height: 1.5)),
      ])),
    );
  }
}

/// 오답 복기 카드의 개념 처방 큐.
/// DESIGN.md 정합(2026-06-09 D3): 칩은 중립색(라벨), 액센트는 학습 링크에만.
///   [ skill 라벨 ]  → 학습문서
class _ConceptCue extends StatelessWidget {
  const _ConceptCue({required this.skill, this.onOpenStudy});
  final String skill;
  final VoidCallback? onOpenStudy;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: Gap.sm, vertical: Gap.xs),
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: BorderRadius.circular(Radii.full),
      ),
      child: Text(skill,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, fontVariations: Wght.w700, color: c.textMuted)),
    );
    return Wrap(
      spacing: Gap.sm,
      runSpacing: Gap.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        chip,
        if (onOpenStudy != null)
          InsetFocusRing(
            borderRadius: BorderRadius.circular(Radii.sm),
            child: InkWell(
              onTap: onOpenStudy,
              borderRadius: BorderRadius.circular(Radii.sm),
              child: Padding(
                // 44px 터치 타깃 확보.
                padding: const EdgeInsets.symmetric(
                    vertical: Gap.md, horizontal: Gap.xs),
                child: Text('→ 학습문서',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700, fontVariations: Wght.w700,
                        color: c.accent)),
              ),
            ),
          ),
      ],
    );
  }
}

/// 응시 기록 저장이 실패했을 때(localStorage 쿼터 초과·브라우저 저장 차단 등)
/// 사용자에게 알린다. 결과 화면 자체는 러너의 try/finally가 열어 주므로,
/// 여기서는 "기록이 남지 않았다"는 사실만 알린다.
void notifyAttemptSaveFailure(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('기록을 저장하지 못했습니다. 저장 공간이 부족하거나 브라우저가 저장을 막았을 수 있습니다.'),
    ),
  );
}
