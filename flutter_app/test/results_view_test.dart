import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/content/quiz_widgets.dart';
import 'package:aws_docs/models/question.dart';
import 'package:aws_docs/theme/app_theme.dart';

/// 통합 모의고사처럼 bank.examGuideTaskId는 synthetic이지만
/// 문항별 examGuideTaskId는 실제 Task인 혼합 뱅크.
QuestionBank _mixedBank() => const QuestionBank(
      examGuideTaskId: 'CLF-C02-mock', // synthetic wrapper id
      taskTitle: '통합 모의고사',
      certCode: 'CLF-C02',
      domain: 0,
      questions: [
        Question(
            id: 'q1',
            examGuideTaskId: 'clf-t1-1', // 실제 Task
            skill: 'VPC 피어링',
            stem: '오답이고 개념 있음',
            options: ['알파', '베타'],
            correct: 0, // picked 1 → 오답
            explanation: 'e',
            wrongExplanations: {},
            sources: [],
            verified: true),
        Question(
            id: 'q2',
            examGuideTaskId: 'clf-t2-2',
            skill: 'IAM',
            stem: '정답',
            options: ['감마', '델타'],
            correct: 1, // picked 1 → 정답
            explanation: 'e',
            wrongExplanations: {},
            sources: [],
            verified: true),
        Question(
            id: 'q3',
            examGuideTaskId: 'clf-t3-3',
            skill: '', // 무태그
            stem: '오답이지만 개념 없음',
            options: ['엡실론', '제타'],
            correct: 0, // picked 1 → 오답
            explanation: 'e',
            wrongExplanations: {},
            sources: [],
            verified: true),
      ],
    );

Widget _host(Widget child) => MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: SingleChildScrollView(child: child)));

void main() {
  testWidgets('오답+개념 → 칩+학습링크, 정답·무태그 제외, 실제 taskId 전달',
      (tester) async {
    String? openedTask;
    String? openedSection;
    await tester.pumpWidget(_host(ResultsView(
      bank: _mixedBank(),
      picked: const {0: 1, 1: 1, 2: 1}, // q1 오답, q2 정답, q3 오답
      onOpenStudy: (t, s) { openedTask = t; openedSection = s; },
    )));

    expect(find.text('VPC 피어링'), findsOneWidget); // 오답 개념 칩
    expect(find.text('IAM'), findsNothing); // 정답은 칩 없음
    expect(find.text('→ 학습문서'), findsOneWidget); // q1만(q3 무태그 제외)

    await tester.ensureVisible(find.text('→ 학습문서'));
    await tester.tap(find.text('→ 학습문서'));
    expect(openedTask, 'clf-t1-1'); // synthetic 'CLF-C02-mock' 아닌 문항별 실제 Task
    expect(openedSection, ''); // q1 fixture에 section 없음 → 빈 문자열
  });

  testWidgets('onOpenStudy null → 칩은 보이되 학습 링크 숨김', (tester) async {
    await tester.pumpWidget(_host(ResultsView(
      bank: _mixedBank(),
      picked: const {0: 1, 1: 1, 2: 1},
    )));
    expect(find.text('VPC 피어링'), findsOneWidget); // 라벨은 표시
    expect(find.text('→ 학습문서'), findsNothing); // 링크는 숨김
  });

  test('R2: withOptionOrder가 skill·examGuideTaskId 보존(셔플 회귀)', () {
    const q = Question(
        id: 'q',
        examGuideTaskId: 'clf-t1-1',
        skill: 'VPC 피어링',
        stem: 's',
        options: ['a', 'b', 'c'],
        correct: 2,
        explanation: 'e',
        wrongExplanations: {0: 'w'},
        sources: [],
        verified: true);
    final r = q.withOptionOrder([2, 0, 1]);
    expect(r.skill, 'VPC 피어링');
    expect(r.examGuideTaskId, 'clf-t1-1');
    expect(r.correct, 0); // 원본 correct=2 → order.indexOf(2)=0 위치로 재매핑
  });
}
