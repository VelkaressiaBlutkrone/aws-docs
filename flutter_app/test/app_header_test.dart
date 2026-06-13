import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_test/flutter_test.dart';

import 'package:aws_docs/theme/app_theme.dart';
import 'package:aws_docs/theme/theme_scope.dart';
import 'package:aws_docs/widgets/app_header.dart';
import 'package:aws_docs/widgets/focus_ring.dart';

/// AppHeader 문서형(PR4) — 셸 56px·blur·collapse 우선순위·슬롯 규약(메타→액션→토글).
/// 와이어프레임 정답지 2번 섹션 + 인벤토리 문서
/// docs/superpowers/specs/2026-06-13-pr4-appbar-inventory.md 기준.

Widget _host(PreferredSizeWidget header,
    {bool isDark = false, VoidCallback? onToggle, Widget? body}) {
  return ThemeScope(
    isDark: isDark,
    toggle: onToggle ?? () {},
    child: MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(appBar: header, body: body ?? const SizedBox()),
    ),
  );
}

void _setWidth(WidgetTester tester, double width) {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  group('HeaderCollapse.solve — 드롭 우선순위(날짜→배지→섹션→backLabel)', () {
    test('전부 들어가면 전부 표시', () {
      final r = HeaderCollapse.solve(
          available: 1000,
          fixed: 200,
          backLabel: 60,
          section: 80,
          badge: 70,
          date: 90,
          titleMin: 200);
      expect(r.showDate, isTrue);
      expect(r.showBadge, isTrue);
      expect(r.showSection, isTrue);
      expect(r.showBackLabel, isTrue);
    });

    test('1단계: 날짜만 드롭', () {
      // 전부 = 700, 날짜 제외 = 610 ≤ 620
      final r = HeaderCollapse.solve(
          available: 620,
          fixed: 200,
          backLabel: 60,
          section: 80,
          badge: 70,
          date: 90,
          titleMin: 200);
      expect(r.showDate, isFalse);
      expect(r.showBadge, isTrue);
      expect(r.showSection, isTrue);
      expect(r.showBackLabel, isTrue);
    });

    test('2단계: 날짜+배지 드롭', () {
      final r = HeaderCollapse.solve(
          available: 545,
          fixed: 200,
          backLabel: 60,
          section: 80,
          badge: 70,
          date: 90,
          titleMin: 200);
      expect(r.showDate, isFalse);
      expect(r.showBadge, isFalse);
      expect(r.showSection, isTrue);
      expect(r.showBackLabel, isTrue);
    });

    test('3단계: 섹션 라벨까지 드롭', () {
      final r = HeaderCollapse.solve(
          available: 465,
          fixed: 200,
          backLabel: 60,
          section: 80,
          badge: 70,
          date: 90,
          titleMin: 200);
      expect(r.showSection, isFalse);
      expect(r.showBackLabel, isTrue);
    });

    test('최후: backLabel 텍스트 드롭(셰브론은 별개)', () {
      final r = HeaderCollapse.solve(
          available: 410,
          fixed: 200,
          backLabel: 60,
          section: 80,
          badge: 70,
          date: 90,
          titleMin: 200);
      expect(r.showBackLabel, isFalse);
    });

    test('없는 파트(폭 0)는 애초에 미표시', () {
      final r = HeaderCollapse.solve(
          available: 1000,
          fixed: 100,
          backLabel: 0,
          section: 0,
          badge: 0,
          date: 0,
          titleMin: 100);
      expect(r.showDate, isFalse);
      expect(r.showBadge, isFalse);
      expect(r.showSection, isFalse);
      expect(r.showBackLabel, isFalse);
    });
  });

  group('AppHeader.document — 셸', () {
    testWidgets('높이 56 + BackdropFilter(blur) 존재', (tester) async {
      _setWidth(tester, 1100);
      await tester.pumpWidget(
          _host(const AppHeader.document(title: '학습 일정')));
      final size = tester.getSize(find.byType(AppHeader));
      expect(size.height, AppHeaderShell.height);
      expect(
          find.descendant(
              of: find.byType(AppHeader),
              matching: find.byType(BackdropFilter)),
          findsOneWidget);
    });
  });

  group('AppHeader.document — 슬롯 렌더', () {
    testWidgets('와이드: 섹션 라벨 / 제목 / 메타(배지·날짜) / 토글 전부 표시',
        (tester) async {
      _setWidth(tester, 1100);
      await tester.pumpWidget(_host(const AppHeader.document(
        backLabel: 'CLF-C02',
        sectionLabel: '학습 문서',
        title: 'AWS 클라우드의 이점',
        metaBadge: '✓ 검증됨',
        metaDate: '2026-05-27',
      )));
      expect(find.text('학습 문서'), findsOneWidget);
      expect(find.text('AWS 클라우드의 이점'), findsOneWidget);
      expect(find.textContaining('✓ 검증됨'), findsOneWidget);
      expect(find.textContaining('2026-05-27'), findsOneWidget);
      expect(find.byType(ThemeToggleButton), findsOneWidget);
      // 루트(스택 없음)에선 back 셰브론·라벨 없음 — AppBar 기본과 동일.
      expect(find.byIcon(Icons.chevron_left), findsNothing);
      expect(find.text('CLF-C02'), findsNothing);
    });

    testWidgets('360px: collapse 규약 — 날짜·배지·섹션 숨고 제목은 ellipsis로 생존',
        (tester) async {
      _setWidth(tester, 360);
      await tester.pumpWidget(_host(const AppHeader.document(
        sectionLabel: '학습 문서',
        title: 'AWS 클라우드의 이점과 글로벌 인프라 구조 이해',
        metaBadge: '✓ 검증됨',
        metaDate: '2026-05-27',
      )));
      expect(tester.takeException(), isNull); // 오버플로 없음
      expect(find.textContaining('2026-05-27'), findsNothing);
      expect(find.textContaining('✓ 검증됨'), findsNothing);
      expect(find.text('학습 문서'), findsNothing);
      expect(find.textContaining('AWS 클라우드의'), findsOneWidget);
      expect(find.byType(ThemeToggleButton), findsOneWidget);
    });
  });

  group('AppHeader.document — back', () {
    testWidgets('스택이 있으면 ‹+라벨 표시, 탭하면 pop (AppBar 기본과 동일 메커니즘)',
        (tester) async {
      _setWidth(tester, 1100);
      await tester.pumpWidget(ThemeScope(
        isDark: false,
        toggle: () {},
        child: MaterialApp(
          theme: AppTheme.light,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => Scaffold(
                        appBar: const AppHeader.document(
                            backLabel: 'CLF-C02', title: '오답노트'),
                        body: const SizedBox(),
                      ),
                    ),
                  ),
                  child: const Text('go'),
                ),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.text('CLF-C02'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();
      expect(find.text('go'), findsOneWidget); // 첫 페이지로 복귀
    });

    testWidgets('키보드: back에 포커스 후 Enter로 pop (DT4)', (tester) async {
      _setWidth(tester, 1100);
      await tester.pumpWidget(ThemeScope(
        isDark: false,
        toggle: () {},
        child: MaterialApp(
          theme: AppTheme.light,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => Scaffold(
                        appBar: const AppHeader.document(title: '오답노트'),
                        body: const SizedBox(),
                      ),
                    ),
                  ),
                  child: const Text('go'),
                ),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();

      // Tab 순회로 back(첫 포커서블)에 도달 → FocusRing 점등 → Enter → pop.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text('go'), findsOneWidget);
    });
  });

  group('AppHeader.document — 액션 슬롯 규약', () {
    testWidgets('순서: 메타 → 페이지 액션 → 테마 토글(맨 끝)', (tester) async {
      _setWidth(tester, 1100);
      await tester.pumpWidget(_host(AppHeader.document(
        title: '약점 리포트',
        metaBadge: '✓ 검증됨',
        actions: [
          HeaderIconButton(
            icon: Icons.delete_outline,
            tooltip: '이 자격증 학습 기록 초기화',
            onTap: () {},
          ),
        ],
      )));
      final metaX = tester.getCenter(find.textContaining('✓ 검증됨')).dx;
      final actionX =
          tester.getCenter(find.byIcon(Icons.delete_outline)).dx;
      final toggleX = tester.getCenter(find.byType(ThemeToggleButton)).dx;
      expect(metaX, lessThan(actionX));
      expect(actionX, lessThan(toggleX));
    });

    testWidgets('토글: 라이트에서 dark_mode 아이콘, 탭하면 ThemeScope.toggle 호출',
        (tester) async {
      _setWidth(tester, 1100);
      var toggled = 0;
      await tester.pumpWidget(_host(
        const AppHeader.document(title: '학습 일정'),
        onToggle: () => toggled++,
      ));
      expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);
      await tester.tap(find.byType(ThemeToggleButton));
      expect(toggled, 1);
    });

    testWidgets('back·토글은 FocusRing(focus-visible 토큰) 적용', (tester) async {
      _setWidth(tester, 1100);
      await tester.pumpWidget(
          _host(const AppHeader.document(title: '학습 일정')));
      expect(
          find.descendant(
              of: find.byType(ThemeToggleButton),
              matching: find.byType(FocusRing)),
          findsOneWidget);
    });
  });
}
