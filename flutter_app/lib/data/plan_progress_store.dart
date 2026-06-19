import 'dart:convert';

import 'local_kv.dart';

export 'local_kv.dart' show KvBackend, MemoryBackend, defaultBackend;

/// 일정별(planId) 완료 itemId 집합을 영속한다. 일정 삭제 시 해당 planId만 비워,
/// 전역 열람·응시 이력과 독립적으로 일정 진행을 초기화한다(멀티 일정 모델).
class PlanProgressStore {
  PlanProgressStore({KvBackend? backend}) : _b = backend ?? defaultBackend();

  final KvBackend _b;
  static const _key = 'awsdocs.plan.progress.v1';

  Map<String, dynamic> _read() {
    final raw = _b.read(_key);
    if (raw == null || raw.isEmpty) return {};
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  /// 해당 일정의 완료 itemId 집합(없으면 빈 집합).
  Set<String> donePlan(String planId) {
    final l = _read()[planId];
    if (l is! List) return {};
    return {for (final x in l) x.toString()};
  }

  /// 항목 완료 토글. done=false면 집합에서 제거.
  void setDone(String planId, String itemId, bool done) {
    final m = _read();
    final set = donePlan(planId);
    if (done) {
      set.add(itemId);
    } else {
      set.remove(itemId);
    }
    if (set.isEmpty) {
      m.remove(planId);
    } else {
      m[planId] = set.toList();
    }
    _b.write(_key, jsonEncode(m));
  }

  /// 한 일정의 진행만 초기화(다른 일정 보존).
  void clearPlan(String planId) {
    final m = _read()..remove(planId);
    _b.write(_key, jsonEncode(m));
  }

  void clearAll() => _b.write(_key, '');
}
