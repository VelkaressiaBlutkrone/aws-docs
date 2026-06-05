import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../content/markdown_parser.dart';
import '../content/study_markdown_view.dart';
import '../data/content_index.dart';
import '../models/study_content.dart';
import '../theme/app_theme.dart';
import 'quiz_page.dart';

class StudyDocPage extends StatelessWidget {
  const StudyDocPage({super.key, required this.entry});
  final ContentEntry entry;

  Future<StudyContent> _load() async {
    final raw = await rootBundle.loadString(entry.mdAsset);
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
        title: Text(entry.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      body: SelectionArea(
        child: FutureBuilder<StudyContent>(
          future: _load(),
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
                          _StartQuizButton(entry: entry),
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
    final c = context.c;
    if (entry.questionCount <= 0) return const SizedBox.shrink();
    return InkWell(
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => QuizPage(entry: entry))),
      borderRadius: BorderRadius.circular(Radii.sm),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: Gap.xl),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: c.accent,
          borderRadius: BorderRadius.circular(Radii.sm),
        ),
        child: Text('연습 문제 풀기 (${entry.questionCount}문항)',
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w700, color: c.onAccent)),
      ),
    );
  }
}
