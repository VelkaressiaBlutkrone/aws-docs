import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/models/attempt_record.dart';
import 'package:aws_docs/data/wrong_answer_index.dart';

// 현재 뱅크: 문항ID -> TaskID (개정으로 사라진 문항은 이 맵에서 빠짐).
const _tasks = {
  'clf-t2-1-q1': 'clf-t2-1',
  'clf-t2-1-q2': 'clf-t2-1',
  'clf-t2-1-q3': 'clf-t2-1',
  'clf-t3-1-q1': 'clf-t3-1',
};

AttemptRecord _rec({
  required String examId,
  required String date,
  required List<String> presented,
  required List<String> wrong,
  String mode = 'practice',
}) =>
    AttemptRecord(
      certId: 'CLF-C02',
      examId: examId,
      mode: mode,
      date: date,
      correct: presented.length - wrong.length,
      total: presented.length,
      wrongQuestionIds: wrong,
      flaggedQuestionIds: const [],
      presentedQuestionIds: presented,
      durationSpentSec: 60,
    );

void main() {
  test('한 번도 틀리지 않은 문항은 노트에 없음', () {
    final idx = WrongAnswerIndex.build(
      certId: 'CLF-C02',
      taskByQuestionId: _tasks,
      history: [
        _rec(examId: 'practice:clf-t2-1', date: '2026-06-01',
            presented: ['clf-t2-1-q1', 'clf-t2-1-q2'], wrong: []),
      ],
    );
    expect(idx.entries, isEmpty);
    expect(idx.weakByTask(), isEmpty);
  });

  test('첫 오답 후 미졸업 → weak', () {
    final idx = WrongAnswerIndex.build(
      certId: 'CLF-C02',
      taskByQuestionId: _tasks,
      history: [
        _rec(examId: 'practice:clf-t2-1', date: '2026-06-01',
            presented: ['clf-t2-1-q1'], wrong: ['clf-t2-1-q1']),
      ],
    );
    expect(idx.weakEntries().map((e) => e.questionId), ['clf-t2-1-q1']);
    expect(idx.weakByTask(), {'clf-t2-1': 1});
    expect(idx.entries.single.status, WrongStatus.weak);
    expect(idx.entries.single.wrongCount, 1);
    expect(idx.entries.single.consecutiveCorrect, 0);
  });

  test('서로 다른 응시 2회 연속 정답 → mastered(졸업)', () {
    final idx = WrongAnswerIndex.build(
      certId: 'CLF-C02',
      taskByQuestionId: _tasks,
      history: [
        _rec(examId: 'practice:clf-t2-1', date: '2026-06-01',
            presented: ['clf-t2-1-q1'], wrong: ['clf-t2-1-q1']), // 오답
        _rec(examId: 'review:clf-t2-1', date: '2026-06-02', mode: 'review',
            presented: ['clf-t2-1-q1'], wrong: []), // 정답 1
        _rec(examId: 'review:clf-t2-1', date: '2026-06-03', mode: 'review',
            presented: ['clf-t2-1-q1'], wrong: []), // 정답 2 → 졸업
      ],
    );
    expect(idx.entries.single.status, WrongStatus.mastered);
    expect(idx.entries.single.consecutiveCorrect, 2);
    expect(idx.weakByTask(), isEmpty); // 졸업이라 weak 0
    expect(idx.weakEntries(), isEmpty);
  });

  test('1회만 정답이면 아직 weak (졸업 아님)', () {
    final idx = WrongAnswerIndex.build(
      certId: 'CLF-C02',
      taskByQuestionId: _tasks,
      history: [
        _rec(examId: 'practice:clf-t2-1', date: '2026-06-01',
            presented: ['clf-t2-1-q1'], wrong: ['clf-t2-1-q1']),
        _rec(examId: 'review:clf-t2-1', date: '2026-06-02', mode: 'review',
            presented: ['clf-t2-1-q1'], wrong: []),
      ],
    );
    expect(idx.entries.single.status, WrongStatus.weak);
    expect(idx.entries.single.consecutiveCorrect, 1);
  });

  test('정답 후 재오답 → 연속정답 리셋(weak)', () {
    final idx = WrongAnswerIndex.build(
      certId: 'CLF-C02',
      taskByQuestionId: _tasks,
      history: [
        _rec(examId: 'practice:clf-t2-1', date: '2026-06-01',
            presented: ['clf-t2-1-q1'], wrong: ['clf-t2-1-q1']),
        _rec(examId: 'review:clf-t2-1', date: '2026-06-02', mode: 'review',
            presented: ['clf-t2-1-q1'], wrong: []),
        _rec(examId: 'practice:clf-t2-1', date: '2026-06-03',
            presented: ['clf-t2-1-q1'], wrong: ['clf-t2-1-q1']), // 다시 오답
      ],
    );
    expect(idx.entries.single.status, WrongStatus.weak);
    expect(idx.entries.single.wrongCount, 2);
    expect(idx.entries.single.consecutiveCorrect, 0);
  });

  test('현재 뱅크에 없는(개정 삭제) 문항은 제외', () {
    final idx = WrongAnswerIndex.build(
      certId: 'CLF-C02',
      taskByQuestionId: _tasks,
      history: [
        _rec(examId: 'practice:clf-t2-1', date: '2026-06-01',
            presented: ['clf-t2-1-q9'], wrong: ['clf-t2-1-q9']), // q9 = 삭제됨
      ],
    );
    expect(idx.entries, isEmpty);
  });

  test('레거시 레코드(presented 빈 값) → examId의 Task 현재 뱅크를 출제로 폴백', () {
    // presented 비어 있고 q2만 오답 → q1/q3는 정답으로 간주(같은 Task 출제).
    final idx = WrongAnswerIndex.build(
      certId: 'CLF-C02',
      taskByQuestionId: _tasks,
      history: [
        _rec(examId: 'practice:clf-t2-1', date: '2026-06-01',
            presented: [], wrong: ['clf-t2-1-q2']),
      ],
    );
    expect(idx.weakEntries().map((e) => e.questionId), ['clf-t2-1-q2']);
    expect(idx.entries.single.wrongCount, 1);
  });

  test('다른 certId 레코드는 무시', () {
    final other = AttemptRecord(
      certId: 'SAA-C03', examId: 'practice:saa-x', mode: 'practice',
      date: '2026-06-01', correct: 0, total: 1,
      wrongQuestionIds: const ['clf-t2-1-q1'], flaggedQuestionIds: const [],
      presentedQuestionIds: const ['clf-t2-1-q1'], durationSpentSec: 1,
    );
    final idx = WrongAnswerIndex.build(
      certId: 'CLF-C02', taskByQuestionId: _tasks, history: [other],
    );
    expect(idx.entries, isEmpty);
  });

  test('weakByTask는 Task별 weak 수 집계, lastSeen은 마지막 출제일', () {
    final idx = WrongAnswerIndex.build(
      certId: 'CLF-C02',
      taskByQuestionId: _tasks,
      history: [
        _rec(examId: 'practice:clf-t2-1', date: '2026-06-01',
            presented: ['clf-t2-1-q1', 'clf-t2-1-q2'],
            wrong: ['clf-t2-1-q1', 'clf-t2-1-q2']),
        _rec(examId: 'practice:clf-t3-1', date: '2026-06-05',
            presented: ['clf-t3-1-q1'], wrong: ['clf-t3-1-q1']),
      ],
    );
    expect(idx.weakByTask(), {'clf-t2-1': 2, 'clf-t3-1': 1});
    final t3 = idx.weakEntries('clf-t3-1').single;
    expect(t3.lastSeen, '2026-06-05');
  });
}
