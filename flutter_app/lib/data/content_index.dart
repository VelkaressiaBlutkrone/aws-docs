import 'package:flutter/foundation.dart' show visibleForTesting;

import 'audio_asset_url.dart';
import 'exam_allocation.dart';

/// 어떤 (자격증 → Task)에 검증 콘텐츠가 있는지 정적 인덱스.
/// 새 Task를 추가하면 여기에 한 줄 등록한다(스펙 §14 작성 컨벤션).
class ContentEntry {
  const ContentEntry({
    required this.certCode,
    required this.taskId,
    required this.title,
    required this.domain,
    required this.mdAsset,
    required this.questionsAsset,
    required this.questionCount,
    this.audioApproved = false,
    this.audioSha8,
  });

  final String certCode;
  final String taskId;
  final String title;
  final int domain;
  final String mdAsset;
  final String questionsAsset;
  final int questionCount;

  /// 청취 검수 완료(audio_meta.json reviewStatus=approved)된 오디오 강의 보유 여부.
  /// SSOT는 audio_meta.json — content_index_test의 동기화 테스트가 일치를 강제한다.
  /// study_doc_page가 노출 전 게이트로 검사(approved만 미니플레이어 표시).
  final bool audioApproved;

  /// 승인 오디오의 audio_meta.json `audio.sha256` 앞 8자리. R2 불변 키의 버전 세그먼트.
  /// SSOT는 audio_meta.json — content_index_test 동기화 테스트가 일치를 강제한다.
  /// 재합성(sha 변경) 시 이 값을 갱신하고 publish_audio.py로 새 키를 발행한다.
  final String? audioSha8;

  /// 이력 기록용 자격증 ID(현재는 certCode와 동일).
  String get certForHistory => certCode;

  /// 노출 가능한 검증 문항이 있는가(questions.json 존재 여부와 1:1).
  /// 학습문서만 있는(문항 0) Task의 불필요한 에셋 로드/404를 막는 가드.
  bool get hasQuestions => questionCount > 0;

  /// 합친 강의 mp3 위치.
  /// - 승인(audioSha8 있음): R2 불변 키 `{base}/{family}/{taskId}/{sha8}/lecture.mp3`
  ///   (설계: docs/superpowers/specs/2026-09-03-audio-r2-hosting-design.md).
  /// - 미승인: 기존 번들 규약 `assets/audio/{family}/{taskId}/lecture.mp3`(노출 게이트가
  ///   막고 있어 실제 로드되지 않는 placeholder). family = taskId 접두어.
  String get lectureAudioSrc {
    final family = taskId.split('-').first;
    final sha = audioSha8;
    if (sha != null) return '$kAudioBaseUrl/$family/$taskId/$sha/lecture.mp3';
    return 'assets/audio/$family/$taskId/lecture.mp3';
  }

  /// 오디오 메타(reviewStatus·체크섬) 경로. lectureAudioSrc와 같은 폴더.
  String get lectureAudioMetaSrc =>
      'assets/audio/${taskId.split('-').first}/$taskId/audio_meta.json';
}

/// 통합/약점 모의고사를 열기 위한 정적 readiness 정책.
///
/// [practiceQuestionCount]는 실제 AWS 시험 문항 수를 가장하지 않고, 앱의 65문항
/// 연습 세트에 공식 도메인 비중을 적용하는 기준이다.
class ExamReadinessRequirement {
  const ExamReadinessRequirement({
    required this.practiceQuestionCount,
    required this.weightByDomain,
  });

  final int practiceQuestionCount;
  final Map<int, int> weightByDomain;
}

const Map<String, ExamReadinessRequirement> kExamReadinessRequirements = {
  'CLF-C02': ExamReadinessRequirement(
    practiceQuestionCount: 65,
    weightByDomain: {1: 24, 2: 30, 3: 34, 4: 12},
  ),
  'SAA-C03': ExamReadinessRequirement(
    practiceQuestionCount: 65,
    weightByDomain: {1: 30, 2: 26, 3: 24, 4: 20},
  ),
  // MLA-C01 공식 Task 12개(4도메인 × 3)가 전부 들어온 뒤 추가했다(2026-10-26).
  // 정책이 없으면 `examWeightedCapacityStatus`가 `hasPolicy: false`로 fail closed라
  // 사람이 문항을 전부 flip해도 통합/약점 모의고사가 잠긴 채 남는다.
  // 비중은 공식 시험 가이드의 도메인 가중(28·26·22·24)이다.
  'MLA-C01': ExamReadinessRequirement(
    practiceQuestionCount: 65,
    weightByDomain: {1: 28, 2: 26, 3: 22, 4: 24},
  ),
  // SOA-C03·DEA-C01도 같은 fail closed 함정에 걸려 있었다 — 학습문서와 드래프트
  // 문항은 이미 전부 들어와 있는데 정책이 없어, 사람이 검수해 flip해도 모의고사가
  // 영원히 잠긴 채 남았다(2026-10-27 추가). 정책 추가는 공개가 아니다: verified가
  // 0인 동안은 전 도메인이 부족해 게이트가 그대로 잠겨 있다.
  //
  // ⚠️ SOA-C03은 도메인이 **5개**다(공식명 CloudOps Engineer, 가이드 v1.1).
  // 비중 22·22·22·16·18 → 65문항 배분은 14·14·14·11·12.
  'SOA-C03': ExamReadinessRequirement(
    practiceQuestionCount: 65,
    weightByDomain: {1: 22, 2: 22, 3: 22, 4: 16, 5: 18},
  ),
  // DEA-C01 공식 비중 34·26·22·18 → 65문항 배분은 22·17·14·12.
  'DEA-C01': ExamReadinessRequirement(
    practiceQuestionCount: 65,
    weightByDomain: {1: 34, 2: 26, 3: 22, 4: 18},
  ),
};

class ExamReadinessStatus {
  const ExamReadinessStatus({
    required this.certCode,
    required this.hasPolicy,
    required this.practiceQuestionCount,
    required this.requiredByDomain,
    required this.availableByDomain,
    required this.deficitByDomain,
  });

  final String certCode;
  final bool hasPolicy;
  final int practiceQuestionCount;
  final Map<int, int> requiredByDomain;
  final Map<int, int> availableByDomain;
  final Map<int, int> deficitByDomain;

  bool get ready => hasPolicy && deficitByDomain.isEmpty;

  String get domainProgressLabel {
    if (requiredByDomain.isEmpty) return '';
    final keys = requiredByDomain.keys.toList()..sort();
    return keys
        .map(
          (d) => 'D$d ${availableByDomain[d] ?? 0}/${requiredByDomain[d] ?? 0}',
        )
        .join(' · ');
  }
}

const Map<String, List<ContentEntry>> kContentIndex = {
  'CLF-C02': [
    ContentEntry(
      certCode: 'CLF-C02',
      taskId: 'clf-t1-1',
      title: 'AWS 클라우드의 이점',
      domain: 1,
      mdAsset: 'assets/content/clf/t1-1.md',
      questionsAsset: 'assets/content/clf/t1-1.questions.json',
      questionCount: 15,
      audioApproved: true,
      audioSha8: 'f2433088',
    ),
    ContentEntry(
      certCode: 'CLF-C02',
      taskId: 'clf-t1-2',
      title: 'Well-Architected Framework (6대 기둥)',
      domain: 1,
      mdAsset: 'assets/content/clf/t1-2.md',
      questionsAsset: 'assets/content/clf/t1-2.questions.json',
      questionCount: 15,
      audioApproved: true,
      audioSha8: '52b97a4d',
    ),
    ContentEntry(
      certCode: 'CLF-C02',
      taskId: 'clf-t1-3',
      title: '클라우드 마이그레이션과 AWS CAF',
      domain: 1,
      mdAsset: 'assets/content/clf/t1-3.md',
      questionsAsset: 'assets/content/clf/t1-3.questions.json',
      questionCount: 15,
      audioApproved: true,
      audioSha8: '6a26ccb0',
    ),
    ContentEntry(
      certCode: 'CLF-C02',
      taskId: 'clf-t1-4',
      title: '클라우드 경제학 (비용·rightsizing·관리형)',
      domain: 1,
      mdAsset: 'assets/content/clf/t1-4.md',
      questionsAsset: 'assets/content/clf/t1-4.questions.json',
      questionCount: 15,
      audioApproved: true,
      audioSha8: 'b8be2740',
    ),
    ContentEntry(
      certCode: 'CLF-C02',
      taskId: 'clf-t2-1',
      title: '공동 책임 모델',
      domain: 2,
      mdAsset: 'assets/content/clf/t2-1.md',
      questionsAsset: 'assets/content/clf/t2-1.questions.json',
      questionCount: 15,
      audioApproved: true, // 2026-07 AR-2 사실정정 재합성 — 청취 재승인 전 비노출
      audioSha8: '2f9c997f',
    ),
    ContentEntry(
      certCode: 'CLF-C02',
      taskId: 'clf-t2-2',
      title: '보안·거버넌스·컴플라이언스',
      domain: 2,
      mdAsset: 'assets/content/clf/t2-2.md',
      questionsAsset: 'assets/content/clf/t2-2.questions.json',
      questionCount: 18,
      audioApproved: true,
      audioSha8: 'abf58061',
    ),
    ContentEntry(
      certCode: 'CLF-C02',
      taskId: 'clf-t2-3',
      title: '접근 관리 (IAM)',
      domain: 2,
      mdAsset: 'assets/content/clf/t2-3.md',
      questionsAsset: 'assets/content/clf/t2-3.questions.json',
      questionCount: 18,
      audioApproved: true, // 2026-07 AR-2 사실정정 재합성 — 청취 재승인 전 비노출
      audioSha8: 'd0945e0c',
    ),
    ContentEntry(
      certCode: 'CLF-C02',
      taskId: 'clf-t2-4',
      title: '보안 구성요소·리소스',
      domain: 2,
      mdAsset: 'assets/content/clf/t2-4.md',
      questionsAsset: 'assets/content/clf/t2-4.questions.json',
      questionCount: 15,
      audioApproved: true,
      audioSha8: 'd36f5aec',
    ),
    ContentEntry(
      certCode: 'CLF-C02',
      taskId: 'clf-t3-1',
      title: '배포·운영 방법 (콘솔·CLI·SDK·IaC)',
      domain: 3,
      mdAsset: 'assets/content/clf/t3-1.md',
      questionsAsset: 'assets/content/clf/t3-1.questions.json',
      questionCount: 19,
      audioApproved: true,
      audioSha8: '8a553ecc',
    ),
    ContentEntry(
      certCode: 'CLF-C02',
      taskId: 'clf-t3-2',
      title: '글로벌 인프라 (리전·AZ·엣지)',
      domain: 3,
      mdAsset: 'assets/content/clf/t3-2.md',
      questionsAsset: 'assets/content/clf/t3-2.questions.json',
      questionCount: 15,
      audioApproved: true,
      audioSha8: '987f9f07',
    ),
    ContentEntry(
      certCode: 'CLF-C02',
      taskId: 'clf-t3-3',
      title: '컴퓨팅 서비스 (EC2·컨테이너·서버리스)',
      domain: 3,
      mdAsset: 'assets/content/clf/t3-3.md',
      questionsAsset: 'assets/content/clf/t3-3.questions.json',
      questionCount: 16,
      audioApproved: true,
      audioSha8: '5ec02d34',
    ),
    ContentEntry(
      certCode: 'CLF-C02',
      taskId: 'clf-t3-4',
      title: '데이터베이스 서비스 (관계형·NoSQL·인메모리)',
      domain: 3,
      mdAsset: 'assets/content/clf/t3-4.md',
      questionsAsset: 'assets/content/clf/t3-4.questions.json',
      questionCount: 15,
      audioApproved: true, // 2026-07 AR-2 사실정정 재합성 — 청취 재승인 전 비노출
      audioSha8: '2782b2a7',
    ),
    ContentEntry(
      certCode: 'CLF-C02',
      taskId: 'clf-t3-5',
      title: '네트워크 서비스 (VPC·Route 53·연결)',
      domain: 3,
      mdAsset: 'assets/content/clf/t3-5.md',
      questionsAsset: 'assets/content/clf/t3-5.questions.json',
      questionCount: 17,
      audioApproved: true,
      audioSha8: '39e8e08b',
    ),
    ContentEntry(
      certCode: 'CLF-C02',
      taskId: 'clf-t3-6',
      title: '스토리지 서비스 (객체·블록·파일)',
      domain: 3,
      mdAsset: 'assets/content/clf/t3-6.md',
      questionsAsset: 'assets/content/clf/t3-6.questions.json',
      questionCount: 15,
      audioApproved: true, // 2026-07 AR-2 사실정정 재합성 — 청취 재승인 전 비노출
      audioSha8: '3429c791',
    ),
    ContentEntry(
      certCode: 'CLF-C02',
      taskId: 'clf-t3-7',
      title: 'AI/ML·분석 서비스',
      domain: 3,
      mdAsset: 'assets/content/clf/t3-7.md',
      questionsAsset: 'assets/content/clf/t3-7.questions.json',
      questionCount: 17,
      audioApproved: true,
      audioSha8: 'a1f7b60c',
    ),
    ContentEntry(
      certCode: 'CLF-C02',
      taskId: 'clf-t3-8',
      title: '기타 범위 내 서비스 (메시징·EUC·IoT)',
      domain: 3,
      mdAsset: 'assets/content/clf/t3-8.md',
      questionsAsset: 'assets/content/clf/t3-8.questions.json',
      questionCount: 16,
      audioApproved: true, // 2026-07 AR-2 사실정정 재합성 — 청취 재승인 전 비노출
      audioSha8: 'dc43492d',
    ),
    ContentEntry(
      certCode: 'CLF-C02',
      taskId: 'clf-t4-1',
      title: '요금 모델 (구매 옵션·데이터 전송·스토리지)',
      domain: 4,
      mdAsset: 'assets/content/clf/t4-1.md',
      questionsAsset: 'assets/content/clf/t4-1.questions.json',
      questionCount: 15,
      audioApproved: true, // 2026-07 AR-2 사실정정 재합성 — 청취 재승인 전 비노출
      audioSha8: '4855ab76',
    ),
    ContentEntry(
      certCode: 'CLF-C02',
      taskId: 'clf-t4-2',
      title: '결제·예산·비용 관리 도구',
      domain: 4,
      mdAsset: 'assets/content/clf/t4-2.md',
      questionsAsset: 'assets/content/clf/t4-2.questions.json',
      questionCount: 15,
      audioApproved: true,
      audioSha8: 'd10423fd',
    ),
    ContentEntry(
      certCode: 'CLF-C02',
      taskId: 'clf-t4-3',
      title: '기술 리소스와 Support 플랜',
      domain: 4,
      mdAsset: 'assets/content/clf/t4-3.md',
      questionsAsset: 'assets/content/clf/t4-3.questions.json',
      questionCount: 15,
      // 2026-07 사실 정정 후 재합성 — 청취 재승인 전까지 비노출
      // (audio_meta.reviewStatus=needs_human_review와 동기화).
      audioApproved: true,
      audioSha8: '9aa15b47',
    ),
  ],
  'SAA-C03': [
    ContentEntry(
      certCode: 'SAA-C03',
      taskId: 'saa-t1-1',
      title: 'IAM — 자격증명·권한·페더레이션',
      domain: 1,
      mdAsset: 'assets/content/saa/saa-t1-1.md',
      questionsAsset: 'assets/content/saa/saa-t1-1.questions.json',
      questionCount: 15,
      audioApproved: true,
      audioSha8: '1e6f1170',
    ),
    ContentEntry(
      certCode: 'SAA-C03',
      taskId: 'saa-t1-2',
      title: '다중 계정 보안 — Organizations·Control Tower·SCP',
      domain: 1,
      mdAsset: 'assets/content/saa/saa-t1-2.md',
      questionsAsset: 'assets/content/saa/saa-t1-2.questions.json',
      questionCount: 15,
      audioApproved: true,
      audioSha8: '39fc6341',
    ),
    ContentEntry(
      certCode: 'SAA-C03',
      taskId: 'saa-t1-3',
      title: 'VPC 보안 네트워크 — 서브넷·SG·NACL·NAT·엔드포인트',
      domain: 1,
      mdAsset: 'assets/content/saa/saa-t1-3.md',
      questionsAsset: 'assets/content/saa/saa-t1-3.questions.json',
      questionCount: 15,
      audioApproved: true,
      audioSha8: '299aaa9c',
    ),
    ContentEntry(
      certCode: 'SAA-C03',
      taskId: 'saa-t1-4',
      title: '애플리케이션 보안 — Shield·WAF·Cognito·Secrets Manager',
      domain: 1,
      mdAsset: 'assets/content/saa/saa-t1-4.md',
      questionsAsset: 'assets/content/saa/saa-t1-4.questions.json',
      questionCount: 15,
      audioApproved: true,
      audioSha8: '2a87352e',
    ),
    ContentEntry(
      certCode: 'SAA-C03',
      taskId: 'saa-t1-5',
      title: '데이터 보안 제어 — KMS·CloudHSM·ACM·백업·거버넌스',
      domain: 1,
      mdAsset: 'assets/content/saa/saa-t1-5.md',
      questionsAsset: 'assets/content/saa/saa-t1-5.questions.json',
      questionCount: 15,
      audioApproved: true,
      audioSha8: 'fc4cae46',
    ),
    ContentEntry(
      certCode: 'SAA-C03',
      taskId: 'saa-t2-1',
      title: '느슨한 결합 아키텍처 — SQS·SNS·EventBridge·Step Functions',
      domain: 2,
      mdAsset: 'assets/content/saa/saa-t2-1.md',
      questionsAsset: 'assets/content/saa/saa-t2-1.questions.json',
      questionCount: 15,
      audioApproved: true,
      audioSha8: 'e85822df',
    ),
    ContentEntry(
      certCode: 'SAA-C03',
      taskId: 'saa-t2-2',
      title: '서버리스 패턴 — Lambda·API Gateway·Fargate·ECS/EKS',
      domain: 2,
      mdAsset: 'assets/content/saa/saa-t2-2.md',
      questionsAsset: 'assets/content/saa/saa-t2-2.questions.json',
      questionCount: 15,
      audioApproved: true,
      audioSha8: '81c561a0',
    ),
    ContentEntry(
      certCode: 'SAA-C03',
      taskId: 'saa-t2-3',
      title: 'ELB + Auto Scaling — 탄력적 확장 설계',
      domain: 2,
      mdAsset: 'assets/content/saa/saa-t2-3.md',
      questionsAsset: 'assets/content/saa/saa-t2-3.questions.json',
      questionCount: 15,
      audioApproved: true,
      audioSha8: '4e6410b1',
    ),
    ContentEntry(
      certCode: 'SAA-C03',
      taskId: 'saa-t2-4',
      title: '고가용성 패턴 — Multi-AZ·단일 실패점 제거',
      domain: 2,
      mdAsset: 'assets/content/saa/saa-t2-4.md',
      questionsAsset: 'assets/content/saa/saa-t2-4.questions.json',
      questionCount: 15,
      audioApproved: true,
      audioSha8: '5dad5838',
    ),
    ContentEntry(
      certCode: 'SAA-C03',
      taskId: 'saa-t2-5',
      title: 'DR 전략 — RTO·RPO·Pilot Light·Warm Standby·Active-Active',
      domain: 2,
      mdAsset: 'assets/content/saa/saa-t2-5.md',
      questionsAsset: 'assets/content/saa/saa-t2-5.questions.json',
      questionCount: 15,
      audioApproved: true,
      audioSha8: '51430c09',
    ),
    ContentEntry(
      certCode: 'SAA-C03',
      taskId: 'saa-t3-1',
      title: 'S3 스토리지 성능 — 스토리지 클래스·수명주기·접근 제어',
      domain: 3,
      mdAsset: 'assets/content/saa/saa-t3-1.md',
      questionsAsset: 'assets/content/saa/saa-t3-1.questions.json',
      questionCount: 15,
      audioApproved: true,
      audioSha8: 'e4735d54',
    ),
    ContentEntry(
      certCode: 'SAA-C03',
      taskId: 'saa-t3-2',
      title: '블록·파일 스토리지 — EBS 볼륨 타입·EFS·FSx 선택',
      domain: 3,
      mdAsset: 'assets/content/saa/saa-t3-2.md',
      questionsAsset: 'assets/content/saa/saa-t3-2.questions.json',
      questionCount: 15,
      audioApproved: true,
      audioSha8: '82066b45',
    ),
    ContentEntry(
      certCode: 'SAA-C03',
      taskId: 'saa-t3-3',
      title: 'EC2 컴퓨팅 성능 — 인스턴스 패밀리·구매 옵션·배치 전략',
      domain: 3,
      mdAsset: 'assets/content/saa/saa-t3-3.md',
      questionsAsset: 'assets/content/saa/saa-t3-3.questions.json',
      questionCount: 15,
      audioApproved: true,
      audioSha8: 'e8787eae',
    ),
    ContentEntry(
      certCode: 'SAA-C03',
      taskId: 'saa-t3-4',
      title: '컨테이너·서버리스·배치 컴퓨팅 선택',
      domain: 3,
      mdAsset: 'assets/content/saa/saa-t3-4.md',
      questionsAsset: 'assets/content/saa/saa-t3-4.questions.json',
      questionCount: 15,
      audioApproved: true,
      audioSha8: 'fb29bb91',
    ),
    ContentEntry(
      certCode: 'SAA-C03',
      taskId: 'saa-t3-5',
      title: 'RDS·Aurora 고성능 — Multi-AZ·Read Replica·프록시',
      domain: 3,
      mdAsset: 'assets/content/saa/saa-t3-5.md',
      questionsAsset: 'assets/content/saa/saa-t3-5.questions.json',
      questionCount: 15,
      audioApproved: true,
      audioSha8: 'b0a8e6a1',
    ),
    ContentEntry(
      certCode: 'SAA-C03',
      taskId: 'saa-t3-6',
      title: 'DynamoDB·ElastiCache — NoSQL 성능·캐싱 전략',
      domain: 3,
      mdAsset: 'assets/content/saa/saa-t3-6.md',
      questionsAsset: 'assets/content/saa/saa-t3-6.questions.json',
      questionCount: 15,
      audioApproved: true,
      audioSha8: '6b66bc50',
    ),
    ContentEntry(
      certCode: 'SAA-C03',
      taskId: 'saa-t3-7',
      title: '네트워크 성능 — Route 53·CloudFront·Global Accelerator·로드밸런서',
      domain: 3,
      mdAsset: 'assets/content/saa/saa-t3-7.md',
      questionsAsset: 'assets/content/saa/saa-t3-7.questions.json',
      questionCount: 15,
      audioApproved: true,
      audioSha8: '64aca139',
    ),
    ContentEntry(
      certCode: 'SAA-C03',
      taskId: 'saa-t3-8',
      title: '하이브리드 네트워크 — VPC 심화·VPN·Direct Connect·PrivateLink',
      domain: 3,
      mdAsset: 'assets/content/saa/saa-t3-8.md',
      questionsAsset: 'assets/content/saa/saa-t3-8.questions.json',
      questionCount: 15,
      audioApproved: true,
      audioSha8: '19402f50',
    ),
    ContentEntry(
      certCode: 'SAA-C03',
      taskId: 'saa-t3-9',
      title: '데이터 수집·변환·분석 — Kinesis·Glue·Athena·EMR·Lake Formation',
      domain: 3,
      mdAsset: 'assets/content/saa/saa-t3-9.md',
      questionsAsset: 'assets/content/saa/saa-t3-9.questions.json',
      questionCount: 15,
      audioApproved: true,
      audioSha8: '0374ca20',
    ),
    ContentEntry(
      certCode: 'SAA-C03',
      taskId: 'saa-t4-1',
      title: '비용 최적화 스토리지 — S3 티어링·EBS 선택·수명주기·전송 비용',
      domain: 4,
      mdAsset: 'assets/content/saa/saa-t4-1.md',
      questionsAsset: 'assets/content/saa/saa-t4-1.questions.json',
      questionCount: 15,
      audioApproved: true,
      audioSha8: '3c55e2fd',
    ),
    ContentEntry(
      certCode: 'SAA-C03',
      taskId: 'saa-t4-2',
      title: '비용 최적화 컴퓨팅 — Savings Plans·RI·Spot·오토스케일링·rightsizing',
      domain: 4,
      mdAsset: 'assets/content/saa/saa-t4-2.md',
      questionsAsset: 'assets/content/saa/saa-t4-2.questions.json',
      questionCount: 15,
    ),
    ContentEntry(
      certCode: 'SAA-C03',
      taskId: 'saa-t4-3',
      title: '비용 최적화 데이터베이스 — DB 서비스 선택·용량 계획·서버리스 옵션',
      domain: 4,
      mdAsset: 'assets/content/saa/saa-t4-3.md',
      questionsAsset: 'assets/content/saa/saa-t4-3.questions.json',
      questionCount: 15,
    ),
    ContentEntry(
      certCode: 'SAA-C03',
      taskId: 'saa-t4-4',
      title: '비용 최적화 네트워크 — NAT 전략·전송 비용·CDN·피어링·PrivateLink',
      domain: 4,
      mdAsset: 'assets/content/saa/saa-t4-4.md',
      questionsAsset: 'assets/content/saa/saa-t4-4.questions.json',
      questionCount: 15,
    ),
    ContentEntry(
      certCode: 'SAA-C03',
      taskId: 'saa-t4-5',
      title: '비용 관리 도구 — Cost Explorer·Budgets·CUR·태그·Well-Architected',
      domain: 4,
      mdAsset: 'assets/content/saa/saa-t4-5.md',
      questionsAsset: 'assets/content/saa/saa-t4-5.questions.json',
      questionCount: 15,
    ),
  ],
  'SOA-C03': [
    ContentEntry(certCode: 'SOA-C03', taskId: 'soa-t1-1', title: 'CloudWatch 지표·경보·대시보드', domain: 1, mdAsset: 'assets/content/soa/soa-t1-1.md', questionsAsset: 'assets/content/soa/soa-t1-1.questions.json', questionCount: 0),
    ContentEntry(certCode: 'SOA-C03', taskId: 'soa-t1-2', title: 'CloudWatch Logs·Logs Insights·구독 필터·에이전트', domain: 1, mdAsset: 'assets/content/soa/soa-t1-2.md', questionsAsset: 'assets/content/soa/soa-t1-2.questions.json', questionCount: 0),
    ContentEntry(certCode: 'SOA-C03', taskId: 'soa-t1-3', title: 'CloudTrail·EventBridge·X-Ray (감사·이벤트·추적)', domain: 1, mdAsset: 'assets/content/soa/soa-t1-3.md', questionsAsset: 'assets/content/soa/soa-t1-3.questions.json', questionCount: 0),
    ContentEntry(certCode: 'SOA-C03', taskId: 'soa-t1-4', title: '가용성 지표 기반 문제 식별·해결 (Health Dashboard)', domain: 1, mdAsset: 'assets/content/soa/soa-t1-4.md', questionsAsset: 'assets/content/soa/soa-t1-4.questions.json', questionCount: 0),
    ContentEntry(certCode: 'SOA-C03', taskId: 'soa-t1-5', title: '컴퓨팅·스토리지·DB 성능 최적화 (EC2·EBS·RDS·ElastiCache)', domain: 1, mdAsset: 'assets/content/soa/soa-t1-5.md', questionsAsset: 'assets/content/soa/soa-t1-5.questions.json', questionCount: 0),
    ContentEntry(certCode: 'SOA-C03', taskId: 'soa-t2-1', title: 'Auto Scaling·ELB로 확장성·탄력성 구현', domain: 2, mdAsset: 'assets/content/soa/soa-t2-1.md', questionsAsset: 'assets/content/soa/soa-t2-1.questions.json', questionCount: 0),
    ContentEntry(certCode: 'SOA-C03', taskId: 'soa-t2-2', title: 'Multi-AZ·고가용성·복원력 설계', domain: 2, mdAsset: 'assets/content/soa/soa-t2-2.md', questionsAsset: 'assets/content/soa/soa-t2-2.questions.json', questionCount: 0),
    ContentEntry(certCode: 'SOA-C03', taskId: 'soa-t2-3', title: '백업·복원 전략 (AWS Backup·스냅샷·수명주기)', domain: 2, mdAsset: 'assets/content/soa/soa-t2-3.md', questionsAsset: 'assets/content/soa/soa-t2-3.questions.json', questionCount: 0),
    ContentEntry(certCode: 'SOA-C03', taskId: 'soa-t2-4', title: 'DR·데이터 복원력 (RTO/RPO·S3 복제)', domain: 2, mdAsset: 'assets/content/soa/soa-t2-4.md', questionsAsset: 'assets/content/soa/soa-t2-4.questions.json', questionCount: 0),
    ContentEntry(certCode: 'SOA-C03', taskId: 'soa-t3-1', title: 'CloudFormation 프로비저닝 (템플릿·스택·StackSets·드리프트)', domain: 3, mdAsset: 'assets/content/soa/soa-t3-1.md', questionsAsset: 'assets/content/soa/soa-t3-1.questions.json', questionCount: 0),
    ContentEntry(certCode: 'SOA-C03', taskId: 'soa-t3-2', title: 'AMI·리소스 배포·유지 관리·패치 전략', domain: 3, mdAsset: 'assets/content/soa/soa-t3-2.md', questionsAsset: 'assets/content/soa/soa-t3-2.questions.json', questionCount: 0),
    ContentEntry(certCode: 'SOA-C03', taskId: 'soa-t3-3', title: 'Systems Manager 운영 자동화 (Run Command·Patch·State Manager·Parameter Store)', domain: 3, mdAsset: 'assets/content/soa/soa-t3-3.md', questionsAsset: 'assets/content/soa/soa-t3-3.questions.json', questionCount: 0),
    ContentEntry(certCode: 'SOA-C03', taskId: 'soa-t3-4', title: '자동화 패턴 (EventBridge·Lambda·자동 복구)', domain: 3, mdAsset: 'assets/content/soa/soa-t3-4.md', questionsAsset: 'assets/content/soa/soa-t3-4.questions.json', questionCount: 0),
    ContentEntry(certCode: 'SOA-C03', taskId: 'soa-t4-1', title: 'IAM·계정 보안 운영 (정책·역할·MFA·자격증명 보고서)', domain: 4, mdAsset: 'assets/content/soa/soa-t4-1.md', questionsAsset: 'assets/content/soa/soa-t4-1.questions.json', questionCount: 0),
    ContentEntry(certCode: 'SOA-C03', taskId: 'soa-t4-2', title: '규정 준수·거버넌스 (Config·Security Hub·GuardDuty·Inspector)', domain: 4, mdAsset: 'assets/content/soa/soa-t4-2.md', questionsAsset: 'assets/content/soa/soa-t4-2.questions.json', questionCount: 0),
    ContentEntry(certCode: 'SOA-C03', taskId: 'soa-t4-3', title: '데이터·인프라 보호 (KMS·암호화·Secrets Manager·ACM)', domain: 4, mdAsset: 'assets/content/soa/soa-t4-3.md', questionsAsset: 'assets/content/soa/soa-t4-3.questions.json', questionCount: 0),
    ContentEntry(certCode: 'SOA-C03', taskId: 'soa-t5-1', title: 'VPC 네트워킹 구현 (서브넷·라우팅·SG·NACL·NAT)', domain: 5, mdAsset: 'assets/content/soa/soa-t5-1.md', questionsAsset: 'assets/content/soa/soa-t5-1.questions.json', questionCount: 0),
    ContentEntry(certCode: 'SOA-C03', taskId: 'soa-t5-2', title: '하이브리드·연결 (피어링·TGW·VPN·Direct Connect·엔드포인트)', domain: 5, mdAsset: 'assets/content/soa/soa-t5-2.md', questionsAsset: 'assets/content/soa/soa-t5-2.questions.json', questionCount: 0),
    ContentEntry(certCode: 'SOA-C03', taskId: 'soa-t5-3', title: 'Route 53 DNS·CloudFront 콘텐츠 전송', domain: 5, mdAsset: 'assets/content/soa/soa-t5-3.md', questionsAsset: 'assets/content/soa/soa-t5-3.questions.json', questionCount: 0),
    ContentEntry(certCode: 'SOA-C03', taskId: 'soa-t5-4', title: '네트워크 문제 해결 (Flow Logs·Reachability Analyzer)', domain: 5, mdAsset: 'assets/content/soa/soa-t5-4.md', questionsAsset: 'assets/content/soa/soa-t5-4.questions.json', questionCount: 0),
  ],
  // DEA-C01: 도메인 1(데이터 수집 및 변환, 34%)·도메인 2(데이터 스토어 관리, 26%)·
  // 도메인 3(데이터 운영 및 지원, 22%)·도메인 4(데이터 보안 및 거버넌스, 18%)를
  // 배치별로 누적 등록한다.
  // 문항은 사람 검수 전 드래프트(verified:false)라 questionCount는 0이다.
  'DEA-C01': [
    ContentEntry(certCode: 'DEA-C01', taskId: 'dea-t1-1', title: '데이터 수집 수행 (스트리밍·배치·트리거)', domain: 1, mdAsset: 'assets/content/dea/dea-t1-1.md', questionsAsset: 'assets/content/dea/dea-t1-1.questions.json', questionCount: 16),
    ContentEntry(certCode: 'DEA-C01', taskId: 'dea-t1-2', title: '데이터 변환 및 처리 (엔진 선택·비용·형식)', domain: 1, mdAsset: 'assets/content/dea/dea-t1-2.md', questionsAsset: 'assets/content/dea/dea-t1-2.questions.json', questionCount: 15),
    ContentEntry(certCode: 'DEA-C01', taskId: 'dea-t1-3', title: '데이터 파이프라인 오케스트레이션 (워크플로·복원력·알림)', domain: 1, mdAsset: 'assets/content/dea/dea-t1-3.md', questionsAsset: 'assets/content/dea/dea-t1-3.questions.json', questionCount: 15),
    ContentEntry(certCode: 'DEA-C01', taskId: 'dea-t1-4', title: '프로그래밍 개념 (코드 최적화·Lambda·IaC·CI/CD)', domain: 1, mdAsset: 'assets/content/dea/dea-t1-4.md', questionsAsset: 'assets/content/dea/dea-t1-4.questions.json', questionCount: 15),
    ContentEntry(certCode: 'DEA-C01', taskId: 'dea-t2-1', title: '데이터 스토어 선택 (분석·NoSQL·스트림·벡터·잠금)', domain: 2, mdAsset: 'assets/content/dea/dea-t2-1.md', questionsAsset: 'assets/content/dea/dea-t2-1.questions.json', questionCount: 15),
    ContentEntry(certCode: 'DEA-C01', taskId: 'dea-t2-2', title: '데이터 카탈로그 시스템 (Glue Data Catalog·크롤러·파티션·SageMaker Catalog)', domain: 2, mdAsset: 'assets/content/dea/dea-t2-2.md', questionsAsset: 'assets/content/dea/dea-t2-2.questions.json', questionCount: 15),
    ContentEntry(certCode: 'DEA-C01', taskId: 'dea-t2-3', title: '데이터 수명 주기 관리 (COPY/UNLOAD·S3 수명 주기·보존·복원성)', domain: 2, mdAsset: 'assets/content/dea/dea-t2-3.md', questionsAsset: 'assets/content/dea/dea-t2-3.questions.json', questionCount: 15),
    ContentEntry(certCode: 'DEA-C01', taskId: 'dea-t2-4', title: '데이터 모델·스키마 진화 설계 (테이블 설계·스키마 변환·계보·벡터화)', domain: 2, mdAsset: 'assets/content/dea/dea-t2-4.md', questionsAsset: 'assets/content/dea/dea-t2-4.questions.json', questionCount: 15),
    ContentEntry(certCode: 'DEA-C01', taskId: 'dea-t3-1', title: '데이터 처리 자동화 (MWAA·Step Functions·SDK·Lambda·EventBridge)', domain: 3, mdAsset: 'assets/content/dea/dea-t3-1.md', questionsAsset: 'assets/content/dea/dea-t3-1.questions.json', questionCount: 15),
    ContentEntry(certCode: 'DEA-C01', taskId: 'dea-t3-2', title: '데이터 분석 (시각화·정리·뷰·Spark 노트북·SQL 집계)', domain: 3, mdAsset: 'assets/content/dea/dea-t3-2.md', questionsAsset: 'assets/content/dea/dea-t3-2.questions.json', questionCount: 15),
    ContentEntry(certCode: 'DEA-C01', taskId: 'dea-t3-3', title: '파이프라인 유지 관리·모니터링 (로그·알림·성능·CloudTrail)', domain: 3, mdAsset: 'assets/content/dea/dea-t3-3.md', questionsAsset: 'assets/content/dea/dea-t3-3.questions.json', questionCount: 15),
    ContentEntry(certCode: 'DEA-C01', taskId: 'dea-t3-4', title: '데이터 품질 보장 (Glue DQ·DataBrew 규칙·샘플링·스큐)', domain: 3, mdAsset: 'assets/content/dea/dea-t3-4.md', questionsAsset: 'assets/content/dea/dea-t3-4.questions.json', questionCount: 15),
    ContentEntry(certCode: 'DEA-C01', taskId: 'dea-t4-1', title: '인증 메커니즘 적용 (보안 그룹·IAM 역할·VPC 엔드포인트·Secrets Manager)', domain: 4, mdAsset: 'assets/content/dea/dea-t4-1.md', questionsAsset: 'assets/content/dea/dea-t4-1.questions.json', questionCount: 15),
    ContentEntry(certCode: 'DEA-C01', taskId: 'dea-t4-2', title: '권한 부여 메커니즘 적용 (사용자 지정 정책·Lake Formation·RBAC/ABAC·최소 권한)', domain: 4, mdAsset: 'assets/content/dea/dea-t4-2.md', questionsAsset: 'assets/content/dea/dea-t4-2.questions.json', questionCount: 15),
    ContentEntry(certCode: 'DEA-C01', taskId: 'dea-t4-3', title: '데이터 암호화·마스킹 보장 (DDM·KMS·S3 SSE·교차 계정·전송 중/전)', domain: 4, mdAsset: 'assets/content/dea/dea-t4-3.md', questionsAsset: 'assets/content/dea/dea-t4-3.questions.json', questionCount: 15),
    ContentEntry(certCode: 'DEA-C01', taskId: 'dea-t4-4', title: '감사용 로그 준비 (CloudTrail·CloudWatch Logs·Lake·로그 분석)', domain: 4, mdAsset: 'assets/content/dea/dea-t4-4.md', questionsAsset: 'assets/content/dea/dea-t4-4.questions.json', questionCount: 0),
    ContentEntry(certCode: 'DEA-C01', taskId: 'dea-t4-5', title: '데이터 프라이버시·거버넌스 (Redshift 공유·Macie·리전 통제·Config·주권)', domain: 4, mdAsset: 'assets/content/dea/dea-t4-5.md', questionsAsset: 'assets/content/dea/dea-t4-5.questions.json', questionCount: 0),
  ],
  // MLA-C01: 공식 Task 12개(4도메인 × 3)를 도메인 배치별로 누적 등록한다.
  // 도메인 1(ML을 위한 데이터 준비, 28%)·2(ML 모델 개발, 26%)·
  // 3(ML 워크플로의 배포 및 오케스트레이션, 22%)·4(모니터링·유지 관리·보안, 24%).
  // 문항은 사람 검수 전 드래프트(verified:false)라 questionCount는 0이다.
  'MLA-C01': [
    ContentEntry(certCode: 'MLA-C01', taskId: 'mla-t1-1', title: '데이터 수집·저장 (형식·스트리밍·스토리지·학습 입력 모드)', domain: 1, mdAsset: 'assets/content/mla/mla-t1-1.md', questionsAsset: 'assets/content/mla/mla-t1-1.questions.json', questionCount: 22),
    ContentEntry(certCode: 'MLA-C01', taskId: 'mla-t1-2', title: '데이터 변환·특성 추출 (정리·인코딩·도구 선택·Feature Store)', domain: 1, mdAsset: 'assets/content/mla/mla-t1-2.md', questionsAsset: 'assets/content/mla/mla-t1-2.questions.json', questionCount: 23),
    ContentEntry(certCode: 'MLA-C01', taskId: 'mla-t1-3', title: '데이터 무결성·편향 관리 (지표·불균형·암호화·민감정보·품질)', domain: 1, mdAsset: 'assets/content/mla/mla-t1-3.md', questionsAsset: 'assets/content/mla/mla-t1-3.questions.json', questionCount: 24),
    ContentEntry(certCode: 'MLA-C01', taskId: 'mla-t2-1', title: '모델링 접근 방식 선택 (선택 사다리·내장 알고리즘·AI 서비스·해석 가능성·비용)', domain: 2, mdAsset: 'assets/content/mla/mla-t2-1.md', questionsAsset: 'assets/content/mla/mla-t2-1.questions.json', questionCount: 23),
    ContentEntry(certCode: 'MLA-C01', taskId: 'mla-t2-2', title: '모델 훈련·개선 (분산·조기 중지·정규화·AMT·파인튜닝·Model Registry)', domain: 2, mdAsset: 'assets/content/mla/mla-t2-2.md', questionsAsset: 'assets/content/mla/mla-t2-2.questions.json', questionCount: 28),
    ContentEntry(certCode: 'MLA-C01', taskId: 'mla-t2-3', title: '모델 성능 분석 (지표·기준선·수렴 진단·Clarify 편향·SHAP·섀도 테스트)', domain: 2, mdAsset: 'assets/content/mla/mla-t2-3.md', questionsAsset: 'assets/content/mla/mla-t2-3.questions.json', questionCount: 27),
    ContentEntry(certCode: 'MLA-C01', taskId: 'mla-t3-1', title: '배포 인프라 선택 (추론 옵션 4종·다중 모델·가드레일·컴퓨팅·컨테이너·엣지)', domain: 3, mdAsset: 'assets/content/mla/mla-t3-1.md', questionsAsset: 'assets/content/mla/mla-t3-1.questions.json', questionCount: 25),
    ContentEntry(certCode: 'MLA-C01', taskId: 'mla-t3-2', title: '인프라 생성·스크립팅 (오토 스케일링·용량 모델·IaC·컨테이너 운영·VPC)', domain: 3, mdAsset: 'assets/content/mla/mla-t3-2.md', questionsAsset: 'assets/content/mla/mla-t3-2.questions.json', questionCount: 23),
    ContentEntry(certCode: 'MLA-C01', taskId: 'mla-t3-3', title: 'CI/CD 파이프라인 설정 (CodePipeline·CodeBuild·CodeDeploy·SageMaker Pipelines·재훈련)', domain: 3, mdAsset: 'assets/content/mla/mla-t3-3.md', questionsAsset: 'assets/content/mla/mla-t3-3.questions.json', questionCount: 26),
    ContentEntry(certCode: 'MLA-C01', taskId: 'mla-t4-1', title: '모델 추론 모니터링 (드리프트·Model Monitor·CloudWatch·EventBridge·A/B)', domain: 4, mdAsset: 'assets/content/mla/mla-t4-1.md', questionsAsset: 'assets/content/mla/mla-t4-1.questions.json', questionCount: 30),
    ContentEntry(certCode: 'MLA-C01', taskId: 'mla-t4-2', title: '인프라·비용 모니터링과 최적화 (지연 분해·CloudTrail·적정 규모·구매 옵션·태깅)', domain: 4, mdAsset: 'assets/content/mla/mla-t4-2.md', questionsAsset: 'assets/content/mla/mla-t4-2.questions.json', questionCount: 35),
    ContentEntry(certCode: 'MLA-C01', taskId: 'mla-t4-3', title: 'AWS 리소스 보호 (실행 역할·조건 키 가드레일·네트워크 격리·CI/CD 보안·감사)', domain: 4, mdAsset: 'assets/content/mla/mla-t4-3.md', questionsAsset: 'assets/content/mla/mla-t4-3.questions.json', questionCount: 35),
  ],
};

/// 테스트 전용 콘텐츠 인덱스 덮어쓰기(자격증별). 앱 경로에서는 항상 null이다.
///
/// ## 왜 있는가
///
/// 잠금 화면·"준비 중" 라벨·약점 모의고사 잠금 같은 **게이트 미달 동작**을
/// 검증하는 테스트가 "지금 잠겨 있는 자격증"을 표본으로 써 왔다. 그 표본은
/// 사람이 문항을 flip해 게이트를 열 때마다 깨져서 SAA(2026-10-28) →
/// MLA(2026-10-29) → DEA로 두 번 이사했고, 콘텐츠 있는 5종(CLF·SAA·SOA·DEA·MLA)이
/// 전부 개방되면 **옮길 자격증이 남지 않는다**(HANDOFF.md §0-2026-10-29 교훈 2).
/// 제품 동작은 어느 자격증이 검수를 통과했는지와 무관해야 하므로, 테스트가
/// "콘텐츠 인덱스가 이렇게 말한다면"을 직접 주입한다.
///
/// `contentFor`가 유일한 조회 지점이라 이 한 곳만 덮어쓰면 그 아래의
/// `certHasContent`·`certContentSummary`·`certHasVerifiedQuestions`·
/// `examWeightedCapacityStatus`·`certExamHasWeightedCapacity`와 그것을 읽는
/// 위젯 전부가 **같은 주입 상태**를 본다 — 위젯마다 주입구를 뚫지 않아도 된다.
///
/// ## 쓰는 법
///
/// 덮어쓰지 않은 자격증은 실제 인덱스를 그대로 본다(`{}`가 아니라 **빈 목록**을
/// 넣으면 그 자격증만 "콘텐츠 없음"이 된다). 누출되면 다른 테스트가 조용히
/// 틀린 상태를 보므로 **`tearDown`/`addTearDown`으로 반드시 null로 되돌린다.**
///
/// ```dart
/// debugContentIndexOverride = const {'CLF-C02': [ /* 합성 엔트리 */ ]};
/// addTearDown(() => debugContentIndexOverride = null);
/// ```
@visibleForTesting
Map<String, List<ContentEntry>>? debugContentIndexOverride;

List<ContentEntry> contentFor(String certCode) =>
    debugContentIndexOverride?[certCode] ?? kContentIndex[certCode] ?? const [];

/// 해당 자격증에 검증 콘텐츠(학습문서)가 존재하는가.
bool certHasContent(String certCode) => contentFor(certCode).isNotEmpty;

/// 청취 검수 승인(audioApproved) 오디오 강의가 있는 엔트리만 선언 순서로.
List<ContentEntry> approvedAudioEntries(String certCode) =>
    contentFor(certCode).where((e) => e.audioApproved).toList(growable: false);

/// 승인 오디오 강의를 1개 이상 가진 자격증 코드(kContentIndex 키 순서).
List<String> certsWithApprovedAudio() => kContentIndex.keys
    .where((code) => approvedAudioEntries(code).isNotEmpty)
    .toList(growable: false);

/// 랜딩 요약용: 학습문서 수 + 총 검증 문항 수.
({int docs, int questions}) certContentSummary(String certCode) {
  final entries = contentFor(certCode);
  var questions = 0;
  for (final e in entries) {
    questions += e.questionCount;
  }
  return (docs: entries.length, questions: questions);
}

/// 해당 자격증에 노출 가능한(verified) 문항이 1개 이상 있는가.
/// "학습문서만(문항 0)" 상태를 모의고사·리포트 노출에서 가르는 정적 판정.
bool certHasVerifiedQuestions(String certCode) =>
    certContentSummary(certCode).questions > 0;

ExamReadinessStatus examWeightedCapacityStatus(
  String certCode, {
  List<ContentEntry>? entries,
}) {
  final requirement = kExamReadinessRequirements[certCode];
  if (requirement == null) {
    return ExamReadinessStatus(
      certCode: certCode,
      hasPolicy: false,
      practiceQuestionCount: 0,
      requiredByDomain: const {},
      availableByDomain: const {},
      deficitByDomain: const {},
    );
  }

  final requiredByDomain = allocateByWeight(
    requirement.weightByDomain,
    requirement.practiceQuestionCount,
  );
  final availableByDomain = {
    for (final domain in requiredByDomain.keys) domain: 0,
  };
  for (final entry in entries ?? contentFor(certCode)) {
    if (availableByDomain.containsKey(entry.domain)) {
      availableByDomain[entry.domain] =
          availableByDomain[entry.domain]! + entry.questionCount;
    }
  }

  final deficitByDomain = <int, int>{};
  for (final entry in requiredByDomain.entries) {
    final available = availableByDomain[entry.key] ?? 0;
    if (available < entry.value) {
      deficitByDomain[entry.key] = entry.value - available;
    }
  }

  return ExamReadinessStatus(
    certCode: certCode,
    hasPolicy: true,
    practiceQuestionCount: requirement.practiceQuestionCount,
    requiredByDomain: Map.unmodifiable(requiredByDomain),
    availableByDomain: Map.unmodifiable(availableByDomain),
    deficitByDomain: Map.unmodifiable(deficitByDomain),
  );
}

/// 통합/약점 모의고사 공개 게이트: 공식 도메인 비중을 앱의 연습 세트에
/// 적용할 만큼 도메인별 검증 문항이 있어야 한다. 정책 없는 cert는 fail closed.
bool certExamHasWeightedCapacity(String certCode) =>
    examWeightedCapacityStatus(certCode).ready;

// 옛 공개 게이트 `examIsBalanced`/`certExamIsBalanced`("전 도메인에 검증 문항
// 1개 이상")는 2026-10-20에 제거했다. 2026-08-06 weighted capacity 게이트가
// 그 역할을 대신한 뒤로 lib 호출이 0이었고(테스트만 참조), 검수 루브릭이 그
// 함수를 공개 조건으로 적어 둔 탓에 "도메인 일괄 flip" 같은 틀린 절차가
// 문서에 남아 있었다. 편향 방지는 이제 도메인별 필요 수량이 담당한다 —
// `certExamHasWeightedCapacity`. 경위: HANDOFF.md §0-2026-10-20.
