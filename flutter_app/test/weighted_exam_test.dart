import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/models/attempt_record.dart';
import 'package:aws_docs/data/content_index.dart';
import 'package:aws_docs/data/task_score_report.dart';
import 'package:aws_docs/data/weighted_exam.dart';

const _tasks = {
  'clf-t2-1-q1': 'clf-t2-1',
  'clf-t2-1-q2': 'clf-t2-1',
  'clf-t3-1-q1': 'clf-t3-1',
  'clf-t4-1-q1': 'clf-t4-1',
};
const _order = ['clf-t2-1', 'clf-t3-1', 'clf-t4-1'];

AttemptRecord _rec({
  String certId = 'CLF-C02',
  required String examId,
  required String date,
  required List<String> presented,
  required List<String> wrong,
  String mode = 'practice',
}) => AttemptRecord(
  certId: certId,
  examId: examId,
  mode: mode,
  date: date,
  correct: presented.length - wrong.length,
  total: presented.length,
  wrongQuestionIds: wrong,
  flaggedQuestionIds: const [],
  presentedQuestionIds: presented,
  durationSpentSec: 60,
);

void main() {
  test('약점 Task 가중 > ok Task > 미응시(=floor), 전 Task ≥ floor', () {
    final report = TaskScoreReport.build(
      certId: 'CLF-C02',
      taskByQuestionId: _tasks,
      taskOrder: _order,
      history: [
        // t2-1: 둘 다 오답(0%) → 큰 가중
        _rec(
          examId: 'practice:clf-t2-1',
          date: '2026-06-01',
          presented: ['clf-t2-1-q1', 'clf-t2-1-q2'],
          wrong: ['clf-t2-1-q1', 'clf-t2-1-q2'],
        ),
        // t3-1: 정답(100%) → floor
        _rec(
          examId: 'practice:clf-t3-1',
          date: '2026-06-02',
          presented: ['clf-t3-1-q1'],
          wrong: [],
        ),
        // t4-1: 미응시
      ],
    );
    final w = weightByTaskFromReport(report, scale: 100, floor: 10);
    expect(w['clf-t2-1'], 110); // 10 + (1-0)*100
    expect(w['clf-t3-1'], 10); // 10 + (1-1)*100
    expect(w['clf-t4-1'], 10); // 미응시 → floor만
    expect(w.values.every((v) => v >= 10), isTrue); // 전 Task 출제 보장
    expect(w['clf-t2-1']! > w['clf-t3-1']!, isTrue);
  });

  test('게이트: 비-review 응시 3회 미만 잠김, 3회 해제', () {
    AttemptRecord r(String date, String mode) => AttemptRecord(
      certId: 'CLF-C02',
      examId: 'exam:CLF-C02-mock',
      mode: mode,
      date: date,
      correct: 1,
      total: 1,
      wrongQuestionIds: const [],
      flaggedQuestionIds: const [],
      durationSpentSec: 1,
    );
    final two = [r('2026-06-01', 'practice'), r('2026-06-02', 'exam')];
    final withReview = [...two, r('2026-06-03', 'review')]; // review 미포함
    final three = [...two, r('2026-06-04', 'exam')];

    expect(nonReviewAttemptCount('CLF-C02', two), 2);
    expect(weightedExamAttemptUnlocked('CLF-C02', two), isFalse);
    expect(
      weightedExamAttemptUnlocked('CLF-C02', withReview),
      isFalse,
    ); // 여전히 2회
    expect(nonReviewAttemptCount('CLF-C02', three), 3);
    expect(weightedExamAttemptUnlocked('CLF-C02', three), isTrue);
    expect(certWeightedExamUnlocked('CLF-C02', three), isTrue);
  });

  test('게이트: 타 cert 응시는 미포함', () {
    final h = [
      AttemptRecord(
        certId: 'SAA-C03',
        examId: 'x',
        mode: 'practice',
        date: '2026-06-01',
        correct: 1,
        total: 1,
        wrongQuestionIds: const [],
        flaggedQuestionIds: const [],
        durationSpentSec: 1,
      ),
    ];
    expect(nonReviewAttemptCount('CLF-C02', h), 0);
  });

  test('최종 게이트: 응시 3회여도 weighted capacity 부족이면 잠김', () {
    // ⚠️ **실제 cert 의 flip 상태에 묶지 않는다.** 전에는 "지금 잠긴 cert"를
    // 표본으로 썼고 그 표본이 SAA → MLA → DEA 로 두 번 이사했다(개방될 때마다
    // 이 테스트가 깨졌다). 콘텐츠 있는 5종이 전부 개방되면 옮길 곳이 없으므로,
    // 열린 cert(CLF-C02)에 "문항은 있는데 도메인 비중 미달"을 주입해 푼다.
    debugContentIndexOverride = const {
      'CLF-C02': [
        ContentEntry(
          certCode: 'CLF-C02',
          taskId: 'clf-t1-1',
          title: '합성 엔트리(문항 보유·비중 미달)',
          domain: 1,
          mdAsset: 'assets/content/clf/clf-t1-1.md',
          questionsAsset: 'assets/content/clf/clf-t1-1.questions.json',
          questionCount: 3,
        ),
      ],
    };
    addTearDown(() => debugContentIndexOverride = null);
    expect(certExamHasWeightedCapacity('CLF-C02'), isFalse,
        reason: '주입이 먹지 않으면 아래 단정이 거짓 통과한다');

    final history = [
      for (final d in ['2026-06-01', '2026-06-02', '2026-06-03'])
        _rec(
          examId: 'exam:CLF-C02-mock',
          date: d,
          presented: ['q$d'],
          wrong: const [],
        ),
    ];

    expect(weightedExamAttemptUnlocked('CLF-C02', history), isTrue);
    expect(certWeightedExamUnlocked('CLF-C02', history), isFalse);
  });
}
