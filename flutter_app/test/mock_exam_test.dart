import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/mock_exam.dart';
import 'package:aws_docs/models/question.dart';

Question _q(String id, int domain) => Question(
      id: id,
      examGuideTaskId: 'clf-t$domain',
      stem: 's',
      options: const ['a', 'b', 'c', 'd'],
      correct: 0,
      explanation: 'e',
      wrongExplanations: const {},
      sources: const [],
      verified: true,
    );

QuestionBank _bank(int domain, List<String> ids) => QuestionBank(
      examGuideTaskId: 'clf-t$domain-x',
      taskTitle: 't',
      certCode: 'CLF-C02',
      domain: domain,
      questions: [for (final id in ids) _q(id, domain)],
    );

void main() {
  test('allocateByWeight: 합이 N, CLF 가중 65 → 16/19/22/8', () {
    final a = allocateByWeight({1: 24, 2: 30, 3: 34, 4: 12}, 65);
    expect(a.values.fold(0, (s, v) => s + v), 65);
    expect(a, {1: 16, 2: 19, 3: 22, 4: 8});
  });

  test('allocateByWeight: 비중 합 0이면 균등 배분, 합=N', () {
    final a = allocateByWeight({1: 0, 2: 0, 3: 0}, 7);
    expect(a.values.fold(0, (s, v) => s + v), 7);
  });

  test('allocateByWeight: N=0 → 전부 0', () {
    expect(allocateByWeight({1: 24, 2: 76}, 0), {1: 0, 2: 0});
  });

  test('groupByDomain / indexById', () {
    final banks = [_bank(1, ['a', 'b']), _bank(2, ['c'])];
    final pool = groupByDomain(banks);
    expect(pool[1]!.length, 2);
    expect(pool[2]!.length, 1);
    final byId = indexById([for (final b in banks) ...b.questions]);
    expect(byId.keys.toSet(), {'a', 'b', 'c'});
  });

  test('buildMockExam: 결정적(동일 seed) · 길이 N · 전부 풀 소속 · 중복 없음', () {
    final pool = {
      1: [for (var i = 0; i < 10; i++) _q('d1q$i', 1)],
      2: [for (var i = 0; i < 10; i++) _q('d2q$i', 2)],
    };
    const w = {1: 50, 2: 50};
    final a =
        buildMockExam(poolByDomain: pool, weightByDomain: w, n: 8, rng: Random(42));
    final b =
        buildMockExam(poolByDomain: pool, weightByDomain: w, n: 8, rng: Random(42));
    expect(a.map((q) => q.id).toList(), b.map((q) => q.id).toList());
    expect(a.length, 8);
    final allIds = {for (final d in pool.values) for (final q in d) q.id};
    expect(a.every((q) => allIds.contains(q.id)), isTrue);
    expect(a.map((q) => q.id).toSet().length, 8);
  });

  test('buildMockExam: 도메인 풀 부족 → 잔여 도메인에서 보충해 N 유지', () {
    final pool = {
      1: [_q('d1q0', 1)],
      2: [for (var i = 0; i < 10; i++) _q('d2q$i', 2)],
    };
    const w = {1: 50, 2: 50};
    final r =
        buildMockExam(poolByDomain: pool, weightByDomain: w, n: 8, rng: Random(1));
    expect(r.length, 8);
    expect(r.where((q) => q.id == 'd1q0').length, 1);
  });

  test('buildMockExam: 풀 총량 < N이면 가능한 최대', () {
    final pool = {
      1: [_q('a', 1), _q('b', 1)]
    };
    final r =
        buildMockExam(poolByDomain: pool, weightByDomain: {1: 100}, n: 8, rng: Random(1));
    expect(r.length, 2);
  });

  test('restoreOrdered: 모든 ID 존재 시 순서대로, 누락/빈목록 시 null', () {
    final byId = indexById([_q('a', 1), _q('b', 1), _q('c', 1)]);
    expect(restoreOrdered(['c', 'a'], byId)!.map((q) => q.id).toList(),
        ['c', 'a']);
    expect(restoreOrdered(['a', 'z'], byId), isNull);
    expect(restoreOrdered(const [], byId), isNull);
  });
}
