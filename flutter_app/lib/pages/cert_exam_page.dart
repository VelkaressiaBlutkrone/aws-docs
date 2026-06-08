import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:go_router/go_router.dart';

import '../content/quiz_widgets.dart';
import '../data/content_index.dart';
import '../data/exam_session_store.dart';
import '../data/history_store.dart';
import '../data/mock_exam.dart';
import '../data/task_score_report.dart';
import '../data/weighted_exam.dart';
import '../models/certification.dart';
import '../models/exam_guide.dart';
import '../models/exam_session.dart';
import '../models/question.dart';
import '../theme/app_theme.dart';
import 'exam_page.dart'; // ExamView

/// 통합 모의고사 진입점. 자격증 전체 검증 문항 풀을 병합해 도메인 가중으로
/// N문항을 샘플링·출제하고, 진행 중 세션을 복원한다. ExamView를 재사용한다.
class CertExamPage extends StatefulWidget {
  const CertExamPage({super.key, required this.cert, this.weighted = false});
  final Certification cert;
  final bool weighted;

  @override
  State<CertExamPage> createState() => _CertExamPageState();
}

class _CertExamPageState extends State<CertExamPage> {
  final _store = ExamSessionStore();
  final _history = HistoryStore();
  late final Future<_MockLoad> _future = _load();
  _RunParams? _running;

  String get _examId =>
      'exam:${widget.cert.code}-${widget.weighted ? 'weak' : 'mock'}';

  Future<_MockLoad> _load() async {
    final entries = contentFor(widget.cert.code);
    final banks = <QuestionBank>[];
    final taskByQuestionId = <String, String>{};
    final taskOrder = <String>[];
    final taskPool = <String, List<Question>>{};
    for (final e in entries) {
      // 학습문서만 있는(문항 0) Task는 questions.json이 없다 → 로드 생략(404 방지).
      if (!e.hasQuestions) continue;
      try {
        final raw = await rootBundle.loadString(e.questionsAsset);
        final bank =
            QuestionBank.fromJson(json.decode(raw) as Map<String, dynamic>);
        banks.add(bank);
        taskOrder.add(e.taskId);
        taskPool[e.taskId] = bank.questions;
        for (final q in bank.questions) {
          taskByQuestionId[q.id] = e.taskId;
        }
      } catch (_) {
        // 개별 뱅크 로드 실패는 무시(나머지로 진행)
      }
    }
    final pool = groupByDomain(banks);
    final all = [for (final b in banks) ...b.questions];
    final byId = indexById(all);

    var weights = <int, int>{};
    ExamOverview? overview;
    try {
      final gRaw = await rootBundle
          .loadString('assets/exam_guides/${widget.cert.code}.json');
      final guide =
          ExamGuide.fromJson(json.decode(gRaw) as Map<String, dynamic>);
      overview = guide.overview;
      weights = {for (final d in guide.domains) d.no: d.weightPct};
    } catch (_) {
      overview = null;
    }
    if (weights.isEmpty) {
      weights = {for (final d in pool.keys) d: 1}; // 균등 폴백
    }

    // 약점 가중은 약점 모드에서만 계산(도메인 모드는 불필요).
    var taskWeights = <String, int>{};
    if (widget.weighted) {
      final report = TaskScoreReport.build(
        certId: widget.cert.code,
        history: _history.all(),
        taskByQuestionId: taskByQuestionId,
        taskOrder: taskOrder,
      );
      taskWeights = weightByTaskFromReport(report);
    }

    // 복원 가능한 진행 세션? — 문항 ID 복원 + 선택지 순서 완비 검증(스펙 §3.3)
    final existing = _store.load(_examId);
    _Restorable? restorable;
    if (existing != null && !existing.submitted) {
      final restored = restoreOrdered(existing.questionIds, byId);
      if (restored == null ||
          !ordersCoverQuestions(restored, existing.optionOrders)) {
        _store.clear(_examId); // 개정/불일치/구버전 폐기
      } else {
        restorable = _Restorable(
            existing, applyOptionOrders(restored, existing.optionOrders));
      }
    }

    return _MockLoad(
      pool: pool,
      weights: weights,
      taskPool: taskPool,
      taskWeights: taskWeights,
      overview: overview,
      total: all.length,
      restorable: restorable,
    );
  }

  int _targetN(ExamOverview? o) =>
      (o?.scoredQuestions ?? 50) + (o?.unscoredQuestions ?? 15);

  void _startFresh(_MockLoad d) {
    _store.clear(_examId);
    final rng = Random();
    final sampled = widget.weighted
        ? buildSampledExam<String>(
            poolByKey: d.taskPool,
            weightByKey: d.taskWeights,
            n: _targetN(d.overview),
            rng: rng,
          )
        : buildMockExam(
            poolByDomain: d.pool,
            weightByDomain: d.weights,
            n: _targetN(d.overview),
            rng: rng,
          );
    final orders = randomOptionOrders(sampled, rng); // 선택지 셔플(스펙 §3.2)
    final questions = applyOptionOrders(sampled, orders);
    final startedAt = DateTime.now();
    final durationSec = examDurationSec(
      durationMinutes: d.overview?.durationMinutes,
      scored: d.overview?.scoredQuestions,
      unscored: d.overview?.unscoredQuestions,
      count: questions.length,
    );
    setState(() =>
        _running = _RunParams.fresh(questions, orders, startedAt, durationSec));
  }

  void _resume(_Restorable r) {
    setState(() => _running = _RunParams.restored(r.session, r.questions));
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
        title: Text(
            '${widget.cert.code} · ${widget.weighted ? '약점 집중 모의고사' : '통합 모의고사'}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      body: FutureBuilder<_MockLoad>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snap.data;
          if (snap.hasError || data == null || data.total == 0) {
            return Center(
                child: Text('검증된 문항이 아직 없습니다.',
                    style: TextStyle(color: c.textMuted)));
          }
          if (_running != null) return _examView(_running!);
          return _startScreen(data);
        },
      ),
    );
  }

  Widget _examView(_RunParams r) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Layout.exam),
        child: ExamView(
          bank: QuestionBank(
            examGuideTaskId:
                '${widget.cert.code}-${widget.weighted ? 'weak' : 'mock'}',
            taskTitle: widget.weighted ? '약점 집중 모의고사' : '통합 모의고사',
            certCode: widget.cert.code,
            domain: 0,
            questions: r.questions,
          ),
          certId: widget.cert.code,
          taskId: '${widget.cert.code}-${widget.weighted ? 'weak' : 'mock'}',
          startedAt: r.startedAt,
          durationSec: r.durationSec,
          initialIndex: r.index,
          initialPicked: r.picked,
          initialFlagged: r.flagged,
          restored: r.restored,
          optionOrders: r.optionOrders,
          onChanged: _store.save,
          onFinished: (rec) {
            _history.add(rec);
            _store.clear(_examId);
          },
          onExit: () => context.pop(),
        ),
      ),
    );
  }

  Widget _startScreen(_MockLoad d) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    final target = _targetN(d.overview);
    final cap = target < d.total ? target : d.total;
    // 실제 타이머(examDurationSec, count=cap)와 동일 기준으로 표시 — 풀 부족 시 오도 방지.
    final mins = (examDurationSec(
              durationMinutes: d.overview?.durationMinutes,
              scored: d.overview?.scoredQuestions,
              unscored: d.overview?.unscoredQuestions,
              count: cap,
            ) /
            60)
        .round();
    final pass = d.overview?.passingScore;
    final restorable = d.restorable;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(Gap.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.weighted ? '약점 집중 모의고사' : '통합 모의고사',
                  style: t.headlineSmall),
              const SizedBox(height: Gap.sm),
              Text(
                  widget.weighted
                      ? '지금까지 자주 틀린 Task가 더 자주 출제됩니다. 전체 검증 문항 풀(${d.total}개) 기반.'
                      : '자격증 전체 검증 문항 풀(${d.total}개)에서 도메인 비중에 맞춰 출제합니다.',
                  style: t.bodyMedium),
              const SizedBox(height: Gap.lg),
              _infoRow(c, t, '문항 수', '$cap문항'),
              _infoRow(c, t, '제한 시간', '$mins분'),
              if (pass != null)
                _infoRow(c, t, '합격선', '$pass / 1000 (정답률과 다름)'),
              _infoRow(c, t, '출제 방식',
                  widget.weighted ? '약점 Task 가중(자주 틀린 Task 우선)' : _weightLabel(d.weights)),
              const SizedBox(height: Gap.xl),
              if (restorable != null) ...[
                SizedBox(
                    width: 220,
                    child: PrimaryButton(
                        label: '이어서 풀기', onTap: () => _resume(restorable))),
                const SizedBox(height: Gap.sm),
                InkWell(
                  onTap: () => _startFresh(d),
                  borderRadius: BorderRadius.circular(Radii.sm),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: Gap.sm, horizontal: Gap.xs),
                    child: Text('새로 시작',
                        style: TextStyle(
                            color: c.textMuted, fontWeight: FontWeight.w700)),
                  ),
                ),
              ] else
                SizedBox(
                    width: 220,
                    child:
                        PrimaryButton(label: '시작', onTap: () => _startFresh(d))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(AppColors c, TextTheme t, String label, String value) =>
      Padding(
        padding: const EdgeInsets.only(bottom: Gap.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: 96,
                child: Text(label,
                    style: t.labelLarge?.copyWith(color: c.textMuted))),
            Expanded(child: Text(value, style: t.labelLarge)),
          ],
        ),
      );

  String _weightLabel(Map<int, int> w) {
    final keys = w.keys.toList()..sort();
    return '${keys.map((k) => 'D$k ${w[k]}').join(' · ')}%';
  }
}

/// 복원 가능한 진행 세션 — 세션과 그에 맞춰 정렬 복원된 문항은 항상 함께 존재한다.
/// (둘 중 하나만 있는 상태를 타입으로 배제.)
class _Restorable {
  const _Restorable(this.session, this.questions);
  final ExamSession session;
  final List<Question> questions;
}

/// 로드 결과(풀·인덱스·가중·메타·복원 후보).
class _MockLoad {
  const _MockLoad({
    required this.pool,
    required this.weights,
    required this.taskPool,
    required this.taskWeights,
    required this.overview,
    required this.total,
    required this.restorable,
  });
  final Map<int, List<Question>> pool; // 도메인 모드
  final Map<int, int> weights; // 도메인 모드
  final Map<String, List<Question>> taskPool; // 약점 모드
  final Map<String, int> taskWeights; // 약점 모드
  final ExamOverview? overview;
  final int total;
  final _Restorable? restorable;
}

/// ExamView에 주입할 실행 파라미터(새 시험 / 복원).
class _RunParams {
  final List<Question> questions;
  final Map<String, List<int>> optionOrders;
  final DateTime startedAt;
  final int durationSec;
  final int index;
  final Map<int, int> picked;
  final Set<int> flagged;
  final bool restored;

  _RunParams.fresh(
      this.questions, this.optionOrders, this.startedAt, this.durationSec)
      : index = 0,
        picked = const <int, int>{},
        flagged = const <int>{},
        restored = false;

  _RunParams.restored(ExamSession s, this.questions)
      : optionOrders = s.optionOrders,
        startedAt = DateTime.tryParse(s.startedAtIso) ?? DateTime.now(),
        durationSec = s.durationSec,
        index = s.index,
        picked = s.picked,
        flagged = s.flagged.toSet(),
        restored = true;
}
