import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// SOA 학습문서가 SAA 템플릿 7개 섹션 + Task 앵커 + 출처를 갖췄는지 검증.
/// assets/content/soa/ 에 존재하는 .md 만 검사한다(점진적 집필 지원).
void main() {
  final dir = Directory('assets/content/soa');
  final mdFiles = dir.existsSync()
      ? dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.md'))
          .toList()
      : <File>[];

  const requiredMarkers = <String>[
    '커버하는 공식 Task',
    '## ✅ 학습 목표 체크리스트',
    '## 🎯 왜 중요한가',
    '## 📖 핵심 개념',
    '## ✍️ 시험 포인트',
    '## ⚠️ 흔한 함정',
    '## 🧪 자가 점검',
    '### 📌 출처',
  ];

  test('SOA 문서 디렉터리에 .md가 1개 이상 존재', () {
    expect(mdFiles, isNotEmpty,
        reason: 'soa-t1-1.md 부터 집필되어야 한다');
  });

  for (final f in mdFiles) {
    final name = f.uri.pathSegments.last;
    final body = f.readAsStringSync();
    test('$name: 템플릿 7개 섹션 + Task 앵커 + 출처', () {
      for (final marker in requiredMarkers) {
        expect(body.contains(marker), isTrue,
            reason: '$name 에 "$marker" 누락');
      }
    });
    test('$name: SOA-C03 Task 앵커 명시', () {
      expect(body.contains('SOA-C03'), isTrue,
          reason: '$name 머리말에 SOA-C03 Task 앵커 필요');
    });
    test('$name: 출처에 실제 AWS URL 기록', () {
      final sourceIdx = body.indexOf('### 📌 출처');
      expect(sourceIdx, greaterThan(-1));
      final sourceSection = body.substring(sourceIdx);
      expect(sourceSection.contains('https://'), isTrue,
          reason: '$name 출처 섹션에 https:// URL 필요(게이트 규율)');
    });
  }
}
