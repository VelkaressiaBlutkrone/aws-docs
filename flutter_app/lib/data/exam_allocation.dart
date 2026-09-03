/// 키별 가중에 비례해 [n]을 배분한다.
///
/// floor 후 largest-remainder로 남은 몫을 +1 하며, 합 == [n]을 보장한다.
/// 키 타입 비의존(도메인 int·Task String 공용). remainder 동률은 선언 순서로
/// 결정해 테스트와 readiness 정책이 흔들리지 않게 한다.
Map<K, int> allocateByWeight<K>(Map<K, int> weightByKey, int n) {
  if (weightByKey.isEmpty) return {};
  if (n <= 0) return {for (final k in weightByKey.keys) k: 0};

  final entries = weightByKey.entries.toList();
  final indexByKey = <K, int>{
    for (var i = 0; i < entries.length; i++) entries[i].key: i,
  };
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
  for (final e in entries) {
    final v = n * e.value / totalWeight;
    exact[e.key] = v;
    alloc[e.key] = v.floor();
  }

  var assigned = alloc.values.fold(0, (s, v) => s + v);
  final byFraction = exact.keys.toList()
    ..sort((a, b) {
      final fa = exact[a]! - exact[a]!.floorToDouble();
      final fb = exact[b]! - exact[b]!.floorToDouble();
      final byRemainder = fb.compareTo(fa);
      if (byRemainder != 0) return byRemainder;
      return indexByKey[a]!.compareTo(indexByKey[b]!);
    });
  for (var i = 0; assigned < n; i++, assigned++) {
    final k = byFraction[i % byFraction.length];
    alloc[k] = alloc[k]! + 1;
  }
  return alloc;
}
