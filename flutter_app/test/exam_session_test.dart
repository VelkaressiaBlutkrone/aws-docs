import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/models/exam_session.dart';
import 'package:aws_docs/models/question.dart';

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
}
