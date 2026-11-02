// flutter_app/test/cloud/sync_watch_retry_test.dart
import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aws_docs/data/cloud/auth_service.dart';
import 'package:aws_docs/data/cloud/cloud_store.dart';
import 'package:aws_docs/data/cloud/sync_controller.dart';
import 'package:aws_docs/data/local_kv.dart';

/// 리뷰 M-8의 **선결** — `watchCollection` 구독에 `onError`도 재구독도 없어서
/// 스트림이 한 번 끊기면(규칙 거부·네트워크 단절) **조용히 영구 중단**됐다.
/// 그 상태에서는 다른 기기의 변경을 30초 주기 reconcile만으로 받게 되므로,
/// 주기 간격을 건드리기 전에 watch 쪽 복구를 먼저 세운다.
///
/// 정본: `docs/audits/2026-09-22-app-code-ux-review.md` M-8.

/// watch 스트림에 **오류를 주입**할 수 있고 **구독 횟수를 세는** 스토어.
class _FlakyWatchCloud implements CloudStore {
  _FlakyWatchCloud(this._inner);
  final CloudStore _inner;

  /// 컬렉션별 `watchCollection` 호출 수 = 구독 시도 수(재구독이 여기 찍힌다).
  final subscribes = <String, int>{};
  final _ctrls =
      <String, StreamController<Map<String, Map<String, dynamic>>>>{};

  @override
  Future<void> setDoc(String uid, String collection, String docId,
          Map<String, dynamic> data) =>
      _inner.setDoc(uid, collection, docId, data);

  @override
  Future<void> deleteDoc(String uid, String collection, String docId) =>
      _inner.deleteDoc(uid, collection, docId);

  @override
  Future<Map<String, Map<String, dynamic>>> loadCollection(
          String uid, String collection) =>
      _inner.loadCollection(uid, collection);

  @override
  Stream<Map<String, Map<String, dynamic>>> watchCollection(
      String uid, String collection) {
    subscribes[collection] = (subscribes[collection] ?? 0) + 1;
    final key = '$uid/$collection';
    // 재구독마다 **새 컨트롤러**를 준다 — 닫힌 스트림을 다시 듣는 상황을 피한다.
    final c = StreamController<Map<String, Map<String, dynamic>>>();
    _ctrls[key] = c;
    return c.stream;
  }

  /// 현재 구독 중인 스트림에 오류를 흘린다.
  void failWatch(String uid, String collection) =>
      _ctrls['$uid/$collection']?.addError(StateError('watch 끊김'));

  /// 현재 구독 중인 스트림에 변경 이벤트를 흘린다.
  void emit(String uid, String collection) =>
      _ctrls['$uid/$collection']?.add(const {});
}

/// sync() 호출 수를 센다 — 재구독 뒤 이벤트가 실제로 reconcile을 트리거하는지,
/// 그리고 로그아웃 뒤 고아 타이머가 남지 않는지를 관측한다.
class _ProbeController extends SyncController {
  _ProbeController({
    required super.auth,
    required super.cloud,
    required super.local,
    super.syncInterval,
    super.watchRetryDelay,
  });
  int syncCalls = 0;

  @override
  Future<void> sync() {
    syncCalls++;
    return super.sync();
  }
}

const _uid = 'u-test'; // FakeAuthService.signInWithGoogle이 쓰는 uid(실측)
const _retry = Duration(seconds: 3);

void main() {
  test('watch 오류 뒤 재구독하고, 재구독한 스트림의 이벤트로 reconcile한다', () {
    fakeAsync((fa) {
      final cloud = _FlakyWatchCloud(FakeCloudStore());
      final c = _ProbeController(
        auth: FakeAuthService(),
        cloud: cloud,
        local: MemoryBackend(),
        syncInterval: null, // 주기 트리거 없음 — watch 경로만 본다
        watchRetryDelay: _retry,
      );
      c.signIn();
      fa.flushMicrotasks();

      expect(cloud.subscribes['attempts'], 1, reason: '로그인 직후 1회 구독');
      final afterSignIn = c.syncCalls;

      cloud.failWatch(_uid, 'attempts');
      fa.flushMicrotasks();
      expect(cloud.subscribes['attempts'], 1,
          reason: '오류 즉시 재구독하면 실패 폭주가 된다 — 지연 뒤에 다시 붙는다');

      fa.elapse(_retry);
      fa.flushMicrotasks();
      expect(cloud.subscribes['attempts'], 2, reason: '재구독되지 않았다 — 변경 수신이 영구 중단된다');

      cloud.emit(_uid, 'attempts');
      fa.flushMicrotasks();
      expect(c.syncCalls, greaterThan(afterSignIn),
          reason: '재구독한 스트림의 이벤트가 reconcile을 트리거하지 않는다');

      c.dispose();
      fa.flushTimers();
    });
  });

  test('watch 오류는 동기 상태를 error로 만든다', () {
    fakeAsync((fa) {
      final cloud = _FlakyWatchCloud(FakeCloudStore());
      final c = _ProbeController(
        auth: FakeAuthService(),
        cloud: cloud,
        local: MemoryBackend(),
        syncInterval: null,
        watchRetryDelay: _retry,
      );
      c.signIn();
      fa.flushMicrotasks();
      expect(c.status, SyncStatus.idle, reason: '전제: 정상 로그인은 idle로 끝난다');

      cloud.failWatch(_uid, 'attempts');
      fa.flushMicrotasks();
      expect(c.status, SyncStatus.error,
          reason: '변경 수신이 끊긴 것도 사용자가 알아야 하는 실패다(m-3 표시와 같은 경로)');

      c.dispose();
      fa.flushTimers();
    });
  });

  test('로그아웃하면 대기 중인 재구독이 취소된다 — 고아 타이머 없음', () {
    fakeAsync((fa) {
      final cloud = _FlakyWatchCloud(FakeCloudStore());
      final c = _ProbeController(
        auth: FakeAuthService(),
        cloud: cloud,
        local: MemoryBackend(),
        syncInterval: null,
        watchRetryDelay: _retry,
      );
      c.signIn();
      fa.flushMicrotasks();
      cloud.failWatch(_uid, 'attempts');
      fa.flushMicrotasks();

      c.signOut(); // 재구독 타이머가 아직 대기 중인 시점
      fa.flushMicrotasks();
      final subsAtSignOut = cloud.subscribes['attempts'];

      fa.elapse(_retry * 2);
      fa.flushMicrotasks();

      expect(cloud.subscribes['attempts'], subsAtSignOut,
          reason: '로그아웃 뒤에 재구독하면 비로그인 상태로 watch가 살아난다');

      c.dispose();
      fa.flushTimers();
    });
  });
}
