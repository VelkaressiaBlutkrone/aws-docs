import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:go_router/go_router.dart';

import '../content/quiz_widgets.dart';
import '../content/reset_dialog.dart';
import '../data/content_index.dart';
import '../data/history_store.dart';
import '../data/mock_exam.dart';
import '../data/study_reset.dart';
import '../data/wrong_answer_index.dart';
import '../models/attempt_record.dart';
import '../models/certification.dart';
import '../models/question.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/state_views.dart';
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
    final rng = Random();
    // 차출 없이 weak 전부 + 선택지만 셔플(스펙 §3.2). 세션 저장 없음 → 매 회차 자유 셔플.
    final shuffled = applyOptionOrders(queue, randomOptionOrders(queue, rng));
    setState(() => _running = _ReviewRun(taskId, shuffled));
  }

  void _onFinished(AttemptRecord rec) {
    _history.add(rec);
    setState(() {
      _running = null;
      _future = _load(); // 졸업 문항 반영해 목록 재계산
    });
  }

  Future<void> _resetCert() async {
    final attempts =
        _history.all().where((r) => r.certId == widget.cert.code).length;
    final ok = await confirmReset(
      context,
      title: '${widget.cert.code} 학습 기록 초기화',
      message: '이 자격증의 응시 기록 $attempts회와 오답노트·약점 리포트·진행률·약점 모의고사 '
          '잠금 해제 상태가 모두 삭제됩니다. 다른 자격증은 그대로입니다.\n\n이 작업은 되돌릴 수 없습니다.',
    );
    if (!ok || !mounted) return;
    resetCert(widget.cert.code);
    setState(() {
      _running = null;
      _future = _load();
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.cert.code} 학습 기록을 초기화했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      backgroundColor: c.bg,
      extendBodyBehindAppBar: true, // 글래스 헤더 — 인벤토리 §5
      appBar: AppHeader.document(
        sectionLabel: widget.cert.code,
        title: '오답노트',
        actions: [
          HeaderIconButton(
            onTap: _resetCert,
            tooltip: '이 자격증 학습 기록 초기화',
            icon: Icons.delete_outline,
          ),
        ],
      ),
      body: FutureBuilder<_ReviewLoad>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(
                child: LoadingView(label: '오답노트를 불러오고 있습니다…'));
          }
          final data = snap.data;
          if (snap.hasError || data == null) {
            return Center(
              child: ErrorView(
                message: '오답노트를 불러오지 못했습니다.',
                onRetry: () => setState(() => _future = _load()),
                onHome: () => context.go('/'),
              ),
            );
          }
          if (_running != null) return _runner(data, _running!);
          return _list(context, data);
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

  // context: Scaffold body 아래(FutureBuilder builder) — headerScrollInset용.
  Widget _list(BuildContext context, _ReviewLoad d) {
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
          padding: EdgeInsets.all(Gap.xl)
              .copyWith(top: headerScrollInset(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('오답노트', style: t.headlineSmall),
              const SizedBox(height: Gap.sm),
              Text('연습·시험에서 틀린 문항을 모아 다시 풉니다. 서로 다른 회차에서 연속 2번 맞히면 졸업합니다.',
                  style: t.bodyMedium),
              const SizedBox(height: Gap.xl),
              if (weakTasks.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: Gap.xl2),
                  child: Center(
                    child: EmptyView(
                      title: '아직 오답이 없습니다',
                      description: '연습이나 시험을 풀면 여기에 모입니다.',
                      ctaLabel: '모의고사 시작하기',
                      onCta: () =>
                          context.push('/cert/${widget.cert.code}/exam'),
                    ),
                  ),
                )
              else
                for (final taskId in weakTasks) _taskRow(c, t, d, taskId),
            ],
          ),
        ),
      ),
    );
  }

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
                            fontWeight: FontWeight.w800, fontVariations: Wght.w800,
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
