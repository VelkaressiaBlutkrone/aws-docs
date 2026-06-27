import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/pages/audio_hub_page.dart';
import 'package:aws_docs/theme/app_theme.dart';

// 허브 페이지 전체는 AppHeader(ThemeScope 의존)·글래스 헤더 때문에 위젯
// 테스트에서 렌더되지 않는다(SelectionArea 함정 부류). 표시 책임은 평문
// 인터페이스의 AudioCertCard로 분리돼 카드 단독으로 검증한다.
Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(child: SizedBox(width: 400, child: child)),
        ),
      ),
    );

void main() {
  testWidgets('카드는 자격증 표시명(title)을 제목으로 보여준다', (tester) async {
    await _pump(
      tester,
      const AudioCertCard(
        title: 'AWS Certified Cloud Practitioner',
        code: 'CLF-C02',
        count: 19,
        onTap: _noop,
      ),
    );
    expect(find.text('AWS Certified Cloud Practitioner'), findsOneWidget);
  });

  testWidgets('카드는 코드·강의 개수를 보조로 보여준다', (tester) async {
    await _pump(
      tester,
      const AudioCertCard(
        title: 'AWS Certified Cloud Practitioner',
        code: 'CLF-C02',
        count: 19,
        onTap: _noop,
      ),
    );
    expect(find.text('CLF-C02 · 강의 19개'), findsOneWidget);
  });

  testWidgets('탭하면 onTap 호출', (tester) async {
    var tapped = false;
    await _pump(
      tester,
      AudioCertCard(
        title: 'AWS Certified Cloud Practitioner',
        code: 'CLF-C02',
        count: 19,
        onTap: () => tapped = true,
      ),
    );
    await tester.tap(find.text('AWS Certified Cloud Practitioner'));
    expect(tapped, isTrue);
  });
}

void _noop() {}
