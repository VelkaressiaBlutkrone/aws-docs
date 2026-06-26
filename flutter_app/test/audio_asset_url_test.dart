import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/audio_asset_url.dart';

void main() {
  group('webAudioAssetUrl', () {
    test('rootBundle asset 키에 flutter web assets/ 접두어를 붙인다', () {
      // Flutter web은 asset을 base-href 아래 assets/<키>에 둔다. 키 자체가
      // pubspec 경로(assets/...)라 최종 HTTP URL은 assets/assets/...가 된다.
      // <audio>.src 직접 지정 시 이 변환이 없으면 404(2026-06-26 dogfood 확인).
      expect(
        webAudioAssetUrl('assets/audio/clf/clf-t1-1/lecture.mp3'),
        'assets/assets/audio/clf/clf-t1-1/lecture.mp3',
      );
    });

    test('다른 문서 키도 동일 규칙', () {
      expect(
        webAudioAssetUrl('assets/audio/clf/clf-t4-3/lecture.mp3'),
        'assets/assets/audio/clf/clf-t4-3/lecture.mp3',
      );
    });
  });
}
