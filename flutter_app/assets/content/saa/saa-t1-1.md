---
examGuideTaskId: saa-t1-1
certCode: SAA-C03
domain: 1
domainName: 보안 아키텍처 설계
domainWeightPct: 30
title: IAM — 자격증명·권한·페더레이션
coversTasks:
  - "1.1"
sources:
  - title: AWS Identity and Access Management — 소개 (공식)
    url: https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction.html
  - title: IAM 정책과 권한 (공식)
    url: https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html
  - title: IAM 역할 (공식)
    url: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html
  - title: IAM 자격 증명 공급자와 페더레이션 (공식)
    url: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers.html
  - title: SAA-C03 공식 시험 가이드 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
lastVerified: 2026-06-07
---

# IAM — 자격증명·권한·페더레이션

> **커버하는 공식 Task** — SAA-C03 · 도메인 1 「보안 아키텍처 설계」(30%) · **Task 1.1 AWS 리소스에 대한 보안 액세스 설계** (`saa-t1-1`)
> 이 문서는 위 한 Task에 1:1로 매핑됩니다. 도메인 1은 시험 비중 1위(30%) — IAM은 그 출발점입니다.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명할 수 있어야 합니다. (공식 시험 가이드 Task 1.1의 Skill 항목 기반)

- [ ] **IAM 보안 모범 사례** — 루트 사용자 보호(MFA), 최소 권한 원칙을 설명할 수 있다
- [ ] **유연한 권한 모델 설계** — 사용자·그룹·역할·정책의 관계를 그릴 수 있다
- [ ] **역할 기반 액세스 제어** — AWS STS `AssumeRole`, 역할 전환, 교차 계정 패턴을 설명할 수 있다
- [ ] **다계정 보안 전략** — AWS Organizations + SCP의 "권한 상한선" 메커니즘을 안다
- [ ] **리소스 정책 사용 결정** — 아이덴티티 기반 정책 vs 리소스 기반 정책을 언제 쓰는지 안다
- [ ] **디렉터리 서비스 연동 시점** — SAML, OIDC, IAM Identity Center 중 상황별 선택 기준을 안다

---

## 🎯 왜 중요한가

- 도메인 1(30%)은 SAA 시험에서 비중이 가장 높습니다. IAM은 모든 접근 제어의 뿌리 — 다른 도메인의 보안 질문도 IAM 개념이 전제로 깔립니다.
- 시험은 "누가 무엇에 접근해야 하는가"라는 시나리오를 주고 **올바른 자격증명 방식·정책 유형·페더레이션 선택**을 고르게 합니다.
- CLF에서 IAM을 개념 수준으로 봤다면, SAA는 **설계 결정**을 묻습니다. 역할 vs 사용자, 신뢰 정책 vs 권한 정책, SCP vs 권한 경계 — 각각 언제 무엇을 쓰는지가 핵심입니다.

---

## 📖 핵심 개념

### 1) IAM이란

> 공식 정의: **"AWS 리소스에 대한 액세스를 안전하게 제어하는 웹 서비스."** 누가 인증(authenticated)되고, 무엇을 사용할 권한(authorized)이 있는지를 관리합니다.

IAM은 **글로벌 서비스**입니다 — 리전이 없고, 추가 요금도 없습니다. (IAM, STS, IAM Identity Center 모두 무료)

### 2) IAM 구성요소

| 요소 | 설명 | 자격증명 유형 |
|---|---|---|
| **루트 사용자** | 계정 생성 시 자동 부여. 전체 권한. 일상 작업에 사용 금지 | 이메일+비밀번호, 액세스 키 |
| **IAM 사용자(User)** | 개별 장기 자격증명. 콘솔 비밀번호 또는 액세스 키 | 장기(long-term) |
| **IAM 그룹(Group)** | 사용자 묶음 — 그룹에 정책을 붙이면 멤버 전원 적용. 그룹에 그룹은 불가 | 없음(컨테이너) |
| **IAM 역할(Role)** | 특정인이 아닌 **누구든 수임(assume)** 가능한 ID. 장기 자격증명 없음 | **임시(STS)** |
| **정책(Policy)** | 권한 규칙을 담은 JSON 문서 — 아이덴티티나 리소스에 부착 | — |

> 핵심 대비: **사용자 = 장기 키**, **역할 = 임시 STS 토큰**. 애플리케이션·서비스에는 역할을 사용하고 액세스 키를 코드에 넣지 않습니다.

### 3) 정책 유형 비교 (★ 시험 핵심)

| 정책 유형 | 부착 대상 | 권한 부여 여부 | 주요 용도 |
|---|---|---|---|
| **아이덴티티 기반(Identity-based)** | 사용자·그룹·역할 | 부여 O | 일반 권한 설정 |
| **리소스 기반(Resource-based)** | 리소스(S3 버킷 등) | 부여 O | 교차 계정 액세스, S3 버킷 정책 |
| **권한 경계(Permissions boundary)** | 사용자·역할 | 부여 X (상한선) | 위임 시 과도 권한 방지 |
| **SCP (서비스 제어 정책)** | Organizations 계정·OU | 부여 X (상한선) | 다계정 가드레일 |
| **세션 정책(Session policy)** | 임시 세션 | 부여 X (교집합) | AssumeRole 시 추가 제한 |

> **SCP와 권한 경계의 공통점**: 둘 다 권한을 "부여"하지 않고 **최대치를 제한**합니다. SCP가 `s3:*`를 막으면 그 계정의 관리자도 S3를 사용할 수 없습니다.

### 4) 권한 평가 로직 (★ 단골 출제)

```
1. 명시적 Deny → 무조건 거부 (최우선, 모든 Allow를 이김)
2. 명시적 Allow → 허용
3. 아무것도 없으면 → 암묵적 Deny (기본 거부)
```

> **명시적 Deny > 명시적 Allow > 암묵적 Deny.** SCP·권한 경계·세션 정책 등 어느 레이어의 Deny든 이 규칙이 적용됩니다.

정책 JSON의 핵심 요소:

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": ["s3:GetObject"],
    "Resource": "arn:aws:s3:::my-bucket/*",
    "Condition": { "Bool": { "aws:MultiFactorAuthPresent": "true" } }
  }]
}
```

- `Effect`: Allow 또는 Deny
- `Action`: API 작업(예: `s3:GetObject`)
- `Resource`: ARN으로 지정
- `Condition`: IP, MFA, 시간 등 추가 조건 (선택)

### 5) IAM 역할과 STS (AWS Security Token Service)

역할(Role)에는 두 가지 정책이 항상 함께 붙습니다:

| 정책 종류 | 질문 | 예시 |
|---|---|---|
| **신뢰 정책(Trust policy)** | *누가* 이 역할을 수임할 수 있나? | `ec2.amazonaws.com`, 타 계정 IAM 사용자 |
| **권한 정책(Permissions policy)** | 이 역할이 *무엇을* 할 수 있나? | `s3:GetObject`, `dynamodb:PutItem` |

역할 수임 흐름:

```
Principal → sts:AssumeRole 호출
    → STS가 임시 자격증명 발급 (Access Key ID + Secret Key + Session Token)
    → 임시 자격증명으로 AWS 리소스 접근 (기본 최대 1시간, 최대 12시간)
```

**역할을 써야 하는 상황:**

| 상황 | 올바른 방법 |
|---|---|
| EC2 인스턴스 → S3 접근 | EC2 인스턴스 프로필(IAM Role 부착) |
| Lambda → DynamoDB 접근 | Lambda 실행 역할 |
| 계정 A 사용자 → 계정 B 리소스 | 계정 B에 Cross-account Role 생성 + `sts:AssumeRole` |
| 코드/앱에서 AWS 접근 | 역할 (액세스 키 하드코딩 절대 금지) |

### 6) 페더레이션 (Federation)

외부 ID를 사용해 AWS에 접근하는 방식. 사람(사원·고객)에 대해 IAM 사용자를 개별 생성하는 대신, **기존 ID 시스템을 신뢰**합니다.

| 방식 | 적합한 상황 | 작동 방식 |
|---|---|---|
| **IAM Identity Center** | 조직 직원 다계정 접근 (권장) | Organizations 통합, SAML IdP 또는 내장 디렉터리 연동, SSO |
| **SAML 2.0 (IAM 직접)** | 단일 계정, 기업 디렉터리(AD/Shibboleth) | IdP가 SAML assertion 발급 → `AssumeRoleWithSAML` |
| **OIDC (웹 자격 증명)** | 모바일·웹 앱, GitHub Actions 등 | OIDC 토큰 → `AssumeRoleWithWebIdentity` |
| **Amazon Cognito** | 앱 사용자(소비자) | User Pool 인증 + Identity Pool으로 임시 IAM 자격증명 |

> AWS 공식 권장: **인간 사용자는 IAM Identity Center를 통한 페더레이션**을 사용하고, IAM 사용자 직접 생성을 최소화합니다.

### 7) 다계정 보안 (AWS Organizations + SCP)

| 도구 | 역할 | 핵심 특성 |
|---|---|---|
| **AWS Organizations** | 다계정 통합 관리·통합 결제 | OU(조직 단위) 계층 구조 |
| **SCP** | 계정·OU 권한 상한선 | 권한 부여 X, 제한만 O. 루트 사용자에도 적용 |
| **AWS Control Tower** | 다계정 Landing Zone 자동 설정 | SCP·가드레일 선탑재 |
| **IAM Access Analyzer** | 외부 공유·과도 권한 탐지 | 리소스가 외부에 열려 있는지 분석 |

> SCP는 **IAM 사용자·역할** 모두에 적용됩니다. 해당 계정의 루트 사용자도 SCP의 제한을 받습니다(단, 관리 계정의 루트는 예외).

---

## ✍️ 시험 포인트

- **EC2·Lambda에서 AWS 서비스 접근** → 항상 IAM Role(인스턴스 프로필/실행 역할). 액세스 키를 코드나 환경변수에 넣는 보기는 무조건 오답.
- **교차 계정 접근** → 대상 계정에 Role 생성(신뢰 정책에 소스 계정 지정) + 소스 계정 사용자에게 `sts:AssumeRole` 허용.
- **다계정 일괄 가드레일** → SCP(Organizations). Permission Boundary는 단일 사용자·역할 수준.
- **페더레이션 선택**: 조직 직원 = IAM Identity Center, 기업 AD 단일계정 = SAML, 앱 사용자 = Cognito, GitHub Actions = OIDC.
- **명시적 Deny 우선**: 어느 정책에서든 Deny가 있으면 Allow를 이깁니다. 시험에서 "모든 서비스를 Allow하는 정책 + 특정 서비스 Deny" → Deny가 이깁니다.
- **신뢰 정책 vs 권한 정책**: 역할에는 반드시 둘 다 필요. 신뢰 정책만 있으면 수임은 가능해도 아무것도 못 하고, 권한 정책만 있으면 수임 자체가 안 됩니다.
- **루트 사용자 보호**: MFA 필수, 액세스 키 발급 금지, 일상 작업에 사용 금지 — 이 세 가지는 AWS 모범 사례의 첫 번째 항목입니다.

---

## ⚠️ 흔한 함정

1. **"액세스 키를 EC2 인스턴스에 저장하면 된다."** → 절대 금지. IAM Role을 인스턴스에 부착하면 SDK가 자동으로 임시 자격증명을 가져옵니다. 키 하드코딩은 유출 위험과 교체 비용 모두 큽니다.

2. **"역할은 영구 권한이다."** → 역할 수임 시 STS가 발급하는 자격증명은 **임시**(기본 1시간, 설정에 따라 최대 12시간)입니다. 만료되면 재수임이 필요합니다.

3. **"신뢰 정책과 권한 정책이 같다."** → 신뢰 정책은 **누가 역할을 수임할 수 있는지**, 권한 정책은 **역할이 무엇을 할 수 있는지**입니다. 둘은 별개의 문서로 역할에 함께 붙습니다.

4. **"SCP를 붙이면 권한이 부여된다."** → SCP는 허용 가능한 권한의 **최대치를 제한**할 뿐, 권한을 부여하지 않습니다. SCP가 Allow여도 아이덴티티 기반 정책에 Allow가 없으면 접근 불가입니다.

5. **"Permission Boundary와 SCP는 같은 것이다."** → 적용 범위가 다릅니다. Permission Boundary는 **개별 IAM 사용자·역할**에 설정하고, SCP는 **AWS Organizations의 계정·OU 전체**에 적용됩니다.

6. **"같은 계정 내 리소스 기반 정책에서는 아이덴티티 기반 정책도 반드시 있어야 한다."** → 같은 계정 내에서는 리소스 기반 정책만으로 접근을 허용할 수 있습니다. 교차 계정일 때는 양쪽 모두 필요합니다.

---

## 🧪 자가 점검

> 아래는 학습용 자가 점검입니다. (정식 검증 문항은 별도 문항 파일 참조)

**Q1.** EC2 인스턴스에서 실행 중인 애플리케이션이 S3 버킷에 파일을 써야 합니다. 가장 안전한 방법은?

<details><summary>정답 보기</summary>

**IAM Role을 생성해 EC2 인스턴스 프로필로 부착**합니다. SDK가 인스턴스 메타데이터 서비스(IMDS)를 통해 자동으로 임시 자격증명을 가져오므로 코드에 액세스 키를 저장할 필요가 없습니다. 액세스 키를 환경변수나 코드에 하드코딩하는 방식은 유출 위험이 있어 AWS 모범 사례에 어긋납니다.
</details>

**Q2.** 계정 A의 개발팀이 계정 B에 있는 DynamoDB 테이블을 읽어야 합니다. 어떻게 설계하나요?

<details><summary>정답 보기</summary>

**계정 B에 IAM Role을 생성**합니다. 이 역할의 신뢰 정책에 계정 A를 신뢰 주체로 지정하고, 권한 정책에 `dynamodb:GetItem` 등 필요한 DynamoDB 권한을 부여합니다. 계정 A의 사용자·역할에는 `sts:AssumeRole`로 계정 B의 역할 ARN을 허용합니다. 이를 **교차 계정(Cross-account) 역할 패턴**이라 합니다.
</details>

**Q3.** Organizations에서 특정 OU 전체의 계정이 `us-east-1` 외 리전을 사용하지 못하도록 강제하려 합니다. 어떤 도구를 사용하나요?

<details><summary>정답 보기</summary>

**SCP(서비스 제어 정책)**를 해당 OU에 적용합니다. SCP는 계정·OU 단위의 권한 상한선으로, OU에 붙이면 하위 계정의 루트 사용자를 포함한 모든 IAM 아이덴티티에 적용됩니다. Permission Boundary는 개별 사용자·역할에만 적용되므로 OU 전체 가드레일에는 SCP가 적합합니다.
</details>

**Q4.** 기업이 Microsoft Active Directory를 사용 중이며, 수백 명의 직원이 여러 AWS 계정에 SSO로 접근해야 합니다. 가장 적합한 AWS 서비스는?

<details><summary>정답 보기</summary>

**AWS IAM Identity Center**(구 AWS SSO)입니다. Organizations과 통합되어 다계정 접근 관리를 중앙화하고, Active Directory 등 SAML 2.0 IdP와 연동해 SSO를 제공합니다. 단일 계정 + SAML 직접 연동(IAM)보다 다계정 환경에서 IAM Identity Center가 권장됩니다.
</details>

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. (작성·대조: 2026-06-07)

1. AWS Identity and Access Management — 소개 — https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction.html
2. IAM 정책과 권한 — https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html
3. IAM 역할 — https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html
4. IAM 자격 증명 공급자와 페더레이션 — https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers.html
5. SAA-C03 공식 시험 가이드 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
