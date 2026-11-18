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

void main() {
  // ⚠️ SAA-C03(360문항)·SOA-C03(300문항)은 2026-11-18 실측으로 section 을 단 문항이 **0개**다 —
  // 그 두 자격증은 해설에서 학습문서 절로 가는 딥링크가 없다. 이 가드로 메울 일이 아니라
  // 콘텐츠 작업이므로 현재 집합을 고정한다. 누가 SAA·SOA 에 section 을 달기 시작하면 이 단정이
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
    expect(linkedCerts, {'CLF-C02', 'DEA-C01', 'MLA-C01', 'AIF-C01', 'SCS-C03', 'AIP-C01'},
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
}
