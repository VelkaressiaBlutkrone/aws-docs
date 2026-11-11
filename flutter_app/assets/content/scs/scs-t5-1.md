---
examGuideTaskId: scs-t5-1
certCode: SCS-C03
domain: 5
domainName: 데이터 보호
domainWeightPct: 18
title: 전송 중인 데이터 (암호화 강제·비공개 액세스·리소스 간 암호화)
coversTasks:
  - "5.1"
sources:
  - title: Security policies for your Application Load Balancer
    url: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/describe-ssl-policies.html
  - title: Create an HTTPS listener for your Application Load Balancer
    url: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html
  - title: AWS PrivateLink concepts
    url: https://docs.aws.amazon.com/vpc/latest/privatelink/concepts.html
  - title: Access an AWS service using an interface VPC endpoint
    url: https://docs.aws.amazon.com/vpc/latest/privatelink/create-interface-endpoint.html
  - title: Client authentication in AWS Client VPN
    url: https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/client-authentication.html
  - title: Mutual authentication in AWS Client VPN
    url: https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/mutual.html
  - title: What is AWS Verified Access?
    url: https://docs.aws.amazon.com/verified-access/latest/ug/what-is-verified-access.html
  - title: Data protection in Amazon EC2
    url: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/data-protection.html
  - title: Encryption options for Amazon EMR
    url: https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-data-encryption-options.html
  - title: Protect Communications Between ML Compute Instances in a Distributed Training Job
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/train-encrypt.html
  - title: Network security - Amazon EKS Best Practices Guide
    url: https://docs.aws.amazon.com/eks/latest/best-practices/network-security.html
lastVerified: 2026-11-09
---

# 전송 중인 데이터 (암호화 강제·비공개 액세스·리소스 간 암호화)

> **커버하는 공식 Task** — SCS-C03 · 도메인 5 「데이터 보호」(18%) · **작업 5.1 전송 중인 데이터에 대한 제어 설계 및 구현** (`scs-t5-1`)
> 이 문서는 위 한 작업에 1:1로 매핑되고 공식 기술 3개(5.1.1~5.1.3)를 모두 덮습니다.

> ⚠️ 이 작업의 문항은 거의 전부 **"그 트래픽이 실제로 암호화되는가, 어느 계층에서 되는가"**로 환원됩니다. AWS는 **물리 계층 · 피어링 벌크 · Nitro 하드웨어 · 애플리케이션 TLS**의 **네 층**에서 서로 다른 보장을 주고, 그중 하나가 성립한다고 다른 하나도 성립하는 것이 아닙니다(§3-1).

> 그리고 **기본값이 생성 경로마다 다른** 자리가 하나 있습니다 — ALB HTTPS 리스너의 보안 정책은 **콘솔로 만들면 최신, IaC로 만들면 2016년 정책**이 기본입니다(§1-1). 코드로 배포하는 조직이 그대로 밟는 함정입니다.

---

## ✅ 학습 목표 체크리스트

- [ ] ALB 보안 정책의 **기본값이 생성 경로마다 다름**을 안다
- [ ] 정책군 **네 갈래**(TLS·FIPS·RFC 9151·PQ)를 구분한다
- [ ] **백엔드 연결** 정책을 고를 수 없는 이유를 설명한다
- [ ] PrivateLink의 **제공자·소비자 양쪽** 구성요소를 말한다
- [ ] VPC 엔드포인트 유형과 **게이트웨이만 PrivateLink가 아닌 것**을 안다
- [ ] Client VPN의 **인증 세 유형**과 인증서 요건을 안다
- [ ] 전송 중 암호화의 **네 계층**을 가르고 섞지 않는다
- [ ] EMR·SageMaker AI의 **리소스 간 암호화 설정**을 안다

## 🎯 왜 중요한가

전송 중 암호화 문항은 **"암호화됐다고 생각했는데 아니었다"**와 **"이미 암호화돼 있는데 또 설정했다"** 두 방향으로 나옵니다. 둘 다 **어느 계층이 무엇을 보장하는지**를 모르면 풀 수 없습니다.

특히 Nitro 인스턴스 간 하드웨어 암호화는 **조건이 셋**(지원 인스턴스 유형 · 같은 리전 · 같은 VPC 또는 피어링된 VPC)이고 **중간 홉이 끼면 성립하지 않습니다**. 그런데 같은 트래픽이 **다른 계층에서는 여전히 암호화**될 수 있습니다 — AZ 간 트래픽과 리전을 나가는 트래픽은 물리 계층에서 자동 암호화되고, VPC 피어링·Transit Gateway 교차 리전 피어링은 리전을 나갈 때 **벌크 암호화**됩니다. 이 구분이 §3-1이고, 이 작업에서 가장 자주 틀리는 자리입니다.

## ⚡ 시험 직전 요약

- ⚠️⚠️ **ALB HTTPS 리스너의 기본 보안 정책은 생성 경로마다 다릅니다** — **콘솔은 `ELBSecurityPolicy-TLS13-1-2-Res-PQ-2025-09`**, **CLI·CloudFormation·CDK 등은 `ELBSecurityPolicy-2016-08`**입니다
- ⚠️ **ALB는 사용자 지정 보안 정책을 지원하지 않습니다** — 미리 정의된 정책에서 고릅니다
- ⚠️⚠️ **백엔드 연결의 보안 정책은 고를 수 없습니다** — 리스너 정책에 따라 자동으로 정해집니다(일반 TLS 정책이면 백엔드는 `ELBSecurityPolicy-2016-08`)
- **PQ 정책은 하이브리드 포스트 양자 키 교환**이고 클라이언트가 **ML-KEM**을 지원해야 씁니다. **RFC 9151(CNSA 1.0)** 정책군에는 전환용 **INTEROP** 변형이 있습니다
- ⚠️ **ELB 조건 키로 IAM·SCP에서 쓸 수 있는 보안 정책을 제한**할 수 있습니다
- ⚠️⚠️ **게이트웨이 엔드포인트만 PrivateLink를 쓰지 않습니다**(S3·DynamoDB 전용, 라우팅 테이블 항목). 나머지 유형은 모두 PrivateLink입니다
- **엔드포인트 서비스를 만들려면 로드 밸런서를 지정**해야 하고, **기본적으로 소비자에게 공개되지 않아** 보안 주체 권한을 명시적으로 추가해야 합니다
- ⚠️ **Client VPN은 인증 유형과 무관하게 ACM의 서버 인증서가 필요합니다.** 인증은 **Active Directory · 상호 인증(인증서) · SAML SSO** 셋이고, 상호 인증과 사용자 기반을 **조합하면 둘 다** 통과해야 합니다
- ⚠️⚠️ **전송 중 암호화는 네 계층입니다** — 물리 계층(리전 간·AZ 간 자동) · VPC·TGW 교차 리전 피어링 벌크 암호화 · **Nitro 인스턴스 간 하드웨어 암호화**(AEAD 256비트, 조건 셋) · 애플리케이션 TLS
- ⚠️⚠️ **중간 홉(Transit Gateway·로드 밸런서)이 끼면 Nitro 인스턴스 간 암호화는 성립하지 않습니다** — 그래도 다른 계층의 보장은 남습니다

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **보안 정책** | 프로토콜과 암호(cipher)의 조합. ELB가 클라이언트와 SSL 연결을 협상할 때 쓰는 구성입니다 |
| **FS(전달 비밀성)** | 장기 키가 유출돼도 과거 세션을 복호화할 수 없는 성질. TLS 1.3 전용 정책이 지원합니다 |
| **하이브리드 PQ-TLS** | 고전 알고리즘과 **ML-KEM** 포스트 양자 알고리즘을 함께 쓰는 키 교환 |
| **엔드포인트 서비스** | 제공자가 리전에 서비스를 공개하는 PrivateLink 객체. **로드 밸런서를 지정**해야 합니다 |
| **엔드포인트 네트워크 인터페이스** | 소비자 서브넷마다 만들어지는 **요청자 관리형** ENI. 보이지만 내가 관리하지 않습니다 |
| **리소스 구성 / 리소스 게이트웨이** | 리소스 제공자가 리소스를 공유하는 논리 객체와, 그 VPC로 들어오는 진입점 |
| **상호 인증** | Client VPN이 **클라이언트 인증서**로 클라이언트를 인증하는 방식 |
| **컨테이너 간 트래픽 암호화** | 분산 훈련에서 **ML 컴퓨팅 인스턴스 사이** 통신을 암호화하는 SageMaker AI 설정 |

## 📖 핵심 개념

### 1) 연결에 암호화를 강제한다 (기술 5.1.1) {#enforce-tls}

#### 1-1. ELB 보안 정책 — 기본값이 생성 경로마다 다르다

**HTTPS 리스너에는 보안 정책이 반드시 있어야 합니다.** 지정하지 않으면 기본 정책이 쓰이는데, ⚠️⚠️ **그 기본값이 만든 방법에 따라 다릅니다.**

| 만든 방법 | 기본 보안 정책 |
|---|---|
| **콘솔** | **`ELBSecurityPolicy-TLS13-1-2-Res-PQ-2025-09`** |
| **그 밖의 방법**(AWS CLI · CloudFormation · AWS CDK) | **`ELBSecurityPolicy-2016-08`** |

⚠️ **코드로 배포하는 조직이 그대로 밟는 함정입니다.** `ELBSecurityPolicy-2016-08`은 **TLS 1.0·1.1과 CBC 모드 암호**를 포함하는 오래된 정책이라, "IaC로 ALB를 만들었더니 준수 스캔에서 TLS 1.0이 잡힌다"는 시나리오가 그대로 성립합니다. 리스너를 만들 때 **명시적으로 지정**하는 것이 해법입니다.

⚠️ **ALB는 사용자 지정 보안 정책을 지원하지 않습니다.** "우리가 고른 암호 목록으로 정책을 만든다"는 선택지는 없고, **미리 정의된 정책 중에서** 고릅니다.

#### 1-2. 정책군 네 갈래

공식 문서가 보안 정책을 **네 묶음**으로 나눠 싣습니다 — **TLS · FIPS · RFC 9151(CNSA 1.0) · FS 지원**. 그리고 이름에 든 접미사가 성질을 말합니다.

| 이름의 표식 | 뜻 |
|---|---|
| **`PQ`** | **하이브리드 포스트 양자 키 교환**. 호환을 위해 고전 알고리즘과 **ML-KEM**을 **모두** 지원하고, ⚠️ **클라이언트가 ML-KEM을 지원해야** 하이브리드 PQ-TLS가 쓰입니다. 지원 알고리즘은 `SecP256r1MLKEM768` · `SecP384r1MLKEM1024` · `X25519MLKEM768`입니다 |
| **`FIPS`** | FIPS 요건용 정책군 |
| **`RFC9151`** | 미국 NSA의 **CNSA 1.0** 요건(RFC 9151)을 돕는 정책군. ⚠️ **엄격(strict) 정책**과 **`INTEROP` 정책**(RFC 9151 준수 암호와 비준수 암호를 모두 지원해 점진 전환)으로 갈립니다 |
| **`TLS13-1-x`** | 지원하는 최소 TLS 버전. 예: `TLS13-1-3`은 **TLS 1.3만**, `TLS13-1-0`은 1.3~1.0 |

**공식 권고가 분명합니다** — **`ELBSecurityPolicy-TLS13-1-2-Res-PQ-2025-09`** 또는 FIPS 판 **`ELBSecurityPolicy-TLS13-1-2-Res-FIPS-PQ-2025-09`**로 시작하라고 적습니다. 이 정책은 **하이브리드 PQ-TLS를 협상할 수 있는 클라이언트 · TLS 1.3만 가능한 클라이언트 · TLS 1.2만 가능한 클라이언트**를 모두 받아 **전환 중 중단을 최소화**합니다. 더 엄격한 정책으로는 **점진적으로** 옮깁니다. RFC 9151 쪽도 같은 모양으로 **`...RFC9151-INTEROP4-FIPS-2023-07`에서 시작**하라고 권합니다.

- **FS는 정책의 성질에서 따라옵니다** — **TLS 1.3만 지원하는 정책은 FS를 지원**하고, TLS 1.3과 1.2를 지원하는 정책 중 **`TLS_*`·`ECDHE_*` 형태의 암호만** 가진 것도 FS를 제공합니다
- ⚠️ **TLS 재개는 같은 ALB IP 주소 연결에서만** 동작합니다(TLS 1.3은 PSK, 1.2 이하는 세션 ID·세션 티켓). **0-RTT 데이터와 `early_data` 확장은 구현되지 않았습니다**
- **진단은 로그로 합니다** — **연결 로그**에서 TLS 프로토콜 버전(필드 5)과 키 교환(필드 13)을, 또는 `tls_protocol`·`tls_cipher`·`tls_keyexchange` 필드를 봅니다. 접근 로그로도 프로토콜 버전을 확인할 수 있습니다

#### 1-3. 백엔드 연결은 고를 수 없다

⚠️⚠️ **프런트엔드 연결의 정책은 내가 고르지만 백엔드 연결의 정책은 고를 수 없습니다.** 리스너 정책에 따라 **자동으로 정해집니다.**

| 리스너가 쓰는 정책 | 백엔드 연결이 쓰는 정책 |
|---|---|
| **RFC 9151 정책**(INTEROP 포함) | `ELBSecurityPolicy-TLS13-1-2-RFC9151-INTEROP4-FIPS-2023-07` |
| **FIPS 포스트 양자 TLS 정책** | `ELBSecurityPolicy-TLS13-1-0-FIPS-PQ-2025-09` |
| **FIPS 정책** | `ELBSecurityPolicy-TLS13-1-0-FIPS-2023-04` |
| **포스트 양자 TLS 정책** | `ELBSecurityPolicy-TLS13-1-0-PQ-2025-09` |
| **TLS 1.3 정책** | `ELBSecurityPolicy-TLS13-1-0-2021-06` |
| **그 밖의 TLS 정책** | **`ELBSecurityPolicy-2016-08`** |

⚠️ 즉 **"리스너를 TLS 1.2 전용으로 묶었으니 백엔드도 1.2 이상"이 아닙니다.** 대상까지 엔드 투 엔드로 버전을 묶으려면 **리스너 정책의 종류 자체**를 올려야 합니다. 그리고 ALB는 **대상 연결에 대해서만 SSL 재협상을 지원**합니다.

#### 1-4. 조직 차원에서 강제하는 수단

⚠️ **ELB 조건 키를 IAM 정책과 서비스 제어 정책(SCP)에 써서, 계정과 조직 전반에서 쓸 수 있는 보안 정책을 제한**할 수 있습니다. "낡은 정책을 고를 수 없게 하라"는 요구의 공식 답이고, 도메인 6의 조직 정책과 이어지는 자리입니다.

### 2) 리소스에 안전하게 비공개로 접근한다 (기술 5.1.2) {#private-access}

#### 2-1. PrivateLink는 양쪽이 있다

PrivateLink는 **내 VPC의 클라이언트가 다른 VPC의 서비스·리소스에 사설 IP로 접근**하게 합니다 — 그 서비스가 내 VPC 안에 있는 것처럼요.

**제공자 쪽:**

| 구성요소 | 하는 일 |
|---|---|
| **서비스 제공자 / 리소스 제공자** | 서비스·리소스의 소유자. AWS · AWS 파트너 · 다른 AWS 계정이고 **온프레미스에서 호스팅해도** 됩니다 |
| **엔드포인트 서비스** | 리전에 서비스를 공개하는 객체. ⚠️ **로드 밸런서를 반드시 지정**해야 하고, ⚠️ **기본적으로 소비자에게 공개되지 않아** 특정 AWS 보안 주체의 연결을 허용하는 권한을 추가해야 합니다 |
| **서비스 이름** | 소비자가 엔드포인트를 만들 때 지정하는 식별자. ⚠️ AWS 서비스의 이름은 조회할 수 있지만 **내 서비스 이름은 내가 소비자에게 알려야** 합니다 |
| **리소스 구성 / 리소스 게이트웨이** | 리소스(IP 주소·도메인 이름 대상·RDS 데이터베이스 등)를 공유하는 논리 객체와 그 VPC의 진입점. ⚠️ **다른 계정과 공유할 때는 AWS RAM 리소스 공유를 거쳐야** 합니다 |

**소비자 쪽:**

- **VPC 엔드포인트**를 만들어 엔드포인트 서비스·리소스·서비스 네트워크에 연결합니다
- **엔드포인트 네트워크 인터페이스** — 지정한 서브넷마다 만들어지는 **요청자 관리형** ENI입니다. ⚠️ 내 계정에서 **보이지만 내가 관리할 수 없습니다**. IPv6를 지원하는 엔드포인트의 ENI는 IPv6 주소를 갖는데 ⚠️ **그 IPv6 주소는 인터넷에서 닿을 수 없습니다**
- **엔드포인트 정책**으로 그 엔드포인트를 쓸 수 있는 보안 주체와 접근 가능한 리소스를 제한합니다
- 과금은 **시간당 사용료 + 데이터 처리 요금**입니다

#### 2-2. VPC 엔드포인트 유형

공식 개념 페이지가 유형을 이렇게 적습니다.

| 유형 | 무엇에 쓰나 |
|---|---|
| **`Interface`** | 엔드포인트 서비스에 **TCP·UDP 트래픽**을 보냅니다. 대상은 **DNS로 해석**됩니다 |
| **`GatewayLoadBalancer`** | **가상 어플라이언스 플릿**에 사설 IP로 트래픽을 보냅니다. **라우팅 테이블**로 보냅니다 |
| **`Resource`** | 다른 VPC나 온프레미스에 있는 **공유된 리소스**(데이터베이스·EC2 인스턴스·애플리케이션 엔드포인트·도메인 이름 대상·IP 주소)에 접근합니다. ⚠️ **로드 밸런서가 필요하지 않고** 리소스에 직접 접근합니다 |
| **`Tunnel`** | 공유된 **네트워크 세그먼트**(CIDR 범위 목록)로 터널링합니다. ⚠️ 애플리케이션 트래픽을 **GENEVE로 캡슐화**해야 합니다 |
| **`Service network`** | VPC Lattice **서비스 네트워크**에 접근합니다. ⚠️ **엔드포인트 하나로 여러 서비스·리소스**에 접근합니다 |
| **`Gateway`** | **S3 또는 DynamoDB**로 트래픽을 보냅니다. ⚠️⚠️ **다른 유형과 달리 PrivateLink를 쓰지 않습니다** |

⚠️⚠️ **유형의 「개수」를 외우지 않습니다.** 공식 개념 페이지와 PrivateLink FAQ가 **서로 다른 수를 암시**하고(FAQ는 `Tunnel`을 들지 않습니다) 유형은 늘어나는 값입니다. 고정할 축은 **"게이트웨이 엔드포인트만 PrivateLink를 쓰지 않고 S3·DynamoDB 전용이며 라우팅 테이블 항목을 더한다"**입니다.

#### 2-3. AWS Client VPN — 인증 세 유형

Client VPN은 **AWS 클라우드로 들어오는 첫 지점에서** 클라이언트를 인증합니다. 인증이 실패하면 **VPN 세션이 아예 만들어지지 않습니다.**

| 유형 | 성질 |
|---|---|
| **Active Directory 인증** | 사용자 기반 |
| **상호 인증** | **인증서 기반**. 서버가 **클라이언트 인증서**로 클라이언트를 인증합니다 |
| **단일 로그인(SAML 기반 연동 인증)** | 사용자 기반 |

⚠️ **조합이 가능하고, 조합하면 둘 다 통과해야 합니다** — 상호 인증 + 연동 인증, 상호 인증 + Active Directory 인증. 공식이 "both methods must then be used to correctly authenticate"라고 적습니다.

⚠️⚠️ **인증 유형과 무관하게 ACM에 서버 인증서를 프로비저닝해야 Client VPN 엔드포인트를 만들 수 있습니다.** "SAML로 하니 인증서는 필요 없다"는 거짓입니다.

상호 인증의 세부:

- 서버 인증서·키와 **클라이언트 인증서·키를 최소 하나** 만듭니다. 서버 인증서는 ACM에 업로드하고 엔드포인트 생성 시 지정합니다
- ⚠️ **클라이언트 인증서를 ACM에 올려야 하는 것은 그 CA가 서버 인증서의 CA와 다를 때만**입니다
- **클라이언트마다 인증서를 따로** 만들면 조직을 떠난 사용자의 인증서만 **폐기**할 수 있습니다
- ⚠️ **RSA 1024비트와 2048비트만** 지원하고 **클라이언트 인증서에는 Subject 필드의 CN 속성이 있어야** 합니다(RFC 5280 준수)
- ⚠️ 인증서가 갱신되면(ACM 자동 교체·수동 가져오기·IAM Identity Center 메타데이터 갱신) Client VPN이 엔드포인트를 **자동으로 새 인증서로 갱신**하는데 **최대 5시간**이 걸립니다

#### 2-4. Verified Access — VPN이 필요 없는 쪽

Verified Access는 **VPN 없이** 기업 애플리케이션에 접근하게 하고 **요청마다 실시간으로** 정책을 평가합니다. 작업 3.3(`scs-t3-3` §3)에서 네트워크 관점으로 다뤘고, 여기서는 **「비공개 액세스 메커니즘」의 한 선택지**로 봅니다.

⚠️ **갈림길은 「클라이언트 소프트웨어가 필요한가」와 「무엇을 평가하는가」**입니다 — Client VPN은 **네트워크 수준 연결**을 주고 클라이언트가 필요하며, Verified Access는 **애플리케이션 단위 접근**을 주고 클라이언트 없이 **ID와 디바이스 상태**를 요청마다 봅니다.

### 3) 리소스 간 전송 중 암호화 (기술 5.1.3) {#inter-resource}

#### 3-1. ⚠️⚠️ 계층 넷을 섞지 않는다

이 절이 이 문서의 핵심입니다. 공식 EC2 데이터 보호 문서가 전송 중 암호화를 **여러 소제목으로 나눠** 적습니다.

| 계층 | 보장 | 조건 |
|---|---|---|
| **물리 계층** | AWS 글로벌 네트워크로 **리전 간** 흐르는 모든 데이터가 **AWS 보안 시설을 떠나기 전에 자동 암호화**되고, ⚠️ **AZ 간 모든 트래픽이 암호화**됩니다 | 없음(자동) |
| **피어링 벌크 암호화** | **VPC 피어링과 Transit Gateway 피어링을 쓰는 모든 교차 리전 트래픽**이 리전을 나갈 때 **자동으로 벌크 암호화**됩니다 | 교차 리전 |
| **Nitro 인스턴스 간 하드웨어 암호화** | **AEAD 알고리즘·256비트**로 인스턴스 간 트래픽을 자동 암호화하고 **네트워크 성능에 영향이 없습니다** | ⚠️ **지원 인스턴스 유형** · **같은 리전** · **같은 VPC 또는 피어링된 VPC** |
| **애플리케이션 TLS** | 애플리케이션 프로세스 사이의 종단 간 보장 | 내가 구성합니다 |

⚠️⚠️ **중간 홉이 끼면 Nitro 인스턴스 간 암호화는 성립하지 않습니다** — 공식 EKS 모범 사례 가이드가 "**When there's an intermediate hop, like a transit gateway or a load balancer, the traffic is not encrypted**"라고 적습니다. **그런데 그것이 "그 트래픽이 평문"이라는 뜻은 아닙니다** — 같은 트래픽이 AZ를 넘거나 리전을 나가면 **물리 계층·벌크 계층의 보장이 남습니다.** 앞의 서술은 하드웨어 암호화 계층이고 뒤의 서술은 물리 계층이므로 계층을 나눠 읽어야 합니다.

⚠️ **지원 인스턴스 유형 목록은 길고 늘어납니다** — 목록을 외우지 않고 **"확인하는 방법"**을 기억합니다. 공식 문서에 AWS CLI로 **인스턴스 간 전송 중 암호화를 지원하는 인스턴스 유형을 조회하는 절차**가 있습니다.

⚠️ 공식 권고의 기준선도 함께 기억합니다 — **AWS는 TLS 1.2를 요구하고 TLS 1.3을 권장**하며, CLI·API로 접근할 때 **FIPS 140-3 검증 모듈이 필요하면 FIPS 엔드포인트**를 씁니다.

#### 3-2. Amazon EMR — 보안 구성과 인증서 두 경로

EMR의 전송 중 암호화는 **보안 구성(security configuration)**으로 켭니다. 그러면 EMR이 **전송 중 암호화를 지원하는 모든 오픈 소스 애플리케이션 엔드포인트**에 대해 설정을 자동으로 맞춥니다.

⚠️ **그런데 이 기능들은 오픈 소스 기능이고 애플리케이션별이며 EMR 릴리스 버전마다 다릅니다.** "EMR에서 전송 중 암호화를 켜면 모든 통신이 암호화된다"고 단정할 수 없고, 공식은 **전송 중 암호화 지원 매트릭스**를 보라고 적습니다.

**TLS 인증서를 주는 방법이 둘입니다:**

| 방법 | 성질 |
|---|---|
| **S3 버킷의 `.zip` 파일 경로** | 인증서를 모은 압축 파일을 지정합니다 |
| **사용자 지정 인증서 공급자(Java 클래스)** | ⚠️ 개인 키를 S3에 두는 것을 금지하는 보안 정책이 있을 때의 경로입니다 |

- ⚠️⚠️ **일부 엔드포인트는 보안 구성만으로 끝나지 않습니다** — **SASL**을 쓰는 오픈 소스 엔드포인트는 그 보안 구성에 **Kerberos 인증이 켜져 있어야** 전송 중 암호화가 동작합니다
- 오픈 소스 구성을 직접 덮어써서 **TLS 호스트 이름 검증 끄기 · 특정 엔드포인트만 끄기 · TLS 버전과 암호 제어**를 할 수 있습니다
- **EMR 7.0.0 이상**에서는 대부분의 오픈 소스 프레임워크가 **TLS 1.2 이상을 강제**합니다

#### 3-3. SageMaker AI — 컨테이너 간 트래픽 암호화

SageMaker AI는 기본적으로 훈련 작업을 **AWS가 관리하는 VPC**에서 돌리고, 여기에 **프라이빗 VPC**와 **컨테이너 간 트래픽 암호화**를 더해 보호를 올립니다.

⚠️ **무엇이 전송되는지가 중요합니다** — 분산 ML 프레임워크가 인스턴스 사이에 보내는 것은 대개 **가중치처럼 모델과 직접 관련된 정보**이고 **훈련 데이터세트 자체가 아닙니다.** 그래도 규제 요건을 맞추기 위해 그 통신을 암호화합니다.

- **훈련 작업과 하이퍼파라미터 튜닝 작업**에 켤 수 있습니다(API 또는 콘솔)
- ⚠️⚠️ **단일 컴퓨팅 인스턴스 훈련 작업에는 영향이 없습니다** — 암호화할 인스턴스 간 통신이 없기 때문입니다
- ⚠️ **분산 딥러닝에서는 훈련 시간이 늘고 비용도 늘 수 있습니다.** 영향의 크기는 **인스턴스 간 통신량**에 달렸고, **XGBoost·DeepAR·linear learner** 같은 대부분의 내장 알고리즘은 **보통 영향을 받지 않습니다**
- 공식이 **의료 분야 사용 사례에서는 노드 간 통신 암호화를 보안 모범 사례로** 적습니다

#### 3-4. 저장 쪽 사실 셋 — 인스턴스 스토어·메모리·EBS 재사용

작업 5.2가 저장 데이터를 다루지만, **EC2의 이 두 사실은 「내가 설정하는 것이 아니다」**라서 전송 중 문항의 오답 보기로 자주 쓰입니다.

- ⚠️⚠️ **NVMe 인스턴스 스토어는 `XTS-AES-256`으로 암호화되고 끌 수 없으며 내 키를 줄 수도 없습니다.** 키는 **고객별·볼륨별**이고 **하드웨어 모듈 안에서만** 생성·존재하며 **AWS 인력도 접근할 수 없고**, 인스턴스를 중지·종료하면 **파괴되어 복구할 수 없습니다**. HDD 인스턴스 스토어(H1·D3·D3en)는 **XTS-AES-256과 일회성 키**를 씁니다
- ⚠️ **메모리 암호화는 프로세서가 제공합니다** — **Graviton2 이상**은 상시 켜져 있고(키가 호스트 시스템 안에서 생성되어 밖으로 나가지 않으며 호스트 재부팅·전원 차단 시 파괴됩니다), Intel은 **TME**, AMD는 **SME**, 일부 AMD 인스턴스 유형은 **SEV-SNP**를 지원합니다
- ⚠️ **EBS 볼륨은 재사용 전에 논리적으로 비워집니다**(원시 블록이 0이거나 암호학적 의사난수). **DoD 5220.22-M**·**NIST 800-88** 같은 삭제 절차가 필요하면 EBS에서 수행할 수 있고 그 블록 수준 활동이 기반 저장 매체까지 반영됩니다

## ✍️ 시험 포인트

- **"IaC로 만든 ALB에서 TLS 1.0이 잡힌다"는 기본 정책이 `ELBSecurityPolicy-2016-08`이기 때문이다** — 콘솔 기본값과 다릅니다
- **"암호 목록을 우리가 정한 정책으로 만든다"는 ALB에서 불가능하다**
- **"리스너를 올렸는데 백엔드가 그대로다"는 백엔드 정책이 리스너 정책 종류에 따라 자동 결정되기 때문이다**
- **"포스트 양자 전환 중 호환을 유지하라"는 `Res-PQ` 정책이고, 클라이언트가 ML-KEM을 지원해야 한다**
- **"CNSA 1.0으로 점진 전환"은 `RFC9151-INTEROP` 정책이다**
- **"조직에서 낡은 정책을 못 고르게 하라"는 ELB 조건 키 + SCP다**
- **"S3에 사설로 접근"에서 게이트웨이 엔드포인트만 PrivateLink가 아니다**
- **"엔드포인트 서비스를 만들었는데 소비자가 연결하지 못한다"는 권한을 추가하지 않은 것이다**
- **"로드 밸런서 없이 다른 VPC의 데이터베이스에 사설 접근"은 리소스 엔드포인트다**
- **"엔드포인트 하나로 여러 서비스에"는 서비스 네트워크 엔드포인트다**
- **"SAML만 쓰니 ACM 인증서는 필요 없다"는 틀렸다** — 유형과 무관하게 서버 인증서가 필요합니다
- **"상호 인증과 AD를 함께 켰는데 한쪽만 통과하면 된다"는 틀렸다** — 둘 다 필요합니다
- **"떠난 직원만 차단하라"는 클라이언트별 인증서 폐기다**
- **"TGW를 지나는 인스턴스 간 트래픽이 Nitro 암호화된다"는 틀렸다** — 중간 홉이 있으면 성립하지 않습니다
- **"그러면 평문인가"도 틀렸다** — AZ 간·리전 간 물리 계층과 피어링 벌크 암호화가 남습니다
- **"EMR에서 암호화를 켜면 모든 통신이 암호화된다"는 단정할 수 없다** — 애플리케이션별이고 릴리스마다 다릅니다
- **"개인 키를 S3에 두지 말라"는 EMR 사용자 지정 인증서 공급자다**
- **"SASL 엔드포인트가 암호화되지 않는다"는 Kerberos가 꺼져 있는 것이다**
- **"단일 인스턴스 훈련에 컨테이너 간 암호화를 켜서 느려졌다"는 성립하지 않는다** — 영향이 없습니다
- **"인스턴스 스토어를 우리 KMS 키로 암호화하라"는 불가능하다** — 끌 수도, 키를 줄 수도 없습니다

## ⚠️ 흔한 함정 {#pitfalls}

- ❌ "HTTPS 리스너는 보안 정책 없이도 만들 수 있다" → **반드시 있어야** 하고, 지정하지 않으면 **기본값**이 쓰입니다
- ❌ "기본 보안 정책은 하나다" → **콘솔과 그 밖의 방법이 다릅니다**
- ❌ "ALB에 사용자 지정 보안 정책을 붙인다" → **지원되지 않습니다**
- ❌ "백엔드 연결 정책을 따로 고른다" → **고를 수 없습니다**
- ❌ "PQ 정책을 켜면 모든 클라이언트가 포스트 양자로 붙는다" → **클라이언트가 ML-KEM을 지원해야** 합니다
- ❌ "TLS 1.3 정책이면 0-RTT로 지연이 줄어든다" → **0-RTT와 `early_data`는 구현되지 않았습니다**
- ❌ "TLS 재개는 어느 노드로 붙어도 된다" → **같은 ALB IP 주소**여야 합니다
- ❌ "게이트웨이 엔드포인트도 PrivateLink다" → **아닙니다**(S3·DynamoDB 전용)
- ❌ "엔드포인트 네트워크 인터페이스를 내가 관리한다" → **요청자 관리형**입니다
- ❌ "엔드포인트의 IPv6 주소로 인터넷에서 접근한다" → **닿을 수 없습니다**
- ❌ "리소스 엔드포인트도 NLB가 필요하다" → **필요하지 않습니다**
- ❌ "터널 엔드포인트는 그냥 TCP를 보낸다" → **GENEVE 캡슐화**가 필요합니다
- ❌ "다른 계정에 리소스를 공유할 때 RAM이 필요 없다" → **RAM 리소스 공유를 거칩니다**
- ❌ "Client VPN에서 클라이언트 인증서를 항상 ACM에 올린다" → **CA가 서버 인증서와 다를 때만**입니다
- ❌ "Client VPN은 RSA 4096비트를 쓴다" → **1024·2048비트만** 지원합니다
- ❌ "인증서를 갱신하면 즉시 반영된다" → **최대 5시간** 걸립니다
- ❌ "Verified Access도 VPN 클라이언트가 필요하다" → **클라이언트 없이** 요청마다 평가합니다
- ❌ "AZ 간 트래픽은 내가 TLS를 켜야 암호화된다" → **물리 계층에서 자동 암호화**됩니다
- ❌ "인스턴스 유형만 맞으면 Nitro 암호화가 된다" → **같은 리전·같은 VPC(또는 피어링)**도 필요합니다
- ❌ "컨테이너 간 트래픽 암호화가 훈련 데이터를 암호화한다" → 전송되는 것은 **가중치 등 모델 관련 정보**입니다
- ❌ "메모리 암호화를 내가 켜고 끈다" → 지원 프로세서에서 **상시** 동작합니다

## 🧪 자가 점검

**Q1.** 플랫폼팀이 CloudFormation으로 ALB를 배포했습니다. 준수 스캔에서 "TLS 1.0 허용"과 "CBC 모드 암호"가 지적됐는데, 팀은 "콘솔에서 만든 다른 ALB는 통과했다"고 합니다. 원인과 해결은? (→ 1-1 기본 정책)

<details><summary>정답 보기</summary>

**기본 보안 정책이 생성 경로마다 다르기 때문입니다.**

- 공식이 명시합니다 — HTTPS 리스너는 보안 정책이 **반드시** 있어야 하고, 지정하지 않으면 **콘솔은 `ELBSecurityPolicy-TLS13-1-2-Res-PQ-2025-09`**, **AWS CLI·CloudFormation·AWS CDK 등은 `ELBSecurityPolicy-2016-08`**이 기본값입니다
- `ELBSecurityPolicy-2016-08`은 **TLS 1.0·1.1을 포함**하는 오래된 정책이라 지적 내용과 맞습니다
- 해결은 **리스너에 정책을 명시적으로 지정**하는 것입니다. 공식 권고 출발점은 **`ELBSecurityPolicy-TLS13-1-2-Res-PQ-2025-09`**(또는 FIPS 판)이고, 이 정책은 하이브리드 PQ-TLS·TLS 1.3 전용·TLS 1.2 전용 클라이언트를 **모두** 받아 전환 중 중단을 줄입니다
- ⚠️ **사용자 지정 보안 정책으로 암호 목록을 직접 만들 수는 없습니다** — 미리 정의된 정책에서 고릅니다

⚠️ 조직 차원 예방은 **ELB 조건 키를 IAM 정책과 SCP에 써서** 쓸 수 있는 보안 정책을 제한하는 것입니다.
</details>

**Q2.** 보안팀이 "리스너를 TLS 1.2 이상으로 묶었으니 로드 밸런서에서 대상까지 전 구간이 TLS 1.2 이상"이라고 보고했습니다. 맞습니까? (→ 1-3 백엔드 연결)

<details><summary>정답 보기</summary>

**아닙니다. 백엔드 연결의 보안 정책은 고를 수 없고 리스너 정책의 종류에 따라 자동으로 정해집니다.**

- 공식이 표로 적습니다 — 리스너가 **그 밖의 TLS 정책**을 쓰면 백엔드 연결은 **`ELBSecurityPolicy-2016-08`**을 씁니다. 즉 프런트엔드를 1.2로 묶어도 백엔드는 낡은 정책일 수 있습니다
- 백엔드를 올리려면 **리스너 정책의 종류 자체**를 바꿔야 합니다 — TLS 1.3 정책이면 백엔드가 `ELBSecurityPolicy-TLS13-1-0-2021-06`, PQ 정책이면 `...TLS13-1-0-PQ-2025-09`, FIPS 정책이면 `...TLS13-1-0-FIPS-2023-04`, RFC 9151 정책이면 `...RFC9151-INTEROP4-FIPS-2023-07`입니다
- ⚠️ 그리고 ALB는 **대상 연결에 대해서만 SSL 재협상을 지원**합니다

⚠️ 검증은 추측이 아니라 로그로 합니다 — **연결 로그**의 TLS 프로토콜 버전·키 교환 필드나 `tls_protocol`·`tls_cipher`·`tls_keyexchange`를 봅니다.
</details>

**Q3.** 다른 VPC(다른 계정)에 있는 Aurora 클러스터에 사설로 접근해야 합니다. 로드 밸런서를 세우지 않고, 엔드포인트 하나로 그 데이터베이스에만 닿게 하려면? (→ 2-1·2-2 엔드포인트 유형)

<details><summary>정답 보기</summary>

**리소스 제공자가 리소스 구성을 만들어 AWS RAM으로 공유하고, 소비자가 리소스 엔드포인트를 만듭니다.**

- **`Resource` 엔드포인트**는 다른 VPC나 온프레미스에 있는 **공유된 리소스**(데이터베이스·EC2 인스턴스·애플리케이션 엔드포인트·도메인 이름 대상·IP 주소)에 접근하고 ⚠️ **로드 밸런서가 필요하지 않습니다**
- 제공자 쪽은 **리소스 구성**(단일 리소스·리소스 그룹·네트워크 세그먼트를 나타내는 논리 객체)을 만들고, ⚠️ **다른 계정과 공유할 때는 AWS RAM 리소스 공유**로 그 계정의 특정 보안 주체가 연결할 수 있게 해야 합니다. 리소스가 공유되는 VPC의 진입점은 **리소스 게이트웨이**입니다
- 대비되는 선택지들 — **`Interface`**는 엔드포인트 서비스(제공자가 **로드 밸런서를 지정**해 만든 것)용이고, **`Service network`**는 VPC Lattice 서비스 네트워크에 **엔드포인트 하나로 여러 서비스·리소스**를 묶어 접근할 때, **`Gateway`**는 **S3·DynamoDB 전용**이며 ⚠️ **PrivateLink를 쓰지 않습니다**

⚠️ 유형의 **개수를 외우지 않습니다** — 공식 개념 페이지와 FAQ가 드는 목록이 다르고 늘어나는 값입니다.
</details>

**Q4.** 원격 근무자에게 VPC 내부 애플리케이션 접근을 주려 합니다. "SAML IdP로 연동하니 인증서는 필요 없다"고 보고가 왔습니다. 그리고 "퇴사자만 차단하고 싶다"는 요구가 있습니다. (→ 2-3 Client VPN)

<details><summary>정답 보기</summary>

**서버 인증서는 인증 유형과 무관하게 필요하고, 사용자별 차단은 클라이언트별 인증서 폐기로 합니다.**

- 공식이 Important 로 적습니다 — **"To create a Client VPN endpoint, you must provision a server certificate in AWS Certificate Manager, regardless of the type of authentication that you use."** SAML SSO를 쓰더라도 **ACM 서버 인증서가 필요**합니다
- 인증 유형은 **Active Directory(사용자 기반) · 상호 인증(인증서 기반) · SAML SSO(사용자 기반)** 셋이고, ⚠️ **상호 인증과 사용자 기반을 조합하면 둘 다 통과**해야 합니다
- "퇴사자만 차단"은 **상호 인증에서 클라이언트마다 인증서·키를 따로 만들어** 그 인증서를 폐기하는 길입니다
- ⚠️ 세부 제약 — **클라이언트 인증서를 ACM에 올리는 것은 CA가 서버 인증서의 CA와 다를 때만**이고, **RSA 1024·2048비트만** 지원하며 **클라이언트 인증서에는 Subject 필드의 CN이 있어야** 합니다

⚠️ 인증서를 갱신하면 Client VPN이 엔드포인트를 자동으로 갱신하지만 **최대 5시간**이 걸립니다 — "갱신했는데 바로 안 된다"의 설명입니다.
</details>

**Q5.** 감사에서 "두 AZ의 EC2 인스턴스가 Transit Gateway를 거쳐 통신하는데, 그 구간이 암호화되는지 증명하라"는 요구가 나왔습니다. 인스턴스는 Nitro 기반 지원 유형입니다. (→ 3-1 계층 넷)

<details><summary>정답 보기</summary>

**Nitro 인스턴스 간 하드웨어 암호화는 성립하지 않지만, 그 트래픽이 평문이라는 뜻도 아닙니다.**

- 공식 EKS 모범 사례 가이드가 적습니다 — **"When there's an intermediate hop, like a transit gateway or a load balancer, the traffic is not encrypted."** Transit Gateway가 중간 홉이므로 **Nitro 계층의 보장은 깨집니다**(그 계층의 조건은 **지원 인스턴스 유형 · 같은 리전 · 같은 VPC 또는 피어링된 VPC**입니다)
- 그런데 EC2 데이터 보호 문서가 **다른 계층**을 적습니다 — **"All traffic between AZs is encrypted"**(물리 계층), 그리고 **VPC 피어링과 Transit Gateway 피어링을 쓰는 교차 리전 트래픽은 리전을 나갈 때 자동 벌크 암호화**됩니다
- 따라서 감사 답변은 **계층을 나눠** 해야 합니다: AZ 간 구간은 **물리 계층에서 자동 암호화**되고, 애플리케이션 수준의 종단 간 인증·무결성이 필요하면 **TLS를 명시적으로 구성**합니다
- ⚠️ 지원 인스턴스 유형 목록은 길고 늘어나므로 외우지 않고, 공식 문서의 **AWS CLI 조회 절차**로 확인합니다

⚠️ 기준선도 함께 기억합니다 — AWS는 **TLS 1.2를 요구하고 1.3을 권장**하며, FIPS 140-3 검증 모듈이 필요하면 **FIPS 엔드포인트**를 씁니다.
</details>

**Q6.** 데이터팀이 EMR 보안 구성으로 전송 중 암호화를 켰는데, 일부 엔드포인트가 여전히 평문이라고 합니다. 그리고 보안 정책이 "개인 키를 S3에 두지 말라"고 합니다. (→ 3-2 EMR)

<details><summary>정답 보기</summary>

**SASL을 쓰는 엔드포인트는 Kerberos 인증이 켜져 있어야 하고, 인증서는 사용자 지정 공급자로 줍니다.**

- 공식이 적습니다 — 보안 구성으로 전송 중 암호화를 켜면 EMR이 **지원하는 모든 오픈 소스 애플리케이션 엔드포인트**에 설정을 맞추지만, ⚠️ **일부 통신 채널은 추가 보안 구성이 필요**합니다. **SASL을 쓰는 엔드포인트는 그 EMR 클러스터 보안 구성에 Kerberos 인증이 켜져 있어야** 합니다
- 그리고 ⚠️ 이 기능들은 **오픈 소스 기능이고 애플리케이션별이며 EMR 릴리스 버전마다 다릅니다** — 어느 엔드포인트가 덮이는지는 **전송 중 암호화 지원 매트릭스**로 확인합니다
- 인증서를 주는 방법은 둘 — **S3 버킷의 `.zip` 파일 경로**와 **사용자 지정 인증서 공급자(Java 클래스)**입니다. "개인 키를 S3에 두지 말라"는 정책에서는 **후자**가 답입니다
- 필요하면 오픈 소스 구성을 덮어써 **TLS 호스트 이름 검증 끄기 · 특정 엔드포인트만 끄기 · TLS 버전·암호 제어**를 할 수 있습니다

⚠️ 참고로 **EMR 7.0.0 이상**에서는 대부분의 오픈 소스 프레임워크가 **TLS 1.2 이상을 강제**합니다.
</details>

### 📌 출처

1. Security policies for your Application Load Balancer — `docs.aws.amazon.com/elasticloadbalancing/latest/application/describe-ssl-policies.html` (2026-11-09 확인)
2. Create an HTTPS listener for your Application Load Balancer — `docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html` (2026-11-09 확인)
3. AWS PrivateLink concepts — `docs.aws.amazon.com/vpc/latest/privatelink/concepts.html` (2026-11-09 확인)
4. Access an AWS service using an interface VPC endpoint — `docs.aws.amazon.com/vpc/latest/privatelink/create-interface-endpoint.html` (2026-11-09 확인)
5. Client authentication in AWS Client VPN — `docs.aws.amazon.com/vpn/latest/clientvpn-admin/client-authentication.html` (2026-11-09 확인)
6. Mutual authentication in AWS Client VPN — `docs.aws.amazon.com/vpn/latest/clientvpn-admin/mutual.html` (2026-11-09 확인)
7. What is AWS Verified Access? — `docs.aws.amazon.com/verified-access/latest/ug/what-is-verified-access.html` (2026-11-09 확인)
8. Data protection in Amazon EC2 — `docs.aws.amazon.com/AWSEC2/latest/UserGuide/data-protection.html` (2026-11-09 확인)
9. Encryption options for Amazon EMR — `docs.aws.amazon.com/emr/latest/ManagementGuide/emr-data-encryption-options.html` (2026-11-09 확인)
10. Protect Communications Between ML Compute Instances in a Distributed Training Job — `docs.aws.amazon.com/sagemaker/latest/dg/train-encrypt.html` (2026-11-09 확인)
11. Network security - Amazon EKS Best Practices Guide — `docs.aws.amazon.com/eks/latest/best-practices/network-security.html` (2026-11-09 확인)
