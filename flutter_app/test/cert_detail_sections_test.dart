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

/// cert_detail 분해 섹션 가드(PR4 T8) — 추출된 각 섹션을 셸 밖에서 단독 렌더해 가드한다.
///
/// ⚠️ 여기 있던 "페이지 전체는 SelectionArea+비동기로 위젯 테스트 렌더 불가" 단정은
/// **틀렸다**(2026-10-30 실측) — `ThemeScope`로 감싸면 `CertDetailPage`도 직접 뜬다
/// (`test/resume_exam_card_test.dart`의 상세 배선 테스트가 그렇게 돈다. `CertExamPage`가
/// 2026-10-24에 같은 정정을 받았다). 섹션 단독 렌더 방식 자체는 그대로 둔다 — 섹션별
/// 입력 조합을 짚는 데는 에셋 로드 없이 도는 이 방식이 더 싸다.
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

  testWidgets('LearningContentSection: 응시 3회여도 capacity 부족이면 약점 모의고사 잠김', (
    tester,
  ) async {
    // ⚠️ **실제 cert의 verified 수량에 묶지 않는다.** 이 위젯은
    // `entries.any((e) => e.questionCount > 0)` 로 약점 모의고사 줄을 그릴지
    // 정하지만, **잠금 여부는 전역 인덱스**를 읽는 `certExamHasWeightedCapacity(certCode)`
    // 가 정한다 — 그래서 합성 엔트리만으로는 표본 cert 의 flip 에서 풀리지 않는다
    // (2026-10-29 양쪽 개방 시뮬레이션에서 이 테스트가 실제로 깨졌다. 표본이
    // SAA → MLA → DEA 로 두 번 이사한 뒤 "해소됐다"고 적혀 있었지만 아니었다).
    // 같은 엔트리를 `debugContentIndexOverride` 로도 주입해 **두 경로가 같은
    // 상태를 보게** 해야 비로소 cert 와 무관해진다.
    const entries = [
      ContentEntry(
        certCode: 'CLF-C02',
        taskId: 'clf-t1-1',
        title: '합성 엔트리(문항 보유·비중 미달)',
        domain: 1,
        mdAsset: 'assets/content/clf/clf-t1-1.md',
        questionsAsset: 'assets/content/clf/clf-t1-1.questions.json',
        questionCount: 15,
      ),
    ];
    debugContentIndexOverride = const {'CLF-C02': entries};
    addTearDown(() => debugContentIndexOverride = null);
    expect(certExamHasWeightedCapacity('CLF-C02'), isFalse,
        reason: '주입이 먹지 않으면 아래 잠금 단정이 거짓 통과한다');

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
