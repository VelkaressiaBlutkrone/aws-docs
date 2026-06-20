import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/content_index.dart';

void main() {
  test('certHasContent: 콘텐츠 보유 true, 미보유/미지정 false', () {
    expect(certHasContent('CLF-C02'), isTrue);
    expect(certHasContent('DVA-C02'), isFalse);
    expect(certHasContent('NOPE'), isFalse);
  });

  test('SAA-C03: 학습문서 보유 (문항 수는 동적 불변식으로 가드)', () {
    // verified flip 시 문항 수가 바뀌므로 0을 하드코딩하지 않는다.
    // questionCount의 정확성은 아래 "동적 불변식" 테스트가 보장한다.
    expect(certHasContent('SAA-C03'), isTrue);
    expect(certContentSummary('SAA-C03').docs, greaterThan(0));
  });

  test('certContentSummary: docs/questions 합산', () {
    final entries = contentFor('CLF-C02');
    var sum = 0;
    for (final e in entries) {
      sum += e.questionCount;
    }
    final s = certContentSummary('CLF-C02');
    expect(s.docs, entries.length);
    expect(s.questions, sum);
    expect(s.questions, greaterThan(0));
  });

  test('certContentSummary: 콘텐츠 없는 cert는 0', () {
    final s = certContentSummary('DVA-C02');
    expect(s.docs, 0);
    expect(s.questions, 0);
  });

  test('certHasVerifiedQuestions: 문항 있으면 true, 없으면 false', () {
    expect(certHasVerifiedQuestions('CLF-C02'), isTrue);
    expect(certHasVerifiedQuestions('NOPE'), isFalse);
  });

  test('ContentEntry.hasQuestions: questionCount>0과 1:1 (뱅크 로드 가드의 불변식)', () {
    // CLF는 모든 Task에 검증 문항 → 전부 로드 대상.
    expect(contentFor('CLF-C02').every((e) => e.hasQuestions), isTrue);
  });

  test('SOA-C03: 학습문서 20개 (문항 수는 동적 불변식으로 가드)', () {
    expect(certHasContent('SOA-C03'), isTrue);
    expect(certContentSummary('SOA-C03').docs, 20);
  });

  test('SOA-C03: 도메인별 문서 수 D1:5 D2:4 D3:4 D4:3 D5:4', () {
    final byDomain = <int, int>{};
    for (final e in contentFor('SOA-C03')) {
      byDomain[e.domain] = (byDomain[e.domain] ?? 0) + 1;
    }
    expect(byDomain, {1: 5, 2: 4, 3: 4, 4: 3, 5: 4});
  });

  // ── 동적 불변식 (T3, flip 회귀 가드) ──────────────────────────────
  // content_index의 questionCount는 그 Task .questions.json의 verified:true
  // 문항 수와 *항상* 일치해야 한다. 특정 숫자(예: SAA==0)에 의존하지 않으므로
  // 첫 SAA flip 시에도 깨지지 않고, flip 후 count 동기화 누락을 잡아낸다.
  // (saa_review.mjs flip이 verified 전환 + content_index questionCount를 함께
  //  갱신하므로 정상 워크플로에서는 항상 일치.)
  test('동적 불변식: 모든 Task questionCount == .questions.json verified 수', () {
    final mismatches = <String>[];
    for (final entry in kContentIndex.entries) {
      for (final e in entry.value) {
        final file = File(e.questionsAsset);
        var verified = 0;
        if (file.existsSync()) {
          final map = json.decode(file.readAsStringSync()) as Map<String, dynamic>;
          final qs = (map['questions'] as List?) ?? const [];
          verified =
              qs.where((q) => (q as Map<String, dynamic>)['verified'] == true).length;
        }
        if (e.questionCount != verified) {
          mismatches.add(
              '${e.certCode}/${e.taskId}: content_index=${e.questionCount} != JSON verified=$verified  (${e.questionsAsset})');
        }
      }
    }
    expect(mismatches, isEmpty,
        reason: 'content_index questionCount ↔ 실제 verified 수 불일치:\n${mismatches.join('\n')}');
  });

  // ── T4: 통합 모의고사 공개 게이트 (전 도메인 균형) ──────────────────
  group('examIsBalanced (순수): 전 도메인 검증 시에만 true', () {
    test('빈 목록 → false', () => expect(examIsBalanced(const []), isFalse));
    test('전 도메인 검증 → true', () {
      expect(examIsBalanced([_e(1, 15), _e(2, 15), _e(3, 15)]), isTrue);
    });
    test('부분 검증(일부 도메인만 verified) → false (편향 방지)', () {
      expect(examIsBalanced([_e(1, 15), _e(2, 0), _e(3, 0)]), isFalse);
    });
    test('전부 0 → false', () {
      expect(examIsBalanced([_e(1, 0), _e(2, 0)]), isFalse);
    });
    test('한 도메인에 여러 verified Task여도 다른 도메인 0이면 false', () {
      expect(examIsBalanced([_e(1, 15), _e(1, 15), _e(2, 0)]), isFalse);
    });
  });

  test('certExamIsBalanced: CLF balanced(true), SAA 현재 0(false), 미지정(false)', () {
    expect(certExamIsBalanced('CLF-C02'), isTrue);
    expect(certExamIsBalanced('SAA-C03'), isFalse);
    expect(certExamIsBalanced('NOPE'), isFalse);
  });
}

ContentEntry _e(int domain, int questionCount) => ContentEntry(
      certCode: 'X',
      taskId: 't$domain-$questionCount',
      title: '',
      domain: domain,
      mdAsset: '',
      questionsAsset: '',
      questionCount: questionCount,
    );
