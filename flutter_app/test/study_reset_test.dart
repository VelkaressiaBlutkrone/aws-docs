import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/history_store.dart';
import 'package:aws_docs/data/viewed_docs_store.dart';
import 'package:aws_docs/data/exam_session_store.dart';
import 'package:aws_docs/data/study_reset.dart';
import 'package:aws_docs/models/attempt_record.dart';
import 'package:aws_docs/models/exam_session.dart';
import 'package:aws_docs/models/study_plan.dart';
import 'package:aws_docs/data/study_plan_store.dart';
import 'package:aws_docs/data/plan_check_store.dart';

AttemptRecord _rec(String certId, String examId) => AttemptRecord(
      certId: certId,
      examId: examId,
      mode: 'exam',
      date: '2026-01-01T00:00:00.000Z',
      correct: 1,
      total: 1,
      wrongQuestionIds: const [],
      flaggedQuestionIds: const [],
      durationSpentSec: 10,
    );

ExamSession _sess(String examId) => ExamSession(
      examId: examId,
      certId: 'CLF-C02',
      taskId: 'clf-t1-1',
      startedAtIso: '2026-01-01T00:00:00.000Z',
      durationSec: 600,
      index: 0,
      picked: const {},
      flagged: const [],
      bankFingerprint: '1:q1',
      questionIds: const ['q1'],
      optionOrders: const {},
      submitted: false,
    );

void main() {
  group('KvBackend.keys', () {
    test('MemoryBackend: 기록한 키를 열거한다', () {
      final b = MemoryBackend()
        ..write('a', '1')
        ..write('b', '2');
      expect(b.keys().toSet(), {'a', 'b'});
    });
  });

  group('HistoryStore.clear*', () {
    test('clearCert: 해당 자격증 레코드만 제거하고 나머지는 보존', () {
      final b = MemoryBackend();
      HistoryStore(backend: b)
        ..add(_rec('CLF-C02', 'exam:clf-t1-1'))
        ..add(_rec('SAA-C03', 'exam:saa-t1-1'))
        ..add(_rec('CLF-C02', 'exam:CLF-C02-mock'));
      HistoryStore(backend: b).clearCert('CLF-C02');
      final left = HistoryStore(backend: b).all();
      expect(left.map((r) => r.certId), ['SAA-C03']);
    });

    test('clearAll: 전부 제거', () {
      final b = MemoryBackend();
      HistoryStore(backend: b)
        ..add(_rec('CLF-C02', 'exam:clf-t1-1'))
        ..add(_rec('SAA-C03', 'exam:saa-t1-1'));
      HistoryStore(backend: b).clearAll();
      expect(HistoryStore(backend: b).all(), isEmpty);
    });
  });

  group('ViewedDocsStore.clear*', () {
    test('clearCert: 해당 자격증 열람만 제거', () {
      final b = MemoryBackend();
      ViewedDocsStore(backend: b)
        ..markViewed('CLF-C02', 'clf-t1-1')
        ..markViewed('SAA-C03', 'saa-t1-1');
      ViewedDocsStore(backend: b).clearCert('CLF-C02');
      expect(ViewedDocsStore(backend: b).viewed('CLF-C02'), isEmpty);
      expect(ViewedDocsStore(backend: b).viewed('SAA-C03'), {'saa-t1-1'});
    });

    test('clearAll: 전부 제거', () {
      final b = MemoryBackend();
      ViewedDocsStore(backend: b)
        ..markViewed('CLF-C02', 'clf-t1-1')
        ..markViewed('SAA-C03', 'saa-t1-1');
      ViewedDocsStore(backend: b).clearAll();
      expect(ViewedDocsStore(backend: b).viewed('CLF-C02'), isEmpty);
      expect(ViewedDocsStore(backend: b).viewed('SAA-C03'), isEmpty);
    });
  });

  group('ExamSessionStore.clearAll', () {
    test('clearAll: 모든 세션 키 제거', () {
      final b = MemoryBackend();
      ExamSessionStore(backend: b)
        ..save(_sess('exam:clf-t1-1'))
        ..save(_sess('exam:CLF-C02-mock'));
      ExamSessionStore(backend: b).clearAll();
      expect(ExamSessionStore(backend: b).load('exam:clf-t1-1'), isNull);
      expect(ExamSessionStore(backend: b).load('exam:CLF-C02-mock'), isNull);
    });
  });

  group('resetCert / resetAll', () {
    test('resetCert: history+viewed+세션을 해당 자격증만 정리', () {
      final b = MemoryBackend();
      HistoryStore(backend: b)
        ..add(_rec('CLF-C02', 'exam:CLF-C02-mock'))
        ..add(_rec('SAA-C03', 'exam:saa-t1-1'));
      ViewedDocsStore(backend: b)
        ..markViewed('CLF-C02', 'clf-t1-1')
        ..markViewed('SAA-C03', 'saa-t1-1');
      ExamSessionStore(backend: b)
        ..save(_sess('exam:CLF-C02-mock'))
        ..save(_sess('exam:clf-t1-1'))
        ..save(_sess('exam:saa-t1-1'));

      resetCert('CLF-C02', backend: b);

      // CLF는 비고, SAA는 보존.
      expect(HistoryStore(backend: b).all().map((r) => r.certId), ['SAA-C03']);
      expect(ViewedDocsStore(backend: b).viewed('CLF-C02'), isEmpty);
      expect(ViewedDocsStore(backend: b).viewed('SAA-C03'), {'saa-t1-1'});
      expect(ExamSessionStore(backend: b).load('exam:CLF-C02-mock'), isNull);
      expect(ExamSessionStore(backend: b).load('exam:clf-t1-1'), isNull);
      expect(ExamSessionStore(backend: b).load('exam:saa-t1-1'), isNotNull);
    });

    test('resetAll: 모든 store를 비운다', () {
      final b = MemoryBackend();
      HistoryStore(backend: b).add(_rec('CLF-C02', 'exam:CLF-C02-mock'));
      ViewedDocsStore(backend: b).markViewed('CLF-C02', 'clf-t1-1');
      ExamSessionStore(backend: b).save(_sess('exam:CLF-C02-mock'));

      resetAll(backend: b);

      expect(HistoryStore(backend: b).all(), isEmpty);
      expect(ViewedDocsStore(backend: b).viewed('CLF-C02'), isEmpty);
      expect(ExamSessionStore(backend: b).load('exam:CLF-C02-mock'), isNull);
    });

    test('resetCert는 플랜·체크도 정리', () {
      final b = MemoryBackend();
      StudyPlanStore(backend: b).save(StudyPlan(
          certCode: 'CLF-C02', startIso: '2026-06-10', endIso: '2026-06-20',
          mode: PlanMode.period, createdIso: '2026-06-10', items: const []));
      PlanCheckStore(backend: b).set('CLF-C02', 'x', true);

      resetCert('CLF-C02', backend: b);

      expect(StudyPlanStore(backend: b).planFor('CLF-C02'), isNull);
      expect(PlanCheckStore(backend: b).overrides('CLF-C02'), isEmpty);
    });
  });
}
