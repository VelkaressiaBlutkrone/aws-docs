// 두 키 저장소 가드(Task 3) — 설계 2026-10-24 §4.4·§4.4.1·§4.6.
//
// 키를 쪼개면 단일 레코드가 갖던 원자성이 사라진다. nonce 짝 검증이 그 손상 채널을
// 막고, 정리(GC)는 **시간 만료분만** 건드린다(반목표: 살아 있는 시험을 지우는 것).
import 'package:flutter_test/flutter_test.dart';

import 'package:aws_docs/data/exam_session_store.dart';
import 'package:aws_docs/data/history_store.dart' show MemoryBackend;
import 'package:aws_docs/models/exam_snapshot.dart';
import 'package:aws_docs/models/question.dart';

const _examId = 'exam:CLF-C02-mock';
final _start = DateTime(2026, 10, 25, 9);

Question _q(String id) => Question(
      id: id,
      examGuideTaskId: 'clf-t2-3',
      skill: '',
      section: '',
      difficulty: '',
      stem: '문항 $id',
      options: const ['보기 0', '보기 1'],
      correct: 0,
      explanation: '',
      wrongExplanations: const {},
      sources: const [],
      verified: true,
    );

ExamSnapshot _snap({String nonce = 'run-1', String examId = _examId}) =>
    ExamSnapshot(
      examId: examId,
      certId: 'CLF-C02',
      taskId: 'CLF-C02-mock',
      nonce: nonce,
      startedAtIso: _start.toIso8601String(),
      durationSec: 5400,
      questions: [_q('a'), _q('b')],
    );

ExamProgress _prog({
  String nonce = 'run-1',
  int index = 0,
  Map<int, int> picked = const {},
  String examId = _examId,
}) =>
    ExamProgress(
      examId: examId,
      nonce: nonce,
      index: index,
      picked: picked,
      flagged: const [],
    );

void main() {
  late MemoryBackend backend;
  late ExamSessionStore store;

  setUp(() {
    backend = MemoryBackend();
    store = ExamSessionStore(backend: backend);
  });

  test('스냅샷·진행 왕복 후 loadRun이 둘을 짝지어 돌려준다', () {
    store.saveSnapshot(_snap());
    store.saveProgress(_prog(index: 1, picked: {0: 1}));

    final run = store.loadRun(_examId)!;
    expect(run.snapshot.nonce, 'run-1');
    expect([for (final q in run.snapshot.questions) q.id], ['a', 'b']);
    expect(run.progress.index, 1);
    expect(run.progress.picked, {0: 1});
  });

  test('⚠️ nonce 불일치: 진행을 버리고 index 0·무선택으로 복원', () {
    // 키 분리가 만드는 손상 채널 — 옛 진행이 새 스냅샷에 얹히면 안 된다(§4.4.1)
    store.saveSnapshot(_snap(nonce: 'B'));
    store.saveProgress(_prog(nonce: 'A', index: 7, picked: {3: 1}));

    final run = store.loadRun(_examId)!;
    expect(run.snapshot.nonce, 'B');
    expect(run.progress.index, 0);
    expect(run.progress.picked, isEmpty);
    expect(run.progress.nonce, 'B', reason: '복원된 진행은 스냅샷 세대를 따른다');
  });

  test('⚠️ 스냅샷만 있고 진행 키 없음 → index 0·무선택 복원', () {
    store.saveSnapshot(_snap());
    final run = store.loadRun(_examId)!;
    expect(run.progress.index, 0);
    expect(run.progress.picked, isEmpty);
  });

  test('⚠️ 손상된 스냅샷 JSON → loadRun null(새 시험)', () {
    backend.write('awsdocs.examSnapshot.v1:$_examId', '{깨진');
    expect(store.loadRun(_examId), isNull);
  });

  test('진행 키만 있고 스냅샷 없음 → null', () {
    store.saveProgress(_prog(index: 4));
    expect(store.loadRun(_examId), isNull);
  });

  test('loadRun은 벗어난 picked를 정화해서 돌려준다', () {
    store.saveSnapshot(_snap());
    store.saveProgress(_prog(picked: {0: 9})); // 보기는 2개뿐
    expect(store.loadRun(_examId)!.progress.picked, isEmpty);
  });

  test('⚠️ 만료 세션도 loadRun은 복원한다(자동 제출은 ExamView 몫)', () {
    // 저장소가 걸러 버리면 사용자는 결과 화면을 못 본다
    store.saveSnapshot(_snap());
    store.saveProgress(_prog(index: 1)); // 문항 2개이므로 1이 마지막
    final run = store.loadRun(_examId,
        now: () => _start.add(const Duration(seconds: 5401 + 60)));
    expect(run, isNotNull);
    expect(run!.progress.index, 1, reason: '만료 여부가 복원을 막지 않는다');
  });

  test('clearExpired: 만료분만 지우고 살아 있는 세션은 남긴다', () {
    const aliveId = 'exam:SAA-C03-mock';
    store.saveSnapshot(_snap());
    store.saveProgress(_prog());
    store.saveSnapshot(_snap(examId: aliveId, nonce: 'run-2'));
    store.saveProgress(_prog(examId: aliveId, nonce: 'run-2'));
    // aliveId 쪽만 시작 시각을 미래로 둬서 만료되지 않게 한다
    store.saveSnapshot(ExamSnapshot(
      examId: aliveId,
      certId: 'SAA-C03',
      taskId: 'SAA-C03-mock',
      nonce: 'run-2',
      startedAtIso: _start.add(const Duration(hours: 10)).toIso8601String(),
      durationSec: 5400,
      questions: [_q('a')],
    ));

    final removed = store.clearExpired(
        now: () => _start.add(const Duration(seconds: 5401)));

    expect(removed, 1);
    expect(store.loadRun(_examId), isNull, reason: '만료 세션은 지워진다');
    expect(store.loadRun(aliveId), isNotNull, reason: '살아 있는 시험은 남는다');
  });

  test('clearExpired: 시작 시각이 손상된 세션은 건드리지 않는다', () {
    // 반목표 — 판단 불가를 삭제 근거로 쓰지 않는다
    backend.write(
      'awsdocs.examSnapshot.v1:$_examId',
      '{"examId":"$_examId","startedAtIso":"없는날짜","durationSec":5400,"questions":[]}',
    );
    expect(store.clearExpired(now: () => _start), 0);
  });

  test('clear는 없는 키에 빈 값을 새로 쓰지 않는다', () {
    store.clear(_examId);
    expect(backend.keys(), isEmpty,
        reason: '진입마다 무조건 쓰면 구포맷 키가 빈 값으로 영구 축적된다');
  });

  test('clearRun은 없는 키를 새로 만들지 않는다', () {
    store.clearRun(_examId);
    expect(backend.keys(), isEmpty, reason: '빈 진행 키를 새로 만들면 고아 키가 쌓인다');
  });

  test('clearExpired: 스냅샷 없는 고아 진행 키를 비운다', () {
    // 짝 스냅샷이 없으면 loadRun이 영원히 null이다 — 복원될 수 없는 키가 쿼터만 먹는다.
    store.saveProgress(_prog());

    expect(store.clearExpired(now: () => _start), 0, reason: '만료된 런은 없다');
    expect(store.loadProgress(_examId), isNull);
  });

  test('clearExpired: 살아 있는 세션의 진행 키는 건드리지 않는다', () {
    // 반목표 — 정리가 산 시험을 지우는 것
    store.saveSnapshot(_snap());
    store.saveProgress(_prog(index: 1));

    store.clearExpired(now: () => _start.add(const Duration(seconds: 10)));

    expect(store.loadProgress(_examId)?.index, 1);
  });
}
