import 'dart:async';

import 'package:flutter/material.dart';

import '../../content/quiz_widgets.dart';
import '../../data/exam_session_store.dart';
import '../../data/history_store.dart';
import '../../data/wrong_skills.dart';
import '../../models/attempt_record.dart';
import '../../models/exam_session.dart';
import '../../models/exam_snapshot.dart';
import '../../models/question.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_header.dart';
import 'exam_bits.dart';

/// 모델 주입식 시험 러너(테스트 대상). 자산/localStorage 의존 없음.
///
/// 분해 — exam_page.dart에서 이동. 임포트 호환을 위해 exam_page.dart가
/// `ExamView`·`recordFinishedAttempt`를 재노출한다.
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
    this.onProgress,
    this.runNonce,
    this.onFinished,
    this.onExit,
    this.now,
    this.resultsActionsBuilder,
    this.onOpenStudy,
    this.passingScore,
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

  /// 스냅샷 체제의 진행 통지(설계 2026-10-24 §4.4). 가변부만 넘긴다 — 출제 문항은
  /// 스냅샷이 이미 들고 있다. `onChanged`와 당분간 공존하며, 페이지가 모두 옮겨간 뒤
  /// 구경로를 제거한다(expand → migrate → contract).
  final void Function(ExamProgress)? onProgress;

  /// 진행 레코드가 들고 다닐 세대 식별자. 스냅샷의 `nonce`와 같아야 짝으로 인정된다.
  final String? runNonce;
  final void Function(AttemptRecord)? onFinished;
  final VoidCallback? onExit;
  final DateTime Function()? now;

  /// 결과 화면 처방 허브 빌더. 제출 후 _results 렌더 시점에 호출되어
  /// 방금 끝난 응시(justFinished)를 반영 → 약점 모의고사 잠금해제 stale 방지.
  /// null이면 기존 동작(onExit "학습문서로" 버튼)을 유지(하위호환).
  final Widget Function(BuildContext context, AttemptRecord? justFinished)?
  resultsActionsBuilder;

  /// 오답 복기 카드의 개념 라벨 → 해당 Task 학습문서 이동. null이면 링크 숨김.
  final void Function(String taskId, String section)? onOpenStudy;

  /// 공식 합격선(1000점 만점 환산, 시험 가이드 메타). null이면 결과 부제에서 생략.
  final int? passingScore;

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
    assert(
      widget.bank.questions.isNotEmpty,
      'ExamView requires a non-empty question bank',
    );
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
    bankFingerprint: widget.sessionFingerprint ?? bankFingerprint(widget.bank),
    questionIds: _qs.map((q) => q.id).toList(),
    optionOrders: widget.optionOrders,
    submitted: _submitted,
  );

  ExamProgress _progress() => ExamProgress(
        examId: 'exam:${widget.taskId}',
        nonce: widget.runNonce ?? '',
        index: _index,
        picked: _picked,
        flagged: _flagged.toList()..sort(),
      );

  void _persist() {
    widget.onChanged?.call(_session());
    widget.onProgress?.call(_progress());
  }

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
      wrongSkills: buildWrongSkills(_qs, _picked),
      durationSpentSec: spent > widget.durationSec ? widget.durationSec : spent,
    );
    _justFinished = rec;
    try {
      widget.onFinished?.call(rec);
    } finally {
      // 기록 저장(onFinished)이 실패해도 결과 화면은 연다 — 예외는 그대로 전파.
      if (mounted) setState(() {});
    }
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
            child: const Text('계속 풀기'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('제출하기'),
          ),
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
      padding: EdgeInsets.all(Gap.xl).copyWith(top: headerScrollInset(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timer_outlined,
                size: 18,
                color: low ? c.warning : c.textMuted,
              ),
              const SizedBox(width: Gap.xs),
              Text(
                _mmss(remaining),
                style: TextStyle(
                  fontFamily: AppTheme.monoFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontVariations: Wght.w700,
                  color: low ? c.warning : c.text,
                ),
              ),
              const Spacer(),
              Text('${_index + 1} / ${_qs.length}', style: t.labelSmall),
            ],
          ),
          if (widget.restored)
            Padding(
              padding: const EdgeInsets.only(top: Gap.xs),
              child: Text(
                '이전 진행을 복원했습니다.',
                style: t.labelSmall?.copyWith(color: c.textMuted),
              ),
            ),
          const SizedBox(height: Gap.md),
          Wrap(
            spacing: Gap.xs,
            runSpacing: Gap.xs,
            children: [
              for (var k = 0; k < _qs.length; k++)
                GridChip(
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
                SecondaryButton(
                  icon: Icons.chevron_left,
                  label: '이전',
                  onTap: () => _go(_index - 1),
                ),
              const SizedBox(width: Gap.sm),
              SecondaryButton(
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
    final pass = widget.passingScore;
    return SingleChildScrollView(
      padding: EdgeInsets.all(Gap.xl).copyWith(top: headerScrollInset(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResultsView(
            bank: widget.bank,
            picked: _picked,
            flagged: _flagged,
            onOpenStudy: widget.onOpenStudy,
            // 합격선은 자격증마다 다르다(700/720/750) — 메타가 없으면 지어내지 않는다.
            subtitle: pass == null
                ? '플래그 ${_flagged.length}개'
                : '플래그 ${_flagged.length}개 · 실제 합격선은 1000점 만점 환산 $pass점(정답률과 다름)',
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

/// 제출된 응시를 이력에 기록하고 진행 세션을 정리한다(ExamPage·CertExamPage 공용).
/// 기록 저장이 실패해도(localStorage 쿼터 초과 등) 제출된 세션은 정리하고,
/// 예외는 호출자로 전파한다(전역 핸들러가 로그).
void recordFinishedAttempt(
  AttemptRecord r, {
  required HistoryStore history,
  required ExamSessionStore sessions,
  required String examId,
}) {
  try {
    history.add(r);
  } finally {
    sessions.clear(examId); // 구포맷 단일 키
    sessions.clearRun(examId); // 스냅샷·진행 두 키(설계 §4.6)
  }
}
