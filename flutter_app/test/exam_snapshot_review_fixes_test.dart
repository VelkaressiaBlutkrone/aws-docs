// 최종 리뷰(2026-10-25)가 찾은 Critical 1 · Important 4를 재현·고정하는 가드.
//
// 각 테스트는 수정 전에 실패해야 한다 — 그게 발견이 실재했다는 유일한 증거다.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';

import 'package:aws_docs/data/cert_lookup.dart';
import 'package:aws_docs/data/content_index.dart';
import 'package:aws_docs/data/exam_session_store.dart';
import 'package:aws_docs/data/history_store.dart' show KvBackend, MemoryBackend;
import 'package:aws_docs/models/exam_snapshot.dart';
import 'package:aws_docs/models/question.dart';
import 'package:aws_docs/pages/cert_exam_page.dart';
import 'package:aws_docs/pages/exam_page.dart';
import 'package:aws_docs/theme/app_theme.dart';
import 'package:aws_docs/theme/theme_scope.dart';

/// 스냅샷 쓰기를 **무장한 뒤부터** 실패시킨다 — 사전 세팅(심기)은 통과해야 하므로
/// 생성자부터 던지면 테스트가 세우지도 못한다.
class _QuotaOnSnapshot extends MemoryBackend {
  bool armed = false;
  @override
  void write(String key, String value) {
    // ⚠️ 빈 문자열 쓰기(= 삭제)는 통과시킨다. 쿼터 초과는 **늘리는** 쓰기를 막지
    // 줄이는 쓰기를 막지 않는다 — 삭제까지 막으면 실제로는 없는 상태를 모사하게 된다.
    if (armed &&
        value.isNotEmpty &&
        key.startsWith('awsdocs.examSnapshot.v1:')) {
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

Question _q(String id, String stem) => Question(
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

ExamSnapshot _snapshot(
  String examId, {
  String nonce = 'run-1',
  int? passingScore,
  DateTime? startedAt,
}) =>
    ExamSnapshot(
      examId: examId,
      certId: 'CLF-C02',
      taskId: 'clf-mock',
      nonce: nonce,
      startedAtIso: (startedAt ?? DateTime.now()).toIso8601String(),
      durationSec: 5400,
      questions: [_q('s1', '스냅샷 전용 문항'), _q('s2', '두 번째')],
      passingScore: passingScore,
    );

Future<void> _settle(WidgetTester tester) => tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 10),
    );

Future<void> _pumpCert(
    WidgetTester tester, String code, KvBackend backend) async {
  tester.view.physicalSize = const Size(1400, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
      _wrap(CertExamPage(cert: certByCode(code)!, backend: backend)));
  await tester.pump();
  await _settle(tester);
}

void main() {
  setUp(rootBundle.clear);

  testWidgets('C-1: 잠금 화면의 "이어서 풀기"가 실제로 시험을 연다', (tester) async {
    // build에서 `_running` 검사가 잠금 분기 뒤에 있으면 탭해도 화면이 안 바뀐다.
    final b = MemoryBackend();
    ExamSessionStore(backend: b).saveSnapshot(_snapshot('exam:SAA-C03-mock'));

    await _pumpCert(tester, 'SAA-C03', b);
    await tester.tap(find.text('이어서 풀기'));
    await _settle(tester);

    expect(find.text('스냅샷 전용 문항'), findsOneWidget,
        reason: '§4.3 — 게이트에 막혀도 풀던 시험은 끝낼 수 있어야 한다');
  });

  testWidgets('I-3: 스냅샷 쓰기가 실패해도 옛 시험이 되살아나지 않는다', (tester) async {
    // _startFresh가 clearRun을 안 하면 옛 스냅샷 + 새 nonce 진행이 남는다.
    final b = _QuotaOnSnapshot();
    ExamSessionStore(backend: b).saveSnapshot(
        ExamSnapshot.fromJson(_snapshot('exam:CLF-C02-mock').toJson()));
    b.armed = true; // 심은 뒤부터 쓰기 실패

    await _pumpCert(tester, 'CLF-C02', b);
    await tester.tap(find.text('새로 시작'));
    await _settle(tester);

    expect(ExamSessionStore(backend: b).loadRun('exam:CLF-C02-mock'), isNull,
        reason: '새 시험을 시작했으면 옛 런은 남아 있으면 안 된다');
  });

  test('I-4: 퇴화 스냅샷(문항 0개)은 복원 후보가 아니다', () {
    final b = MemoryBackend();
    b.write('awsdocs.examSnapshot.v1:exam:X',
        '{"examId":"exam:X","questions":[],"durationSec":5400}');
    expect(ExamSessionStore(backend: b).loadRun('exam:X'), isNull,
        reason: '문항 0개 스냅샷으로 복원하면 _qs[_index]가 RangeError를 던진다');
  });

  test('I-4: durationSec이 0 이하인 스냅샷도 복원 후보가 아니다', () {
    final b = MemoryBackend();
    final json = _snapshot('exam:Y').toJson()..['durationSec'] = 0;
    ExamSessionStore(backend: b)
        .saveSnapshot(ExamSnapshot.fromJson(Map<String, dynamic>.from(json)));
    expect(ExamSessionStore(backend: b).loadRun('exam:Y'), isNull,
        reason: '복원하자마자 자동 제출돼 이력이 오염된다');
  });

  test('I-5: 스냅샷이 합격선을 들고 간다', () {
    final back = ExamSnapshot.fromJson(_snapshot('exam:Z', passingScore: 700).toJson());
    expect(back.passingScore, 700,
        reason: '§2 — 결과 화면 부제도 그때 보던 그대로여야 한다');
  });

  testWidgets('I-5: ExamPage 복원이 합격선을 유지한다', (tester) async {
    final entry = contentFor('CLF-C02').firstWhere((e) => e.hasQuestions);
    final examId = 'exam:${entry.taskId}';
    final b = MemoryBackend();
    ExamSessionStore(backend: b)
        .saveSnapshot(_snapshot(examId, passingScore: 700));

    tester.view.physicalSize = const Size(1400, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_wrap(ExamPage(entry: entry, backend: b)));
    await tester.pump();
    await _settle(tester);

    // ⚠️ 저장소를 되읽는 것은 테스트가 심은 값을 다시 보는 것뿐이다(빈 통과). 페이지가
    // 스냅샷의 합격선을 **ExamView까지** 넘겼는지 위젯 트리에서 직접 본다.
    expect(tester.widget<ExamView>(find.byType(ExamView)).passingScore, 700);
    expect(find.text('스냅샷 전용 문항'), findsOneWidget);
  });

  testWidgets('I-2: 시험 화면 진입이 만료 세션을 정리한다', (tester) async {
    // clearExpired에 호출처가 없으면 버려진 스냅샷이 무한히 쌓인다(§4.6).
    final b = MemoryBackend();
    final store = ExamSessionStore(backend: b);
    store.saveSnapshot(_snapshot('exam:STALE-mock',
        startedAt: DateTime.now().subtract(const Duration(days: 2))));

    await _pumpCert(tester, 'CLF-C02', b);

    expect(store.loadSnapshot('exam:STALE-mock'), isNull,
        reason: '제한 시간이 지난 세션은 정리돼야 한다');
  });
}
