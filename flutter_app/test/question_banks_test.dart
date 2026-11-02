import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:aws_docs/data/content_index.dart';
import 'package:aws_docs/data/question_banks.dart';

/// 리뷰 M-4 / `CODE-P-012` — 문항 뱅크 다중 로드가 **네 곳에 복제**돼 있었고
/// 그중 `cert_exam_page`에만 `hasQuestions` 가드가 있었다(나머지 셋은 문항 0인
/// 학습문서 Task마다 404를 긁었다). 직렬 `await` 루프라 첫 진입이 N×RTT였다.
///
/// 정본: `docs/audits/2026-09-22-app-code-ux-review.md` M-4.

ContentEntry _entry(String taskId, {required int questionCount}) => ContentEntry(
      certCode: 'TEST-C01',
      taskId: taskId,
      title: '제목 $taskId',
      domain: 1,
      mdAsset: 'assets/content/test/$taskId.md',
      questionsAsset: 'assets/content/test/$taskId.questions.json',
      questionCount: questionCount,
    );

String _bankJson(String taskId) => json.encode({
      'examGuideTaskId': taskId,
      'taskTitle': '제목 $taskId',
      'certCode': 'TEST-C01',
      'domain': 1,
      'questions': const [],
    });

void main() {
  group('loadQuestionBanks', () {
    test('content_index 순서를 보존하고 문항 0 Task는 건너뛴다', () async {
      final entries = [
        _entry('t1-1', questionCount: 15),
        _entry('t1-2', questionCount: 0), // 학습문서만 있는 Task
        _entry('t1-3', questionCount: 20),
      ];
      final requested = <String>[];

      final loaded = await loadQuestionBanks(entries, loadString: (key) async {
        requested.add(key);
        final taskId = key.split('/').last.split('.').first;
        return _bankJson(taskId);
      });

      expect([for (final l in loaded) l.entry.taskId], ['t1-1', 't1-3'],
          reason: '결과는 입력 순서를 보존해야 한다(뱅크 순서가 시험 구성에 쓰인다)');
      expect([for (final l in loaded) l.bank.examGuideTaskId], ['t1-1', 't1-3']);

      expect(requested, [
        'assets/content/test/t1-1.questions.json',
        'assets/content/test/t1-3.questions.json',
      ], reason: '⚠️ 문항 0 Task를 요청하면 배포본에서 404가 난다 — 요청 자체를 하지 않아야 한다');
    });

    test('요청을 병렬로 발행한다 — 하나가 끝나기를 기다리지 않는다', () async {
      final entries = [
        for (var i = 1; i <= 4; i++) _entry('t2-$i', questionCount: 10),
      ];
      final gate = Completer<void>();
      var inFlight = 0;
      var maxInFlight = 0;

      final future = loadQuestionBanks(entries, loadString: (key) async {
        inFlight++;
        maxInFlight = inFlight > maxInFlight ? inFlight : maxInFlight;
        await gate.future; // 모든 요청이 발행될 때까지 아무것도 완료되지 않는다
        inFlight--;
        return _bankJson(key.split('/').last.split('.').first);
      });

      await Future<void>.delayed(Duration.zero);
      expect(maxInFlight, entries.length,
          reason: '직렬 `for … await`이면 동시 비행이 1이다 — 첫 진입이 N×RTT가 된다');

      gate.complete();
      final loaded = await future;
      expect(loaded.length, 4);
      expect([for (final l in loaded) l.entry.taskId],
          ['t2-1', 't2-2', 't2-3', 't2-4'],
          reason: '병렬이어도 순서는 입력 순서여야 한다');
    });

    test('개별 뱅크 실패는 나머지를 막지 않는다', () async {
      final entries = [
        _entry('t3-1', questionCount: 15),
        _entry('t3-2', questionCount: 15),
        _entry('t3-3', questionCount: 15),
      ];

      final loaded = await loadQuestionBanks(entries, loadString: (key) async {
        if (key.contains('t3-2')) throw StateError('에셋 없음');
        return _bankJson(key.split('/').last.split('.').first);
      });

      expect([for (final l in loaded) l.entry.taskId], ['t3-1', 't3-3'],
          reason: '하나가 실패하면 그 뱅크만 빠지고 나머지로 진행해야 한다');
    });

    test('빈 입력은 빈 결과다', () async {
      final loaded = await loadQuestionBanks(const [], loadString: (_) async {
        fail('요청이 발생하면 안 된다');
      });
      expect(loaded, isEmpty);
    });
  });

  group('M-4 드리프트 가드 — 다중 뱅크 로드는 공용 로더만 쓴다', () {
    // 단일 엔트리(`widget.entry`)를 읽는 두 페이지는 대상이 아니다.
    const singleEntryPages = {
      'lib/pages/exam_page.dart',
      'lib/pages/quiz_page.dart',
    };

    test('`questionsAsset` 직접 로드가 공용 로더 밖에 없다', () {
      final offenders = <String>[];
      for (final f in Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))) {
        final rel = f.path.replaceAll(r'\', '/');
        if (rel.endsWith('lib/data/content_index.dart')) continue; // 정의부
        if (rel.endsWith('lib/data/question_banks.dart')) continue; // 공용 로더
        if (singleEntryPages.any(rel.endsWith)) continue;
        if (f.readAsStringSync().contains('questionsAsset')) offenders.add(rel);
      }
      expect(offenders, isEmpty,
          reason: '⚠️ 다중 뱅크 로드를 손으로 다시 쓰면 `hasQuestions` 가드가 또 빠진다'
              '(실제로 네 곳 중 셋에서 빠져 404를 긁었다) — `loadQuestionBanks`를 쓴다. '
              '위반: $offenders');
    });
  });
}
