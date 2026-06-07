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

class StudyDocPage extends StatefulWidget {
  const StudyDocPage({super.key, required this.entry});
  final ContentEntry entry;

  @override
  State<StudyDocPage> createState() => _StudyDocPageState();
}

class _StudyDocPageState extends State<StudyDocPage> {
  late final Future<StudyContent> _future;

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
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: Border(bottom: BorderSide(color: c.border)),
        title: Text(widget.entry.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      body: SelectionArea(
        child: FutureBuilder<StudyContent>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final doc = snap.data;
            if (doc == null) {
              return Center(
                  child: Text('콘텐츠를 불러오지 못했습니다.',
                      style: TextStyle(color: c.textMuted)));
            }
            return Scrollbar(
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: Layout.measure),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                          Gap.xl, Gap.xl, Gap.xl, Gap.xl4),
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
            _badge(c.correctWeak, c.correct, '✓ 검증됨'),
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

  Widget _badge(Color bg, Color fg, String text) => Builder(
        builder: (_) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
              color: bg, borderRadius: BorderRadius.circular(Radii.full)),
          child: Text(text,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w800, color: fg)),
        ),
      );

  Widget _chip(BuildContext context, String text) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: BorderRadius.circular(Radii.full),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: c.textMuted)),
    );
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
    return InkWell(
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
                fontWeight: FontWeight.w700,
                color: filled ? c.onAccent : c.accent)),
      ),
    );
  }
}
