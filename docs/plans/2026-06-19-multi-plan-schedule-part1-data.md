# 멀티 일정 — 데이터·진행 계층 구현 Plan (Part 1/2)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 멀티 일정의 데이터·진행 계층을 만든다 — `StudyPlan` 확장, planId 기반 itemId, 수동 일정 빌더, 자격증당 일정 리스트 저장소(+v1→v2 마이그레이션), 일정별 진행 저장소, planId 스코프 진행 판정. UI는 Part 2.

**Architecture:** `StudyPlan`에 `id/label/source/planType/taskIds`를 더한다. itemId를 certCode 기반에서 planId 기반으로 바꿔 일정 간 충돌을 없앤다. 진행은 자격증 전역 store(ViewedDocs/PlanCheck) 대신 신규 `PlanProgressStore`(planId→완료 itemId 집합)로 옮긴다. 저장소는 `certCode→List<StudyPlan>`로 바꾸고 기존 단일 plan을 자동 이관한다.

**Tech Stack:** Dart, flutter_test, `MemoryBackend`(KvBackend 주입), JSON 직렬화.

## Global Constraints

- 모든 명령은 `flutter_app/` 기준. 변경 후 `flutter test` 전부 통과, `flutter analyze` 신규 0건.
- 기존 테스트(현재 그린)를 깨지 않는다. 특히 `plan_scheduler_test`, `plan_progress_test`, `study_plan_model_test`, `study_plan_store_test`, `plan_check_store_test`, `plan_agenda_summary_test`.
- TDD(절대조건 2): 실패 테스트를 먼저 작성하고 실패를 눈으로 확인한 뒤 최소 구현한다.
- 순수 Dart/데이터만 — 위젯 변경 없음(Part 2).
- 마이그레이션 시 기존 일정의 **진행은 초기화된다**(새 PlanProgressStore로 시작). 이는 사용자 의도(#2)와 부합하며 v1 사용자는 드물다.

## File Structure

- Modify: `lib/models/study_plan.dart` — `PlanSource` enum, `StudyPlan` 필드 추가, `planItemId` 헬퍼
- Modify: `lib/data/plan_scheduler.dart` — `buildPlan`가 planId 기반 itemId 생성, 신규 `buildManualPlanItems`
- Modify: `lib/data/study_plan_store.dart` — `certCode→List<StudyPlan>`, v1→v2 마이그레이션, CRUD
- Create: `lib/data/plan_progress_store.dart` — `PlanProgressStore`(planId→Set<itemId>)
- Modify: `lib/data/plan_progress.dart` — `computePlanDone`가 `PlanProgressStore` 기반(planId 스코프)
- Modify: `lib/data/study_reset.dart` — `PlanProgressStore`도 초기화 대상에 포함
- Tests: `test/study_plan_model_test.dart`, `test/plan_scheduler_test.dart`, `test/study_plan_store_test.dart`, `test/plan_progress_store_test.dart`(신규), `test/plan_progress_test.dart`

---

### Task 1: StudyPlan 모델 확장 + planId/itemId 헬퍼

**Files:**
- Modify: `lib/models/study_plan.dart`
- Test: `test/study_plan_model_test.dart`

**Interfaces:**
- Produces:
  - `enum PlanSource { auto, manual }`
  - `String planIdOf(String certCode, String createdIso, int seq)` → `'$certCode:$createdIso:$seq'`
  - `String planItemId(String planId, PlanItemType type, String? refId, int i)` → `'$planId#${type.name}:${refId ?? ''}:$i'`
  - `StudyPlan` 신규 필드: `id`(required), `label`(default `''`), `source`(default `PlanSource.auto`), `planType`(`PlanItemType?`), `taskIds`(`List<String>` default `const []`). 기존 필드(`certCode/startIso/endIso/mode/createdIso/items`) 유지.

- [ ] **Step 1: 실패 테스트 작성** — `test/study_plan_model_test.dart`에 추가:

```dart
import 'package:aws_docs/models/study_plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('planIdOf / planItemId 결정적 포맷', () {
    expect(planIdOf('CLF-C02', '2026-06-19', 0), 'CLF-C02:2026-06-19:0');
    expect(planItemId('CLF-C02:2026-06-19:0', PlanItemType.doc, 'clf-t1-1', 2),
        'CLF-C02:2026-06-19:0#doc:clf-t1-1:2');
    expect(planItemId('p1', PlanItemType.mockExam, null, 0), 'p1#mockExam::0');
  });

  test('StudyPlan 신규 필드 round-trip', () {
    final p = StudyPlan(
      id: 'CLF-C02:2026-06-19:0',
      label: '1주차 문서',
      certCode: 'CLF-C02',
      startIso: '2026-06-19',
      endIso: '2026-06-26',
      mode: PlanMode.period,
      createdIso: '2026-06-19',
      source: PlanSource.manual,
      planType: PlanItemType.doc,
      taskIds: const ['clf-t1-1', 'clf-t1-2'],
      items: const [],
    );
    final back = StudyPlan.fromJson(p.toJson());
    expect(back.id, p.id);
    expect(back.label, '1주차 문서');
    expect(back.source, PlanSource.manual);
    expect(back.planType, PlanItemType.doc);
    expect(back.taskIds, ['clf-t1-1', 'clf-t1-2']);
  });

  test('레거시 JSON(id/source 없음)도 안전 — auto/빈 기본값', () {
    final legacy = {
      'certCode': 'CLF-C02', 'startIso': '2026-06-01', 'endIso': '2026-06-15',
      'mode': 'period', 'createdIso': '2026-06-01', 'items': [],
    };
    final p = StudyPlan.fromJson(legacy);
    expect(p.source, PlanSource.auto);
    expect(p.taskIds, isEmpty);
    expect(p.planType, isNull);
    expect(p.id, ''); // 마이그레이션 단계(Task 3)에서 부여
  });
}
```

- [ ] **Step 2: 실패 확인** — Run: `flutter test test/study_plan_model_test.dart`. Expected: 컴파일 실패(`planIdOf` 등 미정의).

- [ ] **Step 3: 최소 구현** — `lib/models/study_plan.dart` 수정:
  - 파일 상단에 enum 추가: `enum PlanSource { auto, manual }`
  - 헬퍼 추가:
    ```dart
    String planIdOf(String certCode, String createdIso, int seq) =>
        '$certCode:$createdIso:$seq';

    String planItemId(String planId, PlanItemType type, String? refId, int i) =>
        '$planId#${type.name}:${refId ?? ''}:$i';
    ```
  - `StudyPlan` 클래스에 필드 추가(생성자 파라미터 포함). `toJson`에 `'id','label','source','planType','taskIds'` 추가, `fromJson`에 대응 파싱:
    ```dart
    id: (j['id'] ?? '').toString(),
    label: (j['label'] ?? '').toString(),
    source: _enumByName(PlanSource.values, j['source'], PlanSource.auto),
    planType: j['planType'] == null
        ? null
        : _enumByName(PlanItemType.values, j['planType'], PlanItemType.doc),
    taskIds: ((j['taskIds'] as List?) ?? const [])
        .map((e) => e.toString()).toList(),
    ```
    (`planType` toJson은 `planType?.name`.)

- [ ] **Step 4: 통과 확인** — Run: `flutter test test/study_plan_model_test.dart`. Expected: PASS.

- [ ] **Step 5: 커밋**

```bash
git add lib/models/study_plan.dart test/study_plan_model_test.dart
git commit -m "feat(plan): StudyPlan에 id/label/source/planType/taskIds + itemId 헬퍼"
```

---

### Task 2: 빌더 — buildPlan을 planId 기반으로 + 수동 빌더

**Files:**
- Modify: `lib/data/plan_scheduler.dart`
- Test: `test/plan_scheduler_test.dart`

**Interfaces:**
- Consumes: `planItemId`, `PlanSource`, `StudyPlan`(Task 1)
- Produces:
  - `buildPlan({required String planId, required List<ContentEntry> content, required String startIso, required String endIso, required PlanMode mode})` — 기존 `certCode` 파라미터를 `planId`로 교체. 내부 `_spread`의 itemId가 `planItemId(planId, type, refId, i)`.
  - `List<PlanItem> buildManualPlanItems({required String planId, required PlanItemType planType, required List<String> taskIds, required String startIso, required String endIso})` — 수동 일정의 items 생성.

- [ ] **Step 1: 실패 테스트 작성** — `test/plan_scheduler_test.dart`에 추가:

```dart
test('buildManualPlanItems — 문서 유형은 taskIds를 기간에 분배', () {
  final items = buildManualPlanItems(
    planId: 'p1',
    planType: PlanItemType.doc,
    taskIds: const ['clf-t1-1', 'clf-t1-2', 'clf-t1-3'],
    startIso: '2026-06-19',
    endIso: '2026-06-25',
  );
  expect(items.length, 3);
  expect(items.every((i) => i.type == PlanItemType.doc), isTrue);
  expect(items.map((i) => i.refId), ['clf-t1-1', 'clf-t1-2', 'clf-t1-3']);
  expect(items.first.id, startsWith('p1#doc:clf-t1-1:'));
  // 기간 내 분배
  expect(items.first.dateIso.compareTo('2026-06-19') >= 0, isTrue);
  expect(items.last.dateIso.compareTo('2026-06-25') <= 0, isTrue);
});

test('buildManualPlanItems — 모의고사 유형은 refId 없는 단일 항목', () {
  final items = buildManualPlanItems(
    planId: 'p2', planType: PlanItemType.mockExam, taskIds: const [],
    startIso: '2026-06-19', endIso: '2026-06-19',
  );
  expect(items.length, 1);
  expect(items.single.type, PlanItemType.mockExam);
  expect(items.single.refId, isNull);
});

test('buildPlan은 planId 기반 itemId를 만든다', () {
  final r = buildPlan(
    planId: 'CLF-C02:2026-06-19:0',
    content: const [],
    startIso: '2026-06-19', endIso: '2026-06-20', mode: PlanMode.period,
  );
  // content 비면 경고만(기존 동작 보존)
  expect(r.items, isEmpty);
  expect(r.warnings, isNotEmpty);
});
```

- [ ] **Step 2: 실패 확인** — Run: `flutter test test/plan_scheduler_test.dart`. Expected: 컴파일 실패(`buildManualPlanItems` 미정의, `buildPlan` 시그니처 불일치). 기존 `buildPlan(certCode:...)` 호출처(plan_create_form 등)도 깨지므로 Step 3에서 함께 갱신.

- [ ] **Step 3: 최소 구현** — `lib/data/plan_scheduler.dart`:
  - `buildPlan`의 파라미터 `required String certCode` → `required String planId`로 바꾸고, 본문에서 `certCode`를 쓰던 곳(`_spread` 호출의 첫 인자)을 `planId`로 교체.
  - `_spread`의 itemId 생성 라인을 교체:
    ```dart
    // 기존: id: '$certCode:${type.name}:${refId ?? ''}:$i',
    id: planItemId(planId, type, refId, i),
    ```
    (`_spread`의 `certCode` 파라미터명을 `planId`로 바꾼다.)
  - 신규 함수 추가:
    ```dart
    /// 수동 일정의 items 생성(순수). docs/practice는 taskIds를 기간에 균등 분배,
    /// 시험류(mock/weak/review)는 refId 없는 단일 항목.
    List<PlanItem> buildManualPlanItems({
      required String planId,
      required PlanItemType planType,
      required List<String> taskIds,
      required String startIso,
      required String endIso,
    }) {
      final lastDay = endIso;
      final windowDays = daysBetween(startIso, lastDay) + 1; // >=1
      final out = <PlanItem>[];
      final phase = switch (planType) {
        PlanItemType.doc => PlanPhase.learn,
        PlanItemType.quiz => PlanPhase.practice,
        PlanItemType.mockExam => PlanPhase.mock,
        _ => PlanPhase.reinforce,
      };
      final refs = (planType == PlanItemType.doc || planType == PlanItemType.quiz)
          ? taskIds
          : <String?>[null];
      final k = refs.length;
      for (var i = 0; i < k; i++) {
        var off = (windowDays <= 1 || k <= 1) ? 0 : (i * windowDays ~/ k);
        if (off > windowDays - 1) off = windowDays - 1;
        out.add(PlanItem(
          id: planItemId(planId, planType, refs[i], i),
          dateIso: addDays(startIso, off),
          type: planType,
          phase: phase,
          refId: refs[i],
        ));
      }
      return out;
    }
    ```
  - `buildPlan` 호출처 임시 수정: `plan_create_form.dart`의 `buildPlan(certCode: widget.cert.code, ...)` → `buildPlan(planId: widget.cert.code, ...)` (Part 2에서 올바른 planId로 교체; 지금은 컴파일·기존 테스트 통과 목적).

- [ ] **Step 4: 통과 확인** — Run: `flutter test test/plan_scheduler_test.dart`. Expected: PASS. 그리고 `flutter test`로 전체 회귀(plan_scheduler 의존 테스트 포함) 확인.

- [ ] **Step 5: 커밋**

```bash
git add lib/data/plan_scheduler.dart lib/pages/plan/plan_create_form.dart test/plan_scheduler_test.dart
git commit -m "feat(plan): buildPlan planId 기반 itemId + buildManualPlanItems"
```

---

### Task 3: StudyPlanStore 리스트화 + v1→v2 마이그레이션

**Files:**
- Modify: `lib/data/study_plan_store.dart`
- Test: `test/study_plan_store_test.dart`

**Interfaces:**
- Consumes: `StudyPlan`, `planIdOf`(Task 1)
- Produces (StudyPlanStore 새 API):
  - `List<StudyPlan> plansFor(String certCode)` — 빈 리스트 가능
  - `void add(StudyPlan plan)` — 리스트에 추가(id 비어있으면 `planIdOf(certCode, createdIso, 현재 길이)`로 부여)
  - `void update(StudyPlan plan)` — 같은 id 교체
  - `void removePlan(String certCode, String planId)`
  - `void clearCert(String certCode)` / `void clearAll()` 유지
  - 내부: v1 키(`awsdocs.plan.v1`, 단일 `{certCode: plan}`)를 읽어 v2(`awsdocs.plan.v2`, `{certCode: [plan]}`)로 1회 이관. 이관 시 plan에 `id=planIdOf(cert, createdIso, 0)`, `label='기존 일정'`, `source=auto` 부여.

- [ ] **Step 1: 실패 테스트 작성** — `test/study_plan_store_test.dart` 재작성/추가:

```dart
import 'dart:convert';
import 'package:aws_docs/data/study_plan_store.dart';
import 'package:aws_docs/models/study_plan.dart';
import 'package:flutter_test/flutter_test.dart';

StudyPlan _plan(String id, String cert, {String label = ''}) => StudyPlan(
      id: id, label: label, certCode: cert,
      startIso: '2026-06-19', endIso: '2026-06-26',
      mode: PlanMode.period, createdIso: '2026-06-19', items: const []);

void main() {
  test('add/plansFor/update/removePlan', () {
    final b = MemoryBackend();
    final s = StudyPlanStore(backend: b);
    expect(s.plansFor('CLF-C02'), isEmpty);

    s.add(_plan('', 'CLF-C02', label: 'A')); // id 자동 부여
    final after = s.plansFor('CLF-C02');
    expect(after.length, 1);
    expect(after.first.id, isNotEmpty);
    expect(after.first.label, 'A');

    final id = after.first.id;
    s.update(StudyPlan(
      id: id, label: 'A2', certCode: 'CLF-C02', startIso: '2026-06-19',
      endIso: '2026-06-26', mode: PlanMode.period, createdIso: '2026-06-19',
      items: const []));
    expect(s.plansFor('CLF-C02').single.label, 'A2');

    s.removePlan('CLF-C02', id);
    expect(s.plansFor('CLF-C02'), isEmpty);
  });

  test('두 일정이 독립적으로 공존', () {
    final s = StudyPlanStore(backend: MemoryBackend());
    s.add(_plan('', 'CLF-C02', label: 'A'));
    s.add(_plan('', 'CLF-C02', label: 'B'));
    expect(s.plansFor('CLF-C02').map((p) => p.label), ['A', 'B']);
  });

  test('v1 단일 plan을 v2 리스트로 마이그레이션', () {
    final b = MemoryBackend();
    // v1 형식 주입
    b.write('awsdocs.plan.v1', jsonEncode({
      'CLF-C02': {
        'certCode': 'CLF-C02', 'startIso': '2026-06-01', 'endIso': '2026-06-15',
        'mode': 'period', 'createdIso': '2026-06-01', 'items': [],
      }
    }));
    final s = StudyPlanStore(backend: b);
    final plans = s.plansFor('CLF-C02');
    expect(plans.length, 1);
    expect(plans.first.id, isNotEmpty);
    expect(plans.first.source, PlanSource.auto);
    // v2 키에 기록됐는지
    expect(b.read('awsdocs.plan.v2'), isNotNull);
  });
}
```

- [ ] **Step 2: 실패 확인** — Run: `flutter test test/study_plan_store_test.dart`. Expected: 실패(`plansFor/add/...` 미정의).

- [ ] **Step 3: 최소 구현** — `lib/data/study_plan_store.dart` 재작성:

```dart
import 'dart:convert';
import '../models/study_plan.dart';
import 'local_kv.dart';

export 'local_kv.dart' show KvBackend, MemoryBackend, defaultBackend;

/// 자격증별 학습 플랜 '리스트'를 영속한다(v2). v1(단일)을 1회 이관한다.
class StudyPlanStore {
  StudyPlanStore({KvBackend? backend}) : _b = backend ?? defaultBackend() {
    _migrateV1IfNeeded();
  }

  final KvBackend _b;
  static const _key = 'awsdocs.plan.v2';
  static const _keyV1 = 'awsdocs.plan.v1';

  Map<String, dynamic> _read() {
    final raw = _b.read(_key);
    if (raw == null || raw.isEmpty) return {};
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  void _write(Map<String, dynamic> m) => _b.write(_key, jsonEncode(m));

  void _migrateV1IfNeeded() {
    if ((_b.read(_key) ?? '').isNotEmpty) return; // 이미 v2 있음
    final rawV1 = _b.read(_keyV1);
    if (rawV1 == null || rawV1.isEmpty) return;
    try {
      final v1 = jsonDecode(rawV1) as Map<String, dynamic>;
      final out = <String, dynamic>{};
      for (final e in v1.entries) {
        if (e.value is! Map) continue;
        final j = Map<String, dynamic>.from(e.value as Map);
        final created = (j['createdIso'] ?? '').toString();
        j['id'] = planIdOf(e.key, created, 0);
        j['label'] = '기존 일정';
        j['source'] = PlanSource.auto.name;
        out[e.key] = [j];
      }
      _write(out);
    } catch (_) {/* 손상 v1 무시 */}
  }

  List<StudyPlan> plansFor(String certCode) {
    final list = _read()[certCode];
    if (list is! List) return [];
    final out = <StudyPlan>[];
    for (final j in list) {
      if (j is! Map<String, dynamic>) continue;
      try {
        final p = StudyPlan.fromJson(j);
        if (p.startIso.isEmpty || p.endIso.isEmpty) continue;
        out.add(p);
      } catch (_) {/* 손상 항목 무시 */}
    }
    return out;
  }

  void add(StudyPlan plan) {
    final m = _read();
    final list = (m[plan.certCode] is List)
        ? List<dynamic>.from(m[plan.certCode] as List)
        : <dynamic>[];
    final id = plan.id.isNotEmpty
        ? plan.id
        : planIdOf(plan.certCode, plan.createdIso, list.length);
    final withId = StudyPlan(
      id: id, label: plan.label, certCode: plan.certCode,
      startIso: plan.startIso, endIso: plan.endIso, mode: plan.mode,
      createdIso: plan.createdIso, source: plan.source,
      planType: plan.planType, taskIds: plan.taskIds, items: plan.items);
    list.add(withId.toJson());
    m[plan.certCode] = list;
    _write(m);
  }

  void update(StudyPlan plan) {
    final m = _read();
    final list = (m[plan.certCode] is List)
        ? List<dynamic>.from(m[plan.certCode] as List)
        : <dynamic>[];
    for (var i = 0; i < list.length; i++) {
      final j = list[i];
      if (j is Map && j['id'] == plan.id) {
        list[i] = plan.toJson();
        break;
      }
    }
    m[plan.certCode] = list;
    _write(m);
  }

  void removePlan(String certCode, String planId) {
    final m = _read();
    final list = (m[certCode] is List)
        ? List<dynamic>.from(m[certCode] as List)
        : <dynamic>[];
    list.removeWhere((j) => j is Map && j['id'] == planId);
    if (list.isEmpty) {
      m.remove(certCode);
    } else {
      m[certCode] = list;
    }
    _write(m);
  }

  void clearCert(String certCode) {
    final m = _read()..remove(certCode);
    _write(m);
  }

  void clearAll() => _b.write(_key, '');
}
```

- [ ] **Step 4: 통과 확인** — Run: `flutter test test/study_plan_store_test.dart`. Expected: PASS. (`planFor`(단수)를 쓰던 호출처 `plan_page.dart`는 Part 2에서 교체 — 이 Task에서 컴파일 오류가 나면 plan_page는 Part 2 대상이므로, 전체 `flutter test`는 Part 2 전까지 plan_page 위젯 테스트가 깨질 수 있음. **이 Task의 통과 기준은 해당 store 테스트 파일 단독 통과**로 한다. 전체 그린은 Part 2 완료 시.)

- [ ] **Step 5: 커밋**

```bash
git add lib/data/study_plan_store.dart test/study_plan_store_test.dart
git commit -m "feat(plan): StudyPlanStore 리스트화(v2) + v1 단일 plan 마이그레이션"
```

---

### Task 4: PlanProgressStore + 진행 판정 planId 스코프 + reset 연결

**Files:**
- Create: `lib/data/plan_progress_store.dart`
- Modify: `lib/data/plan_progress.dart`
- Modify: `lib/data/study_reset.dart`
- Test: `test/plan_progress_store_test.dart`(신규), `test/plan_progress_test.dart`

**Interfaces:**
- Consumes: `KvBackend`, `StudyPlan`, `PlanItemType`
- Produces:
  - `PlanProgressStore`: `Set<String> donePlan(String planId)`, `void setDone(String planId, String itemId, bool done)`, `void clearPlan(String planId)`, `void clearAll()`
  - `computePlanDone(StudyPlan plan, {required Set<String> done, required List<AttemptRecord> history})` — 기존 `manual`/`viewedTaskIds` 파라미터를 제거하고 `done`(PlanProgressStore에서 온 planId 완료 집합)으로 대체. doc 완료 = `done.contains(itemId)`. 퀴즈/시험류는 기존 자동 감지 유지하되 `done`이 우선.

- [ ] **Step 1: 실패 테스트 작성** — `test/plan_progress_store_test.dart`(신규):

```dart
import 'package:aws_docs/data/plan_progress_store.dart';
import 'package:aws_docs/data/local_kv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('setDone/donePlan/clearPlan — planId 격리', () {
    final s = PlanProgressStore(backend: MemoryBackend());
    s.setDone('p1', 'p1#doc:clf-t1-1:0', true);
    s.setDone('p2', 'p2#doc:clf-t1-1:0', true);
    expect(s.donePlan('p1'), {'p1#doc:clf-t1-1:0'});
    expect(s.donePlan('p2'), {'p2#doc:clf-t1-1:0'});

    s.clearPlan('p1'); // p1만 초기화
    expect(s.donePlan('p1'), isEmpty);
    expect(s.donePlan('p2'), {'p2#doc:clf-t1-1:0'}); // p2 보존
  });

  test('setDone false는 제거', () {
    final s = PlanProgressStore(backend: MemoryBackend());
    s.setDone('p1', 'x', true);
    s.setDone('p1', 'x', false);
    expect(s.donePlan('p1'), isEmpty);
  });
}
```

  그리고 `test/plan_progress_test.dart`의 기존 호출을 새 시그니처로 갱신하고 케이스 추가:

```dart
test('computePlanDone — done 집합의 doc만 완료', () {
  final plan = StudyPlan(
    id: 'p1', certCode: 'CLF-C02', startIso: '2026-06-19', endIso: '2026-06-26',
    mode: PlanMode.period, createdIso: '2026-06-19',
    items: [
      PlanItem(id: 'p1#doc:clf-t1-1:0', dateIso: '2026-06-19',
          type: PlanItemType.doc, phase: PlanPhase.learn, refId: 'clf-t1-1'),
      PlanItem(id: 'p1#doc:clf-t1-2:1', dateIso: '2026-06-20',
          type: PlanItemType.doc, phase: PlanPhase.learn, refId: 'clf-t1-2'),
    ],
  );
  final done = computePlanDone(plan, done: {'p1#doc:clf-t1-1:0'}, history: const []);
  expect(done['p1#doc:clf-t1-1:0'], isTrue);
  expect(done['p1#doc:clf-t1-2:1'], isFalse);
});
```

- [ ] **Step 2: 실패 확인** — Run: `flutter test test/plan_progress_store_test.dart test/plan_progress_test.dart`. Expected: 실패(`PlanProgressStore` 미정의, `computePlanDone` 시그니처 불일치).

- [ ] **Step 3: 최소 구현**
  - Create `lib/data/plan_progress_store.dart`:
    ```dart
    import 'dart:convert';
    import 'local_kv.dart';
    export 'local_kv.dart' show KvBackend, MemoryBackend, defaultBackend;

    /// 일정별(planId) 완료 itemId 집합. 일정 삭제 시 해당 planId만 비운다.
    class PlanProgressStore {
      PlanProgressStore({KvBackend? backend}) : _b = backend ?? defaultBackend();
      final KvBackend _b;
      static const _key = 'awsdocs.plan.progress.v1';

      Map<String, dynamic> _read() {
        final raw = _b.read(_key);
        if (raw == null || raw.isEmpty) return {};
        try { return jsonDecode(raw) as Map<String, dynamic>; }
        catch (_) { return {}; }
      }

      Set<String> donePlan(String planId) {
        final l = _read()[planId];
        if (l is! List) return {};
        return {for (final x in l) x.toString()};
      }

      void setDone(String planId, String itemId, bool done) {
        final m = _read();
        final set = donePlan(planId);
        if (done) { set.add(itemId); } else { set.remove(itemId); }
        if (set.isEmpty) { m.remove(planId); } else { m[planId] = set.toList(); }
        _b.write(_key, jsonEncode(m));
      }

      void clearPlan(String planId) {
        final m = _read()..remove(planId);
        _b.write(_key, jsonEncode(m));
      }

      void clearAll() => _b.write(_key, '');
    }
    ```
  - Modify `lib/data/plan_progress.dart` `computePlanDone`: 파라미터를 `{required Set<String> done, required List<AttemptRecord> history}`로 바꾼다. 본문에서 `manual[it.id]` 분기를 `done.contains(it.id)` 우선으로 바꾸고, doc 분기를 `result[it.id] = done.contains(it.id)`로, 퀴즈/시험류는 `done.contains(it.id) || <기존 자동 감지>`로 둔다. `viewedTaskIds` 사용 제거.
  - Modify `lib/data/study_reset.dart`: `resetCert`/`resetAll`에 `PlanProgressStore(backend: b).clearAll()` 추가(또는 cert별은 해당 cert의 planId들을 store에서 조회해 clearPlan — 단순화를 위해 `resetAll`엔 clearAll, `resetCert`엔 그 cert의 plan id들 순회). import 추가.

- [ ] **Step 4: 통과 확인** — Run: `flutter test test/plan_progress_store_test.dart test/plan_progress_test.dart`. Expected: PASS. (computePlanDone 호출처 plan_agenda는 Part 2에서 갱신.)

- [ ] **Step 5: 커밋**

```bash
git add lib/data/plan_progress_store.dart lib/data/plan_progress.dart lib/data/study_reset.dart test/plan_progress_store_test.dart test/plan_progress_test.dart
git commit -m "feat(plan): PlanProgressStore(planId별 진행) + computePlanDone planId 스코프 + reset 연결"
```

---

## Self-Review (작성자 점검 완료)

- **Spec 커버리지(Part 1 범위)**: 모델 확장(Task1), 수동 빌더·planId itemId(Task2), 리스트 저장·마이그레이션(Task3), 일정별 진행·초기화(Task4) — spec §4·§5(진행/초기화)·§7(마이그레이션) 데이터 측면 모두 task로 커버. UI(§6)와 자동/수동 생성 진입(§5 UI)·plan_page/plan_agenda 배선은 **Part 2**.
- **타입 일관성**: `planIdOf`/`planItemId`/`PlanSource`/`PlanProgressStore.donePlan/setDone/clearPlan`/`computePlanDone(done:history:)` 시그니처가 Task 간 일치.
- **알려진 임시 상태**: Task 2~4에서 `plan_page.dart`·`plan_agenda.dart`가 옛 API(`planFor`, `computePlanDone(manual:viewedTaskIds:)`)를 참조해 **전체 `flutter test`는 Part 2 완료 시 그린**이 된다. 각 Task의 통과 기준은 해당 테스트 파일 단독 통과 + 데이터 레이어 테스트. 이는 Part 1/Part 2 분리의 의도된 결과다.

## 다음 (Part 2 — UI 계층, 별도 plan)
일정 목록→선택 어젠다, 수동 생성 폼(유형+Task 다중선택), plan_page/plan_agenda를 새 store·진행 API로 배선, 자동 생성 통합, 일정 삭제 시 `clearPlan` 연결, 전체 `flutter test` 그린 복구.
