---
examGuideTaskId: soa-t5-2
certCode: SOA-C03
domain: 5
domainName: 네트워킹 및 콘텐츠 전송
domainWeightPct: 18
title: 하이브리드·연결 — 피어링·TGW·VPN·Direct Connect·엔드포인트
coversTasks:
  - "5.1"
sources:
  - title: VPC 피어링이란 무엇인가 (공식)
    url: https://docs.aws.amazon.com/vpc/latest/peering/what-is-vpc-peering.html
  - title: AWS Transit Gateway란 무엇인가 (공식)
    url: https://docs.aws.amazon.com/vpc/latest/tgw/what-is-transit-gateway.html
  - title: AWS Site-to-Site VPN이란 무엇인가 (공식)
    url: https://docs.aws.amazon.com/vpn/latest/s2svpn/VPC_VPN.html
  - title: AWS Direct Connect란 무엇인가 (공식)
    url: https://docs.aws.amazon.com/directconnect/latest/UserGuide/Welcome.html
  - title: AWS PrivateLink 및 VPC 엔드포인트 (공식)
    url: https://docs.aws.amazon.com/vpc/latest/privatelink/what-is-privatelink.html
  - title: 게이트웨이 VPC 엔드포인트 (S3·DynamoDB) (공식)
    url: https://docs.aws.amazon.com/vpc/latest/privatelink/gateway-endpoints.html
lastVerified: 2026-06-09
---

# 하이브리드·연결 — 피어링·TGW·VPN·Direct Connect·엔드포인트

> **커버하는 공식 Task** — SOA-C03 · 도메인 5 「네트워킹 및 콘텐츠 전송」(18%) · **Task 5.1 네트워킹 기능 및 연결 구현 및 최적화** (`soa-t5-2`)
> 이 문서는 VPC 간 연결과 온프레미스↔AWS 하이브리드 연결, VPC 엔드포인트에 집중합니다. VPC 내부 구성은 `soa-t5-1`에서 다룹니다.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명하고, 콘솔/CLI에서 직접 구성·선택할 수 있어야 합니다.

- [ ] **VPC 피어링** — 비전이(non-transitive) 특성과 CIDR 중첩 불가 제약을 설명할 수 있다
- [ ] **Transit Gateway** — 허브-스포크 + 전이 라우팅 + TGW 라우팅 테이블 구조를 그릴 수 있다
- [ ] **Site-to-Site VPN** — VGW/CGW/터널 2개 구성과 가용성을 설명할 수 있다
- [ ] **Direct Connect** — 전용 회선·VIF 종류·기본 무암호화·DX+VPN 백업을 안다
- [ ] **Gateway vs Interface 엔드포인트** — S3/DynamoDB 라우팅 기반 무료 vs PrivateLink/ENI 시간당 과금을 구분한다
- [ ] **연결 옵션 선택** — 온프레미스↔VPC, VPC↔VPC 시나리오에서 적절한 서비스를 고를 수 있다
- [ ] **운영 진단** — 하이브리드 경로에서 라우팅 전파/터널 상태를 점검할 수 있다

---

## 🎯 왜 중요한가

- 도메인 5에서 "온프레미스를 어떻게 잇느냐", "여러 VPC를 어떻게 연결하느냐", "프라이빗 서브넷에서 S3를 인터넷 없이 어떻게 부르느냐"는 운영 시나리오로 반복 출제됩니다.
- VPC 피어링의 **비전이성**과 **CIDR 중첩 불가**, Transit Gateway의 **전이 라우팅**은 단골 비교 함정입니다. "A-B, B-C 피어링이 있는데 A-C가 안 된다"는 문제의 정답은 TGW이거나 직접 피어링 추가입니다.
- **Gateway 엔드포인트(S3·DynamoDB, 무료, 라우팅 기반)** vs **Interface 엔드포인트(PrivateLink, ENI, 시간당 과금)** 의 구분은 비용·동작 방식이 달라 정확히 외워야 합니다. SOA는 "어떤 엔드포인트를 만들고 라우팅/DNS를 어떻게 거는가"라는 **구성 절차**를 묻습니다.

---

## 📖 핵심 개념

### 1) VPC 피어링 — 1:1, 비전이, CIDR 중첩 불가

> 공식 정의: **"두 VPC 사이의 네트워킹 연결로, 프라이빗 IPv4/IPv6 주소를 사용해 두 VPC 간 트래픽을 라우팅할 수 있게 한다."**

- 같은 계정·다른 계정·다른 리전(인터-리전 피어링) 모두 지원합니다.
- **CIDR 중첩 불가:** 두 VPC의 IP 대역이 겹치면 피어링을 만들 수 없습니다.
- **비전이(non-transitive):** A↔B, B↔C 피어링이 있어도 **A↔C는 통신 불가**. 직접 피어링을 또 만들어야 합니다.
- 피어링 후에는 **양쪽 VPC 라우팅 테이블에 상대 CIDR 경로**를 추가해야 실제로 통신됩니다(피어링 생성만으로는 안 됨).

> VPC 수가 늘면 필요한 피어링 쌍은 **n(n-1)/2** 로 증가합니다(4개=6, 10개=45). 규모가 커지면 Transit Gateway가 유리합니다.

### 2) Transit Gateway(TGW) — 허브-스포크, 전이 라우팅

> 공식 정의: **"VPC와 온프레미스 네트워크를 상호 연결하는 네트워크 전송 허브."**

TGW는 여러 VPC, Site-to-Site VPN, Direct Connect 게이트웨이를 **하나의 허브에 어태치먼트로 연결**합니다. 허브를 경유하는 **전이 라우팅**이 가능해 VPC끼리 직접 피어링 없이 통신합니다.

| 특성 | 내용 |
|---|---|
| 어태치먼트 유형 | VPC, Site-to-Site VPN, Direct Connect 게이트웨이, 타 TGW 피어링 |
| 전이 라우팅 | O — TGW 경유로 VPC-to-VPC, VPC-to-온프레미스 통신 가능 |
| TGW 라우팅 테이블 | 어태치먼트를 격리/공유하도록 **세그먼트화** 가능(예: 운영망/개발망 분리) |
| 리전 범위 | 리전 리소스. 인터-리전은 **TGW 피어링**으로 연결 |
| 과금 | 어태치먼트 시간당 + 처리된 데이터 GB당 |

> **운영 핵심:** TGW는 여러 **라우팅 테이블**을 두어 어떤 어태치먼트가 어떤 어태치먼트와 통신할지 제어합니다. 모든 VPC를 다 연결하지 않고 특정 그룹만 통신하게 하는 세그먼트화가 가능합니다.

```
[피어링 메시 — VPC 4개]           [Transit Gateway 허브-스포크]
 A ─── B                            A    B    C    온프레미스(VPN/DX)
 │ ╲   │   (6개 피어링)              \   │   /    /
 C ─── D                              TGW (전이 라우팅 O)
```

### 3) Site-to-Site VPN — 인터넷 위 IPsec 터널

> 공식: 온프레미스 장비와 AWS 사이의 **IPsec VPN 연결**.

| 구성 요소 | 역할 |
|---|---|
| **고객 게이트웨이(CGW)** | 온프레미스 측 라우터/방화벽 정보를 AWS에 등록하는 리소스 |
| **가상 프라이빗 게이트웨이(VGW)** | AWS 측 VPN 엔드포인트(단일 VPC에 연결) |
| **Transit Gateway** | 여러 VPC를 공유하는 VPN 엔드포인트로도 사용 가능 |
| **VPN 터널** | CGW-VGW 사이의 암호화 통로. 연결당 **2개 터널**(고가용성) |

- 구축 시간: **수 분(즉시)**. 경로는 공용 인터넷 → 대역폭·지연 변동 가능.
- 암호화: **기본 포함(IPsec)**.
- **라우팅:** 정적 라우팅 또는 **동적 라우팅(BGP)**. 동적이면 온프레미스 경로가 자동 전파됩니다.

> **가용성:** VPN 연결은 항상 **터널 2개**(서로 다른 엔드포인트)를 제공합니다. CGW가 두 터널을 모두 활성화하도록 구성해야 한 터널 장애 시에도 끊기지 않습니다.

### 4) Direct Connect(DX) — 전용 물리 회선

> 공식: 표준 이더넷 광케이블로 내부 네트워크를 Direct Connect 위치에 직접 연결. ISP를 우회합니다.

**가상 인터페이스(VIF) 유형:**

| VIF 유형 | 용도 |
|---|---|
| **프라이빗 VIF** | 프라이빗 IP로 특정 VPC(VGW) 접근 |
| **퍼블릭 VIF** | 모든 AWS 퍼블릭 서비스에 퍼블릭 IP로 접근 |
| **트랜짓 VIF** | Direct Connect 게이트웨이를 통해 **Transit Gateway**에 연결 |

- 구축 시간: **수 주(물리 회선 설치)**. 경로는 전용 회선 → **일관된 대역폭·저지연**.
- 암호화: **기본 없음**. 전송 암호화가 필요하면 **DX 위에 VPN을 얹음(DX over VPN)**.
- **DX + VPN 백업:** 평시 DX, DX 장애 시 VPN으로 자동 우회 → 가용성 + 성능 확보.

### 5) VPC 엔드포인트 — Gateway vs Interface (★ 핵심)

프라이빗 서브넷에서 **인터넷을 거치지 않고** AWS 서비스에 접근하는 메커니즘입니다.

| 유형 | **게이트웨이 엔드포인트** | **인터페이스 엔드포인트 (PrivateLink)** |
|---|---|---|
| 대상 서비스 | **S3, DynamoDB 전용** | 대부분의 AWS 서비스 + 사용자 서비스 |
| 동작 방식 | **라우팅 테이블에 경로(prefix list) 추가** | **서브넷에 ENI + 사설 IP** 생성 |
| 비용 | **무료** | **시간당 + 처리 데이터 GB당 과금** |
| 보안 제어 | 엔드포인트 정책 + 라우팅 | **보안 그룹** + 엔드포인트 정책 |
| DNS | (라우팅 기반, DNS 변경 없음) | **프라이빗 DNS**로 서비스 기본 도메인이 ENI로 해석 |
| 리전/AZ | 리전 단위(라우팅) | **AZ별 ENI** 배치 |

> **Gateway 엔드포인트(S3/DynamoDB):** 라우팅 테이블에 **prefix list(`pl-xxxx`) → vpce** 경로가 자동 추가됩니다. 그 서브넷에서 S3/DynamoDB로 가는 트래픽이 인터넷 대신 AWS 백본으로 흐릅니다. **무료**이고 라우팅 기반이라 SG가 없습니다.

> **Interface 엔드포인트(PrivateLink):** 서브넷에 **ENI**가 생기고, **프라이빗 DNS**를 켜면 서비스의 기본 엔드포인트 이름(예: `sqs.ap-northeast-2.amazonaws.com`)이 그 ENI의 사설 IP로 해석됩니다. **보안 그룹**으로 접근 제어하며 **시간당 + 데이터 처리 비용**이 듭니다.

```
프라이빗 서브넷 인스턴스 → (S3) ──→ Gateway 엔드포인트 (라우팅, 무료)
                        → (SQS) ─→ Interface 엔드포인트 (ENI+사설IP, 과금)
   둘 다 인터넷 게이트웨이/NAT 불필요 — AWS 백본 내부 경로
```

---

## ✍️ 시험 포인트

- **VPC 피어링 = 1:1, 비전이, CIDR 중첩 불가.** 피어링 후 **양쪽 라우팅 테이블**에 경로 추가 필요.
- **A-B, B-C 피어링인데 A-C 통신 필요** → 직접 피어링 추가 또는 **Transit Gateway**.
- **Transit Gateway = 허브-스포크 + 전이 라우팅 + 라우팅 테이블 세그먼트화.** 인터-리전은 TGW 피어링.
- **Site-to-Site VPN = 즉시 구축, IPsec 기본 암호화, 터널 2개**. BGP로 동적 라우팅.
- **Direct Connect = 전용 회선, 일관된 저지연, 기본 무암호화.** 암호화 필요 시 **DX over VPN**.
- **VIF**: 프라이빗(VPC), 퍼블릭(AWS 퍼블릭 서비스), 트랜짓(TGW).
- **Gateway 엔드포인트 = S3·DynamoDB 전용, 라우팅 기반, 무료, SG 없음.**
- **Interface 엔드포인트 = PrivateLink, ENI+사설 IP, 시간당+데이터 과금, SG 있음, 프라이빗 DNS.**
- **DX + VPN 백업** = 평시 DX, 장애 시 VPN 자동 우회.

---

## ⚠️ 흔한 함정

1. **"피어링을 만들면 바로 통신된다."** → 피어링 생성만으로는 안 됩니다. **양쪽 VPC 라우팅 테이블에 상대 CIDR 경로**를 추가하고, 필요 시 SG/NACL도 허용해야 실제 트래픽이 흐릅니다.

2. **"A-B, B-C 피어링이 있으니 A도 C와 통신한다."** → 피어링은 **비전이**입니다. A-C 전용 피어링을 또 만들거나, 다수 VPC라면 **Transit Gateway**로 전환합니다.

3. **"CIDR이 겹쳐도 피어링하면 된다."** → 피어링은 **CIDR 중첩을 허용하지 않습니다.** CIDR이 겹치는데 서비스를 공유해야 한다면 **PrivateLink(인터페이스 엔드포인트)** 가 대안입니다.

4. **"게이트웨이 엔드포인트로 SQS·KMS 등 모든 서비스에 접근한다."** → 게이트웨이 엔드포인트는 **S3와 DynamoDB 전용**입니다. 나머지는 **인터페이스 엔드포인트(PrivateLink)** 를 사용합니다.

5. **"인터페이스 엔드포인트도 무료다."** → 인터페이스 엔드포인트는 **시간당 + 데이터 처리 GB당 과금**됩니다. 무료는 **게이트웨이 엔드포인트(S3/DynamoDB)** 뿐입니다.

6. **"Direct Connect는 전용 회선이라 암호화된다."** → DX는 **기본 암호화가 없습니다.** 물리적 전용성과 암호화는 다릅니다. 전송 암호화가 필요하면 **DX over VPN**.

7. **"VPN은 터널이 하나라 장애에 약하다."** → Site-to-Site VPN은 **항상 터널 2개**를 제공합니다. CGW에서 두 터널을 모두 활성화하면 한 터널 장애에도 견딥니다.

---

## 🧪 자가 점검

> 아래는 학습용 자가 점검입니다. (정식 검증 문항은 별도 문항 파일 참조)

**Q1.** VPC 3개(운영/공유/개발)가 있고, 운영과 개발은 각각 공유 VPC와만 통신해야 하며 운영-개발 직접 통신은 막아야 합니다. 어떻게 구성하나요?

<details><summary>정답 보기</summary>

**Transit Gateway + 라우팅 테이블 세그먼트화**로 구성합니다. 운영·공유·개발 VPC를 모두 TGW에 어태치먼트로 연결하되, TGW 라우팅 테이블을 분리해 운영과 개발이 각각 공유 VPC로만 라우팅되고 서로의 CIDR로는 경로가 없게 만듭니다. 단순 피어링으로 하면 비전이 특성상 운영-개발이 자동으로 막히긴 하지만, 다수 VPC 관리와 온프레미스 통합까지 고려하면 TGW가 운영상 깔끔합니다.
</details>

**Q2.** 프라이빗 서브넷의 인스턴스가 S3에 대량 데이터를 업로드합니다. NAT Gateway 데이터 처리 비용이 크게 발생합니다. 비용을 줄이려면?

<details><summary>정답 보기</summary>

**S3용 게이트웨이 VPC 엔드포인트**를 만듭니다. 게이트웨이 엔드포인트는 **무료**이고 라우팅 테이블에 S3 prefix list 경로를 추가해 트래픽이 NAT/인터넷 대신 **AWS 백본**으로 흐르게 합니다. 이러면 S3 트래픽이 NAT Gateway를 거치지 않아 데이터 처리 비용이 사라집니다. DynamoDB도 동일하게 게이트웨이 엔드포인트로 처리합니다.
</details>

**Q3.** 프라이빗 서브넷 인스턴스가 인터넷 없이 SQS와 Secrets Manager를 호출해야 합니다. 어떤 엔드포인트를 쓰며 어떻게 동작하나요?

<details><summary>정답 보기</summary>

**인터페이스 엔드포인트(PrivateLink)** 를 SQS와 Secrets Manager 각각에 대해 만듭니다. 서브넷에 **ENI + 사설 IP**가 생성되고, **프라이빗 DNS**를 활성화하면 서비스 기본 도메인이 그 사설 IP로 해석되어 코드 변경 없이 사설 경로로 호출됩니다. 엔드포인트에 **보안 그룹**을 붙여 접근을 제어합니다. 게이트웨이 엔드포인트는 S3/DynamoDB 전용이라 이 서비스들에는 쓸 수 없습니다(시간당+데이터 과금 발생).
</details>

**Q4.** 온프레미스↔AWS를 Direct Connect로 연결 중인데, 규정상 전송 데이터 암호화가 필요하고 DX 장애 시 자동 우회도 요구됩니다. 어떻게 설계하나요?

<details><summary>정답 보기</summary>

두 패턴을 결합합니다. ① **DX over VPN**: Direct Connect 위에 IPsec VPN 터널을 얹어 전송 암호화 요건을 충족합니다(DX는 기본 무암호화). ② **DX + VPN 백업**: 별도 Site-to-Site VPN을 백업 경로로 두어 DX 장애 시 인터넷 기반 VPN으로 자동 우회합니다. BGP 동적 라우팅으로 경로 우선순위를 조정하면 평시 DX, 장애 시 VPN으로 전환됩니다.
</details>

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 AWS 자료를 기준으로 작성했습니다. (작성·대조: 2026-06-09)

1. VPC 피어링이란 무엇인가 — https://docs.aws.amazon.com/vpc/latest/peering/what-is-vpc-peering.html
2. AWS Transit Gateway란 무엇인가 — https://docs.aws.amazon.com/vpc/latest/tgw/what-is-transit-gateway.html
3. AWS Site-to-Site VPN이란 무엇인가 — https://docs.aws.amazon.com/vpn/latest/s2svpn/VPC_VPN.html
4. AWS Direct Connect란 무엇인가 — https://docs.aws.amazon.com/directconnect/latest/UserGuide/Welcome.html
5. AWS PrivateLink 및 VPC 엔드포인트 — https://docs.aws.amazon.com/vpc/latest/privatelink/what-is-privatelink.html
6. 게이트웨이 VPC 엔드포인트(S3·DynamoDB) — https://docs.aws.amazon.com/vpc/latest/privatelink/gateway-endpoints.html
