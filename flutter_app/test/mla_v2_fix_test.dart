import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 2026-11-17 전 콘텐츠 검증 **2단계(보정) — MLA-C01** 가드.
///
/// 1단계 보고서 정본: `docs/audits/2026-11-17-full-verify/mla.md`
/// 반영 보고서: `docs/audits/2026-11-17-full-verify/mla-phase2.md`
///
/// **MLA 321문항은 전부 `verified: true` 라이브**다. 이 배치는 🔴 1건 · 🟡 23문항 ·
/// 🟢 다섯 묶음을 닫았고 **정답 인덱스는 한 건도 바뀌지 않았다**(전수 분포
/// 224·78·14·5 불변을 이 파일이 고정한다).
///
/// ## ⚠️⚠️ `verified` 상태를 단정하지 않는다
///
/// 2026-11-13 검수자의 첫 SCS flip 이 「전 문항 드래프트」류 대조군 때문에 레드로
/// 끝났다. 그래서 여기서는 **구조 단정**(파일별 문항 수 · 보기 4개 · 정답 인덱스
/// 분포 · 마크다운 0)으로 대신한다.
///
/// ## ⚠️ 사실 단정은 전수 집계형이다
///
/// 문항별 리터럴 가드는 **어형 하나로 뚫린다**(「프로비저닝 처리량」 ↔ 「프로비저닝
/// **된** 처리량」로 네 번 새어 나간 선례). 그래서 「최소 인스턴스가 1」·Lambda
/// 타임아웃·Logs Insights 동시 쿼리 같은 사실 단정은 **md 12편 + 문항 12파일 전수**를
/// 센다. 반대로 **출처 URL 은 어형이 없으므로** 문항별 쌍 단정을 쓴다.
///
/// ## 공식 근거 (2단계가 직접 재측정했다 — 전부 `curl -sL` `200 r=0`)
///
/// - `sagemaker/latest/dg/endpoint-auto-scaling-zero-instances.html` —
///   "An endpoint can scale to and from zero instances **only if it hosts
///   inference components**."
/// - `lambda/latest/dg/gettingstarted-limits.html` — "Code can run for up to 15
///   minutes in a single invocation (**up to 90 minutes for Lambda Managed
///   Instances functions invoked asynchronously or through any event source
///   mapping** except Amazon MQ and Amazon DocumentDB)".
/// - `AmazonS3/latest/userguide/privatelink-interface-endpoints.html` — "You can
///   use **two types of VPC endpoints** to access Amazon S3: gateway endpoints
///   and interface endpoints" + "gateway endpoints, **which are not billed**".
///   SageMaker `train-vpc.html` 은 인터페이스 엔드포인트가 안 된다고 **적지 않는다**
///   (`not supported` 0건).
/// - `IAM/latest/UserGuide/access-analyzer-policy-generation.html` — "You can
///   choose a range of up to 90 days. **We recommend that you choose the
///   shortest time period possible**". ⚠️ `30 days` 0건 · `representative` 0건.
/// - `AmazonCloudWatch/latest/logs/AnalyzingLogData.html` — "limited to **100
///   concurrent CloudWatch Logs Insights QL** per account … **you can run 15
///   concurrent queries for either OpenSearch Service PPL or OpenSearch Service
///   SQL**".
/// - `aws.amazon.com/what-is/ai-bias/` — Label / Selection / Recall / Algorithm /
///   Measurement bias 정의가 **한 페이지에** 있다(옛 출처 `mlrel03-bp04.html` 은
///   편향 유형을 **이름만** 들고 `label bias` 0건).
/// - `sagemaker/latest/dg/data-parallel-config.html` — "batch sizes should
///   increase proportionally … increase the learning rate … **Linear Scaling
///   Rule**"(옛 출처 `distributed-training-strategies.html` 은 `learning rate` 0건).
/// - `machine-learning/latest/dg/evaluating_models.html` — "it **rewards models
///   that can \"remember\" the training data, as opposed to generalizing from
///   it**". ⚠️ 첫 문장이 "We are no longer updating the Amazon Machine Learning
///   service" 라 **출처 제목에 구서비스 라벨**을 붙인다.
/// - `sagemaker/latest/dg/multi-model-endpoints-autoscaling.html` —
///   "`SageMakerVariantInvocationsPerInstance` … **We strongly recommend using
///   this metric.**"
/// - `sagemaker/latest/dg/build-and-manage-steps.html` — "When a step does not
///   depend on any other step, **it runs immediately upon pipeline execution** …
///   `ParallelismConfiguration`" + "specifying a step's **`DependsOn`**".
/// - `wellarchitected/latest/machine-learning-lens/mlperf06-bp05.html` —
///   안티패턴 "**Retraining on a fixed schedule regardless of model performance
///   or data patterns**" + 재훈련 조건 네 가지("business requirements,
///   performance degradation beyond defined thresholds, detection of data drift
///   above acceptable limits, and **availability of new training data**").
/// - `sagemaker/latest/dg/debugger-built-in-rules.html` 첫 Note — "Amazon
///   SageMaker Debugger is **no longer open to new customers**."
/// - `sagemaker/latest/dg/role-manager-availability-change.html` — "Amazon
///   SageMaker Role Manager is **no longer open to new customers. Existing
///   customers can continue to use the service as normal.**"
/// - `sagemaker/latest/dg/monitoring-cloudwatch.html` — `Invocation4XXErrors`
///   "where the model returned a **4xx** HTTP response code" ↔
///   `InvocationModelErrors` "includes 4XX/5XX status codes, **low-level socket
///   errors**, malformed HTTP responses, and **request timeouts**".
/// - `ko_kr/aws-certification/latest/machine-learning-engineer-associate-01/
///   mla-01-out-of-scope-services.html` — **AWS Artifact · Amazon Inspector** 가
///   「보안, ID 및 규정 준수」 범주에 실재한다(⚠️ 그 페이지가 스스로 「전체 목록이
///   아니다」라고 적으므로 **목록에 없는 이름은 범위 밖으로 단정하지 않는다**).
/// - `sagemaker/latest/dg/inference-cost-optimization.html` — `right-siz` **0건** ·
///   `before` **0건**(대조군 `Savings Plans` 2건) → 「약정 전에 적정 규모 조정」은
///   **AWS 블로그에만** 있다. 그래서 수치를 지우지 않고 **귀속만** 블로그로 바꿨다.
void main() {
  const dir = 'assets/content/mla';

  List<Map<String, dynamic>> allQuestions() {
    final out = <Map<String, dynamic>>[];
    for (final f in questionFiles()) {
      final map = json.decode(f.readAsStringSync()) as Map<String, dynamic>;
      for (final q in (map['questions'] as List)) {
        out.add(q as Map<String, dynamic>);
      }
    }
    return out;
  }

  Map<String, dynamic> byId(String id) =>
      allQuestions().firstWhere((q) => q['id'] == id);

  /// 문항 전체(지문·보기·해설·오답 근거·`skill`·출처 제목·URL).
  String blob(Map<String, dynamic> q) => json.encode(q);

  /// **가르치는 층** — 오답 보기·출처 제목만이면 아니다.
  /// 2026-11-06 AIF Model Monitor 교훈: 오답 보기를 반박하는 문장에 상태를 달면
  /// 그 상태가 그 보기를 틀리게 만든 이유처럼 읽혀 **거짓이 된다**.
  String teaching(Map<String, dynamic> q) => <String>[
        q['skill'] as String? ?? '',
        q['stem'] as String? ?? '',
        (q['options'] as List).cast<String>()[q['correct'] as int],
        q['explanation'] as String? ?? '',
      ].join('\n');

  List<String> sourceUrls(Map<String, dynamic> q) => (q['sources'] as List)
      .map((s) => (s as Map<String, dynamic>)['url'] as String)
      .toList();

  Map<String, String> docs() {
    final out = <String, String>{};
    for (final f in Directory(dir)
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.md'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path))) {
      out[f.uri.pathSegments.last] = f.readAsStringSync();
    }
    return out;
  }

  // ══════════════════════════ 대조군 ══════════════════════════

  test('대조군: MLA 문항 321개와 학습문서 12편을 실제로 읽고 있다', () {
    // 0건 통과가 "파일을 못 읽어서"일 수 있다 — 이 단정을 먼저 통과시킨다.
    expect(allQuestions().length, 321);
    expect(docs().length, 12);
    expect(questionFiles().length, 12);
  });

  test('구조 불변: 보기 4개 · 정답 인덱스 분포 · 문항 필드에 마크다운 0', () {
    // ⚠️ `verified` 를 단정하지 않는다(사람의 flip 을 레드로 만들지 않기 위해).
    // 「정답 인덱스 변경 0건」을 **분포**로 고정한다 — 2026-11-17 1단계 실측값이다.
    final qs = allQuestions();
    final dist = <int, int>{};
    for (final q in qs) {
      expect((q['options'] as List).length, 4, reason: '${q['id']}');
      dist[q['correct'] as int] = (dist[q['correct'] as int] ?? 0) + 1;
      final b = blob(q);
      expect(b.contains('**'), isFalse, reason: '${q['id']}: 문항 렌더는 평문 Text 다');
      expect(b.contains(']('), isFalse, reason: '${q['id']}: 마크다운 링크는 렌더되지 않는다');
    }
    expect(dist, {0: 224, 1: 78, 2: 14, 3: 5});
  });

  // ═══════════════════ §1 🔴 0대 축소는 추론 컴포넌트 전제 ═══════════════════

  test('🔴 §1 전수: 「최소 인스턴스가 1」은 일반 변형 한정과 함께 쓴다', () {
    // 공식: "An endpoint can scale to and from zero instances **only if it
    // hosts inference components**." → 한정 없는 단정은 거짓 일반화다.
    // ⚠️ `mla-t3-2-q10` 의 `wrongExplanations["3"]` 이 그 자리였고, 같은 Task 의
    // `q9`·`q13` 과 `mla-t3-1-q9` 는 처음부터 올바르게 한정하고 있었다.
    // ⚠️⚠️ **문장 단위로 센다.** 문항·필드 단위로 보면 같은 문항의 다른 문장이나
    // 출처 제목이 「추론 컴포넌트」를 담고 있어서 한정이 빠진 문장을 통과시킨다
    // (민감도 측정에서 실제로 그렇게 새어 나갔다 — 그래서 범위를 좁혔다).
    final trigger = RegExp(r'최소 인스턴스가 1|최소 용량은 1');
    final hits = <String>[];
    final offenders = <String>[];
    for (final q in allQuestions()) {
      final fields = <String>[
        q['skill'] as String? ?? '',
        q['stem'] as String? ?? '',
        q['explanation'] as String? ?? '',
        ...(q['options'] as List).cast<String>(),
        ...((q['wrongExplanations'] as Map?)?.values ?? const []).cast<String>(),
        ...(q['sources'] as List)
            .map((s) => (s as Map<String, dynamic>)['title'] as String),
      ];
      var hit = false;
      for (final f in fields) {
        for (final sentence in f.split(RegExp(r'(?<=다\.)\s*'))) {
          if (!trigger.hasMatch(sentence)) continue;
          hit = true;
          if (!sentence.contains('일반') && !sentence.contains('추론 컴포넌트')) {
            offenders.add('${q['id']} :: $sentence');
          }
        }
      }
      if (hit) hits.add(q['id'] as String);
    }
    expect(offenders, isEmpty,
        reason: '0대까지 줄어드는 것은 추론 컴포넌트를 호스팅하는 엔드포인트뿐이다: $offenders');
    // 대조군 — 탐지 집합이 비면 위 0건은 아무것도 보장하지 않는다.
    expect(hits, ['mla-t3-1-q9', 'mla-t3-2-q10', 'mla-t3-2-q13']);
    // md 는 처음부터 옳게 적었다(역방향 잔존이었다).
    for (final e in docs().entries) {
      expect(trigger.hasMatch(e.value), isFalse, reason: '${e.key}: md 는 다른 문구로 적는다');
    }
  });

  test('🔴 §1 mla-t3-2-q10: 0대 축소 전제를 적는 공식 출처가 붙었다', () {
    final q = byId('mla-t3-2-q10');
    expect(q['correct'], 0, reason: '정답 인덱스 불변');
    expect(sourceUrls(q),
        contains(
            'https://docs.aws.amazon.com/sagemaker/latest/dg/endpoint-auto-scaling-zero-instances.html'),
        reason: '기존 두 출처(serverless-endpoints · inference-cost-optimization)에는 '
            '0대 축소 규칙이 없다 — 「URL 은 200인데 그 페이지에 그 사실이 없다」를 닫았다');
    final b = blob(q);
    expect(b.contains('0대까지 줄어드는지와 스케일링 정책이 필요한지'), isFalse,
        reason: '옛 해설 끝 문장(같은 거짓 전제)');
    expect(b.contains('추론 컴포넌트를 호스팅하는 엔드포인트뿐'), isTrue);
  });

  // ═══════════════════ §2-A 정답 유일성·지문 조건 ═══════════════════

  test('§2-A 전수: Lambda 함수 타임아웃 900초 단정에 표준 한정과 예외가 붙었다', () {
    // ⚠️ 트리거를 `Lambda` + `900초` 로 넓히면 **Firehose 버퍼 간격 0–900초** ·
    // `InvocationTimeoutSeconds 기본 900초` · Glue 배치 창 · 쿨다운 기본값이 전부
    // 걸린다(실측 md 4편 · 문항 2개). 함수 **타임아웃 상한** 단정만 본다.
    final trigger = RegExp(r'타임아웃 상한|상한이 900초|타임아웃 \*\*900초');
    final allowed = RegExp(r'Managed Instances|표준');
    final hits = <String>[];
    final offenders = <String>[];
    for (final q in allQuestions()) {
      final b = blob(q);
      if (!trigger.hasMatch(b)) continue;
      hits.add(q['id'] as String);
      if (!allowed.hasMatch(b)) offenders.add(q['id'] as String);
    }
    for (final e in docs().entries) {
      for (final line in e.value.split('\n')) {
        if (!trigger.hasMatch(line)) continue;
        hits.add(e.key);
        if (!allowed.hasMatch(line)) offenders.add(e.key);
      }
    }
    expect(offenders, isEmpty,
        reason: '공식은 "up to 90 minutes for Lambda Managed Instances functions '
            'invoked asynchronously or through any event source mapping" 을 함께 적는다: '
            '$offenders');
    expect(hits, ['mla-t3-1-q22', 'mla-t3-1.md'],
        reason: '대조군 — 탐지 집합이 바뀌면 다른 900초 사실까지 번진 것이다');
  });

  test('§2-A S3 VPC 엔드포인트: 배타 단정이 사라지고 두 유형 서술이 들어왔다', () {
    final docsMap = docs();
    // 옛 배타 단정(라이브 학습문서 `mla-t4-3.md`).
    const stale = '- **S3는 게이트웨이, SageMaker API·Runtime은 인터페이스 엔드포인트.**';
    for (final e in docsMap.entries) {
      expect(e.value.contains(stale), isFalse, reason: e.key);
    }
    // 새 공식 사실 — 지우기만 하는 가드는 출처 삭제를 막지 못하므로 쌍으로 본다.
    expect(docsMap['mla-t4-3.md']!.contains('게이트웨이와 인터페이스 **두 가지**'), isTrue);
    final q = byId('mla-t4-3-q22');
    expect(q['correct'], 0, reason: '정답 인덱스 불변');
    expect(blob(q).contains('게이트웨이와 인터페이스 두 가지'), isTrue);
    expect(blob(q).contains('문서가 S3에 안내하는 것은 게이트웨이 엔드포인트입니다. 라우트 테이블 연결이 핵심입니다.'),
        isFalse,
        reason: '회피형 반박 — 보기가 왜 틀렸는지 말하지 않았다');
    expect(sourceUrls(q),
        contains(
            'https://docs.aws.amazon.com/AmazonS3/latest/userguide/privatelink-interface-endpoints.html'));
    // 지문이 갈림길(추가 요금)을 말해야 정답이 하나가 된다.
    expect((q['stem'] as String).contains('추가 요금 없이'), isTrue);
  });

  // ═══════════════════ §2-B 출처 교체 8문항 ═══════════════════

  test('§2-B: 그 사실을 담지 않던 출처가 정본으로 바뀌었다 (8문항)', () {
    // 사실은 전부 옳았고 **인용 페이지만** 틀렸다. 정답 인덱스·본문 불변.
    const table = <String, List<String>>{
      // id : [사라져야 하는 URL 조각, 들어와야 하는 URL]
      'mla-t1-3-q8': [
        'mlrel03-bp04.html',
        'https://aws.amazon.com/what-is/ai-bias/',
      ],
      'mla-t1-3-q24': [
        'mlrel03-bp04.html',
        'https://aws.amazon.com/what-is/ai-bias/',
      ],
      'mla-t2-2-q3': [
        'distributed-training-strategies.html',
        'https://docs.aws.amazon.com/sagemaker/latest/dg/data-parallel-config.html',
      ],
      'mla-t2-3-q11': [
        'mlperf04-bp02.html',
        'https://docs.aws.amazon.com/machine-learning/latest/dg/evaluating_models.html',
      ],
      'mla-t3-2-q5': [
        'target-tracking-scaling-policy-overview.html',
        'https://docs.aws.amazon.com/sagemaker/latest/dg/multi-model-endpoints-autoscaling.html',
      ],
      'mla-t3-3-q15': [
        'sagemaker/latest/dg/pipelines.html',
        'https://docs.aws.amazon.com/sagemaker/latest/dg/build-and-manage-steps.html',
      ],
      'mla-t3-3-q16': [
        'pipelines-overview.html',
        'https://docs.aws.amazon.com/sagemaker/latest/dg/build-and-manage-steps.html',
      ],
      'mla-t3-3-q24': [
        'mlops04-bp01.html',
        'https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/mlperf06-bp05.html',
      ],
    };
    final correct = <String, int>{};
    for (final e in table.entries) {
      final q = byId(e.key);
      final urls = sourceUrls(q);
      expect(urls.where((u) => u.contains(e.value[0])), isEmpty,
          reason: '${e.key}: 그 페이지에 이 문항이 단정하는 사실이 없다');
      expect(urls, contains(e.value[1]), reason: '${e.key}: 정본이 들어왔는지');
      correct[e.key] = q['correct'] as int;
    }
    // 보고가 적지 않은 값을 추측하지 않고 실측해 못박는다.
    expect(correct, {
      'mla-t1-3-q8': 1,
      'mla-t1-3-q24': 2,
      'mla-t2-2-q3': 1,
      'mla-t2-3-q11': 1,
      'mla-t3-2-q5': 0,
      'mla-t3-3-q15': 0,
      'mla-t3-3-q16': 0,
      'mla-t3-3-q24': 0,
    });
  });

  test('§2-B 전수: 죽은 귀속이 MLA 문항에서 0건이다 (+md 대조군)', () {
    // 두 URL 은 교체 뒤 **문항에 한 건도 남지 않는다**(나머지 옛 URL 은 다른 문항이
    // 정당하게 인용하므로 전수 0 으로 셀 수 없다 — 위 표가 문항별로 본다).
    for (final slug in ['mlrel03-bp04.html', 'sagemaker/latest/dg/pipelines.html']) {
      final hits = <String>[];
      for (final q in allQuestions()) {
        if (sourceUrls(q).any((u) => u.contains(slug))) hits.add(q['id'] as String);
      }
      expect(hits, isEmpty, reason: '$slug 를 아직 인용하는 문항: $hits');
    }
    // ⚠️ md 는 `mlrel03-bp04` 를 **정당하게** 인용한다(그 BP 자체를 가르치는 자리다).
    // 이 대조군이 없으면 "전역에서 지워라"로 번진다.
    expect(docs()['mla-t1-3.md']!.contains('mlrel03-bp04.html'), isTrue);
  });

  test('§2-B: 새 정본 URL 6개가 같은 Task md 프런트매터에 등재됐다', () {
    // 문항 가드는 `.md` 를 보지 않는다 — 학습자가 학습문서에서 같은 출처에 닿아야 한다.
    const need = <String, List<String>>{
      'mla-t1-3.md': ['https://aws.amazon.com/what-is/ai-bias/'],
      'mla-t2-3.md': [
        'https://docs.aws.amazon.com/machine-learning/latest/dg/evaluating_models.html'
      ],
      'mla-t3-2.md': [
        'https://docs.aws.amazon.com/sagemaker/latest/dg/multi-model-endpoints-autoscaling.html'
      ],
      'mla-t3-3.md': [
        'https://docs.aws.amazon.com/sagemaker/latest/dg/build-and-manage-steps.html',
        'https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/mlperf06-bp05.html',
      ],
      'mla-t4-3.md': [
        'https://docs.aws.amazon.com/AmazonS3/latest/userguide/privatelink-interface-endpoints.html'
      ],
    };
    final docsMap = docs();
    for (final e in need.entries) {
      final lines = docsMap[e.key]!.split('\n').map((l) => l.trimRight()).toList();
      final i = lines.indexOf('sources:');
      expect(i, greaterThan(0), reason: '${e.key}: 프런트매터 sources 가 없다');
      var k = i + 1;
      final list = <String>[];
      while (k < lines.length &&
          (lines[k].startsWith('  - ') || lines[k].startsWith('    '))) {
        list.add(lines[k]);
        k++;
      }
      // ⚠️⚠️ 목록 **중간**에 최상위 키가 끼면 파서가 뒤쪽 출처를 **조용히 버린다**
      // (2026-11-11 SCS 에서 실제로 라이브 결함이 났다). 목록 뒤는 lastVerified 다.
      expect(lines[k].startsWith('lastVerified:'), isTrue,
          reason: '${e.key}: sources 목록 뒤에 온 줄이 ${lines[k]} 다');
      for (final url in e.value) {
        expect(list.any((l) => l.contains(url)), isTrue,
            reason: '${e.key}: $url 이 파서가 읽는 sources 목록 안에 없다');
      }
    }
  });

  // ═══════════════════ §2-C 귀속 ═══════════════════

  test('§2-C 전수: Access Analyzer 분석 기간은 공식 권고대로 적는다', () {
    // 공식에 `30 days` 0건 · `representative` 0건. 레포가 적던 「대표 기간 30~90일」은
    // 공식 권고가 아니다 — 권고는 "the shortest time period possible" 이다.
    final stale = RegExp(r'대표 기간 30|30일에서 90일');
    final offenders = <String>[];
    for (final q in allQuestions()) {
      if (stale.hasMatch(blob(q))) offenders.add(q['id'] as String);
    }
    for (final e in docs().entries) {
      if (stale.hasMatch(e.value)) offenders.add(e.key);
    }
    expect(offenders, isEmpty, reason: '옛 권고 서술: $offenders');
    expect(blob(byId('mla-t4-3-q8')).contains('가능한 한 짧은 기간'), isTrue);
    expect(docs()['mla-t4-3.md']!.contains('가능한 한 짧은 대표 기간'), isTrue);
    expect(byId('mla-t4-3-q8')['correct'], 0, reason: '정답 인덱스 불변');
  });

  test('§2-C mla-t4-2-q33: 귀속을 문서에서 블로그로 바로잡았다', () {
    // `inference-cost-optimization.html` 에 `right-siz` 0건 · `before` 0건.
    // 사실은 블로그에만 있으므로 **수치를 지우지 않고 귀속만** 정직하게 바꿨다
    // (레포 선례: `mla-t4-1-q3` 이 지문에서 블로그 귀속을 밝힌다).
    final q = byId('mla-t4-2-q33');
    expect(q['correct'], 0, reason: '정답 인덱스 불변');
    final b = blob(q);
    expect(b.contains('문서가 제시하는 순서'), isFalse);
    expect(b.contains('블로그가 제시하는 순서'), isTrue);
    expect(b.contains('SageMaker 추론 비용 최적화 문서는 적지 않습니다'), isTrue,
        reason: '어느 층에 있는 사실인지 학습자가 알아야 한다');
    expect((q['stem'] as String).contains('AWS 기계 학습 블로그'), isTrue);
  });

  test('§2-E 전수: Logs Insights 동시 쿼리는 언어별로 적는다', () {
    // 공식은 QL 100 + "15 concurrent queries for either OpenSearch Service PPL
    // or OpenSearch Service SQL" 이다. 세 언어를 나란히 들면서 한도를 하나만 적으면
    // PPL·SQL 에도 100 이 적용되는 것처럼 읽힌다.
    //
    // ⚠️⚠️ **금지형이 아니라 요구형**으로 둔다. 금지형(「계정당 동시 쿼리 100개」 0건)
    // 으로 썼더니 기존 가드 `mla_questions_test`「2차 검수 출처 교체 2건이 반영됐다」가
    // 그 **리터럴을 반대로 요구**해 레드가 났다(그 가드의 의도는 「100 이라는 수치가
    // 맞고 근거가 달렸다」이고 지금도 참이다). 어형에도 둔감해진다.
    //
    // ⚠️ 트리거를 `동시 쿼리` 만으로 두면 `mla-t1-1-q18` 의 **Athena 워크그룹 동시
    // 쿼리 수**가 걸린다 — Logs Insights 문맥으로 좁힌다.
    final offenders = <String>[];
    var hits = 0;
    for (final q in allQuestions()) {
      final b = blob(q);
      if (!b.contains('동시 쿼리') || !b.contains('Logs Insights')) continue;
      hits++;
      if (!b.contains('QL') || !b.contains('각 15')) offenders.add(q['id'] as String);
    }
    for (final e in docs().entries) {
      for (final line in e.value.split('\n')) {
        if (!line.contains('동시 쿼리') || !line.contains('Logs Insights')) continue;
        hits++;
        if (!line.contains('QL') || !line.contains('각 15')) offenders.add(e.key);
      }
    }
    expect(offenders, isEmpty, reason: '언어 한정 없는 동시 쿼리 한도: $offenders');
    expect(hits, 2, reason: '대조군 — 탐지 집합은 mla-t4-2-q11 과 mla-t4-2.md 두 자리다');
    // Athena 문맥은 대상이 아니다(규칙이 과잉으로 번지지 않았음을 고정한다).
    expect(blob(byId('mla-t1-1-q18')).contains('Logs Insights'), isFalse);
    expect(byId('mla-t4-2-q11')['correct'], 0, reason: '정답 인덱스 불변');
  });

  // ═══════════════════ §2-D 닫힌 서비스 상태 표기 ═══════════════════

  test('§2-D: Model Monitor 기능을 가르치는 문항 17개에 정본 문구가 있다', () {
    // ⚠️⚠️ 2026-10-27 의 선정은 「문항 JSON 어디에든 `Model Monitor` **문자열**이
    // 나오는가」였다. 그래서 같은 기능을 문자열 없이 가르치는 네 문항
    // (`q12`·`q13` 위반 스키마 · `q17` 품질 스케줄 오프셋 · `q18` 정답 라벨 병합)이
    // 모집단 **밖**에 있었다. 기준을 **「Model Monitor 기능을 가르치는가」**로 바꾼다:
    // 가르치는 층이 이름을 들거나 **출처가 `model-monitor-*` 계열**이면 대상이다.
    const note = '⚠️ Model Monitor는 현재 신규 고객을 받지 않습니다(기존 고객은 사용 가능).';
    // 명시 제외 5문항 — 왜 제외인지를 가드에 적어 기준이 암묵적으로 남지 않게 한다.
    const excluded = <String, String>{
      // 2026-10-27 판정 — 데이터 캡처는 Model Monitor 없이도 쓰는 독립 기능이다.
      'mla-t4-1-q10': '데이터 캡처(독립 기능)',
      'mla-t4-1-q11': '데이터 캡처(독립 기능)',
      // 2026-11-06 §P3-M2 판정 ② — 출처가 `clarify-model-monitor-*` 계열이라
      // **Clarify 상태**가 더 정확한 층이고 이미 붙어 있다. 둘을 다 달면 같은
      // 사실을 두 번 말한다(`mla_p3_review_fix_test` 가 이 제외를 고정한다).
      'mla-t4-1-q19': 'Clarify 상태가 이미 있다',
      'mla-t4-1-q20': 'Clarify 상태가 이미 있다',
      'mla-t4-1-q21': 'Clarify 상태가 이미 있다',
    };
    final target = <String>[];
    final offenders = <String>[];
    for (final q in allQuestions()) {
      final id = q['id'] as String;
      final isMm = teaching(q).contains('Model Monitor') ||
          sourceUrls(q).any((u) => u.contains('model-monitor-'));
      if (!isMm || excluded.containsKey(id)) continue;
      target.add(id);
      if (!'${q['explanation']}'.contains(note)) offenders.add(id);
    }
    expect(offenders, isEmpty,
        reason: '학습자는 오답노트·모의고사 화면에서 md 의 상태 표를 보지 못한다: $offenders');
    expect(target.length, 17,
        reason: '대조군 — 집합이 13으로 돌아가면 문자열 우연 기준으로 되돌아간 것이다: $target');
    for (final id in excluded.keys) {
      expect(blob(byId(id)).contains(note), isFalse, reason: '$id: ${excluded[id]}');
    }
  });

  test('§2-D: Debugger 2문항 · Role Manager 1문항에 정본 문구가 있다', () {
    const dbg = '⚠️ SageMaker Debugger는 신규 고객에게 닫혀 있습니다(기존 고객은 계속 사용).';
    const rm = '⚠️ Role Manager는 신규 고객에게 닫혀 있습니다(기존 고객은 계속 사용).';
    // 인용 페이지 `debugger-built-in-rules.html` **자신의 첫 Note** 가 상태를 적는데
    // 문항만 빼먹고 있었다(`q15` 는 2026-11-06 중복 해소 때 새로 쓴 본문이다).
    for (final id in ['mla-t2-3-q14', 'mla-t2-3-q15']) {
      expect('${byId(id)['explanation']}'.contains(dbg), isTrue, reason: id);
    }
    // Role Manager 는 종료가 아니라 Maintenance 라 **기존 고객은 지금도 쓴다** —
    // 과거형("제공하던"·"제공했습니다")은 「사라졌다」로 읽혀 거짓이 된다.
    final q = byId('mla-t4-3-q10');
    expect('${q['explanation']}'.contains(rm), isTrue);
    expect(q['correct'], 0, reason: '정답 인덱스 불변');
    final past = RegExp(r'제공하던|제공했습니다');
    final offenders = <String>[];
    for (final x in allQuestions()) {
      if (past.hasMatch(blob(x))) offenders.add(x['id'] as String);
    }
    expect(offenders, isEmpty, reason: '유지 관리 상태를 과거형으로 적은 자리: $offenders');
  });

  test('§3-9 전수: 「신규 고객을 받지 않습니다」는 괄호 보충과 함께 쓴다', () {
    // `mla-t1-2-q19`(A2I) 만 「(기존 고객은 사용 가능)」이 빠져 다른 18자리와 달랐다.
    final bad = <String>[];
    var all = 0;
    for (final q in allQuestions()) {
      final b = blob(q);
      if (!b.contains('신규 고객을 받지 않습니다')) continue;
      all++;
      if (RegExp(r'신규 고객을 받지 않습니다(?!\()').hasMatch(b)) bad.add(q['id'] as String);
    }
    expect(bad, isEmpty, reason: '괄호 보충이 빠진 자리: $bad');
    expect(all, 19, reason: '대조군 — 탐지 집합');
  });

  // ═══════════════════ §3 품질 ═══════════════════

  test('§3-2 전수: 저작 과정 메모 네 계열이 0건이다 (+정당한 부정문 대조군)', () {
    // 기존 M2 가드(`mla_questions_test`)의 패턴 밖에 있던 네 자리다. 그 가드는
    // 본문만 보고 **`sources[].title` 은 보지 않아서** `mla-t2-2-q17` 이 새어 나갔다.
    final memo = RegExp(r'에서 확인됨|확인된 연동|이 수준까지만|서술하지 않으므로');
    final offenders = <String>[];
    for (final q in allQuestions()) {
      if (memo.hasMatch(blob(q))) offenders.add(q['id'] as String);
    }
    expect(offenders, isEmpty, reason: '저작자의 검증 상태 서술: $offenders');
    // ⚠️ 보기의 주장을 부정하는 문장은 **정당**하다 — 탐지기가 그것을 걷지 않는다.
    expect(blob(byId('mla-t4-3-q22')).contains('단정할 수 없'), isTrue,
        reason: '대조군: 「ECR 엔드포인트가 필수라고 단정할 수 없고」는 남아야 한다');
    // 교체된 자리의 공식 사실이 들어왔는지 쌍으로 본다.
    expect(blob(byId('mla-t4-1-q23')).contains('4xx 응답으로 돌아오지 않는 실패'), isTrue,
        reason: '공식 `InvocationModelErrors` 정의와 대비되는 사실 서술');
  });

  test('§3-3 전수: 오답 근거에서 상태를 그 보기가 틀린 이유로 들지 않는다', () {
    // 지문이 신규 계정 상황이 아닌데 상태를 이유로 들면 **거짓**이다 — 기존 고객은
    // 그 기능을 지금도 쓸 수 있으므로 이유로 성립하지 않는다.
    const stale = <String>[
      '게다가 이 단계는 신규 고객에게 닫힌 Model Monitor 컨테이너를 씁니다.',
      'CloudTrail Lake는 2026-05-31부터 신규 고객에게 닫혔고 이 경로의 전제 조건도 아닙니다.',
      'Debugger는 신규 고객에게 닫혀 있어 대체 경로가 될 수 없습니다.',
    ];
    final offenders = <String>[];
    for (final q in allQuestions()) {
      final b = blob(q);
      for (final s in stale) {
        if (b.contains(s)) offenders.add('${q['id']} :: $s');
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
    // 바뀐 자리에 **그 보기를 틀리게 만드는 진짜 이유**가 들어왔는지.
    expect(blob(byId('mla-t4-2-q18')).contains('추적이 기록한 API 호출 이벤트'), isTrue);
    expect(blob(byId('mla-t4-2-q34')).contains('Profiler 공지가 시스템 자원 모니터링의 대체로 안내하는 것은 CloudWatch'),
        isTrue);
    // ⚠️ 대조군 — 지문이 「새로 만든 계정」인 문항에서는 상태가 **실제 이유**다.
    // 이 셋이 사라지면 규칙이 과잉으로 번진 것이다.
    final newAccount = <String>[];
    for (final q in allQuestions()) {
      final stem = q['stem'] as String;
      if (stem.contains('새로 만든 계정') || stem.contains('새 계정')) {
        newAccount.add(q['id'] as String);
      }
    }
    expect(newAccount, ['mla-t2-1-q5', 'mla-t3-1-q16', 'mla-t4-3-q11']);
  });

  test('§3-4: Clarify 지표의 정의만 묻는 6문항은 명시 제외다', () {
    // 1단계 보고가 「기준이 문자열 우연에 달려 있다」고 지적한 자리다. 2026-11-06
    // 판정(ⓑ)을 **명문화**한다 — 기준은 「가르치는 층이 Clarify 라는 **서비스**를
    // 드는가」이고, 아래 여섯은 **지표의 정의·공식**만 묻는다.
    //
    // ⚠️ 그 판정이 옳은 근거: Clarify 가용성 변경 페이지와 `mla-t1-3.md:96` 이
    // 「지표가 라벨 개수와 혼동 행렬로 계산되는 **공개된 표준 공식**이고
    // pandas·scikit-learn 으로 재현하면 Clarify 출력과 일치한다」고 적는다.
    // 즉 **기능은 닫혔지만 공식은 닫히지 않았다** — 정의 문항에 서비스 상태를 달면
    // 학습 대상이 사라진 것처럼 읽힌다. 반대로 §2-D 의 Model Monitor 네 문항은
    // **그 기능 안에서만 존재하는 스키마·스케줄 의미**를 가르치므로 상태가 필요하다.
    //
    // ⚠️ `mla_aif_p2_review_fix_test` 가 `mla-t1-3-q1` 을 같은 뜻으로 못박고 있다 —
    // 둘을 바꾸려면 **그 가드를 먼저 뒤집어야** 한다.
    const six = <String>[
      'mla-t1-3-q1',
      'mla-t1-3-q2',
      'mla-t1-3-q3',
      'mla-t1-3-q4',
      'mla-t1-3-q8',
      'mla-t2-3-q20',
    ];
    for (final id in six) {
      expect(teaching(byId(id)).contains('Clarify'), isFalse,
          reason: '$id: 가르치는 층이 Clarify 를 들면 기존 전수 가드가 상태를 요구한다');
    }
    // 대조군 — 가르치는 층에서 Clarify 를 드는 문항은 실재하고 상태를 적는다.
    final taught = <String>[];
    for (final q in allQuestions()) {
      if (teaching(q).contains('Clarify')) taught.add(q['id'] as String);
    }
    expect(taught.length, greaterThanOrEqualTo(8));
    for (final id in taught) {
      expect(RegExp(r'신규 고객|유지 관리').hasMatch(blob(byId(id))), isTrue, reason: id);
    }
  });

  test('§3-7: 범위 외 서비스가 정답인 2문항에 범위 메모가 붙었다', () {
    // 사실은 둘 다 옳다 — 결함은 **학습 시간 배분**이라 CLF 선례대로 문항을 지우지
    // 않고 `explanation` 에 한 줄을 단다(md 에만 적으면 오답노트·모의고사에서 안 보인다).
    // ⚠️ 공식 「범위 외」 페이지가 스스로 「전체 목록이 아니다」라고 적으므로 **이름이
    // 올라 있는 것만** 센다(`Amazon MSK`·`CodeCommit` 은 두 목록 어디에도 없다).
    const memo = '「범위 외 AWS 서비스」 목록(보안, ID 및 규정 준수)에 있습니다';
    final hits = <String>[];
    for (final q in allQuestions()) {
      if ('${q['explanation']}'.contains(memo)) hits.add(q['id'] as String);
    }
    expect(hits, ['mla-t3-2-q20', 'mla-t4-3-q27']);
    expect(byId('mla-t3-2-q20')['correct'], 0, reason: '정답 인덱스 불변');
    expect(byId('mla-t4-3-q27')['correct'], 0, reason: '정답 인덱스 불변');
    expect(blob(byId('mla-t4-3-q27')).contains('AWS Artifact는 공식 MLA-C01'), isTrue);
    expect(blob(byId('mla-t3-2-q20')).contains('Amazon Inspector는 공식 MLA-C01'), isTrue);
  });

  test('§3-8 mla-t4-3-q25: 출처가 담지 않는 둘째 문장이 사라졌다', () {
    // 2026-11-17 백서 재소싱으로 출처가 `security_iam_id-based-policy-examples.html`
    // 로 바뀐 뒤 그 문장의 근거가 없어졌다(`CloudTrail` 0건). 첫 문장은 그 페이지에
    // 있다 — "use VPC flow logs to monitor all traffic to and from the training
    // cluster".
    final q = byId('mla-t4-3-q25');
    expect(q['correct'], 0, reason: '정답 인덱스 불변');
    expect(blob(q).contains('심층 방어에서 관측 층'), isFalse);
    expect('${q['explanation']}'.contains('VPC Flow Logs'), isTrue, reason: '첫 문장은 남는다');
  });
}

/// MLA 문항 파일 12개(이름 순).
List<File> questionFiles() => Directory('assets/content/mla')
    .listSync()
    .whereType<File>()
    .where((f) => f.path.endsWith('.questions.json'))
    .toList()
  ..sort((a, b) => a.path.compareTo(b.path));
