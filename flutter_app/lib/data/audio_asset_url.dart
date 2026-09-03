/// 강의 mp3 공개 오리진(Cloudflare R2 커스텀 도메인). 끝 슬래시 없음.
///
/// `--dart-define=audio_base_url=https://...`로 오버라이드(로컬 dogfood·롤백).
/// 설계: docs/superpowers/specs/2026-09-03-audio-r2-hosting-design.md
const String kAudioBaseUrl = String.fromEnvironment(
  'audio_base_url',
  defaultValue: 'https://aws-audio.leva.ai.kr',
);

/// `<audio>.src`에 넣을 HTTP URL을 만든다.
///
/// - 절대 URL(`http://`/`https://`)은 그대로 반환한다(R2 mp3).
/// - rootBundle asset 키는 flutter web 규약대로 `assets/<키>`가 된다. 키 자체가
///   pubspec 경로(`assets/...`)라 최종 HTTP URL은 `assets/assets/...`가 된다.
///   `rootBundle.load`는 이 접두어를 자동 처리하지만 `<audio>.src`처럼 URL을 직접
///   지정하는 경우엔 변환이 필요하다 — 누락 시 404(2026-06-26 라이브 dogfood로
///   확인, `web_audio_backend.setSrc`가 이 함수를 거친다).
String webAudioAssetUrl(String src) {
  if (src.startsWith('https://') || src.startsWith('http://')) return src;
  return 'assets/$src';
}
