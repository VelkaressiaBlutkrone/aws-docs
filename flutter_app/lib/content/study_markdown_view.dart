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
  const StudyMarkdownView({
    super.key,
    required this.blocks,
    this.anchorKeys,
    this.headingTrailing,
  });

  final List<MdBlock> blocks;
  final Map<String, GlobalKey>? anchorKeys;

  /// 앵커 있는 헤딩의 오른쪽 슬롯(예: 오디오 시크 아이콘). null 반환이면 미표시.
  final Widget? Function(String anchor)? headingTrailing;

  Key? _anchorKey(MdHeading? h) {
    final id = h?.anchor;
    if (id == null) return null;
    return anchorKeys?[id];
  }

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
          key: _anchorKey(head),
          padding: const EdgeInsets.only(top: Gap.xl, bottom: Gap.sm),
          child: () {
            final trailing = (head.anchor != null)
                ? headingTrailing?.call(head.anchor!)
                : null;
            final title = Text(head.text,
                style: Theme.of(context).textTheme.headlineSmall);
            if (trailing == null) return title;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: title),
                const SizedBox(width: Gap.sm),
                trailing,
              ],
            );
          }(),
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
      case MdHeading(:final level, :final text, :final anchor):
        Key? headingKey;
        if (anchor != null) headingKey = anchorKeys?[anchor];
        final trailing =
            (anchor != null) ? headingTrailing?.call(anchor) : null;
        return Padding(
          key: headingKey,
          padding: EdgeInsets.only(
              top: level <= 2 ? Gap.lg : Gap.md, bottom: Gap.xs),
          child: trailing == null
              ? Text(text, style: level >= 3 ? t.titleMedium : t.titleLarge)
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(text,
                          style: level >= 3 ? t.titleMedium : t.titleLarge),
                    ),
                    const SizedBox(width: Gap.sm),
                    trailing,
                  ],
                ),
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
                                fontWeight: FontWeight.w700, fontVariations: Wght.w700, color: c.accent))),
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
          // 배경색은 Material이 담당한다. DecoratedBox(Container)에 배경색을 두면
          // ExpansionTile 내부 ListTile의 잉크/배경이 가려진다는 assertion이 난다.
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Radii.sm),
            border: Border.all(color: c.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Material(
            color: c.surface,
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
                    ? base.copyWith(fontWeight: FontWeight.w700, fontVariations: Wght.w700, color: c.text)
                    : s.url != null
                        ? base.copyWith(color: c.accent)
                        : base,
          ),
      ]),
      style: base,
    );
  }

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
}
