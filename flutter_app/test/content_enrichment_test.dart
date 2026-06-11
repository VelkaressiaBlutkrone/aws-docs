import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// 고도화 템플릿(스펙 2026-06-11-content-enrichment-design.md §4) 마커 검증.
/// 고도화 완료 문서만 목록에 올린다(점진적 롤아웃 지원 — soa_content_structure_test 패턴).
void main() {
  const enriched = <String>[
    'assets/content/clf/t1-1.md', 'assets/content/clf/t1-2.md',
    'assets/content/clf/t1-3.md', 'assets/content/clf/t1-4.md',
    'assets/content/clf/t2-1.md', 'assets/content/clf/t2-2.md',
    'assets/content/clf/t2-3.md', 'assets/content/clf/t2-4.md',
    'assets/content/clf/t3-1.md', 'assets/content/clf/t3-2.md',
    'assets/content/clf/t3-3.md', 'assets/content/clf/t3-4.md',
    'assets/content/clf/t3-5.md', 'assets/content/clf/t3-6.md',
    'assets/content/clf/t3-7.md', 'assets/content/clf/t3-8.md',
    'assets/content/clf/t4-1.md', 'assets/content/clf/t4-2.md',
    'assets/content/clf/t4-3.md',
  ];

  for (final path in enriched) {
    final name = path.split('/').last;
    final body = File(path).readAsStringSync();

    test('$name: 🔤 용어 섹션이 🎯와 📖 사이에 존재', () {
      final terms = body.indexOf('## 🔤 먼저 알아야 할 용어');
      final why = body.indexOf('## 🎯 왜 중요한가');
      final concepts = body.indexOf('## 📖 핵심 개념');
      expect(terms, greaterThan(-1), reason: '$name 용어 섹션 누락');
      expect(terms, greaterThan(why), reason: '$name 용어 섹션은 🎯 뒤');
      expect(terms, lessThan(concepts), reason: '$name 용어 섹션은 📖 앞');
    });

    test('$name: 모든 개념 서브섹션에 🧠 원리 블록 ≥1', () {
      final concepts = body.substring(body.indexOf('## 📖 핵심 개념'),
          body.indexOf('## ✍️ 시험 포인트'));
      final subsections = '### '.allMatches(concepts).length;
      final principles = '> 🧠 원리:'.allMatches(concepts).length;
      expect(subsections, greaterThan(0), reason: '$name 서브섹션 파싱 실패');
      expect(principles, greaterThanOrEqualTo(subsections),
          reason: '$name 서브섹션 $subsections개 중 원리 블록 $principles개');
    });

    test('$name: 자가 점검에 원리형(왜) 문항 존재', () {
      final selfCheck = body.substring(body.indexOf('## 🧪 자가 점검'));
      final whyQ = RegExp(r'^\*\*Q\d+.*왜', multiLine: true);
      expect(whyQ.hasMatch(selfCheck), isTrue,
          reason: '$name 자가 점검에 "왜 ~인가" 원리형 문항 필요');
    });
  }
}
