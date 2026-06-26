/// 학습 문서 오디오 강의("주머니 라디오") M1 — 전역 오디오 런타임 경계.
///
/// study_doc_page가 이 경계를 거쳐 전역 [AudioController]에 접근한다. 실제
/// 구현(web)은 package:web DOM `<audio>`/Media Session을 묶지만, 이 파일은
/// 조건부 import로 web/stub을 분기하므로 **study_doc_page는 package:web을
/// 직접 import하지 않는다** → VM 테스트(app_router_test)가 컴파일된다.
///
/// 출처: docs/superpowers/specs/2026-06-20-study-audio-lecture-review.md (M1 T4).
library;

import 'audio_controller.dart';
import 'audio_runtime_stub.dart'
    if (dart.library.js_interop) 'audio_runtime_web.dart' as platform;

/// dart-define 게이트. 기본 false → 프로덕션/CI(GitHub Pages) 빌드는 미노출.
/// 개발자가 `--dart-define=audio_lecture=true`로 빌드할 때만 진입점이 연결된다.
/// 검수 전 생성 강의를 진짜 학습 콘텐츠로 노출하지 않기 위한 안전장치(이슈 5-9).
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

/// 전역 오디오 런타임(웹 전용). VM/test에선 null.
/// 위젯 트리 밖 싱글톤이라 라우팅 전환·위젯 dispose에도 재생이 유지된다.
AudioRuntime? get audioRuntime => platform.audioRuntime;

/// 미니 플레이어가 의존하는 런타임 표면. 실제 구현은 web(package:web)이며
/// DOM `<audio>`(재생)와 navigator.mediaSession(잠금화면)을 묶는다.
abstract class AudioRuntime {
  /// 재생 상태 머신 — 미니 플레이어가 구독한다.
  AudioController get controller;

  /// 잠금화면에 표시할 메타데이터(문서 제목)를 설정한다.
  void nowPlaying(String title);
}
