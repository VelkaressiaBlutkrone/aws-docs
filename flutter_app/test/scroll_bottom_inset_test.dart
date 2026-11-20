import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/models/question.dart';
import 'package:aws_docs/pages/exam_page.dart';
import 'package:aws_docs/theme/app_theme.dart';
import 'package:aws_docs/widgets/app_header.dart';

/// A6-2 — 스크롤 끝에서 마지막 요소가 시스템 바에 가리지 않게.
///
/// 레포는 **상단** 시스템·헤더 인셋을 [headerScrollInset]으로 여덟 파일에서 일관되게
/// 처리하는데 **하단 짝이 없었다.** 그래서 스크롤을 끝까지 내리면 마지막 요소가
/// 내비게이션 바 밑에 깔린다.
///
/// ⚠️ 2026-11-19 실측이 점검 문서의 판정을 둘 바로잡았다 — 침범은 **기본 글자 크기에서도
/// 스크롤 중간이면** 생기고(문서는 최상단 한 위치만 봤다), 침범량이 늘 정확히 inset
/// 전체(제스처 63px)인 것은 **스크롤 콘텐츠가 뷰포트 바닥까지 그려지는 정상 동작**이다
/// (제스처 바 안쪽을 눌러도 탭이 먹는다 — 시스템은 스와이프만 가로챈다).
/// 그러므로 고칠 것은 「침범 0건」이 아니라 **스크롤 끝의 여백**이고, 기준은 제스처
/// 24dp가 아니라 **3버튼 내비의 48dp**다(실측 inset 126px, 실제 바가 화면을 가린다).
void main() {
  group('scrollBottomInset — 헬퍼', () {
    testWidgets('시스템 바 인셋 + gap을 돌려준다', (tester) async {
      expect(await _inset(tester, const EdgeInsets.only(bottom: 24)),
          24 + Gap.xl);
    });

    testWidgets('인셋이 없으면 gap만 — 웹이 이 경우다', (tester) async {
      expect(await _inset(tester, EdgeInsets.zero), Gap.xl);
    });

    testWidgets('gap 0이면 인셋만', (tester) async {
      expect(
          await _inset(tester, const EdgeInsets.only(bottom: 48), gap: 0), 48);
    });

    testWidgets('3버튼 내비(48dp)와 제스처(24dp)를 그대로 따른다', (tester) async {
      expect(await _inset(tester, const EdgeInsets.only(bottom: 126), gap: 0),
          126);
    });
  });

  group('스크롤 뷰 — 주입한 인셋이 하단 패딩에 실린다', () {
    testWidgets('시험 러너(exam_view)', (tester) async {
      await tester.pumpWidget(_host(
        ExamView(
          bank: _bank(),
          certId: 'CLF-C02',
          taskId: 'clf-t2-3',
          startedAt: _started,
          durationSec: 600,
          // now 를 주지 않으면 기본값이 실제 현재 시각이라 제한 시간이 이미 지나
          // **결과 화면으로 렌더된다** — 러너를 재려면 반드시 고정해야 한다(실측).
          now: () => _started.add(const Duration(seconds: 30)),
          onFinished: (_) {},
        ),
        bottom: 48,
      ));
      await tester.pump();
      _expectBottom(tester, Gap.xl + 48);
    });

    testWidgets('시험 결과 화면도 같다', (tester) async {
      await tester.pumpWidget(_host(
        ExamView(
          bank: _bank(),
          certId: 'CLF-C02',
          taskId: 'clf-t2-3',
          startedAt: _started,
          durationSec: 600,
          // now 를 주지 않으면 기본값이 실제 현재 시각이라 제한 시간이 이미 지나
          // **결과 화면으로 렌더된다** — 러너를 재려면 반드시 고정해야 한다(실측).
          now: () => _started.add(const Duration(seconds: 30)),
          onFinished: (_) {},
        ),
        bottom: 48,
      ));
      await tester.pump();
      await tester.tap(find.text('계정 해지'));
      await tester.pump();
      await tester.tap(find.text('제출'));
      await tester.pumpAndSettle();
      _expectBottom(tester, Gap.xl + 48);
    });

    testWidgets('대조군: 인셋이 0이면 기존 값 그대로다(웹 시각 변화 0)',
        (tester) async {
      await tester.pumpWidget(_host(
        ExamView(
          bank: _bank(),
          certId: 'CLF-C02',
          taskId: 'clf-t2-3',
          startedAt: _started,
          durationSec: 600,
          // now 를 주지 않으면 기본값이 실제 현재 시각이라 제한 시간이 이미 지나
          // **결과 화면으로 렌더된다** — 러너를 재려면 반드시 고정해야 한다(실측).
          now: () => _started.add(const Duration(seconds: 30)),
          onFinished: (_) {},
        ),
        bottom: 0,
      ));
      await tester.pump();
      _expectBottom(tester, Gap.xl);
    });
  });

  group('적용 전수 — 스크롤 뷰를 가진 라우트', () {
    // 파일 -> 그 파일에서 기대하는 scrollBottomInset 호출 수.
    // ⚠️ 스크롤 뷰를 새로 만들면 이 표에 더한다. 빠뜨리면 그 라우트만 조용히
    // 시스템 바에 깔리므로, 수를 박아 두어 늘거나 줄면 알려 준다.
    const sites = <String, int>{
      'lib/pages/home_page.dart': 1,
      'lib/pages/cert_detail_page.dart': 1,
      'lib/pages/study_doc_page.dart': 1,
      'lib/pages/quiz_page.dart': 2,
      'lib/pages/review_page.dart': 1,
      'lib/pages/report_page.dart': 1,
      'lib/pages/exam/exam_view.dart': 2,
      'lib/pages/plan/plan_list_view.dart': 1,
      'lib/pages/audio_hub_page.dart': 1,
      'lib/pages/cert_exam_page.dart': 1,
    };

    test('대조군: 목록의 파일이 모두 스크롤 뷰를 갖는다', () {
      for (final path in sites.keys) {
        final String src = File(path).readAsStringSync();
        expect(
            src.contains('SingleChildScrollView') ||
                src.contains('ListView') ||
                src.contains('CustomScrollView'),
            isTrue,
            reason: '$path 가 스크롤 뷰를 갖지 않는다 — 목록이 낡았다');
      }
    });

    sites.forEach((path, count) {
      test('$path — scrollBottomInset $count곳', () {
        final String src = File(path).readAsStringSync();
        expect('scrollBottomInset('.allMatches(src).length, count);
      });
    });

    test('자격증 오디오는 bottomNavigationBar가 인셋을 먹는다 — 적용 대상이 아니다',
        () {
      final String src = File('lib/pages/cert_audio_page.dart').readAsStringSync();
      expect(src, contains('bottomNavigationBar'));
      expect(src, isNot(contains('scrollBottomInset')),
          reason: '트랜스포트 바가 SafeArea(top:false)로 이미 처리한다 — '
              '여기서 또 더하면 이중 여백이다');
      expect(File('lib/widgets/lecture_transport_bar.dart').readAsStringSync(),
          contains('SafeArea'));
    });
  });
}

Future<double> _inset(WidgetTester tester, EdgeInsets padding,
    {double? gap}) async {
  double? got;
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.light,
    home: MediaQuery(
      data: MediaQueryData(padding: padding),
      child: Builder(builder: (context) {
        got = gap == null
            ? scrollBottomInset(context)
            : scrollBottomInset(context, gap: gap);
        return const SizedBox();
      }),
    ),
  ));
  return got!;
}

Widget _host(Widget child, {required double bottom}) => MaterialApp(
      theme: AppTheme.light,
      home: MediaQuery(
        data: MediaQueryData(padding: EdgeInsets.only(bottom: bottom)),
        child: Scaffold(body: child),
      ),
    );

void _expectBottom(WidgetTester tester, double expected) {
  final Iterable<SingleChildScrollView> views = tester
      .widgetList<SingleChildScrollView>(find.byType(SingleChildScrollView));
  expect(views, isNotEmpty);
  expect(
      views.any((v) => v.padding?.resolve(TextDirection.ltr).bottom == expected),
      isTrue,
      reason: '스크롤 뷰의 하단 패딩이 $expected 이어야 한다 — 실제: '
          '${views.map((v) => v.padding?.resolve(TextDirection.ltr).bottom).toList()}');
}

final DateTime _started = DateTime(2026, 6, 6);

QuestionBank _bank() => const QuestionBank(
      examGuideTaskId: 'clf-t2-3',
      taskTitle: '접근 관리',
      certCode: 'CLF-C02',
      domain: 2,
      questions: [
        Question(
            id: 'q1',
            examGuideTaskId: 'clf-t2-3',
            stem: '루트 전용 작업은?',
            options: ['EC2 시작', '계정 해지'],
            correct: 1,
            explanation: '계정 해지는 루트 전용.',
            wrongExplanations: {0: 'EC2는 일상.'},
            sources: [],
            verified: true),
      ],
    );
