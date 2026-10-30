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
  - title: Aurora 고가용성 — 6개 스토리지 노드·장애 조치 시간 (공식)
    url: https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Concepts.AuroraHighAvailability.html
  - title: DynamoDB 글로벌 테이블 동작 — MREC·MRSC·증인 (공식)
    url: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/V2globaltables_HowItWorks.html
  - title: Route 53 라우팅 정책 선택 — 8종 (공식)
    url: https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy.html
  - title: Route 53 헬스 체크 판정 — 18% 규칙·응답 시간 (공식)
    url: https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/dns-failover-determining-health-of-endpoints.html
  - title: 멀티값 응답 라우팅 — 최대 8개 (공식)
    url: https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy-multivalue.html
  - title: 재시도 제어·제한 — Well-Architected REL05-BP03 (공식)
    url: https://docs.aws.amazon.com/wellarchitected/2022-03-31/framework/rel_mitigate_interaction_failure_limit_retries.html
  - title: 회로 차단기 패턴 (공식 Prescriptive Guidance)
    url: https://docs.aws.amazon.com/prescriptive-guidance/latest/cloud-design-patterns/circuit-breaker.html
  - title: X-Ray 트레이스 맵 (공식)
    url: https://docs.aws.amazon.com/xray/latest/devguide/xray-console-servicemap.html
  - title: Service Quotas 요청 템플릿 (공식)
    url: https://docs.aws.amazon.com/servicequotas/latest/userguide/organization-templates.html
lastVerified: 2026-10-21
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
- [ ] **RDS Multi-AZ 동작 원리** — DB 인스턴스 배포 기준의 동기 복제·자동 페일오버·스탠바이 읽기 불가를 안다
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
| **스탠바이** | Standby | RDS Multi-AZ DB 인스턴스 배포에서 동기 복제를 받는 대기 인스턴스 — 페일오버 전까지 읽기 불가 |
| **읽기 복제본** | Read Replica | 비동기 복제를 통해 읽기 트래픽을 분산하는 추가 인스턴스 — 가용성 목적 아님 |

---

## 📖 핵심 개념 {#core-concepts}

### 1) HA·내결함성·DR — 세 개념 구분 (★ 시험 단골) {#ha-ft-dr}

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

### 2) 단일 실패점(SPOF)이란 {#single-point-of-failure}

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

### 3) 표준 HA 아키텍처 {#standard-ha-architecture}

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

### 4) RDS Multi-AZ DB 인스턴스 배포 동작 원리 (★ 시험 핵심) {#rds-multi-az}

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

여기서의 Multi-AZ는 SAA 고전 문항에서 자주 묻는 **DB 인스턴스 배포(single standby)** 기준입니다. 읽기 가능한 스탠바이 2개를 제공하는 **Multi-AZ DB 클러스터**는 별도 배포 옵션입니다.

RDS Multi-AZ DB 인스턴스 배포의 핵심 특성:

- **동기 복제**: 쓰기가 Primary와 Standby 모두에 완료돼야 애플리케이션에 응답 반환 → 데이터 유실 없음
- **자동 페일오버**: 수동 개입 없이 AWS가 DNS 전환 수행 (일반적으로 1~2분 이내)
- **스탠바이는 읽기 불가**: DB 인스턴스 배포의 스탠바이는 읽기 트래픽을 처리하지 않습니다 — 오직 가용성 목적
- **동일 엔드포인트**: 페일오버 후에도 애플리케이션이 연결하는 DNS 엔드포인트는 변경되지 않음


> 🧠 원리: 왜 RDS Multi-AZ는 동기 복제를 선택해 쓰기 지연을 감수할까요?
> 페일오버 목적의 스탠바이가 Primary보다 데이터가 뒤처져 있으면, 전환 시 최근 쓰기가 유실되어 "데이터 유실 없음"이라는 HA 보장이 깨집니다.
> 동기 복제는 Primary와 Standby 모두에 쓰기가 완료돼야 응답을 반환하므로 네트워크 왕복 지연이 추가되지만, 페일오버 시점에 두 인스턴스의 데이터가 항상 동일함을 보장합니다.
> 이 트레이드오프(쓰기 지연 허용 vs 데이터 유실 방지)가 Multi-AZ를 읽기 확장이 아닌 가용성 전용 기능으로 분류하는 설계 이유입니다.

---

### 5) Multi-AZ vs 읽기 복제본 비교 (★ 시험 필출) {#multi-az-vs-read-replica}

가장 자주 혼동하는 두 기능입니다.

| 항목 | RDS Multi-AZ DB 인스턴스 배포 | 읽기 복제본(Read Replica) |
|---|---|---|
| **목적** | 고가용성·자동 페일오버 | 읽기 확장(읽기 처리량 증가) |
| **복제 방식** | 동기(Synchronous) | 비동기(Asynchronous) |
| **읽기 트래픽** | 스탠바이는 읽기 불가 | 읽기 가능 (별도 엔드포인트) |
| **페일오버** | 자동 (수 분 이내) | 수동 승격 필요 |
| **리전** | 동일 리전 내 다른 AZ | 동일 리전 또는 다른 리전 |
| **데이터 유실** | 없음 (동기 복제) | 소량 가능 (비동기 지연) |
| **용도** | SPOF 제거, 가용성 확보 | 읽기 부하 분산, 보고서·분석 쿼리 |

> **시험 함정**: "읽기 복제본은 가용성을 높인다"는 설명은 틀렸습니다. 읽기 복제본은 가용성 기능이 아니라 읽기 확장 기능입니다. 가용성이 목적이라면 Multi-AZ를 선택합니다.

> **현행 구분**: RDS Multi-AZ DB 클러스터는 읽기 가능한 스탠바이 2개를 갖는 별도 옵션입니다. 시험에서 단순히 "RDS Multi-AZ standby"를 묻는 고전 문항은 보통 DB 인스턴스 배포 기준으로 풉니다.

> 🧠 원리: 왜 읽기 복제본은 비동기 복제를 사용해 페일오버 자동화를 제공하지 않을까요?
> 읽기 복제본의 목적은 읽기 처리량 확장이므로, 복제 지연(lag)이 약간 있어도 읽기 성능 향상이라는 목표를 달성합니다. 동기 복제를 요구하면 모든 쓰기마다 복제본 수만큼 지연이 중첩되어 쓰기 성능이 크게 저하됩니다.
> 비동기 복제 구조에서는 Primary 장애 시 복제본이 최신 데이터를 보장할 수 없어 자동 페일오버를 구현하면 데이터 유실이 발생할 수 있으므로, AWS는 수동 승격을 요구해 운영자가 데이터 상태를 확인 후 결정하게 합니다.
> 이 구조적 차이가 "읽기 복제본 = 읽기 확장, Multi-AZ = 가용성"으로 목적을 분리하는 근거이며, 두 기능은 함께 사용할 수 있지만 서로 대체하지 않습니다.

---

### 6) Route 53 헬스 체크·페일오버 라우팅 {#route53-failover}

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

### 7) 정적 안정성(Static Stability) {#static-stability}

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

### 8) 스테이트리스 설계 — ASG의 전제 {#stateless-asg}

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

### 9) HA 지표 — 가용성 %와 연간 허용 중단 {#availability-targets}

가용성은 퍼센트 하나로 말하지만, **실제로 허용되는 중단 시간**으로 바꿔 보면 설계 난이도가 드러납니다. 아래는 365일(8,760시간) 기준 산술 환산입니다 — 공식 수치가 아니라 `365 × 24h × (1 − 가용성)` 계산값입니다.

| 가용성 | 연간 허용 중단 | 30일 환산 |
|---|---|---|
| 99% | 약 3일 15시간 36분 | 약 7시간 12분 |
| 99.9% (three nines) | 약 8시간 46분 | 약 43분 |
| 99.95% | 약 4시간 23분 | 약 22분 |
| 99.99% (four nines) | 약 52분 34초 | 약 4분 19초 |
| 99.999% (five nines) | 약 5분 15초 | 약 26초 |

9가 하나 늘 때마다 허용 중단이 **10분의 1**로 줄어듭니다. 99.9%는 "주말 한 번 고생"이지만 99.99%는 **한 해 통틀어 1시간도 안 되는** 예산이라, 사람이 알아차리고 손으로 대응하는 설계로는 닿을 수 없습니다 — 자동 장애 조치가 필수가 되는 경계가 여기입니다.

> ⚠️ **SLA와 설계 목표는 다릅니다.**
> **SLA**는 AWS가 서비스 수준 계약 문서에 적는 수치이고, **설계 목표**는 "그렇게 되도록 설계했다"는 서술입니다. 예컨대 Aurora 관련 공식 자료는 Aurora를 **99.99%를 넘는 가용성을 목표로 설계**했다고 적는데, 이것은 계약 수치가 아닙니다.
> 이 문서는 **서비스별 SLA 퍼센트를 적지 않습니다.** SLA는 개정되고 리전·구성에 따라 조건이 달라 암기 대상이 아닙니다. 출제 축은 "목표를 몇 개의 9로 둘 것인가"와 **그에 맞는 설계**(AZ 수·복제 방식·장애 조치 시간)를 고르는 쪽입니다.

---

### 10) DB 가용성 옵션 심화 {#db-availability-options}

**Aurora — 스토리지와 컴퓨트가 분리돼 있습니다**

- 프라이머리에 쓰면 Aurora가 **여러 AZ에 걸쳐 클러스터 볼륨의 스토리지 노드 6개에 동기 복제**합니다. 이 구조가 데이터 중복을 주고 **I/O 프리즈를 없애며 시스템 백업 중 지연 스파이크를 최소화**합니다.
- 클러스터 볼륨은 단일 리전의 여러 AZ에 걸치고 **각 AZ가 클러스터 볼륨 데이터의 사본**을 가집니다 → **AZ 하나의 장애를 데이터 손실 없이, 짧은 중단만으로** 견딥니다.
- 프라이머리(라이터) 외에 **읽기 전용 Aurora 복제본을 최대 15개** 둘 수 있고, 비동기 복제라 프라이머리 성능에 영향을 주지 않습니다.
- 프라이머리 장애 시 ① **기존 Aurora 복제본을 승격**하거나 ② **새 프라이머리를 생성**합니다. 복제본이 하나 이상 있으면 승격 경로입니다.
- ⚠️ **장애 조치 시간** — 공식 사용자 가이드는 "**통상 60초 미만, 흔히 30초 미만**"으로 적습니다. "30초"만 기억하면 상한을 놓칩니다.
- **클러스터 엔드포인트**는 항상 현재 프라이머리를 가리키므로 장애 조치 후에도 연결 문자열이 그대로입니다.
- 가장 빠른 복구 경로는 종종 **재시작**입니다 — 재시작이 장애 조치보다 빠르고 오버헤드가 적습니다.

**RDS Multi-AZ — 두 가지 배치 (★ 시험 핵심)**

| | Multi-AZ **DB 인스턴스** | Multi-AZ **DB 클러스터** |
|---|---|---|
| 스탠바이 | **1개**(읽기 불가) | **2개 · 읽기 가능 스탠바이** |
| 장애 조치 | 통상 **60~120초** | 통상 **35초 미만** |
| 구조 | 동기 복제 | 트랜잭션 로그를 인스턴스 **로컬 스토리지**에 먼저 쓰고 영구 스토리지로 플러시 → 커밋 지연이 **최대 2배 빠름** |

§4·§5가 Multi-AZ **인스턴스** 중심이므로, "읽기도 받는 스탠바이가 필요하다" 또는 "장애 조치를 1분 안쪽으로" 같은 요구가 나오면 **클러스터** 쪽을 봐야 합니다.

**DynamoDB 글로벌 테이블 — 두 일관성 모드**

| 모드 | 동작 |
|---|---|
| **MREC**(기본) | 항목 변경이 다른 복제본에 **통상 1초 내** 복제되고 리전 간 **최종 일관성**. 쓰기 지연이 더 낮습니다 |
| **MRSC** | 쓰기가 성공을 반환하기 **전에 최소 1개 다른 리전에 동기 복제**. 어떤 복제본에서든 강한 일관성 읽기가 **항상 최신 버전**을 반환하고, 조건부 쓰기도 최신 버전에 대해 평가됩니다 |

- ⚠️ **MRSC는 정확히 3개 리전**에 배포해야 합니다. **복제본 3개** 또는 **복제본 2개 + 증인(witness) 1개** 구성입니다. 증인은 복제본에 쓰인 변경 데이터를 담지만 **읽기·쓰기를 할 수 없고**, 두 복제본과 다른 리전에 있으며 **DynamoDB가 소유·관리**해 계정에 나타나지 않습니다(`DescribeTable`로 확인).
- MRSC는 **일부 리전에서만** 제공되고, 쓰기·강한 일관성 읽기 지연이 **선택한 리전 조합에 따라 달라집니다**(교차 리전 통신이 필요해서입니다).
- **시험 신호**: "리전 장애에도 **RPO 0**가 필요하다 / 어느 리전에서 읽어도 최신 데이터여야" → **MRSC**. "지연이 더 중요하고 최종 일관성으로 충분" → **MREC**.

---

### 11) Route 53 라우팅 정책과 헬스 체크 수치 {#route53-policies}

§6이 장애 조치 라우팅을 다뤘으니, 정책 전체 지도와 헬스 체크의 **수치**를 채웁니다. 정책별 상세 설계는 **`saa-t3-7`** 이 정본입니다.

**라우팅 정책은 8종입니다**

| 정책 | 언제 쓰는가 |
|---|---|
| **단순(Simple)** | 도메인의 한 기능을 수행하는 **단일 리소스** |
| **장애 조치(Failover)** | **액티브-패시브** 장애 조치 |
| **가중(Weighted)** | 지정한 **비율**로 여러 리소스에 분배 |
| **지연 시간(Latency)** | 여러 리전의 리소스 중 **지연이 가장 좋은 리전**으로 |
| **지리적 위치(Geolocation)** | **사용자의 위치** 기준 |
| **지리 근접(Geoproximity)** | **리소스의 위치** 기준 + 선택적으로 한쪽으로 트래픽 **편향** |
| **IP 기반(IP-based)** | 트래픽이 출발하는 **IP 주소**를 알고 있을 때 |
| **멀티값 응답(Multivalue answer)** | 무작위로 고른 **최대 8개 정상 레코드** 반환 |

- 멀티값 응답은 **로드 밸런서의 대체가 아닙니다.** 정상 레코드가 8개 이하면 전부 반환하고, **전부 비정상이면 최대 8개 비정상 레코드를 반환**합니다. 헬스 체크를 연결하지 않은 레코드는 **항상 정상으로 간주**됩니다.

**헬스 체크 수치 (★ 시험 포인트)**

- 요청 간격은 **30초(기본) 또는 10초**를 고릅니다.
- **실패 임계값**은 "연속 몇 번 실패하면 비정상으로 볼지"입니다.
- ⚠️ **18% 규칙** — 전 세계 헬스 체커 중 **18%를 넘는** 비율이 정상이라 보고하면 Route 53은 엔드포인트를 정상으로, **18% 이하면 비정상**으로 봅니다. 여러 리전의 체커가 정상으로 판단하도록 고른 값이며 공식이 **향후 변경될 수 있다**고 적습니다.
- HTTP·HTTPS 체크는 **4초 안에 TCP 연결**, 연결 후 **2초 안에 2xx·3xx 응답**을 요구합니다.
- ⚠️ **HTTPS 헬스 체크는 SSL/TLS 인증서를 검증하지 않습니다** — 인증서가 무효하거나 만료돼도 그 때문에 실패하지 않습니다. 인증서 만료 감시는 ACM·CloudWatch 쪽 일입니다.
- 헬스 체커들은 서로 조율하지 않으므로, 초당 여러 요청이 몰린 뒤 몇 초간 공백이 생기는 패턴이 **정상 동작**입니다.

---

### 12) 분산 설계 패턴 — 재시도·백오프·회로 차단기 {#distributed-patterns}

재시도는 네트워크 장애의 기본 대응이지만, **그대로 두면 장애를 키웁니다.**

- 오류가 나자마자 모든 클라이언트가 재시도하면 네트워크가 신규·재시도 요청으로 포화되고 **재시도 폭풍(retry storm)** 이 되어 가용성이 더 떨어집니다. 이 패턴이 계속되면 **전체 시스템 장애**로 이어질 수 있습니다.
- **지수 백오프** — 재시도 간격을 점진적으로 늘려 혼잡을 피합니다. 백오프는 **최대값으로 캡**해야 합니다.
- **지터(jitter)** — 백오프만으로는 부족합니다. 분산 시스템에서 모든 클라이언트가 동시에 백오프하면 **재시도 호출 군집**이 생기므로, 대기 시간에 **무작위성**을 더해 시간축에 흩뿌립니다.
- **최대 재시도 횟수 또는 경과 시간**을 정하고 그 뒤엔 실패시킵니다. 스택 **하위** 서비스는 최대 재시도를 **0 또는 1**로 제한해도 효과적입니다 — 재시도를 상위 스택에 위임하는 설계입니다.
- ⚠️ 공식 경고: "**백오프 알고리즘이 존재한다고 절대 가정하지 말고 항상 테스트·검증하라.**" AWS SDK는 기본 구현을 갖지만 설정을 확인해야 합니다. Well-Architected는 이 모범 사례를 세우지 않을 때의 **위험 수준을 높음(High)** 으로 적습니다.

**회로 차단기(circuit breaker)** — 실패할 가능성이 큰 호출을 **아예 보내지 않는** 패턴입니다.

| 상태 | 동작 |
|---|---|
| **CLOSED**(정상) | 요청이 정상적으로 흐릅니다 |
| **OPEN**(실패) | 반복 실패를 감지하면 전환. 새 요청을 **즉시 거부**해 대상 서비스의 압력을 줄이고 클라이언트 자원을 보존합니다 |
| **HALF_OPEN**(시험) | 타임아웃이 지나면 **소수의 시험 요청**만 허용. 성공하면 다시 CLOSED로 돌아갑니다 |

공식 고려사항 — 코드 비대를 막기 위해 **마이크로서비스 비의존·API 기반**으로 구현 · 다중 스레드에서 **첫 실패 호출이 만료 타임아웃을 정하고 후속 호출이 그것을 무한히 밀지 않도록** 구현 · 관리자가 회로를 **강제로 open/close** 할 수 있어야 함 · OPEN 중 실패한 호출을 식별할 **로깅** 필요.

> 재시도와 회로 차단기는 **대체가 아니라 층**입니다. 일시적 오류는 재시도(백오프·지터)가 흡수하고, 지속되는 장애는 회로 차단기가 끊습니다. 둘 중 하나만 두면 "복구 가능한 실패를 포기"하거나 "죽은 서비스를 계속 때리는" 쪽으로 기웁니다.

---

### 13) 운영 가시성과 서비스 쿼터 {#visibility-and-quotas}

**AWS X-Ray — 분산 추적으로 "어디가 느린가"를 찾습니다**

- 추적 데이터로 **애플리케이션을 구성하는 서비스의 시각 표현**(트레이스 맵·서비스 맵)을 만들어, **오류가 있는 서비스 · 지연이 높은 연결 · 실패한 요청의 추적**을 식별합니다.
- 맵은 **서비스 노드**(요청을 처리하는 쪽) · **업스트림 클라이언트 노드**(요청의 출처) · **다운스트림 서비스 노드**(앱이 처리 중 쓰는 웹 서비스·리소스)를 보여 줍니다.
- **SQS·Lambda를 쓰는 이벤트 기반 애플리케이션의 연결된 뷰**와 **교차 계정 추적**을 지원합니다.
- 노드 테두리 색이 문제 유형을 가립니다 — **빨강 = 서버 결함(500대)** · **노랑 = 클라이언트 오류(400대)** · **보라 = 스로틀링(429 Too Many Requests)**.

**Service Quotas — 한도를 가용성 설계의 일부로 다루기**

- 쿼터(한도)를 **한곳에서 조회·관리**합니다(콘솔·API·CLI). **기본 쿼터**와 계정에 **적용된(applied) 쿼터**를 모두 볼 수 있습니다 — applied는 과거에 그 계정에 부여된 재정의입니다.
- **CloudWatch 경보**를 붙여 사용량이 쿼터에 가까워질 때 알림을 받습니다. 쿼터를 "터지면 올리는 것"이 아니라 **선제적으로 관리**하는 축입니다.
- **쿼터 요청 템플릿** — Organizations 조직에 연결하면 **새 계정이 만들어질 때 자동으로 쿼터 증액을 요청**합니다. 조직이 **all features**여야 하고(통합 결제 기능만이면 쓸 수 없습니다), 템플릿에는 **최대 10개 쿼터**를 담습니다. 상업 리전만 지원합니다.
- ⚠️ **템플릿을 갱신해도 기존 계정의 쿼터 값은 바뀌지 않습니다** — 템플릿은 "앞으로 만들 계정"에만 적용됩니다.
- **시험 신호**: "DR **대기 환경**을 다른 리전에 둔다" → 그 리전의 **쿼터가 장애 조치 시 필요한 규모를 감당하는지** 미리 확인·증액해야 합니다. §7 정적 안정성과 같은 사고 방식입니다 — **장애 시점에 증액을 요청해서는 늦습니다.**

---

### 14) 관리형 서비스 선택과 가용성 {#managed-services}

공식 Task 2.2 Knowledge에 "**관리형 서비스와 적합한 사용 사례**(예: Amazon Comprehend, Amazon Polly)"가 있습니다.

> ⚠️ **공식 문구 자체가 모호합니다.** 영문 가이드는 `AWS Managed Services (AMS) with appropriate use cases (for example, Amazon Comprehend, Amazon Polly)`로 적는데, **AMS**(AWS가 고객 환경 운영을 대행하는 서비스)와 예시로 든 AI 서비스는 **다른 범주**입니다. AMS는 공식 in-scope 목록에도 없습니다. 그래서 이 절은 **in-scope 목록에 있는 관리형 AI 서비스**를 기준으로 정리하고, AMS 자체에 대한 주장은 하지 않습니다.

**가용성 관점에서 관리형 서비스를 고르는 이유** — 직접 운영하면 Multi-AZ 배치·장애 조치·패치·용량을 전부 설계해야 하지만, 관리형 서비스를 쓰면 그 책임이 AWS로 넘어갑니다. 공동 책임 모델이 가용성 설계에 주는 가장 직접적인 효과입니다.

| 데이터 양식 | 용도 | 서비스 |
|---|---|---|
| 텍스트 | 감정 분석 · 엔티티 인식 · 토픽 모델링 | **Amazon Comprehend** |
| 텍스트 | 대화형 인터페이스 · 챗봇 · 의도 인식 | **Amazon Lex** |
| 텍스트 | 실시간·배치 **번역** | **Amazon Translate** |
| 문서 | 인쇄 텍스트 · **필기** · 레이아웃 · 데이터 추출 | **Amazon Textract** |
| 이미지·비디오 | 객체 탐지 · 콘텐츠 검토 · 얼굴 분석 | **Amazon Rekognition** |
| 오디오 | **음성 → 텍스트** 전사 | **Amazon Transcribe** |
| 오디오 | **텍스트 → 음성** | **Amazon Polly** |

- **시험 신호**: "고객 리뷰에서 감정을 뽑아야" → Comprehend. "스캔한 서류의 표와 **필기**를 읽어야" → Textract(단순 OCR을 넘어 레이아웃·데이터까지). "업로드 이미지의 부적절 콘텐츠를 걸러야" → Rekognition **콘텐츠 검토**. "안내 음성을 만들어야" → Polly. "통화 녹음을 글로" → Transcribe.
- ⚠️ 모델을 **직접 학습·배포**해야 하는 요구라면 관리형 AI 서비스가 아니라 **SageMaker AI** 축입니다. 관리형 AI 서비스는 사전 학습된 기능을 API로 쓰는 쪽입니다.

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

## ⚠️ 흔한 함정 {#common-pitfalls}

1. **"RDS Multi-AZ DB 인스턴스 배포는 읽기 성능도 높여준다."** → 틀렸습니다. DB 인스턴스 배포의 스탠바이 인스턴스는 읽기 트래픽을 처리하지 않습니다. 읽기 확장이 필요하면 읽기 복제본 또는 Multi-AZ DB 클러스터를 검토합니다.
   (원리: §4 — Multi-AZ 스탠바이는 가용성 전용 설계로, 동기 복제와 단일 엔드포인트 페일오버가 목적이며 읽기 확장은 읽기 복제본의 역할이다.)

2. **"Multi-AZ가 부하를 분산한다."** → 부하 분산은 ELB(ALB/NLB)의 역할입니다. Multi-AZ는 가용성을 위한 이중화이지, 트래픽 분산 기능이 아닙니다.
   (원리: §3 — 표준 HA 구조에서 ALB가 트래픽 분산을, RDS Multi-AZ가 DB 가용성을 각각 전담하므로 한 레이어가 두 역할을 겸하지 않는다.)

3. **"ASG를 단일 AZ에 구성하면 고가용성이다."** → 단일 AZ ASG는 그 AZ 자체가 장애 나면 전멸합니다. 반드시 2개 이상 AZ에 분산해야 합니다.
   (원리: §2 — AZ 내 인스턴스를 아무리 늘려도 AZ 자체가 SPOF로 남으므로, SPOF 제거는 다중 AZ 분산이 전제 조건이다.)

4. **"EC2에 세션을 저장해도 ASG 환경에서 문제없다."** → ASG가 인스턴스를 교체하면 해당 인스턴스의 세션이 사라집니다. 세션은 외부 공유 스토어(ElastiCache/DynamoDB)에 두어야 합니다.
   (원리: §8 — 스테이트리스 설계가 ASG 자가 복구의 전제 조건이라, 상태를 인스턴스에 두면 교체가 사용자에게 단절로 나타난다.)

5. **"읽기 복제본은 자동으로 페일오버된다."** → 읽기 복제본은 자동 페일오버가 없습니다. 수동 승격(promote)이 필요합니다. 자동 페일오버는 RDS Multi-AZ의 기능입니다.
   (원리: §5 — 비동기 복제 구조에서는 데이터 유실 가능성을 운영자가 확인해야 하므로, 자동 전환을 허용하지 않고 수동 승격을 요구한다.)

6. **"NAT 게이트웨이 1개로 전체 VPC를 커버하면 된다."** → NAT 게이트웨이가 있는 AZ에 장애가 나면 다른 AZ의 프라이빗 서브넷이 인터넷에 나갈 수 없습니다. AZ마다 NAT 게이트웨이를 배치해야 합니다.
   (원리: §7 — 정적 안정성 원칙에 따라 장애 중 동적 조달 없이 각 AZ가 독립 동작하려면 NAT 게이트웨이도 AZ마다 사전 배치돼야 한다.)

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

DB 인스턴스 배포 기준으로는 아닙니다. RDS Multi-AZ DB 인스턴스 배포의 스탠바이 인스턴스는 읽기 트래픽을 처리하지 않습니다. 스탠바이는 오직 동기 복제 및 페일오버 대기 목적으로만 존재합니다. 읽기 성능 향상이 필요하면 읽기 복제본(Read Replica) 또는 Multi-AZ DB 클러스터를 별도로 검토해야 합니다.
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

**DB 인스턴스 배포의 설계 목적이 가용성 전용이기 때문입니다.** RDS Multi-AZ DB 인스턴스 배포의 스탠바이는 동기 복제로 Primary와 항상 동일한 데이터를 유지하며, 단일 DNS 엔드포인트를 통해 페일오버 시 투명하게 Primary로 전환됩니다. AWS는 이 스탠바이를 읽기 트래픽 없이 페일오버 대기 전용으로 설계함으로써 가용성 보장에 집중하며, 읽기 확장이 필요하면 읽기 복제본이나 읽기 가능한 스탠바이를 제공하는 Multi-AZ DB 클러스터를 별도로 사용합니다.
</details>

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. (작성·대조: 2026-06-07, WebFetch 200 확인 · 고도화 검수: 2026-06-12)

1. AWS Well-Architected Framework — Reliability Pillar — https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/welcome.html
2. RDS Multi-AZ DB 인스턴스 배포 — https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.MultiAZSingleStandby.html
3. RDS Multi-AZ 배포 구성 및 관리 — https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.MultiAZ.html
4. Route 53 헬스 체크 생성 — https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/dns-failover.html
5. SAA-C03 공식 시험 가이드 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
6. Aurora 고가용성(6개 스토리지 노드 동기 복제·AZ별 사본·복제본 최대 15·장애 조치 **통상 60초 미만·흔히 30초 미만**·클러스터 엔드포인트·재시작이 더 빠름) — https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Concepts.AuroraHighAvailability.html
7. DynamoDB 글로벌 테이블 동작(MREC 기본·통상 1초 / MRSC 동기 복제·**정확히 3개 리전**·복제본 3 또는 2+증인·증인은 읽기/쓰기 불가·일부 리전만) — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/V2globaltables_HowItWorks.html
8. Route 53 라우팅 정책 선택 — **8종**(단순·장애 조치·가중·지연 시간·지리적 위치·지리 근접·IP 기반·멀티값 응답) — https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy.html
9. Route 53 헬스 체크 판정(간격 10/30초·**18% 규칙**·HTTP TCP 4초·응답 2초·**HTTPS는 인증서 미검증**·체커 비조율) — https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/dns-failover-determining-health-of-endpoints.html
10. 멀티값 응답 라우팅(최대 8개 정상 레코드·전부 비정상이면 최대 8개 비정상 반환·헬스 체크 미연결은 정상 간주·LB 대체 아님) — https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy-multivalue.html
11. 재시도 제어·제한 — Well-Architected `REL05-BP03`(재시도 폭풍·지수 백오프·지터·최대 캡·하위 서비스 0~1회·"백오프 존재를 가정하지 말라"·위험 High) — https://docs.aws.amazon.com/wellarchitected/2022-03-31/framework/rel_mitigate_interaction_failure_limit_retries.html
12. 회로 차단기 패턴(CLOSED·OPEN·HALF_OPEN·서비스 비의존 구현·다중 스레드 타임아웃·강제 open/close·로깅) — https://docs.aws.amazon.com/prescriptive-guidance/latest/cloud-design-patterns/circuit-breaker.html
13. X-Ray 트레이스 맵(서비스·업스트림·다운스트림 노드·SQS/Lambda 연결 뷰·교차 계정·노드 색 = 500/400/429) — https://docs.aws.amazon.com/xray/latest/devguide/xray-console-servicemap.html
14. Service Quotas 요청 템플릿(기본/적용 쿼터·CloudWatch 경보·all features 필요·최대 10개·**기존 계정 미소급**·상업 리전만) — https://docs.aws.amazon.com/servicequotas/latest/userguide/organization-templates.html
15. RDS Multi-AZ DB 클러스터(읽기 가능 스탠바이 2·장애 조치 통상 35초 미만·커밋 지연 최대 2배 빠름) — https://aws.amazon.com/blogs/database/is-amazon-rds-for-postgresql-or-amazon-aurora-postgresql-a-better-choice-for-me/
16. 관리형 AI 서비스 선택(양식별 용도 — Comprehend·Lex·Translate·Textract·Rekognition·Transcribe·Polly) — https://repost.aws/articles/ARg2nreO9URO2VyMnRKOt3ZA/building-a-decision-framework-to-select-the-right-aws-ml-service-for-your-workload

> 📝 **2026-10-21 보강(갭 `G-2.2-01`·`02`·`04`·`05`·`07`·`08`·`09`, 배치 B6)**: **§9~§14를 신설**했습니다 — ① **§9** 가용성 %↔연간 중단 환산(산술 계산값)과 **SLA vs 설계 목표 구분**. ② **§10** Aurora 6사본·장애 조치 **통상 60초 미만·흔히 30초 미만**·Multi-AZ 클러스터·DynamoDB **MREC/MRSC**(근거 6·7·15번). ③ **§11** 라우팅 정책 8종·**18% 규칙**·**HTTPS 인증서 미검증**(근거 8·9·10번). ④ **§12** 백오프·지터·재시도 제한·회로 차단기 3상태(근거 11·12번). ⑤ **§13** X-Ray·Service Quotas 템플릿(근거 13·14번). ⑥ **§14** in-scope 관리형 AI 서비스(근거 16번).
>
> **쓰지 않은 것:** 서비스별 **SLA 퍼센트**(개정·구성 의존이라 암기 대상이 아니고 `99-gaps` V-13 계열) · **RDS Proxy 장애 조치 단축 66%**(V-14 미확인). `G-2.2-04`는 공식 문구가 AMS와 AI 서비스를 섞어 모호해(`99-gaps` C-18) **in-scope 목록 기준으로 좁혀** 적고 AMS에 대한 주장은 하지 않았습니다. 기존 §1~§8의 번호·앵커는 바꾸지 않았습니다.

