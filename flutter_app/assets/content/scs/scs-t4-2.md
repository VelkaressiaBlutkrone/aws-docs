---
examGuideTaskId: scs-t4-2
certCode: SCS-C03
domain: 4
domainName: ID 및 액세스 관리
domainWeightPct: 20
title: 권한 부여 전략 (제어 설계·ABAC와 RBAC·최소 권한·실패 분석·의도하지 않은 권한)
coversTasks:
  - "4.2"
sources:
  - title: Policies and permissions in AWS Identity and Access Management
    url: https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html
  - title: Policy evaluation logic
    url: https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_evaluation-logic.html
  - title: Permissions boundaries for IAM entities
    url: https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_boundaries.html
  - title: IAM identifiers
    url: https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_identifiers.html
  - title: IAM and AWS STS quotas
    url: https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_iam-quotas.html
  - title: Define permissions based on attributes with ABAC authorization
    url: https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction_attribute-based-access-control.html
  - title: IAM policy testing with the IAM policy simulator
    url: https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_testing-policies.html
  - title: Permissions for using the policy simulator
    url: https://docs.aws.amazon.com/IAM/latest/UserGuide/permissions-required_policy-simulator.html
  - title: IAM policy validation
    url: https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_policy-validator.html
  - title: IAM policy validation check reference
    url: https://docs.aws.amazon.com/IAM/latest/UserGuide/access-analyzer-reference-policy-checks.html
  - title: Using AWS Identity and Access Management Access Analyzer
    url: https://docs.aws.amazon.com/IAM/latest/UserGuide/what-is-access-analyzer.html
  - title: The confused deputy problem
    url: https://docs.aws.amazon.com/IAM/latest/UserGuide/confused-deputy.html
  - title: What is AWS Identity and Access Management Roles Anywhere?
    url: https://docs.aws.amazon.com/rolesanywhere/latest/userguide/introduction.html
  - title: What is Amazon Verified Permissions?
    url: https://docs.aws.amazon.com/verifiedpermissions/latest/userguide/what-is-avp.html
  - title: Resource control policies (RCPs)
    url: https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_rcps.html
lastVerified: 2026-11-09
---

# 권한 부여 전략 (제어 설계·ABAC와 RBAC·최소 권한·실패 분석·의도하지 않은 권한)

> **커버하는 공식 Task** — SCS-C03 · 도메인 4 「ID 및 액세스 관리」(20%) · **작업 4.2 권한 부여 전략 설계, 구현 및 문제 해결** (`scs-t4-2`)
> 이 문서는 위 한 작업에 1:1로 매핑되고 공식 기술 5개(4.2.1~4.2.5)를 모두 덮습니다. 작업 4.1(`scs-t4-1`)이 **"누구인지 증명하는 쪽"**이었다면 이 작업은 **"증명된 뒤 무엇을 할 수 있는가"**입니다.

> ⚠️⚠️ **C02에서 이 작업의 「정책의 구성 요소」(보안 주체·작업·리소스·조건)가 삭제됐습니다.** 「정책이 무엇으로 이뤄졌나」를 묻지 않는다는 뜻이고, 남은 것은 **「여러 정책이 겹칠 때 결과가 무엇인가」**입니다. 그래서 이 문서의 중심은 §3(겹침의 결과)과 §4(겹침을 진단하는 도구)입니다.

---

## ✅ 학습 목표 체크리스트

- [ ] 요구에 맞는 **권한 부여 제어**를 골라낸다
- [ ] 크로스 계정에서 **양쪽 정책이 필요한 경우**를 안다
- [ ] IAM 경로와 와일드카드의 **매칭 규칙**을 설명한다
- [ ] Roles Anywhere의 **신뢰 경계가 어디까지인지** 안다
- [ ] ABAC와 RBAC를 **공식 비교 축**으로 가른다
- [ ] 합집합·교집합이 되는 **정책 조합**을 구분한다
- [ ] 권한 경계와 세션 정책의 **비대칭 규칙**을 안다
- [ ] 정책 시뮬레이터와 Access Analyzer를 **질문의 모양**에 따라 고른다

## 🎯 왜 중요한가

권한 부여 문항은 거의 전부 **"허용이 있는데 거부된다"** 또는 **"막았다고 생각했는데 통한다"**입니다. 답은 **어느 조합이 합집합이고 어느 조합이 교집합인가**에 있습니다.

그리고 이 작업에는 **방향을 거꾸로 알기 쉬운 자리**가 여럿 있습니다. 외부 ID는 **내가 만드는 것이 아니고**(§1-3), `user/*` 와일드카드는 **경로가 있는 사용자까지 매칭하며**(§1-4), 트러스트 앵커를 팀마다 나눠도 **격리가 되지 않고**(§1-5), 리소스 기반 정책이 **역할 ARN을 적을 때와 세션 ARN을 적을 때 권한 경계의 적용이 다릅니다**(§3-2). 그 자리들이 이 문서의 뼈대입니다.

## ⚡ 시험 직전 요약

- **같은 계정의 ID 기반 + 리소스 기반은 합집합**이고, **권한 경계·SCP·RCP·세션 정책이 끼면 교집합**입니다. ⚠️ **어느 정책의 명시적 거부든 허용을 덮습니다**
- ⚠️⚠️ **크로스 계정은 양쪽이 필요합니다** — 리소스 기반 정책에 다른 계정 보안 주체를 적는 것은 **신뢰의 절반**이고 그쪽 **ID 기반 정책도 허용**해야 합니다. 같은 계정이면 리소스 기반 정책만으로 충분합니다
- ⚠️⚠️ **외부 ID는 제3자가 만들어 관리합니다** — 공식이 "controlled by Example Corp, **not its customers**"라고 적습니다. 역할 ARN은 **비밀이 아닙니다**
- ⚠️ **IAM 경로는 콘솔에서 만들거나 수정할 수 없습니다**(API·CLI·PowerShell만). 그리고 **`user/*`는 경로가 있는 사용자까지 매칭**합니다
- ⚠️⚠️ **Roles Anywhere의 신뢰 경계는 계정 수준입니다** — 역할 신뢰 정책에 조건을 쓰지 않으면 **계정 안 어느 트러스트 앵커의 인증서로든 어느 대상 역할이든** 맡을 수 있고 **조직 수준 제어와 자동 통합이 없습니다**
- **Verified Permissions는 인증하지 않습니다** — 보안 주체가 이미 식별·인증됐다고 전제하는 **애플리케이션 권한 부여**(Cedar) 서비스입니다
- **ABAC는 태그로 권한을 정의**해 새 리소스에 정책 수정 없이 적용되고, **RBAC는 직무별 정책에 리소스를 열거**해 새 리소스가 생기면 정책을 갱신해야 합니다
- ⚠️ **권한 범위는 관리형 정책으로만 설정**하고 **권한을 부여하지 않습니다.** ⚠️⚠️ 리소스 기반 정책에 **역할 ARN**을 적으면 권한 경계의 **명시적 허용이 필요**하고, **역할 세션 ARN이나 사용자**를 적으면 필요하지 않습니다
- ⚠️⚠️ **정책 시뮬레이터는 RCP를 지원하지 않습니다**(SCP는 평가합니다). 반대로 **Access Analyzer 정책 검증에는 RCP 전용 검사가 있습니다**
- **Access Analyzer는 기능이 6종**이고 ⚠️⚠️ **외부 액세스 분석기는 리전마다 만들어야 하지만 미사용 액세스 분석기는 리전과 무관**합니다

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **권한 범위(권한 경계)** | IAM 사용자·역할에 붙이는 **관리형 정책**. ID 기반 정책이 줄 수 있는 **최대 권한**을 정하고 권한을 부여하지는 않습니다 |
| **세션 정책** | 임시 세션을 만들 때 파라미터로 넘기는 정책. 결과 권한은 **교집합**이고 넓힐 수 없습니다 |
| **역할 신뢰 정책** | IAM이 지원하는 **유일한 리소스 기반 정책**. 누가 그 역할을 맡을 수 있는지 정합니다 |
| **외부 ID** | 역할 신뢰 정책의 `sts:ExternalId` 조건 값. **혼동된 대리인 문제**를 막기 위해 **제3자가 생성·관리**합니다 |
| **IAM 경로** | ARN 안의 `/division_abc/subdivision_xyz/` 같은 조직도 형태 구분자. 콘솔에서 만들 수 없습니다 |
| **트러스트 앵커 / 프로필** | Roles Anywhere의 구성요소. 앞은 CA 참조, 뒤는 맡을 역할과 세션 정책을 정합니다 |
| **신뢰 영역** | Access Analyzer 분석기를 만든 단위(조직 또는 계정). 그 안의 접근은 신뢰된 것으로 봅니다 |
| **ABAC / RBAC** | 전자는 **태그(속성)**로 권한을 정의, 후자는 **직무별 정책**에 리소스를 열거합니다 |

## 📖 핵심 개념

### 1) 권한 부여 제어를 설계하고 평가한다 (기술 4.2.1) {#controls}

#### 1-1. 경계 표 — 무엇으로 무엇을 하나

| 요구 | 쓰는 것 | 쓰지 않는 것(그리고 왜) |
|---|---|---|
| 앱 안의 세분화 권한 결정 | **Verified Permissions**(Cedar) | IAM 정책 — **애플리케이션의 리소스를 모릅니다** |
| 온프레미스 서버가 AWS API를 호출 | **IAM Roles Anywhere**(X.509) | IAM 사용자 액세스 키 — 장기 자격 증명입니다 |
| 다른 계정이 내 버킷에 쓰게 함 | **리소스 기반 정책 + 상대 계정의 ID 기반 정책** | 리소스 기반 정책 단독 — **크로스 계정은 양쪽이 필요합니다** |
| 제3자 업체가 내 계정을 대행 | **역할 + 신뢰 정책의 외부 ID 조건** | 액세스 키 전달 — 혼동된 대리인 문제가 남습니다 |
| 조직 밖 보안 주체의 접근을 중앙에서 막음 | **RCP** | SCP — **조직 안 보안 주체**를 겨눕니다 |
| 위임 관리자에게 역할 생성 권한을 주되 상한을 둠 | **권한 범위** | SCP — 계정 전체에 걸립니다 |

⚠️ **RCP에 대해 자주 틀리는 둘** — **RCP는 권한을 부여하지 않습니다**(가드레일이고 실제 부여는 ID 기반·리소스 기반 정책이 합니다). 그리고 ⚠️⚠️ **RCP는 관리 계정의 리소스에 영향을 주지 않지만 위임 관리자 계정은 멤버 계정이므로 적용됩니다.** "보안 도구 계정을 위임 관리자로 뒀으니 RCP가 비켜 간다"는 거짓입니다. RCP는 **모든 기능이 활성화된 조직**에서만 쓸 수 있고, 공식은 **조직 루트에 바로 붙이지 말고** 테스트 계정 → 하위 OU → 상위로 올리며 **CloudTrail의 접근 거부를 검토**하라고 권합니다.

#### 1-2. 정책 유형 — 먼저 알아 둘 비대칭 셋

| 사실 | 왜 중요한가 |
|---|---|
| ⚠️ **리소스 기반 정책은 전부 인라인입니다** — 공식이 "There are no managed resource-based policies"라고 적습니다 | "버킷 정책을 관리형 정책으로 만들어 재사용한다"가 성립하지 않습니다 |
| ⚠️ **IAM이 지원하는 리소스 기반 정책은 역할 신뢰 정책 하나뿐**이고, 역할은 **ID이면서 리소스**라 **신뢰 정책과 ID 기반 정책을 둘 다** 붙입니다 | "역할에 권한 정책만 붙였는데 못 맡는다"의 원인입니다 |
| ⚠️ **VPC 엔드포인트 정책은 추가 경계이고 다른 정책을 덮어쓰지 않습니다.** 커스텀 정책을 붙이지 않으면 **전체 허용 기본 정책**이 붙습니다 | "엔드포인트를 만들었으니 접근이 좁아졌다"가 거짓입니다 |

**ACL과 RAM도 한 줄씩 기억합니다.** ACL은 **JSON 형식을 쓰지 않는 유일한 정책 유형**이고 **같은 계정 안 보안 주체에는 쓸 수 없습니다**. AWS RAM 리소스 공유는 리소스마다 정책을 쓰지 않고 **계정 ID 열거 없이** 중앙에서 공유하는 대안입니다(VPC 서브넷·Transit Gateway 어태치먼트·Route 53 Resolver 규칙 등).

#### 1-3. 크로스 계정 — 양쪽이 필요하고 외부 ID는 상대가 만든다

**혼동된 대리인 문제**는 **권한이 없는 엔터티가 더 특권 있는 엔터티를 꾀어 작업을 수행시키는** 보안 문제입니다. 공식이 두 종류로 가릅니다.

**교차 계정(제3자 위임)** — 업체에 역할 ARN을 주면 업체가 그것으로 임시 자격 증명을 얻습니다. 그런데 ⚠️ **역할 ARN은 비밀이 아닙니다.** 다른 고객이 같은 ARN을 업체에 알려주면 업체가 **내 계정의 리소스에 접근**하게 됩니다 — 업체가 "혼동된 대리인"이 된 것입니다.

해결은 **역할 신뢰 정책의 `sts:ExternalId` 조건**입니다.

```
{
  "Version":"2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Principal": { "AWS": "업체의 AWS 계정 ID" },
    "Action": "sts:AssumeRole",
    "Condition": { "StringEquals": { "sts:ExternalId": "12345" } }
  }
}
```

⚠️⚠️ **외부 ID는 내가 정하지 않습니다.** 공식 문구가 분명합니다 — 값은 **업체의 고객 사이에서 유일해야 하고 업체가 통제**하며, "**this is why you get it from Example Corp and you don't come up with it on your own**"입니다. 업체가 역할을 맡을 때 **그 고객의 외부 ID를 항상 포함**하므로, 다른 고객이 내 ARN을 알려줘도 그 호출에는 **다른 외부 ID가 실려** 실패합니다.

**교차 서비스** — CloudTrail이 다른 계정의 S3 버킷에 쓰는 경우처럼 **AWS 서비스 보안 주체**가 접근할 때입니다. ⚠️⚠️ **리소스 정책은 그 서비스 보안 주체만 인증하고, 그 서비스를 구성한 행위자는 인증하지 않습니다.** 조건 없이 `cloudtrail.amazonaws.com`을 신뢰하면 **버킷 이름을 아는 누군가의 로그까지** 받게 됩니다.

해결은 **출처 조건 키 넷**입니다 — **`aws:SourceArn`**(특정 리소스 대행) · **`aws:SourceAccount`**(특정 계정 대행) · **`aws:SourceOrgID`**(특정 조직 대행) · **`aws:SourceOrgPaths`**(조직 경로 대행). ⚠️ 이 조건 키들은 **리소스 기반 정책뿐 아니라 RCP에도** 쓸 수 있습니다.

#### 1-4. IAM 경로 — 콘솔에서 만들 수 없고 와일드카드가 경로를 가로지른다

공식 기술 4.2.1이 예시로 드는 **「IAM 경로」**는 ARN 안의 조직도 형태 구분자입니다.

```
arn:aws:iam::123456789012:user/John
arn:aws:iam::123456789012:user/division_abc/subdivision_xyz/Jane
arn:aws:iam::123456789012:role/aws-service-role/access-analyzer.amazonaws.com/AWSServiceRoleForAccessAnalyzer
arn:aws:iam::123456789012:role/service-role/QuickSightAction
```

- ⚠️⚠️ **경로는 콘솔에서 만들거나 조작할 수 없습니다** — 공식이 "Paths cannot be created or manipulated in the AWS Management Console. To use paths, you must work with the resource by using the AWS API, the AWS CLI, or the Tools for Windows PowerShell"이라 적습니다
- **경로 이름은 슬래시로 시작하고 끝나야** 합니다
- **서비스 연결 역할은 `role/aws-service-role/`**, **서비스 역할은 `role/service-role/`** 경로를 씁니다 — ARN만 보고 가를 수 있습니다
- ⚠️ **사용자의 경로는 그 사용자가 속한 그룹과 무관**합니다

**와일드카드 규칙이 시험에 그대로 나옵니다.**

| 패턴 | 매칭되는 것 |
|---|---|
| `user/*` | ⚠️⚠️ **`user/John`과 `user/division_abc/subdivision_xyz/JaneDoe` 둘 다** — 경로를 가로지릅니다 |
| `user/division_abc*` | **경로가 있는 쪽만** (`user/John`은 아님) |
| `user/division_abc/subdivision_xyz/product_1234/*` | 그 경로 아래 전부 |
| `iam::123456789012:u*` | ❌ **허용되지 않습니다** — `user/`·`group/`·`policy/` 부분에는 와일드카드를 쓰지 않습니다 |

⚠️⚠️ **불완전 ARN은 자동으로 와일드카드가 채워집니다** — `arn:aws:sqs`는 `arn:aws:sqs:*:*:*`와 같아서 **전 리전·전 계정의 SQS 리소스**를 허용합니다. **그런데 `AssumeRole`·`AssumeRoleWithWebIdentity`·`AssumeRoleWithSAML`에 넘기는 세션 정책은 불완전 ARN을 지원하지 않고** `MalformedPolicyDocumentException`을 돌려줍니다. 같은 문자열이 ID 기반 정책에서는 **조용히 넓어지고** 세션 정책에서는 **실패**합니다.

⚠️ 친숙한 이름 대신 **고유 ID**를 쓰는 경우도 알아 둡니다. 계정 안에서 이름은 유일하지만 **삭제 후 재사용**할 수 있어서, `John`이 퇴사하고 다른 `John`이 입사하면 이름 기반 정책이 **이전 John의 데이터에 접근을 주게** 됩니다. 고유 ID는 재사용되지 않으므로 리소스 기반 정책에서 **고유 ID로 부여**하면 그 위험이 줄어듭니다.

#### 1-5. IAM Roles Anywhere — 신뢰 경계가 계정 수준이다

AWS 밖에서 도는 서버·컨테이너·애플리케이션이 **같은 IAM 정책·IAM 역할로** AWS 리소스에 접근하게 하고, **장기 AWS 자격 증명을 두지 않아도** 됩니다.

**구성요소 셋:**

| 구성요소 | 하는 일 |
|---|---|
| **트러스트 앵커** | AWS Private CA 또는 **외부 CA 인증서**에 대한 참조. 워크로드는 그 CA가 발급한 **X.509 인증서**로 인증합니다. **한 계정에 여러 개** 둘 수 있습니다 |
| **역할** | Roles Anywhere **서비스 보안 주체를 신뢰**해야 하고, 신뢰 정책의 **`aws:SourceArn` 조건 키**에 앵커 ARN을 넣어 앵커와 묶입니다 |
| **프로필** | 어느 역할을 맡고 무엇을 할 수 있는지 정합니다. ⚠️ **프로필은 여러 IAM 역할을 가질 수 있지만 세션 정책은 하나뿐**입니다 |

⚠️⚠️ **이 서비스의 가장 중요한 보안 사실은 신뢰 경계가 계정 수준이라는 것입니다.**

> "Certificates issued by **any** trust anchor in the account can be used to assume **any** target role in that same account, **unless you specify conditions in the role's trust policy**."
> "**There is no automatic integration with organization-wide controls.**"

즉 **"팀마다 트러스트 앵커를 따로 뒀으니 서로의 역할은 못 맡는다"는 거짓입니다.** 격리는 **역할 신뢰 정책의 조건**으로 만듭니다.

⚠️ 모든 Roles Anywhere 리소스는 **리전 리소스**이고 **같이 쓰려면 같은 계정·같은 리전**에 있어야 합니다.

#### 1-6. Verified Permissions — 인증하지 않는다

**내가 만든 사용자 지정 애플리케이션**의 세분화 권한 관리 서비스이고, 권한 부여를 애플리케이션 밖으로 빼내(externalize) 정책 관리를 중앙화합니다. **정책 언어는 Cedar**입니다.

- ⚠️⚠️ **인증은 하지 않습니다** — 공식이 "**presumes that the principal has been previously identified and authenticated** through other means"라고 적고, 보안 주체가 **어디서 관리되고 어떻게 인증됐는지에 무관(agnostic)**하다고 밝힙니다. "Verified Permissions로 사용자를 로그인시킨다"는 거짓이고 그 자리는 **Cognito 사용자 풀**입니다
- ⚠️ **IAM 권한 부여가 아닙니다** — 평가 대상은 **애플리케이션의 리소스**이고, 클라이언트가 권한 부여 API를 호출해 결정을 받습니다(**정책 결정 지점**을 세우는 패턴)
- 정책 저장소를 만들 때 **Cognito 사용자 풀**에서 보안 주체·그룹을, **API Gateway의 API**에서 작업·리소스를 **끌어올 수 있습니다**

### 2) ABAC와 RBAC 전략 (기술 4.2.2) {#abac}

**ABAC는 속성 기반 권한 부여이고 AWS에서 그 속성은 태그입니다.** 공식이 RBAC와의 차이를 다섯 축으로 적습니다.

| 축 | ABAC | RBAC |
|---|---|---|
| 권한의 근거 | **태그 값의 일치**(보안 주체 태그 ↔ 리소스 태그) | **직무별 정책**이 열거한 리소스 |
| 새 리소스가 생기면 | **정책을 고치지 않습니다** — 태그만 맞으면 접근됩니다 | **정책을 갱신**해야 접근됩니다 |
| 정책 개수 | **적습니다**(하나 또는 소수) | 직무마다 하나씩 |
| 조직 변화 대응 | 태그·역할 할당만 바꿉니다 | 역할을 바꾸고 정책을 점검합니다 |
| 세분화 | **"리소스 태그가 내 태그와 같으면 전 리소스에 허용"** | "이 리소스들에만 허용" |

공식 예시가 이해를 고정합니다 — `access-project` 태그 키에 값 `Heart`·`Star`·`Lightning`을 둔 역할 셋을 만들고, **정책 하나**로 "역할과 리소스의 `access-project` 값이 같으면 허용"을 씁니다. 새 프로젝트 `Lightning`을 추가할 때 **정책을 바꾸지 않습니다.**

- ⚠️⚠️ **RBAC의 「역할」은 IAM 역할이 아닙니다** — 공식이 "a person's job function, or role, **which is distinct from an IAM role**"이라고 못박습니다. IAM에는 RBAC 모델을 돕는 **직무별 AWS 관리형 정책**이 따로 있습니다
- ⚠️ **기업 디렉터리 속성을 그대로 쓸 수 있습니다** — **SAML 또는 OIDC 공급자가 세션 태그를 전달**하도록 구성하면, 직원이 연동해 들어올 때 IAM이 그 속성을 결과 보안 주체에 적용합니다. 그러면 **IdP에서 속성을 바꾸는 것만으로** AWS 권한이 따라 바뀝니다
- 태그 기반 접근 제어의 조건 키는 **`aws:ResourceTag/키`**, **`aws:RequestTag/키`**, **`aws:TagKeys`**이고, 보안 주체 쪽 값은 **`aws:PrincipalTag/키`**로 참조합니다
- ⚠️ **AWS는 둘을 공존시킵니다** — "ABAC로 전부 바꿔라"가 아니라 기존 RBAC 옆에 ABAC를 더하는 길이 공식 권고입니다

### 3) 최소 권한으로 설계한다 — 겹칠 때의 결과 (기술 4.2.3) {#least-privilege}

#### 3-1. 합집합과 교집합

공식 정책 평가 논리 페이지가 **"정책의 순서가 평가 방식에 영향을 준다"**고 적고, 조합별 결과를 셋으로 가릅니다.

| 조합 | 결과 | 공식 문구 |
|---|---|---|
| ID 기반 + 리소스 기반 (**같은 계정**) | **합집합** | "If an action is allowed by an identity-based policy, a resource-based policy, or both, then AWS allows the action." |
| ID 기반 + **권한 경계** | **교집합** | "the resulting permissions are the intersection of the two categories" |
| ID 기반 + **SCP + RCP** (리소스 기반 정책이 없는 리소스) | **교집합 — 세 유형 모두가 허용해야** | "an action must be allowed by all three policy types" |

⚠️ **모든 조합에서 명시적 거부가 허용을 덮습니다.**
⚠️ **SCP·RCP 교집합 규칙의 전제는 「리소스 기반 정책이 구성되지 않은 리소스」**입니다. 이 전제를 떼고 "항상 세 유형의 교집합"이라고 외우면 공식 문구를 넘어섭니다.
⚠️ **멤버 계정의 개발자는 스스로 원인을 알기 어렵습니다** — SCP·RCP가 그 요청을 거부하는지 확인하려면 `organizations:DescribeOrganization` 권한이 필요하고, 그 이상은 공식이 **조직 관리자에게 문의**하라고 적습니다.

#### 3-2. 권한 범위 — 관리형 정책만, 그리고 리소스 기반 정책과의 비대칭

**권한 범위(권한 경계)는 ID 기반 정책이 IAM 엔터티에 줄 수 있는 최대 권한**을 정합니다.

- ⚠️ **AWS 관리형 정책 또는 고객 관리형 정책으로만** 설정합니다 — 인라인 정책으로는 못 만듭니다
- **권한을 부여하지 않습니다.** 공식 예시가 분명합니다 — 경계가 `s3`·`cloudwatch`·`ec2`만 허용하고 ID 기반 정책이 `iam:CreateUser`만 허용하면, 그 사용자는 **AWS에서 아무 작업도 못 합니다**(교집합이 비어 있습니다)
- 대표 용례는 **권한 관리 위임**입니다 — 중앙 관리자가 "권한 경계를 붙인 역할만 만들 수 있다"는 조건을 개발자의 ID 정책에 걸어, 개발자가 역할을 만들되 **민감 리소스에는 못 닿게** 합니다

⚠️⚠️ **리소스 기반 정책과의 관계가 비대칭입니다 — 이 절에서 가장 비자명한 자리입니다.**

| 리소스 기반 정책의 `Principal`에 적은 것 | 권한 경계의 **명시적 허용**이 필요한가 |
|---|---|
| **IAM 사용자** (또는 역할 **세션** ARN) | **필요하지 않습니다** — 세션에 직접 부여되는 권한입니다 |
| **IAM 역할 ARN** | **필요합니다** — 경계의 암시적 거부에 걸립니다 |

⚠️ **두 경우 모두 권한 경계의 명시적 거부는 유효합니다.** 그리고 **STS 연동 사용자 세션**도 같은 모양입니다 — 리소스 기반 정책이 **연동 사용자 ARN**을 적으면 세션에 직접 부여되어 제한받지 않지만, **연동한 IAM 사용자의 ARN**을 적으면 권한 경계·세션 정책의 암시적 거부에 걸립니다.

> ⚠️⚠️ 공식 문서 안에서 **거친 요약과 정밀한 서술이 갈리는 자리**입니다. 접근 거부 문제 해결 페이지는 "Resource-based policies are **not** limited by permissions boundaries"라고 한 줄로 적지만, 정책 유형 페이지와 권한 경계 페이지는 위 표처럼 **`Principal`에 무엇을 적었는지에 따라 다르다**고 적습니다. **더 구체적인 쪽을 정본으로** 삼습니다.

마지막으로 ⚠️ **`NotPrincipal` 함정**이 있습니다. 리소스 기반 정책에 **`NotPrincipal` + `Deny`**를 쓰면 **권한 경계가 붙은 모든 IAM 보안 주체가, `NotPrincipal`에 적힌 값과 무관하게 거부됩니다.** 공식 권고는 `NotPrincipal` 대신 **`ArnNotEquals` 연산자와 `aws:PrincipalArn` 조건 키**를 쓰는 것입니다.

#### 3-3. 세션 정책 — 넓힐 수 없고, 세션 ARN이면 제한도 못 한다

**세션 정책은 임시 세션을 만들 때 파라미터로 넘기는 정책**입니다.

- **`AssumeRole`·`AssumeRoleWithSAML`·`AssumeRoleWithWebIdentity`**로 전달하고, **인라인 JSON 1개(`Policy`)** 또는 **관리형 정책 ARN 최대 10개(`PolicyArns`)**를 씁니다. **`GetFederationToken`은 세션 정책을 반드시 전달**해야 합니다
- **결과 권한은 교집합**이고 ⚠️ **역할의 ID 기반 정책이 허용하지 않는 권한을 세션 정책으로 줄 수는 없습니다**
- ID 기반 정책 + 세션 정책 + **권한 경계**가 함께 걸리면 **셋의 교집합**입니다

⚠️⚠️ **리소스 기반 정책이 끼면 「언제 더해지는가」가 결과를 바꿉니다.**

| 리소스 기반 정책이 `Principal`에 적은 것 | 언제 더해지나 | 세션 정책의 제한을 받나 |
|---|---|---|
| **사용자 또는 역할의 ARN** | **세션 생성 전** | **받습니다** — 세션 정책이 총합을 제한합니다 |
| **세션 ARN** | **세션 생성 후** | ⚠️ **받지 않습니다** — 그 권한은 세션 정책으로 좁혀지지 않습니다 |

즉 **"세션 정책으로 모든 권한을 확실히 좁혔다"가 거짓이 되는 경우**가 있습니다. 리소스 소유자가 **세션 ARN을 직접 보안 주체로 적어 둔 경우**입니다.

### 4) 인증 실패를 분석해 원인 또는 영향을 확인한다 (기술 4.2.4) {#analyze}

공식 기술 4.2.4가 **「IAM 정책 시뮬레이터」와 「IAM Access Analyzer」**를 함께 듭니다. **둘은 다른 질문에 답합니다.**

#### 4-1. 정책 시뮬레이터 — 요청 단위로 결과를 예측한다

시뮬레이터는 **ID 기반 정책 · 권한 경계 · SCP · 내가 제공한 리소스 기반 정책**을 평가해, **실제 요청을 보내지 않고** 각 작업·리소스 조합에 **허용/거부 이진 결과**를 돌려줍니다. 허용이나 명시적 거부일 때는 **어느 정책이 그 결과를 만들었는지**도 보여 줍니다.

**모드가 둘입니다.**

| 모드 | 무엇을 테스트하나 |
|---|---|
| **보안 주체(Principal) 모드** | 이미 있는 IAM 사용자·역할·그룹에 **붙어 있는 정책**. 사용자 지정 정책이나 권한 경계를 **붙이지 않은 채 포함·제외**해 볼 수 있습니다 |
| **사용자 지정(Custom) 모드** | 내가 **쓰거나 붙여 넣은 정책**. 어디에도 연결하기 전에 확인합니다. **계정에 저장되지 않습니다** |

**한계를 공식이 직접 적습니다.**

- ⚠️⚠️ **RCP를 지원하지 않습니다**("does not support resource control policies (RCPs)") — SCP는 조건 키와 거부 문장의 리소스 범위까지 평가하지만 RCP는 대상이 아닙니다
- ⚠️ **권한 경계는 한 번에 하나**만 시뮬레이션할 수 있습니다
- ⚠️ **SCP가 허용인지 거부인지는 알려주지만, 보안상 이유로 매칭된 SCP 문장은 보여 주지 않습니다**
- ⚠️ **콘솔 외에서는 리소스의 정책을 대신 가져오지 않습니다** — 리소스 기반 정책을 포함하려면 **내가 함께 제공**해야 합니다
- ⚠️ **실제 환경과 다를 수 있는 구성이 있습니다** — **VPC 엔드포인트 정책 · 역할 체이닝 · 한 리소스에 여러 리소스 기반 정책**. 공식이 "시뮬레이터로 테스트한 뒤 실제 환경에서 확인하라"고 권합니다
- ⚠️ **조건 키 값의 출처가 둘**입니다 — 시뮬레이터가 자동으로 채우는 것(**보안 주체 컨텍스트** `aws:PrincipalAccount`·`aws:PrincipalId`·`aws:PrincipalType`·`aws:UserId`·`aws:UserName`, **조직 컨텍스트** `aws:PrincipalOrgID`·`aws:PrincipalOrgMasterAccountId`·`aws:PrincipalOrgPaths`)과 **내가 입력하는 나머지 전부**입니다. 값이 조건을 만족하지 않으면 거부됩니다
- ⚠️ **콘솔과 CLI·API가 다릅니다** — 콘솔에서는 **ID 기반 정책·권한 경계·리소스 기반 정책에 나타난 조건 키**에만 값을 넣을 수 있어, **SCP에만 있는 조건 키에는 값을 줄 수 없습니다**(CLI·API에서는 가능합니다)
- ⚠️ **글로벌 조건 키의 서비스 지원 여부를 판정하지 않습니다**(예: 어떤 서비스가 `aws:TagKeys`를 지원하지 않는다는 것을 알려주지 않습니다). 반면 **SCP는 서비스를 아는 논리로 평가**됩니다

**권한도 모드별로 갈립니다** — 넘겨 준 정책 문자열을 테스트하려면 **`iam:SimulateCustomPolicy`**, 엔터티에 붙은 정책을 테스트하려면 **`iam:SimulatePrincipalPolicy`**입니다. ⚠️ 후자는 **다른 IAM 엔터티의 권한을 드러내므로** 공식이 호출자를 제한하라고 권합니다.

#### 4-2. Access Analyzer 정책 검증 — 문서 단위로 품질을 본다

**정책 검증**은 요청을 평가하지 않습니다. **IAM 정책 문법과 AWS 모범 사례에 대조**해 조사 결과를 돌려줍니다.

- **조사 결과 유형 넷** — **오류(ERROR) · 보안 경고(SECURITY WARNING) · 일반 경고(GENERAL WARNING) · 제안(SUGGESTION)**
- ⚠️ **추가 요금이 없습니다** — 공식이 "There is no additional charge associated with running the policy validation checks"라고 적습니다
- **콘솔에서 JSON 정책을 만들거나 수정하면 자동으로 돌고**, `access-analyzer:ValidatePolicy` 권한이 있으면 조사 결과가 보입니다. CLI·API로도 돌릴 수 있습니다
- ⚠️ AWS 자체의 **JSON 문법·문법 검증은 별도로** 항상 돕니다 — ARN 형식, 작업 이름, 조건 키가 올바른지 봅니다

⚠️⚠️ **검사 목록이 시뮬레이터가 못 보는 영역을 덮습니다.** 공식 검사 참조에 **RCP 전용 검사**(`Policy size exceeds RCP quota`, `RCP syntax error principal`·`allow`·`NotAction`·`action`, `RCP missing related principal condition key` 등), **역할 신뢰 정책 전용 검사**(`Role trust policy syntax error notprincipal` 등), **Roles Anywhere 신뢰 정책 검사**(`Missing action for roles anywhere trust policy`)가 들어 있습니다. 즉 **RCP를 다루는 쪽은 정책 검증입니다.**

#### 4-3. 둘을 가르는 질문

| 질문의 모양 | 쓰는 것 |
|---|---|
| **"이 보안 주체가 이 리소스에 이 작업을 할 수 있나"** | **정책 시뮬레이터** — 요청 단위 허용/거부와 책임 정책 |
| **"붙이기 전에 이 정책 문서가 문법·모범 사례에 맞나"** | **정책 검증** — 오류·보안 경고·일반 경고·제안 |
| **"우리 표준을 어기는 정책을 CI에서 막아라"** | **사용자 지정 정책 검사** — 내가 지정한 보안 표준에 대조 |
| **"RCP가 이 요청을 막는가"** | 시뮬레이터로는 안 됩니다 — RCP를 지원하지 않으므로 **정책 검증**과 **CloudTrail의 접근 거부**로 접근합니다 |
| **"과거 활동을 근거로 최소 권한 정책을 써라"** | **정책 생성**(CloudTrail 로그 기반) — 시뮬레이터는 평가만 하고 생성하지 않습니다 |

### 5) 의도하지 않은 권한을 조사하고 수정한다 (기술 4.2.5) {#unintended}

#### 5-1. Access Analyzer는 기능이 6종이다

「Access Analyzer = 외부 공유 탐지」로만 알면 이 기술을 못 가릅니다.

| 기능 | 하는 일 |
|---|---|
| **외부 액세스 분석기** | 조직·계정의 리소스가 **외부 엔터티와 공유**되는지 식별 |
| **내부 액세스 분석기** | 선택한 **업무상 중요한 리소스**에 조직·계정 **내부**의 어느 보안 주체가 접근하는지 식별 |
| **미사용 액세스 분석기** | IAM 사용자·역할의 **미사용 액세스** 식별 |
| **정책 검증** | 정책을 **문법과 AWS 모범 사례**에 대조(§4-2) |
| **사용자 지정 정책 검사** | 정책을 **내가 지정한 보안 표준**에 대조 |
| **정책 생성** | **CloudTrail 로그의 액세스 활동**을 근거로 정책 생성 |

**신뢰 영역**은 분석기를 만든 단위(조직 또는 계정)이고, **그 안의 보안 주체 접근은 신뢰된 것으로** 봅니다.

#### 5-2. 리전 축이 기능마다 다르다

⚠️⚠️ **가장 자주 틀리는 자리입니다.**

- **외부 액세스 분석기** — "analyzes only policies applied to resources in **the same AWS Region where it's enabled**" → **사용 중인 모든 리전에 분석기를 만들어야** 전 환경을 봅니다
- **미사용 액세스 분석기** — "findings for the analyzer **do not change based on Region**" → **리전마다 만들 필요가 없습니다**

**지연 시간도 세 갈래입니다.** 정책을 추가·변경하면 **약 30분 내** 분석되고, **S3 다중 리전 액세스 지점** 관련은 **최대 6시간**이며, CloudTrail 전달 문제나 **RCP 제한 변경**은 정책 변경이 재스캔을 트리거하지 않아 **다음 주기 스캔(24시간 내)**에 반영됩니다. 즉시 확인하려면 **`Rescan` 링크 또는 `StartResourceScan` API**를 씁니다.

#### 5-3. 외부 액세스가 보는 것 — 리소스 15종과 넓은 외부 엔터티 정의

**리소스 유형 15종** — S3 버킷 · **S3 디렉터리 버킷** · IAM 역할 · KMS 키 · Lambda 함수 및 레이어 · SQS 큐 · Secrets Manager 보안 암호 · SNS 주제 · **EBS 볼륨 스냅샷** · **RDS DB 스냅샷** · **RDS DB 클러스터 스냅샷** · ECR 리포지토리 · EFS 파일 시스템 · **DynamoDB 스트림** · **DynamoDB 테이블**.

⚠️ **"S3와 IAM 역할만 본다"가 아닙니다** — **스냅샷 공유**가 전형적인 외부 노출 경로이고 EBS·RDS 스냅샷이 모두 대상입니다.

**외부 엔터티의 정의도 넓습니다** — 다른 AWS 계정 · 루트 사용자 · IAM 사용자·역할 · **연동 사용자** · **익명 사용자**.

⚠️ 조사 결과는 **배포 전 미리 보기**에도 씁니다 — 공식이 "preview how your policy affects public and cross-account access to your resource **before deploying**"라고 적습니다. 즉 **의도하지 않은 권한은 생기기 전에 막는 쪽이 먼저**입니다.

## ✍️ 시험 포인트

- **"같은 계정인데 리소스 정책만으로 접근이 된다"는 합집합이다** — 크로스 계정이면 양쪽이 필요합니다
- **"권한 경계를 붙였더니 아무것도 못 한다"는 교집합이 비었기 때문이다**
- **"SCP·권한 경계·ID 정책이 함께 걸렸다"는 셋 모두의 허용이 필요하다**
- **"외부 ID를 우리가 생성해 업체에 준다"는 틀렸다** — 업체가 만들어 관리합니다
- **"역할 ARN이 노출되면 위험하다"가 요지가 아니다** — ARN은 비밀이 아니고 방어는 외부 ID 조건입니다
- **"다른 계정의 CloudTrail 로그가 우리 버킷에 쌓인다"는 출처 조건 키 누락이다** — `aws:SourceArn`·`aws:SourceAccount`·`aws:SourceOrgID`·`aws:SourceOrgPaths`
- **"경로를 콘솔에서 만든다"는 안 된다** — API·CLI·PowerShell입니다
- **"`user/*`는 경로 없는 사용자만"은 틀렸다** — 경로가 있는 사용자도 매칭됩니다
- **"세션 정책에 `arn:aws:sqs`를 넣었다"는 실패한다** — 세션 정책은 불완전 ARN을 지원하지 않습니다
- **"팀마다 트러스트 앵커를 나눠 격리했다"는 거짓이다** — 격리는 역할 신뢰 정책의 조건입니다
- **"Verified Permissions로 로그인시킨다"는 틀렸다** — 인증은 하지 않습니다
- **"새 리소스가 생길 때마다 정책을 갱신해야 한다"는 RBAC의 단점이다** — ABAC는 태그로 흡수합니다
- **"IdP 속성으로 권한을 움직여라"는 세션 태그 + ABAC다**
- **"권한 경계를 인라인 정책으로 만든다"는 안 된다** — 관리형 정책만입니다
- **"리소스 정책에 역할 ARN을 적었는데 거부된다"는 권한 경계의 명시적 허용이 없기 때문이다** — 세션 ARN이면 필요하지 않습니다
- **"`NotPrincipal` + `Deny`로 예외를 뒀는데 전부 막힌다"는 권한 경계가 붙은 보안 주체 때문이다** — `ArnNotEquals` + `aws:PrincipalArn`을 씁니다
- **"세션 정책으로 확실히 좁혔다"가 거짓인 경우가 있다** — 리소스 정책이 **세션 ARN**을 적으면 제한되지 않습니다
- **"RCP가 막는지 시뮬레이터로 확인"은 안 된다** — 시뮬레이터는 RCP를 지원하지 않습니다
- **"붙이기 전에 정책 품질을 보라"는 정책 검증이고 추가 요금이 없다**
- **"전 리전의 외부 공유를 보라"는 리전마다 외부 액세스 분석기, "미사용 권한"은 리전 무관이다**
- **"스냅샷이 외부에 공유됐다"는 외부 액세스 분석기가 본다** — 대상 15종에 EBS·RDS 스냅샷이 듭니다

## ⚠️ 흔한 함정 {#pitfalls}

- ❌ "버킷 정책을 관리형 정책으로 만들어 여러 버킷에 재사용한다" → **관리형 리소스 기반 정책은 없습니다**
- ❌ "역할에 권한 정책만 붙이면 맡을 수 있다" → **신뢰 정책과 ID 기반 정책을 둘 다** 붙입니다
- ❌ "VPC 엔드포인트를 만들면 접근이 저절로 좁아진다" → 커스텀 정책이 없으면 **전체 허용 기본 정책**이 붙습니다
- ❌ "ACL로 같은 계정 안 사용자를 제어한다" → **같은 계정 보안 주체에는 쓸 수 없습니다**
- ❌ "외부 ID는 추측하기 어려운 값을 우리가 정한다" → **제3자가 생성·관리**합니다
- ❌ "교차 서비스 혼동된 대리인은 리소스 정책만으로 막는다" → 조건 키가 없으면 **서비스 보안 주체만 인증**하므로 막히지 않습니다
- ❌ "`aws:SourceArn` 계열은 리소스 정책에만 쓴다" → **RCP에도** 씁니다
- ❌ "`iam::123456789012:u*`로 사용자 전체를 지정한다" → **`user/` 부분에는 와일드카드를 쓰지 않습니다**
- ❌ "불완전 ARN은 어디서나 와일드카드로 채워진다" → **세션 정책에서는 오류**가 납니다
- ❌ "친숙한 이름으로 정책을 쓰면 안전하다" → 이름은 **삭제 후 재사용**되므로 고유 ID가 더 안전합니다
- ❌ "프로필에 세션 정책을 여럿 둔다" → **프로필의 세션 정책은 하나**입니다
- ❌ "Roles Anywhere는 조직 전체 제어와 연동된다" → **자동 통합이 없습니다**
- ❌ "Cedar 정책으로 IAM 권한도 평가한다" → 평가 대상은 **애플리케이션의 리소스**입니다
- ❌ "ABAC는 RBAC를 대체해야 한다" → 공식은 **공존**을 적습니다
- ❌ "RBAC의 역할은 IAM 역할이다" → 공식이 **다르다고 못박습니다**
- ❌ "권한 경계가 권한을 준다" → **제한만** 합니다
- ❌ "세션 정책으로 역할보다 넓은 권한을 준다" → **교집합**이라 불가능합니다
- ❌ "시뮬레이터로 RCP 영향을 미리 본다" → **RCP를 지원하지 않습니다**
- ❌ "시뮬레이터가 리소스 정책을 알아서 가져온다" → **콘솔 외에서는 내가 제공**해야 합니다
- ❌ "시뮬레이터 결과는 실제와 같다" → **VPC 엔드포인트 정책·역할 체이닝·다중 리소스 정책**에서 달라질 수 있습니다
- ❌ "정책 검증은 유료 기능이다" → **추가 요금이 없습니다**
- ❌ "외부 액세스 분석기를 한 리전에 만들면 전체를 본다" → **활성화된 리전만** 분석합니다
- ❌ "미사용 액세스도 리전마다 만들어야 한다" → **리전과 무관**합니다
- ❌ "정책을 바꾸면 모든 조사 결과가 30분 안에 갱신된다" → **RCP 제한 변경은 재스캔을 트리거하지 않습니다**

## 🧪 자가 점검

**Q1.** 파트너 회사 계정의 역할이 우리 S3 버킷에 쓸 수 있어야 합니다. 우리 쪽 버킷 정책에 그 역할 ARN을 보안 주체로 적어 `s3:PutObject`를 허용했는데도 거부됩니다. 무엇이 빠졌습니까? (→ 1-2·3-1 크로스 계정)

<details><summary>정답 보기</summary>

**파트너 계정 쪽 ID 기반 정책이 빠졌습니다.**

- 공식이 명시합니다 — 리소스 기반 정책에 **크로스 계정 보안 주체를 적는 것은 신뢰 관계를 세우는 절반**이고, 보안 주체와 리소스가 **다른 계정**이면 **그쪽 ID 기반 정책도** 그 리소스에 대한 접근을 허용해야 합니다
- ⚠️ **같은 계정**이라면 반대입니다 — 리소스 기반 정책이 허용하면 **추가 ID 기반 정책이 필요하지 않습니다**(합집합)
- 그래도 거부가 남으면 다음 후보는 **권한 경계**(파트너 역할에 붙어 있고 명시적 허용이 없는 경우 — §3-2), **SCP·RCP**, **버킷의 다른 명시적 거부**입니다

⚠️ 여기서 권한 경계가 특히 함정입니다 — 리소스 정책이 **역할 ARN**을 적었으므로 **권한 경계의 명시적 허용이 필요**합니다. 세션 ARN을 적었다면 필요하지 않았습니다.
</details>

**Q2.** 비용 최적화 업체에 우리 계정 접근을 위임합니다. 업체가 "역할을 만들고 신뢰 정책에 `sts:ExternalId` 조건을 넣어 달라"고 하면서 값을 알려줍니다. 더 안전하게 하려고 우리가 만든 임의의 GUID로 바꿔도 됩니까? (→ 1-3 외부 ID)

<details><summary>정답 보기</summary>

**안 됩니다. 외부 ID는 업체가 통제해야 의미가 있습니다.**

- 외부 ID가 막는 것은 **혼동된 대리인 문제**입니다 — 역할 ARN은 **비밀이 아니므로** 다른 고객이 같은 ARN을 업체에 넘길 수 있고, 그러면 업체가 **내 리소스에 접근**하게 됩니다
- 방어가 성립하는 이유는 **업체가 역할을 맡을 때 "그 요청을 보낸 고객"의 외부 ID를 항상 싣기 때문**입니다. 다른 고객이 내 ARN을 넘겨도 그 호출에는 **그 고객의 외부 ID**가 실려 조건과 어긋나 실패합니다
- 그래서 공식이 못박습니다 — 값은 **업체의 고객 사이에서 유일**해야 하고 **업체가 통제**하며, "**this is why you get it from Example Corp and you don't come up with it on your own**"입니다
- 내가 정한 값을 쓰면 **업체가 그 값을 호출에 실을 수 없으므로** 위임 자체가 깨지거나, 업체가 모든 고객에 같은 값을 쓰게 되어 보호가 사라집니다
</details>

**Q3.** 중앙 관리팀이 개발자에게 역할 생성 권한을 주되 민감 S3 버킷에는 절대 닿지 못하게 하려 합니다. 그리고 특정 버킷 정책에는 `NotPrincipal` + `Deny`로 "감사 역할만 빼고 전부 거부"를 적어 뒀습니다. 어떤 문제가 생깁니까? (→ 3-2 권한 범위)

<details><summary>정답 보기</summary>

**권한 경계가 붙은 보안 주체가 `NotPrincipal`의 값과 무관하게 전부 거부됩니다.**

- 공식 경고가 분명합니다 — 리소스 기반 정책의 **`NotPrincipal` + `Deny`**는 **권한 경계 정책이 붙어 있는 IAM 보안 주체를 항상 거부**하고, `NotPrincipal`에 무엇을 적었는지는 영향을 주지 않습니다. 그래서 **원래 접근할 수 있어야 했던 사용자·역할이 접근을 잃습니다**
- 권한 경계를 위임에 쓰는 설계 자체는 공식이 권하는 대표 용례입니다 — 중앙 관리자가 개발자의 ID 정책에 **"권한 경계를 붙인 역할만 만들 수 있다"**는 조건을 걸고, 경계가 민감 리소스를 **명시적으로 거부**합니다
- 고쳐야 할 쪽은 **버킷 정책**입니다. 공식 권고대로 **`ArnNotEquals` 연산자와 `aws:PrincipalArn` 조건 키**로 예외를 표현합니다

⚠️ 권한 경계는 **관리형 정책으로만** 설정하고 **권한을 부여하지 않습니다** — 개발자가 만든 역할에는 **별도의 권한 정책**이 있어야 실제로 일을 할 수 있습니다.
</details>

**Q4.** 조직에서 RCP를 새로 적용했습니다. 한 멤버 계정의 애플리케이션이 접근 거부를 받기 시작했고, 개발자가 "정책 시뮬레이터로 돌려 봤지만 전부 허용으로 나온다"고 합니다. 설명은? (→ 4-1·4-3 시뮬레이터)

<details><summary>정답 보기</summary>

**시뮬레이터는 RCP를 지원하지 않기 때문입니다.**

- 공식이 명시합니다 — 시뮬레이터는 **SCP를 평가하고**(조건 키와 거부 문장의 리소스 범위까지) **RCP는 "does not support"**입니다. 그래서 RCP가 원인인 거부는 시뮬레이션에서 **보이지 않습니다**
- 반대로 **Access Analyzer 정책 검증에는 RCP 전용 검사가 있습니다**(`Policy size exceeds RCP quota` · `RCP syntax error principal` · `RCP missing related principal condition key` 등) — RCP 문서의 품질을 보는 쪽은 이쪽입니다
- 원인 확인은 **CloudTrail의 접근 거부**로 접근하고, 공식은 RCP를 **조직 루트에 바로 붙이지 말고** 테스트 계정 → 하위 OU로 올리면서 **CloudTrail의 Access Denied를 검토**하라고 권합니다
- ⚠️ 멤버 계정의 개발자가 스스로 알기 어려운 구조이기도 합니다 — SCP·RCP가 그 요청을 거부하는지 확인하려면 `organizations:DescribeOrganization` 권한이 필요하고, 그 이상은 **조직 관리자에게 문의**하라고 공식이 적습니다

⚠️ 그리고 시뮬레이터가 실제와 갈리는 구성이 더 있습니다 — **VPC 엔드포인트 정책 · 역할 체이닝 · 한 리소스에 여러 리소스 기반 정책**입니다.
</details>

**Q5.** 감사에서 "전 리전의 리소스가 외부와 공유되는지와, 쓰이지 않는 IAM 권한을 모두 보고하라"는 요구가 나왔습니다. Access Analyzer 분석기를 몇 개 만들어야 합니까? (→ 5-1·5-2 Access Analyzer)

<details><summary>정답 보기</summary>

**외부 액세스 분석기는 사용 중인 리전마다, 미사용 액세스 분석기는 하나면 됩니다.**

- 공식이 리전 축을 다르게 적습니다 — **외부 액세스 분석기**는 "analyzes only policies applied to resources in **the same AWS Region where it's enabled**"이므로 **전 환경을 보려면 사용 중인 모든 리전에 만들어야** 합니다
- 반면 **미사용 액세스 분석기**는 "findings for the analyzer **do not change based on Region**"이라 **리전마다 만들 필요가 없습니다**
- ⚠️ 둘은 서로 다른 질문에 답합니다 — 외부 액세스는 "**누가 밖에서 닿을 수 있나**", 미사용 액세스는 "**부여했지만 안 쓰는 권한이 무엇인가**"입니다. 미사용 액세스 분석기를 외부 공유 탐지에 쓰려 하면 답이 나오지 않습니다
- 분석기를 만드는 단위(조직 또는 계정)가 **신뢰 영역**이 되고, 그 안의 보안 주체 접근은 신뢰된 것으로 봅니다

⚠️ **갱신 지연도 한 갈래가 아닙니다** — 정책 변경은 **약 30분 내**, S3 다중 리전 액세스 지점 관련은 **최대 6시간**, **RCP 제한 변경은 재스캔을 트리거하지 않아 다음 주기 스캔(24시간 내)**에 반영됩니다. 즉시 보려면 `Rescan` 또는 `StartResourceScan`을 씁니다.
</details>

**Q6.** 팀마다 트러스트 앵커를 따로 만들어 온프레미스 서버가 각 팀의 역할만 맡게 설계했습니다. 프로필과 역할도 팀별로 나눴습니다. 이 설계로 팀 사이 격리가 보장됩니까? (→ 1-5 Roles Anywhere)

<details><summary>정답 보기</summary>

**보장되지 않습니다. Roles Anywhere의 신뢰 경계는 계정 수준입니다.**

- 공식 문구가 그대로 답입니다 — "Certificates issued by **any** trust anchor in the account can be used to assume **any** target role in that same account, **unless you specify conditions in the role's trust policy**."
- 즉 **앵커를 나눈 것만으로는 앵커 사이 격리가 없습니다.** A팀 CA가 발급한 인증서로 B팀 역할을 맡을 수 있습니다
- 격리는 **역할 신뢰 정책의 조건**으로 만듭니다 — 신뢰 정책의 **`aws:SourceArn`** 조건 키에 그 역할이 받아들일 **트러스트 앵커 ARN**을 값으로 두는 것이 공식이 적는 묶음 방식입니다
- ⚠️ 그리고 **조직 수준 제어와 자동 통합이 없습니다**("There is no automatic integration with organization-wide controls") — "조직에 SCP를 걸었으니 Roles Anywhere도 함께 통제된다"고 가정하지 않습니다
- ⚠️ 모든 Roles Anywhere 리소스는 **리전 리소스**이고 함께 쓰려면 **같은 계정·같은 리전**에 있어야 합니다

⚠️ 덤으로 **프로필의 세션 정책은 하나뿐**입니다("A profile can have many IAM roles, but only one session policy") — 역할마다 다른 세션 제약을 주려면 프로필을 나눕니다.
</details>

### 📌 출처

1. Policies and permissions in AWS Identity and Access Management — `docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html` (2026-11-09 확인)
2. Policy evaluation logic — `docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_evaluation-logic.html` (2026-11-09 확인)
3. Permissions boundaries for IAM entities — `docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_boundaries.html` (2026-11-09 확인)
4. IAM identifiers — `docs.aws.amazon.com/IAM/latest/UserGuide/reference_identifiers.html` (2026-11-09 확인)
5. IAM and AWS STS quotas — `docs.aws.amazon.com/IAM/latest/UserGuide/reference_iam-quotas.html` (2026-11-09 확인)
6. Define permissions based on attributes with ABAC authorization — `docs.aws.amazon.com/IAM/latest/UserGuide/introduction_attribute-based-access-control.html` (2026-11-09 확인)
7. IAM policy testing with the IAM policy simulator — `docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_testing-policies.html` (2026-11-09 확인)
8. Permissions for using the policy simulator — `docs.aws.amazon.com/IAM/latest/UserGuide/permissions-required_policy-simulator.html` (2026-11-09 확인)
9. IAM policy validation — `docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_policy-validator.html` (2026-11-09 확인)
10. IAM policy validation check reference — `docs.aws.amazon.com/IAM/latest/UserGuide/access-analyzer-reference-policy-checks.html` (2026-11-09 확인)
11. Using AWS Identity and Access Management Access Analyzer — `docs.aws.amazon.com/IAM/latest/UserGuide/what-is-access-analyzer.html` (2026-11-09 확인)
12. The confused deputy problem — `docs.aws.amazon.com/IAM/latest/UserGuide/confused-deputy.html` (2026-11-09 확인)
13. What is AWS Identity and Access Management Roles Anywhere? — `docs.aws.amazon.com/rolesanywhere/latest/userguide/introduction.html` (2026-11-09 확인)
14. What is Amazon Verified Permissions? — `docs.aws.amazon.com/verifiedpermissions/latest/userguide/what-is-avp.html` (2026-11-09 확인)
15. Resource control policies (RCPs) — `docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_rcps.html` (2026-11-09 확인)
