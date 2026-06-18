import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/models/attempt_record.dart';
import 'package:aws_docs/data/concept_report.dart';

AttemptRecord _rec({
  List<WrongSkill> wrongSkills = const [],
  List<String> wrongQ = const [],
  String mode = 'exam',
}) =>
    AttemptRecord(
      certId: 'CLF-C02', examId: 'x', mode: mode, date: 'd',
      correct: 0, total: 1, wrongQuestionIds: wrongQ,
      flaggedQuestionIds: const [], durationSpentSec: 0,
      wrongSkills: wrongSkills,
    );

void main() {
  group('buildConceptReport', () {
    test('groups denormalized wrongSkills by task', () {
      final out = buildConceptReport(
        certId: 'CLF-C02',
        history: [
          _rec(wrongSkills: const [
            WrongSkill(skill: '탄력성', section: 'ha-elasticity', taskId: 'clf-t1-1'),
            WrongSkill(skill: '글로벌', section: 'global-infra', taskId: 'clf-t1-2'),
          ]),
        ],
        questionMeta: const {},
      );
      expect(out['clf-t1-1']!.single.skill, '탄력성');
      expect(out['clf-t1-1']!.single.section, 'ha-elasticity');
      expect(out['clf-t1-2']!.single.skill, '글로벌');
    });

    test('legacy record (no wrongSkills) falls back to live join', () {
      final out = buildConceptReport(
        certId: 'CLF-C02',
        history: [_rec(wrongQ: const ['q2'])],
        questionMeta: const {
          'q2': (taskId: 'clf-t1-1', skill: '고정비', section: 'core-benefits'),
        },
      );
      expect(out['clf-t1-1']!.single.skill, '고정비');
      expect(out['clf-t1-1']!.single.section, 'core-benefits');
    });

    test('dedups same skill within a task; ignores review mode', () {
      final out = buildConceptReport(
        certId: 'CLF-C02',
        history: [
          _rec(wrongSkills: const [
            WrongSkill(skill: '탄력성', section: 'ha-elasticity', taskId: 'clf-t1-1'),
          ]),
          _rec(wrongSkills: const [
            WrongSkill(skill: '탄력성', section: 'x', taskId: 'clf-t1-1'),
          ]),
          _rec(mode: 'review', wrongSkills: const [
            WrongSkill(skill: '복습', section: 'y', taskId: 'clf-t1-1'),
          ]),
        ],
        questionMeta: const {},
      );
      expect(out['clf-t1-1']!.length, 1); // dedup
      expect(out['clf-t1-1']!.single.section, 'ha-elasticity'); // 첫 section 유지
    });
  });
}
