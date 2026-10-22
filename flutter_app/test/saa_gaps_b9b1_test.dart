import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// SAA 갭 보강 배치 **B9b-1** — Task 4.2 중 **기존 절 보강 6행** (2026-10-22).
///
/// 배정 정본은 `docs/content-research/SAA-C03/97-gap-batch-map.md` §4 "B9".
/// B9b 12행을 **기존 절 보강(B9b-1: `08`·`11`·`10`·`20`·`09`·`07`)** 과
/// **신규 절(B9b-2: `01`~`06`)** 로 쪼갰다 — 같은 파일이라 순차로만 가능하고,
/// `saa-t4-2` 는 **`verified:true` 15/15 라이브 문항 문서**라 한 번에 넣는 변경 폭을
/// 줄이는 쪽을 골랐다.
///
/// ## ⚠️ 라이브 문항과의 정합 (전수 대조에서 나온 설계 제약)
///
/// - **q10** 의 정답은 `capacityOptimized` 다("비용보다 **중단 최소화를 우선**" 조건).
///   그래서 Spot 절은 **일반 권고 `price-capacity-optimized`(가격·용량 균형)** 와
///   **중단 최소화가 절대 우선일 때의 `capacity-optimized`** 를 **구분해** 적는다.
///   뭉쳐 쓰면 라이브 정답과 어긋난다.
/// - **q1** 의 오답 해설이 "개발·테스트에 Spot 은 부적합"(2분 알림 후 회수 시 작업 중단)
///   이라고 못박는다. 그래서 비프로덕션의 Spot 활용은 **"중단을 허용할 수 있는"**
///   조건부로만 적는다(그 저작은 B9b-2 의 `G-4.2-03` 소관).
/// - **q12** 의 해설은 "기본 14일, 확장 시 93일"이다. **32일 옵션을 더해도 거짓이 되지
///   않는다**(93일이 최대). 오답 해설 2 의 리소스 목록도 "외에도 …를 분석한다"로 열려
///   있어 유휴 권고 대상을 늘려도 모순이 아니다.
/// - **q14** 는 "Graviton 은 최대 20% 저렴, 단 ARM 에서 동작해야 한다"가 정답이다.
///   **Windows Server 의 Graviton 불가**는 그 조건의 구체 사례라 정합한다.
///
/// ## ⚠️ G-02 요율 규율 — 쓰지 않는 것
///
/// 비용 문서라 리전 의존 요율이 많다. **과금 축·용량 단위·상대 비율만** 쓰고
/// **단가는 쓰지 않는다**: Lambda 요청·GB-초 단가, T unlimited vCPU-시간 정액,
/// Optimize CPUs 라이선스 절감액, NLB 25% 절감 블로그 사례, FinOps 월 비용 예시.
/// 무료 티어 **수량**(요청 수·GB-초)은 요율이 아니라 한도라서 쓴다.
///
/// ## ⚠️ 기존 가드와 충돌하지 않게
///
/// `saa_t2_t4_facts_test.dart` 가 이 문서에 대해 `최대 54%`·`(Graviton3 기준)`·
/// Dedicated Host 표 셀·`lowestPrice   : 가장 저렴한 풀 우선 (비용 최소화)` 를 금지하고
/// `Convertible RI** | 최대 66%`·`Database Savings Plans`·`SageMaker AI Savings Plans`·
/// `price-capacity-optimized`·`최대 20%`·`최대 70%` 를 요구한다. **그 서술은 손대지
/// 않는다.** 또 `최근 14일`(§7 Compute Optimizer)·`capacity-optimized`(§5 전략 목록)·
/// `최소 1분`·`1 ms`·`프로비저닝 동시성`(2026-10-19 정정분)은 **이미 본문에 있어**
/// 그대로 요구하면 가드가 아무것도 보장하지 못한다 → 이 파일은 **새로 쓰는 구체
/// 문구**로만 단정한다(B9a 교훈).
void main() {
  String doc(String id) =>
      File('assets/content/saa/$id.md').readAsStringSync();

  /// 출처·정정 노트 구간을 제외한 **본문**만 본다(B6 교훈 — 맵 §4).
  String body(String id) {
    final t = doc(id);
    final i = t.indexOf('### 📌 출처');
    return i < 0 ? t : t.substring(0, i);
  }

  group('B9b-1 G-4.2-08 — 구매 옵션 세부 (saa-t4-2)', () {
    // 공식: Regional RI = 리전 내 전 AZ 할인·크기 유연성·용량 보장 없음 /
    //       Zonal RI = 특정 AZ 용량 예약 + 할인.
    test('Zonal RI 와 Regional RI 를 용량 보장으로 가른다', () {
      final t = doc('saa-t4-2');
      expect(t.contains('Zonal RI'), isTrue);
      expect(t.contains('Regional RI'), isTrue);
    });

    // 공식: "Billing discounts for Savings Plans and Regional Reserved
    //        Instances apply to Capacity Reservations"
    test('On-Demand Capacity Reservation 과 할인의 결합을 적는다', () {
      expect(doc('saa-t4-2').contains('On-Demand Capacity Reservation'), isTrue);
    });

    // 공식: "Savings Plans doesn't provide capacity reservations"
    // ⚠️ 라이브 q5 가 "SP 우선 권장"을 단정하므로, 용량이 요건일 때의 예외를
    //    분명히 적어야 한다(갭 노트 G-4.2-14 의 "Q1식 일반화 주의").
    test('Savings Plans 가 용량을 예약하지 않음을 적는다', () {
      expect(doc('saa-t4-2').contains('용량을 예약하지 않'), isTrue);
    });

    // 공식: Standard RI(리전·존)만 판매 가능, Convertible 불가, 수수료 12%,
    //       잔여 기간 1개월 이상.
    test('RI Marketplace 조건과 수수료를 적는다', () {
      final t = doc('saa-t4-2');
      expect(t.contains('RI Marketplace'), isTrue);
      expect(t.contains('12%'), isTrue);
    });

    // 공식: RI 적용 후 SP, EC2 Instance SP 가 Compute SP 보다 먼저,
    //       "Each hour's commitment can only be used within that hour".
    test('할인 적용 순서와 시간당 약정 이월 불가를 적는다', () {
      final t = doc('saa-t4-2');
      expect(t.contains('적용 순서'), isTrue);
      expect(t.contains('이월'), isTrue);
    });

    // 공식: Dedicated Host 에 Savings Plans 는 가상 호스트만(`.metal` 제외).
    test('Dedicated Host 의 Savings Plans 적용 범위를 적는다', () {
      expect(doc('saa-t4-2').contains('가상 호스트'), isTrue);
    });
  });

  group('B9b-1 G-4.2-11 — Spot 설계 (saa-t4-2)', () {
    // 공식: 풀 = AZ × 인스턴스 유형 → 다양화.
    test('스팟 용량 풀의 정의를 적는다', () {
      expect(doc('saa-t4-2').contains('AZ × 인스턴스 유형'), isTrue);
    });

    test('속성 기반 인스턴스 유형 선택을 적는다', () {
      expect(doc('saa-t4-2').contains('속성 기반'), isTrue);
    });

    test('Spot 배치 점수를 적는다', () {
      expect(doc('saa-t4-2').contains('Spot 배치 점수'), isTrue);
    });

    test('ASG 용량 재조정(Capacity Rebalancing)을 적는다', () {
      expect(doc('saa-t4-2').contains('Capacity Rebalancing'), isTrue);
    });

    // 공식: On-Demand 폴백은 다른 Spot 중단을 유발할 수 있어 비권장.
    test('온디맨드 폴백이 권장되지 않음을 적는다', () {
      expect(doc('saa-t4-2').contains('온디맨드 폴백'), isTrue);
    });
  });

  group('B9b-1 G-4.2-10 — 스케일링 전략 연계 (saa-t4-2)', () {
    // 공식: "it uses On-Demand Instances by default" · 선택적 On-Demand base
    //       용량을 먼저 확보 · 비율→인스턴스 수 변환 시 소수는 On-Demand 쪽으로 올림.
    test('혼합 인스턴스 정책의 기본값·base 용량을 적는다', () {
      final t = doc('saa-t4-2');
      expect(t.contains('혼합 인스턴스 정책'), isTrue);
      expect(t.contains('온디맨드 기본(base) 용량'), isTrue);
    });

    test('비율 반올림 방향을 적는다', () {
      expect(doc('saa-t4-2').contains('온디맨드 쪽으로 올림'), isTrue);
    });

    test('인스턴스 가중치를 적는다', () {
      expect(doc('saa-t4-2').contains('가중치'), isTrue);
    });

    // 공식: 지표 최소 24시간·최근 14일 분석·"hourly forecast ... next 48 hours"·
    //       6시간마다 갱신·스케일 아웃만(인은 동적 정책).
    // ⚠️ `최근 14일` 은 §7 Compute Optimizer 가 이미 쓰고 있어 `14일 분석` 으로 좁혔다.
    test('예측 스케일링의 데이터 전제와 동작 범위를 적는다', () {
      final t = doc('saa-t4-2');
      expect(t.contains('14일 분석'), isTrue);
      expect(t.contains('향후 48시간'), isTrue);
      expect(t.contains('스케일 아웃만'), isTrue);
    });

    // 공식: 웜 풀 기본 크기 = 최대 용량 − 희망 용량.
    test('웜 풀과 기본 크기를 적는다', () {
      expect(doc('saa-t4-2').contains('웜 풀'), isTrue);
    });
  });

  group('B9b-1 G-4.2-20 — Compute Optimizer 룩백·유휴 권고 (saa-t4-2)', () {
    test('룩백 32일 옵션이 있다', () {
      expect(doc('saa-t4-2').contains('32일'), isTrue);
    });

    // 공식: 유휴 권고 대상에 NAT Gateway·DynamoDB 프로비저닝 테이블·
    //       ElastiCache·MemoryDB 포함.
    test('유휴 권고 대상이 컴퓨팅 밖으로 넓어짐을 적는다', () {
      final t = doc('saa-t4-2');
      expect(t.contains('NAT Gateway'), isTrue);
      expect(t.contains('MemoryDB'), isTrue);
    });

    // 공식: 지원 리소스에 상용 라이선스(SQL Server on EC2) 포함.
    test('상용 라이선스 분석 대상을 적는다', () {
      expect(doc('saa-t4-2').contains('SQL Server'), isTrue);
    });
  });

  group('B9b-1 G-4.2-09 — 인스턴스 패밀리·크기의 비용 요소 (saa-t4-2)', () {
    // 공식: 범주 6종(범용·컴퓨트 최적화·메모리 최적화·가속·스토리지·HPC).
    test('인스턴스 범주 선택 기준을 적는다', () {
      expect(doc('saa-t4-2').contains('컴퓨트 최적화'), isTrue);
    });

    // 공식: "an approximately 10 percent discount on compute costs" (AMD).
    test('AMD 프로세서의 상대 절감을 적는다', () {
      final t = doc('saa-t4-2');
      expect(t.contains('AMD'), isTrue);
      expect(t.contains('약 10%'), isTrue);
    });

    // 공식: Windows Server 는 x86 전용 → Graviton 불가.
    // ⚠️ q14 의 "ARM 에서 동작해야 한다"는 조건의 구체 사례라 정합한다.
    test('Windows Server 가 Graviton 을 쓸 수 없음을 적는다', () {
      expect(doc('saa-t4-2').contains('Graviton을 쓸 수 없'), isTrue);
    });

    // 공식: "T8i, T4g, T3a, and T3 instances launch as unlimited by default" —
    //       24시간 평균이 기준선 이하면 추가 요금 없음.
    test('T 계열 unlimited 의 과금 조건을 적는다', () {
      expect(doc('saa-t4-2').contains('unlimited'), isTrue);
    });

    // 공식: "to save on vCPU-based licensing costs".
    test('Optimize CPUs 를 적는다', () {
      expect(doc('saa-t4-2').contains('Optimize CPUs'), isTrue);
    });
  });

  group('B9b-1 G-4.2-07 — Lambda vs EC2 vs Fargate (saa-t4-2)', () {
    // 공식: Lambda = 요청 수 + 기간(할당 메모리 비례 GB-초),
    //       무료 티어 월 100만 요청·400,000 GB-초.
    test('Lambda 과금 축과 무료 티어 수량을 적는다', () {
      final t = doc('saa-t4-2');
      expect(t.contains('GB-초'), isTrue);
      expect(t.contains('400,000'), isTrue);
    });

    test('Lambda 계층 요금을 적는다', () {
      expect(doc('saa-t4-2').contains('계층 요금'), isTrue);
    });

    // 공식: "A minimum charge of 1 minute applies." · Fargate Spot 최대 70%.
    test('Fargate Spot 을 적는다', () {
      expect(doc('saa-t4-2').contains('Fargate Spot'), isTrue);
    });

    // 공식(FinOps): "container deployments typically prove more cost-effective
    //       than AWS Lambda" — 24/7 고처리량 프로덕션 기준.
    // ⚠️ q13(간헐 burst → Lambda)과 반대 조건이라 보완적이다.
    test('24/7 고처리량에서의 선택 기준을 적는다', () {
      expect(doc('saa-t4-2').contains('24/7'), isTrue);
    });
  });

  group('B9b-1 금지 — G-02 요율 규율', () {
    test('Lambda 단가를 적지 않는다', () {
      final t = body('saa-t4-2');
      expect(t.contains('\$0.20'), isFalse);
      expect(t.contains('\$0.00001667'), isFalse);
    });

    test('T unlimited 정액 요율을 적지 않는다', () {
      expect(body('saa-t4-2').contains('\$0.05'), isFalse);
    });

    test('Optimize CPUs 라이선스 절감액을 적지 않는다', () {
      expect(body('saa-t4-2').contains('vCPU-시간당 \$'), isFalse);
    });

    test('블로그 사례 수치(NLB 절감률·FinOps 월 비용)를 적지 않는다', () {
      final t = body('saa-t4-2');
      expect(t.contains('25% 절감'), isFalse);
      expect(t.contains('\$13.31'), isFalse);
    });
  });
}
