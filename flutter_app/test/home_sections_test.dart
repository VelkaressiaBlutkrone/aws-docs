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
  testWidgets('학습문서 섹션: CLF-C02 요약 카드 + 준비 중 그룹', (tester) async {
    await tester.pumpWidget(_home());
    await tester.pump();

    // 콘텐츠 보유 자격증 요약 카드.
    expect(find.textContaining('검증 학습문서'), findsWidgets);
    // 콘텐츠 없는 자격증은 "준비 중" 그룹에.
    expect(find.text('준비 중'), findsWidgets);
    expect(find.text('DVA-C02'), findsWidgets);
  });

  testWidgets('학습문서만 cert(SAA): 학습 섹션 노출 + 문항 준비 중 라벨', (tester) async {
    await tester.pumpWidget(_home());
    await tester.pump();

    // 문항 0 cert는 '문항 준비 중' 라벨로 학습문서 섹션에 노출.
    expect(find.textContaining('문항 준비 중'), findsWidgets);
  });
}
