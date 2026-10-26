import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/content_index.dart';

void main() {
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
  // (saa_review.mjs flip이 verified 전환 + content_index questionCount를 함께
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

    test('SAA-C03는 현재 D1/D2 가중 수량 미달이라 locked', () {
      final s = examWeightedCapacityStatus('SAA-C03');
      expect(s.hasPolicy, isTrue);
      expect(s.ready, isFalse);
      expect(s.requiredByDomain, {1: 19, 2: 17, 3: 16, 4: 13});
      expect(s.availableByDomain, {1: 0, 2: 15, 3: 45, 4: 30});
      expect(s.deficitByDomain, {1: 19, 2: 2});
      expect(s.domainProgressLabel, 'D1 0/19 · D2 15/17 · D3 45/16 · D4 30/13');
      expect(certExamHasWeightedCapacity('SAA-C03'), isFalse);
    });

    test('SAA-C03 합성 엔트리가 도메인별 필요 수량을 채우면 ready', () {
      final s = examWeightedCapacityStatus(
        'SAA-C03',
        entries: [_e(1, 19), _e(2, 17), _e(3, 16), _e(4, 13)],
      );
      expect(s.ready, isTrue);
      expect(s.deficitByDomain, isEmpty);
    });

    test('정책 없는 cert는 fail closed', () {
      final s = examWeightedCapacityStatus('SOA-C03');
      expect(s.hasPolicy, isFalse);
      expect(s.ready, isFalse);
      expect(certExamHasWeightedCapacity('SOA-C03'), isFalse);
    });

    test('readiness 정책은 exam guide의 65문항/도메인 비중과 동기화된다', () {
      // ⚠️ 이 목록은 하드코딩이라 정책을 추가하고 여기를 빠뜨리면 **검증 없이
      // 통과한다**(2026-10-26 MLA 정책 추가 때 실제로 그랬다). 정책을 늘리면
      // 반드시 여기도 늘린다 — 아래 단정이 그것을 다시 잡아 준다.
      expect(kExamReadinessRequirements.keys.toSet(),
          {'CLF-C02', 'SAA-C03', 'MLA-C01'},
          reason: 'readiness 정책을 추가·삭제했으면 이 테스트의 대조 목록도 맞춘다');
      for (final code in ['CLF-C02', 'SAA-C03', 'MLA-C01']) {
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
