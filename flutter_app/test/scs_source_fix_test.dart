import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// SCS **출처 교정 회귀 가드** — 2026-11-10 T2 1차 패스가 찾은 C4 결함을 고정한다.
///
/// 패스 결과와 판정 근거의 정본은 `docs/saa-review/2026-11-10-scs-t2-prescreen.md`
/// 이고 문항별 판정은 `docs/saa-review/prescreen/scs-t*.json` 16편이다.
///
/// ## 이 가드가 막는 결함 종류
///
/// **「URL 은 200인데 그 페이지에 인용 사실이 없다」** — 이 레포가 반복해 밟은
/// 자리다(SAA §4-9 · CLF·DVA 죽은 URL 배치 · AIF 재구성 페이지). SCS 에서는 셋이
/// 나왔다:
///
/// 1. **목차만 있는 장 랜딩 페이지**를 항목 사실의 출처로 썼다
///    (`what-is-cfnstacksets.html` 본문 2,361자 — 문항이 쓰는 세 사실이 0건이고
///    대조군으로 잡히는 `service-managed permissions` 는 **목차 항목 제목**이다).
/// 2. **다른 서비스의 문서**를 인용했다(로드 밸런서 상태 확인을 CloudWatch
///    **알람 평가** 페이지로 — 본문 7,436자에 `health check` 0건, 대조군 통과).
/// 3. **`AWS Lifecycle Changes` 랜딩 페이지**를 항목 사실의 출처로 썼다.
///    ⚠️⚠️ 그 페이지는 **Maintenance·Sunset·Full Shutdown 용어 정의만** 담고
///    (본문 2,292자) **134항목은 하위 세 페이지에 있다.** curl 추출로는 표가
///    보이지 않아 알려진 양성 `Simple AD` 조차 0건이었다 — **내장 브라우저로
///    목차를 열어** 하위 페이지를 찾았다.
///
/// ## ⚠️ 하위 페이지에 **없는** 항목은 그 출처를 쓰지 않는다
///
/// 세 하위 페이지를 전수로 뒤져 확인했다:
///
/// - `SMS` · `MFA` — **세 목록 모두 0건**이다. 그래서 `scs-t4-1-q4` 의 둘째 출처를
///   걷었다. 사실(`SMS 문자 기반 MFA 활성화 지원 종료`)은 IAM MFA 페이지가
///   `AWS ended support for enabling SMS multi-factor authentication (MFA)` 로
///   직접 적는다(실측).
/// - `CodeGuru` — 목록에 있는 것은 **CodeGuru Reviewer**(유지 관리, 2025-10-07)이고
///   문항이 다루는 **CodeGuru Security 는 세 목록에 없다.** 그래서 `scs-t3-2-q12`
///   의 그 출처도 걷었고, 문구 판정은 검수자에게 남겼다(prescreen `review`).
/// - `Amazon S3 Glacier Direct`(유지 관리) · `AWS Directory Service – Simple AD`
///   (유지 관리) · `Amazon Q Developer IDE plugins`(종료 예정) ·
///   `AWS DataSync Discovery`(완전 종료, **2025-05-20** — 문항이 적는 날짜와 일치)
///   는 실재하므로 **하위 페이지로 정밀화**했다.
void main() {
  const dir = 'assets/content/scs';
  const tasks = <String>[
    'scs-t1-1', 'scs-t1-2', 'scs-t1-3',
    'scs-t2-1', 'scs-t2-2',
    'scs-t3-1', 'scs-t3-2', 'scs-t3-3',
    'scs-t4-1', 'scs-t4-2',
    'scs-t5-1', 'scs-t5-2', 'scs-t5-3',
    'scs-t6-1', 'scs-t6-2', 'scs-t6-3',
  ];

  List<Map<String, dynamic>> questionsOf(String taskId) {
    final f = File('$dir/$taskId.questions.json');
    expect(f.existsSync(), isTrue, reason: '$taskId: 문항 파일이 없다');
    final doc = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
    return (doc['questions'] as List).cast<Map<String, dynamic>>();
  }

  Map<String, dynamic> questionById(String id) {
    final taskId = id.substring(0, id.lastIndexOf('-'));
    final q = questionsOf(taskId).firstWhere((e) => e['id'] == id,
        orElse: () => <String, dynamic>{});
    expect(q, isNotEmpty, reason: '$id: 문항을 찾지 못했다');
    return q;
  }

  List<String> urlsOf(String id) => (questionById(id)['sources'] as List)
      .map((s) => (s as Map)['url'] as String)
      .toList();

  // ───────────────────────────────── 대조군
  test('대조군: SCS 문항 자산이 읽히고 240문항이다', () {
    final n = tasks.fold<int>(0, (a, t) => a + questionsOf(t).length);
    expect(n, 240, reason: '문항 수가 240이 아니면 아래 전수 단정이 공허해진다');
  });

  // ───────────────────────────────── 전수 불변식
  test('Lifecycle Changes **랜딩** 페이지를 출처로 쓰지 않는다', () {
    // 랜딩(`service-lifecycle.html`)에는 항목이 없다 — 하위 세 페이지를 쓴다.
    final offenders = <String>[];
    var subPageUses = 0;
    for (final t in tasks) {
      for (final q in questionsOf(t)) {
        for (final s in (q['sources'] as List).cast<Map>()) {
          final u = s['url'] as String;
          if (u.contains('general/latest/gr/service-lifecycle.html')) {
            offenders.add(q['id'] as String);
          }
          if (u.contains('general/latest/gr/maintenance_services.html') ||
              u.contains('general/latest/gr/sunset_services.html') ||
              u.contains('general/latest/gr/full_shutdown_services.html')) {
            subPageUses++;
          }
        }
      }
    }
    expect(offenders, isEmpty,
        reason: '랜딩 페이지는 용어 정의만 담는다(본문 2,292자) — '
            '항목 사실은 Maintenance·Sunset·Full Shutdown 하위 페이지가 근거다: '
            '$offenders');
    expect(subPageUses, greaterThanOrEqualTo(4),
        reason: '하위 페이지 인용이 사라지면 이 단정이 공허해진다(실측 4건)');
  });

  test('G-84: 문항 출처는 그 Task 학습문서 출처의 부분집합이다', () {
    // 문항이 md 밖의 URL 을 들이면 **학습문서 저작 때 실측된 대상이 아니었던
    // 것**이라 「URL 은 200인데 그 페이지에 인용 사실이 없다」의 입구가 된다.
    // 2026-11-10 이 가드를 처음 세울 때 선재 위반 1건을 찾았다
    // (`scs-t1-2-q13` 의 Security Lake what-is — 그 URL 을 md 에 더해 닫았다).
    final urlRe = RegExp(r'https://[^\s`)\]<>"]+');
    final offenders = <String>[];
    for (final t in tasks) {
      final md = File('$dir/$t.md').readAsStringSync();
      final mdUrls = urlRe.allMatches(md).map((m) => m.group(0)!).toSet();
      for (final q in questionsOf(t)) {
        for (final s in (q['sources'] as List).cast<Map>()) {
          final u = s['url'] as String;
          if (!mdUrls.contains(u)) offenders.add('${q['id']} -> $u');
        }
      }
    }
    expect(offenders, isEmpty,
        reason: '문항 출처가 학습문서 출처 목록에 없다 — md 에 더하거나 문항을 '
            '고친다: $offenders');
  });

  // ───────────────────────────────── resource 2건
  test('scs-t1-3-q8: 상태 확인 출처가 ELB 문서다 (알람 평가 페이지가 아니다)', () {
    final u = urlsOf('scs-t1-3-q8');
    expect(u.any((e) => e.contains('alarm-evaluation.html')), isFalse,
        reason: 'CloudWatch 알람 평가 페이지에는 `health check` 가 0건이다');
    expect(
        u.any((e) => e.contains(
            'elasticloadbalancing/latest/application/target-group-health-checks.html')),
        isTrue,
        reason: '경로·포트·간격·임계값 축의 근거');
    expect(
        u.any((e) => e.contains(
            'elasticloadbalancing/latest/application/target-group-register-targets.html')),
        isTrue,
        reason: '보안 그룹 요건 축의 근거 — 상태 확인 페이지에는 `security group` 이 없다');
  });

  test('scs-t6-2-q1: StackSets 자동 배포 출처가 concepts 페이지다', () {
    final u = urlsOf('scs-t6-2-q1');
    expect(u.any((e) => e.contains('what-is-cfnstacksets.html')), isFalse,
        reason: '그 페이지는 소개 두 문단 + 목차뿐이다(본문 2,361자)');
    expect(u.any((e) => e.contains('stacksets-concepts.html')), isTrue,
        reason: '`automatic deployment` 와 `service-managed` 가 실재하는 페이지'
            '(16,307자) — 같은 Task 의 q2·q3·q4 가 이미 쓴다');
  });

  // ───────────────────────────────── review 보강
  test('Athena 를 지목하는 두 문항에 Athena 출처가 있다', () {
    for (final id in ['scs-t1-2-q2', 'scs-t2-2-q4']) {
      expect(urlsOf(id).any((e) => e.contains('athena/latest/ug/what-is.html')),
          isTrue,
          reason: '$id: 정답이 Athena 를 지목하는데 인용 페이지에 `Athena` 가 '
              '0건이었다(`AnalyzingLogData.html`, 대조군 통과)');
    }
  });

  test('scs-t1-2-q1: CloudTrail 축에 출처가 있다', () {
    expect(
        urlsOf('scs-t1-2-q1')
            .any((e) => e.contains('how-cloudtrail-works.html')),
        isTrue,
        reason: '정답의 세 짝 중 CloudTrail 축을 뒷받침하는 출처가 없었다');
  });

  test('scs-t3-1-q1: 오리진 보호 짝에 출처가 있다', () {
    expect(
        urlsOf('scs-t3-1-q1')
            .any((e) => e.contains('ecommerce-security-checklist.html')),
        isTrue,
        reason: '정답의 셋째 짝(커스텀 헤더 + 관리형 접두사 목록)이 WAF 소개 '
            '페이지에 없다 — 같은 Task q5 가 쓰는 근거로 맞춘다');
  });

  test('scs-t4-1-q4: SMS MFA 근거가 IAM MFA 페이지 하나다', () {
    final u = urlsOf('scs-t4-1-q4');
    expect(u.length, 1, reason: 'Lifecycle 랜딩 페이지를 걷었다');
    expect(u.single.contains('IAM/latest/UserGuide/id_credentials_mfa.html'),
        isTrue,
        reason: '그 페이지가 `AWS ended support for enabling SMS multi-factor '
            'authentication (MFA)` 를 직접 적는다. ⚠️ Lifecycle Changes 하위 세 '
            '페이지에는 `SMS`·`MFA` 가 0건이다');
  });

  test('scs-t1-1-q1: 지문이 「공식 접근」을 주장하지 않는다', () {
    // 정답이 적는 「자산→위협→사실→신호원→서비스」 순서는 **저작자의 프레이밍**
    // 이고 어느 공식 페이지도 그 순서를 적지 않는다(Well-Architected 탐지
    // 페이지도 구성 변경·예상 밖 행동 탐지까지만 적는다 — 실측 3,455자).
    final q = questionById('scs-t1-1-q1');
    expect((q['stem'] as String).contains('공식 접근'), isFalse,
        reason: '뒷받침하는 공식 페이지가 없는 「공식」 주장을 지문에 두지 않는다');
  });

  test('정답 인덱스가 모두 불변이고 전 문항이 드래프트다', () {
    // 이 배치는 **출처와 지문 한 줄**만 고쳤다 — 정답·보기·해설은 건드리지 않았다.
    // ⚠️ 이 맵을 처음 손으로 적었을 때 **14건 중 6건이 틀렸다**(t1-3-q8·t2-2-q4·t3-2-q12·t3-2-q13·t4-1-q4·t5-2-q15).
    // 정답 인덱스는 추측하지 않고 실측한다 — 레포가 반복해 밟은 자리다.
    const expected = <String, int>{
      'scs-t1-1-q1': 0,
      'scs-t1-2-q1': 2,
      'scs-t1-2-q2': 0,
      'scs-t1-3-q8': 2,
      'scs-t2-2-q4': 3,
      'scs-t3-1-q1': 0,
      'scs-t3-2-q2': 1,
      'scs-t3-2-q12': 3,
      'scs-t3-2-q13': 0,
      'scs-t4-1-q4': 3,
      'scs-t4-1-q14': 1,
      'scs-t5-2-q7': 0,
      'scs-t5-2-q15': 2,
      'scs-t6-2-q1': 0,
    };
    for (final e in expected.entries) {
      expect(questionById(e.key)['correct'], e.value,
          reason: '${e.key}: 정답 인덱스가 바뀌었다');
    }
    for (final t in tasks) {
      for (final q in questionsOf(t)) {
        expect(q['verified'], isFalse,
            reason: '${q['id']}: flip 은 사람만 한다');
      }
    }
  });
}
