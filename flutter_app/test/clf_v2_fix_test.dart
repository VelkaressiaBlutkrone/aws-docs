import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 2026-11-17 전 콘텐츠 검증 2단계(보정) — CLF-C02 · DVA-C03.
///
/// 집행한 보고서: `docs/audits/2026-11-17-full-verify/clf-dva.md`
/// 반영 보고서: `docs/audits/2026-11-17-full-verify/clf-dva-phase2.md`
///
/// ## 무엇을 지키는가
///
/// - **Support 플랜(C-R1·C-R2·C-Y6·C-Y7)** — 현행 공식 플랜은 넷이다(Basic · AWS Business
///   Support+ · AWS Enterprise Support · AWS Unified Operations). `aws-support-plans.html` 이
///   Enterprise 에 `A designated Technical Account Manager (TAM).` 을, Unified Operations 에
///   `Designated AWS Technical Account Manager (TAM) and Domain Specialist Engineer (DSE)` 를
///   적고, 비교표(`premiumsupport/plans/`)의 「Business/Mission-critical system down」 행이
///   Enterprise `< 15 mins` · Unified Operations `< 5 mins` 다. 그래서 **「Enterprise = 최상위」·
///   「TAM 은 Enterprise 에서만」·「가장 빠른 응답 = Enterprise」 셋이 거짓**이다. 공식 가이드
///   작업 4.3 의 지원 옵션 예시에 Developer Support 가 없으므로 「시험 가이드 기준 업무 시간
///   지원 플랜」 귀속도 거짓이다.
/// - **닫힌 서비스 상태(C-Y1·C-Y2·C-Y3)** — Snowball Edge · Simple AD · FSx File Gateway.
/// - **출처(C-Y4·C-Y5)** — 가이드 **개요** 페이지에는 Task 기술 문구가 없다(도메인 페이지에
///   있다). 여덟 문항은 인용 페이지가 그 사실을 담지 않았다.
/// - **DVA** — 역할 체이닝 1시간 상한은 콘솔에도 적용된다(`id_roles.html`:
///   `Role chaining limits your AWS Management Console, AWS CLI or AWS API role session to a
///   maximum of one hour.`). Bedrock Agents Classic · X-Ray SDK 유지 관리 상태 등.
///
/// ## 가드 설계
///
/// - 사실 단정은 **전수 집계형**이다(md 줄 · 문항 전체 · **대본의 발화 본문**). 문항별 리터럴
///   가드는 어형 하나로 뚫린다.
/// - **옛 문구 0건 + 새 공식 사실 있음**을 쌍으로 단정한다.
/// - ⚠️ `verified` · `reviewStatus` 는 **단정하지 않는다**(사람의 서명 영역). 구조 단정
///   (보기 4개 · 정답 인덱스 불변)으로 대신한다.
/// - ⚠️ **기각한 판정도 고정한다** — 「미션 크리티컬 환경이 Enterprise 의 TAM 과 짧은 응답
///   목표를 얻는다」는 거짓이 아니다(공식 비교표의 15분 행 이름이 `Business/Mission-critical
///   system down` 이다). 탐지기가 그 서술을 걸지 않는 것을 대조군으로 둔다.
void main() {
  const clfDir = 'assets/content/clf';
  const dvaDir = 'assets/content/dva';
  const audioDir = 'assets/audio/clf';
  const guideBase =
      'https://docs.aws.amazon.com/ko_kr/aws-certification/latest/cloud-practitioner-02/';
  const overviewUrl = '${guideBase}cloud-practitioner-02.html';

  String base(File f) => f.path.replaceAll(r'\', '/').split('/').last;

  List<File> filesOf(String dir, String suffix) => Directory(dir)
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith(suffix))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  String clfDoc(String id) => File('$clfDir/$id.md').readAsStringSync();
  String dvaDoc(String id) => File('$dvaDir/$id.md').readAsStringSync();

  List<Map<String, dynamic>> allQuestions() => [
        for (final f in filesOf(clfDir, '.questions.json'))
          ...((json.decode(f.readAsStringSync()) as Map<String, dynamic>)['questions']
                  as List)
              .cast<Map<String, dynamic>>(),
      ];

  Map<String, dynamic> question(String qid) => allQuestions()
      .firstWhere((q) => q['id'] == qid, orElse: () => fail('$qid 없음'));

  List<String> urls(Map<String, dynamic> q) => (q['sources'] as List)
      .map((s) => (s as Map<String, dynamic>)['url'] as String)
      .toList();

  List<String> titles(Map<String, dynamic> q) => (q['sources'] as List)
      .map((s) => (s as Map<String, dynamic>)['title'] as String? ?? '')
      .toList();

  /// 학습자에게 렌더되는 본문(출처 제목 제외).
  String bodyText(Map<String, dynamic> q) => <String>[
        q['stem'] as String? ?? '',
        q['explanation'] as String? ?? '',
        ...(q['options'] as List).cast<String>(),
        ...(q['wrongExplanations'] as Map<String, dynamic>).values.cast<String>(),
      ].join('\n');

  String allText(Map<String, dynamic> q) =>
      '${bodyText(q)}\n${titles(q).join('\n')}';

  /// 가르치는 층 — 지문 · 정답 보기 · 해설. 오답 보기와 그 반박문은 뺀다.
  String teachingText(Map<String, dynamic> q) => <String>[
        q['stem'] as String? ?? '',
        (q['options'] as List).cast<String>()[q['correct'] as int],
        q['explanation'] as String? ?? '',
      ].join('\n');

  /// 대본의 **발화 본문** — `gen_lecture_audio.py` 의 `_spoken_body` 와 같은 우선순위.
  /// `sourceExcerpt` 는 읽지 않는다(발화되지 않는다).
  List<({String docId, String segId, String text})> spokenSegments() {
    final out = <({String docId, String segId, String text})>[];
    final dirs = Directory(audioDir).listSync().whereType<Directory>().toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    for (final d in dirs) {
      final f = File('${d.path}/script.json');
      if (!f.existsSync()) continue;
      final docId = d.path.replaceAll(r'\', '/').split('/').last;
      final map = json.decode(f.readAsStringSync()) as Map<String, dynamic>;
      for (final seg in (map['segments'] as List).cast<Map<String, dynamic>>()) {
        if (seg['skip'] == true) continue;
        final body = seg['kind'] == 'table'
            ? (seg['audioSummary'] as String? ?? '')
            : (seg['enrichedScriptText'] as String? ??
                seg['scriptText'] as String? ??
                '');
        if (body.isEmpty) continue;
        out.add((docId: docId, segId: seg['id'] as String? ?? '?', text: body));
      }
    }
    return out;
  }

  String spoken(String docId, String segId) => spokenSegments()
      .firstWhere((s) => s.docId == docId && s.segId == segId,
          orElse: () => fail('$docId/$segId 없음'))
      .text;

  /// CLF md 줄 · 문항 전체 · 대본 발화 본문을 한 규칙으로 센다.
  List<String> sweepClf(RegExp re, {bool withSpoken = true}) {
    final hits = <String>[];
    for (final f in filesOf(clfDir, '.md')) {
      final lines = f.readAsStringSync().split('\n');
      for (var i = 0; i < lines.length; i++) {
        if (re.hasMatch(lines[i])) hits.add('${base(f)}:${i + 1}');
      }
    }
    for (final q in allQuestions()) {
      if (re.hasMatch(allText(q))) hits.add(q['id'] as String);
    }
    if (withSpoken) {
      for (final s in spokenSegments()) {
        if (re.hasMatch(s.text)) hits.add('${s.docId}/${s.segId}');
      }
    }
    return hits..sort();
  }

  List<String> sweepDva(RegExp re) {
    final hits = <String>[];
    for (final f in filesOf(dvaDir, '.md')) {
      final lines = f.readAsStringSync().split('\n');
      for (var i = 0; i < lines.length; i++) {
        if (re.hasMatch(lines[i])) hits.add('${base(f)}:${i + 1}');
      }
    }
    return hits;
  }

  /// 프런트매터의 `sources` URL 목록 — 파서와 같은 방식으로 **연속 블록만** 읽는다.
  List<String> frontmatterUrls(String md) {
    final lines = md.replaceAll('\r\n', '\n').split('\n');
    final start = lines.indexOf('sources:');
    if (start < 0) return const [];
    final out = <String>[];
    for (var i = start + 1; i < lines.length; i++) {
      final l = lines[i];
      if (!l.startsWith('  ')) break;
      if (l.startsWith('    url: ')) out.add(l.substring('    url: '.length).trim());
    }
    return out;
  }

  // ═════════════════════ 대조군 ═════════════════════

  group('대조군 — 콘텐츠가 읽혔다', () {
    test('CLF 문항·학습문서·대본, DVA 학습문서가 읽힌다', () {
      final qs = allQuestions();
      expect(qs.length, greaterThan(250), reason: '0건 통과가 파일을 못 읽어서일 수 있다');
      for (final q in qs) {
        expect((q['options'] as List).length, 4, reason: '${q['id']}');
      }
      expect(filesOf(clfDir, '.md').length, 19);
      expect(filesOf(dvaDir, '.md').length, 12);
      expect(spokenSegments().where((s) => s.docId == 'clf-t4-3').length,
          greaterThan(20));
    });

    test('손댄 43문항의 정답 인덱스가 불변이다', () {
      // ⚠️ 보고서가 아니라 **문항 파일에서 읽은 실측값**이다(2026-11-17).
      const correct = <String, int>{
        'clf-t4-3-q1': 0, 'clf-t4-3-q2': 0, 'clf-t4-3-q3': 0, 'clf-t4-3-q4': 0,
        'clf-t4-3-q5': 0, 'clf-t4-3-q6': 0, 'clf-t4-3-q7': 0, 'clf-t4-3-q8': 2,
        'clf-t4-3-q9': 0, 'clf-t4-3-q10': 2, 'clf-t4-3-q11': 0, 'clf-t4-3-q13': 0,
        'clf-t4-3-q14': 0, 'clf-t4-3-q15': 0, 'clf-t1-1-q13': 1, 'clf-t1-3-q3': 0,
        'clf-t1-3-q8': 1, 'clf-t1-3-q9': 0, 'clf-t1-3-q14': 0, 'clf-t1-4-q8': 2,
        'clf-t2-2-q15': 0, 'clf-t2-4-q15': 0, 'clf-t3-1-q4': 0, 'clf-t3-1-q12': 0,
        'clf-t3-1-q14': 0, 'clf-t3-1-q15': 0, 'clf-t3-2-q8': 2, 'clf-t3-2-q11': 0,
        'clf-t3-2-q12': 0, 'clf-t3-2-q14': 0, 'clf-t3-3-q4': 0, 'clf-t3-4-q11': 0,
        'clf-t3-8-q11': 0, 'clf-t3-8-q15': 0, 'clf-t4-1-q2': 0, 'clf-t4-1-q4': 0,
        'clf-t4-1-q5': 0, 'clf-t4-1-q13': 0, 'clf-t4-1-q15': 0, 'clf-t4-2-q6': 0,
        'clf-t4-2-q10': 1, 'clf-t4-2-q12': 0, 'clf-t4-2-q15': 0,
      };
      expect(correct.length, 43);
      correct.forEach((qid, c) {
        expect(question(qid)['correct'], c, reason: '$qid 의 정답 인덱스는 바꾸지 않는다');
      });
    });
  });

  // ═════════════════════ C-R1 Support 플랜 사다리 ═════════════════════

  group('C-R1 Enterprise 는 최상위 플랜이 아니다 (md·문항·발화 전수)', () {
    final topRe = RegExp(r'최상위[^.\n]{0,12}플랜|최상위\s*Enterprise');
    final tamOnlyRe =
        RegExp(r'(Enterprise|엔터프라이즈)\s*플랜(에서만|에만)\s*(포함|제공)');
    final fastestRe = RegExp(r'가장 빠른[^.\n]{0,20}응답');

    test('「최상위 플랜」 0건', () {
      final hits = sweepClf(topRe);
      expect(hits, isEmpty,
          reason: '현행 4플랜에서 Enterprise 위에 AWS Unified Operations 가 있다: '
              '${hits.join(', ')}');
    });

    test('「TAM 은 Enterprise 플랜에서만」 0건', () {
      final hits = sweepClf(tamOnlyRe);
      expect(hits, isEmpty,
          reason: 'Unified Operations 도 전담 TAM 을 포함한다: ${hits.join(', ')}');
    });

    test('「가장 빠른 응답」 0건', () {
      final hits = sweepClf(fastestRe);
      expect(hits, isEmpty,
          reason: 'Enterprise 15분보다 빠른 Unified Operations 5분 응답이 있다: '
              '${hits.join(', ')}');
    });

    test('대조군: 탐지기가 옛 문구는 잡고 참인 서술은 걸지 않는다', () {
      expect(topRe.hasMatch('전담 TAM 등을 포함하는 최상위 유료 플랜으로'), isTrue);
      expect(topRe.hasMatch('최상위 Enterprise 플랜을 유지해야'), isTrue);
      expect(tamOnlyRe.hasMatch('엔터프라이즈 플랜에만 포함됩니다'), isTrue);
      expect(tamOnlyRe.hasMatch('Enterprise 플랜에서만 포함된다'), isTrue);
      expect(fastestRe.hasMatch('가장 빠른(약 15분) 응답이 필요하다'), isTrue);
      // 참 — 고치지 않는다.
      expect(topRe.hasMatch('엣지 로케이션이 리전을 담는 최상위 단위가 아니며'), isFalse);
      expect(tamOnlyRe.hasMatch('전담 TAM(Technical Account Manager)은 Enterprise 플랜'),
          isFalse);
      expect(tamOnlyRe.hasMatch('Enterprise에서만 제공되는 것이 아니라 Business 플랜부터'),
          isFalse);
    });

    test('기각 판정 고정: 「미션 크리티컬 → Enterprise 의 TAM·짧은 응답」은 남아 있다', () {
      // 공식 비교표의 15분 행 이름이 `Business/Mission-critical system down` 이다 —
      // 이 서술은 거짓이 아니므로 지우지 않았다(대본 seg009·seg015 도 그대로다).
      final t = clfDoc('t4-3');
      expect(t.contains('미션 크리티컬 환경은 Enterprise의 전담 TAM과 짧은 응답 목표'), isTrue);
      expect(spoken('clf-t4-3', 'seg015').contains('엔터프라이즈의 전담 티에이엠'), isTrue);
    });

    test('t4-3.md 가 Unified Operations 를 사다리 위에 둔다', () {
      final t = clfDoc('t4-3');
      expect(
          t.contains('Basic 무료 → Business Support+ → Enterprise TAM → Unified Operations'),
          isTrue);
      final uoLine = t.split('\n').where(
          (l) => l.contains('Unified Operations') && l.contains('5분 응답'));
      expect(uoLine, isNotEmpty, reason: '공식: "A five-minute, context-aware response"');
      expect(t.contains('Enterprise Support부터 포함된다'), isTrue,
          reason: 'TAM 의 하한은 Enterprise 이고 상한은 아니다');
      final fm = frontmatterUrls(t);
      expect(fm, contains('https://aws.amazon.com/premiumsupport/plans/'));
      expect(
          fm,
          contains(
              'https://docs.aws.amazon.com/awssupport/latest/user/unified-operations-intro.html'));
    });

    test('clf-t4-3-q3: 지문에서 최상급이 빠지고 해설이 Unified Operations 를 적는다', () {
      final q = question('clf-t4-3-q3');
      final stem = q['stem'] as String;
      expect(stem.contains('약 15분 응답'), isTrue);
      expect(stem.contains('TAM'), isTrue, reason: '문항이 묻는 것은 그대로다');
      final e = q['explanation'] as String;
      expect(e.contains('Unified Operations'), isTrue);
      expect(e.contains('5분'), isTrue);
      expect(urls(q), contains('https://aws.amazon.com/premiumsupport/plans/'),
          reason: '15분·5분·1시간 응답 목표 표는 비교 페이지에 있다');
    });

    test('발화: 고친 세그먼트가 Unified Operations 를 말하고 단종 공지는 유지된다', () {
      for (final id in ['seg006', 'seg014', 'seg030', 'seg033']) {
        expect(spoken('clf-t4-3', id).contains('유니파이드 오퍼레이션스'), isTrue,
            reason: id);
      }
      expect(spoken('clf-t4-3', 'seg033').contains('엔터프라이즈 플랜부터 포함'), isTrue);
      // ⚠️ seg030 의 단종 문장은 공식과 일치한다 — 지키는 문장이다(2026-11-06 판정).
      expect(spoken('clf-t4-3', 'seg030').contains('2027년 1월 1일에 단종'), isTrue);
    });
  });

  // ═════════════════════ C-R2 · C-Y7 귀속·단정 ═════════════════════

  group('C-R2·C-Y7 시험 가이드 귀속과 출제 단정', () {
    final examClaimRe =
        RegExp(r'시험은[^.\n]{0,40}전통[^.\n]{0,40}출제|시험 전통 분류 기준|시험 대비로는 전통');
    final signupRe = RegExp(r'신규 가입[^.\n]{0,12}종료');

    test('「시험 가이드 기준」 0건', () {
      final hits = sweepClf(RegExp(r'시험 가이드 기준'));
      expect(hits, isEmpty,
          reason: '공식 작업 4.3 의 지원 옵션 예시에 Developer Support 가 없다: '
              '${hits.join(', ')}');
    });

    test('「시험은 전통 분류로 출제된다」류 단정 0건', () {
      final hits = sweepClf(examClaimRe);
      expect(hits, isEmpty, reason: '근거를 제시할 수 없는 단정이다: ${hits.join(', ')}');
    });

    test('「신규 가입 종료」 0건 — 공식 문구는 2027-01-01 단종이다', () {
      final hits = sweepClf(signupRe);
      expect(hits, isEmpty,
          reason: '`aws-support-plans.html`·`support-plans-eos.html` 에 신규 가입 차단 '
              '서술이 없다: ${hits.join(', ')}');
      expect(clfDoc('t4-3').contains('2027-01-01 단종 공지'), isTrue);
      expect(spoken('clf-t4-3', 'seg031').contains('2027년 1월 1일에 단종한다는 공지'),
          isTrue);
    });

    test('대조군: 탐지기 민감도와 기각한 학습 조언', () {
      expect(examClaimRe.hasMatch('시험은 전통 분류(Basic·Developer) 기준으로 출제되며'),
          isTrue);
      expect(signupRe.hasMatch('신규 가입을 종료한다는 공지'), isTrue);
      // 학습 조언은 AWS 사실에 대한 서술이 아니다 — seg014·seg026 은 고치지 않았다.
      expect(
          examClaimRe.hasMatch('시험을 준비할 때는 전통적인 분류 기준으로, 비즈니스 플랜을'),
          isFalse);
    });

    test('clf-t4-3-q13: 정답 보기에서 거짓 귀속이 빠지고 길이 단서가 생기지 않았다', () {
      final q = question('clf-t4-3-q13');
      final opts = (q['options'] as List).cast<String>();
      final right = opts[q['correct'] as int].length;
      final wrong = [
        for (var i = 0; i < 4; i++)
          if (i != q['correct']) opts[i].length
      ]..sort();
      expect(right, greaterThanOrEqualTo(wrong.first),
          reason: '괄호만 걷으면 정답이 최단이 되어 반대 방향 단서가 된다');
      expect(right, lessThanOrEqualTo((wrong.last * 1.3).floor()));
      final e = q['explanation'] as String;
      expect(e.contains('Business Support+'), isTrue);
      expect(e.contains('2027-01-01'), isTrue);
    });
  });

  // ═════════════════════ C-Y6 출처 ═════════════════════

  group('C-Y6 Support 문항의 출처가 그 사실을 담는 페이지다', () {
    test('clf-t4-3-q10: Support API 요건은 about-support-api 페이지에 있다', () {
      final q = question('clf-t4-3-q10');
      expect(
          urls(q),
          contains(
              'https://docs.aws.amazon.com/awssupport/latest/user/about-support-api.html'),
          reason: '공식: "You must have a AWS Business Support+, AWS Enterprise Support, '
              'or AWS Unified Operations plan to use the AWS Support API."');
      expect(urls(q).any((u) => u.endsWith('/getting-started.html')), isFalse,
          reason: '그 페이지 본문에 Support API 가 0건이다');
    });

    test('clf-t4-3-q1: Trusted Advisor 핵심 점검의 근거는 Trusted Advisor 페이지다', () {
      final q = question('clf-t4-3-q1');
      expect(
          urls(q),
          contains(
              'https://docs.aws.amazon.com/awssupport/latest/user/trusted-advisor.html'));
    });

    test('clf-t4-3-q6: Developer Support 의 제공 범위는 그 플랜 페이지에 있다', () {
      final q = question('clf-t4-3-q6');
      expect(urls(q), contains('https://aws.amazon.com/premiumsupport/plans/developers/'),
          reason: '`aws-support-plans.html` 은 이제 단종 공지만 적는다');
    });

    test('Support 문항의 출처 제목에 낡은 플랜 묶음이 없다', () {
      final stale = <String>[];
      for (final q in allQuestions()) {
        for (final t in titles(q)) {
          if (t.contains('Basic/Developer') ||
              t.contains('Enterprise On-Ramp/Enterprise') ||
              t.contains('Enterprise TAM)')) {
            stale.add(q['id'] as String);
          }
        }
      }
      expect(stale, isEmpty, reason: stale.join(', '));
    });
  });

  // ═════════════════════ C-Y1 · C-Y2 · C-Y3 닫힌 서비스 ═════════════════════

  group('C-Y1 AWS Snowball — 상태를 가르치는 층에 적는다', () {
    test('Snowball 을 가르치는 문항은 해설에 상태가 있고 제품 페이지를 든다', () {
      final teach = allQuestions()
          .where((q) => teachingText(q).contains('Snowball'))
          .toList();
      expect(teach.length, greaterThanOrEqualTo(4), reason: '0건이면 단정이 공허하다');
      final offenders = <String>[];
      for (final q in teach) {
        final e = q['explanation'] as String;
        if (!e.contains('신규 고객') ||
            !e.contains('2026-12-31') ||
            !urls(q).contains('https://aws.amazon.com/snowball/')) {
          offenders.add(q['id'] as String);
        }
      }
      expect(offenders, isEmpty,
          reason: '공식: "AWS Snowball Edge is no longer available to new customers" · '
              '"On December 31, 2026, AWS will discontinue support": ${offenders.join(', ')}');
    });

    test('대조군: 오답 보기로만 나오는 문항이 따로 있고 거기엔 상태를 달지 않았다', () {
      // 틀린 보기를 반박하는 문장에 상태를 달면 그 상태가 오답 이유처럼 읽힌다.
      final wrongOnly = allQuestions().where((q) =>
          !teachingText(q).contains('Snowball') && bodyText(q).contains('Snowball'));
      expect(wrongOnly.length, greaterThanOrEqualTo(5));
      for (final q in wrongOnly) {
        expect((q['explanation'] as String).contains('2026-12-31'), isFalse,
            reason: '${q['id']}');
      }
    });

    test('t1-3.md 의 정직성 메모가 가정법이 아니라 공식 단정이다', () {
      final t = clfDoc('t1-3');
      expect(t.contains('신규 고객 등록이 제한'), isFalse);
      expect(t.contains('Snowball Edge는 신규 고객에게 제공되지 않습니다'), isTrue);
      expect(t.contains('AWS Data Transfer Terminal'), isTrue);
      expect(t.contains('2026-12-31'), isTrue);
      expect(frontmatterUrls(t), contains('https://aws.amazon.com/snowball/'));
    });
  });

  group('C-Y2·C-Y3 Simple AD · FSx File Gateway', () {
    test('CLF md 에서 그 이름을 적는 줄은 상태를 함께 적는다', () {
      final offenders = <String>[];
      var seen = 0;
      for (final f in filesOf(clfDir, '.md')) {
        final lines = f.readAsStringSync().split('\n');
        for (var i = 0; i < lines.length; i++) {
          final l = lines[i];
          if (!l.contains('Simple AD') && !l.contains('FSx File Gateway')) continue;
          seen++;
          if (!l.contains('신규 고객')) offenders.add('${base(f)}:${i + 1}');
        }
      }
      expect(seen, greaterThanOrEqualTo(2), reason: '대조군 — 두 이름이 실제로 나온다');
      expect(offenders, isEmpty,
          reason: '공식: "Simple AD is no longer open to new customers." · '
              '"Amazon FSx File Gateway is no longer available to new customers.": '
              '${offenders.join(', ')}');
    });
  });

  // ═════════════════════ C-Y4 가이드 개요 페이지 ═════════════════════

  group('C-Y4 Task 기술의 출처는 도메인 페이지다', () {
    test('문항이 가이드 개요 페이지를 인용하지 않는다', () {
      final hits = [
        for (final q in allQuestions())
          if (urls(q).contains(overviewUrl)) q['id'] as String
      ];
      expect(hits, isEmpty,
          reason: '개요 페이지는 서론·형식·비중만 담고 Task 기술 문구는 도메인 페이지에 '
              '있다: ${hits.join(', ')}');
    });

    test('옮긴 20문항이 정본을 들고 있다', () {
      const moved = <String, String>{
        'clf-t2-2-q15': '${guideBase}cloud-practitioner-02-domain2.html',
        'clf-t2-4-q15': '${guideBase}cloud-practitioner-02-domain2.html',
        'clf-t3-1-q4': '${guideBase}cloud-practitioner-02-domain3.html',
        'clf-t3-1-q12': '${guideBase}cloud-practitioner-02-domain3.html',
        'clf-t3-1-q14': '${guideBase}cloud-practitioner-02-domain3.html',
        'clf-t3-1-q15': '${guideBase}cloud-practitioner-02-domain3.html',
        'clf-t3-2-q11': '${guideBase}cloud-practitioner-02-domain3.html',
        // 공식 3.2 기술에 「가격」이 없다 — 리전별 요금 차이는 Well-Architected 가 적는다.
        'clf-t3-2-q12':
            'https://docs.aws.amazon.com/wellarchitected/latest/framework/cost07-bp02.html',
        'clf-t3-4-q11': '${guideBase}cloud-practitioner-02-domain3.html',
        'clf-t3-8-q15': '${guideBase}cloud-practitioner-02-domain3.html',
        'clf-t4-1-q4': '${guideBase}cloud-practitioner-02-domain4.html',
        'clf-t4-1-q13': '${guideBase}cloud-practitioner-02-domain4.html',
        'clf-t4-2-q6': '${guideBase}cloud-practitioner-02-domain4.html',
        'clf-t4-2-q15': '${guideBase}cloud-practitioner-02-domain4.html',
        'clf-t4-3-q4': '${guideBase}cloud-practitioner-02-domain4.html',
        'clf-t4-3-q5': '${guideBase}cloud-practitioner-02-domain4.html',
        'clf-t4-3-q8': '${guideBase}cloud-practitioner-02-domain4.html',
        'clf-t4-3-q9': '${guideBase}cloud-practitioner-02-domain4.html',
        'clf-t4-3-q14': '${guideBase}cloud-practitioner-02-domain4.html',
        'clf-t4-3-q15': '${guideBase}cloud-practitioner-02-domain4.html',
      };
      expect(moved.length, 20);
      moved.forEach((qid, url) {
        expect(urls(question(qid)), contains(url), reason: qid);
      });
    });

    test('출처 제목이 공식에 없는 예시를 싣지 않는다', () {
      // 공식 2.4: Knowledge Center · Security Center · Security Blog (re:Post 없음)
      // ⚠️ 가이드에 귀속한 제목만 본다 — 둘째 출처 「AWS re:Post Knowledge Center」는
      // Knowledge Center 가 실제로 있는 곳이라 정당하다(전체 제목으로 세면 그 줄이 걸린다).
      final t24 = titles(question('clf-t2-4-q15'))
          .where((t) => t.contains('공식 시험 가이드'))
          .join('\n');
      expect(t24.contains('AWS Security Center'), isTrue);
      expect(t24.contains('re:Post'), isFalse);
      // 공식 3.2 다중 리전 예시에 가격이 없다.
      expect(titles(question('clf-t3-2-q12')).join('\n').contains('가격 포함'), isFalse);
      expect(titles(question('clf-t4-3-q5')).join('\n').contains('Partner-Led'), isFalse);
    });

    test('학습문서 19편의 프런트매터가 자기 도메인 페이지를 든다', () {
      for (final f in filesOf(clfDir, '.md')) {
        final md = f.readAsStringSync();
        final domain = RegExp(r'^domain: (\d)', multiLine: true).firstMatch(md)!.group(1);
        expect(frontmatterUrls(md),
            contains('${guideBase}cloud-practitioner-02-domain$domain.html'),
            reason: base(f));
      }
    });
  });

  // ═════════════════════ C-Y5 인용 페이지가 사실을 담는다 ═════════════════════

  group('C-Y5 인용 페이지가 그 사실을 담는다', () {
    const docs = 'https://docs.aws.amazon.com';
    const ec2Raz = '$docs/AWSEC2/latest/UserGuide/using-regions-availability-zones.html';
    const required = <String, String>{
      'clf-t1-1-q13': 'https://aws.amazon.com/what-is/virtualization/',
      'clf-t3-2-q8': '$docs/global-infrastructure/latest/regions/aws-regions.html',
      'clf-t3-2-q11': '$docs/global-infrastructure/latest/regions/aws-regions.html',
      'clf-t3-2-q14':
          '$docs/global-infrastructure/latest/regions/aws-regions-availability-zones.html',
      'clf-t3-3-q4': '$docs/eks/latest/userguide/fargate.html',
      'clf-t4-1-q2': '$docs/savingsplans/latest/userguide/plan-types.html',
      'clf-t4-1-q5': '$docs/savingsplans/latest/userguide/sp-ris.html',
      'clf-t4-1-q15': '$docs/AWSEC2/latest/UserGuide/reserved-instances-types.html',
    };
    required.forEach((qid, url) {
      test('$qid 가 정본을 든다', () {
        expect(urls(question(qid)), contains(url));
      });
    });

    test('사실을 담지 않던 옛 출처가 그 문항에서 빠졌다', () {
      for (final qid in ['clf-t3-2-q8', 'clf-t3-2-q11', 'clf-t3-2-q14']) {
        expect(urls(question(qid)), isNot(contains(ec2Raz)), reason: qid);
      }
      expect(urls(question('clf-t4-1-q15')),
          isNot(contains('$docs/AWSEC2/latest/UserGuide/concepts.html')),
          reason: '그 페이지에 Convertible 이 0건이다');
    });

    test('clf-t1-4-q8: 출처 제목이 그 페이지에 없는 TCO·숨은 비용을 귀속하지 않는다', () {
      final t = titles(question('clf-t1-4-q8')).join('\n');
      expect(t.contains('TCO 추정'), isFalse);
      expect(t.contains('숨은 비용'), isFalse);
      expect(t.contains('온프레미스 환경과 관련된 비용 이해'), isTrue,
          reason: '공식 작업 1.4 기술');
    });

    test('clf-t3-3-q4: 「서버리스」의 근거는 공식 가이드이고 ECS 페이지에 귀속하지 않는다', () {
      // ECS `AWS_Fargate.html` 본문에 `serverless` 가 0건이다 — 그 페이지가 적는 것은
      // "run containers without having to manage servers or clusters of Amazon EC2 instances".
      // Fargate 를 서버리스로 분류하는 것은 공식 가이드 작업 3.3 기술이다.
      final q = question('clf-t3-3-q4');
      final ecsTitle = (q['sources'] as List)
          .cast<Map<String, dynamic>>()
          .firstWhere((s) => (s['url'] as String).endsWith('/AWS_Fargate.html'))['title']
          as String;
      expect(ecsTitle.contains('서버리스'), isFalse);
      expect(urls(q), contains('${guideBase}cloud-practitioner-02-domain3.html'));
      expect(titles(q).join('\n').contains('서버리스 컴퓨팅 옵션'), isTrue,
          reason: '공식 3.3: 「다양한 서버리스 컴퓨팅 옵션의 적절한 사용 이해(예: AWS Fargate, AWS Lambda)」');
    });

    test('2026-11-17 에 404 인 WA 슬러그를 쓰지 않는다', () {
      // `framework/cost_pricing_model_region_cost.html` 은 재구성으로 지워졌다(404 r=0).
      final hits = sweepClf(RegExp(r'framework/cost_pricing_model_region_cost'),
          withSpoken: false);
      expect(hits, isEmpty);
    });
  });

  // ═════════════════════ C-Y8 ~ C-Y13 학습문서 정합 ═════════════════════

  group('C-Y8~C-Y13 학습문서 정합', () {
    test('C-Y8 t1-2: 「공식 원문」이 인용 페이지에 실재하는 문장이다', () {
      final t = clfDoc('t1-2');
      expect(t.contains('the six pillars of operational excellence'), isFalse);
      expect(
          t.contains('The AWS Well-Architected Framework is based on the following six pillars:'),
          isTrue,
          reason: '`framework/definitions.html` 의 문장');
    });

    test('C-Y9 범위 외 세 서비스에 범위 메모가 붙었다', () {
      const where = {'t3-1': 'CodeDeploy', 't3-2': 'Wavelength', 't3-7': 'Personalize'};
      where.forEach((doc, name) {
        final memo = clfDoc(doc).split('\n').where((l) =>
            l.contains('범위 메모') && l.contains(name) && l.contains('범위 외'));
        expect(memo, isNotEmpty,
            reason: '$name 은 공식 「범위 외 AWS 서비스」 목록에 이름으로 있다 ($doc)');
      });
    });

    test('C-Y10 t3-8: CloudShell 을 「범주만 매칭」으로 묶지 않는다', () {
      final bad = clfDoc('t3-8').split('\n').where((l) =>
          l.contains('CloudShell') && l.contains('범주만') && !l.contains('범위 외'));
      expect(bad, isEmpty);
    });

    test('C-Y11 t4-2: 문항이 묻는 태그 두 유형·활성화가 본문에 있다', () {
      final t = clfDoc('t4-2');
      expect(t.contains('aws:createdBy'), isTrue);
      expect(t.contains('AWS 생성 태그'), isTrue);
      expect(t.contains('각각 활성화'), isTrue);
      expect(question('clf-t4-2-q10')['section'], 'cost-tracking');
      expect(t.contains('{#cost-tracking}'), isTrue, reason: '그 앵커가 실재한다');
    });

    test('C-Y12 t4-1: 구매 옵션 개수를 단정하지 않고 전용 인스턴스를 싣는다', () {
      final t = clfDoc('t4-1');
      expect(RegExp(r'구매 옵션\s*6종').hasMatch(t), isFalse,
          reason: '공식 4.1 지식은 일곱을 든다(전용 인스턴스 포함)');
      final row = t.split('\n').where((l) => l.startsWith('| **Dedicated Instances**'));
      expect(row, isNotEmpty);
      expect(row.first.contains('단일 계정 전용 하드웨어'), isTrue,
          reason: '공식: "run on hardware that\'s dedicated to a single AWS account"');
      expect(
          frontmatterUrls(t),
          contains(
              'https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/dedicated-instance.html'));
    });

    test('C-Y13 t1-3: 가이드 인용이 공식 문구 그대로다', () {
      final t = clfDoc('t1-3');
      expect(t.contains('전략적 마이그레이션 사례 파악'), isFalse);
      expect(t.contains('적절한 마이그레이션 전략 파악'), isTrue);
    });

    test('문항 본문에 백틱이 없다 (평문 Text 로 렌더된다)', () {
      final hits = [
        for (final q in allQuestions())
          if (bodyText(q).contains('`')) q['id'] as String
      ];
      expect(hits, isEmpty, reason: hits.join(', '));
    });

    test('프런트매터 sources 가 한 덩어리로 읽힌다 (CLF·DVA 전수)', () {
      // 목록 중간에 최상위 키가 끼면 파서가 뒤쪽 출처를 조용히 버린다.
      for (final f in [...filesOf(clfDir, '.md'), ...filesOf(dvaDir, '.md')]) {
        final md = f.readAsStringSync().replaceAll('\r\n', '\n');
        final fm = md.substring(0, md.indexOf('\n---\n', 4));
        final declared = RegExp(r'^    url: ', multiLine: true).allMatches(fm).length;
        expect(frontmatterUrls(md).length, declared, reason: base(f));
        expect(declared, greaterThan(0), reason: base(f));
      }
    });
  });

  // ═════════════════════ DVA-C03 ═════════════════════

  group('DVA D-R1 역할 체이닝 1시간 상한은 콘솔에도 적용된다', () {
    test('「콘솔 역할 전환에는 해당하지 않는다」 0건', () {
      final hits = sweepDva(RegExp(r'콘솔 역할 전환에는 해당하지'));
      expect(hits, isEmpty,
          reason: '공식: "Role chaining limits your AWS Management Console, AWS CLI or '
              'AWS API role session to a maximum of one hour.": ${hits.join(', ')}');
    });

    test('체이닝 상한의 대상을 CLI·API 로만 적지 않는다', () {
      final lines = filesOf(dvaDir, '.md')
          .expand((f) => f.readAsStringSync().split('\n'))
          .where((l) => l.contains('체이닝') && l.contains('CLI·API'))
          .toList();
      expect(lines.length, greaterThanOrEqualTo(3), reason: '대조군');
      for (final l in lines) {
        expect(l.contains('콘솔·CLI·API'), isTrue, reason: l.trim());
      }
    });
  });

  group('DVA 상태·출처·표기', () {
    test('D-Y1 Bedrock Agents 의 사용자 확인·제어 반환에 Agents Classic 상태가 붙었다', () {
      var seen = 0;
      for (final f in filesOf(dvaDir, '.md')) {
        final md = f.readAsStringSync();
        if (!md.contains('제어 반환') || !md.contains('사용자 확인')) continue;
        seen++;
        expect(md.contains('Agents Classic'), isTrue, reason: base(f));
        expect(md.contains('2026-07-30부터 신규 고객에게 열려 있지 않습니다'), isTrue,
            reason: base(f));
        expect(md.contains('AgentCore'), isTrue, reason: '공식 이전 경로');
        expect(
            frontmatterUrls(md),
            contains(
                'https://docs.aws.amazon.com/bedrock/latest/userguide/agents-classic-maintenance-mode.html'),
            reason: '상태는 전용 페이지에서만 읽힌다');
      }
      expect(seen, greaterThanOrEqualTo(1));
    });

    test('D-Y2 X-Ray SDK 로 계측을 가르치는 줄은 유지 관리 모드를 함께 적는다', () {
      final lines = filesOf(dvaDir, '.md')
          .expand((f) => f.readAsStringSync().split('\n'))
          .where((l) => l.contains('X-Ray SDK') && l.contains('계측'))
          .toList();
      expect(lines.length, greaterThanOrEqualTo(2), reason: '대조군');
      for (final l in lines) {
        expect(l.contains('유지 관리 모드'), isTrue,
            reason: '공식: "On February 25th, 2026, the AWS X-Ray SDKs/Daemon will enter '
                'maintenance mode": ${l.trim()}');
      }
    });

    test('D-Y3 인용 페이지에 없는 날짜를 적지 않고 Kiro 표의 근거 수준을 밝힌다', () {
      expect(sweepDva(RegExp(r'2026-05-15')), isEmpty,
          reason: '인용 페이지에는 2027-04-30 지원 종료만 있다');
      final kiro = dvaDoc('dva-t1-1')
          .split('\n')
          .where((l) => l.contains('Kiro의 구성 요소'))
          .toList();
      expect(kiro, isNotEmpty);
      expect(kiro.first.contains('문항의 근거로 쓰지 않습니다'), isTrue);
      expect(dvaDoc('dva-t1-1').contains('2027-04-30'), isTrue, reason: '공식 사실은 지킨다');
    });

    test('D-Y4·D-Y5 출처 추가와 mTLS 행', () {
      expect(
          frontmatterUrls(dvaDoc('dva-t3-2')),
          contains(
              'https://docs.aws.amazon.com/AmazonECS/latest/developerguide/copilot-install.html'),
          reason: '2026-06-12 지원 종료 공지가 있는 페이지');
      final row = dvaDoc('dva-t2-1').split('\n').where((l) => l.startsWith('| **mTLS**'));
      expect(row, isNotEmpty);
      expect(row.first.contains('HTTP(커스텀 도메인)'), isTrue,
          reason: 'HTTP API 도 상호 TLS 를 지원하고 커스텀 도메인이 전제다');
      expect(
          frontmatterUrls(dvaDoc('dva-t2-1')),
          contains(
              'https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-mutual-tls.html'));
    });

    test('SDK 재시도: 현행 Boto3 가이드의 기본 모드는 standard 다 (1단계 보고 밖 — 범위 확장)', () {
      // 공식 Boto3 가이드: "Standard mode is the default mode used by any Boto3 client you
      // create." · "Legacy mode was the default mode for Boto3 clients before standard mode
      // became the default." — 「Boto3 가이드(현행): legacy가 기본」은 거짓이 됐다.
      final re = RegExp(r'legacy\*{0,2}가 기본');
      expect(re.hasMatch('| 모드 | **legacy**가 기본, standard·adaptive 선택 |'), isTrue,
          reason: '대조군 — 굵게가 낱말을 감싸도 잡는다');
      expect(re.hasMatch('legacy는 그 이전 기본값'), isFalse);
      final hits = sweepDva(re);
      expect(hits, isEmpty, reason: hits.join(', '));
      final t = dvaDoc('dva-t1-1');
      expect(t.contains('AWS_NEW_RETRIES_2026'), isTrue,
          reason: 'SDK 레퍼런스의 opt-in 서술은 오늘도 참이므로 지킨다');
      expect(t.contains('2026년 이전 재시도 동작'), isTrue,
          reason: '공식: "Without this setting, your SDK uses pre-2026 retry behavior"');
      expect(frontmatterUrls(t),
          contains('https://docs.aws.amazon.com/boto3/latest/guide/retries.html'),
          reason: '표의 둘째 열이 근거로 삼는 문서인데 출처에 없었다');
    });

    test('개수·권장 단정을 걷었다 (Guardrails 범주 수 · Valkey 권장 엔진)', () {
      expect(sweepDva(RegExp(r'범주\s*\*{0,2}6종|\(6종:')), isEmpty,
          reason: '레포 규율 — 공식 내부에서 범주 수가 갈린다. 이름 나열은 유지한다');
      expect(dvaDoc('dva-t2-3').contains('Prompt Attack'), isTrue);
      expect(sweepDva(RegExp(r'권장 엔진')), isEmpty,
          reason: '인용 페이지의 recommend 는 「그 엔진의 최신 버전」뿐이다');
      expect(dvaDoc('dva-t1-1').contains('MaximumMessageSize'), isTrue);
    });
  });
}
