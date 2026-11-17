import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 2026-11-17 전 콘텐츠 검증 **2단계(보정) — SOA** 가드.
///
/// 1단계 보고: `docs/audits/2026-11-17-full-verify/soa.md`
/// 2단계 반영 보고: `docs/audits/2026-11-17-full-verify/soa-phase2.md`
///
/// 이 배치는 🔴 6건(R1~R6) · 🟡 Y1~Y17·Y19 · 🟢 G2~G5·G7·G8 을 반영했다.
/// 손댄 문항 71개·학습문서 14편이 **전부 라이브**이고 **정답 인덱스는 한 건도
/// 바뀌지 않았다**(아래 `correctIndex` 맵은 추측이 아니라 파일에서 덤프한 값이다).
///
/// ## 가드 설계
///
/// - **사실 단정은 자격증 전수 집계형**이다(md 20편 + 문항 20파일). 문항별 리터럴
///   가드는 어형 하나로 뚫린다(2026-11-06 AIF 「PT 필수」).
/// - **옛 문구 0건 + 새 공식 사실 있음**을 쌍으로 둔다. 지우기만 해도 통과하는
///   가드는 출처·사실 삭제를 막지 못한다.
/// - ⚠️ **`verified` 상태는 단정하지 않는다** — flip 은 사람의 영역이고, 상태를
///   박아 두면 검수자의 flip 이 레드로 끝난다(2026-11-13 SCS).
/// - ⚠️ **`lastVerified` 날짜도 여기서 정확 비교하지 않는다** — 그 맵은
///   `soa_facts_test`·`soa_v11_topics_test`(공유 파일)에 있다.
///
/// ## 비자명한 공식 사실 (2026-11-17 직접 측정 · 전부 `200 r=0`)
///
/// ⚠️ **로그 데이터에 경보를 거는 방법은 둘이다**(R1) —
/// `Alarm-On-Logs.html`: `You can create CloudWatch alarms that monitor your log
/// data in two ways: Log Alarm approach — Create a Log Alarm that runs a
/// CloudWatch Logs Insights query on a schedule and evaluates the aggregated
/// results directly against a threshold. Metric filter approach — …`.
/// 그래서 「Logs Insights 쿼리를 5분마다 실행하는 경보」는 **참인 보기**가 됐고
/// `soa-t1-2-q3` 은 정답이 둘이었다. 오답 보기를 명백히 거짓(보존 기간)으로 바꿨다.
///
/// ⚠️ **Performance Insights 는 2026-07-31 에 수명이 끝났다**(R2) —
/// `Database-Insights.html`: `AWS announced that the end-of-life date for
/// Performance Insights was July 31, 2026, and has migrated Performance Insights
/// users to Database Insights.` 시험 가이드 skill 1.3.5 는 옛 이름을 쓰므로
/// **지우지 않고 병기**한다.
///
/// ⚠️ **가져온 인증서의 개인 키는 ACM 안에 있다**(R3) —
/// `import-certificate-prerequisites.html`: `you must provide both the certificate
/// and its private key`. 갱신되지 않는 이유는 「키가 밖에 있어서」가 아니라
/// `ACM does not provide managed renewal for imported certificates` 이고, 갱신은
/// `obtain a new certificate from your certificate issuer and then manually
/// reimport it` 다.
///
/// ⚠️ **Geoproximity 는 Traffic Flow 전용이 아니다**(R4) — `routing-policy.html`
/// 이 레코드 생성 시 고르는 정책으로 Geoproximity 와 **IP-based** 를 함께 싣고
/// (`Traffic Flow` 0건), `routing-policy-geoproximity.html` 은
/// `The maps are available only with Traffic Flow.` 로 **지도만** 한정한다.
/// 정책 개수는 단정하지 않는다.
///
/// ⚠️ **Trusted Advisor 범주는 다섯이 아니다**(R5) — `Cost optimization ·
/// Performance · Security · Fault tolerance · Service limits · Operational
/// Excellence`.
///
/// ⚠️ **AMI 등록 해제 시 스냅샷을 함께 지울 수 있다**(R6) — `When deregistering
/// an AMI, you can optionally delete its associated snapshots at the same time.
/// However, if a snapshot is associated with multiple AMIs, it won't be deleted
/// even if specified for deletion`. 「연동 삭제 불가」는 거짓이고 「기본 동작으로는
/// 남는다」가 참이다.
///
/// ⚠️ **Secrets Manager 교체가 전부 Lambda 는 아니다**(Y3) — `Managed rotation
/// doesn't use a Lambda function.` / `Rotation by Lambda function – For other
/// types of secrets`.
///
/// ⚠️ **패치 그룹 태그 키는 둘이다**(Y7) — `the tag key must be Patch Group or
/// PatchGroup. PatchGroup (without a space) is required if you have allowed tags
/// in EC2 instance metadata`. 그리고 `Patch groups are not used in patching
/// operations that are based on patch policies`.
///
/// ⚠️ **상태 확인 유예 기간 기본값은 생성 경로마다 다르다**(Y8) — 콘솔 300초,
/// `Its default value is 0 seconds when you create an Auto Scaling group using
/// the AWS CLI or an SDK`.
///
/// ⚠️ **14일은 권장 하한이 아니라 분석 창의 상한이다**(Y9) — `must have at least
/// 24 hours of data … analyzing metric data from up to the past 14 days`.
///
/// ⚠️ **무효화의 `/*` 는 경로 1개다**(Y6) — `A path that includes the * wildcard
/// counts as one path` · 매월 1,000 경로 무료. 버전 파일명을 권하는 공식 이유는
/// 비용만이 아니라 `the user might continue to see the old version until it
/// expires from those caches` 다.
///
/// ⚠️ **로컬 경로 「삭제 불가」는 공식 문장으로 확인되지 않았다**(Y17) — 공식이
/// 적는 것은 `This route is added by default to all route tables` 와
/// `You can replace or restore the target of each local route` 다. 확인되지 않은
/// 단정을 정답의 실질에서 뺐다.
///
/// ⚠️ **RDS 자동 백업 보존 범위는 0~35일이다**(2단계 범위 확장) — `between 0 and
/// 35 days. Setting the backup retention period to 0 disables automated backups.`
/// 기본값은 콘솔 7일 · API/CLI 1일.
void main() {
  const dir = 'assets/content/soa';

  List<File> questionFiles() => Directory(dir)
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.questions.json'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  List<File> docFiles() => Directory(dir)
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.md'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  List<Map<String, dynamic>> questionsOf(File f) =>
      ((json.decode(f.readAsStringSync()) as Map<String, dynamic>)['questions']
              as List)
          .cast<Map<String, dynamic>>();

  List<Map<String, dynamic>> allQuestions() =>
      [for (final f in questionFiles()) ...questionsOf(f)];

  Map<String, dynamic> question(String qid) => allQuestions()
      .firstWhere((q) => q['id'] == qid, orElse: () => fail('$qid 없음'));

  String doc(String id) => File('$dir/$id.md').readAsStringSync();

  /// 문항 전체(지문·보기·해설·오답 근거·출처).
  String blob(Map<String, dynamic> q) => json.encode(q);

  /// **가르치는 층** — skill·지문·정답 보기·해설. 상태·명칭 메모는 이 층에만
  /// 요구한다(오답 보기를 반박하는 문장에 달면 그 상태가 보기를 틀리게 만든
  /// 이유처럼 읽혀 거짓이 된다).
  String teaching(Map<String, dynamic> q) => [
        q['skill'],
        q['stem'],
        (q['options'] as List)[q['correct'] as int],
        q['explanation'],
      ].join('\n');

  List<String> urls(Map<String, dynamic> q) => [
        for (final s in (q['sources'] as List).cast<Map<String, dynamic>>())
          s['url'] as String
      ];

  /// SOA 전 콘텐츠의 줄(파일명 접두).
  List<String> allLines() => [
        for (final f in [...docFiles(), ...questionFiles()])
          for (final l in const LineSplitter().convert(f.readAsStringSync()))
            '${f.uri.pathSegments.last}: $l'
      ];

  /// 전수에서 금지 문구가 든 줄.
  List<String> hits(Pattern p) => allLines().where((l) => l.contains(p)).toList();

  // ───────────────────── 탐지기 (대조군으로 고정) ─────────────────────

  /// Y10 — ELB 상태 확인/점검을 앱 장애 감지의 **배타적 경로**로 단정하는가.
  /// `soa_p2_review_fix_test` 의 탐지기가 못 본 두 어형을 본다:
  /// ① 「통해서만」 ② 「상태 **점검**」(그 탐지기는 「상태 확인」만 본다).
  /// 다른 경로(사용자 정의 상태 확인/점검)를 함께 적으면 배타적이지 않다.
  bool elbOnly(String text) {
    final elb = RegExp(r'ELB(\(로드밸런서\))?\s*상태\s*(확인|점검)');
    if (!elb.hasMatch(text)) return false;
    if (RegExp(r'사용자 정의 상태\s*(확인|점검)').hasMatch(text)) return false;
    if (text.contains('통해서만')) return true;
    final appCtx = RegExp(r'앱|애플리케이션');
    return text.contains('상태 점검') &&
        appCtx.hasMatch(text) &&
        RegExp(r'연결해야').hasMatch(text);
  }

  /// R4 — Geoproximity 를 Traffic Flow 전용으로 적는가. 「지도」만 Traffic Flow
  /// 전용이라는 정정문은 통과한다.
  bool geoTrafficFlowOnly(String text) =>
      text.contains('Traffic Flow') &&
      RegExp(r'Geoproximity|bias|지리근접').hasMatch(text) &&
      !text.contains('지도');

  /// Y5 — API Gateway 인증서를 한정 없이 「같은 리전」으로 적는가.
  bool apiGwSameRegion(String text) =>
      RegExp(r'API (Gateway|GW)').hasMatch(text) &&
      text.contains('같은 리전') &&
      !text.contains('리전형');

  // ═════════════════════ 대조군 ═════════════════════

  test('대조군: SOA 콘텐츠가 읽힌다 — md 20편 · 문항 300개 · Task당 15 · 보기 4개', () {
    expect(docFiles().length, 20);
    expect(questionFiles().length, 20);
    for (final f in questionFiles()) {
      final qs = questionsOf(f);
      expect(qs.length, 15, reason: f.path);
      for (final q in qs) {
        expect((q['options'] as List).length, 4, reason: '${q['id']}');
        expect((q['wrongExplanations'] as Map).length, 3, reason: '${q['id']}');
        expect(q['sources'] as List, isNotEmpty, reason: '${q['id']}');
      }
    }
    expect(allQuestions().length, 300);
    expect(allLines().length, greaterThan(10000));
  });

  test('대조군: 탐지기가 옛 문구는 잡고 정정문은 통과시킨다', () {
    // Y10 — 옛 두 어형
    expect(elbOnly('앱 계층 장애는 ELB 상태 확인을 통해서만 ASG에 전달된다.'), isTrue);
    expect(
        elbOnly('애플리케이션 수준 장애로 교체하려면 **ELB 상태 점검**을 ASG에 연결해야 합니다.'),
        isTrue);
    // Y10 — 정정문
    expect(
        elbOnly('앱 계층 장애를 ASG에 알리려면 ELB 상태 확인이나 사용자 정의 상태 확인 같은 '
            '추가 소스가 필요하다.'),
        isFalse);
    expect(
        elbOnly('**ELB 상태 점검**을 ASG에 연결하거나 **사용자 정의 상태 점검**으로 비정상을 '
            '알립니다.'),
        isFalse);
    // R4
    expect(
        geoTrafficFlowOnly(
            '> **Geoproximity**는 **Route 53 Traffic Flow** 에서만 사용하며 bias 값으로'),
        isTrue);
    expect(
        geoTrafficFlowOnly('**Traffic Flow에서만 제공되는 것은 편향 범위를 보여 주는 지도**입니다. '
            'Geoproximity'),
        isFalse);
    // Y5
    expect(apiGwSameRegion('ALB·NLB·API Gateway는 리소스와 같은 리전의 인증서를 사용합니다.'),
        isTrue);
    expect(apiGwSameRegion('ALB·NLB·리전형 API Gateway는 리소스와 같은 리전의 인증서를 사용하고'),
        isFalse);
  });

  test('정답 인덱스 불변 — 이 배치가 손댄 71문항 (파일에서 덤프한 값)', () {
    const correctIndex = <String, int>{
      'soa-t1-1-q2': 0,
      'soa-t1-1-q3': 0,
      'soa-t1-1-q4': 0,
      'soa-t1-1-q10': 0,
      'soa-t1-1-q13': 0,
      'soa-t1-2-q3': 0,
      'soa-t1-2-q9': 0,
      'soa-t1-2-q10': 1,
      'soa-t1-2-q11': 1,
      'soa-t1-2-q12': 0,
      'soa-t1-2-q13': 1,
      'soa-t1-3-q6': 0,
      'soa-t1-3-q9': 1,
      'soa-t1-3-q11': 0,
      'soa-t1-4-q2': 1,
      'soa-t1-5-q12': 0,
      'soa-t1-5-q13': 0,
      'soa-t2-1-q4': 0,
      'soa-t2-1-q5': 0,
      'soa-t2-1-q7': 0,
      'soa-t2-1-q11': 0,
      'soa-t2-2-q1': 1,
      'soa-t2-2-q2': 0,
      'soa-t2-2-q4': 0,
      'soa-t2-2-q5': 0,
      'soa-t2-2-q10': 0,
      'soa-t2-2-q11': 0,
      'soa-t2-2-q13': 0,
      'soa-t2-2-q14': 0,
      'soa-t2-3-q4': 0,
      'soa-t2-3-q6': 0,
      'soa-t2-3-q8': 1,
      'soa-t2-3-q13': 0,
      'soa-t2-3-q14': 0,
      'soa-t2-4-q10': 0,
      'soa-t3-2-q1': 0,
      'soa-t3-2-q9': 0,
      'soa-t3-2-q10': 0,
      'soa-t3-2-q13': 0,
      'soa-t3-2-q14': 0,
      'soa-t3-3-q3': 0,
      'soa-t3-3-q8': 0,
      'soa-t3-4-q2': 0,
      'soa-t3-4-q5': 0,
      'soa-t4-1-q6': 0,
      'soa-t4-1-q10': 0,
      'soa-t4-2-q3': 0,
      'soa-t4-2-q4': 0,
      'soa-t4-2-q5': 0,
      'soa-t4-2-q12': 3,
      'soa-t4-3-q4': 0,
      'soa-t4-3-q10': 0,
      'soa-t4-3-q11': 0,
      'soa-t4-3-q12': 0,
      'soa-t4-3-q13': 0,
      'soa-t5-1-q3': 0,
      'soa-t5-1-q7': 0,
      'soa-t5-1-q9': 0,
      'soa-t5-1-q13': 0,
      'soa-t5-1-q14': 0,
      'soa-t5-2-q15': 0,
      'soa-t5-3-q1': 0,
      'soa-t5-3-q2': 0,
      'soa-t5-3-q4': 0,
      'soa-t5-3-q9': 0,
      'soa-t5-3-q11': 0,
      'soa-t5-3-q13': 0,
      'soa-t5-4-q2': 0,
      'soa-t5-4-q5': 0,
      'soa-t5-4-q9': 0,
      'soa-t5-4-q15': 0,
    };
    expect(correctIndex.length, 71);
    correctIndex.forEach((qid, idx) {
      expect(question(qid)['correct'], idx, reason: '$qid 정답 인덱스가 바뀌었다');
    });
  });

  // ═════════════════════ 🔴 R1 ~ R6 ═════════════════════

  group('R1 로그 경보의 두 경로 (soa-t1-2-q3 — 정답이 둘이던 문항)', () {
    test('전수: 「Logs Insights 결과에는 경보를 걸 수 없다」는 단정이 없다', () {
      expect(hits('쿼리 결과에 직접 경보를 거는 방식이 아닙'), isEmpty);
      expect(hits('로그 기반 경보는 지표 필터를 사용합니다'), isEmpty);
    });

    test('q3: 오답 보기 어디에도 Logs Insights 경보가 없다 (참인 보기를 오답으로 두지 않는다)', () {
      final q = question('soa-t1-2-q3');
      final options = (q['options'] as List).cast<String>();
      for (var i = 0; i < options.length; i++) {
        if (i == q['correct']) continue;
        expect(options[i].contains('Logs Insights'), isFalse,
            reason: 'Log Alarm 은 공식 기능이다 — 오답 보기로 두면 정답이 둘이 된다');
      }
      expect(options[q['correct'] as int].contains('지표 필터'), isTrue);
    });

    test('q3·md: 두 번째 경로(Log Alarm)를 가르치고 그 출처를 든다', () {
      final q = question('soa-t1-2-q3');
      expect((q['explanation'] as String).contains('Log Alarm'), isTrue);
      expect(urls(q).any((u) => u.endsWith('monitoring/Alarm-On-Logs.html')),
          isTrue);
      final d = doc('soa-t1-2');
      expect(d.contains('Log Alarm'), isTrue);
      expect(d.contains('monitoring/Alarm-On-Logs.html'), isTrue);
    });
  });

  group('R2 Performance Insights 수명 종료 — Database Insights 병기', () {
    test('전수: 옛 이름을 드는 md 는 새 이름과 종료 사실을 함께 적는다', () {
      var seen = 0;
      for (final f in docFiles()) {
        final t = f.readAsStringSync();
        if (!t.contains('Performance Insights') && !t.contains('성능 개선 도우미')) {
          continue;
        }
        seen++;
        expect(t.contains('Database Insights'), isTrue, reason: f.path);
        expect(t.contains('2026-07-31'), isTrue, reason: f.path);
      }
      expect(seen, greaterThanOrEqualTo(1), reason: '대조군: 옛 이름을 드는 md 가 실재한다');
    });

    test('전수: 가르치는 층에서 옛 이름을 드는 문항은 새 이름을 함께 적는다', () {
      var seen = 0;
      for (final q in allQuestions()) {
        final t = teaching(q);
        if (!t.contains('Performance Insights') && !t.contains('성능 개선 도우미')) {
          continue;
        }
        seen++;
        expect(t.contains('Database Insights'), isTrue, reason: '${q['id']}');
      }
      expect(seen, greaterThanOrEqualTo(1));
    });

    test('q13: 정답 보기가 현행 이름이고 종료 공지 출처를 든다', () {
      final q = question('soa-t1-5-q13');
      final answer = (q['options'] as List)[q['correct'] as int] as String;
      expect(answer.contains('Database Insights'), isTrue);
      expect(answer.contains('성능 개선 도우미'), isTrue,
          reason: '시험 가이드 skill 1.3.5 가 옛 이름을 쓴다 — 지우지 않고 병기한다');
      expect((q['explanation'] as String).contains('2026-07-31'), isTrue);
      expect(urls(q).any((u) => u.endsWith('monitoring/Database-Insights.html')),
          isTrue);
      expect(blob(q).contains('Amazon RDS 성능 개선 도우미로 DB 부하 모니터링'), isFalse,
          reason: '그 페이지의 제목은 이제 Database Insights 다');
    });
  });

  group('R3 가져온 인증서가 갱신되지 않는 이유', () {
    test('전수: 「개인 키가 ACM 외부」라는 거짓 이유가 없다', () {
      expect(hits('개인 키가 ACM 외부'), isEmpty);
    });

    test('q11·md: 공식이 적는 갱신 절차(다시 가져오기)를 가르친다', () {
      final q = question('soa-t4-3-q11');
      expect((q['explanation'] as String).contains('다시 가져와'), isTrue);
      expect((q['explanation'] as String).contains('관리형 갱신을 제공하지 않'), isTrue);
      expect(
          urls(q).any((u) => u.endsWith('import-certificate-prerequisites.html')),
          isTrue);
      expect(doc('soa-t4-3').contains('다시 가져와야'), isTrue);
    });
  });

  group('R4 Route 53 라우팅 정책 — 개수 단정과 Traffic Flow 전용 서술', () {
    test('전수: 정책 개수를 단정하지 않는다', () {
      expect(hits(RegExp(r'라우팅\s*(정책\s*)?7종')), isEmpty);
    });

    test('전수: Geoproximity 를 Traffic Flow 전용으로 적는 줄이 없다', () {
      expect(allLines().where(geoTrafficFlowOnly).toList(), isEmpty);
      expect(hits('Traffic Flow 필요'), isEmpty);
    });

    test('md: IP 기반 라우팅과 「지도만 Traffic Flow」를 가르친다', () {
      final d = doc('soa-t5-3');
      expect(d.contains('IP 기반(IP-based)'), isTrue);
      expect(d.contains('Traffic Flow에서만 제공되는 것은 편향 범위를 보여 주는 지도'), isTrue);
      expect(d.contains('routing-policy-geoproximity.html'), isTrue);
    });
  });

  group('R5 Trusted Advisor 점검 범주', () {
    test('전수: 「5범주」류 개수 단정이 없다', () {
      expect(hits(RegExp(r'5\s*범주|5개\s*(점검\s*)?범주|다섯\s*범주')), isEmpty);
    });

    test('q12·md: 운영 우수성 범주를 싣는다', () {
      expect(
          (question('soa-t4-2-q12')['explanation'] as String).contains('운영 우수성'),
          isTrue);
      final d = doc('soa-t4-2');
      expect(d.contains('운영 우수성(Operational Excellence)'), isTrue);
      expect(d.contains('trusted-advisor-check-reference.html'), isTrue);
    });
  });

  group('R6 AMI 등록 해제와 스냅샷', () {
    test('전수: 「연동 삭제 불가」·「두 단계 필수」 단정이 없다', () {
      expect(hits('연동 삭제가 불가'), isEmpty);
      expect(hits('두 단계를 명시적으로 수행해야'), isEmpty);
    });

    test('q1·md: 「기본 동작」 한정과 함께 삭제 옵션을 가르친다', () {
      final e = question('soa-t3-2-q1')['explanation'] as String;
      expect(e.contains('기본 동작으로는'), isTrue);
      expect(e.contains('함께 삭제'), isTrue);
      final d = doc('soa-t3-2');
      expect(d.contains('기본 동작으로는'), isTrue);
      expect(d.contains('함께 삭제'), isTrue);
      expect(d.contains('UserGuide/deregister-ami.html'), isTrue);
    });
  });

  // ═════════════════════ 🟡 Y1 ~ Y17 ═════════════════════

  group('Y1 CloudTrail Lake 신규 고객 제공 상태', () {
    test('전수: 가르치는 층에서 CloudTrail Lake 를 드는 문항·md 는 상태를 적는다', () {
      var qCount = 0;
      for (final q in allQuestions()) {
        if (!teaching(q).contains('CloudTrail Lake')) continue;
        qCount++;
        expect(teaching(q).contains('신규 고객'), isTrue, reason: '${q['id']}');
      }
      expect(qCount, greaterThanOrEqualTo(1));
      var mdCount = 0;
      for (final f in docFiles()) {
        final t = f.readAsStringSync();
        if (!t.contains('CloudTrail Lake')) continue;
        mdCount++;
        expect(t.contains('신규 고객'), isTrue, reason: f.path);
      }
      expect(mdCount, greaterThanOrEqualTo(1));
    });

    test('대조군: 오답 층에서만 드는 문항이 실재한다 (층 분리가 공허하지 않다)', () {
      final wrongOnly = allQuestions().where((q) =>
          blob(q).contains('CloudTrail Lake') &&
          !teaching(q).contains('CloudTrail Lake'));
      expect(wrongOnly, isNotEmpty);
    });
  });

  test('Y2 Security Hub CSPM — ASFF 를 가르치는 문항·md 가 현행 이름을 적는다', () {
    var seen = 0;
    for (final q in allQuestions()) {
      if (!teaching(q).contains('ASFF')) continue;
      seen++;
      expect(teaching(q).contains('Security Hub CSPM'), isTrue,
          reason: '${q['id']}');
    }
    expect(seen, greaterThanOrEqualTo(2));
    expect(doc('soa-t4-2').contains('현재 공식 이름은 AWS Security Hub CSPM'), isTrue);
  });

  group('Y3 Secrets Manager 교체 방식', () {
    test('전수: 교체를 「Lambda 기반」으로만 적는 문구가 없다', () {
      expect(hits('Lambda 기반 교체'), isEmpty);
      expect(hits('Lambda 기반의 **자동 교체**'), isEmpty);
      expect(hits('내장 Lambda 로테이터'), isEmpty);
      expect(hits('(Lambda 기반, RDS'), isEmpty);
    });

    test('q13·md: 관리형 교체는 Lambda 를 쓰지 않는다고 가르친다', () {
      final q = question('soa-t4-3-q13');
      expect((q['explanation'] as String).contains('관리형 교체'), isTrue);
      expect(
          ((q['options'] as List)[q['correct'] as int] as String)
              .contains('Lambda'),
          isFalse);
      expect(doc('soa-t4-3').contains('관리형 교체'), isTrue);
      expect(doc('soa-t3-3').contains('관리형 교체'), isTrue);
    });
  });

  test('Y4 ACM 완전 자동 갱신 — 「사용 중」 조건을 적는다', () {
    final q = question('soa-t4-3-q12');
    expect(
        ((q['options'] as List)[q['correct'] as int] as String).contains('사용 중'),
        isTrue);
    expect((q['explanation'] as String).contains('AWS 서비스에서 사용 중'), isTrue);
    expect(urls(q).any((u) => u.endsWith('acm/latest/userguide/managed-renewal.html')),
        isTrue);
    expect(doc('soa-t4-3').contains('AWS 서비스에서 사용 중이고 DNS 검증 레코드가 유지되는 동안'),
        isTrue);
  });

  group('Y5 API Gateway 인증서 리전 — 엣지 최적화 예외', () {
    test('전수: API Gateway 를 한정 없이 「같은 리전」으로 적는 줄이 없다', () {
      expect(allLines().where(apiGwSameRegion).toList(), isEmpty);
      expect(allLines().where((l) => l.contains('리전형 API G')).length,
          greaterThanOrEqualTo(4),
          reason: '대조군: 정정된 줄이 실재한다');
    });

    test('q10·q13: 엣지 최적화는 us-east-1 이라고 적고 그 출처를 든다', () {
      for (final id in ['soa-t4-3-q10', 'soa-t5-3-q13']) {
        final q = question(id);
        expect((q['explanation'] as String).contains('엣지 최적화'), isTrue, reason: id);
        expect(
            urls(q).any((u) =>
                u.endsWith('how-to-edge-optimized-custom-domain-name.html')),
            isTrue,
            reason: id);
      }
    });
  });

  group('Y6 CloudFront 무효화 — 과금 단위와 버전 파일명', () {
    test('전수: 「잦은 전체 무효화는 비용·부하가 크다」는 논리가 없다', () {
      expect(hits(RegExp(r'잦은 전체 무효화는\s*(비용|운영 비용)')), isEmpty);
      expect(hits('전체 무효화를 자주 하면 비용과 오리진 부하가 큽니다'), isEmpty);
    });

    test('q11·md: 월 1,000 경로와 와일드카드 1경로를 적는다', () {
      final q = question('soa-t5-3-q11');
      final e = q['explanation'] as String;
      expect(e.contains('1,000'), isTrue);
      expect(e.contains('경로 1개'), isTrue);
      expect(urls(q).any((u) => u.endsWith('PayingForInvalidation.html')), isTrue);
      final d = doc('soa-t5-3');
      expect(d.contains('매월 처음 1,000개 경로까지 무료'), isTrue);
    });
  });

  group('Y7 패치 그룹 태그 키', () {
    test('전수: 「정확히 Patch Group 일 때만」류 단정이 없다', () {
      expect(hits('공백·대소문자 정확히'), isEmpty);
      expect(hits('공백·대소문자 포함'), isEmpty);
      expect(hits('공백 포함)가 정확해야'), isEmpty);
      expect(hits('정확히 `Patch Group`'), isEmpty);
    });

    test('q8·q10·md: 두 키와 패치 정책 한정을 적는다', () {
      for (final id in ['soa-t3-3-q8', 'soa-t3-2-q10']) {
        final e = question(id)['explanation'] as String;
        expect(e.contains('PatchGroup'), isTrue, reason: id);
        expect(e.contains('패치 정책'), isTrue, reason: id);
      }
      for (final id in ['soa-t3-3', 'soa-t3-2']) {
        expect(doc(id).contains('`PatchGroup`'), isTrue, reason: id);
        expect(doc(id).contains('패치 정책 기반 패치 작업에서는 패치 그룹을 쓰지 않습니다'), isTrue,
            reason: id);
      }
    });
  });

  test('Y8 상태 확인 유예 기간 — 「기본 300초」는 콘솔 한정과 함께만 나온다', () {
    final lines = allLines().where((l) => l.contains('유예 기간') && l.contains('300초'));
    expect(lines, isNotEmpty);
    for (final l in lines) {
      expect(l.contains('콘솔'), isTrue, reason: l);
      expect(l.contains('0초'), isTrue, reason: l);
    }
  });

  test('Y9 예측 조정 — 14일은 「권장 하한」이 아니라 분석 창의 상한이다', () {
    expect(hits(RegExp(r'14일\s*이상')), isEmpty);
    expect(
        (question('soa-t2-1-q5')['explanation'] as String).contains('최근 최대 14일'),
        isTrue);
    expect(doc('soa-t2-1').contains('최근 최대 14일'), isTrue);
    expect(
        urls(question('soa-t2-1-q5'))
            .any((u) => u.endsWith('predictive-scaling-policy-overview.html')),
        isTrue);
  });

  group('Y10 ELB 상태 확인 배타 서술의 어형 잔여', () {
    test('전수: 「통해서만」·「상태 점검 … 연결해야」 어형이 없다', () {
      expect(allLines().where(elbOnly).toList(), isEmpty);
    });

    test('md: 다른 소스(사용자 정의 상태 점검)를 함께 적는다', () {
      expect(doc('soa-t3-4').contains('사용자 정의 상태 점검'), isTrue);
      // soa_p2_review_fix_test 가 필수로 묶은 문장은 그대로다.
      expect(doc('soa-t2-1').contains('유일한 경로는 아닙니다'), isTrue);
    });
  });

  test('Y11 Flow Logs REJECT — NACL 한정 서술이 없다', () {
    expect(hits('NACL에 의해 거부된'), isEmpty);
    expect(hits('REJECT가 없는데도 실패하면 SG 인바운드를 의심'), isEmpty);
    expect(doc('soa-t5-4').contains('**보안 그룹 또는 NACL이 허용하지 않은** 트래픽'), isTrue);
  });

  test('Y12 오답 근거 정밀화 — 회피형·부정확 반박이 없다', () {
    expect(hits('TTL 설정 가능 여부가 핵심 차이는 아닙니다'), isEmpty);
    expect(hits('지표 집계·상태 확인에서'), isEmpty);
    expect(hits('합집합 평가 대상이 아닙니다'), isEmpty);
    final w = (question('soa-t5-3-q4')['wrongExplanations'] as Map)['2'] as String;
    expect(w.contains('TTL을 설정할 수 없습니다'), isTrue);
    final b = (question('soa-t4-1-q6')['wrongExplanations'] as Map)['2'] as String;
    expect(b.contains('IAM 사용자 ARN'), isTrue);
    expect(b.contains('IAM 역할 ARN'), isTrue,
        reason: '역할 ARN 은 경계에 제한받는다 — 사용자 ARN 만 예외다');
  });

  test('Y13 Config 평가 트리거 — 「반드시 포착」 단정이 없고 세 유형을 적는다', () {
    expect(hits('반드시 포착'), isEmpty);
    expect(
        (question('soa-t4-2-q3')['explanation'] as String).contains('하이브리드'),
        isTrue);
    expect(doc('soa-t4-2').contains('구성 변경·주기·둘을 함께 쓰는 하이브리드'), isTrue);
  });

  test('Y14 Direct Connect 구축 시간 — 확인되지 않은 「수 주」를 가르치지 않는다', () {
    final q = question('soa-t5-2-q15');
    expect(teaching(q).contains('수 주'), isFalse);
    expect(doc('soa-t5-2').contains('수 주'), isFalse);
    expect(teaching(q).contains('물리 회선 설치'), isTrue);
    expect(urls(q).any((u) => u.endsWith('s2svpn/SetUpVPNConnections.html')), isTrue);
  });

  test('Y15 예약 규칙은 레거시 — 두 문항 해설이 EventBridge Scheduler 를 적는다', () {
    for (final id in ['soa-t3-4-q5', 'soa-t1-3-q9']) {
      expect((question(id)['explanation'] as String).contains('EventBridge Scheduler'),
          isTrue,
          reason: id);
    }
  });

  test('Y16 프라이빗 호스팅 영역 — DNS 속성 둘 다', () {
    expect(hits('**enableDnsSupport가 켜져 있어야**'), isEmpty);
    expect(doc('soa-t5-1').contains('**enableDnsHostnames와 enableDnsSupport 둘 다**'),
        isTrue);
  });

  group('Y17 VPC 로컬 경로 — 확인되지 않은 「삭제 불가」', () {
    test('soa-t5-1 md·문항: 「삭제 불가」 단정이 없다', () {
      final t = doc('soa-t5-1') + File('$dir/soa-t5-1.questions.json').readAsStringSync();
      expect(RegExp(r'삭제\s*불가|삭제할 수 없').hasMatch(t), isFalse);
    });

    test('q14: 확인된 사실(기본 추가·대상 교체)로 가르치고 오답 보기는 거짓이다', () {
      final q = question('soa-t5-1-q14');
      final options = (q['options'] as List).cast<String>();
      expect(options[q['correct'] as int].contains('기본으로 포함'), isTrue);
      expect((q['explanation'] as String).contains('교체'), isTrue);
      expect(options.any((o) => o.contains('표준 수단')), isTrue,
          reason: '오답 보기는 명백히 거짓이어야 한다(격리의 표준 수단은 SG·NACL)');
      expect(urls(q).any((u) => u.endsWith('userguide/subnet-route-tables.html')),
          isTrue);
      expect(urls(q).any((u) => u.endsWith('replace-local-route-target.html')), isTrue);
    });
  });

  test('범위 확장: RDS 자동 백업 보존 — 0은 비활성화이고 기본값이 경로마다 다르다', () {
    final q = question('soa-t2-3-q8');
    expect((q['explanation'] as String).contains('0은 자동 백업 비활성화'), isTrue);
    expect(((q['wrongExplanations'] as Map)['0'] as String).contains('API·CLI 기본값은 1일'),
        isTrue);
    expect(hits('7일은 기본값에 가까운 값'), isEmpty);
  });

  // ═════════════════════ 🟡 Y19 출처 ═════════════════════

  group('Y19 출처가 그 사실을 담는 페이지를 든다', () {
    test('문항별: 사실을 담는 페이지가 출처에 있다 (파일에서 덤프한 값)', () {
      const need = <String, String>{
        'soa-t1-2-q3': 'monitoring/Alarm-On-Logs.html',
        'soa-t1-2-q9': 'logs/CWL_AnalyzeLogData-discoverable-fields.html',
        'soa-t1-2-q10': 'monitoring/metrics-collected-by-CloudWatch-agent.html',
        'soa-t1-2-q11': 'monitoring/installing-cloudwatch-agent-ssm.html',
        'soa-t1-2-q12': 'monitoring/installing-cloudwatch-agent-ssm.html',
        'soa-t1-2-q13': 'monitoring/metrics-collected-by-CloudWatch-agent.html',
        'soa-t1-3-q11': 'cloudwatch/',
        'soa-t1-4-q2': 'ug/getting-started-health-dashboard.html',
        'soa-t1-5-q12': 'UserGuide/Concepts.MultiAZSingleStandby.html',
        'soa-t1-5-q13': 'monitoring/Database-Insights.html',
        'soa-t2-1-q4': 'userguide/predictive-scaling-policy-overview.html',
        'soa-t2-1-q5': 'userguide/predictive-scaling-policy-overview.html',
        'soa-t2-1-q7': 'userguide/ec2-auto-scaling-default-instance-warmup.html',
        'soa-t2-2-q1': 'UserGuide/Concepts.MultiAZSingleStandby.html',
        'soa-t2-2-q2': 'UserGuide/Concepts.MultiAZ.Failover.html',
        'soa-t2-2-q4': 'UserGuide/Concepts.MultiAZSingleStandby.html',
        'soa-t2-2-q5': 'reliability-pillar/rel_fault_isolation_multiaz_region_system.html',
        'soa-t2-2-q10': 'DeveloperGuide/resource-record-sets-values-failover.html',
        'soa-t2-2-q11': 'DeveloperGuide/health-checks-creating-values.html',
        'soa-t2-2-q13': 'reliability-pillar/rel_fault_isolation_multiaz_region_system.html',
        'soa-t2-2-q14': 'UserGuide/Concepts.MultiAZSingleStandby.html',
        'soa-t2-3-q8': 'UserGuide/USER_WorkingWithAutomatedBackups.BackupRetention.html',
        'soa-t2-3-q13': 'userguide/replication-requirements.html',
        'soa-t2-3-q14': 'userguide/intro-lifecycle-rules.html',
        'soa-t3-2-q9': 'userguide/patch-manager-predefined-and-custom-patch-baselines.html',
        'soa-t3-2-q13': 'blue-green-deployments/introduction.html',
        'soa-t3-2-q14': 'blue-green-deployments/introduction.html',
        'soa-t3-3-q3': 'userguide/send-commands-multiple.html',
        'soa-t3-4-q2': 'UserGuide/monitoring-instance-state-changes.html',
        'soa-t4-1-q6': 'UserGuide/access_policies_boundaries.html',
        'soa-t4-1-q10': 'UserGuide/reference_policies_condition-keys.html',
        'soa-t4-3-q4': 'developerguide/kms-cryptography.html',
        'soa-t4-3-q10': 'developerguide/how-to-edge-optimized-custom-domain-name.html',
        'soa-t4-3-q11': 'userguide/import-certificate-prerequisites.html',
        'soa-t4-3-q12': 'userguide/managed-renewal.html',
        'soa-t5-1-q3': 'userguide/route-tables-priority.html',
        'soa-t5-1-q7': 'userguide/work-with-nat-instances.html',
        'soa-t5-1-q9': 'userguide/custom-network-acl.html',
        'soa-t5-1-q13': 'userguide/AmazonDNS-concepts.html',
        'soa-t5-1-q14': 'userguide/subnet-route-tables.html',
        'soa-t5-2-q15': 's2svpn/SetUpVPNConnections.html',
        'soa-t5-3-q1': 'DeveloperGuide/hosted-zone-private-considerations.html',
        'soa-t5-3-q2': 'DeveloperGuide/hosted-zone-private-considerations.html',
        'soa-t5-3-q9': 'DeveloperGuide/DownloadDistValuesCacheBehavior.html',
        'soa-t5-3-q11': 'DeveloperGuide/PayingForInvalidation.html',
        'soa-t5-3-q13': 'developerguide/how-to-edge-optimized-custom-domain-name.html',
        'soa-t5-4-q2': 'userguide/flow-logs-basics.html',
        'soa-t5-4-q9': 'userguide/custom-network-acl.html',
        'soa-t5-4-q15': 'userguide/flow-logs-athena.html',
      };
      expect(need.length, greaterThanOrEqualTo(45));
      need.forEach((qid, tail) {
        expect(urls(question(qid)).any((u) => u.endsWith(tail)), isTrue,
            reason: '$qid 출처에 $tail 이 없다');
      });
    });

    test('전수: OTel 비교 허브로 바뀐 페이지를 문항 출처로 쓰지 않는다', () {
      for (final q in allQuestions()) {
        expect(urls(q).any((u) => u.endsWith('working_with_metrics.html')), isFalse,
            reason: '${q['id']} — 그 페이지에 보존·해상도 서술이 없다(retention 0건)');
      }
    });

    test('전수: 출처 URL 은 전부 https 이고 문항마다 중복이 없다', () {
      for (final q in allQuestions()) {
        final u = urls(q);
        expect(u.toSet().length, u.length, reason: '${q['id']} 출처 중복');
        for (final x in u) {
          expect(x.startsWith('https://'), isTrue, reason: '${q['id']} $x');
        }
      }
    });
  });

  // ═════════════════════ 🟢 ═════════════════════

  test('🟢 표기·지문 정리 — 콜드오프·고대수·메타 문구·DLM 대상', () {
    expect(hits('콜드오프'), isEmpty, reason: '공식 용어는 cooling-off period(grace time)');
    expect(hits('고대수'), isEmpty);
    expect(doc('soa-t2-3').contains('쿨링오프'), isTrue);
    expect((question('soa-t5-4-q5')['stem'] as String).contains('공식 문서가 드는'), isFalse);
    expect((question('soa-t2-3-q6')['stem'] as String).contains('EBS 스냅샷과 EBS 기반 AMI'),
        isTrue);
  });

  test('교차 자격증 정합(2단계 범위 확장) — Macie 분류 방식 · RDS 마그네틱 사용 중단', () {
    // what-is-macie: `discovers sensitive data by using machine learning and
    // pattern matching`. CHAP_Storage: `Amazon RDS has deprecated magnetic
    // storage. You can no longer create new DB instances using magnetic storage`.
    expect(hits('S3 객체 머신러닝 분류'), isEmpty);
    expect(doc('soa-t4-2').contains('머신러닝과 패턴 매칭'), isTrue);
    for (final l in allLines().where((l) => l.contains('마그네틱'))) {
      expect(l.contains('중단'), isTrue, reason: '마그네틱을 선택지로만 적으면 거짓이다: $l');
    }
    expect(allLines().where((l) => l.contains('마그네틱')), isNotEmpty);
    expect(doc('soa-t1-5').contains('UserGuide/CHAP_Storage.html'), isTrue);
  });

  test('프런트매터: sources 목록이 lastVerified 앞에서 끊기지 않는다 (20편)', () {
    // 목록 중간에 최상위 키가 끼면 파서가 뒤쪽 출처를 조용히 버린다(2026-11-11 SCS).
    for (final f in docFiles()) {
      final lines = const LineSplitter().convert(f.readAsStringSync());
      final i = lines.indexOf('sources:');
      expect(i, greaterThan(0), reason: f.path);
      var j = i + 1;
      var titles = 0, links = 0;
      while (j < lines.length &&
          (lines[j].startsWith('  - title:') || lines[j].startsWith('    url:'))) {
        if (lines[j].startsWith('  - title:')) titles++;
        if (lines[j].startsWith('    url:')) links++;
        j++;
      }
      expect(lines[j].startsWith('lastVerified:'), isTrue, reason: '${f.path}: ${lines[j]}');
      expect(titles, links, reason: f.path);
      expect(titles, greaterThanOrEqualTo(5), reason: f.path);
    }
  });
}
