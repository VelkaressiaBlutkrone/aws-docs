import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../data/content_index.dart';
import '../models/certification.dart';
import '../models/exam_guide.dart';
import '../theme/app_theme.dart';
import 'study_doc_page.dart';

typedef _Loaded = ({ExamGuide? guide, ExamSummary? summary});

class CertDetailPage extends StatelessWidget {
  const CertDetailPage({super.key, required this.cert});

  final Certification cert;

  Future<_Loaded> _load() async {
    ExamGuide? guide;
    ExamSummary? summary;
    try {
      final raw = await rootBundle.loadString('assets/exam_guides/${cert.code}.json');
      guide = ExamGuide.fromJson(json.decode(raw) as Map<String, dynamic>);
    } catch (_) {}
    try {
      final raw = await rootBundle.loadString('assets/exam_summaries.json');
      final m = json.decode(raw) as Map<String, dynamic>;
      final entry = m[cert.code];
      if (entry is Map<String, dynamic>) summary = ExamSummary.fromJson(entry);
    } catch (_) {}
    return (guide: guide, summary: summary);
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CodePill(cert.code),
            const SizedBox(width: Gap.md),
            Flexible(
              child: Text(cert.title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
      body: SelectionArea(
        child: FutureBuilder<_Loaded>(
          future: _load(),
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final guide = snap.data?.guide;
            final summary = snap.data?.summary;
            return Scrollbar(
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(Gap.xl, Gap.xl, Gap.xl, Gap.xl4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Header(cert: cert, guide: guide),
                          if (summary != null) _SummaryBlock(summary: summary),
                          if (contentFor(cert.code).isNotEmpty)
                            _LearningContent(entries: contentFor(cert.code)),
                          if (guide != null)
                            _OfficialGuide(guide: guide)
                          else
                            _GuideMissing(cert: cert),
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

class _Header extends StatelessWidget {
  const _Header({required this.cert, required this.guide});
  final Certification cert;
  final ExamGuide? guide;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    final o = guide?.overview;
    final facts = <String>[
      if (o?.passingScore != null) '합격 ${o!.passingScore}/1000',
      if (o?.scoredQuestions != null)
        '채점 ${o!.scoredQuestions}문항${o.unscoredQuestions != null ? ' (+비채점 ${o.unscoredQuestions})' : ''}',
      if (o?.durationMinutes != null) '${o!.durationMinutes}분',
      if (guide != null) '도메인 ${guide!.domains.length} · Task ${guide!.taskCount}',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(cert.level.short,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: c.accent)),
        const SizedBox(height: Gap.sm),
        Text(cert.title, style: t.headlineMedium),
        const SizedBox(height: Gap.sm),
        Text(cert.audience, style: t.bodyMedium),
        if (facts.isNotEmpty) ...[
          const SizedBox(height: Gap.lg),
          Wrap(
            spacing: Gap.sm,
            runSpacing: Gap.sm,
            children: [for (final f in facts) _FactPill(f)],
          ),
        ],
        const SizedBox(height: Gap.xl2),
      ],
    );
  }
}

/// 검증된 학습 콘텐츠(학습문서 + 연습 문제) 진입 섹션.
class _LearningContent extends StatelessWidget {
  const _LearningContent({required this.entries});
  final List<ContentEntry> entries;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: Gap.xl2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.menu_book_outlined, size: 18, color: c.accent),
            const SizedBox(width: 8),
            Text('학습 콘텐츠 · 검증 문항', style: t.headlineSmall),
          ]),
          const SizedBox(height: 4),
          Text('AWS 공식 출처로 검증한 한국어 학습문서와 연습 문제.',
              style: t.bodyMedium),
          const SizedBox(height: Gap.lg),
          for (final e in entries)
            Padding(
              padding: const EdgeInsets.only(bottom: Gap.md),
              child: InkWell(
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => StudyDocPage(entry: e))),
                borderRadius: BorderRadius.circular(Radii.md),
                child: Container(
                  padding: const EdgeInsets.all(Gap.lg),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(Radii.md),
                    border: Border.all(color: c.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Task ${e.taskId.replaceAll('clf-t', '').replaceAll('-', '.')} · ${e.title}',
                                style: t.titleMedium),
                            const SizedBox(height: Gap.xs),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                  color: c.correctWeak,
                                  borderRadius:
                                      BorderRadius.circular(Radii.full)),
                              child: Text('검증 문항 ${e.questionCount}',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: c.correct)),
                            ),
                          ],
                        ),
                      ),
                      Text('학습문서 →',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: c.accent)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Drive Korean summary — clearly separated from the verbatim official guide.
class _SummaryBlock extends StatelessWidget {
  const _SummaryBlock({required this.summary});
  final ExamSummary summary;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: Gap.xl2),
      padding: const EdgeInsets.all(Gap.xl),
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.translate, size: 16, color: c.accent),
            const SizedBox(width: 6),
            Text('한국어 학습 요약본',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                    color: c.accent)),
          ]),
          const SizedBox(height: Gap.md),
          Text(summary.purpose, style: t.bodyLarge?.copyWith(fontSize: 16)),
          const SizedBox(height: Gap.sm),
          Text(summary.audience, style: t.bodyMedium),
          const SizedBox(height: Gap.lg),
          _MiniList(label: '우선 학습 포인트', items: summary.priorityPoints),
          const SizedBox(height: Gap.md),
          _MiniList(label: '시험 범위가 아닌 항목', items: summary.outOfScope),
          const SizedBox(height: Gap.md),
          _MiniList(label: '활용 방법', items: ExamSummary.howToUse),
          const SizedBox(height: Gap.md),
          Text('비공식 학습 요약본 · 최신 세부 항목은 공식 안내서를 확인하세요.',
              style: TextStyle(fontSize: 12, color: c.textFaint)),
        ],
      ),
    );
  }
}

class _MiniList extends StatelessWidget {
  const _MiniList({required this.label, required this.items});
  final String label;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: c.textMuted)),
        const SizedBox(height: 6),
        for (final it in items) _Bullet(it, color: c.accent),
      ],
    );
  }
}

/// Verbatim official exam guide content.
class _OfficialGuide extends StatelessWidget {
  const _OfficialGuide({required this.guide});
  final ExamGuide guide;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(Icons.verified_outlined, size: 18, color: c.text),
          const SizedBox(width: 8),
          Text('공식 시험 가이드', style: t.headlineSmall),
        ]),
        const SizedBox(height: 4),
        Text('AWS 공식 Exam Guide의 도메인·과제·세부 항목 (한국어).',
            style: t.bodyMedium),
        const SizedBox(height: Gap.xl),
        for (final d in guide.domains) _DomainCard(domain: d),
        const SizedBox(height: Gap.lg),
        Text('출처: ${guide.sourceUrl}',
            style: TextStyle(fontSize: 11, color: c.textFaint, fontFamily: AppTheme.monoFamily)),
      ],
    );
  }
}

class _DomainCard extends StatelessWidget {
  const _DomainCard({required this.domain});
  final ExamDomain domain;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: Gap.lg),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: c.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: domain.no == 1,
          tilePadding: const EdgeInsets.symmetric(horizontal: Gap.xl, vertical: Gap.xs),
          childrenPadding: const EdgeInsets.fromLTRB(Gap.xl, 0, Gap.xl, Gap.lg),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          title: Row(
            children: [
              Expanded(
                child: Text('도메인 ${domain.no}. ${domain.name}',
                    style: t.titleMedium),
              ),
              const SizedBox(width: Gap.sm),
              _WeightPill(domain.weightPct),
            ],
          ),
          children: [
            for (final task in domain.tasks) _TaskBlock(task: task),
          ],
        ),
      ),
    );
  }
}

class _TaskBlock extends StatelessWidget {
  const _TaskBlock({required this.task});
  final ExamTask task;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(top: Gap.md),
      padding: const EdgeInsets.all(Gap.lg),
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: BorderRadius.circular(Radii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Task ${task.no}',
                  style: TextStyle(
                      fontFamily: AppTheme.monoFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: c.accent)),
              const SizedBox(width: Gap.sm),
              Expanded(
                child: Text(task.title, style: t.titleMedium?.copyWith(fontSize: 15)),
              ),
            ],
          ),
          if (task.knowledge.isNotEmpty) ...[
            const SizedBox(height: Gap.md),
            _SubLabel('지식'),
            for (final k in task.knowledge) _Bullet(k, color: c.info),
          ],
          if (task.skills.isNotEmpty) ...[
            const SizedBox(height: Gap.md),
            _SubLabel(task.knowledge.isEmpty ? '세부 항목' : '기술'),
            for (final s in task.skills) _Bullet(s, color: c.accent),
          ],
        ],
      ),
    );
  }
}

class _GuideMissing extends StatelessWidget {
  const _GuideMissing({required this.cert});
  final Certification cert;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Gap.xl),
      decoration: BoxDecoration(
        color: c.warningWeak,
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: c.warning.withValues(alpha: 0.35)),
      ),
      child: Text('이 자격증의 공식 가이드 본문은 아직 준비 중입니다.',
          style: TextStyle(color: c.text)),
    );
  }
}

// ── small shared widgets ──

class _Bullet extends StatelessWidget {
  const _Bullet(this.text, {required this.color});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8, right: 10),
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          Expanded(
            child: Text(text,
                style: TextStyle(fontSize: 14, height: 1.6, color: c.text)),
          ),
        ],
      ),
    );
  }
}

class _SubLabel extends StatelessWidget {
  const _SubLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Text(text,
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: c.textFaint));
  }
}

class _CodePill extends StatelessWidget {
  const _CodePill(this.code);
  final String code;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: c.surface2, borderRadius: BorderRadius.circular(Radii.full)),
      child: Text(code,
          style: TextStyle(
              fontFamily: AppTheme.monoFamily,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: c.textMuted)),
    );
  }
}

class _WeightPill extends StatelessWidget {
  const _WeightPill(this.pct);
  final int pct;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: c.accentWeak, borderRadius: BorderRadius.circular(Radii.full)),
      child: Text('$pct%',
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w800, color: c.accentStrong)),
    );
  }
}

class _FactPill extends StatelessWidget {
  const _FactPill(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(Radii.full),
        border: Border.all(color: c.borderStrong),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700, color: c.textMuted)),
    );
  }
}
