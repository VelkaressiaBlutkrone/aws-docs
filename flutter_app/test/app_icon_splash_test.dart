// 런처 아이콘·스플래시 가드 (A6-3 · A6-4, 2026-11-19).
//
// 점검(`docs/audits/2026-11-19-a6-mobile-usability-audit.md`)이 찾은 둘:
//  - 런처 아이콘이 **Flutter 기본**(파란 F)이었다. ⚠️ `web/icons/*` 도 마찬가지라
//    웹에서 「홈 화면에 추가」해도 파란 F 가 떴다 — 두 플랫폼을 같은 자산으로 맞춘다.
//  - `values/` 와 `values-night/` 가 **둘 다** `@drawable/launch_background` 를 가리키는데
//    그 drawable 이 `@android:color/white` 라, 다크에서 흰 화면이 번쩍였다.
//    (A2 측정상 설치 직후 첫 실행은 488ms 동안 그 화면을 본다.)
//
// ⚠️ 색은 **웹에서 읽어 비교**한다. 숫자를 양쪽에 적어 두면 한쪽만 바뀌어도 아무도 모른다.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _read(String p) => File(p).readAsStringSync();

/// PNG 의 IHDR 에서 픽셀 크기를 읽는다(디코더 없이 바이트로).
({int w, int h}) _pngSize(String path) {
  final b = File(path).readAsBytesSync();
  int be32(int i) => (b[i] << 24) | (b[i + 1] << 16) | (b[i + 2] << 8) | b[i + 3];
  return (w: be32(16), h: be32(20));
}

/// 교체 전 Flutter 기본 아이콘의 바이트 길이(2026-11-19 실측).
/// 되돌아오면 레드가 된다.
const _flutterDefaultBytes = <String, int>{
  'android/app/src/main/res/mipmap-mdpi/ic_launcher.png': 442,
  'android/app/src/main/res/mipmap-hdpi/ic_launcher.png': 544,
  'android/app/src/main/res/mipmap-xhdpi/ic_launcher.png': 721,
  'android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png': 1031,
  'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png': 1443,
  'web/favicon.png': 917,
  'web/icons/Icon-192.png': 5292,
  'web/icons/Icon-512.png': 8252,
  'web/icons/Icon-maskable-192.png': 5594,
  'web/icons/Icon-maskable-512.png': 20998,
};

/// 밀도별 런처 아이콘의 기대 픽셀 크기.
const _mipmapPx = <String, int>{
  'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192,
};

void main() {
  test('대조군: 테마·웹 소스를 읽었다', () {
    expect(_read('lib/theme/app_theme.dart'), contains('accent:'));
    expect(_read('web/index.html'), contains('theme-color'));
  });

  test('스플래시가 더 이상 흰색 고정이 아니다', () {
    for (final p in const [
      'android/app/src/main/res/drawable/launch_background.xml',
      'android/app/src/main/res/drawable-v21/launch_background.xml',
    ]) {
      final src = _read(p);
      expect(src, isNot(contains('@android:color/white')),
          reason: '$p 가 흰색 고정이면 다크에서 흰 화면이 번쩍인다');
      expect(src, contains('@color/splash_background'));
    }
  });

  test('스플래시 색이 웹 theme-color 와 같다(라이트·다크)', () {
    final html = _read('web/index.html');
    String themeColor(String scheme) {
      final m = RegExp(
        'theme-color"\\s+content="(#[0-9A-Fa-f]{6})"\\s+media="\\(prefers-color-scheme: '
        '$scheme\\)"',
      ).firstMatch(html);
      expect(m, isNotNull, reason: '웹 index.html 에서 $scheme theme-color 를 찾지 못했다');
      return m!.group(1)!.toUpperCase();
    }

    // ⚠️ 2026-11-20 부터 `splash_background` 는 색 리터럴이 아니라
    // `@color/splash_background_light`·`_dark` **참조**다(A6-4 잔여) — 색 정의를 한정자 없는
    // `values/` 한 곳에 모으고 `MainActivity` 가 저장 테마로 그 둘 중 하나를 고른다.
    // 그래서 참조를 한 단계 따라가야 한다.
    String androidColor(String path) {
      String? raw(String p, String n) =>
          RegExp('name="$n">([^<]+)<').firstMatch(_read(p))?.group(1);

      var v = raw(path, 'splash_background');
      expect(v, isNotNull, reason: '$path 에 splash_background 가 없다');
      if (v!.startsWith('@color/')) {
        final target = v.substring('@color/'.length);
        v = raw('android/app/src/main/res/values/colors.xml', target);
        expect(v, isNotNull, reason: '참조 대상 $target 이 values/colors.xml 에 없다');
      }
      final up = v!.toUpperCase();
      // #AARRGGBB 로 적었으면 알파를 떼고 비교한다.
      return up.length == 9 ? '#${up.substring(3)}' : up;
    }

    expect(androidColor('android/app/src/main/res/values/colors.xml'),
        themeColor('light'));
    expect(androidColor('android/app/src/main/res/values-night/colors.xml'),
        themeColor('dark'));
  });

  test('적응형 아이콘이 있고 배경이 테마 accent 와 같다', () {
    final adaptive =
        _read('android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml');
    expect(adaptive, contains('<adaptive-icon'));
    expect(adaptive, contains('@color/ic_launcher_background'));
    expect(adaptive, contains('@mipmap/ic_launcher_foreground'));

    final accent = RegExp(r'accent:\s*Color\(0xFF([0-9A-Fa-f]{6})\)')
        .firstMatch(_read('lib/theme/app_theme.dart'));
    expect(accent, isNotNull, reason: 'app_theme.dart 에서 accent 를 읽지 못했다');

    final bg = RegExp(r'name="ic_launcher_background">#([0-9A-Fa-f]{6,8})<')
        .firstMatch(_read('android/app/src/main/res/values/colors.xml'));
    expect(bg, isNotNull);
    final bgHex = bg!.group(1)!.toUpperCase();
    expect(bgHex.length == 8 ? bgHex.substring(2) : bgHex,
        accent!.group(1)!.toUpperCase(),
        reason: '아이콘 배경이 앱의 accent 와 달라지면 런처와 앱 안의 마크가 어긋난다');
  });

  test('런처 아이콘이 밀도별로 올바른 픽셀 크기다', () {
    _mipmapPx.forEach((density, px) {
      for (final name in const ['ic_launcher', 'ic_launcher_foreground']) {
        final p = 'android/app/src/main/res/mipmap-$density/$name.png';
        expect(File(p).existsSync(), isTrue, reason: '$p 가 없다');
        final size = _pngSize(p);
        // foreground 는 적응형 캔버스(108dp)라 런처 아이콘(48dp)보다 2.25배 크다.
        final expected = name == 'ic_launcher' ? px : (px * 108 / 48).round();
        expect(size.w, expected, reason: '$p 의 가로가 ${size.w}px');
        expect(size.h, expected, reason: '$p 의 세로가 ${size.h}px');
      }
    });
  });

  test('아이콘이 Flutter 기본으로 되돌아가지 않았다', () {
    _flutterDefaultBytes.forEach((path, defaultLen) {
      expect(File(path).existsSync(), isTrue, reason: '$path 가 없다');
      expect(File(path).lengthSync(), isNot(defaultLen),
          reason: '$path 가 교체 전 Flutter 기본 아이콘과 바이트 길이가 같다');
    });
  });

  test('아이콘 생성기가 레포에 있다', () {
    // 재현할 수 없는 바이너리를 커밋하지 않는다 — 같은 입력에서 같은 PNG 가 나와야
    // 나중에 색·비율을 바꿀 때 손으로 다시 그리지 않는다.
    expect(File('../tool/make_app_icon.py').existsSync(), isTrue);
  });
}
