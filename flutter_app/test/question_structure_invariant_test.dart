// 전 자격증 문항 구조 불변식 가드 (2026-11-18 외부 리뷰 후속 §4-1).
//
// 자격증마다 `*_questions_test.dart` 가 정답 범위·ID 중복을 단정하지만 **범위가 제각각**이었다 —
// CLF 는 `clf_supplement_questions_test` 가 19 Task 중 7개만 봤다. 그리고 문항 모델
// (`lib/models/question.dart`)은 `correct` 가 없으면 예외 없이 −1 로 읽어, 그런 문항은 화면에서
// 「정답이 없는 문항」이 된다. 그래서 자격증별 가드와 별개로 **디스크의 모든 문항 파일**을
// 디렉터리에서 유도해 같은 규칙으로 센다(드래프트 포함 — 언제든 flip 될 수 있다).
//
// 규칙은 2026-11-18 에 2,288문항 전수로 성립을 먼저 확인한 것만 넣었다(위반 0건).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

class _Bank {
  _Bank(this.cert, this.file, this.json);
  final String cert;
  final File file;
  final Map<String, dynamic> json;

  String get base => file.uri.pathSegments.last.replaceAll('.questions.json', '');

  /// CLF 는 파일명에 자격증 접두사가 없다(`t1-1.questions.json` → `clf-t1-1`).
  String get expectedTaskId => base.startsWith('$cert-') ? base : '$cert-$base';

  List<Map<String, dynamic>> get questions =>
      (json['questions'] as List).cast<Map<String, dynamic>>();
}

List<_Bank> _loadAll() {
  final banks = <_Bank>[];
  final dirs = Directory('assets/content').listSync().whereType<Directory>().toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  for (final dir in dirs) {
    final cert = dir.uri.pathSegments.where((s) => s.isNotEmpty).last;
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.questions.json'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    for (final f in files) {
      banks.add(_Bank(cert, f, json.decode(f.readAsStringSync()) as Map<String, dynamic>));
    }
  }
  return banks;
}

bool _nonBlank(Object? v) => v is String && v.trim().isNotEmpty;

void main() {
  final banks = _loadAll();
  final all = [for (final b in banks) for (final q in b.questions) (b, q)];

  test('대조군: 여러 자격증의 문항 파일을 실제로 읽었다(이 가드가 공허하지 않다)', () {
    expect(banks.map((b) => b.cert).toSet().length, greaterThanOrEqualTo(8));
    expect(all.length, greaterThan(2000));
    // CLF 는 파일명 규칙이 다르다 — 그 분기가 실제로 쓰였는지 확인한다.
    expect(banks.any((b) => b.cert == 'clf' && b.expectedTaskId == 'clf-${b.base}'), isTrue);
  });

  test('뱅크의 examGuideTaskId 가 파일 위치와 맞고 questions 가 비어 있지 않다', () {
    final bad = <String>[];
    for (final b in banks) {
      if (b.json['examGuideTaskId'] != b.expectedTaskId) {
        bad.add('${b.file.path}: examGuideTaskId=${b.json['examGuideTaskId']} 기대=${b.expectedTaskId}');
      }
      if (b.questions.isEmpty) bad.add('${b.file.path}: questions 비어 있음');
    }
    expect(bad, isEmpty, reason: bad.join('\n'));
  });

  test('문항 ID 가 레포 전역에서 유일하고 그 뱅크의 Task 접두사를 쓴다', () {
    final seen = <String, String>{};
    final bad = <String>[];
    for (final (b, q) in all) {
      final id = q['id'];
      if (!_nonBlank(id)) {
        bad.add('${b.file.path}: id 없음');
        continue;
      }
      if (!(id as String).startsWith('${b.expectedTaskId}-q')) {
        bad.add('$id: ${b.expectedTaskId}-q 접두사가 아니다');
      }
      final prev = seen[id];
      if (prev != null) bad.add('$id: 중복 (${b.file.path} · $prev)');
      seen[id] = b.file.path;
    }
    expect(bad, isEmpty, reason: bad.join('\n'));
  });

  test('필수 필드 · 보기 4개(비어 있지 않고 서로 다름) · 정답 인덱스 범위 · verified 는 bool', () {
    final bad = <String>[];
    for (final (_, q) in all) {
      final id = q['id'];
      for (final k in ['stem', 'explanation']) {
        if (!_nonBlank(q[k])) bad.add('$id: $k 비어 있음');
      }
      final options = q['options'];
      if (options is! List || options.length != 4) {
        bad.add('$id: 보기가 4개가 아니다');
        continue;
      }
      if (options.any((o) => !_nonBlank(o))) bad.add('$id: 빈 보기');
      if (options.toSet().length != 4) bad.add('$id: 같은 보기가 둘 이상');
      final correct = q['correct'];
      if (correct is! int || correct < 0 || correct >= options.length) {
        bad.add('$id: correct=$correct 범위 밖(모델은 누락을 −1 로 읽는다)');
      }
      if (q['verified'] is! bool) bad.add('$id: verified 가 bool 이 아니다');
      if (q['sources'] is! List || (q['sources'] as List).isEmpty) bad.add('$id: sources 없음');
    }
    expect(bad, isEmpty, reason: bad.join('\n'));
  });

  test('오답 근거(wrongExplanations)가 정답을 뺀 세 보기를 정확히 덮는다', () {
    final bad = <String>[];
    for (final (_, q) in all) {
      final id = q['id'];
      final correct = q['correct'];
      final we = q['wrongExplanations'];
      if (correct is! int) continue; // 위 테스트가 잡는다
      if (we is! Map) {
        bad.add('$id: wrongExplanations 없음');
        continue;
      }
      final want = {for (var i = 0; i < 4; i++) if (i != correct) '$i'};
      if (we.keys.toSet().difference(want).isNotEmpty || want.difference(we.keys.toSet()).isNotEmpty) {
        bad.add('$id: 키 ${we.keys.toList()} 기대 $want');
      }
      if (we.values.any((v) => !_nonBlank(v))) bad.add('$id: 빈 오답 근거');
    }
    expect(bad, isEmpty, reason: bad.join('\n'));
  });
}
