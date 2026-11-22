// 시험 결과의 도메인별 정답률 가드 (2026-11-22 외부 리뷰 후속 §5-3 · C→A 트랙 A1).
//
// 결과 화면이 총점만 보여 줘 어느 도메인이 부족한지 약점 리포트까지 가야 알 수 있었다.
// ⚠️ 합격·불합격 색을 쓰지 않는다 — AWS 실제 점수는 환산 점수라 정답률로 판정할 수 없다.
// ⚠️ 배선까지 본다 — 위젯 단위 테스트만 두면 페이지가 값을 넘기지 않아도 초록이다
// (2026-11-21 D2 의 홈 메뉴 항목 누락과 같은 계열).
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';

import 'package:aws_docs/content/quiz_widgets.dart';
import 'package:aws_docs/data/cert_lookup.dart';
import 'package:aws_docs/data/content_index.dart';
import 'package:aws_docs/data/domain_score.dart';
import 'package:aws_docs/data/exam_session_store.dart';
import 'package:aws_docs/data/history_store.dart' show MemoryBackend;
import 'package:aws_docs/models/exam_snapshot.dart';
import 'package:aws_docs/models/question.dart';
import 'package:aws_docs/pages/cert_exam_page.dart';
import 'package:aws_docs/pages/exam_page.dart';
import 'package:aws_docs/theme/app_theme.dart';
import 'package:aws_docs/theme/theme_scope.dart';

Question _q(String id, String taskId, {int correct = 0}) => Question(
      id: id,
      examGuideTaskId: taskId,
      skill: '',
      section: '',
      difficulty: '',
      stem: '$id 지문',
      options: const ['보기 하나', '보기 둘'],
      correct: correct,
      explanation: '',
      wrongExplanations: const {},
      sources: const [],
      verified: true,
    );

QuestionBank _bank(List<Question> questions) => QuestionBank(
      examGuideTaskId: 'SAA-C03-mock',
      taskTitle: '통합 모의고사',
      certCode: 'SAA-C03',
      domain: 0,
      questions: questions,
    );

Widget _wrap(Widget child) => ThemeScope(
      isDark: false,
      toggle: () {},
      child: MaterialApp(theme: AppTheme.light, home: child),
    );

const _domains = {'t1': 1, 't2': 2, 't3': 3};

Future<void> _settle(WidgetTester tester) => tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 10),
    );

void main() {
  setUp(rootBundle.clear);

  group('buildDomainScores', () {
    test('도메인 번호순으로 묶고 미응답은 오답으로 센다', () {
      final scores = buildDomainScores(
        questions: [
          _q('a', 't2'),
          _q('b', 't1'),
          _q('c', 't1'),
          _q('d', 't2'),
        ],
        picked: const {0: 0, 1: 0, 2: 1}, // a 정답 · b 정답 · c 오답 · d 미응답
        domainByTaskId: _domains,
      );

      expect([for (final s in scores) s.domain], [1, 2]);
      expect([for (final s in scores) s.correct], [1, 1]);
      expect([for (final s in scores) s.total], [2, 2]);
    });

    test('도메인 이름을 붙이고 이름이 없으면 번호만 남긴다', () {
      final scores = buildDomainScores(
        questions: [_q('a', 't1'), _q('b', 't2')],
        picked: const {},
        domainByTaskId: _domains,
        domainNames: const {1: '보안'},
      );

      expect(scores[0].label, '도메인 1 · 보안');
      expect(scores[1].label, '도메인 2');
    });

    test('정답률은 반올림한 정수 퍼센트다', () {
      final scores = buildDomainScores(
        questions: [
          _q('a', 't1'),
          _q('b', 't1'),
          _q('c', 't1'),
          _q('d', 't2'),
        ],
        picked: const {0: 0, 1: 0, 2: 1, 3: 1},
        domainByTaskId: _domains,
      );

      expect(scores[0].percent, 67);
      expect(scores[1].percent, 0);
    });

    test('도메인이 하나뿐이면 나누어 보여 줄 것이 없다', () {
      expect(
        buildDomainScores(
          questions: [_q('a', 't1'), _q('b', 't1')],
          picked: const {},
          domainByTaskId: _domains,
        ),
        isEmpty,
      );
    });

    test('⚠️ 도메인을 모르는 문항이 하나라도 있으면 일부만 보여 주지 않는다', () {
      expect(
        buildDomainScores(
          questions: [_q('a', 't1'), _q('b', 't2'), _q('c', '없는-task')],
          picked: const {},
          domainByTaskId: _domains,
        ),
        isEmpty,
        reason: '합계가 총점과 어긋나는 표는 틀린 정보다',
      );
    });
  });

  test('전 자격증 문항의 Task ID 가 도메인 조회 키와 일치한다', () {
    var counted = 0;
    for (final cert in kContentIndex.keys) {
      for (final entry in contentFor(cert)) {
        final file = File(entry.questionsAsset);
        if (!file.existsSync()) continue;
        final bank = json.decode(file.readAsStringSync()) as Map<String, dynamic>;
        for (final q in (bank['questions'] as List).cast<Map<String, dynamic>>()) {
          expect(q['examGuideTaskId'], entry.taskId, reason: '${q['id']}');
          counted++;
        }
      }
    }
    expect(counted, greaterThan(2000), reason: '문항을 읽지 못하면 이 단정이 공허하다');
  });

  group('ResultsView', () {
    Widget host(List<DomainScore> scores) => _wrap(Scaffold(
          body: SingleChildScrollView(
            child: ResultsView(
              bank: _bank([_q('a', 't1'), _q('b', 't2')]),
              picked: const {0: 0, 1: 1},
              domainScores: scores,
            ),
          ),
        ));

    testWidgets('도메인별 맞힌 수·문항 수·정답률을 보여 준다', (tester) async {
      await tester.pumpWidget(host(const [
        DomainScore(domain: 1, name: '보안', correct: 12, total: 19),
        DomainScore(domain: 2, name: null, correct: 5, total: 17),
      ]));

      expect(find.text('도메인별 정답률'), findsOneWidget);
      expect(find.text('도메인 1 · 보안'), findsOneWidget);
      expect(find.text('12/19 · 63%'), findsOneWidget);
      expect(find.text('도메인 2'), findsOneWidget);
      expect(find.text('5/17 · 29%'), findsOneWidget);
    });

    testWidgets('점수가 없으면 절을 그리지 않는다', (tester) async {
      await tester.pumpWidget(host(const []));
      expect(find.text('도메인별 정답률'), findsNothing);
    });
  });

  testWidgets('도메인 표를 넘기지 않는 Task 시험에는 절이 없다', (tester) async {
    final start = DateTime(2026, 11, 22);
    await tester.pumpWidget(_wrap(Scaffold(
      body: ExamView(
        bank: _bank([_q('a', 't1'), _q('b', 't2')]),
        certId: 'SAA-C03',
        taskId: 'saa-t1-1',
        startedAt: start,
        durationSec: 600,
        now: () => start,
      ),
    )));
    await tester.tap(find.text('제출'));
    await tester.pump();

    expect(find.text('결과'), findsOneWidget);
    expect(find.text('도메인별 정답률'), findsNothing);
  });

  testWidgets('통합 모의고사 결과에 공식 도메인 이름과 정답률이 나온다', (tester) async {
    tester.view.physicalSize = const Size(1400, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final backend = MemoryBackend();
    ExamSessionStore(backend: backend).saveSnapshot(ExamSnapshot(
      examId: 'exam:SAA-C03-mock',
      certId: 'SAA-C03',
      taskId: 'SAA-C03-mock',
      nonce: 'run-1',
      startedAtIso: DateTime.now().toIso8601String(),
      durationSec: 5400,
      questions: [_q('s1', 'saa-t1-1'), _q('s2', 'saa-t2-1')],
    ));

    await tester.pumpWidget(_wrap(
        CertExamPage(cert: certByCode('SAA-C03')!, backend: backend)));
    await tester.pump();
    await _settle(tester);
    await tester.tap(find.text('이어서 풀기'));
    await _settle(tester);

    await tester.tap(find.text('보기 하나')); // 1번(도메인 1) 정답
    await tester.pump();
    await tester.tap(find.text('제출'));
    await _settle(tester);

    expect(find.text('도메인별 정답률'), findsOneWidget);
    expect(find.text('도메인 1 · 보안 아키텍처 설계'), findsOneWidget);
    expect(find.text('1/1 · 100%'), findsOneWidget);
    expect(find.text('도메인 2 · 복원력을 갖춘 아키텍처 설계'), findsOneWidget);
    expect(find.text('0/1 · 0%'), findsOneWidget);
  });
}
