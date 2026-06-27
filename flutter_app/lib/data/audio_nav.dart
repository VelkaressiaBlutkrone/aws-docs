/// 오디오 페이지 노출·라우트 게이트(순수 함수 — 위젯/라우터 밖에서 단위 테스트).
/// audioLectureEnabled(const, dart-define)는 호출부에서 주입한다(기존
/// shouldShowLecturePlayer 패턴). 라우터 테스트 안전을 위해 게이트 off면
/// 항상 안전 페이지("/", HomePage)로 보낸다(비-안전 페이지 렌더 회피).
library;

/// 상단 메뉴 '오디오' 항목 노출 여부.
bool shouldShowAudioMenu({required bool enabled, required bool hasAudio}) =>
    enabled && hasAudio;

/// `/audio` 허브 redirect 대상. null이면 그대로 렌더.
String? audioHubRedirect({required bool enabled, required bool hasAudio}) =>
    (enabled && hasAudio) ? null : '/';

/// `/cert/:code/audio` redirect 대상. null이면 그대로 렌더.
String? certAudioRedirect({
  required bool certExists,
  required bool enabled,
  required bool hasAudio,
  required String code,
}) {
  if (!certExists) return '/';
  if (!enabled) return '/';
  if (!hasAudio) return '/cert/$code';
  return null;
}
