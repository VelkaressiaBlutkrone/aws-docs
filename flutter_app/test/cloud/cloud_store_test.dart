// flutter_app/test/cloud/cloud_store_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/cloud/cloud_store.dart';

void main() {
  test('FakeCloudStore: setDoc·loadCollection 왕복 + uid/컬렉션 격리', () async {
    final cs = FakeCloudStore();
    await cs.setDoc('u1', 'plans', 'CLF-C02', {'x': 1});
    await cs.setDoc('u1', 'plans', 'SAA-C03', {'x': 2});
    await cs.setDoc('u2', 'plans', 'CLF-C02', {'x': 9});
    final u1 = await cs.loadCollection('u1', 'plans');
    expect(u1.keys.toSet(), {'CLF-C02', 'SAA-C03'});
    expect(u1['CLF-C02'], {'x': 1});
    expect((await cs.loadCollection('u2', 'plans'))['CLF-C02'], {'x': 9});
    expect(await cs.loadCollection('u1', 'attempts'), isEmpty);
  });

  test('FakeCloudStore: watchCollection이 setDoc마다 스냅샷 방출', () async {
    final cs = FakeCloudStore();
    final snaps = <Map<String, Map<String, dynamic>>>[];
    final sub = cs.watchCollection('u1', 'viewed').listen(snaps.add);
    await cs.setDoc('u1', 'viewed', 'CLF-C02', {'taskIds': ['t1']});
    await Future<void>.delayed(Duration.zero);
    expect(snaps.last['CLF-C02'], {'taskIds': ['t1']});
    await sub.cancel();
  });
}
