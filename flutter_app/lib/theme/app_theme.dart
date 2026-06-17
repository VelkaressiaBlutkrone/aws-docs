import 'package:flutter/material.dart';

/// Design system tokens — "조용한 레퍼런스"
/// Source of truth: aws-docs/DESIGN.md (verified teal accent, light default + dark).
/// Custom tokens that don't fit Material's ColorScheme live in [AppColors].
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.border,
    required this.borderStrong,
    required this.text,
    required this.textMuted,
    required this.textFaint,
    required this.ink,
    required this.onInk,
    required this.accent,
    required this.accentStrong,
    required this.accentWeak,
    required this.onAccent,
    required this.correct,
    required this.correctWeak,
    required this.wrong,
    required this.wrongWeak,
    required this.info,
    required this.infoWeak,
    required this.warning,
    required this.warningWeak,
  });

  final Color bg;
  final Color surface;
  final Color surface2;
  final Color border;
  final Color borderStrong;
  final Color text;
  final Color textMuted;
  final Color textFaint;
  final Color ink;
  final Color onInk;
  final Color accent;
  final Color accentStrong;
  final Color accentWeak;
  final Color onAccent;
  final Color correct;
  final Color correctWeak;
  final Color wrong;
  final Color wrongWeak;
  final Color info;
  final Color infoWeak;
  final Color warning;
  final Color warningWeak;

  static const light = AppColors(
    bg: Color(0xFFFBFAF8),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFF3F1EC),
    border: Color(0xFFE7E4DD),
    borderStrong: Color(0xFFD6D1C7),
    text: Color(0xFF1B2430),
    textMuted: Color(0xFF5C6573),
    textFaint: Color(0xFF8A93A0),
    ink: Color(0xFF1B2430),
    onInk: Color(0xFFEFEDE7),
    accent: Color(0xFF0E8175),
    accentStrong: Color(0xFF0B6B61),
    accentWeak: Color(0xFFE0F2EF),
    onAccent: Color(0xFFFFFFFF),
    correct: Color(0xFF1F8A52),
    correctWeak: Color(0xFFE5F4EA),
    wrong: Color(0xFFC0392B),
    wrongWeak: Color(0xFFFBEAE7),
    info: Color(0xFF2563B0),
    infoWeak: Color(0xFFE8EFF8),
    warning: Color(0xFFB7791F),
    warningWeak: Color(0xFFF8EFDD),
  );

  static const dark = AppColors(
    bg: Color(0xFF14181F),
    surface: Color(0xFF1B212B),
    surface2: Color(0xFF222A36),
    border: Color(0xFF2A323F),
    borderStrong: Color(0xFF3A4350),
    text: Color(0xFFE8EAED),
    textMuted: Color(0xFF9AA4B2),
    textFaint: Color(0xFF6B7585),
    ink: Color(0xFF0F131A),
    onInk: Color(0xFFE8EAED),
    accent: Color(0xFF3FB8AA),
    accentStrong: Color(0xFF5ECABD),
    accentWeak: Color(0xFF13302D),
    onAccent: Color(0xFF14181F),
    correct: Color(0xFF3DBB78),
    correctWeak: Color(0xFF15281D),
    wrong: Color(0xFFE06A5C),
    wrongWeak: Color(0xFF2E1816),
    info: Color(0xFF5B9BE0),
    infoWeak: Color(0xFF15212E),
    warning: Color(0xFFD9A441),
    warningWeak: Color(0xFF2A2113),
  );

  @override
  AppColors copyWith({
    Color? bg,
    Color? surface,
    Color? surface2,
    Color? border,
    Color? borderStrong,
    Color? text,
    Color? textMuted,
    Color? textFaint,
    Color? ink,
    Color? onInk,
    Color? accent,
    Color? accentStrong,
    Color? accentWeak,
    Color? onAccent,
    Color? correct,
    Color? correctWeak,
    Color? wrong,
    Color? wrongWeak,
    Color? info,
    Color? infoWeak,
    Color? warning,
    Color? warningWeak,
  }) {
    return AppColors(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      surface2: surface2 ?? this.surface2,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      text: text ?? this.text,
      textMuted: textMuted ?? this.textMuted,
      textFaint: textFaint ?? this.textFaint,
      ink: ink ?? this.ink,
      onInk: onInk ?? this.onInk,
      accent: accent ?? this.accent,
      accentStrong: accentStrong ?? this.accentStrong,
      accentWeak: accentWeak ?? this.accentWeak,
      onAccent: onAccent ?? this.onAccent,
      correct: correct ?? this.correct,
      correctWeak: correctWeak ?? this.correctWeak,
      wrong: wrong ?? this.wrong,
      wrongWeak: wrongWeak ?? this.wrongWeak,
      info: info ?? this.info,
      infoWeak: infoWeak ?? this.infoWeak,
      warning: warning ?? this.warning,
      warningWeak: warningWeak ?? this.warningWeak,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surface2: Color.lerp(surface2, other.surface2, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      text: Color.lerp(text, other.text, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textFaint: Color.lerp(textFaint, other.textFaint, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      onInk: Color.lerp(onInk, other.onInk, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentStrong: Color.lerp(accentStrong, other.accentStrong, t)!,
      accentWeak: Color.lerp(accentWeak, other.accentWeak, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      correct: Color.lerp(correct, other.correct, t)!,
      correctWeak: Color.lerp(correctWeak, other.correctWeak, t)!,
      wrong: Color.lerp(wrong, other.wrong, t)!,
      wrongWeak: Color.lerp(wrongWeak, other.wrongWeak, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoWeak: Color.lerp(infoWeak, other.infoWeak, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningWeak: Color.lerp(warningWeak, other.warningWeak, t)!,
    );
  }
}

/// 8px spacing scale (DESIGN.md).
abstract final class Gap {
  static const double xs2 = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xl2 = 32;
  static const double xl3 = 48;
  static const double xl4 = 64;
}

/// Border radius scale (DESIGN.md).
abstract final class Radii {
  static const double sm = 6;
  static const double md = 10;
  static const double lg = 16;
  static const double full = 999;
}

/// Layout widths (DESIGN.md).
abstract final class Layout {
  static const double content = 1180;
  static const double measure = 1080; // reading measure for study docs (web)
  static const double exam = 768;
}

const String _sans = 'Pretendard';
const String _mono = 'JetBrainsMono';

/// Pretendard Variable의 `wght` 축 토큰 — [TextStyle.fontWeight]와 항상 쌍으로 쓴다.
/// Flutter는 FontWeight를 가변축에 자동 매핑하지 않으므로, 이게 없으면 Variable
/// 본문이 전부 기본 굵기(400)로 렌더된다. fontWeight 자체는 폴백 폰트(한자 Noto 등)의
/// 합성 굵기와 위젯 시맨틱을 위해 유지한다. 정적 폰트(JetBrainsMono)에선 무시되므로
/// 병기해도 무해하다. 게이트: lib 전체에서 fontWeight:와 fontVariations:는 1:1.
abstract final class Wght {
  static const List<FontVariation> w400 = [FontVariation('wght', 400)];
  static const List<FontVariation> w500 = [FontVariation('wght', 500)];
  static const List<FontVariation> w600 = [FontVariation('wght', 600)];
  static const List<FontVariation> w700 = [FontVariation('wght', 700)];
  static const List<FontVariation> w800 = [FontVariation('wght', 800)];
}

/// 전 라우트 공통 순수 fade 전환 (DESIGN.md Motion — enter 200ms ease-out /
/// exit 150ms ease-in). 웹은 호스트 OS를 [TargetPlatform]으로 보고하므로
/// 6키 전부에 등록해야 한다 — 누락된 플랫폼의 방문자는 스톡 전환(iOS/macOS는
/// Cupertino 슬라이드)을 본다. `MediaQuery.disableAnimations`(OS 모션 감소)
/// 설정 시 전환 없이 즉시 표시한다.
class AppFadePageTransitionsBuilder extends PageTransitionsBuilder {
  const AppFadePageTransitionsBuilder();

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 150);

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
      child: child,
    );
  }
}

ThemeData _build(AppColors c, Brightness brightness) {
  final scheme = ColorScheme(
    brightness: brightness,
    primary: c.accent,
    onPrimary: c.onAccent,
    primaryContainer: c.accentWeak,
    onPrimaryContainer: c.accentStrong,
    secondary: c.accent,
    onSecondary: c.onAccent,
    error: c.wrong,
    onError: brightness == Brightness.light
        ? const Color(0xFFFFFFFF)
        : const Color(0xFF14181F),
    surface: c.surface,
    onSurface: c.text,
    surfaceContainerHighest: c.surface2,
    outline: c.border,
    outlineVariant: c.borderStrong,
  );

  final base =
      brightness == Brightness.light ? ThemeData.light() : ThemeData.dark();

  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: c.bg,
    canvasColor: c.bg,
    extensions: <ThemeExtension<dynamic>>[c],
    textTheme: _textTheme(c).apply(fontFamily: _sans),
    dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),
    splashFactory: InkRipple.splashFactory,
    visualDensity: VisualDensity.standard,
    pageTransitionsTheme: PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        for (final platform in TargetPlatform.values)
          platform: const AppFadePageTransitionsBuilder(),
      },
    ),
  );
}

TextTheme _textTheme(AppColors c) {
  return TextTheme(
    displayLarge: TextStyle(
        fontSize: 52,
        height: 1.05,
        fontWeight: FontWeight.w800, fontVariations: Wght.w800,
        letterSpacing: -1.3,
        color: c.text),
    displayMedium: TextStyle(
        fontSize: 40,
        height: 1.08,
        fontWeight: FontWeight.w800, fontVariations: Wght.w800,
        letterSpacing: -1,
        color: c.text),
    headlineMedium: TextStyle(
        fontSize: 30,
        height: 1.15,
        fontWeight: FontWeight.w800, fontVariations: Wght.w800,
        letterSpacing: -0.6,
        color: c.text),
    headlineSmall: TextStyle(
        fontSize: 24,
        height: 1.2,
        fontWeight: FontWeight.w700, fontVariations: Wght.w700,
        letterSpacing: -0.3,
        color: c.text),
    titleLarge: TextStyle(
        fontSize: 20,
        height: 1.3,
        fontWeight: FontWeight.w700, fontVariations: Wght.w700,
        color: c.text),
    titleMedium: TextStyle(
        fontSize: 16,
        height: 1.4,
        fontWeight: FontWeight.w700, fontVariations: Wght.w700,
        color: c.text),
    bodyLarge: TextStyle(
        fontSize: 17, height: 1.75, fontWeight: FontWeight.w400, fontVariations: Wght.w400, color: c.text),
    bodyMedium: TextStyle(
        fontSize: 15,
        height: 1.6,
        fontWeight: FontWeight.w400, fontVariations: Wght.w400,
        color: c.textMuted),
    labelLarge: TextStyle(
        fontSize: 14,
        height: 1.4,
        fontWeight: FontWeight.w700, fontVariations: Wght.w700,
        color: c.text),
    labelSmall: TextStyle(
        fontSize: 12,
        height: 1.3,
        fontWeight: FontWeight.w700, fontVariations: Wght.w700,
        letterSpacing: 0.4,
        color: c.textFaint),
  );
}

abstract final class AppTheme {
  static const String monoFamily = _mono;
  static ThemeData get light => _build(AppColors.light, Brightness.light);
  static ThemeData get dark => _build(AppColors.dark, Brightness.dark);
}

extension AppColorsContext on BuildContext {
  AppColors get c => Theme.of(this).extension<AppColors>()!;
}
