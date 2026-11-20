// 네이티브 스플래시 ↔ 저장 테마 계약 가드 (A6-4 잔여, 2026-11-20).
//
// 시스템 스플래시 배경은 `values-night/` 리소스 한정자로 **시스템** 다크 모드를 따르는데,
// 앱은 `ThemePrefStore` 의 **저장값**을 따르고 키가 없으면 라이트다(DESIGN.md: 라이트가
// 기본). 그래서 「시스템 다크 + 앱 라이트」에서 어두운 스플래시 뒤 밝은 앱이 뜬다 —
// 2026-11-20 프레임 단위 실측으로 **1,867ms** 동안 `#14181F` 였다(그 뒤 `#FBFAF8` 로 전환).
//
// ⚠️⚠️ **이번 실행의 스플래시는 코드로 바꿀 수 없다** — 프로세스가 시작되기 전에
// WindowManager 가 그린다. 공식 `SplashScreen.setSplashScreenTheme` javadoc 이
// "overrides and **persists** the theme used for the SplashScreen" 라고 적는 대로 그것은
// **다음** 콜드 스타트에 적용된다. 그래서 설치 직후 첫 실행 한 번은 여전히 시스템 테마를
// 따르고(그때는 저장값도 없다), API 31 미만에는 그 API 자체가 없다.
//
// ⚠️⚠️ **Kotlin 이 파일명을 런타임에 계산하면 아무도 검증하지 못한다.** Dart 테스트는
// Kotlin 을 실행할 수 없으므로, Kotlin 은 파일명을 **상수**로 들고 이 가드가 그 상수를
// `base64Url.encode(utf8.encode(<키>))` 와 맞댄다. 키가 바뀌거나 인코딩이 달라지면
// 여기서 먼저 깨진다 — 그러지 않으면 네이티브가 조용히 「키 없음 = 라이트」로 떨어진다.
//
// ⚠️ `NormalTheme`(`?android:colorBackground`, 흰색·검정)은 **고치지 않았다** — 같은 실측에서
// 30fps 전 프레임을 훑어도 보이지 않는다(시스템 스플래시가 Flutter 첫 프레임까지 유지된다).
// 보이지 않는 구간을 위해 코드를 넣는 것은 추측으로 고치는 것이다.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _kotlin = 'android/app/src/main/kotlin/kr/ai/leva/awsdocs/MainActivity.kt';
const _styles = 'android/app/src/main/res/values/styles.xml';
const _colors = 'android/app/src/main/res/values/colors.xml';
const _colorsNight = 'android/app/src/main/res/values-night/colors.xml';
const _store = 'lib/data/theme_pref_store.dart';

String _read(String p) => File(p).readAsStringSync();

/// `static const _name = 'value';` 꼴에서 값을 뽑는다(ThemePrefStore 의 키·값 리터럴).
String _dartConst(String src, String name) {
  final m = RegExp("$name\\s*=\\s*'([^']*)'").firstMatch(src);
  expect(m, isNotNull, reason: '$_store 에서 $name 을 읽지 못했다');
  return m!.group(1)!;
}

/// `const NAME = "value"` 꼴에서 값을 뽑는다(Kotlin companion 상수).
String _kotlinConst(String src, String name) {
  final m = RegExp('$name\\s*=\\s*"([^"]*)"').firstMatch(src);
  expect(m, isNotNull, reason: '$_kotlin 에서 $name 을 읽지 못했다');
  return m!.group(1)!;
}

/// colors.xml 의 색 하나를 `#RRGGBB` 로 돌려준다. 값이 `@color/다른이름` 참조면
/// 한정자 없는 `values/colors.xml` 에서 한 단계 따라간다(색 리터럴을 한 곳에 두려고
/// `splash_background` 가 `_light`·`_dark` 를 참조한다).
String _androidColor(String path, String name) {
  String? raw(String p, String n) =>
      RegExp('name="$n">([^<]+)<').firstMatch(_read(p))?.group(1);

  var v = raw(path, name);
  expect(v, isNotNull, reason: '$path 에 $name 이 없다');
  if (v!.startsWith('@color/')) {
    final target = v.substring('@color/'.length);
    v = raw(_colors, target);
    expect(v, isNotNull, reason: '$_colors 에 참조 대상 $target 이 없다');
  }
  final up = v!.toUpperCase();
  // #AARRGGBB 로 적었으면 알파를 떼고 비교한다.
  return up.length == 9 ? '#${up.substring(3)}' : up;
}

String _webThemeColor(String scheme) {
  final m = RegExp(
    'theme-color"\\s+content="(#[0-9A-Fa-f]{6})"\\s+media="\\(prefers-color-scheme: '
    '$scheme\\)"',
  ).firstMatch(_read('web/index.html'));
  expect(m, isNotNull, reason: '웹 index.html 에서 $scheme theme-color 를 찾지 못했다');
  return m!.group(1)!.toUpperCase();
}

void main() {
  group('A6-4 잔여 — 네이티브 스플래시가 저장 테마를 읽는다', () {
    test('대조군: 네 소스를 읽었다', () {
      // 아래 단정들이 "추출 실패로 통과"가 되지 않게 하는 하한이다.
      expect(_read(_kotlin), contains('FlutterActivity'));
      expect(_read(_styles), contains('LaunchTheme'));
      expect(_read(_colors), contains('splash_background'));
      expect(_read(_store), contains('ThemePrefStore'));
    });

    test('Kotlin 이 읽는 파일명이 Dart 가 쓰는 키에서 유도된다', () {
      final key = _dartConst(_read(_store), '_key');
      final expected = base64Url.encode(utf8.encode(key));
      expect(_kotlinConst(_read(_kotlin), 'THEME_FILE_NAME'), expected,
          reason: '키($key)의 base64url 과 다르면 네이티브가 영원히 「키 없음」을 본다 — '
              'FileKvBackend 가 키 하나를 base64url 파일명 하나로 쓴다');
    });

    test('Kotlin 이 비교하는 값이 Dart 가 쓰는 값과 같다', () {
      final dark = _dartConst(_read(_store), '_dark');
      expect(_kotlinConst(_read(_kotlin), 'THEME_DARK_VALUE'), dark);
      // 키 미존재·파손은 양쪽 모두 **라이트** 폴백이어야 한다(DESIGN.md: 라이트가 기본).
      expect(_read(_store), contains("read(_key) == _dark"),
          reason: 'Dart 가 「dark 일 때만 다크」가 아니면 폴백이 갈린다');
      expect(_read(_kotlin), contains('== THEME_DARK_VALUE'));
    });

    test('Kotlin 의 디렉터리 계약이 path_provider 와 같다', () {
      final src = _read(_kotlin);
      final dart = _read('lib/data/persistent_backend_io.dart');

      // ⚠️⚠️ **두 경로를 혼동하면 네이티브가 빈 디렉터리를 보고 항상 라이트로 폴백한다**
      // (2026-11-20 에 실제로 그랬다 — 저장값이 다크인데 스플래시가 라이트였다).
      // `path_provider_android` 2.2.23 `PathProviderPlugin` 의 두 메서드는 6줄 간격으로
      // 붙어 있고 **서로 다른 디렉터리**를 준다:
      //   getApplicationSupportPath()   -> PathUtils.getFilesDir(context)
      //                                 = context.getFilesDir()  = <dataDir>/files
      //   getApplicationDocumentsPath() -> PathUtils.getDataDirectory(context)
      //                                 = getDir("flutter", MODE_PRIVATE) = <dataDir>/app_flutter
      // Dart 가 쓰는 것은 **support** 쪽이다.
      expect(dart, contains('getApplicationSupportDirectory'),
          reason: 'Dart 가 다른 경로로 바뀌면 Kotlin 의 filesDir 도 함께 바꿔야 한다');
      expect(src, contains('filesDir'));
      expect(src, isNot(contains('getDir("flutter"')),
          reason: 'app_flutter 는 documents 경로다 — support 경로가 아니다');

      // FileKvBackend 가 그 아래 `kv/` 를 쓴다(persistent_backend_io.dart).
      expect(src, contains('kv/'));
      expect(dart, contains(r"pathSeparator}kv'"),
          reason: 'Dart 쪽이 kv 하위 디렉터리를 쓰지 않으면 Kotlin 경로가 틀린다');

      // ⚠️ 이 매핑은 **그 버전에서 소스로 확인한 것**이다. 버전이 올라가면 매핑이 바뀔 수
      // 있는데, `android_release_config_test.dart` 가 `path_provider_android` 를 2.2.23 에
      // 정확히 고정하고 있어 버전이 움직이면 거기서 먼저 깨진다(A2 의 JNI 회귀 핀).
      expect(_read('pubspec.yaml'), contains('path_provider_android'));
    });

    test('스플래시 테마 둘이 있고 Kotlin 이 그 이름을 쓴다', () {
      final styles = _read(_styles);
      final src = _read(_kotlin);
      for (final name in const ['SplashThemeLight', 'SplashThemeDark']) {
        expect(styles, contains('name="$name"'), reason: '$_styles 에 $name 이 없다');
        expect(src, contains('R.style.$name'));
      }
      // ⚠️ 공식 javadoc: "the theme name is resolved and persisted ... the theme name must
      // be stable across versions, otherwise it won't be found after your application is
      // updated." 이름을 바꾸면 **업데이트한 기기**에서 스플래시를 못 찾는다.
    });

    test('스플래시 테마 색은 시스템 테마와 무관하게 고정이다', () {
      final styles = _read(_styles);
      expect(styles, contains('@color/splash_background_light'));
      expect(styles, contains('@color/splash_background_dark'));
      // 한정자 없는 values/ 에만 **정의**돼야 한다 — values-night/ 에 같은 이름의
      // 리소스가 있으면 「고정색」이 아니라 또 시스템 테마를 따르게 되어 이 수정의
      // 요점이 사라진다.
      //
      // ⚠️ 금지하는 것은 `name="..."` 정의뿐이고 **주석이나 참조에서의 언급은 아니다** —
      // night 파일이 「이 둘을 여기 두면 안 된다」고 설명하면서 그 이름을 인용하고,
      // `splash_background` 가 `@color/splash_background_dark` 를 참조한다. 이름만 세면
      // 그 정당한 줄들이 걸린다(실제로 걸렸다 — 레포에서 반복된 함정이다).
      final night = _read(_colorsNight);
      for (final n in const ['splash_background_light', 'splash_background_dark']) {
        expect(night, isNot(contains('name="$n"')),
            reason: '$_colorsNight 이 $n 을 정의하면 고정색이 아니게 된다');
        // 대조군 — 같은 패턴이 values/ 에서는 실제로 그 정의를 찾는다(탐지기가 먹는다).
        expect(_read(_colors), contains('name="$n"'));
      }
    });

    test('고정색이 웹 theme-color 와 같다', () {
      expect(_androidColor(_colors, 'splash_background_light'),
          _webThemeColor('light'));
      expect(_androidColor(_colors, 'splash_background_dark'),
          _webThemeColor('dark'));
      // LaunchTheme 쪽(시스템 테마를 따르는 기존 경로)도 같은 색이어야 한다.
      // API 31 미만과 설치 직후 첫 실행이 그 경로를 쓴다.
      expect(_androidColor(_colors, 'splash_background'), _webThemeColor('light'));
      expect(_androidColor(_colorsNight, 'splash_background'),
          _webThemeColor('dark'));
    });

    test('측정 도구가 레포에 있다', () {
      // 스플래시는 **노드가 없는 단색 화면**이라 `tool/android_ui_audit.py` 의 접근성 노드
      // 판정으로는 아무것도 보이지 않는다. 이 수정의 유일한 판정 수단이 프레임 색 추적이고,
      // 2026-11-19 감사가 스크립트를 커밋하지 않아 재점검이 막힌 선례가 있다.
      final tool = File('../tool/android_splash_trace.py');
      expect(tool.existsSync(), isTrue);
      final src = tool.readAsStringSync();
      expect(src, contains('--self-test'),
          reason: '기기 없이 판정 로직을 검증할 수단이 있어야 한다');
      // 도구가 쓰는 색이 이 레포의 테마 색과 같아야 한다 — 다르면 측정이 조용히 틀린다.
      expect(src, contains('#FBFAF8'));
      expect(src, contains('#14181F'));
    });

    test('API 31 미만을 건너뛰고, 토글 직후도 반영한다', () {
      final src = _read(_kotlin);
      expect(src, contains('Build.VERSION_CODES.S'),
          reason: 'setSplashScreenTheme 은 API 31+ 다 — minSdk 24 에서 버전 가드가 없으면 죽는다');
      expect(src, contains('setSplashScreenTheme'));
      // onCreate 만 보면 **토글 후 첫 재시작**이 옛 테마로 뜬다(어긋남이 가장 눈에 띄는 순간).
      expect(RegExp(r'override fun onPause').hasMatch(src), isTrue,
          reason: '토글 직후를 반영하려면 백그라운드로 갈 때도 다시 읽어야 한다');
    });
  });
}
