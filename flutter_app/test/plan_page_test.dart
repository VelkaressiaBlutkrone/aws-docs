import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/local_kv.dart';
import 'package:aws_docs/data/study_plan_store.dart';
import 'package:aws_docs/data/plan_check_store.dart';
import 'package:aws_docs/data/cert_lookup.dart';
import 'package:aws_docs/models/study_plan.dart';
import 'package:aws_docs/pages/plan_page.dart';
import 'package:aws_docs/theme/app_theme.dart';
import 'package:aws_docs/theme/theme_scope.dart';

Widget _host(KvBackend backend, String code) => ThemeScope(
      isDark: false,
      toggle: () {},
      child: MaterialApp(
        theme: AppTheme.light,
        home: PlanPage(cert: certByCode(code)!, backend: backend),
      ),
    );

void main() {
  testWidgets('cert 변경 시 플랜 재로드 — A(플랜 어젠다) → B(생성 폼)', (tester) async {
    final backend = MemoryBackend();
    StudyPlanStore(backend: backend).save(const StudyPlan(
      certCode: 'CLF-C02', startIso: '2026-06-10', endIso: '2026-06-24',
      mode: PlanMode.period, createdIso: '2026-06-10', items: []));

    await tester.pumpWidget(_host(backend, 'CLF-C02'));
    await tester.pump();
    expect(find.text('다시 만들기'), findsOneWidget);       // 어젠다
    expect(find.text('학습 일정 만들기'), findsNothing);

    // 같은 PlanPage 엘리먼트에 SAA 주입 → didUpdateWidget이 재로드
    await tester.pumpWidget(_host(backend, 'SAA-C03'));
    await tester.pump();
    expect(find.text('학습 일정 만들기'), findsOneWidget);   // 생성 폼(SAA 플랜 없음)
    expect(find.text('다시 만들기'), findsNothing);
  });

  testWidgets('체크박스 토글이 PlanCheckStore에 영속 + 진행률 UI 반영', (tester) async {
    final backend = MemoryBackend();
    StudyPlanStore(backend: backend).save(const StudyPlan(
      certCode: 'CLF-C02', startIso: '2026-06-10', endIso: '2026-06-24',
      mode: PlanMode.period, createdIso: '2026-06-10',
      items: [PlanItem(id: 'x', dateIso: '2026-06-15', type: PlanItemType.doc, phase: PlanPhase.learn)]));

    await tester.pumpWidget(_host(backend, 'CLF-C02'));
    await tester.pump();
    expect(find.text('진행 0/1 (0%)'), findsOneWidget);

    await tester.tap(find.byType(Checkbox).first);
    await tester.pump();

    expect(PlanCheckStore(backend: backend).overrides('CLF-C02')['x'], isTrue); // 영속
    expect(find.text('진행 1/1 (100%)'), findsOneWidget);                        // UI 반영
  });
}
