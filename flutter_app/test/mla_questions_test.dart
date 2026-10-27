import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// MLA-C01 문항 드래프트 구조·밀도 가드.
///
/// `QuestionBank.fromJson`은 verified 게이트로 비검증 문항을 제외하므로,
/// 드래프트(verified:false) 단계 검증은 raw JSON을 직접 파싱해 스키마를 확인한다
/// (dea_questions_test.dart와 같은 패턴).
/// 품질 바(question_model_test.dart의 런타임 규칙과 동일):
/// options 정확히 4개, correct 범위 내, wrongExplanations 키=정답 아닌 인덱스, sources 존재.
void main() {
  // 문항 작성을 완료한(드래프트 포함) Task — 도메인 배치별로 누적 추가한다.
  const mlaTaskIds = [
    // D1 기계 학습(ML)을 위한 데이터 준비 (28%) — 도메인 1 완료
    'mla-t1-1', 'mla-t1-2', 'mla-t1-3',
    // D2 ML 모델 개발 (26%) — 도메인 2 완료
    'mla-t2-1', 'mla-t2-2', 'mla-t2-3',
    // D3 ML 워크플로의 배포 및 오케스트레이션 (22%) — 도메인 3 완료
    'mla-t3-1', 'mla-t3-2', 'mla-t3-3',
    // D4 ML 솔루션 모니터링·유지 관리·보안 (24%) — 도메인 4 완료
    'mla-t4-1', 'mla-t4-2', 'mla-t4-3',
  ];
  const minPerTask = 15; // CLF·DEA 기준선과 동일한 Task당 밀도 목표

  /// 사람 검수를 마쳐 flip을 허용한 Task — **사람만 여기에 추가한다.**
  ///
  /// 예전에는 모든 문항에 `verified: false`를 단정해 AI flip을 막았는데, 그러면
  /// 사람이 첫 Task를 flip하는 순간 테스트가 깨져 **flip 자체가 불가능**했다
  /// (SAA에는 같은 단정이 없다 — flip이 살아 있는 자격증이기 때문이다).
  /// 지금은 보호 의도를 유지하면서 길을 연다: 이 목록에 **없는** Task는 전 문항이
  /// `verified: false`여야 하고, 목록에 넣는 행위가 곧 사람의 서명이다
  /// (flip 커밋의 diff에 드러나므로 감사 추적이 된다).
  ///
  /// 검수 절차·루브릭은 `docs/saa-review/review-rubric.md` C1~C6을 그대로 쓴다.
  /// flip 단위는 Task이고, 통합 모의고사 공개에 필요한 양은 도메인당
  /// D1 18 · D2 17 · D3 14 · D4 16(연습 65문항에 공식 비중 배분)이다.
  const flipApprovedTaskIds = <String>{};

  for (final taskId in mlaTaskIds) {
    group(taskId, () {
      final path = 'assets/content/mla/$taskId.questions.json';

      test('문항 파일이 존재한다', () {
        expect(File(path).existsSync(), isTrue,
            reason: '$path 가 없습니다 — 해당 도메인 배치 문항을 작성하세요.');
      });

      test('스키마·밀도 규칙을 만족한다', () {
        final file = File(path);
        if (!file.existsSync()) {
          fail('$path 없음(앞 테스트에서 보고됨)');
        }
        final map = json.decode(file.readAsStringSync()) as Map<String, dynamic>;
        expect(map['examGuideTaskId'], taskId);
        expect(map['certCode'], 'MLA-C01');

        final questions = (map['questions'] as List).cast<Map<String, dynamic>>();
        expect(questions.length, greaterThanOrEqualTo(minPerTask),
            reason: '$taskId 문항 수 ${questions.length} < $minPerTask');

        final ids = <String>{};
        for (final q in questions) {
          final qid = (q['id'] ?? '').toString();
          expect(qid, isNotEmpty);
          expect(ids.add(qid), isTrue, reason: '중복 id: $qid');
          expect((q['stem'] ?? '').toString(), isNotEmpty);
          expect((q['explanation'] ?? '').toString(), isNotEmpty);

          final options = (q['options'] as List);
          expect(options.length, 4, reason: '$qid options 4개 아님');

          final correct = (q['correct'] as num).toInt();
          expect(correct, inInclusiveRange(0, 3), reason: '$qid correct 범위 밖');

          final we = (q['wrongExplanations'] as Map);
          final keys = we.keys.map((k) => int.parse(k.toString())).toSet();
          // 정답이 아닌 0..3 인덱스 전부에 오답해설이 있어야 한다
          final expected = {0, 1, 2, 3}..remove(correct);
          expect(keys, expected, reason: '$qid wrongExplanations 키=비정답 인덱스 전부');

          final sources = (q['sources'] as List);
          expect(sources, isNotEmpty, reason: '$qid sources 비어있음');
          for (final s in sources.cast<Map<String, dynamic>>()) {
            expect((s['url'] ?? '').toString(), startsWith('http'));
            expect((s['title'] ?? '').toString(), isNotEmpty);
          }

          // `verified`는 bool이어야 한다. 값 자체는 아래 flip 허용 목록 가드가 본다.
          expect(q['verified'], isA<bool>(),
              reason: '$qid verified가 bool이 아니다');
        }
      });

      test('flip 허용 목록에 없으면 전 문항이 드래프트다 (AI flip 금지)', () {
        // 사람이 `flipApprovedTaskIds`에 Task를 넣기 전에는 verified:true가
        // 하나도 없어야 한다. 허용한 Task는 이 가드를 통과하고, 실제 수량
        // 정합성은 content_index_test의 동적 불변식(questionCount ↔ verified)이 본다.
        final map = json.decode(File(path).readAsStringSync())
            as Map<String, dynamic>;
        final qs = (map['questions'] as List).cast<Map<String, dynamic>>();
        final flipped =
            qs.where((q) => q['verified'] == true).map((q) => q['id']).toList();
        if (flipApprovedTaskIds.contains(taskId)) {
          expect(flipped, isNotEmpty,
              reason: '$taskId: flip 허용 목록에 있는데 verified 문항이 없다 — '
                  '검수를 끝냈으면 flip하고, 아직이면 목록에서 빼라');
        } else {
          expect(flipped, isEmpty,
              reason: '$taskId: 사람 검수 전인데 verified=true 문항이 있다 — '
                  'flip은 사람 전용이다. 검수를 마쳤다면 flipApprovedTaskIds에 '
                  '$taskId 을 추가하라:\n${flipped.take(5).join(', ')}');
        }
      });

      test('개념 확인(foundational) 문항이 Task당 5개 이상이다', () {
        // 전부 시나리오형(applied)이면 학습 순서상 진입 장벽이 높다.
        // 정의·규칙을 묻는 문항이 섞여 있어야 개념을 먼저 세울 수 있다.
        // ⚠️ 라벨은 레포 전체 규약(foundational·applied)을 따른다 — 'associate'는
        // 시험 등급명과 겹쳐 모호하고 다른 자격증 파일이 쓰지 않는다.
        final map = json.decode(File(path).readAsStringSync())
            as Map<String, dynamic>;
        final byDifficulty = <String, int>{};
        for (final q in (map['questions'] as List).cast<Map<String, dynamic>>()) {
          final d = (q['difficulty'] ?? '').toString();
          byDifficulty[d] = (byDifficulty[d] ?? 0) + 1;
        }
        expect(byDifficulty.keys, everyElement(isIn(['foundational', 'applied'])),
            reason: '$taskId 난이도 라벨은 foundational·applied만 쓴다: $byDifficulty');
        expect(byDifficulty['foundational'] ?? 0, greaterThanOrEqualTo(5),
            reason: '$taskId 난이도 분포: $byDifficulty');
      });

      test('문항 파일에 검증 기준일(lastVerified)이 있다', () {
        // md 머리말은 lastVerified를 갖는데 문항 파일에는 없어 상태가 엇갈렸다.
        // ⚠️ 의미: 이 날짜는 **출처를 조회·대조한 기준일**이지 사람 검수가 끝난 날이
        // 아니다. 사람 검수 완료 여부는 문항별 `verified` 플래그가 따로 나타낸다
        // (드래프트 단계에서는 lastVerified가 있으면서 verified:false인 것이 정상).
        // md의 lastVerified(조사 노트 조회일)와 값이 다를 수 있다 — 문서는 노트를
        // 작성한 날, 문항은 그 문항을 쓰며 출처를 다시 확인한 날이다.
        final map = json.decode(File(path).readAsStringSync())
            as Map<String, dynamic>;
        expect(RegExp(r'^\d{4}-\d{2}-\d{2}$')
            .hasMatch((map['lastVerified'] ?? '').toString()), isTrue,
            reason: '$taskId: 문항 사실 확인 기준일을 YYYY-MM-DD로 적는다');
      });

      test('해설에 마크다운 표기가 없다', () {
        // 해설은 `Text()` 위젯으로 **평문** 렌더된다(quiz_widgets.dart:245·251).
        // 마크다운을 쓰면 `**`와 백틱이 화면에 글자 그대로 보인다.
        final map = json.decode(File(path).readAsStringSync())
            as Map<String, dynamic>;
        final offenders = <String>[];
        for (final q in (map['questions'] as List).cast<Map<String, dynamic>>()) {
          final texts = <String>[
            (q['explanation'] ?? '').toString(),
            ...(q['wrongExplanations'] as Map).values.map((v) => v.toString()),
          ];
          for (final t in texts) {
            if (t.contains('**') || t.contains('`')) {
              offenders.add('${q['id']}: ${t.substring(0, t.length.clamp(0, 40))}…');
            }
          }
        }
        expect(offenders, isEmpty,
            reason: '해설은 평문으로 렌더된다 — 마크다운 제거:\n${offenders.join('\n')}');
      });

      test('정답 보기가 오답보다 지나치게 길지 않다', () {
        // 가장 긴 보기가 정답인 패턴은 내용을 몰라도 찍게 만든다.
        final map = json.decode(File(path).readAsStringSync())
            as Map<String, dynamic>;
        final offenders = <String>[];
        for (final q in (map['questions'] as List).cast<Map<String, dynamic>>()) {
          final options = (q['options'] as List).cast<String>();
          final correct = (q['correct'] as num).toInt();
          final longestWrong = [
            for (var i = 0; i < options.length; i++)
              if (i != correct) options[i].length,
          ].reduce((a, b) => a > b ? a : b);
          if (options[correct].length > longestWrong * 1.4) {
            offenders.add(
                '${q['id']}: 정답 ${options[correct].length}자 vs 최장 오답 $longestWrong자');
          }
        }
        expect(offenders, isEmpty,
            reason: '정답이 유독 길면 단서가 된다(오답을 비슷한 구체성으로):\n${offenders.join('\n')}');
      });

      test('스킬 태그가 공식 가이드에 실재하고 Task의 전 항목을 덮는다', () {
        // 문항의 `skill`은 공식 가이드 문장 + 꼬리 태그(예: "…(SK2)") 형식이다.
        // 태그가 가이드에 없는 번호를 가리키면 커버리지 집계가 조용히 어긋나고,
        // 어떤 K·SK에도 문항이 없으면 그 항목은 학습자가 연습할 수 없다.
        // 2026-10-26 도메인 3 외부 리뷰가 손으로 찾아낸 공백(3.3 K3 버전 관리)을
        // 기계가 잡게 하려고 신설했다.
        //
        // ⚠️ 본문 일치는 요구하지 않는다. 도메인 1은 "(K1, SK1)"처럼 한 괄호에 복수
        // 태그를 쓰고 문장도 가이드 원문과 글자 단위로 같지 않다(도메인 2~3은 단일
        // 태그 + 원문). 본문 통일까지 가드하면 범위 밖 90여 문항이 깨지므로 여기서는
        // **태그의 실재·범위와 커버리지**만 본다 — 표기 통일은 별건이다.
        final m = RegExp(r'^mla-t(\d)-(\d)$').firstMatch(taskId)!;
        final taskNo = '${m.group(1)}.${m.group(2)}';

        final guide = json.decode(
                File('assets/exam_guides/MLA-C01.json').readAsStringSync())
            as Map<String, dynamic>;
        Map<String, dynamic>? task;
        for (final d in (guide['domains'] as List)) {
          for (final t in ((d as Map)['tasks'] as List)) {
            if ((t as Map)['no'] == taskNo) task = t.cast<String, dynamic>();
          }
        }
        expect(task, isNotNull, reason: '가이드에 Task $taskNo 가 없다');
        final kCount = (task!['knowledge'] as List).length;
        final skCount = (task['skills'] as List).length;

        final map = json.decode(File(path).readAsStringSync())
            as Map<String, dynamic>;
        final tagRe = RegExp(r'\(([^()]*(?:SK|K)\d+[^()]*)\)\s*$');
        final oneRe = RegExp(r'SK\d+|K\d+');
        final seen = <String>{};
        final invalid = <String>[];
        for (final q in (map['questions'] as List).cast<Map<String, dynamic>>()) {
          final skill = (q['skill'] ?? '').toString();
          final inner = tagRe.firstMatch(skill)?.group(1);
          final tags = inner == null
              ? const <String>[]
              : oneRe.allMatches(inner).map((x) => x.group(0)!).toList();
          if (tags.isEmpty) {
            invalid.add('${q['id']}: 꼬리 태그 없음 — "$skill"');
            continue;
          }
          for (final tag in tags) {
            final isSk = tag.startsWith('SK');
            final idx = int.parse(tag.substring(isSk ? 2 : 1));
            final limit = isSk ? skCount : kCount;
            if (idx < 1 || idx > limit) {
              invalid.add('${q['id']}: $tag — 가이드 Task $taskNo 는 '
                  'K$kCount·SK$skCount 뿐');
            } else {
              seen.add(tag);
            }
          }
        }
        expect(invalid, isEmpty,
            reason: '$taskId 스킬 태그가 가이드 범위를 벗어났다:\n${invalid.join('\n')}');

        final all = [
          for (var i = 1; i <= kCount; i++) 'K$i',
          for (var i = 1; i <= skCount; i++) 'SK$i',
        ];
        final gaps = all.where((t) => !seen.contains(t)).toList();
        expect(gaps, isEmpty,
            reason: '$taskId: 문항이 하나도 없는 가이드 항목 $gaps '
                '— 해당 항목을 묻는 문항을 추가하세요');
      });

      test('문항의 section이 학습문서 앵커와 짝이 맞는다', () {
        // 개념 딥링크(`?at=`)는 문항 `section`을 md의 `{#id}` 앵커로 찾아간다.
        // 짝이 깨지면 링크가 조용히 죽으므로 문서와 함께 가드한다.
        final qFile = File(path);
        final mdFile = File('assets/content/mla/$taskId.md');
        if (!qFile.existsSync() || !mdFile.existsSync()) {
          fail('$taskId 문서·문항 파일 없음(앞 테스트에서 보고됨)');
        }
        final anchors = RegExp(r'\{#([a-z0-9-]+)\}')
            .allMatches(mdFile.readAsStringSync())
            .map((m) => m.group(1)!)
            .toSet();
        final map = json.decode(qFile.readAsStringSync()) as Map<String, dynamic>;
        for (final q in (map['questions'] as List).cast<Map<String, dynamic>>()) {
          final section = (q['section'] ?? '').toString();
          expect(section, isNotEmpty, reason: '${q['id']} section 비어있음');
          expect(anchors, contains(section),
              reason: '${q['id']} section "$section" 앵커가 $taskId.md에 없다');
        }
      });
    });
  }

  // ── M2: 작성 과정 메모 금지 (루브릭 §2 주의 문단) ──────────────────────────
  // 학습자용 문장에 **작성자의 검증 상태**가 섞이면 해설이 사실 서술을 멈추고
  // "나는 이걸 확인하지 못했다"를 설명하게 된다. 2026-10-27 외부 검수가 7문항에서
  // 이것을 집어냈다(예: "공식 문서에서 확인되지 않으므로 요건으로 삼을 수
  // 없습니다" — 실제로는 서버리스 제외 기능 목록에 데이터 캡처와 Model Monitor가
  // 둘 다 적혀 있었다). 확인된 것은 사실로 쓰고, 확인되지 않은 것은 해설에서 뺀다.
  //
  // ⚠️ 겨냥하는 것은 작성자의 검증 상태를 적은 문장뿐이다. "~라는 서술은 없습니다"
  // 처럼 보기의 주장을 부정하고 곧바로 사실을 제시하는 문장은 정당하므로 금지하지
  // 않는다(전수 스캔에서 7개소가 그 쪽이었다). 학습문서(.md)도 대상이 아니다 —
  // 거기서는 "공식 문서에서 확인되지 않았으므로 정답으로 고르지 않습니다"가 의도된
  // 시험 전략 서술이고 31개소가 그렇게 쓰여 있다.
  test('문항 본문에 작성 과정 메모가 없다 (M2)', () {
    const forbidden = [
      '확인되지 않',
      '확인할 수 없',
      '원문에 나오지 않',
      '문서가 반올림',
      '단정하지 않',
      '공식 문서는 없',
      '문구는 없',
      '가장 가까운 공식',
    ];
    final offenders = <String>[];
    for (final taskId in mlaTaskIds) {
      final file = File('assets/content/mla/$taskId.questions.json');
      if (!file.existsSync()) continue;
      final map = json.decode(file.readAsStringSync()) as Map<String, dynamic>;
      for (final q in (map['questions'] as List).cast<Map<String, dynamic>>()) {
        final options = (q['options'] as List?) ?? const [];
        final wrong = (q['wrongExplanations'] as Map?) ?? const {};
        final fields = <String, String>{
          'stem': '${q['stem']}',
          'explanation': '${q['explanation']}',
          for (var i = 0; i < options.length; i++) 'options[$i]': '${options[i]}',
          for (final e in wrong.entries) 'wrongExplanations[${e.key}]': '${e.value}',
        };
        for (final field in fields.entries) {
          for (final phrase in forbidden) {
            if (field.value.contains(phrase)) {
              offenders.add('${q['id']} ${field.key}: "$phrase"');
            }
          }
        }
      }
    }
    expect(offenders, isEmpty,
        reason: '작성 과정 메모를 사실 서술로 바꾸거나 지우세요(루브릭 M2):\n'
            '${offenders.join('\n')}');
  });
}
