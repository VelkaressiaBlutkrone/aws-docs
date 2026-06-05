export type Level = "Foundational" | "Associate" | "Professional" | "Specialty";

export type Certification = {
  id: string;
  level: Level;
  title: string;
  code?: string;
  audience: string;
  focus: string[];
  roadmap: string[];
  studyDocs: StudyDoc[];
  exams: PracticeExam[];
};

export type StudyDoc = {
  title: string;
  outcome: string;
  topics: string[];
};

export type PracticeExam = {
  title: string;
  scenario: string;
  checks: string[];
};

const commonDocs = {
  foundation: [
    "AWS 글로벌 인프라, 리전, 가용 영역",
    "공동 책임 모델과 기본 보안",
    "핵심 서비스와 과금 구조",
  ],
  architecture: [
    "Well-Architected Framework",
    "고가용성 네트워크와 컴퓨팅 설계",
    "스토리지, 데이터베이스, 비용 최적화",
  ],
  developer: [
    "SDK, CLI, IAM 권한 경계",
    "서버리스 애플리케이션 개발",
    "CI/CD, 관측성, 오류 처리",
  ],
  ops: [
    "모니터링과 이벤트 대응",
    "백업, 복구, 패치 운영",
    "성능, 비용, 보안 운영",
  ],
  ai: [
    "AI/ML 기본 개념",
    "Amazon Bedrock와 SageMaker",
    "책임 있는 AI와 보안",
  ],
};

const examSets = (prefix: string): PracticeExam[] =>
  Array.from({ length: 6 }, (_, index) => ({
    title: `${prefix} 모의고사 ${index + 1}회차`,
    scenario:
      index % 2 === 0
        ? "공식 시험 가이드의 도메인 비중을 따라 시나리오형 문항으로 구성합니다."
        : "실무 상황을 제시하고 가장 적절한 AWS 서비스와 설계 판단을 고르게 합니다.",
    checks: [
      "정답뿐 아니라 오답 제거 근거를 기록",
      "도메인별 취약 영역 태깅",
      "재응시 전 관련 상세 학습 문서로 회귀",
    ],
  }));

export const certificationLevels: Level[] = [
  "Foundational",
  "Associate",
  "Professional",
  "Specialty",
];

export const certifications: Certification[] = [
  {
    id: "cloud-practitioner",
    level: "Foundational",
    title: "AWS Certified Cloud Practitioner",
    code: "CLF-C02",
    audience: "AWS를 처음 시작하는 학습자와 비기술/기술 공통 입문자",
    focus: ["클라우드 개념", "보안과 규정 준수", "기술 개요", "요금과 지원"],
    roadmap: [
      "클라우드 가치 제안과 AWS 글로벌 인프라를 정리합니다.",
      "IAM, 공동 책임 모델, 기본 보안 제어를 학습합니다.",
      "EC2, S3, RDS, VPC, Lambda의 역할을 구분합니다.",
      "요금, 지원 플랜, 비용 관리 도구를 문제풀이로 확인합니다.",
    ],
    studyDocs: [
      {
        title: "클라우드 입문 문서",
        outcome: "AWS 서비스 이름을 목적별로 설명할 수 있습니다.",
        topics: commonDocs.foundation,
      },
      {
        title: "시험 직전 요약",
        outcome: "공식 가이드 도메인별 핵심 개념을 빠르게 회독합니다.",
        topics: ["책임 모델", "비용 도구", "지원 플랜", "기본 보안"],
      },
    ],
    exams: examSets("Cloud Practitioner"),
  },
  {
    id: "ai-practitioner",
    level: "Foundational",
    title: "AWS Certified AI Practitioner",
    code: "AIF-C01",
    audience: "AI/ML 서비스를 비즈니스와 기술 관점에서 이해하려는 입문자",
    focus: ["AI/ML 개념", "생성형 AI", "Foundation Model", "책임 있는 AI"],
    roadmap: [
      "AI, ML, 생성형 AI 용어와 활용 사례를 구분합니다.",
      "Bedrock, SageMaker, Q 계열 서비스의 목적을 정리합니다.",
      "프롬프트, RAG, 모델 평가, 보안 고려사항을 학습합니다.",
      "책임 있는 AI와 비용/운영 리스크를 점검합니다.",
    ],
    studyDocs: [
      {
        title: "AI Practitioner 기본 문서",
        outcome: "AWS AI 서비스의 쓰임새와 제한사항을 설명합니다.",
        topics: commonDocs.ai,
      },
      {
        title: "생성형 AI 핵심 문서",
        outcome: "Bedrock 기반 생성형 AI 구성요소를 구분합니다.",
        topics: ["모델 선택", "프롬프트", "RAG", "가드레일"],
      },
    ],
    exams: examSets("AI Practitioner"),
  },
  {
    id: "solutions-architect-associate",
    level: "Associate",
    title: "AWS Certified Solutions Architect - Associate",
    code: "SAA-C03",
    audience: "AWS 아키텍처 설계의 실무 기초를 잡는 학습자",
    focus: ["복원력 있는 아키텍처", "보안", "비용 최적화", "성능"],
    roadmap: [
      "VPC, 서브넷, 라우팅, 보안 그룹을 설계 관점에서 학습합니다.",
      "EC2, ELB, Auto Scaling, Lambda의 선택 기준을 정리합니다.",
      "S3, EBS, EFS, RDS, DynamoDB의 설계 패턴을 비교합니다.",
      "Well-Architected 원칙으로 시나리오형 문제를 풉니다.",
    ],
    studyDocs: [
      {
        title: "아키텍처 설계 기본 문서",
        outcome: "요구사항에 맞는 AWS 구성안을 선택합니다.",
        topics: commonDocs.architecture,
      },
      {
        title: "서비스 선택 기준 문서",
        outcome: "컴퓨팅, 스토리지, 데이터베이스 선택 근거를 설명합니다.",
        topics: ["EC2 vs Lambda", "RDS vs DynamoDB", "S3 스토리지 클래스"],
      },
    ],
    exams: examSets("Solutions Architect Associate"),
  },
  {
    id: "developer-associate",
    level: "Associate",
    title: "AWS Certified Developer - Associate",
    code: "DVA-C02",
    audience: "AWS 기반 애플리케이션을 개발하고 배포하는 개발자",
    focus: ["개발", "보안", "배포", "문제 해결"],
    roadmap: [
      "IAM, SDK, CLI, 환경별 자격 증명 흐름을 정리합니다.",
      "Lambda, API Gateway, SQS, SNS, EventBridge를 구현 흐름으로 학습합니다.",
      "DynamoDB, S3, ElastiCache 사용 패턴을 비교합니다.",
      "X-Ray, CloudWatch, CodePipeline 기반 운영 문제를 풉니다.",
    ],
    studyDocs: [
      {
        title: "개발자 핵심 문서",
        outcome: "서버리스 애플리케이션의 배포와 디버깅 흐름을 설명합니다.",
        topics: commonDocs.developer,
      },
      {
        title: "이벤트 기반 개발 문서",
        outcome: "비동기 서비스 조합의 실패 처리 방식을 설명합니다.",
        topics: ["SQS DLQ", "SNS fan-out", "EventBridge 규칙"],
      },
    ],
    exams: examSets("Developer Associate"),
  },
  {
    id: "cloudops-engineer-associate",
    level: "Associate",
    title: "AWS Certified CloudOps Engineer - Associate",
    code: "SOA-C03",
    audience: "AWS 워크로드를 배포, 관리, 운영하는 인프라/운영 담당자",
    focus: ["모니터링", "운영 자동화", "네트워킹", "비즈니스 연속성"],
    roadmap: [
      "CloudWatch, CloudTrail, EventBridge 기반 관측성을 학습합니다.",
      "Systems Manager, Backup, Auto Scaling 운영 절차를 정리합니다.",
      "VPC 연결, DNS, 보안 제어의 운영 이슈를 풉니다.",
      "비용과 성능 최적화 관점에서 운영 결정을 연습합니다.",
    ],
    studyDocs: [
      {
        title: "CloudOps 운영 문서",
        outcome: "장애, 배포, 백업 상황에서 적절한 운영 액션을 고릅니다.",
        topics: commonDocs.ops,
      },
      {
        title: "운영 네트워크 문서",
        outcome: "DNS, 라우팅, 접근 제어 이슈를 진단합니다.",
        topics: ["Route 53", "VPC Flow Logs", "NACL", "보안 그룹"],
      },
    ],
    exams: examSets("CloudOps Engineer Associate"),
  },
  {
    id: "data-engineer-associate",
    level: "Associate",
    title: "AWS Certified Data Engineer - Associate",
    code: "DEA-C01",
    audience: "AWS 데이터 파이프라인과 분석 기반을 구축하는 데이터 엔지니어",
    focus: ["데이터 수집", "변환", "오케스트레이션", "품질과 보안"],
    roadmap: [
      "S3 기반 데이터 레이크와 Glue 카탈로그를 정리합니다.",
      "Kinesis, MSK, DMS, Glue ETL의 사용 지점을 비교합니다.",
      "Redshift, Athena, Lake Formation 보안 구성을 학습합니다.",
      "데이터 품질, 모니터링, 비용 최적화 문제를 풉니다.",
    ],
    studyDocs: [
      {
        title: "데이터 파이프라인 문서",
        outcome: "배치/스트리밍 요구사항에 맞는 서비스를 선택합니다.",
        topics: ["Glue", "Kinesis", "Redshift", "Athena"],
      },
      {
        title: "데이터 거버넌스 문서",
        outcome: "권한과 품질 관리 경계를 설명합니다.",
        topics: ["Lake Formation", "IAM", "암호화", "데이터 품질"],
      },
    ],
    exams: examSets("Data Engineer Associate"),
  },
  {
    id: "machine-learning-engineer-associate",
    level: "Associate",
    title: "AWS Certified Machine Learning Engineer - Associate",
    code: "MLA-C01",
    audience: "ML 워크로드를 구현하고 운영하려는 엔지니어",
    focus: ["ML 수명주기", "SageMaker", "배포", "운영화"],
    roadmap: [
      "ML 문제 유형과 데이터 준비 과정을 정리합니다.",
      "SageMaker 학습, 튜닝, 배포 구성요소를 학습합니다.",
      "MLOps, 모니터링, 모델 품질 관리를 익힙니다.",
      "보안, 비용, 성능 요구사항을 반영한 시나리오를 풉니다.",
    ],
    studyDocs: [
      {
        title: "ML 엔지니어링 문서",
        outcome: "SageMaker 기반 ML 수명주기를 설명합니다.",
        topics: ["데이터 준비", "학습", "튜닝", "엔드포인트"],
      },
      {
        title: "MLOps 문서",
        outcome: "모델 배포 후 운영과 품질 관리 방식을 설명합니다.",
        topics: ["모델 모니터", "파이프라인", "피처 저장소", "드리프트"],
      },
    ],
    exams: examSets("Machine Learning Engineer Associate"),
  },
  {
    id: "solutions-architect-professional",
    level: "Professional",
    title: "AWS Certified Solutions Architect - Professional",
    code: "SAP-C02",
    audience: "복잡한 AWS 조직/멀티계정 아키텍처를 설계하는 고급 학습자",
    focus: ["복잡한 설계", "마이그레이션", "비용", "조직 거버넌스"],
    roadmap: [
      "멀티계정, Organizations, Control Tower 전략을 정리합니다.",
      "하이브리드 네트워크와 대규모 마이그레이션 패턴을 학습합니다.",
      "DR, 고가용성, 보안 경계를 고급 시나리오로 풉니다.",
      "비용 최적화와 운영 효율을 설계안에 반영합니다.",
    ],
    studyDocs: [
      {
        title: "프로페셔널 아키텍처 문서",
        outcome: "복잡한 제약 조건에서 최적 설계를 선택합니다.",
        topics: ["Organizations", "Transit Gateway", "DR", "Migration Hub"],
      },
    ],
    exams: examSets("Solutions Architect Professional"),
  },
  {
    id: "devops-engineer-professional",
    level: "Professional",
    title: "AWS Certified DevOps Engineer - Professional",
    code: "DOP-C02",
    audience: "AWS에서 자동화, 배포, 운영 안정성을 책임지는 엔지니어",
    focus: ["SDLC 자동화", "관측성", "복원력", "보안 자동화"],
    roadmap: [
      "Code 계열 서비스와 IaC 배포 전략을 정리합니다.",
      "CloudWatch, X-Ray, Config로 관측성과 거버넌스를 구성합니다.",
      "장애 대응, 롤백, DR 자동화 시나리오를 풉니다.",
      "보안 제어와 컴플라이언스 자동화를 학습합니다.",
    ],
    studyDocs: [
      {
        title: "DevOps Professional 문서",
        outcome: "운영 자동화와 배포 안정성 요구사항을 해결합니다.",
        topics: ["CodePipeline", "CloudFormation", "Config", "CloudWatch"],
      },
    ],
    exams: examSets("DevOps Engineer Professional"),
  },
  {
    id: "generative-ai-developer-professional",
    level: "Professional",
    title: "AWS Certified Generative AI Developer - Professional",
    code: "AIP-C01",
    audience: "AWS에서 프로덕션 생성형 AI 솔루션을 개발/배포하는 개발자",
    focus: ["Bedrock", "RAG", "에이전트", "보안과 운영"],
    roadmap: [
      "생성형 AI 애플리케이션 요구사항과 모델 선택 기준을 정리합니다.",
      "Bedrock, Knowledge Bases, Agents, Guardrails 구성을 학습합니다.",
      "평가, 비용, 지연시간, 보안 통제를 설계합니다.",
      "프로덕션 배포와 운영 시나리오를 풉니다.",
    ],
    studyDocs: [
      {
        title: "생성형 AI 개발 문서",
        outcome: "Bedrock 기반 프로덕션 애플리케이션을 설계합니다.",
        topics: ["Foundation Model", "RAG", "Agents", "Guardrails"],
      },
    ],
    exams: examSets("Generative AI Developer Professional"),
  },
  {
    id: "security-specialty",
    level: "Specialty",
    title: "AWS Certified Security - Specialty",
    code: "SCS-C02",
    audience: "AWS 보안 아키텍처와 운영을 전문적으로 다루는 학습자",
    focus: ["IAM", "탐지", "인프라 보안", "데이터 보호", "사고 대응"],
    roadmap: [
      "IAM 정책 평가, Organizations SCP, 권한 경계를 학습합니다.",
      "GuardDuty, Security Hub, Detective, CloudTrail 탐지를 정리합니다.",
      "KMS, Secrets Manager, 암호화 전략을 비교합니다.",
      "침해 대응과 로그 분석 시나리오를 풉니다.",
    ],
    studyDocs: [
      {
        title: "Security Specialty 문서",
        outcome: "보안 요구사항에 맞는 예방/탐지/대응 구성을 선택합니다.",
        topics: ["IAM", "KMS", "GuardDuty", "Security Hub"],
      },
    ],
    exams: examSets("Security Specialty"),
  },
  {
    id: "advanced-networking-specialty",
    level: "Specialty",
    title: "AWS Certified Advanced Networking - Specialty",
    code: "ANS-C01",
    audience: "AWS와 하이브리드 네트워크를 전문적으로 설계/운영하는 학습자",
    focus: ["하이브리드 연결", "라우팅", "DNS", "네트워크 보안"],
    roadmap: [
      "VPC 심화, Transit Gateway, Direct Connect를 정리합니다.",
      "Route 53, Resolver, 하이브리드 DNS 패턴을 학습합니다.",
      "멀티리전/멀티계정 네트워크 보안 경계를 설계합니다.",
      "트러블슈팅 중심 시나리오를 반복합니다.",
    ],
    studyDocs: [
      {
        title: "Advanced Networking 문서",
        outcome: "복잡한 네트워크 연결과 장애 원인을 분석합니다.",
        topics: ["Transit Gateway", "Direct Connect", "Route 53", "Network Firewall"],
      },
    ],
    exams: examSets("Advanced Networking Specialty"),
  },
];

export const recommendedPaths = [
  {
    title: "처음 시작",
    steps: ["Cloud Practitioner", "Solutions Architect Associate"],
  },
  {
    title: "개발자",
    steps: ["Developer Associate", "DevOps Professional"],
  },
  {
    title: "인프라/운영",
    steps: ["CloudOps Engineer Associate", "DevOps Professional"],
  },
  {
    title: "데이터",
    steps: ["Data Engineer Associate"],
  },
  {
    title: "AI/ML",
    steps: [
      "AI Practitioner",
      "Machine Learning Engineer Associate",
      "Generative AI Developer Professional",
    ],
  },
  {
    title: "보안/네트워크 전문",
    steps: ["Security Specialty", "Advanced Networking Specialty"],
  },
];

export const officialSources = [
  {
    title: "AWS Certification",
    href: "https://aws.amazon.com/certification/",
  },
  {
    title: "AWS Certified CloudOps Engineer - Associate",
    href: "https://aws.amazon.com/certification/certified-cloudops-engineer-associate/",
  },
  {
    title: "AWS Certification 시험 안내서 PDF",
    href: "https://docs.aws.amazon.com/ko_kr/aws-certification/latest/examguides/aws-certification-exam-guides.pdf",
  },
];
