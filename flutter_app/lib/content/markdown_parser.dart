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
