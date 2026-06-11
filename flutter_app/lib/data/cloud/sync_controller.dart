// flutter_app/lib/data/cloud/sync_controller.dart
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../local_kv.dart';
import 'auth_service.dart';
import 'auth_user.dart';
import 'cloud_store.dart';
import 'sync_service.dart';

enum SyncStatus { off, idle, syncing, error }

/// 인증·트리거를 받아 SyncService.reconcileAll을 멱등 재실행(reconcile-on-trigger).
/// 가로채기 없음 — SyncService가 스토어와 같은 localStorage를 읽고/쓴다.
class SyncController extends ChangeNotifier {
  SyncController({
    required AuthService auth,
    required CloudStore cloud,
    required KvBackend local,
    int Function()? nowMs,
    Duration? syncInterval,
    Stream<void>? onAppResume,
  })  : _auth = auth,
        _cloud = cloud,
        _syncInterval = syncInterval,
        _onAppResume = onAppResume,
        _svc = SyncService(local: local, cloud: cloud, nowMs: nowMs);

  final AuthService _auth;
  final CloudStore _cloud;
  final SyncService _svc;

  /// signed-in 동안 멱등 reconcile을 재실행할 주기. null이면 주기 트리거 off.
  final Duration? _syncInterval;

  /// 앱 복귀(예: web visibilitychange) 신호. 수신 시 sync() — 비로그인이면 무시(가드).
  final Stream<void>? _onAppResume;

  StreamSubscription<AuthUser?>? _authSub;
  StreamSubscription<void>? _resumeSub;
  Timer? _periodic;
  final List<StreamSubscription<dynamic>> _watchSubs = [];
  AuthUser? _user;
  SyncStatus _status = SyncStatus.off;
  bool _busy = false;
  bool _pending = false;
  // Guard: signIn/signOut already handle _onUser directly; skip the stream echo.
  bool _explicitTransition = false;

  AuthUser? get user => _user;
  SyncStatus get status => _status;

  void start() {
    _authSub ??= _auth.authChanges().listen((u) {
      if (!_explicitTransition) _onUser(u);
    });
    // 앱 복귀 신호 → reconcile. sync()가 비로그인을 가드하므로 추가 게이트 불필요.
    _resumeSub ??= _onAppResume?.listen((_) => sync());
  }

  Future<void> signIn() async {
    _explicitTransition = true;
    try {
      await _auth.signInWithGoogle();
      await _onUser(_auth.current);
    } finally {
      _explicitTransition = false;
    }
  }

  Future<void> signOut() async {
    _explicitTransition = true;
    try {
      await _auth.signOut();
      await _onUser(null);
    } finally {
      _explicitTransition = false;
    }
  }

  Future<void> _onUser(AuthUser? u) async {
    _user = u;
    await _cancelWatches();
    _periodic?.cancel();
    _periodic = null;
    if (u == null) {
      _set(SyncStatus.off);
      return;
    }
    await sync(); // 초기 화해
    _startWatches(u.uid); // 클라우드 변경 수신
    _startPeriodic(); // 로컬→클라우드 주기 푸시(멱등 reconcile)
  }

  void _startPeriodic() {
    final interval = _syncInterval;
    if (interval == null) return;
    _periodic = Timer.periodic(interval, (_) => sync());
  }

  /// 멱등 reconcile. 재진입 가드: 진행 중이면 pending 표시 후 1회 재실행.
  Future<void> sync() async {
    final u = _user;
    if (u == null) return;
    if (_busy) {
      _pending = true;
      return;
    }
    _busy = true;
    _set(SyncStatus.syncing);
    try {
      await _svc.reconcileAll(u.uid);
      _set(SyncStatus.idle);
    } catch (_) {
      _set(SyncStatus.error);
    } finally {
      _busy = false;
      if (_pending) {
        _pending = false;
        await sync();
      }
    }
  }

  void _startWatches(String uid) {
    for (final coll in const ['attempts', 'viewed', 'plans', 'checks']) {
      _watchSubs.add(
          _cloud.watchCollection(uid, coll).listen((_) => sync()));
    }
  }

  Future<void> _cancelWatches() async {
    final subs = List<StreamSubscription<dynamic>>.from(_watchSubs);
    _watchSubs.clear();
    for (final s in subs) {
      await s.cancel();
    }
  }

  void _set(SyncStatus s) {
    _status = s;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _resumeSub?.cancel();
    _periodic?.cancel();
    _cancelWatches();
    super.dispose();
  }
}
