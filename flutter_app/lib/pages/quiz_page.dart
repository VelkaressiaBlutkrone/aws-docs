import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../data/content_index.dart';
import '../data/history_store.dart';
import '../models/attempt_record.dart';
import '../models/question.dart';
import '../theme/app_theme.dart';

/// 얇은 로더: 자산에서 QuestionBank를 읽어 QuizView에 주입.
class QuizPage extends StatelessWidget {
  const QuizPage({super.key, required this.entry});
  final ContentEntry entry;

  Future<QuestionBank> _load() async {
    final raw = await rootBundle.loadString(entry.questionsAsset);
    return QuestionBank.fromJson(json.decode(raw) as Map<String, dynamic>);
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
        title: Text('${entry.title} · 연습 문제',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      body: FutureBuilder<QuestionBank>(
        future: _load(),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final bank = snap.data;
          if (bank == null || bank.questions.isEmpty) {
            return Center(
                child: Text('검증된 연습 문제가 아직 없습니다.',
                    style: TextStyle(color: c.textMuted)));
          }
          final store = HistoryStore();
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: Layout.exam),
              child: QuizView(
                bank: bank,
                certId: entry.certForHistory,
                onFinished: store.add,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 모델 주입식 퀴즈 러너(테스트 대상).
class QuizView extends StatefulWidget {
  const QuizView({
    super.key,
    required this.bank,
    required this.certId,
    this.onFinished,
  });

  final QuestionBank bank;
  final String certId;
  final void Function(AttemptRecord)? onFinished;

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  int _index = 0;
  final _picked = <int, int>{};
  final _revealed = <int>{};
  final _startedAt = DateTime.now();
  bool _finished = false;

  List<Question> get _qs => widget.bank.questions;

  void _finish() {
    final wrong = <String>[];
    var correct = 0;
    for (var k = 0; k < _qs.length; k++) {
      if (_picked[k] == _qs[k].correct) {
        correct++;
      } else {
        wrong.add(_qs[k].id);
      }
    }
    widget.onFinished?.call(AttemptRecord(
      certId: widget.certId,
      examId: 'practice:${widget.bank.examGuideTaskId}',
      mode: 'practice',
      date: DateTime.now().toIso8601String(),
      correct: correct,
      total: _qs.length,
      wrongQuestionIds: wrong,
      flaggedQuestionIds: const [],
      durationSpentSec: DateTime.now().difference(_startedAt).inSeconds,
    ));
    setState(() => _finished = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) return _Results(bank: widget.bank, picked: _picked);
    final c = context.c;
    final t = Theme.of(context).textTheme;
    final q = _qs[_index];
    final revealed = _revealed.contains(_index);
    final picked = _picked[_index];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(Gap.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('문항 ${_index + 1} / ${_qs.length}',
              style: t.labelSmall),
          const SizedBox(height: Gap.sm),
          Text(q.stem, style: t.titleLarge),
          const SizedBox(height: Gap.lg),
          for (var k = 0; k < q.options.length; k++)
            _OptionTile(
              text: q.options[k],
              selected: picked == k,
              state: !revealed
                  ? _OptState.idle
                  : k == q.correct
                      ? _OptState.correct
                      : (picked == k ? _OptState.wrong : _OptState.idle),
              onTap: revealed ? null : () => setState(() => _picked[_index] = k),
            ),
          const SizedBox(height: Gap.lg),
          if (revealed) ...[
            _Explain(
                bg: c.accentWeak,
                bar: c.accent,
                label: '해설',
                text: q.explanation),
            if (picked != null &&
                picked != q.correct &&
                q.wrongExplanations[picked] != null)
              Padding(
                padding: const EdgeInsets.only(top: Gap.sm),
                child: _Explain(
                    bg: c.wrongWeak,
                    bar: c.wrong,
                    label: '왜 아닌가',
                    text: q.wrongExplanations[picked]!),
              ),
            const SizedBox(height: Gap.lg),
            _PrimaryButton(
              label: _index < _qs.length - 1 ? '다음' : '결과 보기',
              onTap: () {
                if (_index < _qs.length - 1) {
                  setState(() => _index++);
                } else {
                  _finish();
                }
              },
            ),
          ] else
            _PrimaryButton(
              label: '확인',
              onTap: picked == null
                  ? null
                  : () => setState(() => _revealed.add(_index)),
            ),
        ],
      ),
    );
  }
}

enum _OptState { idle, correct, wrong }

class _OptionTile extends StatelessWidget {
  const _OptionTile(
      {required this.text,
      required this.selected,
      required this.state,
      required this.onTap});
  final String text;
  final bool selected;
  final _OptState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    late Color border;
    late Color bg;
    switch (state) {
      case _OptState.correct:
        border = c.correct;
        bg = c.correctWeak;
      case _OptState.wrong:
        border = c.wrong;
        bg = c.wrongWeak;
      case _OptState.idle:
        border = selected ? c.accent : c.border;
        bg = selected ? c.accentWeak : c.surface;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.md),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(Gap.md),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(Radii.md),
            border: Border.all(color: border, width: selected ? 2 : 1),
          ),
          child: Text(text,
              style: TextStyle(fontSize: 15, height: 1.5, color: c.text)),
        ),
      ),
    );
  }
}

class _Explain extends StatelessWidget {
  const _Explain(
      {required this.bg,
      required this.bar,
      required this.label,
      required this.text});
  final Color bg;
  final Color bar;
  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Gap.md),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(Radii.sm),
        border: Border(left: BorderSide(color: bar, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w800, color: bar)),
          const SizedBox(height: 4),
          Text(text, style: TextStyle(fontSize: 15, height: 1.6, color: c.text)),
        ],
      ),
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({required this.bank, required this.picked});
  final QuestionBank bank;
  final Map<int, int> picked;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    final qs = bank.questions;
    var correct = 0;
    for (var k = 0; k < qs.length; k++) {
      if (picked[k] == qs[k].correct) correct++;
    }
    final pct = qs.isEmpty ? 0 : (correct * 100 / qs.length).round();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Gap.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('결과', style: t.headlineSmall),
          const SizedBox(height: Gap.sm),
          Text('$correct / ${qs.length}  ·  $pct%',
              style: t.displayMedium?.copyWith(color: c.accent)),
          const SizedBox(height: Gap.xl),
          for (var k = 0; k < qs.length; k++)
            Padding(
              padding: const EdgeInsets.only(bottom: Gap.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                      picked[k] == qs[k].correct
                          ? Icons.check_circle
                          : Icons.cancel,
                      size: 18,
                      color:
                          picked[k] == qs[k].correct ? c.correct : c.wrong),
                  const SizedBox(width: Gap.sm),
                  Expanded(
                      child: Text('${k + 1}. ${qs[k].stem}',
                          style: t.bodyMedium?.copyWith(color: c.text))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Radii.sm),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: Gap.lg),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? c.accent : c.surface2,
          borderRadius: BorderRadius.circular(Radii.sm),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: enabled ? c.onAccent : c.textFaint)),
      ),
    );
  }
}
