import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/site_data.dart';
import '../models/certification.dart';
import '../theme/app_theme.dart';
import '../theme/theme_scope.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scroll = ScrollController();
  final _levels = GlobalKey();
  final _paths = GlobalKey();
  final _roadmaps = GlobalKey();
  final _docs = GlobalKey();
  final _exams = GlobalKey();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _goto(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      alignment: 0.02,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      backgroundColor: c.bg,
      appBar: _Header(
        isDark: ThemeScope.of(context).isDark,
        onToggleTheme: ThemeScope.of(context).toggle,
        onNav: {
          '단계': () => _goto(_levels),
          '추천 순서': () => _goto(_paths),
          '로드맵': () => _goto(_roadmaps),
          '학습 문서': () => _goto(_docs),
          '모의고사': () => _goto(_exams),
        },
      ),
      body: SelectionArea(
        child: Scrollbar(
          controller: _scroll,
          child: SingleChildScrollView(
            controller: _scroll,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: Layout.content),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      Gap.xl, 0, Gap.xl, Gap.xl4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Hero(),
                      const _Sources(),
                      _LevelsSection(key: _levels),
                      _PathsSection(key: _paths),
                      _RoadmapSection(key: _roadmaps),
                      _StudyDocsSection(key: _docs),
                      _ExamsSection(key: _exams),
                      const _Footer(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────── Header

class _Header extends StatelessWidget implements PreferredSizeWidget {
  const _Header({
    required this.isDark,
    required this.onToggleTheme,
    required this.onNav,
  });

  final bool isDark;
  final VoidCallback onToggleTheme;
  final Map<String, VoidCallback> onNav;

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Material(
      color: c.bg.withValues(alpha: 0.9),
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: c.border)),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Layout.content),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Gap.xl, vertical: Gap.md),
              child: Row(
                children: [
                  const _Brand(),
                  const Spacer(),
                  ...onNav.entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(left: Gap.lg),
                      child: _NavLink(label: e.key, onTap: e.value),
                    ),
                  ),
                  const SizedBox(width: Gap.lg),
                  _ThemeToggle(isDark: isDark, onTap: onToggleTheme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: c.accent,
            borderRadius: BorderRadius.circular(7),
          ),
          alignment: Alignment.center,
          child: Text('A',
              style: TextStyle(
                  color: c.onAccent,
                  fontWeight: FontWeight.w800,
                  fontSize: 14)),
        ),
        const SizedBox(width: Gap.sm),
        Text('AWS Docs Roadmap',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                letterSpacing: -0.4,
                color: c.text)),
      ],
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Radii.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Text(label,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: c.textMuted)),
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle({required this.isDark, required this.onTap});
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Tooltip(
      message: isDark ? '라이트 모드' : '다크 모드',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.full),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: c.surface2,
            borderRadius: BorderRadius.circular(Radii.full),
            border: Border.all(color: c.border),
          ),
          child: Icon(
            isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            size: 18,
            color: c.textMuted,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────── Hero

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: Gap.xl4, bottom: Gap.xl3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Eyebrow('AWS 공식 시험 가이드 기준'),
          const SizedBox(height: Gap.lg),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Text.rich(
              TextSpan(children: [
                const TextSpan(text: '클라우드 자격증,\n'),
                TextSpan(text: '이해', style: TextStyle(color: c.accent)),
                const TextSpan(text: '하고 통과하기'),
              ]),
              style: t.displayLarge,
            ),
          ),
          const SizedBox(height: Gap.lg),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Text(
              '입문부터 전문 분야까지 자격증 단계, 추천 순서, 상세 학습 문서, 모의고사를 한국어로 한 곳에서. '
              '덤프 암기가 아니라 "왜"를 가르치는 이해 중심 학습 사이트입니다.',
              style: t.bodyLarge?.copyWith(color: c.textMuted, fontSize: 19),
            ),
          ),
          const SizedBox(height: Gap.xl),
          Wrap(
            spacing: Gap.md,
            runSpacing: Gap.md,
            children: const [
              _Button(label: '추천 순서 보기', primary: true),
              _Button(label: '모의고사 구성', primary: false),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────── Sources

class _Sources extends StatelessWidget {
  const _Sources();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.xl2),
      child: Wrap(
        spacing: Gap.sm,
        runSpacing: Gap.sm,
        children: [
          for (final s in officialSources) _SourcePill(label: s.title),
        ],
      ),
    );
  }
}

class _SourcePill extends StatelessWidget {
  const _SourcePill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(Radii.sm),
        border: Border.all(color: c.border),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700, color: c.textMuted)),
    );
  }
}

// ─────────────────────────────────────────────────────────── Levels

class _LevelsSection extends StatelessWidget {
  const _LevelsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final level in certificationLevels)
          _Band(
            title: level.heading,
            meta:
                '${certifications.where((cert) => cert.level == level).length}개 자격증',
            child: Wrap(
              spacing: Gap.lg,
              runSpacing: Gap.lg,
              children: [
                for (final cert
                    in certifications.where((cert) => cert.level == level))
                  _CertCard(cert: cert),
              ],
            ),
          ),
      ],
    );
  }
}

class _CertCard extends StatelessWidget {
  const _CertCard({required this.cert});
  final Certification cert;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    return InkWell(
      onTap: () => context.push('/cert/${cert.code}'),
      borderRadius: BorderRadius.circular(Radii.md),
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(Gap.lg),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(color: c.border),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Pill(label: cert.level.short, tone: _Tone.level),
              const SizedBox(width: Gap.sm),
              _Pill(label: cert.code, tone: _Tone.code),
            ],
          ),
          const SizedBox(height: Gap.md),
          Text(cert.title, style: t.titleMedium),
          const SizedBox(height: Gap.xs),
          Text(cert.audience, style: t.bodyMedium),
          const SizedBox(height: Gap.md),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [for (final f in cert.focus) _Chip(label: f)],
          ),
          const SizedBox(height: Gap.md),
          _LinkText(label: '공식 가이드 보기 →'),
        ],
      ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────── Paths

class _PathsSection extends StatelessWidget {
  const _PathsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    return _Band(
      title: '추천 순서',
      meta: '목표별 기본 경로',
      child: Wrap(
        spacing: Gap.lg,
        runSpacing: Gap.lg,
        children: [
          for (final p in recommendedPaths)
            Container(
              width: 360,
              padding: const EdgeInsets.all(Gap.lg),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(Radii.md),
                border: Border.all(color: c.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.title, style: t.titleMedium),
                  const SizedBox(height: Gap.sm),
                  Text(p.steps.join('  →  '),
                      style: t.bodyMedium?.copyWith(
                          fontFeatures: const [], color: c.textMuted)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────── Roadmaps

class _RoadmapSection extends StatelessWidget {
  const _RoadmapSection({super.key});

  @override
  Widget build(BuildContext context) {
    return _Band(
      title: '자격증별 학습 로드맵',
      meta: '${certifications.length}개 로드맵',
      child: Column(
        children: [
          for (final cert in certifications)
            Padding(
              padding: const EdgeInsets.only(bottom: Gap.lg),
              child: _RoadmapCard(cert: cert),
            ),
        ],
      ),
    );
  }
}

class _RoadmapCard extends StatelessWidget {
  const _RoadmapCard({required this.cert});
  final Certification cert;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Gap.xl),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Pill(label: cert.code, tone: _Tone.code),
          const SizedBox(height: Gap.sm),
          Text(cert.title, style: t.titleLarge),
          const SizedBox(height: Gap.xs),
          Text(cert.audience, style: t.bodyMedium),
          const SizedBox(height: Gap.lg),
          for (var i = 0; i < cert.roadmap.length; i++)
            _Step(index: i + 1, text: cert.roadmap[i]),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.index, required this.text});
  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: c.accentWeak,
              borderRadius: BorderRadius.circular(Radii.full),
              border: Border.all(color: c.accent.withValues(alpha: 0.4)),
            ),
            alignment: Alignment.center,
            child: Text('$index',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: c.accentStrong)),
          ),
          const SizedBox(width: Gap.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text(text,
                  style: t.bodyLarge?.copyWith(fontSize: 15, height: 1.5)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────── Study docs

class _StudyDocsSection extends StatelessWidget {
  const _StudyDocsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return _Band(
      title: '상세 학습 문서',
      meta: '문서 단위 학습 목표',
      child: Wrap(
        spacing: Gap.lg,
        runSpacing: Gap.lg,
        children: [
          for (final cert in certifications)
            Container(
              width: 380,
              padding: const EdgeInsets.all(Gap.lg),
              decoration: BoxDecoration(
                color: context.c.surface,
                borderRadius: BorderRadius.circular(Radii.md),
                border: Border.all(color: context.c.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cert.title,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: Gap.md),
                  for (final doc in cert.studyDocs) _DocItem(doc: doc),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DocItem extends StatelessWidget {
  const _DocItem({required this.doc});
  final StudyDoc doc;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: Gap.md),
      padding: const EdgeInsets.all(Gap.md),
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(doc.title, style: t.labelLarge),
          const SizedBox(height: Gap.xs),
          Text(doc.outcome, style: t.bodyMedium),
          const SizedBox(height: Gap.sm),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [for (final topic in doc.topics) _Chip(label: topic)],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────── Exams

class _ExamsSection extends StatelessWidget {
  const _ExamsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return _Band(
      title: '학습 문서 기반 모의고사',
      meta: '자격증별 6회차 구성',
      child: Column(
        children: [
          for (final cert in certifications)
            Padding(
              padding: const EdgeInsets.only(bottom: Gap.lg),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Gap.lg),
                decoration: BoxDecoration(
                  color: context.c.surface,
                  borderRadius: BorderRadius.circular(Radii.md),
                  border: Border.all(color: context.c.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cert.title,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: Gap.md),
                    Wrap(
                      spacing: Gap.sm,
                      runSpacing: Gap.sm,
                      children: [
                        for (final exam in cert.exams)
                          _Pill(
                              label: exam.title.split(' ').last,
                              tone: _Tone.soon),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────── Footer

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: Gap.xl3),
      padding: const EdgeInsets.only(top: Gap.xl),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: Text(
        '비공식 학습 사이트 · 응시 전 반드시 AWS 공식 시험 가이드를 단일 진실 공급원으로 확인하세요.',
        style: TextStyle(fontSize: 13, color: c.textFaint),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────── Shared

class _Band extends StatelessWidget {
  const _Band({required this.title, required this.meta, required this.child});
  final String title;
  final String meta;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: Gap.xl2),
      padding: const EdgeInsets.only(top: Gap.xl2),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: Text(title, style: t.headlineSmall)),
              Text(meta,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: c.textFaint)),
            ],
          ),
          const SizedBox(height: Gap.xl),
          child,
        ],
      ),
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(Radii.full),
        border: Border.all(color: c.borderStrong),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: c.textMuted)),
    );
  }
}

enum _Tone { level, code, soon }

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.tone});
  final String label;
  final _Tone tone;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    late final Color bg;
    late final Color fg;
    switch (tone) {
      case _Tone.level:
        bg = c.infoWeak;
        fg = c.info;
      case _Tone.code:
        bg = c.surface2;
        fg = c.textMuted;
      case _Tone.soon:
        bg = c.surface2;
        fg = c.textMuted;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(Radii.full),
      ),
      child: Text(label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: fg,
            fontFamily: tone == _Tone.code ? AppTheme.monoFamily : null,
          )),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(Radii.full),
        border: Border.all(color: c.border),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: c.textMuted)),
    );
  }
}

class _LinkText extends StatelessWidget {
  const _LinkText({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Text(label,
        style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w700, color: c.accent));
  }
}

class _Button extends StatelessWidget {
  const _Button({required this.label, required this.primary});
  final String label;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: Gap.lg),
      decoration: BoxDecoration(
        color: primary ? c.accent : c.surface,
        borderRadius: BorderRadius.circular(Radii.sm),
        border: Border.all(color: primary ? c.accent : c.borderStrong),
      ),
      alignment: Alignment.center,
      child: Text(label,
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: primary ? c.onAccent : c.text)),
    );
  }
}
