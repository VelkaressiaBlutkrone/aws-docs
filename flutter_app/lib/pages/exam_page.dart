import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:go_router/go_router.dart';

import '../content/prescription_hub.dart';
import '../content/study_deep_link.dart';
import '../data/content_index.dart';
import '../data/exam_session_store.dart';
import '../data/history_store.dart';
import '../data/mock_exam.dart';
import '../data/weighted_exam.dart';
import '../models/exam_guide.dart';
import '../models/exam_session.dart';
import '../models/question.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/state_views.dart';
import 'exam/exam_view.dart';

/// 분해로 ExamView가 exam/exam_view.dart로 옮겨졌지만, 기존 임포트
/// (`app_router.dart` · `cert_exam_page.dart` · `test/exam_view_test.dart`)가
/// 그대로 동작하도록 재노출한다.
export 'exam/exam_view.dart' show ExamView, recordFinishedAttempt;

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
    final fullBank = QuestionBank.fromJson(
      json.decode(qRaw) as Map<String, dynamic>,
    );

    ExamOverview? overview;
    try {
      final gRaw = await rootBundle.loadString(
        'assets/exam_guides/${widget.entry.certCode}.json',
      );
      overview = ExamGuide.fromJson(
        json.decode(gRaw) as Map<String, dynamic>,
      ).overview;
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
      final ordered = restoreOrdered(
        existing.questionIds,
        indexById(fullBank.questions),
      );
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
      passingScore: overview?.passingScore,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      backgroundColor: c.bg,
      extendBodyBehindAppBar: true, // 글래스 헤더 — 인벤토리 §5
      appBar: AppHeader.document(
        sectionLabel: widget.entry.title,
        title: '시험 모드',
      ),
      body: FutureBuilder<_ExamLoad>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: LoadingView(label: '시험을 준비하고 있습니다…'));
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
                passingScore: data.passingScore,
                onChanged: _store.save,
                onFinished: (r) => recordFinishedAttempt(r,
                    history: _history, sessions: _store, examId: examId),
                resultsActionsBuilder: (ctx, justFinished) {
                  // history는 onFinished의 add 직후라 현재 응시를 포함한다.
                  final history = _history.all();
                  final code = widget.entry.certCode;
                  final hasCapacity = certExamHasWeightedCapacity(code);
                  final unlocked = certWeightedExamUnlocked(code, history);
                  return PrescriptionHub(
                    allCorrect:
                        justFinished != null &&
                        justFinished.wrongQuestionIds.isEmpty,
                    onReview: () => ctx.push('/cert/$code/review'),
                    onReport: () => ctx.push('/cert/$code/report'),
                    onWeightedExam: unlocked
                        ? () => ctx.push('/cert/$code/exam/weak')
                        : null,
                    weightedAttemptCount: nonReviewAttemptCount(code, history),
                    weightedLockedNote: hasCapacity ? null : '검증 문항 준비 중',
                  );
                },
                onOpenStudy: (taskId, section) => context.push(
                  studyDeepLink(widget.entry.certCode, taskId, section),
                ),
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
    required this.passingScore,
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
  final int? passingScore; // 시험 가이드 메타(없으면 null)
}
