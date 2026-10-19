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
      expect(option.contains('관리형 교체'), isTrue);
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
}
