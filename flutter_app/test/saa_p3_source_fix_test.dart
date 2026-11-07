import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 2026-11-06 전 콘텐츠 2단 검토의 **SAA `§4-9`(출처가 전부 소개 페이지) 1차**와
/// **`§4-3`(범위 목록 비매칭) 판정 기록** 가드.
///
/// 보고서 정본: `docs/audits/2026-11-06-full-content-review/saa-c03.md` §4-3·§4-9.
/// 손댄 문항은 **전부 라이브**이고 **정답 인덱스·`verified` 는 한 건도 바뀌지
/// 않았다.**
///
/// ## 범위를 어떻게 좁혔는가 (사용자 승인)
///
/// `§4-9` 는 「92건을 일괄 교체하라」가 **아니라** 「한 건씩 재면 몇 건은 교체
/// 대상」이라는 작업량 추정이다. 그래서 **수치·상한·기본값을 단정하는 문항**부터
/// 쟀다(소개 페이지가 그런 수치를 담는 일은 드물다).
///
/// 2026-11-07 실측: SAA 360문항 중 **출처가 전부 소개류인 것 99건**, 그중
/// **2자리 이상 수치를 단정하는 것 27건**. 그 27건의 인용 페이지를 **전부 내려받아
/// 수치 문자열로 탐침**했고(대조군: SQS 소개 페이지에서 `1 MiB`·`4 days` 가 잡히고
/// `256 KB`·`30 second` 는 안 잡힌다), **2자리 이상 수치가 인용 페이지에 하나도
/// 없는 것이 10건**이었다.
///
/// ⚠️⚠️ **그 10건을 그대로 「결함」으로 세지 않았다.** 수치가 **문항이 만든 시나리오
/// 값**이면 인용 페이지가 그 숫자를 담을 이유가 없다 — 담아야 하는 것은 **기제**다.
/// 키워드로 다시 재서 갈랐다:
///
/// - `saa-t1-5-q11`(30일 보존) — `whatisbackup.html` 에 `lifecycle` 4 ·
///   `backup plan` 11 · `retention` 1 → **기제를 담는다.** 손대지 않음
/// - `saa-t2-1-q3`(30초/45초) — `visibility timeout` 2 → **기제를 담는다.** 손대지 않음
/// - `saa-t2-3-q7`(최소 2·원하는 4·최대 10) — `minimum` 3 · `desired` 4 →
///   **세 용량 개념을 담는다.** 손대지 않음
/// - `saa-t3-5-q5` · `saa-t4-2-q12` · `saa-t2-1-q12` · `saa-t3-4-q13` ·
///   `saa-t4-5-q1` · `saa-t4-5-q15` — 수치가 **인용 페이지에 실재**한다. 손대지 않음
///   (⭐ 「소개 페이지 = 틀린 출처」가 아니라는 보고서의 경고가 실측으로 확인됐다)
///
/// 남은 **8문항**이 「인용 페이지에 그 사실이 없다」다 — 이 배치가 닫는 것이다.
///
/// ## 비자명한 공식 사실 (직접 인용)
///
/// ⚠️⚠️ **EventBridge 재시도 기본값은 버스 종류마다 다르다** — `saa-t2-1-q7` 이
/// 「기본 5회 또는 300초」로 적는데, **클래식 규칙 대상의 기본값은 24시간·185회**다
/// (`eb-rule-retry-policy.html`: `By default, EventBridge retries sending the
/// event for 24 hours and up to 185 times`). 5회·300초는 **사용자 지정 이벤트 버스**
/// 구독자의 기본값이고(`eb-custom-bus-retry.html` 의 표: `MaxRetryAttempts` 0–185
/// **기본 5** · `MaxEventAgeInSeconds` 60–86,400 **기본 300**), 같은 페이지가
/// `The defaults are shorter than a Custom Event Bus - Classic target's 24 hours
/// and 185 attempts.` 로 **둘의 차이를 못박는다.** 그래서 숫자를 지우지 않고
/// **어느 버스의 기본값인지 한정**했다.
///
/// ⚠️ **Step Functions** — `choosing-workflow-type.html` 이 `long-running (up to
/// one year)` · `90 days` · `five minutes` 를 모두 적는다(SFN 소개 페이지에는
/// 90·1년 수치가 없다).
///
/// ⚠️ **Lambda 15분** — `gettingstarted-limits.html` 에 `900` · `15 minutes`.
/// EKS·Batch 소개 페이지에는 **`Lambda` 가 0건**이다.
///
/// ⚠️ **RDS gp3** — `CHAP_Storage.html` 에 `gp3` 25 · `3,000 IOPS` 7 ·
/// `125 MiB/s` 4. RDS 소개 페이지에는 **`gp3` 가 0건**이다.
///
/// ⚠️ **EFS 수명 주기** — `lifecycle-management-efs.html` 에 `Infrequent Access` 2 ·
/// `30 days` 1. EFS 소개 페이지에는 **`lifecycle` 이 0건**이다.
///
/// ⚠️ **VPC 피어링 완전 메시** — `n(n-1)/2` 는 **산술**이라 공식 페이지가 적지
/// 않는다(`mesh` 0건). 공식이 적는 것은 **비전이성**이다(`vpc-peering-basics.html`
/// 의 `transitive` 2 · `two VPCs` 3) — 쌍마다 연결이 따로 필요하다는 근거가 그것이고,
/// 그 페이지를 더했다.
///
/// ## `§4-3` — 고치지 않는다는 판정을 가드로 고정한다
///
/// `saa-t2-5-q10`(Elastic Disaster Recovery)·`saa-t4-3-q13`(Timestream for
/// InfluxDB)의 정답 보기 서비스가 공식 「범위 내 AWS 서비스」 목록에 없다는 지적이다.
/// **고치지 않는다** — ① 목록 머리말이 스스로 *「이 목록은 전체 목록이 아니며 변경될
/// 수 있습니다」* 라고 밝혀 **「목록에 없다」가 「범위 밖」이 아니고**(이 레포가 CLF
/// 범위 메모 배치에서 이미 못박은 규율), ② 같은 보고서 `§4-4` 가 `saa-t4-3-q13` 을
/// **「교과서적」**이라고 칭찬해 두 절이 서로 엇갈린다. ⭐ 2026-11-07 MLA 배치의
/// 교훈대로 **「고치지 않는다」는 결정도 가드로 고정**해야 다음 검수가 같은 항목을
/// 또 올리지 않는다.
void main() {
  const content = 'assets/content';

  List<File> saaFiles() => Directory('$content/saa')
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.questions.json'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  List<Map<String, dynamic>> questionsOf(File f) =>
      ((json.decode(f.readAsStringSync()) as Map<String, dynamic>)['questions']
              as List)
          .cast<Map<String, dynamic>>();

  Iterable<Map<String, dynamic>> allSaa() => saaFiles().expand(questionsOf);

  Map<String, dynamic> question(String qid) =>
      allSaa().firstWhere((q) => q['id'] == qid, orElse: () => fail('$qid 없음'));

  List<String> urls(Map<String, dynamic> q) => (q['sources'] as List)
      .cast<Map<String, dynamic>>()
      .map((s) => s['url'] as String)
      .toList();

  /// 서비스 「소개」류 페이지인가 — 2026-11-07 측정에 쓴 것과 같은 표식이다.
  bool isIntro(String url) => const <String>[
        '/welcome',
        'Welcome.html',
        'what-is',
        'whatis',
        'Introduction.html',
        'introduction.html',
        'WhatIs',
        // ⚠️ `CHAP_` 접두사 전체를 표식으로 쓰면 안 된다 — RDS 사용 설명서의
        //    **장(chapter) 접두사**라서 `CHAP_Storage.html`(gp3 수치가 실제로
        //    적힌 페이지)까지 「소개류」로 잡힌다. 실제로 이 가드가 그렇게
        //    걸렸다. 소개 페이지인 것은 `CHAP_AuroraOverview` 쪽이다.
        'CHAP_AuroraOverview',
        'overview.html',
      ].any(url.contains);

  /// 문항이 **수치·상한·기본값을 단정**하는가.
  ///
  /// ⚠️ **탐지기는 2026-11-07 측정에 쓴 것과 같아야 한다.** 처음에는 `\d\d`
  /// (두 자리 숫자 아무거나)로 썼다가 집합이 **23건**으로 불어 판정 목록과
  /// 어긋났다 — `RFC 1918`·`99.99%` 처럼 **단위도 맥락도 없는 숫자**까지 걸린다.
  /// 측정 때처럼 **숫자에 단위가 붙은 경우**(또는 「최대/최소/기본」 표현)로
  /// 좁혀야 목록이 유지 가능해진다.
  final numeric = RegExp(
      r'\d[\d,\.]*\s*(GB|TB|TiB|GiB|MB|MiB|KB|KiB|초|분|시간|일|개월|년|%|배|회|개|노드|샤드|vCPU)'
      r'|최대 \d|최소 \d|기본값|기본 \d');

  bool assertsNumber(Map<String, dynamic> q) {
    final text = <String>[
      q['stem'] as String? ?? '',
      q['explanation'] as String? ?? '',
      ...(q['options'] as List).cast<String>(),
      ...((q['wrongExplanations'] as Map?)?.values.whereType<String>() ??
          const <String>[]),
    ].join('\n');
    return numeric.hasMatch(text);
  }

  /// 교체·추가한 8문항과 그 새 출처.
  const added = <String, List<String>>{
    'saa-t2-1-q7': ['eb-custom-bus-retry.html', 'eb-rule-retry-policy.html'],
    'saa-t2-1-q11': ['choosing-workflow-type.html'],
    'saa-t3-2-q15': ['lifecycle-management-efs.html'],
    'saa-t3-4-q4': ['gettingstarted-limits.html'],
    'saa-t3-4-q8': ['gettingstarted-limits.html'],
    'saa-t3-5-q11': ['CHAP_Storage.html'],
    'saa-t1-3-q12': ['vpc-peering-basics.html'],
    'saa-t3-8-q2': ['vpc-peering-basics.html'],
  };

  /// 「전부 소개류 + 수치 단정」인데 **실측으로 괜찮다고 판정한** 문항.
  /// ⚠️ 새 문항이 이 모양으로 들어오면 아래 집합 단정이 깨진다 — 그때 한 건씩
  /// 재서 **고치거나 이 목록에 등록**한다(판정 없이 늘리지 않는다).
  const judgedFine = <String>{
    'saa-t1-5-q11', // whatisbackup: lifecycle·backup plan·retention 이 기제를 담는다
    'saa-t2-1-q2',
    'saa-t2-1-q3', // visibility timeout 기제가 있다. 30/45초는 시나리오 값
    'saa-t2-1-q4',
    'saa-t2-1-q6',
    'saa-t2-1-q12', // 100,000·2,000 이 인용 페이지에 실재
    'saa-t2-1-q13',
    'saa-t2-1-q14',
    'saa-t2-3-q5',
    'saa-t2-3-q7', // minimum·desired 가 있다. 2/4/10 은 시나리오 값
    'saa-t2-4-q12',
    'saa-t3-4-q12',
    'saa-t3-4-q13', // 15 가 인용 페이지에 실재
    'saa-t3-5-q5', // 256 TiB 가 인용 페이지에 실재
    'saa-t3-6-q1',
    'saa-t3-8-q14',
    'saa-t4-2-q12', // 14일·93일 이 인용 페이지에 실재
    'saa-t4-5-q1', // 13·18개월 이 인용 페이지에 실재
    'saa-t4-5-q15', // 요청당 $0.01 이 인용 페이지에 실재
  };

  // ═════════════════════ 대조군 ═════════════════════

  test('대조군: SAA 문항이 읽히고 손댄 여덟 문항이 실재한다', () {
    expect(saaFiles().length, 24, reason: 'SAA 24 Task');
    expect(allSaa().length, 360);
    for (final qid in added.keys) {
      expect(question(qid)['id'], qid);
    }
  });

  test('§4-9: 손댄 여덟 문항의 정답 인덱스·verified 가 불변이다', () {
    for (final qid in added.keys) {
      final q = question(qid);
      expect(q['verified'], true, reason: '$qid 은 라이브다 — 핫픽스다');
      expect(q['correct'], isA<int>());
    }
    // ⚠️ **처음 쓴 값 중 네 개가 틀렸고 이 단정이 잡았다** — 또 추측했다.
    //    아래는 2026-11-07 실측값이다(보고서는 정답 인덱스를 적지 않는다).
    expect(question('saa-t2-1-q7')['correct'], 1);
    expect(question('saa-t2-1-q11')['correct'], 1);
    expect(question('saa-t3-2-q15')['correct'], 1);
    expect(question('saa-t3-4-q4')['correct'], 1);
    expect(question('saa-t3-4-q8')['correct'], 2);
    expect(question('saa-t3-5-q11')['correct'], 3);
    expect(question('saa-t1-3-q12')['correct'], 0);
    expect(question('saa-t3-8-q2')['correct'], 2);
  });

  // ═══════════ §4-9 — 수치를 담는 페이지를 출처로 단다 ═══════════

  group('§4-9 단정한 수치가 적힌 페이지를 출처로 단다', () {
    added.forEach((qid, slugs) {
      test('$qid 에 ${slugs.length}개 출처가 더해졌다', () {
        final u = urls(question(qid));
        for (final slug in slugs) {
          expect(u.any((x) => x.contains(slug)), isTrue,
              reason: '$qid: $slug 이 없다 — 소개 페이지에는 그 수치가 없다');
        }
        expect(u.any((x) => !isIntro(x)), isTrue,
            reason: '$qid: 소개류가 아닌 출처가 하나는 있어야 한다');
      });
    });

    test('saa-t2-1-q7: EventBridge 기본값을 버스 종류로 한정한다', () {
      final b = json.encode(question('saa-t2-1-q7'));
      expect(b.contains('사용자 지정 이벤트 버스'), isTrue,
          reason: '5회·300초는 사용자 지정 이벤트 버스 구독자의 기본값이다');
      expect(RegExp(r'24\s*시간').hasMatch(b), isTrue);
      expect(b.contains('185'), isTrue,
          reason: '클래식 규칙 대상의 기본값(24시간·185회)을 함께 적는다');
    });

    test('대조군: 소개 페이지를 무조건 걷어내지는 않았다', () {
      // ⭐ 「소개 페이지 = 틀린 출처」가 아니다 — 사실을 담으면 맞는 출처다.
      for (final qid in <String>['saa-t3-4-q4', 'saa-t3-5-q11']) {
        expect(urls(question(qid)).any(isIntro), isTrue,
            reason: '$qid: 소개 페이지는 서비스 선택 축을 여전히 받쳐 준다');
      }
    });
  });

  test('§4-9 전수: 「출처가 전부 소개류 + 수치 단정」은 판정된 것만 남는다', () {
    final offenders = <String>{};
    var scanned = 0;
    for (final q in allSaa()) {
      final u = urls(q);
      if (u.isEmpty) continue;
      if (!u.every(isIntro)) continue;
      if (!assertsNumber(q)) continue;
      scanned++;
      offenders.add(q['id'] as String);
    }
    expect(scanned, greaterThanOrEqualTo(10), reason: '대조군 — 비공허');
    expect(offenders.difference(judgedFine), isEmpty,
        reason: '이 모양의 새 문항은 한 건씩 재서 고치거나 판정 목록에 등록한다: '
            '${offenders.difference(judgedFine).toList()..sort()}');
  });

  // ═══════════ §4-3 — 고치지 않는다는 판정의 회귀 가드 ═══════════

  group('§4-3 범위 목록 비매칭은 고치지 않는다 (판정 고정)', () {
    test('saa-t2-5-q10 의 정답은 Elastic Disaster Recovery 그대로다', () {
      final q = question('saa-t2-5-q10');
      final right = (q['options'] as List).cast<String>()[q['correct'] as int];
      expect(right.contains('Elastic Disaster Recovery'), isTrue,
          reason: '목록 머리말이 non-exhaustive 라 「목록에 없다」가 「범위 밖」이 '
              '아니다 — 이 문항을 고치지 않는다');
      expect(q['verified'], true);
    });

    test('saa-t4-3-q13 은 닫힌 서비스 처리의 모범 사례로 유지한다', () {
      final q = question('saa-t4-3-q13');
      final b = json.encode(q);
      final right = (q['options'] as List).cast<String>()[q['correct'] as int];
      expect(right.contains('Timestream for InfluxDB'), isTrue);
      expect(b.contains('LiveAnalytics'), isTrue,
          reason: '해설이 닫힌 쪽을 명시하는 것이 이 문항의 가치다 '
              '(보고서 §4-4 가 「교과서적」이라고 적었다)');
      expect(q['verified'], true);
    });
  });
}
