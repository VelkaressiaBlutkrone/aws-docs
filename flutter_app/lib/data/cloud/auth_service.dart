import 'dart:async';
import 'auth_user.dart';

/// 인증 추상화. 실제 구현(Firebase)은 Plan 2. 비로그인이면 current==null.
abstract interface class AuthService {
  AuthUser? get current;
  Stream<AuthUser?> authChanges();
  Future<void> signInWithGoogle();
  Future<void> signOut();
}

/// 테스트용. signInWithGoogle()은 고정 사용자, emit()으로 임의 상태 주입.
class FakeAuthService implements AuthService {
  AuthUser? _current;
  final _ctrl = StreamController<AuthUser?>.broadcast();

  @override
  AuthUser? get current => _current;
  @override
  Stream<AuthUser?> authChanges() => _ctrl.stream;
  @override
  Future<void> signInWithGoogle() async =>
      emit(const AuthUser(uid: 'u-test', email: 'test@example.com'));
  @override
  Future<void> signOut() async => emit(null);

  /// 테스트 도우미: 임의 인증 상태 방출.
  void emit(AuthUser? u) {
    _current = u;
    _ctrl.add(u);
  }
}
