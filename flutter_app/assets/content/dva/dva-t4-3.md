---
examGuideTaskId: dva-t4-3
certCode: DVA-C03
domain: 4
domainName: 문제 해결 및 최적화
domainWeightPct: 22
title: 애플리케이션 최적화 (동시성·메모리/컴퓨팅·메시징·캐싱·병목 탐지·AI 최적화)
coversTasks:
  - "4.3"
sources:
  - title: Understanding Lambda Event Function scaling (동시성 쿼터)
    url: https://docs.aws.amazon.com/lambda/latest/dg/lambda-concurrency.html
  - title: Event Function scaling behavior (동시성 스케일링 속도)
    url: https://docs.aws.amazon.com/lambda/latest/dg/scaling-behavior.html
  - title: Configure Lambda Event Function memory
    url: https://docs.aws.amazon.com/lambda/latest/dg/configuration-memory.html
  - title: RDS Proxy concepts and terminology (연결 풀링·다중화)
    url: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/rds-proxy.howitworks.html
  - title: Target tracking scaling policies for Amazon EC2 Auto Scaling
    url: https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-scaling-target-tracking.html
  - title: ChangeMessageVisibility (Amazon SQS API)
    url: https://docs.aws.amazon.com/AWSSimpleQueueService/latest/APIReference/API_ChangeMessageVisibility.html
  - title: DAX and DynamoDB consistency models
    url: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DAX.consistency.html
  - title: Configuring your DAX cluster (TTL·LRU)
    url: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/dax-config-considerations.html
  - title: Choosing between deployment options (ElastiCache)
    url: https://docs.aws.amazon.com/AmazonElastiCache/latest/dg/WhatIs.deployment.html
  - title: Cache behavior settings (CloudFront TTL)
    url: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/DownloadDistValuesCacheBehavior.html
  - title: Cache settings for REST APIs in API Gateway
    url: https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-caching.html
  - title: Use natural language to generate and update CloudWatch Logs Insights queries
    url: https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CloudWatchLogs-Insights-Query-Assist.html
  - title: DVA-C03 공식 시험 가이드 · 콘텐츠 도메인 4 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/developer-associate-03/developer-associate-03-domain4.html
lastVerified: 2026-11-02
---

# 애플리케이션 최적화 (동시성·메모리/컴퓨팅·메시징·캐싱·병목 탐지·AI 최적화)

> **커버하는 공식 Task** — DVA-C03 · 도메인 4 「문제 해결 및 최적화」(22%) · **작업 4.3 AWS 서비스와 기능을 사용하여 애플리케이션을 최적화합니다** (`dva-t4-3`)
> 이 문서는 위 한 작업에 1:1로 매핑되고, 공식 기술 여섯 개(4.3.1~4.3.6)를 모두 덮습니다. 도메인 4에서 **기술이 가장 많은 작업**입니다.

> ⚠️ **C02에서 옮겨온 것이 있습니다** — C02 작업 1.2(Lambda)에 있던 **성능 튜닝(메모리·컴퓨팅)**이 C03에서 이 작업의 **기술 4.3.2**로 들어왔습니다. 그래서 Lambda 메모리와 vCPU 관계를 여기서 묻습니다. 그리고 **기술 4.3.6(AI 도구로 최적화 기회 파악)**이 신설됐습니다.

---

## ✅ 학습 목표 체크리스트

- [ ] Lambda의 **동시성 쿼터와 스케일링 속도**를 구분한다
- [ ] 예약·프로비저닝된 동시성과 **커넥션 풀링**을 용도로 가른다
- [ ] 메모리와 **vCPU의 비례 관계**로 컴퓨팅을 조정한다
- [ ] SQS의 **폴링·가시성·배치**로 메시징 비용과 지연을 줄인다
- [ ] 캐시 네 곳(**ElastiCache·DAX·CloudFront·API Gateway**)을 계층으로 배치한다
- [ ] DAX의 **write-through·네거티브 캐싱·강력한 일관성** 동작을 설명한다
- [ ] CloudFront의 **TTL 세 값**이 언제 적용되는지 안다
- [ ] 기술 4.3.6의 범위를 **확인된 사실**로만 잡는다

---

## 🎯 왜 중요한가

최적화 문항은 **"더 빠르게"가 아니라 "무엇이 한계인가"**를 묻습니다. 같은 "느리다"는 증상이 **동시성 상한**일 때와 **vCPU 부족**일 때, **캐시 미스**일 때 서로 다른 답을 가집니다. 그래서 이 작업은 **한계의 종류를 구분하는 연습**입니다.

그리고 최적화는 거의 항상 **트레이드오프**를 묻습니다 — 메모리를 올리면 단가가 오르지만 실행 시간이 줄고, 캐시 TTL을 늘리면 오리진 부하가 줄지만 **낡은 데이터**를 보여 주고, 롱 폴링은 지연을 조금 늘리는 대신 **빈 응답 요금**을 없앱니다. 어느 쪽이 정답인지는 **지문이 무엇을 우선하라고 적는지**에 달려 있습니다.

---

## ⚡ 시험 직전 요약

> 시험 직전에 이 열 줄만 다시 봅니다. 근거와 맥락은 아래 본문에 있습니다.

- **Lambda 동시성 쿼터는 두 층**입니다 — 계정 기본 **1,000**, 함수 예약은 기본 **최대 900**(⭐ Lambda가 **예약하지 않은 함수용으로 항상 100을 남깁니다**). 두 층 모두 **초당 요청 한도 = 동시성 × 10**
- **스케일링 속도는 쿼터와 다른 개념**입니다 — 리전·함수마다 **10초에 실행 환경 1,000개**(또는 10초에 초당 10,000 요청). ⚠️ **함수별 한도이고 쓰지 않은 분량은 누적되지 않으며** 초과는 **429**입니다
- **메모리는 128~10,240 MB(1 MB 단위)**이고 CPU는 **선형 비례**, ⭐ **1,769 MB에서 1 vCPU**입니다 — 그래서 **단일 스레드 코드는 그 위에서 수확이 줄어듭니다**
- **RDS Proxy**는 풀링에 **다중화(multiplexing)**를 더합니다 — **한 트랜잭션을 하나의 DB 연결로** 처리하고 다음 트랜잭션은 다른 연결을 씁니다. writer·reader **각각 별도 풀**
- **SQS 롱 폴링**은 **`ReceiveMessageWaitTimeSeconds` 0~20초**이고 **0이 숏 폴링**입니다(요청 수준 값이 큐 기본값을 덮어씁니다). 배치 API는 **한 번에 10개**
- **가시성 타임아웃 기본 30초 · 최대 12시간**. in-flight 메시지는 약 **120,000**이고 ⚠️ **표준 큐는 `OverLimit` 오류를 주지만 FIFO는 아무 오류도 주지 않습니다**
- **DAX는 write-through**이고 캐시가 **아이템·쿼리 둘**입니다. ⚠️ **`ConsistentRead=true`와 `TransactGetItems`는 캐시하지 않고 DynamoDB로 통과**시킵니다
- ⚠️ **DAX는 없는 항목도 캐시합니다**(네거티브 캐싱) — TTL 만료·LRU·쓰기 전까지 **DynamoDB를 다시 보지 않습니다**
- **CloudFront TTL**: **Maximum 기본 1년(31,536,000초)** · **Default 기본 1일(86,400초)**. ⚠️ **Maximum은 오리진이 헤더를 줄 때만, Default는 주지 않을 때만** 적용되고, **Minimum TTL > 0이면 `no-cache`·`no-store`·`private`가 있어도 그만큼 캐시**합니다
- **API Gateway 스테이지 캐시**: TTL **기본 300초 · 최대 3,600초 · 0은 비활성**, 응답 **최대 1 MB**, 용량 **0.5~237 GB**, ⚠️ 켜면 **`GET` 메서드만 기본 활성**이고 **시간당 과금**입니다

---

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **예약 동시성(reserved)** | 그 함수에만 할당되는 동시성. **상한 역할도** 한다 |
| **프로비저닝된 동시성(provisioned)** | 미리 준비해 둔 실행 환경. 전용 지표가 따로 있다 |
| **동시성 스케일링 속도** | 쿼터와 별개로 **얼마나 빨리** 환경을 늘릴 수 있는지 |
| **다중화(multiplexing)** | 여러 클라이언트 연결을 **적은 수의 DB 연결**로 처리하는 것 |
| **write-through** | 쓰기를 **캐시와 원본에 함께** 적용하는 캐싱 전략 |
| **네거티브 캐싱** | 조회 결과가 **없다는 사실**을 캐시하는 것 |
| **LRU** | 가장 오래 안 쓴 항목부터 축출하는 알고리즘 |
| **TTL** | 캐시 항목의 유효 기간 |
| **in-flight 메시지** | 소비자가 받았지만 **아직 삭제하지 않은** SQS 메시지 |

---

## 📖 핵심 개념

### 1) 동시성 개념 적용 (기술 4.3.1) {#concurrency}

공식 예시가 **"Lambda에서 프로비저닝한 동시성, EC2 Auto Scaling, 스레드 풀 관리, 연결 풀링"** 넷입니다.

**Lambda 동시성은 "쿼터"와 "속도"가 다른 개념입니다**

| 개념 | 값 | 메모 |
|---|---|---|
| **계정 수준 쿼터** | 기본 **1,000** | Service Quotas로 증설 요청 |
| **함수 수준 예약 합계** | 기본 **최대 900** | ⭐ Lambda가 **예약하지 않은 함수들을 위해 항상 100을 유보**한다. 계정 한도를 2,000으로 올리면 1,900까지 예약 가능 |
| **초당 요청 한도** | **동시성 쿼터 × 10** | 계정·온디맨드·프로비저닝된 동시성·스케일링 동작 모두에 적용 |
| **동시성 스케일링 속도** | **10초에 실행 환경 1,000개**(= 10초에 초당 10,000 요청) | ⚠️ **함수별** 한도라 함수마다 독립 확장. **쓰지 않은 분량은 누적되지 않는다**. 초과 요청은 **스로틀 오류(429)** |

- 현재 쿼터는 **`aws lambda get-account-settings`**로 확인합니다 — `ConcurrentExecutions`가 계정 쿼터, **`UnreservedConcurrentExecutions`**가 **아직 예약에 쓸 수 있는 양**입니다.
- **예약 동시성**은 그 함수 전용 몫을 확보하면서 **동시에 상한**이 됩니다(다른 함수가 계정 동시성을 다 써도 돌 수 있고, 반대로 그 값을 넘지도 못합니다).
- **프로비저닝된 동시성**은 지표가 따로 있습니다 — `ProvisionedConcurrentExecutions` · `ProvisionedConcurrencyUtilization`(구성값 대비 사용률) · **`ProvisionedConcurrencySpilloverInvocations`**(⭐ **프로비저닝된 분량을 다 쓰고 표준 동시성으로 호출된 횟수** — 프로비저닝 값이 부족하다는 신호입니다) · `ProvisionedConcurrencyInvocations`.

**EC2 Auto Scaling**

- **대상 추적(target tracking)**은 지표와 목표값만 정하면 ⭐ **Auto Scaling이 CloudWatch 경보를 만들고 관리**합니다(온도 조절기에 비유됩니다). 예: 그룹 평균 CPU 사용률 50%.
- 그 밖에 **단계(step) 조정**과 **단순(simple) 조정**이 있고, 한 그룹에 **여러 동적 정책**을 둘 수 있습니다.
- ⚠️ **여러 정책이 동시에 조건을 충족하면 "더 큰 용량을 주는 정책"이 우선**합니다 — 축소에서도 같은 기준이 적용됩니다. 그래서 정책을 겹쳐 두면 **의도보다 많이 늘어날 수 있습니다.**

**연결 풀링 — RDS Proxy**

- **연결 풀링**은 연결을 열고 닫는 비용(연결마다의 메모리, TLS 핸드셰이크·인증·기능 협상 같은 CPU 비용)을 줄입니다.
- ⭐ RDS Proxy는 거기에 **다중화(연결 재사용)**를 더합니다 — **한 트랜잭션의 모든 작업을 하나의 백엔드 연결로** 처리하고, **다음 트랜잭션에는 다른 연결**을 쓸 수 있습니다. 그래서 프록시에는 많은 연결을 열어 두고 **DB에는 더 적은 수**만 유지해 **"too many connections" 오류 가능성을 줄입니다.**
- 풀링은 **writer 인스턴스와 reader 인스턴스에 각각 따로** 수행됩니다.
- 서버리스 조합의 이점: 함수가 호출마다 새 연결을 만드는 대신 **기존 연결을 재사용**하고, ⭐ Lambda **IAM 실행 역할로 인증**해 코드에서 DB 자격 증명을 다루지 않아도 됩니다.

**스레드 풀**

- 스레드를 늘려도 **할당된 vCPU 이상으로는 병렬 처리가 되지 않습니다.** Lambda에서 스레드 풀을 키우는 결정은 곧 **메모리(=vCPU) 결정**입니다(아래 2절).

> 🧠 **원리** — 동시성 설계는 **"어디에 줄이 생기는가"**를 옮기는 일입니다. 함수 앞단의 줄은 **동시성 쿼터·스케일링 속도**가 만들고, 함수 뒤의 줄은 **데이터베이스 연결 수**가 만듭니다. 그래서 Lambda를 무한정 확장하면 **병목이 DB로 옮겨 가고**, 그 지점에서 필요한 것은 더 많은 동시성이 아니라 **연결 풀링 또는 예약 동시성으로 유입을 평탄화하는 것**입니다.

### 2) 메모리·컴퓨팅 파워 최적화 (기술 4.3.2) {#memory}

🔁 **C02 작업 1.2에서 옮겨온 영역입니다.**

- Lambda는 **구성한 메모리에 비례해 CPU를 할당**합니다. 범위는 **128 MB ~ 10,240 MB**이고 **1 MB 단위**로 지정하며, ⭐ **1,769 MB에서 1 vCPU에 해당**합니다(초당 1 vCPU-초의 크레딧).
- ⚠️ 그래서 **1,769 MB 아래에서는 1 vCPU 미만**이고, 그 위로는 vCPU가 늘어납니다 — **단일 스레드 코드**는 메모리를 더 올려도 수확이 줄어들고, **병렬화된 코드**만 추가 vCPU를 활용합니다.
- 청구는 **요청 수 + 실행 시간의 GB-초**입니다. ⭐ 그래서 메모리를 올리면 **초당 단가는 오르지만 실행 시간이 줄어** 총액이 내려갈 수 있습니다 — 메모리 튜닝이 **성능 조정이자 비용 조정**인 이유입니다.
- 측정은 로그로 합니다 — Logs Insights의 **`@maxMemoryUsed`·`@memorySize`**(실제 사용량 대 구성값)와 **`@billedDuration`**, 지표의 **`Duration` p95**를 함께 봅니다.
- 콘솔에는 **함수 메모리 권장**을 받아 적용하는 기능이 있습니다. ⚠️ 그 권장의 출처는 **AWS Compute Optimizer**이고 **IAM 관리자 권한으로 옵트인**해야 하며, ⚠️ **DVA-C03 범위 내 서비스 목록에는 Compute Optimizer가 없습니다**(그렇다고 범위 밖 목록에 있는 것도 아닙니다 — 아래 6절의 판정을 따릅니다).
- 다른 축: 메모리를 **과다 할당하면** 쓰지 않는 GB-초를 내고, **과소 할당하면** 타임아웃·느린 응답이 됩니다. 두 방향 모두 지표로 보입니다.

> 🧠 **원리** — Lambda에는 "CPU 설정"이 없습니다. **메모리 슬라이더 하나가 CPU·네트워크 처리량까지 함께 움직이는** 설계이므로, "CPU가 부족하다"는 진단의 해법도 **메모리를 올리는 것**입니다. 그리고 과금이 **GB-초**라 성능과 비용이 **같은 다이얼에 묶여** 있어, 최적점은 "가장 싼 메모리"가 아니라 **단가 × 시간이 최소가 되는 지점**입니다.

### 3) 애플리케이션 메시징 최적화 (기술 4.3.3) {#messaging}

공식 예시는 **"Amazon SQS 대기열, Amazon SNS 팬아웃 패턴"**입니다.

**폴링 방식이 비용과 지연을 정합니다**

- **`ReceiveMessageWaitTimeSeconds`**(큐 기본값)는 **0~20초**이고 **0보다 크면 롱 폴링**, **0이면 숏 폴링**입니다. 요청 수준 값(`WaitTimeSeconds`)이 ⭐ **큐 기본값을 덮어씁니다.**
- 롱 폴링은 **빈 응답을 줄여 요청 수(=비용)를 낮춥니다.** 공식 FAQ는 **가능한 한 높게, 최대 20초**를 권하고 필요하면 **1초까지** 낮출 수 있다고 적습니다.

**가시성 타임아웃과 in-flight 한도**

| 항목 | 값 |
|---|---|
| **가시성 타임아웃** | 기본 **30초** · 최소 **0초** · 최대 **12시간** |
| **`ChangeMessageVisibility`** | 새 타이머가 ⚠️ **호출 시점부터** 다시 센다(받은 시점이 아니다) |
| **저장된(stored) 메시지** | **무제한** |
| **in-flight 메시지** | 약 **120,000**. ⚠️ **표준 큐는 `OverLimit` 오류**를 돌려주지만 **FIFO 큐는 아무 오류도 주지 않는다** |

- 메시지 상태는 **① 생산자가 큐에 보냄 → ② 소비자가 받음 → ③ 삭제됨** 세 가지이고, **②와 ③ 사이가 in-flight**입니다. ⭐ **처리 후 삭제를 빠뜨리면** in-flight 한도에 걸립니다 — 공식 대응은 **처리 후 삭제**와 **큐를 나누는 것**입니다.
- 가시성 타임아웃은 **처리 시간보다 길게** 둬야 중복 수신이 줄어듭니다. 처리가 길어질 수 있으면 `ChangeMessageVisibility`로 **연장**합니다.

**배치와 지연**

- **`SendMessageBatch`·`DeleteMessageBatch`**는 **한 번에 최대 10개**를 다룹니다 — 네트워크 왕복과 요청 수가 줄어 **효율과 비용** 모두 좋아집니다.
- **지연 큐(`DelaySeconds` 큐 속성)**는 큐의 모든 새 메시지를 늦추고, **메시지 타이머**(`SendMessage`·`SendMessageBatch`의 `DelaySeconds`)는 **개별 메시지**를 늦춥니다.

**SNS 팬아웃**

- 하나의 **주제(topic)**에 여러 구독(예: 여러 SQS 큐)을 붙이면 메시지가 **각 구독으로 복제**됩니다 — 생산자 하나가 **여러 소비자 파이프라인**을 먹이는 구조입니다.
- 구독마다 **필터 정책**을 걸어 필요한 메시지만 받게 할 수 있습니다 — 모든 구독자가 모든 메시지를 받아 걸러내는 것보다 **처리량과 비용**이 낫습니다.
- ⭐ 큐를 중간에 두면 소비자가 느릴 때 **버퍼**가 되고(내구성), 주제만 쓰면 **전달 시점에 받을 수 있는 구독자**에게만 갑니다.

> 🧠 **원리** — 메시징 최적화는 대개 **"요청 수를 줄이는 일"**입니다. 롱 폴링은 **빈 요청**을 없애고, 배치는 **왕복**을 줄이고, 팬아웃은 **생산자의 중복 발행**을 없앱니다. 반대로 가시성 타임아웃은 요청 수가 아니라 **중복 처리**를 조절하는 다이얼이므로, "같은 메시지를 두 번 처리한다"는 증상에는 폴링이 아니라 **타임아웃과 삭제 시점**을 봅니다.

### 4) 캐싱 구현 (기술 4.3.4) {#caching}

공식 예시가 **ElastiCache · DAX · CloudFront**입니다. 거기에 API Gateway 스테이지 캐시를 더해 **계층**으로 봅니다.

| 캐시 | 자리 | 무엇을 줄이는가 |
|---|---|---|
| **CloudFront** | 엣지(뷰어에 가장 가깝다) | 오리진까지 가는 왕복·전송 |
| **API Gateway 스테이지 캐시** | API 앞 | 백엔드 통합 호출 |
| **ElastiCache** | 애플리케이션과 DB 사이 | DB 쿼리(범용 인메모리) |
| **DAX** | DynamoDB 전용 | DynamoDB 읽기 |

**ElastiCache — 배포 옵션이 둘입니다**

- **서버리스 캐싱**: 1분 안에 만들고 용량 계획이 필요 없으며, ⭐ **데이터를 3개 가용 영역에 중복 저장**하고 **99.99% 가용성 SLA**를 제공합니다. **VPC 없이 인터넷으로 연결**하는 사용(노트북·서버리스 함수·CI/CD 파이프라인)도 공식 권장 사례입니다.
- **노드 기반 클러스터**: **노드 타입·개수·AZ 배치**를 직접 고릅니다. 최대 **99.99% SLA**로 설계할 수 있고, 트래픽이 예측 가능하고 **용량을 예상해 비용을 통제**하려는 경우에 맞습니다.
- 백업은 **양방향으로 복원**됩니다(노드 기반 → 서버리스, 서버리스 → 노드 기반).

**DAX — DynamoDB 전용이고 일관성 규칙이 많습니다**

- **write-through 캐싱 서비스**이고 클러스터마다 캐시가 **둘**입니다 — **아이템 캐시**(`GetItem`·`BatchGetItem`)와 **쿼리 캐시**(`Query`·`Scan`).
- 고가용성에는 **노드 3개 이상 + 다중 AZ**가 공식 권장입니다. 노드 간 복제는 ⚠️ **최종 일관성**이고 보통 **1초 미만**에 끝나지만, 그 사이 **두 클라이언트가 같은 키에서 다른 값**을 볼 수 있습니다.
- 읽기: 캐시 히트면 즉시 반환, **미스면 DynamoDB에 최종 일관성 `GetItem`**을 수행해 받은 값을 캐시합니다.
- ⚠️ **DAX를 우회해 DynamoDB를 직접 수정하면** 그 항목의 **TTL이 만료될 때까지 DAX와 DynamoDB가 다른 값**을 갖습니다. 우회 쓰기가 있는 설계는 이 불일치를 **감당하도록 만들어야** 합니다.
- 쓰기: DAX 클라이언트의 `PutItem`·`UpdateItem`·`DeleteItem`·`BatchWriteItem`·`TransactWriteItems`는 **DAX와 DynamoDB 둘 다** 갱신하고, ⭐ **TTL 값과 무관하게** 아이템 캐시를 갱신합니다.
- ⚠️ **`ConsistentRead=true`(강력한 일관성 읽기)와 `TransactGetItems`는 DAX가 캐시하지 않습니다** — 요청을 DynamoDB로 **통과시키고 결과만 전달**합니다. DAX가 DynamoDB와 긴밀히 결합돼 있지 않아 **스스로 강력한 일관성을 제공할 수 없기** 때문입니다.
- ⚠️ **네거티브 캐싱**: 항목이 **없다는 사실도 캐시**합니다 — 빈 결과를 저장해 돌려주고, **TTL 만료·LRU 축출·쓰기 작업** 전까지 **DynamoDB를 다시 보지 않습니다.** 쿼리 캐시도 빈 결과 집합을 같은 방식으로 캐시합니다.
- **LRU는 항상 켜져 있고 사용자가 구성할 수 없습니다.** 노드 메모리가 가득 차면 **만료되지 않은 항목도 축출**됩니다. ⚠️ **TTL을 0으로 두면** 아이템 캐시는 **LRU 축출 또는 write-through에서만** 갱신되고 **쿼리 응답은 캐시되지 않습니다.**

**CloudFront — TTL 세 값이 서로 다른 조건에서 쓰입니다**

| 설정 | 언제 적용되는가 | 기본값 |
|---|---|---|
| **Minimum TTL** | 항상(하한) | ⚠️ **0보다 크면 오리진의 `no-cache`·`no-store`·`private`가 있어도 그 시간만큼 캐시한다** |
| **Maximum TTL** | ⚠️ **오리진이 `Cache-Control max-age`·`s-maxage`·`Expires`를 보낼 때만** | **31,536,000초(1년)** |
| **Default TTL** | ⚠️ **오리진이 그 헤더를 보내지 않을 때만** | **86,400초(1일)** |

- 오리진이 `max-age`를 줄 때의 판정: **Minimum < `max-age` < Maximum이면 `max-age`**, **`max-age` < Minimum이면 Minimum**, **`max-age` > Maximum이면 Maximum**을 씁니다. 브라우저는 그와 별개로 **`max-age` 값만큼** 캐시합니다.
- 값은 **캐시 정책에 두는 것이 권장**이고 레거시 캐시 설정에도 둘 수 있습니다. Minimum·Default를 1년보다 크게 바꾸면 **Maximum 기본값이 Default 값으로 따라갑니다.**
- 캐시되는 메서드는 **`GET`·`HEAD`**(+선택적으로 `OPTIONS`)이고, ⭐ **`OPTIONS` 응답은 캐시 키가 분리**되어 따로 저장됩니다. 그 밖의 메서드 응답은 **캐시하지 않습니다.**

**API Gateway 스테이지 캐시**

- TTL은 **기본 300초 · 최대 3,600초**이고 **`0`이면 캐싱 비활성**입니다.
- 캐시할 수 있는 응답 크기는 **최대 1,048,576바이트(1 MB)**이고 ⚠️ **암호화를 켜면 캐시되는 응답 크기가 커질 수 있습니다.**
- 용량(`cacheClusterSize`)은 **0.5 · 1.6 · 6.1 · 13.5 · 28.4 · 58.2 · 118 · 237 GB**입니다. 용량은 캐시 인스턴스의 **CPU·메모리·네트워크 대역폭**을 함께 좌우합니다.
- ⚠️ **캐시 인스턴스 생성에 최대 4분**이 걸리고, **용량을 바꾸면 기존 인스턴스를 없애고 새로 만들어 캐시 데이터가 전부 삭제**됩니다.
- ⚠️ 스테이지 캐싱을 켜면 **`GET` 메서드만 기본 활성**입니다(안전·가용성 때문). 다른 메서드는 **메서드 설정 재정의**로 켭니다.
- 캐싱은 **best-effort**라 **`CacheHitCount`·`CacheMissCount`** 지표로 확인하고, ⚠️ **선택한 캐시 크기에 따라 시간당 과금**되며 **프리 티어에 포함되지 않습니다.**

> 🧠 **원리** — 캐시의 값은 **"요청이 어디까지 가지 않아도 되는가"**로 측정됩니다. 그래서 같은 데이터라도 **뷰어에 가까운 캐시가 가장 많이 절약**하고, 대신 **무효화가 가장 어렵습니다.** TTL 결정은 결국 **"낡은 데이터를 몇 초까지 허용하는가"**이고, DAX의 네거티브 캐싱·CloudFront의 Minimum TTL처럼 **"의도보다 오래 남는 경로"**를 아는 것이 문항의 핵심입니다.

### 5) 성능 병목 탐지 (기술 4.3.5) {#bottlenecks}

공식 예시는 **Amazon CloudWatch**입니다. 도구는 t4-1·t4-2에서 본 것들이고, 여기서는 **병목의 종류별로 어디를 보는지**가 핵심입니다.

| 병목 | 신호 | 어디서 |
|---|---|---|
| **동시성 상한** | `Throttles > 0` + `ConcurrentExecutions`가 상한에 붙는다(계단 모양) | CloudWatch 지표 |
| **스케일링 속도** | 급증 구간에만 `Throttles`가 튄다 | 1분 단위로 좁혀 본 지표 |
| **컴퓨팅·메모리** | `@maxMemoryUsed`가 `@memorySize`에 닿는다 · `Duration` p95가 길다 | Logs Insights · 지표 |
| **다운스트림 지연** | 특정 하위 세그먼트만 길다 | X-Ray 추적 |
| **스트림 적체** | `IteratorAge`(Kafka는 `OffsetLag`)가 증가 | 지표 |
| **DB 연결** | "too many connections" 류 오류 | 애플리케이션 로그 |
| **쿼터** | `AWS/Usage`의 `ThrottleCount`·`CallCount`가 쿼터선에 접근 | 지표 + **`SERVICE_QUOTA()`** |

- **백분위로 봅니다** — `Duration`은 백분위 통계를 지원하고, Logs Insights에서는 **`stats`**와 백분위 함수로 분포를 냅니다. 평균만 보면 **꼬리 지연**이 보이지 않습니다.
- **급변은 해상도 문제입니다** — 커스텀 지표를 **고해상도(1초)**로 올리면 분 단위로는 평탄해 보이던 스파이크가 드러납니다. Auto Scaling의 대상 추적 정책도 **고해상도 지표로 더 빠르게 반응**하도록 만들 수 있습니다.
- **추적은 샘플링이 전제**입니다(기본 초당 1건 + 5%) — 드물게 터지는 지연을 쫓을 때는 **저수지·비율을 올리거나** 조건을 좁힌 **샘플링 규칙**을 추가합니다.
- 조사 비용도 관리합니다 — Logs Insights는 **로그 그룹을 좁히고 시간 범위를 최소로** 하라는 것이 공식 권장입니다.

> 🧠 **원리** — 병목 탐지는 **"무엇이 상한인가"를 하나씩 배제하는 일**입니다. 지표는 **상한에 닿았는지**를, 로그는 **무엇이 거부됐는지**를, 추적은 **어느 구간이 기다렸는지**를 말해 줍니다. 세 가지가 같은 구간을 가리킬 때만 원인이 확정되고, 하나만 보고 고치면 **다음 상한이 바로 나타납니다.**

### 6) AI 도구로 최적화 기회 파악 (기술 4.3.6) {#ai-optimization}

🆕 **C03 신설 기술**입니다. 공식 문구는 "**AWS AI 도구**를 사용하여 최적화 기회를 파악합니다(예: 성능 병목 상태 탐지, 리소스 사용 최적화, 코드 효율성 개선)"입니다.

⚠️ **먼저 알아야 할 판정: 이 문구에 대응하는 "단일 AI 최적화 서비스"는 없습니다.** 가이드가 서비스를 지목하지 않고, 흔히 떠올리는 후보들이 **범위 내 서비스 목록에 없습니다.**

| 후보 | 판정 |
|---|---|
| **AWS Compute Optimizer** | Lambda 메모리 권장의 정본이지만(**옵트인 필요**) ⚠️ **범위 내 목록에 없다** |
| **Amazon CodeGuru Profiler** | ⚠️ **범위 내 목록에 없다** |
| **AWS Lambda Power Tuning** | AWS 서비스가 아니라 **오픈 소스 도구**다 |

> ⚠️ **"목록에 없다"와 "범위 밖이다"는 다릅니다.** 범위 내 목록은 공식적으로 **전수가 아니고**(non-exhaustive), 위 셋은 **범위 밖 목록에도 없습니다.** 그러니 "범위 밖"으로 단정하지 말고 **우리는 정답 보기로 쓰지 않는다**로 운영합니다.

**그래서 받칠 수 있는 범위 내 기능은 둘입니다**

1. **CloudWatch 자연어 쿼리 생성** — 평문 영어로 찾고 싶은 것을 설명하면 **Logs Insights QL · OpenSearch PPL · OpenSearch SQL · CloudWatch Metrics Insights** 쿼리를 만들어 주고, **줄 단위 설명**과 **유도식 갱신**(질문을 덧붙여 쿼리를 다듬기)을 제공합니다. 예시 프롬프트가 공식 문서에 "전송 바이트 기준 상위 100개 소스 IP", **"가장 느린 Lambda 함수 요청 10건 찾기"**로 적혀 있어 **병목 탐지 용도**가 분명합니다.
   - ⚠️ **권한**: `CloudWatchLogsFullAccess` · `CloudWatchLogsReadOnlyAccess` · `AdministratorAccess` · `ReadOnlyAccess` 중 하나로 로그인했거나 **`cloudwatch:GenerateQuery`** 권한이 있어야 합니다.
   - ⚠️ **리전 서비스**이고 일부 리전에서는 프롬프트 처리를 위해 **미국 리전으로 교차 호출**합니다.
2. **Kiro** — 코드 효율 개선·리팩터링을 돕는 범위 내 개발 도구입니다. ⚠️ 다만 **"최적화 기회를 식별한다"고 명시한 공식 문장은 확인하지 못했으므로** 그 표현을 사실로 쓰지 않습니다.

**4.1.5와의 경계**

- **4.1.5(CloudWatch investigations)**는 **인시던트 대응**입니다 — 이미 난 문제의 근본 원인 가설을 제안합니다.
- **4.3.6**은 **평시의 최적화 기회**입니다 — 병목 탐지·리소스 사용·코드 효율.
- 두 기술 모두 ⚠️ **"어떤 AI 서비스가 그것을 해 주는가"를 묻는 단일 정답 구도는 공식 근거가 약합니다.** 확인된 사실(권한 이름 `cloudwatch:GenerateQuery`, 생성 대상 쿼리 언어, 콘솔 전용 동작)을 기준으로 공부합니다.

> 🧠 **원리** — AI 기술 다섯 개(1.1.9 · 3.2.5 · 3.3.9 · 4.1.5 · 4.3.6)는 **같은 도구가 수명 주기의 다른 단계에 붙은 것**입니다. 그래서 외울 것은 서비스 이름 목록이 아니라 **"어느 단계에서, 어떤 권한으로, 콘솔인지 API인지"**입니다. 이 셋만 알면 다섯 기술을 한 틀로 답할 수 있습니다.

---

## ✍️ 시험 포인트

- **"함수 하나에 동시성을 1,000 전부 예약"** → ⚠️ 안 됩니다. **예약 합계는 기본 900**이고 Lambda가 **100을 유보**합니다.
- **"트래픽 급증 때만 스로틀"** → **쿼터**가 아니라 **스케일링 속도**(10초에 1,000)입니다 → 프로비저닝된 동시성을 검토합니다.
- **"프로비저닝을 켰는데 콜드 스타트가 보인다"** → **`ProvisionedConcurrencySpilloverInvocations`**를 확인합니다(분량 초과).
- **"Lambda에 스레드를 늘렸는데 빨라지지 않는다"** → **1,769 MB 미만이면 1 vCPU 미만**입니다 → 메모리를 올립니다.
- **"메모리를 올리면 비용이 오르나"** → 단가는 오르지만 **GB-초**라 **duration이 줄면 총액이 내려갈 수 있습니다.**
- **"빈 응답 요금을 줄이고 싶다"** → **롱 폴링**(`ReceiveMessageWaitTimeSeconds`를 20까지).
- **"같은 메시지를 두 번 처리한다"** → **가시성 타임아웃**(기본 30초)이 처리 시간보다 짧거나 **삭제를 빠뜨렸습니다.**
- **"`OverLimit` 오류"** → in-flight 약 **120,000** 한도입니다. ⚠️ **FIFO는 오류 없이** 막힙니다.
- **"한 번에 여러 메시지를 보내 비용을 줄이자"** → 배치 API는 **10개**까지입니다.
- **"DynamoDB 읽기 지연을 1밀리초 수준으로"** → **DAX**. 단 ⚠️ **강력한 일관성 읽기는 캐시되지 않습니다.**
- **"DAX를 붙였는데 캐시 히트가 없다"** → `ConsistentRead=true`를 쓰고 있거나 TTL·LRU로 축출됐습니다.
- **"없는 키를 계속 조회하는데 DynamoDB 요청이 안 보인다"** → **네거티브 캐싱**입니다.
- **"DAX TTL을 0으로 두면?"** → 아이템 캐시는 **LRU·write-through에서만** 갱신되고 **쿼리 응답은 캐시되지 않습니다.**
- **"오리진에 `no-cache`를 넣었는데 CloudFront가 캐시한다"** → ⚠️ **Minimum TTL > 0**입니다.
- **"오리진이 `max-age`를 안 보낸다"** → **Default TTL**(기본 **1일**)이 적용됩니다.
- **"POST 응답을 CloudFront가 캐시하길 기대"** → **`GET`·`HEAD`(+`OPTIONS`)만** 캐시합니다.
- **"API Gateway 캐시를 켰는데 POST가 캐시되지 않는다"** → 기본은 **`GET`만** 활성입니다.
- **"캐시 용량을 늘렸더니 캐시가 비었다"** → ⚠️ 용량 변경은 **인스턴스를 재생성**합니다.
- **"초 단위 스파이크가 안 보인다"** → **고해상도 지표**(1초)와 **고해상도 경보**(10·30초).
- **"어떤 AI 서비스가 최적화 기회를 알려 주나"** → ⚠️ **단일 서비스 정답이 없습니다.** 확인된 사실은 **`cloudwatch:GenerateQuery`** 같은 권한과 자연어 쿼리 생성 범위입니다.

---

## ⚠️ 흔한 함정 {#pitfalls}

| 함정 | 바로잡기 |
|---|---|
| 계정 동시성 전부를 한 함수에 예약할 수 있다고 본다 | 기본 **900**까지다(Lambda가 **100 유보**) |
| 동시성 쿼터와 스케일링 속도를 같은 것으로 본다 | 쿼터는 **총량**, 속도는 **10초에 1,000**이다 |
| 쓰지 않은 스케일링 속도가 누적된다고 본다 | **누적되지 않는다** |
| 초당 요청 한도를 동시성과 같다고 본다 | **동시성 × 10**이다 |
| 예약 동시성이 상한이 아니라고 본다 | **확보이자 상한**이다 |
| 메모리를 올리면 항상 비용이 오른다고 본다 | **GB-초**라 duration이 줄면 총액이 줄 수 있다 |
| 메모리를 올리면 단일 스레드도 비례해 빨라진다고 본다 | **1,769 MB 이상의 추가 vCPU는 병렬 코드만** 쓴다 |
| Compute Optimizer를 정답 보기로 쓴다 | ⚠️ **범위 내 목록에 없다**(범위 밖도 아니다) |
| 여러 ASG 정책이 평균으로 합쳐진다고 본다 | ⚠️ **가장 큰 용량을 주는 정책이 우선**이다 |
| 대상 추적 정책에 경보를 직접 만든다 | **Auto Scaling이 만들고 관리**한다 |
| RDS Proxy가 연결 수만 모아 준다고 본다 | **다중화**로 트랜잭션 단위 재사용까지 한다 |
| 숏 폴링이 기본값이 아니라고 본다 | **`ReceiveMessageWaitTimeSeconds`가 0이면 숏 폴링**이다 |
| 롱 폴링 대기를 20초 넘게 설정한다 | **최대 20초**다 |
| 가시성 타임아웃 최대가 몇 분이라고 본다 | **12시간**이다 |
| `ChangeMessageVisibility`가 수신 시점부터 센다고 본다 | **호출 시점부터** 다시 센다 |
| FIFO 큐도 in-flight 초과 시 오류를 준다고 본다 | ⚠️ **오류를 주지 않는다** |
| 배치로 수십 개를 보낸다 | **10개**까지다 |
| DAX가 강력한 일관성 읽기를 캐시한다고 본다 | **통과시키고 캐시하지 않는다** |
| DAX가 없는 항목은 매번 DynamoDB를 본다고 생각한다 | **네거티브 캐싱**으로 빈 결과를 캐시한다 |
| DynamoDB를 직접 수정해도 DAX가 곧 맞춰질 것이라고 본다 | **TTL 만료까지 불일치**한다 |
| DAX의 LRU를 끌 수 있다고 본다 | **항상 켜져 있고 구성 불가**다 |
| CloudFront Maximum TTL이 항상 적용된다고 본다 | **오리진이 헤더를 줄 때만**이다 |
| Default TTL이 헤더가 있어도 적용된다고 본다 | **헤더가 없을 때만**이다 |
| `no-store`면 CloudFront가 반드시 캐시하지 않는다고 본다 | ⚠️ **Minimum TTL > 0이면 캐시한다** |
| API Gateway 캐시 TTL 상한을 하루로 본다 | **3,600초**다 |
| 1 MB가 넘는 응답도 API 캐시에 담긴다고 본다 | **1,048,576바이트**가 상한이다 |
| 기술 4.3.6에서 단일 AI 서비스를 고른다 | **공식 근거가 없다** — 확인된 사실을 본다 |

---

## 🧪 자가 점검

**Q1.** 함수가 트래픽 급증 구간에만 스로틀된다. 계정 동시성에는 여유가 있다. 원인과 수치, 대응은? (→ 1) 동시성)

<details><summary>정답 보기</summary>

**동시성 스케일링 속도** 때문입니다 — 리전·함수마다 **10초에 실행 환경 1,000개**(= 10초에 초당 10,000 요청)까지만 늘릴 수 있고, ⚠️ **쓰지 않은 분량은 누적되지 않으며** 요청이 그보다 빨리 들어오면 **429 스로틀 오류**가 납니다. 이 한도는 **함수 수준**이라 함수마다 독립적입니다.

대응은 **프로비저닝된 동시성**(미리 준비된 환경)으로 버스트 구간을 덮는 것이고, 충분한지는 **`ProvisionedConcurrencySpilloverInvocations`**(프로비저닝 분량을 다 쓰고 표준 동시성으로 호출된 횟수)로 확인합니다.

쿼터 쪽 수치도 함께 알아 둡니다 — 계정 기본 **1,000**, 함수 예약 합계 기본 **최대 900**(⭐ Lambda가 예약 없는 함수용으로 **항상 100 유보**), 그리고 **초당 요청 한도 = 동시성 × 10**. 현재 값은 **`aws lambda get-account-settings`**의 `ConcurrentExecutions`·`UnreservedConcurrentExecutions`로 봅니다.
</details>

**Q2.** Lambda 함수를 멀티 스레드로 바꿨는데도 처리 시간이 줄지 않는다. 메모리는 1,024 MB다. 무엇이 문제인가? (→ 2) 메모리·컴퓨팅)

<details><summary>정답 보기</summary>

**1,024 MB에서는 1 vCPU에 못 미칩니다.** Lambda는 **구성한 메모리에 비례해 CPU를 선형 할당**하고 ⭐ **1,769 MB에서 1 vCPU**(초당 1 vCPU-초 크레딧)에 해당하므로, 그 아래에서는 스레드를 늘려도 **병렬 처리가 되지 않습니다.** 범위는 **128 MB ~ 10,240 MB**이고 **1 MB 단위**로 지정합니다.

비용 판단도 함께 합니다 — 청구가 **요청 수 + GB-초**이므로 메모리를 올리면 **초당 단가는 오르지만 실행 시간이 줄어** 총액이 내려갈 수 있습니다. 측정은 Logs Insights의 **`@maxMemoryUsed`·`@memorySize`·`@billedDuration`**과 지표의 **`Duration` p95**로 합니다.

⚠️ 콘솔의 메모리 권장은 **AWS Compute Optimizer**(옵트인 필요)에서 오지만, 그 서비스는 **DVA-C03 범위 내 목록에 없으므로** 문항의 정답 보기로 다루지 않습니다.
</details>

**Q3.** 큐 소비자가 같은 메시지를 두 번 처리하고, 어느 순간 `OverLimit` 오류가 난다. 두 증상의 원인과 수치는? (→ 3) 메시징)

<details><summary>정답 보기</summary>

**중복 처리**는 **가시성 타임아웃**이 처리 시간보다 짧았기 때문입니다 — 기본 **30초**(최소 0, 최대 **12시간**)이고, 처리가 길어질 수 있으면 **`ChangeMessageVisibility`**로 연장합니다. ⚠️ 그때 새 타이머는 **호출 시점부터** 다시 셉니다(메시지를 받은 시점이 아닙니다).

**`OverLimit`**은 **in-flight 메시지 한도**(약 **120,000**)입니다 — 받았지만 **삭제하지 않은** 메시지가 쌓인 것이고, 저장된(stored) 메시지는 무제한입니다. 공식 대응은 **처리 후 삭제**와 **큐를 나누는 것**이며 한도 증설은 지원 요청입니다. ⚠️ **FIFO 큐는 같은 한도에서 아무 오류도 주지 않습니다.**

함께 보는 최적화: **롱 폴링**(`ReceiveMessageWaitTimeSeconds` **0~20초**, 0이면 숏 폴링, 요청 수준 값이 큐 기본값을 덮어씀)과 **배치 API**(한 번에 **10개**).
</details>

**Q4.** DynamoDB에 DAX를 붙였는데 캐시 히트율이 거의 0이고, 지운 항목을 조회하면 계속 빈 결과가 즉시 돌아온다. 각각 왜인가? (→ 4) 캐싱)

<details><summary>정답 보기</summary>

히트율 0: ⚠️ **`ConsistentRead=true`(강력한 일관성 읽기)와 `TransactGetItems`는 DAX가 캐시하지 않습니다** — DynamoDB로 **통과시키고 결과만 전달**합니다(DAX가 DynamoDB와 긴밀히 결합돼 있지 않아 스스로 강력한 일관성을 낼 수 없기 때문입니다). 최종 일관성 읽기로 바꿔야 캐시가 채워집니다.

즉시 돌아오는 빈 결과: ⚠️ **네거티브 캐싱**입니다 — DAX는 **항목이 없다는 사실도 캐시**하고, **TTL 만료·LRU 축출·`PutItem`/`UpdateItem`/`DeleteItem`** 전까지 **DynamoDB를 전혀 보지 않습니다.** 쿼리 캐시도 빈 결과 집합을 같은 방식으로 다룹니다.

보조 사실: DAX는 **write-through**이고 캐시가 **아이템·쿼리 둘**입니다. 노드 간 복제는 **최종 일관성**(보통 1초 미만)이라 노드에 따라 다른 값을 볼 수 있고, 고가용성에는 **노드 3개 이상 다중 AZ**가 권장입니다. ⚠️ **DAX를 우회해 DynamoDB를 직접 수정하면 TTL 만료까지 불일치**하며, **LRU는 항상 켜져 있고 구성할 수 없습니다.**
</details>

**Q5.** 오리진이 `Cache-Control: no-cache`를 보내는데 CloudFront가 콘텐츠를 계속 제공한다. 왜인가? 오리진이 아무 헤더도 보내지 않으면 얼마나 캐시되는가? (→ 4) 캐싱)

<details><summary>정답 보기</summary>

⚠️ **Minimum TTL이 0보다 크기** 때문입니다 — 캐시 정책의 Minimum TTL이 0보다 크면 CloudFront는 오리진 헤더에 **`no-cache`·`no-store`·`private`가 있어도 그 시간만큼 캐시**합니다.

헤더가 전혀 없으면 **Default TTL**이 적용되고 기본값은 **86,400초(1일)**입니다. 참고로 **Maximum TTL의 기본값은 31,536,000초(1년)**이고 ⚠️ **Maximum은 오리진이 `Cache-Control max-age`·`s-maxage`·`Expires`를 보낼 때만, Default는 보내지 않을 때만** 적용됩니다.

오리진이 `max-age`를 줄 때의 판정: **Minimum < `max-age` < Maximum → `max-age`**, **`max-age` < Minimum → Minimum**, **`max-age` > Maximum → Maximum**. 그리고 캐시되는 메서드는 **`GET`·`HEAD`**(+선택적 `OPTIONS`, ⭐ **캐시 키가 분리**됨)뿐입니다.
</details>

**Q6.** API Gateway 스테이지 캐시를 켰다. POST 응답이 캐시되지 않고, 용량을 바꾸자 적중률이 0으로 떨어졌다. 각각 정상인가? (→ 4) 캐싱)

<details><summary>정답 보기</summary>

둘 다 **정상입니다.**

⚠️ 스테이지 캐싱을 켜면 **`GET` 메서드만 기본 활성**됩니다(API의 안전·가용성을 위해). 다른 메서드는 **메서드 설정 재정의**로 켜야 합니다.

⚠️ **용량을 바꾸면 기존 캐시 인스턴스를 없애고 새로 만들어 캐시 데이터가 전부 삭제**됩니다(생성에도 **최대 4분**이 걸립니다).

나머지 수치: TTL **기본 300초 · 최대 3,600초 · 0은 비활성**, 캐시 가능한 응답 크기 **최대 1,048,576바이트**(암호화를 켜면 커질 수 있음), 용량 **0.5 · 1.6 · 6.1 · 13.5 · 28.4 · 58.2 · 118 · 237 GB**, 캐싱은 **best-effort**라 **`CacheHitCount`·`CacheMissCount`**로 확인하며 ⚠️ **시간당 과금이고 프리 티어가 아닙니다.**
</details>

**Q7.** ElastiCache를 처음 도입한다. 두 배포 옵션의 차이와 고르는 기준은? (→ 4) 캐싱)

<details><summary>정답 보기</summary>

**서버리스 캐싱**과 **노드 기반 클러스터** 둘입니다.

**서버리스**: 1분 안에 만들고 **용량을 계획·관리하지 않아도** 되며, ⭐ **데이터를 3개 가용 영역에 중복 저장**하고 **99.99% 가용성 SLA**를 제공합니다. **VPC 없이 인터넷으로 연결**하는 사용(노트북·서버리스 함수·CI/CD 파이프라인)도 공식 사례입니다. 고르는 기준은 **새 워크로드·예측이 어려운 트래픽·가장 쉬운 시작**입니다.

**노드 기반**: **노드 타입·개수·AZ 배치**를 직접 고르고 최대 **99.99% SLA**로 설계합니다. 고르는 기준은 **성능·가용성·비용에 대한 세밀한 제어**, **예측 가능한 트래픽**, **용량 예측으로 비용 통제**입니다.

⭐ 백업은 **양방향 복원**이 됩니다(노드 기반 ↔ 서버리스).
</details>

**Q8.** 기술 4.3.6을 어떻게 공부하는가? 보기에서 무엇을 의심하고, 확인된 사실은 무엇인가? (→ 6) AI 최적화)

<details><summary>정답 보기</summary>

⚠️ **단일 "AI 최적화 서비스"는 없습니다.** 가이드 문구가 서비스를 지목하지 않고, 흔한 후보들은 **범위 내 서비스 목록에 없습니다** — **Compute Optimizer**(Lambda 메모리 권장의 정본이지만 목록에 없음·옵트인 필요) · **CodeGuru Profiler**(목록에 없음) · **Lambda Power Tuning**(AWS 서비스가 아니라 **오픈 소스 도구**). ⚠️ 다만 **"목록에 없다"가 "범위 밖"은 아닙니다**(목록은 전수가 아니고 범위 밖 목록에도 없습니다) — 그래서 **정답 보기로 쓰지 않는다**로 운영합니다.

확인된 사실은 **CloudWatch 자연어 쿼리 생성**입니다 — **Logs Insights QL · OpenSearch PPL · OpenSearch SQL · Metrics Insights** 쿼리를 평문 설명에서 만들고 **줄 단위 설명**과 **유도식 갱신**을 제공하며, 공식 예시 프롬프트에 **"가장 느린 Lambda 함수 요청 10건 찾기"**가 있습니다. ⚠️ **권한은 `CloudWatchLogsFullAccess`·`CloudWatchLogsReadOnlyAccess`·`AdministratorAccess`·`ReadOnlyAccess` 중 하나이거나 `cloudwatch:GenerateQuery`**이고, ⚠️ **리전 서비스**라 일부 리전은 프롬프트 처리를 위해 **미국 리전으로 교차 호출**합니다. **Kiro**는 코드 효율 개선을 돕지만 "최적화 기회 식별"을 명시한 공식 문장은 확인되지 않았습니다.
</details>

---

### 📌 출처

1. Understanding Lambda Event Function scaling (동시성 쿼터) — https://docs.aws.amazon.com/lambda/latest/dg/lambda-concurrency.html
2. Event Function scaling behavior (스케일링 속도) — https://docs.aws.amazon.com/lambda/latest/dg/scaling-behavior.html
3. Types of metrics for Lambda Event Functions (프로비저닝된 동시성 지표) — https://docs.aws.amazon.com/lambda/latest/dg/monitoring-metrics-types.html
4. Configure Lambda Event Function memory — https://docs.aws.amazon.com/lambda/latest/dg/configuration-memory.html
5. What is AWS Lambda? (과금 축 — 요청 + GB-초) — https://docs.aws.amazon.com/lambda/latest/dg/welcome.html
6. Target tracking scaling policies for Amazon EC2 Auto Scaling — https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-scaling-target-tracking.html
7. Dynamic scaling for Amazon EC2 Auto Scaling (여러 정책의 우선순위) — https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-scale-based-on-demand.html
8. RDS Proxy concepts and terminology (풀링·다중화) — https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/rds-proxy.howitworks.html
9. ChangeMessageVisibility (SQS API — 가시성 타임아웃·in-flight 한도) — https://docs.aws.amazon.com/AWSSimpleQueueService/latest/APIReference/API_ChangeMessageVisibility.html
10. Configure long polling for Amazon SQS — https://docs.aws.amazon.com/sdk-for-python/v4/guide/sqs-long-polling.html
11. Amazon SQS FAQs (롱 폴 타임아웃 권장) — https://aws.amazon.com/sqs/faqs/
12. DAX and DynamoDB consistency models — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DAX.consistency.html
13. Configuring your DAX cluster (TTL·LRU) — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/dax-config-considerations.html
14. Choosing between deployment options (ElastiCache) — https://docs.aws.amazon.com/AmazonElastiCache/latest/dg/WhatIs.deployment.html
15. Cache behavior settings (CloudFront TTL 기본값) — https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/DownloadDistValuesCacheBehavior.html
16. Manage how long content stays in the cache (expiration) — https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/Expiration.html
17. Cache settings for REST APIs in API Gateway — https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-caching.html
18. CreateStage (API Gateway API — `cacheClusterSize` 값) — https://docs.aws.amazon.com/apigateway/latest/api/API_CreateStage.html
19. Use natural language to generate and update CloudWatch Logs Insights queries — https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CloudWatchLogs-Insights-Query-Assist.html
20. Publish custom metrics (고해상도 지표) — https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/publishingMetrics.html
21. DVA-C03 공식 시험 가이드 · 콘텐츠 도메인 4 (한국어) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/developer-associate-03/developer-associate-03-domain4.html
22. DVA-C03 범위 내 AWS 서비스 (한국어) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/developer-associate-03/dva-03-in-scope-services.html
