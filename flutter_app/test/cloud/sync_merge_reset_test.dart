import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/cloud/sync_merge.dart';
import 'package:aws_docs/models/attempt_record.dart';

AttemptRecord _rec(String date, int createdAtMs) => AttemptRecord(
      certId: 'CLF-C02',
      examId: 'exam:clf-t1-1',
      mode: 'exam',
      date: date,
      correct: 1,
      total: 1,
      wrongQuestionIds: const [],
      flaggedQuestionIds: const [],
      durationSpentSec: 10,
      createdAtMs: createdAtMs,
    );

void main() {
  test('mergeAttempts: 표식보다 오래된 레코드는 버리고 삭제 목록에 넣는다', () {
    final old = _rec('2026-09-01T00:00:00.000', 1000);
    final fresh = _rec('2026-09-23T00:00:00.000', 5000);
    final cloud = {
      attemptKey(old): old.toJson(),
      attemptKey(fresh): fresh.toJson(),
    };

    final r = mergeAttempts([old, fresh], cloud, resetAt: {'CLF-C02': 3000});

    expect(r.merged.map((e) => e.createdAtMs), [5000]);
    expect(r.toDelete, [attemptKey(old)]);
    expect(r.toCloud, isEmpty); // 남은 레코드는 이미 클라우드에 있음
  });

  test('mergeAttempts: 전체 표식(*)도 적용된다', () {
    final r = mergeAttempts([_rec('2026-09-01T00:00:00.000', 1000)], const {},
        resetAt: {'*': 3000});
    expect(r.merged, isEmpty);
    expect(r.toCloud, isEmpty);
  });

  test('mergeAttempts: 표식이 없으면 기존 합집합 그대로', () {
    final a = _rec('2026-09-01T00:00:00.000', 1000);
    final r = mergeAttempts([a], const {});
    expect(r.merged.length, 1);
    expect(r.toCloud.keys, [attemptKey(a)]);
    expect(r.toDelete, isEmpty);
  });

  test('mergeAttempts: createdAtMs 없는 레거시는 date로 비교한다', () {
    const legacy = AttemptRecord(
      certId: 'CLF-C02', examId: 'exam:clf-t1-1', mode: 'exam',
      date: '2026-09-01T00:00:00.000', correct: 1, total: 1,
      wrongQuestionIds: [], flaggedQuestionIds: [], durationSpentSec: 10,
    );
    final cut = DateTime.parse('2026-09-10T00:00:00.000').millisecondsSinceEpoch;
    final r = mergeAttempts([legacy], const {}, resetAt: {'CLF-C02': cut});
    expect(r.merged, isEmpty);
  });

  test('mergeViewed: 표식 이후 열람만 남기고 빈 자격증은 삭제 목록에', () {
    final local = {
      'CLF-C02': {'t-old': 1000, 't-new': 9000},
    };
    final cloud = {
      'CLF-C02': {
        'items': {'t-old': 1000}
      },
      'SAA-C03': {
        'items': {'s-old': 500}
      },
    };

    final r = mergeViewed(local, cloud, resetAt: {'*': 3000});

    expect(r.merged['CLF-C02'], {'t-new': 9000});
    expect(r.merged['SAA-C03'], isEmpty);
    expect(r.toDelete, contains('SAA-C03'));
    expect(r.toCloud['CLF-C02']!['items'], {'t-new': 9000});
  });
}
