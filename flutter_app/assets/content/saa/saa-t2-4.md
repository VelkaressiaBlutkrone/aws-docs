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

## 🔤 먼저 알아야 할 용어

이 문서를 읽는 데 필요한 기초 용어입니다. 이미 알면 건너뛰세요.

| 용어 | 영문 | 한 줄 풀이 |
|---|---|---|
| **가용 영역** | Availability Zone (AZ) | 단일 리전 내 독립 데이터센터 클러스터 — AZ 간 장애가 전파되지 않도록 물리적으로 격리 |
| **단일 실패점** | SPOF (Single Point of Failure) | 그 하나가 멈추면 전체 시스템이 멈추는 구성 요소 |
| **동기 복제** | Synchronous Replication | 주 인스턴스가 복제본에도 쓰기가 완료됨을 확인한 뒤 응답 — 데이터 유실 없음 |
| **비동기 복제** | Asynchronous Replication | 주 인스턴스가 복제 완료를 기다리지 않고 응답 — 지연(lag) 만큼 데이터 유실 가능 |
| **페일오버** | Failover | 장애 시 대기 리소스로 자동 전환하는 동작 |
| **정적 안정성** | Static Stability | 장애 중 신규 리소스 조달 없이 사전 이중화된 용량으로 계속 동작하는 설계 원칙 |
| **스탠바이** | Standby | RDS Multi-AZ에서 동기 복제를 받는 대기 인스턴스 — 페일오버 전까지 읽기 불가 |
| **읽기 복제본** | Read Replica | 비동기 복제를 통해 읽기 트래픽을 분산하는 추가 인스턴스 — 가용성 목적 아님 |

---

## 📖 핵심 개념

### 1) HA·내결함성·DR — 세 개념 구분 (★ 시험 단골)

| 개념 | 목표 | 장애 시 동작 | 비용·복잡도 |
|---|---|---|---|
| **고가용성(HA)** | 다운타임 최소화·빠른 자동 복구 | 짧은 중단 후 자동 전환 (수 초~수 분) | 중간 |
| **내결함성(Fault Tolerance)** | 장애 중에도 **완전 무중단** 지속 | 능동 이중화로 중단 없이 계속 동작 | 높음 |
| **재해 복구(DR)** | 대규모·리전 단위 재해로부터 복구 | RTO/RPO 목표에 따라 복구 | 전략에 따라 다름 |

> **시험 문구 해석**: "highly available" → Multi-AZ + 자동 복구 조합으로 답합니다. "fault tolerant" → 더 강한 요건으로, 완전한 능동 이중화를 암시합니다. "DR"이 나오면 `saa-t2-5`의 4전략으로 답합니다.


> 🧠 원리: 왜 HA·내결함성·DR을 같은 개념으로 묶으면 시험에서 오답을 고를까요?
> 세 개념은 "얼마나 빨리, 얼마나 완전하게 서비스를 유지하느냐"의 요구 강도가 다릅니다.
> HA는 수 초~수 분의 짧은 중단을 허용하며 비용 대비 자동 복구를 목표로 하고, 내결함성은 중단 자체를 허용하지 않아 능동 이중화 비용이 훨씬 크며, DR은 리전 단위 재해를 대상으로 RTO/RPO로 목표를 수치화합니다.
> "highly available"이라는 시험 문구는 Multi-AZ 자동 복구를 의미하고, "fault tolerant"는 그보다 강한 무중단 이중화를 암시하므로 두 키워드를 구분해 다른 설계로 답해야 합니다.

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


> 🧠 원리: 왜 AWS는 단일 AZ 내 이중 인스턴스보다 다중 AZ 분산을 SPOF 제거 방법으로 권고할까요?
> 단일 AZ 내 두 인스턴스는 네트워크·전력·냉각을 공유하기 때문에 AZ 수준 장애에서 동시에 영향을 받습니다.
> AZ는 물리적으로 분리된 데이터센터 클러스터로 설계돼 한 AZ의 장애가 다른 AZ로 전파되지 않으므로, 다중 AZ 배치가 인스턴스 이중화보다 격리 수준이 높습니다.
> 이 원리에서 "단일 AZ ASG"는 인스턴스를 아무리 늘려도 SPOF를 완전히 제거하지 못하며, AZ 자체가 SPOF로 남는다는 결론이 나옵니다.

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

> 🧠 원리: 왜 표준 HA 구조는 Route 53 → ALB → ASG → RDS라는 레이어 순서를 가질까요?
> 각 레이어는 자신보다 아래 레이어의 SPOF를 담당하는 역할 분담입니다. Route 53은 지역(리전·엔드포인트) 수준, ALB는 인스턴스 수준, ASG는 개별 EC2 수준, RDS Multi-AZ는 DB 수준의 이중화를 각각 맡습니다.
> 레이어를 건너뛰거나 하나로 통합하면 특정 장애 유형에 취약한 구멍이 생깁니다. 예를 들어 ALB 없이 Route 53만 있으면 인스턴스 장애를 DNS가 직접 감지해야 해서 감지 지연과 TTL 전파 지연이 중첩됩니다.
> 각 레이어가 자신의 범위 장애만 책임지므로 장애 탐지와 복구가 독립적으로 작동하고, 설계 변경 시 영향 범위도 해당 레이어로 한정됩니다.

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


> 🧠 원리: 왜 RDS Multi-AZ는 동기 복제를 선택해 쓰기 지연을 감수할까요?
> 페일오버 목적의 스탠바이가 Primary보다 데이터가 뒤처져 있으면, 전환 시 최근 쓰기가 유실되어 "데이터 유실 없음"이라는 HA 보장이 깨집니다.
> 동기 복제는 Primary와 Standby 모두에 쓰기가 완료돼야 응답을 반환하므로 네트워크 왕복 지연이 추가되지만, 페일오버 시점에 두 인스턴스의 데이터가 항상 동일함을 보장합니다.
> 이 트레이드오프(쓰기 지연 허용 vs 데이터 유실 방지)가 Multi-AZ를 읽기 확장이 아닌 가용성 전용 기능으로 분류하는 설계 이유입니다.

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

> 🧠 원리: 왜 읽기 복제본은 비동기 복제를 사용해 페일오버 자동화를 제공하지 않을까요?
> 읽기 복제본의 목적은 읽기 처리량 확장이므로, 복제 지연(lag)이 약간 있어도 읽기 성능 향상이라는 목표를 달성합니다. 동기 복제를 요구하면 모든 쓰기마다 복제본 수만큼 지연이 중첩되어 쓰기 성능이 크게 저하됩니다.
> 비동기 복제 구조에서는 Primary 장애 시 복제본이 최신 데이터를 보장할 수 없어 자동 페일오버를 구현하면 데이터 유실이 발생할 수 있으므로, AWS는 수동 승격을 요구해 운영자가 데이터 상태를 확인 후 결정하게 합니다.
> 이 구조적 차이가 "읽기 복제본 = 읽기 확장, Multi-AZ = 가용성"으로 목적을 분리하는 근거이며, 두 기능은 함께 사용할 수 있지만 서로 대체하지 않습니다.

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

> 🧠 원리: 왜 Route 53 페일오버는 ALB 헬스 체크가 아닌 DNS 레벨에서 별도로 동작할까요?
> ALB 헬스 체크는 대상 그룹 내 개별 인스턴스를 교체하는 레이어이고, Route 53 헬스 체크는 ALB 엔드포인트 전체 또는 리전 단위 리소스의 정상 여부를 판단하는 레이어입니다.
> ALB가 응답하더라도 그 뒤 전체 가용 영역·리전이 장애 상황일 수 있으므로, DNS 수준에서 독립된 헬스 체크가 필요합니다.
> 두 레이어가 각자의 범위를 독립 감시하면 "인스턴스 교체"와 "엔드포인트 전환"이 서로의 실패 없이 각각 동작하며, Active-Passive 또는 지리 기반 라우팅 같은 고수준 전략을 ALB 설정 변경 없이 DNS만으로 구현할 수 있습니다.

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

> 🧠 원리: 왜 장애 중에 동적 조달(인스턴스 생성·확장)에 의존하는 방식이 위험할까요?
> 대규모 장애나 리전 이벤트는 AWS 제어 플레인(EC2 API, Auto Scaling 등)에도 부하를 주어 동적 조달 자체가 지연되거나 실패할 수 있습니다.
> 정적 안정성은 장애 발생 이전에 충분한 용량이 이미 실행 중인 상태를 유지해, 복구 과정이 제어 플레인 가용성에 의존하지 않도록 설계합니다.
> RDS Multi-AZ의 스탠바이와 멀티 AZ ASG의 예비 용량이 대표적인 정적 안정성 적용 사례로, 장애 감지와 동시에 추가 프로비저닝 없이 바로 전환·처리가 가능한 이유입니다.

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

> 🧠 원리: 왜 스테이트리스 설계가 ASG의 자가 복구 전제 조건이 될까요?
> ASG가 비정상 인스턴스를 교체하면 그 인스턴스에 저장됐던 로컬 상태(세션·임시 데이터)는 함께 사라집니다. 상태가 인스턴스에 묶여 있으면 교체가 곧 상태 유실이므로 자가 복구가 사용자에게 단절로 느껴집니다.
> 상태를 ElastiCache나 DynamoDB 같은 외부 공유 스토어에 두면 어떤 인스턴스든 동일 상태를 읽어 요청을 처리할 수 있어, 인스턴스 교체가 사용자에게 투명하게 작동합니다.
> 결국 ASG의 자가 복구는 "인스턴스를 교체해도 서비스가 끊기지 않는다"는 보장 위에서만 의미를 가지며, 그 보장의 전제가 상태를 인스턴스 밖에 두는 스테이트리스 설계입니다.

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
   *(원리: §4 — Multi-AZ 스탠바이는 가용성 전용 설계로, 동기 복제와 단일 엔드포인트 페일오버가 목적이며 읽기 확장은 읽기 복제본의 역할이다.)*

2. **"Multi-AZ가 부하를 분산한다."** → 부하 분산은 ELB(ALB/NLB)의 역할입니다. Multi-AZ는 가용성을 위한 이중화이지, 트래픽 분산 기능이 아닙니다.
   *(원리: §3 — 표준 HA 구조에서 ALB가 트래픽 분산을, RDS Multi-AZ가 DB 가용성을 각각 전담하므로 한 레이어가 두 역할을 겸하지 않는다.)*

3. **"ASG를 단일 AZ에 구성하면 고가용성이다."** → 단일 AZ ASG는 그 AZ 자체가 장애 나면 전멸합니다. 반드시 2개 이상 AZ에 분산해야 합니다.
   *(원리: §2 — AZ 내 인스턴스를 아무리 늘려도 AZ 자체가 SPOF로 남으므로, SPOF 제거는 다중 AZ 분산이 전제 조건이다.)*

4. **"EC2에 세션을 저장해도 ASG 환경에서 문제없다."** → ASG가 인스턴스를 교체하면 해당 인스턴스의 세션이 사라집니다. 세션은 외부 공유 스토어(ElastiCache/DynamoDB)에 두어야 합니다.
   *(원리: §8 — 스테이트리스 설계가 ASG 자가 복구의 전제 조건이라, 상태를 인스턴스에 두면 교체가 사용자에게 단절로 나타난다.)*

5. **"읽기 복제본은 자동으로 페일오버된다."** → 읽기 복제본은 자동 페일오버가 없습니다. 수동 승격(promote)이 필요합니다. 자동 페일오버는 RDS Multi-AZ의 기능입니다.
   *(원리: §5 — 비동기 복제 구조에서는 데이터 유실 가능성을 운영자가 확인해야 하므로, 자동 전환을 허용하지 않고 수동 승격을 요구한다.)*

6. **"NAT 게이트웨이 1개로 전체 VPC를 커버하면 된다."** → NAT 게이트웨이가 있는 AZ에 장애가 나면 다른 AZ의 프라이빗 서브넷이 인터넷에 나갈 수 없습니다. AZ마다 NAT 게이트웨이를 배치해야 합니다.
   *(원리: §7 — 정적 안정성 원칙에 따라 장애 중 동적 조달 없이 각 AZ가 독립 동작하려면 NAT 게이트웨이도 AZ마다 사전 배치돼야 한다.)*

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

**Q5 (원리).** 왜 RDS Multi-AZ의 스탠바이는 읽기 트래픽을 처리하지 않도록 설계됐을까요?

<details><summary>정답 보기</summary>

**설계 목적이 가용성 전용이기 때문입니다.** RDS Multi-AZ의 스탠바이는 동기 복제로 Primary와 항상 동일한 데이터를 유지하며, 단일 DNS 엔드포인트를 통해 페일오버 시 투명하게 Primary로 전환됩니다. AWS는 스탠바이를 읽기 트래픽 없이 페일오버 대기 전용으로 설계함으로써 가용성 보장에 집중하며, 읽기 확장이 필요하면 비동기 복제 기반의 읽기 복제본을 별도로 사용합니다.
</details>

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. (작성·대조: 2026-06-07, WebFetch 200 확인)

1. AWS Well-Architected Framework — Reliability Pillar — https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/welcome.html
2. RDS Multi-AZ DB 인스턴스 배포 — https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.MultiAZSingleStandby.html
3. RDS Multi-AZ 배포 구성 및 관리 — https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.MultiAZ.html
4. Route 53 헬스 체크 생성 — https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/dns-failover.html
5. SAA-C03 공식 시험 가이드 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
