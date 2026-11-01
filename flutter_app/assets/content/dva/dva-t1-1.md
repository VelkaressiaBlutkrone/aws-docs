---
examGuideTaskId: dva-t1-1
certCode: DVA-C03
domain: 1
domainName: AWS 서비스를 통한 개발
domainWeightPct: 30
title: AWS에서 호스팅하는 애플리케이션 코드 개발 (결합도·통신·복원력·API·SDK·스트리밍·AI)
coversTasks:
  - "1.1"
sources:
  - title: REL04-BP02 Implement loosely coupled dependencies (AWS Well-Architected)
    url: https://docs.aws.amazon.com/wellarchitected/2025-02-25/framework/rel_prevent_interaction_failure_loosely_coupled_system.html
  - title: Asynchronous communication (AWS Prescriptive Guidance)
    url: https://docs.aws.amazon.com/prescriptive-guidance/latest/modernization-integrating-microservices/asynchronous.html
  - title: Retry behavior (AWS SDKs and Tools Reference Guide)
    url: https://docs.aws.amazon.com/sdkref/latest/guide/feature-retry-behavior.html
  - title: Choose between REST APIs and HTTP APIs (Amazon API Gateway)
    url: https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-vs-rest.html
  - title: AWS SDKs and Tools standardized credential providers
    url: https://docs.aws.amazon.com/sdkref/latest/guide/standardized-credentials.html
  - title: Amazon Kinesis Data Streams Terminology and concepts
    url: https://docs.aws.amazon.com/streams/latest/dev/key-concepts.html
  - title: What Is Amazon EventBridge?
    url: https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-what-is.html
  - title: CloudWatch Logs 자연어 쿼리 생성 (Query Assist)
    url: https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CloudWatchLogs-Insights-Query-Assist.html
  - title: DVA-C03 공식 시험 가이드 · 콘텐츠 도메인 1 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/developer-associate-03/developer-associate-03-domain1.html
  - title: DVA-C03 범위 내 AWS 서비스 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/developer-associate-03/dva-03-in-scope-services.html
lastVerified: 2026-11-01
---

# AWS에서 호스팅하는 애플리케이션 코드 개발 (결합도·통신·복원력·API·SDK·스트리밍·AI)

> **커버하는 공식 Task** — DVA-C03 · 도메인 1 「AWS 서비스를 통한 개발」(30%) · **작업 1.1 AWS에서 호스팅하는 애플리케이션의 코드를 개발합니다** (`dva-t1-1`)
> 이 문서는 위 한 작업에 1:1로 매핑되고, 공식 기술 10개(1.1.1~1.1.10)를 모두 덮습니다. 도메인 1은 시험에서 가장 큰 덩어리이고, 그중 1.1은 **"컴포넌트를 어떻게 나누고 무엇으로 잇는가"** — 나머지 모든 작업이 이 선택 위에 올라갑니다.

> ⚠️ **C02에서 바뀐 것** — 이 작업에서 **SAM 로컬 단위 테스트는 작업 3.2로 나갔고**, 데이터 **직렬화·역직렬화가 작업 1.3에서 들어왔습니다**(기술 1.1.7). 그리고 **AI 기술 두 개가 새로 생겼습니다**(1.1.9 AI 보조 개발 · 1.1.10 관리형 AI 서비스 통합). C02 교재의 "Task 1.1" 목차와 다른 이유입니다.

---

## ✅ 학습 목표 체크리스트

- [ ] 강결합과 느슨한 결합을 **변경·장애가 번지는가**로 가르고, 중간 계층(큐·토픽·버스)으로 분리할 수 있다
- [ ] 동기와 비동기를 **호출자가 무엇을 받는가**로 고르고, Lambda·API Gateway의 호출 방식과 페이로드 한도를 안다
- [ ] 타임아웃 → 재시도(지수 백오프 + 지터) → 멱등성 → 한도·서킷 브레이커 → DLQ 순서로 복원력을 쌓을 수 있다
- [ ] REST API와 HTTP API를 **필요한 기능**으로 고르고, 검증·변환·상태 코드를 게이트웨이에서 처리할 수 있다
- [ ] SDK가 대신 해 주는 것(서명·자격 증명 체인·재시도·페이지네이션)을 알고 리전·자격 증명 우선순위를 설명한다
- [ ] KDS·Firehose·DynamoDB Streams·SQS를 **보존·재처리·소비자 수**로 가르고 샤드 한도를 안다
- [ ] 이벤트 기반 패턴에서 SNS 팬아웃과 EventBridge 규칙을 구분하고 실패를 DLQ로 보존한다
- [ ] AI 기술 두 개의 범위를 가른다 — **1.1.9는 개발 도구(Kiro), 1.1.10은 애플리케이션 기능(Bedrock·AgentCore)**

---

## 🎯 왜 중요한가

이 작업의 문항은 코드를 쓰게 하지 않습니다. **"이 상황에서 무엇으로 잇는가"**, 그리고 **"이 실패를 어디서 막는가"**를 묻습니다. 그래서 서비스 이름을 외우는 것보다 **가르는 질문 한 줄**을 갖는 것이 빠릅니다. 예를 들어 SQS와 SNS를 가르는 질문은 "메시지 하나를 한 소비자가 처리하는가, 모든 구독자가 받는가" 하나입니다.

C03에서 이 작업의 성격이 한 번 더 분명해졌습니다. 공식 기술 10개 중 **둘이 AI**이고, 가이드는 응시자가 **"AI 도구 및 서비스를 사용하여 고품질 코드의 개발·테스트·릴리스를 지원"**하고 **"관리형 AI 서비스를 애플리케이션에 통합"**할 수 있어야 한다고 적습니다. 다만 범위 밖도 분명합니다 — **파운데이션 모델 선택·프롬프트 엔지니어링·RAG 아키텍처 설계**는 응시자 역할이 아닙니다.

---

## ⚡ 시험 직전 요약

> 시험 직전에 이 열 줄만 다시 봅니다. 근거와 맥락은 아래 본문에 있습니다.

- **결합 분리 3수단**: 내구 중간 계층(**SQS**) · 생산자를 소비자에서 추상화(**EventBridge**) · 고처리량 푸시 다대다(**SNS**)
- **Lambda 페이로드**: 동기 호출 **6 MB** · 비동기 호출 **1 MB**. 비동기는 함수 오류 시 **최대 2회 더** 실행하고 처리 못 한 이벤트는 **DLQ**로
- ⚠️ **동기 Lambda 호출은 함수가 오류를 반환해도 HTTP 200**일 수 있다 — 호출자가 **응답 본문의 오류**를 확인해야 한다
- **재시도 3요소**: 지수 백오프 + **지터** + **최대 횟수 제한**(REL05-BP03). 지터가 없으면 재시도 폭주가 난다
- **SQS 세 시간을 구분**: 가시성 제한 시간(기본 **30초**, 최대 **12시간**) · 지연 **0~15분** · 보존 기본 **4일**(최대 14일)
- **FIFO 필수 파라미터**: `MessageGroupId`(없으면 실패) + 중복 제거 ID 또는 콘텐츠 기반 중복 제거(**5분** 구간)
- **REST만 되는 것**: 요청 유효성 검사 · 본문 매핑 템플릿 · 게이트웨이 응답 · API 키·클라이언트별 제한 · WAF. **HTTP API는 JWT 권한 부여를 직접 지원**
- **API Gateway 타임아웃**: REST 통합 기본 **29초**(쿼터 증가 가능) · HTTP API 최대 **30초**(증가 불가)
- **KDS 샤드**: 쓰기 **1 MB/s·1,000 records/s** · 읽기 **2 MB/s·5 TPS**. 소비자마다 전용 처리량이 필요하면 **향상된 팬아웃**(평균 약 **70 ms**)
- **AI 두 기술의 경계**: **1.1.9 = 개발 도구**(범위 내 목록에서는 **Kiro**) · **1.1.10 = 앱 기능**(**Bedrock·AgentCore**). ⚠️ `Amazon Q Developer`는 **범위 내 목록에 없다**

---

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **강결합** | 한 컴포넌트가 바뀌면 의존 컴포넌트도 바꿔야 하는 관계. 변경·장애가 연쇄된다 |
| **백프레셔(backpressure)** | 처리 속도를 못 맞출 때 유입을 늦추거나 멈추는 능력. 무시하는 것이 강결합 안티패턴의 하나 |
| **멱등(idempotent)** | 같은 호출을 여러 번 해도 결과 상태가 같은 성질. 재시도가 안전한지를 결정한다 |
| **지터(jitter)** | 재시도 간격에 난수를 섞는 것. 같은 시점에 실패한 클라이언트가 같은 시점에 몰리는 것을 막는다 |
| **가시성 제한 시간** | SQS에서 수신한 메시지가 다른 소비자에게 **일시적으로 안 보이는** 시간. 이 안에 삭제하지 못하면 다시 보인다 |
| **파티션 키** | Kinesis 레코드를 어느 샤드에 넣을지 정하는 키. MD5 해시로 매핑되므로 **같은 키는 같은 샤드** |
| **프록시 통합** | API Gateway가 요청을 통째로 Lambda에 넘기고, 함수가 `statusCode`·`headers`·`body` JSON을 돌려주는 방식 |
| **자격 증명 공급자 체인** | SDK가 정해진 순서로 자격 증명을 찾다가 **처음 유효한 것에서 멈추는** 탐색 절차 |

---

## 📖 핵심 개념

### 1) 결합도와 구성 요소 분리 (기술 1.1.1) {#coupling}

공식 기술 문구는 "긴밀하게 연결된 시스템과 느슨하게 연결된 시스템을 **식별하고** AWS 서비스를 사용하여 시스템 구성 요소를 **분리**합니다"입니다. 그래서 묻는 것은 정의가 아니라 **"무엇으로 분리하는가"**입니다.

| 구분 | 강결합 | 느슨한 결합 |
|---|---|---|
| 정의 | 한 컴포넌트가 바뀌면 의존 컴포넌트도 바꿔야 한다 | 의존 컴포넌트는 버전 관리되고 **게시된 인터페이스만** 알면 된다 |
| 장애·변경 | 변경·장애가 연쇄되어 전반의 성능이 저하된다 | 한 컴포넌트의 장애가 다른 컴포넌트로 번지지 않게 격리된다 |
| 수단 | 직접 점대점 호출 | **SQS 큐·Kinesis·Step Functions** 같은 내구 중간 계층, **EventBridge**(생산자를 소비자로부터 추상화), **SNS**(고처리량 푸시 기반 다대다) |

공식 문서가 드는 **강결합 신호 네 가지**는 그대로 문항의 지문 재료입니다 — ① 모놀리식 워크로드 배포 ② 장애 조치·비동기 처리 능력 없이 워크로드 계층끼리 API를 **직접 호출** ③ **공유 데이터베이스**로 데이터를 공유해 결합 ④ **백프레셔 무시**.

- 즉시 응답이 필요 없고 "요청이 등록되었다"는 확인이면 충분한 상호작용은 **비동기로 바꾸고 중간 계층을 둡니다.**
- ⚠️ 반대 주의도 공식 문서에 있습니다 — **하드 리얼타임 시스템**에서는 임계 시간(보통 수 초)보다 오래된 큐 요청은 클라이언트가 이미 포기했을 수 있어 **stale로 보고 처리하지 않는 편**이 낫습니다.

> 🧠 **원리** — 결합을 끊는 것은 "중간에 무언가를 두는 일"입니다. 그 중간 계층이 **내구성**을 가지면(SQS) 소비자가 죽어도 메시지가 남고, **라우팅**을 가지면(EventBridge) 소비자를 늘려도 생산자 코드를 건드리지 않습니다. 둘 중 무엇이 필요한지가 서비스 선택을 결정합니다.

### 2) 동기와 비동기 (기술 1.1.2) {#sync-async}

공식 예시는 **API Gateway 동기식 호출 · SQS 기반 비동기식 처리 · EventBridge 이벤트 기반 워크플로**입니다.

| 구분 | 동기 | 비동기 |
|---|---|---|
| 호출자가 받는 것 | **결과** | 보통 **"요청 접수" 확인만** |
| 장점 | 단순, 즉시 결과 | 장애 격리, 큐로 피크 흡수, 용량 기준 처리 |
| 단점 | 지연·실패가 호출 사슬로 **연쇄** | 결과 회수 경로가 따로 필요, 추적·테스트가 어렵다 |
| 구현 방식 | — | fire and forget · claim check · callback · bidirectional |

Lambda 호출 경로의 숫자는 그대로 출제 재료입니다.

| 호출 경로 | 동기 | 비동기 |
|---|---|---|
| Lambda `Invoke` API | 기본값 `RequestResponse` — 응답을 기다린다 | `InvocationType=Event` — 이벤트를 큐에 넣고 성공 응답을 돌려준다 |
| 페이로드 한도 | **6 MB** | **1 MB** |
| 오류·재시도 책임 | **호출자**가 응답의 오류를 확인해 재시도 | Lambda가 함수 오류 시 **최대 2회 더** 실행하고, 처리 못 한 이벤트는 **DLQ**로 보존 |
| API Gateway → Lambda | 별도 설정이 없으면 **동기**(Invoke 기본값) | 통합 요청에 `X-Amz-Invocation-Type` 헤더를 `'Event'`로 고정 |

⚠️ **가장 자주 걸리는 한 줄**: 동기 호출은 **Lambda가 함수를 실행할 수 있었다면 함수가 오류를 반환해도 상태 코드 200**입니다. "200이 왔으니 성공"으로 처리하는 코드는 조용히 실패를 삼킵니다.

> 🧠 **원리** — 비동기는 지연을 호출자에게서 떼어내지만, **결과와 실패도 함께 떼어냅니다.** 그래서 비동기를 고른 순간 "결과를 어디서 받을지"(콜백·이벤트)와 "실패를 어디에 쌓을지"(DLQ)를 같이 정해야 설계가 끝납니다.

### 3) 내결함성·복원력 (기술 1.1.3) {#resilience}

공식 문구는 "**백오프, 점진적 성능 저하를 통한 재시도** 구성"입니다. 복원력 도구 상자는 순서가 있습니다 — **타임아웃 → 재시도(백오프 + 지터) → 멱등성 → 재시도 한도·서킷 브레이커 → DLQ·우아한 실패**.

- **타임아웃**: 의존 호출마다 **연결 타임아웃과 요청 타임아웃을 모두** 설정합니다. 프레임워크 기본값이 무한이거나 과도할 수 있습니다. 너무 길면 기다리는 동안 자원을 소모하고, 너무 짧으면 재시도가 늘어 최악엔 전면 장애가 납니다.
- **재시도는 서버 용량을 더 쓰는 행위**입니다. 호출 스택의 여러 계층이 각자 재시도하면 하위 서비스 부하가 곱절로 늘어나므로 **한 지점에서만** 재시도합니다.
- **지터**: 없으면 같은 시점에 실패한 클라이언트가 같은 시점에 재시도해 **재시도 폭주**가 생깁니다. REL05-BP03은 **지수 백오프·지터·최대 재시도 횟수 제한을 함께** 쓰라고 합니다.
- **멱등성**: 재시도는 멱등 작업에서만 안전합니다. 그렇지 않으면 부분 갱신이 상태를 망칩니다.

SDK 재시도 기본값은 **두 문서가 다르게 적혀 있어** 둘을 구분해 외웁니다.

| 항목 | SDK·Tools 공통 레퍼런스(새 동작, opt-in) | Boto3 가이드(현행) |
|---|---|---|
| 모드 | **standard**(기본) · adaptive · legacy | **legacy**가 기본, standard·adaptive 선택 |
| 최대 시도(최초 포함) | **3** (DynamoDB·DynamoDB Streams는 4) | **5** (standard로 바꾸면 3) |
| 백오프 | 전체 지터 `random(0,1) × min(20,000 ms, base × 2^retry)` — base는 일시 오류 **50 ms**·스로틀링 **1,000 ms** | 지수 백오프(밑 2), standard의 최대 백오프 20초 |
| 재시도 제한 | **재시도 쿼터**(토큰 500, 일시 재시도 14·스로틀링 재시도 5 소모, 성공 시 복원) | standard 모드에 서킷 브레이킹 기능 |

- 새 동작은 `AWS_NEW_RETRIES_2026=true`로 **opt-in**해야 적용되고, 그때까지 Java·Python·Ruby·PHP·C++·CLI는 **legacy가 기본**(재시도 쿼터 없음)입니다.
- **재시도 대상**: 일시 오류(`RequestTimeout`, 연결 끊김, HTTP 500/502/503/504)와 스로틀링 오류(`ThrottlingException`, `ProvisionedThroughputExceededException` 등). ⚠️ `AccessDenied`·`ValidationException`·`ResourceNotFound`는 **즉시 반환**합니다 — 재시도해도 결과가 같습니다.
- **adaptive 모드**는 클라이언트 측 속도 제한기가 **초기 요청도 지연**시킬 수 있어 단일 리소스·스로틀링이 잦은 워크로드용이고, 범용 기본값으로는 권장되지 않습니다.
- ⚠️ **배치 API의 부분 실패**: HTTP 200이어도 일부 항목이 실패할 수 있습니다. EventBridge `PutEvents`는 `FailedEntryCount`, Kinesis `PutRecords`는 레코드별 `ErrorCode`, SQS `SendMessageBatch`는 `Failed` 목록을 확인해 **실패분만** 재시도합니다.
- **서킷 브레이커**: 실패가 임계치를 넘으면 회로를 열어 **호출을 보내지 않고 즉시 실패**를 돌려주고, 주기적으로 시험 호출해 성공하면 닫습니다. 일시 오류는 백오프 재시도, 원인을 알 수 있는 **지속 장애는 빨리 실패(fail fast)**로 가릅니다.
- **우아한 성능 저하**: 의존성이 불가용일 때 핵심 기능은 **오래된 데이터·대체 데이터·무데이터로라도** 계속 수행합니다.

> 🧠 **원리** — 재시도는 **일시적** 오류에만 효과가 있습니다. 그래서 오류를 세 부류로 나누는 것이 먼저입니다: 일시 오류는 짧게·지터와 함께, 스로틀링은 길게, 영구 오류는 바로 포기. 이 분류가 없으면 재시도가 장애를 키웁니다.

### 4) API 만들기·확장·유지 (기술 1.1.4) {#api}

공식 문구는 "**유효성 검사 규칙을 적용하여 응답/요청 변환 구성**"입니다. 그래서 API Gateway의 두 종류와 **어느 쪽에서 무엇이 되는지**가 핵심입니다.

| 기능 | REST API | HTTP API |
|---|---|---|
| 요청 유효성 검사 | 지원 | **미지원** |
| 요청 변환 | 파라미터·본문 모두(매핑 템플릿) | **파라미터 변환만** |
| 커스텀 게이트웨이 응답 | 지원 | 미지원 |
| API 키·클라이언트별 제한·WAF·Private 엔드포인트 | 지원 | 미지원 |
| JWT 권한 부여 | 직접 지원하지 않음(Lambda 권한 부여자로 검증) | **지원** |
| 포지셔닝 | 기능이 많음 | 최소 기능·낮은 가격 |

- **요청 유효성 검사(REST)**: 검증기를 만들어 메서드에 연결합니다. ① 필수 URI·쿼리·헤더 파라미터가 **존재하고 비어 있지 않은지**(⚠️ 존재 여부만 보고 **타입·형식은 보지 않습니다**) ② 본문이 메서드 모델의 **JSON 스키마**에 맞는지. 실패하면 **즉시 400**이고 백엔드를 호출하지 않습니다. Content-Type과 맞는 모델이 없으면 검증하지 않으므로, 모든 타입에 같은 모델을 쓰려면 `$default`를 씁니다.
- **매핑 템플릿**: 해당 Content-Type에 템플릿이 정의된 경우에만 변환하고, 없으면 본문을 그대로 통과시킵니다. 통과 정책은 `WHEN_NO_MATCH`·`WHEN_NO_TEMPLATES`·`NEVER`이고, 템플릿과 맞지 않는 Content-Type은 후자 둘에서 **415 Unsupported Media Type**이 납니다.
- **프록시 통합 vs 비프록시**: 프록시는 함수가 `statusCode`·`headers`·`body`(필요하면 `isBase64Encoded`) JSON을 반환해야 하고, 형식이 다르면 **502 Bad Gateway**입니다. CORS는 응답 `headers`에 `Access-Control-Allow-Origin`을 직접 넣습니다. 비프록시에서는 함수가 상태 코드를 직접 전달할 수 없고 **통합 응답 매핑**이 정합니다.
- **상태 코드 재정의**: 통합 응답 매핑 템플릿에서 `$context.responseOverride.status`를 설정합니다. ⚠️ 재정의는 **최종적**이며 같은 파라미터를 여러 번 재정의하면 **5XX**가 나므로, 변수에 모았다가 템플릿 끝에서 한 번 적용합니다.
- **게이트웨이 응답**: API Gateway가 **통합을 호출하지 못하고** 만든 오류 응답(예: `Missing Authentication Token`)을 API 수준에서 커스터마이징합니다. 비-VTL 본문 템플릿(단순 변수 치환)을 쓰며, **VTL 매핑은 유효한 요청·성공 응답에서만** 동작합니다.
- **타임아웃**: REST API 통합은 기본 **29초**(50~29,000 ms)이고 Regional·Private REST API는 쿼터 증가로 늘릴 수 있습니다. HTTP API는 최대 **30초**(증가 불가), 페이로드 **10 MB**입니다.

> 🧠 **원리** — 검증·변환·상태 코드를 게이트웨이에서 처리하면 잘못된 요청이 **백엔드에 닿기 전에** 걸러집니다(비용·부하 절감). 그리고 백엔드 코드를 바꾸지 않고 API 계약을 조정할 수 있습니다 — "백엔드는 항상 200을 주는데 클라이언트에는 400을 줘야 한다"는 문항이 바로 이 지점입니다.

### 5) SDK·API로 AWS 서비스 호출 (기술 1.1.5) {#sdk}

- **SDK·CLI는 요청 서명(SigV4)을 자동 처리**합니다. 직접 HTTP로 호출하면 표준 요청 생성 → 자격 증명으로 서명 계산 → `Authorization` 헤더 추가를 직접 구현해야 하고, 서명 키는 **서비스·리전·날짜** 범위입니다.
- **자격 증명 공급자 체인**: 정해진 순서로 탐색하다 **처음 유효한 자격 증명에서 멈춥니다.** 코드에서 직접 지정 > 환경 변수 > 공유 config·credentials 파일 순으로 우선합니다. 표준 공급자에는 액세스 키, 웹 ID 연합, IAM Identity Center, Assume role, 컨테이너(ECS·EKS), 프로세스, **IMDS(EC2 인스턴스 프로파일)**가 있고 만료되면 SDK가 자동 갱신합니다.
- **리전**: 코드에서 지정하지 않으면 설정값을 쓰며 **기본값이 없어 명시해야** 합니다. 클라이언트 생성 시 지정한 리전이 전역 설정보다 우선합니다.
- **페이지네이션**: 일부 작업은 결과를 나눠 주므로 마커·토큰으로 이어 받아야 하고, Boto3 paginator가 이를 추상화합니다(S3 `list_objects`는 한 번에 최대 1,000개).
- **웨이터(waiter)**: 리소스가 원하는 상태가 되거나 실패할 때까지 **폴링·대기**합니다.
- 재시도·타임아웃 설정 우선순위는 **코드 > 환경 변수 > 공유 config > SDK 기본값**입니다.

> 🧠 **원리** — SDK는 서명·자격 증명 갱신·재시도·페이지네이션을 대신 처리하는 얇은 클라이언트입니다. 그래서 "직접 HTTP 호출"은 **서명 도구를 쓸 수 없을 때의 예외 수단**이고, 시험에서 "SDK 대신 직접 서명"이 정답이 되는 경우는 드뭅니다.

### 6) 스트리밍 데이터 관리 (기술 1.1.6) {#streaming}

| 개념 | 규칙 |
|---|---|
| 샤드 | 쓰기 **1 MB/s·1,000 records/s**, 읽기 **2 MB/s·5 TPS**(`GetRecords`) |
| 파티션 키 | 최대 256자. MD5로 128비트 정수화해 샤드의 해시 키 범위에 매핑 → **같은 키는 같은 샤드** |
| 보존 | 기본 **24시간**, 최대 **365일**. 24시간 초과분은 추가 요금 |
| 용량 모드 | Provisioned(샤드 수 지정) / On-demand(자동 관리, 신규 스트림 기본 4 MB/s 쓰기·8 MB/s 읽기) |

| 소비자 | 공유 처리량 | 향상된 팬아웃(EFO) |
|---|---|---|
| 읽기 처리량 | 샤드당 **총 2 MB/s를 모든 소비자가 나눠 씀** | 등록한 소비자**마다** 샤드당 최대 2 MB/s |
| 전파 지연 | 평균 약 200 ms(소비자 1개) → 소비자 5개면 약 1,000 ms | 소비자 수와 무관하게 평균 약 **70 ms** |
| 전달 방식 | `GetRecords` 폴링(HTTP) | `SubscribeToShard`로 **HTTP/2 푸시**, 폴링 불필요 |
| 비용 | 해당 없음 | 데이터 조회 비용 + 소비자-샤드 시간 비용 |

**무엇을 고르는가**는 네 줄로 끝납니다.

| 요구 | 선택 |
|---|---|
| 실시간 수집 + 여러 커스텀 소비자 + 보존 기간 내 **재처리** | **Kinesis Data Streams** |
| 버퍼링 후 S3·Redshift·OpenSearch 등으로 **관리형 적재** | **Amazon Data Firehose** |
| **DynamoDB 테이블 변경**(CDC) 소비 | **DynamoDB Streams** |
| 단순 작업 큐·버퍼(샤드·순서 불필요) | **SQS** |

- **Firehose 버퍼**: 크기(MB)와 간격(초) 중 **먼저 충족되는 조건**이 전달을 트리거하고, 값을 주지 않으면 목적지 기본값(S3는 5 MB·300초, 범위 1~128 MB·0~900초)을 씁니다.
- **DynamoDB Streams**: 항목 수준 변경을 시간순으로 **최대 24시간** 보관하고, 각 스트림 레코드는 **정확히 한 번** 나타나며 항목별 수정 순서가 보장됩니다.
- ⚠️ **중복은 기본 가정입니다** — 생산자가 `PutRecord` 타임아웃 후 재전송하거나 소비자가 재시도하면 중복 레코드가 생깁니다. 엄격한 보장이 필요하면 레코드에 기본키를 넣어 처리 단계에서 **멱등 처리**합니다.
- **KCL**은 샤드마다 레코드 프로세서가 하나씩 돌게 보장하며, 소비 메타데이터를 **DynamoDB 테이블**에 저장합니다.

> 🧠 **원리** — 파티션 키가 샤드를 결정하므로 **순서는 샤드(=파티션 키) 안에서만** 보장됩니다. 그래서 핫 키는 곧 핫 샤드(스로틀링)이고, 용량 모드를 바꾸는 것으로는 **키 불균형이 해결되지 않습니다.**

### 7) 직렬화·역직렬화 (기술 1.1.7) {#serialization}

⚠️ 이 기술은 **C02에서는 작업 1.3에 있었고 C03에서 1.1로 들어왔습니다.** 공식 문구는 "데이터를 직렬화 및 역직렬화하여 애플리케이션 코드를 AWS 서비스와 **통합**합니다"이므로, 묻는 것은 파일 포맷 이론이 아니라 **SDK 수준에서 타입이 어떻게 오가는가**입니다.

- **저수준 클라이언트와 고수준 클라이언트**: 저수준은 **DynamoDB JSON을 그대로** 다루고 전체 API를 제공합니다. 고수준(Node.js `DynamoDBDocumentClient`, Boto3 `resource`)은 **타입 주석을 숨기고** 네이티브 값으로 변환합니다. 변환 유틸은 Node.js `marshall`·`unmarshall`, Boto3 `serialize`·`deserialize`입니다.
- ⚠️ **전송 표현은 저장 크기보다 클 수 있습니다** — DynamoDB 항목 한도는 **400 KB**인데 `BatchWriteItem`은 **전송 데이터 16 MB**라는 별도 한도를 가집니다.
- **400 KB를 넘는 데이터** 세 처방: 큰 속성을 **압축**하거나, 여러 항목으로 쪼개 **정렬 키로 색인**하거나, **S3에 객체로 저장하고 S3 식별자를 항목에 둡니다.** 마지막 경우 키·인덱스에 쓰는 속성과 `S3Location` 속성은 테이블에 남기고, 앱이 `S3Location`을 확인해 S3에서 전체 데이터를 가져오는 로직을 갖습니다.
- SDK가 **요청 파라미터 직렬화·서명·응답 추출·기본 재시도**를 대신합니다 — 직렬화를 "직접 구현"하는 보기는 대개 오답 방향입니다.

> 🧠 **원리** — 직렬화 문제는 거의 항상 **경계 문제**입니다. 앱의 타입(객체·날짜·소수)과 저장소의 타입(DynamoDB 속성·S3 바이트)이 다르기 때문에, 어느 쪽 표현으로 바꿀지와 **그 변환을 누가 하는지**(고수준 클라이언트인가 내 코드인가)를 정하는 것이 설계입니다.

### 8) 이벤트 기반 패턴 (기술 1.1.8) {#event-driven}

공식 예시는 **EventBridge · S3 이벤트 알림 · SQS · SNS**입니다. 세 서비스를 가르는 표가 이 절의 핵심입니다.

| 기준 | SQS | SNS | EventBridge |
|---|---|---|---|
| 모델 | 큐 — 소비자가 **폴링해 가져가고 삭제** | 토픽 pub/sub — **구독자 전원에게 푸시** | 버스 + 규칙(이벤트 패턴) + 대상 |
| 전달 대상 수 | 소비자 풀이 나눠 처리(**메시지당 소비자 하나**) | **구독자마다 사본** | 규칙당 최대 **5개 대상** |
| 필터링 | 없음(소비자 코드) | **구독 필터 정책**(속성 또는 본문) | **이벤트 패턴**(`source`·`detail-type`·`detail`) |
| 실패 처리 | 가시성 제한 + **DLQ** | 전달 재시도 + **구독 DLQ** | 대상별 재시도 정책 + **DLQ** |

**SQS의 숫자**는 그대로 나옵니다.

- 전달·순서: **Standard는 최소 1회(at-least-once)**이고 순서는 최선 노력, **FIFO는 5분 중복 제거 구간**과 같은 그룹 내 엄격한 순서입니다.
- FIFO 필수 파라미터: **`MessageGroupId`(없으면 실패)** + `MessageDeduplicationId` 또는 콘텐츠 기반 중복 제거.
- FIFO 처리량: 파티션·**API 작업당 300 TPS**(비-고처리량 모드), 배치로 **3,000 msg/s**, 고처리량 모드로 상향.
- 시간 셋: **가시성 제한 시간** 기본 30초(0~12시간) · **지연** 0~15분 · **보존** 기본 4일(60초~14일).
- 크기: 메시지 최대 **1 MiB**, 배치 최대 **10개**. 더 큰 페이로드는 Extended Client Library로 **S3 참조**(최대 2 GB).
- 폴링: 짧은 폴링(기본)은 서버 일부만 조회해 **빈 응답**이 가능하고, **긴 폴링**(`WaitTimeSeconds` 최대 20초)은 빈 응답과 비용을 줄입니다.
- DLQ: 리드라이브 정책의 `maxReceiveCount`번 수신되고도 삭제되지 않으면 DLQ로 이동합니다. ⚠️ 표준 큐는 **원래 enqueue 시각 기준**으로 만료되므로 **DLQ 보존 기간을 원본보다 길게** 둡니다.

**SNS**는 전달 재시도 숫자가 특징입니다 — Lambda·SQS 같은 AWS 관리형 엔드포인트는 **총 100,015회·23일** 동안 재시도하고(즉시 3회 → 1초 간격 2회 → 지수 백오프 10회 → 20초 간격 100,000회), **HTTP/S만 사용자 정의 전달 정책**을 쓸 수 있으며 그 총 재시도 시간은 3,600초 이하입니다. 기본 최대 메시지는 **256 KiB**(속성으로 최대 1 MiB)입니다.

**SNS → SQS 팬아웃**이 이 절의 대표 패턴입니다. 구독 서비스 앞마다 큐를 두면 큐가 메시지를 **내구적으로 버퍼링**하므로 구독 프로세스가 몇 시간~며칠 장애여도 유실이 없고, 큐가 "버퍼링 로드밸런서"가 되어 구독자를 쉽게 늘리고 줄일 수 있습니다.

**EventBridge**: 소스가 버스로 이벤트를 보내면 규칙이 이벤트 패턴으로 평가하고, 일치하면 대상으로 전달합니다. 일치 규칙이 없으면 **아무 일도 일어나지 않습니다.** 기본 버스는 AWS 서비스 이벤트를 자동 수신합니다. 대상별 재시도 정책은 기본 **24시간·최대 185회**(지수 백오프 + 지터)이고 **소진되면 이벤트가 드롭되므로 DLQ를 구성**합니다. `PutEvents`는 요청당 엔트리 **최대 10개**이고 HTTP 200이어도 `FailedEntryCount`를 확인해야 합니다.

> 🧠 **원리** — SNS는 **복제·푸시**, SQS는 **분리·버퍼링**, EventBridge는 **라우팅**을 맡습니다. 그래서 "구독자가 장애여도 유실되면 안 된다"는 조건이 붙는 순간 토픽만으로는 부족하고 **큐가 필요**해집니다.

### 9) AI 보조 개발 도구 (기술 1.1.9) {#ai-dev}

공식 문구는 "**AI 지원 개발 도구**를 사용하여 코드를 생성, 검토 및 최적화합니다(예: 사양 기반 코드 생성, 자동화된 코드 검토, 지능형 코드 완성, 리팩터링 제안, 보안 스캐닝)"입니다.

⚠️ **먼저 바로잡아야 할 두 가지가 있습니다.**

1. **가이드의 이 기술 문구는 서비스 이름을 하나도 적지 않습니다.** 범위 내 「기계 학습 및 인공 지능」은 **Bedrock · Bedrock AgentCore · Amazon Quick · Kiro** 넷이고, 그중 **코드를 다루는 개발 도구는 Kiro뿐**입니다. 그러니 "가이드가 Kiro를 쓰라고 한다"가 아니라 **"범위 내 목록에서 이 기술에 해당하는 유일한 도구가 Kiro"**로 이해합니다.
2. ⚠️ **`Amazon Q Developer`는 범위 내 목록에 없습니다.** C02 교재는 이 자리를 Q Developer로 다뤘지만 C03 목록에 그 이름이 없고, 공식 문서가 **IDE 플러그인 지원 종료(2027-04-30)**와 신규 가입 차단(2026-05-15)을 알리며 대체재로 **Kiro**를 지목합니다. 콘솔·문서 사이트·모바일 앱·채팅 앱의 Q는 영향이 없습니다.

**Kiro의 구성 요소**(AWS 블로그·지식 센터 수준의 서술입니다 — 세부 플래그는 이 문서에 쓰지 않았습니다)

| 요소 | 하는 일 | 걸리는 공식 문구 |
|---|---|---|
| **Specs(스펙)** | 만들 것을 구조화된 자연어 요구사항으로 정의하고, 요구사항 → 설계 → 작업 목록으로 쪼갠 뒤 구현한다 | **사양 기반 코드 생성** |
| **Hooks(훅)** | 파일 저장·커밋 같은 **이벤트에 걸리는 자동 트리거** — 표준 강제, 테스트 실행 | 반복 작업 자동화(작업 3.2와 이어진다) |
| **Steering files** | 아키텍처·규약·제약을 담는 **프로젝트 수준 영속 컨텍스트** | 지능형 코드 완성의 품질 |
| **Custom subagents** | 도메인 전용 에이전트 — **보안 리뷰**·API 계약 검증 | **자동화된 코드 검토 · 보안 스캐닝** |

⚠️ **`Amazon Quick`을 이 기술에 쓰지 않습니다.** Quick은 공식 정의가 "**작업 자동화·데이터 분석·웹 애플리케이션 구축·리서치**를 위한 AI 기반 서비스"인 업무용 에이전트 작업 공간이고, 코드베이스를 다루는 개발 도구가 아닙니다. ⚠️ 게다가 그 BI 구성 요소인 **`Amazon Quick Sight`는 범위 밖**입니다 — 상위 제품은 범위 내, 그 기능 하나는 범위 밖이라는 **기묘한 짝**이므로 둘을 묶어 외우면 틀립니다.

> 🧠 **원리** — 이 기술이 묻는 것은 "AI가 코드를 써 준다"가 아니라 **개발 수명 주기의 어느 단계를 AI가 맡는가**입니다. 생성(스펙) · 검토(서브에이전트) · 자동화(훅)로 단계를 가르면 작업 3.2(테스트)·3.3(CI/CD)·4.1(오류 분석)의 AI 기술과도 같은 틀로 읽힙니다.

### 10) 관리형 AI 서비스 통합 (기술 1.1.10) {#managed-ai}

공식 문구는 "**관리형 AWS AI 서비스를 애플리케이션에 통합**합니다"입니다. 앞 기술과 **방향이 반대**입니다 — 1.1.9는 **AI로 개발하기**, 1.1.10은 **AI를 애플리케이션 기능으로 넣기**입니다.

- 범위 내 대상은 **Amazon Bedrock**(모델 호출)과 **Amazon Bedrock AgentCore**(에이전트 런타임·ID)입니다.
- ⚠️ **범위 밖을 예시로 쓰지 않습니다** — `Amazon SageMaker AI`·`Amazon Polly`·`Amazon Rekognition`·`Strands Agents`는 out-of-scope 목록에 **명시**돼 있습니다. "이미지 인식을 붙인다 → Rekognition"은 DVA-C03에서는 범위를 벗어난 보기입니다.
- **통합의 보안 측면은 도메인 2의 작업 2.3이 통째로 담당**합니다(모델 접근 요청·사설 연결·입출력 필터링·에이전트 상호작용 보안·로그의 민감 콘텐츠 보호). 이 작업에서는 **"어떻게 붙이는가"**까지입니다.
- 범위 밖 작업도 가이드가 못 박습니다 — **파운데이션 모델 선택 · AI 프롬프트 엔지니어링 · RAG 아키텍처 설계**, 그리고 **AI 안전 프레임워크 설계·가드레일 구현·AI 거버넌스 구현**은 응시자 역할이 아닙니다. 요구되는 것은 **제공되는 통제를 적용**하는 일입니다.

> 🧠 **원리** — "통합"은 결국 **SDK로 API를 호출하는 일**입니다. 그래서 기술 1.1.5(SDK)에서 배운 것이 그대로 적용됩니다 — 자격 증명·리전·재시도·타임아웃. AI라고 새로운 호출 규율이 생기지 않습니다.

---

## ✍️ 시험 포인트

- **"구독자가 각자 독립적으로 받아야 하고, 한쪽이 몇 시간 장애여도 유실되면 안 된다"** → SNS 토픽 + **구독자별 SQS 큐**(팬아웃). 단서가 "이벤트 패턴 라우팅"·"AWS 서비스 이벤트"면 **EventBridge**.
- **"순서와 중복 제거가 모두 필요하다"** → **SQS FIFO**(`MessageGroupId` + 중복 제거). "처리량이 최우선"이면 Standard + **멱등 소비자**.
- **"모든 인스턴스가 같은 간격으로 재시도해 장애가 길어진다"** → 지수 백오프 + **지터** + 재시도 상한. 지속 장애면 **타임아웃 + 서킷 브레이커**.
- **"백엔드는 항상 200인데 클라이언트에는 400을 줘야 한다"** → 통합 응답 매핑 템플릿의 **`$context.responseOverride.status`**. **"스키마에 맞지 않는 요청을 Lambda까지 보내지 않는다"** → REST **요청 검증기 + 모델**(HTTP API는 미지원).
- **"같은 스트림을 여러 앱이 읽어 `ProvisionedThroughputExceededException`이 난다"** → **향상된 팬아웃**. 같은 예외가 **on-demand에서도** 계속 나면 **파티션 키 불균형**을 의심합니다.
- **AI 기술은 방향으로 가릅니다** — "개발자를 돕는다"면 **1.1.9(Kiro)**, "앱 기능으로 넣는다"면 **1.1.10(Bedrock·AgentCore)**. 보기에 **Q Developer·Rekognition·SageMaker AI**가 있으면 범위 신호를 의심합니다.
- 숫자는 쌍으로 외웁니다 — Lambda **6 MB/1 MB** · API Gateway **29초/30초** · KDS **1 MB/s·2 MB/s** · SQS **30초/12시간**.

---

## ⚠️ 흔한 함정 {#pitfalls}

| 함정 | 바로잡기 |
|---|---|
| 동기 Lambda 호출의 **200을 성공으로** 처리한다 | 함수를 실행할 수 있었다면 **함수 오류에도 200**이다. 응답 본문의 오류를 확인한다 |
| 배치 API가 200이면 전부 성공이라고 본다 | `FailedEntryCount`(EventBridge) · 레코드별 `ErrorCode`(Kinesis) · `Failed` 목록(SQS)을 확인해 **실패분만** 재시도 |
| SQS와 SNS를 같은 것으로 본다 | SQS는 **메시지당 소비자 하나**, SNS는 **구독자마다 사본**. 합치면 팬아웃 |
| SQS의 세 시간을 섞는다 | 가시성=수신 후 숨김(기본 30초·최대 12시간) · 지연=첫 노출까지(0~15분) · 보존=메시지 수명(기본 4일·최대 14일) |
| DLQ 보존 기간을 원본과 같게 둔다 | 표준 큐는 **원래 enqueue 시각 기준**으로 만료된다 — DLQ를 더 길게 |
| 재시도를 호출 스택의 여러 계층에서 각각 한다 | 하위 서비스 부하가 곱절이 된다 — **한 지점에서만** 재시도하고 상한을 둔다 |
| `AccessDenied`·`ValidationException`을 재시도한다 | 영구 오류다. **즉시 반환**해야 부하가 늘지 않는다 |
| on-demand 전환으로 핫 파티션 키를 고치려 한다 | 용량 모드는 **키 불균형을 고치지 못한다** — 키 설계를 바꾼다 |
| HTTP API에서 요청 본문 검증을 하려 한다 | **REST API만** 지원한다. HTTP API는 파라미터 변환까지 |
| 프록시 통합에서 함수가 평문을 반환한다 | `statusCode`·`headers`·`body` JSON이 아니면 **502**다 |
| 기술 1.1.9를 `Amazon Q Developer`로 공부한다 | **범위 내 목록에 없다.** 공식 대체재는 **Kiro**이고 Q Developer IDE 플러그인은 2027-04-30 지원 종료 |
| `Amazon Quick`과 `Amazon Quick Sight`를 묶는다 | Quick은 **범위 내**, Quick Sight는 **범위 밖**이다 |
| 1.1.10 예시로 Rekognition·Polly·SageMaker AI를 든다 | 모두 **out-of-scope 목록에 명시**돼 있다. 범위 내는 **Bedrock·AgentCore** |

---

## 🧪 자가 점검

**Q1.** 주문 이벤트를 재고·결제·알림 세 시스템이 각자 받아야 하고, 한 시스템이 몇 시간 멈춰도 메시지가 유실되면 안 된다. 무엇을 어떻게 구성하는가? (→ 8) 이벤트 기반 패턴)

<details><summary>정답 보기</summary>

**SNS 토픽 + 구독자별 SQS 큐**(팬아웃)입니다. SNS만 쓰면 전달 실패가 SNS의 재시도 정책에만 의존하지만, 구독자 앞에 큐를 두면 큐가 메시지를 **내구적으로 버퍼링**하므로 구독 프로세스가 몇 시간~며칠 장애여도 유실이 없고, 소비자가 자기 속도로 가져갑니다. 큐가 "버퍼링 로드밸런서"가 되어 소비자를 늘리고 줄이기도 쉬워집니다. 필요하면 각 큐에 DLQ를 답니다.
</details>

**Q2.** 동기로 호출한 Lambda가 HTTP 200을 돌려줬는데 실제로는 처리가 실패했다. 왜 이런 일이 생기고, 비동기 호출이라면 실패는 어디로 가는가? (→ 2) 동기와 비동기)

<details><summary>정답 보기</summary>

동기 호출은 **Lambda가 함수를 실행할 수 있었다면 함수가 오류를 반환해도 상태 코드 200**입니다. 그래서 호출자가 **응답 본문의 오류**를 확인해 재시도해야 합니다. 비동기 호출(`InvocationType=Event`)이라면 Lambda가 함수 오류 시 **최대 2회 더** 실행하고, 그래도 처리하지 못한 이벤트는 **DLQ**로 보존됩니다. 페이로드 한도도 다릅니다 — 동기 **6 MB**, 비동기 **1 MB**.
</details>

**Q3.** 백엔드는 항상 200을 반환하는데 본문에 오류가 있으면 클라이언트에 400을 줘야 한다. 백엔드 코드는 바꿀 수 없다. 무엇을 쓰고, 그때 주의할 점은? (→ 4) API)

<details><summary>정답 보기</summary>

**통합 응답 매핑 템플릿의 `$context.responseOverride.status`**로 상태 코드를 재정의합니다. ⚠️ 재정의는 **최종적**이고 같은 파라미터를 여러 번 재정의하면 **5XX**가 나므로, 변수에 모았다가 **템플릿 끝에서 한 번** 적용합니다. 참고로 "스키마에 맞지 않는 요청을 백엔드에 보내지 않는" 요구는 다른 기능입니다 — **REST API 요청 검증기 + 모델**이고 실패하면 즉시 400이며, **HTTP API는 요청 본문 검증을 지원하지 않습니다.**
</details>

**Q4.** 같은 Kinesis 스트림을 네 개의 애플리케이션이 읽자 전파 지연이 커지고 스로틀링이 났다. 처방은? 그리고 on-demand로 바꿨는데도 같은 예외가 계속 나면 무엇을 의심하는가? (→ 6) 스트리밍)

<details><summary>정답 보기</summary>

**향상된 팬아웃(EFO)**입니다. 공유 처리량 소비자는 샤드당 **총 2 MB/s를 나눠 쓰고** `GetRecords`가 샤드당 5 TPS라 소비자가 늘면 지연이 커집니다(소비자 1개 약 200 ms → 5개 약 1,000 ms). EFO는 **소비자마다 샤드당 2 MB/s**를 받고 `SubscribeToShard`로 HTTP/2 푸시하며 평균 약 **70 ms**입니다. on-demand로 바꿔도 같은 예외가 나면 **단일 파티션 키로 쏠린 핫 샤드**를 의심합니다 — 같은 키는 같은 샤드로 가므로 **용량 모드가 키 불균형을 고치지 못합니다.**
</details>

**Q5.** 재시도를 넣었는데 장애가 더 길어졌다. 무엇이 빠졌고, 어떤 오류는 애초에 재시도하지 않아야 하는가? (→ 3) 복원력)

<details><summary>정답 보기</summary>

**지터와 재시도 상한**이 빠졌습니다. 지터가 없으면 같은 시점에 실패한 클라이언트가 같은 시점에 재시도해 **재시도 폭주**가 나고, 재시도는 그 자체로 **서버 용량을 더 쓰는 행위**입니다. REL05-BP03은 지수 백오프·지터·최대 횟수 제한을 **함께** 쓰라고 합니다. 또 호출 스택의 여러 계층이 각자 재시도하면 하위 부하가 곱절이 되므로 **한 지점에서만** 재시도합니다. `AccessDenied`·`ValidationException`·`ResourceNotFound` 같은 **영구 오류는 즉시 반환**하고, 지속 장애에는 **서킷 브레이커**로 빨리 실패합니다.
</details>

**Q6.** 기술 1.1.9와 1.1.10은 둘 다 AI인데 무엇이 다른가? 그리고 보기에 `Amazon Q Developer`와 `Amazon Rekognition`이 있으면 어떻게 판단하는가? (→ 9) AI 보조 개발 · 10) 관리형 AI 통합)

<details><summary>정답 보기</summary>

**방향이 반대입니다.** 1.1.9는 **AI로 개발하기**(코드 생성·검토·최적화)이고, 1.1.10은 **AI를 애플리케이션 기능으로 넣기**입니다. 범위 내 목록에서 1.1.9에 해당하는 개발 도구는 **Kiro**뿐이고, 1.1.10의 대상은 **Bedrock·Bedrock AgentCore**입니다.

보기 판단: **`Amazon Q Developer`는 범위 내 목록에 없습니다**(IDE 플러그인은 2027-04-30 지원 종료, 공식 대체재가 Kiro). **`Amazon Rekognition`은 out-of-scope 목록에 명시**돼 있습니다(`Polly`·`SageMaker AI`·`Strands Agents`도 함께). 둘 다 범위 신호로 읽습니다. ⚠️ 다만 "목록에 없다"와 "범위 밖이다"는 다릅니다 — Rekognition은 **명시된 범위 밖**이고, Q Developer는 **어느 목록에도 없는** 경우입니다.
</details>

**Q7.** DynamoDB에 저장할 항목이 400 KB를 넘는다. 공식 처방 세 가지는? 그리고 `BatchWriteItem`의 16 MB는 무엇의 한도인가? (→ 7) 직렬화)

<details><summary>정답 보기</summary>

세 처방은 ① 큰 속성을 **압축** ② 여러 항목으로 쪼개 **정렬 키로 색인** ③ **S3에 객체로 저장하고 `S3Location` 식별자를 항목에 두기**입니다. ③은 키·인덱스에 쓰는 속성만 테이블에 남기고, 앱이 `S3Location`을 확인해 S3에서 전체 데이터를 가져오는 로직을 가져야 합니다.

**16 MB는 저장 크기가 아니라 전송 데이터 한도**입니다 — DynamoDB JSON 전송 표현이 저장 크기(항목당 400 KB)보다 클 수 있어 `BatchWriteItem`이 별도 한도를 가집니다.
</details>

---

### 📌 출처

1. REL04-BP02 Implement loosely coupled dependencies — https://docs.aws.amazon.com/wellarchitected/2025-02-25/framework/rel_prevent_interaction_failure_loosely_coupled_system.html
2. Asynchronous communication (AWS Prescriptive Guidance) — https://docs.aws.amazon.com/prescriptive-guidance/latest/modernization-integrating-microservices/asynchronous.html
3. Invoke a Lambda function synchronously — https://docs.aws.amazon.com/lambda/latest/dg/invocation-sync.html
4. Invoking a Lambda function asynchronously — https://docs.aws.amazon.com/lambda/latest/dg/invocation-async.html
5. Retry behavior (AWS SDKs and Tools Reference Guide) — https://docs.aws.amazon.com/sdkref/latest/guide/feature-retry-behavior.html
6. REL05-BP03 Control and limit retry calls — https://docs.aws.amazon.com/wellarchitected/2025-02-25/framework/rel_mitigate_interaction_failure_limit_retries.html
7. Circuit breaker pattern (AWS Prescriptive Guidance) — https://docs.aws.amazon.com/prescriptive-guidance/latest/cloud-design-patterns/circuit-breaker.html
8. Choose between REST APIs and HTTP APIs — https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-vs-rest.html
9. Request validation for REST APIs in API Gateway — https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-method-request-validation.html
10. Override your API's request and response parameters and status codes — https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-override-request-response-parameters.html
11. Lambda proxy integrations in API Gateway — https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html
12. AWS SDKs and Tools standardized credential providers — https://docs.aws.amazon.com/sdkref/latest/guide/standardized-credentials.html
13. AWS Signature Version 4 for API requests — https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_sigv.html
14. Amazon Kinesis Data Streams Terminology and concepts — https://docs.aws.amazon.com/streams/latest/dev/key-concepts.html
15. Develop enhanced fan-out consumers with dedicated throughput — https://docs.aws.amazon.com/streams/latest/dev/enhanced-consumers.html
16. Change data capture for DynamoDB Streams — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Streams.html
17. Amazon SQS message quotas — https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/quotas-messages.html
18. Amazon SQS visibility timeout — https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-visibility-timeout.html
19. Using dead-letter queues in Amazon SQS — https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-dead-letter-queues.html
20. Amazon SNS message delivery retries — https://docs.aws.amazon.com/sns/latest/dg/sns-message-delivery-retries.html
21. What Is Amazon EventBridge? — https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-what-is.html
22. How EventBridge retries delivering events — https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-rule-retry-policy.html
23. Amazon Q Developer IDE 플러그인 지원 종료 — https://docs.aws.amazon.com/amazonq/latest/qdeveloper-ug/q-developer-ide-end-of-support.html
24. What is Amazon Quick? — https://docs.aws.amazon.com/quick/latest/userguide/what-is.html
25. DVA-C03 공식 시험 가이드 · 콘텐츠 도메인 1 (한국어) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/developer-associate-03/developer-associate-03-domain1.html
26. DVA-C03 범위 내 AWS 서비스 (한국어) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/developer-associate-03/dva-03-in-scope-services.html
27. DVA-C03 범위 외 AWS 서비스 (한국어) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/developer-associate-03/dva-03-out-of-scope-services.html
