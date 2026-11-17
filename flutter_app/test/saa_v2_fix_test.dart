import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 2026-11-17 전 콘텐츠 검증 2단계(보정) — **SAA** 가드.
///
/// 집행한 1단계 보고: `docs/audits/2026-11-17-full-verify/saa.md`
/// 반영 보고(판정 채택·기각·범위 확장): `docs/audits/2026-11-17-full-verify/saa-phase2.md`
///
/// ## 이 가드가 지키는 것
///
/// 1단계 보고의 중심 발견은 「**리터럴 전파 가드를 문항이 어형으로 비켜 갔다**」였다
/// (`saa_question_propagation_test` 의 금지 문장이 조사·구두점 하나로 일치하지 않았다).
/// 그래서 사실 단정은 **문항 ID 별 리터럴이 아니라 SAA 학습문서 24편 + 문항 360개를
/// 전수로 도는 정규식**으로 두고, 「옛 문구 0건」과 「새 공식 사실 있음」을 쌍으로 건다.
///
/// - `verified` 상태는 **단정하지 않는다**(flip 은 사람의 서명이고 이 가드가 막으면 안 된다).
///   대신 구조(Task 당 15문항 · 보기 4개 · 손댄 문항의 정답 인덱스 불변)를 본다.
/// - 탐지기마다 **단위 대조군**을 둔다 — 옛 문구는 잡고, 정정한 문구는 통과시킨다.
///
/// ## 탐지 단위
///
/// - 학습문서: **줄** 단위.
/// - 문항: 기본은 **필드** 단위(지문·보기·해설·오답 근거·출처 제목 각각). 「같은 문항 안에
///   한정어가 있으면 통과」가 맞는 규칙(Multi-AZ 배포 유형 등)만 **문항** 단위로 본다.
void main() {
  const content = 'assets/content/saa';

  final taskIds = <String>[
    for (final d in <int, int>{1: 5, 2: 5, 3: 9, 4: 5}.entries)
      for (var n = 1; n <= d.value; n++) 'saa-t${d.key}-$n',
  ];

  List<Map<String, dynamic>> bank(String task) =>
      ((json.decode(File('$content/$task.questions.json').readAsStringSync())
              as Map<String, dynamic>)['questions'] as List)
          .cast<Map<String, dynamic>>();

  final banks = <String, List<Map<String, dynamic>>>{
    for (final t in taskIds) t: bank(t),
  };
  final questions = <Map<String, dynamic>>[
    for (final t in taskIds) ...banks[t]!,
  ];
  final byId = <String, Map<String, dynamic>>{
    for (final q in questions) q['id'] as String: q,
  };
  final docs = <String, String>{
    for (final t in taskIds) t: File('$content/$t.md').readAsStringSync(),
  };

  Map<String, dynamic> question(String id) => byId[id]!;

  List<String> options(Map<String, dynamic> q) =>
      (q['options'] as List).cast<String>();

  Map<String, String> wrongs(Map<String, dynamic> q) =>
      (q['wrongExplanations'] as Map).cast<String, String>();

  List<Map<String, dynamic>> sources(Map<String, dynamic> q) =>
      (q['sources'] as List).cast<Map<String, dynamic>>();

  /// 문항의 모든 텍스트 필드(출처 제목 포함).
  List<String> fields(Map<String, dynamic> q) => <String>[
        (q['skill'] ?? '') as String,
        q['stem'] as String,
        ...options(q),
        q['explanation'] as String,
        ...wrongs(q).values,
        for (final s in sources(q)) s['title'] as String,
      ];

  String allText(Map<String, dynamic> q) => fields(q).join('\n');

  /// 가르치는 층 — 지문·정답 보기·해설·skill. 오답 근거와 오답 보기는 뺀다.
  String teaching(Map<String, dynamic> q) => <String>[
        (q['skill'] ?? '') as String,
        q['stem'] as String,
        options(q)[q['correct'] as int],
        q['explanation'] as String,
      ].join('\n');

  bool hasSource(Map<String, dynamic> q, String fragment) =>
      sources(q).any((s) => (s['url'] as String).contains(fragment));

  /// 학습문서의 (문서 id, 줄 번호, 줄) 전수.
  Iterable<({String id, int no, String line})> mdLines() sync* {
    for (final t in taskIds) {
      final lines = docs[t]!.split('\n');
      for (var i = 0; i < lines.length; i++) {
        yield (id: t, no: i + 1, line: lines[i].replaceAll('\r', ''));
      }
    }
  }

  /// 학습문서 줄 + 문항 필드 전수에서 [hit] 가 참인 자리를 모은다.
  List<String> sweep(bool Function(String) hit) => <String>[
        for (final l in mdLines())
          if (hit(l.line)) '${l.id}.md:${l.no}',
        for (final q in questions)
          for (final f in fields(q))
            if (hit(f)) '${q['id']}',
      ];

  /// 학습문서 줄 + **문항 전체**(한 문항 = 한 단위) 전수.
  List<String> sweepByQuestion(bool Function(String) hit) => <String>[
        for (final l in mdLines())
          if (hit(l.line)) '${l.id}.md:${l.no}',
        for (final q in questions)
          if (hit(allText(q))) '${q['id']}',
      ];

  // ═══════════════════════ 대조군 · 구조 ═══════════════════════

  group('대조군 — 콘텐츠가 읽혔다', () {
    test('학습문서 24편 · 뱅크 24개 · Task 당 15문항 · 보기 4개', () {
      expect(taskIds, hasLength(24));
      expect(docs.values.every((d) => d.length > 5000), isTrue);
      for (final t in taskIds) {
        expect(banks[t], hasLength(15), reason: '$t 문항 수');
      }
      expect(questions, hasLength(360));
      for (final q in questions) {
        expect(options(q), hasLength(4), reason: '${q['id']} 보기 수');
        expect(options(q).toSet(), hasLength(4), reason: '${q['id']} 보기 중복');
        expect(sources(q), isNotEmpty, reason: '${q['id']} 출처 없음');
      }
    });

    test('전수 스윕이 실제로 문구를 찾는다(0건 통과가 못 읽어서가 아니다)', () {
      expect(sweep((s) => s.contains('Multi-AZ')).length, greaterThan(30));
      expect(sweep((s) => s.contains('NAT 게이트웨이')).length, greaterThan(30));
    });
  });

  group('정답 인덱스 불변 — 이 배치는 정답을 한 건도 옮기지 않았다', () {
    // 2026-11-17 파일에서 기계로 읽은 값이다(보고는 정답 인덱스를 적지 않는 자리가 있다).
    const correct = <String, int>{
      'saa-t1-2-q9': 2,
      'saa-t1-2-q11': 1,
      'saa-t1-3-q7': 1,
      'saa-t1-3-q8': 3,
      'saa-t1-4-q4': 2,
      'saa-t1-5-q9': 1,
      'saa-t1-5-q10': 3,
      'saa-t2-1-q7': 1,
      'saa-t2-1-q8': 1,
      'saa-t2-3-q15': 1,
      'saa-t2-4-q1': 1,
      'saa-t2-4-q2': 2,
      'saa-t2-5-q8': 0,
      'saa-t2-5-q11': 0,
      'saa-t3-3-q1': 1,
      'saa-t3-3-q2': 2,
      'saa-t3-3-q8': 1,
      'saa-t3-4-q8': 2,
      'saa-t3-5-q11': 3,
      'saa-t3-5-q14': 2,
      'saa-t3-8-q7': 2,
      'saa-t3-8-q11': 0,
      'saa-t3-9-q9': 1,
      'saa-t3-9-q15': 2,
      'saa-t4-3-q8': 2,
      'saa-t4-4-q4': 1,
      'saa-t4-4-q6': 3,
      'saa-t4-4-q7': 1,
      'saa-t4-4-q12': 2,
      'saa-t4-4-q15': 1,
      'saa-t4-5-q7': 3,
      'saa-t4-5-q14': 0,
    };

    test('본문을 손댄 32문항의 정답 인덱스가 그대로다', () {
      correct.forEach((id, c) {
        expect(question(id)['correct'], c, reason: '$id 정답 인덱스가 바뀌었다');
      });
    });
  });

  // ═══════════════════════ 🔴 R1 · 🟡 Y4 — SNS 재시도 ═══════════════════════
  //
  // 공식(sns-message-delivery-retries): AWS 관리형 엔드포인트(Lambda·SQS·Firehose)는
  // "100,015 times, over 23 days". 「재시도가 제한적이라 메시지를 버린다」는 정반대다.
  // 보기를 떨어뜨리는 진짜 이유는 재시도 부족이 아니라 **내구성 버퍼가 없다(Push)**는 것.

  group('R1·Y4 SNS → Lambda 직접 구독: 재시도 부족이 아니라 버퍼 부재', () {
    final limited = RegExp(r'재시도가\s*제한|제한된 횟수만 재시도|메시지를 버릴|메시지를 버립니다'
        r'|처리 보장을 위해 SQS|처리 보장의 핵심');

    test('대조군: 탐지기가 옛 어형 셋을 잡고 정정문은 통과시킨다', () {
      expect(limited.hasMatch('재시도가 제한적이어서 메시지를 버릴 수 있습니다'), isTrue);
      expect(limited.hasMatch('제한된 횟수만 재시도하고 이후 메시지를 버립니다'), isTrue);
      expect(limited.hasMatch('SNS는 Push 후 재시도가 제한적입니다'), isTrue);
      expect(limited.hasMatch('재시도가 부족해서 떨어지는 보기가 아닙니다'), isFalse);
      expect(limited.hasMatch('exactly-once 처리 보장도 Standard의 특징입니다'), isFalse);
    });

    test('SAA 전수: 「SNS 재시도가 제한적」 계열이 0건이다', () {
      expect(sweep(limited.hasMatch), isEmpty);
    });

    test('saa-t2-1-q7: 공식 수치와 진짜 갈림길(Push·버퍼)을 적는다', () {
      final q = question('saa-t2-1-q7');
      final w2 = wrongs(q)['2']!;
      expect(w2.contains('100,015'), isTrue);
      expect(w2.contains('23일'), isTrue);
      expect(w2.contains('Push'), isTrue);
      expect(w2.contains('버퍼'), isTrue);
      expect(hasSource(q, 'sns-message-delivery-retries'), isTrue);
      expect(hasSource(q, 'sns-dead-letter-queues'), isTrue);
    });
  });

  // ═══════════════════════ 🔴 R2 — Lake Formation ═══════════════════════
  //
  // 공식 지원 표(working-with-services): Hive on EMR(EC2) 는 행·셀 수준 Not supported,
  // EMR on EKS·Athena Spark 는 세 수준 모두 Not supported. 「전반에 일관되게」는 거짓이다.

  group('R2 Lake Formation 권한은 엔진마다 지원 수준이 다르다', () {
    final uniform = RegExp(r'(전반|전체)에[^\n]{0,40}일관되게|일관되게 적용되(므로|어야)');

    test('대조군: 옛 지문·해설을 잡고 정정문은 통과시킨다', () {
      expect(uniform.hasMatch('Athena·EMR 쿼리 전체에 이 권한이 일관되게 적용되어야 한다'), isTrue);
      expect(
          uniform.hasMatch('Athena·EMR·Redshift Spectrum 쿼리 전반에 Lake Formation '
              '권한이 일관되게 적용되므로'),
          isTrue);
      expect(uniform.hasMatch('지원 수준은 엔진마다 다릅니다'), isFalse);
    });

    test('SAA 전수: 「전 엔진에 일관되게 적용」 단정이 0건이다', () {
      expect(sweep(uniform.hasMatch), isEmpty);
    });

    test('saa-t3-9-q9: 엔진별 차이와 지원 표 출처를 싣는다', () {
      final q = question('saa-t3-9-q9');
      final e = q['explanation'] as String;
      expect(e.contains('엔진마다'), isTrue);
      expect(e.contains('EMR on EKS'), isTrue);
      expect(e.contains('Hive'), isTrue);
      expect(hasSource(q, 'lake-formation/latest/dg/working-with-services'), isTrue);
    });
  });

  // ═══════════════════════ 🔴 R3 — TGW 단가 합산 ═══════════════════════
  //
  // 같은 Task 학습문서(saa-t4-4.md)와 md 가드가 「$0.01 + $0.02」 합산을 이중 계상으로
  // 금지한다(EKS 모범 사례: "There is no destination cost associated with inter-AZ
  // traffic that flows through the TGW"). 요금 페이지의 일반 문구와 갈리는 자리라
  // 문항은 **TGW 쪽 전송 요금 유무를 정답의 근거로 쓰지 않고** 처리 요금 유무로 가른다.

  group('R3 피어링 대 Transit Gateway: 갈림길은 데이터 처리 요금', () {
    final summed = RegExp(r'\$0\.03/GB|\$0\.01\s*교차 AZ\s*\+|\$0\.01/GB\s*\+\s*\$0\.02'
        r'|교차 AZ 전송 \$0\.01/GB에[^\n]{0,40}추가');

    test('대조군: 합산 어형 넷을 잡는다', () {
      expect(summed.hasMatch(r'Transit Gateway $0.03/GB($0.01 교차 AZ + $0.02 처리)'), isTrue);
      expect(summed.hasMatch(r'$0.01/GB + $0.02/GB'), isTrue);
      expect(
          summed.hasMatch(r'교차 AZ 전송 $0.01/GB에 Transit Gateway 데이터 처리 요금 '
              r'$0.02/GB가 추가되어'),
          isTrue);
      expect(summed.hasMatch(r'GB당 데이터 처리 요금 $0.02가 붙으므로'), isFalse);
    });

    test('SAA 전수: TGW 에 교차 AZ 전송 요금을 합산한 수치가 0건이다', () {
      expect(sweep(summed.hasMatch), isEmpty);
    });

    test('saa-t4-4-q12: 정답 보기가 처리 요금 유무로 가르고 기존 한정을 유지한다', () {
      final q = question('saa-t4-4-q12');
      final answer = options(q)[2];
      expect(answer.contains('데이터 처리 요금'), isTrue);
      expect(answer.contains('피어링이 저렴'), isTrue);
      // 2026-10-28 판정(saa_question_facts_test) — 송신 측 기준과 양방향 과금 설명.
      expect((q['stem'] as String).contains('송신 측 1 GB 기준'), isTrue);
      expect((q['explanation'] as String).contains('양방향'), isTrue);
      // 오답 셋이 모두 「처리 요금이 붙는 쪽」을 틀리게 적는다 — 참인 보기가 없다.
      expect(options(q)[0].contains('Transit Gateway는 처리 요금이 없어'), isTrue);
      expect(options(q)[1].contains('둘 다 데이터 처리 요금이 없어'), isTrue);
    });
  });

  // ═══════════════════════ 🔴 R4 — NAT 인스턴스 ═══════════════════════
  //
  // 공식 비교표(vpc-nat-comparison): Port forwarding — NAT gateway "Not supported" /
  // NAT instance "Manually customize the configuration to support port forwarding";
  // Bastion servers — "Not supported" / "Use as a bastion server".
  // 「NAT 인스턴스로 인바운드 처리」는 참이라 오답 보기로 둘 수 없다(정답이 둘).

  group('R4 NAT 인스턴스는 아웃바운드 전용이 아니다', () {
    final outboundOnly = RegExp(r'NAT 인스턴스[^\n]{0,80}아웃바운드 전용');

    test('대조군', () {
      expect(outboundOnly.hasMatch('NAT 인스턴스도 NAT 게이트웨이와 동일하게 아웃바운드 전용 역할'), isTrue);
      expect(outboundOnly.hasMatch('| **NAT 인스턴스** | EC2로 직접 구현 (레거시) | 아웃바운드 전용 |'),
          isTrue);
      expect(outboundOnly.hasMatch('NAT 게이트웨이는 아웃바운드 전용입니다'), isFalse);
    });

    test('SAA 전수: 「NAT 인스턴스 = 아웃바운드 전용」 단정이 0건이다', () {
      expect(sweep(outboundOnly.hasMatch), isEmpty);
    });

    test('saa-t1-3-q8: 오답 보기가 명백히 거짓이고 근거가 공식 비교표다', () {
      final q = question('saa-t1-3-q8');
      // 참인 서술(NAT 인스턴스 → 포트 포워딩 가능)을 오답 보기로 두지 않는다.
      expect(options(q).any((o) => o.contains('NAT 인스턴스로 교체')), isFalse);
      expect(options(q)[1].contains('보안 그룹'), isTrue);
      final w1 = wrongs(q)['1']!;
      expect(w1.contains('보안 그룹을 연결할 수 없'), isTrue);
      expect(w1.contains('포트 포워딩'), isTrue);
      expect(hasSource(q, 'vpc-nat-comparison'), isTrue);
      expect(hasSource(q, 'vpc-nat-gateway'), isTrue);
      expect(docs['saa-t1-3']!.contains('포트 포워딩·배스천'), isTrue);
    });
  });

  // ═══════════════════════ 🔴 R5 — Geoproximity (학습문서) ═══════════════════════
  //
  // 공식(routing-policy): "You can use geoproximity routing to create records in a
  // private hosted zone." / (routing-policy-geoproximity) "The maps are available only
  // with Traffic Flow." — Traffic Flow 전용은 **지도**뿐이다. 문항은 2026-10-28 에
  // 고쳐졌는데 학습문서 5줄이 남아 정반대를 가르쳤다(문항 가드는 .md 를 보지 않는다).

  group('R5 Geoproximity 는 Traffic Flow 전용이 아니다', () {
    final tfOnly = RegExp(r'Traffic Flow(\*\*)?\s*(기능)?에서만\s*(사용|bias)'
        r'|Traffic Flow\s*필요|Traffic Flow 없이는');

    test('대조군: 옛 다섯 줄의 어형을 잡고 정정문(지도만 전용)은 통과시킨다', () {
      expect(tfOnly.hasMatch('트래픽을 특정 리전으로 점진 이동 (Traffic Flow 필요)'), isTrue);
      expect(tfOnly.hasMatch('Geoproximity는 **Route 53 Traffic Flow** 기능에서만 사용할 수 있습니다'),
          isTrue);
      expect(tfOnly.hasMatch('Traffic Flow 없이는 설정할 수 없습니다'), isTrue);
      expect(tfOnly.hasMatch('Geoproximity는 Traffic Flow 기능에서만 bias 값과 함께 사용 가능하다'), isTrue);
      expect(tfOnly.hasMatch('Traffic Flow에서만 사용 가능하다'), isTrue);
      expect(tfOnly.hasMatch('Traffic Flow에서만 쓸 수 있는 것은 편향 범위를 그려 보여 주는 지도입니다'),
          isFalse);
      expect(tfOnly.hasMatch('Traffic Flow 전용이 아니고'), isFalse);
    });

    test('SAA 전수(학습문서 포함): 「Traffic Flow 에서만」 단정이 0건이다', () {
      expect(sweep(tfOnly.hasMatch), isEmpty);
    });

    test('saa-t3-7.md 가 문항과 같은 사실을 적는다', () {
      final d = docs['saa-t3-7']!;
      expect(d.contains('Traffic Flow 전용이 아니'), isTrue);
      expect(d.contains('프라이빗 호스팅 영역에서도'), isTrue);
      expect(RegExp(r'Traffic Flow에서만 쓸 수 있는 것은 편향 범위').allMatches(d).length,
          greaterThanOrEqualTo(2));
    });
  });

  // ═══════════════════════ 🟡 Y1 · Y2 — Control Tower ═══════════════════════

  group('Y1 Control Tower 예방 제어의 구현 수단은 SCP 하나가 아니다', () {
    // 공식(control-behavior): "The preventive controls are implemented using Service
    // Control Policies (SCPs), Resource Control Policies (RCPs), and declarative policies".
    bool scpOnly(String s) =>
        s.contains('예방적') && s.contains('SCP') && !s.contains('RCP');

    test('대조군', () {
      expect(scpOnly('예방적 제어는 SCP, 탐지적 제어는 AWS Config 규칙으로 구현됩니다'), isTrue);
      expect(scpOnly('예방적 가드레일만 SCP로 구현됩니다'), isTrue);
      expect(scpOnly('예방적 제어는 SCP·RCP·선언적 정책으로 구현'), isFalse);
    });

    test('SAA 전수: 예방 제어를 SCP 로만 적는 자리가 0건이다(문항은 문항 단위)', () {
      expect(sweepByQuestion(scpOnly), isEmpty);
    });

    test('saa-t1-2-q9: 세 구현 수단과 공식 페이지', () {
      final q = question('saa-t1-2-q9');
      expect((q['explanation'] as String).contains('선언적 정책'), isTrue);
      expect(hasSource(q, 'controlreference/control-behavior'), isTrue);
    });
  });

  group('Y2 감사 계정의 교차 계정 역할은 읽기 전용만이 아니다', () {
    // 공식(special-accounts): "auditor (read-only) and administrator (full-access)
    // cross-account roles to all accounts in the landing zone".
    bool readOnlyOnly(String s) =>
        s.contains('감사') && RegExp(r'읽기 전용(으로)? 접근').hasMatch(s) && !s.contains('관리자');

    test('대조군', () {
      expect(readOnlyOnly('감사 계정은 보안팀 전용으로 전 계정에 읽기 전용 접근 권한을 가집니다'), isTrue);
      expect(readOnlyOnly('감사 계정 … 교차 계정 역할(읽기 전용 감사 역할과 전체 권한 관리자 역할)'), isFalse);
    });

    test('SAA 전수: 감사 계정을 「읽기 전용 접근」으로만 적는 자리가 0건이다', () {
      expect(sweep(readOnlyOnly), isEmpty);
    });

    test('saa-t1-2-q11: 두 역할과 현행 계정 이름', () {
      final e = question('saa-t1-2-q11')['explanation'] as String;
      expect(e.contains('관리자 역할'), isTrue);
      expect(e.contains('Config aggregator'), isTrue);
    });
  });

  // ═══════════════════════ 🟡 Y3 — Macie ═══════════════════════

  group('Y3 Macie 는 머신러닝과 패턴 매칭을 함께 쓴다', () {
    // 공식(what-is-macie): "discovers sensitive data by using machine learning and
    // pattern matching".
    final mlOnly = RegExp(r'머신러닝(으로|을 사용해)|규칙 기반이 아닌 머신러닝');
    bool macieMlOnly(String s) =>
        s.contains('Macie') && mlOnly.hasMatch(s) && !s.contains('패턴 매칭');

    test('대조군', () {
      expect(macieMlOnly('Amazon Macie — 머신러닝으로 S3를 스캔해 PII를 탐지'), isTrue);
      expect(macieMlOnly('왜 Macie는 규칙 기반이 아닌 머신러닝으로 민감 데이터를 탐지할까요?'), isTrue);
      expect(macieMlOnly('Amazon Macie — 머신러닝과 패턴 매칭으로 S3를 스캔해'), isFalse);
      expect(macieMlOnly('Cost Anomaly Detection은 비용 급등을 머신러닝으로 자동 감지'), isFalse);
    });

    test('SAA 전수: Macie 를 「머신러닝으로」만 적는 자리가 0건이다', () {
      expect(sweep(macieMlOnly), isEmpty);
    });

    test('정본 표기가 문항과 학습문서 양쪽에 있다', () {
      expect(options(question('saa-t1-5-q9'))[1].contains('머신러닝과 패턴 매칭'), isTrue);
      expect((question('saa-t1-5-q10')['explanation'] as String).contains('머신러닝과 패턴 매칭'),
          isTrue);
      expect('머신러닝과 패턴 매칭'.allMatches(docs['saa-t1-5']!).length, greaterThanOrEqualTo(3));
    });
  });

  // ═══════════════════════ 🟡 Y5 · Y6 — RDS Multi-AZ ═══════════════════════
  //
  // 공식: Multi-AZ 는 배포 유형이 둘이다. DB 인스턴스 배포는 동기 스탠바이
  // ("can have increased write and commit latency compared to a Single-AZ deployment"),
  // DB 클러스터 배포는 "semisynchronous" 이고 리더가 읽기를 받는다.

  group('Y5·Y6 Multi-AZ 동기 복제 서술은 배포 유형을 한정한다', () {
    final sync = RegExp(r'(?<![비반])동기(?!화)');
    final qualifier = RegExp(r'인스턴스 배포|DB 클러스터|반동기');
    /// 한 문장 단위(학습문서 줄 · 문항 필드)가 Multi-AZ 를 두고 동기 단정을 하는가.
    bool claims(String s) =>
        s.contains('Multi-AZ') && (sync.hasMatch(s) || s.contains('스탠바이는 장애조치용'));
    bool unqualified(String s) => claims(s) && !qualifier.hasMatch(s);

    /// 문항은 **단정은 필드 단위, 한정어는 문항 단위**로 본다 — 지문이 배포 유형을
    /// 한정했으면 보기는 그 범위 안의 서술이다. 반대로 단정을 문항 단위로 보면
    /// 「Aurora 스토리지의 동기 복제」와 다른 보기의 「Multi-AZ」가 한 문항에 있다는
    /// 이유만으로 걸린다(이 가드가 실제로 그렇게 `saa-t3-5-q5` 를 걸었다).
    bool unqualifiedQuestion(Map<String, dynamic> q) =>
        fields(q).any(claims) && !qualifier.hasMatch(allText(q));

    test('대조군: 비동기·동기화를 삼키지 않고, 한정된 서술은 통과시킨다', () {
      expect(unqualified('RDS Multi-AZ는 같은 리전 내 동기 복제를 사용해'), isTrue);
      expect(unqualified('Multi-AZ RDS의 스탠바이는 장애조치용이고'), isTrue);
      expect(unqualified('Multi-AZ 대신 읽기 복제본은 비동기 복제라 지연이 있다'), isFalse);
      expect(unqualified('Aurora Multi-AZ … 애플리케이션이 양방향 쓰기를 동기화한다'), isFalse);
      expect(unqualified('RDS Multi-AZ DB 인스턴스 배포는 동기 스탠바이를 유지'), isFalse);
    });

    test('대조군: 다른 사실(Aurora 스토리지의 동기 복제)을 Multi-AZ 단정으로 걸지 않는다', () {
      // 보기 하나가 Multi-AZ 를 말하고 출처 제목이 Aurora 스토리지의 동기 복제를 말한다.
      final q5 = question('saa-t3-5-q5');
      expect(allText(q5).contains('Multi-AZ'), isTrue);
      expect(sync.hasMatch(allText(q5)), isTrue);
      expect(fields(q5).any(claims), isFalse);
      // 반대로 지문이 한정한 문항은 보기가 한정어 없이 「동기」를 말해도 통과한다.
      final q11 = question('saa-t2-5-q11');
      expect(options(q11).any(unqualified), isTrue);
      expect(unqualifiedQuestion(q11), isFalse);
    });

    test('SAA 전수: 한정 없는 Multi-AZ 동기 단정이 0건이다', () {
      expect(
          <String>[
            for (final l in mdLines())
              if (unqualified(l.line)) '${l.id}.md:${l.no}',
            for (final q in questions)
              if (unqualifiedQuestion(q)) '${q['id']}',
          ],
          isEmpty);
    });

    test('「쓰기 지연이 체감되지 않는다」가 사라지고 공식 서술이 들어왔다', () {
      expect(sweep((s) => s.contains('체감되지')), isEmpty);
      final q = question('saa-t2-5-q11');
      expect((q['explanation'] as String).contains('쓰기·커밋 지연이 늘 수 있습니다'), isTrue);
      expect((q['explanation'] as String).contains('반동기'), isTrue);
      expect(hasSource(q, 'Concepts.MultiAZSingleStandby'), isTrue);
      expect(docs['saa-t2-5']!.contains('쓰기·커밋 지연이 늘 수 있습니다'), isTrue);
    });
  });

  // ═══════════════════════ 🟡 Y7 — AWS Batch ═══════════════════════

  group('Y7 AWS Batch 에 「실행 시간 제한이 없다」고 단정하지 않는다', () {
    // 공식(job_timeouts): "Jobs that run on Fargate resources can't expect to run for
    // more than 14 days."
    bool batchNoLimit(String s) =>
        s.contains('Batch') && RegExp(r'실행 시간 제한[이 ]*없').hasMatch(s);

    test('대조군: Batch 서술만 잡고 Fargate(ECS) 서술은 대상이 아니다', () {
      expect(batchNoLimit('AWS Batch — 실행 시간 제한 없이 Job 제출량에 따라'), isTrue);
      expect(batchNoLimit('AWS Batch는 … 자동 프로비저닝·종료하며 실행 시간 제한이 없습니다'), isTrue);
      expect(batchNoLimit('Fargate는 실행 시간 제한이 없고 EFS 마운트로 상태를 유지'), isFalse);
      expect(batchNoLimit('AWS Batch — Lambda의 15분 같은 고정 상한 없이'), isFalse);
    });

    test('SAA 전수: Batch 「실행 시간 제한 없음」 단정이 0건이다', () {
      expect(sweep(batchNoLimit), isEmpty);
    });

    test('Fargate 14일 한도를 문항과 학습문서가 적는다', () {
      final q = question('saa-t3-4-q8');
      expect((q['explanation'] as String).contains('14일'), isTrue);
      expect(hasSource(q, 'batch/latest/userguide/job_timeouts'), isTrue);
      expect('14일 한도'.allMatches(docs['saa-t3-4']!).length, greaterThanOrEqualTo(2));
    });
  });

  // ═══════════════════════ 🟡 Y8 — RDS Magnetic ═══════════════════════

  group('Y8 RDS Magnetic 스토리지는 사용 중단됐다', () {
    // 공식(CHAP_Storage): "Amazon RDS has deprecated magnetic storage. You can no longer
    // create new DB instances using magnetic storage, and Amazon RDS has migrated
    // existing magnetic storage volumes to gp3."
    test('saa-t3-5-q11: 「이전 세대」·근거 없는 100 IOPS 가 사라지고 사용 중단을 적는다', () {
      final q = question('saa-t3-5-q11');
      final w0 = wrongs(q)['0']!;
      expect(w0.contains('이전 세대'), isFalse);
      expect(w0.contains('100 IOPS'), isFalse);
      expect(w0.contains('사용 중단'), isTrue);
      expect(w0.contains('gp3로 이전'), isTrue);
      // 2026-10-27 §C 판정 유지.
      expect(allText(q).contains('gp3는 버스트를 쓰지 않아'), isTrue);
      expect(hasSource(q, 'CHAP_Storage'), isTrue);
    });

    test('SAA 전수: RDS 문맥에서 Magnetic 을 「이전 세대」로 적는 자리가 0건이다', () {
      // EBS 의 이전 세대 Magnetic(`standard`)은 다른 사실이고 옳다 — RDS 문맥만 본다.
      bool rdsMagneticLegacy(String s) =>
          s.contains('Magnetic') && s.contains('RDS') && s.contains('이전 세대');
      expect(sweepByQuestion(rdsMagneticLegacy), isEmpty);
      expect(docs['saa-t3-5']!.contains('사용 중단됨'), isTrue);
    });
  });

  // ═══════════════════════ 🟡 Y9 · Y10 — NAT 게이트웨이 ═══════════════════════

  group('Y9·Y10 NAT 게이트웨이 서술의 두 과잉 단정', () {
    // 공식(gateway-endpoints): "While traffic to Amazon S3 or DynamoDB traverses the
    // internet gateway, it does not leave the AWS network".
    // 공식(vpc-nat-gateway): "You can't associate an Elastic IP address with a private
    // NAT gateway."
    final viaInternet = RegExp(r'NAT[^\n]{0,40}인터넷을 경유');

    test('SAA 전수: 「NAT 는 인터넷을 경유」·「Elastic IP 가 반드시」가 0건이다', () {
      expect(viaInternet.hasMatch('NAT 게이트웨이는 비용이 발생하고 인터넷을 경유합니다'), isTrue);
      expect(sweep(viaInternet.hasMatch), isEmpty);
      expect(sweep((s) => s.contains('Elastic IP가 반드시')), isEmpty);
    });

    test('정정한 두 오답 근거가 공식 문장을 담는다', () {
      expect(wrongs(question('saa-t3-8-q11'))['3']!.contains('AWS 네트워크를 벗어나지는 않습니다'),
          isTrue);
      final q7 = question('saa-t1-3-q7');
      expect(wrongs(q7)['2']!.contains('프라이빗 NAT 게이트웨이에는 Elastic IP를 연결할 수 없습니다'),
          isTrue);
      expect(hasSource(q7, 'vpc/latest/userguide/vpc-nat-gateway'), isTrue);
    });
  });

  // ═══════════════════════ 🟡 Y11 — Elastic Beanstalk ═══════════════════════

  group('Y11 참인 보기를 오답으로 두지 않는다 — Elastic Beanstalk', () {
    test('saa-t2-3-q15: 보기 [3] 이 거짓 서술이고 오답 근거가 참·거짓을 말한다', () {
      final q = question('saa-t2-3-q15');
      expect(options(q)[3].contains('자동 스케일링과 로드밸런싱을 모두 내장'), isFalse);
      expect(options(q)[3].contains('자동 조정은 제공하지 않는다'), isTrue);
      final w3 = wrongs(q)['3']!;
      expect(w3.contains('질문의 핵심은'), isFalse, reason: '회피형 반박');
      expect(w3.contains('틀렸습니다'), isTrue);
      expect(hasSource(q, 'using-features.managing.as'), isTrue);
    });
  });

  // ═══════════════════════ 🟡 Y12 — HA / 내결함성 ═══════════════════════

  group('Y12 내결함성을 「완전 무중단 보장」으로 적지 않는다', () {
    // 공식(가용성과 그 너머 백서): "Fault tolerance is the ability to withstand subsystem
    // failure and maintain availability … another picks up its work, typically almost
    // seamlessly."
    test('SAA 전수: 「완전 무중단」이 0건이다', () {
      expect(sweep((s) => s.contains('완전 무중단')), isEmpty);
    });

    test('saa-t2-4-q1: 공식 서술에 맞춘 문구와 출처', () {
      final q = question('saa-t2-4-q1');
      expect((q['explanation'] as String).contains('거의 끊김 없이'), isTrue);
      expect(options(q)[1].contains('중단 없이 계속 동작하는 것을 목표'), isTrue);
      expect(hasSource(q, 'fault-tolerance-and-fault-isolation'), isTrue);
    });
  });

  // ═══════════════════════ 🟡 Y13 — Aurora serverless ═══════════════════════

  group('Y13 Aurora serverless 최솟값은 「기본 0.5 ACU」가 아니다', () {
    // 공식(setting-capacity): "It's tempting to always choose 0.5 for the minimum …
    // You can also enable automatic pause behavior by specifying a minimum capacity of
    // 0 ACUs".
    final defaultHalf = RegExp(r'기본 0\.5 ?ACU|최솟값\(0\.5 ACU\)');

    test('SAA 전수: 0.5 ACU 를 기본값·고정 최솟값으로 적는 자리가 0건이다', () {
      expect(defaultHalf.hasMatch('설정된 최솟값(기본 0.5 ACU) ACU만 과금'), isTrue);
      expect(defaultHalf.hasMatch('활성 상태의 최소 용량은 0.5 ACU이고'), isFalse);
      expect(sweep(defaultHalf.hasMatch), isEmpty);
    });

    test('saa-t4-3-q8: 0 ACU 자동 일시 정지를 함께 적는다', () {
      final q = question('saa-t4-3-q8');
      expect((q['explanation'] as String).contains('0 ACU'), isTrue);
      expect(hasSource(q, 'aurora-serverless-v2.setting-capacity'), isTrue);
    });
  });

  // ═══════════════════════ 🟡 Y14 — Rekognition · Flink ═══════════════════════

  group('Y14 닫힌 기능의 상태와 Flink 지원 언어', () {
    // 공식(rekognition streaming-video): "Streaming Video and Bulk Image Analysis is no
    // longer available to new customers. … does not impact the availability of other
    // Amazon Rekognition features."
    // 공식(managed-flink what-is): "you can use Java, Scala, Python, or SQL".
    test('SAA 전수: Flink 언어에서 Python 을 빠뜨린 「Java·Scala·SQL」이 0건이다', () {
      expect(sweep((s) => s.contains('Java·Scala·SQL')), isEmpty);
      expect(wrongs(question('saa-t3-9-q15'))['3']!.contains('Java·Scala·Python·SQL'), isTrue);
    });

    test('Rekognition 실시간·스트리밍 영상 분석을 가르치는 자리는 상태를 함께 적는다', () {
      final streaming = RegExp(r'(실시간|스트리밍) 영상 분석');
      final missing = <String>[
        for (final l in mdLines())
          if (l.line.contains('Rekognition') &&
              streaming.hasMatch(l.line) &&
              !l.line.contains('신규 고객'))
            '${l.id}.md:${l.no}',
        for (final q in questions)
          if (teaching(q).contains('Rekognition') &&
              streaming.hasMatch(teaching(q)) &&
              !(q['explanation'] as String).contains('신규 고객'))
            '${q['id']}',
      ];
      expect(missing, isEmpty);
      // 비공허: 그 자리가 실제로 있다.
      expect(streaming.hasMatch(teaching(question('saa-t3-9-q15'))), isTrue);
      expect(hasSource(question('saa-t3-9-q15'), 'rekognition/latest/dg/streaming-video'), isTrue);
    });
  });

  // ═══════════════════════ 🟡 Y15 — 인터페이스 엔드포인트 시간 요금 ═══════════════════════

  group('Y15 인터페이스 엔드포인트 시간 요금은 「AZ별」로 통일한다', () {
    // 공식(privatelink/pricing): "billed for each hour that your VPC endpoint remains
    // provisioned in each Availability Zone". 같은 페이지 예시는 "each endpoint ENI" 라고도
    // 적어 표현이 둘이다 — 레포는 2026-10-19 에 「엔드포인트·AZ별」을 골랐고(md 가드),
    // 「ENI 단위가 아니다」는 부정도 단정하지 않는다.
    final eniFee = RegExp(r'ENI 요금|ENI 유지 비용|ENI 단위가 아니라');

    test('SAA 전수: 「ENI 요금」·「ENI 단위가 아니라」가 0건이다', () {
      expect(eniFee.hasMatch(r'$0.01/GB 데이터 처리 요금과 시간당 ENI 요금'), isTrue);
      expect(eniFee.hasMatch('VPC·서브넷·ENI 단위로 활성화할 수 있습니다'), isFalse);
      expect(sweep(eniFee.hasMatch), isEmpty);
    });

    test('saa-t4-4-q6·q7: AZ별 시간 요금으로 적는다', () {
      expect(options(question('saa-t4-4-q6'))[3].contains('AZ별 시간 요금'), isTrue);
      expect(wrongs(question('saa-t4-4-q7'))['3']!.contains('AZ별 시간 요금'), isTrue);
    });
  });

  // ═══════════════════════ 🟡 Y16 · Y17 · 🟢 — 학습문서 잔존 ═══════════════════════

  group('Y16·Y17·G5·G11 학습문서에만 남아 있던 서술', () {
    test('HTTP API 「지연도 낮다」(근거 없음)가 학습문서에서도 사라졌다', () {
      final hits = <String>[
        for (final l in mdLines())
          if (l.line.contains('HTTP API') && RegExp(r'지연[도이] 낮').hasMatch(l.line))
            '${l.id}.md:${l.no}',
      ];
      expect(hits, isEmpty);
    });

    test('「IP 차단은 반드시 NACL」이 학습문서에서도 사라졌다(WAF IP 집합도 가능)', () {
      expect(sweep(RegExp(r'반드시 \*{0,2}NACL').hasMatch), isEmpty);
      expect(docs['saa-t1-3']!.contains('WAF의 IP 집합'), isTrue);
    });

    test('신규 고객에게 닫힌 서비스·기능은 그 줄에 상태를 적는다', () {
      bool lacksStatus(String line, RegExp trigger, String status) =>
          trigger.hasMatch(line) && !line.contains(status);
      final rules = <({RegExp trigger, String status})>[
        (trigger: RegExp(r'^\| \*\*readiness check\*\*'), status: '신규 고객'),
        (trigger: RegExp(r'App Runner'), status: '신규 고객'),
        (trigger: RegExp(r'AppRegistry'), status: '신규 고객'),
        (trigger: RegExp(r'WAF Classic'), status: '지원 종료'),
      ];
      final missing = <String>[
        for (final l in mdLines())
          for (final r in rules)
            if (lacksStatus(l.line, r.trigger, r.status)) '${l.id}.md:${l.no}',
      ];
      expect(missing, isEmpty);
      // 비공허: 네 규칙이 각각 적어도 한 줄을 본다.
      for (final r in rules) {
        expect(mdLines().any((l) => r.trigger.hasMatch(l.line)), isTrue,
            reason: '트리거가 아무 줄도 못 찾는다: ${r.trigger.pattern}');
      }
      expect((question('saa-t1-4-q4')['explanation'] as String).contains('신규 고객'), isTrue);
    });

    test('표현이 거친 네 자리(Memcached·Lambda 15분·DX 암호화·IA 30일)', () {
      expect(sweep(RegExp(r'(?<!노드 기반 )Memcached는 영속성과 (복제|HA)').hasMatch), isEmpty);
      expect(sweep((s) => s.contains('Lambda의 최대 실행 시간은 15분')), isEmpty);
      expect(sweep(RegExp(r'VPN over Direct Connect 패턴을 (사용|적용)해야').hasMatch), isEmpty);
      expect(sweep((s) => s.contains('30일 이전에 Standard-IA')), isEmpty);
      expect(sweep((s) => s.contains('Day 30 전환과 일치')), isEmpty);
      expect(docs['saa-t3-8']!.contains('MACsec을 사용합니다'), isTrue);
    });
  });

  // ═══════════════════════ 범위 확장 — 출처 대조에서 새로 찾은 두 자리 ═══════════════════════

  group('범위 확장: 스팟 최대 절전에는 2분 경고가 없다', () {
    // 공식(spot-instance-termination-notices): "If you specify hibernation as the
    // interruption behavior, you receive an interruption notice, but you do not receive
    // a two-minute warning because the hibernation process begins immediately."
    test('saa-t3-3-q8: 정답 보기가 2분 경고를 종료·중지로 한정한다', () {
      final q = question('saa-t3-3-q8');
      expect(options(q)[1].contains('종료·중지는 2분 전 경고'), isTrue);
      expect(options(q)[1].contains('최대 절전은 2분 유예 없이 즉시'), isTrue);
      expect((q['explanation'] as String).contains('2분 경고가 없습니다'), isTrue);
      expect(hasSource(q, 'spot-instance-termination-notices'), isTrue);
    });

    test('SAA 전수: 「2분 경고 뒤 세 동작 모두 실행」으로 뭉뚱그린 문장이 0건이다', () {
      expect(sweep((s) => s.contains('2분 전에 경고가 제공되며, 지정된 중단 동작')), isEmpty);
      expect(docs['saa-t3-3']!.contains('2분 경고가 없음'), isTrue);
      expect(docs['saa-t4-2']!.contains('2분 알림이 없음'), isTrue);
    });
  });

  group('범위 확장: 비용 최적화 기둥의 설명을 공식 문장에 맞춘다', () {
    // 공식(framework/cost-optimization): "A cost-optimized workload delivers business
    // outcomes at the lowest appropriate price point while meeting its functional
    // requirements and your performance, reliability, security, and sustainability
    // standards."
    test('saa-t4-5-q14', () {
      final q = question('saa-t4-5-q14');
      final e = q['explanation'] as String;
      expect(e.contains("공식 정의는 '기능 요구사항을 충족하면서 최저 가격으로"), isFalse);
      expect(e.contains('가장 낮은 적정 가격'), isTrue);
      expect(hasSource(q, 'wellarchitected/latest/framework/cost-optimization'), isTrue);
      // 2026-10-28 판정 유지(saa_question_facts_test).
      expect(hasSource(q, 'cost-optimization-pillar'), isTrue);
      expect(allText(q).contains('6개 기둥'), isTrue);
    });
  });

  // ═══════════════════════ 🟢 G7 · G12 ═══════════════════════

  group('G7·G12 표현 정밀화', () {
    test('인스턴스 접미사 n 을 「네트워크 강화」로만 적지 않는다(공식: Network and EBS optimized)', () {
      expect(sweep(RegExp(r'네트워크 강화[^\n]{0,14}`n`').hasMatch), isEmpty);
      expect((question('saa-t3-3-q2')['explanation'] as String).contains('블록 스토리지 최적화는 `b`'),
          isTrue);
    });

    test('Compute Optimizer 룩백은 「14일 이상」이 아니라 기본 14일이다', () {
      expect(
          <String>[
            for (final q in questions)
              if (allText(q).contains('14일 이상을 수집')) '${q['id']}',
          ],
          isEmpty);
      expect((question('saa-t4-5-q7')['explanation'] as String).contains('최근 14일'), isTrue);
    });
  });

  // ═══════════════════════ 🟡 Y18 · Y19 — 출처 ═══════════════════════
  //
  // 「URL 은 200 인데 그 페이지에 그 사실이 없다」를 닫는다. 아래 79문항은 문항이 단정하는
  // 사실을 담은 페이지를 **더했다**(2026-11-17 전부 `curl -sL` 로 200·리다이렉트 0 과
  // 본문의 해당 문장을 확인). 옛 출처는 기존 가드가 요구하거나 다른 축을 받치는 것이
  // 많아 대부분 지우지 않았다.

  group('Y18 사실을 담은 페이지를 출처로 싣는다', () {
    const d = 'docs.aws.amazon.com/';
    const added = <String, List<String>>{
      'saa-t1-1-q2': ['${d}IAM/latest/UserGuide/id_roles_use_switch-role-ec2.html'],
      'saa-t1-1-q3': ['${d}lambda/latest/dg/lambda-intro-execution-role.html'],
      'saa-t1-1-q15': ['${d}IAM/latest/UserGuide/id_root-enable-root-access.html'],
      'saa-t1-2-q1': ['${d}organizations/latest/userguide/orgs_manage_policies_scps_evaluation.html'],
      'saa-t1-2-q4': ['${d}organizations/latest/userguide/orgs_manage_policies_scps_evaluation.html'],
      'saa-t1-2-q9': ['${d}controltower/latest/controlreference/control-behavior.html'],
      'saa-t1-2-q15': [
        '${d}whitepapers/latest/organizing-your-aws-environment/benefits-of-using-multiple-aws-accounts.html'
      ],
      'saa-t1-3-q4': ['${d}vpc/latest/userguide/custom-network-acl.html'],
      'saa-t1-3-q7': ['${d}vpc/latest/userguide/vpc-nat-gateway.html'],
      'saa-t1-3-q8': ['${d}vpc/latest/userguide/vpc-nat-comparison.html'],
      'saa-t1-3-q9': ['${d}vpc/latest/privatelink/gateway-endpoints.html'],
      'saa-t1-3-q10': ['${d}vpc/latest/privatelink/gateway-endpoints.html'],
      'saa-t1-3-q13': ['${d}vpc/latest/userguide/flow-logs.html'],
      'saa-t1-4-q1': ['${d}waf/latest/developerguide/aws-managed-rule-groups-baseline.html'],
      'saa-t1-4-q3': [
        'aws.amazon.com/shield/features/',
        '${d}waf/latest/developerguide/ddos-request-service-credit.html'
      ],
      'saa-t1-4-q6': ['${d}waf/latest/developerguide/web-acl-processing-order.html'],
      'saa-t1-4-q11': ['${d}systems-manager/latest/userguide/parameter-store-advanced-parameters.html'],
      'saa-t1-4-q12': ['${d}AmazonCloudFront/latest/DeveloperGuide/distribution-web-awswaf.html'],
      'saa-t2-1-q4': ['${d}AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-dead-letter-queues.html'],
      'saa-t2-1-q7': [
        '${d}sns/latest/dg/sns-message-delivery-retries.html',
        '${d}sns/latest/dg/sns-dead-letter-queues.html'
      ],
      'saa-t2-1-q9': ['${d}eventbridge/latest/userguide/eb-event-patterns.html'],
      'saa-t2-1-q10': ['${d}eventbridge/latest/userguide/eb-saas.html'],
      'saa-t2-2-q2': ['${d}lambda/latest/dg/provisioned-concurrency.html'],
      'saa-t2-2-q6': ['${d}lambda/latest/dg/services-rds.html'],
      'saa-t2-2-q9': ['${d}apigateway/latest/developerguide/apigateway-use-lambda-authorizer.html'],
      'saa-t2-2-q11': ['${d}eks/latest/userguide/what-is-eks.html'],
      'saa-t2-2-q12': ['${d}AmazonECS/latest/developerguide/fargate-tasks-services.html'],
      'saa-t2-2-q15': ['${d}lambda/latest/dg/configuration-vpc-internet.html'],
      'saa-t2-3-q5': [
        '${d}elasticloadbalancing/latest/userguide/how-elastic-load-balancing-works.html',
        '${d}elasticloadbalancing/latest/network/edit-target-group-attributes.html'
      ],
      'saa-t2-3-q10': ['${d}autoscaling/ec2/userguide/ec2-auto-scaling-lifecycle.html'],
      'saa-t2-3-q11': ['${d}autoscaling/ec2/userguide/ec2-auto-scaling-lifecycle.html'],
      'saa-t2-3-q12': ['${d}autoscaling/ec2/userguide/ec2-auto-scaling-health-checks.html'],
      'saa-t2-3-q14': ['${d}autoscaling/ec2/userguide/launch-templates.html'],
      'saa-t2-3-q15': ['${d}elasticbeanstalk/latest/dg/using-features.managing.as.html'],
      'saa-t2-4-q1': [
        '${d}whitepapers/latest/availability-and-beyond-improving-resilience/fault-tolerance-and-fault-isolation.html'
      ],
      'saa-t2-4-q2': [
        '${d}vpc/latest/userguide/nat-gateway-basics.html',
        '${d}AmazonRDS/latest/UserGuide/Concepts.MultiAZSingleStandby.html'
      ],
      'saa-t2-4-q5': ['${d}AmazonRDS/latest/UserGuide/Concepts.MultiAZ.Failover.html'],
      'saa-t2-4-q8': ['${d}Route53/latest/DeveloperGuide/dns-failover-types.html'],
      'saa-t2-4-q9': [
        '${d}wellarchitected/latest/reliability-pillar/rel_withstand_component_failures_static_stability.html'
      ],
      'saa-t2-4-q11': ['${d}vpc/latest/userguide/nat-gateway-basics.html'],
      'saa-t2-4-q12': [
        '${d}wellarchitected/latest/reliability-pillar/rel_fault_isolation_multiaz_region_system.html'
      ],
      'saa-t2-4-q13': ['${d}Route53/latest/DeveloperGuide/dns-failover-types.html'],
      'saa-t2-4-q14': ['${d}AmazonRDS/latest/UserGuide/Concepts.MultiAZ.Failover.html'],
      'saa-t2-5-q11': ['${d}AmazonRDS/latest/UserGuide/Concepts.MultiAZSingleStandby.html'],
      'saa-t3-1-q6': ['${d}AmazonS3/latest/userguide/lifecycle-transition-general-considerations.html'],
      'saa-t3-2-q2': ['${d}ebs/latest/userguide/general-purpose.html'],
      'saa-t3-2-q7': ['${d}ebs/latest/userguide/ebs-snapshots.html'],
      'saa-t3-2-q14': ['${d}ebs/latest/userguide/ebs-snapshots.html'],
      'saa-t3-3-q1': ['${d}ec2/latest/instancetypes/instance-type-names.html'],
      'saa-t3-3-q2': ['${d}ec2/latest/instancetypes/instance-type-names.html'],
      'saa-t3-3-q8': ['${d}AWSEC2/latest/UserGuide/spot-instance-termination-notices.html'],
      'saa-t3-3-q9': ['aws.amazon.com/ec2/spot/'],
      'saa-t3-3-q10': ['${d}AWSEC2/latest/UserGuide/placement-strategies.html'],
      'saa-t3-3-q13': ['${d}AWSEC2/latest/UserGuide/placement-strategies.html'],
      'saa-t3-3-q14': ['${d}AWSEC2/latest/UserGuide/efa.html'],
      'saa-t3-4-q7': ['${d}batch/latest/userguide/batch_components.html'],
      'saa-t3-4-q8': ['${d}batch/latest/userguide/job_timeouts.html'],
      'saa-t3-5-q5': [
        '${d}AmazonRDS/latest/AuroraUserGuide/Concepts.AuroraHighAvailability.html',
        '${d}AmazonRDS/latest/AuroraUserGuide/Aurora.Overview.StorageReliability.html'
      ],
      'saa-t3-6-q8': ['${d}amazondynamodb/latest/developerguide/DAX.consistency.html'],
      'saa-t3-6-q9': ['${d}amazondynamodb/latest/developerguide/V2globaltables_HowItWorks.html'],
      'saa-t3-7-q11': ['${d}global-accelerator/latest/dg/introduction-how-it-works.html'],
      'saa-t3-7-q12': ['${d}global-accelerator/latest/dg/introduction-how-it-works.html'],
      'saa-t3-8-q8': [
        '${d}wellarchitected/latest/reliability-pillar/rel_planning_network_topology_ha_conn_private_networks.html'
      ],
      'saa-t3-9-q7': ['${d}athena/latest/ug/columnar-storage.html'],
      'saa-t3-9-q9': ['${d}lake-formation/latest/dg/working-with-services.html'],
      'saa-t3-9-q15': ['${d}rekognition/latest/dg/streaming-video.html'],
      'saa-t4-1-q8': ['${d}AWSEC2/latest/UserGuide/ec2-instance-lifecycle.html'],
      'saa-t4-1-q9': ['${d}awssupport/latest/user/cost-optimization-checks.html'],
      'saa-t4-2-q1': ['${d}AWSEC2/latest/UserGuide/ec2-on-demand-instances.html'],
      'saa-t4-2-q8': ['aws.amazon.com/ec2/spot/'],
      'saa-t4-2-q11': ['${d}autoscaling/ec2/userguide/ec2-auto-scaling-scheduled-scaling.html'],
      'saa-t4-3-q6': [
        '${d}AmazonRDS/latest/UserGuide/USER_PIOPS.ModifyingExisting.html',
        '${d}AmazonRDS/latest/UserGuide/USER_PIOPS.Autoscaling.html'
      ],
      'saa-t4-3-q8': ['${d}AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2.setting-capacity.html'],
      'saa-t4-4-q8': ['${d}AmazonCloudFront/latest/DeveloperGuide/Introduction.html'],
      'saa-t4-4-q9': ['${d}AmazonCloudFront/latest/DeveloperGuide/cache-hit-ratio.html'],
      'saa-t4-5-q5': ['${d}awsaccountbilling/latest/aboutv2/cost-allocation-backfill.html'],
      'saa-t4-5-q7': ['${d}awssupport/latest/user/cost-optimization-checks.html'],
      'saa-t4-5-q12': ['${d}organizations/latest/userguide/orgs_manage_policies_tag-policies.html'],
      'saa-t4-5-q14': ['${d}wellarchitected/latest/framework/cost-optimization.html'],
    };

    test('79문항에 사실을 담은 출처가 실려 있다', () {
      expect(added, hasLength(79));
      final missing = <String>[
        for (final e in added.entries)
          for (final frag in e.value)
            if (!hasSource(question(e.key), frag)) '${e.key} ← $frag',
      ];
      expect(missing, isEmpty);
    });

    test('문항과 무관하던 출처 넷을 걷었다(지우기만 한 것이 아니라 정본을 달았다)', () {
      // VPC 소개 페이지는 NAT 배치·Flow Logs 발행 대상을 담지 않고, RI 개요는 예약된 조정을,
      // 태그 활성화 페이지는 태그 정책을 담지 않는다.
      expect(hasSource(question('saa-t1-3-q7'), 'what-is-amazon-vpc'), isFalse);
      expect(hasSource(question('saa-t1-3-q13'), 'what-is-amazon-vpc'), isFalse);
      expect(hasSource(question('saa-t4-2-q11'), 'ec2-reserved-instances'), isFalse);
      expect(hasSource(question('saa-t4-5-q12'), 'activating-tags'), isFalse);
    });

    test('출처 제목이 그 페이지에 없는 표현을 약속하지 않는다(saa-t3-5-q12)', () {
      final titles = sources(question('saa-t3-5-q12')).map((s) => s['title'] as String);
      expect(titles.any((t) => t.contains('되돌릴 수 없음')), isFalse);
    });
  });

  group('Y19 블로그를 「(공식)」 문서로 표시하지 않는다', () {
    bool blogAsOfficial(Map<String, dynamic> s) =>
        (s['url'] as String).contains('/blogs/') && (s['title'] as String).contains('(공식)');

    test('대조군', () {
      expect(
          blogAsOfficial(<String, dynamic>{
            'title': '데이터 전송 비용 개요 (공식)',
            'url': 'https://aws.amazon.com/blogs/architecture/x/',
          }),
          isTrue);
      expect(
          blogAsOfficial(<String, dynamic>{
            'title': '데이터 전송 비용 개요 (AWS 아키텍처 블로그)',
            'url': 'https://aws.amazon.com/blogs/architecture/x/',
          }),
          isFalse);
    });

    test('SAA 전수: 블로그 출처에 「(공식)」 라벨이 0건이다', () {
      expect(
          <String>[
            for (final q in questions)
              for (final s in sources(q))
                if (blogAsOfficial(s)) '${q['id']}',
          ],
          isEmpty);
    });
  });

  // ═══════════════════════ lastVerified ═══════════════════════

  group('본문을 고친 학습문서의 lastVerified', () {
    const touched = <String>[
      'saa-t1-2',
      'saa-t1-3',
      'saa-t1-4',
      'saa-t1-5',
      'saa-t2-2',
      'saa-t2-4',
      'saa-t2-5',
      'saa-t3-3',
      'saa-t3-4',
      'saa-t3-5',
      'saa-t3-6',
      'saa-t3-7',
      'saa-t3-8',
      'saa-t3-9',
      'saa-t4-1',
      'saa-t4-2',
      'saa-t4-3',
      'saa-t4-4',
      'saa-t4-5',
    ];

    test('19편이 2026-11-17 이상이다(하한 비교 — 뒤 배치가 올려도 깨지지 않는다)', () {
      for (final id in touched) {
        final stamp =
            RegExp(r'lastVerified: (\d{4}-\d{2}-\d{2})').firstMatch(docs[id]!)?.group(1);
        expect(stamp, isNotNull, reason: '$id lastVerified 항목이 없다');
        expect(stamp!.compareTo('2026-11-17') >= 0, isTrue,
            reason: '$id lastVerified 가 본문 수정일보다 이르다: $stamp');
      }
    });
  });
}
