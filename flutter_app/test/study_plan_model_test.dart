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

  test('알 수 없는 enum/결손 필드는 안전 기본값', () {
    final it = PlanItem.fromJson({'id': 'x', 'dateIso': '2026-01-01', 'type': '몰라', 'phase': null});
    expect(it.type, PlanItemType.doc); // fallback
    expect(it.phase, PlanPhase.learn); // fallback
    expect(it.refId, isNull);
    final p = StudyPlan.fromJson({'certCode': 'CLF-C02'});
    expect(p.mode, PlanMode.period); // fallback
    expect(p.items, isEmpty);
  });
}
