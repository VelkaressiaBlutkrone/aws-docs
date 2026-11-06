import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// CLF-C02 문항의 **정답 보기**가 공식 「범위 외 AWS 서비스」를 가리키면 해설에
/// **범위 메모**가 있어야 한다 — 2026-11-06 전 콘텐츠 2단 검토 §P2-D 반영.
///
/// ## 무엇이 문제였나
///
/// 라이브 문항 **5건**의 정답이 공식 「범위 외」 목록에 **이름으로 올라 있는**
/// 서비스였다(`AWS Billing Conductor` · `AWS CodeDeploy` · `AWS Wavelength` ·
/// `Amazon MemoryDB for Redis OSS` · `Amazon Personalize`).
///
/// ⚠️ **사실은 다섯 건 모두 정확하다.** 그래서 틀린 지식을 주지는 않는다 — 문제는
/// **학습 시간 배분**이다. Foundational 등급에서 범위 밖 서비스를 정답으로 외우게
/// 하면 학습자가 비용을 잘못 쓴다. 이 레포는 닫힌·특이 상태 서비스에 **상태 메모
/// 한 줄**을 붙이는 관례를 가지고 있고(AIF·MLA·CLF 의 「정직성 메모」), 보고서 §P2-F
/// 는 그 관례가 **문항에는 비대칭적으로 적용돼 있다**고 지적했다. 그 관례를 범위
/// 판정에도 적용한 것이 이 가드다.
///
/// ⚠️ **메모는 `explanation` 에 둔다.** 학습문서에만 적으면 학습자가 **오답노트·
/// 모의고사 화면에서 보지 못한다**(2026-11-06 MLA `mla-t1-2-q18` 에서 같은 교훈을
/// 얻었다 — md 의 상태 표가 있어도 문항에는 안 보인다).
///
/// ## 목록의 출처와 전수 대조
///
/// 아래 `outOfScopeServices` 는 공식 페이지 전문(2026-11-06 실측)에서 그대로 뽑았다:
/// <https://docs.aws.amazon.com/ko_kr/aws-certification/latest/cloud-practitioner-02/clf-02-out-of-scope-services.html>
///
/// ⭐ **전체 목록으로 CLF 301문항의 정답 보기를 대조하니 정확히 5건이 나왔다 —
/// 거짓 양성이 0이다.** 그래서 목록을 좁히지 않고 전부 넣었다. 앞으로 누가 범위 외
/// 서비스를 정답으로 쓰는 문항을 추가하면 **이 가드가 먼저 깨진다.**
///
/// ⚠️ **「목록에 없다」는 범위 밖 판정이 아니다.** 공식 페이지 스스로 *"이 목록에
/// 모든 사항이 포함된 것은 아니며 변경될 수 있습니다"* 라고 적는다. 그래서 이 가드는
/// **목록에 이름이 있는 것만** 본다(그 반대 방향으로는 아무것도 단정하지 않는다).
void main() {
  // 공식 「범위 외 AWS 서비스」(2026-11-06 전문 실측). 범주 순서대로 적었다.
  const outOfScopeServices = <String>[
    // 분석
    'Amazon AppFlow', 'AWS Clean Rooms', 'AWS Data Exchange', 'Amazon DataZone',
    'Amazon Managed Streaming for Apache Kafka', 'Amazon MSK',
    // 애플리케이션 통합
    'AWS AppFabric', 'Amazon Simple Workflow Service',
    // 비즈니스 애플리케이션
    'Amazon WorkDocs',
    // 컴퓨팅
    'AWS Copilot', 'AWS Wavelength',
    // 비용 관리
    'AWS Application Cost Profiler', 'Amazon DevPay',
    // 고객 지원
    'AWS Activate', 'AWS IQ', 'AWS Managed Services',
    // 클라우드 재무 관리
    'AWS Billing Conductor',
    // 데이터베이스
    'Amazon Keyspaces', 'Amazon MemoryDB', 'AWS AppConfig',
    // 개발자 도구
    'AWS Application Composer', 'AWS CodeArtifact', 'AWS CodeDeploy',
    'Amazon CodeGuru', 'AWS CloudShell', 'AWS Device Farm',
    // 게임 기술
    'Amazon GameLift', 'Amazon Lumberyard',
    // IoT
    'AWS IoT Device Defender', 'AWS IoT Greengrass', 'Amazon Monitron',
    // 기계 학습
    'Amazon Fraud Detector', 'Amazon Lookout for Metrics', 'AWS Panorama',
    'Amazon Personalize',
    // 관리 및 거버넌스
    'AWS Chatbot', 'Amazon Data Lifecycle Manager', 'Amazon Elastic Transcoder',
    'AWS Launch Wizard',
    // 미디어 서비스
    'AWS Elemental', 'Amazon Interactive Video Service', 'Amazon IVS',
    // 마이그레이션 및 전송
    'AWS Migration Hub Refactor Spaces', 'AWS Transfer Family',
    // 네트워킹 및 콘텐츠 전송
    'AWS Cloud Map', 'AWS Network Access Analyzer', 'AWS Ground Station',
    'Amazon VPC Lattice',
    // 보안·ID·규정 준수
    'Amazon Cloud Directory', 'AWS Network Firewall',
    // 로보틱스
    'AWS RoboMaker',
    // 스토리지
    'Amazon FSx for Lustre',
  ];

  /// 콘텐츠는 접두사를 떼고 쓰기도 한다(`Amazon MemoryDB` → `MemoryDB`,
  /// `AWS CodeDeploy` → `CodeDeploy`). 두 형태를 함께 본다.
  Set<String> forms(String service) {
    final out = <String>{service};
    for (final prefix in const ['Amazon ', 'AWS ']) {
      if (service.startsWith(prefix)) out.add(service.substring(prefix.length));
    }
    return out;
  }

  final files = Directory('assets/content/clf')
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.questions.json'))
      .toList()
    // ⚠️ `listSync()` 순서는 플랫폼마다 다르다(2026-11-06 CI 레드로 실측).
    ..sort((a, b) => a.path.compareTo(b.path));

  List<Map<String, dynamic>> questionsOf(File f) =>
      ((json.decode(f.readAsStringSync()) as Map<String, dynamic>)['questions']
              as List)
          .cast<Map<String, dynamic>>();

  List<Map<String, dynamic>> allQuestions() =>
      [for (final f in files) ...questionsOf(f)];

  /// 정답 보기가 가리키는 범위 외 서비스들.
  List<String> outOfScopeInAnswer(Map<String, dynamic> q) {
    final answer = (q['options'] as List).cast<String>()[q['correct'] as int];
    return [
      for (final s in outOfScopeServices)
        if (forms(s).any(answer.contains)) s,
    ];
  }

  /// 범위 메모가 달렸는지. 문구를 하나로 못 박지 않고 **두 낱말**로 본다 —
  /// 서비스마다 문장이 달라야 자연스럽기 때문이다(q19 는 범위 내 둘과 섞여 있다).
  bool hasScopeNote(Map<String, dynamic> q) {
    final e = q['explanation'] as String;
    return e.contains('범위 외') && e.contains('CLF-C02');
  }

  group('대조군 — 목록과 매칭이 작동한다', () {
    test('CLF 문항 자산이 읽혔다', () {
      expect(files.length, 19, reason: 'CLF 공식 Task 는 19개다');
      expect(allQuestions().length, greaterThan(250),
          reason: '0이면 아래 전수 단정이 공허하다');
    });

    test('탐지 집합은 CodeDeploy 한 건뿐이다', () {
      // 2026-11-06 1차: 다섯 건이었다(Billing Conductor · CodeDeploy · Wavelength ·
      // MemoryDB · Personalize). 그중 **넷을 범위 내 소재로 교체**(사용자 승인)해 하나만
      // 남았다 — 그리고 **그 줄어듦을 이 단정이 먼저 알렸다**(설계대로다).
      //
      // `clf-t3-1-q19` 만 남긴 이유: 정답 보기가 **범위 내 둘**(CodePipeline·CodeBuild)과
      // 섞여 있어 CodeDeploy 만 떼면 지문("빌드 단계와 배포 단계")이 성립하지 않는다.
      // 그래서 교체가 아니라 **범위 메모**가 자연스러운 처리다.
      final hit = <String, List<String>>{
        for (final q in allQuestions())
          if (outOfScopeInAnswer(q).isNotEmpty)
            q['id'] as String: outOfScopeInAnswer(q),
      };
      expect(hit.keys.toList()..sort(), ['clf-t3-1-q19'],
          reason: '늘었으면 새 문항이 범위 외 서비스를 정답으로 쓴 것이고, 줄었으면 '
              '문항이 또 교체된 것이다(둘 다 이 가드를 보고 판단해라)');
      expect(hit['clf-t3-1-q19'], ['AWS CodeDeploy']);
    });

    test('교체한 네 문항의 정답은 범위 외 서비스가 아니다', () {
      for (final qid in const [
        'clf-t3-2-q10',
        'clf-t3-4-q10',
        'clf-t3-7-q19',
        'clf-t4-2-q10',
      ]) {
        final q = allQuestions().firstWhere((q) => q['id'] == qid,
            orElse: () => fail('$qid 없음'));
        expect(outOfScopeInAnswer(q), isEmpty,
            reason: '$qid 은 2026-11-06 에 범위 내 소재로 교체했다');
      }
    });

    test('범위 내 서비스가 정답인 문항에는 메모를 요구하지 않는다', () {
      // 탐지기가 과잉이면 CLF 301문항 대부분이 걸린다. 그렇지 않음을 고정한다.
      final flagged = allQuestions().where((q) => outOfScopeInAnswer(q).isNotEmpty);
      expect(flagged.length, lessThan(10),
          reason: '전체 문항의 극히 일부여야 한다 — 많으면 목록·매칭이 과잉이다');
    });
  });

  test('정답이 범위 외 서비스인 문항은 해설에 범위 메모를 단다', () {
    final offenders = <String>[];
    for (final q in allQuestions()) {
      final oos = outOfScopeInAnswer(q);
      if (oos.isEmpty) continue;
      if (!hasScopeNote(q)) offenders.add('${q['id']} ← ${oos.join(', ')}');
    }
    offenders.sort();
    expect(offenders, isEmpty,
        reason: '사실은 맞아도 학습 시간 배분이 틀어진다. 해설에 「공식 CLF-C02 '
            '범위 외」 한 줄을 달아 우선순위를 알려 준다:\n${offenders.join('\n')}');
  });

  group('정답 자리는 교체 전과 같다', () {
    // ⚠️ 문항을 교체할 때도 **정답을 교체 전과 같은 인덱스**에 두었다. 앱이 전 경로에서
    // 보기를 셔플하므로 인덱스는 학습자에게 보이지 않고, 그래서 자리를 옮길 이유가
    // 없다 — 옮기면 `wrongExplanations` 키 집합까지 함께 바꿔야 하고 리뷰가 어려워진다.
    const correct = <String, int>{
      'clf-t3-1-q19': 0, // 메모만 추가(교체 안 함)
      'clf-t3-2-q10': 0, // Wavelength → 가용 영역 독립성
      'clf-t3-4-q10': 0, // MemoryDB → 용도별 DB 매칭(Neptune·DocumentDB·DynamoDB)
      'clf-t3-7-q19': 0, // Personalize → OpenSearch Service
      'clf-t4-2-q10': 1, // Billing Conductor → 비용 할당 태그 두 유형·활성화
    };
    correct.forEach((qid, idx) {
      test('$qid: correct == $idx', () {
        final q = allQuestions().firstWhere((q) => q['id'] == qid,
            orElse: () => fail('$qid 없음'));
        expect(q['correct'], idx);
      });
    });
  });

  group('교체 문항은 실측한 공식 출처를 든다', () {
    // 2026-11-06 `curl -sL` 로 네 URL 전부 `200 r=0` 확인. 출처를 지우거나 다른 페이지로
    // 바꾸면 이 단정이 깨진다 — 「URL 은 200 인데 그 페이지에 인용 사실이 없다」는
    // 이 레포의 반복 결함을 막는 쪽이다.
    const required = <String, String>{
      'clf-t3-2-q10':
          'https://aws.amazon.com/about-aws/global-infrastructure/regions_az/',
      'clf-t3-4-q10': 'https://docs.aws.amazon.com/neptune/latest/userguide/intro.html',
      'clf-t3-7-q19':
          'https://docs.aws.amazon.com/opensearch-service/latest/developerguide/what-is.html',
      'clf-t4-2-q10':
          'https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/cost-alloc-tags.html',
    };
    required.forEach((qid, url) {
      test('$qid: ${url.split('/').where((s) => s.endsWith('.html') || s == 'regions_az').first}',
          () {
        final q = allQuestions().firstWhere((q) => q['id'] == qid,
            orElse: () => fail('$qid 없음'));
        final urls = (q['sources'] as List)
            .map((s) => (s as Map<String, dynamic>)['url'] as String)
            .toList();
        expect(urls, contains(url));
      });
    });
  });
}
