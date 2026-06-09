---
examGuideTaskId: soa-t2-2
certCode: SOA-C03
domain: 2
domainName: 신뢰성 및 비즈니스 연속성
domainWeightPct: 22
title: Multi-AZ·고가용성·복원력 설계
coversTasks:
  - "2.2"
sources:
  - title: 신뢰성 기둥 — AWS Well-Architected Framework (공식)
    url: https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/welcome.html
  - title: RDS Multi-AZ 배포 구성 및 관리 (공식)
    url: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.MultiAZ.html
  - title: RDS 읽기 전용 복제본 작업 (공식)
    url: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_ReadRepl.html
  - title: NAT 게이트웨이 — 고가용성 구성 (공식)
    url: https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html
  - title: Route 53 DNS 장애 조치 구성 (공식)
    url: https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/dns-failover.html
lastVerified: 2026-06-09
---

# Multi-AZ·고가용성·복원력 설계

> **커버하는 공식 Task** — SOA-C03 · 도메인 2 「신뢰성 및 비즈니스 연속성」(22%) · **Task 2.2 가용성과 복원력이 뛰어난 환경 구현** (`soa-t2-2`)
> 이 문서는 단일 리전 내 Multi-AZ 고가용성과 단일 실패점(SPOF) 제거에 집중합니다. 자동 확장은 `soa-t2-1`, 리전 단위 DR은 `soa-t2-4`에서 다룹니다.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명하고, 콘솔/CLI에서 직접 구성·점검할 수 있어야 합니다.

- [ ] **Multi-AZ 개념** — AZ가 물리적으로 분리된 장애 격리 단위임을 이해하고 다중 AZ 분산 원칙을 안다
- [ ] **RDS Multi-AZ 동작** — 동기 복제·자동 장애 조치·스탠바이 읽기 불가를 정확히 설명할 수 있다
- [ ] **Multi-AZ vs 읽기 전용 복제본** — 가용성 vs 읽기 확장의 목적 차이를 구분할 수 있다
- [ ] **ELB+다중 AZ** — LB가 여러 AZ의 정상 대상에만 트래픽을 보내는 자가 격리를 안다
- [ ] **NAT Gateway 이중화** — AZ별 NAT 게이트웨이 배치가 왜 필요한지 설명할 수 있다
- [ ] **Route 53 장애 조치** — 헬스 체크 기반 Active-Passive DNS 페일오버를 구성할 수 있다
- [ ] **SPOF 제거 원칙** — 각 계층의 단일 실패점을 식별하고 이중화 방법을 적용할 수 있다
- [ ] **무상태 설계** — 세션 외부화로 인스턴스 교체에도 살아남는 구조를 안다

---

## 🎯 왜 중요한가

- 도메인 2(22%)의 Task 2.2는 "highly available", "resilient", "AZ 장애에도 서비스 유지" 같은 운영 시나리오와 직결됩니다.
- SOA는 설계보다 **운영 점검**을 묻습니다. "AZ 하나가 다운돼도 살아남는가?"를 각 계층(컴퓨트·DB·네트워크·DNS)에서 검증하는 능력이 핵심입니다.
- CLF/SAA에서 Multi-AZ를 개념으로 봤다면, SOA는 **RDS Multi-AZ와 읽기 복제본의 차이**, **NAT 게이트웨이 AZ별 이중화**, **세션 외부화** 같은 운영 실수 지점을 직접 점검하도록 요구합니다.

---

## 📖 핵심 개념

### 1) Multi-AZ란 — 장애 격리 단위

> 가용 영역(AZ)은 한 리전 내에서 전력·냉각·네트워크가 **물리적으로 분리**된 하나 이상의 데이터센터입니다. AZ는 서로 의미 있는 거리만큼 떨어져 있어, 한 AZ의 장애가 다른 AZ로 전파되지 않도록 설계됩니다.

- **원칙**: 모든 계층의 리소스를 **최소 2개 AZ**에 분산해야 단일 AZ 장애에서 생존합니다.
- AWS Well-Architected 신뢰성 기둥은 "이중화를 통한 단일 실패점 제거"를 복원력 핵심 원칙으로 명시합니다.

### 2) RDS Multi-AZ 동작 원리 (★ 시험 핵심)

> 공식: **"Amazon RDS는 다른 AZ에 동기식 스탠바이 복제본을 자동으로 프로비저닝·유지한다."**

```
앱 → RDS 엔드포인트(DNS)
        │
   Primary DB (AZ-a)
        │ 동기 복제(쓰기가 양쪽에 커밋돼야 응답)
   Standby DB (AZ-b)  ← 읽기 불가, 대기만
```

**자동 장애 조치(Failover):**

```
Primary 장애 감지 → AWS가 Standby를 Primary로 자동 승격
→ RDS 엔드포인트(DNS)가 새 Primary로 전환 → 앱은 동일 엔드포인트로 재연결
```

| 특성 | 내용 |
|---|---|
| **복제 방식** | 동기(Synchronous) — 데이터 유실 없음 |
| **장애 조치** | 자동(수동 개입 불필요), 일반적으로 1~2분 이내 |
| **스탠바이 읽기** | **불가** — 오직 가용성 목적 |
| **엔드포인트** | 장애 조치 후에도 **동일 DNS 엔드포인트** 유지 |

> Multi-AZ DB **클러스터** 배포(2개의 읽기 가능 스탠바이)는 예외적으로 스탠바이가 읽기를 제공하지만, 전통적 Multi-AZ **인스턴스** 배포의 단일 스탠바이는 읽기 불가입니다. 시험 기본값은 후자입니다.

### 3) Multi-AZ vs 읽기 전용 복제본 (★ 필출 비교)

| 항목 | RDS Multi-AZ | 읽기 전용 복제본(Read Replica) |
|---|---|---|
| **목적** | 고가용성·자동 장애 조치 | 읽기 확장(읽기 처리량 증가) |
| **복제 방식** | 동기(Synchronous) | 비동기(Asynchronous) |
| **읽기 트래픽** | 스탠바이 읽기 **불가** | 읽기 **가능**(별도 엔드포인트) |
| **장애 조치** | 자동 | **수동 승격** 필요 |
| **리전** | 동일 리전 내 다른 AZ | 동일 또는 **다른 리전** |
| **데이터 유실** | 없음 | 비동기 지연만큼 가능 |

> **함정**: "읽기 복제본이 가용성을 높인다"는 틀립니다. 읽기 복제본은 읽기 확장 기능이며 자동 장애 조치가 없습니다. 가용성이 목적이면 Multi-AZ를 선택합니다. (둘을 함께 쓰는 것도 가능)

### 4) ELB + 다중 AZ

- ELB는 내부적으로 **여러 AZ에 노드를 이중화**합니다(ELB 자체가 SPOF가 아님).
- 대상 그룹 상태 확인으로 **정상 대상에만** 트래픽을 보내며, 한 AZ의 대상이 모두 비정상이면 해당 AZ를 우회합니다.
- ASG를 다중 AZ로 구성(=`soa-t2-1`)하면, AZ 장애 시 ELB가 살아있는 AZ로 트래픽을 보내고 ASG가 부족분을 다른 AZ에서 보충합니다.

### 5) NAT Gateway AZ별 이중화

> NAT 게이트웨이는 **AZ 단위 리소스**입니다. 특정 AZ의 퍼블릭 서브넷에 배치됩니다.

```
[잘못된 구성]  모든 프라이빗 서브넷 → NAT(AZ-a) 1개
  → AZ-a 장애 시 AZ-b 프라이빗 서브넷도 인터넷 불가(SPOF)

[올바른 구성]  AZ마다 NAT 게이트웨이 1개 + 각 AZ 프라이빗 라우팅 테이블이
              같은 AZ NAT를 가리킴
  → 한 AZ 장애가 다른 AZ 아웃바운드에 영향 없음
```

> **운영 점검**: 프라이빗 서브넷의 라우팅 테이블이 **자기 AZ의 NAT**를 가리키는지 확인합니다. 모든 AZ가 한 NAT를 공유하면 그 AZ가 SPOF이자 AZ 간 데이터 전송 비용도 발생합니다.

### 6) Route 53 장애 조치(Failover) 라우팅 + 헬스 체크

- **헬스 체크**: 지정 엔드포인트(IP/도메인)에 HTTP/HTTPS/TCP 요청을 주기 전송, CloudWatch 경보 기반 판정도 가능.
- **Active-Passive 장애 조치 라우팅**:

```
Route 53 장애 조치 레코드
  Primary 레코드(헬스 체크 연결) → 기본 리소스
  Secondary 레코드 → 대기 리소스(Primary 비정상 시 응답 전환)
```

- Primary 비정상 시 Route 53이 자동으로 Secondary로 DNS 응답을 전환. 앱 코드 변경 불필요.
- **유의**: DNS TTL만큼 전파 지연이 있습니다(즉각적이지 않음).

### 7) SPOF 제거 원칙 — 계층별 점검표

| 계층 | SPOF | 제거 방법 |
|---|---|---|
| 컴퓨트 | 단일 EC2 / 단일 AZ ASG | ASG + 최소 2개 AZ 분산 |
| 부하 분산 | 단일 LB 노드 | ELB 내부 다중 AZ 이중화(자동) |
| 데이터베이스 | 단일 RDS 인스턴스 | RDS Multi-AZ(동기 스탠바이+자동 장애 조치) |
| 아웃바운드 | 단일 NAT 게이트웨이 | AZ마다 NAT 게이트웨이 배치 |
| DNS/진입 | 단일 엔드포인트 | Route 53 헬스 체크 + 장애 조치 라우팅 |
| 세션 상태 | EC2 로컬 세션 | ElastiCache/DynamoDB로 외부화 |

### 8) 무상태(Stateless) 설계 — 세션 외부화

ASG는 인스턴스를 수시로 생성·교체합니다. EC2 로컬에 세션을 저장하면 교체 시 세션이 사라집니다.

```
EC2(무상태, 언제든 교체 가능)
        ↓
ElastiCache(Redis) / DynamoDB  ← 세션·상태 저장
```

- **ElastiCache Redis**: 저지연 인메모리 세션·캐시.
- **DynamoDB**: 내구성 있는 세션 테이블.

---

## ✍️ 시험 포인트

| 시나리오 문구 | 정답 방향 |
|---|---|
| "automatic failover for database" | **RDS Multi-AZ**(읽기 복제본 아님) |
| "scale read traffic" | **읽기 전용 복제본**(Multi-AZ 아님) |
| "AZ 장애에도 아웃바운드 유지" | **AZ별 NAT 게이트웨이** 이중화 |
| "DNS 레벨 자동 페일오버" | **Route 53 헬스 체크 + 장애 조치 라우팅** |
| "EC2 자동 복구·교체" | **ASG 헬스 체크**(self-healing) |
| "세션 저장 위치(ASG 환경)" | **ElastiCache Redis 또는 DynamoDB** |
| "highly available 웹" | ALB + 다중 AZ ASG + RDS Multi-AZ |

- **RDS Multi-AZ = 동기·자동 장애 조치·스탠바이 읽기 불가·동일 엔드포인트**. 4가지를 함께 외우세요.
- **읽기 복제본 = 비동기·읽기 가능·수동 승격·교차 리전 가능**.
- **NAT는 AZ 단위 리소스** → AZ마다 1개, 라우팅 테이블이 자기 AZ NAT를 가리켜야 함.
- **Route 53 페일오버는 DNS TTL 전파 지연**이 있음.

---

## ⚠️ 흔한 함정

1. **"RDS Multi-AZ가 읽기 성능도 높여준다."** → 틀립니다. 단일 스탠바이는 읽기를 처리하지 않습니다(가용성 전용). 읽기 확장은 읽기 전용 복제본을 추가합니다.

2. **"읽기 복제본은 자동으로 장애 조치된다."** → 읽기 복제본은 자동 장애 조치가 없습니다. **수동 승격(promote)**이 필요합니다. 자동 장애 조치는 Multi-AZ의 기능입니다.

3. **"NAT 게이트웨이 1개로 전체 VPC를 커버하면 된다."** → NAT가 있는 AZ가 장애 나면 다른 AZ 프라이빗 서브넷이 인터넷에 못 나갑니다(SPOF). AZ마다 NAT를 배치하고 라우팅을 같은 AZ로 향하게 합니다.

4. **"Multi-AZ가 부하를 분산한다."** → 부하 분산은 ELB의 역할입니다. Multi-AZ는 가용성을 위한 이중화이지 트래픽 분산이 아닙니다.

5. **"EC2에 세션을 저장해도 ASG 환경에서 괜찮다."** → ASG가 인스턴스를 교체하면 로컬 세션이 사라집니다. 세션은 ElastiCache/DynamoDB로 외부화해야 합니다.

6. **"Route 53 장애 조치는 즉각적이다."** → DNS TTL만큼 전파 지연이 있습니다. 더 빠른 전환이 필요하면 짧은 TTL이나 AWS Global Accelerator를 고려합니다.

7. **"단일 AZ ASG도 고가용성이다."** → 단일 AZ ASG는 그 AZ 장애 시 전멸합니다. 최소 2개 AZ에 분산해야 합니다.

---

## 🧪 자가 점검

> 아래는 학습용 자가 점검입니다. (정식 검증 문항은 별도 문항 파일 참조)

**Q1.** 데이터베이스에 "자동 장애 조치"가 필요합니다. 읽기 전용 복제본을 추가하면 충분한가요?

<details><summary>정답 보기</summary>

아닙니다. 읽기 전용 복제본은 **비동기 복제 + 수동 승격**이라 자동 장애 조치를 제공하지 않습니다. 자동 장애 조치가 필요하면 **RDS Multi-AZ**를 활성화해야 합니다. Multi-AZ는 다른 AZ에 동기 스탠바이를 유지하다가 Primary 장애 시 AWS가 자동으로 승격하고 DNS 엔드포인트를 전환합니다. 읽기 확장까지 필요하면 Multi-AZ와 읽기 복제본을 함께 사용합니다.
</details>

**Q2.** 프라이빗 서브넷의 인스턴스들이 외부 API를 호출하는데, AZ-a 장애 시 AZ-b의 인스턴스도 외부 호출이 끊깁니다. 원인과 해결책은?

<details><summary>정답 보기</summary>

모든 프라이빗 서브넷이 **AZ-a의 NAT 게이트웨이 하나만** 사용하도록 라우팅되어 있는 것이 원인입니다. NAT 게이트웨이는 AZ 단위 리소스이므로, **각 AZ에 NAT 게이트웨이를 배치**하고 각 AZ의 프라이빗 서브넷 라우팅 테이블이 **자기 AZ의 NAT**를 가리키도록 구성해야 합니다. 그러면 한 AZ 장애가 다른 AZ의 아웃바운드에 영향을 주지 않습니다.
</details>

**Q3.** RDS Multi-AZ를 사용 중인데 장애 조치 후에도 애플리케이션 연결 문자열을 바꿀 필요가 없습니다. 왜인가요?

<details><summary>정답 보기</summary>

RDS Multi-AZ는 장애 조치 시 스탠바이를 Primary로 승격하면서 **RDS 엔드포인트(DNS)를 새 Primary로 전환**합니다. 애플리케이션은 IP가 아니라 **동일한 DNS 엔드포인트**로 연결하므로, DNS가 새 인스턴스를 가리키게 되어 코드·연결 문자열 변경 없이 재연결됩니다. (앱은 연결 풀을 재설정하면 됩니다.)
</details>

**Q4.** 다음 중 단일 실패점(SPOF)이 아닌 것은?
(A) 단일 AZ에만 있는 ASG
(B) AZ마다 배치된 NAT 게이트웨이
(C) 단일 RDS 인스턴스(Multi-AZ 미사용)
(D) 모든 프라이빗 서브넷이 공유하는 NAT 게이트웨이 1개

<details><summary>정답 보기</summary>

**(B) AZ마다 배치된 NAT 게이트웨이**입니다. 각 AZ에 독립 배치되어 한 AZ 장애가 다른 AZ에 영향을 주지 않으므로 SPOF가 제거된 상태입니다. (A)는 그 AZ 장애 시 전멸, (C)는 DB가 SPOF, (D)는 공유 NAT가 있는 AZ 장애 시 전체 아웃바운드 중단으로 모두 SPOF입니다.
</details>

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 AWS 자료를 기준으로 작성했습니다. (작성·대조: 2026-06-09)

1. 신뢰성 기둥 — AWS Well-Architected Framework — https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/welcome.html
2. RDS Multi-AZ 배포 구성 및 관리 — https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.MultiAZ.html
3. RDS 읽기 전용 복제본 작업 — https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_ReadRepl.html
4. NAT 게이트웨이 — 고가용성 구성 — https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html
5. Route 53 DNS 장애 조치 구성 — https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/dns-failover.html
</content>
