import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/audio_controller.dart';
import 'package:aws_docs/data/content_index.dart';
import 'package:aws_docs/data/lecture_playlist.dart';

class _Fake implements AudioBackend {
  final _ev = StreamController<AudioEvent>.broadcast();
  String? src;
  int playCalls = 0;
  int pauseCalls = 0;
  int loads = 0;
  @override
  Stream<AudioEvent> get events => _ev.stream;
  @override
  void setSrc(String s) {
    src = s;
    loads++;
  }
  @override
  Future<void> play() async => playCalls++;
  @override
  void pause() => pauseCalls++;
  @override
  void dispose() => _ev.close();
  @override
  void seek(double seconds) {}
  @override
  Stream<Duration> get positionStream => const Stream<Duration>.empty();
  @override
  Duration? get duration => null;
  void emit(AudioEvent e) => _ev.add(e);
}

ContentEntry _e(String taskId, {bool approved = true}) => ContentEntry(
      certCode: 'CLF-C02',
      taskId: taskId,
      title: 'T $taskId',
      domain: 1,
      mdAsset: 'a',
      questionsAsset: 'b',
      questionCount: 0,
      audioApproved: approved,
    );

void main() {
  late _Fake fake;
  late AudioController ctrl;
  late LecturePlaylist pl;
  final tracks = [_e('clf-t1-1'), _e('clf-t1-2'), _e('clf-t1-3')];

  setUp(() {
    fake = _Fake();
    ctrl = AudioController(backend: fake);
    pl = LecturePlaylist(controller: ctrl);
  });

  test('setQueue: 큐·인덱스 설정, 자동재생 안 함', () {
    pl.setQueue('CLF-C02', tracks);
    expect(pl.queue.length, 3);
    expect(pl.index, 0);
    expect(fake.playCalls, 0);
    expect(fake.src, isNull); // load 안 함
  });

  test('select(i): 그 트랙 load+play, currentTitle 갱신', () {
    pl.setQueue('CLF-C02', tracks);
    pl.select(1);
    expect(pl.index, 1);
    expect(fake.src, 'assets/audio/clf/clf-t1-2/lecture.mp3');
    expect(fake.playCalls, 1);
    expect(pl.currentTitle, 'T clf-t1-2');
  });

  test('select 같은 트랙 재선택(재생 중): 재시작 안 함(reload·play 추가 없음)', () async {
    pl.setQueue('CLF-C02', tracks);
    pl.select(1);
    fake.emit(AudioEvent.playing);
    await Future<void>.delayed(Duration.zero);
    final loads = fake.loads;
    final plays = fake.playCalls;
    pl.select(1); // 현재 트랙 재선택
    expect(pl.index, 1);
    expect(fake.loads, loads); // 재로드 없음(처음부터 재시작 안 함)
    expect(fake.playCalls, plays); // 추가 play 없음
  });

  test('select 같은 트랙 재선택(일시정지): 재로드 없이 이어재생', () async {
    pl.setQueue('CLF-C02', tracks);
    pl.select(1);
    fake.emit(AudioEvent.paused);
    await Future<void>.delayed(Duration.zero);
    final loads = fake.loads;
    final plays = fake.playCalls;
    pl.select(1); // 현재 트랙 재선택
    expect(pl.index, 1);
    expect(fake.loads, loads); // 재로드 없음
    expect(fake.playCalls, plays + 1); // 이어재생(play 1회)
  });

  test('next/prev 경계 no-op(끝에서 next, 처음에서 prev는 멈춤)', () {
    pl.setQueue('CLF-C02', tracks);
    expect(pl.hasPrev, isFalse);
    pl.prev();
    expect(pl.index, 0);
    expect(fake.playCalls, 0); // 경계 no-op: 재생 안 함
    pl.last();
    expect(pl.index, 2);
    expect(pl.hasNext, isFalse);
    final calls = fake.playCalls;
    pl.next();
    expect(pl.index, 2);
    expect(fake.playCalls, calls); // 경계 no-op
  });

  test('first/last: 점프(처음/마지막 트랙)', () {
    pl.setQueue('CLF-C02', tracks, startIndex: 1);
    pl.last();
    expect(pl.index, 2);
    pl.first();
    expect(pl.index, 0);
  });

  test('ended 이벤트는 인덱스 불변(수동 전환 — 자동전환 없음)', () async {
    pl.setQueue('CLF-C02', tracks);
    pl.select(0);
    fake.emit(AudioEvent.ended);
    await Future<void>.delayed(Duration.zero);
    expect(pl.index, 0); // 다음으로 넘어가지 않음
  });

  test('openDoc: idle이면 해당 트랙 load(준비), 재생 안 함', () {
    pl.openDoc('CLF-C02', 'clf-t1-2');
    expect(pl.current?.taskId, 'clf-t1-2');
    expect(fake.src, 'assets/audio/clf/clf-t1-2/lecture.mp3');
    expect(fake.playCalls, 0);
  });

  test('openDoc 비중단: 재생 중이면 컨트롤러·트랙 미변경', () async {
    pl.setQueue('CLF-C02', tracks);
    pl.select(2); // t1-3 재생
    fake.emit(AudioEvent.playing);
    await Future<void>.delayed(Duration.zero);
    final srcBefore = fake.src;
    pl.openDoc('CLF-C02', 'clf-t1-1'); // 다른 문서로 진입
    expect(pl.index, 2); // 트랙 안 바뀜
    expect(fake.src, srcBefore); // 재로드 없음(연속성)
  });

  test('openDoc 비중단: 일시정지 중이면 컨트롤러·트랙 미변경', () async {
    pl.setQueue('CLF-C02', tracks);
    pl.select(2); // t1-3 재생
    fake.emit(AudioEvent.playing);
    await Future<void>.delayed(Duration.zero);
    fake.emit(AudioEvent.paused); // 일시정지 상태로
    await Future<void>.delayed(Duration.zero);
    final srcBefore = fake.src;
    pl.openDoc('CLF-C02', 'clf-t1-1'); // 다른 문서로 진입
    expect(pl.index, 2); // 트랙 안 바뀜(비중단)
    expect(fake.src, srcBefore); // 재로드 없음
  });

  test('playPause: playing이면 pause, 아니면 play', () async {
    pl.setQueue('CLF-C02', tracks);
    pl.playPause();
    expect(fake.playCalls, 1);
    fake.emit(AudioEvent.playing);
    await Future<void>.delayed(Duration.zero);
    pl.playPause();
    expect(fake.pauseCalls, 1);
  });
}
