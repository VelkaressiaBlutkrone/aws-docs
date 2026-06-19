import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/content_index.dart';
import '../../data/history_store.dart';
import '../../data/plan_progress_store.dart';
import '../../data/plan_progress_view.dart';
import '../../data/plan_scheduler.dart';
import '../../data/site_data.dart';
import '../../data/study_plan_store.dart';
import '../../models/attempt_record.dart';
import '../../theme/app_theme.dart';
import 'content_cert_card.dart';
import 'home_bits.dart';

/// 학습 일정 섹션 — 콘텐츠 보유 자격증별 일정(들) 진입. 여러 일정이면 합산
/// 요약(개수·가장 이른 종료일 D-day·진행%). (멀티 일정 — Part 2 배선.)
class ScheduleSection extends StatelessWidget {
  const ScheduleSection({super.key});

  @override
  Widget build(BuildContext context) {
    final todayIso = DateTime.now().toIso8601String().substring(0, 10);
    final planStore = StudyPlanStore();
    final progress = PlanProgressStore();
    final history = HistoryStore().all();
    final certs =
        certifications.where((cert) => certHasContent(cert.code)).toList();
    return HomeBand(
      title: '학습 일정',
      meta: '시험일까지 단계별 계획',
      child: Wrap(
        spacing: Gap.lg,
        runSpacing: Gap.lg,
        children: [
          for (final cert in certs)
            ContentCertCard(
              cert: cert,
              summaryLabel:
                  _label(cert.code, planStore, progress, history, todayIso),
              cta: '일정 →',
              onTap: () => context.push('/cert/${cert.code}/plan'),
            ),
        ],
      ),
    );
  }

  String _label(
    String code,
    StudyPlanStore planStore,
    PlanProgressStore progress,
    List<AttemptRecord> history,
    String todayIso,
  ) {
    final plans = planStore.plansFor(code);
    if (plans.isEmpty) return '시험일·기간을 정하면 일정 생성';
    var total = 0, doneN = 0;
    String? earliestEnd;
    for (final plan in plans) {
      final done = planDone(plan, progress, history);
      total += plan.items.length;
      doneN += done.values.where((v) => v).length;
      if (earliestEnd == null || plan.endIso.compareTo(earliestEnd) < 0) {
        earliestEnd = plan.endIso;
      }
    }
    final pct = total == 0 ? 0 : (doneN / total * 100).round();
    final left = daysBetween(todayIso, earliestEnd!);
    return '일정 ${plans.length}개 · D-${left < 0 ? 0 : left} · 진행 $pct%';
  }
}
