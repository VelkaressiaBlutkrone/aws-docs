// 한국어 어절 단위 줄바꿈(keep-all) 가드 (2026-11-20).
//
// Flutter 3.47.2 의 `ParagraphStyle` 에는 CSS `word-break: keep-all` 에 해당하는 설정이
// 없다(SDK `dart:ui` text.dart 실측 — textAlign·textDirection·maxLines·font·height·strut·
// ellipsis·locale 뿐). 그래서 한국어가 **글자 단위로** 끊겨 「덤|프」「추천 순|서」가 났다.
// 어절 안의 글자 사이에 U+2060(WORD JOINER)을 넣으면 그 자리에서 끊지 않는다 — 이 파일이
// 실제 렌더(SkParagraph, 웹 CanvasKit 과 같은 엔진)로 그것을 단정한다.
//
// ⚠️ 테스트 환경에서는 `flutter_test_config.dart` 가 이 처리를 끈다 — 기존 `find.text`
// 244곳이 보이지 않는 문자 때문에 깨지지 않게. 이 파일만 켜고 잰다.
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aws_docs/util/keep_all.dart';
import 'package:aws_docs/widgets/text.dart' as k;

const _wj = '\u2060';
const _zw = '\u200B';

String _strip(String s) => s.replaceAll(_wj, '').replaceAll(_zw, '');
const _sample = '입문부터 전문 분야까지 자격증 단계, 추천 순서, 상세 학습 문서, 모의고사를 '
    '한국어로 한 곳에서. 덤프 암기가 아니라 "왜"를 가르치는 이해 중심 학습 사이트입니다.';

/// 렌더된 각 줄의 글자(U+2060 제거).
List<String> _lines(String text, double width) {
  final tp = TextPainter(
    text: TextSpan(text: text, style: const TextStyle(fontSize: 20)),
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: width);
  return [
    for (final m in tp.computeLineMetrics())
      () {
        final start = tp
            .getPositionForOffset(Offset(0, m.baseline - m.ascent + 1))
            .offset;
        final end = tp.getLineBoundary(TextPosition(offset: start)).end;
        return _strip(text.substring(start, end)).trim();
      }(),
  ];
}

/// 원문의 어절 집합 — 렌더된 줄이 어절을 쪼개지 않았는지 보는 기준.
Set<String> _words(String s) => s.split(RegExp(r'\s+')).toSet();

void main() {
  setUp(() => keepAllEnabled = true);
  tearDown(() => keepAllEnabled = false);

  group('keepAll', () {
    // CSS keep-all 과 같은 규칙: 한글이 낀 「글자·숫자」 쌍 사이만 막고, 문장부호는
    // 렌더러의 원래 규칙에 맡긴다(URL 의 「/」 뒤처럼 원래 끊기던 자리를 막지 않게).
    test('한글이 낀 글자 쌍 사이에만 U+2060 을 넣는다', () {
      expect(keepAll('추천 순서'), '추$_wj천 순$_wj서');
      expect(keepAll('한 곳에서.'), '한 곳$_wj에$_wj서.');
      expect(keepAll('AWS를'), 'AWS$_wj를');
    });

    test('한글이 없는 쌍과 문장부호는 그대로다', () {
      const url = 'https://aws.amazon.com/ko_kr/';
      expect(keepAll(url), url);
      expect(keepAll('(1024)'), '(1024)');
    });

    // 「자격증명·권한」「Organizations·Control」: 가운뎃점 **앞**에서 끊기면 줄이 「·」 로
    // 시작한다 — 막는다. **뒤**는 끊을 수 있게 열어 둔다(영문끼리는 원래 끊을 자리가 없어
    // 긴 묶음이 한가운데서 강제로 잘렸다 — 「Orga|nizations」).
    test('가운뎃점은 앞에서 끊지 않고 뒤에서 끊을 수 있다', () {
      expect(keepAll('명·권'), '명$_wj·$_zw권');
      expect(keepAll('Organizations·Control'), 'Organizations$_wj·${_zw}Control');
      // 「A · B」 구분자는 **앞 공백**에서 끊기면 다음 줄이 「·」 로 시작한다 —
      // 앞 공백만 줄바꿈 없는 공백(U+00A0)으로 바꾼다. 뒤 공백에서는 끊을 수 있다.
      expect(keepAll('A · B'), 'A\u00A0· B');
      expect(keepAll('학습문서 · 출처'), '학$_wj습$_wj문$_wj서\u00A0· 출$_wj처');
    });

    test('공백·줄바꿈은 그대로이고 앞뒤에 넣지 않는다', () {
      expect(keepAll(' 가나\n다라 '), ' 가$_wj나\n다$_wj라 ');
      expect(keepAll(''), '');
      expect(keepAll('가'), '가');
    });

    test('넣은 문자를 지우면 원문과 같다', () {
      expect(_strip(keepAll(_sample)), _sample);
    });

    test('이모지 같은 결합 문자는 쪼개지 않는다', () {
      // 👨‍💻 은 ZWJ 로 묶인 한 글자다 — 그 안에 문자가 들어가면 그림이 깨진다.
      expect(keepAll('👨‍💻개발').replaceAll(_wj, '|'), '👨‍💻개|발');
    });

    test('꺼져 있으면 아무것도 바꾸지 않는다', () {
      keepAllEnabled = false;
      expect(keepAll(_sample), _sample);
    });
  });

  group('keepAllRuns — 여러 조각(굵게·코드)으로 나뉜 문단', () {
    test('공백 없이 붙은 조각 경계도 잇는다', () {
      // 「**굵게**다」는 조각 「굵게」 + 「다」 — 조각마다 따로 처리하면 그 사이에서 끊긴다.
      expect(keepAllRuns(['굵게', '다 끝']), ['굵$_wj게', '$_wj다 끝']);
    });

    test('경계에 공백이 있으면 잇지 않는다', () {
      expect(keepAllRuns(['굵게 ', '다']), ['굵$_wj게 ', '다']);
      expect(keepAllRuns(['굵게', ' 다']), ['굵$_wj게', ' 다']);
    });

    test('빈 조각을 건너뛰어도 경계를 잇는다', () {
      expect(keepAllRuns(['가', '', '나']), ['가', '', '$_wj나']);
    });
  });

  group('keepAllSpan — Text.rich 의 조각 트리', () {
    test('붙은 조각 경계를 잇고 스타일·제스처를 보존한다', () {
      final tap = TapGestureRecognizer();
      addTearDown(tap.dispose);
      const bold = TextStyle(fontWeight: FontWeight.w700);
      final out = keepAllSpan(TextSpan(children: [
        const TextSpan(text: '굵게', style: bold),
        TextSpan(text: '다 끝', recognizer: tap),
      ])) as TextSpan;
      final kids = out.children!.cast<TextSpan>();
      expect(kids[0].text, '굵$_wj게');
      expect(kids[0].style, bold);
      expect(kids[1].text, '$_wj다 끝');
      expect(kids[1].recognizer, same(tap));
    });

    test('화면 낭독용 라벨은 원문이다(보이지 않는 문자를 읽지 않게)', () {
      final out = keepAllSpan(const TextSpan(text: '추천 순서')) as TextSpan;
      expect(out.semanticsLabel, '추천 순서');
      // 이미 라벨이 있으면 그대로 둔다.
      final kept =
          keepAllSpan(const TextSpan(text: '가나', semanticsLabel: '다른')) as TextSpan;
      expect(kept.semanticsLabel, '다른');
    });

    test('WidgetSpan 은 그대로 두고 경계를 잇지 않는다', () {
      const icon = WidgetSpan(child: SizedBox(width: 4));
      final out = keepAllSpan(const TextSpan(children: [
        TextSpan(text: '가'),
        icon,
        TextSpan(text: '나'),
      ])) as TextSpan;
      expect(out.children![1], same(icon));
      expect((out.children![2] as TextSpan).text, '나');
    });

    test('꺼져 있으면 같은 객체를 돌려준다', () {
      keepAllEnabled = false;
      const span = TextSpan(text: '추천 순서');
      expect(keepAllSpan(span), same(span));
    });
  });

  group('Text 위젯(lib/widgets/text.dart)', () {
    Future<Text> inner(WidgetTester tester, Widget w) async {
      await tester.pumpWidget(Directionality(textDirection: TextDirection.ltr, child: w));
      return tester.widget<Text>(find.byType(Text));
    }

    testWidgets('글자를 어절 단위로 바꾸고 낭독 라벨은 원문이다', (tester) async {
      final t = await inner(tester, const k.Text('추천 순서', maxLines: 2));
      expect(t.data, '추$_wj천 순$_wj서');
      expect(t.semanticsLabel, '추천 순서');
      expect(t.maxLines, 2);
    });

    testWidgets('Text.rich 도 조각 경계까지 바꾼다', (tester) async {
      final t = await inner(
          tester,
          const k.Text.rich(TextSpan(children: [
            TextSpan(text: '이해'),
            TextSpan(text: '하고'),
          ])));
      final kids = (t.textSpan! as TextSpan).children!.cast<TextSpan>();
      expect(kids.map((s) => s.text), ['이$_wj해', '$_wj하$_wj고']);
    });

    testWidgets('꺼져 있으면 원문 그대로이고 라벨을 붙이지 않는다', (tester) async {
      keepAllEnabled = false;
      final t = await inner(tester, const k.Text('추천 순서'));
      expect(t.data, '추천 순서');
      expect(t.semanticsLabel, isNull);
    });

    // lib 의 모든 Text 가 이 위젯을 쓰는지 — import 하나만 빠뜨려도 그 파일은 조용히
    // Flutter 의 Text 로 돌아가 글자 단위로 끊긴다.
    test('lib 에서 Text 를 쓰는 파일은 전부 lib/widgets/text.dart 를 쓴다', () {
      final files = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .where((f) => !f.path.replaceAll(r'\', '/').endsWith('widgets/text.dart'));
      final usesText = RegExp(r'\bText(\.rich)?\(');
      final missing = <String>[];
      var checked = 0;
      for (final f in files) {
        final src = f.readAsStringSync();
        if (!usesText.hasMatch(src)) continue;
        checked++;
        // lib/widgets 안의 파일은 `import 'text.dart';` 로 쓴다 — 경로 앞부분은 선택이다.
        // ('context.dart' 같은 이름은 'text' 바로 앞이 따옴표나 '/' 가 아니라 걸리지 않는다.)
        if (!RegExp(r"import '(?:[^']*/)?text\.dart';").hasMatch(src)) missing.add(f.path);
      }
      expect(checked, greaterThan(30), reason: '범위가 비었다');
      expect(missing, isEmpty);
    });
  });

  // 넣은 문자도 **자간을 받는다**(SkParagraph 가 글자마다 더한다). 제목처럼 자간이 음수인
  // 글에서는 글자마다 1~1.5px 씩 당겨져 실제 잉크보다 폭이 작게 재지고 끝 글자가 잘렸다
  // (2026-11-20 에뮬레이터에서 히어로 「자격증,」 의 쉼표). 자간이 0이 아니면 넣은 문자만
  // 자간 0 조각으로 떼어 낸다 — 폭이 원문과 같아야 한다.
  group('자간 보정', () {
    double width(InlineSpan span) {
      final tp = TextPainter(text: span, textDirection: TextDirection.ltr)..layout();
      return tp.width;
    }

    for (final ls in [-1.3, 0.4]) {
      test('자간 $ls 에서도 폭이 원문과 같다(Text.rich)', () {
        final style = TextStyle(fontSize: 20, letterSpacing: ls);
        const text = '클라우드 자격증, 이해하고 통과하기';
        final plain = width(TextSpan(text: text, style: style));
        final out = keepAllSpan(TextSpan(text: text, style: style));
        expect(width(out), closeTo(plain, 0.01));
        // 그러면서도 어절 사이만 끊긴다(조각을 떼어 내도 줄바꿈 규칙은 그대로다).
        expect(_strip(out.toPlainText()), text);
      });
    }

    test('자간이 0이면 조각을 떼지 않는다(본문 성능)', () {
      final out = keepAllSpan(const TextSpan(text: '추천 순서', style: TextStyle(fontSize: 20)))
          as TextSpan;
      expect(out.children, isNull);
      expect(out.text, '추$_wj천 순$_wj서');
    });

    test('물려받은 자간도 본다', () {
      final out = keepAllSpan(const TextSpan(text: '추천 순서'),
          inherited: const TextStyle(letterSpacing: -1.3)) as TextSpan;
      expect(out.children, isNotNull);
    });

    test('떼어 낸 조각도 원래 조각의 탭 처리를 갖는다', () {
      final tap = TapGestureRecognizer();
      addTearDown(tap.dispose);
      final out = keepAllSpan(
          TextSpan(text: '추천 순서', recognizer: tap, style: const TextStyle(letterSpacing: -1)))
          as TextSpan;
      final leaves = <TextSpan>[];
      out.visitChildren((s) {
        if (s is TextSpan && s.text != null) leaves.add(s);
        return true;
      });
      expect(leaves, isNotEmpty);
      expect(leaves.every((l) => identical(l.recognizer, tap)), isTrue);
    });

    testWidgets('Text 위젯 — 자간 있는 제목도 폭이 원문과 같다', (tester) async {
      const style = TextStyle(fontSize: 20, letterSpacing: -1.3);
      await tester.pumpWidget(const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(child: k.Text('클라우드 자격증,', style: style))));
      final inner = tester.widget<Text>(find.byType(Text));
      expect(inner.semanticsLabel, '클라우드 자격증,');
      final shown = inner.textSpan ?? TextSpan(text: inner.data);
      final plain = width(const TextSpan(text: '클라우드 자격증,', style: style));
      expect(width(TextSpan(style: style, children: [shown])), closeTo(plain, 0.01));
    });
  });

  group('실제 렌더', () {
    // 대조군: 처리 없이는 이 렌더러가 어절 중간에서 끊는다(그래서 고칠 이유가 있다).
    test('대조군: 처리 전에는 어절 중간에서 끊긴다', () {
      final words = _words(_sample);
      final broken = [
        for (final w in [180.0, 260.0])
          for (final line in _lines(_sample, w))
            for (final tok in line.split(' '))
              if (tok.isNotEmpty && !words.contains(tok)) tok,
      ];
      expect(broken, isNotEmpty);
    });

    test('처리 후에는 모든 줄이 원문 어절로만 이루어진다', () {
      final words = _words(_sample);
      for (final w in [180.0, 220.0, 260.0, 320.0]) {
        final lines = _lines(keepAll(_sample), w);
        for (final line in lines) {
          for (final tok in line.split(' ')) {
            if (tok.isEmpty) continue;
            expect(words, contains(tok), reason: 'width $w: 「$tok」 이 어절 중간에서 잘렸다');
          }
        }
        expect(lines.join(' '), _sample, reason: 'width $w');
      }
    });

    test('줄 폭보다 긴 한 어절은 넘치지 않고 강제로 끊긴다', () {
      const long = '확인되지않았으므로정답으로고르지않습니다아주긴어절';
      final lines = _lines(keepAll(long), 120);
      expect(lines.length, greaterThan(1));
      expect(lines.join(), long);
    });
  });
}
