---
examGuideTaskId: soa-t5-4
certCode: SOA-C03
domain: 5
domainName: 네트워킹 및 콘텐츠 전송
domainWeightPct: 18
title: 네트워크 문제 해결 — Flow Logs·Reachability Analyzer
coversTasks:
  - "5.3"
sources:
  - title: VPC 흐름 로그 (공식)
    url: https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html
  - title: 흐름 로그 레코드 (필드) (공식)
    url: https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs-records-examples.html
  - title: Reachability Analyzer란 무엇인가 (공식)
    url: https://docs.aws.amazon.com/vpc/latest/reachability/what-is-reachability-analyzer.html
  - title: Network Access Analyzer란 무엇인가 (공식)
    url: https://docs.aws.amazon.com/vpc/latest/network-access-analyzer/what-is-network-access-analyzer.html
  - title: 보안 그룹과 네트워크 ACL 비교 (공식)
    url: https://docs.aws.amazon.com/vpc/latest/userguide/infrastructure-security.html
lastVerified: 2026-06-12
---

# 네트워크 문제 해결 — Flow Logs·Reachability Analyzer

> **커버하는 공식 Task** — SOA-C03 · 도메인 5 「네트워킹 및 콘텐츠 전송」(18%) · **Task 5.3 네트워크 연결 문제 해결** (`soa-t5-4`)
> 이 문서는 연결 장애를 체계적으로 진단하는 도구(Flow Logs·Reachability Analyzer)와 절차에 집중합니다. VPC 구성 기초는 `soa-t5-1`을 참고하세요.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명하고, 콘솔/CLI에서 직접 진단할 수 있어야 합니다.

- [ ] **VPC Flow Logs** — VPC/서브넷/ENI 레벨로 캡처하고 대상(CloudWatch Logs/S3)을 고를 수 있다
- [ ] **Flow Log 레코드 필드** — srcaddr/dstaddr/srcport/dstport/action(ACCEPT·REJECT) 을 해석할 수 있다
- [ ] **SG vs NACL의 로그 가시성** — SG 거부는 Flow Log에 안 보이고, NACL 거부는 보이는 뉘앙스를 안다
- [ ] **Reachability Analyzer** — 소스→대상 경로를 분석하고 차단 구성요소를 찾을 수 있다
- [ ] **Network Access Analyzer** — 의도치 않은 접근 경로를 식별하는 용도를 안다
- [ ] **체계적 진단 순서** — SG → NACL → 라우팅 → IGW/NAT → DNS 순서로 좁혀갈 수 있다
- [ ] **운영** — REJECT 로그로 차단 지점을 추적하는 절차를 수행할 수 있다

---

## 🎯 왜 중요한가

- Task 5.3은 SOA에서 가장 "운영자다운" 영역입니다. 시험은 "왜 연결이 안 되는가"를 주고, **어떤 도구로 어떤 순서로** 원인을 좁히는지를 묻습니다. 단순 암기가 아니라 **진단 절차**가 핵심입니다.
- **Flow Logs의 ACCEPT/REJECT 해석**, 특히 **SG 거부는 로그에 안 보이고 NACL 거부는 보인다**는 뉘앙스는 실무·시험 모두에서 결정적입니다. 이 차이를 알면 "REJECT가 안 찍히는데 연결은 안 된다 → SG 의심"처럼 추론할 수 있습니다.
- **Reachability Analyzer**는 실제 트래픽 없이도 경로 도달성을 정적 분석해 **차단 구성요소(어느 SG/NACL/라우팅)** 를 콕 집어줍니다. 운영자가 빠르게 원인을 찾는 도구로 출제됩니다.

---

## 🔤 먼저 알아야 할 용어

이 문서를 읽는 데 필요한 기초 용어입니다. 이미 알면 건너뛰세요.

| 용어 | 영문 | 한 줄 풀이 |
|---|---|---|
| **탄력적 네트워크 인터페이스** | ENI (Elastic Network Interface) | VPC 안의 가상 네트워크 카드로, Flow Logs 캡처와 진단의 최소 단위 |
| **이페머럴 포트** | Ephemeral Port | 클라이언트가 응답을 받기 위해 OS가 임시로 여는 높은 번호 포트(1024–65535 범위) |
| **트래픽 미러링** | Traffic Mirroring | ENI 트래픽의 실제 패킷을 복사해 분석 도구로 전달하는 기능 |
| **CIDR** | Classless Inter-Domain Routing | IP 주소 범위를 표기하는 방식(예: 10.0.0.0/16) — 라우팅 테이블 경로 단위 |
| **인터넷 게이트웨이** | IGW (Internet Gateway) | VPC에서 인터넷으로 나가거나 들어오는 관문 역할을 하는 VPC 구성 요소 |

---

## 📖 핵심 개념

### 1) VPC Flow Logs — 트래픽 메타데이터 캡처

> 공식 정의: **"VPC의 네트워크 인터페이스로 오가는 IP 트래픽 정보를 캡처하는 기능."** 패킷 내용이 아니라 **메타데이터(누가, 어디로, 허용/거부)** 를 기록합니다.

**캡처 레벨(범위):**

| 레벨 | 적용 범위 |
|---|---|
| **VPC 레벨** | 해당 VPC의 모든 ENI 트래픽 |
| **서브넷 레벨** | 해당 서브넷의 모든 ENI 트래픽 |
| **ENI(네트워크 인터페이스) 레벨** | 특정 인터페이스만 |

**대상(저장 위치):**

| 대상 | 용도 |
|---|---|
| **CloudWatch Logs** | 실시간 조회·Logs Insights 쿼리·경보 연동 |
| **S3** | 저비용 장기 보관·Athena 분석 |
| **Kinesis Data Firehose** | 스트리밍 파이프라인으로 전달 |

> Flow Logs는 **나중에 켜는 진단 도구**가 아니라 평소에 켜 두면 사고 시점의 트래픽을 되짚을 수 있습니다. 기존 트래픽을 소급 캡처하지는 못하므로 **사전 활성화**가 운영 정석입니다.

> 🧠 원리: Flow Logs는 패킷 내용 대신 메타데이터만 기록하는데, 이것으로 연결 진단이 가능한 이유는 무엇일까요?
> 연결 실패 대부분은 패킷 내용이 아니라 경로 어딘가에서 허용 여부가 결정되는 문제이므로, 누가 어디로 보냈고 허용됐는지(action)를 기록하면 차단 지점을 찾을 수 있습니다.
> 패킷 전체를 저장하면 용량과 비용이 급증하고 민감한 내용이 포함될 수 있어, 운영 환경에서 상시 켜두기 어려워집니다.
> 메타데이터만 경량 기록하는 구조 덕분에 VPC·서브넷·ENI 레벨 모두에서 평소에 켜 두고 사고 시점을 소급 조회하는 운영 방식이 현실적으로 가능합니다.

### 2) Flow Log 레코드 필드 해석 (★ 핵심)

기본 형식의 주요 필드:

| 필드 | 의미 |
|---|---|
| **srcaddr / dstaddr** | 출발지 / 목적지 IP |
| **srcport / dstport** | 출발지 / 목적지 포트 |
| **protocol** | 프로토콜 번호(6=TCP, 17=UDP, 1=ICMP) |
| **packets / bytes** | 전송된 패킷 수 / 바이트 |
| **action** | **ACCEPT**(허용됨) / **REJECT**(거부됨) |
| **log-status** | OK / NODATA / SKIPDATA |

```
# Flow Log 레코드 예시 (action 끝 필드에 주목)
2 123456789012 eni-abc 10.0.1.5 10.0.2.9 443 51514 6 10 840 ... ACCEPT OK
2 123456789012 eni-abc 203.0.113.7 10.0.1.5 39812 22 6 1 40 ... REJECT OK
```

- **ACCEPT** = SG와 NACL을 모두 통과한 트래픽.
- **REJECT** = **NACL에 의해 거부된** 트래픽(또는 SG 미일치로 응답이 끊긴 상황의 흔적).

> 🧠 원리: action 필드가 ACCEPT와 REJECT 두 값만 갖는 구조는 어떤 운영상 판단을 가능하게 할까요?
> 모든 흐름을 허용/거부로 이분하면 필터 하나(`action = "REJECT"`)로 전체 차단 이벤트를 즉시 조회할 수 있어, 대용량 로그에서 문제가 된 흐름만 추출하는 쿼리 비용이 낮아집니다.
> dstPort 조건을 함께 걸면 "특정 포트에 대한 차단만"처럼 좁은 범위로 드릴다운할 수 있어, 운영자가 수백만 건 로그에서 단서를 찾는 시간을 단축할 수 있습니다.
> 이 단순한 필드 구조 덕분에 Logs Insights처럼 인터랙티브 쿼리 도구와 결합해 사고 타임라인을 빠르게 재구성할 수 있습니다.

### 3) SG vs NACL의 로그 가시성 (★ 결정적 뉘앙스)

> **보안 그룹(stateful) 거부는 Flow Log에 REJECT로 잘 드러나지 않습니다.** SG는 상태를 추적해 "허용된 연결의 응답"을 자동 통과시키고, 허용되지 않은 인바운드는 조용히 버립니다. 반면 **네트워크 ACL(stateless) 거부는 REJECT로 명확히 기록**됩니다.

| 상황 | Flow Log에 보이는 것 |
|---|---|
| NACL이 명시적/암묵적으로 거부 | **REJECT** (차단 지점 추적 가능) |
| SG가 인바운드 미허용으로 차단 | REJECT로 잘 안 보임(연결이 성립 안 됨) |
| SG·NACL 모두 통과 | **ACCEPT** |

> **추론 패턴:** "연결이 안 되는데 Flow Log에 REJECT가 안 찍힌다" → **NACL은 통과했고 SG에서 막혔을** 가능성이 큽니다. "REJECT가 찍힌다" → **NACL 규칙(또는 이페머럴 포트 누락)** 을 의심합니다. SG는 stateful이라 응답 포트 문제는 없지만, NACL은 stateless라 응답용 이페머럴 포트가 막혀 REJECT가 날 수 있습니다.

> 🧠 원리: SG와 NACL이 같은 인바운드를 차단해도 로그 흔적이 다른 이유는 무엇일까요?
> SG는 ENI 이후 계층에서 연결 상태를 추적해 허용 목록에 없는 패킷을 조용히 폐기하는데, 이 폐기가 트래픽 흐름 레코드에 REJECT로 잘 드러나지 않는 경우가 많습니다.
> NACL은 각 패킷을 독립적으로 규칙과 대조하며, 거부 규칙에 매칭되면 명시적 거부가 발생해 Flow Log에 REJECT로 기록됩니다.
> 이 차이를 알면 로그의 REJECT 유무로 차단 계층을 추론할 수 있어, 도구 없이도 첫 번째 진단 가설을 빠르게 세울 수 있습니다.

### 4) Reachability Analyzer — 정적 경로 도달성 분석

> 공식 정의: **"네트워크 구성을 분석해 소스와 대상 리소스 간 네트워크 도달 가능성을 점검하는 구성 분석 도구."** 실제 패킷을 보내지 않고 **구성만으로** 경로를 평가합니다.

- **소스 → 대상**(예: EC2 → EC2, IGW → EC2 등)을 지정하면 도달 가능 여부를 반환합니다.
- **도달 불가**일 때, **어느 구성요소가 차단했는지**(특정 SG, NACL, 라우팅 테이블 누락 등)를 알려줍니다.
- 트래픽을 발생시키지 않으므로 운영 중인 환경에서도 안전하게 진단할 수 있습니다.

> **운영 핵심:** "EC2-A에서 EC2-B로 SSH가 안 된다"를 Reachability Analyzer로 경로 분석하면, "NACL이 22 포트를 막음" 또는 "라우팅 경로 없음"처럼 **차단 지점을 즉시 지목**합니다. Flow Logs가 *무슨 일이 일어났는지*를 보여준다면, Reachability Analyzer는 *구성상 도달 가능한지*를 보여줍니다.

> 🧠 원리: Reachability Analyzer가 실제 패킷을 보내지 않고도 차단 지점을 지목할 수 있는 이유는 무엇일까요?
> VPC의 네트워크 경로는 SG 규칙, NACL 규칙, 라우팅 테이블 항목 같은 구성 데이터의 조합으로 완전히 결정되며, 이 데이터는 API를 통해 읽을 수 있습니다.
> Reachability Analyzer는 이 구성 스냅샷을 그래프로 모델링해 소스에서 대상까지 경로를 탐색하면서 각 홉에서 통과 조건을 평가합니다.
> 트래픽 없이 구성만으로 분석하므로 운영 중인 시스템에 영향 없이 반복 실행할 수 있고, 구성 변경이 경로에 미치는 영향을 배포 전에 검증하는 데도 활용됩니다.

### 5) Network Access Analyzer — 의도치 않은 접근 경로 탐지

> 공식 정의: 네트워크 구성을 분석해 **의도하지 않은 네트워크 접근 경로**를 식별하는 도구.

- "인터넷에서 데이터베이스 서브넷에 도달 가능한 경로가 있는가?"처럼 **보안 의도 위반**을 찾습니다.
- 컴플라이언스·보안 점검 용도. (도달성 단건 진단은 Reachability Analyzer, 광범위 접근 경로 감사는 Network Access Analyzer로 구분)

> 🧠 원리: Network Access Analyzer가 "단건 도달성"이 아니라 "광범위 접근 경로 감사"에 쓰이는 이유는 무엇일까요?
> 컴플라이언스 점검은 "이 특정 EC2가 저 DB에 닿는가"가 아니라 "인터넷에서 데이터베이스 계층에 닿는 경로가 하나라도 존재하는가"처럼 범위가 열린 질문을 다룹니다.
> Network Access Analyzer는 접근 범위 네트워크(Network Access Scope)를 정의하면 VPC 전체 구성을 스캔해 정책 위반 경로를 모두 열거하므로, 운영자가 알지 못하는 열린 경로까지 발견할 수 있습니다.
> 이 광범위 스캔 모델은 정기 감사나 아키텍처 변경 후 의도치 않은 접근 경로가 생겼는지 확인하는 용도에 맞으며, 특정 소스-대상 쌍을 진단하는 Reachability Analyzer와 목적이 구별됩니다.

### 6) 체계적 연결 진단 순서 (★ 운영 절차)

연결이 안 될 때, 트래픽 경로를 따라 **계층별로** 좁혀갑니다.

```
1. 보안 그룹(SG)      — 인스턴스 인바운드/아웃바운드에 해당 포트·소스가 허용?
2. 네트워크 ACL(NACL) — 서브넷 인/아웃 + 응답용 이페머럴 포트 허용? (stateless 주의)
3. 라우팅 테이블       — 대상 CIDR로 가는 경로(local/igw/nat/peering/tgw)가 있는가?
4. IGW / NAT          — 퍼블릭은 IGW+퍼블릭IP, 프라이빗 아웃바운드는 NAT 경로?
5. DNS                — 이름 해석 실패? enableDnsSupport/Hostnames, 프라이빗 호스팅 영역
```

- **도구 매핑:** 빠른 도달성 판정은 **Reachability Analyzer**, 실제 트래픽 흔적·REJECT 추적은 **Flow Logs(CloudWatch Logs Insights)** 로 확인합니다.
- **REJECT 추적 절차:** Flow Logs에서 `action=REJECT` + 해당 dstport로 필터 → 어느 ENI/서브넷에서 거부되는지 확인 → 그 서브넷 NACL 규칙(특히 이페머럴 포트) 점검 → REJECT가 없는데도 실패하면 SG 인바운드를 의심.

```
# CloudWatch Logs Insights — 특정 포트의 REJECT 추적
fields @timestamp, srcAddr, dstAddr, dstPort, action
| filter action = "REJECT" and dstPort = 443
| sort @timestamp desc
| limit 50
```

> 🧠 원리: 왜 연결 진단은 라우팅이나 DNS 같은 상위 계층이 아니라 SG부터 시작하는 것이 효율적일까요?
> SG는 인스턴스에 가장 가까운 계층이므로 잘못된 SG 규칙이 있으면 라우팅이 아무리 올바르게 설정돼 있어도 패킷이 인스턴스에 도달하지 않습니다.
> 바깥 계층(라우팅·IGW)부터 점검하면 정상인 계층을 여러 개 통과한 뒤에야 실제 문제를 찾게 되어 진단 경로가 길어집니다.
> 인스턴스에 가까운 계층을 먼저 확인하고 범위를 바깥으로 넓히면, 대부분 흔한 SG·NACL 구성 오류에서 일찍 멈추고 불필요한 라우팅·DNS 점검을 건너뛸 수 있습니다.

---

## ✍️ 시험 포인트

- **Flow Logs = 트래픽 메타데이터**(패킷 내용 아님). 레벨: **VPC / 서브넷 / ENI**. 대상: **CloudWatch Logs / S3 / Firehose**.
- **action 필드 = ACCEPT / REJECT.** REJECT로 **차단 지점 추적**.
- **SG 거부는 Flow Log에 잘 안 보이고(REJECT 없음), NACL 거부는 REJECT로 보인다.** → REJECT 부재 + 연결 실패 = **SG 의심**.
- **SG = stateful**(응답 자동 허용), **NACL = stateless**(이페머럴 포트 별도) — 로그 해석의 핵심.
- **Reachability Analyzer = 구성 기반 정적 도달성 분석**(트래픽 안 보냄), **차단 구성요소 지목**.
- **Network Access Analyzer = 의도치 않은 접근 경로 감사**(보안·컴플라이언스).
- **진단 순서: SG → NACL → 라우팅 → IGW/NAT → DNS.**
- **Flow Logs는 사전 활성화 필요**(소급 캡처 불가).

---

## ⚠️ 흔한 함정

1. **"Flow Logs가 패킷 내용(페이로드)을 보여준다."** → 아닙니다. Flow Logs는 **메타데이터**(src/dst IP·포트·프로토콜·action 등)만 기록합니다. 패킷 내용 캡처는 **Traffic Mirroring** 이 필요합니다.
   *(원리: §1 — 메타데이터만 경량 기록해야 상시 활성화가 현실적이고 민감 데이터 노출 없이 진단이 가능하다.)*

2. **"연결이 안 되면 무조건 Flow Log에 REJECT가 찍힌다."** → **보안 그룹 거부는 REJECT로 잘 드러나지 않습니다**(SG는 stateful이라 미허용 인바운드를 조용히 버림). REJECT가 없는데 연결이 안 되면 **SG 인바운드**를 먼저 의심해야 합니다. NACL 거부라면 REJECT가 찍힙니다.
   *(원리: §3 — SG는 패킷을 조용히 폐기해 REJECT가 잘 드러나지 않고, NACL은 명시적 거부로 REJECT를 남긴다.)*

3. **"NACL은 인바운드만 열면 된다."** → NACL은 **stateless**라 응답이 나가는 **이페머럴 포트(1024–65535)** 의 반대 방향 규칙이 없으면 응답이 막혀 REJECT가 발생합니다. SG는 stateful이라 이 문제가 없습니다.
   *(원리: §3 본문 — stateless는 요청·응답을 독립 평가하므로 양방향 규칙이 없으면 응답 방향에서 REJECT가 발생한다.)*

4. **"Reachability Analyzer가 실제 트래픽을 보내 테스트한다."** → 보내지 않습니다. **구성(SG·NACL·라우팅 등)만으로 정적 분석**합니다. 그래서 운영 중에도 안전하고, 차단 구성요소를 지목해 줍니다.
   *(원리: §4 — VPC 경로는 구성 데이터로 완전히 결정되므로 패킷 없이 그래프 탐색으로 차단 지점을 찾을 수 있다.)*

5. **"Flow Logs를 사고 후에 켜면 그 시점 트래픽을 볼 수 있다."** → Flow Logs는 **켠 이후의 트래픽만** 기록합니다. 소급 캡처가 안 되므로 **평소에 켜 두는** 것이 운영 정석입니다.
   *(원리: §1 본문 — 기존 트래픽 소급 캡처 불가이므로 사고 시점 조회를 위해 사전 활성화가 필요하다.)*

6. **"진단은 라우팅부터 본다."** → 정해진 순서는 없지만, 인스턴스에 가까운 **SG → NACL → 라우팅 → IGW/NAT → DNS** 순으로 계층을 따라 좁히는 것이 효율적입니다. 도구로는 도달성은 Reachability Analyzer, 흔적은 Flow Logs.
   *(원리: §6 — 인스턴스에 가까운 계층을 먼저 확인하면 흔한 SG·NACL 오류에서 일찍 멈추고 불필요한 점검을 줄인다.)*

7. **"Network Access Analyzer와 Reachability Analyzer는 같은 도구다."** → 다릅니다. **Reachability Analyzer**는 소스→대상 **단건 도달성** 진단, **Network Access Analyzer**는 **의도치 않은 접근 경로 광범위 감사**(보안)입니다.
   *(원리: §5 — Network Access Analyzer는 범위가 열린 스캔으로 정책 위반 경로를 열거하고, Reachability Analyzer는 특정 쌍의 도달성을 진단한다.)*

---

## 🧪 자가 점검

> 아래는 학습용 자가 점검입니다. (정식 검증 문항은 별도 문항 파일 참조)

**Q1.** EC2-A에서 EC2-B의 443 포트로 접속이 안 됩니다. Flow Logs를 보니 해당 트래픽에 대한 **REJECT 레코드가 보이지 않습니다.** 어디를 의심해야 하나요?

<details><summary>정답 보기</summary>

**보안 그룹(SG)** 을 먼저 의심합니다. SG는 stateful이라 허용되지 않은 인바운드를 **조용히 버리며 REJECT 로그를 남기지 않습니다.** NACL이 거부했다면 REJECT가 찍혔을 것입니다. 따라서 REJECT 부재 + 연결 실패 = EC2-B의 SG 인바운드에 443/EC2-A 소스가 허용되어 있는지, 또는 EC2-A의 SG 아웃바운드가 443을 허용하는지를 점검합니다.
</details>

**Q2.** 어떤 서브넷의 웹 서버로 들어오는 요청에 대해 Flow Logs에 인바운드 443은 ACCEPT인데, 응답 트래픽이 **REJECT** 로 찍힙니다. 원인은?

<details><summary>정답 보기</summary>

서브넷 **NACL이 stateless** 이기 때문입니다. 요청(인바운드 443)은 허용됐지만, 서버 응답이 나가는 **이페머럴 포트(아웃바운드 1024–65535)** 가 NACL에 허용되지 않아 REJECT가 발생합니다. NACL 아웃바운드(또는 응답 방향)에 이페머럴 포트 범위 허용 규칙을 추가하면 해결됩니다. 보안 그룹만 썼다면 stateful이라 이 문제가 없었을 것입니다.
</details>

**Q3.** 운영 중인 환경에서 "배스천에서 DB 인스턴스로 도달 가능한지"를 트래픽을 발생시키지 않고 안전하게 확인하고, 막혔다면 어느 구성요소가 원인인지 알고 싶습니다. 어떤 도구를 쓰나요?

<details><summary>정답 보기</summary>

**Reachability Analyzer**를 사용합니다. 소스(배스천)와 대상(DB 인스턴스)을 지정하면 실제 패킷 없이 **구성만으로 도달 가능 여부**를 분석하고, 도달 불가라면 **차단한 구성요소**(특정 SG, NACL, 누락된 라우팅 등)를 지목합니다. 실제 트래픽 흔적이나 시간대별 REJECT 추적이 필요하면 Flow Logs를 병행합니다.
</details>

**Q4.** 프라이빗 서브넷 인스턴스가 인터넷에 못 나갑니다. 어떤 순서로 진단하나요?

<details><summary>정답 보기</summary>

계층을 따라 좁힙니다. ① **SG** 아웃바운드가 대상 포트(예: 443)를 허용하는가, ② **NACL** 이 아웃바운드와 응답용 이페머럴 포트를 허용하는가, ③ 프라이빗 서브넷 **라우팅 테이블**에 `0.0.0.0/0 → NAT` 경로가 있는가, ④ **NAT Gateway** 가 퍼블릭 서브넷에 있고 그 서브넷이 `0.0.0.0/0 → IGW`를 갖는가(+EIP), ⑤ 이름 해석 실패면 **DNS**(enableDnsSupport 등). 빠른 판정은 Reachability Analyzer, REJECT 흔적은 Flow Logs로 확인합니다.
</details>

**Q5 (원리).** 왜 NACL의 이페머럴 포트 누락은 SG만 사용할 때는 문제가 되지 않지만, NACL을 추가하는 순간 응답 차단을 유발하나요?

<details><summary>정답 보기</summary>

SG는 stateful이라 허용한 인바운드 연결의 응답 트래픽을 상태 테이블로 추적해 아웃바운드 규칙 검사 없이 자동 통과시킵니다. 반면 NACL은 stateless라 인바운드 요청을 허용해도 응답이 나가는 아웃바운드 이페머럴 포트에 별도 허용 규칙이 없으면 응답이 차단되고 REJECT가 기록됩니다. 따라서 SG만 사용하던 서브넷에 NACL을 추가할 때 이페머럴 포트 아웃바운드 규칙을 빠뜨리면, SG는 통과해도 NACL에서 응답이 막히는 단방향 연결 장애가 생깁니다.
</details>

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 AWS 자료를 기준으로 작성했습니다. (작성·대조: 2026-06-09 · 고도화 검수: 2026-06-12)

1. VPC 흐름 로그 — https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html
2. 흐름 로그 레코드(필드) — https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs-records-examples.html
3. Reachability Analyzer란 무엇인가 — https://docs.aws.amazon.com/vpc/latest/reachability/what-is-reachability-analyzer.html
4. Network Access Analyzer란 무엇인가 — https://docs.aws.amazon.com/vpc/latest/network-access-analyzer/what-is-network-access-analyzer.html
5. 보안 그룹과 네트워크 ACL 비교(인프라 보안) — https://docs.aws.amazon.com/vpc/latest/userguide/infrastructure-security.html
