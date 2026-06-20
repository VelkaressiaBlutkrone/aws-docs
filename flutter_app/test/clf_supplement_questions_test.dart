import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// CLF-C02 보강 문항 드래프트 구조 가드.
///
/// QuestionBank.fromJson은 verified:false 문항을 런타임 풀에서 제외하므로,
/// 이번 보강 초안(q16+)은 raw JSON을 직접 파싱해 스키마를 확인한다.
void main() {
  const taskIds = ['t3-1', 't2-3', 't3-7', 't2-2', 't3-3', 't3-8', 't3-5'];

  for (final taskId in taskIds) {
    group('clf-$taskId', () {
      final path = 'assets/content/clf/$taskId.questions.json';

      test('문항 파일이 존재한다', () {
        expect(File(path).existsSync(), isTrue, reason: '$path 가 없습니다.');
      });

      test('raw JSON 스키마 규칙을 만족한다', () {
        final file = File(path);
        if (!file.existsSync()) {
          fail('$path 없음(앞 테스트에서 보고됨)');
        }

        final map =
            json.decode(file.readAsStringSync()) as Map<String, dynamic>;
        expect(map['examGuideTaskId'], 'clf-$taskId');
        expect(map['certCode'], 'CLF-C02');

        final questions = (map['questions'] as List)
            .cast<Map<String, dynamic>>();
        final ids = <String>{};

        for (final q in questions) {
          final qid = (q['id'] ?? '').toString();
          expect(qid, isNotEmpty);
          expect(ids.add(qid), isTrue, reason: '중복 id: $qid');
          expect(
            (q['stem'] ?? '').toString(),
            isNotEmpty,
            reason: '$qid stem 비어있음',
          );
          expect(
            (q['explanation'] ?? '').toString(),
            isNotEmpty,
            reason: '$qid explanation 비어있음',
          );

          final options = (q['options'] as List);
          expect(options.length, 4, reason: '$qid options 4개 아님');

          final correct = (q['correct'] as num).toInt();
          expect(correct, inInclusiveRange(0, 3), reason: '$qid correct 범위 밖');

          final wrongExplanations = (q['wrongExplanations'] as Map);
          final keys = wrongExplanations.keys
              .map((k) => int.parse(k.toString()))
              .toSet();
          final expected = {0, 1, 2, 3}..remove(correct);
          expect(keys, expected, reason: '$qid wrongExplanations 키=비정답 인덱스 전부');

          final sources = (q['sources'] as List);
          expect(sources, isNotEmpty, reason: '$qid sources 비어있음');
          for (final source in sources.cast<Map<String, dynamic>>()) {
            expect(
              (source['title'] ?? '').toString(),
              isNotEmpty,
              reason: '$qid source title 비어있음',
            );
            expect(
              (source['url'] ?? '').toString(),
              startsWith('http'),
              reason: '$qid source url 형식 오류',
            );
          }

          if (q.containsKey('section')) {
            expect(
              (q['section'] ?? '').toString(),
              isNotEmpty,
              reason: '$qid section 비어있음',
            );
          }
        }
      });
    });
  }
}
