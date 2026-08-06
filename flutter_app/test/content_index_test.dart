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

  // ── T4: 통합 모의고사 공개 게이트 (전 도메인 균형) ──────────────────
  group('examIsBalanced (순수): 전 도메인 검증 시에만 true', () {
    test('빈 목록 → false', () => expect(examIsBalanced(const []), isFalse));
    test('전 도메인 검증 → true', () {
      expect(examIsBalanced([_e(1, 15), _e(2, 15), _e(3, 15)]), isTrue);
    });
    test('부분 검증(일부 도메인만 verified) → false (편향 방지)', () {
      expect(examIsBalanced([_e(1, 15), _e(2, 0), _e(3, 0)]), isFalse);
    });
    test('전부 0 → false', () {
      expect(examIsBalanced([_e(1, 0), _e(2, 0)]), isFalse);
    });
    test('한 도메인에 여러 verified Task여도 다른 도메인 0이면 false', () {
      expect(examIsBalanced([_e(1, 15), _e(1, 15), _e(2, 0)]), isFalse);
    });
  });

  test(
    'certExamIsBalanced: CLF balanced(true), SAA 부분 verified·D1 미충족(false), 미지정(false)',
    () {
      expect(certExamIsBalanced('CLF-C02'), isTrue);
      // SAA는 일부 Task만 flip(D2~D4 부분)·D1 0 → 전 도메인 균형 미충족 → false(통합 모의고사 숨김).
      expect(certExamIsBalanced('SAA-C03'), isFalse);
      expect(certExamIsBalanced('NOPE'), isFalse);
    },
  );

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
      for (final code in ['CLF-C02', 'SAA-C03']) {
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
  test('ContentEntry.lectureAudioSrc: family/taskId 규약', () {
    expect(
      contentFor('CLF-C02').first.lectureAudioSrc,
      'assets/audio/clf/clf-t1-1/lecture.mp3',
    );
    expect(
      contentFor('SAA-C03').first.lectureAudioSrc,
      'assets/audio/saa/saa-t1-1/lecture.mp3',
    );
  });

  // ── 오디오 노출 동기화 (M2 런타임 게이트) ───────────────────────────
  // audioApproved=true ↔ audio_meta.json reviewStatus=approved + mp3 존재.
  // SSOT는 audio_meta.json(사람이 청취 후 approved 전환). 불일치 시 잘못된
  // 노출/404를 빌드 전에 차단(verified 문항 동적 불변식과 동일 패턴).
  test('동기화: audioApproved ↔ audio_meta.json reviewStatus + mp3 존재', () {
    final issues = <String>[];
    for (final entry in kContentIndex.entries) {
      for (final e in entry.value) {
        final meta = File(e.lectureAudioMetaSrc);
        final mp3 = File(e.lectureAudioSrc);
        String? status;
        String? scriptStatus;
        if (meta.existsSync()) {
          final m =
              json.decode(meta.readAsStringSync()) as Map<String, dynamic>;
          status = m['reviewStatus'] as String?;
          scriptStatus =
              (m['script'] as Map<String, dynamic>?)?['reviewStatus']
                  as String?;
        }
        // spec: top-level + script.reviewStatus 둘 다 approved를 SSOT로 본다.
        final metaApproved =
            status == 'approved' &&
            scriptStatus == 'approved' &&
            mp3.existsSync();
        if (e.audioApproved != metaApproved) {
          issues.add(
            '${e.certCode}/${e.taskId}: audioApproved=${e.audioApproved} != meta(approved&&mp3)=$metaApproved (top=$status, script=$scriptStatus, mp3=${mp3.existsSync()})',
          );
        }
      }
    }
    expect(
      issues,
      isEmpty,
      reason: 'audioApproved ↔ audio_meta 동기화 불일치:\n${issues.join('\n')}',
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
