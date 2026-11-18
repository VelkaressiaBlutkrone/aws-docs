// 자격증 오디오 라우트의 자격증 전환 가드 — **`audio_lecture` 플래그를 켠 빌드 전용** (2026-11-18).
//
// 릴리스 빌드(`pages.yml`)는 `--dart-define=audio_lecture=true` 로 빌드하는데 일반 `flutter test` 는
// 그 플래그 없이 돌아, 라이브에서 쓰는 오디오 경로가 테스트되지 않았다. 그래서 이 파일은 플래그가
// 꺼져 있으면 건너뛰고, CI 가 `flutter test --dart-define=audio_lecture=true` 로 따로 돌린다
// (`release_flag_sync_test.dart` 가 그 CI 단계의 존재를 지킨다).
//
// 결함: `CertAudioPage` 는 `initState` 에서만 재생 큐를 그 자격증으로 바꾼다. 라우트에 key 가 없으면
// `/cert/CLF-C02/audio` → `/cert/SAA-C03/audio` 처럼 코드만 바뀔 때 State 가 재사용돼 큐가 CLF 로
// 남고, SAA 트랙 목록의 i 번째 행을 누르면 **CLF 큐의 i 번째 강의가 재생**된다(`pl.select(i)`).
// 재생 큐는 웹 전용이라 VM 에서는 null 이므로 큐 자체가 아니라 「State 가 새로 만들어진다(=initState 가
// 다시 돈다)」를 단정한다.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:aws_docs/app_router.dart';
import 'package:aws_docs/data/audio_runtime.dart' show audioLectureEnabled;
import 'package:aws_docs/pages/cert_audio_page.dart';
import 'package:aws_docs/theme/app_theme.dart';
import 'package:aws_docs/theme/theme_scope.dart';

Widget _app(GoRouter router) => ThemeScope(
      isDark: false,
      toggle: () {},
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();
  }
}

void main() {
  setUp(rootBundle.clear);

  testWidgets('오디오 라우트: 자격증이 바뀌면 State 를 새로 만든다(재생 큐 교체가 다시 돈다)',
      (tester) async {
    final router = createRouter(initialLocation: '/cert/CLF-C02/audio');
    await tester.pumpWidget(_app(router));
    await _settle(tester);
    expect(find.byType(CertAudioPage), findsOneWidget,
        reason: '대조군: 플래그가 켜졌다면 홈으로 리다이렉트되지 않고 오디오 화면이 렌더돼야 한다');
    final before = tester.state(find.byType(CertAudioPage));

    router.go('/cert/SAA-C03/audio');
    await tester.pump();
    await _settle(tester);

    expect(find.byType(CertAudioPage), findsOneWidget);
    expect(identical(tester.state(find.byType(CertAudioPage)), before), isFalse,
        reason: 'State 가 재사용되면 재생 큐가 이전 자격증으로 남는다');
  }, skip: !audioLectureEnabled);
}
