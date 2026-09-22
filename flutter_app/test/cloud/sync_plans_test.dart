import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/cloud/cloud_store.dart';
import 'package:aws_docs/data/cloud/sync_meta.dart';
import 'package:aws_docs/data/cloud/sync_service.dart';
import 'package:aws_docs/data/study_plan_store.dart';
import 'package:aws_docs/models/study_plan.dart';

StudyPlan _plan(String id, String cert, String label) => StudyPlan(
      id: id,
      label: label,
      certCode: cert,
      startIso: '2026-09-01',
      endIso: '2026-10-01',
      mode: PlanMode.period,
      createdIso: '2026-09-01',
      items: const [],
    );

void main() {
  test('로컬 일정이 클라우드로 올라간다(updatedAtMs 포함)', () async {
    final local = MemoryBackend();
    final cloud = FakeCloudStore();
    StudyPlanStore(backend: local).add(_plan('', 'CLF-C02', 'A'));
    final id = StudyPlanStore(backend: local).plansFor('CLF-C02').single.id;

    await SyncService(local: local, cloud: cloud, nowMs: () => 5000)
        .reconcileAll('u1');

    final doc = (await cloud.loadCollection('u1', 'plans'))[id]!;
    expect(doc['label'], 'A');
    expect(doc['updatedAtMs'], 5000);
    expect(SyncMeta(local).entity('plans').base[id]!['label'], 'A');
  });

  test('클라우드 일정이 로컬로 내려온다', () async {
    final local = MemoryBackend();
    final cloud = FakeCloudStore();
    final p = _plan('CLF-C02:2026-09-01:0', 'CLF-C02', 'B');
    await cloud.setDoc('u1', 'plans', p.id, {...p.toJson(), 'updatedAtMs': 100});

    await SyncService(local: local, cloud: cloud, nowMs: () => 5000)
        .reconcileAll('u1');

    expect(StudyPlanStore(backend: local).plansFor('CLF-C02').single.label, 'B');
  });

  test('로컬에서 고친 일정이 다음 동기에 되돌아가지 않는다', () async {
    final local = MemoryBackend();
    final cloud = FakeCloudStore();
    StudyPlanStore(backend: local).add(_plan('', 'CLF-C02', 'A'));
    final id = StudyPlanStore(backend: local).plansFor('CLF-C02').single.id;
    final svc = SyncService(local: local, cloud: cloud, nowMs: () => 5000);
    await svc.reconcileAll('u1'); // 1회차: push

    StudyPlanStore(backend: local).upsert(_plan(id, 'CLF-C02', 'A2'));
    await svc.reconcileAll('u1'); // 2회차: 로컬 변경 감지 → push

    expect(
        StudyPlanStore(backend: local).plansFor('CLF-C02').single.label, 'A2');
    expect((await cloud.loadCollection('u1', 'plans'))[id]!['label'], 'A2');
  });

  test('자격증 초기화 표식보다 오래된 클라우드 일정은 지운다', () async {
    final local = MemoryBackend();
    final cloud = FakeCloudStore();
    final p = _plan('CLF-C02:2026-09-01:0', 'CLF-C02', 'old');
    await cloud.setDoc('u1', 'plans', p.id, {...p.toJson(), 'updatedAtMs': 100});
    SyncMeta(local).markReset('CLF-C02', 3000);

    await SyncService(local: local, cloud: cloud, nowMs: () => 5000)
        .reconcileAll('u1');

    expect(await cloud.loadCollection('u1', 'plans'), isEmpty);
    expect(StudyPlanStore(backend: local).plansFor('CLF-C02'), isEmpty);
  });
}
