import 'dart:convert';

import 'package:aws_docs/data/study_plan_store.dart';
import 'package:aws_docs/models/study_plan.dart';
import 'package:flutter_test/flutter_test.dart';

StudyPlan _plan(String id, String cert, {String label = ''}) => StudyPlan(
      id: id,
      label: label,
      certCode: cert,
      startIso: '2026-06-19',
      endIso: '2026-06-26',
      mode: PlanMode.period,
      createdIso: '2026-06-19',
      items: const [],
    );

void main() {
  test('add/plansFor/update/removePlan', () {
    final s = StudyPlanStore(backend: MemoryBackend());
    expect(s.plansFor('CLF-C02'), isEmpty);

    s.add(_plan('', 'CLF-C02', label: 'A')); // id 자동 부여
    final after = s.plansFor('CLF-C02');
    expect(after.length, 1);
    expect(after.first.id, isNotEmpty);
    expect(after.first.label, 'A');

    final id = after.first.id;
    s.update(StudyPlan(
        id: id,
        label: 'A2',
        certCode: 'CLF-C02',
        startIso: '2026-06-19',
        endIso: '2026-06-26',
        mode: PlanMode.period,
        createdIso: '2026-06-19',
        items: const []));
    expect(s.plansFor('CLF-C02').single.label, 'A2');

    s.removePlan('CLF-C02', id);
    expect(s.plansFor('CLF-C02'), isEmpty);
  });

  test('두 일정이 독립적으로 공존', () {
    final s = StudyPlanStore(backend: MemoryBackend());
    s.add(_plan('', 'CLF-C02', label: 'A'));
    s.add(_plan('', 'CLF-C02', label: 'B'));
    expect(s.plansFor('CLF-C02').map((p) => p.label), ['A', 'B']);
  });

  test('clearCert 격리', () {
    final b = MemoryBackend();
    StudyPlanStore(backend: b)
      ..add(_plan('', 'CLF-C02'))
      ..add(_plan('', 'SAA-C03'));
    StudyPlanStore(backend: b).clearCert('CLF-C02');
    expect(StudyPlanStore(backend: b).plansFor('CLF-C02'), isEmpty);
    expect(StudyPlanStore(backend: b).plansFor('SAA-C03'), isNotEmpty);
  });

  test('v1 단일 plan을 v2 리스트로 마이그레이션', () {
    final b = MemoryBackend();
    b.write(
        'awsdocs.plan.v1',
        jsonEncode({
          'CLF-C02': {
            'certCode': 'CLF-C02',
            'startIso': '2026-06-01',
            'endIso': '2026-06-15',
            'mode': 'period',
            'createdIso': '2026-06-01',
            'items': [],
          }
        }));
    final s = StudyPlanStore(backend: b);
    final plans = s.plansFor('CLF-C02');
    expect(plans.length, 1);
    expect(plans.first.id, isNotEmpty);
    expect(plans.first.source, PlanSource.auto);
    expect(b.read('awsdocs.plan.v2'), isNotNull);
  });

  test('손상 v2 데이터는 빈 리스트', () {
    final b = MemoryBackend()..write('awsdocs.plan.v2', '{bad');
    expect(StudyPlanStore(backend: b).plansFor('CLF-C02'), isEmpty);
  });
}
