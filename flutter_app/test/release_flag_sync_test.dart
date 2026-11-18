// 릴리스 빌드 플래그 ↔ CI 테스트 플래그 동기 가드 (2026-11-18).
//
// 릴리스(`pages.yml`)는 `--dart-define=audio_lecture=true` 로 빌드하는데 CI(`ci.yml`)의 `flutter test` 는
// 플래그 없이 돌아, 라이브에서 켜져 있는 오디오 경로가 CI 에서 한 번도 검사되지 않았다(그 사이 오디오
// 라우트의 State 재사용 결함이 숨어 있었다). 그래서 **릴리스가 켜는 dart-define 마다 CI 에 그 플래그로
// 테스트를 돌리는 단계가 있어야 하고**, 그 단계가 가리키는 파일이 실재해야 한다.
//
// ⚠️ 웹 빌드는 VM 테스트로 검증할 수 없으므로(조건부 import 가 stub 을 고른다) 워크플로 파일을
// 문자열로 읽는 소스 가드다 — `web_hardening_test.dart` 와 같은 방식.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

final _defineRe = RegExp(r'--dart-define=([A-Za-z_][A-Za-z0-9_]*)=(\S+)');

List<String> _runLines(String yml) => yml
    .split(RegExp(r'\r?\n'))
    .map((l) => l.trim())
    .where((l) => l.startsWith('run:'))
    .map((l) => l.substring(4).trim())
    .toList();

void main() {
  final pages = File('../.github/workflows/pages.yml').readAsStringSync();
  final ci = File('../.github/workflows/ci.yml').readAsStringSync();

  test('대조군: 릴리스 빌드가 dart-define 을 쓴다(이 가드가 공허하지 않다)', () {
    final build = _runLines(pages).where((l) => l.startsWith('flutter build web')).toList();
    expect(build, hasLength(1), reason: 'pages.yml 의 웹 빌드 단계가 하나여야 한다');
    expect(_defineRe.allMatches(build.single).map((m) => m.group(1)), contains('audio_lecture'));
  });

  test('릴리스가 켜는 dart-define 마다 CI 가 그 플래그로 테스트를 돌리고, 대상 파일이 실재한다', () {
    final build = _runLines(pages).singleWhere((l) => l.startsWith('flutter build web'));
    final ciTests = _runLines(ci).where((l) => l.startsWith('flutter test')).toList();
    for (final m in _defineRe.allMatches(build)) {
      final define = m.group(0)!;
      final withFlag = ciTests.where((l) => l.contains(define)).toList();
      expect(withFlag, isNotEmpty,
          reason: 'ci.yml 에 `flutter test $define …` 단계가 없다 — 릴리스에서 켜진 경로가 CI 에서 검사되지 않는다');
      for (final line in withFlag) {
        final files = line.split(RegExp(r'\s+')).where((t) => t.endsWith('_test.dart')).toList();
        expect(files, isNotEmpty, reason: '$line: 대상 테스트 파일을 명시해야 한다(전체 스위트는 플래그 끔 전제 단정과 충돌)');
        for (final f in files) {
          expect(File(f).existsSync(), isTrue, reason: '$line: $f 가 없다');
        }
      }
    }
  });
}
