import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aws_docs/theme/app_theme.dart';

/// 시각 리펙토링 WS3 — 라우트 전환 모션 스모크 (설계 게이트: 6키 등록 어서션).
/// 웹은 호스트 OS를 TargetPlatform으로 보고하므로 6키 전부에 fade 빌더가
/// 등록돼야 한다 — 누락 시 iOS/macOS 방문자가 Cupertino 슬라이드를 본다.
void main() {
  group('pageTransitionsTheme 등록', () {
    test('TargetPlatform 6키 전부에 AppFadePageTransitionsBuilder — light/dark', () {
      for (final theme in [AppTheme.light, AppTheme.dark]) {
        final builders = theme.pageTransitionsTheme.builders;
        expect(builders.keys.toSet(), TargetPlatform.values.toSet(),
            reason: '6키 누락 시 해당 OS 방문자는 스톡 전환(슬라이드 등)을 본다');
        for (final b in builders.values) {
          expect(b, isA<AppFadePageTransitionsBuilder>());
        }
      }
    });

    test('전환 시간 — enter 200ms / exit 150ms (DESIGN.md 150–250ms)', () {
      const b = AppFadePageTransitionsBuilder();
      expect(b.transitionDuration, const Duration(milliseconds: 200));
      expect(b.reverseTransitionDuration, const Duration(milliseconds: 150));
      expect(b.transitionDuration.inMilliseconds, inInclusiveRange(150, 250));
      expect(
          b.reverseTransitionDuration.inMilliseconds, inInclusiveRange(150, 250));
    });
  });

  group('전환 적용', () {
    Widget app() => MaterialApp(
          theme: AppTheme.light,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                    builder: (_) => const Text('second-page')),
              ),
              child: const Text('go'),
            ),
          ),
        );

    testWidgets('push 전환 중 새 라우트가 FadeTransition으로 감싸인다', (tester) async {
      await tester.pumpWidget(app());
      await tester.tap(find.text('go'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100)); // 전환 중간

      expect(
        find.ancestor(
            of: find.text('second-page'),
            matching: find.byType(FadeTransition)),
        findsWidgets,
      );
      // 슬라이드 계열 스톡 전환이 아님.
      expect(
        find.ancestor(
            of: find.text('second-page'),
            matching: find.byType(SlideTransition)),
        findsNothing,
      );
      await tester.pumpAndSettle();
    });

    testWidgets('iOS 플랫폼에서도 fade — Cupertino 슬라이드 아님', (tester) async {
      // addTearDown은 invariant 검사(본문 종료 시점) 이후라 늦다 — 본문에서 복원.
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      try {
        await tester.pumpWidget(app());
        await tester.tap(find.text('go'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(
          find.ancestor(
              of: find.text('second-page'),
              matching: find.byType(SlideTransition)),
          findsNothing,
        );
        expect(
          find.ancestor(
              of: find.text('second-page'),
              matching: find.byType(FadeTransition)),
          findsWidgets,
        );
        await tester.pumpAndSettle();
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    testWidgets('MediaQuery.disableAnimations 존중 — 전환 위젯 생략', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const Text('second-page')),
            ),
            child: const Text('go'),
          ),
        ),
      ));
      await tester.tap(find.text('go'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50)); // 전환 중간

      // buildTransitions가 child를 그대로 반환 — fade 래퍼 없음.
      expect(
        find.ancestor(
            of: find.text('second-page'),
            matching: find.byType(FadeTransition)),
        findsNothing,
      );
      await tester.pumpAndSettle();
    });
  });
}
