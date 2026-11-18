import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'flip_allowlist.dart';

/// 정답 길이가 최장 오답의 이 배수를 넘으면 「제일 긴 것 고르기」로 맞을 수 있다.
/// `tool/prescreen.mjs`의 `ANSWER_LENGTH_RATIO`와 같은 값이다.
const answerLengthRatio = 1.3;

/// Task마다 보장하는 진입용(회상·분류형) 문항 수의 하한.
/// 저작 카덴스는 q1·q6·q11이고 2026-11-15 배치 1의 실측값이 Task당 정확히 3이다.
const minFoundationalPerTask = 3;

/// 지문과 정답 보기에서 금지하는 자기 프레임 문구.
/// 해설의 출처 귀속(「공식 문서가 …라고 적습니다」)은 **정당한 층**이라 세지 않고,
/// `tool/prescreen.mjs`의 `META_PHRASES`도 같은 둘만 본다.
const selfFramePhrases = ['공식', '시험 가이드', '단정하지'];

/// AIP-C01 문항 가드 — **문항 저작 전에 미리 세운 선결 가드**(2026-11-13, Phase 2 P-04).
///
/// ## 왜 문항이 하나도 없는데 지금 만드는가
///
/// AIF-C01(2026-11-05)·SCS-C03(2026-11-09)이 같은 순서를 밟았다. 셋 다 「나중에
/// 하면 늦는」 것들이다.
///
///  1. `review.mjs`의 `CERTS.aip.flipAllowlist`가 **이 파일의
///     `flipApprovedTaskIds`를 가리킨다.** 파일이 없으면 `review.test.mjs`의
///     「flipAllowlist의 파일·심볼이 실재한다」가 레드다.
///  2. 허용 목록이 없으면 **사람의 첫 flip이 반드시 레드로 끝난다** — 드래프트
///     전수 단정이 `CERTS[<cert>].tests`에 들어 있어, `review.mjs flip`이 문항
///     파일을 다 쓴 뒤 그 단정에서 멈춘다(`--force`는 쓰기 **전** 구조 검사만
///     건너뛴다). MLA가 #246에서, SOA·DEA가 #286에서 같은 함정을 밟았다.
///  3. 문항이 들어온 **뒤에** 가드를 만들면 이미 쓴 문항에 가드를 맞추게 된다.
///
/// ## ⚠️⚠️ AIF 판을 그대로 베끼면 가드가 **빈 집합**을 상대로 통과한다
///
/// AIF 가이드 JSON은 목표를 **`knowledge`**에 담고 `skills`를 비워 두는데
/// **AIP-C01은 그 반대다**(SCS와 같다) — `knowledge`가 **20개 Task 전부 빈
/// 배열**이고 공식 기술 **98개**가 전부 `skills`에 있다. `task['knowledge']`를
/// 그대로 옮기면 번호 집합이 빈 집합이 되고, 그러면 「skill이 실재하는 기술
/// 번호다」가 전 문항을 **거짓으로 거부**한다. ⚠️ **문항이 0개인 지금은 레드도
/// 나지 않아** 첫 배치에서야 터진다(SCS G-77). 아래 대조군이 양방향으로 못박는다.
///
/// ## ⚠️⚠️ 이 자격증만 `skills` 본문에 `기술 N.M.K: ` 접두사가 있다
///
/// 레포 12종 중 이 파일만 그렇다(SCS·SOA는 접두사 없음 · AIF는 `knowledge`).
/// 번호는 **배열 위치**에서 유도하지만, 본문의 접두사와 어긋나면 어느 쪽이
/// 틀렸는지 알 수 없으므로 **98건 전수로 둘이 같은지** 단정한다(99 G-20).
/// 전사 본문 자체의 공식 일치는 `aip_guide_sync_test.dart`가 본다.
///
/// ## 문항 0개에서 공허하지 않으려면
///
/// `dea_questions_test.dart`처럼 전 Task의 파일 존재를 단정하면 **20건 레드**다.
/// 그래서 「저작된 Task 선언 ↔ 디스크 일치」로 간다 — 선언이 비어 있어도 단정은
/// 비어 있지 않다(문항을 넣고 선언을 빠뜨리면 레드, 선언만 하고 파일을 안 넣어도 레드).
void main() {
  const certCode = 'AIP-C01';
  const dir = 'assets/content/aip';

  /// 문항이 저작된 Task — **배치마다 늘린다.**
  ///
  /// ⚠️ 첫 배치에서 `tool/review.test.mjs`의 `preAuthoring` 집합에서 `aip`를
  /// **지워야 한다** — 안 지우면 node 단계가 1초 만에 레드다(설계대로다).
  /// 2026-11-15 도메인 1 배치 1에서 지웠다.
  /// ⚠️ 학습문서 포맷 가드(`aip_doc_format_test.dart`)의 `aipTaskIds`는 **이미 20개
  /// 전부**다(학습문서가 먼저 들어왔다) — 문항 배치에서는 이 목록만 늘린다.
  /// MLA에서 두 파일 중 한쪽만 늘려 빠뜨린 적이 있어 적어 둔다.
  const authoredTaskIds = <String>{
    'aip-t1-1', 'aip-t1-2', 'aip-t1-3', 'aip-t1-4', 'aip-t1-5', 'aip-t1-6',
    'aip-t2-1', 'aip-t2-2', 'aip-t2-3', 'aip-t2-4', 'aip-t2-5',
    'aip-t3-1', 'aip-t3-2', 'aip-t3-3', 'aip-t3-4',
    'aip-t4-1', 'aip-t4-2', 'aip-t4-3',
    'aip-t5-1', 'aip-t5-2',
  };

  /// 사람이 검수를 마쳐 flip한 Task — **AI는 여기에 손대지 않는다.**
  /// `node tool/review.mjs flip aip <taskId>`가 대신 넣어 주고, 그 diff가
  /// 사람의 서명이다.
  const flipApprovedTaskIds = <String>{'aip-t1-1', 'aip-t1-2', 'aip-t1-3', 'aip-t1-4', 'aip-t1-5', 'aip-t1-6', 'aip-t2-1', 'aip-t2-2', 'aip-t2-3', 'aip-t2-4', 'aip-t2-5', 'aip-t3-1', 'aip-t3-2', 'aip-t3-3', 'aip-t3-4'};

  /// 공식 Task 20개. 도메인별 Task 수는 **6·5·4·3·2**다(2026-11-13 실측).
  /// ⚠️ 비중과 Task 수가 반대로 간다 — 최대 비중 D1(31%)이 Task 6개인데
  /// **D5(11%)는 Task 2개뿐이고 기술이 14개**다(`작업 5.1` 하나에 기술 9개).
  const allTaskIds = [
    'aip-t1-1', 'aip-t1-2', 'aip-t1-3', 'aip-t1-4', 'aip-t1-5', 'aip-t1-6',
    'aip-t2-1', 'aip-t2-2', 'aip-t2-3', 'aip-t2-4', 'aip-t2-5',
    'aip-t3-1', 'aip-t3-2', 'aip-t3-3', 'aip-t3-4',
    'aip-t4-1', 'aip-t4-2', 'aip-t4-3',
    'aip-t5-1', 'aip-t5-2',
  ];

  Map<String, dynamic> guide() {
    final raw = File('assets/exam_guides/$certCode.json').readAsStringSync();
    return json.decode(raw) as Map<String, dynamic>;
  }

  /// 공식 기술 번호 전체(`1.1.1` … `5.2.5`)를 시험 가이드 JSON에서 유도한다.
  ///
  /// ⚠️ **`skills`를 읽는다**(위 클래스 주석). 그리고 `task['no']`는 이미
  /// `'1.1'`처럼 **도메인 번호를 포함**하므로 앞에 `domain['no']`를 또 붙이면
  /// `1.1.1.1`이 된다(AIF가 그 실수를 대조군으로 잡았다).
  Set<String> officialSkillNumbers() {
    final numbers = <String>{};
    for (final d in guide()['domains'] as List<dynamic>) {
      for (final t in (d as Map<String, dynamic>)['tasks'] as List<dynamic>) {
        final task = t as Map<String, dynamic>;
        final skills = task['skills'] as List<dynamic>;
        for (var i = 0; i < skills.length; i++) {
          numbers.add('${task['no']}.${i + 1}');
        }
      }
    }
    return numbers;
  }

  String questionPath(String taskId) => '$dir/$taskId.questions.json';

  List<Map<String, dynamic>> readQuestions(String taskId) {
    final raw = File(questionPath(taskId)).readAsStringSync();
    final decoded = json.decode(raw);
    final list = decoded is List ? decoded : (decoded as Map)['questions'];
    return [for (final q in list as List<dynamic>) q as Map<String, dynamic>];
  }

  // ── 대조군: 가드의 입력이 실제로 만들어지는가 ────────────────────────
  //
  // 이 단정이 없으면 아래 「skill이 실재하는 기술 번호다」가 **빈 집합**을
  // 상대로 통과할 수 있다. Task별 기술 수는
  // 3·4·4·5·6·6 / 7·3·5·4·6 / 5·3·4·3 / 4·6·6 / 9·5 다(2026-11-13 전수 실측).
  test('대조군: 시험 가이드에서 공식 기술 번호 98개가 유도된다', () {
    final numbers = officialSkillNumbers();
    expect(numbers.length, 98,
        reason: '기술 번호 유도가 깨졌다 — 가이드 JSON 구조가 바뀌었는지 본다');
    expect(numbers, contains('1.1.1'));
    expect(numbers, contains('2.1.7'), reason: 'D2에서 가장 두꺼운 Task는 2.1(기술 7개)다');
    expect(numbers, contains('5.1.9'), reason: '가장 두꺼운 Task는 5.1(기술 9개)다');
    expect(numbers, contains('5.2.5'));
    expect(numbers, isNot(contains('1.1.4')),
        reason: '가장 얇은 Task 중 하나가 1.1(기술 3개)다');
    expect(numbers, isNot(contains('5.3.1')),
        reason: '도메인 5는 Task가 2개뿐이다');
    expect(numbers, isNot(contains('6.1.1')),
        reason: 'AIP는 도메인이 5개까지다');
  });

  // ⚠️⚠️ 구조 비대칭을 **양방향으로** 못박고, 이 자격증만 있는 접두사도 함께 본다.
  test('대조군: knowledge가 비어 있고 기술 98개가 skills에 있으며 접두사 번호가 위치와 같다', () {
    var knowledgeTotal = 0;
    var skillsTotal = 0;
    var taskCount = 0;
    var prefixChecked = 0;
    for (final d in guide()['domains'] as List<dynamic>) {
      for (final t in (d as Map<String, dynamic>)['tasks'] as List<dynamic>) {
        final task = t as Map<String, dynamic>;
        knowledgeTotal += (task['knowledge'] as List<dynamic>).length;
        final skills = task['skills'] as List<dynamic>;
        skillsTotal += skills.length;
        taskCount++;
        for (var i = 0; i < skills.length; i++) {
          final m = RegExp(r'^기술 (\d+\.\d+\.\d+): ').firstMatch('${skills[i]}');
          expect(m, isNotNull,
              reason: '${task['no']}.${i + 1}: `기술 N.M.K: ` 접두사가 없다 — '
                  '이 자격증만의 관례가 바뀌었는지 본다(99 G-20)');
          expect(m!.group(1), '${task['no']}.${i + 1}',
              reason: '본문 번호와 배열 위치가 어긋난다');
          prefixChecked++;
        }
      }
    }
    expect(taskCount, 20, reason: 'AIP 공식 Task는 20개다(6·5·4·3·2)');
    expect(knowledgeTotal, 0,
        reason: 'knowledge는 전부 빈 배열이다 — 0이 아니게 되면 '
            'officialSkillNumbers의 소스를 다시 판단한다');
    expect(skillsTotal, 98, reason: '기술은 skills에 98개 있다 — AIF와 반대 구조다');
    expect(prefixChecked, 98);
  });

  // ── 선언 ↔ 디스크 일치 ───────────────────────────────────────────────
  test('authoredTaskIds가 실제 문항 파일 집합과 일치한다', () {
    final onDisk = {
      for (final taskId in allTaskIds)
        if (File(questionPath(taskId)).existsSync()) taskId,
    };
    expect(onDisk, authoredTaskIds,
        reason: '문항 파일을 추가·삭제했으면 authoredTaskIds도 맞춘다 — '
            '첫 배치에서는 `tool/review.test.mjs`의 preAuthoring에서 '
            '`aip`를 지우는 것도 함께 한다');
  });

  test('authoredTaskIds는 공식 Task 20개의 부분집합이다', () {
    expect(allTaskIds.length, 20, reason: 'AIP 공식 Task는 20개다');
    expect(allTaskIds.toSet().length, 20, reason: 'taskId가 중복됐다');
    expect(authoredTaskIds.difference(allTaskIds.toSet()), isEmpty,
        reason: '공식 Task에 없는 taskId가 선언됐다');
  });

  test('flipApprovedTaskIds는 저작된 Task의 부분집합이다', () {
    expect(flipApprovedTaskIds.difference(authoredTaskIds), isEmpty,
        reason: '문항이 없는 Task가 flip 허용 목록에 있다');
  });

  // ── 저작된 Task별 가드 (지금은 0회) ──────────────────────────────────
  for (final taskId in authoredTaskIds) {
    group(taskId, () {
      test('구조: options 4개 · correct 0~3 · wrongExplanations 키가 맞다', () {
        final questions = readQuestions(taskId);
        expect(questions, isNotEmpty, reason: '$taskId: 문항이 비어 있다');
        for (final q in questions) {
          final id = q['id'];
          final options = q['options'] as List<dynamic>;
          expect(options.length, 4, reason: '$id: options ${options.length}개');
          final correct = q['correct'];
          expect(correct, isA<int>(), reason: '$id: correct가 정수가 아니다');
          expect(correct as int, inInclusiveRange(0, 3),
              reason: '$id: correct 범위 밖');
          final expected = {
            for (var i = 0; i < 4; i++)
              if (i != correct) '$i',
          };
          expect((q['wrongExplanations'] as Map).keys.toSet(), expected,
              reason: '$id: wrongExplanations 키가 오답 인덱스와 다르다');
        }
      });

      test('skill 태그가 실재하는 공식 기술 번호다', () {
        final numbers = officialSkillNumbers();
        final prefix =
            taskId.replaceAll(RegExp(r'^aip-t'), '').replaceAll('-', '.');
        for (final q in readQuestions(taskId)) {
          final skill = '${q['skill']}';
          expect(numbers, contains(skill),
              reason: '${q['id']}: skill "$skill"은 공식 기술 번호가 아니다');
          expect(skill, startsWith('$prefix.'),
              reason: '${q['id']}: skill "$skill"이 이 Task($taskId)의 기술이 아니다');
        }
      });

      test('이 Task의 모든 기술이 최소 한 문항에 덮인다', () {
        final prefix =
            '${taskId.replaceAll(RegExp(r'^aip-t'), '').replaceAll('-', '.')}.';
        final taskSkills =
            officialSkillNumbers().where((n) => n.startsWith(prefix)).toSet();
        expect(taskSkills, isNotEmpty,
            reason: '$taskId: 기술 번호가 유도되지 않았다 — 접두사 계산을 본다');
        final covered = {for (final q in readQuestions(taskId)) '${q['skill']}'};
        expect(taskSkills.difference(covered), isEmpty,
            reason: '$taskId: 덮이지 않은 기술이 있다');
      });

      test('flip 허용 목록 계약을 지킨다 (flip은 사람 전용)', () {
        final questions = readQuestions(taskId);
        expect(
          flipAllowlistGuardPasses(
            approved: flipApprovedTaskIds,
            taskId: taskId,
            questions: questions,
          ),
          isTrue,
          reason: flipApprovedTaskIds.contains(taskId)
              ? '$taskId: flip 허용 목록에 있는데 verified 문항이 하나도 없다 — '
                  '목록만 넣고 flip을 빠뜨렸는지 본다'
              : '$taskId: verified 문항이 있는데 허용 목록에 없다. '
                  'flip은 사람 전용이다. 검수를 마쳤다면 '
                  '`node tool/review.mjs flip aip $taskId`로 넣는다',
        );
      });
    });
  }

  // ── 저작 품질 불변식 (집계형 — 편수와 무관하게 수가 고정이다) ────────────
  //
  // ⚠️⚠️ **이 묶음을 첫 문항 배치에서 세운다.** SCS-C03은 같은 결함을 240문항을
  // 다 쓴 뒤에 발견해 **일곱 배치**를 들여 되돌렸다(길이 단서 227 → 0). AIP는
  // 생성 단계에서 같은 규율을 걸어 **첫 배치가 prescreen 품질 신호 0/45문항(0%)**로
  // 들어왔다(SCS 90% · AIF 92% · SOA 60% · DEA 46% · SAA 42% · CLF 30% · MLA 23%).
  //
  // ⚠️ 배치당 테스트 증가는 **Task 수 × 4**다(위 per-Task 묶음). 이 집계형 묶음은
  // `authoredTaskIds`를 순회하는 한 테스트씩이라 편수가 늘어도 수가 변하지 않는다.

  String mdText(String taskId) => File('$dir/$taskId.md').readAsStringSync();

  Set<String> mdAnchors(String taskId) => RegExp(r'\{#([a-z0-9-]+)\}')
      .allMatches(mdText(taskId))
      .map((m) => m.group(1)!)
      .toSet();

  Set<String> mdSourceUrls(String taskId) {
    final parts = mdText(taskId).split('---');
    expect(parts.length, greaterThan(2),
        reason: '$taskId: 프런트매터를 못 읽었다 — 구분선 규약이 바뀌었는지 본다');
    return RegExp(r'url: (\S+)')
        .allMatches(parts[1])
        .map((m) => m.group(1)!)
        .toSet();
  }

  String allText(Map<String, dynamic> q) => [
        '${q['stem']}',
        '${q['explanation']}',
        for (final o in q['options'] as List<dynamic>) '$o',
        for (final v in (q['wrongExplanations'] as Map).values) '$v',
        for (final s in q['sources'] as List<dynamic>) '${(s as Map)['title']}',
      ].join('\n');

  /// 「제일 긴 것 고르기」로 맞출 수 있는지와, **그 반대 방향**까지 함께 본다.
  /// ⚠️ 상한만 두면 「정답만 짧게 깎는」 결함을 통과시킨다(SCS 배치 2·4의 실측).
  bool lengthCuePasses(int correctLen, List<int> otherLens) =>
      correctLen <= otherLens.reduce(max) * answerLengthRatio &&
      correctLen >= otherLens.reduce(min);

  test('대조군: 길이 단서 판정이 양쪽 방향을 실제로 잡는다', () {
    expect(lengthCuePasses(50, [40, 45, 38]), isTrue, reason: '1.11배는 통과');
    expect(lengthCuePasses(58, [40, 45, 38]), isTrue, reason: '1.29배는 통과');
    expect(lengthCuePasses(63, [40, 45, 38]), isFalse, reason: '1.40배는 걸린다');
    expect(lengthCuePasses(30, [40, 45, 38]), isFalse,
        reason: '최단 오답보다 짧으면 걸린다 — 반대 방향 단서');
  });

  test('길이 단서: 정답 ÷ 최장 오답 ≤ $answerLengthRatio · 정답이 최단 오답보다 짧지 않다', () {
    var checked = 0;
    for (final taskId in authoredTaskIds) {
      for (final q in readQuestions(taskId)) {
        final c = q['correct'] as int;
        final lens = [for (final o in q['options'] as List<dynamic>) '$o'.length];
        final others = [
          for (var i = 0; i < lens.length; i++)
            if (i != c) lens[i],
        ];
        expect(lengthCuePasses(lens[c], others), isTrue,
            reason: '${q['id']}: 정답 ${lens[c]}자 · 오답 $others — '
                '상한 ${(others.reduce(max) * answerLengthRatio).floor()}자 · '
                '하한 ${others.reduce(min)}자. 오답을 '
                '${(lens[c] / answerLengthRatio).ceil()}자 이상으로 올리는 쪽이 '
                '교육 가치도 올린다');
        checked++;
      }
    }
    expect(checked, authoredTaskIds.length * 15,
        reason: '대조군: 문항을 전수로 읽지 못했다');
  });

  test('난이도: Task마다 foundational 최소 $minFoundationalPerTask개', () {
    final counts = <String, int>{};
    for (final taskId in authoredTaskIds) {
      counts[taskId] = readQuestions(taskId)
          .where((q) => '${q['difficulty']}' == 'foundational')
          .length;
      expect(readQuestions(taskId).map((q) => '${q['difficulty']}'),
          everyElement(anyOf('foundational', 'applied')),
          reason: '$taskId: 레포가 쓰는 두 난이도 값 밖의 라벨이 있다');
    }
    for (final e in counts.entries) {
      expect(e.value, greaterThanOrEqualTo(minFoundationalPerTask),
          reason: '${e.key}: foundational ${e.value}개. 진입용 문항이 없는 Task가 '
              '생기면 그 작업을 처음 공부하는 사람이 붙을 자리가 없다 — '
              '회상·분류형 문항을 더한다(배분 전체: $counts)');
    }
  });

  test('대조군: 난이도 라벨을 실제로 읽고 두 값이 모두 쓰인다', () {
    var foundational = 0;
    var total = 0;
    for (final taskId in authoredTaskIds) {
      final qs = readQuestions(taskId);
      total += qs.length;
      foundational +=
          qs.where((q) => '${q['difficulty']}' == 'foundational').length;
    }
    expect(total, authoredTaskIds.length * 15);
    expect(foundational,
        greaterThanOrEqualTo(authoredTaskIds.length * minFoundationalPerTask));
    expect(foundational, lessThan(total),
        reason: 'applied가 하나도 없으면 난이도 분리가 무의미하다');
  });

  test('정답 인덱스가 파일마다 4/4/4/3이다', () {
    for (final taskId in authoredTaskIds) {
      final counts = <int, int>{0: 0, 1: 0, 2: 0, 3: 0};
      for (final q in readQuestions(taskId)) {
        final c = q['correct'] as int;
        counts[c] = counts[c]! + 1;
      }
      expect(counts, {0: 4, 1: 4, 2: 4, 3: 3},
          reason: '$taskId: $counts. 앱이 전 경로에서 보기를 셔플하므로 인덱스는 '
              '학습자에게 안 보이지만 JSON을 읽는 검수자에게는 보인다 — 쏠린 분포는 '
              '저작자가 「첫 보기를 정답으로 쓰는 습관」에 빠졌다는 신호다. '
              '문항을 쓰기 전에 표로 정한다(손으로는 지켜지지 않는다)');
    }
  });

  test('section이 학습문서의 실제 앵커다', () {
    for (final taskId in authoredTaskIds) {
      final anchors = mdAnchors(taskId);
      // 하한은 추측하지 않고 실측해서 잡는다 — aip 20편의 앵커 수 최솟값이 **4**다
      // (`aip-t2-2`·`aip-t3-2`·`aip-t3-4`가 4, 최대는 `aip-t5-1`의 10).
      // 2026-11-15 도메인 2 배치 1에서 5로 두었던 하한이 `aip-t2-2`를 거짓으로
      // 거부했다 — 같은 하한이 생성기 쪽에도 복제돼 있었으므로 **두 곳을 함께** 본다.
      expect(anchors.length, greaterThanOrEqualTo(4),
          reason: '$taskId: 앵커 ${anchors.length}개 — 추출이 깨졌다');
      for (final q in readQuestions(taskId)) {
        expect(anchors, contains('${q['section']}'),
            reason: '${q['id']}: section "${q['section']}"이 학습문서 앵커에 없다. '
                '앵커는 추측하지 않고 `grep` 으로 센다 (앵커: ${anchors.toList()..sort()})');
      }
    }
  });

  test('문항 출처가 학습문서 출처의 부분집합이다', () {
    var checked = 0;
    for (final taskId in authoredTaskIds) {
      final srcs = mdSourceUrls(taskId);
      expect(srcs.length, greaterThanOrEqualTo(8),
          reason: '$taskId: md 출처 ${srcs.length}개 — 추출이 깨졌다');
      for (final q in readQuestions(taskId)) {
        final list = q['sources'] as List<dynamic>;
        expect(list, isNotEmpty, reason: '${q['id']}: 출처가 없다');
        for (final s in list) {
          final url = '${(s as Map)['url']}';
          expect(srcs, contains(url),
              reason: '${q['id']}: 출처 $url 가 학습문서 출처에 없다. 문항이 새 URL을 '
                  '들이면 그 URL은 학습문서 저작 때 실측된 대상이 아니었던 것이고, '
                  '「URL은 200인데 그 페이지에 인용 사실이 없다」의 입구가 된다');
          checked++;
        }
      }
    }
    expect(checked, greaterThanOrEqualTo(authoredTaskIds.length * 15),
        reason: '대조군: 출처를 전수로 읽지 못했다');
  });

  test('문항은 평문 렌더다 — 굵게·백틱·마크다운 링크 0건', () {
    for (final taskId in authoredTaskIds) {
      for (final q in readQuestions(taskId)) {
        final t = allText(q);
        expect(t.contains('**'), isFalse, reason: '${q['id']}: 굵게 표기');
        expect(t.contains('`'), isFalse, reason: '${q['id']}: 백틱');
        expect(RegExp(r'\[[^\]]+\]\([^)]+\)').hasMatch(t), isFalse,
            reason: '${q['id']}: 마크다운 링크');
      }
    }
  });

  test('대조군: 같은 탐지기가 학습문서에서는 굵게와 백틱을 찾는다', () {
    for (final taskId in authoredTaskIds) {
      final md = mdText(taskId);
      expect(md.contains('**'), isTrue,
          reason: '$taskId: 탐지기가 md의 굵게를 못 찾는다 — 탐지기가 죽었다');
      expect(md.contains('`'), isTrue,
          reason: '$taskId: 탐지기가 md의 백틱을 못 찾는다 — 탐지기가 죽었다');
    }
  });

  test('지문·정답 보기에 자기 프레임 문구가 없다', () {
    for (final taskId in authoredTaskIds) {
      for (final q in readQuestions(taskId)) {
        final options = q['options'] as List<dynamic>;
        final asked = '${q['stem']}\n${options[q['correct'] as int]}';
        for (final p in selfFramePhrases) {
          expect(asked.contains(p), isFalse,
              reason: '${q['id']}: 지문·정답 보기에 "$p". 실질 질문은 이미 들어 있고 '
                  '이 문구는 크러치다 — 출처 귀속은 해설로 옮긴다');
        }
      }
    }
  });

  test('대조군: 해설의 출처 귀속은 그대로 두고 센다', () {
    var attributed = 0;
    for (final taskId in authoredTaskIds) {
      for (final q in readQuestions(taskId)) {
        if ('${q['explanation']}'.contains('공식')) attributed++;
      }
    }
    expect(attributed, greaterThanOrEqualTo(20),
        reason: '해설이 출처를 귀속하지 않으면 위 탐지기의 층 분리가 공허하다 '
            '(2026-11-15 실측 29/45)');
  });
}
