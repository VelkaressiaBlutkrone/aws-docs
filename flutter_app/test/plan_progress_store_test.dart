import 'package:aws_docs/data/plan_progress_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('setDone/donePlan/clearPlan — planId 격리', () {
    final s = PlanProgressStore(backend: MemoryBackend());
    s.setDone('p1', 'p1#doc:clf-t1-1:0', true);
    s.setDone('p2', 'p2#doc:clf-t1-1:0', true);
    expect(s.donePlan('p1'), {'p1#doc:clf-t1-1:0'});
    expect(s.donePlan('p2'), {'p2#doc:clf-t1-1:0'});

    s.clearPlan('p1'); // p1만 초기화
    expect(s.donePlan('p1'), isEmpty);
    expect(s.donePlan('p2'), {'p2#doc:clf-t1-1:0'}); // p2 보존
  });

  test('setDone false는 항목 제거', () {
    final s = PlanProgressStore(backend: MemoryBackend());
    s.setDone('p1', 'x', true);
    s.setDone('p1', 'x', false);
    expect(s.donePlan('p1'), isEmpty);
  });

  test('빈 planId는 빈 집합', () {
    final s = PlanProgressStore(backend: MemoryBackend());
    expect(s.donePlan('nope'), isEmpty);
  });
}
