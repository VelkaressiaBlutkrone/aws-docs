// flutter_app/lib/data/cloud/firebase_auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';
import 'auth_user.dart';

/// AuthService의 Firebase 구현(웹 Google 팝업). 라이브 검증은 사용자 설정 후.
class FirebaseAuthService implements AuthService {
  FirebaseAuthService([FirebaseAuth? auth])
      : _auth = auth ?? FirebaseAuth.instance;
  final FirebaseAuth _auth;

  AuthUser? _map(User? u) =>
      u == null ? null : AuthUser(uid: u.uid, email: u.email ?? '');

  @override
  AuthUser? get current => _map(_auth.currentUser);

  @override
  Stream<AuthUser?> authChanges() => _auth.authStateChanges().map(_map);

  @override
  Future<void> signInWithGoogle() async {
    await _auth.signInWithPopup(GoogleAuthProvider());
  }

  @override
  Future<void> signOut() => _auth.signOut();
}
