import 'dart:convert';

import 'local_kv.dart';

export 'local_kv.dart' show KvBackend, MemoryBackend, defaultBackend;

/// 플랜 항목의 수동 완료 오버라이드. itemId -> bool. 키 없으면 자동 감지로.
class PlanCheckStore {
  PlanCheckStore({KvBackend? backend}) : _b = backend ?? defaultBackend();

  final KvBackend _b;
  static const _key = 'awsdocs.plan.checks.v1';

  Map<String, dynamic> _read() {
    final raw = _b.read(_key);
    if (raw == null || raw.isEmpty) return {};
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  /// 자격증의 itemId -> 수동값(true/false). 오버라이드 없으면 키 없음.
  Map<String, bool> overrides(String certCode) {
    final cm = _read()[certCode];
    if (cm is! Map) return {};
    return {
      for (final e in cm.entries)
        if (e.value is bool) e.key.toString(): e.value as bool,
    };
  }

  /// [value]=null이면 오버라이드 해제(자동 감지로 복귀).
  void set(String certCode, String itemId, bool? value) {
    final m = _read();
    final cm = (m[certCode] is Map)
        ? Map<String, dynamic>.from(m[certCode] as Map)
        : <String, dynamic>{};
    if (value == null) {
      cm.remove(itemId);
    } else {
      cm[itemId] = value;
    }
    if (cm.isEmpty) {
      m.remove(certCode);
    } else {
      m[certCode] = cm;
    }
    _b.write(_key, jsonEncode(m));
  }

  void clearCert(String certCode) {
    final m = _read()..remove(certCode);
    _b.write(_key, jsonEncode(m));
  }

  void clearAll() => _b.write(_key, '');
}
