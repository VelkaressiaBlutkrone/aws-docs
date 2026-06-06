import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/theme/theme_scope.dart';

void main() {
  testWidgets('ThemeScope.of 로 isDark/toggle 접근', (tester) async {
    var toggled = false;
    await tester.pumpWidget(
      ThemeScope(
        isDark: true,
        toggle: () => toggled = true,
        child: Builder(
          builder: (context) {
            final scope = ThemeScope.of(context);
            return MaterialApp(
              home: Scaffold(
                body: TextButton(
                  onPressed: scope.toggle,
                  child: Text(scope.isDark ? 'dark' : 'light'),
                ),
              ),
            );
          },
        ),
      ),
    );

    expect(find.text('dark'), findsOneWidget);
    await tester.tap(find.byType(TextButton));
    expect(toggled, isTrue);
  });
}
