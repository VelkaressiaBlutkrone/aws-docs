import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:go_router/go_router.dart';

import '../content/prescription_hub.dart';
import '../content/study_deep_link.dart';
import '../content/quiz_widgets.dart';
import '../data/content_index.dart';
import '../data/exam_session_store.dart';
import '../data/history_store.dart';
import '../data/mock_exam.dart';
import '../data/question_banks.dart';
import '../data/task_score_report.dart';
import '../data/weighted_exam.dart';
import '../models/certification.dart';
import '../models/exam_guide.dart';
import '../models/exam_session.dart';
import '../models/exam_snapshot.dart';
import '../models/question.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/state_views.dart';
import 'exam_page.dart'; // ExamView

/// 통합 모의고사 진입점. 자격증 전체 검증 문항 풀을 병합해 도메인 가중으로
/// N문항을 샘플링·출제하고, 진행 중 세션을 복원한다. ExamView를 재사용한다.
class CertExamPage extends StatefulWidget {
  const CertExamPage({
    super.key,
    required this.cert,
    this.weighted = false,
    this.backend,
  });
  final Certification cert;
  final bool weighted;

  /// 이력·진행 세션 저장소 백엔드. null이면 `defaultBackend()`(웹=localStorage,
  /// 그 외=메모리)라서 앱 동작은 그대로다. 테스트가 진행 세션을 심어 복원 판정을
  /// 검증할 때만 주입한다 — VM의 `defaultBackend()`는 호출마다 별도 MemoryBackend라
  /// 주입구 없이는 심은 세션을 페이지가 볼 수 없다.
  final KvBackend? backend;

  @override
  State<CertExamPage> createState() => _CertExamPageState();
}

class _CertExamPageState extends State<CertExamPage> {
  late final _store = ExamSessionStore(backend: widget.backend);
  late final _history = HistoryStore(backend: widget.backend);
  late Future<_MockLoad> _future = _load(); // 재할당은 에러 재시도에서만
  _RunParams? _running;

  String get _examId =>
      'exam:${widget.cert.code}-${widget.weighted ? 'weak' : 'mock'}';

  Future<_MockLoad> _load() async {
    final readiness = examWeightedCapacityStatus(widget.cert.code);
    final history = _history.all();
    final attemptCount = nonReviewAttemptCount(widget.cert.code, history);

    // ⚠️ 복원을 게이트보다 **먼저** 본다(설계 §4.3). 문항을 내리는 릴리스가 capacity를
    // ready→not-ready로 뒤집을 수 있는데, 게이트가 먼저 돌면 진행 중이던 세션이 복원
    // 판정에 닿기도 전에 지워진다 — "그 시험 진행 동안 유지"가 조용히 깨지고 반목표
    // ("오히려 세션을 잃는 것")에 걸린다. 게이트는 **새 시험 시작 경로에만** 적용한다.
    // 만료 세션 정리(§4.6). 설계 §7이 "언제 도는가"를 빌더에게 남겼고, 시험 화면 진입이
    // 가장 자연스러운 지점이다 — 쌓이는 쪽과 같은 경로라 압박이 생기는 곳에서 바로 돈다.
    // ⚠️ 실패는 삼킨다: 정리가 안 되는 것보다 시험이 막히는 쪽이 나쁘다(반목표).
    try {
      _store.clearExpired();
    } catch (_) {}

    final run = _store.loadRun(_examId);
    final restorable =
        run == null
            ? null
            : _Restorable(run.snapshot, run.progress, run.progressRestored);
    if (restorable == null) _store.clear(_examId); // 구포맷 단일 키 폐기(§4.8)

    // ⚠️ 게이트는 **새 시험 시작**에만 적용한다(설계 §4.3). 진행 중 시험이 있으면
    // 세션을 지우지 않고 잠금 화면에 "이어서 풀기"를 띄운다 — 문항을 내리는 릴리스가
    // capacity를 ready→not-ready로 뒤집어도 풀던 시험을 뺏지 않는다.
    if (!readiness.ready) {
      if (restorable == null) _store.clearCertExamSessions(widget.cert.code);
      return _MockLoad.capacityLocked(
        readiness: readiness,
        weightedAttemptCount: attemptCount,
        restorable: restorable,
      );
    }
    if (widget.weighted &&
        !weightedExamAttemptUnlocked(widget.cert.code, history)) {
      if (restorable == null) _store.clear(_examId);
      return _MockLoad.attemptLocked(
        readiness: readiness,
        weightedAttemptCount: attemptCount,
        restorable: restorable,
      );
    }

    final entries = contentFor(widget.cert.code);
    final banks = <QuestionBank>[];
    final taskByQuestionId = <String, String>{};
    final taskOrder = <String>[];
    final taskPool = <String, List<Question>>{};
    // 공용 로더가 문항 0 Task 생략·병렬 로드·순서 보존을 담당한다(리뷰 M-4).
    for (final l in await loadQuestionBanks(entries)) {
      banks.add(l.bank);
      taskOrder.add(l.entry.taskId);
      taskPool[l.entry.taskId] = l.bank.questions;
      for (final q in l.bank.questions) {
        taskByQuestionId[q.id] = l.entry.taskId;
      }
    }
    final pool = groupByDomain(banks);
    final all = [for (final b in banks) ...b.questions];
    // `indexById`로 만들던 ID 색인은 더 이상 필요 없다 — 복원이 스냅샷만 쓰므로
    // 현재 뱅크에서 문항을 ID로 되찾는 단계가 사라졌다(설계 §4.7).

    var weights = <int, int>{};
    ExamOverview? overview;
    try {
      final gRaw = await rootBundle.loadString(
        'assets/exam_guides/${widget.cert.code}.json',
      );
      final guide = ExamGuide.fromJson(
        json.decode(gRaw) as Map<String, dynamic>,
      );
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
        history: history,
        taskByQuestionId: taskByQuestionId,
        taskOrder: taskOrder,
      );
      taskWeights = weightByTaskFromReport(report);
    }

    // 복원 후보는 위에서 이미 처리했다 — 여기 도달했다는 건 진행 세션이 없다는 뜻이다.
    // 개정 감지(`bankFingerprint`·`restoreOrdered`)는 스냅샷 도입으로 불필요해졌다:
    // 복원이 에셋을 읽지 않으므로 대조할 대상 자체가 없다(설계 §3에서 감지 안 기각).
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
    _store.clear(_examId); // 구포맷 단일 키
    // ⚠️ 옛 런도 지운다. 안 지우면 아래 스냅샷 쓰기가 쿼터로 실패했을 때 **옛 스냅샷이
    // 남고 진행만 새 nonce로** 덮여, 새로고침 시 옛 시험이 되살아나고 새 답이 사라진다
    // (nonce가 못 막는 갈래 — 2026-10-25 최종 리뷰 I-3).
    try {
      _store.clearRun(_examId);
    } catch (_) {
      // 삭제까지 막히는 저장소라면 복원을 포기시킬 수단이 없다 — 시험은 진행한다.
    }
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
    // 시작 시 스냅샷을 1회 쓴다(설계 §4.5 — 통합·약점은 시작 화면이 있다).
    // ⚠️ 쓰기 실패는 삼킨다 — 저장이 안 되는 것보다 시작이 막히는 쪽이 나쁘다(반목표).
    final nonce = '${startedAt.microsecondsSinceEpoch}';
    try {
      _store.saveSnapshot(ExamSnapshot(
        examId: _examId,
        certId: widget.cert.code,
        taskId: '${widget.cert.code}-${widget.weighted ? 'weak' : 'mock'}',
        nonce: nonce,
        // ⚠️ UTC로 쓴다(`...Z`). 오프셋 없는 로컬 벽시계로 저장하면 DST·시간대 이동 뒤
        // 같은 문자열이 다른 절대 시각으로 읽혀 `clearExpired`가 **살아 있는** 세션을
        // 만료로 오판할 수 있다 — 반목표("오히려 세션을 잃는 것").
        startedAtIso: startedAt.toUtc().toIso8601String(),
        durationSec: durationSec,
        questions: questions,
        passingScore: d.overview?.passingScore,
      ));
    } catch (_) {
      // 복원만 포기하고 시험은 진행한다
    }

    setState(
      () => _running = _RunParams.fresh(
        questions,
        orders,
        startedAt,
        durationSec,
        nonce,
        d.overview?.passingScore,
      ),
    );
  }

  /// 진행 저장 — 스냅샷은 시작 때 이미 썼으므로 여기서는 가변부만 갱신한다(§4.4).
  void _onProgress(ExamProgress p) {
    try {
      _store.saveProgress(p);
    } catch (_) {
      // 저장 실패가 시험을 막으면 안 된다(반목표)
    }
  }

  /// 세로 공간이 남으면 가운데, 모자라면 스크롤. 비스크롤 `Column`으로 두면 짧은
  /// 뷰포트에서 아래쪽(잠금 화면의 "이어서 풀기", 시작 화면의 버튼)이 잘려 **닿을 수조차
  /// 없다** — 실측: 폭 400에서 시작 화면은 높이 360, 잠금 화면은 240부터 넘쳤다.
  ///
  /// ⚠️ `context`는 **Scaffold body 아래**의 것이어야 한다(FutureBuilder 빌더). 페이지
  /// State의 context로 부르면 `headerScrollInset`이 0을 돌려줘, 글래스 헤더가 덮는
  /// body 위쪽에 첫 줄이 깔린다 — 실측: 제목 상단 24.0 vs 헤더 하단 56.0.
  static Widget _scrollCenter(BuildContext context, Widget child) => Center(
        child: SingleChildScrollView(
          // gap 0 — 자식이 이미 자기 여백을 갖고 있다. 여기서 더하는 건 헤더 높이뿐.
          padding: EdgeInsets.only(top: headerScrollInset(context, gap: 0)),
          child: child,
        ),
      );

  /// 잠금 화면 위에 "이어서 풀기"를 덧붙인다(설계 §4.3) — 게이트는 새 시험 시작만
  /// 막고, 이미 진행 중인 시험은 끝까지 풀 수 있어야 한다.
  Widget _withResume(Widget locked, _Restorable? restorable) {
    if (restorable == null) return locked;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        locked,
        const SizedBox(height: Gap.lg),
        SizedBox(
          width: 220,
          child: PrimaryButton(
            label: '이어서 풀기',
            onTap: () => _resume(restorable),
          ),
        ),
      ],
    );
  }

  void _resume(_Restorable r) {
    setState(() => _running = _RunParams.fromSnapshot(r));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      backgroundColor: c.bg,
      extendBodyBehindAppBar: true, // 글래스 헤더 — 인벤토리 §5
      appBar: AppHeader.document(
        sectionLabel: widget.cert.code,
        title: widget.weighted ? '약점 집중 모의고사' : '통합 모의고사',
      ),
      body: FutureBuilder<_MockLoad>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: LoadingView(label: '모의고사를 준비하고 있습니다…'));
          }
          final data = snap.data;
          // 에러와 빈 풀을 분리 — 로드 실패를 "문항 없음"으로 가장하지 않는다(fatal 분류).
          if (snap.hasError || data == null) {
            return Center(
              child: ErrorView(
                message: '모의고사를 준비하지 못했습니다.',
                onRetry: () => setState(() => _future = _load()),
                onHome: () => context.go('/'),
              ),
            );
          }
          // ⚠️ 진행 중 런을 **잠금·빈 상태 분기보다 먼저** 본다. 뒤에 두면 잠금 화면의
          // "이어서 풀기"를 눌러 `_running`이 설정돼도 다음 빌드가 여전히 잠금 화면을
          // 돌려줘 죽은 버튼이 된다 — §4.3의 목적이 통째로 작동하지 않는다
          // (2026-10-25 최종 리뷰 C-1).
          if (_running != null) {
            return _examView(
              _running!,
              _running!.passingScore ?? data.overview?.passingScore,
            );
          }
          if (data.capacityLocked) {
            return _scrollCenter(
              context,
              _withResume(
                _capacityLockedView(data.readiness!),
                data.restorable,
              ),
            );
          }
          if (data.attemptLocked) {
            return _scrollCenter(
              context,
              _withResume(
                _attemptLockedView(data.weightedAttemptCount),
                data.restorable,
              ),
            );
          }
          if (data.total == 0) {
            return const Center(
              child: EmptyView(
                title: '검증된 문항이 아직 없습니다.',
                description: '문항이 사람 검수를 통과하면 모의고사가 열립니다.',
              ),
            );
          }
          // ⚠️ 이 `context`(FutureBuilder 빌더)를 넘긴다 — Scaffold body 아래여야
          // 헤더 인셋이 실제 헤더 높이를 돌려준다.
          return _startScreen(context, data);
        },
      ),
    );
  }

  Widget _examView(_RunParams r, int? passingScore) {
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
          progressRestored: r.progressRestored,
          passingScore: passingScore,
          runNonce: r.nonce,
          onProgress: _onProgress,
          onFinished: (rec) => recordFinishedAttempt(rec,
              history: _history, sessions: _store, examId: _examId),
          resultsActionsBuilder: (ctx, justFinished) {
            // history는 onFinished의 add 직후라 현재 응시를 포함한다(잠금해제 stale 방지).
            final history = _history.all();
            final code = widget.cert.code;
            final hasCapacity = certExamHasWeightedCapacity(code);
            final unlocked = certWeightedExamUnlocked(code, history);
            return PrescriptionHub(
              allCorrect:
                  justFinished != null && justFinished.wrongQuestionIds.isEmpty,
              onReview: () => ctx.push('/cert/$code/review'),
              onReport: () => ctx.push('/cert/$code/report'),
              onWeightedExam: unlocked
                  ? () => ctx.push('/cert/$code/exam/weak')
                  : null,
              weightedAttemptCount: nonReviewAttemptCount(code, history),
              weightedLockedNote: hasCapacity ? null : '검증 문항 준비 중',
            );
          },
          onOpenStudy: (taskId, section) =>
              context.push(studyDeepLink(widget.cert.code, taskId, section)),
          onExit: () => context.pop(),
        ),
      ),
    );
  }

  Widget _capacityLockedView(ExamReadinessStatus readiness) {
    final mode = widget.weighted ? '약점 집중 모의고사' : '통합 모의고사';
    final description = readiness.hasPolicy
        ? '공식 도메인 비중을 앱의 ${readiness.practiceQuestionCount}문항 연습 세트에 적용하려면 도메인별 검증 문항이 더 필요합니다.\n${readiness.domainProgressLabel}'
        : '이 자격증은 아직 앱의 모의고사 구성 정책이 등록되지 않았습니다.';
    return EmptyView(
      title: '${widget.cert.code} $mode는 아직 준비 중입니다.',
      description: description,
    );
  }

  Widget _attemptLockedView(int attemptCount) => EmptyView(
    title: '${widget.cert.code} 약점 집중 모의고사는 아직 잠겨 있습니다.',
    description:
        '오답 복습을 제외한 응시 기록이 $kWeightedExamMinAttempts회 쌓이면 열립니다. 현재 $attemptCount/$kWeightedExamMinAttempts회입니다.',
  );

  Widget _startScreen(BuildContext context, _MockLoad d) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    final target = _targetN(d.overview);
    final cap = target < d.total ? target : d.total;
    // 실제 타이머(examDurationSec, count=cap)와 동일 기준으로 표시 — 풀 부족 시 오도 방지.
    final mins =
        (examDurationSec(
                  durationMinutes: d.overview?.durationMinutes,
                  scored: d.overview?.scoredQuestions,
                  unscored: d.overview?.unscoredQuestions,
                  count: cap,
                ) /
                60)
            .round();
    final pass = d.overview?.passingScore;
    final restorable = d.restorable;
    return _scrollCenter(
      context,
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(Gap.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.weighted ? '약점 집중 모의고사' : '통합 모의고사',
                style: t.headlineSmall,
              ),
              const SizedBox(height: Gap.sm),
              Text(
                widget.weighted
                    ? '지금까지 자주 틀린 Task가 더 자주 출제됩니다. 전체 검증 문항 풀(${d.total}개) 기반.'
                    : '자격증 전체 검증 문항 풀(${d.total}개)에서 공식 도메인 비중을 앱의 ${_targetN(d.overview)}문항 연습 세트에 적용해 출제합니다.',
                style: t.bodyMedium,
              ),
              const SizedBox(height: Gap.lg),
              _infoRow(c, t, '문항 수', '$cap문항'),
              _infoRow(c, t, '제한 시간', '$mins분'),
              if (pass != null) _infoRow(c, t, '합격선', '$pass / 1000 (정답률과 다름)'),
              _infoRow(
                c,
                t,
                '출제 방식',
                widget.weighted
                    ? '약점 Task 가중(자주 틀린 Task 우선)'
                    : _weightLabel(d.weights),
              ),
              const SizedBox(height: Gap.xl),
              if (restorable != null) ...[
                SizedBox(
                  width: 220,
                  child: PrimaryButton(
                    label: '이어서 풀기',
                    onTap: () => _resume(restorable),
                  ),
                ),
                const SizedBox(height: Gap.sm),
                InkWell(
                  onTap: () => _startFresh(d),
                  borderRadius: BorderRadius.circular(Radii.sm),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: Gap.sm,
                      horizontal: Gap.xs,
                    ),
                    child: Text(
                      '새로 시작',
                      style: TextStyle(
                        color: c.textMuted,
                        fontWeight: FontWeight.w700,
                        fontVariations: Wght.w700,
                      ),
                    ),
                  ),
                ),
              ] else
                SizedBox(
                  width: 220,
                  child: PrimaryButton(
                    label: '시작',
                    onTap: () => _startFresh(d),
                  ),
                ),
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
              child: Text(
                label,
                style: t.labelLarge?.copyWith(color: c.textMuted),
              ),
            ),
            Expanded(child: Text(value, style: t.labelLarge)),
          ],
        ),
      );

  String _weightLabel(Map<int, int> w) {
    final keys = w.keys.toList()..sort();
    return '${keys.map((k) => 'D$k ${w[k]}').join(' · ')}%';
  }
}

/// 복원 가능한 진행 세션(스냅샷 체제) — 스냅샷과 그 세대의 진행은 항상 함께 존재한다.
/// 문항은 스냅샷이 들고 있으므로 복원이 에셋을 읽지 않는다(설계 §4.1).
class _Restorable {
  const _Restorable(this.snapshot, this.progress, this.progressRestored);
  final ExamSnapshot snapshot;
  final ExamProgress progress;

  /// 저장된 진행을 채택했는지(§4.4.1) — 복원 노트 문구가 이걸로 갈린다.
  final bool progressRestored;
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
  }) : readiness = null,
       capacityLocked = false,
       attemptLocked = false,
       weightedAttemptCount = 0;

  const _MockLoad.capacityLocked({
    required this.readiness,
    required this.weightedAttemptCount,
    required this.restorable,
  }) : pool = const <int, List<Question>>{},
       weights = const <int, int>{},
       taskPool = const <String, List<Question>>{},
       taskWeights = const <String, int>{},
       overview = null,
       total = 0,
       capacityLocked = true,
       attemptLocked = false;

  const _MockLoad.attemptLocked({
    required this.readiness,
    required this.weightedAttemptCount,
    required this.restorable,
  }) : pool = const <int, List<Question>>{},
       weights = const <int, int>{},
       taskPool = const <String, List<Question>>{},
       taskWeights = const <String, int>{},
       overview = null,
       total = 0,
       capacityLocked = false,
       attemptLocked = true;

  final Map<int, List<Question>> pool; // 도메인 모드
  final Map<int, int> weights; // 도메인 모드
  final Map<String, List<Question>> taskPool; // 약점 모드
  final Map<String, int> taskWeights; // 약점 모드
  final ExamOverview? overview;
  final int total;
  final _Restorable? restorable;
  final ExamReadinessStatus? readiness;
  final bool capacityLocked;
  final bool attemptLocked;
  final int weightedAttemptCount;
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
  final bool progressRestored;

  /// 세대 식별자 — 진행 레코드가 들고 다닌다(설계 §4.4.1).
  final String nonce;

  /// 복원 런이 들고 온 합격선. 잠금 화면에서 이어 풀면 `overview`가 없으므로 이쪽을 쓴다.
  final int? passingScore;

  _RunParams.fresh(
    this.questions,
    this.optionOrders,
    this.startedAt,
    this.durationSec,
    this.nonce,
    this.passingScore,
  ) : index = 0,
      picked = const <int, int>{},
      flagged = const <int>{},
      restored = false,
      progressRestored = true;

  /// 스냅샷 복원 — 보기는 이미 표시 순서가 적용돼 있어 `optionOrders`가 비어 있다.
  _RunParams.fromSnapshot(_Restorable r)
    : questions = r.snapshot.questions,
      optionOrders = const {},
      startedAt =
          DateTime.tryParse(r.snapshot.startedAtIso) ?? DateTime.now(),
      durationSec = r.snapshot.durationSec,
      index = r.progress.index,
      picked = r.progress.picked,
      flagged = r.progress.flagged.toSet(),
      nonce = r.snapshot.nonce,
      passingScore = r.snapshot.passingScore,
      restored = true,
      progressRestored = r.progressRestored;
}
