import 'package:flutter/material.dart';

import '../../data/site_data.dart';
import '../../theme/app_theme.dart';
import '../../util/open_link.dart';
import '../../widgets/focus_ring.dart';
import 'home_bits.dart';

/// 히어로 + 공식 출처 스트립(PR4 분해 — home_page.dart에서 이동).

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: Gap.xl4, bottom: Gap.xl3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HomeEyebrow('AWS 공식 시험 가이드 기준'),
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
            constraints: const BoxConstraints(maxWidth: 760),
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
              HomeButton(label: '추천 순서 보기', primary: true),
              HomeButton(label: '모의고사 구성', primary: false),
            ],
          ),
        ],
      ),
    );
  }
}

class SourcesRow extends StatelessWidget {
  const SourcesRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.xl2),
      child: Wrap(
        spacing: Gap.sm,
        runSpacing: Gap.sm,
        children: [
          for (final s in officialSources)
            _SourcePill(label: s.title, href: s.href),
        ],
      ),
    );
  }
}

class _SourcePill extends StatefulWidget {
  const _SourcePill({required this.label, required this.href});
  final String label;
  final String href;

  @override
  State<_SourcePill> createState() => _SourcePillState();
}

class _SourcePillState extends State<_SourcePill> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final active = _hover;
    // GestureDetector → InkWell(DT4): 이전엔 키보드로 닿을 수도, Enter로 열
    // 수도 없었다. 호버 강조는 보존, 포커스는 인셋 링.
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Semantics(
        link: true,
        label: '${widget.label} (공식 자료, 새 탭으로 열기)',
        child: InsetFocusRing(
          borderRadius: BorderRadius.circular(Radii.sm),
          child: InkWell(
            onTap: () => openLink(widget.href),
            borderRadius: BorderRadius.circular(Radii.sm),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(Radii.sm),
                border: Border.all(color: active ? c.accent : c.border),
              ),
              child: Text(widget.label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700, fontVariations: Wght.w700,
                      color: active ? c.accent : c.textMuted)),
            ),
          ),
        ),
      ),
    );
  }
}
