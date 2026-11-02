import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aws_docs/data/cloud/auth_service.dart';
import 'package:aws_docs/data/cloud/cloud_store.dart';
import 'package:aws_docs/data/cloud/sync_controller.dart';
import 'package:aws_docs/data/local_kv.dart';
import 'package:aws_docs/pages/sync_entry.dart';
import 'package:aws_docs/theme/app_theme.dart';
import 'package:aws_docs/theme/theme_scope.dart';

/// 리뷰 Minor m-3 — `SyncStatus.error`가 UI에 나타나지 않아 **동기 실패(규칙 거부·
/// 오프라인)를 사용자가 알 수 없었다**(syncing 스피너만 있었다).
///
/// 정본: `docs/audits/2026-09-22-app-code-ux-review.md` m-3.

/// reconcile이 반드시 실패하는 스토어 — `loadCollection`이 던지면
/// `SyncController.sync()`의 catch가 `SyncStatus.error`로 전이한다.
class _FailingCloudStore extends FakeCloudStore {
  @override
  Future<Map<String, Map<String, dynamic>>> loadCollection(
          String uid, String collection) async =>
      throw StateError('규칙 거부 시뮬레이션');
}

Widget _app(SyncController ctrl) => ThemeScope(
      isDark: false,
      toggle: () {},
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SyncEntry(controller: ValueNotifier<SyncController?>(ctrl)),
        ),
      ),
    );

Future<SyncController> _signedIn({required CloudStore cloud}) async {
  final ctrl = SyncController(
    auth: FakeAuthService(),
    cloud: cloud,
    local: MemoryBackend(),
    syncInterval: null, // 주기 트리거 없음 — 테스트 안에서 상태를 고정한다
  );
  await ctrl.signIn();
  return ctrl;
}

void main() {
  const errorLabel = '동기 실패 — 다음 트리거에 재시도';

  testWidgets('동기 실패 상태가 UI에 표시된다', (tester) async {
    final ctrl = await _signedIn(cloud: _FailingCloudStore());
    addTearDown(ctrl.dispose);

    // 전제: 실패 스토어로 로그인하면 컨트롤러가 error로 간다.
    expect(ctrl.status, SyncStatus.error,
        reason: '전제가 깨졌다 — 이 단정이 실패하면 아래 UI 단정은 거짓 통과한다');

    await tester.pumpWidget(_app(ctrl));

    expect(find.bySemanticsLabel(errorLabel), findsOneWidget,
        reason: '동기 실패를 알리는 표시가 없다 — 사용자는 백업이 멈춘 것을 모른다');
  });

  testWidgets('정상 동기에서는 실패 표시가 없다', (tester) async {
    final ctrl = await _signedIn(cloud: FakeCloudStore());
    addTearDown(ctrl.dispose);

    expect(ctrl.status, SyncStatus.idle, reason: '전제: 정상 스토어는 idle로 끝난다');

    await tester.pumpWidget(_app(ctrl));

    expect(find.bySemanticsLabel(errorLabel), findsNothing,
        reason: '정상 상태에 실패 표시가 뜨면 경보 피로가 된다');
    expect(find.textContaining('동기 켜짐'), findsOneWidget);
  });
}
