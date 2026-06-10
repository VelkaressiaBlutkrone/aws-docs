import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/app_router.dart';
import 'package:aws_docs/theme/app_theme.dart';
import 'package:aws_docs/theme/theme_scope.dart';

Widget _home() {
  final router = createRouter(initialLocation: '/');
  return ThemeScope(
    isDark: false,
    toggle: () {},
    child: MaterialApp.router(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
    ),
  );
}

void main() {
  testWidgets('홈 학습 일정 섹션: 제목 노출 + 일정 → CTA 존재', (tester) async {
    await tester.pumpWidget(_home());
    await tester.pump();

    // 섹션 제목 '학습 일정'이 노출된다.
    expect(find.text('학습 일정'), findsWidgets);
    // 콘텐츠 보유 자격증별 '일정 →' CTA가 최소 하나 이상 있다.
    expect(find.text('일정 →'), findsWidgets);
  });
}
