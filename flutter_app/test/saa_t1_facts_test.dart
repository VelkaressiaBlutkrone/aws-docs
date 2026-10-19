import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// SAA Task 1.1 학습문서의 사실 정정 가드 (2026-10-19).
///
/// 외부 조사(docs/content-research/SAA-C03/98-existing-gap.md)가 올린 Task 1.1의
/// `[오류]`·`[구식]` 2건을 공식 문서로 재확인한 뒤 정정했다. 같은 구식 서술이
/// 되살아나지 않도록 정정 결과를 고정한다.
///
/// - G-1.1-07 `[오류]` SCP 리전 제한 예시가 글로벌 서비스까지 차단
///   근거: https://docs.aws.amazon.com/controltower/latest/controlreference/primary-region-deny-policy.html
///   (공식 리전 거부 통제는 NotAction으로 iam/organizations/route53/sts 등을 예외 처리)
/// - G-1.1-10 `[구식]` 루트 사용자 서술이 현행 정책 미반영
///   근거: https://docs.aws.amazon.com/IAM/latest/UserGuide/root-user-best-practices.html
///   (모든 계정 유형 루트 MFA 요구 · 첫 로그인 후 35일 유예) ·
///   https://docs.aws.amazon.com/IAM/latest/UserGuide/id_root-user.html
///   (중앙 루트 접근 관리 · "New accounts you create in Organizations have no
///   root user credentials by default")
void main() {
  final t11 = File('assets/content/saa/saa-t1-1.md').readAsStringSync();
  final t12 = File('assets/content/saa/saa-t1-2.md').readAsStringSync();

  group('G-1.1-07 SCP 리전 제한 예시', () {
    test('예시가 글로벌 서비스를 NotAction으로 예외 처리한다', () {
      expect(t12.contains('NotAction'), isTrue,
          reason: 'Deny + Action:"*" 만으로 리전을 막으면 글로벌 서비스 호출까지 차단된다');
      for (final action in ['iam:*', 'organizations:*', 'route53:*', 'sts:*']) {
        expect(t12.contains(action), isTrue,
            reason: '공식 리전 거부 통제가 예외로 두는 $action 가 예시에 없다');
      }
    });

    test('"어떤 API도 호출할 수 없다"는 단정이 예외 설명 없이 남아 있지 않다', () {
      expect(t12.contains('어떤 API도 호출할 수 없습니다'), isFalse,
          reason: '글로벌 서비스 예외를 말하지 않는 단정은 위험한 정책을 유도한다');
    });

    test('공식 Control Tower 리전 거부 통제를 출처로 싣는다', () {
      expect(t12.contains('controlreference/primary-region-deny-policy'), isTrue);
    });
  });

  group('G-1.1-10 루트 사용자 현행 정책', () {
    test('루트 MFA 요구와 35일 유예가 서술돼 있다', () {
      expect(t11.contains('35일'), isTrue,
          reason: '첫 로그인 후 35일 안에 MFA를 등록해야 한다는 현행 규칙');
    });

    test('옛 3종 서술("MFA 필수, 액세스 키 발급 금지, 일상 작업에 사용 금지")이 그대로 남아 있지 않다', () {
      expect(t11.contains('MFA 필수, 액세스 키 발급 금지, 일상 작업에 사용 금지'), isFalse);
    });

    test('중앙 루트 접근 관리가 두 문서에 반영돼 있다', () {
      expect(t11.contains('중앙 루트 접근 관리'), isTrue);
      expect(t12.contains('중앙 루트 접근 관리'), isTrue);
    });

    test('Organizations 신규 계정은 기본 루트 자격증명이 없다는 사실이 있다', () {
      expect(t12.contains('루트 자격증명이 없'), isTrue,
          reason: '공식: New accounts you create in Organizations have no root user credentials by default');
    });

    test('루트 모범 사례 공식 출처를 싣는다', () {
      expect(t11.contains('root-user-best-practices'), isTrue);
      expect(t12.contains('id_root-user'), isTrue);
    });
  });

  group('드래프트 문항도 현행 정책과 어긋나지 않는다', () {
    test('saa-t1-1-q15 해설이 루트 MFA 요구·35일 유예를 반영한다', () {
      final bank = File('assets/content/saa/saa-t1-1.questions.json')
          .readAsStringSync();
      final q15Start = bank.indexOf('"saa-t1-1-q15"');
      expect(q15Start, greaterThan(-1), reason: 'saa-t1-1-q15 문항이 없다');
      final q15End =
          (q15Start + 2500) < bank.length ? q15Start + 2500 : bank.length;
      final q15 = bank.substring(q15Start, q15End);
      expect(q15.contains('35일'), isTrue,
          reason: '정답은 그대로지만 해설은 현행 정책(모든 계정 유형 MFA 요구·35일 유예)을 담아야 한다');
      expect(q15.contains('root-user-best-practices'), isTrue,
          reason: '근거 출처를 루트 모범 사례 페이지로 둔다');
    });
  });

  group('정정 날짜 기록', () {
    test('두 문서의 lastVerified가 2026-10-19로 갱신됐다', () {
      expect(t11.contains('lastVerified: 2026-10-19'), isTrue);
      expect(t12.contains('lastVerified: 2026-10-19'), isTrue);
    });
  });
}
