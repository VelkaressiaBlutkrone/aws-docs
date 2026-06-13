import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/content_index.dart';
import '../../data/history_store.dart';
import '../../data/plan_check_store.dart';
import '../../data/plan_progress.dart';
import '../../data/plan_scheduler.dart';
import '../../data/site_data.dart';
import '../../data/study_plan_store.dart';
import '../../data/viewed_docs_store.dart';
import '../../models/attempt_record.dart';
import '../../theme/app_theme.dart';
import 'content_cert_card.dart';
import 'home_bits.dart';

/// 학습 일정 섹션 — 콘텐츠 보유 자격증별 플랜 진입(있으면 D-day·진행%,
/// 없으면 만들기). (PR4 분해 — home_page.dart에서 이동.)
class ScheduleSection extends StatelessWidget {
  const ScheduleSection({super.key});

  @override
  Widget build(BuildContext context) {
    final todayIso = DateTime.now().toIso8601String().substring(0, 10);
    final planStore = StudyPlanStore();
    final checkStore = PlanCheckStore();
    final viewedStore = ViewedDocsStore();
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
              summaryLabel: _label(cert.code, planStore, checkStore,
                  viewedStore, history, todayIso),
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
    PlanCheckStore checkStore,
    ViewedDocsStore viewedStore,
    List<AttemptRecord> history,
    String todayIso,
  ) {
    final plan = planStore.planFor(code);
    if (plan == null) return '시험일·기간을 정하면 일정 생성';
    final done = computePlanDone(
      plan,
      manual: checkStore.overrides(code),
      viewedTaskIds: viewedStore.viewed(code),
      history: history,
    );
    final total = plan.items.length;
    final doneN = done.values.where((v) => v).length;
    final pct = total == 0 ? 0 : (doneN / total * 100).round();
    final left = daysBetween(todayIso, plan.endIso);
    return '일정 있음 · D-${left < 0 ? 0 : left} · 진행 $pct%';
  }
}
