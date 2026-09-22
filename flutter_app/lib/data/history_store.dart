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

  /// 손상 원문 보존 키 — 다시 쓰기 전 해석에서 버려진 부분이 있으면 원문을 여기 남긴다.
  static const _corruptKey = '$_key.corrupt';

  /// 레코드 단위로 해석한다: 깨진 레코드만 건너뛴다(lossless=false). 최상위가
  /// JSON 배열이 아니면 전부 건너뛴다.
  static ({List<AttemptRecord> records, bool lossless}) _parse(String? raw) {
    if (raw == null || raw.isEmpty) return (records: [], lossless: true);
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } catch (_) {
      return (records: [], lossless: false);
    }
    if (decoded is! List) return (records: [], lossless: false);
    final records = <AttemptRecord>[];
    var lossless = true;
    for (final e in decoded) {
      if (e is! Map<String, dynamic>) {
        lossless = false;
        continue;
      }
      try {
        records.add(AttemptRecord.fromJson(e));
      } catch (_) {
        lossless = false;
      }
    }
    return (records: records, lossless: lossless);
  }

  List<AttemptRecord> all() => _parse(_b.read(_key)).records;

  /// 다시 쓰기용 로드. 해석에서 버려진 부분이 있으면 원문을 보존 키에 남긴다 —
  /// 손상 레코드 하나 때문에 나머지 이력이 영구히 덮어써지지 않게. 보존은
  /// best-effort: 보존본 쓰기가 실패해도(쿼터 근접) 이후 본 쓰기는 막지 않는다.
  List<AttemptRecord> _loadForRewrite() {
    final raw = _b.read(_key);
    final p = _parse(raw);
    if (!p.lossless) {
      try {
        _b.write(_corruptKey, raw!);
      } catch (_) {/* 보존 실패는 무시 — 새 응시 저장이 우선 */}
    }
    return p.records;
  }

  void add(AttemptRecord r) {
    final list = _loadForRewrite()..add(r);
    _b.write(_key, jsonEncode(list.map((e) => e.toJson()).toList()));
  }

  /// 해당 자격증 레코드만 제거하고 나머지는 보존(전 자격증 통합 단일 키).
  void clearCert(String certId) {
    final kept = _loadForRewrite().where((r) => r.certId != certId).toList();
    _b.write(_key, jsonEncode(kept.map((e) => e.toJson()).toList()));
  }

  /// 모든 응시 이력 삭제(빈 값 = all()에서 빈 리스트). 전체 초기화이므로 손상
  /// 보존본도 함께 지운다.
  void clearAll() {
    _b.write(_key, '');
    if ((_b.read(_corruptKey) ?? '').isNotEmpty) _b.write(_corruptKey, '');
  }
}
