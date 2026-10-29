---
examGuideTaskId: saa-t1-3
certCode: SAA-C03
domain: 1
domainName: 보안 아키텍처 설계
domainWeightPct: 30
title: VPC 보안 네트워크 — 서브넷·SG·NACL·NAT·엔드포인트
coversTasks:
  - "1.2"
sources:
  - title: Amazon VPC — 소개 (공식)
    url: https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html
  - title: 보안 그룹으로 트래픽 제어 (공식)
    url: https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-groups.html
  - title: 네트워크 ACL로 서브넷 트래픽 제어 (공식)
    url: https://docs.aws.amazon.com/vpc/latest/userguide/vpc-network-acls.html
  - title: AWS PrivateLink 개념 (공식)
    url: https://docs.aws.amazon.com/vpc/latest/privatelink/concepts.html
  - title: SAA-C03 공식 시험 가이드 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
  - title: NAT 게이트웨이 기본 사항(AZ 이중화·대역폭·연결 수) (공식)
    url: https://docs.aws.amazon.com/vpc/latest/userguide/nat-gateway-basics.html
  - title: VPC Flow Logs(저장 대상 3종) (공식)
    url: https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html
  - title: Amazon VPC 요금(피어링 전송 과금) (공식)
    url: https://aws.amazon.com/vpc/pricing/
  - title: Amazon DNS 이해 — 규칙·고려사항 (공식)
    url: https://docs.aws.amazon.com/vpc/latest/userguide/AmazonDNS-concepts.html
  - title: Systems Manager VPC 엔드포인트 제약 — 게이트웨이 엔드포인트는 VPC 밖으로 확장 불가 (공식)
    url: https://docs.aws.amazon.com/systems-manager/latest/userguide/setup-create-vpc.html
  - title: Amazon VPC FAQ — SG vs NACL (공식)
    url: https://aws.amazon.com/vpc/faqs/
  - title: Amazon VPC 쿼터 — 보안 그룹 (공식)
    url: https://docs.aws.amazon.com/vpc/latest/userguide/amazon-vpc-limits.html
  - title: Route 53 Resolver DNS Firewall 작동 방식 (공식)
    url: https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resolver-dns-firewall-overview.html
  - title: AWS PrivateLink for DynamoDB — 게이트웨이 vs 인터페이스 엔드포인트 (공식)
    url: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/privatelink-interface-endpoints.html
  - title: AWS Network Firewall FAQ (공식)
    url: https://aws.amazon.com/network-firewall/faqs
  - title: AWS 서비스 엔드포인트 — 리전·글로벌·FIPS·듀얼스택 (공식)
    url: https://docs.aws.amazon.com/general/latest/gr/rande.html
lastVerified: 2026-10-21
---

# VPC 보안 네트워크 — 서브넷·SG·NACL·NAT·엔드포인트

> **커버하는 공식 Task** — SAA-C03 · 도메인 1 「보안 아키텍처 설계」(30%) · **Task 1.2 안전한 워크로드와 애플리케이션 설계** (`saa-t1-3`)
> 이 문서는 위 한 Task에 1:1로 매핑됩니다. VPC 네트워크 보안은 도메인 1의 두 번째 핵심 주제로, 거의 모든 아키텍처 문제의 전제가 됩니다.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명할 수 있어야 합니다. (공식 시험 가이드 Task 1.2의 Skill 항목 기반)

- [ ] **VPC와 서브넷** — 퍼블릭·프라이빗 서브넷을 결정하는 요소(라우트 테이블)를 설명할 수 있다
- [ ] **보안 그룹(SG)** — 상태 저장(Stateful)·Allow 전용 규칙의 의미를 설명하고 적용 대상을 안다
- [ ] **네트워크 ACL(NACL)** — 상태 비저장(Stateless)·Allow+Deny·번호 순 평가를 설명할 수 있다
- [ ] **SG vs NACL 비교** — 두 방화벽의 차이를 표로 재현하고 상황별 선택 기준을 안다
- [ ] **NAT 게이트웨이 vs NAT 인스턴스** — 관리형과 자체 운영의 트레이드오프를 안다
- [ ] **VPC 엔드포인트** — Gateway(S3/DynamoDB, 무료)와 Interface(PrivateLink, 유료)를 구분할 수 있다
- [ ] **VPC 피어링 vs Transit Gateway** — 비전이·전이 라우팅의 차이와 선택 기준을 안다
- [ ] **VPC Flow Logs** — 수집 정보와 활용 목적(보안 감사, 트러블슈팅)을 설명할 수 있다

---

## 🎯 왜 중요한가

- VPC는 AWS에서 EC2·RDS·ELB 등 거의 모든 컴퓨팅·데이터 리소스가 놓이는 격리된 네트워크입니다. VPC 구조를 모르면 SAA 아키텍처 문제의 절반 이상이 흐릿해집니다.
- 시험은 "인터넷 없이 S3에 접근하려면?", "특정 IP를 차단하려면?", "다수 VPC를 허브로 연결하려면?" 같은 시나리오를 주고 정확한 서비스·설정을 고르게 합니다.
- CLF에서 VPC 개념을 개략적으로 봤다면, SAA는 **보안 계층 설계**를 묻습니다 — 어떤 방화벽을 어느 레이어에 두고, 인터넷 경로를 어떻게 제어하는지가 핵심입니다.

---

## 🔤 먼저 알아야 할 용어

이 문서를 읽는 데 필요한 기초 용어입니다. 이미 알면 건너뛰세요.

| 용어 | 영문 | 한 줄 풀이 |
|---|---|---|
| **CIDR** | Classless Inter-Domain Routing | IP 범위를 `/숫자` 접두사 길이로 표현하는 방식 |
| **ENI** | Elastic Network Interface | EC2 등에 붙이는 가상 네트워크 카드 — SG는 여기에 적용됨 |
| **임시 포트** | ephemeral port | 클라이언트가 연결 시 OS가 자동 할당하는 고번호 포트(1024~65535) |
| **prefix list** | prefix list | CIDR 블록 집합을 하나의 논리 ID로 묶어 라우트·정책에서 참조하는 객체 |
| **전이 라우팅** | transitive routing | A→B→C 중간 노드를 경유해 간접 목적지에 도달하는 라우팅 |
| **PrivateLink** | AWS PrivateLink | ENI 기반으로 서비스를 VPC 내부 사설 IP로 노출하는 AWS 메커니즘 |

---

## 📖 핵심 개념 {#core-concepts}

### 1) VPC와 서브넷 — 격리된 가상 네트워크 {#vpc-subnet}

> 공식 정의: **"Amazon VPC는 AWS 리소스를 배포할 수 있는 논리적으로 격리된 가상 네트워크."** 전통적인 온프레미스 데이터센터 네트워크를 AWS 인프라 위에서 운영하는 것과 유사합니다.

**CIDR과 서브넷 크기**

| CIDR | 총 IP | 실제 사용 가능 | 주요 용도 |
|---|---|---|---|
| `/16` | 65,536 | 65,531 | VPC 범위(최대) |
| `/24` | 256 | 251 | 일반 서브넷 |
| `/28` | 16 | 11 | 서브넷 최소 단위 |

AWS는 각 서브넷에서 **5개 IP를 예약**합니다 — 첫 번째(네트워크 주소), 두 번째(VPC 라우터), 세 번째(DNS), 네 번째(예약), 마지막(브로드캐스트). `/24`(256개)의 실제 사용 가능은 **251개**입니다.

**퍼블릭 vs 프라이빗 서브넷 — 이름이 아니라 라우팅으로 결정**

| 구분 | 정의 | 배치 리소스 |
|---|---|---|
| **퍼블릭 서브넷** | 라우트 테이블에 `0.0.0.0/0 → 인터넷 게이트웨이(IGW)` 경로 존재 | ALB, NAT 게이트웨이, Bastion |
| **프라이빗 서브넷** | IGW 경로 없음 | EC2(앱), RDS, ElastiCache |

> 핵심: 서브넷 이름에 "Public"이 붙어 있어도 라우트 테이블에 IGW 경로가 없으면 프라이빗입니다. 시험에서 "퍼블릭인데 인터넷이 안 된다" → **라우트 테이블 IGW 경로 누락**을 먼저 의심하세요.

> 🧠 원리: 왜 AWS는 퍼블릭/프라이빗 구분을 서브넷 속성이 아닌 라우트 테이블로 결정할까요?
> 서브넷에 플래그를 박으면 라우팅과 상태가 분리되어 실제 경로와 속성 표시가 불일치하는 상황이 생길 수 있습니다.
> 라우트 테이블이 곧 경로 결정자이므로, IGW 경로 존재 여부 = 인터넷 도달 가능 여부가 단일 진실 소스(single source of truth)가 됩니다.
> 이 설계로 퍼블릭 IP 할당 여부나 서브넷 이름과 무관하게, 라우트 테이블만 바꾸면 서브넷의 인터넷 연결성 자체를 전환할 수 있습니다.

### 2) 핵심 네트워크 컴포넌트 {#network-components}

```
             인터넷
               │
       ┌───────┴───────┐
       │ Internet GW   │  ← VPC ↔ 인터넷 양방향 게이트
       └───────┬───────┘
 ┌─────────────┴──────────────────┐
 │ VPC (10.0.0.0/16)              │
 │  [퍼블릭 서브넷 10.0.1.0/24]  │
 │    ALB  /  NAT GW  /  Bastion  │
 │           │ (아웃바운드 전용)  │
 │           ▼                    │
 │  [프라이빗 서브넷 10.0.2.0/24]│
 │    EC2(앱서버)  /  RDS         │
 └────────────────────────────────┘
```

| 컴포넌트 | 역할 | 방향 |
|---|---|---|
| **인터넷 게이트웨이(IGW)** | VPC와 인터넷 연결 | 양방향 |
| **라우트 테이블** | 목적지별 다음 홉 결정, 서브넷에 연결 | — |
| **NAT 게이트웨이** | 프라이빗 서브넷 → 인터넷 아웃바운드 (관리형) | 아웃바운드 전용 |
| **NAT 인스턴스** | NAT 게이트웨이 역할을 EC2로 직접 구현 (레거시) | 아웃바운드 전용 |
| **Egress-Only IGW** | IPv6 전용 아웃바운드 게이트웨이 | 아웃바운드 전용 |

**NAT 게이트웨이 vs NAT 인스턴스**

| 항목 | NAT 게이트웨이 | NAT 인스턴스 |
|---|---|---|
| 관리 | AWS 관리형 (패치·스케일 자동) | 직접 운영 (AMI 업데이트, 스케일 수동) |
| 가용성 | **AZ 내 이중화**(해당 AZ 안에서만) — AZ 장애에는 AZ별 생성 필요 | 단일 EC2 — 직접 HA 구성 필요 |
| 대역폭 | 5 Gbps에서 시작해 자동 스케일 (최대 100 Gbps) | 인스턴스 타입에 종속 |
| 연결 수 | IPv4 주소당 **목적지별 동시 연결 55,000** (주소를 최대 8개까지 추가해 확장) | 인스턴스 타입·OS 설정에 종속 |
| 비용 | 시간 + 데이터 처리 과금 | EC2 인스턴스 비용 |
| 권장 | 신규 설계 시 표준 | 비용 절감 특수 상황 또는 레거시 |

> 시험 포인트: NAT 게이트웨이는 **퍼블릭 서브넷에 배치**하고 Elastic IP를 연결합니다. 프라이빗 서브넷의 라우트 테이블에 `0.0.0.0/0 → NAT 게이트웨이`를 추가해야 아웃바운드가 동작합니다.

> ⚠️ **"NAT 게이트웨이는 자동으로 고가용"이 아닙니다.** 각 NAT 게이트웨이는 **특정 AZ에 만들어지고 그 AZ 안에서만 이중화**됩니다. 여러 AZ의 리소스가 하나의 NAT 게이트웨이를 공유하면 **그 AZ가 내려갈 때 다른 AZ 리소스까지 인터넷이 끊깁니다.** 공식 권고는 **AZ마다 NAT 게이트웨이를 만들고 같은 AZ의 NAT로 라우팅**하는 것입니다. 이 구성이 시험에서 "AZ 장애에도 아웃바운드 유지" 요구의 정답 방향입니다.
> 참고 한도: 퍼블릭 NAT 게이트웨이에 기본 **Elastic IP 2개**까지 연결(쿼터 상향 요청 가능), 보안 그룹은 연결할 수 없고 **NACL로 제어**(NAT는 포트 1024–65535 사용), **VPC 피어링을 거쳐 NAT로 향하는 경로는 불가**(NAT → 피어링 방향은 가능).

> 🧠 원리: 왜 NAT 게이트웨이는 프라이빗이 아닌 퍼블릭 서브넷에 배치해야 할까요?
> NAT 게이트웨이 자신이 인터넷에 패킷을 내보내려면 IGW에 도달할 수 있어야 합니다 — IGW 경로가 있는 퍼블릭 서브넷에 있어야만 가능합니다.
> NAT 게이트웨이는 프라이빗 서브넷 EC2의 사설 IP를 자신의 Elastic IP(퍼블릭)로 변환(SNAT)해 인터넷으로 내보내고, 응답은 역변환(DNAT)해 돌려줍니다.
> 이 SNAT/DNAT 중간자 역할이 가능하려면 NAT 자신이 퍼블릭 IP를 보유한 채 IGW를 통해 인터넷과 직접 통신할 수 있는 위치에 있어야 합니다.

### 3) 보안 그룹(Security Group) vs 네트워크 ACL(NACL) ★ 단골 출제 {#sg-vs-nacl}

> 이 비교표는 시험 최빈출 주제입니다. 표를 보지 않고 재현할 수 있을 때까지 반복하세요.

| 항목 | 보안 그룹(SG) | 네트워크 ACL(NACL) |
|---|---|---|
| **적용 단위** | ENI(탄력적 네트워크 인터페이스) — 인스턴스 수준 | **서브넷** 수준 |
| **상태** | **Stateful** (응답 트래픽 자동 허용) | **Stateless** (인바운드·아웃바운드 별도 규칙 필요) |
| **규칙 유형** | **Allow만** 지원 (Deny 없음) | Allow + **Deny** 모두 지원 |
| **규칙 평가** | 모든 규칙을 종합해 판단 | **번호 순서대로** 평가, 첫 매칭에서 결정 |
| **기본 동작** | 인바운드 전부 차단 / 아웃바운드 전부 허용 | 기본 NACL: 전부 허용 / 커스텀 NACL: 전부 차단 |
| **리소스 연결** | 여러 인스턴스에 동일 SG 적용 가능 | 서브넷 1개당 NACL 1개 연결 |
| **변경 적용** | 즉시 반영 | 즉시 반영 |

**Stateful vs Stateless 차이 — 핵심 예시**

보안 그룹(Stateful): 인바운드 포트 443을 허용하면, 그 응답 트래픽은 **아웃바운드 규칙과 무관하게 자동 허용**됩니다.

NACL(Stateless): 인바운드 포트 443을 허용해도, 응답은 임시 포트(1024~65535) 범위의 **아웃바운드 규칙을 별도로 열어야** 합니다. 아웃바운드 규칙이 없으면 응답이 차단됩니다.

**두 방화벽을 함께 쓰는 이유**

SG와 NACL은 서로 보완합니다 — SG는 인스턴스 단위 세밀 제어, NACL은 서브넷 전체의 1차 필터(특히 Deny). AWS 공식 모범 사례는 두 레이어를 모두 사용하는 심층 방어(Defense in Depth)를 권장합니다.

> 🧠 원리: 왜 보안 그룹은 Deny 규칙 없이 Allow 전용으로 설계됐을까요?
> SG는 연결 상태(connection tracking)를 유지하는 Stateful 방화벽입니다 — 허용된 연결의 응답 패킷은 규칙 재평가 없이 자동 통과시킵니다.
> Deny를 허용하면 충돌 해소 규칙이 필요해지고, 같은 포트에 Allow·Deny가 공존할 때 평가 결과를 예측하기 어려워집니다.
> Allow 전용 모델에서는 "목록에 없으면 차단"(암묵적 Deny)이 기본이므로, 규칙 충돌 없이 화이트리스트를 명확하게 관리할 수 있습니다.
> Deny가 필요한 IP 차단은 Stateless·번호 순 평가인 NACL로 위임하는 계층 분리 설계입니다.

### 4) VPC 엔드포인트 — 인터넷 없이 AWS 서비스 접근 {#vpc-endpoints}

프라이빗 서브넷의 EC2가 S3·DynamoDB 같은 AWS 관리형 서비스에 접근할 때, 기본 경로는 NAT 게이트웨이 → 인터넷 → AWS 퍼블릭 엔드포인트입니다. VPC 엔드포인트는 이 경로를 **인터넷 없이 AWS 내부망으로** 대체합니다.

| 유형 | 대상 서비스 | 구현 방식 | 비용 |
|---|---|---|---|
| **Gateway Endpoint** | **S3, DynamoDB 전용** | 라우트 테이블에 prefix list 경로 추가 | **무료** |
| **Interface Endpoint** | S3·DynamoDB 외 대부분 AWS 서비스 | 서브넷에 ENI(사설 IP) 생성 (PrivateLink) | 시간 + 데이터 처리 과금 |

> 중요: Gateway Endpoint는 **PrivateLink를 사용하지 않습니다**. 라우트 테이블에 경로만 추가하는 방식이라 별도 ENI가 없고 추가 비용이 없습니다. Interface Endpoint는 PrivateLink 기반으로 ENI가 생성되며 과금됩니다.

**적용 범위 — Gateway Endpoint는 VPC 밖으로 확장되지 않습니다 (★ 시험 포인트):**

| 접근 경로 | Gateway Endpoint | Interface Endpoint |
|---|---|---|
| **같은 VPC 안에서** | 사용 가능 | 사용 가능 |
| **온프레미스**(Direct Connect·Site-to-Site VPN) | **사용 불가** | 사용 가능 |
| **피어링 상대 VPC** | **사용 불가** | 사용 가능(인트라·인터 리전 피어링) |
| **다른 리전에서** | **사용 불가** | 피어링·Transit Gateway 경유로 가능 |
| 사용하는 IP | 서비스의 **퍼블릭 IP** | VPC의 **사설 IP** |

공식 서술은 "**VPC 게이트웨이 엔드포인트 연결은 VPC 밖으로 확장할 수 없다** — VPC 피어링 반대편의 리소스는 그 게이트웨이 엔드포인트로 통신할 수 없다"입니다(출처 10번). 그래서 온프레미스 호출자와 VPC 내부 호출자가 함께 있으면 **같은 VPC에 두 유형을 같이 두는** 구성을 씁니다 — 내부 트래픽은 무료인 Gateway로, 온프레미스 트래픽은 Interface로 받습니다.

> ⚠️ **함정**: "프라이빗 서브넷 + 온프레미스에서 S3에 사설로 접근" 같은 문제에서 **Gateway Endpoint를 고르면 틀립니다.** Gateway는 라우트 테이블 기반이라 그 VPC의 라우트 테이블을 참조하는 주체만 쓸 수 있고, 온프레미스는 그 라우트 테이블을 쓰지 않습니다. 답은 Interface Endpoint이며, 온프레미스 DNS가 엔드포인트의 사설 IP를 받도록 조건부 전달(conditional forwarding)이나 Route 53 Resolver 인바운드 엔드포인트를 함께 설계합니다.

**PrivateLink란?**

AWS PrivateLink는 서비스를 **다른 VPC에 사설로 노출**하는 메커니즘입니다. Interface Endpoint의 기반 기술로, 트래픽이 인터넷·퍼블릭 IP를 거치지 않고 AWS 내부망에서만 이동합니다. SaaS 공급자가 자신의 서비스를 다른 계정 VPC에 안전하게 제공할 때도 사용됩니다.

**엔드포인트 정책**

VPC 엔드포인트에는 IAM 리소스 정책(엔드포인트 정책)을 부착할 수 있습니다. 예를 들어 S3 Gateway Endpoint에 정책을 걸어 특정 버킷에만 접근을 허용할 수 있습니다.

> 🧠 원리: 왜 S3·DynamoDB만 Gateway Endpoint를 지원하고 다른 서비스는 Interface Endpoint를 사용할까요?
> Gateway Endpoint는 라우트 테이블에 prefix list를 삽입하는 방식으로 동작합니다 — 서비스의 IP 범위가 고정적이고 사전에 알려져야 prefix list로 표현할 수 있습니다.
> S3와 DynamoDB는 AWS가 관리하는 공용 IP 대역을 쓰는 서비스로, 그 대역을 prefix list로 노출해 라우트 테이블에 박는 방식이 기술적으로 가능했습니다.
> Interface Endpoint(PrivateLink)는 반대로 서비스 측에 ENI를 하나 생성해 VPC 내부 사설 IP를 부여하는 방식이라 어떤 서비스든 적용 가능하지만, ENI 유지 비용이 발생합니다.

### 5) VPC 피어링 vs Transit Gateway — 연결 아키텍처 보안 관점 {#peering-tgw}

**VPC 피어링 — 1:1 직접 연결, 비전이**

- 두 VPC를 직접 연결합니다. 동일 계정·다른 계정·다른 리전 모두 가능합니다.
- **CIDR 대역이 중복되면 피어링 불가**합니다.
- **비전이(non-transitive)**: A-B 피어링, B-C 피어링이 있어도 A-C는 통신할 수 없습니다. A-C를 연결하려면 별도 피어링이 필요합니다. VPC 수가 늘면 연결 쌍이 폭발적으로 증가합니다.

**Transit Gateway — 허브 앤 스포크, 전이 라우팅**

- 여러 VPC와 온프레미스(VPN/Direct Connect)를 **중앙 허브 하나**로 연결합니다.
- **전이 라우팅(transitive)**: A → TGW → C 경로가 자동으로 성립합니다.
- 대규모 멀티 VPC·하이브리드 네트워크의 표준 아키텍처입니다.
- 라우트 테이블을 TGW 수준에서 관리해 트래픽 격리·세분화가 가능합니다.

```
[VPC 피어링 — VPC 4개, 전부 직접 연결]    [Transit Gateway — VPC 4개]
  A ─── B                                    A   B   C   D
  │ ╲ ╱ │                                     \  │  │  /
  │  ╳  │  (연결 6쌍 필요)                      \ │  │ /
  │ ╱ ╲ │                                        TGW (전이 라우팅)
  C ─── D
```

| 항목 | VPC 피어링 | Transit Gateway |
|---|---|---|
| 연결 모델 | 1:1 직접 | 허브 앤 스포크 |
| 전이 라우팅 | 불가 | 가능 |
| 확장성 | VPC 수 증가 시 관리 복잡 | 중앙 집중, 확장 용이 |
| 적합 상황 | VPC 2~3개, 단순 연결 | VPC 다수 또는 온프레미스 포함 |
| 비용 | 연결 보유 요금은 없음 — **AZ를 넘는 전송에 $0.01/GB**(양방향), 리전 간은 EC2 요금 기준 | 연결 시간 + 데이터 처리 과금 |

> 🧠 원리: 왜 VPC 피어링은 구조적으로 전이 라우팅이 불가능할까요?
> 피어링은 두 VPC 간 직접 경로만 추가합니다 — B 라우트 테이블에 A의 CIDR 경로가 있고, C 라우트 테이블에도 B 경로가 있지만, A가 C를 목적지로 보낸 패킷은 B의 라우터에서 다음 홉을 찾을 때 C로 향하는 피어링 경로 자체가 없습니다.
> A→C 패킷을 B가 중계하려면 B의 라우트 테이블에 C 행이 있어야 하고, B에서 C로 나가는 피어링이 따로 있어야 합니다 — 이 경우 B-C 피어링을 만들고 A-C도 직접 피어링해야 하는 것과 다를 바 없습니다.
> Transit Gateway는 중앙 라우터로서 자신의 라우트 테이블에 모든 VPC CIDR를 보유해 임의의 A→C 경로를 단일 홉(A→TGW→C)으로 해결합니다.

### 6) VPC Flow Logs — 트래픽 가시성 {#flow-logs}

VPC Flow Logs는 VPC 내 네트워크 인터페이스를 오가는 **IP 트래픽 메타데이터를 캡처**합니다. 패킷 내용(페이로드)은 포함되지 않고, 소스/목적지 IP, 포트, 프로토콜, 허용/거부 여부, 바이트 수 등의 메타데이터를 기록합니다.

**활성화 수준**: VPC 전체 / 특정 서브넷 / 특정 네트워크 인터페이스(ENI) 단위로 설정 가능합니다.

**로그 저장 대상**: **CloudWatch Logs · Amazon S3 · Amazon Data Firehose** 세 곳입니다(Firehose로 보내면 외부 분석 도구로 바로 스트리밍할 수 있습니다).

**주요 활용**

| 용도 | 설명 |
|---|---|
| 보안 감사 | 의심스러운 트래픽 소스 탐지, 허용·거부 패턴 분석 |
| 트러블슈팅 | SG/NACL 설정 오류로 인한 연결 거부 확인 |
| 규정 준수 | 네트워크 접근 이력 보관 |
| 비용 분석 | 데이터 전송 패턴 파악 |

> 🧠 원리: 왜 Flow Logs는 패킷 페이로드(내용)를 기록하지 않고 메타데이터만 수집할까요?
> 페이로드까지 캡처하면 모든 트래픽의 실제 데이터를 저장해야 해 스토리지 비용과 처리 지연이 급증하고, TLS 암호화 트래픽은 어차피 해독 없이는 의미가 없습니다.
> 보안 감사·트러블슈팅에서 필요한 것은 "어디서 어디로 어떤 포트가 허용/거부됐는가"이고, 이는 메타데이터만으로 충분히 답할 수 있습니다.
> 페이로드가 필요한 심층 패킷 검사(DPI)는 별도 전용 도구(Network Firewall, Suricata IDS 등)의 역할로 분리하는 것이 단일 책임 설계입니다.

---

### 7) 심층 트래픽 제어 — Network Firewall·DNS Firewall {#advanced-traffic-control}

SG·NACL은 IP·포트·프로토콜 수준의 필터입니다. 도메인 이름이나 위협 시그니처처럼 그 위 계층을 봐야 하는 통제는 전용 서비스가 맡습니다.

**SG·NACL이 걸러내지 못하는 것 (★ 시험 포인트):**

- **Amazon DNS 서버로 가거나 오는 트래픽은 NACL·보안 그룹으로 필터할 수 없습니다**(출처 9번). VPC Resolver를 지나는 DNS를 통제하려면 아래 **DNS Firewall**을 씁니다.
- **NACL은 같은 서브넷 안의 인스턴스 간 트래픽을 걸러내지 않습니다**(출처 11번). 같은 서브넷 내부를 가르려면 **SG**를 써야 합니다 — NACL을 촘촘히 짜도 서브넷 내부 통신은 그대로 흐릅니다.

**보안 그룹 쿼터 (★ 시험 수치, 출처 12번):**

| 항목 | 기본값 | 조정 |
|---|---|---|
| 리전당 VPC 보안 그룹 | **2,500** | 가능 |
| SG당 인바운드·아웃바운드 규칙 | **각 60** | 가능 |
| ENI당 보안 그룹 | **5** | 가능(최대 **16**) |

- 규칙 수는 **인바운드·아웃바운드가 따로**, 그리고 **IPv4·IPv6가 따로** 계산됩니다. 기본값 60이면 IPv4 인바운드 60개와 IPv6 인바운드 60개를 각각 가질 수 있습니다.
- ⚠️ **SG당 규칙 수 × ENI당 SG 수는 1,000을 넘을 수 없습니다.** 한쪽을 올리면 다른 쪽이 묶입니다 — 규칙을 200개로 올리면 ENI당 SG는 5개까지입니다.

**AWS Network Firewall** — VPC용 관리형 네트워크 방화벽입니다.

- **stateless 규칙**(출발·목적지 IP·포트·프로토콜)과 **stateful 규칙**(연결·세션을 수명 동안 유지하며 방향까지 판단) 양쪽을 지원합니다.
- **관리형 규칙 그룹**을 쓸 수 있습니다 — AWS 관리형(도메인·IP 규칙 그룹, 위협 시그니처 규칙 그룹, 글로벌 위협 인텔리전스 기반 방어)과 파트너 관리형(Marketplace 구독)이 있습니다. AWS 관리형 규칙은 Network Firewall 사용 고객에게 추가 비용이 없습니다.
- TCP·UDP 포트를 지정하는 필터뿐 아니라 **포트 지정 없이 공통 프로토콜**을 필터할 수 있습니다.

**Route 53 Resolver DNS Firewall** — Route 53 VPC Resolver를 지나 **VPC에서 나가는 DNS 쿼리**를 통제합니다.

- 도메인 필터링 규칙을 **rule group**으로 정의하고 VPC에 연결하면 그 VPC의 DNS 필터링이 켜집니다. 도메인 목록을 **허용·차단·알림(ALERT)** 할 수 있고, 차단 응답을 바꿀 수 있습니다(기본 `NODATA`). DNS 터널링·DGA 방어용 Advanced 규칙도 있습니다.
- ⚠️ **도메인 이름만 필터합니다** — 그 이름을 IP로 해석해 차단하지는 않습니다. 또 **DNS 트래픽만** 보며 HTTPS·SSH·TLS·FTP 같은 다른 애플리케이션 계층 프로토콜은 필터하지 않습니다(출처 13번). IP·프로토콜 수준까지 막아야 하면 Network Firewall과 함께 씁니다.
- Firewall Manager로 Organizations 전체 계정에 중앙 배포·관리할 수 있습니다.

| 통제 | 보는 것 | 적용 범위 |
|---|---|---|
| 보안 그룹 | IP·포트·프로토콜 (Stateful) | ENI |
| NACL | IP·포트·프로토콜 (Stateless) | 서브넷 |
| Network Firewall | IP·포트·프로토콜 + 세션·위협 시그니처 | VPC |
| DNS Firewall | **도메인 이름** | VPC(Resolver를 지나는 쿼리) |

> 🧠 원리: 왜 도메인 기준 차단이 SG·NACL이 아니라 별도 서비스로 갈라져 있을까요?
> SG·NACL이 보는 것은 패킷의 IP·포트·프로토콜입니다 — 도메인 이름은 패킷 헤더가 아니라 DNS 쿼리의 **페이로드** 안에 있습니다.
> 그래서 "이 도메인을 막아라"는 요구는 헤더 기반 필터의 표현 범위를 벗어나고, 쿼리를 해석하는 지점인 Resolver에서만 판단할 수 있습니다.
> 공식 서술도 그 한계를 그대로 적습니다 — DNS Firewall은 **도메인 이름만** 필터하며 그 이름을 IP로 해석해 차단하지 않고, DNS가 아닌 HTTPS·SSH·TLS·FTP는 필터하지 않습니다(출처 13번).
> 그래서 도메인 기준과 IP·프로토콜 기준은 서로를 대체하지 못하고, Network Firewall과 DNS Firewall을 함께 두는 구성이 나옵니다.

---

### 8) AWS 서비스 엔드포인트 유형 — 리전·FIPS·듀얼스택 {#service-endpoints}

프로그램으로 AWS 서비스를 호출할 때 쓰는 **진입점 URL**입니다. §4의 VPC 엔드포인트와는 다른 개념입니다 — VPC 엔드포인트는 VPC 안에 사설 경로를 만드는 리소스이고, 서비스 엔드포인트는 그 서비스 API의 주소 체계입니다.

| 유형 | 구문·예 | 설명 |
|---|---|---|
| **리전 엔드포인트** | `service-code.region-code.amazonaws.com` (예 `dynamodb.us-west-2.amazonaws.com`) | 대부분의 서비스가 제공. 일반적으로 IPv4를 지원합니다 |
| **글로벌 엔드포인트** | 리전이 없는 주소 | 리전을 넘는 서비스 — CloudFront · IAM · Organizations · Route 53 · Shield Advanced · Global Accelerator · Cloud WAN · WAF Classic |
| **FIPS 엔드포인트** | 예 `kms-fips.us-west-2.amazonaws.com` | FIPS 140을 준수하는 TLS 라이브러리를 씁니다. 미국 정부와 거래하는 기업에서 요구될 수 있습니다. **최소 TLS 1.2**(권장 1.3) |
| **듀얼스택 엔드포인트** | `service-code.region-code.api.aws` | IPv4·IPv6 양쪽으로 호출 가능. **Amazon S3만 예외**로 `service-code.dualstack.region-code.amazonaws.com` 형식을 씁니다 |

- 일부 서비스는 리전 엔드포인트와 함께 **리전이 없는 general 엔드포인트**도 제공합니다(EC2 `ec2.amazonaws.com` · EC2 Auto Scaling · EMR). 이때 AWS는 요청을 기본 리전인 **us-east-1**로 보냅니다.
- 지정 방법 — SDK는 `AWS_USE_FIPS_ENDPOINT=true` 환경 변수나 `~/.aws/config`의 `use_fips_endpoint=true`로, CLI는 `--endpoint-url` 옵션으로 대체 엔드포인트를 씁니다.

> 🧠 원리: 왜 같은 서비스에 리전·FIPS·듀얼스택 엔드포인트가 따로 있을까요?
> 엔드포인트는 단순한 주소가 아니라 **접속 조건의 묶음**입니다 — 어느 리전의 자원을 보는지, 어떤 TLS 라이브러리로 협상하는지, IPv4·IPv6 중 무엇으로 받는지가 주소로 갈립니다.
> 리전마다 주소가 다른 것은 리전의 자원이 서로 독립이기 때문입니다 — 공식 서술도 한 리전에 만든 EC2 인스턴스나 SQS 큐는 다른 모든 리전의 그것과 독립이라고 적습니다(출처 16번).
> FIPS가 별도 주소인 것은 요건이 **TLS 협상 자체**에 걸리기 때문입니다: FIPS 엔드포인트는 FIPS 140을 준수하는 TLS 라이브러리를 쓰고 최소 TLS 1.2를 요구합니다. 같은 주소에서 요청마다 고르게 둘 수 있는 성질이 아닙니다.
> 듀얼스택도 같은 이유로 `api.aws` 라는 별도 주소 체계를 둡니다 — IPv4·IPv6 양쪽으로 접근할 수 있게 하려면 주소가 갈려야 합니다(출처 16번).

> ⚠️ **글로벌 엔드포인트와 글로벌 서비스를 구분하세요.** 위 목록은 엔드포인트가 리전을 넘는 서비스이고, 이들 중 일부는 FIPS 같은 추가 엔드포인트를 따로 갖습니다. `saa-t1-2` §3의 리전 제한 SCP가 글로벌 서비스까지 막아 조직을 잠그는 함정이 바로 이 구분에서 나옵니다.

---

## ✍️ 시험 포인트

- **특정 IP 차단** → SG에는 Deny가 없습니다 → **NACL**을 사용합니다.
- **인스턴스 단위 세밀 허용** → **보안 그룹**. NACL은 서브넷 전체에 적용됩니다.
- **프라이빗 EC2 → 인터넷 아웃바운드** → **NAT 게이트웨이**(퍼블릭 서브넷 배치 + Elastic IP 필수). NAT는 인바운드 처리 불가입니다.
- **프라이빗 서브넷 → S3 접근, 인터넷 경유 금지** → **S3 Gateway Endpoint**(무료, 라우트 테이블 추가).
- **그 외 AWS 서비스에 사설 접근** → **Interface Endpoint**(PrivateLink, 과금).
- **VPC 2개 단순 연결** → **VPC 피어링**. CIDR 중복 여부를 먼저 확인합니다.
- **VPC 다수 + 온프레미스 중앙 연결** → **Transit Gateway**. 피어링으로 전이 통신 불가입니다.
- **네트워크 트래픽 감사·모니터링** → **VPC Flow Logs** (CloudWatch 또는 S3 저장).
- **퍼블릭 서브넷인데 인터넷 불가** → 라우트 테이블에 **IGW 경로 누락** 또는 **퍼블릭 IP 미할당** 확인.
- **NACL 규칙 순서** → 번호가 낮을수록 먼저 평가됩니다. 동일 포트에 Allow(100번)와 Deny(200번)가 있으면 Allow가 이깁니다. 반대이면 Deny가 이깁니다. 규칙은 100 단위 간격으로 만드는 것이 권장입니다.

---

## ⚠️ 흔한 함정 {#common-pitfalls}

1. **"NAT 게이트웨이로 인바운드 트래픽을 처리할 수 있다."** → NAT는 **아웃바운드 전용**입니다. 프라이빗 서브넷의 EC2에 외부에서 직접 접근하려면 ALB(퍼블릭)를 앞에 두거나 VPN/Direct Connect를 사용합니다.
   (원리: §2 — NAT는 SNAT으로 사설 IP를 퍼블릭 IP로 치환해 내보내는 역할이라 외부에서 먼저 연결을 시작하면 맵핑할 내부 IP를 알 수 없어 인바운드를 처리하지 못한다.)

2. **"보안 그룹으로 특정 IP를 차단(Deny)할 수 있다."** → SG는 Allow 규칙만 지원합니다. IP 차단은 반드시 **NACL**을 사용합니다.
   (원리: §3 — SG는 Allow 전용 화이트리스트 모델로 설계돼 Deny 역할은 NACL에 위임하는 계층 분리 구조다.)

3. **"서브넷 이름이 Public이면 퍼블릭이다."** → 퍼블릭·프라이빗 구분은 **라우트 테이블에 IGW 경로가 있는지**로 결정됩니다. 이름은 관계없습니다.
   (원리: §1 — 라우트 테이블이 단일 진실 소스이므로 이름·태그 같은 메타데이터는 실제 연결성과 무관하다.)

4. **"VPC 피어링으로 A-B-C를 전이 연결할 수 있다."** → VPC 피어링은 **비전이**입니다. A↔B, B↔C가 있어도 A↔C는 별도 피어링이 필요합니다. 전이 라우팅은 **Transit Gateway**를 사용합니다.
   (원리: §5 — 피어링은 양 끝 라우트 테이블에만 경로를 추가하므로 중간 VPC가 A→C 패킷을 다음 홉으로 전달할 경로 자체를 보유하지 않는다.)

5. **"Gateway Endpoint로 모든 AWS 서비스에 접근할 수 있다."** → Gateway Endpoint는 **S3와 DynamoDB 전용**입니다. 다른 서비스(예: SQS, SNS, API Gateway)는 Interface Endpoint(PrivateLink)를 사용합니다.
   (원리: §4 — Gateway Endpoint는 prefix list 라우팅 방식이라 IP 대역이 공개된 S3·DynamoDB에만 적용 가능하고, 그 외 서비스는 ENI 기반 Interface Endpoint를 써야 한다.)

6. **"NACL에서 인바운드만 허용하면 응답도 통과한다."** → NACL은 **Stateless**입니다. 응답 트래픽을 위한 **아웃바운드 임시 포트(1024~65535) 규칙을 별도로** 추가해야 합니다.
   (원리: §3 — NACL은 연결 상태를 추적하지 않아 응답 패킷도 독립 패킷으로 평가하며, 응답이 쓰는 임시 포트는 요청 포트와 달라 별도 규칙이 필요하다.)

7. **"CIDR가 겹치는 VPC 간에 피어링을 만들 수 있다."** → CIDR 대역이 중복되면 VPC 피어링을 생성할 수 없습니다. 설계 단계에서 VPC CIDR를 미리 분리해야 합니다.
   (원리: §5 — 피어링 라우팅은 목적지 CIDR로 다음 홉을 결정하므로, 두 VPC CIDR가 겹치면 로컬·피어 중 어느 라우트 테이블 항목을 따를지 모호성이 생겨 설정 자체가 거부된다.)

---

## 🧪 자가 점검

> 아래는 학습용 자가 점검입니다. (정식 검증 문항은 별도 문항 파일 참조)

**Q1.** 프라이빗 서브넷의 EC2 인스턴스가 운영체제 패키지 업데이트를 위해 인터넷에 연결해야 합니다. 어떻게 설계하나요?

<details><summary>정답 보기</summary>

**NAT 게이트웨이**를 퍼블릭 서브넷에 배치하고 Elastic IP를 연결합니다. 프라이빗 서브넷의 라우트 테이블에 `0.0.0.0/0 → NAT 게이트웨이` 경로를 추가합니다. NAT 게이트웨이는 프라이빗 서브넷의 아웃바운드 트래픽만 처리하며, 인터넷에서 프라이빗 EC2로 직접 인바운드 접근은 불가합니다.
</details>

**Q2.** 보안팀이 특정 악성 IP 주소 대역(`203.0.113.0/24`)으로부터의 트래픽을 즉시 차단하려 합니다. 무엇을 사용하나요?

<details><summary>정답 보기</summary>

**네트워크 ACL(NACL)**을 사용합니다. 보안 그룹은 Deny 규칙을 지원하지 않아 특정 IP를 차단할 수 없습니다. NACL에서 해당 CIDR에 대한 Deny 규칙을 낮은 번호(예: 규칙 번호 50)로 추가하면, 기존 Allow 규칙보다 먼저 평가되어 트래픽이 차단됩니다.
</details>

**Q3.** 프라이빗 서브넷의 EC2가 Amazon S3 버킷에 접근해야 하는데, 보안 정책상 트래픽이 인터넷을 경유하면 안 됩니다. 가장 비용 효율적인 방법은?

<details><summary>정답 보기</summary>

**S3 Gateway Endpoint**를 생성합니다. Gateway Endpoint는 라우트 테이블에 S3 prefix list 경로를 추가하는 방식으로, 별도 ENI가 없고 **추가 비용이 없습니다**. 트래픽이 인터넷이나 NAT 게이트웨이를 거치지 않고 AWS 내부망으로 S3에 직접 도달합니다. NAT 게이트웨이 데이터 처리 비용도 절감됩니다. Interface Endpoint(PrivateLink)도 인터넷 없이 접근 가능하지만 시간·데이터 과금이 발생하므로 S3에는 Gateway Endpoint가 우선입니다.
</details>

**Q4.** 회사가 운영·개발·스테이징 VPC 3개와 온프레미스 데이터센터를 모두 연결해야 합니다. 각 환경이 서로 통신해야 합니다. 어떻게 설계하나요?

<details><summary>정답 보기</summary>

**Transit Gateway**를 사용합니다. VPC 피어링으로 3개 VPC를 전부 연결하면 3쌍의 피어링이 필요하고, 온프레미스를 추가하면 구조가 더 복잡해집니다. Transit Gateway는 모든 VPC와 온프레미스(Site-to-Site VPN 또는 Direct Connect)를 중앙 허브 하나에 연결하고 전이 라우팅을 지원합니다. TGW 라우트 테이블로 환경 간 격리 정책도 세밀하게 설정할 수 있습니다.
</details>

**Q5 (원리).** NACL은 왜 규칙을 번호 순서대로 평가하고 첫 매칭에서 결정할까요?

<details><summary>정답 보기</summary>

**명시적 우선순위를 숫자로 표현해 예측 가능한 평가 순서를 보장하기 위해서입니다.** SG처럼 모든 규칙을 종합하는 방식에서는 Deny 규칙이 없으므로 충돌이 발생하지 않습니다. 그러나 Deny를 지원하는 NACL에서 Allow·Deny가 동일 포트에 공존하면 충돌 해소 규칙 없이는 결과를 알 수 없습니다. 번호 순 우선 평가 방식에서는 Deny를 낮은 번호에 두면 Allow보다 먼저 적용되고, Allow를 낮은 번호에 두면 Deny보다 먼저 허용됩니다 — 운영자가 숫자 배치로 의도를 명확히 표현할 수 있습니다. 규칙을 100 단위로 띄워 만드는 권장 사항도 이 번호 체계를 중간에 삽입하기 쉽게 유지하기 위한 관례입니다.
</details>

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. (작성·대조: 2026-06-07 · 고도화 검수: 2026-06-12)

1. Amazon VPC — 소개 — https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html
2. 보안 그룹으로 트래픽 제어 — https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-groups.html
3. 네트워크 ACL로 서브넷 트래픽 제어 — https://docs.aws.amazon.com/vpc/latest/userguide/vpc-network-acls.html
4. AWS PrivateLink 개념 — https://docs.aws.amazon.com/vpc/latest/privatelink/concepts.html
5. NAT 게이트웨이 기본 사항(AZ 내 이중화·AZ별 생성 권고·100 Gbps·55,000 연결) — https://docs.aws.amazon.com/vpc/latest/userguide/nat-gateway-basics.html
6. VPC Flow Logs(CloudWatch Logs·S3·Data Firehose) — https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html
7. Amazon VPC 요금(피어링은 AZ 교차 전송 $0.01/GB) — https://aws.amazon.com/vpc/pricing/
8. SAA-C03 공식 시험 가이드 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
9. Amazon DNS 이해 — 규칙·고려사항(Amazon DNS 서버 트래픽은 NACL·SG로 필터 불가) — https://docs.aws.amazon.com/vpc/latest/userguide/AmazonDNS-concepts.html
10. Systems Manager VPC 엔드포인트 제약(게이트웨이 엔드포인트 연결은 VPC 밖으로 확장 불가·피어링 반대편 사용 불가) — https://docs.aws.amazon.com/systems-manager/latest/userguide/setup-create-vpc.html
11. Amazon VPC FAQ(NACL은 같은 서브넷 내 인스턴스 간 트래픽을 필터하지 않음·stateless vs stateful) — https://aws.amazon.com/vpc/faqs/
12. Amazon VPC 쿼터 — 보안 그룹(리전당 2,500·규칙 각 60·ENI당 5~16·규칙×SG ≤ 1,000) — https://docs.aws.amazon.com/vpc/latest/userguide/amazon-vpc-limits.html
13. Route 53 Resolver DNS Firewall 작동 방식(도메인 이름만 필터·IP 해석 안 함·DNS 외 프로토콜 미필터) — https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resolver-dns-firewall-overview.html
14. AWS PrivateLink for DynamoDB — 게이트웨이 vs 인터페이스 엔드포인트(온프레미스·타 리전 접근 불가·퍼블릭/사설 IP·과금) — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/privatelink-interface-endpoints.html
15. AWS Network Firewall FAQ(stateless·stateful 규칙·AWS/파트너 관리형 규칙 그룹) — https://aws.amazon.com/network-firewall/faqs
16. AWS 서비스 엔드포인트(리전·글로벌·FIPS 최소 TLS 1.2·듀얼스택 `api.aws`, S3만 `dualstack.`) — https://docs.aws.amazon.com/general/latest/gr/rande.html

> 📝 **2026-10-21 보강(갭 `G-1.2-02`·`G-1.2-04`·`G-1.2-15`, 배치 B3)**: ① §4에 **Gateway Endpoint의 적용 범위 제약**(온프레미스·피어링 VPC·타 리전 불가 → Interface Endpoint)을 표와 함정으로 추가했습니다(근거 10·14번). ② **§7 심층 트래픽 제어**를 신설해 Network Firewall·DNS Firewall·보안 그룹 쿼터와 **SG·NACL이 걸러내지 못하는 트래픽**(Amazon DNS·같은 서브넷 내부)을 넣었습니다(근거 9·11·12·13·15번). ③ **§8 AWS 서비스 엔드포인트 유형**(리전·글로벌·FIPS·듀얼스택)을 신설했습니다(근거 16번). 기존 §1~§6의 번호와 앵커는 바꾸지 않았습니다.

> 📝 **2026-10-19 정정**: ① NAT 게이트웨이 가용성 서술을 **AZ 내 이중화 + AZ별 생성 권고**로 고치고 대역폭·동시 연결 수치를 더했습니다(근거 5번). ② Flow Logs 저장 대상에 **Amazon Data Firehose**를 추가했습니다(근거 6번). ③ VPC 피어링 비용을 "데이터 처리 과금"에서 **AZ를 넘는 전송 과금**으로 정정했습니다(근거 7번).
