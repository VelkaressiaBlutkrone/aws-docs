// ExamPage 스냅샷 복원·저장 가드(Task 5) — 설계 2026-10-24 §4.1·§4.5.
//
// ⚠️ 에셋을 읽는 페이지를 한 파일에서 두 번 이상 렌더하면 rootBundle 캐시에 앞 테스트
// zone의 future가 남아 다음 테스트가 **예외 없이 멈춘다** → setUp(rootBundle.clear).
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';

import 'package:aws_docs/data/content_index.dart';
import 'package:aws_docs/data/exam_session_store.dart';
import 'package:aws_docs/data/history_store.dart' show KvBackend, MemoryBackend;
import 'package:aws_docs/models/exam_snapshot.dart';
import 'package:aws_docs/models/question.dart';
import 'package:aws_docs/pages/exam_page.dart';
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

ContentEntry _entry() =>
    contentFor('CLF-C02').firstWhere((e) => e.hasQuestions);

Widget _wrap(Widget child) => ThemeScope(
      isDark: false,
      toggle: () {},
      child: MaterialApp(theme: AppTheme.light, home: child),
    );

Question _snapQ(String id, String stem) => Question(
      id: id,
      examGuideTaskId: _entry().taskId,
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

ExamSnapshot _snapshot({String nonce = 'run-1'}) => ExamSnapshot(
      examId: 'exam:${_entry().taskId}',
      certId: _entry().certForHistory,
      taskId: _entry().taskId,
      nonce: nonce,
      startedAtIso: DateTime.now().toIso8601String(),
      durationSec: 5400,
      questions: [_snapQ('snap-1', '스냅샷 전용 문항'), _snapQ('snap-2', '두 번째')],
    );

Future<void> _pump(WidgetTester tester, KvBackend backend) async {
  tester.view.physicalSize = const Size(1400, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_wrap(ExamPage(entry: _entry(), backend: backend)));
  await tester.pump();
  await tester.pumpAndSettle(
    const Duration(milliseconds: 100),
    EnginePhase.sendSemanticsUpdate,
    const Duration(seconds: 10),
  );
}

void main() {
  setUp(rootBundle.clear);

  testWidgets('⚠️ 릴리스를 가로질러도 스냅샷 문항이 유지된다', (tester) async {
    // 에셋에 없는 stem을 스냅샷에 심는다 — 복원이 에셋을 읽으면 이 문구는 안 보인다.
    final b = MemoryBackend();
    ExamSessionStore(backend: b).saveSnapshot(_snapshot());

    await _pump(tester, b);

    expect(find.text('스냅샷 전용 문항'), findsOneWidget);
  });

  testWidgets('진입만 하고 상호작용이 없으면 스냅샷을 쓰지 않는다', (tester) async {
    final b = MemoryBackend();
    await _pump(tester, b);
    expect(ExamSessionStore(backend: b).loadSnapshot('exam:${_entry().taskId}'),
        isNull,
        reason: '설계 §4.5 — Task 시험은 첫 상호작용부터 저장한다');
  });

  testWidgets('첫 응답에서 스냅샷과 진행이 함께 저장된다', (tester) async {
    final b = MemoryBackend();
    await _pump(tester, b);

    await tester.tap(find.byType(InkWell).first);
    await tester.pump();

    final store = ExamSessionStore(backend: b);
    final examId = 'exam:${_entry().taskId}';
    final snap = store.loadSnapshot(examId);
    final prog = store.loadProgress(examId);
    expect(snap, isNotNull);
    expect(prog, isNotNull);
    expect(prog!.nonce, snap!.nonce, reason: '같은 세대여야 짝으로 인정된다');
  });

  testWidgets('⚠️ 스냅샷 쓰기가 실패해도 시험은 진행된다', (tester) async {
    // 반목표 — 저장 실패가 시험을 막으면 안 된다.
    final b = _QuotaOnSnapshot();
    await _pump(tester, b);

    await tester.tap(find.byType(InkWell).first);
    await tester.pump();

    expect(tester.takeException(), isNull, reason: '예외가 사용자에게 닿으면 안 된다');
    expect(find.byType(ExamPage), findsOneWidget);
  });

  testWidgets('구포맷 examSession 키는 복원하지 않고 비운다', (tester) async {
    final b = MemoryBackend();
    final examId = 'exam:${_entry().taskId}';
    b.write('awsdocs.examSession.v1:$examId', '{"examId":"$examId"}');

    await _pump(tester, b);

    expect(b.read('awsdocs.examSession.v1:$examId'), isEmpty,
        reason: '설계 §4.8 — 구포맷 세션은 폐기한다');
  });

  testWidgets('⚠️ 스냅샷은 시험 중 다시 쓰이지 않는다', (tester) async {
    // 설계 §4.4의 존재 이유 — 깨지면 매 탭 112 KB를 다시 쓴다.
    final b = _CountingBackend();
    await _pump(tester, b);

    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byType(InkWell).first);
      await tester.pump();
    }

    final examId = 'exam:${_entry().taskId}';
    expect(b.writeCount('awsdocs.examSnapshot.v1:$examId'), 1);
    expect(b.writeCount('awsdocs.examProgress.v1:$examId'), greaterThan(1));
  });

  testWidgets('시작 시각을 타임존이 명시된 ISO로 저장한다', (tester) async {
    // 오프셋 없는 로컬 벽시계로 저장하면 DST·시간대 이동 뒤 clearExpired가 **살아 있는**
    // 세션을 만료로 오판할 수 있다(반목표: 오히려 세션을 잃는 것).
    final b = MemoryBackend();
    await _pump(tester, b);

    await tester.tap(find.byType(InkWell).first);
    await tester.pump();

    final iso = ExamSessionStore(backend: b)
        .loadSnapshot('exam:${_entry().taskId}')!
        .startedAtIso;
    expect(DateTime.parse(iso).isUtc, isTrue,
        reason: '타임존이 박혀 있어야 오프셋이 바뀌어도 같은 절대 시각으로 읽힌다');
  });

  testWidgets('⚠️ nonce가 어긋난 진행을 버렸으면 복원했다고 말하지 않는다', (tester) async {
    // §4.4.1 — 두 탭·부분 쓰기로 세대가 엇갈리면 진행을 버린다. 그때도 "이전 진행을
    // 복원했습니다"가 떠서, 답이 하나도 없는 화면이 거짓말을 했다.
    final b = MemoryBackend();
    final store = ExamSessionStore(backend: b);
    store.saveSnapshot(_snapshot(nonce: 'run-2'));
    store.saveProgress(ExamProgress(
      examId: 'exam:${_entry().taskId}',
      nonce: 'run-1', // 옛 세대
      index: 1,
      picked: const {0: 1},
      flagged: const [],
    ));

    await _pump(tester, b);

    expect(find.text('이전 진행을 복원했습니다.'), findsNothing);
    expect(find.text('이전 진행은 복원하지 못해 처음부터 표시합니다.'), findsOneWidget);
  });

  testWidgets('진입이 구포맷 키를 빈 값으로 새로 만들지 않는다', (tester) async {
    final b = MemoryBackend();
    await _pump(tester, b);

    expect(b.keys().where((k) => k.startsWith('awsdocs.examSession.v1:')), isEmpty,
        reason: '없던 키에 빈 값을 쓰면 진입마다 영구 축적된다');
  });
}
