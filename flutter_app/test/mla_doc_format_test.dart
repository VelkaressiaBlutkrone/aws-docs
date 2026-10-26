import 'dart:io';

import 'package:aws_docs/content/markdown_parser.dart';
import 'package:aws_docs/models/study_content.dart';
import 'package:flutter_test/flutter_test.dart';

/// MLA-C01 학습문서 포맷 가드 — 2026-10-26 외부 리뷰 3건의 공통 지적을 기계화.
///
/// 리뷰가 세 도메인에 걸쳐 반복 지적한 것 중 **문서 포맷**에 해당하는 셋이다:
///   ① 자가 점검에 정답이 없다(3회 지적) → 접이식 `<details>` 정답을 요구
///   ② "시험 직전 요약"이 없다(2회 지적) → 전용 절을 요구
///   ③ 학습 목표가 너무 길다(2회 지적) → 항목 수 상한
///
/// ⚠️ 파서로 검증한다(`parseStudyDoc`). 이 레포의 학습문서 파서는 마크다운
/// **하위집합**이라 텍스트만 맞아도 화면에 안 보일 수 있다 — `<details>`는
/// `markdown_parser.dart`가 `MdDetails`로 인식하고 `study_markdown_view.dart`가
/// 렌더하므로, 블록이 실제로 생겼는지까지 확인한다.
///
/// 상한 8개는 다른 자격증의 실측 관행이다(DEA 7·8·8·9 · SAA 6). 소절 1:1 대조는
/// 학습 목표가 아니라 "이 문서가 다루는 것" 한 줄이 담당한다 — 그 줄 덕분에
/// 체크리스트를 줄여도 절 누락 점검이 가능하다(리뷰 반영 과정에서 실제 누락 3건을
/// 그 대조로 잡았다: t3-1 §5·§15, t3-2 §7).
void main() {
  const mlaTaskIds = [
    'mla-t1-1', 'mla-t1-2', 'mla-t1-3',
    'mla-t2-1', 'mla-t2-2', 'mla-t2-3',
    'mla-t3-1', 'mla-t3-2', 'mla-t3-3',
    'mla-t4-1', 'mla-t4-2', 'mla-t4-3',
  ];
  const maxObjectives = 8;
  const maxSummaryBullets = 10;

  for (final taskId in mlaTaskIds) {
    group(taskId, () {
      final path = 'assets/content/mla/$taskId.md';
      String raw() => File(path).readAsStringSync();

      test('학습 목표 체크리스트가 $maxObjectives개 이하다', () {
        final blocks = parseStudyDoc(raw()).blocks;
        final checklists = blocks.whereType<MdChecklist>().toList();
        expect(checklists, isNotEmpty, reason: '$taskId: 학습 목표 체크리스트가 없다');
        final count = checklists.first.items.length;
        expect(count, lessThanOrEqualTo(maxObjectives),
            reason: '$taskId: 학습 목표 $count개 — $maxObjectives개 이하로 압축하고 '
                '세부는 각 절로 넘긴다(소절 대조는 "이 문서가 다루는 것" 줄이 담당)');
      });

      test('"시험 직전 요약" 절이 있고 불릿이 $maxSummaryBullets개 이하다', () {
        final blocks = parseStudyDoc(raw()).blocks;
        final idx = blocks.indexWhere(
            (b) => b is MdHeading && b.text.contains('시험 직전 요약'));
        expect(idx, isNot(-1),
            reason: '$taskId: "시험 직전 요약" 절이 없다 — 시험 포인트 앞에 둔다');

        // 다음 ## 헤딩까지의 불릿 수를 센다.
        var bullets = 0;
        for (var i = idx + 1; i < blocks.length; i++) {
          final b = blocks[i];
          if (b is MdHeading && b.level <= 2) break;
          if (b is MdBullets) bullets += b.items.length;
        }
        expect(bullets, inInclusiveRange(1, maxSummaryBullets),
            reason: '$taskId: 요약 불릿 $bullets개 — 1~$maxSummaryBullets개여야 한다');
      });

      test('자가 점검의 모든 질문에 접이식 정답이 붙어 있다', () {
        final text = raw();
        final start = text.indexOf('## 🧪 자가 점검');
        expect(start, isNot(-1), reason: '$taskId: 자가 점검 절이 없다');
        // 자가 점검 다음 ## 절 전까지가 대상 구간.
        final after = text.indexOf('\n## ', start + 1);
        final section = after == -1 ? text.substring(start) : text.substring(start, after);

        final questions = RegExp(r'^\*\*Q\d+\.\*\*', multiLine: true)
            .allMatches(section)
            .length;
        final answers = RegExp(r'^<details><summary>정답 보기</summary>', multiLine: true)
            .allMatches(section)
            .length;
        final closes = RegExp(r'^</details>', multiLine: true).allMatches(section).length;

        expect(questions, greaterThanOrEqualTo(5),
            reason: '$taskId: 자가 점검 질문 $questions개 — "**Qn.**" 형식으로 5개 이상');
        expect(answers, questions,
            reason: '$taskId: 질문 $questions개 vs 접이식 정답 $answers개 — 모든 질문에 '
                '"<details><summary>정답 보기</summary>"를 붙인다');
        expect(closes, answers, reason: '$taskId: </details> 닫힘 $closes개 ≠ 열림 $answers개');

        // 파서가 실제로 MdDetails 블록으로 인식하는지(렌더 보장).
        final details = parseStudyDoc(text).blocks.whereType<MdDetails>().toList();
        expect(details.length, greaterThanOrEqualTo(questions),
            reason: '$taskId: 파서가 인식한 MdDetails ${details.length}개 < 질문 $questions개');
        expect(details.every((d) => d.summary.isNotEmpty), isTrue,
            reason: '$taskId: summary가 빈 접이식 블록이 있다');
        expect(details.every((d) => d.body.isNotEmpty), isTrue,
            reason: '$taskId: 본문이 빈 접이식 블록이 있다');
      });
    });
  }
}
