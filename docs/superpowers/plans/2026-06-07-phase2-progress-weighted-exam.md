# Phase 2 — 학습 진행률(E5) + 약점 가중 모의고사(E6) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 학습문서 방문을 "열람"으로 집계해 진행률(열람 N/총·최고 정답률·마지막 응시일)을 랜딩·cert 상세에 정직하게 노출하고(E5), 누적 약점 Task에 출제를 가중한 별도 "약점 집중 모의고사"를 3회 응시 게이트로 제공한다(E6).

**Architecture:** 모든 파생은 순수 모듈(`StudyProgress`·`weightByTaskFromReport`)로 분리하고, localStorage 접근은 기존 `KvBackend` 패턴 스토어(`ViewedDocsStore`)로 캡슐화한다. E6는 기존 `mock_exam.dart` 샘플러를 키 비의존(generic)으로 일반화해 도메인(int)·Task(String) 양쪽에 재사용하고, `CertExamPage`에 `weighted` 플래그를 더해 통합/약점 두 모드를 한 위젯으로 처리한다.

**Tech Stack:** Flutter Web (Dart) · go_router(해시 라우팅) · flutter_test. 페이지는 `SelectionArea`라 위젯 렌더 테스트 금지 → 순수 모듈·스토어 단위테스트 + 라우팅 redirect 테스트 + headless dogfood로 커버.

**환경 주의(매 세션 함정):**
- git 루트 = `D:\workspace\awc-docs`, Flutter 코드 = `flutter_app\`(바로 아래). flutter/test/analyze는 **PowerShell**에서 `flutter_app`기준, git은 **항상** `-C D:/workspace/awc-docs`.
- 커밋은 `main` 직접(피처 브랜치 아님, 사용자 선택).
- 테스트 실행: `flutter test`(현재 63개 green, 이 플랜으로 신규 추가).

**참고 스펙:** `docs/superpowers/specs/2026-06-07-phase2-progress-weighted-exam-design.md`

---

## File Structure

**신규 (순수/스토어 — 단위 테스트 대상):**
- `flutter_app/lib/data/viewed_docs_store.dart` — 열람 Task 집합 영속(localStorage).
- `flutter_app/lib/data/study_progress.dart` — 진행률 순수 파생.
- `flutter_app/lib/data/weighted_exam.dart` — Task 가중 + 3회 게이트 순수 헬퍼.
- `flutter_app/test/viewed_docs_store_test.dart`
- `flutter_app/test/study_progress_test.dart`
- `flutter_app/test/weighted_exam_test.dart`
- `flutter_app/test/attempt_presented_test.dart`

**수정:**
- `flutter_app/lib/data/mock_exam.dart` — 샘플러 generic 일반화(+ `buildMockExam` 호환 래퍼).
- `flutter_app/lib/data/attempt_presented.dart` — `taskFromExamId`에 `-weak` 집계 인식.
- `flutter_app/lib/pages/study_doc_page.dart` — 방문 시 열람 마킹(Stateful 전환).
- `flutter_app/lib/pages/cert_detail_page.dart` — 진행률 배너.
- `flutter_app/lib/pages/home_page.dart` — 학습문서 카드 진행률 배지.
- `flutter_app/lib/pages/cert_exam_page.dart` — `weighted` 모드.
- `flutter_app/lib/app_router.dart` — `/cert/:code/exam/weak` 라우트.
- `flutter_app/test/mock_exam_test.dart` — Task-키 샘플 케이스 추가(도메인 케이스는 회귀 유지).
- `flutter_app/test/app_router_test.dart` — weak 경로 redirect.

---

## Task 1: ViewedDocsStore (열람 영속)

**Files:**
- Create: `flutter_app/lib/data/viewed_docs_store.dart`
- Test: `flutter_app/test/viewed_docs_store_test.dart`

- [ ] **Step 1: 실패 테스트 작성**

`flutter_app/test/viewed_docs_store_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/viewed_docs_store.dart';

void main() {
  test('markViewed 멱등 · 자격증 분리', () {
    final store = ViewedDocsStore(backend: MemoryBackend());
    expect(store.viewed('CLF-C02'), isEmpty);

    store.markViewed('CLF-C02', 'clf-t1-1');
    store.markViewed('CLF-C02', 'clf-t1-1'); // 중복 → 무변경
    store.markViewed('CLF-C02', 'clf-t2-1');
    store.markViewed('SAA-C03', 'saa-t1-1');

    expect(store.viewed('CLF-C02'), {'clf-t1-1', 'clf-t2-1'});
    expect(store.viewed('SAA-C03'), {'saa-t1-1'});
  });

  test('영속 백엔드 공유 시 재로드해도 유지', () {
    final backend = MemoryBackend();
    ViewedDocsStore(backend: backend).markViewed('CLF-C02', 'clf-t1-1');
    expect(ViewedDocsStore(backend: backend).viewed('CLF-C02'), {'clf-t1-1'});
  });

  test('손상 데이터는 빈 결과로 무시', () {
    final corrupt = MemoryBackend()..write('awsdocs.viewed.v1', '{not json');
    expect(ViewedDocsStore(backend: corrupt).viewed('CLF-C02'), isEmpty);
  });
}
```

- [ ] **Step 2: 실패 확인**

Run (PowerShell, in `flutter_app`): `flutter test test/viewed_docs_store_test.dart`
Expected: FAIL — `viewed_docs_store.dart` 없음(컴파일 에러).

- [ ] **Step 3: 구현**

`flutter_app/lib/data/viewed_docs_store.dart`:
```dart
import 'dart:convert';

import 'local_kv.dart';

// 소비자가 MemoryBackend/KvBackend를 함께 보도록 re-export(HistoryStore 선례).
export 'local_kv.dart' show KvBackend, MemoryBackend, defaultBackend;

/// 열람한 학습문서 Task 집합을 자격증별로 영속한다(방문 = 열람).
/// 멀티탭은 last-write-wins(스펙 §E5, 원안 §4). 손상 데이터는 빈 결과.
class ViewedDocsStore {
  ViewedDocsStore({KvBackend? backend}) : _b = backend ?? defaultBackend();

  final KvBackend _b;
  static const _key = 'awsdocs.viewed.v1';

  Map<String, List<String>> _read() {
    final raw = _b.read(_key);
    if (raw == null || raw.isEmpty) return {};
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return {
        for (final e in m.entries)
          e.key: ((e.value as List?) ?? const [])
              .map((x) => x.toString())
              .toList(),
      };
    } catch (_) {
      return {}; // 손상 데이터 무시
    }
  }

  /// 해당 자격증에서 열람한 Task ID 집합.
  Set<String> viewed(String certId) => (_read()[certId] ?? const []).toSet();

  /// 방문 기록(이미 있으면 무변경).
  void markViewed(String certId, String taskId) {
    final m = _read();
    final list = m[certId] ?? <String>[];
    if (list.contains(taskId)) return;
    m[certId] = [...list, taskId];
    _b.write(_key, jsonEncode(m));
  }
}
```

- [ ] **Step 4: 통과 확인**

Run: `flutter test test/viewed_docs_store_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 5: 커밋**

```bash
git -C D:/workspace/awc-docs add flutter_app/lib/data/viewed_docs_store.dart flutter_app/test/viewed_docs_store_test.dart
git -C D:/workspace/awc-docs commit -m "feat: ViewedDocsStore — 학습문서 열람(방문) 영속"
```

---

## Task 2: StudyProgress (진행률 순수 파생)

**Files:**
- Create: `flutter_app/lib/data/study_progress.dart`
- Test: `flutter_app/test/study_progress_test.dart`

- [ ] **Step 1: 실패 테스트 작성**

`flutter_app/test/study_progress_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/models/attempt_record.dart';
import 'package:aws_docs/data/study_progress.dart';

const _all = ['clf-t1-1', 'clf-t1-2', 'clf-t2-1'];

AttemptRecord _rec({
  required String date,
  required int correct,
  required int total,
  String mode = 'practice',
  String certId = 'CLF-C02',
}) =>
    AttemptRecord(
      certId: certId,
      examId: 'practice:clf-t1-1',
      mode: mode,
      date: date,
      correct: correct,
      total: total,
      wrongQuestionIds: const [],
      flaggedQuestionIds: const [],
      durationSpentSec: 60,
    );

void main() {
  test('이력·열람 없으면 빈 상태', () {
    final p = StudyProgress.build(
      certId: 'CLF-C02', allTaskIds: _all,
      viewedTaskIds: const {}, history: const [],
    );
    expect(p.viewedCount, 0);
    expect(p.totalDocs, 3);
    expect(p.bestRatePct, isNull);
    expect(p.lastAttemptIso, isNull);
    expect(p.hasAny, isFalse);
  });

  test('열람은 현재 인덱스 교집합만(stale 제외, 분자 ≤ 분모)', () {
    final p = StudyProgress.build(
      certId: 'CLF-C02', allTaskIds: _all,
      viewedTaskIds: const {'clf-t1-1', 'clf-t9-9'}, // t9-9 = 삭제됨
      history: const [],
    );
    expect(p.viewedCount, 1);
    expect(p.totalDocs, 3);
    expect(p.hasAny, isTrue); // 열람 있으면 true
  });

  test('최고 정답률·마지막 응시일(review·타 cert·total0 제외)', () {
    final p = StudyProgress.build(
      certId: 'CLF-C02', allTaskIds: _all, viewedTaskIds: const {},
      history: [
        _rec(date: '2026-06-01', correct: 3, total: 5), // 60%
        _rec(date: '2026-06-03', correct: 9, total: 10), // 90% ← 최고
        _rec(date: '2026-06-05', correct: 5, total: 5, mode: 'review'), // 무시
        _rec(date: '2026-06-09', correct: 1, total: 1, certId: 'SAA-C03'), // 무시
        _rec(date: '2026-06-04', correct: 0, total: 0), // total0 무시
      ],
    );
    expect(p.bestRatePct, 90);
    expect(p.lastAttemptIso, '2026-06-03'); // review/타cert/total0 제외 후 최신
    expect(p.hasAny, isTrue);
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/study_progress_test.dart`
Expected: FAIL — `study_progress.dart` 없음.

- [ ] **Step 3: 구현**

`flutter_app/lib/data/study_progress.dart`:
```dart
import '../models/attempt_record.dart';

/// 학습 진행률 순수 파생: 열람 문서 수(현재 인덱스 기준) + 최고 정답률 + 마지막 응시일.
/// 자산/스토어 로드는 호출측 책임 — 모듈은 입력만으로 계산.
class StudyProgress {
  const StudyProgress({
    required this.viewedCount,
    required this.totalDocs,
    required this.bestRatePct,
    required this.lastAttemptIso,
  });

  final int viewedCount; // 현재 인덱스에 존재하는 열람 Task 수(stale 제외)
  final int totalDocs; // 현재 인덱스 총 문서 수
  final int? bestRatePct; // 비-review 이력 최고 정답률(%), 없으면 null
  final String? lastAttemptIso; // 마지막 비-review 응시일(ISO), 없으면 null

  bool get hasAny => viewedCount > 0 || bestRatePct != null;

  factory StudyProgress.build({
    required String certId,
    required List<String> allTaskIds,
    required Set<String> viewedTaskIds,
    required List<AttemptRecord> history,
  }) {
    final all = allTaskIds.toSet();
    final viewedCount = viewedTaskIds.where(all.contains).length;

    int? bestPct;
    String? lastIso;
    for (final r in history) {
      if (r.certId != certId || r.mode == 'review' || r.total <= 0) continue;
      final pct = (r.correct / r.total * 100).round();
      if (bestPct == null || pct > bestPct) bestPct = pct;
      if (lastIso == null || r.date.compareTo(lastIso) > 0) lastIso = r.date;
    }

    return StudyProgress(
      viewedCount: viewedCount,
      totalDocs: allTaskIds.length,
      bestRatePct: bestPct,
      lastAttemptIso: lastIso,
    );
  }
}
```

- [ ] **Step 4: 통과 확인**

Run: `flutter test test/study_progress_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 5: 커밋**

```bash
git -C D:/workspace/awc-docs add flutter_app/lib/data/study_progress.dart flutter_app/test/study_progress_test.dart
git -C D:/workspace/awc-docs commit -m "feat: StudyProgress — 열람률·최고점·마지막 응시일 순수 파생"
```

---

## Task 3: mock_exam 샘플러 generic 일반화

기존 `allocateByWeight`·`buildMockExam`(도메인 int 키)를 키 비의존으로 일반화해 Task(String) 키에도 재사용한다. **도메인 동작은 불변** — 기존 `mock_exam_test`의 도메인 케이스가 회귀 가드. `buildMockExam`은 호환 래퍼로 유지.

**Files:**
- Modify: `flutter_app/lib/data/mock_exam.dart`
- Test: `flutter_app/test/mock_exam_test.dart` (Task-키 케이스 추가)

- [ ] **Step 1: 실패 테스트 추가**

`flutter_app/test/mock_exam_test.dart` `main()` 안에 추가(기존 테스트는 그대로 유지):
```dart
  test('buildSampledExam<String>: Task 키 — 합 N · 전부 풀 소속 · 결정적', () {
    final pool = {
      'clf-t2-1': [for (var i = 0; i < 10; i++) _q('t21q$i', 2)],
      'clf-t3-1': [for (var i = 0; i < 10; i++) _q('t31q$i', 3)],
    };
    const w = {'clf-t2-1': 70, 'clf-t3-1': 30};
    final a = buildSampledExam<String>(
        poolByKey: pool, weightByKey: w, n: 10, rng: Random(7));
    final b = buildSampledExam<String>(
        poolByKey: pool, weightByKey: w, n: 10, rng: Random(7));
    expect(a.map((q) => q.id).toList(), b.map((q) => q.id).toList());
    expect(a.length, 10);
    final allIds = {for (final t in pool.values) for (final q in t) q.id};
    expect(a.every((q) => allIds.contains(q.id)), isTrue);
    expect(a.map((q) => q.id).toSet().length, 10);
  });

  test('allocateByWeight<String>: 합이 N', () {
    final a = allocateByWeight<String>({'a': 70, 'b': 30}, 10);
    expect(a.values.fold(0, (s, v) => s + v), 10);
    expect(a['a']! > a['b']!, isTrue); // 가중 큰 쪽 더 많이
  });
```

상단 `_q` 헬퍼는 domain만 라벨용으로 쓰므로 Task 케이스에서도 그대로 사용 가능(기존 정의 재사용).

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/mock_exam_test.dart`
Expected: FAIL — `buildSampledExam` 미정의, `allocateByWeight<String>` 타입 불일치.

- [ ] **Step 3: 구현 — mock_exam.dart 일반화**

`flutter_app/lib/data/mock_exam.dart`에서 `allocateByWeight`와 `buildMockExam`를 아래로 교체(나머지 `groupByDomain`/`indexById`/`restoreOrdered`는 불변):

```dart
/// 키별 가중에 비례해 n을 배분(floor 후 largest-remainder로 +1). 합 == n 보장.
/// 키 타입 비의존(도메인 int·Task String 공용).
Map<K, int> allocateByWeight<K>(Map<K, int> weightByKey, int n) {
  if (weightByKey.isEmpty) return {};
  if (n <= 0) return {for (final k in weightByKey.keys) k: 0};

  final totalWeight = weightByKey.values.fold(0, (s, w) => s + w);
  if (totalWeight <= 0) {
    final keys = weightByKey.keys.toList();
    final base = n ~/ keys.length;
    final alloc = {for (final k in keys) k: base};
    var rem = n - base * keys.length;
    for (var i = 0; i < keys.length && rem > 0; i++, rem--) {
      alloc[keys[i]] = alloc[keys[i]]! + 1;
    }
    return alloc;
  }

  final exact = <K, double>{};
  final alloc = <K, int>{};
  for (final e in weightByKey.entries) {
    final v = n * e.value / totalWeight;
    exact[e.key] = v;
    alloc[e.key] = v.floor();
  }
  var assigned = alloc.values.fold(0, (s, v) => s + v);
  final byFraction = exact.keys.toList()
    ..sort((a, b) => (exact[b]! - exact[b]!.floorToDouble())
        .compareTo(exact[a]! - exact[a]!.floorToDouble()));
  for (var i = 0; assigned < n; i++, assigned++) {
    final k = byFraction[i % byFraction.length];
    alloc[k] = alloc[k]! + 1;
  }
  return alloc;
}

/// 키별 가중으로 n문항을 샘플링해 순서를 섞어 반환. [rng] 주입으로 결정적.
/// 특정 키 풀이 배분량보다 적으면 잔여 키 문항에서 보충(총 n 유지, 풀<n이면 최대).
List<Question> buildSampledExam<K>({
  required Map<K, List<Question>> poolByKey,
  required Map<K, int> weightByKey,
  required int n,
  required Random rng,
}) {
  final alloc = allocateByWeight<K>(weightByKey, n);
  final picked = <Question>[];
  final leftovers = <Question>[];

  final keys = <K>{...poolByKey.keys, ...alloc.keys}.toList();
  for (final k in keys) {
    final pool = [...?poolByKey[k]]..shuffle(rng);
    final want = alloc[k] ?? 0;
    final take = want < pool.length ? want : pool.length;
    picked.addAll(pool.take(take));
    leftovers.addAll(pool.skip(take));
  }

  if (picked.length < n && leftovers.isNotEmpty) {
    leftovers.shuffle(rng);
    picked.addAll(leftovers.take(n - picked.length));
  }

  picked.shuffle(rng);
  return picked;
}

/// 도메인 가중 통합 모의고사(호환 래퍼). 키=도메인 번호(int).
List<Question> buildMockExam({
  required Map<int, List<Question>> poolByDomain,
  required Map<int, int> weightByDomain,
  required int n,
  required Random rng,
}) =>
    buildSampledExam<int>(
        poolByKey: poolByDomain, weightByKey: weightByDomain, n: n, rng: rng);
```

> 주의: 기존 도메인 코드는 키 순서를 `..sort()`했으나, 일반 K는 비교 불가라 정렬을 제거했다. 순서는 최종 `picked.shuffle(rng)`가 결정하므로 출제 결과에 영향 없음(도메인 회귀 테스트가 이를 보장).

- [ ] **Step 4: 통과 확인**

Run: `flutter test test/mock_exam_test.dart`
Expected: PASS — 기존 도메인 케이스(회귀) + 신규 Task 케이스 모두.

- [ ] **Step 5: 커밋**

```bash
git -C D:/workspace/awc-docs add flutter_app/lib/data/mock_exam.dart flutter_app/test/mock_exam_test.dart
git -C D:/workspace/awc-docs commit -m "refactor: mock_exam 샘플러 키 비의존 일반화(buildSampledExam<K>)"
```

---

## Task 4: weighted_exam (Task 가중 + 3회 게이트)

**Files:**
- Create: `flutter_app/lib/data/weighted_exam.dart`
- Test: `flutter_app/test/weighted_exam_test.dart`

- [ ] **Step 1: 실패 테스트 작성**

`flutter_app/test/weighted_exam_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/models/attempt_record.dart';
import 'package:aws_docs/data/task_score_report.dart';
import 'package:aws_docs/data/weighted_exam.dart';

const _tasks = {
  'clf-t2-1-q1': 'clf-t2-1',
  'clf-t2-1-q2': 'clf-t2-1',
  'clf-t3-1-q1': 'clf-t3-1',
  'clf-t4-1-q1': 'clf-t4-1',
};
const _order = ['clf-t2-1', 'clf-t3-1', 'clf-t4-1'];

AttemptRecord _rec({
  required String examId,
  required String date,
  required List<String> presented,
  required List<String> wrong,
  String mode = 'practice',
}) =>
    AttemptRecord(
      certId: 'CLF-C02', examId: examId, mode: mode, date: date,
      correct: presented.length - wrong.length, total: presented.length,
      wrongQuestionIds: wrong, flaggedQuestionIds: const [],
      presentedQuestionIds: presented, durationSpentSec: 60,
    );

void main() {
  test('약점 Task 가중 > ok Task > 미응시(=floor), 전 Task ≥ floor', () {
    final report = TaskScoreReport.build(
      certId: 'CLF-C02', taskByQuestionId: _tasks, taskOrder: _order,
      history: [
        // t2-1: 둘 다 오답(0%) → 큰 가중
        _rec(examId: 'practice:clf-t2-1', date: '2026-06-01',
            presented: ['clf-t2-1-q1', 'clf-t2-1-q2'],
            wrong: ['clf-t2-1-q1', 'clf-t2-1-q2']),
        // t3-1: 정답(100%) → floor
        _rec(examId: 'practice:clf-t3-1', date: '2026-06-02',
            presented: ['clf-t3-1-q1'], wrong: []),
        // t4-1: 미응시
      ],
    );
    final w = weightByTaskFromReport(report, scale: 100, floor: 10);
    expect(w['clf-t2-1'], 110); // 10 + (1-0)*100
    expect(w['clf-t3-1'], 10); // 10 + (1-1)*100
    expect(w['clf-t4-1'], 10); // 미응시 → floor만
    expect(w.values.every((v) => v >= 10), isTrue); // 전 Task 출제 보장
    expect(w['clf-t2-1']! > w['clf-t3-1']!, isTrue);
  });

  test('게이트: 비-review 응시 3회 미만 잠김, 3회 해제', () {
    AttemptRecord r(String date, String mode) => AttemptRecord(
        certId: 'CLF-C02', examId: 'exam:CLF-C02-mock', mode: mode,
        date: date, correct: 1, total: 1, wrongQuestionIds: const [],
        flaggedQuestionIds: const [], durationSpentSec: 1);
    final two = [r('2026-06-01', 'practice'), r('2026-06-02', 'exam')];
    final withReview = [...two, r('2026-06-03', 'review')]; // review 미포함
    final three = [...two, r('2026-06-04', 'exam')];

    expect(nonReviewAttemptCount('CLF-C02', two), 2);
    expect(weightedExamUnlocked('CLF-C02', two), isFalse);
    expect(weightedExamUnlocked('CLF-C02', withReview), isFalse); // 여전히 2회
    expect(nonReviewAttemptCount('CLF-C02', three), 3);
    expect(weightedExamUnlocked('CLF-C02', three), isTrue);
  });

  test('게이트: 타 cert 응시는 미포함', () {
    final h = [
      AttemptRecord(certId: 'SAA-C03', examId: 'x', mode: 'practice',
          date: '2026-06-01', correct: 1, total: 1, wrongQuestionIds: const [],
          flaggedQuestionIds: const [], durationSpentSec: 1),
    ];
    expect(nonReviewAttemptCount('CLF-C02', h), 0);
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/weighted_exam_test.dart`
Expected: FAIL — `weighted_exam.dart` 없음.

- [ ] **Step 3: 구현**

`flutter_app/lib/data/weighted_exam.dart`:
```dart
import '../models/attempt_record.dart';
import 'task_score_report.dart';

/// 약점 집중 모의고사 활성 게이트: 비-review 응시 최소 횟수.
const int kWeightedExamMinAttempts = 3;

/// 가중 기본값 — floor: 전 Task 최소 출제 보장, scale: 오답률 1.0당 가산.
const int kWeightFloor = 10;
const int kWeightScale = 100;

/// Task별 출제 가중 = floor + round((1 - 정답률) * scale).
/// 미응시 Task는 floor만(약점 근거 없음 → 과대 가중 방지, 출제는 유지).
/// 모든 Task ≥ floor → 전 Task 노출 보장(스펙 D6, 원안 "최소 가중치 보장").
Map<String, int> weightByTaskFromReport(
  TaskScoreReport report, {
  int scale = kWeightScale,
  int floor = kWeightFloor,
}) {
  final w = <String, int>{};
  for (final t in report.tasks) {
    final rate = t.rate;
    if (rate == null) {
      w[t.taskId] = floor; // 미응시
    } else {
      w[t.taskId] = floor + ((1 - rate) * scale).round();
    }
  }
  return w;
}

/// 해당 자격증의 비-review 응시 횟수(게이트 판정용).
int nonReviewAttemptCount(String certId, List<AttemptRecord> history) =>
    history.where((r) => r.certId == certId && r.mode != 'review').length;

/// 약점 집중 모의고사 활성 여부(응시 3회+).
bool weightedExamUnlocked(String certId, List<AttemptRecord> history) =>
    nonReviewAttemptCount(certId, history) >= kWeightedExamMinAttempts;
```

- [ ] **Step 4: 통과 확인**

Run: `flutter test test/weighted_exam_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 5: 커밋**

```bash
git -C D:/workspace/awc-docs add flutter_app/lib/data/weighted_exam.dart flutter_app/test/weighted_exam_test.dart
git -C D:/workspace/awc-docs commit -m "feat: weighted_exam — Task 오답률 가중 + 3회 응시 게이트"
```

---

## Task 5: taskFromExamId — `-weak` 집계 인식

`-weak` 세션도 통합 모의고사처럼 단일 Task가 아닌 집계 시험으로 인식해야 한다(레거시 폴백 일관성).

**Files:**
- Modify: `flutter_app/lib/data/attempt_presented.dart`
- Test: `flutter_app/test/attempt_presented_test.dart` (신규)

- [ ] **Step 1: 실패 테스트 작성**

`flutter_app/test/attempt_presented_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/attempt_presented.dart';

void main() {
  test('단일 Task examId → taskId', () {
    expect(taskFromExamId('practice:clf-t2-1'), 'clf-t2-1');
    expect(taskFromExamId('exam:clf-t2-1'), 'clf-t2-1');
    expect(taskFromExamId('review:clf-t2-1'), 'clf-t2-1');
  });

  test('집계 시험(-mock/-weak) → null', () {
    expect(taskFromExamId('exam:CLF-C02-mock'), isNull);
    expect(taskFromExamId('exam:CLF-C02-weak'), isNull);
  });

  test('구분자 없음/빈 값 → null', () {
    expect(taskFromExamId('nocolon'), isNull);
    expect(taskFromExamId('exam:'), isNull);
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/attempt_presented_test.dart`
Expected: FAIL — `exam:CLF-C02-weak`가 `'CLF-C02-weak'` 반환(현 구현은 `-mock`만 null).

- [ ] **Step 3: 구현 — `taskFromExamId` 수정**

`flutter_app/lib/data/attempt_presented.dart`의 `taskFromExamId`를 교체:
```dart
/// 'practice:clf-t2-1' / 'exam:clf-t2-1' / 'review:clf-t2-1' → 'clf-t2-1'.
/// 집계 시험('...-mock' 통합 / '...-weak' 약점 집중)은 단일 Task 아님 → null.
String? taskFromExamId(String examId) {
  final i = examId.indexOf(':');
  if (i < 0) return null;
  final rest = examId.substring(i + 1);
  if (rest.isEmpty) return null;
  if (rest.endsWith('-mock') || rest.endsWith('-weak')) return null;
  return rest;
}
```

- [ ] **Step 4: 통과 확인**

Run: `flutter test test/attempt_presented_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 5: 커밋**

```bash
git -C D:/workspace/awc-docs add flutter_app/lib/data/attempt_presented.dart flutter_app/test/attempt_presented_test.dart
git -C D:/workspace/awc-docs commit -m "feat: taskFromExamId — 약점 집중(-weak)도 집계 시험으로 인식"
```

---

## Task 6: StudyDocPage 방문 = 열람 마킹

**Files:**
- Modify: `flutter_app/lib/pages/study_doc_page.dart`

위젯 렌더 테스트 금지(SelectionArea). analyze + Task 12 dogfood로 검증.

- [ ] **Step 1: StatefulWidget 전환 + 마킹**

`flutter_app/lib/pages/study_doc_page.dart` 상단 import에 추가:
```dart
import '../data/viewed_docs_store.dart';
```

`StudyDocPage`를 StatelessWidget → StatefulWidget으로 전환. 클래스 선언을 아래로 교체(빌드 본문은 `build`를 State로 이동하되 내용 동일):
```dart
class StudyDocPage extends StatefulWidget {
  const StudyDocPage({super.key, required this.entry});
  final ContentEntry entry;

  @override
  State<StudyDocPage> createState() => _StudyDocPageState();
}

class _StudyDocPageState extends State<StudyDocPage> {
  @override
  void initState() {
    super.initState();
    // 방문 = 열람(스펙 D2). 부수효과만, 렌더와 분리.
    ViewedDocsStore().markViewed(widget.entry.certCode, widget.entry.taskId);
  }

  Future<StudyContent> _load() async {
    final raw = await rootBundle.loadString(widget.entry.mdAsset);
    return parseStudyDoc(raw);
  }

  @override
  Widget build(BuildContext context) {
    // 기존 build 본문과 동일. 단 `entry` 참조를 `widget.entry`로 교체.
    ...
  }
}
```
구체 변경: 기존 `build`의 `entry.title` → `widget.entry.title`, `_StartQuizButton(entry: entry)` → `_StartQuizButton(entry: widget.entry)`. `_load()`의 `entry.mdAsset` → `widget.entry.mdAsset`. `_DocHeader`/`_StartQuizButton` 등 하위 위젯은 변경 없음.

- [ ] **Step 2: analyze 무결 확인**

Run: `flutter analyze`
Expected: No issues found.

- [ ] **Step 3: 전체 테스트 회귀 확인**

Run: `flutter test`
Expected: 기존 + 신규 전부 PASS(라우터 테스트가 StudyDocPage 직접 렌더 안 하므로 영향 없음).

- [ ] **Step 4: 커밋**

```bash
git -C D:/workspace/awc-docs add flutter_app/lib/pages/study_doc_page.dart
git -C D:/workspace/awc-docs commit -m "feat: 학습문서 방문 시 열람 기록(StudyDocPage)"
```

---

## Task 7: cert 상세 진행률 배너

`_load()`가 이미 뱅크를 로드하므로 거기서 `StudyProgress`를 구성해 `_Loaded`에 추가하고, `_LearningContent` 상단에 배너를 렌더한다.

**Files:**
- Modify: `flutter_app/lib/pages/cert_detail_page.dart`

- [ ] **Step 1: import + `_Loaded` 확장 + 산출**

상단 import에 추가:
```dart
import '../data/study_progress.dart';
import '../data/viewed_docs_store.dart';
```

`_Loaded` typedef를 교체:
```dart
typedef _Loaded = ({
  ExamGuide? guide,
  ExamSummary? summary,
  Map<String, int> weakByTask,
  StudyProgress progress,
});
```

`_load()`에서 `weakByTask` 계산 직후(같은 `taskByQuestionId` 루프 뒤), `return` 전에 추가:
```dart
    final entries = contentFor(cert.code);
    final progress = StudyProgress.build(
      certId: cert.code,
      allTaskIds: [for (final e in entries) e.taskId],
      viewedTaskIds: ViewedDocsStore().viewed(cert.code),
      history: HistoryStore().all(),
    );
```
그리고 `return` 문을 교체:
```dart
    return (
      guide: guide,
      summary: summary,
      weakByTask: weakByTask,
      progress: progress,
    );
```

- [ ] **Step 2: 배너를 `_LearningContent`에 전달**

`build`의 `_LearningContent(...)` 호출에 progress 전달:
```dart
                          if (contentFor(cert.code).isNotEmpty)
                            _LearningContent(
                              entries: contentFor(cert.code),
                              weakByTask: snap.data?.weakByTask ?? const {},
                              progress: snap.data?.progress,
                            ),
```

`_LearningContent` 클래스에 필드 추가 + 배너 렌더:
```dart
class _LearningContent extends StatelessWidget {
  const _LearningContent({
    required this.entries,
    required this.weakByTask,
    required this.progress,
  });
  final List<ContentEntry> entries;
  final Map<String, int> weakByTask;
  final StudyProgress? progress;
```

`build` 안 `const SizedBox(height: Gap.lg),`(설명 텍스트 아래, `for (final e in entries)` 위)에 배너 삽입:
```dart
          if (progress != null && progress!.hasAny) ...[
            _ProgressBanner(progress: progress!),
            const SizedBox(height: Gap.lg),
          ],
```

- [ ] **Step 3: `_ProgressBanner` 위젯 추가**

`cert_detail_page.dart` 하단 `// ── small shared widgets ──` 근처에 추가:
```dart
/// 학습 진행률 배너(열람률 + 최고 정답률 + 마지막 응시일). 정직 표기 툴팁.
class _ProgressBanner extends StatelessWidget {
  const _ProgressBanner({required this.progress});
  final StudyProgress progress;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    final p = progress;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Gap.lg),
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: c.border),
      ),
      child: Wrap(
        spacing: Gap.xl,
        runSpacing: Gap.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Tooltip(
            message: '학습 자료가 추가되면 진도율이 변할 수 있습니다.',
            child: _stat(c, t, '문서 열람', '${p.viewedCount}/${p.totalDocs}'),
          ),
          if (p.bestRatePct != null)
            _stat(c, t, '최고 정답률', '${p.bestRatePct}%'),
          if (p.lastAttemptIso != null)
            _stat(c, t, '마지막 응시', p.lastAttemptIso!.split('T').first),
        ],
      ),
    );
  }

  Widget _stat(AppColors c, TextTheme t, String label, String value) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: t.labelSmall?.copyWith(color: c.textFaint)),
          const SizedBox(height: 2),
          Text(value,
              style: t.titleMedium?.copyWith(
                  color: c.accent, fontFamily: AppTheme.monoFamily)),
        ],
      );
}
```

- [ ] **Step 4: analyze + 전체 테스트**

Run: `flutter analyze` → No issues.
Run: `flutter test` → 전부 PASS(cert_detail은 라우터 테스트에서 redirect만, 렌더 안 함).

- [ ] **Step 5: 커밋**

```bash
git -C D:/workspace/awc-docs add flutter_app/lib/pages/cert_detail_page.dart
git -C D:/workspace/awc-docs commit -m "feat: cert 상세 학습 진행률 배너(열람률·최고점·마지막 응시)"
```

---

## Task 8: 랜딩 학습문서 카드 진행률 배지

`_StudyDocsSection`(StatelessWidget)이 동기 스토어를 읽어 카드별 `StudyProgress`를 구성하고, `_ContentCertCard`에 옵셔널 배지를 추가한다. 열람 0이면 배지 비노출.

**Files:**
- Modify: `flutter_app/lib/pages/home_page.dart`

- [ ] **Step 1: import 추가**

`home_page.dart` 상단:
```dart
import '../data/history_store.dart';
import '../data/study_progress.dart';
import '../data/viewed_docs_store.dart';
```

- [ ] **Step 2: `_ContentCertCard`에 옵셔널 progress 배지**

`_ContentCertCard` 생성자/필드에 추가:
```dart
  const _ContentCertCard({
    required this.cert,
    required this.summaryLabel,
    required this.cta,
    required this.onTap,
    this.viewedBadge,
  });
  final Certification cert;
  final String summaryLabel;
  final String cta;
  final VoidCallback onTap;
  final String? viewedBadge; // 예: '열람 5/19' — null이면 미표시
```

`build`의 `summaryLabel` 칩을 감싼 부분에 배지 추가. `Container`(summaryLabel 칩) 다음 줄에:
```dart
            if (viewedBadge != null) ...[
              const SizedBox(height: Gap.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: c.accentWeak,
                  borderRadius: BorderRadius.circular(Radii.full),
                ),
                child: Text(viewedBadge!,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: c.accentStrong)),
              ),
            ],
```
(위치: `Container(...summaryLabel...)` 와 `const SizedBox(height: Gap.md)` 사이.)

- [ ] **Step 3: `_StudyDocsSection`에서 progress 산출·주입**

`_StudyDocsSection.build`의 학습문서 카드 루프를 교체:
```dart
    final viewedStore = ViewedDocsStore();
    final history = HistoryStore().all();
    ...
              for (final cert in withContent)
                _ContentCertCard(
                  cert: cert,
                  summaryLabel: () {
                    final s = certContentSummary(cert.code);
                    return '검증 학습문서 ${s.docs} · 총 ${s.questions}문항';
                  }(),
                  cta: '학습문서 보기 →',
                  onTap: () => context.push('/cert/${cert.code}'),
                  viewedBadge: () {
                    final p = StudyProgress.build(
                      certId: cert.code,
                      allTaskIds: [for (final e in contentFor(cert.code)) e.taskId],
                      viewedTaskIds: viewedStore.viewed(cert.code),
                      history: history,
                    );
                    return p.viewedCount > 0
                        ? '열람 ${p.viewedCount}/${p.totalDocs}'
                        : null;
                  }(),
                ),
```
`contentFor`는 이미 `content_index.dart` import로 사용 가능. `_ExamsSection`(모의고사 카드)은 변경 없음(배지 미표시).

- [ ] **Step 4: analyze + 전체 테스트**

Run: `flutter analyze` → No issues.
Run: `flutter test` → 전부 PASS. (`home_sections_test`는 MemoryBackend라 열람 0 → 배지 없음 → 기존 기대 불변.)

- [ ] **Step 5: 커밋**

```bash
git -C D:/workspace/awc-docs add flutter_app/lib/pages/home_page.dart
git -C D:/workspace/awc-docs commit -m "feat: 랜딩 학습문서 카드에 열람 진행률 배지"
```

---

## Task 9: 약점 집중 모의고사 — 라우트 + CertExamPage weighted 모드

`CertExamPage`에 `weighted` 플래그를 더해 통합/약점 두 모드를 처리한다. 약점 모드는 Task 풀 + Task 오답률 가중 + `-weak` 세션 키. 문항 수·타이머·복원·제출은 통합과 동일 로직 재사용.

**Files:**
- Modify: `flutter_app/lib/pages/cert_exam_page.dart`
- Modify: `flutter_app/lib/app_router.dart`
- Test: `flutter_app/test/app_router_test.dart` (redirect)

- [ ] **Step 1: 라우트 추가**

`app_router.dart`의 `cert/:code` 자식 routes에서 `exam` 라우트 아래에 추가:
```dart
                GoRoute(
                  path: 'exam/weak',
                  builder: (context, state) => CertExamPage(
                    cert: certByCode(state.pathParameters['code']!)!,
                    weighted: true,
                  ),
                ),
```
(주의: `cert/:code`에 이미 `redirect`가 있어 잘못된 코드는 부모에서 `/`로 보냄.)

- [ ] **Step 2: CertExamPage `weighted` 파라미터 + 모드별 로드**

import 추가:
```dart
import '../data/task_score_report.dart';
import '../data/weighted_exam.dart';
```

위젯에 플래그 추가:
```dart
class CertExamPage extends StatefulWidget {
  const CertExamPage({super.key, required this.cert, this.weighted = false});
  final Certification cert;
  final bool weighted;
```

`_examId` 게터 교체:
```dart
  String get _examId =>
      'exam:${widget.cert.code}-${widget.weighted ? 'weak' : 'mock'}';
```

`_MockLoad`에 Task 모드 필드 추가(도메인/Task 양쪽 보관, 미사용 측은 비움):
```dart
class _MockLoad {
  const _MockLoad({
    required this.pool,
    required this.weights,
    required this.taskPool,
    required this.taskWeights,
    required this.overview,
    required this.total,
    required this.restorable,
  });
  final Map<int, List<Question>> pool; // 도메인 모드
  final Map<int, int> weights; // 도메인 모드
  final Map<String, List<Question>> taskPool; // 약점 모드
  final Map<String, int> taskWeights; // 약점 모드
  final ExamOverview? overview;
  final int total;
  final _Restorable? restorable;
}
```

`_load()`를 교체(공통 로드 + 모드 분기):
```dart
  Future<_MockLoad> _load() async {
    final entries = contentFor(widget.cert.code);
    final banks = <QuestionBank>[];
    final taskByQuestionId = <String, String>{};
    final taskOrder = <String>[];
    final taskPool = <String, List<Question>>{};
    for (final e in entries) {
      try {
        final raw = await rootBundle.loadString(e.questionsAsset);
        final bank =
            QuestionBank.fromJson(json.decode(raw) as Map<String, dynamic>);
        banks.add(bank);
        taskOrder.add(e.taskId);
        taskPool[e.taskId] = bank.questions;
        for (final q in bank.questions) {
          taskByQuestionId[q.id] = e.taskId;
        }
      } catch (_) {
        // 개별 뱅크 로드 실패는 무시(나머지로 진행)
      }
    }
    final pool = groupByDomain(banks);
    final all = [for (final b in banks) ...b.questions];
    final byId = indexById(all);

    var weights = <int, int>{};
    ExamOverview? overview;
    try {
      final gRaw = await rootBundle
          .loadString('assets/exam_guides/${widget.cert.code}.json');
      final guide =
          ExamGuide.fromJson(json.decode(gRaw) as Map<String, dynamic>);
      overview = guide.overview;
      weights = {for (final d in guide.domains) d.no: d.weightPct};
    } catch (_) {
      overview = null;
    }
    if (weights.isEmpty) {
      weights = {for (final d in pool.keys) d: 1}; // 균등 폴백
    }

    // 약점 가중(약점 모드에서만 의미). TaskScoreReport → Task별 오답률 가중.
    final report = TaskScoreReport.build(
      certId: widget.cert.code,
      history: _history.all(),
      taskByQuestionId: taskByQuestionId,
      taskOrder: taskOrder,
    );
    final taskWeights = weightByTaskFromReport(report);

    // 복원 가능한 진행 세션?
    final existing = _store.load(_examId);
    _Restorable? restorable;
    if (existing != null && !existing.submitted) {
      final restored = restoreOrdered(existing.questionIds, byId);
      if (restored == null) {
        _store.clear(_examId); // 개정/불일치 폐기
      } else {
        restorable = _Restorable(existing, restored);
      }
    }

    return _MockLoad(
      pool: pool,
      weights: weights,
      taskPool: taskPool,
      taskWeights: taskWeights,
      overview: overview,
      total: all.length,
      restorable: restorable,
    );
  }
```

- [ ] **Step 3: `_startFresh` 모드 분기**

`_startFresh`의 `final sampled = buildMockExam(...)` 를 교체:
```dart
    final sampled = widget.weighted
        ? buildSampledExam<String>(
            poolByKey: d.taskPool,
            weightByKey: d.taskWeights,
            n: _targetN(d.overview),
            rng: Random(),
          )
        : buildMockExam(
            poolByDomain: d.pool,
            weightByDomain: d.weights,
            n: _targetN(d.overview),
            rng: Random(),
          );
```

- [ ] **Step 4: 제목·시작화면 모드 문구**

AppBar 제목 교체:
```dart
        title: Text(
            '${widget.cert.title} · ${widget.weighted ? '약점 집중 모의고사' : '통합 모의고사'}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
```

`_examView`의 `ExamView`에 넘기는 `bank`/`taskId`는 `_examId` 기반이 아니라 표시용이므로, 약점 모드 식별을 위해 교체:
```dart
          bank: QuestionBank(
            examGuideTaskId: '${widget.cert.code}-${widget.weighted ? 'weak' : 'mock'}',
            taskTitle: widget.weighted ? '약점 집중 모의고사' : '통합 모의고사',
            certCode: widget.cert.code,
            domain: 0,
            questions: r.questions,
          ),
          certId: widget.cert.code,
          taskId: '${widget.cert.code}-${widget.weighted ? 'weak' : 'mock'}',
```

`_startScreen`의 제목·설명·출제방식 행을 모드 분기. `Text('통합 모의고사', style: t.headlineSmall)` 및 그 아래 설명/`_infoRow(... '도메인 비중' ...)`를 교체:
```dart
              Text(widget.weighted ? '약점 집중 모의고사' : '통합 모의고사',
                  style: t.headlineSmall),
              const SizedBox(height: Gap.sm),
              Text(
                  widget.weighted
                      ? '지금까지 자주 틀린 Task가 더 자주 출제됩니다. 전체 검증 문항 풀(${d.total}개) 기반.'
                      : '자격증 전체 검증 문항 풀(${d.total}개)에서 도메인 비중에 맞춰 출제합니다.',
                  style: t.bodyMedium),
              const SizedBox(height: Gap.lg),
              _infoRow(c, t, '문항 수', '$cap문항'),
              _infoRow(c, t, '제한 시간', '$mins분'),
              if (pass != null)
                _infoRow(c, t, '합격선', '$pass / 1000 (정답률과 다름)'),
              _infoRow(c, t, '출제 방식',
                  widget.weighted ? '약점 Task 가중(자주 틀린 Task 우선)' : _weightLabel(d.weights)),
```

- [ ] **Step 5: redirect 테스트 추가**

`app_router_test.dart` `main()`에 추가:
```dart
  testWidgets('잘못된 cert weak 모의고사 경로 → "/"로 redirect', (tester) async {
    await tester.pumpWidget(_app('/cert/NOPE/exam/weak'));
    await tester.pump();
    expect(find.byType(HomePage), findsOneWidget);
  });
```
(유효 경로 `/cert/CLF-C02/exam/weak`의 실제 렌더는 SelectionArea/비동기라 위젯 테스트 금지 — dogfood로 검증.)

- [ ] **Step 6: analyze + 전체 테스트**

Run: `flutter analyze` → No issues.
Run: `flutter test` → 전부 PASS(신규 redirect 포함).

- [ ] **Step 7: 커밋**

```bash
git -C D:/workspace/awc-docs add flutter_app/lib/pages/cert_exam_page.dart flutter_app/lib/app_router.dart flutter_app/test/app_router_test.dart
git -C D:/workspace/awc-docs commit -m "feat: 약점 집중 모의고사 — /cert/:code/exam/weak + CertExamPage weighted 모드"
```

---

## Task 10: 약점 집중 진입 버튼(게이트) — cert 상세 + 랜딩

이력 3회+면 진입, 미만이면 잠김 + "응시 기록이 3회 쌓이면 열립니다 (N/3)".

**Files:**
- Modify: `flutter_app/lib/pages/cert_detail_page.dart`
- Modify: `flutter_app/lib/pages/home_page.dart`

- [ ] **Step 1: cert 상세 — 게이트 데이터**

`cert_detail_page.dart` import 추가:
```dart
import '../data/weighted_exam.dart';
```

`_Loaded` typedef에 필드 추가:
```dart
typedef _Loaded = ({
  ExamGuide? guide,
  ExamSummary? summary,
  Map<String, int> weakByTask,
  StudyProgress progress,
  int attemptCount,
});
```

`_load()`에서 progress 산출 근처에 추가하고 return에 포함:
```dart
    final history = HistoryStore().all();
    final attemptCount = nonReviewAttemptCount(cert.code, history);
```
(주의: `_load`는 이미 `HistoryStore().all()`을 `weakByTask`·`progress`에서 호출한다. 중복 호출을 피하려면 `_load` 상단에서 `final history = HistoryStore().all();`로 한 번 읽어 `WrongAnswerIndex.build`·`StudyProgress.build`·`nonReviewAttemptCount`에 공유한다.)
return에 `attemptCount: attemptCount,` 추가. `_LearningContent` 호출에 `attemptCount: snap.data?.attemptCount ?? 0,` 전달.

- [ ] **Step 2: cert 상세 — 진입 버튼 위젯**

`_LearningContent`에 필드 추가:
```dart
  const _LearningContent({
    required this.entries,
    required this.weakByTask,
    required this.progress,
    required this.attemptCount,
  });
  ...
  final int attemptCount;
```

약점 리포트 진입 `InkWell` 다음(오답노트 진입 위)에 약점 집중 진입 추가:
```dart
          Padding(
            padding: const EdgeInsets.only(top: Gap.xs),
            child: () {
              final unlocked = attemptCount >= kWeightedExamMinAttempts;
              final certCode = entries.first.certCode;
              return InkWell(
                onTap: unlocked
                    ? () => context.push('/cert/$certCode/exam/weak')
                    : null,
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
                      Icon(unlocked ? Icons.bolt_outlined : Icons.lock_outline,
                          size: 18,
                          color: unlocked ? c.accent : c.textFaint),
                      const SizedBox(width: Gap.sm),
                      Expanded(
                        child: Text(
                            unlocked
                                ? '약점 집중 모의고사 · 자주 틀린 Task 가중 출제'
                                : '약점 집중 모의고사 · 응시 기록이 3회 쌓이면 열립니다 ($attemptCount/$kWeightedExamMinAttempts)',
                            style: t.titleMedium?.copyWith(
                                color: unlocked ? c.text : c.textMuted)),
                      ),
                      if (unlocked)
                        Text('시작 →',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: c.accent)),
                    ],
                  ),
                ),
              );
            }(),
          ),
```

- [ ] **Step 3: 랜딩 — 모의고사 섹션 약점 진입**

`home_page.dart` import 추가:
```dart
import '../data/weighted_exam.dart';
```

`_ExamsSection.build`에서 통합 모의고사 카드 `Wrap` 뒤에 약점 집중 진입 줄을 추가(잠김 상태도 노출해 동기 부여). `Wrap(...)`(통합 카드들) 다음, `if (pending.isNotEmpty)` 앞에:
```dart
          ...[
            const SizedBox(height: Gap.lg),
            for (final cert in withContent)
              () {
                final unlocked = weightedExamUnlocked(cert.code, history);
                return Padding(
                  padding: const EdgeInsets.only(bottom: Gap.sm),
                  child: InkWell(
                    onTap: unlocked
                        ? () => context.push('/cert/${cert.code}/exam/weak')
                        : null,
                    borderRadius: BorderRadius.circular(Radii.md),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(Gap.lg),
                      decoration: BoxDecoration(
                        color: c.surface,
                        borderRadius: BorderRadius.circular(Radii.md),
                        border: Border.all(color: c.border),
                      ),
                      child: Row(
                        children: [
                          Icon(
                              unlocked
                                  ? Icons.bolt_outlined
                                  : Icons.lock_outline,
                              size: 18,
                              color: unlocked ? c.accent : c.textFaint),
                          const SizedBox(width: Gap.sm),
                          Expanded(
                            child: Text(
                                unlocked
                                    ? '${cert.title} · 약점 집중 모의고사'
                                    : '${cert.title} · 약점 집중 모의고사 (응시 3회 후 열림)',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: unlocked ? c.text : c.textMuted)),
                          ),
                          if (unlocked)
                            Text('약점 모의고사 →',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: c.accent)),
                        ],
                      ),
                    ),
                  ),
                );
              }(),
          ],
```
`_ExamsSection.build` 상단에서 `final c = context.c;`와 `final history = HistoryStore().all();`를 선언(섹션은 현재 `c`를 안 쓰므로 추가). `HistoryStore` import는 Task 8에서 이미 추가됨.

- [ ] **Step 4: analyze + 전체 테스트**

Run: `flutter analyze` → No issues.
Run: `flutter test` → 전부 PASS. (`home_sections_test`는 MemoryBackend라 잠김 상태 렌더 — 추가 줄은 텍스트만, 기존 기대 깨지지 않는지 확인. 깨지면 해당 테스트의 finder를 신규 텍스트와 충돌 없게 조정.)

- [ ] **Step 5: 커밋**

```bash
git -C D:/workspace/awc-docs add flutter_app/lib/pages/cert_detail_page.dart flutter_app/lib/pages/home_page.dart
git -C D:/workspace/awc-docs commit -m "feat: 약점 집중 모의고사 진입(게이트) — cert 상세 + 랜딩"
```

---

## Task 11: 전체 검증

**Files:** 없음(검증만).

- [ ] **Step 1: analyze 무결**

Run (PowerShell, in `flutter_app`): `flutter analyze`
Expected: No issues found.

- [ ] **Step 2: 전체 테스트**

Run: `flutter test`
Expected: 전부 PASS(기존 63 + 신규 ~12: viewed_docs 3, study_progress 3, weighted_exam 3, attempt_presented 3, mock_exam +2, app_router +1).

- [ ] **Step 3: 릴리스 빌드**

Run: `flutter build web --release --base-href /aws-docs/`
Expected: 빌드 성공(에러 없음).

- [ ] **Step 4: 커밋(없으면 생략)**

검증만이라 변경 없음. analyze/test에서 수정이 발생했다면 별도 커밋.

---

## Task 12: headless dogfood

실제 브라우저(CanvasKit)로 사용자 시나리오 확인. PowerShell + gstack.

- [ ] **Step 1: dogfood 빌드 + 정적 서버**

```powershell
# in flutter_app
flutter build web --base-href /
Start-Process py -ArgumentList '-m','http.server','5151','--directory','D:\workspace\awc-docs\flutter_app\build\web' -WindowStyle Hidden
```

- [ ] **Step 2: E5 진행률 확인 (gstack browse)**

CanvasKit라 'Enable accessibility' JS click 후 @ref 구동.
- `http://localhost:5151/#/cert/CLF-C02/study/clf-t1-1` 방문(열람 기록).
- `http://localhost:5151/#/cert/CLF-C02` → 진행률 배너 `문서 열람 1/19` 표시 확인.
- `http://localhost:5151/#/` 랜딩 → 학습문서 카드 `열람 1/19` 배지 확인.

- [ ] **Step 3: E6 게이트 + 가중 출제 확인**

- 이력 <3회 상태: cert 상세에서 약점 집중 진입이 잠김 + "(N/3)" 표시 확인.
- 연습/시험을 3회 응시(또는 기존 이력 3회+ 상태)에서 cert 상세 약점 집중 진입 활성 확인.
- `http://localhost:5151/#/cert/CLF-C02/exam/weak` → 시작 화면 "약점 집중 모의고사" 제목·"약점 Task 가중" 출제 방식 표시, 시작 → 출제 동작 확인.

- [ ] **Step 4: 서버 종료**

```powershell
Get-Process py -ErrorAction SilentlyContinue | Stop-Process -Force
```

---

## Task 13: 배포 + 핸드오프 갱신

- [ ] **Step 1: origin push(자동 배포 트리거)**

```bash
git -C D:/workspace/awc-docs push origin main
```
(GitHub Pages CI가 `main` push 시 자동 배포.)

- [ ] **Step 2: 핸드오프 문서 갱신**

`docs/plans/2026-06-06-session-handoff.md`의 한 줄 상태·"다음 행동"을 **Phase 2 완료 → 다음 Phase 3(콘텐츠) 또는 잔여 항목**으로 갱신. 신규 라우트 `/cert/:code/exam/weak`, 신규 모듈(`ViewedDocsStore`·`StudyProgress`·`weighted_exam`) 기록.

- [ ] **Step 3: 크로스세션 메모리 갱신**

`C:\Users\deepe\.claude\projects\D--workspace-awc-docs\memory\work-priority-roadmap-phase0.md`(또는 신규 파일)에 **Phase 2 완료**(E5 진행률·E6 약점 가중) 반영 + `MEMORY.md` 인덱스 한 줄 갱신.

- [ ] **Step 4: 핸드오프/메모리 커밋 + push**

```bash
git -C D:/workspace/awc-docs add docs/plans/2026-06-06-session-handoff.md
git -C D:/workspace/awc-docs commit -m "docs: Phase 2(E5 진행률·E6 약점 가중) 완료 핸드오프 갱신"
git -C D:/workspace/awc-docs push origin main
```

---

## 자기 검토 메모(작성자 → 실행자)

- **스펙 커버리지:** D1(한 스펙=Task 1~13) · D2 방문열람(Task 1·6) · D3 랜딩+상세(Task 7·8) · D4 별도 진입(Task 9·10) · D5 실전형 동일 문항(Task 9 `_targetN` 재사용) · D6 Task 오답률 가중·최소 보장(Task 4) · D7 3회 게이트(Task 4·10). E2/E6 강등 규칙: 현재 콘텐츠 보유=CLF뿐이라 분기 영향 없음 — Task 10 진입은 `withContent`(=CLF) 한정이라 자동 충족.
- **타입 일관성:** `buildSampledExam<K>`·`allocateByWeight<K>`(Task 3) → `weightByTaskFromReport`(Task 4) → CertExamPage 사용(Task 9) 시그니처 일치. `StudyProgress.build`(Task 2) 파라미터명이 Task 7·8 호출과 일치. `nonReviewAttemptCount`/`weightedExamUnlocked`/`kWeightedExamMinAttempts`(Task 4) → Task 10 사용 일치.
- **함정 준수:** 모든 페이지(SelectionArea) 렌더 테스트 없음. 순수 모듈·스토어·redirect만 자동 테스트, 페이지는 analyze + dogfood.
- **빌드/경로:** flutter는 PowerShell·`flutter_app`기준, git은 `-C D:/workspace/awc-docs`.
