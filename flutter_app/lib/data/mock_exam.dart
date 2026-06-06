import '../models/question.dart';

/// 자격증 통합 모의고사용 순수 로직(샘플링·병합·복원). Flutter 무의존 → 단위 테스트 가능.

/// 도메인 번호 → 출제 문항 수. weightByDomain 비중에 비례해 n을 배분하되,
/// floor 후 잔여를 소수부가 큰 순(largest-remainder)으로 +1. 합 == n 보장.
Map<int, int> allocateByWeight(Map<int, int> weightByDomain, int n) {
  if (weightByDomain.isEmpty) return {};
  if (n <= 0) return {for (final d in weightByDomain.keys) d: 0};

  final totalWeight = weightByDomain.values.fold(0, (s, w) => s + w);
  if (totalWeight <= 0) {
    final domains = weightByDomain.keys.toList();
    final base = n ~/ domains.length;
    final alloc = {for (final d in domains) d: base};
    var rem = n - base * domains.length;
    for (var i = 0; i < domains.length && rem > 0; i++, rem--) {
      alloc[domains[i]] = alloc[domains[i]]! + 1;
    }
    return alloc;
  }

  final exact = <int, double>{};
  final alloc = <int, int>{};
  for (final e in weightByDomain.entries) {
    final v = n * e.value / totalWeight;
    exact[e.key] = v;
    alloc[e.key] = v.floor();
  }
  var assigned = alloc.values.fold(0, (s, v) => s + v);
  final byFraction = exact.keys.toList()
    ..sort((a, b) => (exact[b]! - exact[b]!.floorToDouble())
        .compareTo(exact[a]! - exact[a]!.floorToDouble()));
  for (var i = 0; assigned < n; i++, assigned++) {
    final d = byFraction[i % byFraction.length];
    alloc[d] = alloc[d]! + 1;
  }
  return alloc;
}

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
