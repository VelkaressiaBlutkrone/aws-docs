// 약점 리포트 「잠정」 표시 가드 (2026-11-22 외부 리뷰 후속 §5-4 · A2).
//
// 한두 문항만 풀고 틀린 Task 가 「정답률 0%」 빨간 카드로 단정돼 통계가 왜곡됐다.
// ⚠️ 표시만 바꾼다 — `TaskStatus` 는 그대로라 학습문서 처방과 약점 모의고사 가중이
// 변하지 않는다. 그 불변을 아래 단정이 함께 지킨다.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';

import 'package:aws_docs/data/cert_lookup.dart';
import 'package:aws_docs/data/history_store.dart';
import 'package:aws_docs/data/task_score_report.dart';
import 'package:aws_docs/models/attempt_record.dart';
import 'package:aws_docs/pages/report_page.dart';
import 'package:aws_docs/theme/app_theme.dart';
import 'package:aws_docs/theme/theme_scope.dart';

Widget _wrap(Widget child) => ThemeScope(
      isDark: false,
      toggle: () {},
      child: MaterialApp(theme: AppTheme.light, home: child),
    );

TaskScore _score(int attempted) => TaskScore(
      taskId: 't',
      total: 15,
      attempted: attempted,
      correct: 0,
      rate: attempted == 0 ? null : 0,
      status: attempted == 0 ? TaskStatus.unattempted : TaskStatus.weak,
    );

AttemptRecord _wrongAttempt(int n) {
  final ids = [for (var i = 1; i <= n; i++) 'clf-t1-1-q$i'];
  return AttemptRecord(
    certId: 'CLF-C02',
    examId: 'practice:clf-t1-1',
    mode: 'practice',
    date: '2026-11-22T00:00:00.000Z',
    correct: 0,
    total: n,
    presentedQuestionIds: ids,
    wrongQuestionIds: ids,
    flaggedQuestionIds: const [],
    durationSpentSec: 10,
  );
}

Future<void> _pumpReport(WidgetTester tester, int wrongCount) async {
  tester.view.physicalSize = const Size(1200, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  final KvBackend backend = MemoryBackend();
  HistoryStore(backend: backend).add(_wrongAttempt(wrongCount));
  await tester.pumpWidget(
      _wrap(ReportPage(cert: certByCode('CLF-C02')!, backend: backend)));
  await tester.pumpAndSettle();
}

BoxDecoration _cardOf(WidgetTester tester, Finder text) {
  final card = tester.widget<Container>(
      find.ancestor(of: text, matching: find.byType(Container)).first);
  return card.decoration! as BoxDecoration;
}

void main() {
  setUp(rootBundle.clear);

  group('TaskScore.isProvisional', () {
    test('응시 1~4문항은 잠정이고 5문항부터 아니다', () {
      expect(kProvisionalMinAttempts, 5);
      expect(_score(1).isProvisional, isTrue);
      expect(_score(4).isProvisional, isTrue);
      expect(_score(5).isProvisional, isFalse);
    });

    test('미응시는 잠정이 아니다', () {
      expect(_score(0).isProvisional, isFalse);
    });

    test('⚠️ 잠정이어도 약점 판정은 그대로다', () {
      final report = TaskScoreReport.build(
        certId: 'CLF-C02',
        history: [_wrongAttempt(1)],
        taskByQuestionId: const {'clf-t1-1-q1': 'clf-t1-1'},
        taskOrder: const ['clf-t1-1'],
      );
      expect(report.tasks.single.status, TaskStatus.weak,
          reason: '처방과 약점 모의고사 가중이 이 값을 쓴다');
      expect(report.tasks.single.isProvisional, isTrue);
    });
  });

  group('약점 리포트 화면', () {
    testWidgets('표본이 적은 Task 는 잠정으로 적고 빨간 강조를 하지 않는다',
        (tester) async {
      await _pumpReport(tester, 2);
      final c = tester.element(find.byType(ReportPage)).c;

      expect(find.text('응시 2/15문항 · 표본 적음 · 잠정'), findsOneWidget);
      final rate = find.text('정답률 0%');
      expect(tester.widget<Text>(rate).style?.color, c.textMuted);
      expect(_cardOf(tester, rate).color, c.surface);
      expect(find.text('학습문서 →'), findsOneWidget,
          reason: '처방 경로는 잠정이어도 유지한다');
    });

    testWidgets('응시 5문항이면 약점으로 강조하고 잠정을 적지 않는다', (tester) async {
      await _pumpReport(tester, 5);
      final c = tester.element(find.byType(ReportPage)).c;

      expect(find.text('응시 5/15문항'), findsOneWidget);
      expect(find.textContaining('표본 적음'), findsNothing);
      final rate = find.text('정답률 0%');
      expect(tester.widget<Text>(rate).style?.color, c.wrong);
      expect(_cardOf(tester, rate).color, c.wrongWeak);
    });

    testWidgets('잠정 기준을 화면에 밝힌다', (tester) async {
      await _pumpReport(tester, 2);
      expect(
        find.textContaining('응시 문항이 $kProvisionalMinAttempts문항 미만이면 잠정'),
        findsOneWidget,
      );
    });
  });
}
