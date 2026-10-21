import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// SAA 갭 보강 배치 B7a — Task 3.1 잔여: 스토리지 성능 수치 (2026-10-21).
///
/// 배정 정본은 `docs/content-research/SAA-C03/97-gap-batch-map.md` §4 "B7".
/// B7 18행 중 **Task 3.1 잔여 8행**만 담는다(3.2 는 B7b, `G-3.2-03` 은 저작 대상이
/// `saa-t2-3` 이고 미머지 #177 과 같은 파일이라 제외).
///
/// ⚠️ `saa-t3-2` 는 `verified:true` 15/15 **라이브 문항 문서**다.
/// ⚠️ `saa-t3-1` 은 서브섹션 6·원리 6 이라 절을 늘리면 `content_enrichment_test` 의
///    하한(min(서브섹션,8))이 깨진다 — 그래서 t3-1 은 **제자리 보강만** 했다.
void main() {
  String doc(String id) =>
      File('assets/content/saa/$id.md').readAsStringSync();

  /// 출처·보강 노트 구간을 제외한 **본문**만 본다(B6 교훈 — 맵 §4).
  /// 보강 노트는 "쓰지 않은 것"을 적으며 그 수치를 인용하므로, 본문 금지와 같은
  /// 자를 대면 올바른 기록이 걸린다.
  String body(String id) {
    final t = doc(id);
    final i = t.indexOf('### 📌 출처');
    return i < 0 ? t : t.substring(0, i);
  }

  group('B7a-1 G-3.1-05 S3 Express One Zone (saa-t3-1)', () {
    test('디렉터리 버킷과 요청률·가용성이 있다', () {
      final t = doc('saa-t3-1');
      expect(t.contains('디렉터리 버킷'), isTrue);
      expect(t.contains('2,000,000'), isTrue, reason: 'GET TPS 상한');
      expect(t.contains('99.95'), isTrue, reason: '단일 AZ 가용성 설계');
      expect(t.contains('한 자릿수'), isTrue, reason: '한 자릿수 ms 지연');
    });

    // 갭 노트가 적은 "SLA 99.9%"는 공식과 다르다 — 공식은 "단일 AZ 내 99.95%
    // 가용성 설계"이고 S3 SLA 가 적용된다는 서술이다.
    test('가용성을 SLA 99.9%로 적지 않는다', () {
      final t = body('saa-t3-1');
      expect(t.contains('SLA 99.9%'), isFalse);
      expect(t.contains('SLA는 99.9'), isFalse);
    });

    // `99-gaps` C-03 — 요청 비용 절감률이 공식 자료 간 상충(80% vs 50%)이다.
    // 한쪽만 단정하지 말고 병기한다.
    test('요청 비용 절감률을 한쪽으로 단정하지 않는다', () {
      final t = body('saa-t3-1');
      if (t.contains('80%')) {
        expect(t.contains('50%'), isTrue,
            reason: 'C-03 상충이므로 두 수치를 병기해야 한다');
      }
    });

    test('공식 출처가 실려 있다', () {
      expect(doc('saa-t3-1').contains('directory-bucket-high-performance'), isTrue);
    });
  });

  group('B7a-2 G-3.1-06 S3 성능 세부 (saa-t3-1)', () {
    test('요청률 동작과 병렬화·스케일링이 있다', () {
      final t = doc('saa-t3-1');
      expect(t.contains('PUT/COPY/POST/DELETE'), isTrue);
      expect(t.contains('55,000'), isTrue, reason: '프리픽스 10개 병렬화 예');
      expect(t.contains('503'), isTrue, reason: '스케일링 중 Slow Down');
    });

    // 금지: 쓰기 계열을 PUT/DELETE 로만 적는 것. 공식은 COPY·POST 도 포함한다.
    // ⚠️ `PUT/DELETE` 문자열 자체를 금지하면 안 된다 — §1 의 강력한 일관성 서술
    // ("PUT/DELETE 요청 직후 GET 이 최신 데이터를 반환")은 **옳은 문장**이고
    // 요청률과 무관하다. 결함은 요청률 수치에 붙은 표기였으므로 그 형태만 막는다.
    test('요청률 문장에서 쓰기 계열을 PUT/DELETE로만 적지 않는다', () {
      final t = body('saa-t3-1');
      expect(t.contains('3,500 PUT/DELETE'), isFalse);
      expect(t.contains('3,500 **PUT/DELETE**'), isFalse);
    });

    // 금지: 성능을 위해 키 이름을 무작위화해야 한다는 서술.
    // 공식: "이 지침이 이전 지침을 대체한다 — 더 이상 해시 문자로 프리픽스
    //        이름을 무작위화할 필요가 없다."
    // ⚠️ 문구 자체를 금지하면 **그것을 바로잡는 경고**가 걸린다(이 세션에서 네
    // 번째 재발). 그래서 금지가 아니라 **교정 문맥을 요구**한다 — 무작위화를
    // 언급하면 "옛 지침"이라는 교정이 같은 문서에 있어야 한다.
    test('키 무작위화를 현행 권고로 적지 않는다', () {
      final t = body('saa-t3-1');
      if (t.contains('무작위화')) {
        expect(t.contains('옛 지침'), isTrue,
            reason: '공식은 더 이상 키 이름 무작위화를 성능 권고로 두지 않는다');
      }
    });
  });

  group('B7a-3 G-3.1-02 EBS 성능 결정 조건 (saa-t3-2)', () {
    test('gp3·io2 상한과 비율이 있다', () {
      final t = doc('saa-t3-2');
      expect(t.contains('80,000'), isTrue, reason: 'gp3 최대 IOPS');
      expect(t.contains('2,000 MiB/s'), isTrue, reason: 'gp3 최대 처리량');
      expect(t.contains('256,000'), isTrue, reason: 'io2 Block Express 최대 IOPS');
      expect(t.contains('16 KiB'), isTrue, reason: 'IOPS 기준 I/O 크기');
    });

    test('EBS 최적화 인스턴스와 인스턴스 측 한계가 있다', () {
      final t = doc('saa-t3-2');
      expect(t.contains('EBS 최적화'), isTrue);
      expect(t.contains('32,000'), isTrue, reason: 'Nitro 외 달성 상한');
    });

    // io2 의 256,000 은 **Nitro 기반 인스턴스에서만** 달성된다.
    test('256,000 IOPS를 인스턴스 종류와 무관하게 적지 않는다', () {
      final t = body('saa-t3-2');
      if (t.contains('256,000')) {
        expect(t.contains('Nitro'), isTrue,
            reason: '256,000 은 Nitro 기반에서만 달성된다');
      }
    });

    // 금지: gp3 가 버스트 모델이라는 **단정**(공식: gp3 는 버스트를 쓰지 않는다).
    //
    // ⚠️ `gp3는 버스트` 로 금지하면 안 된다 — "gp3는 버스트 구조 자체가 **없고**"
    // 처럼 부정어가 뒤에 오는 **옳은 문장**이 걸린다(실제로 `saa-t4-1-q7` 이 그렇게
    // 적고 있다). 이 세션에서 다섯 번째 재발이므로 단정 형태만 집는다.
    test('gp3가 버스트 크레딧 방식이라고 적지 않는다', () {
      final t = body('saa-t3-2');
      expect(t.contains('gp3는 버스트 크레딧'), isFalse);
      expect(t.contains('gp2/gp3)는 버스트'), isFalse);
      expect(t.contains('gp3도 버스트 크레딧'), isFalse);
    });
  });

  group('B7a-4 G-3.1-03 Elastic Volumes (saa-t3-2)', () {
    test('운영 중 변경·축소 불가·횟수 제약이 있다', () {
      final t = doc('saa-t3-2');
      expect(t.contains('Elastic Volumes'), isTrue);
      expect(t.contains('24시간'), isTrue, reason: '롤링 24시간 제약');
      expect(t.contains('4회'), isTrue);
      expect(t.contains('축소'), isTrue, reason: '크기 축소 불가');
    });

    // 금지: 볼륨 크기를 줄일 수 있다는 서술.
    test('볼륨 크기를 줄일 수 있다고 쓰지 않는다', () {
      final t = body('saa-t3-2');
      expect(t.contains('크기를 줄일 수 있'), isFalse);
      expect(t.contains('축소도 가능'), isFalse);
    });
  });

  group('B7a-5 G-3.1-04 EFS 처리량 모드 (saa-t3-2)', () {
    test('세 모드와 선택 기준이 있다', () {
      final t = doc('saa-t3-2');
      expect(t.contains('Elastic'), isTrue);
      expect(t.contains('Provisioned'), isTrue);
      expect(t.contains('Bursting'), isTrue);
      expect(t.contains('5%'), isTrue, reason: '평균/피크 비율 기준');
      expect(t.contains('12시간'), isTrue, reason: 'Bursting 하루 버스트 한도');
    });

    // 금지: EFS IA 절감률 단정 — `99-gaps` C-02 상충(최대 95% vs 92%).
    test('EFS IA 절감률을 단정하지 않는다', () {
      final t = body('saa-t3-2');
      expect(t.contains('최대 95%'), isFalse);
      expect(t.contains('최대 92%'), isFalse);
    });
  });

  group('B7a-6 G-3.1-07 FSx 보조 특성 (saa-t3-2)', () {
    test('Lustre DRA 와 OpenZFS 변경 불가가 있다', () {
      final t = doc('saa-t3-2');
      expect(t.contains('데이터 리포지토리') || t.contains('DRA'), isTrue);
      expect(t.contains('배포 유형'), isTrue);
    });

    // 금지: S3 에 링크된 Lustre 파일 시스템도 백업된다는 서술.
    // 공식: 백업은 S3 데이터 리포지토리에 **링크되지 않은** persistent 파일
    //       시스템에서만 지원된다.
    test('링크된 Lustre 파일 시스템도 백업된다고 쓰지 않는다', () {
      final t = body('saa-t3-2');
      expect(t.contains('링크된 파일 시스템도 백업'), isFalse);
      expect(t.contains('S3 링크와 무관하게 백업'), isFalse);
    });

    // 금지: OpenZFS 배포 유형·스토리지 클래스를 생성 후 바꿀 수 있다는 서술.
    test('OpenZFS 배포 유형을 나중에 바꿀 수 있다고 쓰지 않는다', () {
      final t = body('saa-t3-2');
      expect(t.contains('배포 유형을 나중에 변경'), isFalse);
      expect(t.contains('스토리지 클래스를 변경할 수 있'), isFalse);
    });
  });

  group('B7a-7 G-3.1-08 Multi-Attach (saa-t3-2)', () {
    test('인스턴스 수 상한과 펜싱 수단이 있다', () {
      final t = doc('saa-t3-2');
      expect(t.contains('16개'), isTrue, reason: '최대 16개 Nitro 인스턴스');
      expect(t.contains('NVMe 예약'), isTrue);
    });

    // 금지: Multi-Attach 가 표준 파일 시스템을 지원한다는 서술.
    test('Multi-Attach가 표준 파일 시스템을 지원한다고 쓰지 않는다', () {
      final t = body('saa-t3-2');
      expect(t.contains('표준 파일 시스템도 지원'), isFalse);
      expect(t.contains('ext4를 그대로 공유'), isFalse);
    });
  });

  group('B7a-8 G-3.1-14 인스턴스 스토어 소실 조건 (saa-t3-2)', () {
    test('공식 표의 소실 조건이 모두 있다', () {
      final t = doc('saa-t3-2');
      expect(t.contains('최대 절전'), isTrue);
      expect(t.contains('인스턴스 유형 변경') || t.contains('유형을 변경'), isTrue);
      expect(t.contains('은퇴'), isTrue);
      expect(t.contains('소거') || t.contains('암호학적'), isTrue);
    });

    // 금지: 재부팅에도 데이터가 사라진다는 서술(공식: 재부팅은 유지).
    test('재부팅에도 소실된다고 쓰지 않는다', () {
      final t = body('saa-t3-2');
      expect(t.contains('재부팅하면 데이터가 사라'), isFalse);
      expect(t.contains('재부팅 시 소실'), isFalse);
    });
  });
}
