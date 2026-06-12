import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/main.dart';

void main() {
  tearDown(() => syncController.value = null);

  test('후행 init 예외: 로컬 전용 degrade — 컨트롤러 null 유지 + 로깅', () async {
    final logs = <String>[];
    final orig = debugPrint;
    debugPrint = (m, {wrapWidth}) => logs.add(m ?? '');
    addTearDown(() => debugPrint = orig);

    await initCloudSync(init: () async => throw StateError('boom'));

    expect(syncController.value, isNull);
    expect(logs.join('\n'), contains('boom'));
  });

  test('미설정(false): 컨트롤러 미생성 — 기존 graceful degrade 계약 유지', () async {
    await initCloudSync(init: () async => false);
    expect(syncController.value, isNull);
  });
}
