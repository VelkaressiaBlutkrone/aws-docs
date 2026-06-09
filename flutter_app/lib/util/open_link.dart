// 외부 URL을 새 탭으로 연다.
// 웹 빌드에서는 `package:web`(open_link_web.dart)을 사용하고,
// VM(테스트 등)에서는 no-op 스텁(open_link_stub.dart)을 사용한다 —
// `dart:js_interop`이 VM에 없어 공유 코드에서 직접 import하면 테스트가 깨지기 때문.
export 'open_link_stub.dart' if (dart.library.js_interop) 'open_link_web.dart';
