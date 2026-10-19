import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

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

          // 드래프트 단계: 사람 검수 전이므로 verified는 false여야 한다(AI flip 금지).
          expect(q['verified'], isFalse,
              reason: '$qid verified=true — flip은 사람 검수 전용이다');
        }
      });
    });
  }
}
