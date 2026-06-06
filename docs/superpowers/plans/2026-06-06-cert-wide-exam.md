# cert-wide 통합 모의고사 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 자격증 전체 검증 문항 풀에서 도메인 비중에 맞춰 65문항을 샘플링해 출제·채점하고, 진행 중 새로고침 시 같은 시험을 복원하는 통합 모의고사를 `/cert/:code/exam`에 구현한다.

**Architecture:** 순수 Dart 모듈(`mock_exam.dart`)이 도메인 가중 샘플링과 복원을 담당(rng 주입으로 결정적·단위 테스트 가능). `ExamSession`에 출제 ID 목록(`questionIds`)을 추가하고 `ExamView`가 이를 세션에 보존(1줄). `CertExamPage`를 placeholder에서 로더+시작화면+복원 페이지로 재작성하되, 기존 `ExamView`(모델 주입식 러너)를 합성 `QuestionBank` 주입으로 그대로 재사용한다.

**Tech Stack:** Flutter Web (Dart), go_router, dart:math `Random`. 신규 런타임 패키지 없음.

**Spec:** `docs/superpowers/specs/2026-06-06-cert-wide-exam-design.md`

---

## Pre-flight (실행 시작 전)

- **작업 디렉터리:** flutter/test 명령은 `aws-docs/flutter_app`에서, git 명령은 `aws-docs/`에서 실행한다.
- **브랜치:** 현재 `main`. 하니스 정책상 기본 브랜치 직접 커밋을 피한다 — 실행 전 피처 브랜치(예: `feat/cert-wide-exam`)를 생성한다. (사용자가 main 직접 커밋을 명시 승인하면 예외)
- **선행 미커밋 변경 분리:** 작업 트리에 Spec 2와 무관한 미커밋 변경(Task 2·3: CLAUDE.md·DESIGN.md 스택 표기, 문항 12개 flip + content_index/test 동기화)이 있다. 이들은 본 플랜의 첫 커밋 전에 **별도 커밋**으로 분리한다:
  ```bash
  # in aws-docs/
  git add CLAUDE.md DESIGN.md
  git commit -m "docs: 스택 표기를 Flutter Web로 정정 (CLAUDE/DESIGN)"
  git add flutter_app/assets/content/clf/t1-3.questions.json flutter_app/assets/content/clf/t2-1.questions.json flutter_app/assets/content/clf/t4-3.questions.json flutter_app/lib/data/content_index.dart flutter_app/test/question_model_test.dart
  git commit -m "content: CLF 드래프트 12문항 검증 flip (검증 130), 카운트·테스트 동기화"
  ```

## File Structure

| 파일 | 역할 | 종류 |
|---|---|---|
| `flutter_app/lib/data/mock_exam.dart` | 도메인 가중 샘플러 + 병합/복원 순수 함수 (Flutter 무의존) | 생성 |
| `flutter_app/lib/models/exam_session.dart` | `ExamSession`에 `questionIds` 추가 | 수정 |
| `flutter_app/lib/pages/exam_page.dart` | `ExamView._session()`에 출제 ID 보존 1줄 | 수정 |
| `flutter_app/lib/pages/cert_exam_page.dart` | placeholder → 로더+시작화면+복원+ExamView | 재작성 |
| `flutter_app/test/mock_exam_test.dart` | 샘플러/복원 순수 단위 테스트 | 생성 |
| `flutter_app/test/exam_session_test.dart` | `questionIds` 라운드트립·하위호환 | 수정 |
| `flutter_app/test/exam_view_test.dart` | onChanged가 출제 ID를 보존하는지 | 수정 |
| `flutter_app/test/app_router_test.dart` | `/cert/:code/exam` 안전 라우팅 스모크 | 수정 |

라우터(`app_router.dart`)는 이미 `/cert/:code/exam → CertExamPage(cert:)`로 빌드하므로 **수정 불필요**.

---

## Task 1: ExamSession에 questionIds 추가

**Files:**
- Test: `flutter_app/test/exam_session_test.dart` (추가)
- Modify: `flutter_app/lib/models/exam_session.dart`

- [ ] **Step 1: 실패하는 테스트 추가**

`flutter_app/test/exam_session_test.dart`의 `void main() {` 바로 다음에 아래 테스트를 추가:

```dart
  test('questionIds 라운드트립 + 누락 시 빈 목록(하위호환)', () {
    const s = ExamSession(
      examId: 'exam:CLF-C02-mock',
      certId: 'CLF-C02',
      taskId: 'CLF-C02-mock',
      startedAtIso: '2026-06-06T00:00:00.000',
      durationSec: 5400,
      index: 0,
      picked: {},
      flagged: [],
      bankFingerprint: 'fp',
      submitted: false,
      questionIds: ['clf-t1-1-q1', 'clf-t2-1-q3'],
    );
    final back = ExamSession.fromJson(s.toJson());
    expect(back.questionIds, ['clf-t1-1-q1', 'clf-t2-1-q3']);
    // 구버전 JSON(questionIds 없음) → 빈 목록
    final old = ExamSession.fromJson({'examId': 'x'});
    expect(old.questionIds, isEmpty);
  });
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `flutter test test/exam_session_test.dart`
Expected: FAIL — `ExamSession`에 `questionIds` 명명 인자가 없어 컴파일 에러.

- [ ] **Step 3: 모델에 필드 추가**

`flutter_app/lib/models/exam_session.dart`를 다음과 같이 수정.

(a) 생성자에 `submitted` 위에 한 줄 추가:
```dart
  const ExamSession({
    required this.examId,
    required this.certId,
    required this.taskId,
    required this.startedAtIso,
    required this.durationSec,
    required this.index,
    required this.picked,
    required this.flagged,
    required this.bankFingerprint,
    this.questionIds = const [],
    required this.submitted,
  });
```

(b) 필드 선언에 `bankFingerprint` 아래 한 줄 추가:
```dart
  final String bankFingerprint;
  final List<String> questionIds; // 통합 모의고사 출제 문항 ID(순서) — 복원용
  final bool submitted;
```

(c) `toJson()`의 `'bankFingerprint'` 아래 한 줄 추가:
```dart
        'bankFingerprint': bankFingerprint,
        'questionIds': questionIds,
        'submitted': submitted,
```

(d) `fromJson`의 `bankFingerprint:` 아래 한 줄 추가:
```dart
      bankFingerprint: (j['bankFingerprint'] ?? '').toString(),
      questionIds: ((j['questionIds'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      submitted: j['submitted'] == true,
```

- [ ] **Step 4: 테스트 통과 확인**

Run: `flutter test test/exam_session_test.dart`
Expected: PASS (전체 통과).

- [ ] **Step 5: 커밋**

```bash
# in aws-docs/
git add flutter_app/lib/models/exam_session.dart flutter_app/test/exam_session_test.dart
git commit -m "feat: ExamSession에 questionIds(출제 ID) 추가 — 통합 모의고사 복원용

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 2: mock_exam.dart 순수 헬퍼 (allocate/group/index/restore)

**Files:**
- Test: `flutter_app/test/mock_exam_test.dart` (생성)
- Create: `flutter_app/lib/data/mock_exam.dart`

- [ ] **Step 1: 실패하는 테스트 작성**

`flutter_app/test/mock_exam_test.dart` 생성:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/mock_exam.dart';
import 'package:aws_docs/models/question.dart';

Question _q(String id, int domain) => Question(
      id: id,
      examGuideTaskId: 'clf-t$domain',
      stem: 's',
      options: const ['a', 'b', 'c', 'd'],
      correct: 0,
      explanation: 'e',
      wrongExplanations: const {},
      sources: const [],
      verified: true,
    );

QuestionBank _bank(int domain, List<String> ids) => QuestionBank(
      examGuideTaskId: 'clf-t$domain-x',
      taskTitle: 't',
      certCode: 'CLF-C02',
      domain: domain,
      questions: [for (final id in ids) _q(id, domain)],
    );

void main() {
  test('allocateByWeight: 합이 N, CLF 가중 65 → 16/19/22/8', () {
    final a = allocateByWeight({1: 24, 2: 30, 3: 34, 4: 12}, 65);
    expect(a.values.fold(0, (s, v) => s + v), 65);
    expect(a, {1: 16, 2: 19, 3: 22, 4: 8});
  });

  test('allocateByWeight: 비중 합 0이면 균등 배분, 합=N', () {
    final a = allocateByWeight({1: 0, 2: 0, 3: 0}, 7);
    expect(a.values.fold(0, (s, v) => s + v), 7);
  });

  test('allocateByWeight: N=0 → 전부 0', () {
    expect(allocateByWeight({1: 24, 2: 76}, 0), {1: 0, 2: 0});
  });

  test('groupByDomain / indexById', () {
    final banks = [_bank(1, ['a', 'b']), _bank(2, ['c'])];
    final pool = groupByDomain(banks);
    expect(pool[1]!.length, 2);
    expect(pool[2]!.length, 1);
    final byId = indexById([for (final b in banks) ...b.questions]);
    expect(byId.keys.toSet(), {'a', 'b', 'c'});
  });

  test('restoreOrdered: 모든 ID 존재 시 순서대로, 누락/빈목록 시 null', () {
    final byId = indexById([_q('a', 1), _q('b', 1), _q('c', 1)]);
    expect(restoreOrdered(['c', 'a'], byId)!.map((q) => q.id).toList(),
        ['c', 'a']);
    expect(restoreOrdered(['a', 'z'], byId), isNull); // z 없음 → 복원 거부
    expect(restoreOrdered(const [], byId), isNull); // 빈 목록
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `flutter test test/mock_exam_test.dart`
Expected: FAIL — `mock_exam.dart`가 없어 import 에러.

- [ ] **Step 3: 모듈 작성(헬퍼 부분)**

`flutter_app/lib/data/mock_exam.dart` 생성:

```dart
import '../models/question.dart';

/// 자격증 통합 모의고사용 순수 로직(샘플링·병합·복원). Flutter 무의존 → 단위 테스트 가능.

/// 도메인 번호 → 출제 문항 수. weightByDomain 비중에 비례해 n을 배분하되,
/// floor 후 잔여를 소수부가 큰 순(largest-remainder)으로 +1. 합 == n 보장.
Map<int, int> allocateByWeight(Map<int, int> weightByDomain, int n) {
  if (weightByDomain.isEmpty) return {};
  if (n <= 0) return {for (final d in weightByDomain.keys) d: 0};

  final totalWeight = weightByDomain.values.fold(0, (s, w) => s + w);
  if (totalWeight <= 0) {
    // 비중 정보 없음 → 가능한 균등 배분.
    final domains = weightByDomain.keys.toList();
    final base = n ~/ domains.length;
    final alloc = {for (final d in domains) d: base};
    var rem = n - base * domains.length;
    for (var i = 0; i < domains.length && rem > 0; i++, rem--) {
      alloc[domains[i]] = alloc[domains[i]]! + 1;
    }
    return alloc;
  }

  final exact = <int, double>{};
  final alloc = <int, int>{};
  for (final e in weightByDomain.entries) {
    final v = n * e.value / totalWeight;
    exact[e.key] = v;
    alloc[e.key] = v.floor();
  }
  var assigned = alloc.values.fold(0, (s, v) => s + v);
  // 잔여를 소수부 큰 순으로 +1.
  final byFraction = exact.keys.toList()
    ..sort((a, b) => (exact[b]! - exact[b]!.floorToDouble())
        .compareTo(exact[a]! - exact[a]!.floorToDouble()));
  for (var i = 0; assigned < n; i++, assigned++) {
    final d = byFraction[i % byFraction.length];
    alloc[d] = alloc[d]! + 1;
  }
  return alloc;
}

/// 로드한 뱅크들을 도메인 번호 → 검증 문항 리스트로 묶는다.
Map<int, List<Question>> groupByDomain(List<QuestionBank> banks) {
  final map = <int, List<Question>>{};
  for (final b in banks) {
    (map[b.domain] ??= <Question>[]).addAll(b.questions);
  }
  return map;
}

/// 문항 ID → 문항. 복원 시 사용.
Map<String, Question> indexById(Iterable<Question> questions) =>
    {for (final q in questions) q.id: q};

/// 저장된 출제 ID를 현재 풀로 복원. 모든 ID가 존재할 때만 순서대로 반환, 아니면 null.
List<Question>? restoreOrdered(List<String> ids, Map<String, Question> byId) {
  if (ids.isEmpty) return null;
  final out = <Question>[];
  for (final id in ids) {
    final q = byId[id];
    if (q == null) return null; // 콘텐츠 개정/불일치 → 복원 거부
    out.add(q);
  }
  return out;
}
```

> 주: `buildMockExam`(rng 사용)은 Task 3에서 같은 파일에 `import 'dart:math';`와 함께 추가한다.

- [ ] **Step 4: 테스트 통과 확인**

Run: `flutter test test/mock_exam_test.dart`
Expected: PASS.

- [ ] **Step 5: 커밋**

```bash
# in aws-docs/
git add flutter_app/lib/data/mock_exam.dart flutter_app/test/mock_exam_test.dart
git commit -m "feat: mock_exam 순수 헬퍼(allocateByWeight/groupByDomain/restoreOrdered)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 3: buildMockExam (도메인 가중 샘플링 + 풀 부족 보충)

**Files:**
- Test: `flutter_app/test/mock_exam_test.dart` (추가)
- Modify: `flutter_app/lib/data/mock_exam.dart`

- [ ] **Step 1: 실패하는 테스트 추가**

`flutter_app/test/mock_exam_test.dart`의 `restoreOrdered` 테스트 위(또는 main 내 어디든)에 추가:

```dart
  test('buildMockExam: 결정적(동일 seed) · 길이 N · 전부 풀 소속 · 중복 없음', () {
    final pool = {
      1: [for (var i = 0; i < 10; i++) _q('d1q$i', 1)],
      2: [for (var i = 0; i < 10; i++) _q('d2q$i', 2)],
    };
    const w = {1: 50, 2: 50};
    final a =
        buildMockExam(poolByDomain: pool, weightByDomain: w, n: 8, rng: Random(42));
    final b =
        buildMockExam(poolByDomain: pool, weightByDomain: w, n: 8, rng: Random(42));
    expect(a.map((q) => q.id).toList(), b.map((q) => q.id).toList());
    expect(a.length, 8);
    final allIds = {for (final d in pool.values) for (final q in d) q.id};
    expect(a.every((q) => allIds.contains(q.id)), isTrue);
    expect(a.map((q) => q.id).toSet().length, 8); // 중복 없음
  });

  test('buildMockExam: 도메인 풀 부족 → 잔여 도메인에서 보충해 N 유지', () {
    final pool = {
      1: [_q('d1q0', 1)], // 1개뿐(배분 4 요구)
      2: [for (var i = 0; i < 10; i++) _q('d2q$i', 2)],
    };
    const w = {1: 50, 2: 50};
    final r =
        buildMockExam(poolByDomain: pool, weightByDomain: w, n: 8, rng: Random(1));
    expect(r.length, 8);
    expect(r.where((q) => q.id == 'd1q0').length, 1); // 있는 만큼은 포함
  });

  test('buildMockExam: 풀 총량 < N이면 가능한 최대', () {
    final pool = {
      1: [_q('a', 1), _q('b', 1)]
    };
    final r =
        buildMockExam(poolByDomain: pool, weightByDomain: {1: 100}, n: 8, rng: Random(1));
    expect(r.length, 2);
  });
```

이 테스트는 `Random`을 사용하므로 파일 상단 import에 추가:
```dart
import 'dart:math';
```
(파일 맨 위, 기존 import들과 함께. 이미 있으면 생략.)

- [ ] **Step 2: 테스트 실패 확인**

Run: `flutter test test/mock_exam_test.dart`
Expected: FAIL — `buildMockExam` 미정의.

- [ ] **Step 3: buildMockExam 구현**

먼저 `flutter_app/lib/data/mock_exam.dart` 최상단 import에 `import 'dart:math';`를 추가한다(기존 `import '../models/question.dart';` 위). 그런 다음 `allocateByWeight` 아래에 함수를 추가:

```dart
/// 도메인 가중으로 n문항을 샘플링해 순서를 섞어 반환. [rng] 주입으로 결정적.
/// 특정 도메인 풀이 배분량보다 적으면 잔여 도메인 문항에서 보충(총 n 유지, 풀<n이면 최대).
List<Question> buildMockExam({
  required Map<int, List<Question>> poolByDomain,
  required Map<int, int> weightByDomain,
  required int n,
  required Random rng,
}) {
  final alloc = allocateByWeight(weightByDomain, n);
  final picked = <Question>[];
  final leftovers = <Question>[];

  final domains = {...poolByDomain.keys, ...alloc.keys}.toList()..sort();
  for (final d in domains) {
    final pool = [...?poolByDomain[d]]..shuffle(rng);
    final want = alloc[d] ?? 0;
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
```

- [ ] **Step 4: 테스트 통과 확인**

Run: `flutter test test/mock_exam_test.dart`
Expected: PASS (전체).

- [ ] **Step 5: 커밋**

```bash
# in aws-docs/
git add flutter_app/lib/data/mock_exam.dart flutter_app/test/mock_exam_test.dart
git commit -m "feat: buildMockExam 도메인 가중 샘플러(rng 주입, 풀부족 보충)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 4: ExamView가 출제 ID를 세션에 보존 (1줄)

**Files:**
- Test: `flutter_app/test/exam_view_test.dart` (추가)
- Modify: `flutter_app/lib/pages/exam_page.dart:102` (`ExamView._session()`)

- [ ] **Step 1: 실패하는 테스트 추가**

`flutter_app/test/exam_view_test.dart` 상단 import에 추가:
```dart
import 'package:aws_docs/models/exam_session.dart';
```

`void main() {` 안에 테스트 추가:
```dart
  testWidgets('onChanged 세션에 출제 문항 ID가 순서대로 담긴다', (tester) async {
    ExamSession? saved;
    final started = DateTime(2026, 6, 6);
    await tester.pumpWidget(_host(ExamView(
      bank: _bank(),
      certId: 'CLF-C02',
      taskId: 'clf-t2-3',
      startedAt: started,
      durationSec: 600,
      now: () => started.add(const Duration(seconds: 5)),
      onChanged: (s) => saved = s,
    )));
    await tester.pump();

    await tester.tap(find.text('계정 해지')); // 선택 → onChanged 발화
    await tester.pump();

    expect(saved, isNotNull);
    expect(saved!.questionIds, ['q1', 'q2']);
  });
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `flutter test test/exam_view_test.dart`
Expected: FAIL — `saved!.questionIds`가 `[]`(기본값). 기대 `['q1','q2']`.

- [ ] **Step 3: _session()에 1줄 추가**

`flutter_app/lib/pages/exam_page.dart`의 `_session()`(약 102행)에서 `bankFingerprint:` 아래 한 줄 추가:
```dart
  ExamSession _session() => ExamSession(
        examId: 'exam:${widget.taskId}',
        certId: widget.certId,
        taskId: widget.taskId,
        startedAtIso: widget.startedAt.toIso8601String(),
        durationSec: widget.durationSec,
        index: _index,
        picked: _picked,
        flagged: _flagged.toList()..sort(),
        bankFingerprint: bankFingerprint(widget.bank),
        questionIds: _qs.map((q) => q.id).toList(),
        submitted: _submitted,
      );
```

- [ ] **Step 4: 테스트 통과 확인**

Run: `flutter test test/exam_view_test.dart`
Expected: PASS (전체).

- [ ] **Step 5: 커밋**

```bash
# in aws-docs/
git add flutter_app/lib/pages/exam_page.dart flutter_app/test/exam_view_test.dart
git commit -m "feat: ExamView 세션 스냅샷에 출제 ID 보존(통합 모의고사 복원 지원)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 5: CertExamPage 재작성 (로더 + 시작 화면 + 복원 + ExamView)

**Files:**
- Test: `flutter_app/test/app_router_test.dart` (추가)
- Rewrite: `flutter_app/lib/pages/cert_exam_page.dart`

> 테스트 전략: 메모리의 SelectionArea 위젯-테스트 함정 때문에 이 async 페이지는 **전체 렌더를 단언하지 않는다**. 라우터 스모크 테스트는 첫 프레임의 로딩 스피너만 확인하고(`pumpAndSettle` 금지), 핵심 로직은 Task 2·3의 순수 단위 테스트가, end-to-end는 Task 6의 수동 검증이 커버한다.

- [ ] **Step 1: 실패하는 라우터 스모크 테스트 추가**

`flutter_app/test/app_router_test.dart` 상단 import에 추가:
```dart
import 'package:aws_docs/pages/cert_exam_page.dart';
```

`void main() {` 안에 테스트 추가:
```dart
  testWidgets('"/cert/CLF-C02/exam" → CertExamPage 로딩 스피너 렌더(리다이렉트 없음)',
      (tester) async {
    await tester.pumpWidget(_app('/cert/CLF-C02/exam'));
    await tester.pump(); // 1프레임: FutureBuilder 로딩 상태
    expect(find.byType(CertExamPage), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    // 주의: pumpAndSettle 금지 — 풀 로드 완료 후 화면 전환/타이머 회피
  });
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `flutter test test/app_router_test.dart`
Expected: FAIL — 현재 placeholder CertExamPage엔 `CircularProgressIndicator`가 없음.

- [ ] **Step 3: CertExamPage 재작성**

`flutter_app/lib/pages/cert_exam_page.dart` 전체를 아래로 교체:

```dart
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:go_router/go_router.dart';

import '../content/quiz_widgets.dart';
import '../data/content_index.dart';
import '../data/exam_session_store.dart';
import '../data/history_store.dart';
import '../data/mock_exam.dart';
import '../models/certification.dart';
import '../models/exam_guide.dart';
import '../models/exam_session.dart';
import '../models/question.dart';
import '../theme/app_theme.dart';
import 'exam_page.dart'; // ExamView

/// 통합 모의고사 진입점. 자격증 전체 검증 문항 풀을 병합해 도메인 가중으로
/// N문항을 샘플링·출제하고, 진행 중 세션을 복원한다. ExamView를 재사용한다.
class CertExamPage extends StatefulWidget {
  const CertExamPage({super.key, required this.cert});
  final Certification cert;

  @override
  State<CertExamPage> createState() => _CertExamPageState();
}

class _CertExamPageState extends State<CertExamPage> {
  final _store = ExamSessionStore();
  final _history = HistoryStore();
  late final Future<_MockLoad> _future = _load();
  _RunParams? _running;

  String get _examId => 'exam:${widget.cert.code}-mock';

  Future<_MockLoad> _load() async {
    final entries = contentFor(widget.cert.code);
    final banks = <QuestionBank>[];
    for (final e in entries) {
      try {
        final raw = await rootBundle.loadString(e.questionsAsset);
        banks.add(
            QuestionBank.fromJson(json.decode(raw) as Map<String, dynamic>));
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

    // 복원 가능한 진행 세션?
    final existing = _store.load(_examId);
    List<Question>? restored;
    if (existing != null && !existing.submitted) {
      restored = restoreOrdered(existing.questionIds, byId);
      if (restored == null) _store.clear(_examId); // 개정/불일치 폐기
    }

    return _MockLoad(
      pool: pool,
      byId: byId,
      weights: weights,
      overview: overview,
      total: all.length,
      existing: restored == null ? null : existing,
      restoredQuestions: restored,
    );
  }

  int _targetN(ExamOverview? o) =>
      (o?.scoredQuestions ?? 50) + (o?.unscoredQuestions ?? 15);

  void _startFresh(_MockLoad d) {
    _store.clear(_examId);
    final sampled = buildMockExam(
      poolByDomain: d.pool,
      weightByDomain: d.weights,
      n: _targetN(d.overview),
      rng: Random(),
    );
    final startedAt = DateTime.now();
    final durationSec = examDurationSec(
      durationMinutes: d.overview?.durationMinutes,
      scored: d.overview?.scoredQuestions,
      unscored: d.overview?.unscoredQuestions,
      count: sampled.length,
    );
    setState(() => _running = _RunParams.fresh(sampled, startedAt, durationSec));
  }

  void _resume(_MockLoad d) {
    setState(() =>
        _running = _RunParams.restored(d.existing!, d.restoredQuestions!));
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
        title: Text('${widget.cert.title} · 통합 모의고사',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      body: FutureBuilder<_MockLoad>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snap.data;
          if (snap.hasError || data == null || data.total == 0) {
            return Center(
                child: Text('검증된 문항이 아직 없습니다.',
                    style: TextStyle(color: c.textMuted)));
          }
          if (_running != null) return _examView(_running!);
          return _startScreen(data);
        },
      ),
    );
  }

  Widget _examView(_RunParams r) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Layout.exam),
        child: ExamView(
          bank: QuestionBank(
            examGuideTaskId: '${widget.cert.code}-mock',
            taskTitle: '통합 모의고사',
            certCode: widget.cert.code,
            domain: 0,
            questions: r.questions,
          ),
          certId: widget.cert.code,
          taskId: '${widget.cert.code}-mock',
          startedAt: r.startedAt,
          durationSec: r.durationSec,
          initialIndex: r.index,
          initialPicked: r.picked,
          initialFlagged: r.flagged,
          restored: r.restored,
          onChanged: _store.save,
          onFinished: (rec) {
            _history.add(rec);
            _store.clear(_examId);
          },
          onExit: () => context.pop(),
        ),
      ),
    );
  }

  Widget _startScreen(_MockLoad d) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    final target = _targetN(d.overview);
    final cap = target < d.total ? target : d.total;
    final mins = d.overview?.durationMinutes ?? 90;
    final pass = d.overview?.passingScore;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(Gap.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('통합 모의고사', style: t.headlineSmall),
              const SizedBox(height: Gap.sm),
              Text('자격증 전체 검증 문항 풀(${d.total}개)에서 도메인 비중에 맞춰 출제합니다.',
                  style: t.bodyMedium),
              const SizedBox(height: Gap.lg),
              _infoRow(c, t, '문항 수', '$cap문항'),
              _infoRow(c, t, '제한 시간', '$mins분'),
              if (pass != null)
                _infoRow(c, t, '합격선', '$pass / 1000 (정답률과 다름)'),
              _infoRow(c, t, '도메인 비중', _weightLabel(d.weights)),
              const SizedBox(height: Gap.xl),
              if (d.restoredQuestions != null) ...[
                SizedBox(
                    width: 220,
                    child:
                        PrimaryButton(label: '이어서 풀기', onTap: () => _resume(d))),
                const SizedBox(height: Gap.sm),
                InkWell(
                  onTap: () => _startFresh(d),
                  borderRadius: BorderRadius.circular(Radii.sm),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: Gap.sm, horizontal: Gap.xs),
                    child: Text('새로 시작',
                        style: TextStyle(
                            color: c.textMuted, fontWeight: FontWeight.w700)),
                  ),
                ),
              ] else
                SizedBox(
                    width: 220,
                    child:
                        PrimaryButton(label: '시작', onTap: () => _startFresh(d))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(AppColors c, TextTheme t, String label, String value) =>
      Padding(
        padding: const EdgeInsets.only(bottom: Gap.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: 96,
                child: Text(label,
                    style: t.labelLarge?.copyWith(color: c.textMuted))),
            Expanded(child: Text(value, style: t.labelLarge)),
          ],
        ),
      );

  String _weightLabel(Map<int, int> w) {
    final keys = w.keys.toList()..sort();
    return '${keys.map((k) => 'D$k ${w[k]}').join(' · ')}%';
  }
}

/// 로드 결과(풀·인덱스·가중·메타·복원 후보).
class _MockLoad {
  const _MockLoad({
    required this.pool,
    required this.byId,
    required this.weights,
    required this.overview,
    required this.total,
    required this.existing,
    required this.restoredQuestions,
  });
  final Map<int, List<Question>> pool;
  final Map<String, Question> byId;
  final Map<int, int> weights;
  final ExamOverview? overview;
  final int total;
  final ExamSession? existing;
  final List<Question>? restoredQuestions;
}

/// ExamView에 주입할 실행 파라미터(새 시험 / 복원).
class _RunParams {
  final List<Question> questions;
  final DateTime startedAt;
  final int durationSec;
  final int index;
  final Map<int, int> picked;
  final Set<int> flagged;
  final bool restored;

  _RunParams.fresh(this.questions, this.startedAt, this.durationSec)
      : index = 0,
        picked = const <int, int>{},
        flagged = const <int>{},
        restored = false;

  _RunParams.restored(ExamSession s, this.questions)
      : startedAt = DateTime.tryParse(s.startedAtIso) ?? DateTime.now(),
        durationSec = s.durationSec,
        index = s.index,
        picked = s.picked,
        flagged = s.flagged.toSet(),
        restored = true;
}
```

- [ ] **Step 4: 테스트 통과 확인**

Run: `flutter test test/app_router_test.dart`
Expected: PASS (전체). 새 스모크 테스트 포함.

- [ ] **Step 5: 정적 분석**

Run: `flutter analyze`
Expected: `No issues found!` (경고 0). 경고가 있으면 해결 후 재실행.

- [ ] **Step 6: 커밋**

```bash
# in aws-docs/
git add flutter_app/lib/pages/cert_exam_page.dart flutter_app/test/app_router_test.dart
git commit -m "feat: 통합 모의고사 CertExamPage 구현(로더+시작화면+복원, ExamView 재사용)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 6: 전체 검증 + 수동 dogfood + 메모리 갱신

**Files:** (검증 전용 — 코드 변경 없음, 문제 발견 시 해당 Task로 복귀)

- [ ] **Step 1: 전체 테스트**

Run: `flutter test`
Expected: `All tests passed!` (기존 31 + 신규 추가분 전부).

- [ ] **Step 2: 정적 분석**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 3: 릴리스 웹 빌드(회귀 확인)**

Run (PowerShell, in `aws-docs/flutter_app`): `flutter build web --base-href /aws-docs/`
Expected: 빌드 성공(에러 0). (메모리: `--base-href`는 Git Bash에서 경로 깨짐 → PowerShell 사용.)

- [ ] **Step 4: 수동 dogfood**

`flutter run -d chrome`(또는 빌드 결과 서빙) 후 다음을 확인:
- `/cert/CLF-C02/exam` 진입 → 시작 화면(문항 수·90분·도메인 비중·합격선) 표시.
- '시작' → 타이머 시작, 65문항(풀 충분 시), 문항 그리드/플래그/제출 동작.
- 진행 중 새로고침 → 시작 화면에 '이어서 풀기' 노출 → 같은 문항·진행 상태 복원("이전 진행을 복원했습니다." 노트).
- 제출 → 결과(정답 수·문항별 해설) 표시.
- 도메인 분포가 대략 24/30/34/12에 근사하는지 육안 확인.

- [ ] **Step 5: 메모리 갱신**

`C:\Users\deepe\.claude\projects\D--workspace-awc-docs\memory\ia-routing-shipped-next-cert-exam.md`와 `MEMORY.md`에 Spec 2 구현 완료(통합 모의고사 라이브, `mock_exam.dart` 샘플러 + `questionIds` 복원)를 반영하고, 남은 후속(비-CLF 콘텐츠 등)을 정리.

- [ ] **Step 6: 최종 커밋(필요 시)**

수동 검증에서 수정이 있었다면 커밋. 없으면 생략.

```bash
# in aws-docs/  (수정이 있을 때만)
git add -A
git commit -m "fix: 통합 모의고사 수동 검증 반영

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## 완료 기준 (Definition of Done)

- `flutter test` 전부 green, `flutter analyze` 무경고, 릴리스 웹 빌드 성공.
- `/cert/CLF-C02/exam`에서 도메인 가중 65문항 출제·채점·복원이 수동으로 확인됨.
- 기존 Task별 시험/세션/테스트 무영향.
- 스펙의 모든 섹션(§3 사양·§4 컴포넌트·§5 흐름·§6 복원·§7 시작화면·§8 엣지·§9 테스트)에 대응하는 구현/테스트 존재.
