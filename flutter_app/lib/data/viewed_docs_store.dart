import 'dart:convert';

import 'local_kv.dart';

// 소비자가 MemoryBackend/KvBackend를 함께 보도록 re-export(HistoryStore 선례).
export 'local_kv.dart' show KvBackend, MemoryBackend, defaultBackend;

/// 열람한 학습문서 Task를 자격증별로 영속한다(방문 = 열람).
/// 값은 `{taskId: 열람시각(UTC ms)}`이며, 레거시 배열 형태도 읽는다(시각 0).
/// 멀티탭은 last-write-wins. 손상 데이터는 빈 결과.
class ViewedDocsStore {
  ViewedDocsStore({KvBackend? backend, int Function()? nowMs})
      : _b = backend ?? defaultBackend(),
        _now = nowMs ?? (() => DateTime.now().toUtc().millisecondsSinceEpoch);

  final KvBackend _b;
  final int Function() _now;
  static const _key = 'awsdocs.viewed.v1';

  /// 자격증 → {taskId: 열람시각}. 배열 형태(레거시)는 시각 0으로 해석한다.
  Map<String, Map<String, int>> readAll() {
    final raw = _b.read(_key);
    if (raw == null || raw.isEmpty) return {};
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      final out = <String, Map<String, int>>{};
      for (final e in m.entries) {
        final v = e.value;
        if (v is List) {
          out[e.key] = {for (final x in v) x.toString(): 0};
        } else if (v is Map) {
          out[e.key] = {
            for (final t in v.entries)
              if (t.value is num) t.key.toString(): (t.value as num).toInt(),
          };
        }
      }
      return out;
    } catch (_) {
      return {}; // 손상 데이터 무시
    }
  }

  void writeAll(Map<String, Map<String, int>> m) =>
      _b.write(_key, jsonEncode(m));

  /// 해당 자격증에서 열람한 Task ID 집합.
  Set<String> viewed(String certId) => readAll()[certId]?.keys.toSet() ?? {};

  /// 방문 기록(이미 있으면 시각을 갱신하지 않는다 — 첫 열람 시각 보존).
  void markViewed(String certId, String taskId) {
    final m = readAll();
    final cert = m[certId] ?? <String, int>{};
    if (cert.containsKey(taskId)) return;
    m[certId] = {...cert, taskId: _now()};
    writeAll(m);
  }

  /// 해당 자격증 열람 기록만 제거.
  void clearCert(String certId) {
    final m = readAll()..remove(certId);
    writeAll(m);
  }

  /// 모든 열람 기록 삭제.
  void clearAll() => _b.write(_key, '');
}
