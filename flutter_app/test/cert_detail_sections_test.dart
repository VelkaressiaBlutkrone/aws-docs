import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';

import 'package:aws_docs/data/cert_lookup.dart';
import 'package:aws_docs/data/content_index.dart';
import 'package:aws_docs/data/study_progress.dart';
import 'package:aws_docs/models/exam_guide.dart';
import 'package:aws_docs/pages/cert_detail/cert_detail_bits.dart';
import 'package:aws_docs/pages/cert_detail/cert_header_section.dart';
import 'package:aws_docs/pages/cert_detail/learning_content_section.dart';
import 'package:aws_docs/pages/cert_detail/official_guide_section.dart';
import 'package:aws_docs/pages/cert_detail/summary_section.dart';
import 'package:aws_docs/theme/app_theme.dart';

/// cert_detail 분해 섹션 가드(PR4 T8) — 페이지 전체는 SelectionArea+비동기로
/// 위젯 테스트 렌더 불가하므로, 추출된 각 섹션을 셸 밖에서 단독 렌더해 가드한다.
Widget _host(Widget child) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // 에셋은 setUpAll에서 1회만 로드 — testWidgets 본문에서 실제 비동기를
  // await하면 연속 실행에서 해소가 지연/유실되어 행이 걸릴 수 있다(실측:
  // 단독 통과·파일 연속 실행 10분 타임아웃).
  late final ExamGuide guide;
  late final ExamSummary summary;
  setUpAll(() async {
    final gRaw = await rootBundle.loadString('assets/exam_guides/CLF-C02.json');
    guide = ExamGuide.fromJson(json.decode(gRaw) as Map<String, dynamic>);
    final sRaw = await rootBundle.loadString('assets/exam_summaries.json');
    final m = json.decode(sRaw) as Map<String, dynamic>;
    summary = ExamSummary.fromJson(m['CLF-C02'] as Map<String, dynamic>);
  });

  testWidgets('CertHeaderSection: 레벨·타이틀·대상 렌더(guide 없음 → 팩트 필 없음)', (
    tester,
  ) async {
    final cert = certByCode('CLF-C02')!;
    await tester.pumpWidget(_host(CertHeaderSection(cert: cert, guide: null)));
    expect(find.text(cert.title), findsOneWidget);
    expect(find.text(cert.audience), findsOneWidget);
    expect(find.textContaining('합격'), findsNothing);
  });

  testWidgets('CertHeaderSection: guide가 있으면 팩트 필(합격선 등) 노출', (tester) async {
    final cert = certByCode('CLF-C02')!;
    await tester.pumpWidget(_host(CertHeaderSection(cert: cert, guide: guide)));
    expect(find.textContaining('합격'), findsWidgets);
  });

  testWidgets('SummaryBlock: 요약본 라벨·목적·비공식 고지 렌더', (tester) async {
    await tester.pumpWidget(_host(SummaryBlock(summary: summary)));
    expect(find.text('한국어 학습 요약본'), findsOneWidget);
    expect(find.textContaining('비공식 학습 요약본'), findsOneWidget);
  });

  testWidgets('LearningContentSection: 검증 문항·오답 배지 + 약점 모의고사 잠금 라벨', (
    tester,
  ) async {
    final entries = contentFor('CLF-C02').take(2).toList();
    await tester.pumpWidget(
      _host(
        LearningContentSection(
          entries: entries,
          weakByTask: {entries.first.taskId: 2},
          attemptCount: 0,
        ),
      ),
    );
    expect(find.textContaining('검증 문항'), findsWidgets);
    expect(find.text('오답 2'), findsOneWidget);
    // 3회 게이트 잠금 카피(응시 0회).
    expect(find.textContaining('응시 기록이 3회'), findsOneWidget);
    expect(find.textContaining('오답노트 · 틀린 2문항'), findsOneWidget);
  });

  testWidgets('LearningContentSection: SAA는 응시 3회여도 capacity 부족이면 약점 모의고사 잠김', (
    tester,
  ) async {
    final entries = contentFor('SAA-C03');
    await tester.pumpWidget(
      _host(
        LearningContentSection(
          entries: entries,
          weakByTask: const {},
          attemptCount: 3,
        ),
      ),
    );
    expect(
      find.textContaining('공식 도메인 비중을 적용할 검증 문항이 더 필요합니다'),
      findsOneWidget,
    );
    expect(find.text('시작 →'), findsNothing);
  });

  testWidgets('LearningContentSection: 진행률 배너(열람 1/N) 표시', (tester) async {
    final entries = contentFor('CLF-C02').take(2).toList();
    final progress = StudyProgress.build(
      certId: 'CLF-C02',
      allTaskIds: [for (final e in entries) e.taskId],
      viewedTaskIds: {entries.first.taskId},
      history: const [],
    );
    await tester.pumpWidget(
      _host(
        LearningContentSection(
          entries: entries,
          weakByTask: const {},
          progress: progress,
          attemptCount: 0,
        ),
      ),
    );
    expect(find.text('문서 열람'), findsOneWidget);
    expect(find.text('1/2'), findsOneWidget);
  });

  testWidgets('OfficialGuideSection: 도메인 카드 + 비중 필 렌더', (tester) async {
    await tester.pumpWidget(_host(OfficialGuideSection(guide: guide)));
    expect(find.text('공식 시험 가이드'), findsOneWidget);
    expect(find.textContaining('도메인 1.'), findsOneWidget);
    expect(find.textContaining('%'), findsWidgets);
  });

  testWidgets('GuideMissing: 준비 중 안내', (tester) async {
    final cert = certByCode('SAP-C02') ?? certByCode('CLF-C02')!;
    await tester.pumpWidget(_host(GuideMissing(cert: cert)));
    expect(find.textContaining('준비 중'), findsOneWidget);
  });

  testWidgets('CodePill: 코드 텍스트 렌더(페이지 헤더 titleLeading 재사용분)', (tester) async {
    await tester.pumpWidget(_host(const CodePill('CLF-C02')));
    expect(find.text('CLF-C02'), findsOneWidget);
  });
}
