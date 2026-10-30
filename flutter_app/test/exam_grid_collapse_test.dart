import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/models/question.dart';
import 'package:aws_docs/pages/exam/exam_bits.dart';
import 'package:aws_docs/pages/exam_page.dart';
import 'package:aws_docs/theme/app_theme.dart';

/// UX-1 가드 — 768px 미만에서 문항 그리드는 접힌 채 시작하고, 요약 칩이 그 자리를 대신한다.
///
/// 리뷰(2026-09-22 §UX-1): 65칩 `Wrap`이 지문 **위**에 고정돼 360px에서 9줄(≈338px)을
/// 차지하는 바람에 문항마다 그리드를 지나쳐 스크롤해야 지문이 보였다. 데스크톱은 현행 유지.

QuestionBank _bank(int n) => QuestionBank(
      examGuideTaskId: 'clf-mock',
      taskTitle: '통합 모의고사',
      certCode: 'CLF-C02',
      domain: 0,
      questions: [
        for (var i = 0; i < n; i++)
          Question(
            id: 'q${i + 1}',
            examGuideTaskId: 'clf-mock',
            stem: '문항 ${i + 1} 지문',
            options: const ['보기 A', '보기 B'],
            correct: 0,
            explanation: '해설',
            wrongExplanations: const {1: '아니다'},
            sources: const [],
            verified: true,
          ),
      ],
    );

Widget _host(Widget child) =>
    MaterialApp(theme: AppTheme.light, home: Scaffold(body: child));

/// 제출 없이 끝나는 테스트는 1초 주기 틱이 살아 있어 "A Timer is still pending"으로
/// 깨진다 — 위젯을 교체해 `dispose`가 타이머를 정리하게 한다.
Future<void> _teardown(WidgetTester tester) =>
    tester.pumpWidget(const SizedBox());

Widget _exam(QuestionBank bank) {
  final started = DateTime(2026, 10, 30, 9, 0, 0);
  return _host(ExamView(
    bank: bank,
    certId: 'CLF-C02',
    taskId: 'CLF-C02-mock',
    startedAt: started,
    durationSec: 5400,
    now: () => started.add(const Duration(seconds: 30)),
  ));
}

void main() {
  group('examGridSummaryLabel', () {
    test('진행·미답·플래그를 한 줄로 요약한다', () {
      expect(
        examGridSummaryLabel(index: 11, total: 65, answered: 57, flagged: 3),
        '12 / 65 · 미답 8 · 플래그 3',
      );
    });

    test('플래그가 없으면 그 절을 적지 않는다 — 0을 보여 주는 것은 소음이다', () {
      expect(
        examGridSummaryLabel(index: 0, total: 65, answered: 0, flagged: 0),
        '1 / 65 · 미답 65',
      );
    });

    test('전부 답했으면 미답 0을 정직하게 적는다', () {
      expect(
        examGridSummaryLabel(index: 64, total: 65, answered: 65, flagged: 0),
        '65 / 65 · 미답 0',
      );
    });
  });

  group('좁은 폭(360px)', () {
    testWidgets('그리드는 접힌 채 시작하고 요약 칩이 그 자리에 선다', (tester) async {
      tester.view.physicalSize = const Size(360, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_exam(_bank(65)));
      await tester.pump();

      expect(find.byType(GridChip), findsNothing);
      expect(find.text('1 / 65 · 미답 65'), findsOneWidget);
      await _teardown(tester);
    });

    testWidgets('요약 칩을 누르면 65칩이 펼쳐진다', (tester) async {
      tester.view.physicalSize = const Size(360, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_exam(_bank(65)));
      await tester.pump();

      await tester.tap(find.text('1 / 65 · 미답 65'));
      await tester.pumpAndSettle();

      expect(find.byType(GridChip), findsNWidgets(65));
      // 칩은 토글이다 — 다시 누르면 접힌다.
      await tester.tap(find.text('1 / 65 · 미답 65'));
      await tester.pumpAndSettle();
      expect(find.byType(GridChip), findsNothing);
      await _teardown(tester);
    });

    testWidgets('상단 행의 진행 표시는 요약 칩과 중복되지 않는다', (tester) async {
      tester.view.physicalSize = const Size(360, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_exam(_bank(65)));
      await tester.pump();

      // 좁은 폭에서는 진행이 요약 칩 한 곳에만 있다(상단은 타이머만).
      expect(find.text('1 / 65'), findsNothing);
      // 타이머는 mm:ss다(시 단위 없음) — 5400 - 30 = 5370초 = 89:30.
      expect(find.text('89:30'), findsOneWidget);
      await _teardown(tester);
    });
  });

  group('넓은 폭(768px 이상)', () {
    testWidgets('그리드는 즉시 노출되고 요약 칩은 없다 — 현행 유지', (tester) async {
      tester.view.physicalSize = const Size(1024, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_exam(_bank(65)));
      await tester.pump();

      expect(find.byType(GridChip), findsNWidgets(65));
      expect(find.text('1 / 65 · 미답 65'), findsNothing);
      expect(find.text('1 / 65'), findsOneWidget); // 상단 행 진행 표시 유지
      await _teardown(tester);
    });

    testWidgets('정확히 768px은 데스크톱으로 판정한다', (tester) async {
      tester.view.physicalSize = const Size(768, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_exam(_bank(65)));
      await tester.pump();

      expect(find.byType(GridChip), findsNWidgets(65));
      await _teardown(tester);
    });
  });
}
