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
  /// 기본 주기 트리거 간격. 변경이 없어도 틱마다 컬렉션 로드가 발생하는
  /// 비용↔백업 지연 트레이드오프의 단일 조정점.
  static const Duration defaultSyncInterval = Duration(seconds: 30);

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
  // 전환 세대. auth 스트림이 _onUser를 await 없이 부르므로 전환이 인터리브될 수
  // 있다 — await sync() 뒤 세대가 다르면(더 새 전환 또는 dispose가 추월) 스테일
  // 측이 watch/timer를 부착해 고아를 만들기에, 최신 세대만 부착을 진행한다.
  int _gen = 0;
  bool _disposed = false;

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
    final gen = ++_gen;
    _user = u;
    _teardownTriggers();
    if (u == null) {
      _pending = false; // 로그아웃: 큐된 재동기 요청은 무의미
      _set(SyncStatus.off);
      return;
    }
    await sync(); // 초기 화해
    if (gen != _gen) return; // 추월당한 스테일 전환은 watch/timer 부착 금지
    _startWatches(u.uid); // 클라우드 변경 수신
    _startPeriodic(); // 로컬→클라우드 주기 푸시(멱등 reconcile)
  }

  /// 주기 타이머·watch 구독 해제. 의도적으로 **동기** — cancel()이 리턴되는
  /// 순간 이벤트 전달은 멈춘다(Dart stream 보장). 정리-완료 future를 기다리면
  /// 해제가 await 너머로 밀려, 로그아웃 직후에도 타이머가 살아있는 창이 생긴다.
  void _teardownTriggers() {
    _periodic?.cancel();
    _periodic = null;
    final subs = List<StreamSubscription<dynamic>>.from(_watchSubs);
    _watchSubs.clear();
    for (final s in subs) {
      s.cancel();
    }
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

  void _set(SyncStatus s) {
    if (_disposed) return; // 비행 중 reconcile이 dispose 뒤 완료될 수 있음
    _status = s;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _gen++; // 비행 중 _onUser가 깨어나도 부착 못 하게
    _authSub?.cancel();
    _resumeSub?.cancel();
    _teardownTriggers();
    super.dispose();
  }
}
