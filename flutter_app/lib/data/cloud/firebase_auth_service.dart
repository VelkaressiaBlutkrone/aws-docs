// flutter_app/lib/data/cloud/firebase_auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';

import '../../app_errors.dart';
import 'auth_service.dart';
import 'auth_user.dart';
import 'google_native_login.dart';

/// AuthService의 Firebase 구현.
///
/// ⚠️ **로그인 경로가 플랫폼마다 다르다.** 웹은 `signInWithPopup`(원래 경로),
/// 네이티브는 `google_sign_in`으로 받은 idToken으로 credential을 만든다(A4).
/// `signInWithPopup`은 웹 전용이라 **안드로이드에서는 로그인이 되지 않았다**.
/// firebase_auth 6.7.1의 `signInWithProvider`는 Apple·Facebook 같은 generic OAuth
/// 공급자용이고 공식 문서가 Google 경로로는 적지 않는다.
///
/// 분기를 `GoogleSignIn.instance.supportsAuthenticate()`로 하지 않는다 — 공식 문서가
/// `initialize`를 **다른 메서드보다 먼저** 부르라고 요구하므로 그 질의부터 초기화 뒤여야
/// 하고, 웹에서 초기화하려면 쓰지도 않을 웹 clientId 설정이 필요해진다. 웹은 이 패키지를
/// 아예 쓰지 않는 쪽이 맞다(웹은 `supportsAuthenticate()`가 false다 — SDK가 렌더한
/// 버튼만 로그인을 시작할 수 있어 앱이 만든 버튼으로는 `authenticate()`를 쓸 수 없다).
class FirebaseAuthService implements AuthService {
  FirebaseAuthService([FirebaseAuth? auth])
      : _auth = auth ?? FirebaseAuth.instance;
  final FirebaseAuth _auth;

  AuthUser? _map(User? u) =>
      u == null ? null : AuthUser(uid: u.uid, email: u.email ?? '');

  @override
  AuthUser? get current => _map(_auth.currentUser);

  @override
  Stream<AuthUser?> authChanges() => _auth.authStateChanges().map(_map);

  @override
  Future<void> signInWithGoogle() async {
    if (kIsWeb) {
      await _auth.signInWithPopup(GoogleAuthProvider());
      return;
    }
    await runNativeGoogleLogin(
      ensureInitialized: initGoogleSignIn.call,
      authenticate: () async => (await GoogleSignInPlatform.instance
              .authenticate(const AuthenticateParameters()))
          .authenticationTokens
          .idToken,
      signInWithIdToken: (idToken) => _auth.signInWithCredential(
          GoogleAuthProvider.credential(idToken: idToken)),
    );
  }

  @override
  Future<void> signOut() async {
    // ⚠️ 네이티브는 Firebase와 google_sign_in 양쪽에서 나와야 한다 — 공식 문서가
    // "clients should not call authenticate to obtain a new GoogleSignInAccount
    // instance until after a call to signOut"이라고 적는다.
    if (!kIsWeb) {
      try {
        await initGoogleSignIn();
        await GoogleSignInPlatform.instance.signOut(const SignOutParams());
      } catch (e) {
        // 여기서 멈추면 Firebase 로그아웃까지 못 한다 — 그쪽이 더 중요하다.
        // 삼키지 않고 로그로 남긴다(다음 로그인의 계정 선택이 달라질 수 있다).
        appLog('google_sign_in 로그아웃 실패: $e');
      }
    }
    await _auth.signOut();
  }
}
