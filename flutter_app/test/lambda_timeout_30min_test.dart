import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Lambda 함수 타임아웃 상한 정정(15분 → 30분) 회귀 가드.
///
/// 공식 근거(2026-11-22 확인):
/// - `lambda/latest/dg/configuration-timeout.html` — "up to a maximum value of
///   1,800 seconds (30 minutes)"
/// - `lambda/latest/dg/gettingstarted-limits.html` — "Function timeout 1,800
///   seconds (30 minutes)". Managed Instances 의 비동기·이벤트 소스 매핑 호출은
///   Amazon MQ·DocumentDB 를 빼고 5,400초(90분)
/// - `aws.amazon.com/lambda/faqs/` 만 아직 15분으로 적는다 — 그래서 문서마다
///   메모를 한 번 둔다.
///
/// ⚠️ 「15분」·「900초」를 전역 금지하면 안 된다. API Gateway 응답 스트림,
/// Firehose 버퍼, IAM DB 인증 토큰, 스케일링 쿨다운, S3 RTC 는 전부 참인 값이다.
const _memo = '2026년 11월 상향 전 자료와 FAQ에는 15분으로 적힌 곳이 있습니다.';

const _root = 'assets/content';

final _old = RegExp(r'15\s*분|900\s*초');

/// Lambda 이름 바로 뒤에 옛 상한이 오는 단정.
final _lambdaClaim = RegExp(r'(Lambda|람다)[^.。|\n]{0,40}(15\s*분|900\s*초)');

/// 본문을 고친 학습문서 → 메모를 뺀 뒤 남아야 하는 무관한 15분·900초 수.
const _docs = <String, int>{
  'clf/t3-3.md': 0,
  'dea/dea-t1-1.md': 2, // Kinesis 온디맨드 급증 15분 · Firehose 버퍼 간격 0~900초
  'dea/dea-t1-2.md': 2, // Glue 잡 큐잉 최대 15분 · API Gateway 응답 스트리밍 15분
  'dea/dea-t1-3.md': 0,
  'dea/dea-t1-4.md': 0,
  'dea/dea-t3-1.md': 1, // EMR Serverless 워커 유휴 15분
  'dva/dva-t1-2.md': 0,
  'mla/mla-t3-1.md': 3, // SageMaker 비동기 처리 15분 2곳 · InvocationTimeoutSeconds 900초
  'saa/saa-t2-2.md': 0,
  'saa/saa-t3-4.md': 0,
};

/// 옛 상한이 한 글자도 남으면 안 되는 문항.
const _fixedQuestions = <String>[
  'saa-t2-2-q3',
  'saa-t2-2-q14',
  'saa-t3-4-q1',
  'saa-t3-4-q2',
  'saa-t3-4-q4',
  'saa-t3-4-q8',
  'saa-t3-4-q13',
  'dea-t1-2-q1',
  'mla-t3-1-q22',
];

String _read(String rel) => File('$_root/$rel').readAsStringSync();

Iterable<File> _files(String suffix) => Directory(_root)
    .listSync(recursive: true)
    .whereType<File>()
    .where((f) => f.path.endsWith(suffix))
    .where((f) => !f.path.contains('.omc'));

List<Map<String, dynamic>> _questionsOf(File f) {
  final d = jsonDecode(f.readAsStringSync());
  final list = d is Map ? d['questions'] as List : d as List;
  return list.cast<Map<String, dynamic>>();
}

Map<String, Map<String, dynamic>> _allQuestions() => {
      for (final f in _files('.questions.json'))
        for (final q in _questionsOf(f)) q['id'] as String: q,
    };

List<String> _fields(Map<String, dynamic> q) => [
      q['stem'] as String,
      ...(q['options'] as List).cast<String>(),
      q['explanation'] as String,
      ...(q['wrongExplanations'] as Map).values.cast<String>(),
      ...(q['sources'] as List).map((s) => (s as Map)['title'] as String),
    ];

void main() {
  late Map<String, Map<String, dynamic>> questions;

  setUpAll(() => questions = _allQuestions());

  group('대조군', () {
    test('대상 파일을 실제로 읽었다', () {
      for (final rel in _docs.keys) {
        expect(_read(rel), contains('Lambda'), reason: rel);
      }
      expect(questions.length, greaterThan(2000));
      for (final id in _fixedQuestions) {
        expect(questions, contains(id));
      }
    });

    test('Lambda 타임아웃이 아닌 15분·900초는 그대로 남아 있다', () {
      expect(_read('aip/aip-t2-5.md'), contains('스트림은 **최대 15분**'));
      expect(_read('mla/mla-t1-1.md'), contains('0–900초'));
      expect(_read('mla/mla-t1-2.md'), contains('0–900초'));
      expect(questions['scs-t5-3-q3']!['explanation'], contains('15분'));
      expect(questions['mla-t3-2-q8']!['options'], contains('양방향 각각 900초'));
      expect(questions['dea-t1-2-q14']!['options'][3], contains('기본 900초'));
    });
  });

  group('Lambda 상한 30분', () {
    test('전 자격증 md·문항에 Lambda 를 15분·900초로 단정하는 문구가 없다', () {
      final hits = <String>[];
      for (final f in _files('.md')) {
        final lines = f.readAsStringSync().split('\n');
        for (var i = 0; i < lines.length; i++) {
          if (_lambdaClaim.hasMatch(lines[i].replaceAll(_memo, ''))) {
            hits.add('${f.path}:${i + 1}');
          }
        }
      }
      for (final e in questions.entries) {
        if (_fields(e.value).any(_lambdaClaim.hasMatch)) hits.add(e.key);
      }
      expect(hits, isEmpty, reason: hits.join('\n'));
    });

    test('고친 학습문서에는 메모와 무관한 값 외의 15분·900초가 없다', () {
      _docs.forEach((rel, allowed) {
        final body = _read(rel).replaceAll(_memo, '');
        expect(_old.allMatches(body).length, allowed, reason: rel);
      });
    });

    test('고친 학습문서는 30분 또는 1,800초를 적는다', () {
      for (final rel in _docs.keys) {
        expect(_read(rel), matches(RegExp(r'30분|1,800초')), reason: rel);
      }
    });

    test('고친 문항에 옛 상한이 남지 않는다', () {
      for (final id in _fixedQuestions) {
        final hit = _fields(questions[id]!).where(_old.hasMatch).toList();
        expect(hit, isEmpty, reason: id);
      }
    });

    test('dea-t1-2-q14: Lambda 한도만 바뀌고 API Gateway 값은 유지된다', () {
      final q = questions['dea-t1-2-q14']!;
      expect(q['explanation'], contains('Lambda 자체 한도는 1,800초'));
      expect((q['wrongExplanations'] as Map)['1'], contains('1,800초'));
      expect(q['explanation'], contains('응답 스트리밍(최대 15분)'));
    });

    test('Managed Instances 90분 구분이 유지된다', () {
      expect(_read('saa/saa-t2-2.md'), contains('5,400초(90분)'));
      expect(_read('saa/saa-t3-4.md'), contains('최대 90분'));
      expect(_read('mla/mla-t3-1.md'), contains('5,400초'));
      expect(questions['saa-t3-4-q2']!['explanation'], contains('5,400초(90분)'));
      expect(questions['saa-t2-2-q3']!['explanation'], contains('최대 90분'));
    });
  });

  group('지문 전제 문항', () {
    test('정답이 교체 전과 같다', () {
      const expected = {
        'saa-t2-2-q3': 2,
        'saa-t3-4-q2': 1,
        'saa-t3-4-q8': 2,
        'mla-t3-1-q22': 0,
      };
      expected.forEach((id, correct) {
        expect(questions[id]!['correct'], correct, reason: id);
      });
    });

    test('지문이 30분을 넘는 시나리오다', () {
      for (final id in ['saa-t2-2-q3', 'saa-t3-4-q2', 'mla-t3-1-q22']) {
        final stem = questions[id]!['stem'] as String;
        expect(stem, contains('40분'), reason: id);
        expect(stem, isNot(contains('20분')), reason: id);
      }
      expect(questions['saa-t3-4-q8']!['stem'], contains('수 시간'));
      expect(_read('saa/saa-t2-2.md'), contains('40분 이상 실행되는 배치'));
    });
  });

  group('상향 메모', () {
    test('고친 문서마다 정확히 한 번이다', () {
      for (final rel in _docs.keys) {
        expect(_memo.allMatches(_read(rel)).length, 1, reason: rel);
      }
    });

    test('메모 전수는 문서 수와 같고 문항에는 없다', () {
      var total = 0;
      for (final f in _files('.md')) {
        total += _memo.allMatches(f.readAsStringSync()).length;
      }
      expect(total, _docs.length);
      final inQuestions = questions.entries
          .where((e) => _fields(e.value).any((v) => v.contains('상향 전')))
          .map((e) => e.key);
      expect(inQuestions, isEmpty);
    });
  });
}
