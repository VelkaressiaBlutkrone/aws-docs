import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/local_kv.dart';
import 'package:aws_docs/main.dart';

void main() {
  testWidgets('토글→재기동: 같은 저장소로 새 앱을 띄우면 다크 유지', (tester) async {
    final kv = MemoryBackend();

    await tester.pumpWidget(AwsDocsApp(kv: kv));
    await tester.pump();

    MaterialApp app() => tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app().themeMode, ThemeMode.light);

    await tester.tap(find.byTooltip('다크 모드'));
    await tester.pumpAndSettle();
    expect(app().themeMode, ThemeMode.dark);

    // 새로고침에 해당: 같은 백엔드로 완전히 새 위젯 트리.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(AwsDocsApp(kv: kv));
    await tester.pump();
    expect(app().themeMode, ThemeMode.dark);
  });

  testWidgets('파손 키: 라이트로 부팅', (tester) async {
    final kv = MemoryBackend()..write('awsdocs.theme.v1', 'v2:???');

    await tester.pumpWidget(AwsDocsApp(kv: kv));
    await tester.pump();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.light);
  });
}
