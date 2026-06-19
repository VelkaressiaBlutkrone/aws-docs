import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/cert_lookup.dart';
import 'package:aws_docs/data/plan_progress_store.dart';
import 'package:aws_docs/data/study_plan_store.dart';
import 'package:aws_docs/models/study_plan.dart';
import 'package:aws_docs/pages/plan_page.dart';
import 'package:aws_docs/pages/plan/plan_agenda.dart';
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

Widget _agendaHost(KvBackend backend, StudyPlan plan) => ThemeScope(
      isDark: false,
      toggle: () {},
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: PlanAgenda(
            cert: certByCode('CLF-C02')!,
            plan: plan,
            today: '2026-06-10',
            onEdit: () {},
            onChanged: (_) {},
            backend: backend,
          ),
        ),
      ),
    );

StudyPlan _plan({String label = '1주차', List<PlanItem> items = const []}) =>
    StudyPlan(
      id: '',
      label: label,
      certCode: 'CLF-C02',
      startIso: '2026-06-10',
      endIso: '2026-06-24',
      mode: PlanMode.period,
      createdIso: '2026-06-10',
      items: items,
    );

void main() {
  testWidgets('일정 없으면 목록에 "일정 추가"', (tester) async {
    await tester.pumpWidget(_host(MemoryBackend(), 'CLF-C02'));
    await tester.pump();
    expect(find.text('+ 일정 추가'), findsOneWidget);
  });

  testWidgets('"일정 추가" 탭 → 생성 폼', (tester) async {
    await tester.pumpWidget(_host(MemoryBackend(), 'CLF-C02'));
    await tester.pump();
    await tester.tap(find.text('+ 일정 추가'));
    await tester.pump();
    expect(find.text('학습 일정 만들기'), findsOneWidget);
  });

  testWidgets('일정 추가 후 카드 노출 + 탭하면 어젠다', (tester) async {
    final b = MemoryBackend();
    StudyPlanStore(backend: b).add(_plan(label: '1주차'));
    await tester.pumpWidget(_host(b, 'CLF-C02'));
    await tester.pump();
    expect(find.text('1주차'), findsOneWidget);
    await tester.tap(find.text('1주차'));
    await tester.pump();
    expect(find.text('다시 만들기'), findsOneWidget);
  });

  testWidgets('어젠다 체크박스 → PlanProgressStore 영속 + 진행률', (tester) async {
    final b = MemoryBackend();
    StudyPlanStore(backend: b).add(_plan(label: '1주차', items: const [
      PlanItem(
          id: 'i0',
          dateIso: '2026-06-15',
          type: PlanItemType.doc,
          phase: PlanPhase.learn),
    ]));
    await tester.pumpWidget(_host(b, 'CLF-C02'));
    await tester.pump();
    await tester.tap(find.text('1주차'));
    await tester.pump();
    expect(find.text('진행 0/1 (0%)'), findsOneWidget);

    await tester.tap(find.byType(Checkbox).first);
    await tester.pump();

    final planId = StudyPlanStore(backend: b).plansFor('CLF-C02').first.id;
    expect(PlanProgressStore(backend: b).donePlan(planId), contains('i0'));
    expect(find.text('진행 1/1 (100%)'), findsOneWidget);
  });

  testWidgets('일정 삭제 → 목록 제거 + 진행 초기화', (tester) async {
    final b = MemoryBackend();
    StudyPlanStore(backend: b).add(_plan(label: '삭제대상', items: const [
      PlanItem(
          id: 'i0',
          dateIso: '2026-06-15',
          type: PlanItemType.doc,
          phase: PlanPhase.learn),
    ]));
    final planId = StudyPlanStore(backend: b).plansFor('CLF-C02').first.id;
    PlanProgressStore(backend: b).setDone(planId, 'i0', true);
    await tester.pumpWidget(_host(b, 'CLF-C02'));
    await tester.pump();
    await tester.tap(find.text('삭제대상'));
    await tester.pump();
    await tester.tap(find.byTooltip('일정 삭제'));
    await tester.pump();
    expect(find.text('삭제대상'), findsNothing);
    expect(StudyPlanStore(backend: b).plansFor('CLF-C02'), isEmpty);
    expect(PlanProgressStore(backend: b).donePlan(planId), isEmpty);
  });

  testWidgets('월 셀 탭 → 해당 날짜로 스크롤 (PlanAgenda 회귀 가드)',
      (tester) async {
    final backend = MemoryBackend();
    final items = <PlanItem>[
      for (var d = 10; d <= 24; d++)
        PlanItem(
            id: 'i$d',
            dateIso: '2026-06-${d.toString().padLeft(2, '0')}',
            type: PlanItemType.doc,
            phase: PlanPhase.learn),
    ];
    await tester.pumpWidget(_agendaHost(backend, _plan(items: items)));
    await tester.pumpAndSettle();

    ScrollableState bodyScrollable() => tester.state<ScrollableState>(
          find.descendant(
            of: find.byKey(const Key('plan-agenda-scroll')),
            matching: find.byType(Scrollable),
          ),
        );
    expect(bodyScrollable().position.pixels, 0);

    await tester.tap(find.byTooltip('월 보기'));
    await tester.pumpAndSettle();
    await tester.tap(find
        .ancestor(of: find.text('24'), matching: find.byType(InkWell))
        .first);
    await tester.pumpAndSettle();

    expect(bodyScrollable().position.pixels, greaterThan(0),
        reason: '24일 셀 탭 → 본문이 늦은 날짜로 스크롤');
    expect(find.textContaining('2026-06-24'), findsOneWidget);
  });
}
