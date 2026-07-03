import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'
    show RenderAbstractViewport, ScrollCacheExtent;
import 'package:go_router/go_router.dart';

import '../../data/cert_lookup.dart';
import '../../data/history_store.dart';
import '../../data/plan_month.dart';
import '../../data/plan_progress.dart';
import '../../data/plan_progress_store.dart';
import '../../data/plan_progress_view.dart';
import '../../data/plan_scheduler.dart';
import '../../models/certification.dart';
import '../../models/study_plan.dart';
import '../../theme/app_theme.dart';
import '../../widgets/focus_ring.dart';
import 'plan_summary.dart';

/// 학습 일정 어젠다(Task 7) — 진행 헤더(SliverAppBar) + 날짜별 목록/월 보기.
/// (PR4 분해 — plan_page.dart에서 이동.)
class PlanAgenda extends StatefulWidget {
  const PlanAgenda(
      {super.key,
      required this.cert,
      required this.plan,
      required this.today,
      required this.onEdit,
      required this.onChanged,
      this.onDelete,
      this.backend});
  final Certification cert;
  final StudyPlan plan;
  final String today;
  final VoidCallback onEdit;
  final ValueChanged<StudyPlan> onChanged;
  final VoidCallback? onDelete;
  final KvBackend? backend;

  @override
  State<PlanAgenda> createState() => _PlanAgendaState();
}

class _PlanAgendaState extends State<PlanAgenda> {
  late final _progress = PlanProgressStore(backend: widget.backend);
  late final _history = HistoryStore(backend: widget.backend);
  bool _month = false;
  final _dateKeys = <String, GlobalKey>{};
  String? _scrollToDate;

  Map<String, bool> _done() =>
      planDone(widget.plan, _progress, _history.all());

  void _toggle(String itemId, bool current) {
    _progress.setDone(widget.plan.id, itemId, !current);
    setState(() {});
  }

  void _open(PlanItem it) {
    final code = widget.cert.code;
    switch (it.type) {
      case PlanItemType.doc:
        if (it.refId != null) context.push('/cert/$code/study/${it.refId}');
      case PlanItemType.quiz:
        if (it.refId != null) {
          context.push('/cert/$code/study/${it.refId}/quiz');
        }
      case PlanItemType.mockExam:
        context.push('/cert/$code/exam');
      case PlanItemType.weakExam:
        context.push('/cert/$code/exam/weak');
      case PlanItemType.finalReview:
        context.push('/cert/$code/review');
    }
  }

  static const _typeLabel = {
    PlanItemType.doc: '학습',
    PlanItemType.quiz: '연습',
    PlanItemType.mockExam: '모의고사',
    PlanItemType.weakExam: '약점',
    PlanItemType.finalReview: '점검',
  };

  String _title(PlanItem it) {
    if (it.refId == null) return _typeLabel[it.type]!;
    final e = entryByTask(widget.cert.code, it.refId!);
    return e?.title ?? '(삭제된 항목)';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    final done = _done();
    final s = planSummary(widget.plan, done, widget.today);

    final byDate = <String, List<PlanItem>>{};
    for (final it in [...widget.plan.items]
      ..sort((a, b) => a.dateIso.compareTo(b.dateIso))) {
      (byDate[it.dateIso] ??= []).add(it);
    }
    final dates = byDate.keys.toList()..sort();

    if (!_month && _scrollToDate != null) {
      final target = _scrollToDate!;
      _scrollToDate = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _runScrollToDate(target, dates, 24);
      });
    }

    final header = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text('D-${s.daysLeft}',
                style: t.titleLarge?.copyWith(
                    color: c.accent, fontFamily: AppTheme.monoFamily)),
            const SizedBox(width: Gap.md),
            Flexible(
              child: Text('진행 ${s.done}/${s.total} (${s.percent}%)',
                  overflow: TextOverflow.ellipsis,
                  style: t.bodyMedium?.copyWith(color: c.textMuted)),
            ),
            const Spacer(),
            IconButton(
              tooltip: _month ? '어젠다' : '월 보기',
              visualDensity: VisualDensity.compact,
              icon: Icon(
                  _month
                      ? Icons.view_agenda_outlined
                      : Icons.calendar_month_outlined,
                  size: 20,
                  color: c.textMuted),
              onPressed: () => setState(() => _month = !_month),
            ),
            TextButton(
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: Gap.sm),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {
                final messenger = ScaffoldMessenger.of(context);
                final done = _done();
                final doneIds = {
                  for (final e in done.entries)
                    if (e.value) e.key
                };
                final r = redistribute(widget.plan, widget.today, doneIds);
                widget.onChanged(StudyPlan(
                  certCode: widget.plan.certCode,
                  startIso: widget.plan.startIso,
                  endIso: widget.plan.endIso,
                  mode: widget.plan.mode,
                  createdIso: widget.plan.createdIso,
                  items: r.items,
                ));
                if (r.warnings.isNotEmpty) {
                  messenger.showSnackBar(
                      SnackBar(content: Text(r.warnings.first)));
                }
              },
              child: const Text('재분배'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: Gap.sm),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: widget.onEdit,
              child: const Text('다시 만들기'),
            ),
            if (widget.onDelete != null)
              IconButton(
                tooltip: '일정 삭제',
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.delete_outline, size: 20, color: c.textMuted),
                onPressed: widget.onDelete,
              ),
          ],
        ),
        const SizedBox(height: Gap.sm),
        LinearProgressIndicator(
          value: s.total == 0 ? 0 : s.done / s.total,
          backgroundColor: c.surface2,
          color: c.accent,
        ),
      ],
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                floating: true,
                snap: true,
                automaticallyImplyLeading: false,
                backgroundColor: c.bg,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                // 헤더 Row(D-day/진행/토글/버튼) + 진행바 + 상하 패딩이 들어갈 높이.
                toolbarHeight: 88,
                flexibleSpace: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(Gap.xl, Gap.md, Gap.xl, Gap.sm),
                    child: header,
                  ),
                ),
              ),
            ),
          ],
          body: Builder(
            builder: (context) => CustomScrollView(
              key: const Key('plan-agenda-scroll'),
              // 만료 배너/날짜 헤더가 적당히 선마운트되도록 절제된 오버스캔.
              // (scrollCacheExtent: 9999 핵 대신) 수 개월 플랜에서도 _runScrollToDate의
              // 스텝 횟수를 줄여 주는 정도의 보수적인 값.
              scrollCacheExtent: const ScrollCacheExtent.pixels(1200),
              slivers: [
                SliverOverlapInjector(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(Gap.xl),
                  sliver: _month
                      ? SliverToBoxAdapter(child: _monthView(c, t, done))
                      : SliverList(
                          delegate: SliverChildListDelegate([
                            if (daysBetween(widget.today, widget.plan.endIso) <
                                0)
                              Container(
                                margin: const EdgeInsets.only(bottom: Gap.md),
                                padding: const EdgeInsets.all(Gap.md),
                                decoration: BoxDecoration(
                                  color: c.surface2,
                                  borderRadius:
                                      BorderRadius.circular(Radii.md),
                                  border: Border.all(color: c.border),
                                ),
                                child: Text(
                                    '학습 기간이 종료됐습니다. "다시 만들기"로 새 일정을 만들거나 기간을 연장하세요.',
                                    style: t.bodySmall
                                        ?.copyWith(color: c.textMuted)),
                              ),
                            for (final date in dates) ...[
                              _dayHeader(c, t, date,
                                  _dateKeys.putIfAbsent(date, () => GlobalKey())),
                              for (final it in byDate[date]!)
                                _itemRow(c, t, it, done[it.id] == true,
                                    isOverdue(it, widget.today,
                                        done[it.id] == true)),
                              const SizedBox(height: Gap.md),
                            ],
                          ]),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 탭한 날짜로 본문(inner body)을 스크롤한다.
  ///
  /// SliverList는 화면 밖 자식을 지연 마운트하므로, 멀리 떨어진 날짜 헤더의
  /// GlobalKey.currentContext가 null일 수 있다(→ ensureVisible no-op). 그래서:
  /// 1) 대상이 이미 마운트돼 있으면 곧장 ensureVisible로 정렬한다.
  /// 2) 아니면 현재 마운트된 헤더 중 대상에 가장 가까운 것을 뷰포트 끝으로 즉시
  ///    스크롤해(한 화면씩 대상 쪽으로 이동) 대상 주변을 마운트시킨 뒤, 다음
  ///    프레임에 자신을 재호출한다(retries 예산만큼). cacheExtent:1200과 합쳐져
  ///    수 개월 길이 플랜에서도 몇 스텝 안에 대상에 도달한다. 패키지/핵 없음.
  void _runScrollToDate(String target, List<String> dates, int retriesLeft) {
    if (!mounted || _month) return;
    final targetCtx = _dateKeys[target]?.currentContext;
    if (targetCtx != null) {
      _revealInBody(targetCtx);
      return;
    }
    if (retriesLeft <= 0) return;

    final targetIdx = dates.indexOf(target);
    if (targetIdx < 0) return;

    // 마운트된 헤더 중 대상 인덱스에 가장 가까운 것을 찾는다.
    BuildContext? stepCtx;
    int stepIdx = -1;
    var bestDist = 1 << 30;
    for (var i = 0; i < dates.length; i++) {
      final ctx = _dateKeys[dates[i]]?.currentContext;
      if (ctx == null) continue;
      final dist = (i - targetIdx).abs();
      if (dist < bestDist) {
        bestDist = dist;
        stepCtx = ctx;
        stepIdx = i;
      }
    }
    if (stepCtx == null) return; // 마운트된 헤더가 전혀 없으면 포기(안전).

    // 대상이 아래쪽이면 가장 가까운 헤더를 뷰포트 상단(0.0)으로,
    // 위쪽이면 하단(1.0)으로 즉시 스크롤해 대상 쪽으로 한 화면 이동.
    _revealInBody(stepCtx,
        alignment: targetIdx >= stepIdx ? 0.0 : 1.0, animate: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runScrollToDate(target, dates, retriesLeft - 1);
    });
  }

  /// 본문(NestedScrollView body) 스크롤러를 **직접** 구동해 [ctx]를 드러낸다.
  ///
  /// NestedScrollView body + floating SliverAppBar 조합에서 `Scrollable.ensureVisible`은
  /// 코디네이터를 거치며 floating 헤더의 snap과 충돌해 inner 오프셋이 0으로 되돌아간다.
  /// 그래서 ensureVisible 대신 inner ScrollPosition을 찾아 getOffsetToReveal로
  /// 목표 오프셋을 계산하고 animateTo/jumpTo로 직접 이동시킨다.
  void _revealInBody(BuildContext ctx,
      {double alignment = 0.05, bool animate = true}) {
    final ro = ctx.findRenderObject();
    if (ro == null) return;
    final position = Scrollable.of(ctx).position;
    final viewport = RenderAbstractViewport.of(ro);
    final target = viewport
        .getOffsetToReveal(ro, alignment)
        .offset
        .clamp(position.minScrollExtent, position.maxScrollExtent);
    if (animate) {
      position.animateTo(target,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      position.jumpTo(target);
    }
  }

  Widget _dayHeader(AppColors c, TextTheme t, String date, Key key) {
    final isToday = date == widget.today;
    return Padding(
      key: key,
      padding: const EdgeInsets.only(bottom: Gap.xs),
      child: Text(isToday ? '$date · 오늘' : date,
          style: t.labelLarge?.copyWith(
              color: isToday ? c.accent : c.textMuted,
              fontWeight: FontWeight.w800, fontVariations: Wght.w800)),
    );
  }

  Widget _itemRow(
      AppColors c, TextTheme t, PlanItem it, bool done, bool overdue) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.xs2),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: Gap.md, vertical: Gap.sm),
        decoration: BoxDecoration(
          color: overdue ? c.wrongWeak : c.surface,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(
              color: overdue ? c.wrong.withValues(alpha: 0.35) : c.border),
        ),
        child: Row(
          children: [
            Checkbox(
              value: done,
              onChanged: (_) => _toggle(it.id, done),
              activeColor: c.accent,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            Expanded(
              child: FocusTap(
                onTap: () => _open(it),
                radius: Radii.sm,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: Gap.sm),
                  child: Row(
                    children: [
                      Text(_typeLabel[it.type]!,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800, fontVariations: Wght.w800,
                              color: c.textMuted)),
                      const SizedBox(width: Gap.sm),
                      Expanded(
                        child: Text(_title(it),
                            style: TextStyle(
                                color: c.text,
                                decoration: done
                                    ? TextDecoration.lineThrough
                                    : null)),
                      ),
                      if (overdue)
                        Text('밀림',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800, fontVariations: Wght.w800,
                                color: c.wrong)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _monthView(AppColors c, TextTheme t, Map<String, bool> done) {
    final blocks = planMonthBlocks(widget.plan, done);
    const wd = ['일', '월', '화', '수', '목', '금', '토'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final b in blocks) ...[
          Padding(
            padding: const EdgeInsets.only(top: Gap.sm, bottom: Gap.sm),
            child: Text('${b.year}년 ${b.month}월',
                style: t.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800, fontVariations: Wght.w800)),
          ),
          Row(
            children: [
              for (final d in wd)
                Expanded(
                    child: Center(
                        child: Text(d,
                            style:
                                t.labelSmall?.copyWith(color: c.textFaint)))),
            ],
          ),
          const SizedBox(height: Gap.xs),
          for (final week in b.weeks)
            Row(
              children: [
                for (final day in week) Expanded(child: _monthCell(c, t, day)),
              ],
            ),
        ],
      ],
    );
  }

  Widget _monthCell(AppColors c, TextTheme t, MonthDay day) {
    if (day.dateIso == null) return const SizedBox(height: 56);
    final isToday = day.dateIso == widget.today;
    final isExam = widget.plan.mode == PlanMode.examDate &&
        day.dateIso == widget.plan.endIso;
    final accent = isToday || isExam;
    final dayNum = int.parse(day.dateIso!.split('-')[2]).toString();
    final allDone = day.total > 0 && day.done >= day.total;
    return FocusTap(
      onTap: day.total > 0
          ? () => setState(() {
                _month = false;
                _scrollToDate = day.dateIso;
              })
          : null,
      radius: Radii.sm,
      child: Container(
        height: 56,
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.all(Gap.xs2),
        decoration: BoxDecoration(
          color: accent ? c.surface2 : Colors.transparent,
          borderRadius: BorderRadius.circular(Radii.sm),
          border: Border.all(
              color: accent
                  ? c.accent
                  : c.border.withValues(alpha: day.inRange ? 1 : 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isExam ? '$dayNum·시험' : dayNum,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700, fontVariations: Wght.w700,
                    color: accent
                        ? c.accent
                        : (day.inRange ? c.text : c.textFaint))),
            const Spacer(),
            if (day.total > 0)
              Text('${day.done}/${day.total}',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700, fontVariations: Wght.w700,
                      color: allDone ? c.correct : c.textMuted)),
          ],
        ),
      ),
    );
  }
}
