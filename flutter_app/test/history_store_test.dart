import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/models/attempt_record.dart';
import 'package:aws_docs/data/history_store.dart';

/// 손상 보존본 키 쓰기만 실패시키는 백엔드(localStorage 쿼터 근접 모사).
class _QuotaOnBackup extends MemoryBackend {
  @override
  void write(String key, String value) {
    if (key == 'awsdocs.history.v1.corrupt') {
      throw StateError('QuotaExceededError');
    }
    super.write(key, value);
  }
}

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

  group('손상 이력 — 레코드 단위 관용 + 덮어쓰기 전 원문 보존', () {
    Map<String, dynamic> rec(String date) => {
          'certId': 'CLF-C02', 'examId': 'exam:clf-t1-1', 'mode': 'exam',
          'date': date, 'correct': 1, 'total': 1, 'wrongQuestionIds': [],
          'flaggedQuestionIds': [], 'durationSpentSec': 10,
        };
    const newer = AttemptRecord(
      certId: 'CLF-C02', examId: 'exam:clf-t1-2', mode: 'exam',
      date: '2026-09-22T00:00:00.000', correct: 1, total: 1,
      wrongQuestionIds: [], flaggedQuestionIds: [], durationSpentSec: 10,
    );

    test('all: 깨진 레코드만 건너뛰고 나머지는 읽는다', () {
      final b = MemoryBackend()
        ..write('awsdocs.history.v1',
            jsonEncode([rec('2026-09-01T00:00:00.000'), 42, rec('2026-09-02T00:00:00.000')]));
      expect(HistoryStore(backend: b).all().map((r) => r.date),
          ['2026-09-01T00:00:00.000', '2026-09-02T00:00:00.000']);
    });

    test('add: 깨진 레코드가 섞여 있어도 정상 레코드를 지키고 원문을 보존한다', () {
      final raw =
          jsonEncode([rec('2026-09-01T00:00:00.000'), 42]);
      final b = MemoryBackend()..write('awsdocs.history.v1', raw);

      HistoryStore(backend: b).add(newer);

      expect(HistoryStore(backend: b).all().map((r) => r.date),
          ['2026-09-01T00:00:00.000', '2026-09-22T00:00:00.000']);
      expect(b.read('awsdocs.history.v1.corrupt'), raw);
    });

    test('add: 해석 불가 원문은 덮어쓰기 전에 보존한다', () {
      const raw = '[{"certId":"CLF-C02","examId":"exam:clf-t1-1"'; // 잘린 JSON
      final b = MemoryBackend()..write('awsdocs.history.v1', raw);

      HistoryStore(backend: b).add(newer);

      expect(HistoryStore(backend: b).all().single.date,
          '2026-09-22T00:00:00.000');
      expect(b.read('awsdocs.history.v1.corrupt'), raw);
    });

    test('add: 보존본 쓰기가 실패해도(쿼터 근접) 새 응시는 저장한다', () {
      final b = _QuotaOnBackup()
        ..write('awsdocs.history.v1',
            jsonEncode([rec('2026-09-01T00:00:00.000'), 42]));

      HistoryStore(backend: b).add(newer);

      expect(HistoryStore(backend: b).all().map((r) => r.date),
          ['2026-09-01T00:00:00.000', '2026-09-22T00:00:00.000']);
    });

    test('clearCert: 깨진 레코드가 섞여 있으면 다시 쓰기 전에 원문을 보존한다', () {
      final raw = jsonEncode([rec('2026-09-01T00:00:00.000'), 42]);
      final b = MemoryBackend()..write('awsdocs.history.v1', raw);

      HistoryStore(backend: b).clearCert('SAA-C03');

      expect(b.read('awsdocs.history.v1.corrupt'), raw);
      expect(HistoryStore(backend: b).all().single.date,
          '2026-09-01T00:00:00.000');
    });

    test('fromJson이 던지는 레코드도 건너뛰고, 다시 쓰기 전에 원문을 보존한다', () {
      final raw = jsonEncode([
        rec('2026-09-01T00:00:00.000'),
        {...rec('2026-09-02T00:00:00.000'), 'correct': 'x'}, // 캐스트 실패
      ]);
      final b = MemoryBackend()..write('awsdocs.history.v1', raw);
      expect(HistoryStore(backend: b).all().single.date,
          '2026-09-01T00:00:00.000');

      HistoryStore(backend: b).add(newer);

      expect(b.read('awsdocs.history.v1.corrupt'), raw);
    });

    test('add: 최상위가 배열이 아니면 원문을 보존한다', () {
      final b = MemoryBackend()..write('awsdocs.history.v1', '{}');
      HistoryStore(backend: b).add(newer);
      expect(b.read('awsdocs.history.v1.corrupt'), '{}');
      expect(HistoryStore(backend: b).all().single.date,
          '2026-09-22T00:00:00.000');
    });

    test('add: 정상 원문이면 보존본을 만들지 않는다', () {
      final b = MemoryBackend()
        ..write('awsdocs.history.v1', jsonEncode([rec('2026-09-01T00:00:00.000')]));
      HistoryStore(backend: b).add(newer);
      expect(b.read('awsdocs.history.v1.corrupt'), isNull);
    });

    test('clearAll: 손상 보존본도 함께 지운다(전체 초기화)', () {
      final b = MemoryBackend()
        ..write('awsdocs.history.v1', '{not json')
        ..write('awsdocs.history.v1.corrupt', '{not json');
      HistoryStore(backend: b).clearAll();
      expect(b.read('awsdocs.history.v1.corrupt'), isEmpty);
    });
  });
}
