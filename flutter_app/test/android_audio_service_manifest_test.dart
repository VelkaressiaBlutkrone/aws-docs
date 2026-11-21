// Android 미디어 세션 선언 가드 (D1-b, 2026-11-21).
//
// `audio_service` 는 **매니페스트 선언이 코드의 전제**다 — 공식 문서가 적는 대로 서비스·리시버·
// Activity 가 맞지 않으면 `AudioService.init` 이 `PlatformException` 으로 실패한다("On Android,
// if the correct Service or Activity is not declared in AndroidManifest.xml, or the Activity does
// not provide the correct FlutterEngine"). 그 실패는 **재생은 되는데 잠금화면만 없는** 모양으로
// 나타나므로 테스트가 없으면 조용히 샌다.
//
// Gradle·매니페스트·Kotlin 은 VM 테스트로 실행할 수 없어 소스 문자열 가드다
// (`android_release_config_test.dart`·`splash_theme_sync_test.dart` 와 같은 방식). 대조군으로
// 「파일을 실제로 읽었다」를 먼저 단정해 추출이 깨져 0건이 되는 거짓 통과를 막는다.
import 'dart:io';

import 'package:aws_docs/data/audio_service_session.dart';
import 'package:aws_docs/data/media_session_binder.dart';
import 'package:flutter_test/flutter_test.dart';

File get _manifest => File('android/app/src/main/AndroidManifest.xml');
File get _gradle => File('android/app/build.gradle.kts');
File get _activity =>
    File('android/app/src/main/kotlin/kr/ai/leva/awsdocs/MainActivity.kt');

/// 공백·줄바꿈을 한 칸으로 접어 속성 순서를 그대로 둔 채 부분 문자열로 셀 수 있게 한다.
String _flat(String s) => s.replaceAll(RegExp(r'\s+'), ' ');

int? _sdkLiteral(String gradle, String key) {
  final m = RegExp('$key\\s*=\\s*(\\d+)').firstMatch(gradle);
  return m == null ? null : int.parse(m.group(1)!);
}

/// `tools:keep` 규칙(`@drawable/audio_service_*`)이 `MediaControl.androidIcon`
/// (`drawable/audio_service_stop`)을 덮는가. `*` 만 와일드카드다.
bool _keepCovers(String pattern, String androidIcon) {
  final p = pattern.startsWith('@') ? pattern.substring(1) : pattern;
  final rx = RegExp('^${p.split('*').map(RegExp.escape).join('.*')}\$');
  return rx.hasMatch(androidIcon);
}

void main() {
  test('대조군: 매니페스트·Gradle·MainActivity 를 읽었다', () {
    expect(_manifest.existsSync(), isTrue);
    expect(_gradle.existsSync(), isTrue);
    expect(_activity.existsSync(), isTrue);
    expect(_manifest.readAsStringSync(), contains('<manifest'));
    expect(_activity.readAsStringSync(), contains('class MainActivity'));
  });

  test('tools 네임스페이스를 선언한다', () {
    // `tools:ignore="Instantiatable"` 이 서비스·리시버 선언에 필요하고(플러그인이 제공하는
    // 클래스를 lint 가 「인스턴스화 불가」로 본다) 네임스페이스가 없으면 **빌드가 깨진다**.
    expect(_flat(_manifest.readAsStringSync()),
        contains('xmlns:tools="http://schemas.android.com/tools"'));
  });

  test('targetSdk 가 34 이상이므로 포그라운드 서비스 권한 3종이 모두 있다', () {
    // ⚠️ `FOREGROUND_SERVICE_MEDIA_PLAYBACK` 은 **SDK 34 이상을 타깃할 때** 필수다. 수치를
    // 리터럴로 박지 않고 Gradle 에서 읽어 와, targetSdk 를 내리면 이 단정의 전제가 함께
    // 바뀌는 것이 보이게 한다.
    final target = _sdkLiteral(_gradle.readAsStringSync(), 'targetSdk');
    expect(target, isNotNull, reason: 'targetSdk 를 숫자 리터럴로 적어야 한다');
    expect(target, greaterThanOrEqualTo(34));

    final m = _manifest.readAsStringSync();
    for (final p in const [
      'android.permission.WAKE_LOCK',
      'android.permission.FOREGROUND_SERVICE',
      'android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK',
    ]) {
      expect(m, contains('<uses-permission android:name="$p"'), reason: p);
    }
  });

  test('AudioService 를 mediaPlayback 포그라운드 서비스로 선언한다', () {
    final m = _flat(_manifest.readAsStringSync());
    expect(m, contains('android:name="com.ryanheise.audioservice.AudioService"'));
    // ⚠️ 이 유형이 없으면 Android 14+ 에서 포그라운드 시작이 거부된다.
    expect(m, contains('android:foregroundServiceType="mediaPlayback"'));
    // 미디어 브라우저 클라이언트(잠금화면·Android Auto)가 찾는 액션.
    expect(m, contains('android.media.browse.MediaBrowserService'));
  });

  test('MediaButtonReceiver 를 선언한다', () {
    // 공식 FAQ 가 「알림·헤드셋 버튼이 안 먹는다」의 원인으로 이 리시버 누락을 든다.
    final m = _flat(_manifest.readAsStringSync());
    expect(m,
        contains('android:name="com.ryanheise.audioservice.MediaButtonReceiver"'));
    expect(m, contains('android.intent.action.MEDIA_BUTTON'));
  });

  test('서비스·리시버가 exported 다', () {
    // 다른 프로세스(시스템 미디어 세션·헤드셋 브로드캐스트)가 붙으므로 exported 여야 한다.
    final m = _flat(_manifest.readAsStringSync());
    for (final tag in const ['<service', '<receiver']) {
      final i = m.indexOf(tag);
      expect(i, greaterThan(-1), reason: '$tag 선언이 없다');
      final chunk = m.substring(i, m.indexOf('>', i) + 1);
      expect(chunk, contains('android:exported="true"'), reason: chunk);
    }
  });

  test('MainActivity 가 AudioServiceActivity 를 상속하고 스플래시 코드를 유지한다', () {
    // ⚠️⚠️ **상속만 바꾼다.** 이 Activity 는 A6-4 의 「저장된 테마로 다음 콜드 스타트의
    // 스플래시를 지정한다」 코드를 들고 있다. `AudioServiceActivity` 는 `FlutterActivity` 의
    // 하위 클래스로 `provideFlutterEngine` 만 재정의해 **공유 FlutterEngine** 을 돌려주므로
    // (패키지 소스 실측) 나머지 동작은 그대로다 — 매니페스트의 Activity 이름을
    // `com.ryanheise.audioservice.AudioServiceActivity` 로 바꾸면 이 코드가 통째로 사라진다.
    final a = _activity.readAsStringSync();
    expect(a, contains('import com.ryanheise.audioservice.AudioServiceActivity'));
    expect(a, contains('class MainActivity : AudioServiceActivity()'));
    expect(a, contains('setSplashScreenTheme'),
        reason: 'A6-4 의 스플래시 테마 지정이 사라졌다');

    // 매니페스트는 여전히 우리 Activity 를 가리켜야 한다(플러그인 기본 Activity 로
    // 바꾸면 위 코드가 실행되지 않는다).
    expect(_flat(_manifest.readAsStringSync()),
        contains('android:name=".MainActivity"'));
  });

  test('내보내는 알림 버튼 아이콘이 리소스 축소에서 지켜진다', () {
    // ⚠️⚠️ **릴리스 빌드에서만 나는 결함을 막는 가드다.** Flutter 는 릴리스에
    // `isShrinkResources = true` 를 켜고, audio_service 는 아이콘을 **런타임 이름 조회**
    // (`getResources().getIdentifier`)로 찾는다 — 축소기가 그 호출을 못 보고 드로어블을
    // 지우면 `getIdentifier` 가 0 을 돌려주고, SDK 33+ 의 `MediaControl.stop` 은
    // CustomAction 이라 `IllegalArgumentException` 으로 **setState 전체가 중단된다**
    // (2026-11-21 실측: 알림·포그라운드 서비스·잠금화면이 통째로 없었다).
    // 그래서 우리가 내보내는 컨트롤의 아이콘 이름을 keep 규칙과 **기계로** 맞댄다 —
    // 플러그인이 아이콘 이름 규칙을 바꾸면 여기서 먼저 깨진다.
    final keep = File('android/app/src/main/res/raw/keep.xml');
    expect(keep.existsSync(), isTrue,
        reason: 'res/raw/keep.xml 이 없다 — 릴리스에서 알림 아이콘이 사라진다');
    final rules =
        RegExp(r'tools:keep="([^"]+)"').firstMatch(keep.readAsStringSync())?.group(1);
    expect(rules, isNotNull, reason: '대조군: keep.xml 에서 tools:keep 규칙을 읽었다');
    final patterns = rules!.split(',').map((s) => s.trim()).toList();

    final icons = <String>{
      for (final st in MediaPlaybackState.values)
        ...mapSessionPlaybackState(st).controls.map((c) => c.androidIcon),
      // 알림 small icon 도 같은 경로로 찾는다(`androidNotificationIcon` → getIdentifier).
      kLectureNotificationIcon,
    };
    expect(icons, isNotEmpty, reason: '대조군: 내보내는 컨트롤이 있다');
    for (final icon in icons) {
      expect(patterns.any((p) => _keepCovers(p, icon)), isTrue,
          reason: '$icon 를 덮는 keep 규칙이 없다 (규칙: $patterns)');
    }
    // 대조군: 탐지가 공허하지 않다 — 관계없는 이름은 덮이지 않는다.
    expect(patterns.any((p) => _keepCovers(p, 'drawable/ic_launcher')), isFalse);
  });

  test('알림 small icon 자산이 밀도별로 실재한다', () {
    // ⚠️⚠️ 런처 아이콘을 쓰면 잠금화면에 **글리프 없는 단색 원**이 나온다 — 안드로이드는
    // small icon 의 알파만 쓰고 강조색으로 칠하는데 런처 아이콘은 전체가 불투명하다
    // (2026-11-21 실측). 그래서 배경 없는 전용 자산을 둔다.
    expect(kLectureNotificationIcon, startsWith('drawable/'));
    final name = kLectureNotificationIcon.split('/').last;
    const densities = ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi'];
    for (final d in densities) {
      final f = File('android/app/src/main/res/drawable-$d/$name.png');
      expect(f.existsSync(), isTrue, reason: '${f.path} 가 없다');
      expect(f.lengthSync(), greaterThan(100), reason: '${f.path} 가 비었다');
    }
    // 재현 가능한 생성기를 함께 둔다(레포 관례 — 재현 불가 바이너리를 두지 않는다).
    final gen = File('../tool/make_app_icon.py').readAsStringSync();
    expect(gen, contains('--notification'));
    expect(gen, contains(name));
  });

  test('알림 채널 ID 가 applicationId 접두사를 쓴다', () {
    // ⚠️⚠️ 공식 문서: 채널 ID 를 **릴리스 뒤에 바꾸면 두 번째 채널이 생긴다** — 사용자가 끈
    // 알림 설정이 옛 채널에 남아 「알림을 껐는데 또 뜬다」가 된다. Dart 상수와 Gradle 의
    // `applicationId` 를 여기서 묶어 둬서, 패키지 이름이 바뀌면 채널 ID 도 함께 보게 한다.
    final appId = RegExp(r'applicationId\s*=\s*"([^"]+)"')
        .firstMatch(_gradle.readAsStringSync())
        ?.group(1);
    expect(appId, isNotNull, reason: '대조군: Gradle 에서 applicationId 를 읽었다');
    final src = File('lib/data/audio_service_session.dart').readAsStringSync();
    expect(src, contains("'$appId.channel.lecture'"));
  });

  test('Android 릴리스 빌드가 웹 릴리스와 같은 dart-define 을 켠다', () {
    // ⚠️⚠️ `audio_lecture` 는 **빌드 시점** 상수라 켜는 곳이 빌드 명령뿐이다. 웹은
    // `pages.yml` 이 켜고 `release_flag_sync_test.dart` 가 CI 동기를 지키는데, Android 에는
    // 워크플로가 없어 **켤 자리가 없었다**. 그래서 릴리스 AAB 명령을 스크립트로 커밋해
    // 단일 출처로 두고, 웹이 켜는 플래그를 전부 켜는지 여기서 맞댄다.
    final script = File('tool/build_android_release.ps1');
    expect(script.existsSync(), isTrue,
        reason: 'Android 릴리스 빌드 명령이 커밋돼 있어야 한다');
    final s = script.readAsStringSync();
    expect(s, contains('flutter build appbundle'));

    final pages = File('../.github/workflows/pages.yml').readAsStringSync();
    final defines = RegExp(r'--dart-define=([A-Za-z_][A-Za-z0-9_]*)=(\S+)')
        .allMatches(pages)
        .map((m) => m.group(0)!)
        .toSet();
    expect(defines, isNotEmpty, reason: '대조군: 웹 릴리스가 dart-define 을 쓴다');
    for (final d in defines) {
      expect(s, contains(d),
          reason: 'Android 릴리스가 $d 를 켜지 않는다 — 웹에만 있는 기능이 되어 버린다');
    }
  });
}
