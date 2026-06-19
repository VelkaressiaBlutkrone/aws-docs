import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/cert_lookup.dart';
import 'package:aws_docs/models/study_plan.dart';
import 'package:aws_docs/pages/plan/plan_create_form.dart';
import 'package:aws_docs/theme/app_theme.dart';
import 'package:aws_docs/theme/theme_scope.dart';

Widget _host(Widget child) => ThemeScope(
      isDark: false,
      toggle: () {},
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: child),
      ),
    );

void main() {
  testWidgets('수동: 모의고사 유형 저장 → manual plan 1항목', (tester) async {
    StudyPlan? saved;
    await tester.pumpWidget(_host(PlanCreateForm(
        cert: certByCode('CLF-C02')!,
        today: '2026-06-19',
        onSaved: (p) => saved = p)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('직접 만들기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('모의고사'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('일정 저장'));
    await tester.pumpAndSettle();

    expect(saved, isNotNull);
    expect(saved!.source, PlanSource.manual);
    expect(saved!.planType, PlanItemType.mockExam);
    expect(saved!.items.length, 1);
  });

  testWidgets('수동: 문서 유형 + Task 선택 저장 → manual plan', (tester) async {
    StudyPlan? saved;
    await tester.pumpWidget(_host(PlanCreateForm(
        cert: certByCode('CLF-C02')!,
        today: '2026-06-19',
        onSaved: (p) => saved = p)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('직접 만들기'));
    await tester.pumpAndSettle();

    // '문서 학습'이 기본 유형 → Task 체크리스트 노출
    final firstCheck = find.byType(CheckboxListTile).first;
    await tester.scrollUntilVisible(firstCheck, 100,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(firstCheck);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('일정 저장'), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('일정 저장'));
    await tester.pumpAndSettle();

    expect(saved, isNotNull);
    expect(saved!.source, PlanSource.manual);
    expect(saved!.planType, PlanItemType.doc);
    expect(saved!.items.length, 1);
  });
}
