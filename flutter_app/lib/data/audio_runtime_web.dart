/// 전역 오디오 런타임 — web 구현(package:web). 웹 전용: VM/test import 금지.
///
/// DOM `<audio>`([WebAudioBackend])와 navigator.mediaSession
/// ([WebMediaSessionBackend])을 [AudioController]·[MediaSessionBinder]로 묶어
/// 위젯 트리 밖 전역 싱글톤으로 둔다. 라우팅 전환·위젯 dispose에도 재생이 유지된다.
/// 잠금화면 연속재생·인터럽션 후 재개는 실기기에서만 검증(M1 T6 수동 게이트).
library;

import 'audio_controller.dart';
import 'audio_runtime.dart';
import 'media_session_binder.dart';
import 'web_audio_backend.dart';

/// 전역 싱글톤(지연 초기화) — 첫 접근 시 1회 생성. audioLectureEnabled일 때만
/// study_doc_page가 접근하므로, dev 플래그가 꺼져 있으면 DOM element도 만들지 않는다.
AudioRuntime? get audioRuntime => _instance ??= _WebAudioRuntime();
_WebAudioRuntime? _instance;

class _WebAudioRuntime implements AudioRuntime {
  _WebAudioRuntime()
      : _controller = AudioController(backend: WebAudioBackend()) {
    // binder 생성만으로 잠금화면 액션 핸들러 등록 + 상태 동기화 리스너가 붙는다.
    _binder = MediaSessionBinder(
      controller: _controller,
      session: WebMediaSessionBackend(),
    );
  }

  final AudioController _controller;
  late final MediaSessionBinder _binder;

  @override
  AudioController get controller => _controller;

  @override
  void nowPlaying(String title) => _binder.setNowPlaying(title);
}
