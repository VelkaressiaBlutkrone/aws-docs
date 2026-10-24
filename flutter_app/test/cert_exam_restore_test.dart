// CertExamPage의 진행 세션 복원 판정(cert_exam_page.dart `_load()` §복원 분기).
//
// 구성 요소(restoreOrdered·ordersCoverQuestions·ExamSessionStore)는 각각
// mock_exam_test·exam_session_test가 덮고 있었지만, **그것들을 조합해 "복원할까
// 폐기할까"를 정하는 페이지 쪽 판정**과 폐기 시의 `_store.clear(_examId)` 부수효과는
// 어떤 테스트에도 걸려 있지 않았다. 이 파일이 그 공백을 메운다.
//
// ⚠️ 라우터로 `/cert/:code/exam`에 들어가면 부모 CertDetailPage(SelectionArea)가
// 스택에 빌드돼 렌더가 깨진다. 그래서 여기서는 CertExamPage를 **직접** 렌더한다.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';

import 'package:aws_docs/data/cert_lookup.dart';
import 'package:aws_docs/data/content_index.dart';
import 'package:aws_docs/data/exam_session_store.dart';
import 'package:aws_docs/data/history_store.dart' show MemoryBackend;
import 'package:aws_docs/models/exam_session.dart';
import 'package:aws_docs/models/question.dart';
import 'package:aws_docs/pages/cert_exam_page.dart';
import 'package:aws_docs/theme/app_theme.dart';
import 'package:aws_docs/theme/theme_scope.dart';

const _cert = 'CLF-C02';
const _examId = 'exam:$_cert-mock'; // 통합 모의고사(weighted=false)

Widget _wrap(Widget child) => ThemeScope(
      isDark: false,
      toggle: () {},
      child: MaterialApp(theme: AppTheme.light, home: child),
    );

/// 페이지가 실제로 읽는 뱅크에서 문항을 가져온다(ID가 byId에 반드시 있도록).
Future<List<Question>> _realQuestions(int n) async {
  for (final e in contentFor(_cert)) {
    if (!e.hasQuestions) continue;
    final raw = await rootBundle.loadString(e.questionsAsset);
    final bank =
        QuestionBank.fromJson(json.decode(raw) as Map<String, dynamic>);
    if (bank.questions.length >= n) return bank.questions.take(n).toList();
  }
  throw StateError('$_cert 뱅크에서 문항 $n개를 찾지 못했다');
}

/// 모든 문항을 길이까지 맞춰 덮는 표시 순서(항등 순열) — ordersCoverQuestions 통과용.
Map<String, List<int>> _fullOrders(List<Question> qs) => {
      for (final q in qs)
        q.id: [for (var i = 0; i < q.options.length; i++) i],
    };

ExamSession _session({
  required List<String> questionIds,
  required Map<String, List<int>> optionOrders,
  bool submitted = false,
}) =>
    ExamSession(
      examId: _examId,
      certId: _cert,
      taskId: '$_cert-mock',
      startedAtIso: DateTime(2026, 10, 24, 9).toIso8601String(),
      durationSec: 5400,
      index: 0,
      picked: const {},
      flagged: const [],
      // cert_exam_page의 복원 판정은 지문을 보지 않는다(exam_page와 다른 정책).
      // 일부러 맞지 않는 값을 넣어 현재 동작을 고정한다.
      bankFingerprint: 'fingerprint-무관',
      questionIds: questionIds,
      optionOrders: optionOrders,
      submitted: submitted,
    );

Future<void> _pump(WidgetTester tester, MemoryBackend backend) async {
  tester.view.physicalSize = const Size(1400, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    _wrap(CertExamPage(cert: certByCode(_cert)!, backend: backend)),
  );
  await tester.pump();
  // pumpAndSettle의 첫 인자는 타임아웃이 아니라 "펌프 간격"이고 기본 타임아웃은 10분이다.
  // 가라앉지 않는 트리를 10분 매달리는 대신 빨리 드러내려고 타임아웃을 명시한다.
  await tester.pumpAndSettle(
    const Duration(milliseconds: 100),
    EnginePhase.sendSemanticsUpdate,
    const Duration(seconds: 10),
  );
}

void main() {
  // ⚠️ rootBundle은 로드 결과를 캐시한다. 앞 테스트의 zone에서 만들어진 future가
  // 캐시에 남으면 다음 테스트에서는 완료되지 않아 **그 테스트가 영영 멈춘다**
  // (이 페이지도 매번 같은 questions.json·exam_guides를 읽는다). 테스트마다 비운다.
  setUp(rootBundle.clear);

  testWidgets('미제출 + ID 존재 + 순서 완비 세션 → "이어서 풀기" 노출', (tester) async {
    final qs = await _realQuestions(3);
    final b = MemoryBackend();
    ExamSessionStore(backend: b).save(_session(
      questionIds: [for (final q in qs) q.id],
      optionOrders: _fullOrders(qs),
    ));

    await _pump(tester, b);

    expect(find.text('이어서 풀기'), findsOneWidget);
    expect(ExamSessionStore(backend: b).load(_examId), isNotNull,
        reason: '복원 가능한 세션은 보존돼야 한다');
  });

  testWidgets('제출된 세션 → 복원하지 않고 새 시험 시작 화면', (tester) async {
    final qs = await _realQuestions(3);
    final b = MemoryBackend();
    ExamSessionStore(backend: b).save(_session(
      questionIds: [for (final q in qs) q.id],
      optionOrders: _fullOrders(qs),
      submitted: true,
    ));

    await _pump(tester, b);

    expect(find.text('이어서 풀기'), findsNothing);
    expect(find.text('시작'), findsOneWidget);
  });

  testWidgets('문항이 개정돼 ID가 사라진 세션 → 복원 불가 + 세션 폐기', (tester) async {
    final qs = await _realQuestions(2);
    final b = MemoryBackend();
    final ids = [for (final q in qs) q.id, 'clf-없는문항-zzz'];
    ExamSessionStore(backend: b).save(_session(
      questionIds: ids,
      optionOrders: _fullOrders(qs),
    ));

    await _pump(tester, b);

    expect(find.text('이어서 풀기'), findsNothing);
    expect(find.text('시작'), findsOneWidget);
    expect(ExamSessionStore(backend: b).load(_examId), isNull,
        reason: '복원 불가 세션은 폐기돼야 한다(_store.clear)');
  });

  testWidgets('optionOrders 없는 구버전 세션 → 복원 불가 + 세션 폐기', (tester) async {
    final qs = await _realQuestions(3);
    final b = MemoryBackend();
    ExamSessionStore(backend: b).save(_session(
      questionIds: [for (final q in qs) q.id],
      optionOrders: const {}, // 구버전: 선택지 순서 미기록
    ));

    await _pump(tester, b);

    expect(find.text('이어서 풀기'), findsNothing);
    expect(ExamSessionStore(backend: b).load(_examId), isNull,
        reason: '구버전 세션은 폐기돼야 한다(스펙 §3.3)');
  });
}
