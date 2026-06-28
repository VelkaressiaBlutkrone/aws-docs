import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/audio_chapters.dart';

void main() {
  test('parseChapters: chapters 배열 파싱', () {
    final list = parseChapters({
      'chapters': [
        {'anchor': 'a', 'title': 'A', 'level': 2, 'fraction': 0.0},
        {'anchor': 'b', 'title': 'B', 'level': 3, 'fraction': 0.5},
      ],
    });
    expect(list.length, 2);
    expect(list[1].anchor, 'b');
    expect(list[1].fraction, 0.5);
    expect(list[0].level, 2);
  });

  test('parseChapters: chapters 없으면 빈 리스트', () {
    expect(parseChapters({'docId': 'x'}), isEmpty);
    expect(parseChapters({'chapters': null}), isEmpty);
  });

  test('chapterSeekMs: fraction×duration', () {
    expect(chapterSeekMs(0.25, const Duration(seconds: 100)), 25000);
    expect(chapterSeekMs(0.0, const Duration(seconds: 100)), 0);
  });

  test('shouldShowHeadingSeek: 모두 true일 때만', () {
    expect(shouldShowHeadingSeek(enabled: true, approved: true,
        isCurrentTrack: true, hasDuration: true, hasFraction: true), isTrue);
    expect(shouldShowHeadingSeek(enabled: true, approved: true,
        isCurrentTrack: false, hasDuration: true, hasFraction: true), isFalse);
    expect(shouldShowHeadingSeek(enabled: false, approved: true,
        isCurrentTrack: true, hasDuration: true, hasFraction: true), isFalse);
    expect(shouldShowHeadingSeek(enabled: true, approved: true,
        isCurrentTrack: true, hasDuration: false, hasFraction: true), isFalse);
  });
}
