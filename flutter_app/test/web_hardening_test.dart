import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 웹 전용 코드(`package:web` 조건부 import, `web/index.html`)의 회귀 가드.
///
/// ⚠️ **런타임으로는 검증할 수 없다** — VM 테스트에서는 조건부 import가
/// `open_link_stub.dart`(no-op)를 고르고 `web/index.html`은 Flutter가
/// 빌드 시점에만 읽는다. 그래서 이 파일은 **소스를 문자열로 읽어** 단정한다
/// (`dva_doc_format_test`·`content_format_test`와 같은 방식).
///
/// 각 그룹은 **대조군**(탐지 규칙이 옛 형태를 실제로 잡는지)을 함께 둔다 —
/// 없으면 정규식이 틀렸을 때 조용히 통과한다.
///
/// 정본: `docs/audits/2026-09-22-app-code-ux-review.md` Minor m-1·m-4·m-5.
void main() {
  group('m-1 새 탭 열기는 noopener·noreferrer를 넘긴다', () {
    const path = 'lib/util/open_link_web.dart';
    String src() => File(path).readAsStringSync();

    test('`window.open` 호출이 하나이고 세 번째 인수를 넘긴다', () {
      final calls = RegExp(r'window\.open\(').allMatches(src()).length;
      expect(calls, 1, reason: '$path: `window.open` 호출이 $calls개 — 1개여야 한다');

      final threeArgs = RegExp(
        r"""window\.open\(\s*url\s*,\s*'_blank'\s*,\s*'([^']*)'\s*\)""",
      ).firstMatch(src());
      expect(threeArgs, isNotNull,
          reason: '$path: `window.open(url, \'_blank\', \'<기능>\')` 형태가 아니다 — '
              '인수가 둘이면 열린 페이지가 `window.opener`로 부모 탭을 조작할 수 있다'
              '(reverse tabnabbing)');

      final features = threeArgs!.group(1)!;
      expect(features, contains('noopener'),
          reason: '$path: 세 번째 인수 "$features"에 `noopener`가 없다');
      expect(features, contains('noreferrer'),
          reason: '$path: 세 번째 인수 "$features"에 `noreferrer`가 없다');
    });

    test('대조군: 탐지 규칙이 인수 두 개짜리 옛 형태를 잡는다', () {
      const old = "  web.window.open(url, '_blank');";
      final threeArgs = RegExp(
        r"""window\.open\(\s*url\s*,\s*'_blank'\s*,\s*'([^']*)'\s*\)""",
      ).firstMatch(old);
      expect(threeArgs, isNull, reason: '옛 형태가 세 인수 패턴에 걸리면 가드가 무의미하다');
    });
  });
}
