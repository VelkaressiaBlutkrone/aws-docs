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
    expect(review.dateIso, '2026-07-01'); // = endIso (period 모드의 마지막 학습일 = finalReview)
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

  test('혼합 cert: doc는 전부, quiz는 hasQuestions만', () {
    final mixed = [
      _e('m1', 1, q: 12),
      _e('m2', 1, q: 0),
      _e('m3', 2, q: 12),
      _e('m4', 2, q: 0),
    ];
    final r = buildPlan(
      certCode: 'CLF-C02', content: mixed,
      startIso: '2026-06-01', endIso: '2026-06-20', mode: PlanMode.period,
    );
    expect(r.items.where((i) => i.type == PlanItemType.doc).length, 4);
    expect(r.items.where((i) => i.type == PlanItemType.quiz).length, 2);
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

  test('redistribute: 완료 보존 + 미완을 오늘~끝에 재배치', () {
    final plan = StudyPlan(
      certCode: 'CLF-C02', startIso: '2026-06-01', endIso: '2026-06-20',
      mode: PlanMode.period, createdIso: '2026-06-01',
      items: const [
        PlanItem(id: 'a', dateIso: '2026-06-02', type: PlanItemType.doc, phase: PlanPhase.learn, refId: 'clf-t1'),
        PlanItem(id: 'b', dateIso: '2026-06-03', type: PlanItemType.doc, phase: PlanPhase.learn, refId: 'clf-t2'),
        PlanItem(id: 'c', dateIso: '2026-06-04', type: PlanItemType.doc, phase: PlanPhase.learn, refId: 'clf-t3'),
      ],
    );
    final r = redistribute(plan, '2026-06-10', {'a'}); // a 완료
    final byId = {for (final i in r.items) i.id: i};
    expect(byId['a']!.dateIso, '2026-06-02'); // 완료는 보존
    expect(byId['b']!.dateIso.compareTo('2026-06-10') >= 0, isTrue);
    expect(byId['c']!.dateIso.compareTo('2026-06-10') >= 0, isTrue);
  });

  test('redistribute: 남은 기간 없으면 경고', () {
    final plan = StudyPlan(
      certCode: 'CLF-C02', startIso: '2026-06-01', endIso: '2026-06-05',
      mode: PlanMode.period, createdIso: '2026-06-01',
      items: const [
        PlanItem(id: 'a', dateIso: '2026-06-02', type: PlanItemType.doc, phase: PlanPhase.learn),
      ],
    );
    final r = redistribute(plan, '2026-06-10', {});
    expect(r.warnings, isNotEmpty);
  });

  test('redistribute: 전체 완료 → 완료 항목만 그대로', () {
    final plan = StudyPlan(
      certCode: 'CLF-C02', startIso: '2026-06-01', endIso: '2026-06-20',
      mode: PlanMode.period, createdIso: '2026-06-01',
      items: const [
        PlanItem(id: 'a', dateIso: '2026-06-02', type: PlanItemType.doc, phase: PlanPhase.learn),
        PlanItem(id: 'b', dateIso: '2026-06-03', type: PlanItemType.doc, phase: PlanPhase.learn),
      ],
    );
    final r = redistribute(plan, '2026-06-10', {'a', 'b'});
    expect(r.items.map((i) => i.id).toSet(), {'a', 'b'});
    expect(r.warnings, isEmpty);
  });

  test('redistribute: 미완 항목 > 남은 일수 → 경고', () {
    final plan = StudyPlan(
      certCode: 'CLF-C02', startIso: '2026-06-18', endIso: '2026-06-20',
      mode: PlanMode.period, createdIso: '2026-06-18',
      items: const [
        PlanItem(id: 'a', dateIso: '2026-06-18', type: PlanItemType.doc, phase: PlanPhase.learn),
        PlanItem(id: 'b', dateIso: '2026-06-18', type: PlanItemType.doc, phase: PlanPhase.learn),
        PlanItem(id: 'c', dateIso: '2026-06-19', type: PlanItemType.doc, phase: PlanPhase.learn),
        PlanItem(id: 'd', dateIso: '2026-06-19', type: PlanItemType.doc, phase: PlanPhase.learn),
        PlanItem(id: 'e', dateIso: '2026-06-20', type: PlanItemType.doc, phase: PlanPhase.learn),
      ],
    );
    final r = redistribute(plan, '2026-06-19', {}); // winStart=6/19, lastDay=6/20 → 2일, 5개
    expect(r.warnings.any((w) => w.contains('재배치')), isTrue);
  });
}
