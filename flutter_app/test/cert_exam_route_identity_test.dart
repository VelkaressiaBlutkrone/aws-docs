// 모의고사 라우트의 자격증 전환 가드 (2026-11-18 라이브 점검에서 발견).
//
// 증상: `/cert/SCS-C03/exam` 에서 주소의 코드만 `AIF-C01` 로 바꾸면 AIF 화면에 SCS 값
// (문항 풀 240개 · 170분 · 6도메인)이 그대로 남았다. 새로고침하면 AIF 값이 맞게 나온다.
//
// 원인: `CertExamPage` 가 `_future = _load()` 를 State 생성 때 한 번만 부르고, 라우트
// 빌더가 key 를 주지 않아 **같은 경로 패턴에서 코드만 바뀌면 State 가 재사용**됐다.
// `StudyDocPage` 라우트는 같은 문제를 `ValueKey` 로 이미 막아 두었다(app_router.dart).
//
// 이 테스트는 실제 증상 경로(라우터로 두 자격증을 오간다)를 그대로 밟는다.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:aws_docs/app_router.dart';
import 'package:aws_docs/pages/cert_exam_page.dart';
import 'package:aws_docs/theme/app_theme.dart';
import 'package:aws_docs/theme/theme_scope.dart';

Widget _app(GoRouter router) => ThemeScope(
      isDark: false,
      toggle: () {},
      child: MaterialApp.router(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        routerConfig: router,
      ),
    );

/// 에셋 로딩(rootBundle)이 끝날 때까지 실제 비동기를 돌리며 펌프한다.
Future<void> _settle(WidgetTester tester, Finder until) async {
  for (var i = 0; i < 50 && until.evaluate().isEmpty; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();
  }
}

void main() {
  setUp(rootBundle.clear);

  // 대조군: 두 자격증의 공식 제한 시간이 서로 달라야 이 가드가 의미를 가진다
  // (SCS-C03 170분 · AIF-C01 90분 — exam_guides/*.json 의 overview).
  testWidgets('통합 모의고사: 같은 라우트에서 자격증이 바뀌면 새 자격증 값을 보인다',
      (tester) async {
    final router = createRouter(initialLocation: '/cert/SCS-C03/exam');
    await tester.pumpWidget(_app(router));
    await _settle(tester, find.text('170분'));
    expect(find.text('170분'), findsOneWidget, reason: '대조군: SCS 시작 화면이 렌더돼야 한다');
    final scsState = tester.state(find.byType(CertExamPage));

    router.go('/cert/AIF-C01/exam');
    await tester.pump();
    await _settle(tester, find.text('90분'));

    expect(find.text('90분'), findsOneWidget, reason: 'AIF-C01 의 제한 시간이 보여야 한다');
    expect(find.text('170분'), findsNothing, reason: 'SCS 값이 남으면 안 된다');
    expect(identical(tester.state(find.byType(CertExamPage)), scsState), isFalse,
        reason: '자격증이 바뀌면 State 가 새로 만들어져야 한다');
  });

  testWidgets('약점 모의고사: 같은 라우트에서 자격증이 바뀌면 State 를 새로 만든다',
      (tester) async {
    final router = createRouter(initialLocation: '/cert/SCS-C03/exam/weak');
    await tester.pumpWidget(_app(router));
    await _settle(tester, find.byType(CertExamPage));
    final before = tester.state(find.byType(CertExamPage));

    router.go('/cert/AIF-C01/exam/weak');
    await tester.pump();
    await _settle(tester, find.byType(CertExamPage));

    expect(identical(tester.state(find.byType(CertExamPage)), before), isFalse);
  });
}
