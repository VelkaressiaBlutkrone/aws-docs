import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:go_router/go_router.dart';

import '../data/content_index.dart';
import '../data/history_store.dart';
import '../data/question_banks.dart';
import '../data/resume_exam.dart';
import '../data/study_progress.dart';
import '../data/viewed_docs_store.dart';
import '../data/weighted_exam.dart';
import '../data/wrong_answer_index.dart';
import '../models/certification.dart';
import '../models/exam_guide.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/resume_exam_card.dart';
import '../widgets/state_views.dart';
import 'cert_detail/cert_detail_bits.dart';
import 'cert_detail/cert_header_section.dart';
import 'cert_detail/learning_content_section.dart';
import 'cert_detail/official_guide_section.dart';
import 'cert_detail/summary_section.dart';

typedef _Loaded = ({
  ExamGuide? guide,
  ExamSummary? summary,
  Map<String, int> weakByTask,
  StudyProgress progress,
  int attemptCount,
});

/// 자격증 상세 — 섹션 위젯들은 `pages/cert_detail/`(PR4 분해), 이 파일은
/// 로더(_load)와 골격(헤더·스크롤·상태 분기)만 가진다.
class CertDetailPage extends StatefulWidget {
  const CertDetailPage({super.key, required this.cert, this.backend});

  final Certification cert;

  /// 진행 중 시험 세션 조회용 주입구(UX-4). 앱에서는 null이라 `defaultBackend()`를
  /// 쓴다. 테스트가 세션을 심어 "이어서 풀기" 카드 노출을 검증할 때만 주입한다
  /// (`CertExamPage.backend`와 같은 사정).
  final KvBackend? backend;

  @override
  State<CertDetailPage> createState() => _CertDetailPageState();
}

class _CertDetailPageState extends State<CertDetailPage> {
  Certification get cert => widget.cert;

  Future<_Loaded> _load() async {
    ExamGuide? guide;
    ExamSummary? summary;
    try {
      final raw = await rootBundle.loadString(
        'assets/exam_guides/${cert.code}.json',
      );
      guide = ExamGuide.fromJson(json.decode(raw) as Map<String, dynamic>);
    } catch (_) {}
    try {
      final raw = await rootBundle.loadString('assets/exam_summaries.json');
      final m = json.decode(raw) as Map<String, dynamic>;
      final entry = m[cert.code];
      if (entry is Map<String, dynamic>) summary = ExamSummary.fromJson(entry);
    } catch (_) {}

    // 오답노트 배지: 뱅크 로드 → taskByQuestionId → 약점 인덱스.
    // 로드는 공용 로더가 한다(문항 0 Task 생략 + 병렬 + 순서 보존 — 리뷰 M-4).
    final taskByQuestionId = <String, String>{};
    for (final l in await loadQuestionBanks(contentFor(cert.code))) {
      for (final q in l.bank.questions) {
        taskByQuestionId[q.id] = l.entry.taskId;
      }
    }
    final history = HistoryStore().all();
    final weakByTask = WrongAnswerIndex.build(
      certId: cert.code,
      history: history,
      taskByQuestionId: taskByQuestionId,
    ).weakByTask();

    final progress = StudyProgress.build(
      certId: cert.code,
      allTaskIds: [for (final e in contentFor(cert.code)) e.taskId],
      viewedTaskIds: ViewedDocsStore().viewed(cert.code),
      history: history,
    );

    final attemptCount = nonReviewAttemptCount(cert.code, history);

    return (
      guide: guide,
      summary: summary,
      weakByTask: weakByTask,
      progress: progress,
      attemptCount: attemptCount,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      backgroundColor: c.bg,
      extendBodyBehindAppBar: true, // 글래스 헤더 — 인벤토리 §5
      appBar: AppHeader.document(
        titleLeading: CodePill(cert.code),
        title: cert.title,
      ),
      body: SelectionArea(
        child: FutureBuilder<_Loaded>(
          // StatelessWidget 시절처럼 build마다 _load()를 호출한다 — 학습문서 열람·
          // 응시 후 이 페이지로 돌아올 때 진행률·오답 배지가 재계산되는 동작 보존.
          future: _load(),
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(
                  child: LoadingView(label: '자격증 정보를 불러오고 있습니다…'));
            }
            if (snap.hasError) {
              // fatal 승격(승인된 의도적 변경 ③): 이전엔 메타 없는 빈 화면으로
              // 침묵 렌더했다. guide/summary/개별 뱅크의 부가 실패(optional)는
              // _load() 안의 try/catch가 계속 흡수한다 — 여기 오는 건 그 밖의 실패.
              return Center(
                child: ErrorView(
                  message: '자격증 정보를 불러오지 못했습니다.',
                  onRetry: () => setState(() {}), // build가 _load()를 재호출
                  onHome: () => context.go('/'),
                ),
              );
            }
            final guide = snap.data?.guide;
            final summary = snap.data?.summary;
            return Scrollbar(
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        Gap.xl,
                        headerScrollInset(context),
                        Gap.xl,
                        Gap.xl4,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CertHeaderSection(cert: cert, guide: guide),
                          // 진행 중인 시험은 제일 위에 — 시계가 돌고 있다(UX-4).
                          ResumeExamSection(
                            exams: resumableExamsForCert(cert.code,
                                backend: widget.backend),
                            onOpen: (route) => context.push(route),
                          ),
                          if (summary != null) SummaryBlock(summary: summary),
                          if (contentFor(cert.code).isNotEmpty)
                            LearningContentSection(
                              entries: contentFor(cert.code),
                              weakByTask: snap.data?.weakByTask ?? const {},
                              progress: snap.data?.progress,
                              attemptCount: snap.data?.attemptCount ?? 0,
                            ),
                          if (guide != null)
                            OfficialGuideSection(guide: guide)
                          else
                            GuideMissing(cert: cert),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
