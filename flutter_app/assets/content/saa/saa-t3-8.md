---
examGuideTaskId: saa-t3-8
certCode: SAA-C03
domain: 3
domainName: 고성능 아키텍처 설계
domainWeightPct: 24
title: 하이브리드 네트워크 — VPC 심화·VPN·Direct Connect·PrivateLink
coversTasks:
  - "3.4"
sources:
  - title: AWS Site-to-Site VPN — 소개 (공식)
    url: https://docs.aws.amazon.com/vpn/latest/s2svpn/VPC_VPN.html
  - title: AWS Direct Connect — 소개 (공식)
    url: https://docs.aws.amazon.com/directconnect/latest/UserGuide/Welcome.html
  - title: AWS Direct Connect Gateway (공식)
    url: https://docs.aws.amazon.com/directconnect/latest/UserGuide/direct-connect-gateways-intro.html
  - title: Private IP AWS Site-to-Site VPN with Direct Connect (공식)
    url: https://docs.aws.amazon.com/vpn/latest/s2svpn/private-ip-dx.html
  - title: AWS Transit Gateway — 소개 (공식)
    url: https://docs.aws.amazon.com/vpc/latest/tgw/what-is-transit-gateway.html
  - title: AWS PrivateLink — 소개 (공식)
    url: https://docs.aws.amazon.com/vpc/latest/privatelink/what-is-privatelink.html
  - title: SAA-C03 공식 시험 가이드 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
  - title: AWS Transit Gateway — VPC 어태치먼트 (공식)
    url: https://docs.aws.amazon.com/vpc/latest/tgw/tgw-vpc-attachments.html
lastVerified: 2026-10-28
---

# 하이브리드 네트워크 — VPC 심화·VPN·Direct Connect·PrivateLink

> **커버하는 공식 Task** — SAA-C03 · 도메인 3 「고성능 아키텍처 설계」(24%) · **Task 3.4 네트워크 연결성 결정** (`saa-t3-8`)
> 이 문서는 위 한 Task에 1:1로 매핑됩니다. "온프레미스를 AWS에 어떻게 잇느냐"와 "여러 VPC를 어떻게 연결하느냐"가 핵심입니다.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명할 수 있어야 합니다. (공식 시험 가이드 Task 3.4의 Skill 항목 기반)

- [ ] **VPC 피어링의 전이 불가 특성** — A-B, B-C 피어링이 있어도 A-C 통신이 불가능한 이유를 설명할 수 있다
- [ ] **Transit Gateway 허브-스포크 모델** — 다수 VPC와 온프레미스를 중앙 허브로 연결하는 구조를 그릴 수 있다
- [ ] **Site-to-Site VPN 구성 요소** — 고객 게이트웨이, 가상 프라이빗 게이트웨이, VPN 터널의 역할을 설명할 수 있다
- [ ] **Direct Connect 특성** — 전용 물리 회선, 일관된 대역폭, 기본 암호화 없음을 안다
- [ ] **VPN vs Direct Connect 선택 기준** — 즉시성·비용 vs 안정성·저지연 기준으로 상황별 선택을 할 수 있다
- [ ] **Direct Connect Gateway** — 단일 DX 연결로 여러 리전의 VPC에 접근하는 방법을 안다
- [ ] **PrivateLink와 인터페이스 엔드포인트** — 서비스를 인터넷 없이 사설로 노출하는 메커니즘을 설명할 수 있다

---

## 🎯 왜 중요한가

- 도메인 3(24%)의 Task 3.4는 "연결성"에 집중합니다. 시험은 온프레미스-AWS 연결, 다중 VPC 연결, 서비스 사설 접근이라는 세 축을 시나리오로 출제합니다.
- "가장 안전하게", "일관된 대역폭으로", "즉시 구축 가능하게", "인터넷을 거치지 않고" 등 제약 조건이 선택을 갈라놓습니다. 조건을 읽고 서비스를 매핑하는 훈련이 핵심입니다.
- CLF에서 VPN과 Direct Connect를 개념 수준으로 봤다면, SAA는 **어느 상황에 무엇을 쓰는지 설계 결정**을 묻습니다. 특히 VPN vs Direct Connect 비교, 피어링 vs Transit Gateway 비교는 단골 출제 패턴입니다.

---

## 🔤 먼저 알아야 할 용어

이 문서를 읽는 데 필요한 기초 용어입니다. 이미 알면 건너뛰세요.

| 용어 | 영문 | 한 줄 풀이 |
|---|---|---|
| **비전이** | Non-transitive | A-B, B-C 연결이 있어도 A-C 연결이 자동으로 생기지 않는 성질 — 다리를 건너도 다음 다리가 이어지지 않는 것과 같음 |
| **CIDR** | Classless Inter-Domain Routing | IP 주소 범위를 `10.0.0.0/16`처럼 프리픽스 길이로 표기하는 방식 |
| **IPsec** | IP Security | 인터넷 레이어에서 패킷을 암호화·인증하는 프로토콜 묶음 |
| **ENI** | Elastic Network Interface | VPC 내 가상 네트워크 카드 — 사설 IP를 가지며 인스턴스에 탈부착 가능 |
| **NLB** | Network Load Balancer | OSI 4계층(TCP/UDP) 기반 고성능 로드 밸런서. PrivateLink 엔드포인트 서비스의 앞단으로 사용됨 |
| **VGW** | Virtual Private Gateway | AWS 측 VPN 엔드포인트 — 단일 VPC에 연결되며 온프레미스 터널의 AWS 종단점 역할 |

---

## 📖 핵심 개념 {#core-concepts}

### 1) VPC 피어링 — 1:1 직접 연결, 전이 불가 {#vpc-peering}

> 공식 정의: 두 VPC 사이의 네트워킹 연결로, 프라이빗 IPv4 또는 IPv6 주소를 사용해 인스턴스 간 트래픽을 라우팅합니다.

VPC 피어링은 같은 계정, 다른 계정, 다른 리전(인터-리전 피어링) 모두 지원합니다.

핵심 제약:

- **CIDR 중복 불가**: 두 VPC의 IP 대역이 겹치면 피어링을 생성할 수 없습니다.
- **비전이(non-transitive)**: A-B 피어링과 B-C 피어링이 존재해도 A와 C는 통신할 수 없습니다. A-C를 연결하려면 별도 피어링이 필요합니다.

```
[피어링 메시 — VPC 4개]          [Transit Gateway 허브-스포크]

 A ─── B                           A    B    C    온프레미스
 │ ╲   │                            \   │   /    /
 │  ╲  │   (6개 피어링 필요)          \  │  /  /
 C ─── D                              TGW (전이 라우팅 O)
```

VPC 수가 늘어날수록 필요한 피어링 쌍은 n(n-1)/2로 증가합니다. VPC 4개면 6개, 10개면 45개입니다.

> 🧠 원리: 왜 VPC 피어링은 전이를 허용하지 않을까요?
> 피어링은 두 VPC 사이에만 라우팅 경로를 추가하는 1:1 네트워크 약속이어서, B가 A와 C 양쪽에 피어링되어 있어도 B는 A-C 사이의 트래픽을 대신 전달할 중계 역할을 하지 않습니다.
> 전이 라우팅을 허용하면 중간 VPC가 경로를 제어하기 어려워지고, 네트워크 관리자가 의도하지 않은 경로로 트래픽이 흐를 수 있기 때문에 각 연결은 명시적으로 쌍마다 설정해야 합니다.
> 이 비전이 특성이 VPC 수가 많아질수록 피어링 관리 부담이 급격히 증가하는 근본 이유이며, 그래서 Transit Gateway가 등장했습니다.

### 2) Transit Gateway — 허브-스포크, 전이 라우팅 {#transit-gateway}

> 공식 정의: VPC와 온프레미스 네트워크를 상호 연결하는 네트워크 전송 허브.

Transit Gateway(TGW)는 여러 VPC, VPN 연결, Direct Connect 게이트웨이를 **단일 허브에 연결**합니다. 허브를 경유하는 전이 라우팅이 가능하므로 VPC끼리 직접 피어링 없이도 통신할 수 있습니다.

| 특성 | 내용 |
|---|---|
| 어태치먼트 유형 | VPC, Site-to-Site VPN, Direct Connect 게이트웨이, 타 TGW 피어링 |
| 전이 라우팅 | O — TGW 경유 시 VPC-to-VPC 통신 가능 |
| 리전 범위 | 리전 리소스. 인터-리전은 TGW 피어링으로 연결 |
| 과금 | 어태치먼트 시간당 + 처리된 데이터 GB당 |

**규모 한도 — 숫자를 알아야 설계 문제를 가릅니다 (★ 시험 포인트)**

| 쿼터 | 기본값 | 조정 |
|---|---|---|
| TGW당 어태치먼트 | **5,000** | 가능 |
| **VPC당 전송 게이트웨이** | **5** | ⚠️ 불가 |
| TGW당 피어링 어태치먼트 | **50** | 가능 |
| TGW당 대기 중 피어링 어태치먼트 | 10 | 가능 |
| 두 TGW 사이 또는 **TGW ↔ Cloud WAN 코어 네트워크 에지(CNE)** 사이의 피어링 어태치먼트 | **1** | ⚠️ 불가 |
| Connect 어태치먼트당 Connect 피어(GRE 터널) | 4 | ⚠️ 불가 |
| TGW당 **VPN Concentrator** | 5 | ⚠️ 불가 |
| VPN Concentrator당 VPN 연결 | 100 | ⚠️ 불가 |

**동작 제약 (★ 함정)**

- ⚠️ **하나의 TGW는 같은 VPC에 두 개의 VPC 어태치먼트를 가질 수 없습니다.**
- ⚠️ **원격 VPC의 보안 그룹을 TGW에서 참조할 수 없습니다.** VPC 피어링은 보안 그룹 참조를 지원하므로, "SG 참조로 소스를 제한하라"는 요구가 있으면 TGW 허브-스포크만으로는 충족되지 않습니다 — 이것이 피어링을 완전히 대체하지 못하는 대표적 이유입니다.
- VPC 어태치먼트는 **트래픽을 보낼 AZ마다 서브넷을 하나씩** 지정해야 합니다. 서브넷을 지정하지 않은 AZ의 리소스는 TGW에 도달하지 못합니다.
- 리전 간은 **TGW 피어링**이고, 피어링 어태치먼트는 쌍마다 **1개**뿐이라 두 TGW를 여러 경로로 이중화할 수 없습니다.

**피어링 vs Transit Gateway 비교 (★ 단골)**

| 항목 | VPC 피어링 | Transit Gateway |
|---|---|---|
| 연결 형태 | 1:1 직접 | 허브-스포크 |
| 전이 라우팅 | 불가 | 가능 |
| 온프레미스 통합 | 불가 (VPN/DX 별도) | 가능 (VPN/DX 어태치먼트) |
| 적합 규모 | VPC 소수 (2~3개) | VPC 다수 또는 하이브리드 |
| 비용 | 데이터 전송비만 | 어태치먼트 + 데이터 처리비 |
| CIDR 중복 | 불가 | 불가 (중복 경로는 라우팅 테이블에 전파되지 않음) |

> 🧠 원리: 왜 Transit Gateway 허브 설계에서 CIDR 계획이 반드시 전제되어야 할까요?
> TGW는 중복 CIDR이 있는 VPC 간 라우팅을 지원하지 않습니다. 이미 어태치된 VPC와 CIDR이 동일하거나 겹치는 VPC를 추가로 어태치하면, 새로 어태치된 VPC의 경로는 TGW 라우팅 테이블에 전파되지 않아 해당 VPC와의 통신이 불가능해집니다.
> 이는 TGW가 허브-스포크 전이 라우팅을 위해 각 어태치먼트의 CIDR을 고유한 경로로 등록해야 하는 구조이기 때문입니다. CIDR이 겹치면 어느 어태치먼트로 트래픽을 보내야 하는지 결정할 수 없으므로 중복 경로 자체가 허용되지 않습니다.
> 따라서 TGW 기반 허브 설계에서는 모든 연결 VPC의 CIDR이 겹치지 않도록 사전에 주소 계획을 수립하는 것이 전제입니다. CIDR이 겹치는 환경에서 서비스를 노출해야 한다면 PrivateLink(§7)처럼 IP 공간을 격리하는 별도 패턴이 필요합니다.

### 3) Site-to-Site VPN — 인터넷 위 IPsec 터널 {#site-to-site-vpn}

> 공식 정의: 온프레미스 장비와 VPC 사이의 보안 연결. IPsec VPN 연결을 지원합니다.

**구성 요소:**

| 구성 요소 | 역할 |
|---|---|
| **고객 게이트웨이(Customer Gateway, CGW)** | 온프레미스 측 라우터/방화벽 장비 또는 소프트웨어. AWS에 장비 정보를 등록하는 리소스 |
| **가상 프라이빗 게이트웨이(VGW)** | AWS 측 VPN 엔드포인트. 단일 VPC에 연결 |
| **Transit Gateway** | 여러 VPC를 공유하는 VPN 엔드포인트로도 사용 가능 |
| **VPN 터널** | CGW-VGW 사이의 암호화된 통로. 연결당 **2개 터널**(고가용성) |

터널 대역폭은 표준 1.25 Gbps, Transit Gateway 연결 시 대형 대역폭 터널로 터널당 최대 5 Gbps까지 지원합니다.

**대역폭을 늘리는 방법은 "터널을 묶는 것"입니다 (★ 시험 핵심)**

| 터널 유형 | 대역폭 | PPS |
|---|---|---|
| **표준** VPN 터널 | 최대 **1.25 Gbps** | 최대 **140,000** |
| **대용량(large bandwidth)** VPN 터널 | 최대 **5 Gbps** | 최대 **400,000** |
| **VPN Concentrator** VPN 터널 | 최대 **100 Mbps** | 최대 **10,000** |

한 터널의 상한은 올릴 수 없습니다. 그래서 **ECMP(Equal Cost Multi-Path)** 로 **여러 VPN 터널을 묶어** 총 대역폭을 키웁니다.

- ⚠️ **ECMP는 Transit Gateway에 종단한 VPN 연결에서만 쓸 수 있고, 반드시 동적 라우팅(BGP)으로 구성해야 합니다.** **정적 라우팅에서는 ECMP가 지원되지 않습니다** — VGW 기반 구성이 ECMP를 쓰지 못하는 이유도 같습니다.
- ECMP와 다중 IPsec 터널을 묶으면 **최대 약 50 Gbps** 규모까지 갈 수 있습니다. 단 **개별 트래픽 흐름(flow)은 여전히 터널 하나의 상한에 묶입니다** — 단일 대용량 전송 하나가 빨라지는 것이 아니라 **흐름이 많을 때 합계가 커지는** 구조입니다.
- BGP를 쓸 때는 ⚠️ **IPsec 세션과 BGP 세션이 같은 고객 게이트웨이 장비에서 종단**돼야 합니다. 장비가 둘 다 종단할 수 있어야 합니다.
- **VPN Concentrator**는 많은 사이트를 모을 때 쓰는 구성이며, TGW당 5개·Concentrator당 VPN 연결 100개가 한도입니다(§2 표 참고). 터널 대역폭이 100 Mbps라 **지점 수가 많고 지점별 대역폭이 작은** 경우에 맞습니다.
- **Accelerated VPN(가속 VPN)** 은 **AWS Global Accelerator**를 사용해 고객 게이트웨이에 **가장 가까운 AWS 엣지 로케이션**으로 트래픽을 보내, 퍼블릭 인터넷 경유에서 생기는 네트워크 중단·품질 변동을 줄입니다. 대역폭 상한을 올리는 기능이 **아니라 경로 품질**을 개선하는 기능이라는 점이 ECMP와의 차이입니다.
- IPv6 VPN은 IPv4와 **같은 처리량·MTU·라우트 한도**를 가집니다 — 성능 차이가 없습니다.

**Site-to-Site VPN 특성:**

- 구축 시간: 수 분 (즉시 사용 가능)
- 경로: 공용 인터넷 위 IPsec 터널 → 대역폭·지연 변동 가능
- 암호화: 기본 포함 (IPsec)
- 비용: 연결 시간당 + 데이터 전송비

> 🧠 원리: 왜 Site-to-Site VPN은 연결당 터널을 2개 제공할까요?
> VPN 터널은 특정 AWS 가용 영역의 엔드포인트 장비에 종단되는데, 단일 터널이면 그 장비나 AZ에 문제가 생길 때 연결 전체가 끊깁니다.
> 2개의 터널은 서로 다른 AWS 엔드포인트로 각각 연결되어 있어, 하나가 장애를 일으키면 온프레미스 장비가 자동으로 다른 터널로 트래픽을 넘길 수 있습니다.
> 이 중복 구조가 VPN 연결의 기본 가용성을 높이는 메커니즘이며, 두 터널을 동시에 활성화하면 부하 분산도 가능합니다.

### 4) Direct Connect (DX) — 전용 물리 회선 {#direct-connect}

> 공식 정의: 표준 이더넷 광섬유 케이블로 내부 네트워크를 Direct Connect 위치에 직접 연결. 인터넷 서비스 공급자를 우회합니다.

**가상 인터페이스(VIF) 유형:**

| VIF 유형 | 용도 |
|---|---|
| **프라이빗 VIF** | 프라이빗 IP로 특정 VPC 접근 |
| **퍼블릭 VIF** | 모든 AWS 퍼블릭 서비스에 퍼블릭 IP로 접근 |
| **트랜짓 VIF** | Direct Connect 게이트웨이를 통해 Transit Gateway에 연결 |

**Direct Connect 특성:**

- 구축 시간: 수 주 (파트너사 협의, 물리 회선 설치)
- 경로: 전용 물리 회선 → 일관된 대역폭·저지연
- 암호화: **기본 없음**. 선택지가 둘입니다 — DX 위에 IPsec VPN을 얹는 **VPN over Direct Connect**, 또는 아래의 **MACsec**
- 비용: 포트 시간당 + 아웃바운드 데이터 전송비 (인터넷 대비 낮은 단가)

**MACsec — 2계층 암호화 (★ 시험 핵심 · 기존 서술에 빠져 있던 선택지)**

**MACsec(MAC Security, IEEE 802.1AE)** 은 DX 연결 자체를 **2계층에서 지점 간 암호화**합니다. IPsec을 얹는 것과 달리 오버레이가 아니라 **링크 암호화**입니다.

| 항목 | 공식 내용 |
|---|---|
| 지원 범위 | ⚠️ **전용(dedicated) 연결의 10 Gbps · 100 Gbps · 400 Gbps**, 그중 **선택된 PoP(접속 지점)** 에서만 |
| 암호 스위트 | 10 Gbps는 **GCM-AES-256 또는 GCM-AES-XPN-256** / 100·400 Gbps는 **GCM-AES-XPN-256** |
| 키 | **256비트 MACsec 키만** 지원. **CKN/CAK 쌍**을 만들어 연결에 연결합니다 |
| XPN(확장 패킷 번호) | **100·400 Gbps는 필수** — 원래 32비트 패킷 번호 공간이 고속 링크에서 금방 소진돼 몇 분마다 키를 돌려야 하므로, IEEE 802.1AEbw-2013이 **64비트**로 확장했습니다 |
| SCI | **필수이며 항상 켜짐**(조정 불가) |
| 미지원 | **IEEE 802.1Q(dot1q/VLAN) 태그 오프셋(dot1q-in-clear)** — 암호화 페이로드 밖으로 VLAN 태그를 빼는 방식은 안 됩니다 |

> ⚠️ **전제가 까다롭습니다.** MACsec은 링크를 **홉 단위(hop-by-hop)** 로 보호하므로, 고객 장비가 AWS Direct Connect 장비와 **직접 2계층 인접(direct layer 2 adjacency)** 이어야 합니다. 그래서 **종단 간(end-to-end) 암호화가 아닙니다** — "온프레미스 앱부터 EC2까지 전 구간 암호화"가 요구면 MACsec만으로는 답이 아닙니다. 라스트마일 사업자가 MACsec 동작 여부를 확인해 줄 수 있습니다.

**속도·연결 형태와 SiteLink**

- **전용 연결**은 포트를 통째로 받고, **호스팅 연결**은 파트너가 분할해 제공합니다. ⚠️ **MACsec은 전용 연결 전용**입니다.
- **SiteLink**를 켜면 DX 로케이션끼리 **AWS 리전을 거치지 않고** 직접 트래픽을 주고받아, 지점 간 경로를 AWS 글로벌 네트워크로 단축할 수 있습니다.

**복원력 모델 — SLA가 숫자로 갈립니다 (★ 시험 포인트)**

**Direct Connect Resiliency Toolkit**의 연결 마법사가 목표 SLA에 맞는 연결 수·위치를 안내합니다.

| 모델 | SLA | 구성 | 무엇을 견디나 |
|---|---|---|---|
| **최대 복원력(Maximum Resiliency)** | **99.99%** | **둘 이상의 위치**에서 **별도 장치**에 종단하는 별도 연결 | 장치·연결·**전체 위치 장애** |
| **높은 복원력(High Resiliency)** | **99.9%** | **여러 위치에 단일 연결 2개** | 광케이블 절단·장치 장애 |
| **개발·테스트(Development and Test)** | — | **한 위치**의 별도 장치에 종단하는 별도 연결 | 장치 장애만 — ⚠️ **위치 장애는 못 견딥니다** |
| **Classic** | **95%** | 툴킷 없이 만드는 연결 | ⚠️ 복원력·중복성을 제공하지 않습니다 |

> SLA 수치는 **구성 요구사항을 모두 충족했을 때** 적용됩니다. "99.99%가 필요하다"는 요구에 한 위치에 회선 2개를 넣는 선택지는 오답입니다 — **위치가 둘 이상**이어야 합니다.

> 🧠 원리: 왜 Direct Connect는 기본 암호화를 포함하지 않을까요?
> Direct Connect는 ISP를 거치지 않는 전용 물리 회선으로, 공용 인터넷과 달리 경로상 제3자가 패킷을 가로채기 어려운 물리적 격리를 제공합니다.
> 그러나 물리적 격리는 전송 계층 암호화와 다르며, 내부 위협이나 DX 위치(교환 시설)에서의 트래픽 접근 가능성을 배제하지 않습니다.
> 암호화가 필요한 규정 환경에서는 DX 위에 IPsec VPN 터널을 얹는 패턴으로 물리 회선의 낮은 지연과 전송 암호화를 함께 확보할 수 있습니다.

### 5) Direct Connect Gateway — 단일 DX로 다중 리전 접근 {#direct-connect-gateway}

> 공식 정의: Direct Connect 연결을 사용해 VPC를 연결하는 전 세계적으로 사용 가능한 리소스.

Direct Connect Gateway(DXGW)는 **특정 리전에 종속되지 않는 글로벌 리소스**입니다. 단일 DX 연결로 여러 AWS 리전의 VPC에 접근할 수 있습니다.

```
온프레미스 DC
    │
 DX 연결 (예: us-east-1 위치)
    │
Direct Connect Gateway (글로벌)
    ├── 가상 프라이빗 게이트웨이 → VPC (us-east-1)
    ├── 가상 프라이빗 게이트웨이 → VPC (us-west-2)
    └── Transit Gateway → 여러 VPC (ap-northeast-2)
```

- DXGW 자체는 데이터 경로에 있지 않아 단일 장애점이 되지 않습니다.
- 같은 DXGW에 연결된 VGW 사이의 트래픽은 기본적으로 차단됩니다(VPC-to-VPC 브리지 목적이 아님).

> 🧠 원리: 왜 Direct Connect Gateway는 특정 리전에 종속되지 않는 글로벌 리소스로 설계됐을까요?
> DX 연결은 물리 회선이 설치된 위치(교환 시설)에 종속되고, 그 위치가 반드시 접근하려는 AWS 리전과 같은 곳에 있지 않을 수 있습니다.
> DXGW가 글로벌 리소스이기 때문에 물리 회선 위치와 무관하게 여러 리전의 VPC를 단일 논리 엔티티에 연결할 수 있으며, 리전별로 각각 DX 연결을 구축하지 않아도 됩니다.
> 이 설계 덕분에 온프레미스 네트워크가 단일 DX 위치에서 글로벌 멀티 리전 아키텍처에 접근하는 구성을 비교적 간단하게 만들 수 있습니다.

### 6) VPN vs Direct Connect 비교 (★ 단골) {#vpn-vs-direct-connect}

| 항목 | Site-to-Site VPN | Direct Connect |
|---|---|---|
| 연결 경로 | 공용 인터넷 (IPsec 암호화) | 전용 물리 회선 |
| 구축 시간 | 수 분 (즉시) | 수 주 (리드타임) |
| 대역폭·지연 | 변동 (인터넷 상황 의존) | 전용 회선이라 일관적. 단 약정은 **가용성 SLA**뿐(다중 사이트 중복 **99.99%** / 다중 사이트 비중복 99.9% / 단일 연결 95.0%)이며 대역폭·지연 자체를 SLA로 보장하지는 않음 |
| 암호화 | 기본 포함 | 기본 없음 |
| 비용 | 낮음 | 높음 (전용 회선) |
| 적합 상황 | 빠른 구축, 백업 연결, 소규모 트래픽 | 고대역폭, 저지연, 규정 준수, 대규모 전송 |
| 가용성 강화 | 터널 2개 기본 제공 | DX + VPN 백업 패턴 |

**조합 패턴:**

1. **DX + VPN 백업**: 평시 DX로 안정적으로 운영, DX 장애 시 VPN으로 자동 우회. 가용성과 성능을 동시에 확보합니다.
2. **VPN over Direct Connect (암호화 DX)**: DX 자체는 암호화가 없으므로, 규정상 전송 암호화가 필요한 경우 DX 위에 VPN 터널을 얹습니다. 퍼블릭 VIF로 VPN 퍼블릭 엔드포인트에 붙이는 방식과, 전송 VIF 위에서 사설 IP만 쓰는 **Private IP VPN** 방식이 있습니다.

> 🧠 원리: 왜 DX + VPN 백업 패턴이 두 서비스의 단점을 서로 보완할 수 있을까요?
> VPN은 구축이 빠르고 암호화가 포함되어 있지만 공용 인터넷 경로를 사용해 대역폭과 지연이 변동될 수 있고, DX는 일관된 전용 회선을 제공하지만 회선 장애 시 대체 경로가 없습니다.
> DX를 기본 경로로 두고 VPN을 백업으로 구성하면, 정상 운영 시에는 DX의 안정적인 대역폭을 쓰면서 DX 장애 시에는 VPN이 자동으로 우회 경로를 제공합니다.
> 이 조합은 두 서비스 중 어느 하나만 쓸 때보다 연결 가용성이 높아지며, 각각의 구축 시간·비용 특성도 단계적으로 활용할 수 있습니다.

### 7) PrivateLink와 인터페이스 엔드포인트 {#privatelink}

> 공식 정의: 인터넷 게이트웨이, NAT 장치, 퍼블릭 IP, Direct Connect, VPN 없이 VPC를 서비스 및 리소스에 비공개로 연결하는 고가용성·확장 가능한 기술.

**VPC 엔드포인트 유형 비교:**

| 유형 | 대상 서비스 | 방식 | 비용 |
|---|---|---|---|
| **게이트웨이 엔드포인트** | S3, DynamoDB 전용 | 라우트 테이블 항목 추가 | 무료 |
| **인터페이스 엔드포인트 (PrivateLink)** | 대부분의 AWS 서비스 및 사용자 서비스 | VPC 내 ENI + 사설 IP | 시간당 + 데이터 GB당 |

**PrivateLink의 핵심 용도:**

- AWS 관리형 서비스(예: SQS, SNS, EC2 API 등)에 인터넷을 거치지 않고 접근
- 사용자가 만든 서비스(NLB 뒤)를 다른 VPC나 계정에 사설로 노출 — VPC 소비자는 인터페이스 엔드포인트를 생성해 접근

```
서비스 제공자 VPC              서비스 소비자 VPC
┌──────────────┐              ┌──────────────────┐
│ NLB          │              │ 인터페이스 엔드포인트│
│  │           │◄─PrivateLink─►│ (ENI + 사설 IP)  │
│ EC2 서비스   │              │                  │
└──────────────┘              └──────────────────┘
      (인터넷 불필요 — 사설 AWS 백본 경유)
```

- PrivateLink를 사용하면 소비자 VPC와 제공자 VPC의 **CIDR이 겹쳐도 통신 가능**합니다(피어링과의 차이).

> 🧠 원리: 왜 PrivateLink는 CIDR이 겹치는 VPC 사이에서도 작동할 수 있을까요?
> VPC 피어링은 두 VPC의 IP 공간을 직접 연결해 서로의 IP 주소로 통신하므로 CIDR이 겹치면 어느 VPC의 주소인지 구분할 수 없습니다.
> PrivateLink는 소비자 VPC 안에 ENI를 생성하고 해당 ENI의 사설 IP로만 서비스에 접근하는 방식이어서, 소비자는 제공자 VPC의 IP 공간을 전혀 볼 필요가 없습니다.
> 두 VPC의 IP 공간이 서로 격리된 채 ENI라는 단일 접점만 노출되기 때문에 CIDR 겹침이 라우팅 충돌로 이어지지 않습니다.

### 8) 서브넷 설계와 IP 주소 지정 {#subnet-design}

연결 수단을 고르기 전에 정해야 하는 것이 **주소 계획**입니다. 여기서 틀리면 나중에 CIDR을 못 늘려 재구축이 됩니다.

| 규칙 | 공식 내용 |
|---|---|
| 서브넷의 AZ 범위 | ⚠️ **서브넷은 단일 AZ에 속합니다.** 여러 AZ에 걸치는 서브넷은 없습니다 — 다중 AZ 설계는 "AZ마다 서브넷을 하나씩" 두는 것입니다 |
| IPv4 CIDR 크기 | **`/28` ~ `/16`** |
| 예약 IP | ⚠️ **각 서브넷 CIDR의 처음 네 개 + 마지막 한 개 = 5개**가 예약돼 리소스에 할당할 수 없습니다 |
| IPv6 | VPC에 `/56`, 서브넷은 **`/64` 고정** → VPC 안에 **256개 서브넷** |

`10.0.0.0/24` 서브넷에서 예약되는 다섯 주소:

```
10.0.0.0    네트워크 주소
10.0.0.1    VPC 라우터용 AWS 예약
10.0.0.2    AWS 예약 — DNS 서버는 VPC 네트워크 범위의 "기준 + 2"
            (CIDR 블록이 여럿이면 DNS 서버 IP는 프라이머리 CIDR에 있고,
             모든 CIDR의 각 서브넷 범위 + 2 도 함께 예약합니다)
10.0.0.3    향후 사용을 위한 AWS 예약
10.0.0.255  네트워크 브로드캐스트 주소 (VPC는 브로드캐스트를 지원하지 않지만 예약)

가용 IP 수 = 2^(32 − 프리픽스 길이) − 5
  /24 → 2^8 − 5  = 251개
  /16 → 2^16 − 5 = 65,531개
```

- ⚠️ **BYOIP로 가져온 IPv4 범위는 예외**입니다 — 네트워크 주소와 브로드캐스트 주소까지 **범위의 모든 IP를 쓸 수 있습니다.**
- CLI·API로 서브넷을 만들면 CIDR이 **표준형으로 자동 변환**됩니다(`100.68.0.18/18` → `100.68.0.0/18`).

**티어 분리의 실제 기준**은 "퍼블릭/프라이빗"이라는 이름이 아니라 **라우트 테이블의 기본 경로**입니다 — 0.0.0.0/0이 **인터넷 게이트웨이**로 가면 퍼블릭 서브넷, **NAT 게이트웨이**로 가면 프라이빗 서브넷, 아무 데도 안 가면 격리 서브넷입니다. IPv6 전용 송신에는 **Egress-Only 인터넷 게이트웨이**를 씁니다.

> 🧠 원리: 왜 AWS는 서브넷마다 5개 IP를 가져갈까요?
> 서브넷은 단순한 주소 목록이 아니라 **VPC가 제공하는 기능의 접점**이기도 합니다. 라우터 주소(`+1`)가 있어야 서브넷 밖으로 나가는 경로가 성립하고, DNS 리졸버 주소(`+2`)가 있어야 인스턴스가 추가 설정 없이 이름을 풀 수 있습니다.
> 네트워크 주소와 브로드캐스트 주소는 IP 표준이 예약하는 것이고, 남은 하나(`+3`)는 AWS가 향후 기능을 위해 남겨 둡니다 — 나중에 기능이 늘어도 고객 주소 계획을 깨지 않으려는 여유분입니다.
> 그래서 `/28`(16개 중 11개 가용)처럼 작은 서브넷에서는 예약 비율이 31%에 달합니다. 작은 서브넷을 잘게 많이 쪼개면 주소 낭비가 커지는 것이 이 구조의 직접적 결과이고, BYOIP 범위가 예외인 이유도 "그 주소 공간의 기능 접점을 AWS가 제공할 필요가 없기" 때문입니다.

### 9) 글로벌 토폴로지·하이브리드 DNS·리소스 배치 {#global-topology-dns}

**AWS Cloud WAN — 글로벌 토폴로지를 정책으로 관리**

Cloud WAN은 여러 리전·온프레미스를 **코어 네트워크**라는 하나의 관리 단위로 묶어, 세그먼트(라우팅 도메인)와 어태치먼트를 **정책 문서**로 선언해 운영하는 수단입니다. TGW와의 접점은 공식 쿼터 표에 나오는 **코어 네트워크 에지(CNE)** 피어링이며, **TGW ↔ CNE 피어링 어태치먼트는 쌍마다 1개**입니다(§2 표).

> ⚠️ **출제 범위를 단정하지 마세요.** Cloud WAN은 SAA-C03 공식 가이드의 in-scope·out-of-scope 목록 **어디에도 없어 범위 판정 자체가 불확실**합니다(`99-gaps.md` V-72). 여기서는 "글로벌 토폴로지를 정책으로 다루는 수단이 TGW 외에 하나 더 있다"는 수준으로만 알아 두고, 수치나 세부 기능을 외우는 데 시간을 쓰지 않는 것이 맞습니다.

**Route 53 Resolver — 온프레미스와 양방향 이름 해석**

VPC와 온프레미스 사이에서 **DNS 서버를 따로 세우지 않고** 질의를 전달하는 수단입니다. 방향에 따라 엔드포인트가 갈립니다.

| 구성 요소 | 방향 | 역할 |
|---|---|---|
| **인바운드 엔드포인트** | 온프레미스 → AWS | 온프레미스 DNS 리졸버가 이 엔드포인트로 질의를 보내 **프라이빗 호스팅 영역·AWS 리소스 이름**을 해석합니다. 기본(default) 유형과, 프라이빗 호스팅 영역 서브도메인의 권한을 위임하는 **위임(delegation)** 유형이 있습니다 |
| **아웃바운드 엔드포인트** | AWS → 온프레미스 | VPC Resolver가 **조건부로** 온프레미스 리졸버에 질의를 전달합니다 |
| **전달 규칙(Resolver 규칙)** | — | 전달할 도메인 이름과 대상 리졸버 IP를 지정합니다. 유형은 **forward · system** 등이며, **RAM으로 다른 VPC·계정과 공유**할 수 있습니다 |

- 여러 규칙이 겹치면(`example.com`·`acme.example.com`) **가장 구체적인 규칙**을 택해 전달합니다.
- ⚠️ **온프레미스나 다른 VPC의 DNS 서버에서 VPC CIDR의 `+2` 주소로 프라이빗 질의를 전달하는 것은 지원되지 않습니다** — 불안정한 결과를 냅니다. 반드시 **인바운드 엔드포인트**를 씁니다.
- 규모: 계정·VPC가 여러 개여도 **공유 서비스 VPC에 AZ 중복 인바운드 엔드포인트 한 세트**와 **아웃바운드 엔드포인트 하나**로 충분합니다(규칙을 공유). 한도는 엔드포인트의 **ENI당 약 10,000 QPS**이고, ⚠️ Resolver가 응답한 질의는 **로깅 가시성이 없으며 질의 소스 IP가 엔드포인트 IP로 대체**됩니다.

**리소스를 어디에 둘 것인가 — 리전 밖 선택지**

지연이 거리 때문이라면 리전 안에서 손쓸 수 없습니다. **Local Zones**(대도시 근접) · **Wavelength Zones**(통신사 5G 엣지) · **Outposts**(고객 데이터센터)의 정의와 선택 신호는 `saa-t3-4` §7에 정리해 두었습니다 — ⚠️ 세 곳 모두 **ECS on Fargate를 지원하지 않아** 컨테이너는 EC2 시작 유형이어야 한다는 점이 함께 묶이는 함정입니다.

> 🧠 원리: 왜 하이브리드 DNS에는 엔드포인트가 두 개나 필요할까요?
> DNS 질의는 방향이 있는 트래픽이고, 양쪽 네트워크는 서로의 이름 공간에 대해 **권한이 없습니다.** 온프레미스 리졸버는 `*.compute.internal`이나 프라이빗 호스팅 영역의 레코드를 모르고, VPC Resolver는 사내 AD 도메인을 모릅니다.
> 그래서 "모르는 이름을 아는 쪽에 넘기는 통로"를 방향마다 하나씩 열어 둡니다 — 들어오는 질의를 받는 접점(인바운드)과, 나가는 질의를 조건부로 넘기는 접점(아웃바운드)입니다. 아웃바운드가 **조건부**인 이유는 모든 질의를 온프레미스로 넘기면 AWS 이름 해석까지 느려지고 단일 장애점이 생기기 때문입니다.
> `+2` 주소로 직접 질의하는 방식이 지원되지 않는 것도 같은 맥락입니다 — 그 주소는 **VPC 내부 리소스를 위한 리졸버 접점**이지 외부에 노출하도록 설계된 엔드포인트가 아니고, VPC 밖에서 접근하면 경로·응답이 보장되지 않습니다.

---

## ✍️ 시험 포인트

| 요구사항 | 정답 |
|---|---|
| 온프레미스 ↔ AWS, 즉시 연결, 저비용 | **Site-to-Site VPN** |
| 온프레미스 ↔ AWS, 일관된 저지연·고대역폭 | **Direct Connect** |
| DX 장애 시 자동 우회 | **DX + VPN 백업** |
| DX 연결에 암호화 추가 | **VPN over Direct Connect** |
| 단일 DX로 여러 리전 VPC 접근 | **Direct Connect Gateway** |
| VPC 2~3개 단순 연결 | **VPC 피어링** |
| VPC 다수 + 온프레미스 중앙 연결 | **Transit Gateway** |
| 프라이빗 서브넷에서 S3·DynamoDB, 인터넷 불필요 | **게이트웨이 엔드포인트** |
| 프라이빗 서브넷에서 기타 AWS 서비스 사설 접근 | **인터페이스 엔드포인트 (PrivateLink)** |
| CIDR 겹쳐도 두 VPC가 서비스를 공유 | **PrivateLink** (피어링은 CIDR 중복 불가) |
| 내 서비스를 다른 계정 VPC에 사설로 노출 | **PrivateLink 엔드포인트 서비스 (NLB 기반)** |

- **"VPN이 Direct Connect보다 빠른 구축"** — 핵심 키워드: 즉시성·비용·임시 연결 = VPN. 안정성·규정준수·대규모 = DX.
- **피어링은 전이 불가** — A-B-C 피어링에서 A-C 통신을 묻는 선택지가 나오면 Transit Gateway가 답입니다.
- **게이트웨이 엔드포인트는 S3·DynamoDB 전용·무료** — 다른 서비스는 반드시 인터페이스 엔드포인트입니다.

---

## ⚠️ 흔한 함정 {#common-pitfalls}

1. **"지금 당장 연결이 필요하다" → Direct Connect 선택.** Direct Connect 구축에는 수 주의 리드타임이 걸립니다. 즉시성이 요구되면 **Site-to-Site VPN**이 답입니다.
   (원리: §3 본문 — VPN은 공용 인터넷을 이용한 소프트웨어 설정만으로 즉시 연결이 가능하고, DX는 물리 회선 설치가 선행되어야 한다.)

2. **"Direct Connect는 기본 암호화된다."** Direct Connect는 전용 물리 회선이지만 **기본 암호화가 없습니다.** 전송 암호화가 필요하면 VPN over Direct Connect 패턴을 사용해야 합니다.
   (원리: §4 — 물리적 격리는 전송 계층 암호화가 아니며, 암호화가 필요하면 DX 위에 IPsec 터널을 얹어야 한다.)

3. **"VPC 피어링을 통해 세 VPC가 서로 통신한다."** 피어링은 비전이입니다. A-B, B-C가 있어도 A는 C를 볼 수 없습니다. 세 VPC 모두 통신하려면 Transit Gateway 또는 각 쌍을 직접 피어링해야 합니다.
   (원리: §1 — 피어링은 1:1 네트워크 약속이어서 중간 VPC가 트래픽을 중계하지 않으므로 전이 통신이 성립하지 않는다.)

4. **"게이트웨이 엔드포인트로 모든 AWS 서비스에 접근한다."** 게이트웨이 엔드포인트는 **S3와 DynamoDB 전용**입니다. 나머지 AWS 서비스에는 인터페이스 엔드포인트(PrivateLink)를 사용해야 합니다.
   (원리: §7 본문 — 엔드포인트 유형 표에서 게이트웨이 엔드포인트 대상은 S3·DynamoDB 전용이고 나머지는 인터페이스 엔드포인트다.)

5. **"PrivateLink는 CIDR이 겹치면 사용 불가다."** CIDR 겹침 제약은 VPC 피어링에 해당합니다. PrivateLink는 ENI 기반으로 동작하므로 소비자-제공자 VPC의 CIDR이 겹쳐도 사용할 수 있습니다.
   (원리: §7 — 소비자 VPC 내 ENI가 서비스 접점 역할을 하므로 제공자 VPC IP 공간이 노출되지 않아 CIDR 충돌이 발생하지 않는다.)

6. **"Direct Connect Gateway는 VPC 간 통신 브리지다."** DXGW에 연결된 VGW끼리는 기본적으로 트래픽이 차단됩니다. VPC 간 통신이 목적이라면 Transit Gateway를 사용해야 합니다.
   (원리: §5 본문 — DXGW는 온프레미스-VPC 연결 목적이며 같은 DXGW의 VGW 사이 트래픽은 기본 차단된다.)

7. **"VPN은 터널이 하나다."** Site-to-Site VPN 연결에는 **항상 터널 2개**가 포함됩니다. 고가용성을 위해 두 터널을 동시에 사용할 수 있습니다.
   (원리: §3 — 터널 2개가 서로 다른 AWS 엔드포인트에 연결되어 하나 장애 시 다른 터널로 자동 우회가 가능하다.)

---

## 🧪 자가 점검

> 아래는 학습용 자가 점검입니다. (정식 검증 문항은 별도 문항 파일 참조)

**Q1.** 기업이 온프레미스 데이터센터와 AWS를 연결해야 합니다. 3일 안에 연결이 필요하고, 초기 트래픽은 100 Mbps 수준입니다. 6개월 후 트래픽이 10 Gbps로 증가할 것으로 예상됩니다. 가장 적합한 초기 전략은?

<details><summary>정답 보기</summary>

**Site-to-Site VPN으로 즉시 연결을 시작하고, 병렬로 Direct Connect를 발주합니다.** VPN은 수 분 내 구축 가능하고 즉시성 요건을 충족합니다. Direct Connect는 구축에 수 주가 걸리므로 지금 발주하면 트래픽이 증가하기 전에 준비할 수 있습니다. 이후 DX + VPN 백업 패턴으로 전환하면 고가용성과 일관된 대역폭을 모두 확보할 수 있습니다.
</details>

**Q2.** 한 회사가 AWS에 VPC 8개를 운영 중이며 온프레미스 데이터센터도 연결해야 합니다. 모든 VPC가 서로 통신하고 온프레미스와도 통신해야 합니다. VPC 피어링으로 구성하면 피어링이 몇 개 필요하고, 더 나은 대안은 무엇인가요?

<details><summary>정답 보기</summary>

VPC 피어링으로만 구성하면 8×7/2 = **28개**의 피어링이 필요하고, 온프레미스 VPN/DX 연결도 각 VPC마다 별도 설정해야 합니다. 더 나은 대안은 **Transit Gateway**입니다. TGW 하나에 모든 VPC와 온프레미스 연결(VPN 또는 DX)을 어태치먼트로 연결하면, 전이 라우팅을 통해 모든 네트워크가 서로 통신할 수 있습니다. 관리 복잡도가 크게 낮아집니다.
</details>

**Q3.** 금융 기업이 Direct Connect를 사용해 AWS에 연결 중입니다. 규정상 모든 전송 데이터는 암호화되어야 합니다. 현재 구성에서 무엇이 누락되어 있으며, 어떻게 해결하나요?

<details><summary>정답 보기</summary>

Direct Connect는 **기본 암호화를 제공하지 않습니다.** 전용 회선이라는 점이 물리적 보안을 제공하지만 전송 계층 암호화는 아닙니다. 해결책은 **VPN over Direct Connect 패턴**입니다. Direct Connect 연결 위에 IPsec VPN 터널을 구성하면 전용 회선의 일관된 대역폭·저지연 특성을 유지하면서 데이터 암호화 요건도 충족할 수 있습니다.
</details>

**Q4.** SaaS 공급자가 자신의 서비스를 여러 고객 AWS 계정에 안전하게 제공하려 합니다. 고객의 VPC CIDR이 공급자 VPC와 겹칠 수 있습니다. 가장 적합한 아키텍처는?

<details><summary>정답 보기</summary>

**AWS PrivateLink(엔드포인트 서비스)**를 사용합니다. 공급자 VPC에서 서비스를 NLB 뒤에 두고 VPC 엔드포인트 서비스를 생성합니다. 각 고객은 자신의 VPC에 인터페이스 엔드포인트를 생성해 접근합니다. VPC 피어링과 달리 PrivateLink는 CIDR 겹침 제약이 없고, 고객 VPC에서 공급자 VPC의 다른 리소스에 접근할 수 없어 보안 경계도 명확합니다. 인터넷을 거치지 않으므로 트래픽은 AWS 백본 내부에서만 이동합니다.
</details>

**Q5 (원리).** 왜 VPC 피어링으로 연결된 5개 VPC 환경에서 온프레미스 연결을 추가할 때 Transit Gateway로 전환하는 것이 유리한가요?

<details><summary>정답 보기</summary>

VPC 피어링은 비전이 특성상 온프레미스와 통신해야 하는 모든 VPC마다 개별 VPN 또는 DX 연결을 설정해야 합니다. 반면 Transit Gateway에 온프레미스 연결을 어태치먼트로 한 번만 등록하면, TGW에 연결된 모든 VPC가 전이 라우팅을 통해 온프레미스와 통신할 수 있어 연결 수와 관리 부담이 크게 줄어듭니다. VPC 수가 늘수록 이 차이는 더욱 커집니다.
</details>

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. (작성·대조: 2026-06-07 · 고도화 검수: 2026-06-12)

1. AWS Site-to-Site VPN — 소개 — https://docs.aws.amazon.com/vpn/latest/s2svpn/VPC_VPN.html
2. AWS Direct Connect — 소개 — https://docs.aws.amazon.com/directconnect/latest/UserGuide/Welcome.html
3. AWS Direct Connect Gateway — https://docs.aws.amazon.com/directconnect/latest/UserGuide/direct-connect-gateways-intro.html
4. AWS Transit Gateway — 소개 — https://docs.aws.amazon.com/vpc/latest/tgw/what-is-transit-gateway.html
5. AWS PrivateLink — 소개 — https://docs.aws.amazon.com/vpc/latest/privatelink/what-is-privatelink.html
6. SAA-C03 공식 시험 가이드 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
7. AWS Transit Gateway — VPC 어태치먼트 (공식) — https://docs.aws.amazon.com/vpc/latest/tgw/tgw-vpc-attachments.html (게이트 검수 반영: 2026-06-12)
8. AWS Direct Connect SLA(가용성 99.99%/99.9%/95.0%, 대역폭·지연 약정 없음) — https://aws.amazon.com/directconnect/sla/
9. Direct Connect MACsec(전용 10/100/400 Gbps·선택 PoP·암호 스위트·256비트 키·XPN·SCI·dot1q-in-clear 미지원) — https://docs.aws.amazon.com/directconnect/latest/UserGuide/MACsec.html (갭 배치 B8b: 2026-10-21)
10. 다중 VPC 네트워크 백서 — MACsec은 2계층·지점 간이며 **홉 단위 보호라 DX 장비와 직접 2계층 인접 필요** — https://docs.aws.amazon.com/whitepapers/latest/building-scalable-secure-multi-vpc-network-infrastructure/direct-connect.html (갭 배치 B8b: 2026-10-21)
11. Direct Connect 연결 옵션·복원력 모델 4종(최대 99.99% / 높은 99.9% / 개발·테스트 / Classic 95%) — https://docs.aws.amazon.com/directconnect/latest/UserGuide/connection_options.html (갭 배치 B8b: 2026-10-21)
12. Site-to-Site VPN 쿼터 — 터널 대역폭·PPS 표와 **ECMP는 동적 라우팅 전용** — https://docs.aws.amazon.com/vpn/latest/s2svpn/vpn-limits.html (갭 배치 B8b: 2026-10-21)
13. TGW + Site-to-Site VPN 백서(ECMP 집계·IPsec·BGP 동일 CGW 종단·Accelerated VPN = Global Accelerator) — https://docs.aws.amazon.com/whitepapers/latest/aws-vpc-connectivity-options/aws-transit-gateway-vpn.html (갭 배치 B8b: 2026-10-21)
14. Accelerated Site-to-Site VPN(ECMP 합계 ~50 Gbps·흐름당은 터널 상한·⚠️ TGW에서 원격 VPC 보안 그룹 참조 불가) — https://docs.aws.amazon.com/whitepapers/latest/hybrid-connectivity/aws-accelerated-site-to-site-vpn-aws-transit-gateway-single-aws-region.html (갭 배치 B8b: 2026-10-21)
15. AWS Transit Gateway 쿼터(어태치먼트 5,000·VPC당 TGW 5·피어링 50·TGW↔CNE 1·VPN Concentrator 5) — https://docs.aws.amazon.com/vpc/latest/tgw/transit-gateway-quotas.html (갭 배치 B8b: 2026-10-21)
16. VPC 서브넷 CIDR 블록·사이징(`/28`~`/16`·예약 5개·`2^(32−prefix)−5`·BYOIP 예외) — https://docs.aws.amazon.com/vpc/latest/userguide/subnet-sizing.html (갭 배치 B8b: 2026-10-21)
17. VPC와 네트워크 간 DNS 질의 해석(인바운드·아웃바운드 엔드포인트·전달 규칙·⚠️ CIDR `+2` 직접 질의 미지원) — https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resolver-overview-DSN-queries-to-vpc.html (갭 배치 B8b: 2026-10-21)
18. 하이브리드 DNS 백서 — Resolver 엔드포인트 운영 규모(ENI당 ~10,000 QPS·로깅 가시성 없음·소스 IP 대체·RAM 공유) — https://docs.aws.amazon.com/whitepapers/latest/hybrid-cloud-dns-options-for-vpc/route-53-resolver-endpoints-and-forwarding-rules.html (갭 배치 B8b: 2026-10-21)

> 📝 **2026-10-21 보강 (갭 배치 B8b)**: ① §2에 **TGW 쿼터 표**(어태치먼트 5,000 · **VPC당 TGW 5**(조정 불가) · 피어링 50 · **TGW↔TGW/Cloud WAN CNE 1**(조정 불가) · VPN Concentrator 5·연결 100)와 **동작 제약**(같은 VPC 중복 어태치 불가 · ⚠️ **원격 VPC 보안 그룹 참조 불가** · AZ별 서브넷 지정)을 추가했습니다(근거 14·15번). ② §3에 **터널 대역폭·PPS 표**와 **ECMP**(⚠️ **TGW + 동적 라우팅 전용, 정적 라우팅 불가** · 합계 ~50 Gbps지만 **흐름당은 터널 상한**) · **VPN Concentrator** · **Accelerated VPN**(Global Accelerator로 **경로 품질** 개선, 대역폭 증가가 아님)을 추가했습니다(근거 12·13·14번). ③ §4에 **MACsec**을 추가했습니다 — 기존 서술은 암호화 선택지로 **IPsec 오버레이만** 제시하고 있었습니다(근거 9·10번). 전용/호스팅 구분·**SiteLink**·**복원력 모델 4종**도 함께 적었습니다(근거 11번). ④ 새 절 **§8 서브넷 설계와 IP 주소 지정**·**§9 글로벌 토폴로지·하이브리드 DNS·리소스 배치**를 원리 블록과 함께 넣었습니다(근거 16·17·18번) — 서브섹션이 7→9가 되어 하한이 8로 올라가므로 **원리도 2개 함께** 넣어 9/9로 맞췄고, 가드가 그 하한을 직접 검사합니다.
>
> **쓰지 않은 것**: ① **리전 선택 4요소**(규정·지연·비용·서비스 가용성) — 갭 노트 `G-3.4-08`의 틀이지만 공식 문장을 확보하지 못해 **리전 밖 배치 선택지는 `saa-t3-4` §7 교차 참조**로만 채웠습니다. ② **Cloud WAN의 수치·세부 기능** — `99-gaps.md` **V-72**로 공식 in/out-of-scope 어디에도 없어 **범위 판정 자체가 불확실**합니다. 개념과 TGW 접점(CNE 피어링)만 적고 **범위 불확실을 본문에 명시**했으며, 가드가 출제 단정을 금지합니다.

> 📝 **2026-10-19 정정**: Direct Connect의 "대역폭·지연 일관됨(SLA 보장)" 서술을 정정했습니다 — SLA가 약정하는 것은 **연결 가용성**(다중 사이트 중복 99.99%, 비중복 99.9%, 단일 연결 95.0%)이며 대역폭·지연 수치를 보장하는 문장은 없습니다(근거 8번).
