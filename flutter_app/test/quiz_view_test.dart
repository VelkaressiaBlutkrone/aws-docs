import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/content/quiz_widgets.dart';
import 'package:aws_docs/data/history_store.dart';
import 'package:aws_docs/models/attempt_record.dart';
import 'package:aws_docs/models/question.dart';
import 'package:aws_docs/pages/quiz_page.dart';
import 'package:aws_docs/theme/app_theme.dart';

/// 응시 이력 키 쓰기만 실패시키는 백엔드(localStorage 쿼터 초과 모사).
class _QuotaOnHistory extends MemoryBackend {
  @override
  void write(String key, String value) {
    if (key == 'awsdocs.history.v1') throw StateError('QuotaExceededError');
    super.write(key, value);
  }
}

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
    expect(finished!.presentedQuestionIds, ['q1']);

    // 결과 화면 복기(스펙 §9.3): 정답 라벨 + 해설 재표시
    expect(find.textContaining('정답'), findsWidgets);
    expect(find.textContaining('EC2는 IaaS'), findsOneWidget);
  });

  testWidgets('mode/examId 주입 시 review 레코드로 기록', (tester) async {
    AttemptRecord? finished;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: QuizView(
          bank: _bank(),
          certId: 'CLF-C02',
          mode: 'review',
          examId: 'review:clf-t2-1',
          onFinished: (r) => finished = r,
        ),
      ),
    ));

    await tester.tap(find.text('EC2'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('결과 보기'));
    await tester.pumpAndSettle();

    expect(finished, isNotNull);
    expect(finished!.mode, 'review');
    expect(finished!.examId, 'review:clf-t2-1');
    expect(finished!.presentedQuestionIds, ['q1']);
  });

  testWidgets('기록 저장(onFinished)이 실패해도 결과 화면을 연다', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: QuizView(
          bank: _bank(),
          certId: 'CLF-C02',
          onFinished: (_) => throw StateError('QuotaExceededError'),
        ),
      ),
    ));

    await tester.tap(find.text('EC2'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('결과 보기'));
    await tester.pumpAndSettle();

    // 저장 예외는 전역 핸들러로 전파되지만, 결과 화면은 열려 있어야 한다.
    expect(tester.takeException(), isStateError);
    expect(find.byType(ResultsView), findsOneWidget);
    expect(find.text('결과 보기'), findsNothing);
  });

  group('recordPracticeAttempt', () {
    const rec = AttemptRecord(
      certId: 'CLF-C02',
      examId: 'practice:clf-t2-1',
      mode: 'practice',
      date: '2026-10-17T00:00:00.000',
      correct: 1,
      total: 1,
      wrongQuestionIds: [],
      flaggedQuestionIds: [],
      presentedQuestionIds: ['q1'],
      durationSpentSec: 12,
    );

    test('저장 성공 시 이력에 쌓이고 알림은 호출되지 않는다', () {
      final b = MemoryBackend();
      var notified = 0;
      recordPracticeAttempt(rec,
          history: HistoryStore(backend: b),
          onSaveFailure: (_) => notified++);
      expect(HistoryStore(backend: b).all().single.examId, 'practice:clf-t2-1');
      expect(notified, 0);
    });

    test('저장 실패 시 사용자에게 알리고 예외를 전파한다', () {
      final b = _QuotaOnHistory();
      Object? seen;
      expect(
          () => recordPracticeAttempt(rec,
              history: HistoryStore(backend: b),
              onSaveFailure: (e) => seen = e),
          throwsStateError);
      expect(seen, isStateError); // 알림이 실제로 호출됐다
    });
  });

  testWidgets('notifyAttemptSaveFailure는 저장 실패를 스낵바로 알린다', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => notifyAttemptSaveFailure(context),
            child: const Text('알림'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('알림'));
    await tester.pump();
    expect(find.textContaining('저장하지 못했습니다'), findsOneWidget);
  });
}
