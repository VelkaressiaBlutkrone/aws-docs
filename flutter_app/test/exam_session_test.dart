import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/models/exam_session.dart';
import 'package:aws_docs/models/question.dart';
import 'package:aws_docs/data/exam_session_store.dart';
import 'package:aws_docs/data/local_kv.dart';

QuestionBank _bank(List<String> ids) => QuestionBank(
  examGuideTaskId: 'clf-t2-3',
  taskTitle: '접근 관리',
  certCode: 'CLF-C02',
  domain: 2,
  questions: [
    for (final id in ids)
      Question(
        id: id,
        examGuideTaskId: 'clf-t2-3',
        stem: 's',
        options: const ['a', 'b'],
        correct: 0,
        explanation: 'e',
        wrongExplanations: const {},
        sources: const [],
        verified: true,
      ),
  ],
);

void main() {
  test('questionIds 라운드트립 + 누락 시 빈 목록(하위호환)', () {
    const s = ExamSession(
      examId: 'exam:CLF-C02-mock',
      certId: 'CLF-C02',
      taskId: 'CLF-C02-mock',
      startedAtIso: '2026-06-06T00:00:00.000',
      durationSec: 5400,
      index: 0,
      picked: {},
      flagged: [],
      bankFingerprint: 'fp',
      submitted: false,
      questionIds: ['clf-t1-1-q1', 'clf-t2-1-q3'],
    );
    final back = ExamSession.fromJson(s.toJson());
    expect(back.questionIds, ['clf-t1-1-q1', 'clf-t2-1-q3']);
    // 구버전 JSON(questionIds 없음) → 빈 목록
    final old = ExamSession.fromJson({'examId': 'x'});
    expect(old.questionIds, isEmpty);
  });

  test('ExamSession JSON 왕복(picked 문자열키 복원)', () {
    const s = ExamSession(
      examId: 'exam:clf-t2-3',
      certId: 'CLF-C02',
      taskId: 'clf-t2-3',
      startedAtIso: '2026-06-06T00:00:00.000',
      durationSec: 581,
      index: 2,
      picked: {0: 1, 2: 3},
      flagged: [2, 4],
      bankFingerprint: '7:a,b',
      submitted: false,
    );
    final back = ExamSession.fromJson(s.toJson());
    expect(back.index, 2);
    expect(back.picked, {0: 1, 2: 3});
    expect(back.flagged, [2, 4]);
    expect(back.durationSec, 581);
    expect(back.submitted, isFalse);
  });

  test('fromJson은 손상된 flagged 항목을 건너뛴다(방어적)', () {
    final back = ExamSession.fromJson({
      'examId': 'exam:x',
      'flagged': [1, 'x', 2],
    });
    expect(back.flagged, [1, 2]);
  });

  test('bankFingerprint는 문항 변경 시 달라진다', () {
    expect(
      bankFingerprint(_bank(['a', 'b', 'c'])),
      bankFingerprint(_bank(['a', 'b', 'c'])),
    );
    expect(
      bankFingerprint(_bank(['a', 'b', 'c'])),
      isNot(bankFingerprint(_bank(['a', 'b']))),
    ); // 문항 수 변경
    expect(
      bankFingerprint(_bank(['a', 'b', 'c'])),
      isNot(bankFingerprint(_bank(['a', 'b', 'x']))),
    ); // ID 변경
  });

  test('examDurationSec: CLF 90분/65문항 페이스 비례', () {
    // 90*60/65 ≈ 83.08s/문항 → 7문항 = 581.54 → round 582
    expect(
      examDurationSec(durationMinutes: 90, scored: 50, unscored: 15, count: 7),
      582,
    );
    // 메타 null → 폴백 84s/문항
    expect(
      examDurationSec(
        durationMinutes: null,
        scored: null,
        unscored: null,
        count: 5,
      ),
      420,
    );
  });

  ExamSession session({bool submitted = false}) => ExamSession(
    examId: 'exam:clf-t2-3',
    certId: 'CLF-C02',
    taskId: 'clf-t2-3',
    startedAtIso: '2026-06-06T00:00:00.000',
    durationSec: 581,
    index: 1,
    picked: const {0: 1},
    flagged: const [1],
    bankFingerprint: '7:a',
    submitted: submitted,
  );

  test('ExamSessionStore save→load 동일, clear 후 null', () {
    final store = ExamSessionStore(backend: MemoryBackend());
    expect(store.load('exam:clf-t2-3'), isNull);
    store.save(session());
    final loaded = store.load('exam:clf-t2-3');
    expect(loaded, isNotNull);
    expect(loaded!.index, 1);
    expect(loaded.picked, {0: 1});
    store.clear('exam:clf-t2-3');
    expect(store.load('exam:clf-t2-3'), isNull);
  });

  test('ExamSessionStore.clearCertExamSessions: 통합/약점 세션만 함께 정리', () {
    ExamSession s(String examId) => ExamSession(
      examId: examId,
      certId: 'SAA-C03',
      taskId: examId,
      startedAtIso: '2026-06-06T00:00:00.000',
      durationSec: 581,
      index: 1,
      picked: const {0: 1},
      flagged: const [1],
      bankFingerprint: '7:a',
      submitted: false,
    );

    final store = ExamSessionStore(backend: MemoryBackend());
    store
      ..save(s('exam:SAA-C03-mock'))
      ..save(s('exam:SAA-C03-weak'))
      ..save(s('exam:saa-t2-1'));

    store.clearCertExamSessions('SAA-C03');

    expect(store.load('exam:SAA-C03-mock'), isNull);
    expect(store.load('exam:SAA-C03-weak'), isNull);
    expect(store.load('exam:saa-t2-1'), isNotNull);
  });

  test('손상 데이터는 null로 무시', () {
    final b = MemoryBackend()
      ..write('awsdocs.examSession.v1:exam:clf-t2-3', '{not json');
    expect(ExamSessionStore(backend: b).load('exam:clf-t2-3'), isNull);
  });

  test('optionOrders 직렬화 왕복 + 구버전(필드 없음) 빈 맵', () {
    const s = ExamSession(
      examId: 'exam:clf-t2-3',
      certId: 'CLF-C02',
      taskId: 'clf-t2-3',
      startedAtIso: '2026-06-08T00:00:00.000',
      durationSec: 420,
      index: 0,
      picked: {},
      flagged: [],
      bankFingerprint: 'fp',
      submitted: false,
      questionIds: ['q1', 'q2'],
      optionOrders: {
        'q1': [2, 0, 3, 1],
        'q2': [1, 0],
      },
    );
    final back = ExamSession.fromJson(s.toJson());
    expect(back.optionOrders, {
      'q1': [2, 0, 3, 1],
      'q2': [1, 0],
    });
    // 구버전 JSON(optionOrders 없음) → 빈 맵
    final old = ExamSession.fromJson({'examId': 'x'});
    expect(old.optionOrders, isEmpty);
  });

  test('fromJson은 손상된 optionOrders 항목을 건너뛴다(방어적)', () {
    final back = ExamSession.fromJson({
      'examId': 'exam:x',
      'optionOrders': {
        'q1': [1, 0],
        'q2': 'broken', // 리스트 아님 → 스킵
      },
    });
    expect(back.optionOrders, {
      'q1': [1, 0],
    });
  });
}
