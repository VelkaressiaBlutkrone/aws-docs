import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// AIF-C01 2단계 보정 가드 — 2026-11-17 전 콘텐츠 검증(1단계 보고
/// `docs/audits/2026-11-17-full-verify/aif.md`)을 집행한 결과를 고정한다.
/// 반영 보고는 `docs/audits/2026-11-17-full-verify/aif-phase2.md`.
///
/// **무엇을 고쳤는가(한 줄씩)**
///
/// - 🔴 `aif-t2-3.md` 「시험 포인트」의 **「PT(필수)」** — 사용자 지정 모델의 추론
///   설정은 **둘**(PT 구매 / 온디맨드 추론용 배포)이다. 이 오류가 라이브에
///   남은 것은 **다섯 번째**이고, 이번에는 **약어 + 괄호**(`PT(필수)`)가 기존
///   리터럴 `'PT 필수'`와 정규식 `프로비저닝(된)? 처리량…(사야|구매해야)`를
///   둘 다 비켜 갔다. 그래서 **「PT·프로비저닝 처리량」과 「필수」가 가까이
///   있는 줄**을 md + 문항 전수에서 센다.
/// - Y1 `genai-guide.html`이 **2026-11-14에 개정**돼 옛 인용문이 사라졌다
///   (파라미터 수 기준선·「결정적 요소」·「가장 본질적인 기준」 등). 현행 문구로
///   다시 썼다.
/// - Y2 옛 벡터 데이터베이스 안내 페이지가 의사 결정 가이드로 **영구 이동(301)**
///   하면서 서비스별 권장 문구가 사라졌다.
/// - Y3 지속 가능성 「리전 선택」 모범 사례의 현행 정본은
///   `framework/sus01-bp03.html`(**SUS01-BP03**)이다. 옛 백서의 `SUS01-BP01`은
///   "역사적 참조용"이고, 현행 Framework의 `SUS01-BP01`은 **다른 모범 사례**다.
/// - Y4 Quick 제품 사용자 가이드가 서비스를 **`AWS Quick`**으로 적는다(시험
///   가이드·범위 내 목록은 `Amazon Quick`). **일괄 개명하지 않고** 사용자
///   가이드를 인용·귀속하는 문장과 기능 이름만 고쳤다.
/// - Y5~Y9 출처가 그 사실을 담지 않던 다섯 자리, Y10 메타 문항 재작성,
///   Y11 `CloudTrail Lake`를 새로 만들라고 권하던 두 줄.
///
/// **설계 규율**
///
/// - 사실 단정은 **전수 집계형**이다(문항별 리터럴 가드는 어형 하나로 뚫린다).
/// - **옛 문구 0건 + 새 공식 사실 있음**을 쌍으로 단정한다.
/// - ⚠️ **`verified`는 단정하지 않는다** — 사람의 flip이 바로 그 값을 바꾼다.
///   구조 단정(보기 4개 · Task당 15문항 · 정답 인덱스 불변)으로 대신한다.
/// - 탐지기마다 **대조군**을 붙인다(0건이 「고장 나서 0건」이 아님을 보인다).
void main() {
  const dir = 'assets/content/aif';
  const taskIds = [
    'aif-t1-1', 'aif-t1-2', 'aif-t1-3',
    'aif-t2-1', 'aif-t2-2', 'aif-t2-3',
    'aif-t3-1', 'aif-t3-2', 'aif-t3-3', 'aif-t3-4',
    'aif-t4-1', 'aif-t4-2',
    'aif-t5-1', 'aif-t5-2',
  ];

  String md(String taskId) => File('$dir/$taskId.md').readAsStringSync();
  String bankRaw(String taskId) =>
      File('$dir/$taskId.questions.json').readAsStringSync();

  List<Map<String, dynamic>> questions(String taskId) {
    final data = json.decode(bankRaw(taskId)) as Map<String, dynamic>;
    return (data['questions'] as List).cast<Map<String, dynamic>>();
  }

  List<Map<String, dynamic>> allQuestions() =>
      [for (final t in taskIds) ...questions(t)];

  Map<String, dynamic> q(String id) {
    final taskId = RegExp(r'^(aif-t\d-\d)-q\d+$').firstMatch(id)!.group(1)!;
    return questions(taskId).firstWhere((x) => x['id'] == id);
  }

  /// 문항 전체(지문·보기·해설·오답 근거·출처 제목·URL)를 한 덩어리로 본다.
  String allText(Map<String, dynamic> x) => json.encode(x);

  String correctOption(Map<String, dynamic> x) =>
      (x['options'] as List)[x['correct'] as int] as String;

  List<String> sourceUrls(Map<String, dynamic> x) => [
        for (final s in x['sources'] as List)
          (s as Map<String, dynamic>)['url'] as String,
      ];

  /// md + 문항 전수를 **줄 단위**로 훑어 `파일:줄` 목록을 돌려준다(정렬).
  List<String> scanLines(bool Function(String line) hit,
      {bool docs = true, bool banks = true}) {
    final out = <String>[];
    for (final t in taskIds) {
      final files = [
        if (docs) '$t.md',
        if (banks) '$t.questions.json',
      ];
      for (final name in files) {
        final lines = File('$dir/$name').readAsStringSync().split('\n');
        for (var i = 0; i < lines.length; i++) {
          if (hit(lines[i])) out.add('$name:${i + 1}');
        }
      }
    }
    out.sort();
    return out;
  }

  /// 프런트매터 `sources`의 URL 집합.
  Set<String> frontmatterUrls(String taskId) {
    final raw = md(taskId).replaceAll('\r\n', '\n');
    final end = raw.indexOf('\n---\n', 4);
    final fm = raw.substring(0, end);
    return {
      for (final m in RegExp(r'^    url: (\S+)$', multiLine: true).allMatches(fm))
        m.group(1)!,
    };
  }

  // ═════════════════════ 대조군: 입력이 읽혔는가 ═════════════════════

  group('대조군', () {
    test('학습문서 14편과 문항 210개가 읽힌다', () {
      for (final t in taskIds) {
        // ⚠️ `String.length`는 문자 수다(한국어 md는 글자당 3바이트).
        expect(md(t).length, greaterThan(10000), reason: '$t.md');
        expect(questions(t).length, 15, reason: '$t: Task당 15문항');
      }
      expect(allQuestions().length, 210);
    });

    test('문항 구조가 성립한다 (보기 4개 · 오답 근거 3개)', () {
      for (final x in allQuestions()) {
        expect((x['options'] as List).length, 4, reason: x['id'] as String);
        final c = x['correct'] as int;
        expect(
          (x['wrongExplanations'] as Map).keys.toSet(),
          {
            for (var i = 0; i < 4; i++)
              if (i != c) '$i',
          },
          reason: x['id'] as String,
        );
      }
    });
  });

  // ═════════════════════ 정답 인덱스 불변 ═════════════════════

  // ⚠️ 이 배치는 **정답 인덱스를 한 건도 바꾸지 않았다.** 값은 추측이 아니라
  // 수정 전 파일에서 읽은 실측이다. `skill`·`section`도 함께 묶는다 —
  // `aif_questions_test`가 Task별 「모든 목표가 최소 한 문항에 덮인다」를 본다.
  test('손댄 26문항의 정답 인덱스·skill·section이 그대로다', () {
    const expected = <String, List<Object>>{
      'aif-t1-2-q10': [1, '1.2.4', 'applications'],
      'aif-t1-3-q8': [0, '1.3.4', 'aws-services'],
      'aif-t1-3-q9': [1, '1.3.4', 'aws-services'],
      'aif-t2-1-q10': [2, '2.1.5', 'context-engineering'],
      'aif-t2-2-q1': [0, '2.2.1', 'benefits'],
      'aif-t2-2-q9': [2, '2.2.3', 'model-selection'],
      'aif-t2-2-q10': [1, '2.2.3', 'model-selection'],
      'aif-t2-2-q11': [0, '2.2.3', 'model-selection'],
      'aif-t2-2-q12': [2, '2.2.3', 'model-selection'],
      'aif-t2-3-q1': [1, '2.3.1', 'services'],
      'aif-t2-3-q3': [0, '2.3.1', 'services'],
      'aif-t2-3-q4': [3, '2.3.1', 'services'],
      'aif-t3-1-q1': [1, '3.1.1', 'model-criteria'],
      'aif-t3-1-q2': [0, '3.1.1', 'model-criteria'],
      'aif-t3-1-q9': [2, '3.1.4', 'vector-stores'],
      'aif-t3-1-q10': [1, '3.1.4', 'vector-stores'],
      'aif-t3-1-q12': [3, '3.1.5', 'pitfalls'],
      'aif-t3-2-q9': [1, '3.2.3', 'best-practices'],
      'aif-t3-3-q3': [0, '3.3.1', 'cpt-then-ft'],
      'aif-t3-4-q12': [3, '3.4.4', 'app-eval'],
      'aif-t4-1-q5': [0, '4.1.2', 'guardrails'],
      'aif-t4-1-q6': [1, '4.1.3', 'model-selection'],
      'aif-t4-1-q7': [2, '4.1.3', 'model-selection'],
      'aif-t4-1-q12': [3, '4.1.6', 'bias-variance'],
      'aif-t4-2-q8': [3, '4.2.2', 'tools'],
      'aif-t5-1-q5': [0, '5.1.2', 'provenance'],
    };
    expected.forEach((id, v) {
      final x = q(id);
      expect(x['correct'], v[0], reason: '$id correct');
      expect(x['skill'], v[1], reason: '$id skill');
      expect(x['section'], v[2], reason: '$id section');
    });
  });

  // ═════════════════════ 🔴 「PT 필수」 약어형 ═════════════════════

  group('🔴 사용자 지정 모델의 추론 설정은 둘이다 — 「필수」 어형 전수', () {
    // 「PT」 또는 「프로비저닝(된) 처리량」과 「필수」가 **25자 이내**에 함께
    // 있는 줄. 괄호·공백·굵게 표시가 사이에 끼어도 잡힌다.
    final pattern = RegExp(
        r'(PT|프로비저닝(된)?\s?처리량).{0,25}필수|필수.{0,25}(PT|프로비저닝(된)?\s?처리량)');
    // 「필수는 아닙니다」처럼 **부정으로 정정하는** 문장은 정당하다.
    final negation = RegExp(r'필수(는|가)?\s?아닙|아직');
    bool asserts(String line) =>
        pattern.hasMatch(line) && !negation.hasMatch(line);

    test('대조군: 탐지기가 네 번의 누출 어형을 모두 잡는다', () {
      expect(asserts('**"사용자 지정 모델 서빙"**이면 PT(필수), 캐싱입니다'), isTrue,
          reason: '이번에 새어 나간 약어 + 괄호');
      expect(asserts('사용자 지정 모델은 **PT 필수**'), isTrue);
      expect(asserts('사용자 지정 모델에는 프로비저닝된 처리량이 **필수**입니다'), isTrue);
      expect(asserts('필수 조건은 프로비저닝 처리량 구매입니다'), isTrue);
      // 정정문은 걸리지 않는다.
      expect(asserts('프로비저닝 처리량이 **필수는 아닙니다** — 온디맨드 배포가 있습니다'), isFalse);
      expect(
          asserts('**PT 구매 또는 온디맨드 추론용 배포**(처리량 보장이 필요하면 PT)'), isFalse,
          reason: '이번 정정문 자신');
    });

    test('md + 문항 전수에서 단정하는 줄이 0건이다', () {
      expect(scanLines(asserts), isEmpty,
          reason: '공식 「Set up inference for a custom model」: "you can set up '
              'inference using one of the following options" — Provisioned '
              'Throughput 구매 / on-demand inference용 배포');
    });

    test('「비용 절충 문항」 줄이 두 경로를 함께 적는다', () {
      final line = md('aif-t2-3')
          .split('\n')
          .firstWhere((l) => l.contains('**비용 절충 문항**은 세 패턴'));
      expect(line, contains('온디맨드 추론용 배포'));
      expect(line, contains('PT'));
    });
  });

  // ═════════════════════ Y1 결정 가이드 2026-11-14 개정 ═════════════════════

  group('Y1 genai-guide.html 개정으로 사라진 인용문', () {
    // 현행 페이지 본문 + raw HTML에서 0건인 옛 인용(대조군 `Quality of
    // response` 1건). 「공식이 적는다」로 귀속하던 문장들이다.
    const orphaned = <String>[
      '500억',
      '가장 본질적인 기준',
      '결정적 요소',
      '복잡한 아키텍처 때문에',
      '예산 친화',
      '안전한 관리형 환경',
      '모델 복잡도의 핵심 지표',
      'Fine-tuning and continuous pre-training capability',
      'model-independent, single API access',
    ];

    test('md + 문항 전수에서 0건이다', () {
      final hits = scanLines((l) => orphaned.any(l.contains));
      expect(hits, isEmpty, reason: '개정판에 없는 문구: $hits');
    });

    test('현행 문구가 학습문서에 있다', () {
      final t22 = md('aif-t2-2');
      for (final s in [
        '대체로 가장 중요한 기준', // "This is usually the most important criterion."
        '추론과 도구 사용', // Reasoning and tool use
        '수명 주기', // Lifecycle
        '작은 모델이 대체로 더 빠르고 저렴', // "Smaller models are usually faster and cheaper"
        '2026-11-14',
      ]) {
        expect(t22, contains(s), reason: 'aif-t2-2.md: $s');
      }
      expect(md('aif-t3-1'), contains('숫자를 외우지 않습니다'),
          reason: '파라미터 수의 기준선은 현행 판에 없다');
      expect(md('aif-t2-3'), contains('model-independent API access'),
          reason: '현행: "Because Amazon Bedrock offers model-independent API access"');
    });

    test('결정 가이드를 출처로 적는 참고자료 줄은 개정판 확인 날짜를 단다', () {
      // 세 편 모두 참고자료 절에서 이 URL을 한 줄로 든다.
      for (final t in ['aif-t2-2', 'aif-t2-3', 'aif-t3-1']) {
        final line = md(t).split('\n').firstWhere((l) =>
            RegExp(r'^\d+\. ').hasMatch(l) &&
            l.contains('decision-guides/genai-guide.html'));
        expect(line, contains('2026-11-17 확인'), reason: t);
        expect(line, contains('개정'), reason: t);
      }
    });

    test('문항이 현행 문구로 근거를 든다', () {
      final q10 = q('aif-t2-2-q10');
      expect(q10['explanation'], contains('작은 모델이 대체로 더 빠르고 저렴'));
      final q11 = q('aif-t2-2-q11');
      expect(correctOption(q11), contains('지속적인 사전 훈련'));
      expect(correctOption(q11), contains('특화'),
          reason: '"Train a model on your own unlabeled data to make it more '
              'domain-specific"');
      expect(q('aif-t3-1-q2')['explanation'], contains('사용자 지정 지원'),
          reason: 'Customization support');
    });

    test('대조군: 개정에도 그대로인 인용은 건드리지 않았다', () {
      // `aif-t2-3-q7`이 인용한 "Experiment faster" 문장은 현행에도 있다.
      expect(sourceUrls(q('aif-t2-3-q7')),
          contains(contains('decision-guides/genai-guide.html')));
    });
  });

  // ═════════════════════ Y2 벡터 데이터베이스 인용 ═════════════════════

  group('Y2 벡터 저장소 — 영구 이동한 옛 안내 페이지의 문구', () {
    const orphaned = <String>[
      '이상적인 선택',
      '더 높은 수준의 이해',
      '수평 확장',
      '분석 그래프 데이터베이스 엔진',
      'Aurora Serverless v2',
    ];

    test('aif-t3-1 md + 문항에서 0건이다', () {
      final text = md('aif-t3-1') + bankRaw('aif-t3-1');
      expect(orphaned.where(text.contains).toList(), isEmpty);
    });

    test('전수: 「이상적」으로 서비스를 권하는 귀속 문장이 없다', () {
      expect(scanLines((l) => l.contains('이상적인 선택')), isEmpty);
    });

    test('현행 의사 결정 가이드의 문구와 RDS for PostgreSQL의 출처가 있다', () {
      final t = md('aif-t3-1');
      expect(t, contains('PostgreSQL 전문성이 있고 SQL과 벡터 질의를 함께 써야 하는 팀'),
          reason: '"Teams with PostgreSQL expertise who need SQL and vector '
              'queries together."');
      expect(t, contains('엔터티 관계를 사용하는 검색'),
          reason: '"GraphRAG – retrieval that uses entity relationships."');
      // RDS for PostgreSQL은 의사 결정 가이드에 없다(0건) → 그 사실의 출처를 든다.
      expect('aws.amazon.com/what-is/vector-databases/'.allMatches(t).length, 2,
          reason: '프런트매터 sources와 참고자료 양쪽');
    });

    test('q9·q10이 현행 문구로 답한다', () {
      expect(correctOption(q('aif-t3-1-q9')), contains('pgvector'));
      expect(correctOption(q('aif-t3-1-q10')), contains('GraphRAG'));
      expect(q('aif-t3-1-q9')['explanation'], contains('PostgreSQL 전문성'));
    });
  });

  // ═════════════════════ Y3 리전 선택 모범 사례 ═════════════════════

  group('Y3 지속 가능성 리전 선택 — 현행 정본은 SUS01-BP03', () {
    test('옛 백서의 문구와 죽은 슬러그가 없다', () {
      final hits = scanLines((l) =>
          l.contains('재생 에너지 프로젝트') ||
          l.contains('sus_sus_region_a2') ||
          l.contains('한 지리적 위치'));
      expect(hits, isEmpty);
    });

    test('`SUS01-BP01`은 「옛 번호」로만 언급된다', () {
      // `MLSUS01-BP01`(머신 러닝 렌즈)은 다른 모범 사례라 제외한다.
      final old = RegExp(r'(?<!ML)SUS01-BP01');
      final lines = [
        for (final t in taskIds) ...md(t).split('\n').where(old.hasMatch),
      ];
      expect(lines, isNotEmpty, reason: '대조군 — 번호 재배정 경고가 남아 있다');
      for (final l in lines) {
        expect(l, contains('역사적 참조용'), reason: l);
      }
      expect(
          [for (final x in allQuestions()) allText(x)].where(old.hasMatch),
          isEmpty,
          reason: '문항은 BP 번호를 쓰지 않는다');
    });

    test('현행 정본이 프런트매터·참고자료·문항 출처에 있다', () {
      final t = md('aif-t4-1');
      expect(t, contains('SUS01-BP03 Select Regions that align to your sustainability goals'));
      expect('wellarchitected/latest/framework/sus01-bp03.html'.allMatches(t).length,
          2);
      expect(t, contains('전력망의 탄소 집약도'),
          reason: '"consider the carbon intensity of each Region\'s power grid"');
      for (final id in ['aif-t4-1-q6', 'aif-t4-1-q7']) {
        expect(sourceUrls(q(id)), contains(contains('framework/sus01-bp03.html')),
            reason: id);
      }
    });

    test('전수: 리전 선택 안티패턴을 드는 문항은 그 출처를 든다', () {
      final users = allQuestions()
          .where((x) => allText(x).contains('리전 선택 모범 사례'))
          .toList();
      expect(users, isNotEmpty, reason: '대조군');
      for (final x in users) {
        expect(sourceUrls(x), contains(contains('sus01-bp03.html')),
            reason: x['id'] as String);
      }
    });
  });

  // ═════════════════════ Y4 Quick 표기 ═════════════════════

  group('Y4 Quick — 제품 사용자 가이드는 `AWS Quick`으로 적는다', () {
    test('사용자 가이드가 정의하는 기능 이름을 옛 접두사로 쓰지 않는다', () {
      final old = RegExp(
          r'Amazon Quick (Sight|Flows|Automate|Index|Research)|Apps in Amazon Quick');
      expect(scanLines(old.hasMatch), isEmpty,
          reason: '현행 사용자 가이드: AWS Quick Sight · AWS Quick Flows · … · '
              'Apps in AWS Quick');
    });

    test('페이지 제목과 따옴표 인용이 현행 원문과 맞는다', () {
      expect(scanLines((l) => l.contains('What is Amazon Quick?')), isEmpty,
          reason: '<title>What is AWS Quick? - AWS Quick</title>');
      expect(scanLines((l) => l.contains('"Amazon Quick은 Amazon QuickSight에서')),
          isEmpty,
          reason: '원문은 "AWS Quick evolved from Amazon QuickSight."');
      for (final t in ['aif-t1-3', 'aif-t2-3']) {
        expect('What is AWS Quick?'.allMatches(md(t)).length, 2,
            reason: '$t: 프런트매터와 참고자료');
      }
    });

    test('두 학습문서가 표기의 갈림을 명시한다', () {
      for (final t in ['aif-t1-3', 'aif-t2-3']) {
        final note = md(t).split('\n').where((l) =>
            l.contains('표기가 공식 안에서 갈립니다') &&
            l.contains('`Amazon Quick`') &&
            l.contains('`AWS Quick`') &&
            l.contains('시험 가이드'));
        expect(note.length, 1, reason: t);
      }
    });

    test('대조군: 시험 가이드 표기 `Amazon Quick`은 일괄 개명하지 않았다', () {
      // 공식 범위 내 서비스 목록과 시험 가이드 본문은 `Amazon Quick`이다.
      // 이 수가 0에 가까워지면 **과잉 정정**이다. 하한은 추측이 아니라 실측에서
      // 잡았다 — 보정 전 75건, 보정 뒤 40건(줄어든 35건은 기능 이름과 사용자
      // 가이드 인용이다).
      var n = 0;
      for (final t in taskIds) {
        n += 'Amazon Quick'.allMatches(md(t) + bankRaw(t)).length;
      }
      expect(n, greaterThanOrEqualTo(30));
    });

    test('문항 해설이 귀속을 바로 적는다', () {
      for (final id in ['aif-t1-3-q9', 'aif-t2-3-q4']) {
        final e = q(id)['explanation'] as String;
        expect(e, contains('AWS Quick'), reason: id);
        expect(e, contains('Amazon Quick'), reason: '$id: 시험 가이드 표기 병기');
        expect(e.contains('공식 사용자 가이드는 Amazon Quick을'), isFalse, reason: id);
      }
    });
  });

  // ═════════════════════ Y5~Y9 출처가 그 사실을 담는가 ═════════════════════

  group('Y5~Y9 인용한 페이지가 그 사실을 담는다 (전수 불변식)', () {
    /// 「이 문구를 가르치는 문항은 이 URL을 출처로 든다」.
    void requireSource(String phrase, String urlPart, {int atLeast = 1}) {
      final users =
          allQuestions().where((x) => allText(x).contains(phrase)).toList();
      expect(users.length, greaterThanOrEqualTo(atLeast),
          reason: '대조군 — 「$phrase」를 쓰는 문항이 있다');
      for (final x in users) {
        expect(sourceUrls(x), contains(contains(urlPart)),
            reason: '${x['id']}: 「$phrase」의 출처');
      }
    }

    test('Y5 「추론의 효과가 감쇠」는 그 문장이 있는 출처와 함께만 쓴다', () {
      // 그 문장은 AWS Database Blog에 있고 `AGENTPERF03-BP02`에는 없다
      // (`decay|degrad|attenuat|diminish` 0건, 대조군 `crowd out` 1건).
      requireSource('감쇠', 'key-components-of-a-data-driven-agentic-ai-application');
      final w0 = (q('aif-t2-1-q10')['wrongExplanations'] as Map)['0'] as String;
      expect(w0.contains('감쇠'), isFalse);
      expect(w0, contains('추론 용량'),
          reason: '"conversation history and tool schemas crowd out reasoning '
              'capacity and inflate latency on every iteration"');
    });

    test('Y6 「교사가 현저히 크고 유능」의 출처는 증류 전제 조건 페이지다', () {
      requireSource('현저히 크고', 'prequisites-model-distillation.html');
      expect(frontmatterUrls('aif-t3-1'),
          contains(contains('prequisites-model-distillation.html')));
    });

    test('Y7 「내장 평가자 구성은 수정할 수 없다」의 출처는 AgentCore 페이지다', () {
      requireSource('수정할 수 없', 'built-in-evaluators-overview.html');
    });

    test('Y8 「가드레일 버전은 자체 ARN이 없다」의 출처가 있다', () {
      requireSource('자체 ARN', 'guardrails-deploy.html');
      expect(
          'bedrock/latest/userguide/guardrails-deploy.html'
              .allMatches(md('aif-t4-1'))
              .length,
          2,
          reason: '프런트매터와 참고자료');
    });

    test('Y9 FAQ의 「현저히 더 적은 레이블 레코드」는 Titan 한정으로 적는다', () {
      final users = allQuestions()
          .where((x) => allText(x).contains('현저히 더 적은 레이블'))
          .toList();
      expect(users, isNotEmpty, reason: '대조군');
      for (final x in users) {
        expect(x['explanation'], contains('Titan'),
            reason: '${x['id']}: "This job will adapt the Amazon Titan base '
                'model to the new domain"');
      }
    });
  });

  // ═════════════════════ Y10 메타 문항 ═════════════════════

  group('Y10 aif-t2-2-q9 — 가이드 판본의 차이가 아니라 선택 기준을 묻는다', () {
    test('옛 메타 문구가 없다', () {
      final text = allText(q('aif-t2-2-q9'));
      for (final s in ['여덟 가지', '출제 범위', '영문 본문은', '다섯 가지']) {
        expect(text.contains(s), isFalse, reason: s);
      }
      expect((q('aif-t2-2-q9')['stem'] as String).contains('시험 가이드'), isFalse);
    });

    test('요금을 선택 요소로 가르치고 출처가 둘이다', () {
      final x = q('aif-t2-2-q9');
      expect(correctOption(x), contains('비용'));
      expect(x['explanation'], contains('요금'));
      expect(sourceUrls(x), contains(contains('decision-guides/genai-guide.html')));
      expect(sourceUrls(x), contains(contains('ai-practitioner-01-domain2.html')));
    });

    test('전수: 지문이 시험 가이드의 판본을 묻는 문항이 없다', () {
      final offenders = [
        for (final x in allQuestions())
          if (RegExp(r'영문 (공식 )?시험 가이드').hasMatch(x['stem'] as String))
            x['id'],
      ];
      expect(offenders, isEmpty);
    });

    test('새 보기의 길이가 정답 단서가 되지 않는다', () {
      // 양방향: 정답 ÷ 최장 오답 ≤ 1.3, 그리고 정답 ≥ 최단 오답.
      for (final id in ['aif-t2-2-q9', 'aif-t2-2-q10', 'aif-t2-2-q11', 'aif-t3-1-q9']) {
        final x = q(id);
        final opts = (x['options'] as List).cast<String>();
        final c = x['correct'] as int;
        final wrong = [
          for (var i = 0; i < 4; i++)
            if (i != c) opts[i].length,
        ]..sort();
        expect(opts[c].length / wrong.last, lessThanOrEqualTo(1.3), reason: id);
        expect(opts[c].length, greaterThanOrEqualTo(wrong.first), reason: id);
      }
    });
  });

  // ═════════════════════ Y11 CloudTrail Lake ═════════════════════

  group('Y11 aif-t5-2.md — CloudTrail Lake를 권하는 줄은 상태를 적는다', () {
    // 트리거는 **기능 이름**으로 좁힌다 — CloudTrail 본체·추적·Insights는 정상이다.
    bool recommends(String l) =>
        l.contains('CloudTrail Lake') &&
        (l.contains('만듭니다') || l.contains('필요합니다'));

    test('대조군: 탐지기가 옛 권유 문장을 잡는다', () {
      expect(
          recommends('지속 보관이 필요하면 **추적(S3)** 또는 **CloudTrail Lake**를 만듭니다'),
          isTrue);
      expect(recommends('CloudTrail 본체는 영향이 없습니다'), isFalse);
    });

    test('권하는 줄마다 「신규 고객」 상태가 있다', () {
      final lines = md('aif-t5-2').split('\n').where(recommends).toList();
      expect(lines, isNotEmpty, reason: '대조군');
      for (final l in lines) {
        expect(l, contains('신규 고객'), reason: l);
      }
    });

    test('「시험 직전 요약」의 기록 방식 3종 줄도 상태를 적는다', () {
      final line = md('aif-t5-2')
          .split('\n')
          .firstWhere((l) => l.contains('CloudTrail의 기록 방식은 3종'));
      expect(line, contains('신규 고객'));
      expect(line, contains('추적(Trail)'), reason: '본체 쪽 수단은 그대로다');
    });
  });

  // ═════════════════════ 🟢 저작 메모·번역 ═════════════════════

  group('🟢 저작 메모와 번역', () {
    test('문항에 레포 용어 「정본」이 없다', () {
      final offenders = [
        for (final x in allQuestions())
          if (allText(x).contains('정본')) x['id'],
      ];
      expect(offenders, isEmpty);
    });

    test('Strands Agents — "initially released … as an open-source SDK"', () {
      expect(scanLines((l) => l.contains('처음 공개한 오픈소스')), isEmpty,
          reason: '「AWS 최초의 오픈소스 SDK」로 읽히는 번역');
      expect(md('aif-t2-3'), contains('처음에 오픈소스 SDK로 공개'));
    });

    test('프롬프트 최적화의 멈출 지점 — "below acceptable thresholds"', () {
      expect(allText(q('aif-t3-2-q9')).contains('기준선'), isFalse);
      expect(q('aif-t3-2-q9')['stem'], contains('허용 임계값'));
      expect(md('aif-t3-2'), contains('허용 임계값 아래에서'));
    });

    test('Clarify — 기존 고객은 계속 쓴다', () {
      final stem = q('aif-t4-2-q8')['stem'] as String;
      expect(stem.contains('더 쓸 수 없게'), isFalse,
          reason: '"Existing customers can continue to use the service as normal."');
      expect(stem, contains('신규 고객'));
    });
  });

  // ═════════════════════ 🟢 G1-1 교차 Task 중복 ═════════════════════

  group('🟢 G1-1 aif-t4-1-q12 — 공개 문항과 같은 사실을 묻지 않는다', () {
    // `aif-t1-1-q1`(목표 1.1.1)과 `aif-t4-1-q12`(목표 4.1.6)가 둘 다 「훈련에서는
    // 좋고 테스트에서 나쁘다 → 과적합·높은 분산/변동」을 물었다(같은 페이지).
    // 정답 자카드는 0.182로 임계 아래였다 — **지표는 하한이다.**
    // 용어 정의는 1.1.1이 소유하므로 4.1.6 쪽을 그 목표의 미출제 축
    // 「인구통계 집단에 미치는 영향」으로 돌렸다(정답 인덱스 3 불변).
    test('q12가 과적합의 이름·변동을 다시 묻지 않는다', () {
      final x = q('aif-t4-1-q12');
      final asked = '${x['stem']} ${(x['options'] as List).join(' ')}';
      for (final s in ['높은 변동', '높은 편향', '과소적합이고', '과적합이고']) {
        expect(asked.contains(s), isFalse, reason: s);
      }
    });

    test('q12가 공식 과적합 예시의 인구통계 축을 묻는다', () {
      final x = q('aif-t4-1-q12');
      // "the prediction accuracy of this overfit algorithm drops for public
      // universities, as their student demographics aren't reflected in the
      // training data."
      expect(x['stem'], contains('사립대'));
      expect(correctOption(x), contains('인구통계'));
      expect(correctOption(x), contains('떨어집니다'));
      expect(sourceUrls(x), contains(contains('aws.amazon.com/what-is/overfitting/')));
    });

    test('대조군: 용어 정의를 소유한 쪽(목표 1.1.1)은 그대로 과적합을 묻는다', () {
      final x = q('aif-t1-1-q1');
      expect(x['skill'], '1.1.1');
      expect(correctOption(x), contains('과적합'));
    });

    test('목표 4.1.6의 두 문항이 서로 다른 축을 묻는다', () {
      final both = questions('aif-t4-1').where((x) => x['skill'] == '4.1.6').toList();
      expect(both.length, greaterThanOrEqualTo(2));
      final demographic =
          both.where((x) => allText(x).contains('인구통계')).toList();
      expect(demographic, isNotEmpty,
          reason: '목표 4.1.6의 예 「인구통계학적 그룹에 미치는 영향」');
    });
  });

  // ═════════════════════ 출처 구조 불변식 ═════════════════════

  group('출처 구조 (전수)', () {
    test('문항 출처는 그 Task 학습문서 프런트매터 출처의 부분집합이다', () {
      final offenders = <String>[];
      for (final t in taskIds) {
        final fm = frontmatterUrls(t);
        expect(fm.length, greaterThanOrEqualTo(8), reason: '대조군 — $t 프런트매터');
        for (final x in questions(t)) {
          for (final u in sourceUrls(x)) {
            if (!fm.contains(u)) offenders.add('${x['id']}: $u');
          }
        }
      }
      expect(offenders, isEmpty);
    });

    test('이번에 더한 프런트매터 출처가 참고자료 절에도 있다', () {
      // ⚠️ 프런트매터에만 넣고 참고자료 절을 빠뜨리면 학습자는 그 출처를 못 본다.
      const added = <String, List<String>>{
        'aif-t3-1': [
          'aws.amazon.com/what-is/vector-databases/',
          'docs.aws.amazon.com/bedrock/latest/userguide/prequisites-model-distillation.html',
        ],
        'aif-t4-1': [
          'docs.aws.amazon.com/wellarchitected/latest/framework/sus01-bp03.html',
          'docs.aws.amazon.com/bedrock/latest/userguide/guardrails-deploy.html',
        ],
      };
      added.forEach((t, urls) {
        final raw = md(t);
        for (final u in urls) {
          expect(frontmatterUrls(t), contains('https://$u'), reason: '$t 프런트매터');
          expect(raw, contains('`$u`'), reason: '$t 참고자료 절');
        }
      });
    });

    test('프런트매터의 sources 목록이 lastVerified까지 끊기지 않는다', () {
      // 목록 중간에 최상위 키가 끼면 파서가 뒤쪽 출처를 조용히 버린다
      // (2026-11-11 SCS 라이브 결함).
      for (final t in taskIds) {
        final raw = md(t).replaceAll('\r\n', '\n');
        final fm = raw.substring(4, raw.indexOf('\n---\n', 4)).split('\n');
        final start = fm.indexOf('sources:');
        expect(start, greaterThan(0), reason: t);
        var i = start + 1;
        while (i < fm.length &&
            (fm[i].startsWith('  - title: ') || fm[i].startsWith('    url: '))) {
          i++;
        }
        expect(fm[i], startsWith('lastVerified: '), reason: t);
        expect(i, fm.length - 1, reason: '$t: lastVerified가 프런트매터의 마지막 줄');
      }
    });
  });
}
