// 굵게 안의 인라인 코드가 백틱째 보이던 렌더 결함 가드 (2026-11-18 라이브 점검).
//
// 증상: 학습문서 「시험 직전 요약」의 `**\`stopReason\`이 …**` 같은 줄에서 백틱이 글자로 보였다.
// 원인: `markdown_parser.dart` 의 인라인 정규식이 `\*\*([^*]+)\*\*` 를 먼저 잡고 그 안을
// **다시 파싱하지 않아** 굵게 구간 전체를 백틱째 한 덩어리 굵은 글자로 넘겼다. 전 자격증
// md 에 그런 굵게 구간이 약 2,400곳 있었다.
//
// 가드는 세 층이다 — 파서 단위(굵게 안 코드가 코드 스팬으로 갈라진다 + 기존 동작 불변),
// 실제 콘텐츠 전수(굵은 스팬에 백틱 0 + 굵은 코드 스팬이 실제로 생긴다는 대조군),
// 렌더러(굵은 코드 스팬이 모노 폰트 · 굵게로 그려진다).
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aws_docs/content/markdown_parser.dart';
import 'package:aws_docs/content/study_markdown_view.dart';
import 'package:aws_docs/models/study_content.dart';
import 'package:aws_docs/theme/app_theme.dart';

List<MdSpan> _paragraph(String line) {
  final doc = parseStudyDoc('---\ntitle: X\n---\n\n$line\n');
  return doc.blocks.whereType<MdParagraph>().single.spans;
}

/// 블록 트리 전체의 스팬을 모은다(토글 안까지).
Iterable<MdSpan> _allSpans(List<MdBlock> blocks) sync* {
  for (final b in blocks) {
    switch (b) {
      case MdParagraph(:final spans):
        yield* spans;
      case MdQuote(:final spans):
        yield* spans;
      case MdBullets(:final items):
        for (final i in items) {
          yield* i;
        }
      case MdNumbered(:final items):
        for (final i in items) {
          yield* i;
        }
      case MdChecklist(:final items):
        for (final i in items) {
          yield* i.spans;
        }
      case MdTable(:final headers, :final rows):
        for (final h in headers) {
          yield* h;
        }
        for (final r in rows) {
          for (final c in r) {
            yield* c;
          }
        }
      case MdDetails(:final body):
        yield* _allSpans(body);
      default:
        break;
    }
  }
}

void main() {
  group('파서', () {
    test('굵게 안의 인라인 코드는 굵은 코드 스팬으로 갈라지고 백틱이 남지 않는다', () {
      final spans = _paragraph('가 **앞 `stopReason` 뒤** 나');
      expect(spans.map((s) => s.text).toList(), ['가 ', '앞 ', 'stopReason', ' 뒤', ' 나']);
      expect(spans.map((s) => s.bold).toList(), [false, true, true, true, false]);
      expect(spans.map((s) => s.code).toList(), [false, false, true, false, false]);
      expect(spans.where((s) => s.text.contains('`')), isEmpty);
    });

    test('코드로만 이뤄진 굵게도 갈라진다', () {
      final spans = _paragraph('**`Amazon Quick`**');
      expect(spans, hasLength(1));
      expect(spans.single.text, 'Amazon Quick');
      expect(spans.single.bold, isTrue);
      expect(spans.single.code, isTrue);
    });

    test('대조군: 코드 없는 굵게와 굵게 밖의 코드는 전과 같다', () {
      final a = _paragraph('**굵게만**');
      expect(a.single.text, '굵게만');
      expect(a.single.bold, isTrue);
      expect(a.single.code, isFalse);

      final b = _paragraph('앞 `code` 뒤');
      expect(b.map((s) => s.text).toList(), ['앞 ', 'code', ' 뒤']);
      expect(b[1].code, isTrue);
      expect(b[1].bold, isFalse);
    });
  });

  test('실제 콘텐츠 전수: 굵은 스팬에 백틱이 남지 않는다 (+ 굵은 코드 스팬이 실제로 생긴다)', () {
    final files = Directory('assets/content')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.md'))
        .toList();
    expect(files.length, greaterThan(100), reason: '대조군: 학습문서 전수가 읽혀야 한다');

    final leaks = <String>[];
    var boldCode = 0;
    for (final f in files) {
      final doc = parseStudyDoc(f.readAsStringSync());
      for (final s in _allSpans(doc.blocks)) {
        if (s.bold && s.code) boldCode++;
        if (s.bold && !s.code && s.text.contains('`')) {
          if (leaks.length < 5) leaks.add('${f.path}: ${s.text}');
        }
      }
    }
    expect(leaks, isEmpty, reason: '굵게 안 백틱이 글자로 남는다');
    // 대조군: 수정이 실제 콘텐츠에 닿는다(2026-11-18 실측 약 2,400 구간).
    expect(boldCode, greaterThan(1000));
  });

  testWidgets('렌더러: 굵은 코드 스팬은 모노 폰트 · 굵게로 그린다', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: const Scaffold(
        body: StudyMarkdownView(blocks: [
          MdParagraph([
            MdSpan('평문 '),
            MdSpan('코드굵게', bold: true, code: true),
            MdSpan(' 코드만', code: true),
          ]),
        ]),
      ),
    ));
    final rich = tester
        .widgetList<RichText>(find.byType(RichText))
        .firstWhere((w) => w.text.toPlainText().contains('코드굵게'));
    TextStyle? styleOf(String text) {
      TextStyle? found;
      rich.text.visitChildren((s) {
        if (s is TextSpan && s.text == text) {
          found = s.style;
          return false;
        }
        return true;
      });
      return found;
    }

    final boldCode = styleOf('코드굵게')!;
    expect(boldCode.fontFamily, AppTheme.monoFamily);
    expect(boldCode.fontWeight, FontWeight.w700);
    // 대조군: 굵지 않은 코드는 굵게 되지 않는다.
    expect(styleOf(' 코드만')!.fontWeight, isNot(FontWeight.w700));
  });
}
