// flutter_app/test/cloud/sync_merge_viewed_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/cloud/sync_merge.dart';

void main() {
  test('mergeViewed: cert별 taskId 합집합 + 변경 cert만 toCloud', () {
    final local = {
      'CLF-C02': {'t1', 't2'},
      'SAA-C03': {'s1'},
    };
    final cloud = {
      'CLF-C02': {'taskIds': ['t2', 't3']},   // 합 → t1,t2,t3
      'SOA-C03': {'taskIds': ['o1']},          // 로컬에 없음 → 추가
    };
    final r = mergeViewed(local, cloud);
    expect(r.merged['CLF-C02'], {'t1', 't2', 't3'});
    expect(r.merged['SAA-C03'], {'s1'});       // 클라우드에 없던 로컬 유지
    expect(r.merged['SOA-C03'], {'o1'});       // 클라우드 전용 흡수
    // 클라우드와 달라진 cert만 push: CLF(t1 추가)·SAA(신규)
    expect(r.toCloud.keys.toSet(), {'CLF-C02', 'SAA-C03'});
    expect((r.toCloud['CLF-C02']!['taskIds'] as List).toSet(), {'t1', 't2', 't3'});
  });
}
