import 'dart:convert';

import '../models/study_plan.dart';
import 'local_kv.dart';

export 'local_kv.dart' show KvBackend, MemoryBackend, defaultBackend;

/// 자격증별 단일 학습 플랜을 영속한다. 손상 데이터는 빈/null(기존 store 관례).
class StudyPlanStore {
  StudyPlanStore({KvBackend? backend}) : _b = backend ?? defaultBackend();

  final KvBackend _b;
  static const _key = 'awsdocs.plan.v1';

  Map<String, dynamic> _read() {
    final raw = _b.read(_key);
    if (raw == null || raw.isEmpty) return {};
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  StudyPlan? planFor(String certCode) {
    final j = _read()[certCode];
    if (j is! Map<String, dynamic>) return null;
    try {
      return StudyPlan.fromJson(j);
    } catch (_) {
      return null;
    }
  }

  void save(StudyPlan plan) {
    final m = _read();
    m[plan.certCode] = plan.toJson();
    _b.write(_key, jsonEncode(m));
  }

  void clearCert(String certCode) {
    final m = _read()..remove(certCode);
    _b.write(_key, jsonEncode(m));
  }

  void clearAll() => _b.write(_key, '');
}
