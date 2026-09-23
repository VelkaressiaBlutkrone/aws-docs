import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/viewed_docs_store.dart';

void main() {
  test('markViewed 멱등 · 자격증 분리', () {
    final store = ViewedDocsStore(backend: MemoryBackend());
    expect(store.viewed('CLF-C02'), isEmpty);

    store.markViewed('CLF-C02', 'clf-t1-1');
    store.markViewed('CLF-C02', 'clf-t1-1'); // 중복 → 무변경
    store.markViewed('CLF-C02', 'clf-t2-1');
    store.markViewed('SAA-C03', 'saa-t1-1');

    expect(store.viewed('CLF-C02'), {'clf-t1-1', 'clf-t2-1'});
    expect(store.viewed('SAA-C03'), {'saa-t1-1'});
  });

  test('영속 백엔드 공유 시 재로드해도 유지', () {
    final backend = MemoryBackend();
    ViewedDocsStore(backend: backend).markViewed('CLF-C02', 'clf-t1-1');
    expect(ViewedDocsStore(backend: backend).viewed('CLF-C02'), {'clf-t1-1'});
  });

  test('손상 데이터는 빈 결과로 무시', () {
    final corrupt = MemoryBackend()..write('awsdocs.viewed.v1', '{not json');
    expect(ViewedDocsStore(backend: corrupt).viewed('CLF-C02'), isEmpty);
  });

  group('항목별 열람 시각', () {
    test('markViewed: 항목마다 UTC 시각을 남긴다', () {
      final b = MemoryBackend();
      ViewedDocsStore(backend: b, nowMs: () => 777)
          .markViewed('CLF-C02', 'clf-t1-1');
      expect(ViewedDocsStore(backend: b).readAll(), {
        'CLF-C02': {'clf-t1-1': 777}
      });
      expect(ViewedDocsStore(backend: b).viewed('CLF-C02'), {'clf-t1-1'});
    });

    test('레거시 배열 형태는 시각 0으로 읽는다', () {
      final b = MemoryBackend()
        ..write(
            'awsdocs.viewed.v1',
            jsonEncode({
              'CLF-C02': ['clf-t1-1', 'clf-t1-2']
            }));
      expect(ViewedDocsStore(backend: b).readAll(), {
        'CLF-C02': {'clf-t1-1': 0, 'clf-t1-2': 0}
      });
      expect(ViewedDocsStore(backend: b).viewed('CLF-C02'),
          {'clf-t1-1', 'clf-t1-2'});
    });

    test('이미 본 문서는 시각을 갱신하지 않는다', () {
      final b = MemoryBackend();
      ViewedDocsStore(backend: b, nowMs: () => 100)
          .markViewed('CLF-C02', 'clf-t1-1');
      ViewedDocsStore(backend: b, nowMs: () => 200)
          .markViewed('CLF-C02', 'clf-t1-1');
      expect(
          ViewedDocsStore(backend: b).readAll()['CLF-C02'], {'clf-t1-1': 100});
    });

    test('clearCert는 해당 자격증만 지운다', () {
      final b = MemoryBackend();
      ViewedDocsStore(backend: b, nowMs: () => 1)
        ..markViewed('CLF-C02', 'a')
        ..markViewed('SAA-C03', 'b');
      ViewedDocsStore(backend: b).clearCert('CLF-C02');
      expect(ViewedDocsStore(backend: b).viewed('CLF-C02'), isEmpty);
      expect(ViewedDocsStore(backend: b).viewed('SAA-C03'), {'b'});
    });
  });
}
