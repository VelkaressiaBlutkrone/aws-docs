// flutter_app/test/account_deletion_test.dart
//
// A7 — 계정 삭제(앱·웹 공통). Play 는 앱 내에서 계정과 관련 데이터를 지울 수 있어야
// 한다고 요구하고, 이 레포에는 그 경로가 없었다.
//
// ⚠️⚠️ **순서가 안전 설계다.** `firestore.rules` 가 `request.auth.uid == uid` 를
// 요구하므로 Auth 계정을 먼저 지우면 그 사용자의 문서를 **영원히 지울 수 없다**(고아
// 데이터). 문서 → Auth 순서면 중간에 실패해도 계정이 남아 재시도된다.
//
// ⚠️⚠️ **Firestore 클라이언트 SDK 는 서브컬렉션을 나열할 수 없다**(`listCollections`
// 는 서버 SDK 전용). 그래서 삭제는 `kSyncedCollections` 를 돌며 할 수밖에 없고, 그
// 목록이 낡으면 **지워지지 않은 데이터가 조용히 남는다** — 드리프트 가드가 그래서 있다.
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aws_docs/data/cloud/auth_service.dart';
import 'package:aws_docs/data/cloud/auth_user.dart';
import 'package:aws_docs/data/cloud/cloud_store.dart';
import 'package:aws_docs/data/cloud/sync_controller.dart';
import 'package:aws_docs/data/cloud/sync_meta.dart';
import 'package:aws_docs/data/cloud/synced_collections.dart';
// local_kv(MemoryBackend)는 viewed_docs_store가 re-export 한다.
import 'package:aws_docs/data/viewed_docs_store.dart';
import 'package:aws_docs/pages/sync_entry.dart';
import 'package:aws_docs/theme/app_theme.dart';
import 'package:aws_docs/theme/theme_scope.dart';

const _uid = 'u-del';
const _user = AuthUser(uid: _uid, email: 'del@example.com');

/// 재인증·삭제 결과를 테스트가 지정하는 AuthService. 호출 순서를 [log] 에 적는다.
class _ScriptedAuth implements AuthService {
  _ScriptedAuth(this.log, {this.signedIn = true});

  final List<String> log;
  bool signedIn;

  /// 재인증 결과. false 면 사용자가 취소한 것이다.
  bool reauthOk = true;

  /// 재인증이 던질 예외(취소가 아닌 실패).
  Object? reauthThrows;

  /// Auth 계정 삭제가 던질 예외.
  Object? deleteThrows;

  final _ctrl = StreamController<AuthUser?>.broadcast();

  @override
  AuthUser? get current => signedIn ? _user : null;
  @override
  Stream<AuthUser?> authChanges() => _ctrl.stream;

  @override
  Future<void> signInWithGoogle() async => signedIn = true;
  @override
  Future<void> signOut() async => signedIn = false;

  @override
  Future<bool> reauthenticate() async {
    log.add('reauth');
    final e = reauthThrows;
    if (e != null) throw e;
    return reauthOk;
  }

  @override
  Future<void> deleteAccount() async {
    log.add('deleteAccount');
    final e = deleteThrows;
    if (e != null) throw e;
    signedIn = false;
  }
}

/// 삭제 호출을 세고 선택적으로 던지는 클라우드. 내용은 FakeCloudStore 가 들고 있다.
class _SpyCloud implements CloudStore {
  _SpyCloud(this._inner, this.log, {this.liveWatch = false});
  final CloudStore _inner;
  final List<String> log;

  /// 변경 알림을 컨트롤러에 흘릴지. 기본은 **끈다** — 켜면 `setDoc` 한 번이
  /// watch → `sync()` → reconcile 을 깨워 테스트 본문과 섞이고, 순서·범위 단정이
  /// 비결정적이 된다. 그 끼어들기 자체는 전용 테스트가 켠 채로 본다.
  final bool liveWatch;

  /// 이 컬렉션의 삭제에서 던진다(부분 실패 재현).
  String? throwOnDeleteIn;

  @override
  Future<void> setDoc(String uid, String collection, String docId,
      Map<String, dynamic> data) {
    log.add('set:$collection/$docId');
    return _inner.setDoc(uid, collection, docId, data);
  }

  @override
  Future<void> deleteDoc(String uid, String collection, String docId) async {
    log.add('del:$collection/$docId');
    if (collection == throwOnDeleteIn) throw Exception('cloud boom');
    return _inner.deleteDoc(uid, collection, docId);
  }

  @override
  Future<Map<String, Map<String, dynamic>>> loadCollection(
          String uid, String collection) =>
      _inner.loadCollection(uid, collection);

  @override
  Stream<Map<String, Map<String, dynamic>>> watchCollection(
          String uid, String collection) =>
      liveWatch
          ? _inner.watchCollection(uid, collection)
          : const Stream.empty();
}

/// 사용자 소유 컬렉션 전부에 문서를 하나씩 심는다(동기 컬렉션 + 피드백).
Future<void> _seedCloud(CloudStore c) async {
  for (final col in kUserOwnedCollections) {
    await c.setDoc(_uid, col, 'doc-$col', {'v': 1});
  }
}

Future<int> _cloudDocCount(CloudStore c) async {
  var n = 0;
  for (final col in kUserOwnedCollections) {
    n += (await c.loadCollection(_uid, col)).length;
  }
  return n;
}

void main() {
  group('A7 동기 컬렉션 목록', () {
    test('비어 있지 않고 중복이 없다', () {
      expect(kSyncedCollections, isNotEmpty);
      expect(kSyncedCollections.toSet().length, kSyncedCollections.length);
    });

    // ⚠️⚠️ 이 가드가 A7 의 핵심이다. 컬렉션 이름이 상수로 모여 있지 않고
    // `sync_service.dart` 에 리터럴로 흩어져 있어서, 새 컬렉션을 쓰기 시작하면
    // 계정 삭제가 그것을 **조용히 남긴다**. 소스에서 집합을 뽑아 맞댄다.
    test('sync_service가 쓰는 컬렉션 집합과 같다', () {
      final src = File('lib/data/cloud/sync_service.dart').readAsStringSync();
      // 대조군: 파일을 실제로 읽었다(추출이 깨져 빈 집합이 되는 거짓 통과 방지).
      expect(src, contains('class SyncService'));

      final used = RegExp(r"\(uid, '([a-z]+)'")
          .allMatches(src)
          .map((m) => m.group(1)!)
          .toSet();
      expect(used, isNotEmpty, reason: '컬렉션 리터럴 추출이 깨졌다');
      expect(used, equals(kSyncedCollections.toSet()),
          reason: '동기가 쓰는 컬렉션과 동기 목록이 다르다');
    });

    // D2 — 피드백은 **동기 화해 대상이 아니지만 삭제 대상**이다. 둘을 한 목록에
    // 두면 위 소스 대조 가드가 깨지고(피드백은 `sync_service.dart` 를 거치지
    // 않는다), 삭제 목록에서 빠뜨리면 사용자가 지웠다고 믿는 데이터가 남는다.
    test('feedback 은 동기 집합에 없고 소유 집합에 있다', () {
      expect(kSyncedCollections, isNot(contains('feedback')));
      expect(kUserOwnedCollections, contains('feedback'));
      expect(kUserOwnedCollections.toSet().length,
          kUserOwnedCollections.length);
      // 소유 집합은 동기 집합을 전부 포함한다(동기 데이터도 사용자 소유다).
      expect(kUserOwnedCollections.toSet(),
          containsAll(kSyncedCollections.toSet()));
    });
  });

  group('A7 계정 삭제 흐름', () {
    late List<String> log;
    late _ScriptedAuth auth;
    late _SpyCloud cloud;
    late MemoryBackend local;
    late SyncController ctrl;

    setUp(() async {
      log = [];
      auth = _ScriptedAuth(log);
      cloud = _SpyCloud(FakeCloudStore(), log);
      local = MemoryBackend();
      ctrl = SyncController(auth: auth, cloud: cloud, local: local);

      // ⚠️ 로그인 상태를 실제로 만든다. 이것 없이는 `ctrl.user`가 처음부터 null이라
      // 「성공 뒤 로그아웃 상태가 된다」가 **자명하게 통과**한다(거짓 통과).
      await ctrl.signIn();
      expect(ctrl.user, isNotNull);

      await _seedCloud(cloud);
      // 로컬에도 기록을 하나 심는다(초기화되는지 보려면 비어 있지 않아야 한다).
      ViewedDocsStore(backend: local).markViewed('SAA-C03', 'saa-t1-1');
      SyncMeta(local).syncedAtMs = 1000;
      log.clear(); // 로그인 중의 호출은 삭제 순서 판정과 무관하다
    });

    tearDown(() => ctrl.dispose());

    test('성공 순서: 재인증 → 클라우드 문서 → Auth 계정 → 로컬', () async {
      final ok = await ctrl.deleteAccount();
      expect(ok, isTrue);

      final first = log.first;
      final lastCloud = log.lastIndexWhere((e) => e.startsWith('del:'));
      final authAt = log.indexOf('deleteAccount');
      expect(first, 'reauth');
      expect(lastCloud, lessThan(authAt),
          reason: 'Auth 계정을 먼저 지우면 규칙이 그 문서 삭제를 막는다');
      expect(await _cloudDocCount(cloud), 0);
    });

    // ⚠️⚠️ 실제로 겪은 결함이고 이 테스트가 그것을 잡았다. 문서를 지우면
    // `watchCollection`이 변경을 내보내고 그 구독이 `sync()`를 돌려 **삭제 도중에
    // reconcile이 끼어든다** — 로컬 데이터를 클라우드에 다시 쓰면 방금 지운 문서가
    // 되살아나고, Auth 계정이 사라진 뒤라면 규칙 거부로 status가 error가 된다.
    // 그래서 `deleteAccount`의 첫 단계가 `_onUser(null)`(동기 정리)이다.
    //
    // ⚠️ 이 테스트만 watch를 **켠다** — 그래야 결함이 재현된다. 켠 채로는 seed가
    // reconcile을 깨우므로 `sync()`와 이벤트 큐로 가라앉힌 뒤 로그를 비운다.
    test('watch가 살아 있어도 삭제 중 클라우드 쓰기가 끼어들지 않는다', () async {
      final log2 = <String>[];
      final auth2 = _ScriptedAuth(log2);
      final cloud2 = _SpyCloud(FakeCloudStore(), log2, liveWatch: true);
      final local2 = MemoryBackend();
      final c2 = SyncController(auth: auth2, cloud: cloud2, local: local2);
      addTearDown(c2.dispose);

      await c2.signIn();
      await _seedCloud(cloud2);
      await c2.sync();
      await pumpEventQueue();
      log2.clear();

      await c2.deleteAccount();
      await pumpEventQueue();
      expect(log2.where((e) => e.startsWith('set:')), isEmpty,
          reason: 'watch로 깨어난 reconcile이 지운 문서를 되살린다');
    });

    test('사용자 소유 컬렉션 전부를 돈다', () async {
      await ctrl.deleteAccount();
      final touched = log
          .where((e) => e.startsWith('del:'))
          .map((e) => e.substring(4).split('/').first)
          .toSet();
      expect(touched, equals(kUserOwnedCollections.toSet()));
    });

    test('로컬 학습 기록도 지운다', () async {
      expect(ViewedDocsStore(backend: local).viewed('SAA-C03'), isNotEmpty);
      await ctrl.deleteAccount();
      expect(ViewedDocsStore(backend: local).viewed('SAA-C03'), isEmpty);
    });

    // ⚠️⚠️ 사이드카를 남기면 **다음에 다른 계정으로 로그인할 때** 그 계정의 클라우드
    // 기록을 「초기화 표식보다 오래된 것」으로 보고 지운다. 계정 삭제는 이 기기를
    // 동기 미경험 상태로 되돌려야 한다.
    test('동기 사이드카를 비운다', () async {
      await ctrl.deleteAccount();
      expect(SyncMeta(local).resetAt, isEmpty);
      expect(SyncMeta(local).syncedAtMs, 0);
      expect((local.read(SyncMeta.key) ?? '').isEmpty, isTrue);
    });

    test('성공 뒤 로그아웃 상태가 된다', () async {
      await ctrl.deleteAccount();
      expect(ctrl.user, isNull);
      expect(ctrl.status, SyncStatus.off);
    });

    test('재인증을 취소하면 아무것도 지우지 않는다', () async {
      // 로그인 reconcile이 문서를 더 썼을 수 있으므로 절대 수가 아니라 불변을 본다.
      final before = await _cloudDocCount(cloud);
      auth.reauthOk = false;
      final ok = await ctrl.deleteAccount();
      expect(ok, isFalse);
      expect(log, ['reauth']);
      expect(await _cloudDocCount(cloud), before);
      expect(ViewedDocsStore(backend: local).viewed('SAA-C03'), isNotEmpty);
      expect(ctrl.user, isNotNull);
    });

    test('클라우드 삭제가 실패하면 Auth 계정을 지우지 않는다', () async {
      cloud.throwOnDeleteIn = 'plans';
      await expectLater(ctrl.deleteAccount(), throwsA(isA<Exception>()));
      expect(log, isNot(contains('deleteAccount')));
      expect(ViewedDocsStore(backend: local).viewed('SAA-C03'), isNotEmpty,
          reason: '계정이 남아 있으면 로컬도 남겨 재시도할 수 있어야 한다');
    });

    test('Auth 삭제가 실패하면 전파하고 로컬을 지우지 않는다', () async {
      auth.deleteThrows = StateError('auth boom');
      await expectLater(ctrl.deleteAccount(), throwsA(isA<StateError>()));
      expect(ViewedDocsStore(backend: local).viewed('SAA-C03'), isNotEmpty);
    });

    test('비로그인 상태에서는 아무 일도 하지 않는다', () async {
      auth.signedIn = false;
      final ok = await ctrl.deleteAccount();
      expect(ok, isFalse);
      expect(log, isEmpty);
    });
  });

  group('A7 플랫폼 분기(소스 가드)', () {
    // 플러그인·Firebase 호출은 VM 에 구현이 없어 분기를 실행으로 검증할 수 없다.
    test('웹은 팝업 재인증, 네이티브는 credential 재인증을 쓴다', () {
      final src =
          File('lib/data/cloud/firebase_auth_service.dart').readAsStringSync();
      expect(src, contains('class FirebaseAuthService')); // 대조군
      expect(src, contains('reauthenticateWithPopup'));
      expect(src, contains('reauthenticateWithCredential'));
      // A4 의 네이티브 흐름을 재사용한다 — 취소를 false 로 돌려주는 계약이 같다.
      expect(src, contains('runNativeGoogleLogin'));
      expect(src, contains('kIsWeb'));
    });
  });

  group('A7 진입점', () {
    Widget wrap(SyncController? c) => ThemeScope(
          isDark: false,
          toggle: () {},
          child: MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: SyncEntry(controller: ValueNotifier<SyncController?>(c)),
            ),
          ),
        );

    testWidgets('로그인 상태에만 계정 삭제가 보인다', (tester) async {
      final signedOut = _ScriptedAuth([], signedIn: false);
      final a = SyncController(
          auth: signedOut, cloud: FakeCloudStore(), local: MemoryBackend());
      addTearDown(a.dispose);
      await tester.pumpWidget(wrap(a));
      expect(find.textContaining('계정 삭제'), findsNothing);

      final signedIn = _ScriptedAuth([]);
      final b = SyncController(
          auth: signedIn, cloud: FakeCloudStore(), local: MemoryBackend());
      addTearDown(b.dispose);
      await b.signIn();
      await tester.pumpWidget(wrap(b));
      await tester.pump();
      expect(find.textContaining('계정 삭제'), findsOneWidget);
    });
  });
}
