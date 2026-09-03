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
lastVerified: 2026-06-12
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
| **예약 인스턴스 — Convertible RI** | 최대 54% | 1년 또는 3년 | 인스턴스 패밀리 변경 가능성 있음 |
| **Savings Plans — Compute** | 최대 66% | 1년 또는 3년 | EC2+Fargate+Lambda, 가장 유연 |
| **Savings Plans — EC2 Instance** | 최대 72% | 1년 또는 3년 | 특정 패밀리·리전 고정, 높은 절감 |
| **스팟(Spot)** | 최대 90% | 없음 | 중단 가능 배치·스테이트리스 |
| **전용 호스트(Dedicated Host)** | 온디맨드 이상 비용 | 선택적 | BYOL 라이선스·규제 컴플라이언스 |

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

### 3) Savings Plans 유형 {#savings-plans-types}

| 유형 | 적용 대상 | 특징 |
|---|---|---|
| **Compute Savings Plans** | EC2 + Fargate + Lambda | 인스턴스 패밀리·리전·OS·테넌시 무관. 가장 유연 |
| **EC2 Instance Savings Plans** | 특정 EC2 패밀리·리전 | 절감률 높음, 유연성 낮음 |
| **SageMaker Savings Plans** | Amazon SageMaker | SageMaker 인스턴스 전용 |

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
스팟 플릿 전략:
- lowestPrice   : 가장 저렴한 풀 우선 (비용 최소화)
- diversified   : 여러 풀에 분산 (가용성 최대화)
- capacityOptimized : 가용 용량이 가장 많은 풀 (중단 최소화)
```

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

**스팟 + 오토스케일링 혼합:**

Auto Scaling 그룹에서 온디맨드(기반 용량)와 스팟(초과 용량)을 혼합하면 안정성을 유지하면서 비용을 낮출 수 있습니다.

### 7) Rightsizing — AWS Compute Optimizer {#rightsizing}

> 공식 정의: "AWS 리소스의 구성과 활용도 지표를 분석해 rightsizing 권장 사항을 제공하고 유휴 리소스를 식별하는 서비스."

**분석 대상 리소스:**

- Amazon EC2 인스턴스
- EC2 Auto Scaling 그룹
- Amazon EBS 볼륨
- AWS Lambda 함수
- Amazon ECS 서비스(Fargate)
- Amazon RDS 및 Aurora 데이터베이스

**작동 방식:**

- 기본 분석 기간: **최근 14일** CloudWatch 지표
- 확장 기간(유료): **93일** (Enhanced Infrastructure Metrics 기능)
- CPU 사용률·메모리·네트워크·디스크 I/O 분석 후 과프로비저닝 또는 저프로비저닝 판정

**권장 결과 유형:**

- 과프로비저닝 → 더 작은 인스턴스 유형 권장
- 저프로비저닝 → 더 큰 인스턴스 유형 권장
- 유휴(Idle) → 중지 또는 삭제 권장

> 🧠 원리: 왜 Compute Optimizer는 자동 변경 없이 권장 사항만 제안하는 방식으로 동작할까요?
> 인스턴스 크기 변경은 재시작을 수반하며, 운영 중인 서비스에 다운타임이 생길 수 있습니다.
> CloudWatch 지표는 과거 패턴을 반영하지만, 미래 수요 변화나 애플리케이션 특수 요건(메모리 핀닝, 라이선스 제약 등)까지 파악할 수 없습니다.
> 실제 변경 여부와 시점은 운영자가 판단해야 하므로, 자동 실행이 아닌 권장 사항 제공 방식이 의도치 않은 장애를 막는 안전한 설계 방향입니다.

### 8) 서버리스 및 Graviton의 비용 이점 {#serverless-graviton}

**서버리스 (Lambda·Fargate):**

- 사용한 시간만 밀리초 단위로 과금 — 유휴 시 비용 없음
- 서버 프로비저닝·관리 비용 제거
- 예측 불가·간헐적 워크로드에 적합

**AWS Graviton (ARM 기반):**

- 동일 성능 대비 온디맨드 가격 약 20% 저렴 (Graviton3 기준)
- Savings Plans와 결합 시 추가 절감 가능
- 지원: EC2(m7g·c7g·r7g 등), Lambda, Fargate, RDS, ElastiCache 등
- 조건: 애플리케이션이 ARM 아키텍처에서 동작해야 함 (컨테이너·인터프리터 언어 전환 용이)

> 🧠 원리: 왜 서버리스(Lambda·Fargate) 과금은 유휴 시 비용이 발생하지 않을까요?
> EC2는 인스턴스가 실행 중인 시간 전체에 대해 과금되므로, 요청이 없는 유휴 시간도 동일하게 청구됩니다.
> Lambda와 Fargate는 요청이 들어올 때만 컨테이너·실행 환경을 프로비저닝하고 완료되면 자원을 반환하므로, 대기 상태에서 점유하는 컴퓨팅이 없어 과금도 발생하지 않습니다.
> 이 구조 덕분에 간헐적·예측 불가 워크로드는 항상 켜둔 인스턴스 없이도 수요에 맞춰 처리됩니다.

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

6. **"Standard RI와 Convertible RI의 할인율이 같다."** → Standard RI가 더 높은 할인(최대 72%)을 제공하지만, 인스턴스 유형 교환이 불가합니다. Convertible RI는 교환 가능한 대신 할인율이 낮습니다(최대 54%).
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
