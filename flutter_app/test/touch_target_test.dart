import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/content/quiz_widgets.dart';
import 'package:aws_docs/data/cert_lookup.dart';
import 'package:aws_docs/data/history_store.dart';
import 'package:aws_docs/models/attempt_record.dart';
import 'package:aws_docs/models/question.dart';
import 'package:aws_docs/models/study_plan.dart';
import 'package:aws_docs/pages/plan/plan_agenda.dart';
import 'package:aws_docs/pages/report_page.dart';
import 'package:aws_docs/pages/exam/exam_bits.dart';
import 'package:aws_docs/pages/home/hero_section.dart';
import 'package:aws_docs/pages/home/home_bits.dart';
import 'package:aws_docs/pages/home/home_header.dart';
import 'package:aws_docs/theme/app_theme.dart';
import 'package:aws_docs/theme/theme_scope.dart';
import 'package:aws_docs/widgets/app_header.dart';
import 'package:aws_docs/widgets/focus_ring.dart';
import 'package:aws_docs/widgets/study_audio_player.dart';
import 'package:aws_docs/widgets/touch_target.dart';

import 'dart:io';

/// A6-1 — 터치 타깃 48dp(Material 권장).
///
/// 2026-11-19 점검(`docs/audits/2026-11-19-a6-mobile-usability-audit.md`)이 에뮬레이터
/// 접근성 트리로 미달을 찾았는데, **그 수치는 실제 탭 영역이 아니었다** —
/// `uiautomator`가 보는 노드는 [FocusRing]의 4px 패딩을 포함하고 그 띠는
/// `InkWell` 밖이라 눌리지 않는다. 위젯 테스트로 다시 재니 헤더 아이콘은 36dp,
/// 뒤로 버튼은 30×34dp였다(문서보다 8px 작다).
///
/// **처방은 A안 — 도색 크기는 그대로 두고 탭 영역만 넓힌다.** Material 3 자신의
/// 방식이고(도색 40dp + 타깃 48dp) 그래서 웹 시각이 바뀌지 않는다. 그 수단이
/// [TouchTarget]이다. 이 파일은 둘을 함께 지킨다 — **탭 영역은 48 이상**,
/// **도색은 불변**(한쪽만 보면 반대 방향으로 망가진다).
void main() {
  group('TouchTarget — 단위', () {
    testWidgets('작은 자식을 48dp 박스로 감싸되 자식 도색은 그대로다', (tester) async {
      await tester.pumpWidget(_wrap(
        const TouchTarget(child: SizedBox(width: 20, height: 20)),
      ));
      expect(tester.getSize(find.byType(TouchTarget)),
          const Size(Touch.min, Touch.min));
      expect(tester.getSize(find.byType(SizedBox).last), const Size(20, 20));
    });

    testWidgets('자식이 48보다 크면 키우지 않는다', (tester) async {
      await tester.pumpWidget(_wrap(
        const TouchTarget(child: SizedBox(width: 200, height: 60)),
      ));
      expect(tester.getSize(find.byType(TouchTarget)), const Size(200, 60));
    });

    testWidgets('자식 밖 · 48 안의 띠를 탭하면 자식이 받는다', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_wrap(TouchTarget(
        child: SizedBox(
          width: 44,
          height: 44,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => taps++,
            child: const SizedBox(),
          ),
        ),
      )));
      final Offset center = tester.getCenter(find.byType(TouchTarget));
      // 도색 44의 바깥(±22 초과) · 탭 영역 48의 안(±24 이하).
      await tester.tapAt(center + const Offset(0, 23));
      await tester.pump();
      expect(taps, 1, reason: '48dp 띠가 자식 중앙으로 돌아가야 한다');
    });

    testWidgets('48 밖은 받지 않는다 — Material 원본과 다른 경계 가드', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_wrap(TouchTarget(
        child: SizedBox(
          width: 44,
          height: 44,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => taps++,
            child: const SizedBox(),
          ),
        ),
      )));
      final Offset center = tester.getCenter(find.byType(TouchTarget));
      await tester.tapAt(center + const Offset(0, 40));
      await tester.pump();
      expect(taps, 0,
          reason: 'Material의 _RenderInputPadding은 폴백에 경계 검사가 없어 '
              '자기 밖의 포인터까지 삼킨다 — 여기서는 size 안으로 한정한다');
    });

    testWidgets('대조군: 래퍼가 없으면 같은 띠 탭이 아무 일도 하지 않는다', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_wrap(SizedBox(
        width: 44,
        height: 44,
        child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => taps++,
            child: const SizedBox(),
          ),
      )));
      final Offset center = tester.getCenter(find.byType(GestureDetector));
      await tester.tapAt(center + const Offset(0, 23));
      await tester.pump();
      expect(taps, 0, reason: '이 0이 위 테스트의 1을 의미 있게 만든다');
    });
  });

  group('공통 위젯 — 탭 영역 48dp · 도색 불변', () {
    testWidgets('HomeButton (홈 CTA)', (tester) async {
      await tester.pumpWidget(_wrap(
        HomeButton(label: '추천 순서 보기', primary: true, onTap: () {}),
      ));
      _expectTap(tester, find.byType(HomeButton));
      _expectPaintedHeight(tester, find.byType(HomeButton), 44);
    });

    testWidgets('PrimaryButton (제출)', (tester) async {
      await tester.pumpWidget(_wrap(
        PrimaryButton(label: '제출', onTap: () {}),
      ));
      _expectTap(tester, find.byType(PrimaryButton));
      _expectPaintedHeight(tester, find.byType(PrimaryButton), 44);
    });

    testWidgets('SecondaryButton (플래그·이전)', (tester) async {
      await tester.pumpWidget(_wrap(
        SecondaryButton(icon: Icons.flag_outlined, label: '플래그', onTap: () {}),
      ));
      _expectTap(tester, find.byType(SecondaryButton));
      _expectPaintedHeight(tester, find.byType(SecondaryButton), 44);
    });

    testWidgets('ExamGridSummaryChip (그리드 손잡이)', (tester) async {
      await tester.pumpWidget(_wrap(
        ExamGridSummaryChip(label: '12/65 응답', expanded: false, onTap: () {}),
      ));
      _expectTap(tester, find.byType(ExamGridSummaryChip));
      _expectPaintedHeight(tester, find.byType(ExamGridSummaryChip), 44);
    });

    testWidgets('PlayPauseButton (재생)', (tester) async {
      await tester.pumpWidget(_wrap(
        PlayPauseButton(isPlaying: false, onTap: () {}),
      ));
      _expectTap(tester, find.byType(PlayPauseButton));
      // 도색은 액센트 원형 Material이다(SizedBox는 내부에 여럿 있어 못 쓴다).
      expect(
          tester
              .getSize(find.descendant(
                  of: find.byType(PlayPauseButton),
                  matching: find.byType(Material)))
              .height,
          44);
    });

    testWidgets('HeaderIconButton (테마 토글·초기화)', (tester) async {
      await tester.pumpWidget(_wrap(
        HeaderIconButton(
            icon: Icons.dark_mode_outlined, tooltip: '다크 모드', onTap: () {}),
      ));
      _expectTap(tester, find.byType(HeaderIconButton));
      _expectPaintedHeight(tester, find.byType(HeaderIconButton), 36);
    });

    testWidgets('히어로 출처 칩', (tester) async {
      await tester.pumpWidget(_wrap(
        const SingleChildScrollView(child: SourcesRow()),
      ));
      final Finder pill = find.byType(InkWell).first;
      _expectTap(tester, pill);
      expect(tester.getSize(pill).height, 43, reason: '도색 43 유지');
    });

    testWidgets('결과 복기 필터 칩', (tester) async {
      await tester.pumpWidget(_wrap(SingleChildScrollView(
        child: ResultsView(bank: _bank(), picked: const {0: 0, 1: 0}),
      )));
      final Finder chip = find.ancestor(
        of: find.textContaining('전체 '),
        matching: find.byType(InkWell),
      );
      _expectTap(tester, chip);
      expect(tester.getSize(chip).height, 36, reason: '도색 36 유지');
    });

    testWidgets('홈 헤더 — 메뉴·설정·내비', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_wrap(Scaffold(
        appBar: HomeHeader(onNav: {'자격증': () {}}, onResetAll: () {}),
        body: const SizedBox(),
      )));
      for (final Finder f in [
        find.byType(PopupMenuButton<String>),
        find.byType(InkWell),
      ]) {
        for (var i = 0; i < f.evaluate().length; i++) {
          _expectTap(tester, f.at(i));
        }
      }
    });

    testWidgets('문서 헤더 — 뒤로 버튼', (tester) async {
      tester.view.physicalSize = const Size(1100, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_wrap(Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const Scaffold(
                    appBar: AppHeader.document(title: '오답노트'),
                    body: SizedBox(),
                  ),
                ),
              ),
              child: const Text('열기'),
            ),
          ),
        ),
      )));
      await tester.tap(find.text('열기'));
      await tester.pumpAndSettle();
      final Finder back = find.ancestor(
        of: find.byIcon(Icons.chevron_left),
        matching: find.byType(InkWell),
      );
      _expectTap(tester, back, alsoWidth: true);
    });
  });

  group('헤더 — 48 박스가 56 셸에 들어가고 도색 간격은 보존된다', () {
    testWidgets('셸 높이 56 불변 · 오버플로 없음', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_wrap(const Scaffold(
        appBar: AppHeader.document(
          title: 'AWS 클라우드의 이점과 글로벌 인프라 구조 이해',
          metaBadge: '✓ 검증됨',
          metaDate: '2026-05-27',
        ),
        body: SizedBox(),
      )));
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(AppHeader)).height,
          AppHeaderShell.height);
      expect(tester.getSize(find.byType(TouchTarget).first).height, Touch.min,
          reason: '48 < 56이라 셸에 들어간다');
    });

    testWidgets('헤더 액션 두 개의 링 박스 사이 간격 8px — 도색 사이 16px 보존',
        (tester) async {
      tester.view.physicalSize = const Size(1100, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_wrap(Scaffold(
        appBar: AppHeader.document(
          title: '학습 일정',
          actions: [
            HeaderIconButton(
                icon: Icons.delete_outline, tooltip: '초기화', onTap: () {}),
          ],
        ),
        body: const SizedBox(),
      )));
      // ⚠️ HeaderIconButton의 **루트가 이제 TouchTarget**이라 그 rect는 48
      // 박스다. 보존을 보려면 한 겹 안의 링(44)을 재야 한다 — 실측으로 배웠다.
      final Finder ringFinder = find.descendant(
          of: find.byType(HeaderIconButton), matching: find.byType(FocusRing));
      final List<Rect> rings = ringFinder
          .evaluate()
          .map((e) => tester.getRect(find.byWidget(e.widget)))
          .toList()
        ..sort((a, b) => a.left.compareTo(b.left));
      expect(rings.length, 2);
      expect(rings[0].height, 44, reason: '링 박스는 도색 36 + 2+2');
      expect(rings[1].left - rings[0].right, Gap.sm,
          reason: '링 박스(44) 사이 8px = 도색(36) 사이 16px. '
              'TouchTarget이 2px/side를 더하므로 간격 토큰을 Gap.xs로 줄여 보존한다');
    });
  });

  group('예외 — 문항 번호 그리드', () {
    testWidgets('GridChip은 34dp를 유지한다', (tester) async {
      await tester.pumpWidget(_wrap(
        GridChip(
            label: '1',
            answered: false,
            flagged: false,
            current: true,
            onTap: () {}),
      ));
      expect(tester.getSize(find.byType(GridChip)), const Size(34, 34),
          reason: '2026-10-30 결정이 65칩 그리드를 360px에 맞춰 설계했다 — '
              '48로 키우면 그 작업을 되돌린다. 대신 간격으로 완화 조건을 맞춘다');
    });

    test('그리드 간격이 8dp 이상이다 — Material의 sub-48 완화 조건', () {
      final String src =
          File('lib/pages/exam/exam_view.dart').readAsStringSync();
      expect(src, contains('GridChip('), reason: '대조군: 파일을 실제로 읽었다');
      final int i = src.indexOf('Widget _grid() => Wrap(');
      expect(i, greaterThan(0));
      final String head = src.substring(i, i + 200);
      expect(head, contains('spacing: Gap.sm'));
      expect(head, contains('runSpacing: Gap.sm'));
      expect(head, isNot(contains('Gap.xs')),
          reason: '4dp로는 34dp 칩의 완화 조건(≥8dp)을 못 맞춘다');
    });
  });

  // A6-1이 공통 위젯 9종을 고쳤지만 **페이지 안에서 직접 만든 표면**은 그 목록에
  // 없었다. 2026-11-20 A6 체크리스트 순회(에뮬레이터 16화면)가 셋을 더 찾았다 —
  // 전부 `TouchTarget` 미적용이고 DESIGN.md의 「모든 인터랙티브의 탭 영역은 48dp
  // 이상」을 어긴다. 수치는 그 측정의 실측값이다.
  group('A6-5~7 — 페이지 안의 미적용 표면', () {
    testWidgets('학습 일정 아젠다 — 항목 완료 체크박스', (tester) async {
      // ⚠️ 가장 심한 미달이자 **실측으로 확정한** 자리다(2026-11-20): 노드 중심
      // 탭은 먹고, 32dp 밖·48dp 안은 **먹지 않았다**. 29개 항목을 지워 나가는
      // 이 화면에서 가장 자주 눌리는 요소다.
      await tester.pumpWidget(_wrap(_agenda()));
      await tester.pumpAndSettle();
      final Finder cb = find.byType(Checkbox);
      expect(cb, findsWidgets, reason: '대조군: 아젠다에 체크박스가 그려졌다');
      _expectTap(tester, cb.first, alsoWidth: true);
    });

    testWidgets('학습 일정 아젠다 — 재분배·다시 만들기', (tester) async {
      await tester.pumpWidget(_wrap(_agenda()));
      await tester.pumpAndSettle();
      for (final String label in ['재분배', '다시 만들기']) {
        final Finder btn = find.ancestor(
            of: find.text(label), matching: find.byType(TextButton));
        expect(btn, findsOneWidget, reason: '대조군: $label 버튼이 있다');
        _expectTap(tester, btn);
      }
    });

    testWidgets('학습 일정 아젠다 — 월 보기·일정 삭제', (tester) async {
      await tester.pumpWidget(_wrap(_agenda(onDelete: () {})));
      await tester.pumpAndSettle();
      final Finder icons = find.byType(IconButton);
      expect(icons, findsNWidgets(2), reason: '대조군: 월 보기 + 일정 삭제');
      for (var i = 0; i < 2; i++) {
        _expectTap(tester, icons.at(i), alsoWidth: true);
      }
    });

    testWidgets('약점 리포트 — 학습문서 링크·개념 칩', (tester) async {
      tester.view.physicalSize = const Size(1200, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final KvBackend b = MemoryBackend();
      // weak(정답률 70% 미만) Task가 있어야 링크와 개념 칩이 그려진다.
      // ⚠️ `presentedQuestionIds`를 비우면 `resolvePresented`가 examId로 **그 Task
      // 전 문항**을 출제로 잡아 13/15 = 87%가 되어 weak가 되지 않는다(실측).
      HistoryStore(backend: b).add(const AttemptRecord(
        certId: 'CLF-C02',
        examId: 'practice:clf-t1-1',
        mode: 'practice',
        date: '2026-11-20T00:00:00.000Z',
        correct: 0,
        total: 2,
        presentedQuestionIds: ['clf-t1-1-q1', 'clf-t1-1-q2'],
        wrongQuestionIds: ['clf-t1-1-q1', 'clf-t1-1-q2'],
        flaggedQuestionIds: [],
        durationSpentSec: 10,
      ));
      await tester.pumpWidget(_wrap(
          ReportPage(cert: certByCode('CLF-C02')!, backend: b)));
      await tester.pumpAndSettle();
      final Finder link = find.ancestor(
          of: find.text('학습문서 →'), matching: find.byType(InkWell));
      expect(link, findsWidgets, reason: '대조군: weak Task의 학습문서 링크');
      _expectTap(tester, link.first);
    });

    testWidgets('시험 결과 — 오답 복기의 학습문서 링크', (tester) async {
      await tester.pumpWidget(_wrap(SingleChildScrollView(
        child: ResultsView(
          // ⚠️ 개념 처방 큐는 `!isCorrect && q.skill.isNotEmpty`일 때만 그려진다.
          bank: _bankWithSkill(),
          picked: const {0: 0}, // 오답 → 복기 카드가 열린다
          onOpenStudy: (_, _) {},
        ),
      )));
      await tester.pumpAndSettle();
      final Finder link = find.ancestor(
          of: find.text('→ 학습문서'), matching: find.byType(InkWell));
      expect(link, findsWidgets, reason: '대조군: 개념 처방 큐의 학습 링크');
      _expectTap(tester, link.first);
    });
  });
}

/// A6-5 가드용 아젠다 — 항목이 있어야 체크박스가 그려진다.
Widget _agenda({VoidCallback? onDelete}) => PlanAgenda(
      cert: certByCode('CLF-C02')!,
      plan: StudyPlan(
        certCode: 'CLF-C02',
        startIso: '2026-11-20',
        endIso: '2026-12-04',
        mode: PlanMode.examDate,
        createdIso: '2026-11-20',
        items: const [
          PlanItem(
              id: 'i1',
              dateIso: '2026-11-20',
              type: PlanItemType.doc,
              phase: PlanPhase.learn,
              refId: 'clf-t1-1'),
          PlanItem(
              id: 'i2',
              dateIso: '2026-11-21',
              type: PlanItemType.quiz,
              phase: PlanPhase.learn,
              refId: 'clf-t1-1'),
        ],
      ),
      today: '2026-11-20',
      onEdit: () {},
      onChanged: (_) {},
      onDelete: onDelete,
      backend: MemoryBackend(),
    );

Widget _wrap(Widget child) => ThemeScope(
      isDark: false,
      toggle: () {},
      child: MaterialApp(
        theme: AppTheme.light,
        home: child is Scaffold || child is Builder
            ? child
            : Scaffold(body: Center(child: child)),
      ),
    );

/// 해당 표면이 [TouchTarget]으로 감싸여 탭 영역이 48dp 이상인지.
///
/// ⚠️ 위젯 클래스를 주면 래퍼는 그 **자손**이고(build 안에서 감쌌다),
/// InkWell 같은 내부 노드를 주면 **조상**이다. 둘 다 받는다 — 한쪽만 보면
/// 멀쩡한 표면을 "감싸지 않았다"고 거부한다(실측으로 배웠다).
void _expectTap(WidgetTester tester, Finder painted, {bool alsoWidth = false}) {
  Finder box = find.descendant(
      of: painted, matching: find.byType(TouchTarget), matchRoot: true);
  if (box.evaluate().isEmpty) {
    box = find.ancestor(of: painted, matching: find.byType(TouchTarget));
  }
  expect(box, findsWidgets,
      reason: '이 표면이 TouchTarget으로 감싸여 있지 않다(A6-1)');
  final Size size = tester.getSize(box.first);
  expect(size.height, greaterThanOrEqualTo(Touch.min));
  if (alsoWidth) expect(size.width, greaterThanOrEqualTo(Touch.min));
}

/// 도색 크기 불변(A안의 핵심) — 보이는 상자의 높이.
void _expectPaintedHeight(
    WidgetTester tester, Finder owner, double expected) {
  expect(
      tester
          .getSize(find
              .descendant(of: owner, matching: find.byType(Container))
              .last)
          .height,
      expected,
      reason: '도색 크기는 바뀌지 않아야 한다(웹 시각 변화 0)');
}

Question _q(String id, {required int correct}) => Question(
      id: id,
      examGuideTaskId: 'clf-t1-1',
      stem: '$id 지문',
      options: const ['보기 A', '보기 B'],
      correct: correct,
      explanation: '$id 해설',
      wrongExplanations: const {},
      sources: const [],
      verified: true,
    );

QuestionBank _bank() => QuestionBank(
      examGuideTaskId: 'CLF-C02-mock',
      taskTitle: '통합 모의고사',
      certCode: 'CLF-C02',
      domain: 0,
      questions: [_q('q1', correct: 1), _q('q2', correct: 0)],
    );

/// A6-7 가드용 — 개념 처방 큐는 `skill`이 있어야 그려진다.
QuestionBank _bankWithSkill() => QuestionBank(
      examGuideTaskId: 'clf-t1-1',
      taskTitle: 'AWS 클라우드의 이점',
      certCode: 'CLF-C02',
      domain: 1,
      questions: [
        Question(
          id: 'clf-t1-1-q1',
          examGuideTaskId: 'clf-t1-1',
          stem: 'q1 지문',
          options: const ['보기 A', '보기 B'],
          correct: 1,
          explanation: 'q1 해설',
          wrongExplanations: const {},
          sources: const [],
          verified: true,
          skill: '클라우드 컴퓨팅 정의 (가치 제안)',
        ),
      ],
    );
