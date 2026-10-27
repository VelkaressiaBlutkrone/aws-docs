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
/// 단일 `*이탤릭*`도 마찬가지로 별표가 글자로 남는다.
///
/// 경위(링크, 2026-10-26): MLA 9편이 이 표기를 527회 썼고 CLF 19편이 56회 썼다.
/// MLA는 #243에서, CLF는 #245에서 평문으로 정리했다. 두 자격증을 각각 고친
/// 뒤에야 레포 전역으로 0건을 고정할 수 있게 되어 이 파일을 신설했다.
///
/// 경위(이탤릭, 2026-10-27): 가드 레시피로 clf 762 · dea 194 · saa 194 · soa 144
/// (MLA만 0)였다. CLF 762건을 정리해 `italicCleanCerts`에 clf를 넣었고, 남은
/// 세 자격증은 자격증별 별건으로 둔다 — 건별 편집 판단이 필요해서다(SAA·SOA는
/// 대부분이 문장급 괄호 주석이라 일괄 `**굵게**` 전환이 화면을 망가뜨린다).
///
/// 집계형 한 건으로 둔 이유: 전역 불변식은 위반 파일 목록을 한 번에 보여 주는
/// 쪽이 CI에서 읽기 좋고, 학습문서가 늘어도 테스트 수가 흔들리지 않는다.
/// 문서별 귀속이 필요한 MLA는 `mla_doc_format_test.dart`가 따로 본다
/// (그쪽도 같은 둘을 보므로 검사가 겹치는 것은 무해하다).

/// 코드 스팬을 **자리표시자로** 바꾼다(빈 문자열이 아니다).
///
/// 빈 문자열로 지우면 `` **`코드`** ``가 `****`가 되고, 빈 굵게는 `[^*\n]+`에
/// 걸리지 않아 별표 4개가 남는다. 그 잔여가 뒤따르는 `**`와 짝을 이뤄 가짜
/// 이탤릭을 만든다(2026-10-26에 링크 가드를 만들며 실제로 밟은 함정이다).
String _maskCodeSpans(String s) => s.replaceAll(RegExp(r'`[^`]*`'), '\u0000');

/// 파서가 렌더하지 않는 링크 표기 `[제목](타깃)`을 찾는다.
List<String> findLinkNotation(String raw) => RegExp(r'\[[^\]\n]+\]\([^)\n]+\)')
    .allMatches(_maskCodeSpans(raw))
    .map((m) => m.group(0)!)
    .toList();

/// 파서가 렌더하지 않는 단일 `*이탤릭*`을 찾는다.
///
/// `**굵게**`를 먼저 걷어내는 이유는 둘이다: ① `**굵게**`가 단일 별표 쌍으로
/// 오탐되는 것을 막고, ② 굵게 **안쪽**에 이탤릭이 들어간 줄을 잡는다. ②는
/// 파서가 바깥 굵게마저 렌더하지 못해(`\*\*([^*]+)\*\*`는 내부 별표를 허용하지
/// 않는다) **그 줄의 별표 전부가 글자로 보이는** 더 나쁜 경우다 — CLF에 44건
/// 있었고, 그중 6줄은 이탤릭이 굵게의 닫는 별표와 맞붙어(`*…***`) 있었다.
List<String> findItalicNotation(String raw) => RegExp(r'\*[^*\n]+\*')
    .allMatches(
        _maskCodeSpans(raw).replaceAll(RegExp(r'\*\*[^*\n]*\*\*'), ''))
    .map((m) => m.group(0)!)
    .toList();

void main() {
  final mdFiles = Directory('assets/content')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.md'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  /// 단일 이탤릭을 전수 정리한 자격증. 여기 대해서만 0건을 고정한다.
  /// 늘릴 때는 그 자격증의 `.md`를 먼저 정리하고 한 줄 추가한다.
  const italicCleanCerts = {'clf', 'mla'};

  String relOf(File f) =>
      f.path.replaceAll(r'\', '/').split('assets/content/').last;

  test('학습문서 자산이 하나 이상 존재한다', () {
    expect(mdFiles, isNotEmpty);
  });

  test('어느 학습문서도 파서가 렌더하지 않는 링크 표기를 쓰지 않는다', () {
    final offenders = <String>[];
    for (final f in mdFiles) {
      final hits = findLinkNotation(f.readAsStringSync());
      if (hits.isNotEmpty) {
        offenders.add('${relOf(f)}: ${hits.length}건 — 예: ${hits.first}');
      }
    }
    expect(offenders, isEmpty,
        reason: '링크 표기는 괄호가 글자로 보인다. 출처는 "제목 — URL" 번호 목록으로, '
            '문서 간·절 간 포인터는 평문으로 적는다:\n${offenders.join('\n')}');
  });

  test('평문 정리를 마친 자격증은 단일 이탤릭을 쓰지 않는다', () {
    final seen = {for (final c in italicCleanCerts) c: 0};
    final offenders = <String>[];
    for (final f in mdFiles) {
      final rel = relOf(f);
      final cert = rel.split('/').first;
      if (!italicCleanCerts.contains(cert)) continue;
      seen[cert] = seen[cert]! + 1;
      final hits = findItalicNotation(f.readAsStringSync());
      if (hits.isNotEmpty) {
        offenders.add('$rel: ${hits.length}건 — 예: ${hits.first}');
      }
    }
    // 자격증 코드 오타로 이 가드가 공허하게 통과하는 것을 막는다.
    seen.forEach((cert, count) {
      expect(count, greaterThan(0),
          reason: '$cert: 대상 .md가 0편 — italicCleanCerts의 자격증 코드를 확인한다');
    });
    expect(offenders, isEmpty,
        reason: '단일 이탤릭은 별표가 글자로 보인다. 강조가 의미 있으면 **굵게**로, '
            '문장급 괄호 주석이면 별표만 지운다:\n${offenders.join('\n')}');
  });

  group('표기 탐지 규칙', () {
    test('`**굵게**`를 단일 이탤릭으로 오탐하지 않는다', () {
      expect(findItalicNotation('**굵게**와 **또 굵게**'), isEmpty);
      expect(findItalicNotation('**굵게**바로**붙은굵게**'), isEmpty);
    });

    test('코드 스팬 안의 별표는 세지 않는다', () {
      expect(findItalicNotation('`cron(0 * ? * * *)`과 `ecr:*` 권한'), isEmpty);
      expect(findItalicNotation('굵게 안의 코드 **`s3:*`** 는 정상'), isEmpty);
      expect(findLinkNotation('배열 접근 `a[0](x)` 는 링크가 아니다'), isEmpty);
    });

    test('단일 `*이탤릭*`과 문장급 괄호 주석을 잡는다', () {
      expect(findItalicNotation('용량을 *탄력성*으로 조절'), ['*탄력성*']);
      expect(findItalicNotation('*(원리: §3 — 축이 다르다.)*'),
          ['*(원리: §3 — 축이 다르다.)*']);
    });

    test('`**굵게**` 안쪽·경계의 이탤릭도 잡는다', () {
      expect(findItalicNotation('**클라우드 *자체*의 보안**'), isNotEmpty);
      expect(findItalicNotation('**임계값 초과 *알림***'), isNotEmpty);
    });
  });
}
