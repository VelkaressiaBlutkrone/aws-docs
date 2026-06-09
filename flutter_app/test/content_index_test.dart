import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/content_index.dart';

void main() {
  test('certHasContent: 콘텐츠 보유 true, 미보유/미지정 false', () {
    expect(certHasContent('CLF-C02'), isTrue);
    expect(certHasContent('DVA-C02'), isFalse);
    expect(certHasContent('NOPE'), isFalse);
  });

  test('SAA-C03: 학습문서 보유하나 문항은 0(학습문서만 상태)', () {
    expect(certHasContent('SAA-C03'), isTrue);
    expect(certHasVerifiedQuestions('SAA-C03'), isFalse);
    expect(certContentSummary('SAA-C03').questions, 0);
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
    // SAA는 학습문서만(문항 0) → 전부 로드 생략 대상(questions.json 404 방지).
    expect(contentFor('SAA-C03').any((e) => e.hasQuestions), isFalse);
  });

  test('SOA-C03: 학습문서 20개·문항 0·게이트 잠금 (SAA와 동일 패턴)', () {
    expect(certHasContent('SOA-C03'), isTrue);
    expect(certHasVerifiedQuestions('SOA-C03'), isFalse);
    final s = certContentSummary('SOA-C03');
    expect(s.docs, 20);
    expect(s.questions, 0);
    expect(contentFor('SOA-C03').any((e) => e.hasQuestions), isFalse);
  });

  test('SOA-C03: 도메인별 문서 수 D1:5 D2:4 D3:4 D4:3 D5:4', () {
    final byDomain = <int, int>{};
    for (final e in contentFor('SOA-C03')) {
      byDomain[e.domain] = (byDomain[e.domain] ?? 0) + 1;
    }
    expect(byDomain, {1: 5, 2: 4, 3: 4, 4: 3, 5: 4});
  });
}
