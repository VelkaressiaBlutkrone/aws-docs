// flutter_app/lib/util/keep_all.dart
//
// 한국어 어절 단위 줄바꿈 — CSS `word-break: keep-all` 의 대용 (2026-11-20).
//
// Flutter 3.47.2 의 `ParagraphStyle` 에는 줄바꿈 규칙 설정이 없어(SDK `dart:ui` 실측)
// 한국어가 **글자 단위로** 끊긴다 — 「덤|프 암기」「추천 순|서」「통과하|기」. 어절 안의
// 글자 사이에 U+2060(WORD JOINER, 폭 없음)을 넣으면 렌더러가 그 자리에서 끊지 않아
// 공백에서만 줄이 바뀐다. 줄 폭보다 긴 한 어절은 여전히 강제로 끊겨 넘치지 않는다.
// 가드: test/keep_all_test.dart(실제 렌더로 단정).
//
// ⚠️ 대가: 화면 글자에 U+2060 이 섞여 **선택·복사하면 함께 복사된다**(보이지 않음).
// ⚠️ 테스트 환경은 `test/flutter_test_config.dart` 가 [keepAllEnabled] 를 끈다 —
// 화면 글자를 그대로 찾는 `find.text` 가 보이지 않는 문자 때문에 깨지지 않게.
//
// 적용 대상은 **여러 줄로 감기는 글**이다(학습문서 본문, 문항 지문·보기·해설, 소개 문구).
// 한 줄짜리 버튼·칩은 감기지 않으므로 넣지 않는다.
import 'package:flutter/widgets.dart';

/// 어절 단위 줄바꿈을 켤지. 테스트 환경만 끈다.
bool keepAllEnabled = true;

const String _wordJoiner = '\u2060'; // 이 자리에서 끊지 않는다(폭 없음)
const String _breakHere = '\u200B'; // 이 자리에서 끊어도 된다(폭 없음)
const String _middleDot = '\u00B7';
final RegExp _space = RegExp(r'\s');
// 「A · B」 구분자: 앞 공백에서 끊기면 다음 줄이 「·」 로 시작한다 — 그 공백만 줄바꿈 없는
// 공백(U+00A0, 보이는 폭은 같다)으로 바꾼다. 뒤 공백에서는 그대로 끊을 수 있다.
final RegExp _spaceBeforeDotSeparator = RegExp(r'(?<=\S) (?=\u00B7 )');
final RegExp _letterOrDigit = RegExp(r'^[\p{L}\p{N}]', unicode: true);
final RegExp _hangul = RegExp(r'^[\u1100-\u11FF\u3130-\u318F\uAC00-\uD7A3]');

bool _isSpace(String ch) => _space.hasMatch(ch);

/// 두 글자 [a]·[b] 사이에 넣을 문자. CSS `word-break: keep-all` 과 같이 **한글이 낀
/// 글자·숫자 쌍**만 붙이고, 문장부호는 렌더러의 원래 규칙에 맡긴다 — URL 의 「/」 뒤처럼
/// 원래 끊기던 자리를 막으면 긴 덩어리가 엉뚱한 곳에서 강제로 잘린다(2026-11-20 조사에서
/// 「….com|/ko…」 로 실제로 났다). 가운뎃점은 **앞을 붙이고 뒤를 연다** — 줄이 「·」 로
/// 시작하지 않게, 그리고 「Organizations·Control」 같은 영문 묶음이 「·」 뒤에서 끊길 수 있게.
String _between(String a, String b) {
  if (_isSpace(a) || _isSpace(b)) return '';
  if (b == _middleDot) return _wordJoiner;
  if (a == _middleDot) return _breakHere;
  final words = _letterOrDigit.hasMatch(a) && _letterOrDigit.hasMatch(b);
  if (words && (_hangul.hasMatch(a) || _hangul.hasMatch(b))) return _wordJoiner;
  return '';
}

/// 어절 단위 줄바꿈 문자를 넣는다([_between] 의 규칙). 글자는 그래핌 단위로 다룬다.
String keepAll(String s) {
  if (!keepAllEnabled || s.length < 2) return s;
  final out = StringBuffer();
  String? prev;
  for (final ch in s.characters) {
    if (prev != null) out.write(_between(prev, ch));
    out.write(ch);
    prev = ch;
  }
  return out.toString().replaceAll(_spaceBeforeDotSeparator, '\u00A0');
}

/// `Text.rich` 의 조각 트리 전체에 [keepAll] 을 적용한다. 공백 없이 붙은 조각 경계도 잇고
/// (「**굵게**다」), 바뀐 조각의 낭독 라벨은 **원문**으로 둔다 — 화면 낭독기가 보이지 않는
/// 문자를 읽지 않게. 스타일·제스처·마우스 처리는 그대로 옮긴다. `WidgetSpan` 은 그대로 두고
/// 그 앞뒤는 잇지 않는다(인라인 아이콘 옆에서는 끊겨도 된다).
/// [inherited] 는 위에서 물려받는 스타일(DefaultTextStyle 과 Text 의 style)이다 — 자간 판정에 쓴다.
InlineSpan keepAllSpan(InlineSpan span, {TextStyle? inherited}) {
  if (!keepAllEnabled) return span;
  String? last; // 앞 조각들의 마지막 글자
  InlineSpan walk(InlineSpan s, TextStyle? parent) {
    if (s is! TextSpan) {
      last = null;
      return s;
    }
    final effective = parent == null ? s.style : parent.merge(s.style);
    var text = s.text;
    if (text != null && text.isNotEmpty) {
      var t = keepAll(text);
      final first = text.characters.first;
      if (last != null) t = '${_between(last!, first)}$t';
      last = text.characters.last;
      text = t;
    }
    final kids = s.children?.map((c) => walk(c, effective)).toList();
    final changed = text != s.text;
    // 넣은 문자도 자간을 받는다(SkParagraph 가 글자마다 더한다). 자간이 0이 아니면 넣은
    // 문자만 자간 0 조각으로 떼어 내 폭을 원문과 같게 한다 — 안 그러면 음수 자간인 제목이
    // 글자마다 당겨져 실제 잉크보다 좁게 재지고 끝 글자가 잘린다(2026-11-20 히어로 쉼표).
    final spacing = effective?.letterSpacing ?? 0;
    if (changed && spacing != 0) {
      TextSpan leaf(String t, {TextStyle? style, String? label}) => TextSpan(
            text: t,
            style: style,
            recognizer: s.recognizer,
            mouseCursor: s.mouseCursor,
            onEnter: s.onEnter,
            onExit: s.onExit,
            semanticsLabel: label,
            locale: s.locale,
            spellOut: s.spellOut,
          );
      final pieces = <InlineSpan>[];
      final buf = StringBuffer();
      void flush() {
        if (buf.isEmpty) return;
        final piece = buf.toString();
        buf.clear();
        pieces.add(leaf(piece));
      }

      for (final ch in text!.characters) {
        if (ch == _wordJoiner || ch == _breakHere) {
          flush();
          // 화면 낭독기가 읽지 않게 빈 라벨을 둔다.
          pieces.add(leaf(ch, style: const TextStyle(letterSpacing: 0), label: ''));
        } else {
          buf.write(ch);
        }
      }
      flush();
      return TextSpan(
        children: [...pieces, ...?kids],
        style: s.style,
        recognizer: s.recognizer,
        mouseCursor: s.mouseCursor,
        onEnter: s.onEnter,
        onExit: s.onExit,
        semanticsIdentifier: s.semanticsIdentifier,
        locale: s.locale,
        spellOut: s.spellOut,
      );
    }
    return TextSpan(
      text: text,
      children: kids,
      style: s.style,
      recognizer: s.recognizer,
      mouseCursor: s.mouseCursor,
      onEnter: s.onEnter,
      onExit: s.onExit,
      semanticsLabel: s.semanticsLabel ?? (changed ? s.text : null),
      semanticsIdentifier: s.semanticsIdentifier,
      locale: s.locale,
      spellOut: s.spellOut,
    );
  }

  return walk(span, inherited);
}

/// 한 문단이 여러 조각(굵게·코드·링크)으로 나뉠 때 쓴다. 조각마다 [keepAll] 을 하고,
/// **공백 없이 붙은 조각 경계**에도 U+2060 을 넣는다 — 「**굵게**다」가 경계에서 끊기지 않게.
List<String> keepAllRuns(List<String> runs) {
  if (!keepAllEnabled) return runs;
  final out = <String>[];
  String? lastChar; // 앞 조각들의 마지막 글자(빈 조각은 건너뛴다)
  for (final r in runs) {
    var t = keepAll(r);
    if (r.isNotEmpty) {
      final first = r.characters.first;
      if (lastChar != null) t = '${_between(lastChar, first)}$t';
      lastChar = r.characters.last;
    }
    out.add(t);
  }
  return out;
}
