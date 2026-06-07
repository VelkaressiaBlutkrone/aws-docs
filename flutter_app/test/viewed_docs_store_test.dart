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
}
