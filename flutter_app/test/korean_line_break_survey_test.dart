// 전체 화면 한국어 줄바꿈 조사·가드 (2026-11-20).
//
// 실제 라우터로 주요 화면을 폰 폭(412dp)에 렌더하고, 화면의 **모든 문단**(RenderParagraph)을
// 줄 단위로 걸어 「어절 중간에서 끊긴 줄」을 모은다. 한 줄 전체가 한 어절이라 강제로 끊긴
// 경우(줄 폭보다 긴 낱말)는 정상으로 본다. 처리([keepAll])는 lib/util/keep_all.dart.
//
// 세로를 아주 길게 둔다 — 목록이 화면에 보이는 것만 만드는(lazy) 구조라 짧으면 아래쪽
// 문단이 트리에 없어 조사에서 빠진다. 줄바꿈은 **폭**만으로 정해지므로 세로는 결과에 무관하다.
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:aws_docs/app_router.dart';
import 'package:aws_docs/theme/app_theme.dart';
import 'package:aws_docs/theme/theme_scope.dart';
import 'package:aws_docs/util/keep_all.dart';

const _wj = '\u2060';
const _zw = '\u200B';
final _hangul = RegExp(r'[가-힣]');
final _space = RegExp(r'\s');
final _letterOrDigit = RegExp(r'^[\p{L}\p{N}]', unicode: true);

bool _invisible(String ch) => ch == _wj || ch == _zw;
String _strip(String s) => s.replaceAll(_wj, '').replaceAll(_zw, '');

/// 결함으로 보는 줄바꿈 — CSS keep-all 이 막는 자리(한글이 낀 글자·숫자 쌍 사이)와
/// 가운뎃점으로 시작하는 줄. URL 의 「/」 뒤나 영문 긴 낱말의 강제 줄바꿈은 결함이 아니다.
bool _isDefect(String a, String b) {
  if (b == '·') return true;
  final words = _letterOrDigit.hasMatch(a) && _letterOrDigit.hasMatch(b);
  return words && (_hangul.hasMatch(a) || _hangul.hasMatch(b));
}

Widget _app(GoRouter router) => ThemeScope(
      isDark: false,
      toggle: () {},
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: router,
      ),
    );

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 30; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 40)));
    await tester.pump();
  }
}

/// 어절 중간에서 끊긴 줄을 「…앞|뒤…」 로 돌려준다.
List<String> _midWordBreaks(WidgetTester tester) {
  final found = <String>[];
  for (final rp in tester.allRenderObjects.whereType<RenderParagraph>()) {
    final text = rp.text.toPlainText(includeSemanticsLabels: false);
    if (!_hangul.hasMatch(text)) continue;
    final maxWidth = rp.constraints.maxWidth;
    if (!maxWidth.isFinite) continue; // 가로 스크롤(코드 블록 등)은 감기지 않는다
    // RenderParagraph 는 줄 경계를 노출하지 않는다 — 같은 입력으로 TextPainter 를 다시 잰다.
    final tp = TextPainter(
      text: rp.text,
      textAlign: rp.textAlign,
      textDirection: rp.textDirection,
      textScaler: rp.textScaler,
      maxLines: rp.maxLines,
      locale: rp.locale,
      strutStyle: rp.strutStyle,
      textWidthBasis: rp.textWidthBasis,
      textHeightBehavior: rp.textHeightBehavior,
    )..layout(maxWidth: maxWidth);
    var offset = 0;
    var guard = 0;
    while (offset < text.length && guard++ < 2000) {
      final line = tp.getLineBoundary(TextPosition(offset: offset));
      final end = line.end;
      if (end <= offset) break;
      if (end < text.length) {
        // 줄 끝 앞뒤의 실제 글자(넣은 폭 없는 문자는 건너뛴다).
        var a = end - 1;
        while (a > line.start && _invisible(text[a])) {
          a--;
        }
        var z = end;
        while (z < text.length && _invisible(text[z])) {
          z++;
        }
        final lineText = _strip(text.substring(line.start, end)).trim();
        final forced = !_space.hasMatch(lineText); // 한 줄 전체가 한 어절(줄 폭보다 길다)
        if (z < text.length && _isDefect(text[a], text[z]) && !forced) {
          final head = _strip(text.substring((a - 6).clamp(0, a), a + 1));
          final tail = _strip(text.substring(z, (z + 6).clamp(z, text.length)));
          found.add('…$head|$tail…');
        }
      }
      offset = end;
      while (offset < text.length && (_space.hasMatch(text[offset]) || _invisible(text[offset]))) {
        offset++;
      }
    }
  }
  return found;
}

const _routes = <String>[
  '/',
  '/cert/SAA-C03',
  '/cert/CLF-C02',
  '/cert/SAA-C03/study/saa-t1-3',
  '/cert/CLF-C02/study/clf-t1-1',
  '/cert/SAA-C03/exam',
  '/cert/SAA-C03/plan',
  '/cert/SAA-C03/review',
  '/cert/SAA-C03/report',
  '/cert/SAA-C03/study/saa-t1-3/quiz',
  '/notices',
];

void main() {
  setUp(() {
    rootBundle.clear();
    keepAllEnabled = true;
  });
  tearDown(() => keepAllEnabled = false);

  for (final route in _routes) {
    testWidgets('$route — 어절 중간 줄바꿈이 없다', (tester) async {
      tester.view.physicalSize = const Size(412, 30000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_app(createRouter(initialLocation: route)));
      await _settle(tester);
      // 대조군: 화면에 한국어 문단이 실제로 그려졌다(조사가 공허하지 않다).
      final paragraphs = tester.allRenderObjects
          .whereType<RenderParagraph>()
          .where((rp) => _hangul.hasMatch(rp.text.toPlainText()))
          .length;
      // 빈 상태 화면(학습 일정 없음)은 한국어 문단이 3개뿐이다 — 렌더 여부만 본다.
      expect(paragraphs, greaterThan(0), reason: '$route 가 렌더되지 않았다');
      final breaks = _midWordBreaks(tester).toSet().toList();
      expect(breaks, isEmpty, reason: '\n${breaks.join('\n')}');
    });
  }
}
