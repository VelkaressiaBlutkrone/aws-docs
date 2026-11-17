import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 2026-11-17 전 콘텐츠 검증 2단계(보정) — DEA 분 가드.
///
/// 1단계 보고: `docs/audits/2026-11-17-full-verify/dea.md`
/// 반영 보고: `docs/audits/2026-11-17-full-verify/dea-phase2.md`
///
/// DEA 는 문항 256개가 전부 라이브이고, **학습문서 사실 가드가 레포에서 가장 얇다**
/// (`dea_questions_test` 는 구조·밀도 가드다). 그래서 이 파일은 문항만 보지 않고
/// **md 17편 + 문항 17파일을 같은 규칙으로** 센다(문항 가드는 `.md` 를 보지 않는다).
///
/// 설계 규율(레포가 비싸게 배운 것):
/// - **대조군을 먼저 둔다** — 0건 통과가 「파일을 못 읽어서」일 수 있다.
/// - 사실 단정은 **전수 문맥 규칙**이다(리터럴 하나는 어형 하나로 뚫린다).
/// - **옛 문구 0건 + 새 공식 사실 있음**을 쌍으로 둔다.
/// - ⚠️ **`verified` 상태를 단정하지 않는다**(사람의 flip 을 레드로 만들지 않는다).
///   대신 구조(보기 4개)와 **정답 인덱스 불변**을 단정한다.
/// - 오답 보기는 일부러 틀린 서술이므로 사실 규칙은 **가르치는 층**
///   (`skill`·지문·정답 보기·해설·오답 근거)만 본다. 명칭·출처 규칙은 문항 전체를 본다.
///
/// 공식 재측정(2026-11-17, `curl -sL` · 전부 `200 r=0`)에서 1단계와 달라진 판정 셋:
/// - **R1** 「EFO 샤드당 최대 20」은 날조가 아니었다 — DynamoDB 개발자 안내서
///   `streamsmain.html` 의 비교 표가 지금도 `up to 20 simultaneous consumers per
///   shard with enhanced fan-out` 으로 적는다. **공식 내부 어긋남**이고, 한도를
///   정의하는 KDS 전용 페이지 둘(`service-sizes-and-limits.html` 의 `for each data
///   stream` · `enhanced-consumers.html` 의 `20 consumers per stream`)을 정본으로 삼았다.
/// - **Y8** Performance Insights 종료 날짜를 적는 **공식 문서가 있다** —
///   `AmazonCloudWatch/latest/monitoring/Database-Insights.html`: `the end-of-life
///   date for Performance Insights was July 31, 2026`. 학습문서의 2026-06-30 은
///   `repost.aws` 에서 온 값이었다.
/// - **Y7** 「Redshift Serverless 는 128의 배수」는 공식 docs 에 없다(`repost.aws`
///   뿐) → 귀속해 남기지 않고 **걷었다**.
void main() {
  const dir = 'assets/content/dea';

  List<File> files(String suffix) => Directory(dir)
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith(suffix))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  String base(File f) => f.path.replaceAll(r'\', '/').split('/').last;

  List<String> linesOf(File f) => f
      .readAsStringSync()
      .split('\n')
      .map((l) => l.endsWith('\r') ? l.substring(0, l.length - 1) : l)
      .toList();

  List<Map<String, dynamic>> questionsOf(File f) =>
      ((json.decode(f.readAsStringSync()) as Map<String, dynamic>)['questions']
              as List)
          .cast<Map<String, dynamic>>();

  final mdFiles = files('.md');
  final qFiles = files('.questions.json');
  final allQuestions = <Map<String, dynamic>>[
    for (final f in qFiles) ...questionsOf(f),
  ];

  Map<String, dynamic> q(String id) => allQuestions
      .firstWhere((e) => e['id'] == id, orElse: () => fail('$id 없음'));

  String md(String taskId) => File('$dir/$taskId.md').readAsStringSync();

  /// 가르치는 층 — 오답 보기(일부러 틀린 서술)는 뺀다.
  List<String> teachFields(Map<String, dynamic> e) => <String>[
        e['skill'] as String? ?? '',
        e['stem'] as String? ?? '',
        (e['options'] as List).cast<String>()[e['correct'] as int],
        e['explanation'] as String? ?? '',
        ...(e['wrongExplanations'] as Map<String, dynamic>)
            .values
            .cast<String>(),
      ];

  /// 문항 전체 — 보기 넷 + 출처 제목까지.
  List<String> allFields(Map<String, dynamic> e) => <String>[
        ...teachFields(e),
        ...(e['options'] as List).cast<String>(),
        for (final s in (e['sources'] as List).cast<Map<String, dynamic>>())
          s['title'] as String? ?? '',
      ];

  List<String> urlsOf(Map<String, dynamic> e) => [
        for (final s in (e['sources'] as List).cast<Map<String, dynamic>>())
          s['url'] as String,
      ];

  /// md 전 줄(파일명:줄번호 꼬리표) + 문항 가르치는 층 필드(문항 id 꼬리표).
  List<MapEntry<String, String>> factUnits() => [
        for (final f in mdFiles)
          for (final (i, l) in linesOf(f).indexed)
            MapEntry('${base(f)}:${i + 1}', l),
        for (final e in allQuestions)
          for (final t in teachFields(e)) MapEntry(e['id'] as String, t),
      ];

  /// md 전 줄 + 문항 전체 필드.
  List<MapEntry<String, String>> nameUnits() => [
        for (final f in mdFiles)
          for (final (i, l) in linesOf(f).indexed)
            MapEntry('${base(f)}:${i + 1}', l),
        for (final e in allQuestions)
          for (final t in allFields(e)) MapEntry(e['id'] as String, t),
      ];

  List<String> hits(Iterable<MapEntry<String, String>> units, bool Function(String) bad) =>
      [
        for (final u in units)
          if (bad(u.value)) '${u.key} → ${u.value.length > 90 ? '${u.value.substring(0, 90)}…' : u.value}',
      ];

  // ─────────────────────────── 대조군 ───────────────────────────

  group('대조군 — 콘텐츠가 읽혔고 구조가 그대로다', () {
    test('md 17편 · 문항 17파일 · 256문항이 읽힌다', () {
      expect(mdFiles.length, 17);
      expect(qFiles.length, 17);
      expect(allQuestions.length, 256);
      for (final f in mdFiles) {
        // `String.length` 는 문자 수다(한국어는 글자당 3바이트).
        expect(f.readAsStringSync().length, greaterThan(8000), reason: base(f));
      }
    });

    test('모든 문항이 보기 4개 · 오답 근거 3개 · 출처 1개 이상이다', () {
      for (final e in allQuestions) {
        final id = e['id'] as String;
        expect((e['options'] as List).length, 4, reason: id);
        expect((e['wrongExplanations'] as Map).length, 3, reason: id);
        expect((e['sources'] as List), isNotEmpty, reason: id);
        for (final u in urlsOf(e)) {
          expect(u, startsWith('https://'), reason: id);
        }
      }
    });

    test('이 배치가 손댄 문항의 정답 인덱스는 불변이다 (1단계 실측값)', () {
      // ⚠️ 추측하지 않고 문항 파일에서 읽은 값이다(보정 전 `q.py` 덤프).
      const correct = <String, int>{
        'dea-t1-1-q3': 1,
        'dea-t1-1-q7': 1,
        'dea-t1-1-q8': 0,
        'dea-t1-1-q9': 0,
        'dea-t1-1-q11': 0,
        'dea-t1-1-q15': 0,
        'dea-t1-1-q16': 0,
        'dea-t1-2-q3': 0,
        'dea-t1-2-q7': 0,
        'dea-t1-2-q10': 0,
        'dea-t1-2-q12': 0,
        'dea-t1-3-q9': 0,
        'dea-t1-3-q14': 0,
        'dea-t1-4-q5': 0,
        'dea-t1-4-q10': 0,
        'dea-t1-4-q13': 0,
        'dea-t2-1-q6': 2,
        'dea-t2-1-q15': 0,
        'dea-t2-3-q1': 0,
        'dea-t3-2-q1': 1,
        'dea-t3-2-q3': 0,
        'dea-t3-2-q9': 1,
        'dea-t3-3-q2': 2,
        'dea-t3-3-q14': 2,
        'dea-t4-1-q4': 3,
        'dea-t4-3-q6': 0,
        'dea-t4-4-q7': 2,
        'dea-t4-4-q8': 1,
        'dea-t4-4-q11': 2,
        'dea-t4-4-q15': 2,
        'dea-t4-5-q7': 1,
      };
      correct.forEach((id, c) => expect(q(id)['correct'], c, reason: id));
    });
  });

  // ─────────────────────────── 🔴 R1~R5 ───────────────────────────

  group('R1 EFO 등록 소비자 한도의 단위는 데이터 스트림이다', () {
    final efo = RegExp(r'EFO|등록 소비자|향상된 팬아웃');
    final perShard20 = RegExp(r'샤드당\s*(최대\s*)?\*{0,2}20(?![0-9,])');
    bool bad(String t) => efo.hasMatch(t) && perShard20.hasMatch(t);

    test('탐지기 대조군 — 옛 문구는 잡고 「샤드당 전용 2 MB/s」는 통과한다', () {
      expect(bad('EFO 사용 시 샤드당 최대 20'), isTrue);
      expect(bad('EFO 소비자를 샤드당 최대 20개까지 붙여'), isTrue);
      expect(bad('EFO를 등록하면 소비자마다 샤드당 전용 2 MB/s를 받고'), isFalse);
      expect(bad('샤드당 쓰기 1 MB/s·1,000 records/s'), isFalse);
      // 20 뒤에 자릿수가 이어지면(200·2,000) 다른 수치다.
      expect(bad('EFO 샤드당 2000'), isFalse);
    });

    test('md + 문항 전수에서 「EFO … 샤드당 (최대) 20」 0건', () {
      expect(hits(factUnits(), bad), isEmpty);
    });

    test('정본 단위가 실재한다 — md 표 · q7 해설 · q7 출처', () {
      final doc = md('dea-t1-1');
      expect(doc, contains('데이터 스트림당'));
      expect(doc, contains('Advantage'));
      final q7 = q('dea-t1-1-q7');
      expect(q7['explanation'], contains('데이터 스트림당 최대 20개'));
      expect(q7['explanation'], contains('50개'));
      expect(
        urlsOf(q7),
        contains(
            'https://docs.aws.amazon.com/streams/latest/dev/service-sizes-and-limits.html'),
      );
    });

    test('보존 — 「소비자마다 샤드당 전용 2 MB/s」는 다른 사실이고 참이다', () {
      // 과잉 정정 방지: 「샤드당」을 통째로 지우면 이 참인 문장이 사라진다.
      expect(md('dea-t1-1'), contains('소비자마다 샤드당 전용 2 MB/s'));
    });
  });

  group('R2 rolling with additional batch 는 Elastic Beanstalk 의 정책이다', () {
    test('「EC2/온프레미스 배포 구성」 귀속 0건', () {
      bool bad(String t) =>
          t.contains('rolling with additional batch') &&
          t.contains('EC2/온프레미스 배포 구성으로');
      expect(hits(nameUnits(), bad), isEmpty);
    });

    test('q13 오답 근거가 Beanstalk 로 귀속하고 그 근거 페이지를 단다', () {
      final e = q('dea-t1-4-q13');
      final w3 = (e['wrongExplanations'] as Map)['3'] as String;
      expect(w3, contains('Elastic Beanstalk'));
      expect(w3, contains('Lambda'));
      // CodeDeploy EC2/온프레미스 사전 정의 구성 셋(공식 표의 행).
      expect(w3, contains('AllAtOnce'));
      expect(w3, contains('HalfAtATime'));
      expect(w3, contains('OneAtATime'));
      expect(
        urlsOf(e),
        contains(
            'https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/using-features.rolling-version-deploy.html'),
      );
      // 보기 문구는 그대로다(오답 보기로 쓰는 것은 무방하다).
      expect((e['options'] as List)[3], 'rolling with additional batch');
    });
  });

  group('R3 버전을 지정하지 않은 Glue 잡의 기본은 6.0 이다', () {
    final bad = RegExp(
        r'(기본 Glue 버전은|버전을 지정하지 않고 만든 (잡|작업)[^\n.]{0,24})\s*\*{0,2}5\.1');

    test('탐지기 대조군 — 스킬 번호 (4.5.1) 과 Glue 5.1 자체는 걸리지 않는다', () {
      expect(bad.hasMatch('버전을 지정하지 않고 만든 잡은 **5.1**로 생성됩니다'), isTrue);
      expect(bad.hasMatch('작업의 **기본 Glue 버전은 5.1** 입니다'), isTrue);
      expect(bad.hasMatch('데이터 주권 이해(4.5.1)'), isFalse);
      expect(bad.hasMatch('Glue 4.0·5.0·5.1을 사용'), isFalse);
    });

    test('md + 문항 전수에서 「기본 5.1」 0건', () {
      expect(hits(factUnits(), bad.hasMatch), isEmpty);
    });

    test('두 학습문서가 6.0 을 기본으로 적는다', () {
      final good = RegExp(
          r'(기본 Glue 버전은|버전을 지정하지 않고 만든 (잡|작업)[^\n.]{0,24})\s*\*{0,2}6\.0');
      expect(good.hasMatch(md('dea-t1-2')), isTrue);
      expect(good.hasMatch(md('dea-t3-3')), isTrue);
    });
  });

  group('R4 S3 Access Points 한도는 계정·리전당 10,000 이다', () {
    final perBucket = RegExp(r'버킷당\s*(최대\s*)?\*{0,2}10,000');

    test('「버킷당 10,000」 0건 (수명 주기 「버킷당 1,000개」는 다른 사실)', () {
      expect(perBucket.hasMatch('**버킷당 최대 10,000개**이며'), isTrue);
      expect(perBucket.hasMatch('수명 주기 규칙 **버킷당 1,000개**'), isFalse);
      expect(hits(factUnits(), perBucket.hasMatch), isEmpty);
    });

    test('Access Points 와 10,000 을 함께 적는 줄은 전부 「계정·리전당」이다', () {
      final lines = [
        for (final u in factUnits())
          if (u.value.contains('Access Points') && u.value.contains('10,000')) u,
      ];
      // 비공허: dea-t4-1 1줄 + dea-t4-5 2줄.
      expect(lines.length, greaterThanOrEqualTo(3));
      for (final u in lines) {
        expect(u.value, contains('계정·리전당'), reason: u.key);
      }
    });
  });

  group('R5 boto3 기본 재시도 모드는 standard 다', () {
    test('「legacy 를 기본으로」·「시점에 따라 다르다」 0건', () {
      bool bad(String t) =>
          t.contains('legacy를 기본으로') ||
          t.contains('기본 모드가 무엇인지는 시점에 따라') ||
          (t.contains('boto3 기본 재시도 모드') && t.contains('자료마다'));
      expect(hits(factUnits(), bad), isEmpty);
    });

    test('dea-t3-1 이 standard 를 기본으로 적고 표의 두 행은 그대로다', () {
      final doc = md('dea-t3-1');
      expect(doc, contains('기본 모드는 standard'));
      expect(doc, contains('retry_mode = legacy'));
      // 보존 — 공식과 일치하는 표 행(legacy 5 · standard 3).
      expect(doc, contains('| **legacy** | 5 (최초 요청 포함)'));
      expect(doc, contains('| **standard** | 3 (최초 요청 포함)'));
    });
  });

  // ─────────────────────────── 🟡 ───────────────────────────

  group('Y1 Multi-AZ 스탠바이의 읽기는 배포 유형으로 갈린다', () {
    bool inContext(String t) =>
        t.contains('Multi-AZ') && RegExp(r'읽기 트래픽|읽기를').hasMatch(t);
    bool qualified(String t) =>
        t.contains('DB 인스턴스 배포') || t.contains('DB 클러스터');

    test('Multi-AZ 와 읽기를 함께 적는 자리는 전부 배포 유형을 한정한다', () {
      final units = [
        for (final u in factUnits())
          if (inContext(u.value)) u,
      ];
      // 비공허: md 4줄(dea-t2-1 2 · dea-t2-3 2) + dea-t2-1-q6 오답 근거.
      expect(units.length, greaterThanOrEqualTo(5));
      expect(
        [for (final u in units) if (!qualified(u.value)) u.key],
        isEmpty,
      );
    });

    test('q6 의 둘째 출처가 그 사실을 담는 페이지다', () {
      final e = q('dea-t2-1-q6');
      expect(
        urlsOf(e),
        contains(
            'https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.MultiAZ.html'),
      );
      // `USER_ReadRepl.html` 의 "standby replica" 는 Db2 복제본 모드 이야기다.
      expect(urlsOf(e).where((u) => u.contains('USER_ReadRepl')), isEmpty);
      // 오답 보기 문구는 그대로다(한정을 넣으면 그 보기가 참이 된다).
      expect((e['options'] as List)[3], 'Multi-AZ 대기 복제본을 추가해 읽기 트래픽을 보낸다');
    });
  });

  group('Y2 Bedrock Provisioned Throughput — 약정 없음이 있고 커스텀 모델 경로는 둘', () {
    test('「커스텀 모델에 필수」·「약정이 필요」 0건', () {
      final bad = RegExp(r'(커스텀|사용자 지정) 모델에 필수|약정이 필요');
      expect(hits(factUnits(), bad.hasMatch), isEmpty);
    });

    test('PT 와 약정을 함께 적는 자리는 「약정 없음」을 적는다', () {
      final units = [
        for (final u in factUnits())
          if (u.value.contains('Provisioned Throughput') && u.value.contains('약정')) u,
      ];
      expect(units.length, greaterThanOrEqualTo(2)); // md 1 + q12 W2
      for (final u in units) {
        expect(u.value, contains('약정 없음'), reason: u.key);
      }
    });

    test('dea-t1-2 가 사용자 지정 모델의 두 경로를 적는다', () {
      final doc = md('dea-t1-2');
      expect(doc, contains('온디맨드 추론용 배포'));
      expect(doc, contains('model-customization-use.html'));
    });
  });

  group('Y3 KMS 온디맨드 회전 한도', () {
    test('「평생/키당 10회」 0건 — 출처 제목까지', () {
      final bad = RegExp(r'(평생|키당)\s*\*{0,2}10회');
      expect(bad.hasMatch('온디맨드 회전 키당 10회'), isTrue);
      expect(hits(nameUnits(), bad.hasMatch), isEmpty);
    });

    test('dea-t4-3 이 개발자 안내서 쿼터(25회·조정 불가)를 적는다', () {
      final doc = md('dea-t4-3');
      expect(doc, contains('25회'));
      expect(doc, contains('조정 불가'));
      expect(doc, contains('kms/latest/developerguide/resource-limits.html'));
      // 보존 — 같은 줄의 참인 사실.
      expect(doc, contains('90~2560일'));
    });
  });

  group('Y4 구체화된 뷰는 Redshift 만의 객체가 아니다', () {
    test('「구체화된 뷰는 Amazon Redshift의 객체입니다」 0건', () {
      bool bad(String t) => t.contains('구체화된 뷰는 Amazon Redshift의 객체입니다');
      expect(hits(nameUnits(), bad), isEmpty);
    });

    test('q1 오답 근거가 「성립 불가」가 아니라 SPICE 와의 차이로 가른다', () {
      final e = q('dea-t3-2-q1');
      final w3 = (e['wrongExplanations'] as Map)['3'] as String;
      expect(w3, isNot(contains('성립하지 않습니다')));
      expect(w3, contains('SPICE'));
      expect(w3, contains('Glue Data Catalog'));
      expect(
        urlsOf(e),
        contains('https://docs.aws.amazon.com/glue/latest/dg/materialized-views.html'),
      );
    });
  });

  group('Y5 CloudWatch Logs 로그 클래스 — Essentials 개명과 S3 내보내기', () {
    test('저작 메모 0건 — 「서술이 엇갈려」·「일수 표현에 차이」', () {
      final bad = RegExp(r'서술이 엇갈려|일수 표현에 차이|제시된 공식 문서에서');
      expect(hits(nameUnits(), bad.hasMatch), isEmpty);
    });

    test('로그 클래스를 정의하는 md 줄은 현재 이름 Essentials 를 병기한다', () {
      final defs = [
        for (final u in factUnits())
          if (u.value.contains('**로그 클래스**') && u.value.contains('Infrequent Access')) u,
      ];
      expect(defs.length, 2); // dea-t3-3 · dea-t4-4
      for (final u in defs) {
        expect(u.value, contains('Essentials'), reason: u.key);
      }
    });

    test('대조군 — S3 스토리지 클래스의 Infrequent Access 는 대상이 아니다', () {
      // 같은 문자열이 S3 Intelligent-Tiering 티어 이름으로도 쓰인다. 금지하지 않는다.
      final s3 = [
        for (final u in factUnits())
          if (u.value.contains('Infrequent Access') && u.value.contains('Intelligent-Tiering')) u,
      ];
      expect(s3, isNotEmpty);
    });

    test('IA 클래스를 가르치는 세 문항이 Essentials 를 적는다', () {
      final w3 = (q('dea-t3-3-q2')['wrongExplanations'] as Map)['3'] as String;
      expect(w3, contains('Essentials'));
      expect(w3, contains('S3 내보내기'));
      expect(q('dea-t3-3-q14')['explanation'], contains('Essentials'));
      expect(q('dea-t4-4-q7')['explanation'], contains('Essentials'));
    });
  });

  group('Y6 cdk bootstrap 의 근거 페이지', () {
    test('q10 과 dea-t1-4 가 bootstrapping.html 을 단다', () {
      const url = 'https://docs.aws.amazon.com/cdk/v2/guide/bootstrapping.html';
      expect(urlsOf(q('dea-t1-4-q10')), contains(url));
      expect(md('dea-t1-4'), contains(url));
    });
  });

  group('Y7 「Redshift Serverless 는 128의 배수」는 공식 문서에 없다', () {
    test('md + 문항 전수(출처 제목 포함) 0건', () {
      expect(hits(nameUnits(), (t) => t.contains('128의 배수')), isEmpty);
    });

    test('보존 — 공식이 적는 「슬라이스 수의 배수」와 128 MB 자동 분할은 남는다', () {
      final slices = [
        for (final u in factUnits())
          if (u.value.contains('슬라이스 수의 배수')) u,
      ];
      expect(slices.length, greaterThanOrEqualTo(5));
      final e = q('dea-t2-3-q1');
      expect(e['explanation'], contains('슬라이스 수의 배수'));
      expect((e['wrongExplanations'] as Map)['3'], contains('128 MB'));
      expect(urlsOf(e).where((u) => u.contains('repost.aws')), isEmpty);
      expect(
        urlsOf(e),
        contains(
            'https://docs.aws.amazon.com/redshift/latest/dg/c_best-practices-use-multiple-files.html'),
      );
    });
  });

  group('Y8 RDS Performance Insights 종료 날짜는 2026-07-31 이다', () {
    test('Performance Insights 줄에 2026-06-30 이 없다', () {
      bool bad(String t) =>
          t.contains('Performance Insights') && t.contains('2026-06-30');
      expect(hits(nameUnits(), bad), isEmpty);
    });

    test('대조군 — 2026-06-30 자체는 Redshift Python UDF 의 날짜로 남는다', () {
      final udf = [
        for (final u in factUnits())
          if (u.value.contains('2026-06-30')) u,
      ];
      expect(udf, isNotEmpty);
      for (final u in udf) {
        expect(u.value, contains('Python UDF'), reason: u.key);
      }
    });

    test('dea-t2-1 이 공식 날짜와 이전 대상을 적고 공식 페이지를 단다', () {
      final doc = md('dea-t2-1');
      expect(doc, contains('2026-07-31'));
      expect(doc, contains('CloudWatch Database Insights'));
      expect(
        doc,
        contains(
            'https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Database-Insights.html'),
      );
      expect(doc, isNot(contains('repost.aws/knowledge-center/rds-mysql-slow-query')));
    });
  });

  group('Y9 Glue Data Catalog compaction 시작 조건', () {
    test('「기본 5개」 0건이고 공식 수치(100개 초과 · 75%)를 적는다', () {
      expect(hits(factUnits(), (t) => t.contains('기본 5개')), isEmpty);
      final line = linesOf(File('$dir/dea-t2-1.md'))
          .firstWhere((l) => l.contains('**자동 최적화**'));
      expect(line, contains('100개'));
      expect(line, contains('75%'));
      expect(md('dea-t2-1'), contains('glue/latest/dg/compaction-management.html'));
    });
  });

  group('Y10 퍼블릭 서브넷이 필요한 것은 영역형 NAT 게이트웨이다', () {
    final pub = RegExp(r'(퍼블릭|공용) 서브넷[^|\n]{0,8}NAT 게이트웨이');

    test('「퍼블릭 서브넷의 NAT 게이트웨이」를 적는 자리는 영역형으로 한정한다', () {
      final units = [
        for (final u in factUnits())
          if (pub.hasMatch(u.value)) u,
      ];
      // 비공허: 정답 보기 둘(dea-t1-1-q16 · dea-t4-1-q4)은 구성을 그대로 적는다.
      expect(units.length, greaterThanOrEqualTo(2));
      for (final u in units) {
        // 정답 보기 자체는 보기 문구라 한정을 해설이 맡는다 — 문항 단위로 본다.
        if (u.key.startsWith('dea-t') && !u.key.contains('.md')) continue;
        expect(u.value, contains('영역형'), reason: u.key);
      }
    });

    test('NAT 를 가르치는 md 네 줄이 영역형/리전형을 가른다', () {
      final lines = [
        for (final f in mdFiles)
          for (final l in linesOf(f))
            if (l.contains('영역형') && l.contains('NAT')) base(f),
      ];
      expect(lines.where((b) => b == 'dea-t1-1.md').length, greaterThanOrEqualTo(1));
      expect(lines.where((b) => b == 'dea-t2-2.md').length, greaterThanOrEqualTo(1));
      expect(lines.where((b) => b == 'dea-t4-1.md').length, greaterThanOrEqualTo(2));
    });

    test('두 문항의 해설이 리전 NAT 게이트웨이를 적고 공식 출처를 단다', () {
      const regional =
          'https://docs.aws.amazon.com/vpc/latest/userguide/nat-gateways-regional.html';
      for (final id in ['dea-t1-1-q16', 'dea-t4-1-q4']) {
        final e = q(id);
        expect(e['explanation'], contains('영역형'), reason: id);
        expect(e['explanation'], contains('리전'), reason: id);
        expect(urlsOf(e), contains(regional), reason: id);
      }
    });
  });

  group('Y11 MWAA 스케줄러 수 — mw1.micro 는 1개', () {
    test('스케줄러 수를 적는 자리는 mw1.micro 예외를 함께 적는다', () {
      final count = RegExp(r'최소 2|2~5|2에서 |2개 이상');
      final units = [
        for (final u in factUnits())
          if (u.value.contains('스케줄러') && count.hasMatch(u.value)) u,
      ];
      expect(units.length, greaterThanOrEqualTo(3)); // md 2 + q9 W2
      for (final u in units) {
        expect(u.value, contains('mw1.micro'), reason: u.key);
      }
    });
  });

  group('Y12 Kinesis 이벤트 소스 매핑의 실패 대상은 SQS·SNS 만이 아니다', () {
    test('「실패 대상(SQS/SNS)」 0건 — 보기까지', () {
      expect(hits(nameUnits(), (t) => t.contains('실패 대상(SQS/SNS)')), isEmpty);
    });

    test('q15 해설과 md 가 S3 대상과 전달 내용의 차이를 적는다', () {
      final e = q('dea-t1-1-q15');
      expect(e['explanation'], contains('S3'));
      expect(e['explanation'], contains('메타데이터'));
      expect(e['explanation'], contains('호출 레코드 전체'));
      final line = linesOf(File('$dir/dea-t1-1.md'))
          .firstWhere((l) => l.contains('**Kinesis → Lambda 튜닝**'));
      expect(line, contains('S3'));
    });
  });

  group('Y13 낡은 저작 상태 문구', () {
    test('md 전수에서 「사람 검수 전」 0건', () {
      // ⚠️ 공개 상태(verified)를 단정하는 것이 아니다 — 낡은 문구의 금지다.
      final found = [
        for (final f in mdFiles)
          for (final (i, l) in linesOf(f).indexed)
            if (l.contains('사람 검수 전')) '${base(f)}:${i + 1}',
      ];
      expect(found, isEmpty);
    });

    test('보존 — 출처 절 머리말과 수집·저작 날짜는 17편 모두 남는다', () {
      for (final f in mdFiles) {
        final head = linesOf(f)
            .where((l) => l.startsWith('이 문서의 사실 진술은 아래 공식 자료로 대조했습니다.'))
            .toList();
        expect(head.length, 1, reason: base(f));
        expect(head.single, contains('수집·대조:'), reason: base(f));
        expect(head.single, contains('저작:'), reason: base(f));
      }
    });
  });

  group('Y14·Y16 비공식·백서 출처', () {
    test('dea-t4-1-q4 의 출처가 공식 문서다', () {
      final urls = urlsOf(q('dea-t4-1-q4'));
      expect(urls.where((u) => u.contains('repost.aws')), isEmpty);
      expect(
        urls,
        contains('https://docs.aws.amazon.com/lambda/latest/dg/configuration-vpc-internet.html'),
      );
      expect(
        urls,
        contains('https://docs.aws.amazon.com/lambda/latest/dg/configuration-vpc.html'),
      );
    });

    test('dea-t1-2-q7 이 Lambda 요금 사실을 담는 요금 페이지를 단다', () {
      final urls = urlsOf(q('dea-t1-2-q7'));
      expect(urls, contains('https://aws.amazon.com/athena/pricing/'));
      expect(urls.where((u) => u.contains('big-data-analytics-options')), isEmpty);
    });

    test('md 에 남은 Athena 백서 줄에는 상태 메모가 있다', () {
      final lines = [
        for (final f in mdFiles)
          for (final l in linesOf(f))
            if (l.contains('whitepapers/latest/big-data-analytics-options/')) l,
      ];
      for (final l in lines) {
        expect(l, contains('리다이렉트'));
      }
    });
  });

  group('Y15 Redshift ALL 분산의 조건', () {
    test('dea-t3-4 의 ALL 분산 줄은 colocate 조건을 적는다', () {
      final lines = linesOf(File('$dir/dea-t3-4.md'))
          .where((l) => l.contains('**ALL 분산**'))
          .toList();
      expect(lines.length, 2);
      for (final l in lines) {
        expect(l, contains('colocate'));
      }
    });
  });

  // ─────────────────────────── 🟢 ───────────────────────────

  group('G2 자기 프레임 — 지문·정답 보기에 「공식」 0건', () {
    test('256문항 전수', () {
      final found = [
        for (final e in allQuestions)
          if ('${e['stem']}\n${(e['options'] as List)[e['correct'] as int]}'
              .contains('공식'))
            e['id'],
      ];
      expect(found, isEmpty);
    });

    test('대조군 — 해설의 출처 귀속은 정당한 층이라 남아 있다', () {
      final inExplanation = [
        for (final e in allQuestions)
          if ((e['explanation'] as String).contains('공식')) e['id'],
      ];
      expect(inExplanation, isNotEmpty);
    });
  });

  group('G3·G4·G5 저작 메모 · 날짜 고정 지문 · 오타', () {
    test('「문항은 피하세요」 0건 (학습자가 아니라 저작자에게 하는 말)', () {
      expect(hits(nameUnits(), (t) => t.contains('문항은 피하세요')), isEmpty);
    });

    test('날짜에 묶인 지문 0건 — 「2026-10 현재」', () {
      final bad = RegExp(r'2026-1[0-2] 현재');
      expect(hits(nameUnits(), bad.hasMatch), isEmpty);
    });

    test('오타 「북반」 0건', () {
      expect(hits(nameUnits(), (t) => t.contains('북반')), isEmpty);
      expect(md('dea-t3-1'), contains('Glue 북마크 Disable'));
    });
  });

  group('G7 Quick 제품 문서의 페이지 제목', () {
    test('출처 제목은 실제 페이지 제목 「What is AWS Quick?」이다', () {
      expect(hits(nameUnits(), (t) => t.contains('What is Amazon Quick?')), isEmpty);
      final titles = [
        for (final s in (q('dea-t3-2-q3')['sources'] as List).cast<Map<String, dynamic>>())
          s['title'] as String,
      ];
      expect(titles.where((t) => t.startsWith('What is AWS Quick?')), isNotEmpty);
    });

    test('보존 — 본문 표기는 시험 가이드 표기 「Amazon Quick」을 유지한다', () {
      expect(md('dea-t3-2'), contains('Amazon Quick'));
    });
  });
}
