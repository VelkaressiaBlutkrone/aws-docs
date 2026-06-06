import 'dart:async';

import 'package:flutter/material.dart';

import '../content/quiz_widgets.dart';
import '../models/attempt_record.dart';
import '../models/exam_session.dart';
import '../models/question.dart';
import '../theme/app_theme.dart';

/// 모델 주입식 시험 러너(테스트 대상). 자산/localStorage 의존 없음.
class ExamView extends StatefulWidget {
  const ExamView({
    super.key,
    required this.bank,
    required this.certId,
    required this.taskId,
    required this.startedAt,
    required this.durationSec,
    this.initialIndex = 0,
    this.initialPicked = const {},
    this.initialFlagged = const {},
    this.restored = false,
    this.passingHintPct = 70,
    this.onChanged,
    this.onFinished,
    this.onExit,
    this.now,
  });

  final QuestionBank bank;
  final String certId;
  final String taskId;
  final DateTime startedAt;
  final int durationSec;
  final int initialIndex;
  final Map<int, int> initialPicked;
  final Set<int> initialFlagged;
  final bool restored;
  final int passingHintPct;
  final void Function(ExamSession)? onChanged;
  final void Function(AttemptRecord)? onFinished;
  final VoidCallback? onExit;
  final DateTime Function()? now;

  @override
  State<ExamView> createState() => _ExamViewState();
}

class _ExamViewState extends State<ExamView> {
  late int _index = widget.bank.questions.isEmpty
      ? 0
      : widget.initialIndex.clamp(0, widget.bank.questions.length - 1);
  late final Map<int, int> _picked = {...widget.initialPicked};
  late final Set<int> _flagged = {...widget.initialFlagged};
  bool _submitted = false;
  bool _dialogOpen = false;
  Timer? _ticker;

  List<Question> get _qs => widget.bank.questions;
  DateTime _clock() => (widget.now ?? DateTime.now)();

  int get _remainingSec {
    final elapsed = _clock().difference(widget.startedAt).inSeconds;
    final left = widget.durationSec - elapsed;
    return left < 0 ? 0 : left;
  }

  @override
  void initState() {
    super.initState();
    assert(widget.bank.questions.isNotEmpty,
        'ExamView requires a non-empty question bank');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_remainingSec <= 0) {
        _submit(auto: true);
      } else {
        _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
          if (!mounted) return;
          if (_remainingSec <= 0) {
            _submit(auto: true);
          } else {
            setState(() {});
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  ExamSession _session() => ExamSession(
        examId: 'exam:${widget.taskId}',
        certId: widget.certId,
        taskId: widget.taskId,
        startedAtIso: widget.startedAt.toIso8601String(),
        durationSec: widget.durationSec,
        index: _index,
        picked: _picked,
        flagged: _flagged.toList()..sort(),
        bankFingerprint: bankFingerprint(widget.bank),
        submitted: _submitted,
      );

  void _persist() => widget.onChanged?.call(_session());

  void _pick(int opt) {
    setState(() => _picked[_index] = opt);
    _persist();
  }

  void _toggleFlag() {
    setState(() {
      if (_flagged.contains(_index)) {
        _flagged.remove(_index);
      } else {
        _flagged.add(_index);
      }
    });
    _persist();
  }

  void _go(int i) {
    if (i < 0 || i >= _qs.length) return;
    setState(() => _index = i);
    _persist();
  }

  void _submit({required bool auto}) {
    if (_submitted) return;
    _submitted = true;
    _ticker?.cancel();
    if (auto && _dialogOpen && mounted) {
      Navigator.of(context).pop();
      _dialogOpen = false;
    }
    final wrong = <String>[];
    var correct = 0;
    for (var k = 0; k < _qs.length; k++) {
      if (_picked[k] == _qs[k].correct) {
        correct++;
      } else {
        wrong.add(_qs[k].id);
      }
    }
    final flaggedIds = [
      for (final i in _flagged.toList()..sort())
        if (i >= 0 && i < _qs.length) _qs[i].id,
    ];
    final spent = _clock().difference(widget.startedAt).inSeconds;
    widget.onFinished?.call(AttemptRecord(
      certId: widget.certId,
      examId: 'exam:${widget.taskId}',
      mode: 'exam',
      date: _clock().toIso8601String(),
      correct: correct,
      total: _qs.length,
      wrongQuestionIds: wrong,
      flaggedQuestionIds: flaggedIds,
      durationSpentSec: spent > widget.durationSec ? widget.durationSec : spent,
    ));
    setState(() {});
  }

  Future<void> _onSubmitPressed() async {
    if (_flagged.isEmpty) {
      _submit(auto: false);
      return;
    }
    _dialogOpen = true;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('제출할까요?'),
        content: Text('플래그한 문항 ${_flagged.length}개가 남아 있습니다. 그래도 제출할까요?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('계속 풀기')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('제출하기')),
        ],
      ),
    );
    _dialogOpen = false;
    if (!mounted || _submitted) return;
    if (ok == true) _submit(auto: false);
  }

  String _mmss(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) return _results(context);
    final c = context.c;
    final t = Theme.of(context).textTheme;
    final q = _qs[_index];
    final remaining = _remainingSec;
    final low = remaining <= (widget.durationSec * 0.1).ceil();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(Gap.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timer_outlined,
                  size: 18, color: low ? c.warning : c.textMuted),
              const SizedBox(width: Gap.xs),
              Text(_mmss(remaining),
                  style: TextStyle(
                      fontFamily: AppTheme.monoFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: low ? c.warning : c.text)),
              const Spacer(),
              Text('${_index + 1} / ${_qs.length}', style: t.labelSmall),
            ],
          ),
          if (widget.restored)
            Padding(
              padding: const EdgeInsets.only(top: Gap.xs),
              child: Text('이전 진행을 복원했습니다.',
                  style: t.labelSmall?.copyWith(color: c.textMuted)),
            ),
          const SizedBox(height: Gap.md),
          Wrap(
            spacing: Gap.xs,
            runSpacing: Gap.xs,
            children: [
              for (var k = 0; k < _qs.length; k++)
                _GridChip(
                  label: '${k + 1}',
                  answered: _picked.containsKey(k),
                  flagged: _flagged.contains(k),
                  current: k == _index,
                  onTap: () => _go(k),
                ),
            ],
          ),
          const SizedBox(height: Gap.lg),
          Text(q.stem, style: t.titleLarge),
          const SizedBox(height: Gap.lg),
          for (var k = 0; k < q.options.length; k++)
            OptionTile(
              text: q.options[k],
              selected: _picked[_index] == k,
              state: OptState.idle,
              onTap: () => _pick(k),
            ),
          const SizedBox(height: Gap.lg),
          Row(
            children: [
              if (_index > 0)
                _SecondaryButton(
                    icon: Icons.chevron_left,
                    label: '이전',
                    onTap: () => _go(_index - 1)),
              const SizedBox(width: Gap.sm),
              _SecondaryButton(
                icon: _flagged.contains(_index)
                    ? Icons.flag
                    : Icons.flag_outlined,
                label: _flagged.contains(_index) ? '플래그 해제' : '플래그',
                active: _flagged.contains(_index),
                onTap: _toggleFlag,
              ),
              const Spacer(),
              SizedBox(
                width: 130,
                child: PrimaryButton(
                  label: _index < _qs.length - 1 ? '다음' : '제출',
                  onTap: _index < _qs.length - 1
                      ? () => _go(_index + 1)
                      : _onSubmitPressed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _results(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Gap.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResultsView(
            bank: widget.bank,
            picked: _picked,
            flagged: _flagged,
            subtitle:
                '실전 합격 기준 ≈ ${widget.passingHintPct}% · 플래그 ${_flagged.length}개',
          ),
          const SizedBox(height: Gap.lg),
          if (widget.onExit != null)
            SizedBox(
              width: 180,
              child: PrimaryButton(label: '학습문서로', onTap: widget.onExit),
            ),
        ],
      ),
    );
  }
}

class _GridChip extends StatelessWidget {
  const _GridChip({
    required this.label,
    required this.answered,
    required this.flagged,
    required this.current,
    required this.onTap,
  });
  final String label;
  final bool answered;
  final bool flagged;
  final bool current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Radii.sm),
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: answered ? c.accentWeak : c.surface,
          borderRadius: BorderRadius.circular(Radii.sm),
          border: Border.all(
            color: current ? c.accent : (flagged ? c.warning : c.border),
            width: current ? 2 : 1,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Text(label,
                style: TextStyle(
                    fontFamily: AppTheme.monoFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: answered ? c.accentStrong : c.textMuted)),
            if (flagged)
              Positioned(
                top: -2,
                right: -2,
                child: Icon(Icons.flag, size: 11, color: c.warning),
              ),
          ],
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Radii.sm),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: Gap.md),
        decoration: BoxDecoration(
          color: active ? c.warningWeak : c.surface,
          borderRadius: BorderRadius.circular(Radii.sm),
          border: Border.all(color: active ? c.warning : c.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: active ? c.warning : c.textMuted),
            const SizedBox(width: Gap.xs),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: active ? c.warning : c.textMuted)),
          ],
        ),
      ),
    );
  }
}
