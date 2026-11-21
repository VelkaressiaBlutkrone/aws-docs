// flutter_app/test/question_report_test.dart
//
// 결과 복기 카드의 문항 신고 진입점. 설계 §7-2.
//
// ⚠️ `ResultCard` 한 곳이면 **시험·자격증 모의고사·연습 퀴즈 결과** 세 화면이
// 덮인다 — `ResultsView` → `ResultCard` 경로의 호출부가 `exam_view` 와
// `quiz_page` 둘이고 `cert_exam_page` 는 `ExamView` 를 재사용한다(2026-11-21 실측).
// 오답노트(`review_page`)는 `ResultsView` 를 쓰지 않아 범위 밖이다(설계 §9).
import 'dart:io';

import 'package:flutter/material.dart' hide Text;
import 'package:flutter_test/flutter_test.dart';

import 'package:aws_docs/content/quiz_widgets.dart';
import 'package:aws_docs/models/question.dart';
import 'package:aws_docs/theme/app_theme.dart';
import 'package:aws_docs/theme/theme_scope.dart';
import 'package:aws_docs/widgets/touch_target.dart';

const _q = Question(
  id: 'x-q1',
  examGuideTaskId: 'clf-t1-1',
  stem: '지문',
  options: ['가', '나', '다', '라'],
  correct: 0,
  explanation: '해설',
  wrongExplanations: {},
  sources: [],
  verified: true,
);

Widget _wrap(Widget child) => ThemeScope(
      isDark: false,
      toggle: () {},
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );

void main() {
  group('ResultCard 신고 버튼', () {
    testWidgets('onReport 를 주지 않으면 신고 버튼이 없다', (tester) async {
      await tester.pumpWidget(
          _wrap(const ResultCard(index: 0, q: _q, pickedIndex: 1)));
      await tester.pumpAndSettle();
      expect(find.text('신고'), findsNothing);
    });

    testWidgets('onReport 를 주면 버튼이 보이고 q 와 pickedIndex 를 넘긴다',
        (tester) async {
      Question? got;
      int? picked = -1;
      await tester.pumpWidget(_wrap(ResultCard(
        index: 0,
        q: _q,
        pickedIndex: 2,
        onReport: (q, p) {
          got = q;
          picked = p;
        },
      )));
      await tester.pumpAndSettle();
      await tester.tap(find.text('신고'));
      await tester.pumpAndSettle();
      expect(got?.id, 'x-q1');
      expect(picked, 2);
    });

    testWidgets('고르지 않은 문항도 신고할 수 있다', (tester) async {
      Question? got;
      int? picked = -1;
      await tester.pumpWidget(_wrap(ResultCard(
        index: 0,
        q: _q,
        pickedIndex: null,
        onReport: (q, p) {
          got = q;
          picked = p;
        },
      )));
      await tester.pumpAndSettle();
      await tester.tap(find.text('신고'));
      await tester.pumpAndSettle();
      expect(got?.id, 'x-q1');
      expect(picked, isNull);
    });

    testWidgets('신고 버튼의 탭 영역이 48dp 이상이다', (tester) async {
      await tester.pumpWidget(_wrap(ResultCard(
          index: 0, q: _q, pickedIndex: 0, onReport: (_, _) {})));
      await tester.pumpAndSettle();
      final box = find.ancestor(
          of: find.text('신고'), matching: find.byType(TouchTarget));
      expect(box, findsOneWidget);
      expect(tester.getSize(box).height, greaterThanOrEqualTo(48));
    });
  });

  group('ResultsView 전달', () {
    testWidgets('카드마다 신고 버튼을 그린다', (tester) async {
      const bank = QuestionBank(
        examGuideTaskId: 'clf-t1-1',
        taskTitle: '클라우드 개념',
        certCode: 'CLF-C02',
        domain: 1,
        questions: [_q, _q, _q],
      );
      // ⚠️ 정답 카드는 오답이 있으면 **접힌 채** 시작하고(UX-5) 접힌 카드에는
      // 해설도 신고 버튼도 없다. 전부 오답으로 둬 세 카드가 펼쳐지게 한다.
      await tester.pumpWidget(_wrap(ResultsView(
        bank: bank,
        picked: const {0: 1, 1: 1, 2: 1},
        onReport: (_, _) {},
      )));
      await tester.pumpAndSettle();
      expect(find.text('신고'), findsNWidgets(3));
    });

    testWidgets('onReport 를 주지 않으면 신고 버튼이 없다', (tester) async {
      const bank = QuestionBank(
        examGuideTaskId: 'clf-t1-1',
        taskTitle: '클라우드 개념',
        certCode: 'CLF-C02',
        domain: 1,
        questions: [_q],
      );
      await tester.pumpWidget(
          _wrap(const ResultsView(bank: bank, picked: {0: 0})));
      await tester.pumpAndSettle();
      expect(find.text('신고'), findsNothing);
    });
  });

  // ⚠️⚠️ Task 8 에서 **배선 누락**(파라미터는 더했는데 호출부가 넘기지 않아
  // 라이브에서만 사라진다)을 겪었다. 단위 테스트는 콜백을 직접 주므로 그 공백을
  // 보지 못한다 — 결과 화면을 가진 세 페이지가 실제로 넘기는지 소스로 센다.
  group('배선', () {
    // ⭐ 두 뷰가 **자기 cert 를 이미 안다**(`ExamView.certId` · `QuizView` 의
    // `bank.certCode`) — 그래서 페이지 셋(`exam_page`·`cert_exam_page`·
    // `quiz_page`)을 거치지 않고 뷰에서 바로 보낸다. `cert_exam_page` 는
    // `ExamView` 를 재사용하므로 그 한 자리가 두 모의고사 화면을 덮는다.
    test('ExamView·QuizView 가 신고를 /feedback 으로 보낸다', () {
      for (final path in [
        'lib/pages/exam/exam_view.dart',
        'lib/pages/quiz_page.dart',
      ]) {
        final src = File(path).readAsStringSync();
        expect(src, contains('onReport'), reason: '$path 가 onReport 를 모른다');
        expect(src, contains('/feedback'),
            reason: '$path 가 신고를 보내지 않는다');
        expect(src, contains('FeedbackKind.question'),
            reason: '$path 가 신고 유형을 지정하지 않는다');
        expect(src, contains('shownOptions'),
            reason: '$path 가 보여 준 보기를 담지 않는다 — 셔플 때문에 복원 불가');
      }
    });

    // 자격증 모의고사가 ExamView 를 재사용한다는 전제(위 한 자리가 두 화면을
    // 덮는 근거). 이것이 깨지면 그 화면에 신고가 사라진다.
    test('cert_exam_page 가 ExamView 를 재사용한다', () {
      final src = File('lib/pages/cert_exam_page.dart').readAsStringSync();
      expect(src, contains('ExamView('));
    });
  });
}
