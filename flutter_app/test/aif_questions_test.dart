import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'flip_allowlist.dart';

/// AIF-C01 문항 가드 — **문항 저작 전에 미리 세운 선결 가드**(2026-11-05).
///
/// ## 왜 문항이 하나도 없는데 지금 만드는가
///
/// 셋 다 "나중에 하면 늦는" 것들이기 때문이다.
///
///  1. `review.mjs`의 `CERTS.aif.flipAllowlist`가 **이 파일의
///     `flipApprovedTaskIds`를 가리킨다.** 파일이 없으면 `review.test.mjs`의
///     "flipAllowlist의 파일·심볼이 실재한다"가 레드다.
///  2. 허용 목록이 없으면 **사람의 첫 flip이 반드시 레드로 끝난다** — 드래프트
///     전수 단정이 `CERTS[<cert>].tests`에 들어 있어, `review.mjs flip`이
///     문항 파일을 다 쓴 뒤 그 단정에서 멈춘다(`--force`는 쓰기 **전** 구조
///     검사만 건너뛴다). MLA가 #246에서, SOA·DEA가 #286에서 같은 함정을 밟았다.
///  3. 문항이 들어온 **뒤에** 가드를 만들면 이미 쓴 문항에 가드를 맞추게 된다.
///     먼저 세워 두면 첫 배치부터 가드가 강제한다.
///
/// ## 문항 0개에서 공허하지 않으려면
///
/// `dea_questions_test.dart`는 `deaTaskIds` 전수를 돌며
/// `expect(File(path).existsSync(), isTrue)`를 단정한다 — 문항이 이미 다
/// 들어와 있어서 가능한 형태다. AIF에 그대로 쓰면 **14건 레드**다.
///
/// 그래서 「저작된 Task 선언」 방식으로 간다(`aif_doc_format_test.dart`의
/// `aifTaskIds`와 같은 패턴). 핵심은 **선언과 디스크가 일치하는지**를 보는
/// 것이라, 선언이 비어 있어도 단정이 비어 있지 않다 — 문항을 넣고 선언을
/// 빠뜨리면 레드, 선언만 하고 파일을 안 넣어도 레드다.
///
/// 그리고 **가드의 입력이 실제로 만들어졌는지**를 먼저 확인하는 대조군을 둔다
/// (목표 번호 69개). 이것이 없으면 "목표 번호가 실재한다"는 단정이 빈 집합을
/// 상대로 조용히 통과할 수 있다.
void main() {
  const certCode = 'AIF-C01';
  const dir = 'assets/content/aif';

  /// 문항이 저작된 Task — **배치마다 늘린다.**
  ///
  /// ⚠️ 늘릴 때 `aif_doc_format_test.dart`의 `aifTaskIds`와 **둘 다** 봐야 한다
  /// (MLA에서 한쪽만 늘려 빠뜨린 적이 있다 — CLAUDE.md 기준선 메모).
  /// ⚠️ 그리고 `tool/review.test.mjs`의 `preAuthoring` 집합에서 `aif`를
  /// **지워야 한다** — 첫 배치에서 지웠다.
  const authoredTaskIds = <String>{
    'aif-t1-1', 'aif-t1-2', 'aif-t1-3', // 도메인 1 (2026-11-05)
    'aif-t2-1', 'aif-t2-2', 'aif-t2-3', // 도메인 2 (2026-11-05)
  };

  /// 사람이 검수를 마쳐 flip한 Task — **AI는 여기에 손대지 않는다.**
  /// `node tool/review.mjs flip aif <taskId>`가 대신 넣어 주고, 그 diff가
  /// 사람의 서명이다.
  const flipApprovedTaskIds = <String>{};

  /// 공식 Task 14개. 저작 결정 D-01(공식 Task 1개 = 학습문서 1편).
  const allTaskIds = [
    'aif-t1-1', 'aif-t1-2', 'aif-t1-3',
    'aif-t2-1', 'aif-t2-2', 'aif-t2-3',
    'aif-t3-1', 'aif-t3-2', 'aif-t3-3', 'aif-t3-4',
    'aif-t4-1', 'aif-t4-2',
    'aif-t5-1', 'aif-t5-2',
  ];

  /// 공식 목표 번호 전체(`1.1.1` … `5.2.3`)를 시험 가이드 JSON에서 유도한다.
  ///
  /// ⚠️ 저작 결정 D-06은 레포 JSON을 **저작 입력**으로 쓰지 말라고 한다(목표
  /// **본문** 69건 중 17건이 공식 v1.1과 다르다). 여기서 쓰는 것은 본문이
  /// 아니라 **번호 집합**이고, 00-overview §5가 번호 집합·순서가 공식과
  /// 완전히 일치함을 기계 대조로 확인해 뒀다. 본문 교체는 문항 저작 PR 몫이고
  /// 그 교체도 이 번호 집합을 바꾸지 않는다.
  Set<String> officialObjectiveNumbers() {
    final raw = File('assets/exam_guides/$certCode.json').readAsStringSync();
    final guide = json.decode(raw) as Map<String, dynamic>;
    final numbers = <String>{};
    for (final d in guide['domains'] as List<dynamic>) {
      final domain = d as Map<String, dynamic>;
      for (final t in domain['tasks'] as List<dynamic>) {
        final task = t as Map<String, dynamic>;
        // ⚠️ `task['no']`는 이미 `'1.1'`처럼 **도메인 번호를 포함**한다(실측).
        // 앞에 `domain['no']`를 또 붙이면 `1.1.1.1`이 되고, 그러면
        // "skill이 실재한다"가 전 문항을 거짓으로 거부한다. 아래 대조군이
        // 실제로 그 실수를 잡았다.
        final objectives = task['knowledge'] as List<dynamic>;
        for (var i = 0; i < objectives.length; i++) {
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
  // 이 단정이 없으면 아래 "skill이 실재하는 목표 번호다"가 **빈 집합**을
  // 상대로 통과할 수 있다. 공식 목표는 69개이고 그 분해는
  // 5·6·6 / 6·4·4 / 6·5·3·5 / 7·4 / 5·3이다(00-overview §3 전수 실측).
  test('대조군: 시험 가이드에서 공식 목표 번호 69개가 유도된다', () {
    final numbers = officialObjectiveNumbers();
    expect(numbers.length, 69,
        reason: '목표 번호 유도가 깨졌다 — 가이드 JSON 구조가 바뀌었는지 본다');
    expect(numbers, contains('1.1.1'));
    expect(numbers, contains('4.1.7'), reason: '도메인 4는 Task 4.1이 목표 7개다');
    expect(numbers, contains('5.2.3'), reason: 'AIF는 도메인이 5개다');
    expect(numbers, isNot(contains('5.3.1')),
        reason: '도메인 5는 Task가 2개뿐이다');
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
            '`aif_doc_format_test.dart`의 aifTaskIds와 **둘 다** 본다');
  });

  test('authoredTaskIds는 공식 Task 14개의 부분집합이다', () {
    expect(allTaskIds.length, 14, reason: 'AIF 공식 Task는 14개다(D-01)');
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

      test('skill 태그가 실재하는 공식 목표 번호다 (저작 결정 D-04)', () {
        final numbers = officialObjectiveNumbers();
        for (final q in readQuestions(taskId)) {
          final skill = '${q['skill']}';
          expect(numbers, contains(skill),
              reason: '${q['id']}: skill "$skill"은 공식 목표 번호가 아니다. '
                  'AIF 가이드에는 Skill 계층이 없어 목표 번호를 태그로 쓴다');
          expect(skill, startsWith(taskId.replaceAll(RegExp(r'^aif-t'), '').replaceAll('-', '.')),
              reason: '${q['id']}: skill "$skill"이 이 Task($taskId)의 목표가 아니다');
        }
      });

      test('이 Task의 모든 목표가 최소 한 문항에 덮인다', () {
        final prefix = '${taskId.replaceAll(RegExp(r'^aif-t'), '').replaceAll('-', '.')}.';
        final taskObjectives = officialObjectiveNumbers()
            .where((n) => n.startsWith(prefix))
            .toSet();
        final covered = {for (final q in readQuestions(taskId)) '${q['skill']}'};
        expect(taskObjectives.difference(covered), isEmpty,
            reason: '$taskId: 덮이지 않은 목표가 있다');
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
                  '`node tool/review.mjs flip aif $taskId`로 넣는다',
        );
      });
    });
  }
}
