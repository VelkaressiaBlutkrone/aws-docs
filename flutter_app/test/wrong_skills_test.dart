import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/models/attempt_record.dart';
import 'package:aws_docs/models/question.dart';
import 'package:aws_docs/data/wrong_skills.dart';

Question _q(String id, int correct, {String skill = '', String section = ''}) =>
    Question(
      id: id,
      examGuideTaskId: 'clf-t1-1',
      stem: 's',
      options: const ['a', 'b', 'c', 'd'],
      correct: correct,
      explanation: 'e',
      wrongExplanations: const {},
      sources: const [],
      verified: true,
      skill: skill,
      section: section,
    );

void main() {
  group('WrongSkill json', () {
    test('round-trips', () {
      const w = WrongSkill(skill: '탄력성', section: 'ha-elasticity', taskId: 'clf-t1-1');
      expect(WrongSkill.fromJson(w.toJson()).section, 'ha-elasticity');
      expect(WrongSkill.fromJson(w.toJson()).skill, '탄력성');
      expect(WrongSkill.fromJson(w.toJson()).taskId, 'clf-t1-1');
    });
  });

  group('AttemptRecord.wrongSkills', () {
    test('legacy json without field -> empty list', () {
      final r = AttemptRecord.fromJson(const {
        'certId': 'CLF-C02', 'examId': 'x', 'mode': 'exam', 'date': 'd',
        'correct': 1, 'total': 2, 'wrongQuestionIds': ['q2'],
        'flaggedQuestionIds': <String>[], 'durationSpentSec': 0,
      });
      expect(r.wrongSkills, isEmpty);
    });
    test('round-trips wrongSkills', () {
      final r = AttemptRecord(
        certId: 'CLF-C02', examId: 'x', mode: 'exam', date: 'd',
        correct: 1, total: 2, wrongQuestionIds: const ['q2'],
        flaggedQuestionIds: const [], durationSpentSec: 0,
        wrongSkills: const [WrongSkill(skill: 's', section: 'sec', taskId: 't')],
      );
      final back = AttemptRecord.fromJson(r.toJson());
      expect(back.wrongSkills.single.section, 'sec');
    });
  });

  group('buildWrongSkills', () {
    test('wrong+skill only; correct and skill-empty excluded', () {
      final qs = [
        _q('q1', 0, skill: '정의'),                    // correct picked -> excluded
        _q('q2', 0, skill: '탄력성', section: 'ha-elasticity'), // wrong -> included
        _q('q3', 0, skill: ''),                        // wrong but no skill -> excluded
        _q('q4', 0, skill: '글로벌', section: 'global-infra'),  // unanswered -> wrong -> included
      ];
      final picked = {0: 0, 1: 1, 2: 1}; // q1 correct, q2 wrong, q3 wrong, q4 unanswered
      final ws = buildWrongSkills(qs, picked);
      expect(ws.map((w) => w.skill).toList(), ['탄력성', '글로벌']);
      expect(ws.first.section, 'ha-elasticity');
      expect(ws.first.taskId, 'clf-t1-1');
    });
  });
}
