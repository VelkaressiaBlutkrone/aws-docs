import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'flip_allowlist.dart';

/// SCS-C03 문항 가드 — **문항 저작 전에 미리 세운 선결 가드**(2026-11-09).
///
/// ## 왜 문항이 하나도 없는데 지금 만드는가
///
/// AIF-C01이 2026-11-05에 같은 이유로 먼저 세웠고(`aif_questions_test.dart`),
/// 셋 다 "나중에 하면 늦는" 것들이다.
///
///  1. `review.mjs`의 `CERTS.scs.flipAllowlist`가 **이 파일의
///     `flipApprovedTaskIds`를 가리킨다.** 파일이 없으면 `review.test.mjs`의
///     "flipAllowlist의 파일·심볼이 실재한다"가 레드다.
///  2. 허용 목록이 없으면 **사람의 첫 flip이 반드시 레드로 끝난다** — 드래프트
///     전수 단정이 `CERTS[<cert>].tests`에 들어 있어, `review.mjs flip`이
///     문항 파일을 다 쓴 뒤 그 단정에서 멈춘다(`--force`는 쓰기 **전** 구조
///     검사만 건너뛴다). MLA가 #246에서, SOA·DEA가 #286에서 같은 함정을 밟았다.
///  3. 문항이 들어온 **뒤에** 가드를 만들면 이미 쓴 문항에 가드를 맞추게 된다.
///     먼저 세워 두면 첫 배치부터 가드가 강제한다.
///
/// ## ⚠️⚠️ AIF 판을 그대로 베끼면 가드가 공허해진다
///
/// AIF 가이드 JSON은 목표를 **`knowledge`**에 담고 `skills`를 빈 배열로 둔다.
/// **SCS-C03은 그 반대다** — 2026-11-09 실측으로 `knowledge`가 **16개 Task 전부
/// 빈 배열**이고 공식 기술 **70개**가 전부 `skills`에 있다. AIF 판의
/// `task['knowledge']`를 그대로 옮기면 번호 집합이 **빈 집합**이 되고,
/// 그러면 "skill이 실재하는 기술 번호다"가 전 문항을 **거짓으로 거부**한다.
/// 아래 대조군이 그 구조 비대칭을 양방향으로 못박는다.
///
/// ## 문항 0개에서 공허하지 않으려면
///
/// `dea_questions_test.dart`는 `deaTaskIds` 전수를 돌며 파일 존재를 단정한다 —
/// 문항이 이미 다 들어와 있어서 가능한 형태이고 SCS에 그대로 쓰면 **16건
/// 레드**다. 그래서 「저작된 Task 선언 ↔ 디스크 일치」로 간다: 선언이 비어
/// 있어도 단정은 비어 있지 않다(문항을 넣고 선언을 빠뜨리면 레드, 선언만 하고
/// 파일을 안 넣어도 레드).
void main() {
  const certCode = 'SCS-C03';
  const dir = 'assets/content/scs';

  /// 문항이 저작된 Task — **배치마다 늘린다.**
  ///
  /// ⚠️ 늘릴 때 `scs_doc_format_test.dart`의 `scsTaskIds`는 **이미 16개 전부**라
  /// 건드릴 일이 없다(학습문서는 2026-11-09에 완료됐다). MLA에서 두 파일 중
  /// 한쪽만 늘려 빠뜨린 적이 있어 적어 둔다.
  /// ⚠️ 그리고 첫 배치에서 `tool/review.test.mjs`의 `preAuthoring` 집합에서
  /// `scs`를 **지워야 한다** — 안 지우면 node 단계가 1초 만에 레드다(설계대로다).
  const authoredTaskIds = <String>{
    'scs-t1-1', 'scs-t1-2', 'scs-t1-3', // 도메인 1 (2026-11-09)
    'scs-t2-1', 'scs-t2-2', // 도메인 2 (2026-11-10)
    'scs-t3-1', 'scs-t3-2', 'scs-t3-3', // 도메인 3 (2026-11-10)
    'scs-t4-1', 'scs-t4-2', // 도메인 4 (2026-11-10)
    'scs-t5-1', 'scs-t5-2', 'scs-t5-3', // 도메인 5 (2026-11-10)
    'scs-t6-1', 'scs-t6-2', 'scs-t6-3', // 도메인 6 (2026-11-10)
  };

  /// 사람이 검수를 마쳐 flip한 Task — **AI는 여기에 손대지 않는다.**
  /// `node tool/review.mjs flip scs <taskId>`가 대신 넣어 주고, 그 diff가
  /// 사람의 서명이다.
  const flipApprovedTaskIds = <String>{};

  /// 공식 Task 16개. 저작 결정 D-01(공식 Task 1개 = 학습문서 1편).
  /// 도메인별 Task 수는 3·2·3·2·3·3이다(2026-11-09 실측).
  const allTaskIds = [
    'scs-t1-1', 'scs-t1-2', 'scs-t1-3',
    'scs-t2-1', 'scs-t2-2',
    'scs-t3-1', 'scs-t3-2', 'scs-t3-3',
    'scs-t4-1', 'scs-t4-2',
    'scs-t5-1', 'scs-t5-2', 'scs-t5-3',
    'scs-t6-1', 'scs-t6-2', 'scs-t6-3',
  ];

  Map<String, dynamic> guide() {
    final raw = File('assets/exam_guides/$certCode.json').readAsStringSync();
    return json.decode(raw) as Map<String, dynamic>;
  }

  /// 공식 기술 번호 전체(`1.1.1` … `6.3.3`)를 시험 가이드 JSON에서 유도한다.
  ///
  /// ⚠️ **`skills`를 읽는다** — SCS 가이드는 `knowledge`를 비워 두고 기술 70개를
  /// `skills`에 담는다(위 클래스 주석). 가이드 JSON은 2026-11-08에 공식 전문과
  /// **70/70 바이트 일치**로 맞춰 뒀고(`scs_guide_sync_test.dart`), 여기서 쓰는
  /// 것은 본문이 아니라 **번호 집합**이다.
  Set<String> officialSkillNumbers() {
    final numbers = <String>{};
    for (final d in guide()['domains'] as List<dynamic>) {
      final domain = d as Map<String, dynamic>;
      for (final t in domain['tasks'] as List<dynamic>) {
        final task = t as Map<String, dynamic>;
        // ⚠️ `task['no']`는 이미 `'1.1'`처럼 **도메인 번호를 포함**한다(실측).
        // 앞에 `domain['no']`를 또 붙이면 `1.1.1.1`이 된다(AIF가 그 실수를
        // 대조군으로 잡았다 — CLAUDE.md 기준선 메모).
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
  // 이 단정이 없으면 아래 "skill이 실재하는 기술 번호다"가 **빈 집합**을
  // 상대로 통과할 수 있다. 공식 기술은 70개이고 Task별 분해는
  // 5·6·2 / 4·5 / 4·7·5 / 3·5 / 3·4·5 / 5·4·3 이다(2026-11-09 전수 실측).
  test('대조군: 시험 가이드에서 공식 기술 번호 70개가 유도된다', () {
    final numbers = officialSkillNumbers();
    expect(numbers.length, 70,
        reason: '기술 번호 유도가 깨졌다 — 가이드 JSON 구조가 바뀌었는지 본다');
    expect(numbers, contains('1.1.1'));
    expect(numbers, contains('3.2.7'), reason: '가장 두꺼운 Task는 3.2(기술 7개)다');
    expect(numbers, contains('6.3.3'), reason: 'SCS는 도메인이 6개다');
    expect(numbers, isNot(contains('1.3.3')),
        reason: '가장 얇은 Task는 1.3(기술 2개)다');
    expect(numbers, isNot(contains('6.4.1')),
        reason: '도메인 6은 Task가 3개뿐이다');
    expect(numbers, isNot(contains('7.1.1')),
        reason: 'SCS는 도메인이 6개까지다');
  });

  // ⚠️⚠️ 구조 비대칭을 **양방향으로** 못박는다. AIF 판을 베껴 `knowledge`를
  // 읽으면 번호 집합이 빈 집합이 되고 가드가 전 문항을 거짓으로 거부한다.
  test('대조군: SCS 가이드는 knowledge가 비어 있고 기술이 skills에 있다', () {
    var knowledgeTotal = 0;
    var skillsTotal = 0;
    var taskCount = 0;
    for (final d in guide()['domains'] as List<dynamic>) {
      for (final t in (d as Map<String, dynamic>)['tasks'] as List<dynamic>) {
        final task = t as Map<String, dynamic>;
        knowledgeTotal += (task['knowledge'] as List<dynamic>).length;
        skillsTotal += (task['skills'] as List<dynamic>).length;
        taskCount++;
      }
    }
    expect(taskCount, 16, reason: 'SCS 공식 Task는 16개다(3·2·3·2·3·3)');
    expect(knowledgeTotal, 0,
        reason: 'SCS 가이드의 knowledge는 전부 빈 배열이다 — '
            '여기가 0이 아니게 되면 officialSkillNumbers의 소스를 다시 판단한다');
    expect(skillsTotal, 70,
        reason: '기술은 skills에 70개 있다 — AIF와 반대 구조다');
  });

  // ── 선언 ↔ 디스크 일치 ───────────────────────────────────────────────
  //
  // 선언이 비어 있어도 이 단정은 비어 있지 않다: 문항을 넣고 선언을 빠뜨리면
  // 레드, 선언만 하고 파일을 안 넣어도 레드다.
  test('authoredTaskIds가 실제 문항 파일 집합과 일치한다', () {
    final onDisk = {
      for (final taskId in allTaskIds)
        if (File(questionPath(taskId)).existsSync()) taskId,
    };
    expect(onDisk, authoredTaskIds,
        reason: '문항 파일을 추가·삭제했으면 authoredTaskIds도 맞춘다 — '
            '첫 배치에서는 `tool/review.test.mjs`의 preAuthoring에서 '
            '`scs`를 지우는 것도 함께 한다');
  });

  test('authoredTaskIds는 공식 Task 16개의 부분집합이다', () {
    expect(allTaskIds.length, 16, reason: 'SCS 공식 Task는 16개다(D-01)');
    expect(allTaskIds.toSet().length, 16, reason: 'taskId가 중복됐다');
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
          expect(correct as int, inInclusiveRange(0, 3), reason: '$id: correct 범위 밖');
          final expected = {
            for (var i = 0; i < 4; i++)
              if (i != correct) '$i',
          };
          expect((q['wrongExplanations'] as Map).keys.toSet(), expected,
              reason: '$id: wrongExplanations 키가 오답 인덱스와 다르다');
        }
      });

      test('skill 태그가 실재하는 공식 기술 번호다 (저작 결정 D-04)', () {
        final numbers = officialSkillNumbers();
        final prefix =
            taskId.replaceAll(RegExp(r'^scs-t'), '').replaceAll('-', '.');
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
            '${taskId.replaceAll(RegExp(r'^scs-t'), '').replaceAll('-', '.')}.';
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
                  '`node tool/review.mjs flip scs $taskId`로 넣는다',
        );
      });
    });
  }

  // ⚠️⚠️ **난이도 쏠림 가드**(2026-11-10 신설). 검수 준비 스캔에서 **도메인 5·6의
  //    6 Task 가 `foundational` 0~1개**로 흘렀고 `scs-t5-1`·`scs-t6-2` 는 **0개**라
  //    그 Task 에 진입용 문항이 하나도 없었다(D1~D4 는 Task 당 2~5개). 자격증 전체
  //    비율(당시 16.7%)은 Specialty 로서 정상 범위였으므로 **문제는 자격증 안의
  //    쏠림**이고, 전역 비율이 아니라 **Task 단위 하한**으로 잡는다.
  //
  // ⚠️ 하한을 **2**로 두는 이유는 실측이다 — D1~D4 의 최솟값이 `scs-t4-1`·
  //    `scs-t4-2` 의 **2**다. 3으로 올리면 그 두 Task 가 즉시 레드가 되는데 그것은
  //    저작 판단을 사후에 뒤집는 것이라 하지 않는다.
  //
  // ⚠️ 상한은 두지 않는다 — `foundational` 이 많은 것은 결함이 아니다(CLF 는 76%다).
  test('Task 마다 foundational 문항이 최소 2개다 (난이도 쏠림 방지)', () {
    const minFoundational = 2;
    final counts = <String, int>{};
    for (final taskId in authoredTaskIds) {
      counts[taskId] = readQuestions(taskId)
          .where((q) => q['difficulty'] == 'foundational')
          .length;
    }
    // 대조군: 라벨을 읽고 있는지 먼저 센다(전부 0이면 파싱이 샌 것이다).
    expect(counts.values.fold<int>(0, (a, b) => a + b),
        greaterThanOrEqualTo(2 * authoredTaskIds.length),
        reason: '전 Task 합이 하한의 총합보다 적다 — 라벨을 못 읽었는지 먼저 본다');
    final short = {
      for (final e in counts.entries)
        if (e.value < minFoundational) e.key: e.value,
    };
    expect(short, isEmpty,
        reason: 'foundational 이 $minFoundational개 미만인 Task 가 있다 — '
            '학습자가 그 Task 에서 진입용 문항을 만나지 못한다. '
            '회상·분류형 문항(「공식 서술로 올바른 것은」·「올바르게 짝지은」)에 '
            '`foundational` 을 붙인다: $short');
  });

  // ══════════════════════════════════════════════════════════════════
  // 저작 메모·시험 예측 금지 (2026-11-11 외부 검수 보고 §4 2단계)
  //
  // 보고 🟢 가 「해설에 남은 저작 메모」로 든 계열이다. **저작자의 판정 기준·학습
  // 지시·출제 예측**이 학습자 문장으로 새어 나온 자리이고, 학습자에게 쓸모가 없고
  // 틀릴 수도 있다. 문항 10개 자리 + **라이브 학습문서 11개 자리**를 사실 서술로
  // 바꿨다.
  //
  // ⚠️⚠️ **보고 대상은 문항 뱅크였지만 같은 문구가 md 에도 있었다** — 레포 규율대로
  // (「한 파일에서 오류를 찾으면 그 문구로 레포 전역을 쓸고 가드도 전역으로 건다」)
  // 이 가드는 **md 와 문항을 함께** 본다. 문항만 보면 학습자가 같은 저작 메모를
  // 옆 학습문서에서 읽는다.
  //
  // ⚠️ **아직 금지하지 않는 계열이 셋 있다** — 판정 없이 금지하면 참인 문장을 지운다.
  //   - `외우` : SCS md 6편 · 전 자격증 md 55편. 「지원 유형 목록은 외우지 않고 CLI
  //     조회 절차로 확인한다」처럼 **공식이 적어 둔 절차를 안내**하는 정당한 서술이
  //     섞여 있다. `scs-t3-1-q4` 의 것은 보고가 **보류(교체)**로 분류했다.
  //   - `단정하지` : `scs-t2-2-q15` · `scs-t6-1-q9` 가 보고 **보류(재작성)** 목록이라
  //     이 배치의 범위가 아니다(§4 6단계).
  //   - `묻지 않` : 전 자격증 md 11편. 「개수를 묻지 않는다」는 D-16 판정을 학습문서에
  //     **의도적으로 명시**한 것이다.
  //   세 계열의 현재 수를 아래 대조군이 고정해, 범위를 넓힐 때 무엇을 보게 되는지
  //   남긴다.
  group('저작 메모·시험 예측이 학습자 문장에 없다', () {
    /// 저작된 Task 의 md + 문항을 합쳐 읽는다(`scs_doc_format_test` 와 같은 방식).
    String authoredTextOf(String taskId) {
      final buf = StringBuffer();
      for (final ext in const ['.md', '.questions.json']) {
        final f = File('$dir/$taskId$ext');
        if (f.existsSync()) buf.writeln(f.readAsStringSync());
      }
      return buf.toString();
    }

    final forbidden = <String, String>{
      '자주 출제': '출제 예측 — 학습자에게 쓸모가 없고 틀릴 수 있다',
      '옛 교재': '저작자가 다른 교재를 평가한다',
      '교재가': '같은 계열 — 「교재가 가장 빨리 낡는 자리」',
      '공부 시간': '저작자가 학습자의 공부 배분을 지시한다',
      '쪽이 정본': '저작 규율 메모 — 어느 출처를 정본으로 삼았는지는 저작자의 일이다',
      '시험이 묻는': '시험 예측',
      '어느 쪽이든 거짓': '저작 규율 메모 — 사실은 「두 서술이 다른 계층」이다',
    };

    test('금지 문구가 md·문항 전수에서 0건이다', () {
      final hits = <String, List<String>>{};
      for (final taskId in authoredTaskIds) {
        final text = authoredTextOf(taskId);
        for (final phrase in forbidden.keys) {
          if (text.contains(phrase)) {
            (hits[phrase] ??= <String>[]).add(taskId);
          }
        }
      }
      expect(hits, isEmpty,
          reason: '저작 메모가 학습자 문장에 남아 있다. 사실 서술로 바꾼다 '
              '(지우기만 하면 교육 가치가 빈다): $hits');
    });

    test('대조군: 탐지기가 글을 실제로 읽고 있다', () {
      // 0이면 위 단정이 공허하다.
      final text = authoredTextOf(authoredTaskIds.first);
      expect(text.length, greaterThan(10000),
          reason: 'md + 문항을 합쳐 읽어야 한다');
      expect(text.contains('공식'), isTrue);
      // 금지 문구를 실제로 잡는지.
      expect(forbidden.keys.any(('옛 교재는 이렇게 적는다').contains), isTrue);
    });

    test('아직 금지하지 않는 세 계열의 현재 수를 고정한다', () {
      // 범위를 넓히는 배치가 무엇을 보게 되는지 남긴다 — 이 수가 늘면
      // 누군가 새 저작 메모를 넣었다는 뜻이고, 줄면 정리가 진행된 것이다.
      int filesWith(String phrase, String ext) => authoredTaskIds
          .where((t) => File('$dir/$t$ext').existsSync())
          .where((t) => File('$dir/$t$ext').readAsStringSync().contains(phrase))
          .length;
      expect(filesWith('외우', '.md'), lessThanOrEqualTo(6),
          reason: '⚠️ 정당한 용례가 섞여 있다 — 늘어나면 새로 들어온 것을 본다');
      // ⭐ 계열이 닫혔다(2026-11-12) — 보고가 든 둘(`t2-2-q15` 6단계 배치 1 ·
      //    `t6-1-q9` 배치 2)을 단정문으로 바꿔 **문항 전수 0건**이다. 하한을
      //    0으로 고정해 앞으로 문항에 메타 표현이 들어오면 알린다.
      //    ⚠️ `.md` 쪽 2편은 **D-16 판정을 의도적으로 가르치는 자리**라
      //    대상이 아니다(이 단정은 `.questions.json` 만 센다).
      expect(filesWith('단정하지', '.questions.json'), 0,
          reason: '문항에서 「…단정하지 않습니다」는 메타 표현이다 — 보고 판정');
      expect(filesWith('묻지 않', '.md'), lessThanOrEqualTo(2),
          reason: 'D-16 판정을 학습문서에 명시한 것이다');
    });
  });

  // ══════════════════════════════════════════════════════════════════
  // 공식 근거가 붙은 🟡 4건 (2026-11-11 외부 검수 보고 §4 3단계)
  //
  // 보고가 공식 문서를 들어 지적한 넷을 각각 재측정했다. **정답 인덱스는 네 건 모두
  // 불변**이고 셋은 보고가 옳았으며 하나는 **방향만** 옳았다.
  //
  // ⚠️⚠️ `t3-1-q3` — 보고는 「규칙 작업은 Allow·Block·Count·CAPTCHA·Challenge **다섯**
  // 이다」로 적었지만 공식 `waf-rule-action.html` 의 불릿은 **넷**이다(`CAPTCHA and
  // Challenge` 가 한 불릿). 2026-11-10 내 T2 패스가 「인용 페이지 기준으로 정확하다」로
  // 판정한 것이 그 때문이다. **그런데 같은 페이지에 `Monetize` 작업 절이 따로 있다** —
  // CloudFront 연결 웹 ACL 전용이고 `MonetizationConfig` 가 필요하며 HTTP 402 와 x402
  // 결제 지시를 돌려준다(AI 봇·에이전트 과금용). 그래서 **「넷」 단정이 이제 불완전**
  // 하다. 그리고 보고의 더 중요한 지적이 옳다 — 공식 용어는 **rule action**(규칙 작업)과
  // **web ACL default action**(기본 작업: Allow/Block)이 **다른 것**인데 문항이
  // 「기본 규칙 작업」으로 섞었다. → D-16 계열 규율대로 **개수를 묻지 않고** 과금 층만
  // 묻게 고쳤다. ⭐ 그 결과 정답 보기가 96 → 47자가 되어 **길이 단서까지 해소**됐다.
  //
  // ⚠️ `t4-1-q7`·`t6-2-q13`·`t6-1-q15` 는 정답 보기가 아직 최장이다(84 · 151 · 100) —
  // **§4 5단계(P-2)의 전용 작업**이고, 이 배치는 **길이를 늘리지 않았다**는 것만
  // 보장한다(`t4-1-q7` 은 1차 초안이 88 → 95로 **늘렸고 내 단정이 잡아** 84로 줄였다).
  group('공식 근거가 붙은 🟡 4건 (보고 §4 3단계)', () {
    Map<String, dynamic> q(String id) {
      final taskId = id.substring(0, id.lastIndexOf('-'));
      return readQuestions(taskId).firstWhere((e) => e['id'] == id);
    }

    String allOf(String id) => jsonEncode(q(id));

    test('정답 인덱스가 네 건 모두 불변이다', () {
      // ⚠️ 보고는 정답 인덱스를 적지 않는다 — 이 값은 실측이다.
      expect(q('scs-t3-1-q3')['correct'], 2);
      expect(q('scs-t4-1-q7')['correct'], 2);
      expect(q('scs-t6-2-q13')['correct'], 0);
      expect(q('scs-t6-1-q15')['correct'], 3);
      for (final id in const [
        'scs-t3-1-q3', 'scs-t4-1-q7', 'scs-t6-2-q13', 'scs-t6-1-q15',
      ]) {
        expect(q(id)['verified'], isFalse, reason: '$id 은 드래프트다');
      }
    });

    test('t3-1-q3: 규칙 작업 개수를 단정하지 않고 과금 층만 묻는다', () {
      final all = allOf('scs-t3-1-q3');
      expect(all.contains('기본 규칙 작업'), isFalse,
          reason: '공식은 rule action 과 web ACL default action 을 구분한다');
      expect(all.contains('기본 작업은'), isFalse,
          reason: '「기본 작업」은 웹 ACL 의 Allow/Block 이고 규칙 작업이 아니다');
      expect(all.contains('넷입니다'), isFalse,
          reason: 'Monetize 작업이 추가돼 개수 단정이 불완전하다');
      // 과금 층은 그대로 가르친다(지우는 것이 목적이 아니다).
      for (final fact in const ['Bot Control', '계정 탈취 방지', '계정 생성 사기 방지']) {
        expect(all.contains(fact), isTrue, reason: '추가 요금 층: $fact');
      }
      expect(all.contains('CAPTCHA'), isTrue,
          reason: 'CAPTCHA·Challenge 규칙 작업 자체에도 추가 요금이 붙는다');
    });

    test('t4-1-q7: AssumeRole 도 쓸 수 있다고 적는다', () {
      final all = allOf('scs-t4-1-q7');
      // 공식: "Call the AWS STS AssumeRole (recommended) or GetFederationToken".
      expect(all.contains('쓸 수 있는 것은 GetFederationToken입니다'), isFalse,
          reason: '배타 서술이 거짓이었다 — AssumeRole 도 쓸 수 있고 공식이 권장한다');
      expect(all.contains('AssumeRole'), isTrue);
      expect((q('scs-t4-1-q7')['explanation'] as String).contains('권장'), isTrue,
          reason: '공식이 AssumeRole 을 recommended 로 적는다');
      expect(all.contains('DurationSeconds'), isTrue,
          reason: 'AssumeRole 계열에 쓰려면 장기 자격 증명 IAM 사용자로 호출해야 하고 '
              '그러지 않으면 페더레이션 엔드포인트 호출이 실패한다');
      // 정답의 핵심(GetSessionToken 은 콘솔 SSO 에 못 쓴다)은 그대로다.
      expect(all.contains('GetSessionToken'), isTrue);
    });

    test('t6-2-q13: 공식이 뒷받침하지 않는 전제를 쓰지 않는다', () {
      final stem = q('scs-t6-2-q13')['stem'] as String;
      // 공식 `ram/what-is.html` 은 리소스 기반 정책 공유를 "some types" 까지만 말하고
      // **서브넷은 RAM 공유의 공식 예시**다. 그래서 「서브넷을 리소스 기반 정책으로
      // 공유했다」는 전제가 근거를 얻지 못한다.
      // ⚠️ 「서브넷은 리소스 기반 정책이 없다」고 **단정하지 않는다** — 공식이 유형을
      // 열거하지 않는다. 그래서 지문에서 리소스 종류를 빼는 쪽으로 고쳤다.
      expect(stem.contains('서브넷'), isFalse,
          reason: '지문이 리소스 종류를 특정하면 그 유형이 리소스 기반 정책을 '
              '지원하는지까지 공식 근거가 필요하다');
      expect(stem.contains('리소스 기반 정책'), isTrue);
      // 대조군 — 해설의 RAM 서브넷 예시는 공식 그대로이므로 남아 있어야 한다.
      expect((q('scs-t6-2-q13')['explanation'] as String).contains('서브넷'), isTrue,
          reason: '공식이 드는 대비 예다 — RAM 으로 공유한 VPC 서브넷은 상대 계정의 '
              'VPC 콘솔과 API 결과에 나타난다');
    });

    test('t6-1-q15: 멤버 계정으로 한정하고 관리 계정 루트를 따로 적는다', () {
      final stem = q('scs-t6-1-q15')['stem'] as String;
      // 공식 중앙 집중화는 **멤버 계정** 루트 자격 증명 제거다. 관리 계정 루트는 그
      // 대상이 아니라 남아 있고 MFA 로 보호하므로, 보기 [0]의 보관 절차 자체는 실무다.
      // 갈림길은 그것이 **워크로드 비상 접근 프로세스가 아니라는** 점이다.
      expect(stem.contains('멤버 계정'), isTrue,
          reason: '「루트 자격 증명을 모두 없앴다」는 관리 계정까지 포함해 읽힌다');
      final w0 = (q('scs-t6-1-q15')['wrongExplanations']
          as Map<String, dynamic>)['0'] as String;
      expect(w0.contains('관리 계정 루트'), isTrue,
          reason: '참인 실무를 「공식이 드는 형태가 아니다」로만 반박하면 안 된다');
      expect(w0.contains('비상 접근'), isTrue,
          reason: '갈림길은 계정 복구용과 워크로드 비상 접근의 구분이다');
    });
  });
}
