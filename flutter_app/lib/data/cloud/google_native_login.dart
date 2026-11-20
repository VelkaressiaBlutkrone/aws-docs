// flutter_app/lib/data/cloud/google_native_login.dart
import 'dart:async';

import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';

import '../../app_errors.dart';

/// Google 로그인에 넘기는 **웹 OAuth 클라이언트 ID**(`serverClientId`).
///
/// ⚠️ A3 결정대로 이 레포는 `google-services.json`과 Gradle 플러그인을 쓰지 않는다.
/// 공식 `google_sign_in_android` 문서가 그 경우를 명시한다 — json과 Gradle 등록을
/// 쓰면 Dart에서 식별자를 넘기지 않아도 되지만(단, json에 웹 OAuth 클라이언트 항목이
/// 있어야 한다), **쓰지 않으면 등록한 _웹_ 애플리케이션의 클라이언트 ID를
/// `serverClientId`로 넘겨야 한다.**
///
/// 값은 `firebase apps:sdkconfig ANDROID`의 `oauth_client` 중 `client_type: 3`
/// 항목이다. `firebase_options.dart`의 키와 같은 급의 **공개 식별자**이고 비밀이
/// 아니다(공식이 이 값을 커밋 대상 json에 담게 한다). 비밀은 키스토어와
/// `key.properties`이며 그 둘은 `.gitignore`에 있다.
///
/// 가드: `test/android_google_signin_test.dart`가 이 값이 웹 클라이언트 형식이고
/// `firebase_options`의 프로젝트 번호와 같은지 단정한다.
const String googleServerClientId =
    '169329324307-672g0tccg2hlgier6vm3jpimbbddrfnh.apps.googleusercontent.com';

/// `GoogleSignIn.instance.initialize`를 앱 수명 동안 **한 번만** 부르는 래퍼.
///
/// ⚠️ 공식 문서가 요구한다 — "Clients must call this method **exactly once**, and
/// wait for its future to complete, before calling any other methods on this
/// object. Calling other methods without waiting for this method to return, or
/// **calling this method more than once, will result in undefined behavior.**"
/// `initialize`는 플랫폼 인증 이벤트 스트림까지 구독하므로, 로그인 버튼을 두 번
/// 누르면 두 번 구독된다.
///
/// 실패는 캐시하지 않는다 — 캐시하면 한 번 실패한 기기는 앱을 다시 켤 때까지
/// 로그인할 수 없다. 진행 중인 호출은 공유하므로 **동시에 두 번 눌러도 한 번**이다.
class OnceInitializer {
  OnceInitializer(this._init);
  final Future<void> Function() _init;

  bool _done = false;
  Future<void>? _inflight;

  /// 초기화가 끝난 뒤 완료되는 Future. 이미 끝났으면 즉시 완료된다.
  Future<void> call() {
    if (_done) return Future<void>.value();
    return _inflight ??= _run();
  }

  Future<void> _run() async {
    try {
      await _init();
      _done = true;
    } finally {
      _inflight = null;
    }
  }
}

/// 앱 전체가 공유하는 google_sign_in 초기화. `GoogleSignInPlatform.instance`가 전역
/// 싱글턴이므로 초기화도 전역으로 한 번이어야 한다(서비스 인스턴스가 여러 개
/// 만들어져도). 최상위 `final`은 **지연 초기화**라 이 선언 자체는 플러그인을
/// 부르지 않는다 — VM 테스트에서 안전하다.
final OnceInitializer initGoogleSignIn = OnceInitializer(() =>
    GoogleSignInPlatform.instance
        .init(const InitParameters(serverClientId: googleServerClientId)));

/// 네이티브 Google 로그인의 **순서와 실패 처리**.
///
/// 플러그인·Firebase 호출은 VM에 플랫폼 구현이 없어 돌지 않으므로 주입해 받는다 —
/// 그래야 "초기화가 먼저인가", "idToken이 없을 때 무엇을 하는가", "취소를 실패로
/// 보는가"를 테스트로 고정할 수 있다.
///
/// 돌려주는 값은 **로그인이 일어났는가**다. 사용자가 취소하면 `false`이고 예외를
/// 던지지 않는다(취소는 오류가 아니다). 그 밖의 실패는 **전파한다** — 조용히 삼키면
/// 동기가 꺼진 채 화면이 아무 말도 하지 않는다.
Future<bool> runNativeGoogleLogin({
  required Future<void> Function() ensureInitialized,
  required Future<String?> Function() authenticate,
  required Future<void> Function(String idToken) signInWithIdToken,
}) async {
  await ensureInitialized();

  String? idToken;
  try {
    idToken = await authenticate();
  } on GoogleSignInException catch (e) {
    if (e.code == GoogleSignInExceptionCode.canceled) {
      appLog('Google 로그인 취소');
      return false;
    }
    rethrow;
  }

  // ⚠️ `GoogleSignInAuthentication.idToken`은 String?다. 없는데 조용히 끝내면
  // 화면은 "동기 켜짐"으로 보이는데 Firebase 자격 증명이 없는 상태가 된다.
  if (idToken == null) {
    throw StateError('Google 로그인: idToken이 없어 Firebase 자격 증명을 만들 수 없다');
  }

  await signInWithIdToken(idToken);
  return true;
}
