// SCS-C03 2026-11-17 전수 검증 2단계 보정 가드.
//
// 정본: `docs/audits/2026-11-17-full-verify/scs.md`(1단계 보고) ·
//       `docs/audits/2026-11-17-full-verify/scs-phase2.md`(이 배치의 판정)
//
// 이 배치가 닫은 것 — 공개 🔴 3건 + 🟡 32문항 + 🟢 G3·G5·G6·G8·G9.
//
// ⚠️⚠️ **세 🔴 의 공통 원인은 「측정의 유효 기간」이다.** 셋 다 저작 시점에는 맞았고
//    그 뒤 공식 페이지가 움직였다(EMR 릴리스 7.11.0 의 세 번째 경로 · 2026-11-17 URL
//    교체로 바뀐 SEC03-BP03 본문 · CloudFront 체크리스트의 "Alternatively").
//    그래서 이 파일은 「옛 문구 0건」만 걸지 않고 **새 공식 사실이 실재하는지**를
//    쌍으로 고정한다 — 지우기만 하면 통과하는 가드는 출처 삭제를 막지 못한다.
//
// ⚠️⚠️ **`verified` 를 단정하지 않는다.** 2026-11-13 검수자의 첫 flip 이 그런 모양의
//    대조군 4건을 레드로 만들었다. 구조 단정(보기 4개 · Task 당 15문항 · 정답 인덱스
//    불변)으로 대신한다.
//
// ⚠️ 사실 단정은 **전수 집계형**이다. 문항별 리터럴 가드는 어형 하나로 뚫린다
//    (2026-11-06 AIF 「프로비저닝 처리량」 ↔ 「프로비저닝**된** 처리량」로 네 번 새어
//    나간 선례). 그리고 **md 와 문항을 함께** 센다 — 문항 가드는 `.md` 를 보지 않아
//    같은 거짓이 학습문서에 조용히 남는다.

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

const _dir = 'assets/content/scs';

const _taskIds = <String>[
  'scs-t1-1', 'scs-t1-2', 'scs-t1-3',
  'scs-t2-1', 'scs-t2-2',
  'scs-t3-1', 'scs-t3-2', 'scs-t3-3',
  'scs-t4-1', 'scs-t4-2',
  'scs-t5-1', 'scs-t5-2', 'scs-t5-3',
  'scs-t6-1', 'scs-t6-2', 'scs-t6-3',
];

String _md(String taskId) => File('$_dir/$taskId.md').readAsStringSync();

List<Map<String, dynamic>> _questions(String taskId) =>
    ((jsonDecode(File('$_dir/$taskId.questions.json').readAsStringSync())
            as Map<String, dynamic>)['questions'] as List)
        .cast<Map<String, dynamic>>();

List<Map<String, dynamic>> _allQuestions() =>
    [for (final t in _taskIds) ..._questions(t)];

Map<String, dynamic> _q(String id) {
  final taskId = id.substring(0, id.lastIndexOf('-'));
  return _questions(taskId).firstWhere((e) => e['id'] == id);
}

/// 문항 전체(지문·보기·해설·오답 근거·`skill`·출처 제목과 URL)를 한 문자열로.
String _allText(Map<String, dynamic> q) => jsonEncode(q);

String _correctOf(Map<String, dynamic> q) =>
    (q['options'] as List)[q['correct'] as int] as String;

List<String> _urlsOf(String id) =>
    ((_q(id)['sources'] as List).cast<Map<String, dynamic>>())
        .map((s) => s['url'] as String)
        .toList();

/// md 의 프런트매터 `sources:` URL 집합.
Set<String> _mdUrls(String taskId) => RegExp(r'url: (\S+)')
    .allMatches(_md(taskId).split('---')[1])
    .map((m) => m[1]!.trim())
    .toSet();

/// 「md + 문항」을 합쳐 자격증 전수를 도는 텍스트 맵. 키는 진단용 이름이다.
Map<String, String> _corpus() {
  final out = <String, String>{};
  for (final t in _taskIds) {
    out['$t.md'] = _md(t);
    for (final q in _questions(t)) {
      out[q['id'] as String] = _allText(q);
    }
  }
  return out;
}

/// 문장 단위로 쪼갠다 — 「같은 주장 안에 두 토큰이 함께 있는가」를 보려면
/// 파일 전체가 아니라 문장을 봐야 거짓 양성이 사라진다.
Iterable<String> _sentences(String text) =>
    text.split(RegExp(r'(?<=[.。!?])\s|\r?\n|\\n'));

void main() {
  // ================================================================= 대조군
  group('대조군', () {
    test('콘텐츠가 읽히고 구조가 맞다', () {
      expect(_taskIds.length, 16, reason: 'SCS 는 레포에서 유일한 6도메인 자격증이다');
      final all = _allQuestions();
      expect(all.length, 240);
      for (final t in _taskIds) {
        expect(_questions(t).length, 15, reason: '$t: Task 당 15문항 관례');
        // ⚠️ `String.length` 는 **문자 수**다(바이트 수가 아니다 — 한국어는 글자당
        //    3바이트). 하한은 추측하지 않고 실측값에서 잡는다(최소 `scs-t1-3.md` 15,314자).
        expect(_md(t).length, greaterThan(15000), reason: '$t: md 가 읽히지 않았다');
      }
      for (final q in all) {
        expect((q['options'] as List).length, 4, reason: '${q['id']}');
      }
      // 코퍼스가 md 16 + 문항 240 을 다 담는다(전수 단정이 공허해지지 않게).
      expect(_corpus().length, 256);
    });

    test('탐지기 대조군: 합성 입력에서 실제로 잡는다', () {
      // 1) 근접 탐지기
      final near = RegExp(r'장기 상승 권한.{0,40}안티패턴|안티패턴.{0,40}장기 상승 권한');
      expect(near.hasMatch('장기 상승 권한 부여를 안티패턴으로 적습니다'), isTrue);
      // 음성 — 한쪽 토큰만 있으면 잡지 않는다.
      expect(near.hasMatch('장기 상승 권한을 미리 부여해 두는 것은 최소 권한 원칙에 어긋납니다'),
          isFalse);
      // 음성 — 50자 넘게 떨어져 있으면 다른 주장이다.
      expect(
          near.hasMatch('장기 상승 권한은 최소 권한 원칙에 어긋납니다. '
              '승인 단계를 거치는 요청 절차가 공식이 드는 형태이고 교차 계정 역할을 '
              '미리 만들어 둡니다. 안티패턴은 따로 적혀 있습니다'),
          isFalse);
      // 2) 문장 분해기
      expect(_sentences('가. 나\r\n다').length, 3);
      // 3) 길이 비율 — 양방향이다
      double ratio(List<int> l, int c) {
        final o = [for (var i = 0; i < l.length; i++) if (i != c) l[i]];
        return l[c] / o.reduce(max);
      }
      expect(ratio([100, 50, 50, 50], 0) > 1.3, isTrue);
      expect(ratio([60, 50, 50, 50], 0) > 1.3, isFalse);
    });
  });

  // ============================================================ 정답 인덱스
  test('⚠️ 이 배치가 손댄 36문항의 정답 인덱스가 전부 불변이다', () {
    // ⚠️ 보고는 정답 인덱스를 적지 않는 자리가 있고, 레포가 그것을 추측하다
    //    14건 중 6건을 틀린 선례가 있다. 이 맵은 전부 **실측값**이다.
    const expected = <String, int>{
      // 🔴
      'scs-t5-1-q14': 3, 'scs-t6-1-q15': 3, 'scs-t3-1-q5': 0,
      // 🟡 공개
      'scs-t3-1-q1': 0, 'scs-t3-1-q3': 2, 'scs-t3-1-q12': 3, 'scs-t3-1-q15': 2,
      'scs-t5-1-q1': 0, 'scs-t1-1-q9': 0, 'scs-t4-1-q7': 2, 'scs-t4-1-q6': 1,
      'scs-t2-1-q15': 2, 'scs-t2-1-q14': 1, 'scs-t2-1-q2': 1,
      'scs-t6-1-q7': 0, 'scs-t6-1-q3': 2,
      // 🟡 드래프트
      'scs-t1-3-q15': 1, 'scs-t1-3-q3': 1, 'scs-t1-3-q4': 3,
      'scs-t1-2-q12': 3, 'scs-t1-2-q13': 0, 'scs-t2-2-q1': 0,
      'scs-t3-2-q12': 3, 'scs-t3-2-q13': 0, 'scs-t3-3-q14': 1, 'scs-t3-3-q15': 2,
      'scs-t4-2-q6': 1, 'scs-t5-2-q6': 2, 'scs-t5-2-q14': 1, 'scs-t5-2-q11': 2,
      'scs-t5-2-q9': 0, 'scs-t5-3-q7': 2, 'scs-t6-2-q6': 1, 'scs-t6-2-q14': 1,
      'scs-t6-3-q9': 0,
      // 🟢
      'scs-t6-3-q13': 0, 'scs-t6-3-q8': 3,
    };
    expect(expected.length, 37);
    for (final e in expected.entries) {
      expect(_q(e.key)['correct'], e.value, reason: '${e.key}: 정답 인덱스가 바뀌었다');
    }
    // ⚠️ `verified` 는 단정하지 않는다 — 사람의 flip 이 바로 그 값을 바꾼다.
  });

  // ==================================================================== 🔴 1
  group('🔴 scs-t5-1-q14 — EMR 전송 중 암호화 인증서 경로', () {
    // `emr-data-encryption-options.html`: "You specify the encryption artifacts used
    // for in-transit encryption in one of three ways: by allowing Amazon EMR to create
    // and manage certificates for you, by providing a zipped file of certificates that
    // you upload to Amazon S3, or by referencing a custom Java class…"
    // `emr-encryption-enable.html`: "With Amazon EMR release version 7.11.0 or later,
    // you have three options…" / "For Amazon EMR release version 4.8.0 through 7.10.0,
    // only a .zip file or custom Java class are supported."
    test('「인증서를 주는 방법」을 적는 모든 자리가 릴리스를 한정한다', () {
      // ⚠️ 트리거를 「방법이 둘」로 넓히면 `scs-t5-2.md` 의 「관리 방법이 둘입니다」(키
      //    관리 주제)가 걸린다. 「인증서를 주는 방법」으로 좁히고, 그 좁힘이 공허하지
      //    않다는 것을 hits 수로 고정한다.
      var hits = 0;
      _corpus().forEach((name, text) {
        for (final s in _sentences(text)) {
          if (!s.contains('인증서를 주는 방법')) continue;
          hits++;
          expect(s.contains('릴리스') || s.contains('7.10'), isTrue,
              reason: '$name: 릴리스 한정 없이 경로 개수를 적는다 — 7.11.0 이상은 셋이다\n$s');
        }
      });
      expect(hits, greaterThanOrEqualTo(3),
          reason: '탐지기가 아무것도 찾지 못했다 — 좁힘이 과했다');
    });

    test('세 번째 경로가 문항과 학습문서 양쪽에 적혀 있다', () {
      final q = _allText(_q('scs-t5-1-q14'));
      expect(q.contains('7.11.0'), isTrue);
      expect(q.contains('7.10.0'), isTrue);
      expect(q.contains('Secrets Manager'), isTrue,
          reason: '7.11.0 이상에서 EMR 이 만든 CA 의 PEM 인증서를 올리는 곳이다');
      expect(_q('scs-t5-1-q14')['stem'], contains('릴리스 7.9.0'),
          reason: '지문을 그 릴리스 범위로 한정해 보기 교체 없이 닫았다');
      final md = _md('scs-t5-1');
      expect(md.contains('7.11.0'), isTrue);
      expect(md.contains('4.8.0~7.10.0'), isTrue);
      expect(_urlsOf('scs-t5-1-q14')
              .any((u) => u.endsWith('emr-encryption-enable.html')),
          isTrue,
          reason: '릴리스별 경로를 적는 전용 페이지가 근거다');
    });
  });

  // ==================================================================== 🔴 2
  group('🔴 scs-t6-1-q15 — SEC03-BP03 현행판의 안티패턴', () {
    // 현행 `security-pillar/sec_permissions_emergency_process.html` 실측:
    // `elevated` 0건 · `validate and approve` 0건. 있는 것은 네 안티패턴 —
    // "You do not have well-documented and well-tested emergency access processes." /
    // "depend on the same systems (such as a centralized identity provider) as your
    // normal access mechanisms" / "are used in non-emergency situations" / "do not
    // generate sufficient logs to audit the processes".
    // 문항·md 의 옛 문구는 **2023-04-10 판**과 글자 그대로 맞았다 — 2026-11-17 URL 교체가
    // 그 URL 이 업고 있던 문장을 바꿨다.
    test('「장기 상승 권한 = 안티패턴」 귀속이 정정 줄 하나뿐이다', () {
      final near = RegExp(r'장기 상승 권한.{0,40}안티패턴|안티패턴.{0,40}장기 상승 권한');
      var exempt = 0;
      _corpus().forEach((name, text) {
        for (final s in _sentences(text)) {
          if (!near.hasMatch(s)) continue;
          // ⚠️ 옛 문구를 **인용해 정정하는 줄**은 죽이지 않는다(문구를 바꾸면 그 교육이
          //    사라진다). 예외는 「어느 판의 문구인가」를 적는 성질로 좁힌다.
          expect(s.contains('2023-04-10'), isTrue,
              reason: '$name: 현행판에 없는 안티패턴을 공식 귀속으로 적는다\n$s');
          exempt++;
        }
      });
      expect(exempt, 1,
          reason: '예외가 1줄이 아니다 — 모든 줄이 예외로 삼켜지는 상태와 「정말 0건」을 '
              '구별해야 한다');
    });

    test('현행 안티패턴과 형태가 문항·md 양쪽에 적혀 있다', () {
      final q = _allText(_q('scs-t6-1-q15'));
      expect(q.contains('안티패턴이 둘'), isFalse);
      for (final fact in const ['평소 접근과 같은 시스템', '비상이 아닌 상황', '교차 계정 역할']) {
        expect(q.contains(fact), isTrue, reason: '현행 공식 사실 누락: $fact');
      }
      expect((_q('scs-t6-1-q15')['wrongExplanations'] as Map)['1'],
          contains('SEC03-BP02'),
          reason: '장기 상승 권한이 어긋나는 근거는 같은 페이지가 드는 최소 권한 모범 사례다');
      // 특권 세션 15분·`sts:AssumeRoot` 는 그 WA 페이지에 없다 — API 참조가 근거다.
      expect(_urlsOf('scs-t6-1-q15')
              .any((u) => u.endsWith('API_AssumeRoot.html')),
          isTrue);
      final md = _md('scs-t6-1');
      expect(md.contains('평소 접근과 같은 시스템에 의존'), isTrue);
      expect(md.contains('안티패턴 ②'), isFalse, reason: '옛 두 줄 표가 남아 있다');
    });
  });

  // ==================================================================== 🔴 3
  group('🔴 scs-t3-1-q5 — CloudFront 오리진 보호의 귀속', () {
    // 인용 `ecommerce-security-checklist.html` 은 두 수단을 **"Alternatively"** 로 적고
    // `strongest`·`together`·`shared` 가 0건이다. 측정된 문장은
    // `LocationsOfEdgeServers.html`: "This allows all of the CloudFront global
    // origin-facing servers to reach the instance."
    test('「가장 강한 오리진 보호」·「모든 고객의 배포」 귀속이 전수 0건이다', () {
      _corpus().forEach((name, text) {
        for (final bad in const ['가장 강한 오리진 보호', '모든 고객의 CloudFront 배포',
          '모든 고객의 배포']) {
          expect(text.contains(bad), isFalse, reason: '$name: 거짓 귀속 「$bad」');
        }
      });
    });

    test('측정된 문장이 문항·md 양쪽에 있고 새 출처가 달렸다', () {
      final q5 = _allText(_q('scs-t3-1-q5'));
      expect(q5.contains('오리진 대면 서버'), isTrue);
      expect(_correctOf(_q('scs-t3-1-q5')).contains('커스텀 오리진 헤더'), isTrue);
      expect(
          _urlsOf('scs-t3-1-q5')
              .any((u) => u.endsWith('LocationsOfEdgeServers.html')),
          isTrue);
      // 체크리스트 페이지는 **지우지 않는다** — 「헤더 값을 Secrets Manager 에 두고
      // 교체」와 두 수단의 나열을 실제로 담는다(`scs_source_fix_test` 도 요구한다).
      expect(
          _urlsOf('scs-t3-1-q5')
              .any((u) => u.endsWith('ecommerce-security-checklist.html')),
          isTrue);
      // 🟢 G9 — 출처 제목이 현행 `h1`(「…for marketplace distributions」)이다.
      for (final id in const ['scs-t3-1-q1', 'scs-t3-1-q5']) {
        final t = ((_q(id)['sources'] as List).cast<Map<String, dynamic>>())
            .firstWhere((s) =>
                (s['url'] as String).endsWith('ecommerce-security-checklist.html'))['title'] as String;
        expect(t.contains('marketplace distributions'), isTrue,
            reason: '$id: 출처 제목이 옛 `h1` 이다');
      }
      expect((_q('scs-t3-1-q1')['explanation'] as String).contains('함께 쓰며'),
          isFalse);
      final md = _md('scs-t3-1');
      expect(md.contains('Alternatively'), isTrue,
          reason: '체크리스트가 두 수단을 대안으로 적는다는 사실을 md 가 가르쳐야 한다');
      expect(md.contains('글로벌 오리진 대면 서버'), isTrue);
    });
  });

  // =============================================================== 🟡 출처 보강
  group('🟡 출처 보강 — 인용 페이지가 그 사실을 담지 않던 자리', () {
    test('문항별 새 정본이 출처에 들었다', () {
      // 전부 이 세션에서 `curl -sL` `200 r=0` + **본문에서 그 문장을 확인**한 것이다.
      const need = <String, List<String>>{
        // Y3 "WCUs – 2, as a base cost. For each custom aggregation key … add 30 WCUs."
        'scs-t3-1-q12': ['waf-rule-statement-type-rate-based.html'],
        // Y4 "To protect the intellectual property of the rule group providers…"
        'scs-t3-1-q15': ['waf-managed-rule-groups.html'],
        // Y1 "You are charged additional fees when you use this managed rule group."
        'scs-t3-1-q3': ['aws-managed-rule-groups-anti-ddos.html'],
        // Y5 "Other methods (for example, the AWS CLI, AWS CloudFormation, and the
        //     AWS CDK) – The default security policy is ELBSecurityPolicy-2016-08."
        'scs-t5-1-q1': ['describe-ssl-policies.html'],
        // Y6 "You can't use an AWS Region that is disabled by default as your home
        //     Region." / "March 20, 2019"
        'scs-t1-1-q9': ['finding-aggregation-enable.html', 'manage-acct-regions.html'],
        // Y7 "Call the AWS STS AssumeRole (recommended) or GetFederationToken…"
        'scs-t4-1-q7': ['id_roles_providers_enable-console-custom-url.html'],
        // Y8 "You can use the PolicyArns parameter to specify up to 10 managed
        //     session policies."
        'scs-t4-1-q6': ['access_policies.html'],
        // Y10 메모리 수집 뒤 격리(형제 페이지)
        'scs-t2-1-q15': ['forensic-memory-and-disk-acquisition-service.html'],
        // Y11 ARC 준비 상태 확인의 유지 관리 상태
        'scs-t2-1-q14': ['maintenance_services.html'],
        // Y12 "Affects management account" / "Supports viewing effective policy…"
        'scs-t6-1-q7': ['orgs_manage_policies.html'],
        // Y13 "scans your managed SCPs, RCPs, and Declarative policies daily" /
        //     "implemented as preCreate and preUpdate hook handlers"
        'scs-t6-1-q3': ['drift.html', 'proactive-controls.html'],
        // Y15·Y16 "API Gateway creates log groups or log streams for an API stage at
        //          the time when it is deployed."
        'scs-t1-3-q3': ['view-cloudwatch-log-events-in-cloudwatch-console.html'],
        'scs-t1-3-q4': ['view-cloudwatch-log-events-in-cloudwatch-console.html'],
        // Y17·Y18 세 서비스의 소개 페이지(열린 갭 G-31 의 자리)
        'scs-t1-2-q12': ['lambda/latest/dg/welcome.html',
          'opensearch-service/latest/developerguide/what-is.html',
          'what-is-Amazon-Managed-Service-Grafana.html'],
        'scs-t1-2-q13': ['opensearch-service/latest/developerguide/what-is.html',
          'what-is-Amazon-Managed-Service-Grafana.html'],
        // Y20 `supportedEvents` · `frequency` 유효값
        'scs-t3-2-q12': ['API_ContinuousIntegrationScanConfiguration.html',
          'API_PeriodicScanConfiguration.html'],
        // Y21 "On November 20, 2025, AWS will discontinue support…"
        'scs-t3-2-q13': ['cli/latest/reference/codeguru-security'],
        // Y22·Y23 "uses automated reasoning algorithms… static analysis… no packets
        //          are transmitted"
        'scs-t3-3-q14': ['how-network-access-analyzer-works.html'],
        'scs-t3-3-q15': ['how-network-access-analyzer-works.html'],
        // Y24·Y30 태그 조건 키의 정본
        'scs-t4-2-q6': ['reference_policies_condition-keys.html'],
        'scs-t6-2-q6': ['reference_policies_condition-keys.html'],
        // Y25·Y26 "Amazon Data Lifecycle Manager no longer manages that snapshot."
        'scs-t5-2-q6': ['snapshot-ami-policy.html'],
        'scs-t5-2-q14': ['snapshot-ami-policy.html'],
        // Y27 "File systems cannot transition into Archive storage before
        //      transitioning into IA storage."
        'scs-t5-2-q11': ['API_PutLifecycleConfiguration.html'],
      };
      for (final e in need.entries) {
        final urls = _urlsOf(e.key);
        for (final frag in e.value) {
          expect(urls.any((u) => u.contains(frag)), isTrue,
              reason: '${e.key}: 새 정본 $frag 이 출처에 없다');
        }
      }
    });

    test('⚠️ G-84: 문항 출처는 그 Task 학습문서 출처의 부분집합이다 (전수)', () {
      var checked = 0;
      for (final t in _taskIds) {
        final mdUrls = _mdUrls(t);
        for (final q in _questions(t)) {
          for (final s in (q['sources'] as List).cast<Map<String, dynamic>>()) {
            checked++;
            expect(mdUrls.contains(s['url']), isTrue,
                reason: '${q['id']}: ${s['url']} 가 $t.md 출처에 없다 — 「URL 은 200인데 '
                    '그 페이지에 그 사실이 없다」의 입구다');
          }
        }
      }
      expect(checked, greaterThanOrEqualTo(290), reason: '인용을 세지 못했다');
    });

    test('목차·오귀속 출처가 교체됐고 정본이 남았다', () {
      // ⚠️ 「지웠다」만 보는 가드는 출처 삭제를 통과시킨다 — **쌍으로** 단정한다.
      // `working-with-network-access-scopes.html` 은 1,968자 목차 페이지다(재측정).
      expect(_urlsOf('scs-t3-3-q14')
              .any((u) => u.endsWith('working-with-network-access-scopes.html')),
          isFalse);
      // `what-is-network-access-analyzer.html` 에 `reasoning` 이 0건이다.
      expect(_urlsOf('scs-t3-3-q15')
              .any((u) => u.endsWith('what-is-network-access-analyzer.html')),
          isFalse);
      for (final id in const ['scs-t3-3-q14', 'scs-t3-3-q15']) {
        expect(_urlsOf(id).isNotEmpty, isTrue, reason: '$id: 출처가 비었다');
      }
    });
  });

  // ================================================================ 🟡 문구 정정
  group('🟡 문구 정정 — 전수 집계', () {
    test('Anti-DDoS 관리형 규칙 그룹의 추가 요금을 빠뜨리지 않는다', () {
      // 공식 내부 어긋남 — 소개 페이지는 "All other AWS Managed Rules rule groups …
      // at no additional cost", 전용 페이지는 "You are charged additional fees when you
      // use this managed rule group". **더 구체적인 쪽을 정본**으로 삼는다(D-15 계열).
      _corpus().forEach((name, text) {
        expect(text.contains('그 밖의 모든 AWS Managed Rules'), isFalse,
            reason: '$name: 「그 밖의 모든」이 Anti-DDoS 를 삼킨다');
      });
      expect(_allText(_q('scs-t3-1-q3')).contains('Anti-DDoS'), isTrue);
      expect(_md('scs-t3-1').contains('Anti-DDoS 관리형 규칙 그룹'), isTrue);
    });

    test('⚠️ 닫힌·특이 상태 문구가 오답 근거에 없다 (가르치는 층에만)', () {
      // 보기가 틀린 이유가 **상태**가 아닌데 상태를 반박 근거로 쓰면, 그 상태가 그 보기를
      // 틀리게 만든 이유처럼 읽혀 거짓이 된다(6단계 배치 3 의 규율).
      var wrongs = 0;
      for (final q in _allQuestions()) {
        (q['wrongExplanations'] as Map<String, dynamic>).forEach((k, v) {
          wrongs++;
          for (final bad in const ['유지 관리 상태', '프리뷰 릴리스']) {
            expect((v as String).contains(bad), isFalse,
                reason: '${q['id']} W$k: 상태 문구는 해설로 옮긴다');
          }
        });
      }
      expect(wrongs, greaterThanOrEqualTo(700), reason: '오답 근거를 세지 못했다');
      // 대조군 — 가르치는 층에는 그대로 있다(지우는 것이 목적이 아니다).
      expect(_q('scs-t2-1-q14')['explanation'], contains('유지 관리 상태'));
      expect(_q('scs-t6-3-q13')['explanation'], contains('프리뷰 릴리스'));
      // ⚠️ `scs-t4-1-q4` 의 `W0` 은 **상태 자체가 반박 근거**라 정당하다 — 그 보기가
      //    틀린 이유가 SMS MFA 활성화 지원 종료다. 그래서 탐지기를 그 두 문구로 좁혔다.
      expect((_q('scs-t4-1-q4')['wrongExplanations'] as Map)['0'],
          contains('지원이 종료'));
    });

    test('Network Access Analyzer 를 「온디맨드 분석」으로 단정하지 않는다', () {
      // NAA 네 페이지 재측정: `on-demand`·`on demand`·`continuous`·`schedul` 전부 0건
      // (대조군 `MatchPaths`·`automated reasoning` 양성). **확인되지 않았다**.
      _corpus().forEach((name, text) {
        expect(text.contains('온디맨드 분석'), isFalse, reason: name);
      });
      expect(_allText(_q('scs-t3-3-q14')).contains('정적 분석'), isTrue);
      expect(_md('scs-t3-3').contains('정적 분석'), isTrue);
    });

    test('ABAC — 「RBAC 옆에 ABAC 를 더하라」는 공식 권고로 적지 않는다', () {
      // `introduction_attribute-based-access-control.html` 실측: `recommend` 0 ·
      // `alongside` 0 · `in addition` 0 · `combin` 0 · `aws:ResourceTag` 0.
      // 그 페이지가 적는 것은 "ABAC provides the following advantages over the
      // traditional RBAC model" 까지다.
      _corpus().forEach((name, text) {
        for (final bad in const ['RBAC 옆에 ABAC', '공존을 권']) {
          expect(text.contains(bad), isFalse, reason: '$name: $bad');
        }
      });
      expect(_md('scs-t4-2').contains('함께 쓸 수 있습니다'), isTrue,
          reason: '둘을 함께 쓸 수 있다는 사실 자체는 지우지 않는다');
      expect(_allText(_q('scs-t4-2-q6')).contains('조건 키'), isTrue);
    });

    test('개수를 단정하지 않는다 (D-16)', () {
      _corpus().forEach((name, text) {
        for (final bad in const ['전제가 다섯', '안티패턴이 둘']) {
          expect(text.contains(bad), isFalse, reason: '$name: $bad');
        }
      });
      // 대조군 — 열거 자체는 남아 있다(개수만 걷었다).
      expect(_md('scs-t6-3').contains('기록할 리소스 유형'), isTrue);
    });

    test('FIPS 140-3 수준 3 검증을 모든 키 저장소 유형으로 일반화하지 않는다', () {
      // `key-store-overview.html` 의 그 문장은 **표준 키 저장소** 단락에 있다 —
      // "The standard key store in AWS KMS … generated in and protected by hardware
      // security modules (HSMs) that are FIPS 140-3 Level 3 validated."
      // 외부 키 저장소의 HSM 은 고객이 고르므로 「모든 유형」의 근거가 그 페이지에 없다.
      _corpus().forEach((name, text) {
        expect(text.contains('모든 키 저장소 유형이 FIPS'), isFalse, reason: name);
      });
      expect((_q('scs-t5-3-q7')['wrongExplanations'] as Map)['3'],
          contains('가져온 키'));
      expect(_md('scs-t5-3').contains('표준 키 저장소에서 만드는 KMS 키'), isTrue);
    });

    test('DLM 과 잠긴 스냅샷의 공식 귀결이 적혀 있다', () {
      // "If you manually lock a snapshot created by Amazon Data Lifecycle Manager, and
      // that snapshot is still locked when its retention threshold is reached, Amazon
      // Data Lifecycle Manager no longer manages that snapshot. You must manually
      // delete the snapshot if it is no longer needed."
      for (final id in const ['scs-t5-2-q6', 'scs-t5-2-q14']) {
        final e = _q(id)['explanation'] as String;
        expect(e.contains('보존 임계'), isTrue, reason: '$id: 공식 조건이 빠졌다');
        expect(e.contains('수동'), isTrue, reason: '$id: 수동 삭제 귀결이 빠졌다');
      }
    });

    test('무출처 부연을 문항에서 걷었다 — md 는 유지하고 출처를 달았다', () {
      // ⚠️ **보존 가드**다. 두 서술은 **옳다** — 다만 문항이 인용한 페이지가 담지 않았다.
      //   `lambda/latest/dg/governance-code-signing.html`: `IoT` 0 · `Notation` 0 ·
      //   `container` 0. `servicecatalog/.../introduction.html`: `Account Factory` 0 ·
      //   `Control Tower` 0. `controltower/.../account-factory.html`: `Service Catalog` 0.
      //   그래서 **문항에서는 정답을 가르지 않는 부연을 걷고, md 는 정본을 달아 살렸다.**
      expect(_allText(_q('scs-t5-2-q9')).contains('Notation'), isFalse);
      expect((_q('scs-t5-2-q9')['wrongExplanations'] as Map)['3'],
          contains('코드 서명 구성'));
      expect(_md('scs-t5-2').contains('Notation CLI'), isTrue,
          reason: '옳은 서술을 지우는 것이 목적이 아니다');
      expect(_mdUrls('scs-t5-2')
              .any((u) => u.contains('signer/latest/developerguide/Welcome.html')),
          isTrue);

      expect(_allText(_q('scs-t6-2-q14')).contains('Account Factory'), isFalse);
      expect(_correctOf(_q('scs-t6-2-q14')).contains('포트폴리오'), isTrue);
      expect(_md('scs-t6-2').contains('프로비저닝된 제품과 연결'), isTrue,
          reason: '측정된 서술("a provisioned product that\'s associated with an '
              'account that Account Factory vends")로 좁혔다');
      expect(_md('scs-t6-2').contains('Service Catalog의 프로비저닝된 제품 위에'), isFalse,
          reason: '그 귀속은 공식 Account Factory 페이지에 없다');
      expect(_mdUrls('scs-t6-2').any((u) => u.endsWith('account-factory.html')),
          isTrue);

      // Y9 · `scs-t2-1-q2` — 「노트북은 런북의 실행 가능한 판」이 무출처였다
      // (인용 `systems-manager/…/OpsCenter.html`: `SageMaker` 0 · `notebook` 0,
      //  대조군 `runbook` 10 양성). 공식 docs 에서 그 역할을 적는 페이지를 찾지
      // 못했으므로(§6-4) 추론 서술을 걷고 **검증 가능한 귀속만** 남겼다 —
      // 레포 `exam_guides/SCS-C03.json` 의 `기술 2.1.1` 이 두 이름을 함께 든다.
      expect(_allText(_q('scs-t2-1-q2')).contains('런북의 실행 가능한 판'), isFalse);
      expect(_allText(_q('scs-t2-1-q2')).contains('기술 2.1.1'), isTrue);
      final guide = File('assets/exam_guides/SCS-C03.json').readAsStringSync();
      expect(guide.contains('Amazon SageMaker AI 노트북'), isTrue,
          reason: '귀속의 근거가 가이드 전사에 실재해야 한다(`scs_guide_sync_test` 가 '
              '그 전사를 공식과 바이트 단위로 고정한다)');
    });

    test('t1-3-q15 지문이 성립하지 않는 전제를 쓰지 않는다', () {
      // "IN_WARM_UP – … does not yet evaluate. The alarm remains in INSUFFICIENT_DATA
      // and does not perform alarm actions until the warm-up period ends."
      // → 워밍업 중에는 ALARM 으로 **전이하지 않는다**.
      final stem = _q('scs-t1-3-q15')['stem'] as String;
      expect(stem.contains('ALARM 상태로 바뀌었'), isFalse);
      expect(stem.contains('ALARM으로 바뀌지 않'), isTrue);
      expect(stem.contains('IN_WARM_UP'), isTrue);
    });

    test('포렌식 — 공식 흐름이 고정하는 선후와 휘발성 원칙을 가른다', () {
      // 인용 페이지가 고정하는 것은 **메모리 캡처 → 격리**뿐이고 `snapshot` 은 0건이다.
      _corpus().forEach((name, text) {
        expect(text.contains('공식 흐름의 순서도 수집 뒤 격리'), isFalse, reason: name);
      });
      final e = _q('scs-t2-2-q1')['explanation'] as String;
      expect(e.contains('휘발성 순서 원칙'), isTrue);
      expect(e.contains('메모리 데이터를 캡처해 저장한 뒤'), isTrue);
    });

    test('API Gateway 실행 로그 그룹의 생성 주체를 정밀하게 적는다', () {
      _corpus().forEach((name, text) {
        expect(text.contains('로그 그룹을 API Gateway가 관리'), isFalse, reason: name);
      });
      expect(_allText(_q('scs-t1-3-q3')).contains('스테이지를 배포할 때'), isTrue);
      expect(_allText(_q('scs-t1-3-q4')).contains('스테이지를 배포할 때'), isTrue);
    });

    test('t6-3-q9 — 닫힌 서비스가 정답인 문항의 지문이 한정됐다 (D-04)', () {
      // 사실은 옳고 공식 `기술 6.3.2` 가 그 이름을 예시로 들어서 🔴 가 아니다.
      // ⚠️ 작은 쪽을 골랐다 — 보기·정답을 바꾸지 않고 지문을 한정했다.
      //    「둘째 요구의 답을 닫히지 않은 수단으로 바꿔 다시 쓰기」는 사람 승인 영역이라
      //    보고서 §컨트롤러 요청에 남겼다.
      final e = _q('scs-t6-3-q9');
      expect(e['stem'], contains('Audit Manager를 이미 쓰고'));
      expect(e['explanation'], contains('신규 고객'),
          reason: '상태는 가르치는 층에 그대로 있어야 한다');
      expect(_correctOf(e), isNot(contains('신규 고객')));
    });
  });

  // ======================================================================= 🟢
  group('🟢 품질', () {
    test('⚠️ G3: 길이 단서가 240문항 전수에서 **양방향** 0건이다', () {
      // ⚠️ 상한만 보는 가드는 「정답만 깎는」 반대 방향 결함을 통과시킨다. 기존
      //    `scs_length_cue_test` 는 하한을 `handled` 목록에만 걸어서 `scs-t3-1-q3`
      //    (47 < 49)과 `scs-t3-2-q12`(77 < 80)가 목록 밖으로 새어 있었다 — 이 배치가
      //    둘을 고치고 하한을 **전수**로 올린다.
      final over = <String>[];
      final under = <String>[];
      for (final q in _allQuestions()) {
        final lens = [for (final o in q['options'] as List) (o as String).length];
        final c = lens[q['correct'] as int];
        final others = [
          for (var i = 0; i < lens.length; i++)
            if (i != q['correct']) lens[i],
        ];
        if (c / others.reduce(max) > 1.3) {
          over.add('${q['id']}($c/${others.reduce(max)})');
        }
        if (c < others.reduce(min)) {
          under.add('${q['id']}($c<${others.reduce(min)})');
        }
      }
      expect(over, isEmpty, reason: '정답이 최장 오답의 1.3배를 넘는다');
      expect(under, isEmpty, reason: '정답이 최단 오답보다 짧다 — 반대 방향 길이 단서다');
    });

    test('🟢 G6: md 본문이 App Runner 를 상태 없이 나열하지 않는다', () {
      // 공식 WAF 페이지가 지금도 그 이름을 목록에 싣는 것은 사실이라 **지우지 않고**
      // 상태만 적는다(`maintenance_services.html` · 2026-03-31).
      final md = _md('scs-t3-1');
      expect(md.contains('App Runner'), isTrue);
      expect(md.contains('유지 관리 상태'), isTrue);
    });
  });
}
