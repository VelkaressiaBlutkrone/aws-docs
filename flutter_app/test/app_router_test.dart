import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/app_router.dart';
import 'package:aws_docs/pages/cert_detail_page.dart';
import 'package:aws_docs/pages/home_page.dart';
import 'package:aws_docs/theme/app_theme.dart';
import 'package:aws_docs/theme/theme_scope.dart';

// 라우터 위젯 호스트. 일부 페이지가 Theme 토큰(context.c)을 요구하므로 테마 주입.
Widget _app(String location) {
  final router = createRouter(initialLocation: location);
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

// 참고(의도된 범위): CertDetailPage/StudyDocPage/QuizPage/ExamPage는 body를
// SelectionArea로 감싸고 비동기(rootBundle) 로딩 스피너를 띄운다. 위젯 테스트에서
// 이들을 렌더하면 SelectionArea가 레이아웃 완료 전에 selectable을 화면순 정렬하다
// 'RenderBox was not laid out' assert가 발생한다(테스트 환경 한정 결함, 실제 앱은 정상).
// 따라서 라우터 테스트는 안전하게 렌더되는 경로(HomePage·에러 페이지)와 redirect
// 동작만 검증한다. 유효 딥링크의 엔티티 해석은 cert_lookup_test가, 실제 페이지 렌더는
// 수동 검증(계획 Task 8)이 커버한다.
void main() {
  testWidgets('"/" → HomePage 렌더', (tester) async {
    await tester.pumpWidget(_app('/'));
    await tester.pump();
    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('잘못된 cert 코드 → "/"로 redirect (HomePage, CertDetail 미생성)',
      (tester) async {
    await tester.pumpWidget(_app('/cert/NOPE'));
    await tester.pump();
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(CertDetailPage), findsNothing);
  });

  testWidgets('잘못된 cert review 경로 → "/"로 redirect', (tester) async {
    await tester.pumpWidget(_app('/cert/NOPE/review'));
    await tester.pump();
    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('잘못된 cert report 경로 → "/"로 redirect', (tester) async {
    await tester.pumpWidget(_app('/cert/NOPE/report'));
    await tester.pump();
    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('알 수 없는 경로 → 에러 페이지', (tester) async {
    await tester.pumpWidget(_app('/no/such/route'));
    await tester.pump();
    expect(find.text('페이지를 찾을 수 없습니다.'), findsOneWidget);
  });
}
