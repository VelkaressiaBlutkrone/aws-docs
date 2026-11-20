// flutter_app/lib/widgets/text.dart
//
// 앱 전체의 `Text` — Flutter 의 `Text` 와 **같은 이름·같은 매개변수**를 갖고, 글자를 한국어
// 어절 단위 줄바꿈([keepAll])으로 바꾼 뒤 Flutter 의 `Text` 를 그린다(2026-11-20).
//
// 왜 같은 이름인가: lib 의 `Text(` 호출이 42개 파일 205곳이다. 호출부를 하나씩 바꾸면 새 문구를
// 쓸 때마다 잊기 쉽다. 대신 각 파일은 Flutter import 에서 `Text` 를 숨기고 이 파일을 import 한다
// — 호출 코드는 그대로다. 빠뜨린 파일은 test/keep_all_test.dart 가 잡는다.
//
// 왜 하위 클래스가 아닌가: `extends Text` 면 이 위젯과 안쪽 Flutter `Text` 가 둘 다
// `widget is Text` 라 테스트의 `find.text` 가 두 개를 찾는다. 별개의 위젯이어야 안쪽 하나만 잡힌다.
//
// 화면 낭독: 글자가 바뀐 경우에만 원문을 `semanticsLabel` 로 넘겨 보이지 않는 문자를 읽지 않게 한다.
import 'package:flutter/widgets.dart' as flutter show Text;
import 'package:flutter/widgets.dart' hide Text;

import '../util/keep_all.dart';

class Text extends StatelessWidget {
  const Text(
    String this.data, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.semanticsIdentifier,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  }) : textSpan = null;

  const Text.rich(
    InlineSpan this.textSpan, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.semanticsIdentifier,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  }) : data = null;

  final String? data;
  final InlineSpan? textSpan;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final TextScaler? textScaler;
  final int? maxLines;
  final String? semanticsLabel;
  final String? semanticsIdentifier;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;

  @override
  Widget build(BuildContext context) {
    // 자간 판정에 쓰는 실제 스타일(flutter Text 가 합치는 것과 같다).
    final base = DefaultTextStyle.of(context).style.merge(style);
    final d = data;
    if (d != null) {
      final shown = keepAll(d);
      // 자간이 0이 아니면 넣은 문자를 자간 0 조각으로 떼어 내야 폭이 원문과 같다.
      if (shown != d && (base.letterSpacing ?? 0) != 0) {
        return flutter.Text.rich(
          keepAllSpan(TextSpan(text: d), inherited: base),
          style: style,
          strutStyle: strutStyle,
          textAlign: textAlign,
          textDirection: textDirection,
          locale: locale,
          softWrap: softWrap,
          overflow: overflow,
          textScaler: textScaler,
          maxLines: maxLines,
          semanticsLabel: semanticsLabel ?? d,
          semanticsIdentifier: semanticsIdentifier,
          textWidthBasis: textWidthBasis,
          textHeightBehavior: textHeightBehavior,
          selectionColor: selectionColor,
        );
      }
      return flutter.Text(
        shown,
        style: style,
        strutStyle: strutStyle,
        textAlign: textAlign,
        textDirection: textDirection,
        locale: locale,
        softWrap: softWrap,
        overflow: overflow,
        textScaler: textScaler,
        maxLines: maxLines,
        semanticsLabel: semanticsLabel ?? (shown == d ? null : d),
        semanticsIdentifier: semanticsIdentifier,
        textWidthBasis: textWidthBasis,
        textHeightBehavior: textHeightBehavior,
        selectionColor: selectionColor,
      );
    }
    return flutter.Text.rich(
      keepAllSpan(textSpan!, inherited: base),
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaler: textScaler,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      semanticsIdentifier: semanticsIdentifier,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
    );
  }
}
