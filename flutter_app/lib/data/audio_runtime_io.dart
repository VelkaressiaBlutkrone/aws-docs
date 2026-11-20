/// 전역 오디오 런타임 — Android·iOS 구현(just_audio). 로드맵 D1-a.
///
/// 웹의 [audio_runtime_web] 과 **같은 모양**이다: [NativeAudioBackend] 를
/// [AudioController] 에 물리고 [MediaSessionBinder] 로 세션을 잇는다. 위젯 트리 밖
/// 전역 싱글톤이라 라우팅 전환·위젯 dispose 에도 재생이 유지된다.
///
/// ⚠️⚠️ **`dart.library.io` 는 VM 테스트도 고른다.** 그래서 getter 가 플랫폼을 먼저 보고
/// Android·iOS 가 아니면 **null 을 돌려준다** — 그러지 않으면 Windows·CI(Linux)의
/// `flutter test` 가 `AudioPlayer()` 를 만들어 `MissingPluginException` 으로 깨지고,
/// `audioRuntime == null` 에 기대는 기존 가드(`audio_runtime_test.dart` ·
/// `shouldShowLecturePlayer` 의 `hasRuntime`)가 전부 무너진다.
///
/// ⏳ **잠금화면·알림은 D1-b 다.** 지금은 [_NoopMediaSession] 이라 백그라운드 재생과
/// 잠금화면 조작이 없다(화면을 끄면 OS 가 재생을 멈출 수 있다). D1-b 가
/// `audio_service` 기반 세션으로 **이 한 줄만** 교체한다.
library;

import 'dart:io' show Platform;

import 'audio_controller.dart';
import 'audio_runtime.dart';
import 'media_session_binder.dart';
import 'native_audio_backend.dart';

/// 지원 플랫폼에서만 지연 생성. 그 밖(데스크톱·VM 테스트)에서는 null.
AudioRuntime? get audioRuntime {
  if (!nativeAudioSupported(
    isAndroid: Platform.isAndroid,
    isIOS: Platform.isIOS,
  )) {
    return null;
  }
  return _instance ??= _NativeAudioRuntime();
}

_NativeAudioRuntime? _instance;

class _NativeAudioRuntime implements AudioRuntime {
  _NativeAudioRuntime()
      : _controller = AudioController(backend: NativeAudioBackend()) {
    _binder = MediaSessionBinder(
      controller: _controller,
      session: _NoopMediaSession(),
    );
  }

  final AudioController _controller;
  late final MediaSessionBinder _binder;

  @override
  AudioController get controller => _controller;

  @override
  void nowPlaying(String title) => _binder.setNowPlaying(title);
}

/// D1-a 의 자리표시자 — 세션 표면을 **삼키기만** 한다.
///
/// 이것을 두는 이유는 [MediaSessionBinder] 를 지금부터 끼워 두면 D1-b 가 **세션 구현
/// 한 줄만** 갈아끼우면 되기 때문이다(바인더·컨트롤러 배선은 그대로). 실제 잠금화면
/// 메타데이터·액션은 `audio_service` 가 붙는 D1-b 에서 생긴다.
class _NoopMediaSession implements MediaSessionBackend {
  @override
  void setMetadata({required String title, String? artist}) {}

  @override
  void setPlaybackState(MediaPlaybackState state) {}

  @override
  void setActionHandler(MediaAction action, void Function()? handler) {}

  @override
  void clear() {}
}
