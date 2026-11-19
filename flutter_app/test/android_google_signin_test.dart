// flutter_app/test/android_google_signin_test.dart
//
// A4 — Android Google 로그인. `signInWithPopup`은 **웹 전용**이라 안드로이드에서는
// 로그인이 되지 않았고(동기도 돌지 않는다), 공식 문서가 Google에 적는 네이티브 경로는
// `google_sign_in`으로 idToken을 받아 `GoogleAuthProvider.credential`을 만드는 쪽이다
// (firebase_auth 6.7.1의 `signInWithProvider`는 Apple·Facebook 같은 generic OAuth용이고
// Google 경로로는 문서에 없다).
//
// 플러그인·Firebase 호출은 VM에 플랫폼 구현이 없어 돌지 않으므로, **순서와 실패 처리**를
// 주입 가능한 순수 흐름(`runNativeGoogleLogin`·`OnceInitializer`)으로 빼서 여기서 검증하고,
// 플랫폼 분기 자체는 소스 가드로 고정한다(웹 전용 코드를 소스 문자열로 보는 기존 관례 —
// `web_hardening_test.dart`·`release_flag_sync_test.dart`).
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';

import 'package:aws_docs/data/cloud/auth_service.dart';
import 'package:aws_docs/data/cloud/auth_user.dart';
import 'package:aws_docs/data/cloud/cloud_store.dart';
import 'package:aws_docs/data/cloud/google_native_login.dart';
import 'package:aws_docs/data/cloud/sync_controller.dart';
import 'package:aws_docs/data/local_kv.dart';
import 'package:aws_docs/firebase_options.dart';
import 'package:aws_docs/pages/sync_entry.dart';
import 'package:aws_docs/theme/app_theme.dart';
import 'package:aws_docs/theme/theme_scope.dart';

/// 로그인 결과를 테스트가 지정하는 AuthService. `FakeAuthService`는 항상 성공하므로
/// 실패·취소 경로를 만들 수 없다(그 클래스를 건드리지 않고 여기서 따로 만든다).
class _ScriptedAuth implements AuthService {
  _ScriptedAuth();

  /// signInWithGoogle이 던질 예외. null이면 던지지 않는다.
  Object? throwOnSignIn;

  /// signInWithGoogle이 성공했을 때 로그인될 사용자. null이면 미로그인으로 남는다
  /// (= 사용자가 취소한 경우: 예외 없이 끝나지만 사용자는 없다).
  AuthUser? signedInUser;

  AuthUser? _current;
  final _ctrl = StreamController<AuthUser?>.broadcast();

  @override
  AuthUser? get current => _current;
  @override
  Stream<AuthUser?> authChanges() => _ctrl.stream;

  @override
  Future<void> signInWithGoogle() async {
    final e = throwOnSignIn;
    if (e != null) throw e;
    _current = signedInUser;
  }

  @override
  Future<void> signOut() async {
    _current = null;
  }
}

class _EmptyCloud implements CloudStore {
  @override
  Future<void> setDoc(String uid, String collection, String docId,
          Map<String, dynamic> data) async =>
      {};
  @override
  Future<void> deleteDoc(String uid, String collection, String docId) async =>
      {};
  @override
  Future<Map<String, Map<String, dynamic>>> loadCollection(
          String uid, String collection) async =>
      {};
  @override
  Stream<Map<String, Map<String, dynamic>>> watchCollection(
          String uid, String collection) =>
      const Stream.empty();
}

List<String> _captureLogs() {
  final logs = <String>[];
  final original = debugPrint;
  debugPrint = (String? message, {int? wrapWidth}) => logs.add(message ?? '');
  addTearDown(() => debugPrint = original);
  return logs;
}

void main() {
  group('A4 serverClientId', () {
    // ⚠️ google-services.json을 쓰지 않으므로(A3 결정) 공식 android 플러그인 문서대로
    // **웹 애플리케이션의 OAuth 클라이언트 ID**를 serverClientId로 넘겨야 한다. 값이
    // 다른 프로젝트의 것이면 로그인이 조용히 실패하므로 프로젝트 번호를 맞물려 둔다.
    test('웹 OAuth 클라이언트 ID 형식이고 firebase_options의 프로젝트 번호와 같다', () {
      final sender = DefaultFirebaseOptions.android.messagingSenderId;
      expect(sender, isNotEmpty);
      expect(googleServerClientId, endsWith('.apps.googleusercontent.com'));
      expect(googleServerClientId, startsWith('$sender-'),
          reason: 'serverClientId가 이 Firebase 프로젝트의 웹 클라이언트가 아니다');
    });
  });

  group('A4 runNativeGoogleLogin', () {
    test('성공: initialize → authenticate → signInWithCredential 순서', () async {
      final calls = <String>[];
      final ok = await runNativeGoogleLogin(
        ensureInitialized: () async => calls.add('init'),
        authenticate: () async {
          calls.add('auth');
          return 'id-token';
        },
        signInWithIdToken: (t) async => calls.add('signIn:$t'),
      );
      expect(ok, isTrue);
      expect(calls, ['init', 'auth', 'signIn:id-token']);
    });

    // ⚠️ idToken은 String?다(`GoogleSignInAuthentication.idToken`). 없는데 조용히
    // 끝내면 UI가 "동기 켜짐"으로 보이면서 자격 증명이 없는 상태가 된다.
    test('idToken이 없으면 로그인하지 않고 예외를 던진다', () async {
      var signedIn = false;
      await expectLater(
        runNativeGoogleLogin(
          ensureInitialized: () async {},
          authenticate: () async => null,
          signInWithIdToken: (_) async => signedIn = true,
        ),
        throwsA(isA<StateError>()),
      );
      expect(signedIn, isFalse);
    });

    test('사용자 취소는 예외가 아니라 false다', () async {
      var signedIn = false;
      final ok = await runNativeGoogleLogin(
        ensureInitialized: () async {},
        authenticate: () async => throw const GoogleSignInException(
            code: GoogleSignInExceptionCode.canceled),
        signInWithIdToken: (_) async => signedIn = true,
      );
      expect(ok, isFalse);
      expect(signedIn, isFalse);
    });

    test('취소가 아닌 실패는 전파한다(삼키지 않는다)', () async {
      await expectLater(
        runNativeGoogleLogin(
          ensureInitialized: () async {},
          authenticate: () async => throw const GoogleSignInException(
              code: GoogleSignInExceptionCode.providerConfigurationError,
              description: 'SHA 미등록'),
          signInWithIdToken: (_) async {},
        ),
        throwsA(isA<GoogleSignInException>()),
      );
    });

    // `supportsAuthenticate()`가 false인 플랫폼에서 authenticate()는 UnsupportedError를
    // 던진다(웹이 그렇다). 그 경우는 분기가 잘못된 것이므로 삼키면 안 된다.
    test('UnsupportedError도 전파한다', () async {
      await expectLater(
        runNativeGoogleLogin(
          ensureInitialized: () async {},
          authenticate: () async => throw UnsupportedError('no authenticate'),
          signInWithIdToken: (_) async {},
        ),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });

  group('A4 OnceInitializer', () {
    // ⚠️ 공식 문서: "Clients must call this method exactly once ... calling this
    // method more than once will result in undefined behavior." initialize는
    // 플랫폼 인증 이벤트 스트림까지 구독하므로 버튼을 두 번 누르면 두 번 구독된다.
    test('여러 번 호출해도 initialize는 한 번만 돈다', () async {
      var n = 0;
      final once = OnceInitializer(() async => n++);
      await once();
      await once();
      await once();
      expect(n, 1);
    });

    test('동시에 호출해도 initialize는 한 번만 돈다', () async {
      var n = 0;
      final gate = Completer<void>();
      final once = OnceInitializer(() async {
        n++;
        await gate.future;
      });
      final a = once();
      final b = once();
      gate.complete();
      await Future.wait([a, b]);
      expect(n, 1);
    });

    // 실패까지 캐시하면 한 번 실패한 기기는 앱을 다시 켜야 로그인할 수 있다.
    test('실패하면 다음 호출에서 다시 시도한다', () async {
      var n = 0;
      final once = OnceInitializer(() async {
        n++;
        if (n == 1) throw StateError('boom');
      });
      await expectLater(once(), throwsA(isA<StateError>()));
      await once();
      expect(n, 2);
      await once();
      expect(n, 2, reason: '성공한 뒤에는 다시 초기화하지 않는다');
    });
  });

  group('A4 플랫폼 분기(소스 가드)', () {
    // 플러그인 호출은 VM에서 돌지 않아 분기를 실행으로 검증할 수 없다.
    test('웹은 팝업, 네이티브는 runNativeGoogleLogin을 쓴다', () {
      final src =
          File('lib/data/cloud/firebase_auth_service.dart').readAsStringSync();
      // 대조군: 파일을 실제로 읽었다(추출이 깨져 0건이 되는 거짓 통과를 막는다).
      expect(src, contains('class FirebaseAuthService'));

      expect(src, contains('kIsWeb'),
          reason: '웹은 authenticate()를 지원하지 않아 분기가 필요하다');
      expect(src, contains('signInWithPopup'), reason: '웹 경로는 그대로 유지한다');
      expect(src, contains('runNativeGoogleLogin'));
      // serverClientId는 google_native_login이 들고 있고, 네이티브 경로는 **공유**
      // 초기화를 써야 한다 — 서비스마다 따로 초기화하면 "exactly once"가 깨진다.
      expect(src, contains('initGoogleSignIn'));
      expect(src, contains('signInWithCredential'));
    });
  });

  group('A4 웹 번들 보호', () {
    // ⚠️⚠️ 앱 대면 패키지 `google_sign_in`을 의존하면 `google_sign_in_web`이 딸려 오고,
    // 그 플러그인은 **등록 시점**(웹 시작 시 registerWith)에 생성자가 `loadWebSdk()`를
    // 불러 `accounts.google.com/gsi/client` <script>를 **조건 없이** 주입한다. 웹은
    // Firebase 팝업 경로를 쓰므로 그 SDK가 필요 없는데도 모든 페이지 로드가 구글에
    // 3자 요청을 하게 된다 — 그래서 웹 구현이 없는 패키지만 의존한다.
    test('pubspec은 앱 대면 google_sign_in을 의존하지 않는다', () {
      final src = File('pubspec.yaml').readAsStringSync();
      expect(src, contains('google_sign_in_android:'));
      expect(src, contains('google_sign_in_platform_interface:'));
      expect(
          RegExp(r'^\s{2}google_sign_in:', multiLine: true).hasMatch(src), isFalse,
          reason: '앱 대면 패키지를 의존하면 google_sign_in_web이 웹 번들에 들어온다');
    });

    test('lock에 웹 구현 패키지가 없다', () {
      final lock = File('pubspec.lock').readAsStringSync();
      // 대조군: 안드로이드 구현은 실제로 잠겨 있다(추출이 깨진 게 아니다).
      expect(lock, contains('google_sign_in_android'));
      expect(lock, isNot(contains('google_sign_in_web')));
      expect(lock, isNot(contains('google_identity_services_web')));
    });
  });

  group('A4 로그인 실패 노출', () {
    SyncController make(_ScriptedAuth auth) => SyncController(
          auth: auth,
          cloud: _EmptyCloud(),
          local: MemoryBackend(),
        );

    // ⚠️ 호출부가 `onPressed: ctrl.signIn`이라 Future를 버린다 — 컨트롤러가 던지면
    // unhandled async error가 되고 사용자에게는 아무 변화가 없어 버튼이 고장난 것처럼
    // 보인다(Android에서 자격 증명 없음·설정 오류는 흔한 경로다).
    test('실패를 전파하지 않고 메시지로 남기며 로그도 남긴다', () async {
      final logs = _captureLogs();
      final auth = _ScriptedAuth()
        ..throwOnSignIn = const GoogleSignInException(
            code: GoogleSignInExceptionCode.providerConfigurationError);
      final ctrl = make(auth);
      addTearDown(ctrl.dispose);

      await ctrl.signIn(); // 던지지 않는다
      expect(ctrl.signInError, isNotNull);
      expect(ctrl.user, isNull);
      expect(logs.where((l) => l.contains('Google 로그인 실패')), isNotEmpty);
    });

    test('취소(예외 없이 미로그인)에는 메시지를 남기지 않는다', () async {
      final auth = _ScriptedAuth(); // signedInUser == null
      final ctrl = make(auth);
      addTearDown(ctrl.dispose);

      await ctrl.signIn();
      expect(ctrl.signInError, isNull);
      expect(ctrl.user, isNull);
    });

    test('다시 시도해 성공하면 메시지가 지워진다', () async {
      _captureLogs();
      final auth = _ScriptedAuth()..throwOnSignIn = StateError('boom');
      final ctrl = make(auth);
      addTearDown(ctrl.dispose);

      await ctrl.signIn();
      expect(ctrl.signInError, isNotNull);

      auth
        ..throwOnSignIn = null
        ..signedInUser = const AuthUser(uid: 'u1', email: 'a@b.c');
      await ctrl.signIn();
      expect(ctrl.signInError, isNull);
      expect(ctrl.user, isNotNull);
    });

    // ⚠️ 여기서는 debugPrint를 바꾸지 않는다 — testWidgets는 본문이 끝날 때
    // `debugAssertAllFoundationVarsUnset`으로 foundation 디버그 변수가 건드려지지
    // 않았는지 검사하고, 그 검사가 addTearDown보다 **먼저** 돈다.
    testWidgets('SyncEntry가 실패 문구를 보여 준다', (tester) async {
      final auth = _ScriptedAuth()..throwOnSignIn = StateError('boom');
      final ctrl = make(auth);
      addTearDown(ctrl.dispose);

      await tester.pumpWidget(ThemeScope(
        isDark: false,
        toggle: () {},
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SyncEntry(controller: ValueNotifier<SyncController?>(ctrl)),
          ),
        ),
      ));
      expect(find.textContaining('로그인 실패'), findsNothing);

      await ctrl.signIn();
      await tester.pump();
      expect(find.textContaining('로그인 실패'), findsOneWidget);
    });
  });
}
