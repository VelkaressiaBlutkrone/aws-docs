# DVA-C03 — 공식 시험 가이드 실측 (Task 12 · Skill 72)

> **원자료 노트(저작 재료)** · 조회일 **2026-11-01** · 공식 가이드 본문을 직접 읽어 적었다.
> 인용은 공식 원문(영문)을 15단어 이내로만 옮겼고, **Skill 72개는 전부 한국어 요약(본인 말)**이다 — 원문 전재가 아니다.
> 이 폴더 밖은 읽기만 했다. 학습문서·문항 저작과 `content_index.dart` 등록은 하지 않았다.

**정본 URL:** https://docs.aws.amazon.com/aws-certification/latest/developer-associate-03/developer-associate-03.html

> ⚠️ **슬러그 주의 — `aws-certification`이다.** `docs.aws.amazon.com/certification/latest/…`는 **404**다(2026-11-01 실측). 접두어 하나가 달라 "가이드가 없다"고 오판하기 쉽다.

하위 페이지 9개: `…-domain1` ~ `…-domain4` · `dva-03-comparison` · `dva-03-in-scope-services` · `dva-03-out-of-scope-services` · `dva-03-service-mentions` · `dva-03-technologies-concepts`.

---

## 1. 시험 메타 (가이드 본문 실측)

| 항목 | 값 | 비고 |
|---|---|---|
| 채점 문항 | **50** | "The exam includes 50 questions that affect your score." |
| 비채점 문항 | **15** | 식별되지 않음 |
| 점수 범위 | 100–1,000 | |
| **합격선** | **720** | C02와 동일 |
| 채점 모델 | 보상식(compensatory) | 도메인별 합격 불필요, 총점만 |
| 응답 유형 | 객관식(정답 1·오답 3) · 복수응답(5개 이상 중 2개 이상, **부분 점수 없음**) | |
| 미응답 | 오답 처리, 추측 벌점 없음 | |

> ⚠️ **시험 시간(130분)과 응시료는 가이드 본문에 없다.** C02 노트의 130분은 **블로그·인증 페이지** 출처다. C03 기준이라고 단정할 근거를 가이드에서는 찾지 못했다 — `exam_guides/DVA-C03.json`을 만들 때 걸리는 지점이다(§6).

### 전환 일정 (가이드 Note 직접 인용)

> "Registration for the updated version of the exam (DVA-C03) opens December 1, 2026."
> "The last day to take the current version of the exam (DVA-C02) is November 30, 2026."

⚠️ C02 노트 §0은 블로그를 근거로 **등록 시작을 2026-10-27**로 적었다. **가이드 본문은 2026-12-01이라고 적는다** — 등록 시작일이 뒤로 밀렸거나 블로그 표현이 달랐던 것이고, **가이드 본문이 정본**이다.

---

## 2. 도메인 비중

| 도메인 | 이름 | C03 | (C02) |
|---|---|---|---|
| 1 | Development with AWS Services | **30%** | 32% |
| 2 | Security | **26%** | 26% |
| 3 | **Testing and Deployment** | **22%** | 24% (이름은 "Deployment") |
| 4 | Troubleshooting and Optimization | **22%** | 18% |

---

## 3. Task 12개 · Skill 72개 (전수 — 한국어 요약)

Skill 수: **D1 18 · D2 19 · D3 19 · D4 16 = 72**. Task는 도메인당 3개씩 **12개**다(C02는 13개 — 도메인 3이 4개였다).

### 도메인 1 — Development with AWS Services (30%, Skill 18)

**Task 1.1 AWS에서 호스팅되는 애플리케이션 코드 개발 (10)**

| # | 요약 |
|---|---|
| 1.1.1 | 강결합·느슨한 결합 구분과 AWS 서비스로 구성 요소 분리 |
| 1.1.2 | 동기 vs 비동기 패턴 선택(API Gateway 동기 호출 · SQS 비동기 처리 · EventBridge 이벤트 기반) |
| 1.1.3 | 내결함성·복원력(백오프 재시도, 우아한 성능 저하) |
| 1.1.4 | API 생성·확장·유지(요청/응답 변환, 검증 규칙 적용) |
| 1.1.5 | API·SDK로 AWS 서비스와 상호작용하는 코드 |
| 1.1.6 | AWS 서비스로 스트리밍 데이터 관리 |
| 1.1.7 | **직렬화·역직렬화** (C02에서는 Task 1.3에 있었다) |
| 1.1.8 | 이벤트 기반 패턴(EventBridge · S3 이벤트 알림 · SQS · SNS) |
| 1.1.9 | **AI 보조 개발 도구로 코드 생성·리뷰·최적화** — 스펙 기반 코드 생성, 자동 코드 리뷰, 지능형 자동 완성, 리팩터링 제안, 보안 스캔 |
| 1.1.10 | **관리형 AWS AI 서비스를 애플리케이션에 통합** |

**Task 1.2 AWS Lambda 코드 개발 (4)** — ⚠️ C02보다 크게 줄었다

| # | 요약 |
|---|---|
| 1.2.1 | Lambda 함수에 VPC 내 프라이빗 리소스 접근 권한 부여 |
| 1.2.2 | 환경 변수·파라미터 구성(메모리·동시성·타임아웃·런타임·핸들러·계층·확장) |
| 1.2.3 | 이벤트 수명 주기·오류 처리(Destinations · DLQ) |
| 1.2.4 | 코드·이벤트 소스 매핑·Destinations로 AWS 서비스와 통합(API Gateway · DynamoDB) |

> ⚠️ **Lambda 성능 튜닝은 D4 Task 4.3으로 옮겨 갔다**(공식 재배치표). C02 1.2에 있던 멱등성·테스트 도구·준실시간 처리는 별도 Skill로 남지 않았다.

**Task 1.3 애플리케이션 개발 시 데이터 스토어 사용 (4)**

| # | 요약 |
|---|---|
| 1.3.1 | 데이터 수명 주기 관리(S3 Lifecycle · TTL · 보존 기간) |
| 1.3.2 | 액세스 패턴 기반 데이터 스토어 선택(ElastiCache · DynamoDB · S3 · RDS) |
| 1.3.3 | 데이터 스토어 선택에 맞는 캐싱 솔루션 결정 |
| 1.3.4 | **DynamoDB 통합 Skill** — 고카디널리티 파티션 키 선택, 읽기 일관성 모델, Query·Scan, 키·속성·인덱스 정의 |

### 도메인 2 — Security (26%, Skill 19)

**Task 2.1 인증·인가 구현 (7)**: 2.1.1 자격 증명 페더레이션 · 2.1.2 액세스 제어(세분화 권한·보안 토큰·MFA) · 2.1.3 프로그래밍 방식 액세스 구성 · **2.1.4 사전 서명 URL로 시간 제한 액세스(S3 · CloudFront)** · 2.1.5 인증된 AWS 서비스 호출 · 2.1.6 IAM 보안 주체·리소스 권한 정의 · 2.1.7 IAM 역할 수임

**Task 2.2 암호화·민감 데이터 관리 (7)** — C02 Task 2.2 + 2.3 = 13 Skill이 하나로 통합됐다: 2.2.1 저장 중·전송 중 암호화 · 2.2.2 인증서 관리(ACM · Private CA) · 2.2.3 클라이언트측 vs 서버측 암호화 · 2.2.4 암호화 키로 암·복호화 · 2.2.5 개발용 인증서·SSH 키 생성 · 2.2.6 민감 데이터(PII·PHI) 식별·마스킹·접근 제한 · 2.2.7 보안 암호 관리 서비스 사용

**Task 2.3 AI 서비스 사용·통합의 보안 위험 식별·완화 (5)** — 🆕 **신설**

| # | 요약 |
|---|---|
| 2.3.1 | AI 서비스 접근 요청·관리 |
| 2.3.2 | AI 서비스로 데이터를 보낼 때의 프라이버시 제어 — VPC 엔드포인트로 사설 연결, **입출력이 AI 모델 학습에 쓰이지 않도록** |
| 2.3.3 | AI 모델 입출력 필터링·제어 — 콘텐츠 필터링, 민감 정보 탐지, PII/PHI 편집, 거부 주제 정책, **프롬프트 인젝션·조작 방어** |
| 2.3.4 | AI 에이전트 상호작용 보안 — 도구 사용 권한, 세션 격리, 민감 작업의 **사람 승인 흐름** |
| 2.3.5 | AI 서비스 상호작용 중 **모니터링 로그의 민감 콘텐츠 보호** |

### 도메인 3 — Testing and Deployment (22%, Skill 19)

**Task 3.1 배포할 애플리케이션 아티팩트 준비 (5)**: 3.1.1 패키지 내 코드 모듈 의존성 관리(환경 변수·구성 파일·컨테이너 이미지) · **3.1.2 배포용 컨테이너 이미지 빌드·관리(ECR · Dockerfile · 이미지 태깅 · 수명 주기 정책)** 🆕 · 3.1.3 배포 환경에서 코드 리포지토리 사용 · 3.1.4 환경별 구성 관리(AppConfig · Parameter Store · Secrets Manager · API Gateway · Lambda) · **3.1.5 API Gateway 기능·리소스(스테이지별 URL·엔드포인트)** — C02 Task 3.4에서 이동

**Task 3.2 테스트 구현·자동화 (5)** — C02 Task 3.2 + 3.3 = 11 Skill 통합: 3.2.1 테스트 개발·검증(SAM · CDK · CloudFormation) · 3.2.2 외부 의존성 모의 API(API Gateway) · 3.2.3 테스트 이벤트 생성(Lambda·API Gateway용 JSON 페이로드) · 3.2.4 애플리케이션 환경 생성·구성(Lambda 별칭 · 컨테이너 이미지 태그 · **Amplify 브랜치** · **Copilot 환경** · API Gateway API) · **3.2.5 AWS AI 도구로 테스트 생성·반복 워크플로 자동화** 🆕

**Task 3.3 CI/CD 서비스로 코드 배포 (9)**: 3.3.1 Lambda 배포 패키징(.zip · 컨테이너 이미지 · 계층) · **3.3.2 컨테이너 오케스트레이션 서비스로 배포(ECS 작업 정의 · EKS 매니페스트 · Fargate 시작 유형 · 롤링 업데이트)** 🆕 · 3.3.3 IaC 템플릿(CloudFormation · SAM) · 3.3.4 CodeDeploy로 리비전 배포 · 3.3.5 CodePipeline으로 파이프라인 오케스트레이션 · 3.3.6 배포 전략(블루/그린 · 카나리 · 롤링) · 3.3.7 자동·수동 롤백(CloudFormation · CodeDeploy) · 3.3.8 소스 제어로 버전·릴리스 관리(레이블 · 브랜치) · **3.3.9 AWS AI 도구로 CI/CD 지원(배포 승인 자동화 · 환경 프로비저닝 · 배포 후 검증)** 🆕

### 도메인 4 — Troubleshooting and Optimization (22%, Skill 16)

**Task 4.1 근본 원인 분석 지원 (5)**: 4.1.1 코드·서비스 통합 디버깅 · 4.1.2 지표·로그·추적 해석 · 4.1.3 로그 쿼리 · 4.1.4 출력 로그로 배포 실패 문제 해결 · **4.1.5 AWS AI 도구로 오류 분석·문제 해결 제안 생성** 🆕

**Task 4.2 로깅·모니터링·관찰성 모범 사례 (5)** — C02의 8 Skill에서 3개 병합: 4.2.1 구조화 로깅 등 효과적 로깅 전략 · 4.2.2 사용자 지정 지표를 내보내는 코드 · 4.2.3 알림 구현(쿼터 한도 · 배포 완료) · 4.2.4 추적 구현 · 4.2.5 워크로드 상태 모니터링(헬스 체크 · **liveness·readiness 프로브**)

**Task 4.3 애플리케이션 최적화 (6)** — C02의 9 Skill에서 3개 병합: 4.3.1 동시성(Lambda 프로비저닝된 동시성 · EC2 Auto Scaling · 스레드 풀 · 커넥션 풀) · **4.3.2 메모리·컴퓨팅 최적화**(C02 Task 1.2의 Lambda 성능 튜닝이 여기로) · 4.3.3 메시징 최적화(SQS 큐 · SNS 팬아웃) · 4.3.4 캐싱(ElastiCache · DAX · CloudFront) · 4.3.5 성능 병목 탐지(CloudWatch) · **4.3.6 AWS AI 도구로 최적화 기회 식별** 🆕

---

## 4. in-scope 서비스 (전수 — 카테고리별)

| 카테고리 | 서비스 |
|---|---|
| Analytics | Athena · **Data Firehose** · Kinesis · OpenSearch Service |
| Application Integration | EventBridge · SNS · SQS · Step Functions |
| Compute | EC2 · Elastic Beanstalk · Lambda |
| Containers | **ECR · ECS · EKS** |
| Database | Aurora · DynamoDB · ElastiCache · RDS |
| Developer Tools | Amplify · CloudShell · CodeArtifact · CodeBuild · CodeDeploy · CodePipeline · X-Ray |
| **ML and AI** | **Bedrock · Bedrock AgentCore · Amazon Quick · Kiro** |
| Management and Governance | AppConfig · CDK · CloudFormation · CloudTrail · CloudWatch · CloudWatch Logs · CLI · SAM · Systems Manager |
| Networking and Content Delivery | API Gateway · CloudFront · ELB · **PrivateLink** · Route 53 · VPC |
| Security, Identity, and Compliance | ACM · Cognito · IAM · KMS · Private CA · Secrets Manager · STS · WAF |
| Storage | EBS · EFS · S3 · S3 Glacier |

> 목록은 공식적으로 **"non-exhaustive and is subject to change"**다 — 미기재가 곧 범위 밖은 아니다.

### ⚠️ 여기서 바로잡아야 할 것 두 가지

1. **"Amazon Q"가 아니라 「Amazon Quick」이다.** 블로그 예고를 받아 적은 C02 노트 §0과 `96-c03-readiness.md`는 신규 in-scope를 "Amazon Q"로 적었는데, **가이드의 ML/AI 항목은 `Amazon Quick`**이다(그리고 out-of-scope Analytics에 `Amazon Quick Sight`가 따로 있다). **`Amazon Q Developer`라는 이름은 in-scope 목록에 없다.**
2. **CodeCommit이 in-scope에 없다.** C02 노트 Task 3.1이 "코드·아티팩트 저장소(CodeCommit 현황)"를 다뤘는데, C03 Developer Tools 목록에는 CodeArtifact·CodeBuild·CodeDeploy·CodePipeline·Amplify·CloudShell·X-Ray뿐이다.

## 5. out-of-scope 서비스 (전수)

Quick Sight · Connect · WorkMail · AppStream 2.0 · WorkSpaces · GameLift · **Polly · Rekognition · SageMaker AI · Strands Agents** · AWS Managed Services · Elastic Transcoder · Application Discovery Service · Application Migration Service · Transfer Family · **Shield Advanced · Shield Standard** · Snow Family · Storage Gateway

### 후보자 역할에서 범위 밖인 작업 (가이드 "Job tasks that are out of scope")

아키텍처 설계 · CI/CD 파이프라인 **설계·생성** · IAM 사용자·그룹 관리 · 서버·OS 관리 · **파운데이션 모델 선택, 프롬프트 엔지니어링, RAG 아키텍처 설계** · **AI 안전 프레임워크 설계, 가드레일 구현, AI 거버넌스 구현** · ETL 파이프라인 설계 · 네트워킹 인프라 설계

> ⚠️ **이 목록과 Skill 2.3.3은 모순이 아니다.** 범위 밖인 것은 안전 프레임워크를 **설계**하고 거버넌스를 **구현**하는 일이고, Skill 2.3.3이 요구하는 것은 제공되는 필터링·탐지·거부 주제 정책을 **적용**하는 일이다. 문항을 쓸 때 이 선을 넘지 않는다 — "가드레일을 어떻게 설계할 것인가"가 아니라 "주어진 통제를 어디에 적용하는가"를 묻는다.

## 6. 「Technologies and Concepts」 절은 카테고리 목록뿐이다

Analytics · Application integration · Compute · Containers · Database · Developer tools · ML and AI · Management and governance · Networking and content delivery · Security, identity, and compliance · Storage — **개별 기술·개념 항목이 없다.** 다른 자격증 가이드처럼 세부 항목을 기대하면 안 된다.

## 7. ⚠️ Revisions 절이 없다

가이드 머리의 Note는 "Check the Revisions section for a summary of changes."라고 적지만, **Topics 목록에도 하위 페이지에도 Revisions는 없다.** 그 역할을 하는 것은 `dva-03-comparison.html`(C02↔C03 비교)이다. SOA-C03 v1.1 작업에서 쓴 "공식 Revisions 표" 같은 입력은 **이 자격증에는 없다** — 비교 페이지를 그 자리에 놓고 쓴다. Emerging topics 절도 없다.

## 8. 다음 단계에서 확인해야 할 것

- **시험 시간·응시료** — 가이드 본문에 없다. `exam_guides/DVA-C03.json`에 넣으려면 인증 페이지 등 다른 공식 출처가 필요하다(§1).
- **한국어 도메인 명칭** — 레포의 가이드 JSON은 한국어 명칭을 쓰는데(C02가 "AWS 서비스를 통한 개발"), **C03 본문은 `ko_kr` URL에서도 영문**인지 12월 전에 다시 확인한다. 번역해 넣으면 비공식 표기가 박힌다.
- **`Amazon Quick`의 정확한 제품 범위** — Quick Suite인지, Q Developer 후속을 포함하는지. Skill 1.1.9의 "AI 보조 개발 도구"가 Kiro를 가리키는지도 함께.
- **`AWS Copilot`** — Skill 3.2.4 예시에 **여전히 남아 있는데** CLI는 2026-06-12 지원 종료다(C02 노트 §4). in-scope 서비스 목록에는 Copilot이 **없다**. 문항에 쓸지 말지 판단이 필요하다.
