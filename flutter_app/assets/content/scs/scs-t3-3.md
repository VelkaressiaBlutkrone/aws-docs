---
examGuideTaskId: scs-t3-3
certCode: SCS-C03
domain: 3
domainName: 인프라 보안
domainWeightPct: 18
title: 네트워크 보안 제어 (허용과 차단·하이브리드 보안 연결·Verified Access·세분화·불필요한 액세스 식별)
coversTasks:
  - "3.3"
sources:
  - title: Infrastructure security in Amazon VPC
    url: https://docs.aws.amazon.com/vpc/latest/userguide/infrastructure-security.html
  - title: Control subnet traffic with network access control lists
    url: https://docs.aws.amazon.com/vpc/latest/userguide/vpc-network-acls.html
  - title: What is AWS Network Firewall?
    url: https://docs.aws.amazon.com/network-firewall/latest/developerguide/what-is-aws-network-firewall.html
  - title: AWS Network Firewall example architectures with routing
    url: https://docs.aws.amazon.com/network-firewall/latest/developerguide/architectures.html
  - title: What is AWS Site-to-Site VPN?
    url: https://docs.aws.amazon.com/vpn/latest/s2svpn/VPC_VPN.html
  - title: MAC Security in Direct Connect
    url: https://docs.aws.amazon.com/directconnect/latest/UserGuide/MACsec.html
  - title: What is AWS Verified Access?
    url: https://docs.aws.amazon.com/verified-access/latest/ug/what-is-verified-access.html
  - title: How AWS Transit Gateway works
    url: https://docs.aws.amazon.com/vpc/latest/tgw/how-transit-gateways-work.html
  - title: What is Network Access Analyzer?
    url: https://docs.aws.amazon.com/vpc/latest/network-access-analyzer/what-is-network-access-analyzer.html
  - title: Network Access Scopes in Network Access Analyzer
    url: https://docs.aws.amazon.com/vpc/latest/network-access-analyzer/working-with-network-access-scopes.html
  - title: Amazon Inspector finding types
    url: https://docs.aws.amazon.com/inspector/latest/user/findings-types.html
lastVerified: 2026-11-08
---

# 네트워크 보안 제어 (허용과 차단·하이브리드 보안 연결·Verified Access·세분화·불필요한 액세스 식별)

> **커버하는 공식 Task** — SCS-C03 · 도메인 3 「인프라 보안」(18%) · **작업 3.3 네트워크 보안 제어 설계 및 문제 해결** (`scs-t3-3`)
> 이 문서는 위 한 작업에 1:1로 매핑되고 공식 기술 5개(3.3.1~3.3.5)를 모두 덮습니다. 작업 3.1이 **AWS 바깥에서 들어오는 요청**을 다뤘다면 이 작업은 **VPC 안과 온프레미스 사이**입니다.

> ⚠️ 이 작업의 문항은 **"어느 제어가 그 트래픽을 볼 수 있는가"**로 거의 다 환원됩니다. 보안 그룹·네트워크 ACL·Network Firewall이 **각각 보지 못하는 트래픽**이 있고(§1), Transit Gateway는 **설정 하나로 상태 저장 검사를 깨뜨립니다**(§4-2). 그 목록이 이 문서의 뼈대입니다.

---

## ✅ 학습 목표 체크리스트

- [ ] 보안 그룹과 네트워크 ACL을 **다섯 특성**으로 가른다
- [ ] 네트워크 ACL이 **평가하지 않는 트래픽**을 말한다
- [ ] Network Firewall의 **방화벽 서브넷 규칙**과 **미지원 아키텍처**를 안다
- [ ] Site-to-Site VPN의 **터널 두 개의 의미**와 한계를 설명한다
- [ ] MACsec이 **무엇을 보호하지 않는지**와 두 암호화 모드를 구분한다
- [ ] Verified Access가 **VPN을 대신하는 방식**을 설명한다
- [ ] 상태 저장 검사에서 **어플라이언스 모드**가 필요한 이유를 안다
- [ ] 불필요한 액세스를 찾는 **세 수단**을 질문의 모양에 따라 고른다

## 🎯 왜 중요한가

네트워크 문항은 **"규칙은 맞는데 트래픽이 안 간다"**거나 반대로 **"막았다고 생각했는데 간다"**로 나옵니다. 둘 다 **그 제어가 그 트래픽을 평가하는지**를 모르면 풀 수 없습니다.

그리고 Specialty 시험은 **"보이지 않는 반쪽"**을 좋아합니다. 상태 비저장 NACL에서 **응답 트래픽을 열지 않은 경우**, 상태 저장 어플라이언스에서 **응답이 다른 AZ로 간 경우**가 대표입니다. §1-2와 §4-2가 그 자리입니다.

## ⚡ 시험 직전 요약

- **보안 그룹은 인스턴스 수준·허용 규칙만·모든 규칙 평가·상태 저장**, **NACL은 서브넷 수준·허용과 거부·번호 순 평가·상태 비저장**입니다
- ⚠️⚠️ **NACL은 서브넷 안에서 라우팅되는 트래픽을 평가하지 않습니다** — 같은 서브넷 인스턴스 간 통신은 막을 수 없습니다
- ⚠️⚠️ **NACL로 막을 수 없는 것** — Route 53 Resolver DNS 요청 · **인스턴스 메타데이터(IMDS)** · DHCP · **ECS 작업 메타데이터** · Windows 라이선스 활성화 · **Amazon Time Sync** · 기본 VPC 라우터의 예약 IP
- **Network Firewall은 Suricata 기반 상태 저장 IPS**이고 ⚠️ **방화벽 서브넷은 전용**이며 **그 서브넷 자체의 트래픽은 필터링하지 못합니다**
- ⚠️⚠️ **Network Firewall은 VPC 피어링 트래픽을 검사하지 못합니다**(클라이언트 IP 보존을 켠 Global Accelerator, EC2의 AmazonProvidedDNS도 미지원)
- **Site-to-Site VPN의 터널 두 개는 「고가용성」**이고 ⚠️ **가상 프라이빗 게이트웨이는 VPC 하나에만** 붙습니다
- ⚠️⚠️ **MACsec은 점대점 L2 암호화이고 여러 세그먼트를 지나는 종단 간 암호화가 아닙니다.** 기본 모드는 **`should_encrypt`**(실패 시 비암호화로 폴백)입니다
- **Verified Access는 VPN 없이 요청마다 실시간 평가**하고 **모든 액세스 시도를 로깅**합니다
- ⚠️⚠️ 상태 저장 어플라이언스가 여러 AZ에 걸친 VPC 트래픽을 검사하려면 **어플라이언스 모드**를 켜야 합니다 — 켜지 않으면 응답이 **다른 AZ의 어플라이언스로 가서 드롭**됩니다
- 불필요한 액세스는 **Network Access Analyzer(스코프 선언·온디맨드)** / **Inspector 네트워크 도달성(EC2 전용·12시간)** / **Verified Access(접근 자체를 조건부로)**로 가릅니다

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **상태 저장(stateful)** | 이전에 주고받은 트래픽을 기억해 **응답을 자동 허용**합니다. 보안 그룹이 그렇습니다 |
| **상태 비저장(stateless)** | 기억하지 않으므로 **응답도 명시적으로 허용**해야 합니다. NACL이 그렇습니다 |
| **북-남(north-south) 트래픽** | VPC 경계를 **넘는** 트래픽(인터넷·온프레미스 방향) |
| **동-서(east-west) 트래픽** | VPC·서브넷 **사이**를 오가는 내부 트래픽 |
| **방화벽 서브넷** | Network Firewall 엔드포인트 전용으로 지정한 서브넷. ⚠️ 다른 용도로 쓰지 않습니다 |
| **어플라이언스 모드** | 요청과 응답이 **같은 AZ의 같은 어플라이언스**를 지나게 하는 Transit Gateway VPC 어태치먼트 설정 |
| **CKN / CAK** | MACsec 키를 유도하는 이름·키 쌍. 내가 생성해 양쪽에 프로비저닝합니다 |
| **SAK** | CKN/CAK에서 **유도되는 세션 키**. 사전 공유하지 않고 자동 교체됩니다 |
| **네트워크 액세스 스코프** | 허용할·금지할 경로를 선언하는 Network Access Analyzer의 요구 사항 명세 |

## 📖 핵심 개념

### 1) 트래픽을 허용·차단하는 제어를 설계한다 (기술 3.3.1) {#controls}

#### 1-1. 보안 그룹과 네트워크 ACL — 공식 비교표

| 특성 | **보안 그룹** | **네트워크 ACL** |
|---|---|---|
| 동작 수준 | **인스턴스 수준** | **서브넷 수준** |
| 적용 범위 | 그 보안 그룹에 연결된 모든 인스턴스 | 연결된 서브넷의 모든 인스턴스 |
| 규칙 유형 | **허용 규칙만** | **허용과 거부 규칙** |
| 규칙 평가 | **모든 규칙을 평가한 뒤** 허용 여부를 결정 | **번호 오름차순으로 평가해 매칭되면 중단** |
| 반환 트래픽 | **자동 허용(상태 저장)** | **명시적으로 허용해야 함(상태 비저장)** |

공식 권고는 **"보안 그룹만으로도 인스턴스를 보호할 수 있지만, 네트워크 ACL을 추가 방어 계층으로 둘 수 있다"**입니다. 즉 **NACL이 필수는 아니고 심층 방어**입니다.

⚠️ NACL의 구조적 사실 — 각 서브넷은 **정확히 하나의 NACL**에 연결되고(지정하지 않으면 **기본 NACL**), 하나의 NACL은 **여러 서브넷**에 쓸 수 있습니다. 규칙 번호는 **1~32766**이고 낮은 번호부터 평가해 **처음 매칭된 규칙만** 적용합니다 — 그래서 **10이나 100 단위로 띄워** 만들라는 권고가 붙습니다.

#### 1-2. ⚠️⚠️ NACL이 평가하지 않는 트래픽

공식 문서가 두 가지를 구분해 적습니다.

**첫째, 평가 시점** — **트래픽이 서브넷에 들어오고 나갈 때** 평가하고 **서브넷 안에서 라우팅될 때는 평가하지 않습니다.** 즉 **같은 서브넷에 있는 인스턴스끼리의 통신은 NACL로 막을 수 없습니다**(그것은 보안 그룹의 일입니다).

**둘째, 아예 대상이 아닌 트래픽**

- ⚠️ **Route 53 Resolver로 가는·오는 DNS 요청**(VPC+2 주소, AmazonProvidedDNS) — 필터링하려면 **Route 53 Resolver DNS Firewall**을 켭니다
- ⚠️ **인스턴스 메타데이터 서비스(IMDS)** — 관리하려면 **인스턴스 메타데이터 옵션**을 씁니다
- 그리고 다음으로 가는·오는 트래픽을 필터링하지 않습니다 — **Amazon DNS · DHCP · EC2 인스턴스 메타데이터 · ECS 작업 메타데이터 엔드포인트 · Windows 인스턴스 라이선스 활성화 · Amazon Time Sync Service · 기본 VPC 라우터가 쓰는 예약 IP 주소**

⚠️⚠️ **이 목록이 문항이 됩니다** — "NACL로 아웃바운드를 전부 거부했는데 왜 DNS가 되는가", "IMDS 접근을 NACL로 막으려 한다"는 지문의 답이 여기 있습니다. **IMDS는 IMDSv2 강제와 메타데이터 옵션**으로 다룹니다.

#### 1-3. AWS Network Firewall — 상태 저장 검사와 그 경계

Network Firewall은 VPC를 위한 **상태 저장 관리형 네트워크 방화벽이자 침입 탐지·방지 서비스(IDS/IPS)**이고, 상태 저장 검사에 **오픈 소스 Suricata**를 써서 **Suricata 호환 규칙**을 지원합니다. 인터넷 게이트웨이·NAT 게이트웨이·VPN·Direct Connect를 **드나드는 트래픽**을 VPC 경계에서 걸러냅니다.

할 수 있는 일 넷 — **알려진 AWS 서비스 도메인·IP로만 통과** · **알려진 악성 도메인 목록으로 제한** · **심층 패킷 검사** · ⚠️ **상태 저장 프로토콜 탐지로 포트와 무관하게 HTTPS 같은 프로토콜을 필터**.

관리하는 리소스는 넷입니다.

| 리소스 | 역할 |
|---|---|
| **Firewall** | 보호할 주 VPC와 **AZ마다의 방화벽 엔드포인트 서브넷**을 정의 |
| **VpcEndpointAssociation** | 주 VPC나 **다른 VPC**에 **추가 엔드포인트**를 제공 |
| **FirewallPolicy** | 규칙과 설정을 정의 |
| **RuleGroup** | 매칭 규칙과 작업. **상태 비저장·상태 저장 두 유형**이고 각각 ARN을 가집니다 |

⚠️⚠️ **방화벽 서브넷의 제약이 설계를 결정합니다** — 공식이 **"방화벽 엔드포인트는 자신이 속한 서브넷으로 들어오거나 나가는 트래픽을 필터링할 수 없으므로, 방화벽 서브넷을 Network Firewall 외의 용도로 쓰지 마십시오"**라고 적습니다. 트래픽은 **VPC 라우트 테이블로 방화벽에 유도**합니다.

⚠️ **상태 테이블은 상태 저장 규칙이 처리한 플로만 추적**합니다. 플로의 동일성 기준은 **대상·대상 포트·방향·프로토콜·소스·소스 포트**이고 플로 로그에서 볼 수 있습니다.

⚠️⚠️ **미지원 아키텍처 세 가지가 가장 중요한 실측입니다.**

1. **VPC 피어링** — 피어링으로 오가는 트래픽은 검사할 수 없습니다
2. **클라이언트 IP 주소 보존을 켠 AWS Global Accelerator 트래픽**
3. **EC2의 AmazonProvidedDNS 트래픽**

⚠️ 기본 동작 모드는 **소스 보존(source-preservation) 모드**입니다 — VPC 엔드포인트에서 트래픽을 받아 검사하고 다시 엔드포인트로 돌려보내며 **원래 소스·대상 IP를 유지**합니다. 모든 프로토콜(TCP·UDP·ICMP)을 지원하고 **동-서·북-남 검사**에 맞습니다. **소스 비보존 모드**는 명시적 정방향 프록시로 동작하지만 ⚠️ **현재 프리뷰이고 US East(오하이오) 리전에서만** 제공되므로 설계의 전제로 삼지 않습니다.

⚠️ **Firewall Manager가 Network Firewall을 지원**하므로 조직 전체의 방화벽을 한 계정에서 중앙 구성·관리할 수 있습니다.

### 2) 하이브리드·멀티 클라우드 보안 연결 (기술 3.3.2) {#hybrid}

#### 2-1. Site-to-Site VPN — 터널 두 개의 의미

Site-to-Site VPN은 **IPsec** VPN 연결을 지원합니다. 구성 요소는 **VPN 연결 · VPN 터널 · 고객 게이트웨이(AWS 쪽 리소스) · 고객 게이트웨이 장치(내 쪽 물리·소프트웨어) · 대상 게이트웨이**입니다.

⚠️⚠️ **공식 문장이 정확히 이렇습니다 — "각 VPN 연결에는 고가용성을 위해 동시에 사용할 수 있는 VPN 터널 두 개가 포함됩니다."** 「부하 분산」이나 「대역폭 두 배」가 아닙니다.

대상 게이트웨이는 둘입니다.

- **가상 프라이빗 게이트웨이(VGW)** — ⚠️ **VPC 하나에만 연결**됩니다
- **Transit Gateway** — 여러 VPC와 온프레미스를 잇는 허브이자 VPN 종단

⚠️ 기능 중 보안에 걸리는 것 — **IKEv2 · NAT 통과 · AES 256비트 암호화·SHA-2 해싱·추가 Diffie-Hellman 그룹 · 구성 가능한 터널 옵션 · Amazon 쪽 BGP 세션의 사용자 지정 프라이빗 ASN · AWS Private CA 하위 CA의 프라이빗 인증서**. ⚠️ **대규모 대역폭 터널(Large Bandwidth Tunnel)**은 터널당 **최대 5 Gbps**(표준 1.25 Gbps)이고 **Transit Gateway 또는 Cloud WAN에 연결된 VPN**에서만 쓸 수 있습니다.

⚠️ 한계도 시험에 나옵니다 — **경로 MTU 탐색(PMTU Discovery) 미지원** · ⚠️ **한 연결이 IPv4와 IPv6를 동시에 나르지 못합니다**(각각 별 연결 필요) · **VGW에서는 IPv6 트래픽 미지원**(외부 터널 IP의 IPv6는 Transit Gateway·Cloud WAN만) · **기존 IPv4 연결을 IPv6로 변경할 수 없어 삭제 후 재생성**해야 합니다. 그리고 공통 온프레미스 네트워크에 여러 VPC를 붙일 때는 **CIDR이 겹치지 않게** 하라는 권고가 붙습니다.

#### 2-2. MACsec — 무엇을 보호하고 무엇을 보호하지 않는가

MACsec은 **데이터 기밀성·무결성·데이터 출처 인증**을 제공하는 **IEEE 802.1AE** 표준이고, Direct Connect에서는 **교차 연결(cross-connect) 구간의 계층 2 점대점 암호화**입니다. 두 L3 라우터 사이에서 동작하고, **MACsec 지원 인터페이스**가 고객 엣지 장치에 있어야 합니다.

⚠️⚠️ **공식 경고가 핵심입니다 — "MACsec은 이더넷 링크의 점대점 보안을 제공하므로, 여러 개의 연속된 이더넷이나 다른 네트워크 세그먼트를 지나는 종단 간 암호화를 제공하지 않습니다."** "온프레미스 애플리케이션에서 S3까지 전 구간 암호화"를 요구하는 지문에서 MACsec만 고르면 틀립니다.

⚠️ 함께 적힌 사실 — **AWS가 Direct Connect 로케이션과 AWS 리전 사이 네트워크를 흐르는 모든 데이터를 물리 계층에서 암호화**합니다. MACsec은 그 앞 구간(내 라우터 ↔ DX 로케이션)을 덮어 **계층적 보안**을 만듭니다.

**키 체계가 두 층입니다.**

| 키 | 성격 |
|---|---|
| **CKN / CAK** | 내가 생성해 연결에 연관시키고 **내 엣지 장치에도 프로비저닝**합니다. ⚠️ **정적 CAK 모드만 지원**(동적 CAK 미지원)이라 **키 생성·배포·교체 정책은 내 책임**입니다 |
| **SAK** | ⚠️ **사전 공유가 아니라 CKN/CAK 쌍에서 암호학적으로 유도**됩니다. **주기·암호화 트래픽 양·세션 수립 시 자동 교체**되고 **영구 저장되지 않습니다** |

⚠️ 키 형식은 **정확히 64자 16진수**이고 전용 연결에는 **AES 256비트 키만** 지원됩니다. 키체인은 **CKN/CAK 쌍 세 개까지** 저장해 **연결 중단 없이 수동 교체**할 수 있고, 새 키가 내 장치와 맞지 않으면 **이전에 동작하던 키로 폴백**합니다. 새 쌍을 AWS에 전달할 때는 `associate-mac-sec-key`를 쓰고 공식 권고가 **TLS 1.3과 ML-KEM 같은 포스트 양자 키 교환 알고리즘**을 쓰라고 적습니다.

⚠️⚠️ **암호화 모드 둘이 가용성과 보안의 트레이드오프입니다.**

- **`must_encrypt`** — 모든 트래픽에 MACsec을 요구합니다. 협상이 실패하면 **트래픽을 전혀 전송하지 않습니다**. 보안은 최고이고 **가용성에 영향**을 줄 수 있습니다
- **`should_encrypt`** — 협상이 실패하면 **비암호화 통신으로 폴백**합니다. ⚠️ **새 MACsec 활성 연결의 기본값이 이쪽**입니다(초기 설정 중 연결 문제 방지)

**지원 연결은 전용 연결 · LAG · 파트너 인터커넥트**입니다.

### 3) 하이브리드 환경의 워크로드 요구를 Verified Access로 (기술 3.3.3) {#verified-access}

**AWS Verified Access**는 **VPN을 쓰지 않고** 애플리케이션에 안전하게 접근하게 합니다. 전통적 모델이 **한 번 평가해 모든 애플리케이션 접근을 허용**하는 것과 달리, Verified Access는 ⚠️ **애플리케이션 접근 요청마다 실시간으로 평가**해 공격자가 **한 애플리케이션에서 다른 애플리케이션으로 이동하기 어렵게** 만듭니다.

- **ID·디바이스 관리 서비스와 통합**됩니다(AWS와 **타사 둘 다**). 그 데이터로 **사용자와 디바이스의 신뢰성**을 보안 요구 사항에 대조해 접근 여부를 정합니다
- **사용자 경험** — VPN이 없어 VPN 관련 지원 요청이 줄어듭니다
- ⚠️ **모든 접근 시도를 로깅**해 애플리케이션 접근에 대한 중앙 가시성을 주므로 **보안 사고 대응과 감사 요청**에 바로 씁니다
- 과금은 **애플리케이션당 시간 + 처리 데이터량**입니다
- ⚠️ Verified Access 인스턴스는 **AWS WAF로 보호할 수 있는 리소스 목록**에 들어 있습니다(작업 3.1 §1-2) — 접근 제어 앞단에 L7 검사를 더할 수 있습니다

⚠️ **Site-to-Site VPN과의 갈림길** — "온프레미스 네트워크와 VPC를 네트워크 수준에서 연결"하는 것은 VPN·Direct Connect이고, **"사용자가 내부 애플리케이션에 접근"**하는 것은 Verified Access입니다. 지문이 **디바이스 자세·ID 조건**을 말하면 거의 Verified Access입니다.

### 4) 네트워크 세분화를 설계한다 (기술 3.3.4) {#segmentation}

#### 4-1. 격리의 층

공식 기술이 드는 두 축이 **북-남/동-서 트래픽 보호**와 **격리된 서브넷**입니다. 실무 설계는 층을 겹칩니다.

| 층 | 수단 | 비고 |
|---|---|---|
| 서브넷 | **라우트 테이블 + NACL** | 인터넷 경로가 없는 **프라이빗·격리 서브넷** |
| 인스턴스 | **보안 그룹** | ⚠️ 같은 서브넷 내부 통신은 **여기서만** 막힙니다 |
| VPC 경계(북-남) | **Network Firewall** | IGW·NAT·VPN·DX를 드나드는 트래픽 |
| VPC 사이(동-서) | **Transit Gateway + 검사 VPC** | ⚠️ **피어링은 Network Firewall이 검사하지 못합니다**(§1-3) |
| 조직 전체 일괄 | **Firewall Manager** | 계정마다 손으로 붙이지 않습니다 |

⚠️⚠️ **설계 판정 하나** — 동-서 트래픽을 검사해야 하는데 VPC를 **피어링**으로 묶어 두면 Network Firewall을 쓸 수 없습니다. **Transit Gateway를 경유시켜 검사 VPC로 유도**하는 것이 공식 제약에서 따라오는 결론입니다.

#### 4-2. ⚠️⚠️ 어플라이언스 모드 — 켜지 않으면 응답이 드롭된다

Transit Gateway는 **리전 가상 라우터**이고 **계층 3에서 대상 IP를 보고 다음 홉 어태치먼트**로 보냅니다. VPC를 붙일 때 **AZ마다 서브넷을 정확히 하나** 지정해 네트워크 인터페이스를 두고, ⚠️ **어태치먼트가 있는 AZ의 리소스만 Transit Gateway에 도달**할 수 있습니다.

**어플라이언스 모드를 켜지 않은 기본 동작**은 이렇습니다 — Transit Gateway는 VPC 어태치먼트 사이 트래픽을 **출발 AZ 안에 유지**하려 하고, **AZ 장애나 그 AZ에 서브넷이 없을 때만** AZ를 넘습니다.

⚠️⚠️ **그래서 상태 저장 어플라이언스가 깨집니다.** 공식 설명의 예가 그대로 시험 문항입니다 — VPC A에서 출발한 요청을 **AZ 1의 어플라이언스**가 검사했는데, VPC B의 **AZ 2**에서 나온 응답은 Transit Gateway가 **VPC C의 같은 AZ 2로** 보냅니다. **AZ 2의 어플라이언스는 원래 요청을 모르므로 트래픽이 드롭됩니다.**

해법은 공식 그대로입니다 — **VPC 어태치먼트가 여러 AZ에 걸쳐 있고 소스·대상 호스트 사이 트래픽이 상태 저장 검사를 위해 같은 어플라이언스를 지나야 하면, 어플라이언스가 있는 VPC 어태치먼트에서 어플라이언스 모드 지원을 켭니다.**

⚠️ 공유 서비스 VPC 설계의 라우팅도 함께 기억합니다 — 검사 VPC는 **서브넷마다 다른 라우트 테이블**을 둡니다. Transit Gateway가 쓰는 서브넷은 **모든 트래픽을 어플라이언스 ENI로**, 어플라이언스가 있는 서브넷은 **모든 트래픽을 다시 Transit Gateway로** 보냅니다.

⚠️ **교차 AZ 트래픽에는 추가 Transit Gateway 요금이 없습니다**(어태치먼트가 없는 AZ에서 온 트래픽을 내부적으로 임의 AZ로 라우팅하는 경우).

⚠️ ECMP 제약도 설계에 걸립니다 — **VPC는 ECMP 미지원**(CIDR이 겹칠 수 없으므로) · **Transit Gateway 피어링 미지원** · ⚠️ **서로 다른 어태치먼트 유형 간 ECMP 불가**(VPN과 VPC 사이) · **다른 ASN 사이도 불가**. Direct Connect 게이트웨이는 **네트워크 접두사·접두사 길이·AS_PATH가 정확히 같을 때** 여러 어태치먼트에 ECMP가 적용됩니다.

### 5) 불필요한 네트워크 액세스를 식별한다 (기술 3.3.5) {#identify}

#### 5-1. 세 수단은 질문의 모양이 다르다

| 질문의 모양 | 수단 | 성격 |
|---|---|---|
| "**이 연결은 우리 정책 위반인가**" | **Network Access Analyzer** | 내가 **요구 사항을 선언**하고 위반 경로를 찾습니다 |
| "**이 EC2가 외부에서 닿는가**" | **Inspector 네트워크 도달성** | 선언 없이 **열린 경로**를 알려 줍니다 |
| "**이 사용자가 지금 이 앱에 접근해도 되는가**" | **Verified Access** | 탐지가 아니라 **접근 자체를 조건부로** 만듭니다 |

#### 5-2. Network Access Analyzer — 스코프를 선언한다

**네트워크 액세스 스코프**로 네트워크 접근 요구 사항을 명세합니다. 스코프는 **아웃바운드·인바운드 트래픽 패턴**(소스·대상·경로·트래픽 유형)을 정의하고 **하나 이상의 매칭 조건과 0개 이상의 제외 조건**으로 이뤄집니다.

- **MatchPaths** — 분석이 **찾아낼** 경로 유형. 보통 **정책·준수 위반으로 보는 경로**를 적습니다(예: VPC A에서 시작해 VPC B에서 끝나는 경로)
- **ExcludePaths** — 조사 결과에 **나타나지 않게 할** 경로. 보통 **정당한 예외**를 적습니다(예: 인터넷 게이트웨이에서 닿는 네트워크 인터페이스 중 **웹 서버는 제외**)
- ⚠️ **조사 결과의 정의** — **MatchPaths 중 하나 이상에 맞고 ExcludePaths 중 어느 것에도 맞지 않는** 잠재 경로입니다

⚠️ **자동 추론(automated reasoning) 기술**을 씁니다 — IAM Access Analyzer · VPC Reachability Analyzer · Inspector 네트워크 도달성과 **같은 계열의 증명 기반 보안 도구**입니다. 그래서 "트래픽을 흘려 보는 테스트"가 아니라 **구성만 보고 수학적으로 판정**합니다.

⚠️ 분석 대상에 **보안 그룹 · CIDR 블록 · 접두사 목록 · 네트워크 인터페이스 · EC2 인스턴스 · 로드밸런서 · VPC·서브넷 · VPC 엔드포인트·엔드포인트 서비스 · Transit Gateway · NAT 게이트웨이 · 인터넷 게이트웨이 · VPN 게이트웨이 · 피어링 연결 · Network Firewall**이 듭니다. 스코프는 **리소스 그룹**으로 태그 기반 참조를 할 수 있습니다.

⚠️ **온디맨드 분석**입니다 — 스코프를 고르고 분석을 시작하면 **몇 분** 뒤 조사 결과가 납니다. "상시 감시"가 필요하면 **주기적으로 분석을 실행하는 자동화**를 따로 둡니다.

#### 5-3. Inspector 네트워크 도달성 — 선언이 없는 쪽

⚠️ **EC2 인스턴스 전용**이고 **12시간마다** 스캔합니다. 조사 결과는 **TCP·UDP 포트가 VPC 경계에서 닿을 수 있음**을 뜻하고, 경계는 **인터넷 게이트웨이(ALB·CLB 뒤의 인스턴스 포함) · VPC 피어링 연결 · 가상 프라이빗 게이트웨이를 통한 VPN**입니다.

⚠️ 평가에 쓰는 구성이 **EC2 인스턴스 · ALB·ELB · Direct Connect · 네트워크 인터페이스 · 인터넷 게이트웨이 · 네트워크 ACL · 라우트 테이블 · 보안 그룹 · 서브넷 · VPC · 가상 프라이빗 게이트웨이 · VPC 엔드포인트·게이트웨이 엔드포인트 · 피어링 연결 · VPN 연결**입니다. 공식 표현이 **"잘못 관리된 보안 그룹·액세스 제어 목록·인터넷 게이트웨이처럼 과도하게 허용적인 네트워크 구성"**을 드러낸다는 것입니다.

⚠️⚠️ **두 수단의 차이를 한 줄로** — Network Access Analyzer는 **"내 정책을 위반하는 경로"**(선언 필요, 리소스 범위 넓음)이고, Inspector 네트워크 도달성은 **"이 EC2에 열린 경로"**(선언 없음, EC2만, 12시간 주기)입니다.

## ✍️ 시험 포인트

- **"같은 서브넷 인스턴스끼리 통신을 막아라"는 보안 그룹이다** — NACL은 서브넷 내부 라우팅을 평가하지 않습니다
- **"NACL 아웃바운드를 전부 거부했는데 DNS·NTP가 된다"는 예외 목록이다**
- **"IMDS 접근 제한"은 NACL이 아니라 메타데이터 옵션(IMDSv2)이다**
- **"상태 비저장 제어에서 응답이 끊긴다"는 임시 포트 범위 인바운드·아웃바운드다**
- **"방화벽 서브넷에 다른 리소스를 두면 안 된다"는 엔드포인트가 자기 서브넷 트래픽을 필터링하지 못하기 때문이다**
- **"피어링 트래픽을 검사하라"는 Network Firewall로 안 된다** — Transit Gateway 경유 검사 VPC입니다
- **"VPN 터널 두 개로 대역폭을 두 배"는 틀렸다** — 공식 표현은 **고가용성**입니다
- **"온프레미스에서 S3까지 전 구간 암호화"는 MACsec만으로 안 된다** — 점대점입니다
- **"MACsec 협상 실패 시 트래픽을 흘리지 말라"는 `must_encrypt`다** — 기본값은 `should_encrypt`입니다
- **"SAK를 사전 공유한다"는 틀렸다** — CKN/CAK에서 유도되고 자동 교체됩니다
- **"VPN 없이 디바이스 자세를 보고 앱 접근"은 Verified Access다**
- **"여러 AZ에서 상태 저장 검사가 깨진다"는 어플라이언스 모드다**
- **"정책 위반 경로를 찾아라"는 Network Access Analyzer, "이 EC2가 외부에 열렸나"는 Inspector 네트워크 도달성이다**

## ⚠️ 흔한 함정 {#pitfalls}

- ❌ "NACL은 보안 그룹보다 강하므로 항상 둬야 한다" → 공식은 **추가 방어 계층**으로 설명하고 보안 그룹만으로도 가능하다고 적습니다
- ❌ "NACL 규칙은 모두 평가된다" → **번호 오름차순으로 첫 매칭에서 중단**합니다
- ❌ "NACL로 Route 53 Resolver DNS를 막는다" → **못 막습니다. DNS Firewall**입니다
- ❌ "한 서브넷에 NACL 두 개를 연결한다" → 서브넷은 **하나만** 연결됩니다
- ❌ "Network Firewall 엔드포인트 서브넷에 애플리케이션을 함께 둔다" → **그 서브넷 트래픽은 필터링되지 않습니다**
- ❌ "소스 비보존 모드로 프록시 구성을 설계한다" → **프리뷰이고 한 리전 전용**입니다
- ❌ "Network Firewall이 AmazonProvidedDNS와 피어링도 본다" → **둘 다 미지원**입니다
- ❌ "VGW 하나에 여러 VPC를 붙인다" → **VPC 하나**입니다. 여러 VPC는 Transit Gateway입니다
- ❌ "한 VPN 연결로 IPv4와 IPv6를 함께 나른다" → **연결을 따로** 만들어야 합니다
- ❌ "MACsec은 동적 CAK로 자동 교체된다" → **정적 CAK만** 지원하고 CKN/CAK 교체는 **내 책임**입니다
- ❌ "MACsec 키체인에 쌍을 무제한 넣는다" → **세 개까지**입니다
- ❌ "어플라이언스 모드는 성능 옵션이다" → **상태 저장 검사의 정확성** 문제이고 끄면 **응답이 드롭**됩니다
- ❌ "Transit Gateway는 VPN과 VPC 사이에도 ECMP를 한다" → **서로 다른 어태치먼트 유형 간에는 불가**합니다
- ❌ "Network Access Analyzer가 상시로 감시한다" → **온디맨드 분석**입니다
- ❌ "Inspector 네트워크 도달성으로 Lambda·컨테이너의 노출을 본다" → **EC2 전용**입니다

## 🧪 자가 점검

**Q1.** 보안팀이 "모든 서브넷의 아웃바운드를 기본 거부로 바꿔 데이터 유출 경로를 없애라"는 요구를 NACL로 구현했습니다. 적용 후에도 인스턴스가 이름 해석과 시간 동기화를 정상 수행하고, 애플리케이션이 IMDS에서 자격 증명을 계속 읽습니다. 설명은? (→ 1-2 NACL 예외)

<details><summary>정답 보기</summary>

**그 트래픽들은 애초에 NACL의 대상이 아닙니다.**

- 공식 문서가 NACL이 **필터링하지 않는** 대상을 열거합니다 — **Amazon DNS · DHCP · EC2 인스턴스 메타데이터 · ECS 작업 메타데이터 엔드포인트 · Windows 라이선스 활성화 · Amazon Time Sync Service · 기본 VPC 라우터가 쓰는 예약 IP**
- 별도로 ⚠️ **"NACL은 Route 53 Resolver로 가는·오는 DNS 요청을 차단할 수 없다"**(VPC+2 주소)와 ⚠️ **"NACL은 인스턴스 메타데이터 서비스(IMDS)로 가는 트래픽을 차단할 수 없다"**가 명시돼 있습니다
- 각각의 올바른 수단은 — DNS 필터링은 **Route 53 Resolver DNS Firewall**, IMDS는 **인스턴스 메타데이터 옵션**(IMDSv2 강제·홉 제한·끄기)입니다

⚠️ 그리고 NACL은 **서브넷에 들어오고 나갈 때만** 평가하므로 **같은 서브넷 내부 통신**도 이 요구로 막히지 않습니다 — 그것은 보안 그룹의 일입니다.
</details>

**Q2.** 두 VPC를 피어링으로 연결해 쓰고 있습니다. 감사에서 "VPC 사이 동-서 트래픽도 IPS로 검사하라"는 요구가 나왔습니다. Network Firewall을 각 VPC에 배치하면 됩니까? (→ 1-3·4-1 세분화)

<details><summary>정답 보기</summary>

**안 됩니다. Network Firewall은 VPC 피어링 트래픽을 지원하지 않습니다.**

- 공식 문서가 **미지원 아키텍처**로 **VPC 피어링**을 명시합니다(함께 **클라이언트 IP 보존을 켠 Global Accelerator 트래픽**과 **EC2의 AmazonProvidedDNS 트래픽**도 미지원)
- 해법은 **피어링을 Transit Gateway 경유로 바꾸고 검사 VPC로 유도**하는 것입니다. 검사 VPC는 서브넷별 라우트 테이블로 **Transit Gateway 서브넷 → 어플라이언스 ENI → 다시 Transit Gateway** 경로를 만듭니다
- ⚠️⚠️ 그리고 **어플라이언스 모드**를 켜야 합니다 — 켜지 않으면 응답이 **다른 AZ의 엔드포인트로 가서 드롭**됩니다(§4-2)

⚠️ 함께 기억할 것 — **방화벽 서브넷은 Network Firewall 전용**이고, 엔드포인트는 **자기 서브넷으로 드나드는 트래픽을 필터링하지 못합니다.**
</details>

**Q3.** 여러 AZ에 걸친 VPC들이 Transit Gateway로 공유 서비스 VPC의 상태 저장 방화벽 어플라이언스를 거치게 구성했습니다. 일부 세션만 간헐적으로 실패합니다. 원인과 해법은? (→ 4-2 어플라이언스 모드)

<details><summary>정답 보기</summary>

**어플라이언스 모드가 꺼져 있어 응답이 다른 AZ의 어플라이언스로 갔습니다.**

- 어플라이언스 모드를 켜지 않으면 Transit Gateway는 트래픽을 **출발 AZ 안에 유지**하려 합니다. 그래서 VPC A(AZ 1)의 요청은 AZ 1 어플라이언스가 보는데, VPC B의 **AZ 2**에서 나온 응답은 공유 서비스 VPC의 **AZ 2**로 갑니다
- ⚠️⚠️ **AZ 2의 어플라이언스는 원래 요청을 모르므로 트래픽이 드롭됩니다.** 간헐적으로 보이는 것은 **요청·응답이 같은 AZ에 떨어진 세션만 성공**하기 때문입니다
- 해법은 공식 그대로 — **어플라이언스가 있는 VPC 어태치먼트에서 어플라이언스 모드 지원을 켭니다.** 그러면 소스·대상 사이 트래픽이 **같은 어플라이언스**를 지납니다

⚠️ 함께 확인할 것 — VPC 어태치먼트는 **AZ마다 서브넷을 하나** 지정해야 하고, **어태치먼트가 있는 AZ의 리소스만** Transit Gateway에 도달합니다.
</details>

**Q4.** "온프레미스 데이터센터와 AWS 사이 전송 구간을 암호화하라"는 요구에 Direct Connect + MACsec을 제안했습니다. 보안 검토에서 "종단 간 암호화 요건을 충족하지 못한다"는 지적을 받았습니다. 맞습니까? (→ 2-2 MACsec)

<details><summary>정답 보기</summary>

**맞습니다. MACsec은 점대점 L2 암호화입니다.**

- ⚠️⚠️ 공식 문장 — **"MACsec은 이더넷 링크의 점대점 보안을 제공하므로, 여러 개의 연속된 이더넷이나 다른 네트워크 세그먼트를 지나는 종단 간 암호화를 제공하지 않습니다."** 덮는 구간은 **내 엣지 장치 ↔ Direct Connect 로케이션의 교차 연결**입니다
- 다만 ⚠️ **AWS가 Direct Connect 로케이션과 AWS 리전 사이를 흐르는 모든 데이터를 물리 계층에서 암호화**하므로 **계층적 보안**은 성립합니다
- 애플리케이션 종단까지 요구하면 **상위 계층 암호화**를 더합니다 — **Direct Connect 위의 IPsec VPN**(공식 명칭은 `VPN over Direct Connect`)이나 **애플리케이션 계층 TLS**입니다
- 모드 선택도 함께 봅니다 — 암호화 없는 폴백을 막아야 하면 **`must_encrypt`**이고, ⚠️ **새 연결의 기본값은 `should_encrypt`**(협상 실패 시 비암호화 폴백)입니다

⚠️ 키는 **정적 CAK만** 지원되므로 **생성·배포·교체 정책이 내 책임**이고, 키체인에는 **세 쌍까지** 둬 무중단 수동 교체를 합니다. **SAK는 CKN/CAK에서 유도**되고 자동 교체됩니다.
</details>

**Q5.** "재무 부서 리소스가 개발 부서 리소스에서 절대 도달할 수 없어야 한다"는 거버넌스 요구를 검증하라는 과제를 받았습니다. 어떤 수단이고 어떻게 구성합니까? (→ 5-2 Network Access Analyzer)

<details><summary>정답 보기</summary>

**Network Access Analyzer의 네트워크 액세스 스코프로 선언하고 분석합니다.**

- **MatchPaths**에 **위반으로 보는 경로**를 적습니다 — 소스를 개발 리소스, 대상을 재무 리소스로 둡니다. 스코프는 **리소스 그룹**으로 태그 기반 참조를 할 수 있어 "재무 태그가 붙은 모든 리소스"로 쓸 수 있습니다
- **ExcludePaths**에는 **정당한 예외**를 적습니다. ⚠️ 조사 결과의 정의는 **MatchPaths 중 하나 이상에 맞고 ExcludePaths 중 어느 것에도 맞지 않는 잠재 경로**입니다
- **자동 추론**으로 구성만 보고 판정하므로 트래픽을 흘릴 필요가 없고, 분석 대상에 **보안 그룹·NACL·라우트 테이블·엔드포인트·Transit Gateway·피어링·Network Firewall**까지 듭니다
- ⚠️ **온디맨드 분석**이므로 상시 검증이 필요하면 **주기 실행 자동화**를 둡니다

⚠️ **Inspector 네트워크 도달성과 혼동하지 않습니다** — 그쪽은 **선언 없이 EC2에 열린 경로**를 **12시간마다** 알려 주고 **EC2 전용**입니다. "부서 간 격리 정책 위반"은 스코프를 선언하는 쪽입니다.
</details>

**Q6.** 협력사 직원이 사내 웹 애플리케이션 세 개 중 하나에만 접근해야 하고, 회사 관리 디바이스에서만 허용해야 합니다. VPN 계정을 발급하는 방식의 문제와 대안은? (→ 3 Verified Access)

<details><summary>정답 보기</summary>

**VPN은 한 번 평가해 네트워크에 들여보내므로 애플리케이션 단위 제한과 디바이스 조건을 걸기 어렵습니다. 대안은 AWS Verified Access입니다.**

- ⚠️ 공식 비교가 그대로입니다 — 전통적 모델은 **한 번 평가하고 모든 애플리케이션 접근을 허용**하는데, Verified Access는 **애플리케이션 접근 요청마다 실시간 평가**해 **한 앱에서 다른 앱으로의 이동을 어렵게** 만듭니다
- **ID·디바이스 관리 서비스와 통합**(AWS·**타사 둘 다**)해 **사용자와 디바이스의 신뢰성**을 요구 사항에 대조합니다 — "회사 관리 디바이스에서만"이 그 자리입니다
- ⚠️ **모든 접근 시도를 로깅**하므로 협력사 접근의 감사 추적이 남습니다
- 과금은 **애플리케이션당 시간 + 처리 데이터량**입니다

⚠️ 더 얹을 수 있는 층 — **Verified Access 인스턴스는 AWS WAF로 보호할 수 있는 리소스**라 L7 검사(관리형 규칙·속도 제한)를 앞단에 둘 수 있습니다(작업 3.1).
</details>

---

### 📌 출처

1. Infrastructure security in Amazon VPC — `docs.aws.amazon.com/vpc/latest/userguide/infrastructure-security.html` (2026-11-08 확인)
2. Control subnet traffic with network access control lists — `docs.aws.amazon.com/vpc/latest/userguide/vpc-network-acls.html` (2026-11-08 확인)
3. What is AWS Network Firewall? — `docs.aws.amazon.com/network-firewall/latest/developerguide/what-is-aws-network-firewall.html` (2026-11-08 확인)
4. AWS Network Firewall example architectures with routing — `docs.aws.amazon.com/network-firewall/latest/developerguide/architectures.html` (2026-11-08 확인)
5. What is AWS Site-to-Site VPN? — `docs.aws.amazon.com/vpn/latest/s2svpn/VPC_VPN.html` (2026-11-08 확인)
6. MAC Security in Direct Connect — `docs.aws.amazon.com/directconnect/latest/UserGuide/MACsec.html` (2026-11-08 확인)
7. What is AWS Verified Access? — `docs.aws.amazon.com/verified-access/latest/ug/what-is-verified-access.html` (2026-11-08 확인)
8. How AWS Transit Gateway works — `docs.aws.amazon.com/vpc/latest/tgw/how-transit-gateways-work.html` (2026-11-08 확인)
9. What is Network Access Analyzer? — `docs.aws.amazon.com/vpc/latest/network-access-analyzer/what-is-network-access-analyzer.html` (2026-11-08 확인)
10. Network Access Scopes in Network Access Analyzer — `docs.aws.amazon.com/vpc/latest/network-access-analyzer/working-with-network-access-scopes.html` (2026-11-08 확인)
11. Amazon Inspector finding types — `docs.aws.amazon.com/inspector/latest/user/findings-types.html` (2026-11-08 확인)
