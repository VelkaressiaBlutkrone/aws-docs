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
    'assets/content/saa/saa-t1-1.md', 'assets/content/saa/saa-t1-2.md',
    'assets/content/saa/saa-t1-3.md', 'assets/content/saa/saa-t1-4.md',
    'assets/content/saa/saa-t1-5.md', 'assets/content/saa/saa-t2-1.md',
    'assets/content/saa/saa-t2-2.md', 'assets/content/saa/saa-t2-3.md',
    'assets/content/saa/saa-t2-4.md', 'assets/content/saa/saa-t2-5.md',
    'assets/content/saa/saa-t3-1.md', 'assets/content/saa/saa-t3-2.md',
    'assets/content/saa/saa-t3-3.md', 'assets/content/saa/saa-t3-4.md',
    'assets/content/saa/saa-t3-5.md', 'assets/content/saa/saa-t3-6.md',
    'assets/content/saa/saa-t3-7.md', 'assets/content/saa/saa-t3-8.md',
    'assets/content/saa/saa-t3-9.md', 'assets/content/saa/saa-t4-1.md',
    'assets/content/saa/saa-t4-2.md', 'assets/content/saa/saa-t4-3.md',
    'assets/content/saa/saa-t4-4.md', 'assets/content/saa/saa-t4-5.md',
    'assets/content/soa/soa-t1-1.md', 'assets/content/soa/soa-t1-2.md',
    'assets/content/soa/soa-t1-3.md', 'assets/content/soa/soa-t1-4.md',
    'assets/content/soa/soa-t1-5.md', 'assets/content/soa/soa-t2-1.md',
    'assets/content/soa/soa-t2-2.md', 'assets/content/soa/soa-t2-3.md',
    'assets/content/soa/soa-t2-4.md', 'assets/content/soa/soa-t3-1.md',
    'assets/content/soa/soa-t3-2.md', 'assets/content/soa/soa-t3-3.md',
    'assets/content/soa/soa-t3-4.md', 'assets/content/soa/soa-t4-1.md',
    'assets/content/soa/soa-t4-2.md', 'assets/content/soa/soa-t4-3.md',
    'assets/content/soa/soa-t5-1.md', 'assets/content/soa/soa-t5-2.md',
    'assets/content/soa/soa-t5-3.md', 'assets/content/soa/soa-t5-4.md',
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

    test('$name: 개념 서브섹션에 🧠 원리 블록 (하한 = min(서브섹션, 8))', () {
      final concepts = body.substring(body.indexOf('## 📖 핵심 개념'),
          body.indexOf('## ✍️ 시험 포인트'));
      // ^### 만 카운트(#### 세부 facet 제외). 14-섹션급 레퍼런스형 문서의
      // 과밀을 막기 위해 하한은 8로 캡(절제 지침) — 초과분은 고가치 섹션 우선.
      final subsections =
          RegExp(r'^### ', multiLine: true).allMatches(concepts).length;
      final principles = '> 🧠 원리:'.allMatches(concepts).length;
      expect(subsections, greaterThan(0), reason: '$name 서브섹션 파싱 실패');
      final required = subsections > 8 ? 8 : subsections;
      expect(principles, greaterThanOrEqualTo(required),
          reason: '$name 서브섹션 $subsections개(하한 $required) 중 원리 블록 $principles개');
    });

    test('$name: 자가 점검에 원리형(왜) 문항 존재', () {
      final selfCheck = body.substring(body.indexOf('## 🧪 자가 점검'));
      final whyQ = RegExp(r'^\*\*Q\d+.*왜', multiLine: true);
      expect(whyQ.hasMatch(selfCheck), isTrue,
          reason: '$name 자가 점검에 "왜 ~인가" 원리형 문항 필요');
    });
  }
}
