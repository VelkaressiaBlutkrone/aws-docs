import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// AIP-C01 공식 시험 가이드 동기화 가드 (Phase 2 선결 **P-02**).
///
/// 레포 `exam_guides/AIP-C01.json`은 2026-06-06~06-10 수집분이고, 2026-11-13
/// 조사(Phase 1)와 **교체 직전 재측정**에서 공식 한국어 가이드와 **본문 4건**이
/// 다른 것이 확인됐다. 나머지 **124건은 바이트 일치**다.
///
/// 근거: `docs/content-research/AIP-C01/97-repo-json-diff.md` §2·§4.
///
/// ## ⭐ 이 JSON은 SCS 쪽에 가깝다 — 「레포 JSON을 믿지 말라」는 자격증마다 다르다
///
/// AIF-C01.json은 목표 69건 중 19건이 틀렸고, SCS-C03.json은 2건, 이 파일은 4건이다.
/// 구조(5 도메인 · 20 Task · 98 기술 · 비중 31·26·20·12·11)는 **공식과 완전히 일치**한다.
/// ⚠️ 그래도 **개정 표가 없으면 기계 대조가 유일한 감시 수단**이다 — 이 가이드에는
/// 개정(Revisions) 절이 **없어서**(00-overview §1-1) 「가이드가 바뀌었는지」를
/// 공식 페이지로 알 길이 없다(99 G-12). 저작 배치마다 그 배치가 쓰는 Task를 다시 읽는다.
///
/// ## ⚠️⚠️ `기술 4.3.1`은 금지형 가드를 쓸 수 없다 — 공식 문구가 레포 문구의 접두사다
///
/// 공식 한국어 판은 **닫는 괄호를 쓰지 않고**(영문 판은 `).`로 닫는다) 레포 수집분에는
/// 괄호가 있었다. 즉 공식 문구가 옛 레포 문구의 **접두사**라서, 다른 배치들이 쓰던
/// 「옛 문구 `contains` 0건」 가드를 그대로 쓰면 **교체한 공식 문구가 스스로 걸려
/// 영원히 레드**가 된다. AIF의 `Amazon Q` ⊂ `Amazon Quick`, SCS `기술 6.2.4`(마침표만
/// 차이)와 같은 형태다. 그래서 이 건은 **정확한 일치**로 고정하고 접두사 관계 자체를
/// 대조군으로 단정한다.
///
/// ## ⚠️ 공식 쪽 오기는 그대로 넣는다 (D-06)
///
/// 위 괄호는 **공식 한국어 판의 오기**이고 레포 쪽이 타이포그래피상 더 옳았다. 그래도
/// JSON은 **가이드 전사**이므로 공식 전문을 그대로 넣는다(SCS에서 공식 쪽 오기
/// `(AWSRAM)`을 그대로 넣은 것과 같은 규율). 학습문서·문항은 그 괄호를 인용할 이유가 없다.
///
/// ## ⚠️⚠️ `기술 2.5.3`에서 걷어낸 예시는 「가이드가 지웠다」가 아니다 (99 G-02)
///
/// 레포에는 공식 현행(ko·en 양쪽)에 **없는 예시 한 개**(`Amazon Q Business 데이터 소스`)가
/// 있었다. 교체는 막히지 않지만, 개정 절이 없어 **개정 사실을 확인할 길이 없다** —
/// 적을 수 있는 것은 「공식 현행 어디에도 없다」까지다. ⚠️ 그리고 **예시에서 빠진 것이
/// 범위에서 빠진 것은 아니다**: `Amazon Q Business`·`Amazon Q Business Apps`는 지금도
/// 범위 내 목록에 있다(다만 2026-06-30 공지로 **신규 고객 차단**이다 — 96 §5-1).
void main() {
  final raw = File('assets/exam_guides/AIP-C01.json').readAsStringSync();
  final guide = json.decode(raw) as Map<String, dynamic>;
  final domains = (guide['domains'] as List).cast<Map<String, dynamic>>();

  List<Map<String, dynamic>> tasksOf(Map<String, dynamic> d) =>
      (d['tasks'] as List).cast<Map<String, dynamic>>();

  /// 기술 번호 → **접두사를 뗀** 본문.
  ///
  /// ⚠️⚠️ **이 자격증의 `skills` 항목은 본문에 `기술 N.M.K: ` 접두사를 포함한다** —
  /// 레포 12종 중 이 파일만 그렇다(SCS·SOA는 접두사가 없고 AIF는 `knowledge`를 쓴다).
  /// 접두사를 떼지 않고 공식과 비교하면 **98건 전부가 불일치로 세어진다**(실측).
  Map<String, String> skillBodies() {
    final out = <String, String>{};
    for (final d in domains) {
      for (final t in tasksOf(d)) {
        final skills = (t['skills'] as List).cast<String>();
        for (var i = 0; i < skills.length; i++) {
          final no = '${t['no']}.${i + 1}';
          out[no] = skills[i].replaceFirst(RegExp(r'^기술 \d+\.\d+\.\d+: '), '');
        }
      }
    }
    return out;
  }

  // ── 구조 대조군 ──────────────────────────────────────────────────────────
  test('구조: 5 도메인 · 20 Task · 기술 98개가 유도된다', () {
    expect(domains.length, 5);
    expect(domains.fold<int>(0, (a, d) => a + tasksOf(d).length), 20);
    expect(skillBodies().length, 98);
    // Task별 기술 수 — 가장 두꺼운 `작업 5.1`(9개)과 가장 얇은 네 Task(3개)
    final counts = <String, int>{};
    for (final d in domains) {
      for (final t in tasksOf(d)) {
        counts[t['no'] as String] = (t['skills'] as List).length;
      }
    }
    expect(counts['5.1'], 9, reason: '가장 두꺼운 Task');
    expect(counts['1.1'], 3);
    expect(counts['2.2'], 3);
    expect(counts['3.2'], 3);
    expect(counts['3.4'], 3);
  });

  test('대조군: `knowledge` 합이 0이고 `skills` 합이 98이다', () {
    var kn = 0;
    var sk = 0;
    for (final d in domains) {
      for (final t in tasksOf(d)) {
        kn += ((t['knowledge'] as List?) ?? const []).length;
        sk += ((t['skills'] as List?) ?? const []).length;
      }
    }
    // ⚠️⚠️ **AIF 판 가드를 베끼면 안 되는 자리다** — AIF는 목표를 `knowledge`에 담고
    // `skills`를 비워 두는데 이 파일은 **정반대**다(SCS와 같다). `knowledge`에서
    // 번호를 유도하면 **빈 집합**이 되고, 문항이 0개인 단계에서는 **레드도 나지
    // 않아** 첫 문항 배치에서야 터진다(SCS G-77). 그래서 **양방향**으로 단정한다.
    expect(kn, 0, reason: 'knowledge는 20 Task 전부 빈 배열이다');
    expect(sk, 98, reason: '공식 기술 98개가 전부 skills에 있다');
  });

  test('대조군: `skills` 본문의 `기술 N.M.K:` 접두사가 위치에서 유도한 번호와 같다', () {
    var checked = 0;
    for (final d in domains) {
      for (final t in tasksOf(d)) {
        final skills = (t['skills'] as List).cast<String>();
        for (var i = 0; i < skills.length; i++) {
          final m = RegExp(r'^기술 (\d+\.\d+\.\d+): ').firstMatch(skills[i]);
          expect(m, isNotNull, reason: '${t['no']}.${i + 1} 에 접두사가 없다');
          expect(m!.group(1), '${t['no']}.${i + 1}',
              reason: '본문 번호와 위치가 어긋난다');
          checked++;
        }
      }
    }
    expect(checked, 98);
  });

  // ── 공식 전수 대조 ───────────────────────────────────────────────────────
  test('도메인 이름 5개가 공식과 바이트 일치한다', () {
    const expected = <int, String>{
      1: '파운데이션 모델 통합, 데이터 관리 및 규정 준수',
      2: '구현 및 통합',
      3: 'AI 안전, 보안 및 거버넌스',
      4: 'GenAI 애플리케이션을 위한 운영 효율성 및 최적화',
      5: '테스트, 검증 및 문제 해결',
    };
    for (final d in domains) {
      expect(d['name'], expected[int.parse('${d['no']}')]);
    }
  });

  test('비중이 공식과 같고 합이 100이다', () {
    const expected = <int, int>{1: 31, 2: 26, 3: 20, 4: 12, 5: 11};
    var sum = 0;
    for (final d in domains) {
      final no = int.parse('${d['no']}');
      expect(d['weightPct'], expected[no], reason: '도메인 $no 비중');
      sum += d['weightPct'] as int;
    }
    expect(sum, 100);
  });

  test('Task 제목 20개가 공식과 바이트 일치한다', () {
    const expected = <String, String>{
      '1.1': '요구 사항을 분석하고 GenAI 솔루션 설계',
      '1.2': 'FM 선택 및 구성',
      '1.3': 'FM 사용을 위한 데이터 검증 및 처리 파이프라인 구현',
      '1.4': '벡터 저장소 솔루션 설계 및 구현',
      '1.5': 'FM 증강을 위한 검색 메커니즘 설계',
      '1.6': 'FM 상호 작용을 위한 프롬프트 엔지니어링 전략 및 거버넌스 구현',
      '2.1': '에이전틱 AI 솔루션 및 도구 통합 구현',
      '2.2': '모델 배포 전략 구현',
      '2.3': '엔터프라이즈 통합 아키텍처 설계 및 구현',
      '2.4': 'FM API 통합 구현',
      '2.5': '애플리케이션 통합 패턴 및 개발 도구 구현',
      '3.1': '입력 및 출력 안전 제어 구현',
      '3.2': '데이터 보안 및 개인 정보 보호 제어 구현',
      '3.3': 'AI 거버넌스 및 규정 준수 메커니즘 구현',
      '3.4': '책임 있는 AI 원칙 구현',
      '4.1': '비용 최적화 및 리소스 효율성 전략 구현',
      '4.2': '애플리케이션 성능 최적화',
      '4.3': 'GenAI 애플리케이션을 위한 모니터링 시스템 구현',
      '5.1': 'GenAI용 평가 시스템 구현',
      '5.2': 'GenAI 애플리케이션 문제 해결',
    };
    final actual = <String, String>{};
    for (final d in domains) {
      for (final t in tasksOf(d)) {
        actual[t['no'] as String] = t['title'] as String;
      }
    }
    expect(actual.length, 20);
    for (final e in expected.entries) {
      expect(actual[e.key], e.value, reason: '작업 ${e.key}');
    }
  });

  test('overview 다섯 값이 공식과 같다', () {
    final o = guide['overview'] as Map<String, dynamic>;
    // 공식 가이드 본문 + 인증 페이지에서 확인된 값(99 G-01).
    expect(o['level'], 'Professional');
    expect(o['passingScore'], 750);
    expect(o['scoredQuestions'], 65);
    expect(o['unscoredQuestions'], 10);
    expect(o['durationMinutes'], 180,
        reason: '⚠️ 가이드에 없고 **인증 페이지**에만 있다(Exam duration 180 minutes)');
  });

  // ── 2026-11-13 교체한 4건 (정확한 일치) ──────────────────────────────────
  final bodies = skillBodies();

  test('기술 2.1.1 — `Strands 에이전트`(레포 오기 `Stands` 교체)', () {
    expect(
      bodies['2.1.1'],
      '적절한 메모리 및 상태 관리 기능을 갖춘 지능형 자율 시스템 개발'
          '(예: 다중 에이전트 시스템에 Strands 에이전트 및 AWS Agent Squad, '
          '에이전트-도구 상호 작용에 MCP 사용)',
    );
  });

  test('기술 2.5.5 — `Strands Agents`(레포 오기 `Stand Agent` 교체)', () {
    expect(
      bodies['2.5.5'],
      '고급 GenAI 애플리케이션을 개발하여 정교한 AI 기능 구현'
          '(예: AWS 네이티브 오케스트레이션을 위한 Strands Agents 및 AWS Agent Squad 사용, '
          '에이전트 설계 패턴 오케스트레이션용 Step Functions 사용, '
          '프롬프트 체인 패턴 관리를 위한 Amazon Bedrock 사용)',
    );
  });

  test('기술 2.5.3 — 공식 현행에 없는 예시 한 개를 걷었다', () {
    expect(
      bodies['2.5.3'],
      '비즈니스 시스템 개선 사항 만들기(예: 고객 관계 관리(CRM) 개선 사항 구현에 '
          'Lambda 함수 사용, 문서 처리 시스템 오케스트레이션에 Step Functions 사용, '
          '자동화된 데이터 처리 워크플로 관리에 Amazon Bedrock Data Automation 사용)',
    );
  });

  test('기술 4.3.1 — 공식 한국어 판 그대로(닫는 괄호 없음)', () {
    // ⚠️ 영문 판은 `…custom dashboards).` 로 닫는다. ko 판의 오기이지만 JSON은
    // 전사 층이므로 공식 그대로 둔다(D-06).
    expect(
      bodies['4.3.1'],
      'FM 애플리케이션 성능에 대한 완전한 가시성을 제공하는 총체적 관찰성 시스템 구축'
          '(예: 운영 지표, 성능 추적, FM 상호 작용 추적, '
          '사용자 지정 대시보드가 포함된 비즈니스 영향 지표 사용',
    );
  });

  test('대조군: `기술 4.3.1`의 공식 문구는 옛 레포 문구의 **접두사**다', () {
    // 이 관계 때문에 위 테스트가 `equals`여야 한다. 「옛 문구 0건」으로 걸면
    // 교체한 공식 문구가 스스로 걸린다.
    final official = bodies['4.3.1']!;
    final oldRepo = '$official)';
    expect(oldRepo.startsWith(official), isTrue);
    expect(oldRepo.contains(official), isTrue,
        reason: '금지형 가드를 쓰면 공식 문구가 스스로 걸린다');
    expect(official.endsWith(')'), isFalse);
  });

  // ── 전수 금지 (어형이 갈리는 주장은 정규식으로 센다) ────────────────────
  test('`Stands`·`Stand Agent` 오기가 가이드 전수에서 0건이다', () {
    // ⚠️ **같은 제품 이름이 레포 안에서 두 가지로 틀려 있었다** — 한쪽만 고치면
    // 다른 쪽이 남는다. 그래서 전수로 센다.
    final bad = RegExp(r'\bStands?\s+(?:에이전트|Agents?)\b');
    final hits = <String>[];
    bodies.forEach((no, body) {
      // 정본 `Strands` 는 통과해야 한다 — 「Stand」로 시작하되 「Strand」가 아닌 것만 센다.
      for (final m in bad.allMatches(body)) {
        if (!m.group(0)!.startsWith('Strand')) hits.add('$no: ${m.group(0)}');
      }
    });
    expect(hits, isEmpty, reason: '오기 잔존: $hits');
    // 비공허성 — 정본 표기가 실제로 있다.
    expect(bodies.values.where((b) => b.contains('Strands')).length, 2);
  });

  test('공식 현행에 없는 `Amazon Q Business 데이터 소스` 예시가 0건이다', () {
    // ⚠️ `Amazon Q Business` 자체를 금지하면 안 된다 — **지금도 범위 내**다.
    // 걷어낸 것은 `기술 2.5.3`의 그 구절 하나다.
    expect(
      bodies.values.where((b) => b.contains('Amazon Q Business 데이터 소스')).length,
      0,
    );
    expect(raw.contains('내부 지식 도구 제공에'), isFalse);
  });
}
