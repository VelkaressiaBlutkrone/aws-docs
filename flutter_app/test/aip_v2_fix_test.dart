import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 2026-11-17 전 콘텐츠 검증 2단계(보정) — AIP-C01 분 가드.
///
/// 1단계 보고: `docs/audits/2026-11-17-full-verify/aip.md`
/// 반영 보고: `docs/audits/2026-11-17-full-verify/aip-phase2.md`
///
/// AIP 는 문항 300개가 전부 드래프트라 라이브 영향은 없지만 **flip 직전이 가장 싼
/// 수정 시점**이다. 이 파일은 문항만 보지 않고 **md 20편 + 문항 20파일을 같은
/// 규칙으로** 센다(`aip_questions_test` 는 `.md` 의 사실을 보지 않는다).
///
/// 설계 규율(레포가 비싸게 배운 것):
/// - **대조군을 먼저 둔다** — 0건 통과가 「파일을 못 읽어서」일 수 있다.
/// - 사실 단정은 **자격증 전수 집계**다(리터럴 하나는 어형 하나로 뚫린다).
/// - **옛 문구 0건 + 새 공식 사실 있음**을 쌍으로 둔다.
/// - ⚠️ **`verified` 상태를 단정하지 않는다**(사람의 flip 을 레드로 만들지 않는다).
///   대신 구조(보기 4개 · Task 당 15문항)와 **정답 인덱스 불변**을 단정한다.
///
/// 공식 재측정(2026-11-17, `curl -sL` · 전부 `200 r=0`)에서 1단계와 달라진 판정:
/// - **Y3** 「Web Crawler 는 자격 증명으로 보호된 콘텐츠에 맞지 않는다」는 「확인되지
///   않는다」가 아니라 **공식과 반대**다 — 관리형 지식 베이스 전용 페이지
///   `kb-managed-ds-webcrawler.html` 이 `Authentication for protected sites: basic,
///   form-based, or SAML` 을 지원 기능으로 적는다. 막히는 것은 접속이 아니라
///   **문서 수준 ACL** 이다(`does not support document-level access control`).
/// - **Y1** `함께 바뀝|함께 바뀌` 는 md **0자리가 아니라 1자리**였다 — 굵게 표기가
///   낱말 사이에 끼어(`함께** 바뀝니다`) 1단계 정규식을 비켜 갔다. 아래 탐지기는
///   별표를 허용하고 그 어형을 대조군으로 고정한다.
/// - **Y11** 「데이터세트 유형은 프리뷰」는 근거 없는 단정이 아니다 —
///   `dataset-evaluations.html` 이 `Dataset evaluation is in public preview` 로 적는다
///   (인용 페이지가 달랐을 뿐이다). 반대로 **「그라운드 트루스는 배치만」이 거짓**이다 —
///   `ground-truth-evaluations.html` 이 온디맨드의 `Evaluate API` 참조 입력을 적는다.
void main() {
  const dir = 'assets/content/aip';
  const taskIds = [
    'aip-t1-1', 'aip-t1-2', 'aip-t1-3', 'aip-t1-4', 'aip-t1-5', 'aip-t1-6',
    'aip-t2-1', 'aip-t2-2', 'aip-t2-3', 'aip-t2-4', 'aip-t2-5',
    'aip-t3-1', 'aip-t3-2', 'aip-t3-3', 'aip-t3-4',
    'aip-t4-1', 'aip-t4-2', 'aip-t4-3',
    'aip-t5-1', 'aip-t5-2',
  ];

  String md(String t) => File('$dir/$t.md').readAsStringSync();

  List<String> mdLines(String t) => md(t)
      .split('\n')
      .map((l) => l.endsWith('\r') ? l.substring(0, l.length - 1) : l)
      .toList();

  List<Map<String, dynamic>> qs(String t) =>
      ((json.decode(File('$dir/$t.questions.json').readAsStringSync())
              as Map<String, dynamic>)['questions'] as List)
          .cast<Map<String, dynamic>>();

  Map<String, dynamic> q(String id) {
    final t = RegExp(r'^(aip-t\d-\d)-q\d+$').firstMatch(id)!.group(1)!;
    return qs(t).firstWhere((e) => e['id'] == id);
  }

  String correctOf(Map<String, dynamic> e) =>
      '${(e['options'] as List)[e['correct'] as int]}';

  List<String> urlsOf(Map<String, dynamic> e) =>
      [for (final s in e['sources'] as List) '${(s as Map)['url']}'];

  /// 문항 전체 — 지문·보기 4개·해설·오답 근거·출처 제목.
  String allText(Map<String, dynamic> e) => [
        '${e['stem']}',
        '${e['explanation']}',
        for (final o in e['options'] as List) '$o',
        for (final v in (e['wrongExplanations'] as Map).values) '$v',
        for (final s in e['sources'] as List) '${(s as Map)['title']}',
      ].join('\n');

  /// 가르치는 층 — 오답 보기와 그 반박은 뺀다(상태 메모가 붙으면 안 되는 층이다).
  String teachText(Map<String, dynamic> e) =>
      ['${e['skill']}', '${e['stem']}', correctOf(e), '${e['explanation']}']
          .join('\n');

  /// md 20편 + 문항 20파일 전수에서 `pattern` 이 걸리는 자리.
  List<String> hitsEverywhere(RegExp pattern) {
    final hits = <String>[];
    for (final t in taskIds) {
      final lines = mdLines(t);
      for (var i = 0; i < lines.length; i++) {
        if (pattern.hasMatch(lines[i])) hits.add('$t.md:${i + 1}');
      }
      for (final e in qs(t)) {
        if (pattern.hasMatch(allText(e))) hits.add('${e['id']}');
      }
    }
    return hits;
  }

  List<String> hitsInQuestions(RegExp pattern) => [
        for (final t in taskIds)
          for (final e in qs(t))
            if (pattern.hasMatch(allText(e))) '${e['id']}',
      ];

  Set<String> frontmatterUrls(String t) => RegExp(r'url: (\S+)')
      .allMatches(md(t).split('---')[1])
      .map((m) => m.group(1)!)
      .toSet();

  // ── 대조군 ────────────────────────────────────────────────────────────────
  group('대조군', () {
    test('콘텐츠 파일이 읽혔다 — md 20편 · 문항 300개 · Task 당 15 · 보기 4개', () {
      var total = 0;
      for (final t in taskIds) {
        expect(md(t).length, greaterThan(8000), reason: '$t.md 가 너무 짧다');
        final list = qs(t);
        expect(list.length, 15, reason: '$t: 문항 ${list.length}개');
        for (final e in list) {
          expect((e['options'] as List).length, 4, reason: '${e['id']}');
        }
        total += list.length;
      }
      expect(total, 300);
    });

    // 이 배치가 손댄 107문항의 정답 인덱스 — 2단계는 정답을 한 건도 옮기지 않았다.
    // ⚠️ 값은 추측하지 않고 수정 전 원본에서 기계로 읽어 적었다.
    test('이 배치가 손댄 107문항의 정답 인덱스가 불변이다', () {
      const expected = <String, Map<String, int>>{
        'aip-t1-1': {'q1': 0, 'q5': 0, 'q6': 1, 'q9': 0, 'q10': 1, 'q12': 3, 'q13': 0, 'q14': 1, 'q15': 2},
        'aip-t1-2': {'q2': 1, 'q3': 2, 'q13': 0, 'q15': 2},
        'aip-t1-3': {'q1': 0, 'q3': 2, 'q6': 1, 'q7': 2, 'q10': 1, 'q11': 2, 'q14': 1, 'q15': 2},
        'aip-t1-4': {'q1': 0, 'q2': 1, 'q3': 2, 'q4': 3, 'q5': 0, 'q6': 1, 'q8': 3, 'q9': 0, 'q10': 1, 'q11': 2, 'q12': 3},
        'aip-t1-5': {'q1': 0, 'q7': 2, 'q8': 3, 'q11': 2, 'q13': 0, 'q14': 1, 'q15': 2},
        'aip-t1-6': {'q4': 3, 'q5': 0, 'q8': 3, 'q9': 0, 'q11': 2, 'q12': 3, 'q13': 0, 'q14': 1, 'q15': 2},
        'aip-t2-1': {'q2': 1, 'q4': 3, 'q7': 2, 'q8': 3, 'q10': 1, 'q11': 2, 'q13': 0},
        'aip-t2-2': {'q2': 1, 'q4': 3, 'q5': 0, 'q7': 2, 'q8': 3, 'q9': 0, 'q10': 1, 'q11': 2, 'q15': 2},
        'aip-t2-3': {'q2': 1, 'q5': 0, 'q6': 1, 'q14': 1, 'q15': 2},
        'aip-t2-4': {'q3': 2, 'q8': 3, 'q11': 2, 'q13': 0, 'q15': 2},
        'aip-t2-5': {'q8': 0, 'q9': 3, 'q10': 0},
        'aip-t3-1': {'q2': 1, 'q5': 0, 'q13': 0, 'q14': 1},
        'aip-t3-2': {'q6': 1},
        'aip-t3-3': {'q4': 3, 'q5': 0, 'q7': 2, 'q9': 0, 'q14': 1, 'q15': 2},
        'aip-t3-4': {'q5': 0, 'q7': 2, 'q11': 2},
        'aip-t4-1': {'q7': 2, 'q11': 2},
        'aip-t4-2': {'q5': 0, 'q11': 2},
        'aip-t4-3': {'q3': 2, 'q4': 3, 'q9': 0, 'q15': 2},
        'aip-t5-1': {'q1': 0, 'q10': 1, 'q11': 2},
        'aip-t5-2': {'q3': 2, 'q4': 3, 'q7': 2, 'q11': 2, 'q14': 1},
      };
      var checked = 0;
      for (final entry in expected.entries) {
        for (final e in entry.value.entries) {
          final id = '${entry.key}-${e.key}';
          expect(q(id)['correct'], e.value, reason: '$id: 정답 인덱스가 바뀌었다');
          checked++;
        }
      }
      expect(checked, 107);
    });
  });

  // ── 1순위: 정답 보기의 전제가 공식에서 확인되지 않던 셋 ─────────────────────
  group('1순위 — 정답 전제 (Y1·Y2·Y3)', () {
    // 굵게 표기가 낱말 사이에 끼는 어형까지 잡는다 — 1단계가 md 0자리로 센 이유다.
    final y1 = RegExp(r'함께\*{0,2} ?바뀝|함께\*{0,2} ?바뀌');

    test('대조군: Y1 탐지기가 굵게가 끼어든 어형을 잡는다', () {
      expect(y1.hasMatch('그것을 쓰는 플로들이 함께** 바뀝니다'), isTrue);
      expect(y1.hasMatch('그 프롬프트를 쓰는 플로들이 함께 바뀌므로'), isTrue);
      expect(y1.hasMatch('버전을 만들어 노드가 그 버전을 가리키게 합니다'), isFalse);
    });

    test('Y1: 「프롬프트를 고치면 플로들이 함께 바뀐다」 0건 + 버전 고정의 공식 근거', () {
      expect(hitsEverywhere(y1), isEmpty,
          reason: '인용 페이지 어디에도 없는 전파 서술이다. 공식이 적는 것은 '
              '프롬프트 버전(스냅샷)과 promptArn 의 버전 접미사, 플로 버전의 불변성이다');
      final e = q('aip-t1-6-q15');
      expect(correctOf(e), contains('버전'));
      expect(urlsOf(e), contains(endsWith('prompt-management-deploy.html')));
      expect(urlsOf(e),
          contains(endsWith('API_agent_PromptFlowNodeResourceConfiguration.html')));
      expect(md('aip-t1-6'), contains('promptArn'));
      expect(md('aip-t1-6'), contains('스냅샷'));
    });

    test('Y2: Aurora 「필터 필드 미지정 → 조용한 누락」 0건 + 공식이 적는 요건과 원인', () {
      final y2 = RegExp(r'필터(에 쓰는)? 필드[^.\n]{0,60}(조용|오류 없이)|조용한 결과 누락|조용히 누락');
      expect(hitsEverywhere(y2), isEmpty,
          reason: '벡터 스토어 설정 문서가 적는 것은 「Aurora 는 메타데이터 필드를 '
              '직접 준비한다」는 요건이고, 결과가 모자란 원인으로 적는 것은 반복 인덱스 스캔이다');
      final e = q('aip-t1-5-q8');
      expect(correctOf(e), contains('필드'));
      expect('${e['explanation']}', contains('GIN'));
      expect('${e['explanation']}', contains('반복 인덱스 스캔'));
      expect(md('aip-t1-5'), contains('GIN 인덱스 필수'));
      expect(md('aip-t1-5'), contains('반복 인덱스 스캔'));
    });

    // 같은 Note 를 나눠 쓰는 다른 쪽(t4-2-q5)이 과잉 정정으로 사라지지 않게 지킨다.
    test('Y2 보존: 「결과가 기대보다 적다 → 반복 인덱스 스캔」은 그대로이고 출처가 그 Note 를 담는다', () {
      final e = q('aip-t4-2-q5');
      expect(correctOf(e), contains('반복 인덱스 스캔'));
      expect(urlsOf(e), contains(endsWith('knowledge-base-setup.html')),
          reason: '반복 인덱스 스캔 Note 는 kb-test-config 가 아니라 이 페이지에 있다');
      for (final t in ['aip-t4-2', 'aip-t4-3', 'aip-t5-2']) {
        expect(frontmatterUrls(t), contains(endsWith('knowledge-base-setup.html')),
            reason: '$t: 그 사실을 본문에서 쓰는데 출처에 없다');
      }
    });

    test('Y3: 「Web Crawler 는 보호된 콘텐츠에 맞지 않는다」 0건 + 인증 지원·ACL 미지원', () {
      expect(hitsEverywhere(RegExp(r'자격 증명(으로| 기반으로)? ?보호')), isEmpty,
          reason: '관리형 지식 베이스의 Web Crawler 는 기본·폼 기반·SAML 인증을 지원한다. '
              '막히는 것은 문서 수준 ACL 이다');
      final e = q('aip-t1-4-q11');
      expect(correctOf(e), contains('ACL'));
      expect(correctOf(e), contains('로그인이 필요한 사이트도 크롤'));
      expect(urlsOf(e), contains(endsWith('kb-managed-ds-webcrawler.html')));
      // 옛 오해가 이제 오답 보기다 — 참인 보기로 되돌아가면 정답이 둘이 된다.
      expect('${(e['options'] as List)[1]}', contains('크롤할 수 없'));
      expect(md('aip-t1-4'), contains('SAML'));
      expect(md('aip-t1-4'), contains('문서 수준 ACL을 지원하지 않아'));
    });
  });

  // ── 사라졌거나 어긋난 공식 문장 ─────────────────────────────────────────────
  group('사라진·어긋난 공식 문장 (Y4·Y5·Y9·Y10·Y11)', () {
    test('Y4: 「tier 를 지정하지 않으면 Classic」 0건 (1단계 3자리 → 전수 5자리)', () {
      final y4 = RegExp(r'지정하지 않으면\*{0,2} ?Classic|기본은 \*{0,2}Classic|기본 Classic');
      expect(hitsEverywhere(y4), isEmpty,
          reason: '현행 guardrails-tiers.html 에 기본값 문장이 없다(API 참조도 미기재). '
              '대체 단정을 새로 쓰지 않고 걷는다');
      // 과잉 정정 방지 — tier 의 확인된 차이는 남아 있어야 한다.
      expect(md('aip-t3-1'), contains('1,000자'));
      expect(md('aip-t3-1'), contains('검증 오류로 실패'));
      expect('${q('aip-t3-1-q14')['explanation']}', contains('다시 테스트'));
    });

    test('Y5: 그라운드 트루스 요구를 두 페이지가 다르게 적는다는 것을 양쪽이 같은 말로 가르친다', () {
      final y5 = RegExp(r'RAG 평가만 데이터세트에 그라운드|정답지를 반드시|그라운드 트루스가 필요한 평가」');
      expect(hitsEverywhere(y5), isEmpty);
      expect('${q('aip-t3-4-q7')['explanation']}', contains('컨텍스트 커버리지'));
      expect(urlsOf(q('aip-t3-4-q7')),
          contains(endsWith('knowledge-base-evaluation-metrics.html')));
      expect(md('aip-t3-4'), contains('컨텍스트 커버리지'));
      // 더 구체적인 지표 페이지 쪽 문항은 그대로다.
      expect(correctOf(q('aip-t5-1-q10')), contains('그라운드 트루스'));
    });

    test('Y9: Generative AI Lens 「명시적으로 제외」 0건 + 렌즈가 적는 경계', () {
      expect(hitsEverywhere(RegExp(r'명시적으로 제외|범위에서 제외|범위와 제외')), isEmpty,
          reason: '그 문장은 렌즈 문서가 아니라 블로그에 있다. 렌즈는 사용자 지정을 다루고 '
              '전통적 ML 을 Machine Learning Lens 로 보낸다');
      expect(md('aip-t1-1'), contains('Machine Learning Lens를 보라'));
      expect('${q('aip-t1-1-q5')['explanation']}', contains('Machine Learning Lens'));
    });

    test('Y10: Well-Architected Agent 는 WA Tool 과 별개의 서비스이고 과금을 오답 축으로 쓰지 않는다', () {
      expect(
          hitsEverywhere(RegExp(r'WA Tool의 `?Well-Architected Agent|유료 기능이어서|워크로드 검토 서비스를 무료로')),
          isEmpty,
          reason: 'what-is 페이지가 둘을 「two distinct ways」로 적는다. Agent 는 유료 지원 '
              '플랜 고객에게 제공되므로 「유료가 아니다」를 오답 근거로 쓰면 참인 보기를 오답으로 둔다');
      expect(md('aip-t1-1'), contains('별개의 서비스'));
      expect(correctOf(q('aip-t1-1-q13')), contains('프리뷰'));
    });

    test('Y11: 문장 오류 셋 + 「그라운드 트루스는 배치만」 0건', () {
      final y11 = RegExp(r'셋이고 둘 모두|분당 토큰으로 엔드포인트|데이터세트 유형은 프리뷰|배치만 그라운드|배치뿐');
      expect(hitsEverywhere(y11), isEmpty);
      expect(md('aip-t5-1'), contains('Evaluate API'));
      expect(md('aip-t5-1'), contains('온라인 평가에서는 쓸 수 없습니다'));
      expect('${q('aip-t5-1-q11')['stem']}', contains('세션 발견'),
          reason: '온디맨드도 기대 도구 궤적을 받으므로 지문이 「서비스가 대신하는 것」을 물어야 정답이 하나다');
      expect(urlsOf(q('aip-t2-3-q15')), contains(endsWith('gateway-rate-limits.html')));
    });

    // 1단계가 「근거 없는 상태 단정」으로 적었지만 공식에 실재한다 — 지워지지 않게 지킨다.
    test('Y11 보존: 데이터세트 평가의 공개 프리뷰 서술과 그 출처가 남아 있다', () {
      expect(md('aip-t5-1'), contains('| 데이터세트 (**프리뷰**) |'));
      expect(frontmatterUrls('aip-t5-1'), contains(endsWith('dataset-evaluations.html')));
    });
  });

  // ── 저작 과정 메모·메타 문구 ────────────────────────────────────────────────
  group('저작 메모·메타 문구 (Y6·Y7·G1·G2·G5)', () {
    // MLA 의 M2 가드와 같은 전수 집계 — `prescreen` 의 authoring-memo 는 이 어형을 모른다.
    final m2 = RegExp(r'이 트랙|같은 추출|본문이 읽혔|근거[^.]{0,12}얻지 못');

    test('M2: 저작 프로젝트 지칭·측정 방법론이 학습자 문장에 없다 (md + 문항 전수)', () {
      expect(hitsEverywhere(m2), isEmpty,
          reason: '확인되지 않은 것은 해설에서 빼고 판단 보류는 승인 로그에 남긴다(루브릭 §2 M2)');
    });

    test('대조군: M2 탐지기가 실제 어형을 잡고, 의도된 시험 전략 서술은 걸지 않는다', () {
      expect(m2.hasMatch('근거는 이 트랙에서 얻지 못했습니다'), isTrue);
      expect(m2.hasMatch('같은 추출에서 variant는 정상적으로 잡혀'), isTrue);
      expect(m2.hasMatch('전제 자체가 근거를 얻지 못했습니다'), isTrue);
      // md 의 「공식 문서에서 확인되지 않습니다」는 의도된 서술이라 대상이 아니다.
      final kept = <String>[];
      for (final t in taskIds) {
        for (final l in mdLines(t)) {
          if (l.contains('공식 문서에서 확인되지 않')) kept.add(l);
        }
      }
      expect(kept.length, greaterThanOrEqualTo(4),
          reason: '의도된 시험 전략 서술이 사라졌다 — 과잉 정정이다');
      expect(kept.where(m2.hasMatch), isEmpty,
          reason: '탐지기가 의도된 서술을 걸고 있다 — 탐지기를 성질로 좁힌다');
    });

    test('문항이 「이 사이트가 문항을 어떻게 쓰는가」를 묻거나 말하지 않는다', () {
      final meta = RegExp(r'이 사이트|교재|문항으로 내|시험 포인트|시험 소재|이 질문의 문제는|표로 적으려');
      expect(hitsInQuestions(meta), isEmpty,
          reason: '저작 결정(⛔ 개수·서열을 묻지 않는다)은 「그 축으로 문항을 쓰지 않는다」이지 '
              '「그 판정을 문제로 낸다」가 아니다');
    });

    test('대조군: 「시험 포인트」는 학습문서의 절 제목이라 md 에서는 정상이다', () {
      var headings = 0;
      for (final t in taskIds) {
        headings += mdLines(t).where((l) => l.startsWith('## ') && l.contains('시험 포인트')).length;
      }
      expect(headings, 20, reason: '절 제목이 편마다 하나씩 있다 — 위 탐지기의 범위는 문항뿐이다');
    });

    test('G2: 지문에 「~에 비추어」 0건 (자기 프레임의 주어만 바뀐 형태)', () {
      final hits = [
        for (final t in taskIds)
          for (final e in qs(t))
            if ('${e['stem']}'.contains('비추어')) '${e['id']}',
      ];
      expect(hits, isEmpty);
    });

    test('G5: 문항은 평문 렌더다 — 경고·별 이모지 0건', () {
      expect(hitsInQuestions(RegExp('[⚠⭐]')), isEmpty);
      expect(md('aip-t1-4').contains('⚠'), isTrue,
          reason: '대조군: 같은 탐지기가 md 의 이모지는 찾는다');
    });

    test('Y7: 메타 문항 넷이 같은 사실을 설계 상황으로 묻는다', () {
      expect('${q('aip-t2-2-q10')['explanation']}', contains('Deep Java Library'));
      expect(correctOf(q('aip-t2-2-q10')), contains('인스턴스 유형과 백엔드'));
      expect(correctOf(q('aip-t3-3-q9')), allOf(contains('진실성'), contains('견고성')));
      expect(correctOf(q('aip-t2-2-q7')), contains('함께 씁니다'));
      expect(correctOf(q('aip-t1-4-q9')), contains('16,000'));
      expect(correctOf(q('aip-t1-4-q9')), isNot(contains('서열')));
    });
  });

  // ── 상태 표기 ───────────────────────────────────────────────────────────────
  group('상태·한정 (Y8·Y12)', () {
    test('Kendra 를 가르치는 층에서 드는 문항은 해설에 신규 고객 비개방을 적는다', () {
      var taught = 0;
      for (final t in taskIds) {
        for (final e in qs(t)) {
          if (!teachText(e).contains('Kendra')) continue;
          taught++;
          expect('${e['explanation']}', contains('신규 고객'),
              reason: '${e['id']}: Amazon Kendra 는 신규 고객에게 열려 있지 않다 — '
                  '상태를 적지 않으면 현행 경로로 배운다');
        }
        if (md(t).contains('Kendra')) {
          expect(md(t), contains('신규 고객'), reason: '$t.md');
        }
      }
      expect(taught, greaterThanOrEqualTo(1), reason: '대조군: 탐지기가 문항을 찾지 못했다');
    });

    test('`gen_ai.*` 속성은 Strands 한정으로 적는다 (프레임워크 일반으로 넓히지 않는다)', () {
      var seen = 0;
      for (final t in taskIds) {
        final lines = mdLines(t);
        for (var i = 0; i < lines.length; i++) {
          if (!lines[i].contains('gen_ai.')) continue;
          seen++;
          expect(lines[i], contains('Strands'), reason: '$t.md:${i + 1}');
        }
        for (final e in qs(t)) {
          if (!allText(e).contains('gen_ai.')) continue;
          seen++;
          expect(allText(e), contains('Strands'), reason: '${e['id']}');
        }
      }
      expect(seen, greaterThanOrEqualTo(4), reason: '대조군: 탐지기가 죽었다');
    });
  });

  // ── 출처 ────────────────────────────────────────────────────────────────────
  group('출처 — 「URL 은 200인데 그 페이지에 그 사실이 없다」', () {
    test('Y12: 사실을 실제로 담는 페이지가 출처에 있다', () {
      const required = <String, List<String>>{
        'aip-t1-3-q6': ['build-your-own-processing-container.html'],
        'aip-t1-3-q7': ['build-your-own-processing-container.html'],
        'aip-t1-3-q15': ['general/latest/gr/maintenance_services.html'],
        'aip-t1-4-q1': ['kb-test-agentic-retrieve.html'],
        'aip-t1-4-q4': ['kb-test-agentic-retrieve.html'],
        'aip-t1-4-q3': ['kendra-availability-change.html'],
        'aip-t1-4-q10': ['kb-direct-ingestion.html'],
        'aip-t2-1-q4': ['devguide/harness.html'],
        'aip-t2-1-q7': ['agentperf02-bp01.html'],
        'aip-t2-1-q13': ['devguide/gateway.html'],
        'aip-t3-1-q13': ['guardrails-prompt-attack.html'],
        'aip-t3-2-q6': ['general/latest/gr/full_shutdown_services.html'],
        'aip-t3-3-q5': ['glue/latest/dg/components-overview.html'],
        'aip-t3-3-q7': ['cloudtrail-concepts.html'],
        'aip-t4-2-q5': ['knowledge-base-setup.html', 'bp-sharding.html'],
        'aip-t4-3-q9': ['supported-frameworks-strands.html'],
        'aip-t5-1-q1': ['evaluations-types.html'],
        'aip-t5-1-q11': ['dataset-evaluations.html'],
      };
      for (final entry in required.entries) {
        final urls = urlsOf(q(entry.key));
        for (final need in entry.value) {
          expect(urls.any((u) => u.endsWith(need)), isTrue,
              reason: '${entry.key}: $need 가 출처에 없다 (현재 $urls)');
        }
      }
    });

    test('Y12: 학습문서의 출처 항목이 그 페이지에 없는 사실을 귀속하지 않는다', () {
      String line(String t, String needle) =>
          mdLines(t).lastWhere((l) => l.contains(needle) && RegExp(r'^\d+\. ').hasMatch(l));
      for (final t in ['aip-t4-3', 'aip-t5-2']) {
        expect(line(t, 'AuroraPostgreSQL.VectorDB.html'), isNot(contains('반복 스캔')),
            reason: '$t: 반복 인덱스 스캔은 Aurora 안내서가 아니라 Bedrock 벡터 스토어 설정 문서에 있다');
      }
      expect(line('aip-t4-3', 'devguide/supported-frameworks.html'), isNot(contains('gen_ai')));
      expect(line('aip-t3-1', 'guardrails-tiers.html'), isNot(contains('기본 Classic')));
      expect(md('aip-t1-3'), isNot(contains('를 **2026-03-31** 공지로 적습니다')),
          reason: '가용성 변경 페이지에는 날짜가 없다 — 날짜는 수명 주기 목록에 있다');
    });

    // 전수 불변식 — 1단계가 든 18문항 밖에서 3문항이 더 나왔다.
    test('Y13: 「기술 N.M.K」를 부르는 문항은 그 도메인의 시험 안내서 페이지를 출처로 단다', () {
      final ref = RegExp(r'기술 (\d)\.\d\.\d');
      var seen = 0;
      for (final t in taskIds) {
        for (final e in qs(t)) {
          final text = [
            '${e['stem']}',
            '${e['explanation']}',
            for (final v in (e['wrongExplanations'] as Map).values) '$v',
          ].join('\n');
          final m = ref.firstMatch(text);
          if (m == null) continue;
          seen++;
          final want = 'ai-professional-01/ai-professional-01-domain${m.group(1)}.html';
          expect(urlsOf(e).any((u) => u.endsWith(want)), isTrue,
              reason: '${e['id']}: 근거가 시험 안내서의 예시 목록인데 출처에 그 페이지($want)가 없다');
        }
      }
      // 하한은 추측하지 않고 실측해서 잡는다 — 2026-11-17 실측 14문항
      // (시험 안내서 출처를 단 문항은 23개이고 그중 본문이 번호를 부르는 것이 14다).
      expect(seen, greaterThanOrEqualTo(12), reason: '대조군: 탐지기가 문항을 찾지 못했다');
    });

    test('프런트매터 ↔ 「출처」 절의 URL 집합이 같고 lastVerified 가 sources 뒤에 있다', () {
      for (final t in taskIds) {
        final text = md(t);
        final fm = text.split('---')[1];
        final section = text.substring(text.lastIndexOf('### 📌 출처'));
        final listed = RegExp(r'— `([^`]+)` \(')
            .allMatches(section)
            .map((m) => 'https://${m.group(1)}')
            .toSet();
        expect(listed, frontmatterUrls(t), reason: '$t: 프런트매터와 「출처」 절이 어긋났다');
        expect(fm.lastIndexOf('lastVerified:'), greaterThan(fm.lastIndexOf('url: ')),
            reason: '$t: sources 목록 중간에 최상위 키가 끼면 파서가 뒤 출처를 버린다');
      }
    });

    test('해설이 400자를 넘지 않는다 (prescreen explanation-long 과 같은 임계)', () {
      for (final t in taskIds) {
        for (final e in qs(t)) {
          expect('${e['explanation']}'.length, lessThanOrEqualTo(400), reason: '${e['id']}');
        }
      }
    });
  });

  // ── 정밀도 ──────────────────────────────────────────────────────────────────
  group('정밀도 (G4)', () {
    test('공식보다 거친 서술 넷이 0건이고 공식 문구가 그 자리에 있다', () {
      final g4 = RegExp(r'단일 검색 패스|검색이 단일 패스|약정이 있는 모델을 프로비저닝하려면|약정 있는 모델은|권고되는 방식|파티션 전 리전');
      expect(hitsEverywhere(g4), isEmpty);
      expect(md('aip-t1-4'), contains('에이전틱 검색 미지원(관리형 전용)'));
      expect(md('aip-t2-2'), contains('약정 유무와 무관하게'));
      expect(md('aip-t3-3'), contains('다중 리전 추적'));
      expect(correctOf(q('aip-t4-1-q11')), contains('EventBridge'));
    });

    test('단어 필터의 일치 방식을 두 Task 가 같은 뜻으로 적는다', () {
      // 공식 표기가 둘이다 — `(exact match)` 와 `case-insensitive whole-word and
      // whole-phrase matching`. 한쪽만 적으면 부분 문자열·대소문자에서 오해가 난다.
      expect(md('aip-t1-6'), contains('대소문자'));
      expect(md('aip-t3-1'), contains('대소문자'));
      expect('${q('aip-t3-1-q2')['explanation']}', contains('대소문자 무시'));
    });
  });

  // ── 중복 해소 ───────────────────────────────────────────────────────────────
  group('중복 해소 (G3 A~D)', () {
    // 쌍 가드는 「옛 문구 0건」이 아니라 **중복이 사라졌는지**를 본다:
    // 남긴 쪽의 정답에 공통 사실이 있고, 교체한 쪽 어디에도 그 문구가 없다.
    const pairs = <List<String>>[
      // [남긴 문항, 남긴 쪽 정답의 공통 사실, 교체한 문항, 교체한 쪽에 없어야 하는 문구]
      ['aip-t4-3-q4', '어디에도 들어가지 않', 'aip-t5-2-q4', '어느 집합에도'],
      ['aip-t2-5-q3', '입력 토큰', 'aip-t5-2-q3', '입력 토큰 수만'],
      ['aip-t1-2-q13', '온디맨드 추론용 배포', 'aip-t2-2-q4', '온디맨드 추론용 배포'],
      ['aip-t3-3-q12', '신규 고객', 'aip-t3-3-q4', 'Clarify'],
    ];
    for (final p in pairs) {
      test('${p[0]} ↔ ${p[2]}: 공통 사실은 남긴 쪽에만 있다', () {
        expect(correctOf(q(p[0])), contains(p[1]));
        expect(allText(q(p[2])), isNot(contains(p[3])));
      });
    }

    test('교체한 넷이 그 기술이 소유하는 다른 공식 사실을 묻고 출처가 그 사실을 담는다', () {
      final a = q('aip-t5-2-q4');
      expect(correctOf(a), contains('원래 상태 코드'));
      expect(urlsOf(a), contains(endsWith('API_runtime_Converse.html')));
      final b = q('aip-t5-2-q3');
      expect(correctOf(b), contains('청킹 없음'));
      expect(urlsOf(b), contains(endsWith('kb-chunking.html')));
      expect(md('aip-t5-2'), contains('사용자 지정 변환 Lambda 함수에서 직접 청킹'),
          reason: '문항이 학습문서에 없는 사실을 가르치지 않는다');
      final c = q('aip-t2-2-q4');
      expect(correctOf(c), contains('약정 유무와 무관하게'));
      expect(urlsOf(c), contains(endsWith('prov-thru-purchase.html')));
      final d = q('aip-t3-3-q4');
      expect(correctOf(d), allOf(contains('PDF'), contains('Model Registry')));
      expect(urlsOf(d), contains(endsWith('model-cards.html')));
    });
  });
}
