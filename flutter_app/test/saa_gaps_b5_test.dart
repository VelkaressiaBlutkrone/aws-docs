import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// SAA 갭 보강 배치 B5 — Task 2.1 잔여: 통합 서비스·SQS·Lambda·API Gateway·EKS (2026-10-21).
///
/// 배정 정본은 `docs/content-research/SAA-C03/97-gap-batch-map.md` §4 "B5".
/// 외부 조사 `98-existing-gap.md` 의 9행을 공식 문서로 확인해 처리했다.
///
/// ⚠️ `saa-t2-1` 은 `verified:true` 15/15 **라이브 문항 문서**다. md 추가가 기존 문항과
/// 어긋나면 라이브 결함이 되므로 문항 전수 대조를 거쳤다(PR 본문).
///
/// 가드 규율: **금지할 것만 고정하고 요구는 느슨하게**(핵심 키워드 수준).
/// 틀린 수치를 바로잡는 **경고 문구**가 그 문자열을 포함할 수 있으므로, 문자열 금지보다
/// 단정 금지를 쓴다(B3 교훈 — 맵 §4).
void main() {
  String doc(String id) =>
      File('assets/content/saa/$id.md').readAsStringSync();

  group('B5-1 G-2.1-02 통합 서비스 3종 (saa-t2-1)', () {
    test('Amazon MQ 가 엔진·표준 프로토콜과 함께 있다', () {
      final t21 = doc('saa-t2-1');
      expect(t21.contains('Amazon MQ'), isTrue);
      expect(t21.contains('ActiveMQ'), isTrue);
      expect(t21.contains('RabbitMQ'), isTrue);
      expect(t21.contains('JMS'), isTrue, reason: '표준 API로 코드 변경 최소화');
    });

    test('EventBridge Pipes 와 AppFlow 가 있다', () {
      final t21 = doc('saa-t2-1');
      expect(t21.contains('Pipes'), isTrue);
      expect(t21.contains('AppFlow'), isTrue);
    });

    // 금지: Pipes 를 팬아웃 수단으로 적는 것.
    // 공식: "A pipe routes events from a single source to a single target" —
    // 팬아웃·pub/sub 은 이벤트 버스와 규칙의 역할이고 Pipes 는 점대점이다.
    test('Pipes를 팬아웃·다중 타깃으로 쓰지 않는다', () {
      final t21 = doc('saa-t2-1');
      expect(t21.contains('Pipes로 팬아웃'), isFalse);
      expect(t21.contains('Pipes는 여러 타깃'), isFalse);
      expect(t21.contains('Pipes를 사용해 팬아웃'), isFalse);
    });

    test('공식 출처가 실려 있다', () {
      final t21 = doc('saa-t2-1');
      expect(t21.contains('pipes-concepts') || t21.contains('eb-pipes'), isTrue);
      expect(t21.contains('amazon-mq'), isTrue);
    });
  });

  group('B5-2 G-2.1-05 SQS 세부 사양 (saa-t2-1)', () {
    test('메시지 크기·지연 큐·in-flight·DLQ 정책이 있다', () {
      final t21 = doc('saa-t2-1');
      expect(t21.contains('1 MiB'), isTrue, reason: '현행 최대 메시지 크기');
      expect(t21.contains('900'), isTrue, reason: '지연 큐 최대 15분=900초');
      expect(t21.contains('120,000'), isTrue, reason: 'in-flight 한도');
      expect(t21.contains('maxReceiveCount'), isTrue, reason: 'DLQ 리드라이브');
    });

    // 금지: 256 KiB 를 **현행 상한**으로 적는 것. 2025-08 에 1 MiB 로 상향됐다.
    // 문자열 '256' 자체는 금지하지 않는다 — 구식 수치를 바로잡는 서술에 필요하다.
    test('256 KiB를 현행 상한으로 단정하지 않는다', () {
      final t21 = doc('saa-t2-1');
      expect(t21.contains('최대 256 KiB'), isFalse);
      expect(t21.contains('최대 256 KB'), isFalse);
      expect(t21.contains('메시지는 256 KiB까지'), isFalse);
    });

    // 금지: FIFO 고처리량 상한을 리전 무관 단일 수치로 적는 것.
    // 공식: 비배칭 TPS·배칭 msg/s 상한이 리전마다 다르다(최상위 70,000 / 2,400까지).
    test('고처리량 상한을 전 리전 공통으로 단정하지 않는다', () {
      final t21 = doc('saa-t2-1');
      expect(t21.contains('모든 리전에서 70,000'), isFalse);
      expect(t21.contains('고처리량 모드는 70,000'), isFalse);
      if (t21.contains('70,000')) {
        expect(t21.contains('리전'), isTrue,
            reason: '70,000은 특정 리전 상한이므로 리전 조건을 함께 적어야 한다');
      }
    });

    test('기존에 공식과 일치했던 300·3,000 서술이 유지된다', () {
      final t21 = doc('saa-t2-1');
      expect(t21.contains('300'), isTrue);
      expect(t21.contains('3,000'), isTrue);
    });
  });

  group('B5-3 G-2.1-03·G-2.1-09 선택 지도·상호 참조 (saa-t2-1)', () {
    test('DB·읽기 복제본은 담당 문서로 상호 참조한다', () {
      final t21 = doc('saa-t2-1');
      expect(t21.contains('saa-t3-5'), isTrue, reason: 'DB 성능 문서 참조');
      expect(t21.contains('읽기 전용 복제본'), isTrue);
    });

    // 금지: 읽기 복제본의 엔진별 상한을 이 문서에 복제하는 것.
    // 그 수치의 정본은 `saa-t3-5` 다(갭 노트 G-2.1-09 가 "`saa-t3-5` 로 이동"이라 적음).
    // 두 곳에 두면 한쪽만 갱신되는 드리프트가 생긴다.
    test('복제본 상한 수치를 이 문서에 복제하지 않는다', () {
      final t21 = doc('saa-t2-1');
      expect(t21.contains('최대 15개'), isFalse);
      expect(t21.contains('Oracle·SQL Server 5'), isFalse);
    });
  });

  group('B5-4 G-2.1-06·G-2.1-12 Lambda 한도·비동기 (saa-t2-2)', () {
    test('실행 환경·페이로드·이미지·임시 저장소 수치가 있다', () {
      final t22 = doc('saa-t2-2');
      expect(t22.contains('1,000'), isTrue, reason: '기본 동시 실행');
      expect(t22.contains('10초'), isTrue, reason: '함수당 확장 속도');
      expect(t22.contains('6 MB'), isTrue, reason: '동기 요청·응답');
      expect(t22.contains('10 GB'), isTrue, reason: '컨테이너 이미지');
      expect(t22.contains('512 MB'), isTrue, reason: '/tmp 기본값');
    });

    test('비동기 호출의 보관 기간과 대상 구분이 있다', () {
      final t22 = doc('saa-t2-2');
      expect(t22.contains('6시간'), isTrue);
      expect(t22.contains('Destination') || t22.contains('대상'), isTrue);
    });

    // 금지: 비동기 페이로드를 256 KB 로 적는 것(2025-10 에 1 MB 로 상향).
    test('비동기 페이로드를 256 KB로 단정하지 않는다', () {
      final t22 = doc('saa-t2-2');
      expect(t22.contains('비동기 256 KB'), isFalse);
      expect(t22.contains('비동기 호출은 256 KB'), isFalse);
    });

    // 금지: S3 를 성공 대상으로 적는 것.
    // 공식: "S3 buckets are supported only for on-failure destinations."
    test('S3를 성공 대상으로 쓸 수 있다고 쓰지 않는다', () {
      final t22 = doc('saa-t2-2');
      expect(t22.contains('S3를 성공 대상'), isFalse);
      expect(t22.contains('성공 대상으로 S3'), isFalse);
    });
  });

  group('B5-5 G-2.1-07 API Gateway 수치·유형 (saa-t2-2)', () {
    test('계정 스로틀과 통합 타임아웃이 있다', () {
      final t22 = doc('saa-t2-2');
      expect(t22.contains('10,000'), isTrue, reason: '계정·리전당 RPS');
      expect(t22.contains('29'), isTrue, reason: '통합 타임아웃 29초');
    });

    test('엔드포인트 유형 3종이 있다', () {
      final t22 = doc('saa-t2-2');
      expect(t22.contains('Regional'), isTrue);
      expect(t22.contains('프라이빗'), isTrue);
      expect(
        t22.contains('엣지 최적화') || t22.contains('Edge-optimized'),
        isTrue,
      );
    });

    // 금지: 29초 증액이 모든 API 유형에서 된다고 적는 것.
    // 공식: "only supported for Regional and private REST APIs".
    test('29초 증액을 전 API 유형에서 가능하다고 쓰지 않는다', () {
      final t22 = doc('saa-t2-2');
      expect(t22.contains('모든 API에서 29초'), isFalse);
      expect(t22.contains('어떤 API든 29초 이상'), isFalse);
    });
  });

  group('B5-6 G-2.1-08 EKS 버전 지원·과금 구조 (saa-t2-2)', () {
    test('표준·연장 지원 기간이 있다', () {
      final t22 = doc('saa-t2-2');
      expect(t22.contains('14개월'), isTrue);
      expect(t22.contains('12개월'), isTrue);
      expect(t22.contains('26개월'), isTrue);
    });

    // 금지: 리전 의존 요율을 본문에 적는 것(`99-gaps` G-02 규율). 과금 축만 적는다.
    test('시간당 요율을 적지 않는다', () {
      final t22 = doc('saa-t2-2');
      expect(t22.contains(r'$0.10'), isFalse);
      expect(t22.contains(r'$0.60'), isFalse);
    });

    // 금지: 연장 지원이 기본 비활성이라는 서술.
    // 공식: "By default, for all new and existing clusters, the upgrade policy is
    //        set to EXTENDED, unless specified otherwise."
    test('연장 지원이 기본 비활성이라고 쓰지 않는다', () {
      final t22 = doc('saa-t2-2');
      expect(t22.contains('연장 지원은 기본적으로 비활성'), isFalse);
      expect(t22.contains('연장 지원을 켜야'), isFalse);
    });
  });

  group('B5-7 G-2.1-01 컨테이너 이전 경로 (saa-t2-2)', () {
    test('App2Container 와 현재 제공 상태·대안이 있다', () {
      final t22 = doc('saa-t2-2');
      expect(t22.contains('App2Container'), isTrue);
      expect(t22.contains('신규'), isTrue, reason: '신규 고객 불가 상태');
      expect(t22.contains('AWS Transform'), isTrue, reason: '공식이 제시한 대안');
    });

    // 금지: 지금 새로 가입해 쓸 수 있다는 서술.
    // 공식: "no longer open to new customers ... sign up prior to November 7, 2025".
    test('App2Container를 신규 가입 가능으로 쓰지 않는다', () {
      final t22 = doc('saa-t2-2');
      expect(t22.contains('App2Container를 새로 신청'), isFalse);
      expect(t22.contains('App2Container는 누구나'), isFalse);
    });

    // 금지: 시험 범위에 든다고 단정하는 것.
    // 공식 in-scope·out-of-scope 목록 어디에도 없다(`00-overview.md` §서비스 범위) —
    // Cloud WAN(V-72)과 같은 계열이라 범위 판정 자체가 불확실하다.
    test('App2Container가 시험 범위라고 단정하지 않는다', () {
      final t22 = doc('saa-t2-2');
      expect(t22.contains('App2Container는 시험 범위'), isFalse);
      expect(t22.contains('App2Container도 출제'), isFalse);
    });
  });
}
