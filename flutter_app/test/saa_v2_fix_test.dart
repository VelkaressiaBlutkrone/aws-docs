import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 2026-11-17 전 콘텐츠 검증 2단계(보정) — SAA 회귀 가드.
///
/// 1단계 보고(`docs/audits/2026-11-17-full-verify/saa.md`)의 🔴 5건 · 🟡 내용
/// 계열 17건 · 출처 계열 · 🟢 2건을 공식 문서로 재확인해 반영한 것을 고정한다.
/// 판정·근거의 정본은 `docs/audits/2026-11-17-full-verify/saa-phase2.md` 다.
///
/// ## 이 가드의 설계 — 왜 「정규식 + 전수 집계」인가
///
/// 1단계 보고의 중심 발견은 **「리터럴 전파 가드를 문항이 어형으로 비켜 갔다」**
/// 였다. 🔴 4건 중 3건이 md 는 2026-10-19 에 정정됐고 금지 문구가
/// `saa_question_propagation_test` 의 `_rules` 에 등재돼 있는데 문항만 남은
/// 자리다(「제한된 횟수만 재시도하고」 ↔ 「재시도가 제한적이어서」 ·
/// 「\$0.01/GB + \$0.02/GB」 ↔ 「\$0.01 교차 AZ + \$0.02 처리」). 그래서 이 파일의
/// 사실 단정은 **문항 ID 별 리터럴이 아니라 자격증 전수(md 24편 + 문항 360개)를
/// 정규식으로 센다.**
///
/// ⚠️ **탐지기는 「가르치는 층」과 「오답 보기」를 가른다.** 오답 보기는 일부러
/// 틀린 서술이라 금지 문구가 들어갈 수 있다 — 그런 자리는 예외를 **성질로**
/// 좁히고 그 예외가 몇 건인지 대조군으로 고정한다(예외가 모든 것을 삼키는
/// 상태와 「정말 0건」을 구별하기 위해서다).
///
/// ⚠️ **`verified` 를 단정하지 않는다.** 구조 단정(뱅크 24 · Task 당 15 ·
/// 보기 4개 · 손댄 문항의 정답 인덱스 불변)으로 대신한다.
void main() {
  const dir = 'assets/content/saa';

  List<File> bankFiles() => Directory(dir)
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.questions.json'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  List<File> mdFiles() => Directory(dir)
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.md'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  List<Map<String, dynamic>> questionsOf(File f) =>
      ((json.decode(f.readAsStringSync()) as Map<String, dynamic>)['questions']
              as List)
          .cast<Map<String, dynamic>>();

  final all = bankFiles().expand(questionsOf).toList();

  Map<String, dynamic> question(String qid) =>
      all.firstWhere((q) => q['id'] == qid, orElse: () => fail('$qid 없음'));

  List<String> options(Map<String, dynamic> q) =>
      (q['options'] as List).cast<String>();

  List<String> wrongs(Map<String, dynamic> q) =>
      ((q['wrongExplanations'] as Map?) ?? const {})
          .values
          .cast<String>()
          .toList();

  List<Map<String, dynamic>> sources(Map<String, dynamic> q) =>
      (q['sources'] as List).cast<Map<String, dynamic>>();

  List<String> urls(Map<String, dynamic> q) =>
      sources(q).map((s) => s['url'] as String).toList();

  /// 문항 전체(오답 보기·출처 제목 포함).
  String allText(Map<String, dynamic> q) => <String>[
        q['skill'] as String? ?? '',
        q['stem'] as String? ?? '',
        ...options(q),
        q['explanation'] as String? ?? '',
        ...wrongs(q),
        ...sources(q).map((s) => s['title'] as String? ?? ''),
      ].join('\n');

  /// 「가르치는 층」 — 오답 보기 본문과 출처 제목을 뺀다.
  String teach(Map<String, dynamic> q) => <String>[
        q['skill'] as String? ?? '',
        q['stem'] as String? ?? '',
        options(q)[q['correct'] as int],
        q['explanation'] as String? ?? '',
        ...wrongs(q),
      ].join('\n');

  String md(String id) => File('$dir/$id.md').readAsStringSync();

  /// md 전 줄 — `(파일명:줄번호, 줄)`.
  Iterable<MapEntry<String, String>> mdLines() sync* {
    for (final f in mdFiles()) {
      final name = f.uri.pathSegments.last;
      final lines = f.readAsStringSync().split('\n');
      for (var i = 0; i < lines.length; i++) {
        yield MapEntry('$name:${i + 1}', lines[i]);
      }
    }
  }

  /// 전수 탐지: 문항(문항 단위) + md(줄 단위)에서 [rx] 가 걸리는 자리.
  List<String> hits(RegExp rx, {bool teachOnly = false}) => <String>[
        for (final q in all)
          if (rx.hasMatch(teachOnly ? teach(q) : allText(q))) q['id'] as String,
        for (final e in mdLines())
          if (rx.hasMatch(e.value)) e.key,
      ];

  // ═══════════════════════ 대조군 ═══════════════════════

  group('대조군 — 콘텐츠가 읽혔다', () {
    test('뱅크 24 · 문항 360 · Task 당 15 · 보기 4개', () {
      expect(bankFiles().length, 24);
      expect(all.length, 360);
      for (final f in bankFiles()) {
        expect(questionsOf(f).length, 15, reason: f.path);
      }
      for (final q in all) {
        expect(options(q).length, 4, reason: '${q['id']}');
        expect(sources(q), isNotEmpty, reason: '${q['id']}: 출처가 비었다');
      }
    });

    test('학습문서 24편이 읽혔고 줄 단위 탐지기가 본문을 본다', () {
      expect(mdFiles().length, 24);
      for (final f in mdFiles()) {
        expect(f.readAsStringSync().length, greaterThan(8000), reason: f.path);
      }
      // 같은 탐지 경로가 **분명히 있는** 문구를 찾는다(0건 통과가 파일을
      // 못 읽어서가 아님을 보인다).
      expect(hits(RegExp('Geoproximity')).length, greaterThanOrEqualTo(3));
      expect(hits(RegExp('Multi-AZ')).length, greaterThanOrEqualTo(20));
    });

    test('본문을 손댄 28문항의 정답 인덱스가 불변이다', () {
      // 2026-11-17 `git show HEAD:` 대비 실측값이다(보고는 일부만 적는다 —
      // 추측하지 않고 덤프해서 붙였다).
      const correct = <String, int>{
        'saa-t1-2-q9': 2, 'saa-t1-2-q11': 1, 'saa-t1-3-q7': 1,
        'saa-t1-3-q8': 3, 'saa-t1-5-q9': 1, 'saa-t1-5-q10': 3,
        'saa-t2-1-q7': 1, 'saa-t2-1-q8': 1, 'saa-t2-3-q15': 1,
        'saa-t2-4-q1': 1, 'saa-t2-4-q2': 2, 'saa-t2-5-q8': 0,
        'saa-t2-5-q11': 0, 'saa-t3-3-q1': 1, 'saa-t3-3-q2': 2,
        'saa-t3-4-q8': 2, 'saa-t3-5-q11': 3, 'saa-t3-5-q14': 2,
        'saa-t3-8-q11': 0, 'saa-t3-9-q9': 1, 'saa-t3-9-q15': 2,
        'saa-t4-3-q8': 2, 'saa-t4-4-q4': 1, 'saa-t4-4-q6': 3,
        'saa-t4-4-q7': 1, 'saa-t4-4-q12': 2, 'saa-t4-4-q15': 1,
        'saa-t4-5-q7': 3,
      };
      expect(correct.length, 28);
      correct.forEach((qid, c) {
        expect(question(qid)['correct'], c, reason: '$qid 정답 인덱스');
      });
    });
  });

  // ═══════════════════════ 🔴 R1~R5 ═══════════════════════

  group('R1 — SNS→Lambda 는 재시도가 부족해서 떨어지는 보기가 아니다', () {
    // 공식 `sns-message-delivery-retries.html`: AWS 관리형 엔드포인트(Lambda·
    // SQS·Firehose) 합계 "100,015 times, over 23 days" · "all 5XX errors and
    // 429 (too many requests sent) errors as retryable" · DLQ 는 구독 단위.
    test('전수: 「재시도가 제한」·「처리 보장을 위해 SQS」 0건', () {
      expect(hits(RegExp(r'재시도가 제한|재시도[^.\n]{0,12}제한적')), isEmpty);
      expect(hits(RegExp(r'처리 보장을 위해|처리 보장의 핵심')), isEmpty);
    });

    test('saa-t2-1-q7 이 공식 수치와 그 근거 페이지를 싣는다', () {
      final q = question('saa-t2-1-q7');
      expect(teach(q), contains('100,015회'));
      expect(teach(q), contains('내구성 버퍼'));
      expect(urls(q).any((u) => u.contains('sns-message-delivery-retries')),
          isTrue);
      expect(urls(q).any((u) => u.contains('sns-dead-letter-queues')), isTrue);
    });
  });

  group('R2 — Lake Formation 권한의 지원 수준은 엔진마다 다르다', () {
    // 공식 `working-with-services.html` 표: Apache Hive on Amazon EMR (EC2) 의
    // 행·셀 수준 "Not supported" · EMR on EKS / Athena Spark 전부 "Not supported".
    test('전수: 「Lake Formation … 일관되게」 단정 0건', () {
      expect(hits(RegExp(r'Lake Formation[^.\n]{0,40}일관되게')), isEmpty);
      expect(hits(RegExp(r'(Athena|EMR)[^.\n]{0,30}전(체|반)에[^.\n]{0,25}일관')),
          isEmpty);
    });

    test('saa-t3-9-q9 가 엔진별 차이와 지원 표 페이지를 싣는다', () {
      final q = question('saa-t3-9-q9');
      expect(q['explanation'], contains('엔진마다 다릅니다'));
      expect(q['explanation'], contains('Apache Hive'));
      expect(urls(q).any((u) => u.contains('working-with-services')), isTrue);
    });
  });

  group('R3 — Transit Gateway 쪽에 교차 AZ 전송 요금을 합산하지 않는다', () {
    // 공식 `eks/latest/best-practices/cost-opt-networking.html`: "There is no
    // destination cost associated with inter-AZ traffic that flows through
    // the TGW." — 같은 Task 학습문서가 2026-10-19 에 「이중 계상」으로 정정한
    // 산술이 문항에만 남아 있었다.
    final arith = RegExp(
        r'\$0\.01 교차 AZ \+|\$0\.01/GB에[^.\n]{0,40}\$0\.02/GB가 추가|'
        r'Transit Gateway[가는]?[^.\n,]{0,20}\$0\.03');

    test('전수: TGW = 교차 AZ + 처리 합산 산술 0건', () {
      expect(hits(arith), isEmpty);
    });

    test('대조군: 탐지기가 옛 정답 보기를 실제로 잡는다', () {
      expect(
          arith.hasMatch('VPC 피어링 \$0.01/GB(교차 AZ 전송), Transit Gateway '
              '\$0.03/GB(\$0.01 교차 AZ + \$0.02 처리)로 피어링이 저렴하다'),
          isTrue);
      // 일부러 틀린 오답 보기 「VPC 피어링 $0.03/GB, Transit Gateway $0.01/GB」
      // 는 TGW 에 0.03 을 붙이지 않으므로 탐지 대상이 아니다 — 그 보기가
      // 남아 있다는 것이 「0건이 탐지기 고장이 아님」의 둘째 근거다.
      final q = question('saa-t4-4-q12');
      expect(options(q).where((o) => o.contains(r'$0.03/GB')).length, 1);
      expect(options(q)[q['correct'] as int].contains(r'$0.03'), isFalse);
    });

    test('saa-t4-4-q12 의 갈림길은 데이터 처리 요금의 유무다', () {
      final q = question('saa-t4-4-q12');
      expect(q['explanation'], contains('데이터 처리 요금의 유무'));
      expect(options(q)[q['correct'] as int], contains('데이터 처리'));
      expect(urls(q).any((u) => u.contains('cost-opt-networking')), isTrue);
      expect(urls(q).any((u) => u.contains('transit-gateway/pricing')), isTrue);
      expect((q['explanation'] as String).length, lessThan(400),
          reason: 'prescreen explanation-long 임계');
    });
  });

  group('R4 — NAT 인스턴스는 「아웃바운드 전용」이 아니다(정답이 둘이던 자리)', () {
    // 공식 `vpc-nat-comparison.html` 표: Port forwarding — NAT gateway "Not
    // supported." / NAT instance "Manually customize the configuration to
    // support port forwarding." · Bastion servers — "Not supported." / "Use as
    // a bastion server."
    test('전수: 「NAT 인스턴스 … 아웃바운드 전용」 단정 0건', () {
      expect(hits(RegExp(r'NAT 인스턴스[^\n]{0,80}아웃바운드 전용')), isEmpty);
      expect(hits(RegExp(r'NAT 인스턴스도 NAT 게이트웨이와 동일')), isEmpty);
    });

    test('saa-t1-3-q8 의 오답 보기에 공식 비교표로 참인 서술이 없다', () {
      final q = question('saa-t1-3-q8');
      for (final o in options(q)) {
        expect(o.contains('NAT 인스턴스로 교체하면'), isFalse, reason: o);
      }
      // 새 오답 보기는 공식 표가 그대로 반증한다(NAT 게이트웨이 포트 포워딩
      // = Not supported).
      expect(options(q)[1], contains('포트 포워딩을 지원'));
      expect((q['wrongExplanations'] as Map)['1'], contains('NAT 인스턴스'));
      expect(urls(q).any((u) => u.contains('vpc-nat-comparison')), isTrue);
    });

    test('saa-t1-3.md 가 포트 포워딩·배스천을 적는다', () {
      expect(md('saa-t1-3'), contains('포트 포워딩·배스천 서버'));
    });
  });

  group('R5 — Geoproximity 는 Traffic Flow 전용이 아니다(라이브 학습문서)', () {
    // 공식 `routing-policy.html`: "You can use geoproximity routing to create
    // records in a private hosted zone." / `routing-policy-geoproximity.html`:
    // "The maps are available only with Traffic Flow."
    final claim = RegExp(
        r'Traffic Flow\*{0,2} ?기능에서만|Traffic Flow[^|\n]{0,12}필요|'
        r'Traffic Flow 없이는|Traffic Flow에서만 사용');

    test('전수: 「Traffic Flow 에서만·필요」 단정은 오해를 인용하는 줄에만 남는다', () {
      // 예외의 성질: 「흔한 함정」 항목이 **틀린 믿음을 따옴표로 인용**하는 줄
      // (`**"…"**`). 그 줄은 바로 뒤에서 정정한다.
      bool quoted(String line) => line.contains('**"') && line.contains('"**');
      final bad = <String>[
        for (final q in all)
          if (claim.hasMatch(teach(q))) q['id'] as String,
        for (final e in mdLines())
          if (claim.hasMatch(e.value) && !quoted(e.value)) e.key,
      ];
      expect(bad, isEmpty);
      final exempt = mdLines()
          .where((e) => claim.hasMatch(e.value) && quoted(e.value))
          .toList();
      expect(exempt.length, 1, reason: '예외 줄 수가 바뀌었다 — 다시 읽을 것');
      expect(exempt.single.value, contains('편향 범위를 그려 보여 주는 지도'));
    });

    test('saa-t3-7.md 가 문항 q6 과 같은 사실을 가르친다', () {
      final t = md('saa-t3-7');
      expect(t, contains('Traffic Flow 전용이 아니고'));
      expect(t, contains('프라이빗 호스팅 영역'));
      expect(allText(question('saa-t3-7-q6')), contains('Traffic Flow 전용이 아니고'));
    });
  });

  // ═══════════════════════ 🟡 내용 계열 ═══════════════════════

  group('Y1·Y2 — Control Tower 예방 제어 셋 · 감사 계정의 두 역할', () {
    // 공식 `control-behavior.html`: "implemented using Service Control Policies
    // (SCPs), Resource Control Policies (RCPs), and declarative policies".
    // 공식 `special-accounts.html`: "auditor (read-only) and administrator
    // (full-access) cross-account roles" · "previous name: the audit account".
    final scpOnly = RegExp(r'예방적[^.\n]{0,25}SCP(?!·RCP)');

    test('전수(가르치는 층 + md): 예방 제어를 SCP 하나로 적지 않는다', () {
      expect(hits(scpOnly, teachOnly: true), isEmpty);
      // 대조군: 짝짓기 문항의 **오답 보기** 「예방적(Preventive) — SCP」는 남아
      // 있다(가르치는 층이 아니다) — 층 분리가 공허하지 않다.
      expect(options(question('saa-t1-2-q9')).where(scpOnly.hasMatch).length, 1);
    });

    test('saa-t1-2-q9 · md 가 셋을 적고 근거 페이지를 싣는다', () {
      final q = question('saa-t1-2-q9');
      expect(q['explanation'], contains('SCP·RCP·선언적 정책'));
      expect(urls(q).any((u) => u.contains('control-behavior')), isTrue);
      expect(md('saa-t1-2'), contains('SCP·RCP·선언적 정책'));
    });

    test('전수: 감사 계정을 「전 계정 읽기 전용」으로만 적지 않는다', () {
      expect(hits(RegExp(r'전 계정(에)? 읽기 전용')), isEmpty);
      expect(question('saa-t1-2-q11')['explanation'], contains('관리자 역할'));
      expect(md('saa-t1-2'), contains('Config aggregator'));
    });
  });

  group('Y3 — Macie 는 머신러닝과 패턴 매칭', () {
    // 공식 `what-is-macie.html`: "machine learning and pattern matching".
    final mlOnly = RegExp(r'Macie[^.\n]{0,60}머신러닝(?!과 패턴| ?\+ ?패턴)');

    test('전수: 「Macie … 머신러닝」 단독 서술 0건', () {
      expect(hits(mlOnly), isEmpty);
    });

    test('대조군: 탐지기가 옛 문구를 잡고 정정문은 통과시킨다', () {
      expect(mlOnly.hasMatch('Amazon Macie — 머신러닝으로 S3를 스캔해'), isTrue);
      expect(mlOnly.hasMatch('Amazon Macie — 머신러닝과 패턴 매칭으로 S3를 스캔해'),
          isFalse);
      final q = question('saa-t1-5-q9');
      expect(options(q)[q['correct'] as int], contains('머신러닝과 패턴 매칭'));
    });
  });

  group('Y5·Y6 — Multi-AZ 의 동기 복제는 「DB 인스턴스 배포」로 한정한다', () {
    // 공식 `Concepts.MultiAZSingleStandby.html`: "can have increased write and
    // commit latency compared to a Single-AZ deployment". 공식
    // `multi-az-db-clusters-concepts.html`: "a semisynchronous, high
    // availability deployment mode … with two readable replica DB instances".
    final sync = RegExp(r'(?<!비)(?<!반)동기(?!화)');
    final qualified = RegExp(r'인스턴스 배포|DB 클러스터|반동기');
    bool unqualified(String t) =>
        t.contains('Multi-AZ') && sync.hasMatch(t) && !qualified.hasMatch(t);

    test('전수: 한정 없는 「Multi-AZ = 동기」 0건(문항 단위 · md 줄 단위)', () {
      final bad = <String>[
        for (final q in all)
          if (unqualified(allText(q))) q['id'] as String,
        for (final e in mdLines())
          if (unqualified(e.value)) e.key,
      ];
      expect(bad, isEmpty);
    });

    test('대조군: 탐지기 민감도와 비공허성', () {
      expect(unqualified('RDS Multi-AZ는 같은 리전 내 동기 복제를 사용합니다'), isTrue);
      expect(unqualified('RDS Multi-AZ DB 인스턴스 배포는 동기 복제를 사용합니다'), isFalse);
      // 「비동기」·「동기화」는 동기 복제 단정이 아니다.
      expect(unqualified('Multi-AZ와 달리 읽기 복제본은 비동기 복제입니다'), isFalse);
      expect(unqualified('Aurora Multi-AZ … 양방향 쓰기를 동기화한다'), isFalse);
      final ok = all
          .where((q) =>
              allText(q).contains('Multi-AZ') &&
              sync.hasMatch(allText(q)) &&
              qualified.hasMatch(allText(q)))
          .length;
      expect(ok, greaterThanOrEqualTo(5), reason: '한정해서 적는 문항이 실재한다');
    });

    test('전수: 「쓰기 지연이 체감되지 않는다」 0건 + 공식 서술 있음', () {
      expect(hits(RegExp('체감되지')), isEmpty);
      expect(question('saa-t2-5-q11')['explanation'], contains('쓰기·커밋 지연이 늘 수'));
      expect(md('saa-t2-5'), contains('쓰기·커밋 지연이 늘 수'));
    });

    test('전수: 「Multi-AZ RDS 의 스탠바이는 장애조치용」에 배포 유형 한정이 있다', () {
      expect(hits(RegExp(r'Multi-AZ RDS의 스탠바이는 장애조치용')), isEmpty);
      expect(question('saa-t4-4-q15')['explanation'], contains('DB 클러스터 배포'));
    });
  });

  group('Y7 — AWS Batch 를 「실행 시간 제한 없음」으로 단정하지 않는다', () {
    // 공식 `job_timeouts.html`: "Jobs that run on Fargate resources can't
    // expect to run for more than 14 days."
    final batch = RegExp(r'(Batch|배치 오케스트레이터)[^\n]{0,140}실행 시간 제한(이)? ?없');

    test('전수: Batch 문맥의 「실행 시간 제한 없」 0건', () {
      expect(hits(batch), isEmpty);
    });

    test('대조군: ECS on Fargate 의 같은 표현은 대상이 아니고 남아 있다', () {
      // 트리거를 「실행 시간 제한 없」 전체로 넓히면 Fargate 서비스 서술까지
      // 걸린다 — Batch 문맥으로 좁힌 것이 공허하지 않음을 보인다.
      expect(hits(RegExp(r'Fargate는 실행 시간 제한')).length, greaterThanOrEqualTo(2));
      expect(batch.hasMatch('AWS Batch — 실행 시간 제한 없이 Job 제출량에 따라'), isTrue);
    });

    test('saa-t3-4-q8 · md 가 Fargate 14일 상한과 근거 페이지를 싣는다', () {
      final q = question('saa-t3-4-q8');
      expect(q['explanation'], contains('14일'));
      expect(urls(q).any((u) => u.contains('job_timeouts')), isTrue);
      expect(RegExp('14일').allMatches(md('saa-t3-4')).length,
          greaterThanOrEqualTo(2));
    });
  });

  group('Y8~Y10 — RDS Magnetic · NAT 경로 · NAT 의 Elastic IP', () {
    test('saa-t3-5-q11: Magnetic 은 「이전 세대」가 아니라 사용 중단이다', () {
      // 공식 `CHAP_Storage.html`: "Amazon RDS has deprecated magnetic storage.
      // You can no longer create new DB instances using magnetic storage".
      final t = allText(question('saa-t3-5-q11'));
      expect(RegExp(r'Magnetic[^\n]{0,30}이전 세대').hasMatch(t), isFalse);
      expect(t.contains('평균 약 100 IOPS'), isFalse,
          reason: '인용 페이지에 없는 수치다');
      expect(t, contains('사용 중단'));
      expect(t, contains('임계 용량 미만의 기준'));
    });

    test('전수: 「NAT … 인터넷을 경유」 0건 + 공식 서술 있음', () {
      // 공식 `gateway-endpoints.html`: "it does not leave the AWS network".
      expect(hits(RegExp(r'NAT[^.\n]{0,30}인터넷을 경유')), isEmpty);
      expect(teach(question('saa-t3-8-q11')), contains('AWS 네트워크를 벗어나지'));
    });

    test('전수: 「Elastic IP가 반드시」 0건 + 프라이빗 NAT 한정 있음', () {
      // 공식 `vpc-nat-gateway.html`: "You can't associate an Elastic IP
      // address with a private NAT gateway."
      expect(hits(RegExp('Elastic IP가 반드시')), isEmpty);
      final q = question('saa-t1-3-q7');
      expect(teach(q), contains('프라이빗 NAT 게이트웨이에는 Elastic IP를 연결할 수 없'));
      expect(urls(q).any((u) => u.contains('vpc-nat-gateway')), isTrue);
    });
  });

  group('Y11·Y12 — 참인 오답 보기 · 「완전 무중단」 귀속', () {
    test('saa-t2-3-q15: Beanstalk 오답 보기가 참인 서술이 아니다', () {
      // 공식 `using-features.managing.as.html`: "Your AWS Elastic Beanstalk
      // environment includes an Auto Scaling group".
      final q = question('saa-t2-3-q15');
      for (final o in options(q)) {
        expect(o.contains('자동 스케일링과 로드밸런싱을 모두 내장'), isFalse);
      }
      final w3 = (q['wrongExplanations'] as Map)['3'] as String;
      expect(w3.contains('질문의 핵심은'), isFalse,
          reason: '회피형 반박 — 보기의 참·거짓을 말해야 한다');
      expect(w3, contains('Auto Scaling 그룹이 포함'));
      expect(urls(q).any((u) => u.contains('using-features.managing.as')),
          isTrue);
    });

    test('전수: 「완전 무중단」 0건(공식 정의처럼 단정하지 않는다)', () {
      expect(hits(RegExp('완전 무중단')), isEmpty);
      expect(question('saa-t2-4-q1')['explanation'], contains('일반적으로 구분하는 방식'));
    });
  });

  group('Y13~Y15 — Aurora serverless 최솟값 · Rekognition 상태 · 엔드포인트 시간 요금', () {
    test('전수: 「기본 0.5 ACU」 0건 + 0 ACU 자동 일시 정지', () {
      // 공식 `aurora-serverless-v2.setting-capacity.html`: "It's tempting to
      // always choose 0.5 …" · "a minimum capacity of 0 ACUs".
      expect(hits(RegExp(r'기본 0\.5|최솟값\(0\.5 ACU\)만')), isEmpty);
      final q = question('saa-t4-3-q8');
      expect(q['explanation'], contains('0 ACU'));
      expect(urls(q).any((u) => u.contains('setting-capacity')), isTrue);
    });

    test('전수: Flink 언어에서 Python 을 빠뜨리지 않는다', () {
      // 공식 `managed-flink/latest/java/what-is.html`: "Java, Scala, Python,
      // or SQL". ⚠️ 전파 규칙의 리터럴 `**Java·Scala·SQL**` 은 별표가 들어
      // 있어 평문 문항과 일치할 수 없었다 — 여기서는 별표 없이 센다.
      expect(hits(RegExp(r'Java·Scala·SQL')), isEmpty);
      expect(allText(question('saa-t3-9-q15')), contains('Java·Scala·Python·SQL'));
    });

    test('Rekognition 스트리밍 영상 분석의 상태를 해설과 md 가 적는다', () {
      // 공식 `rekognition/latest/dg/streaming-video.html`: "Streaming Video
      // and Bulk Image Analysis is no longer available to new customers."
      // 상태 메모는 가르치는 층(해설)에 둔다 — md 에만 적으면 오답노트·
      // 모의고사 화면에 보이지 않는다.
      final q = question('saa-t3-9-q15');
      expect(q['explanation'], contains('신규 고객에게 더 이상 제공되지'));
      expect(urls(q).any((u) => u.contains('rekognition/latest/dg/streaming-video')),
          isTrue);
      expect(md('saa-t3-9'), contains('신규 고객에게 더 이상 제공되지'));
    });

    test('전수: 「ENI 요금·ENI 유지 비용·ENI 단위가 아니라」 0건', () {
      // 공식 PrivateLink 요금 페이지가 "in each Availability Zone" 과 "for each
      // endpoint ENI" 를 함께 적는다 — 어느 쪽도 부정하지 않고 레포가 고른
      // 표현(AZ별 시간 요금)으로 통일한다.
      expect(hits(RegExp(r'ENI 요금|ENI 유지 비용|ENI 단위가 아니라')), isEmpty);
      final q6 = question('saa-t4-4-q6');
      expect(options(q6)[q6['correct'] as int], contains('AZ별 시간 요금'));
      expect(allText(q6).contains('200개 이상'), isFalse,
          reason: '인용 페이지에 없는 수치다');
    });
  });

  group('Y16·Y17 — 학습문서에만 남아 있던 서술', () {
    test('전수: 「HTTP API 가 지연도 낮다」·「반드시 NACL」 0건', () {
      expect(hits(RegExp(r'지연도 낮|지연이 낮다')), isEmpty);
      expect(hits(RegExp(r'반드시 \**NACL')), isEmpty);
      expect(md('saa-t1-3'), contains('WAF의 IP 집합'));
    });

    test('ARC readiness check 행이 상태를 적는다', () {
      // 공식 `arc-readiness-availability-change.html`: "no longer open to new
      // customers. Existing customers can continue to use the service".
      final row = md('saa-t2-5')
          .split('\n')
          .firstWhere((l) => l.startsWith('| **readiness check**'));
      expect(row, contains('신규 고객에게 열려 있지 않'));
    });
  });

  // ═══════════════════════ 🟡 출처 계열 ═══════════════════════

  group('Y18·Y19 — 사실을 담은 페이지를 출처로 단다', () {
    // 2026-11-17 `curl -sL` 로 전부 `200 r=0` + 본문 탐침 양성을 재측정했다
    // (보고서 §1 표). 소개 페이지는 지우지 않고 **더했다** — 지우면 그 URL 이
    // 업고 있던 사실을 하나씩 다시 세어야 하고, 기존 가드가 요구하는 조각도
    // 있다.
    const added = <String, List<String>>{
      'saa-t1-1-q2': ['id_roles_use_switch-role-ec2'],
      'saa-t1-1-q3': ['lambda-intro-execution-role'],
      'saa-t1-2-q1': ['orgs_manage_policies_scps_evaluation'],
      'saa-t1-2-q4': ['orgs_manage_policies_scps_evaluation'],
      'saa-t1-2-q9': ['control-behavior'],
      'saa-t1-3-q7': ['vpc-nat-gateway'],
      'saa-t1-3-q9': ['privatelink/gateway-endpoints'],
      'saa-t1-3-q10': ['privatelink/gateway-endpoints'],
      'saa-t1-3-q13': ['userguide/flow-logs'],
      'saa-t1-4-q1': ['aws-managed-rule-groups-baseline'],
      'saa-t2-1-q10': ['eb-saas'],
      'saa-t2-2-q2': ['provisioned-concurrency'],
      'saa-t2-2-q15': ['configuration-vpc'],
      'saa-t2-3-q12': ['ec2-auto-scaling-health-checks'],
      'saa-t3-2-q2': ['userguide/general-purpose'],
      'saa-t3-3-q2': ['instance-type-names'],
      'saa-t3-3-q8': ['spot-instance-termination-notices'],
      'saa-t3-3-q10': ['placement-strategies'],
      'saa-t3-3-q13': ['placement-strategies'],
      'saa-t3-3-q14': ['UserGuide/efa.html'],
      'saa-t3-4-q7': ['batch_components'],
      'saa-t3-5-q5': [
        'Concepts.AuroraHighAvailability',
        'Aurora.Overview.StorageReliability'
      ],
      'saa-t3-6-q8': ['DAX.consistency'],
      'saa-t3-9-q15': ['rekognition/latest/dg/streaming-video'],
      'saa-t4-1-q9': ['cost-optimization-checks'],
      'saa-t4-2-q1': ['ec2-on-demand-instances'],
      'saa-t4-2-q11': ['ec2-auto-scaling-scheduled-scaling'],
      'saa-t4-3-q6': ['USER_PIOPS.ModifyingExisting', 'USER_PIOPS.Autoscaling'],
      'saa-t4-4-q8': ['AmazonCloudFront/latest/DeveloperGuide/Introduction'],
      'saa-t4-4-q9': ['AmazonCloudFront/latest/DeveloperGuide/Introduction'],
      'saa-t4-5-q5': ['cost-allocation-backfill'],
      'saa-t4-5-q7': ['cost-optimization-checks'],
      'saa-t4-5-q12': ['orgs_manage_policies_tag-policies'],
      'saa-t4-5-q14': ['framework/cost-optimization'],
    };

    test('34문항이 사실을 담은 공식 페이지를 싣는다', () {
      expect(added.length, 34);
      added.forEach((qid, frags) {
        final u = urls(question(qid));
        for (final frag in frags) {
          expect(u.any((x) => x.contains(frag)), isTrue,
              reason: '$qid: $frag 이 없다');
        }
      });
    });

    test('전수: 출처 URL 이 문항 안에서 중복되지 않고 전부 https 다', () {
      for (final q in all) {
        final u = urls(q);
        expect(u.toSet().length, u.length, reason: '${q['id']}: 중복 출처');
        expect(u.every((x) => x.startsWith('https://')), isTrue,
            reason: '${q['id']}');
      }
    });

    test('전수: AWS 블로그 출처에 「(공식)」 표기를 달지 않는다', () {
      var blogs = 0;
      for (final q in all) {
        for (final s in sources(q)) {
          if ((s['url'] as String).contains('aws.amazon.com/blogs/')) {
            blogs++;
            expect((s['title'] as String).contains('(공식)'), isFalse,
                reason: '${q['id']}: 블로그는 공식 문서가 아니다');
            // 블로그 하나만 달린 문항은 없어야 한다 — 사실은 공식 출처가 받친다.
            expect(urls(q).length, greaterThan(1), reason: '${q['id']}');
          }
        }
      }
      expect(blogs, greaterThanOrEqualTo(1), reason: '대조군 — 비공허');
    });
  });

  // ═══════════════════════ 🟢 ═══════════════════════

  group('G7·G12 — md 는 옳고 문항만 어형으로 남아 있던 표현', () {
    test('전수: 인스턴스 접미사 n 을 「네트워크 강화」로만 적지 않는다', () {
      // 공식 `instance-type-names.html`: "n – Network and EBS optimized" ·
      // "b – Block storage optimization".
      expect(hits(RegExp(r'네트워크 강화(는|\s접미사|\s기능 접미사)')), isEmpty);
      expect(allText(question('saa-t3-3-q2')), contains('네트워크·EBS 최적화'));
      expect(allText(question('saa-t3-3-q2')), contains('블록 스토리지 최적화'));
    });

    test('전수: Compute Optimizer 를 「14일 이상」으로 적지 않는다', () {
      // 공식 `view-idle-recommendations.html`: "the default lookback period of
      // 14 days" — 「이상」이 아니라 기본 14일이다.
      // 예외의 성질: 옛 문구를 **인용해 정정 경위를 적는 메모 줄**(`> 📝`).
      // 처음에는 예외 없이 걸었다가 `saa-t4-5.md` 의 2026-10-19 정정 메모가
      // 걸렸다 — 문구를 바꾸지 않고 예외를 성질로 좁히고 줄 수를 고정한다.
      final rx = RegExp(r'14일 이상');
      bool memo(String line) => line.startsWith('> 📝');
      final bad = <String>[
        for (final q in all)
          if (rx.hasMatch(allText(q))) q['id'] as String,
        for (final e in mdLines())
          if (rx.hasMatch(e.value) && !memo(e.value)) e.key,
      ];
      expect(bad, isEmpty);
      expect(
          mdLines().where((e) => rx.hasMatch(e.value) && memo(e.value)).length,
          1,
          reason: '정정 메모 인용 줄 수가 바뀌었다 — 다시 읽을 것');
      expect(question('saa-t4-5-q7')['explanation'], contains('기본 14일'));
    });

    test('saa-t3-5-q12: 출처 제목이 그 페이지에 없는 표현을 싣지 않는다', () {
      final s = sources(question('saa-t3-5-q12'))
          .firstWhere((s) => (s['url'] as String).contains('USER_ReadRepl.Promote'));
      expect((s['title'] as String).contains('되돌릴 수 없음'), isFalse);
      expect(s['title'], contains('재부팅'));
    });
  });
}
