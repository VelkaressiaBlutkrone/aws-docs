import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/content/markdown_parser.dart';
import 'package:aws_docs/models/study_content.dart';

void main() {
  // 테스트 cwd = 패키지 루트(flutter_app/)이므로 상대경로로 자산을 읽는다.
  final raw = File('assets/content/clf/t2-1.md').readAsStringSync();

  test('프런트매터를 파싱한다', () {
    final doc = parseStudyDoc(raw);
    expect(doc.examGuideTaskId, 'clf-t2-1');
    expect(doc.certCode, 'CLF-C02');
    expect(doc.domain, 2);
    expect(doc.title, contains('공동 책임 모델'));
    expect(doc.sources.length, greaterThanOrEqualTo(5));
    expect(doc.sources.first.url, startsWith('https://'));
  });

  test('섹션 헤딩과 자가점검 토글, 표를 파싱한다', () {
    final doc = parseStudyDoc(raw);
    final headings =
        doc.blocks.whereType<MdHeading>().map((h) => h.text).toList();
    expect(headings.any((h) => h.startsWith('🎯')), isTrue);
    expect(headings.any((h) => h.startsWith('⚠️')), isTrue);
    expect(headings.any((h) => h.startsWith('🧪')), isTrue);

    final details = doc.blocks.whereType<MdDetails>().toList();
    expect(details.length, greaterThanOrEqualTo(4));
    expect(details.first.summary, isNotEmpty);

    expect(doc.blocks.whereType<MdTable>().isNotEmpty, isTrue);
  });

  test('알 수 없는 줄도 크래시 없이 문단으로 degrade 한다', () {
    final doc = parseStudyDoc('---\ntitle: X\n---\n\n@@이상한 줄@@');
    expect(doc.blocks.whereType<MdParagraph>().isNotEmpty, isTrue);
  });

  test('표 셀의 **굵게**를 인라인 spans로 파싱한다', () {
    const md = '''
---
title: X
---

| 용어 | 설명 |
| --- | --- |
| **탄력성** | 수요에 맞춰 `조절` |
''';
    final doc = parseStudyDoc(md);
    final table = doc.blocks.whereType<MdTable>().first;
    // 헤더: 평문
    expect(table.headers[0].first.text, '용어');
    // 첫 행 첫 셀: 굵게 span
    expect(table.rows[0][0].any((s) => s.bold && s.text == '탄력성'), isTrue);
    // 첫 행 둘째 셀: code span 포함
    expect(table.rows[0][1].any((s) => s.code && s.text == '조절'), isTrue);
  });
}
