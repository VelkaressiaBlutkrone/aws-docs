// flutter_app/test/cloud/sync_merge_attempts_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/models/attempt_record.dart';
import 'package:aws_docs/data/cloud/sync_merge.dart';

AttemptRecord _r(String examId, String date, {String cert = 'CLF-C02'}) =>
    AttemptRecord(
      certId: cert, examId: examId, mode: 'exam', date: date,
      correct: 1, total: 1, wrongQuestionIds: const [],
      flaggedQuestionIds: const [], durationSpentSec: 1,
    );

void main() {
  test('attemptKey: certId|examId|date 안정·금지문자 치환', () {
    final k = attemptKey(_r('exam:CLF-C02-mock', '2026-06-10T09:00:00.000'));
    expect(k, isNotEmpty);
    expect(k.contains('/'), isFalse);
    expect(k.contains('.'), isFalse);
    expect(attemptKey(_r('exam:CLF-C02-mock', '2026-06-10T09:00:00.000')), k); // 안정
  });

  test('mergeAttempts: 양쪽 union·무손실 + 로컬 신규만 toCloud', () {
    final l1 = _r('exam:CLF-C02-mock', '2026-06-10T09:00:00.000'); // 로컬 전용
    final shared = _r('practice:clf-t1-1', '2026-06-09T10:00:00.000'); // 양쪽
    final c1 = _r('exam:CLF-C02-weak', '2026-06-11T08:00:00.000'); // 클라우드 전용
    final local = [l1, shared];
    final cloud = {
      attemptKey(shared): shared.toJson(),
      attemptKey(c1): c1.toJson(),
    };
    final r = mergeAttempts(local, cloud);
    // 병합 = 3건(유실 없음)
    expect(r.merged.map(attemptKey).toSet(),
        {attemptKey(l1), attemptKey(shared), attemptKey(c1)});
    // 클라우드에 없던 로컬(l1)만 push
    expect(r.toCloud.keys.toSet(), {attemptKey(l1)});
  });
}
