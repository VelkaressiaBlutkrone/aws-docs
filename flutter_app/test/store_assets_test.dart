// Play 스토어 그래픽 자산 가드 (A8-2, 2026-11-20).
//
// 스토어 아이콘 · 기능 그래픽 · 휴대전화 스크린샷이 Play 공식 요건을 지키는지 본다.
// 요건 정본(2026-11-20 실측):
// - Add preview assets (support.google.com/googleplay/android-developer/answer/9866151):
//   스크린샷 2~8장 · JPEG 또는 24-bit PNG(no alpha) · 장당 8MB · 각 변 320~3,840px ·
//   긴 변 ≤ 짧은 변 × 2.3 · 추천 노출은 1080px 이상 4장(세로 1080×1920 이상) ·
//   아이콘 32-bit PNG(with alpha) 512×512 · 1024KB · 기능 그래픽 1024×500 no alpha.
// - Icon design specifications (developer.android.com/distribute/google-play/resources/
//   icon-design-specifications): "Full square -- Google Play dynamically handles
//   masking" · "Don't round the edges of your final asset".
//
// ⚠️ Pillow 없이 Dart 로 PNG 를 직접 읽는다 — IHDR 의 크기·비트 깊이·색 유형과
// tRNS 청크 유무를 보고, 아이콘은 **첫 픽셀**을 복원해 모서리를 미리 깎지 않았는지 본다
// (첫 행 첫 픽셀은 어떤 필터 유형이든 왼쪽·위 이웃이 0 이라 원시 바이트와 같다).
//
// 자산 생성: `py tool/make_app_icon.py --store` · 스크린샷은 에뮬레이터 데모 모드로
// 찍는다(`docs/play/assets/README.md`).
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

const _assets = '../docs/play/assets';

class _Png {
  _Png(this.bytes, this.width, this.height, this.bitDepth, this.colorType,
      this.chunks);
  final Uint8List bytes;
  final int width;
  final int height;
  final int bitDepth;
  final int colorType; // 2 = RGB(truecolor), 6 = RGBA
  final List<String> chunks;

  bool get hasAlpha => colorType == 6 || colorType == 4 || chunks.contains('tRNS');
}

int _u32(Uint8List b, int o) =>
    (b[o] << 24) | (b[o + 1] << 16) | (b[o + 2] << 8) | b[o + 3];

_Png _readPng(String path) {
  final b = File(path).readAsBytesSync();
  const sig = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
  for (var i = 0; i < 8; i++) {
    if (b[i] != sig[i]) throw StateError('PNG 서명이 아니다: $path');
  }
  final chunks = <String>[];
  var o = 8;
  while (o + 8 <= b.length) {
    final len = _u32(b, o);
    chunks.add(String.fromCharCodes(b.sublist(o + 4, o + 8)));
    o += 12 + len;
  }
  return _Png(b, _u32(b, 16), _u32(b, 20), b[24], b[25], chunks);
}

/// 첫 행 첫 픽셀(RGBA 기준 4바이트). IDAT 를 이어 붙여 풀고 필터 바이트 뒤를 읽는다.
List<int> _firstPixel(_Png png) {
  final idat = BytesBuilder();
  var o = 8;
  while (o + 8 <= png.bytes.length) {
    final len = _u32(png.bytes, o);
    final type = String.fromCharCodes(png.bytes.sublist(o + 4, o + 8));
    if (type == 'IDAT') idat.add(png.bytes.sublist(o + 8, o + 8 + len));
    o += 12 + len;
  }
  final raw = ZLibCodec().decode(idat.takeBytes());
  final channels = png.colorType == 6 ? 4 : 3;
  return raw.sublist(1, 1 + channels);
}

List<File> _screenshots() {
  final dir = Directory('$_assets/screenshots');
  if (!dir.existsSync()) return [];
  return dir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.toLowerCase().endsWith('.png'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
}

void main() {
  test('대조군: 생성기가 스토어 출력 옵션을 가진다', () {
    final src = File('../tool/make_app_icon.py').readAsStringSync();
    expect(src, contains('--store'),
        reason: '스토어 자산을 손으로 그리면 재현할 수 없다');
  });

  // 이 리더가 틀리면 아래 단정이 전부 공허해진다. Pillow 로 미리 잰 파일과 맞댄다
  // (2026-11-20: `Icon-512.png` 는 (512, 512) RGB — 모서리를 둥글게 그린 웹 아이콘).
  test('대조군: PNG 리더가 알려진 파일의 크기·색 유형을 읽는다', () {
    final png = _readPng('web/icons/Icon-512.png');
    expect([png.width, png.height, png.bitDepth, png.colorType], [512, 512, 8, 2]);
    expect(png.chunks.first, 'IHDR');
    expect(png.chunks.last, 'IEND');
    // 웹 아이콘은 모서리를 둥글게 깎아 첫 픽셀이 accent 가 아니다 — 아이콘 단정의 음성 대조군.
    expect(_firstPixel(png), isNot([0x0E, 0x81, 0x75]));
  });

  group('스토어 아이콘', () {
    const path = '$_assets/icon-512.png';

    test('512×512 · 32-bit PNG(투명도 채널) · 1024KB 이하', () {
      final png = _readPng(path);
      expect([png.width, png.height], [512, 512]);
      expect(png.bitDepth, 8);
      expect(png.colorType, 6, reason: '공식: "32-bit PNG (with alpha)"');
      expect(File(path).lengthSync(), lessThanOrEqualTo(1024 * 1024));
    });

    // ⚠️ 웹 `Icon-512.png` 를 그대로 올리면 안 된다 — 모서리를 미리 둥글게 그렸고
    // Play 가 그 위에 30% 마스크를 또 씌운다.
    test('모서리를 미리 깎지 않은 정사각형이고 배경이 불투명한 accent 다', () {
      final px = _firstPixel(_readPng(path));
      expect(px, [0x0E, 0x81, 0x75, 0xFF],
          reason: '공식: "Don\'t round the edges of your final asset"');
    });
  });

  group('기능 그래픽', () {
    const path = '$_assets/feature-graphic.png';

    test('1024×500 · 투명도 없음', () {
      final png = _readPng(path);
      expect([png.width, png.height], [1024, 500]);
      expect(png.hasAlpha, isFalse, reason: '공식: "JPEG or 24-bit PNG (no alpha)"');
      expect(png.bitDepth, 8);
    });
  });

  group('휴대전화 스크린샷', () {
    test('2~8장이고 추천 노출 조건(1080px 이상 4장)을 넘는다', () {
      final shots = _screenshots();
      expect(shots.length, inInclusiveRange(2, 8));
      final big = shots.where((f) {
        final p = _readPng(f.path);
        return p.width >= 1080 && p.height >= 1920;
      });
      expect(big.length, greaterThanOrEqualTo(4));
    });

    test('각 장이 크기·비율·형식·용량 요건을 지킨다', () {
      final shots = _screenshots();
      expect(shots, isNotEmpty);
      for (final f in shots) {
        final p = _readPng(f.path);
        final name = f.uri.pathSegments.last;
        expect(p.hasAlpha, isFalse, reason: '$name: 24-bit PNG(no alpha)여야 한다');
        expect(p.bitDepth, 8, reason: name);
        for (final side in [p.width, p.height]) {
          expect(side, inInclusiveRange(320, 3840), reason: name);
        }
        final long = p.width > p.height ? p.width : p.height;
        final short = p.width > p.height ? p.height : p.width;
        expect(long / short, lessThanOrEqualTo(2.3), reason: '$name: 긴 변 ≤ 짧은 변 × 2.3');
        expect(f.lengthSync(), lessThanOrEqualTo(8 * 1024 * 1024), reason: name);
      }
    });
  });
}
