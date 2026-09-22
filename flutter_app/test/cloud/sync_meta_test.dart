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
}
