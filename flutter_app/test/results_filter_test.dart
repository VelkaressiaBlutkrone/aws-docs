import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/content/quiz_widgets.dart';
import 'package:aws_docs/models/question.dart';
import 'package:aws_docs/theme/app_theme.dart';

/// UX-5 / M-10 가드 — 결과 화면은 오답부터 보여 주고, 정답 카드는 접어 둔다.
///
/// 리뷰(2026-09-22 §UX-5·§M-10): 65장 카드를 정답·오답 구분 없이 `Column`에 한 번에
/// 빌드해, 모바일에서 제출 직후 수백 ms가 멈추고 "오답 12개"를 찾으려면 65장을
/// 스크롤해야 했다.

Question _q(String id, String stem, {required int correct}) => Question(
      id: id,
      examGuideTaskId: 'clf-t1-1',
      stem: stem,
      options: const ['보기 A', '보기 B'],
      correct: correct,
      explanation: '$id 해설 본문',
      wrongExplanations: const {},
      sources: const [],
      verified: true,
    );

/// 0·2번은 오답, 1·3번은 정답이 되는 뱅크(picked를 전부 0으로 줄 때).
QuestionBank _bank() => QuestionBank(
      examGuideTaskId: 'CLF-C02-mock',
      taskTitle: '통합 모의고사',
      certCode: 'CLF-C02',
      domain: 0,
      questions: [
        _q('q1', '오답 하나', correct: 1),
        _q('q2', '정답 하나', correct: 0),
        _q('q3', '오답 둘', correct: 1),
        _q('q4', '정답 둘', correct: 0),
      ],
    );

/// 전부 정답인 뱅크.
QuestionBank _allCorrect() => QuestionBank(
      examGuideTaskId: 'CLF-C02-mock',
      taskTitle: '통합 모의고사',
      certCode: 'CLF-C02',
      domain: 0,
      questions: [
        _q('q1', '정답 하나', correct: 0),
        _q('q2', '정답 둘', correct: 0),
      ],
    );

Widget _host(Widget child) => MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: SingleChildScrollView(child: child)));

const _picked = {0: 0, 1: 0, 2: 0, 3: 0};

void main() {
  testWidgets('오답이 있으면 오답만 보여 주는 것이 기본이다', (tester) async {
    await tester.pumpWidget(_host(ResultsView(bank: _bank(), picked: _picked)));

    expect(find.byType(ResultCard), findsNWidgets(2));
    expect(find.textContaining('오답 하나'), findsOneWidget);
    expect(find.textContaining('오답 둘'), findsOneWidget);
    expect(find.textContaining('정답 하나'), findsNothing);
  });

  testWidgets('필터 칩은 개수를 정직하게 적는다', (tester) async {
    await tester.pumpWidget(_host(ResultsView(
      bank: _bank(),
      picked: _picked,
      flagged: const {1},
    )));

    expect(find.text('전체 4'), findsOneWidget);
    expect(find.text('오답 2'), findsOneWidget);
    expect(find.text('플래그 1'), findsOneWidget);
  });

  testWidgets('전체로 바꾸면 정답 카드도 나오지만 접혀 있다', (tester) async {
    await tester.pumpWidget(_host(ResultsView(bank: _bank(), picked: _picked)));

    await tester.tap(find.text('전체 4'));
    await tester.pump();

    expect(find.byType(ResultCard), findsNWidgets(4));
    expect(find.textContaining('정답 하나'), findsOneWidget);
    // 접힌 정답 카드는 해설을 그리지 않는다 — 이것이 65장 일괄 렌더를 가볍게 한다.
    expect(find.text('q2 해설 본문'), findsNothing);
    // 오답 카드는 접지 않는다 — 복기해야 하는 쪽이다.
    expect(find.text('q1 해설 본문'), findsOneWidget);
  });

  testWidgets('접힌 정답 카드를 누르면 펼쳐진다', (tester) async {
    await tester.pumpWidget(_host(ResultsView(bank: _bank(), picked: _picked)));
    await tester.tap(find.text('전체 4'));
    await tester.pump();

    await tester.ensureVisible(find.textContaining('정답 하나'));
    await tester.tap(find.textContaining('정답 하나'));
    await tester.pump();

    expect(find.text('q2 해설 본문'), findsOneWidget);
  });

  testWidgets('플래그만 — 플래그한 문항만 남는다', (tester) async {
    await tester.pumpWidget(_host(ResultsView(
      bank: _bank(),
      picked: _picked,
      flagged: const {1, 2},
    )));

    await tester.tap(find.text('플래그 2'));
    await tester.pump();

    expect(find.byType(ResultCard), findsNWidgets(2));
    expect(find.textContaining('정답 하나'), findsOneWidget); // index 1
    expect(find.textContaining('오답 둘'), findsOneWidget); // index 2
    expect(find.textContaining('오답 하나'), findsNothing);
  });

  testWidgets('플래그가 없으면 플래그 칩도 없다', (tester) async {
    await tester.pumpWidget(_host(ResultsView(bank: _bank(), picked: _picked)));
    expect(find.textContaining('플래그'), findsNothing);
  });

  testWidgets('전부 정답이면 필터가 없고 전체가 보인다 — 고를 것이 없다', (tester) async {
    await tester.pumpWidget(
        _host(ResultsView(bank: _allCorrect(), picked: const {0: 0, 1: 0})));

    expect(find.text('전체 2'), findsNothing);
    expect(find.text('오답 0'), findsNothing);
    expect(find.byType(ResultCard), findsNWidgets(2));
  });

  testWidgets('⚠️ 전부 정답이면 정답 카드를 접지 않는다 — 그때 할 일은 분류가 아니라 복기다',
      (tester) async {
    // 연습 퀴즈 스펙 §9.3이 결과 화면에 "정답 라벨 + 해설 재표시"를 약속한다. 정답
    // 카드를 늘 접으면 1문항 만점 퀴즈의 결과 화면이 머리글만 남아 그 약속이 깨진다
    // (실제로 `quiz_view_test`가 이걸로 깨졌다).
    await tester.pumpWidget(
        _host(ResultsView(bank: _allCorrect(), picked: const {0: 0, 1: 0})));

    expect(find.text('q1 해설 본문'), findsOneWidget);
    expect(find.text('q2 해설 본문'), findsOneWidget);
    expect(find.byIcon(Icons.expand_more), findsNothing); // 접기 손잡이도 없다
  });

  testWidgets('오답이 섞여 있으면 정답 카드는 접는다', (tester) async {
    await tester.pumpWidget(_host(ResultsView(bank: _bank(), picked: _picked)));
    await tester.tap(find.text('전체 4'));
    await tester.pump();

    expect(find.byIcon(Icons.expand_more), findsNWidgets(2)); // 정답 2장만
  });

  testWidgets('모두 오답이면 오답만과 전체가 같지만 칩은 남는다 — 선택권을 지운다', (tester) async {
    final bank = QuestionBank(
      examGuideTaskId: 'CLF-C02-mock',
      taskTitle: '통합 모의고사',
      certCode: 'CLF-C02',
      domain: 0,
      questions: [_q('q1', '오답 하나', correct: 1)],
    );
    await tester.pumpWidget(_host(ResultsView(bank: bank, picked: const {0: 0})));

    // 전체와 오답만이 같은 집합이면 고를 것이 없다 → 칩을 그리지 않는다.
    expect(find.text('전체 1'), findsNothing);
    expect(find.byType(ResultCard), findsOneWidget);
    expect(find.text('q1 해설 본문'), findsOneWidget);
  });

  testWidgets('미응답은 오답으로 센다', (tester) async {
    await tester.pumpWidget(_host(ResultsView(
      bank: _allCorrect(),
      picked: const {0: 0}, // 1번은 미응답
    )));

    expect(find.text('오답 1'), findsOneWidget);
    expect(find.byType(ResultCard), findsOneWidget);
    expect(find.textContaining('정답 둘'), findsOneWidget); // 미응답 문항
  });
}
