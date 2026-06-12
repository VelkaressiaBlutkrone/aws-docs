import 'dart:ui' show FontFeature, ImageFilter;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/theme_scope.dart';
import 'focus_ring.dart';

/// 공용 헤더(PR4) — DESIGN.md Header 규약: 56px · sticky · blur(14px) ·
/// 88% 불투명 · 하단 1px border. 와이어프레임 정답지 2번 섹션.
///
/// 두 변형 중 **문서형**(‹뒤로[+라벨] + 브레드크럼 "섹션 라벨 / 제목" +
/// 우측 메타→페이지 액션→테마 토글)이 이 파일에 산다. 홈형은 홈 전용 구성
/// (브랜드+내비 앵커+설정)이라 `lib/pages/home/home_header.dart` —
/// 셸([AppHeaderShell])과 토글([ThemeToggleButton])만 공유한다(승격 규칙).
///
/// collapse 우선순위(좁아질 때): 검수 날짜 → '✓ 검증됨' 배지 → 섹션 라벨 →
/// 제목 ellipsis(최소 가시 12자) → 최후에 backLabel 텍스트(셰브론 유지).
/// 햄버거 도입 금지. 매핑·재량 결정:
/// docs/superpowers/specs/2026-06-13-pr4-appbar-inventory.md
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader.document({
    super.key,
    this.backLabel,
    this.sectionLabel,
    required this.title,
    this.titleLeading,
    this.metaBadge,
    this.metaDate,
    this.actions = const <Widget>[],
  });

  /// ‹ 셰브론 옆 맥락 라벨(예: 'CLF-C02'). back이 불가능한 스택 루트에선
  /// 셰브론과 함께 표시되지 않는다(AppBar의 automaticallyImplyLeading 동등).
  final String? backLabel;

  /// 브레드크럼 좌측(상위 맥락). null이면 제목만.
  final String? sectionLabel;

  /// 브레드크럼 우측(현재 페이지, w700·ellipsis).
  final String title;

  /// 제목 앞 위젯(cert_detail의 코드 필 등). collapse 계산엔 불참 —
  /// 제목 ellipsis가 흡수한다.
  final Widget? titleLeading;

  /// 우측 메타 배지 텍스트(예: '✓ 검증됨').
  final String? metaBadge;

  /// 우측 메타 날짜(예: '2026-05-27'). 배지 없이 날짜만 줄 수 없다
  /// (collapse 순서상 날짜가 먼저 떨어져야 하므로 배지에 종속).
  final String? metaDate;

  /// 페이지 액션(초기화 등). 토글은 자동으로 맨 끝에 붙는다.
  final List<Widget> actions;

  @override
  Size get preferredSize => const Size.fromHeight(AppHeaderShell.height);

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final canPop = Navigator.maybeOf(context)?.canPop() ?? false;

    final backStyle = TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600, fontVariations: Wght.w600,
        color: c.textMuted);
    final sectionStyle = TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500, fontVariations: Wght.w500,
        color: c.textMuted);
    final slashStyle = TextStyle(fontSize: 15, color: c.textFaint);
    final titleStyle = TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700, fontVariations: Wght.w700,
        color: c.text);
    final badgeStyle = TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600, fontVariations: Wght.w600,
        color: c.textMuted);
    final dateStyle = TextStyle(
        fontSize: 13,
        color: c.textFaint,
        fontFeatures: const [FontFeature.tabularFigures()]);

    return AppHeaderShell(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scaler = MediaQuery.textScalerOf(context);
          double textW(String s, TextStyle style) {
            final p = TextPainter(
              text: TextSpan(text: s, style: style),
              textDirection: TextDirection.ltr,
              textScaler: scaler,
              maxLines: 1,
            )..layout();
            final w = p.size.width;
            p.dispose();
            return w;
          }

          // 고정 폭: 셰브론 탭 영역 + 그룹 간 간격 + 액션·토글.
          // FocusRing(2+2px)·패딩 포함 보수치 — 실제보다 약간 크게 잡아
          // 드롭이 한 박자 일찍 일어나는 쪽이 오버플로보다 낫다.
          const buttonW = 44.0;
          var fixed = Gap.md * 2; // 좌·우 그룹 간격
          if (canPop) fixed += 36; // ‹ 셰브론
          fixed += (actions.length + 1) * (buttonW + Gap.sm); // 액션 + 토글
          if (metaBadge != null) fixed += Gap.md;

          // 제목 최소 가시 12자(스펙) — 그 폭이 나올 때까지 우선순위 드롭.
          final titleHead =
              title.length <= 12 ? title : '${title.substring(0, 12)}…';
          final collapse = HeaderCollapse.solve(
            available: constraints.maxWidth,
            fixed: fixed,
            backLabel: canPop && backLabel != null
                ? textW(backLabel!, backStyle) + Gap.xs
                : 0,
            section: sectionLabel != null
                ? textW(sectionLabel!, sectionStyle) +
                    textW(' / ', slashStyle)
                : 0,
            badge: metaBadge != null ? textW(metaBadge!, badgeStyle) : 0,
            date: metaDate != null
                ? textW(' · $metaDate', dateStyle)
                : 0,
            titleMin: textW(titleHead, titleStyle),
          );

          return Row(
            children: [
              if (canPop) ...[
                _BackButton(
                  label: collapse.showBackLabel ? backLabel : null,
                  labelStyle: backStyle,
                ),
                const SizedBox(width: Gap.sm),
              ],
              Expanded(
                child: Row(
                  children: [
                    if (titleLeading != null) ...[
                      titleLeading!,
                      const SizedBox(width: Gap.md),
                    ],
                    if (collapse.showSection) ...[
                      Text(sectionLabel!,
                          style: sectionStyle, maxLines: 1),
                      Text(' / ', style: slashStyle),
                    ],
                    Flexible(
                      child: Text(title,
                          style: titleStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Gap.md),
              if (collapse.showBadge) ...[
                Text.rich(
                  TextSpan(children: [
                    TextSpan(text: metaBadge, style: badgeStyle),
                    if (collapse.showDate)
                      TextSpan(text: ' · $metaDate', style: dateStyle),
                  ]),
                  maxLines: 1,
                ),
                const SizedBox(width: Gap.md),
              ],
              for (final action in actions) ...[
                action,
                const SizedBox(width: Gap.sm),
              ],
              const ThemeToggleButton(),
            ],
          );
        },
      ),
    );
  }
}

/// 글래스 헤더 페이지(extendBodyBehindAppBar)의 스크롤 상단 인셋.
/// Scaffold가 body MediaQuery padding.top에 헤더 높이를 실어 주므로
/// 그 값 + 기존 상단 여백을 돌려준다. **반드시 Scaffold body 아래
/// 컨텍스트로 호출할 것** — 페이지(State) 컨텍스트에선 0이 나온다.
/// 위젯 테스트(Scaffold 없이 단독 렌더)에선 0 + gap이라 기존과 동일.
double headerScrollInset(BuildContext context, {double gap = Gap.xl}) =>
    MediaQuery.paddingOf(context).top + gap;

/// collapse 드롭 판정(순수 함수, 테스트 대상) — 우선순위 고정:
/// 날짜 → 배지 → 섹션 라벨 → backLabel. 각 단계는 "제목 최소폭까지 포함해
/// 가용 폭에 들어가는가"로 판정한다. 폭 0인 파트는 처음부터 미표시.
@visibleForTesting
class HeaderCollapse {
  const HeaderCollapse._(
      this.showDate, this.showBadge, this.showSection, this.showBackLabel);

  final bool showDate;
  final bool showBadge;
  final bool showSection;
  final bool showBackLabel;

  static HeaderCollapse solve({
    required double available,
    required double fixed,
    required double backLabel,
    required double section,
    required double badge,
    required double date,
    required double titleMin,
  }) {
    var sDate = date > 0;
    var sBadge = badge > 0;
    var sSection = section > 0;
    var sBack = backLabel > 0;
    double need() =>
        fixed +
        (sBack ? backLabel : 0) +
        (sSection ? section : 0) +
        (sBadge ? badge : 0) +
        (sDate ? date : 0) +
        titleMin;
    if (need() > available && sDate) sDate = false;
    if (need() > available && sBadge) sBadge = false;
    if (need() > available && sSection) sSection = false;
    if (need() > available && sBack) sBack = false;
    return HeaderCollapse._(sDate, sBadge, sSection, sBack);
  }
}

/// 56px 헤더 셸 — blur(14)·bg 88%·하단 1px border·콘텐츠 폭 1180 정렬.
/// 글래스 효과는 페이지가 `extendBodyBehindAppBar: true`로 콘텐츠를
/// 헤더 밑으로 보낼 때 실재한다(인벤토리 §5 — plan 제외 전 페이지).
class AppHeaderShell extends StatelessWidget implements PreferredSizeWidget {
  const AppHeaderShell({super.key, required this.child});

  static const double height = 56;

  final Widget child;

  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Material(
          color: c.bg.withValues(alpha: 0.88),
          child: Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: c.border)),
            ),
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: height,
                child: Center(
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(maxWidth: Layout.content),
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: Gap.xl),
                      child: child,
                    ),
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

class _BackButton extends StatelessWidget {
  const _BackButton({required this.label, required this.labelStyle});

  final String? label;
  final TextStyle labelStyle;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return FocusRing(
      borderRadius: BorderRadius.circular(Radii.sm + 4),
      child: Tooltip(
        message: '뒤로',
        child: InkWell(
          onTap: () => Navigator.maybePop(context),
          borderRadius: BorderRadius.circular(Radii.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chevron_left, size: 22, color: c.textMuted),
                if (label != null) ...[
                  const SizedBox(width: 2),
                  Text(label!, style: labelStyle, maxLines: 1),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 테마 토글 — [ThemeScope] 셀프서비스라 페이지 배선이 필요 없다.
/// 액션 슬롯 규약상 항상 헤더 맨 끝(홈형·문서형 공통).
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = ThemeScope.of(context);
    return HeaderIconButton(
      tooltip: scope.isDark ? '라이트 모드' : '다크 모드',
      icon: scope.isDark
          ? Icons.light_mode_outlined
          : Icons.dark_mode_outlined,
      onTap: scope.toggle,
    );
  }
}

/// 헤더 우측 원형 아이콘 버튼(surface2+border+muted 아이콘) — 토글·설정·
/// 메뉴·초기화가 공유하는 어휘. 파괴적 액션도 muted 유지(상시 wrong 금지),
/// 확인은 다이얼로그가 담당한다.
class HeaderIconButton extends StatelessWidget {
  const HeaderIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return FocusRing(
      borderRadius: BorderRadius.circular(Radii.full),
      child: Tooltip(
        message: tooltip,
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
            child: Icon(icon, size: 18, color: c.textMuted),
          ),
        ),
      ),
    );
  }
}
