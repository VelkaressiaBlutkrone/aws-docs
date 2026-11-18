// 배포 기준점(version.json) 가드 (2026-11-18 외부 리뷰 후속 §6-2).
//
// GitHub Pages 배포가 끝나도 **어느 소스 커밋이 라이브에 나갔는지** 사이트에서 알 수 없었다 —
// 그래서 지금까지 라이브 판정을 콘텐츠 자산 md5 대조로 해 왔다. `pages.yml` 이 빌드 산출물에
// `version.json`(커밋 SHA · 빌드 시각 · 실행 번호)을 쓰게 하고, 이 가드가 그 단계의 존재와 순서를 지킨다.
// 콘텐츠(학습문서·문항)는 같은 커밋에 번들되므로 커밋 SHA 가 곧 콘텐츠 버전이다.
//
// ⚠️ 워크플로는 VM 테스트로 실행할 수 없으므로 파일을 문자열로 읽는 소스 가드다
// (`release_flag_sync_test.dart`·`web_hardening_test.dart` 와 같은 방식).
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// `- name:` 단위로 단계를 나눠 (이름, 본문) 목록으로 돌려준다.
List<(String, String)> _steps(String yml) {
  final out = <(String, String)>[];
  final re = RegExp(r'^\s*- name:\s*(.+)$', multiLine: true);
  final ms = re.allMatches(yml).toList();
  for (var i = 0; i < ms.length; i++) {
    final end = i + 1 < ms.length ? ms[i + 1].start : yml.length;
    out.add((ms[i].group(1)!.trim(), yml.substring(ms[i].start, end)));
  }
  return out;
}

void main() {
  final pages = File('../.github/workflows/pages.yml').readAsStringSync();
  final steps = _steps(pages);
  int indexOf(bool Function(String body) f) => steps.indexWhere((s) => f(s.$2));

  test('대조군: pages.yml 을 실제로 읽었고 빌드·업로드 단계가 있다', () {
    expect(indexOf((b) => b.contains('flutter build web')), isNonNegative);
    expect(indexOf((b) => b.contains('upload-pages-artifact')), isNonNegative);
  });

  test('빌드 뒤·업로드 앞에 build/web/version.json 을 커밋 SHA 와 함께 쓴다', () {
    final build = indexOf((b) => b.contains('flutter build web'));
    final upload = indexOf((b) => b.contains('upload-pages-artifact'));
    final stamp = indexOf((b) => b.contains('build/web/version.json'));
    expect(stamp, isNonNegative, reason: 'version.json 을 쓰는 단계가 없다 — 라이브 커밋을 알 수 없다');
    expect(stamp, greaterThan(build), reason: '빌드가 build/web 을 다시 만들므로 빌드 뒤여야 한다');
    expect(stamp, lessThan(upload), reason: '업로드 뒤에 쓰면 배포 산출물에 들어가지 않는다');
    final body = steps[stamp].$2;
    for (final key in ['commit', 'builtAt', 'runId']) {
      expect(body.contains('"$key"'), isTrue, reason: 'version.json 에 $key 필드가 없다');
    }
    expect(body.contains(r'${{ github.sha }}') || body.contains(r'$GITHUB_SHA'), isTrue,
        reason: '커밋 SHA 를 워크플로 컨텍스트에서 받아야 한다(하드코딩 금지)');
  });
}
