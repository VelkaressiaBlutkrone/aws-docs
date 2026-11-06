import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 2026-11-06 전 콘텐츠 2단 검토의 **SAA 우선순위 2 다섯 건** 정정 가드.
///
/// 보고서 정본: `docs/audits/2026-11-06-full-content-review/saa-c03.md` §3-1~3-4(1차) ·
/// `saa-c03-fable.md` §1 판정표·§2-2(2차가 추가한 P2).
///
/// 공식 재측정은 컨트롤러가 직접 했다. **정답 인덱스는 한 건도 바뀌지 않았다.**
///
/// | 건 | 정정 |
/// |---|---|
/// | §3-1 | 은퇴(이름 변경) URL + Fargate 출처 제목 통일 |
/// | §3-2 | 백서 5종 — 살아 있으나 브라우저로 열면 다른 페이지 → 상태 명시 |
/// | §3-3 | `saa-t1-4-q13` 출처가 **문항과 반대로 읽히는 페이지**였다 |
/// | §3-4 | 경미 URL 드리프트 3건 |
/// | §2-2 | 소개 페이지가 **단정 수치를 담지 않는** 문항 |
///
/// ## ⭐ (a) Fargate 슬러그는 이미 0건이었다
///
/// 보고서가 §3-1 (a)로 적은 `AmazonECS/latest/userguide/what-is-fargate.html` 은
/// **직전 「CLF·DVA 죽은 출처 URL」 배치**(전수 33곳)가 SAA 7곳까지 함께 고쳐 이미
/// 사라졌다. 남은 결함은 **출처 제목이 같은 URL에 두 가지**라는 것이었다(6건이 3:3).
/// 공식 `h1` 은 **`Architect for AWS Fargate for Amazon ECS`** 이므로 그쪽으로 통일했다.
///
/// ## ⚠️⚠️ 가드가 틀린 판정을 굳히고 있었다 — 이번 배치의 핵심
///
/// `saa_gaps_b11_test.dart` 가 `declarative_policies.html` 을 **금지**하고 있었는데
/// 지금 실측하면 **그것이 정본**이다:
///
/// - `orgs_manage_policies_declarative.html` → `200 r=1` → **`…_declarative_policies.html`**
/// - 대조군 `orgs_manage_policies_zz-bogus.html` → `200 r=1` → **userguide 인덱스**
///
/// **도착지가 인덱스가 아니라 특정 페이지**이므로 「소멸」이 아니라 「이름 변경」이다.
/// B11 작성 시점의 판정이 반대였거나 AWS 가 다시 바꿨고, 어느 쪽이든 **가드를 먼저
/// 고쳐야 한다**(md 만 고치면 테스트가 레드다). 2026-11-06 AIF 배치의 「가드는 판정을
/// 굳히므로 판정이 틀리면 가드도 틀린다」가 그대로 재현된 자리다.
///
/// ## ⚠️ 보고서 범위 정정
///
/// - **과대**: §2-2 가 「`saa-t2-3-q10`·`q11` 이 1시간·48시간을 단정한다」고 적었지만
///   **수치를 단정하는 것은 `q11` 하나**다(`q10` 본문에 수치가 없다). `q10` 의 출처도
///   정본으로 바꿨지만 그것은 **수치 때문이 아니라** 소개 페이지가 `Pending:Wait`·
///   `CONTINUE` 기제를 적지 않기 때문이다.
/// - **이미 해결**: §3-1 (a) 4개소(위).
///
/// ## 공식 근거 (전부 `200 r=0` 실측)
///
/// - `lifecycle-hooks.html` — `a specified amount of time (**one hour by default**)` +
///   같은 페이지에 `48 hours` · `100 times` 가 함께 있다(한 페이지로 두 수치를 덮는다).
/// - `kinesis-extended-retention.html` — `365 days`.
/// - `sp-ris.html` — 비교 표의 `Up to 66` (소개 페이지는 전체 상한 `72%` 만 적어
///   66% 단정의 근거가 되지 못하고, 나란히 두면 오히려 혼동된다).
/// - `ddos-standard-summary.html` — `Shield Standard defends against the **most
///   common, frequently occurring network and transport layer** DDoS attacks`
///   (현재 출처 `ddos-overview.html` 의 첫 문단은 Standard·Advanced 를 **묶어**
///   L3/L4 **및** L7 을 말해 문항의 갈림길을 반증처럼 읽힌다).
/// - 백서 5종은 **AWS 문서 리더로 읽으면 `redirected_url: null` 이고 본문이 나온다** —
///   은퇴가 아니라 **사람이 브라우저로 열 수 없는** 것이다. 참인 인용을 지우지 않고
///   상태를 적는다(2026-11-06 AIF `AWS CAF for AI` 와 같은 처리).
void main() {
  const saa = 'assets/content/saa';

  List<File> files(String suffix) => Directory(saa)
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith(suffix))
      .toList()
    // ⚠️ `listSync()` 순서는 플랫폼마다 다르다.
    ..sort((a, b) => a.path.compareTo(b.path));

  String rel(File f) => f.path.replaceAll(r'\', '/').split('/').last;

  String doc(String id) => File('$saa/$id.md').readAsStringSync();

  List<Map<String, dynamic>> questionsOf(String task) =>
      ((json.decode(File('$saa/$task.questions.json').readAsStringSync())
                  as Map<String, dynamic>)['questions'] as List)
          .cast<Map<String, dynamic>>();

  Map<String, dynamic> question(String task, String qid) => questionsOf(task)
      .firstWhere((q) => q['id'] == qid, orElse: () => fail('$qid 없음'));

  List<String> sourceUrls(Map<String, dynamic> q) =>
      ((q['sources'] as List?) ?? const [])
          .map((s) => ((s as Map)['url'] ?? '').toString())
          .toList();

  String allText(Map<String, dynamic> q) => json.encode(q);

  // ═════════════════════ 대조군 ═════════════════════

  test('대조군: SAA 콘텐츠를 실제로 읽고 있다', () {
    expect(files('.md').length, greaterThanOrEqualTo(24),
        reason: 'SAA 학습문서는 24편이다 — 0건 통과가 "파일을 못 읽어서"일 수 있다');
    expect(files('.questions.json').length, greaterThanOrEqualTo(24));
  });

  // ═════════════════════ §3-1 은퇴 URL ═════════════════════

  group('§3-1 은퇴(이름 변경) URL 이 정본으로 교체됐다', () {
    const retired = <String, String>{
      // 옛 슬러그 → 정본
      'amazondynamodb/latest/developerguide/HowItWorks.ReadWriteCapacityMode.html':
          'amazondynamodb/latest/developerguide/capacity-mode.html',
      'IAM/latest/UserGuide/id_roles_terms-and-concepts.html':
          'IAM/latest/UserGuide/id_roles.html#id_roles_terms-and-concepts',
      'organizations/latest/userguide/orgs_manage_policies_declarative.html':
          'organizations/latest/userguide/orgs_manage_policies_declarative_policies.html',
    };

    retired.forEach((old, canon) {
      test('${old.split('/').last} → 정본', () {
        final offenders = <String>[];
        for (final f in [...files('.md'), ...files('.questions.json')]) {
          final t = f.readAsStringSync();
          // ⚠️ 전체 URL 조각으로 센다 — 정본이 옛 슬러그의 부분 문자열인 경우가 있다.
          if (t.contains(old)) offenders.add(rel(f));
        }
        expect(offenders, isEmpty,
            reason: '도착지가 인덱스가 아니라 특정 페이지이므로 이름 변경이다: $offenders');
        final holders = [...files('.md'), ...files('.questions.json')]
            .where((f) => f.readAsStringSync().contains(canon))
            .map(rel)
            .toList();
        expect(holders, isNotEmpty,
            reason: '"지웠다"만 보면 출처를 통째로 삭제해도 통과한다 — 정본 실재를 쌍으로 본다');
      });
    });

    test('saa-t4-3-q9·q10: 정답 불변 + 정본 출처', () {
      for (final e in {'saa-t4-3-q9': 0, 'saa-t4-3-q10': 1}.entries) {
        final q = question('saa-t4-3', e.key);
        expect(q['correct'], e.value, reason: '${e.key} 정답은 그대로다');
        expect(sourceUrls(q).any((u) => u.contains('capacity-mode.html')), isTrue);
      }
    });

    test('Fargate 출처 제목이 공식 h1 으로 통일됐다', () {
      // 같은 URL 에 두 제목(3:3)이 붙어 있었다. 공식 h1 은 한 가지다.
      final titles = <String>{};
      for (final f in [...files('.md'), ...files('.questions.json')]) {
        for (final line in f.readAsStringSync().split('\n')) {
          if (!line.contains('AWS_Fargate.html')) continue;
          if (line.contains('Architect for AWS Fargate')) {
            titles.add('canon');
          } else if (line.contains('AWS Fargate — 소개')) {
            titles.add('old');
          }
        }
      }
      expect(titles.contains('old'), isFalse,
          reason: '공식 h1 은 "Architect for AWS Fargate for Amazon ECS" 다');
      expect(titles.contains('canon'), isTrue, reason: '대조군 — 제목이 사라지지 않았다');
    });

    test('대조군: (a) Fargate 슬러그는 이미 0건이었다', () {
      // 직전 「CLF·DVA 죽은 URL」 배치가 SAA 7곳까지 함께 고쳤다.
      // 이 단정이 깨지면 그 배치의 교체가 되돌려진 것이다.
      final hits = [...files('.md'), ...files('.questions.json')]
          .where((f) => f
              .readAsStringSync()
              .contains('AmazonECS/latest/userguide/what-is-fargate.html'))
          .map(rel)
          .toList();
      expect(hits, isEmpty);
    });
  });

  // ═════════════════════ §3-2 백서 5종 ═════════════════════

  test('§3-2 백서 5종의 인용을 지우지 않고 상태를 적었다', () {
    // ⚠️ 백서는 **살아 있다**(리더로 읽으면 본문이 나온다). `curl -sL` 로는 전혀 다른
    // 서비스 페이지로 튕기므로, 학습자가 링크를 누르면 엉뚱한 곳에 떨어진다.
    // 참인 인용을 지우는 것이 더 나쁘므로 **상태를 명시**한다.
    const papers = <String, String>{
      'saa-t2-1': 'patterns-for-ingesting-saas-data-into-aws-data-lakes',
      'saa-t3-4': 'cost-modeling-data-lakes',
      'saa-t3-8': 'hybrid-cloud-dns-options-for-vpc',
      'saa-t3-9': 'building-data-lakes',
    };
    final missing = <String>[];
    papers.forEach((id, slug) {
      final t = doc(id);
      if (!t.contains(slug)) {
        missing.add('$id: 인용이 사라졌다 ($slug)');
        return;
      }
      if (!t.contains('브라우저')) missing.add('$id: 상태 표기 없음');
    });
    expect(missing, isEmpty, reason: missing.join(' · '));
    // 다섯 번째(hybrid-connectivity)도 같은 문서에 있다.
    expect(doc('saa-t3-8').contains('hybrid-connectivity'), isTrue);
  });

  // ═════════════════════ §3-3 Shield 출처 ═════════════════════

  group('§3-3 saa-t1-4-q13 의 출처가 전용 페이지다', () {
    test('정답 불변 + 전용 페이지 인용', () {
      final q = question('saa-t1-4', 'saa-t1-4-q13');
      expect(q['correct'], 2,
          reason: '전용 페이지와 SRA 가 일치하므로 문항 판정은 유지한다');
      expect(sourceUrls(q).any((u) => u.contains('ddos-standard-summary.html')),
          isTrue,
          reason: '현재 출처 ddos-overview 의 첫 문단은 Standard·Advanced 를 묶어 '
              'L3/L4 및 L7 을 말해 문항의 갈림길을 반증처럼 읽힌다');
    });

    test('대조군: 같은 페이지를 쓰는 다른 네 문항은 손대지 않았다', () {
      // q2·q3·q12·q15 가 인용하는 사실은 그 페이지에 부합하므로 교체 대상이 아니다.
      for (final qid in ['saa-t1-4-q2', 'saa-t1-4-q3', 'saa-t1-4-q12', 'saa-t1-4-q15']) {
        final q = question('saa-t1-4', qid);
        expect(sourceUrls(q).any((u) => u.contains('ddos-overview.html')), isTrue,
            reason: '$qid 의 출처를 함께 바꾸면 범위를 넘는다');
      }
    });
  });

  // ═════════════════════ §3-4 경미 드리프트 ═════════════════════

  test('§3-4 경미 URL 드리프트 3건이 정본으로 맞춰졌다', () {
    const drift = <String, String>{
      'https://aws.amazon.com/directconnect/pricing/':
          'https://aws.amazon.com/directconnect/pricing/pay-as-you-go/',
      'https://aws.amazon.com/network-firewall/faqs\n':
          'https://aws.amazon.com/network-firewall/faqs/',
      'https://docs.aws.amazon.com/databases-on-aws-how-to-choose/':
          'https://docs.aws.amazon.com/decision-guides/latest/decision-guides/databases-on-aws-how-to-choose.html',
    };
    final offenders = <String>[];
    for (final f in [...files('.md'), ...files('.questions.json')]) {
      final t = f.readAsStringSync();
      drift.forEach((old, canon) {
        // ⚠️ 옛 URL 이 정본의 **접두사**인 경우가 둘이다(`pricing/` ⊂ `pricing/pay-as-you-go/`,
        // `faqs` ⊂ `faqs/`). 그래서 「옛 것을 지웠나」를 접두사로 세면 거짓 양성이 난다 —
        // 정본을 지운 뒤 남은 수로 센다.
        final stripped = t.replaceAll(canon, '');
        if (stripped.contains(old.trimRight())) {
          offenders.add('${rel(f)} ← ${old.trim()}');
        }
      });
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
    for (final canon in drift.values) {
      final holders = [...files('.md'), ...files('.questions.json')]
          .where((f) => f.readAsStringSync().contains(canon))
          .length;
      expect(holders, greaterThan(0), reason: '$canon 이 어디에도 없다');
    }
  });

  // ═════════════════════ §2-2 소개 페이지 출처 ═════════════════════

  group('§2-2 단정 수치를 담는 페이지를 인용한다', () {
    test('saa-t2-3-q11: 1시간·48시간의 정본', () {
      final q = question('saa-t2-3', 'saa-t2-3-q11');
      expect(q['correct'], 1);
      expect(allText(q).contains('48시간'), isTrue, reason: '대조군 — 수치는 그대로다');
      expect(sourceUrls(q).any((u) => u.contains('lifecycle-hooks.html')), isTrue,
          reason: '소개 페이지의 「Lifecycle hooks」 항목은 기능 소개 한 문단뿐이고 '
              '수치가 0건이다');
    });

    test('saa-t2-3-q10: 기제를 적는 페이지로 (수치 단정은 없다)', () {
      final q = question('saa-t2-3', 'saa-t2-3-q10');
      expect(q['correct'], 0);
      // ⚠️ 보고서는 q10 도 수치를 단정한다고 적었지만 본문에 수치가 없다 — 과대였다.
      expect(RegExp(r'1시간|48시간').hasMatch(allText(q)), isFalse,
          reason: '이 문항이 수치를 단정하게 되면 보고서의 과대 판정이 사실이 된다');
      expect(sourceUrls(q).any((u) => u.contains('lifecycle-hooks.html')), isTrue);
    });

    test('saa-t3-9-q4: 365일의 정본을 더했다', () {
      final q = question('saa-t3-9', 'saa-t3-9-q4');
      expect(q['correct'], 2);
      expect(allText(q).contains('365일'), isTrue);
      expect(
          sourceUrls(q).any((u) => u.contains('kinesis-extended-retention.html')),
          isTrue);
      // Firehose 소개는 이 문항의 주장(버퍼·보존 없음)을 담으므로 유지한다.
      expect(sourceUrls(q).any((u) => u.contains('what-is-this-service.html')),
          isTrue, reason: '대조군 — 참인 출처를 지우지 않았다');
    });

    test('saa-t4-2-q3: Compute SP 66% 의 정본', () {
      final q = question('saa-t4-2', 'saa-t4-2-q3');
      expect(q['correct'], 2);
      expect(allText(q).contains('66%'), isTrue);
      expect(sourceUrls(q).any((u) => u.contains('sp-ris.html')), isTrue,
          reason: '소개 페이지는 전체 상한 "up to 72%" 만 적어 66% 단정의 근거가 '
              '되지 못하고, 나란히 두면 오히려 혼동된다');
    });

    test('대조군: 같은 소개 페이지를 쓰는 다른 문항은 손대지 않았다', () {
      // 수치를 단정하지 않는 문항은 소개 페이지가 적절한 출처다.
      for (final e in {
        'saa-t2-3': ['saa-t2-3-q7', 'saa-t2-3-q12'],
        'saa-t3-9': ['saa-t3-9-q1', 'saa-t3-9-q13'],
        'saa-t4-2': ['saa-t4-2-q4', 'saa-t4-2-q14'],
      }.entries) {
        for (final qid in e.value) {
          final q = question(e.key, qid);
          expect(
              sourceUrls(q).any((u) =>
                  u.contains('what-is-amazon-ec2-auto-scaling.html') ||
                  u.contains('streams/latest/dev/introduction.html') ||
                  u.contains('what-is-savings-plans.html')),
              isTrue,
              reason: '$qid 까지 바꾸면 범위를 넘는다');
        }
      }
    });
  });
}
