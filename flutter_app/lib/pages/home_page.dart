import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../content/reset_dialog.dart';
import '../data/content_index.dart';
import '../data/history_store.dart';
import '../data/plan_check_store.dart';
import '../data/plan_progress.dart';
import '../data/plan_scheduler.dart';
import '../data/site_data.dart';
import '../data/study_plan_store.dart';
import '../data/study_progress.dart';
import '../data/study_reset.dart';
import '../data/viewed_docs_store.dart';
import '../models/attempt_record.dart';
import '../data/weighted_exam.dart';
import '../models/certification.dart';
import '../util/open_link.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import 'home/home_header.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scroll = ScrollController();
  final _levels = GlobalKey();
  final _paths = GlobalKey();
  final _roadmaps = GlobalKey();
  final _docs = GlobalKey();
  final _exams = GlobalKey();
  final _schedule = GlobalKey();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _goto(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    // 콘텐츠가 글래스 헤더(56px) 밑으로 흐르므로(extendBodyBehindAppBar),
    // 앵커 섹션이 헤더 아래에 보이도록 헤더 높이만큼 내려 정렬한다 —
    // 이전 alignment 0.02(불투명 헤더 바로 아래)와 같은 체감.
    final viewport = _scroll.position.viewportDimension;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      alignment:
          viewport <= 0 ? 0.02 : (AppHeaderShell.height + Gap.sm) / viewport,
    );
  }

  Future<void> _resetAll() async {
    final ok = await confirmReset(
      context,
      title: '모든 학습 기록 초기화',
      message: '모든 자격증의 응시 이력·오답노트·약점 리포트·진행률·열람 기록이 '
          '전부 삭제됩니다. 진행 중인 시험 세션도 사라집니다.\n\n이 작업은 되돌릴 수 없습니다.',
      confirmLabel: '모두 초기화',
    );
    if (!ok || !mounted) return;
    resetAll();
    if (mounted) {
      setState(() {}); // 진행률 배지 등 갱신
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 학습 기록을 초기화했습니다.')),
      );
    }
  }

  Widget? _dueBanner(BuildContext context) {
    final c = context.c;
    final todayIso = DateTime.now().toIso8601String().substring(0, 10);
    // TODO: _ScheduleSection과 동일하게 스토어·computePlanDone를 build마다 로드한다.
    // cert 수가 늘면 둘의 공유 계산을 고려.
    final planStore = StudyPlanStore();
    final checkStore = PlanCheckStore();
    final viewedStore = ViewedDocsStore();
    final history = HistoryStore().all();
    var today = 0, overdue = 0, active = 0;
    String? oneCert;
    for (final cert in certifications.where((cc) => certHasContent(cc.code))) {
      final plan = planStore.planFor(cert.code);
      if (plan == null) continue;
      active++;
      oneCert = cert.code;
      final done = computePlanDone(plan,
          manual: checkStore.overrides(cert.code),
          viewedTaskIds: viewedStore.viewed(cert.code),
          history: history);
      final d = planDueCounts(plan, done, todayIso);
      today += d.today;
      overdue += d.overdue;
    }
    if (today == 0 && overdue == 0) return null;
    final parts = <String>[
      if (today > 0) '오늘 학습할 항목 $today개',
      if (overdue > 0) '지난 일정 $overdue개',
    ];
    return Padding(
      padding: const EdgeInsets.only(top: Gap.lg),
      child: InkWell(
        onTap: active == 1
            ? () => context.push('/cert/$oneCert/plan')
            : () => _goto(_schedule),
        borderRadius: BorderRadius.circular(Radii.md),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(Gap.lg),
          decoration: BoxDecoration(
            color: c.surface2,
            borderRadius: BorderRadius.circular(Radii.md),
            border: Border.all(color: c.border),
          ),
          child: Row(
            children: [
              Icon(Icons.event_available_outlined, size: 18, color: c.accent),
              const SizedBox(width: Gap.sm),
              Expanded(
                child: Text(parts.join(' · '),
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontVariations: Wght.w700, color: c.text)),
              ),
              Text('일정 보기 →',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700, fontVariations: Wght.w700,
                      color: c.accent)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      backgroundColor: c.bg,
      // 글래스 헤더: 콘텐츠가 헤더 밑으로 스크롤되어 blur·반투명이 실재한다.
      // 스크롤 상단 인셋은 body MediaQuery padding(=헤더 높이)으로 보전.
      extendBodyBehindAppBar: true,
      appBar: HomeHeader(
        onResetAll: _resetAll,
        onNav: {
          '단계': () => _goto(_levels),
          '추천 순서': () => _goto(_paths),
          '로드맵': () => _goto(_roadmaps),
          '학습 문서': () => _goto(_docs),
          '모의고사': () => _goto(_exams),
          '일정': () => _goto(_schedule),
        },
      ),
      // Builder: body MediaQuery(padding.top = 헤더 높이)를 읽으려면
      // Scaffold 아래 컨텍스트가 필요하다(페이지 컨텍스트에선 0).
      body: Builder(
        builder: (context) => SelectionArea(
          child: Scrollbar(
            controller: _scroll,
            child: SingleChildScrollView(
              controller: _scroll,
              child: Center(
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxWidth: Layout.content),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(Gap.xl,
                        MediaQuery.paddingOf(context).top, Gap.xl, Gap.xl4),
                    child: Builder(
                      builder: (context) {
                        final dueBanner = _dueBanner(context);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _Hero(),
                            ?dueBanner,
                            const _Sources(),
                            _LevelsSection(key: _levels),
                            _PathsSection(key: _paths),
                            _RoadmapSection(key: _roadmaps),
                            _StudyDocsSection(key: _docs),
                            _ExamsSection(key: _exams),
                            _ScheduleSection(key: _schedule),
                            const _Footer(),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────── Hero

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: Gap.xl4, bottom: Gap.xl3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Eyebrow('AWS 공식 시험 가이드 기준'),
          const SizedBox(height: Gap.lg),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Text.rich(
              TextSpan(children: [
                const TextSpan(text: '클라우드 자격증,\n'),
                TextSpan(text: '이해', style: TextStyle(color: c.accent)),
                const TextSpan(text: '하고 통과하기'),
              ]),
              style: t.displayLarge,
            ),
          ),
          const SizedBox(height: Gap.lg),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Text(
              '입문부터 전문 분야까지 자격증 단계, 추천 순서, 상세 학습 문서, 모의고사를 한국어로 한 곳에서. '
              '덤프 암기가 아니라 "왜"를 가르치는 이해 중심 학습 사이트입니다.',
              style: t.bodyLarge?.copyWith(color: c.textMuted, fontSize: 19),
            ),
          ),
          const SizedBox(height: Gap.xl),
          Wrap(
            spacing: Gap.md,
            runSpacing: Gap.md,
            children: const [
              _Button(label: '추천 순서 보기', primary: true),
              _Button(label: '모의고사 구성', primary: false),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────── Sources

class _Sources extends StatelessWidget {
  const _Sources();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.xl2),
      child: Wrap(
        spacing: Gap.sm,
        runSpacing: Gap.sm,
        children: [
          for (final s in officialSources)
            _SourcePill(label: s.title, href: s.href),
        ],
      ),
    );
  }
}

class _SourcePill extends StatefulWidget {
  const _SourcePill({required this.label, required this.href});
  final String label;
  final String href;

  @override
  State<_SourcePill> createState() => _SourcePillState();
}

class _SourcePillState extends State<_SourcePill> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final active = _hover;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Semantics(
        link: true,
        label: '${widget.label} (공식 자료, 새 탭으로 열기)',
        child: GestureDetector(
          onTap: () => openLink(widget.href),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(Radii.sm),
              border: Border.all(color: active ? c.accent : c.border),
            ),
            child: Text(widget.label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700, fontVariations: Wght.w700,
                    color: active ? c.accent : c.textMuted)),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────── Levels

class _LevelsSection extends StatelessWidget {
  const _LevelsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final level in certificationLevels)
          _Band(
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
    return InkWell(
      onTap: () => context.push('/cert/${cert.code}'),
      borderRadius: BorderRadius.circular(Radii.md),
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
              _Pill(label: cert.level.short, tone: _Tone.level),
              const SizedBox(width: Gap.sm),
              _Pill(label: cert.code, tone: _Tone.code),
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
            children: [for (final f in cert.focus) _Chip(label: f)],
          ),
          const SizedBox(height: Gap.md),
          _LinkText(label: '공식 가이드 보기 →'),
        ],
      ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────── Paths

class _PathsSection extends StatelessWidget {
  const _PathsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    return _Band(
      title: '추천 순서',
      meta: '목표별 기본 경로',
      child: Wrap(
        spacing: Gap.lg,
        runSpacing: Gap.lg,
        children: [
          for (final p in recommendedPaths)
            Container(
              width: 360,
              padding: const EdgeInsets.all(Gap.lg),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(Radii.md),
                border: Border.all(color: c.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.title, style: t.titleMedium),
                  const SizedBox(height: Gap.sm),
                  Text(p.steps.join('  →  '),
                      style: t.bodyMedium?.copyWith(
                          fontFeatures: const [], color: c.textMuted)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────── Roadmaps

class _RoadmapSection extends StatelessWidget {
  const _RoadmapSection({super.key});

  @override
  Widget build(BuildContext context) {
    return _Band(
      title: '자격증별 학습 로드맵',
      meta: '${certifications.length}개 로드맵',
      child: Column(
        children: [
          for (final cert in certifications)
            Padding(
              padding: const EdgeInsets.only(bottom: Gap.lg),
              child: _RoadmapCard(cert: cert),
            ),
        ],
      ),
    );
  }
}

class _RoadmapCard extends StatelessWidget {
  const _RoadmapCard({required this.cert});
  final Certification cert;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Gap.xl),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Pill(label: cert.code, tone: _Tone.code),
          const SizedBox(height: Gap.sm),
          Text(cert.title, style: t.titleLarge),
          const SizedBox(height: Gap.xs),
          Text(cert.audience, style: t.bodyMedium),
          const SizedBox(height: Gap.lg),
          for (var i = 0; i < cert.roadmap.length; i++)
            _Step(index: i + 1, text: cert.roadmap[i]),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.index, required this.text});
  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: c.accentWeak,
              borderRadius: BorderRadius.circular(Radii.full),
              border: Border.all(color: c.accent.withValues(alpha: 0.4)),
            ),
            alignment: Alignment.center,
            child: Text('$index',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800, fontVariations: Wght.w800,
                    color: c.accentStrong)),
          ),
          const SizedBox(width: Gap.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text(text,
                  style: t.bodyLarge?.copyWith(fontSize: 15, height: 1.5)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────── Study docs

class _StudyDocsSection extends StatelessWidget {
  const _StudyDocsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final withContent =
        certifications.where((c) => certHasContent(c.code)).toList();
    final pending =
        certifications.where((c) => !certHasContent(c.code)).toList();
    final viewedStore = ViewedDocsStore();
    final history = HistoryStore().all();
    return _Band(
      title: '상세 학습 문서',
      meta: '검증된 학습 콘텐츠',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: Gap.lg,
            runSpacing: Gap.lg,
            children: [
              for (final cert in withContent)
                _ContentCertCard(
                  cert: cert,
                  summaryLabel: () {
                    final s = certContentSummary(cert.code);
                    return s.questions > 0
                        ? '검증 학습문서 ${s.docs} · 총 ${s.questions}문항'
                        : '학습문서 ${s.docs} · 문항 준비 중';
                  }(),
                  cta: '학습문서 보기 →',
                  onTap: () => context.push('/cert/${cert.code}'),
                  viewedBadge: () {
                    final p = StudyProgress.build(
                      certId: cert.code,
                      allTaskIds: [for (final e in contentFor(cert.code)) e.taskId],
                      viewedTaskIds: viewedStore.viewed(cert.code),
                      history: history,
                    );
                    return p.viewedCount > 0
                        ? '열람 ${p.viewedCount}/${p.totalDocs}'
                        : null;
                  }(),
                ),
            ],
          ),
          if (pending.isNotEmpty) ...[
            const SizedBox(height: Gap.lg),
            _PendingGroup(certs: pending),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────── Exams

class _ExamsSection extends StatelessWidget {
  const _ExamsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final history = HistoryStore().all();
    final withContent =
        certifications.where((cert) => certHasVerifiedQuestions(cert.code)).toList();
    // 콘텐츠는 있으나 문항이 0인 cert(학습문서만)는 모의고사 섹션에서 의도적으로 제외
    // — 학습문서 섹션에만 노출된다.
    final pending =
        certifications.where((cert) => !certHasContent(cert.code)).toList();
    return _Band(
      title: '학습 문서 기반 모의고사',
      meta: '검증 문항 기반',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: Gap.lg,
            runSpacing: Gap.lg,
            children: [
              for (final cert in withContent)
                _ContentCertCard(
                  cert: cert,
                  summaryLabel: '통합 모의고사 · 준비 중',
                  cta: '모의고사 →',
                  onTap: () => context.push('/cert/${cert.code}/exam'),
                ),
            ],
          ),
          if (withContent.isNotEmpty) ...[
            const SizedBox(height: Gap.lg),
            for (final cert in withContent)
              () {
                final unlocked = weightedExamUnlocked(cert.code, history);
                final attempts = nonReviewAttemptCount(cert.code, history);
                return Padding(
                  padding: const EdgeInsets.only(bottom: Gap.sm),
                  child: InkWell(
                    onTap: unlocked
                        ? () => context.push('/cert/${cert.code}/exam/weak')
                        : null,
                    borderRadius: BorderRadius.circular(Radii.md),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(Gap.lg),
                      decoration: BoxDecoration(
                        color: c.surface,
                        borderRadius: BorderRadius.circular(Radii.md),
                        border: Border.all(color: c.border),
                      ),
                      child: Row(
                        children: [
                          Icon(
                              unlocked
                                  ? Icons.bolt_outlined
                                  : Icons.lock_outline,
                              size: 18,
                              color: unlocked ? c.accent : c.textFaint),
                          const SizedBox(width: Gap.sm),
                          Expanded(
                            child: Text(
                                unlocked
                                    ? '${cert.title} · 약점 집중 모의고사'
                                    : '${cert.title} · 약점 집중 모의고사 (응시 기록 $attempts/$kWeightedExamMinAttempts)',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700, fontVariations: Wght.w700,
                                    color: unlocked ? c.text : c.textMuted)),
                          ),
                          if (unlocked)
                            Text('약점 모의고사 →',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700, fontVariations: Wght.w700,
                                    color: c.accent)),
                        ],
                      ),
                    ),
                  ),
                );
              }(),
          ],
          if (pending.isNotEmpty) ...[
            const SizedBox(height: Gap.lg),
            _PendingGroup(certs: pending),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────── Schedule

/// 학습 일정 섹션 — 콘텐츠 보유 자격증별 플랜 진입(있으면 D-day·진행%, 없으면 만들기).
class _ScheduleSection extends StatelessWidget {
  const _ScheduleSection({super.key});

  @override
  Widget build(BuildContext context) {
    final todayIso = DateTime.now().toIso8601String().substring(0, 10);
    final planStore = StudyPlanStore();
    final checkStore = PlanCheckStore();
    final viewedStore = ViewedDocsStore();
    final history = HistoryStore().all();
    final certs =
        certifications.where((cert) => certHasContent(cert.code)).toList();
    return _Band(
      title: '학습 일정',
      meta: '시험일까지 단계별 계획',
      child: Wrap(
        spacing: Gap.lg,
        runSpacing: Gap.lg,
        children: [
          for (final cert in certs)
            _ContentCertCard(
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

/// 콘텐츠 보유 자격증 진입 카드(학습문서/모의고사 공용).
class _ContentCertCard extends StatelessWidget {
  const _ContentCertCard({
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Radii.md),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: c.surface2,
                borderRadius: BorderRadius.circular(Radii.full),
              ),
              child: Text(summaryLabel,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700, fontVariations: Wght.w700,
                      color: c.textMuted)),
            ),
            if (viewedBadge != null) ...[
              const SizedBox(height: Gap.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: c.accentWeak,
                  borderRadius: BorderRadius.circular(Radii.full),
                ),
                child: Text(viewedBadge!,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800, fontVariations: Wght.w800,
                        color: c.accentStrong)),
              ),
            ],
            const SizedBox(height: Gap.md),
            Text(cta,
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700, fontVariations: Wght.w700, color: c.accent)),
          ],
        ),
      ),
    );
  }
}

/// 콘텐츠 미보유 자격증을 "준비 중" 코드 칩으로 묶음.
class _PendingGroup extends StatelessWidget {
  const _PendingGroup({required this.certs});
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
                  fontSize: 12, fontWeight: FontWeight.w800, fontVariations: Wght.w800, color: c.textMuted)),
          const SizedBox(height: Gap.sm),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [for (final cert in certs) _Chip(label: cert.code)],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────── Footer

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: Gap.xl3),
      padding: const EdgeInsets.only(top: Gap.xl),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: Text(
        '비공식 학습 사이트 · 응시 전 반드시 AWS 공식 시험 가이드를 단일 진실 공급원으로 확인하세요.',
        style: TextStyle(fontSize: 13, color: c.textFaint),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────── Shared

class _Band extends StatelessWidget {
  const _Band({required this.title, required this.meta, required this.child});
  final String title;
  final String meta;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: Gap.xl2),
      padding: const EdgeInsets.only(top: Gap.xl2),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: Text(title, style: t.headlineSmall)),
              Text(meta,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600, fontVariations: Wght.w600,
                      color: c.textFaint)),
            ],
          ),
          const SizedBox(height: Gap.xl),
          child,
        ],
      ),
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(Radii.full),
        border: Border.all(color: c.borderStrong),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, fontVariations: Wght.w700, color: c.textMuted)),
    );
  }
}

enum _Tone { level, code }

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.tone});
  final String label;
  final _Tone tone;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    late final Color bg;
    late final Color fg;
    switch (tone) {
      case _Tone.level:
        bg = c.infoWeak;
        fg = c.info;
      case _Tone.code:
        bg = c.surface2;
        fg = c.textMuted;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(Radii.full),
      ),
      child: Text(label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700, fontVariations: Wght.w700,
            color: fg,
            fontFamily: tone == _Tone.code ? AppTheme.monoFamily : null,
          )),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(Radii.full),
        border: Border.all(color: c.border),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, fontVariations: Wght.w600, color: c.textMuted)),
    );
  }
}

class _LinkText extends StatelessWidget {
  const _LinkText({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Text(label,
        style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w700, fontVariations: Wght.w700, color: c.accent));
  }
}

class _Button extends StatelessWidget {
  const _Button({required this.label, required this.primary});
  final String label;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: Gap.lg),
      decoration: BoxDecoration(
        color: primary ? c.accent : c.surface,
        borderRadius: BorderRadius.circular(Radii.sm),
        border: Border.all(color: primary ? c.accent : c.borderStrong),
      ),
      alignment: Alignment.center,
      child: Text(label,
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700, fontVariations: Wght.w700,
              color: primary ? c.onAccent : c.text)),
    );
  }
}
