// Android 오디오 백엔드 가드 (D1-a, 2026-11-21).
//
// 로드맵 D1 의 앞 절반 — `AudioBackend` 의 네이티브 구현(just_audio)을 더한다.
// ⭐ **기존 경계가 그대로 재사용된다**: `AudioController`(상태 머신)·`MediaSessionBinder`·
// `LecturePlaylist` 는 순수 Dart 라 한 줄도 바뀌지 않고, 웹은 `audio_runtime_web` 이
// 그대로 돈다. 이 PR 이 더하는 것은 **비웹 분기의 내용물**뿐이다.
//
// ⚠️⚠️ **`dart.library.io` 분기는 VM 테스트도 고른다.** 지금까지 비웹은 `audio_runtime_stub`
// 이라 `audioRuntime == null` 이었고 그 성질에 기대는 가드가 있다(`audio_runtime_test.dart`
// 의 「VM/test 환경에선 audioRuntime 이 null」 · `study_doc_page` 의 `hasRuntime` 게이트).
// io 구현을 넣으면 **Windows 에서 도는 `flutter test` 가 그 분기를 컴파일**하므로, 거기서
// `AudioPlayer()` 를 만들면 `MissingPluginException` 이 난다. 그래서 런타임 getter 가
// **플랫폼을 먼저 보고** Android·iOS 가 아니면 null 을 돌려준다.
//
// ⚠️ 그 판정을 `Platform.isAndroid` 로 직접 쓰면 **VM 테스트에서 영원히 false 라 한쪽
// 분기만 증명된다.** 레포 관례대로(`shouldShowLecturePlayer`·`flip_allowlist.dart`) 판정을
// **순수 함수**로 빼서 양쪽을 합성 입력으로 짚는다.
//
// ⚠️ `NativeAudioBackend` 자체는 단위 테스트하지 않는다 — `WebAudioBackend` 와 같은 이유로
// 플랫폼 의존이고(그 파일 주석: 「브라우저 의존이라 단위 테스트가 불가하다. 상태 로직은
// AudioController/Binder 단위로 커버됨」) 실제 재생은 **에뮬레이터 실측**이 판정한다.
// 여기서 고정하는 것은 **이벤트 매핑**(순수 함수)과 **플랫폼 게이트**다.
import 'dart:io';

import 'package:aws_docs/data/audio_controller.dart';
import 'package:aws_docs/data/audio_runtime.dart';
import 'package:aws_docs/data/native_audio_backend.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart' show ProcessingState;

String _read(String p) => File(p).readAsStringSync();

void main() {
  group('D1-a 네이티브 오디오 — 이벤트 매핑', () {
    test('대조군: 백엔드 소스를 읽었고 AudioBackend 를 구현한다', () {
      final src = _read('lib/data/native_audio_backend.dart');
      expect(src.length, greaterThan(1000));
      expect(src, contains('implements AudioBackend'));
      // just_audio 의 재생 API 를 실제로 쓴다(래핑이 비어 있지 않다).
      expect(src, contains('setUrl'));
    });

    test('ready + playing → playing', () {
      expect(
        mapPlayerEvent(playing: true, processing: ProcessingState.ready),
        AudioEvent.playing,
      );
    });

    test('ready + !playing → paused', () {
      expect(
        mapPlayerEvent(playing: false, processing: ProcessingState.ready),
        AudioEvent.paused,
      );
    });

    test('completed → ended (재생 의도와 무관)', () {
      // just_audio 는 완료 뒤에도 `playing` 이 true 로 남을 수 있다(재생 "의도"이고
      // 실제 상태는 processingState 다) — 그래서 completed 를 먼저 본다.
      for (final p in const [true, false]) {
        expect(
          mapPlayerEvent(playing: p, processing: ProcessingState.completed),
          AudioEvent.ended,
          reason: 'playing=$p 에서도 끝은 끝이다',
        );
      }
    });

    test('buffering → stalled (재버퍼링 — 재생 중에도 온다)', () {
      for (final p in const [true, false]) {
        expect(
          mapPlayerEvent(playing: p, processing: ProcessingState.buffering),
          AudioEvent.stalled,
          reason: 'playing=$p',
        );
      }
    });

    test('idle·loading 은 이벤트를 내지 않는다', () {
      // `AudioController.load()` 가 이미 loading 으로 전이시킨다 — 여기서 또 내면
      // 같은 상태를 두 번 알리거나(무해) 순서가 뒤집혀 보인다. null 이 「침묵」이다.
      for (final s in const [ProcessingState.idle, ProcessingState.loading]) {
        expect(mapPlayerEvent(playing: false, processing: s), isNull,
            reason: '$s');
        expect(mapPlayerEvent(playing: true, processing: s), isNull,
            reason: '$s (playing)');
      }
    });
  });

  group('D1-a 플랫폼 게이트', () {
    test('Android·iOS 에서만 네이티브 런타임을 쓴다', () {
      expect(nativeAudioSupported(isAndroid: true, isIOS: false), isTrue);
      expect(nativeAudioSupported(isAndroid: false, isIOS: true), isTrue);
      // 데스크톱·VM 테스트 — just_audio 가 데스크톱을 지원하더라도 이 앱의 대상이
      // 아니고, 무엇보다 **`flutter test` 가 여기로 들어온다**.
      expect(nativeAudioSupported(isAndroid: false, isIOS: false), isFalse);
    });

    test('VM 테스트에서는 audioRuntime 이 여전히 null 이다 (회귀 가드)', () {
      // ⚠️ 이 단정은 `audio_runtime_test.dart` 에도 있지만 **이유가 달라졌다** — 전에는
      // 「비웹은 stub」이었고 이제는 「비웹이지만 플랫폼이 Android·iOS 가 아니다」다.
      // 여기서 한 번 더 고정하는 이유는, 누가 플랫폼 게이트를 빼면 **VM 테스트가
      // `AudioPlayer()` 를 만들어 `MissingPluginException` 으로 무더기로 깨지기** 때문이다.
      expect(Platform.isAndroid || Platform.isIOS, isFalse,
          reason: '이 테스트는 데스크톱·CI(Linux)에서 돈다는 전제다');
      expect(audioRuntime, isNull);
    });
  });

  group('D1-a 조건부 import 계약', () {
    test('웹 분기가 io 분기보다 먼저다', () {
      final src = _read('lib/data/audio_runtime.dart');
      final web = src.indexOf('dart.library.js_interop');
      final io = src.indexOf('dart.library.io');
      expect(web, greaterThan(-1));
      expect(io, greaterThan(-1), reason: 'io 분기가 추가돼야 한다');
      // ⚠️ 순서가 계약이다 — io 가 먼저면 **웹 빌드가 io 판을 골라** `dart:io` 를 끌어와
      // 컴파일이 깨진다(레포의 `open_link.dart`·`app_resume.dart` 가 같은 순서를 쓴다).
      expect(web, lessThan(io));
    });

    test('io 런타임은 웹 전용 코드를 import 하지 않는다', () {
      final src = _read('lib/data/audio_runtime_io.dart');
      expect(src, isNot(contains('package:web')));
      expect(src, isNot(contains('web_audio_backend')));
      expect(src, isNot(contains('dart:js_interop')));
    });
  });
}
