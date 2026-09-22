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

  group('clearAll과 레거시 v1', () {
    const v1 = {
      'CLF-C02': {
        'certCode': 'CLF-C02',
        'startIso': '2026-06-01',
        'endIso': '2026-06-15',
        'mode': 'period',
        'createdIso': '2026-06-01',
        'items': [],
      }
    };

    test('clearAll 뒤 v1이 다시 채워져도(동기 복원) 재이관하지 않는다', () {
      final b = MemoryBackend()..write('awsdocs.plan.v1', jsonEncode(v1));
      expect(StudyPlanStore(backend: b).plansFor('CLF-C02'), hasLength(1));

      StudyPlanStore(backend: b).clearAll();
      b.write('awsdocs.plan.v1', jsonEncode(v1)); // 클라우드 plans 동기가 v1을 되돌려 놓음

      expect(StudyPlanStore(backend: b).plansFor('CLF-C02'), isEmpty);
    });

    test('clearAll은 레거시 v1 원본도 지운다', () {
      final b = MemoryBackend()..write('awsdocs.plan.v1', jsonEncode(v1));
      StudyPlanStore(backend: b).clearAll();
      expect(b.read('awsdocs.plan.v1'), isEmpty);
    });
  });

  group('동기용 접근자', () {
    test('byId: 모든 자격증의 일정을 planId로 색인한다', () {
      final b = MemoryBackend();
      StudyPlanStore(backend: b)
        ..add(_plan('', 'CLF-C02', label: 'A'))
        ..add(_plan('', 'SAA-C03', label: 'B'));
      final byId = StudyPlanStore(backend: b).byId();
      expect(byId.length, 2);
      expect(byId.values.map((p) => p.label).toSet(), {'A', 'B'});
      expect(byId.keys.every((id) => id.isNotEmpty), isTrue);
    });

    test('upsert: 같은 id는 교체, 없으면 추가', () {
      final b = MemoryBackend();
      final s = StudyPlanStore(backend: b);
      s.add(_plan('', 'CLF-C02', label: 'A'));
      final id = s.plansFor('CLF-C02').single.id;

      s.upsert(_plan(id, 'CLF-C02', label: 'A2'));
      expect(s.plansFor('CLF-C02').single.label, 'A2');

      s.upsert(_plan('other', 'CLF-C02', label: 'B'));
      expect(s.plansFor('CLF-C02').length, 2);
    });

    test('removeById: 자격증을 몰라도 지운다', () {
      final b = MemoryBackend();
      final s = StudyPlanStore(backend: b);
      s.add(_plan('', 'SAA-C03', label: 'B'));
      final id = s.plansFor('SAA-C03').single.id;

      s.removeById(id);

      expect(s.plansFor('SAA-C03'), isEmpty);
      expect(s.byId(), isEmpty);
    });
  });
}
