// A6 모바일 사용성 판정 스크립트 가드 (2026-11-20).
//
// `docs/audits/2026-11-19-a6-mobile-usability-audit.md` 의 「판정 방법」이 쓴 스크립트가
// **레포에 커밋되지 않아**(2026-11-20 정정, 전수 검색 0건) 같은 수치를 다시 낼 수 없었다.
// 측정 도구는 커밋하거나, 커밋하지 않았다고 적는다 — 이 가드는 그 도구가 레포에 있고
// **무엇을 판정하고 무엇을 판정하지 않는지**가 구조로 고정돼 있는지 본다.
//
// ⚠️⚠️ **접근성 노드 좌표는 "손가락이 닿는 영역"이 아니다**(A6-1 정정). `uiautomator dump`
// 가 보는 노드는 `FocusRing` 의 패딩을 포함하고 그 띠는 `InkWell` 밖이라 눌리지 않으며,
// 반대로 `Semantics` 가 `TouchTarget` **바깥**이면 노드가 48dp 로 커진다. 같은 수정인데
// 노드 수치가 위젯마다 갈리므로 **터치 타깃은 노드 좌표로 판정할 수 없다** — 그 판정은
// 렌더 트리를 직접 재는 `touch_target_test.dart` 가 전수로 지키고, 이 스크립트는
// 참고값으로만 기록한다. 그래서 `VERDICT_KEYS` 와 `INFO_KEYS` 를 갈라 두고 여기서
// 그 가름을 단정한다(누가 터치 타깃을 판정으로 올리면 이 테스트가 먼저 깨진다).
//
// ⚠️ 같은 이유로 **내비 바 침범도 판정이 아니다**(A6-2 정정) — 침범량이 조건과 무관하게
// 늘 inset 전체인 것은 스크롤 콘텐츠가 뷰포트 끝까지 그려지는 정상 동작이고, 진짜 결함인
// 「스크롤 끝 여백」은 `scroll_bottom_inset_test.dart` 가 지킨다.
//
// 사용법은 스크립트의 `--help` 와 `docs/audits/2026-11-19-a6-mobile-usability-audit.md`.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _script = '../tool/android_ui_audit.py';

String _source() => File(_script).readAsStringSync();

/// `NAME = ("a", "b", …)` 꼴 상수에서 문자열 원소를 뽑는다.
List<String> _tupleConst(String src, String name) {
  final m = RegExp('^$name\\s*=\\s*\\(([^)]*)\\)', multiLine: true).firstMatch(src);
  if (m == null) return const [];
  return RegExp('"([^"]+)"')
      .allMatches(m.group(1)!)
      .map((e) => e.group(1)!)
      .toList();
}

void main() {
  group('A6 판정 스크립트 (tool/android_ui_audit.py)', () {
    test('대조군 — 스크립트가 실재하고 본문을 읽었다', () {
      expect(File(_script).existsSync(), isTrue,
          reason: '측정 도구는 커밋한다 — 2026-11-19 감사의 스크립트가 없어 재점검이 막혔다');
      final src = _source();
      // 아래 단정들이 "추출 실패로 0건"이 되는 거짓 통과를 막는 하한이다.
      expect(src.length, greaterThan(3000));
      expect(src, contains('uiautomator'));
    });

    test('판정 키는 셋이고 터치 타깃·내비 침범은 그 안에 없다', () {
      final src = _source();
      final verdict = _tupleConst(src, 'VERDICT_KEYS');
      expect(verdict, containsAll(<String>[
        'offscreen',
        'clickable_overlap',
        'statusbar_intrusion',
      ]));
      // A6-1·A6-2 정정의 보존 — 노드로 판정할 수 없는 것을 판정에 올리지 않는다.
      expect(verdict.where((k) => k.contains('tap_target')), isEmpty,
          reason: '접근성 노드는 실제 탭 영역이 아니다 — touch_target_test.dart 가 판정한다');
      expect(verdict.where((k) => k.contains('navbar')), isEmpty,
          reason: '내비 침범은 정상 동작이다 — scroll_bottom_inset_test.dart 가 판정한다');
    });

    test('그 둘은 참고 키로 남아 기록된다', () {
      final info = _tupleConst(_source(), 'INFO_KEYS');
      expect(info, containsAll(<String>['tap_target_under_48dp', 'navbar_intrusion']),
          reason: '판정하지 않더라도 수치는 남긴다(다음 판정의 재료다)');
    });

    test('임계값이 리터럴로 고정돼 있다', () {
      final src = _source();
      // Material 최소 터치 타깃 48dp, 상태바 24dp — dp 이고, px 환산은 기기 density 로 한다.
      expect(src, contains('TAP_TARGET_MIN_DP = 48'));
      expect(src, contains('STATUS_BAR_DP = 24'));
      expect(src, contains('NAV_BAR_3BUTTON_DP = 48'));
      // 고정 헤더 셸 — AppHeaderShell.height 와 같아야 한다(app_header.dart).
      expect(src, contains('HEADER_SHELL_DP = 56'));
    });

    test('고정 헤더와 스크롤 콘텐츠의 겹침은 위반이 아니다', () {
      // 2026-11-20 실측: 스크롤하면 카드가 글래스 헤더 뒤를 지나가고(설계),
      // 그 영역을 탭하면 **헤더가 받는다**(뒤로 버튼 중심 탭 → 홈으로 이동).
      // 시각과 탭이 일치하는 정상 동작이라, 이것을 겹침으로 세면 거짓 양성이다
      // (A6-2 의 「내비 침범은 정상 동작」과 같은 계열).
      expect(_source(), contains('_in_header'));
    });

    test('스크롤 콘텐츠와 고정 요소를 구분한다', () {
      // ⚠️ 스크롤 콘텐츠가 상태바·헤더 뒤를 지나는 것은 **정상**이다(DESIGN.md
      // System bars: 「스크롤 중간에 요소가 바 영역을 지나는 것은 정상이다」).
      // 고정 요소만 침범 판정 대상이고, 둘은 `scrollable` 컨테이너의 자손인지로
      // 갈린다 — 2026-11-20 실측에서 Flutter 가 ScrollView 를 그렇게 내보낸다.
      final src = _source();
      expect(src, contains('scrollable'));
      expect(src, contains('in_scroll'));
    });

    test('가로 회전을 반영한다', () {
      // ⚠️ `wm size` 는 **물리 크기만** 준다 — 가로로 돌려도 1080x2400 이다.
      // 그대로 쓰면 가로에서 오른쪽 요소가 전부 「화면 밖」으로 잡힌다(2026-11-20
      // 실측 거짓 양성). 회전은 uiautomator XML 루트의 `rotation` 속성에 있다.
      final src = _source();
      expect(src, contains('rotation'));
      expect(src, contains('parse_rotation'));
    });

    test('화면 도달 대조군 장치가 있다', () {
      final src = _source();
      // "그 화면에 도달했는가"를 먼저 단정하지 않으면 0건이 결과가 아니라 측정 실패다.
      expect(src, contains('--expect'));
      expect(src, contains('reached'));
    });

    test('판정 로직을 합성 입력으로 검증하는 self-test 가 있다', () {
      expect(_source(), contains('--self-test'));
    });
  });
}
