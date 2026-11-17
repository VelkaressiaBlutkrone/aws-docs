import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 백서 재소싱 반영 가드 — 2026-11-17.
///
/// ## 왜 필요한가
///
/// 2026-11-17 WA 문서 재구성 감사에서 `whitepapers/latest/**` 33자리가 **브라우저로
/// 열면 다른 서비스 페이지로 리다이렉트**되는 것을 확인했다. 그런데 **본문은 사라지지
/// 않았다** — AWS 문서 리더로 읽으면 그대로 나오고 docs 검색 색인에도 있다. 그래서
/// 레포는 「인용 유지 + 상태 명시」로 처리해 왔고(`AWS CAF for AI`·SAA 백서 5종 선례)
/// 그 판정은 지금도 유효하다. **이 가드는 백서를 추방하지 않는다.**
///
/// 이 배치가 실제로 한 일은 셋이다.
///
/// 1. **되살아난 URL 의 낡은 상태 메모를 걷었다.** `aws-vpc-connectivity-options/`
///    두 페이지는 2026-11-17 실측에서 `200 r=0` 으로 **정상 복귀**했다. 메모를 그대로
///    두면 학습자가 살아 있는 출처를 못 믿는다.
/// 2. **인용 사실을 담은 라이브 정본이 따로 있는 자리를 그쪽으로 옮겼다**(4건).
///    「URL 은 200인데 그 페이지에 그 사실이 없다」의 반대편 — 백서를 쓸 이유가 없는데
///    쓰고 있던 자리다.
/// 3. **그 문항이 인용하지 않는 백서 줄을 지웠다**(2건). AIF 교훈: 죽은 출처가 교체가
///    아니라 **중복 삭제**로 닫히는 경우가 있다 — 해설이 이미 정본을 인용하고 있었다.
///
/// 실측·판정의 정본은 `docs/saa-review/2026-11-17-wa-restructure-source-audit.md`.
///
/// ## ⚠️ 귀속과 출처는 함께 움직인다
///
/// 백서 줄을 지우면서 「백서가 …라고 적습니다」를 남기면 **출처 없는 귀속**이 된다.
/// 거꾸로 백서를 **유지한** 문항(`mla-t4-3-q12` — SCP 가드레일 예제 묶음이 백서
/// 고유다)에서 귀속 문장을 지우면 인용이 떠 버린다. 그래서 이 가드는 수치가 아니라
/// **짝**을 본다: 「백서」 귀속이 있으면 그 문항에 백서 출처가 있어야 한다(역은 아니다 —
/// 백서를 쓰면서 제목으로만 밝히는 것은 정당하다).
///
/// ## ⚠️ `.md` 와 문항은 다른 층이다
///
/// 아직 리다이렉트하는 백서는 `.md` 참고자료에 **상태 메모와 함께 그대로 남는다**.
/// 문항에서 지운 두 백서(`model-interpretability`·`networking-architecture`)가 md 에
/// 1건씩 남아 있는 것은 누락이 아니라 그 정책이다 — 그래서 아래 0건 단정은 **문항
/// 파일만** 센다.
void main() {
  const wpPrefix = 'https://docs.aws.amazon.com/whitepapers/latest/';

  /// 2026-11-17 실측에서 `200 r=0` 으로 되살아난 백서 URL(상태 메모를 걷었다).
  const revivedUrls = <String>[
    '${wpPrefix}aws-vpc-connectivity-options/aws-transit-gateway-vpn.html',
    '${wpPrefix}aws-vpc-connectivity-options/aws-privatelink.html',
  ];

  /// 상태 메모 문구 두 어형 — 같은 뜻을 레포가 두 가지로 적는다.
  const memoPhrases = <String>[
    '브라우저로는 다른 서비스 페이지로 리다이렉트',
    '브라우저로 열면 서비스 페이지로 리다이렉트',
  ];

  /// 재소싱·삭제한 백서 URL → 그 자리를 대신하는 라이브 정본(없으면 삭제).
  const resourced = <String, List<String>>{
    // ① dea-t1-2-q1 — 900초는 Lambda 쿼터 페이지가 직접 적는다.
    '${wpPrefix}big-data-analytics-options/aws-lambda.html': [
      'dea/dea-t1-2.questions.json'
          '|https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-limits.html',
    ],
    // ② saa-t2-1.md — AppFlow 는 서비스 사용자 안내서가 정본이다.
    '${wpPrefix}patterns-for-ingesting-saas-data-into-aws-data-lakes/'
        'purpose-built-integration-service.html': [
      'saa/saa-t2-1.md'
          '|https://docs.aws.amazon.com/appflow/latest/userguide/what-is-appflow.html',
      'saa/saa-t2-1.md'
          '|https://docs.aws.amazon.com/appflow/latest/userguide/flows.html',
    ],
    // ③ mla-t4-3.md — 데이터 카탈로그·검색은 Lake Formation 정본이다.
    '${wpPrefix}building-data-lakes/data-cataloging.html': [
      'mla/mla-t4-3.md'
          '|https://docs.aws.amazon.com/lake-formation/latest/dg/what-is-lake-formation.html',
    ],
  };

  /// 문항에서 **지운** 백서(해설이 인용하지 않았다) — md 참고자료에는 남는다.
  const droppedFromQuestions = <String>[
    '${wpPrefix}ml-best-practices-healthcare-life-sciences/model-interpretability.html',
    '${wpPrefix}build-secure-enterprise-ml-platform/networking-architecture.html',
  ];

  final root = Directory('assets/content');
  final files = root
      .listSync()
      .whereType<Directory>()
      .expand((d) => d.listSync().whereType<File>())
      .where((f) => f.path.endsWith('.md') || f.path.endsWith('.questions.json'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  final questionFiles =
      files.where((f) => f.path.endsWith('.questions.json')).toList();

  String rel(File f) => f.path.replaceAll('\\', '/').split('assets/content/').last;

  test('대조군: 콘텐츠 파일이 읽혔고 백서 인용은 그대로 남아 있다', () {
    // 0건 통과가 "파일을 못 읽어서"일 수 있다 — 먼저 센다.
    expect(files.length, greaterThanOrEqualTo(150));
    final wpUrls = <String>{};
    for (final f in files) {
      for (final m in RegExp(r'whitepapers/latest/[A-Za-z0-9\-/]+\.html')
          .allMatches(f.readAsStringSync())) {
        wpUrls.add(m.group(0)!);
      }
    }
    // ⚠️ 이 배치는 백서를 추방하지 않았다 — 31개(2026-11-17 실측)가 그대로 쓰인다.
    expect(wpUrls.length, greaterThanOrEqualTo(20),
        reason: '백서 인용이 급감했다면 「인용 유지 + 상태 명시」 정책이 깨진 것이다');
  });

  test('대조군: 아직 리다이렉트하는 백서에는 상태 메모가 달려 있다', () {
    // 되살아난 둘만 걷었다 — 메모 탐지기가 아무것도 못 찾으면 아래 0건 단정이 공허하다.
    var memoLines = 0;
    for (final f in files) {
      for (final line in f.readAsStringSync().split('\n')) {
        if (memoPhrases.any(line.contains)) memoLines++;
      }
    }
    expect(memoLines, greaterThanOrEqualTo(8),
        reason: '상태 메모가 사라졌다면 메모를 일괄 삭제한 것이다(되살아난 둘만 걷는다)');
  });

  group('되살아난 백서 URL 에는 낡은 상태 메모가 없다', () {
    for (final url in revivedUrls) {
      test(url.replaceFirst(wpPrefix, ''), () {
        var cited = 0;
        final bad = <String>[];
        for (final f in files) {
          for (final line in f.readAsStringSync().split('\n')) {
            if (!line.contains(url)) continue;
            cited++;
            if (memoPhrases.any(line.contains)) bad.add('${rel(f)}: $line');
          }
        }
        // 인용 자체가 사라지면 "메모 없음"이 공허하게 통과한다.
        expect(cited, greaterThanOrEqualTo(1),
            reason: '이 URL 은 2026-11-17 실측에서 200 r=0 으로 살아 있다 — 인용을 지울 이유가 없다');
        expect(bad, isEmpty,
            reason: '2026-11-17 실측에서 리다이렉트가 사라졌다 — 메모가 학습자를 오해시킨다:\n'
                '${bad.join('\n')}');
      });
    }
  });

  group('재소싱한 백서 URL 이 레포에서 사라졌고 정본이 그 자리에 있다', () {
    resourced.forEach((oldUrl, targets) {
      test(oldUrl.replaceFirst(wpPrefix, ''), () {
        final hits = files
            .where((f) => f.readAsStringSync().contains(oldUrl))
            .map(rel)
            .toList();
        expect(hits, isEmpty, reason: '재소싱한 백서 URL 이 되살아났다: $hits');
        // 지우기만 하면 위 단정은 통과한다 — 정본이 실재하는지 함께 본다.
        for (final t in targets) {
          final parts = t.split('|');
          final f = File('assets/content/${parts[0]}');
          expect(f.existsSync(), isTrue, reason: '${parts[0]} 가 없다');
          expect(f.readAsStringSync().contains(parts[1]), isTrue,
              reason: '${parts[0]} 에 정본 ${parts[1]} 가 없다');
        }
      });
    });
  });

  group('문항에서 지운 백서는 문항 파일에 0건이다(md 참고자료는 유지한다)', () {
    for (final url in droppedFromQuestions) {
      test(url.replaceFirst(wpPrefix, ''), () {
        final hits = questionFiles
            .where((f) => f.readAsStringSync().contains(url))
            .map(rel)
            .toList();
        expect(hits, isEmpty,
            reason: '그 문항의 해설이 인용하지 않는 출처였다 — 다시 달지 않는다: $hits');
        // 대조군: md 쪽에는 상태 메모와 함께 남아 있다(정책이지 누락이 아니다).
        final inMd = files
            .where((f) => f.path.endsWith('.md'))
            .where((f) => f.readAsStringSync().contains(url))
            .length;
        expect(inMd, greaterThanOrEqualTo(1),
            reason: 'md 참고자료의 백서는 「인용 유지 + 상태 명시」로 남긴다');
      });
    }
  });

  test('백서를 유지한 문항은 그대로다 — 전부 지운 것이 아니다', () {
    // SCP 가드레일 예제 묶음은 백서 고유라 `mla-t4-3-q12` 는 백서를 계속 인용한다.
    const kept = '${wpPrefix}build-secure-enterprise-ml-platform/'
        'governance-and-control.html';
    final hits = questionFiles
        .where((f) => f.readAsStringSync().contains(kept))
        .map(rel)
        .toList();
    expect(hits, ['mla/mla-t4-3.questions.json'],
        reason: '유지 판정이 뒤집혔다 — 이 백서만이 적는 사실을 인용하는 문항이다');
  });

  // ⚠️⚠️ 「백서」 토큰 하나는 귀속 탐지기가 **아니다**. 전수로 재니 `clf/t4-3-q15`·`q1`
  // 의 8자리가 걸렸고 전부 정당했다 — 그 문항들은 **자료 종류로서의 백서**를(블로그·
  // 포럼·가이드와 나란히) 묻는다. 「기술」을 말하기 동사로 넣으면 「기술 자료」·「기술
  // 리소스」가 또 걸린다(실측 3건). 그래서 트리거는 **백서 + 조사 + 말하기 동사**이고,
  // 그 좁힘이 공허하지 않다는 것은 아래 대조군이 고정한다.
  final attribution = RegExp(
      r'백서[가은는의에서]{0,2}\s*[^\n]{0,40}?'
      r'(?:적|말|설명|제시|권|인용|비교|정의|분류|싣|드는|든다|적는|적습|적고)');

  List<String> taughtHits(Map<String, dynamic> q) {
    // 출처 제목은 제외하고 **가르치는 본문**에서만 센다.
    final taught = <String>[
      q['stem'] as String? ?? '',
      ...(q['options'] as List<dynamic>? ?? const <dynamic>[]).cast<String>(),
      q['explanation'] as String? ?? '',
      ...((q['wrongExplanations'] as Map<String, dynamic>? ??
              const <String, dynamic>{})
          .values
          .cast<String>()),
    ].join('\n');
    return attribution.allMatches(taught).map((m) => m.group(0)!).toList();
  }

  bool hasWpSource(Map<String, dynamic> q) =>
      (q['sources'] as List<dynamic>? ?? const <dynamic>[])
          .cast<Map<String, dynamic>>()
          .any((s) => (s['url'] as String).contains('/whitepapers/latest/'));

  test('「백서」 귀속이 있으면 그 문항에 백서 출처가 있다', () {
    // ⚠️ 한 방향이다 — 역은 아니다(백서를 쓰면서 출처 제목으로만 밝히는 것은 정당하다:
    // `saa-t3-8-q4` 가 그렇다).
    final orphans = <String>[];
    for (final f in questionFiles) {
      final bank = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
      for (final raw in bank['questions'] as List<dynamic>) {
        final q = raw as Map<String, dynamic>;
        if (hasWpSource(q)) continue;
        for (final hit in taughtHits(q)) {
          orphans.add('${rel(f)} ${q['id']}: $hit');
        }
      }
    }
    expect(orphans, isEmpty,
        reason: '백서 출처가 없는 문항이 백서에 귀속한다 — 출처를 달거나 사실 서술로 바꾼다:\n'
            '${orphans.join('\n')}');
  });

  test('대조군: 그 탐지기는 백서를 유지한 문항의 귀속을 실제로 찾는다', () {
    // 0건이 "탐지기가 아무것도 못 찾아서"일 수 있다 — 백서 출처가 있는 쪽에서 센다.
    var found = 0;
    for (final f in questionFiles) {
      final bank = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
      for (final raw in bank['questions'] as List<dynamic>) {
        final q = raw as Map<String, dynamic>;
        if (hasWpSource(q)) found += taughtHits(q).length;
      }
    }
    expect(found, greaterThanOrEqualTo(3),
        reason: '2026-11-17 실측 5건(aif-t2-3-q4 · aif-t3-2-q12 · saa-t2-5-q4×3)');
  });

  test('재작성한 귀속 문장은 문항에서 사라졌다', () {
    // ⚠️ 어형으로 뚫릴 수 있는 리터럴 가드다 — 위의 짝 단정이 일반 방향을 맡고,
    // 이 둘은 이 배치가 실제로 고친 문장의 회귀만 막는다.
    final rewritten = <String, String>{
      '백서의 가드레일 예제는 이 값이': 'mla-t4-3-q13 — 그 문항은 백서 줄을 잃었다',
      '계층 방어 체크리스트': 'mla-t4-3-q25 — 백서 고유 용어였다',
    };
    final bad = <String>[];
    rewritten.forEach((phrase, why) {
      for (final f in questionFiles) {
        if (f.readAsStringSync().contains(phrase)) bad.add('${rel(f)}: $phrase ($why)');
      }
    });
    expect(bad, isEmpty, reason: bad.join('\n'));
    // 대조군: 백서를 **유지한** q12 의 귀속 문장은 그대로 있어야 한다.
    final t = File('assets/content/mla/mla-t4-3.questions.json').readAsStringSync();
    expect(t.contains('백서의 가드레일 예제는 CreateTrainingJob'), isTrue,
        reason: 'q12 는 백서를 계속 인용한다 — 귀속을 지우면 인용이 떠 버린다');
  });

  test('Resolver QPS 는 공식 쿼터의 단위로 적는다', () {
    // ⚠️ G-67: URL 을 바꾸면 그 URL 이 업고 있던 사실을 하나씩 다시 센다. 백서 줄에서
    // QPS 를 떼고 공식 쿼터 페이지로 옮겼더니 본문이 아직 「ENI당」으로 적고 있었다.
    final t = File('assets/content/saa/saa-t3-8.md').readAsStringSync();
    expect(t.contains('ENI당 약 10,000 QPS'), isFalse,
        reason: '공식은 **IP 주소당**이고 엔드포인트당 IP 는 6개까지다');
    expect(t.contains('IP 주소당 UDP DNS 10,000 QPS'), isTrue);
    expect(
        t.contains(
            'https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/DNSLimitations.html'),
        isTrue,
        reason: '수치를 적으면 그 수치를 적는 페이지를 출처로 단다');
    // NLB·연결 추적이면 1,500 까지 내려간다 — 수치만 적으면 거꾸로 오해한다.
    expect(t.contains('1,500'), isTrue);
    // 백서 줄(#18)에서는 QPS 를 떼었다.
    for (final line in t.split('\n')) {
      if (line.contains('hybrid-cloud-dns-options-for-vpc')) {
        expect(line.contains('QPS'), isFalse,
            reason: '그 수치는 공식 쿼터 페이지가 적는다 — 백서 줄에서 떼었다');
      }
    }
  });

  test('손댄 문항의 구조는 그대로다', () {
    // ⚠️ `verified` 는 보지 않는다 — flip 은 사람의 작업이고, 상태를 단정한 가드가
    // 2026-11-13 검수자의 첫 SCS flip 을 레드로 끝냈다.
    const touched = <String, List<String>>{
      'dea/dea-t1-2.questions.json': ['dea-t1-2-q1'],
      'mla/mla-t2-1.questions.json': ['mla-t2-1-q11'],
      'mla/mla-t4-3.questions.json': [
        'mla-t4-3-q12',
        'mla-t4-3-q13',
        'mla-t4-3-q25',
      ],
      'saa/saa-t3-8.questions.json': ['saa-t3-8-q4'],
    };
    const correctIndex = <String, int>{
      'dea-t1-2-q1': 0,
      'mla-t2-1-q11': 1,
      'mla-t4-3-q12': 0,
      'mla-t4-3-q13': 0,
      'mla-t4-3-q25': 0,
      'saa-t3-8-q4': 0,
    };
    var seen = 0;
    touched.forEach((path, ids) {
      final bank = jsonDecode(File('assets/content/$path').readAsStringSync())
          as Map<String, dynamic>;
      for (final raw in bank['questions'] as List<dynamic>) {
        final q = raw as Map<String, dynamic>;
        final id = q['id'] as String;
        if (!ids.contains(id)) continue;
        seen++;
        expect((q['options'] as List<dynamic>).length, 4, reason: id);
        expect(q['correct'], correctIndex[id], reason: '$id 의 정답 인덱스가 바뀌었다');
        expect((q['sources'] as List<dynamic>), isNotEmpty, reason: '$id 의 출처가 비었다');
      }
    });
    expect(seen, correctIndex.length, reason: '손댄 문항을 다 찾지 못했다');
  });
}
