import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// SAA 갭 보강 배치 B8a — Task 3.3 잔여 6행 (2026-10-21).
///
/// 배정 정본은 `docs/content-research/SAA-C03/97-gap-batch-map.md` §4 "B8".
/// B8 23행 중 **Task 3.3 잔여 6행**만 담는다(3.4+MACsec 10행은 B8b, 3.5 잔여
/// 7행은 B8c).
///
/// ⚠️ `saa-t3-5` 는 `verified:true` 15/15 **라이브 문항 문서**다.
/// ⚠️ 갭 노트가 `G-3.3-03`(ElastiCache)의 저작 위치를 "3.3 문서"로만 적었는데,
///    실제 ElastiCache 절은 `saa-t3-6` §11~§14 다(`saa-t3-5` 는 RDS·Aurora).
void main() {
  String doc(String id) =>
      File('assets/content/saa/$id.md').readAsStringSync();

  /// 출처·보강 노트 구간을 제외한 **본문**만 본다(B6 교훈 — 맵 §4).
  String body(String id) {
    final t = doc(id);
    final i = t.indexOf('### 📌 출처');
    return i < 0 ? t : t.substring(0, i);
  }

  // B7b 가 도입한 행 단위 헬퍼 `linesWith()` 는 이 배치에서 쓰지 않는다 —
  // B8a 의 금지는 전부 단정형 전체를 집는 형태로 충분했다. 선언만 남기면
  // `unused_element` 로 analyze 게이트(0건)가 깨진다.

  group('B8a-1 G-3.3-04 용량 계획 (saa-t3-5)', () {
    test('RDS 스토리지 오토스케일링 발동 3조건이 있다', () {
      final t = doc('saa-t3-5');
      expect(t.contains('10%'), isTrue, reason: '여유 공간 임계');
      expect(t.contains('5분'), isTrue, reason: '저장 공간 부족 지속');
      expect(t.contains('4회'), isTrue, reason: '24시간 내 수정 횟수');
    });

    test('증분 규칙과 최대 임계값 권고가 있다', () {
      final t = doc('saa-t3-5');
      expect(t.contains('10 GiB'), isTrue);
      expect(t.contains('7시간'), isTrue, reason: '예측 성장 구간');
      expect(t.contains('26%'), isTrue, reason: '최대 임계값 권고');
    });

    test('Aurora I/O-Optimized 전환 규칙이 있다', () {
      final t = doc('saa-t3-5');
      expect(t.contains('I/O-Optimized'), isTrue);
      expect(t.contains('25%'), isTrue, reason: 'I/O 지출 기준');
      expect(t.contains('30일'), isTrue, reason: 'I/O-Optimized 전환 주기');
      expect(t.contains('NVMe'), isTrue, reason: 'NVMe 는 재시작 필요');
    });

    test('Performance Insights 지표명이 공식형이다', () {
      expect(doc('saa-t3-5').contains('db.load.avg'), isTrue);
    });

    // 금지: 추가 스토리지 볼륨도 오토스케일링된다는 서술.
    // 공식: "Storage autoscaling isn't supported for additional storage volumes."
    test('추가 스토리지 볼륨도 오토스케일링된다고 적지 않는다', () {
      final t = body('saa-t3-5');
      expect(t.contains('추가 스토리지 볼륨도 오토스케일링'), isFalse);
      expect(t.contains('추가 스토리지 볼륨에도 적용'), isFalse);
    });

    // 금지: 두 스토리지 구성 사이를 양방향 모두 수시로 바꿀 수 있다는 서술.
    // 공식: I/O-Optimized 로는 30일에 한 번, Standard 로는 언제든지.
    test('두 방향 모두 수시 전환이라고 적지 않는다', () {
      final t = body('saa-t3-5');
      expect(t.contains('양방향 모두 언제든'), isFalse);
      expect(t.contains('서로 자유롭게 전환'), isFalse);
    });

    // 금지: Provisioned IOPS 범위를 단정하는 것.
    // 갭 노트는 `1,000–256,000` 을 적지만 이번 조회로 공식 확인하지 못했다.
    test('PIOPS 범위를 단정하지 않는다', () {
      final t = body('saa-t3-5');
      expect(t.contains('1,000–256,000'), isFalse);
      expect(t.contains('1,000~256,000'), isFalse);
    });
  });

  group('B8a-2 G-3.3-05 읽기 복제본 구성 (saa-t3-5)', () {
    test('Aurora Auto Scaling 사전 정의 지표가 있다', () {
      final t = doc('saa-t3-5');
      expect(t.contains('RDSReaderAverageCPUUtilization'), isTrue);
      expect(t.contains('RDSReaderAverageDatabaseConnections'), isTrue);
    });

    test('정책 1개 제약과 평균 계산 규칙이 있다', () {
      final t = doc('saa-t3-5');
      expect(t.contains('지표마다'), isTrue, reason: '대상 지표당 정책 1개');
      expect(t.contains('커스텀 엔드포인트'), isTrue);
      expect(t.contains('라이터'), isTrue, reason: '라이터는 평균에서 제외');
    });

    test('PostgreSQL 연쇄 복제본 조건이 있다', () {
      final t = doc('saa-t3-5');
      expect(t.contains('14.1'), isTrue);
      expect(t.contains('3단계'), isTrue);
      expect(t.contains('자동 백업'), isTrue, reason: '소스에 자동 백업 필수');
    });

    // 금지: 갭 노트가 적은 "최대 155" — 공식 확인 실패.
    // 공식은 "소스당 최대 15개"와 "14.1+ 에서 체인 최대 3단계"만 적는다.
    test('연쇄 복제본 총수를 155로 적지 않는다', () {
      expect(body('saa-t3-5').contains('155'), isFalse);
    });

    // 금지: Aurora Global Database 의 보조 클러스터에도 Auto Scaling 을
    // 쓸 수 있다는 서술. 공식 제한 목록에 "doesn't support Aurora Auto Scaling
    // for secondary DB clusters" 가 있다.
    test('보조 클러스터에 Auto Scaling을 쓸 수 있다고 적지 않는다', () {
      final t = body('saa-t3-5');
      expect(t.contains('보조 클러스터에도 Aurora Auto Scaling'), isFalse);
      expect(t.contains('보조 클러스터도 Auto Scaling'), isFalse);
    });

    // 금지: 읽기 복제본 승격을 되돌릴 수 있다는 서술.
    test('복제본 승격을 되돌릴 수 있다고 적지 않는다', () {
      final t = body('saa-t3-5');
      expect(t.contains('승격을 되돌릴 수 있'), isFalse);
      expect(t.contains('승격은 되돌릴 수 있'), isFalse);
    });
  });

  group('B8a-3 G-3.3-06 RDS Proxy 내부 동작 (saa-t3-5)', () {
    test('다중화·핀닝과 관측 수단이 있다', () {
      final t = doc('saa-t3-5');
      expect(t.contains('다중화'), isTrue);
      expect(t.contains('핀닝'), isTrue);
      expect(t.contains('DatabaseConnectionsCurrentlySessionPinned'), isTrue);
      expect(t.contains('초기화 쿼리'), isTrue, reason: '핀닝 완화 수단');
    });

    test('엔진별 핀닝 차이가 있다', () {
      final t = doc('saa-t3-5');
      expect(t.contains('PostgreSQL'), isTrue);
      expect(t.contains('세션 핀닝 필터'), isTrue, reason: 'MySQL 계열 전용');
    });

    // 금지: 핀닝이 트랜잭션이 끝나면 풀린다는 서술.
    // 공식: 핀닝된 연결은 **세션이 끝날 때까지**(클라이언트 연결이 끊길 때까지)
    //       같은 DB 연결을 쓰고 다른 클라이언트가 재사용할 수 없다.
    test('핀닝이 트랜잭션 종료로 풀린다고 적지 않는다', () {
      final t = body('saa-t3-5');
      expect(t.contains('트랜잭션이 끝나면 핀닝이 풀'), isFalse);
      expect(t.contains('핀닝은 트랜잭션 단위'), isFalse);
    });
  });

  group('B8a-4 G-3.3-08 Aurora Global Database (saa-t3-5)', () {
    test('구성 요건 수치가 있다', () {
      final t = doc('saa-t3-5');
      expect(t.contains('Global Database') || t.contains('글로벌 데이터베이스'),
          isTrue);
      expect(t.contains('db.r5'), isTrue, reason: '메모리 최적화 클래스 권고');
    });

    // 느슨한 `contains('15')` 로는 다른 절의 15가 걸려 의미가 없다.
    // 핵심은 **보조 리전 수와 1차 Replica 가 하나의 예산을 나눈다**는 관계다.
    test('1차 Replica = 15 − 보조 리전 수 관계가 있다', () {
      final t = doc('saa-t3-5');
      expect(t.contains('15 − (보조 리전 수)'), isTrue,
          reason: '공식 표의 "15 - s" 를 관계식으로 적어야 한다');
      expect(t.contains('≤ 15'), isTrue,
          reason: '1차 리더 수 + 보조 클러스터 수 ≤ 15');
    });

    // 금지: 보조 리전 클러스터에 라이터가 있다는 서술.
    test('보조 클러스터에 라이터가 있다고 적지 않는다', () {
      final t = body('saa-t3-5');
      expect(t.contains('보조 클러스터에도 라이터'), isFalse);
      expect(t.contains('보조 리전에서도 쓰기'), isFalse);
    });
  });

  group('B8a-5 G-3.3-03 ElastiCache 현행 구성 (saa-t3-6)', () {
    test('현행 엔진과 Serverless가 있다', () {
      final t = doc('saa-t3-6');
      expect(t.contains('Valkey'), isTrue);
      expect(t.contains('ElastiCache Serverless'), isTrue);
    });

    test('Serverless 한도가 있다', () {
      final t = doc('saa-t3-6');
      expect(t.contains('5,000 GiB'), isTrue, reason: '캐시당 크기');
      expect(t.contains('32 GiB'), isTrue, reason: '슬롯당 크기');
      expect(t.contains('ECPU'), isTrue);
    });

    test('MemoryDB와의 구분이 있다', () {
      final t = doc('saa-t3-6');
      expect(t.contains('MemoryDB'), isTrue);
      expect(t.contains('트랜잭션 로그'), isTrue,
          reason: 'Multi-AZ 트랜잭션 로그가 내구성의 근거다');
    });

    // 금지: ElastiCache 를 영속 데이터베이스로 쓰라는 서술.
    // 공식 구분: MemoryDB 가 내구성 있는 인메모리 **데이터베이스**다.
    test('ElastiCache를 영속 DB로 쓸 수 있다고 적지 않는다', () {
      final t = body('saa-t3-6');
      expect(t.contains('ElastiCache를 영속 데이터베이스로'), isFalse);
      expect(t.contains('ElastiCache는 내구성 있는 데이터베이스'), isFalse);
    });

    // 금지: 엔진 버전 다운그레이드가 가능하다는 서술.
    test('엔진 다운그레이드가 가능하다고 적지 않는다', () {
      final t = body('saa-t3-6');
      expect(t.contains('다운그레이드할 수 있'), isFalse);
      expect(t.contains('다운그레이드도 가능'), isFalse);
    });
  });

  group('B8a-6 G-3.3-07 DynamoDB 용량·파티션 한도 (saa-t3-6)', () {
    test('파티션 한도와 항목 크기가 있다', () {
      final t = doc('saa-t3-6');
      expect(t.contains('3,000'), isTrue, reason: '파티션당 읽기');
      expect(t.contains('1,000'), isTrue, reason: '파티션당 쓰기');
      expect(t.contains('400 KB'), isTrue, reason: '항목 최대 크기');
      expect(t.contains('KeyRangeThroughputExceeded'), isTrue);
    });

    test('현행 온디맨드 모델(warm throughput)이 있다', () {
      final t = doc('saa-t3-6');
      expect(t.contains('warm throughput') || t.contains('웜 스루풋'), isTrue);
      expect(t.contains('12,000'), isTrue, reason: '새 온디맨드 테이블 읽기');
      expect(t.contains('4,000'), isTrue, reason: '새 온디맨드 테이블 쓰기');
      expect(t.contains('적응형 용량'), isTrue);
    });

    // 금지: 온디맨드를 "이전 피크의 2배" 모델로 적는 것.
    // 현행 공식 문서는 그 규칙 대신 **warm throughput** 으로 설명한다.
    test('온디맨드를 이전 피크의 2배 규칙으로 적지 않는다', () {
      final t = body('saa-t3-6');
      expect(t.contains('이전 피크의 2배'), isFalse);
      expect(t.contains('이전 최대치의 2배'), isFalse);
      expect(t.contains('30분 규칙'), isFalse);
    });

    // 금지: 사전 웜업으로 올린 값을 되돌릴 수 있다는 서술.
    // 공식: "After warm throughput is increased, the values can't be decreased."
    test('웜 스루풋을 되돌릴 수 있다고 적지 않는다', () {
      final t = body('saa-t3-6');
      expect(t.contains('다시 낮출 수 있'), isFalse);
      expect(t.contains('되돌릴 수 있습니다'), isFalse);
    });
  });

  group('B8a-7 G-3.3-08 글로벌 테이블 일관성 모드 (saa-t3-6)', () {
    test('두 모드와 기본값이 있다', () {
      final t = doc('saa-t3-6');
      expect(t.contains('MREC'), isTrue);
      expect(t.contains('MRSC'), isTrue);
      expect(t.contains('ReplicatedWriteConflictException'), isTrue);
    });

    test('MRSC 배포 제약이 있다', () {
      final t = doc('saa-t3-6');
      expect(t.contains('증인') || t.contains('witness'), isTrue);
      expect(t.contains('세 개 리전') || t.contains('3개 리전'), isTrue);
    });

    // 금지: MRSC 가 트랜잭션 API 를 지원한다는 서술.
    // 공식: "Global tables using MRSC do not support the transaction APIs."
    test('MRSC가 트랜잭션 API를 지원한다고 적지 않는다', () {
      final t = body('saa-t3-6');
      expect(t.contains('MRSC도 트랜잭션'), isFalse);
      expect(t.contains('MRSC는 트랜잭션 API를 지원'), isFalse);
    });

    // 금지: 생성 후 일관성 모드를 바꿀 수 있다는 서술.
    test('생성 후 일관성 모드를 바꿀 수 있다고 적지 않는다', () {
      final t = body('saa-t3-6');
      expect(t.contains('나중에 일관성 모드를 변경'), isFalse);
      expect(t.contains('일관성 모드를 바꿀 수 있'), isFalse);
    });

    // 금지가 아니라 **교정 문맥 요구**(맵 §4의 ①) — 기존 본문이 글로벌 테이블
    // 충돌 해소를 last-writer-wins 로만 적고 있었다. 그 서술이 남아 있어도
    // 되지만, 그것이 **MREC 의 동작**이라는 문맥이 같은 문서에 있어야 한다.
    test('last-writer-wins를 모드 문맥 없이 적지 않는다', () {
      final t = body('saa-t3-6');
      if (t.contains('last-writer-wins') || t.contains('마지막 쓰기')) {
        expect(t.contains('MREC'), isTrue,
            reason: 'LWW 는 MREC 의 동작이고 MRSC 에는 적용되지 않는다');
      }
    });
  });
}
