import 'dart:convert';

import 'local_kv.dart';

// 소비자가 MemoryBackend/KvBackend를 함께 보도록 re-export(HistoryStore 선례).
export 'local_kv.dart' show KvBackend, MemoryBackend, defaultBackend;

/// 열람한 학습문서 Task 집합을 자격증별로 영속한다(방문 = 열람).
/// 멀티탭은 last-write-wins. 손상 데이터는 빈 결과.
class ViewedDocsStore {
  ViewedDocsStore({KvBackend? backend}) : _b = backend ?? defaultBackend();

  final KvBackend _b;
  static const _key = 'awsdocs.viewed.v1';

  Map<String, List<String>> _read() {
    final raw = _b.read(_key);
    if (raw == null || raw.isEmpty) return {};
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return {
        for (final e in m.entries)
          e.key: (e.value as List).map((x) => x as String).toList(),
      };
    } catch (_) {
      return {}; // 손상 데이터 무시
    }
  }

  /// 해당 자격증에서 열람한 Task ID 집합.
  Set<String> viewed(String certId) => (_read()[certId] ?? const []).toSet();

  /// 방문 기록(이미 있으면 무변경).
  void markViewed(String certId, String taskId) {
    final m = _read();
    final list = m[certId] ?? <String>[];
    if (list.contains(taskId)) return;
    m[certId] = [...list, taskId];
    _b.write(_key, jsonEncode(m));
  }

  /// 해당 자격증 열람 기록만 제거.
  void clearCert(String certId) {
    final m = _read()..remove(certId);
    _b.write(_key, jsonEncode(m));
  }

  /// 모든 열람 기록 삭제.
  void clearAll() => _b.write(_key, '');
}
