/// 학습 문서 오디오 강의("주머니 라디오") — 미디어 세션(audio_service). 로드맵 D1-b.
///
/// D1-a 가 끼워 둔 `_NoopMediaSession` 자리에 들어가는 **실제 세션**이다. 이 파일이 하는 일은
/// 레포의 3-상태 세션 모델([MediaPlaybackState])을 audio_service 의 `PlaybackState`·`MediaItem`
/// 으로 옮기고, 잠금화면·알림·헤드셋이 보내는 play/pause 를 [MediaSessionBinder] 가 등록한
/// 콜백으로 되돌리는 것뿐이다 — `AudioController`·`MediaSessionBinder`·`LecturePlaylist` 는
/// 한 줄도 바뀌지 않는다.
///
/// ⚠️ **이름이 겹친다.** 레포의 [MediaAction](play/pause)·[MediaPlaybackState] 와 audio_service 의
/// `MediaAction`·`PlaybackState` 가 서로 다른 타입이므로 audio_service 쪽을 `svc.` 로 별칭한다.
///
/// ⚠️ 이 파일은 플랫폼 채널에 닿지 않는다(닿는 것은 `AudioService.init` 뿐이고 그것은
/// `audio_runtime_io.dart` 가 부른다) — 그래서 `test/audio_service_session_test.dart` 가 VM 에서
/// 매핑·핸들러·백엔드를 전부 검증한다. 네이티브 전용 파일이지만 **웹 빌드에 들어가도 컴파일은
/// 되고**, 들어가지 않는 것은 `audio_runtime.dart` 의 조건부 import 가 가르기 때문이다.
library;

import 'package:audio_service/audio_service.dart' as svc;

import '../util/legal_links.dart' show kAppDisplayName;
import 'media_session_binder.dart';

/// 미디어 알림 채널 ID.
///
/// ⚠️⚠️ **릴리스 뒤에 바꾸면 두 번째 채널이 생긴다**(공식 문서: "Changing it after release
/// creates a second channel") — 사용자가 끈 알림 설정이 옛 채널에 남는다. 그래서 패키지
/// 이름(`applicationId`)에 묶어 고정하고 `test/android_audio_service_manifest_test.dart` 가
/// Gradle 의 `applicationId` 와 맞댄다.
const String kLectureNotificationChannelId =
    'kr.ai.leva.awsdocs.channel.lecture';

/// 알림 채널의 사용자에게 보이는 이름(설정 → 앱 → 알림에 그대로 나온다).
const String kLectureNotificationChannelName = '강의 재생';

/// 알림·잠금화면의 small icon.
///
/// ⚠️⚠️ **런처 아이콘(`mipmap/ic_launcher`, 패키지 기본값)을 쓰면 안 된다.** 안드로이드는
/// small icon 의 **알파 채널만** 쓰고 그것을 강조색으로 칠하는데, 런처 아이콘은 사각형
/// 전체가 불투명해 잠금화면 미디어 카드에 **글리프 없는 단색 원**으로 나온다(2026-11-21
/// 에뮬레이터 실측). `ic_stat_lecture` 는 배경 없이 흰 'A' 만 그린 자산이다
/// (`tool/make_app_icon.py --notification`).
///
/// ⚠️ 이 문자열도 런타임 이름 조회(`getIdentifier`)로 가므로 `res/raw/keep.xml` 이 지켜야
/// 릴리스 빌드에서 지워지지 않는다.
const String kLectureNotificationIcon = 'drawable/ic_stat_lecture';

/// 레포의 3-상태 세션 모델을 audio_service `PlaybackState` 로 옮긴다.
///
/// 버튼 구성이 상태마다 다른 이유:
/// - **stop 을 항상 함께 둔다** — `androidStopForegroundOnPause: false` 로 두면 일시정지 중에도
///   서비스가 포그라운드로 남아 **알림을 스와이프로 치울 수 없다.** stop 이 없으면 사용자가
///   알림을 없앨 방법이 사라진다(그 설정과 이 버튼은 쌍이다).
/// - **none 에서는 버튼을 비운다** — `idle` 이 알림을 내리는 신호다(공식 문서: "setting the
///   processing state to idle ... disables the system notification").
///
/// ⚠️ 탐색 바(`systemActions: {seek}`)는 두지 않았다. 이 세션 경계에는 위치를 싣는 길이 없어
/// (M1 의 `MediaSessionBackend` 는 메타데이터·상태·play/pause 뿐) 바를 켜면 **먹지 않는
/// 조작과 0 에 멈춘 위치**를 보여 주게 된다.
svc.PlaybackState mapSessionPlaybackState(MediaPlaybackState state) =>
    switch (state) {
      MediaPlaybackState.playing => svc.PlaybackState(
          controls: const [svc.MediaControl.pause, svc.MediaControl.stop],
          processingState: svc.AudioProcessingState.ready,
          playing: true,
        ),
      MediaPlaybackState.paused => svc.PlaybackState(
          controls: const [svc.MediaControl.play, svc.MediaControl.stop],
          processingState: svc.AudioProcessingState.ready,
          playing: false,
        ),
      MediaPlaybackState.none => svc.PlaybackState(
          controls: const [],
          processingState: svc.AudioProcessingState.idle,
          playing: false,
        ),
    };

/// 미디어 세션을 열 플랫폼·빌드인가.
///
/// ⚠️⚠️ **`dart.library.io` 분기는 `flutter test` 도 고른다** — 게이트가 없으면 VM 테스트가
/// `AudioService.init` 을 불러 플랫폼 채널에 닿는다. 판정을 `Platform.isAndroid` 로 직접
/// 쓰지 않고 순수 함수로 빼는 이유는 VM 에서 그것이 영원히 false 라 한쪽 분기만 증명되기
/// 때문이다(레포 관례 — `shouldShowLecturePlayer`·`nativeAudioSupported`).
///
/// [enabled] 는 `audioLectureEnabled`(dart-define)다. 강의가 노출되지 않는 빌드에서 미디어
/// 알림과 포그라운드 서비스를 띄우지 않는다.
bool shouldInitAudioSession({
  required bool enabled,
  required bool isAndroid,
  required bool isIOS,
}) =>
    enabled && (isAndroid || isIOS);

/// audio_service 가 OS 쪽에서 부르는 핸들러.
///
/// 상태 머신을 들고 있지 않다 — 그것은 [AudioController] 의 일이고, 여기서는 [MediaSessionBinder]
/// 가 등록한 콜백으로 되돌릴 뿐이다. `BaseAudioHandler` 의 `playbackState`·`mediaItem` 은
/// `BehaviorSubject.seeded` 라 **새 구독자에게 최신 값을 다시 주므로**, `AudioService.init`
/// (비동기)이 이 객체의 스트림을 늦게 구독해도 먼저 쓴 값이 알림에 반영된다.
class LectureAudioHandler extends svc.BaseAudioHandler {
  final _actions = <MediaAction, void Function()>{};

  /// [stop] 이 시작될 때 불린다 — [AudioServiceSessionBackend] 가 「알림을 닫았다」 래치를
  /// 세우는 자리다. 핸들러가 백엔드를 알지 않게 콜백으로 둔다.
  void Function()? onStop;

  /// [MediaSessionBackend.setActionHandler] 가 거쳐 가는 자리. null 이면 해제한다.
  void setAction(MediaAction action, void Function()? handler) {
    if (handler == null) {
      _actions.remove(action);
    } else {
      _actions[action] = handler;
    }
  }

  @override
  Future<void> play() async {
    _actions[MediaAction.play]?.call();
  }

  @override
  Future<void> pause() async {
    _actions[MediaAction.pause]?.call();
  }

  /// 재생을 멈추고 알림을 내린다.
  ///
  /// ⚠️⚠️ **idle 을 먼저 실어야 한다.** `BaseAudioHandler.stop()` 의 기본 구현은
  /// `playbackState.firstWhere(processingState == idle)` 을 await 하는데, 우리 바인더는
  /// 컨트롤러 상태(playing·paused·none)에서만 state 를 만들고 **멈춤을 idle 로 내보내는
  /// 경로가 없다** — 그대로 super 를 부르면 영원히 완료되지 않는다. 먼저 실어 두면 super 의
  /// `firstWhere` 가 즉시 완료되고, super 를 그래도 부르는 것은 상류가 기본 `stop` 에 정리
  /// 로직을 더할 때 따라가기 위해서다(공식 문서가 "may be overridden" 으로 허용한다).
  ///
  /// ⚠️⚠️ **[onStop] 래치가 먼저다.** 일시정지는 백엔드(just_audio)를 거쳐 **비동기로**
  /// `paused` 이벤트를 돌려주므로, 래치가 없으면 그 이벤트가 바로 아래에서 실은 idle 을
  /// **덮어써 알림이 되살아난다**(2026-11-21 에뮬레이터 실측: 소리는 멈췄는데 치울 수 없는
  /// 알림이 `PAUSED` 로 남았다).
  @override
  Future<void> stop() async {
    onStop?.call();
    _actions[MediaAction.pause]?.call();
    playbackState.add(mapSessionPlaybackState(MediaPlaybackState.none));
    await super.stop();
  }
}

/// [MediaSessionBackend] 의 audio_service 구현 — `_NoopMediaSession` 을 대체한다.
class AudioServiceSessionBackend implements MediaSessionBackend {
  AudioServiceSessionBackend(this._handler) {
    _handler.onStop = () => _dismissed = true;
  }

  final LectureAudioHandler _handler;

  /// 사용자가 알림을 닫았는가(stop). 뒤늦게 도착하는 `paused` 가 알림을 되살리지 않게
  /// 막고, **실제로 재생이 다시 시작될 때만** 풀린다.
  bool _dismissed = false;

  /// ⚠️ `MediaItem.id` 는 필수다. 우리는 큐를 쓰지 않아(한 번에 한 트랙) 식별자가 트랙
  /// 안에서만 안정하면 되므로 제목을 그대로 쓴다. [artist] 가 없으면 앱 이름을 넣는다 —
  /// 호출부(`AudioRuntime.nowPlaying`)가 제목만 주고, 잠금화면 둘째 줄을 비워 두면
  /// 「무엇을 재생하는지」가 반쪽만 보인다.
  @override
  void setMetadata({required String title, String? artist}) =>
      _handler.mediaItem.add(svc.MediaItem(
        id: title,
        title: title,
        artist: artist ?? kAppDisplayName,
      ));

  @override
  void setPlaybackState(MediaPlaybackState state) {
    if (_dismissed) {
      // 닫은 알림은 **다시 재생될 때만** 돌아온다. 그 사이의 paused·none 은 무시한다.
      if (state != MediaPlaybackState.playing) return;
      _dismissed = false;
    }
    _handler.playbackState.add(mapSessionPlaybackState(state));
  }

  @override
  void setActionHandler(MediaAction action, void Function()? handler) =>
      _handler.setAction(action, handler);

  @override
  void clear() {
    _handler
      ..setAction(MediaAction.play, null)
      ..setAction(MediaAction.pause, null)
      ..mediaItem.add(null)
      ..playbackState.add(mapSessionPlaybackState(MediaPlaybackState.none));
  }
}
