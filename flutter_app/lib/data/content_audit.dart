import '../models/exam_guide.dart';

/// 자격증별 학습문서·문항을 공식 문서와 전수 대조한 날
/// (`docs/audits/2026-11-17-full-verify/`).
///
/// ⚠️ 문서별 `lastVerified` 의 최댓값으로 대신하지 않는다. 한 편만 고쳐도
/// 자격증 전체를 최근에 검수한 것처럼 보이기 때문이다. 전수 대조를 다시 했을
/// 때만 이 날짜를 올린다.
const Map<String, String> kOfficialDocsAuditDates = {
  'CLF-C02': '2026-11-17',
  'SAA-C03': '2026-11-17',
  'SOA-C03': '2026-11-17',
  'DEA-C01': '2026-11-17',
  'MLA-C01': '2026-11-17',
  'AIF-C01': '2026-11-17',
  'SCS-C03': '2026-11-17',
  'AIP-C01': '2026-11-17',
  'DVA-C03': '2026-11-17',
};

/// 상세 화면의 공식 가이드 절에 적는 기준 정보. 적을 것이 없으면 null 이다.
String? guideProvenance(ExamGuide guide) {
  final audit = kOfficialDocsAuditDates[guide.code];
  final version = guide.guideVersion;
  final published = guide.guidePublished;
  final parts = [
    if (version != null && published != null) ...[
      '공식 한국어 가이드 버전 $version',
      '게시 $published',
    ],
    if (audit != null) '공식 문서 전수 대조 $audit',
  ];
  return parts.isEmpty ? null : parts.join(' · ');
}
