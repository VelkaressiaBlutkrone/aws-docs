import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/focus_ring.dart';

/// 홈 섹션들이 공유하는 빌딩블록(PR4 분해 — home_page.dart에서 이동).
/// 홈 전용이라 lib/widgets/ 승격 대상이 아니다(승격 규칙: 2+ 페이지).

/// 섹션 밴드 — 상단 헤어라인 + 제목/메타 행.
class HomeBand extends StatelessWidget {
  const HomeBand(
      {super.key, required this.title, required this.meta, required this.child});
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
                      fontWeight: FontWeight.w600, fontVariations: Wght.w600,
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

class HomeEyebrow extends StatelessWidget {
  const HomeEyebrow(this.text, {super.key});
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
              fontSize: 12, fontWeight: FontWeight.w700, fontVariations: Wght.w700, color: c.textMuted)),
    );
  }
}

enum PillTone { level, code }

class HomePill extends StatelessWidget {
  const HomePill({super.key, required this.label, required this.tone});
  final String label;
  final PillTone tone;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    late final Color bg;
    late final Color fg;
    switch (tone) {
      case PillTone.level:
        bg = c.infoWeak;
        fg = c.info;
      case PillTone.code:
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
            fontWeight: FontWeight.w700, fontVariations: Wght.w700,
            color: fg,
            fontFamily: tone == PillTone.code ? AppTheme.monoFamily : null,
          )),
    );
  }
}

class HomeChip extends StatelessWidget {
  const HomeChip({super.key, required this.label});
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
              fontSize: 12, fontWeight: FontWeight.w600, fontVariations: Wght.w600, color: c.textMuted)),
    );
  }
}

class HomeLinkText extends StatelessWidget {
  const HomeLinkText({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Text(label,
        style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w700, fontVariations: Wght.w700, color: c.accent));
  }
}

class HomeButton extends StatelessWidget {
  const HomeButton(
      {super.key, required this.label, required this.primary, this.onTap});
  final String label;
  final bool primary;

  /// 탭·Enter·Space 동작. null이면 장식(과거 무동작 상태) — CODE-P-001로
  /// 히어로 CTA에 실제 배선을 붙였다(home_hero_cta_test 회귀 가드).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final body = Container(
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
              fontWeight: FontWeight.w700, fontVariations: Wght.w700,
              color: primary ? c.onAccent : c.text)),
    );
    if (onTap == null) return body;
    return FocusTap(onTap: onTap, radius: Radii.sm, child: body);
  }
}
