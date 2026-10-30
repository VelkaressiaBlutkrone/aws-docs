import 'package:flutter_test/flutter_test.dart';

import 'flip_allowlist.dart';

/// `flip_allowlist.dart`의 판정을 **합성 입력**으로 검증한다.
///
/// ⚠️ **실제 콘텐츠에 `verified: true`를 쓰지 않는다** — flip은 사람 전용이고
/// 예외가 없다. 그런데도 "목록에 넣으면 flip이 통과한다"를 기계로 보여야 하는데,
/// 그 둘을 동시에 만족시키는 길이 순수 함수 + 합성 입력이다. 네 분기를 전부
/// 짚으므로, SOA·DEA 문항 가드가 사람의 첫 flip에서 레드가 되지 않는다는 것이
/// 콘텐츠를 건드리지 않고 증명된다.
void main() {
  Map<String, dynamic> q(String id, {bool? verified}) => {
        'id': id,
        // `verified`가 null이면 키를 아예 넣지 않는다(= 키 없는 문항).
        'verified': ?verified,
      };

  test('flippedQuestionIds: verified:true만 모은다', () {
    expect(
      flippedQuestionIds([
        q('a', verified: true),
        q('b', verified: false),
        q('c'), // 키 없음 → 드래프트로 본다
        q('d', verified: true),
      ]),
      ['a', 'd'],
    );
  });

  test('목록 밖 Task + 전 문항 드래프트 → 통과 (지금의 SOA·DEA 상태)', () {
    expect(
      flipAllowlistGuardPasses(
        approved: const {},
        taskId: 'soa-t1-1',
        questions: [q('soa-t1-1-q1', verified: false)],
      ),
      isTrue,
    );
  });

  test('⚠️ 목록 밖 Task에 verified:true → 실패 (AI flip 금지)', () {
    expect(
      flipAllowlistGuardPasses(
        approved: const {},
        taskId: 'soa-t1-1',
        questions: [q('soa-t1-1-q1', verified: true)],
      ),
      isFalse,
    );
  });

  test('⭐ 목록 안 Task에 verified:true → 통과 (사람의 flip이 막히지 않는다)', () {
    // 이 분기가 없으면 사람이 첫 Task를 flip하는 순간 가드가 깨져
    // **flip 자체가 불가능**하다(MLA가 #246에서 겪은 함정).
    expect(
      flipAllowlistGuardPasses(
        approved: const {'soa-t1-1'},
        taskId: 'soa-t1-1',
        questions: [
          q('soa-t1-1-q1', verified: true),
          q('soa-t1-1-q2', verified: true),
        ],
      ),
      isTrue,
    );
  });

  test('목록에 넣고 flip을 빠뜨리면 → 실패', () {
    expect(
      flipAllowlistGuardPasses(
        approved: const {'dea-t1-1'},
        taskId: 'dea-t1-1',
        questions: [q('dea-t1-1-q1', verified: false)],
      ),
      isFalse,
    );
  });

  test('판정은 해당 Task만 본다 — 다른 Task가 목록에 있어도 영향 없다', () {
    expect(
      flipAllowlistGuardPasses(
        approved: const {'soa-t2-1'},
        taskId: 'soa-t1-1',
        questions: [q('soa-t1-1-q1', verified: false)],
      ),
      isTrue,
    );
  });
}
