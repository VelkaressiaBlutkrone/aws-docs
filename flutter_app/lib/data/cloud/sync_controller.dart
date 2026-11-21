// flutter_app/lib/data/cloud/sync_controller.dart
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../app_errors.dart';
import '../local_kv.dart';
import '../study_reset.dart';
import 'auth_service.dart';
import 'auth_user.dart';
import 'cloud_store.dart';
import 'sync_meta.dart';
import 'sync_service.dart';
import 'synced_collections.dart';

enum SyncStatus { off, idle, syncing, error }

/// 인증·트리거를 받아 SyncService.reconcileAll을 멱등 재실행(reconcile-on-trigger).
/// 가로채기 없음 — SyncService가 스토어와 같은 localStorage를 읽고/쓴다.
class SyncController extends ChangeNotifier {
  /// 기본 주기 트리거 간격. 변경이 없어도 틱마다 컬렉션 로드가 발생하는
  /// 비용↔백업 지연 트레이드오프의 단일 조정점.
  static const Duration defaultSyncInterval = Duration(seconds: 30);

  /// watch 스트림이 끊겼을 때 다시 붙기까지 기다리는 시간. ⚠️ 즉시 재구독하면
  /// 영구 실패(규칙 거부 등)에서 재구독 폭주가 된다.
  static const Duration defaultWatchRetryDelay = Duration(seconds: 5);

  /// 유휴(변경 없는 회차)가 이어질 때 주기 간격을 늘릴 **상한**. 이 값이 곧
  /// "watch가 죽어 있는 동안 다른 기기 변경을 받는 최대 지연"이고, 로컬 변경이
  /// 클라우드로 올라가는 **최대 지연**도 같다(그 회차에 변경이 보이면 즉시
  /// 기본 간격으로 돌아온다 — 리뷰 M-8).
  static const Duration defaultIdleIntervalCap = Duration(minutes: 5);

  SyncController({
    required AuthService auth,
    required CloudStore cloud,
    required KvBackend local,
    int Function()? nowMs,
    Duration? syncInterval,
    Duration watchRetryDelay = defaultWatchRetryDelay,
    Duration idleIntervalCap = defaultIdleIntervalCap,
    Stream<void>? onAppResume,
  })  : _auth = auth,
        _cloud = cloud,
        _syncInterval = syncInterval,
        _watchRetryDelay = watchRetryDelay,
        _idleIntervalCap = idleIntervalCap,
        _onAppResume = onAppResume,
        _local = local,
        _svc = SyncService(local: local, cloud: cloud, nowMs: nowMs);

  final AuthService _auth;
  final CloudStore _cloud;

  /// 로컬 저장소 — 계정 삭제(A7)가 이 기기의 기록과 동기 사이드카를 지울 때 쓴다.
  final KvBackend _local;
  final SyncService _svc;

  /// signed-in 동안 멱등 reconcile을 재실행할 주기. null이면 주기 트리거 off.
  final Duration? _syncInterval;

  /// watch 재구독 지연(테스트 주입용).
  final Duration _watchRetryDelay;

  /// 유휴 백오프 상한(테스트 주입용).
  final Duration _idleIntervalCap;

  /// 다음 주기 틱까지의 간격. 변경 없는 회차마다 2배로 늘고 상한에서 멈추며,
  /// 변경이 있던 회차 뒤에는 기본 간격으로 돌아온다.
  Duration? _nextInterval;

  /// 앱 복귀(예: web visibilitychange) 신호. 수신 시 sync() — 비로그인이면 무시(가드).
  final Stream<void>? _onAppResume;

  StreamSubscription<AuthUser?>? _authSub;
  StreamSubscription<void>? _resumeSub;
  Timer? _periodic;
  final List<StreamSubscription<dynamic>> _watchSubs = [];

  /// 끊긴 watch를 다시 붙이려고 대기 중인 타이머. ⚠️ 로그아웃·dispose에서
  /// 반드시 취소한다 — 안 하면 비로그인 상태에서 watch가 되살아난다.
  final List<Timer> _watchRetries = [];
  AuthUser? _user;
  SyncStatus _status = SyncStatus.off;
  String? _signInError;
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

  /// 마지막 로그인 시도의 실패 문구. 성공·사용자 취소는 null이다(취소는 실패가 아니다).
  String? get signInError => _signInError;

  Future<void> signIn() async {
    _explicitTransition = true;
    if (_signInError != null) {
      _signInError = null;
      notifyListeners();
    }
    try {
      await _auth.signInWithGoogle();
      await _onUser(_auth.current);
    } catch (e, st) {
      // ⚠️ 호출부가 Future를 버린다(`onPressed: ctrl.signIn`) — 던지면 unhandled async
      // error가 되고 화면은 아무 변화가 없어 버튼이 고장난 것처럼 보인다. Android에서는
      // 자격 증명 없음·설정 오류가 흔한 경로다(A4). 삼키지도 않는다 — 로그 + 화면 문구.
      appLog('Google 로그인 실패: $e\n$st');
      _signInError = '로그인 실패 — 다시 시도해 주세요';
      notifyListeners();
    } finally {
      _explicitTransition = false;
    }
  }

  /// 계정과 데이터를 지운다 — **재인증 → 클라우드 문서 → Auth 계정 → 로컬 기록** (A7).
  /// 사용자가 재인증을 취소하면 **아무것도 지우지 않고** false를 돌려준다.
  ///
  /// ⚠️⚠️ **순서가 안전 설계다.** `firestore.rules`가 `request.auth.uid == uid`를
  /// 요구하므로 Auth 계정을 먼저 지우면 그 사용자의 문서를 **영원히 지울 수 없다**
  /// (고아 데이터). 이 순서면 중간에 실패해도 계정이 남아 그대로 재시도된다 —
  /// 그래서 실패를 **전파하고** 뒷단계를 진행하지 않는다.
  ///
  /// ⚠️⚠️ 끝에 **동기 사이드카를 비운다.** `resetAll()`은 설계상 삭제 표식을
  /// 남기는데(다른 기기의 부활 방지), 계정이 사라진 뒤 그 표식이 남으면 **다음에 다른
  /// 계정으로 로그인할 때 그 계정의 클라우드 기록을 「표식보다 오래된 것」으로 보고
  /// 지운다.** 계정 삭제는 이 기기를 동기 미경험 상태로 되돌려야 한다.
  Future<bool> deleteAccount() async {
    final uid = _auth.current?.uid;
    if (uid == null) return false;

    if (!await _auth.reauthenticate()) return false;

    _explicitTransition = true;
    try {
      // 1) ⚠️⚠️ **동기를 먼저 멈춘다.** 문서를 지우면 `watchCollection`이 변경을
      //    내보내고 그 구독이 `sync()`를 돌려 **삭제 도중에 reconcile이 끼어든다** —
      //    로컬 데이터를 클라우드에 다시 써서 방금 지운 문서를 되살릴 수 있고, Auth
      //    계정이 사라진 뒤라면 규칙 거부로 status가 error가 된다. `_onUser(null)`이
      //    `_teardownTriggers()`로 타이머·구독을 **동기적으로** 끊는다.
      //    (여기서 로그아웃 상태가 되므로 이후 단계가 실패하면 사용자는 로그아웃된
      //    것처럼 보이지만 계정은 살아 있다 — 다시 로그인하면 그대로 복구된다.)
      await _onUser(null);

      // 2) 클라우드 문서 — 클라이언트 SDK가 서브컬렉션을 나열할 수 없어
      //    `kUserOwnedCollections`를 돈다(동기 컬렉션 + 피드백처럼 동기하지 않는
      //    사용자 소유 컬렉션. 그 목록의 드리프트는 가드가 막는다).
      for (final collection in kUserOwnedCollections) {
        final docs = await _cloud.loadCollection(uid, collection);
        for (final docId in docs.keys) {
          await _cloud.deleteDoc(uid, collection, docId);
        }
      }

      // 3) Auth 계정 — 이 뒤로는 그 uid의 문서를 지울 수 없다.
      await _auth.deleteAccount();
    } finally {
      _explicitTransition = false;
    }

    // 4) 이 기기의 기록 + 사이드카(위 주석).
    resetAll(backend: _local);
    _local.write(SyncMeta.key, '');
    notifyListeners();
    return true;
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
    for (final t in List<Timer>.from(_watchRetries)) {
      t.cancel();
    }
    _watchRetries.clear();
    final subs = List<StreamSubscription<dynamic>>.from(_watchSubs);
    _watchSubs.clear();
    for (final s in subs) {
      s.cancel();
    }
  }

  /// 주기 reconcile. ⚠️ **없애지 않는다** — watch가 죽은 사이 다른 기기 변경을 받는
  /// 마지막 안전망이다(P1의 재구독이 대부분을 자체 복구하지만 그 재구독마저 실패할 수
  /// 있다). 대신 **변경 없는 회차가 이어지면 간격을 배로 늘려** 상한까지 간다 —
  /// 무변경 틱이 컬렉션 로드를 반복하던 것이 Firestore 읽기 비용의 유일한
  /// 조정점이었다(리뷰 M-8).
  void _startPeriodic() {
    final interval = _syncInterval;
    if (interval == null) return;
    _nextInterval = interval;
    _scheduleNextTick();
  }

  void _scheduleNextTick() {
    final interval = _nextInterval;
    if (interval == null || _disposed || _user == null) return;
    final gen = _gen;
    _periodic?.cancel();
    _periodic = Timer(interval, () {
      if (_disposed || gen != _gen) return;
      sync(); // 결과에 따라 _nextInterval을 조정하고 다음 틱을 건다
    });
  }

  /// 한 회차의 결과로 다음 간격을 정한다. 변경이 있었으면 기본값으로, 없었으면
  /// 2배(상한까지)로.
  void _applyIdleBackoff({required bool mutated}) {
    final base = _syncInterval;
    if (base == null) return;
    if (mutated) {
      _nextInterval = base;
    } else {
      final grown = (_nextInterval ?? base) * 2;
      _nextInterval = grown > _idleIntervalCap ? _idleIntervalCap : grown;
    }
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
      final mutated = await _svc.reconcileAll(u.uid);
      _applyIdleBackoff(mutated: mutated);
      _set(SyncStatus.idle);
    } catch (_) {
      // 실패한 회차는 "변경 없음"으로 보지 않는다 — 다음 틱을 늦추면 복구가 느려진다.
      _applyIdleBackoff(mutated: true);
      _set(SyncStatus.error);
    } finally {
      _busy = false;
      if (_pending) {
        _pending = false;
        await sync();
      } else {
        // 틱을 한 번 쓰고 다음 것을 건다(주기 트리거가 켜져 있을 때만).
        _scheduleNextTick();
      }
    }
  }

  void _startWatches(String uid) {
    // meta = 삭제 표식. 다른 기기의 초기화를 즉시 받아 로컬을 정리한다.
    for (final coll in const [
      'meta',
      'attempts',
      'viewed',
      'plans',
      'progress'
    ]) {
      _watchOne(uid, coll);
    }
  }

  /// 컬렉션 하나를 구독한다. ⚠️ **오류를 삼키면 그 컬렉션의 변경 수신이 영구
  /// 중단된다**(규칙 거부·네트워크 단절). 그래서 오류를 상태로 드러내고
  /// [_watchRetryDelay] 뒤에 다시 붙인 다음 한 번 reconcile해 그동안의 변경을
  /// 따라잡는다. 세대(`_gen`)가 바뀌었으면(로그아웃·재로그인·dispose) 붙지 않는다.
  void _watchOne(String uid, String coll) {
    if (_disposed || _user?.uid != uid) return;
    final gen = _gen;
    late final StreamSubscription<dynamic> sub;
    sub = _cloud.watchCollection(uid, coll).listen(
      (_) => sync(),
      onError: (Object _) {
        _watchSubs.remove(sub);
        sub.cancel();
        if (_disposed || gen != _gen) return;
        _set(SyncStatus.error); // 변경 수신이 끊긴 것도 사용자에게 보이는 실패다
        late final Timer t;
        t = Timer(_watchRetryDelay, () {
          _watchRetries.remove(t);
          if (_disposed || gen != _gen) return;
          _watchOne(uid, coll);
          sync(); // 끊긴 사이의 변경을 따라잡는다
        });
        _watchRetries.add(t);
      },
    );
    _watchSubs.add(sub);
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
