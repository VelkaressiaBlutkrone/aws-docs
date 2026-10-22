import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// SAA 갭 보강 배치 **B9a-2** — Task 4.1 잔여 중 `saa-t4-5` 소관 **2행** (2026-10-22).
///
/// 배정 정본은 `docs/content-research/SAA-C03/97-gap-batch-map.md` §4 "B9".
/// B9a(스토리지 10행)에서 떼어 둔 `G-4.1-11`·`G-4.1-12`로, 둘 다 `saa-t4-5`가
/// 대상이다 — 당시 같은 파일을 건드리는 #185가 미머지여서 순차로 미뤘다.
///
/// ⚠️ **공식이 갭 노트와 달랐다(이 배치의 수확)**: `G-4.1-12`는 Basic 플랜을
///    "보안 6종 + 서비스 한도"로 적었지만 공식은 **서비스 한도 카테고리 전체 +
///    보안·내결함성 카테고리의 일부 점검**이다 — 내결함성이 빠져 있었고 "6종"은
///    해당 문서에 없다. 갭 노트가 아니라 **공식을 따른다.**
///
/// ⚠️ **쓰지 않기로 한 것** — 근거를 확보하지 못해 본문에서 금지한다:
///    ① Cost Explorer 세분화의 **추가 비용** — `ce-configuring-data`에 과금 언급이
///       없다(F-33의 "추가 비용 가능"은 출처로 확인되지 않았다).
///    ② **Cost Optimization Hub** — `4-1.md` F-30~F-36에 근거 행 자체가 없다.
///    ③ **CUR 2.0·FOCUS 1.0 세부** — `99-gaps` V-88. 기본 서술은 §1 표·§4에 이미 있다.
///    ④ Support 플랜 **월 최소 요금** — 시험 범위 밖이고 휘발성이다(G-02 요율 규율).
///
/// ⚠️ 금지 가드는 **구체 문구로 좁힌다.** `14일`·`3개월`·`내결함성`·`$5,000`은
///    이미 다른 맥락으로 본문에 있다(Compute Optimizer 룩백 14일, 시험 포인트의
///    "지난 3개월", 함정 3의 카테고리 나열, 자가 점검 Q2의 예산 예시 금액) —
///    그대로 금지하거나 그대로 요구하면 **옳은 기존 서술을 잡는다**(맵 §4 B9a 교훈).
void main() {
  String doc(String id) =>
      File('assets/content/saa/$id.md').readAsStringSync();

  /// 출처·정정 노트 구간을 제외한 **본문**만 본다(B6 교훈 — 맵 §4).
  String body(String id) {
    final t = doc(id);
    final i = t.indexOf('### 📌 출처');
    return i < 0 ? t : t.substring(0, i);
  }

  group('B9a-2 G-4.1-11 — Cost Explorer 다년·세분화 (saa-t4-5)', () {
    // 공식: "You can enable up to 38 months of multi-year data at monthly
    //        granularity for your entire organization." ·
    //       "Using the management account, you can enable multi-year data
    //        and granular data in Cost Explorer."
    test('다년 데이터 한도와 활성화 주체가 있다', () {
      final t = doc('saa-t4-5');
      expect(t.contains('최대 38개월'), isTrue, reason: '다년 데이터 한도');
      expect(t.contains('관리 계정'), isTrue, reason: '활성화 주체');
    });

    // 공식: "The hourly data as well as daily resource-level data is
    //        available for the past 14 days."
    test('시간·일 리소스 단위 데이터의 14일 창이 있다', () {
      expect(doc('saa-t4-5').contains('최근 14일'), isTrue);
    });

    // 공식: "It can take up to 48 hours for changes to your data settings to
    //        reflect" · "you won't be able to make any additional changes
    //        for 48 hours".
    test('설정 반영·재변경 대기 48시간이 있다', () {
      expect(doc('saa-t4-5').contains('최대 48시간'), isTrue);
    });

    // 공식: "We will disable multi-year data for your organization if no one
    //        in the organization accesses it in three consecutive months."
    test('3개월 연속 미접근 시 다년 데이터가 해제됨을 적는다', () {
      expect(doc('saa-t4-5').contains('3개월 연속'), isTrue);
    });

    // 공식: "this data is only available in Cost Explorer, as Savings Plans
    //        and Reservations utilization and coverage reports don't support
    //        this data."
    test('다년 데이터가 SP·RI 사용률/커버리지 보고서에서 안 보임을 적는다', () {
      expect(doc('saa-t4-5').contains('사용률·커버리지 보고서'), isTrue);
    });

    test('세분화 활성화가 추가 비용을 유발한다고 단정하지 않는다', () {
      final t = body('saa-t4-5');
      expect(t.contains('추가 비용'), isFalse);
      expect(t.contains('추가 요금'), isFalse);
    });

    test('Cost Optimization Hub를 쓰지 않는다', () {
      expect(body('saa-t4-5').contains('Cost Optimization Hub'), isFalse);
    });

    test('FOCUS 1.0 세부를 쓰지 않는다', () {
      expect(body('saa-t4-5').contains('FOCUS'), isFalse);
    });
  });

  group('B9a-2 G-4.1-11 — 비용 할당 태그 활성화 (saa-t4-5)', () {
    // 공식: "it can take up to 24 hours for the tag keys to appear on your
    //        cost allocation tags page for activation. It can then take up to
    //        24 hours for tag keys to activate."
    test('활성화 지연 2단(목록 등장·활성화)이 있다', () {
      final t = doc('saa-t4-5');
      expect('최대 24시간'.allMatches(t).length, greaterThanOrEqualTo(2),
          reason: '목록 등장까지 24시간 + 활성화까지 24시간 = 2회');
    });

    // 공식: "Once you activate or deactivate the tag key, it will affect all
    //        tag values that share the same tag key."
    test('키 단위 활성화가 같은 키의 모든 값에 적용됨을 적는다', () {
      expect(doc('saa-t4-5').contains('모든 태그 값'), isTrue);
    });

    // 공식: "You can also use the UpdateCostAllocationTagsStatus API
    //        operation to activate your tags in bulk."
    test('일괄 활성화 API 이름이 있다', () {
      expect(doc('saa-t4-5').contains('UpdateCostAllocationTagsStatus'), isTrue);
    });

    test('AWS 생성 태그를 관리 계정이 활성화함을 적는다', () {
      final t = doc('saa-t4-5');
      expect(t.contains('관리 계정이 활성화하면'), isTrue);
      expect(t.contains('createdBy'), isTrue);
    });

    // 공식: "The awsApplication tag will be automatically added to all
    //        resources that are associated with applications that are set up
    //        in AWS Service Catalog AppRegistry. This tag is automatically
    //        activated for you as a cost allocation tag." ·
    //       "The awsApplication tag doesn't count towards your cost
    //        allocation tag quota."
    test('awsApplication 태그의 자동 활성화·쿼터 예외를 적는다', () {
      final t = doc('saa-t4-5');
      expect(t.contains('awsApplication'), isTrue);
      expect(t.contains('AppRegistry'), isTrue);
    });
  });

  group('B9a-2 G-4.1-12 — Trusted Advisor 지원 플랜 조건 (saa-t4-5)', () {
    // 공식: "AWS Trusted Advisor checks are available to customers with an
    //        AWS Business Support+, AWS Enterprise Support, or AWS Unified
    //        Operations plan."
    test('전체 점검 플랜 3종이 Trusted Advisor 맥락에 있다', () {
      final t = doc('saa-t4-5');
      expect(t.contains('Trusted Advisor 전체 점검'), isTrue);
      expect(t.contains('Business Support+'), isTrue);
      expect(t.contains('Unified Operations'), isTrue);
    });

    // 공식: "If you have a Basic Support plan, you can use the Trusted Advisor
    //        console to access all checks in the Service Limits category and
    //        selected checks in the Security and Fault tolerance categories."
    test('Basic 범위를 서비스 한도 전체 + 보안·내결함성 일부로 적는다', () {
      final t = doc('saa-t4-5');
      expect(t.contains('서비스 한도 카테고리'), isTrue);
      expect(t.contains('보안·내결함성 카테고리의 일부'), isTrue);
    });

    test('Basic을 "보안 6종"으로 적지 않는다', () {
      expect(body('saa-t4-5').contains('보안 6종'), isFalse);
    });

    // 공식: "Automatic check updates aren't available in the Basic Support
    //        plan. You must manually refresh Trusted Advisor checks in the
    //        Security category."
    test('Basic에 자동 점검 갱신이 없음을 적는다', () {
      expect(doc('saa-t4-5').contains('자동 점검 갱신'), isTrue);
    });

    // 공식: "Developer Support will be discontinued January 1, 2027." ·
    //       "Business Support will be discontinued January 1, 2027." ·
    //       "On January 1, 2027, AWS will discontinue Enterprise On-Ramp.
    //        Throughout 2026, Enterprise On-Ramp customers will be
    //        automatically upgraded to AWS Enterprise Support".
    test('2027-01-01 플랜 종료와 On-Ramp 자동 승급을 적는다', () {
      final t = doc('saa-t4-5');
      expect(t.contains('2027-01-01'), isTrue);
      expect(t.contains('On-Ramp'), isTrue);
    });

    // 공식: "Developer Support, Business Support, and Enterprise On-Ramp will
    //        remain available in the AWS GovCloud (US) Region."
    test('GovCloud(US)에서는 존치됨을 적는다', () {
      expect(doc('saa-t4-5').contains('GovCloud'), isTrue);
    });

    test('Support 플랜 월 최소 요금을 적지 않는다', () {
      final t = body('saa-t4-5');
      expect(t.contains('월 최소'), isFalse);
      expect(t.contains('\$29'), isFalse);
    });

    // F-35: Compute Optimizer 룩백 기본 14일 / 32일 / 93일(유료).
    test('Compute Optimizer 룩백 32일 옵션이 있다', () {
      expect(doc('saa-t4-5').contains('32일'), isTrue);
    });
  });
}
