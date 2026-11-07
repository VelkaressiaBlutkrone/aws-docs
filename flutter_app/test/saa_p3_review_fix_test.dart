import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 2026-11-06 전 콘텐츠 2단 검토의 **SAA 우선순위 3(P3) 계열** 가드.
///
/// 보고서 정본: `docs/audits/2026-11-06-full-content-review/saa-c03.md`
/// §4-5(지역 미한정 절대 요금) · §4-6(교차 AZ 「each way」) · §4-7(두 터널
/// 「부하 분산」) · §4-8 잔여 2건.
///
/// 공식 재측정은 컨트롤러가 직접 했다. 손댄 문항 5개와 학습문서 1편이 **전부
/// 라이브**이고 **정답 인덱스·`verified` 는 한 건도 바뀌지 않았다.**
///
/// ## ⚠️⚠️ 이 배치는 「문항을 md 수준으로 끌어올리는」 일이다 — 수치를 지우지 않는다
///
/// 보고서 §4-5는 「`(US East … 기준 · 리전마다 다름)` 을 병기하거나 절대값을
/// 빼라」고 적었다. 그런데 **레포는 이미 더 깊이 판정해 뒀다**:
/// `docs/content-research/SAA-C03/98-existing-gap.md` 의 `G-4.4-13`~`15` 가
/// AZ 간 **각 방향 $0.01/GB**(확인) · 인터넷 `$0.09/GB`(**직접 인용 미확보**) ·
/// DX `$0.02/GB`(**공식 문서의 「예시」, 미국 위치**) · 포트 시간 요율(**미확보**)
/// 로 이미 분류하고, `saa_gaps_b10b_test.dart` 가 **「이미 본문에 있는 단가는
/// 건드리지 않는다」**를 못박아 뒀다.
///
/// 그리고 **`saa-t4-4.md:203·211` 은 이미 한정을 적는다** — `$0.02/GB 수준
/// (US 기준)` 과 「아웃바운드 단가와 비율은 **DX 위치와 리전마다 다릅니다**.
/// 「인터넷의 약 1/4」은 특정 지역 예시에 가까우니 …」. 결함은 **문항만 그 한정을
/// 빠뜨린 것**이다(md가 옳고 문항이 거친 **역방향 잔존**이고, 이 트랙에서 반복해
/// 나온 모양이다). 그래서 **수치를 지우지 않고 문항에 md와 같은 한정을 넣는다** —
/// 지우면 md와 문항이 어긋나고 `saa_gaps_b10b_test` 의 결정을 뒤집는다.
///
/// ## 비자명한 공식 사실 (직접 인용)
///
/// ⚠️ **`$0.045` 는 리전이 명시된 공식 산문에 있다** — `aws.amazon.com/vpc/pricing/`
/// 의 NAT Gateway 요금 예시가 `The EC2 instance, NAT gateway, and S3 Bucket are in
/// the same region of the US East (Ohio)` 라고 전제를 깔고
/// `For this region, the rate is $0.045 per hour.` 로 적는다. ⚠️ **리전은
/// 버지니아 북부가 아니라 오하이오**다(보고서는 리전을 적지 않았다 — 추측하지 않고
/// 실측했다). 같은 절이 데이터 처리 1 GB에 `$0.045` 를 적는다.
///
/// ⚠️ **인용한 `nat-gateway-pricing.html` 에는 단가가 하나도 없다** — `you are
/// charged for each hour … and each gigabyte of data that it processes. For more
/// information, see Amazon VPC Pricing.` 까지다. 그래서 **단가가 산문으로 적힌
/// 페이지를 함께 단다**(2026-10-28 배치가 `q1`·`q10`·`q11`·`q15` 에 쓴 것과 같은
/// 규율).
///
/// ⚠️ **교차 AZ 는 「각 방향」이다** — `prescriptive-guidance/latest/
/// eks-cost-optimization/network-cost-reduction.html` 이 `per-GB transfer charges
/// ($0.01/GB each way)` 로 적고, `cur/latest/userguide/cur-data-transfers-charges
/// .html` 이 기제를 설명한다: `For a given resource, you're charged for both
/// inbound and outbound traffic in a data transfer within an AWS Region. This
/// means for each resource metered, you'll see two DataTransfer-Regional-Bytes
/// line items for each data transfer.`
///
/// ⚠️ **DX DTO 의 `$0.02` 는 공식이 「예시일 뿐」이라고 밝힌다** —
/// `directconnect/latest/PricingGuide/pricing-overview.html` 이 `data transfer out
/// is billed at an illustrative rate of $0.02 per GB. This rate is provided only
/// as an example, is subject to change, and might not reflect current pricing.`
/// 로 적고, DTO 가 **DX 로케이션과 리전 조합**으로 정해진다고 말한다. 비교 방향의
/// 근거는 하이브리드 연결 백서다: `all data transferred over your dedicated
/// connection is charged at the reduced AWS Direct Connect data transfer rate,
/// rather than internet data transfer rates` + `calculate a breakeven point`.
///
/// ⚠️ **공식 VPN 문구는 「고가용성」까지다** — `vpn/latest/s2svpn/VPC_VPN.html` 이
/// `Each VPN connection includes two VPN tunnels which you can simultaneously use
/// for high availability.` 로 적고 **부하 분산을 적지 않는다.** 터널을 묶는
/// ECMP 는 `whitepapers/latest/aws-vpc-connectivity-options/
/// aws-transit-gateway-vpn.html` 의 조건부 기능이다: `When terminating the VPN
/// connections in the Transit Gateway, you can use Equal Cost Multi-Path (ECMP)
/// routing to get a higher VPN bandwidth by aggregating multiple VPN tunnels. To
/// use ECMP, you need to configure dynamic routing … ECMP is not supported using
/// static routing.` ⭐ **`saa-t3-8.md:175~177` 은 이미 그 조건을 정확히 적는다** —
/// 또 역방향 잔존이다.
///
/// ⚠️ **IP 차단은 NACL 전용이 아니다** — `waf/latest/developerguide/
/// waf-rule-statement-type-ipset-match.html` 이 `The IP set match statement
/// inspects the IP address of a web request against a set of IP addresses and
/// address ranges. Use this to allow or block web requests based on the IP
/// addresses that the requests originate from.` 로 적는다. 보기 집합 안에서
/// NACL 이 정답인 것은 그대로지만 **「반드시」는 과하다.**
///
/// ## 비자명한 규율
///
/// ⚠️ **반영 전에 레포의 선행 판정을 먼저 읽는다.** 보고서 §4-5·§4-6은 레포
/// `99-gaps` 의 `V-64`·`V-66` 과 같은 사안이고, 그 판정(「구조만 기재」·「예시만」)이
/// 이미 md에 반영돼 있었다. 보고서만 보고 절대값을 지웠다면 **md·가드·갭 노트
/// 세 곳의 결정을 동시에 뒤집었다.**
///
/// ⚠️ **`$0.09/GB`·`$0.30/시간`은 미확보지만 md가 이미 「수준」·한정과 함께 쓴다** —
/// 문항도 같은 어법으로 맞추고, **미확보 사실을 새로 단정하지 않는다**(「us-east-1
/// 에서는 DX 가 더 비싸다」는 근거가 `repost.aws` 뿐이라 쓰지 않았다).
void main() {
  const content = 'assets/content';

  List<Map<String, dynamic>> questionsOf(File f) =>
      ((json.decode(f.readAsStringSync()) as Map<String, dynamic>)['questions']
              as List)
          .cast<Map<String, dynamic>>();

  Map<String, dynamic> question(String task, String qid) =>
      questionsOf(File('$content/saa/$task.questions.json'))
          .firstWhere((q) => q['id'] == qid, orElse: () => fail('$qid 없음'));

  String doc(String id) => File('$content/saa/$id.md').readAsStringSync();

  String blob(Map<String, dynamic> q) => json.encode(q);

  String answer(Map<String, dynamic> q) =>
      (q['options'] as List).cast<String>()[q['correct'] as int];

  List<String> urls(Map<String, dynamic> q) => (q['sources'] as List)
      .cast<Map<String, dynamic>>()
      .map((s) => s['url'] as String)
      .toList();

  /// 절대 단가 표기(`$0.045` 류)를 찾는다.
  bool hasAbsoluteRate(String text) => RegExp(r'\$\d').hasMatch(text);

  /// 리전·위치 한정이 붙었는가 — md가 쓰는 어법과 같은 집합이다.
  bool hasRegionCaveat(String text) =>
      text.contains('리전마다') ||
      text.contains('리전별') ||
      text.contains('위치와 리전') ||
      text.contains('위치·리전') ||
      text.contains('리전·위치');

  // ═════════════════════ 대조군 ═════════════════════

  test('대조군: 손댄 다섯 문항이 읽히고 구조가 성립한다', () {
    for (final q in <Map<String, dynamic>>[
      question('saa-t4-4', 'saa-t4-4-q3'),
      question('saa-t4-4', 'saa-t4-4-q5'),
      question('saa-t4-4', 'saa-t4-4-q13'),
      question('saa-t3-8', 'saa-t3-8-q4'),
      question('saa-t1-3', 'saa-t1-3-q5'),
    ]) {
      expect((q['options'] as List).length, 4);
      expect((q['wrongExplanations'] as Map).length, 3);
      expect(q['verified'], true, reason: 'SAA 360문항은 전부 라이브다');
    }
  });

  test('§4: 정답 인덱스가 한 건도 바뀌지 않았다', () {
    expect(question('saa-t4-4', 'saa-t4-4-q3')['correct'], 2);
    expect(question('saa-t4-4', 'saa-t4-4-q5')['correct'], 2);
    expect(question('saa-t4-4', 'saa-t4-4-q13')['correct'], 3);
    expect(question('saa-t3-8', 'saa-t3-8-q4')['correct'], 0);
    expect(question('saa-t1-3', 'saa-t1-3-q5')['correct'], 0);
  });

  // ═══════════ §4-5 — 절대 단가에 리전·위치 한정을 붙인다 ═══════════

  group('§4-5 절대 단가를 적는 문항은 한정을 함께 적는다', () {
    test('q3 가 리전을 밝히고 단가가 적힌 페이지를 출처로 단다', () {
      final q = question('saa-t4-4', 'saa-t4-4-q3');
      final b = blob(q);
      expect(b.contains('오하이오'), isTrue,
          reason: '공식 예시의 전제 리전은 US East (Ohio) 다');
      expect(hasRegionCaveat(b), isTrue);
      expect(urls(q).any((u) => u.contains('vpc/pricing')), isTrue,
          reason: 'nat-gateway-pricing.html 에는 단가가 하나도 없다');
      expect(urls(q).any((u) => u.contains('nat-gateway-pricing')), isTrue,
          reason: '과금 축(시간 + GB)의 정본은 그대로 남긴다');
    });

    test('q13 이 「예시」와 위치·리전 의존을 밝힌다', () {
      final q = question('saa-t4-4', 'saa-t4-4-q13');
      final b = blob(q);
      expect(b.contains('예시'), isTrue,
          reason: '공식 가이드가 \$0.02 를 illustrative rate 로 적는다');
      expect(hasRegionCaveat(b), isTrue);
      expect(
        urls(q).any((u) => u.contains('PricingGuide/pricing-overview')),
        isTrue,
        reason: 'pay-as-you-go 요율 표는 JS 로 그려져 본문에 나오지 않는다',
      );
    });

    test('전수: t4-4 문항에서 절대 단가는 한정 없이 쓰이지 않는다', () {
      final offenders = <String>[];
      var scanned = 0;
      for (final q in questionsOf(
          File('$content/saa/saa-t4-4.questions.json'))) {
        final b = blob(q);
        if (!hasAbsoluteRate(b)) continue;
        scanned++;
        if (!hasRegionCaveat(b)) offenders.add(q['id'] as String);
      }
      expect(scanned, greaterThanOrEqualTo(3), reason: '대조군 — 비공허');
      expect(offenders, isEmpty,
          reason: '단가는 리전·위치마다 다르다(레포 갭 노트 G-4.4-13~15): '
              '${offenders.join(' · ')}');
    });

    test('대조군: 탐지기가 단가와 한정을 각각 집는다', () {
      expect(hasAbsoluteRate('시간당 \$0.045 가 붙는다'), isTrue);
      expect(hasAbsoluteRate('리전마다 다릅니다'), isFalse);
      expect(hasRegionCaveat('리전마다 다릅니다'), isTrue);
      expect(hasRegionCaveat('단가는 \$0.045 입니다'), isFalse);
    });
  });

  // ═══════════════ §4-6 — 교차 AZ 는 각 방향이다 ═══════════════

  test('§4-6 q5 가 교차 AZ 과금을 「각 방향」으로 적고 근거를 단다', () {
    final q = question('saa-t4-4', 'saa-t4-4-q5');
    final b = blob(q);
    expect(RegExp(r'각\s*방향|양방향').hasMatch(b), isTrue,
        reason: '공식은 \$0.01/GB each way 로 적는다');
    expect(
      urls(q).any((u) => u.contains('network-cost-reduction')),
      isTrue,
      reason: 'q15 가 같은 사실에 쓰는 출처다 — each way 가 적힌 유일한 산문 페이지',
    );
  });

  // ═══════════════ §4-7 — 두 터널은 고가용성이다 ═══════════════

  group('§4-7 두 터널에 「부하 분산」을 붙이지 않는다', () {
    test('saa-t3-8-q4 에서 무조건부 부하 분산 서술이 사라졌다', () {
      final b = blob(question('saa-t3-8', 'saa-t3-8-q4'));
      expect(b.contains('부하 분산도 가능'), isFalse);
      expect(b.contains('고가용성'), isTrue);
      expect(b.contains('ECMP'), isTrue, reason: '묶는 조건을 함께 가르친다');
      expect(b.contains('Transit Gateway'), isTrue);
      expect(RegExp(r'동적\s*라우팅').hasMatch(b), isTrue,
          reason: '정적 라우팅에서는 ECMP 가 지원되지 않는다');
    });

    test('대조군: 학습문서는 이미 그 조건을 정확히 적는다', () {
      final md = doc('saa-t3-8');
      expect(md.contains('ECMP는 Transit Gateway에 종단한 VPN 연결에서만'), isTrue,
          reason: 'md 가 옳았고 문항만 거칠었다 — 이 전제가 사라지면 배치의 '
              '판단 근거가 사라진다');
    });

    test('전수: SAA 어느 문항도 두 터널을 부하 분산으로 적지 않는다', () {
      final offenders = <String>[];
      var scanned = 0;
      for (final f in Directory('$content/saa')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.questions.json'))) {
        for (final q in questionsOf(f)) {
          final b = blob(q);
          if (!b.contains('터널')) continue;
          scanned++;
          if (RegExp(r'부하\s*분산').hasMatch(b) && !b.contains('ECMP')) {
            offenders.add(q['id'] as String);
          }
        }
      }
      expect(scanned, greaterThanOrEqualTo(3), reason: '대조군 — 비공허');
      expect(offenders, isEmpty,
          reason: '터널 간 부하 분산은 ECMP 조건을 적어야 성립한다: '
              '${offenders.join(' · ')}');
    });
  });

  // ═══════════════ §4-8 — 과도한 일반화 잔여 2건 ═══════════════

  group('§4-8 잔여 2건', () {
    test('saa-t1-3-q5: IP 차단이 NACL 전용으로 단정되지 않는다', () {
      final q = question('saa-t1-3', 'saa-t1-3-q5');
      final b = blob(q);
      expect(RegExp(r'반드시\s*NACL').hasMatch(b), isFalse);
      expect(b.contains('WAF'), isTrue,
          reason: 'IP set match statement 가 IP 기반 차단을 한다');
      expect(urls(q).any((u) => u.contains('waf-rule-statement-type-ipset-match')),
          isTrue);
      expect(answer(q).contains('NACL'), isTrue,
          reason: '보기 집합 안에서 NACL 이 정답인 것은 그대로다');
    });

    test('saa-t3-2.md: EBS AZ 이동의 「유일한 경로」가 볼륨으로 한정된다', () {
      final md = doc('saa-t3-2');
      expect(md.contains('스냅샷을 통한 복사가 유일한 경로'), isFalse);
      final line = md.split('\n').firstWhere(
            (l) => l.contains('스냅샷') && l.contains('AZ'),
            orElse: () => fail('EBS AZ 이동 서술이 없다'),
          );
      expect(line.contains('볼륨'), isTrue,
          reason: '볼륨 자체의 AZ 이동은 스냅샷 경유지만, 데이터는 인스턴스 간 '
              '네트워크 복사로도 옮길 수 있다');
    });
  });
}
