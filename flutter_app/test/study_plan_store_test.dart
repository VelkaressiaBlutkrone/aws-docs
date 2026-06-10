import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/models/study_plan.dart';
import 'package:aws_docs/data/study_plan_store.dart';

StudyPlan _plan(String cert) => StudyPlan(
      certCode: cert,
      startIso: '2026-06-10',
      endIso: '2026-06-24',
      mode: PlanMode.period,
      createdIso: '2026-06-10',
      items: const [],
    );

void main() {
  test('save·planFor 왕복 + 자격증 분리', () {
    final s = StudyPlanStore(backend: MemoryBackend());
    expect(s.planFor('CLF-C02'), isNull);
    s.save(_plan('CLF-C02'));
    s.save(_plan('SAA-C03'));
    expect(s.planFor('CLF-C02')!.endIso, '2026-06-24');
    expect(s.planFor('SAA-C03')!.certCode, 'SAA-C03');
  });

  test('clearCert 격리', () {
    final b = MemoryBackend();
    StudyPlanStore(backend: b)..save(_plan('CLF-C02'))..save(_plan('SAA-C03'));
    StudyPlanStore(backend: b).clearCert('CLF-C02');
    expect(StudyPlanStore(backend: b).planFor('CLF-C02'), isNull);
    expect(StudyPlanStore(backend: b).planFor('SAA-C03'), isNotNull);
  });

  test('손상 데이터는 null', () {
    final b = MemoryBackend()..write('awsdocs.plan.v1', '{bad');
    expect(StudyPlanStore(backend: b).planFor('CLF-C02'), isNull);
  });
}
