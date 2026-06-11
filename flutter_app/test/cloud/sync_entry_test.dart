import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/local_kv.dart';
import 'package:aws_docs/data/cloud/auth_service.dart';
import 'package:aws_docs/data/cloud/cloud_store.dart';
import 'package:aws_docs/data/cloud/sync_controller.dart';
import 'package:aws_docs/pages/sync_entry.dart';
import 'package:aws_docs/theme/app_theme.dart';
import 'package:aws_docs/theme/theme_scope.dart';

Widget _host(SyncController? ctrl) => ThemeScope(
      isDark: false,
      toggle: () {},
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: SyncEntry(controller: ctrl)),
      ),
    );

void main() {
  testWidgets('미설정(controller null): 비활성 안내', (tester) async {
    await tester.pumpWidget(_host(null));
    expect(find.textContaining('동기'), findsWidgets);
  });

  testWidgets('비로그인: "Google로 동기 켜기" 표시 → 탭 시 로그인', (tester) async {
    final ctrl = SyncController(
        auth: FakeAuthService(),
        cloud: FakeCloudStore(),
        local: MemoryBackend(),
        nowMs: () => 1000);
    ctrl.start();
    await tester.pumpWidget(_host(ctrl));
    expect(find.textContaining('Google'), findsOneWidget);
    await tester.tap(find.textContaining('Google'));
    await tester.pumpAndSettle();
    // 로그인 후 이메일 표시
    expect(find.textContaining('test@example.com'), findsOneWidget);
  });
}
