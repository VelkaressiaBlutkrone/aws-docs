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

Future<void> _pump(WidgetTester tester, String code, KvBackend backend) async {
  tester.view.physicalSize = const Size(1400, 2400);
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

  testWidgets('⚠️ capacity가 미충족이어도 진행 중 시험은 살아남는다', (tester) async {
    // 설계 §4.3 — 문항을 내리는 릴리스가 capacity를 뒤집어도 풀던 시험을 뺏지 않는다.
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
    final b = MemoryBackend();
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
}
