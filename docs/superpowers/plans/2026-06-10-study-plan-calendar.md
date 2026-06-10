# 학습 일정/달력 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 자격증 시험일/기간을 정하면 학습문서·연습·모의고사를 단계형으로 분배해 어젠다 달력에 표기하고, 열람·응시 데이터로 진행을 자동 감지(+수동 보정)하는 기능.

**Architecture:** 순수 함수 엔진(`buildPlan`/`computePlanDone`/`redistribute`)이 데이터를 만들고, 로컬 저장소 2종(`StudyPlanStore`·`PlanCheckStore`)이 영속하며, `PlanPage`가 생성 폼·어젠다·월뷰를 렌더한다. 기존 `local_kv`·순수-엔진·`go_router` 패턴을 그대로 따른다.

**Tech Stack:** Flutter Web (Dart), go_router(해시), `local_kv`(localStorage), `flutter_test`.

**Spec:** `docs/superpowers/specs/2026-06-10-study-plan-calendar-design.md`
**Branch:** `feat/study-plan-calendar` (스펙 커밋 `bbff62e`)

**검증 명령(모든 Task 끝):** `cd flutter_app && flutter analyze lib && flutter test`

---

## 파일 구조

| 파일 | 책임 | Task |
|---|---|---|
| `lib/models/study_plan.dart` | `StudyPlan`·`PlanItem`·열거형 + JSON | 1 |
| `lib/data/study_plan_store.dart` | 플랜 영속(`awsdocs.plan.v1`) | 2 |
| `lib/data/plan_check_store.dart` | 수동 완료 오버라이드(`awsdocs.plan.checks.v1`) | 3 |
| `lib/data/plan_scheduler.dart` | 날짜 헬퍼 + `buildPlan` + `redistribute` | 4, 8 |
| `lib/data/plan_progress.dart` | `computePlanDone`·`isOverdue` | 5 |
| `lib/pages/plan_page.dart` | 생성/편집 폼 + 어젠다 + 월뷰 | 6, 7, 10 |
| `lib/app_router.dart` (수정) | `/cert/:code/plan` 라우트 | 6 |
| `lib/pages/cert_detail_page.dart` (수정) | "학습 일정" 진입 카드 | 6 |
| `lib/data/study_reset.dart` (수정) | 리셋 시 플랜·체크 정리 | 9 |
| `test/study_plan_model_test.dart` 외 | 단위 테스트 | 각 Task |

> 날짜는 **로컬 날짜 문자열 `YYYY-MM-DD`** 로만 다룬다(시·분 없음). 엔진은 날짜를 파라미터로 받아 순수하게 유지하고, "오늘"은 UI에서 `DateTime.now().toIso8601String().substring(0,10)` 으로 주입한다.

---

## Task 1: StudyPlan 모델

**Files:**
- Create: `flutter_app/lib/models/study_plan.dart`
- Test: `flutter_app/test/study_plan_model_test.dart`

- [ ] **Step 1: 실패 테스트 작성**

```dart
// flutter_app/test/study_plan_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/models/study_plan.dart';

void main() {
  test('PlanItem JSON 왕복', () {
    const it = PlanItem(
      id: 'CLF-C02:doc:clf-t1-1:0',
      dateIso: '2026-06-12',
      type: PlanItemType.doc,
      phase: PlanPhase.learn,
      refId: 'clf-t1-1',
    );
    final back = PlanItem.fromJson(it.toJson());
    expect(back.id, it.id);
    expect(back.dateIso, '2026-06-12');
    expect(back.type, PlanItemType.doc);
    expect(back.phase, PlanPhase.learn);
    expect(back.refId, 'clf-t1-1');
  });

  test('StudyPlan JSON 왕복', () {
    final plan = StudyPlan(
      certCode: 'CLF-C02',
      startIso: '2026-06-10',
      endIso: '2026-06-24',
      mode: PlanMode.examDate,
      createdIso: '2026-06-10',
      items: const [
        PlanItem(
          id: 'CLF-C02:mockExam::0',
          dateIso: '2026-06-20',
          type: PlanItemType.mockExam,
          phase: PlanPhase.mock,
        ),
      ],
    );
    final back = StudyPlan.fromJson(plan.toJson());
    expect(back.certCode, 'CLF-C02');
    expect(back.mode, PlanMode.examDate);
    expect(back.items.single.type, PlanItemType.mockExam);
    expect(back.items.single.refId, isNull);
  });

  test('알 수 없는 enum/결손 필드는 안전 기본값', () {
    final it = PlanItem.fromJson({'id': 'x', 'dateIso': '2026-01-01', 'type': '몰라', 'phase': null});
    expect(it.type, PlanItemType.doc); // fallback
    expect(it.phase, PlanPhase.learn); // fallback
    expect(it.refId, isNull);
    final p = StudyPlan.fromJson({'certCode': 'CLF-C02'});
    expect(p.mode, PlanMode.period); // fallback
    expect(p.items, isEmpty);
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `cd flutter_app && flutter test test/study_plan_model_test.dart`
Expected: FAIL — `study_plan.dart` 미존재(컴파일 에러).

- [ ] **Step 3: 모델 구현**

```dart
// flutter_app/lib/models/study_plan.dart

/// 일정 항목 종류. finalReview = 마지막 '최종 점검'(앱 history 'review' 모드와 구분).
enum PlanItemType { doc, quiz, mockExam, weakExam, finalReview }

/// 단계형 분배의 단계.
enum PlanPhase { learn, practice, mock, reinforce }

/// 종료 정의 방식.
enum PlanMode { examDate, period }

T _enumByName<T extends Enum>(List<T> values, Object? name, T fallback) {
  for (final v in values) {
    if (v.name == name) return v;
  }
  return fallback;
}

/// 달력의 한 항목. id는 결정적(수동 체크 오버라이드 키로 안정적).
class PlanItem {
  const PlanItem({
    required this.id,
    required this.dateIso,
    required this.type,
    required this.phase,
    this.refId,
  });

  final String id;
  final String dateIso; // 'YYYY-MM-DD'
  final PlanItemType type;
  final PlanPhase phase;
  final String? refId; // doc/quiz=taskId, 시험류=null

  Map<String, dynamic> toJson() => {
        'id': id,
        'dateIso': dateIso,
        'type': type.name,
        'phase': phase.name,
        'refId': refId,
      };

  factory PlanItem.fromJson(Map<String, dynamic> j) => PlanItem(
        id: (j['id'] ?? '').toString(),
        dateIso: (j['dateIso'] ?? '').toString(),
        type: _enumByName(PlanItemType.values, j['type'], PlanItemType.doc),
        phase: _enumByName(PlanPhase.values, j['phase'], PlanPhase.learn),
        refId: j['refId']?.toString(),
      );
}

/// 자격증별 단일 학습 플랜.
class StudyPlan {
  const StudyPlan({
    required this.certCode,
    required this.startIso,
    required this.endIso,
    required this.mode,
    required this.createdIso,
    required this.items,
  });

  final String certCode;
  final String startIso; // 'YYYY-MM-DD'
  final String endIso; // examDate=시험일, period=학습 종료일
  final PlanMode mode;
  final String createdIso;
  final List<PlanItem> items;

  Map<String, dynamic> toJson() => {
        'certCode': certCode,
        'startIso': startIso,
        'endIso': endIso,
        'mode': mode.name,
        'createdIso': createdIso,
        'items': items.map((e) => e.toJson()).toList(),
      };

  factory StudyPlan.fromJson(Map<String, dynamic> j) => StudyPlan(
        certCode: (j['certCode'] ?? '').toString(),
        startIso: (j['startIso'] ?? '').toString(),
        endIso: (j['endIso'] ?? '').toString(),
        mode: _enumByName(PlanMode.values, j['mode'], PlanMode.period),
        createdIso: (j['createdIso'] ?? '').toString(),
        items: ((j['items'] as List?) ?? const [])
            .map((e) => PlanItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
```

- [ ] **Step 4: 통과 확인**

Run: `cd flutter_app && flutter test test/study_plan_model_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 5: 커밋**

```bash
git add flutter_app/lib/models/study_plan.dart flutter_app/test/study_plan_model_test.dart
git commit -m "feat(plan): StudyPlan·PlanItem 모델 + JSON"
```

---

## Task 2: StudyPlanStore

**Files:**
- Create: `flutter_app/lib/data/study_plan_store.dart`
- Test: `flutter_app/test/study_plan_store_test.dart`

- [ ] **Step 1: 실패 테스트 작성**

```dart
// flutter_app/test/study_plan_store_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/models/study_plan.dart';
import 'package:aws_docs/data/study_plan_store.dart';

StudyPlan _plan(String cert) => StudyPlan(
      certCode: cert,
      startIso: '2026-06-10',
      endIso: '2026-06-24',
      mode: PlanMode.period,
      createdIso: '2026-06-10',
      items: const [],
    );

void main() {
  test('save·planFor 왕복 + 자격증 분리', () {
    final s = StudyPlanStore(backend: MemoryBackend());
    expect(s.planFor('CLF-C02'), isNull);
    s.save(_plan('CLF-C02'));
    s.save(_plan('SAA-C03'));
    expect(s.planFor('CLF-C02')!.endIso, '2026-06-24');
    expect(s.planFor('SAA-C03')!.certCode, 'SAA-C03');
  });

  test('clearCert 격리', () {
    final b = MemoryBackend();
    StudyPlanStore(backend: b)..save(_plan('CLF-C02'))..save(_plan('SAA-C03'));
    StudyPlanStore(backend: b).clearCert('CLF-C02');
    expect(StudyPlanStore(backend: b).planFor('CLF-C02'), isNull);
    expect(StudyPlanStore(backend: b).planFor('SAA-C03'), isNotNull);
  });

  test('손상 데이터는 null', () {
    final b = MemoryBackend()..write('awsdocs.plan.v1', '{bad');
    expect(StudyPlanStore(backend: b).planFor('CLF-C02'), isNull);
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `cd flutter_app && flutter test test/study_plan_store_test.dart`
Expected: FAIL — `study_plan_store.dart` 미존재.

- [ ] **Step 3: 구현**

```dart
// flutter_app/lib/data/study_plan_store.dart
import 'dart:convert';

import '../models/study_plan.dart';
import 'local_kv.dart';

export 'local_kv.dart' show KvBackend, MemoryBackend, defaultBackend;

/// 자격증별 단일 학습 플랜을 영속한다. 손상 데이터는 빈/null(기존 store 관례).
class StudyPlanStore {
  StudyPlanStore({KvBackend? backend}) : _b = backend ?? defaultBackend();

  final KvBackend _b;
  static const _key = 'awsdocs.plan.v1';

  Map<String, dynamic> _read() {
    final raw = _b.read(_key);
    if (raw == null || raw.isEmpty) return {};
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  StudyPlan? planFor(String certCode) {
    final j = _read()[certCode];
    if (j is! Map<String, dynamic>) return null;
    try {
      return StudyPlan.fromJson(j);
    } catch (_) {
      return null;
    }
  }

  void save(StudyPlan plan) {
    final m = _read();
    m[plan.certCode] = plan.toJson();
    _b.write(_key, jsonEncode(m));
  }

  void clearCert(String certCode) {
    final m = _read()..remove(certCode);
    _b.write(_key, jsonEncode(m));
  }

  void clearAll() => _b.write(_key, '');
}
```

- [ ] **Step 4: 통과 확인**

Run: `cd flutter_app && flutter test test/study_plan_store_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 5: 커밋**

```bash
git add flutter_app/lib/data/study_plan_store.dart flutter_app/test/study_plan_store_test.dart
git commit -m "feat(plan): StudyPlanStore (로컬 영속)"
```

---

## Task 3: PlanCheckStore (수동 오버라이드)

**Files:**
- Create: `flutter_app/lib/data/plan_check_store.dart`
- Test: `flutter_app/test/plan_check_store_test.dart`

- [ ] **Step 1: 실패 테스트 작성**

```dart
// flutter_app/test/plan_check_store_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/plan_check_store.dart';

void main() {
  test('set·overrides 왕복', () {
    final s = PlanCheckStore(backend: MemoryBackend());
    expect(s.overrides('CLF-C02'), isEmpty);
    s.set('CLF-C02', 'item-a', true);
    s.set('CLF-C02', 'item-b', false);
    expect(s.overrides('CLF-C02'), {'item-a': true, 'item-b': false});
  });

  test('null 설정은 오버라이드 해제', () {
    final s = PlanCheckStore(backend: MemoryBackend());
    s.set('CLF-C02', 'item-a', true);
    s.set('CLF-C02', 'item-a', null);
    expect(s.overrides('CLF-C02'), isEmpty);
  });

  test('clearCert 격리 + 손상 데이터 빈 결과', () {
    final b = MemoryBackend();
    PlanCheckStore(backend: b).set('CLF-C02', 'x', true);
    PlanCheckStore(backend: b).set('SAA-C03', 'y', true);
    PlanCheckStore(backend: b).clearCert('CLF-C02');
    expect(PlanCheckStore(backend: b).overrides('CLF-C02'), isEmpty);
    expect(PlanCheckStore(backend: b).overrides('SAA-C03'), {'y': true});

    final bad = MemoryBackend()..write('awsdocs.plan.checks.v1', 'nope');
    expect(PlanCheckStore(backend: bad).overrides('CLF-C02'), isEmpty);
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `cd flutter_app && flutter test test/plan_check_store_test.dart`
Expected: FAIL — 미존재.

- [ ] **Step 3: 구현**

```dart
// flutter_app/lib/data/plan_check_store.dart
import 'dart:convert';

import 'local_kv.dart';

export 'local_kv.dart' show KvBackend, MemoryBackend, defaultBackend;

/// 플랜 항목의 수동 완료 오버라이드. itemId -> bool. 키 없으면 자동 감지로.
class PlanCheckStore {
  PlanCheckStore({KvBackend? backend}) : _b = backend ?? defaultBackend();

  final KvBackend _b;
  static const _key = 'awsdocs.plan.checks.v1';

  Map<String, dynamic> _read() {
    final raw = _b.read(_key);
    if (raw == null || raw.isEmpty) return {};
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  /// 자격증의 itemId -> 수동값(true/false). 오버라이드 없으면 키 없음.
  Map<String, bool> overrides(String certCode) {
    final cm = _read()[certCode];
    if (cm is! Map) return {};
    return {
      for (final e in cm.entries)
        if (e.value is bool) e.key.toString(): e.value as bool,
    };
  }

  /// [value]=null이면 오버라이드 해제(자동 감지로 복귀).
  void set(String certCode, String itemId, bool? value) {
    final m = _read();
    final cm = (m[certCode] is Map)
        ? Map<String, dynamic>.from(m[certCode] as Map)
        : <String, dynamic>{};
    if (value == null) {
      cm.remove(itemId);
    } else {
      cm[itemId] = value;
    }
    if (cm.isEmpty) {
      m.remove(certCode);
    } else {
      m[certCode] = cm;
    }
    _b.write(_key, jsonEncode(m));
  }

  void clearCert(String certCode) {
    final m = _read()..remove(certCode);
    _b.write(_key, jsonEncode(m));
  }

  void clearAll() => _b.write(_key, '');
}
```

- [ ] **Step 4: 통과 확인**

Run: `cd flutter_app && flutter test test/plan_check_store_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 5: 커밋**

```bash
git add flutter_app/lib/data/plan_check_store.dart flutter_app/test/plan_check_store_test.dart
git commit -m "feat(plan): PlanCheckStore (수동 완료 오버라이드)"
```

---

## Task 4: 분배 엔진 buildPlan

**Files:**
- Create: `flutter_app/lib/data/plan_scheduler.dart`
- Test: `flutter_app/test/plan_scheduler_test.dart`

> `ContentEntry`는 `lib/data/content_index.dart`. `hasQuestions`(=`questionCount>0`)가 문항 보유 단일 진실.

- [ ] **Step 1: 실패 테스트 작성**

```dart
// flutter_app/test/plan_scheduler_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/content_index.dart';
import 'package:aws_docs/models/study_plan.dart';
import 'package:aws_docs/data/plan_scheduler.dart';

ContentEntry _e(String task, int domain, {int q = 12}) => ContentEntry(
      certCode: 'CLF-C02',
      taskId: task,
      title: task,
      domain: domain,
      mdAsset: 'a.md',
      questionsAsset: 'a.json',
      questionCount: q,
    );

final _clf = [for (var i = 1; i <= 6; i++) _e('clf-t$i', i)];

void main() {
  test('날짜 헬퍼', () {
    expect(addDays('2026-06-10', 5), '2026-06-15');
    expect(addDays('2026-06-30', 1), '2026-07-01');
    expect(daysBetween('2026-06-10', '2026-06-24'), 14);
  });

  test('기본 플랜: 모든 단계 항목 + 날짜는 창 안', () {
    final r = buildPlan(
      certCode: 'CLF-C02', content: _clf,
      startIso: '2026-06-10', endIso: '2026-06-24', mode: PlanMode.examDate,
    );
    // examDate면 마지막 학습일=시험 전날(6/23), 창=6/10..6/23
    expect(r.items, isNotEmpty);
    for (final it in r.items) {
      expect(it.dateIso.compareTo('2026-06-10') >= 0, isTrue);
      expect(it.dateIso.compareTo('2026-06-23') <= 0, isTrue, reason: it.dateIso);
    }
    expect(r.items.where((i) => i.type == PlanItemType.doc).length, 6);
    expect(r.items.where((i) => i.type == PlanItemType.quiz).length, 6);
    // 모의고사 최소 3 (약점 게이트 충족)
    expect(r.items.where((i) => i.type == PlanItemType.mockExam).length >= 3, isTrue);
    expect(r.items.where((i) => i.type == PlanItemType.weakExam).length, 1);
    expect(r.items.where((i) => i.type == PlanItemType.finalReview).length, 1);
  });

  test('단계 순서: learn 날짜 ≤ reinforce 날짜', () {
    final r = buildPlan(
      certCode: 'CLF-C02', content: _clf,
      startIso: '2026-06-01', endIso: '2026-07-01', mode: PlanMode.period,
    );
    final firstDoc = r.items.firstWhere((i) => i.type == PlanItemType.doc);
    final review = r.items.firstWhere((i) => i.type == PlanItemType.finalReview);
    expect(firstDoc.dateIso.compareTo(review.dateIso) <= 0, isTrue);
    expect(review.dateIso, '2026-07-01'); // 최종 점검 = 마지막 학습일
  });

  test('결정성: 같은 입력 → 같은 결과', () {
    PlanBuildResult run() => buildPlan(
        certCode: 'CLF-C02', content: _clf,
        startIso: '2026-06-01', endIso: '2026-06-20', mode: PlanMode.period);
    final a = run().items.map((e) => '${e.id}@${e.dateIso}').toList();
    final b = run().items.map((e) => '${e.id}@${e.dateIso}').toList();
    expect(a, b);
  });

  test('문항 0 자격증: learn(문서)만 + 경고', () {
    final docsOnly = [for (var i = 1; i <= 4; i++) _e('saa-t$i', i, q: 0)];
    final r = buildPlan(
      certCode: 'SAA-C03', content: docsOnly,
      startIso: '2026-06-01', endIso: '2026-06-20', mode: PlanMode.period,
    );
    expect(r.items.every((i) => i.type == PlanItemType.doc), isTrue);
    expect(r.items.length, 4);
    expect(r.warnings.any((w) => w.contains('검증 문항이 없어')), isTrue);
  });

  test('빡빡한 기간 경고', () {
    final r = buildPlan(
      certCode: 'CLF-C02', content: _clf,
      startIso: '2026-06-10', endIso: '2026-06-12', mode: PlanMode.period,
    );
    expect(r.warnings.any((w) => w.contains('빡빡')), isTrue);
  });

  test('경계: 1일 플랜·역전·빈 콘텐츠', () {
    final one = buildPlan(
      certCode: 'CLF-C02', content: _clf,
      startIso: '2026-06-10', endIso: '2026-06-10', mode: PlanMode.period,
    );
    expect(one.items.every((i) => i.dateIso == '2026-06-10'), isTrue);

    final rev = buildPlan(
      certCode: 'CLF-C02', content: _clf,
      startIso: '2026-06-10', endIso: '2026-06-01', mode: PlanMode.period,
    );
    expect(rev.items, isEmpty);
    expect(rev.warnings, isNotEmpty);

    final empty = buildPlan(
      certCode: 'CLF-C02', content: const [],
      startIso: '2026-06-10', endIso: '2026-06-20', mode: PlanMode.period,
    );
    expect(empty.items, isEmpty);
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `cd flutter_app && flutter test test/plan_scheduler_test.dart`
Expected: FAIL — `plan_scheduler.dart` 미존재.

- [ ] **Step 3: 구현**

```dart
// flutter_app/lib/data/plan_scheduler.dart
import 'content_index.dart';
import '../models/study_plan.dart';

// --- 날짜 헬퍼: UTC 기반(DST 무관·결정적), 'YYYY-MM-DD' 문자열만 다룬다 ---
DateTime _d(String iso) {
  final p = iso.split('-');
  return DateTime.utc(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
}

String _isoOf(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

/// iso에 n일 더한 'YYYY-MM-DD'.
String addDays(String iso, int n) => _isoOf(_d(iso).add(Duration(days: n)));

/// b - a (일수). 같은 날=0.
int daysBetween(String a, String b) => _d(b).difference(_d(a)).inDays;

class PlanBuildResult {
  const PlanBuildResult({required this.items, required this.warnings});
  final List<PlanItem> items;
  final List<String> warnings;
}

/// 단계형 분배(순수·결정적). 부작용 없음.
PlanBuildResult buildPlan({
  required String certCode,
  required List<ContentEntry> content,
  required String startIso,
  required String endIso,
  required PlanMode mode,
}) {
  if (content.isEmpty) {
    return const PlanBuildResult(
        items: [], warnings: ['이 자격증에는 학습 콘텐츠가 없습니다.']);
  }
  final lastDay = mode == PlanMode.examDate ? addDays(endIso, -1) : endIso;
  if (daysBetween(startIso, lastDay) < 0) {
    return const PlanBuildResult(
        items: [], warnings: ['기간이 올바르지 않습니다(종료일이 시작일보다 빠릅니다).']);
  }
  final windowDays = daysBetween(startIso, lastDay) + 1; // inclusive, >=1
  final hasQ = content.any((e) => e.hasQuestions);
  final warnings = <String>[];
  if (!hasQ) {
    warnings.add('이 자격증은 아직 검증 문항이 없어 문서 읽기 일정만 생성됩니다(퀴즈·모의고사 제외).');
  }

  final segs = _segmentDays(windowDays, hasQ); // [learn, practice, mock, reinforce]
  final starts = <int>[
    0,
    segs[0],
    segs[0] + segs[1],
    segs[0] + segs[1] + segs[2],
  ];

  final items = <PlanItem>[];

  _spread(items, certCode, PlanItemType.doc, PlanPhase.learn,
      [for (final e in content) e.taskId],
      starts[0], segs[0], windowDays, startIso);

  if (hasQ) {
    _spread(items, certCode, PlanItemType.quiz, PlanPhase.practice,
        [for (final e in content) if (e.hasQuestions) e.taskId],
        starts[1], segs[1], windowDays, startIso);

    _spread(items, certCode, PlanItemType.mockExam, PlanPhase.mock,
        List<String?>.filled(_mockCount(segs[2]), null),
        starts[2], segs[2], windowDays, startIso);

    _spread(items, certCode, PlanItemType.weakExam, PlanPhase.reinforce,
        <String?>[null], starts[3], segs[3], windowDays, startIso);

    _spread(items, certCode, PlanItemType.finalReview, PlanPhase.reinforce,
        <String?>[null], starts[3], segs[3], windowDays, startIso,
        placeAtEnd: true);
  }

  if (items.length > windowDays) {
    final perDay = (items.length / windowDays).ceil();
    warnings.add('하루 평균 약 $perDay개 — 일정이 빡빡합니다. 기간을 늘리거나 항목을 줄이세요.');
  }
  return PlanBuildResult(items: items, warnings: warnings);
}

/// 단계 일수 분할(45/20/20/15). 합 = windowDays 보존. docs-only면 learn에 전부.
List<int> _segmentDays(int windowDays, bool hasQ) {
  if (!hasQ) return [windowDays, 0, 0, 0];
  var learn = (windowDays * 0.45).round();
  final practice = (windowDays * 0.20).round();
  final mock = (windowDays * 0.20).round();
  var reinforce = windowDays - learn - practice - mock;
  if (reinforce < 0) {
    learn += reinforce; // 반올림 초과분 흡수
    reinforce = 0;
    if (learn < 0) learn = 0;
  }
  return [learn, practice, mock, reinforce];
}

/// 통합 모의고사 횟수: 최소 3(약점 게이트), 최대 6.
int _mockCount(int mockSpan) {
  final n = (mockSpan / 2).floor();
  return n < 3 ? 3 : (n > 6 ? 6 : n);
}

/// refs(K개)를 [phaseStart, phaseStart+phaseSpan) 일수에 균등 배치.
/// placeAtEnd=true면 단계 마지막 날에. off는 [0, windowDays-1]로 clamp.
void _spread(
  List<PlanItem> out,
  String certCode,
  PlanItemType type,
  PlanPhase phase,
  List<String?> refs,
  int phaseStart,
  int phaseSpan,
  int windowDays,
  String startIso, {
  bool placeAtEnd = false,
}) {
  final k = refs.length;
  if (k == 0) return;
  for (var i = 0; i < k; i++) {
    int off;
    if (placeAtEnd) {
      off = phaseStart + (phaseSpan <= 0 ? 0 : phaseSpan - 1);
    } else if (phaseSpan <= 1) {
      off = phaseStart;
    } else {
      off = phaseStart + (i * phaseSpan ~/ k);
    }
    if (off < 0) off = 0;
    if (off > windowDays - 1) off = windowDays - 1;
    final refId = refs[i];
    out.add(PlanItem(
      id: '$certCode:${type.name}:${refId ?? ''}:$i',
      dateIso: addDays(startIso, off),
      type: type,
      phase: phase,
      refId: refId,
    ));
  }
}
```

- [ ] **Step 4: 통과 확인**

Run: `cd flutter_app && flutter test test/plan_scheduler_test.dart`
Expected: PASS (7 tests).

- [ ] **Step 5: 커밋**

```bash
git add flutter_app/lib/data/plan_scheduler.dart flutter_app/test/plan_scheduler_test.dart
git commit -m "feat(plan): buildPlan 단계형 분배 엔진(순수)"
```

---

## Task 5: 진행 추적 computePlanDone

**Files:**
- Create: `flutter_app/lib/data/plan_progress.dart`
- Test: `flutter_app/test/plan_progress_test.dart`

> examId 관례: 통합=`exam:{CODE}-mock`, 약점=`exam:{CODE}-weak`(둘 다 mode='exam'), 연습=`practice:{taskId}`(mode='practice'), 오답노트=mode='review'. `taskFromExamId`는 `lib/data/attempt_presented.dart`.

- [ ] **Step 1: 실패 테스트 작성**

```dart
// flutter_app/test/plan_progress_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/models/attempt_record.dart';
import 'package:aws_docs/models/study_plan.dart';
import 'package:aws_docs/data/plan_progress.dart';

AttemptRecord _rec(String examId, {String mode = 'exam', String cert = 'CLF-C02'}) =>
    AttemptRecord(
      certId: cert, examId: examId, mode: mode, date: '2026-06-15T10:00:00.000',
      correct: 1, total: 1, wrongQuestionIds: const [], flaggedQuestionIds: const [],
      durationSpentSec: 60,
    );

PlanItem _it(String id, PlanItemType type, {String? ref, String date = '2026-06-12'}) =>
    PlanItem(id: id, dateIso: date, type: type, phase: PlanPhase.learn, refId: ref);

StudyPlan _plan(List<PlanItem> items) => StudyPlan(
      certCode: 'CLF-C02', startIso: '2026-06-10', endIso: '2026-06-24',
      mode: PlanMode.period, createdIso: '2026-06-10', items: items,
    );

void main() {
  test('doc는 열람으로, quiz는 연습 이력으로 자동 완료', () {
    final plan = _plan([
      _it('d1', PlanItemType.doc, ref: 'clf-t1-1'),
      _it('d2', PlanItemType.doc, ref: 'clf-t1-2'),
      _it('q1', PlanItemType.quiz, ref: 'clf-t1-1'),
    ]);
    final done = computePlanDone(plan,
      manual: const {},
      viewedTaskIds: {'clf-t1-1'},
      history: [_rec('practice:clf-t1-1', mode: 'practice')],
    );
    expect(done['d1'], isTrue);
    expect(done['d2'], isFalse);
    expect(done['q1'], isTrue);
  });

  test('모의고사는 횟수 기반: 응시 2회면 앞 2개만 완료', () {
    final plan = _plan([
      _it('m0', PlanItemType.mockExam, date: '2026-06-18'),
      _it('m1', PlanItemType.mockExam, date: '2026-06-19'),
      _it('m2', PlanItemType.mockExam, date: '2026-06-20'),
    ]);
    final done = computePlanDone(plan,
      manual: const {}, viewedTaskIds: const {},
      history: [_rec('exam:CLF-C02-mock'), _rec('exam:CLF-C02-mock')],
    );
    expect(done['m0'], isTrue);
    expect(done['m1'], isTrue);
    expect(done['m2'], isFalse);
  });

  test('수동 오버라이드가 자동을 덮어씀', () {
    final plan = _plan([_it('d1', PlanItemType.doc, ref: 'clf-t1-1')]);
    final done = computePlanDone(plan,
      manual: const {'d1': true}, viewedTaskIds: const {}, history: const []);
    expect(done['d1'], isTrue); // 열람 없어도 수동 true
  });

  test('weakExam·finalReview 자동 감지', () {
    final plan = _plan([
      _it('w', PlanItemType.weakExam, date: '2026-06-22'),
      _it('fr', PlanItemType.finalReview, date: '2026-06-23'),
    ]);
    final done = computePlanDone(plan,
      manual: const {}, viewedTaskIds: const {},
      history: [_rec('exam:CLF-C02-weak'), _rec('review:clf-t1-1', mode: 'review')]);
    expect(done['w'], isTrue);
    expect(done['fr'], isTrue);
  });

  test('isOverdue: 미완 + 과거', () {
    final it = _it('d1', PlanItemType.doc, date: '2026-06-12');
    expect(isOverdue(it, '2026-06-15', false), isTrue);
    expect(isOverdue(it, '2026-06-15', true), isFalse); // 완료면 밀림 아님
    expect(isOverdue(it, '2026-06-10', false), isFalse); // 아직 미래
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `cd flutter_app && flutter test test/plan_progress_test.dart`
Expected: FAIL — 미존재.

- [ ] **Step 3: 구현**

```dart
// flutter_app/lib/data/plan_progress.dart
import '../models/attempt_record.dart';
import '../models/study_plan.dart';
import 'attempt_presented.dart';

/// 플랜 항목별 완료 여부(순수). 수동 오버라이드 우선, 없으면 자동 감지.
/// 반복형(mockExam/weakExam/finalReview)은 횟수 기반: 같은 타입 항목을
/// 날짜·id 순으로 정렬해 실제 응시 횟수만큼 앞에서부터 완료 처리.
///
/// 한계(MVP): 수동 오버라이드된 반복형 항목은 자동 순위 계산에서 제외된다.
Map<String, bool> computePlanDone(
  StudyPlan plan, {
  required Map<String, bool> manual,
  required Set<String> viewedTaskIds,
  required List<AttemptRecord> history,
}) {
  final cert = plan.certCode;
  final hist = history.where((r) => r.certId == cert).toList();

  int byExamId(String examId) => hist.where((r) => r.examId == examId).length;
  final rankCount = <PlanItemType, int>{
    PlanItemType.mockExam: byExamId('exam:$cert-mock'),
    PlanItemType.weakExam: byExamId('exam:$cert-weak'),
    PlanItemType.finalReview: hist.where((r) => r.mode == 'review').length,
  };

  bool quizDone(String? refId) =>
      refId != null &&
      hist.any((r) => r.mode == 'practice' && taskFromExamId(r.examId) == refId);

  final sorted = [...plan.items]
    ..sort((a, b) {
      final c = a.dateIso.compareTo(b.dateIso);
      return c != 0 ? c : a.id.compareTo(b.id);
    });

  final seen = <PlanItemType, int>{};
  final result = <String, bool>{};
  for (final it in sorted) {
    final m = manual[it.id];
    if (m != null) {
      result[it.id] = m;
      continue;
    }
    switch (it.type) {
      case PlanItemType.doc:
        result[it.id] = it.refId != null && viewedTaskIds.contains(it.refId);
      case PlanItemType.quiz:
        result[it.id] = quizDone(it.refId);
      case PlanItemType.mockExam:
      case PlanItemType.weakExam:
      case PlanItemType.finalReview:
        final rank = seen[it.type] ?? 0;
        seen[it.type] = rank + 1;
        result[it.id] = rank < (rankCount[it.type] ?? 0);
    }
  }
  return result;
}

/// 밀림: 미완 + 배정일이 오늘보다 과거.
bool isOverdue(PlanItem item, String todayIso, bool done) =>
    !done && item.dateIso.compareTo(todayIso) < 0;
```

- [ ] **Step 4: 통과 확인**

Run: `cd flutter_app && flutter test test/plan_progress_test.dart`
Expected: PASS (5 tests).

- [ ] **Step 5: 커밋**

```bash
git add flutter_app/lib/data/plan_progress.dart flutter_app/test/plan_progress_test.dart
git commit -m "feat(plan): computePlanDone 하이브리드 진행 추적(순수)"
```

---

## Task 6: 라우트 + 생성/편집 화면

**Files:**
- Create: `flutter_app/lib/pages/plan_page.dart`
- Modify: `flutter_app/lib/app_router.dart` (라우트 추가)
- Modify: `flutter_app/lib/pages/cert_detail_page.dart` (진입 카드)
- Test: `flutter_app/test/app_router_test.dart` (redirect 검증 추가)

> 페이지 렌더는 `app_router_test.dart` 상단 주석대로 위젯 테스트가 어려우므로(SelectionArea), **라우트 redirect만 자동 테스트 + 수동 검증**으로 커버한다.

- [ ] **Step 1: 라우트 redirect 실패 테스트 추가**

`flutter_app/test/app_router_test.dart`의 `main()` 안에 추가:

```dart
  testWidgets('잘못된 cert plan 경로 → "/"로 redirect', (tester) async {
    await tester.pumpWidget(_app('/cert/NOPE/plan'));
    await tester.pump();
    expect(find.byType(HomePage), findsOneWidget);
  });
```

- [ ] **Step 2: 실패 확인**

Run: `cd flutter_app && flutter test test/app_router_test.dart`
Expected: FAIL — `/cert/NOPE/plan`은 현재 알 수 없는 경로 → 에러 페이지(HomePage 아님).

- [ ] **Step 3: 라우트 추가**

`lib/app_router.dart` 상단 import에 추가:

```dart
import 'pages/plan_page.dart';
```

`report` GoRoute 블록(현재 48–52행) **다음에** 형제 라우트로 추가:

```dart
                GoRoute(
                  path: 'plan',
                  builder: (context, state) =>
                      PlanPage(cert: certByCode(state.pathParameters['code']!)!),
                ),
```

> 부모 `cert/:code`에 이미 `redirect`(존재하지 않는 코드 → '/')가 있어 `/cert/NOPE/plan`도 '/'로 빠진다.

- [ ] **Step 4: PlanPage 생성(생성/편집 폼 + 어젠다 분기)**

```dart
// flutter_app/lib/pages/plan_page.dart
import 'package:flutter/material.dart';

import '../data/cert_lookup.dart';
import '../data/plan_scheduler.dart';
import '../data/study_plan_store.dart';
import '../models/study_plan.dart';
import '../models/certification.dart';
import '../theme/app_theme.dart';

/// 학습 일정 화면. 플랜이 없으면 생성 폼, 있으면 어젠다(Task 7).
class PlanPage extends StatefulWidget {
  const PlanPage({super.key, required this.cert});
  final Certification cert;

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  final _store = StudyPlanStore();
  StudyPlan? _plan;

  String get _today => DateTime.now().toIso8601String().substring(0, 10);

  @override
  void initState() {
    super.initState();
    _plan = _store.planFor(widget.cert.code);
  }

  void _onSaved(StudyPlan p) {
    _store.save(p);
    setState(() => _plan = p);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: Border(bottom: BorderSide(color: c.border)),
        title: Text('${widget.cert.code} · 학습 일정',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      body: _plan == null
          ? _PlanCreateForm(
              cert: widget.cert, today: _today, onSaved: _onSaved)
          : _PlanAgenda(
              cert: widget.cert,
              plan: _plan!,
              today: _today,
              onEdit: () => setState(() => _plan = null),
              onChanged: (p) => _onSaved(p)),
    );
  }
}

/// 생성/편집 폼: 시험일 또는 기간 → 미리보기(buildPlan) → 저장.
class _PlanCreateForm extends StatefulWidget {
  const _PlanCreateForm(
      {required this.cert, required this.today, required this.onSaved});
  final Certification cert;
  final String today;
  final ValueChanged<StudyPlan> onSaved;

  @override
  State<_PlanCreateForm> createState() => _PlanCreateFormState();
}

class _PlanCreateFormState extends State<_PlanCreateForm> {
  PlanMode _mode = PlanMode.examDate;
  late String _start = widget.today;
  late String _end = addDays(widget.today, 14);

  PlanBuildResult _preview() => buildPlan(
        certCode: widget.cert.code,
        content: contentFor(widget.cert.code),
        startIso: _start,
        endIso: _end,
        mode: _mode,
      );

  Future<void> _pick(bool isStart) async {
    final init = DateTime.parse(isStart ? _start : _end);
    final picked = await showDatePicker(
      context: context,
      initialDate: init,
      firstDate: DateTime.parse(widget.today),
      lastDate: DateTime.parse(widget.today).add(const Duration(days: 365)),
    );
    if (picked == null) return;
    final iso = picked.toIso8601String().substring(0, 10);
    setState(() => isStart ? _start = iso : _end = iso);
  }

  void _save() {
    final r = _preview();
    widget.onSaved(StudyPlan(
      certCode: widget.cert.code,
      startIso: _start,
      endIso: _end,
      mode: _mode,
      createdIso: widget.today,
      items: r.items,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    final r = _preview();
    final endLabel = _mode == PlanMode.examDate ? '시험일' : '종료일';
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.all(Gap.xl),
          children: [
            Text('학습 일정 만들기', style: t.headlineSmall),
            const SizedBox(height: Gap.sm),
            Text('대상 자격증 ${widget.cert.code}의 학습문서·연습·모의고사를 기간에 맞춰 분배합니다.',
                style: t.bodyMedium),
            const SizedBox(height: Gap.lg),
            // 모드 토글
            SegmentedButton<PlanMode>(
              segments: const [
                ButtonSegment(value: PlanMode.examDate, label: Text('시험일 기준')),
                ButtonSegment(value: PlanMode.period, label: Text('기간 기준')),
              ],
              selected: {_mode},
              onSelectionChanged: (s) => setState(() => _mode = s.first),
            ),
            const SizedBox(height: Gap.lg),
            _dateRow(c, '시작일', _start, () => _pick(true)),
            const SizedBox(height: Gap.sm),
            _dateRow(c, endLabel, _end, () => _pick(false)),
            const SizedBox(height: Gap.lg),
            // 미리보기 요약
            Container(
              padding: const EdgeInsets.all(Gap.lg),
              decoration: BoxDecoration(
                color: c.surface2,
                borderRadius: BorderRadius.circular(Radii.md),
                border: Border.all(color: c.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('미리보기 · 총 ${r.items.length}개 항목',
                      style: t.titleMedium),
                  const SizedBox(height: Gap.xs),
                  Text(_summary(r), style: t.bodySmall?.copyWith(color: c.textMuted)),
                  for (final w in r.warnings) ...[
                    const SizedBox(height: Gap.xs),
                    Text('⚠ $w',
                        style: t.bodySmall?.copyWith(color: c.wrong)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: Gap.lg),
            FilledButton(
              onPressed: r.items.isEmpty ? null : _save,
              child: const Text('일정 저장'),
            ),
          ],
        ),
      ),
    );
  }

  String _summary(PlanBuildResult r) {
    int n(PlanItemType x) => r.items.where((i) => i.type == x).length;
    return '문서 ${n(PlanItemType.doc)} · 연습 ${n(PlanItemType.quiz)} · '
        '모의고사 ${n(PlanItemType.mockExam)} · 약점 ${n(PlanItemType.weakExam)} · 점검 ${n(PlanItemType.finalReview)}';
  }

  Widget _dateRow(AppColors c, String label, String iso, VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.md),
        child: Container(
          padding: const EdgeInsets.all(Gap.lg),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(Radii.md),
            border: Border.all(color: c.border),
          ),
          child: Row(
            children: [
              Text(label,
                  style: TextStyle(fontWeight: FontWeight.w700, color: c.textMuted)),
              const Spacer(),
              Text(iso,
                  style: TextStyle(
                      fontFamily: AppTheme.monoFamily, color: c.text)),
              const SizedBox(width: Gap.sm),
              Icon(Icons.calendar_today_outlined, size: 16, color: c.accent),
            ],
          ),
        ),
      );
}

/// Task 7에서 구현. 지금은 자리표시.
class _PlanAgenda extends StatelessWidget {
  const _PlanAgenda(
      {required this.cert,
      required this.plan,
      required this.today,
      required this.onEdit,
      required this.onChanged});
  final Certification cert;
  final StudyPlan plan;
  final String today;
  final VoidCallback onEdit;
  final ValueChanged<StudyPlan> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('플랜 ${plan.items.length}개 항목 (어젠다는 Task 7에서)',
              style: TextStyle(color: c.text)),
          const SizedBox(height: Gap.md),
          TextButton(onPressed: onEdit, child: const Text('다시 만들기')),
        ],
      ),
    );
  }
}
```

- [ ] **Step 5: 진입 카드 추가(cert_detail_page)**

`lib/pages/cert_detail_page.dart`의 "약점 리포트" 카드(현재 약 345–377행, `'약점 리포트 · Task별 정답률 보기'` 포함 `InkWell`) **바로 위에** 동일 패턴으로 추가. `context`/`c`/`t`/`certCode`가 이미 스코프에 있는 위치에 둔다:

```dart
          Padding(
            padding: const EdgeInsets.only(top: Gap.xs),
            child: InkWell(
              onTap: () => context.push('/cert/${entries.first.certCode}/plan'),
              borderRadius: BorderRadius.circular(Radii.md),
              child: Container(
                padding: const EdgeInsets.all(Gap.lg),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(Radii.md),
                  border: Border.all(color: c.border),
                ),
                child: Row(
                  children: [
                    Icon(Icons.event_note_outlined, size: 18, color: c.accent),
                    const SizedBox(width: Gap.sm),
                    Expanded(
                      child: Text('학습 일정 · 시험일까지 무엇을 언제 공부할지',
                          style: t.titleMedium?.copyWith(color: c.text)),
                    ),
                    Text('일정 →',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: c.accent)),
                  ],
                ),
              ),
            ),
          ),
```

> `entries`/`c`/`t`가 스코프에 없으면, 같은 build 메서드에서 "약점 리포트" 카드가 쓰는 동일 변수명을 그대로 사용한다(그 카드와 같은 리스트의 형제 위젯으로 삽입).

- [ ] **Step 6: redirect 테스트 통과 + 분석**

Run: `cd flutter_app && flutter test test/app_router_test.dart && flutter analyze lib`
Expected: PASS(전 라우터 테스트) + analyze 무이슈.

- [ ] **Step 7: 수동 검증**

```bash
cd flutter_app && flutter run -d chrome
```
확인: 홈 → CLF 카드 → 상세에 "학습 일정" 카드 노출 → 탭 → 생성 폼. 시험일/기간 토글, 날짜 선택 시 미리보기 수치·경고 갱신, "일정 저장" 후 자리표시 화면. SAA-C03(문항 0)에서 "검증 문항이 없어…" 경고 노출.

- [ ] **Step 8: 커밋**

```bash
git add flutter_app/lib/pages/plan_page.dart flutter_app/lib/app_router.dart flutter_app/lib/pages/cert_detail_page.dart flutter_app/test/app_router_test.dart
git commit -m "feat(plan): /cert/:code/plan 라우트 + 생성/편집 폼 + 진입 카드"
```

---

## Task 7: 어젠다 뷰

**Files:**
- Modify: `flutter_app/lib/pages/plan_page.dart` (`_PlanAgenda` 실구현)
- Test: `flutter_app/test/plan_agenda_summary_test.dart` (순수 요약 함수)

> 어젠다 렌더 전체는 수동 검증. 단, **요약(진행률·D-day) 계산은 순수 함수로 분리해 단위 테스트**한다.

- [ ] **Step 1: 순수 요약 함수 실패 테스트**

```dart
// flutter_app/test/plan_agenda_summary_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/models/study_plan.dart';
import 'package:aws_docs/pages/plan_page.dart' show planSummary, PlanSummary;

PlanItem _it(String id, {String date = '2026-06-12'}) => PlanItem(
    id: id, dateIso: date, type: PlanItemType.doc, phase: PlanPhase.learn);

void main() {
  test('진행률·남은 일수·완료수', () {
    final plan = StudyPlan(
      certCode: 'CLF-C02', startIso: '2026-06-10', endIso: '2026-06-24',
      mode: PlanMode.examDate, createdIso: '2026-06-10',
      items: [_it('a'), _it('b'), _it('c', date: '2026-06-13')],
    );
    final s = planSummary(plan, {'a': true, 'b': false, 'c': true}, '2026-06-12');
    expect(s.total, 3);
    expect(s.done, 2);
    expect(s.percent, 67); // round(2/3*100)
    expect(s.daysLeft, 12); // 6/24 - 6/12
  });

  test('빈 플랜은 0%', () {
    final plan = StudyPlan(
      certCode: 'CLF-C02', startIso: '2026-06-10', endIso: '2026-06-10',
      mode: PlanMode.period, createdIso: '2026-06-10', items: const []);
    final s = planSummary(plan, const {}, '2026-06-10');
    expect(s.percent, 0);
    expect(s.daysLeft, 0);
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `cd flutter_app && flutter test test/plan_agenda_summary_test.dart`
Expected: FAIL — `planSummary`/`PlanSummary` 미존재.

- [ ] **Step 3: 요약 함수 + 어젠다 구현**

`lib/pages/plan_page.dart` 상단(파일 끝 또는 import 아래)에 순수 함수 추가:

```dart
import '../data/plan_progress.dart';
import '../data/plan_check_store.dart';
import '../data/history_store.dart';
import '../data/viewed_docs_store.dart';
import 'package:go_router/go_router.dart';

/// 어젠다 헤더용 순수 요약.
class PlanSummary {
  const PlanSummary(
      {required this.total, required this.done, required this.percent, required this.daysLeft});
  final int total;
  final int done;
  final int percent;
  final int daysLeft;
}

PlanSummary planSummary(StudyPlan plan, Map<String, bool> done, String todayIso) {
  final total = plan.items.length;
  final d = plan.items.where((i) => done[i.id] == true).length;
  final pct = total == 0 ? 0 : (d / total * 100).round();
  final left = daysBetween(todayIso, plan.endIso);
  return PlanSummary(total: total, done: d, percent: pct, daysLeft: left < 0 ? 0 : left);
}
```

`_PlanAgenda`를 StatefulWidget으로 교체해 실구현:

```dart
class _PlanAgenda extends StatefulWidget {
  const _PlanAgenda(
      {required this.cert,
      required this.plan,
      required this.today,
      required this.onEdit,
      required this.onChanged});
  final Certification cert;
  final StudyPlan plan;
  final String today;
  final VoidCallback onEdit;
  final ValueChanged<StudyPlan> onChanged;

  @override
  State<_PlanAgenda> createState() => _PlanAgendaState();
}

class _PlanAgendaState extends State<_PlanAgenda> {
  final _checks = PlanCheckStore();
  final _history = HistoryStore();
  final _viewed = ViewedDocsStore();

  Map<String, bool> _done() => computePlanDone(
        widget.plan,
        manual: _checks.overrides(widget.cert.code),
        viewedTaskIds: _viewed.viewed(widget.cert.code),
        history: _history.all(),
      );

  void _toggle(String itemId, bool current) {
    // 수동 토글: 현재 상태의 반대를 오버라이드로 고정.
    _checks.set(widget.cert.code, itemId, !current);
    setState(() {});
  }

  void _open(PlanItem it) {
    final code = widget.cert.code;
    switch (it.type) {
      case PlanItemType.doc:
        context.push('/cert/$code/study/${it.refId}');
      case PlanItemType.quiz:
        context.push('/cert/$code/study/${it.refId}/quiz');
      case PlanItemType.mockExam:
        context.push('/cert/$code/exam');
      case PlanItemType.weakExam:
        context.push('/cert/$code/exam/weak');
      case PlanItemType.finalReview:
        context.push('/cert/$code/review');
    }
  }

  static const _typeLabel = {
    PlanItemType.doc: '학습',
    PlanItemType.quiz: '연습',
    PlanItemType.mockExam: '모의고사',
    PlanItemType.weakExam: '약점',
    PlanItemType.finalReview: '점검',
  };

  String _title(PlanItem it) {
    if (it.refId == null) return _typeLabel[it.type]!;
    final e = entryByTask(widget.cert.code, it.refId!);
    return e?.title ?? it.refId!;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    final done = _done();
    final s = planSummary(widget.plan, done, widget.today);

    // 날짜별 그룹(정렬)
    final byDate = <String, List<PlanItem>>{};
    for (final it in [...widget.plan.items]
      ..sort((a, b) => a.dateIso.compareTo(b.dateIso))) {
      (byDate[it.dateIso] ??= []).add(it);
    }
    final dates = byDate.keys.toList()..sort();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.all(Gap.xl),
          children: [
            // 요약 헤더
            Row(
              children: [
                Text('D-${s.daysLeft}',
                    style: t.titleLarge?.copyWith(
                        color: c.accent, fontFamily: AppTheme.monoFamily)),
                const SizedBox(width: Gap.md),
                Text('진행 ${s.done}/${s.total} (${s.percent}%)',
                    style: t.bodyMedium?.copyWith(color: c.textMuted)),
                const Spacer(),
                TextButton(onPressed: widget.onEdit, child: const Text('다시 만들기')),
              ],
            ),
            const SizedBox(height: Gap.sm),
            LinearProgressIndicator(
              value: s.total == 0 ? 0 : s.done / s.total,
              backgroundColor: c.surface2,
              color: c.accent,
            ),
            const SizedBox(height: Gap.lg),
            for (final date in dates) ...[
              _dayHeader(c, t, date),
              for (final it in byDate[date]!)
                _itemRow(c, t, it, done[it.id] == true,
                    isOverdue(it, widget.today, done[it.id] == true)),
              const SizedBox(height: Gap.md),
            ],
          ],
        ),
      ),
    );
  }

  Widget _dayHeader(AppColors c, TextTheme t, String date) {
    final isToday = date == widget.today;
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.xs),
      child: Text(isToday ? '$date · 오늘' : date,
          style: t.labelLarge?.copyWith(
              color: isToday ? c.accent : c.textMuted,
              fontWeight: FontWeight.w800)),
    );
  }

  Widget _itemRow(
      AppColors c, TextTheme t, PlanItem it, bool done, bool overdue) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.xs2),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Gap.md, vertical: Gap.sm),
        decoration: BoxDecoration(
          color: overdue ? c.wrongWeak : c.surface,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(
              color: overdue ? c.wrong.withValues(alpha: 0.35) : c.border),
        ),
        child: Row(
          children: [
            Checkbox(
              value: done,
              onChanged: (_) => _toggle(it.id, done),
              activeColor: c.accent,
            ),
            Expanded(
              child: InkWell(
                onTap: () => _open(it),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: Gap.sm),
                  child: Row(
                    children: [
                      Text(_typeLabel[it.type]!,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: c.textMuted)),
                      const SizedBox(width: Gap.sm),
                      Expanded(
                        child: Text(_title(it),
                            style: TextStyle(
                                color: c.text,
                                decoration: done
                                    ? TextDecoration.lineThrough
                                    : null)),
                      ),
                      if (overdue)
                        Text('밀림',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: c.wrong)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

> `_PlanAgenda` 교체 시 Task 6의 자리표시 클래스를 위 구현으로 완전히 대체한다. import 누락(go_router, theme 등) 없도록 분석으로 확인.

- [ ] **Step 4: 통과 확인**

Run: `cd flutter_app && flutter test test/plan_agenda_summary_test.dart && flutter analyze lib`
Expected: PASS(2) + analyze 무이슈.

- [ ] **Step 5: 수동 검증**

```bash
cd flutter_app && flutter run -d chrome
```
확인: 저장된 플랜 → 어젠다 표시(D-day·진행률 막대·날짜별 항목). 체크박스 토글 시 취소선·진행률 갱신, 항목 탭 시 해당 문서/퀴즈/모의고사/오답노트로 이동, 과거 미완은 "밀림". 문서 열람 후 돌아오면 자동 체크.

- [ ] **Step 6: 커밋**

```bash
git add flutter_app/lib/pages/plan_page.dart flutter_app/test/plan_agenda_summary_test.dart
git commit -m "feat(plan): 어젠다 뷰(진행률·체크·이동·밀림)"
```

---

## Task 8: 재분배

**Files:**
- Modify: `flutter_app/lib/data/plan_scheduler.dart` (`redistribute` 추가)
- Modify: `flutter_app/lib/pages/plan_page.dart` (재분배 액션)
- Test: `flutter_app/test/plan_scheduler_test.dart` (재분배 케이스 추가)

- [ ] **Step 1: 실패 테스트 추가**

`test/plan_scheduler_test.dart`의 `main()`에 추가:

```dart
  test('redistribute: 완료 보존 + 미완을 오늘~끝에 재배치', () {
    final plan = StudyPlan(
      certCode: 'CLF-C02', startIso: '2026-06-01', endIso: '2026-06-20',
      mode: PlanMode.period, createdIso: '2026-06-01',
      items: const [
        PlanItem(id: 'a', dateIso: '2026-06-02', type: PlanItemType.doc, phase: PlanPhase.learn, refId: 'clf-t1'),
        PlanItem(id: 'b', dateIso: '2026-06-03', type: PlanItemType.doc, phase: PlanPhase.learn, refId: 'clf-t2'),
        PlanItem(id: 'c', dateIso: '2026-06-04', type: PlanItemType.doc, phase: PlanPhase.learn, refId: 'clf-t3'),
      ],
    );
    final r = redistribute(plan, '2026-06-10', {'a'}); // a 완료
    final byId = {for (final i in r.items) i.id: i};
    expect(byId['a']!.dateIso, '2026-06-02'); // 완료는 보존
    // 미완 b·c는 오늘(6/10) 이후로
    expect(byId['b']!.dateIso.compareTo('2026-06-10') >= 0, isTrue);
    expect(byId['c']!.dateIso.compareTo('2026-06-10') >= 0, isTrue);
  });

  test('redistribute: 남은 기간 없으면 경고', () {
    final plan = StudyPlan(
      certCode: 'CLF-C02', startIso: '2026-06-01', endIso: '2026-06-05',
      mode: PlanMode.period, createdIso: '2026-06-01',
      items: const [
        PlanItem(id: 'a', dateIso: '2026-06-02', type: PlanItemType.doc, phase: PlanPhase.learn),
      ],
    );
    final r = redistribute(plan, '2026-06-10', {});
    expect(r.warnings, isNotEmpty);
  });
```

- [ ] **Step 2: 실패 확인**

Run: `cd flutter_app && flutter test test/plan_scheduler_test.dart`
Expected: FAIL — `redistribute` 미존재.

- [ ] **Step 3: redistribute 구현**

`lib/data/plan_scheduler.dart` 끝에 추가:

```dart
/// 미완 항목만 [today, lastDay] 창에 단계 순서 유지한 채 재배치.
/// 완료 항목은 날짜를 보존한다. 사용자 명시 동작(자동 호출 금지).
PlanBuildResult redistribute(
  StudyPlan plan,
  String todayIso,
  Set<String> doneItemIds,
) {
  final lastDay = plan.mode == PlanMode.examDate
      ? addDays(plan.endIso, -1)
      : plan.endIso;
  final winStart =
      daysBetween(plan.startIso, todayIso) > 0 ? todayIso : plan.startIso;
  if (daysBetween(winStart, lastDay) < 0) {
    return PlanBuildResult(
        items: plan.items, warnings: ['남은 기간이 없어 재분배할 수 없습니다.']);
  }
  final windowDays = daysBetween(winStart, lastDay) + 1;

  final done = plan.items.where((i) => doneItemIds.contains(i.id)).toList();
  // plan.items는 이미 단계 순서 → todo도 그 순서 보존.
  final todo = plan.items.where((i) => !doneItemIds.contains(i.id)).toList();

  final out = <PlanItem>[...done];
  final k = todo.length;
  for (var i = 0; i < k; i++) {
    var off = windowDays <= 1 ? 0 : (i * windowDays ~/ k);
    if (off > windowDays - 1) off = windowDays - 1;
    out.add(PlanItem(
      id: todo[i].id,
      dateIso: addDays(winStart, off),
      type: todo[i].type,
      phase: todo[i].phase,
      refId: todo[i].refId,
    ));
  }
  out.sort((a, b) => a.dateIso.compareTo(b.dateIso));

  final warnings = <String>[];
  if (k > windowDays) {
    warnings.add('남은 $k개를 $windowDays일에 재배치 — 하루 평균 약 ${(k / windowDays).ceil()}개.');
  }
  return PlanBuildResult(items: out, warnings: warnings);
}
```

- [ ] **Step 4: 통과 확인**

Run: `cd flutter_app && flutter test test/plan_scheduler_test.dart`
Expected: PASS (9 tests).

- [ ] **Step 5: 어젠다에 재분배 액션 연결**

`_PlanAgendaState`의 요약 헤더 Row에서 "다시 만들기" TextButton **앞에** 추가:

```dart
                TextButton(
                  onPressed: () {
                    final done = _done();
                    final doneIds = {
                      for (final e in done.entries)
                        if (e.value) e.key
                    };
                    final r = redistribute(widget.plan, widget.today, doneIds);
                    widget.onChanged(StudyPlan(
                      certCode: widget.plan.certCode,
                      startIso: widget.plan.startIso,
                      endIso: widget.plan.endIso,
                      mode: widget.plan.mode,
                      createdIso: widget.plan.createdIso,
                      items: r.items,
                    ));
                  },
                  child: const Text('오늘부터 재분배'),
                ),
```

- [ ] **Step 6: 분석 + 수동 검증**

Run: `cd flutter_app && flutter analyze lib`
Expected: 무이슈.
수동: 과거 밀린 항목이 있는 플랜에서 "오늘부터 재분배" → 미완 항목 날짜가 오늘 이후로 이동, 완료 항목은 그대로.

- [ ] **Step 7: 커밋**

```bash
git add flutter_app/lib/data/plan_scheduler.dart flutter_app/lib/pages/plan_page.dart flutter_app/test/plan_scheduler_test.dart
git commit -m "feat(plan): 오늘부터 재분배(미완 항목만)"
```

---

## Task 9: study_reset 연동

**Files:**
- Modify: `flutter_app/lib/data/study_reset.dart`
- Test: `flutter_app/test/study_reset_test.dart` (플랜·체크 정리 단언 추가)

- [ ] **Step 1: 실패 테스트 추가**

`test/study_reset_test.dart`에 테스트 추가(기존 import에 맞춰 상단 import 보강):

```dart
import 'package:aws_docs/models/study_plan.dart';
import 'package:aws_docs/data/study_plan_store.dart';
import 'package:aws_docs/data/plan_check_store.dart';

// ... main() 안:
  test('resetCert는 플랜·체크도 정리', () {
    final b = MemoryBackend();
    StudyPlanStore(backend: b).save(StudyPlan(
      certCode: 'CLF-C02', startIso: '2026-06-10', endIso: '2026-06-20',
      mode: PlanMode.period, createdIso: '2026-06-10', items: const []));
    PlanCheckStore(backend: b).set('CLF-C02', 'x', true);

    resetCert('CLF-C02', backend: b);

    expect(StudyPlanStore(backend: b).planFor('CLF-C02'), isNull);
    expect(PlanCheckStore(backend: b).overrides('CLF-C02'), isEmpty);
  });
```

> `study_reset_test.dart`가 `MemoryBackend`를 어떤 import로 보는지 확인하고(예: `package:aws_docs/data/history_store.dart`), 없으면 `import 'package:aws_docs/data/local_kv.dart';` 추가.

- [ ] **Step 2: 실패 확인**

Run: `cd flutter_app && flutter test test/study_reset_test.dart`
Expected: FAIL — resetCert가 아직 플랜/체크를 지우지 않음.

- [ ] **Step 3: 구현**

`lib/data/study_reset.dart` 상단 import에 추가:

```dart
import 'plan_check_store.dart';
import 'study_plan_store.dart';
```

`resetCert` 본문에 두 줄 추가(`ViewedDocsStore(...).clearCert` 다음):

```dart
  StudyPlanStore(backend: b).clearCert(certCode);
  PlanCheckStore(backend: b).clearCert(certCode);
```

`resetAll` 본문에도 추가(`ViewedDocsStore(...).clearAll()` 다음):

```dart
  StudyPlanStore(backend: b).clearAll();
  PlanCheckStore(backend: b).clearAll();
```

- [ ] **Step 4: 통과 확인**

Run: `cd flutter_app && flutter test test/study_reset_test.dart`
Expected: PASS.

- [ ] **Step 5: 전체 회귀 + 커밋**

```bash
cd flutter_app && flutter analyze lib && flutter test
```
Expected: analyze 무이슈, 전 테스트 통과(기존 183 + 신규).

```bash
git add flutter_app/lib/data/study_reset.dart flutter_app/test/study_reset_test.dart
git commit -m "feat(plan): 학습 기록 초기화 시 플랜·체크 정리"
```

---

## Task 10 (후속 증분): 월 펼치기 뷰

**Files:**
- Modify: `flutter_app/lib/pages/plan_page.dart` (`_PlanAgenda`에 월/어젠다 토글)

> 동일 `PlanItem` 소스를 월 격자로. 어젠다 안정화 후 착수. 순수 로직이 거의 없어 수동 검증 위주.

- [ ] **Step 1: 토글 상태 + 월 격자 위젯 추가**

`_PlanAgendaState`에 `bool _month = false;` 필드 추가, 요약 헤더에 토글 버튼:

```dart
                IconButton(
                  tooltip: _month ? '어젠다' : '월 펼치기',
                  icon: Icon(_month ? Icons.view_agenda_outlined : Icons.calendar_month_outlined),
                  onPressed: () => setState(() => _month = !_month),
                ),
```

본문에서 `_month`이면 월 격자, 아니면 기존 어젠다를 렌더. 월 격자는 `plan.startIso`~`endIso`의 달을 7열 그리드로 그리고, 각 날짜 셀에 그 날 항목 수/단계 색 점을 표시(셀 탭 시 해당 날짜로 스크롤하거나 그 날 항목 시트). 색·간격은 DESIGN.md(틸 액센트는 오늘·시험일만).

- [ ] **Step 2: 분석 + 수동 검증**

```bash
cd flutter_app && flutter analyze lib && flutter run -d chrome
```
확인: 어젠다↔월 토글, 월 격자에 항목 점 표시, 오늘·시험일 강조, 모바일 폭에서 셀 가독성.

- [ ] **Step 3: 커밋**

```bash
git add flutter_app/lib/pages/plan_page.dart
git commit -m "feat(plan): 월 펼치기 뷰(어젠다 보조)"
```

---

## Self-Review (작성자 점검 결과)

**스펙 커버리지:** §4 모델→T1, §5 저장소→T2·T3, §6 엔진→T4, §7 추적→T5, §8 UI/라우트→T6·T7, §9 재분배→T8, §10 콘텐츠 준비도→T4(docs-only 분기)·T6(고지), §11 테스트→각 Task, 월뷰→T10. 누락 없음.

**플레이스홀더:** 로직 Task(1–5,8,9)는 완전한 코드·테스트. UI Task(6,7,10)는 완전한 위젯 코드 + 수동 검증(레포의 `app_router_test` 주석이 명시한 SelectionArea 제약 때문에 페이지 위젯 테스트 불가 — 순수 요약/엔진은 단위 테스트로 분리).

**타입 일관성:** `PlanItemType`/`PlanPhase`/`PlanMode` 값, `buildPlan`·`computePlanDone`·`redistribute`·`planSummary` 시그니처, examId 관례(`exam:{CODE}-mock/-weak`·`practice:`·`review`)가 Task 전반에서 일치. `addDays`/`daysBetween`는 T4 정의를 T7·T8이 재사용.

---

## 실행 핸드오프

플랜 완료·저장: `docs/superpowers/plans/2026-06-10-study-plan-calendar.md`. 두 가지 실행 방식:

1. **Subagent-Driven (권장)** — Task마다 새 서브에이전트 디스패치, Task 사이 리뷰, 빠른 반복.
2. **Inline Execution** — 이 세션에서 executing-plans로 체크포인트 배치 실행.

어느 방식으로 진행할까요?
