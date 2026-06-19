import 'package:flutter/material.dart';

import '../../content/quiz_widgets.dart' show PrimaryButton;
import '../../data/content_index.dart';
import '../../data/plan_scheduler.dart';
import '../../models/certification.dart';
import '../../models/study_plan.dart';
import '../../theme/app_theme.dart';
import '../../widgets/focus_ring.dart';

/// 생성/편집 폼: 시험일 또는 기간 → 미리보기(buildPlan) → 저장.
/// (PR4 분해 — plan_page.dart에서 이동.)
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
  PlanMode _mode = PlanMode.examDate;
  late String _start = widget.today;
  late String _end = addDays(widget.today, 14);

  PlanBuildResult _preview() => buildPlan(
        planId: widget.cert.code,
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
                  Text(_summary(r),
                      style: t.bodySmall?.copyWith(color: c.textMuted)),
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
                      fontWeight: FontWeight.w700, fontVariations: Wght.w700,
                      color: c.textMuted)),
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
