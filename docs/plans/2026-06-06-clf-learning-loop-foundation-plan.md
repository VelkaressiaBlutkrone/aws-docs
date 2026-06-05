# CLF 학습 루프 #1 (기반) 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** CLF 상세 페이지에서 `공동 책임 모델`(clf-t2-1) 학습문서를 DESIGN.md대로 읽고 → 연습 문제 5개를 풀고 → 점수·오답해설을 보고 → 결과가 localStorage 이력에 남는, 18 Task로 복제 가능한 기반을 만든다.

**Architecture:** 자산(Markdown + JSON)을 모델로 파싱(`markdown_parser`, `QuestionBank.fromJson`)하고, 모델 주입식 view 위젯(`StudyMarkdownView`, `QuizView`)으로 렌더하며, 얇은 로더 페이지(`StudyDocPage`, `QuizPage`)가 `rootBundle`로 자산을 읽어 view에 넘긴다. 응시 결과는 `HistoryStore`(D14 스키마)로 localStorage에 저장. 진입은 기존 `CertDetailPage`에 섹션 추가.

**Tech Stack:** Flutter Web 3.38.9 / Dart 3.10.8 · 기존 테마 토큰(`context.c`/`Gap`/`Radii`/`Layout`) · `package:web`(localStorage) · 외부 Markdown/스토리지 패키지 미사용.

**Spec:** `docs/designs/2026-06-06-clf-learning-loop-foundation-spec.md` (승인 완료).

> ⚠️ **구현 후 정정(2026-06-06, 이 계획은 구현·병합 완료):** 아래 Task 코드 두 곳이 실제 구현에서 수정됨 — **코드와 git 이력이 진실 공급원**.
> - **Task 5 `history_store.dart`:** 단일 `import 'package:web/web.dart'`는 VM 테스트 컴파일을 깨뜨려 **조건부 import**로 분리했다(`web_backend_stub.dart` / `web_backend_web.dart` 2파일 추가, `if (dart.library.js_interop)` 분기). `kIsWeb ? WebBackend() : MemoryBackend()` 선택 로직은 유지.
> - **Task 7 `_Results`:** 최종 리뷰(스펙 §9.3) 반영해 **문항별 복기 카드 `_ResultCard`**(stem + 내 답 + 정답 + 해설/오답해설 재표시)로 강화.
> 둘 다 일회성 인프라 — 새 콘텐츠 Task 복제 경로(`t2-X.md` + `t2-X.questions.json` + content_index 한 줄)와 무관.

---

## 작업 디렉터리 / 사전 규칙

- **git repo 루트:** `D:\workspace\awc-docs\aws-docs` (`.git` 위치). git 명령은 여기서 실행.
- **Flutter 패키지 루트:** `D:\workspace\awc-docs\aws-docs\flutter_app`. `flutter` 명령은 여기서 실행.
- 현재 브랜치 `main`(푸시 시 CI 자동 배포). **실행 전 피처 브랜치를 딴다:**
  ```bash
  cd D:/workspace/awc-docs/aws-docs
  git switch -c feat/clf-learning-loop-foundation
  ```
- 커밋 메시지 끝에 다음 트레일러를 붙인다(레포 규칙):
  ```
  Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
  ```
- 색·간격은 **항상 `context.c`/`Gap`/`Radii`/`Layout` 토큰**만(하드코딩 금지, DESIGN.md).

## 파일 구조 (생성/수정)

| 파일 | 책임 |
|---|---|
| `lib/models/study_content.dart` | 학습문서 모델(메타 + `MdBlock` 계층 + `MdSpan`/`StudySource`) |
| `lib/models/question.dart` | `Question`/`QuestionBank` + `fromJson`(verified 게이트) |
| `lib/models/attempt_record.dart` | `AttemptRecord`(D14 이력 스키마) + JSON |
| `lib/content/markdown_parser.dart` | 우리 Markdown 하위집합 → `StudyContent` |
| `lib/content/study_markdown_view.dart` | `List<MdBlock>` → 위젯(섹션 인식 스타일) |
| `lib/data/content_index.dart` | (자격증 → 콘텐츠 항목) 정적 인덱스 |
| `lib/data/history_store.dart` | localStorage 영속화(백엔드 주입식) |
| `lib/pages/study_doc_page.dart` | 학습문서 로더 페이지(검수 메타 헤더 + view + CTA) |
| `lib/pages/quiz_page.dart` | `QuizView`(러너) + `QuizPage`(로더) |
| `lib/pages/cert_detail_page.dart` | **수정**: "학습 콘텐츠" 섹션 추가 |
| `test/markdown_parser_test.dart` | 파서 단위 테스트(실제 t2-1.md) |
| `test/question_model_test.dart` | 문항 모델 테스트(실제 t2-1.questions.json) |
| `test/history_store_test.dart` | 이력 직렬화/누적 테스트 |
| `test/study_markdown_view_test.dart` | 렌더 스모크 |
| `test/quiz_view_test.dart` | 퀴즈 흐름/채점 테스트 |

---

## Task 1: `package:web` 의존성 추가

**Files:**
- Modify: `flutter_app/pubspec.yaml` (dependencies 섹션)

- [ ] **Step 1: pubspec에 web 의존성 추가**

`flutter_app/pubspec.yaml`의 `dependencies:` 아래 `cupertino_icons` 다음에 추가:

```yaml
  cupertino_icons: ^1.0.8
  web: ^1.1.0
```

- [ ] **Step 2: 의존성 해결**

Run (in `flutter_app/`): `flutter pub get`
Expected: `Got dependencies!` (오프라인이면 캐시로 해결; 실패 시 `web`은 Flutter SDK의 전이 의존성이라 버전을 `flutter pub deps | findstr web`로 확인해 맞춘다.)

- [ ] **Step 3: Commit**

```bash
cd D:/workspace/awc-docs/aws-docs
git add flutter_app/pubspec.yaml flutter_app/pubspec.lock
git commit -m "build: add package:web for localStorage 이력 저장"
```

---

## Task 2: 학습문서 모델 (`study_content.dart`)

순수 데이터 모델. 로직이 없어 단위 테스트는 Task 3(파서)에서 함께 검증한다.

**Files:**
- Create: `flutter_app/lib/models/study_content.dart`

- [ ] **Step 1: 모델 작성**

```dart
/// 학습문서 콘텐츠 모델 — 프런트매터 메타 + 본문 블록.
/// 출처: docs/designs/2026-06-06-clf-learning-loop-foundation-spec.md §4.1
library;

class StudySource {
  const StudySource({required this.title, required this.url});
  final String title;
  final String url;

  factory StudySource.fromJson(Map<String, dynamic> j) => StudySource(
        title: (j['title'] ?? '').toString(),
        url: (j['url'] ?? '').toString(),
      );
}

/// 인라인 조각: 평문/굵게/코드/URL.
class MdSpan {
  const MdSpan(this.text, {this.bold = false, this.code = false, this.url});
  final String text;
  final bool bold;
  final bool code;
  final String? url;
}

/// 블록 단위 콘텐츠(렌더러가 sealed switch로 분기).
sealed class MdBlock {
  const MdBlock();
}

class MdHeading extends MdBlock {
  const MdHeading(this.level, this.text);
  final int level; // 1..3
  final String text;
}

class MdParagraph extends MdBlock {
  const MdParagraph(this.spans);
  final List<MdSpan> spans;
}

class MdBullets extends MdBlock {
  const MdBullets(this.items);
  final List<List<MdSpan>> items;
}

class MdNumbered extends MdBlock {
  const MdNumbered(this.items);
  final List<List<MdSpan>> items;
}

class MdChecklistItem {
  const MdChecklistItem({required this.checked, required this.spans});
  final bool checked;
  final List<MdSpan> spans;
}

class MdChecklist extends MdBlock {
  const MdChecklist(this.items);
  final List<MdChecklistItem> items;
}

class MdTable extends MdBlock {
  const MdTable(this.headers, this.rows);
  final List<String> headers;
  final List<List<String>> rows;
}

class MdQuote extends MdBlock {
  const MdQuote(this.spans);
  final List<MdSpan> spans;
}

class MdCode extends MdBlock {
  const MdCode(this.text);
  final String text;
}

class MdDetails extends MdBlock {
  const MdDetails(this.summary, this.body);
  final String summary;
  final List<MdBlock> body;
}

class MdDivider extends MdBlock {
  const MdDivider();
}

class StudyContent {
  const StudyContent({
    required this.examGuideTaskId,
    required this.certCode,
    required this.title,
    required this.domain,
    required this.coversTasks,
    required this.sources,
    required this.blocks,
    this.domainName,
    this.domainWeightPct,
    this.lastVerified,
  });

  final String examGuideTaskId;
  final String certCode;
  final String title;
  final int domain;
  final String? domainName;
  final int? domainWeightPct;
  final String? lastVerified;
  final List<String> coversTasks;
  final List<StudySource> sources;
  final List<MdBlock> blocks;
}
```

- [ ] **Step 2: 컴파일 확인**

Run (in `flutter_app/`): `flutter analyze lib/models/study_content.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
cd D:/workspace/awc-docs/aws-docs
git add flutter_app/lib/models/study_content.dart
git commit -m "feat: 학습문서 콘텐츠 모델(MdBlock 계층) 추가"
```

---

## Task 3: Markdown 파서 (`markdown_parser.dart`) — TDD

**Files:**
- Create: `flutter_app/lib/content/markdown_parser.dart`
- Test: `flutter_app/test/markdown_parser_test.dart`

- [ ] **Step 1: 실패하는 테스트 작성 (실제 t2-1.md 파싱)**

`flutter_app/test/markdown_parser_test.dart`:

```dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/content/markdown_parser.dart';
import 'package:aws_docs/models/study_content.dart';

void main() {
  // 테스트 cwd = 패키지 루트(flutter_app/)이므로 상대경로로 자산을 읽는다.
  final raw = File('assets/content/clf/t2-1.md').readAsStringSync();

  test('프런트매터를 파싱한다', () {
    final doc = parseStudyDoc(raw);
    expect(doc.examGuideTaskId, 'clf-t2-1');
    expect(doc.certCode, 'CLF-C02');
    expect(doc.domain, 2);
    expect(doc.title, contains('공동 책임 모델'));
    expect(doc.sources.length, greaterThanOrEqualTo(5));
    expect(doc.sources.first.url, startsWith('https://'));
  });

  test('섹션 헤딩과 자가점검 토글, 표를 파싱한다', () {
    final doc = parseStudyDoc(raw);
    final headings =
        doc.blocks.whereType<MdHeading>().map((h) => h.text).toList();
    expect(headings.any((h) => h.startsWith('🎯')), isTrue);
    expect(headings.any((h) => h.startsWith('⚠️')), isTrue);
    expect(headings.any((h) => h.startsWith('🧪')), isTrue);

    final details = doc.blocks.whereType<MdDetails>().toList();
    expect(details.length, greaterThanOrEqualTo(4));
    expect(details.first.summary, isNotEmpty);

    expect(doc.blocks.whereType<MdTable>().isNotEmpty, isTrue);
  });

  test('알 수 없는 줄도 크래시 없이 문단으로 degrade 한다', () {
    final doc = parseStudyDoc('---\ntitle: X\n---\n\n@@이상한 줄@@');
    expect(doc.blocks.whereType<MdParagraph>().isNotEmpty, isTrue);
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

Run (in `flutter_app/`): `flutter test test/markdown_parser_test.dart`
Expected: FAIL — `Error: ... 'parseStudyDoc' isn't defined`.

- [ ] **Step 3: 파서 구현**

`flutter_app/lib/content/markdown_parser.dart`:

```dart
import '../models/study_content.dart';

/// 우리 학습문서 Markdown 하위집합 파서(스펙 §5). 인식 못 한 줄은
/// 문단으로 degrade — 절대 throw 하지 않는다.
StudyContent parseStudyDoc(String raw) {
  final lines = raw.replaceAll('\r\n', '\n').split('\n');
  var i = 0;

  final fm = <String, String>{};
  final coversTasks = <String>[];
  final sources = <StudySource>[];

  if (i < lines.length && lines[i].trim() == '---') {
    i++;
    while (i < lines.length && lines[i].trim() != '---') {
      final m = RegExp(r'^([A-Za-z][A-Za-z0-9]*):\s*(.*)$').firstMatch(lines[i]);
      if (m == null) {
        i++;
        continue;
      }
      final key = m.group(1)!;
      final val = m.group(2)!.trim();
      if (val.isEmpty && key == 'coversTasks') {
        i++;
        while (i < lines.length && lines[i].trimLeft().startsWith('- ')) {
          coversTasks
              .add(lines[i].trimLeft().substring(2).trim().replaceAll('"', ''));
          i++;
        }
        continue;
      }
      if (val.isEmpty && key == 'sources') {
        i++;
        while (i < lines.length && lines[i].trimLeft().startsWith('- ')) {
          final titleLine = lines[i].trimLeft().substring(2);
          final tm = RegExp(r'^title:\s*(.*)$').firstMatch(titleLine);
          final title = tm != null ? tm.group(1)!.trim() : '';
          var url = '';
          if (i + 1 < lines.length) {
            final um = RegExp(r'^\s*url:\s*(.*)$').firstMatch(lines[i + 1]);
            if (um != null) {
              url = um.group(1)!.trim();
              i++;
            }
          }
          sources.add(StudySource(title: title, url: url));
          i++;
        }
        continue;
      }
      fm[key] = val;
      i++;
    }
    if (i < lines.length) i++; // 닫는 ---
  }

  final blocks = _parseBlocks(lines, i, lines.length);

  return StudyContent(
    examGuideTaskId: fm['examGuideTaskId'] ?? '',
    certCode: fm['certCode'] ?? '',
    title: fm['title'] ?? '',
    domain: int.tryParse(fm['domain'] ?? '') ?? 0,
    domainName: fm['domainName'],
    domainWeightPct: int.tryParse(fm['domainWeightPct'] ?? ''),
    lastVerified: fm['lastVerified'],
    coversTasks: coversTasks,
    sources: sources,
    blocks: blocks,
  );
}

List<MdBlock> _parseBlocks(List<String> lines, int start, int end) {
  final blocks = <MdBlock>[];
  var i = start;
  while (i < end) {
    final line = lines[i];
    final s = line.trim();

    if (s.isEmpty) {
      i++;
      continue;
    }
    if (s == '---') {
      blocks.add(const MdDivider());
      i++;
      continue;
    }

    final h = RegExp(r'^(#{1,3})\s+(.*)$').firstMatch(s);
    if (h != null) {
      blocks.add(MdHeading(h.group(1)!.length, h.group(2)!.trim()));
      i++;
      continue;
    }

    if (s.startsWith('```')) {
      final buf = <String>[];
      i++;
      while (i < end && !lines[i].trim().startsWith('```')) {
        buf.add(lines[i]);
        i++;
      }
      if (i < end) i++;
      blocks.add(MdCode(buf.join('\n')));
      continue;
    }

    if (s.startsWith('<details>')) {
      var summary = '';
      final sm = RegExp(r'<summary>(.*?)</summary>').firstMatch(line);
      if (sm != null) summary = sm.group(1)!.trim();
      i++;
      final inner = <String>[];
      while (i < end && !lines[i].trim().startsWith('</details>')) {
        if (summary.isEmpty) {
          final sm2 = RegExp(r'<summary>(.*?)</summary>').firstMatch(lines[i]);
          if (sm2 != null) {
            summary = sm2.group(1)!.trim();
            i++;
            continue;
          }
        }
        inner.add(lines[i]);
        i++;
      }
      if (i < end) i++;
      blocks.add(MdDetails(summary, _parseBlocks(inner, 0, inner.length)));
      continue;
    }

    if (s.startsWith('|')) {
      final tbl = <String>[];
      while (i < end && lines[i].trim().startsWith('|')) {
        tbl.add(lines[i].trim());
        i++;
      }
      if (tbl.length >= 2) {
        List<String> cells(String r) =>
            r.split('|').map((c) => c.trim()).where((c) => c.isNotEmpty).toList();
        final headers = cells(tbl[0]);
        final rows = <List<String>>[];
        for (var r = 2; r < tbl.length; r++) {
          rows.add(cells(tbl[r]));
        }
        blocks.add(MdTable(headers, rows));
      }
      continue;
    }

    if (s.startsWith('>')) {
      final buf = <String>[];
      while (i < end && lines[i].trim().startsWith('>')) {
        buf.add(lines[i].trim().replaceFirst(RegExp(r'^>\s?'), ''));
        i++;
      }
      blocks.add(MdQuote(_inline(buf.join(' '))));
      continue;
    }

    if (RegExp(r'^- \[[ xX]\]\s').hasMatch(s)) {
      final items = <MdChecklistItem>[];
      while (i < end && RegExp(r'^- \[[ xX]\]\s').hasMatch(lines[i].trim())) {
        final t = lines[i].trim();
        final checked = t.startsWith('- [x]') || t.startsWith('- [X]');
        items.add(MdChecklistItem(
            checked: checked, spans: _inline(t.substring(5).trim())));
        i++;
      }
      blocks.add(MdChecklist(items));
      continue;
    }

    if (s.startsWith('- ')) {
      final items = <List<MdSpan>>[];
      while (i < end &&
          lines[i].trim().startsWith('- ') &&
          !RegExp(r'^- \[[ xX]\]').hasMatch(lines[i].trim())) {
        items.add(_inline(lines[i].trim().substring(2).trim()));
        i++;
      }
      blocks.add(MdBullets(items));
      continue;
    }

    if (RegExp(r'^\d+\.\s').hasMatch(s)) {
      final items = <List<MdSpan>>[];
      while (i < end && RegExp(r'^\d+\.\s').hasMatch(lines[i].trim())) {
        items.add(_inline(lines[i].trim().replaceFirst(RegExp(r'^\d+\.\s'), '')));
        i++;
      }
      blocks.add(MdNumbered(items));
      continue;
    }

    // 문단: 다음 빈 줄/특수 블록 전까지 합침
    final buf = <String>[];
    while (i < end) {
      final l = lines[i].trim();
      if (l.isEmpty ||
          l == '---' ||
          l.startsWith('#') ||
          l.startsWith('```') ||
          l.startsWith('|') ||
          l.startsWith('>') ||
          l.startsWith('- ') ||
          l.startsWith('<details>') ||
          RegExp(r'^\d+\.\s').hasMatch(l)) {
        break;
      }
      buf.add(l);
      i++;
    }
    if (buf.isNotEmpty) blocks.add(MdParagraph(_inline(buf.join(' '))));
  }
  return blocks;
}

final _inlineRe =
    RegExp(r'(\*\*([^*]+)\*\*)|(`([^`]+)`)|((?:https?:\/\/)[^\s)]+)');

List<MdSpan> _inline(String text) {
  final spans = <MdSpan>[];
  var last = 0;
  for (final m in _inlineRe.allMatches(text)) {
    if (m.start > last) spans.add(MdSpan(text.substring(last, m.start)));
    if (m.group(1) != null) {
      spans.add(MdSpan(m.group(2)!, bold: true));
    } else if (m.group(3) != null) {
      spans.add(MdSpan(m.group(4)!, code: true));
    } else {
      final url = m.group(5)!;
      spans.add(MdSpan(url, url: url));
    }
    last = m.end;
  }
  if (last < text.length) spans.add(MdSpan(text.substring(last)));
  if (spans.isEmpty) spans.add(MdSpan(text));
  return spans;
}
```

- [ ] **Step 4: 테스트 통과 확인**

Run (in `flutter_app/`): `flutter test test/markdown_parser_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 5: Commit**

```bash
cd D:/workspace/awc-docs/aws-docs
git add flutter_app/lib/content/markdown_parser.dart flutter_app/test/markdown_parser_test.dart
git commit -m "feat: 학습문서 Markdown 하위집합 파서 + 테스트"
```

---

## Task 4: 문항 모델 (`question.dart`) — TDD

**Files:**
- Create: `flutter_app/lib/models/question.dart`
- Test: `flutter_app/test/question_model_test.dart`

- [ ] **Step 1: 실패하는 테스트 작성**

`flutter_app/test/question_model_test.dart`:

```dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/models/question.dart';

void main() {
  final raw = File('assets/content/clf/t2-1.questions.json').readAsStringSync();
  final map = json.decode(raw) as Map<String, dynamic>;

  test('QuestionBank를 파싱하고 검증 문항만 남긴다', () {
    final bank = QuestionBank.fromJson(map);
    expect(bank.examGuideTaskId, 'clf-t2-1');
    expect(bank.questions.length, 5);
    for (final q in bank.questions) {
      expect(q.verified, isTrue);
      expect(q.correct, inInclusiveRange(0, q.options.length - 1));
      expect(q.options.length, 4);
      expect(q.sources, isNotEmpty);
      // 오답해설 키는 정답이 아닌 인덱스여야 한다
      for (final k in q.wrongExplanations.keys) {
        expect(k, isNot(q.correct));
        expect(k, inInclusiveRange(0, q.options.length - 1));
      }
    }
  });

  test('verified=false 문항은 제외된다(런타임 게이트)', () {
    final m = {
      'examGuideTaskId': 't',
      'questions': [
        {'id': 'a', 'options': ['x', 'y'], 'correct': 0, 'verified': true},
        {'id': 'b', 'options': ['x', 'y'], 'correct': 0, 'verified': false},
      ],
    };
    final bank = QuestionBank.fromJson(m);
    expect(bank.questions.map((q) => q.id), ['a']);
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `flutter test test/question_model_test.dart`
Expected: FAIL — `'QuestionBank' isn't defined`.

- [ ] **Step 3: 모델 구현**

`flutter_app/lib/models/question.dart`:

```dart
import 'study_content.dart' show StudySource;

class Question {
  const Question({
    required this.id,
    required this.examGuideTaskId,
    required this.stem,
    required this.options,
    required this.correct,
    required this.explanation,
    required this.wrongExplanations,
    required this.sources,
    required this.verified,
    this.skill = '',
    this.difficulty = '',
  });

  final String id;
  final String examGuideTaskId;
  final String skill;
  final String difficulty;
  final String stem;
  final List<String> options;
  final int correct; // 0-base
  final String explanation;
  final Map<int, String> wrongExplanations;
  final List<StudySource> sources;
  final bool verified;

  factory Question.fromJson(Map<String, dynamic> j) {
    final we = <int, String>{};
    final rawWe = j['wrongExplanations'];
    if (rawWe is Map) {
      rawWe.forEach((k, v) {
        final ki = int.tryParse(k.toString());
        if (ki != null) we[ki] = v.toString();
      });
    }
    return Question(
      id: (j['id'] ?? '').toString(),
      examGuideTaskId: (j['examGuideTaskId'] ?? '').toString(),
      skill: (j['skill'] ?? '').toString(),
      difficulty: (j['difficulty'] ?? '').toString(),
      stem: (j['stem'] ?? '').toString(),
      options: ((j['options'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      correct: (j['correct'] as num?)?.toInt() ?? -1,
      explanation: (j['explanation'] ?? '').toString(),
      wrongExplanations: we,
      sources: ((j['sources'] as List?) ?? const [])
          .map((e) => StudySource.fromJson(e as Map<String, dynamic>))
          .toList(),
      verified: j['verified'] == true,
    );
  }
}

class QuestionBank {
  const QuestionBank({
    required this.examGuideTaskId,
    required this.taskTitle,
    required this.certCode,
    required this.domain,
    required this.questions,
  });

  final String examGuideTaskId;
  final String taskTitle;
  final String certCode;
  final int domain;
  final List<Question> questions;

  factory QuestionBank.fromJson(Map<String, dynamic> j) => QuestionBank(
        examGuideTaskId: (j['examGuideTaskId'] ?? '').toString(),
        taskTitle: (j['taskTitle'] ?? '').toString(),
        certCode: (j['certCode'] ?? '').toString(),
        domain: (j['domain'] as num?)?.toInt() ?? 0,
        questions: ((j['questions'] as List?) ?? const [])
            .map((e) => Question.fromJson(e as Map<String, dynamic>))
            .where((q) => q.verified) // verified 게이트: 비검증 비노출
            .toList(),
      );
}
```

- [ ] **Step 4: 테스트 통과 확인**

Run: `flutter test test/question_model_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
cd D:/workspace/awc-docs/aws-docs
git add flutter_app/lib/models/question.dart flutter_app/test/question_model_test.dart
git commit -m "feat: 문항 모델 + verified 런타임 게이트 + 테스트"
```

---

## Task 5: 이력 스키마 + 저장소 (`attempt_record.dart`, `history_store.dart`) — TDD

**Files:**
- Create: `flutter_app/lib/models/attempt_record.dart`
- Create: `flutter_app/lib/data/history_store.dart`
- Test: `flutter_app/test/history_store_test.dart`

- [ ] **Step 1: 실패하는 테스트 작성**

`flutter_app/test/history_store_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/models/attempt_record.dart';
import 'package:aws_docs/data/history_store.dart';

void main() {
  test('AttemptRecord JSON 왕복', () {
    const r = AttemptRecord(
      certId: 'CLF-C02',
      examId: 'practice:clf-t2-1',
      mode: 'practice',
      date: '2026-06-06T00:00:00.000',
      correct: 4,
      total: 5,
      wrongQuestionIds: ['clf-t2-1-q3'],
      flaggedQuestionIds: [],
      durationSpentSec: 120,
    );
    final back = AttemptRecord.fromJson(r.toJson());
    expect(back.correct, 4);
    expect(back.wrongQuestionIds, ['clf-t2-1-q3']);
    expect(back.mode, 'practice');
  });

  test('HistoryStore는 누적 저장하고 손상 데이터는 무시한다', () {
    final store = HistoryStore(backend: MemoryBackend());
    expect(store.all(), isEmpty);
    store.add(const AttemptRecord(
      certId: 'CLF-C02', examId: 'practice:clf-t2-1', mode: 'practice',
      date: '2026-06-06T00:00:00.000', correct: 5, total: 5,
      wrongQuestionIds: [], flaggedQuestionIds: [], durationSpentSec: 90,
    ));
    store.add(const AttemptRecord(
      certId: 'CLF-C02', examId: 'practice:clf-t2-1', mode: 'practice',
      date: '2026-06-06T00:01:00.000', correct: 3, total: 5,
      wrongQuestionIds: ['x'], flaggedQuestionIds: [], durationSpentSec: 80,
    ));
    expect(store.all().length, 2);

    final corrupt = MemoryBackend()..write('awsdocs.history.v1', '{not json');
    expect(HistoryStore(backend: corrupt).all(), isEmpty);
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `flutter test test/history_store_test.dart`
Expected: FAIL — `'AttemptRecord' isn't defined`.

- [ ] **Step 3: AttemptRecord 구현**

`flutter_app/lib/models/attempt_record.dart`:

```dart
/// 응시 이력 레코드 — 설계 D14 스키마(+ mode 확장).
class AttemptRecord {
  const AttemptRecord({
    required this.certId,
    required this.examId,
    required this.mode,
    required this.date,
    required this.correct,
    required this.total,
    required this.wrongQuestionIds,
    required this.flaggedQuestionIds,
    required this.durationSpentSec,
  });

  final String certId;
  final String examId; // 연습: 'practice:<taskId>'
  final String mode; // 'practice' | 'exam'
  final String date; // ISO-8601
  final int correct;
  final int total;
  final List<String> wrongQuestionIds;
  final List<String> flaggedQuestionIds;
  final int durationSpentSec;

  Map<String, dynamic> toJson() => {
        'certId': certId,
        'examId': examId,
        'mode': mode,
        'date': date,
        'correct': correct,
        'total': total,
        'wrongQuestionIds': wrongQuestionIds,
        'flaggedQuestionIds': flaggedQuestionIds,
        'durationSpentSec': durationSpentSec,
      };

  factory AttemptRecord.fromJson(Map<String, dynamic> j) => AttemptRecord(
        certId: (j['certId'] ?? '').toString(),
        examId: (j['examId'] ?? '').toString(),
        mode: (j['mode'] ?? 'practice').toString(),
        date: (j['date'] ?? '').toString(),
        correct: (j['correct'] as num?)?.toInt() ?? 0,
        total: (j['total'] as num?)?.toInt() ?? 0,
        wrongQuestionIds: ((j['wrongQuestionIds'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
        flaggedQuestionIds: ((j['flaggedQuestionIds'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
        durationSpentSec: (j['durationSpentSec'] as num?)?.toInt() ?? 0,
      );
}
```

- [ ] **Step 4: HistoryStore 구현**

`flutter_app/lib/data/history_store.dart`:

```dart
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:web/web.dart' as web;

import '../models/attempt_record.dart';

/// 키-값 백엔드(테스트는 MemoryBackend 주입).
abstract interface class HistoryBackend {
  String? read(String key);
  void write(String key, String value);
}

class MemoryBackend implements HistoryBackend {
  final _m = <String, String>{};
  @override
  String? read(String key) => _m[key];
  @override
  void write(String key, String value) => _m[key] = value;
}

/// 웹 localStorage 백엔드(브라우저에서만 인스턴스화됨).
class WebBackend implements HistoryBackend {
  @override
  String? read(String key) => web.window.localStorage.getItem(key);
  @override
  void write(String key, String value) =>
      web.window.localStorage.setItem(key, value);
}

class HistoryStore {
  HistoryStore({HistoryBackend? backend})
      : _b = backend ?? (kIsWeb ? WebBackend() : MemoryBackend());

  final HistoryBackend _b;
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

- [ ] **Step 5: 테스트 통과 확인**

Run: `flutter test test/history_store_test.dart`
Expected: PASS (2 tests). (MemoryBackend 주입이라 비웹 VM에서도 동작.)

- [ ] **Step 6: Commit**

```bash
cd D:/workspace/awc-docs/aws-docs
git add flutter_app/lib/models/attempt_record.dart flutter_app/lib/data/history_store.dart flutter_app/test/history_store_test.dart
git commit -m "feat: 응시 이력(D14) 모델 + localStorage 저장소 + 테스트"
```

---

## Task 6: 학습문서 렌더러 (`study_markdown_view.dart`) — 스모크 테스트

**Files:**
- Create: `flutter_app/lib/content/study_markdown_view.dart`
- Test: `flutter_app/test/study_markdown_view_test.dart`

- [ ] **Step 1: 실패하는 위젯 테스트 작성(모델 주입)**

`flutter_app/test/study_markdown_view_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/content/study_markdown_view.dart';
import 'package:aws_docs/models/study_content.dart';
import 'package:aws_docs/theme/app_theme.dart';

void main() {
  testWidgets('헤딩/문단/표/토글을 렌더한다', (tester) async {
    final blocks = <MdBlock>[
      const MdHeading(2, '🎯 왜 중요한가'),
      const MdParagraph([MdSpan('도메인 2는 비중이 '), MdSpan('30%', bold: true)]),
      const MdTable(['A', 'B'], [
        ['EC2', '고객'],
      ]),
      const MdDetails('정답 보기', [
        MdParagraph([MdSpan('고객.')]),
      ]),
    ];
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: StudyMarkdownView(blocks: blocks)),
    ));
    expect(find.textContaining('왜 중요한가'), findsOneWidget);
    expect(find.text('정답 보기'), findsOneWidget); // ExpansionTile 제목
    expect(find.text('EC2'), findsOneWidget); // 표 셀
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `flutter test test/study_markdown_view_test.dart`
Expected: FAIL — `'StudyMarkdownView' isn't defined`.

- [ ] **Step 3: 렌더러 구현**

`flutter_app/lib/content/study_markdown_view.dart`:

```dart
import 'package:flutter/material.dart';

import '../models/study_content.dart';
import '../theme/app_theme.dart';

enum _Kind { why, pitfalls, plain }

_Kind _kindOf(String h) {
  if (h.startsWith('🎯')) return _Kind.why;
  if (h.startsWith('⚠️')) return _Kind.pitfalls;
  return _Kind.plain;
}

/// MdBlock 목록을 DESIGN.md 토큰으로 렌더. H2 섹션 단위로 묶어
/// 🎯=액센트 콜아웃 / ⚠️=warning 블록으로 스타일링.
class StudyMarkdownView extends StatelessWidget {
  const StudyMarkdownView({super.key, required this.blocks});
  final List<MdBlock> blocks;

  @override
  Widget build(BuildContext context) {
    final sections = <({MdHeading? head, List<MdBlock> body})>[];
    MdHeading? head;
    var body = <MdBlock>[];
    void flush() => sections.add((head: head, body: body));
    for (final b in blocks) {
      if (b is MdHeading && b.level == 2) {
        flush();
        head = b;
        body = <MdBlock>[];
      } else {
        body.add(b);
      }
    }
    flush();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [for (final s in sections) _section(context, s.head, s.body)],
    );
  }

  Widget _section(BuildContext context, MdHeading? head, List<MdBlock> body) {
    final c = context.c;
    final kind = head == null ? _Kind.plain : _kindOf(head.text);
    final children = <Widget>[
      if (head != null)
        Padding(
          padding: const EdgeInsets.only(top: Gap.xl, bottom: Gap.sm),
          child: Text(head.text,
              style: Theme.of(context).textTheme.headlineSmall),
        ),
      for (final b in body) _block(context, b),
    ];
    switch (kind) {
      case _Kind.why:
        return _callout(bg: c.accentWeak, bar: c.accent, children: children);
      case _Kind.pitfalls:
        return _callout(bg: c.warningWeak, bar: c.warning, children: children);
      case _Kind.plain:
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: children);
    }
  }

  Widget _callout(
      {required Color bg, required Color bar, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: Gap.md),
      padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.xs, Gap.lg, Gap.lg),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border(left: BorderSide(color: bar, width: 3)),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _block(BuildContext context, MdBlock b) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    switch (b) {
      case MdHeading(:final level, :final text):
        return Padding(
          padding: EdgeInsets.only(top: level <= 2 ? Gap.lg : Gap.md, bottom: Gap.xs),
          child: Text(text, style: level >= 3 ? t.titleMedium : t.titleLarge),
        );
      case MdParagraph(:final spans):
        return Padding(
          padding: const EdgeInsets.only(bottom: Gap.md),
          child: _spans(context, spans, t.bodyLarge!),
        );
      case MdQuote(:final spans):
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: Gap.md),
          padding: const EdgeInsets.all(Gap.md),
          decoration: BoxDecoration(
            color: c.surface2,
            borderRadius: BorderRadius.circular(Radii.sm),
            border: Border(left: BorderSide(color: c.borderStrong, width: 3)),
          ),
          child: _spans(context, spans, t.bodyMedium!.copyWith(color: c.text)),
        );
      case MdBullets(:final items):
        return Padding(
          padding: const EdgeInsets.only(bottom: Gap.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final it in items)
                _row(
                    leading: Container(
                        margin: const EdgeInsets.only(top: 9, right: 10),
                        width: 5,
                        height: 5,
                        decoration:
                            BoxDecoration(color: c.accent, shape: BoxShape.circle)),
                    child: _spans(context, it, t.bodyLarge!)),
            ],
          ),
        );
      case MdNumbered(:final items):
        return Padding(
          padding: const EdgeInsets.only(bottom: Gap.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var k = 0; k < items.length; k++)
                _row(
                    leading: Padding(
                        padding: const EdgeInsets.only(right: 8, top: 1),
                        child: Text('${k + 1}.',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, color: c.accent))),
                    child: _spans(context, items[k], t.bodyLarge!)),
            ],
          ),
        );
      case MdChecklist(:final items):
        return Padding(
          padding: const EdgeInsets.only(bottom: Gap.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final it in items)
                _row(
                    leading: Padding(
                      padding: const EdgeInsets.only(top: 2, right: 8),
                      child: Icon(
                          it.checked
                              ? Icons.check_box_outlined
                              : Icons.check_box_outline_blank,
                          size: 18,
                          color: c.accent),
                    ),
                    child: _spans(context, it.spans, t.bodyLarge!)),
            ],
          ),
        );
      case MdTable(:final headers, :final rows):
        return _table(context, headers, rows);
      case MdCode(:final text):
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: Gap.md),
          padding: const EdgeInsets.all(Gap.md),
          decoration: BoxDecoration(
              color: c.surface2, borderRadius: BorderRadius.circular(Radii.sm)),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(text,
                style: TextStyle(
                    fontFamily: AppTheme.monoFamily,
                    fontSize: 13,
                    height: 1.7,
                    color: c.text)),
          ),
        );
      case MdDetails(:final summary, :final body):
        return Container(
          margin: const EdgeInsets.only(bottom: Gap.sm),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(Radii.sm),
            border: Border.all(color: c.border),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: Gap.md),
              childrenPadding:
                  const EdgeInsets.fromLTRB(Gap.md, 0, Gap.md, Gap.md),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              title: Text(summary, style: t.labelLarge),
              children: [for (final ib in body) _block(context, ib)],
            ),
          ),
        );
      case MdDivider():
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: Gap.sm),
          child: Divider(color: c.border, height: 1),
        );
    }
  }

  Widget _row({required Widget leading, required Widget child}) => Padding(
        padding: const EdgeInsets.only(bottom: Gap.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [leading, Expanded(child: child)],
        ),
      );

  Widget _spans(BuildContext context, List<MdSpan> spans, TextStyle base) {
    final c = context.c;
    return Text.rich(
      TextSpan(children: [
        for (final s in spans)
          TextSpan(
            text: s.text,
            style: s.code
                ? base.copyWith(
                    fontFamily: AppTheme.monoFamily,
                    fontSize: (base.fontSize ?? 15) - 1,
                    color: c.accentStrong)
                : s.bold
                    ? base.copyWith(fontWeight: FontWeight.w700, color: c.text)
                    : s.url != null
                        ? base.copyWith(color: c.accent)
                        : base,
          ),
      ]),
      style: base,
    );
  }

  Widget _table(
      BuildContext context, List<String> headers, List<List<String>> rows) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    TableRow buildRow(List<String> cells, {required bool header}) => TableRow(
          decoration: BoxDecoration(color: header ? c.surface2 : null),
          children: [
            for (var k = 0; k < headers.length; k++)
              Padding(
                padding: const EdgeInsets.all(Gap.sm),
                child: Text(k < cells.length ? cells[k] : '',
                    style: header
                        ? t.labelLarge
                        : t.bodyMedium!.copyWith(color: c.text)),
              ),
          ],
        );
    return Container(
      margin: const EdgeInsets.only(bottom: Gap.md),
      decoration: BoxDecoration(
          border: Border.all(color: c.border),
          borderRadius: BorderRadius.circular(Radii.sm)),
      child: Table(
        border: TableBorder.symmetric(inside: BorderSide(color: c.border)),
        defaultVerticalAlignment: TableCellVerticalAlignment.top,
        children: [
          buildRow(headers, header: true),
          for (final r in rows) buildRow(r, header: false),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: 테스트 통과 확인**

Run: `flutter test test/study_markdown_view_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
cd D:/workspace/awc-docs/aws-docs
git add flutter_app/lib/content/study_markdown_view.dart flutter_app/test/study_markdown_view_test.dart
git commit -m "feat: 학습문서 섹션 렌더러(DESIGN.md 토큰) + 스모크 테스트"
```

---

## Task 7: 퀴즈 러너 (`quiz_page.dart`) — TDD

**Files:**
- Create: `flutter_app/lib/pages/quiz_page.dart`
- Test: `flutter_app/test/quiz_view_test.dart`

- [ ] **Step 1: 실패하는 위젯 테스트 작성**

`flutter_app/test/quiz_view_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/models/attempt_record.dart';
import 'package:aws_docs/models/question.dart';
import 'package:aws_docs/pages/quiz_page.dart';
import 'package:aws_docs/theme/app_theme.dart';

QuestionBank _bank() => const QuestionBank(
      examGuideTaskId: 'clf-t2-1',
      taskTitle: '공동 책임 모델',
      certCode: 'CLF-C02',
      domain: 2,
      questions: [
        Question(
            id: 'q1',
            examGuideTaskId: 'clf-t2-1',
            stem: '게스트 OS 패치가 고객 책임인 서비스는?',
            options: ['RDS', 'EC2'],
            correct: 1,
            explanation: 'EC2는 IaaS.',
            wrongExplanations: {0: 'RDS는 AWS가 패치.'},
            sources: [],
            verified: true),
      ],
    );

void main() {
  testWidgets('정답 선택→확인 시 해설 공개, 결과에서 onFinished 호출', (tester) async {
    AttemptRecord? finished;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: QuizView(
            bank: _bank(),
            certId: 'CLF-C02',
            onFinished: (r) => finished = r),
      ),
    ));

    await tester.tap(find.text('EC2'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();
    expect(find.textContaining('EC2는 IaaS'), findsOneWidget);

    await tester.tap(find.text('결과 보기'));
    await tester.pumpAndSettle();
    expect(finished, isNotNull);
    expect(finished!.correct, 1);
    expect(finished!.total, 1);
    expect(finished!.wrongQuestionIds, isEmpty);
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `flutter test test/quiz_view_test.dart`
Expected: FAIL — `'QuizView' isn't defined`.

- [ ] **Step 3: QuizView + QuizPage 구현**

`flutter_app/lib/pages/quiz_page.dart`:

```dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

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

/// 모델 주입식 퀴즈 러너(테스트 대상).
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
    if (_finished) return _Results(bank: widget.bank, picked: _picked);
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
          Text('문항 ${_index + 1} / ${_qs.length}',
              style: t.labelSmall),
          const SizedBox(height: Gap.sm),
          Text(q.stem, style: t.titleLarge),
          const SizedBox(height: Gap.lg),
          for (var k = 0; k < q.options.length; k++)
            _OptionTile(
              text: q.options[k],
              selected: picked == k,
              state: !revealed
                  ? _OptState.idle
                  : k == q.correct
                      ? _OptState.correct
                      : (picked == k ? _OptState.wrong : _OptState.idle),
              onTap: revealed ? null : () => setState(() => _picked[_index] = k),
            ),
          const SizedBox(height: Gap.lg),
          if (revealed) ...[
            _Explain(
                bg: c.accentWeak,
                bar: c.accent,
                label: '해설',
                text: q.explanation),
            if (picked != null &&
                picked != q.correct &&
                q.wrongExplanations[picked] != null)
              Padding(
                padding: const EdgeInsets.only(top: Gap.sm),
                child: _Explain(
                    bg: c.wrongWeak,
                    bar: c.wrong,
                    label: '왜 아닌가',
                    text: q.wrongExplanations[picked]!),
              ),
            const SizedBox(height: Gap.lg),
            _PrimaryButton(
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
            _PrimaryButton(
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

enum _OptState { idle, correct, wrong }

class _OptionTile extends StatelessWidget {
  const _OptionTile(
      {required this.text,
      required this.selected,
      required this.state,
      required this.onTap});
  final String text;
  final bool selected;
  final _OptState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    late Color border;
    late Color bg;
    switch (state) {
      case _OptState.correct:
        border = c.correct;
        bg = c.correctWeak;
      case _OptState.wrong:
        border = c.wrong;
        bg = c.wrongWeak;
      case _OptState.idle:
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

class _Explain extends StatelessWidget {
  const _Explain(
      {required this.bg,
      required this.bar,
      required this.label,
      required this.text});
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

class _Results extends StatelessWidget {
  const _Results({required this.bank, required this.picked});
  final QuestionBank bank;
  final Map<int, int> picked;

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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Gap.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('결과', style: t.headlineSmall),
          const SizedBox(height: Gap.sm),
          Text('$correct / ${qs.length}  ·  $pct%',
              style: t.displayMedium?.copyWith(color: c.accent)),
          const SizedBox(height: Gap.xl),
          for (var k = 0; k < qs.length; k++)
            Padding(
              padding: const EdgeInsets.only(bottom: Gap.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                      picked[k] == qs[k].correct
                          ? Icons.check_circle
                          : Icons.cancel,
                      size: 18,
                      color:
                          picked[k] == qs[k].correct ? c.correct : c.wrong),
                  const SizedBox(width: Gap.sm),
                  Expanded(
                      child: Text('${k + 1}. ${qs[k].stem}',
                          style: t.bodyMedium?.copyWith(color: c.text))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});
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
```

> **메모:** import는 `content_index.dart`, `history_store.dart`, `attempt_record.dart`, `question.dart`, `theme/app_theme.dart` 다섯 개. `ContentEntry.certForHistory`는 Task 8에서 정의되므로 **Task 8을 먼저** 수행한다(권장 실행 순서 참조).

- [ ] **Step 4: 테스트 통과 확인**

Run: `flutter test test/quiz_view_test.dart`
Expected: PASS. (Task 8의 `content_index.dart`가 아직 없으면 import 에러가 나므로, 이 Task의 `quiz_page.dart`에서 `content_index`/`history_store` import와 `QuizPage` 클래스는 Task 8 완료 후 컴파일된다. 순서상 Task 8을 먼저 하거나, 본 Task에서는 `QuizView`만 단독 파일로 두고 `QuizPage`는 Task 9에서 합쳐도 된다.)

> **실행 순서 메모:** import 사이클을 피하려면 **Task 8(content_index)을 이 Task보다 먼저** 수행하라. 본 계획의 자체 검토에서 이 의존성을 반영해 아래 "권장 실행 순서"를 둔다.

- [ ] **Step 5: Commit**

```bash
cd D:/workspace/awc-docs/aws-docs
git add flutter_app/lib/pages/quiz_page.dart flutter_app/test/quiz_view_test.dart
git commit -m "feat: 퀴즈 러너(QuizView/결과/이력 기록) + 흐름 테스트"
```

---

## Task 8: 콘텐츠 인덱스 (`content_index.dart`)

**Files:**
- Create: `flutter_app/lib/data/content_index.dart`

- [ ] **Step 1: 인덱스 작성**

`flutter_app/lib/data/content_index.dart`:

```dart
/// 어떤 (자격증 → Task)에 검증 콘텐츠가 있는지 정적 인덱스.
/// 새 Task를 추가하면 여기에 한 줄 등록한다(스펙 §14 작성 컨벤션).
class ContentEntry {
  const ContentEntry({
    required this.certCode,
    required this.taskId,
    required this.title,
    required this.domain,
    required this.mdAsset,
    required this.questionsAsset,
    required this.questionCount,
  });

  final String certCode;
  final String taskId;
  final String title;
  final int domain;
  final String mdAsset;
  final String questionsAsset;
  final int questionCount;

  /// 이력 기록용 자격증 ID(현재는 certCode와 동일).
  String get certForHistory => certCode;
}

const Map<String, List<ContentEntry>> kContentIndex = {
  'CLF-C02': [
    ContentEntry(
      certCode: 'CLF-C02',
      taskId: 'clf-t2-1',
      title: '공동 책임 모델',
      domain: 2,
      mdAsset: 'assets/content/clf/t2-1.md',
      questionsAsset: 'assets/content/clf/t2-1.questions.json',
      questionCount: 5,
    ),
  ],
};

List<ContentEntry> contentFor(String certCode) =>
    kContentIndex[certCode] ?? const [];
```

- [ ] **Step 2: 컴파일 확인**

Run: `flutter analyze lib/data/content_index.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
cd D:/workspace/awc-docs/aws-docs
git add flutter_app/lib/data/content_index.dart
git commit -m "feat: 콘텐츠 정적 인덱스(CLF-C02 → clf-t2-1)"
```

---

## Task 9: 학습문서 페이지 (`study_doc_page.dart`)

**Files:**
- Create: `flutter_app/lib/pages/study_doc_page.dart`

- [ ] **Step 1: 페이지 작성**

`flutter_app/lib/pages/study_doc_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../content/markdown_parser.dart';
import '../content/study_markdown_view.dart';
import '../data/content_index.dart';
import '../models/study_content.dart';
import '../theme/app_theme.dart';
import 'quiz_page.dart';

class StudyDocPage extends StatelessWidget {
  const StudyDocPage({super.key, required this.entry});
  final ContentEntry entry;

  Future<StudyContent> _load() async {
    final raw = await rootBundle.loadString(entry.mdAsset);
    return parseStudyDoc(raw);
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
        title: Text(entry.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      body: SelectionArea(
        child: FutureBuilder<StudyContent>(
          future: _load(),
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final doc = snap.data;
            if (doc == null) {
              return Center(
                  child: Text('콘텐츠를 불러오지 못했습니다.',
                      style: TextStyle(color: c.textMuted)));
            }
            return Scrollbar(
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: Layout.measure),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                          Gap.xl, Gap.xl, Gap.xl, Gap.xl4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _DocHeader(doc: doc),
                          StudyMarkdownView(blocks: doc.blocks),
                          const SizedBox(height: Gap.xl2),
                          _StartQuizButton(entry: entry),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 검수 메타 헤더(DESIGN.md 브랜드 규칙: ✓ 검증됨 + 검수일 + 출처).
class _DocHeader extends StatelessWidget {
  const _DocHeader({required this.doc});
  final StudyContent doc;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: Gap.sm,
          runSpacing: Gap.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _badge(c.correctWeak, c.correct, '✓ 검증됨'),
            _chip(context, '도메인 ${doc.domain}'),
            for (final tk in doc.coversTasks) _chip(context, 'Task $tk'),
            if (doc.lastVerified != null)
              _chip(context, '검수 ${doc.lastVerified}'),
            _chip(context, '출처 ${doc.sources.length}'),
          ],
        ),
        const SizedBox(height: Gap.md),
        Text(doc.title, style: t.headlineMedium),
        const SizedBox(height: Gap.sm),
        Text(
          '공식 AWS 출처로 대조한 검증 학습문서 · 출처는 문서 하단(📌) 참조.',
          style: t.bodyMedium,
        ),
        const SizedBox(height: Gap.lg),
        Divider(color: c.border, height: 1),
      ],
    );
  }

  Widget _badge(Color bg, Color fg, String text) => Builder(
        builder: (_) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
              color: bg, borderRadius: BorderRadius.circular(Radii.full)),
          child: Text(text,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w800, color: fg)),
        ),
      );

  Widget _chip(BuildContext context, String text) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: BorderRadius.circular(Radii.full),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: c.textMuted)),
    );
  }
}

class _StartQuizButton extends StatelessWidget {
  const _StartQuizButton({required this.entry});
  final ContentEntry entry;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    if (entry.questionCount <= 0) return const SizedBox.shrink();
    return InkWell(
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => QuizPage(entry: entry))),
      borderRadius: BorderRadius.circular(Radii.sm),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: Gap.xl),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: c.accent,
          borderRadius: BorderRadius.circular(Radii.sm),
        ),
        child: Text('연습 문제 풀기 (${entry.questionCount}문항)',
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w700, color: c.onAccent)),
      ),
    );
  }
}
```

- [ ] **Step 2: 컴파일 확인**

Run: `flutter analyze lib/pages/study_doc_page.dart lib/pages/quiz_page.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
cd D:/workspace/awc-docs/aws-docs
git add flutter_app/lib/pages/study_doc_page.dart
git commit -m "feat: 학습문서 페이지(검수 메타 헤더 + 렌더 + 연습 CTA)"
```

---

## Task 10: 진입 동선 배선 (`cert_detail_page.dart` 수정)

**Files:**
- Modify: `flutter_app/lib/pages/cert_detail_page.dart`

- [ ] **Step 1: import 추가**

`cert_detail_page.dart` 상단 import 블록에 추가:

```dart
import '../data/content_index.dart';
import 'study_doc_page.dart';
```

- [ ] **Step 2: 본문에 학습 콘텐츠 섹션 삽입**

`build`의 `Column children`에서 요약본과 공식 가이드 사이에 한 줄 추가. 기존:

```dart
                          _Header(cert: cert, guide: guide),
                          if (summary != null) _SummaryBlock(summary: summary),
                          if (guide != null)
```

다음으로 교체:

```dart
                          _Header(cert: cert, guide: guide),
                          if (summary != null) _SummaryBlock(summary: summary),
                          if (contentFor(cert.code).isNotEmpty)
                            _LearningContent(entries: contentFor(cert.code)),
                          if (guide != null)
```

- [ ] **Step 3: 섹션 위젯 추가**

파일 하단(다른 `class _...` 위젯들과 함께)에 추가:

```dart
/// 검증된 학습 콘텐츠(학습문서 + 연습 문제) 진입 섹션.
class _LearningContent extends StatelessWidget {
  const _LearningContent({required this.entries});
  final List<ContentEntry> entries;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: Gap.xl2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.menu_book_outlined, size: 18, color: c.accent),
            const SizedBox(width: 8),
            Text('학습 콘텐츠 · 검증 문항', style: t.headlineSmall),
          ]),
          const SizedBox(height: 4),
          Text('AWS 공식 출처로 검증한 한국어 학습문서와 연습 문제.',
              style: t.bodyMedium),
          const SizedBox(height: Gap.lg),
          for (final e in entries)
            Padding(
              padding: const EdgeInsets.only(bottom: Gap.md),
              child: InkWell(
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => StudyDocPage(entry: e))),
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Task ${e.taskId.replaceAll('clf-t', '').replaceAll('-', '.')} · ${e.title}',
                                style: t.titleMedium),
                            const SizedBox(height: Gap.xs),
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
                          ],
                        ),
                      ),
                      Text('학습문서 →',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: c.accent)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: 분석 확인**

Run: `flutter analyze`
Expected: `No issues found!` (전체 lib 무경고)

- [ ] **Step 5: Commit**

```bash
cd D:/workspace/awc-docs/aws-docs
git add flutter_app/lib/pages/cert_detail_page.dart
git commit -m "feat: CLF 상세에 학습 콘텐츠 진입 섹션 배선"
```

---

## Task 11: 전체 검증 + 빌드

**Files:** 없음(검증만)

- [ ] **Step 1: 전체 정적 분석**

Run (in `flutter_app/`): `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 2: 전체 테스트**

Run: `flutter test`
Expected: All tests passed! (markdown_parser 3 · question_model 2 · history_store 2 · study_markdown_view 1 · quiz_view 1)

- [ ] **Step 3: 웹 빌드**

Run: `flutter build web --release --base-href /aws-docs/`
Expected: `✓ Built build/web` (에러 없음)

- [ ] **Step 4: 수동 확인(선택, 권장)**

Run: `flutter run -d chrome`
확인: 홈 → CLF-C02 카드 → 상세에 "학습 콘텐츠 · 검증 문항" 섹션 → 공동 책임 모델 학습문서(🎯 콜아웃·표·🧪 토글 렌더) → "연습 문제 풀기" → 5문항 풀이 → 정답/오답해설 공개 → 결과 점수. 새로고침 후 재응시 시 localStorage에 이력 누적(브라우저 DevTools → Application → Local Storage → `awsdocs.history.v1`).

- [ ] **Step 5: 최종 Commit (없으면 생략)**

```bash
cd D:/workspace/awc-docs/aws-docs
git add -A
git commit -m "test: #1 기반 전체 analyze/test/build 통과 확인" || echo "변경 없음"
```

---

## 권장 실행 순서 (의존성 반영)

`Task 1 → 2 → 3 → 4 → 5 → 8 → 6 → 7 → 9 → 10 → 11`

- **Task 8(content_index)을 Task 7(quiz_page)보다 먼저** — `QuizPage`가 `ContentEntry`를 참조하기 때문.
- Task 6(렌더러)은 Task 9(학습문서 페이지) 전에.

## Self-Review (작성자 점검 결과)

- **스펙 커버리지:** §3 파일 전부 태스크에 매핑(모델 2·3·5 / 파서 3 / 렌더러 6 / 인덱스 8 / 저장소 5 / 페이지 7·9 / 배선 10). §4 모델·§5 파서 계약·§6 렌더 매핑·§8 저장·§9 흐름·§11 테스트 모두 반영.
- **플레이스홀더:** 없음(모든 코드 완전 기재, 복붙 시 그대로 컴파일).
- **타입 일관성:** `ContentEntry.certForHistory`(Task 8 정의) ↔ Task 7 사용 일치. `QuestionBank.examGuideTaskId` ↔ QuizView `examId` 생성 일치. `MdBlock` sealed 분기 ↔ 렌더러 switch 완전 일치. `HistoryStore(backend:)` ↔ 테스트 주입 일치.
- **발견·수정:** Task 7↔8 import 의존으로 "권장 실행 순서"에서 8을 7보다 앞당김. Task 7의 불필요한 조건부 import 줄을 제거해 코드 블록을 복붙 가능한 상태로 정리.
