import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aws_docs/data/cert_lifecycle.dart';
import 'package:aws_docs/data/cert_lookup.dart';
import 'package:aws_docs/pages/cert_detail/cert_header_section.dart';
import 'package:aws_docs/pages/home/content_cert_card.dart';
import 'package:aws_docs/pages/home/levels_section.dart';
import 'package:aws_docs/theme/app_theme.dart';

Widget _host(Widget child) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  tearDown(() => certLifecycleClock = DateTime.now);

  group('수명 판정', () {
    test('현행 시험에는 안내가 없다(대조군)', () {
      for (final code in ['CLF-C02', 'SAA-C03', 'SCS-C03', 'DOP-C02']) {
        expect(certLifecycleNotice(code, DateTime(2026, 11, 22)), isNull);
      }
    });

    test('안내 대상은 정확히 네 자격증이고 전부 앱에 등재돼 있다', () {
      expect(kCertLifecycles.keys.toSet(), {
        'SAP-C02',
        'DVA-C02',
        'ANS-C01',
        'MLA-C01',
      });
      for (final code in kCertLifecycles.keys) {
        expect(certByCode(code), isNotNull, reason: code);
      }
    });

    test('마지막 응시일 당일 밤까지는 응시 가능이고 다음 날 종료다', () {
      final last = certLifecycleNotice('ANS-C01', DateTime(2026, 12, 31, 23, 59))!;
      expect(last.phase, CertLifecyclePhase.upcoming);
      expect(last.badge, '12월 31일까지 응시');

      final next = certLifecycleNotice('ANS-C01', DateTime(2027, 1, 1))!;
      expect(next.phase, CertLifecyclePhase.ended);
      expect(next.badge, '응시 종료');
    });

    test('SAP-C02는 종료 상태이고 후속 시험과 내용 기준을 밝힌다', () {
      final n = certLifecycleNotice('SAP-C02', DateTime(2026, 11, 22))!;
      expect(n.phase, CertLifecyclePhase.ended);
      expect(n.message, contains('2026년 11월 16일'));
      expect(n.message, contains('SAP-C03'));
      expect(n.message, contains('SAP-C02 기준'));
    });

    test('DVA-C02는 11월 30일까지 응시 가능으로 표시한다', () {
      final n = certLifecycleNotice('DVA-C02', DateTime(2026, 11, 30))!;
      expect(n.phase, CertLifecyclePhase.upcoming);
      expect(n.message, contains('DVA-C03'));
      expect(
        certLifecycleNotice('DVA-C02', DateTime(2026, 12, 1))!.phase,
        CertLifecyclePhase.ended,
      );
    });

    test('ANS-C01은 후속 시험이 없고 기존 자격 3년 유지를 적는다', () {
      final n = certLifecycleNotice('ANS-C01', DateTime(2026, 11, 22))!;
      expect(n.message, contains('후속 시험은 없'));
      expect(n.message, contains('3년'));
    });

    test('MLA-C01은 예정일이 지나도 종료로 단정하지 않는다', () {
      final before = certLifecycleNotice('MLA-C01', DateTime(2026, 11, 22))!;
      expect(before.phase, CertLifecyclePhase.upcoming);
      expect(before.message, contains('정식 출시 전까지'));
      expect(before.message, contains('예정일은 2027년 1월 14일'));
      expect(before.message, contains('확정일이 없'));

      final after = certLifecycleNotice('MLA-C01', DateTime(2027, 1, 15))!;
      expect(after.phase, CertLifecyclePhase.needsConfirmation);
      expect(after.badge, isNot('응시 종료'));
      expect(after.message, contains('공식 페이지에서 확인'));
    });

    test('모든 안내가 공식 https 출처를 가진다', () {
      for (final l in kCertLifecycles.values) {
        expect(l.sourceUrl, startsWith('https://'));
        expect(l.sourceUrl, contains('aws.amazon.com'));
      }
    });
  });

  group('화면', () {
    setUp(() => certLifecycleClock = () => DateTime(2026, 11, 22));

    testWidgets('상세 헤더가 종료 안내와 공식 링크를 보여 준다', (tester) async {
      await tester.pumpWidget(
        _host(CertHeaderSection(cert: certByCode('SAP-C02')!, guide: null)),
      );
      expect(find.textContaining('SAP-C03'), findsOneWidget);
      expect(find.text('공식 안내 보기 ↗'), findsOneWidget);
    });

    testWidgets('현행 시험의 상세 헤더에는 안내가 없다', (tester) async {
      await tester.pumpWidget(
        _host(CertHeaderSection(cert: certByCode('SAA-C03')!, guide: null)),
      );
      expect(find.text('공식 안내 보기 ↗'), findsNothing);
    });

    testWidgets('공식 링크의 탭 영역이 48dp 이상이다', (tester) async {
      await tester.pumpWidget(
        _host(CertHeaderSection(cert: certByCode('ANS-C01')!, guide: null)),
      );
      final size = tester.getSize(find.byKey(const ValueKey('cert-lifecycle-link')));
      expect(size.height, greaterThanOrEqualTo(Touch.min));
      expect(size.width, greaterThanOrEqualTo(Touch.min));
    });

    testWidgets('단계별 카드가 수명 배지를 보여 준다', (tester) async {
      tester.view.physicalSize = const Size(1400, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_host(const LevelsSection()));
      expect(find.text('응시 종료'), findsOneWidget); // SAP-C02
      expect(find.text('11월 30일까지 응시'), findsOneWidget);
      expect(find.text('12월 31일까지 응시'), findsOneWidget);
      expect(find.text('MLA-C02 전환 예정'), findsOneWidget);
    });

    testWidgets('콘텐츠 카드도 MLA-C01 배지를 보여 준다', (tester) async {
      await tester.pumpWidget(
        _host(
          ContentCertCard(
            cert: certByCode('MLA-C01')!,
            summaryLabel: '요약',
            cta: '열기',
            onTap: () {},
          ),
        ),
      );
      expect(find.text('MLA-C02 전환 예정'), findsOneWidget);
    });
  });

  test('JavaScript 없는 목록도 수명 상태를 밝힌다', () {
    final html = File('web/index.html').readAsStringSync();
    final start = html.indexOf('<noscript>');
    expect(start, greaterThan(-1));
    final noscript = html.substring(start, html.indexOf('</noscript>', start));
    final expected = {
      'SAP-C02': '2026-11-16',
      'DVA-C02': '2026-11-30',
      'ANS-C01': '2026-12-31',
      'MLA-C01': 'MLA-C02',
    };
    expected.forEach((code, token) {
      final line = RegExp('<li>[^<]*\\($code\\)[^<]*</li>').stringMatch(noscript);
      expect(line, isNotNull, reason: code);
      expect(line, contains(token), reason: code);
    });
  });
}
