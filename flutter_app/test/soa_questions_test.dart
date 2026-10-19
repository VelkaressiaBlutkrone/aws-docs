import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// SOA-C03 문항 드래프트 구조·밀도 가드.
///
/// `QuestionBank.fromJson`은 verified 게이트로 비검증 문항을 제외하므로,
/// 드래프트(verified:false) 단계 검증은 raw JSON을 직접 파싱해 스키마를 확인한다
/// (saa_questions_test.dart·dea_questions_test.dart와 같은 패턴).
///
/// SOA 학습문서에는 `{#앵커}`가 없으므로(섹션 앵커는 CLF만 적용) `section` 키는
/// 쓰지 않는다 — 딥링크는 문서 최상단으로 graceful 폴백된다.
void main() {
  // 문항 작성을 완료한(드래프트 포함) 콘텐츠 엔트리 — 배치별로 누적 추가한다.
  // SOA 20개 엔트리 전부 문항 작성 완료(도메인 1~5). 추가 엔트리가 생기면 여기 누적한다.
  const soaTaskIds = [
    'soa-t1-1',
    'soa-t1-2',
    'soa-t1-3',
    'soa-t1-4',
    'soa-t1-5',
    'soa-t2-1',
    'soa-t2-2',
    'soa-t2-3',
    'soa-t2-4',
    'soa-t3-1',
    'soa-t3-2',
    'soa-t3-3',
    'soa-t3-4',
    'soa-t4-1',
    'soa-t4-2',
    'soa-t4-3',
    'soa-t5-1',
    'soa-t5-2',
    'soa-t5-3',
    'soa-t5-4',
  ];
  const minPerTask = 15; // CLF 기준선과 동일한 Task당 밀도 목표

  for (final taskId in soaTaskIds) {
    group(taskId, () {
      final path = 'assets/content/soa/$taskId.questions.json';

      test('문항 파일이 존재한다', () {
        expect(File(path).existsSync(), isTrue,
            reason: '$path 가 없습니다 — 도메인 1 배치 문항을 작성하세요.');
      });

      test('스키마·밀도 규칙을 만족한다', () {
        final file = File(path);
        if (!file.existsSync()) {
          fail('$path 없음(앞 테스트에서 보고됨)');
        }
        final map = json.decode(file.readAsStringSync()) as Map<String, dynamic>;
        expect(map['examGuideTaskId'], taskId);
        expect(map['certCode'], 'SOA-C03');

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
