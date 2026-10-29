---
examGuideTaskId: saa-t2-5
certCode: SAA-C03
domain: 2
domainName: 복원력을 갖춘 아키텍처 설계
domainWeightPct: 26
title: DR 전략 — RTO·RPO·Pilot Light·Warm Standby·Active-Active
coversTasks:
  - "2.2"
sources:
  - title: 클라우드의 재해 복구 옵션 — AWS 백서 (공식)
    url: https://docs.aws.amazon.com/whitepapers/latest/disaster-recovery-workloads-on-aws/disaster-recovery-options-in-the-cloud.html
  - title: DynamoDB 글로벌 테이블(MREC·MRSC 일관성 모드) (공식)
    url: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/GlobalTables.html
  - title: AWS Elastic Disaster Recovery란? (공식)
    url: https://docs.aws.amazon.com/drs/latest/userguide/what-is-drs.html
  - title: 신뢰성 기둥 — AWS Well-Architected Framework (공식)
    url: https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/welcome.html
  - title: SAA-C03 공식 시험 가이드 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
lastVerified: 2026-10-19
---

# DR 전략 — RTO·RPO·Pilot Light·Warm Standby·Active-Active

> **커버하는 공식 Task** — SAA-C03 · 도메인 2 「복원력을 갖춘 아키텍처 설계」(26%) · **Task 2.2 재해 복구(DR) 솔루션 설계** (`saa-t2-5`)
> 이 문서는 위 한 Task에 1:1로 매핑됩니다.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명할 수 있어야 합니다. (공식 시험 가이드 Task 2.2의 Skill 항목 기반)

- [ ] **RTO와 RPO를 구분**하고, 각 지표가 전략 선택에 어떻게 연결되는지 설명할 수 있다
- [ ] **4가지 DR 전략**(Backup & Restore · Pilot Light · Warm Standby · Multi-Site Active-Active)을 비용·복구속도 축에서 순서대로 나열할 수 있다
- [ ] **Pilot Light와 Warm Standby의 차이**를 "무엇이 상시 가동되는가"로 명확히 구분할 수 있다
- [ ] **리전 간 데이터 복제 수단**(S3 CRR, RDS 교차 리전 Read Replica, Aurora Global Database)을 상황별로 선택할 수 있다
- [ ] **Route 53 페일오버**가 자동 트래픽 전환에 어떻게 사용되는지 설명할 수 있다
- [ ] **AWS Elastic Disaster Recovery(DRS)**의 역할과 어떤 DR 전략을 사용하는지 안다

---

## 🎯 왜 중요한가

- 도메인 2(26%)는 SAA 시험 비중 2위입니다. Task 2.2는 "주어진 RTO·RPO 수치 → 가장 적합한 전략"을 고르는 문제 유형이 반복 출제됩니다.
- 4가지 전략은 비용과 복구속도 사이의 트레이드오프로 연결됩니다. 전략의 순서(저비용·느림 → 고비용·빠름)와 핵심 차별점을 외우면 대부분의 문제를 풀 수 있습니다.
- Pilot Light와 Warm Standby는 공식 백서에서도 "구분이 어렵다"고 언급할 만큼 단골 혼동 포인트입니다. "즉시 처리 가능한가"가 핵심 구분선입니다.

---

## 🔤 먼저 알아야 할 용어

이 문서를 읽는 데 필요한 기초 용어입니다. 이미 알면 건너뛰세요.

| 용어 | 영문 | 한 줄 풀이 |
|---|---|---|
| **복구 시간 목표** | RTO (Recovery Time Objective) | 재해 발생 후 서비스를 재개하기까지 허용되는 최대 다운타임 |
| **복구 시점 목표** | RPO (Recovery Point Objective) | 재해 발생 시 손실을 허용할 수 있는 최대 데이터 시간 구간 |
| **파일럿 라이트** | Pilot Light | 핵심 데이터 레이어만 상시 복제하고 앱 서버는 꺼둔 DR 전략 |
| **웜 스탠바이** | Warm Standby | 축소판 전체 스택을 상시 가동해 재해 시 즉시 트래픽 처리 가능한 DR 전략 |
| **액티브-액티브** | Active-Active | 여러 리전에서 동시에 프로덕션 트래픽을 처리해 RTO/RPO를 0에 근접시키는 전략 |
| **교차 리전 복제** | Cross-Region Replication (CRR) | S3 버킷 간 객체를 다른 리전으로 비동기 복제하는 기능 |
| **스테이징 영역** | Staging Area | DRS가 최소 비용으로 블록 레벨 복제본을 상시 유지하는 대기 컴퓨팅 공간 |
| **페일백** | Failback | DR 전환 후 원본 사이트가 복구되면 다시 원본으로 트래픽을 되돌리는 절차 |

---

## 📖 핵심 개념 {#core-concepts}

### 1) RTO와 RPO 정의 {#rto-rpo}

| 지표 | 전체 이름 | 의미 | 핵심 질문 |
|---|---|---|---|
| **RTO** | Recovery Time Objective | 재해 발생 후 **얼마나 빨리 서비스를 복구**해야 하는가 | "허용 가능한 다운타임은?" |
| **RPO** | Recovery Point Objective | 재해 발생 시 **얼마만큼의 데이터 손실**을 허용할 수 있는가 | "마지막 백업 이후 잃어도 되는 시간은?" |

> RTO와 RPO가 **0에 가까울수록** 고비용 전략이 필요합니다. 반대로 수 시간의 다운타임·데이터 손실을 허용할 수 있으면 저비용 전략으로 충분합니다.

> 🧠 원리: 왜 DR 요건은 "다운타임"과 "데이터 손실" 두 지표를 따로 측정할까요?
> 다운타임 비용(매출 손실·SLA 위약금)과 데이터 손실 비용(거래 취소·규제 벌금)은 업종마다 다른 비율로 발생해, 하나의 숫자로 합산하면 어느 쪽 투자가 부족한지 진단하기 어렵습니다.
> RTO를 낮추려면 컴퓨팅·네트워크를 미리 준비해야 하고, RPO를 낮추려면 복제 빈도·일관성을 높여야 하므로 두 목표는 독립된 기술 투자를 요구합니다.
> 지표를 분리해야 "앱 서버는 1시간 후 복구해도 되지만 결제 DB는 1분 데이터도 잃으면 안 된다" 같은 서비스별 비대칭 DR 설계가 가능합니다.

### 2) 4가지 DR 전략 비교 (★ 단골 출제) {#dr-strategies}

| 전략 | 상시 운영 구성 | RTO | RPO | 상대 비용 | 핵심 특징 |
|---|---|---|---|---|---|
| **Backup & Restore** | 백업 데이터만 보관 | **24시간 이하** | **시간 단위** | 최저 | 재해 시 인프라·앱·데이터 모두 새로 배포 |
| **Pilot Light** | 핵심 DB/데이터만 상시 복제, 앱 서버는 꺼둠 | **수십 분** | **분 단위** | 낮음~중 | 재해 시 꺼진 서버를 기동·확장 |
| **Warm Standby** | 축소판 전체 스택 상시 가동 | **분 단위** | **초 단위** | 중~높음 | 재해 시 용량만 확장, 즉시 트래픽 처리 가능 |
| **Multi-Site Active-Active** | 여러 리전에서 동시 프로덕션 운영 | 거의 0 | 거의 0 | 최고 | 페일오버 개념 없음, 트래픽이 자동 우회 |

> **위 수치는 Well-Architected 신뢰성 기둥 REL13-BP02의 공식 값입니다.** 공식 문서는 네 전략을 "비용과 복잡도가 커지는 순서, RTO·RPO가 줄어드는 순서"로 나열하며 Backup & Restore는 RPO 시간 단위·RTO 24시간 이하, Pilot Light는 RPO 분 단위·RTO 수십 분, Warm Standby는 RPO 초 단위·RTO 분 단위, 다중 리전 활성-활성은 RPO 거의 0·RTO 사실상 0으로 적습니다. **시험은 이 네 묶음 중 어디에 해당하는지를 RTO·RPO 숫자로 묻습니다.**
>
> 단, Backup & Restore라도 **특정 시점 복구(PITR)** 를 쓰면 경우에 따라 RPO를 5분까지 낮출 수 있습니다 — "백업 주기가 곧 RPO"라고 단정하지 않는 쪽이 공식 서술에 가깝습니다.

비용 ↔ 복구속도 스펙트럼:

```
저비용 / 느린 복구 ─────────────────────────► 고비용 / 빠른 복구
Backup & Restore → Pilot Light → Warm Standby → Multi-Site Active-Active
```

> 🧠 원리: 왜 4가지 DR 전략은 비용과 복구속도 사이의 연속 스펙트럼을 이룰까요?
> 각 전략의 차이는 "재해 발생 전에 얼마나 많은 인프라를 상시 가동 상태로 두는가"의 차이이며, 미리 준비한 용량이 많을수록 복구 단계에서 새로 프로비저닝할 일이 줄어듭니다.
> Backup & Restore는 데이터만 보관하므로 재해 시 인프라 전체를 새로 만들어야 해 복구가 가장 느리고, Active-Active는 이미 전체 용량이 여러 리전에서 동작 중이라 전환 자체가 불필요합니다.
> 이 연속성 덕분에 RTO/RPO 수치와 예산을 대입하면 과잉 투자 없이 가장 경제적인 전략을 선택할 수 있습니다.

### 3) Pilot Light vs Warm Standby — 핵심 구분 (★ 혼동 주의) {#pilot-light-vs-warm-standby}

공식 백서 설명: "Pilot Light는 추가 조치 없이 요청을 처리할 수 없으나, Warm Standby는 즉시(축소 용량으로) 트래픽을 처리할 수 있다."

| 비교 항목 | Pilot Light | Warm Standby |
|---|---|---|
| **상시 가동 범위** | 핵심 데이터(DB)만 | 축소판 전체 스택 (앱+DB) |
| **재해 시 조치** | 서버 기동 + 확장 | 용량 확장만 |
| **즉시 트래픽 처리** | 불가 (서버 기동 필요) | 가능 (축소 용량으로) |
| **RTO** | 더 큼 | 더 작음 |
| **비용** | 더 저렴 | 더 비쌈 |

> 🧠 원리: 왜 Pilot Light는 앱 서버를 꺼두면서 DB 레이어만 상시 복제하는 구성을 선택할까요?
> 앱 서버는 AMI·시작 템플릿·Auto Scaling 설정이 있으면 재해 시 수십 분 안에 새로 기동할 수 있지만, DB의 데이터 자체는 사전 복제 없이는 재해 시점까지 축적된 내용을 빠르게 따라잡을 수 없습니다.
> DB 데이터를 처음부터 전송하면 수십 GB~수 TB 규모에서 시간이 수 시간 이상 걸리므로, 앱은 꺼두되 DB 복제는 상시 유지해야만 RTO를 수십 분 수준으로 유지할 수 있습니다.
> 이 비대칭 구성이 Pilot Light의 핵심 비용 절감 논리이며, Warm Standby처럼 앱 서버까지 상시 가동하지 않아도 되는 이유입니다.

### 4) 리전 간 데이터 복제 수단 {#cross-region-replication}

| 대상 | 수단 | 특징 |
|---|---|---|
| S3 | Cross-Region Replication (CRR) | 비동기 연속 복제, 원본·대상 버킷 버전 관리 필수 |
| RDS | 교차 리전 Read Replica | 비동기, 페일오버 시 Primary로 승격 필요 |
| Aurora | **Global Database** | 전용 인프라, 보조 리전 복제 지연 **1초 미만**, 장애 시 1분 내 승격 |
| DynamoDB | Global Tables | 멀티 리전 읽기·쓰기. 생성 시 일관성 모드 선택 — **MREC**(멀티 리전 최종 일관성, 기본) 또는 **MRSC**(멀티 리전 강한 일관성, 동일 계정 구성만). 생성 후 변경 불가 |
| 통합 백업 | **AWS Backup** | 다중 서비스·리전·계정, 정책 기반 중앙 관리 |

> Aurora Global Database는 RPO를 가장 낮추고 싶을 때 최선택입니다. "리전 간 1초 미만 복제"가 시험 문구로 자주 등장합니다.

> 🧠 원리: 왜 리전 간 데이터 복제는 대부분 비동기 방식을 사용할까요?
> 두 리전 사이의 물리적 거리로 인해 네트워크 왕복 지연이 상당하며, 동기 복제는 모든 쓰기 작업이 보조 리전의 확인 응답을 기다려야 하므로 쓰기마다 그 지연이 추가됩니다.
> 이 지연이 데이터베이스 트랜잭션에 누적되면 애플리케이션 응답시간이 허용 수준을 넘어 사실상 프로덕션 사용이 어려워집니다.
> 따라서 리전 간 복제는 비동기를 기본으로 하고, Aurora Global Database처럼 전용 복제 인프라로 지연을 최소화하는 방식이 RPO 최소화의 현실적 상한선이 됩니다.

### 5) 페일오버 자동화 — Route 53 {#route53-failover}

Route 53은 Pilot Light / Warm Standby / Active-Active 모두에서 트래픽 전환에 사용됩니다.

- **Failover 라우팅 정책**: 기본(Primary) 엔드포인트에 헬스 체크를 설정하고, 장애 감지 시 보조(Secondary) 엔드포인트로 자동 전환
- **헬스 체크**: 데이터 플레인 작업으로 동작 — 고가용성
- **AWS Global Accelerator**: AnyCast IP 기반, 엣지 네트워크를 통한 더 낮은 지연시간, DNS 캐싱 문제 없음 (Route 53의 대안)
- **Amazon Application Recovery Controller (ARC)**: 아래 표처럼 AZ 단위·리전 단위 복구 기능을 묶어 제공합니다

**ARC의 기능 구분 (★ 어느 층의 장애인가)**

| 기능 | 층 | 하는 일 | 요금 |
|---|---|---|---|
| **zonal shift** | 다중 AZ | 성능이 나빠진 AZ에서 트래픽을 **직접** 빼냅니다 | 지원 리소스에는 **추가 요금 없음** |
| **zonal autoshift** | 다중 AZ | AWS가 **대신** 트래픽 이동을 시작합니다 | 지원 리소스에는 **추가 요금 없음** |
| **Region switch** | 다중 리전 | 리전 전환 계획을 만들어 실행합니다 | **별도 요금** |
| **routing control** | 다중 리전 | 리전 간 트래픽 전환을 on/off 스위치로 제어합니다 | **별도 요금** |
| **readiness check** | 감시 | 복구 대상이 전환을 받을 준비가 됐는지 점검합니다 | — |

- **zonal shift는 임시 완화책입니다.** 시작할 때 만료 시각을 **1분부터 최대 3일(72시간)** 사이로 정하며 연장할 수 있지만, 영구 구성이 아닙니다. 리소스를 옵트인해야 쓸 수 있습니다.
- ⚠️ **사전 용량 확보가 전제입니다.** 한 AZ를 빼면 남은 AZ가 그 몫을 받아야 하므로, 애플리케이션을 미리 **사전 확장(prescale)** 해 충분한 용량을 갖춰 두지 않으면 트래픽 이동이 오히려 장애를 키웁니다.
- 시험 신호: "AZ 하나의 성능 저하를 빠르게 우회" → zonal shift(또는 autoshift). "리전 전체를 전환" → Region switch·routing control.

> 🧠 원리: 왜 Route 53 헬스 체크는 데이터 플레인에서 동작해야 DR 신뢰성이 높아질까요?
> 대규모 장애 시 AWS 제어 플레인(API, Auto Scaling 등)이 부하를 받아 응답이 느려질 수 있는데, 헬스 체크가 제어 플레인에 의존하면 장애 감지 자체가 실패할 수 있습니다.
> Route 53 헬스 체크는 분산된 글로벌 체커 네트워크가 엔드포인트에 직접 HTTP/TCP 요청을 보내는 데이터 플레인 동작이므로, 제어 플레인 장애와 독립적으로 동작합니다.
> 이 설계 덕분에 가장 장애가 심각한 상황에서도 DNS 페일오버 전환이 제어 플레인 가용성에 영향받지 않습니다.

### 6) 동기 복제 vs 비동기 복제 {#sync-vs-async-replication}

| 복제 방식 | RPO | 성능 영향 | 사용 예 |
|---|---|---|---|
| **동기(Synchronous)** | 거의 0 (데이터 손실 없음) | 레이턴시 증가 가능 | 같은 리전 내 Multi-AZ(RDS Multi-AZ) |
| **비동기(Asynchronous)** | 복제 지연만큼의 손실 가능 | 성능 영향 최소 | 교차 리전 복제(CRR, Aurora Global DB 보조 클러스터) |

> RDS Multi-AZ는 같은 리전 내 **동기** 복제(AZ 장애 대응), 교차 리전 Read Replica는 **비동기** 복제(리전 장애 대응).

> 🧠 원리: 왜 동기 복제는 같은 리전 내 AZ 간에는 실용적이지만 리전 간에는 잘 쓰지 않을까요?
> 같은 리전의 AZ 간 왕복 지연은 충분히 짧아 동기 복제로 인한 쓰기 지연이 애플리케이션에서 체감되지 않는 수준입니다.
> 반면 리전 간 왕복 지연은 물리적 거리로 인해 상당히 크며, 동기 복제를 강제하면 모든 DB 쓰기가 그 지연을 기다려야 해 초당 처리량이 급감합니다.
> 이 물리적 한계가 "같은 리전 = 동기(RDS Multi-AZ), 리전 간 = 비동기(Read Replica/Aurora Global DB)"라는 복제 방식 이분법의 근거입니다.

### 7) AWS Elastic Disaster Recovery (DRS) {#aws-drs}

> 공식 정의: "저렴한 스토리지와 최소한의 컴퓨팅으로 온프레미스 및 클라우드 기반 애플리케이션의 다운타임과 데이터 손실을 최소화하는 서비스."

- **블록 레벨 복제**: 서버 OS·앱·DB를 통째로 AWS로 지속 복제
- **스테이징 영역**: 저비용 스토리지+최소 컴퓨팅으로 상시 유지 — **Pilot Light 전략** 사용
- **페일오버 시**: 스테이징 리소스로 AWS 내 전체 용량 인스턴스를 수 분 안에 자동 생성
- **대상**: 온프레미스 서버 또는 EC2 기반 앱(RDS 제외). 타 클라우드 → AWS 이전 DR에도 활용 가능
- **복원**: 문제 해결 후 원본 사이트로 페일백(Failback) 지원

> 🧠 원리: 왜 DRS는 파일 레벨이나 애플리케이션 레벨이 아닌 블록 레벨 복제를 사용할까요?
> 블록 레벨 복제는 OS와 파일시스템 종류에 상관없이 디스크에 쓰이는 모든 변경을 그대로 캡처하므로, DB 트랜잭션 로그·임시 파일·시스템 파일을 포함한 서버 전체 상태를 빠짐없이 복제합니다.
> 파일 레벨 복제는 열려 있는 DB 파일처럼 잠긴 상태의 파일을 일관되게 캡처하기 어렵고, 애플리케이션 레벨 복제는 에이전트가 각 앱을 별도로 지원해야 해 이기종 환경에서 관리 부담이 큽니다.
> 이 OS 중립적 특성 덕분에 DRS는 온프레미스 Windows·Linux 서버와 타 클라우드 EC2를 추가 에이전트 없이 단일 방식으로 AWS에 복제할 수 있습니다.

### 8) 전략을 실제로 작동시키는 것 — 쿼터·테스트·페일백 {#dr-operations}

전략을 고르는 것만으로 DR이 끝나지 않습니다. 공식 문서가 "계획하고 구현하고 **시험까지 마친** DR 전략"을 요구하는 이유가 여기 있습니다.

**대기 리전의 Service Quotas (★ 잘 안 보이는 실패 원인)**

대기 리전은 복구할 때까지 **축소 용량**으로 돌아가는 일이 많습니다. 그래서 활성 리전에서 수요가 커질 때마다 한도를 올려 두면서 **대기 리전에는 같은 증액을 요청하지 않는** 일이 생깁니다.

- 쿼터는 **계정과 리전 단위**로 적용되므로, 활성 리전에서만 올린 한도는 대기 리전에 전혀 영향이 없습니다.
- 이 간격은 평소에 드러나지 않습니다. 계획이 멀쩡해 보이다가 **실제 전환 때** 대기 리전이 필요한 만큼의 리소스를 띄우지 못해 실패합니다.
- ARC의 **Region switch**는 계획의 컴퓨팅·데이터베이스 리소스에 대해 **서비스 쿼터를 점검**하고, 양쪽 리전의 한도가 다르면 낮은 쪽을 높은 쪽에 맞추는 증액 요청을 낼 수 있습니다. 다만 쿼터 경고가 계획 실행 자체를 막아 주지는 않으므로, 경고를 무시하면 실행이 실패할 수 있습니다.

**페일백 — 돌아오는 계획도 함께 만든다**

**페일백**은 워크로드 운영을 원래의 주 리전으로 되돌리는 것입니다. 공식 문서는 페일오버만이 아니라 **페일백 방법까지 설계하라**고 적고, 그 절차를 팀 전원이 볼 수 있는 **플레이북**에 담아 주기적으로 검토하라고 적습니다.

- 돌아갈 때는 그동안 대기 리전에 쌓인 변경을 주 리전으로 되돌려야 하므로, 복제 방향을 바꾸는 절차가 계획에 들어가야 합니다.
- 공통 복구 전략을 정해 두면 같은 도구와 **같은 시험 절차**를 재사용할 수 있다는 것이 공식 문서가 전략 표준화를 권하는 이유입니다.

> 🧠 원리: 왜 대기 리전의 쿼터 부족은 **평소에 전혀 드러나지 않을까요**?
> 대기 리전은 복구에 들어갈 때까지 축소 용량으로 돌기 때문에 실제 사용량이 한도 근처에 가지 않고, 그래서 경보로 잡힐 신호 자체가 생기지 않습니다.
> 게다가 쿼터는 계정과 리전 단위로 적용되므로, 활성 리전에서 수요에 맞춰 올려 온 한도가 대기 리전에는 아무 영향을 주지 않습니다.
> 결국 부족은 평상시 지표가 아니라 전환을 실제로 실행하는 순간에 드러나고 그때는 되돌릴 시간이 없으므로, 사전 점검을 계획 안에 넣는 것이 유일한 방어입니다.

---

## ✍️ 시험 포인트

| 시나리오 문구 | 정답 전략 또는 서비스 |
|---|---|
| 비용 최소, 복구 느려도 됨 | **Backup & Restore** |
| 핵심 DB만 켜두고 재해 시 앱 기동 | **Pilot Light** |
| 축소판 전체 스택 상시 가동, 빠른 복구 | **Warm Standby** |
| RTO/RPO 거의 0 | **Multi-Site Active-Active** |
| 리전 간 1초 미만 DB 복제 | **Aurora Global Database** |
| 헬스 체크 기반 자동 트래픽 전환 | **Route 53 Failover** |
| 온프레미스 서버 → AWS DR | **AWS Elastic Disaster Recovery (DRS)** |
| 다중 서비스·리전 백업 중앙 관리 | **AWS Backup** |
| 데이터 손실 허용치 = 0 | RPO=0 → 동기 복제 또는 Active-Active |

---

## ⚠️ 흔한 함정 {#common-pitfalls}

1. **"RTO/RPO가 엄격하면 무조건 Active-Active."** → Active-Active는 가장 비쌉니다. RTO 수 분 허용 + 비용 제약이 있으면 Warm Standby가 더 적합합니다.
   (원리: §2 — 각 전략은 미리 가동 중인 용량 범위로 비용과 복구속도가 결정되므로, 요구 RTO/RPO를 충족하는 최소 비용 전략을 선택해야 한다.)

2. **"Pilot Light = Warm Standby."** → 가장 빈번한 혼동입니다. Pilot Light는 앱 서버가 꺼져 있어 재해 시 기동 시간이 필요합니다. Warm Standby는 이미 실행 중이므로 즉시 트래픽을 받을 수 있습니다.
   (원리: §3 — Pilot Light가 DB만 상시 복제하는 이유는 앱은 기동 가능하지만 데이터는 사전 복제 없이 복구 불가이기 때문이다.)

3. **"RDS Multi-AZ와 교차 리전 Read Replica는 같다."** → Multi-AZ는 동일 리전 내 동기 복제(AZ 장애 대응), Read Replica는 비동기 교차 리전 복제(리전 장애 DR). 목적과 복제 방식이 다릅니다.
   (원리: §6 — AZ 간 왕복 지연은 짧아 동기 복제가 실용적이고, 리전 간 왕복 지연은 물리적으로 커서 비동기가 불가피하다.)

4. **"RPO=0이면 Backup & Restore로 된다."** → Backup & Restore는 RPO가 마지막 백업 이후(수 시간)입니다. RPO 0 요구에는 동기 복제 또는 Active-Active가 필요합니다.
   (원리: §1 — RPO는 복구 가능한 가장 최근 시점까지의 거리이며, 백업 주기만큼 반드시 손실이 발생한다.)

5. **"AWS DRS는 RDS 관리형 DB에도 사용한다."** → DRS는 서버 기반(EC2) 앱과 DB에만 적용됩니다. RDS 같은 관리형 서비스는 교차 리전 Read Replica·Aurora Global Database를 사용합니다.
   (원리: §7 — DRS의 블록 레벨 복제는 OS가 직접 관리하는 디스크를 대상으로 하므로, AWS가 스토리지를 추상화한 관리형 서비스에는 접근 경로가 없다.)

6. **"Route 53 페일오버는 즉각적이다."** → DNS TTL만큼의 전파 지연이 있습니다. AWS Global Accelerator는 DNS 캐싱 문제가 없어 더 빠른 전환이 가능합니다.
   (원리: §5 — Route 53은 헬스 체크 감지 자체는 빠르지만 클라이언트 DNS 캐시가 TTL 동안 이전 IP를 유지해 전환이 지연되며, Global Accelerator는 AnyCast로 이 계층을 우회한다.)

---

## 🧪 자가 점검

> 아래는 학습용 자가 점검입니다. (정식 검증 문항은 별도 문항 파일 참조)

**Q1.** 전자상거래 회사가 장애 시 최대 4시간의 다운타임과 1시간의 데이터 손실을 허용할 수 있습니다. 비용을 최소화하는 DR 전략은?

<details><summary>정답 보기</summary>

**Backup & Restore**입니다. RTO 4시간·RPO 1시간이면 백업만 보관하다가 재해 시 복원하는 방식으로 충분합니다. 4가지 전략 중 비용이 가장 낮으며, 1시간마다 백업을 수행하면 RPO 1시간 목표도 달성 가능합니다. Pilot Light 이상은 상시 운영 비용이 발생하므로 과잉 투자입니다.
</details>

**Q2.** 금융 서비스 회사가 리전 장애 시 RTO 15분, RPO 1분을 요구합니다. 비용 효율적인 전략과 Aurora DB 복제 수단은?

<details><summary>정답 보기</summary>

전략은 **Warm Standby**가 적합합니다. RTO 15분은 Pilot Light(서버 기동 포함)로는 빠듯하고, Active-Active는 불필요하게 비쌉니다. Warm Standby는 축소판 스택이 상시 가동 중이므로 빠른 확장으로 15분 이내 복구가 가능합니다. DB는 **Aurora Global Database**를 사용합니다. 전용 인프라로 보조 리전 복제 지연이 1초 미만이므로 RPO 1분을 충족하며, 장애 시 1분 내 보조 리전을 Primary로 승격할 수 있습니다.
</details>

**Q3.** 회사가 온프레미스 서버에서 실행 중인 애플리케이션의 DR을 AWS에 구성하려 합니다. 서버 단위로 지속 복제하고 수 분 내 AWS에서 기동할 수 있는 서비스는?

<details><summary>정답 보기</summary>

**AWS Elastic Disaster Recovery (DRS)**입니다. DRS는 온프레미스 서버를 블록 레벨로 지속 복제하여 AWS의 스테이징 영역에 유지합니다. 페일오버 이벤트 시 스테이징 리소스를 사용해 AWS에서 수 분 안에 전체 용량 인스턴스를 자동 생성합니다. Pilot Light 전략을 기반으로 하되, 수동 인프라 구성 없이 관리형으로 제공합니다.
</details>

**Q4.** Pilot Light와 Warm Standby 중 "재해 발생 직후 즉시 트래픽을 받을 수 있는" 전략은 무엇이며, 그 이유는?

<details><summary>정답 보기</summary>

**Warm Standby**입니다. Warm Standby는 축소판 전체 스택(앱+DB)이 상시 실행 중이므로 재해 발생 직후 축소된 용량으로 즉시 트래픽을 처리할 수 있습니다. 이후 Auto Scaling 등으로 용량을 확장합니다. Pilot Light는 핵심 DB만 복제되고 앱 서버는 꺼져 있어 재해 시 서버를 기동·배포하는 추가 시간이 필요하므로 즉시 트래픽 처리가 불가합니다.
</details>

**Q5 (원리).** 왜 Aurora Global Database는 교차 리전 복제에서 일반 RDS Read Replica보다 RPO 달성에 유리한가요?

<details><summary>정답 보기</summary>

Aurora Global Database는 전용 복제 인프라를 사용해 보조 리전 복제 지연을 최소화합니다. 일반 RDS Read Replica는 비동기 복제 특성상 복제 지연이 발생할 수 있으며, 복제 지연 동안 Primary에 쓰인 데이터가 보조 리전에 반영되지 않아 해당 구간이 RPO 손실로 이어집니다. 복제 지연이 짧을수록 페일오버 시점의 RPO가 작아지므로, Aurora Global Database가 엄격한 RPO 요구 환경에서 RDS Read Replica보다 유리합니다.
</details>

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. (작성·대조: 2026-06-07 · 고도화 검수: 2026-06-12)

1. 클라우드의 재해 복구 옵션 — AWS 백서 — https://docs.aws.amazon.com/whitepapers/latest/disaster-recovery-workloads-on-aws/disaster-recovery-options-in-the-cloud.html
2. AWS Elastic Disaster Recovery란? — https://docs.aws.amazon.com/drs/latest/userguide/what-is-drs.html
3. 신뢰성 기둥 — AWS Well-Architected Framework — https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/welcome.html
4. DynamoDB 글로벌 테이블("Global tables support two consistency modes: multi-Region eventual consistency (MREC) and multi-Region strong consistency (MRSC)") — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/GlobalTables.html
5. SAA-C03 공식 시험 가이드 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html

6. REL13-BP02 재해 복구 계획(전략별 RPO·RTO 공식 수치·페일백 설계·플레이북) — https://docs.aws.amazon.com/wellarchitected/2025-02-25/framework/rel_planning_for_recovery_disaster_recovery.html
7. ARC란?(다중 AZ = zonal shift·zonal autoshift / 다중 리전 = Region switch·routing control + readiness check) — https://docs.aws.amazon.com/r53recovery/latest/dg/what-is-route53-recovery.html
8. ARC zonal shift(임시 완화·1분~3일(72시간)·사전 확장 요건·리소스 옵트인) — https://docs.aws.amazon.com/r53recovery/latest/dg/arc-zonal-shift.html
9. ARC 기능 비교(zonal shift·autoshift = 추가 요금 없음 / routing control·Region switch = 별도 요금) — https://docs.aws.amazon.com/r53recovery/latest/dg/compare-capabilities.html
10. Region switch의 서비스 쿼터 점검(대기 리전 축소 용량·쿼터는 계정·리전 단위·경고가 실행을 막지 않음) — https://docs.aws.amazon.com/r53recovery/latest/dg/working-with-rs-service-quota-checks.html

> 📝 **2026-10-30 보강(갭 배치 B11)**: ① §2의 RTO·RPO 칸을 **REL13-BP02 공식 수치**로 바꿨습니다(B&R RTO 24시간 이하·RPO 시간 단위 / Pilot Light RTO 수십 분·RPO 분 단위 / Warm Standby RTO 분 단위·RPO 초 단위). PITR로 B&R의 RPO를 5분까지 낮출 수 있다는 단서도 함께 적었습니다(근거 6번). ② §5의 ARC 한 줄을 **공식 기능 5종**(zonal shift·zonal autoshift·Region switch·routing control·readiness check)과 요금·기간·사전 확장 요건으로 늘렸습니다(근거 7~9번). ③ §8을 신설해 **대기 리전 쿼터 함정과 페일백 계획**을 적었습니다(근거 6·10번). ⚠️ 쿼터 서술의 근거는 Well-Architected 쪽이 아니라 **ARC Region switch 문서**입니다 — REL13-BP02 페이지에는 Service Quotas 언급이 없습니다.

> 📝 **2026-10-19 정정**: DynamoDB 글로벌 테이블을 "최종 일관성"만으로 서술했던 칸을 정정했습니다 — 생성 시 **MREC(기본)와 MRSC(강한 일관성)** 중 하나를 고르고, 생성 후에는 바꿀 수 없으며 MRSC는 동일 계정 구성만 지원합니다(근거 4번).
