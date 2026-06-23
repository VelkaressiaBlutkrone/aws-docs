import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/audio_controller.dart';

/// 주입용 가짜 백엔드 — DOM <audio> 없이 상태 전이만 검증.
/// 실제 백엔드(WebAudioBackend, package:web)는 M1 T1에서 별도 구현·실기기 검증.
/// (sync_controller_test 의 _SpyCloud 패턴)
class FakeAudioBackend implements AudioBackend {
  final _events = StreamController<AudioEvent>.broadcast();
  String? src;
  int playCalls = 0;
  int pauseCalls = 0;
  bool rejectPlay = false; // iOS user-activation 거부(NotAllowedError) 모사

  @override
  Stream<AudioEvent> get events => _events.stream;

  @override
  void setSrc(String s) => src = s;

  @override
  Future<void> play() async {
    playCalls++;
    if (rejectPlay) throw Exception('NotAllowedError');
  }

  @override
  void pause() => pauseCalls++;

  @override
  void dispose() => _events.close();

  /// 테스트가 브라우저 미디어 이벤트를 발화.
  void emit(AudioEvent e) => _events.add(e);
}

void main() {
  test('초기 상태는 idle', () {
    final c = AudioController(backend: FakeAudioBackend());
    expect(c.state, PlaybackState.idle);
  });

  test('load는 backend에 src를 설정하고 loading으로 전이', () {
    final b = FakeAudioBackend();
    final c = AudioController(backend: b);
    c.load('audio/clf-t1-1.mp3');
    expect(b.src, 'audio/clf-t1-1.mp3');
    expect(c.state, PlaybackState.loading);
  });

  test('play()는 backend.play()를 동기 진입으로 호출(user-activation 보존)', () async {
    final b = FakeAudioBackend();
    final c = AudioController(backend: b);
    c.load('x.mp3');
    final f = c.play(); // 반환 전(첫 await 지점)에 backend.play() 이미 호출돼야
    expect(b.playCalls, 1); // await/asset/metadata 체인이 끼면 0 → user activation 상실
    await f;
  });

  test('playing 이벤트로 playing 전이', () async {
    final b = FakeAudioBackend();
    final c = AudioController(backend: b);
    c.load('x.mp3');
    b.emit(AudioEvent.playing);
    await Future<void>.delayed(Duration.zero);
    expect(c.state, PlaybackState.playing);
  });

  test('paused 이벤트로 paused 전이', () async {
    final b = FakeAudioBackend();
    final c = AudioController(backend: b);
    b.emit(AudioEvent.playing);
    b.emit(AudioEvent.paused);
    await Future<void>.delayed(Duration.zero);
    expect(c.state, PlaybackState.paused);
  });

  test('pause()는 backend.pause()를 호출', () {
    final b = FakeAudioBackend();
    final c = AudioController(backend: b);
    c.pause();
    expect(b.pauseCalls, 1);
  });

  test('play() 거부(iOS user-activation 실패)는 error로 전이', () async {
    final b = FakeAudioBackend()..rejectPlay = true;
    final c = AudioController(backend: b);
    c.load('x.mp3');
    await c.play();
    expect(c.state, PlaybackState.error);
  });

  test('ended 이벤트로 ended 전이(1A 단일 파일 — 재생 완료)', () async {
    final b = FakeAudioBackend();
    final c = AudioController(backend: b);
    b.emit(AudioEvent.ended);
    await Future<void>.delayed(Duration.zero);
    expect(c.state, PlaybackState.ended);
  });

  test('error 이벤트로 error 전이', () async {
    final b = FakeAudioBackend();
    final c = AudioController(backend: b);
    b.emit(AudioEvent.error);
    await Future<void>.delayed(Duration.zero);
    expect(c.state, PlaybackState.error);
  });

  test('stalled 이벤트는 loading(재버퍼링)으로 전이', () async {
    final b = FakeAudioBackend();
    final c = AudioController(backend: b);
    b.emit(AudioEvent.playing);
    b.emit(AudioEvent.stalled);
    await Future<void>.delayed(Duration.zero);
    expect(c.state, PlaybackState.loading);
  });

  test('dispose 후 이벤트는 상태를 바꾸지 않음(구독 해제)', () async {
    final b = FakeAudioBackend();
    final c = AudioController(backend: b);
    c.dispose();
    b.emit(AudioEvent.playing);
    await Future<void>.delayed(Duration.zero);
    expect(c.state, PlaybackState.idle);
  });

  test('상태 변화 시 리스너에게 알림(ChangeNotifier)', () async {
    final b = FakeAudioBackend();
    final c = AudioController(backend: b);
    var n = 0;
    c.addListener(() => n++);
    c.load('x.mp3'); // idle→loading: 알림
    b.emit(AudioEvent.playing); // →playing: 알림
    await Future<void>.delayed(Duration.zero);
    expect(n, greaterThanOrEqualTo(2));
  });

  test('같은 상태로의 전이는 알리지 않음(불필요 리빌드 방지)', () async {
    final b = FakeAudioBackend();
    final c = AudioController(backend: b);
    b.emit(AudioEvent.playing);
    await Future<void>.delayed(Duration.zero);
    var n = 0;
    c.addListener(() => n++);
    b.emit(AudioEvent.playing); // 이미 playing → 알림 없음
    await Future<void>.delayed(Duration.zero);
    expect(n, 0);
  });
}
