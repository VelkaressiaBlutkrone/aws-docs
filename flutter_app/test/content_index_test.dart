import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/content_index.dart';

void main() {
  // ⚠️ 이 블록이 "잠긴 cert 표본" 문제의 구조적 해소다. 게이트가 열리는 순간
  // 잠금 화면·"준비 중" 라벨을 검증하던 테스트가 깨지는데, 표본은 이미
  // SAA(2026-10-28) → MLA(2026-10-29) → DEA 로 두 번 이사했고 콘텐츠 있는
  // 5종(CLF·SAA·SOA·DEA·MLA)이 전부 개방되면 **옮길 cert 가 없다**
  // (HANDOFF §0-2026-10-29 교훈 2). 제품 동작은 어느 자격증이 검수를 통과했는지와
  // 무관해야 하므로, 테스트가 이 주입구로 "콘텐츠 인덱스가 이렇게 말한다면"을
  // 직접 만든다. 정책 없는 cert 로는 대체할 수 없었다 — `domainProgressLabel` 이
  // 빈 문자열이 된다(착수 노트 §3).
  group('contentFor 테스트 주입구(debugContentIndexOverride)', () {
    tearDown(() => debugContentIndexOverride = null);

    const synthetic = ContentEntry(
      certCode: 'CLF-C02',
      taskId: 'synthetic-t1-1',
      title: '합성 엔트리',
      domain: 1,
      mdAsset: 'assets/content/clf/clf-t1-1.md',
      questionsAsset: 'assets/content/clf/clf-t1-1.questions.json',
      questionCount: 3,
    );

    test('덮어쓴 cert 만 바뀌고 나머지는 실제 인덱스를 그대로 본다', () {
      final realSaa = contentFor('SAA-C03');
      debugContentIndexOverride = const {'CLF-C02': [synthetic]};

      expect(contentFor('CLF-C02'), [synthetic]);
      expect(contentFor('SAA-C03'), realSaa, reason: '덮어쓰지 않은 cert 는 그대로여야 한다');
    });

    test('빈 목록으로 덮어쓰면 "콘텐츠 없음"이 된다 (null 과 구분된다)', () {
      debugContentIndexOverride = const {'CLF-C02': []};
      expect(contentFor('CLF-C02'), isEmpty);
      expect(certHasContent('CLF-C02'), isFalse);
    });

    test('게이트·요약이 주입된 엔트리에서 파생된다', () {
      // 열린 cert(CLF-C02)를 "문항은 있는데 도메인 비중 미달"로 만들 수 있어야
      // 잠금 화면 테스트가 실제 flip 상태에서 풀린다.
      debugContentIndexOverride = const {'CLF-C02': [synthetic]};

      expect(certContentSummary('CLF-C02').questions, 3);
      expect(certHasVerifiedQuestions('CLF-C02'), isTrue);
      final s = examWeightedCapacityStatus('CLF-C02');
      expect(s.hasPolicy, isTrue);
      expect(s.availableByDomain, {1: 3, 2: 0, 3: 0, 4: 0});
      expect(s.ready, isFalse);
      expect(certExamHasWeightedCapacity('CLF-C02'), isFalse);
      expect(s.domainProgressLabel, isNotEmpty);
    });

    test('null 로 되돌리면 실제 인덱스가 복구된다', () {
      final real = contentFor('CLF-C02');
      debugContentIndexOverride = const {'CLF-C02': []};
      expect(contentFor('CLF-C02'), isEmpty);
      debugContentIndexOverride = null;
      expect(contentFor('CLF-C02'), real);
      expect(certExamHasWeightedCapacity('CLF-C02'), isTrue,
          reason: 'CLF-C02 는 실제로 게이트가 열려 있다 — 주입구가 누출되면 여기서 터진다');
    });
  });

  test('certHasContent: 콘텐츠 보유 true, 미보유/미지정 false', () {
    expect(certHasContent('CLF-C02'), isTrue);
    expect(certHasContent('DVA-C02'), isFalse);
    expect(certHasContent('NOPE'), isFalse);
  });

  test('SAA-C03: 학습문서 보유 (문항 수는 동적 불변식으로 가드)', () {
    // verified flip 시 문항 수가 바뀌므로 0을 하드코딩하지 않는다.
    // questionCount의 정확성은 아래 "동적 불변식" 테스트가 보장한다.
    expect(certHasContent('SAA-C03'), isTrue);
    expect(certContentSummary('SAA-C03').docs, greaterThan(0));
  });

  test('certContentSummary: docs/questions 합산', () {
    final entries = contentFor('CLF-C02');
    var sum = 0;
    for (final e in entries) {
      sum += e.questionCount;
    }
    final s = certContentSummary('CLF-C02');
    expect(s.docs, entries.length);
    expect(s.questions, sum);
    expect(s.questions, greaterThan(0));
  });

  test('certContentSummary: 콘텐츠 없는 cert는 0', () {
    final s = certContentSummary('DVA-C02');
    expect(s.docs, 0);
    expect(s.questions, 0);
  });

  test('certHasVerifiedQuestions: 문항 있으면 true, 없으면 false', () {
    expect(certHasVerifiedQuestions('CLF-C02'), isTrue);
    expect(certHasVerifiedQuestions('NOPE'), isFalse);
  });

  test('ContentEntry.hasQuestions: questionCount>0과 1:1 (뱅크 로드 가드의 불변식)', () {
    // CLF는 모든 Task에 검증 문항 → 전부 로드 대상.
    expect(contentFor('CLF-C02').every((e) => e.hasQuestions), isTrue);
  });

  test('SOA-C03: 학습문서 20개 (문항 수는 동적 불변식으로 가드)', () {
    expect(certHasContent('SOA-C03'), isTrue);
    expect(certContentSummary('SOA-C03').docs, 20);
  });

  test('SOA-C03: 도메인별 문서 수 D1:5 D2:4 D3:4 D4:3 D5:4', () {
    final byDomain = <int, int>{};
    for (final e in contentFor('SOA-C03')) {
      byDomain[e.domain] = (byDomain[e.domain] ?? 0) + 1;
    }
    expect(byDomain, {1: 5, 2: 4, 3: 4, 4: 3, 5: 4});
  });

  // MLA-C01은 도메인별로 나눠 들어온다(공식 Task 12개 = 4도메인 × 3). 배치가
  // 끝날 때마다 이 숫자를 올린다 — 올리지 않으면 신규 문서가 조용히 누락돼도 모른다.
  test('MLA-C01: 학습문서 12개 (도메인 4 배치까지 = 공식 Task 전부)', () {
    expect(certHasContent('MLA-C01'), isTrue);
    expect(certContentSummary('MLA-C01').docs, 12);
  });

  test('MLA-C01: 도메인별 문서 수 D1:3 D2:3 D3:3 D4:3', () {
    final byDomain = <int, int>{};
    for (final e in contentFor('MLA-C01')) {
      byDomain[e.domain] = (byDomain[e.domain] ?? 0) + 1;
    }
    expect(byDomain, {1: 3, 2: 3, 3: 3, 4: 3});
  });

  // 통합/약점 모의고사 공개 게이트는 `certExamHasWeightedCapacity`이고
  // **정책이 없는 cert는 fail closed**다(`hasPolicy: false` → `ready: false`).
  // 그래서 정책을 두지 않으면 사람이 321문항을 전부 flip해도 모의고사가 잠긴
  // 채로 남는다 — 2026-10-26에 flip 검수 범위를 산정하며 실측으로 드러났다.
  test('MLA-C01: 가중 게이트 정책이 있고 필요 수량이 공식 비중과 맞는다', () {
    final status = examWeightedCapacityStatus('MLA-C01');
    expect(status.hasPolicy, isTrue,
        reason: 'kExamReadinessRequirements에 MLA-C01이 없으면 게이트가 fail closed다');
    expect(status.practiceQuestionCount, 65);
    // 공식 비중 D1 28 · D2 26 · D3 22 · D4 24 를 연습 65문항에
    // allocateByWeight(floor + 최대 잉여)로 배분한 값.
    expect(status.requiredByDomain, {1: 18, 2: 17, 3: 14, 4: 16});
  });

  // ⚠️ 이 테스트는 **flip 상호형**이다. 예전에는 "MLA 문항은 전부 드래프트"라고
  // 단정했는데, 그러면 사람이 첫 Task를 flip하는 순간 깨져 flip 자체를 막았다
  // (SAA에는 같은 단정이 없다 — flip이 살아 있는 자격증이기 때문이다).
  // 지금은 특정 숫자가 아니라 **게이트가 현재 상태를 올바르게 반영하는지**를 본다.
  test('MLA-C01: 가중 게이트가 현재 verified 수량을 그대로 반영한다', () {
    final status = examWeightedCapacityStatus('MLA-C01');
    final byDomain = <int, int>{};
    for (final e in contentFor('MLA-C01')) {
      byDomain[e.domain] = (byDomain[e.domain] ?? 0) + e.questionCount;
    }
    expect(status.availableByDomain, byDomain,
        reason: '게이트가 집계한 도메인별 검증 문항 수가 content_index와 어긋났다');
    // 부족분은 필요 − 보유이며, 충족한 도메인은 목록에 없다.
    for (final d in status.requiredByDomain.keys) {
      final need = status.requiredByDomain[d]!;
      final have = byDomain[d] ?? 0;
      if (have < need) {
        expect(status.deficitByDomain[d], need - have, reason: 'D$d 부족분 계산 오류');
      } else {
        expect(status.deficitByDomain.containsKey(d), isFalse,
            reason: 'D$d 는 충족인데 부족 목록에 있다');
      }
    }
    expect(status.ready, status.deficitByDomain.isEmpty);
  });

  // ── 동적 불변식 (T3, flip 회귀 가드) ──────────────────────────────
  // content_index의 questionCount는 그 Task .questions.json의 verified:true
  // 문항 수와 *항상* 일치해야 한다. 특정 숫자(예: SAA==0)에 의존하지 않으므로
  // 첫 SAA flip 시에도 깨지지 않고, flip 후 count 동기화 누락을 잡아낸다.
  // (review.mjs flip이 verified 전환 + content_index questionCount를 함께
  //  갱신하므로 정상 워크플로에서는 항상 일치.)
  test('동적 불변식: 모든 Task questionCount == .questions.json verified 수', () {
    final mismatches = <String>[];
    for (final entry in kContentIndex.entries) {
      for (final e in entry.value) {
        final file = File(e.questionsAsset);
        var verified = 0;
        if (file.existsSync()) {
          final map =
              json.decode(file.readAsStringSync()) as Map<String, dynamic>;
          final qs = (map['questions'] as List?) ?? const [];
          verified = qs
              .where((q) => (q as Map<String, dynamic>)['verified'] == true)
              .length;
        }
        if (e.questionCount != verified) {
          mismatches.add(
            '${e.certCode}/${e.taskId}: content_index=${e.questionCount} != JSON verified=$verified  (${e.questionsAsset})',
          );
        }
      }
    }
    expect(
      mismatches,
      isEmpty,
      reason:
          'content_index questionCount ↔ 실제 verified 수 불일치:\n${mismatches.join('\n')}',
    );
  });

  // ── 통합/약점 모의고사 공개 게이트 ──────────────────────────────────
  // 옛 `examIsBalanced`/`certExamIsBalanced`(전 도메인 ≥1) 테스트는 함수와 함께
  // 2026-10-20에 제거했다. 게이트는 아래 weighted capacity가 전담하며, 편향
  // 방지는 "도메인별 필요 수량"이 담당한다(HANDOFF.md §0-2026-10-20).
  group('weighted capacity readiness: 공식 비중을 앱의 65문항 연습 세트에 적용', () {
    test('CLF-C02는 현재 검증 문항으로 통합 모의고사 ready', () {
      final s = examWeightedCapacityStatus('CLF-C02');
      expect(s.hasPolicy, isTrue);
      expect(s.ready, isTrue);
      expect(s.requiredByDomain, {1: 16, 2: 19, 3: 22, 4: 8});
      expect(s.deficitByDomain, isEmpty);
      expect(certExamHasWeightedCapacity('CLF-C02'), isTrue);
    });

    // ⚠️ 여기에 availableByDomain·deficit·라벨의 **지금 숫자를 박으면 안 된다.**
    // 사람이 D1 Task를 flip하는 순간 깨져 flip 자체를 막는다 — 2026-10-27에
    // `review.mjs flip saa saa-t1-1`이 실제로 이 줄에서 멈췄다(기대 {1:0,…} vs
    // 실제 {1:30,…}). #246의 MLA "전부 드래프트" 단정과 같은 함정이다.
    // 그래서 숫자가 아니라 "게이트가 content_index의 현재 verified 수량을 그대로
    // 반영하는가"를 본다. 정책값(requiredByDomain)만 리터럴로 남긴다.
    test('SAA-C03: 게이트가 현재 verified 수량을 그대로 반영한다', () {
      final s = examWeightedCapacityStatus('SAA-C03');
      expect(s.hasPolicy, isTrue);
      expect(s.requiredByDomain, {1: 19, 2: 17, 3: 16, 4: 13});

      final byDomain = <int, int>{
        for (final d in s.requiredByDomain.keys) d: 0,
      };
      for (final e in contentFor('SAA-C03')) {
        byDomain[e.domain] = (byDomain[e.domain] ?? 0) + e.questionCount;
      }
      expect(s.availableByDomain, byDomain,
          reason: 'SAA-C03 게이트 집계가 content_index와 어긋났다');
      for (final d in s.requiredByDomain.keys) {
        final need = s.requiredByDomain[d]!;
        final have = byDomain[d] ?? 0;
        if (have < need) {
          expect(s.deficitByDomain[d], need - have,
              reason: 'SAA-C03 D$d 부족분 계산 오류');
        } else {
          expect(s.deficitByDomain.containsKey(d), isFalse,
              reason: 'SAA-C03 D$d 는 충족인데 부족 목록에 있다');
        }
      }
      expect(s.ready, s.deficitByDomain.isEmpty);
      expect(certExamHasWeightedCapacity('SAA-C03'), s.ready);

      final keys = s.requiredByDomain.keys.toList()..sort();
      expect(
        s.domainProgressLabel,
        keys.map((d) => 'D$d ${byDomain[d]}/${s.requiredByDomain[d]}').join(' · '),
        reason: '라벨 형식이 바뀌면 cert 페이지 진행 문구가 조용히 달라진다',
      );
    });

    // 게이트를 실제로 여는 것은 **의식적인 릴리스 결정**이다. 이 줄은 그때만
    // 바뀐다 — 2026-10-28 검수자가 `flip saa saa-t2-5`로 D2를 15 → 30으로 올려
    // 네 도메인이 모두 충족됐다(D1 30/19 · D2 30/17 · D3 45/16 · D4 30/13).
    // 위 유도형 단정과 달리 이것은 "열기로 했다"는 선언이고, 그래서 실수로
    // 어떤 Task의 flip이 되돌아가 게이트가 조용히 닫히는 것도 여기서 걸린다.
    //
    // ⚠️ 이 단정이 flip 자체를 막았다 — `review.mjs flip`이 끝에
    // `content_index_test`를 돌리므로, D2가 충족되는 순간 옛 `isFalse` 가 깨져
    // flip 명령이 파일을 쓴 뒤 레드로 끝났다(`--force`는 쓰기 전 구조 검사만
    // 건너뛴다). 다음 cert의 게이트를 열 때는 **선언을 먼저 바꾼 뒤 flip**한다.
    test('SAA-C03: 게이트 개방 — 네 도메인 모두 충족', () {
      expect(certExamHasWeightedCapacity('SAA-C03'), isTrue);
    });

    test('SAA-C03 합성 엔트리가 도메인별 필요 수량을 채우면 ready', () {
      final s = examWeightedCapacityStatus(
        'SAA-C03',
        entries: [_e(1, 19), _e(2, 17), _e(3, 16), _e(4, 13)],
      );
      expect(s.ready, isTrue);
      expect(s.deficitByDomain, isEmpty);
    });

    // SOA-C03·DEA-C01도 2026-10-27까지 정책이 없어 fail closed였다. 사람이
    // 드래프트(SOA 300 · DEA 256)를 전부 검수해 flip해도 모의고사가 잠긴 채
    // 남는 함정이라 정책을 넣었다 — MLA가 같은 함정에 걸려 있었다(#246).
    test('SOA-C03: 5도메인 정책이 있고 필요 수량이 공식 비중과 맞는다', () {
      final s = examWeightedCapacityStatus('SOA-C03');
      expect(s.hasPolicy, isTrue,
          reason: 'kExamReadinessRequirements에 SOA-C03이 없으면 게이트가 fail closed다');
      expect(s.practiceQuestionCount, 65);
      // 공식 비중 D1 22 · D2 22 · D3 22 · D4 16 · D5 18 을 연습 65문항에
      // allocateByWeight(floor + 최대 잔여)로 배분한 값. 5도메인이라 다른
      // 자격증(4도메인)과 달리 잔여 배분이 D5·D4로 간다.
      expect(s.requiredByDomain, {1: 14, 2: 14, 3: 14, 4: 11, 5: 12});
      expect(s.requiredByDomain.values.fold(0, (a, b) => a + b), 65,
          reason: '배분 합이 연습 세트 크기와 달라지면 도메인 하나가 조용히 비거나 넘친다');
    });

    test('DEA-C01: 정책이 있고 필요 수량이 공식 비중과 맞는다', () {
      final s = examWeightedCapacityStatus('DEA-C01');
      expect(s.hasPolicy, isTrue,
          reason: 'kExamReadinessRequirements에 DEA-C01이 없으면 게이트가 fail closed다');
      expect(s.practiceQuestionCount, 65);
      // 공식 비중 D1 34 · D2 26 · D3 22 · D4 18 → 65문항 배분.
      expect(s.requiredByDomain, {1: 22, 2: 17, 3: 14, 4: 12});
      expect(s.requiredByDomain.values.fold(0, (a, b) => a + b), 65);
    });

    // ⚠️ 이 단정은 **flip 상호형**이다. availableByDomain에 지금의 0을 박으면
    // 사람이 첫 Task를 flip하는 순간 깨져 flip 자체를 막는다(#246에서 MLA가
    // 그 함정에 걸렸다). 그래서 숫자가 아니라 "게이트가 content_index의 현재
    // verified 수량을 그대로 반영하는가"를 본다.
    test('SOA-C03·DEA-C01: 게이트가 현재 verified 수량을 그대로 반영한다', () {
      for (final code in ['SOA-C03', 'DEA-C01']) {
        final s = examWeightedCapacityStatus(code);
        final byDomain = <int, int>{
          for (final d in s.requiredByDomain.keys) d: 0,
        };
        for (final e in contentFor(code)) {
          byDomain[e.domain] = (byDomain[e.domain] ?? 0) + e.questionCount;
        }
        expect(s.availableByDomain, byDomain,
            reason: '$code 게이트 집계가 content_index와 어긋났다');
        for (final d in s.requiredByDomain.keys) {
          final need = s.requiredByDomain[d]!;
          final have = byDomain[d] ?? 0;
          if (have < need) {
            expect(s.deficitByDomain[d], need - have,
                reason: '$code D$d 부족분 계산 오류');
          } else {
            expect(s.deficitByDomain.containsKey(d), isFalse,
                reason: '$code D$d 는 충족인데 부족 목록에 있다');
          }
        }
        expect(s.ready, s.deficitByDomain.isEmpty);
        expect(certExamHasWeightedCapacity(code), s.ready);
      }
    });

    // 정책 추가는 **공개가 아니다**. verified가 0인 동안은 전 도메인이 부족해야
    // 하고 게이트는 잠겨 있어야 한다 — 합성 엔트리로 박아 두면 나중에 사람이
    // flip해도 이 단정은 그대로 유효하다.
    test('SOA-C03·DEA-C01: 정책만으로는 열리지 않는다 (verified 0 → 전 도메인 부족)', () {
      for (final code in ['SOA-C03', 'DEA-C01']) {
        final s = examWeightedCapacityStatus(code, entries: const []);
        expect(s.hasPolicy, isTrue);
        expect(s.ready, isFalse);
        expect(s.deficitByDomain, s.requiredByDomain,
            reason: '$code: 검증 문항 0인데 부족 도메인이 전부가 아니다');
      }
    });

    // 2026-10-27 실측: SOA·DEA 문항은 전부 드래프트(verified 0)라 정책을 넣어도
    // 라이브 노출은 그대로 잠긴 채였다. **둘 다 2026-10-31 에 열렸다.**
    //
    // DEA — `dea-t4-1` flip 으로 D4 가 채워져 네 도메인이 모두 충족됐다
    // (D1 31/22 · D2 30/17 · D3 15/14 · D4 15/12, verified 91. 그 뒤 256/256).
    //
    // SOA — `soa-t5-1` flip 으로 D5 가 채워져 **다섯** 도메인이 모두 충족됐다
    // (D1 15/14 · D2 15/14 · D3 15/14 · D4 15/11 · D5 15/12, verified 75).
    //
    // 🏁 **이로써 콘텐츠를 가진 다섯 자격증이 전부 열렸고 locked 선언은 하나도
    // 남지 않았다.** 그래서 "지금 잠긴 cert"를 표본으로 쓰는 테스트를 다시
    // 만들면 안 된다 — 잠금 동작은 아래 `정책만으로는 열리지 않는다`(합성 빈
    // 엔트리)와 `정책 없는 cert는 fail closed`(ANS-C01), 그리고
    // `debugContentIndexOverride` 주입으로 검증한다. 전부 실제 flip 상태와
    // 무관하므로 앞으로 어떤 flip 에도 묶이지 않는다.
    //
    // ⚠️ **새 자격증을 열 사람에게**(지금은 해당 없음, 콘텐츠가 더 들어올 때
    // 쓴다): locked 선언을 두면 그것은 `review.mjs flip` 이 마지막에 돌리는
    // `content_index_test` 안에 있게 되고, 게이트를 여는 Task 를 flip 할 때
    // **파일을 다 쓴 뒤** 거기서 레드로 끝난다(`--force` 는 쓰기 **전** 구조
    // 검사만 건너뛰어 소용없다). 순서는 ① 그 자격증 선언 삭제 → ② flip →
    // ③ 개방 단정을 넣어 커밋이고, 개방 단정은 flip **후**에만 통과하므로
    // 커밋이 둘로 갈린다(제거 1 + 추가 1 = **순증 0**). 2026-10-28 에
    // `flip saa saa-t2-5` 가 이 함정에서 실제로 멈췄고, 2026-10-31 DEA·SOA 는
    // 순서를 지켜 중단 없이 끝났다. 자격증별로 분리해 두면 한 자격증을 여는
    // PR 이 다른 자격증 줄을 건드리지 않는다(착수 노트 §2).
    //
    // 개방으로 깨지는 테스트는 **그 자격증의 locked 선언 1건뿐**이다 — 2026-10-29
    // 양쪽 개방 시뮬레이션으로 예측하고 2026-10-31 DEA·SOA 실제 개방으로
    // 두 번 확인했다.

    test('DEA-C01: 게이트 개방 — 네 도메인 모두 충족', () {
      expect(certExamHasWeightedCapacity('DEA-C01'), isTrue);
    });

    test('SOA-C03: 게이트 개방 — 다섯 도메인 모두 충족', () {
      expect(certExamHasWeightedCapacity('SOA-C03'), isTrue);
    });

    test('정책 없는 cert는 fail closed', () {
      // ⚠️ 정책 있는 cert를 여기 쓰면 이 테스트가 의미를 잃는다(예전에는
      // SOA-C03을 썼는데 2026-10-27에 정책이 생겼다). 가이드는 있고 정책은
      // 없는 자격증을 쓴다.
      expect(kExamReadinessRequirements.containsKey('ANS-C01'), isFalse,
          reason: 'ANS-C01에 정책이 생겼으면 아직 정책 없는 다른 cert로 바꾼다');
      final s = examWeightedCapacityStatus('ANS-C01');
      expect(s.hasPolicy, isFalse);
      expect(s.ready, isFalse);
      expect(certExamHasWeightedCapacity('ANS-C01'), isFalse);
    });

    test('readiness 정책은 exam guide의 65문항/도메인 비중과 동기화된다', () {
      // 대조 목록은 **의도 선언**이다(정책이 조용히 늘거나 사라지는 것을 잡는다).
      // 반면 아래 루프는 하드코딩 목록이 아니라 정책 키 전체를 돈다 — 2026-10-26
      // MLA 정책 추가 때 하드코딩 목록을 빠뜨려 **검증 없이 통과**한 적이 있어,
      // 2026-10-27 SOA·DEA 추가에서 루프를 키 집합으로 돌렸다.
      expect(kExamReadinessRequirements.keys.toSet(),
          {'CLF-C02', 'SAA-C03', 'MLA-C01', 'SOA-C03', 'DEA-C01'},
          reason: 'readiness 정책을 추가·삭제했으면 이 테스트의 대조 목록도 맞춘다');
      for (final code in kExamReadinessRequirements.keys) {
        final raw = File('assets/exam_guides/$code.json').readAsStringSync();
        final guide = json.decode(raw) as Map<String, dynamic>;
        final overview = guide['overview'] as Map<String, dynamic>;
        final domains = guide['domains'] as List<dynamic>;
        final requirement = kExamReadinessRequirements[code]!;

        expect(
          requirement.practiceQuestionCount,
          (overview['scoredQuestions'] as int) +
              (overview['unscoredQuestions'] as int),
        );
        expect(requirement.weightByDomain, {
          for (final d in domains)
            (d as Map<String, dynamic>)['no'] as int: d['weightPct'] as int,
        });
      }
    });
  });

  // ── M1 T4: 오디오 강의("주머니 라디오") placeholder 경로 ──────────────
  // 규약 assets/audio/{family}/{taskId}/lecture.mp3 (family = taskId 접두어).
  // mdAsset은 cert마다 불규칙(clf/t1-1.md vs saa/saa-t1-1.md)이라 유도하지 않고
  // 별도 일관 규약을 둔다. 1A = 문서당 1개 합친 파일(섹션 트랙 분리 금지).
  test('ContentEntry.lectureAudioSrc: 승인 엔트리는 R2 불변 키, 미승인은 assets 규약', () {
    final clf = contentFor('CLF-C02').first; // clf-t1-1, 승인
    expect(clf.audioApproved, isTrue);
    expect(clf.audioSha8, isNotNull);
    expect(
      clf.lectureAudioSrc,
      'https://aws-audio.leva.ai.kr/clf/clf-t1-1/${clf.audioSha8}/lecture.mp3',
    );
    final saaPending = contentFor(
      'SAA-C03',
    ).firstWhere((e) => e.taskId == 'saa-t4-2');
    expect(saaPending.audioApproved, isFalse);
    expect(saaPending.audioSha8, isNull);
    expect(saaPending.lectureAudioSrc, 'assets/audio/saa/saa-t4-2/lecture.mp3');
  });

  // ── 오디오 노출 동기화 (M2 런타임 게이트) ───────────────────────────
  // audioApproved=true ↔ audio_meta.json(top+script) approved && audioSha8 == sha256[:8].
  // SSOT는 audio_meta.json. mp3 본체는 R2에 있으므로 로컬 파일 존재는 검사하지 않는다
  // (릴리스 전 publish_audio.py --verify-all이 공개 URL을 실측).
  test('동기화: audioApproved ↔ audio_meta reviewStatus + audioSha8', () {
    final issues = <String>[];
    for (final entry in kContentIndex.entries) {
      for (final e in entry.value) {
        final meta = File(e.lectureAudioMetaSrc);
        String? status;
        String? scriptStatus;
        String? sha8;
        if (meta.existsSync()) {
          final m =
              json.decode(meta.readAsStringSync()) as Map<String, dynamic>;
          status = m['reviewStatus'] as String?;
          scriptStatus =
              (m['script'] as Map<String, dynamic>?)?['reviewStatus']
                  as String?;
          final sha =
              (m['audio'] as Map<String, dynamic>?)?['sha256'] as String?;
          sha8 = sha?.substring(0, 8);
        }
        final metaApproved = status == 'approved' && scriptStatus == 'approved';
        if (e.audioApproved != metaApproved) {
          issues.add(
            '${e.taskId}: audioApproved=${e.audioApproved} != meta=$metaApproved (top=$status, script=$scriptStatus)',
          );
        }
        if (e.audioApproved && e.audioSha8 != sha8) {
          issues.add(
            '${e.taskId}: audioSha8=${e.audioSha8} != meta sha256[:8]=$sha8',
          );
        }
        if (!e.audioApproved && e.audioSha8 != null) {
          issues.add('${e.taskId}: 미승인 엔트리에 audioSha8 존재');
        }
      }
    }
    expect(
      issues,
      isEmpty,
      reason: 'audioApproved/audioSha8 ↔ audio_meta 불일치:\n${issues.join('\n')}',
    );
  });
}

ContentEntry _e(int domain, int questionCount) => ContentEntry(
  certCode: 'X',
  taskId: 't$domain-$questionCount',
  title: '',
  domain: domain,
  mdAsset: '',
  questionsAsset: '',
  questionCount: questionCount,
);
