// 외부 URL을 새 탭으로 연다.
// 웹 빌드에서는 `package:web`(open_link_web.dart)을 사용하고,
// VM(테스트 등)에서는 no-op 스텁(open_link_stub.dart)을 사용한다 —
// `dart:js_interop`이 VM에 없어 공유 코드에서 직접 import하면 테스트가 깨지기 때문.
// 네이티브(Android·데스크톱)는 url_launcher 로 기본 브라우저를 연다(A5). 그 전에는
// 스텁이 no-op 이라 **Android 에서 칩을 눌러도 아무 일이 없었다.**
// ⚠️ js_interop 분기가 **먼저**여야 웹이 web 판을 고른다 — io 판이 웹 빌드에 들어가면
// url_launcher 의 플랫폼 코드가 끌려와 빌드가 깨진다.
export 'open_link_stub.dart'
    if (dart.library.js_interop) 'open_link_web.dart'
    if (dart.library.io) 'open_link_io.dart';
