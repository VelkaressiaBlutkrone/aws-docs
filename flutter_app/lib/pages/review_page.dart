import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../content/quiz_widgets.dart';
import '../data/content_index.dart';
import '../data/history_store.dart';
import '../data/wrong_answer_index.dart';
import '../models/attempt_record.dart';
import '../models/certification.dart';
import '../models/question.dart';
import '../theme/app_theme.dart';
import 'quiz_page.dart'; // QuizView

/// 오답노트: cert의 weak 문항을 Task별로 모아 보여주고 연습형으로 재응시.
/// 로더 → 시작 목록 / 복습 러너(QuizView, mode:'review')를 같은 페이지에서 전환.
class ReviewListPage extends StatefulWidget {
  const ReviewListPage({super.key, required this.cert});
  final Certification cert;

  @override
  State<ReviewListPage> createState() => _ReviewListPageState();
}

class _ReviewListPageState extends State<ReviewListPage> {
  final _history = HistoryStore();
  late Future<_ReviewLoad> _future = _load();
  _ReviewRun? _running;

  Future<_ReviewLoad> _load() async {
    final entries = contentFor(widget.cert.code);
    final byId = <String, Question>{};
    final taskByQuestionId = <String, String>{};
    final taskTitleById = <String, String>{};
    final taskOrder = <String>[];
    for (final e in entries) {
      taskTitleById[e.taskId] = e.title;
      taskOrder.add(e.taskId);
      try {
        final raw = await rootBundle.loadString(e.questionsAsset);
        final bank =
            QuestionBank.fromJson(json.decode(raw) as Map<String, dynamic>);
        for (final q in bank.questions) {
          byId[q.id] = q;
          taskByQuestionId[q.id] = e.taskId;
        }
      } catch (_) {
        // 개별 뱅크 로드 실패는 무시(나머지로 진행)
      }
    }
    final index = WrongAnswerIndex.build(
      certId: widget.cert.code,
      history: _history.all(),
      taskByQuestionId: taskByQuestionId,
    );
    return _ReviewLoad(
      index: index,
      byId: byId,
      taskTitleById: taskTitleById,
      taskOrder: taskOrder,
    );
  }

  void _startTask(_ReviewLoad d, String taskId) {
    final queue = [
      for (final e in d.index.weakEntries(taskId))
        if (d.byId[e.questionId] != null) d.byId[e.questionId]!,
    ];
    if (queue.isEmpty) return;
    setState(() => _running = _ReviewRun(taskId, queue));
  }

  void _onFinished(AttemptRecord rec) {
    _history.add(rec);
    setState(() {
      _running = null;
      _future = _load(); // 졸업 문항 반영해 목록 재계산
    });
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
        title: Text('${widget.cert.title} · 오답노트',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      body: FutureBuilder<_ReviewLoad>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snap.data;
          if (snap.hasError || data == null) {
            return Center(
                child: Text('오답노트를 불러오지 못했습니다.',
                    style: TextStyle(color: c.textMuted)));
          }
          if (_running != null) return _runner(data, _running!);
          return _list(data);
        },
      ),
    );
  }

  Widget _runner(_ReviewLoad d, _ReviewRun run) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Layout.exam),
        child: QuizView(
          bank: QuestionBank(
            examGuideTaskId: run.taskId,
            taskTitle: d.taskTitleById[run.taskId] ?? '복습',
            certCode: widget.cert.code,
            domain: 0,
            questions: run.queue,
          ),
          certId: widget.cert.code,
          mode: 'review',
          examId: 'review:${run.taskId}',
          onFinished: _onFinished,
        ),
      ),
    );
  }

  Widget _list(_ReviewLoad d) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    final weakTasks = [
      for (final taskId in d.taskOrder)
        if (d.index.weakEntries(taskId).isNotEmpty) taskId,
    ];
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Gap.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('오답노트', style: t.headlineSmall),
              const SizedBox(height: Gap.sm),
              Text('연습·시험에서 틀린 문항을 모아 다시 풉니다. 서로 다른 회차에서 연속 2번 맞히면 졸업합니다.',
                  style: t.bodyMedium),
              const SizedBox(height: Gap.xl),
              if (weakTasks.isEmpty)
                _empty(c, t)
              else
                for (final taskId in weakTasks) _taskRow(c, t, d, taskId),
            ],
          ),
        ),
      ),
    );
  }

  Widget _empty(AppColors c, TextTheme t) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Gap.xl),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(color: c.border),
        ),
        child: Text('아직 오답이 없습니다 — 연습이나 시험을 풀면 여기에 모입니다.',
            style: t.bodyMedium?.copyWith(color: c.text)),
      );

  Widget _taskRow(AppColors c, TextTheme t, _ReviewLoad d, String taskId) {
    final count = d.index.weakEntries(taskId).length;
    final title = d.taskTitleById[taskId] ?? taskId;
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.md),
      child: Container(
        padding: const EdgeInsets.all(Gap.lg),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(color: c.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: t.titleMedium),
                  const SizedBox(height: Gap.xs),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                        color: c.wrongWeak,
                        borderRadius: BorderRadius.circular(Radii.full)),
                    child: Text('오답 $count',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: c.wrong)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: Gap.md),
            SizedBox(
              width: 120,
              child: PrimaryButton(
                  label: '복습 시작', onTap: () => _startTask(d, taskId)),
            ),
          ],
        ),
      ),
    );
  }
}

/// 로드 결과(약점 인덱스 + 문항 조회 + Task 표시 메타).
class _ReviewLoad {
  const _ReviewLoad({
    required this.index,
    required this.byId,
    required this.taskTitleById,
    required this.taskOrder,
  });
  final WrongAnswerIndex index;
  final Map<String, Question> byId;
  final Map<String, String> taskTitleById;
  final List<String> taskOrder;
}

/// 진행 중 복습(선택한 Task의 weak 큐).
class _ReviewRun {
  const _ReviewRun(this.taskId, this.queue);
  final String taskId;
  final List<Question> queue;
}
