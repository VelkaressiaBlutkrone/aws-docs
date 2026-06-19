import 'package:flutter/material.dart';

import '../../data/plan_progress_store.dart';
import '../../data/plan_progress_view.dart';
import '../../data/plan_scheduler.dart';
import '../../models/attempt_record.dart';
import '../../models/study_plan.dart';
import '../../theme/app_theme.dart';
import '../../widgets/focus_ring.dart';

/// 자격증의 학습 일정 목록 — 카드 탭으로 어젠다 진입, 하단 "일정 추가".
/// (멀티 일정 — Part 2.)
class PlanListView extends StatelessWidget {
  const PlanListView({
    super.key,
    required this.plans,
    required this.progress,
    required this.history,
    required this.today,
    required this.onOpen,
    required this.onCreate,
  });
  final List<StudyPlan> plans;
  final PlanProgressStore progress;
  final List<AttemptRecord> history;
  final String today;
  final ValueChanged<StudyPlan> onOpen;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.all(Gap.xl),
          children: [
            if (plans.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: Gap.lg),
                child: Text('아직 일정이 없습니다. 아래에서 첫 일정을 만들어 보세요.',
                    style: t.bodyMedium?.copyWith(color: c.textMuted)),
              ),
            for (final plan in plans) _card(context, plan),
            const SizedBox(height: Gap.sm),
            FocusTap(
              onTap: onCreate,
              radius: Radii.md,
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(Radii.md),
                  border: Border.all(color: c.accent, width: 1.5),
                ),
                child: Text('+ 일정 추가',
                    style: TextStyle(
                        color: c.accent,
                        fontWeight: FontWeight.w700,
                        fontVariations: Wght.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(BuildContext context, StudyPlan plan) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    final done = planDone(plan, progress, history);
    final total = plan.items.length;
    final doneN = done.values.where((v) => v).length;
    final pct = total == 0 ? 0 : (doneN / total * 100).round();
    final left = daysBetween(today, plan.endIso);
    final label = plan.label.isNotEmpty ? plan.label : '학습 일정';
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.md),
      child: FocusTap(
        onTap: () => onOpen(plan),
        radius: Radii.md,
        child: Container(
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
                  Expanded(child: Text(label, style: t.titleMedium)),
                  Text('D-${left < 0 ? 0 : left}',
                      style: t.labelLarge?.copyWith(
                          color: c.accent, fontFamily: AppTheme.monoFamily)),
                ],
              ),
              const SizedBox(height: Gap.xs),
              Text('${plan.startIso} ~ ${plan.endIso} · 항목 $total · 진행 $pct%',
                  style: t.bodySmall?.copyWith(color: c.textMuted)),
              const SizedBox(height: Gap.sm),
              LinearProgressIndicator(
                value: total == 0 ? 0 : doneN / total,
                backgroundColor: c.surface2,
                color: c.accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
