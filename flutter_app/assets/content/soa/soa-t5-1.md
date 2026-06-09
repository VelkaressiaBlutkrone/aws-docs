---
examGuideTaskId: soa-t5-1
certCode: SOA-C03
domain: 5
domainName: 네트워킹 및 콘텐츠 전송
domainWeightPct: 18
title: VPC 네트워킹 구현 — 서브넷·라우팅·SG·NACL·NAT
coversTasks:
  - "5.1"
sources:
  - title: Amazon VPC란 무엇인가 (공식)
    url: https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html
  - title: VPC의 서브넷 (공식)
    url: https://docs.aws.amazon.com/vpc/latest/userguide/configure-subnets.html
  - title: VPC 라우팅 테이블 (공식)
    url: https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Route_Tables.html
  - title: 보안 그룹으로 리소스 트래픽 제어 (공식)
    url: https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-groups.html
  - title: 네트워크 ACL로 서브넷 트래픽 제어 (공식)
    url: https://docs.aws.amazon.com/vpc/latest/userguide/vpc-network-acls.html
  - title: NAT 게이트웨이 (공식)
    url: https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html
lastVerified: 2026-06-09
---

# VPC 네트워킹 구현 — 서브넷·라우팅·SG·NACL·NAT

> **커버하는 공식 Task** — SOA-C03 · 도메인 5 「네트워킹 및 콘텐츠 전송」(18%) · **Task 5.1 네트워킹 기능 및 연결 구현 및 최적화** (`soa-t5-1`)
> 이 문서는 VPC 내부 구성(서브넷·라우팅·게이트웨이·SG·NACL·NAT)에 집중합니다. 하이브리드/VPC 간 연결은 `soa-t5-2`에서 다룹니다.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명하고, 콘솔/CLI에서 직접 구성·진단할 수 있어야 합니다.

- [ ] **VPC와 CIDR** — VPC를 만들고 CIDR 블록을 설계하며, 서브넷이 단일 AZ에 묶임을 안다
- [ ] **퍼블릭 vs 프라이빗 서브넷** — "무엇이 서브넷을 퍼블릭으로 만드는가"(IGW 경로)를 설명할 수 있다
- [ ] **라우팅 테이블** — 대상(destination)·타겟(target)·로컬 경로·기본 경로(0.0.0.0/0)를 구성할 수 있다
- [ ] **인터넷 게이트웨이** — IGW 연결 + 퍼블릭 IP + 라우팅 3박자를 이해한다
- [ ] **NAT Gateway vs NAT Instance** — 가용성·대역폭·관리 부담·비용 차이를 비교할 수 있다
- [ ] **보안 그룹(stateful, allow-only)** vs **네트워크 ACL(stateless, allow+deny, 순서, 이페머럴 포트)** 를 구분한다
- [ ] **DNS 옵션** — enableDnsHostnames / enableDnsSupport 의 효과를 안다
- [ ] **운영 진단** — 프라이빗 인스턴스가 인터넷을 못 나갈 때 SG → NACL → 라우팅 순으로 추적할 수 있다

---

## 🎯 왜 중요한가

- 도메인 5(18%)의 출발점이 VPC입니다. 운영(Operations) 자격증인 SOA는 "VPC가 무엇인가"가 아니라 **"왜 이 인스턴스가 인터넷에 못 나가는가", "어느 계층에서 막혔는가"** 를 묻습니다. 즉 구성보다 **진단 절차**가 핵심입니다.
- 보안 그룹(상태 저장)과 네트워크 ACL(상태 비저장)의 차이는 SOA 단골 함정입니다. NACL은 응답 트래픽을 자동으로 허용하지 않기 때문에 **이페머럴 포트(임시 포트)** 를 별도로 열어야 하는데, 이걸 빠뜨려 통신이 막히는 시나리오가 반복 출제됩니다.
- NAT Gateway vs NAT Instance, 퍼블릭/프라이빗 서브넷의 정의(라우팅으로 결정됨)는 개념을 정확히 잡지 않으면 매번 헷갈립니다. SAA에서 설계 결정을 봤다면, SOA는 **이미 구성된 환경을 고치는 절차**를 요구합니다.

---

## 📖 핵심 개념

### 1) VPC와 CIDR — 가상 사설 네트워크

> 공식 정의: **"Amazon VPC는 AWS 클라우드에서 논리적으로 격리된 가상 네트워크로, 사용자가 정의한 가상 네트워크에서 AWS 리소스를 시작할 수 있게 한다."**

- **VPC는 리전 단위 리소스**이며, **여러 AZ에 걸칠 수 있습니다.**
- VPC 생성 시 **IPv4 CIDR 블록**을 지정합니다(예: `10.0.0.0/16`). 프라이빗 IP 대역(RFC 1918)을 쓰는 것이 일반적입니다.
- CIDR 크기 제약: VPC는 **/16 ~ /28** 범위. 생성 후 보조 CIDR 블록을 추가할 수 있습니다.
- 각 VPC에는 기본적으로 **로컬 라우팅 경로**가 있어 VPC 내부의 모든 서브넷은 서로 통신할 수 있습니다(이 경로는 삭제 불가).

### 2) 서브넷 — 단일 AZ, 퍼블릭/프라이빗

> 공식: **"서브넷은 VPC의 IP 주소 범위이다."** 하나의 서브넷은 **반드시 하나의 AZ에 속합니다**(AZ를 가로지를 수 없음).

| 구분 | 정의 |
|---|---|
| **퍼블릭 서브넷** | 라우팅 테이블에 **인터넷 게이트웨이(IGW)로 가는 경로**(0.0.0.0/0 → igw-xxxx)가 있는 서브넷 |
| **프라이빗 서브넷** | IGW 경로가 **없는** 서브넷. 외부 나가기는 NAT를 통해서만 |

> **핵심:** "퍼블릭이냐 프라이빗이냐"는 서브넷 자체의 속성이 아니라 **연결된 라우팅 테이블이 IGW 경로를 갖는가**로 결정됩니다. 같은 서브넷도 라우팅 테이블을 바꾸면 성격이 바뀝니다.

**서브넷 IP 예약:** AWS는 각 서브넷에서 **5개 IP를 예약**합니다(첫 4개 + 마지막 1개). 예: `10.0.0.0/24`는 251개만 사용 가능. 첫 주소는 네트워크, 두 번째는 VPC 라우터, 세 번째는 DNS, 네 번째는 향후 용도, 마지막은 브로드캐스트 예약입니다.

**고가용성:** 서브넷이 단일 AZ에 묶이므로, 가용성을 위해 **여러 AZ에 서브넷을 분산**하고 그 위에 ELB/ASG를 배치합니다.

### 3) 라우팅 테이블 — 대상과 타겟

> 라우팅 테이블은 **대상(destination CIDR)** 과 **타겟(target)** 의 규칙 집합입니다. 트래픽이 어디로 갈지 결정합니다.

| 대상(Destination) | 타겟(Target) | 의미 |
|---|---|---|
| `10.0.0.0/16` (VPC CIDR) | **local** | VPC 내부 통신(자동 생성, 삭제 불가) |
| `0.0.0.0/0` | **igw-xxxx** | 모든 외부 트래픽 → 인터넷 게이트웨이(퍼블릭) |
| `0.0.0.0/0` | **nat-xxxx** | 모든 외부 트래픽 → NAT 게이트웨이(프라이빗) |
| `0.0.0.0/0` | **eni-xxxx / i-xxxx** | NAT 인스턴스로 보낼 때 |

- **가장 구체적인(longest prefix match) 경로가 우선**합니다. `10.0.5.0/24`가 `0.0.0.0/0`보다 우선.
- **메인 라우팅 테이블**은 명시적으로 연결되지 않은 서브넷에 기본 적용됩니다. 서브넷마다 별도 **사용자 지정 라우팅 테이블**을 명시적으로 연결할 수 있습니다.

### 4) 인터넷 게이트웨이(IGW) — 퍼블릭의 3박자

인스턴스가 인터넷과 통신하려면 **세 가지가 모두** 충족돼야 합니다.

1. **IGW를 VPC에 연결**(attach)한다.
2. **서브넷 라우팅 테이블에 `0.0.0.0/0 → igw` 경로**가 있다.
3. 인스턴스에 **퍼블릭 IP(또는 Elastic IP)** 가 있다.

> IGW는 수평 확장·이중화된 관리형 컴포넌트로 대역폭 병목이 없습니다. IGW는 또한 **퍼블릭 IP ↔ 프라이빗 IP의 1:1 NAT**를 수행해, 인스턴스 내부에서는 프라이빗 IP만 보입니다.

### 5) NAT Gateway vs NAT Instance — 프라이빗의 인터넷 나가기

프라이빗 서브넷 인스턴스가 **외부로 나가되(아웃바운드)** 외부에서 직접 들어오는 건 막으려면 NAT가 필요합니다. NAT는 **퍼블릭 서브넷에 위치**하고, 프라이빗 서브넷 라우팅 테이블이 `0.0.0.0/0 → NAT`를 가리킵니다.

| 항목 | **NAT Gateway** (관리형) | **NAT Instance** (직접 EC2) |
|---|---|---|
| 관리 | AWS 완전관리(패치·교체 불필요) | 사용자가 EC2 직접 관리 |
| 가용성 | AZ 내 이중화. **AZ별로 별도 생성** 권장 | 단일 인스턴스 = 단일 장애점(스크립트로 보완) |
| 대역폭 | 자동 확장(최대 수십 Gbps) | 인스턴스 유형에 종속 |
| 보안 그룹 | **연결 불가**(NACL로만 제어) | SG 연결 가능 |
| 포트 포워딩/배스천 겸용 | 불가 | 가능(소스/대상 확인 비활성화 필요) |
| 비용 | 시간당 + 데이터 처리 GB당 | EC2 인스턴스 비용 |

> **운영 핵심:** NAT Gateway는 **단일 AZ 리소스**입니다. AZ 장애에도 견디려면 **AZ마다 NAT Gateway를 두고**, 각 AZ의 프라이빗 라우팅 테이블이 같은 AZ의 NAT를 가리키도록 구성합니다. NAT 인스턴스를 쓸 땐 반드시 **소스/대상 확인(Source/Destination Check)을 비활성화**해야 트래픽을 중계할 수 있습니다.

### 6) 보안 그룹(SG) vs 네트워크 ACL(NACL) — 두 계층의 방화벽

| 항목 | **보안 그룹 (Security Group)** | **네트워크 ACL (NACL)** |
|---|---|---|
| 적용 대상 | **ENI(인스턴스) 단위** | **서브넷 단위** |
| 상태 | **stateful(상태 저장)** | **stateless(상태 비저장)** |
| 규칙 종류 | **허용(allow)만** | **허용 + 거부(deny) 모두** |
| 평가 순서 | 모든 규칙을 종합(순서 무관) | **규칙 번호 오름차순**, 먼저 일치하면 즉시 적용 |
| 응답 트래픽 | 자동 허용(상태 추적) | **자동 허용 안 됨** → 이페머럴 포트 필요 |
| 기본값 | 인바운드 모두 거부, 아웃바운드 모두 허용 | 기본 NACL은 모두 허용 / 사용자 NACL은 모두 거부 |

**stateful의 의미(SG):** 인바운드로 들어온 요청에 대한 응답은 아웃바운드 규칙과 무관하게 자동 허용됩니다. 반대도 마찬가지. 그래서 SG는 "허용할 것만" 적으면 됩니다.

**stateless의 의미(NACL):** 들어오는 트래픽과 나가는 응답을 **각각 따로** 평가합니다. 예를 들어 인바운드 HTTP(80)를 허용해도, 응답이 나가는 **이페머럴 포트(1024–65535)** 의 아웃바운드 규칙이 없으면 응답이 차단됩니다.

> **이페머럴 포트(임시 포트):** 클라이언트가 연결할 때 OS가 임의로 고르는 출발지 포트 범위. NACL에서는 **응답 트래픽이 이 포트로 오가므로**, 인바운드/아웃바운드 양쪽에 이페머럴 포트 범위(`1024–65535`)를 명시적으로 허용해야 양방향 통신이 됩니다.

```
# NACL 규칙 예시 — 웹 서버 서브넷 (stateless라 응답 포트까지 열어야 함)
Inbound  100  HTTP(80)   0.0.0.0/0   ALLOW   # 요청 수신
Inbound  110  HTTPS(443) 0.0.0.0/0   ALLOW
Outbound 100  TCP 1024-65535 0.0.0.0/0 ALLOW # 응답을 위한 이페머럴 포트
```

### 7) DNS 옵션 — enableDnsSupport / enableDnsHostnames

| 속성 | 효과 |
|---|---|
| **enableDnsSupport** | VPC 내에서 **Amazon DNS 서버(.2 주소) 해석을 켤지** 여부. 켜야 인스턴스가 DNS 이름을 풀 수 있음 |
| **enableDnsHostnames** | VPC 내 인스턴스가 **퍼블릭 DNS 호스트네임을 받을지** 여부 |

> S3 인터페이스 엔드포인트나 프라이빗 호스팅 영역이 동작하려면 **enableDnsSupport가 켜져 있어야** 합니다. 두 옵션이 꺼져 있어 DNS 이름 해석이 안 되는 것이 의외로 흔한 장애 원인입니다.

---

## ✍️ 시험 포인트

- **서브넷은 단일 AZ**. VPC는 리전(다중 AZ). 고가용성은 다중 AZ 서브넷 + ELB/ASG.
- **퍼블릭 서브넷 = 라우팅 테이블에 IGW 경로 존재.** 서브넷 자체 속성이 아니라 라우팅으로 결정.
- **인터넷 연결 3박자**: IGW 연결 + `0.0.0.0/0 → igw` 경로 + 퍼블릭 IP/EIP.
- **NAT는 아웃바운드 전용**(프라이빗 → 외부). 외부에서 프라이빗으로 직접 들어오기는 안 됨.
- **NAT Gateway = AZ 단위 관리형, SG 연결 불가.** 다중 AZ 가용성은 AZ마다 NAT GW.
- **NAT Instance = Source/Dest Check 비활성화** 필수, SG 연결 가능.
- **SG = stateful, allow-only, ENI 단위.** 응답 자동 허용.
- **NACL = stateless, allow+deny, 서브넷 단위, 규칙 번호 순서.** 응답은 **이페머럴 포트**를 따로 열어야 함.
- **서브넷당 5개 IP 예약** (사용 가능 = 전체 − 5).
- **enableDnsSupport / enableDnsHostnames** — 프라이빗 DNS·엔드포인트 동작의 전제.

---

## ⚠️ 흔한 함정

1. **"서브넷을 퍼블릭으로 설정하는 체크박스가 있다."** → 없습니다. 퍼블릭/프라이빗은 **라우팅 테이블에 IGW 경로가 있는지**로 결정됩니다(+퍼블릭 IP). "auto-assign public IP"는 별개 옵션입니다.

2. **"NACL에서 인바운드만 열면 통신된다."** → NACL은 **stateless**라 응답이 자동 허용되지 않습니다. 응답이 나가는 **이페머럴 포트(1024–65535)** 의 반대 방향 규칙을 빠뜨리면 연결이 절반만 됩니다. SG는 stateful이라 이 문제가 없습니다.

3. **"NAT Gateway에 보안 그룹을 붙여 제어한다."** → NAT Gateway는 **SG를 연결할 수 없습니다.** 트래픽 제어는 서브넷 NACL과 라우팅으로 합니다. NAT 인스턴스는 SG 연결이 가능합니다.

4. **"NAT 하나면 모든 AZ가 안전하다."** → NAT Gateway는 **단일 AZ 리소스**입니다. 그 AZ가 죽으면 다른 AZ 프라이빗 인스턴스의 인터넷도 끊깁니다. **AZ마다 NAT Gateway**를 두고 각 AZ 라우팅을 분리해야 합니다.

5. **"NAT 인스턴스를 만들었는데 트래픽 중계가 안 된다."** → **소스/대상 확인(Source/Destination Check)** 이 켜져 있으면 자기 IP가 아닌 트래픽을 버립니다. NAT 인스턴스는 이걸 **비활성화**해야 합니다.

6. **"프라이빗 인스턴스에서 외부로 나가려면 퍼블릭 IP를 준다."** → 프라이빗 인스턴스에 퍼블릭 IP를 줘도 IGW 경로가 없으면 못 나갑니다. 프라이빗의 정석은 **NAT 경유 아웃바운드**입니다.

7. **"SG 규칙에 거부(deny)를 추가한다."** → SG는 **허용 규칙만** 가능합니다. 특정 IP를 명시적으로 차단하려면 **NACL의 deny 규칙**을 써야 합니다.

---

## 🧪 자가 점검

> 아래는 학습용 자가 점검입니다. (정식 검증 문항은 별도 문항 파일 참조)

**Q1.** 프라이빗 서브넷의 EC2 인스턴스에서 `yum update`(외부 패키지 다운로드)가 실패합니다. 보안 그룹 아웃바운드는 모두 허용 상태입니다. 무엇을 점검해야 하나요?

<details><summary>정답 보기</summary>

프라이빗 서브넷이 **외부로 나가는 경로(NAT)** 를 갖고 있는지 점검합니다. 순서대로: ① 프라이빗 서브넷 라우팅 테이블에 `0.0.0.0/0 → NAT Gateway` 경로가 있는가, ② NAT Gateway가 **퍼블릭 서브넷**에 있고 그 퍼블릭 서브넷 라우팅이 `0.0.0.0/0 → IGW`인가, ③ NAT Gateway에 Elastic IP가 있는가, ④ 서브넷 NACL이 아웃바운드 HTTPS(443)와 응답용 이페머럴 포트(인바운드 1024–65535)를 허용하는가. 대개 NAT 경로 누락이나 NACL 이페머럴 포트 누락이 원인입니다.
</details>

**Q2.** 보안 그룹에서 인바운드 80을 허용했는데, 같은 서브넷의 NACL에서는 인바운드 80만 허용하고 아웃바운드는 비워 두었습니다. 웹 요청에 응답이 돌아오지 않습니다. 왜인가요?

<details><summary>정답 보기</summary>

**NACL은 stateless**이기 때문입니다. 인바운드 80으로 요청은 들어오지만, 서버의 응답은 클라이언트의 **이페머럴 포트(1024–65535)** 로 나가야 하는데 NACL 아웃바운드에 그 포트 허용 규칙이 없어 응답이 차단됩니다. NACL 아웃바운드에 `TCP 1024–65535 ALLOW`를 추가하면 해결됩니다. 보안 그룹만 있었다면 stateful이라 응답이 자동 허용돼 문제가 없었을 것입니다.
</details>

**Q3.** 두 AZ에 프라이빗 서브넷이 있고, 하나의 NAT Gateway(AZ-a)만 사용 중입니다. AZ-a에 장애가 발생하면 어떤 일이 벌어지며, 어떻게 설계해야 하나요?

<details><summary>정답 보기</summary>

NAT Gateway는 **단일 AZ 리소스**이므로 AZ-a 장애 시 **AZ-b 프라이빗 인스턴스의 아웃바운드 인터넷도 끊깁니다**(AZ-b 라우팅이 AZ-a NAT를 가리키므로). 올바른 설계는 **각 AZ에 NAT Gateway를 하나씩** 두고, 각 AZ의 프라이빗 라우팅 테이블이 **같은 AZ의 NAT**를 가리키게 하는 것입니다. 이러면 한 AZ가 죽어도 다른 AZ는 독립적으로 인터넷을 유지합니다.
</details>

**Q4.** 특정 악성 IP 한 개를 VPC 서브넷 전체에서 차단하고 싶습니다. 보안 그룹으로 가능한가요?

<details><summary>정답 보기</summary>

불가능합니다. **보안 그룹은 허용(allow) 규칙만** 지원하므로 특정 IP를 "거부"할 수 없습니다. 명시적 차단은 **네트워크 ACL의 deny 규칙**으로 합니다. 해당 IP를 낮은 규칙 번호(먼저 평가)로 deny 추가하면 서브넷 전체에 적용됩니다. NACL은 규칙 번호 오름차순으로 평가되어 먼저 일치하는 규칙이 적용됩니다.
</details>

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 AWS 자료를 기준으로 작성했습니다. (작성·대조: 2026-06-09)

1. Amazon VPC란 무엇인가 — https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html
2. VPC의 서브넷 — https://docs.aws.amazon.com/vpc/latest/userguide/configure-subnets.html
3. VPC 라우팅 테이블 — https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Route_Tables.html
4. 보안 그룹으로 리소스 트래픽 제어 — https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-groups.html
5. 네트워크 ACL로 서브넷 트래픽 제어 — https://docs.aws.amazon.com/vpc/latest/userguide/vpc-network-acls.html
6. NAT 게이트웨이 — https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html
