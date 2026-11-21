import 'dart:convert';
import 'dart:io';

import 'package:aws_docs/content/markdown_parser.dart';
import 'package:aws_docs/data/content_index.dart';
import 'package:aws_docs/models/study_content.dart';
import 'package:flutter_test/flutter_test.dart';

/// 문항의 section(있으면)이 그 Task 학습문서의 실제 {#id} 앵커를 가리키는지 가드.
/// section 없는 문항은 통과(점진 — 미연결 허용). 오타·유실 시 실패.
///
/// 2026-11-18 외부 리뷰 후속(§4-2)으로 CLF 한 자격증에서 **`kContentIndex` 에 등재된 전
/// 자격증**으로 넓혔다 — 해설·오답노트의 「학습문서로 이동」 딥링크(`?at=`)가 이 값을 쓰므로,
/// 앵커가 사라지면 다른 자격증에서는 아무도 알려 주지 않았다. 등재 목록에서 유도하므로 새
/// 자격증은 등재와 함께 자동으로 덮인다.
Set<String> _anchorsOf(ContentEntry entry) =>
    parseStudyDoc(File(entry.mdAsset).readAsStringSync())
        .blocks
        .whereType<MdHeading>()
        .map((h) => h.anchor)
        .whereType<String>()
        .toSet();

List<Map<String, dynamic>> _questionsOf(ContentEntry entry) {
  final file = File(entry.questionsAsset);
  if (!file.existsSync()) return const [];
  final qjson = json.decode(file.readAsStringSync()) as Map<String, dynamic>;
  return (qjson['questions'] as List).cast<Map<String, dynamic>>();
}

/// 앵커가 있어야 하는 제목 — `## 📖 핵심 개념`, 그 아래 `###` 전부, `## ⚠️ 흔한 함정`.
/// SAA-C03 24편이 쓰는 규칙이다. 체크리스트·용어·시험 포인트·자가 점검·출처는 문항이
/// 가리킬 자리가 아니라 달지 않는다.
List<MdHeading> _anchorTargets(List<MdBlock> blocks) {
  final targets = <MdHeading>[];
  var inCore = false;
  for (final h in blocks.whereType<MdHeading>()) {
    if (h.level == 2) {
      inCore = h.text.contains('핵심 개념');
      if (inCore || h.text.contains('흔한 함정')) targets.add(h);
    } else if (h.level == 3 && inCore) {
      targets.add(h);
    }
  }
  return targets;
}

/// 파서가 **실제로 읽은** 제목으로 판정한다(코드블록 안의 `#` 주석은 제목이 아니다).
/// ⚠️ 중복은 표기 문제가 아니다 — `buildAnchorKeys` 가 앵커 하나에 `GlobalKey` 하나를 주므로
/// 같은 앵커가 두 제목에 붙으면 그 학습문서가 렌더 중 예외로 깨진다.
List<String> _anchorRuleViolations(String md) {
  final blocks = parseStudyDoc(md).blocks;
  final targets = _anchorTargets(blocks).toSet();
  final violations = <String>[];
  final seen = <String>{};
  for (final h in blocks.whereType<MdHeading>()) {
    final id = h.anchor;
    if (targets.contains(h) && id == null) violations.add('앵커 없음: ${h.text}');
    if (id == null) continue;
    if (!targets.contains(h)) violations.add('규칙 밖 앵커: ${h.text} {#$id}');
    if (!seen.add(id)) violations.add('중복 앵커: $id');
  }
  return violations;
}

void main() {
  // ⚠️ SOA-C03(300문항)은 아직 section 이 **0개**다(학습문서 앵커는 2026-11-21 배치 0 으로 생겼다).
  // SAA-C03 은 C 트랙 배치 1~3 으로 채우는 중이다. 누가 SOA 에 section 을 달기 시작하면 이 단정이
  // 깨져 「집합에 넣어라」고 알리고, 아래 Task별 단정은 그 순간부터 자동으로 그 앵커를 검사한다.
  test('대조군: section 을 쓰는 자격증 집합이 고정돼 있고 공허하지 않다', () {
    final linkedByCert = <String, int>{};
    for (final cert in kContentIndex.keys) {
      for (final entry in contentFor(cert)) {
        final n = _questionsOf(entry)
            .where((q) => (q['section'] ?? '').toString().isNotEmpty)
            .length;
        linkedByCert[cert] = (linkedByCert[cert] ?? 0) + n;
      }
    }
    final linkedCerts =
        linkedByCert.entries.where((e) => e.value > 0).map((e) => e.key).toSet();
    expect(linkedCerts, {'CLF-C02', 'SAA-C03', 'DEA-C01', 'MLA-C01', 'AIF-C01', 'SCS-C03', 'AIP-C01'},
        reason: 'section 연결 현황이 바뀌었다(자격증별 수: $linkedByCert) — 의도한 변경이면 집합을 고친다');
    final total = linkedByCert.values.fold<int>(0, (a, b) => a + b);
    expect(total, greaterThan(1000),
        reason: '탐지가 먹지 않으면 Task별 단정이 전부 공허하게 통과한다');
  });

  for (final cert in kContentIndex.keys) {
    for (final entry in contentFor(cert)) {
      test('$cert ${entry.taskId}: 문항 section이 학습문서 {#id} 앵커에 존재', () {
        final questions = _questionsOf(entry);
        if (questions.isEmpty) return; // 문항 미저작 Task
        final anchors = _anchorsOf(entry);
        for (final q in questions) {
          final section = (q['section'] ?? '').toString();
          if (section.isEmpty) continue; // 미연결 허용(점진)
          expect(anchors.contains(section), isTrue,
              reason: '${q['id']} section "$section" 미존재 — '
                  '${entry.taskId} 앵커: ${(anchors.toList()..sort())}');
        }
      });
    }
  }

  // 2026-11-21 — SOA-C03 20편에 앵커가 하나도 없어 문항이 가리킬 절이 없었다(배치 0).
  group('SOA-C03 학습문서 앵커 규칙', () {
    test('대조군: 탐지기가 누락·중복·규칙 밖·잘못된 형식을 잡고 코드블록은 세지 않는다', () {
      const ok = '## 📖 핵심 개념 {#core-concepts}\n'
          '### 1) 가 {#a}\n'
          '```\n# 코드 주석\n### 코드 안 제목\n```\n'
          '## ✍️ 시험 포인트\n'
          '### 시험 포인트 하위\n'
          '## ⚠️ 흔한 함정 {#common-pitfalls}\n';
      expect(_anchorRuleViolations(ok), isEmpty);

      final missing = _anchorRuleViolations(ok.replaceFirst(' {#a}', ''));
      expect(missing, ['앵커 없음: 1) 가']);

      final dup = _anchorRuleViolations(ok.replaceFirst('{#a}', '{#core-concepts}'));
      expect(dup, ['중복 앵커: core-concepts']);

      final offRule = _anchorRuleViolations(
          ok.replaceFirst('## ✍️ 시험 포인트', '## ✍️ 시험 포인트 {#exam-points}'));
      expect(offRule, ['규칙 밖 앵커: ✍️ 시험 포인트 {#exam-points}']);

      // 파서의 앵커 형식(소문자·숫자·하이픈)을 벗어나면 앵커로 읽히지 않는다.
      final badForm = _anchorRuleViolations(ok.replaceFirst('{#a}', '{#Bad_Id}'));
      expect(badForm, ['앵커 없음: 1) 가 {#Bad_Id}']);
    });

    test('대조군: 대상 제목이 공허하지 않다', () {
      final entries = contentFor('SOA-C03');
      expect(entries, hasLength(20));
      var total = 0;
      for (final entry in entries) {
        final targets =
            _anchorTargets(parseStudyDoc(File(entry.mdAsset).readAsStringSync()).blocks);
        expect(targets.length, greaterThanOrEqualTo(8),
            reason: '${entry.taskId}: 핵심 개념 + 번호 절 6개 이상 + 흔한 함정');
        total += targets.length;
      }
      expect(total, greaterThanOrEqualTo(180));
    });

    for (final entry in contentFor('SOA-C03')) {
      test('${entry.taskId}: 핵심 개념·번호 절·흔한 함정에 고유 앵커', () {
        expect(_anchorRuleViolations(File(entry.mdAsset).readAsStringSync()), isEmpty);
      });
    }
  });

  // C 트랙 — section 을 다 채운 Task. 앵커 존재 단정(위)은 빈 section 을 통과시키므로 여기서
  // 「전 문항이 절을 가리킨다」를 따로 건다. `core-concepts` 는 번호 절 전체를 덮는 상위 제목이라
  // 거기로 보내면 문서 맨 위로 가는 것과 거의 같다 — 구체적인 절만 인정한다.
  group('section 완비 Task', () {
    const completeTaskIds = <String>{
      'saa-t1-1', 'saa-t1-2', 'saa-t1-3', 'saa-t1-4', 'saa-t1-5',
      'saa-t2-1', 'saa-t2-2', 'saa-t2-3', 'saa-t2-4', 'saa-t2-5',
    };
    final entries = [
      for (final cert in kContentIndex.keys)
        for (final entry in contentFor(cert))
          if (completeTaskIds.contains(entry.taskId)) entry,
    ];

    test('대조군: 선언한 Task 가 전부 등재돼 있고 문항이 있다', () {
      expect(entries.map((e) => e.taskId).toSet(), completeTaskIds);
      for (final entry in entries) {
        expect(_questionsOf(entry), isNotEmpty, reason: entry.taskId);
      }
    });

    for (final entry in entries) {
      test('${entry.taskId}: 전 문항이 구체적인 절을 가리킨다', () {
        for (final q in _questionsOf(entry)) {
          final section = (q['section'] ?? '').toString();
          expect(section, isNotEmpty, reason: '${q['id']}: section 없음');
          expect(section, isNot('core-concepts'),
              reason: '${q['id']}: 상위 제목이 아니라 구체적인 절을 가리켜야 한다');
        }
      });
    }
  });
}
