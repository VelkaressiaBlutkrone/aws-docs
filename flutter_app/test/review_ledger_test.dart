// 문항 검수 원장 동기화 가드 (2026-11-18 외부 리뷰 후속 §3-3).
//
// `verified: true` 는 「지금 공개 상태다」만 말하고 **언제 공개됐는지**는 말하지 않는다. 그래서 자격증별
// 원장 `docs/review-ledger/<cert>.json` 에 Task 단위로 최초 공개일(`verifiedAt`)과 공개 문항 수를 두고,
// 이 가드가 **원장 ↔ 디스크의 verified 상태**를 맞댄다. 과거분은 git 이력에서 한 번 복원했고(각 문항 파일에
// `"verified": true` 가 처음 들어온 커밋의 날짜), 이후는 `review.mjs flip` 이 원장에 항목을 더한다.
//
// ⚠️ CI 는 얕은 클론(`actions/checkout` 기본 fetch-depth 1)이라 git 이력을 볼 수 없다 — 그래서 이력을
// 계산하지 않고 **커밋된 원장**을 본다. flip 커밋·공개 후 수정 횟수처럼 git 에서 매번 바뀌는 값은 원장에
// 넣지 않는다(저장하면 다음 커밋에서 조용히 낡는다). 그 값은 `node tool/review.mjs ledger <cert>` 가 로컬에서
// git 으로 계산해 보여 준다.
//
// ⚠️ 「누가」는 저장하지 않는다 — flip 은 사람만 하는 규율(CLAUDE.md)이고, 원장에 `reviewer` 를 적어도
// 그것을 검증할 수단이 없다.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

final _date = RegExp(r'^\d{4}-\d{2}-\d{2}$');

/// 디스크에서 Task 별 verified 문항 수(1 이상인 것만).
Map<String, int> _verifiedByTask(Directory certDir) {
  final out = <String, int>{};
  final files = certDir.listSync().whereType<File>().where((f) => f.path.endsWith('.questions.json'));
  for (final f in files) {
    final bank = json.decode(f.readAsStringSync()) as Map<String, dynamic>;
    final n = (bank['questions'] as List).where((q) => (q as Map)['verified'] == true).length;
    if (n > 0) out[bank['examGuideTaskId'] as String] = n;
  }
  return out;
}

void main() {
  final certDirs = Directory('assets/content').listSync().whereType<Directory>().toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  String certOf(Directory d) => d.uri.pathSegments.where((s) => s.isNotEmpty).last;

  test('대조군: 공개 문항이 있는 자격증이 여럿이고 원장 항목이 실제로 읽힌다(이 가드가 공허하지 않다)', () {
    final withVerified = certDirs.where((d) => _verifiedByTask(d).isNotEmpty).toList();
    expect(withVerified.length, greaterThanOrEqualTo(8));
    var entries = 0;
    for (final d in withVerified) {
      final f = File('../docs/review-ledger/${certOf(d)}.json');
      expect(f.existsSync(), isTrue, reason: '${certOf(d)}: 원장 파일이 없다');
      entries += ((json.decode(f.readAsStringSync()) as Map)['entries'] as List).length;
    }
    expect(entries, greaterThan(100));
  });

  for (final d in certDirs) {
    final cert = certOf(d);
    test('$cert: 원장의 Task·문항 수가 디스크의 verified 상태와 같다', () {
      final disk = _verifiedByTask(d);
      final f = File('../docs/review-ledger/$cert.json');
      if (disk.isEmpty) {
        // 공개 문항이 없는 자격증(예: 미등재 DVA)은 원장이 없거나 비어 있어야 한다.
        if (f.existsSync()) {
          expect((json.decode(f.readAsStringSync()) as Map)['entries'], isEmpty);
        }
        return;
      }
      final ledger = json.decode(f.readAsStringSync()) as Map<String, dynamic>;
      expect(ledger['cert'], cert);
      final entries = (ledger['entries'] as List).cast<Map<String, dynamic>>();
      final byTask = {for (final e in entries) e['taskId'] as String: e};
      expect(byTask.length, entries.length, reason: '$cert: 원장에 같은 Task 가 두 번 있다');
      expect(byTask.keys.toSet(), disk.keys.toSet(),
          reason: '$cert: 공개된 Task 와 원장의 Task 가 다르다 — flip 했으면 원장에도 있어야 한다');
      for (final e in entries) {
        final id = e['taskId'] as String;
        expect(e['questions'], disk[id], reason: '$id: 원장 문항 수 ≠ 디스크 verified 수');
        expect(_date.hasMatch(e['verifiedAt'] as String), isTrue, reason: '$id: verifiedAt 형식');
      }
      final ids = entries.map((e) => e['taskId'] as String).toList();
      expect(ids, [...ids]..sort(), reason: '$cert: 원장은 taskId 순으로 정렬한다(diff 안정성)');
    });
  }
}
