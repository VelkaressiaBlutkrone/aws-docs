// flutter_app/lib/data/cloud/firebase_bootstrap.dart
import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options.dart';

/// firebase_options가 실제 설정(REPLACE_ME 아님)인가. 순수 — Firebase init 불필요.
/// 웹 전용 앱이라 `web` 옵션을 직접 판독한다 — `currentPlatform`은 오프-웹(테스트 VM)에서
/// UnsupportedError를 던지므로 게이트가 호출 불가가 된다.
bool cloudConfigured() =>
    DefaultFirebaseOptions.web.projectId != 'REPLACE_ME';

/// 설정됐으면 Firebase init 후 true, 아니면 false(cloud off). 미설정 시 init 미호출.
Future<bool> initFirebaseIfConfigured() async {
  if (!cloudConfigured()) return false;
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform);
  return true;
}
