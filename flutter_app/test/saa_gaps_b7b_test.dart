import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// SAA 갭 보강 배치 B7b — Task 3.2 10행 (2026-10-21). **B7 완결.**
///
/// 배정 정본은 `docs/content-research/SAA-C03/97-gap-batch-map.md` §4 "B7".
/// B7 18행 중 Task 3.1 잔여 8행은 B7a 가 담았고, 여기서 Task 3.2 10행
/// (`G-3.2-01`~`-09`, `-13`)을 담아 B7 을 닫는다. B7a 에서 미머지 #177 과
/// 같은 파일이라 제외했던 `G-3.2-03`(저작 대상 `saa-t2-3`)을 포함한다.
///
/// ⚠️ `saa-t3-4` 는 `verified:true` 15/15 **라이브 문항 문서**다.
/// ⚠️ `saa-t3-3`·`saa-t3-4` 는 서브섹션 6·원리 6 이라 하한이 꼭 맞아 있었다
///    (min(서브섹션,8)). t3-4 는 절 3개를 늘리는 대신 **원리 블록도 3개** 함께
///    넣어 9/9 로 올렸고, t3-3·t2-3 은 제자리 보강만 했다.
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

  /// 낱말이 있는 **줄**만 골라 본다. 문서 전체를 금지하면 그 수치를 바로잡는
  /// 올바른 문장이 걸린다(이 세션에서 다섯 번 재발 — 맵 §4의 ②).
  Iterable<String> linesWith(String t, String needle) =>
      t.split('\n').where((l) => l.contains(needle));

  group('B7b-1 G-3.2-13 T 패밀리 기본 크레딧 모드 (saa-t3-3)', () {
    test('기본 unlimited 목록에 T8i가 있다', () {
      final t = doc('saa-t3-3');
      expect(t.contains('T8i'), isTrue,
          reason: '공식 목록은 T8i·T4g·T3a·T3 이다');
    });

    test('전용 호스트 예외와 Spot 권장이 있다', () {
      final t = doc('saa-t3-3');
      expect(t.contains('전용 호스트'), isTrue);
      expect(t.contains('standard'), isTrue);
      expect(t.contains('서플러스') || t.contains('surplus'), isTrue);
    });

    // 금지: 기본 unlimited 목록을 T8i 없이 단정하는 것.
    // 공식: "T8i, T4g, T3a, and T3 instances launch as unlimited by default".
    test('기본값 목록을 T3/T3a/T4g로만 적지 않는다', () {
      final t = body('saa-t3-3');
      expect(t.contains('T3/T3a/T4g의 기본값'), isFalse);
      expect(t.contains('T3/T3a/T4g는 기본 모드가'), isFalse);
      expect(t.contains('T3/T3a/T4g 기본값'), isFalse);
    });

    // 금지: 전용 호스트에서도 unlimited 를 쓸 수 있다는 서술.
    // 공식: "unlimited mode is not supported for T3 instances on a Dedicated Host".
    test('전용 호스트에서 unlimited를 쓸 수 있다고 적지 않는다', () {
      final t = body('saa-t3-3');
      expect(t.contains('전용 호스트에서도 `unlimited`'), isFalse);
      expect(t.contains('전용 호스트에서도 unlimited'), isFalse);
    });
  });

  group('B7b-2 G-3.2-08 클러스터 배치 그룹 제약 (saa-t3-3)', () {
    test('지원 인스턴스 유형 제외 목록이 있다', () {
      final t = doc('saa-t3-3');
      expect(t.contains('M7i-flex'), isTrue);
      expect(t.contains('Mac1'), isTrue);
      expect(t.contains('A1'), isTrue, reason: '이전 세대 지원 목록');
    });

    test('대역폭 비대칭과 피어링·용량 예약 항목이 있다', () {
      final t = doc('saa-t3-3');
      expect(t.contains('5 Gbps'), isTrue, reason: '인터넷·DX 트래픽 상한');
      expect(t.contains('피어링'), isTrue);
      expect(t.contains('Capacity Blocks'), isTrue);
      expect(t.contains('온디맨드 용량 예약') || t.contains('ODCR'), isTrue);
    });

    // 금지: 클러스터 PG 가 현행 세대를 전부 지원한다는 서술.
    test('현행 세대를 모두 지원한다고 적지 않는다', () {
      final t = body('saa-t3-3');
      expect(t.contains('현행 세대 전부 지원'), isFalse);
      expect(t.contains('모든 현행 세대를 지원'), isFalse);
    });

    // 금지: 존 RI 로 배치 그룹 내 용량을 예약할 수 있다는 서술.
    // 공식: "you can't reserve capacity using zonal Reserved Instances".
    test('존 RI로 배치 그룹 용량을 예약할 수 있다고 적지 않는다', () {
      final t = body('saa-t3-3');
      expect(t.contains('존 예약 인스턴스로 용량을 예약'), isFalse);
      expect(t.contains('존 RI로 예약'), isFalse);
    });

    // 금지: 인터넷·DX 트래픽에도 10 Gbps 가 적용된다는 서술.
    // 10 Gbps 는 PG 내부 단일 플로우 한도이고, 인터넷·DX 는 5 Gbps 다.
    // ⚠️ `10 Gbps` 자체를 금지하면 **옳은** PG 내부 서술이 걸린다.
    test('인터넷·DX 트래픽을 10 Gbps로 적지 않는다', () {
      final t = body('saa-t3-3');
      expect(t.contains('인터넷 트래픽도 10 Gbps'), isFalse);
      expect(t.contains('인터넷·DX 모두 10 Gbps'), isFalse);
    });
  });

  group('B7b-3 G-3.2-05 ECS 용량 공급자·EKS 컴퓨트 (saa-t3-4)', () {
    test('ECS 용량 공급자와 클러스터 오토스케일링이 있다', () {
      final t = doc('saa-t3-4');
      expect(t.contains('용량 공급자'), isTrue);
      expect(t.contains('FARGATE_SPOT'), isTrue);
      expect(t.contains('CapacityProviderReservation'), isTrue);
      expect(t.contains('targetCapacity'), isTrue);
      expect(t.contains('2분'), isTrue, reason: 'Fargate Spot 중단 경고');
    });

    test('EKS 컴퓨트 선택지가 있다', () {
      final t = doc('saa-t3-4');
      expect(t.contains('Karpenter'), isTrue);
      expect(t.contains('관리형 노드 그룹'), isTrue);
      expect(t.contains('자체 관리'), isTrue);
    });

    // 금지: 한 전략 안에서 Fargate 와 ASG 용량 공급자를 섞을 수 있다는 서술.
    // 공식: "a capacity provider strategy can only contain either Fargate or
    //        Auto Scaling group capacity providers, but not both".
    test('한 전략에 Fargate와 ASG를 섞을 수 있다고 적지 않는다', () {
      final t = body('saa-t3-4');
      expect(t.contains('한 전략에 Fargate와 Auto Scaling 그룹을 함께'), isFalse);
      expect(t.contains('전략 안에서 둘을 섞을 수 있'), isFalse);
    });
  });

  group('B7b-4 G-3.2-06 Lambda 메모리·Fargate 태스크 크기 (saa-t3-4)', () {
    test('Lambda 메모리 범위와 vCPU 환산점이 있다', () {
      final t = doc('saa-t3-4');
      expect(t.contains('128 MB'), isTrue);
      expect(t.contains('10,240 MB'), isTrue);
      expect(t.contains('1,769 MB'), isTrue);
      expect(t.contains('arm64'), isTrue);
    });

    test('Fargate 태스크 CPU·메모리 조합이 있다', () {
      final t = doc('saa-t3-4');
      expect(t.contains('.25 vCPU'), isTrue);
      expect(t.contains('120 GB'), isTrue, reason: '16 vCPU 상단');
      expect(t.contains('200 GiB'), isTrue, reason: '임시 스토리지 상한');
    });

    // 금지: 옛 Lambda 메모리 상한(3,008 MB)을 현행으로 적는 것.
    test('메모리 상한을 3,008 MB로 적지 않는다', () {
      expect(body('saa-t3-4').contains('3,008'), isFalse);
    });

    // 금지: arm64 의 가격-성능 우위를 특정 퍼센트로 단정하는 것.
    // 공식 Lambda 아키텍처 문서는 수치를 적지 않고 "성능을 비교해 보라"고만 한다.
    // ⚠️ 문서 전체에서 `%`를 금지하면 안 된다 — 다른 절의 올바른 수치가 걸린다.
    //    그래서 **arm64 가 있는 줄만** 본다.
    test('arm64 이점을 퍼센트로 단정하지 않는다', () {
      for (final l in linesWith(body('saa-t3-4'), 'arm64')) {
        expect(l.contains('%'), isFalse,
            reason: '공식 Lambda 문서는 arm64 이득을 수치로 적지 않는다: $l');
      }
    });
  });

  group('B7b-5 G-3.2-07 SQS 이벤트 소스 매핑 스케일링 (saa-t3-4)', () {
    test('표준 모드 스케일링 수치가 있다', () {
      final t = doc('saa-t3-4');
      expect(t.contains('이벤트 소스 매핑'), isTrue);
      expect(t.contains('다섯 배치') || t.contains('5개 배치'), isTrue);
      expect(t.contains('300'), isTrue, reason: '분당 증가 폭');
      expect(t.contains('1,250'), isTrue, reason: '동시 호출 상한');
    });

    test('FIFO 상한과 배치 크기가 있다', () {
      final t = doc('saa-t3-4');
      expect(t.contains('메시지 그룹'), isTrue);
      expect(t.contains('10,000'), isTrue, reason: '표준 큐 BatchSize 상한');
    });

    // 금지: ESM 이 계정 동시성까지 무제한으로 확장한다는 서술.
    test('이벤트 소스 매핑이 무제한 확장한다고 적지 않는다', () {
      final t = body('saa-t3-4');
      expect(t.contains('무제한으로 확장'), isFalse);
      expect(t.contains('상한 없이 확장'), isFalse);
    });

    // 금지: 최대 동시성과 예약 동시성을 같은 설정으로 적는 것.
    // 공식: "maximum concurrency and reserved concurrency are two independent settings".
    test('최대 동시성과 예약 동시성을 같은 것으로 적지 않는다', () {
      final t = body('saa-t3-4');
      expect(t.contains('최대 동시성은 예약 동시성과 같은'), isFalse);
      expect(t.contains('예약 동시성의 다른 이름'), isFalse);
    });
  });

  group('B7b-6 G-3.2-01 엣지 컴퓨팅 (saa-t3-4 §7)', () {
    test('절과 앵커가 있다', () {
      expect(doc('saa-t3-4').contains('{#edge-compute}'), isTrue);
    });

    test('두 엣지 함수의 쿼터가 있다', () {
      final t = doc('saa-t3-4');
      expect(t.contains('CloudFront Functions'), isTrue);
      expect(t.contains('Lambda@Edge'), isTrue);
      expect(t.contains('10 KB'), isTrue, reason: 'CF Functions 코드 크기');
      expect(t.contains('2 MB'), isTrue, reason: 'CF Functions 메모리');
      expect(t.contains('50 MB'), isTrue, reason: 'Lambda@Edge 압축 크기');
      expect(t.contains('30초'), isTrue, reason: 'Lambda@Edge 함수 타임아웃');
    });

    test('리전 밖 배치 선택지가 있다', () {
      final t = doc('saa-t3-4');
      expect(t.contains('Local Zone'), isTrue);
      expect(t.contains('Wavelength'), isTrue);
      expect(t.contains('Outposts'), isTrue);
    });

    // 금지: CloudFront Functions 실행 시간을 절대 수치(1 ms)로 단정하는 것.
    // 현행 공식은 **컴퓨팅 사용률(compute utilization) 0~100**으로만 적고
    // 밀리초 한도를 쿼터 표에 두지 않는다.
    test('CloudFront Functions 실행 한도를 1 ms로 단정하지 않는다', () {
      final t = body('saa-t3-4');
      expect(t.contains('1 ms'), isFalse);
      expect(t.contains('1ms'), isFalse);
      expect(t.contains('1밀리초'), isFalse);
      expect(t.contains('컴퓨팅 사용률'), isTrue,
          reason: '공식이 쓰는 지표로 적어야 한다');
    });

    // 금지: Lambda@Edge 타임아웃을 뷰어/오리진으로 쪼개 5초로 적는 것.
    // 현행 쿼터 표는 "함수 타임아웃 30초" 하나이고, 이벤트 유형별로 갈리는
    // 항목은 **생성 응답 크기**(40 KB / 1 MB)뿐이다.
    // ⚠️ `5초` 를 문서 전체에서 금지하면 다른 절의 올바른 서술이 걸린다.
    test('Lambda@Edge 타임아웃을 5초로 적지 않는다', () {
      for (final l in linesWith(body('saa-t3-4'), 'Lambda@Edge')) {
        expect(l.contains('5초'), isFalse,
            reason: '현행 쿼터 표에는 30초만 있다: $l');
      }
    });

    // 금지: CloudFront Functions 가 요청 본문을 읽을 수 있다는 서술.
    test('CloudFront Functions가 본문을 읽는다고 적지 않는다', () {
      final t = body('saa-t3-4');
      expect(t.contains('본문에 접근할 수 있'), isFalse);
      expect(t.contains('요청 본문을 읽을 수 있'), isFalse);
    });
  });

  group('B7b-7 G-3.2-02 컴퓨팅 스케일링 지표 (saa-t3-4 §8)', () {
    test('절과 앵커가 있다', () {
      expect(doc('saa-t3-4').contains('{#compute-scaling-metrics}'), isTrue);
    });

    test('Application Auto Scaling 사전 정의 지표가 있다', () {
      final t = doc('saa-t3-4');
      expect(t.contains('ECSServiceAverageCPUUtilization'), isTrue);
      expect(t.contains('ECSServiceAverageMemoryUtilization'), isTrue);
      expect(t.contains('HighResolution'), isTrue);
      expect(t.contains('20초'), isTrue, reason: '고해상도 지표 간격');
    });

    test('대상 추적 동작 규칙이 있다', () {
      final t = doc('saa-t3-4');
      expect(t.contains('데이터 부족'), isTrue);
      expect(t.contains('배포') && t.contains('축소'), isTrue,
          reason: 'ECS 배포 중 축소 중단');
    });

    // V-22 미해소: AWS Auto Scaling **조정 계획**(scaling plans)의 현행 제공
    // 상태를 공식 문서로 확인하지 못했다. 언급하려면 미확인 표식을 달아야 한다.
    test('조정 계획을 제공 상태 단정 없이 다룬다', () {
      final t = body('saa-t3-4');
      if (t.contains('조정 계획')) {
        expect(t.contains('미확인') || t.contains('확인되지 않'), isTrue,
            reason: 'V-22 가 열려 있어 제공 상태를 단정할 수 없다');
      }
    });
  });

  group('B7b-8 G-3.2-04 큐 버퍼링 (saa-t3-4 §8)', () {
    test('태스크당 백로그 계산이 있다', () {
      final t = doc('saa-t3-4');
      expect(t.contains('백로그'), isTrue);
      expect(t.contains('ApproximateNumberOfMessagesVisible'), isTrue);
      expect(t.contains('지표 수식'), isTrue);
    });

    test('saa-t2-1 교차 참조가 있다', () {
      expect(doc('saa-t3-4').contains('saa-t2-1'), isTrue);
    });

    // 금지: 큐 깊이를 그대로 대상 추적 지표로 쓰라는 서술.
    // 공식: queue depth "is not a reliable metric to scale on directly".
    test('큐 깊이를 그대로 대상 추적 지표로 쓰라고 적지 않는다', () {
      final t = body('saa-t3-4');
      expect(t.contains('큐 깊이를 그대로 대상 추적'), isFalse);
      expect(t.contains('큐 길이를 대상 추적 지표로 쓰면 됩니다'), isFalse);
    });
  });

  group('B7b-9 G-3.2-09 EMR 배포 선택 (saa-t3-4 §9)', () {
    test('절과 앵커가 있다', () {
      expect(doc('saa-t3-4').contains('{#emr-deployment}'), isTrue);
    });

    test('네 가지 배포가 모두 있다', () {
      final t = doc('saa-t3-4');
      expect(t.contains('EMR'), isTrue);
      expect(t.contains('네 가지'), isTrue, reason: '공식은 4종을 적는다');
      expect(t.contains('EMR Serverless'), isTrue);
      // 공식 명칭은 "Amazon EMR on Amazon EKS" 다 — `EMR on EKS` 로만 보면
      // 올바른 표기가 걸린다(가드가 좁았던 사례).
      expect(t.contains('EMR on Amazon EKS'), isTrue);
    });

    test('태스크 노드 Spot 근거와 제약이 있다', () {
      final t = doc('saa-t3-4');
      expect(t.contains('HDFS'), isTrue);
      expect(t.contains('관리형 스케일링'), isTrue);
      expect(t.contains('제거할 수 없') || t.contains('삭제할 수 없'), isTrue,
          reason: '태스크 그룹은 생성 후 제거 불가');
    });

    // 금지: 배포 옵션을 3종으로 단정하는 것(공식 비용 최적화 문서는 4종).
    test('배포 옵션을 세 가지로 적지 않는다', () {
      final t = body('saa-t3-4');
      expect(t.contains('세 가지 배포'), isFalse);
      expect(t.contains('배포 옵션은 3'), isFalse);
    });

    // 금지: Outposts 에서도 Spot 을 쓸 수 있다는 서술.
    test('EMR on Outposts에서 Spot을 쓸 수 있다고 적지 않는다', () {
      final t = body('saa-t3-4');
      expect(t.contains('Outposts에서도 Spot'), isFalse);
      expect(t.contains('Outposts에서 Spot 인스턴스를 쓸 수 있'), isFalse);
    });
  });

  group('B7b-10 G-3.2-03 ASG 조정 지표 (saa-t2-3 §9)', () {
    test('사전 정의 지표 네 가지가 있다', () {
      final t = doc('saa-t2-3');
      expect(t.contains('ASGAverageCPUUtilization'), isTrue);
      expect(t.contains('ASGAverageNetworkIn'), isTrue);
      expect(t.contains('ASGAverageNetworkOut'), isTrue);
      expect(t.contains('ALBRequestCountPerTarget'), isTrue);
      expect(t.contains('ResourceLabel'), isTrue);
    });

    test('인스턴스당 백로그 계산이 있다', () {
      final t = doc('saa-t2-3');
      expect(t.contains('인스턴스당 백로그'), isTrue);
      expect(t.contains('ApproximateNumberOfMessages'), isTrue);
      expect(t.contains('InService'), isTrue);
    });

    test('예측 스케일링 전제가 있다', () {
      final t = doc('saa-t2-3');
      expect(t.contains('24시간'), isTrue, reason: '최소 데이터');
      expect(t.contains('14일'), isTrue, reason: '분석 범위');
      expect(t.contains('48시간'), isTrue, reason: '예측 구간');
      expect(t.contains('6시간'), isTrue, reason: '예측 갱신 주기');
      expect(t.contains('예측 전용'), isTrue);
    });

    // 금지: 예측 스케일링이 축소까지 한다는 서술.
    // 공식: "it will not scale in to remove capacity" — 축소는 동적 조정 정책 몫.
    test('예측 스케일링이 축소한다고 적지 않는다', () {
      final t = body('saa-t2-3');
      expect(t.contains('예측 스케일링이 축소'), isFalse);
      expect(t.contains('예측 스케일링으로 축소'), isFalse);
    });

    // 금지: EC2 ASG 사전 정의 지표에 메모리 지표가 있다는 서술(공식 목록에 없다).
    test('사전 정의 지표에 메모리 지표를 넣지 않는다', () {
      expect(body('saa-t2-3').contains('ASGAverageMemory'), isFalse);
    });
  });
}
