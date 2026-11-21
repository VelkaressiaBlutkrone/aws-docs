// flutter_app/test/notices_page_test.dart
//
// 공지 화면과 메뉴 진입점. 설계 §7-1.
//
// ⚠️ 자산 로더는 **주입**한다 — `testWidgets` 본문에서 실제 `rootBundle` 비동기를
// await 하면 파일 연속 실행에서 멈춘다(`cert_detail_sections_test` 가 같은 이유로
// `setUpAll` 에서 1회만 로드한다. 실측: 단독 통과 · 연속 실행 10분 타임아웃).
import 'dart:io';

import 'package:flutter/material.dart' hide Text;
import 'package:flutter_test/flutter_test.dart';

import 'package:aws_docs/data/local_kv.dart';
import 'package:aws_docs/data/notices.dart';
import 'package:aws_docs/pages/home/home_header.dart';
import 'package:aws_docs/pages/notices_page.dart';
import 'package:aws_docs/theme/app_theme.dart';
import 'package:aws_docs/theme/theme_scope.dart';

const _two = '''
[{"id":"n-20261202-01","date":"2026-12-02","title":"두 번째","body":"본문2"},
 {"id":"n-20261201-01","date":"2026-12-01","title":"첫 번째","body":"본문1"}]''';

Widget _wrap(Widget child) => ThemeScope(
      isDark: false,
      toggle: () {},
      child: MaterialApp(theme: AppTheme.light, home: child),
    );

Future<void> _pumpNotices(
  WidgetTester tester, {
  required String json,
  KvBackend? backend,
}) async {
  await tester.pumpWidget(_wrap(NoticesPage(
    loadString: (_) async => json,
    backend: backend ?? MemoryBackend(),
  )));
  await tester.pumpAndSettle();
}

/// 메뉴를 열고 공지 항목을 누른다. **라벨이 보이는 것만으로는 부족하다** — 그
/// 항목이 다른 동작에 묶여도 라벨은 남는다(`legal_pages_test` 의 민감도 측정
/// 교훈). 콜백이 불렸는지까지 센다.
Future<int> _tapNoticesInMenu(
  WidgetTester tester,
  Size size,
  String tooltip, {
  int unread = 0,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  var opened = 0;
  await tester.pumpWidget(_wrap(Scaffold(
    appBar: HomeHeader(
      onNav: {'자격증': () {}},
      onResetAll: () {},
      onOpenNotices: () => opened++,
      noticeUnread: unread,
    ),
    body: const SizedBox(),
  )));
  await tester.tap(find.byTooltip(tooltip));
  await tester.pumpAndSettle();
  await tester.tap(find.textContaining('공지'));
  await tester.pumpAndSettle();
  return opened;
}

void main() {
  group('공지 화면', () {
    // Review Focus 1 — 빈 공지는 결함이 아니라 초기 상태다.
    testWidgets('공지가 없으면 빈 상태 문구를 보인다', (tester) async {
      await _pumpNotices(tester, json: '[]');
      expect(find.text('아직 공지가 없습니다'), findsOneWidget);
    });

    testWidgets('공지를 최신 먼저 카드로 그린다', (tester) async {
      await _pumpNotices(tester, json: _two);
      expect(find.text('두 번째'), findsOneWidget);
      expect(find.text('본문1'), findsOneWidget);
      expect(tester.getTopLeft(find.text('두 번째')).dy,
          lessThan(tester.getTopLeft(find.text('첫 번째')).dy),
          reason: '최신이 위에 와야 한다');
    });

    testWidgets('날짜를 함께 보인다', (tester) async {
      await _pumpNotices(tester, json: _two);
      expect(find.text('2026-12-02'), findsOneWidget);
    });

    testWidgets('화면을 열면 최신 id 로 읽음 표시된다', (tester) async {
      final kv = MemoryBackend()..write(kNoticeReadUpToKey, 'n-20261201-01');
      await _pumpNotices(tester, json: _two, backend: kv);
      expect(kv.read(kNoticeReadUpToKey), 'n-20261202-01');
    });

    testWidgets('공지가 없으면 읽음 표시를 쓰지 않는다', (tester) async {
      final kv = MemoryBackend();
      await _pumpNotices(tester, json: '[]', backend: kv);
      expect(kv.read(kNoticeReadUpToKey), isNull);
    });
  });

  group('메뉴 진입점', () {
    // ⚠️ 폰 폭에서는 헤더가 메뉴 하나로 접히고(툴팁 「메뉴」) 넓은 폭에는 설정
    // 기어가 따로 있다(툴팁 「설정」) — 둘 다 공지 항목을 가져야 한다.
    testWidgets('좁은 폭: 메뉴의 공지 항목이 공지 화면을 연다', (tester) async {
      expect(await _tapNoticesInMenu(tester, const Size(400, 800), '메뉴'), 1);
    });

    testWidgets('넓은 폭: 설정의 공지 항목이 공지 화면을 연다', (tester) async {
      expect(await _tapNoticesInMenu(tester, const Size(1200, 800), '설정'), 1);
    });

    testWidgets('안 읽은 수가 있으면 라벨에 함께 보인다', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_wrap(Scaffold(
        appBar: HomeHeader(
          onNav: {'자격증': () {}},
          onResetAll: () {},
          onOpenNotices: () {},
          noticeUnread: 2,
        ),
        body: const SizedBox(),
      )));
      await tester.tap(find.byTooltip('메뉴'));
      await tester.pumpAndSettle();
      expect(find.text('공지 2개'), findsOneWidget);
    });

    // 콜백이 없으면 항목을 그리지 않는다 — `onResetAll` 과 같은 규율이라 기존
    // 호출부(`legal_pages_test`·`touch_target_test`·`brand_name_test`)가 그대로 돈다.
    testWidgets('콜백을 주지 않으면 공지 항목이 없다', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_wrap(Scaffold(
        appBar: HomeHeader(onNav: {'자격증': () {}}, onResetAll: () {}),
        body: const SizedBox(),
      )));
      await tester.tap(find.byTooltip('메뉴'));
      await tester.pumpAndSettle();
      expect(find.textContaining('공지'), findsNothing);
    });
  });

  // 라우터 렌더는 자산 로드를 타므로(위 멈춤) 선언만 본다 — 라우트가 빠지면
  // 메뉴 콜백이 갈 곳이 없다.
  test('라우터에 /notices 라우트가 있다', () {
    final src = File('lib/app_router.dart').readAsStringSync();
    expect(src, contains("path: '/notices'"));
    expect(src, contains('NoticesPage'));
  });
}
