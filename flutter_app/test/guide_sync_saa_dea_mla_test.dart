// SAA-C03 · DEA-C01 · MLA-C01 시험 가이드 동기화 가드 (2026-11-18 외부 리뷰 후속 §3-1).
//
// 가이드 동기화 가드는 CLF·SOA·AIF·SCS·AIP 다섯에만 있었다. 이 파일이 나머지 등재 셋의 판이다.
//
// ## 측정 (2026-11-18)
//
// 공식 한국어 도메인 페이지(`/ko_kr/aws-certification/latest/<slug>/<slug>-domainN.html`, 열두 페이지
// 전부 `200 r=0`)를 받아 Task 제목과 지식·기술 항목을 레포 JSON 과 **바이트 단위로** 대조했다.
//
// | 자격증 | 대조 항목 | 교체 전 불일치 | 교체 후 |
// |---|---|---|---|
// | SAA-C03 | 189 | 4 (3종 — ALB 표기가 두 Task 에 반복) | 0 |
// | DEA-C01 | 120 | 8 | 0 |
// | MLA-C01 | 133 | 0 | 0 |
//
// - **SAA 4곳은 2026-11-17 전 콘텐츠 검증(`docs/audits/2026-11-17-full-verify/saa-phase2.md` Y20)이
//   이미 찾았지만 공유 파일이라 고치지 않고 넘긴 것**이다. 실측이 그 기록과 정확히 같았다.
//   그중 `Amazon QuickSuite` 는 **공식에 없는 이름**이다(공식은 `Amazon Quick`).
// - DEA 8곳은 공식이 **약어로 줄인 서비스 이름**(`AWS DMS`·`Amazon EKS`·`AWS SAM`·`AWS KMS` 등)을
//   레포가 풀어 쓴 옛 판이었다. ⚠️ 공식 `기술 1.1.1` 은 **마침표로 끝난다** — 다른 항목과 달라도
//   공식 그대로 넣었다(「읽기 좋게」 고치면 이 가드가 거짓으로 깨진다 — CLF 가드의 같은 규율).
// - 도메인 이름·비중·`overview`(65문항·720점)도 공식과 일치했다. `durationMinutes` 는 가이드
//   본문에 없어 대조 대상이 아니다(AIF 선례).
//
// ## ⚠️ 측정 함정 — 페이지 형식이 둘이다
//
// DEA 는 항목이 `기술 1.1.1: …` 처럼 **번호 접두사**를 달고, SAA·MLA 는 `관련 지식:`·`관련 기술:`
// 소제목 아래 **무번호 목록**이다. 접두사만 찾는 추출기는 SAA·MLA 에서 **항목 0개**를 돌려줬다 —
// 「0건 일치」는 결과가 아니라 파서를 의심할 신호다.
//
// ⚠️ MLA 는 **MLA-C02 가이드가 이미 공개**돼 있지만(한국어 응시 2027-01-14부터) 이 가드는 C01 을 본다.
// C02 로 바꾸는 날 이 표의 MLA 줄을 함께 바꾼다.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 공식 Task 제목과 (지식 수, 기술 수). 2026-11-18 공식 페이지와 바이트 일치를 확인한 값이다.
const Map<String, Map<String, (String, int, int)>> _official = {
  'SAA-C03': {
      '1.1': ('AWS 리소스에 대한 보안 액세스 설계', 5, 6),
      '1.2': ('안전한 워크로드 및 애플리케이션 설계', 6, 4),
      '1.3': ('적합한 데이터 보안 제어 결정', 4, 7),
      '2.1': ('확장 가능하고 느슨하게 결합된 아키텍처 설계', 16, 7),
      '2.2': ('고가용성 및/또는 내결함성 아키텍처 설계', 12, 8),
      '3.1': ('고성능 및/또는 확장 가능한 스토리지 솔루션 결정', 3, 2),
      '3.2': ('고성능의 탄력적인 컴퓨팅 솔루션 설계', 6, 4),
      '3.3': ('고성능 데이터베이스 솔루션 결정', 8, 5),
      '3.4': ('고성능 및/또는 확장 가능한 네트워크 아키텍처 결정', 4, 4),
      '3.5': ('고성능 데이터 수집 및 변환 솔루션 결정', 7, 7),
      '4.1': ('비용에 최적화된 스토리지 솔루션 설계', 11, 10),
      '4.2': ('비용에 최적화된 컴퓨팅 솔루션 설계', 9, 6),
      '4.3': ('비용에 최적화된 데이터베이스 솔루션 설계', 9, 5),
      '4.4': ('비용에 최적화된 네트워크 아키텍처 설계', 7, 7),
    },
  'DEA-C01': {
      '1.1': ('데이터 수집 수행', 0, 12),
      '1.2': ('데이터 변환 및 처리', 0, 10),
      '1.3': ('데이터 파이프라인 오케스트레이션', 0, 4),
      '1.4': ('프로그래밍 개념 적용', 0, 11),
      '2.1': ('데이터 스토어 선택', 0, 8),
      '2.2': ('데이터 카탈로그 시스템 이해', 0, 6),
      '2.3': ('데이터의 수명 주기 관리', 0, 6),
      '2.4': ('데이터 모델 및 스키마 진화 설계', 0, 6),
      '3.1': ('AWS 서비스를 사용하여 데이터 처리 자동화', 0, 9),
      '3.2': ('AWS 서비스를 사용하여 데이터 분석', 0, 6),
      '3.3': ('데이터 파이프라인 유지 관리 및 모니터링', 0, 8),
      '3.4': ('데이터 품질 보장', 0, 5),
      '4.1': ('인증 메커니즘 적용', 0, 7),
      '4.2': ('권한 부여 메커니즘 적용', 0, 6),
      '4.3': ('데이터 암호화 및 마스킹 보장', 0, 4),
      '4.4': ('감사용 로그 준비', 0, 5),
      '4.5': ('데이터 프라이버시 및 거버넌스 이해', 0, 7),
    },
  'MLA-C01': {
      '1.1': ('데이터를 수집 및 저장', 4, 6),
      '1.2': ('데이터 변환 및 특성 추출 수행', 6, 3),
      '1.3': ('데이터 무결성을 보장하고 모델링을 위한 데이터 준비', 5, 4),
      '2.1': ('모델링 접근 방식 선택', 4, 5),
      '2.2': ('모델 훈련 및 개선', 8, 9),
      '2.3': ('모델 성능 분석', 5, 6),
      '3.1': ('기존 아키텍처 및 요구 사항에 따라 배포 인프라를 선택합니다.', 7, 6),
      '3.2': ('기존 아키텍처 및 요구 사항을 기반으로 인프라 만들기 및 스크립팅', 5, 6),
      '3.3': ('자동화된 오케스트레이션 도구를 사용하여 지속적 통합 및 지속적 전달(CI/CD) 파이프라인 설정', 6, 6),
      '4.1': ('모델 추론 모니터링', 3, 4),
      '4.2': ('인프라 및 비용 모니터링 및 최적화', 6, 10),
      '4.3': ('AWS 리소스 보호', 4, 5),
    },
};

/// 공식 판으로 교체한 항목: (교체 전 레포 문구, 공식 문구, 공식에서의 출현 수).
const Map<String, List<(String, String, int)>> _replaced = {
  'SAA-C03': [
    ('적절한 사용 사례를 갖춘 보안 서비스(예: AWS Cognito, AWS GuardDuty, AWS Macie)',
        '보안 서비스와 적합한 사용 사례(예: Amazon Cognito, Amazon GuardDuty, Amazon Macie)', 1),
    ('로드 밸런싱 개념(예: Application Load Balancer)',
        '로드 밸런싱 개념(예: Application Load Balancer(ALB))', 3),
    ('데이터 분석 및 시각화 서비스와 적합한 사용 사례(예: Amazon Athena, AWS Lake Formation, Amazon QuickSuite)',
        '데이터 분석 및 시각화 서비스와 적합한 사용 사례(예: Amazon Athena, AWS Lake Formation, Amazon Quick)', 1),
  ],
  'DEA-C01': [
    ('스트리밍 소스에서 데이터 읽기(예: Amazon Kinesis, Amazon Managed Streaming for Apache Kafka(Amazon MSK), Amazon DynamoDB Streams, AWS Database Migration Service(AWS DMS), AWS Glue, Amazon Redshift)',
        '스트리밍 소스에서 데이터 읽기(예: Amazon Kinesis, Amazon Managed Streaming for Apache Kafka(Amazon MSK), Amazon DynamoDB Streams, AWS DMS, AWS Glue, Amazon Redshift).', 1),
    ('성능 요구 사항에 맞게 컨테이너 사용 최적화(예: Amazon Elastic Kubernetes Service(Amazon EKS), Amazon Elastic Container Service(Amazon ECS))',
        '성능 요구 사항에 맞게 컨테이너 사용 최적화(예: Amazon EKS, Amazon ECS)', 1),
    ('알림 서비스를 사용하여 알림 전송(예: Amazon Simple Notification Service(Amazon SNS), Amazon Simple Queue Service(Amazon SQS))',
        '알림 서비스를 사용하여 알림을 전송(예: Amazon SNS, Amazon SQS)', 1),
    ('AWS Serverless Application Model(AWS SAM)을 사용하여 서버리스 데이터 파이프라인 패키징 및 배포(예: Lambda 함수, Step Functions, Amazon DynamoDB 테이블)',
        'AWS SAM을 사용하여 서버리스 데이터 파이프라인 패키징 및 배포(예: Lambda 함수, Step Functions, Amazon DynamoDB 테이블)', 1),
    ('반복 가능한 리소스 배포를 위해 코드형 인프라(IaC) 사용(예: AWS CloudFormation 및 AWS Cloud Development Kit(AWS CDK))',
        '반복 가능한 리소스 배포를 위해 코드형 인프라(IaC) 사용(예: AWS CloudFormation 및 AWS CDK)', 1),
    ('스키마 변환 수행(예: AWS 스키마 변환 도구(AWS SCT) 및 AWS Database Migration Service(AWS DMS) 스키마 변환 사용)',
        '스키마 변환 수행(예: AWS SCT 및 AWS DMS 스키마 변환 사용)', 1),
    ('AWS Identity and Access Management(AWS IAM) 그룹, 역할, 엔드포인트 및 서비스 생성 및 업데이트',
        'IAM 그룹, 역할, 엔드포인트, 서비스 생성 및 업데이트', 1),
    ('암호화 키를 사용하여 데이터 암호화하거나 암호 해독(예: AWS Key Management Service(AWS KMS))',
        '암호화 키를 사용하여 데이터 암호화 또는 해독(예: AWS KMS)', 1),
  ],
};

const Map<String, (List<String>, List<int>)> _domains = {
  'SAA-C03': (['보안 아키텍처 설계', '복원력을 갖춘 아키텍처 설계', '고성능 아키텍처 설계', '비용에 최적화된 아키텍처 설계'], [30, 26, 24, 20]),
  'DEA-C01': (['데이터 수집 및 변환', '데이터 스토어 관리', '데이터 운영 및 지원', '데이터 보안 및 거버넌스'], [34, 26, 22, 18]),
  'MLA-C01': (['기계 학습(ML)을 위한 데이터 준비', 'ML 모델 개발', 'ML 워크플로의 배포 및 오케스트레이션', 'ML 솔루션 모니터링, 유지 관리 및 보안'], [28, 26, 22, 24]),
};

Map<String, dynamic> _load(String cert) =>
    json.decode(File('assets/exam_guides/$cert.json').readAsStringSync()) as Map<String, dynamic>;

List<Map<String, dynamic>> _tasks(Map<String, dynamic> g) => [
      for (final d in (g['domains'] as List).cast<Map<String, dynamic>>())
        ...(d['tasks'] as List).cast<Map<String, dynamic>>(),
    ];

List<String> _items(Map<String, dynamic> g) => [
      for (final t in _tasks(g)) ...[
        ...((t['knowledge'] as List?) ?? const []).cast<String>(),
        ...((t['skills'] as List?) ?? const []).cast<String>(),
      ],
    ];

void main() {
  for (final cert in _official.keys) {
    group(cert, () {
      final g = _load(cert);

      test('대조군: 가이드를 실제로 읽었고 항목 수가 공식과 같다(이 가드가 공허하지 않다)', () {
        final official = _official[cert]!;
        final want = official.values.fold<int>(0, (a, v) => a + v.$2 + v.$3);
        expect(_items(g).length, want);
        expect(want, greaterThan(100));
      });

      test('도메인 이름·비중·overview 가 공식과 같다', () {
        final (names, weights) = _domains[cert]!;
        final domains = (g['domains'] as List).cast<Map<String, dynamic>>();
        expect([for (final d in domains) d['name']], names);
        expect([for (final d in domains) d['weightPct']], weights);
        final o = g['overview'] as Map<String, dynamic>;
        expect([o['scoredQuestions'], o['unscoredQuestions'], o['passingScore']], [50, 15, 720]);
      });

      test('Task 번호·제목·지식 수·기술 수가 공식과 같다', () {
        final got = {
          for (final t in _tasks(g))
            t['no'] as String: (
              t['title'] as String,
              ((t['knowledge'] as List?) ?? const []).length,
              ((t['skills'] as List?) ?? const []).length,
            ),
        };
        expect(got, _official[cert]);
      });

      if (_replaced.containsKey(cert)) {
        test('2026-11-18 공식 판으로 교체한 항목: 공식 문구가 있고 옛 문구는 없다', () {
          final items = _items(g);
          for (final (old, official, n) in _replaced[cert]!) {
            expect(items.where((i) => i == official).length, n, reason: official);
            expect(items.contains(old), isFalse, reason: '옛 문구가 돌아왔다: $old');
          }
        });
      }
    });
  }

  test('공식에 없는 이름 `Amazon QuickSuite` 가 세 가이드 어디에도 없다', () {
    for (final cert in _official.keys) {
      expect(File('assets/exam_guides/$cert.json').readAsStringSync().contains('QuickSuite'), isFalse,
          reason: cert);
    }
  });
}
