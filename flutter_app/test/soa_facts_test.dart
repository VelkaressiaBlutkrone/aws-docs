import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// SOA-C03 학습문서의 사실 정정 가드 (2026-10-19).
///
/// SOA 문항 드래프트(300개)를 작성하는 과정에서 본문이 공식 문서와 어긋나는
/// 지점 4건을 찾아 출제하지 않고 남겨 두었다. 이 테스트는 그 4건을 공식 문장
/// 기준으로 정정한 상태를 고정한다(saa_t1_facts_test.dart·
/// saa_t2_t4_facts_test.dart와 같은 패턴). 근거를 찾지 못한 하위 주장은
/// 본문에 쓰지 않았다(PR 본문에 기록).
void main() {
  String doc(String id) => File('assets/content/soa/$id.md').readAsStringSync();

  group('F-1 Flow Logs의 REJECT 의미 (soa-t5-4)', () {
    // 근거: flow-log-records — "REJECT — The traffic was rejected. For example,
    // the traffic was not allowed by the security groups or network ACLs, or
    // packets arrived after the connection was closed."
    test('"SG 거부는 REJECT로 드러나지 않는다"는 서술이 사라졌다', () {
      final t = doc('soa-t5-4');
      expect(t.contains('REJECT로 잘 드러나지 않'), isFalse);
      expect(t.contains('REJECT로 잘 안 보임'), isFalse);
      expect(t.contains('REJECT 부재'), isFalse);
      expect(t.contains('REJECT 로그를 남기지 않습니다'), isFalse);
      expect(t.contains('SG 거부는 Flow Log에 잘 안 보이고'), isFalse);
    });

    test('공식 action 정의(보안 그룹 또는 네트워크 ACL)가 들어왔다', () {
      final t = doc('soa-t5-4');
      expect(t.contains('보안 그룹 또는 네트워크 ACL이 허용하지 않은'), isTrue);
      expect(t.contains('연결이 닫힌 뒤'), isTrue);
    });

    test('Flow Logs가 기록하지 않는 트래픽 목록이 들어왔다', () {
      // 근거: flow-logs-limitations — "Flow logs do not capture all IP traffic.
      // The following types of traffic are not logged: ... Amazon DNS server ...
      // 169.254.169.254 for instance metadata ... DHCP traffic ..."
      final t = doc('soa-t5-4');
      expect(t.contains('Amazon DNS 서버'), isTrue);
      expect(t.contains('169.254.169.254'), isTrue);
      expect(t.contains('DHCP'), isTrue);
    });
  });

  group('F-2 KMS 키 정책의 위임 구조 (soa-t4-3)', () {
    // 근거: key-policy-overview — 계정 주체(`:root`) 문장은 "gives the AWS
    // account permission to use IAM policies to delegate the permissions",
    // 그리고 "If you don't explicitly allow access to a KMS key, access is
    // implicitly denied."
    test('"키 정책 + IAM 정책의 교집합" 서술이 사라졌다', () {
      final t = doc('soa-t4-3');
      expect(t.contains('키 정책 + IAM 정책의 교집합'), isFalse);
      expect(t.contains('IAM 정책만으로는 CMK에 접근할 수 없고'), isFalse);
      expect(t.contains('IAM 정책과 교집합이 적용되어'), isFalse);
    });

    test('계정 위임과 암시적 거부로 서술한다', () {
      final t = doc('soa-t4-3');
      expect(t.contains('위임'), isTrue);
      expect(t.contains('암시적으로 거부'), isTrue);
    });
  });

  group('F-3 ACM 인증서 요금 (soa-t4-3)', () {
    // 근거: ACM 요금 — "By default, ACM issues certificates at no cost for use
    // with services integrated with ACM"이지만 내보내기 가능 공인 인증서는
    // 발급·갱신 시 과금(표준 FQDN $7, 와일드카드 $79).
    test('"공인 인증서는 무료"라는 단정이 사라졌다', () {
      final t = doc('soa-t4-3');
      expect(t.contains('공인 TLS 인증서는 **무료**'), isFalse);
      expect(t.contains('ACM 공인 인증서 무료'), isFalse);
    });

    test('내보내기 가능 인증서는 유료임을 명시한다', () {
      final t = doc('soa-t4-3');
      expect(t.contains('내보내기 가능'), isTrue);
      expect(t.contains('통합 서비스'), isTrue);
    });
  });

  group('F-4 Trusted Advisor 지원 플랜 (soa-t4-2)', () {
    // 근거: trusted-advisor — "AWS Trusted Advisor checks are available to
    // customers with an AWS Business Support+, AWS Enterprise Support, or AWS
    // Unified Operations plan." / Basic은 "all checks in the Service Limits
    // category and selected checks in the Security and Fault tolerance
    // categories", 자동 갱신 없음.
    test('구식 플랜 명칭이 사라졌다', () {
      final t = doc('soa-t4-2');
      expect(t.contains('Business/Enterprise Support 플랜'), isFalse);
      expect(t.contains('Business/Enterprise 지원 플랜'), isFalse);
    });

    test('현행 플랜명과 Basic 범위가 들어왔다', () {
      final t = doc('soa-t4-2');
      expect(t.contains('Business Support+'), isTrue);
      expect(t.contains('Unified Operations'), isTrue);
      expect(t.contains('서비스 한도'), isTrue);
      expect(t.contains('자동 갱신'), isTrue);
    });
  });

  group('F-5 ElastiCache 엔진 3종 (soa-t1-5)', () {
    // 근거: SelectEngine — "Amazon ElastiCache supports the Valkey, Memcached,
    // and Redis OSS cache engines."
    test('Redis/Memcached 2종 비교표 머리글이 사라졌다', () {
      final t = doc('soa-t1-5');
      expect(t.contains('| 항목 | Redis (ElastiCache for Redis/Valkey) | Memcached |'),
          isFalse);
    });

    test('Valkey·Redis OSS·Memcached 3종으로 서술한다', () {
      final t = doc('soa-t1-5');
      expect(t.contains('Valkey'), isTrue);
      expect(t.contains('Redis OSS'), isTrue);
    });
  });

  group('F-6 DynamoDB 글로벌 테이블 일관성 모드 (soa-t2-4)', () {
    // 근거: GlobalTables — "Global tables support two consistency modes:
    // multi-Region eventual consistency (MREC) and multi-Region strong
    // consistency (MRSC)."
    test('"최종 일관성" 단독 서술이 사라지고 MREC·MRSC가 들어왔다', () {
      final t = doc('soa-t2-4');
      expect(t.contains('멀티 리전 활성·활성, 최종 일관성'), isFalse);
      expect(t.contains('MREC'), isTrue);
      expect(t.contains('MRSC'), isTrue);
    });
  });

  group('F-7 본문 끝 artifact 정리', () {
    test('어떤 SOA 학습문서에도 </content> 잔재가 없다', () {
      final files = Directory('assets/content/soa')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.md'))
          .toList();
      expect(files.length, greaterThanOrEqualTo(20));
      for (final f in files) {
        expect(f.readAsStringSync().contains('</content>'), isFalse,
            reason: '${f.path} 에 작성 artifact가 남아 있다');
      }
    });
  });

  group('정정 날짜·출처', () {
    test('정정한 문서의 lastVerified가 갱신됐다', () {
      // 이 5개 문서는 2026-10-19 사실 정정으로 갱신됐다. 그 뒤 2026-10-20에
      // 공식 가이드 v1.1 신규 주제를 반영한 3개(soa-t1-5·t2-4·t4-2)는 그 날짜로
      // 다시 갱신됐으므로 문서별 기대값을 명시한다(느슨한 비교가 아니다).
      // v1.1 반영분 10개 문서의 전수 고정은 soa_v11_topics_test.dart V-15.
      const expected = <String, String>{
        'soa-t1-5': '2026-10-20',
        'soa-t2-4': '2026-10-20',
        'soa-t4-2': '2026-10-20',
        'soa-t4-3': '2026-10-19',
        'soa-t5-4': '2026-10-19',
      };
      expected.forEach((id, date) {
        expect(doc(id).contains('lastVerified: $date'), isTrue,
            reason: '$id lastVerified가 $date 가 아니다');
      });
    });

    test('새로 인용한 공식 출처가 실려 있다', () {
      expect(doc('soa-t5-4').contains('flow-log-records'), isTrue);
      expect(doc('soa-t5-4').contains('flow-logs-limitations'), isTrue);
      expect(doc('soa-t4-3').contains('key-policy-overview'), isTrue);
      expect(doc('soa-t4-3').contains('certificate-manager/pricing'), isTrue);
      expect(doc('soa-t4-2').contains('premiumsupport/plans'), isTrue);
      expect(doc('soa-t1-5').contains('SelectEngine'), isTrue);
      expect(doc('soa-t2-4').contains('GlobalTables'), isTrue);
    });
  });

  group('F-8 EventBridge 는 경보 작업이 아니다 (soa-t1-1, 2026-11-01)', () {
    // 근거: alarm-actions — 지원되는 경보 작업은 SNS 알림 · Lambda 함수 호출 ·
    // EC2 작업(중지·종료·재부팅·복구) · Auto Scaling 그룹 · Application Auto
    // Scaling · Systems Manager OpsItem · Systems Manager Incident Manager ·
    // 조사 시작이고, 같은 페이지가 "Alarms also emit events to Amazon
    // EventBridge when they change state"라고 적는다. 표에도 EventBridge 행이
    // 없다. 이 문서의 §4 표가 EventBridge 를 작업 대상으로 싣고 있었고,
    // 거기서 파생된 문항이 soa-t1-1-q11 이다(루브릭 T6 — md 가 선결).
    test('§4 표에서 EventBridge 행이 사라졌다', () {
      final t = doc('soa-t1-1');
      expect(t.contains('| **EventBridge** |'), isFalse,
          reason: 'EventBridge 는 경보 작업 표에 들어갈 항목이 아니다');
    });

    test('시험 직전 요약의 작업 목록에서도 빠졌다', () {
      final t = doc('soa-t1-1');
      expect(t.contains('Systems Manager, EventBridge.'), isFalse);
    });

    test('공식 작업 목록의 Lambda 가 들어왔다', () {
      final t = doc('soa-t1-1');
      expect(t.contains('**Lambda 함수**'), isTrue,
          reason: '공식 목록이 "Invoke a Lambda function"을 두 번째로 적는데 빠져 있었다');
    });

    test('EventBridge 가 이벤트 수신처라는 공식 사실이 들어왔다', () {
      final t = doc('soa-t1-1');
      expect(t.contains('이벤트를 내보냅니다'), isTrue);
      expect(t.contains('경보 작업이 아니라'), isTrue);
    });
  });
}
