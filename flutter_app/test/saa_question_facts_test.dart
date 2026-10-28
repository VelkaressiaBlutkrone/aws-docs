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
}
