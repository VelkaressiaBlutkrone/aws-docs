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
  final List<List<MdSpan>> headers; // 열 → spans
  final List<List<List<MdSpan>>> rows; // 행 → 열 → spans
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
