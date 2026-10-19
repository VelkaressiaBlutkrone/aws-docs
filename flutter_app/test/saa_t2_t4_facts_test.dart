import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// SAA Task 2.1~4.4 학습문서의 사실 정정 가드 (2026-10-19).
///
/// 외부 조사(docs/content-research/SAA-C03/98-existing-gap.md)가 올린 항목 중
/// `[오류]`·`[구식]`·`[부정확]`만 공식 문서로 재확인한 뒤 정정했다. 재확인 과정에서
/// 근거 문장을 찾지 못한 하위 주장은 쓰지 않았다(PR 본문에 그대로 기록).
void main() {
  String doc(String id) =>
      File('assets/content/saa/$id.md').readAsStringSync();

  group('Task 2.1 — saa-t2-1 / saa-t2-2', () {
    test('G-2.1-10 SNS 재시도: AWS 관리형 엔드포인트 100,015회·23일', () {
      // 근거: sns-dead-letter-queues — "For server-side errors caused by AWS
      // managed endpoints backed by Amazon SQS or AWS Lambda, Amazon SNS
      // retries delivery up to 100,015 times, over 23 days."
      final t21 = doc('saa-t2-1');
      expect(t21.contains('제한된 횟수만 재시도하고 이후 메시지를 버립니다'), isFalse);
      expect(t21.contains('100,015'), isTrue);
      expect(t21.contains('23일'), isTrue);
    });

    test('G-2.1-10 SNS DLQ는 구독 단위로 붙는다', () {
      // 근거: 같은 페이지 — "A dead-letter queue is attached to an Amazon SNS
      // subscription (rather than a topic)"
      final t21 = doc('saa-t2-1');
      expect(t21.contains('구독 단위'), isTrue);
      expect(t21.contains('SNS는 Push 후 재시도가 제한적입니다'), isFalse);
    });

    test('G-2.1-10 팬아웃에 SQS를 끼우는 이유가 버퍼링·독립 속도로 서술된다', () {
      final t21 = doc('saa-t2-1');
      expect(t21.contains('버퍼링'), isTrue);
      expect(t21.contains('재처리'), isTrue);
    });

    test('G-2.1-11 Durable functions는 Lambda의 기능군이다', () {
      // 근거: Lambda quotas — "Durable functions" 절이 Lambda 쿼터 페이지에 있고,
      // "up to 90 minutes for Lambda Managed Instances functions invoked
      // asynchronously or through any event source mapping"
      final t22 = doc('saa-t2-2');
      expect(t22.contains('Step Functions(Durable Lambda)'), isFalse);
      expect(t22.contains('Durable functions'), isTrue);
      expect(t22.contains('90분'), isTrue);
      expect(t22.contains('Managed Instances'), isTrue);
    });

    test('G-2.1-12 비동기 호출: 이벤트 큐 6시간·Destinations 성공/실패 분리', () {
      // 근거: PutFunctionEventInvokeConfig — "It retains events in a queue for
      // up to six hours", MaximumEventAgeInSeconds 60~21600,
      // "S3 buckets are supported only for on-failure destinations"
      final t22 = doc('saa-t2-2');
      expect(t22.contains('6시간'), isTrue);
      expect(t22.contains('S3는 실패'), isTrue);
    });
  });

  group('Task 2.2 — saa-t2-3 / saa-t2-5', () {
    test('G-2.2-13 CLB는 EC2-Classic 전용이 아니라 이전 세대 LB다', () {
      // 근거: Classic Load Balancer 소개 — "Classic Load Balancers are the
      // previous generation of load balancers... We recommend that you migrate
      // to a current generation load balancer."
      final t23 = doc('saa-t2-3');
      expect(t23.contains('기존 EC2-Classic 환경만'), isFalse);
      expect(t23.contains('이전 세대'), isTrue);
    });

    test('G-2.2-14 NLB의 근거 없는 "< 1ms" 수치가 사라졌다', () {
      // 근거: NLB 소개 — "It can handle millions of requests per second."
      // 밀리초 수치는 공식 문서에 없다.
      final t23 = doc('saa-t2-3');
      expect(t23.contains('< 1ms'), isFalse);
    });

    test('G-2.2-14 GWLB는 L3(네트워크 계층)이다', () {
      // 근거: GWLB 소개 — "operates at the third layer of the Open Systems
      // Interconnection (OSI) model, the network layer. It listens for all IP
      // packets across all ports"
      final t23 = doc('saa-t2-3');
      expect(t23.contains('| **GWLB** (Gateway LB) | L3/4 |'), isFalse);
      expect(t23.contains('모든 IP 패킷'), isTrue);
    });

    test('G-2.2-15 DynamoDB 글로벌 테이블 일관성 모드 2종(MREC·MRSC)', () {
      // 근거: GlobalTables — "Global tables support two consistency modes:
      // multi-Region eventual consistency (MREC) and multi-Region strong
      // consistency (MRSC)... You cannot change a global table's consistency
      // mode after creation."
      final t25 = doc('saa-t2-5');
      expect(t25.contains('멀티 리전 읽기·쓰기, 최종 일관성 |'), isFalse);
      expect(t25.contains('MREC'), isTrue);
      expect(t25.contains('MRSC'), isTrue);
    });
  });

  group('정정 날짜·출처 (Task 2.x)', () {
    test('정정한 문서의 lastVerified가 2026-10-19로 갱신됐다', () {
      for (final id in ['saa-t2-1', 'saa-t2-2', 'saa-t2-3', 'saa-t2-5']) {
        expect(doc(id).contains('lastVerified: 2026-10-19'), isTrue,
            reason: '$id lastVerified 누락');
      }
    });

    test('새로 인용한 공식 출처가 실려 있다', () {
      expect(doc('saa-t2-1').contains('sns-dead-letter-queues'), isTrue);
      expect(doc('saa-t2-2').contains('PutFunctionEventInvokeConfig'), isTrue);
      expect(doc('saa-t2-3').contains('elasticloadbalancing/latest/gateway'),
          isTrue);
      expect(doc('saa-t2-5').contains('GlobalTables'), isTrue);
    });
  });

  group('Task 3.1 — saa-t3-1 / saa-t3-2', () {
    test('G-3.1-09 S3 단일 객체 최대 크기는 멀티파트로 50 TB', () {
      // 근거: upload-objects — "With a single PUT operation, you can upload a
      // single object up to 5 GB in size" / "you can upload a single large
      // object, up to 50 TB in size"
      final t31 = doc('saa-t3-1');
      expect(t31.contains('단일 객체 최대 5TB'), isFalse);
      expect(t31.contains('50 TB'), isTrue);
    });

    test('G-3.1-10 멀티파트 필수 기준은 5 GB 초과(이상이 아니다)', () {
      final t31 = doc('saa-t3-1');
      expect(t31.contains('5 GB 이상 필수'), isFalse);
      expect(t31.contains('5 GB 초과'), isTrue);
    });

    test('G-3.1-11 EFS Max I/O는 이전 세대 성능 모드다', () {
      // 근거: efs performance — "Max I/O mode is a previous generation
      // performance type... not supported for One Zone file systems or file
      // systems that use Elastic throughput... we recommend using General
      // Purpose performance mode for all file systems."
      final t32 = doc('saa-t3-2');
      expect(t32.contains('수천 인스턴스가 동시 접근하는 빅데이터 분석'), isFalse);
      expect(t32.contains('이전 세대'), isTrue);
      expect(t32.contains('Elastic 처리량'), isTrue);
    });

    test('G-3.1-13 FSx for Lustre 성능은 스토리지 클래스별로 다르다', () {
      // 근거: fsx lustre what-is — SSD "consistent sub-millisecond latency
      // access to your full dataset", Intelligent-Tiering "sub-millisecond
      // latency access to frequently-accessed data", HDD "consistent
      // single-digit ms latency and up to tens of GBps"
      final t32 = doc('saa-t3-2');
      expect(t32.contains('| **성능** | 서브밀리초 지연시간, 수 TBps 처리량, 수백만 IOPS |'),
          isFalse);
      expect(t32.contains('한 자릿수 ms'), isTrue);
      expect(t32.contains('자주 접근하는 데이터'), isTrue);
    });
  });

  group('Task 3.2 — saa-t3-3 / saa-t3-4', () {
    test('G-3.2-10 프로세서 접미사: i=Intel', () {
      // 근거: instance-type-names — "i – Intel processors"
      final t33 = doc('saa-t3-3');
      expect(t33.contains('없음=Intel'), isFalse);
      expect(t33.contains('| Intel (Xeon) | 없음 |'), isFalse);
      expect(t33.contains('i=Intel'), isTrue);
    });

    test('G-3.2-11 기능 접미사: b=블록 스토리지 최적화, n=네트워크·EBS 최적화', () {
      // 근거: instance-type-names — "b – Block storage optimization",
      // "n – Network and EBS optimized", 그 밖에 d·e·z·flex
      final t33 = doc('saa-t3-3');
      expect(t33.contains('n=네트워크 강화, b=EBS 최적화'), isFalse);
      expect(t33.contains('블록 스토리지 최적화'), isTrue);
      expect(t33.contains('네트워크·EBS 최적화'), isTrue);
    });

    test('G-3.2-15 Lambda 메모리는 "유일한" 손잡이가 아니라 주된 손잡이다', () {
      // 근거: configuration-memory — "Memory is the principal lever for
      // controlling the performance of a function." + Lambda Power Tuning
      final t34 = doc('saa-t3-4');
      expect(t34.contains('성능 튜닝의 유일한 손잡이'), isFalse);
      expect(t34.contains('유일한 해결 경로'), isFalse);
      expect(t34.contains('주된'), isTrue);
      expect(t34.contains('Power Tuning'), isTrue);
    });
  });

  group('정정 날짜·출처 (Task 3.1·3.2)', () {
    test('정정한 문서의 lastVerified가 2026-10-19로 갱신됐다', () {
      for (final id in ['saa-t3-1', 'saa-t3-2', 'saa-t3-3', 'saa-t3-4']) {
        expect(doc(id).contains('lastVerified: 2026-10-19'), isTrue,
            reason: '$id lastVerified 누락');
      }
    });

    test('새로 인용한 공식 출처가 실려 있다', () {
      expect(doc('saa-t3-1').contains('upload-objects'), isTrue);
      expect(doc('saa-t3-2').contains('efs/latest/ug/performance'), isTrue);
      expect(doc('saa-t3-2').contains('LustreGuide/what-is'), isTrue);
      expect(doc('saa-t3-3').contains('instance-type-names'), isTrue);
      expect(doc('saa-t3-4').contains('configuration-memory'), isTrue);
    });
  });
}
