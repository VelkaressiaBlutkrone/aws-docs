import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/app_router.dart';
import 'package:aws_docs/data/cert_lookup.dart';
import 'package:aws_docs/data/content_index.dart';
import 'package:aws_docs/pages/cert_exam_page.dart';
import 'package:aws_docs/theme/app_theme.dart';
import 'package:aws_docs/theme/theme_scope.dart';

Widget _home() {
  final router = createRouter(initialLocation: '/');
  return ThemeScope(
    isDark: false,
    toggle: () {},
    child: MaterialApp.router(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
    ),
  );
}

void main() {
  testWidgets('학습문서 섹션: CLF-C02 요약 카드 + 준비 중 그룹', (tester) async {
    await tester.pumpWidget(_home());
    await tester.pump();

    // 콘텐츠 보유 자격증 요약 카드.
    expect(find.textContaining('검증 학습문서'), findsWidgets);
    // 콘텐츠 없는 자격증은 "준비 중" 그룹에.
    expect(find.text('준비 중'), findsWidgets);
    expect(find.text('DVA-C02'), findsWidgets);
  });

  testWidgets('학습문서만 cert(SAA): 학습 섹션 노출 + 문항 준비 중 라벨', (tester) async {
    await tester.pumpWidget(_home());
    await tester.pump();

    // 문항 0 cert는 '문항 준비 중' 라벨로 학습문서 섹션에 노출.
    expect(find.textContaining('문항 준비 중'), findsWidgets);
  });

  group('_Header 반응형 nav', () {
    // _Header는 private이라 HomePage(라우터 '/')를 펌프해 헤더를 관찰한다.
    Future<void> pumpAt(WidgetTester tester, double width) async {
      tester.view.physicalSize = Size(width, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_home());
      await tester.pump();
    }

    testWidgets('좁은 폭(420): 햄버거 노출', (tester) async {
      await pumpAt(tester, 420);
      expect(find.byIcon(Icons.menu), findsOneWidget);
    });

    testWidgets('넓은 폭(1200): 햄버거 없음(링크 모드)', (tester) async {
      await pumpAt(tester, 1200);
      expect(find.byIcon(Icons.menu), findsNothing);
    });

    testWidgets('좁은 폭: 햄버거 탭 → 메뉴 항목(모의고사) 추가 노출', (tester) async {
      await pumpAt(tester, 420);
      final before = find.text('모의고사').evaluate().length;
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      expect(find.text('모의고사').evaluate().length, before + 1);
    });
  });

  testWidgets('통합 모의고사 헤더는 자격증 코드 기반(브레드크럼 "코드 / 모드")', (tester) async {
    // 라우터 스택(하단 HomePage의 SelectionArea + 전환)을 피해 페이지를 직접 펌프.
    // PR4: 단일 타이틀 'CLF-C02 · 통합 모의고사' → AppHeader 브레드크럼
    // (sectionLabel 'CLF-C02' / title '통합 모의고사')로 분해 — 정보 손실 0.
    final cert = certByCode('CLF-C02')!;
    await tester.pumpWidget(
      ThemeScope(
        isDark: false,
        toggle: () {},
        child: MaterialApp(
          theme: AppTheme.light,
          home: CertExamPage(cert: cert),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('CLF-C02'), findsOneWidget);
    expect(find.text('통합 모의고사'), findsWidgets); // 헤더(+시작 화면)
  });

  testWidgets('출처 칩: 외부 링크 ↗ 아이콘 표시', (tester) async {
    await tester.pumpWidget(_home());
    await tester.pump();
    // officialSources 각 칩에 외부 단서 아이콘(north_east).
    expect(find.byIcon(Icons.north_east), findsWidgets);
  });

  testWidgets('플랜 없으면 오늘-할-일 배너 미표시', (tester) async {
    await tester.pumpWidget(_home());
    await tester.pump();
    expect(find.textContaining('오늘 학습할 항목'), findsNothing);
    expect(find.textContaining('지난 일정'), findsNothing);
  });

  testWidgets('통합 모의고사 카드: 게이트 열린 cert는 검증 문항 수, 미달 cert는 준비 중 라벨',
      (tester) async {
    await tester.pumpWidget(_home());
    await tester.pump();
    // CLF-C02·SAA-C03은 게이트가 열려 CTA가 동작하므로 검증 문항 수를 표기한다.
    expect(find.textContaining('통합 모의고사 · 검증'), findsWidgets);
    // MLA-C01은 학습 콘텐츠는 있지만 D1·D3·D4 verified가 0이라 준비 중으로 남는다.
    expect(find.text('통합 모의고사 · 준비 중'), findsWidgets);
    expect(find.text('MLA-C01'), findsWidgets);
  });

  testWidgets('통합 모의고사 직접 진입은 weighted capacity 부족 시 잠김', (tester) async {
    // 잠긴 표본은 MLA다 — SAA는 2026-10-28 t2-5 flip으로 게이트가 열렸다.
    final cert = certByCode('MLA-C01')!;
    await tester.pumpWidget(
      ThemeScope(
        isDark: false,
        toggle: () {},
        child: MaterialApp(
          theme: AppTheme.light,
          home: CertExamPage(cert: cert),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump();

    expect(find.text('MLA-C01 통합 모의고사는 아직 준비 중입니다.'), findsOneWidget);
    // ⚠️ 진행 라벨에 'D1 0/19' 같은 **지금 숫자를 박으면** 사람이 D1 Task를
    // flip하는 순간 깨진다(2026-10-27 t1-1·t1-2 flip에서 실제로 깨졌다).
    // 게이트가 잠긴 동안 "현재 집계 라벨이 그대로 렌더되는가"만 본다.
    final label = examWeightedCapacityStatus('MLA-C01').domainProgressLabel;
    expect(label, isNotEmpty);
    expect(find.textContaining(label), findsOneWidget);
    expect(find.text('시작'), findsNothing);
  });
}
