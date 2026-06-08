import 'package:flutter/foundation.dart' show kIsWeb;

// 조건부 import: 웹은 실제 localStorage, VM/테스트는 stub.
import 'web_backend_stub.dart'
    if (dart.library.js_interop) 'web_backend_web.dart';

/// 키-값 백엔드(이력·시험 세션 공유). 테스트는 [MemoryBackend] 주입.
abstract interface class KvBackend {
  String? read(String key);
  void write(String key, String value);

  /// 현재 저장된 모든 키. 접두사 기반 일괄 삭제(전체 초기화)에 쓴다.
  Iterable<String> keys();
}

class MemoryBackend implements KvBackend {
  final _m = <String, String>{};
  @override
  String? read(String key) => _m[key];
  @override
  void write(String key, String value) => _m[key] = value;
  @override
  Iterable<String> keys() => _m.keys.toList();
}

/// 기본 백엔드: 웹은 localStorage([WebBackend]), 그 외(VM/테스트)는 메모리.
KvBackend defaultBackend() => kIsWeb ? WebBackend() : MemoryBackend();
