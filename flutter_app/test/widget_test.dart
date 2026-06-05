import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aws_docs/main.dart';

void main() {
  testWidgets('App builds and shows the brand + a known cert', (tester) async {
    await tester.pumpWidget(const AwsDocsApp());
    await tester.pump();

    // Brand appears in the header.
    expect(find.text('AWS Docs Roadmap'), findsWidgets);
    // A known certification code is rendered.
    expect(find.text('CLF-C02'), findsWidgets);
  });

  testWidgets('Theme toggle flips brightness', (tester) async {
    await tester.pumpWidget(const AwsDocsApp());
    await tester.pump();

    MaterialApp app() =>
        tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app().themeMode, ThemeMode.light);

    await tester.tap(find.byTooltip('다크 모드'));
    await tester.pumpAndSettle();

    expect(app().themeMode, ThemeMode.dark);
  });
}
