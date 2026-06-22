/// 학습 문서 오디오 강의("주머니 라디오") M1 — Media Session(잠금화면 컨트롤) 바인딩.
///
/// `navigator.mediaSession` 같은 브라우저 부수효과는 [MediaSessionBackend] 경계
/// 뒤로 격리해 단위 테스트한다. 실제 백엔드(WebMediaSessionBackend, package:web)는
/// 잠금화면 표시·동작을 실기기에서만 검증할 수 있다.
///
/// 출처: docs/superpowers/specs/2026-06-20-study-audio-lecture-review.md (M1 T2)
library;

import 'audio_controller.dart';

/// 잠금화면/헤드셋이 보내는 미디어 액션(M1 핵심: play/pause).
/// 헤드셋·블루투스·Control Center 세부 액션은 M2.
enum MediaAction { play, pause }

/// 잠금화면에 반영되는 재생 상태.
enum MediaPlaybackState { none, playing, paused }

/// Media Session 경계. 실제 구현은 `navigator.mediaSession`(package:web)을 감싸고,
/// 테스트는 가짜 백엔드를 주입한다.
abstract class MediaSessionBackend {
  /// 잠금화면에 표시할 메타데이터(제목 등).
  void setMetadata({required String title, String? artist});

  /// 잠금화면 재생 표시 상태.
  void setPlaybackState(MediaPlaybackState state);

  /// 액션 핸들러 등록(null이면 해제). 일부 액션은 미지원으로 무시될 수 있다.
  void setActionHandler(MediaAction action, void Function()? handler);

  /// 메타데이터·핸들러 정리.
  void clear();
}

/// [AudioController] 와 [MediaSessionBackend] 를 잇는다.
/// - 잠금화면 액션(play/pause) → controller
/// - controller 상태 변화 → 세션 playbackState 동기화
class MediaSessionBinder {
  MediaSessionBinder({
    required AudioController controller,
    required MediaSessionBackend session,
  })  : _controller = controller,
        _session = session {
    _session.setActionHandler(MediaAction.play, () => _controller.play());
    _session.setActionHandler(MediaAction.pause, _controller.pause);
    _controller.addListener(_sync);
  }

  final AudioController _controller;
  final MediaSessionBackend _session;

  /// 잠금화면에 표시할 제목(문서명 등) 설정.
  void setNowPlaying(String title) => _session.setMetadata(title: title);

  void _sync() {
    _session.setPlaybackState(switch (_controller.state) {
      PlaybackState.playing => MediaPlaybackState.playing,
      PlaybackState.paused => MediaPlaybackState.paused,
      _ => MediaPlaybackState.none,
    });
  }

  /// 바인딩 해제 + 세션 정리(핸들러 제거·메타 클리어).
  void dispose() {
    _controller.removeListener(_sync);
    _session.setActionHandler(MediaAction.play, null);
    _session.setActionHandler(MediaAction.pause, null);
    _session.clear();
  }
}
