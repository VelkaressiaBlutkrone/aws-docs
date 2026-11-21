/// 전역 오디오 런타임 — Android·iOS 구현(just_audio + audio_service). 로드맵 D1.
///
/// 웹의 [audio_runtime_web] 과 **같은 모양**이다: [NativeAudioBackend] 를 [AudioController] 에
/// 물리고 [MediaSessionBinder] 로 세션을 잇는다. 위젯 트리 밖 전역 싱글톤이라 라우팅 전환·
/// 위젯 dispose 에도 재생이 유지된다.
///
/// ⚠️⚠️ **`dart.library.io` 는 VM 테스트도 고른다.** 그래서 getter 가 플랫폼을 먼저 보고
/// Android·iOS 가 아니면 **null 을 돌려준다** — 그러지 않으면 Windows·CI(Linux)의
/// `flutter test` 가 `AudioPlayer()` 를 만들어 `MissingPluginException` 으로 깨지고,
/// `audioRuntime == null` 에 기대는 기존 가드(`audio_runtime_test.dart` ·
/// `shouldShowLecturePlayer` 의 `hasRuntime`)가 전부 무너진다. [initAudioSession] 도 같은
/// 이유로 게이트를 지난다.
library;

import 'dart:io' show Platform;

import 'package:audio_service/audio_service.dart' as svc;

import '../app_errors.dart' show appLog;
import 'audio_controller.dart';
import 'audio_runtime.dart';
import 'audio_service_session.dart';
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

/// 미디어 세션 핸들러.
///
/// ⚠️ **런타임보다 먼저 만들어질 수도, 나중일 수도 있다.** [initAudioSession] 은 `main()` 이
/// 첫 프레임 앞에서 부르고 런타임은 미니 플레이어가 처음 접근할 때 생긴다 — 둘 다 이
/// 지연 초기화 final 을 집으므로 **같은 인스턴스**를 보고, 순서가 뒤집혀도 안전하다
/// (`BaseAudioHandler` 의 스트림이 `BehaviorSubject.seeded` 라 늦은 구독자도 최신 값을 받는다).
final LectureAudioHandler _handler = LectureAudioHandler();

bool _sessionInitStarted = false;

/// 미디어 세션(잠금화면·알림·헤드셋)을 연다. 한 번만 유효하다.
///
/// ⚠️ **await 하지 않고 부른다**(`main()` 참조) — 첫 프레임을 늦추지 않기 위해서다. 실패는
/// 여기서 삼키고 로그만 남긴다: 세션이 없어도 **앱 안에서의 재생은 그대로 동작**하고
/// (D1-a), 매니페스트가 틀리면 `AudioService.init` 이 `PlatformException` 을 던진다.
Future<void> initAudioSession() async {
  if (!shouldInitAudioSession(
    enabled: audioLectureEnabled,
    isAndroid: Platform.isAndroid,
    isIOS: Platform.isIOS,
  )) {
    return;
  }
  // 패키지가 `assert(_cacheManager == null)` 로 재호출을 막는다 — 핫리스타트·중복 호출에서
  // 디버그 빌드가 죽지 않게 우리 쪽에서 먼저 막는다.
  if (_sessionInitStarted) return;
  _sessionInitStarted = true;

  try {
    await svc.AudioService.init(
      builder: () => _handler,
      config: const svc.AudioServiceConfig(
        androidNotificationChannelId: kLectureNotificationChannelId,
        androidNotificationChannelName: kLectureNotificationChannelName,
        androidNotificationIcon: kLectureNotificationIcon,
        // ⚠️⚠️ Android 12+ 는 백그라운드에서 포그라운드 서비스를 **재시작할** 권한이 없으면
        // `ForegroundServiceStartNotAllowedException` 을 던진다. 일시정지 중에도 서비스를
        // 포그라운드로 두면 그 재시작이 아예 필요 없다 — 공식 문서가 권하는 쪽이다.
        //
        // ⚠️ **양쪽을 다 실측했고 관측 가능한 차이가 없었다**(2026-11-21, API 36 에뮬레이터):
        // `true`(패키지 기본값)로 바꿔도 일시정지·정지 뒤 `isForeground=true` 와
        // `flags=NO_CLEAR|FOREGROUND_SERVICE` 가 그대로였다. 플러그인의 `stop()` 이
        // `stopSelf()` 만 부르는데 **Flutter 엔진이 서비스에 바인딩돼 있어 `onDestroy()`(거기서
        // `stopForeground` 한다)가 돌지 않기** 때문이다. 구별이 안 되므로 **문서 권장값**을
        // 쓴다 — 재개 시점의 예외 위험이 없는 쪽이다.
        androidStopForegroundOnPause: false,
        // `androidNotificationOngoing` 은 건드리지 않는다 — 패키지가
        // `androidStopForegroundOnPause == true` 를 전제로 assert 하므로 위 설정과 함께
        // 켤 수 없다(기본 false).
      ),
    );
  } catch (e, st) {
    appLog('오디오 세션 init 실패 — 잠금화면 없이 재생만 동작: $e\n$st');
  }
}

class _NativeAudioRuntime implements AudioRuntime {
  _NativeAudioRuntime()
      : _controller = AudioController(backend: NativeAudioBackend()) {
    _binder = MediaSessionBinder(
      controller: _controller,
      session: AudioServiceSessionBackend(_handler),
    );
  }

  final AudioController _controller;
  late final MediaSessionBinder _binder;

  @override
  AudioController get controller => _controller;

  @override
  void nowPlaying(String title) => _binder.setNowPlaying(title);
}
