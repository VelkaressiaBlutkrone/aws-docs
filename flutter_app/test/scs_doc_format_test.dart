import 'dart:io';

import 'package:aws_docs/content/markdown_parser.dart';
import 'package:aws_docs/models/study_content.dart';
import 'package:flutter_test/flutter_test.dart';

/// SCS-C03 학습문서 포맷 가드 — AIF 판(`aif_doc_format_test.dart`)을 옮겼다.
///
/// 포맷 세 줄은 2026-10-26 MLA 외부 리뷰 3건이 반복 지적한 것이다:
///   ① 자가 점검에 정답이 없다 → 접이식 `<details>` 정답을 요구
///   ② "시험 직전 요약"이 없다 → 전용 절을 요구
///   ③ 학습 목표가 너무 길다 → 항목 수 상한 8
///
/// 네 번째(`domainName`)와 다섯 번째(시험 형식 중복 금지)는 AIF에서 가져왔다.
/// SCS 가이드는 AIF와 달리 **도메인 이름을 한 가지로만** 적지만(2026-11-08 실측),
/// 선언을 두면 저작자가 도메인 이름을 임의로 바꿔 쓰는 것을 막는다. 도메인 이름의
/// 정본은 `assets/exam_guides/SCS-C03.json`이고 그 JSON은 2026-11-08 P-03에서
/// 공식과 **70/70 바이트 일치**로 맞춰 뒀다.
///
/// ⚠️ **SCS는 도메인이 6개다** — 이 레포에서 처음이다(다른 자격증은 4개, SOA·AIF가
/// 5개). 아래 표를 5개로 줄이면 도메인 6 문서가 조용히 가드를 비켜 간다.
///
/// ⚠️ **목록은 배치마다 늘린다.** 저작된 Task만 올린다(점진적 롤아웃 —
/// `content_enrichment_test`·`aif_doc_format_test` 패턴). 문항 가드
/// `scs_questions_test.dart`가 생기면 **두 파일의 목록을 모두** 늘려야 한다
/// (MLA에서 한쪽만 늘려 빠뜨린 적이 있다 — CLAUDE.md 기준선 메모).
///
/// ⚠️ `content_enrichment_test`는 **명시 허용 목록**(clf·saa·soa)이라 SCS를
/// 강제하지 않는다. 그래서 `###` 서브섹션마다 `> 🧠 원리:`를 요구하는 규칙은
/// 이 자격증에 적용되지 않는다(MLA·DVA·AIF도 그렇다).
void main() {
  // 2026-11-08 도메인 1·2 배치 — 공식 Task 16개 중 5개.
  const scsTaskIds = [
    'scs-t1-1', 'scs-t1-2', 'scs-t1-3',
    'scs-t2-1', 'scs-t2-2',
  ];
  const maxObjectives = 8;
  const maxSummaryBullets = 10;

  // 공식 도메인 이름 (`SCS-C03.json` = 공식 가이드 전사, 2026-11-08 실측).
  const domainNames = <String, String>{
    '1': '탐지',
    '2': '인시던트 대응',
    '3': '인프라 보안',
    '4': 'ID 및 액세스 관리',
    '5': '데이터 보호',
    '6': '보안 기반 및 거버넌스',
  };

  for (final taskId in scsTaskIds) {
    group(taskId, () {
      final path = 'assets/content/scs/$taskId.md';
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

      test('프런트매터의 domainName이 공식 도메인 이름과 같다', () {
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
            reason: '$taskId: domainName="$name" — 공식 도메인 이름은 '
                '"${domainNames[domain]}"이다(`SCS-C03.json`이 정본)');
      });
    });
  }

  // 공식 답안 유형 4종 설명은 **도메인 1 첫 편에만** 둔다(AIF 저작 결정 D-05의 SCS 판).
  // 16편에 반복하면 소음이 되고, 빠지면 응시자가 시험장에서 처음 본다.
  test('시험 형식 안내는 scs-t1-1에만 있다', () {
    const marker = '## 🧭 시험 형식';
    final t11 = File('assets/content/scs/scs-t1-1.md').readAsStringSync();
    expect(t11.contains(marker), isTrue,
        reason: 'scs-t1-1: 시험 형식 절이 없다 — 답안 유형 4종과 채점 규칙은 '
            '도메인 1 첫 편에서 한 번 설명한다');

    for (final taskId in scsTaskIds.where((t) => t != 'scs-t1-1')) {
      final text = File('assets/content/scs/$taskId.md').readAsStringSync();
      expect(text.contains(marker), isFalse,
          reason: '$taskId: 시험 형식 절이 중복됐다 — scs-t1-1에만 둔다');
    }
  });

  // 2026-11-08 조사가 찾은 두 가지를 저작 규율로 고정한다. 둘 다 "공식 가이드가
  // 드는 예시 자체가 낡았거나 갈린" 자리라 저작자가 무심코 틀리기 쉽다.
  //
  // ① `Security Hub`는 두 제품이다(저작 결정 D-09 — 조사 노트 93 §2).
  //    CSPM은 ASFF·표준 점검, 신 Security Hub는 OCSF·노출 조사 결과다.
  // ② 공식 `기술 1.2.2`가 드는 "CloudWatch Logs 에이전트"는 **폐지된 구 에이전트**다
  //    (2026-11-08 실측: "The older logs agent is deprecated" · IMDSv2에서는 통합
  //    에이전트 필수 · AL2023에는 패키지가 없다). 축은 **통합 CloudWatch 에이전트**다.
  group('도메인 1 저작 규율', () {
    test('Security Hub를 CSPM과 신 제품으로 갈라 쓴다', () {
      for (final taskId in scsTaskIds) {
        final text = File('assets/content/scs/$taskId.md').readAsStringSync();
        if (!text.contains('Security Hub')) continue;
        expect(text.contains('Security Hub CSPM'), isTrue,
            reason: '$taskId: `Security Hub`를 언급하면서 `Security Hub CSPM`을 '
                '한 번도 쓰지 않았다 — 표준 점검·ASFF 층과 노출·OCSF 층을 가른다'
                '(저작 결정 D-09)');
      }
    });

    test('구 CloudWatch Logs 에이전트를 현행처럼 적지 않는다', () {
      final t12 = File('assets/content/scs/scs-t1-2.md').readAsStringSync();
      expect(t12.contains('통합 CloudWatch 에이전트'), isTrue,
          reason: 'scs-t1-2: 로깅 에이전트의 축은 **통합 CloudWatch 에이전트**다');
      // 구 에이전트를 언급하는 것 자체는 옳다(가이드가 예시로 들기 때문이다).
      // 다만 **폐지 상태를 적어야** 한다 — D-04-b의 "상태를 적는다" 규율.
      if (t12.contains('CloudWatch Logs 에이전트')) {
        expect(RegExp(r'폐지|더 이상 지원').hasMatch(t12), isTrue,
            reason: 'scs-t1-2: 구 `CloudWatch Logs 에이전트`를 언급하면 '
                '**폐지 상태를 함께 적는다**(공식 가이드가 예시로 드는 기능이 '
                '이미 폐지된 자리다 — 저작 결정 D-04-b)');
      }
    });
  });
}
