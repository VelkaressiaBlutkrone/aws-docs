import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// SAA 갭 보강 배치 **B10a-2** — Task 4.3 중 **기존 절 보강 4행** (2026-10-24).
///
/// 배정 정본은 `docs/content-research/SAA-C03/97-gap-batch-map.md` §4 "B10".
/// B10a-1(신규 절 5행)에 이어 **이미 있는 절을 깊게 만드는 4행**을 넣는다 —
/// §3 용량 계획(`06` 일부·`07`) · §4 서버리스·온디맨드(`06` 일부·`10`) ·
/// §5 백업 보존(`08`).
///
/// ## ⚠️ 라이브 문항과의 정합 (`saa-t4-3` 은 `verified:true` 15/15)
///
/// - **q7** 의 오답 해설이 *"RDS Multi-AZ Standby 는 HA 를 위한 대기 복제본으로 읽기
///   요청을 직접 처리하지 않습니다"* 라고 적는다 → §3 의 복제본 비용 서술도 **같은
///   구분**(읽기 분산은 복제본 / 가용성은 Multi-AZ)을 유지한다.
/// - **q9**(야간·주말 유휴 → 온디맨드)와 **q10**(일정·예측 가능 → 프로비저닝 +
///   Auto Scaling)은 새로 넣는 **활용률 35% 기준**과 정합한다 — 유휴가 길면 활용률이
///   낮아 온디맨드, 안정적이면 활용률이 높아 프로비저닝이다.
/// - **q11**(보존 기간 단축 → 비용 감소)·**q12**(수동 스냅샷은 인스턴스와 독립)는
///   §5 보강이 **덧붙이는** 방향이라 충돌하지 않는다.
///
/// ## ⚠️ 가드 문구를 좁힌 이유 (실측)
///
/// `TTL`(3)·`35%`(2)·`RPU`(2)·`교차 리전`(1)·`0~35일`(1)·`Redshift Serverless`(1) 은
/// **이미 본문에 있다** — B10a-1 에서 캐싱 절에 TTL 을 넣었고, §7 이 Redshift 를
/// 다룬다. 그대로 요구하면 가드가 아무것도 보장하지 못하므로 **새로 쓰는 구체 문구**
/// 로만 단정한다(`TTL로 만료`·`활용률 35%`·`최소 60초`·`교차 리전 복제본`).
///
/// ## ⚠️ 쓰지 않는 것
///
/// Aurora I/O-Optimized 의 **최대 40% 절감**과 DynamoDB 자동 확장 실험의 **30.8% 절감**
/// 은 둘 다 **블로그 전용 근거**라 쓰지 않는다(B9b-2·B10a-1 과 같은 기준). 반면
/// 예약 용량 **54%·77%** 와 Standard-IA **60%** 는 공식 요금 페이지 수치라 쓴다.
void main() {
  String doc(String id) =>
      File('assets/content/saa/$id.md').readAsStringSync();

  String body(String id) {
    final t = doc(id);
    final i = t.indexOf('### 📌 출처');
    return i < 0 ? t : t.substring(0, i);
  }

  group('B10a-2 G-4.3-07 — 읽기 복제본의 비용 (saa-t4-3)', () {
    // 공식: "A Read replica is billed as a standard DB instance and at the
    //        same rates."
    test('복제본이 표준 인스턴스와 같은 요율로 과금됨을 적는다', () {
      final t = doc('saa-t4-3');
      expect(t.contains('별도 인스턴스'), isTrue);
      expect(t.contains('같은 요율'), isTrue);
    });

    // 공식: 교차 리전 복제본은 리전 간 데이터 전송이 과금된다.
    test('교차 리전 복제본의 전송 과금을 적는다', () {
      expect(doc('saa-t4-3').contains('교차 리전 복제본'), isTrue);
    });

    // 공식: MySQL·MariaDB 는 복제본에서 복제본을 만들 수 있고 같은 리전 내
    //       전송은 무과금이라 다중 복제본의 전송 비용이 줄어든다.
    test('연쇄 복제본으로 전송 비용을 줄이는 수단을 적는다', () {
      expect(doc('saa-t4-3').contains('연쇄'), isTrue);
    });
  });

  group('B10a-2 G-4.3-06 — 용량 단위와 절감 수단 (saa-t4-3)', () {
    // 공식: I/O-Optimized 는 "best choice when your I/O spending is 25% or
    //       more"; 반대 방향 전환은 30일에 1회.
    test('Aurora I/O-Optimized 의 선택 기준을 적는다', () {
      final t = doc('saa-t4-3');
      expect(t.contains('I/O-Optimized'), isTrue);
      expect(t.contains('30일에 한 번'), isTrue);
    });

    // 공식: 예약 용량은 프로비저닝 전용(1년 54%·3년 77%, 단일 리전·Standard).
    test('DynamoDB 예약 용량의 조건을 적는다', () {
      expect(doc('saa-t4-3').contains('예약 용량'), isTrue);
    });

    // 공식: "reduces storage costs by 60% compared to existing Standard
    //        tables" — 단 처리량 단가는 Standard 보다 높다.
    test('Standard-IA 테이블 클래스의 트레이드오프를 적는다', () {
      expect(doc('saa-t4-3').contains('Standard-IA'), isTrue);
    });

    // ⚠️ `TTL` 은 B10a-1 의 캐싱 절에 이미 있어 좁혔다.
    test('TTL 로 저장량을 줄이는 수단을 적는다', () {
      expect(doc('saa-t4-3').contains('TTL로 만료'), isTrue);
    });
  });

  group('B10a-2 G-4.3-10 — 서버리스 선택지와 모드 기준 (saa-t4-3)', () {
    // 공식: "On-demand mode costs less for workloads with average provisioned
    //        capacity utilization below 35%."
    // ⚠️ `35%` 는 이미 본문에 있어 `활용률 35%` 로 좁혔다. q9·q10 과 정합한다.
    test('DynamoDB 모드 선택의 정량 기준을 적는다', () {
      expect(doc('saa-t4-3').contains('활용률 35%'), isTrue);
    });

    test('ElastiCache Serverless 를 선택지로 적는다', () {
      expect(doc('saa-t4-3').contains('ElastiCache Serverless'), isTrue);
    });

    // 공식: Redshift Serverless 는 RPU-시간을 초 단위로 재되 최소 60초.
    // ⚠️ `RPU`·`Redshift Serverless` 는 §7 에 이미 있어 `최소 60초` 로 좁혔다.
    test('Redshift Serverless 의 최소 과금 단위를 적는다', () {
      expect(doc('saa-t4-3').contains('최소 60초'), isTrue);
    });
  });

  group('B10a-2 G-4.3-08 — 백업·보존 정책의 비용 (saa-t4-3)', () {
    // 공식: Aurora 는 "no additional charge for backup storage of up to 100%"
    //       (클러스터 총 Aurora 스토리지 기준).
    test('Aurora 백업의 100% 무료 범위를 적는다', () {
      expect(doc('saa-t4-3').contains('100%까지 무료'), isTrue);
    });

    // 공식: 자동 시스템 스냅샷은 복사하지 않으면 무료이고 **복사본은 항상 과금**.
    test('스냅샷 복사본이 항상 과금됨을 적는다', () {
      expect(doc('saa-t4-3').contains('복사본은 항상 과금'), isTrue);
    });

    // 공식: "PITR incurs additional charges." + 온디맨드 백업은 저장 GB-월.
    test('DynamoDB PITR·온디맨드 백업의 과금을 적는다', () {
      final t = doc('saa-t4-3');
      expect(t.contains('PITR'), isTrue);
      expect(t.contains('온디맨드 백업'), isTrue);
    });

    test('AWS Backup 을 백업 관리 수단으로 적는다', () {
      expect(doc('saa-t4-3').contains('AWS Backup'), isTrue);
    });
  });

  group('B10a-2 전환 방향·근거', () {
    // ⚠️ 2026-10-24 실측 정정 — `최대 40% 절감` 을 "블로그 전용"으로 보고 금지했다가
    //    **Aurora 요금 페이지 본문**에서 확인했다("if your I/O spend exceeds 25% of
    //    your total Aurora database spend, you can save up to 40% on costs").
    //    금지를 걷고 **요구**로 바꿨다 — 근거를 확인하기 전에 금지부터 건 실수다.
    test('I/O-Optimized 의 절감 상한을 공식 수치로 적는다', () {
      expect(doc('saa-t4-3').contains('최대 40% 절감'), isTrue);
    });

    // ⚠️ 전환 제약은 **방향마다 다르다**(`4-3.md` F-04). 처음에 반대로 썼다가
    //    잡았다: I/O-Optimized → Standard 는 언제든, Standard → I/O-Optimized 가
    //    30일에 한 번이다.
    test('전환 제약의 방향을 뒤집어 적지 않는다', () {
      final t = body('saa-t4-3');
      expect(t.contains('Standard → I/O-Optimized는 30일에 한 번'), isTrue);
      expect(t.contains('되돌리는 방향은 **30일에 한 번**'), isFalse);
    });

    test('자동 확장 실험의 블로그 절감률을 적지 않는다', () {
      expect(body('saa-t4-3').contains('30.8%'), isFalse);
    });
  });
}
