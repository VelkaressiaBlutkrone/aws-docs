import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/models/attempt_record.dart';
import 'package:aws_docs/data/study_progress.dart';

const _all = ['clf-t1-1', 'clf-t1-2', 'clf-t2-1'];

AttemptRecord _rec({
  required String date,
  required int correct,
  required int total,
  String mode = 'practice',
  String certId = 'CLF-C02',
}) =>
    AttemptRecord(
      certId: certId,
      examId: 'practice:clf-t1-1',
      mode: mode,
      date: date,
      correct: correct,
      total: total,
      wrongQuestionIds: const [],
      flaggedQuestionIds: const [],
      durationSpentSec: 60,
    );

void main() {
  test('이력·열람 없으면 빈 상태', () {
    final p = StudyProgress.build(
      certId: 'CLF-C02', allTaskIds: _all,
      viewedTaskIds: const {}, history: const [],
    );
    expect(p.viewedCount, 0);
    expect(p.totalDocs, 3);
    expect(p.bestRatePct, isNull);
    expect(p.lastAttemptIso, isNull);
    expect(p.hasAny, isFalse);
  });

  test('열람은 현재 인덱스 교집합만(stale 제외, 분자 ≤ 분모)', () {
    final p = StudyProgress.build(
      certId: 'CLF-C02', allTaskIds: _all,
      viewedTaskIds: const {'clf-t1-1', 'clf-t9-9'}, // t9-9 = 삭제됨
      history: const [],
    );
    expect(p.viewedCount, 1);
    expect(p.totalDocs, 3);
    expect(p.hasAny, isTrue); // 열람 있으면 true
  });

  test('최고 정답률·마지막 응시일(review·타 cert·total0 제외)', () {
    final p = StudyProgress.build(
      certId: 'CLF-C02', allTaskIds: _all, viewedTaskIds: const {},
      history: [
        _rec(date: '2026-06-01', correct: 3, total: 5), // 60%
        _rec(date: '2026-06-03', correct: 9, total: 10), // 90% ← 최고
        _rec(date: '2026-06-05', correct: 5, total: 5, mode: 'review'), // 무시
        _rec(date: '2026-06-09', correct: 1, total: 1, certId: 'SAA-C03'), // 무시
        _rec(date: '2026-06-04', correct: 0, total: 0), // total0 무시
      ],
    );
    expect(p.bestRatePct, 90);
    expect(p.lastAttemptIso, '2026-06-03'); // review/타cert/total0 제외 후 최신
    expect(p.hasAny, isTrue);
  });
}
