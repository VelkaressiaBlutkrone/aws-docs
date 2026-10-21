import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// SAA 갭 보강 배치 B9a — Task 4.1 잔여 중 **스토리지 10행** (2026-10-21).
///
/// 배정 정본은 `docs/content-research/SAA-C03/97-gap-batch-map.md` §4 "B9".
/// B9 24행 중 Task 4.1 잔여는 12행인데, 그중 **`saa-t4-1` 소관 10행**만 담는다.
/// 나머지 2행(`G-4.1-11`·`G-4.1-12`)은 `saa-t4-5` 소관이고 **미머지 #185 가
/// 같은 파일을 건드려** 순차로 미뤘다 — 겹치는 파일은 `saa-t4-5.md` 하나뿐이라
/// 10행은 지금 안전하게 들어간다.
///
/// ⚠️ **G-02 규율**: 이 배치는 비용이라 리전 의존 요율이 많다. 공식 수치가
///    확인된 **구조·한도**만 쓰고 **구체 요율은 쓰지 않는다**(과금 축만).
void main() {
  String doc(String id) =>
      File('assets/content/saa/$id.md').readAsStringSync();

  /// 출처·보강 노트 구간을 제외한 **본문**만 본다(B6 교훈 — 맵 §4).
  String body(String id) {
    final t = doc(id);
    final i = t.indexOf('### 📌 출처');
    return i < 0 ? t : t.substring(0, i);
  }

  group('B9a-1 G-4.1-01 Requester Pays (saa-t4-1)', () {
    test('과금 주체와 인증 전제가 있다', () {
      final t = doc('saa-t4-1');
      expect(t.contains('Requester Pays'), isTrue);
      expect(t.contains('x-amz-request-payer'), isTrue);
      expect(t.contains('익명'), isTrue, reason: '익명 접근 불가');
    });

    // 금지: 요청자가 **저장** 비용까지 낸다는 서술.
    // 공식: "The bucket owner always pays the cost of storing data."
    test('요청자가 저장 비용도 낸다고 적지 않는다', () {
      final t = body('saa-t4-1');
      expect(t.contains('요청자가 저장 비용'), isFalse);
      expect(t.contains('스토리지 비용도 요청자'), isFalse);
    });

    // 금지: Requester Pays 버킷에 익명 접근이 가능하다는 서술.
    test('익명 접근이 가능하다고 적지 않는다', () {
      final t = body('saa-t4-1');
      expect(t.contains('익명 접근도 가능'), isFalse);
      expect(t.contains('익명 요청을 허용'), isFalse);
    });
  });

  group('B9a-2 G-4.1-02 소형 객체와 배치 전략 (saa-t4-1)', () {
    test('Glacier 오버헤드 내역이 있다', () {
      final t = doc('saa-t4-1');
      expect(t.contains('40 KB'), isTrue, reason: '객체당 총 오버헤드');
      expect(t.contains('8 KB'), isTrue, reason: 'Standard 요율 부분');
      expect(t.contains('32 KB'), isTrue, reason: 'Glacier 요율 부분');
    });

    test('집계 권고와 전환 요청 비용이 있다', () {
      final t = doc('saa-t4-1');
      expect(t.contains('집계'), isTrue, reason: '작은 객체를 큰 객체로');
      expect(t.contains('전환 요청'), isTrue);
    });

    // 금지: 작은 객체도 수명 주기 전환이 이득이라는 서술.
    // 공식: "if you're storing many smaller sized objects, we don't
    //        recommend using lifecycle transitions."
    test('작은 객체도 전환이 이득이라고 적지 않는다', () {
      final t = body('saa-t4-1');
      expect(t.contains('작은 객체도 전환하면 이득'), isFalse);
      expect(t.contains('크기와 무관하게 전환'), isFalse);
    });
  });

  group('B9a-3 G-4.1-08 수명 주기 세부 (saa-t4-1)', () {
    test('기본 최소 전환 크기 동작이 있다', () {
      final t = doc('saa-t4-1');
      expect(t.contains('all_storage_classes_128K'), isTrue);
      expect(t.contains('ObjectSizeGreaterThan'), isTrue);
    });

    test('최소 스토리지 기간 3단이 있다', () {
      final t = doc('saa-t4-1');
      expect(t.contains('30일'), isTrue, reason: 'IA');
      expect(t.contains('90일'), isTrue, reason: 'Glacier FR·IR');
      expect(t.contains('180일'), isTrue, reason: 'Deep Archive');
    });

    test('버전 관리 비용 수단이 있다', () {
      final t = doc('saa-t4-1');
      expect(t.contains('NoncurrentVersionExpiration'), isTrue);
      expect(t.contains('NewerNoncurrentVersions'), isTrue);
    });

    // 금지: 128 KB 미만도 기본으로 전환된다는 서술.
    test('128 KB 미만이 기본 전환된다고 적지 않는다', () {
      final t = body('saa-t4-1');
      expect(t.contains('128 KB 미만도 기본으로 전환'), isFalse);
      expect(t.contains('크기 제한 없이 전환됩니다'), isFalse);
    });

    // 금지: 수명 주기로 상위 클래스로 되돌릴 수 있다는 서술(하향 전환만).
    test('수명 주기로 상향 전환이 된다고 적지 않는다', () {
      final t = body('saa-t4-1');
      expect(t.contains('상향 전환도 가능'), isFalse);
      expect(t.contains('Standard로 되돌리는 수명 주기'), isFalse);
    });
  });

  group('B9a-4 G-4.1-05 백업·아카이브 (saa-t4-1)', () {
    test('Snapshots Archive 제약이 있다', () {
      final t = doc('saa-t4-1');
      expect(t.contains('Archive'), isTrue);
      expect(t.contains('72시간'), isTrue, reason: '복원 소요');
      expect(t.contains('전체 스냅샷') || t.contains('full 스냅샷'), isTrue);
      expect(t.contains('Recycle Bin'), isTrue);
    });

    // 금지: 아카이브된 스냅샷으로 볼륨을 만들 수 있다는 서술.
    // 공식: "You can't use an archived snapshot in a block device mapping
    //        or to create an Amazon EBS volume."
    test('아카이브 스냅샷으로 볼륨을 만들 수 있다고 적지 않는다', () {
      final t = body('saa-t4-1');
      expect(t.contains('아카이브된 스냅샷으로 볼륨을 생성'), isFalse);
      expect(t.contains('아카이브 상태에서 바로 복원해 쓸 수 있'), isFalse);
    });

    // 금지: 절감률 수치 — 갭 노트의 "최대 75%" 는 확보하지 못했다.
    test('아카이브 절감률을 수치로 단정하지 않는다', () {
      final t = body('saa-t4-1');
      expect(t.contains('최대 75%'), isFalse);
      expect(t.contains('75% 절감'), isFalse);
    });
  });

  group('B9a-5 G-4.1-06 HDD/SSD 비용 선택 (saa-t4-1)', () {
    test('HDD 두 종과 성능 축이 있다', () {
      final t = doc('saa-t4-1');
      expect(t.contains('st1'), isTrue);
      expect(t.contains('sc1'), isTrue);
      expect(t.contains('순차'), isTrue, reason: '큰 순차 I/O 전제');
    });

    // 금지: sc1 을 부팅 볼륨으로 쓸 수 있다는 서술.
    // 공식: "Bootable sc1 volumes are not supported."
    test('sc1을 부팅 볼륨으로 쓸 수 있다고 적지 않는다', () {
      final t = body('saa-t4-1');
      expect(t.contains('sc1도 부팅 볼륨'), isFalse);
      expect(t.contains('sc1을 루트 볼륨으로'), isFalse);
    });

    // 금지: HDD 가 작고 랜덤한 I/O 에 적합하다는 서술.
    test('HDD가 랜덤 I/O에 적합하다고 적지 않는다', () {
      final t = body('saa-t4-1');
      expect(t.contains('HDD는 랜덤 I/O에 적합'), isFalse);
      expect(t.contains('작은 랜덤 I/O에도 HDD'), isFalse);
    });
  });

  group('B9a-6 G-4.1-07 FSx ONTAP 티어 (saa-t4-1)', () {
    test('두 티어와 티어링 정책이 있다', () {
      final t = doc('saa-t4-1');
      expect(t.contains('용량 풀'), isTrue);
      expect(t.contains('티어링 정책'), isTrue);
      expect(t.contains('씬 프로비저닝'), isTrue);
    });

    test('SSD 용량 변경 조건이 있다', () {
      final t = doc('saa-t4-1');
      expect(t.contains('2세대'), isTrue, reason: 'SSD 감소는 2세대부터');
    });

    // 금지: OpenZFS·Lustre 의 현행 스토리지 클래스를 단정하는 것.
    // 이번 조회로 확보하지 못했다(Intelligent-Tiering·HDD 여부 미확인).
    test('OpenZFS·Lustre 클래스를 단정하지 않는다', () {
      final t = body('saa-t4-1');
      expect(t.contains('Lustre Intelligent-Tiering'), isFalse);
      expect(t.contains('OpenZFS HDD 클래스'), isFalse);
    });
  });

  group('B9a-7 G-4.1-16 Storage Lens 고급 지표 (saa-t4-1)', () {
    test('무료·고급 티어의 보존과 과금이 있다', () {
      final t = doc('saa-t4-1');
      expect(t.contains('14일'), isTrue, reason: '무료 티어 쿼리 기간');
      expect(t.contains('15개월'), isTrue, reason: '고급 티어 쿼리 기간');
      expect(t.contains('추가 요금'), isTrue);
    });

    test('그룹 수준 제약이 있다', () {
      final t = doc('saa-t4-1');
      expect(t.contains('Storage Lens 그룹'), isTrue);
    });

    // 금지: 고급 지표가 무료라는 서술.
    test('고급 지표가 무료라고 적지 않는다', () {
      final t = body('saa-t4-1');
      expect(t.contains('고급 지표도 무료'), isFalse);
      expect(t.contains('추가 비용 없이 고급'), isFalse);
    });

    // 금지: Storage Lens 그룹에서도 고급 지표를 쓸 수 있다는 서술.
    test('그룹에서도 고급 지표가 된다고 적지 않는다', () {
      final t = body('saa-t4-1');
      expect(t.contains('그룹에서도 고급 지표'), isFalse);
      expect(t.contains('그룹 수준에서도 고급 티어'), isFalse);
    });
  });

  group('B9a-8 G-4.1-03 · G-4.1-09 크기 결정과 오토 스케일링 (saa-t4-1)', () {
    test('절과 앵커가 있다', () {
      expect(doc('saa-t4-1').contains('{#sizing-autoscaling}'), isTrue);
    });

    test('서비스별 크기 조정 가능 방향이 있다', () {
      final t = doc('saa-t4-1');
      expect(t.contains('줄일 수 없'), isTrue, reason: 'EBS 축소 불가');
      expect(t.contains('탄력'), isTrue, reason: 'S3·EFS 는 크기 지정 없음');
      expect(t.contains('증가만'), isTrue, reason: 'FSx Windows');
    });

    // 금지: EBS 볼륨 크기를 줄일 수 있다는 서술(B7a 에서 확인).
    test('EBS 크기를 줄일 수 있다고 적지 않는다', () {
      final t = body('saa-t4-1');
      expect(t.contains('EBS 크기를 줄일 수 있'), isFalse);
      expect(t.contains('볼륨 축소도 가능'), isFalse);
    });
  });

  group('B9a-9 G-4.1-10 스토리지 선택 매트릭스 (saa-t4-1)', () {
    test('절과 앵커가 있다', () {
      expect(doc('saa-t4-1').contains('{#storage-selection-matrix}'), isTrue);
    });

    test('요구 축과 비용 축이 함께 있다', () {
      final t = doc('saa-t4-1');
      expect(t.contains('프로토콜'), isTrue);
      expect(t.contains('공유'), isTrue);
      expect(t.contains('최소 기간') || t.contains('최소 스토리지 기간'), isTrue);
    });
  });

  group('B9a-10 G-02 규율 — 리전 의존 요율 금지 (saa-t4-1)', () {
    // 맵 §4 B9 가 못박은 규율이다. 비용 문서라 유혹이 크지만 리전마다 달라
    // 금방 낡고 틀린다 — **과금 축**만 적는다.
    test('GB당·요청당 구체 요율을 쓰지 않는다', () {
      final t = body('saa-t4-1');
      expect(t.contains('GB당 \$'), isFalse);
      expect(t.contains('GB당 0.0'), isFalse);
      expect(t.contains('1,000건당 \$'), isFalse);
      expect(t.contains('USD/GB'), isFalse);
    });
  });
}
