import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/content_index.dart';
import 'package:aws_docs/models/study_plan.dart';
import 'package:aws_docs/data/plan_scheduler.dart';

ContentEntry _e(String task, int domain, {int q = 12}) => ContentEntry(
      certCode: 'CLF-C02',
      taskId: task,
      title: task,
      domain: domain,
      mdAsset: 'a.md',
      questionsAsset: 'a.json',
      questionCount: q,
    );

final _clf = [for (var i = 1; i <= 6; i++) _e('clf-t$i', i)];

void main() {
  test('날짜 헬퍼', () {
    expect(addDays('2026-06-10', 5), '2026-06-15');
    expect(addDays('2026-06-30', 1), '2026-07-01');
    expect(daysBetween('2026-06-10', '2026-06-24'), 14);
  });

  test('기본 플랜: 모든 단계 항목 + 날짜는 창 안', () {
    final r = buildPlan(
      certCode: 'CLF-C02', content: _clf,
      startIso: '2026-06-10', endIso: '2026-06-24', mode: PlanMode.examDate,
    );
    expect(r.items, isNotEmpty);
    for (final it in r.items) {
      expect(it.dateIso.compareTo('2026-06-10') >= 0, isTrue);
      expect(it.dateIso.compareTo('2026-06-23') <= 0, isTrue, reason: it.dateIso);
    }
    expect(r.items.where((i) => i.type == PlanItemType.doc).length, 6);
    expect(r.items.where((i) => i.type == PlanItemType.quiz).length, 6);
    expect(r.items.where((i) => i.type == PlanItemType.mockExam).length >= 3, isTrue);
    expect(r.items.where((i) => i.type == PlanItemType.weakExam).length, 1);
    expect(r.items.where((i) => i.type == PlanItemType.finalReview).length, 1);
  });

  test('단계 순서: learn 날짜 ≤ reinforce 날짜', () {
    final r = buildPlan(
      certCode: 'CLF-C02', content: _clf,
      startIso: '2026-06-01', endIso: '2026-07-01', mode: PlanMode.period,
    );
    final firstDoc = r.items.firstWhere((i) => i.type == PlanItemType.doc);
    final review = r.items.firstWhere((i) => i.type == PlanItemType.finalReview);
    expect(firstDoc.dateIso.compareTo(review.dateIso) <= 0, isTrue);
    expect(review.dateIso, '2026-07-01');
  });

  test('결정성: 같은 입력 → 같은 결과', () {
    PlanBuildResult run() => buildPlan(
        certCode: 'CLF-C02', content: _clf,
        startIso: '2026-06-01', endIso: '2026-06-20', mode: PlanMode.period);
    final a = run().items.map((e) => '${e.id}@${e.dateIso}').toList();
    final b = run().items.map((e) => '${e.id}@${e.dateIso}').toList();
    expect(a, b);
  });

  test('문항 0 자격증: learn(문서)만 + 경고', () {
    final docsOnly = [for (var i = 1; i <= 4; i++) _e('saa-t$i', i, q: 0)];
    final r = buildPlan(
      certCode: 'SAA-C03', content: docsOnly,
      startIso: '2026-06-01', endIso: '2026-06-20', mode: PlanMode.period,
    );
    expect(r.items.every((i) => i.type == PlanItemType.doc), isTrue);
    expect(r.items.length, 4);
    expect(r.warnings.any((w) => w.contains('검증 문항이 없어')), isTrue);
  });

  test('빡빡한 기간 경고', () {
    final r = buildPlan(
      certCode: 'CLF-C02', content: _clf,
      startIso: '2026-06-10', endIso: '2026-06-12', mode: PlanMode.period,
    );
    expect(r.warnings.any((w) => w.contains('빡빡')), isTrue);
  });

  test('경계: 1일 플랜·역전·빈 콘텐츠', () {
    final one = buildPlan(
      certCode: 'CLF-C02', content: _clf,
      startIso: '2026-06-10', endIso: '2026-06-10', mode: PlanMode.period,
    );
    expect(one.items.every((i) => i.dateIso == '2026-06-10'), isTrue);

    final rev = buildPlan(
      certCode: 'CLF-C02', content: _clf,
      startIso: '2026-06-10', endIso: '2026-06-01', mode: PlanMode.period,
    );
    expect(rev.items, isEmpty);
    expect(rev.warnings, isNotEmpty);

    final empty = buildPlan(
      certCode: 'CLF-C02', content: const [],
      startIso: '2026-06-10', endIso: '2026-06-20', mode: PlanMode.period,
    );
    expect(empty.items, isEmpty);
  });
}
