import '../models/certification.dart';

/// Ported from `src/data.ts`. Single source of truth for cert metadata.

const List<Level> certificationLevels = [
  Level.foundational,
  Level.associate,
  Level.professional,
  Level.specialty,
];

final List<Certification> certifications = [
  Certification(
    id: 'cloud-practitioner',
    level: Level.foundational,
    title: 'AWS Certified Cloud Practitioner',
    code: 'CLF-C02',
    audience: 'AWS를 처음 시작하는 학습자와 비기술/기술 공통 입문자',
    focus: const ['클라우드 개념', '보안과 규정 준수', '기술 개요', '요금과 지원'],
    roadmap: const [
      '클라우드 가치 제안과 AWS 글로벌 인프라를 정리합니다.',
      'IAM, 공동 책임 모델, 기본 보안 제어를 학습합니다.',
      'EC2, S3, RDS, VPC, Lambda의 역할을 구분합니다.',
      '요금, 지원 플랜, 비용 관리 도구를 문제풀이로 확인합니다.',
    ],
  ),
  Certification(
    id: 'ai-practitioner',
    level: Level.foundational,
    title: 'AWS Certified AI Practitioner',
    code: 'AIF-C01',
    audience: 'AI/ML 서비스를 비즈니스와 기술 관점에서 이해하려는 입문자',
    focus: const ['AI/ML 개념', '생성형 AI', 'Foundation Model', '책임 있는 AI'],
    roadmap: const [
      'AI, ML, 생성형 AI 용어와 활용 사례를 구분합니다.',
      'Bedrock, SageMaker, Q 계열 서비스의 목적을 정리합니다.',
      '프롬프트, RAG, 모델 평가, 보안 고려사항을 학습합니다.',
      '책임 있는 AI와 비용/운영 리스크를 점검합니다.',
    ],
  ),
  Certification(
    id: 'solutions-architect-associate',
    level: Level.associate,
    title: 'AWS Certified Solutions Architect - Associate',
    code: 'SAA-C03',
    audience: 'AWS 아키텍처 설계의 실무 기초를 잡는 학습자',
    focus: const ['복원력 있는 아키텍처', '보안', '비용 최적화', '성능'],
    roadmap: const [
      'VPC, 서브넷, 라우팅, 보안 그룹을 설계 관점에서 학습합니다.',
      'EC2, ELB, Auto Scaling, Lambda의 선택 기준을 정리합니다.',
      'S3, EBS, EFS, RDS, DynamoDB의 설계 패턴을 비교합니다.',
      'Well-Architected 원칙으로 시나리오형 문제를 풉니다.',
    ],
  ),
  Certification(
    id: 'developer-associate',
    level: Level.associate,
    title: 'AWS Certified Developer - Associate',
    code: 'DVA-C02',
    audience: 'AWS 기반 애플리케이션을 개발하고 배포하는 개발자',
    focus: const ['개발', '보안', '배포', '문제 해결'],
    roadmap: const [
      'IAM, SDK, CLI, 환경별 자격 증명 흐름을 정리합니다.',
      'Lambda, API Gateway, SQS, SNS, EventBridge를 구현 흐름으로 학습합니다.',
      'DynamoDB, S3, ElastiCache 사용 패턴을 비교합니다.',
      'X-Ray, CloudWatch, CodePipeline 기반 운영 문제를 풉니다.',
    ],
  ),
  Certification(
    id: 'cloudops-engineer-associate',
    level: Level.associate,
    title: 'AWS Certified CloudOps Engineer - Associate',
    code: 'SOA-C03',
    audience: 'AWS 워크로드를 배포, 관리, 운영하는 인프라/운영 담당자',
    focus: const ['모니터링', '운영 자동화', '네트워킹', '비즈니스 연속성'],
    roadmap: const [
      'CloudWatch, CloudTrail, EventBridge 기반 관측성을 학습합니다.',
      'Systems Manager, Backup, Auto Scaling 운영 절차를 정리합니다.',
      'VPC 연결, DNS, 보안 제어의 운영 이슈를 풉니다.',
      '비용과 성능 최적화 관점에서 운영 결정을 연습합니다.',
    ],
  ),
  Certification(
    id: 'data-engineer-associate',
    level: Level.associate,
    title: 'AWS Certified Data Engineer - Associate',
    code: 'DEA-C01',
    audience: 'AWS 데이터 파이프라인과 분석 기반을 구축하는 데이터 엔지니어',
    focus: const ['데이터 수집', '변환', '오케스트레이션', '품질과 보안'],
    roadmap: const [
      'S3 기반 데이터 레이크와 Glue 카탈로그를 정리합니다.',
      'Kinesis, MSK, DMS, Glue ETL의 사용 지점을 비교합니다.',
      'Redshift, Athena, Lake Formation 보안 구성을 학습합니다.',
      '데이터 품질, 모니터링, 비용 최적화 문제를 풉니다.',
    ],
  ),
  Certification(
    id: 'machine-learning-engineer-associate',
    level: Level.associate,
    title: 'AWS Certified Machine Learning Engineer - Associate',
    code: 'MLA-C01',
    audience: 'ML 워크로드를 구현하고 운영하려는 엔지니어',
    focus: const ['ML 수명주기', 'SageMaker', '배포', '운영화'],
    roadmap: const [
      'ML 문제 유형과 데이터 준비 과정을 정리합니다.',
      'SageMaker 학습, 튜닝, 배포 구성요소를 학습합니다.',
      'MLOps, 모니터링, 모델 품질 관리를 익힙니다.',
      '보안, 비용, 성능 요구사항을 반영한 시나리오를 풉니다.',
    ],
  ),
  Certification(
    id: 'solutions-architect-professional',
    level: Level.professional,
    title: 'AWS Certified Solutions Architect - Professional',
    code: 'SAP-C02',
    audience: '복잡한 AWS 조직/멀티계정 아키텍처를 설계하는 고급 학습자',
    focus: const ['복잡한 설계', '마이그레이션', '비용', '조직 거버넌스'],
    roadmap: const [
      '멀티계정, Organizations, Control Tower 전략을 정리합니다.',
      '하이브리드 네트워크와 대규모 마이그레이션 패턴을 학습합니다.',
      'DR, 고가용성, 보안 경계를 고급 시나리오로 풉니다.',
      '비용 최적화와 운영 효율을 설계안에 반영합니다.',
    ],
  ),
  Certification(
    id: 'devops-engineer-professional',
    level: Level.professional,
    title: 'AWS Certified DevOps Engineer - Professional',
    code: 'DOP-C02',
    audience: 'AWS에서 자동화, 배포, 운영 안정성을 책임지는 엔지니어',
    focus: const ['SDLC 자동화', '관측성', '복원력', '보안 자동화'],
    roadmap: const [
      'Code 계열 서비스와 IaC 배포 전략을 정리합니다.',
      'CloudWatch, X-Ray, Config로 관측성과 거버넌스를 구성합니다.',
      '장애 대응, 롤백, DR 자동화 시나리오를 풉니다.',
      '보안 제어와 컴플라이언스 자동화를 학습합니다.',
    ],
  ),
  Certification(
    id: 'generative-ai-developer-professional',
    level: Level.professional,
    title: 'AWS Certified Generative AI Developer - Professional',
    code: 'AIP-C01',
    audience: 'AWS에서 프로덕션 생성형 AI 솔루션을 개발/배포하는 개발자',
    focus: const ['Bedrock', 'RAG', '에이전트', '보안과 운영'],
    roadmap: const [
      '생성형 AI 애플리케이션 요구사항과 모델 선택 기준을 정리합니다.',
      'Bedrock, Knowledge Bases, Agents, Guardrails 구성을 학습합니다.',
      '평가, 비용, 지연시간, 보안 통제를 설계합니다.',
      '프로덕션 배포와 운영 시나리오를 풉니다.',
    ],
  ),
  Certification(
    id: 'security-specialty',
    level: Level.specialty,
    title: 'AWS Certified Security - Specialty',
    code: 'SCS-C03',
    audience: 'AWS 보안 아키텍처와 운영을 전문적으로 다루는 학습자',
    focus: const ['IAM', '탐지', '인프라 보안', '데이터 보호', '사고 대응'],
    roadmap: const [
      'IAM 정책 평가, Organizations SCP, 권한 경계를 학습합니다.',
      'GuardDuty, Security Hub, Detective, CloudTrail 탐지를 정리합니다.',
      'KMS, Secrets Manager, 암호화 전략을 비교합니다.',
      '침해 대응과 로그 분석 시나리오를 풉니다.',
    ],
  ),
  Certification(
    id: 'advanced-networking-specialty',
    level: Level.specialty,
    title: 'AWS Certified Advanced Networking - Specialty',
    code: 'ANS-C01',
    audience: 'AWS와 하이브리드 네트워크를 전문적으로 설계/운영하는 학습자',
    focus: const ['하이브리드 연결', '라우팅', 'DNS', '네트워크 보안'],
    roadmap: const [
      'VPC 심화, Transit Gateway, Direct Connect를 정리합니다.',
      'Route 53, Resolver, 하이브리드 DNS 패턴을 학습합니다.',
      '멀티리전/멀티계정 네트워크 보안 경계를 설계합니다.',
      '트러블슈팅 중심 시나리오를 반복합니다.',
    ],
  ),
];

const List<RecommendedPath> recommendedPaths = [
  RecommendedPath(
      title: '처음 시작',
      steps: ['Cloud Practitioner', 'Solutions Architect Associate']),
  RecommendedPath(
      title: '개발자', steps: ['Developer Associate', 'DevOps Professional']),
  RecommendedPath(
      title: '인프라/운영',
      steps: ['CloudOps Engineer Associate', 'DevOps Professional']),
  RecommendedPath(title: '데이터', steps: ['Data Engineer Associate']),
  RecommendedPath(title: 'AI/ML', steps: [
    'AI Practitioner',
    'Machine Learning Engineer Associate',
    'Generative AI Developer Professional',
  ]),
  RecommendedPath(
      title: '보안/네트워크 전문',
      steps: ['Security Specialty', 'Advanced Networking Specialty']),
];

const List<OfficialSource> officialSources = [
  OfficialSource(title: 'AWS Certification', href: 'https://aws.amazon.com/certification/'),
  OfficialSource(
      title: '공식 시험 가이드 (한국어)',
      href:
          'https://docs.aws.amazon.com/ko_kr/aws-certification/latest/examguides/aws-certification-exam-guides.html'),
  OfficialSource(
      title: 'AWS Certification 시험 안내서 PDF',
      href:
          'https://docs.aws.amazon.com/ko_kr/aws-certification/latest/examguides/aws-certification-exam-guides.pdf'),
];
