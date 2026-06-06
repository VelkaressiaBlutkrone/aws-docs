import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/cert_lookup.dart';

void main() {
  test('certByCode: 알려진 코드 해석, 미지정 null', () {
    expect(certByCode('CLF-C02')?.code, 'CLF-C02');
    expect(certByCode('NOPE'), isNull);
  });

  test('entryByTask: 알려진 Task 해석, 미지정/잘못된 cert null', () {
    expect(entryByTask('CLF-C02', 'clf-t1-1')?.taskId, 'clf-t1-1');
    expect(entryByTask('CLF-C02', 'clf-nope'), isNull);
    expect(entryByTask('NOPE', 'clf-t1-1'), isNull);
  });
}
