// flutter_app/test/app_version_sync_test.dart
//
// 앱 버전 상수 ↔ `pubspec.yaml` 동기 가드.
//
// ⚠️ 이 레포에는 `package_info_plus` 가 없고(의존성을 더하면 웹 번들 오염을
// 측정해야 한다 — A4·D1 에서 두 번 치른 비용) 두 릴리스 명령 모두
// `--build-name/--build-number` 를 넘기지 않는다. 그래서 앱 버전을 Dart 에서
// 얻는 수단이 **이 상수뿐**이고, 버전을 올릴 때 두 곳을 고쳐야 한다. 빠뜨리면
// 피드백 문서의 `app.version` 이 낡은 값으로 쌓여 **어느 빌드에서 온 의견인지
// 알 수 없게 된다** — 테스트 기간에 그것이 가장 중요한 단서다.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:aws_docs/app_version.dart';

void main() {
  test('kAppVersion 이 pubspec 의 version 과 같다', () {
    final m = RegExp(r'^version:\s*(\S+)', multiLine: true)
        .firstMatch(File('pubspec.yaml').readAsStringSync());
    expect(m, isNotNull, reason: 'pubspec 에서 version 을 읽지 못했다');
    expect(kAppVersion, m!.group(1));
  });
}
