import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/plan_check_store.dart';

void main() {
  test('set·overrides 왕복', () {
    final s = PlanCheckStore(backend: MemoryBackend());
    expect(s.overrides('CLF-C02'), isEmpty);
    s.set('CLF-C02', 'item-a', true);
    s.set('CLF-C02', 'item-b', false);
    expect(s.overrides('CLF-C02'), {'item-a': true, 'item-b': false});
  });

  test('null 설정은 오버라이드 해제', () {
    final s = PlanCheckStore(backend: MemoryBackend());
    s.set('CLF-C02', 'item-a', true);
    s.set('CLF-C02', 'item-a', null);
    expect(s.overrides('CLF-C02'), isEmpty);
  });

  test('clearCert 격리 + 손상 데이터 빈 결과', () {
    final b = MemoryBackend();
    PlanCheckStore(backend: b).set('CLF-C02', 'x', true);
    PlanCheckStore(backend: b).set('SAA-C03', 'y', true);
    PlanCheckStore(backend: b).clearCert('CLF-C02');
    expect(PlanCheckStore(backend: b).overrides('CLF-C02'), isEmpty);
    expect(PlanCheckStore(backend: b).overrides('SAA-C03'), {'y': true});

    final bad = MemoryBackend()..write('awsdocs.plan.checks.v1', 'nope');
    expect(PlanCheckStore(backend: bad).overrides('CLF-C02'), isEmpty);
  });
}
