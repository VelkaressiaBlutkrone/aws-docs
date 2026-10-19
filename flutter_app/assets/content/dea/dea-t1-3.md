---
examGuideTaskId: dea-t1-3
certCode: DEA-C01
domain: 1
domainName: 데이터 수집 및 변환
domainWeightPct: 34
title: 데이터 파이프라인 오케스트레이션 (워크플로·복원력·알림)
coversTasks:
  - "1.3"
sources:
  - title: Choosing workflow type in Step Functions (공식 문서)
    url: https://docs.aws.amazon.com/step-functions/latest/dg/choosing-workflow-type.html
  - title: Discover service integration patterns in Step Functions (공식 문서)
    url: https://docs.aws.amazon.com/step-functions/latest/dg/connect-to-resource.html
  - title: Map workflow state — Step Functions (공식 문서)
    url: https://docs.aws.amazon.com/step-functions/latest/dg/state-map.html
  - title: Handling errors in Step Functions workflows (공식 문서)
    url: https://docs.aws.amazon.com/step-functions/latest/dg/concepts-error-handling.html
  - title: Overview of workflows in AWS Glue (공식 문서)
    url: https://docs.aws.amazon.com/glue/latest/dg/workflows_overview.html
  - title: DEA-C01 공식 시험 가이드 도메인 1 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain1.html
lastVerified: 2026-10-19
---

# 데이터 파이프라인 오케스트레이션 (워크플로·복원력·알림)

> **커버하는 공식 Task** — DEA-C01 · 도메인 1 「데이터 수집 및 변환」(34%) · **Task 1.3 데이터 파이프라인 오케스트레이션** (`dea-t1-3`)
> Skill이 4개뿐이지만 출제 밀도는 높습니다. "수집 → 변환 → 적재 → 검증 → 알림" 사이의 **의존·재시도·분기·병렬**을 코드에 묻지 않고 오케스트레이션 서비스에 맡기는 것이 이 Task의 전제입니다.

---

## ✅ 학습 목표 체크리스트

- [ ] **오케스트레이터 5종**(Step Functions · MWAA · Glue 워크플로 · EventBridge · Lambda)을 요구사항으로 고를 수 있다
- [ ] Step Functions **Standard vs Express**를 실행 시간·실행 의미론·과금·지원 패턴으로 구분한다
- [ ] **서비스 통합 패턴 3종**(Request Response · `.sync` · `.waitForTaskToken`)이 각각 언제 쓰이는지 안다
- [ ] **Map 상태 Inline vs Distributed** 선택 기준을 숫자로 말할 수 있다
- [ ] **Retry·Catch·Redrive**로 오류를 다루고, 재시도가 비용에 미치는 영향을 안다
- [ ] MWAA와 **MWAA Serverless**의 차이, 그리고 프로비저닝 MWAA가 필요한 조건을 설명한다
- [ ] 복원력 설계 축(재시도·멱등성·실패 격리·체크포인트·다중 AZ)을 구현 수단과 연결한다
- [ ] **SNS·SQS**로 알림·완충을 구성하고 DLQ·가시성 제한 시간·긴 폴링을 설정한다

---

## 🎯 왜 중요한가

- 오케스트레이션 문항은 **"운영 부담 · 기존 자산 · 실행 시간 · 호출 대상"** 네 축으로 갈립니다. 서비스 설명을 외우는 것보다 이 축에 숫자를 붙여 두는 쪽이 정답률을 올립니다.
- 복원력(1.3.2)은 Well-Architected **Data Analytics Lens 설계 원칙 6**의 어휘를 그대로 씁니다 — 의존성 도식화 → 실패 모니터링 → 알림 → 복구 자동화 → DR.
- 알림(1.3.4)은 "실패를 어떻게 사람에게 전달하나"를 묻습니다. **Glue 실패 → EventBridge 규칙 → SNS** 같은 조합이 정석 답입니다.

---

## 🔤 먼저 알아야 할 용어

| 용어 | 영문 | 한 줄 풀이 |
|---|---|---|
| **상태 머신** | state machine | Step Functions의 워크플로 정의. 상태(Task·Choice·Map 등)의 연결 |
| **상태 전이** | state transition | 한 상태에서 다음 상태로 넘어가는 것. Standard 과금 단위이며 **재시도도 전이로 계산** |
| **DAG** | directed acyclic graph | Airflow가 워크플로를 표현하는 방향성 비순환 그래프(Python으로 작성) |
| **멱등성** | idempotency | 같은 작업을 여러 번 해도 결과가 같은 성질. 재시도 설계의 전제 |
| **DLQ** | dead-letter queue | 처리에 반복 실패한 메시지를 따로 모아 두는 큐 |
| **가시성 제한 시간** | visibility timeout | SQS에서 한 소비자가 받은 메시지가 다른 소비자에게 보이지 않는 시간 |
| **콜백** | callback | 외부 작업이 끝났다고 알려 줄 때까지 워크플로를 멈추는 패턴(태스크 토큰) |

---

## 📖 핵심 개념

### 1) 오케스트레이터 선택 지도 {#orchestrator-choice}

| 서비스 | 이럴 때 | 제약·과금 | 시험 단서 |
|---|---|---|---|
| **Step Functions Standard** | Glue·Athena·EMR을 직접 호출하고 분기·병렬·재시도·**최대 1년** 실행·사람 승인까지 한곳에서 | 서버리스 · **상태 전이 수(재시도 포함) 과금** · 실행당 이력 **25,000 이벤트** | "시각적 워크플로", "작업이 끝날 때까지 대기", "승인 대기" |
| **Step Functions Express** | **5분 이내** 고빈도 이벤트 처리(IoT 수집·스트리밍 변환) | 실행 수·시간·메모리 과금 · `.sync`·콜백·Distributed Map **미지원** | "초당 수만 건", "멱등 작업" |
| **Amazon MWAA** | 기존 **Airflow DAG(Python)** 와 오픈소스 이식성이 중요 | 사전 배포·클래스 선택 · **DAG가 돌지 않아도 시간당 비용** | "Apache Airflow", "기존 DAG 이전" |
| **MWAA Serverless** | 변동·간헐 워크로드를 Airflow 방식으로 | **실행 시간만 과금** · YAML(DAG factory) 정의 · **Airflow UI 직접 접근 불가** | "Airflow인데 유휴 비용 없이" |
| **Glue 워크플로** | Glue 크롤러·잡·트리거 체인을 Glue 안에서 시각화·관리 | 워크플로당 잡·크롤러·트리거 합계 **100 이하 권장** | "크롤러 완료 후 잡 시작" |
| **EventBridge** (버스·Scheduler·Pipes) | **무엇을 언제 시작할지** — 이벤트 라우팅·예약·점대점 연결 | Scheduler는 재시도 정책·DLQ 설정 가능 | "이벤트 도착 시 시작", "cron" |
| **Lambda 단독** | 짧게 끝나는 단일 처리 | **한 번 호출 최대 15분** · 함수 안에서 오케스트레이션은 안티패턴 | "15분 초과", "함수가 함수를 순차 호출" |

> 공식 선택 기준은 간결합니다. **오픈소스·이식성 우선이면 MWAA, 비용·성능 우선이면 Step Functions.** 또 Step Functions는 실행 중인 워크플로가 없으면 비용이 없고, MWAA는 DAG가 돌지 않아도 비용이 발생합니다.

> 🧠 원리: 왜 "함수 안에서 오케스트레이션"이 안티패턴일까요?
> 단일 Lambda가 다른 함수들을 순차 호출하면 순서·데이터 전달·오류 분류·재시도·보상 로직이 모두 그 함수의 코드가 됩니다.
> 그 코드는 테스트하기 어렵고, 15분 벽에 걸리며, 중간 실패 시 어디까지 진행됐는지 외부에서 볼 수 없습니다.
> Step Functions는 그 제어 흐름을 **상태 머신 정의와 실행 이력**으로 밖으로 끌어내므로, 재시도 정책과 실패 지점이 데이터로 남아 재개(redrive)까지 가능해집니다.

### 2) Step Functions — Standard vs Express {#standard-vs-express}

상태 머신 유형은 **만들 때 정하고 이후 바꿀 수 없습니다.**

| 항목 | Standard | Express |
|---|---|---|
| 최대 실행 시간 | **1년** | **5분** |
| 실행 시작률(공식 비교표) | 초당 2,000 | 초당 100,000 |
| 실행 의미론 | **exactly-once** | 비동기 **at-least-once** / 동기 at-most-once |
| 과금 | **상태 전이 수**(재시도 포함) | 실행 수·지속 시간·메모리 |
| 이력 | Step Functions가 **90일 보관**, 실행당 **25,000 이벤트** | 보관하지 않음 — **CloudWatch Logs 로깅 필요** |
| 통합 패턴 | Request Response + **`.sync`** + **`.waitForTaskToken`** | Request Response만 |
| Distributed Map | 지원 | 미지원 |
| Redrive | 지원(최근 **14일** 내 실패 실행) | 미지원 |

> 선택 규칙: **비멱등 작업**(EMR 클러스터 시작·결제)은 exactly-once인 **Standard**. **멱등 작업**(DynamoDB PUT 변환)의 고빈도 처리는 **Express** — 단 상태 머신 로직 자체가 멱등이어야 합니다.

### 3) 서비스 통합 패턴 — 기다릴까, 안 기다릴까 {#integration-patterns}

Task 상태의 Resource URI를 어떻게 쓰느냐로 패턴이 정해집니다.

- **Request Response(기본)**: 호출하고 HTTP 응답을 받으면 **바로 다음 상태로** — 작업 완료를 기다리지 않습니다.
- **Run a Job(`.sync`)**: ARN 끝에 `.sync`를 붙이면 **작업이 끝날 때까지 기다립니다.** Glue·Athena·EMR·EMR Serverless·Batch·ECS 등이 Standard에서 지원합니다.
- **Wait for Callback(`.waitForTaskToken`)**: 태스크 토큰이 `SendTaskSuccess`/`SendTaskFailure`로 돌아올 때까지 멈춥니다. **사람 승인·타사·레거시 연동**에 씁니다(토큰은 같은 AWS 계정의 주체가 보내야 함).

> 비용 팁: 비동기 작업을 **폴링 루프**로 감시하면 상태 전이가 늘어 Standard 비용이 오릅니다. `.sync`나 콜백을 쓰면 전이 수와 비용이 함께 줄어듭니다.

### 4) Map 상태 — Inline vs Distributed {#map-state}

| 항목 | Inline(기본) | Distributed |
|---|---|---|
| 동시성 | 최대 **40** | 최대 **10,000** 병렬 자식 실행 |
| 입력 | **JSON 배열만** | JSON 배열 또는 **S3 데이터 소스(CSV 등)** |
| 이력 | 부모 실행 이력에 추가 | **자식마다 별도 이력** |
| 워크플로 유형 | Standard·Express | **Standard 상태 머신에서만** |

> 선택 기준(셋 중 하나라도 해당하면 Distributed): 데이터가 **256 KiB 초과**, 이력이 **25,000 항목 초과**, 동시성 **40 초과**. S3의 많은 객체나 큰 CSV를 항목별로 처리하는 경로가 대표 사례입니다.

### 5) 오류 처리 — Retry·Catch·Redrive {#error-handling}

- 상태가 오류를 보고하면 **기본 동작은 실행 전체 실패**입니다. `Retry`로 재시도하고 `Catch`로 폴백 상태로 보내 이를 완화합니다.
- **Retry 필드**: `ErrorEquals`(필수) · `IntervalSeconds` · `MaxAttempts` · `BackoffRate` · `MaxDelaySeconds` · `JitterStrategy`. 간격 3초·배수 2면 첫 재시도는 3초 뒤, 두 번째는 그 **6초 뒤**입니다. `JitterStrategy: FULL`은 대기 시간을 무작위화해 동시 재시도를 분산합니다.
- `States.ALL`은 알려진 모든 오류와 일치하는 와일드카드로, **단독으로 마지막 Retrier**에 둡니다.
- **재시도는 상태 전이로 과금**됩니다 — 무턱대고 늘리면 비용이 늘어납니다.
- **Redrive**: Standard 실행 중 **최근 14일** 안에 실패·중단·타임아웃된 실행을 **실패한 단계부터 같은 입력으로 재개**합니다. 성공한 단계의 결과·이력은 보존되고 재실행되지 않습니다. 같은 상태 머신 정의·실행 ARN을 쓰므로 **정의를 고쳤다면 새 실행**을 시작해야 하고, Express는 지원하지 않습니다.
- 실행 이력이 **25,000 이벤트**에 닿으면 그 실행은 실패합니다 — 이력이 커질 작업은 Distributed Map이 답입니다.

### 6) MWAA와 MWAA Serverless {#mwaa}

- **DAG 배포**: DAG와 지원 파일을 환경에 연결된 **S3 버킷**에 복사하면 MWAA가 워커·스케줄러·웹서버에 동기화합니다. 버킷은 **퍼블릭 액세스 차단과 버전 관리**가 필요하고, `plugins.zip`·`requirements.txt`는 갱신할 때마다 사용할 버전을 지정합니다.
- **구성요소**: 스케줄러(최소 2·최대 5) · 워커(오토스케일) · 웹서버(Airflow UI) · 메타데이터 DB(AWS 관리 Aurora PostgreSQL). 네트워크는 **서로 다른 AZ의 서브넷 2개**가 필요합니다.
- **워커 오토스케일**: 큐 대기 + 실행 중 작업이 기존 용량을 넘으면 늘리고, 합계가 0인 상태가 **2분**을 넘으면 최소 워커 수로 줄입니다.
- **환경 클래스**: `mw1.micro`~`mw1.2xlarge`. 클수록 기본 동시 작업 수가 늘고(micro 3 → 2xlarge 80), **`mw1.micro`는 오토스케일링을 지원하지 않습니다.**
- **버전**: 생성 시 지정(미지정이면 최신). **마이너 업그레이드만 지원**하고 최소 3개 마이너 버전을 동시에 지원하며 종료일은 180일 이상 전에 공지합니다.
- **MWAA Serverless**: Airflow v3·Python 3.12, 워크플로를 **YAML(DAG factory)** 로 정의, 워크플로마다 자체 실행 역할·워커, **Airflow UI 직접 접근 불가**(로그로 모니터링), 요금은 사용량 **1초 단위·최소 1분**.
- **프로비저닝 MWAA가 필요한 조건**(공식 안내): 사용자 정의 Python 연산자·복잡한 DAG 로직, **Airflow 웹 UI 직접 접근**, 지속적으로 대량인 워크로드, Serverless가 지원하지 않는 플러그인·설정.

### 7) EventBridge — 버스·Scheduler·Pipes {#eventbridge}

- **이벤트 버스**: 이벤트 서비스 사이의 **다대다 라우팅**. **Pipes**: 게시자-소비자 **점대점 통합**(고급 변환·보강).
- **Scheduler**: 예약 규칙 기능 위에 **시간대·대규모·사용자 지정 페이로드·모니터링**을 더한 것으로, 대규모 예약에 더 적합합니다. 전달은 **at-least-once**이고 기본적으로 **최대 24시간·185회** 재시도하며, **DLQ를 설정하지 않으면 실패 이벤트는 폐기**됩니다.
- **flexible time window**: 예약 호출을 시간 창에 분산시켜 하위 서비스 부하를 줄입니다.

### 8) Glue 워크플로 {#glue-workflows}

- 트리거가 **잡과 크롤러를 모두** 시작하고, 잡·크롤러 종료 시 발화해 의존 체인을 만듭니다. **정적 뷰(설계)** 와 **동적 뷰(최신 실행)** 를 제공합니다.
- **워크플로 실행 속성(run properties)**: 이름/값 쌍으로 워크플로 안 모든 잡이 읽고 수정해 **뒤 단계에 상태를 전달**할 수 있습니다.
- **동시 실행 상한**은 생성 시 지정하며, 상한을 넘어 시작되지 못한 런은 **Glue가 재시도하지 않습니다.**
- 실패로 끝난 런을 시작시킨 이벤트(묶음)는 **다시 고려되지 않고**, 다음 이벤트가 도착해야 새 런이 시작됩니다.
- 시작 트리거는 **Schedule**(cron) · **On demand** · **EventBridge event**(배치 크기·배치 창, 미지정 시 배치 크기 1).

### 9) 복원력·내결함성 — 축과 수단 {#resilience}

| 축 | 구현 수단 |
|---|---|
| 재시도·백오프·지터 | Step Functions `Retry`(IntervalSeconds·BackoffRate·MaxDelaySeconds·JitterStrategy), Well-Architected 재시도 원칙(**최대 횟수 제한**) |
| 멱등성 | ETL **덮어쓰기** 또는 **삭제 후 쓰기**(삭제는 신중히), Express 로직 멱등 |
| 실패 격리 | SQS DLQ(`maxReceiveCount`), EventBridge Scheduler DLQ, SNS 구독 DLQ |
| 체크포인트·재개 | Step Functions **redrive**, Lambda durable functions |
| 모니터링·알림 | 실패 모니터링(BP 6.2) → 이해관계자 알림(BP 6.3) → EventBridge → SNS |
| 가용성 | MWAA **다른 AZ 서브넷 2개**, 스케줄러 최소 2 |
| 확장성 | MWAA 워커 오토스케일, Distributed Map **10,000 병렬**, Express 높은 시작률, SQS Standard 거의 무제한 처리량 |

### 10) 알림 — SNS·SQS {#notifications}

- **SNS**(pub/sub): 토픽에 게시하면 구독자에게 전달됩니다. 목적지는 **A2A**(Lambda·SQS·Firehose)와 **A2P**(SMS·이메일·모바일 푸시). **구독 필터 정책이 없으면 모든 메시지를 받습니다**(정책은 메시지 속성 또는 본문에 적용). 전달 실패 메시지는 **구독 DLQ**에 보관됩니다.
- **SNS FIFO 토픽**은 **SQS 표준·FIFO 큐로만** 전달할 수 있고 이메일·SMS·모바일·HTTP(S)는 구독할 수 없습니다. 엄격한 순서·중복 제거가 필요하면 **SNS FIFO + SQS FIFO** 조합입니다.
- **SQS**: 큐 유형은 **만든 뒤 바꿀 수 없습니다.**

| 항목 | SQS Standard | SQS FIFO |
|---|---|---|
| 처리량 | 거의 무제한 | 높지만 Standard보다 낮음 |
| 전달·순서 | **최소 한 번**, 순서 비보장 | **정확히 한 번**, 순서 보존 |
| DLQ | Standard 큐여야 함 | **FIFO 큐여야 함** |

- **가시성 제한 시간**: 기본 **30초**, 범위 **0초~12시간**. 소비자가 그 시간 안에 처리·삭제하지 못하면 메시지가 다시 보이므로, 보통 **처리+삭제에 걸리는 최대 시간**으로 맞춥니다.
- **DLQ**: `maxReceiveCount`를 넘으면 DLQ로 이동하며 **기본값은 10**입니다.
- **긴 폴링**: `ReceiveMessage` 대기 시간을 0보다 크게(최대 **20초**) 두면 빈 응답이 줄어 비용이 내려갑니다.
- **알림 패턴**: ① **Glue 잡 실패 → EventBridge 규칙 → SNS** ② **Step Functions 실행 상태 변경 → EventBridge 규칙 → SNS** ③ 재시도·폴백은 Step Functions `Retry`/`Catch`.

---

## ✍️ 시험 포인트

- "작업이 끝날 때까지 기다려야 한다"(Glue·Athena·EMR 호출) → **`.sync`**. "사람 승인·외부 시스템 응답" → **`.waitForTaskToken`**. 둘 다 **Standard 전용**.
- Express 탈락 신호: **5분 초과**, `.sync`·콜백·Distributed Map 필요, **비멱등** 작업, redrive 필요.
- 숫자: Standard **1년**·이력 **25,000**·redrive **14일** / Express **5분** / Inline Map **40** · Distributed Map **10,000** · 입력 **256 KiB** / Scheduler 재시도 **24시간·185회** / SQS 가시성 기본 **30초**(최대 12시간)·`maxReceiveCount` 기본 **10**·긴 폴링 최대 **20초**.
- "DAG가 안 돌아도 비용이 나간다" → 프로비저닝 **MWAA**. "Airflow인데 유휴 비용 없이" → **MWAA Serverless**(단 UI 직접 접근 불가).
- "`mw1.micro`인데 오토스케일이 안 된다" → **micro는 오토스케일링 미지원**(정상 동작).
- "크롤러 끝나면 잡" → **Glue 워크플로 트리거**. "파일 도착 시" → **EventBridge event 트리거**(배치 크기 기본 1).
- SNS FIFO 토픽에 **이메일/SMS 구독은 불가** — SQS 큐만.
- 실패 알림의 정석: **EventBridge 규칙 → SNS 토픽**.

---

## ⚠️ 흔한 함정 {#pitfalls}

1. **"Express가 싸고 빠르니 ETL에도 쓰자."** → ❌. **5분 한도**이고 `.sync`·콜백·Distributed Map을 지원하지 않으며 **at-least-once**라 비멱등 단계에 위험합니다.
2. **"상태 머신 유형은 나중에 바꿀 수 있다."** → ❌. **생성 시 결정되고 변경 불가**입니다.
3. **"재시도는 공짜다."** → ❌. Standard는 **상태 전이 수로 과금**되고 **재시도도 전이**입니다. 폴링 루프도 같은 이유로 비쌉니다.
4. **"redrive로 정의를 수정한 워크플로를 재개할 수 있다."** → ❌. redrive는 **같은 정의·같은 실행 ARN**으로 재개합니다. 정의를 고쳤다면 **새 실행**을 시작해야 합니다.
5. **"Map 상태는 그냥 동시성만 올리면 된다."** → ❌. Inline은 **최대 40**이고 부모 이력에 쌓여 **25,000 이벤트** 한도에 걸립니다. 그 이상은 **Distributed**(Standard 전용).
6. **"EventBridge Scheduler는 실패하면 알아서 보관한다."** → ❌. **DLQ를 설정하지 않으면 폐기**됩니다(기본 재시도 24시간·185회).
7. **"Glue 워크플로가 동시 실행 상한을 넘으면 큐에 쌓인다."** → ❌. **Glue가 재시도하지 않습니다.** 예상 이벤트량에 맞춰 상한을 조정해야 합니다.
8. **"SQS DLQ는 아무 큐나 쓸 수 있다."** → ❌. **FIFO 큐의 DLQ는 FIFO**여야 합니다(Standard는 Standard).
9. **"가시성 제한 시간은 길게 두면 안전하다."** → ⚠️ 너무 길면 실패한 메시지의 재처리가 늦어집니다. 기준은 **처리+삭제에 걸리는 최대 시간**입니다.
10. **"SNS 구독을 만들면 필요한 메시지만 온다."** → ❌. **필터 정책이 없으면 토픽의 모든 메시지**를 받습니다.

---

## 🧪 자가 점검

> 학습용 자가 점검입니다. (문항 뱅크 `dea-t1-3.questions.json` — 사람 검수 전이라 사이트 비노출)

**Q1.** Step Functions에서 Glue 잡을 호출한 뒤 **그 잡이 끝난 다음** 단계로 넘어가야 합니다. 어떻게 구성하나요?

<details><summary>정답 보기</summary>

Task 상태의 리소스 ARN 끝에 **`.sync`** 를 붙이는 **Run a Job 패턴**을 씁니다(Standard 전용). 기본 Request Response는 호출 응답만 받고 바로 다음 상태로 넘어가므로 완료를 보장하지 못하고, 폴링 루프로 흉내내면 상태 전이가 늘어 비용이 커집니다.
</details>

**Q2.** S3에 있는 50만 개 객체를 항목별로 변환해야 합니다. Map 상태를 어떻게 설정하나요?

<details><summary>정답 보기</summary>

**Distributed Map**을 씁니다. Inline은 동시성 최대 40이고 입력이 JSON 배열로 한정되며 부모 이력에 쌓여 25,000 이벤트 한도에 걸립니다. Distributed는 S3 데이터 소스를 직접 읽고 최대 10,000 병렬 자식 실행을 띄우며 자식마다 별도 이력을 갖습니다(상위 상태 머신은 Standard여야 합니다).
</details>

**Q3.** 어제 실패한 Standard 실행을, 성공한 앞 단계를 다시 돌리지 않고 실패 지점부터 재개하려 합니다. 가능한가요?

<details><summary>정답 보기</summary>

**가능합니다 — redrive.** 최근 14일 안의 실패·중단·타임아웃 실행을 같은 입력으로 실패 단계부터 재개하며, 성공한 단계의 결과와 이력은 보존되고 재실행되지 않습니다. 단 같은 상태 머신 정의·실행 ARN을 쓰므로 정의를 수정했다면 새 실행을 시작해야 하고, Express는 지원하지 않습니다.
</details>

**Q4.** 기존 Airflow DAG 자산이 많고 Airflow 웹 UI로 직접 디버깅해야 합니다. MWAA Serverless로 가면 되나요?

<details><summary>정답 보기</summary>

**아니요 — 프로비저닝된 MWAA가 맞습니다.** MWAA Serverless는 워크플로를 YAML(DAG factory)로 정의하고 **Airflow UI에 직접 접근할 수 없습니다**. 공식 안내도 사용자 정의 Python 연산자·복잡한 DAG 로직·웹 UI 접근·지속적 대량 워크로드가 필요하면 프로비저닝된 MWAA를 고려하라고 합니다.
</details>

**Q5.** Glue 잡이 실패했을 때 데이터 팀에 이메일로 알리는 가장 표준적인 구성은?

<details><summary>정답 보기</summary>

**Glue 잡 상태 변경 이벤트 → EventBridge 규칙 → SNS 토픽(이메일 구독)** 입니다. 재시도·폴백 같은 흐름 제어는 Step Functions의 `Retry`/`Catch`가 담당하고, 알림 전달은 SNS가 맡는 역할 분담입니다.
</details>

---

**Q6 (원리).** 왜 Express 워크플로에는 "상태 머신 로직이 멱등해야 한다"는 조건이 붙나요?

<details><summary>정답 보기</summary>

**Express의 비동기 실행이 at-least-once 의미론이기 때문입니다.** 같은 실행이 한 번 이상 일어날 수 있으므로, 같은 입력을 두 번 처리해도 결과가 달라지지 않는 로직(예: 같은 키로 DynamoDB PUT)만 안전합니다. 반대로 결제나 EMR 클러스터 시작처럼 두 번 실행되면 안 되는 비멱등 작업은 exactly-once인 Standard를 써야 합니다.
</details>

---

### 📌 출처

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. (수집·대조: 2026-10-17 · 저작: 2026-10-19 · 사람 검수 전)

1. Choosing workflow type in Step Functions — https://docs.aws.amazon.com/step-functions/latest/dg/choosing-workflow-type.html
2. What is Step Functions? — https://docs.aws.amazon.com/step-functions/latest/dg/welcome.html
3. Discover service integration patterns in Step Functions — https://docs.aws.amazon.com/step-functions/latest/dg/connect-to-resource.html
4. Map workflow state — https://docs.aws.amazon.com/step-functions/latest/dg/state-map.html
5. Handling errors in Step Functions workflows — https://docs.aws.amazon.com/step-functions/latest/dg/concepts-error-handling.html
6. Step Functions service quotas — https://docs.aws.amazon.com/step-functions/latest/dg/service-quotas.html
7. Restarting state machine executions with redrive — https://docs.aws.amazon.com/step-functions/latest/dg/redrive-executions.html
8. State machine aliases in Step Functions workflows — https://docs.aws.amazon.com/step-functions/latest/dg/concepts-state-machine-alias.html
9. AWS Step Functions Express Workflows (Serverless Applications Lens) — https://docs.aws.amazon.com/wellarchitected/latest/serverless-applications-lens/step-functions-workflows.html
10. Apache Airflow versions on Amazon MWAA — https://docs.aws.amazon.com/mwaa/latest/userguide/airflow-versions.html
11. Configuring the Amazon MWAA environment class — https://docs.aws.amazon.com/mwaa/latest/userguide/environment-class.html
12. Explore Amazon MWAA network architecture — https://docs.aws.amazon.com/mwaa/latest/migrationguide/mwaa-architecture.html
13. Working with DAGs on Amazon MWAA — https://docs.aws.amazon.com/mwaa/latest/userguide/working-dags.html
14. Amazon MWAA FAQs — https://aws.amazon.com/managed-workflows-for-apache-airflow/faqs/
15. What is Amazon MWAA Serverless? — https://docs.aws.amazon.com/mwaa/latest/mwaa-serverless-userguide/what-is-mwaa-serverless.html
16. Orchestration (AWS Prescriptive Guidance) — https://docs.aws.amazon.com/prescriptive-guidance/latest/modernization-integrating-microservices/orchestration.html
17. Amazon EventBridge FAQs — https://aws.amazon.com/eventbridge/faqs/
18. Introducing Amazon EventBridge Scheduler — https://aws.amazon.com/blogs/compute/introducing-amazon-eventbridge-scheduler/
19. Overview of workflows in AWS Glue — https://docs.aws.amazon.com/glue/latest/dg/workflows_overview.html
20. Orchestrating Lambda Event Functions with Step Functions — https://docs.aws.amazon.com/lambda/latest/dg/with-step-functions.html
21. Lambda durable functions — https://docs.aws.amazon.com/lambda/latest/dg/durable-functions.html
22. Best practice 6.4 – Automate the recovery of analytics and ETL job failures — https://docs.aws.amazon.com/wellarchitected/latest/analytics-lens/best-practice-6.4-automate-the-recovery-of-analytics-and-etl-job-failures..html
23. REL05-BP03 Control and limit retry calls — https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/rel_mitigate_interaction_failure_limit_retries.html
24. Amazon SNS message filtering — https://docs.aws.amazon.com/sns/latest/dg/sns-message-filtering.html
25. Amazon SNS message delivery for FIFO topics — https://docs.aws.amazon.com/sns/latest/dg/fifo-message-delivery.html
26. Using dead-letter queues in Amazon SQS — https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-dead-letter-queues.html
27. CreateQueue (Amazon SQS API Reference) — https://docs.aws.amazon.com/AWSSimpleQueueService/latest/APIReference/API_CreateQueue.html
28. Automating AWS Glue with EventBridge — https://docs.aws.amazon.com/glue/latest/dg/automating-awsglue-with-cloudwatch-events.html
29. DEA-C01 공식 시험 가이드 도메인 1 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain1.html
