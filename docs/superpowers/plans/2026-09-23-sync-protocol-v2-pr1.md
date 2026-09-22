# 동기 프로토콜 v2 — PR1(삭제 표식 기반) 구현 플랜

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 초기화가 모든 기기와 클라우드에서 실제로 데이터를 지우게 만든다(응시 기록·열람 기록 범위).

**Architecture:** 삭제를 "시각 표식"으로 표현한다. 자격증별(또는 전체) 삭제 시각을 로컬 사이드카와 클라우드 `meta/deletions` 문서에 남기고, 그 시각보다 오래된 레코드를 양쪽에서 버린다. 오래된 사본을 가진 기기도 같은 규칙으로 걸러지므로 부활하지 않는다. 새 레코드는 UTC epoch ms 생성 시각을 함께 기록해 기기 간 시간대 문제를 없앤다.

**Tech Stack:** Flutter Web(Dart), `flutter_test`, 로컬 `KvBackend`(localStorage), `CloudStore`(Firestore / 테스트는 `FakeCloudStore`).

**Spec:** `docs/superpowers/specs/2026-09-23-sync-protocol-v2-design.md`

## Global Constraints

- 모든 명령은 `flutter_app/` 디렉터리에서 실행한다.
- Flutter 3.47.2 고정(워크플로와 로컬 동일).
- 모든 시각은 **UTC epoch ms 정수**다: `DateTime.now().toUtc().millisecondsSinceEpoch`.
- 각 Task 끝에서 `flutter analyze` 0건, `flutter test` 전부 통과를 눈으로 확인한다.
- 테스트를 먼저 쓰고 **실패를 확인한 뒤** 구현한다(CLAUDE.md 절대 조건 2).
- 커밋 직전 `git branch --show-current`로 브랜치를 확인한다(CLAUDE.md §5, 공유 워킹트리).
- 브랜치는 `develop`에서 분기한 `feat/sync-v2-pr1-deletion-marks`, PR 대상은 `develop`.
- 커밋 메시지 마지막 줄: `Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>`
- 로컬 키 이름은 스펙 §3.2 그대로: 사이드카는 `awsdocs.sync.v2`, 열람은 기존 키 `awsdocs.viewed.v1` 유지.
- 주석·UI 문구는 한국어, 기존 코드의 서술 톤을 따른다.

---

## File Structure

**신규**
- `lib/data/cloud/sync_meta.dart` — 사이드카 v2 접근자(`SyncMeta`)와 표식 계산 순수 함수(`mergedEffectiveResetAt`, `mergeResetMarks`).
- `test/cloud/sync_meta_test.dart`, `test/cloud/cloud_store_test.dart`, `test/cloud/sync_merge_reset_test.dart`, `test/viewed_docs_store_test.dart`.

**수정**
- `lib/models/attempt_record.dart` — `createdAtMs` 필드·폴백·복사 메서드.
- `lib/data/history_store.dart` — 저장 시 `createdAtMs` 스탬프(모든 응시가 지나가는 단일 관문).
- `lib/data/viewed_docs_store.dart` — 값 형태를 `{taskId: ms}`로, 레거시 배열 읽기 폴백.
- `lib/data/cloud/cloud_store.dart`·`firestore_cloud_store.dart` — `deleteDoc`.
- `lib/data/cloud/sync_merge.dart` — 표식 필터와 삭제 목록.
- `lib/data/cloud/sync_service.dart` — `meta/deletions` 화해, 표식 적용, 정리 삭제(회차당 50건).
- `lib/data/cloud/sync_controller.dart` — watch 대상에 `meta` 추가.
- `lib/data/study_reset.dart` — 초기화가 표식을 남김.
- `lib/content/reset_dialog.dart` — 확인창 문구 복귀.
- 테스트: `test/cloud/sync_merge_viewed_test.dart`, `test/cloud/sync_service_test.dart`, `test/cloud/sync_controller_test.dart`, `test/study_reset_test.dart`, `test/reset_sync_notice_test.dart`, `test/history_store_test.dart`.

**스펙과의 차이(의도)**: 스펙은 확인창 문구 복귀를 PR3에 뒀지만, PR1이 끝나면 삭제가 실제로 전파되므로 그 시점에 문구를 되돌리지 않으면 **거짓 안내**가 된다. 그래서 Task 8로 앞당긴다.

---

### Task 1: 사이드카 v2와 표식 계산

**Files:**
- Create: `flutter_app/lib/data/cloud/sync_meta.dart`
- Test: `flutter_app/test/cloud/sync_meta_test.dart`

**Interfaces:**
- Consumes: `KvBackend`(`lib/data/local_kv.dart`).
- Produces: `class SyncMeta { SyncMeta(KvBackend); static const String key, legacyKey, allCerts; Map<String,int> get resetAt; set resetAt(Map<String,int>); void markReset(String certOrAll, int ms); int effectiveResetAt(String certCode); }`, `int mergedEffectiveResetAt(Map<String,int>, String)`, `Map<String,int> mergeResetMarks(Map<String,int>, Map<String,int>)`.

- [ ] **Step 1: 실패 테스트 작성**

`flutter_app/test/cloud/sync_meta_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/cloud/sync_meta.dart';
import 'package:aws_docs/data/local_kv.dart';

void main() {
  test('markReset: 표식을 기록하고 늦은 시각을 유지한다', () {
    final b = MemoryBackend();
    SyncMeta(b).markReset('CLF-C02', 1000);
    SyncMeta(b).markReset('CLF-C02', 500); // 더 이른 시각은 무시
    expect(SyncMeta(b).resetAt, {'CLF-C02': 1000});
  });

  test('effectiveResetAt: 자격증 표식과 전체 표식 중 늦은 쪽', () {
    final b = MemoryBackend();
    SyncMeta(b)
      ..markReset('CLF-C02', 1000)
      ..markReset(SyncMeta.allCerts, 3000);
    expect(SyncMeta(b).effectiveResetAt('CLF-C02'), 3000);
    expect(SyncMeta(b).effectiveResetAt('SAA-C03'), 3000);
  });

  test('mergeResetMarks: 필드별 늦은 시각을 채택한다', () {
    expect(
      mergeResetMarks({'CLF-C02': 1000, 'SAA-C03': 5000}, {'CLF-C02': 2000}),
      {'CLF-C02': 2000, 'SAA-C03': 5000},
    );
  });

  test('손상된 값은 무시하고 나머지를 읽는다', () {
    final b = MemoryBackend()
      ..write('awsdocs.sync.v2', '{"resetAt":{"CLF-C02":"oops","SAA-C03":7}}');
    expect(SyncMeta(b).resetAt, {'SAA-C03': 7});
  });

  test('옛 사이드카(v1)는 건드리지 않는다 — 레거시 LWW 경로가 아직 쓴다', () {
    final b = MemoryBackend()..write('awsdocs.sync.v1', '{"plans":{}}');
    SyncMeta(b).markReset('CLF-C02', 1000);
    expect(b.read('awsdocs.sync.v1'), '{"plans":{}}');
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/cloud/sync_meta_test.dart`
Expected: 컴파일 실패 — `sync_meta.dart` 없음.

- [ ] **Step 3: 구현**

`flutter_app/lib/data/cloud/sync_meta.dart`:

```dart
import 'dart:convert';

import '../local_kv.dart';

/// 동기 사이드카(v2) — 로컬에만 있는 동기 부기. 지금은 삭제 표식을 담고,
/// PR2에서 마지막 동기 스냅샷(base)이 더해진다. 옛 v1 사이드카는 레거시 LWW
/// 경로가 아직 쓰므로 건드리지 않는다(PR3에서 그 경로와 함께 정리).
class SyncMeta {
  SyncMeta(this._b);
  final KvBackend _b;

  static const key = 'awsdocs.sync.v2';

  /// 전체 초기화(resetAll)를 가리키는 표식 키.
  static const allCerts = '*';

  Map<String, dynamic> _read() {
    final raw = _b.read(key);
    if (raw == null || raw.isEmpty) return {};
    try {
      final m = jsonDecode(raw);
      return m is Map<String, dynamic> ? m : {};
    } catch (_) {
      return {}; // 손상 사이드카는 빈 상태로(파생 데이터라 복구 불필요)
    }
  }

  void _write(Map<String, dynamic> m) {
    final next = jsonEncode(m);
    if (_b.read(key) != next) _b.write(key, next);
  }

  /// 자격증별 삭제 표식(UTC ms). `*`는 전체 초기화.
  Map<String, int> get resetAt {
    final m = _read()['resetAt'];
    if (m is! Map) return {};
    return {
      for (final e in m.entries)
        if (e.value is num) e.key.toString(): (e.value as num).toInt(),
    };
  }

  set resetAt(Map<String, int> v) {
    final m = _read();
    m['resetAt'] = v;
    _write(m);
  }

  /// 표식 기록. 같은 키는 늦은 시각을 남긴다.
  void markReset(String certOrAll, int ms) {
    final next = {...resetAt};
    if (ms > (next[certOrAll] ?? 0)) next[certOrAll] = ms;
    resetAt = next;
  }

  /// 이 자격증에 적용되는 유효 삭제 시각.
  int effectiveResetAt(String certCode) =>
      mergedEffectiveResetAt(resetAt, certCode);
}

/// 자격증 표식과 전체 표식 중 늦은 쪽.
int mergedEffectiveResetAt(Map<String, int> resetAt, String certCode) {
  final own = resetAt[certCode] ?? 0;
  final all = resetAt[SyncMeta.allCerts] ?? 0;
  return own > all ? own : all;
}

/// 두 표식 맵을 필드별 늦은 시각으로 병합한다(기기 간 동시 초기화 안전).
Map<String, int> mergeResetMarks(Map<String, int> a, Map<String, int> b) {
  final out = {...a};
  for (final e in b.entries) {
    if (e.value > (out[e.key] ?? 0)) out[e.key] = e.value;
  }
  return out;
}
```

- [ ] **Step 4: 통과 확인**

Run: `flutter test test/cloud/sync_meta_test.dart`
Expected: PASS (5건)

- [ ] **Step 5: 커밋**

```bash
git branch --show-current
git add flutter_app/lib/data/cloud/sync_meta.dart flutter_app/test/cloud/sync_meta_test.dart
git commit -m "feat(sync): 삭제 표식 사이드카(v2)와 표식 계산 순수 함수

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
```

---

### Task 2: 응시 기록의 UTC 생성 시각

**Files:**
- Modify: `flutter_app/lib/models/attempt_record.dart`
- Modify: `flutter_app/lib/data/history_store.dart`
- Test: `flutter_app/test/history_store_test.dart`

**Interfaces:**
- Produces: `AttemptRecord.createdAtMs`(`int?`), `int AttemptRecord.createdAtMsEffective`, `AttemptRecord AttemptRecord.withCreatedAtMs(int ms)`, `HistoryStore({KvBackend? backend, int Function()? nowMs})`.

- [ ] **Step 1: 실패 테스트 작성**

`flutter_app/test/history_store_test.dart`의 `void main() {` 바로 아래에 추가:

```dart
  group('createdAtMs — UTC 생성 시각', () {
    test('JSON 왕복 + 없으면 date에서 폴백', () {
      const r = AttemptRecord(
        certId: 'CLF-C02', examId: 'exam:clf-t1-1', mode: 'exam',
        date: '2026-09-22T10:00:00.000', correct: 1, total: 1,
        wrongQuestionIds: [], flaggedQuestionIds: [], durationSpentSec: 10,
        createdAtMs: 1758535200000,
      );
      expect(AttemptRecord.fromJson(r.toJson()).createdAtMs, 1758535200000);

      const legacy = AttemptRecord(
        certId: 'CLF-C02', examId: 'exam:clf-t1-1', mode: 'exam',
        date: '2026-09-22T10:00:00.000', correct: 1, total: 1,
        wrongQuestionIds: [], flaggedQuestionIds: [], durationSpentSec: 10,
      );
      expect(legacy.toJson().containsKey('createdAtMs'), isFalse);
      expect(legacy.createdAtMsEffective,
          DateTime.parse('2026-09-22T10:00:00.000').millisecondsSinceEpoch);
    });

    test('HistoryStore.add: 값이 없으면 저장 시각을 찍는다', () {
      final b = MemoryBackend();
      HistoryStore(backend: b, nowMs: () => 4242).add(const AttemptRecord(
        certId: 'CLF-C02', examId: 'exam:clf-t1-1', mode: 'exam',
        date: '2026-09-22T10:00:00.000', correct: 1, total: 1,
        wrongQuestionIds: [], flaggedQuestionIds: [], durationSpentSec: 10,
      ));
      expect(HistoryStore(backend: b).all().single.createdAtMs, 4242);
    });

    test('HistoryStore.add: 이미 있는 값은 덮지 않는다', () {
      final b = MemoryBackend();
      HistoryStore(backend: b, nowMs: () => 4242).add(const AttemptRecord(
        certId: 'CLF-C02', examId: 'exam:clf-t1-1', mode: 'exam',
        date: '2026-09-22T10:00:00.000', correct: 1, total: 1,
        wrongQuestionIds: [], flaggedQuestionIds: [], durationSpentSec: 10,
        createdAtMs: 111,
      ));
      expect(HistoryStore(backend: b).all().single.createdAtMs, 111);
    });
  });
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/history_store_test.dart`
Expected: 컴파일 실패 — `createdAtMs`·`nowMs` 없음.

- [ ] **Step 3: 구현 — 모델**

`flutter_app/lib/models/attempt_record.dart`의 생성자에서 `required this.durationSpentSec,` **다음 줄**에 추가:

```dart
    this.createdAtMs,
```

`final int durationSpentSec;` 아래에 필드와 파생 값을 추가:

```dart
  /// 생성 시각(UTC epoch ms). 레거시 레코드는 없으며 [createdAtMsEffective]가 date로 폴백한다.
  final int? createdAtMs;

  /// 삭제 표식 비교에 쓰는 유효 생성 시각. 레거시는 시간대 없는 date를 로컬로 해석한다.
  int get createdAtMsEffective =>
      createdAtMs ?? (DateTime.tryParse(date)?.millisecondsSinceEpoch ?? 0);

  AttemptRecord withCreatedAtMs(int ms) => AttemptRecord(
        certId: certId,
        examId: examId,
        mode: mode,
        date: date,
        correct: correct,
        total: total,
        wrongQuestionIds: wrongQuestionIds,
        flaggedQuestionIds: flaggedQuestionIds,
        presentedQuestionIds: presentedQuestionIds,
        wrongSkills: wrongSkills,
        durationSpentSec: durationSpentSec,
        createdAtMs: ms,
      );
```

`toJson()`의 `'durationSpentSec': durationSpentSec,` 다음 줄에 추가(값이 없으면 키를 넣지 않는다):

```dart
        if (createdAtMs != null) 'createdAtMs': createdAtMs,
```

`fromJson`의 `durationSpentSec: (j['durationSpentSec'] as num?)?.toInt() ?? 0,` 다음 줄에 추가:

```dart
        createdAtMs: (j['createdAtMs'] as num?)?.toInt(),
```

- [ ] **Step 4: 구현 — 저장 관문**

`flutter_app/lib/data/history_store.dart`의 생성자와 필드를 교체:

```dart
class HistoryStore {
  HistoryStore({KvBackend? backend, int Function()? nowMs})
      : _b = backend ?? defaultBackend(),
        _now = nowMs ?? (() => DateTime.now().toUtc().millisecondsSinceEpoch);

  final KvBackend _b;
  final int Function() _now;
```

`add`를 교체(모든 응시가 이 관문을 지나므로 여기서만 스탬프한다):

```dart
  void add(AttemptRecord r) {
    final stamped = r.createdAtMs == null ? r.withCreatedAtMs(_now()) : r;
    final list = _loadForRewrite()..add(stamped);
    _b.write(_key, jsonEncode(list.map((e) => e.toJson()).toList()));
  }
```

- [ ] **Step 5: 통과 확인**

Run: `flutter test test/history_store_test.dart && flutter test`
Expected: 전부 PASS

- [ ] **Step 6: 커밋**

```bash
git branch --show-current
git add flutter_app/lib/models/attempt_record.dart flutter_app/lib/data/history_store.dart flutter_app/test/history_store_test.dart
git commit -m "feat(history): 응시 기록에 UTC 생성 시각(createdAtMs) 기록

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
```

---

### Task 3: 열람 기록의 항목별 시각

**Files:**
- Modify: `flutter_app/lib/data/viewed_docs_store.dart`
- Create: `flutter_app/test/viewed_docs_store_test.dart`

**Interfaces:**
- Produces: `ViewedDocsStore({KvBackend? backend, int Function()? nowMs})`, `Map<String, Map<String,int>> readAll()`, `void writeAll(Map<String, Map<String,int>>)`. 기존 `viewed`·`markViewed`·`clearCert`·`clearAll` 시그니처는 그대로(소비자 무변경).

- [ ] **Step 1: 실패 테스트 작성**

`flutter_app/test/viewed_docs_store_test.dart`:

```dart
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/viewed_docs_store.dart';

void main() {
  test('markViewed: 항목마다 UTC 시각을 남긴다', () {
    final b = MemoryBackend();
    ViewedDocsStore(backend: b, nowMs: () => 777)
        .markViewed('CLF-C02', 'clf-t1-1');
    expect(ViewedDocsStore(backend: b).readAll(), {
      'CLF-C02': {'clf-t1-1': 777}
    });
    expect(ViewedDocsStore(backend: b).viewed('CLF-C02'), {'clf-t1-1'});
  });

  test('레거시 배열 형태는 시각 0으로 읽는다', () {
    final b = MemoryBackend()
      ..write('awsdocs.viewed.v1', jsonEncode({
        'CLF-C02': ['clf-t1-1', 'clf-t1-2']
      }));
    expect(ViewedDocsStore(backend: b).readAll(), {
      'CLF-C02': {'clf-t1-1': 0, 'clf-t1-2': 0}
    });
    expect(ViewedDocsStore(backend: b).viewed('CLF-C02'),
        {'clf-t1-1', 'clf-t1-2'});
  });

  test('이미 본 문서는 시각을 갱신하지 않는다', () {
    final b = MemoryBackend();
    ViewedDocsStore(backend: b, nowMs: () => 100)
        .markViewed('CLF-C02', 'clf-t1-1');
    ViewedDocsStore(backend: b, nowMs: () => 200)
        .markViewed('CLF-C02', 'clf-t1-1');
    expect(ViewedDocsStore(backend: b).readAll()['CLF-C02'], {'clf-t1-1': 100});
  });

  test('clearCert는 해당 자격증만 지운다', () {
    final b = MemoryBackend();
    ViewedDocsStore(backend: b, nowMs: () => 1)
      ..markViewed('CLF-C02', 'a')
      ..markViewed('SAA-C03', 'b');
    ViewedDocsStore(backend: b).clearCert('CLF-C02');
    expect(ViewedDocsStore(backend: b).viewed('CLF-C02'), isEmpty);
    expect(ViewedDocsStore(backend: b).viewed('SAA-C03'), {'b'});
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/viewed_docs_store_test.dart`
Expected: 컴파일 실패 — `nowMs`·`readAll` 없음.

- [ ] **Step 3: 구현**

`flutter_app/lib/data/viewed_docs_store.dart`의 클래스 본문 전체를 교체(상단 import·export는 그대로):

```dart
/// 열람한 학습문서 Task를 자격증별로 영속한다(방문 = 열람).
/// 값은 `{taskId: 열람시각(UTC ms)}`이며, 레거시 배열 형태도 읽는다(시각 0).
/// 멀티탭은 last-write-wins. 손상 데이터는 빈 결과.
class ViewedDocsStore {
  ViewedDocsStore({KvBackend? backend, int Function()? nowMs})
      : _b = backend ?? defaultBackend(),
        _now = nowMs ?? (() => DateTime.now().toUtc().millisecondsSinceEpoch);

  final KvBackend _b;
  final int Function() _now;
  static const _key = 'awsdocs.viewed.v1';

  /// 자격증 → {taskId: 열람시각}. 배열 형태(레거시)는 시각 0으로 해석한다.
  Map<String, Map<String, int>> readAll() {
    final raw = _b.read(_key);
    if (raw == null || raw.isEmpty) return {};
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      final out = <String, Map<String, int>>{};
      for (final e in m.entries) {
        final v = e.value;
        if (v is List) {
          out[e.key] = {for (final x in v) x.toString(): 0};
        } else if (v is Map) {
          out[e.key] = {
            for (final t in v.entries)
              if (t.value is num) t.key.toString(): (t.value as num).toInt(),
          };
        }
      }
      return out;
    } catch (_) {
      return {}; // 손상 데이터 무시
    }
  }

  void writeAll(Map<String, Map<String, int>> m) =>
      _b.write(_key, jsonEncode(m));

  /// 해당 자격증에서 열람한 Task ID 집합.
  Set<String> viewed(String certId) => readAll()[certId]?.keys.toSet() ?? {};

  /// 방문 기록(이미 있으면 시각을 갱신하지 않는다 — 첫 열람 시각 보존).
  void markViewed(String certId, String taskId) {
    final m = readAll();
    final cert = m[certId] ?? <String, int>{};
    if (cert.containsKey(taskId)) return;
    m[certId] = {...cert, taskId: _now()};
    writeAll(m);
  }

  /// 해당 자격증 열람 기록만 제거.
  void clearCert(String certId) {
    final m = readAll()..remove(certId);
    writeAll(m);
  }

  /// 모든 열람 기록 삭제.
  void clearAll() => _b.write(_key, '');
}
```

- [ ] **Step 4: 통과 확인**

Run: `flutter test test/viewed_docs_store_test.dart && flutter test`
Expected: 전부 PASS(소비자는 `viewed()`만 쓰므로 영향 없음)

- [ ] **Step 5: 커밋**

```bash
git branch --show-current
git add flutter_app/lib/data/viewed_docs_store.dart flutter_app/test/viewed_docs_store_test.dart
git commit -m "feat(viewed): 열람 기록에 항목별 UTC 시각 기록(레거시 배열 읽기 폴백)

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
```

---

### Task 4: 클라우드 문서 삭제 API

**Files:**
- Modify: `flutter_app/lib/data/cloud/cloud_store.dart`, `flutter_app/lib/data/cloud/firestore_cloud_store.dart`
- Modify(테스트 더블): `flutter_app/test/cloud/sync_service_test.dart`의 `_GatedCloud`, `flutter_app/test/cloud/sync_controller_test.dart`의 `_SpyCloud`
- Create: `flutter_app/test/cloud/cloud_store_test.dart`

**Interfaces:**
- Produces: `Future<void> CloudStore.deleteDoc(String uid, String collection, String docId)`.

- [ ] **Step 1: 실패 테스트 작성**

`flutter_app/test/cloud/cloud_store_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/cloud/cloud_store.dart';

void main() {
  test('FakeCloudStore.deleteDoc: 문서를 지우고 watch에 알린다', () async {
    final cloud = FakeCloudStore();
    await cloud.setDoc('u1', 'attempts', 'k1', {'a': 1});
    final seen = <int>[];
    final sub =
        cloud.watchCollection('u1', 'attempts').listen((m) => seen.add(m.length));

    await cloud.deleteDoc('u1', 'attempts', 'k1');
    await Future<void>.delayed(Duration.zero);

    expect(await cloud.loadCollection('u1', 'attempts'), isEmpty);
    expect(seen.last, 0);
    await sub.cancel();
  });

  test('없는 문서 삭제는 조용히 넘어간다', () async {
    final cloud = FakeCloudStore();
    await cloud.deleteDoc('u1', 'attempts', 'missing');
    expect(await cloud.loadCollection('u1', 'attempts'), isEmpty);
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/cloud/cloud_store_test.dart`
Expected: 컴파일 실패 — `deleteDoc` 없음.

- [ ] **Step 3: 구현**

`cloud_store.dart`의 인터페이스에 추가:

```dart
  Future<void> deleteDoc(String uid, String collection, String docId);
```

`FakeCloudStore`에 추가:

```dart
  @override
  Future<void> deleteDoc(String uid, String collection, String docId) async {
    _d[uid]?[collection]?.remove(docId);
    _emit(uid, collection);
  }
```

`firestore_cloud_store.dart`에 추가:

```dart
  @override
  Future<void> deleteDoc(String uid, String collection, String docId) =>
      _col(uid, collection).doc(docId).delete();
```

`test/cloud/sync_service_test.dart`의 `_GatedCloud`에 추가:

```dart
  @override
  Future<void> deleteDoc(String uid, String collection, String docId) =>
      inner.deleteDoc(uid, collection, docId);
```

`test/cloud/sync_controller_test.dart`의 `_SpyCloud`에 추가:

```dart
  @override
  Future<void> deleteDoc(String uid, String collection, String docId) =>
      _inner.deleteDoc(uid, collection, docId);
```

- [ ] **Step 4: 통과 확인**

Run: `flutter test test/cloud/`
Expected: PASS

- [ ] **Step 5: 커밋**

```bash
git branch --show-current
git add flutter_app/lib/data/cloud/cloud_store.dart flutter_app/lib/data/cloud/firestore_cloud_store.dart flutter_app/test/cloud/cloud_store_test.dart flutter_app/test/cloud/sync_service_test.dart flutter_app/test/cloud/sync_controller_test.dart
git commit -m "feat(sync): CloudStore.deleteDoc 추가(Fake·Firestore·테스트 더블)

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
```

---

### Task 5: 표식을 반영한 병합과 SyncService 적용

병합 함수의 형태가 바뀌면 `SyncService`가 곧바로 컴파일되지 않는다. 둘은 같이 가야 하므로 한 작업으로 묶는다.

**Files:**
- Modify: `flutter_app/lib/data/cloud/sync_merge.dart`, `flutter_app/lib/data/cloud/sync_service.dart`
- Modify(테스트): `flutter_app/test/cloud/sync_merge_viewed_test.dart`, `flutter_app/test/cloud/sync_service_test.dart`, `flutter_app/test/cloud/sync_controller_test.dart:113`
- Create: `flutter_app/test/cloud/sync_merge_reset_test.dart`

**Interfaces:**
- Consumes: `mergedEffectiveResetAt`·`mergeResetMarks`(Task 1), `createdAtMsEffective`(Task 2), `ViewedDocsStore.readAll`(Task 3), `deleteDoc`(Task 4).
- Produces:
  - `({List<AttemptRecord> merged, Map<String, Map<String,dynamic>> toCloud, List<String> toDelete}) mergeAttempts(List<AttemptRecord> local, Map<String, Map<String,dynamic>> cloud, {Map<String,int> resetAt = const {}})`
  - `({Map<String, Map<String,int>> merged, Map<String, Map<String,dynamic>> toCloud, List<String> toDelete}) mergeViewed(Map<String, Map<String,int>> local, Map<String, Map<String,dynamic>> cloud, {Map<String,int> resetAt = const {}})`
  - `Map<String,int> viewedItemsOf(Map<String,dynamic> doc)`
  - `SyncService.maxDeletesPerRound = 50`

- [ ] **Step 1: 실패 테스트 작성 — 순수 함수**

`flutter_app/test/cloud/sync_merge_reset_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/cloud/sync_merge.dart';
import 'package:aws_docs/models/attempt_record.dart';

AttemptRecord _rec(String date, int createdAtMs) => AttemptRecord(
      certId: 'CLF-C02',
      examId: 'exam:clf-t1-1',
      mode: 'exam',
      date: date,
      correct: 1,
      total: 1,
      wrongQuestionIds: const [],
      flaggedQuestionIds: const [],
      durationSpentSec: 10,
      createdAtMs: createdAtMs,
    );

void main() {
  test('mergeAttempts: 표식보다 오래된 레코드는 버리고 삭제 목록에 넣는다', () {
    final old = _rec('2026-09-01T00:00:00.000', 1000);
    final fresh = _rec('2026-09-23T00:00:00.000', 5000);
    final cloud = {
      attemptKey(old): old.toJson(),
      attemptKey(fresh): fresh.toJson(),
    };

    final r = mergeAttempts([old, fresh], cloud, resetAt: {'CLF-C02': 3000});

    expect(r.merged.map((e) => e.createdAtMs), [5000]);
    expect(r.toDelete, [attemptKey(old)]);
    expect(r.toCloud, isEmpty);
  });

  test('mergeAttempts: 전체 표식(*)도 적용된다', () {
    final r = mergeAttempts([_rec('2026-09-01T00:00:00.000', 1000)], const {},
        resetAt: {'*': 3000});
    expect(r.merged, isEmpty);
    expect(r.toCloud, isEmpty);
  });

  test('mergeAttempts: 표식이 없으면 기존 합집합 그대로', () {
    final a = _rec('2026-09-01T00:00:00.000', 1000);
    final r = mergeAttempts([a], const {});
    expect(r.merged.length, 1);
    expect(r.toCloud.keys, [attemptKey(a)]);
    expect(r.toDelete, isEmpty);
  });

  test('mergeViewed: 표식 이후 열람만 남기고 빈 자격증은 삭제 목록에', () {
    final local = {
      'CLF-C02': {'t-old': 1000, 't-new': 9000},
    };
    final cloud = {
      'CLF-C02': {
        'items': {'t-old': 1000}
      },
      'SAA-C03': {
        'items': {'s-old': 500}
      },
    };

    final r = mergeViewed(local, cloud, resetAt: {'*': 3000});

    expect(r.merged['CLF-C02'], {'t-new': 9000});
    expect(r.merged['SAA-C03'], isEmpty);
    expect(r.toDelete, contains('SAA-C03'));
    expect(r.toCloud['CLF-C02']!['items'], {'t-new': 9000});
  });

  test('viewedItemsOf: 레거시 taskIds 배열은 시각 0', () {
    expect(viewedItemsOf({
      'taskIds': ['a', 'b']
    }), {'a': 0, 'b': 0});
    expect(viewedItemsOf({
      'items': {'a': 7}
    }), {'a': 7});
  });
}
```

`flutter_app/test/cloud/sync_merge_viewed_test.dart` 전체를 새 형태로 교체:

```dart
// flutter_app/test/cloud/sync_merge_viewed_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/cloud/sync_merge.dart';

void main() {
  test('mergeViewed: cert별 taskId 합집합 + 변경 cert만 toCloud', () {
    final local = {
      'CLF-C02': {'t1': 10, 't2': 20},
      'SAA-C03': {'s1': 30},
    };
    final cloud = {
      'CLF-C02': {
        'items': {'t2': 20, 't3': 40}
      },
      'SOA-C03': {
        'items': {'o1': 50}
      },
    };
    final r = mergeViewed(local, cloud);
    expect(r.merged['CLF-C02']!.keys.toSet(), {'t1', 't2', 't3'});
    expect(r.merged['SAA-C03']!.keys.toSet(), {'s1'});
    expect(r.merged['SOA-C03']!.keys.toSet(), {'o1'});
    expect(r.toCloud.keys.toSet(), {'CLF-C02', 'SAA-C03'});
    expect((r.toCloud['CLF-C02']!['items'] as Map).keys.toSet(),
        {'t1', 't2', 't3'});
  });
}
```

- [ ] **Step 2: 실패 테스트 작성 — 서비스**

`flutter_app/test/cloud/sync_service_test.dart` 상단 import에 추가:

```dart
import 'package:aws_docs/data/cloud/sync_merge.dart';
import 'package:aws_docs/data/cloud/sync_meta.dart';
import 'package:aws_docs/data/viewed_docs_store.dart';
```

파일 마지막 `}` 앞에 추가:

```dart
  group('삭제 표식(meta/deletions)', () {
    test('로컬 표식이 클라우드에 올라가고 옛 응시·열람이 양쪽에서 지워진다', () async {
      final local = MemoryBackend();
      final cloud = FakeCloudStore();
      HistoryStore(backend: local, nowMs: () => 1000)
          .add(_attempt('2026-09-01T00:00:00.000'));
      ViewedDocsStore(backend: local, nowMs: () => 1000)
          .markViewed('CLF-C02', 'clf-t1-1');
      final svc = SyncService(local: local, cloud: cloud, nowMs: () => 5000);
      await svc.reconcileAll('u1'); // 1회차: 클라우드로 push

      SyncMeta(local).markReset('CLF-C02', 3000); // 초기화 표식
      HistoryStore(backend: local).clearCert('CLF-C02');
      ViewedDocsStore(backend: local).clearCert('CLF-C02');

      await svc.reconcileAll('u1');

      expect(HistoryStore(backend: local).all(), isEmpty);
      expect(await cloud.loadCollection('u1', 'attempts'), isEmpty);
      expect(await cloud.loadCollection('u1', 'viewed'), isEmpty);
      final marks =
          (await cloud.loadCollection('u1', 'meta'))['deletions']!['resetAt'];
      expect((marks as Map)['CLF-C02'], 3000);
    });

    test('다른 기기의 표식을 받아 로컬을 정리한다', () async {
      final local = MemoryBackend();
      final cloud = FakeCloudStore();
      HistoryStore(backend: local, nowMs: () => 1000)
          .add(_attempt('2026-09-01T00:00:00.000'));
      await cloud.setDoc('u1', 'meta', 'deletions', {
        'resetAt': {'CLF-C02': 3000}
      });

      await SyncService(local: local, cloud: cloud, nowMs: () => 5000)
          .reconcileAll('u1');

      expect(HistoryStore(backend: local).all(), isEmpty);
      expect(SyncMeta(local).resetAt['CLF-C02'], 3000);
    });

    test('표식 이후에 만든 기록은 살아남는다', () async {
      final local = MemoryBackend();
      final cloud = FakeCloudStore();
      HistoryStore(backend: local, nowMs: () => 9000)
          .add(_attempt('2026-09-23T00:00:00.000'));
      await cloud.setDoc('u1', 'meta', 'deletions', {
        'resetAt': {'CLF-C02': 3000}
      });

      await SyncService(local: local, cloud: cloud, nowMs: () => 9500)
          .reconcileAll('u1');

      expect(HistoryStore(backend: local).all().single.createdAtMs, 9000);
      expect((await cloud.loadCollection('u1', 'attempts')).length, 1);
    });

    test('정리 삭제는 한 회차 50건까지만 한다', () async {
      final local = MemoryBackend();
      final cloud = FakeCloudStore();
      for (var i = 0; i < 60; i++) {
        final r = _attempt('2026-09-01T00:00:${i.toString().padLeft(2, '0')}.000')
            .withCreatedAtMs(1000);
        await cloud.setDoc('u1', 'attempts', attemptKey(r), r.toJson());
      }
      SyncMeta(local).markReset('CLF-C02', 3000);

      await SyncService(local: local, cloud: cloud, nowMs: () => 5000)
          .reconcileAll('u1');

      expect((await cloud.loadCollection('u1', 'attempts')).length, 10);
    });
  });
```

`flutter_app/test/cloud/sync_controller_test.dart`의 로드 횟수 기대값을 바꾼다(`meta` 화해가 1회 더해진다):

```dart
    // 빈 로컬·클라우드 → push 없음 → watch 재발화 없음 →
    // reconcile 1회 = loadCollection 5회(meta·attempts·viewed·plans·checks).
    expect(spy.loads, 5);
```

- [ ] **Step 3: 실패 확인**

Run: `flutter test test/cloud/`
Expected: 컴파일/단언 실패 — `resetAt` 파라미터·`toDelete`·`viewedItemsOf`·`meta` 화해 없음.

- [ ] **Step 4: 구현 — 병합 함수**

`sync_merge.dart` 상단에 추가:

```dart
import 'sync_meta.dart';
```

`mergeAttempts`를 교체:

```dart
/// attempts union(무손실) + 삭제 표식 적용: 로컬 리스트 + 클라우드(키→json)
/// → 병합 리스트 + 클라우드에 없던 로컬만 toCloud + 표식보다 오래된 클라우드 키는 toDelete.
({
  List<AttemptRecord> merged,
  Map<String, Map<String, dynamic>> toCloud,
  List<String> toDelete,
}) mergeAttempts(
  List<AttemptRecord> local,
  Map<String, Map<String, dynamic>> cloud, {
  Map<String, int> resetAt = const {},
}) {
  bool kept(AttemptRecord r) =>
      r.createdAtMsEffective >= mergedEffectiveResetAt(resetAt, r.certId);

  final byKey = <String, AttemptRecord>{};
  for (final r in local) {
    if (kept(r)) byKey[attemptKey(r)] = r;
  }
  final toDelete = <String>[];
  for (final e in cloud.entries) {
    final r = AttemptRecord.fromJson(e.value);
    if (!kept(r)) {
      toDelete.add(e.key);
      continue;
    }
    byKey.putIfAbsent(e.key, () => r);
  }
  final toCloud = <String, Map<String, dynamic>>{};
  for (final r in local) {
    if (!kept(r)) continue;
    final k = attemptKey(r);
    if (!cloud.containsKey(k)) toCloud[k] = r.toJson();
  }
  return (merged: byKey.values.toList(), toCloud: toCloud, toDelete: toDelete);
}
```

`mergeViewed`를 교체:

```dart
/// 클라우드 열람 문서에서 {taskId: 시각}을 읽는다. 레거시 `taskIds` 배열은 시각 0.
Map<String, int> viewedItemsOf(Map<String, dynamic> doc) {
  final items = doc['items'];
  if (items is Map) {
    return {
      for (final e in items.entries)
        if (e.value is num) e.key.toString(): (e.value as num).toInt(),
    };
  }
  final legacy = doc['taskIds'];
  if (legacy is List) return {for (final x in legacy) x.toString(): 0};
  return {};
}

/// viewed 합집합 + 삭제 표식 적용. 같은 taskId가 양쪽에 있으면 늦은 시각을 남긴다.
({
  Map<String, Map<String, int>> merged,
  Map<String, Map<String, dynamic>> toCloud,
  List<String> toDelete,
}) mergeViewed(
  Map<String, Map<String, int>> local,
  Map<String, Map<String, dynamic>> cloud, {
  Map<String, int> resetAt = const {},
}) {
  final merged = <String, Map<String, int>>{};
  final toCloud = <String, Map<String, dynamic>>{};
  final toDelete = <String>[];
  final certs = {...local.keys, ...cloud.keys};
  for (final cert in certs) {
    final cut = mergedEffectiveResetAt(resetAt, cert);
    final l = local[cert] ?? const <String, int>{};
    final c =
        cloud[cert] == null ? const <String, int>{} : viewedItemsOf(cloud[cert]!);
    final union = <String, int>{};
    for (final e in [...l.entries, ...c.entries]) {
      if (e.value >= (union[e.key] ?? 0)) union[e.key] = e.value;
    }
    union.removeWhere((_, ms) => ms < cut);
    merged[cert] = union;
    if (union.isEmpty) {
      if (cloud.containsKey(cert)) toDelete.add(cert);
      continue;
    }
    final sameAsCloud = union.length == c.length &&
        union.entries.every((e) => c[e.key] == e.value);
    if (!sameAsCloud) toCloud[cert] = {'items': union};
  }
  return (merged: merged, toCloud: toCloud, toDelete: toDelete);
}
```

- [ ] **Step 5: 구현 — SyncService**

`sync_service.dart` 상단 import에 추가:

```dart
import '../viewed_docs_store.dart';
import 'sync_meta.dart';
```

클래스에 추가:

```dart
  /// 한 회차에서 지우는 클라우드 문서 수 상한(초기화 직후 동기가 길어지지 않게).
  static const maxDeletesPerRound = 50;

  /// meta/deletions 화해: 로컬·클라우드 표식을 필드별 늦은 시각으로 합쳐 양쪽에
  /// 반영하고, 이번 회차에 적용할 표식을 돌려준다.
  Future<Map<String, int>> _reconcileDeletions(String uid) async {
    final doc = (await _cloud.loadCollection(uid, 'meta'))['deletions'] ??
        const <String, dynamic>{};
    final cloudMarks = <String, int>{
      for (final e in ((doc['resetAt'] as Map?) ?? const {}).entries)
        if (e.value is num) e.key.toString(): (e.value as num).toInt(),
    };
    final meta = SyncMeta(_local);
    final merged = mergeResetMarks(meta.resetAt, cloudMarks);
    if (!_sameMarks(merged, meta.resetAt)) meta.resetAt = merged;
    if (!_sameMarks(merged, cloudMarks)) {
      await _cloud.setDoc(uid, 'meta', 'deletions', {...doc, 'resetAt': merged});
    }
    return merged;
  }

  bool _sameMarks(Map<String, int> a, Map<String, int> b) =>
      a.length == b.length && a.entries.every((e) => b[e.key] == e.value);

  Future<void> _deleteUpTo(
      String uid, String collection, List<String> ids) async {
    for (final id in ids.take(maxDeletesPerRound)) {
      await _cloud.deleteDoc(uid, collection, id);
    }
  }
```

`reconcileAll`을 교체:

```dart
  /// 로그인 직후·트리거 시 양방향 화해. 삭제 표식을 먼저 화해해 이번 회차 기준으로 쓴다.
  Future<void> reconcileAll(String uid) async {
    final marks = await _reconcileDeletions(uid);
    await _reconcileAttempts(uid, marks);
    await _reconcileViewed(uid, marks);
    await _reconcileLww(uid, _kPlans, 'plans', 'plans'); // 레거시(PR2에서 교체)
    await _reconcileLww(uid, _kChecks, 'checks', 'checks');
  }
```

`_reconcileAttempts`·`_reconcileViewed`를 교체:

```dart
  Future<void> _reconcileAttempts(String uid, Map<String, int> marks) async {
    final cloud = await _cloud.loadCollection(uid, 'attempts');
    final local = _readJsonList(_kHistory)
        .whereType<Map<String, dynamic>>()
        .map(AttemptRecord.fromJson)
        .toList();
    final r = mergeAttempts(local, cloud, resetAt: marks);
    _writeIfChanged(
        _kHistory, jsonEncode(r.merged.map((e) => e.toJson()).toList()));
    for (final e in r.toCloud.entries) {
      await _cloud.setDoc(uid, 'attempts', e.key, e.value);
    }
    await _deleteUpTo(uid, 'attempts', r.toDelete);
  }

  Future<void> _reconcileViewed(String uid, Map<String, int> marks) async {
    final cloud = await _cloud.loadCollection(uid, 'viewed');
    final local = ViewedDocsStore(backend: _local).readAll();
    final r = mergeViewed(local, cloud, resetAt: marks);
    _writeIfChanged(_kViewed, jsonEncode(r.merged));
    for (final e in r.toCloud.entries) {
      await _cloud.setDoc(uid, 'viewed', e.key, e.value);
    }
    await _deleteUpTo(uid, 'viewed', r.toDelete);
  }
```

- [ ] **Step 6: 통과 확인**

Run: `flutter test && flutter analyze`
Expected: 전부 PASS · 0건. 기존 경합 테스트(로드 대기 중 쓰기 보존)와 무변경 재기록 테스트도 계속 통과해야 한다.

- [ ] **Step 7: 커밋**

```bash
git branch --show-current
git add flutter_app/lib/data/cloud/sync_merge.dart flutter_app/lib/data/cloud/sync_service.dart flutter_app/test/cloud/
git commit -m "feat(sync): 삭제 표식 화해와 적용(응시·열람) + 정리 삭제 상한

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
```

---

### Task 6: 초기화가 표식을 남긴다

**Files:**
- Modify: `flutter_app/lib/data/study_reset.dart`
- Test: `flutter_app/test/study_reset_test.dart`

**Interfaces:**
- Consumes: `SyncMeta`(Task 1).
- Produces: `void resetCert(String certCode, {KvBackend? backend, int Function()? nowMs})`, `void resetAll({KvBackend? backend, int Function()? nowMs})`.

- [ ] **Step 1: 실패 테스트 작성**

`flutter_app/test/study_reset_test.dart` 상단 import에 추가:

```dart
import 'package:aws_docs/data/cloud/sync_meta.dart';
```

`group('resetCert / resetAll', ...)` 안에 추가:

```dart
    test('resetCert: 자격증 삭제 표식을 남긴다', () {
      final b = MemoryBackend();
      resetCert('CLF-C02', backend: b, nowMs: () => 4242);
      expect(SyncMeta(b).resetAt, {'CLF-C02': 4242});
    });

    test('resetAll: 전체 삭제 표식을 남긴다(표식은 초기화로 지워지지 않는다)', () {
      final b = MemoryBackend();
      resetAll(backend: b, nowMs: () => 777);
      expect(SyncMeta(b).resetAt, {'*': 777});
    });
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/study_reset_test.dart`
Expected: 컴파일 실패 — `nowMs` 파라미터 없음.

- [ ] **Step 3: 구현**

`study_reset.dart` 상단 import에 추가:

```dart
import 'cloud/sync_meta.dart';
```

두 함수를 교체한다(본문은 기존과 같고 마지막 줄만 더해진다):

```dart
int _utcNowMs() => DateTime.now().toUtc().millisecondsSinceEpoch;

/// 한 자격증의 모든 학습 기록을 삭제한다(다른 자격증은 보존).
/// 로그인 상태면 다음 동기가 이 표식으로 클라우드·다른 기기까지 정리한다.
void resetCert(String certCode, {KvBackend? backend, int Function()? nowMs}) {
  final b = backend ?? defaultBackend();
  HistoryStore(backend: b).clearCert(certCode);
  ViewedDocsStore(backend: b).clearCert(certCode);
  final planStore = StudyPlanStore(backend: b);
  final progress = PlanProgressStore(backend: b);
  for (final p in planStore.plansFor(certCode)) {
    progress.clearPlan(p.id);
  }
  planStore.clearCert(certCode);
  PlanCheckStore(backend: b).clearCert(certCode);
  final sessions = ExamSessionStore(backend: b);
  for (final id in examIdsForCert(certCode)) {
    sessions.clear(id);
  }
  SyncMeta(b).markReset(certCode, (nowMs ?? _utcNowMs)());
}

/// 모든 자격증의 모든 학습 기록을 삭제한다(공장 초기화).
void resetAll({KvBackend? backend, int Function()? nowMs}) {
  final b = backend ?? defaultBackend();
  HistoryStore(backend: b).clearAll();
  ViewedDocsStore(backend: b).clearAll();
  StudyPlanStore(backend: b).clearAll();
  PlanCheckStore(backend: b).clearAll();
  PlanProgressStore(backend: b).clearAll();
  ExamSessionStore(backend: b).clearAll();
  SyncMeta(b).markReset(SyncMeta.allCerts, (nowMs ?? _utcNowMs)());
}
```

- [ ] **Step 4: 통과 확인**

Run: `flutter test test/study_reset_test.dart && flutter test`
Expected: 전부 PASS

- [ ] **Step 5: 커밋**

```bash
git branch --show-current
git add flutter_app/lib/data/study_reset.dart flutter_app/test/study_reset_test.dart
git commit -m "feat(reset): 초기화가 삭제 표식을 남기도록

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
```

---

### Task 7: 다른 기기의 초기화를 즉시 수신

**Files:**
- Modify: `flutter_app/lib/data/cloud/sync_controller.dart`
- Test: `flutter_app/test/cloud/sync_controller_test.dart`

**Interfaces:**
- Consumes: `SyncMeta`(Task 1), `_reconcileDeletions`(Task 5).

- [ ] **Step 1: 실패 테스트 작성**

`flutter_app/test/cloud/sync_controller_test.dart` 상단 import에 추가:

```dart
import 'package:aws_docs/data/cloud/sync_meta.dart';
```

`void main() {` 안에 추가:

```dart
  test('meta 변경(다른 기기의 초기화)도 reconcile을 트리거한다', () async {
    final cloud = FakeCloudStore();
    final local = MemoryBackend();
    final ctrl = SyncController(
        auth: FakeAuthService(), cloud: cloud, local: local, nowMs: () => 1000);
    ctrl.start();
    await ctrl.signIn();

    await cloud.setDoc('u-test', 'meta', 'deletions', {
      'resetAt': {'CLF-C02': 3000}
    });
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(SyncMeta(local).resetAt['CLF-C02'], 3000);
  });
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/cloud/sync_controller_test.dart`
Expected: FAIL — `meta`를 구독하지 않아 reconcile이 다시 돌지 않고 사이드카가 비어 있음.

- [ ] **Step 3: 구현**

`sync_controller.dart`의 `_startWatches`를 교체:

```dart
  void _startWatches(String uid) {
    // meta = 삭제 표식. 다른 기기의 초기화를 즉시 받아 로컬을 정리한다.
    for (final coll in const [
      'meta',
      'attempts',
      'viewed',
      'plans',
      'checks'
    ]) {
      _watchSubs.add(_cloud.watchCollection(uid, coll).listen((_) => sync()));
    }
  }
```

- [ ] **Step 4: 통과 확인**

Run: `flutter test test/cloud/`
Expected: PASS

- [ ] **Step 5: 커밋**

```bash
git branch --show-current
git add flutter_app/lib/data/cloud/sync_controller.dart flutter_app/test/cloud/sync_controller_test.dart
git commit -m "feat(sync): 삭제 표식 문서 변경도 수신

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
```

---

### Task 8: 초기화 확인창 문구 복귀

삭제가 실제로 모든 기기·클라우드에서 이뤄지므로 2026-09-22의 임시 경고를 거둔다.

**Files:**
- Modify: `flutter_app/lib/content/reset_dialog.dart`
- Test: `flutter_app/test/reset_sync_notice_test.dart`

**Interfaces:**
- Produces: `confirmReset` 시그니처 유지. 본문 끝맺음이 동기 상태와 무관해진다.

- [ ] **Step 1: 테스트 수정(실패 확인용)**

`test/reset_sync_notice_test.dart`의 group 제목과 로그인 3건의 기대값을 바꾼다. 세 곳 모두 아래처럼 "되돌릴 수 없"을 기대하고 "클라우드 백업"은 없어야 한다:

```dart
  group('초기화 확인창은 로그인 여부와 무관하게 되돌릴 수 없다고 알린다', () {
    testWidgets('홈 — 모든 학습 기록 초기화', (tester) async {
      await _signIn(tester);
      await _openHomeReset(tester);
      expect(find.textContaining('되돌릴 수 없'), findsOneWidget);
      expect(find.textContaining('클라우드 백업'), findsNothing);
    });
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/reset_sync_notice_test.dart`
Expected: FAIL — 로그인 상태에서 아직 클라우드 경고가 뜬다.

- [ ] **Step 3: 구현**

`reset_dialog.dart` 전체를 교체:

```dart
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// 파괴적 동작(학습 기록 삭제) 확인 다이얼로그. 영향 범위를 본문에 명시하고
/// 위험 버튼(c.wrong 톤)으로 실수 클릭을 줄인다. 확인 시 true.
/// 동기 켜짐 상태에서도 삭제 표식이 모든 기기·클라우드로 전파되므로 되돌릴 수 없다.
Future<bool> confirmReset(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = '초기화',
}) async {
  final c = context.c;
  final t = Theme.of(context).textTheme;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.md),
        side: BorderSide(color: c.border),
      ),
      title: Text(title,
          style: t.titleMedium?.copyWith(
              fontWeight: FontWeight.w800, fontVariations: Wght.w800)),
      content: Text('$message\n\n이 작업은 되돌릴 수 없습니다.',
          style: t.bodyMedium?.copyWith(color: c.text)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text('취소', style: TextStyle(color: c.textMuted)),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(confirmLabel,
              style: TextStyle(
                  color: c.wrong,
                  fontWeight: FontWeight.w800,
                  fontVariations: Wght.w800)),
        ),
      ],
    ),
  );
  return ok ?? false;
}
```

- [ ] **Step 4: 통과 확인**

Run: `flutter test && flutter analyze`
Expected: 전부 PASS · 0건

- [ ] **Step 5: 커밋과 PR**

```bash
git branch --show-current
git add flutter_app/lib/content/reset_dialog.dart flutter_app/test/reset_sync_notice_test.dart
git commit -m "feat(reset): 삭제가 전파되므로 확인창 문구를 되돌림

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
git push -u origin feat/sync-v2-pr1-deletion-marks
```

PR 본문에는 스펙 경로, 닫는 결함(C-2/CODE-D-003 근본 해결), 테스트 수, 남은 범위(PR2 일정·진행 동기 / PR3 정리)를 적는다.

---

## 완료 기준

- `flutter test` 전부 통과, `flutter analyze` 0건, CI `test` 녹색
- 초기화가 로그인 상태에서 응시·열람 기록을 로컬·클라우드·다른 기기에서 지운다
- 표식 이후에 만든 기록은 오프라인 기기 것이라도 살아남는다
- 기존 경합·무변경 재기록 테스트가 계속 통과한다(회귀 없음)

## 다음 플랜

- **PR2**: `plans/{planId}`·`progress/{planId}` 동기, 3-way 판정과 집합 병합, 레거시 클라우드 문서 변환, 개별 삭제 전파
- **PR3**: checks 동기 제외·정리, 레거시 LWW 경로와 옛 사이드카(`awsdocs.sync.v1`) 제거, 동기 경로 관용 파싱, 비로그인 과거 동기 안내 문구, `firestore.rules` 레포 관리와 에뮬레이터 테스트
