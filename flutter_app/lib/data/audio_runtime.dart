/// 학습 문서 오디오 강의("주머니 라디오") M1 — 전역 오디오 런타임 경계.
///
/// study_doc_page가 이 경계를 거쳐 전역 [AudioController]에 접근한다. 구현은 셋으로
/// 갈린다 — **web**(package:web DOM `<audio>`/Media Session) · **io**(Android·iOS,
/// just_audio — 로드맵 D1) · **stub**(그 밖). 호출부는 어느 쪽도 직접 import 하지 않으므로
/// VM 테스트(app_router_test)가 컴파일된다.
///
/// ⚠️ io 판은 **데스크톱·VM 테스트에서도 선택되지만** 그 안에서 플랫폼을 다시 보고
/// Android·iOS 가 아니면 null 을 준다(`audio_runtime_io.dart`) — 그래서 `flutter test`
/// 에서는 지금도 런타임이 없다.
///
/// 출처: docs/superpowers/specs/2026-06-20-study-audio-lecture-review.md (M1 T4).
library;

import 'audio_controller.dart';
import 'lecture_playlist.dart';
// ⚠️ **순서가 계약이다** — 웹 분기가 먼저여야 한다. io 를 앞에 두면 웹 빌드가 io 판을
// 골라 `dart:io` 를 끌어와 컴파일이 깨진다(레포의 `open_link.dart`·`app_resume.dart` 가
// 같은 순서를 쓴다). `native_audio_backend_test.dart` 가 이 순서를 단정한다.
import 'audio_runtime_stub.dart'
    if (dart.library.js_interop) 'audio_runtime_web.dart'
    if (dart.library.io) 'audio_runtime_io.dart' as platform;

/// dart-define 게이트. 기본 false — `--dart-define=audio_lecture=true`로 빌드할 때만 진입점이
/// 연결된다(이슈 5-9의 안전장치). ⚠️ 릴리스(`pages.yml`)는 이 플래그를 **켜고** 빌드하고, 일반
/// `flutter test`는 끈 채 돈다. 켜진 경로는 CI가 `--dart-define=audio_lecture=true`로 따로 돌리는
/// 테스트가 덮는다(`release_flag_sync_test.dart`가 그 단계의 존재를 지킨다).
const bool audioLectureEnabled = bool.fromEnvironment('audio_lecture');

/// 미니 플레이어 노출 게이트(순수 함수 — 위젯 밖에서 단위 테스트 가능하게 분리).
/// study_doc_page가 마스터 플래그·문서별 approved·문서 로드·런타임 존재를
/// 묶어 호출한다. 어느 하나라도 false면 미노출.
bool shouldShowLecturePlayer({
  required bool enabled,
  required bool approved,
  required bool hasDoc,
  required bool hasRuntime,
}) =>
    enabled && approved && hasDoc && hasRuntime;

/// 전역 오디오 런타임(웹 · Android·iOS). 데스크톱·VM/test에선 null.
/// 위젯 트리 밖 싱글톤이라 라우팅 전환·위젯 dispose에도 재생이 유지된다.
AudioRuntime? get audioRuntime => platform.audioRuntime;

/// 미니 플레이어가 의존하는 런타임 표면. 구현은 web(package:web — DOM `<audio>` +
/// navigator.mediaSession)과 네이티브(just_audio) 둘이고, 둘 다 같은 [AudioController]·
/// [MediaSessionBinder] 배선을 쓴다.
abstract class AudioRuntime {
  /// 재생 상태 머신 — 미니 플레이어가 구독한다.
  AudioController get controller;

  /// 잠금화면에 표시할 메타데이터(문서 제목)를 설정한다.
  void nowPlaying(String title);
}

/// 전역 플레이리스트(지연 초기화). 전역 [AudioController]를 감싼다.
/// 런타임이 있는 곳(웹·Android·iOS)에서만 생기고, 데스크톱·VM/test에선
/// audioRuntime이 null이라 함께 null이다.
LecturePlaylist? _lecturePlaylist;
LecturePlaylist? get lecturePlaylist {
  final rt = audioRuntime;
  if (rt == null) return null;
  return _lecturePlaylist ??= LecturePlaylist(controller: rt.controller);
}
