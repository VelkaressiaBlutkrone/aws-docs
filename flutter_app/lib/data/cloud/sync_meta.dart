import 'dart:convert';

import '../local_kv.dart';

/// 동기 사이드카(v2) — 로컬에만 있는 동기 부기. 지금은 삭제 표식을 담고,
/// PR2에서 마지막 동기 스냅샷(base)이 더해진다. 옛 v1 사이드카는 레거시 LWW
/// 경로가 아직 쓰므로 건드리지 않는다(PR3에서 그 경로와 함께 정리).
class SyncMeta {
  SyncMeta(this._b);
  final KvBackend _b;

  static const key = 'awsdocs.sync.v2';

  /// 전체 초기화(resetAll)를 가리키는 표식 키.
  static const allCerts = '*';

  Map<String, dynamic> _read() {
    final raw = _b.read(key);
    if (raw == null || raw.isEmpty) return {};
    try {
      final m = jsonDecode(raw);
      return m is Map<String, dynamic> ? m : {};
    } catch (_) {
      return {}; // 손상 사이드카는 빈 상태로(파생 데이터라 복구 불필요)
    }
  }

  void _write(Map<String, dynamic> m) {
    final next = jsonEncode(m);
    if (_b.read(key) != next) _b.write(key, next);
  }

  /// 자격증별 삭제 표식(UTC ms). `*`는 전체 초기화.
  Map<String, int> get resetAt {
    final m = _read()['resetAt'];
    if (m is! Map) return {};
    return {
      for (final e in m.entries)
        if (e.value is num) e.key.toString(): (e.value as num).toInt(),
    };
  }

  set resetAt(Map<String, int> v) {
    final m = _read();
    m['resetAt'] = v;
    _write(m);
  }

  /// 일정별 삭제 표식(planId → UTC ms). 지운 일정이 다른 기기에서 되살아나지 않게.
  Map<String, int> get deletedPlans => _intMap(_read()['deletedPlans']);

  set deletedPlans(Map<String, int> v) {
    final m = _read();
    m['deletedPlans'] = v;
    _write(m);
  }

  /// 레거시 `checks` 컬렉션 정리 완료 여부(1회성).
  bool get checksPurged => _read()['checksPurged'] == true;

  set checksPurged(bool v) {
    final m = _read();
    m['checksPurged'] = v;
    _write(m);
  }

  /// 표식 기록. 같은 키는 늦은 시각을 남긴다.
  void markReset(String certOrAll, int ms) {
    final next = {...resetAt};
    if (ms > (next[certOrAll] ?? 0)) next[certOrAll] = ms;
    resetAt = next;
  }

  /// 이 자격증에 적용되는 유효 삭제 시각.
  int effectiveResetAt(String certCode) =>
      mergedEffectiveResetAt(resetAt, certCode);

  /// 엔티티 종류(`plans`·`progress`)별 동기 부기.
  EntityMeta entity(String kind) {
    final m = _read()[kind];
    if (m is! Map) return const EntityMeta(base: {}, updatedAt: {}, dirtyAt: {});
    return EntityMeta(
      base: {
        for (final e in ((m['base'] as Map?) ?? const {}).entries)
          if (e.value is Map<String, dynamic>)
            e.key.toString(): e.value as Map<String, dynamic>,
      },
      updatedAt: _intMap(m['updatedAt']),
      dirtyAt: _intMap(m['dirtyAt']),
    );
  }

  void setEntity(String kind, EntityMeta m) {
    final all = _read();
    all[kind] = {
      'base': m.base,
      'updatedAt': m.updatedAt,
      'dirtyAt': m.dirtyAt,
    };
    _write(all);
  }

  static Map<String, int> _intMap(Object? v) {
    if (v is! Map) return {};
    return {
      for (final e in v.entries)
        if (e.value is num) e.key.toString(): (e.value as num).toInt(),
    };
  }
}

/// 한 엔티티 종류의 동기 부기. [base]는 마지막 동기 시점의 문서 내용,
/// [updatedAt]은 그때의 클라우드 `updatedAtMs`, [dirtyAt]은 로컬 변경을 처음 감지한 시각.
class EntityMeta {
  const EntityMeta({
    required this.base,
    required this.updatedAt,
    required this.dirtyAt,
  });

  final Map<String, Map<String, dynamic>> base;
  final Map<String, int> updatedAt;
  final Map<String, int> dirtyAt;
}

/// 자격증 표식과 전체 표식 중 늦은 쪽.
int mergedEffectiveResetAt(Map<String, int> resetAt, String certCode) {
  final own = resetAt[certCode] ?? 0;
  final all = resetAt[SyncMeta.allCerts] ?? 0;
  return own > all ? own : all;
}

/// 두 표식 맵을 필드별 늦은 시각으로 병합한다(기기 간 동시 초기화 안전).
Map<String, int> mergeResetMarks(Map<String, int> a, Map<String, int> b) {
  final out = {...a};
  for (final e in b.entries) {
    if (e.value > (out[e.key] ?? 0)) out[e.key] = e.value;
  }
  return out;
}
