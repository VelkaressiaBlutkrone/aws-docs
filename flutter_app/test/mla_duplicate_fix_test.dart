import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 2026-11-06 전 콘텐츠 2단 검토 **§P3-M1 — MLA 중복·겹침 3쌍** 해소 가드.
///
/// 보고서 정본: `docs/audits/2026-11-06-full-content-review/mla-c01-aif-c01.md` §P3-M1.
///
/// 손댄 3문항은 **전부 `verified: true` 라이브**다(사용자 승인). flip 이 아니라 본문만
/// 바꾸는 핫픽스이고, **정답 인덱스는 교체 전과 같은 자리에 둔다** — 앱이 전 경로에서
/// 보기를 셔플하므로 인덱스는 학습자에게 보이지 않고, 옮기면 `wrongExplanations` 키
/// 집합까지 바꿔야 한다(2026-10-27 SAA 중복 해소 #287 선례).
///
/// ## 중복을 내가 다시 쟀다 — 지표가 의미 중복을 놓친다
///
/// 보고서 §0-3 기준(같은 `sources[].url` 을 공유하는 쌍의 `options[correct]`·`stem`
/// 토큰 자카드)으로 **MLA 321문항을 재측정해 정확히 3쌍**을 얻었다(보고서와 일치).
/// ⚠️ **대조군: 문자열 완전 동일 쌍은 0건**이다 — 그래서 자카드가 필요하다.
/// ⚠️ 같은 스캔을 AIF 에 돌리면 **보고서의 6쌍 중 4쌍만** 걸린다(나머지 둘은 표현이
/// 달라 임계를 넘지 않지만 **같은 사실을 묻는 실제 중복**이다) — **지표는 하한이고
/// 사람이 읽어 판정해야 한다.** AIF 쪽은 별 배치로 둔다.
///
/// ## 쌍별 처리 (교체한 쪽 · 남긴 쪽)
///
/// | 쌍 | 같은 출처 | 자카드 | 교체 |
/// |---|---|---|---|
/// | `mla-t1-3-q1` ↔ `mla-t2-3-q18` | `clarify-bias-metric-class-imbalance` | **1.00** | **q18** |
/// | `mla-t2-3-q13` ↔ `mla-t2-3-q25` | `autopilot-metrics-validation` | 0.62 | **q25** |
/// | `mla-t2-3-q14` ↔ `mla-t2-3-q15` | `debugger-built-in-rules` | 0.50 | **q15** |
///
/// 교체 쪽을 고른 근거:
/// - ①은 **도메인 1 ↔ 도메인 2를 가로질러** 통합 모의고사에서 함께 샘플링될 수 있다.
///   `mla-t1-3-q1` 은 도메인 1의 「사전 훈련 편향 지표 이해(K1)」 자리이고, 교체는
///   Clarify 지표 Task 쪽(`q18`)이 싸다. ⚠️ **`mla-t1-3-q1` 은 내 직전 배치 가드의
///   대조군**이기도 하다(Clarify 를 오답 보기에서만 드는 문항 표본) — 손대지 않는다.
/// - ②는 **20% 절충이 q13 의 「과적합·과소적합 식별(K3)」 맥락에서 정본**이므로 남기고,
///   「성능·시간·비용 절충(SK2)」 자리인 `q25` 를 **이미 붙어 있던 둘째 출처**
///   `MLPERF04-BP05` 의 다른 사실로 돌렸다.
/// - ③은 `q14` 가 **수렴 문제(K5)** 의 유일한 문항이라 개념+규칙 이름을 지키고,
///   `q15`(Debugger 로 컨버전스 디버깅 SK6)를 같은 페이지의 **운영 제약**으로 돌렸다.
///
/// ⚠️ **`skill` 은 원래 값을 유지한다** — `mla_questions_test.dart` 가 태그의 실재·범위와
/// Task 별 커버리지를 보므로 바꾸면 커버리지 집계가 어긋난다.
/// ⚠️ **교체는 가드를 지운다** — 교체 전 `grep -rl` 로 세어 세 문항을 id 로 직접 참조하는
/// 가드가 **0건**임을 확인했다(2026-10-27 SAA 에서 7건이 그렇게 걸렸다).
///
/// ## 공식 근거 (컨트롤러 직접 실측)
///
/// - `clarify-bias-metric-class-imbalance.html` — `CI = (na − nd)/(na + nd)` ·
///   `Positive CI values indicate the facet a has more training samples … a value of 1
///   indicates the data only contains members of the facet a` · `Negative CI values
///   indicate the facet d has more … -1 … only … facet d` · `a value of zero indicates
///   a perfectly equal partition`.
/// - `mlperf04-bp05.html` — `in a credit scoring application, **fairness and
///   explainability** might be primary concerns … a real-time product recommendation
///   system might prioritize **prediction speed and accuracy** over explainability`.
/// - `debugger-built-in-rules.html` — `The maximum numbers of built-in rules that you
///   can attach to a training job is **20**` · `There's **no additional cost** for
///   using the built-in rules`.
void main() {
  const mla = 'assets/content/mla';

  List<Map<String, dynamic>> questionsOf(String task) =>
      ((json.decode(File('$mla/$task.questions.json').readAsStringSync())
                  as Map<String, dynamic>)['questions'] as List)
          .cast<Map<String, dynamic>>();

  Map<String, dynamic> question(String task, String qid) => questionsOf(task)
      .firstWhere((q) => q['id'] == qid, orElse: () => fail('$qid 없음'));

  String correctOf(Map<String, dynamic> q) =>
      (q['options'] as List).cast<String>()[q['correct'] as int];

  String blob(Map<String, dynamic> q) => json.encode(q);

  // ═════════════════════ 대조군 ═════════════════════

  test('대조군: MLA 문항 수와 라이브 상태가 그대로다', () {
    final all = <Map<String, dynamic>>[];
    for (final f in Directory(mla)
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.questions.json'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path))) {
      all.addAll(((json.decode(f.readAsStringSync())
              as Map<String, dynamic>)['questions'] as List)
          .cast<Map<String, dynamic>>());
    }
    expect(all.length, 321, reason: '교체는 문항 수를 바꾸지 않는다');
    expect(all.where((q) => q['verified'] == true).length, 321,
        reason: 'MLA 는 전 문항 공개 상태다 — 교체가 flip 을 건드리지 않았다');
  });

  // ═════════════════════ 쌍 ① CI ═════════════════════

  group('① mla-t1-3-q1 ↔ mla-t2-3-q18 — 같은 사실을 두 번 묻지 않는다', () {
    test('남긴 q1 은 그대로 「어느 지표인가」를 묻는다', () {
      final q = question('mla-t1-3', 'mla-t1-3-q1');
      expect(q['correct'], 0);
      expect(correctOf(q), 'Class Imbalance(CI)');
      expect(q['verified'], true);
    });

    test('교체한 q18: 정답 자리 불변 + 부호 해석으로 각도가 바뀌었다', () {
      final q = question('mla-t2-3', 'mla-t2-3-q18');
      expect(q['correct'], 1, reason: '교체 전과 같은 자리에 둔다');
      expect(q['verified'], true, reason: 'flip 이 아니라 본문 핫픽스다');
      // 중복이 사라졌는지 — 「구성원 수만 재는 지표가 무엇인가」를 더 이상 묻지 않는다.
      expect(correctOf(q).contains('Class Imbalance'), isFalse,
          reason: 'q1 의 정답 문자열을 다시 정답으로 쓰면 중복이 남는다');
      for (final required in ['facet a', 'facet d', '−1']) {
        expect(blob(q), contains(required),
            reason: '공식: Positive → facet a 가 더 많고 1 은 a 만, Negative → d, '
                '-1 은 d 만, 0 은 완전 균등');
      }
    });

    test('교체 후에도 Clarify 상태 표기가 남아 있다', () {
      // ⚠️ 직전 배치(§P3-M2)가 이 문항에 상태 한 줄을 붙였다. 본문을 바꾸면서
      // 지우면 그 가드가 깨지고 학습자가 닫힌 서비스를 현행으로 읽는다.
      final q = question('mla-t2-3', 'mla-t2-3-q18');
      expect(blob(q), contains('신규 고객'));
    });

    test('skill 이 보존됐다', () {
      expect(question('mla-t2-3', 'mla-t2-3-q18')['skill'],
          'ML 훈련 데이터 및 모델에 대한 인사이트를 얻기 위해 SageMaker Clarify에서 사용할 수 있는 지표(K4)');
    });
  });

  // ═════════════════════ 쌍 ② 교차 검증 20% ═════════════════════

  group('② mla-t2-3-q13 ↔ mla-t2-3-q25 — 20% 절충은 한 곳에서만', () {
    test('남긴 q13 이 20% 를 유지한다', () {
      final q = question('mla-t2-3', 'mla-t2-3-q13');
      expect(q['correct'], 0);
      expect(correctOf(q), contains('20%'),
          reason: '과적합·과소적합 식별(K3) 맥락이 이 사실의 정본이다');
    });

    test('교체한 q25: 정답 자리 불변 + 20% 가 사라졌다', () {
      final q = question('mla-t2-3', 'mla-t2-3-q25');
      expect(q['correct'], 2, reason: '교체 전과 같은 자리');
      expect(q['verified'], true);
      expect(blob(q).contains('20%'), isFalse,
          reason: '같은 수치를 두 문항이 정답으로 묻고 있었다');
      for (final required in ['신용', '설명 가능성', '추천']) {
        expect(blob(q), contains(required),
            reason: '공식 MLPERF04-BP05: 신용 평가는 공정성·설명 가능성이 1차 관심, '
                '실시간 추천은 예측 속도·정확도를 우선한다');
      }
    });

    test('출처가 인용 사실을 담는 쪽만 남았다', () {
      final q = question('mla-t2-3', 'mla-t2-3-q25');
      final urls = ((q['sources'] as List))
          .map((s) => ((s as Map)['url'] ?? '').toString())
          .toList();
      expect(urls.any((u) => u.contains('mlperf04-bp05')), isTrue);
      expect(urls.any((u) => u.contains('autopilot-metrics-validation')), isFalse,
          reason: '교차 검증 페이지는 새 본문의 사실을 담지 않는다');
    });

    test('skill 이 보존됐다', () {
      expect(question('mla-t2-3', 'mla-t2-3-q25')['skill'],
          '모델 성능, 훈련 시간, 비용 간의 절충점 평가(SK2)');
    });
  });

  // ═════════════════════ 쌍 ③ vanishing_gradient ═════════════════════

  group('③ mla-t2-3-q14 ↔ mla-t2-3-q15 — 정답 문자열이 겹치지 않는다', () {
    test('남긴 q14 가 개념+규칙 이름을 지킨다', () {
      final q = question('mla-t2-3', 'mla-t2-3-q14');
      expect(q['correct'], 1);
      expect(correctOf(q), contains('vanishing_gradient'),
          reason: '수렴 문제(K5) 의 유일한 문항이다');
    });

    test('교체한 q15: 정답 자리 불변 + 정답이 vanishing_gradient 가 아니다', () {
      final q = question('mla-t2-3', 'mla-t2-3-q15');
      expect(q['correct'], 1, reason: '교체 전과 같은 자리');
      expect(q['verified'], true);
      expect(correctOf(q).contains('vanishing_gradient'), isFalse,
          reason: '두 문항의 정답 문자열이 같은 것이 이 쌍의 결함이었다');
      for (final required in ['20', '추가 비용']) {
        expect(blob(q), contains(required),
            reason: '공식: "maximum numbers of built-in rules … is 20" · '
                '"no additional cost for using the built-in rules"');
      }
    });

    test('skill 이 보존됐다', () {
      expect(question('mla-t2-3', 'mla-t2-3-q15')['skill'],
          'SageMaker Model Debugger를 사용하여 모델 컨버전스 디버깅(SK6)');
    });
  });

  // ═════════════════════ 전수 — 중복이 재발하지 않는다 ═════════════════════

  test('MLA 전수: 같은 출처를 공유하는 쌍의 정답 자카드가 0.33 미만이다', () {
    // 보고서 §0-3 과 같은 기준으로 **재발을 막는 쪽**으로 고정한다.
    // ⚠️ 이 단정이 앞으로의 중복 저작을 잡는다(탐지 규칙을 레포에 남긴다).
    final qs = <Map<String, dynamic>>[];
    for (final f in Directory(mla)
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.questions.json'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path))) {
      qs.addAll(((json.decode(f.readAsStringSync())
              as Map<String, dynamic>)['questions'] as List)
          .cast<Map<String, dynamic>>());
    }
    final token = RegExp(r'[0-9A-Za-z가-힣]{2,}');
    Set<String> toks(String s) =>
        token.allMatches(s).map((m) => m.group(0)!).toSet();
    double jac(Set<String> a, Set<String> b) => (a.isEmpty || b.isEmpty)
        ? 0
        : a.intersection(b).length / a.union(b).length;
    Set<String> urls(Map<String, dynamic> q) => ((q['sources'] as List?) ?? [])
        .map((s) => ((s as Map)['url'] ?? '').toString())
        .toSet();

    var sharedPairs = 0;
    final offenders = <String>[];
    for (var i = 0; i < qs.length; i++) {
      for (var j = i + 1; j < qs.length; j++) {
        if (urls(qs[i]).intersection(urls(qs[j])).isEmpty) continue;
        sharedPairs++;
        final cj = jac(toks(correctOf(qs[i])), toks(correctOf(qs[j])));
        if (cj >= 0.33) {
          offenders.add('${qs[i]['id']}↔${qs[j]['id']} (${cj.toStringAsFixed(2)})');
        }
      }
    }
    // 0건 통과가 "출처를 공유하는 쌍이 없어서"일 수 있다 — 먼저 센다.
    expect(sharedPairs, greaterThan(200),
        reason: '출처 공유 쌍이 급감했다면 이 스캔이 공허하다');
    expect(offenders, isEmpty,
        reason: '같은 출처로 같은 정답을 묻는 쌍이다 — 통합·약점 모의고사가 Task 를 '
            '가로질러 샘플링하므로 한 시험에 함께 나올 수 있다:\n'
            '${offenders.join('\n')}');
  });

  test('대조군: 정답 문자열이 완전히 같은 쌍은 0건이다', () {
    // 이 단정이 0건이어야 위 자카드 스캔이 필요한 이유가 선다(문자열 비교로는
    // 보고서의 3쌍을 **한 건도** 잡지 못했다).
    final correct = <String, String>{};
    final dup = <String>[];
    for (final f in Directory(mla)
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.questions.json'))) {
      for (final q in ((json.decode(f.readAsStringSync())
              as Map<String, dynamic>)['questions'] as List)
          .cast<Map<String, dynamic>>()) {
        final c = correctOf(q).trim();
        if (correct.containsKey(c)) dup.add('${correct[c]}↔${q['id']}');
        correct[c] = q['id'] as String;
      }
    }
    expect(dup, isEmpty);
  });
}
