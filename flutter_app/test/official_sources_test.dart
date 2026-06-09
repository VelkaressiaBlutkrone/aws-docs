import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/site_data.dart';

void main() {
  test('officialSources: 모두 클릭 가능한 https 출처(빈 값 없음)', () {
    expect(officialSources, isNotEmpty);
    for (final s in officialSources) {
      expect(s.title.trim(), isNotEmpty);
      expect(s.href, startsWith('https://'),
          reason: '${s.title} 의 href 가 https:// 여야 클릭 시 새 탭으로 열 수 있다');
    }
  });

  test('officialSources: 단일 자격증 칩 금지(홈은 12개 공통 출처만)', () {
    final titles = officialSources.map((s) => s.title).toList();
    expect(titles.any((t) => t.contains('CloudOps')), isFalse,
        reason: '홈 히어로의 출처는 특정 자격증이 아니라 12개 공통 공식 자료여야 한다');
    expect(titles, contains('공식 시험 가이드 (한국어)'));
  });
}
