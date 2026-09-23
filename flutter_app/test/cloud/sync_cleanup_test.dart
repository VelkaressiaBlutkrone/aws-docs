import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/cloud/cloud_store.dart';
import 'package:aws_docs/data/cloud/sync_meta.dart';
import 'package:aws_docs/data/cloud/sync_service.dart';
import 'package:aws_docs/data/plan_check_store.dart'; // KvBackend도 re-export

void main() {
  group('레거시 checks 정리', () {
    test('클라우드 checks 문서를 한 번 지우고, 로컬 체크는 건드리지 않는다', () async {
      final local = MemoryBackend();
      final cloud = FakeCloudStore();
      PlanCheckStore(backend: local).set('CLF-C02', 'x', true);
      await cloud.setDoc('u1', 'checks', 'CLF-C02', {'x': true});

      await SyncService(local: local, cloud: cloud, nowMs: () => 5000)
          .reconcileAll('u1');

      expect(await cloud.loadCollection('u1', 'checks'), isEmpty);
      expect(PlanCheckStore(backend: local).overrides('CLF-C02'), {'x': true});
      expect(SyncMeta(local).checksPurged, isTrue);
    });

    test('정리가 끝나면 다시 로드하지 않는다', () async {
      final local = MemoryBackend();
      final cloud = _CountingCloud(FakeCloudStore());
      final svc = SyncService(local: local, cloud: cloud, nowMs: () => 5000);

      await svc.reconcileAll('u1');
      final after = cloud.checksLoads;
      await svc.reconcileAll('u1');

      expect(cloud.checksLoads, after); // 2회차엔 checks를 보지 않는다
    });

    test('로컬 체크는 동기로 올라가지 않는다', () async {
      final local = MemoryBackend();
      final cloud = FakeCloudStore();
      PlanCheckStore(backend: local).set('CLF-C02', 'x', true);

      await SyncService(local: local, cloud: cloud, nowMs: () => 5000)
          .reconcileAll('u1');

      expect(await cloud.loadCollection('u1', 'checks'), isEmpty);
    });

    test('초기화 뒤에는 그 자격증의 일정 표식이 사라진다', () async {
      final local = MemoryBackend();
      SyncMeta(local)
        ..deletedPlans = {'CLF-C02:2026-09-01:0': 1000}
        ..markReset('CLF-C02', 3000);

      await SyncService(local: local, cloud: FakeCloudStore(), nowMs: () => 5000)
          .reconcileAll('u1');

      expect(SyncMeta(local).deletedPlans, isEmpty);
    });

    test('옛 사이드카(awsdocs.sync.v1)를 비운다', () async {
      final local = MemoryBackend()
        ..write('awsdocs.sync.v1', '{"plans":{"CLF-C02":100}}');

      await SyncService(local: local, cloud: FakeCloudStore(), nowMs: () => 5000)
          .reconcileAll('u1');

      expect((local.read('awsdocs.sync.v1') ?? '').isEmpty, isTrue);
    });
  });
}

/// checks 컬렉션 로드 횟수만 센다.
class _CountingCloud implements CloudStore {
  _CountingCloud(this._inner);
  final CloudStore _inner;
  int checksLoads = 0;

  @override
  Future<Map<String, Map<String, dynamic>>> loadCollection(
      String uid, String collection) {
    if (collection == 'checks') checksLoads++;
    return _inner.loadCollection(uid, collection);
  }

  @override
  Future<void> setDoc(String uid, String c, String d, Map<String, dynamic> v) =>
      _inner.setDoc(uid, c, d, v);

  @override
  Future<void> deleteDoc(String uid, String c, String d) =>
      _inner.deleteDoc(uid, c, d);

  @override
  Stream<Map<String, Map<String, dynamic>>> watchCollection(
          String uid, String c) =>
      _inner.watchCollection(uid, c);
}
