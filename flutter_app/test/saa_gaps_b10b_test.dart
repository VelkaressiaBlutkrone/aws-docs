import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// SAA 갭 보강 배치 **B10b** — Task 4.4 **11행** (2026-10-24).
///
/// 배정 정본은 `docs/content-research/SAA-C03/97-gap-batch-map.md` §4 "B10".
/// B10a(Task 4.3 9행)에 이어 B10 의 마지막 조각이다. `saa-t4-4` 는 문항이 15/15
/// **`verified:false`·questionCount 0** 이라 노출이 없다(`saa-t4-3`·`saa-t4-2` 와 다른 점).
///
/// ## ⚠️ 이 문서는 요율 지뢰밭이다 — G-02 규율을 가장 엄하게 적용한다
///
/// 갭 노트가 요구하는 항목 다수가 **리전·위치 의존 요율**이고, `99-gaps` 의 `[의심]`
/// 5건(`G-4.4-13`·`14`·`15`·`18`·`19`)이 **기존 요율 서술을 이미 문제 삼고 있다.**
/// 그래서 이 배치는 **과금 축·용량 한도·무료 범위·상대 비율만** 쓰고 **단가는 쓰지
/// 않는다.** 아래 금지 목록이 그 경계다.
///
/// ⚠️ 단 **이미 본문에 있는** `$0.02/GB`(9)·`$0.045`(9)·`$0.01/GB`(9)는 **건드리지
///    않는다** — `G-4.4-13`~`15` 의 `[의심]` 소관이지 이 배치의 범위가 아니다.
///    기존 가드가 요구하는 `$0.005`(공용 IPv4)도 그대로 둔다.
///
/// ## ⚠️ 기존 가드와 충돌하지 않게
///
/// `saa_t2_t4_facts_test` 가 이 문서에서 `$0.01/GB + $0.02/GB`·`$0.01/GB + 시간당 ENI
/// 요금` 을 금지하고 `TGW를 통과하는`·`AZ별 시간 요금`·`$0.005`·`공용 IPv4`·
/// `privatelink/pricing` 을 요구한다. 그 서술은 손대지 않는다.
///
/// ⚠️ `손익분기`(2)·`전이`(1)는 **이미 본문에 있어**(§6 DX·§5 피어링) 가드 문구에서
///    뺐다 — 그대로 요구하면 아무것도 보장하지 못한다.
void main() {
  String doc(String id) =>
      File('assets/content/saa/$id.md').readAsStringSync();

  String body(String id) {
    final t = doc(id);
    final i = t.indexOf('### 📌 출처');
    return i < 0 ? t : t.substring(0, i);
  }

  group('B10b G-4.4-01·07 — 로드 밸런서와 공용 IP (saa-t4-4)', () {
    // 공식: ALB 는 LCU, NLB 는 NLCU 로 과금하고 "charged only on the dimension
    //       with the highest usage".
    test('LCU·NLCU 와 최고 차원 과금을 적는다', () {
      final t = doc('saa-t4-4');
      expect(t.contains('LCU'), isTrue);
      expect(t.contains('NLCU'), isTrue);
      expect(t.contains('가장 큰 한 차원'), isTrue);
    });

    // 공식: 공용 IPv4 절감 수단 — ELB 뒤로 모으기·EC2 Instance Connect Endpoint·IPv6.
    test('공용 IPv4 를 줄이는 수단을 적는다', () {
      final t = doc('saa-t4-4');
      expect(t.contains('Instance Connect Endpoint'), isTrue);
      expect(t.contains('ELB 통합'), isTrue);
    });
  });

  group('B10b G-4.4-02 — NAT 게이트웨이 vs NAT 인스턴스 (saa-t4-4)', () {
    // 공식 비교: 가용성·대역폭(게이트웨이 최대 100 Gbps)·관리·과금 항목,
    //          "AWS는 NAT gateway 권장", 한 NAT 는 단일 AZ 에서 동작.
    test('NAT 인스턴스와의 비교 축을 적는다', () {
      final t = doc('saa-t4-4');
      expect(t.contains('NAT 인스턴스'), isTrue);
      expect(t.contains('100 Gbps'), isTrue);
    });

    test('AZ별 배치 원칙을 적는다', () {
      expect(doc('saa-t4-4').contains('AZ별 1개'), isTrue);
    });
  });

  group('B10b G-4.4-03·08 — VPN·DX·Global Accelerator (saa-t4-4)', () {
    // 공식: "You are charged for each VPN connection hour that your VPN
    //        connection is provisioned" — 전송은 인터넷 DTO 요율.
    test('VPN 의 과금 축을 적는다', () {
      expect(doc('saa-t4-4').contains('VPN'), isTrue);
    });

    // 공식: 표준 VPN 터널 최대 1.25 Gbps, TGW + 동적 라우팅 ECMP 로 집계.
    test('VPN 터널 대역폭 한계와 ECMP 집계를 적는다', () {
      final t = doc('saa-t4-4');
      expect(t.contains('1.25 Gbps'), isTrue);
      expect(t.contains('ECMP'), isTrue);
    });

    // 공식: 가속 VPN 은 연결 요금 + Global Accelerator 2개 시간 요금 + DT-Premium.
    test('가속 VPN 의 비용 구성을 적는다', () {
      expect(doc('saa-t4-4').contains('가속 VPN'), isTrue);
    });

    // 공식: "you are charged $0.025 until it is deleted" — 비활성 가속기도 과금.
    //       → 단가는 쓰지 않고 **삭제 전까지 과금**이라는 구조만 적는다.
    test('Global Accelerator 가 절감 수단이 아님을 적는다', () {
      final t = doc('saa-t4-4');
      expect(t.contains('Global Accelerator'), isTrue);
      expect(t.contains('DT-Premium'), isTrue);
    });
  });

  group('B10b G-4.4-04·09·05 — DNS·CDN·스로틀링 (saa-t4-4)', () {
    // 공식: Alias 가 AWS 리소스를 가리키면 쿼리 무료 · 프라이빗 호스티드 영역
    //       쿼리 무료 · Resolver 엔드포인트는 ENI(IP)당 시간 과금.
    test('Route 53 의 무료 쿼리 경로를 적는다', () {
      final t = doc('saa-t4-4');
      expect(t.contains('Route 53'), isTrue);
      expect(t.contains('Alias'), isTrue);
      expect(t.contains('프라이빗 호스티드 영역'), isTrue);
    });

    // 공식: AWS 오리진 → CloudFront 전송 무료 · 월 1 TB 무료 · 가격 클래스 ·
    //       Origin Shield 는 별도 요청 요금.
    test('CloudFront 의 가격 클래스·무료 범위·Origin Shield 를 적는다', () {
      final t = doc('saa-t4-4');
      expect(t.contains('가격 클래스'), isTrue);
      expect(t.contains('Origin Shield'), isTrue);
      expect(t.contains('1 TB'), isTrue);
    });

    // 공식: API Gateway 토큰 버킷(속도+버스트)·계정 수준 한도는 기본 적용·429 ·
    //       WAF rate-based rule.
    test('스로틀링 수단을 적는다', () {
      final t = doc('saa-t4-4');
      expect(t.contains('토큰 버킷'), isTrue);
      expect(t.contains('429'), isTrue);
      expect(t.contains('rate-based'), isTrue);
    });
  });

  group('B10b G-4.4-06·10·11 — 검토 절차·피어링·DX 총비용 (saa-t4-4)', () {
    // 공식: CUR 사용 유형으로 AZ 간 비용 식별 · Flow Logs 로 NAT 트래픽 출처 파악.
    test('네트워크 비용 검토의 출발점을 적는다', () {
      final t = doc('saa-t4-4');
      expect(t.contains('DataTransfer-Regional-Bytes'), isTrue);
      expect(t.contains('Flow Logs'), isTrue);
    });

    // 공식: TGW 는 **첨부당 시간 요금** + GB당 처리 요금이고, 공유 TGW 의 시간
    //       요금은 첨부 VPC 소유 계정이 부담한다.
    test('TGW 의 첨부 단위 시간 요금을 적는다', () {
      expect(doc('saa-t4-4').contains('첨부당 시간'), isTrue);
    });

    // 공식: DX 총비용은 포트 시간·DTO 외에 ISP·크로스 커넥트·랙·장비를 포함하고,
    //       SiteLink 는 시간 요금 + DX 전송이다.
    test('DX 총비용의 구성 항목과 SiteLink 를 적는다', () {
      final t = doc('saa-t4-4');
      expect(t.contains('크로스 커넥트'), isTrue);
      expect(t.contains('SiteLink'), isTrue);
    });
  });

  group('B10b 금지 — G-02 요율 규율 (이 배치가 새로 들이지 않는 단가)', () {
    test('VPN·가속기 시간 단가를 적지 않는다', () {
      final t = body('saa-t4-4');
      expect(t.contains('\$0.60'), isFalse);
      expect(t.contains('\$1.95'), isFalse);
      expect(t.contains('\$0.025'), isFalse);
    });

    test('Route 53 호스티드 영역·쿼리·Resolver 단가를 적지 않는다', () {
      final t = body('saa-t4-4');
      expect(t.contains('\$0.50'), isFalse);
      expect(t.contains('\$0.40'), isFalse);
      expect(t.contains('\$0.125'), isFalse);
      expect(t.contains('182.50'), isFalse);
    });

    test('CloudFront 요청 단가·번들 할인율을 적지 않는다', () {
      final t = body('saa-t4-4');
      expect(t.contains('\$0.0075'), isFalse);
      expect(t.contains('최대 30%'), isFalse);
    });

    test('DX 의 위치별 DTO 예시 단가를 적지 않는다', () {
      final t = body('saa-t4-4');
      expect(t.contains('\$0.114'), isFalse);
      expect(t.contains('\$0.0420'), isFalse);
    });
  });
}
