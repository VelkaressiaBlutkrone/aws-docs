---
examGuideTaskId: saa-t2-1
certCode: SAA-C03
domain: 2
domainName: 복원력을 갖춘 아키텍처 설계
domainWeightPct: 26
title: 느슨한 결합 아키텍처 — SQS·SNS·EventBridge·Step Functions
coversTasks:
  - "2.1"
sources:
  - title: Amazon SQS — 개발자 가이드 (공식)
    url: https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/welcome.html
  - title: Amazon SNS — 개발자 가이드 (공식)
    url: https://docs.aws.amazon.com/sns/latest/dg/welcome.html
  - title: Amazon EventBridge — 사용 설명서 (공식)
    url: https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-what-is.html
  - title: AWS Step Functions — 개발자 가이드 (공식)
    url: https://docs.aws.amazon.com/step-functions/latest/dg/welcome.html
  - title: SAA-C03 공식 시험 가이드 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
  - title: Amazon SNS 데드레터 큐(구독 단위·100,015회) (공식)
    url: https://docs.aws.amazon.com/sns/latest/dg/sns-dead-letter-queues.html
  - title: Amazon SNS 메시지 전달 재시도 정책 (공식)
    url: https://docs.aws.amazon.com/sns/latest/dg/sns-message-delivery-retries.html
  - title: Amazon SQS 메시지 쿼터 — 파티션 300 TPS·배칭 3,000·고처리량 리전별 상한 (공식)
    url: https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/quotas-messages.html
  - title: SQS 최대 메시지 페이로드 1 MiB 상향 (공식 공지)
    url: https://aws.amazon.com/about-aws/whats-new/2025/08/amazon-sqs-max-payload-size-1mib/
  - title: Amazon SQS 가시성 타임아웃 — in-flight 메시지와 쿼터 (공식)
    url: https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-visibility-timeout.html
  - title: Application integration 개요 — Amazon MQ 엔진·표준 프로토콜 (공식)
    url: https://docs.aws.amazon.com/whitepapers/latest/aws-overview/application-integration.html
  - title: Amazon MQ 마이그레이션 가이드 — 상용 브로커 이전·교차 리전 복제 (공식)
    url: https://docs.aws.amazon.com/amazon-mq/latest/migration-guide/concept-chapter-about.html
  - title: Amazon EventBridge Pipes — 단일 소스·단일 타깃·보강 (공식)
    url: https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-pipes.html
  - title: Amazon AppFlow — 목적별 통합 서비스 (공식 백서)
    url: https://docs.aws.amazon.com/whitepapers/latest/patterns-for-ingesting-saas-data-into-aws-data-lakes/purpose-built-integration-service.html
lastVerified: 2026-10-21
---

# 느슨한 결합 아키텍처 — SQS·SNS·EventBridge·Step Functions

> **커버하는 공식 Task** — SAA-C03 · 도메인 2 「복원력을 갖춘 아키텍처 설계」(26%) · **Task 2.1 확장 가능하고 느슨하게 결합된 아키텍처 설계** (`saa-t2-1`)
> 이 문서는 위 한 Task에 1:1로 매핑됩니다. "decouple·비동기·여러 구독자·순서 보장·단계별 워크플로우"는 전부 이 4개 서비스로 수렴합니다.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명할 수 있어야 합니다.

- [ ] **SQS 메커니즘** — 생산자·소비자 Pull 모델, 가시성 타임아웃, DLQ, 롱폴링을 설명할 수 있다
- [ ] **Standard vs FIFO 큐 선택** — 각각의 보장 범위와 처리량 제약을 비교할 수 있다
- [ ] **SNS Pub/Sub** — 토픽에 발행하면 여러 구독자에게 Push되는 구조를 그릴 수 있다
- [ ] **팬아웃 패턴** — SNS + SQS를 결합해 하나의 이벤트를 여러 소비자가 독립 처리하는 이유를 설명할 수 있다
- [ ] **EventBridge 이벤트 버스** — 규칙 기반 라우팅, 스케줄러, SaaS 통합 시점을 안다
- [ ] **Step Functions 워크플로우** — Standard vs Express 차이와 오케스트레이션이 필요한 상황을 안다
- [ ] **서비스 선택 기준** — SQS·SNS·EventBridge·Step Functions 중 시나리오별 최적 선택을 도출할 수 있다

---

## 🎯 왜 중요한가

- 도메인 2(26%)는 SAA 시험의 두 번째 비중입니다. 그 중 Task 2.1은 "단일 실패점 제거"와 "부하 흡수"를 설계 결정으로 묻습니다.
- 시험은 "컴포넌트 간 직접 호출 → 하나가 죽으면 전체 실패"라는 결합(coupled) 구조를 제시하고, 어떤 서비스로 어떻게 디커플링하는지 고르게 합니다.
- CLF에서 SQS·SNS를 개념으로 봤다면, SAA는 **어떤 보장이 필요한지(순서·중복·정확히 1회)**, **누가 누구에게 전달하는지(1:1 vs 1:N)**, **이벤트 패턴 매칭이 필요한지**를 설계 결정으로 묻습니다.

---

## 🔤 먼저 알아야 할 용어

이 문서를 읽는 데 필요한 기초 용어입니다. 이미 알면 건너뛰세요.

| 용어 | 영문 | 한 줄 풀이 |
|---|---|---|
| **큐** | Queue | 메시지를 순서대로 저장하고 소비자가 꺼내 가는 버퍼 — 생산자와 소비자의 속도 차이를 흡수 |
| **토픽** | Topic | SNS의 발행·구독 채널 — 발행자가 메시지를 보내면 구독자 전원에게 동시 Push |
| **가시성 타임아웃** | Visibility Timeout | 소비자가 메시지를 수신한 후 다른 소비자에게 보이지 않는 잠금 시간 — 만료 전 삭제 않으면 재노출 |
| **DLQ** | Dead-Letter Queue | 처리 재시도 한도를 초과한 메시지를 격리하는 별도 큐 — 장애 분석·수동 재처리용 |
| **팬아웃** | Fan-out | 하나의 이벤트를 여러 소비자가 각자 독립 사본으로 처리하는 1:N 배포 패턴 |
| **이벤트 패턴** | Event Pattern | EventBridge 규칙에서 JSON 속성 조건으로 특정 이벤트만 선별하는 필터 |
| **상태 머신** | State Machine | Step Functions의 실행 단위 — 상태(State)와 전이(Transition)로 워크플로우를 정의 |
| **롱폴링** | Long Polling | SQS가 빈 큐에서 최대 20초 대기 후 응답 — 빈 응답 횟수를 줄여 비용·CPU 절감 |

---

## 📖 핵심 개념 {#core-concepts}

### 1) 느슨한 결합(Decoupling)이란 {#decoupling}

> 공식 정의(SQS): **"분산 소프트웨어 시스템과 컴포넌트를 통합하고 분리(decouple)할 수 있는 보안·내구성 있는 호스팅 큐 서비스."**

컴포넌트 A가 컴포넌트 B를 **직접 동기 호출**하면 B가 느려지거나 다운될 때 A까지 블록됩니다. 중간에 큐·토픽·이벤트 버스를 끼우면 A는 메시지를 "보내고 잊어버리고(fire-and-forget)" 계속 동작하고, B는 자기 속도로 처리합니다. 이것이 느슨한 결합의 핵심입니다.

> 🧠 원리: 왜 느슨한 결합은 단순히 "시스템을 나눈다"가 아니라 중간 버퍼를 반드시 포함하는 개념으로 정의될까요?
> 컴포넌트를 나눠도 직접 동기 호출이 남아 있으면 다운스트림 지연이 업스트림 스레드를 점유해 결합이 유지됩니다.
> 큐·토픽·이벤트 버스가 중간에 있으면 생산자는 소비자의 가용성·속도를 신경 쓰지 않고 메시지를 쓰고 반환할 수 있어, 두 컴포넌트의 수명 주기가 진정으로 독립됩니다.
> 이 독립성이 장애 격리(소비자 다운 → 생산자 무관)와 독립 스케일링(소비자만 확장)이라는 복원력 이점을 동시에 제공합니다.

---

### 2) Amazon SQS — 메시지 큐 (Pull 모델) {#sqs}

생산자(Producer)가 큐에 메시지를 넣으면, 소비자(Consumer)가 **직접 폴링해서** 가져갑니다. 소비자가 처리하는 동안 메시지는 큐에서 숨겨지고(Visibility Timeout), 성공하면 삭제, 실패하면 재노출됩니다.

#### SQS Standard vs FIFO 비교 (★ 시험 핵심)

| 항목 | Standard 큐 | FIFO 큐 |
|---|---|---|
| 전달 보장 | 최소 1회(at-least-once) | 정확히 1회(exactly-once) |
| 순서 | Best-effort (비보장) | 엄격한 FIFO 보장 |
| 처리량 | 거의 무제한 | 기본 300 TPS (배치 시 3,000 TPS), 고처리량 모드 지원 |
| 중복 가능성 | 있음 | 없음 (중복 제거 ID 사용) |
| 적합한 상황 | 처리량 우선, 순서·중복 무관 | 금융 거래·주문·재고 — 순서·중복 민감 |

#### SQS 핵심 기능

| 기능 | 설명 | 기본값 / 범위 |
|---|---|---|
| **Visibility Timeout** | 소비자가 메시지를 받은 후 다른 소비자에게 안 보이는 시간. 처리 완료 전 만료되면 메시지가 재노출 | 30초 (0초 ~ 12시간) |
| **DLQ (Dead-Letter Queue)** | 최대 수신 횟수를 초과한 실패 메시지를 별도 큐로 격리. 장애 분석·재처리에 활용 | 별도 큐 ARN 지정 |
| **Long Polling** | 큐가 비어 있을 때 최대 20초 대기 후 응답. 빈 응답 빈도를 낮춰 비용·CPU 절감 | 기본 Short Polling |
| **메시지 보존 기간** | 큐에 저장되는 최대 기간. 초과 시 자동 삭제 | 기본 4일 (최대 14일) |

**SQS 세부 사양 (★ 시험 수치):**

| 항목 | 값 |
|---|---|
| **최대 메시지 크기** | **1 MiB** — 2025-08에 256 KiB에서 상향됐습니다(Standard·FIFO 모두, 전 상업 리전·GovCloud). 더 큰 본문은 **Extended Client Library**로 S3에 두고 참조만 보냅니다 |
| **지연 큐(Delay Queue)** | 기본·최소 **0초**, 최대 **15분(900초)** |
| **in-flight 메시지** | Standard·FIFO 각 **약 120,000건**(수신했으나 아직 삭제되지 않은 메시지). Standard는 증액 가능, FIFO는 AWS Support 문의 |
| **메시지 속성** | 메시지당 10개 |
| **배치** | 한 요청에 최대 10개 |

- **in-flight 한도에 닿으면** Short polling은 `OverLimit` 오류를 돌려주고, **Long polling은 오류 없이 새 메시지를 주지 않습니다.** 처리 후 즉시 삭제가 1차 대책이고, 그다음이 큐·소비자 분산입니다.
- **DLQ 리드라이브 정책** — 큐에 `maxReceiveCount`를 설정하면 그 횟수를 넘겨 수신된 메시지가 DLQ로 이동합니다. 위 표의 "최대 수신 횟수"가 이 값입니다.
- **FIFO 고처리량 모드** — 기본(비고처리량)은 **파티션당 API 액션별 300 TPS**이고 배칭하면 **3,000 msg/s**(300 호출 × 10건)입니다. 고처리량 모드의 상한은 **리전마다 다릅니다** — 비배칭 TPS가 버지니아·오레곤·아일랜드 **70,000**, 그 외는 더 낮아 최저 **2,400**이고, 배칭하면 각 10배(**700,000** ~ **24,000** msg/s)입니다. 수치를 외우기보다 **"리전 의존 + 배칭이 10배"** 구조를 기억하세요.
- 처리량을 더 올리려면 **메시지 그룹 ID를 여러 개로 분산**합니다 — 한 그룹 안의 메시지는 순차 처리되므로 그룹을 나눠야 병렬성이 올라갑니다.

> ⚠️ **공식 자료 간 불일치 — 메시지 크기.** SQS **쿼터 페이지**는 아직 `Message Size = 256 Kilobytes`로 적혀 있습니다(2026-10-21 확인). 상향은 What's New 공지로 발표됐고 Lambda의 SQS 이벤트 소스 매핑도 1 MiB를 지원합니다(출처 8·9번). **1 MiB를 현행으로** 보되, 구 수치를 본 자료는 날짜를 확인하세요.

> 🧠 원리: 왜 SQS는 소비자가 직접 폴링(Pull)하는 구조를 쓸까요?
> 서버가 소비자에게 Push하려면 소비자의 주소·상태를 추적하는 레지스트리가 필요하고, 소비자가 느리거나 다운되면 Push가 실패해 재시도 로직이 복잡해집니다.
> Pull 모델에서는 소비자가 준비됐을 때만 큐에 접근하므로 소비자 수·속도 변화에 관계없이 큐가 메시지를 안전하게 보존하고, 소비자 확장(오토스케일)이 큐 측 변경 없이 가능합니다.
> Visibility Timeout은 이 Pull 모델의 "처리 중 잠금" 메커니즘으로, 다운된 소비자가 처리 중이던 메시지를 타임아웃 후 다른 소비자가 이어받아 처리할 수 있게 합니다.

---

### 3) Amazon SNS — Pub/Sub (Push 모델) {#sns}

SNS는 **토픽(Topic)** 기반 발행-구독 서비스입니다. 발행자(Publisher)가 토픽에 메시지를 보내면, 토픽에 구독(Subscribe)된 모든 엔드포인트에 **동시에 Push**됩니다.

지원 구독자 유형:

- Amazon SQS
- AWS Lambda
- HTTP/HTTPS 엔드포인트
- 이메일
- SMS (문자 메시지)
- 모바일 푸시 알림
- Amazon Data Firehose

SNS는 **Application-to-Application(A2A)** 와 **Application-to-Person(A2P)** 메시징을 모두 지원합니다.

> 🧠 원리: 왜 SNS는 구독자 유형마다 별도 서비스를 만들지 않고 토픽 하나에서 SQS·Lambda·HTTP·SMS를 동시에 지원할까요?
> 이벤트 발행자는 소비자의 처리 방식을 알 필요가 없어야 느슨한 결합이 완성됩니다 — 토픽이 추상화 레이어가 돼 발행자는 "토픽에 썼다"만 알면 됩니다.
> SNS가 여러 구독자 유형을 내부적으로 처리하므로, 새로운 소비자를 추가해도(Lambda 구독 추가 등) 발행자 코드를 전혀 바꾸지 않아도 됩니다.
> 이 분리 덕분에 소비자의 프로토콜(HTTP vs SQS vs SMS)이 달라도 발행자는 단일 API 호출로 전체에 전달할 수 있어, 이종 시스템 통합 비용이 크게 줄어듭니다.

---

### 4) 팬아웃 패턴 (SNS + SQS) — ★ 단골 출제 {#fanout}

"하나의 이벤트를 여러 소비자가 독립적으로 처리"할 때 사용합니다.

```
이벤트 발생
    │
    ▼
SNS 토픽
    ├─── SQS 큐 A ──► 소비자 A (주문 처리)
    ├─── SQS 큐 B ──► 소비자 B (재고 차감)
    └─── SQS 큐 C ──► 소비자 C (데이터 분석)
```

SNS가 SQS·Lambda 같은 **AWS 관리형 엔드포인트**로 전달할 때는 서버 측 오류에 대해 **최대 100,015회·23일**까지 재시도하고, **구독 단위 DLQ**를 붙이면 재시도를 모두 소진한 메시지도 보존됩니다(클라이언트 측 오류는 재시도 없이 폐기). 그래서 **SQS를 끼우는 진짜 이유는 유실 방지가 아니라** 소비자별 **버퍼링·독립 속도·재처리**입니다 — 각 소비자가 자기 속도로 Pull하고, 실패 메시지는 자기 큐의 DLQ로 격리됩니다.

> 🧠 원리: 왜 팬아웃 패턴에서 SNS → Lambda 직접 구독 대신 SNS → SQS → Lambda 조합을 권장할까요?
> SNS가 Lambda를 직접 Push해도 서버 측 오류라면 최대 100,015회·23일 재시도하고 구독 단위 DLQ로 보존되므로, 권장 이유는 "메시지 유실"이 아니라 **흐름 제어**입니다.
> SQS를 중간에 두면 메시지가 큐에 쌓인 채 Lambda가 여유가 생길 때 직접 Pull하므로, 소비자가 처리 속도를 스스로 조절하고(버퍼링) 느린 소비자가 다른 소비자의 전달을 막지 않습니다.
> 또 각 소비자 큐마다 독립적인 DLQ와 보존 기간을 둘 수 있어 재처리 시점을 소비자별로 고를 수 있으므로, 소비자 A의 실패가 소비자 B의 처리에 영향을 주지 않는 결함 격리를 제공합니다.

---

### 5) Amazon EventBridge — 이벤트 버스 {#eventbridge}

EventBridge는 **이벤트 패턴 기반 라우팅** 서비스입니다. AWS 서비스 이벤트, 커스텀 애플리케이션 이벤트, 서드파티 SaaS 이벤트를 수집해 규칙(Rule)에 따라 여러 대상에 라우팅합니다.

주요 구성 요소:

| 구성요소 | 역할 |
|---|---|
| **이벤트 버스(Event Bus)** | 이벤트를 수신하는 파이프라인. 기본(default)·커스텀·파트너 버스 구분 |
| **규칙(Rule)** | 이벤트 패턴 매칭 후 대상(Target)으로 전달. 하나의 버스에 규칙 여러 개 가능 |
| **이벤트 패턴** | JSON 속성 기반 필터링. 특정 서비스·상태·리전만 선택 가능 |
| **EventBridge Scheduler** | Cron·Rate 표현식 또는 일회성 스케줄로 태스크 트리거 |
| **파트너 이벤트 소스** | Datadog·Zendesk·Salesforce 등 SaaS 서비스 이벤트 직접 수신 |

> SQS·SNS와의 차이: EventBridge는 **이벤트 속성 기반으로 어디로 보낼지 규칙을 정의**합니다. SQS는 버퍼링, SNS는 "전체 구독자에게 전파"가 주목적이지만, EventBridge는 **패턴 매칭 라우팅과 SaaS 통합**이 핵심입니다.

> 🧠 원리: 왜 EventBridge는 SNS처럼 "전체 구독자에게 전파"하지 않고 이벤트 속성 기반 규칙으로 선택 라우팅할까요?
> 이벤트 소스가 늘어날수록 모든 소비자가 모든 이벤트를 받아 자체 필터링하면 소비자 측에 불필요한 처리 비용과 코드가 쌓입니다.
> EventBridge 규칙이 중앙에서 필터링을 담당하면 소비자는 "내가 관심 있는 이벤트만 받는다"는 전제로 설계할 수 있어, 소비자 코드가 단순해집니다.
> SaaS 파트너 이벤트 소스는 AWS 외부 시스템의 이벤트를 직접 이벤트 버스에 주입하므로, 별도 폴링 코드 없이 외부 이벤트를 AWS 워크플로우에 연결할 수 있습니다.

---

### 6) AWS Step Functions — 워크플로우 오케스트레이션 {#step-functions}

Step Functions는 여러 AWS 서비스 호출을 **상태 머신(State Machine)** 으로 조율합니다. 분기(Choice)·병렬(Parallel)·반복(Map)·재시도(Retry)·오류 처리(Catch)·사람 승인(WaitForTaskToken) 등을 코드 없이 시각적으로 정의합니다.

#### Standard vs Express 워크플로우 비교

| 항목 | Standard | Express |
|---|---|---|
| 실행 보장 | **정확히 1회(exactly-once)** | 최소 1회(at-least-once) |
| 최대 실행 시간 | **1년** | **5분** |
| 실행 속도 | 2,000 실행/초 | 100,000 실행/초 |
| 가격 | 상태 전환 수 기준 | 실행 수 × 지속 시간 기준 |
| 실행 이력 | Step Functions 콘솔에서 직접 조회 | CloudWatch Logs로 전송 |
| 적합한 상황 | 장기·감사 필요·중요 트랜잭션 | 고빈도·단기·IoT·스트리밍 처리 |

> 🧠 원리: 왜 Step Functions는 Lambda 코드로 직접 분기·재시도를 구현하지 않고 상태 머신을 별도로 정의할까요?
> 분기·재시도·오류 포착 로직을 Lambda 코드에 직접 쓰면 비즈니스 흐름이 인프라 코드와 섞여 테스트·변경이 어렵고, 흐름 전체를 한눈에 파악하기 어렵습니다.
> 상태 머신 정의(JSON/YAML)는 실행 흐름을 선언적으로 표현하므로 Step Functions 콘솔에서 그래프로 시각화되고, 실패한 상태와 입출력을 단계별로 추적할 수 있습니다.
> Standard 워크플로우는 각 상태 전이를 이력으로 기록하므로 감사 요건 충족에 유리하고, Express는 CloudWatch Logs로 대량 고빈도 이벤트 처리에 적합합니다.

---

### 7) SQS vs SNS vs EventBridge 선택 비교표 (★ 시험 핵심) {#messaging-comparison}

| 요구사항 | 최적 선택 | 이유 |
|---|---|---|
| 컴포넌트 간 부하 흡수·버퍼링 | **SQS** | 소비자가 자기 속도로 Pull. 트래픽 폭증 완충 |
| 1:N 동시 알림 (여러 구독자) | **SNS** | 토픽 하나로 모든 구독자에 Push |
| 여러 구독자 + 재시도·처리 보장 | **SNS + SQS 팬아웃** | SQS가 각 소비자 큐를 안정적으로 버퍼링 |
| 이벤트 속성 기반 조건 라우팅 | **EventBridge** | 이벤트 패턴 매칭 규칙으로 선택 전달 |
| SaaS 서비스 이벤트 수신 | **EventBridge** | 파트너 이벤트 소스 네이티브 지원 |
| 스케줄 기반 트리거 | **EventBridge Scheduler** | Cron/Rate 표현식, 일회성 스케줄 |
| 복잡한 다단계 분기·재시도 | **Step Functions** | 상태 머신으로 전체 흐름 오케스트레이션 |
| 순서 보장 + 중복 제거 | **SQS FIFO** | 엄격한 FIFO, exactly-once 처리 |
| 장기 실행·감사 필요 워크플로우 | **Step Functions Standard** | 최대 1년, 실행 이력 콘솔 조회 |
| 고빈도·단기 워크플로우 | **Step Functions Express** | 100,000 실행/초, 5분 이내 |

> 🧠 원리: 왜 이 네 서비스(SQS·SNS·EventBridge·Step Functions)는 기능이 겹쳐 보여도 AWS가 별도로 유지할까요?
> SQS는 "생산자·소비자 속도 차이 흡수"라는 단일 목적에 최적화돼 있어 단순·저비용이지만 조건 라우팅·다중 구독을 지원하지 않습니다.
> SNS는 Push 기반 1:N 동보 전송에 최적화돼 있어 구독자 유형이 다양하지만 이벤트 속성 필터링 깊이가 EventBridge보다 얕습니다.
> EventBridge는 복잡한 이벤트 패턴 매칭과 외부 SaaS 소스 연결이 강점이고, Step Functions는 상태 전이·재시도·감사 추적이 강점입니다 — 각각이 대체 불가한 축에서 최적화돼 있어 하나로 합치면 복잡성과 비용이 오히려 증가합니다.

---

### 8) 공식 범위의 나머지 통합 서비스 — Amazon MQ·Pipes·AppFlow {#other-integration-services}

공식 시험 가이드의 in-scope **Application Integration**은 **AppFlow · EventBridge · MQ · SNS · SQS · Step Functions** 6종입니다. §2~§7이 네 종을 다뤘으니 나머지를 채웁니다.

**Amazon MQ — 관리형 메시지 브로커**

- **Apache ActiveMQ Classic·RabbitMQ**를 AWS가 프로비저닝·설정·유지관리합니다.
- **업계 표준 API·프로토콜**을 그대로 씁니다 — **JMS·NMS·AMQP·STOMP·MQTT·WebSocket**. 그래서 공식 서술이 "대부분의 경우 메시징 코드를 다시 쓸 필요가 없다"고 적습니다.
- ActiveMQ 엔진은 **IBM MQ·TIBCO EMS** 같은 상용 브로커의 이전을 단순화합니다(JMS 호환 → 최소 코드 변경). RabbitMQ 엔진은 **교차 리전 데이터 복제**를 제공합니다.
- **시험 신호**: "기존 브로커를 쓰는 애플리케이션을 **코드 변경 없이** 옮겨야" → **Amazon MQ**. 반대로 표준 프로토콜 호환이 요구 사항에 없다면 브로커를 운영할 이유가 약합니다 — 그때는 SQS·SNS의 서버리스 모델이 더 단순합니다.

**Amazon EventBridge Pipes — 점대점 통합**

- **단일 소스에서 단일 타깃**으로 이벤트를 보냅니다. 이벤트 버스·규칙이 pub/sub 팬아웃이라면 **Pipes는 점대점**입니다.
- 소스와 타깃 사이에 **필터링**(일치한 이벤트만 과금)과 **보강(enrichment)**을 둘 수 있습니다.
- 보강 수단은 **API destination · API Gateway · Lambda · Step Functions**(Express 워크플로만)입니다. 보강은 **동기** 호출이고 응답은 최대 **6 MB**이며, 배칭할 때 배치 안의 순서를 유지합니다.
- **시험 신호**: "SQS 큐 → (주문에 고객 정보를 채워) → Step Functions"처럼 **중간에 데이터를 보강해야 하는 1:1 연결** → Pipes. 여러 구독자에게 뿌려야 하면 버스·규칙이나 SNS입니다.

**Amazon AppFlow — SaaS ↔ AWS 데이터 전송**

- 완전 관리형 통합 서비스로 **SaaS 애플리케이션**(Salesforce·Marketo·Slack·ServiceNow 등)과 **AWS 서비스**(S3·Redshift 등) 사이에서 데이터를 **양방향**으로 옮깁니다.
- 실행 트리거는 **스케줄 · 비즈니스 이벤트 실시간 대응 · 온디맨드** 세 가지입니다.
- 플로우 안에서 **데이터 변환**(마스킹·필드 연결)과 **검증·필터링**을 구성해, 별도 처리 단계 없이 바로 쓸 수 있는 데이터를 만듭니다.
- **전송 중 자동 암호화**를 하고, PrivateLink와 통합된 SaaS는 트래픽이 **퍼블릭 인터넷을 지나지 않도록** 제한할 수 있습니다.
- **시험 신호**: "코드 없이 SaaS 데이터를 S3·Redshift로 정기 수집" → AppFlow. EventBridge의 SaaS 파트너 소스는 *이벤트*를 받는 것이고 AppFlow는 *레코드·데이터셋*을 옮기는 것이 갈림길입니다.

> 🧠 원리: 왜 AWS는 SQS·SNS가 있는데도 Amazon MQ를 따로 두었을까요?
> SQS·SNS는 **AWS 고유 API**로 호출하는 서버리스 서비스입니다 — 운영 부담이 없는 대신 클라이언트가 그 API에 맞춰 작성돼 있어야 합니다.
> 수십 년 된 기업 애플리케이션은 **JMS·AMQP 같은 표준 위에 쓰여** 있고, 그 코드를 SQS API로 바꾸는 것은 이전 비용의 큰 몫입니다.
> Amazon MQ는 그 표준을 말하는 **브로커 자체**를 관리형으로 제공해, 코드를 그대로 두고 인프라만 옮기게 합니다 — 공식 서술의 "메시징 코드를 다시 쓸 필요가 없다"가 그 뜻입니다.
> 그래서 선택은 성능이 아니라 **"기존 코드가 무엇을 말하는가"**로 갈립니다.

---

### 9) 확장·통합 수단 선택 지도 {#integration-selection-map}

Task 2.1은 "확장 가능하고 느슨하게 결합된 아키텍처"입니다. 어느 수단을 어디서 고르는지 한 번에 보고, **세부 수치는 담당 문서로 넘깁니다** — 같은 수치를 두 곳에 두면 한쪽만 갱신되는 드리프트가 생깁니다.

| 무엇을 분리·확장하나 | 수단 | 세부 정본 |
|---|---|---|
| 생산자·소비자 **속도 차이** 흡수 | SQS(버퍼링) | 이 문서 §2 |
| 하나의 이벤트를 **여러 구독자**에게 | SNS · EventBridge 버스 | §3 · §4 · §5 |
| **조건에 맞는 이벤트만** 라우팅 | EventBridge 규칙 | §5 |
| **1:1 연결 + 중간 보강** | EventBridge Pipes | §8 |
| **상태 전이·재시도·감사** | Step Functions | §6 |
| **기존 표준 프로토콜 브로커** 이전 | Amazon MQ | §8 |
| **SaaS 데이터** 정기 수집 | AppFlow | §8 |
| **요청 처리 용량** 확장 | Lambda 동시성 · ASG | `saa-t2-2` · `saa-t2-3` |
| **읽기 부하** 분산 | **읽기 전용 복제본** · 캐시 | `saa-t3-5` · `saa-t3-6` |
| **DB 엔진·용량** 선택 | 목적별 DB | `saa-t3-5` · `saa-t3-6` |

> **읽기 전용 복제본은 언제 쓰나** — 읽기 질의가 쓰기보다 훨씬 많고 약간의 복제 지연을 감수할 수 있을 때입니다. 복제본은 **쓰기 상한을 올리지 못합니다**(라이터는 하나) — 쓰기가 한계면 복제본이 답이 아니고 스케일 업·샤딩·큐 버퍼링 쪽입니다. 엔진별 복제본 상한과 복제 방식의 정본은 **`saa-t3-5`**이니 수치는 그 문서에서 확인하세요.

---

## ✍️ 시험 포인트

- **SQS = 버퍼링·디커플링**: "다운스트림이 트래픽 폭증을 못 버틴다" → SQS 큐로 완충 후 소비자 오토스케일.
- **SNS = 1:N 동시 Push**: "하나의 이벤트를 여러 시스템에 동시에 알려야" → SNS 토픽. SQS는 1개 메시지를 1개 소비자만 가져갑니다.
- **팬아웃 = SNS + SQS 조합**: SNS 직접 구독도 AWS 관리형 엔드포인트(SQS·Lambda)라면 **100,015회·23일 재시도 + 구독 단위 DLQ**가 있습니다. **SQS를 끼우는 이유**는 소비자별 **버퍼링·독립 속도·재처리**입니다.
- **EventBridge = 이벤트 패턴·SaaS·스케줄**: "특정 조건의 이벤트만 골라서 보내야" 또는 "SaaS 이벤트를 AWS로 받아야" → EventBridge.
- **Step Functions = 오케스트레이션**: "Lambda A → 조건 분기 → Lambda B 또는 C → 오류 시 재시도" 같은 복잡한 흐름 → Step Functions. 단순 트리거는 Lambda 직접 호출로 충분.
- **Standard vs FIFO**: 처리량이 우선이고 순서·중복이 무관 → Standard. 금융·주문처럼 순서·중복이 민감 → FIFO. FIFO는 처리량이 제한되므로 과도 사용 주의.
- **Visibility Timeout 설정**: 처리 시간보다 짧으면 메시지가 중복 처리됩니다. 충분히 넉넉하게 설정하고, 처리 완료 시 즉시 삭제.
- **DLQ 연결**: 실패 메시지를 그냥 버리면 원인 분석 불가. DLQ를 반드시 연결해 장애 메시지를 격리·재처리합니다.

---

## ⚠️ 흔한 함정 {#common-pitfalls}

1. **"SQS로 여러 구독자에게 동시 알림"** → 불가. SQS는 1개 메시지를 **1개 소비자만** 가져갑니다. 여러 구독자에게 동시 전달하려면 SNS(또는 SNS+SQS 팬아웃)가 필요합니다.
   *(원리: §1 — SQS Pull 모델은 메시지를 먼저 수신한 소비자가 잠그므로 동일 메시지의 동시 복수 전달 구조가 아니다.)*

2. **"순서가 필요 없는데 FIFO를 선택"** → FIFO는 Standard보다 처리량이 낮고 비용이 높습니다. 순서·중복 제거가 필요하지 않은 경우 Standard 큐를 사용하세요.
   *(원리: §2 — FIFO의 exactly-once 보장은 중복 제거 ID 추적과 엄격한 순서 관리에 처리량을 소모하므로, 불필요한 제약을 감수할 이유가 없다.)*

3. **"SNS 직접 구독은 재시도가 없어 메시지를 버린다"** → SQS·Lambda 같은 AWS 관리형 엔드포인트에는 서버 측 오류 시 **최대 100,015회·23일** 재시도와 **구독 단위 DLQ**가 있습니다(재시도를 소진했을 때만 폐기). 소비자마다 처리 속도·재처리 시점을 따로 두어야 할 때 **SNS + SQS 팬아웃**을 씁니다.
   *(원리: §4 — SNS의 전달 정책이 유실 방지를 이미 담당하므로, SQS를 끼우는 값은 소비자별 버퍼링·독립 속도·재처리에 있다.)*

4. **"Visibility Timeout이 짧으면 메시지가 사라진다"** → 짧으면 처리 중에 다른 소비자에게 다시 노출되어 **중복 처리**가 발생합니다. 만료 시 메시지가 삭제되는 것이 아니라 재노출됩니다.
   *(원리: §2 — Visibility Timeout은 처리 중 잠금 시간으로, 만료는 삭제가 아닌 잠금 해제이므로 중복 소비가 발생한다.)*

5. **"EventBridge는 SNS 대체"** → 두 서비스는 목적이 다릅니다. SNS는 1:N Push 알림, EventBridge는 **이벤트 속성 기반 조건 라우팅**이 강점입니다. SaaS 이벤트 수신·복잡한 필터링 → EventBridge, 단순 다중 알림 → SNS.
   *(원리: §5 — SNS는 구독자 전체에 전파, EventBridge는 이벤트 JSON 속성 조건 매칭으로 선별 라우팅하는 다른 추상화 레이어다.)*

6. **"Step Functions Express로 1년짜리 워크플로우 실행"** → Express는 최대 **5분**입니다. 장기 실행·감사 이력이 필요하면 Standard를 사용하세요.
   *(원리: §6 — Express는 상태 전이 이력을 콘솔에 보존하지 않아 고빈도·단기에 최적화됐고, 장기 상태 추적은 Standard의 설계 목적이다.)*

7. **"SQS DLQ 없이 운영"** → DLQ 없이 운영하면 처리 실패 메시지가 계속 재시도되거나 조용히 버려집니다. 프로덕션 큐에는 항상 DLQ를 설정하고 알람을 연결합니다.
   *(원리: §2 — DLQ는 최대 수신 횟수 초과 메시지를 격리해 장애 메시지가 큐를 오염시키지 않도록 하는 결함 격리 메커니즘이다.)*

---

## 🧪 자가 점검

> 아래는 학습용 자가 점검입니다. (정식 검증 문항은 별도 문항 파일 참조)

**Q1.** 전자상거래 플랫폼에서 주문이 들어올 때마다 "재고 차감", "결제 처리", "배송 알림" 세 시스템이 각각 독립적으로 이벤트를 받아야 합니다. 가장 적절한 아키텍처는?

<details><summary>정답 보기</summary>

**SNS 토픽 + SQS 팬아웃** 패턴을 사용합니다. 주문 이벤트를 SNS 토픽에 발행하고, 세 개의 SQS 큐(재고·결제·배송)가 각각 구독합니다. 각 큐에는 처리 Lambda 또는 컨슈머가 연결됩니다. SNS 직접 Push만 쓰면 재시도·DLQ 보장이 약하므로, SQS를 끼워 각 소비자가 자기 속도로 안정 처리하고 실패 시 DLQ로 격리합니다.
</details>

**Q2.** 금융 결제 시스템에서 메시지가 **입력된 순서대로** 처리되어야 하고, **동일 메시지가 두 번 처리되는 것을 방지**해야 합니다. 어떤 SQS 큐 유형을 선택하나요?

<details><summary>정답 보기</summary>

**SQS FIFO 큐**를 선택합니다. FIFO는 메시지 순서를 엄격하게 보장하고, 중복 제거 ID(Deduplication ID)를 통해 exactly-once 처리를 지원합니다. 처리량은 Standard보다 낮지만, 순서·중복 민감 시스템에서는 FIFO가 필수입니다.
</details>

**Q3.** EC2 Auto Scaling 그룹의 인스턴스 수가 변경될 때, 특정 조건(scale-out 이벤트만)을 만족하는 경우에만 Slack 알림 Lambda를 호출하고 싶습니다. 가장 적합한 서비스는?

<details><summary>정답 보기</summary>

**Amazon EventBridge**를 사용합니다. EventBridge는 이벤트 패턴 기반 규칙으로, Auto Scaling 이벤트 중 "EC2 Instance Launch Successful" 같은 특정 속성만 필터링해 Lambda를 트리거할 수 있습니다. SNS는 조건 필터링 없이 전체 구독자에게 Push하므로 세밀한 이벤트 패턴 라우팅에는 EventBridge가 적합합니다.
</details>

**Q4.** 사용자 가입 완료 시 "(1) 이메일 발송 Lambda → (2) KYC 검증 API 호출 → (3) 성공이면 계정 활성화, 실패면 관리자 알림"의 순서대로 처리해야 합니다. 각 단계에서 실패 시 재시도·오류 포착이 필요하고, 전체 실행 이력을 감사해야 합니다. 어떤 서비스를 사용하나요?

<details><summary>정답 보기</summary>

**AWS Step Functions Standard 워크플로우**를 사용합니다. 다단계 분기(Choice 상태)·재시도(Retry)·오류 포착(Catch)을 상태 머신으로 정의할 수 있고, Standard는 실행 이력을 Step Functions 콘솔에서 직접 조회할 수 있어 감사 요건을 충족합니다. Lambda를 직접 연결·분기하는 복잡한 흐름을 코드 없이 조율하는 것이 Step Functions의 핵심 용도입니다.
</details>

**Q5 (원리).** 왜 SQS FIFO 큐는 Standard 큐보다 처리량이 낮을까요?

<details><summary>정답 보기</summary>

**순서 보장과 중복 제거에 필요한 추가 조율 비용 때문입니다.** Standard 큐는 메시지를 여러 서버에 분산 저장하고 어떤 서버에서든 꺼내도 되므로 수평 확장이 자유롭습니다. FIFO 큐는 동일 메시지 그룹(MessageGroupId) 내에서 순서를 보장하려면 특정 파티션에 메시지를 순서대로 배치해 소비자도 같은 파티션을 순서대로 처리해야 하고, 중복 제거 ID(DeduplicationId)는 5분 창 내 동일 ID를 추적·거부하는 상태를 유지해야 하므로, 이 두 제약이 수평 분산 확장을 제한합니다.
</details>

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. URL은 2026-06-07 WebFetch로 200 응답 확인. (작성·대조: 2026-06-07 · 고도화 검수: 2026-06-12)

1. Amazon SQS — 개발자 가이드 — https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/welcome.html
2. Amazon SNS — 개발자 가이드 — https://docs.aws.amazon.com/sns/latest/dg/welcome.html
3. Amazon EventBridge — 사용 설명서 — https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-what-is.html
4. AWS Step Functions — 개발자 가이드 — https://docs.aws.amazon.com/step-functions/latest/dg/welcome.html
5. Amazon SNS 데드레터 큐(DLQ는 구독 단위, 관리형 엔드포인트 100,015회·23일) — https://docs.aws.amazon.com/sns/latest/dg/sns-dead-letter-queues.html
6. Amazon SNS 메시지 전달 재시도(AWS 관리형 엔드포인트 전달 정책) — https://docs.aws.amazon.com/sns/latest/dg/sns-message-delivery-retries.html
7. SAA-C03 공식 시험 가이드 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
8. Amazon SQS 메시지 쿼터(파티션당 300 TPS·배칭 3,000·고처리량 모드 리전별 상한·보존 기간) — https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/quotas-messages.html
9. SQS 최대 메시지 페이로드 256 KiB → **1 MiB** 상향 공지(Standard·FIFO·전 상업 리전·Lambda 이벤트 소스 매핑 포함) — https://aws.amazon.com/about-aws/whats-new/2025/08/amazon-sqs-max-payload-size-1mib/
10. Amazon SQS 가시성 타임아웃 — in-flight 약 120,000건·Short/Long polling 동작 차이 — https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-visibility-timeout.html
11. Application integration 개요 — Amazon MQ(ActiveMQ Classic·RabbitMQ·JMS·NMS·AMQP·STOMP·MQTT·WebSocket) — https://docs.aws.amazon.com/whitepapers/latest/aws-overview/application-integration.html
12. Amazon MQ 마이그레이션 가이드(IBM MQ·TIBCO EMS 이전·RabbitMQ 교차 리전 복제) — https://docs.aws.amazon.com/amazon-mq/latest/migration-guide/concept-chapter-about.html
13. Amazon EventBridge Pipes(단일 소스→단일 타깃·필터 과금·보강 동기 호출·응답 6 MB·Express만) — https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-pipes.html
14. Amazon AppFlow — 목적별 통합 서비스(SaaS↔AWS·스케줄/이벤트/온디맨드·변환·전송 중 암호화·PrivateLink) — https://docs.aws.amazon.com/whitepapers/latest/patterns-for-ingesting-saas-data-into-aws-data-lakes/purpose-built-integration-service.html

> 📝 **2026-10-21 보강(갭 `G-2.1-02`·`G-2.1-03`·`G-2.1-05`·`G-2.1-09`, 배치 B5)**: ① §2에 **SQS 세부 사양**(메시지 **1 MiB**·지연 큐 900초·in-flight 약 120,000·`maxReceiveCount`·FIFO 고처리량의 **리전 의존** 상한)을 더했습니다(근거 8·9·10번). 기존 "300 TPS·배치 3,000"은 공식과 일치해 그대로 두고 그 위에 확장했습니다. ② **§8 신설** — 공식 in-scope Application Integration 6종 중 빠져 있던 **Amazon MQ·EventBridge Pipes·AppFlow**(근거 11·12·13·14번). ③ **§9 신설** — 확장·통합 수단 선택 지도. DB·읽기 복제본 수치는 복제하지 않고 `saa-t3-5`·`saa-t3-6`을 가리킵니다. 기존 §1~§7의 번호·앵커는 바꾸지 않았습니다.

> 📝 **2026-10-19 정정**: SNS 직접 구독의 재시도 서술을 정정했습니다. SQS·Lambda 같은 AWS 관리형 엔드포인트는 서버 측 오류 시 **최대 100,015회·23일** 재시도하고 **구독 단위 DLQ**를 붙일 수 있습니다(근거 5·6번). 팬아웃에 SQS를 끼우는 이유를 "유실 방지"에서 **버퍼링·독립 속도·재처리**로 고쳤습니다(§4 원리·시험 포인트·함정 3).
