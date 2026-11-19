// 앱 복귀 신호. 웹은 visibilitychange(→ visible)를 방출, VM/테스트는 빈 스트림.
// dart:js_interop이 VM에 없어 공유 코드에서 직접 import하면 테스트가 깨지므로 분기.
// 네이티브는 `AppLifecycleListener` 로 resumed 를 잡는다(A5, 의존성 0). 그 전에는
// 스텁이 빈 스트림이라 **Android 에서 복귀 시 동기가 돌지 않았다.**
// ⚠️ js_interop 분기가 **먼저**여야 웹이 web 판(visibilitychange)을 고른다.
export 'app_resume_stub.dart'
    if (dart.library.js_interop) 'app_resume_web.dart'
    if (dart.library.io) 'app_resume_io.dart';
