/// Domain models ported from the original `src/data.ts`.
enum Level { foundational, associate, professional, specialty }

extension LevelLabel on Level {
  /// Short label as stored on the cert card chip.
  String get short => switch (this) {
        Level.foundational => 'Foundational',
        Level.associate => 'Associate',
        Level.professional => 'Professional',
        Level.specialty => 'Specialty',
      };

  /// Section heading label (matches original levelLabels).
  String get heading => switch (this) {
        Level.foundational => 'Foundational 입문',
        Level.associate => 'Associate 실무 기초~중급',
        Level.professional => 'Professional 고급',
        Level.specialty => 'Specialty 전문 분야',
      };
}

class Certification {
  const Certification({
    required this.id,
    required this.level,
    required this.title,
    required this.code,
    required this.audience,
    required this.focus,
    required this.roadmap,
  });

  final String id;
  final Level level;
  final String title;
  final String code;
  final String audience;
  final List<String> focus;
  final List<String> roadmap;
}

class RecommendedPath {
  const RecommendedPath({required this.title, required this.steps});
  final String title;
  final List<String> steps;
}

class OfficialSource {
  const OfficialSource({required this.title, required this.href});
  final String title;
  final String href;
}
