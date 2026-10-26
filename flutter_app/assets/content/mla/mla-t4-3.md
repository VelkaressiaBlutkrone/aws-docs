---
examGuideTaskId: mla-t4-3
certCode: MLA-C01
domain: 4
domainName: ML 솔루션 모니터링·유지 관리·보안
domainWeightPct: 24
title: AWS 리소스 보호 (실행 역할·조건 키 가드레일·네트워크 격리·CI/CD 보안·감사)
coversTasks:
  - "4.3"
sources:
  - title: How to use SageMaker AI execution roles (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/sagemaker-roles.html
  - title: Grant a user permissions to pass a role to an AWS service (IAM User Guide)
    url: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_passrole.html
  - title: AWS managed policies for Amazon SageMaker AI (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/security-iam-awsmanpol.html
  - title: Amazon SageMaker AI identity-based policy examples (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/security_iam_id-based-policy-examples.html
  - title: Actions, resources, and condition keys for Amazon SageMaker (Service Authorization Reference)
    url: https://docs.aws.amazon.com/service-authorization/latest/reference/list_sagemaker.html
  - title: Build a Secure Enterprise Machine Learning Platform on AWS — Governance and control (AWS 백서)
    url: https://docs.aws.amazon.com/whitepapers/latest/build-secure-enterprise-ml-platform/governance-and-control.html
  - title: Run Training and Inference Containers in Internet-Free Mode (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/mkt-algo-model-internet-free.html
  - title: Give SageMaker AI Training Jobs Access to Resources in Your Amazon VPC (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/train-vpc.html
  - title: Connect to SageMaker AI Within your VPC (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/interface-vpc-endpoint.html
  - title: Notebook instances, SageMaker AI jobs, and Endpoints (encryption at rest 공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/encryption-at-rest-nbi.html
  - title: Protect Communications Between ML Compute Instances in a Distributed Training Job (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/train-encrypt.html
  - title: Logging Amazon SageMaker AI API calls using AWS CloudTrail (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/logging-using-cloudtrail.html
  - title: Security best practices (AWS CodePipeline User Guide)
    url: https://docs.aws.amazon.com/codepipeline/latest/userguide/security-best-practices.html
  - title: Role Manager availability change (공식 공지)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/role-manager-availability-change.html
  - title: MLA-C01 공식 시험 가이드 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-01/machine-learning-engineer-associate-01.html
lastVerified: 2026-10-17
---

# AWS 리소스 보호 (실행 역할·조건 키 가드레일·네트워크 격리·CI/CD 보안·감사)

> **커버하는 공식 Task** — MLA-C01 · 도메인 4 「ML 솔루션 모니터링, 유지 관리 및 보안」(24%) · **Task 4.3 AWS 리소스 보호** (`mla-t4-3`)
> 이 문서는 위 한 Task에 1:1로 매핑됩니다. 4.1이 "모델이 나빠졌는가", 4.2가 "인프라가 느리거나 비싼가"였다면 4.3은 **"누가 무엇에 닿을 수 있고, 데이터가 나갈 길이 있는가"** 입니다.

---

## ✅ 학습 목표 체크리스트

- [ ] **사람의 역할과 서비스의 실행 역할**을 구분하고, `iam:PassRole`이 왜 별도 권한인지 설명한다
- [ ] 관리형 정책에서 출발해 **요청 필드 단위로 S3·ECR·KMS 권한을 좁히는** 방법과 사용량 기반 축소를 안다
- [ ] `sagemaker:` **조건 키로 암호화·VPC·격리를 강제**하고, Allow+조건과 Deny 가드레일을 가른다
- [ ] **네트워크 격리 · VPC 모드 · Studio `VpcOnly` · 노트북 인터넷 차단**을 효과와 제약으로 구분한다
- [ ] 게이트웨이 엔드포인트와 **인터페이스 엔드포인트(PrivateLink)** 의 용도를 가르고, 보안 그룹 요건을 안다
- [ ] 저장 중·전송 중 암호화의 **기본 동작**과 ⚠️ **기본적으로 암호화되지 않는 구간**을 안다
- [ ] CI/CD 파이프라인의 **비밀 관리·역할 분리·아티팩트 암호화·승인 게이트**를 적용한다
- [ ] **예방 통제(조건 키·SCP)와 평가 통제(Config 규칙)** 를 구분하고, 권한·연결 오류를 순서대로 진단한다

> **이 문서가 다루는 것** — 1) 실행 역할과 `iam:PassRole` · 2) 관리형 정책과 최소 권한 · 3) ⚠️ Role Manager와 대체 경로 · 4) 조건 키 가드레일 · 5) ML 아티팩트 보호 · 6) 암호화 · 7) 네트워크 격리 수단 비교 · 8) VPC·엔드포인트 요건 · 9) 계층 방어 참조 설계 · 10) 거버넌스·규정 준수 · 11) CI/CD 보안 · 12) 모니터링·감사·로깅 · 13) 보안 문제 해결

---

## 🎯 왜 중요한가

4.3의 문항은 거의 전부 **두 종류의 "안 된다"** 를 다룹니다.

**① 권한이 없어서 안 된다.** `AccessDenied` · `not authorized`. 여기서 가장 자주 나오는 것이 **`iam:PassRole`** 입니다 — 사용자가 훈련 작업을 만들려면 자기 권한만으로는 부족하고, **그 실행 역할을 서비스에 건넬 권한**이 따로 있어야 합니다.

**② 길이 없어서 안 된다.** 타임아웃. 사설 서브넷의 훈련 컨테이너가 S3에 닿지 못하는 이유는 권한이 아니라 **VPC 엔드포인트가 없어서**입니다.

그리고 출발점을 기억해야 합니다 — **SageMaker AI의 훈련·추론 컨테이너는 기본적으로 인터넷이 열려 있습니다.** 공개 라이브러리 코드가 데이터를 외부로 보낼 수 있는 경로가 되므로, 격리 수단을 **용도에 맞게** 골라야 합니다. 그 수단 네 가지가 보기에 함께 나오고, **"컨테이너가 아무 데도 못 나가게"** 하는 것은 그중 하나(**네트워크 격리**)뿐입니다.

마지막 축은 **통제의 시점**입니다. IAM 조건 키와 SCP는 **요청을 거부하는 예방 통제**이고, AWS Config 규칙은 **이미 만들어진 리소스를 평가해 NON_COMPLIANT로 표시하는 평가 통제**입니다. "암호화되지 않은 노트북이 만들어지는 것을 막아라"와 "암호화되지 않은 노트북을 찾아내라"는 서로 다른 답을 가집니다.

---

## ⚡ 시험 직전 요약

> 시험 직전에 이 열 줄만 다시 봅니다. 근거와 맥락은 아래 본문에 있습니다.

- **역할 둘**: 사용자 연합 역할은 **사용자가 직접 assume**, 실행 역할은 **SageMaker AI 서비스가 assume**(신뢰 정책 `Principal.Service = sagemaker.amazonaws.com` + `sts:AssumeRole`)
- ⚠️ **`iam:PassRole`이 가장 자주 나오는 권한 오류**다. 정책의 `Resource`를 역할 ARN으로 좁히고 `Condition`에 **`iam:PassedToService = sagemaker.amazonaws.com`**. ⚠️ PassRole은 **같은 계정의 서비스에만**, 역할 태그 기반 `ResourceTag` 통제는 **결과가 일정하지 않다고 문서가 경고**
- ⚠️ **`AmazonSageMakerFullAccess`의 S3 범위가 함정**이다 — 이름에 `SageMaker`·`sagemaker`·`aws-glue`가 든 버킷·객체에만 일부 작업 허용. **도메인 생성 권한은 포함하지 않는다**
- **예방 vs 평가**: 조건 키·SCP는 **요청을 Deny**(명시적 거부가 모든 허용을 이김) · **AWS Config 규칙**은 이미 있는 리소스를 **NON_COMPLIANT로 표시**
- **격리 수단 4종의 차이**: **네트워크 격리**(`EnableNetworkIsolation=True`)만 컨테이너가 **S3를 포함한 어떤 서비스로도 못 나가고 AWS 자격 증명도 받지 않는다.** VPC 모드는 **트래픽을 내 VPC 경로로 돌리는 것**이고, Studio `VpcOnly`·노트북 `DirectInternetAccess=Disabled`는 인터넷을 끊는 것
- ⚠️ **네트워크 격리는 AWS Marketplace 리소스로 훈련·모델 실행 시 필수**이고, 다중 인스턴스 훈련은 **피어 간 통신만** 허용된다
- **엔드포인트 2종**: S3는 **게이트웨이 엔드포인트**(라우트 테이블 연결, 추가 요금 없음) · SageMaker API·Runtime은 **인터페이스 엔드포인트(PrivateLink)**. ⚠️ Runtime은 **클라이언트가 있는 AZ에서 활성화**해야 사설 DNS가 동작
- ⚠️ **기본적으로 암호화되지 않는 구간이 있다** — 서비스 제어 평면↔훈련 인스턴스, **분산 처리·분산 훈련 노드 간.** 켜려면 `EnableInterContainerTrafficEncryption=True` + 보안 그룹에 **UDP 500·ESP 50**(자기 보안 그룹 ID 소스)
- **CI/CD 보안 5축**: 비밀은 **`PLAINTEXT` 환경 변수에 두지 않고** `PARAMETER_STORE`·`SECRETS_MANAGER` · 역할을 단계·용도별로 분리 · 아티팩트 **KMS 암호화(대칭 키만)** · 민감 단계 앞 **수동 승인**(⚠️ 7일 무응답은 실패, Source 스테이지에 추가 불가) · **신뢰할 수 없는 외부 PR을 자동 빌드하지 않는다**
- **감사 질문별 서비스**: 누가 만들었나 → **CloudTrail 관리 이벤트**(기본 기록, 이벤트 기록 90일) · 누가 호출했나 → **데이터 이벤트**(옵트인) · 구성이 규정에 맞나 → **AWS Config** · 민감 데이터가 어디 있나 → **Macie** · 어디와 통신했나 → **VPC Flow Logs**

---

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **실행 역할(execution role)** | SageMaker AI가 사용자를 대신해 다른 AWS 서비스를 호출할 때 쓰는 IAM 역할. **서비스가 assume한다** |
| **`iam:PassRole`** | 역할을 **서비스에 건넬** 권한. 자기에게 없는 권한을 가진 역할을 서비스에 넘겨 우회하는 것을 막는 장치 |
| **네트워크 격리** | 컨테이너의 모든 아웃바운드 호출을 막는 설정. 컨테이너는 **AWS 자격 증명조차 받지 않는다** |
| **VPC 모드** | 서브넷·보안 그룹을 지정해 SageMaker가 **ENI를 만들어 컨테이너에 붙이는** 것. 트래픽을 내 VPC 경로로 돌린다 |
| **게이트웨이 / 인터페이스 엔드포인트** | 라우트 테이블에 붙는 S3·DynamoDB용 vs ENI로 만들어지는 PrivateLink 엔드포인트 |
| **예방 통제 / 평가 통제** | 요청을 **거부**하는 것(IAM 조건 키·SCP) vs 이미 있는 리소스를 **평가**하는 것(AWS Config 규칙) |
| **혼동된 대리인(confused deputy)** | 서비스가 다른 고객의 요청에 속아 내 리소스를 건드리는 문제. `aws:SourceArn`·`aws:SourceAccount` 조건으로 막는다 |
| **권한 경계(permissions boundary)** | 역할이 가질 수 있는 최대 권한. 정책과 **둘 다 허용**해야 동작한다 |

---

## 📖 핵심 개념

### 1) 실행 역할과 `iam:PassRole` {#execution-role-passrole}

**정의.** SageMaker AI는 사용자를 대신해 다른 AWS 서비스를 호출하며, 그 권한을 **IAM 실행 역할**로 부여합니다. **모든 실행 역할의 신뢰 정책은 동일합니다** — `Principal.Service = sagemaker.amazonaws.com`, `Action = sts:AssumeRole`. 즉 "누가 assume하는가"가 SageMaker AI 서비스 주체입니다.

**사용자 연합 역할과 무엇이 다른가**

| 구분 | 사용자 연합 역할 | SageMaker 실행 역할 |
|---|---|---|
| assume하는 주체 | **사용자가 직접** assume | **SageMaker AI 서비스**가 assume |
| 용도 | AWS Management Console 등 AWS 리소스 접근 | 사용자 또는 자동화 도구를 **대신해 서비스가** 기능 수행 |
| 지정 위치 | (문서에 별도 서술 없음) | 사용자 프로필, 없으면 **도메인 수준** |

커스텀 웹 앱이 presigned URL로 Studio에 접근하면 두 역할이 섞인 **하이브리드**가 되므로, **사용자가 할 수 있는 일과 Studio가 대신 할 수 있는 일 양쪽 모두에** 최소 권한을 적용해야 합니다.

**`iam:PassRole` — 누가, 어떻게**

- 실행 역할을 요청에 실어 보내는 API(`CreateTrainingJob`·`CreateProcessingJob`·`CreateHyperParameterTuningJob`·`CreateModel`·`CreateNotebookInstance`·`CreateDomain`·`CreateUserProfile` 등)를 부르는 주체는 **그 역할을 서비스에 건넬 권한**이 있어야 합니다
- 정책은 `Resource`를 허용할 **역할 ARN으로 좁히고**, `Condition`에 **`iam:PassedToService = sagemaker.amazonaws.com`** 을 둡니다
- 대표 오류 — `User: arn:aws:iam::...:user/... is not authorized to perform: iam:PassRole`
- ⚠️ **함정 1**: 역할에 태그를 붙이고 `ResourceTag` 조건으로 PassRole을 통제하는 방식은 **결과가 일정하지 않다고 문서가 경고**합니다
- ⚠️ **함정 2**: PassRole은 **같은 AWS 계정의 서비스에만** 씁니다. 다른 계정의 서비스에 역할을 건네려면 **대상 계정에 그 역할을 assume할 수 있는 역할을 먼저** 만들어야 합니다

> 🧠 원리: PassRole을 별도 권한으로 분리한 이유는 **"사용자가 자기에게 없는 권한을 가진 역할을 서비스에 건네 우회하는 것"** 을 막기 위해서입니다. 문서의 예 — S3 권한이 없는 사용자가 S3 권한이 있는 역할을 서비스에 건넬 수 있다면, **서비스가 그 사용자를 대신해 S3 작업을 수행**하게 됩니다.

**실행 역할을 어디에 연결하나.** 도메인(기본 실행 역할)·공간(space 기본 실행 역할)·사용자 프로필·노트북 인스턴스에 연결하거나 작업 API 호출에 ARN으로 전달합니다. ⚠️ **역할을 바꾸면 그 역할을 쓰는 모든 ID의 권한이 바뀝니다** — 사용자 실행 역할을 바꾸면 그 사용자가 만든 private space가, space 기본 실행 역할을 바꾸면 도메인의 shared space가 바뀐 역할을 가정합니다.

**API별로 실행 역할에 추가해야 하는 권한**

| 상황 | 실행 역할에 필요한 것 |
|---|---|
| 프라이빗 VPC를 지정한 작업(훈련·튜닝·처리·AutoML) | `ec2:CreateNetworkInterface`·`CreateNetworkInterfacePermission`·`DeleteNetworkInterface`·`DeleteNetworkInterfacePermission`·`DescribeNetworkInterfaces`·`DescribeVpcs`·`DescribeDhcpOptions`·`DescribeSubnets`·`DescribeSecurityGroups`. ⚠️ **처리 작업은 이 ec2 권한에 조건·리소스 필터를 걸면 생성 시 검증이 실패** |
| 입력이 SSE-KMS로 암호화됨 | `kms:Decrypt` |
| 출력 설정에 KMS 키 지정 | `kms:Encrypt` |
| 리소스 구성(ML 스토리지 볼륨)에 KMS 키 지정 | `kms:CreateGrant` |
| `CreateDomain`에 고객 관리형 키 지정 | `kms:CreateGrant`·`kms:DescribeKey` — **`CreateApp` 호출 시 적용** |
| 노트북 인스턴스에서 SageMaker API 호출 | 문서 예시는 `sagemaker:*` 등과 함께 **`iam:PassRole`**(조건 `iam:PassedToService`)을 포함 |

**Pipelines.** 파이프라인은 **파이프라인 실행 역할**을 받으며, 생성자 쪽 역할에 그 역할을 지정한 `iam:PassRole`이 필요합니다. 기본적으로 각 단계는 파이프라인 실행 역할을 쓰지만 **단계별로 다른 역할**을 줄 수 있고, 이는 **한 단계의 코드가 직접 관계가 없는 다른 단계의 리소스에 영향을 주지 못하게** 하려는 설계입니다.

**혼동된 대리인 방지.** 실행 역할 신뢰 정책에 **`aws:SourceArn`** 조건을 추가합니다. Studio 예: `ArnLike aws:SourceArn = arn:aws:sagemaker:us-west-2:123456789012:*` — 계정 번호가 ARN에 있으므로 `aws:SourceAccount`는 따로 필요하지 않습니다.

### 2) 관리형 정책과 최소 권한 설계 {#least-privilege-policies}

**관리형 정책에서 시작해 최소 권한으로 이동합니다.** 문서의 정책 모범 사례 — AWS 관리형 정책으로 시작 → 사용 사례에 특화된 **고객 관리형 정책**으로 권한을 더 줄이기 → **조건으로 추가 제한** → **IAM Access Analyzer로 정책 검증** → MFA 요구. 관리형 정책 페이지의 권고는 **"use the most restricted policy"** 입니다.

| 정책 | 무엇을 주나 | 시험에서 중요한 한계 |
|---|---|---|
| **`AmazonSageMakerFullAccess`** | SageMaker AI 리소스·작업 전체 + 관련 서비스 일부 | ⚠️ **S3는 이름에 `SageMaker`·`Sagemaker`·`sagemaker`·`aws-glue`가 들어간 버킷·객체에 대해서만** 일부 작업 허용(`s3:CreateBucket`·`s3:ListBucket` 등은 모든 S3 리소스에 허용). **모든 IAM 역할을 SageMaker에 전달 가능**하고 Glue·Step Functions·RoboMaker에는 이름에 "AmazonSageMaker"가 든 역할만 전달 가능. ⚠️ **도메인 생성 권한은 포함하지 않음** |
| `AmazonSageMakerReadOnly` | SageMaker AI 리소스 읽기 전용 | 감사자·모니터링용 |
| 용도별 관리형 정책 | Canvas·Feature Store·Pipelines·Model Governance·Model Registry 등 | 필요한 기능 단위로 고른다 |
| `AdministratorAccess`, `DataScientist` | — | ⚠️ 문서가 **"권장하지 않음"** 으로 분류 |

**S3·ECR 권한을 요청 필드에 맞춰 좁힙니다**

| 권한 | 좁히는 대상(요청 필드) |
|---|---|
| `s3:ListBucket` | `InputDataConfig.DataSource.S3DataSource.S3Uri`의 버킷 |
| `s3:GetObject`·`PutObject`·`DeleteObject` | `S3Uri`, `OutputDataConfig.S3OutputPath`. `CreateModel`이면 `PrimaryContainer.ModelDataUrl` |
| ECR(`ecr:BatchCheckLayerAvailability`·`GetDownloadUrlForLayer`·`BatchGetImage`) | `AlgorithmSpecification.TrainingImage`(`CreateModel`이면 `PrimaryContainer.Image`) 리포지토리 ARN |
| CloudWatch Logs | 튜닝 작업 예시는 로그 그룹 `/aws/sagemaker/TrainingJobs*` 로 한정 |
| `cloudwatch:PutMetricData`·`ecr:GetAuthorizationToken` | 문서 예시는 `Resource: "*"` 로 둔다 |

**주체별 역할 설계**

| 주체 | 부여 | 막을 것 |
|---|---|---|
| 데이터 과학자·ML 엔지니어(사람) | SageMaker 작업 권한 + **특정 실행 역할에 한정한 `iam:PassRole`** | 임의 역할 전달, 관리자 정책 |
| SageMaker 실행 역할(서비스) | 작업이 쓰는 **S3 프리픽스·ECR 리포지토리·KMS 키·로그 그룹만** | 광범위한 `Resource: "*"` |
| 추론을 호출하는 애플리케이션 | `sagemaker:InvokeEndpoint`를 **특정 엔드포인트 ARN으로 한정** | `Resource` 와일드카드 |
| 읽기 전용 감사자 | `AmazonSageMakerReadOnly` | 변경 권한 |
| 조직 전체 가드레일 | **SCP·Deny 문장**으로 KMS·VPC·격리 강제(4) 참조) | 보안 설정 누락 |

**IAM 그룹.** IAM 사용자 그룹은 **IAM 사용자의 모음**이며 그룹에 ID 기반 정책을 붙여 여러 사용자의 권한을 한 번에 관리합니다. ⚠️ 그룹은 **인증 주체가 아니라 권한 단위**이므로 **리소스 기반 정책의 `Principal`로 쓸 수 없습니다**(예: S3 버킷 정책에 그룹을 주체로 지정 불가).

**정책 평가 규칙**

- 기본은 **암묵적 거부**이고 **명시적 거부가 명시적 허용을 이깁니다.** 명시적 거부는 정책에 `Deny`가 있을 때, 암묵적 거부는 적용되는 `Deny`도 `Allow`도 없을 때입니다
- 실행 역할에 **권한 경계**가 있으면 SageMaker는 **IAM 정책과 경계가 둘 다 허용한** 동작만 실행합니다
- 조직 수준에서는 **SCP**가 구성원 계정 사용자·역할의 유효 권한을 제한합니다

**사용량 기반으로 줄이기**

- **IAM Access Analyzer**는 정책 검증(100개 넘는 점검)과 **CloudTrail 활동 기반 정책 생성**을 제공합니다. 정책 생성은 **최대 90일의 과거 CloudTrail 이벤트**를 분석하며, ⚠️ **서비스 역할과 이벤트를 기록하는 추적(trail)이 먼저 있어야** 합니다
- **적용 흐름** — 넓은 정책(예: `AmazonSageMakerFullAccess`)으로 **대표 기간 30~90일** 워크로드를 돌린 뒤 Access Analyzer로 **실제 사용 작업만 담은 정책**을 생성해 교체합니다
- 수동으로 보려면 CloudTrail Event history를 **사용자 이름으로 필터링**하거나 IAM 콘솔의 **Access Advisor**(마지막 접근 정보)를 봅니다

**태그 기반 접근 제어(ABAC).** `sagemaker:ResourceTag/<키>` 조건으로 팀별 리소스를 분리할 수 있지만 ⚠️ **목록·`Search` 계열 API 등 일부 호출에는 태그 기반 정책이 적용되지 않습니다.** 사용자 정의 태그는 **갱신 시 덮어쓸 수 있으므로** 태그 부여 권한을 좁게 줍니다. AWS가 생성하는 태그(`sagemaker:domain-arn`·`user-profile-arn`·`space-arn`)는 **사용자가 바꿀 수 없습니다.**

### 3) ⚠️ Role Manager와 대체 경로 {#role-manager-status}

> ⚠️ **상태** — "Amazon SageMaker Role Manager is no longer open to new customers." 기존 고객은 계속 사용하고 보안·가용성 개선은 이어가되 **새 기능은 계획이 없습니다.** 기능 묶음 공지에 Role Manager가 **2026-07-30부터** 신규 고객에게 열려 있지 않은 기능으로 포함돼 있고, 같은 공지는 다른 SageMaker AI 기능의 가용성에는 영향이 없다고 명시합니다. 가이드(Version 1.0)가 지식 항목의 예로 Role Manager를 들고 있으므로 **개념은 알아야 하지만 오늘 기준 신규 계정에서는 쓸 수 없습니다.**

**무엇인가.** ML 관리자가 데이터 과학자·MLOps 엔지니어 같은 **페르소나별 최소 권한을 SageMaker AI 콘솔에서 IAM 역할로** 만들고 관리하게 해 주는 기능입니다. 사전 구성된 페르소나 **3개**와 사전 정의된 권한(ML activity)을 제공합니다.

| 페르소나 | 용도 | 사전 선택 ML 활동(일부) |
|---|---|---|
| **Data scientist** | 일반 ML 개발·실험 권한 | Run Studio Classic Applications, Manage ML Jobs, Manage Models, Manage AWS Glue Tables |
| **MLOps** | 운영 활동 권한 | Manage Models, Manage Pipelines, Search and visualize experiments, Amazon S3 Full Access |
| **SageMaker AI compute** | 컴퓨팅 리소스(훈련·추론)가 쓰는 **서비스 실행 역할** | Access Required AWS Services |

- 1단계에서 입력한 **VPC 서브넷·보안 그룹·KMS 키 같은 조건이 선택한 모든 ML 활동에 자동 전달**되고, `InstanceTypes`·`IntercontainerTrafficEncryption` 같은 조건을 활동별로 더 붙일 수도 있습니다
- **결과물은 일반 IAM 역할**입니다. 이름에 기본으로 `sagemaker-` 접두어가 붙고 IAM 콘솔에서 수정·삭제할 수 있습니다. ⚠️ **콘솔 로그인용 사람 역할은 만들 수 없고**, 서비스 역할을 만든 뒤 IAM 콘솔에서 편집해야 합니다

**대체 경로(공식 가이드가 안내하는 것)**

| 필요 | 대체 수단 |
|---|---|
| 실행 역할 생성 | IAM 콘솔·CLI·SDK에서 `sagemaker.amazonaws.com` 신뢰 정책 역할 생성(콘솔의 **SageMaker AI – Execution 사용 사례**, `AmazonSageMakerFullAccess` 자동 부착) |
| 페르소나별 권한 | AWS 관리형 정책 직접 부착 — 일반 개발 `AmazonSageMakerFullAccess`, 읽기 `AmazonSageMakerReadOnly`, Canvas `AmazonSageMakerCanvasFullAccess`+`AmazonSageMakerCanvasAIServicesAccess`, 파이프라인 `AmazonSageMakerPipelinesIntegrations`, Feature Store `AmazonSageMakerFeatureStoreAccess`, 모델 거버넌스 `AmazonSageMakerModelGovernanceUseAccess`, 모델 레지스트리 `AmazonSageMakerModelRegistryFullAccess` |
| 사용량 기반 최소 권한 | **IAM Access Analyzer 정책 생성**(정적 활동 템플릿 대신 실제 CloudTrail 접근 패턴 기반) |
| 인력 ID·중앙 접근 관리 | **AWS IAM Identity Center** 권한 세트, 외부 IdP 연합, Studio와의 trusted identity propagation |
| 반복 가능한 거버넌스 | CloudFormation·CDK로 역할 정의 |

- **기존 Role Manager가 만든 역할은 정리·마이그레이션이 필요 없습니다** — Role Manager 런타임 의존성이 없는 표준 IAM 역할입니다

> 🧠 원리: Role Manager는 사전 정의된 **정적 활동 템플릿**이고, Access Analyzer는 실제 사용 기록에 맞춘 **사용량 기반 권고**입니다. 문서는 **후자가 정적 템플릿을 대체**한다고 설명합니다.

⚠️ **이름이 같은 다른 기능.** AWS Security Blog가 소개하는 **IAM role manager**는 IAM 콘솔 Account settings에서 켜며, 지원 서비스 콘솔에서 리소스를 만들 때 AWS가 필요한 IAM 역할을 만들어 붙여 줍니다. **SageMaker 콘솔의 SageMaker Role Manager(페르소나 기반)와는 켜는 위치·동작이 다릅니다.** 가이드가 말하는 대상은 **SageMaker Role Manager** 입니다.

### 4) 조건 키로 보안 설정 강제 {#condition-key-guardrails}

SageMaker는 `sagemaker:` 접두 조건 키로 **"리소스를 만들 때 요청에 담긴 보안 설정"** 을 IAM 정책에서 검사하게 해 줍니다. 키의 실존·타입·의미의 정본은 **Service Authorization Reference** 입니다.

| 강제하려는 것 | 조건 키(타입) | 정책에서의 쓰임 |
|---|---|---|
| ML 볼륨 KMS 암호화 | **`sagemaker:VolumeKmsKeyArn`**(ARN). 구 이름 `sagemaker:VolumeKmsKey`는 **deprecated** | 노트북·Studio 도메인(EFS)·훈련/처리/변환/튜닝에서 키가 없으면(`Null: "true"`) Deny. 특정 키만 허용은 `ArnEquals` |
| 출력 KMS 암호화 | `sagemaker:OutputKmsKeyArn`(ARN). 구 `OutputKmsKey`는 deprecated | 키 지정 여부 검사 |
| VPC 안에서만 실행 | `sagemaker:VpcSubnets`·`sagemaker:VpcSecurityGroupIds`(ArrayOfString) | 훈련·튜닝·처리·모델·노트북 생성에서 **둘 다 없으면 Deny.** 허용 서브넷·SG만: `ForAllValues:StringEquals` + `Null: "false"` |
| 컨테이너 네트워크 차단 | `sagemaker:NetworkIsolation`(Bool) | **`false`이면 Deny**(훈련·튜닝). 허용형은 `Bool true`일 때만 Allow |
| 노드 간 트래픽 암호화 | `sagemaker:InterContainerTrafficEncryption`(Bool) | `false`이면 Deny. ⚠️ **훈련 속도가 느려질 수 있다고 문서가 주의** |
| 노트북 직접 인터넷 | `sagemaker:DirectInternetAccess`(String) | **`Enabled`이면 Deny.** 허용형은 `Disabled` + VPC 지정일 때만 Allow |
| 노트북 root 권한 | `sagemaker:RootAccess`(String) | `Enabled`이면 Deny(`CreateNotebookInstance`·`UpdateNotebookInstance`) |
| Studio 도메인 인터넷 | `sagemaker:AppNetworkAccessType`(String) | **`PublicInternetOnly`이면 `CreateDomain` Deny** |
| 인스턴스 유형 제한 | `sagemaker:InstanceTypes`(ArrayOfString) | 허용 유형 목록 밖이면 Deny(**비용 통제**) |
| 모델 승인 상태 | `sagemaker:ModelApprovalStatus` | Model Registry 승인 단계 통제 |
| 훈련 입력 파일 시스템 | `sagemaker:FileSystemId`·`FileSystemDirectoryPath`·`FileSystemAccessMode`·`FileSystemType` | EFS·FSx 경로·읽기 전용 모드로 한정 |
| 태그 | `aws:RequestTag/<키>`, `sagemaker:ResourceTag/<키>` | 필수 태그 강제, 팀별 접근 분리 |

**Deny 가드레일 예** — 훈련·튜닝 작업에서 네트워크 격리가 꺼져 있으면 거부합니다.

```json
{
  "Effect": "Deny",
  "Action": ["sagemaker:CreateHyperParameterTuningJob", "sagemaker:CreateTrainingJob"],
  "Resource": "*",
  "Condition": { "Bool": { "sagemaker:NetworkIsolation": "false" } }
}
```

**두 가지 정책 패턴**

1. **Allow + 조건** — 조건을 만족할 때만 허용. 문서 예: `CreateNotebookInstance`를 `DirectInternetAccess=Disabled`·`RootAccess=Disabled`이고 서브넷·보안 그룹이 지정된 경우에만 허용
2. **Deny + 조건(가드레일)** — 조건을 만족하지 않는 요청을 거부. 백서의 가드레일 예제는 **모두 Deny 문장**이며 조직 단위 적용은 **AWS Organizations의 SCP**가 맡습니다

> 🧠 원리: 정책 평가에서 **명시적 거부는 어떤 허용보다 우선**합니다. 그래서 **"다른 정책이 허용해도 막아야 하는"** 필수 통제(암호화·VPC·격리)는 **Deny 형태**로 씁니다.

**호출 출처 제한(네트워크 조건)**

- API 호출을 VPC 안으로 제한: **`aws:SourceVpc`**(특정 VPC) 또는 인터페이스 엔드포인트 경유만 허용하려면 **`aws:SourceVpce`**
- IP 제한: `IpAddress` + **`aws:SourceIp`** 로 API·런타임 호출 또는 `CreatePresignedNotebookInstanceUrl`을 특정 대역에서만 허용. ⚠️ 노트북 인스턴스 접근을 IP로 거르는 방식은 **VPC 인터페이스 엔드포인트로 접속할 때와 호환되지 않습니다**
- ⚠️ **VPC 한정 IAM 정책을 적용하면 사용자는 콘솔로 해당 API를 쓸 수 없습니다**

⚠️ **키 이름 함정.** 문서 안에서도 불일치가 있습니다 — 예제 페이지의 본문은 `sagemaker:VolumeKmsKey`라고 쓰지만 JSON은 `sagemaker:VolumeKmsKeyArn`을 쓰고, 백서의 가드레일 예제도 구 이름을 씁니다. 현재 정본은 **`...Arn` 키가 대체 키**라고 명시합니다. **시험 보기는 구 이름일 수 있으니 둘을 함께 외우고, 키 이름 자체를 정답의 근거로 삼지 않습니다.**

### 5) ML 아티팩트 보호 {#artifact-protection}

| 아티팩트 | 어디에 | 접근 제어 수단 | 교차 계정·추가 주의 |
|---|---|---|---|
| 훈련 데이터·모델 아티팩트·출력 | **S3** | 실행 역할의 **요청 필드 단위 최소 권한**(2) 참조), 버킷 정책의 `aws:SourceVpce`·`aws:SourceVpc` 조건 | 기본 암호화는 SSE-S3지만 ⚠️ **교차 계정은 고객 관리형 키 필요.** S3 버전 관리 + MFA delete로 삭제·변조 대비 |
| 컨테이너 이미지 | **ECR** | 리포지토리 정책(리소스 기반), **불변 태그**, 이미지 스캔 | ⚠️ 다른 계정 주체를 정책에 넣는 것은 **신뢰의 절반**이며, 그 주체에 **ID 기반 정책으로도** 권한을 줘야 한다 |
| 모델 버전 | **Model Registry**(모델 패키지 그룹) | 모델 패키지 그룹 리소스 정책, `sagemaker:ModelApprovalStatus` 조건 키 | 교차 계정 배포는 **모델 그룹·ECR 리포지토리·S3 버킷 3종 정책 + 학습 출력 KMS 키** 필요 |
| 데이터 레이크 테이블·위치 | Glue Data Catalog / S3 | **Lake Formation 권한** + IAM 정책으로 세분화 | Data Catalog 리소스를 외부 계정과 공유 가능 |
| 접속 정보·토큰 | **Secrets Manager** | 코드에 넣지 않고 **런타임에 조회**, 실행 역할에 조회 권한 부여 | 11) 참조 |

- **S3 버킷 정책 + VPC 엔드포인트.** 특정 VPC 엔드포인트가 아니면 모든 작업을 거부하는 **`Deny` + `StringNotEquals aws:SourceVpce`** 패턴이 S3 문서의 예제입니다. ⚠️ 이 정책은 **콘솔 요청이 그 엔드포인트에서 오지 않으므로 콘솔 접근도 막아 버릴 수 있습니다.** 엔드포인트 쪽에서도 정책을 걸 수 있으나 **기본 엔드포인트 정책은 VPC 내 모든 사용자·서비스에 S3 전체 접근을 허용**합니다
- **KMS.** AWS KMS는 **키 정책·IAM 정책·그랜트와 SCP·VPC 엔드포인트 정책을 함께 평가**해 키 사용 허용 여부를 결정합니다
- **교차 계정 모델 배포 레시피.** 모델 그룹에 `sagemaker:DescribeModelPackageGroup`, 모델 버전 리소스에 `DescribeModelPackage`·`ListModelPackages`·`UpdateModelPackage`·`CreateModel`을 상대 계정에 허용하는 리소스 정책, **ECR 리포지토리 정책, S3 버킷 정책, KMS 그랜트를 모두** 만듭니다. ⚠️ **하나라도 빠지면** `CreateModel`이 "no resource-based policy allows the sagemaker:CreateModel action"으로 실패합니다
- ⚠️ **AWS 관리형 키는 공유할 수 없습니다.** S3용 AWS 관리형 키의 키 정책은 **편집할 수 없어** 교차 계정 권한을 줄 수 없습니다 → 출력 버킷이 다른 계정이면 **고객 관리형 키를 요청에 명시**하고 실행 역할에 암호화 권한을 줍니다

⚠️ 문서의 교차 계정 예제 코드는 ECR에 `ecr:*`, S3에 `s3:*` 처럼 **넓은 권한을 상대 계정에 줍니다.** 더 좁힐 수 있는지는 문서에 없으므로 **"예제 그대로가 최소 권한"이라고 단정하지 않습니다.**

> 🧠 원리: 교차 계정 접근은 **"리소스 쪽 허용"과 "주체 쪽 허용"이 모두 있어야** 성립합니다. 따라서 모델·이미지·아티팩트·키는 **각각 리소스 정책이 필요**합니다.

### 6) 암호화 — 저장 중·전송 중 {#ml-encryption}

> ℹ️ 데이터셋 자체의 암호화·민감정보 처리는 `mla-t1-3` 암호화·민감정보가 정본입니다. 여기서는 **SageMaker 리소스**(볼륨·작업 출력·노드 간 통신) 쪽만 다룹니다.

**저장 중(at rest)**

| 대상 | 기본 동작 | 사용자가 KMS 키를 주면 | 제약 |
|---|---|---|---|
| 노트북·모델 구축 데이터·모델 아티팩트·훈련/배치 변환/처리 출력 | **AWS 관리형 S3 키로 SSE-S3 자동 암호화** | 작업 요청에 KMS 키 지정(출력은 S3에 KMS로 암호화 업로드) | ⚠️ 교차 계정은 **고객 관리형 키 필수.** S3 Express One Zone·디렉터리 버킷은 **SSE-S3만, SSE-KMS 불가** |
| **ML 스토리지 볼륨**(노트북·처리·훈련·튜닝·변환·엔드포인트) | ⚠️ 키를 안 주면 **일시적(transient) 키로 암호화 후 즉시 폐기.** 노트북 인스턴스는 OS·ML 볼륨 모두 시스템 관리 KMS 키 | KMS 키 전달(볼륨 지정 시 실행 역할에 **`kms:CreateGrant`**) | ⚠️ **로컬 스토리지가 있는 Nitro 인스턴스는 하드웨어 모듈로 암호화**되며 이 유형에는 KMS 키를 쓸 수 없다 |
| 작업 출력(S3) | 키 미지정 시 **역할 계정의 기본 S3용 KMS 키** | | |

> 🧠 원리: 처리·배치 변환·훈련 컨테이너와 저장소는 **임시적(ephemeral)** 입니다. 작업이 끝나면 출력이 S3에 업로드되고 인스턴스가 해체되므로, **지속되는 민감 데이터는 KMS로 암호화한 S3나 ML 스토리지 볼륨**에 둡니다.

**전송 중(in transit)**

- 서비스 간 **인터네트워크** 전송은 **TLS 1.2를 지원**합니다(TLS 1.3 권장)
- ⚠️ **서비스 플랫폼 내부(intranetwork)의 일부 전송은 기본적으로 암호화되지 않습니다** — ① 서비스 제어 평면 ↔ 훈련 인스턴스 통신(고객 데이터 아님) ② **분산 처리 작업 노드 간** ③ **분산 훈련 작업 노드 간**
- 설정: 훈련·튜닝 작업 요청에 **`EnableInterContainerTrafficEncryption=True`** 를 주고, API 사용 시 VPC 보안 그룹에 **UDP 500**과 **ESP 50**(자기 보안 그룹 ID를 소스로) 인바운드·아웃바운드 규칙을 **먼저** 추가합니다
- ⚠️ **단일 인스턴스 작업에는 영향이 없고**, 다중 인스턴스에서는 통신량에 따라 **훈련 시간·비용이 늘 수 있습니다**
- **FIPS 검증 엔드포인트**가 SageMaker API와 호스팅 모델 요청 라우터(런타임)에 제공됩니다

> 🧠 원리: 분산 ML 프레임워크가 노드 간에 보내는 정보는 **일반적으로 훈련 데이터셋이 아니라 가중치 같은 모델 관련 정보**입니다. 그래도 **규제 요구가 있으면** 노드 간 트래픽 암호화를 켭니다.

**데이터 보호 권고(요약)** — MFA, SSL/TLS, CloudTrail 로깅, AWS 암호화 솔루션 사용, **S3의 민감 데이터 발견에 Macie** 사용.

### 7) 네트워크 격리 수단 비교 {#isolation-compare}

**출발점.** ⚠️ SageMaker AI **훈련 컨테이너와 배포된 추론 컨테이너는 기본적으로 인터넷이 열려 있습니다.** 악의적 사용자나 실수로 설치한 공개 라이브러리 코드가 데이터를 원격 호스트로 보낼 수 있는 경로가 되므로 용도에 맞는 격리 수단을 고릅니다.

| 수단 | 설정 | 효과 | 핵심 제약·함정 |
|---|---|---|---|
| 기본(미설정) | — | 컨테이너가 **퍼블릭 인터넷의 외부 서비스·리소스에 접근 가능.** VPC 구성이 없으면 **사용자 VPC 안의 리소스에는 접근하지 못한다** | 데이터 반출 경로가 열려 있음 |
| **VPC 모드** | 훈련·튜닝 `VpcConfig` · 모델 `CreateModel`의 `VpcConfig` · 처리 `NetworkConfig.VpcConfig` · 노트북 `SubnetId`+`SecurityGroupIds` | SageMaker가 서브넷·보안 그룹 정보로 **ENI를 만들어 컨테이너에 붙여** VPC 리소스에 접근시킨다. 트래픽·인터넷 접근은 **사용자가 보안 그룹·라우팅으로 통제** | 추가 네트워크 구성 비용과 **잘못 구성할 위험.** `Subnets` 최대 **16개**, `SecurityGroupIds` 최대 **5개**. ⚠️ **default tenancy VPC만** |
| **네트워크 격리** | **`EnableNetworkIsolation=True`**(`CreateTrainingJob`·`CreateHyperParameterTuningJob`·`CreateModel`) | 훈련·추론 컨테이너는 **S3를 포함한 어떤 서비스로도 아웃바운드 호출을 못 하고 AWS 자격 증명도 받지 못한다.** S3 다운로드·업로드는 **SageMaker가 실행 역할로 컨테이너와 별도로** 처리 | 다중 인스턴스 훈련은 **컨테이너 피어 간 통신만** 허용. ⚠️ **AWS Marketplace 리소스로 훈련·모델 실행 시 필수.** ⚠️ Chainer·강화 학습 관리형 컨테이너는 S3 접근이 필요해 **미지원** |
| 네트워크 격리 **+** VPC | 둘 다 지정 | 데이터·아티팩트 업·다운로드는 **사용자 VPC 서브넷을 경유**하지만 **컨테이너 자체는 계속 격리**되어 VPC·인터넷 리소스에 접근하지 못한다 | `VpcConfig`를 지정하면 네트워크 격리는 **알고리즘 컨테이너용 ENI를 만들지 않고 S3용 ENI만** 남긴다 |
| **Studio 도메인 `VpcOnly`** | `CreateDomain`의 **`AppNetworkAccessType=VpcOnly`**(기본값 `PublicInternetOnly`) | **EFS 외 모든 트래픽이 지정한 VPC·서브넷을 경유**하고 인터넷은 기본 비활성 | ⚠️ **사설 서브넷만** 가능. **인터페이스 엔드포인트 또는 NAT가 없으면 Studio 노트북·훈련·호스팅을 못 한다** |
| **노트북 인스턴스** | **`DirectInternetAccess=Disabled`** — `SubnetId` 지정 필수 | VPC 안의 리소스만 접근. SageMaker 훈련·엔드포인트 서비스에 닿으려면 **NAT 게이트웨이(또는 VPC 엔드포인트)** 필요 | `DirectInternetAccess`·`KmsKeyId` 변경은 **리소스 교체(Replacement).** ⚠️ **생성 후 네트워크 설정은 변경할 수 없다** |

> 🧠 원리(네트워크 격리가 성립하는 이유): 격리를 켜도 **입력 데이터 다운로드와 CloudWatch 로그·메트릭 전송은 노드에서 도는 SageMaker 내부 프로세스가 컨테이너와 별개로** 수행합니다. 컨테이너는 **입력 채널로 제공된 데이터만 읽고**, 어떤 경우에도 AWS 자격 증명을 받지 않습니다.

**구분 포인트.** 컨테이너가 **외부 네트워크 접근을 아예 받지 않게** 하는 수단은 **네트워크 격리**뿐입니다. VPC 모드는 **트래픽을 사용자가 통제하는 VPC 경로로 돌리는** 수단이며, VPC 밖 리소스가 필요하면 **인터페이스 엔드포인트나 NAT 게이트웨이**(+ 보안 그룹 아웃바운드 허용)를 직접 구성해야 합니다.

**리소스별 설정 위치**

| 리소스 | VPC 지정 | 인터넷·격리·암호화 설정 |
|---|---|---|
| 노트북 인스턴스 | `SubnetId`, `SecurityGroupIds` | `DirectInternetAccess`, `RootAccess` |
| Studio 도메인 | `VpcId`, `SubnetIds`(+ 보안 그룹) | `AppNetworkAccessType` |
| 훈련·튜닝 작업 | `VpcConfig` | `EnableNetworkIsolation`, `EnableInterContainerTrafficEncryption` |
| 처리 작업 | `NetworkConfig.VpcConfig` | — |
| 모델·엔드포인트 | `CreateModel`의 `VpcConfig` | `EnableNetworkIsolation` |

**노트북 인스턴스의 root 권한.** ⚠️ **기본값은 사용자에게 root 접근이 있습니다.** `RootAccess=Disabled`로 끌 수 있지만, **수명 주기 구성 스크립트는 root로 실행되어 노트북 실행 역할의 전체 권한을 상속**하므로 수명 주기 구성 **변경 권한을 신뢰된 관리자에게만** 주고 CloudWatch Logs(`/aws/sagemaker/NotebookInstances`)로 감시해야 합니다.

> ℹ️ VPC 모드를 **배포 인프라로 선언·구성**하는 쪽은 `mla-t3-2` 12) VPC 엔드포인트가 정본입니다. 여기서는 **보안 설계 관점의 격리 수단 비교**를 다룹니다.

### 8) VPC·서브넷·보안 그룹과 엔드포인트 요건 {#vpc-requirements}

**서브넷 크기·가용 영역**

- 훈련 인스턴스당 사설 IP는 **EFA를 쓰지 않으면 최소 2개, EFA를 쓰면 최소 5개**
- ⚠️ 호스팅은 **인스턴스가 하나여도 서로 다른 가용 영역에 서브넷 2개 이상**을 만들어야 합니다
- Studio는 **사용자당 IP 2~4개 권장**이며 여러 가용 영역에 퍼진 서브넷이 IP 가용성에 유리합니다
- ⚠️ 훈련·Studio 모두 **default tenancy VPC의 서브넷만** 구성할 수 있습니다
- **훈련 컨테이너 이미지용 서브넷은 따로 지정하지 않습니다** — SageMaker가 ECR에서 이미지를 자동으로 가져옵니다(처리 작업도 같음)

**보안 그룹 규칙**

| 시나리오 | 필요한 규칙 |
|---|---|
| 분산 훈련(컨테이너끼리 통신) | **같은 보안 그룹 구성원 간 인바운드 허용(자기 참조).** EFA 인스턴스는 같은 보안 그룹 대상 **인바운드·아웃바운드 모두 전체 트래픽** 허용 |
| 컨테이너 간 트래픽 암호화 | **UDP 500, ESP 50** — 소스는 **자기 보안 그룹 ID**, 인바운드·아웃바운드 |
| Studio `VpcOnly` | 도메인↔EFS 사이 **NFS(TCP 2049)**, 보안 그룹 내 TCP(문서 기준 **8192–65535**). ⚠️ 앱을 띄우려면 **2049를 인·아웃바운드 모두** 허용 |
| Studio 사용자 프로필 분리 | ⚠️ **프로필마다 고유 보안 그룹 권장**, 도메인 수준 보안 그룹 재사용은 비권장 — 도메인 SG가 자기 자신으로의 인바운드를 허용하면 **도메인의 모든 앱이 서로 접근 가능**하고, 지나치게 허용적이면 VPC 접근자가 **인증 없이 다른 프로필의 앱과 상호작용**할 수 있습니다 |
| 인터페이스 VPC 엔드포인트 | 엔드포인트에 **VPC의 보안 그룹을 연결**해야 함. ECR 엔드포인트의 보안 그룹은 사설 서브넷에서 오는 **포트 443 인바운드** 허용 |
| `VpcOnly`에서 노트북 실행 | 보안 그룹이 **아웃바운드 연결을 허용** |

**엔드포인트·NAT 요건**

| 필요한 연결 | 방법 | 비고 |
|---|---|---|
| **S3**(데이터·모델 아티팩트) | **게이트웨이 엔드포인트** `com.amazonaws.<region>.s3` — 라우트 테이블에 연결하면 S3 라우트가 자동 추가. **추가 요금 없음** | ⚠️ 인터넷이 막힌 VPC의 훈련 컨테이너는 **S3 엔드포인트가 없으면 버킷에 접근하지 못합니다.** ⚠️ 게이트웨이 엔드포인트는 **온프레미스·다른 리전 피어링·Transit Gateway 접근에는 못 씁니다.** 표준 S3 URL이 해석되도록 **기본 DNS 설정**을 씁니다 |
| **SageMaker API·Runtime** | **인터페이스 엔드포인트(PrivateLink)** `com.amazonaws.<region>.sagemaker.api`, `...sagemaker.runtime`. Feature Store Runtime은 별도 | ⚠️ **Runtime 엔드포인트는 클라이언트가 있는 AZ에서 활성화**해야 사설 DNS가 동작합니다. 사설 DNS를 켜면 기본 호스트명이 VPC 엔드포인트로 해석됩니다 |
| Studio 프로젝트 | `com.amazonaws.<region>.servicecatalog` | |
| Python SDK 원격 훈련 | `com.amazonaws.<region>.sts`, `com.amazonaws.<region>.logs` | 훈련 작업 상태 조회 |
| 인터넷·외부 리소스 | **NAT 게이트웨이** + 보안 그룹 아웃바운드 허용 | 인터페이스 엔드포인트를 지원하지 않는 서비스나 AWS 밖 리소스. Studio에서 인터넷을 허용하려면 NAT 필요 |
| 백서 권장(데이터 과학자 환경) | S3, SageMaker API, SageMaker Runtime, Feature Store Runtime, STS, CloudWatch, CloudTrail, ECR, CodePipeline, CodeBuild, CodeArtifact | |

⚠️ **"ECR 엔드포인트가 필수"라고 단정하지 않습니다.** SageMaker 훈련·처리 문서는 **SageMaker가 컨테이너 이미지를 ECR에서 자동으로 가져온다**고만 서술하고, Studio `VpcOnly` 필수 엔드포인트 목록에 ECR은 없습니다. ECR 문서가 안내하는 `ecr.api`·`ecr.dkr` 엔드포인트는 **ECR을 직접 쓰는 클라이언트**의 구성입니다(백서는 데이터 과학자 환경에 권장).

**엔드포인트 정책·PrivateLink의 보안 포인트**

- **VPC 엔드포인트 정책**으로 주체·액션·리소스를 제한할 수 있습니다. 문서 예: `sagemaker:InvokeEndpoint`를 특정 엔드포인트에만 허용하면 다른 API와 다른 엔드포인트 호출은 **이 VPC 엔드포인트를 통해서는** 거부됩니다. ⚠️ **VPC 밖에서의 호출은 이 정책으로 막히지 않으므로 별도 IAM 정책**이 필요합니다. ⚠️ FIPS 런타임 엔드포인트의 `InvokeEndpoint`는 **VPC 엔드포인트 정책을 지원하지 않습니다**
- **presigned URL**: `CreatePresignedNotebookInstanceUrl`이 돌려준 URL의 트래픽은 **퍼블릭 인터넷을 지나므로 VPC 엔드포인트만으로 접근할 수 없고**, 기본적으로 **사용자가 URL을 외부에 공유할 수 있어** IAM 권한으로 네트워크 내부에서만 쓰게 제한해야 합니다
- **온프레미스**에서 VPC 엔드포인트로 호출하려면 VPC 내 인스턴스를 거치거나 **Site-to-Site VPN·Direct Connect**로 연결합니다
- **패키지 설치 차단** — S3 엔드포인트 정책으로 Amazon Linux 패키지 저장소(`packages.*.amazonaws.com`·`repo.*.amazonaws.com`·`amazonlinux.*.amazonaws.com`)에 대한 `s3:GetObject`를 Deny하면 훈련·모델 컨테이너에서의 패키지 설치를 막을 수 있습니다
- 사용자 지정 IAM 정책으로 VPC 모델을 쓰려면 **ENI 관련 ec2 권한을 직접 추가**해야 합니다(`AmazonSageMakerFullAccess`에는 포함)

### 9) 격리 참조 설계 — 계층 방어 {#defense-layers}

**한 층이 뚫려도 다음 층이 막도록 겹쳐 쓰는 것이 핵심입니다.**

| 층 | 구성 |
|---|---|
| **네트워크 경계** | 전용 VPC의 **사설 서브넷**(호스팅은 서로 다른 AZ 2개 이상), 인터넷 게이트웨이로 직접 나가는 경로 없음. 외부 라이브러리는 **격리 전에 CodeArtifact 같은 사설 저장소로** 가져옴 |
| **트래픽 통제** | **보안 그룹(인스턴스 수준)과 네트워크 ACL(서브넷 수준)** 로 이중 통제 |
| **서비스 접근 경로** | S3 **게이트웨이** 엔드포인트 + SageMaker API/Runtime·STS·CloudWatch·ECR 등 **인터페이스** 엔드포인트. 엔드포인트 정책·버킷 정책으로 **경로를 고정** |
| **컨테이너** | **네트워크 격리**(필요하면 VPC와 병행), 분산 훈련은 **노드 간 트래픽 암호화** |
| **데이터** | KMS 볼륨·출력 키, S3 기본 암호화·**버전 관리** |
| **권한** | 실행 역할 최소 권한 + **SCP·Deny 가드레일**(4) 참조) |
| **접속** | Studio **`VpcOnly`**, presigned URL은 **`aws:SourceIp`로 제한.** 온프레미스는 Direct Connect·VPN, 여러 계정·온프레미스 라우팅은 Transit Gateway |
| **관측** | **VPC Flow Logs**로 훈련 클러스터의 입출력 트래픽 감시, CloudTrail·Config(12) 참조) |

**트래픽 흐름 요약**

- 사설 서브넷의 Studio·노트북 → (인터페이스 엔드포인트 `sagemaker.api`·`sagemaker.runtime`·`sts`·`logs`·`servicecatalog`) → SageMaker API
- 사설 서브넷의 훈련·처리 ENI → (**S3 게이트웨이 엔드포인트**) → S3
- 인터넷이 꼭 필요한 경우에만 사설 서브넷 → **NAT 게이트웨이** → 인터넷

### 10) 거버넌스·규정 준수 {#governance-compliance}

**거버넌스 도구**(문서는 "권한 관리와 모델 성능 추적"을 위한 도구로 묶습니다)

| 기능 | 무엇을 하나 | 시험 포인트 |
|---|---|---|
| **Model Cards** | 모델의 **의도된 사용**(적합·부적합 시나리오·가정), **위험 등급**(`unknown`·`low`·`medium`·`high`), 훈련 상세·지표, 평가 결과·관찰, 권고 사항을 한곳에 문서화. **PDF 내보내기** 가능 | ⚠️ **승인 상태 갱신 외의 편집은 새 버전을 만들어 불변 기록을 유지.** 감사 활동 지원·책임 있는 AI. Model Registry와 통합 |
| **Model Dashboard** | 계정 안 **모든 모델의 사전 구성된 시각적 개요.** Model Monitor·변환 작업·엔드포인트·ML 계보 추적·CloudWatch 정보를 **한 화면에 통합** | ⚠️ 통합 대상 중 Model Monitor는 신규 고객 중단 |
| **Role Manager** ⚠️ | 최소 권한 페르소나 역할(3) 참조) | 신규 고객 불가 |
| SageMaker Assets | ML·데이터 자산을 게시·공유·구독하는 워크플로(관리자가 Amazon DataZone으로 설정) | ⚠️ DataZone은 가이드의 **범위 외** 서비스이므로 깊게 보지 않는다 |

⚠️ 모델 카드는 **Clarify나 Model Monitor가 만든 JSON 평가 리포트를 S3 URI로 올려** 평가 지표를 자동 파싱하게 할 수 있지만, **두 기능은 모두 신규 고객에게 닫혀 있습니다.**

**규정 준수 검증**

- ⚠️ SageMaker AI의 규정 준수 문서는 **개별 프로그램을 나열하지 않습니다.** 서비스가 특정 프로그램 범위에 있는지는 **"AWS Services in Scope by Compliance Program"** 에서 확인하고, **제3자 감사 보고서는 AWS Artifact**로 내려받습니다. 규정 준수 **책임은 데이터 민감도·회사 목표·법규에 따라 사용자가** 집니다
- **HIPAA**: "Amazon SageMaker AI [formerly Amazon Sagemaker]"가 **HIPAA 적격 서비스 목록**에 있으며(목록 갱신일 2026-10-15) 일부 기능은 제외로 표시돼 있습니다. ⚠️ **적격 서비스라도 고객이 HIPAA 요건에 맞게 구성**해야 합니다
- ⚠️ **AWS Artifact·Audit Manager는 가이드의 범위 외 서비스**입니다(보기 구분용으로만 알아 둡니다)

**출제 범위 한정** — 규정 준수 문항은 **"범위 확인은 AWS Services in Scope by Compliance Program, 보고서는 AWS Artifact, HIPAA는 적격 서비스 목록"** 까지입니다. 개별 프로그램(PCI DSS·SOC 등)의 목록은 공식 문서에 없으므로 외우지 않습니다.

### 11) CI/CD 파이프라인 보안 {#cicd-security}

> ℹ️ CodePipeline·CodeBuild·CodeDeploy의 **구조와 동작 자체**는 `mla-t3-3` CI/CD가 정본입니다. 여기서는 **보안 모범 사례**만 다룹니다.

| 영역 | 모범 사례 |
|---|---|
| **비밀 관리** | ⚠️ **CodePipeline**: 파이프라인·액션 구성이나 파이프라인 변수 기본값에 토큰·비밀번호를 **직접 입력하지 않는다**(로그에 표시됨). Secrets Manager에 저장하고 참조. ⚠️ **CodeBuild**: 민감 값을 **`PLAINTEXT` 환경 변수에 두지 않는다**(콘솔·CLI에 평문 노출) — 유형을 **`PARAMETER_STORE` 또는 `SECRETS_MANAGER`** 로 |
| 로그 마스킹의 한계 | ⚠️ CodeBuild 로그는 Parameter Store·Secrets Manager 문자열을 숨기지만 **저장된 값과 정확히 일치할 때만** 가려진다. **Base64 인코딩 등 변환한 값은 다른 문자열이라 마스킹되지 않는다** |
| Secrets Manager vs Parameter Store | **Secrets Manager는 자동 교체(rotation)를 설정할 수 있다.** Parameter Store는 **저장된 비밀의 자동 교체 서비스를 제공하지 않으며**, 비밀을 Secrets Manager에 두고 Parameter Store 파라미터로 **참조**하는 방식을 안내 |
| SageMaker와 Secrets Manager | 노트북 인스턴스에 연결하는 **Git 비공개 저장소 자격 증명**을 Secrets Manager로 관리. 코드에 자격 증명을 넣지 말고 **실행 역할에 Secrets Manager 접근 권한**을 줘서 조회 |
| **서비스 역할 최소 권한** | CodeBuild는 **빌드 유형별로 목적이 분리된 최소 권한 역할**을 쓴다(**테스트 빌드 역할과 릴리스 빌드 역할을 분리**). CloudTrail 활동에서 **IAM Access Analyzer 정책 생성** 활용 |
| 신뢰 정책 | CodeBuild 서비스 역할 신뢰 정책(`codebuild.amazonaws.com`)에 **`aws:SourceAccount`·`aws:SourceArn`** 조건 키로 혼동된 대리인 방지 |
| 액션별 역할 | CodePipeline의 **각 액션에 별도 IAM 역할**을 두는 것이 최소 권한 모범 사례 |
| SageMaker Pipelines | 파이프라인 실행 역할을 전달하는 쪽에 `iam:PassRole` 필요. **단계마다 다른 역할**을 줘 단계 간 영향 범위를 분리 |
| **아티팩트 암호화** | CodePipeline S3 아티팩트는 서버 측 암호화를 구성. ⚠️ 생성 마법사가 만드는 **기본 키는 AWS 관리형 키이고 변경·삭제 불가**, 고객 관리형 키는 교체·변경 가능. ⚠️ **CodePipeline은 대칭 KMS 키만 지원.** 버킷 정책으로 **SSE-KMS가 아닌 업로드와 `aws:SecureTransport=false` 요청을 거부** 가능 |
| **교차 계정 배포** | 파이프라인 계정(A)에서 **고객 관리형 KMS 키**를 만들어 서비스 역할과 B 계정에 사용 권한을 주고, 아티팩트 버킷 정책으로 B 접근을 허용하며, B의 교차 계정 역할을 A의 서비스 역할이 **`sts:AssumeRole`** 로 assume. 파이프라인에는 **기본 키 대신 고객 관리형 키**를 쓰도록 편집. ⚠️ **파이프라인 계정이 아닌 두 계정 사이에서는 아티팩트를 전달할 수 없다** |
| **수동 승인** | 승인 액션 앞에서 파이프라인이 멈추고 **IAM 권한이 있는 주체가** 승인·거부. ⚠️ **거부되거나 7일 안에 응답이 없으면 액션 실패와 같다.** ⚠️ **Source 스테이지에는 추가할 수 없다.** SNS 알림을 쓰려면 **서비스 역할에 SNS 권한**을, 승인 상태를 갱신할 주체에는 **승인 권한**을 먼저 부여 |
| 수동 승인 + 자동 검사 | **자동 보안 스캔을 통과한 뒤** 민감 환경으로 가기 전에 사람 검토 게이트를 둔다 |
| **컨테이너 이미지** | ECR 스캔 **Basic**(AWS 네이티브 기술+CVE DB, OS 취약점, 수동·푸시 시 스캔)과 **Enhanced**(Amazon Inspector 연동, **자동·지속 스캔**, OS+**언어 패키지**). **불변 태그**로 같은 태그 덮어쓰기를 막고 시도 시 `ImageTagAlreadyExistsException`. 리포지토리 정책은 **리소스 기반 정책** |
| 빌드 네트워크 | CodeBuild를 VPC에서 돌릴 때 **사설 서브넷만**, 보안 그룹은 **빌드로의 인바운드 불허**, 빌드가 공용 엔드포인트에 닿으려면 ⚠️ **NAT 게이트웨이**(인터넷 게이트웨이로 대체 불가) 필요, 다중 AZ |
| 소스·웹훅 | ⚠️ **신뢰할 수 없는 기여자의 PR을 자동 빌드하지 않는다**(저장소 자격 증명·환경 변수 접근). push 이벤트 빌드, 브랜치 필터, 신뢰 기여자 필터, **최소 범위의 토큰을 Secrets Manager에** 저장 |
| 구성 변경 감사 | **CloudTrail**로 빌드 활동, **AWS Config**로 CodeBuild 프로젝트 구성(웹훅 필터 포함) 변경 이력·알림 |
| 의존성 | 외부 라이브러리는 **CodeArtifact 같은 사설 저장소**에 가져와 두고 환경을 격리 |
| 코드 검토 ⚠️ | **Amazon CodeGuru Reviewer는 2025-11-07부터 새 저장소 연결을 만들 수 없다.** 대안으로 **Amazon Q Developer**(SAST·비밀 노출 탐지·의존성 취약점)와 **Amazon Inspector Code Security**를 안내 |

> 🧠 원리: CI/CD 파이프라인은 **"코드를 실행하는 곳"** 이어서 자격 증명·환경 변수·서비스 역할이 **곧 공격 표면**입니다. 문서가 반복해서 권하는 축은 다섯입니다 — ① 비밀을 구성·환경 변수에 평문으로 두지 않는다 ② 역할을 **단계·용도별로 쪼개** 최소 권한으로 둔다 ③ 아티팩트를 KMS로 암호화한다 ④ 민감 단계 앞에 **사람 승인 게이트**를 둔다 ⑤ **신뢰할 수 없는 입력(외부 PR)을 자동 실행하지 않는다.**

### 12) 모니터링·감사·로깅 {#security-audit}

| 질문 | 쓸 서비스 | 보는 것 | 주의 |
|---|---|---|---|
| **누가** 이 리소스를 만들고·지우고·바꿨나? | **CloudTrail 관리 이벤트** | SageMaker **제어 영역 작업은 전부 관리 이벤트로 기록**(`eventSource`=`sagemaker.amazonaws.com`) | 기본 기록. **이벤트 기록은 지난 90일 관리 이벤트의 조회·검색·다운로드 가능한 불변 기록**이며 조회 요금이 없다. 90일 이후는 **추적**이 필요 |
| **누가 엔드포인트를 호출**했나? | **CloudTrail 데이터 이벤트** | `AWS::SageMaker::Endpoint` — `InvokeEndpoint`·`InvokeEndpointAsync`·`InvokeEndpointWithResponseStream` | ⚠️ **기본으로 기록되지 않고 이벤트 기록에도 남지 않으며 추가 요금.** ⚠️ 이 호출들은 **요청 파라미터를 기록하지 않는다.** 고급 이벤트 선택기로 `eventName`·`readOnly`·`resources.ARN`을 걸러 필요한 것만 기록 |
| 구성이 **언제·어떻게 바뀌었나**, 규정(암호화·VPC·격리)에 맞나? | **AWS Config** | 구성 이력과 **관리형 규칙 평가** | 아래 규칙 표 |
| 성능·로그·경보 | **CloudWatch** Logs·Metrics·Alarms | 컨테이너·노트북 수명 주기 구성의 `stdout`/`stderr` | 로그는 기본 **무기한 보관**, 로그 그룹별로 보존 기간 설정 |
| S3의 훈련 데이터에 **민감 데이터가 어디** 있나? | **Amazon Macie** | ML·패턴 매칭으로 **S3 객체의 민감 데이터를 탐지**하고 버킷 인벤토리를 만들어 보안·접근 제어를 평가·모니터링 | SageMaker 데이터 보호 문서도 **S3의 민감 데이터 발견·보호에 Macie**를 권고 |
| 훈련 클러스터가 **어디와 통신**했나? | **VPC Flow Logs** | VPC 안에서 만든 훈련 작업의 **클러스터 입출력 트래픽** | |
| Studio에서 **실제 사용자**는 누구인가? | CloudTrail의 **`OnBehalfOf`** | trusted identity propagation을 켠 Studio 도메인에서 호출한 이벤트에 붙는 필드 | 실행 역할 신뢰 정책에 `sts:AssumeRole`과 함께 **`sts:SetContext`** 필요 |

⚠️ **CloudTrail Lake** — **2026-05-31부터 신규 고객에게 닫혔습니다.** 기존 고객은 계속 사용하며 **CloudTrail 추적·Insights·집계 이벤트는 영향이 없습니다.** 유사 기능은 CloudWatch를 보라고 안내합니다. SageMaker CloudTrail 문서가 90일 이후 기록을 위해 "추적 또는 CloudTrail Lake 이벤트 데이터 스토어"를 만들라고 서술하므로, **시험 지문의 Lake 언급은 이 상태를 감안해** 해석합니다.

> 🧠 구분 원리: IAM 조건 키·SCP(4) 참조)는 **요청을 거부하는 예방 통제**이고, Config 규칙은 **이미 존재하는 리소스의 구성을 평가해 NON_COMPLIANT로 표시하는 평가 통제**입니다. 규칙 문서의 정의("The rule is NON_COMPLIANT if ...")가 근거입니다.

**SageMaker 관련 Config 관리형 규칙**

| 규칙 | 평가 대상 | NON_COMPLIANT 조건 | 트리거 |
|---|---|---|---|
| `sagemaker-notebook-no-direct-internet-access` | NotebookInstance | 노트북 인스턴스가 **인터넷 사용 가능** | Periodic |
| `sagemaker-notebook-instance-inside-vpc` | NotebookInstance | **VPC 밖에서 시작**했거나 서브넷 ID가 승인 목록에 없음 | Configuration changes |
| `sagemaker-notebook-instance-root-access-check` | NotebookInstance | **`RootAccess`가 Enabled** | Configuration changes |
| `sagemaker-notebook-instance-kms-key-configured` | NotebookInstance | **`KmsKeyId` 미지정** | Periodic |
| `sagemaker-endpoint-config-kms-key-required` | EndpointConfig | **`KmsKeyId`가 설정되지 않음**(고객 관리형 키 요구) | Configuration changes |
| `sagemaker-model-isolation-enabled` | Model | **`EnableNetworkIsolation`이 false** | Configuration changes |
| `sagemaker-model-in-vpc` | Model | **`VpcConfig`가 없음** | Configuration changes |
| `sagemaker-domain-in-vpc` | Domain | **`AppNetworkAccessType`이 `VpcOnly`가 아님** | Configuration changes |

⚠️ 목록에는 `sagemaker-data-quality-job-isolation`·`sagemaker-model-bias-job-isolation`·`sagemaker-monitoring-schedule-isolation`·`sagemaker-featuregroup-encryption-at-rest`·`sagemaker-model-private-registry-required` 같은 규칙이 **더 있지만 세부 동작은 확인되지 않았습니다.** 출제 범위는 **위 8개**로 잡습니다.

**SageMaker 로그 그룹** — 엔드포인트 `/aws/sagemaker/Endpoints/[EndpointName]` · 처리 `/aws/sagemaker/ProcessingJobs` · **노트북 `/aws/sagemaker/NotebookInstances`**(수명 주기 구성 실행·`jupyter.log`) · Studio `/aws/sagemaker/studio` · 훈련 `/aws/sagemaker/TrainingJobs`. ⚠️ **노트북 수명 주기 구성은 노트북 실행 역할의 권한을 상속하므로 이 로그 그룹을 정기 점검**하라고 문서가 권고합니다.

### 13) 보안 문제 해결 {#security-troubleshoot}

| 증상(대표 오류) | 원인 | 조치 |
|---|---|---|
| `User: ... is not authorized to perform: iam:PassRole` | 호출 주체에게 **실행 역할을 서비스에 건넬 권한**이 없음 | 호출자 정책에 대상 역할 ARN + **`iam:PassedToService=sagemaker.amazonaws.com`** 조건의 `iam:PassRole` 추가 |
| 훈련 중 S3 `AccessDenied`(`AmazonSageMakerFullAccess`를 붙였는데도) | ① FullAccess는 **이름에 sagemaker·aws-glue가 든 버킷·객체만** 포괄 ② 입력이 KMS 암호화 → `kms:Encrypt`·`kms:Decrypt`와 **키 정책의 실행 역할 허용** 필요 ③ ML 볼륨에 KMS 키를 쓰면 **`kms:CreateGrant`** ④ **권한 경계가 정책과 AND로** 적용 ⑤ 버킷 정책의 Deny ⑥ 타 계정 소유 데이터는 **두 계정 모두 키 접근 필요** | 각 항목의 권한 추가·정책 수정. ⚠️ **API마다 필요한 S3 권한이 다릅니다** — `CreateModel`은 `s3:GetObject`만, `CreateTrainingJob`은 `s3:GetObject`·`s3:PutObject`·**`s3:ListBucket`** |
| 처리 작업 생성 시 VPC 관련 **검증 실패** | VPC용 `ec2:*NetworkInterface*` 권한에 **조건·리소스 필터를 건** 경우 | 해당 ec2 권한은 **조건·리소스 필터 없이** 부여 |
| VPC 모드 작업이 **S3 데이터를 못 가져옴** | 인터넷 없는 사설 서브넷에 **S3 VPC 엔드포인트(또는 NAT)가 없음**, 라우트 테이블·DNS 설정, 보안 그룹 아웃바운드 | **S3 게이트웨이 엔드포인트 + 라우트 테이블 연결**(기본 DNS 사용), 필요 시 NAT·인터페이스 엔드포인트 |
| 분산 훈련에서 **노드 간 연결 실패** | 보안 그룹이 **같은 그룹 구성원 간 인바운드를 막음.** 컨테이너 간 암호화를 켠 경우 **UDP 500·ESP 50 규칙 누락** | **자기 참조 규칙** 추가, 암호화 시 UDP 500·ESP 50 인·아웃바운드 추가 |
| Studio(`VpcOnly`) 노트북이 안 뜨거나 프로젝트 템플릿이 안 보임 | `sagemaker.api`·`sagemaker.runtime` 엔드포인트도 NAT도 없음, S3·`servicecatalog` 엔드포인트 없음, 보안 그룹 아웃바운드 차단, **NFS 2049 미허용**, 회사 방화벽이 websocket 차단 | 요건표(8) 참조)대로 엔드포인트+보안 그룹 연결. 터미널에서 `curl -v`로 연결 확인 — **Connection timed out이면 VPC 요건 점검** |
| 노트북 인스턴스(인터넷 차단)에서 훈련·배포 불가 | NAT 게이트웨이 없음 또는 보안 그룹 아웃바운드 차단 | NAT 게이트웨이 + 아웃바운드 허용, 인터넷을 피하려면 SageMaker API·Runtime VPC 엔드포인트. ⚠️ **생성 후 네트워크 설정은 못 바꾸므로 새 인스턴스를 만든다** |
| presigned URL 실행 시 "Not authorized" | `sagemaker:CreatePresignedNotebookInstanceUrl`(노트북) 또는 `sagemaker:CreatePresignedDomainUrl`(Studio) 권한 없음 | 해당 액션을 ID 기반 정책에 추가 |
| 교차 계정 `CreateModel`이 "no resource-based policy allows..." | 모델 패키지 그룹·S3 버킷(·ECR·KMS)의 **교차 계정 리소스 정책 미구성** | 5)의 교차 계정 레시피 적용 |
| 작업·엔드포인트 **로그 스트림이 없거나 비어 있음** | 실행 역할에 `cloudwatch:PutMetricData`·`logs:CreateLogStream`·`logs:PutLogEvents`·`logs:CreateLogGroup`·`logs:DescribeLogStreams`·`ecr:GetAuthorizationToken` 권한 부족 | 해당 권한을 실행 역할에 부여 |
| 네트워크 격리 후 컨테이너가 **S3·인터넷에 접근 못 함** | **설계상 모든 아웃바운드 호출 차단**(자격 증명도 없음) | ⚠️ **정상 동작.** 데이터는 입력 채널로 제공되고 S3 업·다운로드는 SageMaker가 처리 |
| KMS 관련 `AccessDenied` | KMS는 **키 정책·IAM 정책·그랜트·SCP·VPC 엔드포인트 정책을 함께 평가** | IAM·키 정책 허용 확인 → 권한 경계 → SCP·RCP → VPC 엔드포인트 정책 순으로 점검, **조건을 하나씩 제거하며** 원인 조건 식별 |
| 정책이 의도대로 동작하지 않음 | **명시적 거부**(ID 기반·리소스 기반·권한 경계·SCP·세션 정책 중 하나)가 허용을 덮어씀 | ⚠️ **여러 정책 유형이 거부해도 오류 메시지에는 한 유형만 나옵니다** — 적용되는 모든 정책을 검토 |
| VPC·엔드포인트 한정 정책 적용 후 **콘솔 접근 불가** | VPC 한정 IAM 정책은 콘솔 호출을 막고, 버킷 정책의 `aws:SourceVpce` Deny는 **콘솔 요청이 그 엔드포인트에서 오지 않아** 콘솔도 막음 | 의도된 효과인지 확인하고 **관리자용 예외 경로**를 설계 |

**진단 도구**

| 도구 | 용도 |
|---|---|
| CloudTrail Event history / trail | 누가·언제·어떤 API를 호출했는지. **사용자 이름으로 필터링** |
| **IAM 정책 시뮬레이터** | 실제 요청을 보내지 않고 ID 기반 정책·권한 경계·SCP·리소스 기반 정책이 요청을 허용·거부하는지 평가하고 **결정에 기여한 정책**을 보여 준다. ⚠️ 결과가 실제 환경과 다를 수 있어 라이브 확인 필요 |
| IAM Access Analyzer | 정책 검증·**CloudTrail 기반 정책 생성** |
| IAM Access Advisor | **서비스별 마지막 접근 정보**로 불필요 권한 식별 |
| CloudWatch Logs | 컨테이너·노트북 수명 주기 로그 |
| VPC Flow Logs | 훈련 클러스터 입출력 트래픽 |
| AWS Config 타임라인 | 구성 변경 이력 |

> 🧠 진단 순서: 오류가 **권한 문구**(`AccessDenied`·`not authorized`)면 **ID 기반 정책 → 리소스 정책(S3·ECR·KMS·모델 그룹) → 권한 경계·SCP** 순서로, **타임아웃**이면 **엔드포인트 → NAT → 라우트 → 보안 그룹** 순서로 좁힙니다. 두 부류 모두 **CloudTrail로 호출 사실을 확인**합니다.

---

## ✍️ 시험 포인트

- **"훈련 작업을 만들 수 없다 + `iam:PassRole`"** 은 거의 항상 호출자 정책 문제입니다. `Resource`를 역할 ARN으로 좁히고 `iam:PassedToService` 조건을 답니다
- **`AmazonSageMakerFullAccess`를 붙였는데 S3 AccessDenied**가 나면 **버킷 이름**을 봅니다 — 이름에 `sagemaker`·`aws-glue`가 없으면 대상 밖입니다
- **"컨테이너가 외부로 아무것도 못 보내게"** → **네트워크 격리**. VPC 모드는 트래픽 경로를 바꾸는 것이고, 인터넷 차단과 격리는 다릅니다
- **AWS Marketplace 알고리즘·모델로 훈련·실행하면 네트워크 격리가 필수**입니다
- **S3는 게이트웨이, SageMaker API·Runtime은 인터페이스 엔드포인트.** 둘을 바꿔 고르면 틀립니다
- **Runtime 인터페이스 엔드포인트는 클라이언트가 있는 AZ에서 활성화**해야 사설 DNS가 동작합니다
- **분산 훈련 노드 간 통신은 기본적으로 암호화되지 않습니다.** 켜면 보안 그룹에 **UDP 500·ESP 50**이 필요하고 단일 인스턴스에는 영향이 없습니다
- **"막아라"는 조건 키·SCP(예방), "찾아내라"는 Config 규칙(평가).** 질문의 시점을 봅니다
- **`sagemaker:AppNetworkAccessType=PublicInternetOnly`를 Deny**하면 Studio 도메인이 인터넷에 열리는 것을 막습니다
- **CodeBuild의 민감 값을 `PLAINTEXT`로 두면 평문 노출**입니다. `PARAMETER_STORE`·`SECRETS_MANAGER`를 씁니다
- **자동 교체가 필요하면 Secrets Manager**입니다. Parameter Store는 저장된 비밀의 자동 교체를 제공하지 않습니다
- **수동 승인은 7일 무응답이면 실패**이고 **Source 스테이지에는 추가할 수 없습니다**
- **CodePipeline은 대칭 KMS 키만** 지원하고, 마법사가 만드는 기본 키는 **AWS 관리형 키라 변경·삭제가 안 됩니다**
- **`InvokeEndpoint` 감사는 데이터 이벤트 옵트인**이고 요청 파라미터는 남지 않습니다
- **IAM 그룹은 리소스 기반 정책의 `Principal`이 될 수 없습니다**

---

## ⚠️ 흔한 함정 {#pitfalls}

| 함정 | 바로잡기 |
|---|---|
| 사용자에게 SageMaker 권한만 주면 훈련 작업을 만들 수 있다고 본다 | **`iam:PassRole`이 따로 필요**합니다. 자기에게 없는 권한을 가진 역할을 서비스에 건네는 우회를 막는 장치입니다 |
| 역할에 태그를 달고 `ResourceTag`로 PassRole을 통제한다 | ⚠️ 문서가 **결과가 일정하지 않다고 경고**합니다. `Resource`를 역할 ARN으로 좁히는 방식을 씁니다 |
| 다른 계정 서비스에 PassRole로 역할을 건넨다 | **같은 계정의 서비스에만** 씁니다. 대상 계정에 **assume할 수 있는 역할을 먼저** 만듭니다 |
| `AmazonSageMakerFullAccess`가 모든 S3를 커버한다고 본다 | 이름에 `sagemaker`·`aws-glue`가 든 버킷·객체에만 일부 작업을 허용합니다. **도메인 생성 권한도 없습니다** |
| IAM 그룹을 버킷 정책의 `Principal`로 쓴다 | 그룹은 **권한 단위이지 인증 주체가 아니라** 리소스 기반 정책의 주체가 될 수 없습니다 |
| 처리 작업용 ec2 권한에 조건·리소스 필터를 건다 | ⚠️ **생성 시 검증이 실패**합니다. 이 권한은 필터 없이 부여합니다 |
| VPC 모드를 켜면 컨테이너가 외부로 못 나간다고 본다 | VPC 모드는 **트래픽을 내 VPC 경로로 돌리는** 것입니다. 아웃바운드를 전부 막는 것은 **네트워크 격리**입니다 |
| 네트워크 격리를 켜고 컨테이너가 S3를 직접 읽게 한다 | 격리된 컨테이너는 **자격 증명조차 받지 않습니다.** S3 입출력은 SageMaker가 **컨테이너와 별도로** 처리합니다 |
| 네트워크 격리를 Chainer·강화 학습 관리형 컨테이너에 쓴다 | 이 컨테이너들은 **S3 접근이 필요해 미지원**입니다 |
| Studio `VpcOnly`를 퍼블릭 서브넷에 둔다 | ⚠️ **사설 서브넷만** 가능하고, 엔드포인트나 NAT가 없으면 **노트북·훈련·호스팅이 안 됩니다** |
| 노트북 인스턴스의 네트워크 설정을 나중에 바꾼다 | ⚠️ **생성 후 변경할 수 없습니다.** `DirectInternetAccess`·`KmsKeyId` 변경은 리소스 교체입니다 |
| 호스팅 엔드포인트에 서브넷 1개만 둔다 | **인스턴스가 하나여도 서로 다른 AZ에 서브넷 2개 이상**이 필요합니다 |
| 도메인 수준 보안 그룹을 모든 프로필이 공유한다 | ⚠️ 자기 참조 인바운드가 있으면 **도메인의 모든 앱이 서로 접근 가능**해집니다. 프로필마다 고유 보안 그룹을 권장합니다 |
| S3 게이트웨이 엔드포인트로 온프레미스에서 접근한다 | 게이트웨이 엔드포인트는 **온프레미스·리전 간 피어링·Transit Gateway에 쓸 수 없습니다** |
| VPC 엔드포인트 정책만으로 API를 완전히 제한한다 | **VPC 밖에서의 호출은 막히지 않습니다.** 별도 IAM 정책이 필요합니다 |
| presigned URL을 VPC 엔드포인트로만 접근하게 만든다 | URL 트래픽은 **퍼블릭 인터넷을 지납니다.** `aws:SourceIp`와 IAM 권한으로 제한합니다 |
| ML 볼륨은 키를 안 주면 암호화되지 않는다고 본다 | **일시적(transient) 키로 암호화한 뒤 즉시 폐기**합니다. 다만 Nitro 로컬 스토리지에는 KMS 키를 쓸 수 없습니다 |
| 교차 계정 출력에 AWS 관리형 키를 쓴다 | ⚠️ **키 정책을 편집할 수 없어 공유가 불가**합니다. 고객 관리형 키를 요청에 명시합니다 |
| 교차 계정 모델 배포에 모델 그룹 정책만 만든다 | **ECR·S3·KMS까지 모두** 필요합니다. 하나라도 빠지면 `CreateModel`이 실패합니다 |
| Config 규칙으로 리소스 생성을 막는다 | Config는 **평가 통제**입니다. 생성을 막는 것은 **조건 키·SCP의 Deny**입니다 |
| 이벤트 기록에서 엔드포인트 호출 이력을 찾는다 | 데이터 이벤트는 **이벤트 기록에 남지 않습니다.** 추적 + 옵트인이 필요합니다 |
| Parameter Store로 비밀을 자동 교체한다 | **자동 교체는 Secrets Manager**입니다. Parameter Store는 Secrets Manager 비밀을 참조합니다 |
| 민감 값을 Base64로 인코딩해 로그 노출을 피한다 | ⚠️ **변환한 값은 다른 문자열이라 마스킹되지 않습니다** |
| 외부 기여자의 PR을 자동 빌드한다 | 저장소 자격 증명·환경 변수에 접근할 수 있습니다. push 이벤트·브랜치·기여자 필터를 씁니다 |

---

## 🧪 자가 점검

**Q1.** 데이터 과학자에게 `AmazonSageMakerFullAccess`를 붙였는데 `CreateTrainingJob`이 "is not authorized to perform: iam:PassRole"로 실패한다. 무엇을 추가하고 어떻게 좁히는가? (→ 1))

<details><summary>정답 보기</summary>

호출자(데이터 과학자) 정책에 **`iam:PassRole`** 을 추가합니다. 좁히는 방법은 두 가지를 함께 쓰는 것입니다 — ① `Resource`를 **허용할 실행 역할의 ARN**으로 한정하고 ② `Condition`에 **`iam:PassedToService = sagemaker.amazonaws.com`** 을 둡니다. ⚠️ **역할에 태그를 달고 `ResourceTag` 조건으로 통제하는 방식은 문서가 "결과가 일정하지 않다"고 경고**하므로 쓰지 않습니다. 또 PassRole은 **같은 계정의 서비스에만** 쓰며, 다른 계정이면 그 계정에 assume할 수 있는 역할을 먼저 만듭니다. 이 권한이 따로 있는 이유는 **자기에게 없는 권한을 가진 역할을 서비스에 건네 우회하는 것**을 막기 위해서입니다.
</details>

**Q2.** 실행 역할에 `AmazonSageMakerFullAccess`가 붙어 있는데도 훈련 중 S3 `AccessDenied`가 난다. 점검할 원인을 순서대로 대라. (→ 2), 13))

<details><summary>정답 보기</summary>

① ⚠️ **버킷 이름** — FullAccess의 S3 허용은 이름에 `SageMaker`·`Sagemaker`·`sagemaker`·`aws-glue`가 든 버킷·객체에 대한 일부 작업뿐입니다. ② **입력이 KMS 암호화**된 경우 실행 역할에 `kms:Decrypt`(출력이면 `kms:Encrypt`)가 필요하고 **키 정책도 그 역할을 허용**해야 합니다. ③ **ML 볼륨에 KMS 키**를 쓰면 `kms:CreateGrant`. ④ **권한 경계**가 있으면 정책과 **AND로** 적용됩니다. ⑤ **버킷 정책의 Deny**(명시적 거부가 모든 허용을 이김). ⑥ **타 계정 소유 데이터**면 두 계정 모두 키 접근이 필요하고 기본 S3 SSE 키는 다른 계정이 쓸 수 없습니다. 또 **API마다 필요한 S3 권한이 다릅니다** — `CreateModel`은 `s3:GetObject`만, `CreateTrainingJob`은 `s3:GetObject`·`s3:PutObject`·`s3:ListBucket`입니다.
</details>

**Q3.** 규제 요구로 "훈련 컨테이너가 외부로 어떤 데이터도 보낼 수 없어야 한다"가 주어졌다. 어떤 설정이고, 그래도 훈련 데이터는 어떻게 들어오는가? VPC 모드와 함께 쓰면? (→ 7))

<details><summary>정답 보기</summary>

**`EnableNetworkIsolation=True`**(네트워크 격리)입니다 — 컨테이너는 **S3를 포함한 어떤 서비스로도 아웃바운드 호출을 못 하고 AWS 자격 증명조차 받지 않습니다.** 데이터가 들어오는 이유는 **입력 데이터 다운로드와 CloudWatch 로그·메트릭 전송을 노드에서 도는 SageMaker 내부 프로세스가 컨테이너와 별개로** 수행하기 때문입니다 — 컨테이너는 **입력 채널로 제공된 데이터만** 읽습니다. VPC 모드와 함께 쓰면 **업·다운로드는 내 VPC 서브넷을 경유**하지만 **컨테이너 자체는 계속 격리**되며, `VpcConfig`가 있으면 **알고리즘 컨테이너용 ENI를 만들지 않고 S3용 ENI만** 남습니다. ⚠️ 다중 인스턴스 훈련은 **피어 간 통신만** 허용되고, **Marketplace 리소스 사용 시에는 격리가 필수**이며, **Chainer·강화 학습 관리형 컨테이너는 미지원**입니다.
</details>

**Q4.** 인터넷이 없는 사설 서브넷에서 훈련 작업이 S3 데이터를 못 가져온다. 그리고 Studio `VpcOnly` 도메인에서 노트북이 안 뜬다. 각각 무엇이 빠졌는가? (→ 8), 13))

<details><summary>정답 보기</summary>

훈련 쪽은 **S3 게이트웨이 엔드포인트**(`com.amazonaws.<region>.s3`)가 빠진 것입니다 — **라우트 테이블에 연결**하면 S3 라우트가 자동 추가되고 **추가 요금이 없으며**, 표준 S3 URL이 해석되도록 **기본 DNS 설정**을 써야 합니다(대안은 NAT). Studio 쪽은 **인터페이스 엔드포인트**(`sagemaker.api`·`sagemaker.runtime`, 프로젝트는 `servicecatalog`)나 NAT가 없는 것이고, 보안 그룹 쪽에서는 **아웃바운드 허용**과 ⚠️ **NFS TCP 2049를 인·아웃바운드 모두** 허용해야 앱이 뜹니다(보안 그룹 내 TCP는 문서 기준 8192–65535). ⚠️ **Runtime 엔드포인트는 클라이언트가 있는 AZ에서 활성화**해야 사설 DNS가 동작합니다. 확인은 터미널에서 `curl -v`로 하고 **Connection timed out이면 VPC 요건**을 점검합니다.
</details>

**Q5.** "암호화 키 없이 만들어진 노트북 인스턴스가 하나도 없어야 한다"는 요구를 두 방식으로 구현하라. 두 방식의 차이는? (→ 4), 12))

<details><summary>정답 보기</summary>

**① 예방 통제** — IAM 정책(조직 전체면 SCP)에 **Deny + 조건**을 둡니다. `sagemaker:VolumeKmsKeyArn`이 없으면(`Null: "true"`) `CreateNotebookInstance`를 거부합니다. **명시적 거부는 어떤 허용보다 우선**하므로 다른 정책이 허용해도 막힙니다. **② 평가 통제** — AWS Config 관리형 규칙 **`sagemaker-notebook-instance-kms-key-configured`** 로 `KmsKeyId` 미지정 리소스를 **NON_COMPLIANT로 표시**합니다. 차이는 **시점**입니다 — 조건 키·SCP는 **요청을 거부**해 애초에 만들어지지 않게 하고, Config는 **이미 존재하는 리소스의 구성을 평가**합니다. ⚠️ 그래서 "막아라"에 Config를 고르거나 "찾아내라"에 SCP를 고르면 틀립니다. ⚠️ 키 이름은 구 `sagemaker:VolumeKmsKey`가 deprecated이고 `...Arn`이 정본이지만, **문서 안에서도 표기가 섞여 있어 키 이름 자체를 정답 근거로 삼지 않습니다.**
</details>

**Q6.** 분산 훈련에서 노드 간 통신이 기본으로 암호화되는가? 켜려면 무엇을 하고 어떤 대가가 있는가? (→ 6))

<details><summary>정답 보기</summary>

⚠️ **암호화되지 않습니다.** 서비스 플랫폼 내부(intranetwork)에서 기본적으로 암호화되지 않는 구간은 셋입니다 — **서비스 제어 평면↔훈련 인스턴스**(고객 데이터 아님), **분산 처리 작업 노드 간**, **분산 훈련 작업 노드 간**(서비스 간 인터네트워크 전송은 TLS 1.2를 지원합니다). 켜려면 훈련·튜닝 요청에 **`EnableInterContainerTrafficEncryption=True`** 를 주고, API로 할 때는 **보안 그룹에 UDP 500과 ESP 50**(소스를 **자기 보안 그룹 ID**로) 인바운드·아웃바운드 규칙을 **먼저** 추가해야 합니다. 대가는 **다중 인스턴스에서 통신량에 따라 훈련 시간·비용이 늘 수 있다**는 것이고(단일 인스턴스는 영향 없음), 조건 키 문서도 같은 주의를 적습니다. 노드 간에 오가는 것은 **보통 데이터셋이 아니라 가중치 같은 모델 정보**지만 규제 요구가 있으면 켭니다.
</details>

**Q7.** 모델을 다른 계정으로 배포하려는데 `CreateModel`이 "no resource-based policy allows the sagemaker:CreateModel action"으로 실패한다. 무엇을 구성해야 하는가? (→ 5))

<details><summary>정답 보기</summary>

**리소스 정책 네 종류를 모두** 만들어야 합니다 — ① **모델 패키지 그룹 리소스 정책**(모델 그룹에 `sagemaker:DescribeModelPackageGroup`, 모델 버전 리소스에 `DescribeModelPackage`·`ListModelPackages`·`UpdateModelPackage`·`CreateModel`을 상대 계정에 허용) ② **ECR 리포지토리 정책** ③ **S3 버킷 정책** ④ **학습 출력 KMS 키의 그랜트**. ⚠️ **하나라도 빠지면** 이 오류가 납니다. 또 **AWS 관리형 키는 키 정책을 편집할 수 없어 공유가 불가**하므로 **고객 관리형 키**를 써야 합니다. 원리는 교차 계정 접근이 **"리소스 쪽 허용"과 "주체 쪽 허용"이 모두 있어야** 성립한다는 것입니다 — ECR 문서도 다른 계정 주체를 정책에 넣는 것은 **신뢰의 절반**이고 그 주체에 **ID 기반 정책으로도** 권한이 필요하다고 설명합니다. ⚠️ 문서의 예제 코드는 `ecr:*`·`s3:*` 처럼 넓어서 **"예제 그대로가 최소 권한"이라고 보지 않습니다.**
</details>

**Q8.** CodeBuild 프로젝트가 외부 API 토큰을 써야 한다. 어떻게 넣고, 자동 교체가 필요하면 어디에 두는가? 그리고 로그 마스킹을 믿어도 되는가? (→ 11))

<details><summary>정답 보기</summary>

⚠️ **`PLAINTEXT` 환경 변수에 두지 않습니다** — 콘솔·CLI에 평문으로 노출됩니다. 환경 변수 유형을 **`PARAMETER_STORE` 또는 `SECRETS_MANAGER`** 로 지정합니다(CodePipeline도 파이프라인·액션 구성이나 변수 기본값에 토큰을 직접 입력하면 로그에 표시됩니다). **자동 교체(rotation)가 필요하면 Secrets Manager**입니다 — Parameter Store는 **저장된 비밀의 자동 교체 서비스를 제공하지 않고**, 비밀을 Secrets Manager에 두고 파라미터로 **참조**하는 방식을 안내합니다. ⚠️ **로그 마스킹은 저장된 값과 정확히 일치할 때만** 가려지므로 **Base64로 인코딩한 값은 다른 문자열이라 마스킹되지 않습니다.** 함께 권고되는 것은 **빌드 유형별 역할 분리**(테스트 빌드와 릴리스 빌드), 신뢰 정책에 **`aws:SourceAccount`·`aws:SourceArn`** 조건, 그리고 **외부 기여자의 PR을 자동 빌드하지 않기**입니다.
</details>

**Q9.** 감사팀이 네 가지를 요구한다. ① 누가 엔드포인트를 삭제했나 ② 암호화 없이 만들어진 엔드포인트 구성 목록 ③ 훈련 데이터 중 개인정보가 들어 있는 S3 위치 ④ 훈련 클러스터가 통신한 상대. 각각 어떤 서비스인가? (→ 12))

<details><summary>정답 보기</summary>

① **CloudTrail 관리 이벤트** — SageMaker **제어 영역 작업은 전부 관리 이벤트로 기본 기록**되며, 이벤트 기록에서 **지난 90일**을 조회할 수 있습니다(그 이후는 추적 필요). ② **AWS Config 관리형 규칙 `sagemaker-endpoint-config-kms-key-required`** — `KmsKeyId`가 설정되지 않은 EndpointConfig를 NON_COMPLIANT로 표시합니다(Configuration changes 트리거). ③ **Amazon Macie** — ML·패턴 매칭으로 S3 객체의 민감 데이터를 탐지하고 버킷 인벤토리를 만듭니다(SageMaker 데이터 보호 문서도 Macie를 권고). ④ **VPC Flow Logs** — VPC 안에서 만든 훈련 작업의 클러스터 입출력 트래픽을 봅니다. 참고로 **"누가 엔드포인트를 호출했나"** 는 **CloudTrail 데이터 이벤트**이며 ⚠️ **기본 미기록·이벤트 기록에도 없고 요청 파라미터도 남지 않습니다.** Studio에서 실제 사용자를 식별하려면 trusted identity propagation의 **`OnBehalfOf`** 필드를 씁니다.
</details>

---

## 🔭 MLA-C02에서 달라지는 것 {#c02-delta}

> MLA-C02의 대응 Task는 **4.3 ML 및 AI 워크로드와 모델 엔드포인트를 보호합니다**입니다. 아래는 공식 비교 페이지 기준이며 **C01 시험 범위가 아닙니다.**

**추가된 콘텐츠 3개**

- 4.3.1 **코드 및 이미지 취약성을 검사하여** CI/CD 파이프라인을 보호합니다(예: Amazon CodeGuru, Amazon Inspector) — 이 문서 11)의 ECR 스캔·코드 검토가 그 토대입니다. ⚠️ 다만 **CodeGuru Reviewer는 2025-11-07부터 새 저장소 연결을 만들 수 없고**, 대안으로 Amazon Q Developer와 Amazon Inspector Code Security가 안내됩니다
- 4.3.8 **FM에 액세스하기 위한 적절한 자격 증명 유형**을 선택합니다(예: Amazon Bedrock API 키, IAM 자격 증명)
- 4.3.9 애플리케이션 요구 사항 및 **책임 있는 AI 정책을 충족하도록 보호 및 민감한 데이터 보호**를 구현합니다(예: Amazon Bedrock Guardrails 사용)

**삭제된 콘텐츠** — 이 Task에는 없습니다. 즉 C01에서 다룬 실행 역할·조건 키·네트워크 격리·감사는 **C02에서도 그대로 유효**합니다.

⚠️ 비교 페이지는 '추가'된 항목만 번호로 나열하며, 번호가 건너뛰는 항목이 C01의 어느 항목에 대응하는지는 설명하지 않습니다.

---

### 📌 출처

- How to use SageMaker AI execution roles (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/sagemaker-roles.html
- AWS managed policies for Amazon SageMaker AI (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/security-iam-awsmanpol.html
- Amazon SageMaker AI identity-based policy examples (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/security_iam_id-based-policy-examples.html
- Troubleshooting Amazon SageMaker AI Identity and Access (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/security_iam_troubleshoot.html
- Grant a user permissions to pass a role to an AWS service (IAM User Guide) — https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_passrole.html
- Role Manager FAQs (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/role-manager-faqs.html
- Amazon SageMaker Role Manager (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/role-manager.html
- Role Manager availability change (공식 공지) — https://docs.aws.amazon.com/sagemaker/latest/dg/role-manager-availability-change.html
- Persona reference (Amazon SageMaker Role Manager, 공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/role-manager-personas.html
- Actions, resources, and condition keys for Amazon SageMaker (Service Authorization Reference) — https://docs.aws.amazon.com/service-authorization/latest/reference/list_sagemaker.html
- Build a Secure Enterprise Machine Learning Platform on AWS — Governance and control (AWS 백서) — https://docs.aws.amazon.com/whitepapers/latest/build-secure-enterprise-ml-platform/governance-and-control.html
- Build a Secure Enterprise Machine Learning Platform on AWS — Networking architecture (AWS 백서) — https://docs.aws.amazon.com/whitepapers/latest/build-secure-enterprise-ml-platform/networking-architecture.html
- Protect Data at Rest Using Encryption (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/encryption-at-rest.html
- Notebook instances, SageMaker AI jobs, and Endpoints (encryption at rest 공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/encryption-at-rest-nbi.html
- Protecting Data in Transit with Encryption (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/encryption-in-transit.html
- Protect Communications Between ML Compute Instances in a Distributed Training Job (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/train-encrypt.html
- Data Protection in Amazon SageMaker AI (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/data-protection.html
- Run Training and Inference Containers in Internet-Free Mode (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/mkt-algo-model-internet-free.html
- Give SageMaker AI Training Jobs Access to Resources in Your Amazon VPC (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/train-vpc.html
- Give SageMaker AI Hosted Endpoints Access to Resources in Your Amazon VPC (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/host-vpc.html
- Give SageMaker AI Processing Jobs Access to Resources in Your Amazon VPC (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/process-vpc.html
- Connect to SageMaker AI Within your VPC (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/interface-vpc-endpoint.html
- Connect Studio notebooks in a VPC to external resources (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/studio-notebooks-and-internet-access.html
- VpcConfig (Amazon SageMaker API Reference) — https://docs.aws.amazon.com/sagemaker/latest/APIReference/API_VpcConfig.html
- CreateDomain (Amazon SageMaker API Reference) — https://docs.aws.amazon.com/sagemaker/latest/APIReference/API_CreateDomain.html
- AWS::SageMaker::NotebookInstance (CloudFormation Template Reference) — https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/aws-resource-sagemaker-notebookinstance.html
- Control root access to a SageMaker notebook instance (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/nbi-root-access.html
- Logging Amazon SageMaker AI API calls using AWS CloudTrail (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/logging-using-cloudtrail.html
- CloudWatch Logs for Amazon SageMaker AI (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/logging-cloudwatch.html
- AWS Config rule sagemaker-notebook-no-direct-internet-access — https://docs.aws.amazon.com/config/latest/developerguide/sagemaker-notebook-no-direct-internet-access.html
- AWS Config rule sagemaker-notebook-instance-root-access-check — https://docs.aws.amazon.com/config/latest/developerguide/sagemaker-notebook-instance-root-access-check.html
- AWS Config rule sagemaker-notebook-instance-inside-vpc — https://docs.aws.amazon.com/config/latest/developerguide/sagemaker-notebook-instance-inside-vpc.html
- AWS Config rule sagemaker-notebook-instance-kms-key-configured — https://docs.aws.amazon.com/config/latest/developerguide/sagemaker-notebook-instance-kms-key-configured.html
- AWS Config rule sagemaker-endpoint-config-kms-key-required — https://docs.aws.amazon.com/config/latest/developerguide/sagemaker-endpoint-config-kms-key-required.html
- AWS Config rule sagemaker-model-isolation-enabled — https://docs.aws.amazon.com/config/latest/developerguide/sagemaker-model-isolation-enabled.html
- AWS Config rule sagemaker-model-in-vpc — https://docs.aws.amazon.com/config/latest/developerguide/sagemaker-model-in-vpc.html
- AWS Config rule sagemaker-domain-in-vpc — https://docs.aws.amazon.com/config/latest/developerguide/sagemaker-domain-in-vpc.html
- List of AWS Config Managed Rules (공식 문서) — https://docs.aws.amazon.com/config/latest/developerguide/managed-rules-by-aws-config.html
- AWS Config terminology and concepts (공식 문서) — https://docs.aws.amazon.com/config/latest/developerguide/config-concepts.html
- What is Amazon Macie? (공식 문서) — https://docs.aws.amazon.com/macie/latest/user/what-is-macie.html
- CloudTrail Lake availability change (공식 공지) — https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-lake-service-availability-change.html
- IAM Access Analyzer policy generation (IAM User Guide) — https://docs.aws.amazon.com/IAM/latest/UserGuide/access-analyzer-policy-generation.html
- IAM policy testing with the IAM policy simulator (IAM User Guide) — https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_testing-policies.html
- IAM user groups (IAM User Guide) — https://docs.aws.amazon.com/IAM/latest/UserGuide/id_groups.html
- How AWS enforcement code logic evaluates requests to allow or deny access (IAM User Guide) — https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_evaluation-logic_policy-eval-denyallow.html
- Troubleshoot access denied error messages (IAM User Guide) — https://docs.aws.amazon.com/IAM/latest/UserGuide/troubleshoot_access-denied.html
- Troubleshooting AWS KMS permissions (공식 문서) — https://docs.aws.amazon.com/kms/latest/developerguide/policy-evaluation.html
- Identity and access management best practices for AWS KMS (AWS 규범 가이드) — https://docs.aws.amazon.com/prescriptive-guidance/latest/aws-kms-best-practices/access.html
- Compliance validation for Amazon SageMaker AI (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/sagemaker-compliance.html
- HIPAA Eligible Services Reference (공식) — https://aws.amazon.com/compliance/hipaa-eligible-services-reference/
- Amazon SageMaker Model Cards (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/model-cards.html
- Model governance to manage permissions and track model performance (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/governance.html
- Deploy a Model from the Registry with Python (교차 계정 배포, 공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/model-registry-deploy.html
- IAM Access Management (SageMaker Pipelines 공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/build-and-manage-access.html
- Cross-service confused deputy prevention (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/security-confused-deputy-prevention.html
- Security best practices (AWS CodePipeline User Guide) — https://docs.aws.amazon.com/codepipeline/latest/userguide/security-best-practices.html
- Configure server-side encryption for artifacts stored in Amazon S3 for CodePipeline (공식 문서) — https://docs.aws.amazon.com/codepipeline/latest/userguide/S3-artifact-encryption.html
- Create a pipeline in CodePipeline that uses resources from another AWS account (공식 문서) — https://docs.aws.amazon.com/codepipeline/latest/userguide/pipelines-create-cross-account.html
- Add a manual approval action to a stage (CodePipeline 공식 문서) — https://docs.aws.amazon.com/codepipeline/latest/userguide/approvals.html
- Add a manual approval action to a pipeline in CodePipeline (공식 문서) — https://docs.aws.amazon.com/codepipeline/latest/userguide/approvals-action-add.html
- EnvironmentVariable (AWS CodeBuild API Reference) — https://docs.aws.amazon.com/codebuild/latest/APIReference/API_EnvironmentVariable.html
- Data protection in AWS CodeBuild (공식 문서) — https://docs.aws.amazon.com/codebuild/latest/userguide/data-protection.html
- Use AWS CodeBuild with Amazon Virtual Private Cloud (공식 문서) — https://docs.aws.amazon.com/codebuild/latest/userguide/vpc-support.html
- Allow CodeBuild to interact with other AWS services (공식 문서) — https://docs.aws.amazon.com/codebuild/latest/userguide/setting-up-service-role.html
- Scan images for software vulnerabilities in Amazon ECR (공식 문서) — https://docs.aws.amazon.com/AmazonECR/latest/userguide/image-scanning.html
- Preventing image tags from being overwritten in Amazon ECR (공식 문서) — https://docs.aws.amazon.com/AmazonECR/latest/userguide/image-tag-mutability.html
- How Amazon Elastic Container Registry works with IAM (공식 문서) — https://docs.aws.amazon.com/AmazonECR/latest/userguide/security_iam_service-with-iam.html
- Amazon ECR interface VPC endpoints (AWS PrivateLink, 공식 문서) — https://docs.aws.amazon.com/AmazonECR/latest/userguide/vpc-endpoints.html
- How Amazon SageMaker AI uses AWS Secrets Manager (공식 문서) — https://docs.aws.amazon.com/secretsmanager/latest/userguide/integrating-sagemaker.html
- Use AWS Secrets Manager secrets in Parameter Store (공식 문서) — https://docs.aws.amazon.com/secretsmanager/latest/userguide/integrating_parameterstore.html
- Rotate AWS Secrets Manager secrets (공식 문서) — https://docs.aws.amazon.com/secretsmanager/latest/userguide/rotating-secrets.html
- Amazon CodeGuru Reviewer availability change (공식 공지) — https://docs.aws.amazon.com/codeguru/latest/reviewer-ug/codeguru-reviewer-availability-change.html
- Controlling access from VPC endpoints with bucket policies (Amazon S3 공식 문서) — https://docs.aws.amazon.com/AmazonS3/latest/userguide/example-bucket-policies-vpc-endpoint.html
- Gateway endpoints for Amazon S3 (Amazon VPC PrivateLink 공식 문서) — https://docs.aws.amazon.com/vpc/latest/privatelink/vpc-endpoints-s3.html
- Infrastructure security in Amazon VPC (공식 문서) — https://docs.aws.amazon.com/vpc/latest/userguide/infrastructure-security.html
- Building Data Lakes on AWS — Catalog and search (AWS 백서) — https://docs.aws.amazon.com/whitepapers/latest/building-data-lakes/data-cataloging.html
- Invoke endpoints with OpenAI-compatible APIs (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/realtime-endpoints-openai-compatible.html
- What is Amazon SageMaker AI? (개명 안내, 공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/whatis.html
- Clarify availability change (공식 공지) — https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-availability-change.html
- Model Monitor availability change (공식 공지) — https://docs.aws.amazon.com/sagemaker/latest/dg/model-monitor-availability-change.html
- MLA-C01 공식 시험 가이드 (한국어) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-01/machine-learning-engineer-associate-01.html
