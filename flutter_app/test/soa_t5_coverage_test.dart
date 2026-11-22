import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// SOA D5 공개 문항 4건의 정답 사실이 **그 문항이 링크하는 절 안에** 있는가.
///
/// 2026-11-22 C 트랙 배치 6 이 찾은 커버리지 공백이다. 문항은 공식 출처가 있어
/// 사실 결함이 아니었지만, 해설의 「학습문서로 이동」을 눌러도 그 사실을 만나지
/// 못했다. 그래서 파일 전체가 아니라 **`section` 이 가리키는 절**을 잘라 센다 —
/// 같은 문장이 다른 절에 있으면 딥링크가 빗나가는데 파일 단위 검사는 통과한다.
///
/// `verified` 는 단정하지 않는다(flip 은 사람의 서명이고 상태를 박으면 그 flip 이
/// 레드로 끝난다). `lastVerified` 날짜 고정은 `soa_facts_test` 의 맵이 맡는다.
String _md(String taskId) =>
    File('assets/content/soa/$taskId.md').readAsStringSync();

/// `{#anchor}` 제목부터 다음 `##`·`###` 제목 앞까지.
String _section(String md, String anchor) {
  final at = md.indexOf('{#$anchor}');
  expect(at, greaterThanOrEqualTo(0), reason: '앵커 없음: $anchor');
  final bodyStart = md.indexOf('\n', at);
  final next = RegExp(r'^#{2,3} ', multiLine: true).firstMatch(
    md.substring(bodyStart),
  );
  return next == null
      ? md.substring(bodyStart)
      : md.substring(bodyStart, bodyStart + next.start);
}

Map<String, dynamic> _question(String taskId, String id) {
  final bank =
      jsonDecode(
            File(
              'assets/content/soa/$taskId.questions.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
  return (bank['questions'] as List).cast<Map<String, dynamic>>().firstWhere(
    (q) => q['id'] == id,
  );
}

void _expectAll(String text, List<String> tokens, String label) {
  final missing = tokens.where((t) => !text.contains(t)).toList();
  expect(missing, isEmpty, reason: '$label 절에 없다: $missing');
}

void main() {
  group('대조군', () {
    test('절 추출이 제 절만 자른다', () {
      final cf = _section(_md('soa-t5-3'), 'cloudfront');
      expect(cf.contains('OAC'), isTrue);
      // 다음 절의 본문이 섞이면 사실이 옆 절에 있어도 통과한다.
      expect(cf.contains('웹사이트 엔드포인트'), isFalse);
      final fields = _section(_md('soa-t5-4'), 'flow-log-fields');
      expect(fields.contains('srcaddr'), isTrue);
      expect(fields.contains('기록하지 않는 트래픽'), isFalse);
    });

    test('네 문항의 section·정답은 이 보강으로 바뀌지 않았다', () {
      const expected = <List<Object>>[
        ['soa-t5-3', 'soa-t5-3-q15', 'cloudfront', 0],
        ['soa-t5-4', 'soa-t5-4-q7', 'vpc-flow-logs', 0],
        ['soa-t5-4', 'soa-t5-4-q13', 'vpc-flow-logs', 0],
        ['soa-t5-4', 'soa-t5-4-q14', 'flow-log-fields', 0],
      ];
      for (final e in expected) {
        final q = _question(e[0] as String, e[1] as String);
        expect(q['section'], e[2], reason: '${e[1]} section');
        expect(q['correct'], e[3], reason: '${e[1]} correct');
      }
    });
  });

  group('문항이 링크하는 절에 정답 사실이 있다', () {
    test('soa-t5-3-q15 → cloudfront: Global Accelerator', () {
      _expectAll(
        _section(_md('soa-t5-3'), 'cloudfront'),
        [
          'Global Accelerator',
          '애니캐스트',
          '비-HTTP',
          'TCP',
          'UDP',
          'Network Load Balancer',
          'Application Load Balancer',
          'EC2 인스턴스',
          'Elastic IP',
          // CloudFront 도 Anycast 고정 IP 목록을 제공하므로 「고정 IP」만으로는
          // 두 서비스를 가를 수 없다(`request-static-ips.html`).
          'Anycast 고정 IP 목록',
        ],
        'cloudfront',
      );
    });

    test('soa-t5-4-q7 → vpc-flow-logs: 집계 간격', () {
      _expectAll(
        _section(_md('soa-t5-4'), 'vpc-flow-logs'),
        ['집계 간격', '최대 **10분**', '최대 **1분**', 'Nitro', '**1분 이하**'],
        'vpc-flow-logs',
      );
    });

    test('soa-t5-4-q13 → vpc-flow-logs: ELB 액세스 로그', () {
      _expectAll(
        _section(_md('soa-t5-4'), 'vpc-flow-logs'),
        ['ELB 액세스 로그', '요청', '클라이언트 IP', 'S3', '기본으로 꺼져'],
        'vpc-flow-logs',
      );
    });

    test('soa-t5-4-q14 → flow-log-fields: WAF 웹 ACL 로깅', () {
      _expectAll(
        _section(_md('soa-t5-4'), 'flow-log-fields'),
        [
          'WAF 웹 ACL 로깅',
          'terminatingRuleId',
          'nonTerminatingMatchingRules',
          'CloudWatch Logs',
          'S3',
          'Amazon Data Firehose',
        ],
        'flow-log-fields',
      );
    });
  });

  group('새 출처가 프런트매터와 「출처」 절 양쪽에 있다', () {
    void expectBoth(String taskId, List<String> urls) {
      final md = _md(taskId);
      final fmEnd = md.indexOf('lastVerified:');
      final refs = md.indexOf('### 📌 출처');
      expect(fmEnd, greaterThan(0));
      expect(refs, greaterThan(fmEnd));
      final front = md.substring(0, fmEnd);
      final back = md.substring(refs);
      for (final u in urls) {
        expect(front.contains('url: $u'), isTrue, reason: '프런트매터 누락: $u');
        expect(back.contains(u), isTrue, reason: '출처 절 누락: $u');
      }
    }

    test('soa-t5-3', () {
      expectBoth('soa-t5-3', const [
        'https://docs.aws.amazon.com/global-accelerator/latest/dg/what-is-global-accelerator.html',
        'https://docs.aws.amazon.com/global-accelerator/latest/dg/introduction-components.html',
        'https://aws.amazon.com/global-accelerator/faqs/',
        'https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/request-static-ips.html',
      ]);
    });

    test('soa-t5-4', () {
      expectBoth('soa-t5-4', const [
        'https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html',
        'https://docs.aws.amazon.com/waf/latest/developerguide/logging.html',
        'https://docs.aws.amazon.com/waf/latest/developerguide/logging-fields.html',
      ]);
    });
  });
}
