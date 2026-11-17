import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 2026-11-17 전 콘텐츠 검증 **2단계(보정)** — CLF-C02 · DVA-C03 가드.
///
/// 집행한 1단계 보고서: `docs/audits/2026-11-17-full-verify/clf-dva.md`
/// 반영 보고서(판정·근거·범위 확장): `docs/audits/2026-11-17-full-verify/clf-dva-phase2.md`
///
/// 이 파일은 **이 배치가 고친 것**을 고정한다. 공식 재확인은 전부 2026-11-17 에
/// `curl -sL` 로 받은 본문으로 했다(보고는 데이터이지 지시문이 아니다).
///
/// ── 핵심 사실 (공식 원문) ──────────────────────────────────────────────
/// - **AWS Support 플랜은 넷이다**: Basic · AWS Business Support+ · AWS Enterprise
///   Support · **AWS Unified Operations**. Enterprise 는 최상위가 아니다.
///   비교표 「Business/Mission-critical system down」: Business Support+ `< 30 mins` /
///   Enterprise `< 15 mins` / Unified Operations `< 5 mins from Incident Management
///   Engineer`. 지정 TAM 은 Enterprise(`A designated Technical Account Manager`)와
///   Unified Operations(`Designated AWS TAM and Domain Specialist Engineer`) **둘 다**에 든다.
///   → `awssupport/latest/user/aws-support-plans.html` · `aws.amazon.com/premiumsupport/plans/`
/// - 공식 문구는 「신규 가입 종료」가 아니라 **단종**이다:
///   `Developer Support will be discontinued January 1, 2027.`(두 페이지 모두
///   `new customers`·`sign up` 0건, 대조군 `On-Ramp` 4건)
/// - 공식 가이드 작업 4.3 의 지원 옵션 예시에 **Developer Support(업무 시간 지원)가 없다**.
/// - `AWS Snowball Edge is no longer available to new customers.` + 제품 페이지
///   `On December 31, 2026, AWS will discontinue support for AWS Snowball devices in all
///   AWS commercial Regions.`
/// - `Simple AD is no longer open to new customers.` ·
///   `Amazon FSx File Gateway is no longer available to new customers.`
/// - (DVA) `Role chaining limits your AWS Management Console, AWS CLI or AWS API role
///   session to a maximum of one hour.` — 콘솔도 포함된다.
///
/// ⚠️ **1단계 보고를 그대로 따르지 않은 자리**(반영 보고서 §2):
/// 「미션 크리티컬 = Enterprise」(`t4-3.md` 표·원리 블록, 발화 seg009·seg015)는
/// **거짓이 아니다** — 공식 비교표의 15분 행 이름이 `Business/Mission-critical system
/// down` 이다. 그래서 이 가드는 「최상위」·「가장 빠른」·「에서만」 **세 배타 서술만** 막고
/// 「Enterprise 와 미션 크리티컬」의 동시 등장은 막지 않는다.
///
/// ⚠️ **`verified`·`reviewStatus`·`audioApproved` 는 단정하지 않는다** — flip 과 청취
/// 승인은 사람의 서명이다(2026-11-13 「전 문항 드래프트」 단정이 첫 flip 을 레드로 끝냈다).
void main() {
  const clfDir = 'assets/content/clf';
  const dvaDir = 'assets/content/dva';
  const audioDir = 'assets/audio/clf';
  const guide =
      'https://docs.aws.amazon.com/ko_kr/aws-certification/latest/cloud-practitioner-02/';
  const overviewUrl = '${guide}cloud-practitioner-02.html';

  List<File> files(String dir, String suffix) => Directory(dir)
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith(suffix))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  String base(File f) => f.path.replaceAll(r'\', '/').split('/').last;
  String clf(String id) => File('$clfDir/$id.md').readAsStringSync();
  String dva(String id) => File('$dvaDir/$id.md').readAsStringSync();

  Map<String, Map<String, dynamic>> allQuestions() {
    final out = <String, Map<String, dynamic>>{};
    for (final f in files(clfDir, '.questions.json')) {
      final map = json.decode(f.readAsStringSync()) as Map<String, dynamic>;
      for (final q in (map['questions'] as List).cast<Map<String, dynamic>>()) {
        out[q['id'] as String] = q;
      }
    }
    return out;
  }

  List<String> urls(Map<String, dynamic> q) => (q['sources'] as List)
      .map((s) => (s as Map<String, dynamic>)['url'] as String)
      .toList();

  List<String> titles(Map<String, dynamic> q) => (q['sources'] as List)
      .map((s) => (s as Map<String, dynamic>)['title'] as String? ?? '')
      .toList();

  /// 문항 전체(지문·보기·해설·오답 근거·출처 제목).
  String allText(Map<String, dynamic> q) => <String>[
        q['stem'] as String? ?? '',
        q['explanation'] as String? ?? '',
        ...(q['options'] as List).cast<String>(),
        ...(q['wrongExplanations'] as Map<String, dynamic>).values.cast<String>(),
        ...titles(q),
      ].join('\n');

  /// 가르치는 층 — 지문·정답 보기·해설. (`skill` 은 라벨이고 오답 보기·오답 근거는
  /// 틀린 선택지를 설명하는 층이라 상태 메모를 요구하지 않는다.)
  String teaching(Map<String, dynamic> q) => <String>[
        q['stem'] as String? ?? '',
        (q['options'] as List)[q['correct'] as int] as String,
        q['explanation'] as String? ?? '',
      ].join('\n');

  /// 대본의 **발화 본문** — `gen_lecture_audio.py` 의 `_spoken_body` 와 같은 규칙.
  List<({String docId, String segId, String text})> spoken() {
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

  /// CLF md 줄 · 문항 전체 · 발화 본문을 한 규칙으로 센다.
  List<String> sweepClf(RegExp re) {
    final hits = <String>[];
    for (final f in files(clfDir, '.md')) {
      final lines = f.readAsStringSync().split('\n');
      for (var i = 0; i < lines.length; i++) {
        if (re.hasMatch(lines[i])) hits.add('${base(f)}:${i + 1}');
      }
    }
    allQuestions().forEach((id, q) {
      if (re.hasMatch(allText(q))) hits.add(id);
    });
    for (final s in spoken()) {
      if (re.hasMatch(s.text)) hits.add('${s.docId}/${s.segId}');
    }
    return hits..sort();
  }

  List<String> sweepDva(RegExp re) {
    final hits = <String>[];
    for (final f in files(dvaDir, '.md')) {
      final lines = f.readAsStringSync().split('\n');
      for (var i = 0; i < lines.length; i++) {
        if (re.hasMatch(lines[i])) hits.add('${base(f)}:${i + 1}');
      }
    }
    return hits..sort();
  }

  // ── 탐지기 (함수로 빼서 대조군을 붙인다) ──
  // 「Enterprise = 최상위」·「가장 빠른 응답」·「TAM 은 Enterprise 에서만」
  final reTopPlan = RegExp(
      r'(Enterprise|엔터프라이즈)[^.\n]{0,40}최상위|'
      r'최상위[^.\n]{0,20}(Enterprise|엔터프라이즈|Support\s*플랜|플랜)');
  final reFastest = RegExp(r'가장 빠른[^.\n]{0,12}응답');
  final reTamOnly =
      RegExp(r'(Enterprise|엔터프라이즈)\s*플랜에(서)?만\s*(포함|제공)');
  final reSignupClosed = RegExp(r'신규 가입(을)?\s*(종료|차단)');
  final reExamAsks = RegExp(r'시험은[^.\n]{0,60}출제');

  // ═══════════════════════ 대조군 ═══════════════════════

  group('대조군 — 탐지 범위가 실재한다', () {
    test('CLF md·문항·대본, DVA md 를 모두 읽는다', () {
      expect(files(clfDir, '.md').length, 19);
      expect(files(clfDir, '.questions.json').length, 19);
      expect(allQuestions().length, greaterThan(250),
          reason: '문항이 0이면 문항 단정 전부가 공허하다');
      final sp = spoken();
      expect(sp.length, greaterThan(500));
      expect(sp.map((s) => s.docId).toSet().length, 19);
      expect(files(dvaDir, '.md').length, 12);
    });

    test('탐지기가 옛 문구를 잡고 정정문은 통과시킨다', () {
      // 옛 문구(이 배치 전의 라이브 문장 그대로)
      expect(reTopPlan.hasMatch('Enterprise Support는 전담 TAM 등을 포함하는 최상위 유료 플랜으로'),
          isTrue);
      expect(reTopPlan.hasMatch('15분 응답이 포함된 최상위 Support 플랜을 가입해'), isTrue);
      expect(reFastest.hasMatch('케이스에 대한 가장 빠른(약 15분) 응답이 필요하다'), isTrue);
      expect(reFastest.hasMatch('가장 빠른 응답과 전담 지원이 필요하다면 엔터프라이즈'), isTrue);
      expect(reTamOnly.hasMatch('미션 크리티컬 요구를 가진 Enterprise 플랜에서만 포함된다'), isTrue);
      expect(reTamOnly.hasMatch('매니저는 엔터프라이즈 플랜에만 포함됩니다'), isTrue);
      expect(reSignupClosed.hasMatch('온램프 이 세 가지에 대해서는 신규 가입을 종료한다는 공지'), isTrue);
      expect(reExamAsks.hasMatch('시험은 전통 분류(Basic·Developer·Business·Enterprise) 기준으로 출제되며'),
          isTrue);
      // 정정문 — 걸리면 안 된다
      expect(reTopPlan.hasMatch('전담 TAM 등을 포함하는 상위 유료 플랜으로'), isFalse);
      expect(
          reTopPlan.hasMatch('엣지 로케이션이 리전을 담는 최상위 단위가 아니며'), isFalse,
          reason: '`clf-t3-2-q15` 의 무관한 「최상위」(엣지 로케이션 문맥)는 대상이 아니다');
      expect(reTamOnly.hasMatch('Enterprise Support와 그 위의 AWS Unified Operations에 포함되고'),
          isFalse);
      expect(reTamOnly.hasMatch('매니저는 엔터프라이즈 플랜부터 포함됩니다'), isFalse);
    });
  });

  // ═══════════════════════ 구조 — 정답 불변 ═══════════════════════

  test('손댄 문항의 정답 인덱스가 불변이고 보기가 넷이다', () {
    // ⚠️ 이 값은 **JSON 에서 읽어 덤프한 실측값**이다(추측하지 않았다).
    const expected = <String, int>{
      'clf-t4-3-q1': 0, 'clf-t4-3-q2': 0, 'clf-t4-3-q3': 0, 'clf-t4-3-q6': 0,
      'clf-t4-3-q7': 0, 'clf-t4-3-q9': 0, 'clf-t4-3-q10': 2, 'clf-t4-3-q11': 0,
      'clf-t4-3-q13': 0, 'clf-t1-3-q3': 0, 'clf-t1-3-q8': 1, 'clf-t1-3-q9': 0,
      'clf-t1-3-q14': 0, 'clf-t3-2-q8': 2, 'clf-t3-2-q11': 0, 'clf-t3-2-q12': 0,
      'clf-t3-2-q14': 0, 'clf-t1-1-q13': 1, 'clf-t1-4-q8': 2, 'clf-t3-3-q4': 0,
      'clf-t4-1-q2': 0, 'clf-t4-1-q5': 0, 'clf-t4-1-q15': 0, 'clf-t4-2-q10': 1,
      'clf-t4-2-q12': 0, 'clf-t3-8-q11': 0, 'clf-t3-8-q15': 0, 'clf-t2-4-q15': 0,
    };
    final qs = allQuestions();
    expected.forEach((id, correct) {
      final q = qs[id];
      expect(q, isNotNull, reason: '$id 없음');
      expect(q!['correct'], correct, reason: id);
      expect((q['options'] as List).length, 4, reason: id);
      expect((q['wrongExplanations'] as Map).length, 3, reason: id);
    });
  });

  // ═══════════════════════ C-R1 · C-R2 · C-Y7 — Support 플랜 ═══════════════════════

  group('C-R1 Enterprise 는 최상위·최속·TAM 유일 플랜이 아니다', () {
    test('세 배타 서술이 md·문항·발화 전수에서 0건이다', () {
      expect(sweepClf(reTopPlan), isEmpty, reason: '현행 4플랜의 최상위는 Unified Operations 다');
      expect(sweepClf(reFastest), isEmpty,
          reason: 'Unified Operations 가 같은 등급에 5분 안에 응답한다');
      expect(sweepClf(reTamOnly), isEmpty,
          reason: '지정 TAM 은 Unified Operations 에도 든다');
    });

    test('새 사실이 있다 — md·문항·발화가 Unified Operations 를 Enterprise 위에 둔다', () {
      final md = clf('t4-3');
      expect(md.contains('Enterprise Support와 그 위의 AWS Unified Operations에 포함'), isTrue);
      expect(md.contains('Enterprise Support(TAM) → Unified Operations'), isTrue,
          reason: '사다리의 끝은 Enterprise 가 아니다');
      final q3 = allQuestions()['clf-t4-3-q3']!;
      expect((q3['explanation'] as String).contains('Unified Operations'), isTrue);
      expect(urls(q3).any((u) => u.endsWith('unified-operations-intro.html')), isTrue,
          reason: '해설의 「5분 응답」은 그 사실을 담는 페이지를 출처로 단다');
      final segs = {for (final s in spoken().where((s) => s.docId == 'clf-t4-3')) s.segId: s.text};
      for (final id in ['seg006', 'seg030', 'seg033']) {
        expect(segs[id]!.contains('유니파이드 오퍼레이션스'), isTrue, reason: 'clf-t4-3/$id');
      }
    });

    test('보존: 「전담 TAM + 15분 = Enterprise」는 참이므로 지우지 않는다', () {
      // 1단계 보고도 `t4-3.md:32·75·134·148·174` 와 seg012·seg013 을 대상에서 뺐다.
      expect(clf('t4-3').contains('**전담 TAM + 15분 응답 = Enterprise.**'), isTrue);
      final kept = spoken()
          .where((s) => s.docId == 'clf-t4-3' && (s.segId == 'seg012' || s.segId == 'seg013'))
          .where((s) => s.text.contains('엔터프라이즈') && s.text.contains('15분'))
          .length;
      expect(kept, 2);
    });
  });

  group('C-R2 정답 보기가 없는 플랜에 귀속되지 않는다', () {
    test('「시험 가이드 기준」 귀속이 CLF 문항 전수에서 0건이다', () {
      final hits = allQuestions()
          .entries
          .where((e) => allText(e.value).contains('시험 가이드 기준'))
          .map((e) => e.key)
          .toList();
      expect(hits, isEmpty,
          reason: '공식 작업 4.3 의 지원 옵션 예시에 Developer Support(업무 시간 지원)가 없다');
    });

    test('clf-t4-3-q13 의 정답 보기가 길이 단서가 되지 않는다 (양방향)', () {
      final q = allQuestions()['clf-t4-3-q13']!;
      final opts = (q['options'] as List).cast<String>();
      final c = q['correct'] as int;
      final wrong = [for (var i = 0; i < 4; i++) if (i != c) opts[i].length];
      wrong.sort();
      expect(opts[c].length <= wrong.last * 1.3, isTrue, reason: '정답이 최장 단서가 된다');
      expect(opts[c].length >= wrong.first, isTrue,
          reason: '괄호를 걷으면서 정답만 깎으면 반대 방향 단서가 된다');
      expect((q['explanation'] as String).contains('Business Support+'), isTrue);
      expect((q['explanation'] as String).contains('2027-01-01'), isTrue);
    });
  });

  group('C-Y7 공식이 적지 않는 것을 단정하지 않는다', () {
    test('「신규 가입 종료」·「시험은 … 출제」가 md·문항·발화 전수에서 0건이다', () {
      expect(sweepClf(reSignupClosed), isEmpty,
          reason: '공식 문구는 `will be discontinued January 1, 2027` — 단종이다');
      expect(sweepClf(reExamAsks), isEmpty,
          reason: '시험이 무엇으로 출제되는지 적는 공식 문서는 없다');
    });

    test('새 사실이 있다 — 단종일이 md 와 발화에 남는다', () {
      expect(clf('t4-3').contains('**2027-01-01 단종** 공지'), isTrue);
      final seg031 = spoken().firstWhere((s) => s.docId == 'clf-t4-3' && s.segId == 'seg031');
      expect(seg031.text.contains('2027년 1월 1일에 단종'), isTrue);
    });
  });

  // ═══════════════════════ C-Y4 · C-Y5 · C-Y6 — 출처 ═══════════════════════

  group('C-Y4 Task 기술의 출처는 개요 페이지가 아니라 도메인 페이지다', () {
    test('개요 URL 을 문항 출처로 쓰는 문항이 전수 0건이다', () {
      final hits = allQuestions()
          .entries
          .where((e) => urls(e.value).contains(overviewUrl))
          .map((e) => e.key)
          .toList();
      expect(hits, isEmpty,
          reason: '개요 페이지는 형식·비중만 담고 Task 기술 문구는 도메인 페이지에 있다');
    });

    test('옮긴 출처가 실재한다 (지우기만 한 것이 아니다)', () {
      final n = allQuestions()
          .values
          .where((q) => urls(q).any((u) => u.startsWith('${guide}cloud-practitioner-02-domain')))
          .length;
      expect(n, greaterThanOrEqualTo(19));
      expect(urls(allQuestions()['clf-t3-8-q15']!).single,
          '${guide}clf-02-in-scope-services.html');
    });

    test('학습문서 19편이 자기 도메인 페이지를 프런트매터와 출처 절 양쪽에 단다', () {
      for (final f in files(clfDir, '.md')) {
        final name = base(f); // t3-2.md
        final url = '${guide}cloud-practitioner-02-domain${name[1]}.html';
        final text = f.readAsStringSync();
        expect(RegExp(RegExp.escape(url)).allMatches(text).length, 2, reason: name);
        final fm = text.substring(0, text.indexOf('\n---', 4));
        expect(fm.contains('    url: $url'), isTrue, reason: '$name 프런트매터');
        expect(RegExp(r'^lastVerified: 2026-11-(1[7-9]|[23]\d)', multiLine: true).hasMatch(fm) ||
                RegExp(r'^lastVerified: (2026-12|20(2[7-9]|[3-9]\d))', multiLine: true).hasMatch(fm),
            isTrue,
            reason: '$name: 본문을 고쳤으면 lastVerified 를 올린다(하한 비교)');
      }
    });
  });

  group('C-Y5·C-Y6 인용 페이지가 그 사실을 담는다 (새 출처 있음 + 옛 귀속 없음)', () {
    const ec2rz =
        'https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html';
    final pairs = <String, ({String has, String? lacks})>{
      'clf-t1-1-q13': (has: 'https://aws.amazon.com/what-is/virtualization/', lacks: null),
      'clf-t3-2-q8': (
        has: 'https://docs.aws.amazon.com/global-infrastructure/latest/regions/aws-regions.html',
        lacks: ec2rz
      ),
      'clf-t3-2-q11': (
        has: 'https://docs.aws.amazon.com/global-infrastructure/latest/regions/aws-regions.html',
        lacks: ec2rz
      ),
      'clf-t3-2-q14': (
        has: 'https://docs.aws.amazon.com/global-infrastructure/latest/regions/aws-regions-availability-zones.html',
        lacks: ec2rz
      ),
      'clf-t3-2-q12': (
        has: 'https://docs.aws.amazon.com/wellarchitected/latest/cost-optimization-pillar/cost_pricing_model_region_cost.html',
        lacks: overviewUrl
      ),
      'clf-t3-3-q4': (has: 'https://docs.aws.amazon.com/eks/latest/userguide/fargate.html', lacks: null),
      'clf-t4-1-q2': (
        has: 'https://docs.aws.amazon.com/savingsplans/latest/userguide/plan-types.html',
        lacks: null
      ),
      'clf-t4-1-q5': (
        has: 'https://docs.aws.amazon.com/savingsplans/latest/userguide/sp-ris.html',
        lacks: 'https://docs.aws.amazon.com/savingsplans/latest/userguide/what-is-savings-plans.html'
      ),
      'clf-t4-1-q15': (
        has: 'https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/reserved-instances-types.html',
        lacks: 'https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/concepts.html'
      ),
      'clf-t4-3-q1': (has: 'https://aws.amazon.com/premiumsupport/plans/', lacks: null),
      'clf-t4-3-q10': (
        has: 'https://docs.aws.amazon.com/awssupport/latest/user/aws-support-plans.html',
        lacks: 'https://docs.aws.amazon.com/awssupport/latest/user/getting-started.html'
      ),
    };
    pairs.forEach((id, p) {
      test(id, () {
        final u = urls(allQuestions()[id]!);
        expect(u.contains(p.has), isTrue, reason: '$id: 새 출처가 없다');
        if (p.lacks != null) {
          expect(u.contains(p.lacks), isFalse, reason: '$id: 그 사실을 담지 않는 옛 출처가 남았다');
        }
      });
    });

    test('출처 제목이 그 페이지에 없는 것을 귀속하지 않는다', () {
      final qs = allQuestions();
      String t(String id) => titles(qs[id]!).join('\n');
      expect(t('clf-t1-4-q8').contains('TCO 추정'), isFalse,
          reason: 'Pricing Calculator 소개 페이지에 TCO·on-premises 가 0건이다');
      expect(t('clf-t1-4-q8').contains('숨은 비용'), isFalse);
      expect(t('clf-t4-3-q7').contains('Developer'), isFalse,
          reason: '인용 페이지는 현행 세 플랜 이름으로 적는다');
      expect(t('clf-t4-3-q7').contains('Unified Operations'), isTrue);
      expect(t('clf-t4-3-q10').contains('On-Ramp'), isFalse);
      expect(t('clf-t4-3-q13').contains('~ Enterprise TAM'), isFalse);
      expect(t('clf-t2-4-q15').contains('Security Center'), isTrue,
          reason: '공식 2.4: AWS Knowledge Center, AWS Security Center, AWS Security Blog');
      // 2026-11-06 P1-2 가드가 지키는 66/72 갈림은 유지된다
      expect(t('clf-t4-1-q2').contains('Compute SP 최대 66%'), isTrue);
      expect(t('clf-t4-1-q2').contains('EC2 Instance SP 최대 72%'), isTrue);
    });
  });

  // ═══════════════════════ C-Y1 · C-Y2 · C-Y3 — 서비스 상태 ═══════════════════════

  group('C-Y1 Snowball 을 가르치는 문항·문서는 현행 상태를 적는다', () {
    test('가르치는 층에서 Snowball 을 드는 문항 전수가 해설에 상태를 단다', () {
      final qs = allQuestions();
      final teach = qs.entries.where((e) => teaching(e.value).contains('Snowball')).toList();
      expect(teach.length, greaterThanOrEqualTo(4), reason: '탐지기가 공허하지 않다');
      for (final e in teach) {
        final exp = e.value['explanation'] as String;
        expect(exp.contains('신규 고객에게 제공되지 않'), isTrue, reason: e.key);
        expect(exp.contains('2026-12-31'), isTrue, reason: e.key);
        expect(urls(e.value).contains('https://aws.amazon.com/snowball/'), isTrue,
            reason: '${e.key}: 지원 종료일은 제품 페이지가 적는다');
      }
    });

    test('대조군: 오답 층에만 Snowball 이 나오는 문항에는 상태를 달지 않는다', () {
      // 오답 보기를 반박하는 문장에 상태를 달면 그 상태가 그 보기를 틀리게 만든
      // 이유처럼 읽혀 거짓이 된다.
      final qs = allQuestions();
      final wrongOnly = qs.entries
          .where((e) => allText(e.value).contains('Snowball') && !teaching(e.value).contains('Snowball'))
          .toList();
      expect(wrongOnly.length, greaterThanOrEqualTo(5), reason: '층 분리가 공허하지 않다');
      for (final e in wrongOnly) {
        expect(allText(e.value).contains('2026-12-31'), isFalse, reason: e.key);
      }
    });

    test('t1-3.md 가 가정법이 아니라 공식 상태를 적는다', () {
      final md = clf('t1-3');
      expect(RegExp(r'Snow[^\n]{0,80}제한될 수').hasMatch(md), isFalse,
          reason: '공식은 `is no longer available to new customers` — 단정이다');
      expect(md.contains('AWS Snowball Edge는 신규 고객에게 제공되지 않습니다'), isTrue);
      expect(md.contains('2026-12-31'), isTrue);
      expect(md.contains('AWS Data Transfer Terminal'), isTrue, reason: '공식 대안');
      expect(md.contains('「적절한 마이그레이션 전략 파악(예: **데이터베이스 복제**)」'), isTrue,
          reason: 'C-Y13: 공식 가이드 문구를 그대로 인용한다');
      expect(md.contains('전략적 마이그레이션 사례'), isFalse);
    });
  });

  test('C-Y2·C-Y3 Simple AD·FSx File Gateway 를 언급하는 줄은 신규 고객 상태를 함께 적는다', () {
    var seen = 0;
    for (final f in files(clfDir, '.md')) {
      final lines = f.readAsStringSync().split('\n');
      for (var i = 0; i < lines.length; i++) {
        final l = lines[i];
        if (l.contains('url:') || RegExp(r'^\d+\. ').hasMatch(l) || l.contains('- title:')) continue;
        if (l.contains('Simple AD') || l.contains('FSx File Gateway')) {
          seen++;
          expect(l.contains('신규 고객'), isTrue, reason: '${base(f)}:${i + 1}');
        }
      }
    }
    expect(seen, greaterThanOrEqualTo(2), reason: '두 서비스가 본문에 실재한다');
  });

  // ═══════════════════════ C-Y8 ~ C-Y12 — 학습문서 정합 ═══════════════════════

  group('학습문서 정합', () {
    test('C-Y8 「공식 원문」 인용문이 인용 페이지에 실재하는 문장이다', () {
      final md = clf('t1-2');
      expect(md.contains('the six pillars of operational excellence'), isFalse,
          reason: '현행 framework.html·definitions.html 어디에도 없는 문장이다');
      expect(md.contains('"The AWS Well-Architected Framework is based on the following six pillars:"'),
          isTrue);
      expect(md.contains('Sustainability'), isTrue);
    });

    test('C-Y9·C-Y10 공식 「범위 외」 서비스를 가르치는 문서는 범위 메모를 단다', () {
      const where = <String, String>{
        'Personalize': 't3-7',
        'Wavelength': 't3-2',
        'CodeDeploy': 't3-1',
        'CloudShell': 't3-8',
      };
      where.forEach((name, doc) {
        final md = clf(doc);
        expect(md.contains(name), isTrue, reason: '$doc 가 $name 을 다룬다(대조군)');
        final memo = md.split('\n').where((l) => l.contains(name) && l.contains('범위 외'));
        expect(memo, isNotEmpty, reason: '$doc: $name 은 공식 「범위 외 AWS 서비스」 목록에 이름으로 있다');
      });
      // t3-8 내부 모순: CloudShell 을 든 줄은 전부 「범위 외」로 읽힌다
      for (final l in clf('t3-8').split('\n').where((l) => l.contains('CloudShell'))) {
        expect(l.contains('범위 외'), isTrue, reason: l);
      }
    });

    test('C-Y11 문항이 묻는 태그 사실이 학습문서에 있다', () {
      final md = clf('t4-2');
      expect(md.contains('aws:createdBy'), isTrue);
      expect(md.contains('**각각 활성화**'), isTrue,
          reason: '`You must activate both types of tags separately`');
      expect(md.contains('활성화한 뒤에 생성되는 리소스'), isTrue);
      expect(allQuestions()['clf-t4-2-q10']!['section'], 'cost-tracking');
    });

    test('C-Y12 구매 옵션 개수를 단정하지 않고 전용 인스턴스를 싣는다', () {
      final md = clf('t4-1');
      expect(md.contains('구매 옵션 6종'), isFalse,
          reason: '공식 4.1 지식은 일곱을 든다(전용 인스턴스 포함)');
      final row = md.split('\n').where((l) => l.startsWith('| **Dedicated Instances**'));
      expect(row, hasLength(1));
      expect(row.single.contains('단일 계정 전용 하드웨어'), isTrue,
          reason: '`run on hardware that\'s dedicated to a single AWS account`');
      expect(md.contains('dedicated-instance.html'), isTrue);
    });

    test('CLF 문항은 평문으로 그려지므로 백틱이 0건이다 (전수)', () {
      final hits = allQuestions()
          .entries
          .where((e) => <String>[
                e.value['stem'] as String,
                e.value['explanation'] as String,
                ...(e.value['options'] as List).cast<String>(),
                ...(e.value['wrongExplanations'] as Map<String, dynamic>).values.cast<String>(),
              ].join('\n').contains('`'))
          .map((e) => e.key)
          .toList();
      expect(hits, isEmpty);
      // 대조군: 같은 탐지가 md 에서는 백틱을 찾는다
      expect(clf('t4-2').contains('`'), isTrue);
    });
  });

  // ═══════════════════════ DVA-C03 (미등재 학습문서) ═══════════════════════

  group('DVA D-R1 역할 체이닝 1시간 상한은 콘솔에도 적용된다', () {
    test('「콘솔에는 해당하지 않는다」·「CLI·API 세션」 한정이 DVA 전수에서 0건이다', () {
      expect(sweepDva(RegExp(r'콘솔 역할 전환에는 해당하지 않')), isEmpty);
      expect(sweepDva(RegExp(r'(?<!콘솔·)CLI·API (역할 )?세션')), isEmpty,
          reason: '공식: `your AWS Management Console, AWS CLI or AWS API role session`');
    });

    test('새 사실이 있다 + 탐지기 대조군', () {
      final n = '콘솔·CLI·API 역할 세션'.allMatches(dva('dva-t2-1')).length;
      expect(n, 3, reason: '용어 표·핵심 개념·자가 점검 정답 세 자리');
      final re = RegExp(r'(?<!콘솔·)CLI·API (역할 )?세션');
      expect(re.hasMatch('역할 체이닝은 CLI·API 세션을 최대 1시간으로'), isTrue);
      expect(re.hasMatch('콘솔·CLI·API 역할 세션을 최대 1시간으로'), isFalse);
    });
  });

  group('DVA 서비스 상태·출처', () {
    test('D-Y1 사용자 확인·제어 반환을 가르치는 문서는 Agents Classic 상태를 적는다', () {
      var seen = 0;
      for (final f in files(dvaDir, '.md')) {
        final t = f.readAsStringSync();
        if (!(t.contains('사용자 확인') && t.contains('제어 반환'))) continue;
        seen++;
        expect(t.contains('Amazon Bedrock Agents Classic'), isTrue, reason: base(f));
        expect(t.contains('신규 고객에게 열려 있지 않습니다'), isTrue, reason: base(f));
        expect(t.contains('Amazon Bedrock AgentCore'), isTrue, reason: '${base(f)}: 공식 이전 경로');
        expect(t.contains('agents-classic-maintenance-mode.html'), isTrue, reason: base(f));
      }
      expect(seen, greaterThanOrEqualTo(1));
    });

    test('D-Y2 X-Ray SDK 로 계측하라고 적는 문서는 유지 관리 모드를 함께 적는다', () {
      // ⚠️ 트리거는 「X-Ray SDK」다 — X-Ray 서비스 자체는 정상이다.
      var seen = 0;
      for (final f in files(dvaDir, '.md')) {
        final t = f.readAsStringSync();
        if (!RegExp(r'X-Ray SDK\*{0,2}로 계측').hasMatch(t)) continue;
        seen++;
        expect(t.contains('유지 관리 모드'), isTrue, reason: base(f));
        expect(t.contains('OpenTelemetry'), isTrue, reason: base(f));
        expect(t.contains('xray-sdk-java-segment.html'), isTrue,
            reason: '${base(f)}: 그 고지를 싣는 페이지를 출처로 단다');
      }
      expect(seen, 2, reason: 'dva-t4-1 · dva-t4-2');
    });

    test('D-Y3 공식 docs 에 없는 날짜·단정을 적지 않는다', () {
      expect(sweepDva(RegExp(r'2026-05-15')), isEmpty,
          reason: '인용 페이지는 2027-04-30 지원 종료만 적는다(블로그는 근거가 아니다)');
      expect(dva('dva-t1-1').contains('2027-04-30'), isTrue, reason: '공식 사실은 남는다');
      expect(dva('dva-t1-1').contains('**문항 근거로 쓰지 않습니다**'), isTrue,
          reason: 'Kiro 구성 요소 표는 AWS docs 밖의 서술이다');
      expect(sweepDva(RegExp(r'권장 엔진')), isEmpty,
          reason: '`SelectEngine.html` 의 recommend 는 「그 엔진의 최신 버전」뿐이다');
    });

    test('D-Y4·D-Y5 출처와 mTLS', () {
      expect('copilot-install.html'.allMatches(dva('dva-t3-2')).length, 2,
          reason: '2026-06-12 지원 종료를 적는 페이지 — 프런트매터 + 출처 절');
      final row = dva('dva-t2-1').split('\n').where((l) => l.startsWith('| **mTLS**'));
      expect(row, hasLength(1));
      expect(row.single.contains('HTTP'), isTrue, reason: 'HTTP API 도 상호 TLS 를 지원한다');
      expect(dva('dva-t2-1').contains('http-api-mutual-tls.html'), isTrue);
    });

    test('Guardrails 유해 범주는 이름으로 적고 개수를 단정하지 않는다', () {
      // 레포 규율(AIF·SCS): 공식 내부에서 다섯/여섯이 갈린다.
      expect(sweepDva(RegExp(r'범주\s*\*{0,2}6종|\(6종: Hate')), isEmpty);
      expect(dva('dva-t2-3').contains('**Prompt Attack**'), isTrue, reason: '이름 나열은 남는다');
    });
  });
}
