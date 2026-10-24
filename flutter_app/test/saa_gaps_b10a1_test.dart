import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// SAA 갭 보강 배치 **B10a-1** — Task 4.3 중 **신규 주제 5행** (2026-10-24).
///
/// 배정 정본은 `docs/content-research/SAA-C03/97-gap-batch-map.md` §4 "B10".
/// B10 20행을 **Task 4.3 신규(B10a-1) · Task 4.3 보강(B10a-2) · Task 4.4(B10b)** 로
/// 쪼갰다 — `saa-t4-3` 가 **`verified:true` 15/15 라이브 문항 문서**라 한 번에 넣는
/// 변경 폭을 줄이는 쪽을 골랐다(B9b 에서 효과가 확인된 방식).
///
/// 5행을 **3개 절로 묶었다**: §8 엔진·라이선스(`02`) · §9 연결·캐싱(`04`·`05`) ·
/// §10 끄고·낮추고·찾기(`09`·`11`).
///
/// ## ⚠️ 라이브 문항과의 정합
///
/// - **q7** 의 정답이 "ElastiCache 를 앞단에 배치해 반복 쿼리를 캐싱하고 DB 요청 수를
///   줄인다" 다. §9 의 캐싱 전략 서술은 그 정답을 **확장**하는 방향이라 정합한다.
/// - **q14** 의 정답이 "AWS Compute Optimizer" 다. §10 의 비용 도구 연계는 Trusted
///   Advisor·Budgets 를 **더하는** 것이고 Compute Optimizer 의 역할을 바꾸지 않는다.
/// - **q11·q12**(백업 보존·수동 스냅샷)는 B10a-2 의 `G-4.3-08` 소관이라 이 배치에서
///   건드리지 않는다.
///
/// ## ⚠️ 구조 불변식
///
/// 저작 전 `saa-t4-3` 은 **서브섹션 7 / 원리 7** 로 하한 `min(7,7)=7` 에 **정확히
/// 캡**돼 있었다. 절을 3개 늘리면 하한이 8 로 올라가므로 **신규 절마다 원리 블록을
/// 함께** 넣는다(B7b·B8b 패턴).
///
/// ## ⚠️ 쓰지 않는 것 (G-02 요율 규율 + 블로그 전용 근거)
///
/// Extended Support **vCPU-시간 단가**(리전·연차에 따라 오른다) · 상용 엔진 → 오픈소스
/// 전환의 **사례 절감률** · Valkey 의 **33%·20%** 와 캐시 도입 **55%·80배**(모두 블로그
/// 전용 근거 — NLB 25% 를 뺀 B9b-2 와 같은 기준). 과금 축·구조·한도만 적는다.
/// ⚠️ `최대 60%` 는 **이미 본문에 있다**(RDS RI 할인율 표) — 금지 후보에서 뺐다.
void main() {
  String doc(String id) =>
      File('assets/content/saa/$id.md').readAsStringSync();

  /// 출처·정정 노트 구간을 제외한 **본문**만 본다(B6 교훈 — 맵 §4).
  String body(String id) {
    final t = doc(id);
    final i = t.indexOf('### 📌 출처');
    return i < 0 ? t : t.substring(0, i);
  }

  group('B10a-1 G-4.3-02 — DB 엔진 선택과 라이선스 (saa-t4-3)', () {
    // 공식: "MySQL has improved performance for high-frequency read
    //        operations." · PostgreSQL 은 객체-관계형이고 쓰기 빈번에 강하다.
    test('MySQL·PostgreSQL 을 읽기/쓰기 빈도 축으로 가른다', () {
      final t = doc('saa-t4-3');
      expect(t.contains('읽기 빈번'), isTrue);
      expect(t.contains('쓰기 빈번'), isTrue);
    });

    test('PostgreSQL 의 객체-관계형 성격을 적는다', () {
      expect(doc('saa-t4-3').contains('객체-관계형'), isTrue);
    });

    // 공식(지침): 상용 엔진 라이선스 비용을 오픈소스 엔진 전환으로 줄인다.
    test('상용 엔진에서 오픈소스로 가는 라이선스 절감 축을 적는다', () {
      expect(doc('saa-t4-3').contains('상용 엔진에서 오픈소스'), isTrue);
    });
  });

  group('B10a-1 G-4.3-04 — DB 연결·프록시 요금 (saa-t4-3)', () {
    // 공식: "RDS Proxy is priced based on the capacity of underlying
    //        instances." — 프로비저닝은 vCPU-시간당, Aurora Serverless 는
    //        ACU-시간당.
    test('RDS Proxy 의 과금 축을 적는다', () {
      final t = doc('saa-t4-3');
      expect(t.contains('RDS Proxy'), isTrue);
      expect(t.contains('ACU-시간당'), isTrue);
    });

    test('초 단위·10분 최소 과금을 적는다', () {
      expect(doc('saa-t4-3').contains('10분 최소'), isTrue);
    });
  });

  group('B10a-1 G-4.3-05 — 캐싱 전략과 ElastiCache 비용 (saa-t4-3)', () {
    // ⚠️ q7 정합: 정답이 "ElastiCache 로 DB 요청 수를 줄인다" 이므로 그 전략을
    //    구체화하는 방향으로만 쓴다.
    test('지연 로딩과 쓰기 시 갱신을 가른다', () {
      final t = doc('saa-t4-3');
      expect(t.contains('지연 로딩'), isTrue);
      expect(t.contains('쓰기 시 갱신'), isTrue);
    });

    test('DynamoDB 앞단 캐시로 DAX 를 적는다', () {
      expect(doc('saa-t4-3').contains('DAX'), isTrue);
    });

    test('Valkey 와 예약 노드를 비용 레버로 적는다', () {
      final t = doc('saa-t4-3');
      expect(t.contains('Valkey'), isTrue);
      expect(t.contains('예약 노드'), isTrue);
    });

    test('데이터 티어링을 적는다', () {
      expect(doc('saa-t4-3').contains('데이터 티어링'), isTrue);
    });
  });

  group('B10a-1 G-4.3-09 — 중지·Multi-AZ·Extended Support (saa-t4-3)', () {
    // 공식: "you're not charged for DB instance hours" — 중지는 최대 7일이고
    //       그 뒤 자동 재시작된다. 스토리지·백업·퍼블릭 IPv4 는 계속 과금.
    test('RDS 중지의 7일 한도와 계속 과금되는 항목을 적는다', () {
      final t = doc('saa-t4-3');
      expect(t.contains('최대 7일'), isTrue);
      expect(t.contains('퍼블릭 IPv4'), isTrue);
    });

    // 공식: "can cost approximately twice as much" (Multi-AZ).
    test('Multi-AZ 의 비용 배수를 적는다', () {
      expect(doc('saa-t4-3').contains('약 2배'), isTrue);
    });

    // 공식: "RDS Extended Support is priced per vCPU per hour."
    test('Extended Support 를 적는다', () {
      expect(doc('saa-t4-3').contains('Extended Support'), isTrue);
    });
  });

  group('B10a-1 G-4.3-11 — 비용 도구의 DB 연계 (saa-t4-3)', () {
    // 공식: Trusted Advisor "Amazon RDS Idle DB Instances" + 각종 예약 최적화.
    test('Trusted Advisor 의 유휴 DB·예약 최적화 점검을 적는다', () {
      final t = doc('saa-t4-3');
      expect(t.contains('유휴 DB 인스턴스'), isTrue);
      expect(t.contains('예약 최적화'), isTrue);
    });

    // 공식: "RI alerts support Amazon EC2, Amazon RDS, Amazon Redshift, and
    //        Amazon ElastiCache reservations."
    test('Budgets 의 RI 사용률 알림이 DB 예약을 포함함을 적는다', () {
      expect(doc('saa-t4-3').contains('RI 사용률'), isTrue);
    });
  });

  group('B10a-1 금지 — 요율·블로그 전용 근거', () {
    test('Extended Support 의 vCPU-시간 단가를 적지 않는다', () {
      final t = body('saa-t4-3');
      expect(t.contains('\$0.100'), isFalse);
      expect(t.contains('\$0.200'), isFalse);
      expect(t.contains('vCPU-시간당 \$'), isFalse);
    });

    test('엔진 전환의 사례 절감률을 적지 않는다', () {
      final t = body('saa-t4-3');
      expect(t.contains('최대 80%'), isFalse);
      expect(t.contains('최대 70%'), isFalse);
    });

    // 블로그 전용 근거 — NLB 25% 를 뺀 B9b-2 와 같은 기준.
    test('Valkey·캐시 도입의 블로그 수치를 적지 않는다', () {
      final t = body('saa-t4-3');
      expect(t.contains('33%'), isFalse);
      expect(t.contains('20% 저렴'), isFalse);
      expect(t.contains('최대 55%'), isFalse);
      expect(t.contains('80배'), isFalse);
    });
  });
}
