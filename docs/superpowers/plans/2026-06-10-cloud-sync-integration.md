# 클라우드 동기 통합 (Plan 2/2) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Plan 1의 동기 코어를 실제 Firebase + 앱에 연결 — Google 로그인 시 4종 데이터를 기기 간 동기. 미설정/미로그인이면 로컬-only(graceful degrade).

**Architecture:** **reconcile-on-trigger**(가로채기 없음). `SyncController`가 인증 상태를 구독해 로그인 시 `SyncService.reconcileAll` + Firestore watch를 시작하고, 변경 수신·앱 복귀·주기 트리거에 멱등 reconcile를 재실행한다. Firebase는 선택적 init(스텁 `firebase_options` + 게이트)이라 미설정 시 전부 off. SyncService는 스토어와 같은 localStorage를 읽고/써서 별도 가로채기 불필요.

**Tech Stack:** Dart, FlutterFire(`firebase_core`/`firebase_auth`/`cloud_firestore`), `flutter_test`. Plan 1 산출물(`lib/data/cloud/{auth_service,cloud_store,sync_merge,sync_service}.dart` + Fakes) 재사용.

**Spec:** `docs/superpowers/specs/2026-06-10-cloud-sync-design.md` (reconcile-on-trigger 반영본). **Branch:** `feat/cloud-sync-integration`.
**검증(각 코드 Task 끝):** `cd flutter_app && flutter analyze lib && flutter test`.

> **🚧 라이브 한계:** `FirestoreCloudStore`·`FirebaseAuthService`·`Firebase.initializeApp`는 **컴파일·graceful-degrade만 검증**(에이전트는 Firebase 크레덴셜 없음). 실제 Google 로그인·Firestore 왕복·2기기·규칙은 **사용자가 Firebase 프로젝트 설정 후(Task 6) 수동 검증.** 테스트는 `Fake*` + `MemoryBackend`로 `SyncController`·게이트·UI 로직을 커버.

---

## 파일 구조 (Plan 2)
| 파일 | 책임 | 검증 |
|---|---|---|
| `flutter_app/pubspec.yaml`(수정) | Firebase 의존성 | 빌드 |
| `flutter_app/lib/firebase_options.dart` | **스텁**(REPLACE_ME, 사용자가 flutterfire로 덮음) | 컴파일 |
| `flutter_app/lib/data/cloud/firebase_bootstrap.dart` | 선택적 init + `cloudConfigured()` 게이트 | 게이트 단위테스트 |
| `flutter_app/lib/data/cloud/firestore_cloud_store.dart` | `CloudStore`의 Firestore 구현 | 컴파일만 |
| `flutter_app/lib/data/cloud/firebase_auth_service.dart` | `AuthService`의 Google 로그인 구현 | 컴파일만 |
| `flutter_app/lib/data/cloud/sync_controller.dart` | 인증·트리거 오케스트레이션 + `SyncNotifier` | Fake 단위테스트 |
| `flutter_app/lib/pages/settings_sync_*` 또는 기존 설정 진입점(수정) | 동기 진입점·상태 UI | 위젯테스트 |
| `flutter_app/lib/main.dart`(수정) | 부트스트랩 배선(graceful degrade) | 컴파일 |
| `flutter_app/test/cloud/*` | 단위·위젯 테스트 | |

---

## Task 1: Firebase 의존성 + 스텁 firebase_options + bootstrap 게이트

**Files:** Modify `flutter_app/pubspec.yaml`; Create `flutter_app/lib/firebase_options.dart`, `flutter_app/lib/data/cloud/firebase_bootstrap.dart`; Test `flutter_app/test/cloud/firebase_bootstrap_test.dart`

> 이 Task가 Firebase 의존성 빌드 리스크를 먼저 제거한다.

- [ ] **Step 1: 의존성 추가**

Run: `cd flutter_app && flutter pub add firebase_core firebase_auth cloud_firestore`
Expected: pubspec.yaml에 3개 추가, `flutter pub get` 성공.
**버전 충돌(version solving failed) 시:** 강제하지 말고 충돌 제약을 보고하고 BLOCKED 처리(컨트롤러가 SDK 제약을 판단). 웹 Firebase JS SDK는 `firebase_core`가 init 시 자동 주입하므로 `web/index.html` 수정 불필요(미설정이면 init을 안 하니 로드도 안 됨).

- [ ] **Step 2: 스텁 firebase_options.dart 작성**
```dart
// flutter_app/lib/firebase_options.dart
// 스텁. 사용자가 `flutterfire configure` 실행 시 실제 값으로 덮인다.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => const FirebaseOptions(
        apiKey: 'REPLACE_ME',
        appId: 'REPLACE_ME',
        messagingSenderId: 'REPLACE_ME',
        projectId: 'REPLACE_ME',
      );
}
```

- [ ] **Step 3: 실패 테스트(게이트)**
```dart
// flutter_app/test/cloud/firebase_bootstrap_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/cloud/firebase_bootstrap.dart';

void main() {
  test('cloudConfigured: 스텁(REPLACE_ME)이면 false', () {
    expect(cloudConfigured(), isFalse);
  });
}
```

- [ ] **Step 4: 실패 확인** — `flutter test test/cloud/firebase_bootstrap_test.dart` → FAIL(미존재)

- [ ] **Step 5: bootstrap 구현**
```dart
// flutter_app/lib/data/cloud/firebase_bootstrap.dart
import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options.dart';

/// firebase_options가 실제 설정(REPLACE_ME 아님)인가. 순수 — Firebase init 불필요.
bool cloudConfigured() =>
    DefaultFirebaseOptions.currentPlatform.projectId != 'REPLACE_ME';

/// 설정됐으면 Firebase init 후 true, 아니면 false(cloud off). 미설정 시 init 미호출.
Future<bool> initFirebaseIfConfigured() async {
  if (!cloudConfigured()) return false;
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform);
  return true;
}
```

- [ ] **Step 6: 통과** — `flutter test test/cloud/firebase_bootstrap_test.dart` → PASS

- [ ] **Step 7: 빌드 확인** — `cd flutter_app && flutter analyze lib` → no issues. (PowerShell에서) `flutter build web --release --base-href /aws-docs/` → `√ Built build\web`(Firebase 의존성 추가 후에도 빌드 성공 확인).

- [ ] **Step 8: 커밋**(REPO 루트에서; pubspec.lock도 의존성 추가분이라 함께 커밋)
```bash
git add flutter_app/pubspec.yaml flutter_app/pubspec.lock flutter_app/lib/firebase_options.dart flutter_app/lib/data/cloud/firebase_bootstrap.dart flutter_app/test/cloud/firebase_bootstrap_test.dart
git commit -m "feat(sync): Firebase 의존성 + 스텁 firebase_options + bootstrap 게이트"
```

---

## Task 2: FirestoreCloudStore (CloudStore의 Firestore 구현 — 컴파일만)

**Files:** Create `flutter_app/lib/data/cloud/firestore_cloud_store.dart`

> 라이브 미검증(Firebase 필요). 얇은 패스스루. `users/{uid}/{collection}/{docId}` 모델.

- [ ] **Step 1: 구현**
```dart
// flutter_app/lib/data/cloud/firestore_cloud_store.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cloud_store.dart';

/// CloudStore의 Firestore 구현. users/{uid}/{collection}/{docId} = data.
/// 라이브 검증은 사용자 Firebase 설정 후(수동).
class FirestoreCloudStore implements CloudStore {
  FirestoreCloudStore([FirebaseFirestore? db])
      : _db = db ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _col(String uid, String collection) =>
      _db.collection('users').doc(uid).collection(collection);

  @override
  Future<void> setDoc(String uid, String collection, String docId,
          Map<String, dynamic> data) =>
      _col(uid, collection).doc(docId).set(data);

  @override
  Future<Map<String, Map<String, dynamic>>> loadCollection(
      String uid, String collection) async {
    final snap = await _col(uid, collection).get();
    return {for (final d in snap.docs) d.id: d.data()};
  }

  @override
  Stream<Map<String, Map<String, dynamic>>> watchCollection(
          String uid, String collection) =>
      _col(uid, collection).snapshots().map(
          (qs) => {for (final d in qs.docs) d.id: d.data()});
}
```

- [ ] **Step 2: 컴파일 확인** — `cd flutter_app && flutter analyze lib` → no issues. (`flutter test` → 기존 전부 그대로 통과; 이 파일은 아직 미사용.)

- [ ] **Step 3: 커밋**
```bash
git add flutter_app/lib/data/cloud/firestore_cloud_store.dart
git commit -m "feat(sync): FirestoreCloudStore(CloudStore Firestore 구현·컴파일만)"
```

---

## Task 3: FirebaseAuthService (AuthService의 Google 로그인 — 컴파일만)

**Files:** Create `flutter_app/lib/data/cloud/firebase_auth_service.dart`

> 라이브 미검증. 웹 Google 로그인 = `signInWithPopup(GoogleAuthProvider())`(별도 google_sign_in 불필요).

- [ ] **Step 1: 구현**
```dart
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
```

- [ ] **Step 2: 컴파일 확인** — `cd flutter_app && flutter analyze lib` → no issues. `flutter test` → 기존 그대로.

- [ ] **Step 3: 커밋**
```bash
git add flutter_app/lib/data/cloud/firebase_auth_service.dart
git commit -m "feat(sync): FirebaseAuthService(Google 로그인·컴파일만)"
```

---

## Task 4: SyncController (오케스트레이션 + SyncNotifier — Fake로 테스트)

**Files:** Create `flutter_app/lib/data/cloud/sync_controller.dart`; Test `flutter_app/test/cloud/sync_controller_test.dart`

> 인증 구독 → 로그인 시 reconcile + watch, 트리거에 멱등 reconcile. 재진입 가드(busy/pending). `ChangeNotifier`로 UI 통지. SyncService는 이미 존재(Plan 1).

- [ ] **Step 1: 실패 테스트**
```dart
// flutter_app/test/cloud/sync_controller_test.dart
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/local_kv.dart';
import 'package:aws_docs/data/cloud/auth_service.dart';
import 'package:aws_docs/data/cloud/cloud_store.dart';
import 'package:aws_docs/data/cloud/sync_controller.dart';

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
    await Future.wait([ctrl.sync(), ctrl.sync(), ctrl.sync()]);
    expect(ctrl.status, SyncStatus.idle);
  });
}
```

- [ ] **Step 2: 실패 확인** — `flutter test test/cloud/sync_controller_test.dart` → FAIL

- [ ] **Step 3: 구현**
```dart
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
  })  : _auth = auth,
        _cloud = cloud,
        _svc = SyncService(local: local, cloud: cloud, nowMs: nowMs);

  final AuthService _auth;
  final CloudStore _cloud;
  final SyncService _svc;

  StreamSubscription<AuthUser?>? _authSub;
  final List<StreamSubscription> _watchSubs = [];
  AuthUser? _user;
  SyncStatus _status = SyncStatus.off;
  bool _busy = false;
  bool _pending = false;

  AuthUser? get user => _user;
  SyncStatus get status => _status;

  void start() {
    _authSub ??= _auth.authChanges().listen(_onUser);
  }

  Future<void> signIn() async {
    await _auth.signInWithGoogle();
    await _onUser(_auth.current);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _onUser(null);
  }

  Future<void> _onUser(AuthUser? u) async {
    _user = u;
    await _cancelWatches();
    if (u == null) {
      _set(SyncStatus.off);
      return;
    }
    await sync(); // 초기 화해
    _startWatches(u.uid); // 클라우드 변경 수신
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
      _watchSubs.add(_cloud.watchCollection(uid, coll).listen((_) => sync()));
    }
  }

  Future<void> _cancelWatches() async {
    for (final s in _watchSubs) {
      await s.cancel();
    }
    _watchSubs.clear();
  }

  void _set(SyncStatus s) {
    _status = s;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _cancelWatches();
    super.dispose();
  }
}
```

- [ ] **Step 4: 통과** — `flutter test test/cloud/sync_controller_test.dart` → PASS (3)

> 주의: watch가 sync 중 push로 재발화 → sync()가 busy면 pending으로 1회 재실행, 멱등이라 신규 push 없으면 수렴. 무한 루프 없음.

- [ ] **Step 5: 전체 검증 + 커밋**
```bash
cd flutter_app && flutter analyze lib && flutter test
```
Expected: analyze 무이슈, 전 테스트 통과.
```bash
git add flutter_app/lib/data/cloud/sync_controller.dart flutter_app/test/cloud/sync_controller_test.dart
git commit -m "feat(sync): SyncController(reconcile-on-trigger + SyncNotifier)"
```

---

## Task 5: 부트스트랩 배선 + 동기 UI 진입점

**Files:** Modify `flutter_app/lib/main.dart`; Create `flutter_app/lib/pages/sync_entry.dart`; Test `flutter_app/test/cloud/sync_entry_test.dart`. (기존 설정/홈 헤더에 진입점 1개 추가.)

> graceful degrade: 미설정이면 `SyncController` 미생성(또는 off 유지). UI는 `SyncController`(또는 null)를 받아 비로그인/로그인 표시.

- [ ] **Step 1: 실패 테스트(UI 위젯)**
```dart
// flutter_app/test/cloud/sync_entry_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/local_kv.dart';
import 'package:aws_docs/data/cloud/auth_service.dart';
import 'package:aws_docs/data/cloud/cloud_store.dart';
import 'package:aws_docs/data/cloud/sync_controller.dart';
import 'package:aws_docs/pages/sync_entry.dart';
import 'package:aws_docs/theme/theme_scope.dart';

Widget _host(SyncController? ctrl) => ThemeScope(
      child: MaterialApp(home: Scaffold(body: SyncEntry(controller: ctrl))),
    );

void main() {
  testWidgets('미설정(controller null): 비활성 안내', (tester) async {
    await tester.pumpWidget(_host(null));
    expect(find.textContaining('동기'), findsWidgets);
  });

  testWidgets('비로그인: "Google로 동기 켜기" 표시 → 탭 시 로그인', (tester) async {
    final ctrl = SyncController(
        auth: FakeAuthService(), cloud: FakeCloudStore(),
        local: MemoryBackend(), nowMs: () => 1000);
    ctrl.start();
    await tester.pumpWidget(_host(ctrl));
    expect(find.textContaining('Google'), findsOneWidget);
    await tester.tap(find.textContaining('Google'));
    await tester.pumpAndSettle();
    // 로그인 후 이메일 표시
    expect(find.textContaining('test@example.com'), findsOneWidget);
  });
}
```

- [ ] **Step 2: 실패 확인** — `flutter test test/cloud/sync_entry_test.dart` → FAIL

- [ ] **Step 3: SyncEntry 구현**(DESIGN.md 절제 — `c.surface2`/`c.border`, 액센트는 동작 링크에만)
```dart
// flutter_app/lib/pages/sync_entry.dart
import 'package:flutter/material.dart';

import '../data/cloud/sync_controller.dart';
import '../theme/app_theme.dart';

/// 동기 진입점. controller==null이면 미설정(비활성) 안내.
class SyncEntry extends StatelessWidget {
  const SyncEntry({super.key, this.controller});
  final SyncController? controller;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final ctrl = controller;
    if (ctrl == null) {
      return _box(c, Text('기기 간 동기 — 미설정', style: TextStyle(color: c.textMuted)));
    }
    return AnimatedBuilder(
      animation: ctrl,
      builder: (context, _) {
        final user = ctrl.user;
        if (user == null) {
          return _box(
            c,
            Row(children: [
              Expanded(child: Text('기기 간 동기', style: TextStyle(color: c.text))),
              TextButton(
                onPressed: ctrl.signIn,
                child: Text('Google로 동기 켜기',
                    style: TextStyle(color: c.accent, fontWeight: FontWeight.w700)),
              ),
            ]),
          );
        }
        return _box(
          c,
          Row(children: [
            Expanded(
              child: Text('동기 켜짐 · ${user.email}',
                  style: TextStyle(color: c.text), overflow: TextOverflow.ellipsis),
            ),
            if (ctrl.status == SyncStatus.syncing)
              Padding(
                padding: const EdgeInsets.only(right: Gap.sm),
                child: SizedBox(
                    width: 14, height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: c.textMuted)),
              ),
            TextButton(
              onPressed: ctrl.signOut,
              child: Text('로그아웃', style: TextStyle(color: c.textMuted)),
            ),
          ]),
        );
      },
    );
  }

  Widget _box(AppColors c, Widget child) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Gap.lg),
        decoration: BoxDecoration(
          color: c.surface2,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(color: c.border),
        ),
        child: child,
      );
}
```
> `AppColors` 타입명·`context.c`·`Gap`·`Radii`·`c.surface2`/`c.textMuted`/`c.accent`가 실제 `theme/app_theme.dart`와 일치하는지 확인(다르면 실제 토큰명으로 교체). 다르면 보고.

- [ ] **Step 4: 통과** — `flutter test test/cloud/sync_entry_test.dart` → PASS (2)

- [ ] **Step 5: main.dart 부트스트랩 배선**

`flutter_app/lib/main.dart`를 읽고, `runApp` 전에 부트스트랩을 추가한다(기존 구조 보존). 패턴:
```dart
// main() 안, runApp 전:
SyncController? syncController;
final configured = await initFirebaseIfConfigured(); // import firebase_bootstrap.dart
if (configured) {
  syncController = SyncController(
    auth: FirebaseAuthService(),
    cloud: FirestoreCloudStore(),
    local: WebBackend(), // 스토어와 같은 localStorage
  )..start();
}
// syncController를 앱 트리에 전달(예: 기존 설정/홈에서 SyncEntry(controller: syncController)).
```
- `WidgetsFlutterBinding.ensureInitialized()`가 `await` 부트스트랩 전에 호출돼야 한다(이미 있으면 유지).
- `main()`이 `async`가 아니면 `Future<void> main() async {`로.
- `WebBackend`는 `package:aws_docs/data/local_kv.dart`에서 export됨(없으면 `defaultBackend()` 사용).
- syncController 전달은 기존 앱이 무엇을 쓰는지(전역/InheritedWidget/생성자)에 맞춘다. 가장 단순히, 설정 진입 화면이 SyncEntry를 렌더할 때 이 컨트롤러를 넘긴다. 미설정이면 null → SyncEntry가 "미설정" 표시.
- **graceful degrade 회귀:** 미설정(현재 상태)에서 `flutter test` 전부 통과·앱 동작 불변이어야 한다.

- [ ] **Step 6: 진입점 노출** — 사용자가 동기 UI에 닿게 한다. 가장 가벼운 방법: 홈 설정(⚙) 다이얼로그/시트 또는 기존 설정 화면에 `SyncEntry(controller: syncController)` 1개 추가. (새 전체화면 만들지 말 것 — DESIGN.md 절제.) 기존 라우트/위젯을 읽고 최소 침습으로 끼운다.

- [ ] **Step 7: 전체 검증** — `cd flutter_app && flutter analyze lib` → no issues. `flutter test` → 전부 통과. (PowerShell) `flutter build web --release --base-href /aws-docs/` → 빌드 성공.

- [ ] **Step 8: 커밋**
```bash
git add flutter_app/lib/main.dart flutter_app/lib/pages/sync_entry.dart flutter_app/test/cloud/sync_entry_test.dart <진입점 수정 파일>
git commit -m "feat(sync): 부트스트랩 배선(graceful degrade) + 동기 UI 진입점"
```

---

## Task 6: (사용자) Firebase 설정 → 라이브 검증
코드 Task 아님. 사용자가 수행:
1. Firebase 콘솔에서 프로젝트 생성 → 웹 앱 등록.
2. `cd flutter_app && flutterfire configure` → `lib/firebase_options.dart` 실제 값으로 덮임.
3. 콘솔에서 **Cloud Firestore** 생성 + **Authentication → Google** 공급자 사용 설정.
4. Firestore 보안 규칙 배포(스펙 §8): `match /users/{uid}/{document=**} { allow read, write: if request.auth != null && request.auth.uid == uid; }`
5. Auth → Settings → Authorized domains에 `velkaressiablutkrone.github.io` 추가.
6. 라이브 검증: 두 브라우저/기기에서 같은 Google 계정 로그인 → 한쪽 학습/체크 → 다른 쪽에 동기 반영. 로그아웃·미로그인은 로컬-only.

---

## Self-Review (작성자 점검)
- **스펙 커버리지:** §3(SyncController·graceful degrade)→T4·T5; §4(스텁·게이트)→T1; §5(Firestore 모델)→T2; §6(reconcile-on-trigger·watch·재진입가드)→T4; §7(UI)→T5; §10(의존성·사용자 액션)→T1·T6; §8(규칙)→T6. Plan 1(코어)은 완료.
- **플레이스홀더:** 없음. `<진입점 수정 파일>`·main 배선은 "기존 구조를 읽고 최소 침습"으로 명시(실제 파일은 구현자가 확인) — 코드 패턴은 제공.
- **타입 일관성:** `SyncController({auth,cloud,local,nowMs})`·`status`/`user`/`signIn`/`signOut`/`sync`·`SyncStatus`가 T4 정의와 T5 사용 일치. `CloudStore`/`AuthService` 시그니처는 Plan 1과 동일. `cloudConfigured()`/`initFirebaseIfConfigured()` T1↔T5 일치.
- **컴파일-only 표시:** T2·T3은 라이브 미검증 명시. 라이브는 T6(사용자).

## 실행 핸드오프
플랜 저장: `docs/superpowers/plans/2026-06-10-cloud-sync-integration.md`. 두 가지 실행: **1. Subagent-Driven(권장)** / **2. Inline**. 어느 방식?
