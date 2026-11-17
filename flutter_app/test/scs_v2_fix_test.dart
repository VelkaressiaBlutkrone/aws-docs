import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// SCS-C03 **2단계 보정 가드** — 2026-11-17 전수 검증 보고(1단계)를 집행한 배치를 고정한다.
///
/// 집행 판정과 실측의 정본은 `docs/audits/2026-11-17-full-verify/scs-phase2.md` 이고
/// 1단계 보고는 같은 디렉터리의 `scs.md` 다.
///
/// ## 이 배치가 닫은 결함의 공통 원인 — 측정의 유효 기간
///
/// 공개 🔴 셋은 전부 **저작 뒤에 공식 페이지가 움직인 자리**다.
///
/// 1. **EMR 전송 중 암호화 인증서 경로** — 릴리스 7.11.0 부터 셋(EMR 이 인증서를 만들어
///    관리하는 경로가 더해졌다). 「둘」로 적은 문항은 오답 보기 하나가 참이 돼 **정답이 둘**
///    이었다. ⚠️ 덤으로 「Java 클래스 = 개인 키를 S3 에 둘 수 없을 때의 경로**라고 공식이
///    설명한다**」는 귀속은 현행 두 페이지 어디에도 없다 — zip 경로가 `privateKey.pem` 을
///    S3 에 올려야 한다는 **측정된 사실에서 따라오는 추론**으로 적는다.
/// 2. **Well-Architected 비상 접근 모범 사례** — 2026-11-17 URL 교체가 그 URL 이 업고 있던
///    문장을 다시 세지 않았다. 문항·학습문서의 「안티패턴 둘」은 2023-04-10 판의 문구이고
///    현행판은 넷이다. ⚠️⚠️ **현행 프레임워크판에서 이 모범 사례는 `FND05-BP02` 다**
///    (`framework/fnd05-bp02.html`, 200 r=0). 보안 원칙 백서판(`SEC03-BP03`)은 머리에
///    「historical reference only」 배너를 달고, 현행 프레임워크의 `SEC03-BP03` 은
///    **다른 모범 사례**다 — 번호로 찾으면 틀린 페이지를 인용한다.
/// 3. **CloudFront 오리진 보호** — 체크리스트 페이지는 두 수단을 "Alternatively" 로 적는다.
///    「함께 쓰는 것이 가장 강한 보호라고 공식이 적는다」는 귀속이 거짓이었다. 측정된 근거는
///    `restrict-access-to-load-balancer.html` 이다 — 커스텀 헤더가 기본 수단이고 관리형
///    접두사 목록은 "(Optional) … To further restrict access" 다.
///
/// ## 가드 설계
///
/// - **옛 문구 0건 + 새 공식 사실 있음**을 쌍으로 단정한다(지우기만 하면 통과하는 가드는
///   출처 삭제를 막지 못한다).
/// - 사실 단정은 **자격증 전수 집계형**이다 — md 16편 + 문항 16파일을 함께 본다.
///   문항별 리터럴 가드는 어형 하나로 뚫린다.
/// - ⚠️ **`verified` 를 단정하지 않는다.** 사람의 flip 이 바로 그 값을 바꾼다.
/// - ⚠️ 상태·한계 메모는 **문항 단위로** 센다 — `scs_doc_format_test` 의 저작 규율은
///   md 와 문항을 합쳐 읽어 md 가 조건을 만족하면 문항 쪽 누락이 통과한다.
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
  const docs = 'https://docs.aws.amazon.com/';

  final questions = <String, Map<String, dynamic>>{};
  final taskOf = <String, String>{};
  final md = <String, String>{};
  // 파일 이름 → 줄 목록 (md + 문항 전수).
  final corpus = <String, List<String>>{};
  for (final t in tasks) {
    final rawQ = File('$dir/$t.questions.json').readAsStringSync();
    final bank = jsonDecode(rawQ) as Map<String, dynamic>;
    for (final e in (bank['questions'] as List).cast<Map<String, dynamic>>()) {
      questions[e['id'] as String] = e;
      taskOf[e['id'] as String] = t;
    }
    md[t] = File('$dir/$t.md').readAsStringSync();
    corpus['$t.questions.json'] = const LineSplitter().convert(rawQ);
    corpus['$t.md'] = const LineSplitter().convert(md[t]!);
  }

  Map<String, dynamic> q(String id) => questions[id]!;
  String allOf(String id) => jsonEncode(q(id));
  List<String> optionsOf(String id) => (q(id)['options'] as List).cast<String>();
  int correctIdx(String id) => q(id)['correct'] as int;
  String correctOf(String id) => optionsOf(id)[correctIdx(id)];
  Map<String, dynamic> wrongs(String id) =>
      q(id)['wrongExplanations'] as Map<String, dynamic>;
  String explanationOf(String id) => q(id)['explanation'] as String;
  List<String> urlsOf(String id) => (q(id)['sources'] as List)
      .map((s) => (s as Map<String, dynamic>)['url'] as String)
      .toList();
  Set<String> mdUrls(String task) {
    final text = md[task]!;
    final end = text.indexOf('\n---', 4);
    return RegExp(r'^    url: (\S+)\s*$', multiLine: true)
        .allMatches(text.substring(0, end))
        .map((m) => m[1]!)
        .toSet();
  }

  /// md + 문항 전수에서 [p] 가 든 줄을 `파일: 줄` 로 돌려준다.
  List<String> hits(Pattern p) => <String>[
        for (final e in corpus.entries)
          for (final line in e.value)
            if (line.contains(p)) '${e.key}: ${line.trim()}',
      ];

  group('대조군', () {
    test('md 16편과 문항 240개가 읽히고 구조가 맞다', () {
      expect(md.length, 16);
      expect(questions.length, 240);
      for (final t in tasks) {
        expect(taskOf.values.where((v) => v == t).length, 15, reason: t);
        // ⚠️ String.length 는 문자 수다(한국어는 글자당 3바이트).
        expect(md[t]!.length, greaterThan(5000), reason: '$t.md 가 너무 짧다');
      }
      for (final id in questions.keys) {
        expect(optionsOf(id).length, 4, reason: id);
        expect(wrongs(id).length, 3, reason: id);
      }
    });

    test('전 문항의 키 구조가 같고 examGuideTaskId 가 뱅크와 같다', () {
      // ⚠️ `scs-t3-2-q12` 가 2026-11-11 재작성 때 `examGuideTaskId` 를 잃었다(240 중 1).
      //    앱은 누락을 빈 문자열로 읽으므로 flip 뒤에 「관련 문서 열기」와 오답 기술 집계가
      //    그 문항에서만 깨진다. 왕복 재현 대조군이 통과해도 이 결함은 보이지 않는다.
      const keys = <String>[
        'id', 'examGuideTaskId', 'skill', 'section', 'difficulty', 'stem',
        'options', 'correct', 'explanation', 'wrongExplanations', 'sources',
        'verified',
      ];
      for (final e in questions.entries) {
        expect(e.value.keys.toList(), keys, reason: '${e.key}: 키 구조가 다르다');
        expect(e.value['examGuideTaskId'], taskOf[e.key], reason: e.key);
      }
    });

    test('손댄 45문항의 정답 인덱스·skill·section·difficulty 가 불변이다', () {
      // 값은 손으로 적지 않고 보정 전후 파일에서 기계로 뽑았다(추측한 인덱스가 틀린 선례).
      const frozen = <String, (int, String, String, String)>{
        'scs-t1-1-q9': (0, '1.1.3', 'aggregation', 'applied'),
        'scs-t1-2-q12': (3, '1.2.5', 'correlate', 'foundational'),
        'scs-t1-2-q13': (0, '1.2.5', 'correlate', 'applied'),
        'scs-t1-2-q15': (1, '1.2.6', 'network', 'applied'),
        'scs-t1-3-q3': (1, '1.3.1', 'analyze', 'applied'),
        'scs-t1-3-q4': (3, '1.3.1', 'analyze', 'applied'),
        'scs-t1-3-q7': (1, '1.3.1', 'analyze', 'applied'),
        'scs-t1-3-q15': (1, '1.3.2', 'fix', 'applied'),
        'scs-t2-1-q2': (1, '2.1.1', 'runbooks', 'applied'),
        'scs-t2-1-q11': (2, '2.1.3', 'test', 'applied'),
        'scs-t2-1-q14': (1, '2.1.4', 'automate', 'applied'),
        'scs-t2-1-q15': (2, '2.1.4', 'automate', 'applied'),
        'scs-t2-2-q1': (0, '2.2.1', 'capture', 'foundational'),
        'scs-t3-1-q1': (0, '3.1.1', 'strategy', 'foundational'),
        'scs-t3-1-q3': (2, '3.1.1', 'strategy', 'applied'),
        'scs-t3-1-q5': (0, '3.1.2', 'implement', 'foundational'),
        'scs-t3-1-q12': (3, '3.1.3', 'controls', 'applied'),
        'scs-t3-1-q15': (2, '3.1.4', 'third-party', 'applied'),
        'scs-t3-2-q12': (3, '3.2.6', 'pipeline', 'applied'),
        'scs-t3-2-q13': (0, '3.2.6', 'pipeline', 'foundational'),
        'scs-t3-3-q4': (3, '3.3.2', 'hybrid', 'foundational'),
        'scs-t3-3-q14': (1, '3.3.5', 'identify', 'applied'),
        'scs-t3-3-q15': (2, '3.3.5', 'identify', 'applied'),
        'scs-t4-1-q6': (1, '4.1.2', 'temp', 'applied'),
        'scs-t4-1-q7': (2, '4.1.2', 'temp', 'applied'),
        'scs-t4-2-q6': (1, '4.2.2', 'abac', 'applied'),
        'scs-t5-1-q1': (0, '5.1.1', 'enforce-tls', 'applied'),
        'scs-t5-1-q14': (3, '5.1.3', 'inter-resource', 'applied'),
        'scs-t5-2-q6': (2, '5.2.2', 'integrity', 'foundational'),
        'scs-t5-2-q9': (0, '5.2.2', 'integrity', 'applied'),
        'scs-t5-2-q11': (2, '5.2.3', 'lifecycle', 'applied'),
        'scs-t5-2-q14': (1, '5.2.4', 'backup', 'applied'),
        'scs-t5-3-q7': (2, '5.3.3', 'key-stores', 'applied'),
        'scs-t5-3-q13': (0, '5.3.5', 'multi-region', 'applied'),
        'scs-t6-1-q3': (2, '6.1.2', 'control-tower', 'foundational'),
        'scs-t6-1-q7': (0, '6.1.3', 'org-policies', 'applied'),
        'scs-t6-1-q15': (3, '6.1.5', 'root-credentials', 'applied'),
        'scs-t6-2-q6': (1, '6.2.2', 'tags', 'applied'),
        'scs-t6-2-q8': (3, '6.2.2', 'tags', 'foundational'),
        'scs-t6-2-q14': (1, '6.2.4', 'sharing', 'applied'),
        'scs-t6-3-q1': (0, '6.3.1', 'config-rules', 'applied'),
        'scs-t6-3-q8': (3, '6.3.1', 'config-rules', 'foundational'),
        'scs-t6-3-q9': (0, '6.3.2', 'evidence', 'applied'),
        'scs-t6-3-q11': (2, '6.3.2', 'evidence', 'applied'),
        'scs-t6-3-q13': (0, '6.3.3', 'well-architected', 'applied'),
      };
      expect(frozen.length, 45);
      for (final e in frozen.entries) {
        final x = q(e.key);
        expect(
            (x['correct'], x['skill'], x['section'], x['difficulty']), e.value,
            reason: '${e.key}: 보존 필드가 바뀌었다');
      }
    });
  });

  group('🔴 scs-t5-1-q14 — EMR 인증서 경로는 릴리스 7.11.0 부터 셋이다', () {
    // EMR 문맥에서 「방법·경로가 둘」로 단정하는 줄.
    final two = RegExp(r'(방법|경로)(이|은|는|을)?\s?(둘|두 가지)|인증서 두 경로');
    bool emrTwo(String line) =>
        (line.contains('EMR') || line.contains('인증서를 주는')) &&
        two.hasMatch(line);

    test('탐지기 대조군: 옛 문구 셋을 잡고 정정문은 통과한다', () {
      expect(emrTwo('**TLS 인증서를 주는 방법이 둘입니다:**'), isTrue);
      expect(emrTwo('- 인증서를 주는 방법은 둘 — **S3 버킷의 `.zip` 파일 경로**와'), isTrue);
      expect(emrTwo('#### 3-2. Amazon EMR — 보안 구성과 인증서 두 경로'), isTrue);
      expect(
          emrTwo('릴리스 4.8.0부터 7.10.0까지는 zip 파일과 Java 클래스 둘만 지원됩니다. EMR'),
          isFalse,
          reason: '릴리스를 한정한 정정문은 걸리면 안 된다');
    });

    test('전수: EMR 인증서 경로를 「둘」로 단정하는 줄이 0건이다', () {
      final bad = <String>[
        for (final e in corpus.entries)
          for (final line in e.value)
            if (emrTwo(line)) '${e.key}: ${line.trim()}',
      ];
      expect(bad, isEmpty);
      expect(hits('금지하는 보안 정책이 있을 때의 경로'), isEmpty,
          reason: '그 귀속은 현행 EMR 두 페이지 어디에도 없다');
    });

    test('새 공식 사실과 출처가 문항과 학습문서 양쪽에 있다', () {
      const id = 'scs-t5-1-q14';
      for (final fact in const ['7.11.0', 'Secrets Manager', 'privateKey.pem']) {
        expect(allOf(id).contains(fact), isTrue, reason: '문항: $fact');
      }
      const enable = '${docs}emr/latest/ManagementGuide/emr-encryption-enable.html';
      expect(urlsOf(id), contains(enable));
      expect(
          urlsOf(id),
          contains(
              '${docs}emr/latest/ManagementGuide/emr-data-encryption-options.html'));
      expect(mdUrls('scs-t5-1'), contains(enable));
      expect(md['scs-t5-1']!.contains('7.11.0'), isTrue);
      expect(md['scs-t5-1']!.contains('privateKey.pem'), isTrue);
    });

    test('정답이 다시 둘이 되지 않는다', () {
      const id = 'scs-t5-1-q14';
      for (var i = 0; i < 4; i++) {
        if (i == correctIdx(id)) continue;
        // 「EMR 이 인증서를 만들어 준다」는 7.11.0 이상에서 참이다 — 오답 보기에 두면 안 된다.
        expect(optionsOf(id)[i].contains('자동 생성'), isFalse, reason: '보기 [$i]');
        expect(optionsOf(id)[i].contains('EMR이 인증서를 만들어'), isFalse,
            reason: '보기 [$i]');
      }
      // 교체한 오답은 공식이 명시적으로 부정하는 것이다(암호로 보호된 개인 키 미지원).
      expect(wrongs(id)['2'], contains('지원하지 않'));
    });
  });

  group('🔴 scs-t6-1-q15 — 비상 접근 모범 사례의 현행판', () {
    test('전수: 2023-04-10 판의 문구가 0건이다', () {
      for (final old in const [
        '안티패턴이 둘',
        '안티패턴 둘',
        '안티패턴 ①',
        '안티패턴 ②',
        '장기 상승 권한 부여를 안티패턴',
        '장기 상승 권한 부여가 공식이 적는 안티패턴',
        '복구할 비상 프로세스가 없는 것',
        '자동화된 프로세스나 파이프라인 문제',
      ]) {
        expect(hits(old), isEmpty, reason: '옛 판 문구 잔존: $old');
      }
    });

    test('현행판의 안티패턴과 두 판의 출처가 있다', () {
      const id = 'scs-t6-1-q15';
      for (final fact in const ['평소 접근과 같은 시스템', '비상이 아닌 상황', 'FND05-BP02']) {
        expect(allOf(id).contains(fact), isTrue, reason: '문항: $fact');
      }
      const fnd = '${docs}wellarchitected/latest/framework/fnd05-bp02.html';
      const sec =
          '${docs}wellarchitected/latest/security-pillar/sec_permissions_emergency_process.html';
      expect(urlsOf(id), containsAll(<String>[fnd, sec]));
      expect(mdUrls('scs-t6-1'), containsAll(<String>[fnd, sec]));
      for (final fact in const ['FND05-BP02', '역사적 참조용', '평소 접근과 같은 시스템']) {
        expect(md['scs-t6-1']!.contains(fact), isTrue, reason: '학습문서: $fact');
      }
      // 「15분」을 적는다면 그 수치를 담는 페이지가 출처에 있어야 한다.
      if (allOf(id).contains('15분')) {
        expect(urlsOf(id), contains('${docs}STS/latest/APIReference/API_AssumeRoot.html'));
      }
    });

    test('번호 혼동 방지: SEC03-BP03 을 적는 파일은 FND05-BP02 도 적는다', () {
      // 현행 프레임워크의 SEC03-BP03 은 「Analyze public and cross-account access」다.
      var n = 0;
      for (final e in corpus.entries) {
        final text = e.value.join('\n');
        if (!text.contains('SEC03-BP03')) continue;
        n++;
        expect(text.contains('FND05-BP02'), isTrue, reason: e.key);
      }
      expect(n, greaterThanOrEqualTo(2), reason: '대조군: 그 번호를 적는 파일이 없다');
    });
  });

  group('🔴 scs-t3-1-q5 — CloudFront 오리진 보호의 귀속', () {
    test('전수: 측정되지 않은 귀속과 옛 출처 제목이 0건이다', () {
      for (final old in const [
        '가장 강한 오리진',
        '모든 고객의',
        '제3자 배포에서 온',
        '다른 계정의 배포',
        '다른 사람의 CloudFront',
        'Security checklist for ecommerce',
      ]) {
        expect(hits(old), isEmpty, reason: '잔존: $old');
      }
    });

    test('측정된 문장과 그 출처가 문항 둘과 학습문서에 있다', () {
      const restrict =
          '${docs}AmazonCloudFront/latest/DeveloperGuide/restrict-access-to-load-balancer.html';
      const edge =
          '${docs}AmazonCloudFront/latest/DeveloperGuide/LocationsOfEdgeServers.html';
      const checklist =
          '${docs}AmazonCloudFront/latest/DeveloperGuide/ecommerce-security-checklist.html';
      expect(allOf('scs-t3-1-q5').contains('오리진 대면'), isTrue);
      expect(urlsOf('scs-t3-1-q5'), containsAll(<String>[restrict, edge]));
      expect(urlsOf('scs-t3-1-q1'), containsAll(<String>[restrict, checklist]));
      expect(explanationOf('scs-t3-1-q1').contains('함께 쓰며'), isFalse);
      expect(mdUrls('scs-t3-1'), containsAll(<String>[restrict, edge]));
      for (final fact in const ['오리진 대면', '선택 단계']) {
        expect(md['scs-t3-1']!.contains(fact), isTrue, reason: '학습문서: $fact');
      }
    });
  });

  group('🟡 출처 보강 — 인용 페이지가 그 사실을 담는다', () {
    // (문항, 출처 URL 조각들, 그 출처가 뒷받침하는 문항 속 사실)
    const rows = <(String, List<String>, String)>[
      ('scs-t3-1-q3', ['waf/latest/developerguide/aws-managed-rule-groups-anti-ddos.html'], 'Anti-DDoS'),
      ('scs-t3-1-q12', ['waf/latest/developerguide/waf-rule-statement-type-rate-based.html'], '30 WCU'),
      ('scs-t3-1-q15', ['waf/latest/developerguide/waf-managed-rule-groups.html'], '지식재산'),
      ('scs-t5-1-q1', ['elasticloadbalancing/latest/application/describe-ssl-policies.html'], 'ELBSecurityPolicy-2016-08'),
      ('scs-t1-1-q9', ['securityhub/latest/userguide/finding-aggregation-enable.html', 'accounts/latest/reference/manage-acct-regions.html'], '2019년 3월 20일'),
      ('scs-t4-1-q7', ['IAM/latest/UserGuide/id_roles_providers_enable-console-custom-url.html'], 'DurationSeconds'),
      ('scs-t4-1-q6', ['IAM/latest/UserGuide/access_policies.html'], '최대 10개'),
      ('scs-t2-1-q15', ['automated-forensics-orchestrator-for-amazon-ec2/forensic-memory-and-disk-acquisition-service.html'], '메모리 데이터를 캡처'),
      ('scs-t2-1-q14', ['general/latest/gr/maintenance_services.html'], '유지 관리'),
      ('scs-t6-1-q7', ['organizations/latest/userguide/orgs_manage_policies.html'], '유효 정책 보기'),
      ('scs-t6-1-q3', ['controltower/latest/controlreference/proactive-controls.html', 'controltower/latest/userguide/drift.html'], 'preCreate'),
      ('scs-t1-3-q3', ['apigateway/latest/developerguide/view-cloudwatch-log-events-in-cloudwatch-console.html'], '스테이지를 배포할 때'),
      ('scs-t1-3-q4', ['apigateway/latest/developerguide/view-cloudwatch-log-events-in-cloudwatch-console.html'], '스테이지를 배포할 때'),
      ('scs-t1-2-q12', ['opensearch-service/latest/developerguide/what-is.html', 'grafana/latest/userguide/what-is-Amazon-Managed-Service-Grafana.html', 'security-lake/latest/userguide/what-is-security-lake.html'], 'Managed Grafana'),
      ('scs-t3-2-q12', ['inspector/v2/APIReference/API_ContinuousIntegrationScanConfiguration.html', 'inspector/v2/APIReference/API_PeriodicScanConfiguration.html'], 'PULL_REQUEST'),
      ('scs-t3-2-q13', ['cli/latest/reference/codeguru-security/'], '지원이 종료'),
      ('scs-t3-3-q14', ['network-access-analyzer/how-network-access-analyzer-works.html', 'network-access-analyzer/getting-started.html'], '정적'),
      ('scs-t3-3-q15', ['network-access-analyzer/how-network-access-analyzer-works.html'], 'Transit Gateway'),
      ('scs-t4-2-q6', ['IAM/latest/UserGuide/reference_policies_condition-keys.html'], '요청 태그'),
      ('scs-t5-2-q6', ['ebs/latest/userguide/snapshot-ami-policy.html'], '관리에서 벗어나'),
      ('scs-t5-2-q14', ['ebs/latest/userguide/snapshot-ami-policy.html'], '관리에서 벗어나'),
      ('scs-t5-2-q11', ['efs/latest/APIReference/API_PutLifecycleConfiguration.html'], 'TransitionToArchive'),
      ('scs-t5-2-q9', ['signer/latest/developerguide/Welcome.html'], 'Notation'),
      ('scs-t6-2-q6', ['IAM/latest/UserGuide/reference_policies_condition-keys.html', 'organizations/latest/userguide/orgs_manage_policies.html'], 'aws:RequestTag'),
      ('scs-t6-2-q14', ['controltower/latest/userguide/what-is-control-tower.html'], 'Account Factory'),
    ];

    test('대조군: 스물다섯 문항이 읽힌다', () {
      expect(rows.length, 25);
      for (final r in rows) {
        expect(questions.containsKey(r.$1), isTrue, reason: r.$1);
      }
    });

    for (final r in rows) {
      test('${r.$1}: 사실 「${r.$3}」과 그 출처가 문항·학습문서에 있다', () {
        expect(allOf(r.$1).contains(r.$3), isTrue, reason: '사실이 사라졌다');
        for (final frag in r.$2) {
          final url = '$docs$frag';
          final full = urlsOf(r.$1).where((u) => u.endsWith(frag)).toList();
          expect(full.length, 1, reason: '출처 누락: $url');
          expect(mdUrls(taskOf[r.$1]!), contains(full.single),
              reason: 'G-84: 학습문서 출처에 없다 — ${full.single}');
        }
      });
    }

    test('목차만 담은 페이지를 사실 출처로 쓰지 않는다', () {
      // `working-with-network-access-scopes.html` 은 본문 1,774자의 목차 페이지다.
      for (final id in const ['scs-t3-3-q14', 'scs-t3-3-q15']) {
        expect(
            urlsOf(id).any((u) => u.contains('working-with-network-access-scopes')),
            isFalse,
            reason: id);
      }
    });
  });

  group('🟡 문구 정정 — 옛 문구 0건 + 새 사실 있음', () {
    // (문항, 금지 문구들, 필수 문구들) — 문항 전체(지문·보기·해설·오답 근거·출처 제목)를 본다.
    const rows = <(String, List<String>, List<String>)>[
      ('scs-t3-1-q3', ['그 밖의 모든 AWS Managed Rules'], ['Anti-DDoS', 'Bot Control']),
      ('scs-t1-1-q9', ['그곳에 Security Hub CSPM을 구성할 수도 없습니다'], ['옵트인 리전']),
      ('scs-t2-1-q2', ['런북의 실행 가능한 판'], ['시험 가이드']),
      ('scs-t6-1-q7', ['공식 표가'], ['정책 관리 페이지']),
      ('scs-t1-3-q15', ['알람이 ALARM 상태로 바뀌었는데'], ['ALARM 상태로 바뀌지 않고']),
      ('scs-t1-3-q3', ['API Gateway가 관리'], ['스테이지를 배포할 때']),
      ('scs-t1-3-q4', ['API Gateway가 관리'], ['스테이지를 배포할 때']),
      ('scs-t1-2-q13', ['Managed Grafana 묶음', '공식 서술입니다'], ['사용자 지정 소스', 'OCSF']),
      ('scs-t2-2-q1', ['공식 흐름의 순서도 수집 뒤 격리'], ['휘발성 순서 원칙']),
      ('scs-t3-3-q14', ['온디맨드', '주기 실행 자동화', '상시 자동 감시'], ['정적', 'MatchPaths']),
      ('scs-t4-2-q6', ['공존', 'RBAC 옆'], ['요청 태그', '보안 주체 태그']),
      ('scs-t5-2-q11', ['공식이 IA로 전환되기 전에는'], ['API 참조가']),
      ('scs-t5-3-q7', ['모든 키 저장소 유형이 FIPS'], ['똑같이 안전', '가져온 키']),
      ('scs-t6-3-q9', <String>[], ['이미 쓰고 있는', '신규 고객']),
      ('scs-t6-3-q8', ['전제가 다섯'], ['S3 버킷']),
    ];
    for (final r in rows) {
      test(r.$1, () {
        for (final old in r.$2) {
          expect(allOf(r.$1).contains(old), isFalse, reason: '옛 문구 잔존: $old');
        }
        for (final fact in r.$3) {
          expect(allOf(r.$1).contains(fact), isTrue, reason: '사실 누락: $fact');
        }
      });
    }

    test('scs-t4-2-q6 이 같은 Task q4 의 사실을 다시 묻지 않는다', () {
      // 1차 수정이 「새 리소스에 정책 수정이 필요 없다」를 정답에 넣어 q4 와 겹쳤고
      // 기존 전수 자카드 가드(출처 공유 쌍 < 0.33)가 잡았다. 그 사실은 q4 가 소유한다.
      expect(correctOf('scs-t4-2-q4').contains('정책 수정이 필요 없'), isTrue);
      expect(correctOf('scs-t4-2-q6').contains('정책 수정'), isFalse);
    });
  });

  group('전수 집계 — 자격증 전체에서 센다', () {
    test('확인되지 않은 주장 여섯 계열이 md·문항 전수에서 0건이다', () {
      for (final old in const [
        'RBAC 옆', // ABAC 공존 「권고」 — 공식 비교 페이지에 권고 문장이 없다
        '공존을 권',
        'API Gateway가 관리', // 실행 로그 그룹 — 공식은 「스테이지 배포 시 생성」
        '모든 키 저장소 유형이 FIPS', // 표준 키 저장소의 KMS HSM 서술을 일반화했다
        '런북의 실행 가능한 판', // 노트북의 역할을 적는 공식 페이지가 없다
        '전제가 다섯', // 개수 단정
        '온디맨드 분석', // Network Access Analyzer — 공식 세 페이지에 그 표현이 없다
        '주기 실행 자동화',
      ]) {
        expect(hits(old), isEmpty, reason: '잔존: $old');
      }
    });

    test('Network Access Analyzer 를 적는 줄에 「온디맨드」가 없다', () {
      // ⚠️ 「온디맨드」 자체는 금지할 수 없다 — KMS 온디맨드 회전·Patch now 가 정당한 용례다.
      final naa = hits('Network Access Analyzer');
      expect(naa.length, greaterThanOrEqualTo(10), reason: '대조군: 그 이름을 적는 줄');
      expect(naa.where((l) => l.contains('온디맨드')), isEmpty);
      expect(hits('온디맨드').length, greaterThanOrEqualTo(5),
          reason: '대조군: 정당한 용례가 남아 있다 — 낱말 전체를 금지한 것이 아니다');
    });

    test('상태 문구가 오답 근거에 놓인 문항은 그 상태가 반박 근거인 하나뿐이다', () {
      // 상태 메모는 가르치는 층에만 단다. 오답 근거에 달면 그 상태가 그 보기를 틀리게 만든
      // 이유처럼 읽힌다. `scs-t4-1-q4` 는 보기가 틀린 이유가 상태 자체(SMS MFA 종료)다.
      final status = RegExp(r'유지 관리|프리뷰|신규 고객|지원 종료|지원이 종료|완전 종료');
      final found = <String>{
        for (final id in questions.keys)
          if (wrongs(id).values.any((w) => status.hasMatch(w as String))) id,
      };
      expect(found, <String>{'scs-t4-1-q4'});
      // 가르치는 층에는 남아 있다(지우는 것이 목적이 아니다).
      expect(explanationOf('scs-t2-1-q14').contains('유지 관리'), isTrue);
      expect(explanationOf('scs-t6-3-q13').contains('프리뷰'), isTrue);
    });

    test('정답 보기에 「공식」이 든 문항이 0건이다', () {
      // 정답 보기만 「공식이 …라고 적습니다」로 끝나면 그 문구가 정답 표식이 된다.
      final marked = <String>[
        for (final id in questions.keys)
          if (correctOf(id).contains('공식')) id,
      ];
      expect(marked, isEmpty);
      // 대조군 — 해설의 출처 귀속은 정당한 층이라 그대로다(층 분리가 공허하지 않다).
      final inExplanation =
          questions.keys.where((id) => explanationOf(id).contains('공식')).length;
      expect(inExplanation, greaterThanOrEqualTo(50));
    });

    test('길이 단서가 양방향으로 0건이다 — 240문항 전수', () {
      // 상한(정답 ÷ 최장 오답 ≤ 1.3)은 기존 가드가 전수로 본다. 하한(정답이 최단 오답보다
      // 짧지 않다)은 `handled` 목록에만 걸려 있어 목록 밖 두 문항이 비켜 갔다.
      for (final id in questions.keys) {
        final lens = optionsOf(id).map((o) => o.length).toList();
        final c = lens[correctIdx(id)];
        final wrong = <int>[
          for (var i = 0; i < 4; i++)
            if (i != correctIdx(id)) lens[i],
        ]..sort();
        expect(c / wrong.last, lessThanOrEqualTo(1.3), reason: '$id: 정답이 너무 길다 $lens');
        expect(c, greaterThanOrEqualTo(wrong.first), reason: '$id: 정답이 최단이다 $lens');
      }
    });

    test('학습문서: App Runner 를 WAF 보호 대상으로 드는 문서가 상태를 본문에 적는다', () {
      final text = md['scs-t3-1']!;
      expect(text.contains('App Runner'), isTrue);
      expect(text.contains('App Runner는 2026-03-31 공지로 유지 관리 상태'), isTrue);
    });
  });
}
