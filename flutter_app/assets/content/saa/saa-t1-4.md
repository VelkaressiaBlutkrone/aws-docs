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
lastVerified: 2026-06-07
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

## 📖 핵심 개념

### 1) AWS WAF — 웹 애플리케이션 방화벽

> 공식 정의: **"HTTP/HTTPS 요청을 모니터링하고 콘텐츠 접근을 제어하는 웹 애플리케이션 방화벽."** L7(애플리케이션 계층) 트래픽을 조건 기반으로 허용·차단·계수합니다.

**WAF가 보호할 수 있는 리소스 (공식):**

- Amazon CloudFront 배포
- Application Load Balancer (ALB)
- Amazon API Gateway REST API
- AWS AppSync GraphQL API
- Amazon Cognito User Pool
- AWS App Runner 서비스
- AWS Verified Access 인스턴스

**웹 ACL(Web Access Control List):**

웹 ACL은 WAF의 최상위 컨테이너입니다. 하나 이상의 규칙을 순서대로 평가하고, 첫 번째로 매칭된 규칙의 액션(Allow/Block/Count/CAPTCHA)을 실행합니다.

**규칙 유형:**

| 규칙 유형 | 설명 |
|---|---|
| **IP 세트 규칙** | 특정 IP 주소·CIDR 범위 허용 또는 차단 |
| **지역(Geo) 규칙** | 특정 국가에서 오는 요청 필터링 |
| **SQL Injection 탐지** | 요청 내 악성 SQL 코드 패턴 차단 |
| **XSS 탐지** | 크로스사이트 스크립팅 스크립트 패턴 차단 |
| **Rate-based 규칙** | 5분 또는 1분 내 특정 IP의 요청 수 초과 시 차단 (봇·브루트포스 방어) |
| **관리형 규칙 그룹** | AWS 또는 AWS Marketplace 셀러가 제공하는 사전 구성 규칙 세트 |

> **관리형 규칙 그룹**: AWS가 제공하는 `AWSManagedRulesCommonRuleSet` 같은 그룹을 웹 ACL에 추가하면 OWASP Top 10 공격 패턴을 별도 규칙 작성 없이 방어할 수 있습니다.

**WAF 액션:**

```
Allow  → 요청 통과
Block  → HTTP 403 응답 반환
Count  → 통계만 수집 (규칙 테스트 시 활용)
CAPTCHA / Challenge → 봇 여부 검증
```

> 🧠 원리: 왜 WAF 웹 ACL은 모든 규칙을 종합 평가하지 않고 첫 매칭 규칙의 액션을 즉시 실행할까요?
> HTTP 요청은 평균 수십~수백 마이크로초 내에 응답을 반환해야 하므로, 모든 규칙을 다 평가하면 규칙 수 증가에 비례해 지연이 쌓입니다.
> 첫 매칭에서 결정하는 방식은 운영자가 규칙 번호 순서로 우선순위를 명시적으로 제어할 수 있게 하며, 특정 IP를 먼저 허용하거나 먼저 차단하는 예외 처리를 낮은 번호에 배치하는 것만으로 구현할 수 있습니다.
> Allow를 먼저 두면 이후 Deny 규칙을 건너뛰고 통과되므로 화이트리스트 우선 정책을, Deny를 먼저 두면 블랙리스트 우선 정책을 비대칭 규칙 없이 표현할 수 있습니다.

### 2) AWS Shield — DDoS 방어

> 공식 정의: **"L3/L4 및 L7 계층의 분산 서비스 거부(DDoS) 공격으로부터 AWS 리소스를 보호하는 서비스."**

**Shield Standard vs Shield Advanced:**

| 구분 | Shield Standard | Shield Advanced |
|---|---|---|
| **비용** | 무료 (모든 AWS 고객 자동 적용) | 유료 구독 (별도 요금) |
| **보호 계층** | L3/L4 (네트워크·전송) | L3/L4 + L7 (애플리케이션) |
| **자동 완화** | 일반 DDoS 자동 완화 | 애플리케이션 계층 DDoS 자동 완화 포함 |
| **보호 대상** | CloudFront, Route 53, ALB, EC2 등 (기본 범위) | EC2, ELB, CloudFront, Route 53, Global Accelerator |
| **Shield Response Team(SRT)** | 없음 | 전담 DDoS 대응 팀 24/7 지원 |
| **고급 가시성** | 없음 | 상세 이벤트 가시성, CloudWatch 메트릭 |
| **비용 보호** | 없음 | DDoS로 인한 요금 급증 시 크레딧 제공 |

> **핵심 구분**: Shield Standard는 L3/L4 수준의 기본 DDoS 자동 방어를 무료로 제공합니다. Shield Advanced는 L7 자동 완화, SRT 전담 지원, 이벤트 리포트가 추가됩니다. 고트래픽·고가시성 사이트에 적합합니다.

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

### 3) AWS Firewall Manager

> 공식 정의: **"여러 계정과 리소스에 걸쳐 WAF·Shield Advanced·보안 그룹 등 보호 정책을 중앙에서 관리하는 서비스."**

- AWS Organizations와 통합 — 조직 전체에 WAF 웹 ACL 정책을 일괄 배포합니다.
- 새로 추가된 계정·리소스에도 자동으로 정책이 적용됩니다.
- Shield Advanced 구독, VPC 보안 그룹, AWS Network Firewall, Route 53 Resolver DNS Firewall도 관리합니다.

> **3-계층 조합**: WAF(L7 요청 필터) + Shield(DDoS 완화) + Firewall Manager(다계정 정책 중앙화) — 세 서비스는 함께 쓰도록 설계됩니다.

> 🧠 원리: 왜 Firewall Manager는 Organizations와 통합해 새 계정에 자동으로 정책을 적용할까요?
> 다계정 환경에서 각 계정 담당자가 WAF 웹 ACL을 수동으로 설정하면, 신규 계정 생성 직후 정책이 적용되기 전 짧은 공백 기간이 생깁니다.
> Firewall Manager는 Organizations의 계정 생성 이벤트를 감지해 정책을 자동 배포하므로, 이 공백 없이 모든 계정이 출발점부터 동일한 보호 기준을 갖습니다.
> 이 "태어나는 순간부터 적용" 모델은 SCP가 새 계정에 즉시 상속되는 방식과 같은 철학으로, 예외 계정 없이 일관성을 강제합니다.

### 4) Amazon Cognito — 앱 사용자 인증·권한부여

> 공식 정의: **"웹·모바일 앱을 위한 아이덴티티 플랫폼 — 사용자 디렉터리, 인증 서버, OAuth 2.0 및 AWS 자격증명 권한부여 서비스."**

Cognito는 두 개의 독립적인 컴포넌트로 구성됩니다.

**User Pool (사용자 풀) — 인증(Authentication):**

- 사용자 가입·로그인·디렉터리 관리
- 로컬 사용자 또는 소셜(Google·Facebook·Apple·Amazon)·엔터프라이즈(SAML·OIDC) IdP 페더레이션 지원
- 인증 성공 시 **JWT(ID 토큰·액세스 토큰·리프레시 토큰)** 발급
- MFA(TOTP·SMS) 지원
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

### 5) AWS Secrets Manager — 비밀 저장·자동 교체

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
> RDS·Redshift·DocumentDB 교체는 단순히 값을 바꾸는 것이 아니라 "새 비밀번호로 DB에 SET PASSWORD → 연결 테스트 → Secrets Manager에 저장" 세 단계를 원자적으로 수행해야 합니다.
> Lambda는 이 교체 로직을 코드로 캡슐화해 서비스마다 다른 교체 절차를 플러그인 방식으로 교체할 수 있게 합니다 — AWS는 주요 DB에 내장 Lambda 함수를 제공하고, 커스텀 서비스는 직접 Lambda를 작성합니다.
> 이 구조 덕분에 교체 실패 시 롤백 논리도 Lambda 안에서 처리되어, 교체 도중 서비스 중단 없이 이전 버전과 신규 버전을 동시에 유지하는 이중 버전 전략이 가능합니다.

### 6) 계층별 방어 — 엣지 보안 아키텍처

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

---

## ✍️ 시험 포인트

- **WAF vs Shield 역할 구분**: WAF는 L7 HTTP/HTTPS 요청 내용 필터링(SQL injection·XSS·rate limit). Shield는 DDoS(L3/L4/L7) 대용량 공격 방어. WAF는 Shield 없이도 동작하고 반대도 마찬가지이지만, 함께 쓰면 보완됩니다.
- **Shield Standard는 무료·자동**: 모든 AWS 고객에게 자동 적용. 추가 설정 불필요. Advanced는 별도 유료 구독.
- **SRT(Shield Response Team)**: Shield Advanced 가입 시에만 이용 가능. DDoS 공격 중 24/7 전담 지원.
- **Cognito User Pool = JWT 발급(인증)**: 앱 로그인 처리. Cognito Identity Pool = AWS STS 임시 자격증명 발급(AWS 권한부여). 둘을 혼동하면 오답.
- **Secrets Manager = 자동 교체(rotation)**: 시험에서 "DB 비밀번호 자동 교체"가 요구사항이면 Secrets Manager가 정답. Parameter Store는 기본 자동 교체 없음.
- **Firewall Manager = 다계정 정책 중앙화**: Organizations 기반으로 여러 계정에 WAF·Shield 정책을 일괄 배포.
- **CloudFront + WAF**: CloudFront 배포에 WAF를 연결하면 요청이 오리진에 도달하기 전 엣지에서 필터링됩니다. us-east-1 제한 없음(WAF는 글로벌 CloudFront에 그대로 연결).

---

## ⚠️ 흔한 함정

1. **"Shield가 SQL injection을 막는다."** → 틀립니다. SQL injection은 L7 HTTP 요청 내용 문제이므로 **WAF**가 담당합니다. Shield는 DDoS(대용량 트래픽 공격) 전용입니다.
   *(원리: §1 — WAF는 요청 내용(페이로드·헤더)을 파싱해 패턴 매칭하는 L7 필터이고, Shield는 트래픽 볼륨·프로토콜 이상을 감지하는 다른 축의 방어다.)*

2. **"WAF가 DDoS를 막는다."** → 부분적으로만 맞습니다. WAF의 Rate-based 규칙으로 L7 요청 폭주를 어느 정도 제한할 수 있지만, L3/L4 DDoS 완화는 **Shield**가 담당합니다. 시험에서 "DDoS 방어"는 Shield를 고르세요.
   *(원리: §2 — L3/L4 공격은 HTTP 요청으로 표현되지 않아 WAF 규칙으로 파싱 자체가 불가하고, 이 계층 완화는 Shield가 인프라 수준에서 처리한다.)*

3. **"Cognito User Pool이 AWS 리소스 접근 권한을 준다."** → 틀립니다. User Pool은 앱 인증(JWT 발급)만 담당합니다. AWS 리소스(S3·DynamoDB 등) 접근을 위한 임시 자격증명은 **Identity Pool**이 발급합니다.
   *(원리: §4 — 인증(누구인가)과 AWS 권한부여(무엇을 할 수 있는가)를 분리한 설계로, JWT는 앱 레이어 신원 증명이고 STS 토큰이 AWS API 호출 권한을 담당한다.)*

4. **"Secrets Manager와 Parameter Store는 기능이 같다."** → 핵심 차이는 **자동 교체** 지원 여부와 **비용**입니다. 자동 교체가 필요하면 Secrets Manager, 단순 저장·저비용이면 Parameter Store입니다.
   *(원리: §5 — Secrets Manager의 Lambda 기반 교체 메커니즘은 DB 측 비밀번호 변경까지 포함하는 복합 절차이며, Parameter Store는 단순 키-값 저장소로 이 흐름을 내장하지 않는다.)*

5. **"Firewall Manager 없이도 다계정에 WAF를 적용할 수 있다."** → 기술적으로 가능하지만 각 계정마다 수동 설정이 필요합니다. Organizations 환경에서 새 계정·리소스에 자동 정책 적용이 필요하면 **Firewall Manager**가 정답입니다.
   *(원리: §3 — Firewall Manager의 핵심 가치는 신규 계정 생성 시 보호 공백 없이 즉시 정책을 적용하는 자동화이며, 수동 적용 방식은 이 공백을 제거하지 못한다.)*

6. **"Shield Advanced는 EC2에 직접 연결된다."** → Shield Advanced는 EC2(Elastic IP), ELB, CloudFront, Route 53, Global Accelerator를 보호합니다. EC2 인스턴스 자체보다는 그 앞단의 로드밸런서·EIP 단위로 적용됩니다.
   *(원리: §2 — DDoS 완화는 트래픽이 인스턴스에 도달하기 전 네트워크 진입점(EIP·ELB)에서 흡수·필터링해야 하므로, 인스턴스 내부가 아닌 그 앞단 리소스에 보호를 붙이는 구조다.)*

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

**교체 도중 연결 중단을 방지하기 위해서입니다.** 비밀번호가 교체되는 순간 이미 구 버전 자격증명으로 연결 중인 앱 인스턴스(예: DB 커넥션 풀)는 즉시 인증 실패가 발생합니다. Secrets Manager는 교체 과정에서 구 버전(AWSPREVIOUS)과 신규 버전(AWSCURRENT)을 동시에 활성 상태로 유지해, 앱이 다음 자격증명 조회 시 자연스럽게 신규 버전으로 이행할 수 있는 전환 기간을 만듭니다. 이 전략 덕분에 교체가 무중단(zero-downtime)으로 진행됩니다. 교체가 완료되면 구 버전은 AWSPREVIOUS 레이블로 남아 롤백 경로가 되고, 다음 교체 시 폐기됩니다.
</details>

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. (작성·대조: 2026-06-07)

1. What is AWS WAF? (공식) — https://docs.aws.amazon.com/waf/latest/developerguide/what-is-aws-waf.html
2. How AWS Shield and Shield Advanced work (공식) — https://docs.aws.amazon.com/waf/latest/developerguide/ddos-overview.html
3. What is Amazon Cognito? (공식) — https://docs.aws.amazon.com/cognito/latest/developerguide/what-is-amazon-cognito.html
4. What is AWS Secrets Manager? (공식) — https://docs.aws.amazon.com/secretsmanager/latest/userguide/intro.html
5. SAA-C03 공식 시험 가이드 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
