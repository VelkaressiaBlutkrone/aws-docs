import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/pages/home/home_bits.dart';
import 'package:aws_docs/pages/home/hero_section.dart';
import 'package:aws_docs/theme/app_theme.dart';
import 'package:aws_docs/theme/theme_scope.dart';

// CODE-P-001 회귀: 히어로 CTA(HomeButton) 무동작 방지.
// HomeButton은 과거 onTap 없는 순수 Container라 클릭·Tab·Enter 전부 불가했다.
Widget _wrap(Widget child) => ThemeScope(
      isDark: false,
      toggle: () {},
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: child),
      ),
    );

void main() {
  testWidgets('HomeButton: onTap을 주면 탭 시 호출된다', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_wrap(
      HomeButton(label: '눌러', primary: true, onTap: () => taps++),
    ));
    await tester.tap(find.text('눌러'));
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('히어로 CTA: 두 버튼이 각각 onGotoPaths·onGotoExams를 호출한다',
      (tester) async {
    var paths = 0;
    var exams = 0;
    await tester.pumpWidget(_wrap(
      SingleChildScrollView(
        child: HeroSection(
          onGotoPaths: () => paths++,
          onGotoExams: () => exams++,
        ),
      ),
    ));
    await tester.tap(find.text('추천 순서 보기'));
    await tester.pump();
    await tester.tap(find.text('모의고사 구성'));
    await tester.pump();
    expect(paths, 1);
    expect(exams, 1);
  });
}
