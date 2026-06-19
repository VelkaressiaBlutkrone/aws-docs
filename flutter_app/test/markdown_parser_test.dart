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

  group('heading anchor {#id}', () {
    MdHeading firstHeading(String md) =>
        parseStudyDoc(md).blocks.whereType<MdHeading>().first;

    test('extracts anchor and strips it from text', () {
      final h = firstHeading('## 핵심 개념 {#core-concepts}\n');
      expect(h.anchor, 'core-concepts');
      expect(h.text, '핵심 개념');
    });

    test('no anchor when absent', () {
      final h = firstHeading('## 핵심 개념\n');
      expect(h.anchor, isNull);
      expect(h.text, '핵심 개념');
    });

    test('malformed anchor stays literal', () {
      final h = firstHeading('## 핵심 {# Bad ID}\n');
      expect(h.anchor, isNull);
      expect(h.text, '핵심 {# Bad ID}');
    });

    test('anchor on H3 with emoji/parens', () {
      final h = firstHeading('### 1) 이점 (★) {#benefits}\n');
      expect(h.anchor, 'benefits');
      expect(h.text, '### 1) 이점 (★)'.replaceFirst('### ', ''));
    });
  });

  group('H4~H6 헤딩 (회귀: t3-6 등 고도화 문서 무한루프 방지)', () {
    test('H4 헤딩이 무한루프 없이 level 4 heading으로 파싱된다', () {
      final doc =
          parseStudyDoc('---\ntitle: X\n---\n\n#### 세부 facet\n\n본문 문단\n');
      final h4 = doc.blocks.whereType<MdHeading>().where((h) => h.level == 4);
      expect(h4, isNotEmpty, reason: 'H4가 heading(level 4)으로 파싱돼야 한다');
      expect(h4.first.text, '세부 facet');
      expect(
          doc.blocks
              .whereType<MdParagraph>()
              .any((p) => p.spans.any((s) => s.text.contains('본문 문단'))),
          isTrue,
          reason: 'H4 다음 본문이 문단으로 이어져야 한다');
    }, timeout: const Timeout(Duration(seconds: 10)));

    test('H5·H6도 heading으로 파싱된다', () {
      final doc = parseStudyDoc('##### 다섯\n\n###### 여섯\n');
      final levels =
          doc.blocks.whereType<MdHeading>().map((h) => h.level).toSet();
      expect(levels.containsAll({5, 6}), isTrue);
    }, timeout: const Timeout(Duration(seconds: 10)));

    test('지원 범위를 넘는 #######(H7)도 무한루프 없이 degrade 된다', () {
      final doc = parseStudyDoc('####### 일곱\n\n다음 문단\n');
      expect(doc.blocks, isNotEmpty,
          reason: '미지원 헤딩 레벨도 진전 보장으로 멈추지 않아야 한다');
    }, timeout: const Timeout(Duration(seconds: 10)));

    test('#### 다음 목록이 정상 블록으로 이어진다', () {
      final doc = parseStudyDoc('#### 제목\n\n- 항목1\n- 항목2\n');
      expect(
          doc.blocks
              .whereType<MdHeading>()
              .any((h) => h.level == 4 && h.text == '제목'),
          isTrue);
      expect(doc.blocks.whereType<MdBullets>().isNotEmpty, isTrue);
    }, timeout: const Timeout(Duration(seconds: 10)));
  });
}
