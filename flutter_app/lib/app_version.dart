/// 앱 버전 — `pubspec.yaml` 의 `version:` 과 **같은 값**이어야 한다.
///
/// ⚠️ **버전을 올릴 때 여기와 `pubspec.yaml` 두 곳을 함께 고친다.**
/// `test/app_version_sync_test.dart` 가 둘이 어긋나면 레드가 된다.
///
/// 왜 상수인가 — 이 레포에는 `package_info_plus` 가 없고, 의존성을 더하면 웹
/// 번들 오염을 측정해야 한다(A4 의 `google_sign_in` 은 웹 구현이 등록 시점에
/// 3자 스크립트를 주입했다). 두 릴리스 명령도 `--build-name/--build-number` 를
/// 넘기지 않으므로, 빌드에서 버전을 읽는 경로가 없다.
///
/// 쓰이는 곳: 피드백 문서의 `app.version`(D2) — 어느 빌드에서 온 의견인지가
/// 테스트 기간의 가장 중요한 단서다.
const String kAppVersion = '1.0.0+1';
