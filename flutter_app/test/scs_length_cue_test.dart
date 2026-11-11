import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

/// SCS **길이 단서 제거 회귀 가드** — 2026-11-11 외부 검수 보고 §4 5단계.
///
/// ## 보고가 집어낸 것
///
/// **정답이 유일하게 가장 긴 선택지인 문항이 227/240(94.6%)**이었다(정답 길이 중앙값
/// 105자 · 오답 44자). 「제일 긴 것 고르기」만으로 거의 맞으므로 **모의고사 점수가
/// 실력을 반영하지 못한다** — 이 뱅크의 가장 큰 결함이고 CLF 51% · SAA 69%보다 심하다.
///
/// ## ⚠️⚠️ 측정이 보고의 처방을 부분적으로 반증했다
///
/// 보고 P-2 는 「정답은 결론 한 문장(60자 안팎)으로 줄이고 근거는 해설로 옮긴다」였다.
/// 240문항을 전수로 재서 갈라 보면:
///
/// - 정답 보기를 (첫 문장 | 나머지)로 가르면 **첫 문장 중앙값이 54자**이고,
///   **94/202 문항에서 첫 문장이 최장 오답보다 짧아진다**(「안 됩니다.」 6자 대 오답
///   54자). 즉 보고대로 하면 **길이 단서가 반대 방향으로 생긴다.**
/// - 나머지(근거)의 **해설 토큰 커버리지 중앙값이 0.76**이라 95문항은 이미 해설에
///   있지만, **47문항은 한 문장인데 길다**(첫 문장 분리로 해결되지 않는다).
///
/// ⭐ **원인은 「정답이 정확하려고 길어진다」다.** `t1-2-q14` 의 정답은 「만든 뒤 수집과
/// 게시 시작까지 몇 분이 걸립니다」(27자)로 정확하고, 오답은 같은 사실을 「레코드는
/// 실시간으로 나타납니다」(16자)로 **짧게 틀리게** 적었다. 그래서 **주 수단은 정답
/// 줄이기가 아니라 오답을 같은 정밀도로 올리는 것**이고, 그러면 오답이 더 그럴듯해져
/// **교육 가치도 오른다**(보고의 「오답은 그럴듯한 오개념 + 이유로」와 같은 방향).
///
/// ## 이 가드가 고정하는 것
///
/// 처리한 문항에서 **정답 ÷ 최장 오답 ≤ 1.3** 과 **정답이 최단 오답보다 짧지 않다**를
/// 함께 본다. 뒤쪽이 없으면 「정답만 짧게 깎는」 반대 방향 결함을 통과시킨다.
///
/// ⚠️ **🟡·보류 문항은 이 배치에서 제외했다.** 보고 §4 6단계가 그 문항의 본문을 바꾸거나
/// 교체하므로, 먼저 길이를 맞추면 **재작업**이 된다(실측: cue 202 중 **56문항이 6단계
/// 대상**이고 146문항만 순수 5단계다). 6단계에서 내용과 길이를 함께 처리한다.
///
/// ## 배치 기록
///
/// - **배치 1**(2026-11-11) — `t1-1` 3 + `t1-2` 8 = 11문항. 전수 cue 202 → 191.
/// - **배치 2**(2026-11-11) — `t1-3` 9문항. 전수 cue 191 → **182**.
///   ⚠️ **반대 방향 단정이 두 번 막았다** — 초안에서 `q2`(0.85배)·`q3`(0.95배)가 정답을
///   최단 오답보다 **짧게** 깎고 있었다. 1.3배 상한만 보는 가드였다면 통과했을 자리다.
///   ⚠️ **`scs-t1-3.questions.json` 은 끝에 개행이 있다**(`t1-1`·`t1-2` 는 없었다) —
///   왕복 재현 대조군이 그것을 잡았으므로 **파일마다 실측한다.**
/// - **배치 3**(2026-11-11) — `t2-1` 8 + `t2-2` 4 = 12문항. 전수 cue 182 → **170**.
///   ⚠️ **「이미 같다」 단정이 무변경 패치를 8항목 잡았다** — 오답을 「올린다」고 적고
///   **원문을 그대로** 넣은 자리다(배치 2에서 둘, 이 배치에서 여덟). 단정이 없으면
///   그 오답은 손대지 않은 채로 넘어가고, 비율이 이미 통과하면 **아무도 알려 주지
///   않는다.** 지운 8항목은 비율에 영향이 없어 **그대로 두는 것이 옳은 처리**였다.
///   ⚠️ `t2-1`·`t2-2` 는 **둘 다 끝에 개행이 있다** — 자격증이 아니라 파일마다 다르다.
/// - **배치 4**(2026-11-12) — `t3-1` 9 + `t3-2` 9 + `t3-3` 12 = 30문항. 전수 cue
///   170 → **140**. 이 도메인의 정답 보기는 **공식 비교표를 그대로 담아** 115~198자였고
///   오답은 25~62자였다 — **정답을 줄이는 쪽과 오답을 올리는 쪽을 함께** 써야 1.3배 안에
///   들어온다(정답만 줄이면 「반대 방향 단서」 단정에 걸린다).
///   ⚠️⚠️ **왕복 재현 대조군이 내가 PR#445 에서 남긴 들여쓰기 결함을 처음 잡았다** —
///   `scs-t3-2-q12` 의 `"verified"` 줄만 **4칸**이었다(나머지 14개는 6칸). JSON 으로는
///   유효해 **파서·전 가드가 통과했고** 그 두 바이트는 대조군만 볼 수 있었다. 같은 PR 에서
///   수선했다(의미 불변을 `json.loads` 비교로 단정).
/// - **배치 5**(2026-11-12) — `t4-1` 10 + `t4-2` 11 = 21문항. 전수 cue 140 → **119**.
///   ⚠️ **배치 4의 「필요 길이를 먼저 계산한다」를 초안 출력에 넣었다** — 실패한 줄마다
///   `need max>=N`(= 정답 ÷ 1.3)을 함께 찍으니 되돌아오는 횟수가 네 번에서 두 번으로
///   줄었다. ⚠️ **오답을 올려도 모자랄 때는 정답을 줄이는 쪽이 맞다** — 이 Task 의
///   정답은 공식 비교표 요약이라 **해설에 있는 둘째 사실**을 걷으면 바로 들어온다
///   (`q12` 의 `VpceAccessDenied` · `q14` 의 RDS 비호환 — 어느 오답과도 갈림길이 아니다).
void main() {
  const dir = 'assets/content/scs';

  List<Map<String, dynamic>> readQuestions(String taskId) {
    final f = File('$dir/$taskId.questions.json');
    final raw = jsonDecode(f.readAsStringSync());
    final list = raw is Map<String, dynamic> ? raw['questions'] : raw;
    return (list as List).cast<Map<String, dynamic>>();
  }

  /// 길이를 맞춘 문항. ⚠️ 교체·추가가 생기면 이 목록을 함께 고친다.
  const batch1 = <String>[
    'scs-t1-1-q9', 'scs-t1-1-q12', 'scs-t1-1-q15',
    'scs-t1-2-q3', 'scs-t1-2-q4', 'scs-t1-2-q5', 'scs-t1-2-q6',
    'scs-t1-2-q7', 'scs-t1-2-q8', 'scs-t1-2-q13', 'scs-t1-2-q14',
  ];
  const batch2 = <String>[
    'scs-t1-3-q1', 'scs-t1-3-q2', 'scs-t1-3-q3', 'scs-t1-3-q4',
    'scs-t1-3-q6', 'scs-t1-3-q8', 'scs-t1-3-q9', 'scs-t1-3-q10',
    'scs-t1-3-q12',
  ];
  const batch3 = <String>[
    'scs-t2-1-q1', 'scs-t2-1-q3', 'scs-t2-1-q4', 'scs-t2-1-q5',
    'scs-t2-1-q8', 'scs-t2-1-q10', 'scs-t2-1-q12', 'scs-t2-1-q14',
    'scs-t2-2-q6', 'scs-t2-2-q11', 'scs-t2-2-q12', 'scs-t2-2-q13',
  ];
  const batch4 = <String>[
    'scs-t3-1-q5', 'scs-t3-1-q6', 'scs-t3-1-q7', 'scs-t3-1-q8', 'scs-t3-1-q9',
    'scs-t3-1-q10', 'scs-t3-1-q11', 'scs-t3-1-q12', 'scs-t3-1-q15',
    'scs-t3-2-q1', 'scs-t3-2-q4', 'scs-t3-2-q5', 'scs-t3-2-q7', 'scs-t3-2-q8',
    'scs-t3-2-q9', 'scs-t3-2-q10', 'scs-t3-2-q11', 'scs-t3-2-q15',
    'scs-t3-3-q1', 'scs-t3-3-q2', 'scs-t3-3-q3', 'scs-t3-3-q4', 'scs-t3-3-q5',
    'scs-t3-3-q6', 'scs-t3-3-q7', 'scs-t3-3-q9', 'scs-t3-3-q10',
    'scs-t3-3-q11', 'scs-t3-3-q13', 'scs-t3-3-q14',
  ];
  const batch5 = <String>[
    'scs-t4-1-q1', 'scs-t4-1-q4', 'scs-t4-1-q6', 'scs-t4-1-q8',
    'scs-t4-1-q10', 'scs-t4-1-q11', 'scs-t4-1-q12', 'scs-t4-1-q13',
    'scs-t4-1-q14', 'scs-t4-1-q15',
    'scs-t4-2-q1', 'scs-t4-2-q3', 'scs-t4-2-q4', 'scs-t4-2-q5',
    'scs-t4-2-q6', 'scs-t4-2-q7', 'scs-t4-2-q9', 'scs-t4-2-q10',
    'scs-t4-2-q11', 'scs-t4-2-q12', 'scs-t4-2-q14',
  ];
  const handled = <String>[
    ...batch1, ...batch2, ...batch3, ...batch4, ...batch5,
  ];

  /// 지금까지 손댄 Task. 배치가 늘면 여기와 `handled` 를 함께 늘린다.
  const tasks = <String>[
    'scs-t1-1', 'scs-t1-2', 'scs-t1-3', 'scs-t2-1', 'scs-t2-2',
    'scs-t3-1', 'scs-t3-2', 'scs-t3-3', 'scs-t4-1', 'scs-t4-2',
  ];

  /// 보고 P-1 이 든 임계. `prescreen.mjs` 의 `ANSWER_LENGTH_RATIO` 와 같은 값이다.
  const ratioMax = 1.3;

  ({int correct, int longest, int shortest}) lengthsOf(Map<String, dynamic> q) {
    final opts = (q['options'] as List).map((o) => o.toString().length).toList();
    final c = q['correct'] as int;
    final others = <int>[
      for (var i = 0; i < opts.length; i++)
        if (i != c) opts[i],
    ];
    return (
      correct: opts[c],
      longest: others.reduce(max),
      shortest: others.reduce(min),
    );
  }

  group('길이 단서 제거 배치 1~5 (D1 3 · D2 2 · D3 3 · D4 2 Task)', () {
    test('대조군: 문항 자산이 읽히고 전부 드래프트다', () {
      var n = 0;
      for (final t in tasks) {
        final qs = readQuestions(t);
        expect(qs.length, 15, reason: '$t 은 15문항이다');
        for (final q in qs) {
          expect(q['verified'], isFalse, reason: '${q['id']} 는 드래프트다');
          n++;
        }
      }
      expect(n, 150);
    });

    test('처리한 문항에서 정답이 최장 오답의 1.3배를 넘지 않는다', () {
      final over = <String, String>{};
      for (final id in handled) {
        final taskId = id.substring(0, id.lastIndexOf('-'));
        final q = readQuestions(taskId).firstWhere((e) => e['id'] == id);
        final l = lengthsOf(q);
        final ratio = l.correct / l.longest;
        if (ratio > ratioMax) {
          over[id] = '정답 ${l.correct} / 최장 오답 ${l.longest} = '
              '${ratio.toStringAsFixed(2)}배';
        }
      }
      expect(over, isEmpty,
          reason: '길이 단서가 돌아왔다. **오답을 같은 정밀도로 올리는 것**이 주 수단이고 '
              '정답을 깎는 것은 보조다(정답만 깎으면 아래 단정이 막는다): $over');
    });

    test('⚠️ 정답이 최단 오답보다 짧지도 않다 (반대 방향 단서 방지)', () {
      // 보고 P-2 를 글자 그대로 따르면 94/202 가 이 상태가 된다 — 「안 됩니다.」 6자.
      final under = <String, String>{};
      for (final id in handled) {
        final taskId = id.substring(0, id.lastIndexOf('-'));
        final q = readQuestions(taskId).firstWhere((e) => e['id'] == id);
        final l = lengthsOf(q);
        if (l.correct < l.shortest) {
          under[id] = '정답 ${l.correct} < 최단 오답 ${l.shortest}';
        }
      }
      expect(under, isEmpty,
          reason: '정답만 깎아 반대 방향 단서를 만들었다: $under');
    });

    test('⚠️ 손댄 Task 에 남은 cue 문항은 6단계 대상뿐이다', () {
      // 🟡(수정 후 승인)·보류 문항은 6단계가 본문을 바꾸므로 그때 길이를 함께 맞춘다.
      // 지금 남은 것이 그 집합과 정확히 같은지 고정해, 5단계 잔여가 새로 생기면 알린다.
      // ⚠️ `t1-3-q15` 는 🟡 이지만 1.05배라 cue 가 아니다 — 이 집합은 **🟡 목록이
      //    아니라 「아직 1.3배를 넘는 문항」**이다.
      const expected = <String>{
        'scs-t1-1-q1', 'scs-t1-1-q13',   // 🟡
        'scs-t1-2-q9', 'scs-t1-2-q11',   // 🟡
        'scs-t1-3-q13', 'scs-t1-3-q14',  // 🟡
        'scs-t2-1-q13',                  // 🟡
        'scs-t2-2-q5', 'scs-t2-2-q10',   // 🟡
        'scs-t2-2-q2', 'scs-t2-2-q15',   // 보류(교체 예정)
        'scs-t3-1-q2', 'scs-t3-1-q13', 'scs-t3-1-q14',  // 🟡
        'scs-t3-1-q4',                   // 보류(교체 예정)
        'scs-t3-2-q3', 'scs-t3-2-q14',   // 🟡
        'scs-t3-2-q13',                  // 보류(교체 예정)
        'scs-t3-3-q8', 'scs-t3-3-q15',   // 🟡
        'scs-t3-3-q12',                  // 보류(교체 예정)
        'scs-t4-1-q2', 'scs-t4-1-q5', 'scs-t4-1-q7', 'scs-t4-1-q9',    // 🟡
        'scs-t4-2-q2', 'scs-t4-2-q8', 'scs-t4-2-q13', 'scs-t4-2-q15',  // 🟡
      };
      final remaining = <String>{};
      for (final t in tasks) {
        for (final q in readQuestions(t)) {
          final l = lengthsOf(q);
          if (l.correct / l.longest > ratioMax) remaining.add(q['id'] as String);
        }
      }
      expect(remaining, expected,
          reason: '두 Task 의 cue 잔여가 바뀌었다 — 6단계 대상이 아닌 문항이 남았으면 '
              '이 배치에서 함께 처리한다');
    });

    test('대조군: 임계가 실제로 걸러 낸다 (합성 입력)', () {
      // 0이면 위 단정들이 공허하다.
      Map<String, dynamic> synth(List<int> lens, int correct) => {
            'options': [for (final n in lens) 'x' * n],
            'correct': correct,
          };
      final bad = lengthsOf(synth([100, 40, 40, 40], 0));
      expect(bad.correct / bad.longest, greaterThan(ratioMax));
      final ok = lengthsOf(synth([50, 40, 45, 40], 0));
      expect(ok.correct / ok.longest, lessThanOrEqualTo(ratioMax));
      expect(ok.correct, greaterThanOrEqualTo(ok.shortest));
    });
  });
}
