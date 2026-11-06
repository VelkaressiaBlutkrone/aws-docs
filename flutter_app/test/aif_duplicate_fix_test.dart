import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// AIF-C01 중복·겹침 6쌍 해소 가드 — 2026-11-06 전 콘텐츠 2단 검토 §P1b-A3.
///
/// ## 무엇을 고정하는가
///
/// 보고서가 든 6쌍을 본문 전수로 재확인했고 **여섯 쌍 모두 실재 중복**이었다.
/// 각 쌍에서 **그 사실을 공식 목표가 소유하는 쪽**을 남기고 다른 쪽을 새 문항으로
/// 교체했다. 교체 방향은 추측이 아니라 `exam_guides/AIF-C01.json`의 목표 본문
/// 실측으로 정했다(아래 표의 「근거」).
///
/// | 쌍 | 남김 | 교체 | 근거(목표 본문) |
/// |---|---|---|---|
/// | ① 접지/관련성 | `aif-t5-1-q13` | `aif-t4-1-q4` | 5.1.5가 「할루시네이션 감지 방법 및 접지 기법」을 직접 명시 |
/// | ② ROI 동적 KPI | `aif-t2-2-q13` | `aif-t3-4-q13` | 2.2.4가 「비즈니스 가치와 지표 결정」 |
/// | ③ ROI 대시보드 범주 | `aif-t2-2-q14` | `aif-t3-4-q15` | 동일 |
/// | ④ 편향 완화 검증 | `aif-t4-1-q10` | `aif-t3-3-q14` | 4.1.5가 「균형 잡힌 데이터세트」 |
/// | ⑤ 캐싱 × 배치 | `aif-t2-3-q13` | `aif-t2-1-q7` | 2.3.4가 「프로비저닝 처리량」까지 들어 t2-3이 더 완전 |
/// | ⑥ 증류 과금 | `aif-t3-1-q12` | `aif-t3-3-q5` | 3.1.5가 「사용자 지정 접근법의 비용 절충점」 |
///
/// ## 비자명한 규율
///
/// ⚠️ **`skill`은 보존한다.** `aif_questions_test.dart`가 Task별로 「모든 목표가
/// 최소 한 문항에 덮인다」를 단정하므로, 교체 문항이 원본 `skill`을 잃으면
/// 커버리지 단정이 먼저 깨진다. `section`·`difficulty`도 그대로 둔다.
///
/// ⚠️ **정답은 교체 전과 같은 자리에 둔다.** 앱이 전 경로에서 선택지를 셔플하므로
/// 인덱스는 학습자에게 보이지 않고, 옮기면 `wrongExplanations` 키 집합까지
/// 바뀐다. 그래서 각 쌍의 첫 단정이 「정답 인덱스 불변」이다.
///
/// ⚠️ **자카드 불변식은 6쌍 중 3쌍만 잡는다**(교체 전 실측). 같은 출처를
/// 공유하는 쌍의 정답 토큰 자카드로 레포 전수를 스캔하면 ②(0.74)·⑤(0.43)·
/// ⑥(0.33)만 임계를 넘고 **①·③·④는 걸리지 않는다** — 표현이 다른데 같은
/// 사실을 묻는 **의미 중복**이라 사람이 읽어야 보인다. 보고서가 유사도를
/// 「—」로 비워 둔 쌍이 바로 그런 것들이다. 그래서 전수 불변식과 **쌍별 명시
/// 단정**을 함께 둔다(MLA 판과 같은 구조).
///
/// ⚠️ **AIF 문항은 전부 드래프트다**(`verified: false`). 교체는 사실 서술을
/// 바꾸는 작업이고 flip과 무관하며, 교체 스크립트가 원본 `verified` 값을 그대로
/// 옮기게 해 사람의 서명을 AI가 대신 쓰지 않았다.
void main() {
  const dir = 'assets/content/aif';

  Map<String, Map<String, dynamic>> readTask(String taskId) {
    final raw = File('$dir/$taskId.questions.json').readAsStringSync();
    final decoded = json.decode(raw);
    final list = decoded is List ? decoded : (decoded as Map)['questions'];
    return {
      for (final q in list as List<dynamic>)
        '${(q as Map<String, dynamic>)['id']}': q,
    };
  }

  final cache = <String, Map<String, Map<String, dynamic>>>{};

  Map<String, dynamic> q(String qid) {
    final taskId = qid.split('-').take(3).join('-');
    final task = cache.putIfAbsent(taskId, () => readTask(taskId));
    final found = task[qid];
    expect(found, isNotNull, reason: '$qid: 문항을 찾을 수 없다');
    return found!;
  }

  /// 문항 전체(지문·보기·해설·오답 근거·출처)를 한 문자열로 본다.
  /// 같은 오류가 보기와 `wrongExplanations` 양쪽에 있던 사례가 반복됐기 때문이다.
  String allText(String qid) => json.encode(q(qid));

  String correctOption(String qid) {
    final question = q(qid);
    return '${(question['options'] as List<dynamic>)[question['correct'] as int]}';
  }

  // ── 대조군: 문항 자산이 실제로 읽힌다 ────────────────────────────────
  //
  // 이것이 없으면 아래 「옛 문구 0건」 단정들이 **빈 문자열**을 상대로 조용히
  // 통과할 수 있다.
  test('대조군: 6쌍 12문항이 모두 읽히고 구조가 성립한다', () {
    const ids = [
      'aif-t5-1-q13', 'aif-t4-1-q4',
      'aif-t2-2-q13', 'aif-t3-4-q13',
      'aif-t2-2-q14', 'aif-t3-4-q15',
      'aif-t4-1-q10', 'aif-t3-3-q14',
      'aif-t2-3-q13', 'aif-t2-1-q7',
      'aif-t3-1-q12', 'aif-t3-3-q5',
    ];
    for (final id in ids) {
      expect((q(id)['options'] as List<dynamic>).length, 4, reason: id);
      expect(allText(id).length, greaterThan(400), reason: '$id: 본문이 너무 짧다');
    }
  });

  // ── 쌍별 단정 ────────────────────────────────────────────────────────
  //
  // 각 쌍은 세 가지를 본다:
  //   (a) 교체 쪽 정답 인덱스가 불변이다
  //   (b) 중복이 사라졌다 — 공통 사실이 남긴 쪽 `options[correct]`에 있고,
  //       교체 쪽 **어디에도** 없다
  //   (c) 교체 쪽이 새 공식 사실을 담는다
  //
  // (b)는 「옛 문구 0건」이 아니라 **중복이 사라졌는지**를 보는 것이다.

  group('① 접지 vs 관련성 판정 — t5-1-q13을 남기고 t4-1-q4를 교체', () {
    test('정답 인덱스 불변: t4-1-q4 = 3', () {
      expect(q('aif-t4-1-q4')['correct'], 3);
      expect(q('aif-t4-1-q4')['skill'], '4.1.2', reason: '커버리지 단정이 skill을 본다');
      expect(q('aif-t4-1-q4')['section'], 'guardrails');
    });

    test('중복 해소: 공식 London/Tokyo 판정 예는 t5-1-q13만 묻는다', () {
      expect(correctOption('aif-t5-1-q13'), contains('관련성 점수가 낮은'));
      final replaced = allText('aif-t4-1-q4');
      for (final phrase in ['capital of UK', 'capital of Japan', '관련성 점수', '접지 소스']) {
        expect(replaced, isNot(contains(phrase)),
            reason: 'aif-t4-1-q4에 중복 사실("$phrase")이 남아 있다');
      }
    });

    test('신규 공식 사실: 도구 사용 경로의 민감 정보 필터 미평가 필드', () {
      final text = allText('aif-t4-1-q4');
      for (final phrase in ['toolUse.input', 'toolResult', 'toolSpec', '텍스트 콘텐츠만']) {
        expect(text, contains(phrase), reason: '새 공식 사실("$phrase")이 없다');
      }
      expect(text, contains('guardrails-sensitive-filters.html'));
    });
  });

  group('② ROI는 동적 KPI — t2-2-q13을 남기고 t3-4-q13을 교체', () {
    test('정답 인덱스 불변: t3-4-q13 = 1', () {
      expect(q('aif-t3-4-q13')['correct'], 1);
      expect(q('aif-t3-4-q13')['skill'], '3.4.5');
      expect(q('aif-t3-4-q13')['section'], 'alignment-metrics');
    });

    test('중복 해소: ROI 동적 KPI 단정은 t2-2-q13만 묻는다', () {
      expect(correctOption('aif-t2-2-q13'), contains('동적 KPI'));
      final replaced = allText('aif-t3-4-q13');
      for (final phrase in ['동적 KPI', '정적 계산', 'prod-value.html']) {
        expect(replaced, isNot(contains(phrase)),
            reason: 'aif-t3-4-q13에 중복 사실("$phrase")이 남아 있다');
      }
    });

    test('신규 공식 사실: 피드백 네 경로가 최소 설계다 (AGENTOPS02-BP04)', () {
      final text = allText('aif-t3-4-q13');
      for (final phrase in [
        '자동 품질 지표',
        '명시적 사용자 피드백',
        '암시적 행동 신호',
        '비즈니스 결과 지표',
        'agentops02-bp04.html',
      ]) {
        expect(text, contains(phrase), reason: '새 공식 사실("$phrase")이 없다');
      }
    });
  });

  group('③ ROI 대시보드 범주 — t2-2-q14를 남기고 t3-4-q15를 교체', () {
    test('정답 인덱스 불변: t3-4-q15 = 0', () {
      expect(q('aif-t3-4-q15')['correct'], 0);
      expect(q('aif-t3-4-q15')['skill'], '3.4.5');
      expect(q('aif-t3-4-q15')['difficulty'], 'foundational');
    });

    test('중복 해소: 재무 지표/비즈니스 가치 지표 분류는 t2-2-q14만 묻는다', () {
      expect(correctOption('aif-t2-2-q14'), contains('절약 시간'));
      final replaced = allText('aif-t3-4-q15');
      for (final phrase in ['재무 지표', '비즈니스 가치 지표', 'prod-value.html', 'CSAT']) {
        expect(replaced, isNot(contains(phrase)),
            reason: 'aif-t3-4-q15에 중복 사실("$phrase")이 남아 있다');
      }
    });

    test('신규 공식 사실: 인력 공정 베이스라인의 숨은 비용', () {
      final text = allText('aif-t3-4-q15');
      for (final phrase in ['실패 비용', '놓친 사업 기회', 'assessing-costs.html']) {
        expect(text, contains(phrase), reason: '새 공식 사실("$phrase")이 없다');
      }
    });
  });

  group('④ 편향 완화 재검증 — t4-1-q10을 남기고 t3-3-q14를 교체', () {
    test('정답 인덱스 불변: t3-3-q14 = 2', () {
      expect(q('aif-t3-3-q14')['correct'], 2);
      expect(q('aif-t3-3-q14')['skill'], '3.3.3');
      expect(q('aif-t3-3-q14')['section'], 'data-prep');
    });

    test('중복 해소: 교차 집단 불균형 검증은 t4-1-q10만 묻는다', () {
      expect(correctOption('aif-t4-1-q10'), contains('교차 집단'));
      final replaced = allText('aif-t3-3-q14');
      for (final phrase in ['교차 집단', '공정성 문제', 'raidp03-bp02.html', '계층 추출', '통계적 검정력']) {
        expect(replaced, isNot(contains(phrase)),
            reason: 'aif-t3-3-q14에 중복 사실("$phrase")이 남아 있다');
      }
    });

    test('신규 공식 사실: 미세 조정 데이터 파이프라인과 사람 접근 제거', () {
      final text = allText('aif-t3-3-q14');
      for (final phrase in ['포이즈닝', '사람의 접근', 'best-practices-data.html']) {
        expect(text, contains(phrase), reason: '새 공식 사실("$phrase")이 없다');
      }
    });
  });

  group('⑤ 캐싱 × 배치 제약 — t2-3-q13을 남기고 t2-1-q7을 교체', () {
    test('정답 인덱스 불변: t2-1-q7 = 3', () {
      expect(q('aif-t2-1-q7')['correct'], 3);
      expect(q('aif-t2-1-q7')['skill'], '2.1.4');
      expect(q('aif-t2-1-q7')['section'], 'token-pricing');
    });

    test('중복 해소: 캐싱이 배치 추론에서 미지원이라는 사실은 t2-3-q13만 묻는다', () {
      expect(correctOption('aif-t2-3-q13'), contains('배치 추론 API에서는 지원되지 않'));
      final replaced = allText('aif-t2-1-q7');
      for (final phrase in ['프롬프트 캐싱', '배치 추론', 'prompt-caching.html', 'batch-inference.html']) {
        expect(replaced, isNot(contains(phrase)),
            reason: 'aif-t2-1-q7에 중복 사실("$phrase")이 남아 있다');
      }
    });

    test('신규 공식 사실: 지연 최적화 쿼터 도달 시 표준 요율 과금', () {
      final text = allText('aif-t2-1-q7');
      for (final phrase in [
        '사용량 쿼터',
        '표준 지연',
        'latency-optimized-inference.html',
        '프리뷰',
      ]) {
        expect(text, contains(phrase), reason: '새 공식 사실("$phrase")이 없다');
      }
    });
  });

  group('⑥ 증류 과금 — t3-1-q12를 남기고 t3-3-q5를 교체', () {
    test('정답 인덱스 불변: t3-3-q5 = 1', () {
      expect(q('aif-t3-3-q5')['correct'], 1);
      expect(q('aif-t3-3-q5')['skill'], '3.3.1');
      expect(q('aif-t3-3-q5')['section'], 'distillation');
    });

    test('중복 해소: 교사 추론 추가 과금은 t3-1-q12만 묻는다', () {
      expect(correctOption('aif-t3-1-q12'), contains('추가 요금'));
      final replaced = allText('aif-t3-3-q5');
      for (final phrase in ['추가 요금', '온디맨드 추론 요율', '15,000', '15k']) {
        expect(replaced, isNot(contains(phrase)),
            reason: 'aif-t3-3-q5에 중복 사실("$phrase")이 남아 있다');
      }
    });

    test('신규 공식 사실: 호출 로그 프롬프트-응답 쌍 경로의 교사 모델 일치 요건', () {
      final text = allText('aif-t3-3-q5');
      for (final phrase in ['호출 로그', '일치해야', '사용되지 않', 'model-distillation.html']) {
        expect(text, contains(phrase), reason: '새 공식 사실("$phrase")이 없다');
      }
    });
  });

  // ── 전수 재발 가드 ───────────────────────────────────────────────────
  //
  // ⚠️ 이 불변식은 **하한**이다. 위 주석대로 ③·④는 자카드 0.08·0.13으로
  // 임계 아래였다 — 지표가 의미 중복을 놓치므로 쌍별 단정이 함께 있어야 한다.
  // 그래도 「같은 출처를 공유하면서 정답 문장이 겹치는」 유형의 재발은 막는다.

  const allTaskIds = [
    'aif-t1-1', 'aif-t1-2', 'aif-t1-3',
    'aif-t2-1', 'aif-t2-2', 'aif-t2-3',
    'aif-t3-1', 'aif-t3-2', 'aif-t3-3', 'aif-t3-4',
    'aif-t4-1', 'aif-t4-2',
    'aif-t5-1', 'aif-t5-2',
  ];

  Set<String> tokens(String text) => text
      .replaceAll(RegExp(r'[^0-9A-Za-z가-힣 ]'), ' ')
      .split(RegExp(r'\s+'))
      .where((t) => t.length > 1)
      .toSet();

  double jaccard(Set<String> a, Set<String> b) {
    if (a.isEmpty || b.isEmpty) return 0;
    return a.intersection(b).length / a.union(b).length;
  }

  List<Map<String, dynamic>> allQuestions() {
    final out = <Map<String, dynamic>>[];
    for (final taskId in allTaskIds) {
      out.addAll(readTask(taskId).values);
    }
    return out;
  }

  Set<String> sourceUrls(Map<String, dynamic> question) => {
        for (final s in (question['sources'] as List<dynamic>? ?? []))
          '${(s as Map<String, dynamic>)['url']}',
      };

  test('대조군: AIF 210문항이 읽히고 출처를 공유하는 쌍이 충분히 많다', () {
    final questions = allQuestions();
    expect(questions.length, greaterThanOrEqualTo(200),
        reason: 'AIF 14 Task × 15문항 = 210이 읽혀야 한다');
    var shared = 0;
    for (var i = 0; i < questions.length; i++) {
      for (var j = i + 1; j < questions.length; j++) {
        if (sourceUrls(questions[i]).intersection(sourceUrls(questions[j])).isNotEmpty) {
          shared++;
        }
      }
    }
    expect(shared, greaterThan(200),
        reason: '출처 공유 쌍이 이렇게 적으면 아래 불변식이 공허하다 (실측 $shared)');
  });

  test('대조군: 정답 문장이 문자열로 완전히 같은 쌍은 없다', () {
    // 그래서 문자열 비교가 아니라 자카드가 필요하다 — 이 6쌍은 표현을 달리
    // 쓴 중복이었고, 문자열 동일 비교로는 한 건도 잡히지 않는다.
    final questions = allQuestions();
    final seen = <String, String>{};
    for (final question in questions) {
      final key = '${(question['options'] as List<dynamic>)[question['correct'] as int]}';
      expect(seen.containsKey(key), isFalse,
          reason: '${question['id']}와 ${seen[key]}의 정답 문장이 완전히 같다');
      seen[key] = '${question['id']}';
    }
  });

  test('출처를 공유하는 쌍의 정답 자카드가 0.33 미만이다', () {
    final questions = allQuestions();
    final cachedTokens = {
      for (final question in questions)
        '${question['id']}': tokens(
            '${(question['options'] as List<dynamic>)[question['correct'] as int]}'),
    };
    final offenders = <String>[];
    for (var i = 0; i < questions.length; i++) {
      for (var j = i + 1; j < questions.length; j++) {
        final a = questions[i];
        final b = questions[j];
        if (sourceUrls(a).intersection(sourceUrls(b)).isEmpty) continue;
        final score = jaccard(cachedTokens['${a['id']}']!, cachedTokens['${b['id']}']!);
        if (score >= 0.33) {
          offenders.add('${a['id']} ↔ ${b['id']} (${score.toStringAsFixed(2)})');
        }
      }
    }
    expect(offenders, isEmpty,
        reason: '같은 출처를 공유하면서 정답이 겹치는 쌍이 생겼다:\n${offenders.join('\n')}');
  });
}
