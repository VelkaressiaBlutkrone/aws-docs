/// Official AWS exam-guide content (domains → tasks → knowledge/skills),
/// loaded from assets/exam_guides/{code}.json. Korean text preserved verbatim
/// from the official ko_kr exam guides.
class ExamGuide {
  const ExamGuide({
    required this.code,
    required this.overview,
    required this.domains,
    required this.sourceUrl,
  });

  final String code;
  final ExamOverview overview;
  final List<ExamDomain> domains;
  final String sourceUrl;

  int get taskCount =>
      domains.fold(0, (sum, d) => sum + d.tasks.length);

  factory ExamGuide.fromJson(Map<String, dynamic> j) => ExamGuide(
        code: j['code'] as String,
        overview: ExamOverview.fromJson(j['overview'] as Map<String, dynamic>),
        domains: (j['domains'] as List)
            .map((d) => ExamDomain.fromJson(d as Map<String, dynamic>))
            .toList(),
        sourceUrl: (j['sourceUrl'] as String?) ?? '',
      );
}

class ExamOverview {
  const ExamOverview({
    required this.level,
    required this.passingScore,
    required this.scoredQuestions,
    required this.unscoredQuestions,
    required this.durationMinutes,
  });

  final String? level;
  final int? passingScore;
  final int? scoredQuestions;
  final int? unscoredQuestions;
  final int? durationMinutes;

  factory ExamOverview.fromJson(Map<String, dynamic> j) => ExamOverview(
        level: j['level'] as String?,
        passingScore: j['passingScore'] as int?,
        scoredQuestions: j['scoredQuestions'] as int?,
        unscoredQuestions: j['unscoredQuestions'] as int?,
        durationMinutes: j['durationMinutes'] as int?,
      );
}

class ExamDomain {
  const ExamDomain({
    required this.no,
    required this.name,
    required this.weightPct,
    required this.tasks,
  });

  final int no;
  final String name;
  final int weightPct;
  final List<ExamTask> tasks;

  factory ExamDomain.fromJson(Map<String, dynamic> j) => ExamDomain(
        no: j['no'] as int,
        name: j['name'] as String,
        weightPct: (j['weightPct'] as num?)?.toInt() ?? 0,
        tasks: (j['tasks'] as List)
            .map((t) => ExamTask.fromJson(t as Map<String, dynamic>))
            .toList(),
      );
}

class ExamTask {
  const ExamTask({
    required this.no,
    required this.title,
    required this.knowledge,
    required this.skills,
  });

  final String no;
  final String title;
  final List<String> knowledge;
  final List<String> skills;

  factory ExamTask.fromJson(Map<String, dynamic> j) => ExamTask(
        no: (j['no'] ?? '').toString(),
        title: (j['title'] as String?) ?? '',
        knowledge:
            ((j['knowledge'] as List?) ?? const []).map((e) => e.toString()).toList(),
        skills:
            ((j['skills'] as List?) ?? const []).map((e) => e.toString()).toList(),
      );
}

/// Korean study summary distilled from the official guide (the Drive 요약본).
/// Shown separately from the verbatim official guide content.
class ExamSummary {
  const ExamSummary({
    required this.purpose,
    required this.audience,
    required this.priorityPoints,
    required this.outOfScope,
  });

  final String purpose;
  final String audience;
  final List<String> priorityPoints;
  final List<String> outOfScope;

  factory ExamSummary.fromJson(Map<String, dynamic> j) => ExamSummary(
        purpose: (j['purpose'] as String?) ?? '',
        audience: (j['audience'] as String?) ?? '',
        priorityPoints: ((j['priorityPoints'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
        outOfScope: ((j['outOfScope'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
      );

  /// Shared "활용 방법" guidance (identical across all official summaries).
  static const List<String> howToUse = [
    '도메인 비중이 높은 항목부터 공식 문서와 Skill Builder 자료로 보완합니다.',
    '각 도메인별 Task/Skill을 체크리스트로 전환해 모르는 항목을 표시합니다.',
    '최종 점검 때는 공식 안내서의 범위 내/범위 외 서비스 목록을 다시 확인합니다.',
  ];
}
