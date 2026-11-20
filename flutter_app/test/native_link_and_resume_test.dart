// 네이티브 외부 링크·앱 복귀 신호 가드 (A5, 2026-11-19).
//
// 둘 다 네이티브에서 **아무 동작도 하지 않았다** — `open_link_stub.dart` 는
// `void openLink(String url) {}`, `app_resume_stub.dart` 는 `const Stream<void>.empty()`.
// Android 에서 히어로 출처 칩을 눌러도 반응이 없고 앱 복귀 시 동기가 돌지 않았다.
//
// ⚠️ 조건부 분기는 **순서가 계약**이다. `dart.library.js_interop` 이 먼저여야 웹이 web 판을
// 고르고, 네이티브가 `dart.library.io` 판을 고른다. io 판이 웹 빌드에 들어가면
// `url_launcher` 의 플랫폼 코드가 끌려와 빌드가 깨진다.
//
// ⚠️ VM 테스트는 **io 판**을 고른다. 그래서 `openLink` 를 부르면 플랫폼 채널이 없어
// `MissingPluginException` 이 난다 — 구현이 그것을 잡아 **예외를 전파하지 않되 삼키지도
// 않아야**(로그) 한다. 아래 동작 테스트가 그 계약을 고정한다.
import 'dart:io';

import 'package:aws_docs/data/cloud/app_resume.dart';
import 'package:aws_docs/util/open_link.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

String _read(String path) => File(path).readAsStringSync();

void main() {
  test('대조군: 조건부 분기 파일을 읽었다', () {
    expect(_read('lib/util/open_link.dart'), contains('export '));
    expect(_read('lib/data/cloud/app_resume.dart'), contains('export '));
  });

  test('open_link 가 웹·네이티브·스텁 세 갈래이고 순서가 맞다', () {
    final src = _read('lib/util/open_link.dart');
    final web = src.indexOf('dart.library.js_interop');
    final io = src.indexOf('dart.library.io');
    expect(web, greaterThan(-1), reason: '웹 분기가 사라졌다');
    expect(io, greaterThan(-1), reason: '네이티브 분기가 없으면 Android 에서 링크가 안 열린다');
    expect(web, lessThan(io), reason: 'js_interop 분기가 먼저여야 웹이 web 판을 고른다');
    expect(src, contains('open_link_stub.dart'));
  });

  test('app_resume 이 웹·네이티브·스텁 세 갈래이고 순서가 맞다', () {
    final src = _read('lib/data/cloud/app_resume.dart');
    final web = src.indexOf('dart.library.js_interop');
    final io = src.indexOf('dart.library.io');
    expect(web, greaterThan(-1));
    expect(io, greaterThan(-1), reason: '네이티브 분기가 없으면 복귀 시 동기가 돌지 않는다');
    expect(web, lessThan(io));
    expect(src, contains('app_resume_stub.dart'));
  });

  test('네이티브 링크가 브라우저로 연다(앱 내 웹뷰가 아니다)', () {
    // 로드맵 A5 의 완료 기준이 "히어로 출처 링크가 **브라우저로** 열린다" 이다.
    final src = _read('lib/util/open_link_io.dart');
    expect(src, contains('LaunchMode.externalApplication'),
        reason: '기본 모드는 플랫폼이 정해 앱 내 웹뷰가 될 수 있다');
  });

  test('네이티브 링크가 실패를 삼키지 않는다', () {
    final src = _read('lib/util/open_link_io.dart');
    expect(src, contains('appLog'),
        reason: '조용히 실패하면 링크가 안 열리는 것을 아무도 모른다');
  });

  test('openLink 는 플랫폼 채널이 없어도 예외를 전파하지 않는다', () async {
    // VM 에는 url_launcher 의 플랫폼 구현이 없다. 호출부가
    // `onTap: () => openLink(widget.href)` 라 동기 void 계약도 함께 지킨다.
    expect(() => openLink('https://example.com/'), returnsNormally);
    // 비동기 쪽으로 샌 예외가 있으면 이 pump 뒤 테스트가 실패한다.
    await Future<void>.delayed(Duration.zero);
  });

  testWidgets('비활성 → 재개 전이에서 복귀 신호가 1회 나온다', (tester) async {
    final events = <void>[];
    final sub = appResumeSignal().listen(events.add);
    addTearDown(sub.cancel);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(events, hasLength(1));
  });

  testWidgets('전이가 반복되면 그만큼 나온다', (tester) async {
    final events = <void>[];
    final sub = appResumeSignal().listen(events.add);
    addTearDown(sub.cancel);

    for (var i = 0; i < 3; i++) {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    }
    await tester.pump();

    expect(events, hasLength(3));
  });

  testWidgets('broadcast 라 구독이 둘이어도 각자 받는다', (tester) async {
    // `SyncController` 는 start() 에서 한 번 구독하지만, 스트림이 single-subscription
    // 이면 재시작·테스트에서 "Stream has already been listened to" 로 깨진다.
    final stream = appResumeSignal();
    final a = <void>[], b = <void>[];
    final subA = stream.listen(a.add);
    final subB = stream.listen(b.add);
    addTearDown(() async {
      await subA.cancel();
      await subB.cancel();
    });

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(a, hasLength(1));
    expect(b, hasLength(1));
  });
}
