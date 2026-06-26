/// 학습 문서 오디오 강의("주머니 라디오") M1 — package:web 기반 백엔드(웹 전용).
///
/// [AudioBackend]·[MediaSessionBackend] 의 실제 DOM 구현. 브라우저 의존이라
/// 단위 테스트가 불가하다(상태 로직은 AudioController/Binder 단위로 커버됨).
/// 잠금화면 재생·30초 버그·인터럽션 후 재개는 **실기기에서만 검증**(M1 T6 수동 게이트).
///
/// 웹 전용: VM/flutter test에서 import 금지(package:web은 web/wasm 타겟).
///
/// 출처: docs/superpowers/specs/2026-06-20-study-audio-lecture-review.md (M1 T1)
library;

import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'audio_asset_url.dart';
import 'audio_controller.dart';
import 'media_session_binder.dart';

/// 전역에 단 하나만 두는 DOM `<audio>` 식별자.
/// Flutter 핫리스타트 시 중복 element 누적을 막는다(idempotent 생성).
const _audioElementId = 'awsdocs-audio-el';

/// package:web `<audio>` 기반 [AudioBackend].
class WebAudioBackend implements AudioBackend {
  WebAudioBackend() {
    final existing =
        web.document.getElementById(_audioElementId) as web.HTMLAudioElement?;
    if (existing != null) {
      _audio = existing; // 핫리스타트 — 기존 element 재사용
    } else {
      _audio = (web.document.createElement('audio') as web.HTMLAudioElement)
        ..id = _audioElementId
        ..preload = 'metadata'; // 큰 합친 오디오 초기 로딩 최소화
      web.document.body?.appendChild(_audio);
    }
    _wire('playing', AudioEvent.playing);
    _wire('pause', AudioEvent.paused);
    _wire('ended', AudioEvent.ended);
    _wire('stalled', AudioEvent.stalled);
    _wire('error', AudioEvent.error);
  }

  late final web.HTMLAudioElement _audio;
  final _events = StreamController<AudioEvent>.broadcast();
  final _wired = <(String, web.EventListener)>[];

  void _wire(String type, AudioEvent ev) {
    final listener = ((web.Event _) => _events.add(ev)).toJS;
    _audio.addEventListener(type, listener);
    _wired.add((type, listener));
  }

  @override
  Stream<AudioEvent> get events => _events.stream;

  @override
  // asset 키를 flutter web HTTP URL로 변환해 지정(미변환 시 404 — audio_asset_url.dart).
  void setSrc(String src) => _audio.src = webAudioAssetUrl(src);

  @override
  Future<void> play() async {
    // user-activation 보존: 이 메서드는 사용자 제스처와 같은 동기 진입점에서
    // 호출돼야 하며, play() 앞에 어떤 await도 없다(앞에 끼면 iOS가 차단).
    await _audio.play().toDart;
  }

  @override
  void pause() => _audio.pause();

  @override
  void dispose() {
    for (final (type, listener) in _wired) {
      _audio.removeEventListener(type, listener);
    }
    _wired.clear();
    _events.close();
  }
}

/// package:web `navigator.mediaSession` 기반 [MediaSessionBackend].
class WebMediaSessionBackend implements MediaSessionBackend {
  final web.MediaSession _session = web.window.navigator.mediaSession;

  @override
  void setMetadata({required String title, String? artist}) {
    _session.metadata = web.MediaMetadata(
      web.MediaMetadataInit(title: title, artist: artist ?? ''),
    );
  }

  @override
  void setPlaybackState(MediaPlaybackState state) {
    _session.playbackState = switch (state) {
      MediaPlaybackState.playing => 'playing',
      MediaPlaybackState.paused => 'paused',
      MediaPlaybackState.none => 'none',
    };
  }

  @override
  void setActionHandler(MediaAction action, void Function()? handler) {
    final name = switch (action) {
      MediaAction.play => 'play',
      MediaAction.pause => 'pause',
    };
    // 미지원 액션은 브라우저가 무시(throw 가능) — 방어적으로 감싼다.
    try {
      _session.setActionHandler(
        name,
        handler == null ? null : (() => handler()).toJS,
      );
    } catch (_) {
      // 일부 브라우저에서 미지원 액션은 예외 — 무시.
    }
  }

  @override
  void clear() {
    _session.metadata = null;
    setActionHandler(MediaAction.play, null);
    setActionHandler(MediaAction.pause, null);
  }
}
