// CertExamPage 진행 세션 복원 가드 — 스냅샷 체제(설계 2026-10-24 §4.1·§4.3·§4.5).
//
// 2026-10-24 판에서는 `questionIds` + `optionOrders` 대조가 복원 계약이었다. 스냅샷
// 도입으로 복원이 **에셋을 전혀 읽지 않게** 되면서 그 계약이 사라졌으므로 다시 썼다.
//
// ⚠️ 라우터로 `/cert/:code/exam`에 들어가면 부모 CertDetailPage(SelectionArea)가
// 스택에 빌드돼 렌더가 깨진다. 그래서 CertExamPage를 **직접** 렌더한다.
// ⚠️ 에셋을 읽는 페이지를 한 파일에서 두 번 이상 렌더하면 rootBundle 캐시 때문에
// 다음 테스트가 예외 없이 멈춘다 → setUp(rootBundle.clear).
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';

import 'package:aws_docs/data/cert_lookup.dart';
import 'package:aws_docs/data/content_index.dart'
    show certExamHasWeightedCapacity;
import 'package:aws_docs/data/exam_session_store.dart';
import 'package:aws_docs/data/history_store.dart' show KvBackend, MemoryBackend;
import 'package:aws_docs/models/exam_snapshot.dart';
import 'package:aws_docs/models/question.dart';
import 'package:aws_docs/pages/cert_exam_page.dart';
import 'package:aws_docs/theme/app_theme.dart';
import 'package:aws_docs/theme/theme_scope.dart';
import 'package:aws_docs/widgets/app_header.dart';

/// 키별 쓰기 횟수를 세는 백엔드.
class _CountingBackend extends MemoryBackend {
  final counts = <String, int>{};
  @override
  void write(String key, String value) {
    counts[key] = (counts[key] ?? 0) + 1;
    super.write(key, value);
  }

  int writeCount(String key) => counts[key] ?? 0;
}

/// 스냅샷 키 쓰기만 실패시키는 백엔드(쿼터 초과 모사).
class _QuotaOnSnapshot extends MemoryBackend {
  @override
  void write(String key, String value) {
    if (key.startsWith('awsdocs.examSnapshot.v1:')) {
      throw StateError('QuotaExceededError');
    }
    super.write(key, value);
  }
}

Widget _wrap(Widget child) => ThemeScope(
      isDark: false,
      toggle: () {},
      child: MaterialApp(theme: AppTheme.light, home: child),
    );

Question _snapQ(String id, String stem) => Question(
      id: id,
      examGuideTaskId: 'snap',
      skill: '',
      section: '',
      difficulty: '',
      stem: stem,
      options: const ['보기 하나', '보기 둘'],
      correct: 0,
      explanation: '',
      wrongExplanations: const {},
      sources: const [],
      verified: true,
    );

ExamSnapshot _snapshot(String code, {String nonce = 'run-1'}) => ExamSnapshot(
      examId: 'exam:$code-mock',
      certId: code,
      taskId: '$code-mock',
      nonce: nonce,
      startedAtIso: DateTime.now().toIso8601String(),
      durationSec: 5400,
      questions: [_snapQ('s1', '스냅샷 전용 문항'), _snapQ('s2', '두 번째')],
    );

Future<void> _pump(
  WidgetTester tester,
  String code,
  KvBackend backend, {
  Size size = const Size(1400, 2400),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
      _wrap(CertExamPage(cert: certByCode(code)!, backend: backend)));
  await tester.pump();
  await tester.pumpAndSettle(
    const Duration(milliseconds: 100),
    EnginePhase.sendSemanticsUpdate,
    const Duration(seconds: 10),
  );
}

void main() {
  setUp(rootBundle.clear);

  test('전제: CLF-C02는 통합 모의고사 capacity 충족, SAA-C03은 미충족', () {
    // 아래 게이트 테스트가 기대는 사실 — 바뀌면 그 테스트부터 다시 읽어야 한다.
    expect(certExamHasWeightedCapacity('CLF-C02'), isTrue);
    expect(certExamHasWeightedCapacity('SAA-C03'), isFalse);
  });

  testWidgets('⚠️ capacity 미충족에서도 진행 세션을 지우지 않는다(잠금 화면에 "이어서 풀기")',
      (tester) async {
    // 설계 §4.3 — 게이트가 세션을 지워 버리면 이 버튼이 아예 렌더되지 않는다.
    // 버튼이 **실제로 시험을 여는지**는 exam_snapshot_review_fixes_test의 C-1 가드가 본다.
    final b = MemoryBackend();
    ExamSessionStore(backend: b).saveSnapshot(_snapshot('SAA-C03'));

    await _pump(tester, 'SAA-C03', b);

    expect(find.text('이어서 풀기'), findsOneWidget);
  });

  testWidgets('capacity 미충족에서 새 시험 시작은 여전히 막힌다', (tester) async {
    final b = MemoryBackend(); // 진행 세션 없음
    await _pump(tester, 'SAA-C03', b);
    expect(find.text('시작'), findsNothing);
    expect(find.text('이어서 풀기'), findsNothing);
  });

  testWidgets('⚠️ 스냅샷 문항이 현재 에셋과 달라도 그대로 출제된다', (tester) async {
    final b = MemoryBackend();
    ExamSessionStore(backend: b).saveSnapshot(_snapshot('CLF-C02'));

    await _pump(tester, 'CLF-C02', b);
    await tester.tap(find.text('이어서 풀기'));
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 10),
    );

    expect(find.text('스냅샷 전용 문항'), findsOneWidget);
  });

  testWidgets('시작 버튼이 스냅샷을 1회 쓴다', (tester) async {
    final b = _CountingBackend();
    await _pump(tester, 'CLF-C02', b);

    await tester.tap(find.text('시작'));
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 10),
    );

    final snap = ExamSessionStore(backend: b).loadSnapshot('exam:CLF-C02-mock');
    expect(snap, isNotNull);
    expect(snap!.questions, isNotEmpty);
    expect(b.writeCount('awsdocs.examSnapshot.v1:exam:CLF-C02-mock'), 1,
        reason: '"1회"는 이름만이 아니라 단언돼야 한다(설계 §4.4)');
  });

  testWidgets('⚠️ 통합 모의고사도 시험 중 스냅샷을 다시 쓰지 않는다', (tester) async {
    // 설계 §4.4의 존재 이유 — 깨지면 매 탭 112 KB를 다시 쓴다. ExamPage 쪽은
    // exam_page_snapshot_test가 보고 있고, 시작 화면이 있는 이 경로는 가드가 없었다.
    final b = _CountingBackend();
    await _pump(tester, 'CLF-C02', b);
    await tester.tap(find.text('시작'));
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 10),
    );

    await tester.tap(find.text('2')); // 문항 그리드 2번으로 이동 → 진행 저장
    await tester.pump();

    expect(b.writeCount('awsdocs.examSnapshot.v1:exam:CLF-C02-mock'), 1);
    expect(b.writeCount('awsdocs.examProgress.v1:exam:CLF-C02-mock'),
        greaterThanOrEqualTo(1));
  });

  testWidgets('만료된 스냅샷으로 진입하면 복원하지 않고 새 시험을 시작한다', (tester) async {
    // 진입 경로는 clearExpired가 먼저 돈다(§4.6) — 그래서 만료 세션은 "이어서 풀기"로
    // 되살아나지 않고, 0점 자동 제출로 이력을 오염시키지도 않는다.
    final b = MemoryBackend();
    ExamSessionStore(backend: b).saveSnapshot(ExamSnapshot(
      examId: 'exam:CLF-C02-mock',
      certId: 'CLF-C02',
      taskId: 'CLF-C02-mock',
      nonce: 'run-old',
      startedAtIso:
          DateTime.now().subtract(const Duration(days: 2)).toUtc().toIso8601String(),
      durationSec: 5400,
      questions: [_snapQ('s1', '스냅샷 전용 문항')],
    ));

    await _pump(tester, 'CLF-C02', b);

    expect(find.text('이어서 풀기'), findsNothing);
    expect(find.text('시작'), findsOneWidget);
    expect(ExamSessionStore(backend: b).loadSnapshot('exam:CLF-C02-mock'), isNull,
        reason: '만료분은 진입 시 정리된다');
  });

  testWidgets('구포맷 세션은 복원하지 않고 새 시험 시작 화면', (tester) async {
    final b = MemoryBackend();
    b.write('awsdocs.examSession.v1:exam:CLF-C02-mock',
        '{"examId":"exam:CLF-C02-mock"}');

    await _pump(tester, 'CLF-C02', b);

    expect(find.text('이어서 풀기'), findsNothing);
    expect(find.text('시작'), findsOneWidget);
  });

  testWidgets('⚠️ 스냅샷 쓰기가 실패해도 시험 시작이 막히지 않는다', (tester) async {
    // 반목표 — 저장 실패가 시작 자체를 막으면 안 된다.
    final b = _QuotaOnSnapshot();
    await _pump(tester, 'CLF-C02', b);

    await tester.tap(find.text('시작'));
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 10),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('시작'), findsNothing, reason: '시험 화면으로 넘어갔다');
  });

  testWidgets('시작 시각을 타임존이 명시된 ISO로 저장한다', (tester) async {
    // 오프셋 없는 로컬 벽시계로 저장하면 DST·시간대 이동 뒤 clearExpired가 **살아 있는**
    // 세션을 만료로 오판할 수 있다(반목표: 오히려 세션을 잃는 것).
    final b = MemoryBackend();
    await _pump(tester, 'CLF-C02', b);

    await tester.tap(find.text('시작'));
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 10),
    );

    final iso =
        ExamSessionStore(backend: b).loadSnapshot('exam:CLF-C02-mock')!.startedAtIso;
    expect(DateTime.parse(iso).isUtc, isTrue,
        reason: '타임존이 박혀 있어야 오프셋이 바뀌어도 같은 절대 시각으로 읽힌다');
  });

  testWidgets('진입이 구포맷 키를 빈 값으로 새로 만들지 않는다', (tester) async {
    final b = MemoryBackend();
    await _pump(tester, 'CLF-C02', b);

    expect(b.keys().where((k) => k.startsWith('awsdocs.examSession.v1:')), isEmpty,
        reason: '없던 키에 빈 값을 쓰면 진입마다 영구 축적된다');
  });

  testWidgets('짧은 뷰포트에서도 잠금 화면에서 이어서 풀 수 있다', (tester) async {
    // 비스크롤 Column이면 덧붙인 버튼이 잘려 **탭조차 못 한다** — §4.3이 통째로 막힌다.
    final b = MemoryBackend();
    ExamSessionStore(backend: b).saveSnapshot(_snapshot('SAA-C03'));

    await _pump(tester, 'SAA-C03', b, size: const Size(400, 240));

    expect(tester.takeException(), isNull, reason: '오버플로 없이 렌더돼야 한다');
    await tester.ensureVisible(find.text('이어서 풀기')); // 스크롤 조상이 없으면 여기서 던진다
    await tester.tap(find.text('이어서 풀기'));
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 10),
    );

    expect(find.text('스냅샷 전용 문항'), findsOneWidget);
  });

  testWidgets('짧은 뷰포트에서도 시작 화면이 넘치지 않는다', (tester) async {
    final b = MemoryBackend();

    await _pump(tester, 'CLF-C02', b, size: const Size(400, 240));

    expect(tester.takeException(), isNull);
    expect(find.text('시작'), findsOneWidget);
  });

  testWidgets('짧은 뷰포트에서 시작 화면 첫 줄이 글래스 헤더에 가리지 않는다', (tester) async {
    // body가 헤더 **뒤까지** 깔리므로(extendBodyBehindAppBar) 스크롤 상단 인셋이 없으면
    // 첫 줄이 헤더에 덮여 읽을 수 없다 — 레포의 다른 스크롤 페이지는 전부 인셋을 쓴다.
    final b = MemoryBackend();

    await _pump(tester, 'CLF-C02', b, size: const Size(400, 360));

    final title = find.descendant(
      of: find.byType(SingleChildScrollView),
      matching: find.text('통합 모의고사'),
    );
    expect(
      tester.getTopLeft(title).dy,
      greaterThanOrEqualTo(tester.getBottomLeft(find.byType(AppHeader)).dy),
    );
  });
}
