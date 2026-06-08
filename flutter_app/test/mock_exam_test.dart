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

  test('buildSampledExam<String>: Task 키 — 합 N · 전부 풀 소속 · 결정적', () {
    final pool = {
      'clf-t2-1': [for (var i = 0; i < 10; i++) _q('t21q$i', 2)],
      'clf-t3-1': [for (var i = 0; i < 10; i++) _q('t31q$i', 3)],
    };
    const w = {'clf-t2-1': 70, 'clf-t3-1': 30};
    final a = buildSampledExam<String>(
        poolByKey: pool, weightByKey: w, n: 10, rng: Random(7));
    final b = buildSampledExam<String>(
        poolByKey: pool, weightByKey: w, n: 10, rng: Random(7));
    expect(a.map((q) => q.id).toList(), b.map((q) => q.id).toList());
    expect(a.length, 10);
    final allIds = {for (final t in pool.values) for (final q in t) q.id};
    expect(a.every((q) => allIds.contains(q.id)), isTrue);
    expect(a.map((q) => q.id).toSet().length, 10);
  });

  test('allocateByWeight<String>: 합이 N', () {
    final a = allocateByWeight<String>({'a': 70, 'b': 30}, 10);
    expect(a.values.fold(0, (s, v) => s + v), 10);
    expect(a['a']! > a['b']!, isTrue); // 가중 큰 쪽 더 많이
  });

  test('samplePool: n < 풀이면 n개·중복 없음·풀 소속·결정적', () {
    final pool = [for (var i = 0; i < 9; i++) _q('q$i', 1)];
    final a = samplePool(pool, 5, Random(7));
    final b = samplePool(pool, 5, Random(7));
    expect(a.length, 5);
    expect(a.map((q) => q.id).toSet().length, 5);
    expect(a.every((q) => pool.any((p) => p.id == q.id)), isTrue);
    expect(a.map((q) => q.id).toList(), b.map((q) => q.id).toList()); // 결정적
  });

  test('samplePool: 풀 ≤ n이면 전부 반환', () {
    final pool = [for (var i = 0; i < 4; i++) _q('q$i', 1)];
    final r = samplePool(pool, taskSampleCount, Random(1));
    expect(r.map((q) => q.id).toSet(), {'q0', 'q1', 'q2', 'q3'});
  });

  test('randomOptionOrders: 문항별 유효 순열 생성', () {
    final pool = [for (var i = 0; i < 6; i++) _q('q$i', 1)];
    final orders = randomOptionOrders(pool, Random(3));
    expect(orders.length, 6);
    for (final q in pool) {
      expect(orders[q.id]!.toSet(), {0, 1, 2, 3}); // 완전한 순열
    }
  });

  test('applyOptionOrders: 정답 텍스트 보존, 순서 없는 문항은 그대로', () {
    final pool = [_q('a', 1), _q('b', 1)];
    final shuffled = applyOptionOrders(pool, {
      'a': [3, 2, 1, 0],
    });
    expect(shuffled[0].correct, 3); // 원본 0번이 표시 3번으로
    expect(shuffled[0].options[3], pool[0].options[0]); // 정답 텍스트 보존
    expect(identical(shuffled[1], pool[1]), isTrue); // 순서 없음 → 원본
  });

  test('ordersCoverQuestions: 누락·길이 불일치 감지', () {
    final pool = [_q('a', 1), _q('b', 1)];
    final ok = randomOptionOrders(pool, Random(1));
    expect(ordersCoverQuestions(pool, ok), isTrue);
    expect(ordersCoverQuestions(pool, {'a': ok['a']!}), isFalse); // b 누락
    expect(
        ordersCoverQuestions(pool, {'a': ok['a']!, 'b': const [0, 1]}),
        isFalse); // 길이 불일치
    expect(ordersCoverQuestions(pool, const {}), isFalse); // 구버전 세션
  });

  test('분포 스모크: 셔플 후 정답 위치가 단일 인덱스에 95% 이상 몰리지 않는다', () {
    // 현재 데이터의 A-쏠림 재현: 전부 correct=0인 130문항
    final pool = [for (var i = 0; i < 130; i++) _q('q$i', 1)];
    final shuffled =
        applyOptionOrders(pool, randomOptionOrders(pool, Random(5)));
    final dist = <int, int>{};
    for (final q in shuffled) {
      dist[q.correct] = (dist[q.correct] ?? 0) + 1;
    }
    expect(dist.values.every((c) => c < 130 * 0.95), isTrue);
    expect(dist.keys.length, greaterThan(1)); // 한 위치 독점 아님
  });
}
