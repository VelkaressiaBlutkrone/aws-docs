import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// SAA Task 1.2·1.3 학습문서의 사실 정정 가드 (2026-10-19).
///
/// 외부 조사(docs/content-research/SAA-C03/98-existing-gap.md)가 올린 항목 중
/// `[오류]`·`[구식]`·`[부정확]`만 공식 문서로 재확인한 뒤 정정했다. 확인하지 못한
/// 하위 주장은 쓰지 않았다(PR 본문에 그대로 기록).
void main() {
  final t13 = File('assets/content/saa/saa-t1-3.md').readAsStringSync();
  final t14 = File('assets/content/saa/saa-t1-4.md').readAsStringSync();

  group('G-1.2-06 CloudFront 웹 ACL 리전', () {
    // 근거: CreateWebACL API — "To work with CloudFront, you must also specify
    // the Region US East (N. Virginia)" / `--scope=CLOUDFRONT --region=us-east-1`
    test('"us-east-1 제한 없음" 단정이 사라졌다', () {
      expect(t14.contains('us-east-1 제한 없음'), isFalse);
    });

    test('CLOUDFRONT 스코프는 us-east-1에서 만든다고 서술한다', () {
      expect(t14.contains('CLOUDFRONT'), isTrue);
      expect(t14.contains('us-east-1'), isTrue);
    });
  });

  group('G-1.2-07 웹 ACL 규칙 액션의 종료/비종료', () {
    // 근거: web-acl-rule-actions — "Count is a non-terminating action"
    test('Count가 비종료라고 명시한다', () {
      expect(t14.contains('비종료'), isTrue);
    });

    test('"첫 번째로 매칭된 규칙의 액션(Allow/Block/Count/CAPTCHA)을 실행" 서술이 사라졌다', () {
      expect(
          t14.contains('첫 번째로 매칭된 규칙의 액션(Allow/Block/Count/CAPTCHA)을 실행'), isFalse);
    });
  });

  group('G-1.2-08 Rate-based 평가 창', () {
    // 근거: rate-based high-level settings — 60/120/300/600, 기본 300, 최소 한도 10
    test('평가 창 네 값과 기본값이 서술돼 있다', () {
      for (final v in ['60', '120', '300', '600']) {
        expect(t14.contains(v), isTrue, reason: '평가 창 $v초 누락');
      }
      expect(t14.contains('5분 또는 1분'), isFalse, reason: '구식 서술');
    });
  });

  group('G-1.2-09 WAF 보호 대상', () {
    // 근거: CreateWebACL API 리소스 유형 열거
    test('Amplify와 Bedrock AgentCore Gateway가 목록에 있다', () {
      expect(t14.contains('Amplify'), isTrue);
      expect(t14.contains('AgentCore'), isTrue);
    });
  });

  group('G-1.2-10 Cognito 기능 플랜', () {
    // 근거: cognito-sign-in-feature-plans — Lite/Essentials/Plus
    test('세 플랜과 플랜별 경계가 서술돼 있다', () {
      for (final p in ['Lite', 'Essentials', 'Plus']) {
        expect(t14.contains(p), isTrue, reason: '$p 플랜 누락');
      }
      expect(t14.contains('MFA(TOTP·SMS) 지원'), isFalse, reason: '구식 한 줄 서술');
    });
  });

  group('G-1.2-12 Flow Logs 저장 대상', () {
    // 근거: flow-logs — "Amazon CloudWatch Logs, Amazon S3, or Amazon Data Firehose"
    test('Firehose가 포함된 세 곳이다', () {
      expect(t13.contains('Firehose'), isTrue);
      expect(t13.contains('**로그 저장 대상**: CloudWatch Logs 또는 S3.'), isFalse);
    });
  });

  group('G-1.2-13 NAT 게이트웨이 가용성', () {
    // 근거: nat-gateway-basics — "created in a specific Availability Zone and
    // implemented with redundancy in that zone" / AZ별 생성 권장 / 55,000 연결
    test('"자동 고가용성"이 아니라 AZ 내 이중화로 서술한다', () {
      expect(t13.contains('자동 고가용성'), isFalse);
      expect(t13.contains('AZ 내 이중화') || t13.contains('AZ 안에서만'), isTrue);
    });

    test('AZ별 NAT 게이트웨이 권장과 동시 연결 수치가 있다', () {
      expect(t13.contains('AZ마다') || t13.contains('AZ별'), isTrue);
      expect(t13.contains('55,000'), isTrue);
    });
  });

  group('G-1.2-14 VPC 피어링 과금', () {
    // 근거: VPC 요금 — "Data sent over VPC peering connections that crosses an
    // Availability Zone within the same AWS Region is charged at $0.01/GB"
    test('피어링 비용 칸이 "데이터 처리 과금"이 아니라 AZ 교차 전송 과금이다', () {
      // NAT 게이트웨이·Transit Gateway의 데이터 처리 과금은 사실이므로
      // 피어링 비교표의 비용 행만 본다.
      expect(t13.contains('| 비용 | 데이터 처리 과금'), isFalse,
          reason: '피어링에는 처리 요금이 아니라 AZ를 넘는 전송 요금이 붙는다');
      expect(t13.contains('AZ를 넘는 전송에 \$0.01/GB'), isTrue);
    });
  });

  group('정정 날짜·출처', () {
    test('두 문서의 lastVerified가 2026-10-19로 갱신됐다', () {
      expect(t13.contains('lastVerified: 2026-10-19'), isTrue);
      expect(t14.contains('lastVerified: 2026-10-19'), isTrue);
    });

    test('새로 인용한 공식 출처가 실려 있다', () {
      expect(t14.contains('web-acl-rule-actions'), isTrue);
      expect(t14.contains('cognito-sign-in-feature-plans'), isTrue);
      expect(t13.contains('nat-gateway-basics'), isTrue);
    });
  });
}
