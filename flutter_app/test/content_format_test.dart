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
/// 세 자격증은 자격증별 별건으로 뒀다 — 건별 편집 판단이 필요해서다(SAA·SOA는
/// 대부분이 문장급 괄호 주석이라 일괄 `**굵게**` 전환이 화면을 망가뜨린다).
///
/// 경위(SOA, 2026-10-29): soa 144건을 정리해 `soa`를 넣었다. **134건이
/// `*(원리: §N — …)*` 형태의 문장급 괄호 주석**이라 별표만 지웠고, 나머지
/// **10건은 문장 내 의미 있는 강조**라 `**굵게**`로 올렸다(표 셀·불릿 본문이고
/// 굵게 안쪽에 들어간 것은 없었다). 변환은 탐지기의 역연산으로 했고 대조군
/// 둘을 단정했다 — ① 변환 후 탐지 0건 ② **별표를 전부 지운 본문이 변환 전과
/// 동일**(= 글자는 건드리지 않았다). 별표 총수는 11,605 → 11,357로 정확히
/// -248 변했다(괄호 주석 134×-2 + 승격 10×+2).
///
/// 경위(DEA, 2026-10-29): dea 194건을 정리해 `dea`를 넣었다. **SOA와 성격이
/// 전혀 달라 처리도 다르다** — 괄호 주석이 3건뿐이고, 나머지는 **이탤릭이
/// "논의 대상"을, 같은 줄의 `**굵게**`가 "사실·정답"을 표시하는 2층 구조**였다
/// (`*모든 열 + 행 표현식* = **행 수준**` 처럼). 그래서 **191건은 별표만 지웠다**:
/// ① 같은 줄에 굵게가 이미 있는 것 158건(이탤릭까지 올리면 굵게 층의 의미가
/// 무너진다) ② 인용 부호가 이미 표시층인 `*"…"*` 30건 ③ 괄호 주석 3건.
/// **승격은 3건**뿐이고 전부 같은 줄에 굵게가 없는 인용 블록의 단독 강조다
/// (`dea-t1-1` 의 KDS↔Firehose 대비). 용어 정의표의 설명 열을 평문으로 두는 것은
/// 이미 정리된 MLA 표와도 일치한다(기준 ③). ⚠️ **이탤릭 층은 애초에 렌더되지
/// 않았다**(별표가 글자로 보였다) — 별표를 지우는 것이 의도된 읽기를 복원하는
/// 쪽이고, 굵게로 올리면 학습자가 본 적 없는 강조를 **새로 만드는** 것이 된다.
/// 중첩(굵게 안쪽 이탤릭)은 **0줄**임을 먼저 확인했다. 별표 총수는 22,276 →
/// 21,900으로 정확히 -376 변했다(191×-2 + 3×+2).
///
/// 경위(SAA, 2026-10-29): saa 194건을 정리해 **레포 전역 0건**이 됐다. 성격은
/// SOA(괄호 주석이 162/194)와 DEA(2층 구조)의 혼합이라 처리도 둘을 합쳤다 —
/// **192건은 별표만 지웠다**(괄호 주석 162 · 같은 줄에 굵게 23 · 인용 5 · 굵게
/// 안쪽 1) **승격은 2건**뿐이고 `saa-t1-1`의 단어 강조다(`*별개*`·`*위*`, 같은
/// 줄에 굵게가 없다). ⚠️ **`saa-t3-1.md:184`만은 손으로 고쳐야 했다** — `*이름*`이
/// `**굵게**` **안쪽**에 있어 `\*\*[^*\n]*\*\*`가 그 굵게를 읽지 못하고 **한 칸
/// 밀려** 다음 쌍과 짝지었다(`**(위 문장)와 **`가 굵게로 렌더되고 인용구는 평문,
/// 별표는 글자로 남는다). 파서도 같은 정규식이라 **화면이 이미 깨져 있었고**,
/// 기계 치환에 맡기면 같은 함정을 밟아 그 줄을 더 망가뜨린다. ⚠️ **레시피 194 vs
/// 정밀 192의 차이가 바로 이 한 줄이다** — 탐지기가 유령 조각 둘을 내놓지만 편집
/// 지점은 하나다(HANDOFF·WORKLIST의 "saa 192"와 CLAUDE.md의 "saa 194"가 둘 다
/// 맞았다). 별표 총수는 21,541 → 21,163으로 정확히 -378 변했다(192×-2 + 2×+2).
/// ⚠️ **자리표시자는 중첩되므로 복원을 반복해야 한다** — `` **`s3:*`** ``처럼
/// 굵게 안에 코드 스팬이 있으면 코드 스팬이 먼저 금고에 들어가고 굵게가 그
/// 자리표시자를 품은 채 들어간다. 단일 패스 복원은 안쪽 자리표시자를 글자로 남기고
/// 코드 스팬 안의 `*`를 잃는다 — 대조군이 홀수 델타(-379)로 잡아냈다.
///
/// 이로써 `italicCleanCerts` 집합을 없애고 **링크 가드와 같은 전역 불변식**으로
/// 좁혔다. 그 집합은 "아직 정리하지 않은 자격증을 면제"하는 장치였고(집합에 없는
/// 자격증은 `continue`로 건너뛴다), 면제 대상이 0이 된 지금은 오히려 **새 자격증이
/// 조용히 이탤릭을 쌓는 구멍**이 된다. 전역이면 새 콘텐츠는 첫 커밋부터 0건이어야
/// 한다. 자격증 코드 오타로 가드가 공허해지는 것을 막던 `seen` 단정도 함께
/// 불필요해졌다 — 대상이 `mdFiles` 전체이므로 공허해지려면 학습문서가 0편이어야
/// 하고, 그것은 '학습문서 자산이 하나 이상 존재한다'가 이미 잡는다.
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

  test('어느 학습문서도 파서가 렌더하지 않는 단일 이탤릭을 쓰지 않는다', () {
    final offenders = <String>[];
    for (final f in mdFiles) {
      final hits = findItalicNotation(f.readAsStringSync());
      if (hits.isNotEmpty) {
        offenders.add('${relOf(f)}: ${hits.length}건 — 예: ${hits.first}');
      }
    }
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

  /// 문항 JSON 전역 불변식 — **마크다운 표기를 쓰지 않는다.**
  ///
  /// 학습문서 `.md` 는 파서를 타므로 `**굵게**` 가 정상 렌더되지만, **문항은
  /// 파서를 타지 않는다.** 문항 본문을 그리는 네 경로가 모두 평문 `Text` 다 —
  /// 지문 `quiz_page.dart`, 보기 `quiz_widgets.dart` 의 `OptionTile`,
  /// 해설·「왜 아닌가」 `ExplainBox`, 시험 결과·복습 화면. 그래서 `**교집합**` 은
  /// **별표를 포함한 글자 그대로** 학습자에게 보인다.
  ///
  /// 경위(2026-11-06): 전 콘텐츠 2단 검토가 SAA 문항에서 20개소를 찾았다
  /// (8파일 · 9문항, 전부 `explanation` 또는 `wrongExplanations`). **여섯 자격증
  /// 중 SAA 만 20건이고 나머지 다섯은 0건**이라, 이 표기가 설계가 아니라 규율
  /// 위반임이 집계로 드러났다(저작자가 md 감각으로 문항에 넣은 것으로 보인다).
  /// 20개소를 평문화하면서 **면제 집합 없이 전역 불변식**으로 걸었다 — 링크·이탤릭
  /// 가드가 같은 길을 갔고, 면제 집합은 새 자격증이 조용히 쌓는 구멍이 된다.
  group('문항 JSON 은 마크다운 굵게 표기를 쓰지 않는다', () {
    final questionFiles = Directory('assets/content')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.questions.json'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

    List<String> boldIn(String raw) =>
        RegExp(r'\*\*[^*\n]+\*\*').allMatches(raw).map((m) => m.group(0)!).toList();

    test('어느 자격증의 문항도 `**굵게**` 를 쓰지 않는다', () {
      final violations = <String>[];
      for (final f in questionFiles) {
        final hits = boldIn(f.readAsStringSync());
        if (hits.isNotEmpty) {
          violations.add('${relOf(f)}: ${hits.length}건 — 예: ${hits.first}');
        }
      }
      expect(violations, isEmpty,
          reason: '문항은 평문 Text 로 렌더되므로 별표가 글자로 보인다. '
              '강조가 필요하면 문장 구조로 옮긴다:\n${violations.join('\n')}');
    });

    /// 단일 `*이탤릭*` 도 같은 이유로 막는다 — 2026-11-07 CLF P3 배치에서
    /// `clf-t2-3-q1` 해설의 `계정 *자체*에` 한 건을 평문화하면서 전역으로 걸었다.
    ///
    /// ⚠️ **학습문서용 `findItalicNotation` 을 그대로 쓰면 거짓 양성이 난다.**
    /// `saa-t3-7` 문항이 ALB 경로 규칙을 `/api/orders/*` 처럼 적어, 느슨한
    /// `\*[^*\n]+\*` 는 **두 글로브 사이**를 이탤릭으로 잡는다(실측 2건).
    /// 마크다운 규칙대로 **여는 별표 뒤와 닫는 별표 앞이 공백이 아니어야 한다**는
    /// 조건을 넣고, **백틱 코드 스팬을 먼저 가린다** — 둘 다 필요했다.
    /// 공백 조건만으로는 `` `/api/orders/*` `` 처럼 **글로브가 백틱 안에**
    /// 있으면 여는 별표 뒤가 백틱(공백 아님)이라 그대로 걸린다(실측 3건:
    /// `saa-t2-3` 2 · `soa-t5-3` 1). 학습문서 쪽 `findItalicNotation` 이 이미
    /// `_maskCodeSpans` 를 쓰는 것과 같은 이유다.
    List<String> bareItalicIn(String raw) =>
        RegExp(r'\*(?=\S)[^*\n]*?(?<=\S)\*')
            .allMatches(_maskCodeSpans(raw)
                .replaceAll(RegExp(r'\*\*[^*\n]*\*\*'), ''))
            .map((m) => m.group(0)!)
            .toList();

    test('어느 자격증의 문항도 단일 `*이탤릭*` 을 쓰지 않는다', () {
      final violations = <String>[];
      for (final f in questionFiles) {
        final hits = bareItalicIn(f.readAsStringSync());
        if (hits.isNotEmpty) {
          violations.add('${relOf(f)}: ${hits.length}건 — 예: ${hits.first}');
        }
      }
      expect(violations, isEmpty,
          reason: '문항은 평문 Text 로 렌더되므로 별표가 글자로 보인다:\n'
              '${violations.join('\n')}');
    });

    test('대조군: 이탤릭 탐지기가 옛 문구를 잡고 경로 글로브는 통과한다', () {
      expect(bareItalicIn('계정 *자체*에 대한 것이거나'), isNotEmpty);
      expect(
        bareItalicIn('/api/orders/* 요청은 주문 서비스로, /api/users/*'),
        isEmpty,
        reason: 'ALB 경로 규칙은 이탤릭이 아니다 — 여는 별표 뒤가 공백이다',
      );
      expect(
        bareItalicIn('`/api/orders/*` 는 주문, `/static/*` 는 정적 자산'),
        isEmpty,
        reason: '백틱 안의 글로브도 걸리면 안 된다 — 코드 스팬을 먼저 가린다',
      );
      expect(bareItalicIn('**굵게**만 있는 줄'), isEmpty);
    });

    test('대조군: 문항 자산이 실재하고, 같은 탐지기가 학습문서에서는 굵게를 찾는다', () {
      expect(questionFiles.length, greaterThan(100),
          reason: '0이면 위 단정이 공허하다 — 여섯 자격증의 Task 별 문항 파일이 있다');
      final md = mdFiles.map((f) => f.readAsStringSync()).join('\n');
      expect(boldIn(md), isNotEmpty,
          reason: '학습문서는 `**굵게**` 를 정상적으로 쓴다(파서를 탄다). '
              '여기서 0건이면 탐지기가 고장 난 것이다');
    });
  });

  // ══════════════════════════════════════════════════════════════════
  // 프런트매터 `sources` 무결성 — 파서가 항목을 조용히 버리지 않는다
  //
  // ⚠️⚠️ 경위(2026-11-11): 2026-11-10 SCS 출처 교정(#439)이 `sources` 목록에
  // 항목을 삽입할 때 앵커를 잘못 잡아 **`lastVerified:` 줄이 목록 중간에** 끼었다.
  // `markdown_parser.dart` 의 `sources` 루프는 `- ` 로 시작하지 않는 줄에서 멈추고,
  // 그 뒤의 들여쓴 항목은 키 정규식(`^([A-Za-z][A-Za-z0-9]*):`)에도 걸리지 않아
  // **조용히 버려진다.** SCS 4편에서 **출처 7개**가 그렇게 사라졌고
  // (`scs-t1-2` 3 · `scs-t1-3` 2 · `scs-t2-2` 1 · `scs-t3-2` 1)
  // `study_doc_page.dart` 가 그리는 **「출처 N」 칩이 라이브에서 작게 표시**되고 있었다.
  //
  // ⚠️ **기존 가드는 전부 통과했다** — `all_content_parse_test` 는 파서가 예외 없이
  // 돌기만 하면 되고, G-84(문항 출처 ⊆ md 출처)는 md **텍스트**를 grep 하므로
  // 파일에 글자가 있으면 찾는다. **「파서가 읽는 것」과 「파일에 있는 것」을 맞대야**
  // 잡힌다.
  group('프런트매터 sources 를 파서가 하나도 버리지 않는다', () {
    /// `markdown_parser.dart` 의 프런트매터 루프를 그대로 재현한다.
    int parsedSourceCount(List<String> fm) {
      var i = 0;
      var n = 0;
      final keyRe = RegExp(r'^([A-Za-z][A-Za-z0-9]*):\s*(.*)$');
      while (i < fm.length) {
        final m = keyRe.firstMatch(fm[i]);
        if (m == null) {
          i++;
          continue;
        }
        final key = m.group(1)!;
        final val = m.group(2)!.trim();
        if (val.isEmpty && (key == 'sources' || key == 'coversTasks')) {
          i++;
          while (i < fm.length && fm[i].trimLeft().startsWith('- ')) {
            if (key == 'sources') {
              n++;
              if (i + 1 < fm.length &&
                  RegExp(r'^\s*url:').hasMatch(fm[i + 1])) {
                i++;
              }
            }
            i++;
          }
          continue;
        }
        i++;
      }
      return n;
    }

    List<String>? frontMatterOf(File f) {
      final lines = f.readAsStringSync().replaceAll('\r\n', '\n').split('\n');
      if (lines.isEmpty || lines.first.trim() != '---') return null;
      final end = lines.indexWhere((l) => l.trim() == '---', 1);
      if (end < 0) return null;
      return lines.sublist(1, end);
    }

    test('모든 자격증의 모든 md에서 유실이 0건이다', () {
      final titleRe = RegExp(r'^  - title:');
      final losses = <String, String>{};
      var checked = 0;
      for (final f in mdFiles) {
        final fm = frontMatterOf(f);
        if (fm == null) continue;
        checked++;
        final inFile = fm.where(titleRe.hasMatch).length;
        final parsed = parsedSourceCount(fm);
        if (inFile != parsed) {
          losses[relOf(f)] = '파일 $inFile개 → 파서 $parsed개';
        }
      }
      expect(checked, greaterThan(120),
          reason: '0이면 단정이 공허하다 — 프런트매터를 가진 md가 130편 안팎이다');
      expect(losses, isEmpty,
          reason: '파서가 버리는 출처가 있다. `lastVerified:` 처럼 최상위 키가 '
              '`sources` 목록 **중간**에 끼었는지 보라: $losses');
    });

    test('대조군: 탐지기가 끼어든 최상위 키를 실제로 잡는다', () {
      // 2026-11-10 결함을 그대로 재현한 합성 입력이다.
      final broken = <String>[
        'sources:',
        '  - title: A',
        '    url: https://example.invalid/a',
        'lastVerified: 2026-11-08',
        '  - title: B',
        '    url: https://example.invalid/b',
      ];
      expect(parsedSourceCount(broken), 1,
          reason: '파서는 끼어든 키에서 멈추므로 B를 못 읽는다');
      final fixed = <String>[
        'sources:',
        '  - title: A',
        '    url: https://example.invalid/a',
        '  - title: B',
        '    url: https://example.invalid/b',
        'lastVerified: 2026-11-08',
      ];
      expect(parsedSourceCount(fixed), 2,
          reason: '키를 목록 뒤로 옮기면 둘 다 읽힌다 — 이것이 수선 방향이다');
    });
  });
}
