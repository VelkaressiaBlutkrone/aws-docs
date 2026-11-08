---
생성: 2026-11-08
목적: SCS-C03 최대 비중 도메인(D4 「ID 및 액세스 관리」 20%)의 공식 근거와 조직 정책 3종의 경계 수집
대상 기술: 4.1.1 · 4.1.2 · 4.1.3 · 4.2.1 · 4.2.2 · 4.2.3 · 4.2.4 · 4.2.5 · 6.1.3
조회일: 2026-11-08 (명시가 없는 모든 인용의 조회일이다)
---

# 94 — ID와 권한 부여 (SCS-C03)

## 1. 왜 이 노트가 필요한가

**D4 「ID 및 액세스 관리」는 20%로 SCS-C03의 최대 도메인**이고, C02에서 **16% → 20%로 올랐다**(00-overview §10). 그런데 Task는 **둘뿐**(`4.1` 인증, `4.2` 권한 부여)이고 기술은 **3 + 5 = 8개**다. 즉 **기술 하나가 다른 도메인보다 더 깊게 출제된다.**

동시에 C02에서 **`작업 4.2`의 「정책의 구성 요소」(보안 주체·작업·리소스·조건)가 삭제됐다**(00-overview §10). ⚠️ **이것이 이 노트의 출발점이다** — 「정책이 무엇으로 이뤄졌나」를 묻지 않는다는 뜻이고, 남은 것은 **「여러 정책이 겹칠 때 결과가 무엇인가」**다. 그래서 §2(평가 논리)와 §3(조직 정책 3종)이 이 노트의 중심이다.

`기술 6.1.3`을 함께 다룬다. 가이드가 "조직 정책을 적용하여 액세스 제어(예: SCP, RCP, AI 서비스 옵트아웃 정책, 선언적 정책)"로 **네 개를 한 줄에** 묶는데, 실측하면 **그 넷은 같은 층이 아니다**(§3-3).

## 2. 정책 평가 — 겹칠 때의 결과

출처: [Policy evaluation logic](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_evaluation-logic.html)

AWS는 요청을 **① 인증 → ② 요청 컨텍스트 처리 → ③ 정책 평가**로 처리하고, "**정책의 순서가 평가 방식에 영향을 준다**"고 적는다. 조합별 결과는 셋이다.

| 조합 | 결과 | 공식 문구 |
| --- | --- | --- |
| ID 기반 + 리소스 기반 (**같은 계정**) | **합집합**(union) | "If an action is allowed by an identity-based policy, a resource-based policy, or both, then AWS allows the action." |
| ID 기반 + **권한 경계** | **교집합**(intersection) | "the resulting permissions are the intersection of the two categories" |
| ID 기반 + **SCP + RCP** (리소스 기반 정책이 없는 리소스에 접근) | **교집합** — **세 유형 모두가 허용해야 한다** | "an action must be allowed by all three policy types" |

⚠️ **모든 조합에서 명시적 거부가 허용을 덮는다**("An explicit deny in either of these policies overrides the allow").
⚠️ **권한 경계를 붙이면 할 수 있는 일이 줄고, 떼면 늘어날 수 있다** — 공식이 그 방향을 직접 적는다. 권한 경계는 **권한을 부여하지 않는다.**
⚠️ **SCP·RCP 교집합 규칙의 전제는 「리소스 기반 정책이 구성되지 않은 리소스」**다. 이 전제를 떼고 "항상 세 유형의 교집합"이라고 쓰면 공식 문구를 넘어선다.
⚠️ SCP·RCP가 특정 요청을 거부하는지 알아내려면 `organizations:DescribeOrganization` 권한이 필요하고, 그 이상은 **조직 관리자에게 문의**하라고 적는다 — 「멤버 계정 개발자가 스스로 원인을 알 수 있나」의 답이다.

## 3. 조직 정책 3종 — SCP · RCP · 선언적 정책

### 3-1. 공식 비교 표 (그대로 옮긴다)

출처: [Declarative policies in AWS Organizations](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_declarative_policies.html)

| | **SCP** | **RCP** | **선언적 정책** |
| --- | --- | --- | --- |
| 왜? | 보안 주체(IAM 사용자·역할)에 일관된 액세스 제어를 중앙에서 정의·강제 | **리소스**에 일관된 액세스 제어를 중앙에서 정의·강제 | AWS **서비스의 기준 구성**을 중앙에서 정의·강제 |
| 어떻게? | **API 수준**에서 보안 주체의 최대 권한을 제어 | **API 수준**에서 리소스의 최대 권한을 제어 | **API 작업을 쓰지 않고** 서비스의 원하는 구성을 강제 |
| **서비스 연결 역할을 통제하나?** | **아니오** | **아니오** | **예** |
| 예시 | 멤버 계정의 조직 탈퇴 거부 | 리소스에 HTTPS 연결만 허용 | Allowed Images Settings |

⚠️⚠️ **이 표의 세 번째 행이 가장 비자명하다.** SCP·RCP는 **서비스 연결 역할을 통제하지 못하는데 선언적 정책은 통제한다.** 「서비스 연결 역할이 하는 일을 SCP로 막는다」는 설계는 성립하지 않는다.
⚠️⚠️ **선언적 정책은 서비스의 「제어 평면」에서 강제된다** — "Declarative policies are enforced in the service's control plane, which is an important distinction from authorization policies such as SCPs and RCPs. While authorization policies regulate access to APIs, declarative policies are applied directly at the service level to enforce durable intent." 그래서 **서비스가 새 기능·새 API를 도입해도 기준 구성이 유지된다**("set once and forget").
⚠️ **분리하면 되돌아간다** — "If a declarative policy is detached, the attribute state will roll back to its previous state before the declarative policy was attached." SCP를 떼는 것과 **의미가 다르다**(SCP를 떼면 권한이 넓어질 뿐 리소스 구성은 그대로다).
⚠️ **계정 상태 보고서**(account status report)로 범위 내 계정의 전 속성 현재 상태를 검토할 수 있고, **사용자 지정 오류 메시지**를 만들어 왜 실패했는지 안내할 수 있다.
⚠️ **유효 정책**(effective policy)은 조직 루트·OU에서 상속된 것과 계정에 직접 연결된 것의 **합성**이고, 새로 가입한 계정은 자동으로 상속한다.

### 3-2. SCP vs RCP — 누구를 겨누나

출처: [Resource control policies (RCPs)](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_rcps.html)

공식이 한 문장으로 가른다: **SCP는 「조직 멤버 계정 안의 IAM 보안 주체」의 권한을 제한할 때**, **RCP는 「조직 계정 밖의 IAM 보안 주체가 조직 멤버 계정의 리소스에 접근하는 요청」을 제한할 때** 쓴다.

- **RCP는 권한을 부여하지 않는다**("No permissions are granted by an RCP") — 가드레일이다. 실제 부여는 ID 기반·리소스 기반 정책이 한다.
- **유효 권한 = (RCP ∩ SCP) ∩ (ID 기반·리소스 기반)**의 논리적 교집합이다.
- **모든 기능이 활성화된 조직**에서만 쓸 수 있다(통합 결제만 켠 조직에서는 불가).
- ⚠️⚠️ **RCP는 관리 계정의 리소스에 영향을 주지 않는다.** 멤버 계정의 리소스에만 적용된다 — 그리고 **위임 관리자로 지정된 계정도 멤버 계정이므로 RCP가 적용된다.** 「보안 도구 계정을 위임 관리자로 뒀으니 RCP가 비켜 간다」는 거짓이다.
- ⚠️ **조직 루트에 바로 붙이지 말라**고 공식이 강하게 권한다 — 테스트 계정 → 하위 OU → 상위로 올리고, **CloudTrail의 Access Denied를 검토**해 영향을 가늠한다.

#### ⚠️⚠️ RCP 지원 서비스는 출시 당시의 다섯 개가 아니다

조회 2026-11-08 기준 공식 목록은 **62개 서비스**다(AppStream · Aurora DSQL · Cloud Directory · CloudFront · CloudSearch · CloudWatch Logs · Network Synthetic Monitor · Cognito · Cognito User Pools · Comprehend · Comprehend Medical · Data Firehose · DynamoDB · DAX · EC2 Auto Scaling · ECR · ECR Public · GameLift Servers · Inspector Scan · Kendra · Kinesis Video Streams · MemoryDB · OpenSearch Serverless · Personalize · Polly · **S3** · SWF · **SQS** · Textract · Timestream for InfluxDB · Transcribe · Translate · WorkSpaces · AppConfig · Auto Scaling · Budgets · Cloud Map · CloudTrail Data Service · CodeArtifact · CodeBuild · CodeCommit · CodePipeline · Compute Optimizer · Cost Optimization Hub · EventBridge · Firewall Manager · FIS · Health · **IAM Roles Anywhere** · **KMS** · OpenSearch Service · Pricing Calculator · Private CA Connector for AD · Resource Groups · **Secrets Manager** · **STS** · Sign-In · Support · Transfer Family · User Notifications · **WAF** · X-Ray).

⚠️ **「RCP는 S3·STS·SQS·KMS·Secrets Manager 다섯 개만 지원한다」는 출시 시점(2024-11) 서술이고 지금은 거짓이다.** 굵게 표시한 것이 그 다섯이고, 나머지 57개가 그 뒤에 붙었다.
⚠️ **수를 묻는 문항은 만들지 않는다** — 늘어나는 목록이다. 축은 **「RCP는 전 서비스에 적용되지 않는다」**(= 목록 밖 서비스의 리소스는 RCP로 보호되지 않는다)와 **「S3·STS·KMS는 처음부터 지원된다」**다.
⚠️ 목록에 **`CodeCommit`이 있다** — 그 서비스 자체는 어느 공식 범위 목록에도 없고 신규 고객에게 닫혀 있다(2026-11-06 CLF 배치 실측). **지원 목록에 있다는 것이 「지금 새로 쓸 수 있다」는 뜻이 아니다.**

### 3-3. ⚠️⚠️ `기술 6.1.3`의 네 항목은 같은 층이 아니다

가이드는 "SCP, RCP, AI 서비스 옵트아웃 정책, 선언적 정책"을 나란히 적는다. 그런데 **선언적 정책 페이지의 하위 주제 목록**이 이렇다(조회 2026-11-08):

> EC2 정책 · 백업 정책 · **태그 정책** · 채팅 애플리케이션 정책 · **AI 서비스 옵트아웃 정책** · Security Hub 정책 · Amazon Bedrock 정책 · Amazon Inspector 정책 · 업그레이드 롤아웃 정책 · Amazon S3 정책 · AWS Shield Network Security Director 정책 · Amazon GuardDuty 정책

즉 **「AI 서비스 옵트아웃 정책」이 선언적 정책 절 아래에 배치돼 있다.** 가이드의 병렬 나열과 문서의 계층이 어긋난다.

⚠️ **분류를 단정하지 않는다.** 이 노트가 고정하는 것은 ① 공식 문서의 **현재 배치**가 위와 같다는 것 ② **SCP·RCP는 권한 부여 정책**이고 **그 밖의 것들은 권한을 부여·거부하지 않는다**는 축이다. 「AI 서비스 옵트아웃 정책은 선언적 정책의 한 종류다」라고 **단정하는 문항은 만들지 않는다** — 공식 분류 서술이 바뀌면 거짓이 된다.
⚠️ 반대로 **「SCP로 AI 서비스의 데이터 사용을 옵트아웃한다」는 거짓**이다. 그것은 전용 정책 유형이다.

## 4. 워크포스 ID — AWS IAM Identity Center

출처: [What is IAM Identity Center?](https://docs.aws.amazon.com/singlesignon/latest/userguide/what-is.html)

⚠️ **인스턴스 유형이 둘이고, 할 수 있는 일이 다르다.**

| | **조직 인스턴스** | **계정 인스턴스** |
| --- | --- | --- |
| 배치 | AWS Organizations **관리 계정** | 활성화한 그 계정에 묶인다 |
| AWS 계정 액세스 관리 | **가능 — 이것만 가능하다** | 불가 |
| 권한 세트 | **조직 인스턴스 전용 기능** | 쓸 수 없다 |
| 공식 권고 | **모범 사례이고 전 프로덕션 용도에 권장** | **선택된 AWS 관리형 애플리케이션의 격리 배포 지원에만** |

⚠️ **「권한 세트로 계정 액세스를 관리한다」는 조직 인스턴스에서만 성립한다.** 계정 인스턴스를 고른 설계에서는 그 선택지가 애초에 없다.
⚠️ **계정 액세스 관리 경로가 둘이다** — 팀이 각 AWS 계정에 IAM 역할을 만들고 **IAM 「계정 액세스 관리자」**(account access manager) 기능으로 역할 할당을 중앙 관리하는 길, 그리고 **권한 세트**로 공통 직무 권한을 만들어 계정 전반에 프로비저닝하는 길이다. 후자는 **선택 기능**이다.
⚠️ **신뢰할 수 있는 ID 전파**(trusted identity propagation) — AWS 관리형 애플리케이션이 사용자의 **ID 자체**를 다른 AWS 관리형 애플리케이션에 안전하게 전달하고, **CloudTrail 이벤트가 사용자와 그 사용자가 시작한 작업 기준으로 기록**된다. 「누가 무엇에 접근했는지」 감사가 쉬워지는 근거가 이것이다.
⚠️ **연동은 한 번이면 된다** — SAML 2.0 IdP를 쓸 때 "you only federate once, and you have only one certificate to manage".
⚠️ **다중 리전 액세스** — 인스턴스를 추가 리전으로 복제하면 활성화된 전 리전에서 할당된 계정·애플리케이션에 접근할 수 있다.
⚠️ **이미 IAM 연동을 쓰고 있다면 바꿀 필요가 없다** — "You don't need to make any changes to your current AWS account workflows to use IAM Identity Center for access to AWS managed applications."
⚠️ **2022-07-26에 AWS Single Sign-On에서 개명**됐고, **레거시 네임스페이스는 그대로다**: `sso`·`identitystore` API 네임스페이스, `aws configure sso`·`sso-admin`·`sso-oidc` CLI, `AWSSSO`·`AWSIdentitySync` 접두사 관리형 정책, `sso`·`identitystore` 서비스 엔드포인트. **문서 슬러그도 `singlesignon/`이다** — 슬러그를 보고 구문서로 오판하면 안 된다(00-overview §5가 범위 서비스 페이지에서 같은 함정을 기록했다).
⚠️ AWS 관리형 애플리케이션의 공식 예시가 **`Kiro`·`Amazon Quick`**이다 — AIF 트랙이 실측한 Q 계열 개명과 같은 이름 층이다.

## 5. 애플리케이션 사용자 ID — Amazon Cognito

출처: [What is Amazon Cognito?](https://docs.aws.amazon.com/cognito/latest/developerguide/what-is-amazon-cognito.html)

공식이 **두 질문**으로 가른다.

| 질문 | 구성요소 | 하는 일 |
| --- | --- | --- |
| **이 사용자는 누구인가**(인증) | **사용자 풀** | OIDC 표준을 따르는 **사용자 디렉터리**. 사용자를 인증하고 앱·API에 **JWT**를 발급한다. 직접 로그인 · 소셜 제공자 · 엔터프라이즈 SAML·OIDC |
| **이 사용자가 어느 AWS 리소스에 닿을 수 있나**(권한 부여) | **ID 풀** | 신뢰할 수 있는 토큰을 **임시·제한 권한 AWS 자격 증명**으로 교환한다. ⚠️ **토큰 없이 게스트 사용자에게도** 제한 권한 자격 증명을 발급할 수 있다 |

⚠️ **둘은 서로를 요구하지 않는다**("Neither component requires the other") — 사용자 풀만으로 내 백엔드에 토큰을 발급할 수 있고, ID 풀만으로 이미 가진 제공자의 토큰을 자격 증명으로 중개할 수 있다.
⚠️ **ID 풀 쪽에 권한 부여 축이 둘** 있다: **역할 기반 액세스 제어**와 **액세스 제어용 속성**(attributes for access control) — 후자가 `기술 4.2.2`의 **ABAC**와 직접 이어진다.
⚠️ **M2M 권한 부여**가 있다 — `client_credentials` 그랜트로 사람 없이 앱·서비스·디바이스에 액세스 토큰을 발급한다.

## 6. AWS 밖 워크로드 — IAM Roles Anywhere

출처: [What is AWS Identity and Access Management Roles Anywhere?](https://docs.aws.amazon.com/rolesanywhere/latest/userguide/introduction.html)

AWS 밖에서 도는 서버·컨테이너·애플리케이션이 **같은 IAM 정책·IAM 역할로** AWS 리소스에 접근하도록 **임시 보안 자격 증명**을 얻게 한다. **장기 AWS 자격 증명을 관리하지 않아도 된다**는 것이 요점이다.

**구성요소 3종:**
- **트러스트 앵커**(trust anchor) — AWS Private CA 또는 **외부 CA 인증서**에 대한 참조. 워크로드는 그 CA가 발급한 **X.509 인증서**로 인증해 임시 자격 증명을 받는다. **한 계정에 여러 개 둘 수 있다.**
- **역할** — IAM Roles Anywhere **서비스 보안 주체를 신뢰**해야 하고, 트러스트 앵커는 역할 신뢰 정책의 **`aws:SourceArn` 조건 키**에 그 앵커 ARN을 값으로 두어 역할과 묶인다.
- **프로필** — 어느 역할을 맡고 임시 자격 증명으로 무엇을 할 수 있는지 정한다. ⚠️ **프로필은 여러 IAM 역할을 가질 수 있지만 세션 정책은 하나뿐이다**("A profile can have many IAM roles, but only one session policy"). `CreateSession`이 돌려주는 세션은 그 세션 정책으로 권한이 제한된다.

⚠️⚠️ **신뢰 경계가 계정 수준이다 — 이것이 이 서비스의 가장 중요한 보안 사실이다.**
> "Certificates issued by **any** trust anchor in the account can be used to assume **any** target role in that same account, **unless you specify conditions in the role's trust policy**."
> "**There is no automatic integration with organization-wide controls.**"

즉 트러스트 앵커를 여럿 두고 역할 신뢰 정책에 조건을 쓰지 않으면 **앵커 간 격리가 없다.** 「팀마다 트러스트 앵커를 따로 뒀으니 서로의 역할은 못 맡는다」는 **거짓**이다. 격리는 **역할 신뢰 정책의 조건**으로 만든다.
⚠️ **모든 IAM Roles Anywhere 리소스는 리전 리소스**이고 **같이 쓰려면 같은 계정·같은 리전에 만들어야 한다.**

## 7. 애플리케이션 권한 부여 — Amazon Verified Permissions

출처: [What is Amazon Verified Permissions?](https://docs.aws.amazon.com/verifiedpermissions/latest/userguide/what-is-avp.html)

**내가 만든 사용자 지정 애플리케이션**을 위한 세분화 권한 관리·권한 부여 서비스다. 권한 부여를 애플리케이션 밖으로 빼내고(externalize) 정책 관리를 중앙화한다. **정책 언어는 Cedar**이고 **현재 Cedar 4.12 버전**을 쓴다.

⚠️⚠️ **인증은 하지 않는다** — "Verified Permissions **presumes that the principal has been previously identified and authenticated** through other means, such as by using protocols like OpenID Connect, a hosted provider like Amazon Cognito, or another authentication solution. Verified Permissions is **agnostic** to where the principal is managed and how they were authenticated." 「Verified Permissions로 사용자를 로그인시킨다」는 거짓이고, 그 자리는 Cognito 사용자 풀이다.
⚠️ **IAM 권한 부여가 아니다** — 평가 대상은 **애플리케이션의 리소스**이고, 클라이언트 애플리케이션이 권한 부여 API를 호출해 결정을 받는다. **PDP**(정책 결정 지점)를 세우는 패턴이다.
⚠️ 정책 저장소를 만들 때 **Cognito 사용자 풀**에서 보안 주체·그룹을, **API Gateway의 API**에서 작업·리소스를 **끌어올 수 있다.**
⚠️ 통합 예시로 **Express.js 미들웨어**가 있다(기존 라우트 핸들러를 바꾸지 않고 API 엔드포인트를 보호).

## 8. 분석·검증 — IAM Access Analyzer

출처: [Using AWS Identity and Access Management Access Analyzer](https://docs.aws.amazon.com/IAM/latest/UserGuide/what-is-access-analyzer.html)

⚠️ **기능이 6종이다.** 「Access Analyzer = 외부 공유 탐지」로만 알면 `기술 4.2.3`·`4.2.4`·`4.2.5`를 못 가른다.

| 기능 | 하는 일 |
| --- | --- |
| **외부 액세스 분석기** | 조직·계정의 리소스가 **외부 엔터티와 공유**되는지 식별 |
| **내부 액세스 분석기** | 선택한 **업무상 중요한 리소스**에 조직·계정 **내부**의 어느 보안 주체가 접근하는지 식별 |
| **미사용 액세스 분석기** | IAM 사용자·역할에 부여된 **미사용 액세스** 식별 |
| **정책 검증** | IAM 정책을 **정책 문법과 AWS 모범 사례**에 대조 |
| **사용자 지정 정책 검사** | IAM 정책을 **내가 지정한 보안 표준**에 대조 |
| **정책 생성** | **CloudTrail 로그의 액세스 활동**을 근거로 IAM 정책 생성 |

⚠️⚠️ **리전 축이 기능마다 다르다 — 가장 자주 틀리는 자리다.**
- **외부 액세스**: "analyzes only policies applied to resources in **the same AWS Region where it's enabled**" → 전 환경을 보려면 **사용 중인 모든 리전에 분석기를 만들어야 한다.**
- **미사용 액세스**: "findings for the analyzer **do not change based on Region**" → **리전마다 만들 필요가 없다.**

⚠️ **신뢰 영역**(zone of trust) — 분석기를 조직 또는 계정 단위로 만들고, 그 단위가 신뢰 영역이다. **신뢰 영역 안 보안 주체의 접근은 신뢰된 것으로 본다.**
⚠️ **지연 시간이 세 갈래다**: 정책을 추가·변경하면 **약 30분 내** 분석 · S3 **다중 리전 액세스 지점** 관련은 **최대 6시간** · CloudTrail 전달 문제나 **RCP 제한 변경**은 정책 변경이 재스캔을 트리거하지 않아 **다음 주기 스캔(24시간 내)**에 반영된다. 즉시 확인하려면 **`Rescan` 링크 또는 `StartResourceScan` API**를 쓴다.
⚠️ **외부 액세스가 분석하는 리소스 유형 15종**: S3 버킷 · **S3 디렉터리 버킷** · IAM 역할 · KMS 키 · Lambda 함수 및 레이어 · SQS 큐 · Secrets Manager 보안 암호 · SNS 주제 · **EBS 볼륨 스냅샷** · **RDS DB 스냅샷** · **RDS DB 클러스터 스냅샷** · ECR 리포지토리 · EFS 파일 시스템 · **DynamoDB 스트림** · **DynamoDB 테이블**. ⚠️ **「S3와 IAM 역할만 본다」가 아니다**(스냅샷 공유가 외부 노출 경로라는 전형적인 시나리오가 여기 든다).
⚠️ **외부 엔터티의 정의**가 넓다: 다른 AWS 계정 · 루트 사용자 · IAM 사용자·역할 · **연동 사용자** · **익명 사용자**.
⚠️ 조사 결과는 **배포 전 미리 보기**에 쓸 수 있다("preview how your policy affects public and cross-account access to your resource **before deploying**").

## 9. 경계 표 — 「무엇으로 무엇을 하나」

| 요구 | 쓰는 것 | 쓰지 않는 것(그리고 왜) |
| --- | --- | --- |
| 워크포스 사용자를 여러 AWS 계정에 로그인시킨다 | IAM Identity Center **조직 인스턴스** + 권한 세트 | 계정 인스턴스 — **계정 액세스를 관리할 수 없다** |
| 앱 최종 사용자를 로그인시킨다 | Cognito **사용자 풀** | Verified Permissions — **인증을 하지 않는다** |
| 앱 사용자에게 S3·DynamoDB 직접 접근을 준다 | Cognito **ID 풀**(토큰 → 임시 자격 증명) | 사용자 풀 단독 — JWT는 AWS 자격 증명이 아니다 |
| 앱 안의 세분화 권한 결정 | **Verified Permissions**(Cedar) | IAM 정책 — 애플리케이션 리소스를 모른다 |
| 온프레미스 서버가 AWS API를 호출한다 | **IAM Roles Anywhere**(X.509) | IAM 사용자 액세스 키 — 장기 자격 증명이다 |
| 조직 밖 보안 주체의 내 리소스 접근을 막는다 | **RCP** | SCP — **조직 안 보안 주체**를 겨눈다 |
| 서비스 연결 역할의 동작까지 통제한다 | **선언적 정책** | SCP·RCP — **통제하지 못한다**(§3-1) |
| 쓰지 않는 권한을 걷어낸다 | Access Analyzer **미사용 액세스 분석기** | 외부 액세스 분석기 — 다른 질문에 답한다 |
| 과거 활동을 근거로 최소 권한 정책을 쓴다 | Access Analyzer **정책 생성**(CloudTrail) | 정책 시뮬레이터 — **평가**는 하지만 생성하지 않는다 |

## 10. 출제 각도 (저작 시 참고)

1. **교집합/합집합을 가르는 문항** — 같은 계정의 ID 기반 + 리소스 기반은 **합집합**인데 권한 경계·SCP·RCP가 끼면 **교집합**이다. "리소스 정책에서 허용했는데 왜 거부되나" 계열.
2. **SCP vs RCP의 방향** — "파트너 계정이 우리 S3 버킷에 쓰는 것을 조직 전체에서 막아라" → RCP. "우리 개발자가 특정 리전을 쓰지 못하게" → SCP.
3. **위임 관리자 함정** — RCP는 관리 계정만 비켜 간다. 위임 관리자 계정은 **적용 대상**이다.
4. **서비스 연결 역할** — SCP로 막으려는 설계를 제시하고 선언적 정책으로 갈라낸다.
5. **Identity Center 인스턴스 유형** — 계정 인스턴스를 켜 둔 상태에서 계정 액세스를 중앙 관리하려는 시나리오.
6. **Roles Anywhere 격리** — 팀별 트러스트 앵커만으로 격리했다고 믿는 설계 → 역할 신뢰 정책 조건이 없으면 교차 역할 수임이 가능하다.
7. **Access Analyzer 리전 축** — "전 리전의 외부 공유를 보려면?" → 리전마다 외부 액세스 분석기. "미사용 권한은?" → 리전 무관.
8. **스냅샷 노출** — EBS·RDS 스냅샷 공유가 외부 액세스 분석 대상 15종에 든다.

## 11. 단정하지 않는 것

1. **RCP 지원 서비스의 「수」를 묻지 않는다**(§3-2) — 늘어난다. 「전 서비스가 아니다」까지만 쓴다.
2. **「AI 서비스 옵트아웃 정책은 선언적 정책의 한 종류다」로 단정하지 않는다**(§3-3) — 공식 배치는 그렇지만 분류 서술이 바뀔 수 있다.
3. **Cedar 버전 숫자를 묻지 않는다** — 올라가는 값이다. ⚠️ AIF 트랙이 **AgentCore의 정책 언어 서술에서 공식 내부 어긋남**(Cedar/Dogwood)을 실측해 뒀으므로(AIF G-27), **다른 서비스의 Cedar 서술을 Verified Permissions 근거로 섞지 않는다.**
4. **「세 유형의 교집합」을 전제 없이 쓰지 않는다**(§2) — 공식 문구의 전제는 「리소스 기반 정책이 없는 리소스」다.
5. **정책 시뮬레이터와 Access Analyzer 정책 검증의 차이를 이 노트 범위에서 단정하지 않는다** — `기술 4.2.4`가 둘을 함께 들지만 이 배치에서 시뮬레이터 전용 페이지를 재지 않았다. 저작 전에 따로 측정한다(**99-gaps에 남긴다**).

## 12. 측정 기록

이 노트가 인용하는 URL은 전부 **`200 r=0`**(2026-11-08, `curl -sL`). 방법·대조군·죽은 슬러그 표는 **93 §8이 정본**이다.

이 노트와 직접 관련된 죽은 슬러그 1건:

| 슬러그 | 신호 | 판정 |
| --- | --- | --- |
| `organizations/latest/userguide/declarative_policies.html` | `200 r=1` → 가이드 인덱스 | **접두사가 빠진 슬러그.** 정본은 `orgs_manage_policies_declarative_policies.html` |

⚠️⚠️ **이 건에서 하마터면 레포의 기존 판정을 뒤집을 뻔했다.** 2026-11-07 SAA P2 배치가 **`orgs_manage_policies_declarative_policies.html`이 정본**이라고 실측해 가드까지 뒤집어 뒀는데, 내가 접두사를 뺀 슬러그로 읽자 Organizations 소개로 리다이렉트됐다. **그것은 레포 판정이 틀렸다는 증거가 아니라 내 슬러그가 틀렸다는 증거**였다. 리다이렉트 노트를 읽지 않고 "정본이 또 바뀌었다"고 적었다면 **옳은 가드를 뒤집었다.**
