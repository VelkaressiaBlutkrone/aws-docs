import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/app_router.dart';
import 'package:aws_docs/data/cert_lookup.dart';
import 'package:aws_docs/data/cloud/auth_service.dart';
import 'package:aws_docs/data/cloud/cloud_store.dart';
import 'package:aws_docs/data/cloud/sync_controller.dart';
import 'package:aws_docs/data/local_kv.dart';
import 'package:aws_docs/main.dart' show syncController;
import 'package:aws_docs/pages/report_page.dart';
import 'package:aws_docs/pages/review_page.dart';
import 'package:aws_docs/theme/app_theme.dart';
import 'package:aws_docs/theme/theme_scope.dart';

// 로그인(기기 간 동기) 중 초기화는 로컬만 지우고, 다음 reconcile이 클라우드
// 백업으로 기록을 되살린다(CODE-D-003). 근본 해결(삭제 표식) 전까지 확인창이
// "되돌릴 수 없습니다" 대신 그 사실을 알려야 한다.

Widget _page(Widget home) => ThemeScope(
      isDark: false,
      toggle: () {},
      child: MaterialApp(theme: AppTheme.light, home: home),
    );

Widget _homeApp() => ThemeScope(
      isDark: false,
      toggle: () {},
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: createRouter(initialLocation: '/'),
      ),
    );

/// 로그인 상태의 전역 동기 컨트롤러를 주입한다(테스트 종료 시 원복).
Future<void> _signIn(WidgetTester tester) async {
  final ctrl = SyncController(
    auth: FakeAuthService(),
    cloud: FakeCloudStore(),
    local: MemoryBackend(),
    nowMs: () => 1000,
  );
  await tester.runAsync(ctrl.signIn);
  syncController.value = ctrl;
  addTearDown(() {
    syncController.value = null;
    ctrl.dispose();
  });
}

Future<void> _openHomeReset(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1200, 1400); // 넓은 폭: 설정 버튼 노출
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(_homeApp());
  await tester.pump();
  await tester.tap(find.byTooltip('설정'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('모든 학습 기록 초기화'));
  await tester.pumpAndSettle();
}

Future<void> _openCertReset(WidgetTester tester, Widget page) async {
  await tester.pumpWidget(_page(page));
  await tester.pump();
  await tester.tap(find.byTooltip('이 자격증 학습 기록 초기화'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  group('초기화 확인창은 로그인 여부와 무관하게 되돌릴 수 없다고 알린다', () {
    testWidgets('홈 — 모든 학습 기록 초기화(로그인)', (tester) async {
      await _signIn(tester);
      await _openHomeReset(tester);
      expect(find.textContaining('되돌릴 수 없'), findsOneWidget);
      expect(find.textContaining('클라우드 백업'), findsNothing);
    });

    testWidgets('약점 리포트 — 자격증 초기화(로그인)', (tester) async {
      await _signIn(tester);
      await _openCertReset(tester, ReportPage(cert: certByCode('CLF-C02')!));
      expect(find.textContaining('되돌릴 수 없'), findsOneWidget);
      expect(find.textContaining('클라우드 백업'), findsNothing);
    });

    testWidgets('오답노트 — 자격증 초기화(로그인)', (tester) async {
      await _signIn(tester);
      await _openCertReset(
          tester, ReviewListPage(cert: certByCode('CLF-C02')!));
      expect(find.textContaining('되돌릴 수 없'), findsOneWidget);
      expect(find.textContaining('클라우드 백업'), findsNothing);
    });

    testWidgets('비로그인 — 모든 학습 기록 초기화', (tester) async {
      await _openHomeReset(tester);
      expect(find.textContaining('되돌릴 수 없'), findsOneWidget);
      expect(find.textContaining('클라우드 백업'), findsNothing);
    });
  });
}
