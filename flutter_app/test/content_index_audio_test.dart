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
}
