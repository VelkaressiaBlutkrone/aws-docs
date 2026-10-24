import 'dart:math';

import 'exam_allocation.dart';
import '../models/question.dart';

/// 자격증 통합 모의고사용 순수 로직(샘플링·병합·복원). Flutter 무의존 → 단위 테스트 가능.

/// 키별 가중으로 n문항을 샘플링해 순서를 섞어 반환. [rng] 주입으로 결정적.
/// 특정 키 풀이 배분량보다 적으면 잔여 키 문항에서 보충(총 n 유지, 풀<n이면 최대).
List<Question> buildSampledExam<K>({
  required Map<K, List<Question>> poolByKey,
  required Map<K, int> weightByKey,
  required int n,
  required Random rng,
}) {
  final alloc = allocateByWeight<K>(weightByKey, n);
  final picked = <Question>[];
  final leftovers = <Question>[];

  final keys = <K>{...poolByKey.keys, ...alloc.keys}.toList();
  for (final k in keys) {
    final pool = [...?poolByKey[k]]..shuffle(rng);
    final want = alloc[k] ?? 0;
    final take = want < pool.length ? want : pool.length;
    picked.addAll(pool.take(take));
    leftovers.addAll(pool.skip(take));
  }

  if (picked.length < n && leftovers.isNotEmpty) {
    leftovers.shuffle(rng);
    picked.addAll(leftovers.take(n - picked.length));
  }

  picked.shuffle(rng);
  return picked;
}

/// 도메인 가중 통합 모의고사(호환 래퍼). 키=도메인 번호(int).
List<Question> buildMockExam({
  required Map<int, List<Question>> poolByDomain,
  required Map<int, int> weightByDomain,
  required int n,
  required Random rng,
}) => buildSampledExam<int>(
  poolByKey: poolByDomain,
  weightByKey: weightByDomain,
  n: n,
  rng: rng,
);

/// 로드한 뱅크들을 도메인 번호 → 검증 문항 리스트로 묶는다.
Map<int, List<Question>> groupByDomain(List<QuestionBank> banks) {
  final map = <int, List<Question>>{};
  for (final b in banks) {
    (map[b.domain] ??= <Question>[]).addAll(b.questions);
  }
  return map;
}

/// 문항 ID → 문항. 복원 시 사용.
Map<String, Question> indexById(Iterable<Question> questions) => {
  for (final q in questions) q.id: q,
};

// `restoreOrdered` 제거(2026-10-25, 스냅샷 체제 — 설계 2026-10-24 §4.7). 저장된 ID로
// 현재 풀에서 문항을 되찾던 함수인데, 스냅샷이 문항을 직접 들고 가면서 그 단계가 없어졌다.

/// Task 연습/시험 차출 수(스펙 §2). 풀이 이보다 작으면 전부 출제.
const taskSampleCount = 5;

/// 풀에서 n개 무작위 차출. 풀 ≤ n이면 전부. 반환 순서도 섞인다. [rng] 주입으로 결정적.
List<Question> samplePool(List<Question> pool, int n, Random rng) {
  final copy = [...pool]..shuffle(rng);
  return n < copy.length ? copy.sublist(0, n) : copy;
}

/// 문항별 선택지 표시 순서를 무작위 생성(questionId → 원본 인덱스 순열).
/// 생성(랜덤)과 적용(applyOptionOrders, 결정적)을 분리 — 복원·테스트 용이(스펙 §3.1).
Map<String, List<int>> randomOptionOrders(
  Iterable<Question> questions,
  Random rng,
) {
  final out = <String, List<int>>{};
  for (final q in questions) {
    out[q.id] = [for (var i = 0; i < q.options.length; i++) i]..shuffle(rng);
  }
  return out;
}

/// 생성/저장된 표시 순서를 적용. 순서가 없는 문항은 그대로 둔다.
List<Question> applyOptionOrders(
  List<Question> questions,
  Map<String, List<int>> orders,
) => [
  for (final q in questions)
    orders[q.id] == null ? q : q.withOptionOrder(orders[q.id]!),
];

// `ordersCoverQuestions` 제거(2026-10-25, 스냅샷 체제 — 설계 2026-10-24 §4.7). 복원 전
// 표시 순서 완비를 검증하던 함수인데, 스냅샷은 보기를 이미 표시 순서로 저장하므로
// 재적용할 순서 자체가 없다. 손상 방어는 `sanitizeProgress`가 맡는다.
