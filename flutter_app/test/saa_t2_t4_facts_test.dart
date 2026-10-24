import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// SAA Task 2.1~4.4 학습문서의 사실 정정 가드 (2026-10-19).
///
/// 외부 조사(docs/content-research/SAA-C03/98-existing-gap.md)가 올린 항목 중
/// `[오류]`·`[구식]`·`[부정확]`만 공식 문서로 재확인한 뒤 정정했다. 재확인 과정에서
/// 근거 문장을 찾지 못한 하위 주장은 쓰지 않았다(PR 본문에 그대로 기록).
/// `lastVerified` 는 되돌아가는 것만 막고 갱신은 허용한다. 날짜를 리터럴로 못박으면
/// 다음 재검수·보강이 본래 검사하려던 사실 대신 이 단정을 먼저 터뜨린다
/// (2026-10-20 교훈 — 선례 `saa_t12_t13_facts_test.dart`).
void expectLastVerifiedAtLeast(String body, String floor, String id) {
  final stamp =
      RegExp(r'lastVerified: (\d{4}-\d{2}-\d{2})').firstMatch(body)?.group(1);
  expect(stamp, isNotNull, reason: '$id lastVerified 항목이 없다');
  expect(stamp!.compareTo(floor) >= 0, isTrue,
      reason: '$id lastVerified 가 $floor 이전으로 되돌아갔다: $stamp');
}

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
    test('정정한 문서의 lastVerified가 2026-10-19 이후다', () {
      for (final id in ['saa-t2-1', 'saa-t2-2', 'saa-t2-3', 'saa-t2-5']) {
        expectLastVerifiedAtLeast(doc(id), '2026-10-19', id);
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
    test('정정한 문서의 lastVerified가 2026-10-19 이후다', () {
      // 2026-10-20: 날짜를 리터럴로 못박으면 다음 재검수·보강이 이 테스트를 먼저
      // 터뜨린다(선례 saa_t12_t13_facts_test). 되돌아가는 것만 막고 갱신은 허용한다.
      for (final id in ['saa-t3-1', 'saa-t3-2', 'saa-t3-3', 'saa-t3-4']) {
        expectLastVerifiedAtLeast(doc(id), '2026-10-19', id);
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

  group('Task 3.3 — saa-t3-5 / saa-t3-6', () {
    test('G-3.3-10 gp3는 버스트 모델이 아니다', () {
      // 근거: general-purpose — "gp3 volumes do not use burst performance.
      // They can indefinitely sustain their full provisioned IOPS and
      // throughput performance." 버스트는 gp2(3 IOPS/GiB, 1 TiB 미만)만 해당.
      final t35 = doc('saa-t3-5');
      expect(t35.contains('범용 SSD(gp2/gp3)는 버스트 크레딧 방식'), isFalse);
      expect(t35.contains('gp3는 버스트'), isTrue);
      expect(t35.contains('3,000 IOPS'), isTrue);
    });

    test('G-3.3-13 Aurora serverless 명칭(v2 표기 제거)', () {
      // 근거: AuroraUserGuide/aurora-serverless-v2.html 제목·본문이
      // "Aurora serverless"로 바뀌었다("Using Aurora serverless").
      for (final id in ['saa-t3-5', 'saa-t4-3']) {
        expect(doc(id).contains('Aurora Serverless v2'), isFalse,
            reason: '$id 에 구식 명칭 잔존');
        expect(doc(id).contains('Aurora serverless'), isTrue);
      }
    });

    test('G-3.3-11 DynamoDB TTL 삭제는 만료 후 수일 내(최선 노력)', () {
      // 근거: TTL — "DynamoDB automatically deletes expired items within a few
      // days of their expiration time, without consuming write throughput."
      final t36 = doc('saa-t3-6');
      expect(t36.contains('48시간 이내'), isFalse);
      expect(t36.contains('수일'), isTrue);
    });

    test('G-3.3-12 ElastiCache 엔진은 Valkey·Memcached·Redis OSS 3종', () {
      // 근거: SelectEngine — "Amazon ElastiCache supports the Valkey,
      // Memcached, and Redis OSS cache engines."
      final t36 = doc('saa-t3-6');
      expect(t36.contains('두 가지 엔진 지원'), isFalse);
      expect(t36.contains('Valkey'), isTrue);
      expect(t36.contains('Redis OSS'), isTrue);
    });

    test('G-3.3-15 DynamoDB 처리량은 무제한이 아니라 파티션 한도가 있다', () {
      // 근거: bp-partition-key-design — "Every partition in a DynamoDB table is
      // designed to deliver a maximum capacity of 3,000 read units per second
      // and 1,000 write units per second."
      final t36 = doc('saa-t3-6');
      expect(t36.contains('수평 확장, 무제한 처리량'), isFalse);
      expect(t36.contains('파티션당'), isTrue);
    });
  });

  group('Task 3.4 — saa-t3-7 / saa-t3-8', () {
    test('G-3.4-10 Global Accelerator 엔드포인트에 CloudFront는 없다', () {
      // 근거: about-endpoints — "Endpoints for standard accelerators in AWS
      // Global Accelerator can be Network Load Balancers, Application Load
      // Balancers, Amazon EC2 instances, or Elastic IP addresses."
      final t37 = doc('saa-t3-7');
      expect(t37.contains('CloudFront 앞에 Global Accelerator'), isFalse);
      expect(t37.contains('**Global Accelerator** + CloudFront 조합'), isFalse);
      expect(t37.contains('Elastic IP 주소'), isTrue);
    });

    test('G-3.4-11 GWLB는 L3, ALB 프로토콜에 gRPC 포함', () {
      final t37 = doc('saa-t3-7');
      expect(t37.contains('| **GLB** (Gateway LB) | L3/L4 |'), isFalse);
      expect(t37.contains('gRPC'), isTrue);
    });

    test('G-3.4-13 Direct Connect SLA는 가용성 약정이다', () {
      // 근거: Direct Connect SLA — 다중 사이트 중복 99.99%, 비중복 99.9%,
      // 단일 연결 95.0%. 대역폭·지연 약정은 없다.
      final t38 = doc('saa-t3-8');
      expect(t38.contains('일관됨 (SLA 보장)'), isFalse);
      expect(t38.contains('가용성 SLA'), isTrue);
      expect(t38.contains('99.99%'), isTrue);
    });
  });

  group('Task 3.5 — saa-t3-9', () {
    test('G-3.5-09 Snow Family는 신규 주문 불가', () {
      // 근거: snowball-edge-availability-change — "AWS Snowball Edge is no
      // longer available to new customers... AWS will no longer offer any AWS
      // Snow Family devices for new customers to order." 대안은 DataSync·
      // AWS Data Transfer Terminal·파트너, 엣지 컴퓨팅은 Outposts.
      final t39 = doc('saa-t3-9');
      expect(t39.contains('Snowball Edge는 엣지 컴퓨팅도 가능합니다'), isFalse);
      expect(t39.contains('신규 고객'), isTrue);
      expect(t39.contains('Data Transfer Terminal'), isTrue);
      expect(t39.contains('Outposts'), isTrue);
    });

    test('G-3.5-10 KDS 온디맨드 모드는 샤드를 자동 관리한다', () {
      // 근거: how-do-i-size-a-stream — "With the on-demand mode, Kinesis Data
      // Streams automatically manages the shards"; 이전 30일 피크의 2배 수용.
      final t39 = doc('saa-t3-9');
      expect(t39.contains('샤드 수는 자동으로 증가하지 않습니다'), isFalse);
      expect(t39.contains('온디맨드'), isTrue);
      expect(t39.contains('30일'), isTrue);
    });

    test('G-3.5-11 기본 소비자는 샤드당 2 MB/s를 공유, 전용 처리량은 EFO', () {
      // 근거: service-sizes-and-limits — "Each shard can support up to a
      // maximum total data read rate of 2 MB per second via GetRecords."
      final t39 = doc('saa-t3-9');
      expect(t39.contains('**여러 컨슈머가 동시에 독립적으로** 읽을 수 있습니다'), isFalse);
      expect(t39.contains('EFO'), isTrue);
      expect(t39.contains('공유'), isTrue);
    });

    test('G-3.5-12 Lake Formation 지원 범위는 엔진별로 다르다', () {
      // 근거: working-with-services — Hive on EMR은 행/셀 미지원, Athena Spark·
      // EMR on EKS 미지원, Glue ETL 열/행 읽기는 Glue 5.0 이상.
      final t39 = doc('saa-t3-9');
      expect(
          t39.contains('Athena, EMR(Apache Spark), Redshift Spectrum, Glue ETL 전반에 Lake Formation 권한이 일관되게 적용됩니다'),
          isFalse);
      expect(t39.contains('Glue 5.0'), isTrue);
      expect(t39.contains('Hive'), isTrue);
    });

    test('G-3.5-15 Managed Flink 지원 언어에 Python 포함', () {
      // 근거: managed-flink what-is — "you can use Java, Scala, Python, or SQL"
      final t39 = doc('saa-t3-9');
      expect(t39.contains('**Java·Scala·SQL**'), isFalse);
      expect(t39.contains('Python'), isTrue);
    });
  });

  group('정정 날짜·출처 (Task 3.3~3.5)', () {
    test('정정한 문서의 lastVerified가 2026-10-19 이후다', () {
      for (final id in [
        'saa-t3-5',
        'saa-t3-6',
        'saa-t3-7',
        'saa-t3-8',
        'saa-t3-9'
      ]) {
        expectLastVerifiedAtLeast(doc(id), '2026-10-19', id);
      }
    });

    test('새로 인용한 공식 출처가 실려 있다', () {
      expect(doc('saa-t3-5').contains('ebs/latest/userguide/general-purpose'),
          isTrue);
      expect(doc('saa-t3-6').contains('SelectEngine'), isTrue);
      expect(doc('saa-t3-7').contains('global-accelerator'), isTrue);
      expect(doc('saa-t3-8').contains('directconnect/sla'), isTrue);
      expect(doc('saa-t3-9').contains('snowball-edge-availability-change'),
          isTrue);
    });
  });

  group('Task 4.1 — saa-t4-1 / saa-t4-5', () {
    test('G-4.1-13 Terminate가 모든 EBS 볼륨을 지우지는 않는다', () {
      // 근거: preserving-volumes-on-termination — 루트는 시작 시 Delete,
      // 데이터 볼륨은 콘솔 시작 시 Preserve / CLI 시작 시 Delete, 시작 후 연결은
      // Preserve. "Preserved volumes continue to incur charges."
      final t41 = doc('saa-t4-1');
      expect(t41.contains('완전히 삭제(Terminate)해야 볼륨 요금이 멈춥니다'), isFalse);
      expect(t41.contains('DeleteOnTermination'), isTrue);
    });

    test('G-4.1-14 128 KB 미만은 손해가 아니라 절감이 없는 것', () {
      // 근거: storage-class-intro — "If the size of an object is less than
      // 128 KB, it is not monitored and not eligible for auto-tiering.
      // Smaller objects are always stored in the Frequent Access tier."
      final t41 = doc('saa-t4-1');
      expect(t41.contains('절감액을 초과'), isFalse);
      expect(t41.contains('모니터링 대상이 아니'), isTrue);
    });

    test('G-4.1-15 Storage Class Analysis는 Storage Lens와 별개 기능', () {
      final t41 = doc('saa-t4-1');
      expect(t41.contains('Storage Lens와 별개'), isTrue);
    });

    test('G-4.1-20 Budget Actions 조치 3종(IAM·SCP·EC2/RDS 대상)', () {
      // 근거: budgets-controls — "Your available actions include applying an
      // IAM policy or a service control policy (SCP). They also include
      // targeting specific Amazon EC2 or Amazon RDS instances"
      final t45 = doc('saa-t4-5');
      expect(t45.contains('SSM Automation 문서 실행'), isFalse);
      expect(t45.contains('서비스 제어 정책(SCP)'), isTrue);
      expect(t45.contains('실행 중 인스턴스'), isTrue);
    });

    test('G-4.1-21 Budgets는 실시간이 아니라 하루 최대 3회 갱신', () {
      // 근거: budgets-managing-costs — "AWS Budgets information is updated up
      // to three times a day. Updates typically occur 8–12 hours after the
      // previous update."
      final t45 = doc('saa-t4-5');
      expect(t45.contains('실시간(갱신 주기 8~12시간)'), isFalse);
      expect(t45.contains('하루 최대 3회'), isTrue);
    });

    test('G-4.1-22 CUR 2.0 / Data Exports가 반영됐다', () {
      // 근거: dataexports-migrate — CUR 2.0은 고정 스키마·중첩 열·SQL 열 선택,
      // 출력 형식 ZIP·GZIP·Parquet
      final t45 = doc('saa-t4-5');
      expect(t45.contains('CUR 2.0'), isTrue);
      expect(t45.contains('Data Exports'), isTrue);
      expect(t45.contains('Parquet'), isTrue);
    });

    test('G-4.1-24 근거 없는 Support 비용 반영일이 사라지고 현행 플랜명이다', () {
      // 근거: aws.amazon.com/premiumsupport/plans/ — 현재 목록은 Basic·
      // Business Support+·Enterprise·Unified Operations
      final t45 = doc('saa-t4-5');
      expect(t45.contains('해당 월 6~7일에 반영'), isFalse);
      expect(t45.contains('Business Support+'), isTrue);
    });

    test('G-4.1-25 Compute Optimizer 룩백은 기본 14일, 향상 지표로 93일', () {
      // 근거: enhanced-infrastructure-metrics — "extends the utilization
      // metrics analysis lookback period to up to 93 days, compared to the
      // default 14-day period" (유료 기능)
      final t45 = doc('saa-t4-5');
      expect(t45.contains('CloudWatch 지표 14일 이상 수집'), isFalse);
      expect(t45.contains('93일'), isTrue);
    });
  });

  group('Task 4.2 — saa-t4-2', () {
    test('G-4.2-12 Convertible RI 최대 66%', () {
      // 근거: EC2 RI 요금 — Standard "up to 72% off", Convertible "up to 66%"
      final t42 = doc('saa-t4-2');
      expect(t42.contains('최대 54%'), isFalse);
      expect(t42.contains('Convertible RI** | 최대 66%'), isTrue);
    });

    test('G-4.2-13 Savings Plans 4종(Database SP 포함)', () {
      // 근거: plan-types — "AWS offers four types of Savings Plans: Compute
      // Savings Plans, Database Savings Plans, EC2 Instance Savings Plans,
      // and SageMaker AI Savings Plans."
      final t42 = doc('saa-t4-2');
      expect(t42.contains('Database Savings Plans'), isTrue);
      expect(t42.contains('SageMaker AI Savings Plans'), isTrue);
    });

    test('G-4.2-21 스팟 중단 동작 3종 + 기본값은 종료', () {
      // 근거: interruption-behavior — "When you create a Spot request, you can
      // specify the interruption behavior. The following are the possible
      // interruption behaviors: Stop, Hibernate, Terminate. The default
      // behavior is that Amazon EC2 terminates Spot Instances when they are
      // interrupted". `[의심]`이었던 이유는 앞선 조회가 UserGuide 대신 Ruby SDK
      // API 문서에 닿아서였다 — 2026-10-24에 직접 문장을 확보해 해소했다.
      final t42 = doc('saa-t4-2');
      expect(t42.contains('종료·중지·동면 중 선택 가능'), isTrue);
      expect(t42.contains('기본값은 종료'), isTrue,
          reason: '기본 동작이 종료라는 시험 포인트가 빠지면 세 선택지가 동등해 보인다');
      expect(t42.contains('interruption-behavior'), isTrue,
          reason: '직접 근거 URL이 sources에 있어야 한다');
    });

    test('G-4.2-16 스팟 할당 전략 권고는 price-capacity-optimized', () {
      // 근거: spot-best-practices — "We recommend using the
      // price-capacity-optimized strategy"
      final t42 = doc('saa-t4-2');
      expect(t42.contains('lowestPrice   : 가장 저렴한 풀 우선 (비용 최소화)'), isFalse);
      expect(t42.contains('price-capacity-optimized'), isTrue);
    });

    test('G-4.2-17 Graviton 비용 서술에서 근거 없는 수식 제거', () {
      // 근거: aws.amazon.com/ec2/graviton/ — "AWS Graviton-based instances
      // cost up to 20% less than comparable x86-based Amazon EC2 instances."
      final t42 = doc('saa-t4-2');
      expect(t42.contains('(Graviton3 기준)'), isFalse);
      expect(t42.contains('최대 20%'), isTrue);
    });

    test('G-4.2-14 SP vs RI는 우선순위가 아니라 조건으로 적는다', () {
      // 근거: sp-ris 전문 확인(2026-10-24) — 이 페이지는 절감률·유연성 **비교 표**와
      // "Savings Plans doesn't provide capacity reservations, but you can
      // allocate On-Demand Capacity Reservation (ODCR) for your needs and your
      // Savings Plans will apply." 를 제시할 뿐 **"먼저 고려하라"는 문장이 없다.**
      // 용량 확보가 요건이면 SP 는 답이 아니므로 우선순위 단정은 과잉 일반화다.
      final t42 = doc('saa-t4-2');
      expect(t42.contains('먼저 고려하라"고 명시'), isFalse);
      expect(t42.contains('Savings Plans 우선 권장'), isFalse);
      expect(t42.contains('AWS 공식 우선 권장'), isFalse);
      expect(t42.contains('용량 확보가 요건'), isTrue);
    });

    test('G-4.2-15 SP가 Spot·RI 커버 사용량에 적용되지 않는 근거', () {
      // 근거: sp-ris — "Savings Plans doesn't apply to spot usage or usage
      // covered by RIs." 2026-10-24 확보로 종전 "공식 문장 미확보" 판정이 해소됐다.
      // Spot 뿐 아니라 **RI 가 커버한 사용량**도 함께 제외된다는 점이 핵심이다
      // (할인 적용 순서 RI → SP 와 맞물린다).
      final t42 = doc('saa-t4-2');
      expect(t42.contains('RI가 커버한 사용량'), isTrue);
    });

    test('G-4.2-18 Dedicated Host는 예약으로 온디맨드보다 싸질 수 있다', () {
      // 근거: dedicated-hosts/pricing — "Reservations can provide up to a 70%
      // discount compared to the On-Demand price", Savings Plans 적용 가능
      final t42 = doc('saa-t4-2');
      expect(t42.contains('| **전용 호스트(Dedicated Host)** | 온디맨드 이상 비용 |'), isFalse);
      expect(t42.contains('최대 70%'), isTrue);
    });

    test('G-4.2-19 Lambda는 1 ms, Fargate는 초 단위·최소 1분', () {
      // 근거: Fargate 요금 "per second with a 1-minute minimum",
      // Lambda 요금 1 ms 단위·프로비저닝 동시성은 유휴에도 과금
      final t42 = doc('saa-t4-2');
      expect(t42.contains('사용한 시간만 밀리초 단위로 과금 — 유휴 시 비용 없음'), isFalse);
      expect(t42.contains('최소 1분'), isTrue);
      expect(t42.contains('프로비저닝 동시성'), isTrue);
    });
  });

  group('Task 4.3 — saa-t4-3', () {
    test('G-4.3-12 Database Savings Plans가 RDS·Aurora에 적용된다', () {
      final t43 = doc('saa-t4-3');
      expect(t43.contains('RDS 비용 절감은 RDS 예약 인스턴스로만 가능합니다'), isFalse);
      expect(t43.contains('Database Savings Plans'), isTrue);
    });

    test('G-4.3-13 RDS RI 사이즈 유연성', () {
      // 근거: USER_WorkingWithReservedDBInstances — Db2·MariaDB·MySQL·
      // Oracle BYOL·PostgreSQL은 사이즈 유연, SQL Server·Oracle LI는 예외.
      // "Reserved DB instance benefits apply to both Multi-AZ and Single-AZ"
      final t43 = doc('saa-t4-3');
      expect(t43.contains('구성 속성이 하나라도 달라지면 할인이 적용되지 않습니다'), isFalse);
      expect(t43.contains('사이즈 유연'), isTrue);
      expect(t43.contains('SQL Server'), isTrue);
    });

    test('G-4.3-15 Timestream for LiveAnalytics는 신규 고객 불가', () {
      // 근거: availability change — "close new customer access to Amazon
      // Timestream for LiveAnalytics, effective 6/20/25", 대안은 InfluxDB
      final t43 = doc('saa-t4-3');
      expect(t43.contains('관계형 DB 대비 1/10 비용'), isFalse);
      expect(t43.contains('InfluxDB'), isTrue);
    });

    test('G-4.3-20 백업 스토리지는 리전 합계 기준', () {
      // 근거: USER_WorkingWithAutomatedBackups — "Your Amazon RDS backup
      // storage for each AWS Region is composed of the automated backups and
      // manual DB snapshots for that Region."
      final t43 = doc('saa-t4-3');
      expect(t43.contains('프로비저닝 스토리지 크기까지는 무료(RDS 기본 제공 범위)'), isFalse);
      expect(t43.contains('리전 전체'), isTrue);
    });
  });

  group('Task 4.4 — saa-t4-4', () {
    test('G-4.4-12 TGW 통과 AZ 간 트래픽에 별도 AZ 전송 요금이 없다', () {
      // 근거: EKS 비용 최적화 모범 사례 — "There is no destination cost
      // associated with inter-AZ traffic that flows through the TGW."
      final t44 = doc('saa-t4-4');
      expect(t44.contains('\$0.01/GB + \$0.02/GB'), isFalse);
      expect(t44.contains('TGW를 통과하는'), isTrue);
    });

    test('G-4.4-16 인터페이스 엔드포인트 시간 요금은 엔드포인트·AZ별', () {
      // 근거: PrivateLink 요금 — "billed for each hour that your VPC endpoint
      // remains provisioned in each Availability Zone", 상태와 무관하게 과금
      final t44 = doc('saa-t4-4');
      expect(t44.contains('\$0.01/GB + 시간당 ENI 요금'), isFalse);
      expect(t44.contains('AZ별 시간 요금'), isTrue);
    });

    test('G-4.4-17 공용 IPv4 요금이 NAT 손익 계산에 반영됐다', () {
      // 근거: using-instance-addressing — "AWS charges for all public IPv4
      // addresses, including public IPv4 addresses associated with running
      // instances and Elastic IP addresses" + NAT 손익 계산식($0.005/IP/시간)
      final t44 = doc('saa-t4-4');
      expect(t44.contains('\$0.005'), isTrue);
      expect(t44.contains('공용 IPv4'), isTrue);
    });
  });

  group('정정 날짜·출처 (Task 4.x)', () {
    test('정정한 문서의 lastVerified가 2026-10-19 이후다', () {
      for (final id in [
        'saa-t4-1',
        'saa-t4-2',
        'saa-t4-3',
        'saa-t4-4',
        'saa-t4-5'
      ]) {
        expectLastVerifiedAtLeast(doc(id), '2026-10-19', id);
      }
    });

    test('새로 인용한 공식 출처가 실려 있다', () {
      expect(doc('saa-t4-1').contains('preserving-volumes-on-termination'),
          isTrue);
      expect(doc('saa-t4-2').contains('savingsplans/latest/userguide/plan-types'),
          isTrue);
      expect(doc('saa-t4-3').contains('USER_WorkingWithReservedDBInstances'),
          isTrue);
      expect(doc('saa-t4-4').contains('privatelink/pricing'), isTrue);
      expect(doc('saa-t4-5').contains('budgets-controls'), isTrue);
    });
  });
}
