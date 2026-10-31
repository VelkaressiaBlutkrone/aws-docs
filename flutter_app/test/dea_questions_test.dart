import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

import 'flip_allowlist.dart';

/// DEA-C01 문항 드래프트 구조·밀도 가드.
///
/// `QuestionBank.fromJson`은 verified 게이트로 비검증 문항을 제외하므로,
/// 드래프트(verified:false) 단계 검증은 raw JSON을 직접 파싱해 스키마를 확인한다
/// (saa_questions_test.dart와 같은 패턴).
/// 품질 바(question_model_test.dart의 런타임 규칙과 동일):
/// options 정확히 4개, correct 범위 내, wrongExplanations 키=정답 아닌 인덱스, sources 존재.
void main() {
  // 문항 작성을 완료한(드래프트 포함) Task — 도메인 배치별로 누적 추가한다.
  const deaTaskIds = [
    // D1 데이터 수집 및 변환 (34%) — 작성 완료분만 올린다(도메인 1 완료)
    'dea-t1-1', 'dea-t1-2', 'dea-t1-3', 'dea-t1-4',
    // D2 데이터 스토어 관리 (26%) — 도메인 2 완료
    'dea-t2-1', 'dea-t2-2', 'dea-t2-3', 'dea-t2-4',
    // D3 데이터 운영 및 지원 (22%) — 도메인 3 완료
    'dea-t3-1', 'dea-t3-2', 'dea-t3-3', 'dea-t3-4',
    // D4 데이터 보안 및 거버넌스 (18%) — 도메인 4 완료
    'dea-t4-1', 'dea-t4-2', 'dea-t4-3', 'dea-t4-4', 'dea-t4-5',
  ];
  const minPerTask = 15; // CLF 기준선과 동일한 Task당 밀도 목표

  /// 사람 검수를 마쳐 flip을 허용한 Task — **사람만 여기에 추가한다.**
  ///
  /// ⚠️ 2026-10-29까지 이 가드는 **전 문항 `verified: false`를 전수 단정**했다.
  /// 그러면 AI flip은 막히지만 **사람이 첫 Task를 flip하는 순간에도 깨져 flip
  /// 자체가 불가능**하다 — 이 파일은 `CERTS['dea'].tests`에 들어 있어
  /// `review.mjs flip dea <taskId>`가 **문항 파일을 다 쓴 뒤** 마지막에 돌린다
  /// (`--force`는 쓰기 **전** 구조 검사만 건너뛰어 소용없다). MLA가 #246에서
  /// 같은 함정에 걸렸고 허용 목록으로 풀었다.
  ///
  /// 지금은 보호 의도를 유지하면서 길을 연다: 이 목록에 **없는** Task는 전 문항이
  /// `verified: false`여야 하고, 목록에 넣는 행위가 곧 사람의 서명이다(flip 커밋의
  /// diff에 드러나므로 감사 추적이 된다). **그 추가를 `flip` 명령이 대신 해 준다**
  /// (`CERTS['dea'].flipAllowlist`).
  ///
  /// 판정은 `flip_allowlist.dart`의 순수 함수이고 양쪽 분기는
  /// `flip_allowlist_test.dart`가 합성 입력으로 검증한다 — 실제 콘텐츠에
  /// `verified: true`를 쓰지 않고도 "목록에 넣으면 통과한다"가 증명된다.
  ///
  /// 검수 절차·루브릭은 `docs/saa-review/review-rubric.md` C1~C6을 그대로 쓴다.
  /// 통합 모의고사 공개에 필요한 양은 도메인당 D1 22 · D2 17 · D3 14 · D4 12
  /// (연습 65문항에 공식 비중 배분)이고 Task는 15문항씩이라 **D1·D2는 2 Task씩,
  /// 합 6 Task 91문항**이면 게이트가 열린다.
  const flipApprovedTaskIds = <String>{'dea-t1-1', 'dea-t1-2', 'dea-t2-1', 'dea-t2-2', 'dea-t3-1', 'dea-t4-1', 'dea-t1-3', 'dea-t1-4', 'dea-t2-3'};

  for (final taskId in deaTaskIds) {
    group(taskId, () {
      final path = 'assets/content/dea/$taskId.questions.json';

      test('문항 파일이 존재한다', () {
        expect(File(path).existsSync(), isTrue,
            reason: '$path 가 없습니다 — 해당 도메인 배치 문항을 작성하세요.');
      });

      test('스키마·밀도 규칙을 만족한다', () {
        final file = File(path);
        if (!file.existsSync()) {
          fail('$path 없음(앞 테스트에서 보고됨)');
        }
        final map = json.decode(file.readAsStringSync()) as Map<String, dynamic>;
        expect(map['examGuideTaskId'], taskId);
        expect(map['certCode'], 'DEA-C01');

        final questions = (map['questions'] as List).cast<Map<String, dynamic>>();
        expect(questions.length, greaterThanOrEqualTo(minPerTask),
            reason: '$taskId 문항 수 ${questions.length} < $minPerTask');

        final ids = <String>{};
        for (final q in questions) {
          final qid = (q['id'] ?? '').toString();
          expect(qid, isNotEmpty);
          expect(ids.add(qid), isTrue, reason: '중복 id: $qid');
          expect((q['stem'] ?? '').toString(), isNotEmpty);
          expect((q['explanation'] ?? '').toString(), isNotEmpty);

          final options = (q['options'] as List);
          expect(options.length, 4, reason: '$qid options 4개 아님');

          final correct = (q['correct'] as num).toInt();
          expect(correct, inInclusiveRange(0, 3), reason: '$qid correct 범위 밖');

          final we = (q['wrongExplanations'] as Map);
          final keys = we.keys.map((k) => int.parse(k.toString())).toSet();
          // 정답이 아닌 0..3 인덱스 전부에 오답해설이 있어야 한다
          final expected = {0, 1, 2, 3}..remove(correct);
          expect(keys, expected, reason: '$qid wrongExplanations 키=비정답 인덱스 전부');

          final sources = (q['sources'] as List);
          expect(sources, isNotEmpty, reason: '$qid sources 비어있음');
          for (final s in sources.cast<Map<String, dynamic>>()) {
            expect((s['url'] ?? '').toString(), startsWith('http'));
            expect((s['title'] ?? '').toString(), isNotEmpty);
          }

          // `verified`는 bool이어야 한다. 값 자체는 아래 flip 허용 목록 가드가 본다.
          expect(q['verified'], isA<bool>(),
              reason: '$qid verified가 bool이 아니다');
        }
      });

      test('flip 허용 목록에 없으면 전 문항이 드래프트다 (AI flip 금지)', () {
        final map =
            json.decode(File(path).readAsStringSync()) as Map<String, dynamic>;
        final qs = (map['questions'] as List).cast<Map<String, dynamic>>();
        final flipped = flippedQuestionIds(qs);
        expect(
          flipAllowlistGuardPasses(
            approved: flipApprovedTaskIds,
            taskId: taskId,
            questions: qs,
          ),
          isTrue,
          reason: flipApprovedTaskIds.contains(taskId)
              ? '$taskId: flip 허용 목록에 있는데 verified 문항이 없다 — '
                  '검수를 끝냈으면 flip하고, 아직이면 목록에서 빼라'
              : '$taskId: 사람 검수 전인데 verified=true 문항이 있다 — '
                  'flip은 사람 전용이다. 검수를 마쳤다면 flipApprovedTaskIds에 '
                  '$taskId 을 추가하라:\n${flipped.take(5).join(', ')}',
        );
      });
    });
  }
}
