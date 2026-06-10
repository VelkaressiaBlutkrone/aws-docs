// flutter_app/test/cloud/sync_controller_test.dart
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/local_kv.dart';
import 'package:aws_docs/data/cloud/auth_service.dart';
import 'package:aws_docs/data/cloud/cloud_store.dart';
import 'package:aws_docs/data/cloud/sync_controller.dart';

void main() {
  test('signIn: reconcile로 클라우드 plan이 로컬에 내려옴 + status idle', () async {
    final auth = FakeAuthService();
    final cloud = FakeCloudStore();
    final local = MemoryBackend();
    await cloud.setDoc('u-test', 'plans', 'CLF-C02', {
      'certCode': 'CLF-C02', 'startIso': '2026-06-10', 'endIso': '2026-06-24',
      'mode': 'period', 'createdIso': '2026-06-10', 'items': [], 'updatedAt': 9000,
    });
    final ctrl = SyncController(
        auth: auth, cloud: cloud, local: local, nowMs: () => 1000);
    ctrl.start();
    await ctrl.signIn();
    // 클라우드 plan이 로컬 블롭에 반영
    final plans = jsonDecode(local.read('awsdocs.plan.v1')!) as Map;
    expect(plans.containsKey('CLF-C02'), isTrue);
    expect(ctrl.user?.email, 'test@example.com');
    expect(ctrl.status, SyncStatus.idle);
  });

  test('signOut: status off·user null', () async {
    final ctrl = SyncController(
        auth: FakeAuthService(), cloud: FakeCloudStore(),
        local: MemoryBackend(), nowMs: () => 1000);
    ctrl.start();
    await ctrl.signIn();
    await ctrl.signOut();
    expect(ctrl.user, isNull);
    expect(ctrl.status, SyncStatus.off);
  });

  test('sync 재진입 가드: 동시 호출이 겹쳐도 예외 없이 완료', () async {
    final auth = FakeAuthService();
    final cloud = FakeCloudStore();
    final local = MemoryBackend();
    final ctrl = SyncController(
        auth: auth, cloud: cloud, local: local, nowMs: () => 1000);
    ctrl.start();
    await ctrl.signIn();
    await Future.wait<void>([ctrl.sync(), ctrl.sync(), ctrl.sync()]);
    expect(ctrl.status, SyncStatus.idle);
  });
}
