import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/models/question.dart';

void main() {
  final raw = File('assets/content/clf/t2-1.questions.json').readAsStringSync();
  final map = json.decode(raw) as Map<String, dynamic>;

  test('QuestionBank를 파싱하고 검증 문항만 남긴다', () {
    final bank = QuestionBank.fromJson(map);
    expect(bank.examGuideTaskId, 'clf-t2-1');
    expect(bank.questions.length, 9);
    for (final q in bank.questions) {
      expect(q.verified, isTrue);
      expect(q.correct, inInclusiveRange(0, q.options.length - 1));
      expect(q.options.length, 4);
      expect(q.sources, isNotEmpty);
      // 오답해설 키는 정답이 아닌 인덱스여야 한다
      for (final k in q.wrongExplanations.keys) {
        expect(k, isNot(q.correct));
        expect(k, inInclusiveRange(0, q.options.length - 1));
      }
    }
  });

  test('verified=false 문항은 제외된다(런타임 게이트)', () {
    final m = {
      'examGuideTaskId': 't',
      'questions': [
        {'id': 'a', 'options': ['x', 'y'], 'correct': 0, 'verified': true},
        {'id': 'b', 'options': ['x', 'y'], 'correct': 0, 'verified': false},
      ],
    };
    final bank = QuestionBank.fromJson(m);
    expect(bank.questions.map((q) => q.id), ['a']);
  });
}
