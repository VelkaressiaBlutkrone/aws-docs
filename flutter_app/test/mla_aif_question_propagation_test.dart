import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// MLA·AIF **전파 가드** — 학습문서(md) 정정이 파생 문항으로 전파되지 않는 것을
/// 막는다. `soa_dea_question_propagation_test.dart` 의 MLA·AIF 판이다.
///
/// 2026-11-06 전 콘텐츠 2단 검토 `mla-c01-aif-c01.md` §5 `P3-M5`(구조) 반영.
/// 보고서가 적은 공백은 이것이다 — SAA 와 SOA·DEA 에는 전파 가드가 있는데
/// **MLA 에는 사실 가드도 전파 가드도 없고 AIF 는 `aif_facts_test.dart` 가
/// md 전용**이라, §2 `P1-M1`(md 는 「폐쇄」, 문항은 현재 선택지)과 §3 `P1b-A2`
/// (가드가 md 만 보는 사이 문항이 새어 나감)가 **둘 다 이 공백에서 나왔다.**
///
/// ## 규칙을 더하는 자리
///
/// md 사실 가드에서 **금지 문장**을 하나 못박았다면 **그 문장을 아래
/// `_factRules`(명칭이면 `_nameRules`)에 한 줄 추가**하고 어느 가드에서 왔는지
/// 적는다. SOA·DEA 판과 같은 계약이다:
///
/// - **`_factRules`** — `stem` · `skill` · `options[correct]` · `explanation` ·
///   `wrongExplanations` 만 본다(**오답 보기 본문은 제외** — 일부러 틀린 서술을
///   담는 자리다). 범위는 **MLA·AIF 문항**이다.
/// - **`_nameRules`** — 구식·오표기 **명칭**은 문항 **전체**(오답 보기와 출처
///   제목까지)를 본다. **오답 보기도 서비스·개념 이름은 바르게 불러야 한다.**
///   ⚠️ 그리고 **명칭에는 자격증 경계가 없다** — 범위를 **레포 전역 문항**으로
///   둔다(2026-11-07 실측: 보고서가 MLA 8건으로 적은 「파인튜닝」이
///   `dea-t1-2.questions.json` 에 1건 더 있었다. MLA·AIF 만 쓸면 그 1건을
///   놓치고 전역 0건을 만들 수 없다).
///
/// ## ⚠️ `_factRules` 가 비어 있는 이유 (공허가 아니다)
///
/// 2026-11-07 실측으로 **지금 MLA·AIF 의 md 금지 문장은 전부 자기 배치 가드가
/// 문항까지 함께 쓸고 있다** — `aif_p1b_a4_fix_test`(md 14편 + 문항 14파일
/// 전수) · `mla_aif_p2_review_fix_test`(Clarify·백서 상태·「계속 사전 훈련」을
/// md/문항 두 단정으로 갈라 둠) · `aif_facts_test`(「PT 필수」 어형을 aif 전수
/// 집계로) · `dea_mla_p1_review_fix_test`. 그래서 지금 옮겨 올 규칙이 없다.
///
/// 비어 있는 목록은 아무것도 보장하지 못하므로, 이 파일의 값은 **아래
/// 트립와이어**다 — 새 MLA·AIF 가드가 생기면 그 가드가 **문항까지 쓸었는지**를
/// 사람이 판단해 ① 금지 문장을 여기로 옮기거나 ② 파일을 등록 목록에 넣게 한다.
/// 2026-11-06 에 DEA 쪽에 심은 같은 장치가 **실제로 울려** 규칙 두 개를 옮겼다.
void main() {
  List<File> questionFilesOf(Iterable<String> certs) => [
        for (final cert in certs)
          if (Directory('assets/content/$cert').existsSync())
            ...Directory('assets/content/$cert')
                .listSync()
                .whereType<File>()
                .where((f) => f.path.endsWith('.questions.json')),
      ]..sort((a, b) => a.path.compareTo(b.path));

  List<({String file, String id, String text, String all})> scan(
      Iterable<String> certs) {
    final out = <({String file, String id, String text, String all})>[];
    for (final file in questionFilesOf(certs)) {
      final name = file.uri.pathSegments.last;
      final data = json.decode(file.readAsStringSync()) as Map<String, dynamic>;
      final questions =
          (data['questions'] as List?)?.whereType<Map<String, dynamic>>() ??
              const <Map<String, dynamic>>[];
      for (final q in questions) {
        final options =
            (q['options'] as List?)?.whereType<String>().toList() ??
                const <String>[];
        final correct = q['correct'];
        final wrong = q['wrongExplanations'];
        final factParts = <String>[
          q['stem'] as String? ?? '',
          q['skill'] as String? ?? '',
          q['explanation'] as String? ?? '',
          if (correct is int && correct >= 0 && correct < options.length)
            options[correct],
          if (wrong is Map) ...wrong.values.whereType<String>(),
        ];
        out.add((
          file: name,
          id: q['id'] as String? ?? '(id 없음)',
          text: factParts.join('\n'),
          all: json.encode(q),
        ));
      }
    }
    return out;
  }

  const allCerts = <String>['clf', 'saa', 'soa', 'dea', 'mla', 'aif', 'dva'];
  final scanned = scan(const <String>['mla', 'aif']);
  final scannedAll = scan(allCerts);

  test('대조군: MLA·AIF 문항과 레포 전역 문항이 읽혔다', () {
    // 0건 통과가 "파일을 못 읽어서"일 수 있다 — 먼저 센다.
    expect(questionFilesOf(const <String>['mla', 'aif']).length, 26,
        reason: 'MLA 12 + AIF 14 Task. 바뀌었다면 검사 범위를 다시 보라');
    expect(scanned.length, greaterThanOrEqualTo(26 * 10));
    expect(scannedAll.length, greaterThanOrEqualTo(1500),
        reason: '여섯 자격증 1,700문항대 — 명칭 규칙은 전역으로 쓴다');
  });

  group('md 가드가 금지한 사실 서술이 MLA·AIF 문항에 전파되지 않았다', () {
    test('대조군: 지금 옮겨 온 규칙이 없다 (위 주석의 실측)', () {
      expect(_factRules, isEmpty,
          reason: '규칙을 더했다면 이 대조군을 지우고 아래 루프만 남긴다');
    });
    for (final rule in _factRules) {
      final label =
          rule.text.length <= 28 ? rule.text : '${rule.text.substring(0, 28)}…';
      test('${rule.origin} "$label"', () {
        final hits = scanned
            .where((s) => s.text.contains(rule.text))
            .map((s) => '${s.file} ${s.id}')
            .toList();
        expect(hits, isEmpty,
            reason: '${rule.origin}이 md에서 금지한 서술이 문항에 남아 있다.\n'
                '공식 사실: ${rule.why}\n'
                '해당 문항: $hits');
      });
    }
  });

  group('구식·오표기 명칭이 문항 어디에도 없다 (전역 · 오답 보기·출처 제목 포함)', () {
    for (final rule in _nameRules) {
      test('${rule.origin} "${rule.text}"', () {
        final hits = scannedAll
            .where((s) => s.all.contains(rule.text))
            .map((s) => '${s.file} ${s.id}')
            .toList();
        expect(hits, isEmpty,
            reason: '${rule.origin}이 못박은 표기와 다른 명칭이 문항에 남아 있다.\n'
                '정본: ${rule.why}\n'
                '⚠️ 오답 보기도 이름은 바르게 불러야 한다.\n'
                '해당 문항: $hits');
      });
    }

    test('대조군: 탐지기가 공식 표기를 잡지 않는다', () {
      // 「미세 조정」(띄어 씀)은 정본이므로 어느 규칙에도 걸리면 안 된다.
      for (final rule in _nameRules) {
        expect('공식 표기는 미세 조정입니다'.contains(rule.text), isFalse,
            reason: '규칙 "${rule.text}" 이 정본 표기를 잡는다');
      }
      // ⚠️ 하한은 **추측하지 않고 실측해서** 잡았다 — 2026-11-07 기준 정본 표기를
      //    담은 문항은 34건(전역 1,748문항 중)이고, 처음 쓴 50은 틀린 값이었다.
      expect(
        scannedAll.where((s) => s.all.contains('미세 조정')).length,
        greaterThanOrEqualTo(30),
        reason: '정본 표기가 실제로 쓰이고 있다 — 0이면 스캐너가 고장 난 것이다',
      );
    });
  });

  test('MLA·AIF 가드가 새로 생기면 이 파일의 규칙을 채운다', () {
    // 2026-11-06 에 DEA 쪽에 심은 같은 트립와이어가 실제로 울려 규칙 두 개를
    // 옮겨 왔다(`soa_dea_question_propagation_test.dart`). 지우지 않고
    // **등록 목록 방식**으로 둔다 — 지우면 다음 가드가 같은 누락을 반복해도
    // 아무도 알려 주지 않는다.
    //
    // 새 가드를 만들었다면 ① 그 가드의 **md 금지 문장**을 아래 `_factRules`·
    // `_nameRules` 에 옮기거나(문항을 함께 쓸지 않는 가드라면) ② 이미 문항까지
    // 쓸고 있음을 확인한 뒤 파일 이름을 여기에 등록한다.
    const registered = <String>{
      'aif_doc_format_test.dart',
      'aif_duplicate_fix_test.dart',
      'aif_facts_test.dart',
      'aif_guide_v11_test.dart',
      'aif_p1b_a4_fix_test.dart',
      'aif_questions_test.dart',
      'mla_aif_p2_review_fix_test.dart',
      'mla_aif_question_propagation_test.dart',
      'mla_doc_format_test.dart',
      'mla_duplicate_fix_test.dart',
      'mla_p3_review_fix_test.dart',
      'mla_questions_test.dart',
    };
    final unregistered = Directory('test')
        .listSync()
        .whereType<File>()
        .map((f) => f.uri.pathSegments.last)
        .where((n) =>
            (n.startsWith('mla_') || n.startsWith('aif_')) &&
            !registered.contains(n))
        .toList()
      ..sort();
    expect(unregistered, isEmpty,
        reason: '새 MLA·AIF 가드가 생겼다. 그 가드의 md 금지 문장을 이 파일의 '
            '`_factRules`·`_nameRules` 에 옮기고, 이미 문항까지 쓸고 있다면 '
            '이 등록 목록에 파일 이름을 더하라: $unregistered');
  });
}

/// md 사실 가드가 금지한 **사실 서술**. 비어 있는 이유는 파일 머리 주석에 있다.
const _factRules = <({String text, String origin, String why})>[];

/// 구식·오표기 **명칭**. 문항 **전체**를 보고 범위는 **레포 전역**이다.
const _nameRules = <({String text, String origin, String why})>[
  // 2026-11-07 P3-M3. 공식 한국어 표기는 「미세 조정」(띄어 씀)이다 —
  // `ko_kr` Bedrock 사용자 지정 페이지가 「감독 미세 조정」·「강화 미세 조정」으로
  // 적고 「파인튜닝」은 0건이며, 공식 시험 가이드 JSON 도 목표 3.3 을 「파운데이션
  // 모델의 훈련과 **미세 조정** 프로세스 설명」으로 적는다.
  // ⚠️ 붙여 쓴 「미세조정」은 어미가 붙어도(「미세조정된」·「미세조정을」) 같은
  //    위반이므로 부분 문자열로 센다.
  (
    text: '미세조정',
    origin: 'mla_p3_review_fix_test',
    why: '공식 한국어 표기는 「미세 조정」(띄어 씀)이다',
  ),
  (
    text: '파인튜닝',
    origin: 'mla_p3_review_fix_test',
    why: '음차 표기다. 공식 한국어 문서·시험 가이드 모두 「미세 조정」을 쓴다',
  ),
];
