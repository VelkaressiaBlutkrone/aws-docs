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

    // 본문 스크롤러(NestedScrollView body의 CustomScrollView)의 Scrollable.
    ScrollableState bodyScrollable() => tester.state<ScrollableState>(
          find.descendant(
            of: find.byKey(const Key('plan-agenda-scroll')),
            matching: find.byType(Scrollable),
          ),
        );

    // 어젠다 시작 시 본문 스크롤 오프셋 0
    expect(bodyScrollable().position.pixels, 0);

    // 월 보기 토글
    await tester.tap(find.byTooltip('월 보기'));
    await tester.pumpAndSettle();

    // 마지막 날(24) 셀 탭 — 셀 안 '24' 텍스트의 InkWell 조상
    await tester.tap(find.ancestor(
        of: find.text('24'), matching: find.byType(InkWell)).first);
    await tester.pumpAndSettle();

    // (1) 어젠다로 돌아오고 늦은 날짜로 스크롤됨 → 본문 오프셋 > 0
    expect(bodyScrollable().position.pixels, greaterThan(0),
        reason: '24일 셀을 탭하면 본문이 늦은 날짜로 스크롤돼야 한다');

    // (2) 실제로 "그 날짜"로 갔는지 검증: 6/24 어젠다 날짜 헤더가 보이는 뷰포트
    //     안(상단~하단)에 들어와 있어야 한다. 시작 오프셋(0)에서는 6/24가 뷰포트
    //     아래쪽(또는 cacheExtent 영역)에 있으므로, 이 검증은 trivially-true가 아니라
    //     "실제로 그 날짜까지 스크롤됐음"을 보장한다.
    final dayHeader = find.text('2026-06-24');
    expect(dayHeader, findsOneWidget,
        reason: '대상 날짜 헤더가 마운트(=해당 위치로 스크롤)돼 있어야 한다');

    final viewportBox = tester.getRect(find.byKey(const Key('plan-agenda-scroll')));
    final headerTop = tester.getTopLeft(dayHeader).dy;
    // 헤더가 보이는 뷰포트 범위(top..bottom) 안에 있다 = 화면에 실제로 보인다.
    expect(headerTop, greaterThanOrEqualTo(viewportBox.top - 1),
        reason: '6/24 헤더가 뷰포트 상단 위로 잘려 있으면 안 된다');
    expect(headerTop, lessThanOrEqualTo(viewportBox.bottom),
        reason: '6/24 헤더가 보이는 뷰포트 안으로 스크롤돼 들어와야 한다');
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
