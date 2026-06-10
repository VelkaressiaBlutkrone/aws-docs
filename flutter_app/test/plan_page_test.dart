import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

  testWidgets('월 셀 탭 → 어젠다로 전환 + 해당 날짜로 스크롤', (tester) async {
    final backend = MemoryBackend();
    // 6/10~6/24 매일 1개 항목 → 긴(스크롤 가능) 어젠다
    final items = <PlanItem>[
      for (var d = 10; d <= 24; d++)
        PlanItem(
            id: 'i$d',
            dateIso: '2026-06-${d.toString().padLeft(2, '0')}',
            type: PlanItemType.doc,
            phase: PlanPhase.learn),
    ];
    StudyPlanStore(backend: backend).save(StudyPlan(
      certCode: 'CLF-C02', startIso: '2026-06-10', endIso: '2026-06-24',
      mode: PlanMode.period, createdIso: '2026-06-10', items: items));

    await tester.pumpWidget(_host(backend, 'CLF-C02'));
    await tester.pumpAndSettle();

    // 어젠다 시작 시 스크롤 오프셋 0
    final sc0 = tester.widget<ListView>(find.byType(ListView)).controller!;
    expect(sc0.offset, 0);

    // 월 보기 토글
    await tester.tap(find.byTooltip('월 보기'));
    await tester.pumpAndSettle();

    // 마지막 날(24) 셀 탭 — 셀 안 '24' 텍스트의 InkWell 조상
    await tester.tap(find.ancestor(
        of: find.text('24'), matching: find.byType(InkWell)).first);
    await tester.pumpAndSettle();

    // 어젠다로 돌아오고 늦은 날짜로 스크롤됨 → 오프셋 > 0
    final sc1 = tester.widget<ListView>(find.byType(ListView)).controller!;
    expect(sc1.offset, greaterThan(0));
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
