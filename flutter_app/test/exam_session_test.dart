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
    expect(bankFingerprint(_bank(['a', 'b', 'c'])),
        bankFingerprint(_bank(['a', 'b', 'c'])));
    expect(bankFingerprint(_bank(['a', 'b', 'c'])),
        isNot(bankFingerprint(_bank(['a', 'b'])))); // 문항 수 변경
    expect(bankFingerprint(_bank(['a', 'b', 'c'])),
        isNot(bankFingerprint(_bank(['a', 'b', 'x'])))); // ID 변경
  });

  test('examDurationSec: CLF 90분/65문항 페이스 비례', () {
    // 90*60/65 ≈ 83.08s/문항 → 7문항 = 581.54 → round 582
    expect(examDurationSec(durationMinutes: 90, scored: 50, unscored: 15, count: 7),
        582);
    // 메타 null → 폴백 84s/문항
    expect(examDurationSec(durationMinutes: null, scored: null, unscored: null, count: 5),
        420);
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

  test('손상 데이터는 null로 무시', () {
    final b = MemoryBackend()
      ..write('awsdocs.examSession.v1:exam:clf-t2-3', '{not json');
    expect(ExamSessionStore(backend: b).load('exam:clf-t2-3'), isNull);
  });
}
