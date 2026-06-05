import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/models/attempt_record.dart';
import 'package:aws_docs/models/question.dart';
import 'package:aws_docs/pages/quiz_page.dart';
import 'package:aws_docs/theme/app_theme.dart';

QuestionBank _bank() => const QuestionBank(
      examGuideTaskId: 'clf-t2-1',
      taskTitle: '공동 책임 모델',
      certCode: 'CLF-C02',
      domain: 2,
      questions: [
        Question(
            id: 'q1',
            examGuideTaskId: 'clf-t2-1',
            stem: '게스트 OS 패치가 고객 책임인 서비스는?',
            options: ['RDS', 'EC2'],
            correct: 1,
            explanation: 'EC2는 IaaS.',
            wrongExplanations: {0: 'RDS는 AWS가 패치.'},
            sources: [],
            verified: true),
      ],
    );

void main() {
  testWidgets('정답 선택→확인 시 해설 공개, 결과에서 onFinished 호출', (tester) async {
    AttemptRecord? finished;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: QuizView(
            bank: _bank(),
            certId: 'CLF-C02',
            onFinished: (r) => finished = r),
      ),
    ));

    await tester.tap(find.text('EC2'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();
    expect(find.textContaining('EC2는 IaaS'), findsOneWidget);

    await tester.tap(find.text('결과 보기'));
    await tester.pumpAndSettle();
    expect(finished, isNotNull);
    expect(finished!.correct, 1);
    expect(finished!.total, 1);
    expect(finished!.wrongQuestionIds, isEmpty);

    // 결과 화면 복기(스펙 §9.3): 정답 라벨 + 해설 재표시
    expect(find.textContaining('정답'), findsWidgets);
    expect(find.textContaining('EC2는 IaaS'), findsOneWidget);
  });
}
