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
      taskId: 'clf-t1-1',
      title: 'AWS 클라우드의 이점',
      domain: 1,
      mdAsset: 'assets/content/clf/t1-1.md',
      questionsAsset: 'assets/content/clf/t1-1.questions.json',
      questionCount: 6,
    ),
    ContentEntry(
      certCode: 'CLF-C02',
      taskId: 'clf-t1-2',
      title: 'Well-Architected Framework (6대 기둥)',
      domain: 1,
      mdAsset: 'assets/content/clf/t1-2.md',
      questionsAsset: 'assets/content/clf/t1-2.questions.json',
      questionCount: 6,
    ),
    ContentEntry(
      certCode: 'CLF-C02',
      taskId: 'clf-t1-3',
      title: '클라우드 마이그레이션과 AWS CAF',
      domain: 1,
      mdAsset: 'assets/content/clf/t1-3.md',
      questionsAsset: 'assets/content/clf/t1-3.questions.json',
      questionCount: 9,
    ),
    ContentEntry(
      certCode: 'CLF-C02',
      taskId: 'clf-t1-4',
      title: '클라우드 경제학 (비용·rightsizing·관리형)',
      domain: 1,
      mdAsset: 'assets/content/clf/t1-4.md',
      questionsAsset: 'assets/content/clf/t1-4.questions.json',
      questionCount: 6,
    ),
    ContentEntry(
      certCode: 'CLF-C02',
      taskId: 'clf-t2-1',
      title: '공동 책임 모델',
      domain: 2,
      mdAsset: 'assets/content/clf/t2-1.md',
      questionsAsset: 'assets/content/clf/t2-1.questions.json',
      questionCount: 9,
    ),
    ContentEntry(
      certCode: 'CLF-C02',
      taskId: 'clf-t2-2',
      title: '보안·거버넌스·컴플라이언스',
      domain: 2,
      mdAsset: 'assets/content/clf/t2-2.md',
      questionsAsset: 'assets/content/clf/t2-2.questions.json',
      questionCount: 9,
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
    ContentEntry(
      certCode: 'CLF-C02',
      taskId: 'clf-t2-4',
      title: '보안 구성요소·리소스',
      domain: 2,
      mdAsset: 'assets/content/clf/t2-4.md',
      questionsAsset: 'assets/content/clf/t2-4.questions.json',
      questionCount: 6,
    ),
    ContentEntry(
      certCode: 'CLF-C02',
      taskId: 'clf-t3-1',
      title: '배포·운영 방법 (콘솔·CLI·SDK·IaC)',
      domain: 3,
      mdAsset: 'assets/content/clf/t3-1.md',
      questionsAsset: 'assets/content/clf/t3-1.questions.json',
      questionCount: 6,
    ),
    ContentEntry(
      certCode: 'CLF-C02',
      taskId: 'clf-t3-2',
      title: '글로벌 인프라 (리전·AZ·엣지)',
      domain: 3,
      mdAsset: 'assets/content/clf/t3-2.md',
      questionsAsset: 'assets/content/clf/t3-2.questions.json',
      questionCount: 6,
    ),
    ContentEntry(
      certCode: 'CLF-C02',
      taskId: 'clf-t3-3',
      title: '컴퓨팅 서비스 (EC2·컨테이너·서버리스)',
      domain: 3,
      mdAsset: 'assets/content/clf/t3-3.md',
      questionsAsset: 'assets/content/clf/t3-3.questions.json',
      questionCount: 7,
    ),
    ContentEntry(
      certCode: 'CLF-C02',
      taskId: 'clf-t3-4',
      title: '데이터베이스 서비스 (관계형·NoSQL·인메모리)',
      domain: 3,
      mdAsset: 'assets/content/clf/t3-4.md',
      questionsAsset: 'assets/content/clf/t3-4.questions.json',
      questionCount: 6,
    ),
    ContentEntry(
      certCode: 'CLF-C02',
      taskId: 'clf-t3-5',
      title: '네트워크 서비스 (VPC·Route 53·연결)',
      domain: 3,
      mdAsset: 'assets/content/clf/t3-5.md',
      questionsAsset: 'assets/content/clf/t3-5.questions.json',
      questionCount: 6,
    ),
    ContentEntry(
      certCode: 'CLF-C02',
      taskId: 'clf-t3-6',
      title: '스토리지 서비스 (객체·블록·파일)',
      domain: 3,
      mdAsset: 'assets/content/clf/t3-6.md',
      questionsAsset: 'assets/content/clf/t3-6.questions.json',
      questionCount: 7,
    ),
    ContentEntry(
      certCode: 'CLF-C02',
      taskId: 'clf-t3-7',
      title: 'AI/ML·분석 서비스',
      domain: 3,
      mdAsset: 'assets/content/clf/t3-7.md',
      questionsAsset: 'assets/content/clf/t3-7.questions.json',
      questionCount: 7,
    ),
    ContentEntry(
      certCode: 'CLF-C02',
      taskId: 'clf-t3-8',
      title: '기타 범위 내 서비스 (메시징·EUC·IoT)',
      domain: 3,
      mdAsset: 'assets/content/clf/t3-8.md',
      questionsAsset: 'assets/content/clf/t3-8.questions.json',
      questionCount: 6,
    ),
    ContentEntry(
      certCode: 'CLF-C02',
      taskId: 'clf-t4-1',
      title: '요금 모델 (구매 옵션·데이터 전송·스토리지)',
      domain: 4,
      mdAsset: 'assets/content/clf/t4-1.md',
      questionsAsset: 'assets/content/clf/t4-1.questions.json',
      questionCount: 6,
    ),
    ContentEntry(
      certCode: 'CLF-C02',
      taskId: 'clf-t4-2',
      title: '결제·예산·비용 관리 도구',
      domain: 4,
      mdAsset: 'assets/content/clf/t4-2.md',
      questionsAsset: 'assets/content/clf/t4-2.questions.json',
      questionCount: 6,
    ),
    ContentEntry(
      certCode: 'CLF-C02',
      taskId: 'clf-t4-3',
      title: '기술 리소스와 Support 플랜',
      domain: 4,
      mdAsset: 'assets/content/clf/t4-3.md',
      questionsAsset: 'assets/content/clf/t4-3.questions.json',
      questionCount: 9,
    ),
  ],
};

List<ContentEntry> contentFor(String certCode) =>
    kContentIndex[certCode] ?? const [];

/// 해당 자격증에 검증 콘텐츠(학습문서)가 존재하는가.
bool certHasContent(String certCode) => contentFor(certCode).isNotEmpty;

/// 랜딩 요약용: 학습문서 수 + 총 검증 문항 수.
({int docs, int questions}) certContentSummary(String certCode) {
  final entries = contentFor(certCode);
  var questions = 0;
  for (final e in entries) {
    questions += e.questionCount;
  }
  return (docs: entries.length, questions: questions);
}

/// 해당 자격증에 노출 가능한(verified) 문항이 1개 이상 있는가.
/// "학습문서만(문항 0)" 상태를 모의고사·리포트 노출에서 가르는 정적 판정.
bool certHasVerifiedQuestions(String certCode) =>
    certContentSummary(certCode).questions > 0;
