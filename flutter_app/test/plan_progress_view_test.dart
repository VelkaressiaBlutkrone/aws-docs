import 'package:aws_docs/data/plan_progress_view.dart';
import 'package:aws_docs/data/plan_progress_store.dart';
import 'package:aws_docs/models/study_plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('planDone — PlanProgressStore의 done을 computePlanDone에 연결', () {
    final plan = StudyPlan(
      id: 'p1',
      certCode: 'CLF-C02',
      startIso: '2026-06-19',
      endIso: '2026-06-26',
      mode: PlanMode.period,
      createdIso: '2026-06-19',
      items: const [
        PlanItem(
          id: 'p1#doc:clf-t1-1:0',
          dateIso: '2026-06-19',
          type: PlanItemType.doc,
          phase: PlanPhase.learn,
          refId: 'clf-t1-1',
        ),
      ],
    );
    final progress = PlanProgressStore(backend: MemoryBackend());
    expect(planDone(plan, progress, const [])['p1#doc:clf-t1-1:0'], isFalse);
    progress.setDone('p1', 'p1#doc:clf-t1-1:0', true);
    expect(planDone(plan, progress, const [])['p1#doc:clf-t1-1:0'], isTrue);
  });
}
