import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/content_index.dart';

void main() {
  test('approvedAudioEntries: CLF-C02는 승인 오디오 19문서 모두 반환(선언 순서)', () {
    final list = approvedAudioEntries('CLF-C02');
    expect(list, isNotEmpty);
    expect(list.every((e) => e.audioApproved), isTrue);
    expect(list.first.taskId, 'clf-t1-1'); // 선언 순서 첫 항목
  });

  test('approvedAudioEntries: 미존재/무오디오 cert는 빈 리스트', () {
    expect(approvedAudioEntries('NOPE-X'), isEmpty);
  });

  test('certsWithApprovedAudio: CLF-C02 포함', () {
    expect(certsWithApprovedAudio(), contains('CLF-C02'));
  });

  test('approvedAudioEntries: SAA-C03는 청취 승인 20문서(t1~t3 전부 + t4-1) 반환', () {
    final list = approvedAudioEntries('SAA-C03');
    expect(list.length, 20);
    expect(list.every((e) => e.audioApproved), isTrue);
    expect(list.first.taskId, 'saa-t1-1');
    expect(list.last.taskId, 'saa-t4-1');
    // t4-2~t4-5는 enrich·합성 전(스캐폴드)이라 미승인.
    expect(list.any((e) => e.taskId == 'saa-t4-2'), isFalse);
  });

  test('certsWithApprovedAudio: SAA-C03 포함', () {
    expect(certsWithApprovedAudio(), containsAll(['CLF-C02', 'SAA-C03']));
  });
}
