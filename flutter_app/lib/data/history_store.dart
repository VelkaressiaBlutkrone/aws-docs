import 'dart:convert';

import '../models/attempt_record.dart';
import 'local_kv.dart';

// 기존 소비자(import 'history_store.dart')가 KvBackend/MemoryBackend를 계속
// 보도록 re-export(하위 호환).
export 'local_kv.dart' show KvBackend, MemoryBackend, defaultBackend;

class HistoryStore {
  HistoryStore({KvBackend? backend}) : _b = backend ?? defaultBackend();

  final KvBackend _b;
  static const _key = 'awsdocs.history.v1';

  List<AttemptRecord> all() {
    final raw = _b.read(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => AttemptRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return []; // 손상 데이터는 무시
    }
  }

  void add(AttemptRecord r) {
    final list = all()..add(r);
    _b.write(_key, jsonEncode(list.map((e) => e.toJson()).toList()));
  }

  /// 해당 자격증 레코드만 제거하고 나머지는 보존(전 자격증 통합 단일 키).
  void clearCert(String certId) {
    final kept = all().where((r) => r.certId != certId).toList();
    _b.write(_key, jsonEncode(kept.map((e) => e.toJson()).toList()));
  }

  /// 모든 응시 이력 삭제(빈 값 = all()에서 빈 리스트).
  void clearAll() => _b.write(_key, '');
}
