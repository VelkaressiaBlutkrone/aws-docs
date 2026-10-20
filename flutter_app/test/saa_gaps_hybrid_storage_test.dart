import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// SAA 갭 보강 배치 B1 — 하이브리드 스토리지·전송 서비스 가드 (2026-10-20).
///
/// 외부 조사 `docs/content-research/SAA-C03/98-existing-gap.md` 의 `[누락]`·`[부분]`
/// 중 네 항목을 공식 문서로 확인해 저작했다:
///   G-3.1-01  하이브리드 스토리지 솔루션(Storage Gateway) — 24문서 전체 0건이었음
///   G-3.5-06  수집 맥락의 Storage Gateway vs DataSync 구분 — 0건이었음
///   G-4.1-04  하이브리드·마이그레이션 전송 서비스의 비용 선택 — `saa-t4-1` 0건이었음
///   G-2.1-04  Transfer Family 세부(프로토콜·요금 구조)
///
/// 가드 규율(2026-10-20 교훈 `saa-t1-4-q10`): **금지할 것만 고정하고 요구는 느슨하게**.
/// 요구는 핵심 키워드 수준으로만 둬서 다음 재검수가 문장을 다듬을 여지를 남긴다.
void main() {
  String doc(String id) =>
      File('assets/content/saa/$id.md').readAsStringSync();

  group('H-1 G-3.1-01 하이브리드 스토리지 — Storage Gateway (saa-t3-2)', () {
    test('게이트웨이 4유형이 모두 등장한다', () {
      final t32 = doc('saa-t3-2');
      for (final k in [
        'S3 File Gateway',
        'FSx File Gateway',
        'Volume Gateway',
        'Tape Gateway',
      ]) {
        expect(t32.contains(k), isTrue, reason: 'saa-t3-2 에 $k 가 없다');
      }
    });

    test('Volume Gateway 의 캐시형/저장형 구분과 iSCSI 인터페이스가 있다', () {
      final t32 = doc('saa-t3-2');
      expect(t32.contains('iSCSI'), isTrue, reason: 'Volume/Tape 게이트웨이 인터페이스');
      expect(t32.contains('캐시형'), isTrue, reason: 'cached volumes');
      expect(t32.contains('저장형'), isTrue, reason: 'stored volumes');
    });

    test('Tape Gateway 의 아카이브 대상이 Glacier 계열로 적혀 있다', () {
      expect(doc('saa-t3-2').contains('Glacier'), isTrue);
    });

    test('배포 형태(VM·EC2·하드웨어 어플라이언스)가 적혀 있다', () {
      final t32 = doc('saa-t3-2');
      expect(t32.contains('어플라이언스'), isTrue);
      expect(t32.contains('EC2'), isTrue);
    });

    test('공식 출처가 실려 있다', () {
      expect(doc('saa-t3-2').contains('storagegateway'), isTrue);
    });
  });

  group('H-2 G-3.5-06 Storage Gateway vs DataSync (saa-t3-9)', () {
    test('전송 서비스 절에 Storage Gateway 가 들어 있다', () {
      expect(doc('saa-t3-9').contains('File Gateway'), isTrue);
    });

    test('"이전은 DataSync · 이후 지속 접근은 File Gateway" 구분이 있다', () {
      final t39 = doc('saa-t3-9');
      expect(t39.contains('DataSync'), isTrue);
      expect(t39.contains('지속'), isTrue,
          reason: '지속적 하이브리드 접근 vs 전송 작업의 구분 서술');
    });

    // 금지: 공식 FAQ 는 둘을 "이전(DataSync) → 이후 접근(File Gateway)"으로 가른다.
    // Storage Gateway 를 대용량 일회성 이전 수단으로 적는 것은 그 구분을 뒤집는다.
    test('Storage Gateway 를 일회성 대량 이전 수단으로 적지 않는다', () {
      final t39 = doc('saa-t3-9');
      expect(t39.contains('Storage Gateway로 일회성'), isFalse);
      expect(t39.contains('Storage Gateway로 초기 마이그레이션'), isFalse);
    });
  });

  group('H-3 G-2.1-04 Transfer Family 세부 (saa-t3-9 · saa-t4-1)', () {
    test('AS2 를 포함한 프로토콜이 적혀 있다', () {
      expect(doc('saa-t3-9').contains('AS2'), isTrue);
    });

    test('요금 구조(프로토콜별 시간당 + 전송량)가 적혀 있다', () {
      final t41 = doc('saa-t4-1');
      expect(t41.contains('Transfer Family'), isTrue);
      expect(t41.contains('시간당'), isTrue, reason: '프로토콜별 시간당 요금');
    });

    // 금지(공식 FAQ 실측): 서버를 **중지**해도 과금은 계속되고 **삭제**해야 멈춘다.
    // 조사 노트 G-2.1-04 가 "중지해도 과금 없음"으로 잘못 적어 둔 항목이라 못박는다.
    test('"중지하면 과금이 멈춘다"는 오류를 쓰지 않는다', () {
      for (final id in ['saa-t3-9', 'saa-t4-1']) {
        final body = doc(id);
        expect(body.contains('중지하면 과금이 멈춥니다'), isFalse, reason: id);
        expect(body.contains('중지하면 요금이 발생하지 않습니다'), isFalse, reason: id);
        expect(body.contains('중지해도 과금되지 않습니다'), isFalse, reason: id);
      }
    });
  });

  group('H-4 G-4.1-04 전송·하이브리드 서비스의 비용 선택 (saa-t4-1)', () {
    test('DataSync·Transfer Family·Storage Gateway 가 비용 문서에 있다', () {
      final t41 = doc('saa-t4-1');
      for (final k in ['DataSync', 'Transfer Family', 'Storage Gateway']) {
        expect(t41.contains(k), isTrue, reason: 'saa-t4-1 에 $k 가 없다');
      }
    });

    test('Transfer Acceleration 이 추가 요금이라는 점이 적혀 있다', () {
      final t41 = doc('saa-t4-1');
      expect(t41.contains('Transfer Acceleration'), isTrue);
      expect(t41.contains('추가 요금'), isTrue);
    });

    // 금지: Snow 패밀리는 신규 고객이 주문할 수 없다(PR #140 에서 saa-t3-9 가 정정됨).
    // 비용 문서에서 "가장 저렴한 전송"의 답으로 되살아나는 것을 막는다.
    test('Snow 패밀리를 현행 전송 선택지로 되살리지 않는다', () {
      final t41 = doc('saa-t4-1');
      expect(t41.contains('Snowball을 사용합니다'), isFalse);
      expect(t41.contains('Snow 패밀리를 사용합니다'), isFalse);
      expect(t41.contains('Snowball이 가장 저렴'), isFalse);
    });

    test('공식 출처가 실려 있다', () {
      final t41 = doc('saa-t4-1');
      expect(t41.contains('datasync') || t41.contains('DataSync FAQ'), isTrue);
      expect(t41.contains('aws-transfer-family') || t41.contains('transfer/latest'),
          isTrue);
    });
  });

  group('H-5 정정 날짜', () {
    // 날짜를 리터럴로 못박으면 다음 재검수가 이 테스트를 먼저 터뜨린다
    // (선례 `saa_t12_t13_facts_test.dart`). 되돌아가는 것만 막고 갱신은 허용한다.
    test('손댄 세 문서의 lastVerified 가 2026-10-20 이상이다', () {
      for (final id in ['saa-t3-2', 'saa-t3-9', 'saa-t4-1']) {
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
