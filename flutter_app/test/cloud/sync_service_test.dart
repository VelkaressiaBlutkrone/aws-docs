// flutter_app/test/cloud/sync_service_test.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/history_store.dart';
import 'package:aws_docs/data/plan_check_store.dart';
import 'package:aws_docs/data/viewed_docs_store.dart';
import 'package:aws_docs/data/cloud/cloud_store.dart';
import 'package:aws_docs/data/cloud/sync_merge.dart';
import 'package:aws_docs/data/cloud/sync_meta.dart';
import 'package:aws_docs/data/cloud/sync_service.dart';
import 'package:aws_docs/models/attempt_record.dart';

/// loadCollection을 컬렉션별로 멈춰 세우는 CloudStore — 네트워크 왕복 구간에
/// 사용자 쓰기가 끼어드는 경합을 결정적으로 재현한다(CODE-D-004).
class _GatedCloud implements CloudStore {
  _GatedCloud(this.inner);
  final FakeCloudStore inner;
  final _gates = <String, Completer<void>>{};
  final _reached = <String, Completer<void>>{};

  /// 다음 [collection] 로드를 멈춘다. 로드가 게이트에 닿으면 reached가 완료되고,
  /// gate를 complete하면 로드가 재개된다.
  ({Completer<void> gate, Future<void> reached}) arm(String collection) {
    final reached = _reached[collection] = Completer<void>();
    final gate = _gates[collection] = Completer<void>();
    return (gate: gate, reached: reached.future);
  }

  @override
  Future<Map<String, Map<String, dynamic>>> loadCollection(
      String uid, String collection) async {
    final gate = _gates.remove(collection);
    if (gate != null) {
      _reached.remove(collection)!.complete();
      await gate.future;
    }
    return inner.loadCollection(uid, collection);
  }

  @override
  Future<void> setDoc(String uid, String collection, String docId,
          Map<String, dynamic> data) =>
      inner.setDoc(uid, collection, docId, data);

  @override
  Future<void> deleteDoc(String uid, String collection, String docId) =>
      inner.deleteDoc(uid, collection, docId);

  @override
  Stream<Map<String, Map<String, dynamic>>> watchCollection(
          String uid, String collection) =>
      inner.watchCollection(uid, collection);
}

/// 쓰기 키를 기록하는 백엔드(무변경 reconcile의 재기록 여부 확인용).
class _CountingBackend extends MemoryBackend {
  final writes = <String>[];
  @override
  void write(String key, String value) {
    writes.add(key);
    super.write(key, value);
  }
}

AttemptRecord _attempt(String date) => AttemptRecord(
      certId: 'CLF-C02',
      examId: 'exam:clf-t1-1',
      mode: 'exam',
      date: date,
      correct: 1,
      total: 2,
      wrongQuestionIds: const ['q2'],
      flaggedQuestionIds: const [],
      durationSpentSec: 60,
    );

void main() {
  test('reconcileAll: 로컬·클라우드 attempts union이 로컬·클라우드 양쪽에 반영', () async {
    final local = MemoryBackend();
    // 로컬 history 1건
    local.write('awsdocs.history.v1', jsonEncode([
      {'certId': 'CLF-C02', 'examId': 'exam:CLF-C02-mock', 'mode': 'exam',
       'date': '2026-06-10T09:00:00.000', 'correct': 1, 'total': 1,
       'wrongQuestionIds': [], 'flaggedQuestionIds': [], 'durationSpentSec': 1}
    ]));
    final cloud = FakeCloudStore();
    // 클라우드 attempts 1건(다른 응시)
    await cloud.setDoc('u1', 'attempts', 'k-cloud', {
      'certId': 'CLF-C02', 'examId': 'exam:CLF-C02-weak', 'mode': 'exam',
      'date': '2026-06-11T08:00:00.000', 'correct': 1, 'total': 1,
      'wrongQuestionIds': [], 'flaggedQuestionIds': [], 'durationSpentSec': 1,
    });

    final svc = SyncService(local: local, cloud: cloud, nowMs: () => 1000);
    await svc.reconcileAll('u1');

    // 로컬 history = 2건(union·무손실)
    final localList = jsonDecode(local.read('awsdocs.history.v1')!) as List;
    expect(localList.length, 2);
    // 내용 검증: 두 응시 모두 보존(키 충돌로 한쪽이 사라지지 않음)
    final examIds =
        localList.map((e) => (e as Map)['examId'] as String).toSet();
    expect(examIds, {'exam:CLF-C02-mock', 'exam:CLF-C02-weak'});
    // 클라우드 attempts = 2건(로컬 신규 push됨)
    expect((await cloud.loadCollection('u1', 'attempts')).length, 2);
  });

  test('reconcileAll: viewed set union이 로컬·클라우드 양쪽에 반영', () async {
    final local = MemoryBackend();
    local.write('awsdocs.viewed.v1', jsonEncode({
      'CLF-C02': {'t1': 10, 't2': 20}
    }));
    final cloud = FakeCloudStore();
    await cloud.setDoc('u1', 'viewed', 'CLF-C02', {
      'items': {'t2': 20, 't3': 30}
    });
    final svc = SyncService(local: local, cloud: cloud, nowMs: () => 1000);
    await svc.reconcileAll('u1');
    final lv =
        (jsonDecode(local.read('awsdocs.viewed.v1')!) as Map)['CLF-C02'] as Map;
    expect(lv.keys.toSet(), {'t1', 't2', 't3'}); // 로컬 합집합
    final cv = (await cloud.loadCollection('u1', 'viewed'))['CLF-C02']!['items']
        as Map;
    expect(cv.keys.toSet(), {'t1', 't2', 't3'}); // 클라우드 합집합
  });

  test('reconcileAll: 두 번 호출해도 멱등(중복·재push 없음)', () async {
    final local = MemoryBackend();
    local.write('awsdocs.history.v1', jsonEncode([
      {'certId': 'CLF-C02', 'examId': 'exam:CLF-C02-mock', 'mode': 'exam',
       'date': '2026-06-10T09:00:00.000', 'correct': 1, 'total': 1,
       'wrongQuestionIds': [], 'flaggedQuestionIds': [], 'durationSpentSec': 1}
    ]));
    final cloud = FakeCloudStore();
    final svc = SyncService(local: local, cloud: cloud, nowMs: () => 1000);
    await svc.reconcileAll('u1');
    await svc.reconcileAll('u1'); // 2회차
    expect((jsonDecode(local.read('awsdocs.history.v1')!) as List).length, 1);
    expect((await cloud.loadCollection('u1', 'attempts')).length, 1);
  });

  // 일정(plans)은 PR2에서 3-way 경로로 옮겨갔다(test/cloud/sync_plans_test.dart).
  // 레거시 LWW 경로는 checks만 쓰므로 아래 회귀는 checks로 지킨다.
  test('reconcileAll: 손상 사이드카 stamp가 reconcile를 중단시키지 않음', () async {
    final local = MemoryBackend();
    local.write('awsdocs.plan.checks.v1', jsonEncode({
      'CLF-C02': {'x': true}
    }));
    local.write('awsdocs.sync.v1', jsonEncode({
      'checks': {'CLF-C02': 'oops'} // 손상 stamp(숫자 아님)
    }));
    final cloud = FakeCloudStore();
    final svc = SyncService(local: local, cloud: cloud, nowMs: () => 5000);
    await svc.reconcileAll('u1'); // 예외 없이 완료(손상 stamp는 미스탬프로 강등)
    // now(5000)로 스탬프 후 push
    final cc = await cloud.loadCollection('u1', 'checks');
    expect(cc.containsKey('CLF-C02'), isTrue);
    expect(cc['CLF-C02']!['updatedAt'], 5000);
  });

  test('reconcileAll: checks LWW — 사이드카 없던 로컬은 now로 스탬프 후 push', () async {
    final local = MemoryBackend();
    local.write('awsdocs.plan.checks.v1', jsonEncode({
      'CLF-C02': {'x': true}
    }));
    final cloud = FakeCloudStore();
    final svc = SyncService(local: local, cloud: cloud, nowMs: () => 5000);
    await svc.reconcileAll('u1');
    final cc = await cloud.loadCollection('u1', 'checks');
    expect(cc.containsKey('CLF-C02'), isTrue);
    expect(cc['CLF-C02']!['updatedAt'], 5000);
    // 사이드카 기록됨
    final meta = jsonDecode(local.read('awsdocs.sync.v1')!) as Map;
    expect((meta['checks'] as Map)['CLF-C02'], 5000);
  });

  group('reconcile 경합 — 클라우드 로드 대기 중 사용자 쓰기 보존(CODE-D-004)', () {
    test('attempts: 대기 중 제출된 응시가 로컬에 남고 같은 회차에 push된다', () async {
      final local = MemoryBackend();
      final cloud = _GatedCloud(FakeCloudStore());
      final svc = SyncService(local: local, cloud: cloud, nowMs: () => 1000);
      HistoryStore(backend: local).add(_attempt('2026-09-22T10:00:00.000'));

      final g = cloud.arm('attempts');
      final run = svc.reconcileAll('u1');
      await g.reached;
      HistoryStore(backend: local).add(_attempt('2026-09-22T10:05:00.000'));
      g.gate.complete();
      await run;

      expect(HistoryStore(backend: local).all().map((r) => r.date).toSet(),
          {'2026-09-22T10:00:00.000', '2026-09-22T10:05:00.000'});
      expect((await cloud.inner.loadCollection('u1', 'attempts')).length, 2);
    });

    test('viewed: 대기 중 열람한 Task가 로컬·클라우드에 남는다', () async {
      final local = MemoryBackend();
      final cloud = _GatedCloud(FakeCloudStore());
      final svc = SyncService(local: local, cloud: cloud, nowMs: () => 1000);
      ViewedDocsStore(backend: local).markViewed('CLF-C02', 't1');

      final g = cloud.arm('viewed');
      final run = svc.reconcileAll('u1');
      await g.reached;
      ViewedDocsStore(backend: local).markViewed('CLF-C02', 't2');
      g.gate.complete();
      await run;

      expect(ViewedDocsStore(backend: local).viewed('CLF-C02'), {'t1', 't2'});
      final cv = (await cloud.inner.loadCollection('u1', 'viewed'))['CLF-C02']![
          'items'] as Map;
      expect(cv.keys.toSet(), {'t1', 't2'});
    });

    test('checks(LWW): 대기 중 수동 체크가 로컬·클라우드에 남는다', () async {
      final local = MemoryBackend();
      final cloud = _GatedCloud(FakeCloudStore());
      final svc = SyncService(local: local, cloud: cloud, nowMs: () => 5000);

      final g = cloud.arm('checks');
      final run = svc.reconcileAll('u1');
      await g.reached;
      PlanCheckStore(backend: local).set('CLF-C02', 'item-1', true);
      g.gate.complete();
      await run;

      expect(PlanCheckStore(backend: local).overrides('CLF-C02'),
          {'item-1': true});
      final cc = await cloud.inner.loadCollection('u1', 'checks');
      expect(cc['CLF-C02'], {'item-1': true, 'updatedAt': 5000});
    });
  });

  group('삭제 표식(meta/deletions)', () {
    test('로컬 표식이 클라우드에 올라가고 옛 응시·열람이 양쪽에서 지워진다', () async {
      final local = MemoryBackend();
      final cloud = FakeCloudStore();
      HistoryStore(backend: local, nowMs: () => 1000)
          .add(_attempt('2026-09-01T00:00:00.000'));
      ViewedDocsStore(backend: local, nowMs: () => 1000)
          .markViewed('CLF-C02', 'clf-t1-1');
      final svc = SyncService(local: local, cloud: cloud, nowMs: () => 5000);
      await svc.reconcileAll('u1'); // 1회차: 클라우드로 push

      SyncMeta(local).markReset('CLF-C02', 3000); // 초기화 표식
      HistoryStore(backend: local).clearCert('CLF-C02');
      ViewedDocsStore(backend: local).clearCert('CLF-C02');

      await svc.reconcileAll('u1');

      expect(HistoryStore(backend: local).all(), isEmpty);
      expect(await cloud.loadCollection('u1', 'attempts'), isEmpty);
      expect(await cloud.loadCollection('u1', 'viewed'), isEmpty);
      final marks =
          (await cloud.loadCollection('u1', 'meta'))['deletions']!['resetAt'];
      expect((marks as Map)['CLF-C02'], 3000);
    });

    test('다른 기기의 표식을 받아 로컬을 정리한다', () async {
      final local = MemoryBackend();
      final cloud = FakeCloudStore();
      HistoryStore(backend: local, nowMs: () => 1000)
          .add(_attempt('2026-09-01T00:00:00.000'));
      await cloud.setDoc('u1', 'meta', 'deletions', {
        'resetAt': {'CLF-C02': 3000}
      });

      await SyncService(local: local, cloud: cloud, nowMs: () => 5000)
          .reconcileAll('u1');

      expect(HistoryStore(backend: local).all(), isEmpty);
      expect(SyncMeta(local).resetAt['CLF-C02'], 3000);
    });

    test('표식 이후에 만든 기록은 살아남는다', () async {
      final local = MemoryBackend();
      final cloud = FakeCloudStore();
      HistoryStore(backend: local, nowMs: () => 9000)
          .add(_attempt('2026-09-23T00:00:00.000'));
      await cloud.setDoc('u1', 'meta', 'deletions', {
        'resetAt': {'CLF-C02': 3000}
      });

      await SyncService(local: local, cloud: cloud, nowMs: () => 9500)
          .reconcileAll('u1');

      expect(HistoryStore(backend: local).all().single.createdAtMs, 9000);
      expect((await cloud.loadCollection('u1', 'attempts')).length, 1);
    });

    test('정리 삭제는 한 회차 50건까지만 한다', () async {
      final local = MemoryBackend();
      final cloud = FakeCloudStore();
      for (var i = 0; i < 60; i++) {
        final r = _attempt(
                '2026-09-01T00:00:${i.toString().padLeft(2, '0')}.000')
            .withCreatedAtMs(1000);
        await cloud.setDoc('u1', 'attempts', attemptKey(r), r.toJson());
      }
      SyncMeta(local).markReset('CLF-C02', 3000);

      await SyncService(local: local, cloud: cloud, nowMs: () => 5000)
          .reconcileAll('u1');

      expect((await cloud.loadCollection('u1', 'attempts')).length, 10);
    });
  });

  test('reconcileAll: 양쪽이 이미 같으면 로컬 키를 다시 쓰지 않는다', () async {
    final local = _CountingBackend();
    HistoryStore(backend: local).add(_attempt('2026-09-22T10:00:00.000'));
    ViewedDocsStore(backend: local).markViewed('CLF-C02', 't1');
    PlanCheckStore(backend: local).set('CLF-C02', 'item-1', true);
    final svc =
        SyncService(local: local, cloud: FakeCloudStore(), nowMs: () => 1000);
    await svc.reconcileAll('u1'); // 1회차: push + 사이드카 스탬프
    local.writes.clear();

    await svc.reconcileAll('u1'); // 2회차: 변경 없음

    expect(local.writes, isEmpty);
  });
}
