---
examGuideTaskId: scs-t3-1
certCode: SCS-C03
domain: 3
domainName: 인프라 보안
domainWeightPct: 18
title: 네트워크 엣지 보안 (전략 선택·엣지 보호 구현·지리와 속도 제한·타사 통합)
coversTasks:
  - "3.1"
sources:
  - title: What are AWS WAF, AWS Shield Advanced, AWS Shield network security director and AWS Firewall Manager?
    url: https://docs.aws.amazon.com/waf/latest/developerguide/what-is-aws-waf.html
  - title: Baseline rule groups
    url: https://docs.aws.amazon.com/waf/latest/developerguide/aws-managed-rule-groups-baseline.html
  - title: Using managed rule groups in AWS WAF
    url: https://docs.aws.amazon.com/waf/latest/developerguide/waf-managed-rule-groups.html
  - title: AWS Marketplace rule groups
    url: https://docs.aws.amazon.com/waf/latest/developerguide/marketplace-rule-groups.html
  - title: Using rate-based rule statements in AWS WAF
    url: https://docs.aws.amazon.com/waf/latest/developerguide/waf-rule-statement-type-rate-based.html
  - title: Aggregating rate-based rules in AWS WAF
    url: https://docs.aws.amazon.com/waf/latest/developerguide/waf-rule-statement-type-rate-based-aggregation-options.html
  - title: Geographic match rule statement
    url: https://docs.aws.amazon.com/waf/latest/developerguide/waf-rule-statement-type-geo-match.html
  - title: AWS WAF in AWS GovCloud (US)
    url: https://docs.aws.amazon.com/govcloud-us/latest/UserGuide/govcloud-waf.html
  - title: Restrict the geographic distribution of your content
    url: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/georestrictions.html
  - title: Add custom headers to origin requests
    url: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/add-origin-custom-headers.html
  - title: Security checklist for marketplace distributions
    url: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/ecommerce-security-checklist.html
  - title: Using cross-origin resource sharing (CORS)
    url: https://docs.aws.amazon.com/AmazonS3/latest/userguide/cors.html
  - title: AWS IoT Core policy variables
    url: https://docs.aws.amazon.com/iot/latest/developerguide/iot-policy-variables.html
  - title: Thing policy variables
    url: https://docs.aws.amazon.com/iot/latest/developerguide/thing-policy-variables.html
  - title: Security Hub and the OCSF
    url: https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-ocsf.html
  - title: Collecting data from custom sources in Security Lake
    url: https://docs.aws.amazon.com/security-lake/latest/userguide/custom-sources.html
  - title: Services in Maintenance — App Runner 상태
    url: https://docs.aws.amazon.com/general/latest/gr/maintenance_services.html
lastVerified: 2026-11-12
---

# 네트워크 엣지 보안 (전략 선택·엣지 보호 구현·지리와 속도 제한·타사 통합)

> **커버하는 공식 Task** — SCS-C03 · 도메인 3 「인프라 보안」(18%) · **작업 3.1 네트워크 엣지 서비스의 보안 제어 설계, 구현 및 문제 해결** (`scs-t3-1`)
> 이 문서는 위 한 작업에 1:1로 매핑되고 공식 기술 4개(3.1.1~3.1.4)를 모두 덮습니다. 도메인 3은 **18%로 두 번째로 큰 도메인**이고, 작업이 셋(엣지·컴퓨팅·네트워크)입니다. 이 작업은 그중 **요청이 AWS에 들어오는 가장 바깥 지점**을 다룹니다.

> ⚠️ **`기술 3.1.4`는 C03에서 신설된 기술입니다**("AWS 엣지 서비스 및 타사 서비스와의 통합 구성 — OCSF 형식으로 데이터 수집, 타사 WAF 규칙 사용"). 4절이 그 자리이고, 둘 다 **「AWS가 대신 해 주지 않는 부분」이 갈림길**입니다.

> ⚠️ 공식 WAF 문서가 **「보호 팩(protection pack)」**이라는 새 콘솔 용어를 web ACL과 나란히 적기 시작했습니다(2026-11-08 실측). 이 문서는 **공식 표기를 따라 `보호 팩(web ACL)`으로 병기**합니다 — 시험장에서 어느 쪽을 봐도 같은 것임을 알아야 합니다.

---

## ✅ 학습 목표 체크리스트

- [ ] 위협의 **계층**에 따라 Shield·WAF·CloudFront 중 무엇이 답인지 가른다
- [ ] 오리진 우회를 막는 **두 층**(커스텀 헤더·관리형 접두사 목록)을 설명한다
- [ ] WAF 관리형 규칙의 **본문 검사 한도**가 리소스 유형마다 다른 것을 안다
- [ ] 지리 차단에서 **CloudFront 기능과 WAF geo match 중 무엇을 쓸지** 판단한다
- [ ] 속도 제한의 **집계 키**와 그 비용·함정을 설명한다
- [ ] 클라이언트 핑거프린팅이 **JA3·JA4**임을 알고 쓸 자리를 안다
- [ ] OCSF를 **두 서비스가 서로 다른 층에서** 쓰는 것을 구분한다
- [ ] 타사(Marketplace) WAF 규칙의 **구독 단위와 테스트 수단**을 안다

## 🎯 왜 중요한가

엣지 문항은 **"어느 계층의 공격인가"**를 먼저 묻고, 거기서 틀리면 나머지 보기가 다 그럴듯해 보입니다. L3/L4 범람과 L7 애플리케이션 공격은 **다른 서비스가 막고**, 오리진 우회는 **둘 다 아닌 제3의 설계**가 막습니다.

그리고 Specialty 시험은 **"그 기능을 켜면 다른 기능이 못 보게 된다"**를 좋아합니다. 3절의 CloudFront 지리 제한이 정확히 그 모양이고, 모르면 "지리 + 다른 조건"을 요구하는 지문에서 함정 보기를 고릅니다.

## ⚡ 시험 직전 요약

- **L3/L4 범람은 Shield**, **L7 애플리케이션 공격은 WAF**, **콘텐츠 배포 경계는 CloudFront**입니다
- WAF 관리형 **코어 규칙 세트(CRS)**가 OWASP Top 10 같은 **광범위 웹 취약점**을 덮고 **700 WCU**입니다
- ⚠️⚠️ **본문 검사 한도가 리소스마다 다릅니다** — ALB·AppSync는 **8 KB 고정**, CloudFront·API Gateway·Cognito·App Runner·Verified Access·Bedrock AgentCore Gateway는 **기본 16 KB에 최대 64 KB까지 증가**
- 오리진 우회는 **커스텀 헤더(애플리케이션 계층) + 관리형 접두사 목록(네트워크 계층)**을 함께 씁니다
- ⚠️⚠️ **CloudFront 지리 제한은 차단한 요청을 WAF로 전달하지 않습니다** — 지리 + 다른 조건이 필요하면 **WAF geo match를 쓰고 CloudFront 기능은 쓰지 않습니다**
- ⚠️ WAF geo match는 **국가만 단독 매칭**이 되고 **지역(region)은 라벨 매칭 규칙을 하나 더** 둬야 합니다
- 속도 제한의 기본 집계 키는 **요청 출처 IP**이고, 사용자 지정 키는 **키 하나당 30 WCU**입니다
- ⚠️⚠️ 집계 키에 지정한 **구성 요소가 없는 요청은 평가·제한 대상에서 아예 빠집니다**
- **클라이언트 핑거프린팅은 JA3·JA4**이고 각각 **한 번만** 집계 키로 쓸 수 있습니다
- ⚠️ **Marketplace 타사 규칙은 조직의 각 계정이 따로 구독**해야 하고 **GovCloud(US)에서는 쓸 수 없습니다**

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **보호 팩(protection pack)** | 규칙을 담아 리소스에 연결하는 WAF의 단위. 공식 문서가 **web ACL과 같은 것**으로 병기합니다 |
| **WCU** | Web ACL Capacity Unit. 규칙의 처리 비용 단위이고 **보호 팩마다 상한**이 있습니다 |
| **관리형 규칙 그룹** | AWS 또는 **AWS Marketplace 판매자**가 작성·유지하는 미리 정의된 규칙 묶음 |
| **Count 작업** | 차단하지 않고 **매칭 수만 세는** 규칙 작업. 규칙 도입 전 테스트 수단입니다 |
| **스코프 다운 문장** | 규칙이 추적·제한할 요청 범위를 **좁히는** 중첩 문장 |
| **집계 키(aggregation key)** | 속도 제한이 **무엇을 단위로 셀지** 정하는 기준 |
| **JA3 / JA4 핑거프린트** | TLS 핸드셰이크 특성에서 뽑은 **클라이언트 지문**. 사용자 지정 집계 키로 쓸 수 있습니다 |
| **OCSF** | 개방형 사이버 보안 스키마 프레임워크. **벤더 중립 코어 보안 스키마**이고 저장 형식·수집 방법과 독립입니다 |

## 📖 핵심 개념

### 1) 위협에서 엣지 전략을 고른다 (기술 3.1.1) {#strategy}

#### 1-1. 계층이 먼저다

공식 WAF 소개 페이지가 네 제품을 한 페이지에 두고 역할을 가릅니다.

| 위협 | 답 | 이유 |
|---|---|---|
| SYN/UDP 범람 등 **L3/L4** | **Shield**(Standard 자동 · Advanced 구독) | 전송·네트워크 계층 범람을 흡수·완화합니다 |
| SQL 주입·XSS·경로 순회 등 **L7** | **AWS WAF** | 요청의 **내용**을 검사합니다 |
| 봇·계정 탈취·계정 생성 사기 | **WAF의 전용 관리형 규칙 그룹** | ⚠️ 셋 다 **추가 요금**이 붙습니다 |
| 오리진 직접 접근 | **CloudFront + 커스텀 헤더/접두사 목록** | WAF·Shield로는 못 막습니다(§2-1) |
| 조직 전체 규칙 일괄 적용 | **AWS Firewall Manager** | 계정마다 손으로 붙이지 않습니다 |

⚠️ **같은 페이지가 `AWS Shield network security director`를 Shield Advanced와 별개 제품으로 소개합니다.** 공식 시험 가이드는 `Shield Advanced`만 적으므로(`기술 2.1.2`·`3.1.2`) **둘을 섞어 기억하지 않습니다.**

#### 1-2. WAF가 보호할 수 있는 리소스는 정해져 있다

공식 목록은 **CloudFront 배포 · API Gateway REST API · Application Load Balancer · AppSync GraphQL API · Cognito 사용자 풀 · App Runner 서비스 · Amazon Bedrock AgentCore Gateway · AWS Verified Access 인스턴스 · AWS Amplify**입니다.

⚠️ **`Bedrock AgentCore Gateway`와 `Amplify`가 목록에 있다는 것이 중요합니다** — 생성형 AI 애플리케이션의 엣지 보호(`기술 3.2.7`)가 **새 서비스가 아니라 기존 WAF로** 이어집니다. 거꾸로 **Network Load Balancer·EC2 인스턴스는 목록에 없습니다** — 그 앞단에 ALB나 CloudFront를 둬야 WAF를 붙일 수 있습니다.

⚠️ WAF의 기본 작업은 **넷**입니다: 지정한 것만 차단 / 지정한 것만 허용 / **Count** / **CAPTCHA·사일런트 챌린지**.

### 2) 엣지 보호 기능을 구현한다 (기술 3.1.2) {#implement}

#### 2-1. CloudFront 헤더 — 오리진 우회를 막는 층

공식 보안 체크리스트가 두 수단을 나란히 적습니다.

1. **커스텀 오리진 헤더** — CloudFront가 모든 요청에 추가하는 헤더(예: `X-Origin-Verify`)를 두고, **ALB나 애플리케이션이 그 헤더가 없는 요청을 거부**합니다. 값은 **Secrets Manager에 두고 주기적으로 교체**합니다.
2. **관리형 접두사 목록** — ALB 보안 그룹의 인바운드를 **CloudFront IP 범위로 제한**합니다(`com.amazonaws.global.cloudfront.origin-facing`).

⚠️⚠️ **두 층은 서로를 대신하지 못합니다.** 접두사 목록은 **네트워크 수준**에서 CloudFront IP만 허용하고, 커스텀 헤더는 **애플리케이션 수준**에서 "그 트래픽이 내 특정 배포에서 왔음"을 확인합니다. 공식 안내가 **둘을 함께 쓰는 것이 가장 강한 오리진 보호**라고 적습니다 — 접두사 목록만 쓰면 **다른 사람의 CloudFront 배포**에서 온 요청도 통과합니다.

⚠️ **위조가 통하지 않는 이유**가 공식 동작에 있습니다 — 지정한 헤더 이름·값이 **뷰어 요청에 이미 있으면 CloudFront가 그 값을 덮어쓰고** 오리진으로 전달합니다. 즉 공격자가 `X-Origin-Verify`를 넣어 보내도 CloudFront를 통과하는 순간 덮어쓰기 됩니다.

⚠️ **CloudFront가 추가할 수 없는 헤더**가 있습니다 — `Host`·`Cookie`·`Range`·`Transfer-Encoding`·`Via`, 조건부 요청 헤더(`If-Match` 등), 그리고 **`X-Amz-`·`X-Edge-`로 시작하는 모든 헤더**입니다.

#### 2-2. ⚠️⚠️ `Authorization` 헤더는 기본적으로 제거된다

CloudFront는 뷰어 요청을 오리진으로 전달할 때 **일부 헤더를 기본적으로 제거하고, `Authorization`이 거기 듭니다.** 전달하려면 세 길이 있습니다 — **캐시 정책으로 캐시 키에 추가**(캐시 키의 모든 헤더는 오리진 요청에 자동 포함) · **오리진 요청 정책에 개별 추가** · **관리형 정책 `Managed-AllViewer`**.

⚠️⚠️ **공식 경고가 보안 함정 그 자체입니다** — `Authorization`을 **캐시 키에 넣지 않고** 전달하면 **CloudFront가 같은 캐시 응답을 인가된 뷰어와 인가되지 않은 뷰어에게 똑같이 줄 수 있습니다.** 오리진이 그 헤더로 접근 제어를 한다면 **캐시 키에 넣거나 캐싱을 끄는 것**이 답입니다.

#### 2-3. AWS WAF 관리형 규칙으로 OWASP Top 10을 덮는다

**코어 규칙 세트(CRS)** — `AWSManagedRulesCommonRuleSet`, **700 WCU**. 공식 설명이 "**OWASP Top 10** 같은 OWASP 발행물이 기술하는 고위험·빈발 취약점을 포함해 광범위한 취약점의 악용을 막는다"이고 **모든 WAF 사용 사례에 고려**하라고 적습니다. 베이스라인 규칙 그룹은 CRS 외에 **관리자 보호**와 **알려진 잘못된 입력**이 있습니다.

규칙 몇 가지가 **값을 그대로 적어** 시험에 나옵니다 — 쿼리 문자열 **2,048바이트**, 쿠키 헤더 **10,240바이트**, 요청 본문 **8 KB(8,192바이트)**, URI 경로 **1,024바이트** 초과를 차단하고, **`User-Agent` 헤더가 없는 요청**을 차단합니다. 그리고 **EC2 메타데이터 탈취(SSRF)**를 본문·쿠키·URI 경로·쿼리 인자 **네 곳**에서 봅니다.

⚠️⚠️ **본문 검사 한도가 리소스 유형마다 다릅니다.**

| 리소스 | 본문 검사 한도 |
|---|---|
| Application Load Balancer · AppSync | **8 KB 고정**(올릴 수 없습니다) |
| CloudFront · API Gateway · Cognito · App Runner · Verified Access · Bedrock AgentCore Gateway | **기본 16 KB**, 보호 팩(web ACL) 설정에서 **최대 64 KB** |

한도를 넘는 부분은 **초과 콘텐츠 처리**가 결정하고, CRS의 본문 규칙은 **`Continue` 옵션**을 씁니다. 즉 **큰 본문의 뒷부분은 검사되지 않을 수 있습니다** — "대용량 업로드 경로의 주입 공격이 탐지되지 않는다"는 지문의 답입니다.

⚠️ 관리형 규칙 그룹은 평가한 요청에 **라벨을 붙이고**, 그 라벨은 **뒤에 실행되는 규칙**이 쓸 수 있으며 **CloudWatch 지표로도 기록**됩니다. 이것이 "관리형 규칙의 특정 규칙만 예외 처리"의 정석 수단입니다.

#### 2-4. AWS IoT 정책 — IAM과 닮았지만 다르다

IoT Core 정책은 `Resource`·`Condition`에서 **정책 변수**를 씁니다. 기본 변수는 **`iot:ClientId`·`aws:SourceIp`·`iot:DomainName`**이고, 사물 정책 변수는 **`iot:Connection.Thing.ThingName`·`ThingTypeName`·`Attributes[속성이름]`·`IsAttached`**입니다.

⚠️⚠️ **와일드카드가 MQTT와 다릅니다.** 정책에서 `*`는 와일드카드이지만 **MQTT의 `+`와 `#`는 리터럴 문자로 취급**됩니다. MQTT 주제 와일드카드를 정책에 그대로 쓰면 의도한 범위가 되지 않습니다.

⚠️⚠️ **사물 정책 변수는 클라이언트 ID가 사물 이름과 정확히 일치해야 해석됩니다.** 비배타적 사물 연결에서는 같은 인증서를 여러 사물에 붙일 수 있으므로, MQTT `Connect` 메시지의 `clientId`가 사물 이름과 같아야 합니다. ⚠️ 인증서가 사물과 연결돼 있지 않으면 **변수가 해석되지 않고 액세스 거부**가 됩니다 — 한 장비의 인증서로 한 장비의 주제만 쓰게 하는 최소 권한 설계의 핵심입니다. 사물의 속성은 **최대 50개**이고 각각이 정책 변수로 쓰입니다.

#### 2-5. Amazon S3 CORS — 켜도 권한은 그대로다

브라우저의 사전 요청(preflight)을 받으면 S3가 버킷의 CORS 구성을 평가해 **맞는 첫 `CORSRule`**을 적용합니다. 매칭 조건은 셋입니다 — 요청의 `Origin`이 **`AllowedOrigins`**에, `Access-Control-Request-Method`가 **`AllowedMethods`**에, `Access-Control-Request-Headers`가 **`AllowedHeaders`**에 들어야 합니다.

⚠️⚠️ **공식이 못박습니다 — "버킷에서 CORS를 켜도 ACL과 정책은 계속 적용된다."** CORS는 **브라우저의 교차 출처 제약을 푸는 것**이고 **권한을 주는 것이 아닙니다.** "CORS를 허용했는데 403이 난다"는 지문은 거의 항상 **버킷 정책·ACL** 쪽입니다.

⚠️ **S3 Object Lambda 액세스 포인트는 `Origin` 헤더가 있는 요청에 항상 `"AllowedOrigins":"*"`를 추가합니다** — 그 경로에서는 CORS로 출처를 좁힐 수 없습니다.

### 3) 엣지 제어와 규칙을 설계한다 (기술 3.1.3) {#controls}

#### 3-1. ⚠️⚠️ 지리 차단은 두 수단이 서로를 가린다

| | **CloudFront 지리 제한** | **WAF geo match** |
|---|---|---|
| 범위 | **배포 전체** | 규칙 단위로 자유롭게 조합 |
| 세분화 | **국가 수준만** | 국가 + 라벨로 **지역**까지 |
| 다른 조건과 결합 | **할 수 없습니다** | 경로·헤더·속도 등과 중첩 가능 |
| 차단 시 | HTTP **403** 반환 | 규칙 작업에 따름 |

⚠️⚠️ **공식 경고가 결정적입니다 — "CloudFront 지리 제한 기능은 차단한 요청을 AWS WAF로 전달하지 않습니다(허용한 요청은 전달합니다). 지리에 더해 AWS WAF에서 지정할 수 있는 다른 조건으로 차단하려면 WAF geo match 문장을 쓰고 CloudFront 지리 제한 기능은 쓰지 마십시오."**

즉 두 기능을 겹쳐 켜면 **WAF는 차단된 지역의 트래픽을 아예 보지 못하고**, 로그·지표·속도 제한 집계에서도 사라집니다. "특정 국가의 공격 패턴을 분석하면서 차단하라"는 지문에서 CloudFront 기능을 고르면 틀립니다.

⚠️ CloudFront 지리 제한의 비자명한 사실 셋 — 국가 판정은 **제3자 데이터베이스**이고 **전체 정확도 약 99.8%**, 판정 불가 시 **콘텐츠를 제공**합니다 · 오류 응답 캐시는 **기본 10초** · ⚠️⚠️ **CloudFront 관리형 인증서의 검증 요청(`/.well-known/pki-validation/` 경로)은 지리 제한에서 제외**되고, **WAF 규칙(봇 제어 포함)도 그 경로를 차단하면 인증서 검증·갱신이 실패**합니다.

⚠️ WAF geo match 쪽도 비자명합니다 — **1 WCU**, MaxMind GeoIP 데이터베이스, ISO 3166 alpha-2 코드(⚠️ **홍콩은 `HK`**), **국가·지역 코드를 알 수 없으면 `XX`**. 그리고 **지역 코드만으로는 단독 매칭이 불가**해서 geo match 규칙 뒤에 **라벨 매칭 규칙**을 둬야 하고, ⚠️ **라벨은 규칙 평가가 끝날 때 붙기 때문에 같은 규칙 안에서 라벨 매칭을 할 수 없습니다** — 반드시 **별 규칙**입니다. 지역만 보려면 **트래픽이 거의 없는 국가 하나를 Count로 매칭**해 두고 라벨 매칭 규칙을 붙이는 것이 공식 권장 우회입니다.

#### 3-2. 속도 제한 — 무엇을 단위로 세는가

속도 기반 규칙은 **평가 기간·요청 한도·작업**으로 집계 묶음을 세고 제한합니다. 성격이 둘 있습니다 — **중첩 불가**(다른 문장 안에 넣을 수 없고 보호 팩이나 규칙 그룹에 직접 둡니다)이고, **스코프 다운 문장**을 받을 수 있습니다. **기본 WCU는 2**이고 ⚠️ **사용자 지정 집계 키마다 30 WCU**가 더해집니다.

기본 집계는 **요청 출처 IP**입니다. 그 외 선택지는 다음과 같습니다.

| 집계 옵션 | 쓰는 자리 |
|---|---|
| **소스 IP** | 기본값. ⚠️ 프록시·로드밸런서를 거치면 **마지막 프록시의 주소**입니다 |
| **헤더의 IP**(전달된 IP) | `X-Forwarded-For` 등. ⚠️ 잘못된 IP에 대한 **대체 동작**(match/no match)을 함께 정합니다 |
| **ASN** / **헤더의 ASN** | 자율 시스템 번호 단위. ⚠️ 유도 실패 시 **ASN 0**으로 세므로 제외하려면 스코프 다운이 필요합니다 |
| **Count all** | 스코프 다운에 맞는 **모든 요청을 하나로** 셉니다. ⚠️ **스코프 다운이 필수**입니다 |
| **사용자 지정 키** | 라벨 네임스페이스·헤더·쿠키·쿼리 인자·쿼리 문자열·URI 경로·**JA3**·**JA4**·HTTP 메서드·IP·헤더의 IP를 **조합**합니다 |

⚠️⚠️ **가장 자주 틀리는 자리** — 공식이 못박습니다. **"집계 키에 지정한 모든 요청 구성 요소가 요청에 있어야 그 요청이 평가·제한됩니다."** 구성 요소가 빠진 요청은 **차단되지 않고 집계에서 제외**됩니다. 그리고 **요청마다 고유한 값**(요청 ID 같은 것)으로 집계하면 **인스턴스마다 요청이 하나뿐**이라 한도에 닿지 않아 **아무것도 차단되지 않습니다.**

⚠️ 키 유형별 제약이 다릅니다 — 헤더·쿠키·쿼리 인자·라벨 네임스페이스는 **여러 번** 쓸 수 있지만, **쿼리 문자열·URI 경로·JA3·JA4·HTTP 메서드는 한 번만** 쓸 수 있습니다. 라벨 네임스페이스로 집계하면 **그 보호 팩에서 앞서 평가된 규칙이 붙인 라벨만** 쓰입니다.

⚠️ 속도 제한의 다른 길도 있습니다 — **Bot Control 관리형 규칙 그룹의 타기팅 보호 수준**이 자체 속도 제한을 제공하지만 **추가 요금**이 붙습니다.

#### 3-3. 클라이언트 핑거프린팅 = JA3 · JA4

공식 기술 3.1.3이 드는 **「클라이언트 핑거프린팅」**은 WAF에서 **JA3·JA4 핑거프린트**입니다. 둘 다 **사용자 지정 집계 키**로 쓸 수 있고 각각 **한 번만** 쓸 수 있습니다.

⚠️ **쓸 자리는 "IP는 바뀌는데 클라이언트는 같다"입니다.** 분산된 IP에서 오는 자동화 트래픽은 IP 집계로는 못 잡지만, TLS 특성이 같으면 핑거프린트가 같습니다. 반대로 **IP 집계가 과도하게 걸리는 상황**(대형 NAT 뒤의 정상 사용자 다수)에서는 핑거프린트를 **IP와 조합**해 오탐을 줄입니다.

### 4) 타사 서비스와 통합한다 (기술 3.1.4 — 신규) {#third-party}

#### 4-1. OCSF — 한 서비스의 형식이 아니다

OCSF는 확장 가능한 스키마 개발 프레임워크와 **벤더 중립 코어 보안 스키마**를 제공하는 오픈 소스 프로젝트이고, **데이터 타입·속성 사전·분류 체계**로 이뤄지며 **저장 형식·수집 방법·ETL 프로세스와 독립**입니다.

| | **Amazon Security Lake** | **AWS Security Hub**(신) |
|---|---|---|
| OCSF를 어디에 쓰나 | **로그·이벤트**를 OCSF + Parquet로 정규화해 적재 | **조사 결과**의 표현 형식 |
| 산출물 | 쿼리 가능한 S3 데이터 레이크(Glue·Lake Formation 테이블) | 노출 조사 결과 |
| 왜 | 이질적 스키마를 한 언어로 — 여러 솔루션이 **병렬로** 소비 | 상관·분석과 도구 연계 |

⚠️ 지원 버전이 서로 다릅니다(Security Hub는 더 높은 스키마 버전, Security Lake 사용자 지정 소스는 그보다 낮은 범위). **버전 숫자는 올라가는 값이므로 외우지 않습니다** — 축은 **"OCSF는 두 서비스가 서로 다른 층에서 쓰는 공통 언어"**입니다.

⚠️ **「Security Hub」 이름을 CSPM과 섞지 않습니다** — 표준 점검·ASFF는 **`Security Hub CSPM`**, 노출 조사 결과·OCSF는 **신 `Security Hub`**입니다(작업 1.1·2.2의 같은 경계).

#### 4-2. ⚠️⚠️ 타사 데이터를 OCSF로 받는 쪽은 보내는 쪽이 변환한다

Security Lake **사용자 지정 소스**의 요건이 시험의 갈림길입니다. **Security Lake가 대신 변환해 주지 않습니다** — 기본 지원 AWS 소스만 자동 변환이고, **사용자 지정 소스는 보내기 전에 로그·이벤트를 OCSF로 변환**해야 합니다.

- **대상** — 소스에 할당된 접두사 아래 S3 객체로 씁니다. 데이터 범주가 여럿이면 ⚠️ **고유 OCSF 이벤트 클래스마다 별도 소스**로 보냅니다
- **형식** — 각 객체는 **Apache Parquet**이고, 한 객체의 모든 레코드에 **같은 OCSF 이벤트 클래스**가 적용돼야 합니다
- **파티셔닝** — `source location/region=…/accountId=…/eventDay=yyyyMMdd/`. ⚠️ **AWS 밖 계정의 레코드는 `external` 같은 문자열**을 써서 AWS 계정 ID와 충돌하지 않게 합니다
- **주기** — **5분에서 1 이벤트 일 사이**로 보냅니다
- Security Lake가 대신 해 주는 것 — 고유 접두사 제공 · **쓰기 권한 IAM 역할 생성**(권한 경계는 관리형 정책 `AmazonSecurityLakePermissionsBoundary`) · Lake Formation 테이블·Glue 크롤러 설정

⚠️ **계정당 사용자 지정 로그 소스는 최대 50개**이고, 호환성은 **OCSF Validation 도구**로 확인합니다.

#### 4-3. 타사 WAF 규칙 — 과금과 구독의 층

관리형 규칙 그룹은 **AWS와 AWS Marketplace 판매자**가 작성·유지합니다. 과금이 **세 층**입니다.

1. **Bot Control · Fraud Control ATP(계정 탈취 방지) · Fraud Control ACFP(계정 생성 사기 방지)** — AWS 관리형이지만 **기본 WAF 요금 외 추가 요금**
2. **그 밖의 모든 AWS Managed Rules** — **추가 비용 없음**
3. **AWS Marketplace 규칙 그룹** — **구독**이고 판매자가 소유·관리하며 요금은 판매자에게 문의

⚠️⚠️ **Firewall Manager의 WAF 정책에서 Marketplace 규칙 그룹을 쓰려면 조직의 각 계정이 각각 구독해야 합니다.** 중앙에서 한 번 구독해 밀어 넣을 수 없습니다 — `기술 6.2.3`(Firewall Manager)과 이 기술이 만나는 자리입니다.

⚠️ 구독할 수 있는 유형이 **둘**입니다 — **WAF 파트너 관리형 규칙 그룹**과 **클라이언트 측 보호**. 구독료는 **월 단위(시간 비례)**이고 **보호 팩에 추가해 쓰기 시작할 때만** 부과됩니다.

⚠️⚠️ **규칙 그룹 내부는 볼 수 없습니다** — 제공자의 지식재산 보호와 악용 방지를 위해 개별 규칙의 세부를 공개하지 않습니다. 그래서 **테스트 수단이 `Count` 작업**입니다: 차단으로 바꾸기 전에 매칭 수를 세어 오탐을 봅니다. 버전 관리 여부·규칙·규칙 작업·레이블을 정하는 주체는 **판매자**입니다.

⚠️⚠️ **GovCloud(US)에서는 Marketplace 타사 관리형 규칙 그룹을 쓸 수 없습니다** — AWS 관리형 규칙 그룹만 쓸 수 있습니다.

## ✍️ 시험 포인트

- **"지리 + 다른 조건"은 WAF geo match다** — CloudFront 지리 제한은 차단 요청을 WAF로 보내지 않아 조합이 불가능합니다
- **"지역(도·주) 단위 차단"은 두 규칙이다** — geo match(국가) + 라벨 매칭(지역)이고 같은 규칙에 못 넣습니다
- **"오리진으로 직접 오는 요청을 막아라"는 WAF·Shield가 아니다** — 커스텀 헤더 + 접두사 목록입니다
- **"다른 사람의 CloudFront에서 오는 요청도 막아라"는 커스텀 헤더만이 답이다** — 접두사 목록은 CloudFront IP 전체를 허용합니다
- **"큰 본문의 공격이 탐지되지 않는다"는 본문 검사 한도다** — ALB는 8 KB 고정이고 CloudFront 계열은 최대 64 KB까지 올립니다
- **"속도 제한이 걸리지 않는다"는 집계 키다** — 요청마다 고유한 값으로 집계했거나, 키 구성 요소가 없는 요청이 제외된 것입니다
- **"IP가 흩어진 자동화 트래픽"은 JA3·JA4다**
- **"인증된 콘텐츠가 다른 사용자에게 보인다"는 `Authorization`과 캐시 키다**
- **"CORS를 허용했는데 403"은 버킷 정책·ACL이다** — CORS는 권한을 주지 않습니다
- **"타사 규칙을 조직 전체에 적용"은 계정별 구독이 선행 조건이다**
- **"타사 규칙의 오탐을 확인"은 `Count`다** — 내부 규칙을 볼 수 없기 때문입니다

## ⚠️ 흔한 함정 {#pitfalls}

- ❌ "CloudFront 지리 제한과 WAF를 함께 켜면 둘 다 본다" → **차단된 요청은 WAF에 도달하지 않습니다**
- ❌ "WAF geo match로 미국 오리건만 차단" → 지역은 **라벨 매칭 규칙**이 필요하고 **별 규칙**이어야 합니다
- ❌ "접두사 목록으로 CloudFront IP만 허용했으니 안전하다" → **다른 계정의 배포**도 그 IP 범위입니다
- ❌ "공격자가 `X-Origin-Verify`를 위조하면 통과한다" → CloudFront가 **뷰어 값을 덮어씁니다**
- ❌ "CRS를 켜면 모든 OWASP Top 10이 막힌다" → 공식 표현은 **"OWASP Top 10 같은 발행물이 기술하는 고위험·빈발 취약점을 포함해"**이고 **본문 한도** 같은 제약이 있습니다
- ❌ "속도 제한은 IP로만 센다" → **ASN·Count all·사용자 지정 키 조합**이 있습니다
- ❌ "사용자 지정 집계 키는 공짜다" → **키마다 30 WCU**입니다
- ❌ "IoT 정책에서 `+`·`#`로 주제 범위를 넓힌다" → 정책에서는 **리터럴 문자**이고 와일드카드는 `*`입니다
- ❌ "CORS를 열면 누구나 객체를 읽는다" → **ACL·정책이 계속 적용**됩니다
- ❌ "Security Lake에 보내면 OCSF로 바꿔 준다" → **사용자 지정 소스는 보내는 쪽이 변환**합니다
- ❌ "Marketplace 규칙도 Firewall Manager로 한 번에 배포" → **각 계정이 각각 구독**해야 합니다
- ❌ "GovCloud에서도 타사 규칙을 쓴다" → **AWS 관리형만** 가능합니다

## 🧪 자가 점검

**Q1.** 특정 두 국가에서 오는 요청 중 `/login` 경로로 가는 것만 차단하고, 같은 국가의 다른 트래픽은 통과시키면서 그 패턴을 로그로 분석해야 합니다. CloudFront 배포 앞에서 어떻게 구성합니까? (→ 3-1 지리)

<details><summary>정답 보기</summary>

**WAF geo match 문장을 경로 조건과 중첩하고, CloudFront 지리 제한 기능은 쓰지 않습니다.**

- CloudFront 지리 제한은 **배포 전체·국가 수준**이라 경로별 예외를 만들 수 없습니다
- ⚠️⚠️ 더 결정적으로, 공식이 **"지리 제한 기능은 차단한 요청을 AWS WAF로 전달하지 않는다"**고 적습니다. 켜 두면 그 국가 트래픽이 **WAF 로그·지표에 아예 나타나지 않아** 분석도 불가능합니다
- geo match는 **중첩 가능**하고 **1 WCU**이므로 경로 매칭 문장과 `AND`로 묶습니다

⚠️ 국가 코드는 ISO 3166 alpha-2이고 **홍콩은 `HK`**입니다.
</details>

**Q2.** ALB 오리진에 CloudFront를 붙였습니다. 보안 그룹 인바운드를 `com.amazonaws.global.cloudfront.origin-facing` 접두사 목록으로 제한했는데, 감사에서 "여전히 우회 가능"이라는 지적을 받았습니다. 무엇이 빠졌습니까? (→ 2-1 오리진)

<details><summary>정답 보기</summary>

**애플리케이션 계층의 확인이 빠졌습니다 — 커스텀 오리진 헤더입니다.**

- 접두사 목록은 **네트워크 수준**에서 CloudFront의 IP 범위만 허용합니다. 그런데 그 범위는 **모든 고객의 CloudFront 배포**가 공유하므로, 제3자가 자기 배포를 만들어 이 ALB를 오리진으로 지정하면 **같은 IP 범위에서** 요청이 옵니다
- 해법은 CloudFront가 추가하는 **커스텀 헤더**(예: `X-Origin-Verify`)를 두고 **ALB의 WAF 규칙이나 애플리케이션이 그 헤더·값이 없는 요청을 차단**하는 것입니다. 값은 **Secrets Manager에 두고 교체**합니다
- 공식 안내가 **두 층을 함께 쓰는 것이 가장 강한 오리진 보호**라고 적습니다

⚠️ 뷰어가 같은 헤더를 보내도 **CloudFront가 값을 덮어쓰므로** 위조가 통하지 않습니다.
</details>

**Q3.** 로그인 API에 속도 기반 규칙을 걸었는데 공격이 전혀 차단되지 않습니다. 규칙은 "요청의 `X-Request-Id` 헤더로 집계, 5분 100회"입니다. 원인과 수정은? (→ 3-2 속도 제한)

<details><summary>정답 보기</summary>

**집계 키가 요청마다 고유해서 어떤 집계 인스턴스도 한도에 닿지 않습니다.**

- 속도 기반 규칙은 **집계 키의 고유 조합마다 별도 카운터**를 유지합니다. 요청 ID처럼 매 요청 고유한 값으로 집계하면 각 요청이 **자기만의 집계 인스턴스**를 만들어 카운터가 늘 1입니다
- 수정은 **반복되는 값**으로 집계하는 것입니다 — HTTP 메서드, 고객 ID가 든 **커스텀 헤더**, 세션 ID가 든 **쿠키**, 또는 **TLS 핑거프린트(JA3·JA4)**
- ⚠️⚠️ 함께 기억할 것 — **집계 키에 지정한 구성 요소가 없는 요청은 평가·제한에서 아예 빠집니다.** 헤더 기반 집계는 그 헤더를 **보내지 않는** 공격자를 놓칩니다. 그래서 IP와 **조합**하거나 스코프 다운으로 범위를 좁힙니다

⚠️ 비용도 봅니다 — 기본 2 WCU에 **사용자 지정 키마다 30 WCU**입니다.
</details>

**Q4.** 대용량 파일을 업로드하는 API(ALB 오리진)에서 요청 본문에 든 주입 공격이 WAF 관리형 규칙에 걸리지 않습니다. 설명과 대응은? (→ 2-3 관리형 규칙)

<details><summary>정답 보기</summary>

**본문 검사 한도를 넘은 부분은 검사되지 않습니다. ALB는 그 한도를 올릴 수 없습니다.**

- ⚠️⚠️ **Application Load Balancer와 AppSync의 본문 검사 한도는 8 KB로 고정**입니다. CloudFront·API Gateway·Cognito·App Runner·Verified Access·Bedrock AgentCore Gateway는 **기본 16 KB에서 최대 64 KB까지** 보호 팩(web ACL) 설정으로 올릴 수 있습니다
- CRS의 본문 규칙(`SizeRestrictions_BODY`·`GenericLFI_BODY`·`EC2MetaDataSSRF_BODY`)은 초과 콘텐츠에 **`Continue` 옵션**을 쓰므로 **검사되지 않은 채 통과**할 수 있습니다
- 대응은 **CloudFront를 앞에 두어 한도를 64 KB로 올리는 것**, 또는 **애플리케이션 계층에서 본문을 검증**하는 것입니다. CRS의 `SizeRestrictions_BODY`는 **8 KB 초과 본문 자체를 차단**하므로 업로드 경로에서는 그 규칙의 예외 처리(라벨 매칭)가 필요할 수 있습니다

⚠️ 참고로 CRS의 다른 크기 제한은 쿼리 문자열 **2,048바이트**, 쿠키 헤더 **10,240바이트**, URI 경로 **1,024바이트**입니다.
</details>

**Q5.** 조직의 모든 계정에 Firewall Manager로 WAF 정책을 배포하면서 특정 벤더의 Marketplace 규칙 그룹을 포함시켰습니다. 일부 계정에서 정책이 적용되지 않습니다. 원인은? (→ 4-3 타사 규칙)

<details><summary>정답 보기</summary>

**Marketplace 규칙 그룹은 조직의 각 계정이 각각 구독해야 합니다.**

- ⚠️⚠️ 공식이 못박습니다 — Firewall Manager의 WAF 정책에서 Marketplace 규칙 그룹을 쓰려면 **각 계정이 개별로 구독**해야 하고, 중앙에서 한 번 구독해 밀어 넣을 수 없습니다
- Marketplace 규칙 그룹은 **판매자가 소유·관리**하고 요금도 판매자 소관입니다. 구독료는 **월 단위(시간 비례)**이며 **보호 팩에 추가해 쓰기 시작할 때만** 부과됩니다
- ⚠️ **GovCloud(US) 계정이 섞여 있으면 거기서는 애초에 쓸 수 없습니다** — AWS 관리형 규칙 그룹만 가능합니다

⚠️ 도입 시 오탐 확인은 **`Count` 작업**으로 합니다 — 규칙 그룹 내부의 개별 규칙 세부는 **볼 수 없습니다**(제공자 지식재산 보호).
</details>

**Q6.** 타사 EDR 제품의 경보를 Security Lake에 넣어 다른 보안 데이터와 함께 조회하려 합니다. 어떤 준비가 필요합니까? (→ 4-2 사용자 지정 소스)

<details><summary>정답 보기</summary>

**보내는 쪽이 OCSF로 변환해 Parquet으로 써야 합니다 — Security Lake가 변환해 주지 않습니다.**

- **기본 지원 AWS 소스만 자동 변환**이고 **사용자 지정 소스는 전송 전에 OCSF로 변환**합니다
- 형식 요건 — **Apache Parquet** 객체, 한 객체의 **모든 레코드가 같은 OCSF 이벤트 클래스**, 데이터 범주가 여럿이면 ⚠️ **고유 이벤트 클래스마다 별도 소스**
- 파티셔닝은 `region=…/accountId=…/eventDay=yyyyMMdd/`이고 ⚠️ **AWS 밖 계정의 레코드는 `external` 같은 문자열**을 써서 계정 ID와 충돌하지 않게 합니다. 전송 주기는 **5분에서 1 이벤트 일 사이**입니다
- Security Lake가 해 주는 것은 **접두사 제공 · 쓰기 역할 생성**(권한 경계 `AmazonSecurityLakePermissionsBoundary`) **· Lake Formation 테이블 · Glue 크롤러**입니다

⚠️ **계정당 사용자 지정 로그 소스는 최대 50개**이고 호환성은 **OCSF Validation 도구**로 확인합니다.
</details>

---

### 📌 출처

1. What are AWS WAF, AWS Shield Advanced, AWS Shield network security director and AWS Firewall Manager? — `docs.aws.amazon.com/waf/latest/developerguide/what-is-aws-waf.html` (2026-11-08 확인)
2. Baseline rule groups — `docs.aws.amazon.com/waf/latest/developerguide/aws-managed-rule-groups-baseline.html` (2026-11-08 확인)
3. Using managed rule groups in AWS WAF — `docs.aws.amazon.com/waf/latest/developerguide/waf-managed-rule-groups.html` (2026-11-08 확인)
4. AWS Marketplace rule groups — `docs.aws.amazon.com/waf/latest/developerguide/marketplace-rule-groups.html` (2026-11-08 확인)
5. Using rate-based rule statements in AWS WAF — `docs.aws.amazon.com/waf/latest/developerguide/waf-rule-statement-type-rate-based.html` (2026-11-08 확인)
6. Aggregating rate-based rules in AWS WAF — `docs.aws.amazon.com/waf/latest/developerguide/waf-rule-statement-type-rate-based-aggregation-options.html` (2026-11-08 확인)
7. Geographic match rule statement — `docs.aws.amazon.com/waf/latest/developerguide/waf-rule-statement-type-geo-match.html` (2026-11-08 확인)
8. AWS WAF in AWS GovCloud (US) — `docs.aws.amazon.com/govcloud-us/latest/UserGuide/govcloud-waf.html` (2026-11-08 확인)
9. Restrict the geographic distribution of your content — `docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/georestrictions.html` (2026-11-08 확인)
10. Add custom headers to origin requests — `docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/add-origin-custom-headers.html` (2026-11-08 확인)
11. Security checklist for marketplace distributions — `docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/ecommerce-security-checklist.html` (2026-11-08 확인)
12. Using cross-origin resource sharing (CORS) — `docs.aws.amazon.com/AmazonS3/latest/userguide/cors.html` (2026-11-08 확인)
13. AWS IoT Core policy variables — `docs.aws.amazon.com/iot/latest/developerguide/iot-policy-variables.html` (2026-11-08 확인)
14. Thing policy variables — `docs.aws.amazon.com/iot/latest/developerguide/thing-policy-variables.html` (2026-11-08 확인)
15. Security Hub and the OCSF — `docs.aws.amazon.com/securityhub/latest/userguide/securityhub-ocsf.html` (2026-11-08 확인)
16. Collecting data from custom sources in Security Lake — `docs.aws.amazon.com/security-lake/latest/userguide/custom-sources.html` (2026-11-08 확인)
17. Services in Maintenance — App Runner 상태 — `docs.aws.amazon.com/general/latest/gr/maintenance_services.html` (2026-11-12 확인)
