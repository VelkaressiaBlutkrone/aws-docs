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
    // fromJson은 verified 문항만 남긴다 — 콘텐츠가 늘어도 깨지지 않게 raw의 verified 수와 대조.
    final rawVerified = (map['questions'] as List)
        .where((q) => (q as Map)['verified'] == true)
        .length;
    expect(bank.questions.length, rawVerified);
    expect(rawVerified, greaterThanOrEqualTo(12)); // 밀도 목표(Task당 ≥12 verified)
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

  group('withOptionOrder', () {
    const q = Question(
      id: 'q1',
      examGuideTaskId: 't',
      stem: 's',
      options: ['A', 'B', 'C', 'D'],
      correct: 0,
      explanation: 'e',
      wrongExplanations: {1: 'w1', 3: 'w3'},
      sources: [],
      verified: true,
    );

    test('옵션·correct·wrongExplanations를 함께 재매핑한다', () {
      // order = 표시 순서대로 나열한 원본 인덱스: 표시0=원본2, 표시1=원본0 …
      final r = q.withOptionOrder([2, 0, 3, 1]);
      expect(r.options, ['C', 'A', 'D', 'B']);
      expect(r.correct, 1); // 원본 0번(A)이 표시 1번으로
      expect(r.options[r.correct], 'A'); // 정답 텍스트 보존
      expect(r.wrongExplanations, {3: 'w1', 2: 'w3'});
      expect(r.id, 'q1'); // 메타 보존
    });

    test('원본은 불변이다', () {
      q.withOptionOrder([3, 2, 1, 0]);
      expect(q.options, ['A', 'B', 'C', 'D']);
      expect(q.correct, 0);
      expect(q.wrongExplanations, {1: 'w1', 3: 'w3'});
    });

    test('잘못된 순열이면 원본을 그대로 반환한다(방어)', () {
      expect(identical(q.withOptionOrder([0, 0, 1, 2]), q), isTrue); // 중복
      expect(identical(q.withOptionOrder([0, 1, 2]), q), isTrue); // 길이
      expect(identical(q.withOptionOrder([0, 1, 2, 4]), q), isTrue); // 범위 밖
    });

    test('항등 순열은 동일 내용을 반환한다', () {
      final r = q.withOptionOrder([0, 1, 2, 3]);
      expect(r.options, q.options);
      expect(r.correct, q.correct);
      expect(r.wrongExplanations, q.wrongExplanations);
    });
  });
}
