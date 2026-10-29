/// flip 허용 목록 판정(순수 함수) — `verified: true`를 **사람만** 쓰게 만드는 가드의 핵심.
///
/// ## 왜 있는가
///
/// 드래프트 자격증의 문항 가드는 "전 문항 `verified: false`"를 단정해 AI flip을
/// 막았다. 그런데 그러면 **사람이 첫 Task를 flip하는 순간 그 단정이 깨져 flip
/// 자체가 불가능**해진다 — `review.mjs flip`이 마지막에 그 테스트를 돌리므로
/// 파일을 다 쓴 뒤 레드로 끝난다. MLA가 #246에서 그 함정에 걸렸고
/// `flipApprovedTaskIds` 허용 목록으로 풀었다.
///
/// SOA-C03·DEA-C01은 2026-10-29까지 **그 함정이 그대로 남아 있었다**
/// (`soa_questions_test.dart`·`dea_questions_test.dart`의 전수 `verified: false`
/// 단정이 둘 다 `CERTS[<cert>].tests`에 들어 있다). 이 파일이 그 판정을 한곳에
/// 모아 두고, `flip_allowlist_test.dart`가 **양쪽 분기를 합성 입력으로** 검증한다
/// — 실제 콘텐츠에 `verified: true`를 쓰지 않고도 "목록에 넣으면 통과한다"를
/// 기계로 보일 수 있다(AI flip 금지는 예외 없는 규율이다).
///
/// ## 계약
///
/// 허용 목록에 **없는** Task는 전 문항이 드래프트여야 하고, **있는** Task는
/// verified 문항이 하나 이상 있어야 한다. 목록에 Task를 넣는 행위가 곧 사람의
/// 서명이고(flip 커밋의 diff에 드러난다), 그 추가를 `review.mjs flip`이
/// 대신 해 준다(`CERTS[<cert>].flipAllowlist`).
library;

/// `verified: true`인 문항 id만 모은다. `verified`가 bool이 아니면 드래프트로 본다.
List<String> flippedQuestionIds(Iterable<Map<String, dynamic>> questions) => [
      for (final q in questions)
        if (q['verified'] == true) '${q['id']}',
    ];

/// 허용 목록 가드가 통과하는가.
///
/// - 목록 밖 Task: verified 문항이 **하나도 없어야** 한다(AI flip 금지).
/// - 목록 안 Task: verified 문항이 **하나 이상** 있어야 한다(목록만 넣고 flip을
///   빠뜨린 상태를 잡는다).
bool flipAllowlistGuardPasses({
  required Set<String> approved,
  required String taskId,
  required Iterable<Map<String, dynamic>> questions,
}) {
  final flipped = flippedQuestionIds(questions);
  return approved.contains(taskId) ? flipped.isNotEmpty : flipped.isEmpty;
}
