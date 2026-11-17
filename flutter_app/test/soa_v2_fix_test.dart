import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// SOA-C03 2단계 보정 가드 (2026-11-17 전 콘텐츠 검증).
///
/// 1단계 보고 `docs/audits/2026-11-17-full-verify/soa.md` 를 공식 문서로 다시 재서
/// 집행한 결과를 고정한다. 판정·근거 인용의 정본은 같은 폴더의 `soa-phase2.md`.
///
/// ## 이 가드가 보는 것
///
/// - 🔴 공개 문항 3건: `soa-t1-2-q3`(정답이 둘 — **Log Alarm** 이 공식 기능이 되어
///   오답 보기가 참이 됐다) · `soa-t1-5-q13`(정답이 수명이 끝난 제품 이름) ·
///   `soa-t4-3-q11`(해설의 이유가 거짓).
/// - 🔴 라이브 학습문서 3편: `soa-t5-3`(라우팅 정책 개수·Geoproximity) ·
///   `soa-t4-2`(Trusted Advisor 범주) · `soa-t3-2`(AMI 스냅샷 연동 삭제).
/// - 🟡 내용 17항목과 출처 교체(「URL 은 200인데 그 페이지에 그 사실이 없다」).
///
/// ## 설계 규율
///
/// - **사실 단정은 전수 집계형**이다(md 줄 전수 + 문항 전수). 문항별 리터럴은 어형
///   하나로 뚫린다 — 1단계 보고가 짚은 Y10 이 바로 그 사례다(기존 탐지기는
///   「상태 **확인**」·「해야」만 봐서 「상태 **점검**」·「통해서만」이 샜다).
/// - **옛 문구 0건 + 새 공식 사실 있음**을 쌍으로 단정한다.
/// - **`verified` 상태를 단정하지 않는다.** 구조 단정(보기 4개 · Task 당 15문항 ·
///   정답 인덱스 불변)으로 대신한다.
/// - **`lastVerified` 날짜를 단정하지 않는다** — 그 고정은 `soa_facts_test` 와
///   `soa_v11_topics_test` 의 맵이 한다.
/// - 탐지기는 함수로 빼고 **양방향 대조군**(옛 문장은 잡고 정정문은 통과)을 붙였다.
/// - ⚠️ **오답 보기는 사실 층이 아니다.** 일부러 틀린 서술이므로 `fact()` 는 오답
///   보기를 뺀다(「DX 는 즉시 구축되고 VPN 은 수 주」 같은 보기가 그대로 남는다).
/// - ⚠️ **상태 메모는 가르치는 층에만 요구한다**(`taught()` — skill·지문·정답 보기·
///   해설). 오답 근거에만 나오는 이름에 상태를 요구하면 그 상태가 그 보기를
///   틀리게 만든 이유처럼 읽힌다.
void main() {
  const dir = 'assets/content/soa';

  List<File> files(String ext) => Directory(dir)
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith(ext))
      .toList()
    // ⚠️ `listSync()` 순서는 플랫폼마다 다르다.
    ..sort((a, b) => a.path.compareTo(b.path));

  String stem(File f, String ext) =>
      f.uri.pathSegments.last.replaceAll(ext, '');

  final docs = <String, String>{
    for (final f in files('.md')) stem(f, '.md'): f.readAsStringSync(),
  };

  final byTask = <String, List<Map<String, dynamic>>>{
    for (final f in files('.questions.json'))
      stem(f, '.questions.json'):
          ((json.decode(f.readAsStringSync()) as Map<String, dynamic>)['questions']
                  as List)
              .cast<Map<String, dynamic>>(),
  };
  final questions = [for (final qs in byTask.values) ...qs];

  Map<String, dynamic> q(String id) => questions
      .firstWhere((e) => e['id'] == id, orElse: () => fail('$id 없음'));

  String correctOpt(Map<String, dynamic> e) =>
      (e['options'] as List)[e['correct'] as int] as String;

  List<String> wrongOpts(Map<String, dynamic> e) => [
        for (var i = 0; i < (e['options'] as List).length; i++)
          if (i != e['correct']) (e['options'] as List)[i] as String,
      ];

  String expl(Map<String, dynamic> e) => e['explanation'] as String;

  String wrong(Map<String, dynamic> e, String k) =>
      (e['wrongExplanations'] as Map<String, dynamic>)[k] as String;

  /// 가르치는 층 — skill · 지문 · 정답 보기 · 해설.
  String taught(Map<String, dynamic> e) =>
      [e['skill'], e['stem'], correctOpt(e), expl(e)].join('\n');

  /// 사실 층 — 가르치는 층 + 오답 근거(오답 **보기**는 뺀다).
  String fact(Map<String, dynamic> e) => [
        taught(e),
        ...(e['wrongExplanations'] as Map<String, dynamic>).values,
      ].join('\n');

  String all(Map<String, dynamic> e) => json.encode(e);

  List<String> urls(Map<String, dynamic> e) => [
        for (final s in (e['sources'] as List).cast<Map<String, dynamic>>())
          s['url'] as String,
      ];

  /// md 줄 전수에서 탐지기에 걸리는 `문서:줄` 목록.
  List<String> mdOffenders(bool Function(String) hit) => [
        for (final d in docs.entries)
          for (final (i, line) in d.value.split('\n').indexed)
            if (hit(line)) '${d.key}.md:${i + 1}',
      ];

  /// 문항 전수에서 탐지기에 걸리는 id 목록.
  List<String> qOffenders(
    bool Function(String) hit,
    String Function(Map<String, dynamic>) layer,
  ) =>
      [
        for (final e in questions)
          if (hit(layer(e))) e['id'] as String,
      ];

  // ───────────────────────── 탐지기 ─────────────────────────

  /// R2 — 수명이 끝난 이름을 **현행 이름 없이** 든다.
  bool perfInsightsAlone(String t) =>
      RegExp(r'Performance Insights|성능 개선 도우미').hasMatch(t) &&
      !t.contains('Database Insights');

  /// R4 — Geoproximity 를 Traffic Flow 전용으로 묶는다. 공식은 레코드 생성 시
  /// 고르는 정책으로 적고 Traffic Flow 전용인 것은 **지도**뿐이다.
  bool geoproximityTrafficFlowOnly(String t) =>
      RegExp(r'Geoproximity|지리근접|bias').hasMatch(t) &&
      t.contains('Traffic Flow') &&
      !t.contains('지도');

  /// Y3 — Secrets Manager 교체를 Lambda 한 가지로만 적는다. 공식은 형태를 둘로
  /// 적고 관리형 교체는 Lambda 함수를 쓰지 않는다.
  bool rotationLambdaOnly(String t) =>
      RegExp(r'Secrets Manager|시크릿|교체').hasMatch(t) &&
      RegExp(r'Lambda 기반|Lambda로 수행|내장 Lambda|Lambda를 통해 구현|'
              r'Lambda 로테이터|Lambda로 이를 위임')
          .hasMatch(t);

  /// Y5 — API Gateway 를 한정 없이 「같은 리전」에 묶는다(엣지 최적화는 us-east-1).
  bool apiGatewaySameRegionUnqualified(String t) =>
      RegExp(r'API\s*(Gateway|GW)[^.\n]{0,40}같은 리전').hasMatch(t) &&
      !t.contains('리전형');

  /// Y10 — 앱 장애 감지를 ELB 상태 확인에 독점시킨다. 기존
  /// `soa_p2_review_fix_test` 탐지기가 못 본 두 어형(「상태 **점검**」·「통해서만」)을
  /// 더했다. 공식의 다른 경로를 함께 적으면 배타 단정이 아니다.
  bool elbExclusiveExt(String t) {
    if (!RegExp(r'ELB[^.\n]{0,12}상태 (확인|점검)').hasMatch(t)) return false;
    if (!t.contains('앱') && !t.contains('애플리케이션')) return false;
    if (!RegExp(r'통해서만|해야|유일한').hasMatch(t)) return false;
    return !(t.contains('사용자 정의 상태 확인') ||
        t.contains('SetInstanceHealth'));
  }

  /// Y6 — 무효화의 문제를 「전체 무효화는 비용이 크다」로 적는다. 공식 과금은 월
  /// 1,000경로 초과분이고 `/*` 는 1경로다.
  bool invalidationCostMyth(String t) => RegExp(
          r'전체 무효화[^.\n]{0,30}(비용|부하)|무효화[^.\n]{0,12}비용이 적')
      .hasMatch(t);

  // ═════════════════════════ 대조군·구조 ═════════════════════════

  group('대조군·구조', () {
    test('콘텐츠 파일이 읽혔다 — md 20편 · 문항 20파일 · 300문항', () {
      expect(docs.length, 20);
      expect(byTask.length, 20);
      expect(questions.length, 300);
      for (final d in docs.entries) {
        // ⚠️ `String.length` 는 문자 수다(바이트가 아니다).
        expect(d.value.length, greaterThan(5000), reason: '${d.key} 가 너무 짧다');
      }
    });

    test('구조 — Task 당 15문항 · 보기 4개 · 오답 근거 키가 오답 인덱스와 같다', () {
      for (final t in byTask.entries) {
        expect(t.value.length, 15, reason: t.key);
        for (final e in t.value) {
          final n = (e['options'] as List).length;
          expect(n, 4, reason: e['id'] as String);
          expect((e['options'] as List).toSet().length, 4,
              reason: '${e['id']} 보기 중복');
          final keys = (e['wrongExplanations'] as Map).keys.toSet();
          final expected = {
            for (var i = 0; i < n; i++)
              if (i != e['correct']) '$i',
          };
          expect(keys, expected, reason: e['id'] as String);
        }
      }
    });

    test('손댄 72문항의 정답 인덱스가 불변이다', () {
      // 2026-11-17 실측값(파일에서 덤프했다 — 추측하지 않았다).
      const correct = <String, int>{
        'soa-t1-1-q2': 0, 'soa-t1-1-q3': 0, 'soa-t1-1-q4': 0,
        'soa-t1-1-q10': 0, 'soa-t1-1-q13': 0, 'soa-t1-2-q3': 0,
        'soa-t1-2-q9': 0, 'soa-t1-2-q10': 1, 'soa-t1-2-q11': 1,
        'soa-t1-2-q12': 0, 'soa-t1-2-q13': 1, 'soa-t1-3-q6': 0,
        'soa-t1-3-q8': 0, 'soa-t1-3-q9': 1, 'soa-t1-3-q11': 0,
        'soa-t1-4-q2': 1, 'soa-t1-5-q12': 0, 'soa-t1-5-q13': 0,
        'soa-t2-1-q5': 0, 'soa-t2-1-q7': 0, 'soa-t2-1-q11': 0,
        'soa-t2-2-q1': 1, 'soa-t2-2-q2': 0, 'soa-t2-2-q4': 0,
        'soa-t2-2-q5': 0, 'soa-t2-2-q10': 0, 'soa-t2-2-q11': 0,
        'soa-t2-2-q13': 0, 'soa-t2-2-q14': 0, 'soa-t2-3-q4': 0,
        'soa-t2-3-q6': 0, 'soa-t2-3-q8': 1, 'soa-t2-3-q13': 0,
        'soa-t2-3-q14': 0, 'soa-t3-2-q1': 0, 'soa-t3-2-q9': 0,
        'soa-t3-2-q10': 0, 'soa-t3-2-q12': 0, 'soa-t3-2-q13': 0,
        'soa-t3-2-q14': 0, 'soa-t3-3-q3': 0, 'soa-t3-3-q8': 0,
        'soa-t3-4-q1': 0, 'soa-t3-4-q5': 0, 'soa-t4-1-q6': 0,
        'soa-t4-1-q10': 0, 'soa-t4-2-q3': 0, 'soa-t4-2-q4': 0,
        'soa-t4-2-q5': 0, 'soa-t4-2-q12': 3, 'soa-t4-3-q4': 0,
        'soa-t4-3-q10': 0, 'soa-t4-3-q11': 0, 'soa-t4-3-q12': 0,
        'soa-t4-3-q13': 0, 'soa-t5-1-q3': 0, 'soa-t5-1-q7': 0,
        'soa-t5-1-q9': 0, 'soa-t5-1-q13': 0, 'soa-t5-1-q14': 0,
        'soa-t5-2-q15': 0, 'soa-t5-3-q1': 0, 'soa-t5-3-q2': 0,
        'soa-t5-3-q4': 0, 'soa-t5-3-q9': 0, 'soa-t5-3-q11': 0,
        'soa-t5-3-q13': 0, 'soa-t5-3-q15': 0, 'soa-t5-4-q2': 0,
        'soa-t5-4-q5': 0, 'soa-t5-4-q9': 0, 'soa-t5-4-q15': 0,
      };
      expect(correct.length, 72);
      correct.forEach((id, c) => expect(q(id)['correct'], c, reason: id));
    });

    test('탐지기 대조군 — 옛 문장은 잡고 정정문은 통과한다', () {
      expect(perfInsightsAlone('| **Performance Insights** | DB 부하를'), isTrue);
      expect(
          perfInsightsAlone(
              '| **CloudWatch Database Insights**(구 성능 개선 도우미·Performance Insights) |'),
          isFalse);

      expect(
          geoproximityTrafficFlowOnly(
              '> **Geoproximity**는 **Route 53 Traffic Flow** 에서만 사용하며'),
          isTrue);
      expect(
          geoproximityTrafficFlowOnly(
              'Geoproximity 는 레코드 생성 시 고르는 정책이다. Traffic Flow에서만 제공되는 것은 지도다'),
          isFalse);

      expect(rotationLambdaOnly('Secrets Manager — Lambda 기반 교체를 내장 지원'),
          isTrue);
      expect(
          rotationLambdaOnly(
              '서비스가 관리하는 시크릿은 Lambda 함수를 쓰지 않는 관리형 교체로'),
          isFalse);

      expect(apiGatewaySameRegionUnqualified('ALB·NLB·API Gateway는 리소스와 같은 리전'),
          isTrue);
      expect(
          apiGatewaySameRegionUnqualified(
              'ALB·NLB·리전형 API Gateway는 리소스와 같은 리전'),
          isFalse);

      expect(
          elbExclusiveExt('앱 계층 장애는 ELB 상태 확인을 통해서만 ASG에 전달된다'), isTrue);
      expect(
          elbExclusiveExt(
              '애플리케이션 수준 장애로 교체하려면 **ELB 상태 점검**을 ASG에 연결해야 합니다'),
          isTrue);
      expect(
          elbExclusiveExt(
              '앱 계층 장애는 ELB 상태 확인(가장 일반적)이나 사용자 정의 상태 확인 같은 추가 소스로'),
          isFalse);

      expect(invalidationCostMyth('잦은 전체 무효화는 비용·부하가 크므로'), isTrue);
      expect(invalidationCostMyth('무효화는 월 1,000개 경로까지 무료이고'), isFalse);
    });
  });

  // ═════════════════════════ 🔴 R1~R6 ═════════════════════════

  group('R1 로그 경보 — Log Alarm 이 두 번째 공식 경로다', () {
    // Alarm-On-Logs.html: "You can create CloudWatch alarms that monitor your log
    // data in two ways: Log Alarm approach — … runs a CloudWatch Logs Insights
    // query on a schedule and evaluates the aggregated results directly against
    // a threshold. Metric filter approach — …"
    test('전수: 「쿼리 결과에 경보를 걸 수 없다」는 단정이 없다', () {
      final pat = RegExp(r'직접 경보를 거는 방식이 아닙|로그 기반 경보는 지표 필터를 사용');
      expect(mdOffenders(pat.hasMatch), isEmpty);
      expect(qOffenders(pat.hasMatch, all), isEmpty);
    });

    test('전수: Logs Insights 쿼리 경보를 오답 보기로 두지 않는다(이제 참이다)', () {
      final offenders = [
        for (final e in questions)
          for (final o in wrongOpts(e))
            if (o.contains('Logs Insights') && o.contains('경보')) e['id'],
      ];
      expect(offenders, isEmpty, reason: '참인 보기를 오답으로 두면 정답이 둘이 된다');
    });

    test('soa-t1-2-q3 · soa-t1-2.md 가 두 경로를 가르친다', () {
      final e = q('soa-t1-2-q3');
      expect(correctOpt(e).contains('지표 필터'), isTrue);
      expect(expl(e).contains('Log Alarm'), isTrue);
      expect(urls(e).any((u) => u.endsWith('monitoring/Alarm-On-Logs.html')),
          isTrue);
      final d = docs['soa-t1-2']!;
      expect('Log Alarm'.allMatches(d).length, greaterThanOrEqualTo(3));
      expect(d.contains('monitoring/Alarm-On-Logs.html'), isTrue);
    });
  });

  group('R2 Performance Insights 는 수명이 끝났다 — Database Insights 병기', () {
    // Database-Insights.html: "AWS announced that the end-of-life date for
    // Performance Insights was July 31, 2026, and has migrated Performance
    // Insights users to Database Insights."
    test('전수(md 줄 · 문항 가르치는 층): 옛 이름만 드는 자리가 없다', () {
      expect(mdOffenders(perfInsightsAlone), isEmpty);
      expect(qOffenders(perfInsightsAlone, taught), isEmpty);
    });

    test('soa-t1-5-q13 · soa-t1-5.md 가 현행 이름과 상태를 적는다', () {
      final e = q('soa-t1-5-q13');
      expect(correctOpt(e).contains('Database Insights'), isTrue);
      // 공식 가이드(Task 1.3)가 아직 옛 이름을 쓰므로 지우지 않고 병기한다.
      expect(correctOpt(e).contains('Performance Insights'), isTrue);
      expect(expl(e).contains('2026-07-31'), isTrue);
      expect(urls(e).any((u) => u.endsWith('monitoring/Database-Insights.html')),
          isTrue);
      final d = docs['soa-t1-5']!;
      expect('Database Insights'.allMatches(d).length, greaterThanOrEqualTo(6));
      expect(d.contains('2026-07-31'), isTrue);
    });
  });

  group('R3 가져온 인증서 — 「개인 키가 ACM 밖」은 이유가 아니다', () {
    // import-certificate.html: "ACM does not provide managed renewal for imported
    // certificates. To renew an imported certificate, you can obtain a new
    // certificate from your certificate issuer and then manually reimport it"
    // import-certificate-prerequisites.html: "You must provide the private key"
    test('전수: 그 이유가 0건이다', () {
      final pat = RegExp(r'개인 키가 ACM (외부|밖)');
      expect(mdOffenders(pat.hasMatch), isEmpty);
      expect(qOffenders(pat.hasMatch, all), isEmpty);
    });

    test('soa-t4-3-q11 · soa-t4-3.md 가 공식 서술을 적는다', () {
      final e = q('soa-t4-3-q11');
      expect(expl(e).contains('관리형 갱신을 제공하지 않습니다'), isTrue);
      expect(expl(e).contains('다시 가져와야'), isTrue);
      final d = docs['soa-t4-3']!;
      expect(d.contains('관리형 갱신을 제공하지 않습니다'), isTrue);
      expect(d.contains('다시 가져와야'), isTrue);
    });
  });

  group('R4 Route 53 라우팅 정책 — 개수 단정과 Traffic Flow 전용 서술', () {
    // routing-policy.html 은 정책을 여덟 개 싣는다(IP-based 포함) + "You can use
    // geoproximity routing to create records in a private hosted zone."
    // routing-policy-geoproximity.html: "The maps are available only with Traffic Flow."
    test('전수: 「7종」이 없고 Geoproximity 를 Traffic Flow 전용으로 묶지 않는다', () {
      final seven = RegExp(r'라우팅(\s*정책)?\s*7종|정책 7종|7가지 라우팅');
      expect(mdOffenders(seven.hasMatch), isEmpty);
      expect(qOffenders(seven.hasMatch, all), isEmpty);
      expect(mdOffenders(geoproximityTrafficFlowOnly), isEmpty);
      expect(qOffenders(geoproximityTrafficFlowOnly, fact), isEmpty);
    });

    test('soa-t5-3.md 가 IP 기반 라우팅과 지도 한정을 적는다', () {
      final d = docs['soa-t5-3']!;
      expect('IP 기반'.allMatches(d).length, greaterThanOrEqualTo(3),
          reason: '체크리스트·표·시험 포인트');
      expect(d.contains('프라이빗 호스팅 영역에서도 사용 가능'), isTrue);
      // Traffic Flow 는 지우지 않았다 — 지도가 그 기능 전용이라는 사실로 남는다.
      expect(d.contains('Traffic Flow'), isTrue);
      expect(d.contains('지도'), isTrue);
    });
  });

  group('R5 Trusted Advisor 점검 범주는 다섯이 아니다', () {
    // trusted-advisor-check-reference.html: "Check categories: Cost optimization,
    // Performance, Security, Fault tolerance, Service limits, Operational Excellence"
    test('전수: 「5범주」류가 없다', () {
      final pat = RegExp(r'5\s*개?\s*범주|다섯\s*(개\s*)?범주');
      expect(mdOffenders(pat.hasMatch), isEmpty);
      expect(qOffenders(pat.hasMatch, all), isEmpty);
    });

    test('soa-t4-2.md · soa-t4-2-q12 가 운영 우수성을 든다', () {
      final d = docs['soa-t4-2']!;
      expect('운영 우수성'.allMatches(d).length, greaterThanOrEqualTo(3));
      final e = q('soa-t4-2-q12');
      expect(expl(e).contains('운영 우수성'), isTrue);
      // 정답 보기는 여섯 범주 어디에도 없는 것이라 그대로다.
      expect(correctOpt(e), '소스 코드 품질');
      // 여섯 범주 가운데 어느 것도 오답 보기 밖에서 「범주가 아니다」로 불리지 않는다.
      expect(wrongOpts(e).toSet(), {'비용 최적화', '보안', '내결함성'});
    });
  });

  group('R6 AMI 등록 해제 — 스냅샷을 함께 지우는 선택지가 있다', () {
    // deregister-ami.html: "When deregistering an AMI, you can optionally delete
    // its associated snapshots at the same time. However, if a snapshot is
    // associated with multiple AMIs, it won't be deleted even if specified"
    test('전수: 「연동 삭제 불가」 단정이 없다', () {
      final pat = RegExp(r'연동 삭제');
      expect(mdOffenders(pat.hasMatch), isEmpty);
      expect(qOffenders(pat.hasMatch, all), isEmpty);
    });

    test('soa-t3-2.md · soa-t3-2-q1 이 선택지와 한계를 적는다', () {
      final d = docs['soa-t3-2']!;
      expect('함께 삭제'.allMatches(d).length, greaterThanOrEqualTo(4));
      final e = q('soa-t3-2-q1');
      expect(expl(e).contains('함께 삭제하도록 선택'), isTrue);
      expect(expl(e).contains('여러 AMI가 참조하는 스냅샷'), isTrue);
      // 지문이 기본 동작으로 좁혀져야 정답 보기가 참이다.
      expect((e['stem'] as String).contains('스냅샷 삭제 옵션 없이'), isTrue);
    });
  });

  // ═════════════════════════ 🟡 상태·명칭 ═════════════════════════

  group('Y1 CloudTrail Lake — 신규 고객 제한 상태', () {
    // cloudtrail-lake.html: "AWS CloudTrail Lake will no longer be open to new
    // customers starting May 31, 2026. … Existing customers can continue to use
    // the service as normal."
    test('가르치는 층에서 Lake 를 드는 문항은 해설에 상태를 적는다', () {
      final teaching = [
        for (final e in questions)
          if (taught(e).contains('CloudTrail Lake')) e,
      ];
      expect(teaching, isNotEmpty);
      for (final e in teaching) {
        expect(expl(e).contains('신규 고객'), isTrue, reason: e['id'] as String);
      }
      // 대조군: 오답 층에만 나오는 문항이 실재한다 — 거기에는 요구하지 않는다.
      final wrongOnly = [
        for (final e in questions)
          if (!taught(e).contains('CloudTrail Lake') &&
              all(e).contains('CloudTrail Lake'))
            e['id'],
      ];
      expect(wrongOnly, isNotEmpty);
    });

    test('Lake 를 드는 학습문서는 상태를 적는다', () {
      final mentioning = [
        for (final d in docs.entries)
          if (d.value.contains('CloudTrail Lake')) d,
      ];
      expect(mentioning, isNotEmpty);
      for (final d in mentioning) {
        expect(d.value.contains('신규 고객'), isTrue, reason: d.key);
      }
    });
  });

  group('Y2 Security Hub — ASFF 를 쓰는 쪽의 현재 이름은 Security Hub CSPM', () {
    // what-is-securityhub.html: "Security Hub CSPM processes finding data using
    // the AWS Security Finding Format (ASFF)"
    test('가르치는 층에서 ASFF 를 드는 문항은 해설에 현재 이름을 적는다', () {
      final teaching = [
        for (final e in questions)
          if (taught(e).contains('ASFF')) e,
      ];
      expect(teaching.length, greaterThanOrEqualTo(2));
      for (final e in teaching) {
        expect(expl(e).contains('Security Hub CSPM'), isTrue,
            reason: e['id'] as String);
      }
    });

    test('soa-t4-2.md 가 현재 이름을 병기한다', () {
      final d = docs['soa-t4-2']!;
      expect('Security Hub CSPM'.allMatches(d).length, greaterThanOrEqualTo(3));
      // 공식 가이드(Task 4.2)가 「AWS Security Hub」로 적으므로 옛 이름도 남는다.
      expect(d.contains('### 2) Security Hub — 보안 표준·통합 결과·점수'), isTrue);
    });
  });

  group('Y3 Secrets Manager 교체 — Lambda 가 유일한 형태가 아니다', () {
    // rotating-secrets.html: "Managed rotation – … Managed rotation doesn't use a
    // Lambda function." / "Rotation by Lambda function – For other types of secrets"
    test('전수: Lambda 한 가지로만 적는 자리가 없다', () {
      expect(mdOffenders(rotationLambdaOnly), isEmpty);
      expect(qOffenders(rotationLambdaOnly, fact), isEmpty);
    });

    test('두 형태가 문항과 문서에 선다', () {
      final e = q('soa-t4-3-q13');
      expect(correctOpt(e).startsWith('Secrets Manager'), isTrue);
      expect(expl(e).contains('관리형 교체'), isTrue);
      expect(expl(e).contains('Lambda 함수를 쓰지 않는'), isTrue);
      expect(docs['soa-t4-3']!.contains('Lambda 함수를 쓰지 않는 관리형 교체'), isTrue);
      expect(docs['soa-t3-3']!.contains('관리형 교체'), isTrue);
    });
  });

  group('Y4 ACM 관리형 갱신 — 「DNS 검증이면 완전 자동」에 조건이 붙는다', () {
    // dns-renewal-validation.html: "The certificate is currently in use by an AWS
    // service. All required ACM-provided DNS CNAME records … are present"
    test('전수: 조건 없는 「완전 자동」이 없다', () {
      // ⚠️ 「완전 자동」 낱말을 금지하지 않는다 — 지문이 「완전히 자동으로 이뤄지는
      // **조건**은?」으로 묻고 오답 근거가 「수동 승인 구성은 완전 자동이 아니다」로
      // 답하는 것은 정당하다(처음엔 낱말로 걸어 그 문항 자신이 걸렸다). 거짓은
      // **DNS 검증 하나로 충분하다**는 무조건 단정이다.
      final pat =
          RegExp(r'DNS 검증(이면|을 사용한 인증서는)[^.\n]{0,20}완전(히)? 자동');
      expect(pat.hasMatch('(DNS 검증이면 완전 자동)'), isTrue);
      expect(pat.hasMatch('DNS 검증을 사용한 인증서는 관리형 갱신이 완전히 자동화됩니다'), isTrue);
      expect(pat.hasMatch('ACM의 관리형 갱신이 완전히 자동으로 이뤄지는 조건은?'), isFalse);
      expect(mdOffenders(pat.hasMatch), isEmpty);
      expect(qOffenders(pat.hasMatch, fact), isEmpty);
    });

    test('soa-t4-3-q12 정답 보기가 두 조건을 담는다', () {
      final e = q('soa-t4-3-q12');
      expect(correctOpt(e).contains('AWS 서비스에서 사용 중'), isTrue);
      expect(correctOpt(e).contains('CNAME'), isTrue);
      expect(urls(e).any((u) => u.endsWith('acm/latest/userguide/managed-renewal.html')),
          isTrue);
    });
  });

  group('Y5 API Gateway 인증서 리전 — 엣지 최적화는 us-east-1', () {
    // how-to-edge-optimized-custom-domain-name.html: "You must request or import
    // a certificate for your edge-optimized custom domain name in the US East
    // (N. Virginia) – us-east-1 Region."
    test('전수: API Gateway 를 한정 없이 「같은 리전」에 묶지 않는다', () {
      expect(mdOffenders(apiGatewaySameRegionUnqualified), isEmpty);
      expect(qOffenders(apiGatewaySameRegionUnqualified, fact), isEmpty);
    });

    test('두 문항과 문서가 예외를 적는다', () {
      for (final id in ['soa-t4-3-q10', 'soa-t5-3-q13']) {
        final e = q(id);
        expect(expl(e).contains('엣지 최적화 API Gateway'), isTrue, reason: id);
        expect(
            urls(e).any((u) =>
                u.endsWith('how-to-edge-optimized-custom-domain-name.html')),
            isTrue,
            reason: id);
      }
      expect('엣지 최적화'.allMatches(docs['soa-t4-3']!).length,
          greaterThanOrEqualTo(3));
    });
  });

  group('Y6 CloudFront 무효화 — 과금은 경로 수, 권장 이유는 캐시 계층', () {
    // PayingForInvalidation.html: "The first 1,000 invalidation paths that you
    // submit per month are free … A path that includes the * wildcard counts as
    // one path"
    // Invalidation.html: "Versioning enables you to control which file a request
    // returns even when the user has a version cached either locally or behind
    // a corporate caching proxy."
    test('전수: 「전체 무효화는 비용이 크다」 서술이 없다', () {
      expect(mdOffenders(invalidationCostMyth), isEmpty);
      expect(qOffenders(invalidationCostMyth, fact), isEmpty);
    });

    test('soa-t5-3-q11 · soa-t5-3.md 가 공식 과금과 이유를 적는다', () {
      final e = q('soa-t5-3-q11');
      expect(correctOpt(e).contains('버전'), isTrue);
      expect(expl(e).contains('1,000'), isTrue);
      expect(expl(e).contains('브라우저'), isTrue);
      expect(urls(e).any((u) => u.endsWith('PayingForInvalidation.html')), isTrue);
      final d = docs['soa-t5-3']!;
      expect(d.contains('월 1,000개 경로까지 무료'), isTrue);
      expect(d.contains('1개 경로'), isTrue);
    });
  });

  group('Y7 패치 그룹 태그 키 — `Patch Group` 또는 `PatchGroup`', () {
    // patch-manager-tag-a-patch-group.html: "the tag key must be Patch Group or
    // PatchGroup. PatchGroup (without a space) is required if you have allowed
    // tags in EC2 instance metadata."
    test('전수: 한쪽 키만 드는 문서·문항이 없다', () {
      for (final d in docs.entries) {
        if (d.value.contains('`Patch Group`')) {
          expect(d.value.contains('`PatchGroup`'), isTrue, reason: d.key);
        }
      }
      final offenders = [
        for (final e in questions)
          if (taught(e).contains('`Patch Group`') &&
              !taught(e).contains('`PatchGroup`'))
            e['id'],
      ];
      expect(offenders, isEmpty);
      final exact = RegExp(r'공백·대소문자|정확히 `Patch Group`');
      expect(mdOffenders(exact.hasMatch), isEmpty);
      expect(qOffenders(exact.hasMatch, all), isEmpty);
    });

    test('대조군: 두 키를 가르치는 문서 2편 · 문항 2개가 실재한다', () {
      expect(
          docs.values.where((d) => d.contains('`PatchGroup`')).length,
          greaterThanOrEqualTo(2));
      expect(
          questions.where((e) => taught(e).contains('`PatchGroup`')).length,
          greaterThanOrEqualTo(2));
      // 패치 정책 기반 운영의 예외도 함께 선다.
      expect(expl(q('soa-t3-3-q8')).contains('패치 정책'), isTrue);
      expect(docs['soa-t3-3']!.contains('패치 정책(patch policy)'), isTrue);
    });
  });

  // ═════════════════════════ 🟡 Auto Scaling ═════════════════════════

  group('Y8~Y10·Y12 Auto Scaling', () {
    test('Y8 유예 기간 기본값 — 콘솔 300초와 CLI/SDK 0초를 함께 적는다', () {
      // health-check-grace-period.html: "In the console, by default, the health
      // check grace period is 300 seconds … Its default value is 0 seconds when
      // you create an Auto Scaling group using the AWS CLI or an SDK."
      bool alone(String t) =>
          t.contains('유예') &&
          RegExp(r'기본\s*300초').hasMatch(t) &&
          !RegExp(r'기본\s*0초').hasMatch(t);
      expect(mdOffenders(alone), isEmpty);
      expect(qOffenders(alone, fact), isEmpty);
      expect(expl(q('soa-t2-1-q11')).contains('기본 0초'), isTrue);
      expect(docs['soa-t2-1']!.contains('CLI/SDK 기본 0초'), isTrue);
    });

    test('Y9 예측 조정 — 「14일 이상」이 아니라 2주치·최근 최대 14일', () {
      // predictive-scaling-policy-overview.html: "at least 24 hours of data …
      // analyzing metric data from up to the past 14 days" + "forecasts are more
      // effective if historical data spans two full weeks"
      final pat = RegExp(r'14일 이상');
      expect(mdOffenders(pat.hasMatch), isEmpty);
      expect(qOffenders(pat.hasMatch, fact), isEmpty);
      final e = q('soa-t2-1-q5');
      expect(expl(e).contains('2주치'), isTrue);
      expect(expl(e).contains('최대 14일'), isTrue);
      expect(
          urls(e).any((u) => u.endsWith('predictive-scaling-policy-overview.html')),
          isTrue);
    });

    test('Y10 전수: ELB 상태 확인·점검을 앱 장애의 배타 경로로 적지 않는다', () {
      // ec2-auto-scaling-health-checks.html 의 다섯 소스: Amazon EC2 · Elastic
      // Load Balancing · VPC Lattice · Amazon EBS · Custom health checks.
      expect(mdOffenders(elbExclusiveExt), isEmpty);
      expect(qOffenders(elbExclusiveExt, fact), isEmpty);
      final dichotomy =
          RegExp(r'EC2 상태 (점검|확인)\*{0,2}\s*또는\s*\*{0,2}ELB 상태 (점검|확인)');
      expect(mdOffenders(dichotomy.hasMatch), isEmpty);
      // 「상태 점검」 어형을 쓰는 문서에도 다른 경로가 선다.
      expect('사용자 정의 상태 확인'.allMatches(docs['soa-t3-4']!).length,
          greaterThanOrEqualTo(4));
    });

    test('Y12 워밍업은 상태 확인을 미루는 설정이 아니다', () {
      // ec2-auto-scaling-default-instance-warmup.html: "how long after an instance
      // reaches the InService state it waits before contributing usage data to
      // the aggregated metrics" — 상태 확인 보류는 유예 기간의 역할이다.
      bool hit(String t) => t.contains('워밍업') && t.contains('지표 집계·상태 확인');
      expect(mdOffenders(hit), isEmpty);
      expect(qOffenders(hit, fact), isEmpty);
      expect(wrong(q('soa-t2-1-q7'), '1').contains('집계 지표'), isTrue);
    });
  });

  // ═════════════════════════ 🟡 네트워킹·그 밖 ═════════════════════════

  group('Y11 Flow Logs REJECT — 문서 안 잔여', () {
    // flow-log-records.html: "REJECT — The traffic was rejected. For example, the
    // traffic was not allowed by the security groups or network ACLs, or packets
    // arrived after the connection was closed."
    test('전수: REJECT 를 NACL 한 계층에 묶는 서술이 없다', () {
      final pat = RegExp(
          r'NACL에 의해 거부된|SG 인바운드를 의심|REJECT\*{0,2}\s*=\s*\*{0,2}NACL');
      expect(mdOffenders(pat.hasMatch), isEmpty);
      expect(qOffenders(pat.hasMatch, fact), isEmpty);
      expect(
          '보안 그룹 또는 네트워크 ACL이 허용하지 않은'.allMatches(docs['soa-t5-4']!).length,
          greaterThanOrEqualTo(4));
    });
  });

  group('Y12 오답 근거 — 회피형 반박과 경계 서술', () {
    test('전수: 오답 근거가 「핵심이 아니다」로 참·거짓을 피하지 않는다', () {
      final dodge = RegExp(r'핵심(이| 차이는)?\s*아닙니다|핵심이 아니');
      final offenders = [
        for (final e in questions)
          for (final w in (e['wrongExplanations'] as Map).entries)
            if (dodge.hasMatch(w.value as String)) '${e['id']}#${w.key}',
      ];
      expect(offenders, isEmpty);
    });

    test('세 오답 근거가 공식 사실을 적는다', () {
      // resource-record-sets-choosing-alias-non-alias.html: "If an alias record
      // points to an AWS resource, you can't set the time to live (TTL)"
      expect(wrong(q('soa-t5-3-q4'), '2').contains('설정할 수 없습니다'), isTrue);
      // access_policies_boundaries.html: "resource-based policies that grant
      // permissions to an IAM user ARN … are not limited by an implicit deny in
      // an identity-based policy or permissions boundary."
      expect(wrong(q('soa-t4-1-q6'), '2').contains('IAM 사용자 ARN'), isTrue);
      expect(wrong(q('soa-t4-1-q6'), '2').contains('합집합 평가 대상이 아닙니다'), isFalse);
    });
  });

  group('Y13 Config 규칙 트리거', () {
    // evaluate-config_components.html: Configuration changes / Periodic / Hybrid.
    test('전수: 「다음 평가 주기에 반드시 포착」이 없고 트리거 유형이 선다', () {
      final pat = RegExp(r'반드시 포착');
      expect(mdOffenders(pat.hasMatch), isEmpty);
      expect(qOffenders(pat.hasMatch, all), isEmpty);
      final e = q('soa-t4-2-q3');
      expect(correctOpt(e).contains('변경 트리거'), isTrue);
      expect(expl(e).contains('하이브리드'), isTrue);
    });
  });

  group('Y14 Direct Connect 구축 기간 — 확인되지 않은 수치를 걷었다', () {
    test('전수(md 줄 · 사실 층): DX 「수 주」가 없다', () {
      bool hit(String t) =>
          RegExp(r'Direct Connect|DX').hasMatch(t) && RegExp(r'수\s*주').hasMatch(t);
      expect(mdOffenders(hit), isEmpty);
      expect(
          mdOffenders((t) => RegExp(r'\*\*수\s*주').hasMatch(t)), isEmpty);
      expect(qOffenders(hit, fact), isEmpty);
      // 대조군: 오답 보기의 거짓 서술은 그대로 남는다(사실 층이 아니다).
      expect(wrongOpts(q('soa-t5-2-q15')).any((o) => o.contains('수 주')), isTrue);
      // VPN 쪽 수치는 공식에 있다 — SetUpVPNConnections.html "It might take a few
      // minutes to create the VPN connection".
      expect(urls(q('soa-t5-2-q15')).any((u) => u.endsWith('SetUpVPNConnections.html')),
          isTrue);
    });
  });

  group('Y15 EventBridge 예약 규칙 — Scheduler 권장을 문항에도 적는다', () {
    // eb-create-rule-schedule.html 이 예약 규칙을 legacy 로 적고 EventBridge
    // Scheduler 를 권장한다(md `soa-t3-4` 는 이미 적고 있었다 — 역방향 잔존).
    test('가르치는 층에서 스케줄 규칙을 드는 문항은 해설에 Scheduler 를 적는다', () {
      final teaching = [
        for (final e in questions)
          if (taught(e).contains('EventBridge') &&
              RegExp(r'스케줄 규칙|스케줄 표현식|예약 규칙|cron').hasMatch(taught(e)))
            e,
      ];
      expect(teaching.length, greaterThanOrEqualTo(4));
      for (final e in teaching) {
        expect(expl(e).contains('EventBridge Scheduler'), isTrue,
            reason: e['id'] as String);
      }
    });

    test('스케줄 규칙을 가르치는 두 문서가 Scheduler 를 적는다', () {
      for (final id in ['soa-t1-3', 'soa-t3-4']) {
        expect(docs[id]!.contains('EventBridge Scheduler'), isTrue, reason: id);
      }
    });
  });

  group('Y16·Y17 VPC', () {
    test('Y16 프라이빗 DNS 요건 — 두 속성을 함께 적는다', () {
      // hosted-zone-private-considerations.html: "you must set the following
      // Amazon VPC settings to true: enableDnsHostnames, enableDnsSupport"
      bool half(String t) =>
          t.contains('켜져 있어야') &&
          t.contains('enableDnsSupport') &&
          !t.contains('enableDnsHostnames');
      expect(mdOffenders(half), isEmpty);
      expect(docs['soa-t5-1']!.contains('enableDnsSupport와 enableDnsHostnames가 둘 다'),
          isTrue);
    });

    test('Y17 로컬 경로 — 확인되지 않은 「삭제 불가」를 걷었다', () {
      // subnet-route-tables.html: "Every route table contains a local route for
      // communication within the VPC. This route is added by default to all
      // route tables. … You can replace or restore the target of each local route"
      bool hit(String t) =>
          t.contains('로컬') && RegExp(r'삭제할 수 없|삭제 불가').hasMatch(t);
      expect(mdOffenders(hit), isEmpty);
      expect(qOffenders(hit, all), isEmpty);
      final e = q('soa-t5-1-q14');
      expect(correctOpt(e).contains('모든 라우팅 테이블에 기본으로 포함'), isTrue);
      expect(expl(e).contains('되돌릴 수 있습니다'), isTrue);
      expect(urls(e).any((u) => u.endsWith('userguide/subnet-route-tables.html')),
          isTrue);
    });
  });

  group('고해상도 경보 주기 — 공식 두 페이지가 달라 개수를 못박지 않는다', () {
    // cloudwatch_concepts.html: "10 seconds or 30 seconds" ↔ alarm-evaluation.html:
    // "10 seconds, 20 seconds, or 30 seconds".
    test('전수: 「10초 또는 30초」 단정이 없다', () {
      final pat = RegExp(r'10초 또는 30초');
      expect(mdOffenders(pat.hasMatch), isEmpty);
      expect(qOffenders(pat.hasMatch, fact), isEmpty);
      expect(expl(q('soa-t1-1-q3')).contains('60초 미만'), isTrue);
      expect('60초 미만'.allMatches(docs['soa-t1-1']!).length, greaterThanOrEqualTo(2));
    });
  });

  // ═════════════════════════ 출처 ═════════════════════════

  group('Y19 출처 — 그 페이지가 그 사실을 담는다', () {
    test('문항별: 새 출처가 있고 사실을 담지 않던 옛 출처가 없다', () {
      // [문항, 있어야 하는 URL 끝, (없어야 하는 URL 끝)]
      const rows = <List<String?>>[
        ['soa-t1-1-q3', 'monitoring/alarm-evaluation.html', 'working_with_metrics.html'],
        ['soa-t1-2-q9', 'CWL_AnalyzeLogData-discoverable-fields.html', 'CWL_QuerySyntax.html'],
        ['soa-t1-2-q10', 'metrics-collected-by-CloudWatch-agent.html', 'install-CloudWatch-Agent-on-EC2-Instance.html'],
        ['soa-t1-2-q13', 'metrics-collected-by-CloudWatch-agent.html', 'install-CloudWatch-Agent-on-EC2-Instance.html'],
        ['soa-t1-2-q11', 'installing-cloudwatch-agent-ssm.html', null],
        ['soa-t1-2-q12', 'installing-cloudwatch-agent-ssm.html', null],
        ['soa-t1-3-q11', 'docs.aws.amazon.com/cloudwatch/', 'eb-what-is.html'],
        ['soa-t1-4-q2', 'getting-started-health-dashboard.html', null],
        ['soa-t1-5-q12', 'Concepts.MultiAZSingleStandby.html', null],
        ['soa-t2-2-q1', 'Concepts.MultiAZSingleStandby.html', null],
        ['soa-t2-2-q4', 'Concepts.MultiAZSingleStandby.html', null],
        ['soa-t2-2-q14', 'Concepts.MultiAZSingleStandby.html', null],
        ['soa-t2-2-q13', 'Concepts.MultiAZSingleStandby.html', null],
        ['soa-t2-2-q2', 'Concepts.MultiAZ.Failover.html', 'UserGuide/Concepts.MultiAZ.html'],
        ['soa-t2-2-q5', 'using-regions-availability-zones.html', null],
        ['soa-t2-2-q10', 'resource-record-sets-values-failover.html', null],
        ['soa-t2-2-q11', 'health-checks-creating-values.html', null],
        ['soa-t2-1-q5', 'predictive-scaling-policy-overview.html', 'ec2-auto-scaling-predictive-scaling.html'],
        ['soa-t2-3-q8', 'USER_WorkingWithAutomatedBackups.BackupRetention.html', 'UserGuide/USER_WorkingWithAutomatedBackups.html'],
        ['soa-t2-3-q13', 'replication-requirements.html', 'userguide/replication.html'],
        ['soa-t2-3-q14', 'intro-lifecycle-rules.html', null],
        ['soa-t3-2-q9', 'patch-manager-predefined-and-custom-patch-baselines.html', 'patch-manager-patch-baselines.html'],
        ['soa-t3-2-q12', 'update-bluegreen-to-rolling.html', null],
        ['soa-t3-2-q12', 'overview-deployment-options/rolling-deployments.html', null],
        ['soa-t3-2-q13', 'blue-green-deployments/introduction.html', 'blue-green-deployments/welcome.html'],
        ['soa-t3-2-q14', 'blue-green-deployments/introduction.html', 'blue-green-deployments/welcome.html'],
        ['soa-t3-3-q3', 'send-commands-multiple.html', null],
        ['soa-t4-1-q10', 'reference_policies_condition-keys.html', null],
        ['soa-t4-3-q4', 'kms-cryptography.html', 'developerguide/concepts.html'],
        ['soa-t5-1-q3', 'route-tables-priority.html', 'VPC_Route_Tables.html'],
        ['soa-t5-1-q7', 'work-with-nat-instances.html', 'VPC_NAT_Instance.html'],
        ['soa-t5-1-q9', 'custom-network-acl.html', null],
        ['soa-t5-4-q9', 'custom-network-acl.html', null],
        ['soa-t5-1-q13', 'AmazonDNS-concepts.html', 'vpc-dns.html'],
        ['soa-t5-1-q14', 'subnet-route-tables.html', 'VPC_Route_Tables.html'],
        ['soa-t5-3-q1', 'hosted-zone-private-considerations.html', 'hosted-zones-private.html'],
        ['soa-t5-3-q2', 'hosted-zone-private-considerations.html', 'hosted-zones-private.html'],
        ['soa-t5-3-q9', 'DownloadDistValuesCacheBehavior.html', 'distribution-web-values-specify.html'],
        ['soa-t5-3-q15', 'introduction-components.html', null],
        ['soa-t5-4-q2', 'flow-logs-basics.html', 'userguide/flow-logs.html'],
        ['soa-t5-4-q15', 'flow-logs-athena.html', null],
      ];
      final missing = <String>[];
      final lingering = <String>[];
      for (final r in rows) {
        final u = urls(q(r[0]!));
        if (!u.any((x) => x.endsWith(r[1]!))) missing.add('${r[0]} ← ${r[1]}');
        if (r[2] != null && u.any((x) => x.endsWith(r[2]!))) {
          lingering.add('${r[0]} ↛ ${r[2]}');
        }
      }
      expect(missing, isEmpty, reason: '사실을 담는 출처가 빠졌다');
      expect(lingering, isEmpty, reason: '사실을 담지 않는 출처가 남았다');
    });

    test('전수: 지표 허브로 바뀐 `working_with_metrics.html` 을 출처로 쓰지 않는다', () {
      // 그 페이지는 OpenTelemetry 지표 비교 허브가 됐다(보존·기간·차원 서술 0건).
      final users = [
        for (final e in questions)
          if (urls(e).any((u) => u.endsWith('working_with_metrics.html'))) e['id'],
      ];
      expect(users, isEmpty);
      // 대조군: 그 다섯 문항은 출처를 잃지 않았다(첫째 출처가 사실을 담는다).
      for (final id in [
        'soa-t1-1-q2', 'soa-t1-1-q3', 'soa-t1-1-q4', 'soa-t1-1-q10', 'soa-t1-1-q13',
      ]) {
        expect(urls(q(id)), isNotEmpty, reason: id);
      }
    });

    test('전수: 출처는 전부 docs.aws.amazon.com 이고 문항 안에서 중복되지 않는다', () {
      for (final e in questions) {
        final u = urls(e);
        expect(u, isNotEmpty, reason: e['id'] as String);
        expect(u.toSet().length, u.length, reason: '${e['id']} 출처 중복');
        for (final x in u) {
          expect(x.startsWith('https://docs.aws.amazon.com/'), isTrue,
              reason: '${e['id']} $x');
        }
      }
    });

    test('기각한 제안: `soa-t3-4-q2` 의 출처는 이미 그 사실을 담는다', () {
      // 1단계 보고는 「이벤트 이름 없음」이라 했지만 eb-event-patterns.html 본문에
      // "EC2 Instance State-change Notification" 과 "aws.ec2" 가 있다(실측 2건·3건).
      expect(urls(q('soa-t3-4-q2')).any((u) => u.endsWith('eb-event-patterns.html')),
          isTrue);
    });
  });

  // ═════════════════════════ 🟢 · 교차 자격증 ═════════════════════════

  group('표기·교차 자격증 메모', () {
    test('Vault Lock 용어 — 「콜드오프」가 아니라 쿨링오프(cooling-off)', () {
      // vault-lock.html: "the cooling-off period ("grace time")"
      final pat = RegExp(r'콜드오프');
      expect(mdOffenders(pat.hasMatch), isEmpty);
      expect(qOffenders(pat.hasMatch, all), isEmpty);
      expect(docs['soa-t2-3']!.contains('쿨링오프'), isTrue);
      expect(expl(q('soa-t2-3-q4')).contains('쿨링오프'), isTrue);
    });

    test('RDS 마그네틱 스토리지는 선택지가 아니다', () {
      // CHAP_Storage.html: "Amazon RDS has deprecated magnetic storage. You can
      // no longer create new DB instances using magnetic storage"
      expect(docs['soa-t1-5']!.contains('·마그네틱** 중 선택'), isFalse);
      expect(docs['soa-t1-5']!.contains('마그네틱 스토리지는 사용 중단'), isTrue);
    });

    test('Macie — 머신러닝과 패턴 매칭', () {
      // what-is-macie.html: "uses machine learning and pattern matching"
      expect(docs['soa-t4-2']!.contains('머신러닝·패턴 매칭'), isTrue);
      expect(docs['soa-t4-2']!.contains('| S3 객체 머신러닝 분류 |'), isFalse);
    });

    test('그 밖의 정정 — 오자·지문 대상·메타 문구', () {
      expect(mdOffenders((t) => t.contains('고대수')), isEmpty);
      // DLM 대상은 EBS 스냅샷과 EBS 기반 AMI 다.
      expect((q('soa-t2-3-q6')['stem'] as String).contains('EBS 스냅샷과 AMI'), isTrue);
      // 지문이 「공식 문서가 드는 예시」를 묻지 않는다(자기 프레임 크러치).
      final meta = [
        for (final e in questions)
          if ((e['stem'] as String).contains('공식 문서가 드는')) e['id'],
      ];
      expect(meta, isEmpty);
    });
  });
}
