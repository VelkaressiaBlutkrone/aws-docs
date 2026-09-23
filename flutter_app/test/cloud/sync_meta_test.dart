import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/cloud/sync_meta.dart';
import 'package:aws_docs/data/local_kv.dart';

void main() {
  test('markReset: 표식을 기록하고 늦은 시각을 유지한다', () {
    final b = MemoryBackend();
    SyncMeta(b).markReset('CLF-C02', 1000);
    SyncMeta(b).markReset('CLF-C02', 500); // 더 이른 시각은 무시
    expect(SyncMeta(b).resetAt, {'CLF-C02': 1000});
  });

  test('effectiveResetAt: 자격증 표식과 전체 표식 중 늦은 쪽', () {
    final b = MemoryBackend();
    SyncMeta(b)
      ..markReset('CLF-C02', 1000)
      ..markReset(SyncMeta.allCerts, 3000);
    expect(SyncMeta(b).effectiveResetAt('CLF-C02'), 3000);
    expect(SyncMeta(b).effectiveResetAt('SAA-C03'), 3000);
  });

  test('mergeResetMarks: 필드별 늦은 시각을 채택한다', () {
    expect(
      mergeResetMarks({'CLF-C02': 1000, 'SAA-C03': 5000}, {'CLF-C02': 2000}),
      {'CLF-C02': 2000, 'SAA-C03': 5000},
    );
  });

  test('손상된 값은 무시하고 나머지를 읽는다', () {
    final b = MemoryBackend()
      ..write('awsdocs.sync.v2', '{"resetAt":{"CLF-C02":"oops","SAA-C03":7}}');
    expect(SyncMeta(b).resetAt, {'SAA-C03': 7});
  });

  test('옛 사이드카(v1)는 건드리지 않는다 — 레거시 LWW 경로가 아직 쓴다', () {
    final b = MemoryBackend()..write('awsdocs.sync.v1', '{"plans":{}}');
    SyncMeta(b).markReset('CLF-C02', 1000);
    expect(b.read('awsdocs.sync.v1'), '{"plans":{}}');
  });

  group('엔티티 부기(base·updatedAt·dirtyAt)', () {
    test('없으면 빈 부기를 돌려준다', () {
      final m = SyncMeta(MemoryBackend()).entity('plans');
      expect(m.base, isEmpty);
      expect(m.updatedAt, isEmpty);
      expect(m.dirtyAt, isEmpty);
    });

    test('저장한 부기를 그대로 읽는다', () {
      final b = MemoryBackend();
      SyncMeta(b).setEntity(
          'plans',
          const EntityMeta(
            base: {
              'p1': {'id': 'p1', 'label': 'A'}
            },
            updatedAt: {'p1': 100},
            dirtyAt: {'p1': 200},
          ));
      final m = SyncMeta(b).entity('plans');
      expect(m.base['p1'], {'id': 'p1', 'label': 'A'});
      expect(m.updatedAt, {'p1': 100});
      expect(m.dirtyAt, {'p1': 200});
    });

    test('종류가 다르면 서로 간섭하지 않고, 표식도 보존된다', () {
      final b = MemoryBackend();
      SyncMeta(b).markReset('CLF-C02', 50);
      SyncMeta(b).setEntity('plans',
          const EntityMeta(base: {}, updatedAt: {'p1': 1}, dirtyAt: {}));
      SyncMeta(b).setEntity('progress',
          const EntityMeta(base: {}, updatedAt: {'p2': 2}, dirtyAt: {}));
      expect(SyncMeta(b).entity('plans').updatedAt, {'p1': 1});
      expect(SyncMeta(b).entity('progress').updatedAt, {'p2': 2});
      expect(SyncMeta(b).resetAt, {'CLF-C02': 50});
    });

    test('손상된 항목은 건너뛴다', () {
      final b = MemoryBackend()
        ..write('awsdocs.sync.v2',
            '{"plans":{"base":{"p1":"oops"},"updatedAt":{"p1":"x","p2":3}}}');
      final m = SyncMeta(b).entity('plans');
      expect(m.base, isEmpty);
      expect(m.updatedAt, {'p2': 3});
    });
  });

  group('prunedPlanMarks', () {
    test('초기화 표식이 덮는 일정 표식은 버린다', () {
      final out = prunedPlanMarks(
        {'CLF-C02:2026-09-01:0': 1000, 'CLF-C02:2026-09-02:0': 4000},
        {'CLF-C02': 3000},
      );
      expect(out.keys, ['CLF-C02:2026-09-02:0']);
    });

    test('전체 초기화(*)도 반영한다', () {
      expect(
        prunedPlanMarks({'SAA-C03:2026-09-01:0': 1000}, {'*': 2000}),
        isEmpty,
      );
    });

    test('표식이 없으면 그대로 둔다', () {
      final m = {'CLF-C02:2026-09-01:0': 1000};
      expect(prunedPlanMarks(m, const {}), m);
    });
  });
}
