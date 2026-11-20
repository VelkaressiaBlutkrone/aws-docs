// 앱 이름 「구름사다리」 일관성 가드 (2026-11-20).
//
// 이름이 여러 층에 흩어져 있다 — Play 등록명, Android 런처 이름, 웹 제목·PWA
// 매니페스트·공유 미리보기, 스플래시·헤더 워드마크, 개인정보처리방침·계정 삭제 페이지.
// 하나만 남겨도 같은 제품이 두 이름으로 보이고, Play 는 계정 삭제 페이지가
// 「스토어 등록정보에 보이는 앱·개발자 이름」을 싣도록 요구한다.
//
// 결정(사용자, 2026-11-20): Play 등록명 「구름사다리 — AWS 자격증 학습·모의고사」,
// 짧은 이름 「구름사다리」, 대상 연령 18세 이상, 워드마크는 「구름」 본문색 + 「사다리」 accent.
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aws_docs/pages/home/home_header.dart';
import 'package:aws_docs/theme/app_theme.dart';
import 'package:aws_docs/theme/theme_scope.dart';
import 'package:aws_docs/util/legal_links.dart';

const _oldName = 'AWS Docs Roadmap';

String _read(String p) => File(p).readAsStringSync();

int _u32(Uint8List b, int o) =>
    (b[o] << 24) | (b[o + 1] << 16) | (b[o + 2] << 8) | b[o + 3];

void main() {
  group('이름 상수', () {
    test('짧은 이름과 Play 등록명', () {
      expect(kAppDisplayName, '구름사다리');
      expect(kStoreListingName, '구름사다리 — AWS 자격증 학습·모의고사');
      expect(kStoreListingName, startsWith(kAppDisplayName));
    });

    // Play 앱 이름 한도 30자 — "Character limits apply to both full-width and
    // half-width characters"(support.google.com/googleplay/android-developer/answer/9859152,
    // 2026-11-20 실측). 넘기면 등록명을 그대로 넣을 수 없다.
    test('Play 등록명이 30자 이내다', () {
      expect(kStoreListingName.runes.length, lessThanOrEqualTo(30));
    });
  });

  group('옛 이름이 남지 않는다', () {
    // 대조군: 탐지가 공허하지 않다 — 옛 이름은 DESIGN.md 결정 로그에 기록으로 남는다.
    test('대조군: 탐지기가 기록 속 옛 이름은 찾는다', () {
      expect(_read('../DESIGN.md'), contains(_oldName));
    });

    test('lib · web · Android 매니페스트에 옛 이름이 없다', () {
      final files = <File>[
        ...Directory('lib')
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart')),
        ...Directory('web').listSync().whereType<File>().where(
            (f) => f.path.endsWith('.html') || f.path.endsWith('.json')),
        File('android/app/src/main/AndroidManifest.xml'),
      ];
      expect(files.length, greaterThan(50), reason: '범위가 비었다');
      final hits = [
        for (final f in files)
          if (f.readAsStringSync().contains(_oldName)) f.path,
      ];
      expect(hits, isEmpty);
    });
  });

  group('층마다 같은 이름', () {
    test('Android 런처 이름은 짧은 이름이다', () {
      expect(_read('android/app/src/main/AndroidManifest.xml'),
          contains('android:label="$kAppDisplayName"'));
    });

    test('PWA 매니페스트 — name 은 등록명, short_name 은 짧은 이름', () {
      final m = _read('web/manifest.json');
      expect(m, contains('"name": "$kStoreListingName"'));
      expect(m, contains('"short_name": "$kAppDisplayName"'));
    });

    test('웹 제목·공유 미리보기·스플래시 워드마크', () {
      final h = _read('web/index.html');
      expect(h, contains('<title>$kStoreListingName</title>'));
      expect(h, contains('<meta property="og:site_name" content="$kAppDisplayName">'));
      expect(h, contains('<meta property="og:title" content="$kStoreListingName">'));
      expect(h, contains('<meta name="apple-mobile-web-app-title" content="$kAppDisplayName">'));
      expect(h, contains('<div class="splash-wordmark">구름<span>사다리</span></div>'));
    });

    test('개인정보처리방침·계정 삭제 페이지가 등록명을 싣는다', () {
      for (final p in ['web/privacy.html', 'web/delete-account.html']) {
        expect(_read(p), contains(kStoreListingName), reason: p);
      }
    });

    test('처리방침이 대상 연령 18세 이상을 적는다', () {
      final s = _read('web/privacy.html');
      expect(s, contains('만 18세 이상'));
      expect(s, isNot(contains('만 14세')));
    });

    test('공유 미리보기 이미지 생성기가 있고 1200×630 이다', () {
      expect(File('../tool/make_og_image.py').existsSync(), isTrue,
          reason: '재현할 수 없는 바이너리를 레포에 두지 않는다');
      final b = File('web/og-image.png').readAsBytesSync();
      expect([_u32(b, 16), _u32(b, 20)], [1200, 630]);
    });
  });

  testWidgets('헤더 워드마크 — 「구름」 본문색 + 「사다리」 accent', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ThemeScope(
      isDark: false,
      toggle: () {},
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          appBar: HomeHeader(onNav: {'자격증': () {}}, onResetAll: () {}),
          body: const SizedBox(),
        ),
      ),
    ));
    final finder = find.text(kAppDisplayName);
    expect(finder, findsOneWidget);
    final text = tester.widget<Text>(finder);
    final spans = (text.textSpan! as TextSpan).children!.cast<TextSpan>();
    expect(spans.map((s) => s.text), ['구름', '사다리']);
    final c = AppTheme.light.extension<AppColors>()!;
    expect(spans[1].style!.color, c.accent);
    expect(spans[0].style?.color, isNot(c.accent));
  });
}
