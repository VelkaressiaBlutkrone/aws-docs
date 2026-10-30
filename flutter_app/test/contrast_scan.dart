import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/theme/app_theme.dart';

/// 렌더된 트리에서 **텍스트 색 × 실제 배경 색** 짝을 찾아내는 스캐너.
///
/// `accent / surface2` 같은 AA 미달 조합은 **중첩**으로만 판정된다 — 소스를 grep해서는
/// "이 accent 텍스트가 어느 배경 위에 있는가"를 알 수 없다(2026-10-30 M-6에서 surface2
/// 패널 29곳을 눈으로 훑다 7곳만 확인하고 멈췄다). 그래서 트리를 직접 걷는다.
///
/// 판정은 **가장 가까운 불투명 배경**으로 한다 — 바깥이 surface2이고 안쪽 카드가
/// surface면 그 텍스트는 surface 위에 있다.
class TextOnBackground {
  const TextOnBackground({
    required this.text,
    required this.color,
    required this.background,
  });

  /// 화면에 보이는 문자열(진단용).
  final String text;
  final Color color;

  /// 가장 가까운 불투명 배경. 못 찾으면 null(스캐폴드 바깥 등).
  final Color? background;

  @override
  String toString() =>
      '"${text.length > 24 ? '${text.substring(0, 24)}…' : text}" '
      'fg=#${color.toARGB32().toRadixString(16).padLeft(8, '0')} '
      'bg=${background == null ? 'none' : '#${background!.toARGB32().toRadixString(16).padLeft(8, '0')}'}';
}

/// 불투명 배경을 칠하는 위젯이면 그 색, 아니면 null.
Color? _opaqueBackgroundOf(Widget w) {
  Color? opaque(Color? c) =>
      (c == null || c.a < 1.0) ? null : c; // 반투명은 "배경"으로 치지 않는다
  if (w is DecoratedBox) {
    final d = w.decoration;
    return d is BoxDecoration ? opaque(d.color) : null;
  }
  if (w is ColoredBox) return opaque(w.color);
  if (w is Material) return opaque(w.color);
  return null;
}

/// ⚠️ **아이콘은 텍스트가 아니다.** `Icon`은 내부적으로 `RichText`로 렌더되고 글리프가
/// 스팬 텍스트로 들어오므로, 걸러내지 않으면 아이콘 색이 전부 "텍스트"로 잡힌다
/// (대조군이 실제로 이걸 잡아냈다). 아이콘 코드포인트는 유니코드 사용자 영역(PUA)에
/// 있으므로 폰트 이름과 **양쪽으로** 본다 — 폰트만 보면 `packages/...` 접두어가 붙은
/// 아이콘 폰트를 놓치고, PUA만 보면 본문에 쓴 PUA 문자를 놓친다.
bool _isIconGlyph(String text, TextStyle? style) {
  final family = style?.fontFamily ?? '';
  if (family.contains('Icons')) return true;
  if (text.isEmpty) return false;
  return text.runes.every((r) =>
      (r >= 0xE000 && r <= 0xF8FF) || // BMP 사용자 영역
      (r >= 0xF0000 && r <= 0xFFFFD) ||
      (r >= 0x100000 && r <= 0x10FFFD));
}

/// 렌더된 모든 텍스트의 (색, 배경) 짝. `RichText`를 보는 이유는 거기서 스타일이
/// **이미 해결**돼 있기 때문이다 — `Text.style`은 null일 수 있고 실제 색은
/// DefaultTextStyle·테마에서 온다.
List<TextOnBackground> scanTextOnBackground(WidgetTester tester) {
  final out = <TextOnBackground>[];
  for (final element in find.byType(RichText).evaluate()) {
    final rich = element.widget as RichText;

    Color? bg;
    element.visitAncestorElements((a) {
      final c = _opaqueBackgroundOf(a.widget);
      if (c != null) {
        bg = c;
        return false; // 가장 가까운 것에서 멈춘다
      }
      return true;
    });

    // 스팬마다 색이 다를 수 있다(Text.rich) — 전부 본다.
    void visit(InlineSpan span) {
      if (span is TextSpan) {
        final color = span.style?.color;
        final text = span.text;
        if (color != null &&
            text != null &&
            text.trim().isNotEmpty &&
            !_isIconGlyph(text, span.style)) {
          out.add(TextOnBackground(text: text, color: color, background: bg));
        }
        for (final child in span.children ?? const <InlineSpan>[]) {
          visit(child);
        }
      }
    }

    visit(rich.text);
  }
  return out;
}

/// [fg] 텍스트가 [bg] 위에 있는 사례만. AA 미달 조합을 고정할 때 쓴다.
List<TextOnBackground> findPairs(
  WidgetTester tester, {
  required Color fg,
  required Color bg,
}) =>
    scanTextOnBackground(tester)
        .where((t) => t.color == fg && t.background == bg)
        .toList();

/// `accent` 텍스트가 `surface2` 위에 있는 사례(라이트 4.21 = AA 미달).
List<TextOnBackground> accentOnSurface2(WidgetTester tester,
        {AppColors colors = AppColors.light}) =>
    findPairs(tester, fg: colors.accent, bg: colors.surface2);
