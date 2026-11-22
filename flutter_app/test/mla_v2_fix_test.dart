import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 2026-11-17 전 콘텐츠 검증 **2단계(보정) — MLA-C01** 가드.
///
/// 1단계 보고: `docs/audits/2026-11-17-full-verify/mla.md`
/// 반영 보고: `docs/audits/2026-11-17-full-verify/mla-phase2.md`
///
/// 손댄 문항 39개는 **전부 라이브**다. **정답 인덱스·보기·`skill`·`section`·
/// `difficulty` 는 한 건도 바뀌지 않았다**(아래 「정답 인덱스 불변」이 고정한다).
/// ⚠️ 이 파일은 `verified` 상태를 단정하지 않는다 — 그 계약은
/// `mla_questions_test.dart` 의 `flipApprovedTaskIds` 가 갖는다.
///
/// ## 이 배치가 닫은 계열
///
/// 1. 🔴 **「실시간 엔드포인트는 최소 1대」의 거짓 일반화** — 공식
///    `endpoint-auto-scaling-zero-instances.html`: "An endpoint can scale to and
///    from zero instances only if it hosts inference components."
/// 2. **한정 없는 수치·단정 넷** — Lambda 타임아웃 900초(Managed Instances 는
///    5,400초) · Logs Insights 동시 쿼리 100개(QL 한정, PPL·SQL 은 각 15) ·
///    Access Analyzer 「대표 기간 30~90일」(공식은 최대 90일 + 가능한 한 짧게) ·
///    S3 는 게이트웨이 엔드포인트「만」(공식: "Amazon S3 supports both gateway
///    endpoints and interface endpoints").
/// 3. **「URL 은 200인데 그 페이지에 그 사실이 없다」 8문항** + 그 계열의 귀속
///    (지문이 「문서가」라고 적는데 1차 근거가 re:Post·블로그이던 4문항).
/// 4. **닫힌 기능을 현행 해법으로 가르치면서 상태가 없던 7문항**(Debugger 2 ·
///    Model Monitor 4 · Role Manager 1).
/// 5. 🟢 저작 과정 메모 4 · 오답 근거가 상태를 「틀린 이유」로 들던 3 ·
///    범위 외 서비스가 정답에 든 2 · 출처 세부 5.
///
/// ## 가드 설계에서 지킨 것
///
/// - **대조군을 먼저 둔다**(0건 통과가 파일을 못 읽어서일 수 있다).
/// - 사실 단정은 **전수 집계형**이다 — 문항별 리터럴 가드는 어형 하나로 뚫린다.
/// - **옛 문구 0건 + 새 공식 사실 있음**을 쌍으로 단정한다.
/// - ⚠️ **Lambda 규칙은 필드 단위다.** 문항 단위로 「900초 + Lambda」를 보면
///   `mla-t3-2-q8`(스케일링 쿨다운 보기 「900초」 + 오답 근거의 「Lambda
///   프로비저닝된 동시성」)이 걸린다 — 실측한 거짓 양성이고 대조군으로 고정했다.
/// - ⚠️ **상태 규칙의 「가르치는 층」에서 `skill` 을 뺐다.** `skill` 은 공식 가이드
///   문장의 전사라 `SageMaker Role Manager`·`Model Monitor` 가 예시로 들어 있고
///   (`mla-t4-3-q5`·`q6`·`q9` 등), 그 문항들은 그 기능을 가르치지 않는다.
/// - ⚠️ **Model Monitor 규칙은 문자열이 아니라 출처 URL 로 센다.** 2026-10-27 의
///   13문항 선정이 「`Model Monitor` 문자열이 나오는 문항」을 모집단으로 삼아,
///   같은 기능을 문자열 없이 가르치는 4문항(`mla-t4-1-q12`·`q13`·`q17`·`q18`)이
///   빠져 있었다. 그 네 문항이 인용하는 페이지는 **첫머리 Note 가 상태를 적는다.**
///   데이터 캡처(`q10`·`q11`)는 Model Monitor 없이도 쓰는 독립 기능이라는 기존
///   판정을 유지한다(`mla_questions_test.dart` 주석).
void main() {
  const dir = 'assets/content/mla';

  List<File> filesOf(String suffix) => Directory(dir)
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith(suffix))
      .toList()
    // ⚠️ `listSync()` 순서는 플랫폼마다 다르다.
    ..sort((a, b) => a.path.compareTo(b.path));

  String base(File f) => f.uri.pathSegments.last;

  List<Map<String, dynamic>> questionsOf(File f) =>
      ((json.decode(f.readAsStringSync()) as Map<String, dynamic>)['questions']
              as List)
          .cast<Map<String, dynamic>>();

  final all = <Map<String, dynamic>>[
    for (final f in filesOf('.questions.json')) ...questionsOf(f),
  ];
  final byId = <String, Map<String, dynamic>>{
    for (final q in all) q['id'] as String: q,
  };
  final mds = <String, String>{
    for (final f in filesOf('.md')) base(f): f.readAsStringSync(),
  };

  Map<String, dynamic> q(String id) => byId[id] ?? fail('$id 없음');
  String md(String id) => mds['$id.md'] ?? fail('$id.md 없음');

  String correctOf(Map<String, dynamic> x) =>
      (x['options'] as List).cast<String>()[x['correct'] as int];
  String blob(Map<String, dynamic> x) => json.encode(x);
  Map<String, String> wrongOf(Map<String, dynamic> x) =>
      (x['wrongExplanations'] as Map).map((k, v) => MapEntry('$k', '$v'));
  List<Map<String, dynamic>> sourcesOf(Map<String, dynamic> x) =>
      (x['sources'] as List).cast<Map<String, dynamic>>();
  List<String> urlsOf(Map<String, dynamic> x) =>
      [for (final s in sourcesOf(x)) '${s['url']}'];

  /// 사실 서술 필드 — **오답 보기 본문은 제외**한다(일부러 틀린 서술을 담는다).
  Map<String, String> factFields(Map<String, dynamic> x) => {
        'stem': '${x['stem']}',
        'correct': correctOf(x),
        'explanation': '${x['explanation']}',
        for (final e in wrongOf(x).entries) 'W${e.key}': e.value,
      };

  /// 가르치는 층 — `skill`(가이드 문장 전사)은 뺀다.
  String teach(Map<String, dynamic> x) =>
      ['${x['stem']}', correctOf(x), '${x['explanation']}'].join('\n');

  /// md 의 줄을 (파일:줄번호, 본문)으로 훑는다.
  Iterable<MapEntry<String, String>> mdLines() sync* {
    for (final e in mds.entries) {
      final lines = e.value.split('\n');
      for (var i = 0; i < lines.length; i++) {
        yield MapEntry('${e.key}:${i + 1}', lines[i]);
      }
    }
  }

  // ═════════════════════ 대조군 ═════════════════════

  group('대조군', () {
    test('MLA 문항·학습문서를 실제로 읽고 있다', () {
      expect(filesOf('.questions.json').length, 12);
      expect(all.length, 321, reason: '보정은 문항 수를 바꾸지 않는다');
      expect(byId.length, 321, reason: 'id 중복');
      for (final x in all) {
        expect((x['options'] as List).length, 4, reason: '${x['id']}');
      }
      expect(mds.length, 12);
      for (final e in mds.entries) {
        // ⚠️ `String.length` 는 문자 수다(한국어는 글자당 3바이트).
        expect(e.value.length, greaterThan(15000), reason: e.key);
      }
    });

    test('정답 인덱스 불변 — 손댄 39문항', () {
      // ⚠️ 리터럴은 추측이 아니라 실측값이다(보고서가 적지 않은 인덱스를
      // 추측했다가 14건 중 6건이 틀린 선례가 있다).
      const expected = <String, int>{
        'mla-t1-2-q19': 1, 'mla-t1-3-q8': 1, 'mla-t1-3-q24': 2,
        'mla-t2-1-q18': 1, 'mla-t2-2-q3': 1, 'mla-t2-2-q17': 1,
        'mla-t2-3-q11': 1, 'mla-t2-3-q14': 1, 'mla-t2-3-q15': 1,
        'mla-t2-3-q24': 0, 'mla-t3-1-q22': 0, 'mla-t3-1-q24': 0,
        'mla-t3-2-q5': 0, 'mla-t3-2-q10': 0, 'mla-t3-2-q20': 0,
        'mla-t3-3-q4': 0, 'mla-t3-3-q6': 0, 'mla-t3-3-q15': 0,
        'mla-t3-3-q16': 0, 'mla-t3-3-q23': 0, 'mla-t3-3-q24': 0,
        'mla-t4-1-q12': 0, 'mla-t4-1-q13': 0, 'mla-t4-1-q17': 0,
        'mla-t4-1-q18': 0, 'mla-t4-1-q23': 0, 'mla-t4-1-q27': 0,
        'mla-t4-2-q7': 0, 'mla-t4-2-q11': 0, 'mla-t4-2-q14': 0,
        'mla-t4-2-q18': 0, 'mla-t4-2-q32': 0, 'mla-t4-2-q33': 0,
        'mla-t4-2-q34': 0, 'mla-t4-3-q8': 0, 'mla-t4-3-q10': 0,
        'mla-t4-3-q22': 0, 'mla-t4-3-q25': 0, 'mla-t4-3-q27': 0,
      };
      expect(expected.length, 39);
      for (final e in expected.entries) {
        expect(q(e.key)['correct'], e.value, reason: '${e.key} 의 정답 인덱스가 바뀌었다');
      }
    });
  });

  // ═════════════════════ 🔴 0대 축소 ═════════════════════

  group('🔴 실시간 엔드포인트의 최소 인스턴스는 「일반 변형」에 한정해 적는다', () {
    final claim = RegExp(r'최소 (인스턴스|용량)[^.]{0,12}1 이상|최소 1대|최소 용량은 1');
    final qualifier = RegExp(r'일반|추론 컴포넌트');

    test('MLA 전수(문항 사실 필드 + md): 한정 없는 「최소 1」 단정이 없다', () {
      final offenders = <String>[];
      var seenQ = 0;
      var seenMd = 0;
      for (final x in all) {
        for (final e in factFields(x).entries) {
          if (!claim.hasMatch(e.value)) continue;
          seenQ++;
          if (!qualifier.hasMatch(e.value)) offenders.add('${x['id']} ${e.key}');
        }
      }
      for (final l in mdLines()) {
        if (!claim.hasMatch(l.value)) continue;
        seenMd++;
        if (!qualifier.hasMatch(l.value)) offenders.add(l.key);
      }
      // 대조군 — 탐지가 공허하지 않다(실측: 문항 4필드 · md 2줄).
      expect(seenQ, greaterThanOrEqualTo(3));
      expect(seenMd, greaterThanOrEqualTo(2));
      expect(offenders, isEmpty,
          reason: '공식: "An endpoint can scale to and from zero instances only if '
              'it hosts inference components" — 추론 컴포넌트를 호스팅하는 실시간 '
              '엔드포인트는 0대까지 줄어든다:\n${offenders.join('\n')}');
    });

    test('mla-t3-2-q10: 새 공식 사실과 그 출처가 있다', () {
      final x = q('mla-t3-2-q10');
      expect('${x['explanation']}', contains('추론 컴포넌트를 호스팅하는 엔드포인트뿐'));
      expect(wrongOf(x)['3'], contains('일반 프로덕션 변형'));
      expect(urlsOf(x).any((u) => u.contains('endpoint-auto-scaling-zero-instances')),
          isTrue,
          reason: '그 사실을 담는 페이지를 출처로 단다');
      // 같은 Task 의 q9 가 가르치는 것과 어긋나지 않는다.
      expect('${q('mla-t3-2-q9')['stem']}', contains('인스턴스 0대까지'));
    });
  });

  // ═════════════════════ 🟡 한정 없는 수치·단정 ═════════════════════

  group('Lambda 타임아웃 1,800초는 표준 함수의 상한이다', () {
    test('MLA 전수: 타임아웃 1,800초를 적는 자리는 Managed Instances 예외를 함께 적는다', () {
      final offenders = <String>[];
      var seen = 0;
      for (final x in all) {
        final hit = factFields(x)
            .values
            .any((v) => v.contains('1,800초') && v.contains('타임아웃'));
        if (!hit) continue;
        seen++;
        if (!blob(x).contains('Managed Instances')) offenders.add('${x['id']}');
      }
      final mdRule = RegExp(r'타임아웃[^|]{0,12}1,800초');
      var seenMd = 0;
      for (final l in mdLines()) {
        if (!mdRule.hasMatch(l.value)) continue;
        seenMd++;
        if (!l.value.contains('Managed Instances')) offenders.add(l.key);
      }
      expect(seen, greaterThanOrEqualTo(1));
      expect(seenMd, greaterThanOrEqualTo(1));
      expect(offenders, isEmpty,
          reason: '공식 Lambda quotas: "Function timeout 1,800 seconds (30 minutes). '
              'For functions using AWS Lambda Managed Instances, asynchronous '
              'invocations and event source mapping invocations (except Amazon MQ '
              'and Amazon DocumentDB) support a maximum allowed value of 5,400 '
              'seconds":\n${offenders.join('\n')}');
    });

    test('대조군: 쿨다운 「900초」 문항은 규칙의 대상이 아니다', () {
      // `mla-t3-2-q8` 은 보기에 「900초」, 오답 근거에 「Lambda 프로비저닝된
      // 동시성」이 있어 문항 단위 규칙이면 걸린다. 타임아웃을 말하지 않는다.
      final x = q('mla-t3-2-q8');
      expect(blob(x), contains('900초'));
      expect(blob(x), contains('Lambda'));
      expect(
          factFields(x).values.any((v) => v.contains('900초') && v.contains('타임아웃')),
          isFalse);
    });

    test('새 공식 수치가 문항과 md 양쪽에 있다', () {
      expect('${q('mla-t3-1-q22')['explanation']}', contains('5,400초'));
      expect('${q('mla-t3-1-q22')['stem']}', contains('Lambda Managed Instances가 아닌'));
      expect(md('mla-t3-1'), contains('5,400초'));
    });
  });

  group('Logs Insights 동시 쿼리 100개는 Logs Insights QL 의 한도다', () {
    test('MLA 전수: Logs Insights 동시 쿼리 한도를 적는 자리는 PPL·SQL 15개를 함께 적는다', () {
      final offenders = <String>[];
      var seen = 0;
      for (final x in all) {
        final b = blob(x);
        if (!b.contains('동시 쿼리') || !b.contains('Logs Insights')) continue;
        seen++;
        if (!b.contains('15개')) offenders.add('${x['id']}');
      }
      for (final l in mdLines()) {
        if (!l.value.contains('동시 쿼리') || !l.value.contains('Logs Insights')) {
          continue;
        }
        seen++;
        if (!l.value.contains('15개')) offenders.add(l.key);
      }
      expect(seen, greaterThanOrEqualTo(2), reason: '문항 1 + md 1(실측)');
      expect(offenders, isEmpty,
          reason: '공식 AnalyzingLogData: "You are limited to 100 concurrent '
              'CloudWatch Logs Insights QL per account … Additionally, you can run '
              '15 concurrent queries for either OpenSearch Service PPL or OpenSearch '
              'Service SQL":\n${offenders.join('\n')}');
    });

    test('대조군: Athena 의 「동시 쿼리」는 대상이 아니고, 100개 서술은 남아 있다', () {
      final athena = q('mla-t1-1-q18');
      expect(blob(athena), contains('동시 쿼리'));
      expect(blob(athena).contains('Logs Insights'), isFalse);
      // 수치를 지운 것이 아니라 한정했다(`mla_questions_test` 가 같은 문구를 본다).
      expect('${q('mla-t4-2-q11')['explanation']}', contains('동시 쿼리 100개'));
    });
  });

  group('Access Analyzer 정책 생성의 분석 기간', () {
    final stale = RegExp(r'대표 기간|30\s*~\s*90일|30일에서 90일');

    test('MLA 전수: 「대표 기간 30~90일」이 0건이다', () {
      final offenders = <String>[
        for (final x in all)
          if (stale.hasMatch(blob(x))) '${x['id']}',
        for (final l in mdLines())
          if (stale.hasMatch(l.value)) l.key,
      ];
      expect(offenders, isEmpty,
          reason: '공식: "You can choose a range of up to 90 days. We recommend that '
              'you choose the shortest time period possible to reduce the policy '
              'generation time." — 30일·대표 기간은 그 페이지에 없다: $offenders');
    });

    test('새 공식 사실이 문항과 md 양쪽에 있다', () {
      expect('${q('mla-t4-3-q8')['explanation']}', contains('가능한 한 짧'));
      expect('${q('mla-t4-3-q8')['explanation']}', contains('90일'));
      expect(md('mla-t4-3'), contains('가능한 한 짧은 기간'));
      expect(md('mla-t4-3'), contains('최대 90일'));
    });
  });

  group('S3 는 게이트웨이·인터페이스 엔드포인트를 둘 다 지원한다', () {
    test('MLA 전수: S3 인터페이스 엔드포인트를 부정하거나 배타로 적는 서술이 없다', () {
      final negation =
          RegExp(r'S3[^.\n]{0,40}인터페이스 엔드포인트[^.\n]{0,30}(없|불가|못|틀)');
      final offenders = <String>[
        for (final x in all)
          for (final e in factFields(x).entries)
            if (negation.hasMatch(e.value) || e.value.contains('바꿔 고르면'))
              '${x['id']} ${e.key}',
        for (final l in mdLines())
          if (negation.hasMatch(l.value) || l.value.contains('바꿔 고르면')) l.key,
      ];
      expect(offenders, isEmpty,
          reason: '공식 vpc-endpoints-s3: "Amazon S3 supports both gateway endpoints '
              'and interface endpoints" · 인터페이스 쪽은 "available for an additional '
              'cost": $offenders');
    });

    test('mla-t4-3-q22: 지문이 가름 조건(추가 요금)을 주고 오답 근거가 이유를 적는다', () {
      final x = q('mla-t4-3-q22');
      expect('${x['stem']}', contains('추가 요금이 붙지 않는'));
      final w1 = wrongOf(x)['1']!;
      expect(w1, contains('인터페이스 엔드포인트도 지원'));
      expect(w1, contains('추가 요금'));
      expect(w1.contains('문서가 S3에 안내하는 것은 게이트웨이 엔드포인트입니다. 라우트 테이블 연결이 핵심'),
          isFalse,
          reason: '보기가 왜 틀렸는지 말하지 않는 회피형 반박이었다');
      expect(md('mla-t4-3'), contains('S3 자체는 인터페이스 엔드포인트도 지원'));
    });
  });

  // ═════════════════════ 🟡 출처·귀속 ═════════════════════

  group('출처가 그 문항이 단정하는 사실을 담는다 (§2-B 8문항)', () {
    // (문항, 걷어낸 URL 조각들, 새로 단 URL 조각) — 옛 0건 + 새 있음을 쌍으로 본다.
    const swaps = <(String, List<String>, String)>[
      ('mla-t1-3-q8', ['mlrel03-bp04'], 'aws.amazon.com/what-is/ai-bias'),
      ('mla-t1-3-q24', ['mlrel03-bp04'], 'aws.amazon.com/what-is/ai-bias'),
      ('mla-t2-2-q3', ['distributed-training-strategies'], 'data-parallel-config.html'),
      ('mla-t2-3-q11', ['mlperf04-bp02'], 'machine-learning/latest/dg/evaluating_models.html'),
      (
        'mla-t3-2-q5',
        ['endpoint-auto-scaling-policy.html', 'target-tracking-scaling-policy-overview'],
        'multi-model-endpoints-autoscaling.html'
      ),
      ('mla-t3-3-q15', <String>[], 'dg/build-and-manage-steps.html'),
      ('mla-t3-3-q16', <String>[], 'dg/build-and-manage-steps.html'),
      ('mla-t3-3-q24', ['mlops04-bp01'], 'machine-learning-lens/mlperf06-bp05.html'),
    ];

    for (final (id, dropped, added) in swaps) {
      test('$id: 옛 출처 없음 + 새 출처 있음', () {
        final urls = urlsOf(q(id));
        for (final d in dropped) {
          expect(urls.any((u) => u.contains(d)), isFalse,
              reason: '$d 는 이 문항이 단정하는 사실을 담지 않는다');
        }
        expect(urls.any((u) => u.contains(added)), isTrue,
            reason: '지우기만 하면 안 된다 — 그 사실을 담는 페이지가 있어야 한다');
        for (final s in sourcesOf(q(id))) {
          expect('${s['title']}', isNotEmpty);
        }
      });
    }

    test('mla-t3-3-q16: 출처 제목이 그 페이지에 없는 사실을 약속하지 않는다', () {
      // `pipelines-overview.html` 에는 DependsOn·parallel 이 0건이다.
      for (final s in sourcesOf(q('mla-t3-3-q16'))) {
        if ('${s['url']}'.contains('pipelines-overview')) {
          expect('${s['title']}'.contains('DependsOn'), isFalse);
          expect('${s['title']}'.contains('병렬'), isFalse);
        }
      }
    });

    test('구서비스 문서는 라벨을 달고 인용한다', () {
      final s = sourcesOf(q('mla-t2-3-q11'))
          .firstWhere((s) => '${s['url']}'.contains('machine-learning/latest/dg/'));
      expect('${s['title']}', contains('구서비스'),
          reason: '공식 첫머리: "We are no longer updating the Amazon Machine '
              'Learning service or accepting new users for it"');
    });

    test('교체한 정본 URL 이 같은 Task 학습문서 출처에도 있다', () {
      // 문항 가드는 `.md` 를 보지 않는다 — 문항만 고치면 문서가 조용히 뒤처진다.
      const pairs = <String, List<String>>{
        'mla-t1-3': ['aws.amazon.com/what-is/ai-bias'],
        'mla-t2-2': ['dg/data-parallel-config.html'],
        'mla-t2-3': ['machine-learning/latest/dg/evaluating_models.html'],
        'mla-t3-2': ['dg/multi-model-endpoints-autoscaling.html'],
        'mla-t3-3': ['dg/build-and-manage-steps.html', 'mlperf06-bp05.html'],
        'mla-t4-2': [
          'optimize-costs-microsoft-workloads/savings-plans.html',
          'dg/multi-model-endpoints-autoscaling.html',
        ],
      };
      for (final e in pairs.entries) {
        for (final u in e.value) {
          expect(md(e.key), contains(u), reason: '${e.key}.md 출처에 $u 가 없다');
        }
      }
    });

    test('출처를 덧붙인 md 의 「출처」 번호 목록이 1부터 끊김 없이 이어진다', () {
      final item = RegExp(r'^(\d+)\. .* — https?://\S+\s*$');
      for (final id in ['mla-t1-3', 'mla-t2-3', 'mla-t3-2', 'mla-t3-3', 'mla-t4-2']) {
        final text = md(id);
        final start = text.indexOf('### 📌 출처');
        expect(start, greaterThan(0), reason: id);
        final nums = <int>[
          for (final l in text.substring(start).split('\n'))
            if (item.hasMatch(l.trimRight()))
              int.parse(item.firstMatch(l.trimRight())!.group(1)!),
        ];
        expect(nums.length, greaterThan(40), reason: '$id: 목록을 못 읽었다');
        expect(nums, [for (var i = 1; i <= nums.length; i++) i], reason: id);
      }
    });
  });

  group('지문·해설의 귀속이 실제 근거와 맞는다', () {
    test('MLA 전수: re:Post 를 인용하는 문항의 지문은 「문서가」로 귀속하지 않는다', () {
      final docAttr = RegExp(r'문서가|공식 문서');
      final offenders = <String>[];
      var seen = 0;
      for (final x in all) {
        if (!urlsOf(x).any((u) => u.contains('repost.aws'))) continue;
        seen++;
        if (docAttr.hasMatch('${x['stem']}')) offenders.add('${x['id']}');
        // re:Post 만으로 서지 않는다 — 공식 문서 출처가 함께 있다.
        if (!urlsOf(x).any((u) => u.contains('docs.aws.amazon.com'))) {
          offenders.add('${x['id']} (docs 출처 없음)');
        }
      }
      expect(seen, greaterThanOrEqualTo(5), reason: '실측 8문항 — 0이면 공허하다');
      expect(offenders, isEmpty,
          reason: 're:Post 지식 센터는 보조 근거다. 지문에 「문서가 제시하는」을 '
              '박아 두면 근거가 지식 센터뿐일 때 귀속이 거짓이 된다: $offenders');
    });

    test('mla-t4-2-q32: 지문이 정책의 지표를 말하고 근거가 공식 문서로 선다', () {
      final x = q('mla-t4-2-q32');
      expect('${x['stem']}', contains('CPUUtilization'),
          reason: '지문에 정책의 지표가 없으면 정답이 성립하지 않는다');
      final urls = urlsOf(x);
      expect(urls.first, contains('docs.aws.amazon.com'));
      expect(urls.where((u) => u.contains('docs.aws.amazon.com')).length,
          greaterThanOrEqualTo(2));
      expect(urls.any((u) => u.contains('target-tracking-scaling-policy-overview')),
          isTrue,
          reason: '공식: "The metric must be a valid utilization metric and describe '
              'how busy a scalable target is. The metric value must increase or '
              'decrease proportionally to the capacity of the scalable target"');
      expect(urls.any((u) => u.contains('multi-model-endpoints-autoscaling')), isTrue,
          reason: '공식: "We strongly recommend using this metric."');
      final rp = sourcesOf(x).firstWhere((s) => '${s['url']}'.contains('repost.aws'));
      expect('${rp['title']}', contains('보조 출처'));
      // re:Post 에만 있던 세부(워밍업 인스턴스의 집계 제외)는 걷었다.
      expect('${x['explanation']}'.contains('워밍업'), isFalse);
    });

    test('mla-t4-2-q33: 「SageMaker 문서가 제시하는 순서」라는 귀속이 없다', () {
      final x = q('mla-t4-2-q33');
      expect('${x['stem']}'.contains('모범 사례에서'), isFalse);
      expect('${x['explanation']}'.contains('문서가 제시하는'), isFalse,
          reason: 'inference-cost-optimization.html 에는 right-size·before 가 0건이다');
      expect(urlsOf(x).first,
          contains('optimize-costs-microsoft-workloads/savings-plans.html'),
          reason: '공식 규범 가이드: "Right size your resources before you purchase '
              'Savings Plans."');
      expect('${x['explanation']}', contains('규범 가이드'));
      expect(md('mla-t4-2').contains('문서의 순서는'), isFalse);
      expect(md('mla-t4-2'), contains('AWS 규범 가이드의 권고 순서'));
    });

    test('mla-t4-2-q7 · mla-t3-1-q24: 지문에서 「문서가」를 걷고 공식 근거를 보탰다', () {
      final q7 = q('mla-t4-2-q7');
      expect('${q7['stem']}'.contains('문서가'), isFalse);
      expect(urlsOf(q7).first, contains('dg/monitoring-cloudwatch.html'),
          reason: '공식 OverheadLatency 정의: "can vary depending on multiple '
              'factors, including request and response payload sizes, request '
              'frequency, and authentication/authorization of the request"');
      expect('${q('mla-t3-1-q24')['stem']}'.contains('공식 문서가'), isFalse);
    });

    test('mla-t2-1-q18: 오답 근거의 전제가 지문에 있고 근거 없는 일반화가 없다', () {
      final x = q('mla-t2-1-q18');
      expect('${x['stem']}', contains('같은 이미지를 다시 분석하는 일은 없다'));
      expect(wrongOf(x)['3'], contains('사진이 모두 새것'));
      expect('${x['explanation']}'.contains('소량이고 변동이 큰'), isFalse,
          reason: '인용한 어느 페이지에도 없는 일반화였다');
    });
  });

  // ═════════════════════ 🟡 닫힌 기능의 상태 ═════════════════════

  group('닫힌 기능을 가르치는 문항에 상태가 있다 (§2-D)', () {
    final status = RegExp(r'신규 고객|닫혀|닫힌');

    test('MLA 전수: 가르치는 층에서 Debugger·Role Manager 를 들면 상태를 적는다', () {
      for (final name in ['Debugger', 'Role Manager']) {
        final offenders = <String>[];
        var seen = 0;
        for (final x in all) {
          if (!teach(x).contains(name)) continue;
          seen++;
          if (!status.hasMatch(blob(x))) offenders.add('${x['id']}');
        }
        expect(seen, greaterThanOrEqualTo(2), reason: '$name: 탐지가 공허하다');
        expect(offenders, isEmpty,
            reason: '$name 는 Maintenance 다(인용 페이지 첫머리 Note: "…is no '
                'longer open to new customers. Existing customers can continue to '
                'use the service as normal"): $offenders');
      }
    });

    test('대조군: `skill` 에만 Role Manager 가 있는 문항은 대상이 아니다', () {
      // 가이드 4.3 K1 문장이 「SageMaker Role Manager」를 예시로 든다.
      final x = q('mla-t4-3-q9');
      expect('${x['skill']}', contains('Role Manager'));
      expect(teach(x).contains('Role Manager'), isFalse);
    });

    test('MLA 전수: Model Monitor 페이지를 근거로 가르치는 문항은 해설에 상태가 있다', () {
      // ⚠️ 문자열이 아니라 **출처 URL** 로 센다(머리 주석).
      bool mmPage(String u) =>
          u.contains('/dg/model-monitor-') && !u.contains('data-capture');
      final offenders = <String>[];
      var seen = 0;
      for (final x in all) {
        if (!urlsOf(x).any(mmPage)) continue;
        seen++;
        if (!'${x['explanation']}'.contains('신규 고객')) offenders.add('${x['id']}');
      }
      expect(seen, greaterThanOrEqualTo(12), reason: '실측 14문항');
      expect(offenders, isEmpty,
          reason: '그 페이지들의 첫머리 Note 가 상태를 적는다: $offenders');
      for (final id in [
        'mla-t4-1-q12', 'mla-t4-1-q13', 'mla-t4-1-q17', 'mla-t4-1-q18',
      ]) {
        expect('${q(id)['explanation']}',
            contains('⚠️ Model Monitor는 현재 신규 고객을 받지 않습니다(기존 고객은 사용 가능).'),
            reason: '$id: 정본 문구를 그대로 쓴다(문구를 새로 만들지 않는다)');
      }
    });

    test('대조군: 데이터 캡처 문항은 제외한다는 기존 판정을 뒤집지 않았다', () {
      for (final id in ['mla-t4-1-q10', 'mla-t4-1-q11']) {
        expect(urlsOf(q(id)).any((u) => u.contains('data-capture')), isTrue);
        expect('${q(id)['explanation']}'.contains('신규 고객'), isFalse,
            reason: '$id: 데이터 캡처는 Model Monitor 없이도 쓰는 독립 기능이다');
      }
    });

    test('MLA 전수: 「현재 신규 고객을 받지 않습니다」 뒤에 기존 고객 안내가 붙는다', () {
      final bare = RegExp(r'현재 신규 고객을 받지 않습니다(?!\(기존 고객은 사용 가능\))');
      final offenders = [
        for (final x in all)
          if (bare.hasMatch(blob(x))) '${x['id']}',
      ];
      final good = all
          .where((x) => blob(x).contains('현재 신규 고객을 받지 않습니다(기존 고객은 사용 가능)'))
          .length;
      expect(good, greaterThanOrEqualTo(20), reason: '정본 문구가 실제로 쓰인다');
      expect(offenders, isEmpty,
          reason: 'Maintenance 는 종료가 아니다 — 기존 고객은 계속 쓴다: $offenders');
    });

    test('mla-t4-3-q10: Role Manager 를 과거형으로 적지 않는다', () {
      final b = blob(q('mla-t4-3-q10'));
      expect(b.contains('제공하던'), isFalse);
      expect(b.contains('제공했습니다'), isFalse,
          reason: '과거형은 「사라졌다」로 읽힌다 — 기존 고객은 지금도 쓴다');
    });

    test('Debugger 2문항은 기존 가드가 지키는 사실을 그대로 갖는다', () {
      expect(correctOf(q('mla-t2-3-q14')), contains('vanishing_gradient'));
      final q15 = blob(q('mla-t2-3-q15'));
      expect(q15, contains('20'));
      expect(q15, contains('추가 비용'));
    });
  });

  // ═════════════════════ 🟢 품질 ═════════════════════

  group('🟢 저작 과정 메모 · 오답 근거의 상태 · 범위 · 출처 세부', () {
    test('MLA 전수(전 필드 + 출처 제목): 저작 과정 메모가 없다', () {
      // `mla_questions_test` 의 M2 가드는 출처 제목을 보지 않고 아래 넷을 모른다.
      final memo = RegExp(r'에서 확인됨|확인된 연동|이 수준까지만|해석하지 않습니다');
      final offenders = <String>[];
      var titles = 0;
      for (final x in all) {
        final texts = <String>[
          '${x['stem']}',
          '${x['explanation']}',
          ...(x['options'] as List).cast<String>(),
          ...wrongOf(x).values,
          for (final s in sourcesOf(x)) '${s['title']}',
        ];
        titles += sourcesOf(x).length;
        if (texts.any(memo.hasMatch)) offenders.add('${x['id']}');
      }
      expect(titles, greaterThan(500), reason: '출처 제목까지 훑고 있다');
      expect(offenders, isEmpty,
          reason: '학습자용 문장에 작성자의 검증 상태를 적지 않는다: $offenders');
    });

    test('mla-t4-1-q23: 메모 대신 사실을 적는다', () {
      expect(wrongOf(q('mla-t4-1-q23'))['1'], contains('4xx 응답으로 돌아오지 않는 실패'),
          reason: '공식: Invocation4XXErrors 는 "requests where the model returned '
              'a 4xx HTTP response code" 만 센다');
    });

    test('오답 근거가 「닫혀 있다」를 그 보기가 틀린 이유로 들지 않는다 (3문항)', () {
      final closed = RegExp(r'닫힌|닫혔|닫혀');
      expect(closed.hasMatch(wrongOf(q('mla-t3-3-q23'))['2']!), isFalse);
      final w18 = wrongOf(q('mla-t4-2-q18'))['2']!;
      expect(closed.hasMatch(w18), isFalse);
      expect(w18, contains('전제 조건이 아닙니다'));
      final w34 = wrongOf(q('mla-t4-2-q34'))['1']!;
      expect(closed.hasMatch(w34), isFalse,
          reason: '기존 고객은 Debugger 를 쓸 수 있으므로 상태는 이유가 되지 못한다');
      expect(w34, contains('CloudWatch'));
      // 상태 자체는 가르치는 층(해설)에 남아 있다.
      expect('${q('mla-t4-2-q34')['explanation']}', contains('신규 고객에게 닫혀'));
      expect('${q('mla-t4-2-q34')['explanation']}'.contains('100밀리초'), isFalse,
          reason: '인용한 두 페이지에 없는 세부였다');
    });

    test('MLA 전수: 범위 외 서비스가 정답 보기에 든 문항은 해설에 범위 메모가 있다', () {
      // 공식 ko 「범위 외 AWS 서비스」 목록(2026-11-17 실측 100개). ⚠️ 목록이 스스로
      // 「전체 목록이 아니다」라고 적으므로 **이름이 올라 있는 것만** 본다.
      const outOfScope = <String>[
        'AWS Clean Rooms', 'Amazon DataZone', 'Amazon FinSpace', 'Amazon AppFlow',
        'Amazon MQ', 'Amazon Simple Workflow Service', 'Amazon Chime',
        'Amazon Connect', 'Amazon Honeycode', 'Amazon Pinpoint', 'Amazon SES',
        'AWS Supply Chain', 'AWS Wickr', 'Amazon WorkDocs', 'Amazon WorkMail',
        'AWS Application Cost Profiler', 'AWS App Runner', 'AWS Elastic Beanstalk',
        'Amazon Lightsail', 'AWS Outposts', 'AWS Activate for Startups', 'AWS IQ',
        'AWS re:Post Private', 'AWS Application Composer', 'AWS CloudShell',
        'Amazon CodeCatalyst', 'AWS Fault Injection Service', 'Amazon AppStream 2.0',
        'Amazon WorkSpaces', 'AWS Amplify', 'AWS AppSync', 'AWS Device Farm',
        'Amazon Location Service', 'AWS IoT 1-Click', 'AWS IoT Core',
        'AWS IoT Device Defender', 'AWS IoT Device Management', 'AWS IoT Events',
        'AWS IoT FleetWise', 'AWS IoT Greengrass', 'AWS IoT RoboRunner',
        'AWS IoT SiteWise', 'AWS IoT TwinMaker', 'AWS DeepRacer', 'AWS HealthImaging',
        'AWS HealthOmics', 'Amazon Monitron', 'AWS Panorama', 'AWS AppConfig',
        'AWS Control Tower', 'AWS Launch Wizard', 'AWS License Manager',
        'Amazon Managed Grafana', 'AWS Proton', 'AWS Resilience Hub',
        'AWS Resource Explorer', 'AWS Telco Network Builder', 'AWS User Notifications',
        'Amazon Elastic Transcoder', 'AWS Elemental', 'Amazon Interactive Video Service',
        'Amazon Nimble Studio', 'AWS Application Discovery Service',
        'AWS Application Migration Service', 'AWS Mainframe Modernization',
        'AWS Migration Hub', 'AWS App Mesh', 'AWS Cloud Map', 'AWS Global Accelerator',
        'AWS Private 5G', 'Amazon Route 53', 'Amazon VPC IP Address Manager',
        'AWS Artifact', 'AWS Audit Manager', 'AWS Certificate Manager', 'AWS CloudHSM',
        'Amazon Cognito', 'Amazon Detective', 'AWS Directory Service',
        'AWS Firewall Manager', 'Amazon GuardDuty', 'Amazon Inspector',
        'AWS Payment Cryptography', 'AWS Private CA', 'AWS Resource Access Manager',
        'AWS Security Hub', 'AWS Shield', 'AWS Signer', 'Amazon Verified Permissions',
        'AWS WAF', 'AWS Elastic Disaster Recovery',
      ];
      final hits = <String>{
        for (final x in all)
          if (outOfScope.any(correctOf(x).contains)) '${x['id']}',
      };
      // 탐지 집합을 리터럴로 고정한다 — 늘면 「범위 외 서비스를 정답으로 쓴 문항이
      // 생겼다」, 줄면 「문항이 교체됐다」를 알린다(CLF 선례).
      expect(hits, {'mla-t3-2-q20', 'mla-t4-3-q27'});
      for (final id in hits) {
        expect('${q(id)['explanation']}', contains('범위 외 서비스 목록'), reason: id);
      }
      expect(outOfScope.any(correctOf(q('mla-t1-3-q1')).contains), isFalse,
          reason: '대조군 — 목록이 아무 정답이나 잡지 않는다');
    });

    test('출처 세부: 근거가 사라진 문장을 걷고 세부를 담는 페이지를 달았다', () {
      expect('${q('mla-t4-3-q25')['explanation']}'.contains('CloudTrail과 Config가 함께'),
          isFalse,
          reason: '백서 재소싱 뒤 인용 페이지에 CloudTrail 이 0건이다');
      expect('${q('mla-t4-3-q25')['explanation']}', contains('VPC Flow Logs'));
      expect(urlsOf(q('mla-t3-3-q6')).any((u) => u.contains('codepipeline/latest/userguide/limits.html')),
          isTrue,
          reason: '폴링 파이프라인 300개(고정)는 Quotas 페이지에 있다');
      expect(urlsOf(q('mla-t3-3-q4')).any((u) => u.contains('userguide/approvals.html')),
          isTrue,
          reason: 'approval 액션의 Amazon SNS 통합은 이 페이지에 있다');
      expect(urlsOf(q('mla-t2-3-q24')).any((u) => u.contains('shadow-tests-create.html')),
          isTrue,
          reason: '기간(기본 7일·최소 1시간·최대 30일)과 데이터 캡처 옵션');
    });

    test('mla-t1-2-q19 · mla-t2-2-q17 · mla-t4-1-q27 · mla-t4-2-q14 의 잔여', () {
      expect('${q('mla-t1-2-q19')['explanation']}',
          contains('⚠️ A2I는 현재 신규 고객을 받지 않습니다(기존 고객은 사용 가능).'));
      final renate = sourcesOf(q('mla-t2-2-q17'))
          .firstWhere((s) => '${s['url']}'.contains('renate'));
      expect('${renate['title']}', contains('보조 출처(AWS 블로그)'));
      expect('${q('mla-t4-1-q27')['explanation']}', contains('Enable continuous improvement'));
      expect('${q('mla-t4-2-q14')['explanation']}'.contains('Athena'), isFalse,
          reason: '인용한 두 페이지에 Athena 가 0건이다');
    });
  });

  // ═════════════════════ 학습문서 ═════════════════════

  test('본문을 고친 md 는 lastVerified 를 올렸다', () {
    // ⚠️ 하한 비교다 — 날짜를 리터럴로 고정하면 다음 정정이 이 단정을 깬다.
    final re = RegExp(r'^lastVerified: (\d{4}-\d{2}-\d{2})\s*$', multiLine: true);
    for (final id in [
      'mla-t1-3', 'mla-t2-3', 'mla-t3-1', 'mla-t3-2', 'mla-t3-3', 'mla-t4-2', 'mla-t4-3',
    ]) {
      final m = re.firstMatch(md(id));
      expect(m, isNotNull, reason: id);
      expect(m!.group(1)!.compareTo('2026-11-17'), greaterThanOrEqualTo(0), reason: id);
    }
  });
}
