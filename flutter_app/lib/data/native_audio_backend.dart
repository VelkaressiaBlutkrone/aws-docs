/// 학습 문서 오디오 강의("주머니 라디오") — Android·iOS 백엔드(just_audio). 로드맵 D1-a.
///
/// [AudioBackend] 의 네이티브 구현. 웹의 [WebAudioBackend](DOM `<audio>`)와 **같은 경계를
/// 구현**하므로 `AudioController`·`MediaSessionBinder`·`LecturePlaylist` 는 한 줄도 바뀌지
/// 않는다. 플랫폼 의존이라 단위 테스트가 불가하고(웹 백엔드와 같은 사정) 실제 재생은
/// **에뮬레이터·실기기 실측**이 판정한다 — 여기서 테스트로 고정하는 것은 아래 두 순수
/// 함수(이벤트 매핑·플랫폼 게이트)다.
///
/// 네이티브 전용: 웹 빌드에서 import 금지(`audio_runtime.dart` 의 조건부 import 가 가른다).
library;

import 'dart:async';

import 'package:just_audio/just_audio.dart';

import 'audio_controller.dart';

/// just_audio 의 `(playing, processingState)` 쌍을 레포의 [AudioEvent] 로 옮긴다.
///
/// `null` 은 **침묵**이다 — `AudioController.load()` 가 이미 `loading` 으로 전이시키므로
/// idle·loading 에서 또 내면 같은 상태를 두 번 알린다.
///
/// ⚠️ **`completed` 를 `playing` 보다 먼저 본다.** just_audio 의 `playing` 은 재생 "의도"라
/// 트랙이 끝난 뒤에도 true 로 남을 수 있다(공식 문서의 `playerStateStream` 예가 두 값을
/// 따로 분기하는 이유다). 순서를 뒤집으면 **끝난 트랙이 계속 재생 중으로 보이고**
/// `LecturePlaylist` 의 자동 다음 트랙(`PlayMode.autoAll`)이 돌지 않는다.
AudioEvent? mapPlayerEvent({
  required bool playing,
  required ProcessingState processing,
}) =>
    switch (processing) {
      ProcessingState.completed => AudioEvent.ended,
      ProcessingState.buffering => AudioEvent.stalled,
      ProcessingState.ready => playing ? AudioEvent.playing : AudioEvent.paused,
      ProcessingState.idle || ProcessingState.loading => null,
    };

/// 네이티브 오디오 런타임을 둘 플랫폼인가.
///
/// ⚠️⚠️ **`flutter test` 가 이 분기를 고른다.** 조건부 import 의 `dart.library.io` 는
/// VM·데스크톱·모바일을 전부 포함하므로, 이 게이트가 없으면 **Windows·CI(Linux)의 VM
/// 테스트가 `AudioPlayer()` 를 만들어 `MissingPluginException`** 으로 깨진다.
/// just_audio 가 데스크톱도 지원하지만 이 앱의 대상이 아니다.
///
/// 판정을 `Platform.isAndroid` 로 직접 쓰지 않고 순수 함수로 빼는 이유는 **VM 에서는 그것이
/// 영원히 false 라 한쪽 분기만 증명되기** 때문이다(레포 관례 — `shouldShowLecturePlayer`).
bool nativeAudioSupported({required bool isAndroid, required bool isIOS}) =>
    isAndroid || isIOS;

/// just_audio [AudioPlayer] 기반 [AudioBackend].
class NativeAudioBackend implements AudioBackend {
  /// [player] 주입은 테스트·대체 구현용이다(기본은 새 `AudioPlayer`).
  NativeAudioBackend({AudioPlayer? player})
      : _player = player ?? AudioPlayer() {
    _stateSub = _player.playerStateStream.listen(
      (s) {
        final e = mapPlayerEvent(
          playing: s.playing,
          processing: s.processingState,
        );
        // 같은 이벤트를 연달아 내지 않는다(스트림을 깨끗이 — 컨트롤러도 같은 상태는
        // 무시하지만, 중복이 쌓이면 로그·디버깅에서 신호가 묻힌다).
        if (e != null && e != _last) {
          _last = e;
          _events.add(e);
        }
      },
      onError: (Object _) => _events.add(AudioEvent.error),
    );
    _posSub = _player.positionStream.listen(_position.add);
  }

  final AudioPlayer _player;
  late final StreamSubscription<PlayerState> _stateSub;
  late final StreamSubscription<Duration> _posSub;
  final _events = StreamController<AudioEvent>.broadcast();
  final _position = StreamController<Duration>.broadcast();
  AudioEvent? _last;

  @override
  Stream<AudioEvent> get events => _events.stream;

  @override
  Stream<Duration> get positionStream => _position.stream;

  @override
  Duration? get duration => _player.duration;

  /// 승인된 강의는 **R2 절대 URL** 이다(`ContentEntry.lectureAudioSrc` —
  /// `{base}/{family}/{taskId}/{sha8}/lecture.mp3`). 미승인은 번들 asset 경로가 오지만
  /// 노출 게이트(`shouldShowLecturePlayer`)가 막고 있고 **mp3 는 `.gitignore` 라 번들에도
  /// 없으므로**(m-6 판정) 실제로 이 경로로 오지 않는다 — 그래도 조용히 죽지 않게 다룬다.
  @override
  void setSrc(String src) => unawaited(_setSrc(src));

  Future<void> _setSrc(String src) async {
    try {
      if (src.startsWith('https://') || src.startsWith('http://')) {
        await _player.setUrl(src);
      } else {
        await _player.setAsset(src);
      }
    } catch (_) {
      // 네트워크·404·코덱 실패 — 컨트롤러가 error 상태로 가 UI 가 알린다.
      _events.add(AudioEvent.error);
    }
  }

  /// ⚠️⚠️ **`_player.play()` 를 await 하지 않는다.** just_audio 의 `play()` 는 공식 문서가
  /// 적는 대로 **재생이 끝날 때까지** 완료되지 않는 Future 다(「Play while waiting for
  /// completion」). `AudioController.play()` 가 이 Future 를 await 하므로 그대로 두면
  /// **트랙 하나가 끝날 때까지 호출이 매달린다.** 웹의 `<audio>.play()` 는 "재생 시작"
  /// Promise 라 사정이 다르다 — 같은 인터페이스 뒤에서 의미가 갈리는 자리다.
  ///
  /// 그래서 즉시 반환하고 실패는 **이벤트로** 알린다(컨트롤러의 try/catch 로는 못 잡는다).
  @override
  Future<void> play() async {
    unawaited(
      _player.play().catchError((Object _) => _events.add(AudioEvent.error)),
    );
  }

  @override
  void pause() => unawaited(_player.pause());

  @override
  void seek(double seconds) => unawaited(
        _player.seek(Duration(milliseconds: (seconds * 1000).round())),
      );

  @override
  void dispose() {
    unawaited(_stateSub.cancel());
    unawaited(_posSub.cancel());
    unawaited(_player.dispose());
    _events.close();
    _position.close();
  }
}
