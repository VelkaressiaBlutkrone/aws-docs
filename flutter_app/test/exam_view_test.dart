import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/models/attempt_record.dart';
import 'package:aws_docs/models/exam_session.dart';
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
  testWidgets('onChanged 세션에 출제 문항 ID가 순서대로 담긴다', (tester) async {
    ExamSession? saved;
    final started = DateTime(2026, 6, 6);
    await tester.pumpWidget(_host(ExamView(
      bank: _bank(),
      certId: 'CLF-C02',
      taskId: 'clf-t2-3',
      startedAt: started,
      durationSec: 600,
      now: () => started.add(const Duration(seconds: 5)),
      onChanged: (s) => saved = s,
    )));
    await tester.pump();

    await tester.tap(find.text('계정 해지')); // 선택 → onChanged 발화
    await tester.pump();

    expect(saved, isNotNull);
    expect(saved!.questionIds, ['q1', 'q2']);
  });

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

  testWidgets('다이얼로그 중 시간 만료 → 단일 제출, 고립 다이얼로그 없음', (tester) async {
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

    await tester.tap(find.byIcon(Icons.flag_outlined)); // 1번 문항 플래그
    await tester.pump();
    await tester.tap(find.text('다음')); // 마지막 문항으로 이동(제출 버튼 노출)
    await tester.pump();
    await tester.tap(find.text('제출')); // 확인 다이얼로그 오픈
    await tester.pump();
    expect(find.text('제출하기'), findsOneWidget); // 다이얼로그 노출 확인

    clock = started.add(const Duration(seconds: 10)); // 만료
    await tester.pump(const Duration(seconds: 1)); // 틱 1회 → 자동 제출
    await tester.pump();

    expect(calls, 1); // 가드: 1회만
    expect(find.text('결과'), findsOneWidget); // 결과 진입
    expect(find.text('제출하기'), findsNothing); // 다이얼로그 해소(고립 아님)
  });

  testWidgets('복원 경로 → 복원 노트 표시 + 답/플래그 보존 후 제출', (tester) async {
    AttemptRecord? finished;
    final started = DateTime(2026, 6, 6, 0, 0, 0);
    await tester.pumpWidget(_host(ExamView(
      bank: _bank(), certId: 'CLF-C02', taskId: 'clf-t2-3',
      startedAt: started, durationSec: 600,
      restored: true,
      initialIndex: 1,
      initialPicked: const {0: 1, 1: 0}, // 둘 다 정답(q1 correct=1, q2 correct=0)
      initialFlagged: const {1},
      now: () => started.add(const Duration(seconds: 30)), // 미만료 고정 시계
      onFinished: (r) => finished = r,
    )));
    await tester.pump();

    expect(find.text('이전 진행을 복원했습니다.'), findsOneWidget); // 복원 노트

    // 마지막 문항(index 1)이므로 '제출' 노출 → 플래그 존재 → 다이얼로그 처리
    await tester.tap(find.text('제출'));
    await tester.pump();
    await tester.tap(find.text('제출하기'));
    await tester.pump();

    expect(finished, isNotNull);
    expect(finished!.correct, 2); // 복원된 답 둘 다 정답
    expect(finished!.flaggedQuestionIds, ['q2']); // 복원된 플래그 보존
  });
}
