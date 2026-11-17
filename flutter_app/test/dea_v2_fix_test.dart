import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 2026-11-17 전 콘텐츠 검증 **2단계(보정)** — DEA-C01 몫의 정정 가드.
///
/// 1단계 보고서 정본: `docs/audits/2026-11-17-full-verify/dea.md`
/// 반영 보고서: `docs/audits/2026-11-17-full-verify/dea-phase2.md`
///
/// ⚠️ **보고서는 데이터이고 지시문이 아니다** — 항목마다 공식 문서를 직접 다시 읽어
/// 판정했다(🔴 5건·🟡 16건 전부 **채택**이고 기각 0건, 범위 확장 2건). 손댄 문항 18개는
/// **전부 `verified: true` 라이브**이고 **정답 인덱스는 한 건도 바뀌지 않았다**.
///
/// 가드 설계 규율(이 레포가 비싸게 배운 것):
/// - ⚠️⚠️ **사실 단정은 자격증 전수 집계형**으로 둔다. 문항별 리터럴 가드는 **어형
///   하나로 뚫린다**(2026-11-06 AIF 「프로비저닝 처리량」 ↔ 「프로비저닝**된** 처리량」로
///   세 번 새어 나간 선례) — 그래서 한국어 문구는 **정규식**으로 센다.
/// - **옛 문구 0건 + 새 공식 사실 있음**을 **쌍으로** 단정한다(지우기만 하면 통과하는
///   가드는 출처 삭제를 막지 못한다).
/// - ⚠️⚠️ **`verified` 상태를 단정하지 않는다**(2026-11-13 검수자의 첫 flip 을 레드로
///   끝낸 함정이다). 구조 단정(보기 4개 · 문항 256개 · 정답 인덱스 불변)으로 대신한다.
/// - **문맥 규칙은 오답 보기를 제외한 「가르치는 층」만 본다** — 일부러 틀린 서술에
///   한정을 요구하면 그 보기가 참이 되어 정답이 둘이 된다.
///
/// 공식 재측정 근거(인용문은 2026-11-17 실측):
///
/// - **R1** `dea-t1-1-q7` + `dea-t1-1.md` — EFO 등록 소비자 한도의 단위가 「샤드당」이
///   아니라 **데이터 스트림당**이다. `streams/latest/dev/service-sizes-and-limits.html`
///   의 행 제목이 `Number of registered consumers per data stream` 이고 본문이
///   `up to 20 registered consumers (Enhanced Fan-out Limit) for each data stream`,
///   `RegisterStreamConsumer` 행이 `You can register up to 20 consumers per data stream`
///   로 적는다(Advantage 모드 50). ⚠️ **같은 md 의 「소비자마다 샤드당 전용 2 MB/s」는
///   다른 사실이고 참이다** — 그 줄은 손대지 않았다.
/// - **R2** `dea-t1-4-q13` `W3` — `rolling with additional batch` 는 **Elastic Beanstalk
///   의 배포 정책**이다. CodeDeploy 의 `deployment-configurations.html` 에 그 문자열이
///   **0건**이고 EC2/온프레미스 사전 정의 구성은 `CodeDeployDefault.AllAtOnce` ·
///   `HalfAtATime` · `OneAtATime` **셋뿐**이다(표의 행). Beanstalk 쪽
///   `using-features.rolling-version-deploy.html` 이 `All at once, Rolling, Rolling with
///   additional batch, Immutable, and Traffic splitting` 으로 자기 정책으로 적는다.
/// - **R3** `dea-t1-2.md` · `dea-t3-3.md` — 버전 미지정 Glue 잡의 기본은 **6.0** 이다.
///   `glue/latest/dg/release-notes.html` — `AWS Glue 6.0 is the default version for jobs
///   created without specifying an AWS Glue version.`
/// - **R4** `dea-t4-5.md` 2자리 — Access Points 한도는 **계정·리전당** 10,000 이다.
///   `access-points-restrictions-limitations-naming-rules.html` — `You can create a
///   maximum of 10,000 access points per AWS account per AWS Region.`
/// - **R5** `dea-t3-1.md` 2자리 — boto3 기본 재시도 모드는 **standard** 다.
///   `boto3/latest/guide/retries.html` — `Standard mode is the default mode used by any
///   Boto3 client you create.` · `the default retry mode value is standard, and the
///   default max_attempts value is 3 ..., or 4 for Amazon DynamoDB and Amazon DynamoDB
///   Streams.`
/// - **Y1** Multi-AZ 5자리 — `AmazonRDS/.../Concepts.MultiAZ.html` 가 **배포 유형 둘**을
///   가른다: `A Multi-AZ DB instance deployment has one standby DB instance that provides
///   failover support, but doesn't serve read traffic. ... A Multi-AZ DB cluster deployment
///   has standby DB instances that provide failover support and can also serve read
///   traffic.` ⭐ SAA·SOA 는 이미 같은 한정으로 정정돼 있었다(자격증 간 불일치).
/// - **Y2** Bedrock PT — 사용자 지정 모델의 추론 경로는 **둘**이고 **약정 없는 PT** 가
///   있다. `model-customization-use.html` — `Purchase Provisioned Throughput ... Deploy
///   custom model for on-demand inference ... you don't need to set up provisioned compute
///   resources.` · `API_CreateProvisionedModelThroughput` — `To request a no-commit
///   Provisioned Throughput, omit this field. Custom models support all levels of
///   commitment.` (문항이 인용한 ML 블로그는 지금도 「PT 필수」로 적는 **공식 내부
///   어긋남**이고, 더 구체적인 사용자 안내서·API 참조를 정본으로 본다 — AIF·AIP 와 같은 판정.)
/// - **Y3** KMS 온디맨드 회전 — `kms/.../resource-limits.html` 의 쿼터 표가
///   `On-demand rotation | 25 | Customer managed keys | No`(조정 불가)이고 본문이
///   `a maximum of 25 times per KMS key. ... This quota is not adjustable.` 다.
///   `rotating-keys-on-demand.html` 도 25 로 적는다. `aws.amazon.com/kms/faqs/` 의 10회와
///   어긋나므로 **전용 쿼터 페이지를 정본**으로 삼았다.
/// - **Y4** 구체화된 뷰 — `glue/latest/dg/materialized-views.html` 가
///   `The precomputed data is also accessible from other services including Amazon Athena
///   and Amazon Redshift.` 로 적어 「Redshift 의 객체라 성립하지 않는다」는 근거가 무너진다.
///   ⭐ 정답(SPICE)의 유일성은 그대로다 — 구체화된 뷰를 써도 대시보드를 열 때마다 원본
///   쿼리가 실행된다.
/// - **Y5** 로그 클래스 — `CloudWatch_Logs_Log_Classes.html` 기능 표가
///   `Export to Amazon S3 | Yes | Yes` · `Subscription filters | Yes | No` 이고(⚠️ **표의
///   행**이라 산문 검색으로는 안 잡힌다), `The Infrequent Access log class has been renamed
///   to Essentials. ... Starting December 2026, API responses ... will return ESSENTIALS`
///   다. 그래서 「공식 자료 간 서술이 엇갈려」(M2 메모)를 걷고 **Essentials 병기**를 넣었다.
/// - **Y6** `dea-t1-4-q10` — 정답의 핵심(`cdk bootstrap`·`CDKToolkit`)을 기존 출처 둘이
///   담지 않는다(`cdk/v2/guide/home.html`·`constructs.html` 에서 `bootstrap` 0건 ·
///   `CDKToolkit` 0건, 대조군 `CloudFormation` 은 잡힌다). 새 출처
///   `cdk/v2/guide/bootstrapping.html` 는 `200 r=0` · `bootstrap` 23건 · `CDKToolkit` 1건.
/// - **Y7** 「Redshift Serverless 는 128의 배수」 — 공식 두 페이지에 **없다**(근거가
///   `repost.aws` 뿐이다). 레포 규율대로 **공식 권고로 읽히지 않게 귀속**했다(걷지 않았다).
/// - **Y8** RDS Performance Insights 종료일 — ⚠️ **1단계가 인용한 요금 페이지가 오늘은
///   `r=1` 로 `aws.amazon.com/cloudwatch/pricing/` 로 가고 거기에 `July 31, 2026` 이
///   0건이다**. 사용자 안내서 `USER_PerfInsights.html` 은 제목이 Database Insights 로
///   바뀌었고 `2026`·`no longer` 가 0건(대조군 `Database Insights` 10건)이다. **날짜를
///   적는 공식 페이지가 없으므로 날짜를 단정하지 않는다**(CLF 「레거시 12개월」·SAA
///   「us-east-1 DX 단가」와 같은 처리).
/// - **Y9** Glue Data Catalog compaction — `compaction-management.html` — `the compaction
///   process starts when a table or any of its partitions have more than 100 files. Each
///   file must be smaller than 75% of the target file size. The target file size is defined
///   by the write.target-file-size-bytes table property, which defaults to 512 MB`.
/// - **Y10** NAT 게이트웨이 — `nat-gateways-regional.html` — `with a regional NAT Gateway,
///   you don't need to create a public subnet to host it.` · `Enhanced security - No public
///   subnets required.` 그래서 「퍼블릭 서브넷의 NAT 를 **경유해야/있어야**」는 영역형에만
///   맞는 **배타 서술**이다(영역형 구성으로서는 지금도 정답이라 보기를 바꾸지 않았다).
/// - **Y11** MWAA — `mwaa/latest/userguide/environment-class.html` — `For environments
///   larger than mw1.micro, accepts values from 2 to 5. Defaults to 2 for all environment
///   sizes except mw1.micro, which defaults to 1.`
/// - **Y12** Kinesis ESM 실패 대상 — `kinesis-on-failure-destination.html` — `You can
///   configure any Amazon SNS topic, Amazon SQS queue, Amazon S3 bucket, or Kafka as a
///   destination.` · `For Amazon S3 destinations, Lambda also sends the entire invocation
///   record along with the metadata.` ⭐ 정답 보기에서 괄호를 걷어 **길이 단서도 줄었다**
///   (54자 → 45자).
/// - **Y13** 「사람 검수 전」 25자리 — DEA 는 256/256 이 공개인데 학습자가 읽는 md 에
///   저작 시점의 상태 문구가 남아 있었다. ⚠️ **어형이 둘이었다**(「사이트에는 노출되지
///   않습니다」 5편 · 「사이트 비노출」 3편) — 치환 횟수 단정이 갈라 줬다.
/// - **Y14** `dea-t4-1-q4` 의 **유일한 출처가 `repost.aws`** 였다 → 공식
///   `lambda/latest/dg/configuration-vpc-internet.html`(`200 r=0` · `private subnet` 20건 ·
///   `NAT gateway` 20건)을 **첫 출처로** 넣었다.
/// - **Y15** `dea-t3-4.md` 2자리 — 공식 조건은 「작다」가 아니라 **colocate 불가**다.
///   `c_best-practices-best-dist-key.html` — `If a dimension table cannot be collocated
///   with the fact table or other important joining tables, you can improve query
///   performance significantly by distributing the entire table to all of the nodes.` ·
///   `c_choosing_dist_sort.html` — `Because the cost of redistributing small tables during
///   a query is low, there isn't a significant benefit to define small dimension tables as
///   DISTSTYLE ALL.` ⭐ 같은 자격증 `dea-t2-4.md` 가 이미 옳게 적어 **문서끼리 어긋나 있었다**.
/// - **Y16** 백서 출처 상태 메모 — `whitepapers/latest/big-data-analytics-options/
///   amazon-athena.html` 은 `200 r=1` 로 Athena 사용자 안내서로 간다(사람 대상 서빙만 꺼진
///   백서 계열 — 레포 정책은 **인용 유지 + 상태 명시**). ⚠️ `dea-t1-2-q7` 의 첫 출처
///   `federated-queries.html` 은 `charge`·`cost` 가 0건이고 요금을 **링크로만** 가리켜
///   커넥터 Lambda 요금 사실을 담지 않는다 → **백서 줄을 지우지 않고** 메모를 달았다.
void main() {
  const tasks = <String>[
    't1-1', 't1-2', 't1-3', 't1-4',
    't2-1', 't2-2', 't2-3', 't2-4',
    't3-1', 't3-2', 't3-3', 't3-4',
    't4-1', 't4-2', 't4-3', 't4-4', 't4-5',
  ];

  String mdOf(String t) =>
      File('assets/content/dea/dea-$t.md').readAsStringSync();
  String rawOf(String t) =>
      File('assets/content/dea/dea-$t.questions.json').readAsStringSync();
  List<Map<String, dynamic>> questionsOf(String t) =>
      ((jsonDecode(rawOf(t)) as Map)['questions'] as List)
          .cast<Map<String, dynamic>>();

  /// 문항의 **가르치는 층**(오답 보기 제외): 지문 · 스킬 · 정답 보기 · 해설 ·
  /// 오답 근거 · 출처 제목. 일부러 틀린 오답 보기 문구는 사실 규칙 대상이 아니다.
  String factText(Map<String, dynamic> q) {
    final parts = <String>[
      (q['stem'] ?? '') as String,
      (q['skill'] ?? '') as String,
      (q['explanation'] ?? '') as String,
      ((q['options'] as List)[q['correct'] as int] ?? '') as String,
    ];
    final we = q['wrongExplanations'];
    if (we is Map) parts.addAll(we.values.map((v) => '$v'));
    final srcs = q['sources'];
    if (srcs is List) {
      for (final s in srcs) {
        if (s is Map) parts.add('${s['title']}');
      }
    }
    return parts.join('\n');
  }

  /// md 는 줄 단위로, 문항은 가르치는 층 단위로 센다.
  List<String> units() {
    final out = <String>[];
    for (final t in tasks) {
      out.addAll(mdOf(t).split('\n'));
      for (final q in questionsOf(t)) {
        out.add(factText(q));
      }
    }
    return out;
  }

  /// 전수(md 본문 + 문항 JSON 원문)를 한 덩어리로 — 리터럴 금지·필수 집계용.
  String allText() {
    final sb = StringBuffer();
    for (final t in tasks) {
      sb.writeln(mdOf(t));
      sb.writeln(rawOf(t));
    }
    return sb.toString();
  }

  int count(String text, RegExp re) => re.allMatches(text).length;

  // ── 대조군 1 — 콘텐츠가 읽혔고 구조가 그대로다 ───────────────────────────
  // 0건 통과가 「파일을 못 읽어서」일 수 있다. 그래서 먼저 읽힘을 증명한다.
  test('대조군: DEA 콘텐츠 17편·문항 256개가 읽히고 구조가 그대로다', () {
    var qTotal = 0;
    for (final t in tasks) {
      final md = mdOf(t);
      expect(md.length, greaterThan(5000), reason: 'dea-$t.md 가 너무 짧다');
      final qs = questionsOf(t);
      expect(qs, isNotEmpty, reason: 'dea-$t 문항이 비었다');
      for (final q in qs) {
        expect((q['options'] as List).length, 4, reason: '${q['id']} 보기 4개');
        expect(q['correct'], inInclusiveRange(0, 3), reason: '${q['id']}');
      }
      qTotal += qs.length;
    }
    expect(qTotal, 256, reason: 'DEA 문항 수');
    // ⚠️ `verified` 상태는 단정하지 않는다(사람의 flip 을 깨뜨리지 않기 위해).
    expect(allText().length, greaterThan(300000), reason: '전수 덩어리가 읽혔다');
  });

  // ── 대조군 2 — 탐지기가 정정문 자신을 걸지 않는다 ────────────────────────
  // 이 레포에서 탐지기가 정정문을 거는 일이 반복됐다. 합성 입력으로 양 방향을 짚는다.
  test('대조군: 탐지기가 옛 문구는 잡고 정정문은 통과시킨다', () {
    final efo = RegExp(r'샤드당\s*(최대\s*)?20');
    expect(count('EFO 사용 시 샤드당 최대 20', efo), 1);
    expect(count('EFO 등록 소비자 데이터 스트림당 최대 20(Advantage 50)', efo), 0);

    final bucket = RegExp(r'버킷당\s*(최대\s*)?10,000');
    expect(count('버킷당 최대 10,000개이며', bucket), 1);
    expect(count('계정·리전당 최대 10,000개(증액 요청 가능)이며', bucket), 0);
    // 「버킷당 1,000개 수명 주기 규칙」은 다른 사실이다 — 걸리지 않아야 한다.
    expect(count('수명 주기 규칙 버킷당 1,000개', bucket), 0);

    final glue = RegExp(r'기본 Glue 버전은 5\.1|5\.1\*{0,2}로 생성');
    expect(count('기본 Glue 버전은 5.1 입니다', glue), 1);
    expect(count('기본 Glue 버전은 6.0 입니다', glue), 0);
    // ⚠️ `5\.1` 단독은 스킬 번호 `(4.5.1)` 에 걸린다 — 문구로 좁힌 것이 그 때문이다.
    expect(count('데이터 파이프라인 설계(4.5.1)', glue), 0);

    final pt = RegExp(r'커스텀 모델에 필수|약정이 필요');
    expect(count('Provisioned Throughput(1·6개월 약정이 필요하며)', pt), 1);
    expect(count('약정 없음/1개월/6개월 중 선택', pt), 0);
  });

  // ── R1 ───────────────────────────────────────────────────────────────────
  test('R1: EFO 등록 소비자 한도를 「샤드당」으로 적지 않는다 (데이터 스트림당)', () {
    final text = allText();
    expect(count(text, RegExp(r'샤드당\s*(최대\s*)?20')), 0,
        reason: 'EFO 등록 소비자 한도의 단위는 데이터 스트림당이다');
    // 쌍 단정 — 새 공식 사실이 실제로 들어갔는가.
    expect(text.contains('데이터 스트림당'), isTrue);
    expect(count(text, RegExp(r'데이터 스트림당\*{0,2}\s*(등록 소비자\s*)?최대 20')),
        greaterThanOrEqualTo(1));
    // ⚠️ 「소비자마다 샤드당 전용 2 MB/s」는 **다른 사실이고 참**이라 그대로 있어야 한다.
    expect(text.contains('샤드당 전용 2 MB/s'), isTrue,
        reason: 'EFO 의 샤드당 전용 처리량은 참인 서술이다 — 함께 지우면 안 된다');
  });

  // ── R2 ───────────────────────────────────────────────────────────────────
  test('R2: rolling with additional batch 를 CodeDeploy 구성으로 귀속하지 않는다', () {
    final text = allText();
    expect(count(text, RegExp(r'rolling with additional batch는 EC2')), 0);
    expect(text.contains('AWS Elastic Beanstalk의 배포 정책'), isTrue);
    // CodeDeploy 쪽 사전 정의 구성 셋을 적는다.
    expect(text.contains('AllAtOnce·HalfAtATime·OneAtATime'), isTrue);
  });

  // ── R3 ───────────────────────────────────────────────────────────────────
  test('R3: 버전 미지정 Glue 잡의 기본 버전을 5.1 로 적지 않는다 (6.0)', () {
    final text = allText();
    expect(count(text, RegExp(r'기본 Glue 버전은 5\.1|5\.1\*{0,2}로 생성')), 0);
    expect(text.contains('기본 Glue 버전은 6.0'), isTrue);
    expect(text.contains('**6.0**으로 생성'), isTrue);
  });

  // ── R4 ───────────────────────────────────────────────────────────────────
  test('R4: S3 Access Points 한도를 「버킷당 10,000」으로 적지 않는다 (계정·리전당)', () {
    final text = allText();
    expect(count(text, RegExp(r'버킷당\s*(최대\s*)?10,000')), 0);
    // ⚠️ `dea-t4-1.md` 는 「계정·리전당 최대 **10,000개**」로 굵게가 수치를 감싼다 —
    //    `\*{0,2}` 없이 세면 이미 옳던 그 자리를 놓친다(실측으로 2 vs 3 레드).
    expect(count(text, RegExp(r'계정·리전당\s*(최대\s*)?\*{0,2}10,000')),
        greaterThanOrEqualTo(3),
        reason: 'dea-t4-5.md 2자리 + 이미 옳던 dea-t4-1.md 1자리');
    // 수명 주기 규칙의 「버킷당 1,000개」는 다른 사실이라 남아 있어야 한다.
    expect(text.contains('버킷당 1,000개'), isTrue);
  });

  // ── R5 ───────────────────────────────────────────────────────────────────
  test('R5: boto3 기본 재시도 모드를 legacy 로 적지 않는다 (standard)', () {
    final text = allText();
    expect(count(text, RegExp(r'legacy를 기본|기본 모드는 legacy')), 0);
    expect(count(text, RegExp(r'boto3 기본 재시도 모드와')), 0,
        reason: '「자료마다 달라 단정하지 않는다」는 메모도 함께 걷었다');
    expect(text.contains('기본 모드는 `standard` 입니다'), isTrue);
    // 공식이 함께 적는 기본 시도 횟수.
    expect(text.contains('DynamoDB·DynamoDB Streams는 **4**'), isTrue);
    // legacy 자체를 지우는 것이 아니다 — 「예전 기본」으로 가르친다.
    expect(text.contains('retry_mode = legacy'), isTrue);
  });

  // ── Y1 (문맥 규칙) ───────────────────────────────────────────────────────
  test('Y1: Multi-AZ 와 읽기 트래픽이 같은 자리에 오면 배포 유형을 가른다', () {
    final offenders = <String>[];
    for (final u in units()) {
      if (!u.contains('Multi-AZ')) continue;
      if (!RegExp(r'읽기 트래픽|읽기를 분산|읽기를 처리').hasMatch(u)) continue;
      if (RegExp(r'DB 인스턴스 배포|DB 클러스터').hasMatch(u)) continue;
      offenders.add(u.trim().substring(0, u.trim().length.clamp(0, 90)));
    }
    expect(offenders, isEmpty,
        reason: 'Multi-AZ DB 인스턴스 배포(스탠바이 1개)와 DB 클러스터 배포를 가르지 '
            '않으면 거짓이 된다: $offenders');
    // 쌍 단정 — 한정이 실제로 들어갔는가.
    final text = allText();
    expect(count(text, RegExp(r'DB 클러스터 배포')), greaterThanOrEqualTo(3));
  });

  // ── Y2 ───────────────────────────────────────────────────────────────────
  test('Y2: Bedrock PT 를 「커스텀 모델에 필수」·「약정이 필요」로 적지 않는다', () {
    final text = allText();
    expect(count(text, RegExp(r'커스텀 모델에 필수|약정이 필요')), 0);
    expect(text.contains('온디맨드 추론용 모델 배포'), isTrue);
    expect(text.contains('온디맨드 추론용 배포'), isTrue);
  });

  // ── Y3 ───────────────────────────────────────────────────────────────────
  test('Y3: KMS 온디맨드 회전 한도를 10회로 적지 않는다 (쿼터 25회·조정 불가)', () {
    final text = allText();
    expect(count(text, RegExp(r'평생 10회|온디맨드 회전 키당 10회')), 0);
    expect(text.contains('온디맨드 회전은 키당 25회'), isTrue);
    expect(text.contains('조정 불가'), isTrue);
    // 공식 내부 어긋남을 숨기지 않는다.
    expect(text.contains('KMS FAQ 는 10회로 적어'), isTrue);
  });

  // ── Y4 ───────────────────────────────────────────────────────────────────
  test('Y4: 구체화된 뷰를 「Redshift 의 객체라 성립하지 않는다」로 적지 않는다', () {
    final text = allText();
    expect(count(text, RegExp(r'구체화된 뷰는 Amazon Redshift의 객체')), 0);
    expect(text.contains('AWS Glue Data Catalog'), isTrue);
    // 정답(SPICE)의 유일성을 설명하는 문장이 들어갔다.
    expect(text.contains('반복 열람의 쿼리 비용 자체를 없애는 수단은 SPICE'), isTrue);
  });

  // ── Y5 ───────────────────────────────────────────────────────────────────
  test('Y5: IA 와 S3 내보내기를 「공식 자료 간 서술이 엇갈려」로 적지 않고 '
      'Essentials 를 병기한다', () {
    final text = allText();
    expect(count(text, RegExp(r'공식 자료 간 서술이 엇갈려')), 0);
    expect(text.contains('S3 내보내기 자체는 지원'), isTrue);
    // 개명 병기 — 로그 클래스를 정의하는 두 자리.
    expect(count(text, RegExp(r'Essentials')), greaterThanOrEqualTo(3));
    expect(count(text, RegExp(r'2026-12 부터 API 응답이 `ESSENTIALS`')), 2);
    // ⚠️ `Infrequent Access` 자체는 금지하지 않는다 — API 값이 계속 유효하고
    //    S3 스토리지 클래스의 IA 와 문자열이 같다.
    expect(text.contains('Infrequent Access'), isTrue);
  });

  // ── Y6 ───────────────────────────────────────────────────────────────────
  test('Y6: dea-t1-4-q10 과 md 가 cdk bootstrap 사실의 정본을 인용한다', () {
    final q = questionsOf('t1-4').firstWhere((q) => q['id'] == 'dea-t1-4-q10');
    final urls = (q['sources'] as List)
        .map((s) => '${(s as Map)['url']}')
        .toList();
    expect(urls.first, 'https://docs.aws.amazon.com/cdk/v2/guide/bootstrapping.html',
        reason: '정답의 핵심 사실을 담는 페이지가 첫 출처여야 한다');
    // 기존 둘은 각각 다른 사실의 근거라 지우지 않았다.
    expect(urls, contains('https://docs.aws.amazon.com/cdk/v2/guide/home.html'));
    expect(urls, contains('https://docs.aws.amazon.com/cdk/v2/guide/constructs.html'));
    expect(mdOf('t1-4').contains('cdk/v2/guide/bootstrapping.html'), isTrue,
        reason: '학습문서 참고자료에도 함께 넣는다(문항 가드는 .md 를 보지 않는다)');
  });

  // ── Y7 ───────────────────────────────────────────────────────────────────
  test('Y7: 「128의 배수」를 공식 권고로 적지 않고 re:Post 로 귀속한다', () {
    // 「128의 배수」가 나오는 자리는 전부 귀속이 붙어 있어야 한다.
    final offenders = <String>[];
    for (final u in units()) {
      if (!u.contains('128의 배수')) continue;
      if (RegExp(r're:Post').hasMatch(u)) continue;
      offenders.add(u.trim().substring(0, u.trim().length.clamp(0, 90)));
    }
    expect(offenders, isEmpty,
        reason: '공식 두 페이지에 그 서술이 없다(근거가 repost.aws 뿐): $offenders');
    expect(count(allText(), RegExp(r'128의 배수')), greaterThanOrEqualTo(5),
        reason: '귀속해서 남긴 것이지 걷은 것이 아니다');
  });

  // ── Y8 ───────────────────────────────────────────────────────────────────
  test('Y8: RDS Performance Insights 종료 날짜를 단정하지 않는다', () {
    final text = allText();
    expect(count(text, RegExp(r'2026-06-30 수명 종료')), 0);
    expect(text.contains('CloudWatch Database Insights'), isTrue);
    expect(text.contains('공식 문서에서 확인되지 않아 단정하지 않습니다'), isTrue);
  });

  // ── Y9 ───────────────────────────────────────────────────────────────────
  test('Y9: Glue Data Catalog compaction 시작 조건이 공식 수치다', () {
    final text = allText();
    expect(count(text, RegExp(r'파일 수가 설정값\(기본 5개\)')), 0);
    expect(text.contains('100개를 넘고'), isTrue);
    expect(text.contains('`write.target-file-size-bytes`'), isTrue);
    expect(text.contains('512 MB'), isTrue);
  });

  // ── Y10 (문맥 규칙) ──────────────────────────────────────────────────────
  test('Y10: 퍼블릭 서브넷의 NAT 게이트웨이를 배타 조건으로 적지 않는다', () {
    final offenders = <String>[];
    for (final u in units()) {
      if (!RegExp(r'(퍼블릭|공용) 서브넷의 NAT 게이트웨이').hasMatch(u)) continue;
      if (!RegExp(r'경유해야|있어야|써야|필요합니다').hasMatch(u)) continue;
      if (RegExp(r'리전 NAT 게이트웨이|영역형').hasMatch(u)) continue;
      offenders.add(u.trim().substring(0, u.trim().length.clamp(0, 90)));
    }
    expect(offenders, isEmpty,
        reason: '2025-11 리전 NAT 게이트웨이는 퍼블릭 서브넷이 필요 없다: $offenders');
    expect(count(allText(), RegExp(r'리전 NAT 게이트웨이')), greaterThanOrEqualTo(5));
  });

  // ── Y11 ──────────────────────────────────────────────────────────────────
  test('Y11: MWAA 스케줄러 수에 mw1.micro 예외를 적는다', () {
    final offenders = <String>[];
    for (final u in units()) {
      if (!RegExp(r'스케줄러').hasMatch(u)) continue;
      if (!RegExp(r'최소 2|2~5|2에서 최대 5').hasMatch(u)) continue;
      if (u.contains('mw1.micro')) continue;
      offenders.add(u.trim().substring(0, u.trim().length.clamp(0, 90)));
    }
    expect(offenders, isEmpty, reason: 'mw1.micro 는 1 이다: $offenders');
    expect(count(allText(), RegExp(r'`mw1\.micro` 는 1')), greaterThanOrEqualTo(2));
  });

  // ── Y12 ──────────────────────────────────────────────────────────────────
  test('Y12: Kinesis ESM 실패 대상을 (SQS/SNS) 둘로만 적지 않는다', () {
    final text = allText();
    expect(count(text, RegExp(r'실패 대상\(SQS/SNS\)')), 0);
    expect(text.contains('SNS 주제·SQS 대기열·S3 버킷·Kafka'), isTrue);
    // S3 대상만 호출 레코드 전체를 담는다는 갈림길.
    expect(count(text, RegExp(r'S3 대상에만?\s*호출 레코드 전체|S3 대상에는 호출 레코드 전체')),
        greaterThanOrEqualTo(2));
  });

  // ── Y13 ──────────────────────────────────────────────────────────────────
  test('Y13: 낡은 저작 상태 문구 「사람 검수 전」이 0건이다', () {
    // ⚠️ 이것은 **낡은 문구 금지**이고 공개 상태 단정이 아니다 — `verified` 를 보지 않는다.
    expect(count(allText(), RegExp(r'사람 검수 전')), 0);
    // 수집·저작 날짜는 사실이므로 남아 있어야 한다.
    expect(count(allText(), RegExp(r'수집·대조:')), 17);
  });

  // ── Y14 ──────────────────────────────────────────────────────────────────
  test('Y14: dea-t4-1-q4 의 첫 출처가 공식 문서다 (repost 단일 출처였다)', () {
    final q = questionsOf('t4-1').firstWhere((q) => q['id'] == 'dea-t4-1-q4');
    final urls = (q['sources'] as List)
        .map((s) => '${(s as Map)['url']}')
        .toList();
    expect(urls.length, greaterThanOrEqualTo(2));
    expect(urls.first,
        'https://docs.aws.amazon.com/lambda/latest/dg/configuration-vpc-internet.html');
    expect(urls.first.contains('repost.aws'), isFalse);
  });

  // ── Y15 ──────────────────────────────────────────────────────────────────
  test('Y15: 「작은 차원 테이블은 ALL 분산」을 무수식으로 처방하지 않는다', () {
    final offenders = <String>[];
    for (final u in units()) {
      if (!RegExp(r'ALL 분산|DISTSTYLE ALL').hasMatch(u)) continue;
      if (!RegExp(r'작은 (차원|디멘션)').hasMatch(u)) continue;
      if (RegExp(r'colocate|이점이 크지 않|함정').hasMatch(u)) continue;
      offenders.add(u.trim().substring(0, u.trim().length.clamp(0, 90)));
    }
    expect(offenders, isEmpty,
        reason: '공식 조건은 「작다」가 아니라 colocate 불가다: $offenders');
    expect(mdOf('t3-4').contains('colocate 할 수 없는'), isTrue);
  });

  // ── Y16 ──────────────────────────────────────────────────────────────────
  test('Y16: 리다이렉트되는 백서 출처에 상태 메모가 달려 있다', () {
    const wp = 'whitepapers/latest/big-data-analytics-options/amazon-athena.html';
    // md 쪽 — 같은 줄에 상태 메모가 있어야 한다.
    final line = mdOf('t1-2')
        .split('\n')
        .firstWhere((l) => l.contains(wp), orElse: () => '');
    expect(line, isNotEmpty);
    expect(RegExp(r'리다이렉트').hasMatch(line), isTrue);
    // 문항 쪽 — 출처 제목에 상태를 적는다(지우지 않는다: 첫 출처가 그 사실을 담지 않는다).
    final q = questionsOf('t1-2').firstWhere((q) => q['id'] == 'dea-t1-2-q7');
    final src = (q['sources'] as List)
        .cast<Map>()
        .firstWhere((s) => '${s['url']}'.contains(wp));
    expect(RegExp(r'리다이렉트').hasMatch('${src['title']}'), isTrue);
  });

  // ── G3 · G4 · G5 · G7 ────────────────────────────────────────────────────
  test('G3: 저작 과정 메모가 학습자 글에 남아 있지 않다', () {
    final text = allText();
    expect(count(text, RegExp(r'문서 간 일수 표현에 차이')), 0);
    expect(count(text, RegExp(r'문항은 피하세요')), 0);
    // ⚠️ 「공식 문서에서 확인되지 않았으므로 정답으로 고르지 않습니다」류의 **시험 전략**
    //    서술은 의도된 것이므로 금지하지 않는다(일괄 금지 금지 — 한 줄씩 판정한다).
  });

  test('G4: 지문이 특정 연월에 묶여 있지 않다', () {
    expect(count(allText(), RegExp(r'2026-1[01] 현재')), 0);
  });

  test('G5: 「북반」 오타가 0건이다', () {
    expect(count(allText(), RegExp(r'북반')), 0);
    expect(allText().contains('Glue 북마크 Disable'), isTrue);
  });

  test('G7: Quick 출처 제목이 실제 페이지 제목과 같다', () {
    final text = allText();
    expect(count(text, RegExp(r'What is Amazon Quick')), 0,
        reason: '실제 <title> 은 「What is AWS Quick?」이다');
    expect(count(text, RegExp(r'What is AWS Quick')), greaterThanOrEqualTo(3));
    // 본문 표기는 **시험 가이드 표기(Amazon Quick)** 를 유지한다 — 둘 다 공식 근거가 있다.
    expect(text.contains('Amazon Quick'), isTrue);
  });

  // ── 정답 인덱스 불변 ─────────────────────────────────────────────────────
  test('이 배치가 손댄 18문항의 정답 인덱스가 1단계 실측값과 같다', () {
    const expected = <String, int>{
      'dea-t1-1-q7': 1, 'dea-t1-1-q15': 0, 'dea-t1-1-q16': 0,
      'dea-t1-2-q7': 0, 'dea-t1-2-q12': 0,
      'dea-t1-3-q9': 0,
      'dea-t1-4-q10': 0, 'dea-t1-4-q13': 0,
      'dea-t2-1-q6': 2, 'dea-t2-3-q1': 0,
      'dea-t3-2-q1': 1, 'dea-t3-2-q3': 0, 'dea-t3-2-q9': 1,
      'dea-t3-3-q2': 2,
      'dea-t4-1-q4': 3, 'dea-t4-3-q6': 0,
      'dea-t4-4-q7': 2, 'dea-t4-4-q11': 2,
    };
    final actual = <String, int>{};
    for (final t in tasks) {
      for (final q in questionsOf(t)) {
        final id = '${q['id']}';
        if (expected.containsKey(id)) actual[id] = q['correct'] as int;
      }
    }
    expect(actual.length, expected.length, reason: '문항 id 가 사라졌다');
    expect(actual, expected,
        reason: '보정은 해설·오답 근거·출처·학습문서만 바꿨다 — 정답은 불변이다');
  });
}
