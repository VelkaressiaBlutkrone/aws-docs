import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 2026-11-22 대본 검수로 고친 SAA 학습문서의 **문항 쪽 후속** 가드.
///
/// 판정 정본: `docs/audits/2026-11-22-audio-script-review/02-docfix-saa-d12.md`
/// (A11·A14) · `02-docfix-saa-d34.md`(A-02·A-03·A-08·A-10·A-12·A-21).
///
/// 대상 11문항은 전부 라이브이고 **정답 인덱스는 한 건도 바뀌지 않는다.**
/// 고치지 않은 두 문항의 이유:
/// - `saa-t2-5-q11`: 지문이 이미 「Multi-AZ DB 인스턴스 배포(스탠바이 1개)」로
///   한정한다. `saa_v2_fix_test` 가 이 문항을 「지문이 한정하면 보기는 한정어
///   없이 동기를 말해도 된다」의 대조군으로 쓴다.
/// - `saa-t3-2-q6`: 「재부팅 보존, 중지·종료 소실」은 공식의 일부를 요약한 참인
///   서술이고 소실 조건이 그 둘뿐이라고 단정하지 않는다.
Map<String, dynamic> _question(String qid) {
  final task = qid.substring(0, qid.lastIndexOf('-'));
  final file = File('assets/content/saa/$task.questions.json');
  final decoded =
      jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  return (decoded['questions'] as List)
      .cast<Map<String, dynamic>>()
      .firstWhere((q) => q['id'] == qid);
}

String _allText(Map<String, dynamic> q) => <String>[
      q['stem'] as String,
      ...(q['options'] as List).cast<String>(),
      q['explanation'] as String,
      ...(q['wrongExplanations'] as Map).values.cast<String>(),
      for (final s in (q['sources'] as List).cast<Map<String, dynamic>>())
        s['title'] as String,
    ].join('\n');

bool _hasSource(Map<String, dynamic> q, String url) =>
    (q['sources'] as List)
        .cast<Map<String, dynamic>>()
        .any((s) => s['url'] == url);

void main() {
  // HEAD(ca6517d)에서 덤프한 실측값이다.
  const correctAtHead = <String, int>{
    'saa-t2-2-q7': 0,
    'saa-t2-5-q8': 0,
    'saa-t3-3-q12': 1,
    'saa-t2-4-q4': 1,
    'saa-t2-5-q11': 0,
    'saa-t3-5-q2': 1,
    'saa-t3-7-q13': 2,
    'saa-t3-7-q15': 2,
    'saa-t4-4-q6': 3,
    'saa-t3-2-q6': 1,
    'saa-t3-6-q6': 1,
  };

  const cases = <({
    String qid,
    List<String> forbidden,
    List<String> required,
    List<String> sources,
  })>[
    (
      qid: 'saa-t2-2-q7',
      forbidden: ['저지연'],
      required: ['낮은 요금', '요금이 낮아도 서버 Push가 불가능'],
      sources: [
        'https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-vs-rest.html',
      ],
    ),
    (
      qid: 'saa-t2-5-q8',
      forbidden: ['1분 내', '전형적 수치'],
      required: ['RTO는 분 단위', '제품 페이지는 1분 미만을 제시'],
      sources: [
        'https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-global-database-disaster-recovery.html',
        'https://aws.amazon.com/rds/aurora/global-database/',
      ],
    ),
    (
      qid: 'saa-t3-3-q12',
      forbidden: ['인스턴스 수 제한'],
      required: ['인스턴스 수는 계정 한도까지'],
      sources: [],
    ),
    (
      qid: 'saa-t2-4-q4',
      forbidden: ['RDS Multi-AZ는 비동기'],
      required: ['Multi-AZ DB 인스턴스 배포는 비동기 복제가 아닌'],
      sources: [],
    ),
    (
      qid: 'saa-t3-5-q2',
      forbidden: ['Multi-AZ의 방식'],
      required: ['Multi-AZ DB 인스턴스 배포의 방식'],
      sources: [],
    ),
    (
      qid: 'saa-t3-7-q13',
      forbidden: ['GLB', 'L3/L4'],
      required: ['GWLB(Gateway Load Balancer)', 'GWLB는 L3에서'],
      sources: [
        'https://docs.aws.amazon.com/elasticloadbalancing/latest/gateway/introduction.html',
      ],
    ),
    (
      qid: 'saa-t3-7-q15',
      forbidden: ['GLB'],
      required: ['GWLB(Gateway Load Balancer)', 'GWLB는 방화벽'],
      sources: [],
    ),
    (
      qid: 'saa-t4-4-q6',
      forbidden: ['200개'],
      required: ['다수의 AWS 서비스'],
      sources: [],
    ),
    (
      qid: 'saa-t3-6-q6',
      forbidden: ['스로틀 없이', '가장 효과적으로'],
      required: ['미리 설정하지 않고', '2배', '30분 안에'],
      sources: [
        'https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/on-demand-capacity-mode.html',
      ],
    ),
  ];

  group('SAA 문서 정정 후속 문항', () {
    test('대조군: 문항 파일을 실제로 읽는다', () {
      final q = _question('saa-t3-7-q15');
      expect(q['stem'] as String, contains('/api/orders/*'));
      expect((q['options'] as List).length, 4);
    });

    test('대상 11문항의 정답 인덱스가 HEAD 와 같다', () {
      expect(
        {for (final id in correctAtHead.keys) id: _question(id)['correct']},
        correctAtHead,
      );
    });

    for (final c in cases) {
      test('${c.qid}: 옛 문구 0건 + 새 사실 있음', () {
        final q = _question(c.qid);
        final text = _allText(q);
        expect(q['correct'], correctAtHead[c.qid]);
        for (final f in c.forbidden) {
          expect(text.contains(f), isFalse, reason: '남은 옛 문구: $f');
        }
        for (final r in c.required) {
          expect(text.contains(r), isTrue, reason: '없는 새 사실: $r');
        }
        for (final s in c.sources) {
          expect(_hasSource(q, s), isTrue, reason: '없는 출처: $s');
        }
      });
    }
  });
}
