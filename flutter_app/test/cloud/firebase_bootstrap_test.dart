// flutter_app/test/cloud/firebase_bootstrap_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/cloud/firebase_bootstrap.dart';

void main() {
  test('cloudConfigured: 실제 설정이면 true (web 옵션 직접 판독, VM에서도 throw 없음)', () {
    expect(cloudConfigured(), isTrue);
  });
}
