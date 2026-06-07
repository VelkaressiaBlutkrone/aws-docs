import 'dart:math';

import '../models/question.dart';

/// 자격증 통합 모의고사용 순수 로직(샘플링·병합·복원). Flutter 무의존 → 단위 테스트 가능.

/// 키별 가중에 비례해 n을 배분(floor 후 largest-remainder로 +1). 합 == n 보장.
/// 키 타입 비의존(도메인 int·Task String 공용).
Map<K, int> allocateByWeight<K>(Map<K, int> weightByKey, int n) {
  if (weightByKey.isEmpty) return {};
  if (n <= 0) return {for (final k in weightByKey.keys) k: 0};

  final totalWeight = weightByKey.values.fold(0, (s, w) => s + w);
  if (totalWeight <= 0) {
    final keys = weightByKey.keys.toList();
    final base = n ~/ keys.length;
    final alloc = {for (final k in keys) k: base};
    var rem = n - base * keys.length;
    for (var i = 0; i < keys.length && rem > 0; i++, rem--) {
      alloc[keys[i]] = alloc[keys[i]]! + 1;
    }
    return alloc;
  }

  final exact = <K, double>{};
  final alloc = <K, int>{};
  for (final e in weightByKey.entries) {
    final v = n * e.value / totalWeight;
    exact[e.key] = v;
    alloc[e.key] = v.floor();
  }
  var assigned = alloc.values.fold(0, (s, v) => s + v);
  final byFraction = exact.keys.toList()
    ..sort((a, b) => (exact[b]! - exact[b]!.floorToDouble())
        .compareTo(exact[a]! - exact[a]!.floorToDouble()));
  for (var i = 0; assigned < n; i++, assigned++) {
    final k = byFraction[i % byFraction.length];
    alloc[k] = alloc[k]! + 1;
  }
  return alloc;
}

/// 키별 가중으로 n문항을 샘플링해 순서를 섞어 반환. [rng] 주입으로 결정적.
/// 특정 키 풀이 배분량보다 적으면 잔여 키 문항에서 보충(총 n 유지, 풀<n이면 최대).
List<Question> buildSampledExam<K>({
  required Map<K, List<Question>> poolByKey,
  required Map<K, int> weightByKey,
  required int n,
  required Random rng,
}) {
  final alloc = allocateByWeight<K>(weightByKey, n);
  final picked = <Question>[];
  final leftovers = <Question>[];

  final keys = <K>{...poolByKey.keys, ...alloc.keys}.toList();
  for (final k in keys) {
    final pool = [...?poolByKey[k]]..shuffle(rng);
    final want = alloc[k] ?? 0;
    final take = want < pool.length ? want : pool.length;
    picked.addAll(pool.take(take));
    leftovers.addAll(pool.skip(take));
  }

  if (picked.length < n && leftovers.isNotEmpty) {
    leftovers.shuffle(rng);
    picked.addAll(leftovers.take(n - picked.length));
  }

  picked.shuffle(rng);
  return picked;
}

/// 도메인 가중 통합 모의고사(호환 래퍼). 키=도메인 번호(int).
List<Question> buildMockExam({
  required Map<int, List<Question>> poolByDomain,
  required Map<int, int> weightByDomain,
  required int n,
  required Random rng,
}) =>
    buildSampledExam<int>(
        poolByKey: poolByDomain, weightByKey: weightByDomain, n: n, rng: rng);

/// 로드한 뱅크들을 도메인 번호 → 검증 문항 리스트로 묶는다.
Map<int, List<Question>> groupByDomain(List<QuestionBank> banks) {
  final map = <int, List<Question>>{};
  for (final b in banks) {
    (map[b.domain] ??= <Question>[]).addAll(b.questions);
  }
  return map;
}

/// 문항 ID → 문항. 복원 시 사용.
Map<String, Question> indexById(Iterable<Question> questions) =>
    {for (final q in questions) q.id: q};

/// 저장된 출제 ID를 현재 풀로 복원. 모든 ID가 존재할 때만 순서대로 반환, 아니면 null.
List<Question>? restoreOrdered(List<String> ids, Map<String, Question> byId) {
  if (ids.isEmpty) return null;
  final out = <Question>[];
  for (final id in ids) {
    final q = byId[id];
    if (q == null) return null; // 콘텐츠 개정/불일치 → 복원 거부
    out.add(q);
  }
  return out;
}
