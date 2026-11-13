import 'dart:convert';
import 'dart:io';
import 'dart:math';

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
///   **CodeGuru Security 는 세 목록에 없다.** 그래서 그 출처를 걷었다.
///   ⚠️ `scs-t3-2-q12` 는 2026-11-11 외부 검수 보고의 🔴 로 **재작성됐다** — 아래
///   전용 그룹이 그 판정과, 그때 **뒤집힌 2026-11-10 판정 둘**을 적는다.
/// - `Amazon S3 Glacier Direct`(유지 관리) · `AWS Directory Service – Simple AD`
///   (유지 관리) · `Amazon Q Developer IDE plugins`(종료 예정) ·
///   `AWS DataSync Discovery`(완전 종료, **2025-05-20** — 문항이 적는 날짜와 일치)
///   는 실재하므로 **하위 페이지로 정밀화**했다.
/// ⚠️ 이 파일의 대조군은 **상태(`verified`)를 단정하지 않는다.** 2026-11-13 검수자의
/// 첫 flip(`scs-t1-1`)이 그 단정 4건에 걸려 전체 스위트가 레드로 끝났다 — 사람의 flip 은
/// 바로 그 상태를 바꾸는 작업이므로, 「지금 전부 드래프트다」는 테스트가 아니라 기록이다.
/// flip 을 아는 계약은 `scs_questions_test.dart` 의 `flipApprovedTaskIds` 가 갖는다
/// (목록 밖 Task 는 전 문항 드래프트 · 목록 안 Task 는 verified 문항 ≥ 1).
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
    // ⚠️ 하한을 4 → 3 으로 내렸다(2026-11-12). 6단계 배치 1이 `t3-2-q13` 을 수명 주기
    //    메타 문항에서 파이프라인 도구 선택으로 **교체**해 `sunset_services.html` 인용
    //    하나가 정당하게 사라졌다. 공허성 하한은 **그때 측정된 수**이므로 내용이 줄면
    //    함께 내린다 — 지운 인용을 되살리는 것은 교체를 되돌리는 것이다.
    expect(subPageUses, greaterThanOrEqualTo(3),
        reason: '하위 페이지 인용이 사라지면 이 단정이 공허해진다(2026-11-12 실측 3건)');
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

  // ───────────────────── t3-2-q12 (2026-11-11 외부 검수 보고 🔴 재작성)
  //
  // ⚠️⚠️ **이 그룹은 2026-11-10 판정을 두 군데 뒤집는다.** 가드는 판정을 굳히므로
  // 판정이 틀리면 가드도 틀리다 — 옛 가드가 단정했던 두 가지가 모두 잘못이었다.
  //
  // ① **「지금 열리는 공식 페이지가 2025-11-20 을 적지 않는다」가 틀렸다.**
  //    `docs.aws.amazon.com/cli/latest/reference/codeguru-security/` 가 살아 있고
  //    (`index.html` → `/` 리다이렉트는 **후행 슬래시 정규화**이지 죽은 슬러그가
  //    아니다) 그 **본문에** `On November 20, 2025, AWS will discontinue support for
  //    Amazon CodeGuru Security. … you will no longer be able to access the
  //    /codeguru/security console, service resources, or documentation.` 가 글자
  //    그대로 있다(추출 본문 2,077자 · 대조군 `batch-get-findings` 3건 양성 ·
  //    `zzz-known-negative` 0건). 2026-11-10 에는 그 페이지의 **본문을 읽지 않고**
  //    「명령 참조라 상태를 말하지 않는다」고 **추정**했다 — 추측 금지 위반이었다.
  //    그래서 이제 **날짜를 쓰고 그 근거를 출처로 단다.**
  // ② **사용자 안내서 소멸은 그대로 맞다** — `security-ug/` 전 슬러그가 `404 r=0`
  //    이고 AWS 문서 리더도 not found 다. 외부 검수 보고는 검색 색인이 **그 URL 을
  //    인용하는** SDK·CLI 페이지를 보여 주는 것을 보고 「페이지가 존재한다」고 적었다.
  //
  // 재작성 사유는 보고가 든 「해설이 공식과 다르다」가 **아니다**(해설은 맞았다).
  // **메타 문항 + 저작 메모 + 길이 단서**다 — 옛 정답 보기는 110자였고 나머지 셋은
  // 30자 안팎이어서 이 뱅크 길이 단서의 극단 사례였다.
  group('scs-t3-2-q12: 기술 3.2.6 파이프라인 스캔 구성 (재작성)', () {
    test('메타 문항·저작 메모가 사라졌다', () {
      final q = questionById('scs-t3-2-q12');
      final all = jsonEncode(q);
      for (final memo in const [
        '전 페이지가 응답', // 내 측정 과정
        '목록에 없다', // 저작 규율 메모
        '기능 서술의 근거가 없', // 메타 서술
        '공식 시험 가이드가 드는 예시이므로', // 옛 보기
      ]) {
        expect(all.contains(memo), isFalse, reason: '저작 메모 잔존: $memo');
      }
      // 대조군 — 재작성 뒤에도 설계를 묻는 문항이어야 한다.
      expect((q['stem'] as String).contains('스캔 구성'), isTrue);
    });

    test('길이 단서를 다시 만들지 않았다', () {
      // ⚠️ 1차 초안이 정답 86자 · 최장 오답 81자였고 내 생성기 단정이 잡았다.
      // 보고의 최대 지적(정답이 유일하게 가장 긴 문항 227/240)을 고치는 자리에서
      // 같은 결함을 재생산하면 안 된다.
      final q = questionById('scs-t3-2-q12');
      final opts = (q['options'] as List).cast<String>();
      final correct = q['correct'] as int;
      final others = <int>[
        for (var i = 0; i < opts.length; i++)
          if (i != correct) opts[i].length,
      ];
      expect(opts[correct].length, lessThanOrEqualTo(others.reduce(max)),
          reason: '정답이 최장 선택지다 — 길이 단서가 돌아왔다');
      expect((q['explanation'] as String).length, lessThanOrEqualTo(450),
          reason: '보고 P-1 이 해설 400자 초과를 플래그 후보로 든다');
    });

    test('공식 사실을 적고 각 근거를 출처로 단다', () {
      final q = questionById('scs-t3-2-q12');
      final all = jsonEncode(q);
      // 규칙 세트 범주 — API 참조가 `Minimum 1 item. Maximum 3 items.` ·
      // `Valid Values: SAST | IAC | SCA` 로 적는다.
      for (final fact in const ['SAST', 'IAC', 'SCA', 'PULL_REQUEST', 'WEEKLY']) {
        expect(all.contains(fact), isTrue, reason: '공식 값 누락: $fact');
      }
      // 날짜를 적었다면 그 날짜를 적는 페이지가 출처에 있어야 한다.
      if (all.contains('2025년 11월 20일')) {
        expect(
            urlsOf('scs-t3-2-q12')
                .any((e) => e.contains('cli/latest/reference/codeguru-security')),
            isTrue,
            reason: '그 날짜를 본문에 적는 살아 있는 공식 페이지가 근거다');
      }
      final urls = urlsOf('scs-t3-2-q12');
      expect(
          urls.any((e) =>
              e.contains('inspector/latest/user/code-security-assessments.html')),
          isTrue);
      expect(
          urls.any((e) => e.contains(
              'inspector/v2/APIReference/API_CodeSecurityScanConfiguration.html')),
          isTrue);
      // ⚠️ 소멸한 사용자 안내서는 다시 들어오면 안 된다.
      expect(urls.any((e) => e.contains('codeguru/latest/security-ug')), isFalse,
          reason: '그 가이드는 전 슬러그가 404 다');
    });
  });

  test('정답 인덱스가 모두 불변이다', () {
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
  });
}
