// 경로 파라미터만 바뀌는 전환에서 State 가 재사용되는 결함의 전수 가드 (2026-11-18).
//
// `cert_exam_route_identity_test.dart` 가 모의고사 라우트에서 찾은 결함과 같은 모양이다:
// 페이지가 `late Future _future = _load()` 로 **State 생성 때 한 번만** 데이터를 읽고
// (`_load()` 가 `widget.cert.code`·`widget.entry` 로 무엇을 읽을지 정한다) 라우트 빌더가
// key 를 주지 않으면, 주소의 코드나 taskId 만 바뀌는 전환(go/주소창/뒤로가기)에서
// **이전 State 가 그대로 남아 이전 대상의 데이터를 보여 준다.**
//
// 같은 모양의 라우트 넷을 실제 라우터로 밟아 State 가 새로 만들어지는지 본다:
// 오답 목록 · 약점 리포트 · Task 퀴즈 · Task 시험.
//
// ⚠️ 자격증 오디오 라우트(`cert/:code/audio`)는 여기서 재현할 수 없다 — `audio_lecture`
//    dart-define 이 꺼진 테스트 환경에서는 redirect 가 홈으로 보낸다.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:aws_docs/app_router.dart';
import 'package:aws_docs/pages/exam_page.dart';
import 'package:aws_docs/pages/quiz_page.dart';
import 'package:aws_docs/pages/report_page.dart';
import 'package:aws_docs/pages/review_page.dart';
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
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 20; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();
  }
}

/// [from] 에서 [to] 로 `go` 했을 때 [page] State 가 새로 만들어지는지 본다.
Future<void> _expectFreshState(
  WidgetTester tester, {
  required Type page,
  required String from,
  required String to,
}) async {
  final router = createRouter(initialLocation: from);
  await tester.pumpWidget(_app(router));
  await _settle(tester);
  expect(find.byType(page), findsOneWidget, reason: '대조군: $from 에서 $page 가 렌더돼야 한다');
  final before = tester.state(find.byType(page));

  router.go(to);
  await tester.pump();
  await _settle(tester);

  expect(find.byType(page), findsOneWidget, reason: '$to 에서 $page 가 렌더돼야 한다');
  expect(identical(tester.state(find.byType(page)), before), isFalse,
      reason: '$from → $to: 대상이 바뀌면 State 가 새로 만들어져야 한다(이전 데이터가 남는다)');
}

void main() {
  setUp(rootBundle.clear);

  testWidgets('오답 목록: 자격증이 바뀌면 State 를 새로 만든다', (tester) async {
    await _expectFreshState(tester,
        page: ReviewListPage, from: '/cert/SCS-C03/review', to: '/cert/AIF-C01/review');
  });

  testWidgets('약점 리포트: 자격증이 바뀌면 State 를 새로 만든다', (tester) async {
    await _expectFreshState(tester,
        page: ReportPage, from: '/cert/SCS-C03/report', to: '/cert/AIF-C01/report');
  });

  testWidgets('Task 퀴즈: 문서가 바뀌면 State 를 새로 만든다', (tester) async {
    await _expectFreshState(tester,
        page: QuizPage,
        from: '/cert/AIF-C01/study/aif-t1-1/quiz',
        to: '/cert/AIF-C01/study/aif-t1-2/quiz');
  });

  testWidgets('Task 시험: 문서가 바뀌면 State 를 새로 만든다', (tester) async {
    await _expectFreshState(tester,
        page: ExamPage,
        from: '/cert/AIF-C01/study/aif-t1-1/exam',
        to: '/cert/AIF-C01/study/aif-t1-2/exam');
  });
}
