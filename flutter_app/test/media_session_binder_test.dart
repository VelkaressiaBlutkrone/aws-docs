import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/audio_controller.dart';
import 'package:aws_docs/data/media_session_binder.dart';

class _FakeAudioBackend implements AudioBackend {
  final _events = StreamController<AudioEvent>.broadcast();
  int playCalls = 0;
  int pauseCalls = 0;

  @override
  Stream<AudioEvent> get events => _events.stream;
  @override
  void setSrc(String s) {}
  @override
  Future<void> play() async => playCalls++;
  @override
  void pause() => pauseCalls++;
  @override
  void dispose() => _events.close();

  void emit(AudioEvent e) => _events.add(e);
}

class FakeMediaSessionBackend implements MediaSessionBackend {
  final handlers = <MediaAction, void Function()?>{};
  MediaPlaybackState playbackState = MediaPlaybackState.none;
  String? title;
  int clears = 0;

  @override
  void setActionHandler(MediaAction a, void Function()? h) => handlers[a] = h;
  @override
  void setPlaybackState(MediaPlaybackState s) => playbackState = s;
  @override
  void setMetadata({required String title, String? artist}) =>
      this.title = title;
  @override
  void clear() => clears++;

  /// 잠금화면 버튼 누름 모사.
  void invoke(MediaAction a) => handlers[a]?.call();
}

({
  AudioController controller,
  _FakeAudioBackend audio,
  FakeMediaSessionBackend session,
  MediaSessionBinder binder,
}) _wire() {
  final audio = _FakeAudioBackend();
  final controller = AudioController(backend: audio);
  final session = FakeMediaSessionBackend();
  final binder =
      MediaSessionBinder(controller: controller, session: session);
  return (controller: controller, audio: audio, session: session, binder: binder);
}

void main() {
  test('잠금화면 play 액션이 controller.play()를 호출', () {
    final w = _wire();
    w.session.invoke(MediaAction.play);
    expect(w.audio.playCalls, 1);
  });

  test('잠금화면 pause 액션이 controller.pause()를 호출', () {
    final w = _wire();
    w.session.invoke(MediaAction.pause);
    expect(w.audio.pauseCalls, 1);
  });

  test('controller가 playing이면 세션 playbackState=playing 동기화', () async {
    final w = _wire();
    w.audio.emit(AudioEvent.playing);
    await Future<void>.delayed(Duration.zero);
    expect(w.session.playbackState, MediaPlaybackState.playing);
  });

  test('controller가 paused면 세션 playbackState=paused', () async {
    final w = _wire();
    w.audio.emit(AudioEvent.playing);
    w.audio.emit(AudioEvent.paused);
    await Future<void>.delayed(Duration.zero);
    expect(w.session.playbackState, MediaPlaybackState.paused);
  });

  test('setNowPlaying이 세션 메타데이터를 설정', () {
    final w = _wire();
    w.binder.setNowPlaying('CLF-C02 · 도메인 1');
    expect(w.session.title, 'CLF-C02 · 도메인 1');
  });

  test('dispose가 세션을 정리(clear)하고 이후 상태변화를 무시', () async {
    final w = _wire();
    w.binder.dispose();
    expect(w.session.clears, 1);
    w.session.playbackState = MediaPlaybackState.none; // 리셋
    w.audio.emit(AudioEvent.playing);
    await Future<void>.delayed(Duration.zero);
    expect(w.session.playbackState, MediaPlaybackState.none); // listener 제거됨
  });
}
