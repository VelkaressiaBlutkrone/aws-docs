import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:go_router/go_router.dart';

import '../content/markdown_parser.dart';
import '../content/study_markdown_view.dart';
import '../data/content_index.dart';
import '../data/viewed_docs_store.dart';
import '../models/exam_session.dart';
import '../models/study_content.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/badges.dart';
import '../widgets/focus_ring.dart';
import '../widgets/state_views.dart';

class StudyDocPage extends StatefulWidget {
  const StudyDocPage({super.key, required this.entry});
  final ContentEntry entry;

  @override
  State<StudyDocPage> createState() => _StudyDocPageState();
}

class _StudyDocPageState extends State<StudyDocPage> {
  late Future<StudyContent> _future; // 재할당은 에러 재시도에서만

  @override
  void initState() {
    super.initState();
    _future = _load();
    // 방문 = 열람. 부수효과만, 렌더와 분리.
    ViewedDocsStore().markViewed(widget.entry.certCode, widget.entry.taskId);
  }

  Future<StudyContent> _load() async {
    final raw = await rootBundle.loadString(widget.entry.mdAsset);
    return parseStudyDoc(raw);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    // FutureBuilder가 Scaffold를 감싼다(PR4) — 헤더의 검수 메타(✓ 검증됨·
    // 검수일)가 본문 로드 결과를 받아야 해서다. 로딩/에러 분기 표시는 기존과
    // 동일하게 body 안에서 일어난다.
    return FutureBuilder<StudyContent>(
      future: _future,
      builder: (context, snap) {
        final done = snap.connectionState == ConnectionState.done;
        final doc = done && !snap.hasError ? snap.data : null;
        return Scaffold(
          backgroundColor: c.bg,
          extendBodyBehindAppBar: true, // 글래스 헤더 — 인벤토리 §5
          appBar: AppHeader.document(
            backLabel: widget.entry.certCode,
            sectionLabel: '학습 문서',
            title: widget.entry.title,
            metaBadge: doc != null ? '✓ 검증됨' : null,
            metaDate: doc?.lastVerified,
          ),
          body: SelectionArea(
            child: Builder(
              builder: (context) {
                if (!done) {
                  return const Center(
                      child: LoadingView(label: '학습문서를 불러오고 있습니다…'));
                }
                if (doc == null) {
                  return Center(
                    child: ErrorView(
                      message: '콘텐츠를 불러오지 못했습니다.',
                      onRetry: () => setState(() => _future = _load()),
                      onHome: () => context.go('/'),
                    ),
                  );
                }
                return Scrollbar(
                  child: SingleChildScrollView(
                    child: Center(
                      child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(maxWidth: Layout.measure),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                              Gap.xl,
                              headerScrollInset(context),
                              Gap.xl,
                              Gap.xl4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _DocHeader(doc: doc),
                              StudyMarkdownView(blocks: doc.blocks),
                              const SizedBox(height: Gap.xl2),
                              _StartQuizButton(entry: widget.entry),
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
      },
    );
  }
}

/// 검수 메타 헤더(DESIGN.md 브랜드 규칙: ✓ 검증됨 + 검수일 + 출처).
class _DocHeader extends StatelessWidget {
  const _DocHeader({required this.doc});
  final StudyContent doc;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: Gap.sm,
          runSpacing: Gap.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            AppBadge(label: '✓ 검증됨', bg: c.correctWeak, fg: c.correct),
            _chip(
                context,
                doc.domainName != null
                    ? '도메인 ${doc.domain} · ${doc.domainName}'
                    : '도메인 ${doc.domain}'),
            if (doc.domainWeightPct != null)
              _chip(context, '${doc.domainWeightPct}%'),
            for (final tk in doc.coversTasks) _chip(context, 'Task $tk'),
            if (doc.lastVerified != null)
              _chip(context, '검수 ${doc.lastVerified}'),
            _chip(context, '출처 ${doc.sources.length}'),
          ],
        ),
        const SizedBox(height: Gap.md),
        Text(doc.title, style: t.headlineMedium),
        const SizedBox(height: Gap.sm),
        Text(
          '공식 AWS 출처로 대조한 검증 학습문서 · 출처는 문서 하단(📌) 참조.',
          style: t.bodyMedium,
        ),
        const SizedBox(height: Gap.lg),
        Divider(color: c.border, height: 1),
      ],
    );
  }

  Widget _chip(BuildContext context, String text) {
    final c = context.c;
    return AppBadge(
        label: text, bg: c.surface2, fg: c.textMuted, strong: false);
  }
}

class _StartQuizButton extends StatelessWidget {
  const _StartQuizButton({required this.entry});
  final ContentEntry entry;

  @override
  Widget build(BuildContext context) {
    if (entry.questionCount <= 0) return const SizedBox.shrink();
    // 시험 시간(라벨용 추정): CLF-C02 공식 페이스(90분 / 50채점+15비채점).
    // 실제 시간은 ExamPage가 cert 메타로 계산. 비-CLF 자격증 추가 시 per-cert 조회로 교체.
    final mins = (examDurationSec(
                durationMinutes: 90,
                scored: 50,
                unscored: 15,
                count: entry.questionCount) /
            60)
        .round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _cta(
          context,
          label: '연습 문제 풀기 (${entry.questionCount}문항)',
          filled: true,
          onTap: () => context.push(
              '/cert/${entry.certCode}/study/${entry.taskId}/quiz'),
        ),
        const SizedBox(height: Gap.sm),
        _cta(
          context,
          label: '시험처럼 풀기 (${entry.questionCount}문항 · ~$mins분)',
          filled: false,
          onTap: () => context.push(
              '/cert/${entry.certCode}/study/${entry.taskId}/exam'),
        ),
      ],
    );
  }

  Widget _cta(BuildContext context,
      {required String label,
      required bool filled,
      required VoidCallback onTap}) {
    final c = context.c;
    return InsetFocusRing(
      borderRadius: BorderRadius.circular(Radii.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.sm),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: filled ? c.accent : c.surface,
            borderRadius: BorderRadius.circular(Radii.sm),
            border: filled ? null : Border.all(color: c.accent, width: 1.5),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700, fontVariations: Wght.w700,
                  color: filled ? c.onAccent : c.accent)),
        ),
      ),
    );
  }
}
