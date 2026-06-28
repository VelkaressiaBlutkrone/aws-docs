import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/content/markdown_parser.dart';
import 'package:aws_docs/content/study_markdown_view.dart';
import 'package:aws_docs/theme/app_theme.dart';

void main() {
  testWidgets('headingTrailing이 앵커 헤딩 옆에 위젯을 단다', (tester) async {
    final blocks = parseStudyDoc('## 제목 {#sec}\n\n본문입니다.').blocks;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: StudyMarkdownView(
          blocks: blocks,
          headingTrailing: (anchor) =>
              anchor == 'sec' ? const Icon(Icons.play_arrow, key: Key('seek-sec')) : null,
        ),
      ),
    ));
    expect(find.byKey(const Key('seek-sec')), findsOneWidget);
  });

  testWidgets('headingTrailing 없으면 아무 것도 안 단다', (tester) async {
    final blocks = parseStudyDoc('## 제목 {#sec}\n\n본문.').blocks;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: StudyMarkdownView(blocks: blocks)),
    ));
    expect(find.byIcon(Icons.play_arrow), findsNothing);
  });

  testWidgets('headingTrailing이 null 반환하면 슬롯 미표시', (tester) async {
    final blocks = parseStudyDoc('## 제목 {#sec}\n\n본문.').blocks;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: StudyMarkdownView(
        blocks: blocks,
        headingTrailing: (anchor) => null,
      )),
    ));
    expect(find.byIcon(Icons.play_arrow), findsNothing);
  });
}
