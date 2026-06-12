import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:go_router/go_router.dart';

import '../content/prescription_hub.dart';
import '../content/quiz_widgets.dart';
import '../data/content_index.dart';
import '../data/exam_session_store.dart';
import '../data/history_store.dart';
import '../data/mock_exam.dart';
import '../data/weighted_exam.dart';
import '../models/attempt_record.dart';
import '../models/exam_guide.dart';
import '../models/exam_session.dart';
import '../models/question.dart';
import '../theme/app_theme.dart';
import '../widgets/state_views.dart';

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
    this.optionOrders = const {},
    this.sessionFingerprint,
    this.onChanged,
    this.onFinished,
    this.onExit,
    this.now,
    this.resultsActionsBuilder,
    this.onOpenStudy,
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

  /// 세션에 기록할 문항별 선택지 표시 순서(복원용). 셔플 미적용 호출부는 빈 맵.
  final Map<String, List<int>> optionOrders;

  /// 세션에 기록할 뱅크 지문. null이면 표시 뱅크에서 계산.
  /// 차출 시험은 표시 뱅크(5문항)가 아니라 전체 뱅크 지문으로 개정을 감지해야 하므로 주입한다.
  final String? sessionFingerprint;

  final void Function(ExamSession)? onChanged;
  final void Function(AttemptRecord)? onFinished;
  final VoidCallback? onExit;
  final DateTime Function()? now;

  /// 결과 화면 처방 허브 빌더. 제출 후 _results 렌더 시점에 호출되어
  /// 방금 끝난 응시(justFinished)를 반영 → 약점 모의고사 잠금해제 stale 방지.
  /// null이면 기존 동작(onExit "학습문서로" 버튼)을 유지(하위호환).
  final Widget Function(BuildContext context, AttemptRecord? justFinished)?
      resultsActionsBuilder;

  /// 오답 복기 카드의 개념 라벨 → 해당 Task 학습문서 이동. null이면 링크 숨김.
  final void Function(String taskId)? onOpenStudy;

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
  AttemptRecord? _justFinished; // 제출된 응시(처방 허브가 잠금/현재응시 계산에 사용)
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
        bankFingerprint:
            widget.sessionFingerprint ?? bankFingerprint(widget.bank),
        questionIds: _qs.map((q) => q.id).toList(),
        optionOrders: widget.optionOrders,
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
    final rec = AttemptRecord(
      certId: widget.certId,
      examId: 'exam:${widget.taskId}',
      mode: 'exam',
      date: _clock().toIso8601String(),
      correct: correct,
      total: _qs.length,
      wrongQuestionIds: wrong,
      flaggedQuestionIds: flaggedIds,
      presentedQuestionIds: [for (final q in _qs) q.id],
      durationSpentSec: spent > widget.durationSec ? widget.durationSec : spent,
    );
    _justFinished = rec;
    widget.onFinished?.call(rec);
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
            onOpenStudy: widget.onOpenStudy,
            subtitle:
                '플래그 ${_flagged.length}개 · 실제 합격선은 1000점 만점 환산 700점(정답률과 다름)',
          ),
          const SizedBox(height: Gap.lg),
          if (widget.resultsActionsBuilder != null)
            widget.resultsActionsBuilder!(context, _justFinished)
          else if (widget.onExit != null)
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

/// 얇은 로더: 문제은행 + 공식 시험 메타를 읽고 세션을 복원해 ExamView에 주입.
class ExamPage extends StatefulWidget {
  const ExamPage({super.key, required this.entry});
  final ContentEntry entry;

  @override
  State<ExamPage> createState() => _ExamPageState();
}

class _ExamPageState extends State<ExamPage> {
  late Future<_ExamLoad> _future = _load(); // 재할당은 에러 재시도에서만
  final _store = ExamSessionStore();
  final _history = HistoryStore();

  String get _examId => 'exam:${widget.entry.taskId}';

  Future<_ExamLoad> _load() async {
    final qRaw = await rootBundle.loadString(widget.entry.questionsAsset);
    final fullBank =
        QuestionBank.fromJson(json.decode(qRaw) as Map<String, dynamic>);

    ExamOverview? overview;
    try {
      final gRaw = await rootBundle
          .loadString('assets/exam_guides/${widget.entry.certCode}.json');
      overview =
          ExamGuide.fromJson(json.decode(gRaw) as Map<String, dynamic>).overview;
    } catch (_) {
      overview = null; // 메타 없으면 폴백 페이스(examDurationSec)
    }

    final examId = _examId;
    final fp = bankFingerprint(fullBank);
    final existing = _store.load(examId);

    // 복원 조건: 미제출 + 전체 뱅크 지문 일치 + 차출 ID 전부 존재 + 선택지 순서 완비(스펙 §3.3).
    // 구버전 세션(optionOrders 없음)은 ordersCoverQuestions에서 걸러져 새 시험으로 시작.
    List<Question>? restoredQs;
    if (existing != null &&
        !existing.submitted &&
        existing.bankFingerprint == fp) {
      final ordered =
          restoreOrdered(existing.questionIds, indexById(fullBank.questions));
      if (ordered != null &&
          ordersCoverQuestions(ordered, existing.optionOrders)) {
        restoredQs = applyOptionOrders(ordered, existing.optionOrders);
      }
    }

    final DateTime startedAt;
    final int durationSec;
    final int initialIndex;
    final Map<int, int> initialPicked;
    final Set<int> initialFlagged;
    final List<Question> presented;
    final Map<String, List<int>> optionOrders;
    if (restoredQs != null) {
      presented = restoredQs;
      optionOrders = existing!.optionOrders;
      // 손상된 startedAt이면 now로 폴백(타이머 리셋 가능 — 정상 흐름에선 항상 기록됨).
      startedAt = DateTime.tryParse(existing.startedAtIso) ?? DateTime.now();
      durationSec = existing.durationSec;
      initialIndex = existing.index;
      initialPicked = existing.picked;
      initialFlagged = existing.flagged.toSet();
    } else {
      if (existing != null) _store.clear(examId); // 개정/제출/구버전 세션 폐기
      final rng = Random();
      final sampled = samplePool(fullBank.questions, taskSampleCount, rng);
      optionOrders = randomOptionOrders(sampled, rng);
      presented = applyOptionOrders(sampled, optionOrders);
      startedAt = DateTime.now();
      durationSec = examDurationSec(
        durationMinutes: overview?.durationMinutes,
        scored: overview?.scoredQuestions,
        unscored: overview?.unscoredQuestions,
        count: presented.length, // 차출 수 기준 — 시간 자동 단축
      );
      initialIndex = 0;
      initialPicked = const {};
      initialFlagged = const {};
    }

    return _ExamLoad(
      bank: QuestionBank(
        examGuideTaskId: fullBank.examGuideTaskId,
        taskTitle: fullBank.taskTitle,
        certCode: fullBank.certCode,
        domain: fullBank.domain,
        questions: presented,
      ),
      fullBankFingerprint: fp,
      optionOrders: optionOrders,
      startedAt: startedAt,
      durationSec: durationSec,
      initialIndex: initialIndex,
      initialPicked: initialPicked,
      initialFlagged: initialFlagged,
      restored: restoredQs != null,
    );
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
        title: Text('${widget.entry.title} · 시험 모드',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      body: FutureBuilder<_ExamLoad>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(
                child: LoadingView(label: '시험을 준비하고 있습니다…'));
          }
          if (snap.hasError) {
            return Center(
              child: ErrorView(
                message: '문항을 불러오지 못했습니다.',
                onRetry: () => setState(() => _future = _load()),
                onHome: () => context.go('/'),
              ),
            );
          }
          final data = snap.data;
          if (data == null || data.bank.questions.isEmpty) {
            return const Center(
              child: EmptyView(
                title: '검증된 문항이 아직 없습니다.',
                description: '사람 검수를 통과한 문항만 출제합니다.',
              ),
            );
          }
          final examId = _examId;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: Layout.exam),
              child: ExamView(
                bank: data.bank,
                certId: widget.entry.certForHistory,
                taskId: widget.entry.taskId,
                startedAt: data.startedAt,
                durationSec: data.durationSec,
                initialIndex: data.initialIndex,
                initialPicked: data.initialPicked,
                initialFlagged: data.initialFlagged,
                restored: data.restored,
                optionOrders: data.optionOrders,
                sessionFingerprint: data.fullBankFingerprint,
                onChanged: _store.save,
                onFinished: (r) {
                  _history.add(r);
                  _store.clear(examId);
                },
                resultsActionsBuilder: (ctx, justFinished) {
                  // history는 onFinished의 add 직후라 현재 응시를 포함한다.
                  final history = _history.all();
                  final code = widget.entry.certCode;
                  final unlocked = weightedExamUnlocked(code, history);
                  return PrescriptionHub(
                    allCorrect: justFinished != null &&
                        justFinished.wrongQuestionIds.isEmpty,
                    onReview: () => ctx.push('/cert/$code/review'),
                    onReport: () => ctx.push('/cert/$code/report'),
                    onWeightedExam: unlocked
                        ? () => ctx.push('/cert/$code/exam/weak')
                        : null,
                    weightedAttemptCount: nonReviewAttemptCount(code, history),
                  );
                },
                onOpenStudy: (taskId) =>
                    context.push('/cert/${widget.entry.certCode}/study/$taskId'),
                onExit: () => context.pop(),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 로드 결과(표시 뱅크 = 차출+셔플 적용 / 지문·순서는 세션 기록용).
class _ExamLoad {
  const _ExamLoad({
    required this.bank,
    required this.fullBankFingerprint,
    required this.optionOrders,
    required this.startedAt,
    required this.durationSec,
    required this.initialIndex,
    required this.initialPicked,
    required this.initialFlagged,
    required this.restored,
  });
  final QuestionBank bank;
  final String fullBankFingerprint;
  final Map<String, List<int>> optionOrders;
  final DateTime startedAt;
  final int durationSec;
  final int initialIndex;
  final Map<int, int> initialPicked;
  final Set<int> initialFlagged;
  final bool restored;
}
