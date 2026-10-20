import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// SAA 갭 보강 배치 B3 — 조직 정책 수치·네트워크 트래픽 제어·서비스 엔드포인트 (2026-10-21).
///
/// 배정 정본은 `docs/content-research/SAA-C03/97-gap-batch-map.md` §4 "B3".
/// 외부 조사 `docs/content-research/SAA-C03/98-existing-gap.md` 의 네 항목을
/// 공식 문서로 확인해 저작했다:
///   G-1.1-15        SCP 수치(연결 10·문서 10,240자) — `saa-t1-2` 에 없었음
///   G-1.2-04 +01    Network Firewall·DNS Firewall·SG 쿼터·미여과 트래픽 — `saa-t1-3` 0건이었음
///   G-1.2-02        AWS 서비스 엔드포인트 유형(리전·FIPS·듀얼스택) — 0건이었음
///   G-1.2-15        Gateway Endpoint 는 VPC 밖으로 확장되지 않는다 — 미언급이었음
///
/// 같은 배치에서 저작하지 않고 다른 배치로 넘긴 행(맵 §4 주석에 사유 기재):
///   G-1.1-02·G-1.1-06  작업 불필요 — 매핑 문서가 "배경지식(별도 학습문서 불필요)"로 처리
///   G-1.2-03           B8 — 저작 대상이 `saa-t3-8`(공식 Task 3.4)
///   G-1.2-05           B11 — 저작 대상이 `saa-t1-4`(사람 flip 대기)
///
/// 가드 규율: **금지할 것만 고정하고 요구는 느슨하게**(핵심 키워드 수준).
/// 고쳐 넣은 표현까지 `isTrue` 로 못박으면 다음 수정이 막힌다(HANDOFF §0-2026-10-20 교훈).
void main() {
  String doc(String id) =>
      File('assets/content/saa/$id.md').readAsStringSync();

  group('B3-1 G-1.1-15 SCP 수치 (saa-t1-2)', () {
    test('SCP 직접 연결 한도가 있다', () {
      final t12 = doc('saa-t1-2');
      expect(t12.contains('10,240'), isTrue, reason: 'SCP 문서 최대 크기');
      expect(
        RegExp(r'최대\s*10\s*개|10\s*개까지').hasMatch(t12),
        isTrue,
        reason: '루트·OU·계정당 SCP 직접 연결 최대 10',
      );
    });

    test('상속된 정책은 연결 한도에 계산되지 않는다는 점이 있다', () {
      expect(doc('saa-t1-2').contains('상속'), isTrue);
    });

    test('기존에 일치 확인된 OU 중첩 5단계 서술이 유지된다', () {
      expect(doc('saa-t1-2').contains('5단계'), isTrue);
    });

    // 금지: Organizations 자체 한도를 5개로 적는 것. 5개는 Control Tower 예방 통제
    // 맥락(Prescriptive Guidance)의 수치다.
    //
    // ⚠️ 문자열 '5개' 자체를 금지하면 안 된다 — 학습자가 다른 데서 본 5를 바로잡는
    // **경고 문구**가 같은 문자열을 포함하고, 그러면 올바른 서술이 가드에 걸린다
    // (HANDOFF §0-2026-10-20 "가드가 과잉 수정을 고정한다"의 변종).
    // 대신 ① 쿼터 표의 해당 행이 10을 적을 것, ② 5를 적을 때는 Control Tower
    // 문맥이 함께 있을 것 — 두 가지로 단정만 막는다.
    test('쿼터 표의 직접 연결 행은 10개를 적는다', () {
      final line = doc('saa-t1-2')
          .split('\n')
          .firstWhere((l) => l.contains('직접 연결'), orElse: () => '');
      expect(line, isNotEmpty, reason: 'SCP 직접 연결 한도 행이 있어야 한다');
      expect(line.contains('10개'), isTrue, reason: 'Organizations 쿼터는 10');
      expect(line.contains('5개'), isFalse, reason: '5는 Control Tower 맥락의 수치');
    });

    test('5개 수치는 Control Tower 문맥과 함께만 나온다', () {
      final t12 = doc('saa-t1-2');
      if (t12.contains('5개')) {
        expect(
          t12.contains('Control Tower'),
          isTrue,
          reason: '5개를 적으려면 그것이 Control Tower 맥락임을 밝혀야 한다',
        );
      }
    });

    // 금지: 연결 한도를 조정 가능한 것으로 쓰는 서술. 공식은 하드 한도다.
    test('정책 연결 한도를 상향 요청 가능한 것으로 쓰지 않는다', () {
      final t12 = doc('saa-t1-2');
      expect(t12.contains('연결 한도는 상향'), isFalse);
      expect(t12.contains('Service Quotas로 SCP 연결'), isFalse);
    });

    test('공식 출처가 실려 있다', () {
      expect(doc('saa-t1-2').contains('orgs_reference_limits'), isTrue);
    });
  });

  group('B3-2 G-1.2-04+01 Network Firewall·DNS Firewall (saa-t1-3)', () {
    test('Network Firewall 이 stateless·stateful 양쪽 규칙을 갖는다는 점이 있다', () {
      final t13 = doc('saa-t1-3');
      expect(t13.contains('Network Firewall'), isTrue);
      expect(t13.contains('관리형 규칙'), isTrue);
    });

    test('DNS Firewall 의 필터 대상과 연결 단위가 있다', () {
      final t13 = doc('saa-t1-3');
      expect(t13.contains('DNS Firewall'), isTrue);
      expect(t13.contains('도메인'), isTrue);
    });

    // 금지: DNS Firewall 이 IP 를 차단한다는 서술.
    // 공식: "DNS Firewall only filters on the domain name.
    //        It does not resolve that name to an IP address to be blocked."
    test('DNS Firewall 이 IP를 차단한다고 쓰지 않는다', () {
      final t13 = doc('saa-t1-3');
      expect(t13.contains('DNS Firewall로 IP를 차단'), isFalse);
      expect(t13.contains('DNS Firewall은 IP 주소를 차단'), isFalse);
    });

    // 금지: DNS Firewall 이 DNS 외 애플리케이션 프로토콜까지 필터한다는 서술.
    // 공식: "it doesn't filter other application layer protocols,
    //        such as HTTPS, SSH, TLS, FTP".
    test('DNS Firewall 이 HTTPS 등 다른 프로토콜을 필터한다고 쓰지 않는다', () {
      final t13 = doc('saa-t1-3');
      expect(t13.contains('DNS Firewall이 HTTPS'), isFalse);
      expect(t13.contains('DNS Firewall로 HTTPS'), isFalse);
    });
  });

  group('B3-3 G-1.2-04 SG 쿼터·미여과 트래픽 (saa-t1-3)', () {
    test('SG 쿼터 수치가 있다', () {
      final t13 = doc('saa-t1-3');
      expect(t13.contains('2,500'), isTrue, reason: '리전당 SG 수');
      expect(t13.contains('1,000'), isTrue, reason: '규칙 수 × ENI당 SG 수 상한');
    });

    test('SG·NACL 이 걸러내지 못하는 트래픽이 있다', () {
      final t13 = doc('saa-t1-3');
      expect(t13.contains('Amazon DNS'), isTrue);
      expect(t13.contains('같은 서브넷'), isTrue);
    });

    // 금지: Amazon DNS 트래픽을 SG·NACL 로 막을 수 있다는 서술.
    // 공식: "You cannot filter traffic to or from the Amazon DNS server
    //        using network ACLs or security groups."
    test('Amazon DNS 트래픽을 SG·NACL로 막을 수 있다고 쓰지 않는다', () {
      final t13 = doc('saa-t1-3');
      expect(t13.contains('Amazon DNS 서버로의 트래픽을 NACL로 차단'), isFalse);
      expect(t13.contains('Amazon DNS를 보안 그룹으로 차단'), isFalse);
    });

    // 금지: NACL 이 같은 서브넷 안의 인스턴스 간 트래픽을 거른다는 서술.
    // 공식(VPC FAQ): "Network ACLs do not filter traffic between instances
    //                 in the same subnet."
    test('NACL이 같은 서브넷 내부 트래픽을 거른다고 쓰지 않는다', () {
      final t13 = doc('saa-t1-3');
      expect(t13.contains('NACL은 같은 서브넷 내 인스턴스 간 트래픽도 제어'), isFalse);
      expect(t13.contains('같은 서브넷 안에서도 NACL이 적용'), isFalse);
    });
  });

  group('B3-4 G-1.2-02 서비스 엔드포인트 유형 (saa-t1-3)', () {
    test('리전·FIPS·듀얼스택 엔드포인트가 구분돼 있다', () {
      final t13 = doc('saa-t1-3');
      expect(t13.contains('FIPS'), isTrue);
      expect(t13.contains('api.aws'), isTrue, reason: '듀얼스택 일반 구문');
    });

    test('FIPS 엔드포인트의 최소 TLS 버전이 있다', () {
      expect(doc('saa-t1-3').contains('TLS 1.2'), isTrue);
    });

    // 금지: 듀얼스택 구문을 전 서비스가 `dualstack.` 을 쓴다고 적는 것.
    // 공식: 일반 구문은 `service-code.region-code.api.aws` 이고
    //       `dualstack.` 형식은 Amazon S3 만 쓴다.
    test('듀얼스택 구문을 전 서비스 dualstack. 형식으로 단정하지 않는다', () {
      final t13 = doc('saa-t1-3');
      expect(t13.contains('모든 서비스는 dualstack'), isFalse);
      expect(t13.contains('듀얼스택 엔드포인트는 dualstack.'), isFalse);
    });

    test('공식 출처가 실려 있다', () {
      expect(doc('saa-t1-3').contains('general/latest/gr/rande'), isTrue);
    });
  });

  group('B3-5 G-1.2-15 Gateway Endpoint 는 VPC 밖으로 확장되지 않는다 (saa-t1-3)', () {
    test('온프레미스·피어링에서 쓸 수 없다는 점과 대안이 있다', () {
      final t13 = doc('saa-t1-3');
      expect(t13.contains('Interface Endpoint'), isTrue);
      expect(
        RegExp(r'Gateway Endpoint[^\n]*(온프레미스|VPC 밖)').hasMatch(t13),
        isTrue,
        reason: 'Gateway Endpoint 의 적용 범위 제약',
      );
    });

    // 금지: Gateway Endpoint 를 온프레미스·피어링 상대 VPC 에서 쓸 수 있다는 서술.
    // 공식: "Do not allow access from on premises" ·
    //       "VPC gateway endpoint connections can't be extended out of a VPC."
    test('Gateway Endpoint를 온프레미스·피어링에서 쓸 수 있다고 쓰지 않는다', () {
      final t13 = doc('saa-t1-3');
      expect(t13.contains('Gateway Endpoint도 온프레미스에서 사용'), isFalse);
      expect(t13.contains('Gateway Endpoint를 피어링 VPC에서 사용'), isFalse);
      expect(t13.contains('온프레미스에서도 Gateway Endpoint'), isFalse);
    });
  });
}
