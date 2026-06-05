import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/content/study_markdown_view.dart';
import 'package:aws_docs/models/study_content.dart';
import 'package:aws_docs/theme/app_theme.dart';

void main() {
  testWidgets('헤딩/문단/표/토글을 렌더한다', (tester) async {
    final blocks = <MdBlock>[
      const MdHeading(2, '🎯 왜 중요한가'),
      const MdParagraph([MdSpan('도메인 2는 비중이 '), MdSpan('30%', bold: true)]),
      const MdTable(['A', 'B'], [
        ['EC2', '고객'],
      ]),
      const MdDetails('정답 보기', [
        MdParagraph([MdSpan('고객.')]),
      ]),
    ];
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: StudyMarkdownView(blocks: blocks)),
    ));
    expect(find.textContaining('왜 중요한가'), findsOneWidget);
    expect(find.text('정답 보기'), findsOneWidget); // ExpansionTile 제목
    expect(find.text('EC2'), findsOneWidget); // 표 셀
  });
}
