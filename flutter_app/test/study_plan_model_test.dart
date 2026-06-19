import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/models/study_plan.dart';

void main() {
  test('PlanItem JSON 왕복', () {
    const it = PlanItem(
      id: 'CLF-C02:doc:clf-t1-1:0',
      dateIso: '2026-06-12',
      type: PlanItemType.doc,
      phase: PlanPhase.learn,
      refId: 'clf-t1-1',
    );
    final back = PlanItem.fromJson(it.toJson());
    expect(back.id, it.id);
    expect(back.dateIso, '2026-06-12');
    expect(back.type, PlanItemType.doc);
    expect(back.phase, PlanPhase.learn);
    expect(back.refId, 'clf-t1-1');
  });

  test('StudyPlan JSON 왕복', () {
    final plan = StudyPlan(
      certCode: 'CLF-C02',
      startIso: '2026-06-10',
      endIso: '2026-06-24',
      mode: PlanMode.examDate,
      createdIso: '2026-06-10',
      items: const [
        PlanItem(
          id: 'CLF-C02:mockExam::0',
          dateIso: '2026-06-20',
          type: PlanItemType.mockExam,
          phase: PlanPhase.mock,
        ),
      ],
    );
    final back = StudyPlan.fromJson(plan.toJson());
    expect(back.certCode, 'CLF-C02');
    expect(back.mode, PlanMode.examDate);
    expect(back.items.single.type, PlanItemType.mockExam);
    expect(back.items.single.refId, isNull);
  });

  test('StudyPlan.fromJson은 손상된 items 항목을 건너뛴다', () {
    final p = StudyPlan.fromJson({
      'certCode': 'CLF-C02',
      'items': [
        null,
        'bad',
        {'id': 'ok', 'dateIso': '2026-01-01', 'type': 'doc', 'phase': 'learn'},
      ],
    });
    expect(p.items.length, 1);
    expect(p.items.single.id, 'ok');
  });

  test('알 수 없는 enum/결손 필드는 안전 기본값', () {
    final it = PlanItem.fromJson({'id': 'x', 'dateIso': '2026-01-01', 'type': '몰라', 'phase': null});
    expect(it.type, PlanItemType.doc); // fallback
    expect(it.phase, PlanPhase.learn); // fallback
    expect(it.refId, isNull);
    final p = StudyPlan.fromJson({'certCode': 'CLF-C02'});
    expect(p.mode, PlanMode.period); // fallback
    expect(p.items, isEmpty);
  });

  test('planIdOf / planItemId 결정적 포맷', () {
    expect(planIdOf('CLF-C02', '2026-06-19', 0), 'CLF-C02:2026-06-19:0');
    expect(planItemId('CLF-C02:2026-06-19:0', PlanItemType.doc, 'clf-t1-1', 2),
        'CLF-C02:2026-06-19:0#doc:clf-t1-1:2');
    expect(planItemId('p1', PlanItemType.mockExam, null, 0), 'p1#mockExam::0');
  });

  test('StudyPlan 신규 필드 round-trip', () {
    final p = StudyPlan(
      id: 'CLF-C02:2026-06-19:0',
      label: '1주차 문서',
      certCode: 'CLF-C02',
      startIso: '2026-06-19',
      endIso: '2026-06-26',
      mode: PlanMode.period,
      createdIso: '2026-06-19',
      source: PlanSource.manual,
      planType: PlanItemType.doc,
      taskIds: const ['clf-t1-1', 'clf-t1-2'],
      items: const [],
    );
    final back = StudyPlan.fromJson(p.toJson());
    expect(back.id, p.id);
    expect(back.label, '1주차 문서');
    expect(back.source, PlanSource.manual);
    expect(back.planType, PlanItemType.doc);
    expect(back.taskIds, ['clf-t1-1', 'clf-t1-2']);
  });

  test('레거시 JSON(id/source 없음)도 안전 — auto/빈 기본값', () {
    final legacy = {
      'certCode': 'CLF-C02',
      'startIso': '2026-06-01',
      'endIso': '2026-06-15',
      'mode': 'period',
      'createdIso': '2026-06-01',
      'items': [],
    };
    final p = StudyPlan.fromJson(legacy);
    expect(p.source, PlanSource.auto);
    expect(p.taskIds, isEmpty);
    expect(p.planType, isNull);
    expect(p.id, '');
  });
}
