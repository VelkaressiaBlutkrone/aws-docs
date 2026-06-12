import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:go_router/go_router.dart';

import '../content/reset_dialog.dart';
import '../data/content_index.dart';
import '../data/history_store.dart';
import '../data/study_reset.dart';
import '../data/task_score_report.dart';
import '../models/certification.dart';
import '../models/question.dart';
import '../theme/app_theme.dart';
import '../widgets/state_views.dart';

/// 약점 리포트: cert의 Task별 정답률 표 + 70% 미만 Task 학습문서 처방.
class ReportPage extends StatefulWidget {
  const ReportPage({super.key, required this.cert});
  final Certification cert;

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final _history = HistoryStore();
  late Future<_ReportLoad> _future = _load();

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
    setState(() => _future = _load());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.cert.code} 학습 기록을 초기화했습니다.')),
      );
    }
  }

  Future<_ReportLoad> _load() async {
    final entries = contentFor(widget.cert.code);
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
          taskByQuestionId[q.id] = e.taskId;
        }
      } catch (_) {}
    }
    final report = TaskScoreReport.build(
      certId: widget.cert.code,
      history: _history.all(),
      taskByQuestionId: taskByQuestionId,
      taskOrder: taskOrder,
    );
    return _ReportLoad(report: report, taskTitleById: taskTitleById);
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
        title: Text('${widget.cert.code} · 약점 리포트',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontVariations: Wght.w700)),
        actions: [
          IconButton(
            onPressed: _resetCert,
            tooltip: '이 자격증 학습 기록 초기화',
            icon: Icon(Icons.delete_outline, size: 20, color: c.textMuted),
          ),
        ],
      ),
      body: FutureBuilder<_ReportLoad>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(
                child: LoadingView(label: '약점 리포트를 계산하고 있습니다…'));
          }
          final data = snap.data;
          if (snap.hasError || data == null) {
            return Center(
              child: ErrorView(
                message: '리포트를 불러오지 못했습니다.',
                onRetry: () => setState(() => _future = _load()),
                onHome: () => context.go('/'),
              ),
            );
          }
          return _body(data);
        },
      ),
    );
  }

  Widget _body(_ReportLoad d) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    final r = d.report;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Gap.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('약점 리포트', style: t.headlineSmall),
              const SizedBox(height: Gap.sm),
              Text('연습·시험에서의 문항별 최신 결과로 Task별 정답률을 계산합니다(복습 제외).',
                  style: t.bodyMedium),
              const SizedBox(height: Gap.lg),
              if (!r.hasAnyAttempt)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: Gap.xl2),
                  child: Center(
                    child: EmptyView(
                      title: '아직 리포트가 없습니다',
                      description: '모의고사나 연습을 풀면 Task별 약점이 여기 표시됩니다.',
                      ctaLabel: '모의고사 시작하기',
                      onCta: () =>
                          context.push('/cert/${widget.cert.code}/exam'),
                    ),
                  ),
                )
              else ...[
                _summary(c, t, r),
                const SizedBox(height: Gap.lg),
                for (final s in r.tasks) _row(c, t, d, s),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _summary(AppColors c, TextTheme t, TaskScoreReport r) {
    final pct = ((r.overallRate ?? 0) * 100).round();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Gap.lg),
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          Text('전체 정답률', style: t.labelLarge?.copyWith(color: c.textMuted)),
          const SizedBox(width: Gap.md),
          Text('$pct%',
              style: t.titleLarge
                  ?.copyWith(color: c.accent, fontFamily: AppTheme.monoFamily)),
          const Spacer(),
          Text('응시 ${r.correctTotal}/${r.attemptedTotal} 문항',
              style: t.labelLarge?.copyWith(color: c.textMuted)),
        ],
      ),
    );
  }

  Widget _row(AppColors c, TextTheme t, _ReportLoad d, TaskScore s) {
    final title = d.taskTitleById[s.taskId] ?? s.taskId;
    final isWeak = s.status == TaskStatus.weak;
    final isUnattempted = s.status == TaskStatus.unattempted;
    final Color tone =
        isUnattempted ? c.textFaint : (isWeak ? c.wrong : c.correct);
    final String rateLabel =
        isUnattempted ? '미응시' : '정답률 ${((s.rate ?? 0) * 100).round()}%';
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.sm),
      child: Container(
        padding: const EdgeInsets.all(Gap.lg),
        decoration: BoxDecoration(
          color: isWeak ? c.wrongWeak : c.surface,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(
              color: isWeak ? c.wrong.withValues(alpha: 0.35) : c.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: t.titleMedium)),
                const SizedBox(width: Gap.md),
                Text(rateLabel,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800, fontVariations: Wght.w800,
                        color: tone)),
              ],
            ),
            const SizedBox(height: Gap.xs),
            Row(
              children: [
                Text(
                    isUnattempted
                        ? '총 ${s.total}문항'
                        : '응시 ${s.attempted}/${s.total}문항',
                    style: t.labelSmall?.copyWith(color: c.textFaint)),
                const Spacer(),
                if (isWeak)
                  InkWell(
                    onTap: () => context
                        .push('/cert/${widget.cert.code}/study/${s.taskId}'),
                    child: Text('학습문서 →',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700, fontVariations: Wght.w700,
                            color: c.accent)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 로드 결과(리포트 + Task 제목 조회).
class _ReportLoad {
  const _ReportLoad({required this.report, required this.taskTitleById});
  final TaskScoreReport report;
  final Map<String, String> taskTitleById;
}
