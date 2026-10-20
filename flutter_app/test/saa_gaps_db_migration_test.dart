import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// SAA 갭 보강 배치 B2 — DB 마이그레이션·목적별 DB 가드 (2026-10-20).
///
/// 외부 조사 `docs/content-research/SAA-C03/98-existing-gap.md` 의 `[누락]` 다섯 항목을
/// 공식 문서로 확인해 저작했다:
///   G-3.3-01  DMS·SCT·CDC(동종/이기종) — 24문서 전체 0건이었음
///   G-3.3-02  목적별 DB 유형(문서·와이드 컬럼·그래프·인메모리) — 3.3 문서 0건이었음
///   G-3.3-09  쓰기 집약 패턴과 단일 라이터 한계 — 0건이었음
///   G-4.3-01  DB 마이그레이션 비용(DMS 과금 축·SCT 무료) — `saa-t4-3` 0건이었음
///   G-4.3-03  시계열·열 기반 DB 유형의 비용 관점
///
/// 가드 규율: **금지할 것만 고정하고 요구는 느슨하게**(핵심 키워드 수준).
void main() {
  String doc(String id) =>
      File('assets/content/saa/$id.md').readAsStringSync();

  group('D-1 G-3.3-01 DMS·SCT·CDC (saa-t3-5)', () {
    test('동종·이기종 구분과 DMS 가 있다', () {
      final t35 = doc('saa-t3-5');
      expect(t35.contains('DMS'), isTrue);
      expect(t35.contains('동종'), isTrue);
      expect(t35.contains('이기종'), isTrue);
    });

    test('이기종 스키마 변환 수단(SCT)이 있다', () {
      final t35 = doc('saa-t3-5');
      expect(t35.contains('SCT') || t35.contains('Schema Conversion'), isTrue);
    });

    test('지속 복제(CDC)가 있다', () {
      final t35 = doc('saa-t3-5');
      expect(t35.contains('CDC'), isTrue);
    });

    // 금지: 이기종 전환에서 스키마까지 DMS 가 알아서 바꿔 준다는 서술.
    // 공식은 이기종의 스키마·코드 객체 변환을 SCT 가 맡는다고 가른다.
    test('DMS 가 이기종 스키마를 자동 변환한다고 쓰지 않는다', () {
      final t35 = doc('saa-t3-5');
      expect(t35.contains('DMS가 스키마를 자동으로 변환'), isFalse);
      expect(t35.contains('DMS는 스키마까지 변환'), isFalse);
    });

    test('공식 출처가 실려 있다', () {
      expect(doc('saa-t3-5').contains('dms/latest/userguide'), isTrue);
    });
  });

  group('D-2 G-3.3-09 쓰기 집약·단일 라이터 (saa-t3-5)', () {
    test('라이터가 하나라는 사실과 복제본이 읽기 전용이라는 사실이 있다', () {
      final t35 = doc('saa-t3-5');
      expect(t35.contains('단일 라이터'), isTrue);
      expect(t35.contains('읽기 전용'), isTrue);
    });

    test('쓰기 확장 대안이 제시돼 있다', () {
      final t35 = doc('saa-t3-5');
      expect(t35.contains('샤딩'), isTrue, reason: '쓰기 확장 대안');
    });

    // 금지: Aurora 복제본이 쓰기를 분담한다는 서술(공식: 복제본은 읽기 전용).
    test('복제본이 쓰기를 나눠 받는다고 쓰지 않는다', () {
      final t35 = doc('saa-t3-5');
      expect(t35.contains('복제본이 쓰기를 분담'), isFalse);
      expect(t35.contains('복제본을 늘리면 쓰기 성능'), isFalse);
      expect(t35.contains('라이터를 여러 개'), isFalse);
    });
  });

  group('D-3 G-3.3-02 목적별 DB 유형 (saa-t3-6)', () {
    test('문서·와이드 컬럼·그래프·인메모리 DB 가 등장한다', () {
      final t36 = doc('saa-t3-6');
      for (final k in ['DocumentDB', 'Keyspaces', 'Neptune', 'MemoryDB']) {
        expect(t36.contains(k), isTrue, reason: 'saa-t3-6 에 $k 가 없다');
      }
    });

    // 금지: 두 인메모리 서비스의 성격을 뒤집는 서술.
    // 공식 구분은 ElastiCache = 휘발 캐시 계층, MemoryDB = 영속(내구성) 인메모리 DB.
    test('ElastiCache 와 MemoryDB 의 성격을 뒤집지 않는다', () {
      final t36 = doc('saa-t3-6');
      expect(t36.contains('MemoryDB는 휘발'), isFalse);
      expect(t36.contains('ElastiCache는 영속'), isFalse);
      expect(t36.contains('MemoryDB는 캐시 전용'), isFalse);
    });

    test('공식 출처가 실려 있다', () {
      expect(doc('saa-t3-6').contains('databases-on-aws-how-to-choose'), isTrue);
    });
  });

  group('D-4 G-4.3-01 DB 마이그레이션 비용 (saa-t4-3)', () {
    test('DMS 과금 축과 SCT 무료가 적혀 있다', () {
      final t43 = doc('saa-t4-3');
      expect(t43.contains('DMS'), isTrue);
      expect(t43.contains('복제 인스턴스'), isTrue);
      expect(t43.contains('SCT'), isTrue);
      expect(t43.contains('무료'), isTrue);
    });

    // 금지: SCT 를 유료로 적는 오류(공식: DMS 에 포함되어 비용이 들지 않는다).
    test('SCT 를 유료로 쓰지 않는다', () {
      final t43 = doc('saa-t4-3');
      expect(t43.contains('SCT는 유료'), isFalse);
      expect(t43.contains('SCT 요금'), isFalse);
      expect(t43.contains('SCT 사용료'), isFalse);
    });

    test('공식 출처가 실려 있다', () {
      expect(doc('saa-t4-3').contains('dms/pricing'), isTrue);
    });
  });

  group('D-5 G-4.3-03 시계열·열 기반 DB (saa-t4-3)', () {
    test('시계열·열 기반 선택지가 비용 문서에 있다', () {
      final t43 = doc('saa-t4-3');
      expect(t43.contains('InfluxDB'), isTrue);
      expect(t43.contains('Redshift'), isTrue);
    });

    test('Redshift 의 과금 축(컴퓨트·관리형 스토리지 분리)이 있다', () {
      final t43 = doc('saa-t4-3');
      expect(t43.contains('관리형 스토리지'), isTrue);
    });

    // 금지(99-gaps V-74): 열 기반 DB 간 비용 우열의 공식 기준 문장을 확보하지 못했다.
    // 과금 축만 쓰고 "어느 쪽이 더 싸다"는 단정을 넣지 않는다.
    test('열 기반 DB 간 비용 우열을 단정하지 않는다', () {
      final t43 = doc('saa-t4-3');
      expect(t43.contains('Redshift가 Athena보다 저렴'), isFalse);
      expect(t43.contains('Athena가 Redshift보다 저렴'), isFalse);
      expect(t43.contains('Redshift가 항상 저렴'), isFalse);
    });
  });

  group('D-6 정정 날짜', () {
    test('손댄 세 문서의 lastVerified 가 2026-10-20 이상이다', () {
      for (final id in ['saa-t3-5', 'saa-t3-6', 'saa-t4-3']) {
        final stamp = RegExp(r'lastVerified: (\d{4}-\d{2}-\d{2})')
            .firstMatch(doc(id))
            ?.group(1);
        expect(stamp, isNotNull, reason: '$id lastVerified 항목이 없다');
        expect(stamp!.compareTo('2026-10-20') >= 0, isTrue,
            reason: '$id lastVerified 가 되돌아갔다: $stamp');
      }
    });
  });
}
