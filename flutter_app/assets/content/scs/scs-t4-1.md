---
examGuideTaskId: scs-t4-1
certCode: SCS-C03
domain: 4
domainName: ID 및 액세스 관리
domainWeightPct: 20
title: 인증 전략 (ID 솔루션 설계·임시 자격 증명 발급·인증 문제 해결)
coversTasks:
  - "4.1"
sources:
  - title: What is IAM Identity Center?
    url: https://docs.aws.amazon.com/singlesignon/latest/userguide/what-is.html
  - title: Manage AWS accounts with permission sets
    url: https://docs.aws.amazon.com/singlesignon/latest/userguide/permissionsetsconcept.html
  - title: What is Amazon Cognito?
    url: https://docs.aws.amazon.com/cognito/latest/developerguide/what-is-amazon-cognito.html
  - title: AWS Multi-factor authentication in IAM
    url: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_mfa.html
  - title: Temporary security credentials in IAM
    url: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp.html
  - title: Compare AWS STS credentials
    url: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_sts-comparison.html
  - title: Request temporary security credentials
    url: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_request.html
  - title: Use temporary credentials with AWS resources
    url: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_use-resources.html
  - title: Download and upload objects with presigned URLs
    url: https://docs.aws.amazon.com/AmazonS3/latest/userguide/using-presigned-url.html
  - title: Sharing objects with presigned URLs
    url: https://docs.aws.amazon.com/AmazonS3/latest/userguide/ShareObjectPreSignedURL.html
  - title: What is AWS Directory Service?
    url: https://docs.aws.amazon.com/directoryservice/latest/admin-guide/what_is.html
  - title: Troubleshoot access denied error messages
    url: https://docs.aws.amazon.com/IAM/latest/UserGuide/troubleshoot_access-denied.html
  - title: CloudTrail record contents for management, data, and network activity events
    url: https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-event-reference-record-contents.html
  - title: AWS Lifecycle Changes
    url: https://docs.aws.amazon.com/general/latest/gr/service-lifecycle.html
lastVerified: 2026-11-09
---

# 인증 전략 (ID 솔루션 설계·임시 자격 증명 발급·인증 문제 해결)

> **커버하는 공식 Task** — SCS-C03 · 도메인 4 「ID 및 액세스 관리」(20%) · **작업 4.1 인증 전략 설계, 구현 및 문제 해결** (`scs-t4-1`)
> 이 문서는 위 한 작업에 1:1로 매핑되고 공식 기술 3개(4.1.1~4.1.3)를 모두 덮습니다.

> ⚠️ **도메인 4는 20%로 이 시험의 최대 도메인인데 작업이 둘뿐입니다.** 기술은 작업 4.1이 3개, 작업 4.2가 5개로 **합쳐 8개**입니다. 즉 **기술 하나가 다른 도메인보다 훨씬 깊게 출제됩니다.** 얕게 여러 서비스를 훑는 대신, 이 문서는 **공식 비교표에 적힌 값과 그 예외**를 끝까지 따라갑니다.

> 이 작업의 축은 **「누구인지 증명하는 쪽」**입니다. 증명이 끝난 뒤 **「무엇을 할 수 있는가」**는 작업 4.2(`scs-t4-2`)가 다룹니다. 두 작업이 한 시나리오 안에서 섞여 나오므로, 문항을 읽을 때 **인증 실패인지 권한 부여 실패인지**를 먼저 가르는 연습이 그대로 점수가 됩니다.

---

## ✅ 학습 목표 체크리스트

- [ ] 워크포스·앱 사용자·AWS 밖 워크로드의 **ID 축 세 개**를 가른다
- [ ] IAM Identity Center의 **인스턴스 유형 둘**과 할 수 있는 일의 차이를 안다
- [ ] Cognito **사용자 풀과 ID 풀**이 답하는 질문을 구분한다
- [ ] 공식 **MFA 유형 셋**과 종료된 유형을 말한다
- [ ] STS API 다섯의 **수명·MFA·세션 정책** 차이를 표로 떠올린다
- [ ] 미리 서명된 URL의 **만료가 무엇으로 결정되는지** 설명한다
- [ ] 접근 거부 메시지에서 **명시적 거부와 암시적 거부**를 가른다
- [ ] 인증 실패를 **CloudTrail 어느 필드**로 추적하는지 안다

## 🎯 왜 중요한가

인증 문항은 **"로그인은 됐는데 왜 안 되나"** 또는 **"왜 이 사람이 되나"**로 나옵니다. 둘 다 **자격 증명이 어디서 나왔고 얼마나 사는지**를 모르면 풀 수 없습니다.

그리고 Specialty 시험은 **표에 적힌 값의 예외**를 좋아합니다. 임시 자격 증명 다섯 가지 중 **MFA를 받는 것은 둘뿐**이고, **세션 정책을 못 받는 것은 하나뿐**이며, **콘솔 로그인에 쓸 수 있는 것과 없는 것이 갈립니다**(§2-1·2-2). 미리 서명된 URL은 **내가 적은 만료 시간이 아니라 서명에 쓴 자격 증명의 수명**이 먼저 끝날 수 있습니다(§2-3). 그 자리들이 이 문서의 뼈대입니다.

## ⚡ 시험 직전 요약

- **IAM Identity Center는 인스턴스 유형이 둘**이고 ⚠️⚠️ **AWS 계정 액세스 관리는 조직 인스턴스에서만** 됩니다. 권한 세트도 조직 인스턴스 전용입니다
- **Cognito 사용자 풀은 "누구인가"(인증·JWT 발급), ID 풀은 "어느 AWS 리소스에 닿나"(임시 자격 증명 교환)**이고 ⚠️ **둘은 서로를 요구하지 않습니다**
- ⚠️⚠️ **공식 MFA 유형은 셋**(패스키·보안 키 / 가상 인증자 앱 / 하드웨어 TOTP 토큰)이고 **SMS 문자 기반 MFA는 활성화 지원이 종료**됐습니다. 한 사용자가 **최대 8개** 등록, 로그인에는 **하나**면 됩니다
- ⚠️⚠️ **MFA를 받는 STS API는 `AssumeRole`·`GetSessionToken` 둘뿐**이고, **세션 정책을 못 받는 것은 `GetSessionToken` 하나뿐**입니다
- ⚠️⚠️ **콘솔 SSO는 `GetFederationToken`은 되고 `GetSessionToken`은 안 됩니다**
- `AssumeRole` 계열의 최대 수명은 **역할의 「최대 세션 기간」 설정**이고 기본값은 **1시간**, `GetFederationToken`·`GetSessionToken`은 IAM 사용자 기준 **최대 36시간·기본 12시간**(루트 사용자는 최대 1시간)입니다
- ⚠️ **`GetCallerIdentity`는 권한이 필요 없고 명시적으로 거부돼도 호출됩니다** — "나는 지금 누구인가"를 확인하는 첫 수단입니다
- ⚠️⚠️ **미리 서명된 URL은 설정한 만료와 서명에 쓴 자격 증명의 수명 중 먼저 오는 쪽에 죽습니다.** 콘솔은 1분~12시간, CLI·SDK는 최대 7일이며 **역할 세션으로 서명하면 그 세션이 끝날 때**(기본 1시간) 끝납니다
- **접근 거부는 명시적 거부(`Deny` 문장)와 암시적 거부(`Allow`도 `Deny`도 없음)로 갈리고** ⚠️ **여러 정책 유형이 거부하면 오류 메시지는 그중 하나만 적습니다**
- ⚠️ **Simple AD는 유지 관리 상태**이고 **MFA·신뢰 관계·LDAPS·스키마 확장을 지원하지 않습니다**

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **워크포스 ID** | 우리 조직 구성원(직원·계약자)의 ID. AWS 계정 여러 개에 로그인하는 쪽입니다 |
| **임시 보안 자격 증명** | 액세스 키 ID·비밀 액세스 키에 **세션 토큰**이 더해진 한시적 자격 증명. 만료 후 재사용할 수 없습니다 |
| **권한 세트** | IAM 정책 묶음 템플릿. 할당하면 각 계정에 **Identity Center가 통제하는 IAM 역할**이 만들어집니다 |
| **신뢰할 수 있는 ID 전파** | AWS 관리형 애플리케이션이 **사용자 ID 자체**를 다른 관리형 애플리케이션에 전달하는 방식. CloudTrail이 **사용자 기준**으로 기록됩니다 |
| **사용자 풀 / ID 풀** | Cognito의 두 구성요소. 전자는 사용자 디렉터리(인증), 후자는 토큰 → AWS 자격 증명 교환(권한 부여) |
| **미리 서명된 URL** | 생성자의 자격 증명으로 서명해 한시적 접근을 주는 URL. 공식 표현으로 **소유자 토큰(bearer token)**입니다 |
| **명시적 거부 / 암시적 거부** | 전자는 `Deny` 문장이 있는 경우, 후자는 적용되는 `Allow`가 없어 기본 거부가 남은 경우 |
| **최대 세션 기간** | 역할에 설정하는 값. `AssumeRole` 계열의 `DurationSeconds` 상한이 됩니다 |

## 📖 핵심 개념

### 1) 사람·앱·시스템의 ID를 어디에 두는가 (기술 4.1.1) {#identity}

#### 1-1. 축을 먼저 가른다

공식 기술 4.1.1은 "사용자, 애플리케이션 및 시스템 인증용 ID 솔루션"을 한 줄로 묶지만, **쓰는 서비스가 셋으로 갈립니다.**

| 누구를 인증하나 | 쓰는 것 | 왜 그것인가 |
|---|---|---|
| **우리 조직 구성원**(워크포스) | **IAM Identity Center** | 여러 AWS 계정과 관리형 애플리케이션에 **한 번의 연동**으로 SSO |
| **앱의 최종 사용자** | **Amazon Cognito** | OIDC 표준 사용자 디렉터리 + 소셜·엔터프라이즈 제공자 + 게스트 |
| **AWS 밖에서 도는 서버·컨테이너** | **IAM Roles Anywhere** | X.509 인증서로 임시 자격 증명. 장기 액세스 키를 두지 않습니다 |

⚠️ **셋을 섞은 보기가 자주 나옵니다.** "앱 사용자를 권한 세트로 관리한다"나 "온프레미스 서버에 IAM 사용자 액세스 키를 둔다"가 대표적인 오답입니다. Roles Anywhere는 **권한 부여 쪽 기술 4.2.1**에도 걸려 있어 `scs-t4-2` §1-4에서 신뢰 경계까지 다룹니다.

#### 1-2. IAM Identity Center — 인스턴스 유형이 둘이다

공식 소개 페이지가 **인스턴스 유형 둘**을 명시하고, **할 수 있는 일이 다릅니다.**

| | **조직 인스턴스** | **계정 인스턴스** |
|---|---|---|
| 어디에 만드나 | AWS Organizations **관리 계정** | 활성화한 그 계정에 묶입니다 |
| **AWS 계정 액세스 관리** | **가능 — 이쪽만 가능합니다** | 불가 |
| 권한 세트 | **조직 인스턴스 전용 기능** | 쓸 수 없습니다 |
| 공식 권고 | **모범 사례이고 전 프로덕션 용도에 권장** | **선택된 AWS 관리형 애플리케이션의 격리 배포 지원에만** |

⚠️⚠️ **"권한 세트로 계정 액세스를 중앙 관리한다"는 조직 인스턴스에서만 성립합니다.** 계정 인스턴스를 켜 둔 시나리오에서 그 선택지를 고르면 틀립니다.

기억할 세부가 넷 더 있습니다.

- **연동은 한 번이면 됩니다** — SAML 2.0 IdP를 쓸 때 공식 문구가 "you only federate once, and you have only one certificate to manage"입니다. "계정마다 IdP를 연동한다"는 오답의 근거가 이 문장입니다
- **신뢰할 수 있는 ID 전파** — 관리형 애플리케이션이 사용자 ID 자체를 전달하고, **CloudTrail 이벤트가 사용자와 그 사용자가 시작한 작업 기준으로 기록**됩니다. "누가 무엇에 접근했는지" 감사가 쉬워지는 근거입니다
- **다중 리전 액세스** — 인스턴스를 추가 리전으로 복제하면 활성화된 전 리전에서 할당된 계정·애플리케이션에 접근합니다
- ⚠️ **이미 IAM 연동을 쓰고 있다면 바꿀 필요가 없습니다** — 공식이 "You don't need to make any changes to your current AWS account workflows"라고 적습니다. "관리형 애플리케이션을 쓰려면 기존 워크플로를 전부 옮겨야 한다"는 거짓입니다

⚠️ **이름과 슬러그가 어긋납니다.** 2022-07-26에 AWS Single Sign-On에서 개명됐지만 **레거시 네임스페이스는 그대로**입니다 — `sso`·`identitystore` API 네임스페이스, `aws configure sso`·`sso-admin`·`sso-oidc` CLI, `AWSSSO`·`AWSIdentitySync` 접두사 관리형 정책, 그리고 **문서 슬러그도 `singlesignon/`**입니다. 슬러그를 보고 구문서로 오판하지 않습니다.

#### 1-3. Amazon Cognito — 공식이 두 질문으로 가른다

| 질문 | 구성요소 | 하는 일 |
|---|---|---|
| **이 사용자는 누구인가**(인증) | **사용자 풀** | OIDC 표준 **사용자 디렉터리**. 사용자를 인증하고 앱·API에 **JWT**를 발급합니다. 직접 로그인 · 소셜 제공자 · 엔터프라이즈 SAML·OIDC |
| **이 사용자가 어느 AWS 리소스에 닿나**(권한 부여) | **ID 풀** | 신뢰할 수 있는 토큰을 **임시·제한 권한 AWS 자격 증명**으로 교환합니다. ⚠️ **토큰 없이 게스트 사용자에게도** 제한 권한 자격 증명을 줄 수 있습니다 |

⚠️⚠️ **둘은 서로를 요구하지 않습니다** — 공식 문구가 "Neither component requires the other"입니다. 사용자 풀만으로 내 백엔드에 토큰을 발급할 수 있고, ID 풀만으로 이미 가진 제공자의 토큰을 AWS 자격 증명으로 중개할 수 있습니다.

- ⚠️ **JWT는 AWS 자격 증명이 아닙니다.** "앱 사용자가 S3에 직접 올리게 하라"는 요구에 사용자 풀만 두면 안 되고 **ID 풀**이 필요합니다
- **ID 풀의 권한 부여 축이 둘**입니다 — **역할 기반 액세스 제어**와 **액세스 제어용 속성**(attributes for access control). 후자가 `scs-t4-2` §2의 ABAC로 이어집니다
- **M2M 권한 부여**가 있습니다 — `client_credentials` 그랜트로 사람 없이 앱·서비스·디바이스에 액세스 토큰을 발급합니다
- ⚠️ **Cognito Sync는 유지 관리 상태**입니다(공식 `AWS Lifecycle Changes` 기준 2026-06-30 공지). 사용자 풀·ID 풀은 정상이므로 **기능 단위로 갈라** 기억합니다 — 기기 간 사용자 데이터 동기화가 요구로 나오면 그 기능을 새 설계의 축으로 삼지 않습니다

#### 1-4. MFA — 공식 유형은 셋이고 하나는 종료됐다

공식 IAM MFA 페이지가 **유형 셋**을 열거합니다.

| 유형 | 요점 |
|---|---|
| **패스키와 보안 키** | FIDO 표준·공개 키 암호. **피싱·중간자·재생 공격에 저항**합니다. **기기 바인딩 패스키(보안 키)**와 **동기화 패스키**(자격 증명 관리자 사용)로 나뉩니다 |
| **가상 인증자 애플리케이션** | 휴대폰 등에서 도는 **TOTP** 앱. 한 기기에 여러 토큰을 둘 수 있습니다 |
| **하드웨어 TOTP 토큰** | 6자리 코드를 만드는 물리 장치. ⚠️ **토큰 시드를 AWS와 안전하게 공유한 것만** 작동합니다 — 다른 데서 산 토큰은 IAM에서 쓸 수 없습니다 |

⚠️⚠️ **SMS 문자 기반 MFA는 AWS가 활성화 지원을 종료했습니다.** 공식 페이지가 대안으로 위 세 유형을 지목합니다. 공식 시험 가이드는 `기술 4.1.1`에 "다중 인증(MFA)"이라고만 적으므로, **종료된 유형을 현행 선택지로 착각하기 쉬운 자리**입니다.

- **최대 8개** 등록할 수 있고 **로그인에는 하나**면 됩니다. ⚠️ 추가 MFA를 켜거나 끄려면 **기존 MFA로 먼저 인증**해야 합니다
- ⚠️ **패스키·보안 키는 콘솔에서만 활성화**할 수 있습니다(CLI·API 불가). 활성화 전에 그 기기에 **물리적으로 접근**해야 합니다
- **루트 사용자 MFA는 전 계정 유형에 강제**됩니다(독립 계정·관리 계정·멤버 계정). ⚠️ 루트에 MFA를 켜는 것은 **루트 자격 증명에만** 영향을 주고, IAM 사용자는 각자의 MFA 구성을 따릅니다
- **공식 권고 순서가 분명합니다** — 피싱 저항 MFA(패스키·보안 키)를 먼저 쓰고, 아직 못 쓰면 가상 MFA를 **중간 조치**로 둡니다. 물리 장치가 필요하면 하드웨어 TOTP보다 **보안 키**를 권합니다(배터리가 없고 피싱에 저항하며 한 장치로 여러 사용자를 지원)

#### 1-5. IdP 통합 — 두 표준과 그 경계

임시 자격 증명 쪽 공식 문서가 **ID 연동 두 종류**를 가릅니다. 차이는 **외부 시스템이 어디 있는가**입니다.

- **OIDC 연동** — Login with Amazon·Facebook·Google 등 **OIDC 호환 제공자**로 로그인시킵니다. 모바일·웹 앱에 장기 자격 증명을 심지 않아도 됩니다. ⚠️ **모바일 앱에는 Cognito를 권장**합니다(같은 제공자들을 지원하면서 **게스트 접근**과 **사용자 데이터 마이그레이션**이 더해집니다)
- **SAML 2.0 연동** — 조직 네트워크에서 인증한 사용자에게 **새 AWS ID를 만들지 않고** 접근을 줍니다. 공식이 이를 **단일 로그인 방식**이라 부르고, Microsoft AD FS로 Active Directory를 활용하는 길을 적습니다
- **사용자 지정 연동 브로커** — 조직의 인증 시스템으로 직접 접근을 중개합니다. 콘솔까지 넘기려면 **페더레이션 엔드포인트**(`https://signin.aws.amazon.com/federation`)에 임시 자격 증명을 넘겨 토큰을 받고 그 토큰으로 URL을 만듭니다

⚠️ **STS는 글로벌 서비스이고 기본 엔드포인트는 `https://sts.amazonaws.com`**입니다. 리전 엔드포인트로 호출해 지연을 줄일 수 있고, **어느 리전에서 받은 자격 증명이든 전역에서 동작**합니다.

### 2) 임시 자격 증명을 발급하는 메커니즘 (기술 4.1.2) {#temp}

#### 2-1. STS API 다섯 — 공식 비교표

공식 「Compare AWS STS credentials」 표가 이 기술의 정본입니다. 값을 그대로 옮깁니다.

| API | 누가 호출하나 | 수명 (최소·최대·기본) | **MFA** | **세션 정책** | 결과 자격 증명의 제약 |
|---|---|---|---|---|---|
| **`AssumeRole`** | IAM 사용자 또는 임시 자격 증명을 가진 IAM 역할 | 15분 · **역할의 최대 세션 기간 설정** · 1시간 | **예** | 예 | `GetFederationToken`·`GetSessionToken` 호출 불가 |
| **`AssumeRoleWithSAML`** | 누구나(알려진 IdP의 SAML 응답 필요) | 15분 · 최대 세션 기간 설정 · 1시간 | 아니오 | 예 | 위와 같음 |
| **`AssumeRoleWithWebIdentity`** | 누구나(OIDC 호환 JWT 필요) | 15분 · 최대 세션 기간 설정 · 1시간 | 아니오 | 예 | 위와 같음 |
| **`GetFederationToken`** | IAM 사용자 또는 **루트 사용자** | IAM 사용자 15분 · **36시간** · 12시간 / 루트 15분 · **1시간** · 1시간 | 아니오 | 예 | CLI·API로 **IAM 작업 호출 불가**(콘솔 세션은 예외) · `GetCallerIdentity` 외 STS 작업 불가 · **콘솔 SSO 허용** |
| **`GetSessionToken`** | IAM 사용자 또는 루트 사용자 | 위와 같음 | **예** | **아니오** | **MFA 정보를 넣지 않으면 IAM API 호출 불가** · `AssumeRole`·`GetCallerIdentity` 외 STS 작업 불가 · **콘솔 SSO 불가** |

이 표에서 시험이 노리는 자리는 넷입니다.

1. ⚠️⚠️ **MFA를 받는 것은 `AssumeRole`과 `GetSessionToken` 둘뿐**입니다. "SAML 연동 세션에 MFA 조건을 걸어 민감 API를 보호하라"를 `AssumeRoleWithSAML`로 풀면 틀립니다
2. ⚠️⚠️ **세션 정책을 받지 못하는 것은 `GetSessionToken` 하나**입니다. 반대로 **`GetFederationToken`은 세션 정책을 반드시 전달해야** 합니다(인라인 1개 또는 관리형 ARN 최대 10개)
3. ⚠️ **`AssumeRole` 계열의 상한은 고정값이 아니라 역할의 설정값**입니다. "AssumeRole은 최대 1시간"은 **기본값**을 상한으로 오해한 서술입니다
4. ⚠️ **루트 사용자의 임시 자격 증명은 최대 1시간**입니다

세션 자체에 대한 사실도 둘 기억합니다.

- 결과는 **액세스 키 ID·비밀 키·세션 토큰**이고, 직접 HTTPS 요청을 서명할 때는 **`X-Amz-Security-Token` 헤더 또는 쿼리 문자열 파라미터**로 세션 토큰을 넘깁니다(둘 중 하나에만 넣습니다)
- ⚠️ **세션 토큰 크기를 가정하지 말라고 공식이 경고**합니다 — 일반적으로 4,096바이트보다 작지만 고정이 아닙니다
- 임시 자격 증명은 **연장·갱신할 수 없습니다.** 만료되면 새로 받아야 합니다

#### 2-2. 콘솔 SSO가 되는 쪽과 안 되는 쪽

표의 마지막 열이 가장 자주 함정으로 쓰입니다.

- **`GetFederationToken`으로 받은 자격 증명은 콘솔 SSO에 쓸 수 있습니다** — 페더레이션 엔드포인트에 넘겨 로그인 URL을 만드는 길이 열립니다
- ⚠️⚠️ **`GetSessionToken`으로 받은 자격 증명은 페더레이션 SSO 엔드포인트에 넘길 수 없습니다.** "MFA로 받은 세션 토큰으로 콘솔 로그인 URL을 만든다"는 설계가 성립하지 않습니다

그리고 진단에 쓰는 예외가 하나 있습니다.

> ⚠️ **`GetCallerIdentity`는 권한이 필요 없습니다.** 공식이 "No permissions are required to perform this operation"이라 적고, **관리자가 `sts:GetCallerIdentity`를 명시적으로 거부해도 호출됩니다**(거부됐을 때 돌려주는 정보가 같기 때문입니다). 그래서 "지금 내가 어떤 보안 주체인가"는 **거부가 쏟아지는 상황에서도 확인할 수 있습니다.**

#### 2-3. S3 미리 서명된 URL — 만료가 두 값 중 먼저 오는 쪽

기본적으로 S3 객체는 비공개이고 소유자만 접근합니다. 미리 서명된 URL은 **생성자의 자격 증명으로 서명해** 한시적 접근을 줍니다.

- ⚠️⚠️ **URL은 생성자의 권한으로 동작합니다** — "The credentials used by the presigned URL are those of the AWS IAM principal who generated the URL." 받는 사람은 **AWS 자격 증명이 없어도** 됩니다. 공식이 이를 **소유자 토큰(bearer token)**이라 부르고 **적절히 보호하라고** 경고합니다
- **다운로드만이 아닙니다** — `PUT`으로 업로드도 됩니다. ⚠️ 같은 키의 객체가 이미 있으면 **덮어씁니다**
- **만료 전까지 여러 번 쓸 수 있습니다**

**만료 규칙이 이 절의 핵심입니다.**

| 무엇으로 만드나 | 설정 가능 범위 |
|---|---|
| S3 콘솔 | **1분 ~ 12시간**(객체 최대 5 TB) |
| AWS CLI · SDK | **최대 7일**(`--expires-in` 초 단위) |

⚠️⚠️ **그런데 실제 만료는 「설정값」과 「서명에 쓴 자격 증명의 수명」 중 먼저 오는 쪽입니다.**

| 서명에 쓴 자격 증명 | 실제 수명 |
|---|---|
| **IAM 사용자**(SigV4) | 최대 **7일** |
| **IAM 역할 자격 증명** | **역할 세션이 끝날 때** — 더 긴 만료를 적어도 그렇습니다(`AssumeRole` 기본 1시간) |
| **EC2 인스턴스 프로파일** | 메타데이터 자격 증명 교체 주기 — **약 6시간**이 최대 |
| **STS 임시 자격 증명** | 그 임시 자격 증명의 수명만큼 |

그리고 ⚠️ **자격 증명이 취소·삭제·비활성화되면 URL도 즉시 죽습니다.** "URL 만료를 7일로 적었는데 한 시간 뒤에 끊긴다"는 전형적인 문항이 여기서 나옵니다 — Lambda나 ECS 작업처럼 **역할로 도는 코드가 URL을 만든 경우**입니다.

⚠️ **만료 판정 시점도 공식이 적습니다** — S3는 **HTTP 요청 시점**에 만료를 확인합니다. 만료 직전에 큰 파일 다운로드를 시작하면 **중간에 만료돼도 그 다운로드는 계속**되지만, 연결이 끊겨 **재시작하면 실패**합니다.

**제한 수단 둘**을 기억합니다.

- **`s3:signatureAge` 조건** — 버킷 정책·액세스 포인트 정책에서 서명 나이를 제한합니다(예: 600000밀리초 = 10분 초과 요청 거부)
- **네트워크 경로 제한** — IAM 보안 주체 쪽이나 버킷 쪽에 조건을 걸어 특정 네트워크에서만 쓰게 합니다. **퍼블릭 엔드포인트면 `aws:SourceIp`**, **VPC 엔드포인트 경유면 `aws:SourceVpc`·`aws:SourceVpce`**입니다

### 3) 인증 문제를 해결한다 (기술 4.1.3) {#troubleshoot}

#### 3-1. 메시지부터 읽는다

공식 접근 거부 문제 해결 페이지가 **두 가지 거부**를 가릅니다.

- **명시적 거부** — 그 작업에 대한 `Deny` 문장이 정책에 있습니다
- **암시적 거부** — 적용되는 `Deny`도 없고 **적용되는 `Allow`도 없습니다.** IAM은 기본 거부이므로 허용이 없으면 거부됩니다

⚠️⚠️ **오류 메시지를 전부라고 믿지 않습니다.** 공식이 두 가지 한계를 직접 적습니다.

- **같은 유형의 정책 여럿이 거부하면 평가된 정책 개수를 적지 않습니다**
- **여러 정책 유형이 거부하면 AWS는 그중 하나만 메시지에 넣습니다**

즉 **메시지가 가리킨 정책을 고쳐도 다른 유형이 여전히 막고 있을 수 있습니다.** 공식 페이지의 오류 예시 자체가 **여덟 정책 유형**(SCP·RCP·VPC 엔드포인트 정책·권한 경계·세션 정책·리소스 기반 정책·역할 신뢰 정책·ID 기반 정책) × 명시·암시로 나뉘어 있습니다. 어느 유형이 걸렸는지 가르는 연습은 `scs-t4-2` §3·§4가 이어받습니다.

비자명한 진단 사실 셋을 더 기억합니다.

- ⚠️⚠️ **조건 키 이름은 대소문자를 구분하지 않습니다.** `foo`를 검사하는 조건이 `foo`·`Foo`·`FOO`에 모두 매칭되므로, **대소문자만 다른 키-값 쌍을 함께 넘기면 예상치 못하게 거부**됩니다
- ⚠️ **임시 자격 증명으로 거부가 날 때는 만료부터 확인합니다.** 그리고 임시 자격 증명의 권한은 **맡은 역할에 부여된 것으로 제한**되며, 관리자나 브로커가 **세션 정책을 함께 넘겼을 수 있습니다**
- ⚠️ **VPC 엔드포인트 정책 때문에 거부됐는데 CloudTrail에 안 남는 경우가 있습니다** — 엔드포인트 소유 계정이 호출 계정이나 대상 역할 계정과 다를 때입니다

#### 3-2. CloudTrail에서 무엇을 보는가

공식 CloudTrail 레코드 참조에서 인증 추적에 쓰는 필드는 정해져 있습니다.

| 필드 | 무엇을 알려주나 |
|---|---|
| **`userIdentity`** | 요청을 한 **IAM ID 정보**. 항상 존재합니다 |
| **`errorCode` · `errorMessage`** | 오류 코드와 설명. ⚠️ **권한 부여 실패 메시지가 여기 담깁니다** |
| `eventSource` · `eventName` | 어느 서비스의 어느 작업이었나 |
| `sourceIPAddress` | 요청이 온 IP. ⚠️ **콘솔에서 비롯된 작업은 콘솔 웹 서버가 아니라 그 고객 리소스의 주소**가 기록됩니다 |
| `userAgent` | 콘솔·SDK·CLI 등 요청 수단(최대 1 KB, 초과분은 잘립니다) |

⚠️ **VPC 엔드포인트 정책 위반이면 `errorCode`가 `VpceAccessDenied`**입니다(네트워크 활동 이벤트). 정책 유형을 코드만으로 짚을 수 있는 드문 경우입니다.

#### 3-3. 권한 세트 — 그리고 권한 세트로 안 되는 것

공식 기술 4.1.3이 **"IAM Identity Center 권한 세트"**를 문제 해결 수단으로 듭니다. 동작을 알면 어디가 깨지는지 보입니다.

- **권한 세트는 하나 이상의 IAM 정책을 모은 템플릿**입니다. 할당하면 Identity Center가 **각 대상 계정에 자기가 통제하는 IAM 역할을 만들고** 그 정책들을 붙입니다. 권한 세트를 수정하면 **해당 역할·정책이 함께 갱신**됩니다
- ⚠️ **조직 인스턴스에 「다중 계정 권한」이 켜져 있어야** 권한 세트가 동작합니다(조직 인스턴스를 만들면 기본으로 켜집니다). 꺼져 있으면 **설정에서 켜거나 `UpdateInstance` API**를 씁니다
- 권한 세트에는 AWS 관리형 정책·고객 관리형 정책·인라인 정책·**직무별 AWS 관리형 정책**을 넣을 수 있고, **관리형 정책 하나를 권한 경계로** 지정할 수도 있습니다

⚠️⚠️ **권한 세트가 못 하는 것이 공식 페이지에 적혀 있습니다** — **사용자 지정 신뢰 정책 · 역할 태그 · 구성 가능한 역할 경로**가 필요하면 권한 세트로는 안 되고 **IAM의 「계정 액세스 관리자」**를 씁니다. 그 기능은 **이미 있는 IAM 역할**을 Identity Center 사용자·그룹에 할당하며, 권한 세트와 **함께 쓸 수도** 있습니다.

> 「구성 가능한 역할 경로」가 여기 등장하는 것이 중요합니다 — **IAM 경로**는 `scs-t4-2` §1-3의 소재이고, 권한 세트가 만드는 역할에는 그 경로를 내가 정할 수 없습니다. 작업 4.1과 4.2가 맞물리는 지점입니다.

#### 3-4. AWS Directory Service — 세 유형과 MFA

공식 기술 4.1.3이 Directory Service도 듭니다. **디렉터리 유형 셋**을 가르는 축은 **"실제 Active Directory가 필요한가"**입니다.

| 유형 | 무엇인가 | MFA |
|---|---|---|
| **AWS Managed Microsoft AD** | AWS가 클라우드에서 관리하는 **실제 Windows Server AD**. Standard(약 30,000 객체)·Enterprise(약 500,000 객체) 에디션 | **가능** |
| **AD Connector** | 기존 온프레미스 AD로 요청을 **전달하는 프록시**. 디렉터리 동기화나 페더레이션 인프라가 필요 없습니다 | **가능** — 기존 **RADIUS 기반 MFA 인프라**에 연결합니다 |
| **Simple AD** | **Samba 4** 기반 AD 호환 디렉터리. 기본 기능(사용자·그룹·도메인 조인·Kerberos SSO·그룹 정책)만 | **불가** |

⚠️⚠️ **Simple AD는 유지 관리 상태입니다**(공식 `AWS Lifecycle Changes` 기준 2026-06-30 공지). ⚠️ **서비스 소개 페이지에는 그 상태가 적혀 있지 않고** 세 선택지 중 하나로 그대로 소개되므로, 상태는 수명 주기 목록에서 따로 확인해야 합니다.

그리고 **Simple AD가 지원하지 않는 것**이 공식에 명시돼 있습니다 — **MFA · 신뢰 관계 · DNS 동적 업데이트 · 스키마 확장 · LDAPS 통신 · PowerShell AD cmdlet · FSMO 역할 전송**이고 **RDS for SQL Server와도 호환되지 않습니다.** 요구에 이 중 하나가 있으면 **AWS Managed Microsoft AD**입니다.

- ⚠️ **AD Connector도 RDS for SQL Server와 호환되지 않습니다.** "온프레미스 AD 자격 증명으로 RDS SQL Server에 접근"은 **Managed Microsoft AD**입니다
- **Managed Microsoft AD는 규정 준수를 켜면 HIPAA·PCI DSS 대상 애플리케이션에 승인**됩니다. 스키마 확장·암호 정책 관리·**SSL/TLS 기반 보안 LDAP**도 이쪽 기능입니다

## ✍️ 시험 포인트

- **"여러 AWS 계정에 직무별 접근을 중앙에서"는 조직 인스턴스 + 권한 세트다** — 계정 인스턴스는 계정 액세스를 관리하지 못합니다
- **"사용자 지정 신뢰 정책·역할 태그·역할 경로가 필요하다"는 권한 세트가 아니라 계정 액세스 관리자다**
- **"앱 사용자에게 S3 직접 접근"은 ID 풀이다** — 사용자 풀의 JWT는 AWS 자격 증명이 아닙니다
- **"인증되지 않은 게스트에게도 제한 권한을"은 ID 풀이다**
- **"피싱 저항 MFA"는 패스키·보안 키다** — TOTP 계열보다 강하다고 공식이 적습니다
- **"SMS로 MFA를 켜라"는 지금 성립하지 않는다** — 활성화 지원이 종료됐습니다
- **"MFA 조건이 걸린 세션이 필요하다"는 `AssumeRole` 또는 `GetSessionToken`이다**
- **"세션 정책으로 권한을 좁혀라"에 `GetSessionToken`은 안 된다**
- **"임시 자격 증명으로 콘솔 로그인 URL"은 `GetFederationToken`이다** — `GetSessionToken`은 불가합니다
- **"AssumeRole은 최대 1시간"은 틀렸다** — 1시간은 기본값이고 상한은 역할의 최대 세션 기간 설정입니다
- **"미리 서명된 URL이 적은 시간보다 먼저 죽는다"는 서명에 쓴 자격 증명의 수명이다**
- **"7일짜리 URL이 필요하다"는 IAM 사용자 자격 증명으로 서명해야 한다** — 역할·인스턴스 프로파일로는 못 미칩니다
- **"미리 서명된 URL을 특정 네트워크에서만"은 `aws:SourceIp` 또는 `aws:SourceVpc`·`aws:SourceVpce`다**
- **"거부 메시지의 정책을 고쳤는데 여전히 막힌다"는 다른 정책 유형이다** — 메시지는 유형 하나만 적습니다
- **"MFA·LDAPS·스키마 확장이 필요하다"는 Simple AD가 아니다**
- **"온프레미스 AD를 그대로 쓰고 싶다"는 AD Connector, "RDS SQL Server까지"는 Managed Microsoft AD다**

## ⚠️ 흔한 함정 {#pitfalls}

- ❌ "계정 인스턴스에서도 권한 세트를 쓸 수 있다" → **조직 인스턴스 전용 기능**입니다
- ❌ "계정마다 IdP를 연동해야 한다" → 공식은 **한 번만 연동하고 인증서도 하나만 관리**한다고 적습니다
- ❌ "Identity Center를 쓰려면 기존 IAM 워크플로를 전부 바꿔야 한다" → **바꿀 필요가 없다**고 공식이 적습니다
- ❌ "문서 슬러그가 `singlesignon/`이니 구문서다" → 2022년 개명 후에도 **레거시 네임스페이스와 슬러그가 그대로**입니다
- ❌ "사용자 풀과 ID 풀은 함께 써야 한다" → **서로를 요구하지 않습니다**
- ❌ "기기 간 사용자 데이터 동기화를 Cognito Sync로 새로 설계한다" → **유지 관리 상태**입니다
- ❌ "SMS 문자 MFA가 가장 간단한 2단계다" → **활성화 지원이 종료**됐습니다
- ❌ "보안 키는 CLI로도 등록할 수 있다" → **콘솔에서만** 가능하고 기기에 물리적으로 접근해야 합니다
- ❌ "아무 데서 산 하드웨어 TOTP 토큰을 쓴다" → **토큰 시드를 AWS와 공유한 것만** 작동합니다
- ❌ "루트에 MFA를 켜면 IAM 사용자도 보호된다" → **루트 자격 증명에만** 적용됩니다
- ❌ "`AssumeRoleWithSAML`에 MFA 정보를 넣는다" → **MFA를 지원하지 않습니다**
- ❌ "`GetFederationToken`은 세션 정책이 선택이다" → **반드시 전달**해야 합니다
- ❌ "루트 사용자도 36시간 세션을 받는다" → 루트는 **최대 1시간**입니다
- ❌ "임시 자격 증명을 갱신해서 더 쓴다" → **연장·갱신 불가**이고 새로 받아야 합니다
- ❌ "URL 만료를 길게 적으면 그만큼 산다" → **자격 증명 수명이 먼저 끝나면 그때 죽습니다**
- ❌ "만료되면 진행 중인 다운로드도 끊긴다" → 시작된 다운로드는 **계속**되고, 끊겨서 재시작하면 실패합니다
- ❌ "거부 메시지에 적힌 정책 하나만 보면 된다" → **여러 유형이 거부하면 하나만 적습니다**
- ❌ "조건 키는 대소문자를 구분하니 `Env`와 `env`를 따로 쓴다" → **이름은 구분하지 않아** 예상치 못한 거부가 납니다
- ❌ "Simple AD로 LDAPS와 스키마 확장을 쓴다" → **둘 다 미지원**입니다

## 🧪 자가 점검

**Q1.** 보안팀이 "직원이 12개 AWS 계정에 직무별로 로그인하게 하고, 역할마다 사용자 지정 신뢰 정책과 역할 태그를 붙여라"라고 요구합니다. IAM Identity Center 권한 세트로 전부 구현할 수 있습니까? (→ 1-2·3-3 권한 세트)

<details><summary>정답 보기</summary>

**다중 계정 로그인은 권한 세트로 되지만, 사용자 지정 신뢰 정책과 역할 태그는 안 됩니다.**

- 권한 세트는 **조직 인스턴스**에서 동작하고(계정 인스턴스는 AWS 계정 액세스를 관리하지 못합니다), 할당하면 각 계정에 **Identity Center가 통제하는 IAM 역할**이 만들어집니다
- ⚠️ 공식 페이지가 한계를 직접 적습니다 — **사용자 지정 신뢰 정책 · 역할 태그 · 구성 가능한 역할 경로**가 필요하면 **IAM의 「계정 액세스 관리자」**를 씁니다. 그 기능은 **이미 있는 IAM 역할**을 Identity Center 사용자·그룹에 할당하므로 IAM 역할의 전체 기능을 그대로 쓸 수 있습니다
- 둘을 **함께** 쓸 수도 있습니다 — 공통 직무는 권한 세트로, 특수 요건이 있는 역할만 계정 액세스 관리자로 할당합니다

⚠️ 그리고 권한 세트가 동작하려면 조직 인스턴스에 **「다중 계정 권한」이 켜져** 있어야 합니다(기본은 켜짐, 꺼졌다면 설정 또는 `UpdateInstance`).
</details>

**Q2.** 모바일 앱이 Google 로그인으로 사용자를 인증한 뒤, 사용자별 S3 접두사에 사진을 직접 업로드하게 하려 합니다. Cognito 사용자 풀만 만들면 됩니까? (→ 1-3 Cognito)

<details><summary>정답 보기</summary>

**안 됩니다. ID 풀이 필요합니다.**

- **사용자 풀**은 "이 사용자는 누구인가"에 답하고 앱·API에 **JWT**를 발급합니다. ⚠️ **JWT는 AWS 자격 증명이 아니므로** 그것만으로 S3를 직접 호출할 수 없습니다
- **ID 풀**이 신뢰할 수 있는 토큰을 **임시·제한 권한 AWS 자격 증명**으로 교환합니다. 이 교환 뒤에 S3 직접 호출이 가능합니다
- 사용자별로 접두사를 가르는 것은 ID 풀의 **역할 기반 액세스 제어** 또는 **액세스 제어용 속성**으로 합니다(후자가 ABAC이고 `scs-t4-2` §2의 소재입니다)
- ⚠️ 두 구성요소는 **서로를 요구하지 않습니다** — 이미 Google 토큰을 쓰고 있다면 **ID 풀만** 두고 그 토큰을 중개하게 할 수도 있습니다
</details>

**Q3.** Lambda 함수가 S3 객체의 미리 서명된 URL을 만들어 고객에게 메일로 보냅니다. 만료를 7일(604800초)로 지정했는데 고객들이 "한 시간쯤 뒤부터 링크가 죽는다"고 합니다. 원인과 해결은? (→ 2-3 미리 서명된 URL)

<details><summary>정답 보기</summary>

**Lambda가 역할 자격 증명으로 서명했기 때문입니다. URL은 그 역할 세션이 끝날 때 죽습니다.**

- 공식이 명시합니다 — **"IAM role credentials: the presigned URL expires when the role session expires, even if you specify a longer expiration time."** `AssumeRole` 세션의 기본 수명이 **1시간**이라 증상과 맞습니다
- 일반 규칙은 **"설정한 만료"와 "서명에 쓴 자격 증명의 수명" 중 먼저 오는 쪽**입니다. 그리고 그 자격 증명이 **취소·삭제·비활성화되면 URL도 죽습니다**
- **7일을 실제로 보장하려면 IAM 사용자 자격 증명(SigV4)으로 서명**해야 합니다. 역할·EC2 인스턴스 프로파일(최대 약 6시간)로는 7일에 닿지 못합니다

⚠️ 장기 자격 증명을 쓰는 것은 그 자체로 위험을 늘리므로, 실무에서는 **짧은 URL을 필요할 때 다시 발급**하는 설계가 보통 더 낫습니다. 시험은 **"왜 먼저 죽었나"**를 묻습니다.
</details>

**Q4.** 보안팀이 "민감 API 호출은 MFA로 인증한 세션에서만 허용하고, 그 세션의 권한을 세션 정책으로 더 좁혀라"라고 요구합니다. `GetSessionToken`으로 받은 자격 증명으로 구현할 수 있습니까? (→ 2-1 STS 비교표)

<details><summary>정답 보기</summary>

**MFA는 되지만 세션 정책은 안 됩니다. 두 요구를 함께 만족하는 것은 `AssumeRole`입니다.**

- 공식 비교표에서 **MFA를 지원하는 것은 `AssumeRole`과 `GetSessionToken` 둘**이고, **세션 정책을 지원하지 않는 것은 `GetSessionToken` 하나**입니다
- 따라서 **MFA + 세션 정책**이 동시에 필요하면 `AssumeRole`입니다. `AssumeRole`은 인라인 세션 정책 1개(`Policy`) 또는 관리형 정책 ARN 최대 10개(`PolicyArns`)를 받습니다
- ⚠️ 덤으로 `GetSessionToken` 자격 증명은 **MFA 정보를 넣지 않으면 IAM API를 호출하지 못하고**, **콘솔 SSO에도 쓸 수 없습니다**

⚠️ 세션 정책은 **권한을 넓히지 못합니다** — 결과 권한은 역할의 ID 기반 정책과 세션 정책의 **교집합**입니다(자세한 겹침 규칙은 `scs-t4-2` §3).
</details>

**Q5.** 개발자가 "EC2에서 도는 앱이 `s3:PutObject`에서 접근 거부를 받는다. 역할의 ID 기반 정책에는 분명히 허용이 있다"고 보고합니다. 다음에 무엇을 확인합니까? (→ 3-1 거부 진단)

<details><summary>정답 보기</summary>

**거부 메시지가 가리킨 정책 유형을 먼저 보고, 그것이 전부가 아니라고 전제합니다.**

- 공식이 두 한계를 적습니다 — **같은 유형 여럿이 거부하면 개수를 알려주지 않고**, **여러 유형이 거부하면 그중 하나만 메시지에 넣습니다.** 즉 메시지의 정책을 고쳐도 다른 유형이 남아 있을 수 있습니다
- 확인 순서로 쓸 수 있는 것들 —
  - **임시 자격 증명 만료**(EC2 인스턴스 프로파일 자격 증명은 주기적으로 교체됩니다)
  - **권한 경계**: ID 기반 정책이 허용해도 권한 경계가 허용하지 않으면 거부됩니다
  - **세션 정책**: 관리자나 브로커가 세션 정책을 함께 넘겼을 수 있습니다
  - **리소스 기반 정책**: 다른 계정의 버킷이면 **ID 기반과 리소스 기반이 모두** 허용해야 합니다
  - **조건 키의 대소문자**: 이름은 대소문자를 구분하지 않으므로 **대소문자만 다른 키를 함께 넘기면** 예상치 못하게 거부됩니다
- CloudTrail에서는 **`userIdentity`로 실제 호출 주체**를, **`errorCode`·`errorMessage`로 권한 부여 실패 내용**을 읽습니다

⚠️ **VPC 엔드포인트 정책 위반은 CloudTrail에 안 남는 경우가 있습니다**(엔드포인트 소유 계정이 호출 계정·대상 역할 계정과 다를 때). 네트워크 활동 이벤트로 남으면 `errorCode`가 **`VpceAccessDenied`**입니다.
</details>

**Q6.** 온프레미스 Active Directory를 그대로 쓰면서, 클라우드의 RDS for SQL Server에 AD 자격 증명으로 인증하고 LDAPS와 스키마 확장도 필요합니다. Simple AD로 충분합니까? (→ 3-4 Directory Service)

<details><summary>정답 보기</summary>

**충분하지 않습니다. AWS Managed Microsoft AD가 필요합니다.**

- 공식이 **Simple AD가 지원하지 않는 것**을 열거합니다 — **MFA · 신뢰 관계 · DNS 동적 업데이트 · 스키마 확장 · LDAPS 통신 · PowerShell AD cmdlet · FSMO 역할 전송**이고 **RDS for SQL Server와 호환되지 않습니다.** 요구 세 가지 중 둘이 바로 걸립니다
- ⚠️ **AD Connector도 RDS for SQL Server와 호환되지 않습니다.** "기존 온프레미스 AD를 그대로"라는 말만 보고 AD Connector를 고르면 RDS 요건에서 틀립니다
- **AWS Managed Microsoft AD**는 실제 Windows Server AD이고, **스키마 확장·암호 정책 관리·SSL/TLS 기반 보안 LDAP**을 제공하며 **RDS for SQL Server를 지원**합니다. 온프레미스 AD는 **신뢰 관계**로 연결해 기존 자격 증명을 쓸 수 있습니다

⚠️ 그리고 **Simple AD는 유지 관리 상태**입니다(2026-06-30 공지) — 서비스 소개 페이지에는 그 상태가 적혀 있지 않으므로 새 설계의 축으로 삼지 않습니다.
</details>

### 📌 출처

1. What is IAM Identity Center? — `docs.aws.amazon.com/singlesignon/latest/userguide/what-is.html` (2026-11-09 확인)
2. Manage AWS accounts with permission sets — `docs.aws.amazon.com/singlesignon/latest/userguide/permissionsetsconcept.html` (2026-11-09 확인)
3. What is Amazon Cognito? — `docs.aws.amazon.com/cognito/latest/developerguide/what-is-amazon-cognito.html` (2026-11-09 확인)
4. AWS Multi-factor authentication in IAM — `docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_mfa.html` (2026-11-09 확인)
5. Temporary security credentials in IAM — `docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp.html` (2026-11-09 확인)
6. Compare AWS STS credentials — `docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_sts-comparison.html` (2026-11-09 확인)
7. Request temporary security credentials — `docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_request.html` (2026-11-09 확인)
8. Use temporary credentials with AWS resources — `docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_use-resources.html` (2026-11-09 확인)
9. Download and upload objects with presigned URLs — `docs.aws.amazon.com/AmazonS3/latest/userguide/using-presigned-url.html` (2026-11-09 확인)
10. Sharing objects with presigned URLs — `docs.aws.amazon.com/AmazonS3/latest/userguide/ShareObjectPreSignedURL.html` (2026-11-09 확인)
11. What is AWS Directory Service? — `docs.aws.amazon.com/directoryservice/latest/admin-guide/what_is.html` (2026-11-09 확인)
12. Troubleshoot access denied error messages — `docs.aws.amazon.com/IAM/latest/UserGuide/troubleshoot_access-denied.html` (2026-11-09 확인)
13. CloudTrail record contents for management, data, and network activity events — `docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-event-reference-record-contents.html` (2026-11-09 확인)
14. AWS Lifecycle Changes — `docs.aws.amazon.com/general/latest/gr/service-lifecycle.html` (2026-11-09 확인)
