import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 2026-11-06 전 콘텐츠 2단 검토의 **MLA·AIF 우선순위 2 — 상태 표기·귀속·용어 계열** 가드.
///
/// 보고서 정본: `docs/audits/2026-11-06-full-content-review/mla-c01-aif-c01.md`
/// §P2-M1 · §P2-A1 · §P1b-A1 · §P1b-A2 · §P3-M2 · 그리고 2026-11-06 AIF 배치가
/// 남긴 갭 **G-68**(`aif-t5-2.md` CloudTrail Lake 상태 다섯 자리).
///
/// 공식 재측정은 컨트롤러가 직접 했다. **정답 인덱스는 한 건도 바뀌지 않았다.**
///
/// ## 이 배치가 닫는 것은 **한 계열**이다
///
/// 「인용·언급은 유효한데 **상태나 귀속을 적지 않아** 학습자가 현행으로 읽는다」가
/// 여섯 항목의 공통 결함이다. 그래서 자격증 전수 문맥 규칙으로 함께 닫는다 —
/// **계열을 통째로 닫지 않으면 전수 가드를 초록으로 만들 수 없다**(2026-11-06
/// SOA·CLF 배치에서 반복 확인된 규율).
///
/// ## ⚠️⚠️ 보고서 범위가 세 자리에서 어긋났다
///
/// - **과소 ①** §P2-M1 은 백서를 **MLA 전용**으로 적었지만 `cost-optimization-in-
///   analytics-services.html` 은 **`dea-t1-2.md`** 에도 있다(SAA 는 직전 배치가 닫았다).
/// - **과소 ②** §P3-M2 는 Clarify 상태 누락을 **3문항**(`mla-t4-1-q19`·`q20`·`q21`)으로
///   적고 「같은 파일의 13문항은 달고 있다」고 했지만, **그 파일에 Clarify 언급은 4건이고
///   상태가 있는 것은 1건도 없었다.** 전수로 세면 **18문항 언급 · 상태 4건**이고, 그중
///   **가르치는 층**(`skill`·`stem`·`options[correct]`·`explanation`)에서 드는 **8문항**이
///   대상이다. ⚠️ **오답 보기·출처 제목에만 나오는 9문항은 대상이 아니다** — 거기에
///   상태를 달면 **틀린 보기를 설명하는 문장**이 된다(2026-11-06 AIF Model Monitor 교훈).
/// - **과소 ③** §P1b-A1 은 Guardrails 유해 범주 개수 오류를 **문항 1곳**으로 적었지만
///   **`aif-t2-3.md:205`** 에도 같은 열거(`… Misconduct · Prompt Attack`)가 있다.
///
/// ## ⚠️ 손대면 안 되는 참인 주장
///
/// `aif-t4-1.md` 의 **「Guardrails 정책은 여섯 종류」**(콘텐츠 필터 · 거부 주제 · 단어
/// 필터 · 민감 정보 필터 · 문맥 근거 확인 · 자동 추론 검사)는 **다른 주장이고 참이다.**
/// 결함은 **유해 콘텐츠 「범주」** 개수뿐이다. 둘을 섞으면 참인 서술을 지운다.
///
/// ## 공식 근거 (컨트롤러 직접 실측)
///
/// - `guardrails-content-filters.html` — 정의 절은 `Content filters are supported
///   across the following categories:` 뒤에 **Hate · Insults · Sexual · Violence ·
///   Misconduct 다섯**이고 **Prompt Attack 소제목은 없다.** 반면 콘솔 절은 `You can
///   select the filter for prompt attacks **in the harmful categories**` 라고 적는다 →
///   **공식 내부가 갈리므로 개수를 단정하지 않는다.**
/// - `cloudtrail-lake-service-availability-change.html` — `AWS CloudTrail Lake will no
///   longer be open to new customers starting on **May 31, 2026**` + `Your AWS
///   CloudTrail **Trails, Insights and Aggregated Events are not affected**` +
///   `CloudTrail Lake will only receive critical bug fixes and security updates`.
/// - 백서 5종 — `curl -sL` 로는 전혀 다른 서비스 페이지로 튕기고 **일부러 틀린 슬러그
///   대조군도 같은 곳으로 간다** → 개별 슬러그 변경이 아니라 **가이드 전체의 사람 대상
///   서빙이 꺼진 것**이다. AWS 문서 리더로는 본문이 그대로 나오므로 **인용은 유효하다.**
/// - `machine-learning/latest/dg/*` — `200 r=0` 으로 살아 있지만 첫 문장이 `We are no
///   longer updating the Amazon Machine Learning service or accepting new users for it.`
///   ⭐ **MLA 는 같은 가이드에 「레거시」·「구서비스」 라벨을 이미 붙인다** — AIF 만 없었다.
void main() {
  const content = 'assets/content';

  List<File> questionFiles(String cert) =>
      Directory('$content/$cert')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.questions.json'))
          .toList()
        // ⚠️ `listSync()` 순서는 플랫폼마다 다르다.
        ..sort((a, b) => a.path.compareTo(b.path));

  List<Map<String, dynamic>> questionsOf(File f) =>
      ((json.decode(f.readAsStringSync()) as Map<String, dynamic>)['questions']
              as List)
          .cast<Map<String, dynamic>>();

  Iterable<Map<String, dynamic>> allQuestions(String cert) =>
      questionFiles(cert).expand(questionsOf);

  Map<String, dynamic> question(String cert, String task, String qid) =>
      questionsOf(File('$content/$cert/$task.questions.json'))
          .firstWhere((q) => q['id'] == qid, orElse: () => fail('$qid 없음'));

  String doc(String cert, String id) =>
      File('$content/$cert/$id.md').readAsStringSync();

  String blob(Map<String, dynamic> q) => json.encode(q);

  /// Clarify 를 **가르치는 층**에서 드는가(오답 보기·출처 제목만이면 아니다).
  String teachingLayer(Map<String, dynamic> q) => <String>[
        q['skill'] as String? ?? '',
        q['stem'] as String? ?? '',
        (q['options'] as List).cast<String>()[q['correct'] as int],
        q['explanation'] as String? ?? '',
      ].join('\n');

  // ═════════════════════ 대조군 ═════════════════════

  test('대조군: MLA·AIF 문항을 실제로 읽고 있다', () {
    expect(allQuestions('mla').length, greaterThanOrEqualTo(300),
        reason: 'MLA 는 321문항이다 — 0건 통과가 "파일을 못 읽어서"일 수 있다');
    expect(allQuestions('aif').length, greaterThanOrEqualTo(200),
        reason: 'AIF 는 210문항이다');
  });

  // ═════════════════════ §P2-M1 백서 상태 표기 ═════════════════════

  group('§P2-M1 사람이 열 수 없는 백서에 상태를 적었다', () {
    const papers = <String>[
      'cost-modeling-data-lakes/cost-optimization-in-analytics-services.html',
      'ml-best-practices-healthcare-life-sciences/model-interpretability.html',
      'build-secure-enterprise-ml-platform/governance-and-control.html',
      'build-secure-enterprise-ml-platform/networking-architecture.html',
      'building-data-lakes/data-cataloging.html',
    ];
    // 상태 표기로 인정하는 표지 — AIF `AWS CAF for AI` 선례와 같은 세 요소 중
    // 「브라우저로 튕긴다」를 대표 표지로 쓴다.
    const marker = '브라우저';

    test('문항 전수(MLA·DEA): 백서를 출처로 쓰면 제목에 상태가 있다', () {
      final offenders = <String>[];
      for (final cert in ['mla', 'dea', 'saa', 'aif', 'clf', 'soa', 'dva']) {
        final dir = Directory('$content/$cert');
        if (!dir.existsSync()) continue;
        for (final q in allQuestions(cert)) {
          for (final s in ((q['sources'] as List?) ?? const [])) {
            final url = ((s as Map)['url'] ?? '').toString();
            if (!papers.any(url.contains)) continue;
            final title = (s['title'] ?? '').toString();
            if (!title.contains(marker)) {
              offenders.add('${q['id']} ← ${url.split('/').last}');
            }
          }
        }
      }
      expect(offenders, isEmpty,
          reason: '인용은 유효하지만 학습자가 각주를 누르면 인용한 사실이 없는 '
              '다른 페이지에 떨어진다:\n${offenders.join('\n')}');
    });

    test('md 전수: 백서를 적는 참고자료 줄에 상태가 있다', () {
      final offenders = <String>[];
      for (final cert in ['mla', 'dea', 'saa', 'aif', 'clf', 'soa', 'dva']) {
        final dir = Directory('$content/$cert');
        if (!dir.existsSync()) continue;
        for (final f in dir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.md'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path))) {
          final lines = f.readAsStringSync().split('\n');
          for (var i = 0; i < lines.length; i++) {
            if (!papers.any(lines[i].contains)) continue;
            // 프런트매터 `url:` 줄은 제목을 담지 않으므로 대상이 아니다.
            if (lines[i].trimLeft().startsWith('url:')) continue;
            if (!lines[i].contains(marker)) {
              offenders.add('${f.uri.pathSegments.last}:${i + 1}');
            }
          }
        }
      }
      expect(offenders, isEmpty, reason: offenders.join(' · '));
    });

    test('대조군: 인용을 지우지 않았고 DEA 도 포함됐다', () {
      // ⚠️ 보고서는 MLA 전용으로 적었지만 같은 백서가 `dea-t1-2.md` 에도 있었다.
      expect(doc('dea', 'dea-t1-2').contains('cost-optimization-in-analytics-services'),
          isTrue, reason: '참인 인용을 지우는 것이 더 나쁘다');
      expect(doc('mla', 'mla-t4-3').contains('data-cataloging.html'), isTrue);
      // `mla-t4-3-q12` 의 둘째 출처는 **사람이 열 수 있는 유일한 근거**다 — 지우지 않는다.
      final q12 = question('mla', 'mla-t4-3', 'mla-t4-3-q12');
      expect(blob(q12).contains('list_sagemaker'), isTrue,
          reason: '조건 키 가드레일의 사람이 열 수 있는 근거다');
      expect(q12['correct'], 0, reason: '출처 상태 표기는 사실을 바꾸지 않는다');
    });
  });

  // ═════════════════════ §P3-M2 Clarify 상태 ═════════════════════

  group('§P3-M2 Clarify 를 가르치는 층에서 드는 문항에 상태가 있다', () {
    final status = RegExp(r'신규 고객|유지 관리');

    test('MLA 전수: 가르치는 층에서 Clarify 를 들면 상태를 함께 적는다', () {
      final offenders = <String>[];
      for (final q in allQuestions('mla')) {
        if (!teachingLayer(q).contains('Clarify')) continue;
        if (!status.hasMatch(blob(q))) offenders.add(q['id'] as String);
      }
      offenders.sort();
      expect(offenders, isEmpty,
          reason: '학습자는 오답노트·모의고사 화면에서 md 의 상태 표를 보지 못한다: '
              '${offenders.join(', ')}');
    });

    test('대조군: 오답 보기·출처에만 나오는 문항은 대상이 아니다', () {
      // 거기에 상태를 달면 **틀린 보기를 설명하는 문장**이 된다.
      final onlyWrong = <String>[];
      for (final q in allQuestions('mla')) {
        final b = blob(q);
        if (!b.contains('Clarify')) continue;
        if (teachingLayer(q).contains('Clarify')) continue;
        onlyWrong.add(q['id'] as String);
      }
      expect(onlyWrong.length, greaterThanOrEqualTo(5),
          reason: '이 구분이 사라지면 규칙이 과잉으로 번진 것이다: $onlyWrong');
      // 그중 하나를 짚어 상태 문구가 들어가지 않았음을 고정한다.
      final q1 = question('mla', 'mla-t1-3', 'mla-t1-3-q1');
      expect(teachingLayer(q1).contains('Clarify'), isFalse);
    });
  });

  // ═════════════════════ §P2-A1 은퇴 가이드 귀속 ═════════════════════

  group('§P2-A1 은퇴한 Amazon Machine Learning 가이드에 라벨이 붙었다', () {
    final legacy = RegExp(r'레거시|구서비스|신규 사용자');

    test('전 자격증 전수(문항): 그 가이드를 인용하면 상태를 적는다', () {
      final offenders = <String>[];
      for (final cert in ['aif', 'mla', 'saa', 'clf', 'soa', 'dea', 'dva']) {
        if (!Directory('$content/$cert').existsSync()) continue;
        for (final q in allQuestions(cert)) {
          for (final s in ((q['sources'] as List?) ?? const [])) {
            final url = ((s as Map)['url'] ?? '').toString();
            if (!url.contains('machine-learning/latest/dg/')) continue;
            if (!legacy.hasMatch((s['title'] ?? '').toString())) {
              offenders.add(q['id'] as String);
            }
          }
        }
      }
      expect(offenders, isEmpty,
          reason: '아무 표시 없이 「공식 문서」로 인용하면 학습자가 현행 안내로 '
              '읽는다: ${offenders.join(', ')}');
    });

    test('aif-t1-2: 정답 불변 + 해설의 귀속 층이 정확해졌다', () {
      for (final e in {'aif-t1-2-q1': 1, 'aif-t1-2-q3': 2}.entries) {
        final q = question('aif', 'aif-t1-2', e.key);
        expect(q['correct'], e.value, reason: '인용된 사실은 전부 정확하다');
      }
      // md 참고자료에도 라벨이 붙는다.
      final md = doc('aif', 'aif-t1-2');
      final line = md
          .split('\n')
          .firstWhere((l) => l.contains('when-to-use-machine-learning'),
              orElse: () => '');
      expect(legacy.hasMatch(line) || md.contains('신규 사용자'), isTrue);
    });

    test('대조군: MLA 의 선례 라벨은 그대로다', () {
      // ⭐ MLA 는 같은 가이드에 이미 「레거시」·「구서비스」를 붙인다 — 그 선례를 옮겼다.
      expect(doc('mla', 'mla-t2-2').contains('(레거시)'), isTrue);
      final hits = allQuestions('mla')
          .where((q) => blob(q).contains('구서비스'))
          .length;
      expect(hits, greaterThanOrEqualTo(4),
          reason: '선례가 사라졌다면 이 가드의 기준이 흔들린다');
    });
  });

  // ═════════════════════ G-68 CloudTrail Lake ═════════════════════

  test('G-68 aif-t5-2.md 가 CloudTrail Lake 상태를 적는다', () {
    // ⭐ 같은 레포 `mla-t4-3.md:477` 이 이미 적는다 — AIF 만 빠져 있었다.
    final t52 = doc('aif', 'aif-t5-2');
    expect(t52.contains('CloudTrail Lake'), isTrue, reason: '대조군 — 언급은 남는다');
    expect(t52.contains('2026-05-31'), isTrue,
        reason: '공식: "no longer be open to new customers starting on May 31, 2026"');
    expect(t52.contains('신규 고객'), isTrue);
    // 공식이 함께 못박는 것 — 추적·Insights·집계 이벤트는 영향이 없다.
    expect(t52.contains('추적'), isTrue,
        reason: '"Your AWS CloudTrail Trails, Insights and Aggregated Events are '
            'not affected" — CloudTrail 자체가 닫힌 것으로 읽히면 안 된다');
  });

  // ═════════════════════ §P1b-A1 Guardrails 유해 범주 ═════════════════════

  group('§P1b-A1 유해 콘텐츠 범주 개수를 단정하지 않는다', () {
    test('AIF 전수: 유해 범주 열거에 Prompt Attack 을 넣지 않는다', () {
      // 공식 정의 절은 다섯이고 Prompt Attack 소제목은 없다. 콘솔 절은 같은 화면에
      // 둔다고 적어 **공식 내부가 갈리므로 개수를 단정하지 않는다**(규율 5-5).
      final offenders = <String>[];
      for (final f in Directory('$content/aif')
          .listSync()
          .whereType<File>()
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path))) {
        if (!f.path.endsWith('.md') && !f.path.endsWith('.questions.json')) {
          continue;
        }
        final lines = f.readAsStringSync().split('\n');
        for (var i = 0; i < lines.length; i++) {
          final l = lines[i];
          if (!l.contains('Misconduct')) continue;
          if (!l.contains('Prompt Attack') && !l.contains('프롬프트 공격')) continue;
          // ⚠️ 탐지기를 좁혔다 — **공식의 갈림을 설명하는 줄은 올바른 처리**다.
          // `aif-t5-1.md` 가 「정의 절은 다섯이고 **개요가 거기에 더해** …」로 적어
          // 두 공식 서술을 가르친다. 그 줄을 걸면 **참인 서술을 지우게** 된다.
          final explainsSplit = l.contains('더해') ||
              l.contains('별도') ||
              l.contains('개수는 외우지 않');
          if (!explainsSplit) {
            offenders.add('${f.uri.pathSegments.last}:${i + 1}');
          }
        }
      }
      expect(offenders, isEmpty,
          reason: '정의 절의 다섯 범주에 Prompt Attack 은 없다(전담 페이지가 따로 '
              '있다): ${offenders.join(' · ')}');
    });

    test('aif-t4-1-q3: 정답 불변 + 개수 단정 제거', () {
      final q = question('aif', 'aif-t4-1', 'aif-t4-1-q3');
      expect(q['correct'], 1, reason: '자동 추론 검사가 정답인 것은 그대로다');
      final w0 = (q['wrongExplanations'] as Map<String, dynamic>)['0'] as String;
      expect(w0.contains('여섯 종류'), isFalse);
      expect(w0.contains('Misconduct'), isTrue, reason: '대조군 — 범주 열거는 남는다');
    });

    test('대조군: 「정책 여섯 종류」는 다른 참인 주장이라 그대로다', () {
      // 콘텐츠 필터 · 거부 주제 · 단어 필터 · 민감 정보 필터 · 문맥 근거 확인 ·
      // 자동 추론 검사 — 이것은 공식과 맞다. 범주 개수와 섞으면 참인 서술을 지운다.
      final t41 = doc('aif', 'aif-t4-1');
      expect(t41.contains('정책은 여섯 종류'), isTrue,
          reason: '이 서술이 사라졌다면 규칙이 과잉으로 번진 것이다');
      // 이미 옳게 적던 자리도 그대로다 — `aif-t5-1.md` 는 **공식의 갈림을 설명**해
      // 두 서술을 가르친다. 탐지기가 이 줄을 걸면 참인 서술을 지우게 된다.
      final t51 = doc('aif', 'aif-t5-1');
      expect(t51.contains('위법 행위(Misconduct)'), isTrue);
      expect(t51.contains('더해'), isTrue,
          reason: '이 줄의 예외는 「갈림을 설명한다」는 성질에서 온다 — 그 성질이 '
              '사라지면 예외도 성립하지 않는다');
    });
  });

  // ═════════════════════ §P1b-A2 「지속적인 사전 훈련」 ═════════════════════

  group('§P1b-A2 공식 가이드 표기로 통일됐다', () {
    test('AIF 문항 전수: 「계속 사전 훈련」이 0건이다', () {
      // ⚠️ 기존 `aif_facts_test.dart` 의 가드는 **md 만** 순회해 문항이 새어 나갔다.
      final offenders = <String>[];
      for (final f in questionFiles('aif')) {
        if (f.readAsStringSync().contains('계속 사전 훈련')) {
          offenders.add(f.uri.pathSegments.last);
        }
      }
      expect(offenders, isEmpty,
          reason: '공식 한국어 가이드는 「지속적인 사전 훈련」을 쓴다(2개소), '
              '「계속 사전 훈련」은 0개소: $offenders');
    });

    test('aif-t2-2-q11: 정답 불변 + 공식 표기', () {
      final q = question('aif', 'aif-t2-2', 'aif-t2-2-q11');
      expect(q['correct'], 0);
      expect(blob(q).contains('지속적인 사전 훈련'), isTrue);
    });

    test('대조군: md 의 의도된 병기 한 곳은 그대로다', () {
      // `aif-t3-3.md` 용어 표가 「계속 사전 훈련으로도 번역됩니다」로 병기한다 —
      // 학습자가 다른 교재에서 만날 표기이므로 0건으로 만들지 않는다.
      expect(doc('aif', 'aif-t3-3').contains('계속 사전 훈련'), isTrue);
    });
  });
}
