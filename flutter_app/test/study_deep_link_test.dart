import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/content/study_deep_link.dart';

void main() {
  group('studyDeepLink', () {
    test('appends ?at= when section present', () {
      expect(studyDeepLink('CLF-C02', 'clf-t1-1', 'core'),
          '/cert/CLF-C02/study/clf-t1-1?at=core');
    });
    test('no query when section empty', () {
      expect(studyDeepLink('CLF-C02', 'clf-t1-1', ''),
          '/cert/CLF-C02/study/clf-t1-1');
    });
  });
}
