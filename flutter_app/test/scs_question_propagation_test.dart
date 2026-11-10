import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// SCS **전파 가드** — 학습문서(md) 정정이 파생 문항으로 전파되지 않는 것을 막는다.
/// `saa_question_propagation_test.dart` · `soa_dea_question_propagation_test.dart` ·
/// `mla_aif_question_propagation_test.dart` 의 SCS 판이다.
///
/// 2026-11-10 SCS-C03 검수 준비에서 신설했다. 저작이 끝나(학습문서 16편 + 문항
/// 240개) **사람 검수·flip 으로 넘어가는 시점**이고, 그 공정이 md 를 고치면 파생
/// 문항으로 번지지 않는지 볼 자리가 자격증마다 하나씩 있어야 한다.
///
/// ## 규칙을 더하는 자리
///
/// md 사실 가드에서 **금지 문장**을 하나 못박았다면 **그 문장을 아래
/// `_factRules`(명칭이면 `_nameRules`)에 한 줄 추가**하고 어느 가드에서 왔는지
/// 적는다. 다른 자격증 판과 같은 계약이다:
///
/// - **`_factRules`** — `stem` · `skill` · `options[correct]` · `explanation` ·
///   `wrongExplanations` 만 본다(**오답 보기 본문은 제외** — 일부러 틀린 서술을
///   담는 자리다). 범위는 **SCS 문항**이다.
/// - **`_nameRules`** — 구식·오표기 **명칭**은 문항 **전체**(오답 보기와 출처
///   제목까지)를 본다. **오답 보기도 서비스 이름은 바르게 불러야 한다.**
///   ⚠️ 명칭에는 자격증 경계가 없으므로 **전역 규칙은 이 파일에 두지 않는다** —
///   `mla_aif_question_propagation_test.dart` 의 `_nameRules` 가 `assets/content`
///   하위 **전 자격증**을 돈다(2026-11-10에 그 범위를 디렉터리 유도로 넓혔다).
///   SCS 전용 명칭만 아래에 둔다.
///
/// ## ⚠️ 두 목록이 비어 있는 이유 (공허가 아니다)
///
/// 2026-11-10 실측으로 **SCS 에는 md 전용 사실 가드가 없다.** 가드가 셋인데
/// 성격이 이렇다:
///
/// - `scs_questions_test.dart` — 구조·`skill` 실재·기술 커버리지·flip 허용 목록
/// - `scs_guide_sync_test.dart` — `exam_guides/SCS-C03.json` 과 공식 가이드 동기화
/// - `scs_doc_format_test.dart` — 포맷 + **도메인별 저작 규율**(닫힌 서비스 상태·
///   사실 한정·D-11 표기). ⭐ 그런데 이 규율들은 2026-11-10에 넓힌
///   `authoredTextOf` 로 **md 와 `.questions.json` 을 합쳐** 읽는다(G-94). 즉
///   **금지 문장이 이미 문항까지 쓸리고 있어** 여기로 옮겨 올 규칙이 없다.
///
/// 비어 있는 목록은 아무것도 보장하지 못하므로, 지금 이 파일의 값은 **아래
/// 트립와이어**다 — 새 SCS 가드가 생기면 그 가드가 **문항까지 쓸었는지**를 사람이
/// 판단해 ① 금지 문장을 여기로 옮기거나 ② 파일을 등록 목록에 넣게 한다.
/// 같은 장치를 2026-10-29에 DEA 쪽에 심었고 **2026-11-06에 실제로 울려** 규칙 둘을
/// 옮겼다(`dea_mla_p1_review_fix_test`).
void main() {
  final files = Directory('assets/content/scs')
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.questions.json'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  // 사실 영역(오답 보기 제외)과 문항 전체를 따로 모아 둔다.
  final scanned = <({String file, String id, String text, String all})>[];
  for (final file in files) {
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
      scanned.add((
        file: name,
        id: q['id'] as String? ?? '(id 없음)',
        text: <String>[
          q['stem'] as String? ?? '',
          q['skill'] as String? ?? '',
          q['explanation'] as String? ?? '',
          if (correct is int && correct >= 0 && correct < options.length)
            options[correct],
          if (wrong is Map) ...wrong.values.whereType<String>(),
        ].join('\n'),
        all: json.encode(q),
      ));
    }
  }

  test('대조군: SCS 문항이 읽혔다', () {
    // 0건 통과가 "파일을 못 읽어서"일 수 있다 — 먼저 센다.
    expect(files.length, 16,
        reason: 'SCS 공식 Task 는 16개다. 바뀌었다면 검사 범위를 다시 보라');
    expect(scanned.length, greaterThanOrEqualTo(240),
        reason: 'Task 당 15문항 = 240. 더 적으면 파싱이 샌 것이다');
  });

  group('md 가드가 금지한 사실 서술이 SCS 문항에 전파되지 않았다', () {
    for (final rule in _factRules) {
      test('${rule.origin} "${rule.text}"', () {
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

  group('구식·오표기 명칭이 SCS 문항 어디에도 없다 (오답 보기·출처 제목 포함)', () {
    for (final rule in _nameRules) {
      test('${rule.origin} "${rule.text}"', () {
        final hits = scanned
            .where((s) => s.all.contains(rule.text))
            .map((s) => '${s.file} ${s.id}')
            .toList();
        expect(hits, isEmpty,
            reason: '${rule.origin}이 md에서 금지한 구식 명칭이 문항에 남아 있다.\n'
                '정본: ${rule.why}\n'
                '⚠️ 오답 보기도 서비스 이름은 바르게 불러야 한다.\n'
                '해당 문항: $hits');
      });
    }
  });

  test('SCS 가드가 새로 생기면 이 파일의 규칙을 채운다', () {
    // ⚠️ 새 가드를 추가하는 사람은 ① 그 가드의 금지 문장이 **문항까지 쓸리는지**
    //    확인하고, 쓸리지 않으면 `_factRules`·`_nameRules` 로 옮긴 뒤 ② 파일
    //    이름을 아래에 등록한다. 트립와이어를 지우면 다음 가드가 같은 누락을
    //    반복해도 아무도 알려 주지 않는다(DEA 쪽 같은 장치가 2026-11-06에
    //    실제로 울렸다).
    const registered = <String>{
      'scs_questions_test.dart', // 구조·skill·커버리지·flip 허용 목록
      'scs_guide_sync_test.dart', // 가이드 JSON 동기화
      'scs_doc_format_test.dart', // 포맷 + 저작 규율 (md + 문항을 합쳐 읽는다)
      'scs_question_propagation_test.dart', // 이 파일
    };
    final unregistered = Directory('test')
        .listSync()
        .whereType<File>()
        .map((f) => f.uri.pathSegments.last)
        .where((n) => n.startsWith('scs_') && !registered.contains(n))
        .toList()
      ..sort();
    expect(unregistered, isEmpty,
        reason: 'SCS 가드가 새로 생겼다 — 그 가드의 금지 문장이 문항까지 쓸리는지 '
            '확인하고, 아니면 이 파일의 `_factRules`·`_nameRules` 로 옮긴 뒤 위 '
            '목록에 등록해라(그러지 않으면 2026-10-20 SAA 사고가 SCS에서 '
            '재현된다): $unregistered');
  });
}

/// md 가드의 금지 **사실 서술**. `origin` 은 어느 가드에서 왔는지.
///
/// ⚠️ 지금 비어 있는 이유는 머리말에 있다 — `scs_doc_format_test` 의 저작 규율이
/// `authoredTextOf` 로 md 와 문항을 **합쳐** 읽으므로 옮겨 올 규칙이 없다.
const _factRules = <({String text, String origin, String why})>[];

/// 구식·오표기 **명칭**. 전역 규칙은 `mla_aif_question_propagation_test.dart` 에
/// 있고(자격증 경계가 없다) 여기에는 **SCS 전용** 명칭만 둔다.
///
/// ⚠️ D-11 「준수 팩」(구식 「적합성 팩」 금지)은 `scs_doc_format_test` 가 md 와
/// 문항을 각각 단정하고 있어 중복으로 두지 않는다 — 두 곳에 두면 유지 지점이
/// 둘이 된다.
const _nameRules = <({String text, String origin, String why})>[];
