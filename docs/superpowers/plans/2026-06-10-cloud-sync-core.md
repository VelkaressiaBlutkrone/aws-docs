# 클라우드 동기 코어 (Plan 1/2) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Firebase 없이 빌드·단위테스트 가능한 동기 코어 — `AuthService`/`CloudStore` 인터페이스 + Fake 구현 + 엔티티 병합 엔진(attempts union·viewed set union·plan/checks LWW) + `SyncService` 화해.

**Architecture:** 순수 병합 함수(`sync_merge.dart`)가 충돌 해소의 핵심이고, `SyncService`가 로컬 `KvBackend` 블롭 ↔ `CloudStore` 사이를 화해한다. 인증·클라우드는 인터페이스 뒤로 추상화해 `Fake`로 테스트한다. 실제 Firebase·앱 통합·UI는 **Plan 2**.

**Tech Stack:** Dart, `flutter_test`. 기존 `KvBackend`/`MemoryBackend`(local_kv.dart)·`AttemptRecord` 재사용. Firebase 의존성 없음(이 플랜 범위).

**Spec:** `docs/superpowers/specs/2026-06-10-cloud-sync-design.md`
**Branch:** `feat/cloud-sync` (스펙 커밋 `dd4c90b`)
**검증(각 Task 끝):** `cd flutter_app && flutter analyze lib && flutter test`

> **이 플랜의 범위 = 스펙 §12 증분 1·2.** 로컬 스키마·키(`awsdocs.*`) 불변. 새 사이드카 키 `awsdocs.sync.v1`(plan/checks LWW 타임스탬프)만 추가.

---

## 파일 구조 (Plan 1)
| 파일 | 책임 |
|---|---|
| `lib/data/cloud/auth_user.dart` | `AuthUser{uid,email}` |
| `lib/data/cloud/auth_service.dart` | `AuthService` 인터페이스 + `FakeAuthService` |
| `lib/data/cloud/cloud_store.dart` | `CloudStore` 인터페이스 + `FakeCloudStore`(메모리) |
| `lib/data/cloud/sync_merge.dart` | 순수 병합: `attemptKey`·`mergeAttempts`·`mergeViewed`·`mergeLww` |
| `lib/data/cloud/sync_service.dart` | 로컬 KvBackend ↔ CloudStore 화해(`reconcileAll`·`pushLocal`·`applyCloud`) + 사이드카 |
| `test/cloud/*` | 단위 테스트 |

(Plan 2: `synced_kv_backend.dart`·전역 홀더·`firebase_bootstrap.dart`+스텁·`firestore_cloud_store.dart`·`firebase_auth_service.dart`·UI.)

---

## Task 1: AuthUser + AuthService 인터페이스 + Fake

**Files:** Create `flutter_app/lib/data/cloud/auth_user.dart`, `flutter_app/lib/data/cloud/auth_service.dart`; Test `flutter_app/test/cloud/auth_service_test.dart`

- [ ] **Step 1: 실패 테스트**
```dart
// flutter_app/test/cloud/auth_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/cloud/auth_user.dart';
import 'package:aws_docs/data/cloud/auth_service.dart';

void main() {
  test('FakeAuthService: 로그인/로그아웃 상태·스트림', () async {
    final a = FakeAuthService();
    expect(a.current, isNull);
    final seen = <AuthUser?>[];
    final sub = a.authChanges().listen(seen.add);
    await a.signInWithGoogle();
    expect(a.current, isNotNull);
    expect(a.current!.uid, isNotEmpty);
    await a.signOut();
    expect(a.current, isNull);
    await Future<void>.delayed(Duration.zero);
    expect(seen.length, 2); // 로그인·로그아웃
    expect(seen.first?.uid, isNotEmpty);
    expect(seen.last, isNull);
    await sub.cancel();
  });
}
```

- [ ] **Step 2: 실패 확인** — `cd flutter_app && flutter test test/cloud/auth_service_test.dart` → FAIL(미존재)

- [ ] **Step 3: 구현**
```dart
// flutter_app/lib/data/cloud/auth_user.dart
class AuthUser {
  const AuthUser({required this.uid, required this.email});
  final String uid;
  final String email;
}
```
```dart
// flutter_app/lib/data/cloud/auth_service.dart
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
```

- [ ] **Step 4: 통과** — `flutter test test/cloud/auth_service_test.dart` → PASS

- [ ] **Step 5: 커밋**
```bash
git add flutter_app/lib/data/cloud/auth_user.dart flutter_app/lib/data/cloud/auth_service.dart flutter_app/test/cloud/auth_service_test.dart
git commit -m "feat(sync): AuthService 인터페이스 + FakeAuthService"
```

---

## Task 2: CloudStore 인터페이스 + FakeCloudStore

**Files:** Create `flutter_app/lib/data/cloud/cloud_store.dart`; Test `flutter_app/test/cloud/cloud_store_test.dart`

> `CloudStore`는 멍청한 키드-문서 저장소다(병합 의미는 SyncService 담당). collection ∈ {attempts,viewed,plans,checks}, docId=레코드키/certCode, data=JSON.

- [ ] **Step 1: 실패 테스트**
```dart
// flutter_app/test/cloud/cloud_store_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/cloud/cloud_store.dart';

void main() {
  test('FakeCloudStore: setDoc·loadCollection 왕복 + uid/컬렉션 격리', () async {
    final cs = FakeCloudStore();
    await cs.setDoc('u1', 'plans', 'CLF-C02', {'x': 1});
    await cs.setDoc('u1', 'plans', 'SAA-C03', {'x': 2});
    await cs.setDoc('u2', 'plans', 'CLF-C02', {'x': 9});
    final u1 = await cs.loadCollection('u1', 'plans');
    expect(u1.keys.toSet(), {'CLF-C02', 'SAA-C03'});
    expect(u1['CLF-C02'], {'x': 1});
    expect((await cs.loadCollection('u2', 'plans'))['CLF-C02'], {'x': 9});
    expect(await cs.loadCollection('u1', 'attempts'), isEmpty);
  });

  test('FakeCloudStore: watchCollection이 setDoc마다 스냅샷 방출', () async {
    final cs = FakeCloudStore();
    final snaps = <Map<String, Map<String, dynamic>>>[];
    final sub = cs.watchCollection('u1', 'viewed').listen(snaps.add);
    await cs.setDoc('u1', 'viewed', 'CLF-C02', {'taskIds': ['t1']});
    await Future<void>.delayed(Duration.zero);
    expect(snaps.last['CLF-C02'], {'taskIds': ['t1']});
    await sub.cancel();
  });
}
```

- [ ] **Step 2: 실패 확인** — `flutter test test/cloud/cloud_store_test.dart` → FAIL

- [ ] **Step 3: 구현**
```dart
// flutter_app/lib/data/cloud/cloud_store.dart
import 'dart:async';

/// 키드-문서 클라우드 저장소 추상화. 병합 의미는 SyncService가 담당.
abstract interface class CloudStore {
  Future<void> setDoc(
      String uid, String collection, String docId, Map<String, dynamic> data);
  Future<Map<String, Map<String, dynamic>>> loadCollection(
      String uid, String collection);
  Stream<Map<String, Map<String, dynamic>>> watchCollection(
      String uid, String collection);
}

/// 메모리 구현(테스트). uid→collection→docId→data.
class FakeCloudStore implements CloudStore {
  final _d = <String, Map<String, Map<String, Map<String, dynamic>>>>{};
  final _ctrls =
      <String, StreamController<Map<String, Map<String, dynamic>>>>{};

  @override
  Future<void> setDoc(String uid, String collection, String docId,
      Map<String, dynamic> data) async {
    final coll = ((_d[uid] ??= {})[collection] ??= {});
    coll[docId] = Map<String, dynamic>.from(data);
    _emit(uid, collection);
  }

  @override
  Future<Map<String, Map<String, dynamic>>> loadCollection(
      String uid, String collection) async {
    final coll = _d[uid]?[collection] ?? const {};
    return {
      for (final e in coll.entries) e.key: Map<String, dynamic>.from(e.value),
    };
  }

  @override
  Stream<Map<String, Map<String, dynamic>>> watchCollection(
          String uid, String collection) =>
      (_ctrls['$uid/$collection'] ??=
              StreamController<Map<String, Map<String, dynamic>>>.broadcast())
          .stream;

  void _emit(String uid, String collection) {
    final c = _ctrls['$uid/$collection'];
    if (c == null) return;
    final coll = _d[uid]?[collection] ?? const {};
    c.add({
      for (final e in coll.entries) e.key: Map<String, dynamic>.from(e.value),
    });
  }
}
```

- [ ] **Step 4: 통과** — `flutter test test/cloud/cloud_store_test.dart` → PASS (2)

- [ ] **Step 5: 커밋**
```bash
git add flutter_app/lib/data/cloud/cloud_store.dart flutter_app/test/cloud/cloud_store_test.dart
git commit -m "feat(sync): CloudStore 인터페이스 + FakeCloudStore"
```

---

## Task 3: attemptKey + mergeAttempts (union·무손실)

**Files:** Create `flutter_app/lib/data/cloud/sync_merge.dart`; Test `flutter_app/test/cloud/sync_merge_attempts_test.dart`

- [ ] **Step 1: 실패 테스트**
```dart
// flutter_app/test/cloud/sync_merge_attempts_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/models/attempt_record.dart';
import 'package:aws_docs/data/cloud/sync_merge.dart';

AttemptRecord _r(String examId, String date, {String cert = 'CLF-C02'}) =>
    AttemptRecord(
      certId: cert, examId: examId, mode: 'exam', date: date,
      correct: 1, total: 1, wrongQuestionIds: const [],
      flaggedQuestionIds: const [], durationSpentSec: 1,
    );

void main() {
  test('attemptKey: certId|examId|date 안정·금지문자 치환', () {
    final k = attemptKey(_r('exam:CLF-C02-mock', '2026-06-10T09:00:00.000'));
    expect(k, isNotEmpty);
    expect(k.contains('/'), isFalse);
    expect(k.contains('.'), isFalse);
    expect(attemptKey(_r('exam:CLF-C02-mock', '2026-06-10T09:00:00.000')), k); // 안정
  });

  test('mergeAttempts: 양쪽 union·무손실 + 로컬 신규만 toCloud', () {
    final l1 = _r('exam:CLF-C02-mock', '2026-06-10T09:00:00.000'); // 로컬 전용
    final shared = _r('practice:clf-t1-1', '2026-06-09T10:00:00.000'); // 양쪽
    final c1 = _r('exam:CLF-C02-weak', '2026-06-11T08:00:00.000'); // 클라우드 전용
    final local = [l1, shared];
    final cloud = {
      attemptKey(shared): shared.toJson(),
      attemptKey(c1): c1.toJson(),
    };
    final r = mergeAttempts(local, cloud);
    // 병합 = 3건(유실 없음)
    expect(r.merged.map(attemptKey).toSet(),
        {attemptKey(l1), attemptKey(shared), attemptKey(c1)});
    // 클라우드에 없던 로컬(l1)만 push
    expect(r.toCloud.keys.toSet(), {attemptKey(l1)});
  });
}
```

- [ ] **Step 2: 실패 확인** — `flutter test test/cloud/sync_merge_attempts_test.dart` → FAIL

- [ ] **Step 3: 구현** — `flutter_app/lib/data/cloud/sync_merge.dart`:
```dart
import '../../models/attempt_record.dart';

/// Firestore 문서 ID 금지문자 치환.
String _sanitize(String s) => s.replaceAll(RegExp(r'[/.#\$\[\]]'), '_');

/// 응시 1건의 안정적 클라우드 키(certId|examId|date — 응시당 유일).
String attemptKey(AttemptRecord r) =>
    _sanitize('${r.certId}|${r.examId}|${r.date}');

/// attempts union(무손실): 로컬 리스트 + 클라우드(키→json)
/// → 병합 리스트 + 클라우드에 없던 로컬만 toCloud(키→json).
({List<AttemptRecord> merged, Map<String, Map<String, dynamic>> toCloud})
    mergeAttempts(
        List<AttemptRecord> local, Map<String, Map<String, dynamic>> cloud) {
  final byKey = <String, AttemptRecord>{};
  for (final r in local) {
    byKey[attemptKey(r)] = r;
  }
  for (final e in cloud.entries) {
    byKey.putIfAbsent(e.key, () => AttemptRecord.fromJson(e.value));
  }
  final toCloud = <String, Map<String, dynamic>>{};
  for (final r in local) {
    final k = attemptKey(r);
    if (!cloud.containsKey(k)) toCloud[k] = r.toJson();
  }
  return (merged: byKey.values.toList(), toCloud: toCloud);
}
```

- [ ] **Step 4: 통과** — `flutter test test/cloud/sync_merge_attempts_test.dart` → PASS (2)

- [ ] **Step 5: 커밋**
```bash
git add flutter_app/lib/data/cloud/sync_merge.dart flutter_app/test/cloud/sync_merge_attempts_test.dart
git commit -m "feat(sync): mergeAttempts union(무손실) + attemptKey"
```

---

## Task 4: mergeViewed (set union)

**Files:** Modify `flutter_app/lib/data/cloud/sync_merge.dart`; Test `flutter_app/test/cloud/sync_merge_viewed_test.dart`

- [ ] **Step 1: 실패 테스트**
```dart
// flutter_app/test/cloud/sync_merge_viewed_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/cloud/sync_merge.dart';

void main() {
  test('mergeViewed: cert별 taskId 합집합 + 변경 cert만 toCloud', () {
    final local = {
      'CLF-C02': {'t1', 't2'},
      'SAA-C03': {'s1'},
    };
    final cloud = {
      'CLF-C02': {'taskIds': ['t2', 't3']},   // 합 → t1,t2,t3
      'SOA-C03': {'taskIds': ['o1']},          // 로컬에 없음 → 추가
    };
    final r = mergeViewed(local, cloud);
    expect(r.merged['CLF-C02'], {'t1', 't2', 't3'});
    expect(r.merged['SAA-C03'], {'s1'});       // 클라우드에 없던 로컬 유지
    expect(r.merged['SOA-C03'], {'o1'});       // 클라우드 전용 흡수
    // 클라우드와 달라진 cert만 push: CLF(t1 추가)·SAA(신규)
    expect(r.toCloud.keys.toSet(), {'CLF-C02', 'SAA-C03'});
    expect((r.toCloud['CLF-C02']!['taskIds'] as List).toSet(), {'t1', 't2', 't3'});
  });
}
```

- [ ] **Step 2: 실패 확인** — `flutter test test/cloud/sync_merge_viewed_test.dart` → FAIL

- [ ] **Step 3: 구현** — `sync_merge.dart`에 추가:
```dart
/// viewed set union: 로컬 {cert:set} + 클라우드 {cert:{taskIds:[]}}
/// → 병합 {cert:set} + 클라우드와 달라진 cert만 toCloud {cert:{taskIds:[]}}.
({Map<String, Set<String>> merged, Map<String, Map<String, dynamic>> toCloud})
    mergeViewed(Map<String, Set<String>> local,
        Map<String, Map<String, dynamic>> cloud) {
  final merged = <String, Set<String>>{};
  final toCloud = <String, Map<String, dynamic>>{};
  final certs = {...local.keys, ...cloud.keys};
  for (final cert in certs) {
    final l = local[cert] ?? const <String>{};
    final cRaw = (cloud[cert]?['taskIds'] as List?)?.cast<String>() ?? const [];
    final c = cRaw.toSet();
    final union = {...l, ...c};
    merged[cert] = union;
    // 클라우드 집합과 다르면(로컬이 더한 게 있으면) push
    if (union.length != c.length) {
      toCloud[cert] = {'taskIds': union.toList()};
    }
  }
  return (merged: merged, toCloud: toCloud);
}
```

- [ ] **Step 4: 통과** — `flutter test test/cloud/sync_merge_viewed_test.dart` → PASS

- [ ] **Step 5: 커밋**
```bash
git add flutter_app/lib/data/cloud/sync_merge.dart flutter_app/test/cloud/sync_merge_viewed_test.dart
git commit -m "feat(sync): mergeViewed set union"
```

---

## Task 5: mergeLww (plan·checks LWW by updatedAt)

**Files:** Modify `flutter_app/lib/data/cloud/sync_merge.dart`; Test `flutter_app/test/cloud/sync_merge_lww_test.dart`

> 로컬 doc은 엔티티 JSON(타임스탬프 없음), 사이드카 `localMeta`(cert→ms)가 로컬 시각. 클라우드 doc은 `updatedAt` 포함. 병합 결과 로컬 doc은 `updatedAt` 제거(로컬 스키마 청결).

- [ ] **Step 1: 실패 테스트**
```dart
// flutter_app/test/cloud/sync_merge_lww_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/cloud/sync_merge.dart';

void main() {
  test('mergeLww: cert별 updatedAt 큰 쪽 채택·로컬 신/단독은 push', () {
    final local = {
      'CLF-C02': {'v': 'local-clf'},   // 로컬이 최신
      'SAA-C03': {'v': 'local-saa'},   // 로컬 단독
    };
    final localMeta = {'CLF-C02': 200, 'SAA-C03': 50};
    final cloud = {
      'CLF-C02': {'v': 'cloud-clf', 'updatedAt': 100}, // 로컬(200) 최신 → 로컬 유지
      'SOA-C03': {'v': 'cloud-soa', 'updatedAt': 300}, // 클라우드 단독 → 채택
    };
    final r = mergeLww(local, localMeta, cloud);
    expect(r.merged['CLF-C02'], {'v': 'local-clf'});       // 로컬 최신
    expect(r.mergedMeta['CLF-C02'], 200);
    expect(r.merged['SAA-C03'], {'v': 'local-saa'});        // 로컬 단독
    expect(r.merged['SOA-C03'], {'v': 'cloud-soa'});        // 클라우드 단독(updatedAt 제거)
    expect(r.merged['SOA-C03']!.containsKey('updatedAt'), isFalse);
    expect(r.mergedMeta['SOA-C03'], 300);
    // push 대상: 로컬이 더 최신/단독 = CLF(200>100)·SAA(단독)
    expect(r.toCloud.keys.toSet(), {'CLF-C02', 'SAA-C03'});
    expect(r.toCloud['CLF-C02']!['updatedAt'], 200);
  });

  test('mergeLww: 클라우드가 최신이면 클라우드 채택(로컬 메타 갱신)', () {
    final r = mergeLww(
      {'CLF-C02': {'v': 'old'}}, {'CLF-C02': 100},
      {'CLF-C02': {'v': 'new', 'updatedAt': 500}});
    expect(r.merged['CLF-C02'], {'v': 'new'});
    expect(r.mergedMeta['CLF-C02'], 500);
    expect(r.toCloud, isEmpty); // 클라우드가 최신 → push 안 함
  });
}
```

- [ ] **Step 2: 실패 확인** — `flutter test test/cloud/sync_merge_lww_test.dart` → FAIL

- [ ] **Step 3: 구현** — `sync_merge.dart`에 추가:
```dart
/// plan·checks LWW: 로컬 {cert:json} + 사이드카 localMeta{cert:ms}
/// + 클라우드 {cert:json+updatedAt} → 병합 doc/메타 + 로컬이 최신/단독인 cert만 toCloud(+updatedAt).
/// 동률·클라우드 우선은 클라우드 채택. 로컬 doc은 updatedAt 미포함(청결).
({
  Map<String, Map<String, dynamic>> merged,
  Map<String, int> mergedMeta,
  Map<String, Map<String, dynamic>> toCloud,
}) mergeLww(
    Map<String, Map<String, dynamic>> local,
    Map<String, int> localMeta,
    Map<String, Map<String, dynamic>> cloud) {
  final merged = <String, Map<String, dynamic>>{};
  final mergedMeta = <String, int>{};
  final toCloud = <String, Map<String, dynamic>>{};
  final certs = {...local.keys, ...cloud.keys};
  for (final cert in certs) {
    final localMs = localMeta[cert] ?? 0;
    final c = cloud[cert];
    final cloudMs = (c?['updatedAt'] as num?)?.toInt() ?? -1;
    if (c != null && cloudMs >= localMs && cloudMs >= 0) {
      final data = Map<String, dynamic>.from(c)..remove('updatedAt');
      merged[cert] = data;
      mergedMeta[cert] = cloudMs;
    } else if (local.containsKey(cert)) {
      merged[cert] = local[cert]!;
      mergedMeta[cert] = localMs;
      toCloud[cert] = {...local[cert]!, 'updatedAt': localMs};
    }
  }
  return (merged: merged, mergedMeta: mergedMeta, toCloud: toCloud);
}
```
> 주의: 첫 화해에서 사이드카가 없는 기존 로컬 엔티티는 `SyncService`가 화해 직전에 `nowMs()`로 스탬프(아래 Task 6) → 클라우드 stale가 로컬 신규를 덮지 않음.

- [ ] **Step 4: 통과** — `flutter test test/cloud/sync_merge_lww_test.dart` → PASS (2)

- [ ] **Step 5: 커밋**
```bash
git add flutter_app/lib/data/cloud/sync_merge.dart flutter_app/test/cloud/sync_merge_lww_test.dart
git commit -m "feat(sync): mergeLww(plan·checks LWW by updatedAt)"
```

---

## Task 6: SyncService (로컬 KvBackend ↔ CloudStore 화해)

**Files:** Create `flutter_app/lib/data/cloud/sync_service.dart`; Test `flutter_app/test/cloud/sync_service_test.dart`

> `SyncService`는 로컬 블롭(`awsdocs.history.v1`·`viewed.v1`·`plan.v1`·`plan.checks.v1`)을 읽어 병합 함수에 넘기고, 결과를 로컬에 되쓰고 `CloudStore`에 push한다. plan/checks LWW용 사이드카 = `awsdocs.sync.v1` = `{"plans":{cert:ms},"checks":{cert:ms}}`. 시각은 주입(`nowMs`)해 테스트 결정적.

- [ ] **Step 1: 실패 테스트**
```dart
// flutter_app/test/cloud/sync_service_test.dart
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/local_kv.dart';
import 'package:aws_docs/data/cloud/cloud_store.dart';
import 'package:aws_docs/data/cloud/sync_service.dart';

void main() {
  test('reconcileAll: 로컬·클라우드 attempts union이 로컬·클라우드 양쪽에 반영', () async {
    final local = MemoryBackend();
    // 로컬 history 1건
    local.write('awsdocs.history.v1', jsonEncode([
      {'certId': 'CLF-C02', 'examId': 'exam:CLF-C02-mock', 'mode': 'exam',
       'date': '2026-06-10T09:00:00.000', 'correct': 1, 'total': 1,
       'wrongQuestionIds': [], 'flaggedQuestionIds': [], 'durationSpentSec': 1}
    ]));
    final cloud = FakeCloudStore();
    // 클라우드 attempts 1건(다른 응시)
    await cloud.setDoc('u1', 'attempts', 'k-cloud', {
      'certId': 'CLF-C02', 'examId': 'exam:CLF-C02-weak', 'mode': 'exam',
      'date': '2026-06-11T08:00:00.000', 'correct': 1, 'total': 1,
      'wrongQuestionIds': [], 'flaggedQuestionIds': [], 'durationSpentSec': 1,
    });

    final svc = SyncService(local: local, cloud: cloud, nowMs: () => 1000);
    await svc.reconcileAll('u1');

    // 로컬 history = 2건(union·무손실)
    final localList = jsonDecode(local.read('awsdocs.history.v1')!) as List;
    expect(localList.length, 2);
    // 클라우드 attempts = 2건(로컬 신규 push됨)
    expect((await cloud.loadCollection('u1', 'attempts')).length, 2);
  });

  test('reconcileAll: plan LWW — 로컬이 최신이면 클라우드로 push', () async {
    final local = MemoryBackend();
    local.write('awsdocs.plan.v1', jsonEncode({
      'CLF-C02': {'certCode': 'CLF-C02', 'startIso': '2026-06-10',
        'endIso': '2026-06-24', 'mode': 'period', 'createdIso': '2026-06-10', 'items': []}
    }));
    final cloud = FakeCloudStore();
    final svc = SyncService(local: local, cloud: cloud, nowMs: () => 5000);
    await svc.reconcileAll('u1');
    // 사이드카가 없던 로컬 plan은 nowMs로 스탬프 후 클라우드에 push
    final cp = await cloud.loadCollection('u1', 'plans');
    expect(cp.containsKey('CLF-C02'), isTrue);
    expect(cp['CLF-C02']!['updatedAt'], 5000);
    // 사이드카 기록됨
    final meta = jsonDecode(local.read('awsdocs.sync.v1')!) as Map;
    expect((meta['plans'] as Map)['CLF-C02'], 5000);
  });
}
```

- [ ] **Step 2: 실패 확인** — `flutter test test/cloud/sync_service_test.dart` → FAIL

- [ ] **Step 3: 구현** — `flutter_app/lib/data/cloud/sync_service.dart`:
```dart
import 'dart:convert';

import '../local_kv.dart';
import '../../models/attempt_record.dart';
import 'cloud_store.dart';
import 'sync_merge.dart';

/// 로컬 KvBackend 블롭 ↔ CloudStore 엔티티 화해. 시각은 주입(테스트 결정적).
class SyncService {
  SyncService({
    required KvBackend local,
    required CloudStore cloud,
    int Function()? nowMs,
  })  : _local = local,
        _cloud = cloud,
        _now = nowMs ?? (() => DateTime.now().millisecondsSinceEpoch);

  final KvBackend _local;
  final CloudStore _cloud;
  final int Function() _now;

  static const _kHistory = 'awsdocs.history.v1';
  static const _kViewed = 'awsdocs.viewed.v1';
  static const _kPlans = 'awsdocs.plan.v1';
  static const _kChecks = 'awsdocs.plan.checks.v1';
  static const _kMeta = 'awsdocs.sync.v1';

  Map<String, dynamic> _readJsonMap(String key) {
    final raw = _local.read(key);
    if (raw == null || raw.isEmpty) return {};
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  List<dynamic> _readJsonList(String key) {
    final raw = _local.read(key);
    if (raw == null || raw.isEmpty) return [];
    try {
      return jsonDecode(raw) as List;
    } catch (_) {
      return [];
    }
  }

  Map<String, int> _meta(String section) {
    final m = _readJsonMap(_kMeta)[section];
    if (m is! Map) return {};
    return {for (final e in m.entries) e.key.toString(): (e.value as num).toInt()};
  }

  void _writeMeta(String section, Map<String, int> data) {
    final all = _readJsonMap(_kMeta);
    all[section] = data;
    _local.write(_kMeta, jsonEncode(all));
  }

  /// 로그인 직후 4종 양방향 화해.
  Future<void> reconcileAll(String uid) async {
    await _reconcileAttempts(uid);
    await _reconcileViewed(uid);
    await _reconcileLww(uid, _kPlans, 'plans', 'plans');
    await _reconcileLww(uid, _kChecks, 'checks', 'checks');
  }

  Future<void> _reconcileAttempts(String uid) async {
    final local = _readJsonList(_kHistory)
        .map((e) => AttemptRecord.fromJson(e as Map<String, dynamic>))
        .toList();
    final cloud = await _cloud.loadCollection(uid, 'attempts');
    final r = mergeAttempts(local, cloud);
    _local.write(_kHistory, jsonEncode(r.merged.map((e) => e.toJson()).toList()));
    for (final e in r.toCloud.entries) {
      await _cloud.setDoc(uid, 'attempts', e.key, e.value);
    }
  }

  Future<void> _reconcileViewed(String uid) async {
    final raw = _readJsonMap(_kViewed);
    final local = <String, Set<String>>{
      for (final e in raw.entries)
        e.key: ((e.value as List?) ?? const []).map((x) => x.toString()).toSet(),
    };
    final cloud = await _cloud.loadCollection(uid, 'viewed');
    final r = mergeViewed(local, cloud);
    _local.write(_kViewed,
        jsonEncode({for (final e in r.merged.entries) e.key: e.value.toList()}));
    for (final e in r.toCloud.entries) {
      await _cloud.setDoc(uid, 'viewed', e.key, e.value);
    }
  }

  Future<void> _reconcileLww(
      String uid, String localKey, String collection, String metaSection) async {
    final rawLocal = _readJsonMap(localKey);
    final local = <String, Map<String, dynamic>>{
      for (final e in rawLocal.entries)
        e.key: Map<String, dynamic>.from(e.value as Map),
    };
    var meta = _meta(metaSection);
    // 사이드카 없는 기존 로컬 엔티티는 now로 스탬프(클라우드 stale가 덮지 않게).
    final now = _now();
    for (final cert in local.keys) {
      meta.putIfAbsent(cert, () => now);
    }
    final cloud = await _cloud.loadCollection(uid, collection);
    final r = mergeLww(local, meta, cloud);
    _local.write(localKey, jsonEncode(r.merged));
    _writeMeta(metaSection, r.mergedMeta);
    for (final e in r.toCloud.entries) {
      await _cloud.setDoc(uid, collection, e.key, e.value);
    }
  }
}
```

- [ ] **Step 4: 통과** — `flutter test test/cloud/sync_service_test.dart` → PASS (2)

- [ ] **Step 5: 전체 검증 + 커밋**
```bash
cd flutter_app && flutter analyze lib && flutter test
```
Expected: analyze 무이슈, 전 테스트 통과(기존 230 + 신규).
```bash
git add flutter_app/lib/data/cloud/sync_service.dart flutter_app/test/cloud/sync_service_test.dart
git commit -m "feat(sync): SyncService — 로컬 KvBackend ↔ CloudStore 엔티티 화해 + 사이드카"
```

---

## Self-Review (작성자 점검)
- **스펙 커버리지:** §3(CloudStore/AuthService/SyncService)→T1·T2·T6; §5(엔티티 모델)→T3·T4·T5의 병합+T6의 컬렉션 매핑; §6.1 초기 화해→T6 reconcileAll; §9 단위(Fake)→전 Task. **이 플랜은 §12 증분 1·2.** push-on-write(SyncedKvBackend)·watch 수신·firebase_bootstrap·Firestore/FirebaseAuth 실연동·UI = **Plan 2**(아래).
- **플레이스홀더:** 없음(전 Task 완전 코드·테스트).
- **타입 일관성:** `AuthService`/`CloudStore` 시그니처, `mergeAttempts/Viewed/Lww` 반환 레코드, `SyncService(local:,cloud:,nowMs:)`·`reconcileAll(uid)`가 Task 전반 일치. KV 키 상수(`awsdocs.*`)는 기존 스토어와 동일.

## Plan 2 (후속 — 코어 검증 후 별도 플랜)
앱 통합·실연동·UI: ① 전역 백엔드 홀더(`local_kv.dart` 수정·싱글톤) ② `SyncedKvBackend`(쓰기 가로채 `SyncService.pushLocal` 디스패치, 루프가드=raw 로컬 직접쓰기) ③ watch 수신→로컬 병합→`SyncNotifier`→UI ④ `firebase_bootstrap.dart`+스텁 `firebase_options.dart`(REPLACE_ME 게이트) ⑤ `FirestoreCloudStore`·`FirebaseAuthService`(실연동, 컴파일·라이브 미검증) ⑥ 동기 진입점·상태 UI ⑦ (사용자) Firebase 프로젝트·`flutterfire configure`·규칙·authorized domains → 라이브 수동검증.

---

## 실행 핸드오프
플랜 완료·저장: `docs/superpowers/plans/2026-06-10-cloud-sync-core.md`. 두 가지 실행 방식:
1. **Subagent-Driven (권장)** — Task마다 새 서브에이전트, Task 사이 2단계 리뷰.
2. **Inline Execution** — executing-plans로 체크포인트 배치 실행.
어느 방식으로 진행할까요?
