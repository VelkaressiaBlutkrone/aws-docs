import 'package:flutter/material.dart';

import '../content/quiz_widgets.dart' show PrimaryButton;
import '../data/content_index.dart';
import '../data/plan_scheduler.dart';
import '../data/study_plan_store.dart';
import '../models/study_plan.dart';
import '../models/certification.dart';
import '../theme/app_theme.dart';

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

/// Task 7에서 구현. 지금은 자리표시.
class _PlanAgenda extends StatelessWidget {
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
  final ValueChanged<StudyPlan> onChanged; // Task 7(어젠다)에서 재분배·저장에 사용

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('플랜 ${plan.items.length}개 항목 (어젠다는 Task 7에서)',
              style: TextStyle(color: c.text)),
          const SizedBox(height: Gap.md),
          TextButton(onPressed: onEdit, child: const Text('다시 만들기')),
        ],
      ),
    );
  }
}
