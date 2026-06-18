# 개념→섹션 딥링크 Phase 1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 오답 복기의 개념 큐가 학습문서 최상단이 아니라 해당 섹션으로 스크롤되게 한다(딥링크 코어).

**Architecture:** 학습문서 제목의 명시 `{#id}` 앵커를 파서가 추출(`MdHeading.anchor`). 문항에 선택적 `section` 필드. 라우트 `?at={anchor}` 쿼리로 대상 섹션을 전달, `StudyDocPage`가 `ScrollController`+`GlobalKey`로 헤더 보정 스크롤. 개념 큐 콜백이 `(taskId, section)`을 넘겨 URL을 만든다. 모든 누락은 graceful 폴백(현행 최상단).

**Tech Stack:** Flutter Web (Dart), go_router(해시 라우팅), 자체 마크다운 파서.

**Spec:** `docs/superpowers/specs/2026-06-18-concept-deeplink-design.md` (§3.1~3.6, Phase 1).

## Global Constraints

- 모든 명령은 `flutter_app/` 기준. 테스트=`cd flutter_app && flutter test`, 단일=`flutter test test/<파일>.dart`. PowerShell 사용(Git Bash 빌드 금지).
- 게이트: `flutter test` 전부 그린(기준선 499) + `flutter analyze` 신규 0건(기존 잔존 3건 외 금지).
- Test-First(CLAUDE.md 절대조건 2): 실패 테스트 선작성 → 최소 구현 → 통과 확인.
- 파서는 **절대 throw 안 함**(기존 계약). 모든 딥링크 누락은 graceful(최상단 폴백).
- 새 fontWeight엔 `fontVariations: Wght.wXXX` 병기, 새 인터랙티브는 InkWell+(Inset)FocusRing(DESIGN.md). 본 Phase는 신규 인터랙티브 위젯 없음(기존 큐 재사용).
- 브랜치 `feat/concept-deeplink`(이미 생성·스펙 커밋됨). 작업은 이 브랜치에 커밋, develop 직접 push 금지.

---

### Task 1: 마크다운 `{#id}` 앵커 파싱

**Files:**
- Modify: `flutter_app/lib/models/study_content.dart:30-34` (MdHeading에 anchor 추가)
- Modify: `flutter_app/lib/content/markdown_parser.dart:90-95` (제목 파싱 시 앵커 분리)
- Test: `flutter_app/test/markdown_parser_test.dart` (신규 또는 기존에 추가)

**Interfaces:**
- Produces: `MdHeading(int level, String text, {String? anchor})` — `anchor`는 `{#id}`의 id 또는 null. `text`는 `{#id}` 제거된 표시 문자열.

- [ ] **Step 1: 실패 테스트 작성**

`flutter_app/test/markdown_parser_test.dart`에 추가(파일 없으면 생성, 상단에 `import 'package:flutter_test/flutter_test.dart';` + `import 'package:flutter_app/content/markdown_parser.dart';` + `import 'package:flutter_app/models/study_content.dart';`):

```dart
void main() {
  group('heading anchor {#id}', () {
    MdHeading firstHeading(String md) =>
        parseStudyDoc(md).blocks.whereType<MdHeading>().first;

    test('extracts anchor and strips it from text', () {
      final h = firstHeading('## 핵심 개념 {#core-concepts}\n');
      expect(h.anchor, 'core-concepts');
      expect(h.text, '핵심 개념');
    });

    test('no anchor when absent', () {
      final h = firstHeading('## 핵심 개념\n');
      expect(h.anchor, isNull);
      expect(h.text, '핵심 개념');
    });

    test('malformed anchor stays literal', () {
      final h = firstHeading('## 핵심 {# Bad ID}\n');
      expect(h.anchor, isNull);
      expect(h.text, '핵심 {# Bad ID}');
    });

    test('anchor on H3 with emoji/parens', () {
      final h = firstHeading('### 1) 이점 (★) {#benefits}\n');
      expect(h.anchor, 'benefits');
      expect(h.text, '### 1) 이점 (★)'.replaceFirst('### ', ''));
    });
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `cd flutter_app && flutter test test/markdown_parser_test.dart`
Expected: FAIL — `MdHeading` has no `anchor` (컴파일 에러) 또는 anchor 미지원.

- [ ] **Step 3: MdHeading에 anchor 추가**

`flutter_app/lib/models/study_content.dart` 30-34행 교체:

```dart
class MdHeading extends MdBlock {
  const MdHeading(this.level, this.text, {this.anchor});
  final int level; // 1..3
  final String text;
  final String? anchor; // 제목의 {#id} (딥링크 앵커). 없으면 null.
}
```

- [ ] **Step 4: 파서에서 앵커 분리**

`flutter_app/lib/content/markdown_parser.dart` 90-95행 교체:

```dart
    final h = RegExp(r'^(#{1,3})\s+(.*)$').firstMatch(s);
    if (h != null) {
      final (text, anchor) = _splitAnchor(h.group(2)!.trim());
      blocks.add(MdHeading(h.group(1)!.length, text, anchor: anchor));
      i++;
      continue;
    }
```

같은 파일 `final _inlineRe =` 정의 바로 위(223행 부근)에 추가:

```dart
// 제목 끝의 {#id} 앵커. id는 소문자/숫자/하이픈만(케밥). 불일치는 리터럴 유지.
final _anchorRe = RegExp(r'\s*\{#([a-z0-9][a-z0-9-]*)\}$');

(String, String?) _splitAnchor(String text) {
  final m = _anchorRe.firstMatch(text);
  if (m == null) return (text, null);
  return (text.substring(0, m.start).trimRight(), m.group(1));
}
```

- [ ] **Step 5: 통과 확인 + 전체 회귀**

Run: `cd flutter_app && flutter test test/markdown_parser_test.dart && flutter test`
Expected: PASS (신규 4) + 기존 전부 그린.

- [ ] **Step 6: 커밋**

```bash
git add flutter_app/lib/models/study_content.dart flutter_app/lib/content/markdown_parser.dart flutter_app/test/markdown_parser_test.dart
git commit -m "feat(study): 학습문서 제목 {#id} 앵커 파싱 — MdHeading.anchor"
```

---

### Task 2: 문항 `section` 필드

**Files:**
- Modify: `flutter_app/lib/models/question.dart` (필드·fromJson·withOptionOrder)
- Test: `flutter_app/test/question_model_test.dart` (기존 파일에 추가)

**Interfaces:**
- Produces: `Question.section` (String, 기본 `''`) — 이 문항이 가리키는 학습문서 섹션 앵커 id. `withOptionOrder`가 보존.

- [ ] **Step 1: 실패 테스트 작성**

`flutter_app/test/question_model_test.dart`에 추가(import는 기존 것 재사용):

```dart
  group('Question.section', () {
    Question q(Map<String, dynamic> extra) => Question.fromJson({
          'id': 't1-1-q1',
          'examGuideTaskId': 'clf-t1-1',
          'stem': 's',
          'options': ['a', 'b', 'c', 'd'],
          'correct': 0,
          'explanation': 'e',
          'verified': true,
          ...extra,
        });

    test('parses section from json', () {
      expect(q({'section': 'core-concepts'}).section, 'core-concepts');
    });

    test('defaults to empty when absent', () {
      expect(q({}).section, '');
    });

    test('withOptionOrder preserves section', () {
      final shuffled = q({'section': 'benefits'}).withOptionOrder([2, 0, 3, 1]);
      expect(shuffled.section, 'benefits');
    });
  });
```

- [ ] **Step 2: 실패 확인**

Run: `cd flutter_app && flutter test test/question_model_test.dart`
Expected: FAIL — `section` getter 없음(컴파일 에러).

- [ ] **Step 3: section 필드 추가**

`flutter_app/lib/models/question.dart`:

생성자(3-16행)에 `this.section = '',` 추가(`this.skill = '',` 다음 줄):
```dart
    this.skill = '',
    this.section = '',
    this.difficulty = '',
```

필드 선언(18-28행 영역, `final String skill;` 다음)에 추가:
```dart
  final String skill;
  final String section; // 학습문서 섹션 앵커 id (딥링크). 없으면 ''.
```

`fromJson`(39-55행)에서 `skill:` 다음 줄에 추가:
```dart
      skill: (j['skill'] ?? '').toString(),
      section: (j['section'] ?? '').toString(),
```

`withOptionOrder`(68-84행)의 새 Question 생성에서 `skill: skill,` 다음 줄에 추가:
```dart
      skill: skill,
      section: section,
```

- [ ] **Step 4: 통과 확인 + 회귀**

Run: `cd flutter_app && flutter test test/question_model_test.dart && flutter test`
Expected: PASS (신규 3) + 기존 전부 그린.

- [ ] **Step 5: 커밋**

```bash
git add flutter_app/lib/models/question.dart flutter_app/test/question_model_test.dart
git commit -m "feat(quiz): 문항 section 필드(딥링크 앵커) + 셔플 운반"
```

---

### Task 3: 스크롤 오프셋 순수 함수 + 앵커 키 빌더

**Files:**
- Create: `flutter_app/lib/content/anchor_scroll.dart`
- Test: `flutter_app/test/anchor_scroll_test.dart`

**Interfaces:**
- Produces:
  - `double anchorScrollOffset({required double revealOffset, required double headerInset, required double maxScrollExtent})` — 헤더 아래로 보정한 스크롤 오프셋, `[0, maxScrollExtent]` clamp.
  - `Map<String, GlobalKey> buildAnchorKeys(List<MdBlock> blocks)` — 앵커 있는 제목마다 GlobalKey 1개. 키=anchor id.

- [ ] **Step 1: 실패 테스트 작성**

`flutter_app/test/anchor_scroll_test.dart` 생성:

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/content/anchor_scroll.dart';
import 'package:flutter_app/models/study_content.dart';

void main() {
  group('anchorScrollOffset', () {
    test('subtracts header inset', () {
      expect(
          anchorScrollOffset(
              revealOffset: 500, headerInset: 56, maxScrollExtent: 2000),
          444);
    });
    test('clamps to zero (negative)', () {
      expect(
          anchorScrollOffset(
              revealOffset: 20, headerInset: 56, maxScrollExtent: 2000),
          0);
    });
    test('clamps to max', () {
      expect(
          anchorScrollOffset(
              revealOffset: 3000, headerInset: 56, maxScrollExtent: 2000),
          2000);
    });
  });

  group('buildAnchorKeys', () {
    test('one key per anchored heading, keyed by id', () {
      final blocks = <MdBlock>[
        const MdHeading(2, '핵심', anchor: 'core'),
        const MdParagraph([MdSpan('x')]),
        const MdHeading(3, '이점', anchor: 'benefits'),
        const MdHeading(2, '함정'), // 앵커 없음 → 제외
      ];
      final keys = buildAnchorKeys(blocks);
      expect(keys.keys.toSet(), {'core', 'benefits'});
      expect(keys['core'], isA<GlobalKey>());
    });
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `cd flutter_app && flutter test test/anchor_scroll_test.dart`
Expected: FAIL — `anchor_scroll.dart` 없음.

- [ ] **Step 3: 구현**

`flutter_app/lib/content/anchor_scroll.dart` 생성:

```dart
import 'package:flutter/widgets.dart';

import '../models/study_content.dart';

/// 타깃을 글래스 헤더 아래로 보정한 스크롤 오프셋. [revealOffset]은
/// RenderAbstractViewport.getOffsetToReveal(alignment 0)의 offset(타깃을
/// 뷰포트 최상단에 올리는 값). 헤더가 가리는 만큼 위로 당기고 clamp.
double anchorScrollOffset({
  required double revealOffset,
  required double headerInset,
  required double maxScrollExtent,
}) =>
    (revealOffset - headerInset).clamp(0.0, maxScrollExtent);

/// 앵커가 붙은 제목마다 GlobalKey 1개를 만든 맵(키=anchor id). 렌더 시
/// 해당 제목 위젯에 부착해 좌표를 찾는다. 앵커 없는 제목은 제외.
Map<String, GlobalKey> buildAnchorKeys(List<MdBlock> blocks) {
  final map = <String, GlobalKey>{};
  for (final b in blocks) {
    if (b is MdHeading && b.anchor != null) {
      map[b.anchor!] = GlobalKey(debugLabel: 'anchor:${b.anchor}');
    }
  }
  return map;
}
```

- [ ] **Step 4: 통과 확인**

Run: `cd flutter_app && flutter test test/anchor_scroll_test.dart`
Expected: PASS (신규 4).

- [ ] **Step 5: 커밋**

```bash
git add flutter_app/lib/content/anchor_scroll.dart flutter_app/test/anchor_scroll_test.dart
git commit -m "feat(study): 앵커 스크롤 순수 함수 anchorScrollOffset + buildAnchorKeys"
```

---

### Task 4: 섹션 스크롤 인프라 (study_doc_page + study_markdown_view)

**Files:**
- Modify: `flutter_app/lib/content/study_markdown_view.dart` (anchorKeys 주입 + 제목에 키 부착)
- Modify: `flutter_app/lib/pages/study_doc_page.dart` (targetAnchor·ScrollController·post-frame 스크롤)

**Interfaces:**
- Consumes: `buildAnchorKeys`, `anchorScrollOffset` (Task 3); `headerScrollInset(context)` (기존 `widgets/app_header.dart`).
- Produces: `StudyDocPage({required ContentEntry entry, String? targetAnchor})`; `StudyMarkdownView({required List<MdBlock> blocks, Map<String, GlobalKey>? anchorKeys})`.

> **테스트 메모:** StudyDocPage는 SelectionArea+비동기라 위젯테스트에서 "RenderBox was not laid out" 크래시(메모리 flutter-selectionarea-widget-test-pitfall). 스크롤 동작 자동검증은 Task 3 순수 함수로 갈음하고, 이 Task는 **컴파일·analyze·기존 테스트 회귀**로 게이트하며 실제 스크롤은 Task 7 dogfood로 확인한다. 신규 위젯테스트를 작성하지 않는다.

- [ ] **Step 1: StudyMarkdownView에 anchorKeys 주입 + 제목 키 부착**

`flutter_app/lib/content/study_markdown_view.dart`:

상단 import에 추가:
```dart
import 'package:flutter/material.dart';

import '../models/study_content.dart';
import '../theme/app_theme.dart';
```
(기존 import 유지, 추가 import 불필요 — GlobalKey는 material 경유 제공)

생성자(16-18행) 교체:
```dart
class StudyMarkdownView extends StatelessWidget {
  const StudyMarkdownView({super.key, required this.blocks, this.anchorKeys});
  final List<MdBlock> blocks;
  final Map<String, GlobalKey>? anchorKeys;

  Key? _anchorKey(MdHeading? h) =>
      (h?.anchor != null) ? anchorKeys?[h!.anchor] : null;
```

`_section`의 H2 제목 Padding(48-52행)에 key 추가:
```dart
      if (head != null)
        Padding(
          key: _anchorKey(head),
          padding: const EdgeInsets.only(top: Gap.xl, bottom: Gap.sm),
          child: Text(head.text,
              style: Theme.of(context).textTheme.headlineSmall),
        ),
```

`_block`의 MdHeading 케이스(86-90행) 교체(anchor 구조분해 + key):
```dart
      case MdHeading(:final level, :final text, :final anchor):
        return Padding(
          key: anchor != null ? anchorKeys?[anchor] : null,
          padding: EdgeInsets.only(top: level <= 2 ? Gap.lg : Gap.md, bottom: Gap.xs),
          child: Text(text, style: level >= 3 ? t.titleMedium : t.titleLarge),
        );
```

- [ ] **Step 2: StudyDocPage에 targetAnchor·스크롤 추가**

`flutter_app/lib/pages/study_doc_page.dart`:

상단 import에 추가(기존 import 블록 끝):
```dart
import '../content/anchor_scroll.dart';
```

위젯 클래스(17-23행) 교체:
```dart
class StudyDocPage extends StatefulWidget {
  const StudyDocPage({super.key, required this.entry, this.targetAnchor});
  final ContentEntry entry;
  final String? targetAnchor; // ?at= 쿼리. 해당 섹션으로 스크롤. null=최상단.

  @override
  State<StudyDocPage> createState() => _StudyDocPageState();
}
```

State(25-39행) 교체 — ScrollController·앵커키·doc 메모이즈 추가:
```dart
class _StudyDocPageState extends State<StudyDocPage> {
  late Future<StudyContent> _future; // 재할당은 에러 재시도에서만
  final _scroll = ScrollController();
  Map<String, GlobalKey> _anchorKeys = const {};
  StudyContent? _keyedDoc; // 키 빌드·스크롤 1회 트리거 기준

  @override
  void initState() {
    super.initState();
    _future = _load();
    // 방문 = 열람. 부수효과만, 렌더와 분리.
    ViewedDocsStore().markViewed(widget.entry.certCode, widget.entry.taskId);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<StudyContent> _load() async {
    final raw = await rootBundle.loadString(widget.entry.mdAsset);
    return parseStudyDoc(raw);
  }

  // doc 첫 도착 시 앵커 키를 1회 만들고, 레이아웃 후 타깃으로 스크롤.
  void _onDocReady(StudyContent doc) {
    if (identical(_keyedDoc, doc)) return;
    _keyedDoc = doc;
    _anchorKeys = buildAnchorKeys(doc.blocks);
    final anchor = widget.targetAnchor;
    if (anchor == null || anchor.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToAnchor(anchor));
  }

  void _scrollToAnchor(String anchor) {
    final ctx = _anchorKeys[anchor]?.currentContext;
    if (ctx == null || !_scroll.hasClients) return;
    final box = ctx.findRenderObject();
    if (box is! RenderBox || !box.attached) return;
    final reveal = RenderAbstractViewport.of(box).getOffsetToReveal(box, 0.0);
    final target = anchorScrollOffset(
      revealOffset: reveal.offset,
      headerInset: headerScrollInset(context),
      maxScrollExtent: _scroll.position.maxScrollExtent,
    );
    if (MediaQuery.disableAnimationsOf(context)) {
      _scroll.jumpTo(target);
    } else {
      _scroll.animateTo(target,
          duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
    }
  }
```

`build`의 FutureBuilder builder에서 doc 확정 직후 `_onDocReady` 호출 — 47-51행 영역에서 `doc` 계산 다음 줄에 추가:
```dart
        final done = snap.connectionState == ConnectionState.done;
        final doc = done && !snap.hasError ? snap.data : null;
        if (doc != null) _onDocReady(doc);
```

SingleChildScrollView(78-79행)에 controller·anchorKeys 연결:
```dart
                return Scrollbar(
                  controller: _scroll,
                  child: SingleChildScrollView(
                    controller: _scroll,
                    child: Center(
```
그리고 StudyMarkdownView 호출(94행)에 anchorKeys 전달:
```dart
                              StudyMarkdownView(
                                  blocks: doc.blocks, anchorKeys: _anchorKeys),
```

- [ ] **Step 3: analyze + 전체 회귀**

Run: `cd flutter_app && flutter analyze && flutter test`
Expected: analyze 신규 0건(기존 잔존 3건만), 테스트 전부 그린(기존 + Task1~3 신규).

- [ ] **Step 4: 커밋**

```bash
git add flutter_app/lib/content/study_markdown_view.dart flutter_app/lib/pages/study_doc_page.dart
git commit -m "feat(study): 섹션 앵커 스크롤 인프라 — targetAnchor·ScrollController·헤더 보정"
```

---

### Task 5: 라우트 `?at=` 쿼리 파라미터

**Files:**
- Modify: `flutter_app/lib/app_router.dart:59-73` (study 빌더)

**Interfaces:**
- Consumes: `StudyDocPage(targetAnchor:)` (Task 4).
- Produces: URL `/cert/{code}/study/{taskId}?at={anchor}`가 targetAnchor로 주입됨.

> 테스트 메모: study 라우트 빌더는 StudyDocPage(SelectionArea+비동기)를 만들어 위젯테스트 렌더가 크래시한다(메모리). 라우팅 자동검증은 기존 라우터 테스트 범위를 깨지 않는 선(컴파일·회귀)으로 두고, `?at=` 동작은 Task 7 dogfood로 확인한다. 신규 라우터 위젯테스트 미작성.

- [ ] **Step 1: study 빌더에 at 쿼리 주입**

`flutter_app/lib/app_router.dart` 68-73행(study GoRoute의 builder) 교체:

```dart
                  builder: (context, state) => StudyDocPage(
                    entry: entryByTask(
                      state.pathParameters['code']!,
                      state.pathParameters['taskId']!,
                    )!,
                    targetAnchor: state.uri.queryParameters['at'],
                  ),
```

- [ ] **Step 2: analyze + 회귀**

Run: `cd flutter_app && flutter analyze && flutter test`
Expected: analyze 신규 0건, 테스트 전부 그린.

- [ ] **Step 3: 커밋**

```bash
git add flutter_app/lib/app_router.dart
git commit -m "feat(router): study 라우트 ?at= 앵커 쿼리 → targetAnchor 주입"
```

---

### Task 6: 개념 큐 딥링크 배선

**Files:**
- Create: `flutter_app/lib/content/study_deep_link.dart` (URL 빌더)
- Modify: `flutter_app/lib/content/quiz_widgets.dart` (ResultsView·ResultCard·_ConceptCue 콜백 시그니처)
- Modify: `flutter_app/lib/pages/exam_page.dart:45,77,646` (전달 파라미터 타입 + 호출부)
- Modify: `flutter_app/lib/pages/cert_exam_page.dart:246` (호출부)
- Test: `flutter_app/test/study_deep_link_test.dart`

**Interfaces:**
- Produces: `String studyDeepLink(String certCode, String taskId, String section)` — section 있으면 `?at=`, 없으면 쿼리 없음. 콜백 타입 `void Function(String taskId, String section)`.

- [ ] **Step 1: 실패 테스트 작성**

`flutter_app/test/study_deep_link_test.dart` 생성:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/content/study_deep_link.dart';

void main() {
  group('studyDeepLink', () {
    test('appends ?at= when section present', () {
      expect(studyDeepLink('CLF-C02', 'clf-t1-1', 'core'),
          '/cert/CLF-C02/study/clf-t1-1?at=core');
    });
    test('no query when section empty', () {
      expect(studyDeepLink('CLF-C02', 'clf-t1-1', ''),
          '/cert/CLF-C02/study/clf-t1-1');
    });
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `cd flutter_app && flutter test test/study_deep_link_test.dart`
Expected: FAIL — `study_deep_link.dart` 없음.

- [ ] **Step 3: URL 빌더 구현**

`flutter_app/lib/content/study_deep_link.dart` 생성:

```dart
/// 학습문서 딥링크 URL. [section]이 비어있지 않으면 ?at= 앵커를 붙인다.
String studyDeepLink(String certCode, String taskId, String section) {
  final base = '/cert/$certCode/study/$taskId';
  return section.isEmpty ? base : '$base?at=$section';
}
```

- [ ] **Step 4: 통과 확인**

Run: `cd flutter_app && flutter test test/study_deep_link_test.dart`
Expected: PASS (신규 2).

- [ ] **Step 5: 콜백 시그니처 확장 (quiz_widgets.dart)**

`flutter_app/lib/content/quiz_widgets.dart`:

`ResultsView.onOpenStudy`(149-150행) 교체:
```dart
  /// 오답 카드의 개념 라벨 → 해당 Task 학습문서의 섹션 이동. null이면 링크 숨김.
  final void Function(String taskId, String section)? onOpenStudy;
```

`ResultCard.onOpenStudy`(201-202행) 교체:
```dart
  /// 오답이고 개념(skill) 태그가 있을 때 학습문서 섹션으로 보내는 콜백. null이면 링크 숨김.
  final void Function(String taskId, String section)? onOpenStudy;
```

`_ConceptCue` 바인딩(260-263행) 교체 — section 전달:
```dart
            _ConceptCue(
              skill: q.skill,
              onOpenStudy: onOpenStudy == null
                  ? null
                  : () => onOpenStudy!(q.examGuideTaskId, q.section),
            ),
```
(`_ConceptCue` 자체의 `VoidCallback? onOpenStudy`는 변경 없음 — 이미 바인딩된 콜백을 받음.)

- [ ] **Step 6: exam_page.dart 전달 파라미터·호출부**

`flutter_app/lib/pages/exam_page.dart`:

위젯 파라미터(77행) 교체:
```dart
  final void Function(String taskId, String section)? onOpenStudy;
```
(45행 생성자 `this.onOpenStudy,`는 그대로, 348행 `onOpenStudy: widget.onOpenStudy,` 전달도 그대로.)

호출부(646행 부근) — 기존:
```dart
                onOpenStudy: (taskId) =>
```
를 import 추가 후 교체. 상단 import에 추가:
```dart
import '../content/study_deep_link.dart';
```
호출부 교체(실제 cert 변수명은 해당 위치 문맥의 entry/cert에 맞춤 — exam_page는 `widget.entry.certCode` 사용):
```dart
                onOpenStudy: (taskId, section) => context.push(
                    studyDeepLink(widget.entry.certCode, taskId, section)),
```

- [ ] **Step 7: cert_exam_page.dart 호출부**

`flutter_app/lib/pages/cert_exam_page.dart`:

상단 import에 추가:
```dart
import '../content/study_deep_link.dart';
```
호출부(246-247행) 교체:
```dart
          onOpenStudy: (taskId, section) => context.push(
              studyDeepLink(widget.cert.code, taskId, section)),
```

- [ ] **Step 8: analyze + 전체 회귀**

Run: `cd flutter_app && flutter analyze && flutter test`
Expected: analyze 신규 0건, 테스트 전부 그린(신규 study_deep_link 2 포함). 콜백 타입 불일치 컴파일 에러 0.

- [ ] **Step 9: 커밋**

```bash
git add flutter_app/lib/content/study_deep_link.dart flutter_app/lib/content/quiz_widgets.dart flutter_app/lib/pages/exam_page.dart flutter_app/lib/pages/cert_exam_page.dart flutter_app/test/study_deep_link_test.dart
git commit -m "feat(quiz): 개념 큐 딥링크 배선 — onOpenStudy(taskId, section) → ?at="
```

---

### Task 7: 콘텐츠 시드 + dogfood 검증

**Files:**
- Modify: `flutter_app/assets/content/clf/t1-1.md` (핵심 섹션에 `{#id}`)
- Modify: `flutter_app/assets/content/clf/t1-1.questions.json` (해당 문항 일부 `section`)

**Interfaces:**
- Consumes: 파서 앵커(Task 1), 문항 section(Task 2), 딥링크 전체 경로(Task 3~6).

> 문항 JSON은 verified 게이트가 있으므로 기존 `verified:true` 문항의 `section`만 채운다(검증 상태·questionCount 불변 — 본 Task는 문항 추가/삭제 없음).

- [ ] **Step 1: t1-1.md 핵심 섹션에 앵커 부여**

`flutter_app/assets/content/clf/t1-1.md`의 제목에 케밥 id 추가(텍스트는 그대로, 끝에 `{#id}`만). 최소 다음:
- `## 📖 핵심 개념` → `## 📖 핵심 개념 {#core-concepts}`
- `### 2) 클라우드의 핵심 이점 (★ 시험 핵심)` → `… (★ 시험 핵심) {#core-benefits}`
- `### 3) 고가용성 · 탄력성 · 민첩성 — 헷갈리지 않기` → `… 헷갈리지 않기 {#ha-elasticity}`
- `### 4) 글로벌 인프라의 이점` → `… 이점 {#global-infra}`
- `## ⚠️ 흔한 함정` → `## ⚠️ 흔한 함정 {#pitfalls}`

(정확한 현재 제목 문자열은 편집 전 해당 줄을 읽어 끝에 ` {#id}`만 덧붙인다. 다른 텍스트 변경 금지.)

- [ ] **Step 2: t1-1.questions.json에 section 채움**

`flutter_app/assets/content/clf/t1-1.questions.json`의 `verified:true` 문항 중, 개념상 대응되는 섹션이 명확한 문항에 `"section": "<id>"` 키 추가(예: "핵심 이점"·"탄력성" 계열 문항 → `core-benefits`, "고가용성/탄력성 혼동" → `ha-elasticity`, 함정형 → `pitfalls`). 최소 3~4개. 불명확하면 비워 둔다(graceful 폴백).

JSON 유효성 검증:
```bash
cd flutter_app && node -e "JSON.parse(require('fs').readFileSync('assets/content/clf/t1-1.questions.json','utf8')); console.log('valid')"
```
Expected: `valid`.

- [ ] **Step 3: 회귀(콘텐츠 변경이 테스트 깨지 않는지)**

Run: `cd flutter_app && flutter test`
Expected: 전부 그린(questionCount 하드코딩 테스트 영향 없음 — 문항 수 불변).

- [ ] **Step 4: 웹 빌드 (PowerShell)**

PowerShell에서:
```
cd D:\workspace\awc-docs\flutter_app
flutter build web --release --base-href /aws-docs/
```
Expected: 빌드 성공. (Git Bash 금지 — base-href 깨짐.)

- [ ] **Step 5: dogfood — 딥링크 스크롤 실확인**

로컬 빌드를 base-href 루트로 재빌드하거나 기존 dogfood 서버(메모리 flutter-web-dogfood-browse) 사용. browse로 `…/#/cert/CLF-C02/study/clf-t1-1?at=core-benefits` 열고 스크린샷 → 페이지가 "핵심 이점" 섹션에 글래스 헤더 아래로 스크롤됐는지 육안 확인. 앵커 없는 `?at=nonexistent`는 최상단 유지(폴백) 확인. 결과 png를 Read로 확인.

- [ ] **Step 6: 커밋**

```bash
git add flutter_app/assets/content/clf/t1-1.md flutter_app/assets/content/clf/t1-1.questions.json
git commit -m "content(clf): t1-1 섹션 {#id} 앵커 + 문항 section 시드 — 딥링크 dogfood"
```

---

## 완료 후

Phase 1 전체 게이트: `flutter test` 그린 + `flutter analyze` 신규 0건 + dogfood 스크롤 확인. 이후 `feat/concept-deeplink` → develop PR(CI 녹색 확인 후 머지). Phase 2(report 개조 + wrongSkills 비정규화)는 별도 플랜으로 착수.
