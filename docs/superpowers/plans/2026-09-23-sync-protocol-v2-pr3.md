# 동기 프로토콜 v2 — PR3(정리·보안 규칙) 구현 플랜

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** v2로 옮겨간 뒤 남은 레거시 경로를 걷어내고, 동기 경로가 손상 데이터에 무너지지 않게 하고, 보안 규칙을 레포가 관리하게 한다.

**Architecture:** 동기는 로컬 블롭을 직접 파싱하지 않고 **스토어를 통해서만** 읽고 쓴다(값 형태 해석과 손상 보존을 한 곳에 둔다). 앱이 읽지 않는 `checks`는 동기 대상에서 빼고 클라우드 사본을 1회 정리한다. LWW 사이드카(`awsdocs.sync.v1`)는 쓰는 곳이 사라지므로 함께 제거한다.

**Tech Stack:** Flutter Web(Dart), `flutter_test`. 규칙 테스트만 Node(`@firebase/rules-unit-testing` + Firestore 에뮬레이터).

**Spec:** `docs/superpowers/specs/2026-09-23-sync-protocol-v2-design.md` (§6.1 비로그인 초기화 · §8 보안 규칙 · §10 PR 배분의 PR3 행)

**선행:** PR1(#129)·PR2(#130) develop 머지 완료. 기준선 **881 그린 · analyze 0**.

## Global Constraints

- 모든 Flutter 명령은 `flutter_app/` 디렉터리에서 실행한다. Flutter 3.47.2 고정.
- 각 Task 끝에서 `flutter analyze` 0건, `flutter test` 전부 통과를 눈으로 확인한다.
- 테스트를 먼저 쓰고 **실패를 확인한 뒤** 구현한다.
- 커밋 직전 `git branch --show-current`로 확인한다(공유 워킹트리).
- 브랜치는 `develop`에서 분기한 `feat/sync-v2-pr3-cleanup`, PR 대상은 `develop`.
- 커밋 메시지 마지막 줄: `Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>`
- **기존 테스트 파일을 Write로 덮어쓰지 않는다.** "추가"라고 한 파일은 내용을 덧붙인다.
- **로컬 쓰기와 클라우드 await를 섞지 않는다**(CODE-D-004): 클라우드 로드 → 로컬 읽기·판정·로컬 쓰기(await 없음) → 사이드카 저장 → 클라우드 쓰기.
- 로컬 데이터를 **지우는** 변경은 이 PR에 없다. 지우는 것은 클라우드의 레거시 `checks` 문서와 로컬 사이드카 `awsdocs.sync.v1`(파생 부기)뿐이다.

---

## 확인된 사실 (2026-09-23 실측)

- `PlanCheckStore`를 읽는 화면이 없다. `lib/` 안 사용처는 `study_reset.dart`의 `clearCert`/`clearAll`뿐 — 수동 체크 오버라이드는 이미 죽은 데이터다. 그래서 동기에서 빼도 기능 손실이 없다(스토어 자체 제거는 이 PR 범위 밖).
- `mergeLww`는 `sync_service.dart:388` 한 곳에서만 쓰인다. 그 호출이 사라지면 `_reconcileLww`·`_meta`·`_writeMeta`·`_readJsonMap`·`_kMeta`·`_kChecks`가 전부 미사용이 된다.
- `_reconcileAttempts`만 아직 로컬 블롭을 직접 파싱한다(`_readJsonList(_kHistory).map(AttemptRecord.fromJson)`) — 깨진 레코드 하나에 **예외로 화해 전체가 중단**된다. `HistoryStore._parse`는 이미 레코드 단위 관용 파싱이고 `_loadForRewrite`가 손상 원문을 `.corrupt`에 보존한다.
- Firestore 경로는 `users/{uid}/{collection}/{docId}`(`firestore_cloud_store.dart:13`)로, 스펙 §8 규칙이 그대로 덮는다. 레포에 `firestore.rules`·`firebase.json`은 **없다**(신규).
- 일정 삭제 표식은 지금 쌓이기만 한다. `planId`는 `planIdOf` 규칙상 `{certCode}:{createdIso}:{seq}`라 접두사에서 자격증을 되찾을 수 있다.

---

## File Structure

**신규**
- `firestore.rules`, `firebase.json` — 레포 루트.
- `tool/firestore_rules_test/{package.json,package-lock.json,rules.test.mjs}` — 규칙 테스트(에뮬레이터).
- `.github/workflows/firestore-rules.yml` — 규칙 파일이 바뀔 때만 도는 별도 워크플로(필수 체크 아님).
- `flutter_app/test/cloud/sync_cleanup_test.dart` — checks 정리·표식 정리 회귀.

**수정**
- `flutter_app/lib/data/history_store.dart` — `replaceAll` 추가.
- `flutter_app/lib/data/cloud/sync_service.dart` — 이력 읽기·쓰기를 스토어로, checks 1회 정리, 레거시 LWW 제거, 마지막 동기 시각 기록.
- `flutter_app/lib/data/cloud/sync_merge.dart` — `mergeLww` 제거.
- `flutter_app/lib/data/cloud/sync_meta.dart` — `checksPurged`·`lastSyncedAtMs`, 표식 정리 함수.
- `flutter_app/lib/content/reset_dialog.dart` — 비로그인 과거 동기 안내.
- `flutter_app/lib/data/cloud/sync_controller.dart` — watch 대상에서 `checks` 제거.
- 테스트: `test/history_store_test.dart`, `test/cloud/sync_service_test.dart`, `test/cloud/sync_meta_test.dart`, `test/cloud/sync_controller_test.dart`, `test/reset_sync_notice_test.dart`.
- **삭제**: `flutter_app/test/cloud/sync_merge_lww_test.dart`(45줄, `mergeLww` 전용).
- `CLAUDE.md` — 규칙 테스트 실행법 한 줄.

---

### Task 1: 동기가 이력을 스토어로 읽고 쓴다(관용 파싱 + 손상 보존)

**Files:**
- Modify: `flutter_app/lib/data/history_store.dart`, `flutter_app/lib/data/cloud/sync_service.dart`
- Test: `flutter_app/test/history_store_test.dart`(추가), `flutter_app/test/cloud/sync_service_test.dart`(추가)

**Interfaces:**
- Produces: `void HistoryStore.replaceAll(List<AttemptRecord> records)` — 다시 쓰기 전에 손상 원문을 보존하고, 값이 같으면 쓰지 않는다.
- Changes: `_reconcileAttempts`가 `HistoryStore.all()`로 읽고 `replaceAll`로 쓴다. `_readJsonList`·`_kHistory`는 미사용이 되므로 제거한다.

- [ ] **Step 1: 실패 테스트 작성**

`test/history_store_test.dart`의 마지막 `}` 앞에 추가:

```dart
  group('replaceAll — 동기 병합 결과 반영', () {
    const a = AttemptRecord(
      certId: 'CLF-C02', examId: 'exam:clf-t1-1', mode: 'exam',
      date: '2026-09-01T00:00:00.000', correct: 1, total: 1,
      wrongQuestionIds: [], flaggedQuestionIds: [], durationSpentSec: 10,
    );

    test('레코드를 통째로 바꾼다', () {
      final b = MemoryBackend();
      HistoryStore(backend: b).replaceAll([a]);
      expect(HistoryStore(backend: b).all().single.examId, 'exam:clf-t1-1');
    });

    test('깨진 원문은 덮어쓰기 전에 보존한다', () {
      const raw = '[{"certId":"CLF-C02"'; // 잘린 JSON
      final b = MemoryBackend()..write('awsdocs.history.v1', raw);
      HistoryStore(backend: b).replaceAll([a]);
      expect(b.read('awsdocs.history.v1.corrupt'), raw);
    });

    test('값이 같으면 다시 쓰지 않는다', () {
      final b = MemoryBackend();
      HistoryStore(backend: b).replaceAll([a]);
      final before = b.read('awsdocs.history.v1');
      HistoryStore(backend: b).replaceAll([a]);
      expect(identical(b.read('awsdocs.history.v1'), before), isTrue);
    });
  });
```

`test/cloud/sync_service_test.dart`의 마지막 `}` 앞에 추가:

```dart
  test('reconcileAll: 깨진 응시 레코드가 섞여 있어도 화해가 끝난다', () async {
    final local = MemoryBackend();
    local.write('awsdocs.history.v1', jsonEncode([
      {'certId': 'CLF-C02', 'examId': 'exam:clf-t1-1', 'mode': 'exam',
       'date': '2026-09-01T00:00:00.000', 'correct': 1, 'total': 1,
       'wrongQuestionIds': [], 'flaggedQuestionIds': [], 'durationSpentSec': 1},
      42, // 깨진 레코드
    ]));
    final cloud = FakeCloudStore();

    await SyncService(local: local, cloud: cloud, nowMs: () => 5000)
        .reconcileAll('u1'); // 예외 없이 완료

    expect((await cloud.loadCollection('u1', 'attempts')).length, 1);
    expect(local.read('awsdocs.history.v1.corrupt'), isNotNull); // 원문 보존
  });
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/history_store_test.dart test/cloud/sync_service_test.dart`
Expected: `replaceAll` 미정의로 컴파일 실패 + 동기 테스트는 깨진 레코드에서 예외.

- [ ] **Step 3: 구현**

`history_store.dart`의 `clearCert` 위에 추가:

```dart
  /// 동기 병합 결과를 통째로 반영한다. 다시 쓰기이므로 손상 원문을 먼저 보존하고,
  /// 값이 같으면 쓰지 않는다(무변경 reconcile이 매번 재기록하지 않게).
  void replaceAll(List<AttemptRecord> records) {
    _loadForRewrite(); // 버려진 부분이 있을 때만 원문 보존
    final next = jsonEncode(records.map((e) => e.toJson()).toList());
    if (_b.read(_key) != next) _b.write(_key, next);
  }
```

`sync_service.dart`에 `import '../history_store.dart';`를 추가하고 `_reconcileAttempts`를 교체한다:

```dart
  Future<void> _reconcileAttempts(String uid, Map<String, int> marks) async {
    final cloud = await _cloud.loadCollection(uid, 'attempts');
    // 스토어를 통해 읽는다 — 관용 파싱·손상 보존을 한 곳에 둔다(열람·일정과 동일).
    final store = HistoryStore(backend: _local);
    final local = store.all();
    final r = mergeAttempts(local, cloud, resetAt: marks);
    store.replaceAll(r.merged);
    for (final e in r.toCloud.entries) {
      await _cloud.setDoc(uid, 'attempts', e.key, e.value);
    }
    await _deleteUpTo(uid, 'attempts', r.toDelete);
  }
```

`_readJsonList`와 `_kHistory` 상수를 제거한다(다른 사용처 없음 — `grep -n "_readJsonList\|_kHistory" lib/data/cloud/sync_service.dart`로 확인).

- [ ] **Step 4: 통과 확인**

Run: `flutter test && flutter analyze`
Expected: 전부 PASS · 0건

- [ ] **Step 5: 커밋**

```bash
git branch --show-current
git add flutter_app/lib/data/history_store.dart flutter_app/lib/data/cloud/sync_service.dart flutter_app/test/history_store_test.dart flutter_app/test/cloud/sync_service_test.dart
git commit -m "fix(sync): 동기가 이력을 스토어로 읽고 써 깨진 레코드에 중단되지 않게

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
```

---

### Task 2: checks 동기 제외 + 클라우드 1회 정리

**Files:**
- Modify: `flutter_app/lib/data/cloud/sync_meta.dart`, `flutter_app/lib/data/cloud/sync_service.dart`, `flutter_app/lib/data/cloud/sync_controller.dart`
- Test: `flutter_app/test/cloud/sync_cleanup_test.dart`(신규 — 먼저 `ls flutter_app/test/cloud/`로 확인), `flutter_app/test/cloud/sync_controller_test.dart`(로드 횟수)

**Interfaces:**
- Produces: `bool SyncMeta.checksPurged`, `_purgeChecksOnce(uid)`. `reconcileAll`에서 `_reconcileLww(checks)` 호출이 사라진다. watch 대상에서 `checks` 제거(로드 6→5회).

- [ ] **Step 1: 실패 테스트 작성**

`flutter_app/test/cloud/sync_cleanup_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/cloud/cloud_store.dart';
import 'package:aws_docs/data/cloud/sync_meta.dart';
import 'package:aws_docs/data/cloud/sync_service.dart';
import 'package:aws_docs/data/local_kv.dart';
import 'package:aws_docs/data/plan_check_store.dart';

void main() {
  group('레거시 checks 정리', () {
    test('클라우드 checks 문서를 한 번 지우고, 로컬 체크는 건드리지 않는다', () async {
      final local = MemoryBackend();
      final cloud = FakeCloudStore();
      PlanCheckStore(backend: local).set('CLF-C02', 'x', true);
      await cloud.setDoc('u1', 'checks', 'CLF-C02', {'x': true});

      await SyncService(local: local, cloud: cloud, nowMs: () => 5000)
          .reconcileAll('u1');

      expect(await cloud.loadCollection('u1', 'checks'), isEmpty);
      expect(PlanCheckStore(backend: local).overrides('CLF-C02'), {'x': true});
      expect(SyncMeta(local).checksPurged, isTrue);
    });

    test('정리가 끝나면 다시 로드하지 않는다', () async {
      final local = MemoryBackend();
      final cloud = _CountingCloud(FakeCloudStore());
      final svc = SyncService(local: local, cloud: cloud, nowMs: () => 5000);

      await svc.reconcileAll('u1');
      final after = cloud.checksLoads;
      await svc.reconcileAll('u1');

      expect(cloud.checksLoads, after); // 2회차엔 checks를 보지 않는다
    });

    test('로컬 체크는 동기로 올라가지 않는다', () async {
      final local = MemoryBackend();
      final cloud = FakeCloudStore();
      PlanCheckStore(backend: local).set('CLF-C02', 'x', true);

      await SyncService(local: local, cloud: cloud, nowMs: () => 5000)
          .reconcileAll('u1');

      expect(await cloud.loadCollection('u1', 'checks'), isEmpty);
    });
  });
}

/// checks 컬렉션 로드 횟수만 센다.
class _CountingCloud implements CloudStore {
  _CountingCloud(this._inner);
  final CloudStore _inner;
  int checksLoads = 0;

  @override
  Future<Map<String, Map<String, dynamic>>> loadCollection(
      String uid, String collection) {
    if (collection == 'checks') checksLoads++;
    return _inner.loadCollection(uid, collection);
  }

  @override
  Future<void> setDoc(String uid, String c, String d, Map<String, dynamic> v) =>
      _inner.setDoc(uid, c, d, v);

  @override
  Future<void> deleteDoc(String uid, String c, String d) =>
      _inner.deleteDoc(uid, c, d);

  @override
  Stream<Map<String, Map<String, dynamic>>> watchCollection(
          String uid, String c) =>
      _inner.watchCollection(uid, c);
}
```

> 시그니처는 `lib/data/cloud/cloud_store.dart`의 `CloudStore`(setDoc·deleteDoc·loadCollection·watchCollection 4개, 2026-09-23 실측)와 맞춰 둔 것이다. 인터페이스가 바뀌었다면 컴파일 에러가 알려준다.

`test/cloud/sync_controller_test.dart:133`의 기대값을 5로 되돌리고 주석을 갱신한다:

```dart
    // reconcile 1회 = loadCollection 5회(meta·attempts·viewed·plans·progress).
    // 레거시 checks는 1회 정리 후 로드하지 않는다. 이중 호출이면 10.
    expect(spy.loads, 5);
```

> 이 테스트는 빈 클라우드라 checks 정리가 1회차에 끝난다. 1회차 로드가 6이면 `checksPurged`가 아직 false인 것이므로, 기대값이 아니라 구현을 의심할 것.

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/cloud/sync_cleanup_test.dart`
Expected: `checksPurged` 미정의로 컴파일 실패.

- [ ] **Step 3: 구현**

`sync_meta.dart`의 `deletedPlans` 아래에 추가:

```dart
  /// 레거시 `checks` 컬렉션 정리 완료 여부(1회성).
  bool get checksPurged => _read()['checksPurged'] == true;

  set checksPurged(bool v) {
    final m = _read();
    m['checksPurged'] = v;
    _write(m);
  }
```

`sync_service.dart`의 `reconcileAll`에서 checks 줄을 교체한다:

```dart
    await _reconcileProgress(uid, marks);
    await _purgeChecksOnce(uid);
  }

  /// 수동 체크 오버라이드(`checks`)는 앱에서 읽는 화면이 없어 동기 대상에서 뺀다.
  /// 이미 올라간 클라우드 사본만 한 번 지운다(로컬 값은 그대로 둔다 — 초기화가 지운다).
  Future<void> _purgeChecksOnce(String uid) async {
    final meta = SyncMeta(_local);
    if (meta.checksPurged) return;
    final cloud = await _cloud.loadCollection(uid, 'checks');
    await _deleteUpTo(uid, 'checks', cloud.keys.toList());
    // 상한에 걸려 남은 게 있으면 다음 회차에 마저 지운다.
    if (cloud.length <= maxDeletesPerRound) meta.checksPurged = true;
  }
```

`sync_controller.dart`의 watch 목록에서 `'checks'`를 뺀다.

- [ ] **Step 4: 통과 확인(커밋 전 Task 3까지)**

Run: `flutter test`
Expected: 전부 PASS.

**여기서 `flutter analyze`는 아직 0건이 아니다** — `_reconcileLww`가 미사용이 되어 `unused_element`가 뜬다. 이건 정상이며 Task 3이 그 코드를 지워야 해소된다. 따라서 **Task 2는 단독 커밋하지 않고, 곧바로 Task 3을 끝낸 뒤 두 Task를 한 커밋으로 남긴다**(각 커밋이 녹색 게이트를 지키도록).

- [ ] **Step 5: 커밋은 Task 3 Step 5에서 함께 한다**

---

### Task 3: 레거시 LWW 경로와 옛 사이드카 제거

**Files:**
- Modify: `flutter_app/lib/data/cloud/sync_service.dart`, `flutter_app/lib/data/cloud/sync_merge.dart`
- Delete: `flutter_app/test/cloud/sync_merge_lww_test.dart`
- Test: `flutter_app/test/cloud/sync_cleanup_test.dart`(추가)

**Interfaces:**
- Removes: `mergeLww`, `_reconcileLww`, `_meta`, `_writeMeta`, `_readJsonMap`, `_kMeta`, `_kChecks`.
- Produces: 옛 사이드카 `awsdocs.sync.v1`를 1회 비운다(파생 부기라 복구 불필요).

- [ ] **Step 1: 실패 테스트 작성**

`test/cloud/sync_cleanup_test.dart`의 `레거시 checks 정리` group 뒤에 추가:

```dart
  test('옛 사이드카(awsdocs.sync.v1)를 비운다', () async {
    final local = MemoryBackend()
      ..write('awsdocs.sync.v1', '{"plans":{"CLF-C02":100}}');

    await SyncService(local: local, cloud: FakeCloudStore(), nowMs: () => 5000)
        .reconcileAll('u1');

    expect((local.read('awsdocs.sync.v1') ?? '').isEmpty, isTrue);
  });
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/cloud/sync_cleanup_test.dart`
Expected: FAIL — 사이드카가 그대로 남는다.

- [ ] **Step 3: 구현**

`sync_service.dart`:
- `_reconcileLww` 메서드 전체와 `_meta`·`_writeMeta`·`_readJsonMap`, 상수 `_kMeta`·`_kChecks`를 지운다.
- `_purgeChecksOnce`의 **맨 앞**(`if (meta.checksPurged) return;`보다 위)에 사이드카 정리를 넣는다. `checksPurged`가 이미 true인 기기에서도 반드시 지나가야 하므로 조건 안에 두지 않는다:

```dart
    // 레거시 LWW가 쓰던 사이드카. 이제 읽는 곳이 없다(파생 부기라 복구 불필요).
    if ((_local.read('awsdocs.sync.v1') ?? '').isNotEmpty) {
      _local.write('awsdocs.sync.v1', '');
    }
```

`sync_merge.dart`에서 `mergeLww` 함수를 지운다.

테스트 파일을 지운다: `git rm flutter_app/test/cloud/sync_merge_lww_test.dart`

`sync_service_test.dart`에 남은 checks LWW 테스트 2건(`손상 사이드카 stamp가 reconcile를 중단시키지 않음`, `checks LWW — 사이드카 없던 로컬은 now로 스탬프 후 push`)을 지운다 — 검증 대상 경로가 사라졌다. 남은 `dart:convert`·`jsonEncode` 사용처가 없으면 import도 정리한다(analyze가 알려준다).

- [ ] **Step 4: 통과 확인**

Run: `flutter test && flutter analyze`
Expected: 전부 PASS · 0건

- [ ] **Step 5: 커밋**

```bash
git branch --show-current
git add -A flutter_app/lib/data/cloud/ flutter_app/test/cloud/
git commit -m "refactor(sync): checks를 동기에서 빼고 레거시 LWW 경로·옛 사이드카 제거

클라우드 checks 사본은 1회 정리한다(로컬 체크는 초기화가 지운다).
수동 체크 오버라이드는 읽는 화면이 없어 동기할 이유가 없다.

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
```

---

### Task 4: 일정 삭제 표식 정리

**Files:**
- Modify: `flutter_app/lib/data/cloud/sync_meta.dart`, `flutter_app/lib/data/cloud/sync_service.dart`
- Test: `flutter_app/test/cloud/sync_meta_test.dart`(추가), `flutter_app/test/cloud/sync_cleanup_test.dart`(추가)

**Interfaces:**
- Produces: `Map<String, int> prunedPlanMarks(Map<String, int> plans, Map<String, int> resetAt)` — 초기화 표식이 이미 덮는 일정 표식을 버린다. `_reconcileDeletions`가 쓰기 전에 적용한다.

**근거:** 일정 표식이 그 자격증의 유효 초기화 시각보다 오래됐으면, 초기화 표식이 이미 그 일정을 지운다(더 이른 것은 전부 버려진다). 그 표식은 중복이라 버려도 부활하지 않는다. `planId`는 `{certCode}:{createdIso}:{seq}`라 접두사에서 자격증을 얻는다.

- [ ] **Step 1: 실패 테스트 작성**

`test/cloud/sync_meta_test.dart`의 마지막 `}` 앞에 추가:

```dart
  group('prunedPlanMarks', () {
    test('초기화 표식이 덮는 일정 표식은 버린다', () {
      final out = prunedPlanMarks(
        {'CLF-C02:2026-09-01:0': 1000, 'CLF-C02:2026-09-02:0': 4000},
        {'CLF-C02': 3000},
      );
      expect(out.keys, ['CLF-C02:2026-09-02:0']);
    });

    test('전체 초기화(*)도 반영한다', () {
      expect(
        prunedPlanMarks({'SAA-C03:2026-09-01:0': 1000}, {'*': 2000}),
        isEmpty,
      );
    });

    test('표식이 없으면 그대로 둔다', () {
      final m = {'CLF-C02:2026-09-01:0': 1000};
      expect(prunedPlanMarks(m, const {}), m);
    });
  });
```

`test/cloud/sync_cleanup_test.dart`에 추가:

```dart
  test('초기화 뒤에는 그 자격증의 일정 표식이 사라진다', () async {
    final local = MemoryBackend();
    SyncMeta(local)
      ..deletedPlans = {'CLF-C02:2026-09-01:0': 1000}
      ..markReset('CLF-C02', 3000);

    await SyncService(local: local, cloud: FakeCloudStore(), nowMs: () => 5000)
        .reconcileAll('u1');

    expect(SyncMeta(local).deletedPlans, isEmpty);
  });
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/cloud/sync_meta_test.dart`
Expected: 컴파일 실패 — `prunedPlanMarks` 없음.

- [ ] **Step 3: 구현**

`sync_meta.dart` 파일 끝(클래스 밖)에 추가:

```dart
/// 초기화 표식이 이미 덮는 일정 표식을 버린다 — 표식이 무한히 쌓이지 않게.
/// planId는 `{certCode}:{createdIso}:{seq}`라 접두사에서 자격증을 얻는다.
Map<String, int> prunedPlanMarks(
  Map<String, int> plans,
  Map<String, int> resetAt,
) =>
    {
      for (final e in plans.entries)
        if (e.value > mergedEffectiveResetAt(resetAt, e.key.split(':').first))
          e.key: e.value,
    };
```

`sync_service.dart`의 `_reconcileDeletions`에서 `mergedPlans`를 만든 직후에 끼운다:

```dart
    final mergedPlans = prunedPlanMarks(
        mergeResetMarks(
            mergeResetMarks(meta.deletedPlans, cloudPlans), newPlanMarks),
        mergedReset);
```

- [ ] **Step 4: 통과 확인**

Run: `flutter test && flutter analyze`
Expected: 전부 PASS · 0건

- [ ] **Step 5: 커밋**

```bash
git branch --show-current
git add flutter_app/lib/data/cloud/ flutter_app/test/cloud/
git commit -m "feat(sync): 초기화 표식이 덮는 일정 삭제 표식을 정리

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
```

---

### Task 5: 비로그인 초기화 안내

**Files:**
- Modify: `flutter_app/lib/data/cloud/sync_meta.dart`, `flutter_app/lib/data/cloud/sync_service.dart`, `flutter_app/lib/content/reset_dialog.dart`
- Test: `flutter_app/test/reset_sync_notice_test.dart`(추가)

**Interfaces:**
- Produces: `int SyncMeta.lastSyncedAtMs`(화해 완료 시각, 0이면 한 번도 동기한 적 없음). `confirmReset(..., {bool? signedIn, bool? syncedBefore})` — 주입 없으면 전역에서 읽는다.

**스펙과의 차이(의도):** 스펙 §6.1은 "과거 동기 흔적 = `base`가 비어 있지 않음"이라고 적었지만, `base`는 일정·진행에만 있다. 일정을 만든 적 없는 사용자는 응시를 동기했어도 `base`가 비어 거짓 음성이 된다. 그래서 화해 완료 시각을 직접 기록해 판정한다.

- [ ] **Step 1: 실패 테스트 작성**

`test/reset_sync_notice_test.dart`의 마지막 `}` 앞에 추가(이 파일의 기존 group은 그대로 둔다):

```dart
  group('비로그인 + 과거 동기 흔적이면 확인창이 그 사실을 알린다', () {
    Future<void> open(WidgetTester tester,
        {required bool signedIn, required bool syncedBefore}) async {
      await tester.pumpWidget(_page(Builder(
        builder: (ctx) => TextButton(
          onPressed: () => confirmReset(ctx,
              title: '초기화',
              message: '모든 기록을 지웁니다.',
              signedIn: signedIn,
              syncedBefore: syncedBefore),
          child: const Text('열기'),
        ),
      )));
      await tester.tap(find.text('열기'));
      await tester.pumpAndSettle();
    }

    testWidgets('비로그인 + 동기 흔적 → 안내', (tester) async {
      await open(tester, signedIn: false, syncedBefore: true);
      expect(find.textContaining('다음 로그인'), findsOneWidget);
      expect(find.textContaining('되돌릴 수 없'), findsOneWidget);
    });

    testWidgets('로그인 상태면 안내하지 않는다', (tester) async {
      await open(tester, signedIn: true, syncedBefore: true);
      expect(find.textContaining('다음 로그인'), findsNothing);
    });

    testWidgets('동기한 적 없으면 안내하지 않는다', (tester) async {
      await open(tester, signedIn: false, syncedBefore: false);
      expect(find.textContaining('다음 로그인'), findsNothing);
    });
  });
```

`import 'package:aws_docs/content/reset_dialog.dart';`를 파일 상단에 추가한다.

`test/cloud/sync_cleanup_test.dart`에 추가:

```dart
  test('화해를 마치면 마지막 동기 시각을 남긴다', () async {
    final local = MemoryBackend();
    await SyncService(local: local, cloud: FakeCloudStore(), nowMs: () => 7777)
        .reconcileAll('u1');
    expect(SyncMeta(local).lastSyncedAtMs, 7777);
  });
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/reset_sync_notice_test.dart test/cloud/sync_cleanup_test.dart`
Expected: 컴파일 실패 — `signedIn`/`syncedBefore` 인자와 `lastSyncedAtMs` 없음.

- [ ] **Step 3: 구현**

`sync_meta.dart`에 추가:

```dart
  /// 마지막으로 화해를 끝낸 시각(0이면 이 기기에서 한 번도 동기하지 않았다).
  int get lastSyncedAtMs => (_read()['lastSyncedAtMs'] as num?)?.toInt() ?? 0;

  set lastSyncedAtMs(int v) {
    final m = _read();
    m['lastSyncedAtMs'] = v;
    _write(m);
  }
```

`sync_service.dart`의 `reconcileAll` 마지막 줄에 추가:

```dart
    SyncMeta(_local).lastSyncedAtMs = _now();
```

`reset_dialog.dart`:

```dart
import '../data/cloud/sync_meta.dart';
import '../data/local_kv.dart';
import '../main.dart' show syncController;
```

```dart
Future<bool> confirmReset(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = '초기화',
  bool? signedIn,
  bool? syncedBefore,
}) async {
  // 비로그인 상태에서 지우면 표식만 로컬에 남는다. 예전에 동기한 적이 있으면
  // 클라우드 사본은 다음 로그인 때 그 표식으로 정리된다 — 그 사실을 알린다.
  final isSignedIn = signedIn ?? (syncController.value?.user != null);
  final hasTrace =
      syncedBefore ?? (SyncMeta(defaultBackend()).lastSyncedAtMs > 0);
  final notice = (!isSignedIn && hasTrace)
      ? '\n\n로그인하지 않은 상태입니다. 예전에 동기된 클라우드 기록은 다음 로그인 때 함께 정리됩니다.'
      : '';
```

본문을 `'$message\n\n이 작업은 되돌릴 수 없습니다.$notice'`로 바꾼다.

- [ ] **Step 4: 통과 확인**

Run: `flutter test && flutter analyze`
Expected: 전부 PASS · 0건. 기존 `reset_sync_notice_test`의 4건(“되돌릴 수 없” 존재·“클라우드 백업” 부재)은 그대로 통과해야 한다 — 문구가 달라졌다면 기대가 아니라 구현을 고칠 것.

- [ ] **Step 5: 커밋**

```bash
git branch --show-current
git add flutter_app/lib/ flutter_app/test/
git commit -m "feat(sync): 비로그인 초기화 확인창에 과거 동기 정리 시점을 알림

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
```

---

### Task 6: 보안 규칙을 레포가 관리

**Files:**
- Create: `firestore.rules`, `firebase.json`, `tool/firestore_rules_test/{package.json,rules.test.mjs}`, `.github/workflows/firestore-rules.yml`
- Modify: `CLAUDE.md`

**Interfaces:**
- Produces: 규칙 파일과 에뮬레이터 테스트 1건(타인 uid 읽기 거부). **CI 필수 체크(`test`)는 건드리지 않는다** — 규칙 파일이 바뀔 때만 도는 별도 워크플로다.

- [ ] **Step 1: 규칙 파일**

`firestore.rules` (스펙 §8 그대로):

```
rules_version = '2';
service cloud.firestore {
  match /databases/{db}/documents {
    match /users/{uid}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
  }
}
```

`firebase.json`:

```json
{
  "firestore": {
    "rules": "firestore.rules"
  },
  "emulators": {
    "firestore": { "port": 8080 },
    "ui": { "enabled": false }
  }
}
```

- [ ] **Step 2: 실패 테스트 작성**

`tool/firestore_rules_test/package.json`:

```json
{
  "name": "awc-docs-firestore-rules-test",
  "private": true,
  "type": "module",
  "scripts": {
    "test": "firebase emulators:exec --only firestore --project awc-docs-cf67d \"node --test rules.test.mjs\""
  },
  "devDependencies": {
    "@firebase/rules-unit-testing": "^3.0.4",
    "firebase": "^10.12.0",
    "firebase-tools": "^13.11.0"
  }
}
```

`tool/firestore_rules_test/rules.test.mjs`:

```js
// users/{uid} 아래는 그 uid 본인만 읽고 쓸 수 있어야 한다(스펙 §8).
import { test, after, before } from 'node:test';
import { readFileSync } from 'node:fs';
import {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} from '@firebase/rules-unit-testing';
import { doc, getDoc, setDoc } from 'firebase/firestore';

let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'awc-docs-cf67d',
    firestore: { rules: readFileSync(new URL('../../firestore.rules', import.meta.url), 'utf8') },
  });
});

after(() => env?.cleanup());

test('본인 문서는 읽고 쓸 수 있다', async () => {
  const db = env.authenticatedContext('u1').firestore();
  await assertSucceeds(setDoc(doc(db, 'users/u1/attempts/a1'), { correct: 1 }));
  await assertSucceeds(getDoc(doc(db, 'users/u1/attempts/a1')));
});

test('타인 uid 문서는 읽을 수 없다', async () => {
  const db = env.authenticatedContext('u2').firestore();
  await assertFails(getDoc(doc(db, 'users/u1/attempts/a1')));
});

test('비로그인은 읽을 수 없다', async () => {
  const db = env.unauthenticatedContext().firestore();
  await assertFails(getDoc(doc(db, 'users/u1/attempts/a1')));
});
```

- [ ] **Step 3: 로컬 실행으로 통과 확인**

```bash
cd tool/firestore_rules_test && npm install && npm test
```

Expected: 3건 통과. `package-lock.json`이 생기면 함께 커밋한다.
**막히면 여기서 멈추고 보고한다** — 에뮬레이터는 Java가 필요하다(`java -version`). 없으면 설치는 사용자 몫이므로, 규칙 파일만 커밋하고 이 Task를 미완으로 보고할 것.

- [ ] **Step 4: 워크플로**

`.github/workflows/firestore-rules.yml`:

```yaml
name: Firestore rules

on:
  pull_request:
    paths:
      - 'firestore.rules'
      - 'tool/firestore_rules_test/**'
      - '.github/workflows/firestore-rules.yml'

jobs:
  rules:
    runs-on: ubuntu-latest
    timeout-minutes: 15
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: npm
          cache-dependency-path: tool/firestore_rules_test/package-lock.json
      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '17'
      - run: npm ci
        working-directory: tool/firestore_rules_test
      - run: npm test
        working-directory: tool/firestore_rules_test
```

- [ ] **Step 5: 문서**

`CLAUDE.md`의 "빌드·테스트" 절에 한 줄 추가:

```markdown
- **보안 규칙 테스트(선택):** `cd tool/firestore_rules_test && npm ci && npm test` — Firestore 에뮬레이터(Java 필요)로 `firestore.rules`를 검증한다. 규칙 파일이 바뀌는 PR에서는 `firestore-rules` 워크플로가 자동으로 돈다. **콘솔에 배포된 실제 규칙과 맞추는 것은 사용자 작업이다.**
```

- [ ] **Step 6: 커밋**

```bash
git branch --show-current
git add firestore.rules firebase.json tool/firestore_rules_test .github/workflows/firestore-rules.yml CLAUDE.md
git commit -m "chore(security): firestore.rules를 레포로 관리 + 에뮬레이터 규칙 테스트

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
git push -u origin feat/sync-v2-pr3-cleanup
```

PR 본문에는 스펙 경로, 정리 내역, 테스트 수, **콘솔 규칙 배포는 사용자 작업**임을 적는다.

---

## 완료 기준

- `flutter test` 전부 통과, `flutter analyze` 0건, CI `test` 녹색
- 깨진 응시 레코드가 있어도 동기가 끝나고 원문이 `.corrupt`에 남는다
- 클라우드 `checks` 문서가 사라지고 다시 만들어지지 않는다(로컬 체크는 보존)
- `awsdocs.sync.v1`·`mergeLww`·`_reconcileLww`가 코드베이스에 없다
- 초기화 뒤 그 자격증의 일정 삭제 표식이 남지 않는다
- 비로그인 + 과거 동기 흔적일 때만 확인창이 정리 시점을 알린다
- `firestore.rules`가 레포에 있고 규칙 테스트 3건이 통과한다

## 결정이 필요한 것

- **규칙 테스트를 필수 체크로 올릴지.** 지금 플랜은 규칙 파일이 바뀔 때만 도는 별도 워크플로다(일반 PR 속도·비용에 영향 없음). 필수로 만들려면 브랜치 보호의 required check에 `rules`를 추가해야 하고, 그건 사용자 작업이다.
- **`PlanCheckStore` 자체를 지울지.** 읽는 화면이 없어 죽은 코드지만, 제거하면 사용자 로컬에 남은 값이 영영 무의미해진다(이미 그렇다). 이 PR은 동기에서만 뺀다 — 스토어 제거는 별도 정리 PR 후보.

## 남은 것(이 PR 밖)

- 콘솔에 배포된 Firestore 규칙을 `firestore.rules`와 맞추기(사용자)
- 리뷰 후속: M-6 대비 토큰(DESIGN.md), UX-1·2·4 시험 러너 모바일, QuizView/오답노트 저장 실패 try/finally
