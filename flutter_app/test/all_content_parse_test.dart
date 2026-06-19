import 'dart:io';

import 'package:aws_docs/content/markdown_parser.dart';
import 'package:flutter_test/flutter_test.dart';

/// 회귀 가드 — 모든 학습문서가 `parseStudyDoc`으로 실제 파싱되는지 검증한다.
///
/// 배경: 기존엔 어떤 테스트도 실제 md 본문을 `parseStudyDoc` 하지 않아(파서
/// 테스트는 t2-1 한 건만, enrichment 테스트는 문자열 검증만) H4 헤딩(`####`)이
/// 파서를 무한루프에 빠뜨리는 결함(clf-t3-6 등 6개 문서)이 CI를 통과했다.
/// 디렉터리를 직접 순회해 신규 문서도 자동으로 가드한다.
void main() {
  final mdFiles = Directory('assets/content')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.md'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  test('학습문서 자산이 하나 이상 존재한다', () {
    expect(mdFiles, isNotEmpty);
  });

  for (final f in mdFiles) {
    final name = f.path.replaceAll('\\', '/').split('assets/content/').last;
    test('$name: parseStudyDoc 무한루프·예외 없이 파싱된다', () {
      final raw = f.readAsStringSync();
      final doc = parseStudyDoc(raw);
      expect(doc.blocks, isNotEmpty, reason: '$name 파싱 결과 블록이 비어있음');
    }, timeout: const Timeout(Duration(seconds: 15)));
  }
}
