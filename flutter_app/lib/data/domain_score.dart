import '../models/question.dart';

/// 한 번의 시험에서 도메인 하나의 정답 현황.
class DomainScore {
  const DomainScore({
    required this.domain,
    required this.name,
    required this.correct,
    required this.total,
  });

  final int domain;

  /// 공식 시험 가이드의 도메인 이름. 가이드를 읽지 못했으면 null이다.
  final String? name;
  final int correct;
  final int total;

  int get percent => total == 0 ? 0 : (correct * 100 / total).round();

  String get label => name == null ? '도메인 $domain' : '도메인 $domain · $name';
}

/// 시험 문항과 선택에서 도메인별 정답 현황을 계산한다(도메인 번호순).
///
/// 미응답은 총점과 같이 오답으로 센다. 나누어 보여 줄 수 없으면 빈 목록이다:
/// 도메인이 하나뿐이거나, 도메인을 모르는 문항이 섞여 합계가 총점과 어긋날 때.
List<DomainScore> buildDomainScores({
  required List<Question> questions,
  required Map<int, int> picked,
  required Map<String, int> domainByTaskId,
  Map<int, String> domainNames = const {},
}) {
  final correct = <int, int>{};
  final total = <int, int>{};
  for (var k = 0; k < questions.length; k++) {
    final q = questions[k];
    final domain = domainByTaskId[q.examGuideTaskId];
    if (domain == null) return const [];
    total[domain] = (total[domain] ?? 0) + 1;
    if (picked[k] == q.correct) correct[domain] = (correct[domain] ?? 0) + 1;
  }
  if (total.length < 2) return const [];

  final domains = total.keys.toList()..sort();
  return [
    for (final d in domains)
      DomainScore(
        domain: d,
        name: domainNames[d],
        correct: correct[d] ?? 0,
        total: total[d]!,
      ),
  ];
}
