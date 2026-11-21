import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/content_index.dart';

void main() {
  // ⚠️ 승인 편수를 숫자로 박지 않는다. 2026-11-06 P1 정정으로 clf-t2-1·t2-2·t2-3·
  // t4-3 의 대본을 고쳐 재합성했고, 그동안 네 편이 audioApproved: false 였다
  // (19 → 15 → 사람의 청취 승인·R2 발행 후 다시 19). **그 왕복이 바로 숫자를
  // 박지 말아야 하는 이유다** — 「19문서」를 단정했다면 재합성 PR 과 재승인 PR
  // 양쪽에서 레드가 났다. 문항의 `verified: true` flip 과 같은 규율이고, 승인 ↔
  // 메타 일치는 content_index_test 의 동기화 단정이 양방향으로 지킨다.
  test('approvedAudioEntries: CLF-C02는 승인 오디오를 선언 순서로 반환', () {
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

  // 위 CLF 규율과 같다. 2026-11-21 saa-t3-2 재합성으로 승인 편수가 잠시 줄었고,
  // 숫자를 박으면 재합성 PR 과 재승인 PR 양쪽에서 레드가 난다.
  test('approvedAudioEntries: SAA-C03는 승인 오디오를 선언 순서로 반환', () {
    final list = approvedAudioEntries('SAA-C03');
    expect(list, isNotEmpty);
    expect(list.every((e) => e.audioApproved), isTrue);
    expect(list.first.taskId, 'saa-t1-1');
    // 마지막 항목도 박지 않는다 — saa-t4-1 이 재합성으로 잠시 빠지면 레드가 난다.
    expect(
      list.map((e) => e.taskId),
      contentFor('SAA-C03')
          .where((e) => e.audioApproved)
          .map((e) => e.taskId),
    );
    // t4-2~t4-5는 enrich·합성 전(스캐폴드)이라 미승인.
    expect(list.any((e) => e.taskId == 'saa-t4-2'), isFalse);
  });

  test('certsWithApprovedAudio: SAA-C03 포함', () {
    expect(certsWithApprovedAudio(), containsAll(['CLF-C02', 'SAA-C03']));
  });
}
