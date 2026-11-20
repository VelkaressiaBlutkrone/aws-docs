import 'dart:async';
import 'auth_user.dart';

/// 인증 추상화. 실제 구현(Firebase)은 Plan 2. 비로그인이면 current==null.
abstract interface class AuthService {
  AuthUser? get current;
  Stream<AuthUser?> authChanges();
  Future<void> signInWithGoogle();
  Future<void> signOut();

  /// 보안 민감 작업(계정 삭제) 직전의 재인증. 공식이 `User.delete()` 에
  /// `requires-recent-login` 을 명시하고 해결책으로 재인증을 적는다.
  /// 사용자가 취소하면 **false**이고 예외를 던지지 않는다(취소는 오류가 아니다).
  Future<bool> reauthenticate();

  /// Auth 계정 삭제.
  ///
  /// ⚠️⚠️ **클라우드 문서를 먼저 지운 뒤 부른다.** `firestore.rules` 가
  /// `request.auth.uid == uid` 를 요구하므로 계정을 먼저 지우면 그 사용자의 문서를
  /// **영원히 지울 수 없다**(고아 데이터). 순서는 `SyncController.deleteAccount` 가
  /// 조율하고 `test/account_deletion_test.dart` 가 고정한다.
  Future<void> deleteAccount();
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
  @override
  Future<bool> reauthenticate() async => _current != null;
  @override
  Future<void> deleteAccount() async => emit(null);

  /// 테스트 도우미: 임의 인증 상태 방출.
  void emit(AuthUser? u) {
    _current = u;
    _ctrl.add(u);
  }
}
