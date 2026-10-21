import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// SAA 갭 보강 배치 B8b — Task 3.4 9행 + `G-1.2-03` = 10행 (2026-10-21).
///
/// 배정 정본은 `docs/content-research/SAA-C03/97-gap-batch-map.md` §4 "B8".
/// B8 23행 중 **Task 3.4 + MACsec 10행**을 담는다(3.3 잔여 6행은 B8a 완료,
/// 3.5 잔여 7행은 B8c).
///
/// ⚠️ `saa-t3-8` 은 서브섹션 7·원리 7 이라 하한이 꼭 맞아 있었다. 절을 늘리면
///    하한이 8 로 올라가므로 **원리 블록도 함께** 넣어야 한다.
/// ⚠️ `G-3.4-02` Cloud WAN 은 `99-gaps.md` **V-72** 에 걸린다 — 공식
///    in/out-of-scope 목록 어디에도 없어 **시험 범위 단정을 쓸 수 없다.**
void main() {
  String doc(String id) =>
      File('assets/content/saa/$id.md').readAsStringSync();

  /// 출처·보강 노트 구간을 제외한 **본문**만 본다(B6 교훈 — 맵 §4).
  String body(String id) {
    final t = doc(id);
    final i = t.indexOf('### 📌 출처');
    return i < 0 ? t : t.substring(0, i);
  }

  group('B8b-1 G-3.4-09 Route 53 라우팅 정책 8종 (saa-t3-7)', () {
    test('IP 기반 라우팅이 목록에 있다', () {
      final t = doc('saa-t3-7');
      expect(t.contains('IP 기반'), isTrue, reason: '공식 8종 중 누락됐던 항목');
      expect(t.contains('8종'), isTrue);
    });

    test('다중값 응답 상한과 EDNS0 한계가 있다', () {
      final t = doc('saa-t3-7');
      expect(t.contains('최대 8개'), isTrue, reason: '다중값 응답이 반환하는 수');
      expect(t.contains('EDNS0') || t.contains('edns0'), isTrue);
    });

    // 금지: 정책 수를 7종으로 적는 것. 공식은 **8종**(IP 기반 포함)이다.
    // ⚠️ `7` 자체를 금지하면 안 된다 — 다른 절의 올바른 수치가 걸린다.
    test('라우팅 정책을 7종으로 적지 않는다', () {
      final t = body('saa-t3-7');
      expect(t.contains('라우팅 정책 7종'), isFalse);
      expect(t.contains('정책 7종'), isFalse);
      expect(t.contains('7종 중 어떤 정책'), isFalse);
    });
  });

  group('B8b-2 G-3.4-03 CloudFront 성능 구조 (saa-t3-7)', () {
    test('리전 엣지 캐시와 Origin Shield가 있다', () {
      final t = doc('saa-t3-7');
      expect(t.contains('리전 엣지 캐시'), isTrue);
      expect(t.contains('Origin Shield'), isTrue);
      expect(t.contains('OriginShieldHit'), isTrue);
    });

    test('오리진 그룹 장애 조치 조건이 있다', () {
      final t = doc('saa-t3-7');
      expect(t.contains('오리진 그룹'), isTrue);
      expect(t.contains('GET'), isTrue);
      expect(t.contains('OPTIONS'), isTrue);
      expect(t.contains('503'), isTrue, reason: '연결 실패를 장애 조치 코드로');
    });

    // 금지: 모든 HTTP 메서드에서 오리진 장애 조치가 일어난다는 서술.
    // 공식: "fails over ... only when the HTTP method ... is GET, HEAD, or OPTIONS".
    test('모든 메서드에서 장애 조치된다고 적지 않는다', () {
      final t = body('saa-t3-7');
      expect(t.contains('모든 HTTP 메서드에서 장애 조치'), isFalse);
      expect(t.contains('POST도 장애 조치'), isFalse);
    });

    // 금지: 장애 조치 후 이후 요청이 보조 오리진으로 간다는 서술.
    // 공식: CloudFront 는 **모든 들어오는 요청을 프라이머리로** 보낸다.
    test('장애 조치 후 보조를 계속 쓴다고 적지 않는다', () {
      final t = body('saa-t3-7');
      expect(t.contains('이후 요청은 보조 오리진으로'), isFalse);
      expect(t.contains('보조 오리진이 프라이머리를 대체'), isFalse);
    });
  });

  group('B8b-3 G-3.4-04 로드 밸런싱 전략 (saa-t3-7)', () {
    test('ALB 알고리즘 3종과 가중 대상 그룹이 있다', () {
      final t = doc('saa-t3-7');
      expect(t.contains('least_outstanding_requests'), isTrue);
      expect(t.contains('weighted_random'), isTrue);
      expect(t.contains('가중 대상 그룹'), isTrue);
    });

    test('NLB 고정 IP와 클라이언트 IP 보존이 있다', () {
      final t = doc('saa-t3-7');
      expect(t.contains('Elastic IP'), isTrue);
      expect(t.contains('클라이언트 IP 보존'), isTrue);
      expect(t.contains('preserve_client_ip.enabled'), isTrue);
    });

    test('GWLB의 GENEVE 포트가 있다', () {
      final t = doc('saa-t3-7');
      expect(t.contains('GENEVE'), isTrue);
      expect(t.contains('6081'), isTrue);
    });

    // 금지: 클라이언트 IP 보존이 모든 대상 그룹에서 기본 활성이라는 서술.
    // 공식 기본값: 인스턴스 타입 활성 / IP 타입 TCP·TLS **비활성**.
    test('클라이언트 IP 보존이 항상 기본 활성이라고 적지 않는다', () {
      final t = body('saa-t3-7');
      expect(t.contains('항상 기본적으로 활성'), isFalse);
      expect(t.contains('모든 대상 그룹에서 기본 활성'), isFalse);
    });

    // 금지: TGW 경유 대상에서도 클라이언트 IP 보존이 된다는 서술.
    test('TGW 경유에서도 IP 보존이 된다고 적지 않는다', () {
      final t = body('saa-t3-7');
      expect(t.contains('Transit Gateway를 거쳐도 보존'), isFalse);
      expect(t.contains('전송 게이트웨이 경유에서도 보존'), isFalse);
    });
  });

  group('B8b-4 G-3.4-01 네트워크 설계 — 서브넷·IP (saa-t3-8)', () {
    test('절과 앵커가 있다', () {
      expect(doc('saa-t3-8').contains('{#subnet-design}'), isTrue);
    });

    test('서브넷 예약 IP 5개와 계산식이 있다', () {
      final t = doc('saa-t3-8');
      expect(t.contains('5개'), isTrue, reason: '예약 IP 수');
      expect(t.contains('/28'), isTrue, reason: 'CIDR 하한');
      expect(t.contains('251'), isTrue, reason: '/24 가용 IP');
      expect(t.contains('브로드캐스트'), isTrue);
    });

    test('서브넷이 단일 AZ에 속한다는 점이 있다', () {
      expect(doc('saa-t3-8').contains('단일 AZ'), isTrue);
    });

    // 금지: 예약 IP를 "앞 3개 + 뒤 1개" 처럼 잘못 세는 것.
    // 공식: **처음 네 개와 마지막 한 개** = 5개.
    test('예약 IP를 앞 3개로 적지 않는다', () {
      final t = body('saa-t3-8');
      expect(t.contains('처음 3개'), isFalse);
      expect(t.contains('앞 3개'), isFalse);
    });

    // 금지: BYOIP 범위에서도 5개가 예약된다는 서술.
    // 공식: BYOIP 로 가져온 범위는 네트워크·브로드캐스트 주소까지 쓸 수 있다.
    test('BYOIP에서도 5개가 예약된다고 적지 않는다', () {
      final t = body('saa-t3-8');
      expect(t.contains('BYOIP도 5개'), isFalse);
      expect(t.contains('BYOIP 범위에서도 예약'), isFalse);
    });
  });

  group('B8b-5 G-3.4-02 Cloud WAN · Route 53 Resolver (saa-t3-8)', () {
    test('절과 앵커가 있다', () {
      expect(doc('saa-t3-8').contains('{#global-topology-dns}'), isTrue);
    });

    test('Cloud WAN과 TGW 피어링 관계가 있다', () {
      final t = doc('saa-t3-8');
      expect(t.contains('Cloud WAN'), isTrue);
      expect(t.contains('코어 네트워크 에지') || t.contains('CNE'), isTrue);
    });

    test('Resolver 인바운드·아웃바운드 엔드포인트가 있다', () {
      final t = doc('saa-t3-8');
      expect(t.contains('인바운드 엔드포인트'), isTrue);
      expect(t.contains('아웃바운드 엔드포인트'), isTrue);
      expect(t.contains('전달 규칙'), isTrue);
      expect(t.contains('가장 구체적'), isTrue, reason: '규칙 매칭 규칙');
    });

    // V-72 미해소: Cloud WAN 은 공식 in/out-of-scope 목록에 없다.
    // 언급은 하되 **시험 범위 단정**을 쓰면 안 된다 — 교정 문맥을 요구한다.
    test('Cloud WAN의 시험 범위를 단정하지 않는다', () {
      final t = body('saa-t3-8');
      if (t.contains('Cloud WAN')) {
        expect(t.contains('범위가 불확실') || t.contains('범위 판정'), isTrue,
            reason: 'V-72 가 열려 있어 출제 여부를 단정할 수 없다');
      }
      expect(t.contains('Cloud WAN은 시험에 나온다'), isFalse);
      expect(t.contains('Cloud WAN이 출제된다'), isFalse);
    });

    // 금지: 온프레미스에서 VPC CIDR+2 로 쿼리를 보내라는 서술.
    // 공식: 지원되지 않으며 불안정한 결과를 낸다 — 인바운드 엔드포인트를 쓴다.
    test('온프레미스에서 CIDR+2로 질의하라고 적지 않는다', () {
      final t = body('saa-t3-8');
      expect(t.contains('온프레미스에서 +2 주소로 질의'), isFalse);
      expect(t.contains('CIDR + 2 주소로 전달하면 됩니다'), isFalse);
    });
  });

  group('B8b-6 G-3.4-05 · G-1.2-03 Direct Connect 세부와 MACsec (saa-t3-8)', () {
    test('MACsec 지원 범위와 규격이 있다', () {
      final t = doc('saa-t3-8');
      expect(t.contains('MACsec'), isTrue);
      expect(t.contains('802.1AE'), isTrue);
      expect(t.contains('400 Gbps'), isTrue);
      expect(t.contains('256비트') || t.contains('256-bit'), isTrue);
    });

    test('MACsec의 전제(2계층 인접)가 있다', () {
      final t = doc('saa-t3-8');
      expect(t.contains('홉 단위') || t.contains('hop-by-hop'), isTrue);
      expect(t.contains('2계층 인접') || t.contains('계층 인접'), isTrue);
    });

    test('복원력 모델 3종과 SLA가 있다', () {
      final t = doc('saa-t3-8');
      expect(t.contains('99.99%'), isTrue, reason: '최대 복원력');
      expect(t.contains('99.9%'), isTrue, reason: '높은 복원력');
      expect(t.contains('개발') && t.contains('테스트'), isTrue);
      expect(t.contains('SiteLink'), isTrue);
    });

    // 금지: MACsec 을 호스팅 연결에서도 쓸 수 있다는 서술.
    // 공식: **전용(dedicated)** 연결 10/100/400 Gbps 에서 선택 위치 한정.
    test('MACsec을 호스팅 연결에서 쓸 수 있다고 적지 않는다', () {
      final t = body('saa-t3-8');
      expect(t.contains('호스팅 연결에서도 MACsec'), isFalse);
      expect(t.contains('MACsec은 모든 연결에서'), isFalse);
    });

    // 금지: MACsec 을 종단 간 암호화로 적는 것(홉 단위 링크 보호다).
    test('MACsec을 종단 간 암호화로 적지 않는다', () {
      final t = body('saa-t3-8');
      expect(t.contains('MACsec은 종단 간'), isFalse);
      expect(t.contains('MACsec으로 종단 간 암호화'), isFalse);
    });
  });

  group('B8b-7 G-3.4-06 VPN 대역폭 확장 (saa-t3-8)', () {
    test('ECMP 전제와 터널 한도가 있다', () {
      final t = doc('saa-t3-8');
      expect(t.contains('ECMP'), isTrue);
      expect(t.contains('1.25 Gbps'), isTrue);
      expect(t.contains('140,000'), isTrue, reason: '표준 터널 PPS');
      expect(t.contains('동적 라우팅'), isTrue);
    });

    test('VPN Concentrator와 Accelerated VPN이 있다', () {
      final t = doc('saa-t3-8');
      expect(t.contains('VPN Concentrator'), isTrue);
      expect(t.contains('100 Mbps'), isTrue, reason: 'Concentrator 터널 상한');
      expect(t.contains('Global Accelerator'), isTrue);
    });

    // 금지: 정적 라우팅으로도 ECMP 를 쓸 수 있다는 서술.
    // 공식: "ECMP is not supported on VPN connections that use static routing."
    test('정적 라우팅에서도 ECMP가 된다고 적지 않는다', () {
      final t = body('saa-t3-8');
      expect(t.contains('정적 라우팅에서도 ECMP'), isFalse);
      expect(t.contains('정적 라우팅으로 ECMP'), isFalse);
    });
  });

  group('B8b-8 G-3.4-07 Transit Gateway 한도·동작 (saa-t3-8)', () {
    test('쿼터 수치가 있다', () {
      final t = doc('saa-t3-8');
      expect(t.contains('5,000'), isTrue, reason: 'TGW당 어태치먼트');
      expect(t.contains('50'), isTrue, reason: 'TGW당 피어링 어태치먼트');
    });

    test('동작 제약이 있다', () {
      final t = doc('saa-t3-8');
      expect(t.contains('같은 VPC'), isTrue, reason: '같은 VPC 중복 어태치 불가');
      expect(t.contains('보안 그룹'), isTrue, reason: '원격 VPC SG 참조 불가');
    });

    // 금지: TGW 가 원격 VPC 보안 그룹 참조를 지원한다는 서술.
    test('TGW가 원격 SG 참조를 지원한다고 적지 않는다', () {
      final t = body('saa-t3-8');
      expect(t.contains('전송 게이트웨이에서도 보안 그룹을 참조'), isFalse);
      expect(t.contains('TGW도 보안 그룹 참조'), isFalse);
    });
  });

  group('B8b-9 G-3.4-08 리소스 배치 결정 (saa-t3-8)', () {
    test('엣지 배치 선택지 교차 참조가 있다', () {
      final t = doc('saa-t3-8');
      expect(t.contains('Local Zone'), isTrue);
      expect(t.contains('Wavelength'), isTrue);
      expect(t.contains('Outposts'), isTrue);
      expect(t.contains('saa-t3-4'), isTrue, reason: '§7 교차 참조');
    });

    // 금지: 리전 선택 기준을 공식 확인 없이 "4요소"로 단정하는 것.
    // 갭 노트는 규정·지연·비용·서비스 가용성 4요소를 적지만 이번 조회로
    // 공식 문장을 확보하지 못했다.
    test('리전 선택을 4요소로 단정하지 않는다', () {
      final t = body('saa-t3-8');
      expect(t.contains('리전 선택 4요소'), isFalse);
      expect(t.contains('네 가지 요소로 리전을'), isFalse);
    });
  });

  group('B8b-10 불변식 — saa-t3-8 하한', () {
    // `saa-t3-8` 은 보강 전 서브섹션 7·원리 7 로 하한이 꼭 맞아 있었다.
    // 절을 늘렸으므로 원리도 8 이상이어야 `content_enrichment_test` 가 산다.
    test('saa-t3-8의 원리 블록이 8개 이상이다', () {
      final t = doc('saa-t3-8');
      final concepts = t.substring(
          t.indexOf('## 📖 핵심 개념'), t.indexOf('## ✍️ 시험 포인트'));
      final principles = '> 🧠 원리:'.allMatches(concepts).length;
      expect(principles, greaterThanOrEqualTo(8),
          reason: '서브섹션을 늘렸으니 하한 8 을 채워야 한다 (현재 $principles)');
    });
  });
}
