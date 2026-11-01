---
examGuideTaskId: dva-t2-1
certCode: DVA-C03
domain: 2
domainName: 보안
domainWeightPct: 26
title: 인증·권한 부여 메커니즘 구현 (Cognito·토큰·사전 서명 URL·SigV4·IAM 역할)
coversTasks:
  - "2.1"
sources:
  - title: What is Amazon Cognito?
    url: https://docs.aws.amazon.com/cognito/latest/developerguide/what-is-amazon-cognito.html
  - title: Understanding user pool JSON web tokens (JWTs)
    url: https://docs.aws.amazon.com/cognito/latest/developerguide/amazon-cognito-user-pools-using-tokens-with-identity-providers.html
  - title: Identity providers and federation into AWS (IAM)
    url: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers.html
  - title: Download and upload objects with presigned URLs (Amazon S3)
    url: https://docs.aws.amazon.com/AmazonS3/latest/userguide/using-presigned-url.html
  - title: Specifying the signers that can create signed URLs and signed cookies (CloudFront)
    url: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-trusted-signers.html
  - title: AWS Signature Version 4 for API requests
    url: https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_sigv.html
  - title: Policy evaluation logic (IAM)
    url: https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_evaluation-logic.html
  - title: AssumeRole (AWS STS API Reference)
    url: https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRole.html
  - title: DVA-C03 공식 시험 가이드 · 콘텐츠 도메인 2 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/developer-associate-03/developer-associate-03-domain2.html
lastVerified: 2026-11-01
---

# 인증·권한 부여 메커니즘 구현 (Cognito·토큰·사전 서명 URL·SigV4·IAM 역할)

> **커버하는 공식 Task** — DVA-C03 · 도메인 2 「보안」(26%) · **작업 2.1 애플리케이션과 AWS 서비스에 대한 인증 및 권한 부여 메커니즘을 구현합니다** (`dva-t2-1`)
> 이 문서는 위 한 작업에 1:1로 매핑되고, 공식 기술 일곱 개(2.1.1~2.1.7)를 모두 덮습니다.

> ⚠️ **C03에서 기술 2.1.4가 신설됐습니다** — **사전 서명 URL로 시간 제한이 있는 안전한 액세스**(S3·CloudFront). 그리고 번호가 밀렸습니다: C02의 "인증된 호출"은 **2.1.5**, "역할 수임"은 **2.1.7**입니다. C02 교재의 번호를 그대로 쓰면 어긋납니다.
>
> ⚠️ **IAM 사용자·그룹 관리는 시험 범위 밖**입니다(가이드 "범위에 해당하지 않는 작업"). 사람 사용자는 **IdP 페더레이션**이 권장되는 방향입니다.

---

## ✅ 학습 목표 체크리스트

- [ ] Cognito 사용자 풀과 자격 증명 풀이 **각각 답하는 질문**과 결과물을 가른다
- [ ] 외부 IdP 페더레이션 **네 경로**(Identity Center · IAM IdP · 자격 증명 풀 · 사용자 풀 연동)를 고를 수 있다
- [ ] ID·액세스·리프레시 토큰의 **용도와 수명**을 구분하고 JWT 검증 순서를 말한다
- [ ] API Gateway의 접근 제어 수단을 **누가 검증하는가**로 가른다
- [ ] 자격 증명 공급자 체인과 **실행 환경별 자격 증명 출처**를 안다
- [ ] 사전 서명 URL의 **만료가 자격 증명으로 정해진다**는 것과 CloudFront 서명과의 차이를 안다
- [ ] 정책 유형(부여 vs 제한)과 평가 규칙(**명시적 Deny 우선**, 교차 계정은 양쪽 허용)을 설명한다
- [ ] 역할 수임의 수명 규칙과 **역할 체이닝 1시간 상한**을 안다

---

## 🎯 왜 중요한가

보안 도메인은 **26%**이고 그중 이 작업이 기술 수(7개)로 가장 큽니다. 그런데 문항의 모양은 단조롭습니다 — **"누가 무엇으로 신원을 증명하고, 그 신원이 무엇을 할 수 있는가"** 한 축입니다. 그래서 서비스를 외우는 대신 **신원이 자격 증명으로 바뀌는 경로**를 그려 두면 대부분 풀립니다.

가장 자주 틀리는 세 지점도 그 경로에서 나옵니다 — JWT로는 AWS API를 부를 수 없다는 것(중개가 필요합니다), 사전 서명 URL의 만료는 내가 지정한 값이 아니라 **자격 증명이 정한다**는 것, 그리고 교차 계정에서는 **양쪽이 모두 허용**해야 한다는 것입니다.

---

## ⚡ 시험 직전 요약

> 시험 직전에 이 열 줄만 다시 봅니다. 근거와 맥락은 아래 본문에 있습니다.

- **사용자 풀 = 인증**(JWT를 돌려준다) · **자격 증명 풀 = 권한 부여**(STS 임시 자격 증명을 돌려준다). ⚠️ **JWT로는 AWS API에 서명할 수 없어** 중개가 필요합니다
- **토큰 수명**: ID·액세스 **기본 60분**(5분~1일) · 리프레시 **기본 30일**(60분~10년). 리프레시 토큰은 **불투명**이고 폐기 대상입니다
- **JWT 검증 순서**: 구조 → **서명(JWKS의 `kid`)** → `exp` → `iss` → `aud`(ID)·`client_id`(액세스) → `token_use` → 폐기. ⚠️ **폐기는 오프라인으로 알 수 없습니다**
- **사전 서명 URL 만료**: IAM 사용자 키는 **최대 7일**, **임시 자격 증명은 그 자격 증명보다 길 수 없습니다**(역할 세션이 끝나면 URL도 끝남). 콘솔은 **1분~12시간**, CLI·SDK는 최대 7일
- ⚠️ **즉시 무효화하려면 URL을 만든 자격 증명을 취소·비활성화**합니다 — 더 늦은 만료를 지정했어도 그 시점에 죽습니다
- **CloudFront 서명은 메커니즘이 다릅니다** — 서명 재료가 **키 그룹의 개인 키**이고, **서명 URL은 파일 하나 · 서명 쿠키는 경로 아래 다수**이며 **캐시 동작**에 서명자를 붙여 적용합니다
- **SigV4 3단계**: 정규 요청 생성 → 서명 계산 → `Authorization` 헤더. 비밀 키는 **전송하지 않고** 날짜·리전·서비스로 파생한 키로 서명합니다
- **정책 평가**: 기본 암묵적 거부, **명시적 Deny가 모든 Allow를 이깁니다.** 같은 계정은 ID·리소스 정책의 **합집합**, **교차 계정은 양쪽 모두 명시적 허용**
- **STS 수명**: `AssumeRole`은 15분~역할 최대 세션(1~12시간), **기본 1시간**. ⚠️ **역할 체이닝은 1시간 상한**이고 늘릴 수 없습니다
- **세션 정책은 권한을 넓히지 못합니다** — 결과 권한은 역할 정책과의 **교집합**(인라인 1 + 관리형 최대 10, 합계 2,048자)

---

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **사용자 풀** | Cognito의 사용자 디렉터리 + OIDC IdP + OAuth 2.0 인가 서버. 결과물은 **JWT** |
| **자격 증명 풀** | 신뢰된 토큰을 **STS 임시 자격 증명**으로 바꿔 주는 중개자. 게스트 자격도 발급한다 |
| **신뢰 정책** | 역할에 붙는 리소스 기반 정책 — **누가 이 역할을 수임할 수 있는가** |
| **권한 정책** | 역할을 수임한 뒤 **무엇을 할 수 있는가** |
| **세션 정책** | 세션을 만들 때 함께 주는 정책. 역할 권한과의 **교집합**만 남는다(확대 불가) |
| **역할 체이닝** | 역할로 또 다른 역할을 수임하는 것. CLI·API 세션이 **최대 1시간**으로 제한된다 |
| **ABAC** | 주체 태그와 리소스 태그를 맞춰 허용하는 방식. 리소스가 늘어도 정책이 늘지 않는다 |
| **confused deputy** | 권한을 가진 서비스가 제3자에게 속아 대신 행동하는 문제. `aws:SourceArn`·`aws:SourceAccount`·`sts:ExternalId`로 막는다 |

---

## 📖 핵심 개념

### 1) Cognito — 사용자 풀과 자격 증명 풀 (기술 2.1.1) {#cognito}

| 구분 | **사용자 풀** | **자격 증명 풀** |
|---|---|---|
| 답하는 질문 | 이 사용자는 **누구인가**(인증) | 이 사용자가 **어떤 AWS 리소스에** 접근할 수 있나(권한 부여) |
| 정체 | 사용자 디렉터리 + OIDC IdP + OAuth 2.0 인가 서버 | 신뢰된 토큰을 **STS 임시 자격 증명**으로 바꿔 주는 중개자 |
| 결과물 | **JWT**(ID·액세스 토큰) + 리프레시 토큰 | **AWS 임시 자격 증명**(액세스 키·비밀 키·세션 토큰) |
| 입력 | 비밀번호·SRP·패스키, 소셜·SAML·OIDC 로그인 | 사용자 풀 ID 토큰, OIDC ID 토큰, SAML assertion, 소셜 액세스 토큰 |
| 권한 부여 수단 | 스코프, `cognito:groups`, 커스텀 클레임 | **IAM 역할 선택(RBAC)**과 주체 태그(**ABAC**) |
| 이쪽에만 있는 것 | managed login, MFA, 맞춤 인증 흐름, 토큰 커스터마이징, 그룹, WAF 웹 ACL | **게스트(비인증) 자격**, 자격 증명 중개 |

- ⚠️ **두 구성 요소는 서로를 필수로 요구하지 않습니다.** 사용자 풀은 자체 백엔드에 JWT만 발급할 수 있고, 자격 증명 풀은 이미 가진 IdP 토큰만으로 AWS 자격 증명을 중개할 수 있습니다.
- 함께 쓰는 **표준 3단계**: ① 사용자 풀로 로그인해 OAuth 2.0 토큰을 받고 → ② 그 토큰을 자격 증명 풀에 제시해 임시 AWS 자격 증명을 받고 → ③ 앱이 그 자격 증명으로 S3·DynamoDB 요청에 **서명**합니다.
- **자격 증명 풀의 두 흐름**: **Enhanced**(권장)는 `GetId` → `GetCredentialsForIdentity`로 풀이 역할을 고르고 자격 증명은 **1시간**입니다. **Basic**은 `GetId` → `GetOpenIdToken` → `AssumeRoleWithWebIdentity`로 **앱이 역할을 고르고** 세션 기간을 지정할 수 있습니다.
- **역할 매핑 세 가지**: 기본 역할 · 규칙(순서대로 첫 일치, 제공자당 25개) · 토큰(`cognito:preferred_role`·`cognito:roles`). ⚠️ **사용자가 바꿀 수 있는 클레임을 높은 권한 역할에 매핑하면 누구나 그 역할을 얻습니다.**
- **게스트 자격**: ⚠️ **풀 ID는 비밀이 아니므로** 풀 ID를 아는 누구나 게스트 자격을 요청할 수 있습니다. 기본은 비활성이고, 켜면 **최소 권한만** 줍니다.

> 🧠 **원리** — AWS API 요청은 **SigV4 서명**으로 인증 정보를 싣습니다. JWT는 그 서명 재료가 아니므로 **"JWT → STS 자격 증명"으로 바꿔 주는 중개 단계**가 반드시 필요하고, 그 중개자가 자격 증명 풀입니다. "Cognito로 로그인했으니 S3를 부를 수 있다"가 성립하지 않는 이유입니다.

### 2) 외부 IdP 페더레이션 경로 (기술 2.1.1) {#federation}

| 경로 | 주 용도 | 결과 |
|---|---|---|
| **IAM Identity Center** | 여러 계정(Organizations)에 걸친 **직원** 접근 | 단기 자격 증명(CLI SSO 프로필 등) |
| **IAM IdP 엔터티**(SAML·OIDC) | 단일 계정·소규모 사람 사용자·**머신**(예: GitHub Actions) | `AssumeRoleWithSAML` · `AssumeRoleWithWebIdentity` |
| **Cognito 자격 증명 풀** | **앱 사용자**가 IAM 권한이 필요한 경우 | STS 임시 자격 증명 |
| **Cognito 사용자 풀 연동** | 앱이 **하나의 JWT 포맷만** 다루고 싶은 경우 | 풀이 자체 토큰을 발급(앱에는 IdP, 외부 IdP에는 SP) |

- **`AssumeRoleWithWebIdentity`**: ⚠️ **호출에 AWS 자격 증명이 필요 없습니다**(토큰으로 신원을 검증). 기본 1시간이고 **역할 신뢰 정책에 해당 IdP가 명시**돼야 합니다. 모바일 앱에는 Cognito가 권장됩니다.
- **`AssumeRoleWithSAML`**: 역시 AWS 자격 증명이 필요 없고, 세션은 **지정 기간과 SAML 응답의 `SessionNotOnOrAfter` 중 짧은 쪽**입니다. ⚠️ IAM Identity Center가 관리하는 역할(`AWSReservedSSO_`)에는 쓸 수 없습니다.
- IdP가 **세션 태그**(SAML `PrincipalTag`, OIDC 토큰)를 넘기면 ABAC에 쓸 수 있습니다.

> 🧠 **원리** — 외부 신원을 AWS가 믿게 하려면 **먼저 신뢰 관계를 만들고**(IdP 엔터티·신뢰 정책), 토큰·assertion을 STS에 내고 임시 자격 증명을 받습니다. 그래서 앱에 **장기 키를 배포할 필요가 없습니다** — 페더레이션 문항의 정답 방향은 거의 항상 이쪽입니다.

### 3) 토큰과 OAuth 2.0 (기술 2.1.2) {#tokens}

| 토큰 | 목적 | 핵심 클레임 | 기본 만료 / 범위 |
|---|---|---|---|
| **ID** | 사용자 신원·속성 전달, **자격 증명 풀 입력** | `aud`=앱 클라이언트 ID, `iss`, `token_use=id`, `cognito:groups` | **60분** / 5분~1일 |
| **액세스** | **API 인가(스코프)**, 사용자 셀프서비스 API | `client_id`, `scope`, `token_use=access`, `username` | **60분** / 5분~1일 |
| **리프레시** | 새 ID·액세스 토큰 발급, **폐기 대상** | 사용자 풀만 읽는 **불투명** 토큰 | **30일** / 60분~10년 |

- **검증 순서**: 구조(`header.payload.signature`) → **서명**(JWKS의 `kid` 일치) → `exp` → `iss`(풀 URL) → `aud`(ID 토큰)·`client_id`(액세스 토큰) → `token_use` → 폐기 여부. JWKS는 `https://cognito-idp.<Region>.amazonaws.com/<userPoolId>/.well-known/jwks.json`이고, **서명 키가 교체될 수 있어** `kid`로 캐시하고 모르는 `kid`가 오면 갱신합니다.
- ⚠️ **ID 토큰과 액세스 토큰은 서로 다른 키로 서명**됩니다.
- ⚠️ **폐기는 오프라인으로 알 수 없습니다.** JWT는 자체 완결형이라 `exp`는 네트워크 호출 없이 검사되지만, 로그아웃·`RevokeToken`을 반영하려면 **Cognito에 확인하거나 액세스 토큰 수명을 짧게** 해야 합니다.

| OAuth 2.0 grant | 받는 토큰 | 비고 |
|---|---|---|
| **Authorization code (+PKCE)** | ID·액세스·리프레시 **모두** | 가장 안전. 토큰이 사용자에게 직접 노출되지 않는다 |
| Implicit | ID·액세스(리프레시 없음) | **레거시** — 토큰이 노출·가로채기 가능 |
| **Client credentials**(M2M) | 액세스(**커스텀 스코프만**) | ⚠️ 같은 앱 클라이언트에서 위 두 grant와 **동시 활성화 불가**. 앱 클라이언트 시크릿 필요 |

- 서버가 있는 앱·모바일은 **Authorization code + PKCE**를 쓰고, ⚠️ **리프레시 토큰을 클라이언트 측 환경에 저장하지 않습니다.**
- **스코프**: `aws.cognito.signin.user.admin`은 사용자 셀프서비스 API 권한, `openid`는 userInfo 접근입니다. 외부 API용은 **리소스 서버의 커스텀 스코프**(`resourceServerIdentifier/scopeName`)입니다.
- ⚠️ **managed login의 브라우저 쿠키는 1시간 유효**합니다 — 토큰 수명을 1시간 미만으로 줄여도 **재인증 없이 재진입 가능한 시간은 줄지 않습니다.**

> 🧠 **원리** — 서명은 헤더·페이로드를 해시해 RSA로 서명한 값이라 **변조하면 공개 키 대조에서 불일치**합니다. 그래서 검증은 "서버에 묻는 일"이 아니라 "수학을 확인하는 일"이고, 바로 그 때문에 **폐기만은 수학으로 알 수 없습니다.**

### 4) API Gateway 접근 제어 비교 (기술 2.1.2) {#apigw-auth}

| 방식 | API 유형 | 클라이언트가 보내는 것 | 검증 주체 |
|---|---|---|---|
| **IAM (`AWS_IAM`)** | REST·HTTP | **SigV4 서명 요청** | IAM — 호출자 정책의 `execute-api:Invoke` |
| **Cognito 사용자 풀 오소라이저** | REST | `Authorization` 헤더의 ID 또는 액세스 토큰 | API Gateway가 풀 ARN으로 검증 |
| **Lambda 오소라이저 TOKEN** | REST | 단일 bearer 토큰 | 내 Lambda → **IAM 정책 + principalId** 반환 |
| **Lambda 오소라이저 REQUEST** | REST·HTTP | 헤더·쿼리·stage 변수 조합 | 내 Lambda (REST에서 **AWS 권장 유형**) |
| **JWT 오소라이저** | **HTTP만** | JWT | API Gateway가 issuer·audience·scope 검증 |
| **리소스 정책** | **REST만** | — | API Gateway가 IP·VPC 엔드포인트·계정 조건 평가 |
| **API 키 + 사용량 계획** | REST | API 키 | ⚠️ **인증·인가 수단이 아니다**(식별·사용량 제한용) |
| **mTLS** | REST(Regional 커스텀 도메인) | 클라이언트 X.509 인증서 | TLS 핸드셰이크 — ⚠️ **폐기 검증 없음** |

- 메서드에 **스코프를 지정하면 액세스 토큰**이 필요합니다(ID 토큰은 신원 클레임 기반).
- **JWT 오소라이저**는 **RSA만** 지원하고 공개 키를 최대 2시간 캐시하며 ⚠️ **ID·액세스 토큰을 구분하지 못해** 스코프 요구가 권장됩니다.
- **오소라이저 캐시**: 기본 **300초**, 최대 3600초. REQUEST 유형은 **다중 identity source가 캐시 키**이고 ⚠️ 캐시를 쓰면 하나라도 없으면 **Lambda 호출 없이 401**입니다.
- ⚠️ **리소스 정책 평가**: 같은 계정은 IAM 정책과 리소스 정책 중 **하나만 allow여도** 되지만, **교차 계정은 둘 다 명시적 allow**여야 하고 한쪽이 무언급이면 암묵적 거부입니다.

> 🧠 **원리** — REST 오소라이저는 "인증 결과 → **IAM 정책 문서**"로 귀결되고 API Gateway가 그 정책을 평가합니다. 그래서 캐시도 **정책 단위로** 재사용됩니다. HTTP API의 JWT 오소라이저는 정책 없이 **토큰 검증과 스코프 일치만** 하므로 더 단순하지만 표현력이 낮습니다.

### 5) 프로그래밍 액세스 — 자격 증명 체인 (기술 2.1.3) {#programmatic}

SDK·CLI는 정해진 소스를 **순서대로 확인하고 유효한 자격 증명을 찾으면 멈춥니다.** CLI 우선순위는 명령줄 옵션 → 환경 변수 → assume role·web identity → IAM Identity Center → 자격 증명 파일·프로세스·config → 컨테이너 → EC2 인스턴스 프로파일입니다.

| 실행 환경 | 자격 증명 출처 |
|---|---|
| 로컬 개발 | IAM Identity Center SSO 프로필(권장) — ⚠️ 장기 IAM 사용자 키는 비권장 |
| **EC2** | 인스턴스 프로파일 역할을 **IMDS**로 제공(IMDSv2는 PUT으로 토큰을 받아 GET에 첨부, TTL 최대 6시간) |
| **ECS** | 작업 역할 → `AWS_CONTAINER_CREDENTIALS_RELATIVE_URI` |
| **EKS** | **Pod Identity**(권장) → `AWS_CONTAINER_CREDENTIALS_FULL_URI` / IRSA는 `AssumeRoleWithWebIdentity` 방식 |
| **Lambda** | 실행 역할의 임시 자격 증명이 **환경 변수로** 제공 |
| 온프레미스 | 프로세스 공급자(IAM Roles Anywhere 포함) |

- ⚠️ **환경 변수의 액세스 키는 `AWS_PROFILE` 프로필을 덮어씁니다.**
- ⚠️ **환경 변수에 넣어 둔 임시 자격 증명은 만료 후 자동 갱신되지 않습니다.** 표준 공급자(역할·SSO·컨테이너·IMDS)는 자동 갱신합니다.
- 역할 수임 프로필은 `role_arn`에 더해 `source_profile`·`credential_source`·`web_identity_token_file` 중 **하나가 필요**하고, 앞의 둘은 **같은 프로필에 동시에 쓸 수 없습니다.**

> 🧠 **원리** — 자동 갱신되는 공급자를 쓰면 **코드·이미지에 장기 키를 두지 않아도** 됩니다. 그래서 "키를 어디에 저장할까"라는 질문 자체가 대개 잘못된 질문이고, 정답은 "**저장하지 않는 경로를 고른다**"입니다.

### 6) 사전 서명 URL — 시간 제한 안전 액세스 (기술 2.1.4) {#presigned}

🆕 **C03 신설 기술**입니다. 누구든 유효한 자격 증명이 있으면 사전 서명 URL을 만들 수 있지만, ⚠️ **그 URL이 통하려면 만든 사람이 그 작업을 수행할 권한을 가지고 있어야** 합니다.

| 만든 자격 증명 | 유효 한도 |
|---|---|
| **IAM 사용자**(SigV4) | **최대 7일** |
| **임시 보안 자격 증명** | ⚠️ **자격 증명 자체보다 길 수 없다** |
| └ IAM 역할 자격 증명 | **역할 세션이 끝나면 URL도 끝난다**(더 긴 만료를 지정해도) |
| └ EC2 인스턴스의 역할 자격 증명 | 그 자격 증명 기간 동안(보통 **6시간**) |

- ⭐ **가장 많이 틀리는 지점**: "만료를 7일로 줬는데 왜 일찍 끊기나?" → **임시 자격 증명으로 만들었기 때문**입니다.
- ⚠️ **URL을 만든 자격 증명이 취소·삭제·비활성화되면 URL도 그 시점에 죽습니다** — 더 늦은 만료를 지정했어도 그렇습니다. **즉시 무효화**가 필요하면 이 성질을 씁니다.
- **콘솔**로 만들면 만료가 **1분~12시간**, **CLI·SDK**는 최대 7일입니다.
- 만료 후 접근하면 `AccessDenied` / `Request has expired`가 돌아옵니다(응답에 `Expires`·`ServerTime`이 들어 있습니다).

**CloudFront 서명 URL·서명 쿠키는 메커니즘이 다릅니다.** 섞으면 안 됩니다.

| | **S3 사전 서명 URL** | **CloudFront 서명 URL·쿠키** |
|---|---|---|
| 서명 재료 | **호출자의 AWS 자격 증명** | **키 그룹의 개인 키** |
| 만료 상한 | **자격 증명이 정함**(최대 7일) | 서명에 넣은 만료 |
| 범위 | 객체 1개 작업 | **URL=파일 1개 / 쿠키=경로 아래 다수** |
| 적용 지점 | 요청 | **캐시 동작**(cache behavior) |

- 서명자는 **신뢰할 수 있는 키 그룹**(권장) 또는 CloudFront 키 페어를 가진 계정입니다. 서명자의 두 역할: ① **배포에 서명자를 추가하는 순간** CloudFront가 서명 URL·쿠키를 **요구하기 시작**하고 ② 서명자의 개인 키로 서명한 값을 CloudFront가 대조해 **변조와 만료**를 확인합니다.
- 어떤 파일에 요구할지는 **캐시 동작에 서명자를 붙여** 간접 지정합니다 — 캐시 동작이 하나면 배포 전체, 여러 개면 일부 경로에만 걸 수 있습니다.

> 🧠 **원리** — S3 사전 서명 URL은 **"내 권한을 잠시 빌려주는 것"**입니다. 그래서 내 자격 증명이 사라지면 빌려준 권한도 사라집니다. CloudFront 서명은 **"별도의 키로 입장권을 발행하는 것"**이라 내 자격 증명과 무관하게 살아 있고, 그래서 키 그룹 관리가 따로 필요합니다.

### 7) 인증된 호출 — SigV4 (기술 2.1.5) {#sigv4}

- SDK·CLI는 제공된 자격 증명으로 **요청에 자동 서명**합니다. 직접 서명 코드를 쓰는 것은 **SDK가 없거나 완전한 제어가 필요할 때**뿐입니다.
- **3단계**: 정규 요청 생성 → 자격 증명으로 서명 계산 → `Authorization` 헤더(또는 쿼리 문자열)에 추가. 서비스가 **같은 과정을 재현해 서명을 비교**합니다.
- ⚠️ **비밀 키로 직접 서명하지 않습니다** — **날짜·리전·서비스로 파생한 서명 키**를 쓰고, 임시 자격 증명이면 **세션 토큰도** 필요합니다.
- 서명 요소: 알고리즘 `AWS4-HMAC-SHA256`, 자격 범위 `액세스키ID/YYYYMMDD/리전/서비스/aws4_request`, UTC 타임스탬프. **SigV4a**는 다중 리전 요청용이고 SDK가 필요 시 자동 전환합니다.
- **서명이 필요한 대표 경로**: API Gateway `AWS_IAM` · Lambda 함수 URL `AWS_IAM`(호출자에게 `lambda:InvokeFunctionUrl` 필요) · S3 사전 서명 URL · AppSync `AWS_IAM`.

> 🧠 **원리** — 요청 해시로 **변조**를, 타임스탬프로 **재전송**(대개 5분 이내 도달)을 막고, **비밀 키 자체는 전송하지 않습니다.** 그래서 SigV4는 "토큰을 보내는 것"이 아니라 "요청 전체를 봉인하는 것"입니다.

### 8) 권한 정의 — 정책 유형과 평가 (기술 2.1.6) {#policies}

| 정책 유형 | 붙이는 곳 | 권한 부여? | 요점 |
|---|---|---|---|
| **자격 증명 기반** | 사용자·그룹·역할 | **부여** | 관리형(AWS·고객)·인라인 |
| **리소스 기반** | 리소스(S3 버킷 정책, 역할 **신뢰 정책**) | **부여** | 인라인뿐. 같은 계정이면 ID 정책 불필요, **교차 계정이면 ID 정책도 필요** |
| VPC 엔드포인트 정책 | VPC 엔드포인트 | 제한 | 기본 정책은 전체 허용 |
| **권한 경계** | 사용자·역할 | 제한 | ID 정책이 줄 수 있는 **최대** |
| **SCP / RCP** | Organizations 계정·OU | 제한 | 멤버 계정 주체(루트 포함) / 리소스 측 최대 권한 |
| **세션 정책** | 세션 생성 시 | 제한 | 세션 권한 = **ID 정책 ∩ 세션 정책** |

- **평가 규칙**: 기본은 **암묵적 거부**이고, **명시적 Deny는 어떤 Allow도 이깁니다.** 같은 계정의 ID 기반 + 리소스 기반은 **합집합**(하나라도 허용이면 허용), **권한 경계는 교집합**, **SCP·RCP는 모두 허용**해야 합니다.
- 정책 크기 한도: 역할 인라인 합계 **10,240자**(사용자 2,048 · 그룹 5,120), 고객 관리형 정책 1개 **6,144자**(공백 제외).
- 자주 나오는 조건 키: `aws:PrincipalTag`·`aws:RequestTag`·`aws:ResourceTag` · `sts:ExternalId` · `aws:MultiFactorAuthPresent` · `iam:PassedToService` · `aws:SourceArn`·`aws:SourceAccount` · `dynamodb:LeadingKeys`.
- **앱 수준 세분화 권한 부여**: Cognito 그룹(`cognito:groups`, 그룹별 IAM 역할·**Precedence는 낮을수록 우선**) · 사전 토큰 생성 Lambda · 메서드별 스코프 · **Amazon Verified Permissions**(Cedar) · **ABAC** · DynamoDB `dynamodb:LeadingKeys`.
- ⚠️ **DynamoDB 세분화 권한의 함정 둘**: `dynamodb:LeadingKeys`는 파티션 키를 뜻하고 반드시 **`ForAllValues` 한정자**와 씁니다. **`Scan`은 모든 항목을 반환하므로** LeadingKeys 정책에 허용하지 않습니다. 속성 제한은 요청에 `ProjectionExpression`이 없으면 우회되므로 `dynamodb:Select`도 함께 제한합니다.
- ⚠️ **`iam:PassRole`과 `sts:AssumeRole`은 다릅니다** — PassRole은 **사람이 서비스를 설정할 때 서비스에 역할을 넘기는** 권한이고(`iam:PassedToService`로 범위 제한), AssumeRole은 **주체가 직접 임시 자격 증명을 요청하는** 호출입니다.

> 🧠 **원리** — 정책 유형은 **부여형과 제한형** 둘로 나뉩니다. 부여형은 더하기(합집합), 제한형은 곱하기(교집합)로 작동하므로, "왜 거부됐는가"는 **제한형 중 하나가 빠졌는지**부터 봅니다. 그리고 명시적 Deny는 그 모든 계산을 무조건 이깁니다.

### 9) 역할 수임 (기술 2.1.7) {#assume-role}

역할은 **장기 자격 증명이 없는 IAM 자격 증명**이고, 수임하면 임시 자격 증명을 받습니다. 역할에는 정책이 둘입니다 — **신뢰 정책**(누가 수임하나)과 **권한 정책**(수임 후 무엇을 하나).

| STS API | 호출자 | 수명(기본) | MFA | 세션 정책 |
|---|---|---|---|---|
| **AssumeRole** | IAM 사용자·역할 | 15분~역할 최대 세션(1~12시간), **기본 1시간** | 가능 | 가능 |
| AssumeRoleWithSAML | 누구나(SAML 제시) | 동일 | 불가 | 가능 |
| AssumeRoleWithWebIdentity | 누구나(OIDC JWT 제시) | 동일 | 불가 | 가능 |
| GetFederationToken | IAM 사용자·루트 | 15분~36시간(**기본 12시간**) | 불가 | 가능 |
| GetSessionToken | IAM 사용자·루트 | 동일 | **가능** | **불가** |

- ⚠️ **역할 체이닝**(역할로 또 다른 역할을 수임)은 CLI·API 세션을 **최대 1시간**으로 제한하고 **늘릴 수 없습니다**(콘솔 역할 전환에는 해당하지 않습니다). 1시간을 넘기면 `exceeds the 1 hour session limit for roles assumed by role chaining` 계열 오류가 납니다.
- ⚠️ **서비스가 수임한 세션에는 역할의 최대 세션 설정이 적용되지 않습니다.**
- 보조 파라미터: **`ExternalId`**(서드파티 접근·confused deputy 방지, **비밀이 아닙니다**) · **MFA**(신뢰 정책 `aws:MultiFactorAuthPresent`) · **세션 정책**(인라인 1 + 관리형 최대 10, 합계 **2,048자**, ⚠️ **권한을 넓힐 수 없습니다**) · **세션 태그**(최대 50개, `sts:TagSession` 필요, 전이적 태그는 체이닝으로 전달) · `RoleSessionName`(**CloudTrail에 기록**).
- 용어 구분: **서비스 역할**(서비스가 대신 수임) · **서비스 연결 역할**(서비스가 소유·편집 불가) · **실행 역할**(예: Lambda).
- 결과 자격 증명은 **`GetFederationToken`·`GetSessionToken`을 호출할 수 없습니다.**

> 🧠 **원리** — 신뢰 정책("누가")과 권한 정책("무엇을")을 분리하면 **키를 공유하지 않고 위임**할 수 있습니다. 그리고 임시 자격 증명은 만료되므로 **별도의 폐기 절차가 필요 없습니다** — 이것이 장기 액세스 키보다 역할이 선호되는 핵심 이유입니다.

---

## ✍️ 시험 포인트

- **"Cognito로 로그인한 사용자가 S3에 직접 업로드"** → 사용자 풀 토큰 → **자격 증명 풀** → 임시 자격 증명 → SigV4. 중개 단계가 보기에서 빠져 있으면 그 보기가 오답입니다.
- **"7일짜리 다운로드 링크"** → **IAM 사용자 자격 증명 + CLI·SDK**. 역할 자격 증명으로는 세션 길이를 넘지 못합니다. 콘솔은 **12시간**이 상한입니다.
- **"뿌린 링크를 즉시 막아야 한다"** → 만든 **자격 증명을 취소·비활성화**합니다.
- **"경로 아래 수십 개 파일을 한 번에 보호"** → **CloudFront 서명 쿠키**. **"일부 경로만 서명 요구"** → **캐시 동작**별 서명자.
- **"교차 계정에서 API Gateway를 부르는데 거부된다"** → **IAM 정책과 리소스 정책 둘 다 명시적 allow**가 필요합니다.
- **"역할로 역할을 수임하니 1시간 이상이 안 된다"** → **역할 체이닝 상한**이고 늘릴 수 없습니다.
- **"세션 정책으로 권한을 더 주려 한다"** → 불가능합니다. 결과는 **교집합**입니다.
- **"서드파티가 내 계정 역할을 수임한다"** → 신뢰 정책에 **`sts:ExternalId`** 조건. 서비스가 대신 호출하면 **`aws:SourceArn`·`aws:SourceAccount`**.

---

## ⚠️ 흔한 함정 {#pitfalls}

| 함정 | 바로잡기 |
|---|---|
| JWT로 AWS API를 직접 부를 수 있다고 본다 | AWS API는 **SigV4 서명**이 필요하다 — 자격 증명 풀이 JWT를 임시 자격 증명으로 바꿔 준다 |
| 사용자 풀과 자격 증명 풀을 같은 것으로 본다 | 사용자 풀=**인증**(JWT), 자격 증명 풀=**권한 부여**(STS 자격 증명) |
| 사전 서명 URL 만료를 내가 정한다고 본다 | **자격 증명이 상한을 정한다** — 임시 자격 증명이면 세션이 끝나는 순간 URL도 끝난다 |
| 콘솔로 7일짜리 사전 서명 URL을 만들려 한다 | 콘솔은 **1분~12시간**이다. 7일은 **CLI·SDK + IAM 사용자 키** |
| S3 사전 서명 URL과 CloudFront 서명을 섞는다 | 서명 재료가 다르다 — **호출자 자격 증명** vs **키 그룹 개인 키** |
| API 키를 인증 수단으로 쓴다 | **식별·사용량 제한용**이고 인증·인가가 아니다 |
| HTTP API에서 요청 본문 검증·리소스 정책을 기대한다 | 둘 다 **REST 전용**이다 |
| JWT 오소라이저가 ID·액세스 토큰을 구분한다고 본다 | **구분하지 못한다** — 스코프 요구로 보완한다 |
| 교차 계정에서 한쪽 정책만 허용한다 | **양쪽 모두 명시적 allow**여야 한다(한쪽 무언급 = 암묵적 거부) |
| 세션 정책으로 권한을 확대하려 한다 | **교집합**이라 넓힐 수 없다(합계 2,048자) |
| 역할 체이닝 세션을 12시간으로 늘리려 한다 | **1시간 상한**이고 늘릴 수 없다 |
| `iam:PassRole`과 `sts:AssumeRole`을 같은 것으로 본다 | PassRole은 **서비스에 역할을 넘기는** 권한, AssumeRole은 **직접 수임하는** 호출 |
| 환경 변수의 임시 자격 증명이 자동 갱신된다고 본다 | **갱신되지 않는다.** 역할·SSO·컨테이너·IMDS 공급자는 갱신된다 |
| 게스트 자격을 켜 두고 풀 ID를 비밀로 믿는다 | **풀 ID는 비밀이 아니다** — 아는 누구나 게스트 자격을 요청할 수 있다 |
| `dynamodb:LeadingKeys` 정책에 `Scan`을 허용한다 | Scan은 **모든 항목을 반환**해 세분화 제어가 무너진다 |

---

## 🧪 자가 점검

**Q1.** 모바일 앱 사용자가 자기 폴더에만 S3 업로드를 해야 한다. Cognito를 어떻게 구성하고, 왜 사용자 풀만으로는 안 되는가? (→ 1) Cognito)

<details><summary>정답 보기</summary>

**사용자 풀로 로그인 → 자격 증명 풀에 ID 토큰 제시 → STS 임시 자격 증명 → 그 자격 증명으로 SigV4 서명해 S3 호출**입니다. 사용자 풀만으로 안 되는 이유는 **AWS API 요청이 SigV4 서명을 요구하고 JWT는 그 서명 재료가 아니기** 때문입니다 — JWT를 임시 자격 증명으로 바꿔 주는 **중개자가 자격 증명 풀**입니다.

폴더 격리는 자격 증명 풀이 선택하는 **IAM 역할의 정책**에서 정책 변수(예: `${cognito-identity.amazonaws.com:sub}`)나 **ABAC**(주체 태그)로 구현합니다. ⚠️ 사용자가 바꿀 수 있는 클레임을 높은 권한 역할에 매핑하면 누구나 그 역할을 얻으므로 주의합니다.
</details>

**Q2.** 만료를 7일로 지정해 사전 서명 URL을 만들었는데 몇 시간 뒤 끊겼다. 원인과, 반대로 "즉시 무효화"가 필요할 때 쓰는 방법은? (→ 6) 사전 서명 URL)

<details><summary>정답 보기</summary>

**임시 자격 증명으로 만들었기 때문**입니다. 사전 서명 URL은 **자격 증명 자체보다 오래 살 수 없어서**, IAM 역할 자격 증명이면 **역할 세션이 끝나는 순간** URL도 끝납니다(EC2 인스턴스 역할은 보통 6시간). 7일을 주려면 **IAM 사용자 자격 증명 + CLI·SDK**가 필요하고, 콘솔로 만들면 상한이 **1분~12시간**입니다.

즉시 무효화는 같은 성질을 역으로 씁니다 — **URL을 만든 자격 증명을 취소·삭제·비활성화**하면 더 늦은 만료를 지정했어도 그 시점에 죽습니다.
</details>

**Q3.** 사용자가 `/videos/` 아래 수십 개 파일에 10분간 접근해야 한다. S3 사전 서명 URL과 CloudFront 서명 중 무엇을 고르고, 적용 지점은 어디인가? (→ 6) 사전 서명 URL)

<details><summary>정답 보기</summary>

**CloudFront 서명 쿠키**입니다 — 서명 URL은 **파일 하나**에 접근을 주지만 서명 쿠키는 **경로 아래 여러 파일**에 줍니다. S3 사전 서명 URL은 **객체 1개 작업**이라 수십 개면 수십 개를 만들어야 합니다.

적용 지점은 **캐시 동작(cache behavior)**입니다 — 서명자(신뢰할 수 있는 키 그룹)를 캐시 동작에 붙이면 그 동작이 다루는 경로부터 CloudFront가 서명을 **요구하기 시작**합니다. 캐시 동작이 하나면 배포 전체에 걸립니다. 서명 재료는 호출자의 AWS 자격 증명이 아니라 **키 그룹의 개인 키**입니다.
</details>

**Q4.** 다른 계정의 Lambda가 내 REST API를 호출해야 한다. 어떤 정책들이 필요하고 흔한 실패 원인은? (→ 4) API Gateway · 8) 권한 정의)

<details><summary>정답 보기</summary>

호출자 쪽에는 **`execute-api:Invoke` 권한**(Lambda 실행 역할), 내 쪽에는 **API Gateway 리소스 정책**이 필요하고 호출은 **SigV4 서명**(`AWS_IAM`)으로 갑니다.

흔한 실패 원인은 **교차 계정에서는 양쪽이 모두 명시적 allow여야 한다**는 점입니다 — 같은 계정이면 둘 중 하나만 허용해도 통하지만, 교차 계정에서 한쪽이 **무언급이면 암묵적 거부**입니다. 그리고 어느 쪽이든 **명시적 Deny는 모든 Allow를 이깁니다.**
</details>

**Q5.** `AssumeRole`로 받은 자격 증명으로 또 다른 역할을 수임했는데 세션을 4시간으로 늘릴 수 없다. 왜인가? 세션 정책으로 권한을 넓힐 수 있는가? (→ 9) 역할 수임)

<details><summary>정답 보기</summary>

**역할 체이닝**이기 때문입니다 — 역할로 또 다른 역할을 수임하면 CLI·API 세션이 **최대 1시간**으로 제한되고 **늘릴 수 없습니다**(콘솔 역할 전환에는 해당하지 않습니다). 넘기면 `exceeds the 1 hour session limit for roles assumed by role chaining` 계열 오류가 납니다.

세션 정책으로는 **권한을 넓힐 수 없습니다** — 결과 권한은 **역할 권한 정책과의 교집합**입니다(인라인 1개 + 관리형 최대 10개, 평문 합계 2,048자). 넓히려면 역할의 권한 정책 자체를 바꿔야 합니다.
</details>

**Q6.** 액세스 토큰 수명을 5분으로 줄였는데도 로그아웃한 사용자가 계속 들어온다. 무엇을 놓쳤는가? (→ 3) 토큰)

<details><summary>정답 보기</summary>

두 가지입니다. ① **JWT 검증은 폐기를 오프라인으로 알 수 없습니다** — 서명과 `exp`는 네트워크 없이 확인되지만 로그아웃·`RevokeToken`은 반영되지 않습니다. 폐기를 즉시 반영하려면 **Cognito에 확인**하거나 토큰 수명을 짧게 유지해야 합니다. ② ⚠️ **managed login의 브라우저 쿠키가 1시간 유효**합니다 — 토큰 수명을 줄여도 **재인증 없이 재진입 가능한 시간은 줄지 않습니다.**

또한 **리프레시 토큰**(기본 30일)이 살아 있으면 새 토큰을 계속 받을 수 있으므로 함께 폐기해야 합니다.
</details>

**Q7.** 자격 증명 체인에서 로컬 개발자가 `AWS_PROFILE`을 설정했는데 다른 계정으로 호출된다. 원인과, EC2·Lambda의 자격 증명 출처는? (→ 5) 프로그래밍 액세스)

<details><summary>정답 보기</summary>

**환경 변수의 `AWS_ACCESS_KEY_ID`·`AWS_SECRET_ACCESS_KEY`가 `AWS_PROFILE` 프로필의 자격 증명을 덮어쓰기** 때문입니다. 체인은 **처음 유효한 자격 증명에서 멈추고**, CLI 우선순위는 명령줄 옵션 → 환경 변수 → assume role → Identity Center → 파일 → 컨테이너 → 인스턴스 프로파일입니다.

출처는 **EC2는 인스턴스 프로파일 역할을 IMDS로**(IMDSv2는 PUT으로 토큰을 받아 GET에 첨부), **Lambda는 실행 역할의 임시 자격 증명을 환경 변수로** 받습니다. ⚠️ 사람이 **환경 변수에 직접 넣어 둔 임시 자격 증명은 만료 후 자동 갱신되지 않습니다.**
</details>

---

### 📌 출처

1. What is Amazon Cognito? — https://docs.aws.amazon.com/cognito/latest/developerguide/what-is-amazon-cognito.html
2. Identity pools authentication flow (Cognito) — https://docs.aws.amazon.com/cognito/latest/developerguide/authentication-flow.html
3. Understanding user pool JSON web tokens (JWTs) — https://docs.aws.amazon.com/cognito/latest/developerguide/amazon-cognito-user-pools-using-tokens-with-identity-providers.html
4. Verifying JSON web tokens (Cognito) — https://docs.aws.amazon.com/cognito/latest/developerguide/amazon-cognito-user-pools-using-tokens-verifying-a-jwt.html
5. Identity providers and federation into AWS (IAM) — https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers.html
6. AssumeRoleWithWebIdentity (AWS STS) — https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRoleWithWebIdentity.html
7. AssumeRole (AWS STS) — https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRole.html
8. Compare AWS STS credentials — https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_sts-comparison.html
9. IAM roles — https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html
10. Grant a user permissions to pass a role to an AWS service — https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_passrole.html
11. Policies and permissions in AWS IAM — https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html
12. Policy evaluation logic — https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_evaluation-logic.html
13. AWS Signature Version 4 for API requests — https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_sigv.html
14. AWS SDKs and Tools standardized credential providers — https://docs.aws.amazon.com/sdkref/latest/guide/standardized-credentials.html
15. Download and upload objects with presigned URLs (Amazon S3) — https://docs.aws.amazon.com/AmazonS3/latest/userguide/using-presigned-url.html
16. Specifying the signers that can create signed URLs and signed cookies (CloudFront) — https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-trusted-signers.html
17. Use API Gateway Lambda authorizers — https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-use-lambda-authorizer.html
18. Control access to REST APIs using Cognito user pools as an authorizer — https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-integrate-with-cognito.html
19. Control access to HTTP APIs with JWT authorizers — https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-jwt-authorizer.html
20. Control access to a REST API with IAM permissions — https://docs.aws.amazon.com/apigateway/latest/developerguide/permissions.html
21. Using IAM policy conditions for fine-grained access control (DynamoDB) — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/specifying-conditions.html
22. DVA-C03 공식 시험 가이드 · 콘텐츠 도메인 2 (한국어) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/developer-associate-03/developer-associate-03-domain2.html
