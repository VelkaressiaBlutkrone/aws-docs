// flutter_app/test/cloud/sync_merge_lww_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/cloud/sync_merge.dart';

void main() {
  test('mergeLww: cert별 updatedAt 큰 쪽 채택·로컬 신/단독은 push', () {
    final local = {
      'CLF-C02': {'v': 'local-clf'},   // 로컬이 최신
      'SAA-C03': {'v': 'local-saa'},   // 로컬 단독
    };
    final localMeta = {'CLF-C02': 200, 'SAA-C03': 50};
    final cloud = {
      'CLF-C02': {'v': 'cloud-clf', 'updatedAt': 100}, // 로컬(200) 최신 → 로컬 유지
      'SOA-C03': {'v': 'cloud-soa', 'updatedAt': 300}, // 클라우드 단독 → 채택
    };
    final r = mergeLww(local, localMeta, cloud);
    expect(r.merged['CLF-C02'], {'v': 'local-clf'});       // 로컬 최신
    expect(r.mergedMeta['CLF-C02'], 200);
    expect(r.merged['SAA-C03'], {'v': 'local-saa'});        // 로컬 단독
    expect(r.merged['SOA-C03'], {'v': 'cloud-soa'});        // 클라우드 단독(updatedAt 제거)
    expect(r.merged['SOA-C03']!.containsKey('updatedAt'), isFalse);
    expect(r.mergedMeta['SOA-C03'], 300);
    // push 대상: 로컬이 더 최신/단독 = CLF(200>100)·SAA(단독)
    expect(r.toCloud.keys.toSet(), {'CLF-C02', 'SAA-C03'});
    expect(r.toCloud['CLF-C02']!['updatedAt'], 200);
  });

  test('mergeLww: 클라우드가 최신이면 클라우드 채택(로컬 메타 갱신)', () {
    final r = mergeLww(
      {'CLF-C02': {'v': 'old'}}, {'CLF-C02': 100},
      {'CLF-C02': {'v': 'new', 'updatedAt': 500}});
    expect(r.merged['CLF-C02'], {'v': 'new'});
    expect(r.mergedMeta['CLF-C02'], 500);
    expect(r.toCloud, isEmpty); // 클라우드가 최신 → push 안 함
  });
}
