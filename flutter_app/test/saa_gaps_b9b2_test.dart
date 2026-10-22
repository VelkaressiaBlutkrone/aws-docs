import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// SAA 갭 보강 배치 **B9b-2** — Task 4.2 중 **신규 절 6행** (2026-10-22).
///
/// 배정 정본은 `docs/content-research/SAA-C03/97-gap-batch-map.md` §4 "B9".
/// B9b-1(기존 절 보강 6행)에 이어 **문서에 아예 없던 주제 6행**을 새 절로 넣는다 —
/// 실측으로 `LCU`·`Outposts`·`수평`·`수직`·`Instance Scheduler`·
/// `CloudFront Functions` 가 24개 SAA 문서에서 0건이었다.
///
/// 6행을 **3개 절로 묶었다**(얇은 절 6개보다 읽기 흐름이 낫다 — B9a 의 §9·§10 방식):
///   §9 로드 밸런서 비용(`01`) · §10 끄고 줄이는 절감(`02`·`03`) ·
///   §11 배치 결정이 만드는 비용(`04`·`05`·`06`).
///
/// ## ⚠️ 라이브 문항과의 정합
///
/// - **q1** 의 오답 해설이 "개발·테스트에 Spot 은 부적합"(2분 알림 후 회수 시 작업
///   중단)이라고 못박는다. 그래서 비프로덕션의 Spot 활용은 **"중단을 허용할 수
///   있는"** 조건부로만 적는다 — 무조건 권유로 쓰면 라이브 문항과 어긋난다.
/// - **q11**(예측 가능한 패턴 → Scheduled Scaling)과 **Instance Scheduler** 는 층이
///   다르다(ASG 용량 조정 vs 인스턴스 자체 시작·중지). 둘을 같은 것으로 쓰지 않는다.
///
/// ## ⚠️ G-02 요율 규율 — 쓰지 않는 것
///
/// 리전 의존 요율과 단가는 쓰지 않고 **과금 축·용량 단위·상대 비율만** 쓴다:
/// CloudFront Functions·Lambda@Edge 호출 단가, Lambda@Edge GB-초 단가,
/// AMD·Graviton 인스턴스 시간당 예시 가격, Outposts 구성 가격, 리전별 GB 요율.
/// **리전 이름 자체**(us-east-1 등)는 요율이 아니라 예시 지명이라 쓸 수 있다.
void main() {
  String doc(String id) =>
      File('assets/content/saa/$id.md').readAsStringSync();

  /// 출처·정정 노트 구간을 제외한 **본문**만 본다(B6 교훈 — 맵 §4).
  String body(String id) {
    final t = doc(id);
    final i = t.indexOf('### 📌 출처');
    return i < 0 ? t : t.substring(0, i);
  }

  group('B9b-2 G-4.2-01 — 로드 밸런서 비용 (saa-t4-2)', () {
    // 공식: ALB 는 LCU, NLB 는 NLCU 로 용량 단위를 과금한다.
    test('LCU·NLCU 용량 단위를 적는다', () {
      final t = doc('saa-t4-2');
      expect(t.contains('LCU'), isTrue);
      expect(t.contains('NLCU'), isTrue);
    });

    // 공식: "You are charged only on the dimension with the highest usage." ·
    //       NLB "only on one of the three dimensions that has the highest usage"
    test('사용량이 가장 큰 한 차원만 과금됨을 적는다', () {
      expect(doc('saa-t4-2').contains('가장 큰 한 차원'), isTrue);
    });

    // 공식: ALB LCU 4차원 중 규칙 평가(처음 10규칙 무료).
    test('ALB 의 규칙 평가 차원을 적는다', () {
      expect(doc('saa-t4-2').contains('규칙 평가'), isTrue);
    });

    // 공식: NLB·GWLB 는 LCU 예약을 지원하고 예약분은 사용과 무관하게 과금된다.
    test('NLB·GWLB 의 LCU 예약을 적는다', () {
      final t = doc('saa-t4-2');
      expect(t.contains('LCU 예약'), isTrue);
      expect(t.contains('GWLB'), isTrue);
    });

    // 공식: ALB 는 호스트·경로·헤더 조건 라우팅으로 한 LB 에서 여러 앱을 서비스.
    test('ALB 통합으로 로드 밸런서 수를 줄이는 축을 적는다', () {
      expect(doc('saa-t4-2').contains('경로 기반'), isTrue);
    });
  });

  group('B9b-2 G-4.2-02 — 최대 절전과 수평·수직 스케일링 (saa-t4-2)', () {
    // 공식: "You're not charged for instance usage for a hibernated instance" —
    //       단 RAM 내용을 담은 EBS 는 과금되고 `stopping` 상태에서는 과금된다.
    test('최대 절전의 과금 규칙을 적는다', () {
      final t = doc('saa-t4-2');
      expect(t.contains('최대 절전'), isTrue);
      expect(t.contains('stopping'), isTrue);
    });

    test('수평 스케일링과 수직 스케일링을 가른다', () {
      final t = doc('saa-t4-2');
      expect(t.contains('수평 스케일링'), isTrue);
      expect(t.contains('수직 스케일링'), isTrue);
    });
  });

  group('B9b-2 G-4.2-03 — 워크로드 클래스별 필요 가용성 (saa-t4-2)', () {
    // 공식(WA): "You can stop these resources when they're not in use for a
    //       potential cost savings of 75% (40 hours versus 168 hours)."
    test('비프로덕션 스케줄 중지의 절감 근거를 적는다', () {
      final t = doc('saa-t4-2');
      expect(t.contains('75%'), isTrue);
      expect(t.contains('168시간'), isTrue);
    });

    // 공식: Instance Scheduler on AWS 가 EC2·RDS 를 일정에 따라 시작·중지한다.
    test('Instance Scheduler 를 적는다', () {
      expect(doc('saa-t4-2').contains('Instance Scheduler'), isTrue);
    });

    // ⚠️ q1 정합: 비프로덕션의 Spot 활용은 조건부로만 적는다.
    test('비프로덕션 Spot 활용을 중단 허용 조건으로 묶는다', () {
      expect(doc('saa-t4-2').contains('중단을 허용할 수 있'), isTrue);
    });

    test('개발·테스트에 Spot 을 무조건 권하지 않는다', () {
      final t = body('saa-t4-2');
      expect(t.contains('개발·테스트는 Spot으로'), isFalse);
      expect(t.contains('비프로덕션은 Spot으로'), isFalse);
    });
  });

  group('B9b-2 G-4.2-04 — 리전 선택과 비용 (saa-t4-2)', () {
    // 공식(WA): "resource pricing is different in each Region" — 제약이 없으면
    //       요금이 낮은 리전에 배포하고, 절감이 이전 비용보다 크면 옮긴다.
    test('리전별 요금 차이와 이전 비용 비교를 적는다', () {
      final t = doc('saa-t4-2');
      expect(t.contains('이전 비용'), isTrue);
      expect(t.contains('Pricing Calculator'), isTrue);
    });
  });

  group('B9b-2 G-4.2-05 — 엣지 컴퓨팅 비용 (saa-t4-2)', () {
    // 공식: 가능하면 CloudFront Functions 를 쓰고, Lambda@Edge 는 무료 티어가 없다.
    test('CloudFront Functions 와 Lambda@Edge 를 가른다', () {
      final t = doc('saa-t4-2');
      expect(t.contains('CloudFront Functions'), isTrue);
      expect(t.contains('Lambda@Edge'), isTrue);
    });

    test('Lambda@Edge 에 무료 티어가 없음을 적는다', () {
      expect(doc('saa-t4-2').contains('무료 티어가 없'), isTrue);
    });
  });

  group('B9b-2 G-4.2-06 — Outposts 비용 모델 (saa-t4-2)', () {
    // 공식: "You can purchase Outposts rack capacity for a three-year term" —
    //       가격에 배송·설치·유지보수·패치·랙 제거가 포함되고, 약정 종료 시
    //       갱신 또는 반납(미통보 시 월 단위 No Upfront 요율로 자동 갱신).
    test('Outposts 의 약정·포함 항목을 적는다', () {
      final t = doc('saa-t4-2');
      expect(t.contains('Outposts'), isTrue);
      expect(t.contains('설치·유지보수'), isTrue);
    });
  });

  group('B9b-2 금지 — G-02 요율 규율', () {
    test('엣지 함수 호출 단가를 적지 않는다', () {
      final t = body('saa-t4-2');
      expect(t.contains('\$0.10'), isFalse);
      expect(t.contains('\$0.60'), isFalse);
      expect(t.contains('\$0.00005001'), isFalse);
    });

    test('프로세서 인스턴스 시간당 예시 가격을 적지 않는다', () {
      final t = body('saa-t4-2');
      expect(t.contains('\$0.153'), isFalse);
      expect(t.contains('\$0.17'), isFalse);
    });

    test('리전별 GB 요율을 적지 않는다', () {
      final t = body('saa-t4-2');
      expect(t.contains('GB당 \$'), isFalse);
      expect(t.contains('USD/GB'), isFalse);
    });
  });
}
