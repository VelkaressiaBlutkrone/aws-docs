---
examGuideTaskId: saa-t1-4
certCode: SAA-C03
domain: 1
domainName: 보안 아키텍처 설계
domainWeightPct: 30
title: 애플리케이션 보안 — Shield·WAF·Cognito·Secrets Manager
coversTasks:
  - "1.2"
sources:
  - title: What is AWS WAF? (공식)
    url: https://docs.aws.amazon.com/waf/latest/developerguide/what-is-aws-waf.html
  - title: How AWS Shield and Shield Advanced work (공식)
    url: https://docs.aws.amazon.com/waf/latest/developerguide/ddos-overview.html
  - title: What is Amazon Cognito? (공식)
    url: https://docs.aws.amazon.com/cognito/latest/developerguide/what-is-amazon-cognito.html
  - title: What is AWS Secrets Manager? (공식)
    url: https://docs.aws.amazon.com/secretsmanager/latest/userguide/intro.html
  - title: SAA-C03 공식 시험 가이드 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
  - title: 웹 ACL 규칙 액션(종료·비종료) (공식)
    url: https://docs.aws.amazon.com/waf/latest/developerguide/web-acl-rule-actions.html
  - title: Rate-based 규칙 상위 설정(평가 창·한도) (공식)
    url: https://docs.aws.amazon.com/waf/latest/developerguide/waf-rule-statement-type-rate-based-high-level-settings.html
  - title: CreateWebACL — 스코프·보호 대상 리소스 (공식 API)
    url: https://docs.aws.amazon.com/waf/latest/APIReference/API_CreateWebACL.html
  - title: Cognito 사용자 풀 기능 플랜 (공식)
    url: https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-sign-in-feature-plans.html
  - title: AWS WAF Anti-DDoS 관리형 규칙 그룹(유료·웹 ACL에 추가) (공식)
    url: https://docs.aws.amazon.com/waf/latest/developerguide/waf-anti-ddos-advanced.html
lastVerified: 2026-10-28
---

# 애플리케이션 보안 — Shield·WAF·Cognito·Secrets Manager

> **커버하는 공식 Task** — SAA-C03 · 도메인 1 「보안 아키텍처 설계」(30%) · **Task 1.2 보안 워크로드와 애플리케이션 설계** (`saa-t1-4`)
> 이 문서는 위 한 Task에 1:1로 매핑됩니다. 계층별 방어(엣지·애플리케이션·자격증명)가 핵심입니다.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명할 수 있어야 합니다.

- [ ] **AWS WAF** — 웹 ACL·규칙·관리형 규칙 그룹, SQL injection/XSS 방어, rate limit 동작 방식을 설명할 수 있다
- [ ] **AWS Shield Standard vs Advanced** — 차이점, 보호 대상, 비용, Shield Response Team(SRT) 역할을 구분할 수 있다
- [ ] **AWS Firewall Manager** — 다계정 WAF·Shield 정책 중앙화 역할을 안다
- [ ] **Amazon Cognito User Pool vs Identity Pool** — 인증(Authentication)과 권한부여(Authorization)를 각각 어느 쪽이 담당하는지 구분할 수 있다
- [ ] **AWS Secrets Manager** — 자동 교체(rotation)의 작동 방식과 사용 시점을 안다
- [ ] **Secrets Manager vs Parameter Store** — 비용·교체 필요 여부로 선택 기준을 설명할 수 있다
- [ ] **계층별 방어** — CloudFront + WAF + Shield가 엣지에서 어떻게 조합되는지 설명할 수 있다

---

## 🎯 왜 중요한가

- 도메인 1(30%)은 SAA 시험 비중 1위입니다. Task 1.2는 "어떤 서비스가 어떤 위협을 막는가"를 시나리오로 묻습니다.
- WAF와 Shield는 이름이 비슷해 혼동하기 쉽지만 역할이 완전히 다릅니다. WAF는 **HTTP/HTTPS 요청 내용(L7)** 필터링, Shield는 **DDoS(L3/L4/L7)** 방어입니다.
- Cognito는 "앱 사용자 인증"의 정답으로 단골 등장하며, User Pool과 Identity Pool의 역할 구분이 출제 포인트입니다.
- Secrets Manager vs Parameter Store 비교표는 시험 단골 — "자동 교체가 필요한가?"로 결정합니다.

---

## 🔤 먼저 알아야 할 용어

이 문서를 읽는 데 필요한 기초 용어입니다. 이미 알면 건너뛰세요.

| 용어 | 영문 | 한 줄 풀이 |
|---|---|---|
| **웹 ACL** | Web Access Control List | WAF의 규칙 컨테이너 — 요청을 순서대로 평가해 첫 매칭 액션(Allow/Block/Count)을 실행 |
| **관리형 규칙 그룹** | Managed Rule Group | AWS 또는 서드파티가 사전 구성한 WAF 규칙 묶음 — OWASP Top 10 등 |
| **DDoS** | Distributed Denial of Service | 대량 트래픽으로 서비스를 불능 상태로 만드는 분산 공격 |
| **SRT** | Shield Response Team | Shield Advanced 가입자 전용 24/7 DDoS 대응 전담팀 |
| **JWT** | JSON Web Token | 서명된 JSON 기반 자격증명 토큰 — Cognito User Pool 인증 성공 시 발급 |
| **STS** | Security Token Service | 임시 AWS 자격증명을 발급하는 서비스 — Cognito Identity Pool이 내부적으로 호출 |
| **rotation** | 자동 교체 | 저장된 비밀값을 주기적으로 새 값으로 바꾸는 Secrets Manager 기능 |
| **Rate-based 규칙** | Rate-based rule | 지정 시간 내 특정 IP의 요청 수가 임계치를 초과하면 차단하는 WAF 규칙 |

---

## 📖 핵심 개념 {#core-concepts}

### 1) AWS WAF — 웹 애플리케이션 방화벽 {#waf}

> 공식 정의: **"HTTP/HTTPS 요청을 모니터링하고 콘텐츠 접근을 제어하는 웹 애플리케이션 방화벽."** L7(애플리케이션 계층) 트래픽을 조건 기반으로 허용·차단·계수합니다.

**WAF가 보호할 수 있는 리소스 (공식):**

- Amazon CloudFront 배포
- Application Load Balancer (ALB)
- Amazon API Gateway REST API
- AWS AppSync GraphQL API
- Amazon Cognito User Pool
- AWS App Runner 서비스
- AWS Verified Access 인스턴스
- AWS Amplify 애플리케이션
- Amazon Bedrock AgentCore Gateway

> **리전·스코프 규칙**: 웹 ACL은 만들 때 스코프를 고릅니다. **CloudFront 배포에 붙일 웹 ACL은 스코프 `CLOUDFRONT`이며 `us-east-1`(미국 동부 버지니아 북부)에서 만들어야** 합니다(CLI는 `--scope=CLOUDFRONT --region=us-east-1`, SDK·API는 `us-east-1` 리전 엔드포인트). 그 밖의 리소스는 스코프 `REGIONAL`이고 **리소스와 같은 리전**에 만듭니다.

**웹 ACL(Web Access Control List):**

웹 ACL은 WAF의 최상위 컨테이너입니다. 규칙을 **우선순위 숫자가 낮은 것부터** 평가하는데, **액션마다 평가를 끝내는지가 다릅니다.**

| 액션 | 종료 여부 | 동작 |
|---|---|---|
| **Allow · Block** | **종료** | 매칭되면 그 요청에 대한 웹 ACL 평가를 멈추고 최종 처리를 확정합니다(뒤 규칙은 평가하지 않음) |
| **Count** | **비종료** | 요청을 세고 **뒤 규칙 평가를 계속**합니다 — 규칙을 끄지 않고 영향도를 관측하는 용도 |
| **CAPTCHA · Challenge** | **둘 다 가능** | 유효한 토큰이 있으면 Count처럼 세고 계속, 없으면 평가를 **종료**하고 퍼즐·무음 챌린지를 보냅니다 |

> 어떤 규칙도 종료 액션을 내지 않으면 **웹 ACL의 기본 작업(default action)** 이 적용됩니다. 그래서 "Count 규칙을 앞에 둬서 차단이 안 됐다"는 식의 보기는 틀립니다 — Count는 흐름을 멈추지 않습니다.

**규칙 유형:**

| 규칙 유형 | 설명 |
|---|---|
| **IP 세트 규칙** | 특정 IP 주소·CIDR 범위 허용 또는 차단 |
| **지역(Geo) 규칙** | 특정 국가에서 오는 요청 필터링 |
| **SQL Injection 탐지** | 요청 내 악성 SQL 코드 패턴 차단 |
| **XSS 탐지** | 크로스사이트 스크립팅 스크립트 패턴 차단 |
| **Rate-based 규칙** | 평가 창(**60·120·300·600초** = 1·2·5·10분, **기본 300초**) 안의 요청 수가 한도를 넘으면 액션 적용. 한도 **최소 10**, 집계 기준(IP·헤더·커스텀 키) 선택 가능 (봇·브루트포스 방어) |
| **관리형 규칙 그룹** | AWS 또는 AWS Marketplace 셀러가 제공하는 사전 구성 규칙 세트 |

> **관리형 규칙 그룹**: AWS가 제공하는 `AWSManagedRulesCommonRuleSet` 같은 그룹을 웹 ACL에 추가하면 OWASP Top 10 공격 패턴을 별도 규칙 작성 없이 방어할 수 있습니다.

> **WAF도 L7 DDoS를 완화한다 — 단, 유료 옵트인이다**: `AWSManagedRulesAntiDDoSRuleSet`(Anti-DDoS 관리형 규칙 그룹)은 **WAF에서 쓸 수 있는 가장 상위 Anti-DDoS 보호**입니다. 다만 이 그룹을 **웹 ACL에 추가하고** 차단 민감도·챌린지를 구성해야 동작하며 **추가 요금**이 붙습니다. 그래서 "추가 설정 없이 모든 계정에 자동 적용되는 무료 DDoS 방어"는 WAF가 아니라 **Shield Standard**입니다 — 시험에서 이 둘을 바꿔 놓은 보기가 나옵니다(근거 10번).

**WAF 액션:**

```
Allow  → 요청 통과
Block  → HTTP 403 응답 반환
Count  → 통계만 수집 (규칙 테스트 시 활용)
CAPTCHA / Challenge → 봇 여부 검증
```

> 🧠 원리: 왜 Allow·Block만 평가를 끝내고 Count는 끝내지 않을까요?
> Allow·Block은 요청의 **최종 처리를 확정**하는 결정이라 더 볼 규칙이 없습니다 — 그래서 종료 액션입니다.
> 반면 Count는 "이 규칙이 매칭됐다"는 **관측 기록**일 뿐 처리를 정하지 않으므로, 여기서 평가를 멈추면 뒤 규칙의 차단 판단을 잃게 됩니다. 새 규칙을 Count로 먼저 돌려 오탐을 확인하고 Block으로 바꾸는 운영 패턴이 이 성질에 기댑니다.
> 우선순위는 여전히 중요합니다 — 숫자가 낮은 규칙부터 평가하므로 Allow 규칙을 앞에 두면 뒤의 Block 규칙은 평가되지 않습니다(화이트리스트 우선). 반대로 Allow 대상 요청까지 Count 지표에 담으려면 Count 규칙에 **더 낮은 우선순위 숫자**를 줘 먼저 돌려야 합니다.

### 2) AWS Shield — DDoS 방어 {#shield}

> 공식 정의: **"L3/L4 및 L7 계층의 분산 서비스 거부(DDoS) 공격으로부터 AWS 리소스를 보호하는 서비스."**

**Shield Standard vs Shield Advanced:**

| 구분 | Shield Standard | Shield Advanced |
|---|---|---|
| **비용** | 무료 (모든 AWS 고객 자동 적용) | 유료 구독 — 월 $3,000/조직 + 데이터 전송 사용료 |
| **보호 계층** | L3/L4 (네트워크·전송) | L3/L4 + L7 (애플리케이션) |
| **자동 완화** | 일반 DDoS 자동 완화 | 애플리케이션 계층 DDoS 자동 완화 포함 |
| **보호 대상** | CloudFront, Route 53, ALB, EC2 등 (기본 범위) | EC2, ELB, CloudFront, Route 53, Global Accelerator |
| **Shield Response Team(SRT)** | 없음 | 전담 DDoS 대응 팀 — 연락에는 **Business·Enterprise Support 플랜 필요** |
| **고급 가시성** | 없음 | 상세 이벤트 가시성, CloudWatch 메트릭 |
| **비용 보호** | 없음 | DDoS로 인한 요금 급증 시 크레딧 제공 |

> **핵심 구분**: Shield Standard는 L3/L4 수준의 기본 DDoS 자동 방어를 무료로 제공합니다. Shield Advanced는 L7 자동 완화, SRT 전담 지원, 이벤트 리포트가 추가됩니다. 고트래픽·고가시성 사이트에 적합합니다.

**Shield Advanced 요금 구조와 SRT 조건 (★ 출제 포인트)**

- **월 $3,000이 조직 단위입니다.** 계정마다 따로 내는 것이 아니라, 계정들이 하나의 **통합 결제** 아래 있으면 월 요금을 **한 번만** 냅니다. 여기에 Shield Advanced **데이터 전송 사용료**가 사용량 기준으로 더해집니다.
- **표준 AWS WAF 비용이 구독에 포함됩니다.** 보호 리소스의 웹 ACL·규칙·웹 요청 검사 기본 요금이 **1,500 WCU**와 기본 본문 크기까지 포함되고, 월 **500억 요청**까지 포함됩니다. Bot Control·CAPTCHA 규칙 액션, 1,500 WCU를 넘는 웹 ACL처럼 표준 범위를 벗어난 것은 포함되지 않습니다.
- **자동 L7 완화를 켜면 규칙 그룹이 추가되고 150 WCU를 씁니다.** 1,500 WCU 포함 범위를 계산할 때 이 몫을 빼고 생각해야 합니다.
- ⚠️ **SRT는 구독만으로 연락이 되지 않습니다.** 공식 FAQ는 SRT에 에스컬레이션하거나 투입을 요청하려면 **Business 또는 Enterprise Support 플랜**이 필요하다고 적고, 응답 시간도 가입한 Support 플랜에 달려 있다고 적습니다. "Advanced만 구독하면 SRT 지원을 받는다"는 보기는 이 조건을 빠뜨린 것입니다.

**DDoS 공격 유형 (Shield가 탐지):**

```
L3 — 네트워크 볼류메트릭 공격 (대역폭 포화)
L4 — 네트워크 프로토콜 공격 (TCP SYN flood 등 상태 고갈)
L7 — 애플리케이션 계층 공격 (정상 요청처럼 보이는 대량 웹 요청)
```

> 🧠 원리: 왜 Shield Standard와 Advanced는 L3/L4는 공통이지만 L7 자동 완화는 Advanced에만 있을까요?
> L3/L4 공격(볼류메트릭·SYN flood)은 패킷 헤더만으로 판별 가능해 인프라 수준에서 자동화하기 수월하고, AWS 네트워크 전체에 공통 방어를 적용하는 비용이 낮습니다.
> L7 DDoS는 정상 HTTP 요청처럼 보이는 트래픽을 구별해야 해 요청 내용 분석이 필요하고, 오탐 시 합법적 트래픽을 차단하는 위험이 있어 SRT의 사람 개입이 함께 설계됩니다.
> 이 비용 구조 차이가 기본 무료 Standard(L3/L4)와 유료 Advanced(L7 + SRT)의 경계를 만듭니다.

### 3) AWS Firewall Manager {#firewall-manager}

> 공식 정의: **"여러 계정과 리소스에 걸쳐 WAF·Shield Advanced·보안 그룹 등 보호 정책을 중앙에서 관리하는 서비스."**

- AWS Organizations와 통합 — 조직 전체에 WAF 웹 ACL 정책을 일괄 배포합니다.
- 새로 추가된 계정·리소스에도 자동으로 정책이 적용됩니다.
- Shield Advanced 구독, VPC 보안 그룹, AWS Network Firewall, Route 53 Resolver DNS Firewall도 관리합니다.

> **3-계층 조합**: WAF(L7 요청 필터) + Shield(DDoS 완화) + Firewall Manager(다계정 정책 중앙화) — 세 서비스는 함께 쓰도록 설계됩니다.

> 🧠 원리: 왜 Firewall Manager는 Organizations와 통합해 새 계정에 자동으로 정책을 적용할까요?
> 다계정 환경에서 각 계정 담당자가 WAF 웹 ACL을 수동으로 설정하면, 신규 계정 생성 직후 정책이 적용되기 전 짧은 공백 기간이 생깁니다.
> Firewall Manager는 Organizations의 계정 생성 이벤트를 감지해 정책을 자동 배포하므로, 이 공백 없이 모든 계정이 출발점부터 동일한 보호 기준을 갖습니다.
> 이 "태어나는 순간부터 적용" 모델은 SCP가 새 계정에 즉시 상속되는 방식과 같은 철학으로, 예외 계정 없이 일관성을 강제합니다.

### 4) Amazon Cognito — 앱 사용자 인증·권한부여 {#cognito}

> 공식 정의: **"웹·모바일 앱을 위한 아이덴티티 플랫폼 — 사용자 디렉터리, 인증 서버, OAuth 2.0 및 AWS 자격증명 권한부여 서비스."**

Cognito는 두 개의 독립적인 컴포넌트로 구성됩니다.

**User Pool (사용자 풀) — 인증(Authentication):**

- 사용자 가입·로그인·디렉터리 관리
- 로컬 사용자 또는 소셜(Google·Facebook·Apple·Amazon)·엔터프라이즈(SAML·OIDC) IdP 페더레이션 지원
- 인증 성공 시 **JWT(ID 토큰·액세스 토큰·리프레시 토큰)** 발급
- **MFA·기능 플랜**: 사용자 풀은 **Lite · Essentials · Plus** 세 기능 플랜 중 하나를 고르고(신규 풀 기본값 **Essentials**), 플랜이 쓸 수 있는 기능을 가릅니다. **인증 앱(TOTP)·SMS MFA는 Lite부터** 가능하지만 **이메일 OTP MFA·패스키(FIDO2)·패스워드리스 로그인은 Essentials 이상**, **위험 기반 보호(위험 비밀번호·악성 로그인 탐지·사용자 활동 로그)는 Plus**입니다
- AWS WAF 웹 ACL을 User Pool에 직접 연결 가능

**Identity Pool (자격 증명 풀) — AWS 권한부여(Authorization):**

- 인증된 사용자(또는 게스트)에게 **임시 AWS 자격증명(STS 토큰)** 발급
- User Pool JWT, SAML, OIDC, 소셜 IdP 토큰을 입력으로 받아 AWS STS를 통해 IAM 역할 기반 임시 자격증명 반환
- 역할 기반 접근 제어(RBAC)와 속성 기반 접근 제어(ABAC) 모두 지원

**User Pool + Identity Pool 연동 흐름:**

```
1. 앱 사용자 → User Pool 로그인 → JWT 수신
2. 앱 → Identity Pool에 JWT 제출 → STS 임시 자격증명 수신
3. 앱 → 임시 자격증명으로 S3·DynamoDB 등 AWS 리소스 직접 접근
```

**User Pool vs Identity Pool 비교 (★ 시험 핵심):**

| 구분 | User Pool | Identity Pool |
|---|---|---|
| **역할** | 인증(Authentication) | AWS 권한부여(Authorization) |
| **출력** | JWT (ID·액세스·리프레시 토큰) | AWS 임시 자격증명 (STS) |
| **사용 시점** | 앱 로그인·사용자 관리 | AWS 리소스 직접 접근 |
| **단독 사용** | 가능 (API 인증 등) | 가능 (게스트 접근 등) |
| **페더레이션 입력** | 소셜·SAML·OIDC IdP | User Pool JWT, SAML, OIDC, 소셜 |

> 🧠 원리: 왜 Cognito는 인증(User Pool)과 AWS 권한부여(Identity Pool)를 하나의 서비스가 아닌 두 컴포넌트로 분리할까요?
> User Pool은 앱 전용 아이덴티티 레이어로, JWT를 소비하는 쪽이 AWS 서비스일 수도 있고 자체 API 서버일 수도 있습니다 — AWS에 종속되지 않는 범용 인증이 목표입니다.
> Identity Pool은 AWS STS 호출권을 위임하는 레이어로, 입력으로 User Pool JWT 외에 SAML·소셜 토큰을 직접 받을 수 있어 User Pool을 거치지 않는 경로도 지원합니다.
> 두 레이어를 분리하면 인증 소스를 바꿔도(예: 자체 SAML IdP → Cognito User Pool) AWS 권한부여 설정을 그대로 유지할 수 있어 변경 범위가 최소화됩니다.

### 5) AWS Secrets Manager — 비밀 저장·자동 교체 {#secrets-manager}

> 공식 정의: **"데이터베이스 자격증명, API 키, OAuth 토큰 등 비밀(secret)을 수명 주기 전반에 걸쳐 관리·조회·교체하는 서비스."**

**핵심 기능:**

- 코드에 하드코딩된 자격증명 제거 — 런타임에 Secrets Manager API를 호출해 동적으로 조회
- **자동 교체(Automatic Rotation)**: Lambda 함수를 사용해 일정에 따라 비밀을 자동 교체. RDS, Redshift, DocumentDB 등 내장 연동 지원
- KMS로 비밀 암호화 (AWS 관리형 키 무료, 고객 관리형 키는 KMS 요금 발생)
- CloudTrail로 모든 API 호출 감사

**Secrets Manager vs Systems Manager Parameter Store (★ 시험 단골 비교):**

| 구분 | Secrets Manager | SSM Parameter Store |
|---|---|---|
| **주요 용도** | DB 비밀번호·API 키 등 민감한 비밀 | 애플리케이션 설정값·비밀값 |
| **자동 교체** | 지원 (내장 Lambda 연동, RDS 등 네이티브 지원) | 기본 없음 (직접 구현 필요) |
| **비용** | 유료 (비밀당 월 요금 + API 호출 요금) | 표준 티어 무료 / 고급 티어 유료 |
| **암호화** | 항상 KMS 암호화 | SecureString 타입으로 선택 암호화 |
| **크기 제한** | 비밀당 최대 65,536 bytes | 표준 4KB / 고급 8KB |
| **선택 기준** | 자동 교체가 필요한 비밀 | 단순 설정값·저비용 저장 |

> **결정 원칙**: "DB 비밀번호를 정기적으로 자동 교체해야 한다" → Secrets Manager. "앱 설정값이나 교체 불필요한 값을 저렴하게 저장한다" → Parameter Store.

> 🧠 원리: 왜 Secrets Manager는 비밀 교체에 Lambda 함수를 중간에 두는 구조를 채택했을까요?
> RDS·Redshift·DocumentDB 교체는 단순히 값을 바꾸는 것이 아니라 "Secrets Manager에 신규 버전 임시 저장(AWSPENDING) → DB에 새 비밀번호 적용(setSecret) → 연결 테스트(testSecret) → 신규 버전을 AWSCURRENT로 확정(finishSecret)" 네 단계를 순서대로 수행해야 합니다.
> Lambda는 이 교체 로직을 코드로 캡슐화해 서비스마다 다른 교체 절차를 플러그인 방식으로 교체할 수 있게 합니다 — AWS는 주요 DB에 내장 Lambda 함수를 제공하고, 커스텀 서비스는 직접 Lambda를 작성합니다.
> 이 구조 덕분에 교체 실패 시 롤백 논리도 Lambda 안에서 처리되어, 교체 도중 서비스 중단 없이 이전 버전과 신규 버전을 동시에 유지하는 이중 버전 전략이 가능합니다.

### 6) 계층별 방어 — 엣지 보안 아키텍처 {#layered-defense}

AWS 보안은 "가능한 한 엣지에서 먼저 차단"하는 계층 방어 원칙을 따릅니다.

```
인터넷 사용자
    ↓
[엣지 계층] Amazon Route 53 + AWS Shield Standard (DDoS, L3/L4 자동)
    ↓
[CDN/엣지] Amazon CloudFront + AWS WAF (L7 요청 필터링) + Shield Advanced (L7 DDoS)
    ↓
[로드밸런서] Application Load Balancer + AWS WAF
    ↓
[앱 계층] EC2·ECS·Lambda — Secrets Manager로 자격증명 조회
    ↓
[데이터 계층] RDS·DynamoDB — KMS 암호화 저장
```

**엣지 보안 조합 원칙:**

| 위협 유형 | 방어 서비스 |
|---|---|
| DDoS (L3/L4) | Shield Standard (무료, 자동) |
| DDoS (L7) — 고규모 | Shield Advanced (유료) |
| SQL injection·XSS | WAF 관리형 규칙 그룹 |
| 봇·브루트포스 | WAF Rate-based 규칙 |
| 특정 IP·국가 차단 | WAF IP 세트·Geo 규칙 |
| 앱 사용자 로그인 | Cognito User Pool |
| AWS 리소스 임시 접근 | Cognito Identity Pool + STS |
| DB 자격증명 관리·교체 | Secrets Manager |

> 🧠 원리: 왜 WAF를 ALB가 아닌 CloudFront에 먼저 연결하는 것이 유리할까요?
> CloudFront는 전 세계 엣지 로케이션에서 동작하므로, WAF 규칙이 오리진 리전이 아닌 사용자와 가장 가까운 엣지에서 평가됩니다.
> 악성 요청이 엣지에서 차단되면 오리진 ALB·EC2까지 트래픽이 도달하지 않아 오리진 리소스 소비와 ALB 데이터 처리 비용이 줄어듭니다.
> 또한 CloudFront의 지역(Geo) 차단과 WAF 규칙을 조합하면 특정 국가 트래픽을 오리진에 접근시키기 전에 글로벌 단계에서 필터링할 수 있습니다.

### 7) 위협 탐지와 조사 — GuardDuty·Detective {#threat-detection}

WAF·Shield가 **막는** 서비스라면, 이 둘은 **알아차리고 파헤치는** 서비스입니다. 공식 시험 가이드가 Task 1.2의 보안 서비스 예시로 GuardDuty를 직접 들기 때문에 역할 구분이 그대로 출제됩니다.

| 서비스 | 하는 일 | 보는 것 |
|---|---|---|
| **Amazon GuardDuty** | 위협 **탐지** — 계정·워크로드를 지속 감시해 의심스러운 활동을 결과(finding)로 올립니다 | 기본 데이터원 = **CloudTrail 관리 이벤트 · VPC 흐름 로그 · DNS 로그**. 그 밖은 보호 플랜을 **골라 켜는** 방식(S3·EKS·런타임·악성코드·RDS·Lambda 등)이고 언제든 끌 수 있습니다 |
| **Amazon Detective** | 근본 원인 **조사** — 올라온 결과나 의심 활동이 어디서 비롯됐는지 분석합니다 | CloudTrail·VPC 흐름 로그를 모아 동작 그래프를 만들고 **GuardDuty 결과도 가져옵니다** |

- **탐지와 조사는 다른 단계입니다.** "이상 징후를 알려 달라"는 GuardDuty, "왜 이렇게 됐는지 파헤쳐 달라"는 Detective입니다. 시험에서 Detective를 탐지 서비스로 고르거나 GuardDuty를 조사 도구로 고르면 오답입니다.
- ⚠️ **GuardDuty는 방어 서비스가 아닙니다.** 로그를 분석해 결과를 올릴 뿐이라 트래픽을 끊거나 DDoS를 완화하지 않습니다 — 그 몫은 Shield(DDoS)와 WAF(L7 요청 필터)입니다.
- GuardDuty를 처음 켜면 런타임 모니터링을 뺀 보호 플랜이 자동으로 함께 켜집니다. "기본 데이터원"과 "보호 플랜"은 별개의 층이라는 점이 구분 포인트입니다.

> 🧠 원리: 왜 위협 탐지와 근본 원인 조사를 **별개 서비스**로 나눠 놓았을까요?
> 탐지는 "지금 이상한 일이 벌어지는가"를 빨리 판단하는 일이라, 계정에 상시 흘러드는 기본 데이터원(CloudTrail 관리 이벤트·흐름 로그·DNS 로그)을 끊임없이 분석하는 구조가 맞습니다.
> 조사는 "어떻게 여기까지 왔는가"를 과거로 거슬러 보는 일이라, 같은 로그를 **주체·리소스·시간으로 연결한 그래프**로 쌓아 두어야 하고 그 보관·연결 비용은 탐지와 성격이 다릅니다.
> 두 일을 한 서비스로 묶으면 모든 계정이 조사용 그래프 비용까지 늘 부담하게 되므로, 탐지는 켜 두고 조사는 필요할 때 붙이는 구조로 갈렸습니다.

### 8) 애플리케이션 구성 보안 — IMDSv2·Session Manager {#config-security}

자격증명을 Secrets Manager에 넣는 것만으로 끝이 아닙니다. **인스턴스가 자격증명을 내주는 경로**와 **사람이 인스턴스에 들어가는 경로**도 함께 닫아야 합니다.

**IMDSv2 강제 — 인스턴스 메타데이터**

EC2 인스턴스는 메타데이터 서비스(IMDS)로 자기에게 붙은 IAM 역할의 임시 자격증명을 내줍니다. IMDSv1은 단순 요청만으로 그 자격증명을 돌려주기 때문에, 앱의 요청 위조 취약점이 그대로 자격증명 탈취로 이어질 수 있습니다.

| 설정 | 동작 |
|---|---|
| `HttpTokens` = **required** | IMDSv2가 강제됩니다. 메타데이터 조회 요청에 **세션 토큰을 보내야** 하고, IAM 역할 자격증명은 항상 IMDSv2로만 나옵니다 — **IMDSv1 자격증명은 제공되지 않습니다** |
| `HttpTokens` = optional | 세션 토큰을 보낼지 선택할 수 있습니다. 토큰 없이 조회하면 **IMDSv1 자격증명이 돌아옵니다** |

- 적용 수단: 새로 띄울 때는 `run-instances --metadata-options HttpTokens=required`, 이미 뜬 인스턴스는 `modify-instance-metadata-options --http-tokens required`.
- `HttpPutResponseHopLimit`은 메타데이터 요청이 **몇 홉까지 갈 수 있는지**를 정합니다. 숫자가 클수록 더 멀리 가므로, 컨테이너가 호스트 메타데이터에 닿는 것을 막으려면 작게 둡니다.

**Session Manager — 접속 경로 자체를 없앤다**

AWS Systems Manager의 Session Manager로 접속하면 **인바운드 포트를 열거나 배스천 호스트를 유지하거나 SSH 키를 관리할 필요가 없습니다.** 노드 접근 권한을 SSH 키가 아니라 **IAM 정책**으로 주기 때문에, 누가 어떤 노드에 들어갈 수 있는지를 중앙에서 통제합니다.

- 세션 기록을 **CloudWatch Logs 로그 그룹**이나 **S3 버킷**으로 보낼 수 있어 감사 추적이 남습니다. ⚠️ 단 **포트 포워딩이나 SSH로 연결한 세션은 로깅되지 않습니다** — "모든 접속이 기록된다"고 단정하면 틀립니다.
- 시험에서 "프라이빗 서브넷 인스턴스에 SSH 포트를 열지 않고 접속" 요구가 나오면 배스천·VPN보다 Session Manager가 먼저입니다.

> 🧠 원리: 왜 IMDSv2는 **세션 토큰을 먼저 받아 헤더에 싣는** 절차를 끼워 넣었을까요?
> IMDSv1은 단순 GET 한 번으로 역할 자격증명을 돌려주기 때문에, 앱이 외부에서 받은 주소를 그대로 가져오게 만드는 요청 위조 취약점이 그대로 자격증명 유출로 이어집니다.
> IMDSv2는 먼저 PUT으로 토큰을 받아 그 값을 요청 헤더에 넣어야 하므로, "주소 하나를 대신 GET하게 만드는" 공격 경로로는 토큰 발급 단계를 넘지 못합니다.
> 같은 맥락에서 홉 한도를 함께 줄여 두면 컨테이너처럼 한 단계 떨어진 곳에서 온 요청이 호스트의 메타데이터에 닿지 못하게 막을 수 있습니다.

---

## ✍️ 시험 포인트

- **WAF vs Shield 역할 구분**: WAF는 L7 HTTP/HTTPS 요청 내용 필터링(SQL injection·XSS·rate limit). Shield는 DDoS(L3/L4/L7) 대용량 공격 방어. WAF는 Shield 없이도 동작하고 반대도 마찬가지이지만, 함께 쓰면 보완됩니다.
- **Shield Standard는 무료·자동**: 모든 AWS 고객에게 자동 적용. 추가 설정 불필요. Advanced는 별도 유료 구독.
- **SRT(Shield Response Team)**: Shield Advanced 구독자가 쓰는 24/7 전담 DDoS 지원이지만, **연락·에스컬레이션에는 Business 또는 Enterprise Support 플랜이 따로 필요**합니다. 응답 시간도 Support 플랜에 따라 다릅니다.
- **Cognito User Pool = JWT 발급(인증)**: 앱 로그인 처리. Cognito Identity Pool = AWS STS 임시 자격증명 발급(AWS 권한부여). 둘을 혼동하면 오답.
- **Secrets Manager = 자동 교체(rotation)**: 시험에서 "DB 비밀번호 자동 교체"가 요구사항이면 Secrets Manager가 정답. Parameter Store는 기본 자동 교체 없음.
- **Firewall Manager = 다계정 정책 중앙화**: Organizations 기반으로 여러 계정에 WAF·Shield 정책을 일괄 배포.
- **CloudFront + WAF**: CloudFront 배포에 WAF를 연결하면 요청이 오리진에 도달하기 전 엣지에서 필터링됩니다. 단 **웹 ACL 자체는 스코프 `CLOUDFRONT`로 `us-east-1`에서 만들어야** 합니다(ALB·API Gateway 등은 스코프 `REGIONAL`로 리소스와 같은 리전). "리전 제한이 없다"는 보기는 오답입니다.

---

## ⚠️ 흔한 함정 {#common-pitfalls}

1. **"Shield가 SQL injection을 막는다."** → 틀립니다. SQL injection은 L7 HTTP 요청 내용 문제이므로 **WAF**가 담당합니다. Shield는 DDoS(대용량 트래픽 공격) 전용입니다.
   (원리: §1 — WAF는 요청 내용(페이로드·헤더)을 파싱해 패턴 매칭하는 L7 필터이고, Shield는 트래픽 볼륨·프로토콜 이상을 감지하는 다른 축의 방어다.)

2. **"WAF가 DDoS를 막는다."** → 부분적으로만 맞습니다. WAF의 Rate-based 규칙으로 L7 요청 폭주를 어느 정도 제한할 수 있지만, L3/L4 DDoS 완화는 **Shield**가 담당합니다. 시험에서 "DDoS 방어"는 Shield를 고르세요.
   (원리: §2 — L3/L4 공격은 HTTP 요청으로 표현되지 않아 WAF 규칙으로 파싱 자체가 불가하고, 이 계층 완화는 Shield가 인프라 수준에서 처리한다.)

3. **"Cognito User Pool이 AWS 리소스 접근 권한을 준다."** → 틀립니다. User Pool은 앱 인증(JWT 발급)만 담당합니다. AWS 리소스(S3·DynamoDB 등) 접근을 위한 임시 자격증명은 **Identity Pool**이 발급합니다.
   (원리: §4 — 인증(누구인가)과 AWS 권한부여(무엇을 할 수 있는가)를 분리한 설계로, JWT는 앱 레이어 신원 증명이고 STS 토큰이 AWS API 호출 권한을 담당한다.)

4. **"Secrets Manager와 Parameter Store는 기능이 같다."** → 핵심 차이는 **자동 교체** 지원 여부와 **비용**입니다. 자동 교체가 필요하면 Secrets Manager, 단순 저장·저비용이면 Parameter Store입니다.
   (원리: §5 — Secrets Manager의 Lambda 기반 교체 메커니즘은 DB 측 비밀번호 변경까지 포함하는 복합 절차이며, Parameter Store는 단순 키-값 저장소로 이 흐름을 내장하지 않는다.)

5. **"Firewall Manager 없이도 다계정에 WAF를 적용할 수 있다."** → 기술적으로 가능하지만 각 계정마다 수동 설정이 필요합니다. Organizations 환경에서 새 계정·리소스에 자동 정책 적용이 필요하면 **Firewall Manager**가 정답입니다.
   (원리: §3 — Firewall Manager의 핵심 가치는 신규 계정 생성 시 보호 공백 없이 즉시 정책을 적용하는 자동화이며, 수동 적용 방식은 이 공백을 제거하지 못한다.)

6. **"Shield Advanced는 EC2에 직접 연결된다."** → Shield Advanced는 EC2(Elastic IP), ELB, CloudFront, Route 53, Global Accelerator를 보호합니다. EC2 인스턴스 자체보다는 그 앞단의 로드밸런서·EIP 단위로 적용됩니다.
   (원리: §2 — DDoS 완화는 트래픽이 인스턴스에 도달하기 전 네트워크 진입점(EIP·ELB)에서 흡수·필터링해야 하므로, 인스턴스 내부가 아닌 그 앞단 리소스에 보호를 붙이는 구조다.)

---

## 🧪 자가 점검

> 아래는 학습용 자가 점검입니다. (정식 검증 문항은 별도 문항 파일 참조)

**Q1.** 웹 애플리케이션에 SQL injection 및 XSS 공격이 탐지됩니다. 어떤 서비스를 적용해야 하나요?

<details><summary>정답 보기</summary>

**AWS WAF**를 적용합니다. WAF 웹 ACL에 SQL injection 탐지 규칙과 XSS 탐지 규칙을 추가하거나, AWS 관리형 규칙 그룹(AWSManagedRulesCommonRuleSet 등)을 사용하면 됩니다. CloudFront 배포 또는 ALB에 웹 ACL을 연결하면 요청이 오리진에 도달하기 전에 엣지·로드밸런서 단계에서 차단됩니다. Shield는 DDoS 방어 서비스이므로 SQL injection·XSS와는 무관합니다.
</details>

**Q2.** 모바일 앱에서 Google 계정으로 로그인한 사용자가 S3 버킷에 직접 파일을 업로드해야 합니다. 어떻게 설계하나요?

<details><summary>정답 보기</summary>

**Cognito User Pool + Identity Pool** 조합을 사용합니다. User Pool에 Google을 소셜 IdP로 연동해 사용자 인증을 처리하고 JWT를 발급합니다. 앱은 이 JWT를 Identity Pool에 제출하고, Identity Pool은 AWS STS를 통해 S3 접근 권한이 있는 IAM 역할의 임시 자격증명을 발급합니다. 앱은 이 임시 자격증명으로 S3에 직접 업로드합니다. EC2 서버를 중개자로 쓰지 않아도 되는 것이 이 패턴의 장점입니다.
</details>

**Q3.** 애플리케이션이 RDS 데이터베이스에 접속할 때 사용하는 비밀번호를 코드에 하드코딩해 왔습니다. 보안 강화를 위해 비밀번호를 자동으로 90일마다 교체하고 싶습니다. 어떤 서비스를 사용하나요?

<details><summary>정답 보기</summary>

**AWS Secrets Manager**를 사용합니다. RDS 자격증명을 Secrets Manager에 저장하고 자동 교체 일정을 90일로 설정하면, Secrets Manager가 Lambda 함수를 통해 RDS 비밀번호를 자동으로 교체하고 최신 값을 안전하게 보관합니다. 애플리케이션은 코드에 비밀번호를 저장하는 대신 런타임에 Secrets Manager API를 호출해 최신 자격증명을 동적으로 조회합니다. Parameter Store는 자동 교체 기능이 없으므로 이 요구사항에는 부적합합니다.
</details>

**Q4.** 대규모 DDoS 공격이 우려됩니다. 24/7 전담 대응팀 지원과 공격 비용으로 인한 요금 급증 보호가 필요합니다. 어떤 서비스를 선택하나요?

<details><summary>정답 보기</summary>

**AWS Shield Advanced**를 구독합니다. Shield Advanced는 Shield Response Team(SRT)의 24/7 전담 DDoS 대응 지원, 고급 이벤트 가시성, DDoS로 인한 요금 급증 시 크레딧 보호를 제공합니다. Shield Standard는 무료이지만 SRT 지원과 요금 보호가 없습니다. 여러 계정에 걸쳐 Shield Advanced를 일괄 배포해야 한다면 AWS Firewall Manager와 함께 사용합니다.
</details>

**Q5 (원리).** 왜 Secrets Manager는 비밀값 교체 시 새 버전을 즉시 덮어쓰지 않고 이전 버전과 신규 버전을 동시에 유지하는 이중 버전 전략을 사용할까요?

<details><summary>정답 보기</summary>

**교체 도중 연결 중단을 방지하기 위해서입니다.** 비밀번호가 교체되면 아직 구 버전 자격증명을 캐싱 중인 앱 인스턴스(예: DB 커넥션 풀)가 재연결 시 인증 실패를 겪을 수 있습니다. Secrets Manager는 교체 완료 후 신규 버전을 AWSCURRENT로 확정하고, 이전 AWSCURRENT는 AWSPREVIOUS 레이블로 보존합니다. 앱이 GetSecretValue()를 호출하면 기본으로 AWSCURRENT를 받지만, AWSPREVIOUS도 명시적으로 조회 가능해 교체 직후 짧은 전환 기간 동안 구 자격증명으로 롤백할 수 있습니다. 다음 교체 시 AWSPREVIOUS는 폐기됩니다.
</details>

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. (작성·대조: 2026-06-07 · 고도화 검수: 2026-06-12)

1. What is AWS WAF? (공식) — https://docs.aws.amazon.com/waf/latest/developerguide/what-is-aws-waf.html
2. How AWS Shield and Shield Advanced work (공식) — https://docs.aws.amazon.com/waf/latest/developerguide/ddos-overview.html
3. What is Amazon Cognito? (공식) — https://docs.aws.amazon.com/cognito/latest/developerguide/what-is-amazon-cognito.html
4. What is AWS Secrets Manager? (공식) — https://docs.aws.amazon.com/secretsmanager/latest/userguide/intro.html
5. 웹 ACL 규칙 액션(Allow·Block 종료 / Count 비종료 / CAPTCHA·Challenge 조건부) — https://docs.aws.amazon.com/waf/latest/developerguide/web-acl-rule-actions.html
6. Rate-based 규칙 상위 설정(평가 창 60·120·300·600초, 기본 300, 한도 최소 10) — https://docs.aws.amazon.com/waf/latest/developerguide/waf-rule-statement-type-rate-based-high-level-settings.html
7. CreateWebACL(보호 대상 리소스 목록 · CLOUDFRONT 스코프는 us-east-1) — https://docs.aws.amazon.com/waf/latest/APIReference/API_CreateWebACL.html
8. Cognito 사용자 풀 기능 플랜(Lite·Essentials·Plus) — https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-sign-in-feature-plans.html
9. SAA-C03 공식 시험 가이드 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
10. AWS WAF Anti-DDoS 관리형 규칙 그룹(가장 상위 Anti-DDoS 보호·**추가 요금**·웹 ACL에 추가해 민감도 구성) — https://docs.aws.amazon.com/waf/latest/developerguide/waf-anti-ddos-advanced.html

11. AWS Shield FAQ(월 $3,000/조직·통합 결제에서 1회·데이터 전송 사용료 별도·**SRT 연락에 Business·Enterprise Support 필요**) — https://aws.amazon.com/shield/faqs/
12. Shield Advanced 도입 판단(표준 WAF 비용 포함 1,500 WCU·자동 L7 완화 규칙 그룹 150 WCU·월 500억 요청) — https://docs.aws.amazon.com/waf/latest/developerguide/ddos-advanced-summary-deciding.html
13. What is Amazon GuardDuty?(위협 탐지·기본 데이터원 3종·보호 플랜은 선택) — https://docs.aws.amazon.com/guardduty/latest/ug/what-is-guardduty.html
14. What is Amazon Detective?(근본 원인 조사·CloudTrail·VPC 흐름 로그·GuardDuty 결과 수집) — https://docs.aws.amazon.com/detective/latest/userguide/what-is-detective.html
15. ModifyInstanceMetadataOptions(HttpTokens required = IMDSv1 자격증명 미제공·홉 한도 의미) — https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_ModifyInstanceMetadataOptions.html
16. AWS Systems Manager Session Manager(포트·배스천·SSH 키 불필요·IAM 정책 통제·세션 로깅과 그 예외) — https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html

> 📝 **2026-10-19 정정**: ① 웹 ACL 평가를 "첫 매칭 액션 실행"에서 **종료/비종료 구분**(Count는 비종료)으로 고쳤습니다(근거 5번). ② Rate-based 평가 창을 **60·120·300·600초**로 정정했습니다(근거 6번). ③ 보호 대상에 **Amplify·Bedrock AgentCore Gateway**를 더하고 **CLOUDFRONT 스코프는 us-east-1** 규칙을 명시했습니다("리전 제한이 없다"는 단정 삭제, 근거 7번). ④ Cognito MFA 한 줄을 **기능 플랜 3종**으로 바꿨습니다(근거 8번).

> 📝 **2026-10-30 보강(갭 배치 B11)**: ① §2에 Shield Advanced의 **요금 구조**(월 $3,000 조직 단위·통합 결제 1회·데이터 전송 사용료, 구독에 포함되는 표준 WAF 범위 1,500 WCU와 자동 L7 완화 150 WCU)를 더하고, **SRT 연락 조건을 정정**했습니다 — 구독만으로 연락이 되는 것처럼 읽히던 서술을 공식 FAQ의 **Business·Enterprise Support 플랜 필요**로 바꿨습니다(근거 11·12번). ② 공식 Task 1.2가 보안 서비스 예시로 드는 **GuardDuty**와 **Detective**를 §7로 신설했습니다(근거 13·14번). ③ **IMDSv2 강제와 Session Manager**를 §8로 신설했습니다(근거 15·16번). ⚠️ **쓰지 않은 것 3가지:** Shield Advanced의 "1년 약정"은 공식 FAQ 전문에 해당 문장이 없어 넣지 않았습니다(갭 노트가 요구하는 항목이지만 근거 미확보 — `99-gaps.md` 규율). Detective의 데이터원으로 **EKS 감사 로그**는 적지 않았습니다 — 공식 소개 페이지에서 그 로그는 Security Lake가 지원하는 목록에만 나오고 Detective 수집원으로는 적히지 않습니다. `HttpPutResponseHopLimit`의 **기본값**도 API 레퍼런스가 수치로 적지 않아 의미만 썼습니다.

> 📝 **2026-10-28 보강(1건, 2차 검수 우선순위 2)**: §1에 **Anti-DDoS 관리형 규칙 그룹**(`AWSManagedRulesAntiDDoSRuleSet`)을 더했습니다 — WAF도 L7 DDoS를 완화하지만 웹 ACL에 추가해야 동작하는 유료 옵트인이고, "추가 설정 없이 자동 적용되는 무료 방어"는 Shield Standard입니다(근거 10번). 파생 문항 `saa-t1-4-q2`의 오답 근거가 WAF의 DDoS 완화 능력을 전면 부정하고 있어 함께 고쳤습니다.
