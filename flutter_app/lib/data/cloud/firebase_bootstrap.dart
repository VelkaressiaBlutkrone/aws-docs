// flutter_app/lib/data/cloud/firebase_bootstrap.dart
import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options.dart';

/// firebase_options가 실제 설정(REPLACE_ME 아님)인가. 순수 — Firebase init 불필요.
///
/// **`web` 옵션을 직접 판독한다** — 플랫폼을 가리지 않는 게이트여야 하는데
/// `currentPlatform`은 등록하지 않은 플랫폼에서 UnsupportedError를 던지고, 테스트 VM은
/// 호스트 OS(windows)로 보고되기 때문이다. A3(2026-11-19)에서 android를 등록한 뒤에도
/// 이 선택은 유효하다 — android·web이 **같은 프로젝트**라 web 판독으로 충분하고,
/// VM 테스트가 그대로 돈다(가드: `firebase_android_options_test.dart`).
bool cloudConfigured() =>
    DefaultFirebaseOptions.web.projectId != 'REPLACE_ME';

/// 설정됐으면 Firebase init 후 true, 아니면 false(cloud off). 미설정 시 init 미호출.
Future<bool> initFirebaseIfConfigured() async {
  if (!cloudConfigured()) return false;
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform);
  return true;
}
