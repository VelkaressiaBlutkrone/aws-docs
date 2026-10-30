import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/content/quiz_widgets.dart';
import 'package:aws_docs/data/cert_lookup.dart';
import 'package:aws_docs/data/cloud/sync_controller.dart';
import 'package:aws_docs/data/exam_session_store.dart';
import 'package:aws_docs/data/study_plan_store.dart';
import 'package:aws_docs/models/exam_snapshot.dart';
import 'package:aws_docs/models/question.dart';
import 'package:aws_docs/models/study_plan.dart';
import 'package:aws_docs/pages/cert_detail/summary_section.dart';
import 'package:aws_docs/pages/cert_detail_page.dart';
import 'package:aws_docs/pages/home_page.dart';
import 'package:aws_docs/pages/plan_page.dart';
import 'package:aws_docs/pages/report_page.dart';
import 'package:aws_docs/pages/sync_entry.dart';
import 'package:aws_docs/theme/app_theme.dart';
import 'package:aws_docs/theme/theme_scope.dart';
import 'package:aws_docs/widgets/app_header.dart';

import 'contrast_scan.dart';

/// M-6 후속 — `accent` 텍스트가 `surface2` 위에 오지 않는지 **트리를 걸어** 확인한다.
///
/// 라이트 `accent / surface2` = **4.21로 AA 미달**이다(리뷰 부록 A가 빠뜨린 조합).
/// 2026-10-30 1차에서는 surface2 패널 29곳을 눈으로 훑어 7곳만 고쳤는데, 중첩은
/// grep으로 판정할 수 없어 나머지를 확인하지 못했다. 이 파일이 그 공백을 닫는다.
///
/// 올바른 토큰은 `accentStrong`(라이트 5.65 · 다크 7.34)이고, 아이콘·점·진행 바의
/// accent는 비텍스트 3:1을 넘으므로 대상이 아니다(스캐너는 텍스트만 본다).

Widget _host(Widget child, {bool dark = false}) => MaterialApp(
      theme: dark ? AppTheme.dark : AppTheme.light,
      home: Scaffold(
        backgroundColor: (dark ? AppColors.dark : AppColors.light).bg,
        body: SingleChildScrollView(child: child),
      ),
    );

/// surface2 패널 안에 색을 지정한 텍스트 한 줄.
Widget _panel(Color fg, String label, {Color? panel}) => Builder(
      builder: (context) {
        final c = context.c;
        return Container(
          padding: const EdgeInsets.all(Gap.lg),
          decoration: BoxDecoration(color: panel ?? c.surface2),
          child: Text(label, style: TextStyle(color: fg)),
        );
      },
    );

void main() {
  group('⚠️ 대조군 — 스캐너가 실제로 잡는지 먼저 증명한다', () {
    testWidgets('surface2 위의 accent 텍스트를 잡는다', (tester) async {
      await tester.pumpWidget(_host(Builder(
        builder: (context) => _panel(context.c.accent, '걸려야 하는 줄'),
      )));

      final hits = accentOnSurface2(tester);
      expect(hits, hasLength(1), reason: '스캐너가 못 잡으면 뒤의 0건은 무의미하다');
      expect(hits.single.text, '걸려야 하는 줄');
    });

    testWidgets('accentStrong으로 바꾸면 안 잡는다 — 그것이 정답 토큰이다', (tester) async {
      await tester.pumpWidget(_host(Builder(
        builder: (context) => _panel(context.c.accentStrong, '통과해야 하는 줄'),
      )));
      expect(accentOnSurface2(tester), isEmpty);
    });

    testWidgets('같은 accent라도 surface 위면 대상이 아니다 — 4.76으로 AA 통과', (tester) async {
      await tester.pumpWidget(_host(Builder(
        builder: (context) =>
            _panel(context.c.accent, '흰 카드 위', panel: context.c.surface),
      )));
      expect(accentOnSurface2(tester), isEmpty);
    });

    testWidgets('⚠️ 가장 가까운 배경으로 판정한다 — 바깥 surface2, 안쪽 surface', (tester) async {
      await tester.pumpWidget(_host(Builder(
        builder: (context) {
          final c = context.c;
          return Container(
            decoration: BoxDecoration(color: c.surface2),
            padding: const EdgeInsets.all(Gap.lg),
            child: Container(
              decoration: BoxDecoration(color: c.surface),
              padding: const EdgeInsets.all(Gap.lg),
              child: Text('안쪽 카드', style: TextStyle(color: c.accent)),
            ),
          );
        },
      )));
      expect(accentOnSurface2(tester), isEmpty,
          reason: '바깥이 surface2라도 안쪽 surface가 실제 배경이다');
    });

    testWidgets('Text.rich의 스팬별 색도 따로 본다', (tester) async {
      await tester.pumpWidget(_host(Builder(
        builder: (context) {
          final c = context.c;
          return Container(
            decoration: BoxDecoration(color: c.surface2),
            child: Text.rich(TextSpan(children: [
              TextSpan(text: '걸리는 스팬', style: TextStyle(color: c.accent)),
              TextSpan(text: '안 걸리는 스팬', style: TextStyle(color: c.textMuted)),
            ])),
          );
        },
      )));

      final hits = accentOnSurface2(tester);
      expect(hits, hasLength(1));
      expect(hits.single.text, '걸리는 스팬');
    });

    testWidgets('아이콘은 텍스트가 아니라 대상이 아니다', (tester) async {
      await tester.pumpWidget(_host(Builder(
        builder: (context) {
          final c = context.c;
          return Container(
            decoration: BoxDecoration(color: c.surface2),
            child: Icon(Icons.timer_outlined, color: c.accent),
          );
        },
      )));
      expect(accentOnSurface2(tester), isEmpty);
    });

    testWidgets('다크도 같은 규칙으로 본다', (tester) async {
      await tester.pumpWidget(_host(
        Builder(builder: (context) => _panel(context.c.accent, '다크 줄')),
        dark: true,
      ));
      expect(accentOnSurface2(tester, colors: AppColors.dark), hasLength(1));
    });
  });

  group('실제 표면 스캔 — accent 텍스트가 surface2 위에 없다', () {
    /// 실패 메시지에 **어느 문구가** 걸렸는지 적는다 — 없으면 29개 패널 중 어디인지
    /// 다시 찾아야 한다.
    void expectClean(WidgetTester tester, String surface) {
      final hits = accentOnSurface2(tester);
      expect(hits, isEmpty,
          reason: '$surface: accent 텍스트가 surface2 위에 있다(라이트 4.21 = AA 미달). '
              'accentStrong(5.65)으로 바꾼다. 걸린 것 → ${hits.join(' | ')}');
    }

    testWidgets('홈', (tester) async {
      tester.view.physicalSize = const Size(1280, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(ThemeScope(
        isDark: false,
        toggle: () {},
        child: MaterialApp(
            theme: AppTheme.light, home: HomePage(backend: MemoryBackend())),
      ));
      await tester.pump();
      expectClean(tester, '홈');
    });

    testWidgets('홈 — 오늘 할 일 배너 + 이어서 풀기 카드가 뜬 상태', (tester) async {
      tester.view.physicalSize = const Size(1280, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      // 둘 다 surface2 패널이고 accent 텍스트를 품는다 — 1차에서 고친 자리다.
      final b = MemoryBackend();
      ExamSessionStore(backend: b).saveSnapshot(ExamSnapshot(
        examId: 'exam:CLF-C02-mock',
        certId: 'CLF-C02',
        taskId: 'CLF-C02-mock',
        nonce: 'n1',
        startedAtIso: DateTime.now().toUtc().toIso8601String(),
        durationSec: 5400,
        questions: [
          const Question(
              id: 'q1',
              examGuideTaskId: 'clf-t1-1',
              stem: 's',
              options: ['a', 'b'],
              correct: 0,
              explanation: 'e',
              wrongExplanations: {},
              sources: [],
              verified: true),
        ],
      ));
      StudyPlanStore(backend: b).upsert(StudyPlan(
        id: 'p1',
        label: '오늘',
        certCode: 'CLF-C02',
        startIso: _todayIso,
        endIso: _todayIso,
        mode: PlanMode.period,
        createdIso: _todayIso,
        items: [
          PlanItem(
              id: 'i1',
              dateIso: _todayIso,
              type: PlanItemType.doc,
              phase: PlanPhase.learn,
              refId: 'clf-t1-1'),
        ],
      ));

      await tester.pumpWidget(ThemeScope(
        isDark: false,
        toggle: () {},
        child: MaterialApp(theme: AppTheme.light, home: HomePage(backend: b)),
      ));
      await tester.pump();

      // 전제 — 두 패널이 실제로 그려졌는지 먼저 확인한다(안 그려지면 거짓 통과).
      expect(find.textContaining('이어서 풀기'), findsOneWidget);
      expect(find.textContaining('오늘 학습할 항목'), findsOneWidget);
      expectClean(tester, '홈(배너+카드)');
    });

    testWidgets('자격증 상세', (tester) async {
      tester.view.physicalSize = const Size(1280, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(ThemeScope(
        isDark: false,
        toggle: () {},
        child: MaterialApp(
          theme: AppTheme.light,
          home: CertDetailPage(
              cert: certByCode('CLF-C02')!, backend: MemoryBackend()),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(SummaryBlock), findsOneWidget); // 전제
      expectClean(tester, '자격증 상세');
    });

    testWidgets('약점 리포트', (tester) async {
      tester.view.physicalSize = const Size(1280, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(ThemeScope(
        isDark: false,
        toggle: () {},
        child: MaterialApp(
            theme: AppTheme.light,
            home: ReportPage(cert: certByCode('CLF-C02')!)),
      ));
      await tester.pumpAndSettle();
      expectClean(tester, '약점 리포트');
    });

    testWidgets('학습 일정 — 목록·생성 폼', (tester) async {
      tester.view.physicalSize = const Size(1280, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(ThemeScope(
        isDark: false,
        toggle: () {},
        child: MaterialApp(
          theme: AppTheme.light,
          home: PlanPage(
              cert: certByCode('CLF-C02')!, backend: MemoryBackend()),
        ),
      ));
      await tester.pump();
      expectClean(tester, '일정 목록');

      await tester.tap(find.text('+ 일정 추가'));
      await tester.pumpAndSettle();
      expectClean(tester, '일정 생성 폼');
    });

    testWidgets('동기 진입', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SyncEntry(controller: ValueNotifier<SyncController?>(null)),
        ),
      ));
      await tester.pump();
      expectClean(tester, '동기 진입');
    });

    testWidgets('결과 화면 — 오답 복기 카드', (tester) async {
      tester.view.physicalSize = const Size(900, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            child: ResultsView(
              bank: QuestionBank(
                examGuideTaskId: 'CLF-C02-mock',
                taskTitle: '통합 모의고사',
                certCode: 'CLF-C02',
                domain: 0,
                questions: const [
                  Question(
                      id: 'q1',
                      examGuideTaskId: 'clf-t1-1',
                      skill: 'IAM 최소 권한',
                      stem: '오답 문항',
                      options: ['가', '나'],
                      correct: 1,
                      explanation: '해설',
                      wrongExplanations: {0: '아니다'},
                      sources: [],
                      verified: true),
                  Question(
                      id: 'q2',
                      examGuideTaskId: 'clf-t1-2',
                      stem: '정답 문항',
                      options: ['가', '나'],
                      correct: 0,
                      explanation: '해설',
                      wrongExplanations: {},
                      sources: [],
                      verified: true),
                ],
              ),
              picked: const {0: 0, 1: 0},
              flagged: const {0},
              onOpenStudy: (_, _) {},
            ),
          ),
        ),
      ));
      await tester.pump();
      expect(find.text('→ 학습문서'), findsOneWidget); // 전제 — 개념 칩이 그려졌다
      expectClean(tester, '결과 화면');
    });

    testWidgets('문서형 헤더', (tester) async {
      await tester.pumpWidget(ThemeScope(
        isDark: false,
        toggle: () {},
        child: MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            appBar: AppHeader.document(
              backLabel: 'CLF-C02',
              sectionLabel: '학습 문서',
              title: 'AWS 클라우드의 이점',
              metaBadge: '✓ 검증됨',
              metaDate: '2026-10-30',
            ),
            body: SizedBox.shrink(),
          ),
        ),
      ));
      await tester.pump();
      expectClean(tester, '문서형 헤더');
    });

    // ⚠️ 스캔하지 않은 surface2 패널과 그 근거(소스 확인):
    //  · `lecture_transport_bar.dart:165·204` — 그 안의 accent는 **아이콘**뿐이고
    //    (`:169` `Icon(..., color: c.accent)`) 텍스트는 textMuted/textFaint다.
    //    렌더에 fake AudioBackend+LecturePlaylist가 필요해 비용 대비 이득이 없다.
    //  · `study_markdown_view.dart:151·221·302`(코드 블록·표 머리) — accent 텍스트는
    //    `:187`·`:207`·`:288`로 전부 콜아웃·링크이고 surface2 컨테이너 밖이다.
    //  · `cert_audio_page.dart:93`·`study_doc_page.dart:298`·`app_header.dart` 메뉴
    //    시트 — 각각 textMuted/surface2 조합이다.
    // 이 목록은 "안 봤다"가 아니라 "소스로 봤고 텍스트 accent가 없다"는 기록이다.
  });
}

final _todayIso = DateTime.now().toIso8601String().substring(0, 10);
