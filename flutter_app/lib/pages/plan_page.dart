import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../content/quiz_widgets.dart' show PrimaryButton;
import '../data/cert_lookup.dart';
import '../data/content_index.dart';
import '../data/history_store.dart';
import '../data/plan_check_store.dart';
import '../data/plan_progress.dart';
import '../data/plan_month.dart';
import '../data/plan_scheduler.dart';
import '../data/study_plan_store.dart';
import '../data/viewed_docs_store.dart';
import '../models/study_plan.dart';
import '../models/certification.dart';
import '../theme/app_theme.dart';

/// 어젠다 헤더용 순수 요약.
class PlanSummary {
  const PlanSummary(
      {required this.total, required this.done, required this.percent, required this.daysLeft});
  final int total;
  final int done;
  final int percent;
  final int daysLeft;
}

PlanSummary planSummary(StudyPlan plan, Map<String, bool> done, String todayIso) {
  final total = plan.items.length;
  final d = plan.items.where((i) => done[i.id] == true).length;
  final pct = total == 0 ? 0 : (d / total * 100).round();
  final left = daysBetween(todayIso, plan.endIso);
  return PlanSummary(total: total, done: d, percent: pct, daysLeft: left < 0 ? 0 : left);
}

/// 학습 일정 화면. 플랜이 없으면 생성 폼, 있으면 어젠다(Task 7).
class PlanPage extends StatefulWidget {
  const PlanPage({super.key, required this.cert});
  final Certification cert;

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  final _store = StudyPlanStore();
  StudyPlan? _plan;
  late final String _today;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now().toIso8601String().substring(0, 10);
    _plan = _store.planFor(widget.cert.code);
  }

  @override
  void didUpdateWidget(covariant PlanPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cert.code != widget.cert.code) {
      setState(() => _plan = _store.planFor(widget.cert.code));
    }
  }

  void _onSaved(StudyPlan p) {
    _store.save(p);
    setState(() => _plan = p);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: Border(bottom: BorderSide(color: c.border)),
        title: Text('${widget.cert.code} · 학습 일정',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      body: _plan == null
          ? _PlanCreateForm(
              cert: widget.cert, today: _today, onSaved: _onSaved)
          : _PlanAgenda(
              cert: widget.cert,
              plan: _plan!,
              today: _today,
              onEdit: () => setState(() => _plan = null),
              onChanged: (p) => _onSaved(p)),
    );
  }
}

/// 생성/편집 폼: 시험일 또는 기간 → 미리보기(buildPlan) → 저장.
class _PlanCreateForm extends StatefulWidget {
  const _PlanCreateForm(
      {required this.cert, required this.today, required this.onSaved});
  final Certification cert;
  final String today;
  final ValueChanged<StudyPlan> onSaved;

  @override
  State<_PlanCreateForm> createState() => _PlanCreateFormState();
}

class _PlanCreateFormState extends State<_PlanCreateForm> {
  PlanMode _mode = PlanMode.examDate;
  late String _start = widget.today;
  late String _end = addDays(widget.today, 14);

  PlanBuildResult _preview() => buildPlan(
        certCode: widget.cert.code,
        content: contentFor(widget.cert.code),
        startIso: _start,
        endIso: _end,
        mode: _mode,
      );

  Future<void> _pick(bool isStart) async {
    final first = DateTime.parse(widget.today);
    final last = first.add(const Duration(days: 365));
    var init = DateTime.parse(isStart ? _start : _end);
    if (init.isBefore(first)) init = first;
    if (init.isAfter(last)) init = last;
    final picked = await showDatePicker(
      context: context,
      initialDate: init,
      firstDate: first,
      lastDate: last,
    );
    if (picked == null) return;
    final iso = picked.toIso8601String().substring(0, 10);
    setState(() => isStart ? _start = iso : _end = iso);
  }

  void _save(PlanBuildResult r) {
    widget.onSaved(StudyPlan(
      certCode: widget.cert.code,
      startIso: _start,
      endIso: _end,
      mode: _mode,
      createdIso: widget.today,
      items: r.items,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    final r = _preview();
    final endLabel = _mode == PlanMode.examDate ? '시험일' : '종료일';
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.all(Gap.xl),
          children: [
            Text('학습 일정 만들기', style: t.headlineSmall),
            const SizedBox(height: Gap.sm),
            Text('대상 자격증 ${widget.cert.code}의 학습문서·연습·모의고사를 기간에 맞춰 분배합니다.',
                style: t.bodyMedium),
            const SizedBox(height: Gap.lg),
            SegmentedButton<PlanMode>(
              segments: const [
                ButtonSegment(value: PlanMode.examDate, label: Text('시험일 기준')),
                ButtonSegment(value: PlanMode.period, label: Text('기간 기준')),
              ],
              selected: {_mode},
              onSelectionChanged: (s) => setState(() => _mode = s.first),
            ),
            const SizedBox(height: Gap.lg),
            _dateRow(c, '시작일', _start, () => _pick(true)),
            const SizedBox(height: Gap.sm),
            _dateRow(c, endLabel, _end, () => _pick(false)),
            const SizedBox(height: Gap.lg),
            Container(
              padding: const EdgeInsets.all(Gap.lg),
              decoration: BoxDecoration(
                color: c.surface2,
                borderRadius: BorderRadius.circular(Radii.md),
                border: Border.all(color: c.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('미리보기 · 총 ${r.items.length}개 항목',
                      style: t.titleMedium),
                  const SizedBox(height: Gap.xs),
                  Text(_summary(r), style: t.bodySmall?.copyWith(color: c.textMuted)),
                  for (final w in r.warnings) ...[
                    const SizedBox(height: Gap.xs),
                    Text('⚠ $w',
                        style: t.bodySmall?.copyWith(color: c.wrong)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: Gap.lg),
            PrimaryButton(
              label: '일정 저장',
              onTap: r.items.isEmpty ? null : () => _save(r),
            ),
          ],
        ),
      ),
    );
  }

  String _summary(PlanBuildResult r) {
    int n(PlanItemType x) => r.items.where((i) => i.type == x).length;
    return '문서 ${n(PlanItemType.doc)} · 연습 ${n(PlanItemType.quiz)} · '
        '모의고사 ${n(PlanItemType.mockExam)} · 약점 ${n(PlanItemType.weakExam)} · 점검 ${n(PlanItemType.finalReview)}';
  }

  Widget _dateRow(AppColors c, String label, String iso, VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.md),
        child: Container(
          padding: const EdgeInsets.all(Gap.lg),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(Radii.md),
            border: Border.all(color: c.border),
          ),
          child: Row(
            children: [
              Text(label,
                  style: TextStyle(fontWeight: FontWeight.w700, color: c.textMuted)),
              const Spacer(),
              Text(iso,
                  style: TextStyle(
                      fontFamily: AppTheme.monoFamily, color: c.text)),
              const SizedBox(width: Gap.sm),
              Icon(Icons.calendar_today_outlined, size: 16, color: c.accent),
            ],
          ),
        ),
      );
}

class _PlanAgenda extends StatefulWidget {
  const _PlanAgenda(
      {required this.cert,
      required this.plan,
      required this.today,
      required this.onEdit,
      required this.onChanged});
  final Certification cert;
  final StudyPlan plan;
  final String today;
  final VoidCallback onEdit;
  final ValueChanged<StudyPlan> onChanged;

  @override
  State<_PlanAgenda> createState() => _PlanAgendaState();
}

class _PlanAgendaState extends State<_PlanAgenda> {
  final _checks = PlanCheckStore();
  final _history = HistoryStore();
  final _viewed = ViewedDocsStore();
  bool _month = false;

  Map<String, bool> _done() => computePlanDone(
        widget.plan,
        manual: _checks.overrides(widget.cert.code),
        viewedTaskIds: _viewed.viewed(widget.cert.code),
        history: _history.all(),
      );

  void _toggle(String itemId, bool current) {
    _checks.set(widget.cert.code, itemId, !current);
    setState(() {});
  }

  void _open(PlanItem it) {
    final code = widget.cert.code;
    switch (it.type) {
      case PlanItemType.doc:
        if (it.refId != null) context.push('/cert/$code/study/${it.refId}');
      case PlanItemType.quiz:
        if (it.refId != null) context.push('/cert/$code/study/${it.refId}/quiz');
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

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.all(Gap.xl),
          children: [
            if (daysBetween(widget.today, widget.plan.endIso) < 0)
              Container(
                margin: const EdgeInsets.only(bottom: Gap.md),
                padding: const EdgeInsets.all(Gap.md),
                decoration: BoxDecoration(
                  color: c.surface2,
                  borderRadius: BorderRadius.circular(Radii.md),
                  border: Border.all(color: c.border),
                ),
                child: Text('학습 기간이 종료됐습니다. "다시 만들기"로 새 일정을 만들거나 기간을 연장하세요.',
                    style: t.bodySmall?.copyWith(color: c.textMuted)),
              ),
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
                      _month ? Icons.view_agenda_outlined : Icons.calendar_month_outlined,
                      size: 20, color: c.textMuted),
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
              ],
            ),
            const SizedBox(height: Gap.sm),
            LinearProgressIndicator(
              value: s.total == 0 ? 0 : s.done / s.total,
              backgroundColor: c.surface2,
              color: c.accent,
            ),
            const SizedBox(height: Gap.lg),
            if (_month)
              _monthView(c, t, done)
            else
              for (final date in dates) ...[
                _dayHeader(c, t, date),
                for (final it in byDate[date]!)
                  _itemRow(c, t, it, done[it.id] == true,
                      isOverdue(it, widget.today, done[it.id] == true)),
                const SizedBox(height: Gap.md),
              ],
          ],
        ),
      ),
    );
  }

  Widget _dayHeader(AppColors c, TextTheme t, String date) {
    final isToday = date == widget.today;
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.xs),
      child: Text(isToday ? '$date · 오늘' : date,
          style: t.labelLarge?.copyWith(
              color: isToday ? c.accent : c.textMuted,
              fontWeight: FontWeight.w800)),
    );
  }

  Widget _itemRow(
      AppColors c, TextTheme t, PlanItem it, bool done, bool overdue) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.xs2),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Gap.md, vertical: Gap.sm),
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
              child: InkWell(
                onTap: () => _open(it),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: Gap.sm),
                  child: Row(
                    children: [
                      Text(_typeLabel[it.type]!,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
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
                                fontWeight: FontWeight.w800,
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
                style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          ),
          Row(
            children: [
              for (final d in wd)
                Expanded(
                    child: Center(
                        child: Text(d,
                            style: t.labelSmall?.copyWith(color: c.textFaint)))),
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
    final isExam = widget.plan.mode == PlanMode.examDate && day.dateIso == widget.plan.endIso;
    final accent = isToday || isExam;
    final dayNum = int.parse(day.dateIso!.split('-')[2]).toString();
    final allDone = day.total > 0 && day.done >= day.total;
    return InkWell(
      onTap: day.total > 0 ? () => setState(() => _month = false) : null,
      borderRadius: BorderRadius.circular(Radii.sm),
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
                    fontWeight: FontWeight.w700,
                    color: accent
                        ? c.accent
                        : (day.inRange ? c.text : c.textFaint))),
            const Spacer(),
            if (day.total > 0)
              Text('${day.done}/${day.total}',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: allDone ? c.correct : c.textMuted)),
          ],
        ),
      ),
    );
  }
}
