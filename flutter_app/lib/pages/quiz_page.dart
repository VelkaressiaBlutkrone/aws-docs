import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../content/quiz_widgets.dart';
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
          if (snap.hasError) {
            return Center(
                child: Text('문항을 불러오지 못했습니다.',
                    style: TextStyle(color: c.textMuted)));
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

/// 모델 주입식 연습 러너(즉시 공개). 테스트 대상.
class QuizView extends StatefulWidget {
  const QuizView({
    super.key,
    required this.bank,
    required this.certId,
    this.mode = 'practice',
    this.examId,
    this.onFinished,
  });

  final QuestionBank bank;
  final String certId;

  /// 기록 모드: 'practice'(기본) | 'review'. 헤드라인 통계 분리용.
  final String mode;

  /// 기록 examId. null이면 'practice:${bank.examGuideTaskId}'.
  final String? examId;
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
      examId: widget.examId ?? 'practice:${widget.bank.examGuideTaskId}',
      mode: widget.mode,
      date: DateTime.now().toIso8601String(),
      correct: correct,
      total: _qs.length,
      wrongQuestionIds: wrong,
      flaggedQuestionIds: const [],
      presentedQuestionIds: [for (final q in _qs) q.id],
      durationSpentSec: DateTime.now().difference(_startedAt).inSeconds,
    ));
    setState(() => _finished = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(Gap.xl),
        child: ResultsView(bank: widget.bank, picked: _picked),
      );
    }
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
          Text('문항 ${_index + 1} / ${_qs.length}', style: t.labelSmall),
          const SizedBox(height: Gap.sm),
          Text(q.stem, style: t.titleLarge),
          const SizedBox(height: Gap.lg),
          for (var k = 0; k < q.options.length; k++)
            OptionTile(
              text: q.options[k],
              selected: picked == k,
              state: !revealed
                  ? OptState.idle
                  : k == q.correct
                      ? OptState.correct
                      : (picked == k ? OptState.wrong : OptState.idle),
              onTap: revealed ? null : () => setState(() => _picked[_index] = k),
            ),
          const SizedBox(height: Gap.lg),
          if (revealed) ...[
            ExplainBox(
                bg: c.accentWeak,
                bar: c.accent,
                label: '해설',
                text: q.explanation),
            if (picked != null &&
                picked != q.correct &&
                q.wrongExplanations[picked] != null)
              Padding(
                padding: const EdgeInsets.only(top: Gap.sm),
                child: ExplainBox(
                    bg: c.wrongWeak,
                    bar: c.wrong,
                    label: '왜 아닌가',
                    text: q.wrongExplanations[picked]!),
              ),
            const SizedBox(height: Gap.lg),
            PrimaryButton(
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
            PrimaryButton(
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
