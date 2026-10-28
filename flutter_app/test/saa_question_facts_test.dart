import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// SAA 문항 해설·오답근거의 사실 정정 가드 (2026-10-20).
///
/// 2026-08-06 weighted-ready batch(`docs/saa-review/2026-08-06-weighted-ready-batch.md`)의
/// advisory 문항을 공식 문서로 재확인해 해설·오답근거를 정정했다. `correct`(정답)는
/// 하나도 바뀌지 않았다 — 전부 루브릭 §3의 `fix`(해설 표현·출처) 판정이다.
/// 서비스 변경으로 생긴 구식 서술이 되살아나지 않도록 "옛 문장이 없다 + 공식 사실이
/// 있다" 쌍 단정으로 고정한다.
///
/// - `saa-t1-1-q13` STS는 글로벌 전용이 아니다 — 글로벌·리전 엔드포인트를 모두
///   제공하고, 기본 활성 리전에서는 글로벌 엔드포인트 요청이 요청이 발생한 같은
///   리전에서 처리되며 리전 엔드포인트 사용이 베스트 프랙티스다.
///   근거: https://docs.aws.amazon.com/sdkref/latest/guide/feature-sts-regionalized-endpoints.html
/// - `saa-t1-4-q4`·`q12` WAF 보호 대상은 9종이다(Amplify·Bedrock AgentCore
///   Gateway 포함).
///   근거: https://docs.aws.amazon.com/waf/latest/developerguide/what-is-aws-waf.html
/// - `saa-t1-4-q10` 관리형 교체는 Lambda 함수를 쓰지 않는다(RDS·Aurora·
///   DocumentDB·Redshift 마스터 자격증명). 그 외 비밀은 Lambda 교체 함수.
///   근거: https://docs.aws.amazon.com/secretsmanager/latest/userguide/rotate-secrets_managed.html
/// - `saa-t2-5-q8` Aurora 복제본은 같은 리전에서 데이터 볼륨을 공유해 복제 지연이
///   사실상 없다(통상 수십 ms). 글로벌 DB 교차 리전 복제는 비동기·통상 1초 미만.
///   근거: https://docs.aws.amazon.com/rds/latest/auroraextendedcontent/aurora-faq-availability-and-durability.html
void main() {
  Map<String, dynamic> question(String taskId, String qid) {
    final file = File('assets/content/saa/$taskId.questions.json');
    final map = json.decode(file.readAsStringSync()) as Map<String, dynamic>;
    final questions = (map['questions'] as List).cast<Map<String, dynamic>>();
    return questions.firstWhere(
      (q) => q['id'] == qid,
      orElse: () => fail('$qid 문항이 $taskId 에 없다'),
    );
  }

  String wrong(Map<String, dynamic> q, String index) =>
      (q['wrongExplanations'] as Map<String, dynamic>)[index] as String;

  bool hasSource(Map<String, dynamic> q, String fragment) =>
      (q['sources'] as List).any(
        (s) => ((s as Map<String, dynamic>)['url'] as String).contains(fragment),
      );

  group('saa-t1-1-q13 STS 엔드포인트 모델', () {
    final q = question('saa-t1-1', 'saa-t1-1-q13');

    test('정답은 그대로 임시 자격증명 만료(인덱스 1)', () {
      expect(q['correct'], 1);
    });

    test('"STS는 글로벌 성격" 단정이 사라졌다', () {
      expect(wrong(q, '3').contains('글로벌 성격으로 동작'), isFalse,
          reason: 'STS는 리전 서비스이며 글로벌 엔드포인트도 함께 제공한다');
    });

    test('글로벌·리전 엔드포인트를 모두 제공한다는 공식 서술이 들어왔다', () {
      final text = wrong(q, '3');
      expect(text.contains('리전 엔드포인트'), isTrue);
      expect(text.contains('글로벌 엔드포인트'), isTrue);
    });

    test('오답 근거의 논지(임시 자격증명은 리전에 묶이지 않는다)는 유지된다', () {
      expect(wrong(q, '3').contains('리전에 종속되지 않'), isTrue,
          reason: '보기 3을 오답으로 만드는 핵심 근거다');
    });

    test('공식 리전 엔드포인트 문서를 출처로 싣는다', () {
      expect(hasSource(q, 'feature-sts-regionalized-endpoints'), isTrue);
    });
  });

  group('saa-t1-4-q4 WAF 보호 대상 목록', () {
    final q = question('saa-t1-4', 'saa-t1-4-q4');

    test('정답은 그대로 RDS(인덱스 2)', () {
      expect(q['correct'], 2);
    });

    test('해설 목록에 Amplify와 Bedrock AgentCore Gateway가 들어왔다', () {
      final text = q['explanation'] as String;
      expect(text.contains('Amplify'), isTrue);
      expect(text.contains('AgentCore'), isTrue,
          reason: '공식 보호 대상 9종에 Bedrock AgentCore Gateway가 포함된다');
    });

    test('RDS가 대상이 아니라는 정답 근거는 유지된다', () {
      expect((q['explanation'] as String).contains('RDS'), isTrue);
    });
  });

  group('saa-t1-4-q10 Secrets Manager 관리형 교체', () {
    final q = question('saa-t1-4', 'saa-t1-4-q10');

    test('정답은 그대로 Secrets Manager(인덱스 1)', () {
      expect(q['correct'], 1);
    });

    test('정답 선택지가 "Lambda 기반 자동 교체"로 단정하지 않는다', () {
      final option = (q['options'] as List)[1] as String;
      expect(option.contains('Lambda 기반'), isFalse,
          reason: 'RDS 마스터 자격증명은 Lambda 없는 관리형 교체를 쓴다');
      // 2026-10-20 2차 재검수: 1차에서 "관리형 교체"로 바꾼 것이 반대쪽으로 치우쳤다
      // (관리형 교체는 마스터 자격증명 전용인데 stem은 앱이 접속하는 비밀번호다).
      // 어느 한쪽으로 단정하지 않는 중립 표현을 요구한다 — 아래 2차 그룹이 고정.
      expect(option.contains('자동 교체'), isTrue);
    });

    test('해설의 "내장 Lambda 교체 함수" 단정이 사라졌다', () {
      expect((q['explanation'] as String).contains('내장 Lambda 교체 함수'), isFalse);
    });

    test('해설이 관리형 교체(Lambda 미사용)와 그 외 비밀의 Lambda 교체를 구분한다', () {
      final text = q['explanation'] as String;
      expect(text.contains('관리형 교체'), isTrue);
      expect(text.contains('마스터'), isTrue,
          reason: '관리형 교체 대상은 마스터(관리자) 자격증명이다');
      expect(text.contains('Lambda'), isTrue,
          reason: '그 외 비밀은 Lambda 교체 함수를 쓴다는 대비가 남아야 한다');
    });

    test('공식 관리형 교체 문서를 출처로 싣는다', () {
      expect(hasSource(q, 'rotate-secrets_managed'), isTrue);
    });
  });

  group('saa-t1-4-q12 WAF 지원 리소스 목록 통일', () {
    final q = question('saa-t1-4', 'saa-t1-4-q12');

    test('정답은 그대로 CloudFront(인덱스 2)', () {
      expect(q['correct'], 2);
    });

    test('Route 53 오답 근거의 목록이 q4와 같은 9종으로 통일됐다', () {
      final text = wrong(q, '3');
      expect(text.contains('Amplify'), isTrue);
      expect(text.contains('AgentCore'), isTrue);
    });
  });

  group('saa-t2-5-q8 Aurora 복제 구분', () {
    final q = question('saa-t2-5', 'saa-t2-5-q8');

    test('정답은 그대로 Aurora Global Database(인덱스 0)', () {
      expect(q['correct'], 0);
    });

    test('"같은 리전 내 Read Replica도 동기 복제가 아니다" 서술이 사라졌다', () {
      expect(wrong(q, '3').contains('같은 리전 내 Read Replica도 동기 복제가 아'),
          isFalse,
          reason: 'Aurora 복제본은 데이터 볼륨을 공유해 복제 지연이 사실상 없다');
    });

    test('Aurora 복제본의 스토리지 공유와 RDS 복제본의 비동기 복제를 구분한다', () {
      final text = wrong(q, '3');
      expect(text.contains('공유'), isTrue,
          reason: '같은 리전 Aurora 복제본은 클러스터 스토리지를 공유한다');
      expect(text.contains('RDS'), isTrue,
          reason: '비동기 복제는 RDS(비 Aurora) 읽기 전용 복제본 쪽 설명이다');
    });

    test('복제 지연·승격 수치에 "통상" 단서가 붙어 보장값으로 읽히지 않는다', () {
      expect((q['explanation'] as String).contains('통상'), isTrue);
    });

    test('공식 Aurora 복제 지연 문서를 출처로 싣는다', () {
      expect(hasSource(q, 'aurora-faq-availability-and-durability'), isTrue);
    });
  });

  // ── 2차 재검수(2026-10-20): fix 4건 + 출처 보강 3건 ──────────────────────
  //
  // 1차 fix를 머지한 뒤 45문항을 다시 훑어 나온 항목이다. `correct`는 2차에서도
  // 하나도 바뀌지 않았다.
  //
  // - `saa-t1-4-q6` **Count는 비종료 액션**이다. Allow·Block만 평가를 멈추고,
  //   CAPTCHA·Challenge는 유효 토큰이면 Count처럼 다음 규칙으로 넘어간다.
  //   어떤 규칙에도 매칭되지 않으면 웹 ACL 기본 액션이 적용된다.
  //   근거: https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/aws-properties-wafv2-webacl-ruleaction.html
  //   ("Count: Instructs AWS WAF to count the web request and then continue
  //    evaluating the request using the remaining rules in the web ACL")
  // - `saa-t1-4-q5` 평가 기간 유효값은 60·120·300·600초이고 **기본 300초(5분)**.
  //   근거: https://docs.aws.amazon.com/waf/latest/developerguide/waf-rule-statement-type-rate-based-high-level-settings.html
  // - `saa-t1-4-q1` XSS는 Core rule set, **SQL injection은 SQL database 규칙
  //   그룹(AWSManagedRulesSQLiRuleSet)**이 담당한다.
  //   근거: https://docs.aws.amazon.com/waf/latest/developerguide/aws-managed-rule-groups-use-case.html
  // - `saa-t1-4-q10` 관리형 교체는 **마스터 자격증명 전용**이라, 앱이 접속하는
  //   비밀번호를 묻는 stem에는 중립 표현("자동 교체")이 맞다 — 1차 수정이
  //   반대쪽으로 치우쳤던 것을 되돌린다. Parameter Store는 **티어와 관계없이**
  //   자동 교체가 없다(고급 티어 정책은 만료·알림만).
  //   근거: https://docs.aws.amazon.com/systems-manager/latest/userguide/parameter-store-policies.html
  group('saa-t1-4-q6 WAF 규칙 액션 — 종료/비종료', () {
    final q = question('saa-t1-4', 'saa-t1-4-q6');

    test('정답은 그대로 인덱스 2', () => expect(q['correct'], 2));

    test('정답 선택지가 "첫 매칭 액션 즉시 실행"에서 "종료 액션"으로 바뀌었다', () {
      final option = (q['options'] as List)[2] as String;
      expect(option.contains('종료 액션'), isTrue);
      expect(option.contains('Count'), isFalse,
          reason: 'Count는 비종료라 "첫 매칭에 즉시 실행"의 예시가 될 수 없다');
    });

    test('"이후 규칙은 평가하지 않습니다" 단정이 사라졌다', () {
      expect(
        (q['explanation'] as String).contains('이후 규칙은 평가하지 않습니다'),
        isFalse,
      );
    });

    test('해설이 비종료 액션과 웹 ACL 기본 액션을 설명한다', () {
      final text = q['explanation'] as String;
      expect(text.contains('비종료'), isTrue);
      expect(text.contains('기본 액션'), isTrue,
          reason: '어떤 규칙에도 매칭되지 않으면 기본 액션이 적용된다');
    });

    test('공식 규칙 액션 레퍼런스를 출처로 싣는다', () {
      expect(hasSource(q, 'wafv2-webacl-ruleaction'), isTrue);
    });
  });

  group('saa-t1-4-q5 rate-based 평가 기간', () {
    final q = question('saa-t1-4', 'saa-t1-4-q5');

    test('정답은 그대로 인덱스 1', () => expect(q['correct'], 1));

    test('옛 "(5분 또는 1분)" 서술이 사라졌다', () {
      expect((q['explanation'] as String).contains('5분 또는 1분'), isFalse);
    });

    test('해설이 공식 평가 기간 4종과 기본값을 적는다', () {
      final text = q['explanation'] as String;
      for (final v in ['60', '120', '300', '600']) {
        expect(text.contains(v), isTrue, reason: '유효 설정 $v초가 빠졌다');
      }
      expect(text.contains('기본'), isTrue);
    });

    test('공식 rate-based 설정 문서를 출처로 싣는다', () {
      expect(hasSource(q, 'rate-based-high-level-settings'), isTrue);
    });
  });

  group('saa-t1-4-q1 관리형 규칙 그룹의 역할 분리', () {
    final q = question('saa-t1-4', 'saa-t1-4-q1');

    test('정답은 그대로 인덱스 1', () => expect(q['correct'], 1));

    test('해설이 SQLi 담당 규칙 그룹을 명시한다', () {
      expect(
        (q['explanation'] as String).contains('AWSManagedRulesSQLiRuleSet'),
        isTrue,
      );
    });

    test('Core rule set이 SQLi까지 막는 것처럼 읽히지 않는다', () {
      final text = q['explanation'] as String;
      final i = text.indexOf('AWSManagedRulesCommonRuleSet');
      expect(i, greaterThan(-1));
      expect(text.substring(0, i).contains('XSS'), isTrue,
          reason: 'CommonRuleSet 앞에 그것이 XSS 담당임이 드러나야 한다');
    });

    test('공식 use-case 규칙 그룹 문서를 출처로 싣는다', () {
      expect(hasSource(q, 'aws-managed-rule-groups-use-case'), isTrue);
    });
  });

  group('saa-t1-4-q10 선택지 중립화 + Parameter Store 티어', () {
    final q = question('saa-t1-4', 'saa-t1-4-q10');

    test('정답은 그대로 인덱스 1', () => expect(q['correct'], 1));

    test('정답 선택지가 "관리형"이 아니라 중립 표현 "자동 교체"다', () {
      final option = (q['options'] as List)[1] as String;
      expect(option.contains('자동 교체'), isTrue);
      expect(option.contains('관리형 교체'), isFalse,
          reason: '관리형 교체는 마스터 자격증명 전용이라 stem(앱 접속 비밀번호)과 어긋난다');
    });

    test('해설은 관리형 교체와 Lambda 교체 두 경로를 계속 구분한다', () {
      final text = q['explanation'] as String;
      expect(text.contains('관리형 교체'), isTrue);
      expect(text.contains('Lambda'), isTrue);
    });

    test('오답 근거가 Parameter Store를 티어와 무관하게 서술한다', () {
      final w = wrong(q, '0');
      expect(w.contains('티어와 관계없이'), isTrue);
      expect(w.contains('표준 티어는'), isFalse,
          reason: '"표준 티어는"이라고 쓰면 고급 티어에는 교체가 있는 것처럼 읽힌다');
    });

    test('공식 Parameter Store 정책 문서를 출처로 싣는다', () {
      expect(hasSource(q, 'parameter-store-policies'), isTrue);
    });
  });

  group('출처 보강 3건 (정답·해설 변경 없음)', () {
    test('saa-t1-1-q1: IAM 글로벌 엔드포인트 공식 페이지', () {
      expect(
        hasSource(question('saa-t1-1', 'saa-t1-1-q1'), 'UserGuide/programming'),
        isTrue,
      );
    });

    test('saa-t1-4-q11: Parameter Store 정책 페이지', () {
      expect(
        hasSource(
          question('saa-t1-4', 'saa-t1-4-q11'),
          'parameter-store-policies',
        ),
        isTrue,
      );
    });

    test('saa-t2-5-q11: RDS Multi-AZ 동기 복제 공식 페이지', () {
      expect(
        hasSource(
          question('saa-t2-5', 'saa-t2-5-q11'),
          'gettingstartedguide/scaling-ha',
        ),
        isTrue,
      );
    });
  });

  // ── 2차 외부 검수(2026-10-27): 이미 공개된 문항 3건 사실 정정 ───────────────
  //
  // `verified:true`로 **라이브 노출 중이던** SAA 문항에서 사실 오류 3건이 나왔다.
  // 세 건 모두 `correct`(정답)는 바뀌지 않았다 — 해설·오답근거와 q12 지문만 고쳤다.
  //
  // 학습문서는 셋 다 이미 옳게 적고 있어 **문항 단독 오류**였다: `saa-t3-5.md` §3은
  // "일반적으로 최대 15개 … Db2는 3개, Oracle·SQL Server는 5개처럼 엔진별 예외"로,
  // `saa-t3-4.md` §5는 Batch의 EKS와 Fargate를 섞어 단정하지 않는다. 그래서 md 가드는
  // 건드리지 않았고, 따라서 `saa_question_propagation_test.dart` 의 금지 문장 목록도
  // 그대로다(그 목록은 md 가드에서 온 항목만 담는다는 계약이다).
  //
  // 근거(공식 문서 원문):
  // - "AWS Batch on Amazon EKS supports Amazon EC2 instances (On-Demand and Spot)
  //   as compute resources. To use Fargate with AWS Batch, use an Amazon ECS
  //   compute environment instead."
  //   https://docs.aws.amazon.com/batch/latest/userguide/eks.html
  // - "You can create up to 15 read replicas from one DB instance within the same
  //   Region." (MySQL·MariaDB 동일 문구)
  //   https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_MySQL.Replication.ReadReplicas.html
  // - "Each DB instance can have up to 15 read replicas, except for the following
  //   engines: Db2 - Can have up to three replicas. Oracle - Can have up to five
  //   read replicas. SQL Server - Can have up to five read replicas."
  //   https://docs.aws.amazon.com/cli/latest/reference/rds/create-db-instance-read-replica.html
  // - "An Aurora DB cluster can contain up to 15 Aurora Replicas."
  //   https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.Replication.html
  // - "When you promote a read replica, RDS reboots the DB instance before making
  //   it available. The promotion process can take several minutes or longer to
  //   complete" / "You can't use the DB instance as a replication target because
  //   it is no longer a read replica."
  //   https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_ReadRepl.Promote.html

  group('saa-t3-4-q15 AWS Batch on EKS는 EC2 전용', () {
    final q = question('saa-t3-4', 'saa-t3-4-q15');

    test('정답은 그대로 Spot 인스턴스(인덱스 2)', () {
      expect(q['correct'], 2);
    });

    test('"EKS Fargate 컴퓨팅 환경 구성이 가능하다" 단정이 사라졌다', () {
      expect(
        wrong(q, '3').contains('Compute Environment로 구성하는 것은 가능'),
        isFalse,
        reason: 'AWS Batch on EKS는 Fargate를 컴퓨팅 리소스로 지원하지 않는다',
      );
    });

    test('EKS는 EC2만 쓰고 Fargate는 ECS 컴퓨팅 환경이라는 공식 사실이 들어왔다', () {
      final text = wrong(q, '3');
      expect(text.contains('EC2 인스턴스(On-Demand·Spot)'), isTrue);
      expect(text.contains('ECS 컴퓨팅 환경'), isTrue);
    });

    test('공식 EKS 컴퓨팅 환경 문서를 출처로 싣는다', () {
      expect(hasSource(q, 'batch/latest/userguide/eks'), isTrue);
    });
  });

  group('saa-t3-5-q2 읽기 복제본 최대 개수', () {
    final q = question('saa-t3-5', 'saa-t3-5-q2');

    test('정답은 그대로 Read Replica 추가(인덱스 1)', () {
      expect(q['correct'], 1);
    });

    test('"RDS는 최대 5개" 단정이 사라졌다', () {
      expect(
        (q['explanation'] as String).contains('RDS는 최대 5개'),
        isFalse,
        reason: 'MySQL·MariaDB·PostgreSQL은 소스 1개당 15개다 — 5개는 Oracle·SQL Server다',
      );
    });

    test('소스당 15개와 엔진별 예외가 공식 수치로 들어왔다', () {
      final text = q['explanation'] as String;
      expect(text.contains('소스 1개당 최대 15개'), isTrue);
      expect(text.contains('Db2 3개, Oracle·SQL Server 5개는 예외'), isTrue);
    });

    test('공식 MySQL 읽기 복제본 문서를 출처로 싣는다', () {
      expect(hasSource(q, 'USER_MySQL.Replication.ReadReplicas'), isTrue);
    });
  });

  group('saa-t3-5-q12 Aurora vs RDS — 갈림길은 복제본 수가 아니라 페일오버', () {
    final q = question('saa-t3-5', 'saa-t3-5-q12');

    test('정답은 그대로 Aurora(인덱스 2)', () {
      expect(q['correct'], 2);
    });

    test('지문이 페일오버 시간 최소화를 함께 요구한다', () {
      expect(
        (q['stem'] as String).contains('페일오버 시간도 최소화'),
        isTrue,
        reason: '복제본 수가 15개로 같아진 뒤에는 이것만이 보기 B·C를 가른다',
      );
    });

    test('보기 B가 참인데도 반박하던 두 단정이 사라졌다', () {
      final text = wrong(q, '1');
      expect(text.contains('최대 5개 Read Replica'), isFalse);
      expect(
        text.contains('15개는 Aurora의 한계'),
        isFalse,
        reason: '15개는 Aurora 전용 수치가 아니다 — RDS for MySQL도 15개다',
      );
    });

    test('복제본 수는 같고 승격 비용에서 갈린다는 사실이 들어왔다', () {
      final text = wrong(q, '1');
      expect(text.contains('소스 1개당 최대 15개 Read Replica'), isTrue);
      expect(text.contains('복제본 수로는 Aurora와 차이가 없'), isTrue);
      expect(text.contains('수 분 이상 걸릴 수 있'), isTrue);
    });

    test('공식 Aurora 고가용성·복제본 승격 문서를 출처로 싣는다', () {
      expect(hasSource(q, 'Concepts.AuroraHighAvailability'), isTrue);
      expect(hasSource(q, 'USER_ReadRepl.Promote'), isTrue);
    });
  });

  // 같은 일반화가 다른 SAA 문항에 남아 있거나 되살아나지 않도록 전수로 고정한다.
  // 오답 보기(`options`)는 일부러 틀린 서술이므로 제외한다 —
  // `saa_question_propagation_test.dart` 와 같은 이유다.
  group('전파 — "RDS 복제본은 5개" 류 일반화가 SAA 문항 어디에도 없다', () {
    test('모든 SAA 문항의 사실 서술에서 0건', () {
      const banned = <String>['RDS는 최대 5개', 'RDS MySQL은 최대 5개'];
      final files = Directory('assets/content/saa')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.questions.json'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
      final hits = <String>[];
      for (final file in files) {
        final data =
            json.decode(file.readAsStringSync()) as Map<String, dynamic>;
        final questions =
            (data['questions'] as List?)?.whereType<Map<String, dynamic>>() ??
                const <Map<String, dynamic>>[];
        for (final q in questions) {
          final wrongs = q['wrongExplanations'];
          final text = <String>[
            q['stem'] as String? ?? '',
            q['explanation'] as String? ?? '',
            if (wrongs is Map) ...wrongs.values.whereType<String>(),
          ].join('\n');
          for (final phrase in banned) {
            if (text.contains(phrase)) {
              hits.add('${q['id']}: "$phrase"');
            }
          }
        }
      }
      expect(
        hits,
        isEmpty,
        reason: '소스 1개당 상한은 15개다(Db2 3개, Oracle·SQL Server 5개가 예외)',
      );
    });
  });

  // ── 2차 외부 검수 우선순위 1 — 잔여 6문항 독립 재검수 반영 (2026-10-27) ──────
  //
  // 보고가 "정답이 둘이거나 틀림"(t3-4-q1·t4-2-q11·t4-3-q15)과 "정답 모호"
  // (t2-1-q6·t2-1-q15·t4-2-q1)로 분류한 6문항이다. 여섯 건 모두 `verified:true`로
  // **라이브 노출 중**이었고, 공식 문서로 재검수한 결과 **정답 인덱스는 한 건도
  // 바뀌지 않았다** — 결함은 전부 "지문이 갈림길을 말하지 않음" 또는 "보기·근거
  // 본문이 틀림"이었다. 그래서 각 그룹의 첫 단정은 정답 불변을 고정한다.
  //
  // 근거(공식 문서 원문):
  // - "You have the option of running containers on EC2 instances that you manage,
  //   or you can run them on Fargate on AWS managed compute." / "Amazon EKS removes
  //   the need to install, operate, and maintain your own Kubernetes control plane
  //   on AWS." / "Lambda ... performs all of the administration of the compute
  //   resources, including server and operating system maintenance, capacity
  //   provisioning and automatic scaling, and logging."
  //   https://docs.aws.amazon.com/decision-guides/latest/decision-guides/choosing-aws-compute-service.html
  // - "By default, FIFO queues support 300 transactions per second, per API action
  //   for SendMessage, ReceiveMessage, and DeleteMessage." / 배치 API로 "up to 3,000
  //   messages per second per API action"
  //   https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/troubleshooting-fifo-throttling-issues.html
  // - "every queue message is delivered to one of potentially many consumer
  //   processes" / SNS는 "deliver the message to all the SQS queues that are
  //   subscribed to the topic"
  // - "We recommend that you use On-Demand Instances for applications with
  //   short-term, irregular workloads that cannot be interrupted."
  //   https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-on-demand-instances.html
  // - "Spot Instances are a cost-effective choice if you can be flexible about when
  //   your applications run and if your applications can be interrupted."
  // - "Predictive scaling works by analyzing historical load data to detect daily or
  //   weekly patterns" / "Applications that take a long time to initialize"
  //   https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-predictive-scaling.html
  // - "Scaling happens in increments as small as 0.5 ACUs. The larger the current
  //   capacity, the larger the scaling increment" / "most scaling events operations
  //   keep the writer or reader on the same host" / "Scaling doesn't disrupt any
  //   database operations that are underway."
  //   https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2.how-it-works.html

  group('saa-t3-4.md 운영 부담 — 공식에 없는 5종 전순서를 싣지 않는다', () {
    final md =
        File('assets/content/saa/saa-t3-4.md').readAsStringSync();

    test('"ECS EC2 시작 유형 → EKS" 전순서 단정이 사라졌다', () {
      expect(
        md.contains('ECS EC2 시작 유형 → EKS'),
        isFalse,
        reason: 'AWS는 다섯 옵션의 운영 부담 전순서를 공표하지 않는다 — '
            'EKS가 ECS(EC2 시작 유형)보다 부담이 낮다는 근거는 어디에도 없다',
      );
    });

    test('EKS의 관리 범위가 컨트롤 플레인으로 한정되고 "순서 없음"을 명시한다', () {
      expect(md.contains('쿠버네티스 컨트롤 플레인'), isTrue);
      expect(md.contains('공식 운영 부담 순서가 없'), isTrue);
    });
  });

  group('saa-t3-4-q1 운영 부담을 가르는 축', () {
    final q = question('saa-t3-4', 'saa-t3-4-q1');

    test('정답 인덱스는 그대로 0', () {
      expect(q['correct'], 0);
    });

    test('보기에서 5종 전순서 나열이 사라졌다', () {
      final options = (q['options'] as List).cast<String>().join('\n');
      expect(options.contains('EKS → ECS'), isFalse);
      expect(options.contains('Fargate → EKS'), isFalse);
    });

    test('공식 축(노드를 누가 관리)과 컨트롤 플레인 한정이 들어왔다', () {
      expect(
        (q['options'] as List).cast<String>()[0].contains('노드(EC2 인스턴스)를 누가 관리'),
        isTrue,
      );
      expect(wrong(q, '2').contains('컨트롤 플레인'), isTrue);
    });

    test('공식 컴퓨팅 선택 결정 가이드를 출처로 싣는다', () {
      expect(hasSource(q, 'choosing-aws-compute-service'), isTrue);
    });
  });

  group('saa-t2-1-q6 SQS 단독으로 1:N이 불가한 이유', () {
    final q = question('saa-t2-1', 'saa-t2-1-q6');

    test('정답 인덱스는 그대로 1', () {
      expect(q['correct'], 1);
    });

    test('참인데 오답으로 놓였던 보기가 사라졌다', () {
      final all = [
        ...(q['options'] as List).cast<String>(),
        ...(q['wrongExplanations'] as Map<String, dynamic>).values
            .cast<String>(),
      ].join('\n');
      expect(
        all.contains('이메일·SMS 전송 기능이 없'),
        isFalse,
        reason: 'SQS가 이메일·SMS를 보내지 않는 것은 참이라 오답 보기로 쓸 수 없다',
      );
      expect(
        all.contains('직접 지원하지 않는 것은 사실'),
        isFalse,
        reason: '오답 근거가 그 보기도 타당한 이유라고 시인하면 정답이 둘이 된다',
      );
    });

    test('보기 3이 가시성 타임아웃 오해를 반박하는 형태로 바뀌었다', () {
      expect(wrong(q, '3').contains('가시성 타임아웃'), isTrue);
      expect(wrong(q, '3').contains('하나의 소비자'), isTrue);
    });
  });

  group('saa-t2-1-q15 FIFO 기본 처리량', () {
    final q = question('saa-t2-1', 'saa-t2-1-q15');

    test('정답 인덱스는 그대로 1', () {
      expect(q['correct'], 1);
    });

    test('지문이 배치 API 제외를 명시한다', () {
      expect(
        (q['stem'] as String).contains('배치 API 없이'),
        isTrue,
        reason: '300 TPS는 API 요청 기준이라 배치를 쓰면 초당 500건이 가능하다 — '
            '지문이 이 전제를 말해야 보기 1의 "불가"가 성립한다',
      );
    });

    test('"파티션당 300 TPS" 오류가 문항 전체에서 사라졌다', () {
      // 보기 1만 보던 단정으로는 놓친다 — 같은 오류가 `wrongExplanations["3"]`
      // 에도 있었다(2026-10-27 실측). 문항 전체를 본다.
      final all = [
        ...(q['options'] as List).cast<String>(),
        q['explanation'] as String,
        ...(q['wrongExplanations'] as Map<String, dynamic>).values
            .cast<String>(),
      ].join('\n');
      expect(
        all.contains('파티션당 300 TPS'),
        isFalse,
        reason: '기본 300 TPS는 파티션당이 아니라 각 API 작업당이다',
      );
    });

    test('각 API 작업당 300 TPS와 배치 3,000 메시지/초가 공식 수치로 들어왔다', () {
      expect(
        (q['options'] as List).cast<String>()[1].contains('각 API 작업당 300 TPS'),
        isTrue,
      );
      expect((q['explanation'] as String).contains('3,000 메시지/초'), isTrue);
    });
  });

  group('saa-t4-2-q1 단기·불규칙 워크로드 구매 옵션', () {
    final q = question('saa-t4-2', 'saa-t4-2-q1');

    test('정답 인덱스는 그대로 1', () {
      expect(q['correct'], 1);
    });

    test('지문이 "중단되면 안 되는"을 명시한다', () {
      expect(
        (q['stem'] as String).contains('중단되면 안 되는'),
        isTrue,
        reason: '이 조건이 없으면 개발·테스트는 Spot의 교과서적 용례라 정답이 둘이 된다',
      );
    });

    test('오답 근거가 Spot의 공식 기준(시점 유연·중단 허용)을 적는다', () {
      expect(wrong(q, '2').contains('중단을 견딜 수 있을 때'), isTrue);
    });
  });

  group('saa-t4-2-q11 예측 가능한 패턴의 오토스케일링', () {
    final q = question('saa-t4-2', 'saa-t4-2-q11');

    test('정답 인덱스는 그대로 2(Scheduled Scaling)', () {
      expect(q['correct'], 2);
    });

    test('지문이 시각 고정을 명시해 Predictive와 갈린다', () {
      expect(
        (q['stem'] as String).contains('09:00·18:00으로 고정'),
        isTrue,
        reason: '공식 Predictive 문서가 "business hours / evenings and weekends"를 '
            '자기 용례로 적으므로, 시각 고정이 없으면 보기 3도 성립한다',
      );
    });

    test('오답 근거가 Predictive의 공식 성격을 적는다', () {
      expect(wrong(q, '3').contains('과거 부하 데이터를 분석'), isTrue);
    });
  });

  group('saa-t4-3-q15 Aurora serverless 스케일 단위', () {
    final q = question('saa-t4-3', 'saa-t4-3-q15');

    test('정답 인덱스는 그대로 0', () {
      expect(q['correct'], 0);
    });

    test('보기 0과 중복이던 보기 3이 거짓 서술로 바뀌었다', () {
      final options = (q['options'] as List).cast<String>();
      expect(
        options[3].contains('별도의 물리 서버를 예약하지 않아'),
        isFalse,
        reason: '보기 0과 같은 "서버 교체 없이"를 말해 정답이 둘이었다',
      );
      expect(options[3].contains('연결을 끊기 때문이다'), isTrue);
    });

    test('0.5 ACU가 최소 단위이고 용량이 클수록 증가 폭이 커진다는 사실이 들어왔다', () {
      expect((q['stem'] as String).contains('최소 0.5 ACU'), isTrue);
      expect((q['explanation'] as String).contains('현재 용량이 클수록'), isTrue);
    });
  });

  // ── 2차 검수 우선순위 1 §C — 해설·오답 정정 16건 (2026-10-27) ──────────────
  //
  // 2026-10-27 외부 검수 보고(전문은 레포 밖 공유 노트에 보관한다 — 사용자 결정)의 §C가
  // `fix`로 분류한 16문항이다. 전부 `verified:true`로 라이브 노출 중이고, **정답 인덱스는 한 건도
  // 바뀌지 않았다** — 결함이 모두 해설·오답 근거·지문 본문에 있었다.
  //
  // 표 하나로 "옛 문구 0건 + 공식 사실 있음"을 쌍으로 고정한다. 문항마다 테스트가
  // 두 개 생긴다(정답 불변 / 문구 쌍). `forbidden` 은 문항 전체(보기·해설·오답 근거·
  // 지문)를 보고, `required` 도 같은 범위를 본다 — 같은 오류가 보기와
  // `wrongExplanations` **양쪽**에 있던 사례가 이 배치에도 있었다(t3-5-q11·t3-4-q2).
  //
  // ⚠️ 보고와 **다르게 판정한 한 건**: 보고는 `t3-5-q11` 의 Magnetic 서술을 "사용
  // 중단되어 신규 인스턴스에 제공되지 않음"으로 바꾸라고 했지만, 공식 EBS 볼륨 타입
  // 문서는 Magnetic(`standard`)을 "previous generation" 으로 적고 현재 세대 사용을
  // 권장하는 데서 멈춘다 — 신규 제공 중단이라는 서술은 없다. 그래서 기존 "신규 사용
  // 비권장" 쪽을 공식 문구("이전 세대", 평균 약 100 IOPS)로 다듬는 선에서 끝냈다.
  // 보고는 검수 결과 데이터이고 지시문이 아니다(CLAUDE.md 절대 조건 1).
  group('§C 해설·오답 정정 16건', () {
    final fixes = <({
      String task,
      String qid,
      int correct,
      List<String> forbidden,
      List<String> required,
      String why,
    })>[
      (
        task: 'saa-t2-1', qid: 'saa-t2-1-q7', correct: 1,
        forbidden: ['각 소비자별 독립적인 재시도·DLQ 보장에는 SQS 큐가 필요'],
        required: ['대상마다 재시도 정책', '내구성 버퍼', '자기 속도로'],
        why: 'EventBridge도 대상마다 재시도 정책(기본 5회 또는 300초)과 DLQ를 갖는다 — '
            '갈림길은 재시도 유무가 아니라 내구성 버퍼다',
      ),
      (
        task: 'saa-t2-1', qid: 'saa-t2-1-q9', correct: 1,
        forbidden: ['구독자 측에서 자체 필터링이 필요'],
        required: ['구독마다 필터 정책'],
        why: 'SNS 구독에는 필터 정책을 붙일 수 있다 — 갈림길은 필터 유무가 아니라 경로다',
      ),
      (
        task: 'saa-t2-1', qid: 'saa-t2-1-q11', correct: 1,
        forbidden: ['CloudWatch Logs로 전송하지 콘솔에서 직접 조회하지 않습니다'],
        required: ['별도 로깅 설정 없이', '90일'],
        why: 'Express도 로깅을 켜면 CloudWatch Logs와 Step Functions 콘솔에서 볼 수 있다. '
            '갈림길은 Standard가 설정 없이 90일까지 이력을 남긴다는 점이다',
      ),
      (
        task: 'saa-t3-2', qid: 'saa-t3-2-q7', correct: 1,
        forbidden: ['다른 AZ·리전으로 복사할 수 있습니다'],
        required: ['리전 내 모든 가용 영역에 자동 복제'],
        why: '스냅샷은 AZ 리소스가 아니라 리전 리소스다 — 데이터가 리전 내 전 AZ에 '
            '자동 복제되어 어느 AZ에서든 복원하고, 다른 리전으로는 복사한다',
      ),
      (
        task: 'saa-t3-2', qid: 'saa-t3-2-q14', correct: 1,
        forbidden: ['AZ 간·리전 간 복사가 모두 가능'],
        required: ['리전 리소스'],
        why: '(q7과 같은 결함)',
      ),
      (
        task: 'saa-t3-2', qid: 'saa-t3-2-q15', correct: 1,
        forbidden: ['Standard-IA'],
        required: ['Infrequent Access(IA)', '파일 시스템 유형'],
        why: '현행 EFS 스토리지 클래스는 EFS Standard·EFS Infrequent Access(IA)·'
            'EFS Archive다. One Zone은 스토리지 클래스가 아니라 파일 시스템 유형이다',
      ),
      (
        task: 'saa-t3-4', qid: 'saa-t3-4-q2', correct: 1,
        forbidden: ['문서에 없습니다'],
        required: ['900초', '5,400초(90분)'],
        why: '표준 Lambda 타임아웃 상한은 900초이고, Lambda Managed Instances의 비동기·'
            '이벤트 소스 매핑 호출은 5,400초(90분)다. "문서에 없습니다"는 작성자 메모(M2)',
      ),
      (
        task: 'saa-t3-4', qid: 'saa-t3-4-q7', correct: 3,
        forbidden: ['Job Definition, Task, Service는 ECS의 리소스'],
        required: ['Job Definition도 AWS Batch의 리소스'],
        why: 'Job Definition은 AWS Batch의 리소스다 — ECS 것은 Task와 Service뿐이다',
      ),
      (
        task: 'saa-t3-5', qid: 'saa-t3-5-q5', correct: 1,
        forbidden: ['공식 문서 기준 256TiB'],
        required: ['엔진 버전에 따라 최대 256 TiB'],
        why: '"최대 128TiB, 공식 문서 기준 256TiB"처럼 두 수치를 함께 적던 서술을 '
            '공식 문구(엔진 버전에 따라 최대 256 TiB)로 통일했다',
      ),
      (
        task: 'saa-t3-5', qid: 'saa-t3-5-q6', correct: 3,
        forbidden: ['일반 RDS Multi-AZ'],
        required: ['Multi-AZ DB 인스턴스 배포', 'Multi-AZ DB 클러스터 배포'],
        why: 'Multi-AZ는 배포 유형이 둘이다 — DB 클러스터 배포는 읽기 가능한 리더를 '
            '두고 페일오버 시간도 복제 지연에 좌우되므로 배포 유형을 한정해야 한다',
      ),
      (
        task: 'saa-t3-5', qid: 'saa-t3-5-q11', correct: 3,
        forbidden: ['범용 SSD(gp2/gp3)'],
        required: ['gp3는 버스트를 쓰지 않아'],
        why: '공식 문서: "gp3 volumes do not use burst performance." 버스트 크레딧은 gp2다',
      ),
      (
        task: 'saa-t4-2', qid: 'saa-t4-2-q12', correct: 1,
        forbidden: ['권장 사항만 제안하며 실제 변경은 사용자가 직접'],
        required: ['자동화 규칙', 'EBS 볼륨에 한해'],
        why: '2025-11 자동화 규칙으로 EBS 볼륨에 한해 권장 사항이 자동 적용된다 — '
            '인스턴스 크기는 여전히 자동 변경되지 않는다',
      ),
      (
        task: 'saa-t4-3', qid: 'saa-t4-3-q1', correct: 1,
        forbidden: ['유휴 시 최솟값 ACU만 과금되므로'],
        required: ['0 ACU', '자동 일시정지'],
        why: '최근 Aurora MySQL·PostgreSQL 버전은 0 ACU까지 축소돼 컴퓨팅 요금이 0이 된다',
      ),
      (
        task: 'saa-t4-3', qid: 'saa-t4-3-q6', correct: 0,
        forbidden: ['최대 128TB까지 지원'],
        required: ['최대 256 TiB까지 지원'],
        why: 'Aurora 클러스터 볼륨은 엔진 버전에 따라 최대 256 TiB다',
      ),
      (
        task: 'saa-t4-3', qid: 'saa-t4-3-q7', correct: 2,
        forbidden: ['RDS Multi-AZ Standby는 HA를 위한 대기 복제본'],
        required: ['Multi-AZ DB 클러스터 배포는 읽기 가능한 리더'],
        why: '(q6·t3-5-q6과 같은 계열) 배포 유형을 한정하지 않으면 거짓이 된다',
      ),
      (
        task: 'saa-t4-3', qid: 'saa-t4-3-q9', correct: 0,
        forbidden: ['트래픽이 불규칙하고 야간·주말에 거의 없는 패턴'],
        required: ['피크 시각과 규모'],
        why: '지문은 규칙적 패턴으로 읽히는데 해설만 "불규칙"이라 모순이었다 — '
            '지문에 예측이 어렵다는 조건을 넣어 온디맨드가 답이 되게 했다',
      ),
    ];

    String allText(Map<String, dynamic> q) => <String>[
          q['stem'] as String? ?? '',
          q['explanation'] as String? ?? '',
          ...(q['options'] as List).cast<String>(),
          ...(q['wrongExplanations'] as Map<String, dynamic>).values
              .cast<String>(),
        ].join('\n');

    for (final f in fixes) {
      test('${f.qid}: 정답 인덱스는 그대로 ${f.correct}', () {
        expect(question(f.task, f.qid)['correct'], f.correct);
      });

      test('${f.qid}: 옛 문구가 사라지고 공식 사실이 들어왔다', () {
        final text = allText(question(f.task, f.qid));
        for (final bad in f.forbidden) {
          expect(text.contains(bad), isFalse,
              reason: '${f.qid} 에 옛 문구가 남아 있다: "$bad"\n공식: ${f.why}');
        }
        for (final good in f.required) {
          expect(text.contains(good), isTrue,
              reason: '${f.qid} 에 공식 사실이 없다: "$good"\n공식: ${f.why}');
        }
      });
    }
  });

  // ── 2차 검수 우선순위 1 §D — 공개 Task 출처 교체 (2026-10-28) ───────────────
  //
  // 2026-10-27 외부 검수 보고(전문은 레포 밖 공유 노트에 보관한다 — 사용자 결정)의 §D가
  // `resource`로 분류한 공개 Task 14문항 + 깨진 링크를 쓰던 `t4-3-q6`·`q7`(§C 소속이라
  // §D 표에는 없었다)까지 **16문항**이다. 사실은 맞는데 **인용한 페이지가 그 사실을 담고 있지
  // 않던** 경우이고, 대부분 서비스 "소개(welcome·what-is)" 페이지였다.
  //
  // ⚠️ `rds-reserved-instances.html` 은 **깨진 링크다** — 실측하면
  // `UserGuide/Welcome.html` 로 리다이렉트된다(2026-10-28 확인). t4-3의 6문항
  // (q5·q6·q7·q11·q12·q14)이 이것을 쓰고 있었다. 아래 집계 단정이 0건으로 고정한다.
  //
  // ⚠️ **보고 제안보다 정확한 페이지를 쓴 3건**이 있다:
  // - `t4-3-q5` 는 보고가 RDS 예약 인스턴스 페이지를 제안했지만, 이 문항의 사실은
  //   "Compute SP는 EC2·Fargate·Lambda에 적용되고 RDS에는 아니다 + Database Savings
  //   Plans가 따로 있다"다. 그 둘을 한 페이지에 적는 **Savings Plans types**를 썼다.
  // - `t4-3-q11`·`q12` 는 보고가 요금 페이지와 "RDS 스냅샷 삭제 문서(URL 미특정)"를
  //   가리켰는데, **Introduction to backups**가 "Manual snapshots are not deleted when
  //   an instance is deleted" 와 "free amount of backup storage equal to 100 percent of
  //   the total provisioned database storage" 를 모두 담고 있어 그 한 페이지로 닫았다.
  // 보고가 "교체 후보 미확인"으로 남긴 `t4-2-q13`(Lambda 요금)과 "URL 미특정"으로 남긴
  // `t4-3-q12`도 이렇게 해결했다.
  //
  // ⚠️ **교체 페이지에 없는 수치는 지웠다**(보고 §E "확인 필요"가 가리킨 2건):
  // - `t3-5-q7` 의 "RPO 약 1초·RTO 약 1분 충족" — 공식 Aurora Global Database 문서는
  //   "latency typically under a second"만 적고 RPO·RTO를 수치로 제시하지 않는다
  //   (`rds.global_db_rpo` 는 20초~68년 범위의 **설정값**이다). 복제 지연만 남겼다.
  // - `t4-3-q14` 의 "RDS 인스턴스의 CPU·메모리 사용률을 분석" — what-is 페이지는
  //   "configuration and utilization metrics"와 지원 리소스에 RDS·Aurora가 든다는 것까지
  //   적고, RDS의 메모리 분석을 따로 명시하지 않는다. 공식 문구로 바꿨다.
  group('§D 공개 Task 출처 교체 16건', () {
    final swaps = <({String task, String qid, String add, String drop, String why})>[
      (
        task: 'saa-t2-1', qid: 'saa-t2-1-q5',
        add: 'sqs-short-and-long-polling', drop: 'SQSDeveloperGuide/welcome',
        why: '"The maximum long polling wait time is 20 seconds" 와 short polling이 '
            '기본값이라는 서술이 이 페이지에 있다',
      ),
      (
        task: 'saa-t3-2', qid: 'saa-t3-2-q1',
        add: 'efs/latest/ug/whatisefs', drop: 'what-is-ebs',
        why: '정답이 파일 스토리지인데 블록 스토리지 소개 페이지를 인용하고 있었다. '
            'EFS는 NFS 프로토콜과 "massively parallel access from compute instances"를 적는다',
      ),
      (
        task: 'saa-t3-2', qid: 'saa-t3-2-q5',
        add: 'ebs-volumes-multi', drop: 'what-is-ebs',
        why: '"Multi-Attach enables you to attach a single Provisioned IOPS SSD (io1 or '
            'io2) volume to multiple instances that are in the same Availability Zone" + '
            'Nitro 16대 + "Your applications must provide write ordering"',
      ),
      (
        task: 'saa-t3-2', qid: 'saa-t3-2-q6',
        add: 'instance-store-lifetime', drop: 'what-is-ebs',
        why: '"The data on an instance store volume persists even if the instance is '
            'rebooted. However, the data does not persist if the instance is stopped, '
            'hibernated, or terminated."',
      ),
      (
        task: 'saa-t3-2', qid: 'saa-t3-2-q13',
        add: 'what-is-fsx-ontap', drop: 'WindowsGuide/what-is',
        why: '"Multi-protocol access to data using the Network File System (NFS), Server '
            'Message Block (SMB), Internet Small Computer Systems Interface (iSCSI)" + '
            'Linux·Windows·macOS + "without the need to change your application code"',
      ),
      (
        task: 'saa-t3-5', qid: 'saa-t3-5-q7',
        add: 'aurora-global-database', drop: 'CHAP_AuroraOverview',
        why: '"Aurora replicates data to the secondary AWS Regions using dedicated '
            'infrastructure, with latency typically under a second" + 최대 10개 보조 리전',
      ),
      (
        task: 'saa-t3-5', qid: 'saa-t3-5-q8',
        add: 'aurora-serverless-v2.html', drop: 'CHAP_AuroraOverview',
        why: '"on-demand, autoscaling configuration" + "You\'re charged only for the '
            'resources that your DB clusters consume" + 변동·예측 불가 워크로드 용례',
      ),
      (
        task: 'saa-t3-5', qid: 'saa-t3-5-q14',
        add: 'USER_PIT', drop: 'UserGuide/Welcome',
        why: '"You can restore to any point in time within your backup retention period." '
            '보존 기간 0~35일은 ModifyDBInstance의 "Must be a value from 0 to 35"다',
      ),
      (
        task: 'saa-t4-2', qid: 'saa-t4-2-q13',
        add: 'lambda/pricing', drop: 'what-is-savings-plans',
        why: '"charges you only for what you use" + "priced per request and execution '
            'duration" + "price per 1 ms". 보고가 "교체 후보 미확인"으로 남긴 건이다',
      ),
      (
        task: 'saa-t4-3', qid: 'saa-t4-3-q5',
        add: 'savingsplans/latest/userguide/plan-types', drop: 'rds-reserved-instances',
        why: '"Compute Savings Plans ... also apply to your Fargate and Lambda usage" + '
            '"Database Savings Plans ... on Aurora, RDS, DynamoDB, ElastiCache, ..."',
      ),
      (
        task: 'saa-t4-3', qid: 'saa-t4-3-q6',
        add: 'USER_PIOPS.StorageTypes', drop: 'rds-reserved-instances',
        why: '"Later, you can increase the amount or change the type of storage" + 목차에 '
            '"Managing capacity automatically with Amazon RDS storage autoscaling"',
      ),
      (
        task: 'saa-t4-3', qid: 'saa-t4-3-q7',
        add: 'ElastiCache/latest/dg/Strategies', drop: 'rds-reserved-instances',
        why: '"ElastiCache is an in-memory key-value store that sits between your '
            'application and the data store (database)" — 캐시 적중 시 DB 쿼리가 없다',
      ),
      (
        task: 'saa-t4-3', qid: 'saa-t4-3-q11',
        add: 'USER_WorkingWithAutomatedBackups', drop: 'rds-reserved-instances',
        why: '"RDS saves the automated backups ... according to the backup retention '
            'period" + "free amount of backup storage equal to 100 percent of the total '
            'provisioned database storage in your AWS account for each Region"',
      ),
      (
        task: 'saa-t4-3', qid: 'saa-t4-3-q12',
        add: 'USER_WorkingWithAutomatedBackups', drop: 'rds-reserved-instances',
        why: '"Manual snapshots are not deleted when an instance is deleted. You can have '
            'up to 100 manual snapshots per Region."',
      ),
      (
        task: 'saa-t4-3', qid: 'saa-t4-3-q13',
        add: 'AmazonTimestreamForLiveAnalytics-availability-change',
        drop: 'aws-overview/database',
        why: '"close new customer access to Amazon Timestream for LiveAnalytics, effective '
            '6/20/25" + "evaluate Amazon Timestream for InfluxDB as an alternative"',
      ),
      (
        task: 'saa-t4-3', qid: 'saa-t4-3-q14',
        add: 'what-is-compute-optimizer', drop: 'rds-reserved-instances',
        why: '지원 리소스에 "Amazon Aurora and Amazon Relational Database Service (Amazon '
            'RDS) databases" 가 들어 있고 "rightsizing recommendations"를 제시한다',
      ),
    ];

    for (final s in swaps) {
      test('${s.qid}: 사실을 담은 페이지로 출처가 교체됐다', () {
        final q = question(s.task, s.qid);
        expect(hasSource(q, s.add), isTrue,
            reason: '${s.qid} 에 새 출처가 없다: "${s.add}"\n근거: ${s.why}');
        expect(hasSource(q, s.drop), isFalse,
            reason: '${s.qid} 에 옛 출처가 남아 있다: "${s.drop}"');
      });
    }

    test('SAA 문항 전수에서 깨진 링크 rds-reserved-instances 가 0건', () {
      final files = Directory('assets/content/saa')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.questions.json'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
      final hits = <String>[];
      for (final file in files) {
        final data =
            json.decode(file.readAsStringSync()) as Map<String, dynamic>;
        final questions =
            (data['questions'] as List?)?.whereType<Map<String, dynamic>>() ??
                const <Map<String, dynamic>>[];
        for (final q in questions) {
          final urls = (q['sources'] as List?)
                  ?.whereType<Map<String, dynamic>>()
                  .map((s) => s['url'] as String? ?? '') ??
              const <String>[];
          if (urls.any((u) => u.contains('rds-reserved-instances'))) {
            hits.add(q['id'] as String? ?? '(id 없음)');
          }
        }
      }
      expect(hits, isEmpty,
          reason: 'rds-reserved-instances.html 은 UserGuide/Welcome.html 로 '
              '리다이렉트되는 깨진 링크다(2026-10-28 실측)');
    });

    test('saa-t3-5-q7: 공식 문서에 없는 RPO·RTO 수치 단정이 사라졌다', () {
      final text = question('saa-t3-5', 'saa-t3-5-q7')['explanation'] as String;
      expect(
        text.contains('RPO 약 1초·RTO 약 1분의 재해 복구 목표를 충족'),
        isFalse,
        reason: '공식 Aurora Global Database 문서는 RPO·RTO를 수치로 제시하지 않는다',
      );
      expect(text.contains('통상 1초 미만'), isTrue,
          reason: '문서가 적는 것은 복제 지연("latency typically under a second")이다');
    });

    test('saa-t4-3-q14: Compute Optimizer 서술이 공식 문구로 바뀌었다', () {
      final text = question('saa-t4-3', 'saa-t4-3-q14')['explanation'] as String;
      expect(
        text.contains('RDS 인스턴스의 CPU·메모리 사용률을 분석해'),
        isFalse,
        reason: 'what-is 페이지는 RDS의 메모리 분석을 따로 명시하지 않는다',
      );
      expect(text.contains('구성과 사용률 지표'), isTrue);
      expect(text.contains('유휴 리소스'), isTrue);
    });
  });

  // ── 2차 검수 우선순위 2 — 게이트 최단 경로 t2-5 (2026-10-28) ────────────────
  //
  // 우선순위 2는 "D1·D2 초안"인데, #258의 t1-1·t1-2 flip으로 **D1은 이미 충족됐다**
  // (30 ≥ 19). 남은 것은 D2 하나뿐이다 — t2-1(15)만 verified라 17에 2문항 모자라고,
  // D2 Task를 **하나만 더** flip하면 게이트가 열린다.
  //
  // 보고 판정으로 가장 싼 D2 Task가 t2-5(DR)다: pass 13 · fix 1(q12) · resource 1(q15).
  // 그래서 이 두 건을 먼저 닫는다. ⚠️ **flip 자체는 사람만** 한다 — 이 가드는 "문항이
  // 고쳐졌다"만 보고, verified 수량·게이트 상태 같은 상태 숫자는 보지 않는다.
  //
  // 근거(DR 백서 "Disaster recovery options in the cloud" §AWS Elastic Disaster Recovery):
  // - "DRS continuously replicates **server-hosted applications and server-hosted
  //   databases** from any source into AWS using **block-level replication of the
  //   underlying server**."
  // - "It can also be used for disaster recovery of AWS hosted workloads if they consist
  //   only of applications and databases hosted on EC2 (**that is, not RDS**)."
  // - "uses the Pilot Light strategy, maintaining a copy of data and **'switched-off'
  //   resources** in an Amazon VPC used as a **staging area**. When a failover event is
  //   triggered, the staged resources are used to automatically create a **full-capacity
  //   deployment**."
  // 그리고 DRS what-is: "The staging area design reduces costs by using **affordable
  // storage and minimal compute resources**" / "converts your servers to boot and run
  // natively on AWS".
  group('§우선순위2 게이트 경로 — saa-t2-5 (DR)', () {
    test('saa-t2-5-q12: 정답 인덱스는 그대로 2(Pilot Light)', () {
      expect(question('saa-t2-5', 'saa-t2-5-q12')['correct'], 2);
    });

    test('saa-t2-5-q12: "DB 데이터만 복제" 단정이 사라지고 서버 블록 레벨 복제가 들어왔다', () {
      final text = question('saa-t2-5', 'saa-t2-5-q12')['explanation'] as String;
      expect(
        text.contains('DB 데이터만 상시 복제'),
        isFalse,
        reason: 'DRS는 DB 데이터가 아니라 원본 **서버**를 블록 레벨로 복제한다',
      );
      expect(text.contains('블록 레벨'), isTrue);
      expect(text.contains('꺼진'), isTrue,
          reason: '스테이징 영역이 유지하는 것은 데이터 사본과 "switched-off" 리소스다');
    });

    test('saa-t2-5-q12: DR 백서를 출처로 싣는다', () {
      expect(
        hasSource(question('saa-t2-5', 'saa-t2-5-q12'),
            'disaster-recovery-options-in-the-cloud'),
        isTrue,
      );
    });

    test('saa-t2-5-q15: 정답 인덱스는 그대로 1(서버 기반만, RDS 불가)', () {
      expect(question('saa-t2-5', 'saa-t2-5-q15')['correct'], 1);
    });

    test('saa-t2-5-q15: "not RDS"를 적는 DR 백서를 출처로 싣는다', () {
      expect(
        hasSource(question('saa-t2-5', 'saa-t2-5-q15'),
            'disaster-recovery-options-in-the-cloud'),
        isTrue,
        reason: 'what-is-drs 페이지에는 RDS 제외가 없고, DR 백서가 "(that is, not RDS)"를 적는다',
      );
    });
  });

  // ── 우선순위 2 A조 — 2024~2026 변경 미반영 8건 (2026-10-28) ────────────────
  //
  // 전부 **드래프트 Task**(verified:false)라 라이브 노출은 없다. 결함이 세 변경으로
  // 묶이고, 변경 단위로 한 번에 고치는 것이 보고의 권고다.
  //
  // ① **Regional NAT Gateway**(2025-11) — `vpc/nat-gateways-regional.html`
  //    "A regional NAT gateway **automatically expands across Availability Zones** based on
  //    your workload presence. Unlike standard NAT gateways (**referred to as zonal NAT
  //    gateways**), which operate in a single Availability Zone…"
  //    "**Enhanced security – No public subnets required.**"
  //    "Regional NAT Gateways **do not offer private connectivity**"(프라이빗 NAT는 zonal)
  //    → "NAT GW는 퍼블릭 서브넷에 둔다"·"AZ마다 둬야 한다"·"내부적으로 다중 AZ를 지원하지
  //      않는다"가 **영역형에만** 맞는 말이 됐다. 지문을 zonal로 좁히고 regional을 병기한다.
  //
  // ② **ASG가 교체 주체다** — `autoscaling/ec2-auto-scaling-health-checks.html`
  //    "It can receive notifications from various sources when an instance becomes unhealthy
  //    and **must be replaced**. These sources include … **Elastic Load Balancing** …"
  //    "When Amazon EC2 Auto Scaling determines that an InService instance is unhealthy,
  //    **it replaces it** with a new instance"
  //    ⚠️ `t2-4-q13` 은 **정답 보기 본문이 틀렸다** — "ALB 헬스 체크가 개별 인스턴스 교체를
  //      담당"은 거짓이고, ALB는 라우팅에서 빼기만 한다. 정답 인덱스(1)는 그대로 둔다.
  //    그리고 NLB도 HTTP 헬스 체크를 한다 — `network/target-group-health-checks.html`
  //    "You can use **any available health check (TCP, HTTP, or HTTPS)**, and any port"
  //
  // ③ **Multi-AZ 는 배포 유형이 둘이다** — `AmazonRDS/multi-az-db-clusters-concepts.html`
  //    "**Reader DB instances act as automatic failover targets and also serve read
  //    traffic**" / "Multi-AZ DB cluster deployments use **semisynchronous** replication"
  //    → "RDS Multi-AZ"라고만 쓰면 DB 클러스터 배포에서 거짓이 된다. 배포 유형을 한정한다.
  //    (§C의 `t3-5-q6`·`t4-3-q7` 과 같은 계열이고, 이 보고에서 가장 자주 걸리는 항목이다.)
  group('§우선순위2 A조 — 변경 미반영 8건', () {
    final fixes = <({
      String task,
      String qid,
      int correct,
      List<String> forbidden,
      List<String> required,
      String why,
    })>[
      (
        task: 'saa-t1-3', qid: 'saa-t1-3-q7', correct: 1,
        forbidden: <String>[],
        required: ['영역형(zonal)', '리전 NAT 게이트웨이'],
        why: '퍼블릭 서브넷 요구는 영역형에만 해당한다 — 리전 NAT GW는 "No public subnets '
            'required"이고 워크로드가 있는 AZ로 자동 확장한다',
      ),
      (
        task: 'saa-t2-4', qid: 'saa-t2-4-q2', correct: 2,
        forbidden: ['AZ마다 NAT 게이트웨이를 배치해야 합니다'],
        required: ['리전 NAT 게이트웨이'],
        why: '영역형은 AZ마다 둬야 하지만, 리전 NAT GW는 하나로 전 AZ를 덮는다',
      ),
      (
        task: 'saa-t2-4', qid: 'saa-t2-4-q4', correct: 1,
        forbidden: ['RDS Multi-AZ는 엔진에 관계없이 동기 복제'],
        required: ['Multi-AZ DB 인스턴스 배포', 'Multi-AZ DB 클러스터'],
        why: 'DB 인스턴스 배포는 동기 복제지만 DB 클러스터 배포는 반동기(semisynchronous)다',
      ),
      (
        task: 'saa-t2-4', qid: 'saa-t2-4-q6', correct: 1,
        forbidden: ['RDS Multi-AZ의 Standby는 읽기 불가로'],
        required: ['Multi-AZ DB 인스턴스 배포', 'Multi-AZ DB 클러스터'],
        why: 'DB 클러스터 배포의 리더는 읽기를 처리한다 — 배포 유형을 한정하지 않으면 거짓이다',
      ),
      (
        task: 'saa-t2-4', qid: 'saa-t2-4-q11', correct: 1,
        forbidden: ['NAT 게이트웨이는 ALB처럼 내부적으로 다중 AZ를 지원하지 않습니다'],
        required: ['영역형(zonal)', '리전 NAT 게이트웨이'],
        why: '리전 NAT GW는 실제로 전 AZ로 자동 확장하므로, 지문을 영역형으로 좁혀야 '
            '보기 0이 거짓으로 남는다',
      ),
      (
        task: 'saa-t2-4', qid: 'saa-t2-4-q13', correct: 1,
        forbidden: ['개별 인스턴스 교체를 담당'],
        required: ['라우팅에서 제외', 'ASG'],
        why: 'ALB는 비정상 대상을 라우팅에서 빼고, 교체는 ELB 헬스 체크를 신호로 쓰는 ASG가 '
            '한다 — 정답 보기 본문이 틀렸던 건이다',
      ),
      (
        task: 'saa-t2-2', qid: 'saa-t2-2-q6', correct: 2,
        forbidden: ['스탠바이 인스턴스는 읽기 트래픽을 분산하지 않습니다'],
        required: ['Multi-AZ DB 클러스터'],
        why: '배포 유형을 한정하지 않은 단정이다 — 커넥션 풀링 부재가 이 보기의 핵심 근거다',
      ),
      (
        task: 'saa-t2-3', qid: 'saa-t2-3-q12', correct: 3,
        forbidden: ['L7 응답 코드를 감지하지 않습니다'],
        required: ['TCP·HTTP·HTTPS'],
        why: 'NLB도 TCP·HTTP·HTTPS 헬스 체크를 쓸 수 있다 — 갈림길은 감지 여부가 아니라 '
            '교체를 ASG가 한다는 점이다',
      ),
    ];

    String allText(Map<String, dynamic> q) => <String>[
          q['stem'] as String? ?? '',
          q['explanation'] as String? ?? '',
          ...(q['options'] as List).cast<String>(),
          ...(q['wrongExplanations'] as Map<String, dynamic>).values
              .cast<String>(),
        ].join('\n');

    for (final f in fixes) {
      test('${f.qid}: 정답 인덱스는 그대로 ${f.correct}', () {
        expect(question(f.task, f.qid)['correct'], f.correct);
      });

      test('${f.qid}: 옛 문구가 사라지고 공식 사실이 들어왔다', () {
        final text = allText(question(f.task, f.qid));
        for (final bad in f.forbidden) {
          expect(text.contains(bad), isFalse,
              reason: '${f.qid} 에 옛 문구가 남아 있다: "$bad"\n공식: ${f.why}');
        }
        for (final good in f.required) {
          expect(text.contains(good), isTrue,
              reason: '${f.qid} 에 공식 사실이 없다: "$good"\n공식: ${f.why}');
        }
      });
    }
  });

  // ── 우선순위 2 B조(1) — VPC 엔드포인트·Flow Logs 4건 (2026-10-28) ──────────
  //
  // 근거:
  // - `vpc/privatelink/gateway-endpoints.html`
  //   "While traffic to Amazon S3 or DynamoDB **traverses the internet gateway, it does
  //   not leave the AWS network**."
  //   "**Amazon S3 and DynamoDB support both gateway endpoints and interface endpoints.**"
  //   "Gateway VPC endpoints provide reliable connectivity to Amazon S3 and DynamoDB
  //   **without requiring an internet gateway or a NAT device**"
  // - `vpc/userguide/flow-logs.html`
  //   "Flow log data can be published to the following locations: **Amazon CloudWatch Logs,
  //   Amazon S3, or Amazon Data Firehose**."
  //
  // ⚠️ `t1-3-q10` 은 보고가 적은 것보다 넓게 틀렸다 — "교차 적용 불가"라고 **단정**하고
  //   있었고, 이는 같은 Task `q9` 의 오답 근거("Interface Endpoint도 인터넷 없이 S3에
  //   접근 가능")와 **문서 내부에서 모순**이었다. 공식 문서는 S3·DynamoDB가 두 유형을
  //   **둘 다** 지원한다고 적는다.
  group('§우선순위2 B조(1) — VPC 엔드포인트·Flow Logs 4건', () {
    final fixes = <({
      String task,
      String qid,
      int correct,
      List<String> forbidden,
      List<String> required,
      String why,
    })>[
      (
        task: 'saa-t1-3', qid: 'saa-t1-3-q9', correct: 2,
        forbidden: ['인터넷 퍼블릭 엔드포인트를 경유'],
        required: ['AWS 네트워크를 벗어나지 않'],
        why: 'NAT 경유 S3 트래픽은 퍼블릭 서비스 엔드포인트를 쓰지만 AWS 네트워크를 '
            '벗어나지는 않는다 — 보기를 오답으로 만드는 근거는 비용(NAT 과금)이다',
      ),
      (
        task: 'saa-t1-3', qid: 'saa-t1-3-q10', correct: 1,
        forbidden: ['교차 적용 불가'],
        required: ['둘 다 지원'],
        why: 'S3·DynamoDB는 Gateway와 Interface 엔드포인트를 둘 다 지원한다 — '
            '구분점은 Gateway가 그 두 서비스에만 쓰인다는 쪽이다',
      ),
      (
        task: 'saa-t1-3', qid: 'saa-t1-3-q13', correct: 3,
        forbidden: <String>[],
        required: ['Data Firehose'],
        why: 'Flow Logs 발행 대상은 CloudWatch Logs·S3·Data Firehose 세 곳이다',
      ),
      (
        task: 'saa-t2-2', qid: 'saa-t2-2-q15', correct: 2,
        forbidden: ['NAT Gateway·VPC 엔드포인트로 처리'],
        required: ['외부 인터넷으로 나가려면 NAT'],
        why: 'VPC 엔드포인트는 인터넷 경로가 아니라 AWS 서비스에 IGW·NAT 없이 닿는 '
            '비공개 경로다 — 외부 인터넷은 NAT 게이트웨이가 맡는다',
      ),
    ];

    String allText(Map<String, dynamic> q) => <String>[
          q['stem'] as String? ?? '',
          q['explanation'] as String? ?? '',
          ...(q['options'] as List).cast<String>(),
          ...(q['wrongExplanations'] as Map<String, dynamic>).values
              .cast<String>(),
        ].join('\n');

    for (final f in fixes) {
      test('${f.qid}: 정답 인덱스는 그대로 ${f.correct}', () {
        expect(question(f.task, f.qid)['correct'], f.correct);
      });

      test('${f.qid}: 옛 문구가 사라지고 공식 사실이 들어왔다', () {
        final text = allText(question(f.task, f.qid));
        for (final bad in f.forbidden) {
          expect(text.contains(bad), isFalse,
              reason: '${f.qid} 에 옛 문구가 남아 있다: "$bad"\n공식: ${f.why}');
        }
        for (final good in f.required) {
          expect(text.contains(good), isTrue,
              reason: '${f.qid} 에 공식 사실이 없다: "$good"\n공식: ${f.why}');
        }
      });
    }
  });

  // ── 우선순위 2 B조(2) — 잔여 7건 (2026-10-28) ────────────────────────────
  //
  // 2026-10-27 2차 검수 보고 우선순위 2의 마지막 묶음. 전부 드래프트 Task라 라이브
  // 노출은 없다. 정답 인덱스는 6건이 불변이고, `saa-t2-3-q4` 한 건만 **사용자 승인으로
  // 0 → 1** 로 옮겼다 — 대상 그룹 수준에서 교차 영역을 끄는 기능(2022-11)이 정답 보기를
  // 거짓으로 만들어 맞는 보기가 하나도 없었다.
  //
  // 근거:
  // - `waf/latest/developerguide/waf-anti-ddos-advanced.html`
  //   "The `AWSManagedRulesAntiDDoSRuleSet` managed rule group is the **most advanced
  //   tier of Anti-DDoS protections available in AWS WAF**."
  //   "**You are charged additional fees when you use this managed rule group.**"
  //   `waf-anti-ddos-rg-using.html` — "**Add** the AWS managed rule group,
  //   `AWSManagedRulesAntiDDoSRuleSet` **to your protection pack (web ACL)**"
  // - `kms/latest/developerguide/key-policy-overview.html`
  //   "the policy statement **doesn't give permission to any IAM principal**. Instead,
  //   it gives the AWS account permission to **use IAM policies to delegate** the
  //   permissions specified in the key policy."
  // - `acm/latest/userguide/managed-renewal.html`
  //   "ELIGIBLE if associated with another AWS service, such as Elastic Load Balancing
  //   or CloudFront." / "**ELIGIBLE if exported since being issued or last renewed.**"
  //   / "NOT ELIGIBLE if imported." / "NOT ELIGIBLE if already expired."
  //   `acm-exportable-certificates.html` — "Certificates have a **198 days** validity
  //   period." / "ACM renews certificates set to expire **45 days** before their
  //   expiration date."
  // - `AmazonRDS/latest/APIReference/API_TargetResourceConfiguration.html` —
  //   `TargetKmsKeyId` "Specify this setting in either of the following cases: You want
  //   the green resource to use a different KMS key than the blue resource. **The blue
  //   resource is unencrypted and you want to encrypt the green resource.**"
  // - `lambda/latest/dg/configuration-vpc.html`
  //   "**The first time you attach a function to a VPC** using a particular subnet and
  //   security group combination, **Lambda creates a Hyperplane ENI**."
  //   "For new functions, while Lambda is creating a Hyperplane ENI, your function
  //   **remains in the Pending state and you can't invoke it**."
  // - `elasticloadbalancing/latest/userguide/how-elastic-load-balancing-works.html`
  //   "two targets in Availability Zone A and eight targets in Availability Zone B …
  //   each load balancer node receives 50% of the traffic"
  //   "If cross-zone load balancing is disabled: Each of the two targets in Availability
  //   Zone A receives **25%** of the traffic. Each of the eight targets in Availability
  //   Zone B receives **6.25%** of the traffic."
  //   "With Application Load Balancers, cross-zone load balancing is **always enabled at
  //   the load balancer level**. **At the target group level, cross-zone load balancing
  //   can be disabled.**"
  // - `elasticloadbalancing/latest/application/edit-target-group-attributes.html`
  //   "If the cookie is present but can't be decoded, or if it refers to a target that
  //   was deregistered or is unhealthy, **the load balancer selects a new target and
  //   updates the cookie** with information about the new target."
  //   "Sticky sessions are not supported if cross-zone load balancing is disabled."
  //
  // ⚠ 보고가 고정 세션 근거로 적은 `application/sticky-sessions.html` 은
  //   `application/introduction.html` 로 리다이렉트되는 **죽은 슬러그**다(2026-10-28
  //   실측). 정본은 위 `edit-target-group-attributes.html#sticky-sessions` 다.
  //
  // ⚠ `saa-t1-5-q4` 는 **해설과 학습문서는 이미 옳은데 정답 보기만 뒤처진** 경우여서,
  //   같은 문항 안에서 보기와 해설이 서로 모순이었다. 문항 전체를 보는 집계형 가드가
  //   아니면 해설만 보는 기존 가드를 비껴 간다.
  group('§우선순위2 B조(2) — 잔여 7건', () {
    final fixes = <({
      String task,
      String qid,
      int correct,
      List<String> forbidden,
      List<String> required,
      String why,
    })>[
      (
        task: 'saa-t1-4', qid: 'saa-t1-4-q2', correct: 2,
        forbidden: ['DDoS 자동 완화 서비스가 아닙니다'],
        required: ['AWSManagedRulesAntiDDoSRuleSet', '웹 ACL에 추가'],
        why: 'WAF에도 Anti-DDoS 관리형 규칙 그룹이 있다 — 갈림길은 웹 ACL에 직접 '
            '추가해야 하고 추가 요금이 붙는다는 점이다',
      ),
      (
        task: 'saa-t1-5', qid: 'saa-t1-5-q4', correct: 1,
        forbidden: ['해당 역할이 명시적으로 허용돼 있어야 한다'],
        required: ['위임하는 계정 주체 문장도 없어서'],
        why: '기본 키 정책의 계정 위임 문장만 있어도 역할을 키 정책에 적지 않고 IAM '
            '정책만으로 접근된다 — 갈림길은 명시적 허용이 아니라 위임 문장 유무다',
      ),
      (
        task: 'saa-t1-5', qid: 'saa-t1-5-q7', correct: 2,
        forbidden: ['1년마다 수동으로', 'AWS 서비스에서 사용 중이어야 한다'],
        required: ['198일', '내보낸(exported)'],
        why: '공인 인증서 유효 기간은 198일이고, 적격 대상에는 AWS 서비스 연결만 아니라 '
            '발급·갱신 이후 내보낸(exported) 인증서도 들어간다',
      ),
      (
        task: 'saa-t1-5', qid: 'saa-t1-5-q14', correct: 1,
        forbidden: ['유일한 경로는 스냅샷 경유'],
        required: ['TargetKmsKeyId', 'Blue/Green'],
        why: 'Blue/Green 배포를 만들 때 green 리소스에 TargetKmsKeyId 를 지정하면 '
            '암호화되지 않은 blue 를 암호화된 green 으로 바꿀 수 있다',
      ),
      (
        task: 'saa-t2-2', qid: 'saa-t2-2-q2', correct: 3,
        forbidden: ['ENI 생성으로 오히려 콜드 스타트가 길어질 수 있으며'],
        required: ['VPC를 설정하는 시점', 'Pending'],
        why: 'Hyperplane ENI 는 함수 생성·VPC 설정 시점에 미리 만들어지고 준비될 때까지 '
            '함수가 Pending 이라 호출 자체가 되지 않는다 — 2019년 이전 모델이다',
      ),
      (
        task: 'saa-t2-3', qid: 'saa-t2-3-q4', correct: 1,
        forbidden: ['이 설정이 원인일 수 없으며'],
        required: ['대상 그룹', '25%', '6.25%'],
        why: 'ALB 는 로드밸런서 수준에서는 교차 영역 분산이 항상 켜지고 끌 수 있는 곳은 '
            '대상 그룹 수준이다 — 끄면 2대/8대 배치에서 25%·6.25% 가 된다',
      ),
      (
        task: 'saa-t2-3', qid: 'saa-t2-3-q6', correct: 3,
        forbidden: ['새 인스턴스로 자연스럽게 연결하지 못'],
        required: ['새 대상을 골라 쿠키를 갱신'],
        why: '쿠키가 가리키는 대상이 등록 해제되거나 비정상이면 로드밸런서가 새 대상을 '
            '골라 쿠키를 갱신한다 — 끊기는 것은 연결이 아니라 세션 데이터다',
      ),
    ];

    String allText(Map<String, dynamic> q) => <String>[
          q['stem'] as String? ?? '',
          q['explanation'] as String? ?? '',
          ...(q['options'] as List).cast<String>(),
          ...(q['wrongExplanations'] as Map<String, dynamic>).values
              .cast<String>(),
        ].join('\n');

    for (final f in fixes) {
      test('${f.qid}: 정답 인덱스 ${f.correct}', () {
        expect(question(f.task, f.qid)['correct'], f.correct);
      });

      test('${f.qid}: 옛 문구가 사라지고 공식 사실이 들어왔다', () {
        final text = allText(question(f.task, f.qid));
        for (final bad in f.forbidden) {
          expect(text.contains(bad), isFalse,
              reason: '${f.qid} 에 옛 문구가 남아 있다: "$bad"\n공식: ${f.why}');
        }
        for (final good in f.required) {
          expect(text.contains(good), isTrue,
              reason: '${f.qid} 에 공식 사실이 없다: "$good"\n공식: ${f.why}');
        }
      });
    }
  });

  group('§우선순위3 배치1 — D3 saa-t3-1·t3-3 (7건)', () {
    final fixes = <({
      String task,
      String qid,
      int correct,
      List<String> forbidden,
      List<String> required,
      String why,
    })>[
      (
        task: 'saa-t3-1', qid: 'saa-t3-1-q1', correct: 1,
        forbidden: [
          '내구성은 스토리지 클래스에 관계없이 모든 클래스에서',
          '이며 모든 클래스의 내구성은 99.999999999%',
        ],
        required: ['현재 권장되는 모든', 'Reduced Redundancy Storage', '99.99%'],
        why: '스토리지 클래스 비교 표에 권장되지 않는(Not recommended) Reduced '
            'Redundancy Storage 가 설계 내구성 99.99% 로 올라 있다 — "모든 클래스가 '
            '11 nine" 은 사실이 아니고 "현재 권장되는 모든 클래스" 로 한정해야 한다',
      ),
      (
        task: 'saa-t3-1', qid: 'saa-t3-1-q4', correct: 2,
        forbidden: [
          '수 분 이내에 데이터를 꺼낼',
          '복원 시간은 최대 12시간입니다',
          '분~12시간의 복원 시간이 걸립니다',
        ],
        required: ['복원 절차를 거치지 않고 밀리초', '대량(Bulk) 48시간', '1~5분'],
        why: 'Flexible Retrieval 의 신속(Expedited) 복원은 250MB 미만 객체를 보통 '
            '1~5분에 꺼내 주므로 "수 분 이내" 로는 Instant Retrieval 을 가릴 수 없다. '
            'Deep Archive 복원은 표준 12시간 이내·대량 48시간 이내이고 신속 복원이 없다',
      ),
      (
        task: 'saa-t3-1', qid: 'saa-t3-1-q7', correct: 1,
        forbidden: ['학습 문서의'],
        required: ['접근 빈도에 맞춰 단계적으로'],
        why: '"학습 문서의 예시와 정확히 일치합니다" 는 문항 바깥을 가리키는 작성 과정 '
            '메모다 — 학습자에게는 수명 주기 설계 근거만 보여야 한다',
      ),
      (
        task: 'saa-t3-1', qid: 'saa-t3-1-q11', correct: 1,
        forbidden: [
          'Block Public Access → IAM 정책 → 버킷 정책 → ACL',
          '계층 순서로 평가됩니다',
          'IAM 정책뿐만 아니라',
          '접근 제어 평가의 최우선 계층',
        ],
        required: ['재정의(override)', '가장 제한적인 조합', 'IAM 자격증명 정책이 아니라'],
        why: '공식 문서는 평가 순서를 적지 않는다 — BPA 는 버킷 정책·액세스 포인트 '
            '정책·ACL 같은 리소스 쪽 공개 허용 설정을 재정의하며, 액세스 포인트·버킷·'
            '계정·조직 설정 중 가장 제한적인 조합이 적용된다. IAM 자격증명 정책은 '
            'BPA 의 대상이 아니다',
      ),
      (
        task: 'saa-t3-1', qid: 'saa-t3-1-q13', correct: 1,
        forbidden: [
          'URL 만료 전까지 유효하다',
          '만료 시간이 설정되며 만료 후에는 접근이 거부됩니다',
        ],
        required: ['역할 세션', '이른 쪽'],
        why: '역할(임시 자격증명)로 서명한 프리사인 URL 은 더 긴 만료 시간을 지정했어도 '
            '역할 세션이 끝나면 만료된다 — 유효 기간은 URL 만료와 세션 만료 중 이른 쪽이다',
      ),
      (
        task: 'saa-t3-3', qid: 'saa-t3-3-q11', correct: 1,
        forbidden: ['150개 브로커를 배치하면 8번째 인스턴스부터 시작이 실패합니다'],
        required: ['AZ마다 최대 7개', '총 21개'],
        why: '랙 수준 분산 배치 그룹은 같은 리전의 여러 AZ 에 걸칠 수 있고 상한은 '
            'AZ마다 실행 인스턴스 7개다 — 3 AZ 리전이면 총 21개가 상한이다',
      ),
      (
        task: 'saa-t3-3', qid: 'saa-t3-3-q12', correct: 1,
        forbidden: ['배치 그룹(클러스터·파티션·분산 모두)은 전용 인스턴스와 함께 사용할 수 없습니다'],
        required: ['지원하지 않는 것은 분산', '전용 호스트(Dedicated Host)는 어떤 배치 그룹에도'],
        why: '전용 인스턴스를 지원하지 않는 것은 분산 배치 그룹 하나다. 클러스터·파티션은 '
            '함께 쓸 수 있고, 전용 호스트는 어떤 배치 그룹에도 시작할 수 없다',
      ),
    ];

    String allText(Map<String, dynamic> q) => <String>[
          q['stem'] as String? ?? '',
          q['explanation'] as String? ?? '',
          ...(q['options'] as List).cast<String>(),
          ...(q['wrongExplanations'] as Map<String, dynamic>).values
              .cast<String>(),
        ].join('\n');

    for (final f in fixes) {
      test('${f.qid}: 정답 인덱스 ${f.correct}', () {
        expect(question(f.task, f.qid)['correct'], f.correct);
      });

      test('${f.qid}: 옛 문구가 사라지고 공식 사실이 들어왔다', () {
        final text = allText(question(f.task, f.qid));
        for (final bad in f.forbidden) {
          expect(text.contains(bad), isFalse,
              reason: '${f.qid} 에 옛 문구가 남아 있다: "$bad"\n공식: ${f.why}');
        }
        for (final good in f.required) {
          expect(text.contains(good), isTrue,
              reason: '${f.qid} 에 공식 사실이 없다: "$good"\n공식: ${f.why}');
        }
      });
    }

    test('saa-t3-1-q11 은 BPA 공식 문서를 출처로 싣는다', () {
      expect(hasSource(question('saa-t3-1', 'saa-t3-1-q11'),
          'access-control-block-public-access'), isTrue);
    });

    test('saa-t3-1-q13 은 프리사인 URL 공식 문서를 출처로 싣는다', () {
      expect(hasSource(question('saa-t3-1', 'saa-t3-1-q13'),
          'using-presigned-url'), isTrue);
    });

    test('saa-t3-1-q4 는 아카이브 복원 옵션 문서를 출처로 싣는다', () {
      expect(hasSource(question('saa-t3-1', 'saa-t3-1-q4'),
          'restoring-objects-retrieval-options'), isTrue);
    });
  });

  group('§우선순위3 배치2 — D3 saa-t3-6·t3-7 (9건)', () {
    final fixes = <({
      String task,
      String qid,
      int correct,
      List<String> forbidden,
      List<String> required,
      String why,
    })>[
      (
        task: 'saa-t3-6', qid: 'saa-t3-6-q9', correct: 2,
        forbidden: ['CloudFront는 정적 콘텐츠 캐시이며'],
        required: ['정적·동적 콘텐츠 모두를 가속', '오리진인 단일 리전 DynamoDB'],
        why: 'CloudFront 는 정적·동적 웹 콘텐츠 모두의 배포를 가속한다 — 보기 1이 '
            '탈락하는 이유는 캐시 대상이 아니라, 쓰기가 결국 오리진인 단일 리전 '
            '테이블까지 가야 하고 리전 장애 대비가 없다는 점이다',
      ),
      (
        task: 'saa-t3-6', qid: 'saa-t3-6-q11', correct: 1,
        forbidden: [
          '금융 거래 데이터는 RDS 선택 신호입니다',
          '금융 거래 데이터에 관계형 데이터베이스가 적합하다',
        ],
        required: ['금융 거래 여부 자체는 결정 신호가 아닙니다', 'TransactWriteItems'],
        why: 'DynamoDB 도 TransactWriteItems·TransactGetItems 로 ACID 트랜잭션을 '
            '지원한다(같은 계정·같은 리전 범위) — RDS 를 가르는 신호는 금융 거래가 '
            '아니라 복잡한 조인·집계와 고정된 스키마다',
      ),
      (
        task: 'saa-t3-6', qid: 'saa-t3-6-q12', correct: 1,
        forbidden: [
          'Memcached는 영속성과 복제 기능이 없으므로',
          'Memcached는 멀티스레드 처리 능력은 있지만 복제와 HA 기능이 없습니다',
        ],
        required: ['노드 기반(node-based) Memcached', '서버리스 Memcached', '마이크로초'],
        why: '복제가 없는 것은 노드 기반 Memcached 클러스터다 — 서버리스 캐시는 복제된 '
            'Multi-AZ 구조로 노드 장애를 가린다. DynamoDB(한 자릿수 밀리초)를 '
            '가려내려면 지문이 마이크로초 수준의 인메모리 응답을 요구해야 한다',
      ),
      (
        task: 'saa-t3-6', qid: 'saa-t3-6-q13', correct: 2,
        forbidden: [
          '스냅샷(RDB)과 AOF 로그로 영속성을 제공해',
          '스냅샷(RDB)으로 영속성을 지원한다',
        ],
        required: ['2.8.22', 'MemoryDB'],
        why: 'ElastiCache 는 Redis OSS 2.8.22 이후 appendonly·appendfsync 를 '
            '지원하지 않아 AOF 가 없다 — 보존 수단은 스냅샷(RDB) 백업과 복제·'
            'Multi-AZ 이고, 디스크 기반 영속성이 필요하면 MemoryDB 다',
      ),
      (
        task: 'saa-t3-7', qid: 'saa-t3-7-q1', correct: 1,
        forbidden: ['Route 53 Traffic Flow 기능에서만 사용할 수 있습니다'],
        required: ['bias(편향값, 1~99 / -1~-99)'],
        why: 'Geoproximity 는 레코드를 만들 때 고르는 라우팅 정책이고 프라이빗 호스팅 '
            '영역에서도 쓸 수 있다 — Traffic Flow 전용이 아니다',
      ),
      (
        task: 'saa-t3-7', qid: 'saa-t3-7-q3', correct: 1,
        forbidden: ['헬스 체크 연동은 Failover 정책에서 선택이 아니라 필수입니다'],
        required: ['Evaluate Target Health', '별칭(alias) 레코드를 만들 수 없는'],
        why: '별칭 레코드를 만들 수 있는 AWS 리소스로 보낼 때는 헬스 체크를 만들지 '
            '말고 Evaluate Target Health 를 Yes 로 두는 것이 공식 권장이다 — '
            '헬스 체크가 필수인 것은 별칭을 못 쓰는 엔드포인트일 때다',
      ),
      (
        task: 'saa-t3-7', qid: 'saa-t3-7-q5', correct: 1,
        forbidden: ['Route 53 Traffic Flow에서만 사용 가능합니다'],
        required: ['거리 계산으로 정해지므로'],
        why: 'q1 과 같은 "Traffic Flow 전용" 서술이 오답 근거에 복제돼 있었다 — '
            'Geoproximity 가 규제 준수에 부적합한 진짜 이유는 경계가 거리 계산으로 '
            '정해져 국가 단위를 보장하지 못한다는 점이다',
      ),
      (
        task: 'saa-t3-7', qid: 'saa-t3-7-q6', correct: 1,
        forbidden: [
          'Traffic Flow 기능에서만 사용할 수 있습니다',
          'Traffic Flow에서만 사용 가능하다',
          'Traffic Flow에서만 사용 가능합니다',
        ],
        required: ['1 - (bias/100)', 'Traffic Flow 전용이 아니고', '프라이빗 호스팅 영역'],
        why: '정답 보기가 "Traffic Flow 에서만 사용 가능" 을 달고 있어 맞는 보기가 '
            '없는 상태였다. 공식 문서는 Geoproximity 를 레코드 생성 시 고르는 '
            '라우팅 정책으로 싣고 프라이빗 호스팅 영역 사용까지 명시한다 — '
            'Traffic Flow 에서만 되는 것은 편향 범위를 보여 주는 지도다',
      ),
      (
        task: 'saa-t3-7', qid: 'saa-t3-7-q11', correct: 2,
        forbidden: ['또한 CloudFront는 고정 IP가 아닌 도메인 기반(가변 IP)입니다'],
        required: ['Anycast 고정 IP 목록', 'HTTP/HTTPS 트래픽에만'],
        why: 'CloudFront 에도 Anycast 고정 IP 목록 기능이 있다(허용 목록용 21개, '
            '에이펙스 도메인용 3개) — 갈림길은 고정 IP 유무가 아니라 그 IP 가 '
            'CloudFront 배포의 HTTP/HTTPS 트래픽에만 쓰여 UDP 에 못 쓴다는 점이다',
      ),
    ];

    String allText(Map<String, dynamic> q) => <String>[
          q['stem'] as String? ?? '',
          q['explanation'] as String? ?? '',
          ...(q['options'] as List).cast<String>(),
          ...(q['wrongExplanations'] as Map<String, dynamic>).values
              .cast<String>(),
        ].join('\n');

    for (final f in fixes) {
      test('${f.qid}: 정답 인덱스 ${f.correct}', () {
        expect(question(f.task, f.qid)['correct'], f.correct);
      });

      test('${f.qid}: 옛 문구가 사라지고 공식 사실이 들어왔다', () {
        final text = allText(question(f.task, f.qid));
        for (final bad in f.forbidden) {
          expect(text.contains(bad), isFalse,
              reason: '${f.qid} 에 옛 문구가 남아 있다: "$bad"\n공식: ${f.why}');
        }
        for (final good in f.required) {
          expect(text.contains(good), isTrue,
              reason: '${f.qid} 에 공식 사실이 없다: "$good"\n공식: ${f.why}');
        }
      });
    }

    final swaps = <({String task, String qid, String fragment})>[
      (
        task: 'saa-t3-6',
        qid: 'saa-t3-6-q9',
        fragment: 'AmazonCloudFront/latest/DeveloperGuide/Introduction'
      ),
      (task: 'saa-t3-6', qid: 'saa-t3-6-q11', fragment: 'transaction-apis'),
      (
        task: 'saa-t3-6',
        qid: 'saa-t3-6-q12',
        fragment: 'disaster-recovery-resiliency'
      ),
      (task: 'saa-t3-6', qid: 'saa-t3-6-q13', fragment: 'engine-versions'),
      (task: 'saa-t3-6', qid: 'saa-t3-6-q13', fragment: 'what-is-memorydb'),
      (task: 'saa-t3-7', qid: 'saa-t3-7-q3', fragment: 'dns-failover-types'),
      (
        task: 'saa-t3-7',
        qid: 'saa-t3-7-q6',
        fragment: 'routing-policy-geoproximity'
      ),
      (task: 'saa-t3-7', qid: 'saa-t3-7-q11', fragment: 'request-static-ips'),
    ];

    for (final s in swaps) {
      test('${s.qid}: 사실을 담은 공식 페이지(${s.fragment})를 출처로 싣는다', () {
        expect(hasSource(question(s.task, s.qid), s.fragment), isTrue,
            reason: '${s.qid} 가 ${s.fragment} 를 출처로 싣지 않는다');
      });
    }
  });

  group('§우선순위3 배치3 — D3 saa-t3-8·t3-9 (6건)', () {
    final fixes = <({
      String task,
      String qid,
      int correct,
      List<String> forbidden,
      List<String> required,
      String why,
    })>[
      (
        task: 'saa-t3-8', qid: 'saa-t3-8-q2', correct: 2,
        forbidden: [
          '온프레미스 데이터센터와도 연결해야 한다',
          '여기에 온프레미스 연결까지 각 VPC마다 추가로 설정해야 하므로',
        ],
        required: ['10×9/2 = 45개', 'VPC 피어링은 두 VPC 사이를 잇는 연결'],
        why: 'VPC 피어링은 두 VPC 사이의 네트워킹 연결이라 온프레미스에는 쓸 수 없다 '
            '— "피어링만으로 온프레미스까지" 는 전제가 성립하지 않아 지문을 VPC 10개 '
            '완전 메시로 한정했다',
      ),
      (
        task: 'saa-t3-8', qid: 'saa-t3-8-q6', correct: 3,
        forbidden: ['DX over VPN'],
        required: ['VPN over Direct Connect', 'MACsec'],
        why: '공식 명칭은 Direct Connect 위에 Site-to-Site VPN 을 얹는 "VPN over '
            'Direct Connect" 다 — "DX over VPN" 은 위아래가 거꾸로다. 암호화 선택지는 '
            'IPsec VPN 과 MACsec(IEEE 802.1AE) 둘이다',
      ),
      (
        task: 'saa-t3-8', qid: 'saa-t3-8-q7', correct: 2,
        forbidden: ['DX over VPN'],
        required: ['VPN over Direct Connect', 'MACsec'],
        why: '같은 명칭 역전이 정답 보기와 해설에 있었다. 공식 문서는 Direct Connect 가 '
            '기본적으로 전송 중 트래픽을 암호화하지 않는다고 적고, 암호화 수단으로 '
            'Site-to-Site VPN 결합과 MACsec 을 함께 싣는다',
      ),
      (
        task: 'saa-t3-8', qid: 'saa-t3-8-q9', correct: 0,
        forbidden: ['DX over VPN'],
        required: ['VPN over Direct Connect'],
        why: '오답 근거에 같은 명칭 역전이 복제돼 있었다',
      ),
      (
        task: 'saa-t3-8', qid: 'saa-t3-8-q10', correct: 3,
        forbidden: [
          '온프레미스를 경유하는 트래픽(hair-pinning)은 지원되지 않습니다',
          '온프레미스를 경유하는 라우팅을 활성화하면 된다',
        ],
        required: ['2021년 11월', '슈퍼넷', 'BGP 경로 리플렉터'],
        why: '공식 문서는 2021년 11월부터의 예외를 명시한다 — 같은 가상 인터페이스에서 '
            'VPC CIDR 을 포함하는 슈퍼넷(10.0.0.0/8, 0.0.0.0/0 등)을 온프레미스에서 '
            '광고하면 그 VPC 들이 Direct Connect 엔드포인트를 거쳐 서로 통신한다. '
            '따라서 "hair-pinning 불가" 는 틀렸고, 보기도 존재하지 않는 기능으로 '
            '바꿔야 정답이 하나로 남는다. AWS 가 차단 방법까지 안내하므로 의도된 '
            '설계가 아니라 부작용이다',
      ),
      (
        task: 'saa-t3-9', qid: 'saa-t3-9-q11', correct: 0,
        forbidden: [
          '이 문항이 기존 고객을 전제로 두는 이유입니다',
          '회사의 인터넷 대역폭은 1 Gbps이며, 이 속도로 전송하면 수개월이 걸린다',
        ],
        required: ['약 200 Mbps', '약 230일'],
        why: '500 TB 를 1 Gbps 회선 속도로 보내면 약 46일이라 "수개월" 이 아니다. '
            '지문을 이전에 쓸 수 있는 가용 대역폭 약 200 Mbps 로 한정하면 약 230일로 '
            '수개월이 맞다. 괄호 안 "이 문항이 … 이유입니다" 는 작성 과정 메모다',
      ),
    ];

    String allText(Map<String, dynamic> q) => <String>[
          q['stem'] as String? ?? '',
          q['explanation'] as String? ?? '',
          ...(q['options'] as List).cast<String>(),
          ...(q['wrongExplanations'] as Map<String, dynamic>).values
              .cast<String>(),
        ].join('\n');

    for (final f in fixes) {
      test('${f.qid}: 정답 인덱스 ${f.correct}', () {
        expect(question(f.task, f.qid)['correct'], f.correct);
      });

      test('${f.qid}: 옛 문구가 사라지고 공식 사실이 들어왔다', () {
        final text = allText(question(f.task, f.qid));
        for (final bad in f.forbidden) {
          expect(text.contains(bad), isFalse,
              reason: '${f.qid} 에 옛 문구가 남아 있다: "$bad"\n공식: ${f.why}');
        }
        for (final good in f.required) {
          expect(text.contains(good), isTrue,
              reason: '${f.qid} 에 공식 사실이 없다: "$good"\n공식: ${f.why}');
        }
      });
    }

    final swaps = <({String task, String qid, String fragment})>[
      (task: 'saa-t3-8', qid: 'saa-t3-8-q2', fragment: 'what-is-vpc-peering'),
      (task: 'saa-t3-8', qid: 'saa-t3-8-q6', fragment: 'encryption-in-transit'),
      (task: 'saa-t3-8', qid: 'saa-t3-8-q7', fragment: 'encryption-in-transit'),
    ];

    for (final s in swaps) {
      test('${s.qid}: 사실을 담은 공식 페이지(${s.fragment})를 출처로 싣는다', () {
        expect(hasSource(question(s.task, s.qid), s.fragment), isTrue,
            reason: '${s.qid} 가 ${s.fragment} 를 출처로 싣지 않는다');
      });
    }

    test('saa-t3-8 문항에 "DX over VPN" 명칭 역전이 한 건도 남지 않았다', () {
      final map = json.decode(
              File('assets/content/saa/saa-t3-8.questions.json')
                  .readAsStringSync())
          as Map<String, dynamic>;
      final questions = (map['questions'] as List).cast<Map<String, dynamic>>();
      for (final q in questions) {
        // `skill` 까지 본다 — 실제로 saa-t3-8-q7 의 스킬 태그가 "DX over VPN
        // 암호화 패턴" 이었고, 스킬 태그는 학습자에게 그대로 노출된다.
        final text = <String>[
          q['stem'] as String? ?? '',
          q['skill'] as String? ?? '',
          q['explanation'] as String? ?? '',
          ...(q['options'] as List).cast<String>(),
          ...(q['wrongExplanations'] as Map<String, dynamic>).values
              .cast<String>(),
        ].join('\n');
        expect(text.contains('DX over VPN'), isFalse,
            reason: '${q['id']} 에 "DX over VPN" 이 남아 있다 — 공식 명칭은 '
                '"VPN over Direct Connect"(Direct Connect 위에 VPN)다');
      }
    });
  });
}
