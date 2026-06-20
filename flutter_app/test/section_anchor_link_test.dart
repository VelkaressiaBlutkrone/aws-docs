import 'dart:convert';
import 'dart:io';

import 'package:aws_docs/content/markdown_parser.dart';
import 'package:aws_docs/data/content_index.dart';
import 'package:aws_docs/models/study_content.dart';
import 'package:flutter_test/flutter_test.dart';

/// CLF 문항의 section(있으면)이 그 Task 학습문서의 실제 {#id} 앵커를 가리키는지 가드.
/// section 없는 문항은 통과(점진 — 미연결 허용). 오타·유실 시 실패.
void main() {
  for (final entry in contentFor('CLF-C02')) {
    test('${entry.taskId}: 문항 section이 학습문서 {#id} 앵커에 존재', () {
      final md = File(entry.mdAsset).readAsStringSync();
      final anchors = parseStudyDoc(md).blocks
          .whereType<MdHeading>()
          .map((h) => h.anchor)
          .whereType<String>()
          .toSet();
      final qjson = json.decode(File(entry.questionsAsset).readAsStringSync())
          as Map<String, dynamic>;
      final questions =
          (qjson['questions'] as List).cast<Map<String, dynamic>>();
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
