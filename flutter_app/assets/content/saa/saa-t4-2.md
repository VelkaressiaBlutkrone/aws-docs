---
examGuideTaskId: saa-t4-2
certCode: SAA-C03
domain: 4
domainName: 비용에 최적화된 아키텍처 설계
domainWeightPct: 20
title: 비용 최적화 컴퓨팅 — Savings Plans·RI·Spot·오토스케일링·rightsizing
coversTasks:
  - "4.2"
sources:
  - title: AWS Savings Plans — 개요 (공식)
    url: https://docs.aws.amazon.com/savingsplans/latest/userguide/what-is-savings-plans.html
  - title: Amazon EC2 예약 인스턴스 개요 (공식)
    url: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-reserved-instances.html
  - title: Amazon EC2 스팟 인스턴스 (공식)
    url: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-spot-instances.html
  - title: AWS Compute Optimizer — 소개 (공식)
    url: https://docs.aws.amazon.com/compute-optimizer/latest/ug/what-is-compute-optimizer.html
  - title: SAA-C03 공식 시험 가이드 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
  - title: Compute Savings Plans and Reserved Instances (공식)
    url: https://docs.aws.amazon.com/savingsplans/latest/userguide/sp-ris.html
lastVerified: 2026-10-22
---

# 비용 최적화 컴퓨팅 — Savings Plans·RI·Spot·오토스케일링·rightsizing

> **커버하는 공식 Task** — SAA-C03 · 도메인 4 「비용에 최적화된 아키텍처 설계」(20%) · **Task 4.2 비용 효율적인 컴퓨팅 솔루션 설계** (`saa-t4-2`)
> 이 문서는 위 한 Task에 1:1로 매핑됩니다. "most cost-effective"는 시험에서 가장 자주 등장하는 키워드이며, 이 Task는 그 핵심입니다.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명할 수 있어야 합니다. (공식 시험 가이드 Task 4.2의 Skill 항목 기반)

- [ ] **EC2 구매 옵션 5종** — 온디맨드·RI·Savings Plans·Spot·전용 호스트의 할인율·적합 워크로드를 구분할 수 있다
- [ ] **RI vs Savings Plans** — 유연성·절감률·약정 방식의 차이를 설명할 수 있다
- [ ] **Spot 중단 메커니즘** — 2분 인터럽트 알림, 적합·부적합 워크로드를 구분할 수 있다
- [ ] **오토스케일링 비용 절감** — 수요 기반 스케일링과 예약 스케일링의 원리를 안다
- [ ] **Rightsizing** — Compute Optimizer가 분석하는 리소스와 권장 사항 유형을 안다
- [ ] **서버리스·Graviton 비용 이점** — 사용 기반 과금과 ARM 기반 절감 카드를 시험 문맥에서 쓸 수 있다

---

## 🎯 왜 중요한가

- 도메인 4(20%)는 시험 비중 3위입니다. "요구 조건을 충족하는 가장 저렴한 선택" 유형의 문제가 이 도메인에 집중됩니다.
- 시험은 워크로드 특성(상시/배치/예측 가능/중단 가능)을 주고 올바른 구매 옵션·스케일링 전략·rightsizing 도구를 고르게 합니다.
- 비용은 성능·가용성과 트레이드오프합니다. "싸지만 요건을 못 채우는" 보기는 정답이 아닙니다. **요건 충족을 전제로 가장 저렴한 것**이 정답입니다.

---

## 🔤 먼저 알아야 할 용어

이 문서를 읽는 데 필요한 기초 용어입니다. 이미 알면 건너뛰세요.

| 용어 | 영문 | 한 줄 풀이 |
|---|---|---|
| **잉여 용량** | Spare Capacity | 데이터센터에서 현재 온디맨드 수요를 채우고 남은 미사용 서버 자원 |
| **스테이트리스** | Stateless | 요청 처리 시 이전 요청 상태를 저장하지 않아 어느 인스턴스가 응답해도 결과가 동일한 구조 |
| **과프로비저닝** | Over-provisioning | 실제 수요보다 더 많은 컴퓨팅 자원을 할당해 유휴 용량이 발생하는 상태 |
| **CloudWatch** | Amazon CloudWatch | AWS 리소스의 지표(CPU·메모리·네트워크 등)를 수집·모니터링하는 관측 서비스 |
| **ARM 아키텍처** | ARM Architecture | 모바일·임베디드에서 출발한 명령어 집합 구조로, 동일 작업량 대비 전력 소모가 낮아 클라우드 서버 칩(Graviton 등)에 채택 |
| **스팟 가격** | Spot Price | EC2가 설정하며 장기적인 수요·공급 추세에 따라 점진적으로 조정되는 할인 가격 |

---

## 📖 핵심 개념 {#core-concepts}

### 1) EC2 구매 옵션 비교 {#ec2-purchase-options}

| 구매 옵션 | 할인율 (온디맨드 대비) | 약정 | 적합 워크로드 |
|---|---|---|---|
| **온디맨드(On-Demand)** | 기준(0%) | 없음 | 짧고 예측 불가, 개발·테스트 |
| **예약 인스턴스 — Standard RI** | 최대 72% | 1년 또는 3년 | 안정적 상시, 인스턴스 유형 고정 |
| **예약 인스턴스 — Convertible RI** | 최대 66% (3년 평균 약 54%) | 1년 또는 3년 | 인스턴스 패밀리 변경 가능성 있음 |
| **Savings Plans — Compute** | 최대 66% | 1년 또는 3년 | EC2+Fargate+Lambda, 가장 유연 |
| **Savings Plans — EC2 Instance** | 최대 72% | 1년 또는 3년 | 특정 패밀리·리전 고정, 높은 절감 |
| **스팟(Spot)** | 최대 90% | 없음 | 중단 가능 배치·스테이트리스 |
| **전용 호스트(Dedicated Host)** | 호스트 단위 과금(초 단위·최소 60초). **예약 시 최대 70% 할인**, Savings Plans도 적용 | 선택적 | BYOL 라이선스·규제 컴플라이언스 |

> 3년 약정 + All Upfront 결제가 가장 높은 할인을 제공합니다. 그러나 유연성은 그만큼 줄어듭니다.

> 🧠 원리: 왜 절감률이 높을수록 유연성이 낮아지는 구조가 될까요?
> AWS는 고객이 특정 인스턴스 유형·리전·기간을 약속할수록 그 용량을 안정적으로 확보·계획할 수 있고, 이 예측 가능성이 할인의 근거가 됩니다.
> 반대로 Compute Savings Plans처럼 패밀리·리전·서비스를 자유롭게 바꿀 수 있으면 AWS 입장에서 어떤 인프라를 준비해야 할지 불확실해져 같은 수준의 절감을 제공하기 어렵습니다.
> 결국 "얼마나 구체적으로 미래를 약속하는가"의 차이가 절감률과 유연성 사이의 트레이드오프를 만듭니다.

### 2) RI vs Savings Plans — 핵심 차이 {#ri-vs-savings-plans}

| 비교 항목 | 예약 인스턴스(RI) | Savings Plans |
|---|---|---|
| **약정 단위** | 인스턴스 구성(타입·리전·OS·테넌시) | 시간당 달러 사용량($/hr) |
| **유연성** | Standard: 변경 제한 / Convertible: 교환 가능 | Compute: 인스턴스 패밀리·리전·서비스 자유 변경 |
| **커버 서비스** | EC2, RDS 등 서비스별 RI 별도 | Compute SP: EC2+Fargate+Lambda |
| **AWS 공식 권장** | — | **Savings Plans 우선 권장** |
| **Marketplace 판매** | Standard RI: 가능 | 불가 |

> AWS 공식 문서는 "Savings Plans를 Reserved Instances보다 먼저 고려하라"고 명시합니다. 더 유연하고 동등한 수준의 절감율을 제공하기 때문입니다.

> 🧠 원리: 왜 Savings Plans는 인스턴스 구성이 아닌 "시간당 달러 사용량"을 약정 단위로 삼을까요?
> 인스턴스 구성(타입·리전·OS)으로 약정하면 사용 중 워크로드 성격이 바뀌어 인스턴스를 교체하고 싶어도 약정에 묶입니다.
> 달러 사용량($/hr)을 단위로 하면 인스턴스 패밀리나 서비스가 바뀌어도 해당 시간에 발생한 비용이 약정 한도 내에 있으면 할인이 자동으로 적용됩니다.
> 이 추상화 덕분에 워크로드를 EC2에서 Lambda나 Fargate로 전환해도 기존 약정이 유효하게 유지됩니다.

**용량 보장은 할인과 별개의 축입니다.** 시험은 이 둘을 섞어 묻습니다.

| 수단 | 요금 할인 | 특정 AZ 용량 확보 |
|---|---|---|
| **Regional RI** | ○ (리전 내 모든 AZ에 적용·크기 유연성) | ✗ |
| **Zonal RI** | ○ | **○** (특정 AZ에 용량 예약) |
| **On-Demand Capacity Reservation(ODCR)** | ✗ (자체 할인 없음) | **○** |
| **Savings Plans** | ○ | ✗ — **용량을 예약하지 않습니다** |

- **ODCR**은 즉시 사용형이면 **약정이 필요 없고** 생성·수정·취소가 자유롭습니다(미래 시작형에는 약정 기간이 붙습니다). 자체 할인은 없지만 **Savings Plans와 Regional RI의 할인이 일치하는 속성에 자동 적용**되므로 "용량은 ODCR, 할인은 SP 또는 Regional RI"로 조합합니다. ⚠️ **Zonal RI의 할인은 Capacity Reservation에 적용되지 않습니다.**
- ⚠️ 그래서 요건이 "**특정 AZ의 용량을 확보해야 한다**"면 Savings Plans는 답이 아닙니다 — Zonal RI 또는 ODCR입니다.

**할인 적용 순서** — 한 시간의 사용분에 여러 할인이 걸릴 때 적용 순서가 정해져 있습니다.

```
Free Tier → RI → EC2 Instance Savings Plans → Compute Savings Plans → 온디맨드
```

- 적용 범위가 **더 좁은 쪽이 먼저**입니다 — 그래서 EC2 Instance SP가 Compute SP보다 먼저 적용됩니다. 같은 단계에서는 **할인 폭이 가장 큰 사용분부터** 소진합니다.
- ⚠️ **시간당 약정은 다음 시간으로 이월되지 않습니다.** 그 시간에 쓰지 못한 약정은 사라지고, 약정을 넘는 사용분은 온디맨드로 청구됩니다.

**RI Marketplace** — 쓰지 않게 된 RI를 판매할 수 있지만 조건이 좁습니다.

- **Standard RI만** 판매할 수 있고 **Convertible RI는 불가**합니다(RDS·ElastiCache 등 다른 서비스의 RI도 불가).
- 남은 약정 기간이 **1개월 이상**이어야 하고, 판매하면 선납가의 **12%**가 서비스 수수료로 붙습니다.
- 볼륨 할인으로 구매한 RI는 판매할 수 없습니다.

**Dedicated Host 과금** — 호스트를 할당해 둔 시간에 **초 단위(최소 60초)**로 과금되고, 그 호스트에 인스턴스를 몇 개·어떤 크기로 올리든 금액은 같습니다. 예약하면 **최대 70%** 할인되며, Savings Plans는 **가상 호스트**에만 적용됩니다(`.metal` 인스턴스는 제외).

### 3) Savings Plans 유형 {#savings-plans-types}

| 유형 | 적용 대상 | 특징 |
|---|---|---|
| **Compute Savings Plans** | EC2 + Fargate + Lambda | 인스턴스 패밀리·리전·OS·테넌시 무관. 가장 유연 |
| **EC2 Instance Savings Plans** | 특정 EC2 패밀리·리전 | 절감률 높음, 유연성 낮음 |
| **Database Savings Plans** | Aurora·RDS·DynamoDB·ElastiCache·DocumentDB·Neptune·Timestream·Keyspaces·DMS·OpenSearch | 최대 35% 절감. 최신 프로비저닝 세대와 **서버리스 사용량**에 엔진·패밀리·크기·AZ·리전 무관 적용 |
| **SageMaker AI Savings Plans** | Amazon SageMaker AI | SageMaker AI 인스턴스 전용(최대 64%) |

> Savings Plans는 **스팟 인스턴스에 적용되지 않습니다.** Spot에서 발생한 비용은 Savings Plans 약정 소진으로 처리되지 않습니다.

> 🧠 원리: 왜 Savings Plans 약정이 스팟 비용에는 적용되지 않을까요?
> Savings Plans는 온디맨드 요금에서 일정 사용량을 약속하는 구조로, 온디맨드 비용을 기준으로 할인을 산정합니다.
> 스팟 인스턴스는 EC2가 수요·공급 추세에 따라 가격을 설정·조정하는 자체 할인 가격 메커니즘으로 운영되며, AWS 공식 문서는 스팟 사용량에 Savings Plans가 적용되지 않는다고 명시합니다.
> 두 할인 체계는 별개로 설계되어 있어 스팟 비용은 Savings Plans 약정 소진 대상이 아닙니다.

### 4) RI 납입 옵션 (Savings Plans도 동일 구조) {#payment-options}

| 납입 옵션 | 방식 | 절감률 |
|---|---|---|
| **All Upfront** | 약정 시작 시 전액 선납 | 가장 높음 |
| **Partial Upfront** | 일부 선납 + 나머지 할인 시간당 청구 | 중간 |
| **No Upfront** | 선납 없음, 할인 시간당 청구 | 가장 낮음 |

> 기간: 1년 또는 3년. 3년 + All Upfront 조합이 최대 절감을 제공합니다.

> 🧠 원리: 왜 선납(All Upfront)이 월납(No Upfront)보다 높은 할인을 받을 수 있을까요?
> All Upfront는 약정 시작 시점에 전액을 한 번에 지불하므로 선납 비중이 가장 높고, No Upfront는 선납 없이 매월 분할 청구되어 선납 비중이 없습니다.
> AWS 공식 요금 문서는 선납 비중이 클수록 할인율이 높다고 명시하며, Partial Upfront는 두 방식의 중간 할인을 제공합니다.
> 사용자 관점에서 초기 자금 여유가 있다면 All Upfront가 총비용 절감에 유리하고, 현금 흐름 관리가 필요하다면 No Upfront로 초기 부담을 줄일 수 있습니다.

### 5) 스팟 인스턴스 {#spot-instances}

스팟 인스턴스는 EC2의 **잉여 용량**을 활용하며, 스팟 가격은 EC2가 설정하고 장기적인 수요·공급 추세에 따라 점진적으로 조정됩니다.

**핵심 특성:**

- 온디맨드 대비 최대 **90% 할인**
- AWS가 용량을 필요로 하면 **2분 인터럽트 알림** 후 회수(종료·중지·동면 중 선택 가능)
- EC2 인스턴스 재조정 권장 신호(Rebalance Recommendation)로 중단 전 사전 알림 제공

**적합 워크로드:**

- 스테이트리스 웹 워크로드
- 배치 처리(데이터 분석, 이미지 렌더링)
- CI/CD 워커, 빅데이터 처리
- 컨테이너 워커 노드

**부적합 워크로드:**

- 상태 저장 데이터베이스
- 중단 불가 트랜잭션 처리
- 장시간 단일 작업(중간 체크포인트 없는 경우)

**스팟 플릿(Spot Fleet):**

여러 인스턴스 유형·AZ를 혼합하여 스팟 인스턴스를 요청하는 기능입니다. 특정 인스턴스 풀의 용량이 소진되면 다른 풀로 자동 전환하여 목표 용량을 유지합니다.

```
스팟 할당 전략:
- price-capacity-optimized : 용량이 넉넉한 풀 중 가장 저렴한 쪽 (AWS 권고)
- capacity-optimized       : 가용 용량이 가장 많은 풀 (중단 최소화)
- capacity-optimized-prioritized : 용량 우선 + 유형 우선순위 반영
- diversified              : 여러 풀에 분산 (가용성 최대화)
- lowest-price             : 가장 저렴한 풀 우선 (EC2 Fleet 기본값, 중단 위험 큼)
```

> AWS 모범 사례는 **`price-capacity-optimized`** 입니다 — "가장 가용 용량이 많은 풀 중 가능한 가장 낮은 가격"으로 프로비저닝해 회수 가능성을 낮춥니다. `CreateFleet` 기본값이 `lowest-price`라는 점과 혼동하지 마세요(기본값 ≠ 권고값).

> 전략 선택의 기준: **기본은 `price-capacity-optimized`**(가격과 용량의 **균형** — AWS 권고). **중단 최소화가 비용보다 절대적으로 우선**이면 `capacity-optimized` 입니다 — 가용 용량이 가장 많은 풀을 고르므로 가격은 양보합니다. 두 전략을 뭉쳐 외우면 "비용보다 중단 최소화 우선" 문항에서 틀립니다.

**중단을 줄이는 설계는 전략 선택으로 끝나지 않습니다.**

- **스팟 용량 풀 = AZ × 인스턴스 유형**입니다. 한 풀에 몰아 요청하면 그 풀이 회수될 때 용량이 한꺼번에 사라지므로, **여러 풀로 다양화**하는 것이 1차 방어입니다.
- **속성 기반** 인스턴스 유형 선택 — 유형 이름을 일일이 나열하는 대신 vCPU·메모리 같은 **요건**으로 지정하면 조건에 맞는 신규·비인기 유형까지 후보에 들어와 풀이 넓어집니다.
- **Spot 배치 점수** — 원하는 용량·유형 조합이 어느 리전·AZ에서 잘 공급될지를 점수로 알려줍니다. 워크로드를 옮길 수 있다면 배치 전에 확인합니다.
- **ASG의 Capacity Rebalancing** — 재조정 권고를 받으면 ASG가 **회수 전에** 대체 인스턴스를 먼저 띄워 교체합니다(2분 알림만 기다리지 않습니다).
- ⚠️ **온디맨드 폴백은 권장되지 않습니다.** 스팟이 잡히지 않을 때 자동으로 온디맨드를 띄우는 구성은 비용이 튀고, 그 용량 요청이 **다른 스팟 인스턴스의 중단을 유발**할 수 있습니다. 먼저 풀 다양화로 해결합니다.

> 🧠 원리: 왜 AWS는 스팟 인스턴스를 즉시 회수하지 않고 2분 인터럽트 알림을 줄까요?
> 스팟 인스턴스는 잉여 용량을 제공하므로 AWS가 용량을 회수할 때 애플리케이션이 갑자기 종료되면 진행 중인 작업이 소실됩니다.
> 2분 알림 창은 체크포인트 저장, 진행 중 데이터 플러시, 결과 업로드 등 종료 전 정리 작업을 가능하게 해 중단 비용을 줄여줍니다.
> 이 알림 메커니즘 덕분에 스팟이 배치·스테이트리스 워크로드에서 실용적인 옵션으로 활용될 수 있습니다.

### 6) 오토스케일링으로 비용 절감 {#auto-scaling-cost}

오토스케일링은 수요에 맞춰 인스턴스 수를 조정합니다. 과프로비저닝(비용 낭비)과 부족 프로비저닝(성능 저하)을 모두 방지합니다.

**비용 절감 스케일링 전략:**

| 전략 | 방식 | 비용 효과 |
|---|---|---|
| **Target Tracking** | CPU·요청 수 등 지표 목표치 유지 | 수요 비례 자동 조정 |
| **Step Scaling** | 지표 구간별 단계 스케일 | 급격한 변화에 정밀 대응 |
| **Scheduled Scaling** | 예상 패턴(야간 축소 등) 사전 설정 | 예측 가능 시간대 비용 절감 |
| **Predictive Scaling** | ML로 수요 예측 후 선제 스케일 | 반응 지연 없이 최소 용량 유지 |

> 핵심: **야간·주말 트래픽이 낮은 환경** → Scheduled Scaling으로 인스턴스 수 축소. **비규칙적 수요** → Target Tracking.

> 🧠 원리: 왜 오토스케일링은 피크 수요를 기준으로 고정 프로비저닝하는 방식보다 비용이 낮아질 수 있을까요?
> 고정 프로비저닝은 피크 트래픽을 견디기 위해 최대 용량을 항상 유지하므로, 수요가 낮은 시간대에 유휴 인스턴스가 과프로비저닝 상태로 과금됩니다.
> 오토스케일링은 실제 수요에 맞춰 인스턴스 수를 조정하므로 유휴 용량이 줄고, 특히 수요 변동 폭이 큰 워크로드에서 절감 효과가 높아집니다.
> 단, 스케일 아웃 반응 시간이 존재하므로 트래픽 급등에 대비해 최소 기반 용량은 유지해야 합니다.

**스팟 + 오토스케일링 혼합 — 혼합 인스턴스 정책:**

Auto Scaling 그룹에서 온디맨드(기반 용량)와 스팟(초과 용량)을 혼합하면 안정성을 유지하면서 비용을 낮출 수 있습니다. 그룹은 **기본적으로 온디맨드만** 쓰므로, 비율을 조정해야 스팟이 들어옵니다.

- **온디맨드 기본(base) 용량**을 먼저 확보한 뒤, 그 위의 증설분을 온디맨드/스팟 **비율**(0~100%)로 나눕니다. 예를 들어 base 10 + 50/50이면 처음 10대는 온디맨드이고 이후 증설분은 절반씩이며, base 0 + 0/100이면 전부 스팟입니다.
- ⚠️ 비율을 인스턴스 **수**로 환산할 때 소수는 **온디맨드 쪽으로 올림**합니다(안정성 우선).
- **가중치**를 주면 유형마다 "용량 1단위"의 크기가 달라집니다(예: `m5.xlarge`=2, `m5.large`=1) — 목표 용량을 vCPU 같은 실제 능력 기준으로 맞출 수 있습니다.
- 스팟 할당 전략과 **Capacity Rebalancing**을 함께 켜서 중단에 대비합니다.

**예측 스케일링의 데이터 전제:**

- 지표가 **최소 24시간** 쌓여야 동작하고, **최근 14일 분석**으로 **향후 48시간**의 시간당 용량을 예측해 **6시간마다** 갱신합니다.
- 처음에는 예측만 하는 모드로 두고 정확도를 확인한 뒤 실제 스케일링으로 바꿉니다.
- ⚠️ 예측 스케일링은 **스케일 아웃만** 담당합니다 — 줄이는 쪽은 동적 정책(대상 추적 등)이 처리하므로 **함께 설정**해야 비용이 실제로 내려갑니다.

**웜 풀** — 부팅·초기화가 오래 걸리는 앱은 사전 초기화된 인스턴스를 **웜 풀**에 두어 스케일 아웃 지연을 줄일 수 있습니다. 기본 크기는 **최대 용량 − 희망 용량**이고, 풀에 있는 인스턴스는 스케일링 정책 지표에 포함되지 않습니다. 풀 상태를 Stopped로 두면 인스턴스 사용료 없이 EBS만 과금됩니다.

### 7) Rightsizing — AWS Compute Optimizer {#rightsizing}

> 공식 정의: "AWS 리소스의 구성과 활용도 지표를 분석해 rightsizing 권장 사항을 제공하고 유휴 리소스를 식별하는 서비스."

**분석 대상 리소스:**

- Amazon EC2 인스턴스
- EC2 Auto Scaling 그룹
- Amazon EBS 볼륨
- AWS Lambda 함수
- Amazon ECS 서비스(Fargate)
- Amazon RDS 및 Aurora 데이터베이스
- **상용 라이선스 인스턴스**(EC2에서 실행하는 **SQL Server** 등) — 라이선스 관점의 권고도 제공

**작동 방식:**

- 기본 분석 기간: **최근 14일** CloudWatch 지표
- 확장 기간(유료 *Enhanced Infrastructure Metrics*): **32일** 또는 **93일**
- CPU 사용률·메모리·네트워크·디스크 I/O 분석 후 과프로비저닝 또는 저프로비저닝 판정
- 옵트인 서비스입니다 — 계정(또는 조직)에서 켜야 권고가 생성됩니다

**권장 결과 유형:**

- 과프로비저닝 → 더 작은 인스턴스 유형 권장
- 저프로비저닝 → 더 큰 인스턴스 유형 권장
- 유휴(Idle) → 중지 또는 삭제 권장

**유휴 권고는 컴퓨팅 밖까지 넓어졌습니다.** EBS 볼륨·Fargate 태스크·EC2·Auto Scaling 그룹·RDS 외에 **NAT Gateway**, DynamoDB 프로비저닝 테이블, ElastiCache(Redis/Valkey), **MemoryDB**의 유휴 리소스도 식별합니다 — "안 쓰는데 켜져 있는 것"을 찾는 도구로 쓰는 범위가 EC2 크기 조정보다 훨씬 넓습니다.

> 🧠 원리: 왜 Compute Optimizer는 자동 변경 없이 권장 사항만 제안하는 방식으로 동작할까요?
> 인스턴스 크기 변경은 재시작을 수반하며, 운영 중인 서비스에 다운타임이 생길 수 있습니다.
> CloudWatch 지표는 과거 패턴을 반영하지만, 미래 수요 변화나 애플리케이션 특수 요건(메모리 핀닝, 라이선스 제약 등)까지 파악할 수 없습니다.
> 실제 변경 여부와 시점은 운영자가 판단해야 하므로, 자동 실행이 아닌 권장 사항 제공 방식이 의도치 않은 장애를 막는 안전한 설계 방향입니다.

### 8) 서버리스 및 Graviton의 비용 이점 {#serverless-graviton}

**서버리스 (Lambda·Fargate):**

- 과금 단위가 다릅니다: **Lambda는 1 ms 단위**(올림), **Fargate는 초 단위에 최소 1분**(Windows 컨테이너는 최소 5분). 또 Lambda **프로비저닝 동시성**은 활성화해 둔 시간 동안 요청이 없어도 과금됩니다
- 서버 프로비저닝·관리 비용 제거
- 예측 불가·간헐적 워크로드에 적합
- **Lambda 과금 축** = 요청 수 + 기간(**GB-초** — 할당 메모리 × 실행 시간). 월 100만 요청과 **400,000** GB-초는 무료 티어이고, 사용량이 커지면 GB-초에 **계층 요금**(구간이 올라갈수록 할인)이 적용됩니다. Compute Savings Plans는 기간·프로비저닝 동시성에 적용되지만 **요청 요금에는 적용되지 않습니다**
- **Fargate 과금 축** = 프로비저닝한 vCPU·메모리·스토리지. 이미지 pull 시작부터 태스크 종료까지 재고, 임시 스토리지는 20 GB까지 추가 비용이 없습니다. 중단을 허용할 수 있으면 **Fargate Spot**으로 최대 70%까지 낮출 수 있습니다

**어느 쪽이 싼가 — 부하 모양이 가릅니다.**

| 부하 모양 | 유리한 쪽 | 왜 |
|---|---|---|
| 간헐적·예측 불가(대부분 유휴) | **Lambda** | 유휴 시 과금이 없고 1 ms 단위로만 센다 |
| 장시간 실행·마이크로서비스·배치 | **Fargate** | 요청-응답이 아닌 상시 프로세스에 맞고 태스크 단위로 과금된다 |
| **24/7** 고처리량 프로덕션 | **약정을 붙인 컨테이너(EC2·ECS)** | 사용률이 높을수록 종량제보다 RI·Savings Plans 할인이 크게 작용한다 |
| 개발·테스트 | 둘 다 저렴 | 업무 시간만 쓰도록 스케줄링하거나 0까지 줄일 수 있다 |

> ⚠️ "서버리스가 항상 싸다"는 일반화는 틀립니다. **유휴가 많을 때** 싸고, 사용률이 높고 항상 켜져 있어야 한다면 **약정 할인을 받는 컨테이너·EC2가 대체로 더 저렴**합니다.

**AWS Graviton (ARM 기반):**

- 공식 서술: 동급 x86 기반 EC2 인스턴스 대비 **최대 20% 낮은 비용**
- Savings Plans와 결합 시 추가 절감 가능
- 지원: EC2(m7g·c7g·r7g 등), Lambda, Fargate, RDS, ElastiCache 등
- 조건: 애플리케이션이 ARM 아키텍처에서 동작해야 함 (컨테이너·인터프리터 언어 전환 용이)

**프로세서와 패밀리 선택도 비용 축입니다** — 인스턴스 이름의 접미 문자가 프로세서를 나타냅니다(`a`=**AMD**, `g`=Graviton, `i`=Intel).

- **AMD(`a`)** 계열은 동급 Intel 대비 컴퓨트 비용이 **약 10%** 낮습니다 — x86 호환이라 **이식 작업 없이** 적용할 수 있는 가장 값싼 절감입니다.
- **Graviton(`g`)** 은 절감 폭이 더 크지만 ARM 재빌드·검증이 필요합니다. ⚠️ **Windows Server는 x86 전용이라 Graviton을 쓸 수 없습니다** — CPU에 종속된 라이선스를 쓰는 레거시도 보류합니다.
- **범주를 먼저 고르고 그다음 크기를 맞춥니다.** 범용(균형·웹·중소 DB) · **컴퓨트 최적화**(배치·미디어 트랜스코딩·게임 서버) · 메모리 최적화(인메모리 DB·분석) · 스토리지 최적화(저지연 랜덤 I/O) · 가속 컴퓨팅 · HPC 최적화. 범주를 잘못 고르면 크기 조정으로는 복구되지 않습니다(선택 기준 상세는 `saa-t3-3`).
- **T 계열(버스트)** 은 기본이 **unlimited** 모드입니다 — 24시간 평균이 기준선 이하면 추가 요금이 없지만, 꾸준히 기준선을 넘기면 vCPU-시간 단위 요금이 붙어 **같은 크기의 일반 인스턴스보다 비싸질 수 있습니다.**
- **Optimize CPUs** — license-included Windows·SQL Server 인스턴스는 vCPU 수와 하이퍼스레딩을 줄여 **vCPU 기반 라이선스 비용**을 낮출 수 있습니다(컴퓨팅 요금이 아니라 라이선스 요금을 줄이는 수단).

> 🧠 원리: 왜 서버리스(Lambda·Fargate) 과금은 유휴 시 비용이 발생하지 않을까요?
> EC2는 인스턴스가 실행 중인 시간 전체에 대해 과금되므로, 요청이 없는 유휴 시간도 동일하게 청구됩니다.
> Lambda와 Fargate는 요청이 들어올 때만 컨테이너·실행 환경을 프로비저닝하고 완료되면 자원을 반환하므로, 대기 상태에서 점유하는 컴퓨팅이 없어 과금도 발생하지 않습니다.
> 이 구조 덕분에 간헐적·예측 불가 워크로드는 항상 켜둔 인스턴스 없이도 수요에 맞춰 처리됩니다.

### 9) 로드 밸런서 비용 — LCU·NLCU {#elb-cost}

ELB 요금은 **시간당 기본 요금 + 용량 단위**로 구성됩니다. 용량 단위는 ALB가 **LCU**, NLB가 **NLCU**이며, 여러 차원을 동시에 재지만 **사용량이 가장 큰 한 차원**만 과금합니다.

| LB | 용량 단위 차원 |
|---|---|
| **ALB (LCU)** | ① 신규 연결(초당) ② 활성 연결(분당) ③ 처리 바이트(시간당 GB) ④ **규칙 평가**(규칙 수 × 요청률, 처음 10개 규칙은 무료) |
| **NLB (NLCU)** | ① 신규 연결·플로우(초당 — TCP·UDP·TLS가 각각 다름) ② 활성 연결·플로우 ③ 처리 바이트 |

- "차원을 전부 더한다"가 아니라 **최댓값 하나만** 청구된다는 점이 시험 포인트입니다. 규칙이 10개 이하라면 규칙 평가 차원은 아예 무시됩니다.
- **NLB·GWLB는 LCU 예약**을 지원합니다 — 예약한 분량은 **실제 사용량과 무관하게 과금**되므로, 피크 지표를 보고 상시 필요한 만큼만 예약합니다.
- **ALB 통합이 비용을 줄이는 가장 큰 축입니다.** 호스트·**경로 기반** 조건 라우팅으로 여러 앱을 **하나의 ALB**에 모으면 LB 개수만큼 붙던 시간당 요금이 줄어듭니다. 반대로 "정적 IP가 필요해 NLB를 앞에 두고 뒤에 ALB를 붙이는" 구성은 **LB 두 개의 요금과 운영 부담**을 함께 집니다.
- 대상(EC2·컨테이너 등)의 요금은 별도입니다.

> 🧠 원리: 왜 ELB는 여러 차원을 재면서 가장 큰 한 차원만 과금할까요?
> 로드 밸런서가 실제로 소모하는 자원은 연결이 많을 때, 데이터가 많을 때, 규칙이 복잡할 때 각각 다른 이유로 늘어납니다. 어느 축이 병목인지는 워크로드마다 달라서, 모든 축을 더하면 같은 부하인데도 요금이 과도하게 커집니다.
> 최댓값 하나만 과금하면 "가장 부담을 준 축"만 비용이 되므로, 사용자는 자기 워크로드에서 실제로 비싼 축만 최적화하면 됩니다.
> 그래서 ALB 비용 설계는 "연결을 줄일까, 데이터를 줄일까, 규칙을 줄일까"를 한꺼번에 고민하는 게 아니라 **내 워크로드의 지배 차원을 먼저 찾는 것**에서 시작합니다.

### 10) 끄고 줄이는 절감 — 최대 절전·스케줄 중지·수평 vs 수직 {#stop-and-shrink}

가장 확실한 절감은 **안 쓰는 것을 끄는 것**입니다. Well-Architected 비용 최적화 기둥의 "소비 모델 채택"이 드는 예가 개발·테스트 환경입니다 — 주 5일 하루 8시간만 쓰면 **40시간 대 168시간**이므로, 안 쓸 때 끄면 **최대 75%**를 줄일 수 있습니다.

| 워크로드 클래스 | 절감 수단 |
|---|---|
| **프로덕션** | 상시 가동 전제 → 약정(RI·Savings Plans)·rightsizing·오토스케일링 |
| **비프로덕션**(개발·테스트·스테이징) | **스케줄 중지**가 1순위. **중단을 허용할 수 있**는 작업이면 Spot도 후보. 요금이 낮은 리전 배치도 선택지 |

- **Instance Scheduler on AWS**는 태그로 지정한 EC2·RDS를 **일정에 따라 자동 시작·중지**합니다(업무 시간 외·주말, 교차 계정). 사람이 손으로 끄는 운영은 빠뜨리기 쉬워 절감이 새어 나갑니다.
- ⚠️ 오토스케일링의 Scheduled Scaling과는 **층이 다릅니다** — 이쪽은 **인스턴스 자체를 끄고 켜는 것**이고, 그쪽은 **그룹의 용량을 조정하는 것**입니다.

**최대 절전(hibernation)** — 메모리(RAM) 내용을 EBS 루트 볼륨에 저장했다가 시작 시 그대로 복원합니다(프로세스 재개·인스턴스 ID 유지).

- 최대 절전된(stopped) 인스턴스는 **사용료가 없습니다.** RAM 내용을 EBS로 옮기는 전송 요금도 없습니다.
- ⚠️ 그러나 **RAM 내용을 담은 EBS 스토리지는 계속 과금**되고, `stopping` 으로 전환되는 동안에는 인스턴스 요금이 붙습니다. "끄면 0원"이 아닙니다.
- 시작 시점에 최대 절전을 **활성화해 둬야** 쓸 수 있습니다(나중에 켤 수 없습니다). 부트스트랩·캐시 워밍이 오래 걸리는 앱에서 값이 큽니다.

**수평 vs 수직 스케일링** — 같은 부하를 감당하는 두 방향이고 비용 성질이 다릅니다.

| 축 | 방식 | 비용 관점 |
|---|---|---|
| **수평 스케일링**(scale out/in) | 같은 크기 인스턴스의 **수**를 늘리고 줄임 | 수요에 맞춰 **잘게 줄일 수 있어** 유휴가 적다. Spot·혼합 정책을 섞을 수 있다 |
| **수직 스케일링**(scale up/down) | 인스턴스를 **더 큰·작은 유형**으로 교체 | 단계가 거칠고 교체에 **재시작**이 필요하다. 단일 노드만 쓰는 앱에서는 이 축밖에 없다 |

> 🧠 원리: 왜 비용 최적화에서는 수직 스케일링보다 수평 스케일링을 먼저 고려할까요?
> 수직 스케일링은 유형 단위로만 올리고 내릴 수 있어, 필요한 용량이 두 유형 사이에 있으면 큰 쪽을 골라야 하고 그 차액이 상시 유휴로 남습니다.
> 수평 스케일링은 같은 크기 단위를 더하고 빼므로 수요 곡선에 더 촘촘히 붙고, 남는 용량에 Spot을 섞어 단가까지 낮출 수 있습니다.
> 그래서 수직 스케일링은 "그 축밖에 없을 때"(단일 노드 제약, 메모리 집약 단일 프로세스)의 수단으로 두고, 평소 절감은 수평 축에서 가져옵니다.

### 11) 배치 결정이 만드는 비용 — 리전·엣지·하이브리드 {#placement-cost}

**리전 선택** — 리소스 요금은 **리전마다 다릅니다**(토지·전력·광섬유·세금이 다르기 때문).

- 데이터 프라이버시·규정·지연 요건이 묶지 않는다면 **요금이 낮은 리전**에 두는 것이 가장 단순한 절감입니다. 특히 개발·테스트는 사용자 지연이 중요하지 않아 옮기기 쉽습니다.
- ⚠️ 이미 돌고 있는 워크로드는 **이전 비용**(데이터 전송·재구축·검증 공수)과 절감을 비교해 판단합니다. 절감이 이전 비용을 넘을 때만 옮깁니다.
- 리전 비교는 **Pricing Calculator**로 합니다. 리전 평가는 비용만이 아니라 **지연·서비스 제공 여부·규정**까지 네 축으로 봅니다.
- ⚠️ 리전별 구체 단가는 수시로 바뀌므로 이 문서는 **과금 축만** 적습니다 — 시험도 "어느 리전이 더 싸다"가 아니라 "요금이 리전마다 다르다는 사실과 그 판단 방법"을 묻습니다.

**엣지 컴퓨팅** — CloudFront 앞단에서 코드를 돌리는 두 선택지는 비용 성질이 다릅니다.

| | CloudFront Functions | Lambda@Edge |
|---|---|---|
| 과금 축 | **호출 수** | 요청 수 + **기간(GB-초)** |
| 무료 티어 | 있음 | ⚠️ **무료 티어가 없습니다** |
| 적합 | 헤더 조작·URL 리라이트·간단한 인증 같은 **짧고 가벼운 변형** | 네트워크 호출·큰 의존성이 필요한 **무거운 로직** |

- 요건이 허락하면 **CloudFront Functions를 먼저** 고려합니다. 트리거는 **가장 구체적인 behavior에만** 걸어 불필요한 호출을 줄이고, Lambda@Edge를 쓸 때는 메모리를 과하게 잡지 않습니다.

**하이브리드 — AWS Outposts** 는 온프레미스에 AWS 랙을 두는 모델이라 과금 구조가 클라우드와 다릅니다.

- **3년 기간으로 용량을 구매**하고 All·Partial·No Upfront 중에 고릅니다(월 지불도 3년간 이어집니다).
- 가격에 배송·**설치·유지보수**·패치·랙 제거가 **포함**됩니다 — 별도 계약이 아닙니다.
- ⚠️ 약정이 끝나면 갱신하거나 반납하는데, **아무 통보를 하지 않으면 월 단위 요율로 자동 갱신**됩니다.
- 리전과 Outpost 사이의 데이터 전송 등은 **별도 과금**입니다.

> 🧠 원리: 왜 Outposts는 종량제가 아니라 3년 기간 구매 모델일까요?
> Outposts는 AWS가 고객 사이트에 **물리 랙을 배치·설치하고 수명 동안 유지보수**하는 형태라 하드웨어와 현장 서비스 원가가 선투입됩니다.
> 클라우드 리전처럼 여러 고객이 같은 용량을 공유할 수 없어 사용량이 들쭉날쭉해도 그 랙은 그 고객만 씁니다 — 종량제로 두면 AWS가 유휴 위험을 전부 부담하게 됩니다.
> 그래서 기간 약정으로 원가를 회수하는 구조가 되고, "필요할 때만 켠다"는 클라우드식 절감 전략은 Outposts에 적용되지 않습니다.

---

## ✍️ 시험 포인트

| 시나리오 | 정답 선택 |
|---|---|
| 장기 안정, 인스턴스 변경 가능성 있음 | Compute Savings Plans |
| 장기 안정, 인스턴스 고정 | EC2 Instance Savings Plans 또는 Standard RI |
| 중단 가능한 야간 배치 처리 | Spot |
| BYOL 라이선스 요구 | Dedicated Host |
| 짧은 기간, 예측 불가 | On-Demand |
| 인스턴스 크기가 적절한지 분석 | AWS Compute Optimizer |
| 야간 트래픽 감소 시 자동 축소 | Scheduled Scaling (Auto Scaling) |
| 간헐적 짧은 워크로드, 비용 최소화 | Lambda (서버리스) |
| 동일 성능·저렴한 인스턴스 패밀리 | Graviton 계열 (m7g, c7g 등) |
| Savings Plans vs RI 둘 다 가능할 때 | Savings Plans (AWS 공식 우선 권장) |
| **특정 AZ의 용량을 반드시 확보**해야 함 | Zonal RI 또는 On-Demand Capacity Reservation — Savings Plans는 용량을 예약하지 않음 |
| 용량도 확보하고 할인도 받고 싶음 | ODCR + Savings Plans(또는 Regional RI) 조합 |
| 쓰지 않게 된 RI를 처분 | RI Marketplace — Standard RI만, 수수료 12%, Convertible 불가 |
| 중단 최소화가 비용보다 **절대 우선**인 스팟 플릿 | `capacity-optimized` (일반 권고는 `price-capacity-optimized`) |
| 반복 패턴이 있고 부팅이 오래 걸리는 앱 | 예측 스케일링 + 웜 풀 |
| Windows Server 워크로드의 프로세서 비용 절감 | AMD(`a`) 계열 — Graviton은 쓸 수 없음 |
| 안 쓰는 NAT Gateway·유휴 DB까지 찾아야 함 | AWS Compute Optimizer 유휴 권고 |
| **24/7** 고처리량 프로덕션 API의 비용 최소화 | 약정을 붙인 컨테이너·EC2 (Lambda보다 유리) |
| ALB 요금이 늘었는데 어느 축 때문인지 모름 | LCU 4차원 중 **지배 차원**을 먼저 확인 — 가장 큰 한 차원만 과금 |
| 앱이 여러 개인데 로드 밸런서 요금이 과도 | 호스트·경로 기반 라우팅으로 **ALB 하나에 통합** |
| 개발·테스트 환경 비용을 가장 크게 줄이려면 | **Instance Scheduler**로 업무 시간 외 자동 중지 (최대 75%) |
| 부팅·캐시 워밍이 오래 걸리는데 상시 가동은 비싸다 | **최대 절전** — 단, RAM을 담은 EBS는 계속 과금 |
| 단일 노드 RDBMS의 성능이 부족 | **수직 스케일링** (수평 축이 없는 경우의 수단) |
| 헤더 조작·URL 리라이트 정도의 엣지 로직 | **CloudFront Functions** — Lambda@Edge는 무료 티어가 없음 |
| 온프레미스에 AWS 인프라가 필요 | **Outposts** — 3년 기간 구매, 설치·유지보수 포함 |
| 개발 환경을 더 싼 리전으로 옮길지 판단 | 절감 vs **이전 비용** 비교 (Pricing Calculator) |

---

## ⚠️ 흔한 함정 {#common-pitfalls}

1. **"스팟은 언제나 최선이다."** → Spot은 중단 가능한 워크로드에만 적합합니다. 상태 저장 DB나 중단 불가 트랜잭션에 스팟을 사용하면 데이터 손실·서비스 중단 위험이 있습니다.
   *(원리: §5 — 2분 알림은 정리 작업을 가능하게 하지만, 중단 자체를 막지는 못하므로 상태 저장 워크로드에는 스팟이 적합하지 않다.)*

2. **"Savings Plans가 스팟에도 적용된다."** → Savings Plans는 스팟 인스턴스에 **적용되지 않습니다.** Spot 비용은 Savings Plans 약정 소진으로 처리되지 않습니다.
   *(원리: §3 — 스팟은 EC2가 수요·공급 추세에 따라 가격을 설정·조정하는 자체 할인 가격 메커니즘으로 운영되며, Savings Plans 약정 소진 대상에 포함되지 않는다.)*

3. **"RI를 구매하면 언제든 취소할 수 있다."** → RI는 구매 후 **취소 불가**입니다. Standard RI는 Reserved Instance Marketplace에서 제3자에게 판매할 수 있지만, Convertible RI는 판매가 불가합니다.
   *(원리: §1 — 절감률이 높은 구매 옵션일수록 인스턴스 유형·리전·기간을 구체적으로 고정해 유연성을 희생하는 트레이드오프가 적용된다.)*

4. **"Compute Optimizer는 자동으로 인스턴스 크기를 바꿔준다."** → Compute Optimizer는 권장 사항을 **제안**할 뿐, 자동으로 변경하지 않습니다. 실제 변경은 사용자가 직접 해야 합니다.
   *(원리: §7 — 인스턴스 변경은 재시작을 수반하며 CloudWatch 지표가 파악하지 못하는 요건이 있어 운영자 판단이 필요하다.)*

5. **"No Upfront RI는 약정이 아니다."** → No Upfront RI도 1년 또는 3년 계약 의무입니다. 선납금이 없을 뿐이며, 매월 할인 요금이 청구됩니다.
   *(원리: §4 — 납입 방식은 선납 비중 차이로 할인율을 결정할 뿐, 기간 약정 의무 자체는 All Upfront·No Upfront 모두 동일하다.)*

6. **"Standard RI와 Convertible RI의 할인율이 같다."** → Standard RI가 더 높은 할인(최대 72%)을 제공하지만, 인스턴스 유형 교환이 불가합니다. Convertible RI는 교환 가능한 대신 할인율이 조금 낮습니다(최대 66%, 3년 평균 약 54%).
   *(원리: §1 — 인스턴스 유형을 구체적으로 고정할수록 절감률이 높고 유연성이 낮아지는 트레이드오프가 Standard/Convertible 차이에도 동일하게 적용된다.)*

---

## 🧪 자가 점검

> 아래는 학습용 자가 점검입니다. (정식 검증 문항은 별도 문항 파일 참조)

**Q1.** 회사가 향후 3년간 EC2를 안정적으로 운영할 예정이며, 인스턴스 패밀리와 리전을 바꿀 가능성이 있습니다. 가장 비용 효율적인 선택은?

<details><summary>정답 보기</summary>

**Compute Savings Plans (3년, All Upfront)**입니다. 인스턴스 패밀리·리전·OS를 자유롭게 변경할 수 있으면서 최대 66%의 할인을 제공합니다. Standard RI는 인스턴스 유형 변경이 제한되어 유연성이 낮습니다. AWS 공식 문서도 Reserved Instances보다 Savings Plans를 먼저 고려하도록 권장합니다.
</details>

**Q2.** 야간에만 실행되는 데이터 분석 배치 작업이 있습니다. 중간에 중단되더라도 재시작이 가능하도록 설계되어 있습니다. 비용을 최소화하려면 어떤 구매 옵션을 사용해야 합니까?

<details><summary>정답 보기</summary>

**Spot 인스턴스**입니다. 중단·재시작이 가능한 배치 워크로드는 스팟의 최적 사용 사례입니다. 온디맨드 대비 최대 90% 절감이 가능합니다. 중단 시 AWS는 2분 인터럽트 알림을 제공하며, 이 시간에 체크포인트를 저장하거나 작업을 안전하게 종료할 수 있습니다.
</details>

**Q3.** 운영팀이 여러 EC2 인스턴스가 과프로비저닝되어 있다고 의심합니다. 어떤 도구를 사용해 rightsizing 권장 사항을 얻어야 합니까?

<details><summary>정답 보기</summary>

**AWS Compute Optimizer**입니다. 최근 14일(확장 시 93일)의 CloudWatch 지표를 분석해 EC2·Auto Scaling 그룹·EBS·Lambda·RDS 등에 대한 rightsizing 권장 사항을 제공합니다. AWS Trusted Advisor도 비용 관련 점검을 하지만 Compute Optimizer가 rightsizing에 특화되어 있습니다.
</details>

**Q4.** 낮 시간대에는 트래픽이 많고 야간에는 거의 없는 웹 애플리케이션이 있습니다. 인프라 비용을 줄이는 가장 적합한 전략은?

<details><summary>정답 보기</summary>

**Auto Scaling 그룹 + Scheduled Scaling**입니다. 트래픽 패턴이 예측 가능(낮=고트래픽, 야간=저트래픽)하므로 Scheduled Scaling으로 야간에 인스턴스 수를 최소로 설정합니다. 예측 불가한 급격한 변화는 Target Tracking으로 보완할 수 있습니다. 야간에도 고정 수의 인스턴스를 유지하는 것은 비용 낭비입니다.
</details>

**Q5 (원리).** 왜 Compute Savings Plans 약정이 남아 있는 상태에서 스팟 인스턴스를 대량 사용하더라도 약정 소진이 빨라지지 않는가요?

<details><summary>정답 보기</summary>

Savings Plans는 온디맨드 기준 사용량($/hr)에 할인을 적용하는 구조입니다. 스팟 인스턴스는 EC2가 수요·공급 추세에 따라 가격을 설정·조정하는 자체 할인 가격 메커니즘으로 운영되며, AWS 공식 문서는 스팟 사용량에 Savings Plans가 적용되지 않는다고 명시합니다. 따라서 스팟에서 발생한 비용은 Savings Plans 약정 소진으로 처리되지 않고, 스팟 사용량이 아무리 늘어도 Savings Plans 잔여 약정은 변하지 않습니다.
</details>

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. (작성·대조: 2026-06-07 · 고도화 검수: 2026-06-12)

1. AWS Savings Plans — 개요 — https://docs.aws.amazon.com/savingsplans/latest/userguide/what-is-savings-plans.html
2. Amazon EC2 예약 인스턴스 개요 — https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-reserved-instances.html
3. Amazon EC2 스팟 인스턴스 — https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-spot-instances.html
4. AWS Compute Optimizer — 소개 — https://docs.aws.amazon.com/compute-optimizer/latest/ug/what-is-compute-optimizer.html
5. SAA-C03 공식 시험 가이드 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
6. Compute Savings Plans and Reserved Instances — https://docs.aws.amazon.com/savingsplans/latest/userguide/sp-ris.html (게이트 검수 반영: 2026-06-12)
7. Savings Plans 유형 4종(Compute·Database·EC2 Instance·SageMaker AI) — https://docs.aws.amazon.com/savingsplans/latest/userguide/plan-types.html
8. EC2 예약 인스턴스 요금(Standard 최대 72%·Convertible 최대 66%) — https://aws.amazon.com/ec2/pricing/reserved-instances/
9. EC2 스팟 모범 사례(price-capacity-optimized 권고) — https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-best-practices.html
10. Dedicated Hosts 요금(예약 최대 70% 할인) — https://aws.amazon.com/ec2/dedicated-hosts/pricing/
11. AWS Fargate 요금(초 단위·최소 1분) — https://aws.amazon.com/fargate/pricing/ · AWS Graviton — https://aws.amazon.com/ec2/graviton/
12. RI 유형·Regional vs Zonal·지불 옵션 — https://aws.amazon.com/ec2/pricing/reserved-instances/ · https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-reserved-instances.html
13. On-Demand Capacity Reservation 과금·할인 결합(SP·Regional RI 적용, Zonal RI 미적용) — https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/capacity-reservations-pricing-billing.html
14. Savings Plans가 용량을 예약하지 않음 · SP vs RI 비교 — https://docs.aws.amazon.com/savingsplans/latest/userguide/sp-ris.html
15. 할인 적용 순서·시간당 약정 이월 불가 — https://docs.aws.amazon.com/savingsplans/latest/userguide/sp-applying.html
16. RI Marketplace 조건(Standard만·잔여 1개월 이상·수수료 12%) — https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ri-market-general.html
17. Dedicated Host 요금(호스트 초 단위·예약 최대 70%·SP는 가상 호스트만) — https://aws.amazon.com/ec2/dedicated-hosts/pricing/
18. 스팟 모범 사례(풀 다양화·속성 기반 선택·Spot 배치 점수·온디맨드 폴백 비권장) — https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-best-practices.html
19. ASG 혼합 인스턴스 그룹(온디맨드 기본값·base 용량·비율 반올림·가중치) — https://docs.aws.amazon.com/autoscaling/ec2/userguide/mixed-instances-groups-set-up-overview.html
20. 예측 스케일링(지표 24시간·14일 분석·향후 48시간 예측·스케일 아웃만) — https://docs.aws.amazon.com/autoscaling/ec2/userguide/predictive-scaling-policy-overview.html
21. 웜 풀(기본 크기 = 최대 용량 − 희망 용량) — https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-warm-pools.html
22. Compute Optimizer 지원 리소스·유휴 권고 대상 — https://docs.aws.amazon.com/compute-optimizer/latest/ug/supported-resources.html · 룩백 기간(14·32·93일) — https://docs.aws.amazon.com/help-panel/compute-optimizer/latest/console/rightsizing-lookback.html
23. 프로세서별 가격(AMD 약 10% 저렴)·Windows는 x86 전용 — https://docs.aws.amazon.com/prescriptive-guidance/latest/optimize-costs-microsoft-workloads/right-size-selection.html
24. 인스턴스 범주와 용도 — https://aws.amazon.com/ec2/instance-types/ · 이름 규칙 — https://docs.aws.amazon.com/ec2/latest/instancetypes/instance-type-names.html
25. T 계열 unlimited 모드 과금 — https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/burstable-performance-instances-unlimited-mode.html
26. Optimize CPUs(vCPU 기반 라이선스 절감) — https://aws.amazon.com/ec2/pricing/on-demand/
27. Lambda 요금 구조·계층 요금·무료 티어 — https://repost.aws/knowledge-center/lambda-reduce-costs · 컨테이너 vs 함수 비용 비교 — https://docs.aws.amazon.com/decision-guides/latest/decision-guides/fargate-or-lambda.html
28. ELB 요금 — LCU·NLCU 차원과 **가장 큰 한 차원만 과금** — https://aws.amazon.com/elasticloadbalancing/pricing/ · NLB LCU 예약 — https://docs.aws.amazon.com/help-panel/elasticloadbalancing/latest/console/hp-nlb-lb-capacity-units.html · GWLB LCU 예약 — https://docs.aws.amazon.com/help-panel/elasticloadbalancing/latest/console/hp-glb-lb-capacity-units.html
29. EC2 최대 절전(사용료 없음·EBS는 과금·`stopping` 과금·시작 시 활성화) — https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/Hibernate.html · 인스턴스 수명 주기 — https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-lifecycle.html
30. Well-Architected "소비 모델 채택" — 개발·테스트 중지로 **최대 75%(40시간 vs 168시간)** — https://docs.aws.amazon.com/wellarchitected/latest/cost-optimization-pillar/design-principles.html
31. Instance Scheduler on AWS(EC2·RDS 자동 시작·중지) — https://docs.aws.amazon.com/prescriptive-guidance/latest/optimize-costs-microsoft-workloads/windows-ec2-schedules.html
32. 리전별 요금 차이와 리전 선택(이전 비용 비교·Pricing Calculator) — https://docs.aws.amazon.com/wellarchitected/2025-02-25/framework/cost_pricing_model_region_cost.html
33. 엣지 함수 비용(CloudFront Functions vs Lambda@Edge·무료 티어 부재) — https://aws.amazon.com/cloudfront/pricing/pay-as-you-go/
34. Outposts 요금 모델(3년 기간·지불 옵션 3종·설치·유지보수 포함·자동 갱신) — https://aws.amazon.com/outposts/rack/pricing/

> 📝 **2026-10-19 정정**: ① Convertible RI 할인율을 **최대 66%**로 고쳤습니다(근거 8번). ② Savings Plans를 **4종**으로 갱신하고 **Database Savings Plans**를 추가했습니다(근거 7번). ③ 스팟 할당 전략을 현행 목록으로 바꾸고 **price-capacity-optimized 권고**를 명시했습니다(근거 9번). ④ Graviton 비용 서술에서 근거 없는 "Graviton3 기준" 수식을 빼고 공식 문장(동급 x86 대비 최대 20% 낮은 비용)으로 맞췄습니다(근거 11번). ⑤ Dedicated Host를 "온디맨드 이상 비용"에서 **예약 시 최대 70% 할인·SP 적용 가능**으로 정정했습니다(근거 10번). ⑥ 서버리스 과금을 **Lambda 1 ms / Fargate 초 단위·최소 1분**으로 분리하고 프로비저닝 동시성의 유휴 과금을 더했습니다(근거 11번).

> 📝 **2026-10-22 보강 — 갭 배치 B9b-1(`G-4.2-08`·`11`·`10`·`20`·`09`·`07`)**: ① §2에 **용량 보장과 할인을 가르는 표**(Regional/Zonal RI · ODCR · SP)를 넣고 **Savings Plans는 용량을 예약하지 않는다**는 공식 사실을 명시했습니다 — 특정 AZ 용량이 요건이면 Zonal RI·ODCR입니다(근거 12·13·14번). **할인 적용 순서**(Free Tier → RI → EC2 Instance SP → Compute SP)와 **시간당 약정 이월 불가**(근거 15번), **RI Marketplace** 조건(Standard만·잔여 1개월 이상·수수료 12%, 근거 16번), **Dedicated Host** 과금과 SP는 가상 호스트만 적용(`.metal` 제외, 근거 17번)을 더했습니다. ② §5에 **스팟 용량 풀 = AZ × 인스턴스 유형**·속성 기반 선택·Spot 배치 점수·ASG Capacity Rebalancing·**온디맨드 폴백 비권장**을 넣고, **`price-capacity-optimized`(일반 권고)와 `capacity-optimized`(중단 최소화 절대 우선)를 구분**해 적었습니다(근거 18번). ③ §6에 **혼합 인스턴스 정책**(온디맨드 기본값·base 용량·비율 소수는 온디맨드 쪽으로 올림·가중치, 근거 19번), **예측 스케일링 전제**(지표 24시간·14일 분석·향후 48시간·6시간 갱신·**스케일 아웃만**, 근거 20번), **웜 풀**(기본 크기 = 최대 − 희망, 근거 21번)을 더했습니다. ④ §7에 Compute Optimizer **룩백 32일** 옵션·**상용 라이선스(SQL Server on EC2)**·**유휴 권고 대상 확장**(NAT Gateway·DynamoDB 프로비저닝·ElastiCache·MemoryDB)·옵트인을 넣었습니다(근거 22번). ⑤ §8에 **프로세서·패밀리 선택**(AMD `a` 약 10% 저렴 · ⚠️ **Windows Server는 Graviton 불가** · 범주 6종 · T 계열 `unlimited` 과금 조건 · **Optimize CPUs**, 근거 23·24·25·26번)과 **Lambda/Fargate 과금 축 + 부하 모양별 선택표**(간헐→Lambda / 장시간·배치→Fargate / **24/7 고처리량→약정 붙인 컨테이너**, 근거 27번)를 더했습니다. ⑥ **쓰지 않은 것**(G-02 요율 규율): Lambda 요청·GB-초 단가 · T `unlimited` vCPU-시간 정액 · Optimize CPUs 절감액 · NLB 25% 절감 블로그 사례 · FinOps 월 비용 예시. 무료 티어 **수량**은 요율이 아니라 한도라서 적었습니다. 가드는 `test/saa_gaps_b9b1_test.dart`.

> 📝 **2026-10-22 보강 — 갭 배치 B9b-2(`G-4.2-01`~`06`)**: 문서에 **아예 없던 주제 6행**을 새 절 3개로 넣었습니다(얇은 절 6개보다 읽기 흐름이 낫습니다). ① **§9 로드 밸런서 비용** — ALB **LCU** 4차원(신규 연결·활성 연결·처리 바이트·**규칙 평가**, 처음 10규칙 무료)과 NLB **NLCU** 3차원, ⚠️ **사용량이 가장 큰 한 차원만 과금**, **NLB·GWLB의 LCU 예약**(사용과 무관하게 과금), **호스트·경로 기반 라우팅으로 ALB 통합**이 비용의 가장 큰 축(근거 28번). ② **§10 끄고 줄이는 절감** — WA "소비 모델 채택"의 **40시간 대 168시간 → 최대 75%**, **Instance Scheduler**(⚠️ Scheduled Scaling과 층이 다름), **최대 절전**(사용료 없음 / ⚠️ **RAM을 담은 EBS는 계속 과금**·`stopping` 과금·시작 시 활성화 필요), **수평 vs 수직 스케일링**의 비용 성질(근거 29·30·31번). ③ **§11 배치 결정이 만드는 비용** — 리전별 요금 차이와 **이전 비용 비교·Pricing Calculator**, **CloudFront Functions vs Lambda@Edge**(⚠️ Lambda@Edge는 **무료 티어가 없음**), **Outposts**(3년 기간 구매·지불 3종·**설치·유지보수 포함**·미통보 시 자동 갱신·리전↔Outpost 전송 별도)(근거 32·33·34번). ④ ⚠️ **라이브 q1 정합** — 오답 해설이 "개발·테스트에 Spot은 부적합"이라고 못박으므로, 비프로덕션의 Spot 활용은 **"중단을 허용할 수 있는"** 조건부로만 적었고 가드가 무조건 권유 문구를 금지합니다. ⑤ **쓰지 않은 것**(G-02 요율 규율): CloudFront Functions·Lambda@Edge **호출·GB-초 단가** · AMD·Graviton **인스턴스 시간당 예시 가격** · Outposts **구성 가격** · **리전별 GB 요율**. 리전 이름 자체는 요율이 아니라 예시 지명이라 썼습니다. 가드는 `test/saa_gaps_b9b2_test.dart`.
