import 'package:flutter/material.dart';

import '../../content/quiz_widgets.dart' show PrimaryButton;
import '../../data/content_index.dart';
import '../../data/plan_scheduler.dart';
import '../../models/certification.dart';
import '../../models/study_plan.dart';
import '../../theme/app_theme.dart';
import '../../widgets/focus_ring.dart';

const _typeLabels = {
  PlanItemType.doc: '문서 학습',
  PlanItemType.quiz: '연습 문제',
  PlanItemType.mockExam: '모의고사',
  PlanItemType.weakExam: '약점 보강',
  PlanItemType.finalReview: '최종 점검',
};

/// 일정 생성 폼 — 추천 자동(기간→buildPlan) 또는 직접 만들기(유형+Task 범위).
class PlanCreateForm extends StatefulWidget {
  const PlanCreateForm(
      {super.key,
      required this.cert,
      required this.today,
      required this.onSaved});
  final Certification cert;
  final String today;
  final ValueChanged<StudyPlan> onSaved;

  @override
  State<PlanCreateForm> createState() => _PlanCreateFormState();
}

class _PlanCreateFormState extends State<PlanCreateForm> {
  bool _manual = false;
  PlanMode _mode = PlanMode.examDate;
  PlanItemType _type = PlanItemType.doc;
  final _selected = <String>{};
  late String _start = widget.today;
  late String _end = addDays(widget.today, 14);

  bool get _needsTasks =>
      _type == PlanItemType.doc || _type == PlanItemType.quiz;

  PlanBuildResult _autoPreview() => buildPlan(
        planId: widget.cert.code,
        content: contentFor(widget.cert.code),
        startIso: _start,
        endIso: _end,
        mode: _mode,
      );

  List<PlanItem> _manualPreview() => buildManualPlanItems(
        planId: 'preview',
        planType: _type,
        taskIds: _selected.toList(),
        startIso: _start,
        endIso: _end,
      );

  Future<void> _pick(bool isStart) async {
    final first = DateTime.parse(widget.today);
    final last = first.add(const Duration(days: 365));
    var init = DateTime.parse(isStart ? _start : _end);
    if (init.isBefore(first)) init = first;
    if (init.isAfter(last)) init = last;
    final picked = await showDatePicker(
        context: context, initialDate: init, firstDate: first, lastDate: last);
    if (picked == null) return;
    final iso = picked.toIso8601String().substring(0, 10);
    setState(() => isStart ? _start = iso : _end = iso);
  }

  void _saveAuto() {
    final r = _autoPreview();
    widget.onSaved(StudyPlan(
      label: '학습 일정',
      certCode: widget.cert.code,
      startIso: _start,
      endIso: _end,
      mode: _mode,
      createdIso: widget.today,
      items: r.items,
    ));
  }

  void _saveManual() {
    widget.onSaved(StudyPlan(
      label: _typeLabels[_type]!,
      certCode: widget.cert.code,
      startIso: _start,
      endIso: _end,
      mode: PlanMode.period,
      createdIso: widget.today,
      source: PlanSource.manual,
      planType: _type,
      taskIds: _selected.toList(),
      items: buildManualPlanItems(
        planId: 'tmp',
        planType: _type,
        taskIds: _selected.toList(),
        startIso: _start,
        endIso: _end,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.all(Gap.xl),
          children: [
            Text('학습 일정 만들기', style: t.headlineSmall),
            const SizedBox(height: Gap.lg),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('추천 자동')),
                ButtonSegment(value: true, label: Text('직접 만들기')),
              ],
              selected: {_manual},
              onSelectionChanged: (s) => setState(() => _manual = s.first),
            ),
            const SizedBox(height: Gap.lg),
            if (_manual) ..._manualForm(c, t) else ..._autoForm(c, t),
          ],
        ),
      ),
    );
  }

  List<Widget> _autoForm(AppColors c, TextTheme t) {
    final r = _autoPreview();
    final endLabel = _mode == PlanMode.examDate ? '시험일' : '종료일';
    return [
      Text('대상 ${widget.cert.code}의 문서·연습·모의고사를 기간에 맞춰 분배합니다.',
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
      _previewBox(c, t, '총 ${r.items.length}개 항목', r.warnings),
      const SizedBox(height: Gap.lg),
      PrimaryButton(label: '일정 저장', onTap: r.items.isEmpty ? null : _saveAuto),
    ];
  }

  List<Widget> _manualForm(AppColors c, TextTheme t) {
    final items = _manualPreview();
    final entries = contentFor(widget.cert.code);
    return [
      Text('유형', style: t.labelLarge),
      const SizedBox(height: Gap.sm),
      Wrap(
        spacing: Gap.sm,
        runSpacing: Gap.sm,
        children: [
          for (final ty in PlanItemType.values)
            ChoiceChip(
              label: Text(_typeLabels[ty]!),
              selected: _type == ty,
              onSelected: (_) => setState(() => _type = ty),
            ),
        ],
      ),
      const SizedBox(height: Gap.lg),
      _dateRow(c, '시작일', _start, () => _pick(true)),
      const SizedBox(height: Gap.sm),
      _dateRow(c, '종료일', _end, () => _pick(false)),
      const SizedBox(height: Gap.lg),
      if (_needsTasks) ...[
        Text('대상 Task (${_selected.length}개 선택)', style: t.labelLarge),
        const SizedBox(height: Gap.sm),
        for (final e in entries)
          CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: _selected.contains(e.taskId),
            title: Text(e.title, style: t.bodyMedium),
            onChanged: (v) => setState(() {
              if (v == true) {
                _selected.add(e.taskId);
              } else {
                _selected.remove(e.taskId);
              }
            }),
          ),
        const SizedBox(height: Gap.lg),
      ],
      _previewBox(c, t, '총 ${items.length}개 항목', const []),
      const SizedBox(height: Gap.lg),
      PrimaryButton(label: '일정 저장', onTap: items.isEmpty ? null : _saveManual),
    ];
  }

  Widget _previewBox(
          AppColors c, TextTheme t, String summary, List<String> warnings) =>
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
            Text('미리보기 · $summary', style: t.titleMedium),
            for (final w in warnings) ...[
              const SizedBox(height: Gap.xs),
              Text('⚠ $w', style: t.bodySmall?.copyWith(color: c.wrong)),
            ],
          ],
        ),
      );

  Widget _dateRow(AppColors c, String label, String iso, VoidCallback onTap) =>
      FocusTap(
        onTap: onTap,
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
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontVariations: Wght.w700,
                      color: c.textMuted)),
              const Spacer(),
              Text(iso,
                  style:
                      TextStyle(fontFamily: AppTheme.monoFamily, color: c.text)),
              const SizedBox(width: Gap.sm),
              Icon(Icons.calendar_today_outlined, size: 16, color: c.accent),
            ],
          ),
        ),
      );
}
