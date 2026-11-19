import 'local_kv.dart';

/// 웹 컴파일용 no-op — `persistent_backend_io.dart` 는 `dart:io` 를 쓰므로 웹 빌드에
/// 들어가면 컴파일이 깨진다. 웹의 영속화는 `WebBackend`(localStorage)가 맡는다.
KvBackend? persistentBackendOrNull() => null;

Future<void> initPersistentBackend() async {}
