# 동기 프로토콜 v2 — PR2(일정·진행 동기) 구현 플랜

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 현행 학습 일정(v2)과 일정 완료 체크를 기기 간에 동기하고, 일정 개별 삭제도 다른 기기로 전파한다.

**Architecture:** 문서(일정 하나, 진행 하나)마다 **마지막 동기 시점의 내용(base)** 을 사이드카에 두고, 로컬·클라우드와 3-way로 비교한다. 로컬 변경 여부를 내용 비교로 판정하므로 스토어에 쓰기 시각을 심지 않는다. 완료 체크는 집합 3-way로 합쳐 양쪽 변경을 모두 살린다. 일정 삭제는 `meta/deletions.plans`의 시각 표식으로 전파한다.

**Tech Stack:** Flutter Web(Dart), `flutter_test`, 로컬 `KvBackend`, `CloudStore`(테스트는 `FakeCloudStore`).

**Spec:** `docs/superpowers/specs/2026-09-23-sync-protocol-v2-design.md` (§3.1 데이터 모델 · §4.3 3-way · §6.1 마이그레이션)

**선행:** PR1(삭제 표식 기반) 머지 완료 — `SyncMeta`, `CloudStore.deleteDoc`, `meta/deletions` 화해, 표식 필터가 이미 있다.

## Global Constraints

- 모든 명령은 `flutter_app/` 디렉터리에서 실행한다.
- Flutter 3.47.2 고정. 모든 시각은 **UTC epoch ms 정수**.
- 각 Task 끝에서 `flutter analyze` 0건, `flutter test` 전부 통과를 눈으로 확인한다(현재 기준선 851).
- 테스트를 먼저 쓰고 **실패를 확인한 뒤** 구현한다.
- 커밋 직전 `git branch --show-current`로 확인한다(공유 워킹트리).
- 브랜치는 `develop`에서 분기한 `feat/sync-v2-pr2-plans-progress`, PR 대상은 `develop`.
- 커밋 메시지 마지막 줄: `Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>`
- **기존 테스트 파일을 Write로 덮어쓰지 않는다.** 아래에서 "추가"라고 한 파일은 반드시 내용을 덧붙인다(PR1에서 덮어쓰기 사고 2건).
- **로컬 쓰기와 클라우드 await를 섞지 않는다.** `sync_service.dart` 주석(CODE-D-004)대로, 클라우드 로드를 먼저 끝내고 → 로컬 읽기·병합·로컬 쓰기를 await 없이 잇고 → 그 뒤에 클라우드 쓰기를 모아서 한다.
- 클라우드 문서 형태는 스펙 §3.1 그대로: `plans/{planId}` = 일정 JSON + `updatedAtMs`, `progress/{planId}` = `{certCode, itemIds, updatedAtMs}`.

---

## File Structure

**신규**
- `lib/data/cloud/sync_three_way.dart` — 문서 3-way 판정(`DocAction`, `decideDoc`)과 집합 3-way 병합(`mergeSets`). 순수 함수만.
- `test/cloud/sync_three_way_test.dart`, `test/cloud/sync_plans_test.dart`, `test/cloud/sync_progress_test.dart` — 셋 다 현재 없음(확인 완료).

**수정**
- `lib/data/cloud/sync_meta.dart` — 엔티티별 부기(`base`·`updatedAt`·`dirtyAt`), 일정 삭제 표식(`deletedPlans`).
- `lib/data/study_plan_store.dart` — 동기용 접근자(`byId`·`upsert`·`removeById`).
- `lib/data/plan_progress_store.dart` — 동기용 접근자(`readAll`·`setPlan`).
- `lib/data/cloud/sync_service.dart` — 일정·진행 화해로 교체(레거시 `plans` LWW 제거).
- `lib/data/cloud/sync_controller.dart` — watch 대상에 `progress` 추가.
- 테스트 추가: `test/cloud/sync_meta_test.dart`, `test/study_plan_store_test.dart`, `test/plan_progress_store_test.dart`, `test/cloud/sync_controller_test.dart`, `test/cloud/sync_service_test.dart`.

**범위 밖(PR3):** `checks` 동기 제거와 옛 사이드카(`awsdocs.sync.v1`) 정리, 로컬 `awsdocs.plan.v1` 잔존 키 정리, 동기 경로 관용 파싱, `firestore.rules`.

---

### Task 1: 사이드카에 엔티티 부기 추가

**Files:**
- Modify: `flutter_app/lib/data/cloud/sync_meta.dart`
- Test: `flutter_app/test/cloud/sync_meta_test.dart` (추가)

**Interfaces:**
- Produces: `class EntityMeta`, `EntityMeta SyncMeta.entity(String kind)`, `void SyncMeta.setEntity(String kind, EntityMeta m)`. `kind`는 `'plans'` 또는 `'progress'`.

- [ ] **Step 1: 실패 테스트 작성**

`test/cloud/sync_meta_test.dart`의 마지막 `}` 앞에 추가:

```dart
  group('엔티티 부기(base·updatedAt·dirtyAt)', () {
    test('없으면 빈 부기를 돌려준다', () {
      final m = SyncMeta(MemoryBackend()).entity('plans');
      expect(m.base, isEmpty);
      expect(m.updatedAt, isEmpty);
      expect(m.dirtyAt, isEmpty);
    });

    test('저장한 부기를 그대로 읽는다', () {
      final b = MemoryBackend();
      SyncMeta(b).setEntity(
          'plans',
          const EntityMeta(
            base: {
              'p1': {'id': 'p1', 'label': 'A'}
            },
            updatedAt: {'p1': 100},
            dirtyAt: {'p1': 200},
          ));
      final m = SyncMeta(b).entity('plans');
      expect(m.base['p1'], {'id': 'p1', 'label': 'A'});
      expect(m.updatedAt, {'p1': 100});
      expect(m.dirtyAt, {'p1': 200});
    });

    test('종류가 다르면 서로 간섭하지 않고, 표식도 보존된다', () {
      final b = MemoryBackend();
      SyncMeta(b).markReset('CLF-C02', 50);
      SyncMeta(b).setEntity('plans',
          const EntityMeta(base: {}, updatedAt: {'p1': 1}, dirtyAt: {}));
      SyncMeta(b).setEntity('progress',
          const EntityMeta(base: {}, updatedAt: {'p2': 2}, dirtyAt: {}));
      expect(SyncMeta(b).entity('plans').updatedAt, {'p1': 1});
      expect(SyncMeta(b).entity('progress').updatedAt, {'p2': 2});
      expect(SyncMeta(b).resetAt, {'CLF-C02': 50});
    });

    test('손상된 항목은 건너뛴다', () {
      final b = MemoryBackend()
        ..write('awsdocs.sync.v2',
            '{"plans":{"base":{"p1":"oops"},"updatedAt":{"p1":"x","p2":3}}}');
      final m = SyncMeta(b).entity('plans');
      expect(m.base, isEmpty);
      expect(m.updatedAt, {'p2': 3});
    });
  });
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/cloud/sync_meta_test.dart`
Expected: 컴파일 실패 — `EntityMeta`·`entity`·`setEntity` 없음.

- [ ] **Step 3: 구현**

`sync_meta.dart`의 `SyncMeta` 클래스 안, `effectiveResetAt` 아래에 추가:

```dart
  /// 엔티티 종류(`plans`·`progress`)별 동기 부기.
  EntityMeta entity(String kind) {
    final m = _read()[kind];
    if (m is! Map) return const EntityMeta(base: {}, updatedAt: {}, dirtyAt: {});
    return EntityMeta(
      base: {
        for (final e in ((m['base'] as Map?) ?? const {}).entries)
          if (e.value is Map<String, dynamic>)
            e.key.toString(): e.value as Map<String, dynamic>,
      },
      updatedAt: _intMap(m['updatedAt']),
      dirtyAt: _intMap(m['dirtyAt']),
    );
  }

  void setEntity(String kind, EntityMeta m) {
    final all = _read();
    all[kind] = {
      'base': m.base,
      'updatedAt': m.updatedAt,
      'dirtyAt': m.dirtyAt,
    };
    _write(all);
  }

  static Map<String, int> _intMap(Object? v) {
    if (v is! Map) return {};
    return {
      for (final e in v.entries)
        if (e.value is num) e.key.toString(): (e.value as num).toInt(),
    };
  }
```

파일 끝(클래스 밖)에 추가:

```dart
/// 한 엔티티 종류의 동기 부기. [base]는 마지막 동기 시점의 문서 내용,
/// [updatedAt]은 그때의 클라우드 `updatedAtMs`, [dirtyAt]은 로컬 변경을 처음 감지한 시각.
class EntityMeta {
  const EntityMeta({
    required this.base,
    required this.updatedAt,
    required this.dirtyAt,
  });

  final Map<String, Map<String, dynamic>> base;
  final Map<String, int> updatedAt;
  final Map<String, int> dirtyAt;
}
```

- [ ] **Step 4: 통과 확인**

Run: `flutter test test/cloud/sync_meta_test.dart && flutter analyze lib/data/cloud/sync_meta.dart`
Expected: PASS · 0건

- [ ] **Step 5: 커밋**

```bash
git branch --show-current
git add flutter_app/lib/data/cloud/sync_meta.dart flutter_app/test/cloud/sync_meta_test.dart
git commit -m "feat(sync): 사이드카에 엔티티별 동기 부기(base·updatedAt·dirtyAt)

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
```

---

### Task 2: 3-way 판정과 집합 병합

**Files:**
- Create: `flutter_app/lib/data/cloud/sync_three_way.dart`
- Create: `flutter_app/test/cloud/sync_three_way_test.dart`

**Interfaces:**
- Produces: `enum DocAction { none, adoptCloud, pushLocal, deleteLocal, deleteCloud }`, `DocAction decideDoc({...})`, `Set<String> mergeSets({required Set<String> base, required Set<String> local, required Set<String> cloud})`.

- [ ] **Step 1: 실패 테스트 작성**

`flutter_app/test/cloud/sync_three_way_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/cloud/sync_three_way.dart';

const _a = {'id': 'p1', 'label': 'A'};
const _b = {'id': 'p1', 'label': 'B'};
const _c = {'id': 'p1', 'label': 'C'};

void main() {
  group('decideDoc', () {
    test('양쪽 모두 그대로면 아무것도 하지 않는다', () {
      expect(decideDoc(base: _a, local: _a, cloud: _a), DocAction.none);
    });

    test('로컬만 바뀌면 push', () {
      expect(decideDoc(base: _a, local: _b, cloud: _a), DocAction.pushLocal);
    });

    test('클라우드만 바뀌면 채택', () {
      expect(decideDoc(base: _a, local: _a, cloud: _b), DocAction.adoptCloud);
    });

    test('둘 다 바뀌면 늦은 쪽, 동률이면 클라우드', () {
      expect(
        decideDoc(
            base: _a,
            local: _b,
            cloud: _c,
            cloudUpdatedAtMs: 100,
            localDirtyAtMs: 200),
        DocAction.pushLocal,
      );
      expect(
        decideDoc(
            base: _a,
            local: _b,
            cloud: _c,
            cloudUpdatedAtMs: 200,
            localDirtyAtMs: 200),
        DocAction.adoptCloud,
      );
    });

    test('로컬에서 사라졌고 base에 있었으면 클라우드에서도 삭제', () {
      expect(decideDoc(base: _a, local: null, cloud: _a), DocAction.deleteCloud);
    });

    test('로컬에 없고 base에도 없으면 새 클라우드 문서를 채택', () {
      expect(decideDoc(base: null, local: null, cloud: _a),
          DocAction.adoptCloud);
    });

    test('삭제 표식이 있으면 로컬에서 지운다', () {
      expect(decideDoc(base: _a, local: _a, cloud: null, cloudDeleted: true),
          DocAction.deleteLocal);
      expect(decideDoc(base: _a, local: null, cloud: null, cloudDeleted: true),
          DocAction.none);
    });

    test('표식 없이 클라우드 문서만 사라지면 다시 올린다(손실 방지)', () {
      expect(decideDoc(base: _a, local: _a, cloud: null), DocAction.pushLocal);
    });
  });

  group('mergeSets', () {
    test('양쪽 추가를 모두 살린다', () {
      expect(
        mergeSets(base: {'a'}, local: {'a', 'b'}, cloud: {'a', 'c'}),
        {'a', 'b', 'c'},
      );
    });

    test('한쪽 삭제는 병합 결과에서도 빠진다', () {
      expect(
        mergeSets(base: {'a', 'b'}, local: {'a'}, cloud: {'a', 'b'}),
        {'a'},
      );
    });

    test('추가와 삭제가 섞여도 둘 다 반영된다', () {
      expect(
        mergeSets(base: {'a', 'b'}, local: {'a', 'c'}, cloud: {'b'}),
        {'c'},
      );
    });
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/cloud/sync_three_way_test.dart`
Expected: 컴파일 실패 — 파일 없음.

- [ ] **Step 3: 구현**

`flutter_app/lib/data/cloud/sync_three_way.dart`:

```dart
import 'dart:convert';

/// 문서 하나에 대한 3-way 판정 결과.
enum DocAction { none, adoptCloud, pushLocal, deleteLocal, deleteCloud }

/// 마지막 동기 내용([base])을 기준으로 로컬·클라우드 변화를 비교한다.
///
/// - 둘 다 바뀌었으면 늦은 쪽을 택한다. [localDirtyAtMs]는 로컬 변경을 처음 감지한
///   시각, [cloudUpdatedAtMs]는 클라우드 문서의 갱신 시각이며, 동률이면 클라우드를
///   택한다(기존 LWW 규칙 유지).
/// - [cloudDeleted]는 클라우드 삭제 표식이 이 문서를 지웠다는 뜻이다.
/// - 표식 없이 클라우드 문서만 사라진 경우는 다시 올린다 — 삭제는 항상 표식으로
///   오므로, 문서만 없어진 상황에서 로컬을 지우면 데이터를 잃을 수 있다.
DocAction decideDoc({
  Map<String, dynamic>? base,
  Map<String, dynamic>? local,
  Map<String, dynamic>? cloud,
  int cloudUpdatedAtMs = 0,
  int localDirtyAtMs = 0,
  bool cloudDeleted = false,
}) {
  if (cloudDeleted) return local == null ? DocAction.none : DocAction.deleteLocal;
  if (local == null && cloud == null) return DocAction.none;
  if (local == null) {
    return base != null ? DocAction.deleteCloud : DocAction.adoptCloud;
  }
  if (cloud == null) return DocAction.pushLocal;

  final localChanged = !_same(local, base);
  final cloudChanged = !_same(cloud, base);
  if (!localChanged && !cloudChanged) return DocAction.none;
  if (localChanged && !cloudChanged) return DocAction.pushLocal;
  if (!localChanged && cloudChanged) return DocAction.adoptCloud;
  return localDirtyAtMs > cloudUpdatedAtMs
      ? DocAction.pushLocal
      : DocAction.adoptCloud;
}

bool _same(Map<String, dynamic>? a, Map<String, dynamic>? b) {
  if (a == null || b == null) return a == null && b == null;
  return jsonEncode(a) == jsonEncode(b);
}

/// 집합 3-way 병합: 양쪽의 추가와 삭제를 모두 반영한다(손실 없음).
Set<String> mergeSets({
  required Set<String> base,
  required Set<String> local,
  required Set<String> cloud,
}) {
  final removed = base.difference(local).union(base.difference(cloud));
  return {...base, ...local, ...cloud}..removeAll(removed);
}
```

- [ ] **Step 4: 통과 확인**

Run: `flutter test test/cloud/sync_three_way_test.dart && flutter analyze lib/data/cloud/sync_three_way.dart`
Expected: PASS · 0건

- [ ] **Step 5: 커밋**

```bash
git branch --show-current
git add flutter_app/lib/data/cloud/sync_three_way.dart flutter_app/test/cloud/sync_three_way_test.dart
git commit -m "feat(sync): 문서 3-way 판정과 집합 3-way 병합 순수 함수

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
```

---

### Task 3: 스토어에 동기용 접근자

**Files:**
- Modify: `flutter_app/lib/data/study_plan_store.dart`, `flutter_app/lib/data/plan_progress_store.dart`
- Test: `flutter_app/test/study_plan_store_test.dart`, `flutter_app/test/plan_progress_store_test.dart` — **둘 다 이미 있다. 덮어쓰지 말고 내용을 추가한다.**

**Interfaces:**
- Produces: `Map<String, StudyPlan> StudyPlanStore.byId()`, `void StudyPlanStore.upsert(StudyPlan)`, `void StudyPlanStore.removeById(String planId)`, `Map<String, Set<String>> PlanProgressStore.readAll()`, `void PlanProgressStore.setPlan(String planId, Set<String> itemIds)`.

- [ ] **Step 1: 실패 테스트 작성(일정)**

`test/study_plan_store_test.dart`의 마지막 `}` 앞에 추가(파일 상단의 헬퍼 `_plan(String id, String cert, {String label = ''})`를 그대로 쓴다):

```dart
  group('동기용 접근자', () {
    test('byId: 모든 자격증의 일정을 planId로 색인한다', () {
      final b = MemoryBackend();
      StudyPlanStore(backend: b)
        ..add(_plan('', 'CLF-C02', label: 'A'))
        ..add(_plan('', 'SAA-C03', label: 'B'));
      final byId = StudyPlanStore(backend: b).byId();
      expect(byId.length, 2);
      expect(byId.values.map((p) => p.label).toSet(), {'A', 'B'});
      expect(byId.keys.every((id) => id.isNotEmpty), isTrue);
    });

    test('upsert: 같은 id는 교체, 없으면 추가', () {
      final b = MemoryBackend();
      final s = StudyPlanStore(backend: b);
      s.add(_plan('', 'CLF-C02', label: 'A'));
      final id = s.plansFor('CLF-C02').single.id;

      s.upsert(_plan(id, 'CLF-C02', label: 'A2'));
      expect(s.plansFor('CLF-C02').single.label, 'A2');

      s.upsert(_plan('other', 'CLF-C02', label: 'B'));
      expect(s.plansFor('CLF-C02').length, 2);
    });

    test('removeById: 자격증을 몰라도 지운다', () {
      final b = MemoryBackend();
      final s = StudyPlanStore(backend: b);
      s.add(_plan('', 'SAA-C03', label: 'B'));
      final id = s.plansFor('SAA-C03').single.id;

      s.removeById(id);

      expect(s.plansFor('SAA-C03'), isEmpty);
      expect(s.byId(), isEmpty);
    });
  });
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/study_plan_store_test.dart`
Expected: 컴파일 실패 — `byId`·`upsert`·`removeById` 없음.

- [ ] **Step 3: 구현(일정)**

`study_plan_store.dart`의 `clearAll` 위에 추가:

```dart
  /// 모든 자격증의 일정을 planId로 색인한다(동기용).
  Map<String, StudyPlan> byId() {
    final out = <String, StudyPlan>{};
    for (final cert in _read().keys) {
      for (final p in plansFor(cert)) {
        out[p.id] = p;
      }
    }
    return out;
  }

  /// planId 기준 추가·갱신(동기 병합 결과 반영). id가 이미 있으면 교체한다.
  /// [add]와 달리 items를 재매핑하지 않는다 — 동기는 내용을 그대로 옮긴다.
  void upsert(StudyPlan plan) {
    final m = _read();
    final list = (m[plan.certCode] is List)
        ? List<dynamic>.from(m[plan.certCode] as List)
        : <dynamic>[];
    final i = list.indexWhere((j) => j is Map && j['id'] == plan.id);
    if (i >= 0) {
      list[i] = plan.toJson();
    } else {
      list.add(plan.toJson());
    }
    m[plan.certCode] = list;
    _write(m);
  }

  /// planId로 삭제한다(자격증 자동 판별).
  void removeById(String planId) {
    final m = _read();
    for (final cert in m.keys.toList()) {
      final list =
          (m[cert] is List) ? List<dynamic>.from(m[cert] as List) : <dynamic>[];
      final before = list.length;
      list.removeWhere((j) => j is Map && j['id'] == planId);
      if (list.length == before) continue;
      if (list.isEmpty) {
        m.remove(cert);
      } else {
        m[cert] = list;
      }
    }
    _write(m);
  }
```

- [ ] **Step 4: 실패 테스트 작성(진행)**

`test/plan_progress_store_test.dart`의 마지막 `}` 앞에 추가한다(파일에 import와 `main()`이 이미 있으므로 group만 넣는다. `MemoryBackend`는 스토어가 re-export 한다):

```dart
  group('동기용 접근자', () {
    test('readAll: 일정별 완료 집합을 돌려준다', () {
      final b = MemoryBackend();
      PlanProgressStore(backend: b)
        ..setDone('p1', 'i1', true)
        ..setDone('p1', 'i2', true)
        ..setDone('p2', 'i3', true);
      expect(PlanProgressStore(backend: b).readAll(), {
        'p1': {'i1', 'i2'},
        'p2': {'i3'}
      });
    });

    test('setPlan: 집합을 통째로 바꾸고, 비면 항목을 지운다', () {
      final b = MemoryBackend();
      PlanProgressStore(backend: b).setDone('p1', 'i1', true);

      PlanProgressStore(backend: b).setPlan('p1', {'i2', 'i3'});
      expect(PlanProgressStore(backend: b).donePlan('p1'), {'i2', 'i3'});

      PlanProgressStore(backend: b).setPlan('p1', {});
      expect(PlanProgressStore(backend: b).readAll(), isEmpty);
    });
  });
```

- [ ] **Step 5: 실패 확인**

Run: `flutter test test/plan_progress_store_test.dart`
Expected: 컴파일 실패 — `readAll`·`setPlan` 없음.

- [ ] **Step 6: 구현(진행)**

`plan_progress_store.dart`의 `clearPlan` 위에 추가:

```dart
  /// 모든 일정의 완료 집합(동기용).
  Map<String, Set<String>> readAll() => {
        for (final e in _read().entries)
          if (e.value is List)
            e.key: {for (final x in e.value as List) x.toString()},
      };

  /// 한 일정의 완료 집합을 통째로 설정한다(동기 병합 결과 반영). 비면 항목을 지운다.
  void setPlan(String planId, Set<String> itemIds) {
    final m = _read();
    if (itemIds.isEmpty) {
      m.remove(planId);
    } else {
      m[planId] = itemIds.toList();
    }
    _b.write(_key, jsonEncode(m));
  }
```

- [ ] **Step 7: 통과 확인**

Run: `flutter test test/study_plan_store_test.dart test/plan_progress_store_test.dart && flutter test && flutter analyze`
Expected: 전부 PASS · 0건

- [ ] **Step 8: 커밋**

```bash
git branch --show-current
git add flutter_app/lib/data/study_plan_store.dart flutter_app/lib/data/plan_progress_store.dart flutter_app/test/study_plan_store_test.dart flutter_app/test/plan_progress_store_test.dart
git commit -m "feat(plan): 일정·진행 스토어에 동기용 접근자 추가

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
```

---

### Task 4: 일정 동기(3-way) — 레거시 LWW 경로 교체

**Files:**
- Modify: `flutter_app/lib/data/cloud/sync_service.dart`
- Test: `flutter_app/test/cloud/sync_plans_test.dart`(신규), `flutter_app/test/cloud/sync_service_test.dart`(레거시 plans LWW 테스트 정리)

**Interfaces:**
- Consumes: `EntityMeta`(T1), `decideDoc`(T2), `StudyPlanStore.byId/upsert/removeById`(T3).
- Produces: `SyncService`가 `plans/{planId}`를 화해한다. 레거시 `_reconcileLww(uid, _kPlans, 'plans', 'plans')` 호출과 `_kPlans` 상수(`awsdocs.plan.v1`)는 제거한다. `_reconcileLww`·`_meta`·`_writeMeta`는 `checks`가 계속 쓰므로 남긴다.

- [ ] **Step 1: 실패 테스트 작성**

`flutter_app/test/cloud/sync_plans_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/cloud/cloud_store.dart';
import 'package:aws_docs/data/cloud/sync_meta.dart';
import 'package:aws_docs/data/cloud/sync_service.dart';
import 'package:aws_docs/data/study_plan_store.dart';
import 'package:aws_docs/models/study_plan.dart';

StudyPlan _plan(String id, String cert, String label) => StudyPlan(
      id: id,
      label: label,
      certCode: cert,
      startIso: '2026-09-01',
      endIso: '2026-10-01',
      mode: PlanMode.period,
      createdIso: '2026-09-01',
      items: const [],
    );

void main() {
  test('로컬 일정이 클라우드로 올라간다(updatedAtMs 포함)', () async {
    final local = MemoryBackend();
    final cloud = FakeCloudStore();
    StudyPlanStore(backend: local).add(_plan('', 'CLF-C02', 'A'));
    final id = StudyPlanStore(backend: local).plansFor('CLF-C02').single.id;

    await SyncService(local: local, cloud: cloud, nowMs: () => 5000)
        .reconcileAll('u1');

    final doc = (await cloud.loadCollection('u1', 'plans'))[id]!;
    expect(doc['label'], 'A');
    expect(doc['updatedAtMs'], 5000);
    expect(SyncMeta(local).entity('plans').base[id]!['label'], 'A');
  });

  test('클라우드 일정이 로컬로 내려온다', () async {
    final local = MemoryBackend();
    final cloud = FakeCloudStore();
    final p = _plan('CLF-C02:2026-09-01:0', 'CLF-C02', 'B');
    await cloud.setDoc('u1', 'plans', p.id, {...p.toJson(), 'updatedAtMs': 100});

    await SyncService(local: local, cloud: cloud, nowMs: () => 5000)
        .reconcileAll('u1');

    expect(StudyPlanStore(backend: local).plansFor('CLF-C02').single.label, 'B');
  });

  test('로컬에서 고친 일정이 다음 동기에 되돌아가지 않는다', () async {
    final local = MemoryBackend();
    final cloud = FakeCloudStore();
    StudyPlanStore(backend: local).add(_plan('', 'CLF-C02', 'A'));
    final id = StudyPlanStore(backend: local).plansFor('CLF-C02').single.id;
    final svc = SyncService(local: local, cloud: cloud, nowMs: () => 5000);
    await svc.reconcileAll('u1'); // 1회차: push

    StudyPlanStore(backend: local).upsert(_plan(id, 'CLF-C02', 'A2'));
    await svc.reconcileAll('u1'); // 2회차: 로컬 변경 감지 → push

    expect(StudyPlanStore(backend: local).plansFor('CLF-C02').single.label, 'A2');
    expect((await cloud.loadCollection('u1', 'plans'))[id]!['label'], 'A2');
  });

  test('자격증 초기화 표식보다 오래된 클라우드 일정은 지운다', () async {
    final local = MemoryBackend();
    final cloud = FakeCloudStore();
    final p = _plan('CLF-C02:2026-09-01:0', 'CLF-C02', 'old');
    await cloud.setDoc('u1', 'plans', p.id, {...p.toJson(), 'updatedAtMs': 100});
    SyncMeta(local).markReset('CLF-C02', 3000);

    await SyncService(local: local, cloud: cloud, nowMs: () => 5000)
        .reconcileAll('u1');

    expect(await cloud.loadCollection('u1', 'plans'), isEmpty);
    expect(StudyPlanStore(backend: local).plansFor('CLF-C02'), isEmpty);
  });
}
```

`test/cloud/sync_service_test.dart`에서 레거시 plans LWW 테스트 2건(`'reconcileAll: plan LWW — 클라우드가 최신이면 로컬을 덮음(push 없음)'`, `'reconcileAll: plan LWW — 로컬이 최신이면 클라우드로 push'`)을 지운다. 사이드카 손상 테스트(`'reconcileAll: 손상 사이드카 stamp가 reconcile를 중단시키지 않음'`)는 `checks`로 바꿔 남긴다 — 로컬 키를 `awsdocs.plan.checks.v1`로, 기대 컬렉션을 `'checks'`로.

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/cloud/sync_plans_test.dart`
Expected: FAIL — 일정이 클라우드에 올라가지 않는다(레거시 경로는 `awsdocs.plan.v1`만 본다).

- [ ] **Step 3: 구현 — import와 reconcileAll**

`sync_service.dart` 상단에 추가:

```dart
import '../../models/study_plan.dart';
import '../study_plan_store.dart';
import 'sync_three_way.dart';
```

`_kPlans` 상수를 지우고 `reconcileAll`을 교체한다:

```dart
  Future<void> reconcileAll(String uid) async {
    final marks = await _reconcileDeletions(uid);
    await _reconcileAttempts(uid, marks);
    await _reconcileViewed(uid, marks);
    await _reconcilePlans(uid, marks);
    await _reconcileLww(uid, _kChecks, 'checks', 'checks'); // 레거시(PR3에서 제거)
  }
```

- [ ] **Step 4: 구현 — 일정 화해**

클래스 안에 추가한다. **순서 규칙:** 클라우드 로드 → (로컬 읽기·판정·로컬 쓰기, await 없음) → 사이드카 저장 → 클라우드 쓰기. 로컬 쓰기 사이에 await를 끼우지 않는다(CODE-D-004).

```dart
  /// 일정(v2) 화해. 문서마다 base와 비교해 3-way로 판정한다.
  Future<void> _reconcilePlans(String uid, Map<String, int> marks) async {
    final cloud = {...await _cloud.loadCollection(uid, 'plans')};
    final store = StudyPlanStore(backend: _local);
    final meta = SyncMeta(_local);
    final em = meta.entity('plans');
    final local = store.byId();

    final base = {...em.base};
    final updatedAt = {...em.updatedAt};
    final dirtyAt = {...em.dirtyAt};
    final toPush = <String, Map<String, dynamic>>{};
    final toDelete = <String>[];
    final now = _now();

    for (final id in {...local.keys, ...cloud.keys}) {
      final localDoc = local[id]?.toJson();
      final cloudRaw = cloud[id];
      final cloudDoc = cloudRaw == null
          ? null
          : (Map<String, dynamic>.from(cloudRaw)..remove('updatedAtMs'));
      final cloudMs = (cloudRaw?['updatedAtMs'] as num?)?.toInt() ?? 0;
      final cert = (localDoc ?? cloudDoc)?['certCode']?.toString() ?? '';
      final cut = mergedEffectiveResetAt(marks, cert);
      // 마지막으로 아는 로컬 시각. 한 번도 동기된 적 없는 일정(base에 없음)은
      // 시각을 알 수 없어 표식으로 지우지 않는다 — 미동기 로컬 작업을 잃지 않는 쪽.
      final localTime = dirtyAt[id] ?? updatedAt[id] ?? 0;
      final localStale =
          localDoc != null && base.containsKey(id) && localTime < cut;

      if ((cloudRaw != null && cloudMs < cut) || localStale) {
        if (cloudRaw != null) toDelete.add(id);
        if (localStale) store.removeById(id);
        base.remove(id);
        updatedAt.remove(id);
        dirtyAt.remove(id);
        continue;
      }

      // 로컬 변경을 처음 본 시각을 기록한다(둘 다 바뀐 경우의 비교 기준).
      if (localDoc != null &&
          base.containsKey(id) &&
          jsonEncode(localDoc) != jsonEncode(base[id]) &&
          dirtyAt[id] == null) {
        dirtyAt[id] = now;
      }

      switch (decideDoc(
        base: base[id],
        local: localDoc,
        cloud: cloudDoc,
        cloudUpdatedAtMs: cloudMs,
        localDirtyAtMs: dirtyAt[id] ?? 0,
      )) {
        case DocAction.none:
          break;
        case DocAction.adoptCloud:
          store.upsert(StudyPlan.fromJson(cloudDoc!));
          base[id] = cloudDoc;
          updatedAt[id] = cloudMs;
          dirtyAt.remove(id);
          break;
        case DocAction.pushLocal:
          toPush[id] = {...localDoc!, 'updatedAtMs': now};
          base[id] = localDoc;
          updatedAt[id] = now;
          dirtyAt.remove(id);
          break;
        case DocAction.deleteLocal:
          store.removeById(id);
          base.remove(id);
          updatedAt.remove(id);
          dirtyAt.remove(id);
          break;
        case DocAction.deleteCloud:
          toDelete.add(id);
          base.remove(id);
          updatedAt.remove(id);
          dirtyAt.remove(id);
          break;
      }
    }

    meta.setEntity('plans',
        EntityMeta(base: base, updatedAt: updatedAt, dirtyAt: dirtyAt));

    // 로컬 쓰기를 모두 끝낸 뒤 클라우드에 쓴다.
    for (final e in toPush.entries) {
      await _cloud.setDoc(uid, 'plans', e.key, e.value);
    }
    await _deleteUpTo(uid, 'plans', toDelete);
  }
```

- [ ] **Step 5: 통과 확인**

Run: `flutter test && flutter analyze`
Expected: 전부 PASS · 0건. `sync_controller_test`의 `spy.loads` 기대값은 그대로 5다(meta·attempts·viewed·plans·checks).

- [ ] **Step 6: 커밋**

```bash
git branch --show-current
git add flutter_app/lib/data/cloud/sync_service.dart flutter_app/test/cloud/
git commit -m "feat(sync): 일정(v2) 3-way 동기 — 레거시 plan LWW 경로 교체

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
```

---

### Task 5: 레거시 클라우드 일정 문서 변환

**Files:**
- Modify: `flutter_app/lib/data/cloud/sync_service.dart`
- Test: `flutter_app/test/cloud/sync_plans_test.dart`

**Interfaces:**
- Produces: `_reconcilePlans` 진입 시 레거시 `plans/{certCode}` 문서(=`id` 필드 없음. 옛 LWW 경로가 `awsdocs.plan.v1`을 올린 것)를 `plans/{planId}`로 옮기고 원본을 지운다. planId는 로컬 v1→v2 이관과 같은 규칙(`planIdOf(certCode, createdIso, 0)`), 이름은 `기존 일정`.

- [ ] **Step 1: 실패 테스트 작성**

`test/cloud/sync_plans_test.dart`에 추가:

```dart
  test('레거시 클라우드 일정 문서를 planId 문서로 옮긴다', () async {
    final local = MemoryBackend();
    final cloud = FakeCloudStore();
    await cloud.setDoc('u1', 'plans', 'CLF-C02', {
      'certCode': 'CLF-C02',
      'startIso': '2026-06-10',
      'endIso': '2026-06-24',
      'mode': 'period',
      'createdIso': '2026-06-10',
      'items': <dynamic>[],
      'updatedAt': 9000,
    });

    await SyncService(local: local, cloud: cloud, nowMs: () => 5000)
        .reconcileAll('u1');

    final docs = await cloud.loadCollection('u1', 'plans');
    expect(docs.containsKey('CLF-C02'), isFalse); // 레거시 문서 제거
    expect(docs.containsKey('CLF-C02:2026-06-10:0'), isTrue);
    final plan = StudyPlanStore(backend: local).plansFor('CLF-C02').single;
    expect(plan.id, 'CLF-C02:2026-06-10:0');
    expect(plan.label, '기존 일정');
  });

  test('변환은 결정적이다 — 두 번 돌려도 문서가 늘지 않는다', () async {
    final local = MemoryBackend();
    final cloud = FakeCloudStore();
    await cloud.setDoc('u1', 'plans', 'CLF-C02', {
      'certCode': 'CLF-C02',
      'startIso': '2026-06-10',
      'endIso': '2026-06-24',
      'mode': 'period',
      'createdIso': '2026-06-10',
      'items': <dynamic>[],
    });
    final svc = SyncService(local: local, cloud: cloud, nowMs: () => 5000);

    await svc.reconcileAll('u1');
    await svc.reconcileAll('u1');

    expect((await cloud.loadCollection('u1', 'plans')).length, 1);
  });
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/cloud/sync_plans_test.dart`
Expected: FAIL — 레거시 문서가 그대로 남고, `StudyPlan.fromJson`이 id 없는 문서를 빈 id로 읽는다.

- [ ] **Step 3: 구현**

`_reconcilePlans`의 `final cloud = {...await _cloud.loadCollection(uid, 'plans')};` **바로 다음**(로컬을 읽기 전)에 추가한다 — 변환은 클라우드만 건드리므로 로컬 구간보다 앞이어야 한다:

```dart
    // 레거시 문서(id 없음, 문서 id가 자격증 코드)는 planId 문서로 옮긴다.
    for (final e in cloud.entries.toList()) {
      if (e.value['id'] != null) continue;
      final cert = (e.value['certCode'] ?? e.key).toString();
      final created = (e.value['createdIso'] ?? '').toString();
      final id = planIdOf(cert, created, 0);
      final moved = {
        ...e.value,
        'id': id,
        'label': '기존 일정',
        'source': PlanSource.auto.name,
        'updatedAtMs': (e.value['updatedAtMs'] as num?)?.toInt() ??
            (e.value['updatedAt'] as num?)?.toInt() ??
            0,
      }..remove('updatedAt');
      await _cloud.setDoc(uid, 'plans', id, moved);
      await _cloud.deleteDoc(uid, 'plans', e.key);
      cloud.remove(e.key);
      cloud[id] = moved;
    }
```

- [ ] **Step 4: 통과 확인**

Run: `flutter test && flutter analyze`
Expected: 전부 PASS · 0건

- [ ] **Step 5: 커밋**

```bash
git branch --show-current
git add flutter_app/lib/data/cloud/sync_service.dart flutter_app/test/cloud/sync_plans_test.dart
git commit -m "feat(sync): 레거시 클라우드 일정 문서를 planId 문서로 결정적 변환

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
```

---

### Task 6: 일정 개별 삭제 전파

**Files:**
- Modify: `flutter_app/lib/data/cloud/sync_service.dart`, `flutter_app/lib/data/cloud/sync_meta.dart`
- Test: `flutter_app/test/cloud/sync_plans_test.dart`

**Interfaces:**
- Produces: `meta/deletions`의 `plans` 맵(planId → 삭제 시각)을 `_reconcileDeletions`가 함께 화해하고, `_reconcilePlans`가 그 표식으로 양쪽에서 지운다. `_reconcileDeletions`의 반환을 `({Map<String,int> resetAt, Map<String,int> plans})`로, `_reconcilePlans`의 반환을 이번 회차의 새 삭제 표식(`Map<String,int>`)으로 바꾼다.

- [ ] **Step 1: 실패 테스트 작성**

`test/cloud/sync_plans_test.dart`에 추가:

```dart
  test('로컬에서 지운 일정이 클라우드와 다른 기기에서도 사라진다', () async {
    final a = MemoryBackend(); // 기기 A
    final b = MemoryBackend(); // 기기 B
    final cloud = FakeCloudStore();
    StudyPlanStore(backend: a).add(_plan('', 'CLF-C02', 'A'));
    final id = StudyPlanStore(backend: a).plansFor('CLF-C02').single.id;
    await SyncService(local: a, cloud: cloud, nowMs: () => 1000)
        .reconcileAll('u1');
    await SyncService(local: b, cloud: cloud, nowMs: () => 1100)
        .reconcileAll('u1'); // B도 같은 일정을 받음
    expect(StudyPlanStore(backend: b).plansFor('CLF-C02'), isNotEmpty);

    StudyPlanStore(backend: a).removeById(id); // A에서 삭제
    await SyncService(local: a, cloud: cloud, nowMs: () => 2000)
        .reconcileAll('u1');
    await SyncService(local: b, cloud: cloud, nowMs: () => 2100)
        .reconcileAll('u1');

    expect(await cloud.loadCollection('u1', 'plans'), isEmpty);
    expect(StudyPlanStore(backend: b).plansFor('CLF-C02'), isEmpty);
    final marks =
        (await cloud.loadCollection('u1', 'meta'))['deletions']!['plans'];
    expect((marks as Map)[id], 2000);
  });

  test('삭제 표식이 있는 일정은 다시 올라가지 않는다', () async {
    final local = MemoryBackend();
    final cloud = FakeCloudStore();
    final p = _plan('CLF-C02:2026-09-01:0', 'CLF-C02', 'A');
    StudyPlanStore(backend: local).upsert(p);
    await cloud.setDoc('u1', 'meta', 'deletions', {
      'plans': {p.id: 4000}
    });

    await SyncService(local: local, cloud: cloud, nowMs: () => 5000)
        .reconcileAll('u1');

    expect(await cloud.loadCollection('u1', 'plans'), isEmpty);
    expect(StudyPlanStore(backend: local).plansFor('CLF-C02'), isEmpty);
  });
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/cloud/sync_plans_test.dart`
Expected: FAIL — 삭제가 전파되지 않고, B가 다시 올려 일정이 되살아난다.

- [ ] **Step 3: 구현 — 표식 저장소**

`sync_meta.dart`의 `resetAt` setter 아래에 추가:

```dart
  /// 일정별 삭제 표식(planId → UTC ms).
  Map<String, int> get deletedPlans => _intMap(_read()['deletedPlans']);

  set deletedPlans(Map<String, int> v) {
    final m = _read();
    m['deletedPlans'] = v;
    _write(m);
  }
```

- [ ] **Step 4: 구현 — 표식 화해 확장**

`_reconcileDeletions`를 교체한다:

```dart
  /// meta/deletions 화해: 자격증 초기화 표식과 일정 삭제 표식을 필드별 늦은 시각으로
  /// 합쳐 양쪽에 반영하고, 이번 회차에 적용할 표식을 돌려준다.
  /// [newPlanMarks]는 이번 회차에 로컬에서 새로 지운 일정.
  Future<({Map<String, int> resetAt, Map<String, int> plans})>
      _reconcileDeletions(String uid,
          {Map<String, int> newPlanMarks = const {}}) async {
    final doc = (await _cloud.loadCollection(uid, 'meta'))['deletions'] ??
        const <String, dynamic>{};
    final cloudReset = _intMapOf(doc['resetAt']);
    final cloudPlans = _intMapOf(doc['plans']);
    final meta = SyncMeta(_local);

    final mergedReset = mergeResetMarks(meta.resetAt, cloudReset);
    final mergedPlans = mergeResetMarks(
        mergeResetMarks(meta.deletedPlans, cloudPlans), newPlanMarks);

    if (!_sameMarks(mergedReset, meta.resetAt)) meta.resetAt = mergedReset;
    if (!_sameMarks(mergedPlans, meta.deletedPlans)) {
      meta.deletedPlans = mergedPlans;
    }
    if (!_sameMarks(mergedReset, cloudReset) ||
        !_sameMarks(mergedPlans, cloudPlans)) {
      await _cloud.setDoc(uid, 'meta', 'deletions', {
        ...doc,
        'resetAt': mergedReset,
        'plans': mergedPlans,
      });
    }
    return (resetAt: mergedReset, plans: mergedPlans);
  }

  static Map<String, int> _intMapOf(Object? v) {
    if (v is! Map) return {};
    return {
      for (final e in v.entries)
        if (e.value is num) e.key.toString(): (e.value as num).toInt(),
    };
  }
```

`reconcileAll`을 교체한다 — **일정 화해가 만든 새 표식을 다시 화해해, 같은 회차의 진행 화해(T7)가 그 표식을 보게 한다**:

```dart
  Future<void> reconcileAll(String uid) async {
    var marks = await _reconcileDeletions(uid);
    await _reconcileAttempts(uid, marks.resetAt);
    await _reconcileViewed(uid, marks.resetAt);
    final newlyDeleted = await _reconcilePlans(uid, marks);
    if (newlyDeleted.isNotEmpty) {
      marks = await _reconcileDeletions(uid, newPlanMarks: newlyDeleted);
    }
    await _reconcileLww(uid, _kChecks, 'checks', 'checks'); // 레거시(PR3에서 제거)
  }
```

- [ ] **Step 5: 구현 — 일정 화해에 표식 반영**

`_reconcilePlans`를 바꾼다:

- 시그니처:

```dart
  /// 일정(v2) 화해. 이번 회차에 새로 생긴 삭제 표식(planId → 시각)을 돌려준다.
  Future<Map<String, int>> _reconcilePlans(String uid,
      ({Map<String, int> resetAt, Map<String, int> plans}) marks) async {
```

- 함수 시작 지역변수에 `final newlyDeleted = <String, int>{};` 추가.
- 자격증 표식 참조를 `mergedEffectiveResetAt(marks.resetAt, cert)`로 바꾼다.
- 초기화 표식 블록 **다음**에 일정 표식 처리를 넣는다:

```dart
      // 일정 삭제 표식: 클라우드 문서도 함께 정리한다(로컬은 판정이 지운다).
      if (marks.plans.containsKey(id) && cloudRaw != null) toDelete.add(id);
```

- `decideDoc` 호출에 `cloudDeleted: marks.plans.containsKey(id),`를 추가한다.
- `DocAction.deleteCloud` 분기에 `newlyDeleted[id] = now;`를 추가한다.
- 마지막 `await _deleteUpTo(...)` 뒤에 `return newlyDeleted;`.

- [ ] **Step 6: 통과 확인**

Run: `flutter test && flutter analyze`
Expected: 전부 PASS · 0건. 삭제가 있는 회차만 `loadCollection`이 1회(meta 재화해) 늘어난다 — `sync_controller_test`는 삭제 없는 회차를 세므로 영향 없다.

- [ ] **Step 7: 커밋**

```bash
git branch --show-current
git add flutter_app/lib/data/cloud/sync_service.dart flutter_app/lib/data/cloud/sync_meta.dart flutter_app/test/cloud/
git commit -m "feat(sync): 일정 개별 삭제를 표식으로 전파

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
```

---

### Task 7: 진행(완료 체크) 동기와 수신

**Files:**
- Modify: `flutter_app/lib/data/cloud/sync_service.dart`, `flutter_app/lib/data/cloud/sync_controller.dart`
- Test: `flutter_app/test/cloud/sync_progress_test.dart`(신규), `flutter_app/test/cloud/sync_controller_test.dart`

**Interfaces:**
- Consumes: `mergeSets`(T2), `PlanProgressStore.readAll/setPlan`(T3), 일정 삭제 표식(T6).
- Produces: `progress/{planId}` = `{certCode, itemIds, updatedAtMs}` 화해. watch 대상에 `progress` 추가(로드 5→6회).

- [ ] **Step 1: 실패 테스트 작성**

`flutter_app/test/cloud/sync_progress_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/cloud/cloud_store.dart';
import 'package:aws_docs/data/cloud/sync_service.dart';
import 'package:aws_docs/data/plan_progress_store.dart';
import 'package:aws_docs/data/study_plan_store.dart';
import 'package:aws_docs/models/study_plan.dart';

StudyPlan _plan(String id) => StudyPlan(
      id: id,
      label: 'A',
      certCode: 'CLF-C02',
      startIso: '2026-09-01',
      endIso: '2026-10-01',
      mode: PlanMode.period,
      createdIso: '2026-09-01',
      items: const [],
    );

void main() {
  test('로컬 완료 체크가 클라우드로 올라간다', () async {
    final local = MemoryBackend();
    final cloud = FakeCloudStore();
    StudyPlanStore(backend: local).upsert(_plan('p1'));
    PlanProgressStore(backend: local).setDone('p1', 'i1', true);

    await SyncService(local: local, cloud: cloud, nowMs: () => 5000)
        .reconcileAll('u1');

    final doc = (await cloud.loadCollection('u1', 'progress'))['p1']!;
    expect((doc['itemIds'] as List).toSet(), {'i1'});
    expect(doc['certCode'], 'CLF-C02');
    expect(doc['updatedAtMs'], 5000);
  });

  test('두 기기의 서로 다른 체크·해제를 모두 반영한다(집합 3-way)', () async {
    final a = MemoryBackend();
    final b = MemoryBackend();
    final cloud = FakeCloudStore();
    for (final m in [a, b]) {
      StudyPlanStore(backend: m).upsert(_plan('p1'));
    }
    PlanProgressStore(backend: a)
      ..setDone('p1', 'i1', true)
      ..setDone('p1', 'i2', true);
    await SyncService(local: a, cloud: cloud, nowMs: () => 1000)
        .reconcileAll('u1');
    await SyncService(local: b, cloud: cloud, nowMs: () => 1100)
        .reconcileAll('u1'); // B도 {i1,i2}

    PlanProgressStore(backend: a).setDone('p1', 'i3', true); // A: 추가
    PlanProgressStore(backend: b).setDone('p1', 'i1', false); // B: 해제
    await SyncService(local: a, cloud: cloud, nowMs: () => 2000)
        .reconcileAll('u1');
    await SyncService(local: b, cloud: cloud, nowMs: () => 2100)
        .reconcileAll('u1');
    await SyncService(local: a, cloud: cloud, nowMs: () => 2200)
        .reconcileAll('u1');

    expect(PlanProgressStore(backend: a).donePlan('p1'), {'i2', 'i3'});
    expect(PlanProgressStore(backend: b).donePlan('p1'), {'i2', 'i3'});
  });

  test('일정이 삭제되면 그 진행 문서도 사라진다', () async {
    final local = MemoryBackend();
    final cloud = FakeCloudStore();
    StudyPlanStore(backend: local).upsert(_plan('p1'));
    PlanProgressStore(backend: local).setDone('p1', 'i1', true);
    await SyncService(local: local, cloud: cloud, nowMs: () => 1000)
        .reconcileAll('u1');

    StudyPlanStore(backend: local).removeById('p1');
    await SyncService(local: local, cloud: cloud, nowMs: () => 2000)
        .reconcileAll('u1');

    expect(await cloud.loadCollection('u1', 'progress'), isEmpty);
    expect(PlanProgressStore(backend: local).donePlan('p1'), isEmpty);
  });
}
```

`test/cloud/sync_controller_test.dart:135`의 로드 횟수 기대값을 6으로 바꾸고 주석도 갱신한다:

```dart
    // reconcile 1회 = loadCollection 6회(meta·attempts·viewed·plans·progress·checks).
    expect(spy.loads, 6);
```

같은 파일 144행의 주석 `// 명시 전환(loads=4)`도 `loads=6`으로 고친다 — PR1에서 meta 화해가 늘며 이미 틀어진 값이다(주석뿐이라 테스트는 통과해 왔다).

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/cloud/sync_progress_test.dart test/cloud/sync_controller_test.dart`
Expected: FAIL — `progress` 컬렉션이 비어 있고 로드도 5회.

- [ ] **Step 3: 구현 — 진행 화해**

`sync_service.dart`에 import를 추가한다:

```dart
import '../plan_progress_store.dart';
```

`reconcileAll`의 `checks` 줄 **앞**에 넣는다(일정 화해와 표식 재화해 뒤라야 이번 회차의 삭제를 본다):

```dart
    await _reconcileProgress(uid, marks);
```

화해를 추가한다(순서 규칙은 일정과 동일):

```dart
  /// 진행(완료 체크) 화해. 집합 3-way라 양쪽의 체크·해제를 모두 살린다.
  /// 일정이 지워진 진행 문서는 함께 정리한다.
  Future<void> _reconcileProgress(String uid,
      ({Map<String, int> resetAt, Map<String, int> plans}) marks) async {
    final cloud = await _cloud.loadCollection(uid, 'progress');
    final store = PlanProgressStore(backend: _local);
    final plans = StudyPlanStore(backend: _local).byId();
    final meta = SyncMeta(_local);
    final em = meta.entity('progress');
    final local = store.readAll();

    final base = {...em.base};
    final updatedAt = {...em.updatedAt};
    final toPush = <String, Map<String, dynamic>>{};
    final toDelete = <String>[];
    final now = _now();

    for (final id in {...local.keys, ...cloud.keys}) {
      final cloudRaw = cloud[id];
      final cert =
          plans[id]?.certCode ?? cloudRaw?['certCode']?.toString() ?? '';
      final cut = mergedEffectiveResetAt(marks.resetAt, cert);
      final cloudMs = (cloudRaw?['updatedAtMs'] as num?)?.toInt() ?? 0;

      // 일정이 지워졌거나(표식) 초기화 표식보다 오래된 진행은 버린다.
      if (marks.plans.containsKey(id) || (cloudRaw != null && cloudMs < cut)) {
        if (cloudRaw != null) toDelete.add(id);
        if (local.containsKey(id)) store.setPlan(id, {});
        base.remove(id);
        updatedAt.remove(id);
        continue;
      }

      final baseSet = {
        for (final x in (base[id]?['itemIds'] as List?) ?? const [])
          x.toString()
      };
      final localSet = local[id] ?? <String>{};
      final cloudSet = {
        for (final x in (cloudRaw?['itemIds'] as List?) ?? const [])
          x.toString()
      };
      final merged = mergeSets(base: baseSet, local: localSet, cloud: cloudSet);

      if (!_sameSet(merged, localSet)) store.setPlan(id, merged);
      if (merged.isEmpty) {
        if (cloudRaw != null) toDelete.add(id);
        base.remove(id);
        updatedAt.remove(id);
        continue;
      }
      if (!_sameSet(merged, cloudSet)) {
        toPush[id] = {
          'certCode': cert,
          'itemIds': merged.toList(),
          'updatedAtMs': now,
        };
        updatedAt[id] = now;
      } else {
        updatedAt[id] = cloudMs;
      }
      base[id] = {'itemIds': merged.toList()};
    }

    meta.setEntity('progress',
        EntityMeta(base: base, updatedAt: updatedAt, dirtyAt: const {}));

    for (final e in toPush.entries) {
      await _cloud.setDoc(uid, 'progress', e.key, e.value);
    }
    await _deleteUpTo(uid, 'progress', toDelete);
  }

  bool _sameSet(Set<String> a, Set<String> b) =>
      a.length == b.length && a.containsAll(b);
```

- [ ] **Step 4: 구현 — 수신**

`sync_controller.dart`의 watch 목록(`lib/data/cloud/sync_controller.dart:151`)에 `'progress'`를 넣는다:

```dart
    for (final coll in const [
      'meta',
      'attempts',
      'viewed',
      'plans',
      'progress',
      'checks'
    ]) {
```

- [ ] **Step 5: 통과 확인**

Run: `flutter test && flutter analyze`
Expected: 전부 PASS · 0건

- [ ] **Step 6: 커밋과 PR**

```bash
git branch --show-current
git add flutter_app/lib/data/cloud/ flutter_app/test/cloud/
git commit -m "feat(sync): 진행(완료 체크) 집합 3-way 동기 + 문서 변경 수신

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
git push -u origin feat/sync-v2-pr2-plans-progress
```

PR 본문에는 스펙 경로, 닫는 결함(M-9 일정 미동기·CODE-D-001·CODE-D-002·일정 개별 삭제 미전파·PR-m3 잠복 결함), 테스트 수, 남은 범위(PR3)를 적는다.

---

## 완료 기준

- `flutter test` 전부 통과, `flutter analyze` 0건, CI `test` 녹색
- 새 기기에서 로그인하면 일정과 완료 체크가 내려온다
- 한 기기에서 고친 일정이 다음 동기에 되돌아가지 않는다(PR-m3 잠복 결함 해소)
- 두 기기가 서로 다른 항목을 체크·해제해도 둘 다 반영된다
- 일정을 지우면 다른 기기에서도 사라지고, 오래된 사본이 되살리지 못한다
- 자격증 초기화 표식이 일정·진행에도 적용된다

## 알려진 한계(의도된 선택)

- **한 번도 동기되지 않은 로컬 일정은 다른 기기의 초기화 표식으로 지워지지 않는다.** 그 일정의 시각을 알 수 없어, 미동기 로컬 작업을 잃지 않는 쪽을 택했다. 동기된 뒤에는 표식이 적용된다.
- **표식 없이 클라우드 문서만 사라지면 다시 올린다.** 삭제는 항상 표식으로 오므로, 문서만 없는 상태는 이상 상황으로 보고 손실을 막는다.
- **삭제 표식은 계속 쌓인다.** 정리(오래된 표식 제거)는 PR3에서 다룬다.

## 실행 기록 (2026-09-23)

T1~T7 전부 구현 완료. 최종 `flutter test` **881 통과**(기준선 851 + 신규 30), `flutter analyze` **0건**.

플랜과 달라진 점 두 가지:

1. **`test/cloud/sync_controller_test.dart`의 수신 테스트도 고쳐야 했다**(플랜 누락). `signIn: reconcile로 클라우드 plan이 로컬에 내려옴`이 레거시 계약(클라우드 `plans/{cert}` → 로컬 `awsdocs.plan.v1` 블롭)을 검증하고 있어 T4에서 깨졌다. v2 계약(`StudyPlanStore.plansFor`)으로 바꿨고, 그러면서 불필요해진 `dart:convert`·`local_kv` import를 정리했다(`unnecessary_import` 경고 1건 해소).
2. **`plan LWW — 로컬이 최신이면 push` 회귀를 지우지 않고 checks로 옮겼다.** 플랜은 삭제를 지시했지만, 그러면 "사이드카 없는 로컬 엔티티를 now로 스탬프 후 push"하는 LWW 동작의 회귀가 사라진다. 그 경로는 checks가 계속 쓰므로 `reconcileAll: checks LWW — 사이드카 없던 로컬은 now로 스탬프 후 push`로 보존했다.

## 다음 플랜

- **PR3**: checks 동기 제외·클라우드 1회 정리, 레거시 LWW 경로와 옛 사이드카(`awsdocs.sync.v1`)·로컬 `awsdocs.plan.v1` 정리, 동기 경로 관용 파싱, 비로그인 과거 동기 안내 문구, 삭제 표식 정리 규칙, `firestore.rules` 레포 관리와 에뮬레이터 테스트
