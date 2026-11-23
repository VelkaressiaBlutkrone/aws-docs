// flutter_app/test/legal_pages_test.dart
//
// A8 — 개인정보처리방침 · 계정 삭제 안내 페이지 · 앱 내 링크.
//
// Play 공식 요건(User Data 정책 · 계정 삭제 요건, 2026-11-20 원문 확인):
// - 처리방침은 **공개·비지역제한 URL**이고 PDF 가 아니며 수정할 수 없어야 하고, 제목에
//   「개인정보처리방침」이 보여야 하며 **운영자 정보·연락처 / 수집 항목 / 공유 대상 /
//   보안 / 보존·삭제**를 담아야 한다. ⚠️ **앱 안에서도 링크**가 있어야 한다.
// - 계정 삭제 웹 리소스는 경로가 눈에 띄어야 하고 **스토어 앱 이름이나 개발자 이름**을
//   적어야 하며, ⚠️ **앱을 다시 설치하게 하지 않고** 삭제를 요청할 수 있어야 한다.
//
// 두 페이지는 `web/` 의 **정적 HTML**이다 — Flutter 앱(해시 라우팅·CanvasKit)은 JS 가
// 꺼진 검토자·크롤러에게 빈 화면이라, 정책 페이지가 앱 안에 있으면 「로드 오류 없음」을
// 보장할 수 없다. `flutter build web` 이 `web/` 을 그대로 `build/web/` 에 복사한다.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aws_docs/data/cloud/synced_collections.dart';
import 'package:aws_docs/pages/home/home_header.dart';
import 'package:aws_docs/theme/app_theme.dart';
import 'package:aws_docs/theme/theme_scope.dart';
import 'package:aws_docs/util/legal_links.dart';

String _read(String path) => File(path).readAsStringSync();

/// `id="name"` 를 가진 요소부터 다음 `<section` 전까지의 본문.
String _section(String html, String id) {
  final start = html.indexOf('id="$id"');
  expect(start, greaterThanOrEqualTo(0), reason: '절 id="$id" 가 없다');
  final next = html.indexOf('<section', start + 1);
  return html.substring(start, next < 0 ? html.length : next);
}

void main() {
  group('A8 처리방침 페이지', () {
    late String html;
    setUp(() => html = _read('web/privacy.html'));

    test('제목·언어가 맞고 스크립트 없이 읽힌다', () {
      expect(html, contains('<html lang="ko">'));
      expect(RegExp(r'<title>[^<]*개인정보처리방침[^<]*</title>').hasMatch(html),
          isTrue,
          reason: 'Play 요건: 제목에 「개인정보처리방침」이 보여야 한다');
      // JS 가 꺼진 검토자에게도 본문이 그대로 보여야 한다.
      expect(html.toLowerCase(), isNot(contains('<script')));
    });

    test('운영자 정보와 연락처를 적는다', () {
      final s = _section(html, 'operator');
      expect(s, contains(kOperatorName));
      expect(s, contains(kPrivacyContactEmail));
      expect(s, contains('mailto:$kPrivacyContactEmail'));
    });

    test('수집 항목을 로그인 여부로 갈라 적는다', () {
      final s = _section(html, 'collected');
      expect(s, contains('이메일'));
      expect(s, contains('사용자 ID'));
      // Firebase Authentication 공식 문서가 보안·악용 방지용으로 IP 를 수집한다고 적는다.
      expect(s, contains('IP 주소'));
      expect(s, contains('로그인하지 않'),
          reason: '로그인하지 않으면 학습 기록이 기기 밖으로 나가지 않는다는 사실');
    });

    // ⚠️ A7 의 드리프트 가드와 같은 원리다. 동기가 새 컬렉션을 쓰기 시작하면 처리방침이
    // 그 기록 종류를 적지 않은 채로 남는다 — 처리방침의 기록 목록을 기계로 맞댄다.
    test('클라우드 기록 목록이 동기 컬렉션과 같다', () {
      final records = RegExp(r'data-record="([a-z]+)"')
          .allMatches(html)
          .map((m) => m.group(1)!)
          .toSet();
      expect(records, contains('feedback'),
          reason: '보낸 의견도 기기 밖으로 나가는 기록이다');
      expect(records, isNotEmpty, reason: 'data-record 추출이 깨졌다');
      // D2 — 비교 대상은 **사용자 소유 컬렉션**이다(동기 집합 + 피드백). 처리방침은
      // 동기하는 것만이 아니라 **기기 밖으로 나가는 모든 기록**을 적어야 한다.
      expect(records, equals(kUserOwnedCollections.toSet()),
          reason: '사용자 소유 컬렉션과 처리방침이 적는 기록 종류가 다르다');
    });

    test('공유 대상(서비스 제공자)을 적는다', () {
      final s = _section(html, 'sharing');
      for (final name in [
        'Google Firebase',
        'gstatic.com',
        'Cloudflare',
        'GitHub Pages',
      ]) {
        expect(s, contains(name), reason: '$name 이 공유·처리 주체 목록에 없다');
      }
    });

    // D1 로 Android 도 강의 음성을 R2 에서 받는다. 처리방침이 「웹만」으로 남으면
    // Play 에 제출하는 공개 문서가 앱 동작과 어긋난다.
    test('Android 강의 음성 전송을 처리방침이 적는다', () {
      // 대조군: Android 앱이 실제로 미디어 재생 서비스를 선언한다.
      expect(_read('android/app/src/main/AndroidManifest.xml'),
          contains('FOREGROUND_SERVICE_MEDIA_PLAYBACK'));
      expect(html, isNot(contains('Android 앱에는 강의 음성 기능이 없습니다')));

      final collected = _section(html, 'collected');
      expect(collected, contains('강의 음성을 재생할 때'));
      expect(collected, contains('웹 앱과 Android 앱'));

      final row = RegExp(r'<tr><td>Cloudflare[^\n]*</tr>')
          .firstMatch(_section(html, 'sharing'))
          ?.group(0);
      expect(row, isNotNull, reason: 'Cloudflare 행 추출이 깨졌다');
      expect(row, contains('웹·Android'));
      expect(row, isNot(contains('웹만')));

      final transfer = _section(html, 'transfer');
      expect(transfer, contains('강의 음성 전송(Cloudflare)'));
      expect(transfer, isNot(contains('gstatic.com · Cloudflare')));
    });

    // 앱 코드가 접속하는 서비스 호스트는 처리방침에 적혀 있어야 한다. 사용자가 직접 누르는
    // 학습 자료 링크(AWS 공식 문서)는 브라우저로 여는 외부 페이지라 제외한다.
    test('앱 코드의 서비스 호스트가 처리방침에 적혀 있다', () {
      const userInitiated = {'docs.aws.amazon.com', 'aws.amazon.com'};
      final hosts = <String>{};
      for (final f in Directory('lib').listSync(recursive: true)) {
        if (f is! File || !f.path.endsWith('.dart')) continue;
        for (final m in RegExp(r'https://([a-z0-9.-]+\.[a-z]{2,})')
            .allMatches(f.readAsStringSync())) {
          hosts.add(m.group(1)!);
        }
      }
      // 대조군: 실제로 서비스 호스트를 찾았다(추출이 깨진 게 아니다).
      expect(hosts, contains('aws-audio.leva.ai.kr'));
      final service = hosts.difference(userInitiated)
        ..remove('velkaressiablutkrone.github.io'); // 이 사이트 자신
      for (final h in service) {
        expect(html, contains(h), reason: '앱이 접속하는 $h 를 처리방침이 적지 않는다');
      }
    });

    // ⚠️ 처리방침과 Data safety 초안은 「텔레메트리 SDK 0건」을 전제로 쓰였다(2026-11-20
    // `pubspec.lock` 실측). 이런 SDK 는 사용자가 아무것도 하지 않아도 기기 밖으로
    // 데이터를 보내므로, 하나라도 들어오면 두 문서가 거짓이 된다.
    test('텔레메트리 SDK가 없다 — 생기면 처리방침·Data safety를 고친다', () {
      final lock = _read('pubspec.lock');
      // 대조군: lock 을 실제로 읽었다(패키지 항목 형식이 맞다).
      expect(lock, contains('\n  firebase_auth:'));
      const telemetry = [
        'firebase_analytics',
        'firebase_crashlytics',
        'firebase_performance',
        'firebase_messaging',
        'firebase_app_installations',
        'firebase_remote_config',
        'firebase_in_app_messaging',
        'google_mobile_ads',
        'sentry_flutter',
      ];
      for (final p in telemetry) {
        expect(lock, isNot(contains('\n  $p:')),
            reason: '$p 가 들어왔다 — web/privacy.html 과 Data safety 초안을 갱신하라');
      }
    });

    test('보안 조치를 적는다', () {
      final s = _section(html, 'security');
      expect(s, contains('HTTPS'));
      expect(s, contains('본인'));
    });

    test('보존·삭제 정책을 적고 계정 삭제 안내로 잇는다', () {
      final s = _section(html, 'retention');
      expect(s, contains('delete-account.html'));
      expect(s, contains('보존'));
    });

    test('비공식 학습 도구임을 밝힌다', () {
      expect(html, contains('비공식'));
      expect(html, contains('Amazon Web Services'));
    });

    test('시행일을 적는다', () {
      expect(RegExp(r'시행일[^<]*20\d\d-\d\d-\d\d').hasMatch(html), isTrue);
    });
  });

  group('A8 계정 삭제 안내 페이지', () {
    late String html;
    setUp(() => html = _read('web/delete-account.html'));

    test('제목·앱 이름·운영자를 적고 스크립트 없이 읽힌다', () {
      expect(html, contains('<html lang="ko">'));
      expect(RegExp(r'<title>[^<]*계정 삭제[^<]*</title>').hasMatch(html), isTrue);
      expect(html, contains(kAppDisplayName),
          reason: 'Play 요건: 스토어에 보이는 앱 이름을 적어야 한다');
      expect(html, contains(kOperatorName));
      expect(html.toLowerCase(), isNot(contains('<script')));
    });

    // ⚠️ Play: "without sending the user back to the app and requiring them to
    // re-download it" — 웹 앱 경로가 앱 재설치 없이 삭제하는 길이다.
    test('앱을 다시 설치하지 않고 웹에서 지우는 경로를 적는다', () {
      // ⚠️ `contains(kSiteBase)` 로 세면 **자명하게 통과한다** — canonical 태그
      // (`…/aws-docs/delete-account.html`)가 그 문자열을 부분 문자열로 품는다.
      // 웹 앱 루트로 가는 링크 자체를 센다.
      expect(html, contains('href="$kSiteBase"'));
      expect(html, contains('기기 간 동기'));
      expect(html, contains('계정 삭제'));
    });

    test('이메일로 요청하는 경로를 적는다', () {
      expect(html, contains('mailto:$kPrivacyContactEmail'));
    });

    test('지우는 것과 남는 것을 적는다', () {
      final s = _section(html, 'scope');
      expect(s, contains('삭제'));
      expect(s, contains('남'), reason: '보존되는 것이 있으면 밝혀야 한다(Play 요건)');
    });

    // D2 — 피드백은 계정 삭제로 지워지지만, 운영자가 읽고 **검수 노트로 전사한
    // 사본**과 그로 인한 콘텐츠 정정은 사라지지 않는다. 이 기능의 목적 자체가
    // 신고를 레포 검수 흐름으로 들이는 것이므로(설계 §1) 그 예외를 공시한다 —
    // 「전사하지 않는다」는 운영 규율은 목적을 깎는다.
    test('보낸 의견이 지워지는 범위와 남는 사본을 적는다', () {
      final s = _section(html, 'scope');
      expect(s, contains('의견'), reason: '보낸 의견의 삭제 여부를 적어야 한다');
      expect(s, contains('반영'),
          reason: '운영자가 읽고 반영한 기록이 남는다는 것을 적어야 한다');
    });
  });

  group('A8 앱 내 링크', () {
    test('URL 상수가 배포 경로와 파일에 맞는다', () {
      final index = _read('web/index.html');
      expect(index, contains('href="$kSiteBase"'),
          reason: 'kSiteBase 가 index.html 의 canonical 과 다르다');
      expect(kPrivacyPolicyUrl, '${kSiteBase}privacy.html');
      expect(kAccountDeletionUrl, '${kSiteBase}delete-account.html');
      expect(File('web/privacy.html').existsSync(), isTrue);
      expect(File('web/delete-account.html').existsSync(), isTrue);
    });

    test('사이트맵에 두 페이지가 있다', () {
      final map = _read('web/sitemap.xml');
      expect(map, contains('<loc>$kPrivacyPolicyUrl</loc>'));
      expect(map, contains('<loc>$kAccountDeletionUrl</loc>'));
    });

    Widget wrap(Widget child) => ThemeScope(
          isDark: false,
          toggle: () {},
          child: MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              appBar: HomeHeader(onNav: {'자격증': () {}}, onResetAll: () {}),
              body: child,
            ),
          ),
        );

    // 라벨이 보이는 것만으로는 부족하다 — 그 항목이 **다른 동작**에 묶여도 라벨은 남는다
    // (민감도 측정에서 값만 바꾼 변이가 녹색이었다). 그래서 항목을 눌러 처리방침 URL 이
    // 실제로 열리는 데까지 본다. VM 테스트에서 url_launcher 는 기본 구현
    // `MethodChannelUrlLauncher` 를 쓰고 `plugins.flutter.io/url_launcher` 채널의
    // `launch` 에 `url` 을 넘긴다(url_launcher_platform_interface 2.3.2 소스 실측) —
    // 그 채널을 가로채 넘어간 URL 을 센다.
    // ⚠️ 처음에는 `appLog`(debugPrint) 를 셌는데 0건이었다: 핸들러가 없는 채널 응답은
    // fake async 안에서 끝나지 않아 실패 로그가 테스트 안에 찍히지 않는다.
    Future<List<String>> openFromMenu(
        WidgetTester tester, Size size, String tooltip) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      const channel = MethodChannel('plugins.flutter.io/url_launcher');
      final launched = <String>[];
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'launch') {
          launched.add((call.arguments as Map)['url'] as String);
        }
        return true;
      });
      addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
      await tester.pumpWidget(wrap(const SizedBox()));
      await tester.tap(find.byTooltip(tooltip));
      await tester.pumpAndSettle();
      expect(find.text('개인정보처리방침'), findsOneWidget);
      await tester.tap(find.text('개인정보처리방침'));
      await tester.pumpAndSettle();
      return launched;
    }

    // ⚠️ 폰 폭에서는 헤더에 설정 기어가 없고 메뉴 하나로 접힌다(A4 에뮬레이터 실측).
    testWidgets('좁은 폭: 메뉴의 처리방침 항목이 처리방침 URL 을 연다', (tester) async {
      final launched = await openFromMenu(tester, const Size(400, 800), '메뉴');
      expect(launched, [kPrivacyPolicyUrl],
          reason: '처리방침 항목이 다른 동작에 묶였다');
    });

    testWidgets('넓은 폭: 설정의 처리방침 항목이 처리방침 URL 을 연다', (tester) async {
      final launched = await openFromMenu(tester, const Size(1200, 800), '설정');
      expect(launched, [kPrivacyPolicyUrl],
          reason: '처리방침 항목이 다른 동작에 묶였다');
    });
  });
}
