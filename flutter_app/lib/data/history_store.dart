import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

// Conditional import: web platform gets real localStorage; VM/test gets stub.
import 'web_backend_stub.dart'
    if (dart.library.js_interop) 'web_backend_web.dart';

import '../models/attempt_record.dart';

/// 키-값 백엔드(테스트는 MemoryBackend 주입).
abstract interface class HistoryBackend {
  String? read(String key);
  void write(String key, String value);
}

class MemoryBackend implements HistoryBackend {
  final _m = <String, String>{};
  @override
  String? read(String key) => _m[key];
  @override
  void write(String key, String value) => _m[key] = value;
}

class HistoryStore {
  HistoryStore({HistoryBackend? backend})
      : _b = backend ?? (kIsWeb ? WebBackend() : MemoryBackend());

  final HistoryBackend _b;
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
}
