// flutter_app/test/cloud/sync_controller_test.dart
import 'dart:async';
import 'dart:convert';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/local_kv.dart';
import 'package:aws_docs/data/cloud/auth_service.dart';
import 'package:aws_docs/data/cloud/auth_user.dart';
import 'package:aws_docs/data/cloud/cloud_store.dart';
import 'package:aws_docs/data/cloud/sync_controller.dart';

/// loadCollection 호출 수 카운트 + 선택적 throw/지연으로 reconcile 횟수·에러·인터리브 검증.
class _SpyCloud implements CloudStore {
  _SpyCloud(this._inner);
  final CloudStore _inner;
  int loads = 0;
  bool throwOnLoad = false;

  /// fakeAsync에서 reconcile을 파킹시켜 _onUser 인터리브를 결정론적으로 재현.
  Duration loadDelay = Duration.zero;

  @override
  Future<void> setDoc(
          String uid, String collection, String docId, Map<String, dynamic> data) =>
      _inner.setDoc(uid, collection, docId, data);

  @override
  Future<Map<String, Map<String, dynamic>>> loadCollection(
      String uid, String collection) async {
    loads++;
    if (throwOnLoad) throw Exception('boom');
    if (loadDelay > Duration.zero) await Future<void>.delayed(loadDelay);
    return _inner.loadCollection(uid, collection);
  }

  @override
  Stream<Map<String, Map<String, dynamic>>> watchCollection(
          String uid, String collection) =>
      _inner.watchCollection(uid, collection);
}

/// sync() 호출을 센다 — signOut 후엔 sync가 null-가드로 no-op이라
/// loads로는 고아 타이머가 안 보이기 때문(타이머 발화 자체를 관측).
class _ProbeController extends SyncController {
  _ProbeController({
    required super.auth,
    required super.cloud,
    required super.local,
    super.nowMs,
    super.syncInterval,
  });
  int syncCalls = 0;

  @override
  Future<void> sync() {
    syncCalls++;
    return super.sync();
  }
}

void main() {
  test('signIn: reconcile로 클라우드 plan이 로컬에 내려옴 + status idle', () async {
    final auth = FakeAuthService();
    final cloud = FakeCloudStore();
    final local = MemoryBackend();
    await cloud.setDoc('u-test', 'plans', 'CLF-C02', {
      'certCode': 'CLF-C02', 'startIso': '2026-06-10', 'endIso': '2026-06-24',
      'mode': 'period', 'createdIso': '2026-06-10', 'items': [], 'updatedAt': 9000,
    });
    final ctrl = SyncController(
        auth: auth, cloud: cloud, local: local, nowMs: () => 1000);
    ctrl.start();
    await ctrl.signIn();
    // 클라우드 plan이 로컬 블롭에 반영
    final plans = jsonDecode(local.read('awsdocs.plan.v1')!) as Map;
    expect(plans.containsKey('CLF-C02'), isTrue);
    expect(ctrl.user?.email, 'test@example.com');
    expect(ctrl.status, SyncStatus.idle);
  });

  test('signOut: status off·user null', () async {
    final ctrl = SyncController(
        auth: FakeAuthService(), cloud: FakeCloudStore(),
        local: MemoryBackend(), nowMs: () => 1000);
    ctrl.start();
    await ctrl.signIn();
    await ctrl.signOut();
    expect(ctrl.user, isNull);
    expect(ctrl.status, SyncStatus.off);
  });

  test('sync 재진입 가드: 동시 호출이 겹쳐도 예외 없이 완료', () async {
    final auth = FakeAuthService();
    final cloud = FakeCloudStore();
    final local = MemoryBackend();
    final ctrl = SyncController(
        auth: auth, cloud: cloud, local: local, nowMs: () => 1000);
    ctrl.start();
    await ctrl.signIn();
    await Future.wait<void>([ctrl.sync(), ctrl.sync(), ctrl.sync()]);
    expect(ctrl.status, SyncStatus.idle);
  });

  test('signIn: reconcile 정확히 1회(이중 _onUser 없음)', () async {
    final spy = _SpyCloud(FakeCloudStore());
    final ctrl = SyncController(
        auth: FakeAuthService(), cloud: spy, local: MemoryBackend(),
        nowMs: () => 1000);
    ctrl.start();
    await ctrl.signIn();
    // 빈 로컬·클라우드 → push 없음 → watch 재발화 없음 →
    // reconcile 1회 = loadCollection 4회(컬렉션당 1). 이중 호출이면 8.
    expect(spy.loads, 4);
  });

  test('외부 인증 변경(스트림)도 reconcile 트리거(영구 deaf 아님)', () async {
    final spy = _SpyCloud(FakeCloudStore());
    final auth = FakeAuthService();
    final ctrl = SyncController(
        auth: auth, cloud: spy, local: MemoryBackend(), nowMs: () => 1000);
    ctrl.start();
    await ctrl.signIn(); // 명시 전환(loads=4)
    final before = spy.loads;
    // 토큰 갱신처럼 스트림으로 직접 사용자 변경(signIn 경유 아님)
    auth.emit(const AuthUser(uid: 'u-ext', email: 'ext@example.com'));
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(ctrl.user?.uid, 'u-ext'); // 스트림이 반영됨
    expect(spy.loads, greaterThan(before)); // reconcile 다시 트리거
  });

  test('signOut 후 클라우드 변경이 sync를 트리거하지 않음', () async {
    final spy = _SpyCloud(FakeCloudStore());
    final ctrl = SyncController(
        auth: FakeAuthService(), cloud: spy, local: MemoryBackend(),
        nowMs: () => 1000);
    ctrl.start();
    await ctrl.signIn();
    await ctrl.signOut();
    final after = spy.loads;
    await spy.setDoc('u-test', 'plans', 'X', {'updatedAt': 1});
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(spy.loads, after); // 비로그인 → 동기 안 함
  });

  test('reconcile 실패 시 status error', () async {
    final spy = _SpyCloud(FakeCloudStore())..throwOnLoad = true;
    final ctrl = SyncController(
        auth: FakeAuthService(), cloud: spy, local: MemoryBackend(),
        nowMs: () => 1000);
    ctrl.start();
    await ctrl.signIn(); // reconcile가 throwOnLoad로 실패
    expect(ctrl.status, SyncStatus.error);
  });

  // --- 트리거 갭: 로컬→클라우드 (주기 + 앱 복귀) ---

  test('주기 트리거: signed-in 동안 interval마다 reconcile 재실행', () {
    fakeAsync((async) {
      final spy = _SpyCloud(FakeCloudStore());
      final ctrl = SyncController(
          auth: FakeAuthService(), cloud: spy, local: MemoryBackend(),
          nowMs: () => 1000, syncInterval: const Duration(seconds: 30));
      ctrl.start();
      ctrl.signIn();
      async.flushMicrotasks();
      final after = spy.loads; // 초기 화해 완료
      async.elapse(const Duration(seconds: 30));
      async.flushMicrotasks();
      expect(spy.loads, greaterThan(after)); // 주기 틱이 sync 재실행
    });
  });

  test('주기 트리거: signOut 후 멈춤', () {
    fakeAsync((async) {
      final spy = _SpyCloud(FakeCloudStore());
      final ctrl = SyncController(
          auth: FakeAuthService(), cloud: spy, local: MemoryBackend(),
          nowMs: () => 1000, syncInterval: const Duration(seconds: 30));
      ctrl.start();
      ctrl.signIn();
      async.flushMicrotasks();
      ctrl.signOut();
      async.flushMicrotasks();
      final after = spy.loads;
      async.elapse(const Duration(seconds: 90));
      async.flushMicrotasks();
      expect(spy.loads, after); // 비로그인 → 주기 트리거 정지
    });
  });

  test('주기 트리거: dispose 후 멈춤', () {
    fakeAsync((async) {
      final spy = _SpyCloud(FakeCloudStore());
      final ctrl = SyncController(
          auth: FakeAuthService(), cloud: spy, local: MemoryBackend(),
          nowMs: () => 1000, syncInterval: const Duration(seconds: 30));
      ctrl.start();
      ctrl.signIn();
      async.flushMicrotasks();
      final after = spy.loads;
      ctrl.dispose();
      async.elapse(const Duration(seconds: 90));
      async.flushMicrotasks();
      expect(spy.loads, after); // dispose가 타이머 정리
    });
  });

  test('앱 복귀 신호: signed-in이면 reconcile, 비로그인이면 무시', () async {
    final resume = StreamController<void>.broadcast();
    final spy = _SpyCloud(FakeCloudStore());
    final ctrl = SyncController(
        auth: FakeAuthService(), cloud: spy, local: MemoryBackend(),
        nowMs: () => 1000, onAppResume: resume.stream);
    ctrl.start();
    // 비로그인 상태 복귀 → 무시
    resume.add(null);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(spy.loads, 0);
    // 로그인 후 복귀 → reconcile
    await ctrl.signIn();
    final after = spy.loads;
    resume.add(null);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(spy.loads, greaterThan(after));
    await ctrl.signOut();
    await resume.close();
  });

  // --- 인터리브 하드닝: 동시 _onUser가 고아 타이머/스테일 부착을 못 만들게 ---

  test('빠른 인증 전환 인터리브: signOut 후 어떤 타이머도 sync를 발화하지 않음(고아 없음)', () {
    fakeAsync((async) {
      final spy = _SpyCloud(FakeCloudStore())
        ..loadDelay = const Duration(seconds: 10); // 첫 reconcile 파킹
      final auth = FakeAuthService();
      final ctrl = _ProbeController(
          auth: auth, cloud: spy, local: MemoryBackend(),
          nowMs: () => 1000, syncInterval: const Duration(seconds: 30));
      ctrl.start();
      auth.emit(const AuthUser(uid: 'u-a', email: 'a@example.com'));
      async.flushMicrotasks(); // _onUser(A)가 느린 reconcile에 파킹
      auth.emit(const AuthUser(uid: 'u-b', email: 'b@example.com'));
      async.flushMicrotasks(); // _onUser(B)가 추월해 watch/timer 부착
      async.elapse(const Duration(seconds: 60)); // 지연 로드 진행
      spy.loadDelay = Duration.zero;
      ctrl.signOut();
      async.flushMicrotasks(); // 참조된 타이머·watch 정리
      final calls = ctrl.syncCalls;
      async.elapse(const Duration(minutes: 3));
      async.flushMicrotasks();
      // 고아 주기 타이머가 남았다면 틱마다 sync()가 불려 증가한다.
      expect(ctrl.syncCalls, calls);
    });
  });

  test('전환 비행 중 dispose: 이후 타이머 발화 0 + notify-after-dispose 없음', () {
    fakeAsync((async) {
      final spy = _SpyCloud(FakeCloudStore())
        ..loadDelay = const Duration(seconds: 10);
      final auth = FakeAuthService();
      final ctrl = _ProbeController(
          auth: auth, cloud: spy, local: MemoryBackend(),
          nowMs: () => 1000, syncInterval: const Duration(seconds: 30));
      ctrl.start();
      auth.emit(const AuthUser(uid: 'u-a', email: 'a@example.com'));
      async.flushMicrotasks(); // 초기 reconcile에 파킹된 채로
      ctrl.dispose();
      final calls = ctrl.syncCalls;
      // 비행 중이던 reconcile이 완료돼도(throw 없이) watch/timer를 부착하면 안 된다.
      async.elapse(const Duration(minutes: 5));
      async.flushMicrotasks();
      expect(ctrl.syncCalls, calls);
    });
  });
}
