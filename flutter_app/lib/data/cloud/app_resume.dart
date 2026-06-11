// 앱 복귀 신호. 웹은 visibilitychange(→ visible)를 방출, VM/테스트는 빈 스트림.
// dart:js_interop이 VM에 없어 공유 코드에서 직접 import하면 테스트가 깨지므로 분기.
export 'app_resume_stub.dart' if (dart.library.js_interop) 'app_resume_web.dart';
