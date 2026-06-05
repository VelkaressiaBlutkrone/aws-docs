# CLF 학습 루프 #2 (시험 모드) 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 검증 콘텐츠가 있는 CLF Task를 "시험처럼" 풀 수 있게 한다 — 실전 비례 타이머 + 자유 네비게이션 + 문항 플래그 + 제출 전 정답 비공개 + 제출 시 채점·복기 + 새로고침 후 완전 세션 복원. 기존 "연습 모드"는 불변.

**Architecture:** 공유 위젯(`quiz_widgets.dart`)·KV 백엔드(`local_kv.dart`)를 추출해 연습/시험이 재사용한다. 시험 러너 `ExamView`는 주입식(QuestionBank + 콜백 + 테스트 클록)이라 자산/localStorage 의존 없이 위젯 테스트로 타이머·자동제출·복원을 결정적으로 검증한다. 얇은 로더 `ExamPage`가 자산을 읽고 세션을 복원해 `ExamView`에 주입한다.

**Tech Stack:** Flutter Web / Dart · 기존 테마 토큰(`context.c`/`Gap`/`Radii`/`Layout`/`AppTheme.monoFamily`) · `dart:async` `Timer.periodic` · `package:web`(조건부 import) localStorage · 외부 패키지 미사용.

**Spec:** `docs/designs/2026-06-06-clf-learning-loop-subproject-2-spec.md` (APPROVED).

---

## 작업 디렉터리 / 사전 규칙

- **git repo 루트:** `D:\workspace\awc-docs\aws-docs`. git 명령은 여기서.
- **Flutter 패키지 루트:** `D:\workspace\awc-docs\aws-docs\flutter_app`. `flutter` 명령은 여기서.
- **브랜치:** 이미 `feat/clf-learning-loop-subproject-2`에 있음(스펙 커밋 완료). 여기서 작업·커밋.
- 커밋 메시지 끝 트레일러:
  ```
  Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
  ```
- 색·간격은 **항상 `context.c`/`Gap`/`Radii`/`Layout` 토큰**만(하드코딩 금지, DESIGN.md).

## 파일 구조 (생성/수정)

| 파일 | 책임 |
|---|---|
| `lib/data/local_kv.dart` | **신규** — `KvBackend`(인터페이스)/`MemoryBackend`/`defaultBackend()`. 조건부 import로 `WebBackend` 선택 |
| `lib/data/web_backend_stub.dart` | **수정** — `import 'local_kv.dart'`, `implements KvBackend` |
| `lib/data/web_backend_web.dart` | **수정** — `import 'local_kv.dart'`, `implements KvBackend` |
| `lib/data/history_store.dart` | **수정** — 백엔드 정의 제거, `local_kv.dart` import+re-export, `defaultBackend()` 사용 |
| `lib/content/quiz_widgets.dart` | **신규** — `OptState`/`OptionTile`/`ExplainBox`/`PrimaryButton`/`ResultsView`/`ResultCard`(연습·시험 공유) |
| `lib/pages/quiz_page.dart` | **수정** — 추출 위젯 import 사용, 중복 클래스 제거 |
| `lib/models/exam_session.dart` | **신규** — `ExamSession`(+JSON), `bankFingerprint()`, `examDurationSec()` |
| `lib/data/exam_session_store.dart` | **신규** — 활성 세션 `load/save/clear` |
| `lib/pages/exam_page.dart` | **신규** — `ExamView`(타이머 러너) + `ExamPage`(로더+복원) |
| `lib/pages/study_doc_page.dart` | **수정** — "시험처럼 풀기" CTA 추가 |
| `test/exam_session_test.dart` | **신규** — 모델·store·헬퍼 단위 테스트 |
| `test/exam_view_test.dart` | **신규** — 타이머·자동제출·플래그·가드 위젯 테스트 |

---

## Task 1: KV 백엔드 추출 (`local_kv.dart`) — 리팩터(회귀 green)

`HistoryBackend`/`MemoryBackend`/웹 선택 로직을 `history_store.dart`에서 `local_kv.dart`로 옮겨 시험 세션 저장소도 공유한다. 인터페이스명을 일반적인 `KvBackend`로 정리한다. `history_store.dart`는 `local_kv.dart`를 re-export 해 기존 import 경로 호환을 유지(기존 테스트 무수정).

**Files:**
- Create: `flutter_app/lib/data/local_kv.dart`
- Modify: `flutter_app/lib/data/web_backend_stub.dart`
- Modify: `flutter_app/lib/data/web_backend_web.dart`
- Modify: `flutter_app/lib/data/history_store.dart`

- [ ] **Step 1: `local_kv.dart` 생성**

`flutter_app/lib/data/local_kv.dart`:

```dart
import 'package:flutter/foundation.dart' show kIsWeb;

// 조건부 import: 웹은 실제 localStorage, VM/테스트는 stub.
import 'web_backend_stub.dart'
    if (dart.library.js_interop) 'web_backend_web.dart';

/// 키-값 백엔드(이력·시험 세션 공유). 테스트는 [MemoryBackend] 주입.
abstract interface class KvBackend {
  String? read(String key);
  void write(String key, String value);
}

class MemoryBackend implements KvBackend {
  final _m = <String, String>{};
  @override
  String? read(String key) => _m[key];
  @override
  void write(String key, String value) => _m[key] = value;
}

/// 기본 백엔드: 웹은 localStorage([WebBackend]), 그 외(VM/테스트)는 메모리.
KvBackend defaultBackend() => kIsWeb ? WebBackend() : MemoryBackend();
```

- [ ] **Step 2: 웹 백엔드 stub/web의 import·인터페이스 갱신**

`flutter_app/lib/data/web_backend_stub.dart` (전체 교체):

```dart
import 'local_kv.dart';

/// Non-web stub — never used at runtime on web, only satisfies VM/test compiler.
class WebBackend implements KvBackend {
  @override
  String? read(String key) => null;
  @override
  void write(String key, String value) {}
}
```

`flutter_app/lib/data/web_backend_web.dart` (전체 교체):

```dart
import 'package:web/web.dart' as web;
import 'local_kv.dart';

/// Real localStorage backend — compiled only when targeting web.
class WebBackend implements KvBackend {
  @override
  String? read(String key) => web.window.localStorage.getItem(key);
  @override
  void write(String key, String value) =>
      web.window.localStorage.setItem(key, value);
}
```

- [ ] **Step 3: `history_store.dart`에서 백엔드 정의 제거 + local_kv 사용**

`flutter_app/lib/data/history_store.dart` (전체 교체):

```dart
import 'dart:convert';

import '../models/attempt_record.dart';
import 'local_kv.dart';

// 기존 소비자(import 'history_store.dart')가 KvBackend/MemoryBackend를 계속
// 보도록 re-export(하위 호환).
export 'local_kv.dart' show KvBackend, MemoryBackend, defaultBackend;

class HistoryStore {
  HistoryStore({KvBackend? backend}) : _b = backend ?? defaultBackend();

  final KvBackend _b;
  static const _key = 'awsdocs.history.v1';

  List<AttemptRecord> all() {
    final raw = _b.read(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => AttemptRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return []; // 손상 데이터는 무시
    }
  }

  void add(AttemptRecord r) {
    final list = all()..add(r);
    _b.write(_key, jsonEncode(list.map((e) => e.toJson()).toList()));
  }
}
```

- [ ] **Step 4: 회귀 테스트(기존 이력 테스트 green)**

Run (in `flutter_app/`): `flutter test test/history_store_test.dart`
Expected: PASS (기존 테스트가 `MemoryBackend`를 re-export로 그대로 참조 → 무수정 통과).

- [ ] **Step 5: 분석 확인**

Run (in `flutter_app/`): `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 6: Commit**

```bash
git -C D:/workspace/awc-docs/aws-docs add flutter_app/lib/data/local_kv.dart flutter_app/lib/data/web_backend_stub.dart flutter_app/lib/data/web_backend_web.dart flutter_app/lib/data/history_store.dart
git -C D:/workspace/awc-docs/aws-docs commit -m "refactor: KV 백엔드를 local_kv.dart로 추출(이력·시험 세션 공유)" -m "Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 2: 공유 퀴즈 위젯 추출 (`quiz_widgets.dart`) — 리팩터(회귀 green)

`quiz_page.dart`의 비공개 위젯을 공개 위젯으로 `quiz_widgets.dart`에 옮겨 시험 모드가 재사용한다. `ResultsView`는 시험용 옵션 파라미터(`flagged`/`subtitle`/액션 콜백)를 **기본값으로 무동작** 추가해 연습 동작을 보존한다.

**Files:**
- Create: `flutter_app/lib/content/quiz_widgets.dart`
- Modify: `flutter_app/lib/pages/quiz_page.dart`

- [ ] **Step 1: `quiz_widgets.dart` 생성**

`flutter_app/lib/content/quiz_widgets.dart`:

```dart
import 'package:flutter/material.dart';

import '../models/question.dart';
import '../theme/app_theme.dart';

/// 보기 카드 상태(연습: 공개 후 correct/wrong / 시험: 항상 idle).
enum OptState { idle, correct, wrong }

class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    required this.text,
    required this.selected,
    required this.state,
    required this.onTap,
  });
  final String text;
  final bool selected;
  final OptState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    late Color border;
    late Color bg;
    switch (state) {
      case OptState.correct:
        border = c.correct;
        bg = c.correctWeak;
      case OptState.wrong:
        border = c.wrong;
        bg = c.wrongWeak;
      case OptState.idle:
        border = selected ? c.accent : c.border;
        bg = selected ? c.accentWeak : c.surface;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.md),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(Gap.md),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(Radii.md),
            border: Border.all(color: border, width: selected ? 2 : 1),
          ),
          child: Text(text,
              style: TextStyle(fontSize: 15, height: 1.5, color: c.text)),
        ),
      ),
    );
  }
}

class ExplainBox extends StatelessWidget {
  const ExplainBox({
    super.key,
    required this.bg,
    required this.bar,
    required this.label,
    required this.text,
  });
  final Color bg;
  final Color bar;
  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Gap.md),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(Radii.sm),
        border: Border(left: BorderSide(color: bar, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w800, color: bar)),
          const SizedBox(height: 4),
          Text(text, style: TextStyle(fontSize: 15, height: 1.6, color: c.text)),
        ],
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Radii.sm),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: Gap.lg),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? c.accent : c.surface2,
          borderRadius: BorderRadius.circular(Radii.sm),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: enabled ? c.onAccent : c.textFaint)),
      ),
    );
  }
}

/// 결과 화면(연습·시험 공유). [flagged]·[subtitle]은 시험 모드에서만 전달.
class ResultsView extends StatelessWidget {
  const ResultsView({
    super.key,
    required this.bank,
    required this.picked,
    this.flagged = const {},
    this.subtitle,
  });
  final QuestionBank bank;
  final Map<int, int> picked;
  final Set<int> flagged;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    final qs = bank.questions;
    var correct = 0;
    for (var k = 0; k < qs.length; k++) {
      if (picked[k] == qs[k].correct) correct++;
    }
    final pct = qs.isEmpty ? 0 : (correct * 100 / qs.length).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('결과', style: t.headlineSmall),
        const SizedBox(height: Gap.sm),
        Text('$correct / ${qs.length}  ·  $pct%',
            style: t.displayMedium?.copyWith(color: c.accent)),
        if (subtitle != null) ...[
          const SizedBox(height: Gap.xs),
          Text(subtitle!, style: t.bodyMedium),
        ],
        const SizedBox(height: Gap.xl),
        for (var k = 0; k < qs.length; k++)
          ResultCard(
              index: k,
              q: qs[k],
              pickedIndex: picked[k],
              flagged: flagged.contains(k)),
      ],
    );
  }
}

/// 결과 화면의 문항별 복기 카드: stem + 내 답/정답 + 해설 재표시.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.index,
    required this.q,
    required this.pickedIndex,
    this.flagged = false,
  });
  final int index;
  final Question q;
  final int? pickedIndex;
  final bool flagged;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    final isCorrect = pickedIndex == q.correct;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: Gap.md),
      padding: const EdgeInsets.all(Gap.md),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(isCorrect ? Icons.check_circle : Icons.cancel,
                  size: 18, color: isCorrect ? c.correct : c.wrong),
              const SizedBox(width: Gap.sm),
              Expanded(
                  child: Text('${index + 1}. ${q.stem}',
                      style: t.bodyLarge
                          ?.copyWith(fontSize: 15, fontWeight: FontWeight.w700))),
              if (flagged)
                Padding(
                  padding: const EdgeInsets.only(left: Gap.sm),
                  child: Icon(Icons.flag, size: 16, color: c.warning),
                ),
            ],
          ),
          const SizedBox(height: Gap.sm),
          if (pickedIndex == null)
            _answerLine(context, '내 답', '(미응답)', c.wrong)
          else if (!isCorrect)
            _answerLine(context, '내 답', q.options[pickedIndex!], c.wrong),
          _answerLine(context, '정답', q.options[q.correct], c.correct),
          const SizedBox(height: Gap.xs),
          Text(q.explanation,
              style: t.bodyMedium?.copyWith(color: c.text, height: 1.6)),
          if (pickedIndex != null &&
              !isCorrect &&
              q.wrongExplanations[pickedIndex!] != null) ...[
            const SizedBox(height: Gap.xs),
            Text(q.wrongExplanations[pickedIndex!]!,
                style: t.bodyMedium?.copyWith(color: c.wrong, height: 1.6)),
          ],
        ],
      ),
    );
  }

  Widget _answerLine(
      BuildContext context, String label, String text, Color color) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text.rich(TextSpan(children: [
        TextSpan(
            text: '$label  ',
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w800, color: color)),
        TextSpan(
            text: text,
            style: TextStyle(fontSize: 14, color: c.text, height: 1.5)),
      ])),
    );
  }
}
```

> 참고: `ResultCard`에 **미응답("내 답 (미응답)")** 표시를 추가했다(시험 자동제출 대비). 연습 모드는 항상 선택 후 공개라 `pickedIndex==null` 분기에 도달하지 않으므로 동작 불변.

- [ ] **Step 2: `quiz_page.dart`를 추출 위젯 사용으로 정리**

`flutter_app/lib/pages/quiz_page.dart` (전체 교체):

```dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../content/quiz_widgets.dart';
import '../data/content_index.dart';
import '../data/history_store.dart';
import '../models/attempt_record.dart';
import '../models/question.dart';
import '../theme/app_theme.dart';

/// 얇은 로더: 자산에서 QuestionBank를 읽어 QuizView에 주입.
class QuizPage extends StatelessWidget {
  const QuizPage({super.key, required this.entry});
  final ContentEntry entry;

  Future<QuestionBank> _load() async {
    final raw = await rootBundle.loadString(entry.questionsAsset);
    return QuestionBank.fromJson(json.decode(raw) as Map<String, dynamic>);
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
        title: Text('${entry.title} · 연습 문제',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      body: FutureBuilder<QuestionBank>(
        future: _load(),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final bank = snap.data;
          if (bank == null || bank.questions.isEmpty) {
            return Center(
                child: Text('검증된 연습 문제가 아직 없습니다.',
                    style: TextStyle(color: c.textMuted)));
          }
          final store = HistoryStore();
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: Layout.exam),
              child: QuizView(
                bank: bank,
                certId: entry.certForHistory,
                onFinished: store.add,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 모델 주입식 연습 러너(즉시 공개). 테스트 대상.
class QuizView extends StatefulWidget {
  const QuizView({
    super.key,
    required this.bank,
    required this.certId,
    this.onFinished,
  });

  final QuestionBank bank;
  final String certId;
  final void Function(AttemptRecord)? onFinished;

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  int _index = 0;
  final _picked = <int, int>{};
  final _revealed = <int>{};
  final _startedAt = DateTime.now();
  bool _finished = false;

  List<Question> get _qs => widget.bank.questions;

  void _finish() {
    final wrong = <String>[];
    var correct = 0;
    for (var k = 0; k < _qs.length; k++) {
      if (_picked[k] == _qs[k].correct) {
        correct++;
      } else {
        wrong.add(_qs[k].id);
      }
    }
    widget.onFinished?.call(AttemptRecord(
      certId: widget.certId,
      examId: 'practice:${widget.bank.examGuideTaskId}',
      mode: 'practice',
      date: DateTime.now().toIso8601String(),
      correct: correct,
      total: _qs.length,
      wrongQuestionIds: wrong,
      flaggedQuestionIds: const [],
      durationSpentSec: DateTime.now().difference(_startedAt).inSeconds,
    ));
    setState(() => _finished = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(Gap.xl),
        child: ResultsView(bank: widget.bank, picked: _picked),
      );
    }
    final c = context.c;
    final t = Theme.of(context).textTheme;
    final q = _qs[_index];
    final revealed = _revealed.contains(_index);
    final picked = _picked[_index];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(Gap.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('문항 ${_index + 1} / ${_qs.length}', style: t.labelSmall),
          const SizedBox(height: Gap.sm),
          Text(q.stem, style: t.titleLarge),
          const SizedBox(height: Gap.lg),
          for (var k = 0; k < q.options.length; k++)
            OptionTile(
              text: q.options[k],
              selected: picked == k,
              state: !revealed
                  ? OptState.idle
                  : k == q.correct
                      ? OptState.correct
                      : (picked == k ? OptState.wrong : OptState.idle),
              onTap: revealed ? null : () => setState(() => _picked[_index] = k),
            ),
          const SizedBox(height: Gap.lg),
          if (revealed) ...[
            ExplainBox(
                bg: c.accentWeak,
                bar: c.accent,
                label: '해설',
                text: q.explanation),
            if (picked != null &&
                picked != q.correct &&
                q.wrongExplanations[picked] != null)
              Padding(
                padding: const EdgeInsets.only(top: Gap.sm),
                child: ExplainBox(
                    bg: c.wrongWeak,
                    bar: c.wrong,
                    label: '왜 아닌가',
                    text: q.wrongExplanations[picked]!),
              ),
            const SizedBox(height: Gap.lg),
            PrimaryButton(
              label: _index < _qs.length - 1 ? '다음' : '결과 보기',
              onTap: () {
                if (_index < _qs.length - 1) {
                  setState(() => _index++);
                } else {
                  _finish();
                }
              },
            ),
          ] else
            PrimaryButton(
              label: '확인',
              onTap: picked == null
                  ? null
                  : () => setState(() => _revealed.add(_index)),
            ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: 회귀 테스트(연습 흐름 green)**

Run (in `flutter_app/`): `flutter test test/quiz_view_test.dart`
Expected: PASS — 기존 테스트가 `find.text('EC2')`/`'확인'`/`'결과 보기'`로 동작 검증. (위젯 이름은 비공개였으므로 테스트는 텍스트로 찾음 → 무수정 통과.)

- [ ] **Step 4: 전체 분석/테스트**

Run (in `flutter_app/`): `flutter analyze && flutter test`
Expected: `No issues found!` + All tests passed.

- [ ] **Step 5: Commit**

```bash
git -C D:/workspace/awc-docs/aws-docs add flutter_app/lib/content/quiz_widgets.dart flutter_app/lib/pages/quiz_page.dart
git -C D:/workspace/awc-docs/aws-docs commit -m "refactor: 퀴즈 공유 위젯을 quiz_widgets.dart로 추출(연습·시험 공유)" -m "Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 3: 시험 세션 모델 + 헬퍼 (`exam_session.dart`) — TDD

**Files:**
- Create: `flutter_app/lib/models/exam_session.dart`
- Test: `flutter_app/test/exam_session_test.dart`

- [ ] **Step 1: 실패하는 테스트 작성**

`flutter_app/test/exam_session_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/models/exam_session.dart';
import 'package:aws_docs/models/question.dart';

QuestionBank _bank(List<String> ids) => QuestionBank(
      examGuideTaskId: 'clf-t2-3',
      taskTitle: '접근 관리',
      certCode: 'CLF-C02',
      domain: 2,
      questions: [
        for (final id in ids)
          Question(
            id: id,
            examGuideTaskId: 'clf-t2-3',
            stem: 's',
            options: const ['a', 'b'],
            correct: 0,
            explanation: 'e',
            wrongExplanations: const {},
            sources: const [],
            verified: true,
          ),
      ],
    );

void main() {
  test('ExamSession JSON 왕복(picked 문자열키 복원)', () {
    const s = ExamSession(
      examId: 'exam:clf-t2-3',
      certId: 'CLF-C02',
      taskId: 'clf-t2-3',
      startedAtIso: '2026-06-06T00:00:00.000',
      durationSec: 581,
      index: 2,
      picked: {0: 1, 2: 3},
      flagged: [2, 4],
      bankFingerprint: '7:a,b',
      submitted: false,
    );
    final back = ExamSession.fromJson(s.toJson());
    expect(back.index, 2);
    expect(back.picked, {0: 1, 2: 3});
    expect(back.flagged, [2, 4]);
    expect(back.durationSec, 581);
    expect(back.submitted, isFalse);
  });

  test('bankFingerprint는 문항 변경 시 달라진다', () {
    expect(bankFingerprint(_bank(['a', 'b', 'c'])),
        bankFingerprint(_bank(['a', 'b', 'c'])));
    expect(bankFingerprint(_bank(['a', 'b', 'c'])),
        isNot(bankFingerprint(_bank(['a', 'b'])))); // 문항 수 변경
    expect(bankFingerprint(_bank(['a', 'b', 'c'])),
        isNot(bankFingerprint(_bank(['a', 'b', 'x'])))); // ID 변경
  });

  test('examDurationSec: CLF 90분/65문항 페이스 비례', () {
    // 90*60/65 ≈ 83.08s/문항 → 7문항 ≈ 581s
    expect(examDurationSec(durationMinutes: 90, scored: 50, unscored: 15, count: 7),
        581);
    // 메타 null → 폴백 84s/문항
    expect(examDurationSec(durationMinutes: null, scored: null, unscored: null, count: 5),
        420);
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `flutter test test/exam_session_test.dart`
Expected: FAIL — `'ExamSession' isn't defined`.

- [ ] **Step 3: 모델 구현**

`flutter_app/lib/models/exam_session.dart`:

```dart
import 'question.dart';

/// 진행 중 시험 세션(localStorage 복원 대상). 스펙 §4.
class ExamSession {
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
    required this.submitted,
  });

  final String examId; // 'exam:<taskId>'
  final String certId;
  final String taskId;
  final String startedAtIso; // ISO-8601 시작 벽시계 기준점
  final int durationSec;
  final int index;
  final Map<int, int> picked; // 문항 → 선택 보기
  final List<int> flagged;
  final String bankFingerprint;
  final bool submitted;

  Map<String, dynamic> toJson() => {
        'examId': examId,
        'certId': certId,
        'taskId': taskId,
        'startedAtIso': startedAtIso,
        'durationSec': durationSec,
        'index': index,
        'picked': picked.map((k, v) => MapEntry(k.toString(), v)),
        'flagged': flagged,
        'bankFingerprint': bankFingerprint,
        'submitted': submitted,
      };

  factory ExamSession.fromJson(Map<String, dynamic> j) {
    final picked = <int, int>{};
    final rawP = j['picked'];
    if (rawP is Map) {
      rawP.forEach((k, v) {
        final ki = int.tryParse(k.toString());
        final vi = (v as num?)?.toInt();
        if (ki != null && vi != null) picked[ki] = vi;
      });
    }
    return ExamSession(
      examId: (j['examId'] ?? '').toString(),
      certId: (j['certId'] ?? '').toString(),
      taskId: (j['taskId'] ?? '').toString(),
      startedAtIso: (j['startedAtIso'] ?? '').toString(),
      durationSec: (j['durationSec'] as num?)?.toInt() ?? 0,
      index: (j['index'] as num?)?.toInt() ?? 0,
      picked: picked,
      flagged: ((j['flagged'] as List?) ?? const [])
          .map((e) => (e as num).toInt())
          .toList(),
      bankFingerprint: (j['bankFingerprint'] ?? '').toString(),
      submitted: j['submitted'] == true,
    );
  }
}

/// 문제은행 지문(문항 수 + ID 목록) — 콘텐츠 개정 감지용.
String bankFingerprint(QuestionBank bank) =>
    '${bank.questions.length}:${bank.questions.map((q) => q.id).join(',')}';

/// 실전 비례 페이스. 공식 메타 누락 시 폴백 84s/문항.
int examDurationSec({
  required int? durationMinutes,
  required int? scored,
  required int? unscored,
  required int count,
}) {
  final total = (scored ?? 50) + (unscored ?? 15);
  final perQ = total > 0 ? (durationMinutes ?? 90) * 60 / total : 84.0;
  return (perQ * count).round();
}
```

- [ ] **Step 4: 테스트 통과 확인**

Run: `flutter test test/exam_session_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 5: Commit**

```bash
git -C D:/workspace/awc-docs/aws-docs add flutter_app/lib/models/exam_session.dart flutter_app/test/exam_session_test.dart
git -C D:/workspace/awc-docs/aws-docs commit -m "feat: ExamSession 모델 + fingerprint/타이머 페이스 헬퍼 + 테스트" -m "Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 4: 시험 세션 저장소 (`exam_session_store.dart`) — TDD

**Files:**
- Create: `flutter_app/lib/data/exam_session_store.dart`
- Test: `flutter_app/test/exam_session_test.dart` (append)

- [ ] **Step 1: 실패하는 테스트 추가**

`flutter_app/test/exam_session_test.dart`의 `import` 아래에 추가:

```dart
import 'package:aws_docs/data/exam_session_store.dart';
import 'package:aws_docs/data/local_kv.dart';
```

`main()` 안 끝에 추가:

```dart
  ExamSession _session({bool submitted = false}) => ExamSession(
        examId: 'exam:clf-t2-3',
        certId: 'CLF-C02',
        taskId: 'clf-t2-3',
        startedAtIso: '2026-06-06T00:00:00.000',
        durationSec: 581,
        index: 1,
        picked: const {0: 1},
        flagged: const [1],
        bankFingerprint: '7:a',
        submitted: submitted,
      );

  test('ExamSessionStore save→load 동일, clear 후 null', () {
    final store = ExamSessionStore(backend: MemoryBackend());
    expect(store.load('exam:clf-t2-3'), isNull);
    store.save(_session());
    final loaded = store.load('exam:clf-t2-3');
    expect(loaded, isNotNull);
    expect(loaded!.index, 1);
    expect(loaded.picked, {0: 1});
    store.clear('exam:clf-t2-3');
    expect(store.load('exam:clf-t2-3'), isNull);
  });

  test('손상 데이터는 null로 무시', () {
    final b = MemoryBackend()
      ..write('awsdocs.examSession.v1:exam:clf-t2-3', '{not json');
    expect(ExamSessionStore(backend: b).load('exam:clf-t2-3'), isNull);
  });
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `flutter test test/exam_session_test.dart`
Expected: FAIL — `'ExamSessionStore' isn't defined`.

- [ ] **Step 3: 저장소 구현**

`flutter_app/lib/data/exam_session_store.dart`:

```dart
import 'dart:convert';

import '../models/exam_session.dart';
import 'local_kv.dart';

/// 활성 시험 세션 1건을 examId별 키로 영속화(스펙 §7).
class ExamSessionStore {
  ExamSessionStore({KvBackend? backend}) : _b = backend ?? defaultBackend();

  final KvBackend _b;
  static String _key(String examId) => 'awsdocs.examSession.v1:$examId';

  ExamSession? load(String examId) {
    final raw = _b.read(_key(examId));
    if (raw == null || raw.isEmpty) return null;
    try {
      return ExamSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null; // 손상 데이터 무시
    }
  }

  void save(ExamSession s) => _b.write(_key(s.examId), jsonEncode(s.toJson()));

  void clear(String examId) => _b.write(_key(examId), '');
}
```

- [ ] **Step 4: 테스트 통과 확인**

Run: `flutter test test/exam_session_test.dart`
Expected: PASS (5 tests).

- [ ] **Step 5: Commit**

```bash
git -C D:/workspace/awc-docs/aws-docs add flutter_app/lib/data/exam_session_store.dart flutter_app/test/exam_session_test.dart
git -C D:/workspace/awc-docs/aws-docs commit -m "feat: ExamSessionStore(localStorage 시험 세션) + 테스트" -m "Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 5: 시험 러너 `ExamView` (`exam_page.dart`) — TDD

타이머·자유 네비·플래그·자동제출·제출 가드. 주입 클록으로 시간을 구동해 테스트 결정성을 확보한다.

**Files:**
- Create: `flutter_app/lib/pages/exam_page.dart` (이 Task는 `ExamView`만; `ExamPage`는 Task 6)
- Test: `flutter_app/test/exam_view_test.dart`

- [ ] **Step 1: 실패하는 위젯 테스트 작성**

`flutter_app/test/exam_view_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/models/attempt_record.dart';
import 'package:aws_docs/models/exam_session.dart';
import 'package:aws_docs/models/question.dart';
import 'package:aws_docs/pages/exam_page.dart';
import 'package:aws_docs/theme/app_theme.dart';

QuestionBank _bank() => const QuestionBank(
      examGuideTaskId: 'clf-t2-3',
      taskTitle: '접근 관리',
      certCode: 'CLF-C02',
      domain: 2,
      questions: [
        Question(
            id: 'q1',
            examGuideTaskId: 'clf-t2-3',
            stem: '루트 전용 작업은?',
            options: ['EC2 시작', '계정 해지'],
            correct: 1,
            explanation: '계정 해지는 루트 전용.',
            wrongExplanations: {0: 'EC2는 일상 작업.'},
            sources: [],
            verified: true),
        Question(
            id: 'q2',
            examGuideTaskId: 'clf-t2-3',
            stem: '최소 권한은?',
            options: ['필요한 권한만', '관리자 먼저'],
            correct: 0,
            explanation: '필요한 권한만 부여.',
            wrongExplanations: {1: '과도한 권한.'},
            sources: [],
            verified: true),
      ],
    );

Widget _host(Widget child) =>
    MaterialApp(theme: AppTheme.light, home: Scaffold(body: child));

void main() {
  testWidgets('정답 선택 후 제출 → 채점, flagged 기록', (tester) async {
    AttemptRecord? finished;
    final started = DateTime(2026, 6, 6, 0, 0, 0);
    await tester.pumpWidget(_host(ExamView(
      bank: _bank(),
      certId: 'CLF-C02',
      taskId: 'clf-t2-3',
      startedAt: started,
      durationSec: 600,
      now: () => started.add(const Duration(seconds: 30)),
      onFinished: (r) => finished = r,
    )));

    // q1 정답 선택
    await tester.tap(find.text('계정 해지'));
    await tester.pumpAndSettle();
    // q1 플래그
    await tester.tap(find.byIcon(Icons.flag_outlined));
    await tester.pumpAndSettle();
    // 다음 → q2
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    // q2 정답
    await tester.tap(find.text('필요한 권한만'));
    await tester.pumpAndSettle();
    // 제출(플래그 1개 경고 → 확인)
    await tester.tap(find.text('제출'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('제출하기')); // 다이얼로그 확인
    await tester.pumpAndSettle();

    expect(finished, isNotNull);
    expect(finished!.mode, 'exam');
    expect(finished!.correct, 2);
    expect(finished!.wrongQuestionIds, isEmpty);
    expect(finished!.flaggedQuestionIds, ['q1']);
  });

  testWidgets('시간 소진 시 자동 제출 — 미응답=오답, 1회만', (tester) async {
    var calls = 0;
    final started = DateTime(2026, 6, 6, 0, 0, 0);
    var clock = started; // 시작 시점
    await tester.pumpWidget(_host(ExamView(
      bank: _bank(),
      certId: 'CLF-C02',
      taskId: 'clf-t2-3',
      startedAt: started,
      durationSec: 5,
      now: () => clock,
      onFinished: (_) => calls++,
    )));

    // 시간 경과(만료) 후 1초 틱 발생
    clock = started.add(const Duration(seconds: 10));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(calls, 1); // 가드: 자동 제출 1회
    expect(find.text('결과'), findsOneWidget); // 결과 화면 진입
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `flutter test test/exam_view_test.dart`
Expected: FAIL — `'ExamView' isn't defined`.

- [ ] **Step 3: `ExamView` 구현**

`flutter_app/lib/pages/exam_page.dart` (이 Task에서 생성; Task 6에서 `ExamPage` 추가):

```dart
import 'dart:async';

import 'package:flutter/material.dart';

import '../content/quiz_widgets.dart';
import '../models/attempt_record.dart';
import '../models/exam_session.dart';
import '../models/question.dart';
import '../theme/app_theme.dart';

/// 모델 주입식 시험 러너(테스트 대상). 자산/localStorage 의존 없음.
class ExamView extends StatefulWidget {
  const ExamView({
    super.key,
    required this.bank,
    required this.certId,
    required this.taskId,
    required this.startedAt,
    required this.durationSec,
    this.initialIndex = 0,
    this.initialPicked = const {},
    this.initialFlagged = const {},
    this.restored = false,
    this.passingHintPct = 70,
    this.onChanged,
    this.onFinished,
    this.onExit,
    this.now,
  });

  final QuestionBank bank;
  final String certId;
  final String taskId;
  final DateTime startedAt;
  final int durationSec;
  final int initialIndex;
  final Map<int, int> initialPicked;
  final Set<int> initialFlagged;
  final bool restored;
  final int passingHintPct;
  final void Function(ExamSession)? onChanged;
  final void Function(AttemptRecord)? onFinished;
  final VoidCallback? onExit;
  final DateTime Function()? now;

  @override
  State<ExamView> createState() => _ExamViewState();
}

class _ExamViewState extends State<ExamView> {
  late int _index = widget.initialIndex;
  late final Map<int, int> _picked = {...widget.initialPicked};
  late final Set<int> _flagged = {...widget.initialFlagged};
  bool _submitted = false;
  Timer? _ticker;

  List<Question> get _qs => widget.bank.questions;
  DateTime _clock() => (widget.now ?? DateTime.now)();

  int get _remainingSec {
    final elapsed = _clock().difference(widget.startedAt).inSeconds;
    final left = widget.durationSec - elapsed;
    return left < 0 ? 0 : left;
  }

  @override
  void initState() {
    super.initState();
    // 복원 시 이미 만료면 즉시 자동 제출(시간 벌기 차단).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_remainingSec <= 0) {
        _submit(auto: true);
      } else {
        _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
          if (!mounted) return;
          if (_remainingSec <= 0) {
            _submit(auto: true);
          } else {
            setState(() {});
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

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
        submitted: _submitted,
      );

  void _persist() => widget.onChanged?.call(_session());

  void _pick(int opt) {
    setState(() => _picked[_index] = opt);
    _persist();
  }

  void _toggleFlag() {
    setState(() {
      if (_flagged.contains(_index)) {
        _flagged.remove(_index);
      } else {
        _flagged.add(_index);
      }
    });
    _persist();
  }

  void _go(int i) {
    if (i < 0 || i >= _qs.length) return;
    setState(() => _index = i);
    _persist();
  }

  void _submit({required bool auto}) {
    if (_submitted) return; // 가드: 자동·수동 경합 1회만
    _submitted = true;
    _ticker?.cancel();
    final wrong = <String>[];
    var correct = 0;
    for (var k = 0; k < _qs.length; k++) {
      if (_picked[k] == _qs[k].correct) {
        correct++;
      } else {
        wrong.add(_qs[k].id); // 미응답 포함 = 오답
      }
    }
    final spent = _clock().difference(widget.startedAt).inSeconds;
    widget.onFinished?.call(AttemptRecord(
      certId: widget.certId,
      examId: 'exam:${widget.taskId}',
      mode: 'exam',
      date: _clock().toIso8601String(),
      correct: correct,
      total: _qs.length,
      wrongQuestionIds: wrong,
      flaggedQuestionIds: _flagged.toList()..sort(),
      durationSpentSec: spent > widget.durationSec ? widget.durationSec : spent,
    ));
    setState(() {});
  }

  Future<void> _onSubmitPressed() async {
    if (_flagged.isEmpty) {
      _submit(auto: false);
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('제출할까요?'),
        content: Text('플래그한 문항 ${_flagged.length}개가 남아 있습니다. 그래도 제출할까요?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('계속 풀기')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('제출하기')),
        ],
      ),
    );
    if (ok == true) _submit(auto: false);
  }

  String _mmss(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) return _results(context);
    final c = context.c;
    final t = Theme.of(context).textTheme;
    final q = _qs[_index];
    final remaining = _remainingSec;
    final low = remaining <= (widget.durationSec * 0.1).ceil();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(Gap.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 카운트다운 + 복원 노트
          Row(
            children: [
              Icon(Icons.timer_outlined,
                  size: 18, color: low ? c.warning : c.textMuted),
              const SizedBox(width: Gap.xs),
              Text(_mmss(remaining),
                  style: TextStyle(
                      fontFamily: AppTheme.monoFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: low ? c.warning : c.text)),
              const Spacer(),
              Text('${_index + 1} / ${_qs.length}', style: t.labelSmall),
            ],
          ),
          if (widget.restored)
            Padding(
              padding: const EdgeInsets.only(top: Gap.xs),
              child: Text('이전 진행을 복원했습니다.',
                  style: t.labelSmall?.copyWith(color: c.textMuted)),
            ),
          const SizedBox(height: Gap.md),
          // 문항 그리드(번호 칩)
          Wrap(
            spacing: Gap.xs,
            runSpacing: Gap.xs,
            children: [
              for (var k = 0; k < _qs.length; k++)
                _GridChip(
                  label: '${k + 1}',
                  answered: _picked.containsKey(k),
                  flagged: _flagged.contains(k),
                  current: k == _index,
                  onTap: () => _go(k),
                ),
            ],
          ),
          const SizedBox(height: Gap.lg),
          Text(q.stem, style: t.titleLarge),
          const SizedBox(height: Gap.lg),
          for (var k = 0; k < q.options.length; k++)
            OptionTile(
              text: q.options[k],
              selected: _picked[_index] == k,
              state: OptState.idle, // 시험: 제출 전 정답 비공개
              onTap: () => _pick(k),
            ),
          const SizedBox(height: Gap.lg),
          // 푸터: 이전 / 플래그 / 다음·제출
          Row(
            children: [
              if (_index > 0)
                _SecondaryButton(
                    icon: Icons.chevron_left,
                    label: '이전',
                    onTap: () => _go(_index - 1)),
              const SizedBox(width: Gap.sm),
              _SecondaryButton(
                icon: _flagged.contains(_index)
                    ? Icons.flag
                    : Icons.flag_outlined,
                label: _flagged.contains(_index) ? '플래그 해제' : '플래그',
                active: _flagged.contains(_index),
                onTap: _toggleFlag,
              ),
              const Spacer(),
              SizedBox(
                width: 130,
                child: PrimaryButton(
                  label: _index < _qs.length - 1 ? '다음' : '제출',
                  onTap: _index < _qs.length - 1
                      ? () => _go(_index + 1)
                      : _onSubmitPressed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _results(BuildContext context) {
    final c = context.c;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Gap.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResultsView(
            bank: widget.bank,
            picked: _picked,
            flagged: _flagged,
            subtitle: '실전 합격 기준 ≈ ${widget.passingHintPct}% · 플래그 ${_flagged.length}개',
          ),
          const SizedBox(height: Gap.lg),
          if (widget.onExit != null)
            SizedBox(
              width: 180,
              child: PrimaryButton(label: '학습문서로', onTap: widget.onExit),
            ),
        ],
      ),
    );
  }
}

class _GridChip extends StatelessWidget {
  const _GridChip({
    required this.label,
    required this.answered,
    required this.flagged,
    required this.current,
    required this.onTap,
  });
  final String label;
  final bool answered;
  final bool flagged;
  final bool current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Radii.sm),
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: answered ? c.accentWeak : c.surface,
          borderRadius: BorderRadius.circular(Radii.sm),
          border: Border.all(
            color: current ? c.accent : (flagged ? c.warning : c.border),
            width: current ? 2 : 1,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Text(label,
                style: TextStyle(
                    fontFamily: AppTheme.monoFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: answered ? c.accentStrong : c.textMuted)),
            if (flagged)
              Positioned(
                top: -2,
                right: -2,
                child: Icon(Icons.flag, size: 11, color: c.warning),
              ),
          ],
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Radii.sm),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: Gap.md),
        decoration: BoxDecoration(
          color: active ? c.warningWeak : c.surface,
          borderRadius: BorderRadius.circular(Radii.sm),
          border: Border.all(color: active ? c.warning : c.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: active ? c.warning : c.textMuted),
            const SizedBox(width: Gap.xs),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: active ? c.warning : c.textMuted)),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: 테스트 통과 확인**

Run: `flutter test test/exam_view_test.dart`
Expected: PASS (2 tests). 자동제출 테스트가 실패하면 pump 시간(`tester.pump(Duration(seconds:1))`)을 조정한다(틱 1회 발생 보장).

- [ ] **Step 5: 분석 + 전체 테스트**

Run: `flutter analyze && flutter test`
Expected: `No issues found!` + All tests passed.

- [ ] **Step 6: Commit**

```bash
git -C D:/workspace/awc-docs/aws-docs add flutter_app/lib/pages/exam_page.dart flutter_app/test/exam_view_test.dart
git -C D:/workspace/awc-docs/aws-docs commit -m "feat: ExamView 시험 러너(타이머·플래그·자동제출·가드) + 테스트" -m "Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 6: 시험 로더 `ExamPage` (`exam_page.dart`) — 배선

자산(문제은행 + 공식 시험 메타)을 읽고, 기존 세션을 복원하거나 새로 시작해 `ExamView`에 주입한다.

**Files:**
- Modify: `flutter_app/lib/pages/exam_page.dart` (파일 끝에 `ExamPage` 추가, import 보강)

- [ ] **Step 1: import 보강**

`exam_page.dart` 상단 import 블록에 추가:

```dart
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../data/content_index.dart';
import '../data/exam_session_store.dart';
import '../data/history_store.dart';
import '../models/exam_guide.dart';
```

- [ ] **Step 2: `ExamPage` 추가**

`exam_page.dart` 파일 끝에 추가:

```dart
/// 얇은 로더: 문제은행 + 공식 시험 메타를 읽고 세션을 복원해 ExamView에 주입.
class ExamPage extends StatefulWidget {
  const ExamPage({super.key, required this.entry});
  final ContentEntry entry;

  @override
  State<ExamPage> createState() => _ExamPageState();
}

class _ExamPageState extends State<ExamPage> {
  late final Future<_ExamLoad> _future = _load();
  final _store = ExamSessionStore();
  final _history = HistoryStore();

  Future<_ExamLoad> _load() async {
    final qRaw = await rootBundle.loadString(widget.entry.questionsAsset);
    final bank =
        QuestionBank.fromJson(json.decode(qRaw) as Map<String, dynamic>);

    ExamOverview? overview;
    try {
      final gRaw = await rootBundle
          .loadString('assets/exam_guides/${widget.entry.certCode}.json');
      overview =
          ExamGuide.fromJson(json.decode(gRaw) as Map<String, dynamic>).overview;
    } catch (_) {
      overview = null; // 메타 없으면 폴백 페이스(examDurationSec)
    }

    final examId = 'exam:${widget.entry.taskId}';
    final fp = bankFingerprint(bank);
    final existing = _store.load(examId);
    final restorable = existing != null &&
        !existing.submitted &&
        existing.bankFingerprint == fp;

    final DateTime startedAt;
    final int durationSec;
    final int initialIndex;
    final Map<int, int> initialPicked;
    final Set<int> initialFlagged;
    if (restorable) {
      startedAt =
          DateTime.tryParse(existing.startedAtIso) ?? DateTime.now();
      durationSec = existing.durationSec;
      initialIndex = existing.index;
      initialPicked = existing.picked;
      initialFlagged = existing.flagged.toSet();
    } else {
      if (existing != null) _store.clear(examId); // 개정/제출된 세션 폐기
      startedAt = DateTime.now();
      durationSec = examDurationSec(
        durationMinutes: overview?.durationMinutes,
        scored: overview?.scoredQuestions,
        unscored: overview?.unscoredQuestions,
        count: bank.questions.length,
      );
      initialIndex = 0;
      initialPicked = const {};
      initialFlagged = const {};
    }

    return _ExamLoad(
      bank: bank,
      startedAt: startedAt,
      durationSec: durationSec,
      initialIndex: initialIndex,
      initialPicked: initialPicked,
      initialFlagged: initialFlagged,
      restored: restorable,
    );
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
        title: Text('${widget.entry.title} · 시험 모드',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      body: FutureBuilder<_ExamLoad>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snap.data;
          if (data == null || data.bank.questions.isEmpty) {
            return Center(
                child: Text('검증된 문항이 아직 없습니다.',
                    style: TextStyle(color: c.textMuted)));
          }
          final examId = 'exam:${widget.entry.taskId}';
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: Layout.exam),
              child: ExamView(
                bank: data.bank,
                certId: widget.entry.certForHistory,
                taskId: widget.entry.taskId,
                startedAt: data.startedAt,
                durationSec: data.durationSec,
                initialIndex: data.initialIndex,
                initialPicked: data.initialPicked,
                initialFlagged: data.initialFlagged,
                restored: data.restored,
                onChanged: _store.save,
                onFinished: (r) {
                  _history.add(r);
                  _store.clear(examId);
                },
                onExit: () => Navigator.of(context).maybePop(),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ExamLoad {
  const _ExamLoad({
    required this.bank,
    required this.startedAt,
    required this.durationSec,
    required this.initialIndex,
    required this.initialPicked,
    required this.initialFlagged,
    required this.restored,
  });
  final QuestionBank bank;
  final DateTime startedAt;
  final int durationSec;
  final int initialIndex;
  final Map<int, int> initialPicked;
  final Set<int> initialFlagged;
  final bool restored;
}
```

- [ ] **Step 3: 분석 + 전체 테스트**

Run (in `flutter_app/`): `flutter analyze && flutter test`
Expected: `No issues found!` + All tests passed (배선만 추가, 기존 테스트 불변).

- [ ] **Step 4: Commit**

```bash
git -C D:/workspace/awc-docs/aws-docs add flutter_app/lib/pages/exam_page.dart
git -C D:/workspace/awc-docs/aws-docs commit -m "feat: ExamPage 로더(시험 메타 로드 + 세션 복원 배선)" -m "Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 7: 진입 동선 — "시험처럼 풀기" CTA (`study_doc_page.dart`)

**Files:**
- Modify: `flutter_app/lib/pages/study_doc_page.dart`

- [ ] **Step 1: import 추가**

`study_doc_page.dart` 상단 import 블록에 추가(기존 `import 'quiz_page.dart';` 아래):

```dart
import 'exam_page.dart';
import '../models/exam_session.dart';
```

- [ ] **Step 2: 단일 CTA → 두 CTA(연습 + 시험)로 교체**

`_StartQuizButton` 클래스 전체(현재 `lib/pages/study_doc_page.dart:145-171`)를 아래로 교체:

```dart
class _StartQuizButton extends StatelessWidget {
  const _StartQuizButton({required this.entry});
  final ContentEntry entry;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    if (entry.questionCount <= 0) return const SizedBox.shrink();
    // 시험 시간(라벨용 추정): 공식 페이스로 계산(메타 없으면 폴백).
    final mins =
        (examDurationSec(
                    durationMinutes: 90,
                    scored: 50,
                    unscored: 15,
                    count: entry.questionCount) /
                60)
            .round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _cta(
          context,
          label: '연습 문제 풀기 (${entry.questionCount}문항)',
          filled: true,
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => QuizPage(entry: entry))),
        ),
        const SizedBox(height: Gap.sm),
        _cta(
          context,
          label: '시험처럼 풀기 (${entry.questionCount}문항 · ~$mins분)',
          filled: false,
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => ExamPage(entry: entry))),
        ),
      ],
    );
  }

  Widget _cta(BuildContext context,
      {required String label,
      required bool filled,
      required VoidCallback onTap}) {
    final c = context.c;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Radii.sm),
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? c.accent : c.surface,
          borderRadius: BorderRadius.circular(Radii.sm),
          border: filled ? null : Border.all(color: c.accent, width: 1.5),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: filled ? c.onAccent : c.accent)),
      ),
    );
  }
}
```

> 참고: 라벨용 `mins`는 공식 CLF 페이스 상수로 추정한다(정확한 시간은 `ExamPage`가 실제 메타로 계산). 라벨과 실제가 미세하게 다를 수 있어 "~"를 붙인다.

- [ ] **Step 3: 분석 + 전체 테스트 + 웹 빌드**

Run (in `flutter_app/`):
```
flutter analyze
flutter test
flutter build web --release --base-href /aws-docs/
```
Expected: `No issues found!` · All tests passed · `✓ Built build/web`.

- [ ] **Step 4: Commit**

```bash
git -C D:/workspace/awc-docs/aws-docs add flutter_app/lib/pages/study_doc_page.dart
git -C D:/workspace/awc-docs/aws-docs commit -m "feat: 학습문서에 '시험처럼 풀기' CTA 추가(시험 모드 진입)" -m "Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 8: 최종 검증 + 수동 스모크 + 정리

**Files:** (없음 — 검증 전용)

- [ ] **Step 1: 전체 게이트**

Run (in `flutter_app/`):
```
flutter analyze
flutter test
flutter build web --release --base-href /aws-docs/
```
Expected: 0 issue · 모든 테스트 통과(연습 회귀 + 시험 신규) · 빌드 성공.

- [ ] **Step 2: 수동 스모크(웹) — 권장**

Run (in `flutter_app/`): `flutter run -d chrome`
체크: CLF-C02 상세 → 학습 콘텐츠 → 학습문서 하단 "시험처럼 풀기" → 타이머 카운트다운 동작 / 보기 선택해도 정답 비공개 / 플래그 토글·그리드 점프 / 새로고침 후 응답·플래그·남은시간 복원 / 제출 시 채점·복기·플래그 배지 / (durationSec를 잠시 작게 바꿔) 자동제출 미응답=오답 확인.

- [ ] **Step 3: 이력 문서 갱신**

`docs/plans/2026-06-06-session-handoff.md`의 "다음 행동"에서 2순위(하위 프로젝트 #2)를 완료로 갱신하고, `clf-learning-loop.md`의 E3/E4 진척을 기록(완료 표기). (구체 문구는 실행 시점 상태로 작성.)

- [ ] **Step 4: 최종 Commit + 푸시 전 확인**

```bash
git -C D:/workspace/awc-docs/aws-docs add docs/plans/2026-06-06-session-handoff.md docs/designs/clf-learning-loop.md
git -C D:/workspace/awc-docs/aws-docs commit -m "docs: 하위 프로젝트 #2(시험 모드) 완료 이력 갱신" -m "Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

- [ ] **Step 5: 머지/PR (사용자 승인 후)**

`feat/clf-learning-loop-subproject-2` → `main` 머지 또는 PR. **푸시는 main 자동 배포를 유발하므로 사용자 승인 후 실행.** (옵션) `gh pr create`로 PR 생성.

---

## Self-Review (작성자 점검)

**1. Spec 커버리지:**
- 시험 러너/자유 네비/제출후채점 → Task 5(ExamView). ✅
- E3 타이머(비례 페이스·벽시계·dispose cancel) → Task 3(`examDurationSec`) + Task 5(`_remainingSec`/`_ticker`). ✅
- E3 자동제출(미응답=오답·가드) → Task 5(`_submit`). ✅
- E3 세션 복원(저장·복원·만료즉시제출·fingerprint·멀티탭 last-write-wins) → Task 4(store) + Task 6(복원 배선) + Task 5(`initState` 만료 제출). ✅
- E4 플래그(토글·그리드·제출 경고·이력 기록) → Task 5. ✅
- 진입 CTA → Task 7. ✅
- 리팩터(quiz_widgets/local_kv) → Task 2/Task 1. ✅
- 테스트(주입 클록·회귀 유지) → Task 1/2 회귀 + Task 3/4/5 신규. ✅

**2. 플레이스홀더 스캔:** 코드 단계 전부 실제 코드. Task 8 Step 3 이력 문구만 "실행 시점 작성"(문서 텍스트라 허용). ✅

**3. 타입 일관성:** `KvBackend`(Task1)↔`HistoryStore`/`ExamSessionStore`(Task1/4 주입) · `bankFingerprint`/`examDurationSec`(Task3 정의 → Task5/6 사용) · `ExamSession` 필드(Task3 정의 → Task4/5/6 사용) · `OptionTile`/`OptState`/`ResultsView`(Task2 정의 → Task5 사용) 모두 일치. ✅

> ⚠️ 실행 주의: `exam_view_test.dart`의 자동제출 테스트는 `Timer.periodic` + `tester.pump(Duration)` 상호작용에 민감하다. 틱이 안 fire 하면 `pump`를 2회(예: `pump(1s)` 두 번) 호출하거나 `pumpAndSettle` 전에 `pump(Duration(seconds:1))`로 틱을 명시 유도한다. 만료 즉시제출(`initState` postFrame)은 `pumpWidget` 직후 `pumpAndSettle`로 검증.
