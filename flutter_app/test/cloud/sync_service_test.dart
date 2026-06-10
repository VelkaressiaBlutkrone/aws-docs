// flutter_app/test/cloud/sync_service_test.dart
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/local_kv.dart';
import 'package:aws_docs/data/cloud/cloud_store.dart';
import 'package:aws_docs/data/cloud/sync_service.dart';

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
      'CLF-C02': ['t1', 't2']
    }));
    final cloud = FakeCloudStore();
    await cloud.setDoc('u1', 'viewed', 'CLF-C02', {
      'taskIds': ['t2', 't3']
    });
    final svc = SyncService(local: local, cloud: cloud, nowMs: () => 1000);
    await svc.reconcileAll('u1');
    final lv =
        (jsonDecode(local.read('awsdocs.viewed.v1')!) as Map)['CLF-C02'] as List;
    expect(lv.toSet(), {'t1', 't2', 't3'}); // 로컬 합집합
    final cv = (await cloud.loadCollection('u1', 'viewed'))['CLF-C02']!['taskIds']
        as List;
    expect(cv.toSet(), {'t1', 't2', 't3'}); // 클라우드 합집합
  });

  test('reconcileAll: plan LWW — 클라우드가 최신이면 로컬을 덮음(push 없음)', () async {
    final local = MemoryBackend();
    local.write('awsdocs.plan.v1', jsonEncode({
      'CLF-C02': {
        'certCode': 'CLF-C02', 'startIso': '2026-06-10', 'endIso': '2026-06-24',
        'mode': 'period', 'createdIso': '2026-06-10', 'items': []
      }
    }));
    local.write('awsdocs.sync.v1', jsonEncode({
      'plans': {'CLF-C02': 100} // 로컬은 오래됨
    }));
    final cloud = FakeCloudStore();
    await cloud.setDoc('u1', 'plans', 'CLF-C02', {
      'certCode': 'CLF-C02', 'startIso': '2026-06-10', 'endIso': '2026-07-01',
      'mode': 'period', 'createdIso': '2026-06-10', 'items': [], 'updatedAt': 9000,
    });
    final svc = SyncService(local: local, cloud: cloud, nowMs: () => 5000);
    await svc.reconcileAll('u1');
    final lp =
        (jsonDecode(local.read('awsdocs.plan.v1')!) as Map)['CLF-C02'] as Map;
    expect(lp['endIso'], '2026-07-01'); // 클라우드 값으로 덮임
    expect(lp.containsKey('updatedAt'), isFalse); // 로컬 doc은 updatedAt 제거
    final meta = jsonDecode(local.read('awsdocs.sync.v1')!) as Map;
    expect((meta['plans'] as Map)['CLF-C02'], 9000); // 사이드카 갱신
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

  test('reconcileAll: plan LWW — 로컬이 최신이면 클라우드로 push', () async {
    final local = MemoryBackend();
    local.write('awsdocs.plan.v1', jsonEncode({
      'CLF-C02': {'certCode': 'CLF-C02', 'startIso': '2026-06-10',
        'endIso': '2026-06-24', 'mode': 'period', 'createdIso': '2026-06-10', 'items': []}
    }));
    final cloud = FakeCloudStore();
    final svc = SyncService(local: local, cloud: cloud, nowMs: () => 5000);
    await svc.reconcileAll('u1');
    // 사이드카가 없던 로컬 plan은 nowMs로 스탬프 후 클라우드에 push
    final cp = await cloud.loadCollection('u1', 'plans');
    expect(cp.containsKey('CLF-C02'), isTrue);
    expect(cp['CLF-C02']!['updatedAt'], 5000);
    // 사이드카 기록됨
    final meta = jsonDecode(local.read('awsdocs.sync.v1')!) as Map;
    expect((meta['plans'] as Map)['CLF-C02'], 5000);
  });
}
