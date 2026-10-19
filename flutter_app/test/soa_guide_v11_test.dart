import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// SOA-C03 공식 시험 가이드 v1.1 동기화 가드.
///
/// 2026-07 감사(GUIDE-001)에서 레포 JSON이 v1.0 문구에 머물러 공식 v1.1 개정
/// (스킬 10건 변경 · in-scope 5종 추가)을 놓친 것이 적발됐다. 그 재발을 막기 위해
/// ① 가이드 버전 메타 ② 의미가 달라진 스킬 10건의 현행 KO 문구 ③ 개정에서
/// 바뀌지 않은 구조(도메인·Task·Skill 수·비중·overview)를 한꺼번에 고정한다.
///
/// 근거: docs/content-research/SOA-C03/97-guide-v11-diff.md (공식 ko_kr 페이지
/// 기계 추출 · 조회 2026-10-17). 공식 가이드가 다시 개정되면 이 테스트를 근거
/// 문서와 함께 갱신한다.
void main() {
  final raw = File('assets/exam_guides/SOA-C03.json').readAsStringSync();
  final guide = json.decode(raw) as Map<String, dynamic>;
  final domains = (guide['domains'] as List).cast<Map<String, dynamic>>();

  /// `{Task번호}.{순번}` → 스킬 문구.
  Map<String, String> skillsByNumber() {
    final out = <String, String>{};
    for (final d in domains) {
      for (final t in (d['tasks'] as List).cast<Map<String, dynamic>>()) {
        final skills = (t['skills'] as List).cast<String>();
        for (var i = 0; i < skills.length; i++) {
          out['${t['no']}.${i + 1}'] = skills[i];
        }
      }
    }
    return out;
  }

  group('가이드 버전 메타', () {
    test('v1.1 버전·발행일·공식 자격증명이 기록돼 있다', () {
      expect(guide['guideVersion'], '1.1',
          reason: '공식 가이드 버전을 JSON에 남겨야 다음 개정을 감지할 수 있다');
      expect(guide['guidePublished'], '2026-06-01');
      expect(guide['officialName'],
          'AWS Certified CloudOps Engineer - Associate',
          reason: 'SOA-C03부터 공식명이 CloudOps Engineer로 개명됐다(GUIDE-002)');
    });
  });

  group('v1.1에서 의미가 달라진 스킬 10건', () {
    // 공식 ko_kr 도메인 페이지 현행 문구(97-guide-v11-diff.md §2.2) 전문 일치.
    const expected = <String, String>{
      '1.1.1':
          'AWS 서비스(예: Amazon CloudWatch, AWS CloudTrail, Amazon Managed Service for Prometheus)를 '
              '사용하여 워크로드(예: 서버리스, 컴퓨팅, AI)에 대한 모니터링 및 로깅 구성',
      '1.2.1':
          'AWS 서비스 및 기능을 사용하여 성능 지표를 분석하고 문제 해결 전략 자동화'
              '(예: CloudWatch, Lambda, AWS Systems Manager, CloudTrail, Kiro, AWS DevOps Agent)',
      '1.3.4':
          '공유 스토리지 솔루션(예: Amazon EFS, Amazon FSx, Amazon S3 Files)을 평가 및 선택하고 '
              '특정 사용 사례 및 요구 사항에 맞게 솔루션(예: EFS 수명 주기 정책) 최적화',
      '2.3.4':
          '재해 복구 절차 및 모범 사례(예: 백업 및 복원, 파일럿 라이트, 예열 대기 방식, 액티브/액티브) 준수',
      '3.1.2': 'CloudFormation 및 AWS CDK를 사용하여 AWS 리소스를 만들고 관리',
      '3.2.2':
          'AWS 서비스 및 기능(예: Lambda, S3 이벤트 알림, EventBridge, AWS DevOps Agent)을 '
              '사용하여 이벤트 기반 자동화 구현',
      '4.1.3':
          '다중 계정 전략을 안전하게 구현(예: AWS Organizations, 서비스 제어 정책, IAM Identity Center)',
      '4.1.5':
          '규정 준수 요구 사항 및 지속적인 모니터링 적용(예: 리전 및 서비스 선택, AWS Config 규정 준수 팩)',
      '4.2.5':
          '보고서를 구성하고 AWS 서비스(예: AWS Security Hub, Amazon GuardDuty, AWS Config, '
              'Amazon Inspector, AWS Security Agent)의 조사 결과 발견된 문제 해결',
      '5.1.2': '프라이빗 네트워킹 연결 구성(예: VPC 엔드포인트, AWS PrivateLink, VPC 피어링)',
    };

    final actual = skillsByNumber();
    expected.forEach((no, text) {
      test('Skill $no 가 v1.1 문구다', () {
        expect(actual[no], isNotNull, reason: 'Skill $no 가 JSON에 없다');
        expect(actual[no], text);
      });
    });

    test('v1.0 전용 표현이 남아 있지 않다', () {
      final all = actual.values.join('\n');
      // 1.2.1에서 빠진 예시들(공식 Revisions 표 기준)
      expect(all.contains('AWS 사용자 알림'), isFalse,
          reason: 'v1.1 1.2.1에서 AWS User Notifications 예시가 삭제됐다');
      expect(actual['1.2.1']!.contains('오토 스케일링'), isFalse,
          reason: 'v1.1 1.2.1에서 auto scaling 예시가 삭제됐다');
    });
  });

  group('v1.1에서 바뀌지 않은 구조', () {
    test('도메인 5개 · 비중 22/22/22/16/18', () {
      expect(domains.length, 5);
      expect(domains.map((d) => d['weightPct']).toList(), [22, 22, 22, 16, 18]);
    });

    test('Task 13개 · Skill 53개', () {
      final tasks = domains.fold<int>(
          0, (sum, d) => sum + (d['tasks'] as List).length);
      expect(tasks, 13);
      expect(skillsByNumber().length, 53);
    });

    test('overview(합격선 720 · 채점 50 · 비채점 15 · 130분)', () {
      final ov = guide['overview'] as Map<String, dynamic>;
      expect(ov['passingScore'], 720);
      expect(ov['scoredQuestions'], 50);
      expect(ov['unscoredQuestions'], 15);
      expect(ov['durationMinutes'], 130);
    });
  });
}
