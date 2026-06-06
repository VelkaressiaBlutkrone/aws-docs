import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/models/attempt_record.dart';
import 'package:aws_docs/models/question.dart';
import 'package:aws_docs/pages/exam_page.dart';
import 'package:aws_docs/theme/app_theme.dart';

QuestionBank _bank() => const QuestionBank(
      examGuideTaskId: 'clf-t2-3',
      taskTitle: '접근 관리',
      certCode: 'CLF-C02',
      domain: 2,
      questions: [
        Question(
            id: 'q1', examGuideTaskId: 'clf-t2-3', stem: '루트 전용 작업은?',
            options: ['EC2 시작', '계정 해지'], correct: 1,
            explanation: '계정 해지는 루트 전용.', wrongExplanations: {0: 'EC2는 일상.'},
            sources: [], verified: true),
        Question(
            id: 'q2', examGuideTaskId: 'clf-t2-3', stem: '최소 권한은?',
            options: ['필요한 권한만', '관리자 먼저'], correct: 0,
            explanation: '필요한 권한만.', wrongExplanations: {1: '과도.'},
            sources: [], verified: true),
      ],
    );

Widget _host(Widget child) =>
    MaterialApp(theme: AppTheme.light, home: Scaffold(body: child));

void main() {
  testWidgets('정답 선택 후 제출 → 채점, flagged 기록', (tester) async {
    AttemptRecord? finished;
    final started = DateTime(2026, 6, 6, 0, 0, 0);
    await tester.pumpWidget(_host(ExamView(
      bank: _bank(), certId: 'CLF-C02', taskId: 'clf-t2-3',
      startedAt: started, durationSec: 600,
      now: () => started.add(const Duration(seconds: 30)),
      onFinished: (r) => finished = r,
    )));
    await tester.pump();

    await tester.tap(find.text('계정 해지'));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.flag_outlined));
    await tester.pump();
    await tester.tap(find.text('다음'));
    await tester.pump();
    await tester.tap(find.text('필요한 권한만'));
    await tester.pump();
    await tester.tap(find.text('제출'));
    await tester.pump();
    await tester.tap(find.text('제출하기')); // 다이얼로그 확인
    await tester.pump();

    expect(finished, isNotNull);
    expect(finished!.mode, 'exam');
    expect(finished!.correct, 2);
    expect(finished!.wrongQuestionIds, isEmpty);
    expect(finished!.flaggedQuestionIds, ['q1']);
  });

  testWidgets('시간 소진 시 자동 제출 — 미응답=오답, 1회만', (tester) async {
    var calls = 0;
    final started = DateTime(2026, 6, 6, 0, 0, 0);
    var clock = started;
    await tester.pumpWidget(_host(ExamView(
      bank: _bank(), certId: 'CLF-C02', taskId: 'clf-t2-3',
      startedAt: started, durationSec: 5,
      now: () => clock,
      onFinished: (_) => calls++,
    )));
    await tester.pump();

    clock = started.add(const Duration(seconds: 10)); // 만료
    await tester.pump(const Duration(seconds: 1)); // 틱 1회
    await tester.pump();

    expect(calls, 1); // 가드: 1회만
    expect(find.text('결과'), findsOneWidget); // 결과 진입
  });
}
