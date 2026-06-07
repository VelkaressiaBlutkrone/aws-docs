---
examGuideTaskId: saa-t2-4
certCode: SAA-C03
domain: 2
domainName: 복원력을 갖춘 아키텍처 설계
domainWeightPct: 26
title: 고가용성 패턴 — Multi-AZ·단일 실패점 제거
coversTasks:
  - "2.2"
sources:
  - title: AWS Well-Architected Framework — Reliability Pillar (공식)
    url: https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/welcome.html
  - title: RDS Multi-AZ DB 인스턴스 배포 (공식)
    url: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.MultiAZSingleStandby.html
  - title: RDS Multi-AZ 배포 구성 및 관리 (공식)
    url: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.MultiAZ.html
  - title: Route 53 헬스 체크 생성 (공식)
    url: https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/dns-failover.html
  - title: SAA-C03 공식 시험 가이드 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
lastVerified: 2026-06-07
---

# 고가용성 패턴 — Multi-AZ·단일 실패점 제거

> **커버하는 공식 Task** — SAA-C03 · 도메인 2 「복원력을 갖춘 아키텍처 설계」(26%) · **Task 2.2 고가용성 및 내결함성 아키텍처 설계** (`saa-t2-4`)
> 이 문서는 위 한 Task에 1:1로 매핑됩니다. DR 4전략(RTO/RPO)은 `saa-t2-5`에서 다룹니다.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명할 수 있어야 합니다. (공식 시험 가이드 Task 2.2 기반)

- [ ] **HA vs 내결함성 vs DR** — 세 개념의 차이와 비용·복잡도 트레이드오프를 구분할 수 있다
- [ ] **단일 실패점(SPOF) 식별·제거** — 단일 EC2, 단일 AZ, 단일 RDS 각각의 제거 방법을 설명할 수 있다
- [ ] **표준 HA 구조** — Route 53 → ALB → Multi-AZ ASG → RDS Multi-AZ 흐름을 그릴 수 있다
- [ ] **RDS Multi-AZ 동작 원리** — 동기 복제·자동 페일오버·스탠바이가 읽기를 제공하지 않는다는 점을 안다
- [ ] **Multi-AZ vs 읽기 복제본** — 두 기능의 목적 차이(가용성 vs 읽기 확장)를 구분할 수 있다
- [ ] **Route 53 헬스 체크·페일오버** — Active-Passive DNS 페일오버 구성을 설명할 수 있다
- [ ] **정적 안정성(Static Stability)** — 장애 중에 동적 조달 없이 버티는 설계 원칙을 안다

---

## 🎯 왜 중요한가

도메인 2(26%)는 SAA에서 두 번째로 높은 비중입니다. 그 중 Task 2.2는 "highly available", "fault tolerant", "eliminate single point of failure" 같은 시나리오 문구와 직결됩니다.

시험은 설계 결정을 묻습니다. "어떤 서비스를 어떻게 조합하면 단일 AZ 장애 시에도 서비스가 유지되는가?" — 그 정답이 항상 이 문서의 조합(ALB + Multi-AZ ASG + RDS Multi-AZ)에서 나옵니다.

CLF에서 Multi-AZ를 개념으로만 봤다면, SAA는 **RDS Multi-AZ와 읽기 복제본의 차이**, **헬스 체크 기반 자동 전환 메커니즘**, **정적 안정성 원칙** 같은 설계 판단을 묻습니다.

---

## 📖 핵심 개념

### 1) HA·내결함성·DR — 세 개념 구분 (★ 시험 단골)

| 개념 | 목표 | 장애 시 동작 | 비용·복잡도 |
|---|---|---|---|
| **고가용성(HA)** | 다운타임 최소화·빠른 자동 복구 | 짧은 중단 후 자동 전환 (수 초~수 분) | 중간 |
| **내결함성(Fault Tolerance)** | 장애 중에도 **완전 무중단** 지속 | 능동 이중화로 중단 없이 계속 동작 | 높음 |
| **재해 복구(DR)** | 대규모·리전 단위 재해로부터 복구 | RTO/RPO 목표에 따라 복구 | 전략에 따라 다름 |

> **시험 문구 해석**: "highly available" → Multi-AZ + 자동 복구 조합으로 답합니다. "fault tolerant" → 더 강한 요건으로, 완전한 능동 이중화를 암시합니다. "DR"이 나오면 `saa-t2-5`의 4전략으로 답합니다.

---

### 2) 단일 실패점(SPOF)이란

**단일 실패점(Single Point of Failure)**은 그 하나가 장애를 일으키면 전체 시스템이 멈추는 구성 요소입니다.

전형적인 SPOF 예시와 제거 방법:

| SPOF | 제거 방법 |
|---|---|
| 단일 EC2 인스턴스 | Auto Scaling Group(ASG) + 다중 AZ 분산 |
| 단일 가용 영역(AZ) | 리소스를 최소 2개 AZ에 분산 배치 |
| 단일 RDS 인스턴스 | RDS Multi-AZ (자동 스탠바이 + 페일오버) |
| 단일 로드 밸런서 노드 | ELB는 내부적으로 다중 AZ 이중화 제공 |
| 단일 NAT 게이트웨이 | AZ마다 NAT 게이트웨이 1개씩 배치 |

> AWS Well-Architected Reliability Pillar는 "이중화를 통한 단일 실패점 제거"를 복원력 설계의 핵심 원칙으로 명시합니다.

---

### 3) 표준 HA 아키텍처

시험에서 "고가용성 웹 애플리케이션을 설계하라"는 문제의 정답 조합입니다.

```
사용자 요청
    │
Route 53 (헬스 체크 + 페일오버 라우팅)
    │
Application Load Balancer  ← 다중 AZ에 자동 이중화
    │           │
 EC2(AZ-a)  EC2(AZ-b)      ← Auto Scaling Group (다중 AZ)
    │           │
       RDS Multi-AZ
   Primary(AZ-a) ↔ Standby(AZ-b)  ← 동기 복제
```

각 레이어의 역할:

| 레이어 | 역할 | SPOF 제거 방법 |
|---|---|---|
| **Route 53** | DNS 라우팅 + 헬스 체크 | 엔드포인트 장애 시 다른 리소스로 자동 전환 |
| **ALB** | 트래픽 분산 + 헬스 체크 | 내부적으로 다중 AZ 이중화 |
| **ASG (다중 AZ)** | EC2 자동 생성·교체·분산 | 인스턴스 또는 AZ 장애 시 대체 인스턴스 시작 |
| **RDS Multi-AZ** | DB 자동 페일오버 | 주 인스턴스 장애 시 스탠바이로 DNS 전환 |

---

### 4) RDS Multi-AZ 동작 원리 (★ 시험 핵심)

> 공식 문서: "Amazon RDS는 다른 가용 영역에 동기식 스탠바이 복제본을 자동으로 프로비저닝·유지합니다." — AWS RDS 공식 문서

**작동 방식:**

```
애플리케이션 → RDS 엔드포인트(DNS)
                    │
              Primary DB (AZ-a)
              │  동기 복제 (쓰기 확인 후 완료)
              Standby DB (AZ-b)  ← 읽기 불가, 대기만
```

**자동 페일오버 시:**

```
Primary 장애 감지
    → AWS가 자동으로 Standby를 Primary로 승격
    → RDS 엔드포인트(DNS)가 새 Primary로 전환
    → 애플리케이션은 동일 엔드포인트로 재연결
```

RDS Multi-AZ의 핵심 특성:

- **동기 복제**: 쓰기가 Primary와 Standby 모두에 완료돼야 애플리케이션에 응답 반환 → 데이터 유실 없음
- **자동 페일오버**: 수동 개입 없이 AWS가 DNS 전환 수행 (일반적으로 1~2분 이내)
- **스탠바이는 읽기 불가**: 스탠바이 인스턴스는 읽기 트래픽을 처리하지 않습니다 — 오직 가용성 목적
- **동일 엔드포인트**: 페일오버 후에도 애플리케이션이 연결하는 DNS 엔드포인트는 변경되지 않음

---

### 5) Multi-AZ vs 읽기 복제본 비교 (★ 시험 필출)

가장 자주 혼동하는 두 기능입니다.

| 항목 | RDS Multi-AZ | 읽기 복제본(Read Replica) |
|---|---|---|
| **목적** | 고가용성·자동 페일오버 | 읽기 확장(읽기 처리량 증가) |
| **복제 방식** | 동기(Synchronous) | 비동기(Asynchronous) |
| **읽기 트래픽** | 스탠바이는 읽기 불가 | 읽기 가능 (별도 엔드포인트) |
| **페일오버** | 자동 (수 분 이내) | 수동 승격 필요 |
| **리전** | 동일 리전 내 다른 AZ | 동일 리전 또는 다른 리전 |
| **데이터 유실** | 없음 (동기 복제) | 소량 가능 (비동기 지연) |
| **용도** | SPOF 제거, 가용성 확보 | 읽기 부하 분산, 보고서·분석 쿼리 |

> **시험 함정**: "읽기 복제본은 가용성을 높인다"는 설명은 틀렸습니다. 읽기 복제본은 가용성 기능이 아니라 읽기 확장 기능입니다. 가용성이 목적이라면 Multi-AZ를 선택합니다.

---

### 6) Route 53 헬스 체크·페일오버 라우팅

Route 53은 DNS 수준에서 장애를 감지하고 트래픽을 전환합니다.

**헬스 체크 종류:**

- **엔드포인트 모니터링**: 지정한 IP/도메인에 주기적으로 HTTP/HTTPS/TCP 요청을 보내 응답 상태 확인
- **다른 헬스 체크 상태 기반**: 복수의 헬스 체크를 AND/OR 조합
- **CloudWatch 알람 기반**: 알람 상태가 ALARM이면 비정상으로 판단

**Active-Passive 페일오버 구성:**

```
Route 53 페일오버 레코드
  Primary 레코드 → 기본 리소스 (헬스 체크 연결)
  Secondary 레코드 → 대기 리소스 (Primary 비정상 시 활성화)
```

- Primary가 비정상으로 판단되면 Route 53이 자동으로 Secondary 레코드로 응답
- 애플리케이션 코드 변경 없이 DNS 레벨에서 전환
- ALB·EC2·S3 정적 웹사이트 등 다양한 리소스를 대상으로 설정 가능

---

### 7) 정적 안정성(Static Stability)

> AWS Well-Architected Reliability Pillar 원칙: 워크로드는 장애 중에도 동적 조달(provisioning)에 의존하지 않고 정상 운영 용량으로 계속 동작해야 합니다.

**핵심 아이디어**: 장애가 발생했을 때 "새 리소스를 생성해서 복구"하는 방식은 그 생성 자체가 실패할 수 있습니다. 미리 충분한 용량을 이중화해 두면 장애 중에도 바로 동작합니다.

실제 적용 예:

| 상황 | 정적 안정성 적용 |
|---|---|
| AZ 장애 | 나머지 AZ의 인스턴스가 이미 실행 중 → 트래픽 수용 가능 |
| RDS 페일오버 | 스탠바이가 항상 동기 복제 상태로 대기 → 즉시 전환 |
| NAT 게이트웨이 | AZ마다 미리 배치 → 한 AZ 장애 시 다른 AZ 독립 동작 |

---

### 8) 스테이트리스 설계 — ASG의 전제

ASG는 인스턴스를 수시로 생성·교체합니다. EC2 로컬에 세션을 저장하면 그 인스턴스가 교체될 때 세션이 사라집니다.

해결책: 상태를 외부 공유 스토어에 분리합니다.

```
EC2 인스턴스 (상태 없음, 언제든 교체 가능)
    ↓
ElastiCache Redis / DynamoDB (세션·상태 저장)
```

- **ElastiCache Redis**: 세션, 캐시, 리더보드 등 저지연 인메모리 데이터
- **DynamoDB**: 세션 테이블, 내구성이 필요한 상태 데이터

---

## ✍️ 시험 포인트

| 시나리오 문구 | 정답 방향 |
|---|---|
| "highly available" | Multi-AZ + ALB + ASG 조합 |
| "eliminate single point of failure" | 각 레이어를 다중 AZ로 이중화 |
| "automatic failover for database" | RDS Multi-AZ (읽기 복제본 아님) |
| "scale read traffic" | 읽기 복제본 (Multi-AZ 아님) |
| "EC2 자동 복구·교체" | ASG 헬스 체크 (self-healing) |
| "DNS 레벨 페일오버" | Route 53 헬스 체크 + 페일오버 라우팅 |
| "세션 저장 위치 (ASG 환경)" | ElastiCache Redis 또는 DynamoDB |
| "fault tolerant" | 능동 이중화(Multi-AZ/Multi-Region)로 무중단 |

---

## ⚠️ 흔한 함정

1. **"RDS Multi-AZ는 읽기 성능도 높여준다."** → 틀렸습니다. 스탠바이 인스턴스는 읽기 트래픽을 처리하지 않습니다. 읽기 확장이 필요하면 읽기 복제본을 추가합니다.

2. **"Multi-AZ가 부하를 분산한다."** → 부하 분산은 ELB(ALB/NLB)의 역할입니다. Multi-AZ는 가용성을 위한 이중화이지, 트래픽 분산 기능이 아닙니다.

3. **"ASG를 단일 AZ에 구성하면 고가용성이다."** → 단일 AZ ASG는 그 AZ 자체가 장애 나면 전멸합니다. 반드시 2개 이상 AZ에 분산해야 합니다.

4. **"EC2에 세션을 저장해도 ASG 환경에서 문제없다."** → ASG가 인스턴스를 교체하면 해당 인스턴스의 세션이 사라집니다. 세션은 외부 공유 스토어(ElastiCache/DynamoDB)에 두어야 합니다.

5. **"읽기 복제본은 자동으로 페일오버된다."** → 읽기 복제본은 자동 페일오버가 없습니다. 수동 승격(promote)이 필요합니다. 자동 페일오버는 RDS Multi-AZ의 기능입니다.

6. **"NAT 게이트웨이 1개로 전체 VPC를 커버하면 된다."** → NAT 게이트웨이가 있는 AZ에 장애가 나면 다른 AZ의 프라이빗 서브넷이 인터넷에 나갈 수 없습니다. AZ마다 NAT 게이트웨이를 배치해야 합니다.

---

## 🧪 자가 점검

> 아래는 학습용 자가 점검입니다. (정식 검증 문항은 별도 문항 파일 참조)

**Q1.** 단일 EC2 + 단일 RDS로 운영 중인 웹 서비스를 "highly available"하게 만들려 합니다. 필요한 변경 사항은 무엇인가요?

<details><summary>정답 보기</summary>

다음 세 가지를 적용합니다.

1. **ALB + 다중 AZ Auto Scaling Group**: EC2를 최소 2개 AZ에 분산 배치하고, ALB가 헬스 체크로 비정상 인스턴스를 자동 제외합니다.
2. **RDS Multi-AZ 활성화**: 다른 AZ에 동기 스탠바이를 유지해, Primary 장애 시 자동으로 DNS 전환합니다.
3. **세션 외부화**: EC2 로컬 세션을 ElastiCache Redis 또는 DynamoDB로 이전해 인스턴스 교체 시에도 세션이 유지되도록 합니다.
</details>

**Q2.** RDS Multi-AZ를 활성화하면 읽기 성능이 향상되나요? 이유는?

<details><summary>정답 보기</summary>

아닙니다. RDS Multi-AZ의 스탠바이 인스턴스는 읽기 트래픽을 처리하지 않습니다. 스탠바이는 오직 동기 복제 및 페일오버 대기 목적으로만 존재합니다. 읽기 성능 향상이 필요하면 읽기 복제본(Read Replica)을 별도로 추가해야 합니다.
</details>

**Q3.** Route 53 Active-Passive 페일오버 라우팅을 구성했습니다. Primary 리소스가 비정상이 되면 어떤 일이 일어나나요?

<details><summary>정답 보기</summary>

Route 53이 Primary 엔드포인트의 헬스 체크 실패를 감지하면, DNS 응답을 Secondary(대기) 레코드로 자동 전환합니다. 클라이언트는 TTL 만료 후 Secondary 리소스로 연결됩니다. 애플리케이션 코드 변경 없이 DNS 레벨에서 전환이 이루어집니다.
</details>

**Q4.** 다음 중 "단일 실패점"이 아닌 것은 어느 것인가요?
(A) 단일 AZ에만 배치된 EC2 인스턴스
(B) RDS Multi-AZ 배포
(C) 단일 AZ의 NAT 게이트웨이
(D) 단일 AZ RDS 인스턴스

<details><summary>정답 보기</summary>

**(B) RDS Multi-AZ 배포**입니다.

RDS Multi-AZ는 다른 AZ에 동기 스탠바이를 유지하므로 Primary 장애 시 자동으로 페일오버됩니다. 단일 실패점이 제거된 상태입니다. (A), (C), (D)는 해당 AZ에 장애가 나면 서비스가 중단되는 단일 실패점입니다.
</details>

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. (작성·대조: 2026-06-07, WebFetch 200 확인)

1. AWS Well-Architected Framework — Reliability Pillar — https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/welcome.html
2. RDS Multi-AZ DB 인스턴스 배포 — https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.MultiAZSingleStandby.html
3. RDS Multi-AZ 배포 구성 및 관리 — https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.MultiAZ.html
4. Route 53 헬스 체크 생성 — https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/dns-failover.html
5. SAA-C03 공식 시험 가이드 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
