import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/content/anchor_scroll.dart';
import 'package:aws_docs/models/study_content.dart';

void main() {
  group('anchorScrollOffset', () {
    test('subtracts header inset', () {
      expect(
          anchorScrollOffset(
              revealOffset: 500, headerInset: 56, maxScrollExtent: 2000),
          444);
    });
    test('clamps to zero (negative)', () {
      expect(
          anchorScrollOffset(
              revealOffset: 20, headerInset: 56, maxScrollExtent: 2000),
          0);
    });
    test('clamps to max', () {
      expect(
          anchorScrollOffset(
              revealOffset: 3000, headerInset: 56, maxScrollExtent: 2000),
          2000);
    });
  });

  group('buildAnchorKeys', () {
    test('one key per anchored heading, keyed by id', () {
      final blocks = <MdBlock>[
        const MdHeading(2, '핵심', anchor: 'core'),
        const MdParagraph([MdSpan('x')]),
        const MdHeading(3, '이점', anchor: 'benefits'),
        const MdHeading(2, '함정'), // 앵커 없음 → 제외
      ];
      final keys = buildAnchorKeys(blocks);
      expect(keys.keys.toSet(), {'core', 'benefits'});
      expect(keys['core'], isA<GlobalKey>());
    });
  });
}
