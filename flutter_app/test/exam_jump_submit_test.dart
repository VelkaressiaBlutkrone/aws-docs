import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/models/question.dart';
import 'package:aws_docs/pages/exam/exam_bits.dart';
import 'package:aws_docs/pages/exam_page.dart';
import 'package:aws_docs/theme/app_theme.dart';

/// UX-2 가드 — 제출은 어느 문항에서든 한 곳에서 닿고, 미답·플래그로 바로 점프한다.
///
/// 리뷰(2026-09-22 §UX-2): "제출"이 마지막 문항에서만 노출돼, 플래그를 복기하다
/// 30번에 있으면 65번까지 이동해야 제출할 수 있었다.

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

Future<void> _teardown(WidgetTester tester) =>
    tester.pumpWidget(const SizedBox());

Widget _exam(
  QuestionBank bank, {
  int initialIndex = 0,
  Map<int, int> picked = const {},
  Set<int> flagged = const {},
  void Function(dynamic)? onFinished,
}) {
  final started = DateTime(2026, 10, 30, 9, 0, 0);
  return _host(ExamView(
    bank: bank,
    certId: 'CLF-C02',
    taskId: 'CLF-C02-mock',
    startedAt: started,
    durationSec: 5400,
    initialIndex: initialIndex,
    initialPicked: picked,
    initialFlagged: flagged,
    now: () => started.add(const Duration(seconds: 30)),
    onFinished: onFinished == null ? null : (r) => onFinished(r),
  ));
}

/// 넓은 폭 — 요약 칩(UX-1) 없이 점프·제출만 본다.
void _wide(WidgetTester tester) {
  tester.view.physicalSize = const Size(1024, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  group('examNextIndex', () {
    test('현재 다음에서 찾는다', () {
      expect(
        examNextIndex(from: 2, total: 5, matches: (i) => i == 4),
        4,
      );
    });

    test('끝에 닿으면 처음으로 돌아 찾는다 — 복기는 순환이다', () {
      expect(
        examNextIndex(from: 4, total: 5, matches: (i) => i == 1),
        1,
      );
    });

    test('현재 위치는 후보가 아니다 — 눌러도 안 움직이는 버튼은 거짓말이다', () {
      expect(
        examNextIndex(from: 2, total: 5, matches: (i) => i == 2),
        isNull,
      );
    });

    test('후보가 없으면 null', () {
      expect(
        examNextIndex(from: 0, total: 5, matches: (_) => false),
        isNull,
      );
    });

    test('문항이 하나뿐이면 null', () {
      expect(
        examNextIndex(from: 0, total: 1, matches: (_) => true),
        isNull,
      );
    });
  });

  group('상시 제출', () {
    testWidgets('마지막이 아닌 문항에서도 제출에 닿는다', (tester) async {
      _wide(tester);
      await tester.pumpWidget(_exam(_bank(65)));
      await tester.pump();

      expect(find.text('문항 1 지문'), findsOneWidget);
      expect(
        find.descendant(
            of: find.byType(SecondaryButton), matching: find.text('제출')),
        findsOneWidget,
      );
      await _teardown(tester);
    });

    testWidgets('제출은 늘 한 곳에만 있다 — 마지막 문항에선 하단 기본 버튼', (tester) async {
      _wide(tester);
      await tester.pumpWidget(_exam(_bank(3), initialIndex: 2));
      await tester.pump();

      // 하단 기본 버튼이 '제출'로 바뀌는 문항에서는 상단 보조 제출을 숨긴다.
      expect(
        find.descendant(
            of: find.byType(SecondaryButton), matching: find.text('제출')),
        findsNothing,
      );
      expect(find.text('제출'), findsOneWidget);
      await _teardown(tester);
    });

    testWidgets('상단 제출로 바로 채점된다 — 플래그가 없으면 확인 없이', (tester) async {
      _wide(tester);
      dynamic finished;
      await tester.pumpWidget(
          _exam(_bank(65), onFinished: (r) => finished = r));
      await tester.pump();

      await tester.tap(find.descendant(
          of: find.byType(SecondaryButton), matching: find.text('제출')));
      await tester.pump();

      expect(finished, isNotNull);
      expect(find.text('결과'), findsOneWidget);
      await _teardown(tester);
    });

    testWidgets('플래그가 남아 있으면 상단 제출도 확인을 묻는다', (tester) async {
      _wide(tester);
      dynamic finished;
      await tester.pumpWidget(_exam(_bank(65),
          flagged: const {3}, onFinished: (r) => finished = r));
      await tester.pump();

      await tester.tap(find.descendant(
          of: find.byType(SecondaryButton), matching: find.text('제출')));
      await tester.pumpAndSettle();

      expect(find.text('제출할까요?'), findsOneWidget);
      expect(finished, isNull);
      await tester.tap(find.text('계속 풀기'));
      await tester.pumpAndSettle();
      expect(finished, isNull);
      await _teardown(tester);
    });
  });

  group('점프', () {
    testWidgets('다음 미답으로 — 답한 문항을 건너뛴다', (tester) async {
      _wide(tester);
      // 미답은 2·4번 인덱스(= 문항 3·5)
      await tester.pumpWidget(
          _exam(_bank(5), picked: const {0: 0, 1: 0, 3: 0}));
      await tester.pump();

      await tester.tap(find.text('다음 미답'));
      await tester.pump();
      expect(find.text('문항 3 지문'), findsOneWidget);

      await tester.tap(find.text('다음 미답'));
      await tester.pump();
      expect(find.text('문항 5 지문'), findsOneWidget);
      await _teardown(tester);
    });

    testWidgets('전부 답하면 미답 점프는 사라진다 — 못 가는 버튼을 두지 않는다', (tester) async {
      _wide(tester);
      await tester.pumpWidget(
          _exam(_bank(3), picked: const {0: 0, 1: 0, 2: 0}));
      await tester.pump();

      expect(find.text('다음 미답'), findsNothing);
      await _teardown(tester);
    });

    testWidgets('다음 플래그로 — 플래그가 없으면 버튼도 없다', (tester) async {
      _wide(tester);
      await tester.pumpWidget(_exam(_bank(5)));
      await tester.pump();

      expect(find.text('다음 플래그'), findsNothing);

      // 현재 문항을 플래그해도 "다음"이 없으므로 여전히 숨는다.
      await tester.tap(find.text('플래그'));
      await tester.pump();
      expect(find.text('다음 플래그'), findsNothing);
      await _teardown(tester);
    });

    testWidgets('다른 문항이 플래그돼 있으면 거기로 간다', (tester) async {
      _wide(tester);
      await tester.pumpWidget(_exam(_bank(5), flagged: const {3}));
      await tester.pump();

      await tester.tap(find.text('다음 플래그'));
      await tester.pump();
      expect(find.text('문항 4 지문'), findsOneWidget);
      await _teardown(tester);
    });

    testWidgets('좁은 폭에서는 요약 칩과 같은 행에 선다', (tester) async {
      tester.view.physicalSize = const Size(360, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_exam(_bank(65), flagged: const {3}));
      await tester.pump();

      expect(find.text('1 / 65 · 미답 65 · 플래그 1'), findsOneWidget);
      expect(find.text('다음 미답'), findsOneWidget);
      expect(find.text('다음 플래그'), findsOneWidget);
      await _teardown(tester);
    });
  });
}
