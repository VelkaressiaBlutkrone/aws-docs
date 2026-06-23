/// 학습 문서 오디오 강의("주머니 라디오") M1 — 재생 상태 머신.
///
/// DOM `<audio>`/Media Session 같은 브라우저 부수효과는 [AudioBackend] 뒤로 격리해
/// 상태 전이를 단위 테스트할 수 있게 한다. 실제 백엔드(WebAudioBackend, package:web)는
/// 잠금화면 재생을 실기기에서만 검증할 수 있다([[flutter-web-pagetransitions-6keys]]).
///
/// 출처: docs/superpowers/specs/2026-06-20-study-audio-lecture-review.md (M1 T1·T5)
library;

import 'dart:async';

import 'package:flutter/foundation.dart';

/// 플레이어가 노출하는 재생 상태.
///
/// ```
///   idle ──load()──▶ loading ──playing──▶ playing ──paused──▶ paused
///                       ▲                     │
///                       └──────stalled────────┤ (재버퍼링)
///                                             ├─ended──▶ ended
///                                             └─error──▶ error
/// ```
enum PlaybackState { idle, loading, playing, paused, ended, error }

/// 백엔드(브라우저 `<audio>`)가 발화하는 미디어 이벤트.
enum AudioEvent { playing, paused, ended, stalled, error }

/// 재생 백엔드 경계. 실제 구현은 DOM `<audio>`(package:web)를 감싸고,
/// 테스트는 가짜 백엔드를 주입한다.
abstract class AudioBackend {
  /// 소스 URL 설정(아직 재생하지 않음).
  void setSrc(String src);

  /// 재생 시작. iOS user-activation 보존을 위해 호출자는 이 Future를
  /// **사용자 제스처와 같은 동기 진입점에서** 시작해야 한다(앞에 await 체인 금지).
  /// 자동재생 차단 시 reject될 수 있다.
  Future<void> play();

  /// 일시정지.
  void pause();

  /// 백엔드가 발화하는 미디어 이벤트.
  Stream<AudioEvent> get events;

  /// 리소스 정리.
  void dispose();
}

/// 주입된 [AudioBackend] 위에서 재생 상태를 관리하는 컨트롤러.
///
/// M1에서는 전역 싱글톤(위젯 트리 밖)으로 살아 라우팅 전환·위젯 dispose에도
/// 재생을 유지한다. 상태는 backend의 미디어 이벤트로 확정된다(브라우저 비동기 현실 반영).
class AudioController extends ChangeNotifier {
  AudioController({required AudioBackend backend}) : _backend = backend {
    _sub = _backend.events.listen(_onEvent);
  }

  final AudioBackend _backend;
  late final StreamSubscription<AudioEvent> _sub;

  PlaybackState _state = PlaybackState.idle;
  PlaybackState get state => _state;

  /// 소스를 설정하고 로딩 상태로 전이.
  void load(String src) {
    _backend.setSrc(src);
    _set(PlaybackState.loading);
  }

  /// 재생. `backend.play()`를 await 체인 없이 즉시 호출해 user-activation을 보존한다.
  /// 자동재생 차단(reject)되면 error로 전이.
  Future<void> play() async {
    try {
      await _backend.play();
    } catch (_) {
      _set(PlaybackState.error);
    }
  }

  /// 일시정지(상태는 backend의 paused 이벤트로 확정).
  void pause() => _backend.pause();

  void _onEvent(AudioEvent e) {
    _set(switch (e) {
      AudioEvent.playing => PlaybackState.playing,
      AudioEvent.paused => PlaybackState.paused,
      AudioEvent.ended => PlaybackState.ended,
      AudioEvent.stalled => PlaybackState.loading, // 재버퍼링
      AudioEvent.error => PlaybackState.error,
    });
  }

  /// 상태를 바꾸고, 실제로 변경됐을 때만 리스너에 알린다(불필요 리빌드 방지).
  void _set(PlaybackState s) {
    if (_state == s) return;
    _state = s;
    notifyListeners();
  }

  /// 이벤트 구독 해제. 백엔드 리소스 정리는 소유자(전역 싱글톤 셋업) 책임.
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
