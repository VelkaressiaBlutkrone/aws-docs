import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 2026-11-22 CLF 학습문서 커버리지 보강 가드.
///
/// C 트랙(#661)이 `section` 을 채우며 **정답 사실이 그 Task 학습문서에 없는 공개 문항
/// 12건**을 일부러 연결하지 않았다. 이 배치가 그 사실을 학습문서에 넣고 문항을 연결했다.
///
/// 문서 전체에 낱말이 있는지가 아니라 **문항이 가리키는 절 안에** 정답 사실이 있는지를 본다.
/// 낱말이 다른 절에만 있으면 학습자가 답이 없는 곳에 도착하기 때문이다.
///
/// 12건 모두 공식 CLF-C02 「범위 내 AWS 서비스」 목록에 이름이 있거나(Macie · Secrets Manager ·
/// Redshift · Neptune · DocumentDB · Step Functions · API Gateway · VPC · AWS Support)
/// 작업 4.1 지식 항목(컴퓨팅 구매 옵션)에 있어 범위 메모가 필요 없다.
class _Case {
  const _Case(this.id, this.anchor, this.correct, this.facts);

  final String id;
  final String anchor;

  /// 이 배치는 `section` 만 넣는다 — 정답이 바뀌면 안 된다.
  final int correct;

  /// 그 절 안에 있어야 하는 정답 사실의 낱말.
  final List<String> facts;

  String get task => id.replaceFirst('clf-', '').split('-q').first;
}

const _cases = <_Case>[
  _Case('clf-t2-4-q9', 'macie-secrets', 2,
      ['Amazon Macie', '머신러닝', '패턴 매칭', 'Amazon S3', 'PII']),
  _Case('clf-t2-4-q10', 'macie-secrets', 3,
      ['AWS Secrets Manager', 'API 키', '자동 교체', '하드코딩', 'KMS']),
  _Case('clf-t3-3-q8', 'purchase-options', 2,
      ['스팟 인스턴스', 'Spot', '미사용', '중단', '2분', '배치']),
  // 공식 EC2 문서가 예약 인스턴스보다 Savings Plans 를 권장하므로 그 사실이 함께 있어야 한다.
  _Case('clf-t3-3-q12', 'purchase-options', 0,
      ['예약 인스턴스', 'Reserved', '1년 또는 3년', 'Savings Plans']),
  // Redshift 는 공식 범위 목록에서 데이터베이스가 아니라 「분석」 범주다.
  _Case('clf-t3-4-q7', 'purpose-built', 1,
      ['Amazon Redshift', '페타바이트', '데이터 웨어하우스', 'BI', '분석']),
  _Case('clf-t3-4-q8', 'purpose-built', 2,
      ['Amazon Neptune', '그래프', 'Gremlin', 'openCypher', 'SPARQL', '밀리초']),
  _Case('clf-t3-4-q9', 'purpose-built', 3,
      ['Amazon DocumentDB', 'MongoDB', '드라이버']),
  // §3 의 「키-값 + 문서」만 읽으면 ②를 DynamoDB 로 오해한다 — 같은 절에서 갈라야 한다.
  _Case('clf-t3-4-q10', 'purpose-built', 0,
      ['Neptune', 'DocumentDB', 'DynamoDB', '키-값']),
  _Case('clf-t3-5-q12', 'vpc-peering', 0,
      ['VPC 피어링', '사설 IP', '공용 인터넷', '전이', 'CIDR']),
  _Case('clf-t3-8-q7', 'workflow-api', 1,
      ['AWS Step Functions', '상태 머신', '분기', '재시도']),
  _Case('clf-t3-8-q9', 'workflow-api', 3,
      ['Amazon API Gateway', 'REST', 'WebSocket', '스로틀링', '인증', '모니터링']),
  _Case('clf-t4-3-q10', 'support-api', 2, [
    'AWS Support API',
    'Business Support+',
    'Enterprise Support',
    'Unified Operations',
    'Trusted Advisor',
    '케이스',
  ]),
];

String _doc(String task) => File('assets/content/clf/$task.md')
    .readAsStringSync()
    .replaceAll('\r\n', '\n');

Map<String, dynamic> _question(String task, String id) {
  final raw = jsonDecode(
    File('assets/content/clf/$task.questions.json').readAsStringSync(),
  );
  final list = (raw is Map ? raw['questions'] : raw) as List;
  return list.cast<Map<String, dynamic>>().firstWhere((q) => q['id'] == id);
}

/// `{#anchor}` 제목부터 다음 `##`·`###` 제목 앞까지. 없으면 null.
String? _sectionBody(String doc, String anchor) {
  final start = doc.indexOf('{#$anchor}');
  if (start < 0) return null;
  final next = RegExp(r'\n#{2,3} ').firstMatch(doc.substring(start));
  return next == null
      ? doc.substring(start)
      : doc.substring(start, start + next.start);
}

Set<String> _frontmatterUrls(String doc) => RegExp(r'^\s+url:\s*(\S+)\s*$',
        multiLine: true)
    .allMatches(doc.split('\n---\n').first)
    .map((m) => m.group(1)!)
    .toSet();

String _sourcesSection(String doc) => doc.substring(doc.indexOf('### 📌 출처'));

void main() {
  test('대조군: 12문항이 6개 학습문서에 걸쳐 실재한다', () {
    expect(_cases, hasLength(12));
    expect(_cases.map((c) => c.id).toSet(), hasLength(12));
    expect(_cases.map((c) => c.task).toSet(), hasLength(6));
    for (final c in _cases) {
      expect(_question(c.task, c.id)['id'], c.id);
    }
  });

  test('대조군: 절 추출기가 다음 제목에서 멈춘다', () {
    const doc = '### 가 {#a}\n본문가\n### 나 {#b}\n본문나\n## 끝\n';
    expect(_sectionBody(doc, 'a'), contains('본문가'));
    expect(_sectionBody(doc, 'a'), isNot(contains('본문나')));
    expect(_sectionBody(doc, 'b'), isNot(contains('끝')));
    expect(_sectionBody(doc, 'zz'), isNull);
  });

  for (final c in _cases) {
    test('${c.id}: 가리키는 절 안에 정답 사실이 있고 출처가 문서에 있다', () {
      final q = _question(c.task, c.id);
      expect(q['correct'], c.correct, reason: '이 배치는 정답을 바꾸지 않는다');
      expect(q['section'], c.anchor);

      final doc = _doc(c.task);
      final body = _sectionBody(doc, c.anchor);
      expect(body, isNotNull, reason: '{#${c.anchor}} 절이 없다');
      for (final fact in c.facts) {
        expect(body!.contains(fact), isTrue,
            reason: '${c.id}: 「$fact」이 {#${c.anchor}} 절에 없다');
      }

      // 문항이 인용하는 페이지는 학습문서의 프런트매터와 「출처」 절 양쪽에 있어야 한다.
      final front = _frontmatterUrls(doc);
      final listed = _sourcesSection(doc);
      for (final s in (q['sources'] as List).cast<Map<String, dynamic>>()) {
        final url = s['url'] as String;
        expect(front.contains(url), isTrue, reason: '${c.id}: 프런트매터에 $url 없음');
        expect(listed.contains(url), isTrue, reason: '${c.id}: 출처 절에 $url 없음');
      }
    });
  }

  for (final entry in {
    't2-4': 'macie-secrets',
    't3-3': 'purchase-options',
    't3-4': 'purpose-built',
    't3-5': 'vpc-peering',
    't3-8': 'workflow-api',
    't4-3': 'support-api',
  }.entries) {
    test('${entry.key}: 새 절이 시험 포인트 앞에 있고 원리 블록을 가진다', () {
      final doc = _doc(entry.key);
      final at = doc.indexOf('{#${entry.value}}');
      expect(at, greaterThan(doc.indexOf('## 📖 핵심 개념')));
      expect(at, lessThan(doc.indexOf('## ✍️ 시험 포인트')));
      expect(_sectionBody(doc, entry.value), contains('> 🧠 원리:'));
    });
  }
}
