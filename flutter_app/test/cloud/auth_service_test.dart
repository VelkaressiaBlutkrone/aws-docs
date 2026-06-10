// flutter_app/test/cloud/auth_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/cloud/auth_user.dart';
import 'package:aws_docs/data/cloud/auth_service.dart';

void main() {
  test('FakeAuthService: 로그인/로그아웃 상태·스트림', () async {
    final a = FakeAuthService();
    expect(a.current, isNull);
    final seen = <AuthUser?>[];
    final sub = a.authChanges().listen(seen.add);
    await a.signInWithGoogle();
    expect(a.current, isNotNull);
    expect(a.current!.uid, isNotEmpty);
    await a.signOut();
    expect(a.current, isNull);
    await Future<void>.delayed(Duration.zero);
    expect(seen.length, 2); // 로그인·로그아웃
    expect(seen.first?.uid, isNotEmpty);
    expect(seen.last, isNull);
    await sub.cancel();
  });
}
