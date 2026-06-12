import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aws_docs/theme/app_theme.dart';
import 'package:aws_docs/widgets/focus_ring.dart';
import 'package:aws_docs/widgets/state_views.dart';

/// 시각 리펙토링 WS4 — 공용 상태 뷰 3종.
/// SelectionArea+비동기 페이지는 위젯 테스트에서 렌더 불가(HANDOFF §1 함정)
/// → 상태 뷰를 셸 밖 단독 렌더로 가드한다.
Widget _host(Widget child) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('LoadingView', () {
    testWidgets('표시 전 150ms 유예 — 그 전에는 아무것도 그리지 않는다', (tester) async {
      await tester.pumpWidget(_host(const LoadingView(label: '불러오고 있습니다…')));
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('불러오고 있습니다…'), findsNothing);

      await tester.pump(const Duration(milliseconds: 149));
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // 잔여 타이머 소진(pending timer 누수 방지).
      await tester.pump(const Duration(milliseconds: 200));
    });

    testWidgets('150ms 후 틸 링 + 무엇을 불러오는지 한 줄이 나타난다', (tester) async {
      await tester.pumpWidget(_host(const LoadingView(label: '불러오고 있습니다…')));
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump(); // setState 반영 프레임

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('불러오고 있습니다…'), findsOneWidget);

      final ring = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator));
      expect(ring.color, AppColors.light.accent);
      expect(ring.backgroundColor, AppColors.light.accentWeak);

      await tester.pump(const Duration(milliseconds: 80)); // 페이드인 완료
    });

    testWidgets('유예 안에 해소(위젯 제거)되면 한 번도 표시되지 않는다', (tester) async {
      await tester.pumpWidget(_host(const LoadingView(label: 'x')));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.pumpWidget(_host(const Text('done')));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('done'), findsOneWidget);
    });

    testWidgets('disableAnimations에서도 정상 표시(페이드 생략)', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: const Scaffold(
            body: Center(child: LoadingView(label: '불러오고 있습니다…'))),
      ));
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump();
      expect(find.text('불러오고 있습니다…'), findsOneWidget);
    });
  });

  group('EmptyView', () {
    testWidgets('아이콘 없이 제목·설명·CTA를 렌더한다 (디자인 리뷰 2A)', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_host(EmptyView(
        title: '아직 오답이 없습니다',
        description: '연습이나 시험을 풀면 여기에 모입니다.',
        ctaLabel: '모의고사 시작하기',
        onCta: () => tapped = true,
      )));

      expect(find.text('아직 오답이 없습니다'), findsOneWidget);
      expect(find.text('연습이나 시험을 풀면 여기에 모입니다.'), findsOneWidget);
      expect(find.text('모의고사 시작하기'), findsOneWidget);
      // 빈 상태에 아이콘 금지.
      expect(
        find.descendant(
            of: find.byType(EmptyView), matching: find.byType(Icon)),
        findsNothing,
      );

      await tester.tap(find.text('모의고사 시작하기'));
      expect(tapped, isTrue);
    });

    testWidgets('CTA 없이 텍스트만으로도 렌더된다', (tester) async {
      await tester.pumpWidget(_host(const EmptyView(
        title: '검증된 문항이 아직 없습니다.',
        description: '사람 검수를 통과한 문항만 출제합니다.',
      )));
      expect(find.text('검증된 문항이 아직 없습니다.'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsNothing);
    });
  });

  group('ErrorView', () {
    testWidgets('wrong 시맨틱 아이콘 + 메시지 + 보조 설명 + 복구 경로 2개', (tester) async {
      var retried = false;
      var wentHome = false;
      await tester.pumpWidget(_host(ErrorView(
        message: '문항을 불러오지 못했습니다.',
        onRetry: () => retried = true,
        onHome: () => wentHome = true,
      )));

      expect(find.text('문항을 불러오지 못했습니다.'), findsOneWidget);
      // 공통 보조 설명(카피 매트릭스 기본값).
      expect(find.text('네트워크가 잠시 불안정했을 수 있습니다. 다시 시도하면 대부분 해결됩니다.'),
          findsOneWidget);
      expect(find.text('다시 시도'), findsOneWidget);
      expect(find.text('홈으로'), findsOneWidget);

      final icon = tester.widget<Icon>(find.descendant(
          of: find.byType(ErrorView), matching: find.byType(Icon)));
      expect(icon.color, AppColors.light.wrong);

      await tester.tap(find.text('다시 시도'));
      expect(retried, isTrue);
      await tester.tap(find.text('홈으로'));
      expect(wentHome, isTrue);
    });

    testWidgets('보조 설명을 페이지별로 교체할 수 있다', (tester) async {
      await tester.pumpWidget(_host(ErrorView(
        message: 'm',
        description: '커스텀 설명입니다.',
        onRetry: () {},
        onHome: () {},
      )));
      expect(find.text('커스텀 설명입니다.'), findsOneWidget);
    });
  });

  group('FocusRing (focus-visible 토큰)', () {
    testWidgets('자손이 포커스를 받으면 액센트 2px 링이 켜진다', (tester) async {
      final node = FocusNode();
      final other = FocusNode();
      addTearDown(node.dispose);
      addTearDown(other.dispose);
      await tester.pumpWidget(_host(Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FocusRing(
            child: TextButton(
                focusNode: node, onPressed: () {}, child: const Text('btn')),
          ),
          TextButton(
              focusNode: other, onPressed: () {}, child: const Text('other')),
        ],
      )));

      BoxDecoration ringDecoration() {
        final container = tester.widget<Container>(find
            .descendant(
                of: find.byType(FocusRing), matching: find.byType(Container))
            .first);
        return container.decoration! as BoxDecoration;
      }

      expect(ringDecoration().border!.top.color.a, 0); // 평시 투명

      node.requestFocus();
      await tester.pump();
      expect(ringDecoration().border!.top.color, AppColors.light.accent);
      expect(ringDecoration().border!.top.width, 2);

      // 포커스가 링 밖으로 이동하면 꺼진다. (포커스 적용은 마이크로태스크,
      // setState 반영은 그 다음 프레임 — pump 2회)
      other.requestFocus();
      await tester.pump();
      await tester.pump();
      expect(other.hasPrimaryFocus, isTrue);
      expect(node.hasFocus, isFalse);
      expect(ringDecoration().border!.top.color.a, 0);
    });
  });
}
