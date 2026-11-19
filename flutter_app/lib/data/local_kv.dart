import 'package:flutter/foundation.dart' show kIsWeb;

// 조건부 import: 웹은 실제 localStorage, VM/테스트는 stub.
import 'web_backend_stub.dart'
    if (dart.library.js_interop) 'web_backend_web.dart';
// 조건부 import: 네이티브는 파일 백엔드(A2), 웹은 no-op — `dart:io` 가 웹 빌드를 깬다.
import 'persistent_backend_stub.dart'
    if (dart.library.io) 'persistent_backend_io.dart';

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

/// 앱 시작 시 한 번 — 네이티브 영속 저장소를 연다. 웹에서는 아무것도 하지 않는다
/// (웹의 영속화는 localStorage 라 열 것이 없다). 실패는 호출부가 degrade 한다.
Future<void> initLocalStorage() => initPersistentBackend();

/// 기본 백엔드: 웹은 localStorage([WebBackend]), 네이티브는 [initLocalStorage] 로 열어 둔
/// 파일 백엔드, 그 밖(초기화 전 VM/테스트)은 메모리.
///
/// ⚠️ 초기화 전에는 **호출마다 새 [MemoryBackend]** 다. 여러 페이지의 주입구 주석이 그
/// 성질에 기대고 있어(「VM의 defaultBackend()는 호출마다 별도 MemoryBackend라 주입구
/// 없이는 심은 것을 페이지가 볼 수 없다」) 무조건 싱글턴으로 바꾸면 테스트 간 상태가 샌다.
KvBackend defaultBackend() {
  if (kIsWeb) return WebBackend();
  return persistentBackendOrNull() ?? MemoryBackend();
}
