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
    // 클라우드 attempts = 2건(로컬 신규 push됨)
    expect((await cloud.loadCollection('u1', 'attempts')).length, 2);
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
