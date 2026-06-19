import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../content/reset_dialog.dart';
import '../data/content_index.dart';
import '../data/history_store.dart';
import '../data/plan_progress.dart';
import '../data/plan_progress_store.dart';
import '../data/plan_progress_view.dart';
import '../data/site_data.dart';
import '../data/study_plan_store.dart';
import '../data/study_reset.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/focus_ring.dart';
import 'home/exams_section.dart';
import 'home/footer_section.dart';
import 'home/hero_section.dart';
import 'home/home_header.dart';
import 'home/levels_section.dart';
import 'home/paths_section.dart';
import 'home/roadmap_section.dart';
import 'home/schedule_section.dart';
import 'home/study_docs_section.dart';

/// 홈 — 섹션 위젯들은 `pages/home/`(PR4 분해), 이 파일은 골격(스크롤·앵커·
/// 헤더 배선·오늘-할-일 배너)만 가진다.
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
    // TODO: ScheduleSection과 동일하게 스토어·computePlanDone를 build마다 로드한다.
    // cert 수가 늘면 둘의 공유 계산을 고려.
    final planStore = StudyPlanStore();
    final progress = PlanProgressStore();
    final history = HistoryStore().all();
    var today = 0, overdue = 0, active = 0;
    String? oneCert;
    for (final cert in certifications.where((cc) => certHasContent(cc.code))) {
      final plans = planStore.plansFor(cert.code);
      if (plans.isEmpty) continue;
      active++;
      oneCert = cert.code;
      for (final plan in plans) {
        final done = planDone(plan, progress, history);
        final d = planDueCounts(plan, done, todayIso);
        today += d.today;
        overdue += d.overdue;
      }
    }
    if (today == 0 && overdue == 0) return null;
    final parts = <String>[
      if (today > 0) '오늘 학습할 항목 $today개',
      if (overdue > 0) '지난 일정 $overdue개',
    ];
    return Padding(
      padding: const EdgeInsets.only(top: Gap.lg),
      child: FocusTap(
        onTap: active == 1
            ? () => context.push('/cert/$oneCert/plan')
            : () => _goto(_schedule),
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
                            const HeroSection(),
                            ?dueBanner,
                            const SourcesRow(),
                            LevelsSection(key: _levels),
                            PathsSection(key: _paths),
                            RoadmapSection(key: _roadmaps),
                            StudyDocsSection(key: _docs),
                            ExamsSection(key: _exams),
                            ScheduleSection(key: _schedule),
                            const HomeFooter(),
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
