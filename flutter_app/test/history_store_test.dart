import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/models/attempt_record.dart';
import 'package:aws_docs/data/history_store.dart';

void main() {
  test('AttemptRecord JSON 왕복', () {
    const r = AttemptRecord(
      certId: 'CLF-C02',
      examId: 'practice:clf-t2-1',
      mode: 'practice',
      date: '2026-06-06T00:00:00.000',
      correct: 4,
      total: 5,
      wrongQuestionIds: ['clf-t2-1-q3'],
      flaggedQuestionIds: [],
      durationSpentSec: 120,
    );
    final back = AttemptRecord.fromJson(r.toJson());
    expect(back.correct, 4);
    expect(back.wrongQuestionIds, ['clf-t2-1-q3']);
    expect(back.mode, 'practice');
  });

  test('presentedQuestionIds JSON 왕복 + 레거시 누락은 빈 리스트', () {
    const r = AttemptRecord(
      certId: 'CLF-C02',
      examId: 'practice:clf-t2-1',
      mode: 'practice',
      date: '2026-06-06T00:00:00.000',
      correct: 4,
      total: 5,
      wrongQuestionIds: ['clf-t2-1-q3'],
      flaggedQuestionIds: [],
      presentedQuestionIds: ['clf-t2-1-q1', 'clf-t2-1-q3'],
      durationSpentSec: 120,
    );
    final back = AttemptRecord.fromJson(r.toJson());
    expect(back.presentedQuestionIds, ['clf-t2-1-q1', 'clf-t2-1-q3']);

    // 레거시: presentedQuestionIds 키가 없는 JSON → 빈 리스트
    final legacy = AttemptRecord.fromJson({
      'certId': 'CLF-C02',
      'examId': 'practice:clf-t2-1',
      'mode': 'practice',
      'date': '2026-06-06T00:00:00.000',
      'correct': 4,
      'total': 5,
      'wrongQuestionIds': ['clf-t2-1-q3'],
      'flaggedQuestionIds': <String>[],
      'durationSpentSec': 120,
    });
    expect(legacy.presentedQuestionIds, isEmpty);
  });

  test('HistoryStore는 누적 저장하고 손상 데이터는 무시한다', () {
    final store = HistoryStore(backend: MemoryBackend());
    expect(store.all(), isEmpty);
    store.add(const AttemptRecord(
      certId: 'CLF-C02', examId: 'practice:clf-t2-1', mode: 'practice',
      date: '2026-06-06T00:00:00.000', correct: 5, total: 5,
      wrongQuestionIds: [], flaggedQuestionIds: [], durationSpentSec: 90,
    ));
    store.add(const AttemptRecord(
      certId: 'CLF-C02', examId: 'practice:clf-t2-1', mode: 'practice',
      date: '2026-06-06T00:01:00.000', correct: 3, total: 5,
      wrongQuestionIds: ['x'], flaggedQuestionIds: [], durationSpentSec: 80,
    ));
    expect(store.all().length, 2);

    final corrupt = MemoryBackend()..write('awsdocs.history.v1', '{not json');
    expect(HistoryStore(backend: corrupt).all(), isEmpty);
  });
}
