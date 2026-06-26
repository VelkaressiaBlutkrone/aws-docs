/// Flutter web에서 rootBundle asset 키를 `<audio>.src` 같은 HTTP src URL로 변환한다.
///
/// flutter web은 빌드 시 asset을 base-href 아래 `assets/<키>`에 배치한다. 키 자체가
/// pubspec 경로(`assets/...`)라 최종 HTTP URL은 `assets/assets/...`가 된다.
/// `rootBundle.load`는 이 접두어를 자동 처리하지만, `<audio>.src`처럼 URL을 직접
/// 지정하는 경우엔 변환이 필요하다 — 누락 시 404(2026-06-26 라이브 dogfood로 확인,
/// `web_audio_backend.setSrc`가 이 함수를 거친다).
String webAudioAssetUrl(String assetKey) => 'assets/$assetKey';
