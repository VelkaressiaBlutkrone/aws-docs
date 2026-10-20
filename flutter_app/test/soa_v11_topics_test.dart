import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// SOA-C03 공식 시험 가이드 v1.1 신규 주제의 본문 반영 가드 (2026-10-20).
///
/// 「v1.1 신규 주제」의 정본은 두 갈래다.
///   1. `docs/content-research/SOA-C03/97-guide-v11-diff.md` §0 — 공식 Revisions 표의
///      Skill 변경 10건 (1.1.1 · 1.2.1 · 1.3.4 · 2.3.4 · 3.1.2 · 3.2.2 · 4.1.3 ·
///      4.1.5 · 4.2.5 · 5.1.2). 기계 비교로 "표 밖의 숨은 실질 변경은 없다"고 확인됨.
///   2. 같은 문서 §4.1 — in-scope 서비스 추가 5건 (Amazon Bedrock · AWS DevOps Agent ·
///      AWS Health Dashboard · Kiro · AWS Security Agent).
/// 그중 `98-existing-gap.md` §4가 「없음/부분/구식」으로 판정한 13항목만 이 PR의 범위다.
///
/// `soa_facts_test.dart`와 같은 패턴으로, 각 주제마다 「구식 서술이 없다 + 공식 사실이
/// 있다」를 쌍으로 고정한다. 근거 주석의 영문은 공식 페이지 원문(≤15단어)이며 조회일은
/// 2026-10-20이다. 근거를 찾지 못한 하위 주장은 본문에 쓰지 않았다(PR 본문에 기록).
///
/// 범위 밖: `.questions.json`(300개 전부 verified:false) · content_index의 questionCount.
void main() {
  String doc(String id) => File('assets/content/soa/$id.md').readAsStringSync();

  // ---------------------------------------------------------------- 도메인 1

  group('V-1 Skill 1.1.1 — 서버리스·AI 워크로드 지표 (soa-t1-1)', () {
    // 근거: lambda/monitoring-metrics — "Lambda sends metric data to CloudWatch
    // in 1-minute intervals." / bedrock/monitoring-runtime-metrics — metrics are
    // "emitted under the namespace `AWS/Bedrock`", dimension "`ModelId` – all metrics".
    test('EC2의 세부 모니터링 규칙을 Lambda·Bedrock에 전이하는 서술이 없다', () {
      final t = doc('soa-t1-1');
      expect(t.contains('Lambda도 세부 모니터링'), isFalse);
      expect(t.contains('Bedrock 지표도 세부 모니터링'), isFalse);
      expect(t.contains('Bedrock 지표는 에이전트'), isFalse);
    });

    test('Lambda 1분 간격·AWS/Bedrock 네임스페이스가 들어왔다', () {
      final t = doc('soa-t1-1');
      expect(t.contains('Lambda는 지표를 1분 간격으로'), isTrue);
      expect(t.contains('AWS/Bedrock'), isTrue);
      expect(t.contains('InputTokenCount'), isTrue);
      expect(t.contains('ModelId'), isTrue);
    });

    test('EC2 기본/세부 모니터링 서술은 그대로 남아 있다(회귀 방지)', () {
      final t = doc('soa-t1-1');
      expect(t.contains('세부 모니터링'), isTrue);
    });
  });

  group('V-2 Skill 1.1.1 — 서버리스·AI 워크로드 로깅 (soa-t1-2)', () {
    // 근거: bedrock/model-invocation-logging — "Model invocation logging is
    // disabled by default." / "Only destinations from the same account and Region
    // are supported." / "only supported for calls made through the
    // `bedrock-runtime` endpoint." / lambda/monitoring-cloudwatchlogs —
    // "using the AWSLambdaBasicExecutionRole AWS managed policy".
    test('모델 호출 로깅이 기본 활성이라는 서술이 없다', () {
      final t = doc('soa-t1-2');
      expect(t.contains('모델 호출 로깅은 기본적으로 활성'), isFalse);
      expect(t.contains('Bedrock은 별도 설정 없이 호출 로그'), isFalse);
    });

    test('Lambda 로그 권한·Bedrock 모델 호출 로깅 사실이 들어왔다', () {
      final t = doc('soa-t1-2');
      expect(t.contains('AWSLambdaBasicExecutionRole'), isTrue);
      expect(t.contains('기본적으로 비활성'), isTrue);
      expect(t.contains('bedrock-runtime'), isTrue);
      expect(t.contains('같은 계정·같은 리전'), isTrue);
    });
  });

  group('V-3 Skill 1.2.1 — AWS DevOps Agent · Kiro (soa-t1-4)', () {
    // 근거: devopsagent/about-aws-devops-agent — "an AI-powered, always-available
    // agent that spans release management and production operations" /
    // responsible-ai overview — "operates within Agent Spaces" and each Agent Space
    // "maintains a topology—a knowledge graph of the application environment".
    // Kiro 근거: q/developer/faqs — "a standalone agentic development experience
    // that helps you go from concept to production with spec-driven development".
    test('기존 모니터링 서비스를 대체한다는 서술이 없다', () {
      final t = doc('soa-t1-4');
      expect(t.contains('DevOps Agent가 CloudWatch를 대체'), isFalse);
      expect(t.contains('Kiro가 Systems Manager를 대체'), isFalse);
    });

    test('두 서비스의 공식 정의가 들어왔다', () {
      final t = doc('soa-t1-4');
      expect(t.contains('AWS DevOps Agent'), isTrue);
      expect(t.contains('Agent Space'), isTrue);
      expect(t.contains('Kiro'), isTrue);
      expect(t.contains('스펙 기반 개발'), isTrue);
    });
  });

  group('V-4 Skill 1.3.4 — 공유 스토리지에 Amazon S3 Files 추가 (soa-t1-5)', () {
    // 근거: s3/features/files — "S3 Files is a shared file system that connects
    // any AWS compute directly with your data in Amazon S3." / console help panel
    // "S3 Versioning must be enabled on the linked S3 bucket." / "supports the
    // Network File System version 4 protocol" / "the S3 bucket is treated as the
    // source of truth".
    test('공유 스토리지를 EFS·FSx 2종으로만 제시하지 않는다', () {
      final t = doc('soa-t1-5');
      expect(t.contains('EFS와 FSx 두 가지'), isFalse);
      expect(t.contains('EFS·FSx 중에서'), isFalse);
      expect(t.contains('공유 스토리지는 EFS와 FSx'), isFalse);
    });

    test('S3 Files의 공식 사실이 들어왔다', () {
      final t = doc('soa-t1-5');
      expect(t.contains('Amazon S3 Files'), isTrue);
      expect(t.contains('NFS'), isTrue);
      expect(t.contains('S3 버전 관리'), isTrue);
      expect(t.contains('source of truth'), isTrue);
    });

    test('EFS·FSx도 함께 비교축에 있다', () {
      final t = doc('soa-t1-5');
      expect(t.contains('Amazon EFS'), isTrue);
      expect(t.contains('Amazon FSx'), isTrue);
    });
  });

  // ---------------------------------------------------------------- 도메인 2

  group('V-5 Skill 2.3.4 — DR 모범 사례 (soa-t2-4)', () {
    // 근거: wellarchitected REL11-BP04 — "Route 53 routing policies use the
    // control plane, so do not rely on it for recovery." / "The Route 53 data
    // planes answer DNS queries and perform and evaluate health checks." /
    // "designed for a 100% availability service level agreement (SLA)" /
    // "the control planes are located in a single Region: US East (N. Virginia)".
    test('장애 조치를 제어 영역 작업으로 권하는 서술이 없다', () {
      final t = doc('soa-t2-4');
      expect(t.contains('제어 영역(control plane) 작업으로 장애 조치'), isFalse);
      expect(t.contains('가중치를 바꾸는 것이 가장 안전'), isFalse);
    });

    test('데이터 영역 우선·IaC 재배포 모범 사례가 들어왔다', () {
      final t = doc('soa-t2-4');
      expect(t.contains('데이터 영역(data plane)'), isTrue);
      expect(t.contains('제어 영역(control plane)'), isTrue);
      expect(t.contains('us-east-1'), isTrue);
      expect(t.contains('코드형 인프라'), isTrue);
    });

    test('기존 DR 전략 4종·game day 서술은 유지된다(회귀 방지)', () {
      final t = doc('soa-t2-4');
      expect(t.contains('Pilot Light'), isTrue);
      expect(t.contains('Warm Standby'), isTrue);
      expect(t.contains('game day'), isTrue);
    });
  });

  // ---------------------------------------------------------------- 도메인 3

  group('V-6 Skill 3.1.2 — AWS CDK (soa-t3-1)', () {
    // 근거: cdk/v2/guide/migrate — "Use the `cdk synth` command to synthesize the
    // stack in your CDK app into an AWS CloudFormation template." / "When you
    // deploy a CDK app, the AWS CDK CLI utilizes the AWS CloudFormation service to
    // provision your resources." / bootstrapping-customizing — "Bootstrapping
    // creates resources in your AWS environment that are used by the AWS CDK".
    test('CDK가 CloudFormation을 대체한다는 서술이 없다', () {
      // 부분 문자열 가드는 부정형("대체하지 않습니다")까지 잡으므로 긍정 오류문만 막는다.
      final t = doc('soa-t3-1');
      expect(t.contains('CDK는 CloudFormation을 대체합니다'), isFalse);
      expect(t.contains('CDK는 CloudFormation을 대체하며'), isFalse);
      expect(t.contains('CDK는 CloudFormation 없이'), isFalse);
      // 올바른 서술(대체하지 않는다)이 실제로 있어야 한다.
      expect(t.contains('CloudFormation을 대체하지 않습니다'), isTrue);
    });

    test('synth·bootstrap·diff와 CloudFormation 경유 배포가 들어왔다', () {
      final t = doc('soa-t3-1');
      expect(t.contains('cdk synth'), isTrue);
      expect(t.contains('cdk bootstrap'), isTrue);
      expect(t.contains('cdk diff'), isTrue);
      expect(t.contains('CloudFormation 템플릿으로 합성'), isTrue);
    });
  });

  group('V-7 Skill 3.2.2 — EventBridge 예약 규칙 레거시·대상 한도 (soa-t3-4)', () {
    // 근거: eventbridge/eb-create-rule-schedule — "Scheduled rules are a legacy
    // feature of EventBridge." / "We recommend that you use Scheduler to invoke
    // targets on a schedule." / EventBridge PutTargets — "Each rule can have up to
    // five (5) targets associated with it at one time."
    test('예약 규칙을 레거시 표시 없이 제시한 구식 표 행이 사라졌다', () {
      final t = doc('soa-t3-4');
      expect(
          t.contains('| **스케줄 규칙** | **cron/rate 식**에 따라 주기적으로 |'), isFalse);
      expect(t.contains('대상 수에는 제한이 없'), isFalse);
    });

    test('레거시 표시·Scheduler 권장·규칙당 대상 5개가 들어왔다', () {
      final t = doc('soa-t3-4');
      expect(t.contains('레거시(legacy)'), isTrue);
      expect(t.contains('EventBridge Scheduler'), isTrue);
      expect(t.contains('규칙당 최대 5개'), isTrue);
    });
  });

  group('V-8 Skill 3.2.2 — AWS DevOps Agent 이벤트 연동 (soa-t3-4)', () {
    // 근거: devopsagent EventBridge 통합 — "AWS DevOps Agent sends events to
    // Amazon EventBridge when the state of an investigation or mitigation changes."
    test('EventBridge와 연동되지 않는다는 서술이 없다', () {
      final t = doc('soa-t3-4');
      expect(t.contains('DevOps Agent는 EventBridge와 연동되지 않'), isFalse);
    });

    test('조사·완화 상태 전이 이벤트가 들어왔다', () {
      final t = doc('soa-t3-4');
      expect(t.contains('AWS DevOps Agent'), isTrue);
      expect(t.contains('조사(investigation)'), isTrue);
      expect(t.contains('완화(mitigation)'), isTrue);
    });
  });

  // ---------------------------------------------------------------- 도메인 4

  group('V-9 Skill 4.1.3 — Organizations·SCP·IAM Identity Center (soa-t4-1)', () {
    // 근거: organizations/orgs_manage_policies_scps_evaluation — "AWS Organizations
    // attaches an AWS managed SCP named FullAWSAccess to every root, OU and account
    // when it's created. This policy allows all services and actions." /
    // API_CreateOrganization — "`ALL`: ... the management account can also apply any
    // policy type to any member account" / singlesignon/permissionsetdelegation —
    // "To use permission sets, you'll need to use an Organization instance".
    test('SCP가 기본 거부라는 서술이 없다', () {
      final t = doc('soa-t4-1');
      expect(t.contains('SCP는 기본적으로 모든 것을 거부'), isFalse);
      expect(t.contains('SCP는 통합 결제만으로'), isFalse);
    });

    test('FullAWSAccess·모든 기능·OU·권한 세트가 들어왔다', () {
      final t = doc('soa-t4-1');
      expect(t.contains('FullAWSAccess'), isTrue);
      expect(t.contains('모든 기능(all features)'), isTrue);
      expect(t.contains('조직 단위(OU)'), isTrue);
      expect(t.contains('권한 세트(permission set)'), isTrue);
      expect(t.contains('외부 자격 증명 공급자'), isTrue);
    });

    test('기존 SCP 상한선·관리 계정 예외 서술은 유지된다(회귀 방지)', () {
      final t = doc('soa-t4-1');
      expect(t.contains('권한 상한선'), isTrue);
      expect(t.contains('관리 계정'), isTrue);
    });
  });

  group('V-10 Skill 4.1.5 — AWS Config 규정 준수 팩 (공식 KO 명칭) (soa-t4-2)', () {
    // 근거: 공식 ko_kr 도메인 4 페이지의 Skill 4.1.5 문구가 「AWS Config 규정 준수 팩」이며
    // 레포 `assets/exam_guides/SOA-C03.json`도 같은 표기다(PR#136). 기능 근거:
    // config/conformance-pack-organization-apis — "PutOrganizationConformancePack,
    // deploys conformance packs across member accounts in an AWS Organization".
    test('구식 명칭 「적합성 팩」이 본문에서 사라졌다', () {
      final t = doc('soa-t4-2');
      expect(t.contains('적합성 팩'), isFalse,
          reason: 'v1.1 공식 KO 명칭은 「규정 준수 팩」 (가이드 JSON과 일치해야 한다)');
    });

    test('공식 명칭과 조직 배포 사실이 들어왔다', () {
      final t = doc('soa-t4-2');
      expect(t.contains('규정 준수 팩'), isTrue);
      expect(t.contains('Conformance Pack'), isTrue);
      expect(t.contains('위임 관리자'), isTrue);
    });
  });

  group('V-11 Skill 4.1.5 — 리전 및 서비스 선택 (soa-t4-2)', () {
    // 근거: IAM reference_policies_condition-keys — "Use this key to compare the
    // AWS Region that was called in the request with the Region that you specify" /
    // "Because this endpoint is physically located in the US East (N. Virginia)
    // Region, IAM calls are always made to the us-east-1 Region." / "allows you to
    // control which endpoint of a service is invoked but does not control the
    // impact of the operation".
    test('리전 조건 키가 글로벌 서비스까지 막는다는 서술이 없다', () {
      final t = doc('soa-t4-2');
      expect(t.contains('글로벌 서비스까지 차단'), isFalse);
      expect(t.contains('aws:RequestedRegion으로 모든 리전 영향을 통제'), isFalse);
    });

    test('aws:RequestedRegion과 글로벌 서비스 예외가 들어왔다', () {
      final t = doc('soa-t4-2');
      expect(t.contains('aws:RequestedRegion'), isTrue);
      expect(t.contains('us-east-1'), isTrue);
      expect(t.contains('글로벌 서비스'), isTrue);
    });
  });

  group('V-12 Skill 4.2.5 — AWS Security Agent (soa-t4-2)', () {
    // 근거: aws.amazon.com/security-agent — "AWS Security Agent (now part of AWS
    // Continuum) is a frontier agent that proactively secures your applications" /
    // "It performs on-demand penetration testing customized to your application" /
    // "The agent generates threat models and conducts code security reviews".
    test('Security Hub의 하위 기능이라는 서술이 없다', () {
      final t = doc('soa-t4-2');
      expect(t.contains('Security Agent는 Security Hub의 기능'), isFalse);
      expect(t.contains('Security Agent는 GuardDuty의'), isFalse);
    });

    test('공식 명칭 병기와 기능이 들어왔다', () {
      final t = doc('soa-t4-2');
      expect(t.contains('AWS Security Agent'), isTrue);
      expect(t.contains('AWS Continuum'), isTrue);
      expect(t.contains('침투 테스트'), isTrue);
      expect(t.contains('위협 모델'), isTrue);
    });
  });

  // ---------------------------------------------------------------- 도메인 5

  group('V-13 Skill 5.1.2 — AWS PrivateLink 제공자 관점 (soa-t5-2)', () {
    // 근거: vpc/privatelink/create-endpoint-service — "For Load balancer type,
    // choose Network." / "select Acceptance required to require that connection
    // requests to your endpoint service are accepted manually" / "the service
    // provider must verify that they own the domain" / "service consumers can use
    // the endpoint-specific DNS name provided by AWS".
    test('PrivateLink가 AWS 서비스 전용이라는 서술이 없다', () {
      // 부분 문자열 가드는 부정형("전용이 아니라")까지 잡으므로 긍정 오류문만 막는다.
      final t = doc('soa-t5-2');
      expect(t.contains('PrivateLink는 AWS 서비스 전용입니다'), isFalse);
      expect(t.contains('사용자 서비스는 노출할 수 없'), isFalse);
      // 올바른 서술(자체 서비스도 노출 가능)이 실제로 있어야 한다.
      expect(t.contains('AWS 서비스 전용이 아니라'), isTrue);
    });

    test('엔드포인트 서비스·NLB·수락·도메인 검증이 들어왔다', () {
      final t = doc('soa-t5-2');
      expect(t.contains('엔드포인트 서비스'), isTrue);
      expect(t.contains('Network Load Balancer'), isTrue);
      expect(t.contains('수락 필요'), isTrue);
      expect(t.contains('도메인 소유권'), isTrue);
    });

    test('기존 Gateway vs Interface 비교는 유지된다(회귀 방지)', () {
      final t = doc('soa-t5-2');
      expect(t.contains('게이트웨이 엔드포인트'), isTrue);
      expect(t.contains('인터페이스 엔드포인트'), isTrue);
    });
  });

  // ---------------------------------------------------------------- 공통 규율

  group('V-14 신규 서비스 서술 규율 — 출제 추측 금지', () {
    // 가이드 Revisions 표는 예시 추가만 기록하고 출제 비중·빈도를 말하지 않는다.
    // 공식 근거가 없는 출제 추측을 본문에 쓰지 않았음을 고정한다.
    test('신규 AI 에이전트 3종에 출제 빈도 추측을 붙이지 않았다', () {
      for (final id in ['soa-t1-4', 'soa-t3-4', 'soa-t4-2']) {
        final t = doc(id);
        expect(t.contains('출제 비중'), isFalse, reason: '$id 출제 비중 추측');
        expect(t.contains('Kiro는 자주 출제'), isFalse);
        expect(t.contains('DevOps Agent는 자주 출제'), isFalse);
        expect(t.contains('Security Agent는 자주 출제'), isFalse);
      }
    });
  });

  group('V-15 갱신 날짜·공식 출처', () {
    const changed = [
      'soa-t1-1',
      'soa-t1-2',
      'soa-t1-4',
      'soa-t1-5',
      'soa-t2-4',
      'soa-t3-1',
      'soa-t3-4',
      'soa-t4-1',
      'soa-t4-2',
      'soa-t5-2',
    ];

    test('v1.1 주제를 반영한 10개 문서의 lastVerified가 2026-10-20이다', () {
      for (final id in changed) {
        expect(doc(id).contains('lastVerified: 2026-10-20'), isTrue,
            reason: '$id lastVerified 누락');
      }
    });

    test('새로 인용한 공식 출처가 sources에 실려 있다', () {
      expect(doc('soa-t1-1').contains('monitoring-runtime-metrics'), isTrue);
      expect(doc('soa-t1-2').contains('model-invocation-logging'), isTrue);
      expect(doc('soa-t1-4').contains('devopsagent'), isTrue);
      expect(doc('soa-t1-5').contains('s3/features/files'), isTrue);
      expect(
          doc('soa-t2-4')
              .contains('rel_withstand_component_failures_avoid_control_plane'),
          isTrue);
      expect(doc('soa-t3-1').contains('cdk/v2/guide'), isTrue);
      expect(doc('soa-t3-4').contains('eb-create-rule-schedule'), isTrue);
      expect(doc('soa-t4-1').contains('orgs_manage_policies_scps_evaluation'),
          isTrue);
      expect(doc('soa-t4-2').contains('conformance-pack-organization-apis'),
          isTrue);
      expect(doc('soa-t5-2').contains('create-endpoint-service'), isTrue);
    });

    test('문항 드래프트는 손대지 않았다 — 본문만 바뀌었다', () {
      // verified:false 전수 가드는 soa_questions_test.dart가 이미 수행한다.
      // 여기서는 본문 반영이 문항 파일로 번지지 않았는지만 확인한다.
      for (final id in changed) {
        final q = File('assets/content/soa/$id.questions.json');
        expect(q.existsSync(), isTrue, reason: '$id 문항 파일이 사라졌다');
        expect(q.readAsStringSync().contains('"verified": true'), isFalse,
            reason: '$id 문항이 flip됐다 — flip은 사람 검수 전용이다');
      }
    });
  });
}
