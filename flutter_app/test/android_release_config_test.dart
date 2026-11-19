// Android 릴리스 구성 가드 (A1, 2026-11-18).
//
// Android 빌드 구성은 VM 테스트로 실행할 수 없다(Gradle 과 실기기가 필요하다). 그래서 Gradle·manifest·
// .gitignore 를 문자열로 읽는 소스 가드다 — `web_hardening_test.dart`·`release_flag_sync_test.dart` 와
// 같은 방식이고, 대조군으로 「파일을 실제로 읽었다」를 먼저 단정해 추출이 깨져 0건이 되는 거짓 통과를 막는다.
//
// ⚠️ `applicationId` 는 Play 에서 **영구**다 — 삭제·재사용이 불가능하고, 바뀌면 Firebase 안드로이드 앱
// 등록과 구글 로그인 SHA 지문까지 어긋난다. 그래서 정확한 일치로 못박는다.
// ⚠️ 업로드 키는 분실하면 앱 업데이트가 불가능하고, 커밋되면 누구나 이 앱으로 서명할 수 있다. 그래서
// 「키 자료가 .gitignore 에 있다」를 서명 구성과 **쌍으로** 단정한다(한쪽만 보면 반쪽이 샌다).
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Play 에 영구 등록될 패키지 이름. 사용자가 2026-11-18 에 확정했다.
const _appId = 'kr.ai.leva.awsdocs';

/// 런처에 보이는 이름. 웹 PWA 의 `name`("AWS Docs Roadmap")과 같은 제품이므로 같은 값을 쓴다.
const _appLabel = 'AWS Docs Roadmap';

File get _gradle => File('android/app/build.gradle.kts');
File get _manifest => File('android/app/src/main/AndroidManifest.xml');
File get _gitignore => File('.gitignore');

/// `targetSdk = 36` 처럼 **숫자 리터럴**만 읽는다. 템플릿 기본값인 `flutter.targetSdkVersion` 은
/// 이 가드가 수치를 확인할 수 없으므로 허용하지 않는다(null 이면 단정이 실패한다).
int? _sdkLiteral(String gradle, String key) {
  final m = RegExp('$key\\s*=\\s*(\\d+)').firstMatch(gradle);
  return m == null ? null : int.parse(m.group(1)!);
}

void main() {
  test('대조군: Android 앱 모듈의 Gradle·manifest 를 읽었다', () {
    expect(_gradle.existsSync(), isTrue,
        reason: 'android/app/build.gradle.kts 가 없다 — flutter create --platforms=android 가 필요하다');
    expect(_manifest.existsSync(), isTrue, reason: 'main AndroidManifest.xml 이 없다');
    expect(_gradle.readAsStringSync(), contains('android {'));
    expect(_manifest.readAsStringSync(), contains('<manifest'));
  });

  test('applicationId·namespace 가 확정 패키지 이름이다', () {
    final g = _gradle.readAsStringSync();
    expect(g, contains('applicationId = "$_appId"'),
        reason: 'applicationId 는 Play 에서 영구다 — $_appId 에서 바뀌면 안 된다');
    expect(g, contains('namespace = "$_appId"'),
        reason: 'namespace 가 applicationId 와 달라지면 R 클래스·manifest 병합이 어긋난다');
    expect(g, isNot(contains('com.example')),
        reason: '템플릿 기본 패키지(com.example…)가 남아 있으면 Play 에 올릴 수 없다');
  });

  test('targetSdk 가 36 이상이다', () {
    final v = _sdkLiteral(_gradle.readAsStringSync(), 'targetSdk');
    expect(v, isNotNull, reason: 'targetSdk 를 숫자 리터럴로 선언해야 이 가드가 수치를 확인할 수 있다');
    expect(v, greaterThanOrEqualTo(36), reason: 'Play 의 대상 API 수준 요건 — 로드맵 A1');
  });

  test('minSdk 가 23 이상 숫자 리터럴이다', () {
    // 23 은 Firebase 안드로이드 플러그인이 요구하는 하한으로 잡았다. Gradle 이 더 높은 값을 요구하면
    // 빌드가 먼저 알려 주므로, 그때 이 수치와 build.gradle.kts 를 함께 올린다.
    final v = _sdkLiteral(_gradle.readAsStringSync(), 'minSdk');
    expect(v, isNotNull, reason: 'minSdk 를 숫자 리터럴로 선언해야 Firebase 하한을 가드가 확인할 수 있다');
    expect(v, greaterThanOrEqualTo(23));
  });

  test('릴리스 서명을 외부 key.properties 에서 읽고, 키가 없으면 debug 로 폴백한다', () {
    final g = _gradle.readAsStringSync();
    expect(g, contains('key.properties'),
        reason: '키스토어 경로·비밀번호는 저장소 밖 프로퍼티 파일에서 읽어야 한다');
    expect(g, contains('signingConfigs'), reason: '릴리스 서명 구성이 없다');
    // 폴백이 있어야 키 없는 환경(CI·새 클론)에서도 `flutter build appbundle --release` 로
    // A1 완료 기준을 검증할 수 있다.
    expect(g, contains('exists()'),
        reason: 'key.properties 유무 분기가 없으면 키 없는 환경에서 릴리스 빌드가 깨진다');
  });

  test('키 자료·Firebase 안드로이드 설정이 커밋되지 않는다', () {
    final lines = _gitignore
        .readAsStringSync()
        .split(RegExp(r'\r?\n'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty && !l.startsWith('#'))
        .toSet();
    for (final pattern in const [
      '**/android/key.properties',
      '**/*.jks',
      '**/*.keystore',
      '**/android/app/google-services.json',
    ]) {
      expect(lines, contains(pattern),
          reason: '.gitignore 에 `$pattern` 이 없다 — 서명 키나 Firebase 설정이 커밋될 수 있다');
    }
  });

  test('main manifest 가 INTERNET 권한과 앱 표시명을 선언한다', () {
    final m = _manifest.readAsStringSync();
    // 템플릿은 INTERNET 을 debug·profile manifest 에만 넣는다. 릴리스 빌드는 main 을 쓰므로
    // 여기에 없으면 설치된 앱이 Firestore·R2 에 닿지 못한다.
    expect(m, contains('android.permission.INTERNET'),
        reason: 'main manifest 에 INTERNET 권한이 없으면 릴리스 빌드에서 네트워크가 막힌다');
    expect(m, contains('android:label="$_appLabel"'), reason: '런처 표시명이 웹 PWA 이름과 달라졌다');
  });

  test('path_provider_android 가 JNI 이전 판에 정확한 버전으로 고정돼 있다', () {
    // ⚠️ 2.3.0(2026-04-06)부터 JNI 경로를 쓰는데, 최신 2.3.1 에서
    // `ClassNotFoundException: Didn't find class "Landroid/content/Context;"` 로
    // 디렉터리 조회가 실패한다(릴리스·디버그 양쪽에서 재현 — R8 축소가 아니다).
    // 그러면 `initLocalStorage()` 가 degrade 해 **학습 기록이 메모리에만 남는다** —
    // A2 가 고친 바로 그 증상으로 조용히 되돌아간다.
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final m = RegExp(r'^\s*path_provider_android:\s*(\S+)\s*$', multiLine: true)
        .firstMatch(pubspec);
    expect(m, isNotNull,
        reason: 'path_provider_android 핀이 사라졌다 — 상류가 고쳤다면 이 가드도 함께 푼다');
    final pinned = m!.group(1)!;
    expect(pinned, isNot(startsWith('^')),
        reason: '캐럿 범위면 2.3.x 로 올라가 다시 깨진다 — 정확한 버전이어야 한다');
    expect(pinned, '2.2.23');
  });

  test('잠금 파일에 jni 계열이 들어오지 않는다', () {
    final lock = File('pubspec.lock').readAsStringSync();
    // 대조군: 잠금 파일을 실제로 읽었다(추출이 깨져 0건이 되는 거짓 통과를 막는다).
    expect(lock, contains('path_provider_android:'));
    for (final pkg in const ['jni', 'jni_flutter', 'jni_util']) {
      expect(RegExp('^  $pkg:\$', multiLine: true).hasMatch(lock), isFalse,
          reason: '$pkg 가 들어왔다 = path_provider_android 가 2.3.x 로 올라갔다');
    }
  });

  test('Kotlin 소스 경로가 패키지 이름과 일치한다', () {
    final dir = _appId.replaceAll('.', '/');
    expect(File('android/app/src/main/kotlin/$dir/MainActivity.kt').existsSync(), isTrue,
        reason: 'MainActivity 의 디렉터리가 $_appId 와 어긋나면 클래스를 찾지 못한다');
  });
}
