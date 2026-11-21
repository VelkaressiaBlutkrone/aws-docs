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

  group('m-4 엔진 초기화 실패를 사용자에게 알린다', () {
    const path = 'web/index.html';
    String src() => File(path).readAsStringSync();

    // `initializeEngine()` 체인의 끝에 붙은 실패 처리기를 찾는다.
    final catchRe = RegExp(r'initializeEngine\(\)[\s\S]{0,600}?\.catch\(');

    test('`initializeEngine()` 체인에 `.catch`가 붙어 있다', () {
      expect(catchRe.hasMatch(src()), isTrue,
          reason: '$path: `initializeEngine().then(...)`에 `.catch`가 없다 — '
              '엔진·CanvasKit 로드가 실패하면 20초 stall 문구만 뜨고 '
              '사용자는 실패 사실을 알 수 없다');
    });

    test('실패 처리기가 문구를 바꾸고 새로고침 안내를 노출한다', () {
      // ⚠️ 처리기는 `.catch(` 앞에 정의될 수도 있어(`.catch(bootFailed)`)
      // 체인 뒤쪽만 보면 놓친다 — 부트 스크립트 전체를 본다.
      final handler = src();

      expect(handler, contains('시작하지 못했습니다'),
          reason: '$path: 실패 처리기가 `#splash-msg` 문구를 실패로 바꾸지 않는다');
      expect(handler, contains('stall.hidden = false'),
          reason: '$path: 실패 처리기가 새로고침 링크가 든 `#splash-stall`을 노출하지 않는다');
      expect(handler, contains('console.error'),
          reason: '$path: 실패 처리기가 원인을 콘솔에 남기지 않는다');
    });

    test('대조군: 탐지 규칙이 `.catch` 없는 옛 형태를 잡는다', () {
      const old = '''
          engineInitializer.initializeEngine().then(function (appRunner) {
            setStage(3);
            return appRunner.runApp();
          });
''';
      expect(catchRe.hasMatch(old), isFalse,
          reason: '`.catch` 없는 옛 형태가 통과하면 가드가 무의미하다');
    });
  });

  group('m-5 브라우저 크롬 색이 저장된 테마를 따른다', () {
    const path = 'web/index.html';
    String src() => File(path).readAsStringSync();

    test('저장 테마를 읽는 스크립트가 `theme-color` 메타를 갱신한다', () {
      // 저장 테마를 즉시 반영하는 인라인 스크립트(스플래시 색 일치용)가 이미
      // `awsdocs.theme.v1`을 읽는다 — 거기서 크롬 색까지 맞춘다.
      expect(src(), contains('awsdocs.theme.v1'));
      expect(src(), contains("meta[name=\"theme-color\"]"),
          reason: '$path: `theme-color`가 `prefers-color-scheme`만 따르면 '
              '저장된 다크 테마에서 브라우저 크롬 색이 어긋난다');
    });

    test('갱신에 쓰는 색이 메타에 선언된 두 값과 같다', () {
      // ⚠️ 새 색을 만들지 않는다 — 기존 선언값을 그대로 쓴다(DESIGN.md 결정 불필요).
      final declared = RegExp(r'name="theme-color" content="(#[0-9A-Fa-f]{6})"')
          .allMatches(src())
          .map((m) => m.group(1)!)
          .toSet();
      expect(declared, isNotEmpty, reason: '$path: theme-color 메타 선언이 사라졌다');

      final scriptFrom = src().indexOf('awsdocs.theme.v1');
      final script = src().substring(scriptFrom);
      for (final color in declared) {
        expect(script, contains(color),
            reason: '$path: 스크립트가 선언된 색 $color을 쓰지 않는다 — '
                '다른 색을 하드코딩하면 메타와 어긋난다');
      }
    });
  });
  // ⚠️⚠️⚠️ **웹에서 비트 연산은 32비트다 — VM 테스트로는 잡히지 않는다.**
  //
  // dart2js 의 `_shlPositive`(`js_number.dart`)가 `other > 31` 이면 **0** 을
  // 돌려준다. 그래서 `1 << 32` 는 VM 에서 `4294967296` 이지만 웹에서 **0** 이고,
  // `Random().nextInt(0)` 은 `RangeError` 를 던진다. 직접 컴파일해 실측했다:
  //   node  → `const 1<<32 = 0` · `nextInt THREW: RangeError … was 0`
  //   dart  → `4294967296` · `nextInt = 1898356078`
  //
  // 2026-11-21 D2 에서 피드백 문서 id 생성이 `nextInt(1 << 32)` 였고, **전 테스트
  // 초록 + 웹 릴리스 빌드 성공**을 통과한 채 라이브 웹에서 모든 전송이 실패할
  // 상태였다(컴파일은 되고 런타임에 터진다). 전체 브랜치 리뷰가 잡았다.
  //
  // 이 가드는 소스를 센다 — 런타임으로 검증할 수 없는 자리의 레포 관례다
  // (`m-1`·`m-5` 와 같은 방식).
  group('웹 32비트 시프트 함정', () {
    final libFiles = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .toList();

    test('대조군: lib 의 dart 파일을 읽었다', () {
      expect(libFiles.length, greaterThan(50));
    });

    test('32비트를 넘는 왼쪽 시프트가 없다', () {
      // `<< 32` 이상(32~99)을 센다. 웹에서 전부 0 이 되어 조용히 틀린다.
      final re = RegExp(r'<<\s*(3[2-9]|[4-9]\d)\b');
      final hits = <String>[];
      for (final f in libFiles) {
        for (final line in f.readAsStringSync().split('\n')) {
          // 이 함정을 설명하는 주석 줄은 대상이 아니다.
          if (line.trimLeft().startsWith('//')) continue;
          if (re.hasMatch(line)) {
            hits.add('${f.path}: ${line.trim()}');
          }
        }
      }
      expect(hits, isEmpty,
          reason: '웹에서 0 이 된다 — 32비트 안전 상수를 쓴다(예: 0x7FFFFFFF)');
    });

    test('탐지기 대조군: 합성 입력에서 실제로 잡는다', () {
      final re = RegExp(r'<<\s*(3[2-9]|[4-9]\d)\b');
      expect(re.hasMatch('final x = 1 << 32;'), isTrue);
      expect(re.hasMatch('final x = 1 << 33;'), isTrue);
      expect(re.hasMatch('final x = 1 << 31;'), isFalse,
          reason: '31 까지는 웹에서도 안전하다');
      expect(re.hasMatch('final x = 1 << 16;'), isFalse);
    });
  });
}
