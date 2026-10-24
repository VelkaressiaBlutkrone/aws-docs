// 스냅샷·진행 모델 가드(Task 2).
//
// 설계 §4.1: 세션이 출제 문항을 통째로 들고 가 복원이 에셋을 읽지 않게 한다.
// 설계 §4.2: ⚠️ 역직렬화가 `QuestionBank.fromJson`을 타면 안 된다 — 그 생성자가
// `.where((q) => q.verified)`로 거르기 때문에 철회된 문항이 조용히 사라진다.
import 'package:flutter_test/flutter_test.dart';

import 'package:aws_docs/models/exam_snapshot.dart';
import 'package:aws_docs/models/question.dart';

Question _q(String id, {bool verified = true, int options = 2}) => Question(
      id: id,
      examGuideTaskId: 'clf-t2-3',
      skill: '최소 권한',
      section: '',
      difficulty: '',
      stem: '문항 $id',
      options: [for (var i = 0; i < options; i++) '보기 $i'],
      correct: 0,
      explanation: '해설 $id',
      wrongExplanations: const {1: '오답 해설'},
      sources: const [],
      verified: verified,
    );

ExamSnapshot _snapshotWith({bool verified = true}) => ExamSnapshot(
      examId: 'exam:CLF-C02-mock',
      certId: 'CLF-C02',
      taskId: 'CLF-C02-mock',
      nonce: 'run-1',
      startedAtIso: DateTime(2026, 10, 25, 9).toIso8601String(),
      durationSec: 5400,
      questions: [_q('a', verified: verified), _q('b', verified: verified)],
    );

ExamProgress _progress({
  int index = 0,
  Map<int, int> picked = const {},
  List<int> flagged = const [],
}) =>
    ExamProgress(
      examId: 'exam:CLF-C02-mock',
      nonce: 'run-1',
      index: index,
      picked: picked,
      flagged: flagged,
    );

List<Question> _twoOptionQs() => [_q('a'), _q('b')];

void main() {
  test('ExamSnapshot 라운드트립 — 문항·순서·nonce 보존', () {
    final snap = _snapshotWith();
    final back = ExamSnapshot.fromJson(snap.toJson());
    expect(back.examId, snap.examId);
    expect(back.certId, snap.certId);
    expect(back.taskId, snap.taskId);
    expect(back.nonce, 'run-1');
    expect(back.startedAtIso, snap.startedAtIso);
    expect(back.durationSec, 5400);
    expect([for (final q in back.questions) q.id], ['a', 'b']);
    expect(back.questions.first.stem, '문항 a');
    expect(back.questions.first.explanation, '해설 a');
  });

  test('⚠️ 철회 문항도 스냅샷에서 살아남는다(verified 게이트 우선)', () {
    // QuestionBank.fromJson 을 타면 .where((q) => q.verified) 로 사라진다.
    final snap = ExamSnapshot.fromJson(_snapshotWith(verified: false).toJson());
    expect(snap.questions.length, 2,
        reason: '스냅샷은 verified 게이트보다 우선한다(설계 §4.2)');
    expect(snap.questions.every((q) => !q.verified), isTrue);
  });

  test('ExamProgress 라운드트립 — picked 문자열 키 복원', () {
    final p = _progress(index: 3, picked: {0: 1, 2: 0}, flagged: [1]);
    final back = ExamProgress.fromJson(p.toJson());
    expect(back.examId, p.examId);
    expect(back.nonce, 'run-1');
    expect(back.index, 3);
    expect(back.picked, {0: 1, 2: 0}); // int 키 복원
    expect(back.flagged, [1]);
  });

  test('ExamProgress.fromJson은 손상된 picked 항목을 건너뛴다', () {
    final back = ExamProgress.fromJson({
      'examId': 'exam:x',
      'nonce': 'n',
      'index': 0,
      'picked': {'0': 1, 'bad': 2},
      'flagged': [0, 'nope'],
    });
    expect(back.picked, {0: 1});
    expect(back.flagged, [0]);
  });

  test('sanitizeProgress: 보기 개수를 벗어난 응답을 버린다', () {
    // Review Focus 4 — 2지선다 문항에 picked {0: 5} 가 들어온 경우
    final clean =
        sanitizeProgress(_progress(picked: {0: 5, 1: 0}), _twoOptionQs());
    expect(clean.picked.containsKey(0), isFalse);
    expect(clean.picked[1], 0);
  });

  test('sanitizeProgress: 문항 수를 벗어난 index·flagged를 접는다', () {
    final clean = sanitizeProgress(
      _progress(index: 9, picked: {7: 0}, flagged: [0, 9]),
      _twoOptionQs(), // 문항 2개
    );
    expect(clean.index, 1, reason: 'index는 마지막 문항으로 clamp');
    expect(clean.picked, isEmpty, reason: '문항 범위 밖 응답은 버린다');
    expect(clean.flagged, [0]);
  });

  test('sanitizeProgress: 멀쩡한 진행은 그대로 둔다', () {
    final p = _progress(index: 1, picked: {0: 1, 1: 0}, flagged: [1]);
    final clean = sanitizeProgress(p, _twoOptionQs());
    expect(clean.index, 1);
    expect(clean.picked, {0: 1, 1: 0});
    expect(clean.flagged, [1]);
    expect(clean.nonce, 'run-1');
  });
}
