import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/cloud/firebase_bootstrap.dart';
import 'package:aws_docs/firebase_options.dart';

/// A3 — Firebase Android 앱 등록 반영.
///
/// 이 레포는 웹 전용으로 출발해 `firebase_options.dart`에 **web 엔트리만** 있었고,
/// `currentPlatform`이 android에서 `UnsupportedError`를 던졌다. 그래서 A2 측정에서
/// 안드로이드 앱이 「cloud sync init 실패 — 로컬 전용으로 동작」을 띄웠다.
///
/// ⚠️ **이 값들은 비밀이 아니다** — 공식 문서가 "unique, but non-secret identifiers"로
/// 명시하고 이 레포는 web 키를 이미 커밋해 왔다. 비밀은 키스토어와 `key.properties`이고
/// 그 둘은 `.gitignore`에 있다(`android_release_config_test.dart`가 단정한다).
///
/// ⚠️ **`google-services.json`과 `com.google.gms.google-services` 플러그인은 쓰지 않는다.**
/// FlutterFire는 `Firebase.initializeApp(options:)`로 값을 **코드에서** 받고, 그 플러그인은
/// Crashlytics·Performance·FCM 같은 제품을 넣을 때 필요해진다(공식 문서 확인, 2026-11-19).
void main() {
  group('firebase_options — android 엔트리', () {
    test('같은 Firebase 프로젝트를 가리킨다', () {
      expect(DefaultFirebaseOptions.android.projectId,
          DefaultFirebaseOptions.web.projectId);
      expect(DefaultFirebaseOptions.android.messagingSenderId,
          DefaultFirebaseOptions.web.messagingSenderId,
          reason: 'messagingSenderId == 프로젝트 번호라 플랫폼이 같아야 한다');
      expect(DefaultFirebaseOptions.android.storageBucket,
          DefaultFirebaseOptions.web.storageBucket);
    });

    test('appId가 android 플랫폼으로 등록된 것이다', () {
      final String id = DefaultFirebaseOptions.android.appId;
      expect(id, startsWith('1:169329324307:android:'),
          reason: 'appId 형식은 1:<프로젝트 번호>:<플랫폼>:<해시>다 — '
              'web appId를 복사해 오면 여기서 걸린다');
      expect(id, isNot(DefaultFirebaseOptions.web.appId));
    });

    test('apiKey가 web과 다르다 — 플랫폼별로 발급된다', () {
      expect(DefaultFirebaseOptions.android.apiKey,
          isNot(DefaultFirebaseOptions.web.apiKey),
          reason: '같으면 web 엔트리를 복붙한 실수다');
      expect(DefaultFirebaseOptions.android.apiKey, startsWith('AIza'));
    });

    test('web 전용 필드는 android에 넣지 않는다', () {
      // authDomain·measurementId는 웹 SDK가 쓰는 값이다.
      expect(DefaultFirebaseOptions.android.authDomain, isNull);
      expect(DefaultFirebaseOptions.android.measurementId, isNull);
      expect(DefaultFirebaseOptions.web.authDomain, isNotNull,
          reason: '대조군: web은 그 둘을 갖는다');
    });

    test('currentPlatform이 android에서 던지지 않는다 — A3의 실질', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      expect(DefaultFirebaseOptions.currentPlatform.appId,
          DefaultFirebaseOptions.android.appId);
    });

    test('대조군: 설정하지 않은 플랫폼은 여전히 던진다', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      expect(() => DefaultFirebaseOptions.currentPlatform,
          throwsUnsupportedError,
          reason: 'iOS·macOS·Windows·Linux는 등록하지 않았다 — '
              '이 단정이 통과해야 위 테스트가 "아무거나 돌려준다"가 아니다');
    });

    test('cloudConfigured는 플랫폼과 무관하게 true다 — VM 테스트 불변', () {
      expect(cloudConfigured(), isTrue);
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      expect(cloudConfigured(), isTrue,
          reason: 'web 옵션을 직접 판독하므로 VM(windows)에서도 던지지 않는다');
    });
  });
}
