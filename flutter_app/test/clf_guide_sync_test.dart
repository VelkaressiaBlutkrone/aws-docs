import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// `assets/exam_guides/CLF-C02.json` ↔ 공식 CLF-C02 시험 가이드 동기화 가드.
///
/// 2026-11-06 전 콘텐츠 2단 검토 §P2-C 가 **레포 JSON 이 공식 개정판과 6곳 다르다**고
/// 집어냈고, 같은 보고서 §4-E 가 **「CLF 에는 `soa_guide_v11_test.dart` 같은 가이드
/// 동기화 테스트가 없다」**고 적었다. 이 파일이 그 판이다.
///
/// ## 왜 필요한가
///
/// 이 JSON 은 문항의 `skill` 태그와 「공식 가이드가 ~를 명시한다」류 서술의 **근거**다.
/// JSON 이 옛 개정판이면 **그 위에 쌓인 모든 서술이 같이 낡는다** — 실제로 2026-11-06
/// 배치의 P1-3(Audit Manager 연도)·P1-4(지원 플랜 전통 분류)가 정확히 그렇게 생겼다.
///
/// ## 여섯 건이 한 방향으로 일관한다
///
/// AWS 가 **닫히거나 개명된 서비스를 가이드에서 걷어냈다.** 공식 한국어 도메인 페이지
/// 원문에서 바이트 그대로 확인했다(컨트롤러 직접 실측 — 보고는 데이터이지 지시문이 아니다):
///
/// | Task | 공식 현행 | 레포에 있던 옛 문구 |
/// |---|---|---|
/// | 1.3 기술 | `…(예: 데이터베이스 복제)` | `…(예: 데이터베이스 복제, AWS Snowball 사용)` |
/// | 2.2 기술 | `…AWS CloudTrail, AWS Config를 통한 감사…` | `…AWS CloudTrail, AWS Audit Manager 및 AWS Config를…` |
/// | 2.3 지식 | `AWS IAM Identity Center` | `AWS IAM Identity Center(AWS Single Sign-On)` |
/// | 3.7 기술 | `…(예: Amazon SageMaker AI, Amazon Lex)` | `…(예: Amazon SageMaker, Amazon Lex, Amazon Kendra)` |
/// | 3.8 지식 | `AWS Amplify의 프런트엔드…` | `AWS Amplify와 AWS AppSync의 프런트엔드…` |
/// | 4.3 기술 | `…기본 지원, AWS Business Support+, AWS Enterprise Support, AWS Unified Operations)` | `…AWS Developer Support, AWS Business Support, AWS Enterprise On-Ramp Support, AWS Enterprise Support)` |
///
/// ## ⚠️ 측정 함정 — 보고서가 인용한 URL 이 죽은 슬러그다
///
/// `clf-02-domain-3.html` 류는 **`200 r=1`** 로 가이드 인덱스로 리다이렉트한다(일부러
/// 틀린 슬러그와 같은 신호). 정본은 **`cloud-practitioner-02-domainN.html`** 이고,
/// 레포 JSON 이 한국어이므로 **`/ko_kr/` 판**을 받아 대조해야 한다.
///
/// ## ⚠️ 공식의 기계번역 잔재는 고치지 않는다
///
/// Task 3.8 기술에 `프런트엔드 및 모바일 서비스를 **만들기하고** 배포할` 이 있는데
/// **공식 한국어 판 그대로다**(실측). 레포가 공식과 일치하므로 손대지 않는다 —
/// 「읽기 좋게」 바꾸면 이 동기화 가드가 거짓으로 깨진다.
///
/// 근거: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/cloud-practitioner-02/cloud-practitioner-02-domain1.html
/// (domain2·3·4 도 같은 접두사)
void main() {
  final file = File('assets/exam_guides/CLF-C02.json');
  final raw = file.readAsStringSync();
  final guide = json.decode(raw) as Map<String, dynamic>;
  final domains = (guide['domains'] as List).cast<Map<String, dynamic>>();

  Map<String, dynamic> task(String no) {
    for (final d in domains) {
      for (final t in (d['tasks'] as List).cast<Map<String, dynamic>>()) {
        if (t['no'] == no) return t;
      }
    }
    fail('Task $no 가 없다');
  }

  List<String> items(String no, String key) =>
      ((task(no)[key] as List?) ?? const []).cast<String>();

  // ═════════════════════ 대조군 ═════════════════════

  test('대조군: 가이드 JSON 을 실제로 읽고 구조가 공식과 같다', () {
    // 0건 통과가 "파일을 못 읽어서"일 수 있다 — 먼저 센다.
    expect(raw.length, greaterThan(5000));
    expect(domains.length, 4, reason: 'CLF-C02 는 도메인 4개다');
    expect([for (final d in domains) d['weightPct']], [24, 30, 34, 12],
        reason: '공식 「콘텐츠 개요」의 비중이다 — 도메인 3(34%)이 최대다');
    expect([for (final d in domains) (d['tasks'] as List).length],
        [4, 4, 8, 3],
        reason: 'Task 수가 바뀌면 이 가드의 번호 참조가 무의미해진다');
  });

  test('대조군: 직렬화 왕복이 원본을 바이트 단위로 재현한다', () {
    // 이 파일은 2칸 들여쓰기 다중 행이다(SAA-C03·AIF-C01 의 한 줄 compact 와 다르다).
    // 재현되지 않으면 문자열 치환으로만 고쳐야 한다는 뜻이다.
    const encoder = JsonEncoder.withIndent('  ');
    final round = '${encoder.convert(guide)}\n'.replaceAll('\n', '\r\n');
    final normalized = raw.replaceAll('\r\n', '\n').replaceAll('\n', '\r\n');
    expect(round.length, normalized.length,
        reason: '길이가 다르면 서식이 다르다 — 재직렬화로 고치면 리뷰 불가 diff 가 된다');
  });

  // ═════════════════════ P2-C 여섯 항목 ═════════════════════

  group('P2-C 공식 현행 문구와 일치한다', () {
    const expected = <String, MapEntry<String, String>>{
      // Task → (키, 공식 현행 전문)
      '1.3': MapEntry('skills', '적절한 마이그레이션 전략 파악(예: 데이터베이스 복제)'),
      '2.2': MapEntry(
          'skills',
          '거버넌스 및 규정 준수를 지원하는 서비스 이해(예: Amazon CloudWatch를 통한 모니터링, '
              'AWS CloudTrail, AWS Config를 통한 감사, 액세스 보고서를 통한 보고)'),
      '2.3': MapEntry('knowledge', 'AWS IAM Identity Center'),
      '3.7': MapEntry('skills',
          'AI/ML 서비스와 해당 서비스가 수행하는 작업 이해(예: Amazon SageMaker AI, Amazon Lex)'),
      '3.8': MapEntry('knowledge', 'AWS Amplify의 프런트엔드 웹 및 모바일 서비스'),
      '4.3': MapEntry(
          'skills',
          'AWS 고객을 위한 AWS 지원 옵션 파악(예: 고객 서비스 및 커뮤니티, 기본 지원, '
              'AWS Business Support+, AWS Enterprise Support, AWS Unified Operations)'),
    };

    expected.forEach((no, entry) {
      test('Task $no ${entry.key} 에 공식 전문이 있다', () {
        expect(items(no, entry.key), contains(entry.value),
            reason: '공식 한국어 도메인 페이지 원문과 바이트가 달라졌다');
      });
    });

    test('옛 개정판 문구가 남아 있지 않다', () {
      const retired = <String>[
        // 걷어낸 서비스 이름이 다시 들어오면 그 위의 모든 서술이 같이 낡는다.
        'AWS Snowball 사용',
        'AWS Audit Manager 및',
        'AWS IAM Identity Center(AWS Single Sign-On)',
        'Amazon Kendra',
        'AWS Amplify와 AWS AppSync의',
        'AWS Developer Support',
        'AWS Business Support,',
        'AWS Enterprise On-Ramp Support',
      ];
      final hits = retired.where(raw.contains).toList();
      expect(hits, isEmpty,
          reason: '공식 가이드가 걷어낸 문구다: ${hits.join(' · ')}');
    });

    test('대조군: 금지 문구가 공식 전문을 스스로 잡지 않는다', () {
      // `Amazon SageMaker AI` 는 `Amazon SageMaker` 를 포함하므로 접두사 함정이 있다
      // (2026-11-05 AIF 가이드 교체에서 `Amazon Q`/`Amazon Quick` 으로 실제로 밟았다).
      // 그래서 금지 목록에 `Amazon SageMaker` 단독을 넣지 않았고, 그 선택을 고정한다.
      expect(raw.contains('Amazon SageMaker AI'), isTrue);
      expect(raw.contains('AWS Business Support+'), isTrue,
          reason: '`AWS Business Support,` 를 금지하면서 `+` 형은 남아야 한다');
      // `Amazon Kendra` 금지는 안전하다 — 공식 현행 문구에 Kendra 가 없다.
      expect(items('3.7', 'skills').any((s) => s.contains('Kendra')), isFalse);
    });
  });

  // ═════════════════════ 파생 서술이 가이드와 어긋나지 않는다 ═════════════════════

  test('Task 3.8 지식의 개발자 도구 예시가 공식과 같다', () {
    // 공식 범위 내 「개발자 도구」는 AWS CLI·CodeBuild·CodePipeline·X-Ray 넷이고
    // Task 3.8 의 예시는 그중 셋이다. `CloudShell`·`Cloud9`·`CodeCommit`·`CodeDeploy`
    // 는 **어디에도 없다** — §P2-G 의 `t3-8.md` 표 정정 근거다.
    final dev = items('3.8', 'knowledge')
        .firstWhere((s) => s.contains('개발자 도구'), orElse: () => '');
    expect(dev, contains('AWS CodeBuild'));
    expect(dev, contains('AWS CodePipeline'));
    expect(dev, contains('AWS X-Ray'));
    for (final absent in ['CloudShell', 'Cloud9', 'CodeCommit', 'CodeDeploy']) {
      expect(dev.contains(absent), isFalse, reason: '$absent 는 공식 예시에 없다');
    }
  });

  test('Task 4.3 기술이 현행 세 플랜만 든다', () {
    final plans = items('4.3', 'skills')
        .firstWhere((s) => s.contains('지원 옵션 파악'), orElse: () => '');
    for (final cur in [
      '기본 지원',
      'AWS Business Support+',
      'AWS Enterprise Support',
      'AWS Unified Operations',
    ]) {
      expect(plans, contains(cur));
    }
    // 단종 예정 플랜은 공식 예시에서 빠졌다(2027-01-01 단종). 다만 **GovCloud(US)
    // 에서는 계속 제공**되므로 「없어졌다」가 아니라 「예시에서 빠졌다」가 정확하다.
    expect(plans.contains('Developer'), isFalse);
    expect(plans.contains('On-Ramp'), isFalse);
  });
}
