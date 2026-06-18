# 개념→섹션 딥링크 Phase 2 (report 개조 + wrongSkills 비정규화) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 약점 리포트가 약점 Task별로 "놓친 개념"을 보여주고, 각 개념이 해당 학습문서 섹션으로 딥링크(Phase 1의 `?at=`)되게 한다.

**Architecture:** 응시 레코드에 오답 개념을 비정규화(`AttemptRecord.wrongSkills`)해 stale 문항에도 개념을 보존. report는 개념 집계를 순수 함수 `buildConceptReport`로 파생 — **비정규화 우선, 없으면(레거시) 라이브 뱅크 조인 폴백**. UI는 약점 Task 아래에 개념 칩+섹션 링크.

**Tech Stack:** Flutter Web (Dart), 자체 모델/스토어, Phase 1의 `studyDeepLink`/`?at=`.

**Spec:** `docs/superpowers/specs/2026-06-18-concept-deeplink-design.md` (§3.7, §3.8). **선행:** Phase 1(브랜치 `feat/concept-deeplink`, PR #15) — `Question.section`·`studyDeepLink`·`?at=` 라우트가 이 브랜치에 이미 있음(Phase 2는 그 tip에서 분기).

## Global Constraints

- 모든 명령은 `flutter_app/` 기준. 테스트=`cd /d/workspace/awc-docs/flutter_app && flutter.bat test`, 단일=`flutter.bat test test/<파일>.dart`. **패키지명은 `aws_docs`**(테스트 import는 `package:aws_docs/...`).
- 게이트: `flutter test` 전부 그린(기준선 512) + `flutter analyze` 신규 0건(기존 잔존 3건 외 금지).
- Test-First(CLAUDE.md 절대조건 2): 실패 테스트 선작성 → 최소 구현 → 통과 확인.
- 레거시 데이터 graceful: 기존 응시 레코드는 `wrongSkills` 없음 → 빈 리스트(`presentedQuestionIds` 패턴 동일). report는 그 경우 라이브 조인 폴백.
- DESIGN.md 정합(2026-06-09 D3): 개념 칩=중립색 라벨, **액센트는 학습 링크에만**. 새 인터랙티브는 InkWell+(Inset)FocusRing(GestureDetector 단독 금지).
- 브랜치 `feat/concept-report`(이미 생성, Phase 1 tip에서 분기). develop 직접 push 금지.
- report_page는 `rootBundle.loadString` 비동기 로드라 위젯테스트가 행될 수 있음(SelectionArea/async 함정 계열) → report UI는 위젯테스트 대신 **순수 함수 단위테스트 + dogfood**로 검증.

## 설계 메모 (집계 의미)
`buildConceptReport`는 cert의 비-review 레코드에서 오답 개념을 **누적 집계**한다(특정 회차 latest-result가 아니라 "한 번이라도 놓친 개념"). 학습 처방 보조용으로 충분하며 스펙의 "집계" 의도와 일치. Task별로 skill 문자열 기준 dedup(첫 section 유지).

---

### Task 1: WrongSkill 값객체 + AttemptRecord.wrongSkills + 빌더

**Files:**
- Modify: `flutter_app/lib/models/attempt_record.dart` (WrongSkill 클래스 + wrongSkills 필드·toJson·fromJson)
- Create: `flutter_app/lib/data/wrong_skills.dart` (buildWrongSkills 순수 빌더)
- Test: `flutter_app/test/wrong_skills_test.dart`

**Interfaces:**
- Produces:
  - `class WrongSkill { final String skill; final String section; final String taskId; ... toJson()/fromJson() }`
  - `AttemptRecord.wrongSkills` (`List<WrongSkill>`, 기본 `const []`)
  - `List<WrongSkill> buildWrongSkills(List<Question> qs, Map<int,int> picked)` — 오답(picked≠correct 또는 미응답)이며 `skill` 비어있지 않은 문항만 `WrongSkill(skill,section,taskId=examGuideTaskId)`.

- [ ] **Step 1: 실패 테스트 작성**

`flutter_app/test/wrong_skills_test.dart` 생성:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/models/attempt_record.dart';
import 'package:aws_docs/models/question.dart';
import 'package:aws_docs/data/wrong_skills.dart';

Question _q(String id, int correct, {String skill = '', String section = ''}) =>
    Question(
      id: id,
      examGuideTaskId: 'clf-t1-1',
      stem: 's',
      options: const ['a', 'b', 'c', 'd'],
      correct: correct,
      explanation: 'e',
      wrongExplanations: const {},
      sources: const [],
      verified: true,
      skill: skill,
      section: section,
    );

void main() {
  group('WrongSkill json', () {
    test('round-trips', () {
      const w = WrongSkill(skill: '탄력성', section: 'ha-elasticity', taskId: 'clf-t1-1');
      expect(WrongSkill.fromJson(w.toJson()).section, 'ha-elasticity');
      expect(WrongSkill.fromJson(w.toJson()).skill, '탄력성');
      expect(WrongSkill.fromJson(w.toJson()).taskId, 'clf-t1-1');
    });
  });

  group('AttemptRecord.wrongSkills', () {
    test('legacy json without field -> empty list', () {
      final r = AttemptRecord.fromJson(const {
        'certId': 'CLF-C02', 'examId': 'x', 'mode': 'exam', 'date': 'd',
        'correct': 1, 'total': 2, 'wrongQuestionIds': ['q2'],
        'flaggedQuestionIds': <String>[], 'durationSpentSec': 0,
      });
      expect(r.wrongSkills, isEmpty);
    });
    test('round-trips wrongSkills', () {
      final r = AttemptRecord(
        certId: 'CLF-C02', examId: 'x', mode: 'exam', date: 'd',
        correct: 1, total: 2, wrongQuestionIds: const ['q2'],
        flaggedQuestionIds: const [], durationSpentSec: 0,
        wrongSkills: const [WrongSkill(skill: 's', section: 'sec', taskId: 't')],
      );
      final back = AttemptRecord.fromJson(r.toJson());
      expect(back.wrongSkills.single.section, 'sec');
    });
  });

  group('buildWrongSkills', () {
    test('wrong+skill only; correct and skill-empty excluded', () {
      final qs = [
        _q('q1', 0, skill: '정의'),                    // correct picked -> excluded
        _q('q2', 0, skill: '탄력성', section: 'ha-elasticity'), // wrong -> included
        _q('q3', 0, skill: ''),                        // wrong but no skill -> excluded
        _q('q4', 0, skill: '글로벌', section: 'global-infra'),  // unanswered -> wrong -> included
      ];
      final picked = {0: 0, 1: 1, 2: 1}; // q1 correct, q2 wrong, q3 wrong, q4 unanswered
      final ws = buildWrongSkills(qs, picked);
      expect(ws.map((w) => w.skill).toList(), ['탄력성', '글로벌']);
      expect(ws.first.section, 'ha-elasticity');
      expect(ws.first.taskId, 'clf-t1-1');
    });
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `cd /d/workspace/awc-docs/flutter_app && flutter.bat test test/wrong_skills_test.dart`
Expected: FAIL — `WrongSkill`·`wrongSkills`·`buildWrongSkills` 미정의(컴파일 에러).

- [ ] **Step 3: WrongSkill + AttemptRecord.wrongSkills**

`flutter_app/lib/models/attempt_record.dart` 최상단(클래스 `AttemptRecord` 위)에 추가:

```dart
/// 한 응시의 오답 개념(비정규화) — stale 문항에도 개념 보존(report 개념 집계용).
class WrongSkill {
  const WrongSkill(
      {required this.skill, required this.section, required this.taskId});
  final String skill;
  final String section; // 학습문서 섹션 앵커 id (없으면 '')
  final String taskId; // examGuideTaskId

  Map<String, dynamic> toJson() =>
      {'skill': skill, 'section': section, 'taskId': taskId};

  factory WrongSkill.fromJson(Map<String, dynamic> j) => WrongSkill(
        skill: (j['skill'] ?? '').toString(),
        section: (j['section'] ?? '').toString(),
        taskId: (j['taskId'] ?? '').toString(),
      );
}
```

`AttemptRecord` 생성자(3-14행)에 `this.wrongSkills = const [],` 추가(`this.presentedQuestionIds = const [],` 다음 줄):
```dart
    this.presentedQuestionIds = const [],
    this.wrongSkills = const [],
    required this.durationSpentSec,
```

필드 선언(`presentedQuestionIds` 다음, 26-27행 영역)에 추가:
```dart
  final List<String> presentedQuestionIds;

  /// 오답 개념(비정규화). 레거시 레코드는 빈 리스트.
  final List<WrongSkill> wrongSkills;
```

`toJson`(29-40행)에 추가(`'presentedQuestionIds': ...,` 다음):
```dart
        'presentedQuestionIds': presentedQuestionIds,
        'wrongSkills': [for (final w in wrongSkills) w.toJson()],
```

`fromJson`(42-59행)에 추가(`presentedQuestionIds: ...,` 다음):
```dart
        presentedQuestionIds: ((j['presentedQuestionIds'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
        wrongSkills: ((j['wrongSkills'] as List?) ?? const [])
            .map((e) => WrongSkill.fromJson(e as Map<String, dynamic>))
            .toList(),
```

- [ ] **Step 4: buildWrongSkills 빌더**

`flutter_app/lib/data/wrong_skills.dart` 생성:

```dart
import '../models/attempt_record.dart';
import '../models/question.dart';

/// 오답(picked≠correct 또는 미응답)이며 개념(skill) 태그가 있는 문항을
/// WrongSkill로 변환. 정답·무태그 문항은 제외. AttemptRecord 생성 시 사용.
List<WrongSkill> buildWrongSkills(List<Question> qs, Map<int, int> picked) {
  final out = <WrongSkill>[];
  for (var k = 0; k < qs.length; k++) {
    final q = qs[k];
    final isWrong = picked[k] != q.correct; // 미응답(null)도 오답
    if (isWrong && q.skill.isNotEmpty) {
      out.add(WrongSkill(
          skill: q.skill, section: q.section, taskId: q.examGuideTaskId));
    }
  }
  return out;
}
```

- [ ] **Step 5: 통과 확인 + 회귀**

Run: `cd /d/workspace/awc-docs/flutter_app && flutter.bat test test/wrong_skills_test.dart && flutter.bat test`
Expected: PASS (신규) + 기존 전부 그린.

- [ ] **Step 6: 커밋**

```bash
git add flutter_app/lib/models/attempt_record.dart flutter_app/lib/data/wrong_skills.dart flutter_app/test/wrong_skills_test.dart
git commit -m "feat(report): WrongSkill 비정규화 모델 + AttemptRecord.wrongSkills + buildWrongSkills"
```

---

### Task 2: 응시 제출부에 wrongSkills 배선

**Files:**
- Modify: `flutter_app/lib/pages/exam_page.dart:194` (AttemptRecord 생성)
- Modify: `flutter_app/lib/pages/quiz_page.dart:145` (AttemptRecord 생성)

**Interfaces:**
- Consumes: `buildWrongSkills(List<Question>, Map<int,int>)` (Task 1).

> 테스트 메모: 빌더는 Task 1에서 단위 검증됨. 이 Task는 두 생성부에 빌더를 연결하는 배선 — 게이트는 `flutter analyze` 0 new + 전체 `flutter test` 그린(컴파일·회귀). 신규 위젯테스트 없음.

- [ ] **Step 1: exam_page.dart 배선**

`flutter_app/lib/pages/exam_page.dart`:

상단 import에 추가(다른 `../data/...` import 옆):
```dart
import '../data/wrong_skills.dart';
```

AttemptRecord 생성(194-205행)에 `wrongSkills` 추가(`presentedQuestionIds: ...,` 다음):
```dart
      presentedQuestionIds: [for (final q in _qs) q.id],
      wrongSkills: buildWrongSkills(_qs, _picked),
      durationSpentSec: spent > widget.durationSec ? widget.durationSec : spent,
```

- [ ] **Step 2: quiz_page.dart 배선**

`flutter_app/lib/pages/quiz_page.dart`:

상단 import에 추가:
```dart
import '../data/wrong_skills.dart';
```

AttemptRecord 생성(145-156행)에 `wrongSkills` 추가(`presentedQuestionIds: ...,` 다음):
```dart
      presentedQuestionIds: [for (final q in _qs) q.id],
      wrongSkills: buildWrongSkills(_qs, _picked),
      durationSpentSec: DateTime.now().difference(_startedAt).inSeconds,
```

- [ ] **Step 3: analyze + 전체 회귀**

Run: `cd /d/workspace/awc-docs/flutter_app && flutter.bat analyze && flutter.bat test`
Expected: analyze 신규 0건, 테스트 전부 그린.

- [ ] **Step 4: 커밋**

```bash
git add flutter_app/lib/pages/exam_page.dart flutter_app/lib/pages/quiz_page.dart
git commit -m "feat(report): 응시 제출 시 wrongSkills 기록 — exam·quiz 생성부 배선"
```

---

### Task 3: 개념 집계 순수 함수 buildConceptReport

**Files:**
- Create: `flutter_app/lib/data/concept_report.dart`
- Test: `flutter_app/test/concept_report_test.dart`

**Interfaces:**
- Consumes: `AttemptRecord`·`WrongSkill` (Task 1).
- Produces:
  - `class MissedConcept { final String skill; final String section; }`
  - `Map<String, List<MissedConcept>> buildConceptReport({required String certId, required List<AttemptRecord> history, required Map<String, ({String taskId, String skill, String section})> questionMeta})` — cert의 비-review 레코드에서 Task별 놓친 개념(skill dedup, 첫 section 유지). 레코드의 `wrongSkills` 비어있지 않으면 그것을, 비었으면(레거시) `wrongQuestionIds`를 `questionMeta`로 조인. 키=taskId.

- [ ] **Step 1: 실패 테스트 작성**

`flutter_app/test/concept_report_test.dart` 생성:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/models/attempt_record.dart';
import 'package:aws_docs/data/concept_report.dart';

AttemptRecord _rec({
  List<WrongSkill> wrongSkills = const [],
  List<String> wrongQ = const [],
  String mode = 'exam',
}) =>
    AttemptRecord(
      certId: 'CLF-C02', examId: 'x', mode: mode, date: 'd',
      correct: 0, total: 1, wrongQuestionIds: wrongQ,
      flaggedQuestionIds: const [], durationSpentSec: 0,
      wrongSkills: wrongSkills,
    );

void main() {
  group('buildConceptReport', () {
    test('groups denormalized wrongSkills by task', () {
      final out = buildConceptReport(
        certId: 'CLF-C02',
        history: [
          _rec(wrongSkills: const [
            WrongSkill(skill: '탄력성', section: 'ha-elasticity', taskId: 'clf-t1-1'),
            WrongSkill(skill: '글로벌', section: 'global-infra', taskId: 'clf-t1-2'),
          ]),
        ],
        questionMeta: const {},
      );
      expect(out['clf-t1-1']!.single.skill, '탄력성');
      expect(out['clf-t1-1']!.single.section, 'ha-elasticity');
      expect(out['clf-t1-2']!.single.skill, '글로벌');
    });

    test('legacy record (no wrongSkills) falls back to live join', () {
      final out = buildConceptReport(
        certId: 'CLF-C02',
        history: [_rec(wrongQ: const ['q2'])],
        questionMeta: const {
          'q2': (taskId: 'clf-t1-1', skill: '고정비', section: 'core-benefits'),
        },
      );
      expect(out['clf-t1-1']!.single.skill, '고정비');
      expect(out['clf-t1-1']!.single.section, 'core-benefits');
    });

    test('dedups same skill within a task; ignores review mode', () {
      final out = buildConceptReport(
        certId: 'CLF-C02',
        history: [
          _rec(wrongSkills: const [
            WrongSkill(skill: '탄력성', section: 'ha-elasticity', taskId: 'clf-t1-1'),
          ]),
          _rec(wrongSkills: const [
            WrongSkill(skill: '탄력성', section: 'x', taskId: 'clf-t1-1'),
          ]),
          _rec(mode: 'review', wrongSkills: const [
            WrongSkill(skill: '복습', section: 'y', taskId: 'clf-t1-1'),
          ]),
        ],
        questionMeta: const {},
      );
      expect(out['clf-t1-1']!.length, 1); // dedup
      expect(out['clf-t1-1']!.single.section, 'ha-elasticity'); // 첫 section 유지
    });
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `cd /d/workspace/awc-docs/flutter_app && flutter.bat test test/concept_report_test.dart`
Expected: FAIL — `concept_report.dart` 없음.

- [ ] **Step 3: 구현**

`flutter_app/lib/data/concept_report.dart` 생성:

```dart
import '../models/attempt_record.dart';

/// 약점 리포트의 "놓친 개념" 한 항목.
class MissedConcept {
  const MissedConcept({required this.skill, required this.section});
  final String skill;
  final String section; // 학습문서 섹션 앵커 id (없으면 ''). 딥링크용.
}

/// cert의 비-review 응시에서 Task별 놓친 개념을 누적 집계(skill 기준 dedup,
/// 첫 section 유지). 레코드의 wrongSkills가 있으면 그것을, 없으면(레거시)
/// wrongQuestionIds를 [questionMeta](라이브 뱅크)로 조인. 키=taskId.
Map<String, List<MissedConcept>> buildConceptReport({
  required String certId,
  required List<AttemptRecord> history,
  required Map<String, ({String taskId, String skill, String section})>
      questionMeta,
}) {
  final byTask = <String, List<MissedConcept>>{};
  final seen = <String, Set<String>>{}; // taskId -> 본 skill 집합(dedup)

  void add(String taskId, String skill, String section) {
    if (skill.isEmpty) return;
    final s = seen.putIfAbsent(taskId, () => <String>{});
    if (!s.add(skill)) return; // 이미 본 개념
    byTask
        .putIfAbsent(taskId, () => <MissedConcept>[])
        .add(MissedConcept(skill: skill, section: section));
  }

  for (final r in history) {
    if (r.certId != certId || r.mode == 'review') continue;
    if (r.wrongSkills.isNotEmpty) {
      for (final w in r.wrongSkills) {
        add(w.taskId, w.skill, w.section);
      }
    } else {
      for (final qid in r.wrongQuestionIds) {
        final m = questionMeta[qid];
        if (m != null) add(m.taskId, m.skill, m.section);
      }
    }
  }
  return byTask;
}
```

- [ ] **Step 4: 통과 확인**

Run: `cd /d/workspace/awc-docs/flutter_app && flutter.bat test test/concept_report_test.dart`
Expected: PASS (신규 3).

- [ ] **Step 5: 커밋**

```bash
git add flutter_app/lib/data/concept_report.dart flutter_app/test/concept_report_test.dart
git commit -m "feat(report): 개념 집계 순수 함수 buildConceptReport — 비정규화 우선·라이브 조인 폴백"
```

---

### Task 4: report_page UI — 약점 Task 아래 개념 칩+섹션 딥링크

**Files:**
- Modify: `flutter_app/lib/pages/report_page.dart` (_load: questionMeta+conceptReport, _ReportLoad 확장, _row: 개념 칩 렌더)

**Interfaces:**
- Consumes: `buildConceptReport`·`MissedConcept` (Task 3), `studyDeepLink` (Phase 1, `lib/content/study_deep_link.dart`).

> 테스트 메모: report_page는 `rootBundle.loadString` 비동기 로드라 위젯테스트가 행될 수 있음. 집계 로직은 Task 3에서 단위 검증됨 → 이 Task 게이트는 `flutter analyze` 0 new + 전체 `flutter test` 그린 + dogfood(아래 Step 4). 신규 report 위젯테스트 없음.

- [ ] **Step 1: _load에 questionMeta + conceptReport 구성**

`flutter_app/lib/pages/report_page.dart`:

상단 import에 추가:
```dart
import '../content/study_deep_link.dart';
import '../data/concept_report.dart';
```

`_load()`(50-74행)에서 `taskByQuestionId` 구성 루프에 skill/section 수집을 더하고, report 생성 후 conceptReport를 만든다. 기존:
```dart
  Future<_ReportLoad> _load() async {
    final entries = contentFor(widget.cert.code);
    final taskByQuestionId = <String, String>{};
    final taskTitleById = <String, String>{};
    final taskOrder = <String>[];
    for (final e in entries) {
      taskTitleById[e.taskId] = e.title;
      taskOrder.add(e.taskId);
      try {
        final raw = await rootBundle.loadString(e.questionsAsset);
        final bank =
            QuestionBank.fromJson(json.decode(raw) as Map<String, dynamic>);
        for (final q in bank.questions) {
          taskByQuestionId[q.id] = e.taskId;
        }
      } catch (_) {}
    }
    final report = TaskScoreReport.build(
      certId: widget.cert.code,
      history: _history.all(),
      taskByQuestionId: taskByQuestionId,
      taskOrder: taskOrder,
    );
    return _ReportLoad(report: report, taskTitleById: taskTitleById);
  }
```
교체:
```dart
  Future<_ReportLoad> _load() async {
    final entries = contentFor(widget.cert.code);
    final taskByQuestionId = <String, String>{};
    final questionMeta =
        <String, ({String taskId, String skill, String section})>{};
    final taskTitleById = <String, String>{};
    final taskOrder = <String>[];
    for (final e in entries) {
      taskTitleById[e.taskId] = e.title;
      taskOrder.add(e.taskId);
      try {
        final raw = await rootBundle.loadString(e.questionsAsset);
        final bank =
            QuestionBank.fromJson(json.decode(raw) as Map<String, dynamic>);
        for (final q in bank.questions) {
          taskByQuestionId[q.id] = e.taskId;
          questionMeta[q.id] =
              (taskId: e.taskId, skill: q.skill, section: q.section);
        }
      } catch (_) {}
    }
    final history = _history.all();
    final report = TaskScoreReport.build(
      certId: widget.cert.code,
      history: history,
      taskByQuestionId: taskByQuestionId,
      taskOrder: taskOrder,
    );
    final conceptByTask = buildConceptReport(
      certId: widget.cert.code,
      history: history,
      questionMeta: questionMeta,
    );
    return _ReportLoad(
        report: report,
        taskTitleById: taskTitleById,
        conceptByTask: conceptByTask);
  }
```

- [ ] **Step 2: _ReportLoad에 conceptByTask 추가**

`_ReportLoad`(245-250행) 교체:
```dart
/// 로드 결과(리포트 + Task 제목 조회 + Task별 놓친 개념).
class _ReportLoad {
  const _ReportLoad({
    required this.report,
    required this.taskTitleById,
    required this.conceptByTask,
  });
  final TaskScoreReport report;
  final Map<String, String> taskTitleById;
  final Map<String, List<MissedConcept>> conceptByTask;
}
```

- [ ] **Step 3: _row에 약점 Task 개념 칩 렌더**

`_row`(185-242행)의 `isWeak` 링크 블록 다음, 카드 Column 끝에 개념 섹션을 추가한다. 현재 `_row`의 안쪽 `Column` children 마지막(하단 Row를 닫은 뒤, 203-238행 Column의 children 리스트 끝)에 아래를 추가:

```dart
            // 약점 Task: 놓친 개념 칩 + 섹션 딥링크(C-중량). DESIGN.md D3:
            // 칩=중립 라벨, 액센트는 링크에만.
            if (isWeak && (d.conceptByTask[s.taskId]?.isNotEmpty ?? false)) ...[
              const SizedBox(height: Gap.md),
              Text('놓친 개념',
                  style: t.labelSmall?.copyWith(color: c.textFaint)),
              const SizedBox(height: Gap.xs),
              Wrap(
                spacing: Gap.sm,
                runSpacing: Gap.xs,
                children: [
                  for (final mc in d.conceptByTask[s.taskId]!)
                    _ConceptLink(
                      cert: widget.cert.code,
                      taskId: s.taskId,
                      concept: mc,
                    ),
                ],
              ),
            ],
```

그리고 파일 끝(_ReportLoad 위/아래 적당한 위치)에 `_ConceptLink` 위젯 추가:
```dart
/// 약점 리포트의 놓친 개념 한 칩 — 라벨(중립) + 섹션 딥링크(액센트).
/// section 있으면 ?at= 딥링크, 없으면 문서 최상단.
class _ConceptLink extends StatelessWidget {
  const _ConceptLink(
      {required this.cert, required this.taskId, required this.concept});
  final String cert;
  final String taskId;
  final MissedConcept concept;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return InsetFocusRing(
      borderRadius: BorderRadius.circular(Radii.full),
      child: InkWell(
        onTap: () =>
            context.push(studyDeepLink(cert, taskId, concept.section)),
        borderRadius: BorderRadius.circular(Radii.full),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: Gap.sm, vertical: Gap.xs),
          decoration: BoxDecoration(
            color: c.surface2,
            borderRadius: BorderRadius.circular(Radii.full),
            border: Border.all(color: c.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(concept.skill,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      fontVariations: Wght.w700,
                      color: c.textMuted)),
              const SizedBox(width: Gap.xs),
              Text('→',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      fontVariations: Wght.w700,
                      color: c.accent)),
            ],
          ),
        ),
      ),
    );
  }
}
```

상단 import에 `InsetFocusRing`이 필요하다(`lib/widgets/focus_ring.dart`). 없으면 추가:
```dart
import '../widgets/focus_ring.dart';
```

- [ ] **Step 4: analyze + 회귀 + dogfood**

Run: `cd /d/workspace/awc-docs/flutter_app && flutter.bat analyze && flutter.bat test`
Expected: analyze 신규 0건, 테스트 전부 그린.

웹 빌드(PowerShell): `flutter build web --release --base-href /aws-docs/`.
dogfood(메모리 flutter-web-dogfood-browse 레시피, base-href 프리픽스 정적 서버):
1. localStorage에 약점 Task가 생기도록 해당 cert 약점 모의고사를 풀거나, 응시 이력을 주입.
2. `…/#/cert/CLF-C02/report` 열어 약점 Task 아래 "놓친 개념" 칩이 보이는지, 칩 클릭 시 `?at=section`으로 학습문서 섹션에 스크롤되는지 스크린샷 확인.
3. 콘솔 에러 0(알려진 경고만).

- [ ] **Step 5: 커밋**

```bash
git add flutter_app/lib/pages/report_page.dart
git commit -m "feat(report): 약점 Task별 놓친 개념 칩 + 섹션 딥링크(C-중량 Phase 2 UI)"
```

---

## 완료 후

Phase 2 게이트: `flutter test` 그린 + `flutter analyze` 신규 0건 + report dogfood 확인. 이후 `feat/concept-report` → PR. Phase 1(PR #15)이 develop에 머지됐으면 base=develop, 아직이면 base=`feat/concept-deeplink`(스택) 후 Phase 1 머지 시 retarget. C-중량 완료 → HANDOFF.md 갱신(다음 세션).
