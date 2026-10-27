import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 학습문서 전역 포맷 불변식 — 모든 자격증의 모든 md를 한 번에 본다.
///
/// 이 레포의 학습문서 파서는 마크다운 **하위집합**이다.
/// `lib/content/markdown_parser.dart`의 인라인 정규식은
///   `**굵게**` · `` `코드` `` · **맨 URL**
/// 이 셋만 인식한다(`_inlineRe`). 그래서 `[제목](https://…)`은 화면에
/// **`[제목](`와 `)`가 글자 그대로** 보이고 URL만 색칠되며
/// (`study_markdown_view.dart`는 색만 바꾸고 탭 핸들러도 없다),
/// `](#)`처럼 `http`가 없는 타깃은 **전체가 리터럴**로 나온다.
///
/// 경위(2026-10-26): MLA 9편이 이 표기를 527회 썼고 CLF 19편이 56회 썼다.
/// MLA는 #243에서, CLF는 #245에서 평문으로 정리했다. 두 자격증을 각각 고친
/// 뒤에야 레포 전역으로 0건을 고정할 수 있게 되어 이 파일을 신설했다.
///
/// 집계형 한 건으로 둔 이유: 전역 불변식은 위반 파일 목록을 한 번에 보여 주는
/// 쪽이 CI에서 읽기 좋고, 학습문서가 늘어도 테스트 수가 흔들리지 않는다.
/// 문서별 귀속이 필요한 MLA는 `mla_doc_format_test.dart`가 따로 본다
/// (그쪽은 단일 `*이탤릭*`까지 함께 보므로 링크 검사가 겹치는 것은 무해하다).
///
/// ⚠️ 단일 `*이탤릭*`은 아직 전역으로 고정하지 않는다 — 2026-10-26 실측으로
/// clf 762 · dea 194 · saa 194 · soa 144건(MLA만 0)이 남아 있고, 그중 548건이
/// 21자 이상인 문장급 괄호 주석이라 일괄로 `**굵게**`로 바꾸면 화면이 망가진다.
/// 건별 편집 판단이 필요해 자격증별 별건으로 둔다(경위는 감사 문서 부록 A).
void main() {
  final mdFiles = Directory('assets/content')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.md'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  test('학습문서 자산이 하나 이상 존재한다', () {
    expect(mdFiles, isNotEmpty);
  });

  test('어느 학습문서도 파서가 렌더하지 않는 링크 표기를 쓰지 않는다', () {
    // ⚠️ 코드 스팬은 **자리표시자로** 바꾼다(빈 문자열이 아니다).
    // 빈 문자열로 지우면 `` **`코드`** ``가 `****`가 되고, 그 잔여 별표가
    // 뒤따르는 표기와 짝을 이뤄 오탐을 만든다(이 가드를 만들며 실제로 밟았다).
    final link = RegExp(r'\[[^\]\n]+\]\([^)\n]+\)');
    final offenders = <String>[];
    for (final f in mdFiles) {
      final name = f.path.replaceAll(r'\', '/').split('assets/content/').last;
      final s = f.readAsStringSync().replaceAll(RegExp(r'`[^`]*`'), '\u0000');
      final hits = link.allMatches(s).map((m) => m.group(0)!).toList();
      if (hits.isNotEmpty) {
        offenders.add('$name: ${hits.length}건 — 예: ${hits.first}');
      }
    }
    expect(offenders, isEmpty,
        reason: '링크 표기는 괄호가 글자로 보인다. 출처는 "제목 — URL" 번호 목록으로, '
            '문서 간·절 간 포인터는 평문으로 적는다:\n${offenders.join('\n')}');
  });
}
