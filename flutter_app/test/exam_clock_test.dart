import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aws_docs/models/question.dart';
import 'package:aws_docs/pages/exam/exam_clock.dart';
import 'package:aws_docs/pages/exam_page.dart';
import 'package:aws_docs/theme/app_theme.dart';

/// 리뷰 Minor m-2 — 1초 ticker가 `setState(() {})`로 **ExamView 전체**(문항 그리드
/// 65칩 + 선택지 + 버튼)를 매초 리빌드했다. 시계만 리빌드하도록 분리한다.
///
/// ⚠️ **리빌드 횟수는 Flutter 테스트 API로 직접 셀 수 없다** — 그래서 동작(시계가
/// 실제로 갱신된다)은 위젯 테스트로, "매초 리빌드되는 범위가 시계뿐"이라는 구조는
/// 소스 가드로 고정한다. 만료 시 자동 제출은 `exam_view_test.dart`가 덮는다.
///
/// 정본: `docs/audits/2026-09-22-app-code-ux-review.md` m-2.

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

Widget _host(Widget child) =>
    MaterialApp(theme: AppTheme.light, home: Scaffold(body: child));

void main() {
  testWidgets('시험 러너의 시계는 별도 위젯이고 틱마다 갱신된다', (tester) async {
    final started = DateTime(2026, 6, 6, 0, 0, 0);
    var clock = started;

    await tester.pumpWidget(_host(ExamView(
      bank: _bank(),
      certId: 'CLF-C02',
      taskId: 'clf-t2-3',
      startedAt: started,
      durationSec: 600,
      now: () => clock,
    )));
    await tester.pump();

    expect(find.byType(ExamClock), findsOneWidget,
        reason: '시계가 ExamView 본문에 인라인이면 매초 전체가 리빌드된다');
    expect(find.text('10:00'), findsOneWidget);

    clock = started.add(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('09:59'), findsOneWidget, reason: '틱이 시계를 갱신하지 않는다');

    clock = started.add(const Duration(seconds: 62));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('08:58'), findsOneWidget);
  });

  testWidgets('시계는 남은 시간이 0이면 만료를 한 번만 통지한다', (tester) async {
    final started = DateTime(2026, 6, 6, 0, 0, 0);
    var expired = 0;

    await tester.pumpWidget(_host(ExamClock(
      startedAt: started,
      durationSec: 5,
      now: () => started.add(const Duration(seconds: 10)),
      onExpired: () => expired++,
    )));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(expired, 1, reason: '만료 통지가 매 틱 반복되면 자동 제출이 여러 번 불린다');
    expect(find.text('00:00'), findsOneWidget);
  });

  group('m-2 구조 가드 — 매초 리빌드 범위는 시계뿐이다', () {
    const path = 'lib/pages/exam/exam_view.dart';
    String src() => File(path).readAsStringSync();

    test('ExamView가 1초 타이머를 직접 돌리지 않는다', () {
      expect(src().contains('Timer.periodic'), isFalse,
          reason: '$path: 1초 타이머가 남아 있다 — `ExamClock`이 소유해야 한다');
    });

    test('남은 시간 계산·포맷이 ExamView에 남아 있지 않다', () {
      // ⚠️ 제출 직후의 `setState(() {})`(결과 화면 전환)는 정당하므로 대상이 아니다 —
      // 매초 돌던 상태가 부모에서 사라졌는지만 본다.
      expect(src().contains('_remainingSec'), isFalse,
          reason: '$path: 남은 시간 계산이 남아 있다 — 부모 build가 매초 다시 읽게 된다');
      expect(src().contains('_mmss'), isFalse,
          reason: '$path: mm:ss 포맷이 남아 있다 — `ExamClock`으로 옮긴다');
    });
  });
}
