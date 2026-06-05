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
    ContentEntry(
      certCode: 'CLF-C02',
      taskId: 'clf-t2-3',
      title: '접근 관리 (IAM)',
      domain: 2,
      mdAsset: 'assets/content/clf/t2-3.md',
      questionsAsset: 'assets/content/clf/t2-3.questions.json',
      questionCount: 7,
    ),
  ],
};

List<ContentEntry> contentFor(String certCode) =>
    kContentIndex[certCode] ?? const [];
