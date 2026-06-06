# Phase 1 · E1b — 오답노트 복습 UI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** E1a 데이터 기반(`WrongAnswerIndex`) 위에 사용자가 보는 오답노트 복습 경험을 올린다 — cert별 weak 문항을 Task별로 모아 보여주고(`ReviewListPage`), 연습형 즉시피드백으로 재응시해(`review` 모드 `QuizView`) 연속 2회 정답으로 졸업시킨다. cert 상세에 "오답 N" 배지 + 오답노트 진입을 추가한다.

**Architecture:** 새 라우트 `/cert/:code/review` → `ReviewListPage`(로더, `CertExamPage` 패턴). 페이지가 cert의 19개 뱅크를 로드해 `taskByQuestionId`(문항ID→TaskID)·`byId`(문항ID→Question)를 구성하고 `HistoryStore` 이력과 함께 `WrongAnswerIndex.build`를 호출. weak 엔트리를 Task별로 묶어 "복습 시작" 제공. 복습 러너는 **별도 클래스를 만들지 않고 기존 `QuizView`를 재사용** — `mode`/`examId` 옵셔널 파라미터를 추가해 `mode:'review'`, `examId:'review:<taskId>'`로 구성(설계의 `ReviewView`는 이렇게 구현). 종료 시 이력에 기록 후 인덱스를 재계산(졸업 문항 즉시 사라짐). cert 상세는 `_load()`를 확장해 `weakByTask`를 계산, Task 행에 배지 + cert 레벨 오답노트 진입을 추가.

**Tech Stack:** Flutter (Dart), go_router, 기존 `quiz_widgets`·테마 토큰 재사용(새 디자인 언어 없음 — DESIGN.md "조용한 레퍼런스").

**경로:** 코드 = `D:\workspace\awc-docs\flutter_app`. flutter는 **PowerShell**로 `flutter_app`에서. git은 **`cd /d/workspace/awc-docs`**(Bash) 또는 절대 `-C`.

**스펙:** `docs/superpowers/specs/2026-06-06-learning-loop-e1-design.md` §5·§6·§7 + 로드맵 §4. **선행:** E1a 완료(`AttemptRecord.presentedQuestionIds`, `lib/data/wrong_answer_index.dart`).

**테스트 함정(필수 인지):** `ReviewListPage`·`CertDetailPage`는 비동기 로더(+SelectionArea) → 위젯 렌더 테스트 시 "RenderBox was not laid out" 크래시. **렌더 테스트 금지.** 러너(`QuizView`)는 모델주입으로 테스트 가능. 라우팅은 redirect/HomePage 도달만(app_router_test 패턴). 페이지 동작은 headless dogfood로 검증.

---

## Task 1: `QuizView`에 `mode`/`examId` 파라미터 추가 (복습 재사용)

연습 러너 `QuizView`를 복습에도 재사용하기 위해 기록 메타(`mode`·`examId`)를 주입 가능하게 한다. 기본값은 기존 동작 그대로(연습) → 기존 호출부·테스트 무영향.

**Files:**
- Modify: `flutter_app/lib/pages/quiz_page.dart` (`QuizView`)
- Test: `flutter_app/test/quiz_view_test.dart`

- [ ] **Step 1: 실패하는 테스트 추가 — 복습 설정 시 review 레코드**

`flutter_app/test/quiz_view_test.dart`의 `main()` 안, 기존 testWidgets 아래에 추가:
```dart
  testWidgets('mode/examId 주입 시 review 레코드로 기록', (tester) async {
    AttemptRecord? finished;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: QuizView(
          bank: _bank(),
          certId: 'CLF-C02',
          mode: 'review',
          examId: 'review:clf-t2-1',
          onFinished: (r) => finished = r,
        ),
      ),
    ));

    await tester.tap(find.text('EC2'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('결과 보기'));
    await tester.pumpAndSettle();

    expect(finished, isNotNull);
    expect(finished!.mode, 'review');
    expect(finished!.examId, 'review:clf-t2-1');
    expect(finished!.presentedQuestionIds, ['q1']);
  });
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `flutter test test/quiz_view_test.dart`
Expected: 컴파일 실패 — `QuizView`에 `mode`/`examId` 파라미터 없음.

- [ ] **Step 3: QuizView에 파라미터 추가**

`flutter_app/lib/pages/quiz_page.dart`의 `QuizView` 생성자·필드를 갱신.

생성자:
```dart
  const QuizView({
    super.key,
    required this.bank,
    required this.certId,
    this.mode = 'practice',
    this.examId,
    this.onFinished,
  });

  final QuestionBank bank;
  final String certId;

  /// 기록 모드: 'practice'(기본) | 'review'. 헤드라인 통계 분리용.
  final String mode;

  /// 기록 examId. null이면 'practice:${bank.examGuideTaskId}'.
  final String? examId;
  final void Function(AttemptRecord)? onFinished;
```

`_finish()`의 `AttemptRecord(` 생성에서 `examId`·`mode` 두 줄을 교체:
```dart
    widget.onFinished?.call(AttemptRecord(
      certId: widget.certId,
      examId: widget.examId ?? 'practice:${widget.bank.examGuideTaskId}',
      mode: widget.mode,
      date: DateTime.now().toIso8601String(),
```

- [ ] **Step 4: 테스트 통과 + 회귀 확인**

Run:
```
flutter test test/quiz_view_test.dart
flutter analyze
```
Expected: 신규 + 기존 'onFinished 호출' 테스트 PASS(기본값이 연습 동작 보존). analyze 이슈 0.

- [ ] **Step 5: 커밋**

```
cd /d/workspace/awc-docs && git add flutter_app/lib/pages/quiz_page.dart flutter_app/test/quiz_view_test.dart && git commit -m "feat: QuizView에 mode/examId 주입 추가(복습 러너 재사용 토대)"
```

---

## Task 2: `ReviewListPage` + 라우트

cert별 오답노트 목록 + 복습 러너(같은 페이지 내 상태 전환). 로더는 `CertExamPage` 패턴을 따른다.

**Files:**
- Create: `flutter_app/lib/pages/review_page.dart`
- Modify: `flutter_app/lib/app_router.dart`
- Test: `flutter_app/test/app_router_test.dart`

- [ ] **Step 1: `review_page.dart` 작성**

`flutter_app/lib/pages/review_page.dart` 생성:
```dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:go_router/go_router.dart';

import '../content/quiz_widgets.dart';
import '../data/content_index.dart';
import '../data/history_store.dart';
import '../data/wrong_answer_index.dart';
import '../models/certification.dart';
import '../models/question.dart';
import '../theme/app_theme.dart';
import 'quiz_page.dart'; // QuizView

/// 오답노트: cert의 weak 문항을 Task별로 모아 보여주고 연습형으로 재응시.
/// 로더 → 시작 목록 / 복습 러너(QuizView, mode:'review')를 같은 페이지에서 전환.
class ReviewListPage extends StatefulWidget {
  const ReviewListPage({super.key, required this.cert});
  final Certification cert;

  @override
  State<ReviewListPage> createState() => _ReviewListPageState();
}

class _ReviewListPageState extends State<ReviewListPage> {
  final _history = HistoryStore();
  late Future<_ReviewLoad> _future = _load();
  _ReviewRun? _running;

  Future<_ReviewLoad> _load() async {
    final entries = contentFor(widget.cert.code);
    final byId = <String, Question>{};
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
          byId[q.id] = q;
          taskByQuestionId[q.id] = e.taskId;
        }
      } catch (_) {
        // 개별 뱅크 로드 실패는 무시(나머지로 진행)
      }
    }
    final index = WrongAnswerIndex.build(
      certId: widget.cert.code,
      history: _history.all(),
      taskByQuestionId: taskByQuestionId,
    );
    return _ReviewLoad(
      index: index,
      byId: byId,
      taskTitleById: taskTitleById,
      taskOrder: taskOrder,
    );
  }

  void _startTask(_ReviewLoad d, String taskId) {
    final queue = [
      for (final e in d.index.weakEntries(taskId))
        if (d.byId[e.questionId] != null) d.byId[e.questionId]!,
    ];
    if (queue.isEmpty) return;
    setState(() => _running = _ReviewRun(taskId, queue));
  }

  void _onFinished(AttemptRecord rec) {
    _history.add(rec);
    setState(() {
      _running = null;
      _future = _load(); // 졸업 문항 반영해 목록 재계산
    });
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
        title: Text('${widget.cert.title} · 오답노트',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      body: FutureBuilder<_ReviewLoad>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snap.data;
          if (snap.hasError || data == null) {
            return Center(
                child: Text('오답노트를 불러오지 못했습니다.',
                    style: TextStyle(color: c.textMuted)));
          }
          if (_running != null) return _runner(data, _running!);
          return _list(data);
        },
      ),
    );
  }

  Widget _runner(_ReviewLoad d, _ReviewRun run) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Layout.exam),
        child: QuizView(
          bank: QuestionBank(
            examGuideTaskId: run.taskId,
            taskTitle: d.taskTitleById[run.taskId] ?? '복습',
            certCode: widget.cert.code,
            domain: 0,
            questions: run.queue,
          ),
          certId: widget.cert.code,
          mode: 'review',
          examId: 'review:${run.taskId}',
          onFinished: _onFinished,
        ),
      ),
    );
  }

  Widget _list(_ReviewLoad d) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    final weakTasks = [
      for (final taskId in d.taskOrder)
        if (d.index.weakEntries(taskId).isNotEmpty) taskId,
    ];
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Gap.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('오답노트', style: t.headlineSmall),
              const SizedBox(height: Gap.sm),
              Text('연습·시험에서 틀린 문항을 모아 다시 풉니다. 서로 다른 회차에서 연속 2번 맞히면 졸업합니다.',
                  style: t.bodyMedium),
              const SizedBox(height: Gap.xl),
              if (weakTasks.isEmpty)
                _empty(c, t)
              else
                for (final taskId in weakTasks)
                  _taskRow(c, t, d, taskId),
            ],
          ),
        ),
      ),
    );
  }

  Widget _empty(AppColors c, TextTheme t) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Gap.xl),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(color: c.border),
        ),
        child: Text('아직 오답이 없습니다 — 연습이나 시험을 풀면 여기에 모입니다.',
            style: t.bodyMedium?.copyWith(color: c.text)),
      );

  Widget _taskRow(AppColors c, TextTheme t, _ReviewLoad d, String taskId) {
    final count = d.index.weakEntries(taskId).length;
    final title = d.taskTitleById[taskId] ?? taskId;
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.md),
      child: Container(
        padding: const EdgeInsets.all(Gap.lg),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(color: c.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: t.titleMedium),
                  const SizedBox(height: Gap.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                        color: c.wrongWeak,
                        borderRadius: BorderRadius.circular(Radii.full)),
                    child: Text('오답 $count',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: c.wrong)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: Gap.md),
            SizedBox(
              width: 120,
              child: PrimaryButton(
                  label: '복습 시작', onTap: () => _startTask(d, taskId)),
            ),
          ],
        ),
      ),
    );
  }
}

/// 로드 결과(약점 인덱스 + 문항 조회 + Task 표시 메타).
class _ReviewLoad {
  const _ReviewLoad({
    required this.index,
    required this.byId,
    required this.taskTitleById,
    required this.taskOrder,
  });
  final WrongAnswerIndex index;
  final Map<String, Question> byId;
  final Map<String, String> taskTitleById;
  final List<String> taskOrder;
}

/// 진행 중 복습(선택한 Task의 weak 큐).
class _ReviewRun {
  const _ReviewRun(this.taskId, this.queue);
  final String taskId;
  final List<Question> queue;
}
```

- [ ] **Step 2: 라우트 추가**

`flutter_app/lib/app_router.dart`에 import 추가(상단 import 묶음, 알파벳 순 위치):
```dart
import 'pages/review_page.dart';
```
그리고 `cert/:code`의 `routes:` 리스트에서 `exam` GoRoute 다음에 추가:
```dart
                GoRoute(
                  path: 'review',
                  builder: (context, state) =>
                      ReviewListPage(cert: certByCode(state.pathParameters['code']!)!),
                ),
```
(상위 `cert/:code`의 redirect가 잘못된 코드를 '/'로 보내므로 별도 가드 불필요.)

- [ ] **Step 3: 라우팅 테스트 추가(렌더 금지 — redirect만)**

`flutter_app/test/app_router_test.dart`의 `main()` 안에 추가:
```dart
  testWidgets('잘못된 cert review 경로 → "/"로 redirect', (tester) async {
    await tester.pumpWidget(_app('/cert/NOPE/review'));
    await tester.pump();
    expect(find.byType(HomePage), findsOneWidget);
  });
```

- [ ] **Step 4: analyze + 전체 테스트**

PowerShell, `flutter_app`에서:
```
flutter analyze
flutter test
```
Expected: 이슈 0, 전체 green(신규 라우팅 테스트 포함). ReviewListPage는 렌더 테스트하지 않음.

- [ ] **Step 5: 커밋**

```
cd /d/workspace/awc-docs && git add flutter_app/lib/pages/review_page.dart flutter_app/lib/app_router.dart flutter_app/test/app_router_test.dart && git commit -m "feat: 오답노트 ReviewListPage + /cert/:code/review 라우트(QuizView review 재사용)"
```

---

## Task 3: cert 상세 "오답 N" 배지 + 오답노트 진입

`CertDetailPage._load()`를 확장해 `weakByTask`를 계산하고, `_LearningContent` Task 행에 배지 + 학습 콘텐츠 섹션에 오답노트 진입을 추가.

**Files:**
- Modify: `flutter_app/lib/pages/cert_detail_page.dart`

- [ ] **Step 1: `_load()`가 weakByTask를 계산하도록 확장**

`flutter_app/lib/pages/cert_detail_page.dart` 상단 import에 추가:
```dart
import '../data/history_store.dart';
import '../data/wrong_answer_index.dart';
import '../models/question.dart';
```

`typedef _Loaded`를 확장:
```dart
typedef _Loaded = ({
  ExamGuide? guide,
  ExamSummary? summary,
  Map<String, int> weakByTask,
});
```

`_load()`를 교체(기존 guide/summary 로직 유지 + 뱅크 로드/약점 계산 추가):
```dart
  Future<_Loaded> _load() async {
    ExamGuide? guide;
    ExamSummary? summary;
    try {
      final raw = await rootBundle.loadString('assets/exam_guides/${cert.code}.json');
      guide = ExamGuide.fromJson(json.decode(raw) as Map<String, dynamic>);
    } catch (_) {}
    try {
      final raw = await rootBundle.loadString('assets/exam_summaries.json');
      final m = json.decode(raw) as Map<String, dynamic>;
      final entry = m[cert.code];
      if (entry is Map<String, dynamic>) summary = ExamSummary.fromJson(entry);
    } catch (_) {}

    // 오답노트 배지: 뱅크 로드 → taskByQuestionId → 약점 인덱스.
    final taskByQuestionId = <String, String>{};
    for (final e in contentFor(cert.code)) {
      try {
        final raw = await rootBundle.loadString(e.questionsAsset);
        final bank =
            QuestionBank.fromJson(json.decode(raw) as Map<String, dynamic>);
        for (final q in bank.questions) {
          taskByQuestionId[q.id] = e.taskId;
        }
      } catch (_) {}
    }
    final weakByTask = WrongAnswerIndex.build(
      certId: cert.code,
      history: HistoryStore().all(),
      taskByQuestionId: taskByQuestionId,
    ).weakByTask();

    return (guide: guide, summary: summary, weakByTask: weakByTask);
  }
```

- [ ] **Step 2: `_LearningContent`에 weakByTask 전달 + 오답노트 진입**

`build`에서 `_LearningContent` 생성부를 교체:
```dart
                          if (contentFor(cert.code).isNotEmpty)
                            _LearningContent(
                              entries: contentFor(cert.code),
                              weakByTask: snap.data?.weakByTask ?? const {},
                            ),
```

`_LearningContent` 클래스를 갱신 — 필드/생성자에 `weakByTask` 추가:
```dart
class _LearningContent extends StatelessWidget {
  const _LearningContent({required this.entries, required this.weakByTask});
  final List<ContentEntry> entries;
  final Map<String, int> weakByTask;
```

- [ ] **Step 3: Task 행에 "오답 N" 배지 추가**

`_LearningContent.build`의 각 entry 카드에서, "검증 문항 N" 배지(`Container(... '검증 문항 ${e.questionCount}' ...)`)를 감싼 부분을 Row로 바꿔 오답 배지를 나란히 둔다. 해당 `Container(`(검증 문항 배지) 전체를 아래로 교체:
```dart
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                      color: c.correctWeak,
                                      borderRadius:
                                          BorderRadius.circular(Radii.full)),
                                  child: Text('검증 문항 ${e.questionCount}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: c.correct)),
                                ),
                                if ((weakByTask[e.taskId] ?? 0) > 0) ...[
                                  const SizedBox(width: Gap.xs),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                        color: c.wrongWeak,
                                        borderRadius:
                                            BorderRadius.circular(Radii.full)),
                                    child: Text('오답 ${weakByTask[e.taskId]}',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: c.wrong)),
                                  ),
                                ],
                              ],
                            ),
```

- [ ] **Step 4: 학습 콘텐츠 섹션에 오답노트 진입 버튼**

`_LearningContent.build`에서 entries 루프(`for (final e in entries) ...`) **아래**, Column children 끝에 cert 레벨 오답노트 진입을 추가. weak 총합이 있을 때만 노출:
```dart
          for (final e in entries)
            Padding(
              // ... (기존 entry 카드, 변경 없음)
            ),
          if (weakByTask.values.fold(0, (a, b) => a + b) > 0)
            Padding(
              padding: const EdgeInsets.only(top: Gap.xs),
              child: InkWell(
                onTap: () => context.push('/cert/${entries.first.certCode}/review'),
                borderRadius: BorderRadius.circular(Radii.md),
                child: Container(
                  padding: const EdgeInsets.all(Gap.lg),
                  decoration: BoxDecoration(
                    color: c.wrongWeak,
                    borderRadius: BorderRadius.circular(Radii.md),
                    border: Border.all(color: c.wrong.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.refresh, size: 18, color: c.wrong),
                      const SizedBox(width: Gap.sm),
                      Expanded(
                        child: Text(
                            '오답노트 · 틀린 ${weakByTask.values.fold(0, (a, b) => a + b)}문항 다시 풀기',
                            style: t.titleMedium?.copyWith(color: c.text)),
                      ),
                      Text('복습 →',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: c.wrong)),
                    ],
                  ),
                ),
              ),
            ),
```

- [ ] **Step 5: analyze + 전체 테스트**

PowerShell, `flutter_app`에서:
```
flutter analyze
flutter test
```
Expected: 이슈 0, 전체 green. (CertDetailPage는 SelectionArea라 렌더 테스트 없음 — 기존 라우팅 테스트가 잘못된 코드 redirect만 검증.)

- [ ] **Step 6: 커밋**

```
cd /d/workspace/awc-docs && git add flutter_app/lib/pages/cert_detail_page.dart && git commit -m "feat: cert 상세 Task별 '오답 N' 배지 + 오답노트 진입(weakByTask)"
```

---

## Task 4: 게이트 검증 + headless dogfood

**Files:** 없음(검증) + 핸드오프/메모리.

- [ ] **Step 1: analyze + 전체 테스트 + 릴리스 빌드**

PowerShell, `flutter_app`에서:
```
flutter analyze
flutter test
flutter build web --release --base-href /aws-docs/
```
Expected: analyze 무결 · 전체 green · 빌드 성공.

- [ ] **Step 2: headless dogfood (E1 흐름 실증)**

PowerShell, `flutter_app`에서:
```
flutter build web --base-href /
py -m http.server 5151 --directory build\web
```
gstack browse로 (CanvasKit라 'Enable accessibility' JS click 후 @ref 구동):
1. `http://localhost:5151/#/cert/CLF-C02/study/clf-t2-1/quiz` → 연습에서 **일부러 1문항 틀리기** → 결과.
2. `http://localhost:5151/#/cert/CLF-C02` → 해당 Task 행에 **"오답 N" 배지** + 하단 **오답노트 진입** 노출 확인.
3. 오답노트 진입 → `ReviewListPage`에 Task 그룹 + "오답 N" + "복습 시작" 확인.
4. "복습 시작" → 틀린 문항 재응시(즉시 피드백) → 정답 → 결과 → 목록 복귀.
5. (졸업 확인) 같은 문항을 한 번 더 복습해 정답 → **연속 2회 정답 → 목록에서 사라짐**(weak 0 시 빈 상태) 확인.

dogfood 불가 시 Step 1로 최소 게이트 충족, 수동 확인 권장 메모.

- [ ] **Step 3: 핸드오프·메모리 현행화**

`docs/plans/2026-06-06-session-handoff.md`: E1(오답노트) 완료(E1a+E1b), 라이브 흐름(연습/시험 오답 → cert 상세 배지 → 오답노트 → 재응시 → 2연속 졸업), 다음 = E2(약점 리포트, 별도 brainstorm→spec). 크로스세션 메모리(`work-priority-roadmap-phase0.md`) 한 줄 반영. 커밋:
```
cd /d/workspace/awc-docs && git add docs/plans/2026-06-06-session-handoff.md && git commit -m "docs: E1 오답노트(E1a+E1b) 완료 핸드오프 현행화(다음=E2 약점리포트)"
```

- [ ] **Step 4: push는 finishing-a-development-branch로 사용자 확인 후**

---

## Self-Review (작성자 점검 완료)

- **스펙 커버리지:** 설계 §5 — cert 상세 "오답 N" 배지=Task 3 Step 3, cert 오답노트 진입=Task 3 Step 4, `ReviewListPage`(Task별 묶음·복습 시작·빈 상태)=Task 2, `ReviewView`(연습형·mode:'review'·examId·presentedQuestionIds)=Task 1+2(QuizView 재사용). §6 정직함(review 분리 기록)=mode:'review'. §7 엣지(오답 0 빈 상태, stale 제외, 졸업 후 사라짐, 뱅크 로드 실패 무시)=Task 2 _load/_list. 라우트=Task 2 Step 2.
- **DRY 결정:** 별도 `ReviewView` 클래스 대신 `QuizView`(연습 러너) 재사용 — `mode`/`examId` 옵셔널 주입. 설계의 `ReviewView` = "review로 구성된 QuizView". ~90줄 중복 제거, 새 디자인 언어 없음.
- **플레이스홀더 스캔:** TBD/TODO 없음. 모든 코드 스텝에 실제 코드.
- **타입 일관성:** `QuizView({mode='practice', examId})`가 Task 1 정의·Task 2 사용에서 일치. `WrongAnswerIndex.build({certId, history, taskByQuestionId})`/`weakEntries([taskId])`/`weakByTask()`는 E1a 시그니처 그대로. `_Loaded` record에 `weakByTask` 추가 — `_load()` 반환·소비부 동시 갱신. `ReviewListPage(cert: Certification)` 생성자가 라우트 빌더와 일치. 합성 `QuestionBank(examGuideTaskId, taskTitle, certCode, domain, questions)`는 `CertExamPage` 패턴과 동일 필드.
- **회귀:** Task 1 기본값이 연습 동작 보존(기존 QuizPage·테스트 무영향). cert 상세 `_load` 확장은 실패 try/catch로 감싸 뱅크 부재에도 guide/summary 정상.
- **테스트 함정:** 렌더 테스트는 모델주입 가능한 QuizView만(Task 1). ReviewListPage·CertDetailPage는 라우팅 redirect 테스트 + dogfood. SelectionArea 렌더 금지 준수.
