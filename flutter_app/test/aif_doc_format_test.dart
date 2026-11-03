import 'dart:io';

import 'package:aws_docs/content/markdown_parser.dart';
import 'package:aws_docs/models/study_content.dart';
import 'package:flutter_test/flutter_test.dart';

/// AIF-C01 학습문서 포맷 가드 — DVA 판(`dva_doc_format_test.dart`)을 옮기고
/// **이 자격증 고유의 단정 하나**를 더했다.
///
/// 포맷 세 줄은 2026-10-26 MLA 외부 리뷰 3건이 반복 지적한 것이다:
///   ① 자가 점검에 정답이 없다 → 접이식 `<details>` 정답을 요구
///   ② "시험 직전 요약"이 없다 → 전용 절을 요구
///   ③ 학습 목표가 너무 길다 → 항목 수 상한 8
///
/// 네 번째(`domainName`)는 AIF 가이드가 **도메인 3을 한 페이지 안에서 두 가지로**
/// 적기 때문이다(도메인 페이지 제목은 "파운데이션 모델의 적용", 「내용 개요」는
/// "파운데이션 모델 적용"). 저작 결정 D-02가 **도메인 페이지 제목**을 쓰기로
/// 정했다 — 정본은 `docs/content-research/AIF-C01/98-authoring-decisions.md`다.
///
/// ⚠️ **AIF는 도메인이 5개다**(다른 자격증은 4개, SOA만 5개). 아래 표를 4개로
/// 줄이면 도메인 5 문서가 조용히 가드를 비켜 간다.
///
/// ⚠️ **목록은 배치마다 늘린다.** 저작된 Task만 올린다(점진적 롤아웃 —
/// `content_enrichment_test`·`dva_doc_format_test` 패턴). 문항 가드
/// `aif_questions_test.dart`가 생기면 **두 파일의 목록을 모두** 늘려야 한다
/// (MLA에서 한쪽만 늘려 빠뜨린 적이 있다 — CLAUDE.md 기준선 메모).
///
/// ⚠️ `content_enrichment_test`는 **명시 허용 목록**(clf·saa·soa)이라 AIF를
/// 강제하지 않는다. 그래서 `###` 서브섹션마다 `> 🧠 원리:`를 요구하는 규칙은
/// 이 자격증에 적용되지 않는다(MLA·DVA도 그렇다).
void main() {
  // 2026-11-03 도메인 1 배치.
  const aifTaskIds = [
    'aif-t1-1', 'aif-t1-2', 'aif-t1-3',
  ];
  const maxObjectives = 8;
  const maxSummaryBullets = 10;

  // 공식 도메인 페이지 제목 (저작 결정 D-02).
  const domainNames = <String, String>{
    '1': 'AI 및 ML의 기초',
    '2': 'GenAI의 기초',
    '3': '파운데이션 모델의 적용',
    '4': '책임 있는 AI에 대한 가이드라인',
    '5': 'AI 솔루션의 보안, 규정 준수 및 거버넌스',
  };

  for (final taskId in aifTaskIds) {
    group(taskId, () {
      final path = 'assets/content/aif/$taskId.md';
      String raw() => File(path).readAsStringSync();

      test('학습 목표 체크리스트가 $maxObjectives개 이하다', () {
        final blocks = parseStudyDoc(raw()).blocks;
        final checklists = blocks.whereType<MdChecklist>().toList();
        expect(checklists, isNotEmpty, reason: '$taskId: 학습 목표 체크리스트가 없다');
        final count = checklists.first.items.length;
        expect(count, lessThanOrEqualTo(maxObjectives),
            reason: '$taskId: 학습 목표 $count개 — $maxObjectives개 이하로 압축하고 '
                '세부는 각 절로 넘긴다');
      });

      test('"시험 직전 요약" 절이 있고 불릿이 $maxSummaryBullets개 이하다', () {
        final blocks = parseStudyDoc(raw()).blocks;
        final idx = blocks.indexWhere(
            (b) => b is MdHeading && b.text.contains('시험 직전 요약'));
        expect(idx, isNot(-1),
            reason: '$taskId: "시험 직전 요약" 절이 없다 — 시험 포인트 앞에 둔다');

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
        final after = text.indexOf('\n## ', start + 1);
        final section =
            after == -1 ? text.substring(start) : text.substring(start, after);

        final questions = RegExp(r'^\*\*Q\d+\.\*\*', multiLine: true)
            .allMatches(section)
            .length;
        final answers =
            RegExp(r'^<details><summary>정답 보기</summary>', multiLine: true)
                .allMatches(section)
                .length;
        final closes =
            RegExp(r'^</details>', multiLine: true).allMatches(section).length;

        expect(questions, greaterThanOrEqualTo(5),
            reason: '$taskId: 자가 점검 질문 $questions개 — "**Qn.**" 형식으로 5개 이상');
        expect(answers, questions,
            reason: '$taskId: 질문 $questions개 vs 접이식 정답 $answers개');
        expect(closes, answers,
            reason: '$taskId: </details> 닫힘 $closes개 ≠ 열림 $answers개');

        final details =
            parseStudyDoc(text).blocks.whereType<MdDetails>().toList();
        expect(details.length, greaterThanOrEqualTo(questions),
            reason: '$taskId: 파서가 인식한 MdDetails ${details.length}개 '
                '< 질문 $questions개');
        expect(details.every((d) => d.summary.isNotEmpty), isTrue,
            reason: '$taskId: summary가 빈 접이식 블록이 있다');
        expect(details.every((d) => d.body.isNotEmpty), isTrue,
            reason: '$taskId: 본문이 빈 접이식 블록이 있다');
      });

      test('프런트매터의 domainName이 공식 도메인 페이지 제목과 같다', () {
        final text = raw();
        final domain = RegExp(r'^domain:\s*(\d)\s*$', multiLine: true)
            .firstMatch(text)
            ?.group(1);
        expect(domain, isNotNull, reason: '$taskId: 프런트매터에 domain이 없다');
        final name = RegExp(r'^domainName:\s*(.+)$', multiLine: true)
            .firstMatch(text)
            ?.group(1)
            ?.trim();
        expect(name, domainNames[domain],
            reason: '$taskId: domainName="$name" — 공식 도메인 페이지 제목은 '
                '"${domainNames[domain]}"이다(저작 결정 D-02). '
                '도메인 3의 「내용 개요」 표기 "파운데이션 모델 적용"을 쓰지 않는다');
      });
    });
  }

  // 저작 결정 D-05: 공식 문항 유형 4종 설명은 **도메인 1 첫 편에만** 둔다.
  // 14편에 반복하면 소음이 되고, 빠지면 응시자가 시험장에서 처음 본다.
  test('시험 형식 안내는 aif-t1-1에만 있다', () {
    const marker = '## 🧭 시험 형식';
    final t11 = File('assets/content/aif/aif-t1-1.md').readAsStringSync();
    expect(t11.contains(marker), isTrue,
        reason: 'aif-t1-1: 시험 형식 절이 없다 — 문항 유형 4종과 채점 규칙은 '
            '도메인 1 첫 편에서 한 번 설명한다(저작 결정 D-05)');

    for (final taskId in aifTaskIds.where((t) => t != 'aif-t1-1')) {
      final text = File('assets/content/aif/$taskId.md').readAsStringSync();
      expect(text.contains(marker), isFalse,
          reason: '$taskId: 시험 형식 절이 중복됐다 — aif-t1-1에만 둔다');
    }
  });
}
