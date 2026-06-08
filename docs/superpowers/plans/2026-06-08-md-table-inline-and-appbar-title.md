# 표 인라인 서식 + 모바일 표 가독성 + AppBar 제목 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 학습문서 표 셀의 `**굵게**`/`` `코드` ``를 제대로 렌더하고, 좁은 화면에서 표를 가로 스크롤로 읽히게 하며, 3개 페이지 AppBar 제목을 자격증 코드로 줄인다.

**Architecture:** `MdTable`을 raw String에서 `MdSpan` 기반으로 바꿔 파서가 기존 `_inline()`을 셀에 적용하고 렌더러가 기존 `_spans()`를 재사용한다. 표 렌더는 `LayoutBuilder`+가로 스크롤로 좁은 화면에서 열 최소폭을 보장한다. AppBar 제목은 `cert.title`→`cert.code`.

**Tech Stack:** Flutter (Dart), flutter_test. 스펙: `docs/superpowers/specs/2026-06-08-md-table-inline-and-appbar-title-design.md`

**작업 디렉터리:** 명령은 `flutter_app/`에서 실행.

---

## 파일 구조

| 파일 | 작업 | 책임 |
|---|---|---|
| `lib/models/study_content.dart` | 수정 | `MdTable`을 spans 타입으로 |
| `lib/content/markdown_parser.dart` | 수정 | 표 셀에 `_inline()` 적용 |
| `lib/content/study_markdown_view.dart` | 수정 | `_table`을 `_spans` 재사용 + 가로 스크롤 |
| `lib/pages/cert_exam_page.dart` | 수정 | AppBar 제목 `cert.code` |
| `lib/pages/review_page.dart` | 수정 | AppBar 제목 `cert.code` |
| `lib/pages/report_page.dart` | 수정 | AppBar 제목 `cert.code` |
| `test/markdown_parser_test.dart` | 수정 | 표 셀 인라인 파싱 단언 |
| `test/study_markdown_view_test.dart` | 수정 | spans 생성자 + RichText 기반 단언 |
| `test/home_sections_test.dart` 또는 신규 | 추가 | AppBar 코드 제목 위젯 테스트 |

---

### Task 1: `MdTable` spans 모델 + 파서 + 렌더러 + 가로 스크롤

세 파일(model/parser/view)이 한 타입 변경으로 함께 깨지므로 한 Task로 묶어 컴파일·테스트를 한 번에 통과시킨다.

**Files:**
- Modify: `flutter_app/lib/models/study_content.dart:62-66`
- Modify: `flutter_app/lib/content/markdown_parser.dart:132-149`
- Modify: `flutter_app/lib/content/study_markdown_view.dart:164-165, 242-273`
- Test: `flutter_app/test/markdown_parser_test.dart`, `flutter_app/test/study_markdown_view_test.dart`

- [ ] **Step 1: 파서 테스트 작성(실패)**

`test/markdown_parser_test.dart`의 `main()` 끝에 추가:

```dart
  test('표 셀의 **굵게**를 인라인 spans로 파싱한다', () {
    const md = '''
---
title: X
---

| 용어 | 설명 |
| --- | --- |
| **탄력성** | 수요에 맞춰 `조절` |
''';
    final doc = parseStudyDoc(md);
    final table = doc.blocks.whereType<MdTable>().first;
    // 헤더: 평문
    expect(table.headers[0].first.text, '용어');
    // 첫 행 첫 셀: 굵게 span
    expect(table.rows[0][0].any((s) => s.bold && s.text == '탄력성'), isTrue);
    // 첫 행 둘째 셀: code span 포함
    expect(table.rows[0][1].any((s) => s.code && s.text == '조절'), isTrue);
  });
```

- [ ] **Step 2: 실패 확인**

Run: `cd flutter_app; flutter test test/markdown_parser_test.dart`
Expected: 컴파일 에러(`table.headers[0].first.text` — 현재 headers는 `List<String>`) 또는 단언 실패.

- [ ] **Step 3: 모델 변경**

`lib/models/study_content.dart`의 `MdTable`(62-66행)을 교체:

```dart
class MdTable extends MdBlock {
  const MdTable(this.headers, this.rows);
  final List<List<MdSpan>> headers; // 열 → spans
  final List<List<List<MdSpan>>> rows; // 행 → 열 → spans
}
```

- [ ] **Step 4: 파서 변경**

`lib/content/markdown_parser.dart`의 표 분기(132-149행)를 교체:

```dart
    if (s.startsWith('|')) {
      final tbl = <String>[];
      while (i < end && lines[i].trim().startsWith('|')) {
        tbl.add(lines[i].trim());
        i++;
      }
      if (tbl.length >= 2) {
        List<List<MdSpan>> cells(String r) => r
            .split('|')
            .map((c) => c.trim())
            .where((c) => c.isNotEmpty)
            .map(_inline)
            .toList();
        final headers = cells(tbl[0]);
        final rows = <List<List<MdSpan>>>[];
        for (var r = 2; r < tbl.length; r++) {
          rows.add(cells(tbl[r]));
        }
        blocks.add(MdTable(headers, rows));
      }
      continue;
    }
```

- [ ] **Step 5: 렌더러 변경**

`lib/content/study_markdown_view.dart`의 `_table` 호출부(164-165행)는 그대로 두고(`MdTable(:final headers, :final rows) => _table(context, headers, rows)`), `_table` 메서드(242-273행)를 교체:

```dart
  Widget _table(BuildContext context, List<List<MdSpan>> headers,
      List<List<List<MdSpan>>> rows) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    TableRow buildRow(List<List<MdSpan>> cells, {required bool header}) =>
        TableRow(
          decoration: BoxDecoration(color: header ? c.surface2 : null),
          children: [
            for (var k = 0; k < headers.length; k++)
              Padding(
                padding: const EdgeInsets.all(Gap.sm),
                child: _spans(
                    context,
                    k < cells.length ? cells[k] : const [MdSpan('')],
                    header
                        ? t.labelLarge!
                        : t.bodyMedium!.copyWith(color: c.text)),
              ),
          ],
        );
    return LayoutBuilder(
      builder: (context, constraints) {
        const minCol = 140.0;
        final tableWidth = headers.isEmpty
            ? constraints.maxWidth
            : (constraints.maxWidth > headers.length * minCol
                ? constraints.maxWidth
                : headers.length * minCol);
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: tableWidth,
            child: Container(
              margin: const EdgeInsets.only(bottom: Gap.md),
              decoration: BoxDecoration(
                  border: Border.all(color: c.border),
                  borderRadius: BorderRadius.circular(Radii.sm)),
              child: Table(
                border:
                    TableBorder.symmetric(inside: BorderSide(color: c.border)),
                defaultVerticalAlignment: TableCellVerticalAlignment.top,
                children: [
                  buildRow(headers, header: true),
                  for (final r in rows) buildRow(r, header: false),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
```

- [ ] **Step 6: 뷰 테스트 수정**

`test/study_markdown_view_test.dart`의 `MdTable(['A', 'B'], [['EC2', '고객']])`를 spans 생성자로 교체하고, 굵게 셀을 추가하며, `find.text('EC2')`를 RichText 기반으로 교체. 파일 전체를 다음으로 교체:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' show RichText;
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/content/study_markdown_view.dart';
import 'package:aws_docs/models/study_content.dart';
import 'package:aws_docs/theme/app_theme.dart';

bool _richContains(String needle) {
  return find.byWidgetPredicate((w) {
    if (w is! RichText) return false;
    return w.text.toPlainText().contains(needle);
  }).evaluate().isNotEmpty;
}

void main() {
  testWidgets('헤딩/문단/표/토글을 렌더한다', (tester) async {
    final blocks = <MdBlock>[
      const MdHeading(2, '🎯 왜 중요한가'),
      const MdParagraph([MdSpan('도메인 2는 비중이 '), MdSpan('30%', bold: true)]),
      const MdTable([
        [MdSpan('A')],
        [MdSpan('B')]
      ], [
        [
          [MdSpan('EC2', bold: true)],
          [MdSpan('고객')]
        ],
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
    expect(_richContains('EC2'), isTrue); // 표 셀(굵게, Text.rich)
    expect(_richContains('고객'), isTrue); // 표 셀
  });
}
```

- [ ] **Step 7: 테스트·분석 통과 확인**

Run: `cd flutter_app; flutter analyze; flutter test test/markdown_parser_test.dart test/study_markdown_view_test.dart`
Expected: analyze 0건, 두 파일 전체 PASS.

- [ ] **Step 8: 전체 테스트**

Run: `cd flutter_app; flutter test`
Expected: 전체 PASS(회귀 없음).

- [ ] **Step 9: Commit**

```bash
git add flutter_app/lib/models/study_content.dart flutter_app/lib/content/markdown_parser.dart flutter_app/lib/content/study_markdown_view.dart flutter_app/test/markdown_parser_test.dart flutter_app/test/study_markdown_view_test.dart
git commit -m "fix: 학습문서 표 셀 인라인 서식 렌더 + 모바일 가로 스크롤"
```

---

### Task 2: AppBar 제목을 자격증 코드로

**Files:**
- Modify: `flutter_app/lib/pages/cert_exam_page.dart` (제목 Text, ~160-162행)
- Modify: `flutter_app/lib/pages/review_page.dart` (제목 Text, ~92-93행)
- Modify: `flutter_app/lib/pages/report_page.dart` (제목 Text, ~63-64행)
- Test: `flutter_app/test/home_sections_test.dart` (새 그룹)

- [ ] **Step 1: AppBar 제목 위젯 테스트 작성(실패)**

`test/home_sections_test.dart`의 `main()` 끝에 추가(기존 `_home()` 헬퍼·import 재사용). 라우터로 통합 모의고사 경로를 펌프해 코드 제목을 확인:

```dart
  testWidgets('통합 모의고사 AppBar 제목은 자격증 코드 기반', (tester) async {
    final router = createRouter(initialLocation: '/cert/CLF-C02/exam');
    await tester.pumpWidget(ThemeScope(
      isDark: false,
      toggle: () {},
      child: MaterialApp.router(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        routerConfig: router,
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('CLF-C02 · 통합 모의고사'), findsOneWidget);
  });
```

- [ ] **Step 2: 실패 확인**

Run: `cd flutter_app; flutter test test/home_sections_test.dart`
Expected: FAIL — 현재 제목이 `AWS Certified Cloud Practitioner · 통합 모의고사`라 `findsNothing`.

- [ ] **Step 3: cert_exam_page 제목 변경**

`lib/pages/cert_exam_page.dart`의 AppBar `title` Text(160-162행 부근):

```dart
        title: Text(
            '${widget.cert.title} · ${widget.weighted ? '약점 집중 모의고사' : '통합 모의고사'}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
```

를:

```dart
        title: Text(
            '${widget.cert.code} · ${widget.weighted ? '약점 집중 모의고사' : '통합 모의고사'}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
```

- [ ] **Step 4: review_page 제목 변경**

`lib/pages/review_page.dart`의 AppBar `title`(92-93행 부근):

```dart
        title: Text('${widget.cert.title} · 오답노트',
```

를:

```dart
        title: Text('${widget.cert.code} · 오답노트',
```

- [ ] **Step 5: report_page 제목 변경**

`lib/pages/report_page.dart`의 AppBar `title`(63-64행 부근):

```dart
        title: Text('${widget.cert.title} · 약점 리포트',
```

를:

```dart
        title: Text('${widget.cert.code} · 약점 리포트',
```

- [ ] **Step 6: 테스트·분석 통과 확인**

Run: `cd flutter_app; flutter analyze; flutter test test/home_sections_test.dart`
Expected: analyze 0건, PASS.

- [ ] **Step 7: 전체 테스트**

Run: `cd flutter_app; flutter test`
Expected: 전체 PASS(회귀 없음).

- [ ] **Step 8: Commit**

```bash
git add flutter_app/lib/pages/cert_exam_page.dart flutter_app/lib/pages/review_page.dart flutter_app/lib/pages/report_page.dart flutter_app/test/home_sections_test.dart
git commit -m "fix: 모의고사/오답노트/리포트 AppBar 제목을 자격증 코드로(모바일 말줄임 방지)"
```

---

## Self-Review 결과

- **스펙 커버리지:** §3.1 모델·파서·렌더러(spans)→Task 1 Step 3-6 / §3.2 가로 스크롤(LayoutBuilder·minCol 140)→Task 1 Step 5 / §3.3 3개 페이지 코드 제목→Task 2 / §4 테스트(파서·뷰·AppBar)→Task 1 Step 1·6, Task 2 Step 1
- **플레이스홀더 스캔:** 없음(모든 코드 블록 완전)
- **타입 일관성:** `MdTable(List<List<MdSpan>> headers, List<List<List<MdSpan>>> rows)` — 모델(Step3)·파서(Step4)·렌더러(Step5)·테스트(Step1·6) 전부 동일. `_spans(context, List<MdSpan>, TextStyle)`·`_inline(String)→List<MdSpan>`는 기존 시그니처 그대로 사용
- **주의:** Task 2 테스트는 `createRouter`/`ThemeScope`/`AppTheme`를 쓰며 `home_sections_test.dart`에 이미 import됨. 통합 모의고사 start 화면이 곧장 제목 AppBar를 그리므로(시작 버튼 누르기 전에도 제목 표시) 펌프만으로 제목 확인 가능
