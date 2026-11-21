// Android 백그라운드 재생·잠금화면 세션 가드 (D1-b, 2026-11-21).
//
// D1-a 가 `_NoopMediaSession`(세션 표면을 삼키기만 하는 자리표시자)을 끼워 뒀고, 이 PR 이
// 그 **한 줄을** `audio_service` 구현으로 갈아끼운다. `AudioController`·`MediaSessionBinder`·
// `LecturePlaylist` 는 또 한 줄도 바뀌지 않는다.
//
// ⚠️⚠️ **`audio_service` 의 모델 클래스는 VM 테스트에서 쓸 수 있다.** `audio_service.dart` 의
// import 는 `dart:async`·`dart:isolate`·`dart:ui`·flutter foundation/material/services ·
// `audio_session`·`clock`·`flutter_cache_manager`·`rxdart` 뿐이고 `flutter_web_plugins` 가
// 없다(패키지 소스 실측). 플랫폼 채널은 `AudioService.init` 같은 **호출 시점**에만 닿으므로
// `PlaybackState`·`MediaItem`·`BaseAudioHandler` 는 여기서 그대로 검증한다 —
// `NativeAudioBackend`(just_audio) 와 갈리는 지점이다.
//
// ⚠️ 이름이 겹친다 — 레포의 `MediaAction`(play/pause)·`MediaPlaybackState` 와 audio_service 의
// `MediaAction`·`PlaybackState` 가 서로 다른 타입이다. 그래서 audio_service 쪽을 `svc.` 로
// 별칭한다(구현 파일도 같은 규칙).
import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart' as svc;
import 'package:aws_docs/data/audio_controller.dart';
import 'package:aws_docs/data/audio_runtime.dart';
import 'package:aws_docs/data/audio_service_session.dart';
import 'package:aws_docs/data/content_index.dart';
import 'package:aws_docs/data/lecture_playlist.dart';
import 'package:aws_docs/data/media_session_binder.dart';
import 'package:flutter_test/flutter_test.dart';

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
  @override
  void seek(double seconds) {}
  @override
  Stream<Duration> get positionStream => const Stream<Duration>.empty();
  @override
  Duration? get duration => null;

  void emit(AudioEvent e) => _events.add(e);
}

void main() {
  group('D1-b 세션 상태 매핑', () {
    test('대조군: 구현 파일을 읽었고 MediaSessionBackend 를 구현한다', () {
      // `native_audio_backend_test` 와 같은 이유로 둔다 — 추출·import 가 깨져 테스트가
      // 공허해지는 것을 먼저 막는다.
      final s = AudioServiceSessionBackend(LectureAudioHandler());
      expect(s, isA<MediaSessionBackend>());
    });

    test('playing → ready·playing·[pause, stop]', () {
      final s = mapSessionPlaybackState(MediaPlaybackState.playing);
      expect(s.processingState, svc.AudioProcessingState.ready);
      expect(s.playing, isTrue);
      expect(s.controls, [svc.MediaControl.pause, svc.MediaControl.stop]);
    });

    test('paused → ready·!playing·[play, stop]', () {
      final s = mapSessionPlaybackState(MediaPlaybackState.paused);
      expect(s.processingState, svc.AudioProcessingState.ready);
      expect(s.playing, isFalse);
      expect(s.controls, [svc.MediaControl.play, svc.MediaControl.stop]);
    });

    test('none → idle·버튼 없음 (알림이 사라지는 상태)', () {
      // ⚠️ `idle` 이 **알림을 내리는** 신호다(audio_service 문서: "setting the processing
      // state to idle ... disables the system notification"). 그래서 none 에서 버튼을
      // 남겨 두면 안 된다.
      final s = mapSessionPlaybackState(MediaPlaybackState.none);
      expect(s.processingState, svc.AudioProcessingState.idle);
      expect(s.playing, isFalse);
      expect(s.controls, isEmpty);
    });

    test('모든 상태에 stop 버튼이 있거나 알림이 없다', () {
      // ⚠️⚠️ `androidStopForegroundOnPause: false` 로 두면 일시정지 중에도 서비스가
      // 포그라운드로 남아 **알림을 스와이프로 치울 수 없다.** 그래서 stop 버튼이 없으면
      // 사용자가 알림을 없앨 방법이 사라진다 — 그 둘은 쌍으로 묶여 있다.
      for (final st in MediaPlaybackState.values) {
        final s = mapSessionPlaybackState(st);
        expect(
          s.controls.contains(svc.MediaControl.stop) ||
              s.processingState == svc.AudioProcessingState.idle,
          isTrue,
          reason: '$st',
        );
      }
    });
  });

  group('D1-b 핸들러 — 잠금화면 액션', () {
    test('play·pause 가 등록된 콜백을 부른다', () {
      final h = LectureAudioHandler();
      var plays = 0, pauses = 0;
      h.setAction(MediaAction.play, () => plays++);
      h.setAction(MediaAction.pause, () => pauses++);

      h.play();
      h.pause();
      expect(plays, 1);
      expect(pauses, 1);
    });

    test('핸들러가 없으면 조용히 아무것도 하지 않는다', () {
      // 바인더 dispose 뒤에도 OS 가 버튼을 보낼 수 있다(미디어 버튼·헤드셋).
      final h = LectureAudioHandler();
      h.setAction(MediaAction.play, () => fail('해제된 핸들러가 불렸다'));
      h.setAction(MediaAction.play, null);
      expect(h.play(), completes);
    });

    test('stop 은 재생을 멈추고 알림을 내린다(idle)', () async {
      // ⚠️⚠️ **먼저 idle 을 실어야 한다.** `BaseAudioHandler.stop()` 의 기본 구현은
      // `playbackState.firstWhere(processingState == idle)` 을 await 하는데, 우리 바인더는
      // 컨트롤러 상태에서만 state 를 만들고 **idle 을 내보내는 경로가 없다** — 그대로
      // super 를 부르면 영원히 완료되지 않는다.
      final h = LectureAudioHandler();
      var pauses = 0;
      h.setAction(MediaAction.pause, () => pauses++);

      await h.stop().timeout(const Duration(seconds: 1));
      expect(pauses, 1);
      expect(h.playbackState.value.processingState,
          svc.AudioProcessingState.idle);
    });

    test('헤드셋 단일 클릭이 재생 상태에 따라 갈린다', () {
      // audio_service 의 `click()` 기본 구현이 `playbackState.playing` 을 보고 play/pause 를
      // 고른다 — 우리 playbackState 가 정확해야 공짜로 따라온다.
      final h = LectureAudioHandler();
      var plays = 0, pauses = 0;
      h.setAction(MediaAction.play, () => plays++);
      h.setAction(MediaAction.pause, () => pauses++);

      h.playbackState.add(mapSessionPlaybackState(MediaPlaybackState.paused));
      h.click();
      expect([plays, pauses], [1, 0]);

      h.playbackState.add(mapSessionPlaybackState(MediaPlaybackState.playing));
      h.click();
      expect([plays, pauses], [1, 1]);
    });
  });

  group('D1-b 세션 백엔드 — 핸들러 스트림에 싣는다', () {
    test('setMetadata → mediaItem 에 제목이 실리고 artist 는 앱 이름이다', () {
      final h = LectureAudioHandler();
      AudioServiceSessionBackend(h).setMetadata(title: 'CLF 1-1 클라우드 개념');

      final item = h.mediaItem.value;
      expect(item, isNotNull);
      expect(item!.title, 'CLF 1-1 클라우드 개념');
      // 잠금화면의 둘째 줄 — 호출부(`nowPlaying`)는 artist 를 주지 않으므로 세션이 정한다.
      expect(item.artist, '구름사다리');
    });

    test('setMetadata 의 artist 가 주어지면 그것을 쓴다', () {
      final h = LectureAudioHandler();
      AudioServiceSessionBackend(h).setMetadata(title: 'T', artist: 'A');
      expect(h.mediaItem.value!.artist, 'A');
    });

    test('setPlaybackState → playbackState 에 매핑이 실린다', () {
      final h = LectureAudioHandler();
      final s = AudioServiceSessionBackend(h);

      s.setPlaybackState(MediaPlaybackState.playing);
      expect(h.playbackState.value.playing, isTrue);
      s.setPlaybackState(MediaPlaybackState.paused);
      expect(h.playbackState.value.playing, isFalse);
      expect(h.playbackState.value.processingState,
          svc.AudioProcessingState.ready);
    });

    test('clear 가 액션을 떼고 알림을 내린다', () {
      final h = LectureAudioHandler();
      final s = AudioServiceSessionBackend(h);
      s.setActionHandler(MediaAction.play, () => fail('clear 뒤에 핸들러가 불렸다'));
      s.setMetadata(title: 'T');
      s.setPlaybackState(MediaPlaybackState.playing);

      s.clear();
      h.play();
      expect(h.mediaItem.value, isNull);
      expect(h.playbackState.value.processingState,
          svc.AudioProcessingState.idle);
    });

    test('stop 뒤에 뒤늦게 온 paused 가 알림을 되살리지 않는다', () {
      // ⚠️⚠️ 2026-11-21 실측 결함: stop 이 부른 일시정지는 just_audio 를 거쳐 **비동기로**
      // `paused` 를 돌려주므로, 래치가 없으면 그 이벤트가 방금 실은 idle 을 덮어써
      // **소리는 멈췄는데 치울 수 없는 알림이 PAUSED 로 남는다**.
      final h = LectureAudioHandler();
      final s = AudioServiceSessionBackend(h);
      s.setPlaybackState(MediaPlaybackState.playing);

      h.stop();
      expect(h.playbackState.value.processingState,
          svc.AudioProcessingState.idle);

      s.setPlaybackState(MediaPlaybackState.paused); // 뒤늦은 이벤트
      expect(h.playbackState.value.processingState,
          svc.AudioProcessingState.idle,
          reason: 'stop 뒤 paused 가 알림을 되살렸다');
    });

    test('stop 뒤 다시 재생하면 알림이 돌아온다', () {
      final h = LectureAudioHandler();
      final s = AudioServiceSessionBackend(h);
      h.stop();
      s.setPlaybackState(MediaPlaybackState.paused);
      expect(h.playbackState.value.playing, isFalse);

      s.setPlaybackState(MediaPlaybackState.playing);
      expect(h.playbackState.value.playing, isTrue);
      expect(h.playbackState.value.processingState,
          svc.AudioProcessingState.ready);

      // 래치가 풀렸으므로 그 뒤의 일시정지는 정상으로 반영된다.
      s.setPlaybackState(MediaPlaybackState.paused);
      expect(h.playbackState.value.processingState,
          svc.AudioProcessingState.ready);
      expect(h.playbackState.value.playing, isFalse);
    });

    test('init 보다 먼저 쓴 값이 보존된다 (BehaviorSubject seeded 계약)', () {
      // ⚠️ 런타임은 **동기** getter 라 `AudioService.init`(비동기)을 기다릴 수 없다. 순서가
      // 뒤집혀도 안전한 근거는 `BaseAudioHandler` 의 `playbackState`·`mediaItem` 이
      // `BehaviorSubject.seeded` 라서 **새 구독자에게 최신 값을 다시 준다**는 것이다
      // (패키지 소스 실측). 이 계약이 깨지면 init 이 늦은 기기에서 알림이 비어 보인다.
      final h = LectureAudioHandler();
      AudioServiceSessionBackend(h)
        ..setMetadata(title: '먼저 쓴 제목')
        ..setPlaybackState(MediaPlaybackState.playing);

      // init 이 하는 일 = 스트림 구독. 늦게 붙어도 최신 값이 온다.
      expect(h.playbackState.first, completion(isA<svc.PlaybackState>()));
      expect(h.mediaItem.value!.title, '먼저 쓴 제목');
    });
  });

  group('D1-b 바인더 통합 — 기존 배선이 그대로 흐른다', () {
    test('컨트롤러 상태 변화가 잠금화면 상태로 흐른다', () async {
      final audio = _FakeAudioBackend();
      final controller = AudioController(backend: audio);
      final handler = LectureAudioHandler();
      MediaSessionBinder(
        controller: controller,
        session: AudioServiceSessionBackend(handler),
      );
      addTearDown(audio.dispose);

      // 백엔드 이벤트는 스트림이라 한 틱 뒤에 컨트롤러에 닿는다.
      audio.emit(AudioEvent.playing);
      await pumpEventQueue();
      expect(handler.playbackState.value.playing, isTrue);

      audio.emit(AudioEvent.paused);
      await pumpEventQueue();
      expect(handler.playbackState.value.playing, isFalse);
      expect(handler.playbackState.value.controls,
          contains(svc.MediaControl.play));
    });

    test('잠금화면 버튼이 컨트롤러를 움직인다', () {
      final audio = _FakeAudioBackend();
      final controller = AudioController(backend: audio);
      final handler = LectureAudioHandler();
      MediaSessionBinder(
        controller: controller,
        session: AudioServiceSessionBackend(handler),
      );
      addTearDown(audio.dispose);

      handler.play();
      handler.pause();
      expect([audio.playCalls, audio.pauseCalls], [1, 1]);
    });
  });

  group('D1-b 배선 — 세션을 여는 호출이 실재한다', () {
    // ⚠️⚠️ 세션 초기화는 **부르지 않아도 다른 테스트가 전부 통과한다** — 재생(D1-a)은 그대로
    // 동작하고 잠금화면만 조용히 사라진다. 그래서 호출 자체를 소스로 고정한다.
    test('main() 이 runApp 앞에서 initAudioSession 을 부른다', () {
      final src = File('lib/main.dart').readAsStringSync();
      final call = src.indexOf('initAudioSession()');
      final runApp = src.indexOf('runApp(');
      expect(call, greaterThan(-1), reason: 'main.dart 가 세션을 열지 않는다');
      expect(runApp, greaterThan(-1), reason: '대조군: runApp 호출을 찾았다');
      // ⚠️ 공식 문서가 `AudioService.init` 을 「앱 초기화 중 한 번」으로 요구한다. 첫 프레임
      // 뒤(`addPostFrameCallback`)로 미루면 알림에서 깨어난 경로에 프레임이 없어 안 돌 수 있다.
      expect(call, lessThan(runApp),
          reason: 'initAudioSession 이 runApp 뒤에 있다');
      // 첫 프레임을 늦추지 않는다(WS2) — await 하지 않고 띄운다.
      expect(src, contains('unawaited(initAudioSession())'));
    });

    test('세 플랫폼 구현이 모두 initAudioSession 을 노출한다', () {
      // 조건부 import 는 **고른 파일에 심볼이 없으면 컴파일 에러**다. 셋 중 하나를 빼면
      // 그 타깃만 깨지므로(웹 빌드는 VM 테스트가 못 본다) 여기서 함께 센다.
      for (final f in const [
        'lib/data/audio_runtime_io.dart',
        'lib/data/audio_runtime_web.dart',
        'lib/data/audio_runtime_stub.dart',
      ]) {
        expect(File(f).readAsStringSync(), contains('initAudioSession'),
            reason: f);
      }
    });

    test('io 런타임만 audio_service 를 import 한다', () {
      // 웹 번들에 들어가는 것은 플러그인 등록기가 끌어오는 `audio_service_web` 뿐이어야 한다
      // (A4 의 교훈 — 앱 대면 패키지의 웹 구현이 등록 시점에 부수효과를 낼 수 있다.
      // `audio_service_web.registerWith` 는 대입 한 줄이라 안전함을 소스로 확인했다).
      expect(File('lib/data/audio_runtime_io.dart').readAsStringSync(),
          contains("package:audio_service/audio_service.dart"));
      for (final f in const [
        'lib/data/audio_runtime_web.dart',
        'lib/data/audio_runtime_stub.dart',
      ]) {
        expect(File(f).readAsStringSync(), isNot(contains('audio_service')),
            reason: f);
      }
    });
  });

  group('D1-b 잠금화면 제목 — 플레이리스트가 민다', () {
    // ⚠️⚠️ 2026-11-21 실측으로 찾은 구멍: `nowPlaying` 을 부르는 곳이 `study_doc_page`
    // 하나뿐이어서 **오디오 허브로 재생을 시작하면 `metadata: null`** 이었다. 웹도 같은
    // 구멍이지만 네이티브는 잠금화면이 주 표면이라 빈 카드가 바로 보인다.
    ({LecturePlaylist playlist, _FakeAudioBackend audio, List<String> pushed})
        wire() {
      final audio = _FakeAudioBackend();
      final playlist = LecturePlaylist(controller: AudioController(backend: audio));
      final pushed = <String>[];
      bindNowPlaying(playlist, pushed.add);
      addTearDown(audio.dispose);
      return (playlist: playlist, audio: audio, pushed: pushed);
    }

    test('큐를 깔고 트랙을 고르면 그 제목이 실린다', () {
      final w = wire();
      final tracks = approvedAudioEntries('CLF-C02');
      expect(tracks.length, greaterThan(2), reason: '대조군: 승인된 CLF 강의가 있다');

      // 큐를 깔면 현재 트랙 제목이 먼저 실린다 — 재생 전에 메타데이터가 준비돼 있어야
      // 알림이 뜨는 순간 비어 보이지 않는다(알림 자체는 playing 상태에서만 뜬다).
      w.playlist.setQueue('CLF-C02', tracks);
      expect(w.pushed, [tracks[0].title]);

      w.playlist.select(1);
      expect(w.pushed, [tracks[0].title, tracks[1].title]);
      w.playlist.select(2);
      expect(w.pushed.last, tracks[2].title);
    });

    test('같은 트랙에서는 다시 밀지 않는다', () async {
      // 플레이리스트는 **재생 상태가 바뀔 때마다** 알린다 — 중복 제거가 없으면 세션에
      // 같은 메타데이터를 계속 다시 쓴다.
      final w = wire();
      w.playlist.setQueue('CLF-C02', approvedAudioEntries('CLF-C02'));
      final before = w.pushed.length;

      w.audio.emit(AudioEvent.playing);
      await pumpEventQueue();
      w.audio.emit(AudioEvent.paused);
      await pumpEventQueue();
      expect(w.pushed.length, before);
    });

    test('트랙 자동 전환도 제목을 갱신한다 (autoAll)', () {
      // 화면 쪽 한 번의 호출로는 다음 트랙 제목을 갱신할 수 없다 — 그래서 바인딩이
      // 플레이리스트 쪽에 있어야 한다.
      final w = wire();
      final tracks = approvedAudioEntries('CLF-C02');
      w.playlist.setQueue('CLF-C02', tracks);
      expect(w.playlist.mode, PlayMode.autoAll, reason: '대조군: 기본이 자동 전환이다');

      w.playlist.next();
      expect(w.pushed.last, tracks[1].title);
    });
  });

  group('D1-b 세션 초기화 게이트', () {
    test('플래그가 꺼져 있으면 세션을 열지 않는다', () {
      // 강의가 노출되지 않는 빌드에서 미디어 알림·포그라운드 서비스를 띄우지 않는다.
      expect(
        shouldInitAudioSession(enabled: false, isAndroid: true, isIOS: false),
        isFalse,
      );
    });

    test('데스크톱·VM 에서는 열지 않는다', () {
      // ⚠️ `dart.library.io` 분기는 `flutter test` 도 고른다 — 여기서 열면
      // `AudioService.init` 이 플랫폼 채널에 닿아 깨진다.
      expect(
        shouldInitAudioSession(enabled: true, isAndroid: false, isIOS: false),
        isFalse,
      );
    });

    test('Android·iOS + 플래그 켜짐에서만 연다', () {
      expect(
        shouldInitAudioSession(enabled: true, isAndroid: true, isIOS: false),
        isTrue,
      );
      expect(
        shouldInitAudioSession(enabled: true, isAndroid: false, isIOS: true),
        isTrue,
      );
    });
  });
}
