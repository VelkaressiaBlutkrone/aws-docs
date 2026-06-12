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
  - title: AWS Transit Gateway — 소개 (공식)
    url: https://docs.aws.amazon.com/vpc/latest/tgw/what-is-transit-gateway.html
  - title: AWS PrivateLink — 소개 (공식)
    url: https://docs.aws.amazon.com/vpc/latest/privatelink/what-is-privatelink.html
  - title: SAA-C03 공식 시험 가이드 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
lastVerified: 2026-06-07
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

## 📖 핵심 개념

### 1) VPC 피어링 — 1:1 직접 연결, 전이 불가

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
> 이 비전이 특성이 VPC 수가 많아질수록 피어링 개수가 n(n-1)/2로 늘어나는 근본 이유이며, 그래서 Transit Gateway가 등장했습니다.

### 2) Transit Gateway — 허브-스포크, 전이 라우팅

> 공식 정의: VPC와 온프레미스 네트워크를 상호 연결하는 네트워크 전송 허브.

Transit Gateway(TGW)는 여러 VPC, VPN 연결, Direct Connect 게이트웨이를 **단일 허브에 연결**합니다. 허브를 경유하는 전이 라우팅이 가능하므로 VPC끼리 직접 피어링 없이도 통신할 수 있습니다.

| 특성 | 내용 |
|---|---|
| 어태치먼트 유형 | VPC, Site-to-Site VPN, Direct Connect 게이트웨이, 타 TGW 피어링 |
| 전이 라우팅 | O — TGW 경유 시 VPC-to-VPC 통신 가능 |
| 리전 범위 | 리전 리소스. 인터-리전은 TGW 피어링으로 연결 |
| 과금 | 어태치먼트 시간당 + 처리된 데이터 GB당 |

**피어링 vs Transit Gateway 비교 (★ 단골)**

| 항목 | VPC 피어링 | Transit Gateway |
|---|---|---|
| 연결 형태 | 1:1 직접 | 허브-스포크 |
| 전이 라우팅 | 불가 | 가능 |
| 온프레미스 통합 | 불가 (VPN/DX 별도) | 가능 (VPN/DX 어태치먼트) |
| 적합 규모 | VPC 소수 (2~3개) | VPC 다수 또는 하이브리드 |
| 비용 | 데이터 전송비만 | 어태치먼트 + 데이터 처리비 |
| CIDR 중복 | 불가 | 라우팅 테이블로 관리 가능 |

> 🧠 원리: 왜 Transit Gateway는 CIDR이 겹치는 VPC도 라우팅 테이블로 관리할 수 있을까요?
> TGW는 VPC 간 직접 IP 경로를 합치지 않고, 각 어태치먼트마다 독립된 라우팅 테이블 항목으로 경로를 결정합니다. 관리자는 어느 CIDR 대역이 어느 어태치먼트로 향할지 명시적으로 제어할 수 있습니다.
> 피어링은 두 VPC의 라우팅 테이블에 상대 CIDR을 직접 등록하므로 중복이 충돌을 일으키지만, TGW는 목적지를 어태치먼트 ID로 추상화해 CIDR 겹침을 격리 가능한 설계 선택지로 만들어 줍니다.
> 단, 겹치는 CIDR로 두 VPC가 동시에 통신하려면 여전히 라우팅 정책을 신중하게 설계해야 합니다.

### 3) Site-to-Site VPN — 인터넷 위 IPsec 터널

> 공식 정의: 온프레미스 장비와 VPC 사이의 보안 연결. IPsec VPN 연결을 지원합니다.

**구성 요소:**

| 구성 요소 | 역할 |
|---|---|
| **고객 게이트웨이(Customer Gateway, CGW)** | 온프레미스 측 라우터/방화벽 장비 또는 소프트웨어. AWS에 장비 정보를 등록하는 리소스 |
| **가상 프라이빗 게이트웨이(VGW)** | AWS 측 VPN 엔드포인트. 단일 VPC에 연결 |
| **Transit Gateway** | 여러 VPC를 공유하는 VPN 엔드포인트로도 사용 가능 |
| **VPN 터널** | CGW-VGW 사이의 암호화된 통로. 연결당 **2개 터널**(고가용성) |

터널 대역폭은 표준 1.25 Gbps, Transit Gateway 연결 시 대형 대역폭 터널로 터널당 최대 5 Gbps까지 지원합니다.

**Site-to-Site VPN 특성:**

- 구축 시간: 수 분 (즉시 사용 가능)
- 경로: 공용 인터넷 위 IPsec 터널 → 대역폭·지연 변동 가능
- 암호화: 기본 포함 (IPsec)
- 비용: 연결 시간당 + 데이터 전송비

> 🧠 원리: 왜 Site-to-Site VPN은 연결당 터널을 2개 제공할까요?
> VPN 터널은 특정 AWS 가용 영역의 엔드포인트 장비에 종단되는데, 단일 터널이면 그 장비나 AZ에 문제가 생길 때 연결 전체가 끊깁니다.
> 2개의 터널은 서로 다른 AWS 엔드포인트로 각각 연결되어 있어, 하나가 장애를 일으키면 온프레미스 장비가 자동으로 다른 터널로 트래픽을 넘길 수 있습니다.
> 이 중복 구조가 VPN 연결의 기본 가용성을 높이는 메커니즘이며, 두 터널을 동시에 활성화하면 부하 분산도 가능합니다.

### 4) Direct Connect (DX) — 전용 물리 회선

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
- 암호화: **기본 없음**. 암호화가 필요하면 DX 위에 VPN을 얹음 (DX over VPN 패턴)
- 비용: 포트 시간당 + 아웃바운드 데이터 전송비 (인터넷 대비 낮은 단가)

> 🧠 원리: 왜 Direct Connect는 기본 암호화를 포함하지 않을까요?
> Direct Connect는 ISP를 거치지 않는 전용 물리 회선으로, 공용 인터넷과 달리 경로상 제3자가 패킷을 가로채기 어려운 물리적 격리를 제공합니다.
> 그러나 물리적 격리는 전송 계층 암호화와 다르며, 내부 위협이나 DX 위치(교환 시설)에서의 트래픽 접근 가능성을 배제하지 않습니다.
> 암호화가 필요한 규정 환경에서는 DX 위에 IPsec VPN 터널을 얹는 패턴으로 물리 회선의 낮은 지연과 전송 암호화를 함께 확보할 수 있습니다.

### 5) Direct Connect Gateway — 단일 DX로 다중 리전 접근

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

### 6) VPN vs Direct Connect 비교 (★ 단골)

| 항목 | Site-to-Site VPN | Direct Connect |
|---|---|---|
| 연결 경로 | 공용 인터넷 (IPsec 암호화) | 전용 물리 회선 |
| 구축 시간 | 수 분 (즉시) | 수 주 (리드타임) |
| 대역폭·지연 | 변동 (인터넷 상황 의존) | 일관됨 (SLA 보장) |
| 암호화 | 기본 포함 | 기본 없음 |
| 비용 | 낮음 | 높음 (전용 회선) |
| 적합 상황 | 빠른 구축, 백업 연결, 소규모 트래픽 | 고대역폭, 저지연, 규정 준수, 대규모 전송 |
| 가용성 강화 | 터널 2개 기본 제공 | DX + VPN 백업 패턴 |

**조합 패턴:**

1. **DX + VPN 백업**: 평시 DX로 안정적으로 운영, DX 장애 시 VPN으로 자동 우회. 가용성과 성능을 동시에 확보합니다.
2. **DX over VPN (암호화 DX)**: DX 자체는 암호화가 없으므로, 규정상 전송 암호화가 필요한 경우 DX 위에 VPN 터널을 얹습니다.

> 🧠 원리: 왜 DX + VPN 백업 패턴이 두 서비스의 단점을 서로 보완할 수 있을까요?
> VPN은 구축이 빠르고 암호화가 포함되어 있지만 공용 인터넷 경로를 사용해 대역폭과 지연이 변동될 수 있고, DX는 일관된 전용 회선을 제공하지만 회선 장애 시 대체 경로가 없습니다.
> DX를 기본 경로로 두고 VPN을 백업으로 구성하면, 정상 운영 시에는 DX의 안정적인 대역폭을 쓰면서 DX 장애 시에는 VPN이 자동으로 우회 경로를 제공합니다.
> 이 조합은 두 서비스 중 어느 하나만 쓸 때보다 연결 가용성이 높아지며, 각각의 구축 시간·비용 특성도 단계적으로 활용할 수 있습니다.

### 7) PrivateLink와 인터페이스 엔드포인트

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

---

## ✍️ 시험 포인트

| 요구사항 | 정답 |
|---|---|
| 온프레미스 ↔ AWS, 즉시 연결, 저비용 | **Site-to-Site VPN** |
| 온프레미스 ↔ AWS, 일관된 저지연·고대역폭 | **Direct Connect** |
| DX 장애 시 자동 우회 | **DX + VPN 백업** |
| DX 연결에 암호화 추가 | **DX over VPN** |
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

## ⚠️ 흔한 함정

1. **"지금 당장 연결이 필요하다" → Direct Connect 선택.** Direct Connect 구축에는 수 주의 리드타임이 걸립니다. 즉시성이 요구되면 **Site-to-Site VPN**이 답입니다.
   *(원리: §3 본문 — VPN은 구축 시간이 수 분이고 DX는 수 주의 리드타임이 필요하다.)*

2. **"Direct Connect는 기본 암호화된다."** Direct Connect는 전용 물리 회선이지만 **기본 암호화가 없습니다.** 전송 암호화가 필요하면 DX over VPN 패턴을 사용해야 합니다.
   *(원리: §4 — 물리적 격리는 전송 계층 암호화가 아니며, 암호화가 필요하면 DX 위에 IPsec 터널을 얹어야 한다.)*

3. **"VPC 피어링을 통해 세 VPC가 서로 통신한다."** 피어링은 비전이입니다. A-B, B-C가 있어도 A는 C를 볼 수 없습니다. 세 VPC 모두 통신하려면 Transit Gateway 또는 각 쌍을 직접 피어링해야 합니다.
   *(원리: §1 — 피어링은 1:1 네트워크 약속이어서 중간 VPC가 트래픽을 중계하지 않으므로 전이 통신이 성립하지 않는다.)*

4. **"게이트웨이 엔드포인트로 모든 AWS 서비스에 접근한다."** 게이트웨이 엔드포인트는 **S3와 DynamoDB 전용**입니다. 나머지 AWS 서비스에는 인터페이스 엔드포인트(PrivateLink)를 사용해야 합니다.
   *(원리: §7 본문 — 엔드포인트 유형 표에서 게이트웨이 엔드포인트 대상은 S3·DynamoDB 전용이고 나머지는 인터페이스 엔드포인트다.)*

5. **"PrivateLink는 CIDR이 겹치면 사용 불가다."** CIDR 겹침 제약은 VPC 피어링에 해당합니다. PrivateLink는 ENI 기반으로 동작하므로 소비자-제공자 VPC의 CIDR이 겹쳐도 사용할 수 있습니다.
   *(원리: §7 — 소비자 VPC 내 ENI가 서비스 접점 역할을 하므로 제공자 VPC IP 공간이 노출되지 않아 CIDR 충돌이 발생하지 않는다.)*

6. **"Direct Connect Gateway는 VPC 간 통신 브리지다."** DXGW에 연결된 VGW끼리는 기본적으로 트래픽이 차단됩니다. VPC 간 통신이 목적이라면 Transit Gateway를 사용해야 합니다.
   *(원리: §5 본문 — DXGW는 온프레미스-VPC 연결 목적이며 같은 DXGW의 VGW 사이 트래픽은 기본 차단된다.)*

7. **"VPN은 터널이 하나다."** Site-to-Site VPN 연결에는 **항상 터널 2개**가 포함됩니다. 고가용성을 위해 두 터널을 동시에 사용할 수 있습니다.
   *(원리: §3 — 터널 2개가 서로 다른 AWS 엔드포인트에 연결되어 하나 장애 시 다른 터널로 자동 우회가 가능하다.)*

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

Direct Connect는 **기본 암호화를 제공하지 않습니다.** 전용 회선이라는 점이 물리적 보안을 제공하지만 전송 계층 암호화는 아닙니다. 해결책은 **DX over VPN 패턴**입니다. Direct Connect 연결 위에 IPsec VPN 터널을 구성하면 전용 회선의 일관된 대역폭·저지연 특성을 유지하면서 데이터 암호화 요건도 충족할 수 있습니다.
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

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. (작성·대조: 2026-06-07)

1. AWS Site-to-Site VPN — 소개 — https://docs.aws.amazon.com/vpn/latest/s2svpn/VPC_VPN.html
2. AWS Direct Connect — 소개 — https://docs.aws.amazon.com/directconnect/latest/UserGuide/Welcome.html
3. AWS Direct Connect Gateway — https://docs.aws.amazon.com/directconnect/latest/UserGuide/direct-connect-gateways-intro.html
4. AWS Transit Gateway — 소개 — https://docs.aws.amazon.com/vpc/latest/tgw/what-is-transit-gateway.html
5. AWS PrivateLink — 소개 — https://docs.aws.amazon.com/vpc/latest/privatelink/what-is-privatelink.html
6. SAA-C03 공식 시험 가이드 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
