# 설계: 표 인라인 서식 + 모바일 표 가독성 + AppBar 제목

- **날짜:** 2026-06-08
- **상태:** 승인됨 (/superpowers:brainstorming)
- **범위:** 학습문서 마크다운 표 렌더링 + 3개 페이지 AppBar 제목. 모델 1, 파서 1, 렌더러 1, 페이지 3, 테스트 2~3.

## 1. 문제

1. **표 셀 인라인 서식 미적용(버그):** `MdTable`이 셀을 raw `String`으로 저장하고 렌더러도 `Text`로 출력해, 셀 안의 `**굵게**`·`` `코드` ``가 리터럴 별표/백틱으로 노출된다.
2. **모바일 표 가독성:** `Table` 위젯이 가용 폭을 균등 분할해 좁은 화면(예: 390px)에서 3열 표가 심하게 눌려 잘게 줄바꿈된다.
3. **AppBar 긴 제목:** `cert_exam`/`review`/`report` 페이지가 `'${cert.title} · 모드'`(긴 영문 자격증명)를 써서 모바일에서 모드명이 말줄임으로 잘린다.

## 2. 결정 요약

| 항목 | 결정 |
|---|---|
| #1 셀 서식 | `MdTable`을 spans 기반으로 바꿔 파서가 `_inline()` 적용, 렌더러는 `_spans` 재사용 |
| #1 표 가독성 | `LayoutBuilder` + 가로 스크롤, 표 폭 = `max(가용폭, 열수×140)` |
| #2 제목 | `cert.title` → `cert.code` (예: `CLF-C02 · 통합 모의고사`). 데스크톱도 동일 |

## 3. 설계

### 3.1 표 셀 인라인 서식 (모델·파서·렌더러)

**모델** (`lib/models/study_content.dart`):
```dart
class MdTable extends MdBlock {
  const MdTable(this.headers, this.rows);
  final List<List<MdSpan>> headers;          // 셀 = spans
  final List<List<List<MdSpan>>> rows;       // 행 → 셀 → spans
}
```

**파서** (`lib/content/markdown_parser.dart`, 표 분기 132-149행): 각 셀 문자열에 기존 `_inline()`을 적용해 `List<MdSpan>`로 변환 후 저장.
```dart
List<List<MdSpan>> cellsSpans(String r) =>
    r.split('|').map((c) => c.trim()).where((c) => c.isNotEmpty)
     .map(_inline).toList();
final headers = cellsSpans(tbl[0]);
final rows = <List<List<MdSpan>>>[];
for (var r = 2; r < tbl.length; r++) rows.add(cellsSpans(tbl[r]));
blocks.add(MdTable(headers, rows));
```
(헤더 열 수는 `headers.length` 그대로 사용.)

**렌더러** (`lib/content/study_markdown_view.dart` `_table`): `Text(cells[k] …)` → 기존 `_spans(context, cell, style)` 재사용. 헤더는 `t.labelLarge`, 본문 셀은 `t.bodyMedium!.copyWith(color: c.text)`를 base로 전달. `_spans`가 굵게/코드/URL을 본문과 동일하게 처리.

### 3.2 모바일 표 가독성 (렌더러)

`_table`을 `LayoutBuilder`로 감싸 표 폭을 계산하고 가로 스크롤을 추가(코드 블록의 기존 패턴과 동일):
```dart
return LayoutBuilder(builder: (context, constraints) {
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
      child: Container(/* 기존 border/radius */, child: Table(/* 기존 */)),
    ),
  );
});
```
- 넓은 화면: `tableWidth == maxWidth` → 꽉 차고 스크롤 없음(기존과 동일)
- 좁은 화면: 각 열 ≥140px → 가로 스크롤, 가독성 확보

### 3.3 AppBar 제목 → 자격증 코드

`'${widget.cert.title} · …'` → `'${widget.cert.code} · …'` 로 교체:
- `lib/pages/cert_exam_page.dart`: `'${cert.code} · ${weighted ? '약점 집중 모의고사' : '통합 모의고사'}'`
- `lib/pages/review_page.dart`: `'${cert.code} · 오답노트'`
- `lib/pages/report_page.dart`: `'${cert.code} · 약점 리포트'`

`exam_page.dart`/`quiz_page.dart`(`entry.title` = 짧은 Task명), `study_doc_page.dart`(문서 제목)는 무변경.

## 4. 테스트

- `markdown_parser_test.dart`: 표를 가진 자산에서 어떤 표 셀이 `MdSpan(bold:true)`를 포함하는지 단언(셀 인라인 파싱 검증). 기존 `MdTable` 존재 단언은 유지.
- `study_markdown_view_test.dart`: 기존 `const MdTable(['A','B'], [['EC2','고객']])` → spans 생성자로 수정
  (`MdTable([[MdSpan('A')],[MdSpan('B')]], [[[MdSpan('EC2')],[MdSpan('고객')]]])`).
  `find.text('EC2')`는 `Text.rich`로 안 잡히므로 `find.byWidgetPredicate`로 RichText의 plain text에 'EC2' 포함을 확인하도록 교체. 굵게 셀 1개를 추가해 렌더 무crash 확인.
- AppBar 제목: `cert_exam`/`review`/`report`를 라우터로 펌프해 `find.text('CLF-C02 · 통합 모의고사')` 등 코드 기반 제목 노출 확인(최소 1개 페이지).

## 5. 비범위 (YAGNI)

- 표 셀 내부의 블록 요소(리스트/중첩 표)
- 표 정렬 문법(`:---`, `---:`)
- 제목 외 다른 AppBar 요소
- 데스크톱 표 디자인(열 폭 알고리즘) 변경 — 넓은 화면 동작은 기존과 동일 유지
