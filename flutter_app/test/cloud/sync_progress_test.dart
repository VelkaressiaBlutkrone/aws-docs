import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/cloud/cloud_store.dart';
import 'package:aws_docs/data/cloud/sync_service.dart';
import 'package:aws_docs/data/plan_progress_store.dart';
import 'package:aws_docs/data/study_plan_store.dart';
import 'package:aws_docs/models/study_plan.dart';

StudyPlan _plan(String id) => StudyPlan(
      id: id,
      label: 'A',
      certCode: 'CLF-C02',
      startIso: '2026-09-01',
      endIso: '2026-10-01',
      mode: PlanMode.period,
      createdIso: '2026-09-01',
      items: const [],
    );

void main() {
  test('로컬 완료 체크가 클라우드로 올라간다', () async {
    final local = MemoryBackend();
    final cloud = FakeCloudStore();
    StudyPlanStore(backend: local).upsert(_plan('p1'));
    PlanProgressStore(backend: local).setDone('p1', 'i1', true);

    await SyncService(local: local, cloud: cloud, nowMs: () => 5000)
        .reconcileAll('u1');

    final doc = (await cloud.loadCollection('u1', 'progress'))['p1']!;
    expect((doc['itemIds'] as List).toSet(), {'i1'});
    expect(doc['certCode'], 'CLF-C02');
    expect(doc['updatedAtMs'], 5000);
  });

  test('두 기기의 서로 다른 체크·해제를 모두 반영한다(집합 3-way)', () async {
    final a = MemoryBackend();
    final b = MemoryBackend();
    final cloud = FakeCloudStore();
    for (final m in [a, b]) {
      StudyPlanStore(backend: m).upsert(_plan('p1'));
    }
    PlanProgressStore(backend: a)
      ..setDone('p1', 'i1', true)
      ..setDone('p1', 'i2', true);
    await SyncService(local: a, cloud: cloud, nowMs: () => 1000)
        .reconcileAll('u1');
    await SyncService(local: b, cloud: cloud, nowMs: () => 1100)
        .reconcileAll('u1'); // B도 {i1,i2}

    PlanProgressStore(backend: a).setDone('p1', 'i3', true); // A: 추가
    PlanProgressStore(backend: b).setDone('p1', 'i1', false); // B: 해제
    await SyncService(local: a, cloud: cloud, nowMs: () => 2000)
        .reconcileAll('u1');
    await SyncService(local: b, cloud: cloud, nowMs: () => 2100)
        .reconcileAll('u1');
    await SyncService(local: a, cloud: cloud, nowMs: () => 2200)
        .reconcileAll('u1');

    expect(PlanProgressStore(backend: a).donePlan('p1'), {'i2', 'i3'});
    expect(PlanProgressStore(backend: b).donePlan('p1'), {'i2', 'i3'});
  });

  test('일정이 삭제되면 그 진행 문서도 사라진다', () async {
    final local = MemoryBackend();
    final cloud = FakeCloudStore();
    StudyPlanStore(backend: local).upsert(_plan('p1'));
    PlanProgressStore(backend: local).setDone('p1', 'i1', true);
    await SyncService(local: local, cloud: cloud, nowMs: () => 1000)
        .reconcileAll('u1');

    StudyPlanStore(backend: local).removeById('p1');
    await SyncService(local: local, cloud: cloud, nowMs: () => 2000)
        .reconcileAll('u1');

    expect(await cloud.loadCollection('u1', 'progress'), isEmpty);
    expect(PlanProgressStore(backend: local).donePlan('p1'), isEmpty);
  });
}
