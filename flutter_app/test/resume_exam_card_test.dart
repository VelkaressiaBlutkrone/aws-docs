import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/cert_lookup.dart';
import 'package:aws_docs/data/exam_session_store.dart';
import 'package:aws_docs/data/history_store.dart' show KvBackend, MemoryBackend;
import 'package:aws_docs/data/resume_exam.dart';
import 'package:aws_docs/models/exam_snapshot.dart';
import 'package:aws_docs/models/question.dart';
import 'package:aws_docs/pages/cert_detail_page.dart';
import 'package:aws_docs/pages/home_page.dart';
import 'package:aws_docs/theme/app_theme.dart';
import 'package:aws_docs/theme/theme_scope.dart';
import 'package:aws_docs/widgets/resume_exam_card.dart';

/// UX-4 가드 — 카드 카피와 페이지 배선.

Question _q(String id) => Question(
      id: id,
      examGuideTaskId: 'clf-t1-1',
      stem: '지문 $id',
      options: const ['A', 'B'],
      correct: 0,
      explanation: 'e',
      wrongExplanations: const {},
      sources: const [],
      verified: true,
    );

/// 지금 시작해 90분 남은 세션을 심는다 — 실제 시계로 돌아도 만료되지 않는다.
void _seed(KvBackend b, String examId, {String certId = 'CLF-C02'}) {
  ExamSessionStore(backend: b).saveSnapshot(ExamSnapshot(
    examId: examId,
    certId: certId,
    taskId: examId.replaceFirst('exam:', ''),
    nonce: 'n1',
    startedAtIso: DateTime.now().toUtc().toIso8601String(),
    durationSec: 5400,
    questions: [_q('q1'), _q('q2')],
  ));
}

Widget _host(Widget child) => ThemeScope(
      isDark: false,
      toggle: () {},
      child: MaterialApp(theme: AppTheme.light, home: Scaffold(body: child)),
    );

const _exam = ResumableExam(
  certCode: 'CLF-C02',
  examId: 'exam:CLF-C02-mock',
  weighted: false,
  remainingSec: 5370,
);

void main() {
  testWidgets('카드는 무엇을·얼마나 남았는지·무슨 일이 일어나는지 적는다', (tester) async {
    await tester.pumpWidget(
        _host(ResumeExamCard(exam: _exam, onTap: () {})));

    expect(find.textContaining('진행 중인 통합 모의고사'), findsOneWidget);
    expect(find.textContaining('남은 1시간 29분'), findsOneWidget);
    expect(find.text('이어서 풀기 →'), findsOneWidget);
  });

  testWidgets('자격증이 섞이는 곳에서만 코드를 적는다', (tester) async {
    await tester.pumpWidget(_host(
        ResumeExamCard(exam: _exam, showCertCode: true, onTap: () {})));
    expect(find.textContaining('진행 중인 CLF-C02 통합 모의고사'), findsOneWidget);
  });

  testWidgets('탭하면 그 시험의 경로를 연다', (tester) async {
    String? opened;
    await tester.pumpWidget(_host(ResumeExamSection(
      exams: const [
        _exam,
        ResumableExam(
            certCode: 'CLF-C02',
            examId: 'exam:CLF-C02-weak',
            weighted: true,
            remainingSec: 600),
      ],
      onOpen: (r) => opened = r,
    )));

    expect(find.byType(ResumeExamCard), findsNWidgets(2));
    expect(find.textContaining('진행 중인 약점 집중 모의고사'), findsOneWidget);

    await tester.tap(find.textContaining('진행 중인 약점 집중 모의고사'));
    await tester.pump();
    expect(opened, '/cert/CLF-C02/exam/weak');
  });

  testWidgets('0건이면 아무것도 그리지 않는다 — 빈 자리를 만들지 않는다', (tester) async {
    await tester.pumpWidget(
        _host(ResumeExamSection(exams: const [], onOpen: (_) {})));
    expect(find.byType(ResumeExamCard), findsNothing);
    expect(find.textContaining('이어서 풀기'), findsNothing);
  });

  group('홈 배선', () {
    testWidgets('진행 중 세션이 있으면 홈 첫 화면에 카드가 선다', (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final b = MemoryBackend();
      _seed(b, 'exam:CLF-C02-mock');

      await tester.pumpWidget(_HomeHost(backend: b));
      await tester.pump();

      expect(find.textContaining('진행 중인 CLF-C02 통합 모의고사'), findsOneWidget);
    });

    testWidgets('세션이 없으면 카드도 없다', (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_HomeHost(backend: MemoryBackend()));
      await tester.pump();

      expect(find.byType(ResumeExamCard), findsNothing);
    });
  });

  group('자격증 상세 배선', () {
    testWidgets('그 자격증의 진행 중 시험만 상단에 선다', (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final b = MemoryBackend();
      _seed(b, 'exam:CLF-C02-weak');
      _seed(b, 'exam:SAA-C03-mock', certId: 'SAA-C03'); // 다른 자격증

      await tester.pumpWidget(ThemeScope(
        isDark: false,
        toggle: () {},
        child: MaterialApp(
          theme: AppTheme.light,
          home: CertDetailPage(cert: certByCode('CLF-C02')!, backend: b),
        ),
      ));
      await tester.pump();

      expect(find.textContaining('진행 중인 약점 집중 모의고사'), findsOneWidget);
      // 상세는 한 자격증만 다루므로 코드를 적지 않는다.
      expect(find.textContaining('CLF-C02 약점'), findsNothing);
      expect(find.textContaining('SAA-C03'), findsNothing);
    });
  });
}

/// 홈은 `SelectionArea`를 쓰므로 뷰포트를 충분히 크게 잡고 직접 렌더한다.
class _HomeHost extends StatelessWidget {
  const _HomeHost({required this.backend});
  final KvBackend backend;

  @override
  Widget build(BuildContext context) => ThemeScope(
        isDark: false,
        toggle: () {},
        child: MaterialApp(
          theme: AppTheme.light,
          home: HomePage(backend: backend),
        ),
      );
}
