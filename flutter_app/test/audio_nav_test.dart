import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/audio_nav.dart';

void main() {
  test('shouldShowAudioMenu: enabled+hasAudio일 때만 true', () {
    expect(shouldShowAudioMenu(enabled: true, hasAudio: true), isTrue);
    expect(shouldShowAudioMenu(enabled: false, hasAudio: true), isFalse);
    expect(shouldShowAudioMenu(enabled: true, hasAudio: false), isFalse);
  });

  test('audioHubRedirect: 게이트 통과면 null, 아니면 "/"', () {
    expect(audioHubRedirect(enabled: true, hasAudio: true), isNull);
    expect(audioHubRedirect(enabled: false, hasAudio: true), '/');
    expect(audioHubRedirect(enabled: true, hasAudio: false), '/');
  });

  test('certAudioRedirect: 분기별 대상', () {
    expect(certAudioRedirect(certExists: false, enabled: true, hasAudio: true, code: 'X'), '/');
    expect(certAudioRedirect(certExists: true, enabled: false, hasAudio: true, code: 'CLF-C02'), '/');
    expect(certAudioRedirect(certExists: true, enabled: true, hasAudio: false, code: 'CLF-C02'), '/cert/CLF-C02');
    expect(certAudioRedirect(certExists: true, enabled: true, hasAudio: true, code: 'CLF-C02'), isNull);
  });
}
