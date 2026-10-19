---
examGuideTaskId: dea-t3-1
certCode: DEA-C01
domain: 3
domainName: 데이터 운영 및 지원
domainWeightPct: 22
title: 데이터 처리 자동화 (MWAA·Step Functions·SDK·Lambda·EventBridge)
coversTasks:
  - "3.1"
sources:
  - title: Configuring Amazon MWAA worker automatic scaling (공식 문서)
    url: https://docs.aws.amazon.com/mwaa/latest/userguide/mwaa-autoscaling.html
  - title: Update an Amazon MWAA environment (공식 문서)
    url: https://docs.aws.amazon.com/mwaa/latest/userguide/update-environment.html
  - title: Using CloudWatch Logs to log execution history in Step Functions (공식 문서)
    url: https://docs.aws.amazon.com/step-functions/latest/dg/cw-logs.html
  - title: Retries (Boto3 guide) (공식 문서)
    url: https://docs.aws.amazon.com/boto3/latest/guide/retries.html
  - title: Using the Amazon Redshift Data API (공식 문서)
    url: https://docs.aws.amazon.com/redshift/latest/mgmt/data-api.html
  - title: Use workgroups to control query access and costs (Amazon Athena) (공식 문서)
    url: https://docs.aws.amazon.com/athena/latest/ug/workgroups-manage-queries-control-costs.html
  - title: Schedule types in EventBridge Scheduler (공식 문서)
    url: https://docs.aws.amazon.com/scheduler/latest/UserGuide/schedule-types.html
  - title: DEA-C01 공식 시험 가이드 도메인 3 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain3.html
lastVerified: 2026-10-20
---

# 데이터 처리 자동화 (MWAA·Step Functions·SDK·Lambda·EventBridge)

> **커버하는 공식 Task** — DEA-C01 · 도메인 3 「데이터 운영 및 지원」(22%) · **Task 3.1 AWS 서비스를 사용하여 데이터 처리 자동화** (`dea-t3-1`)
> Skill이 **9개**로 도메인 3에서 가장 넓습니다. 도메인 1의 Task 1.3이 "무엇으로 오케스트레이션할지 **고르는**" 쪽이라면, 이 Task는 **이미 고른 것을 운영하고 고장 났을 때 어디를 보는지**를 묻습니다.
> **Skill 3.1.6(변환을 위한 데이터 준비)은 v1.1 개정**으로 Amazon SageMaker Unified Studio 예시가 들어왔습니다.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명할 수 있어야 합니다. (공식 시험 가이드 Task 3.1의 Skill 항목)

- [ ] MWAA의 **DAG 배포 경로·워커 자동 확장·환경 업데이트 전략**을 설명한다
- [ ] MWAA **증상 → 볼 로그 그룹**을 1:1로 짚는다(스케줄러 오류·큐 적체·requirements 실패)
- [ ] Step Functions **Standard와 Express의 실행 이력·로깅 차이**를 안다
- [ ] boto3의 **재시도 모드·페이지네이터·웨이터·자격 증명 탐색 순서**를 구분한다
- [ ] **EMR 스텝·자동 종료, Redshift 예약 쿼리·저장 프로시저, Glue 트리거·북마크**를 요구사항으로 고른다
- [ ] **Data API**(Redshift·RDS)의 쓰임새와 한도, **멱등 토큰**의 필요를 설명한다
- [ ] **DataBrew·Visual ETL·Data Wrangler**가 각각 무엇을 하는 도구인지 구분한다
- [ ] Athena의 **워크그룹·사용량 제어·파티션 프로젝션·페더레이션**을 상황에 맞게 고른다
- [ ] Lambda의 **세 가지 호출 방식별 재시도·실패 처리**를 설명한다
- [ ] **EventBridge 규칙과 Scheduler**를 구분하고 재시도·DLQ를 구성한다

---

## 🎯 왜 중요한가

- 도메인 3은 채점 콘텐츠의 **22%** 입니다. 그 안에서 3.1은 **Skill 9개**로 가장 넓고, MWAA·Step Functions·boto3·EMR·Redshift·Glue·Athena·Lambda·EventBridge까지 걸칩니다.
- 이 Task의 문항은 **"무엇을 쓸까"가 아니라 "증상이 이런데 어디를 보고 무엇을 바꿀까"** 로 나옵니다. 같은 MWAA 질문이라도 *스케줄러가 안 돈다*와 *작업이 큐에 쌓인다*의 정답이 다릅니다.
- 운영 문항은 **기본값**이 승부처입니다. Glue 북마크는 기본 꺼짐, Step Functions Standard의 콘솔 로깅은 기본 꺼짐, MWAA 워커 교체는 기본 Forced — 기본값을 알아야 "왜 이런 일이 벌어졌는가"를 설명할 수 있습니다.

---

## 🔤 먼저 알아야 할 용어

이 문서를 읽는 데 필요한 기초 용어입니다. 이미 알면 건너뛰세요.

| 용어 | 영문 | 한 줄 풀이 |
|---|---|---|
| **DAG** | directed acyclic graph | Airflow에서 *작업과 의존 관계*를 적어 둔 파이프라인 정의 |
| **스케줄러** | scheduler | DAG를 읽어 *조건이 맞은 작업을 큐에 넣는* Airflow 구성 요소 |
| **워커** | worker | 큐에 들어온 *작업을 실제로 실행하는* 프로세스 |
| **스텝** | step | EMR 클러스터에 제출하는 *작업 단위 하나* |
| **잡 북마크** | job bookmark | Glue가 *이미 처리한 데이터를 기억*해 다시 읽지 않게 하는 상태 |
| **멱등성** | idempotency | *같은 요청을 두 번 보내도 결과가 한 번과 같은* 성질 |
| **이벤트 소스 매핑** | event source mapping | Lambda가 스트림·큐를 *직접 폴링*하도록 연결해 두는 설정 |
| **DLQ** | dead-letter queue | 재시도를 다 쓰고도 실패한 것을 *버리지 않고 모아 두는* 큐 |
| **콜드 스타트** | cold start | 실행 환경을 새로 준비하느라 *첫 호출이 느려지는* 현상 |
| **푸시다운** | pushdown | 필터·집계를 *데이터가 있는 쪽으로 내려보내* 읽는 양을 줄이는 것 |

---

## 📖 핵심 개념

### 1) MWAA 운영 — DAG 배포·워커 확장·환경 업데이트 {#mwaa-ops}

Amazon MWAA는 Apache Airflow를 관리형으로 돌려 주는 서비스입니다. 운영에서 외워야 할 것은 **"내가 올린 코드가 언제 반영되는가"** 와 **"워커가 언제 늘어나는가"** 입니다.

- **DAG 배포** — S3 버킷의 새 객체·변경 객체가 스케줄러·워커 컨테이너의 dags 폴더로 **30초마다** 동기화됩니다. 기존 DAG의 변경은 **다음 DAG 처리 루프**에서 반영됩니다. 즉 "파일을 올렸는데 UI에 아직 없다"는 보통 고장이 아니라 **주기 대기**입니다.
- **워커 자동 확장** — 필요한 워커 수는 **(실행 중 작업 + 대기 작업) ÷ 워커당 작업 수** 로 산정하고, 필요량이 현재 워커 수보다 크면 Fargate 워커를 **최대 워커 수까지** 늘립니다. 콘솔에서 지정할 수 있는 최대 워커 수의 기본 상한은 **25** 입니다. 축소 중에도 **작업을 하던 워커는 끝날 때까지 보호**됩니다.
  - 예: mw1.small, 최대 워커 10, 워커당 작업 5개 → **동시 작업 50개**, 나머지는 대기합니다.
- **환경 업데이트의 워커 교체 전략** — **Forced가 기본**이며 활성 워커를 즉시 멈춰 **실행 중 작업이 실패**합니다. **Graceful**은 워커가 **최대 12시간** 작업을 계속하게 하고 새 작업만 갱신된 워커로 보냅니다. Graceful을 쓰려면 **Airflow 2.4.3 이상**이어야 하고, 기존 환경은 Forced 업데이트를 **한 번 거쳐야** 합니다.
- **환경의 VPC 네트워크는 생성 후 바꿀 수 없습니다.** 네트워크를 잘못 잡았으면 환경을 다시 만들어야 합니다.

> 💡 시험 단서: **"업데이트 중 실행 중인 작업이 실패하지 않게"** → Graceful. 기본값(Forced)을 그대로 두면 실패합니다.

### 2) MWAA 트러블슈팅 — 증상에서 로그 그룹으로 {#mwaa-troubleshoot}

로깅 옵션을 활성화하면 **옵션마다 CloudWatch 로그 그룹**이 생기고, 이름은 `airflow-환경이름-로그유형` 형식입니다. 유형은 다섯 가지입니다.

| 로그 그룹 | 담는 것 | 여기서 찾는 증상 |
|---|---|---|
| **DAGProcessing** | 스케줄러의 DAG 프로세서 매니저 로그 | DAG가 UI에 안 뜸, 파싱 오류 |
| **Scheduler** | 스케줄러 동작 | 스케줄링이 안 됨. **패키지 설치 로그(`requirements_install_ip` 스트림)도 여기** |
| **Task** | 작업 인스턴스 실행 | 특정 작업만 실패 |
| **WebServer** | Airflow UI | 5xx 오류 |
| **Worker** | 워커 실행 | 작업이 느림·중단 |

로그는 **콘솔에서 먼저 활성화**해야 CloudWatch에서 볼 수 있고, 선택한 **레벨 이상**의 로그가 전송됩니다.

스케줄러는 모든 작업과 DAG를 감시하며 의존성이 충족된 작업 인스턴스를 호출하고, **하트비트가 임계값 동안 없으면 비정상**으로 봅니다. 헬스 체크 임계값 기본은 **30초** 이고 환경 구성에서 바꿀 수 있습니다.

| 증상 | 의심 원인·확인 위치 | 조치 |
|---|---|---|
| "The scheduler does not seem to be running", DAG 목록이 갱신되지 않음 | 메타데이터 DB 접속용 보안 그룹 규칙, 의존성 설치 실패, 과부하 스케줄러, 깨진 DAG | 보안 그룹이 **HTTPS 443과 TCP 5432** 를 허용하는지 확인하고 DAGProcessing·Scheduler 로그를 본다 |
| 작업이 멈추거나 끝나지 않음 | DAG가 너무 많음(**환경 용량의 50% 초과** 시 스케줄러 과부하, **비활성 DAG도 파싱**됨), 큐에 작업 적체 | DAG 수·동시 실행 작업을 줄이고 작업을 시차 배치, **최소 워커를 늘린다** |
| requirements.txt 업데이트가 **20분** 넘게 걸림 | 설치 실패로 환경 업데이트가 실패해 **마지막 안정 이미지로 롤백** 중 | 패키지 버전 고정 확인, 로그 그룹 생성·실행 역할의 권한 확인 |
| 환경이 Creating에서 멈춤 / Create failed | VPC 네트워크 구성(퍼블릭 라우팅이면 보안 그룹 자기 참조 또는 443·5432 허용) | VPC·실행 역할·사용자 권한 점검 |
| "No space left on device" | MWAA 컨테이너 저장소는 **유한** | `--no-cache-dir` 로 설치하는 시작 스크립트 또는 Python wheel 사용 |
| 웹서버 5xx | Airflow 구성 옵션 오류, requirements와 Airflow 버전 비호환 | 구성 옵션·requirements 호환성 점검 |

- DAG 파싱 부하를 줄이려면 DAG 폴더에 **`.airflowignore`** 를 두어 DAG가 아닌 파일을 파싱에서 제외합니다.

> ⚠️ **DB 오류는 스케줄러 장애의 "증상"일 때가 많습니다.** 메시지만 보고 데이터베이스를 손대면 원인을 비껴갑니다.

### 3) Step Functions 운영 — 이력은 어디에 남는가 {#sfn-ops}

| 구분 | Standard | Express |
|---|---|---|
| 실행 이력 | **Step Functions가 기록** | **기록하지 않음** → 이력·결과를 보려면 CloudWatch Logs 로깅을 구성 |
| 콘솔에서 만들 때 로깅 | **기본 꺼짐** | **기본 켜짐** |

- 로그 레벨은 **ALL·ERROR·FATAL·OFF** 입니다.
- CloudWatch Logs 전달은 **best-effort** 라 완전성·적시성이 보장되지 않습니다. 다만 **로그 게시가 실행을 막거나 느리게 하지는 않습니다.**
- **모든 상태 머신이 실행 메트릭을 내보냅니다.** 알람 대상은 **ExecutionsFailed**(실패 실행 수)·**ExecutionsTimedOut**(어떤 이유로든 타임아웃된 실행 수)입니다.
- 오류 이름으로 원인을 좁힙니다. **`States.DataLimitExceeded`** 는 상태의 출력(또는 커넥터 입력)이 **페이로드 크기 할당량보다 클 때** 나고, Lambda 호출이 최대 호출 수를 넘으면 **`Lambda.TooManyRequestsException`** 으로 보고됩니다.

### 4) SDK(boto3) 호출 — 재시도·페이지네이터·웨이터 {#boto3}

| retry mode | 최대 시도 | 특징 |
|---|---|---|
| **legacy** | 5 (최초 요청 포함) | 제한된 오류·상태 코드 목록에서만 재시도 |
| **standard** | 3 (최초 요청 포함) | **서킷 브레이킹**, 확장된 오류 목록, 지수 백오프 **최대 20초** |
| **adaptive** | standard와 같은 기능 + **클라이언트 측 속도 제한** | **실험적(experimental)** 모드 |

- ⚠️ **기본 모드가 무엇인지는 시점에 따라 다릅니다.** 현행 boto3 문서는 legacy를 기본으로 적지만, AWS는 SDK 재시도 동작을 갱신해 **2026년 11월에 standard를 기본으로** 만든다고 공지했습니다. 시험에서는 **"기본값이 무엇인가"보다 모드별 특성**(서킷 브레이킹·재시도 쿼터 = standard, 클라이언트 측 속도 제한 = adaptive)으로 판단하세요.
- **`max_attempts`의 의미가 두 가지**입니다. 설정 파일·환경 변수에서는 **최초 요청을 포함**한 총 시도이고, Config 객체에서는 **최초 요청을 제외**한 재시도 횟수입니다. 혼동을 피하려면 Config의 **`total_max_attempts`** 를 씁니다.
- **Paginator** — 잘린(truncated) API 결과를 전부 순회하는 추상화로 `get_paginator()` 로 만듭니다. 예를 들어 S3 `list_objects` 는 한 번에 **최대 1,000개** 객체를 반환합니다. `PaginationConfig` 의 `MaxItems`·`PageSize`·`StartingToken` 으로 조절하고 JMESPath로 클라이언트 측 필터링을 할 수 있습니다.
- **Waiter** — 리소스 상태를 폴링하다가 원하는 상태에 도달하거나 실패하면 끝나는 헬퍼로 `get_waiter()` 로 얻어 `wait()` 를 호출합니다. **waiter가 없는 클라이언트도 있습니다**(예: SQS).
- **자격 증명 탐색 순서** — 위에서부터 찾다가 **찾는 즉시 중단**합니다: `client()`/Session 매개변수 → 환경 변수 → assume role → web identity → IAM Identity Center → 공유 자격 증명 파일 → 콘솔 로그인 → config 파일 → Boto2 파일 → 컨테이너 자격 증명 공급자 → **EC2 인스턴스 메타데이터**(마지막).

### 5) 서비스 기능으로 데이터 처리 — EMR·Redshift·Glue {#service-features}

**Amazon EMR**

- 클러스터 상태는 **STARTING → BOOTSTRAPPING → RUNNING → WAITING → TERMINATING → TERMINATED** 로 흐르고, 오류로 끝나면 **TERMINATED_WITH_ERRORS** 입니다. **WAITING은 살아 있지만 실행할 스텝이 없는 상태** — 유휴 비용이 나는 지점입니다.
- 스텝은 클러스터당 **PENDING과 RUNNING을 합쳐 256개** 까지 둘 수 있고, 스텝 취소는 **EMR 5.28.0 이상**에서 대기 중·실행 중 모두 가능합니다.
- 스텝 실패 시 동작은 **`ActionOnFailure`** 로 정합니다.

| ActionOnFailure | 동작 |
|---|---|
| `TERMINATE_CLUSTER` | 클러스터를 종료 |
| `CANCEL_AND_WAIT` | 대기 중 스텝을 취소하고 WAITING으로 |
| `CONTINUE` | 다음 스텝을 계속 진행 |

- **자동 종료 정책**의 유휴 시간은 **60초 ~ 604,800초(7일)** 범위입니다. 임시 클러스터가 WAITING으로 남아 비용이 새는 문제의 정답은 대개 이것입니다.
- **EMR Serverless** — 사전 초기화(pre-initialized) 워커가 없으면 자원 결정·프로비저닝에 **최대 120초**가 걸리고, 워커는 **15분 유휴 시 자동 종료**됩니다(변경 가능).

**Amazon Redshift**

- **예약 쿼리**(쿼리 편집기 v2)는 **EventBridge가 시작하고 Data API로 실행**됩니다. 정의에는 실행 역할(IAM), 인증(Secrets Manager 또는 임시 자격 증명), 클러스터/워크그룹, 데이터베이스, SQL, 빈도 또는 cron 값이 필요하고 SNS 알림을 선택할 수 있습니다.
- **저장 프로시저**는 데이터 변환·검증 로직을 DB 안에 캡슐화하고 **`CALL`** 로 실행합니다. 기본 보안은 **INVOKER**(호출자 권한)이고, **DEFINER**를 지정하면 소유자 권한으로 실행됩니다.
- **구체화된 뷰(MV)의 AUTO REFRESH** 는 기반 테이블이 바뀌면 가능한 한 빨리 새로 고치지만 **워크로드가 우선**이라 지연되거나 중단될 수 있습니다. **정해진 시각에 반드시 갱신돼야 하면 수동 `REFRESH MATERIALIZED VIEW` 또는 예약 새로 고침**을 씁니다.

**AWS Glue**

- **트리거 3종** — `on demand` · `schedule` · `conditional`. 하나의 트리거가 시작할 수 있는 **크롤러는 2개까지**이고, 의존 체인의 모든 잡·크롤러는 **단일 scheduled 또는 on-demand 트리거의 후손**이어야 합니다.
- **잡 북마크** — 이미 처리한 데이터를 추적합니다. **기본은 Disable** 이라 매번 전체 데이터를 처리하고 이전 실행 출력 관리는 사용자 몫입니다. S3 소스는 **객체의 마지막 수정 시간**으로 처리 여부를 판단하므로, 수정된 파일은 다시 처리됩니다.
- **잡 타임아웃 기본값은 Glue 버전마다 다릅니다** — **4.0 이하 2,880분, 5.0 이상 480분** 이며 7일(10,080분) 미만이어야 합니다. `MaxRetries` 는 잡이 실패할 때 다시 시도하는 최대 횟수입니다.

### 6) 데이터 API 사용·유지 관리 {#data-api}

여기서 **Data API**는 **영속 연결·드라이버 없이 HTTPS 엔드포인트와 AWS SDK로 SQL을 실행**하는 방식입니다(Redshift Data API, RDS Data API).

**Redshift Data API**

- 호출은 **비동기**이고, 자격 증명은 **Secrets Manager 또는 임시 DB 자격 증명**(IAM Identity Center도 가능)을 쓰며 **호출에 비밀번호를 넣지 않습니다.**
- 한도: 쿼리 최대 **24시간**, 클러스터당 활성(STARTED·SUBMITTED) 쿼리 **500개**, 결과 크기 **500 MB**(gzip 압축 후), **결과 보존 24시간**, 쿼리문 크기 **200 KB**.
- **`BatchExecuteStatement`** 는 문장을 순서대로 실행하며 **기본은 단일 트랜잭션**이라 하나라도 실패하면 모두 롤백됩니다. `ExecutionMode` 로 `AUTO_COMMIT` 을 선택할 수 있습니다.
- **멱등성** — `ExecuteStatement`·`BatchExecuteStatement` 에는 선택적 **`ClientToken`** 이 있고 **8시간 후 만료**됩니다. AWS SDK로 호출하면 SDK가 재시도용 클라이언트 토큰을 자동 생성하므로 직접 지정하지 않는 편이 낫습니다. 반대로 **Step Functions 상태 머신은 기본적으로 재시도가 꺼져 있고**, 재시도를 쓴다면 **`ClientToken` 을 넣어 재시도 사이에 같은 값을 유지**해야 중복 실행이 없습니다. 쓰로틀되면 `ThrottlingException` 이 반환되므로 SDK 재시도 전략을 씁니다.

**RDS Data API(Aurora)** — 응답 크기 한도 **1 MiB**, **라이터 인스턴스에서만** 실행되며 **T 계열 인스턴스 클래스는 지원하지 않습니다.**

### 7) 변환을 위한 데이터 준비 (v1.1 개정) {#data-prep}

| 도구 | 성격 | 시험 단서 |
|---|---|---|
| **AWS Glue DataBrew** | 코드 없이 쓰는 완전 관리형 **시각적 데이터 준비** 서비스. **250개 넘는** 내장 변환. 프로젝트·데이터셋·레시피·잡·데이터 계보·데이터 프로파일 6개 개념 | "코드 작성 없이 정제·정규화", "프로파일 잡" |
| **SageMaker Unified Studio Visual ETL** | 드래그 앤 드롭 ETL 편집기. **AWS Glue 대화형 세션 위에서** 동작하며 Glue 4.0·5.0·5.1을 사용 | "Unified Studio", "시각적 ETL" |
| **SageMaker Data Wrangler** | 현재는 **SageMaker Canvas 안의 기능**으로 제공(ML 데이터 준비·피처화) | "ML 학습용 데이터 준비", "Canvas" |

- DataBrew **프로젝트**는 **읽기 전용 데이터셋**과 레시피로 구성되고, 콘솔은 기본으로 데이터셋의 **처음 500행 샘플**을 보여 줍니다. 레시피를 게시하면 **잡**에서 전체 데이터셋에 적용하거나 **프로파일**을 만들 수 있습니다. DataBrew는 Glue Studio와 통합되어 **Glue ETL 잡·워크플로 안에서 레시피를 오케스트레이션**할 수 있습니다.
- SageMaker AI의 데이터 준비 도구 선택 가이드는 세 가지를 비교합니다: **Canvas의 Data Wrangler**(시각적 점-클릭), **Studio의 SQL 확장**(Redshift·Snowflake·Athena·S3에 SQL, Spark 학습 불필요), **Studio에서 EMR Serverless**(대규모 Spark/Hive).
- ⚠️ 시험 범위 서비스 목록에는 **AWS Glue DataBrew와 Amazon SageMaker AI**가 있고 "SageMaker Unified Studio" 항목은 따로 없습니다. Skill 문구에는 Unified Studio가 예시로 들어와 있으니 **Visual ETL 수준**으로만 잡아 두세요.

### 8) Athena로 데이터 쿼리 — 워크그룹·사용량 제어·파티션 프로젝션 {#athena}

- **워크그룹** — 워크로드 분리, 팀 접근 제어, **설정 강제**, 쿼리 지표 추적·비용 통제에 씁니다. 워크그룹은 **IAM 리소스**라 리소스 수준 정책으로 접근을 제어하고, **워크그룹마다 쿼리 기록과 저장 쿼리 목록이 따로** 있습니다. 결과 위치·암호화 같은 워크그룹 전체 설정은 선택적으로 **모든 쿼리에 강제**할 수 있습니다(강제하면 클라이언트 설정이 무시됩니다).
- **결과 위치** — 쿼리 실행 전에 S3 쿼리 결과 위치를 지정하거나, 위치가 지정되고 클라이언트 설정을 덮어쓰는 워크그룹을 써야 합니다. 없으면 쿼리가 실패합니다.
- **데이터 사용량 제어** — 쿼리당·워크그룹당 스캔 한도를 둘 수 있습니다. 한도 값은 **10 MB ~ 7 EB** 이고 기본 동작은 **초과 쿼리 취소(변경 불가)** 이며 **취소된 쿼리도 요금이 청구**됩니다. 워크그룹에는 **쿼리당 한도를 1개만** 만들 수 있습니다.
- **파티션 프로젝션** — 파티션 정보를 카탈로그 대신 **테이블 속성의 규칙**(값 범위·프로젝션 유형)으로 두고 Athena가 계산합니다. 켜면 **Glue 데이터 카탈로그/Hive 메타스토어에 등록된 파티션 메타데이터를 무시**합니다. 파티션이 수만 개라 등록·갱신이 부담일 때의 답입니다.
- **페더레이션** — S3 밖의 데이터 소스를 제자리에서 쿼리합니다. 쿼리 시 Athena가 커넥터를 호출해 읽을 데이터를 정하고 병렬성을 관리하며 **필터를 푸시다운**합니다. ⚠️ **"페더레이션은 항상 Lambda 위에서 돈다"고 단정하지 마세요** — 2026-04-21부터 새로 만든 일부 커넥터는 **Glue 데이터 카탈로그에 자동 등록되고 계정 내 Lambda 함수를 쓰지 않습니다.**

### 9) Lambda로 데이터 처리 자동화 {#lambda}

| 호출 방식 | 대표 소스 | 재시도·실패 처리 |
|---|---|---|
| **동기** | API Gateway 등 호출자가 응답을 기다림 | 호출자(또는 서비스)가 재시도를 결정 |
| **비동기** | S3, SNS 등이 이벤트를 큐에 넣음 | 함수 오류 시 **2회 재시도**, 큐 보관 **최대 6시간**(재시도 0~2회로 조정 가능), **DLQ 또는 대상(destination)** |
| **이벤트 소스 매핑(폴링)** | DynamoDB, Kinesis, SQS | **스트림**: 배치 전체 재시도, 오류가 해결되거나 항목이 만료될 때까지 **샤드 처리가 막힘**(Iterator Age로 감시). **큐**: 가시성 제한 시간·redrive 정책으로 제어 |

- 한도: **일반 Lambda 함수의 타임아웃은 최대 900초(15분)**, 메모리 128 MB ~ 10,240 MB, 페이로드 동기 6 MB·비동기 1 MB, 계정·리전별 동시 실행 기본 **1,000**, 함수별 확장 속도는 10초마다 실행 환경 **1,000개** 입니다.
- **동시성 제어** — **예약 동시성**은 함수가 쓸 수 있는 동시 인스턴스의 최소·최대를 정하고 **계정 동시성 한도에서 차감되며 추가 요금이 없습니다.** **프로비저닝 동시성**은 미리 초기화한 실행 환경 수로 **콜드 스타트를 줄이며 추가 요금이 듭니다.**
- 비동기 실패 처리는 **대상(destination)을 선호**합니다(추가 대상 지원, 추가 정보 포함).
- 이벤트 소스 매핑은 이벤트를 **최소 한 번** 처리하므로 **중복이 생길 수 있어 함수를 멱등으로** 만들어야 합니다.
- **SQS 이벤트 소스** — 함수 타임아웃은 **큐 가시성 제한 시간 이하**여야 하고, 가시성 제한 시간은 **함수 타임아웃의 최소 6배**를 권장합니다. 오류가 나면 기본으로 배치 전체가 큐로 돌아가므로 **부분 배치 응답**으로 실패 메시지만 돌려보내고, 소스 큐 redrive 정책의 **`maxReceiveCount` 는 5 이상**을 권장합니다.

### 10) 이벤트와 스케줄러 관리 — 규칙 vs Scheduler {#eventbridge}

| 구분 | EventBridge 규칙 | EventBridge Scheduler |
|---|---|---|
| 용도 | **이벤트 패턴**에 맞는 이벤트를 대상으로 전달(한 규칙이 여러 대상에 병렬 전달) | **시간 기반·일회성** 호출 |
| 예약 | **"예약 규칙"은 레거시** — Scheduler 사용 권장 | `rate`·`cron`·일회성(`at`) 3종, **시간대 지정** |
| 정밀도 | — | **60초** 정밀도(유연 시간 창 미사용 시) |
| 재시도 기본 | 24시간·최대 185회, 이후 폐기 또는 DLQ | 24시간·최대 185회, DLQ 없으면 폐기(설정 변경 가능) |
| DLQ | 실패한 이벤트를 받는 DLQ 구성 | **SQS 표준 큐**로 전달 |

- Scheduler 표현식: `rate(값 단위)` 는 minutes·hours·days, `cron` 은 **분 시 일 월 요일 연 6개 필드**, 일회성은 `at(yyyy-mm-ddThh:mm:ss)` 입니다. **일회성 스케줄도 완료 후 계정 할당량을 차지**하므로 완료 후 삭제를 권장합니다.
- **시간대와 일광절약시간** — cron·일회성 스케줄을 지정한 시간대로 평가하며 DST를 자동 반영합니다. **봄에 존재하지 않는 시각이면 그날 호출을 건너뛰고, 가을에 시각이 반복돼도 한 번만 실행**합니다.
- Scheduler는 **at-least-once**로 전달하고, **유연한 시간 창(flexible time window)** 으로 호출을 분산해 하위 서비스 부하를 줄입니다. 재시도를 모두 쓰고도 실패한 스케줄은 **DLQ에 호출 정보와 대상 응답을 담은 이벤트**를 전달합니다.
- ⚠️ 위 "24시간·185회"는 **규칙(Classic)의 대상과 Scheduler** 기준입니다. EventBridge의 **새 Custom Event Bus** 는 기본값이 다르므로 그대로 적용하지 마세요.

---

## ✍️ 시험 포인트

1. **MWAA 증상 → 조치** — *"스케줄러가 실행 중이 아니라는 오류 + DAG 목록 미갱신"* 이면 **보안 그룹(TCP 5432·HTTPS 443)·requirements 설치 실패·과부하 스케줄러·깨진 DAG** 를 CloudWatch 로그 그룹에서 확인하는 쪽이 정답 방향입니다. *"작업이 큐에 쌓임"* 이면 **DAG 수·동시 작업 줄이기 + 최소 워커 늘리기**, *"requirements 업데이트가 20분 초과"* 이면 **설치 실패로 롤백 중**입니다. 원인 확인 없이 환경 클래스를 올리는 보기는 비용만 늘립니다.
2. **운영 자동화 수단 고르기** — *"연결·드라이버 관리 없이 매일 SQL 실행"* → **예약 쿼리**. *"여러 SQL 단계를 한 단위로"* → **저장 프로시저(CALL)**. *"정해진 시각에 반드시 갱신"* → **수동·예약 REFRESH**(AUTO REFRESH는 보장되지 않음). *"Glue 잡이 매번 전체 재처리"* → **잡 북마크 Enable**(기본 Disable). *"임시 EMR이 유휴로 남아 비용"* → **자동 종료 정책**.
3. **Lambda 호출 방식 식별이 먼저** — *"S3 업로드 트리거 + 실패 이벤트 보관"* 이면 **비동기 + DLQ/대상**. *"SQS 일부 메시지만 실패"* 면 **부분 배치 응답 + 가시성 6배 + maxReceiveCount 5 이상**. *"Iterator Age 증가"* 면 스트림 **이벤트 소스 매핑**이라 샤드가 막힌 상황입니다.
4. **데이터 접근·쿼리 통제** — *"재시도해도 중복 실행 없이 비동기 SQL"* → **Data API + ClientToken**. *"팀별 결과 위치 강제 + 스캔량 제한"* → **Athena 워크그룹 + 데이터 사용량 제어**. *"파티션이 수만 개"* → **파티션 프로젝션**.
5. **기본값을 묻는 문항** — Glue 북반 Disable, Step Functions Standard 콘솔 로깅 꺼짐, MWAA Forced, Scheduler/규칙 재시도 24시간·185회. 다만 **boto3 기본 재시도 모드와 Glue `MaxRetries` 기본값은 자료마다 달라** 이 문서에서 단정하지 않습니다 — 모드·필드의 **특성**으로 푸세요.

---

## ⚠️ 흔한 함정

1. **Forced vs Graceful** — 기본이 **Forced**라 환경을 업데이트하면 **실행 중 작업이 실패**합니다. Graceful은 최대 12시간 유예(Airflow 2.4.3 이상, 기존 환경은 Forced 1회 선행).
2. **DB 오류를 근본 원인으로 오진** — MWAA의 DB 관련 오류는 대개 **스케줄러 장애의 증상**입니다.
3. **큐 적체 vs 파싱 과부하** — *Queued Tasks 증가* 는 워커 부족(최소 워커 증가), *파싱 시간 증가* 는 DAG 수 과다(**비활성 DAG도 파싱됨**, `.airflowignore`).
4. **Express 실행 이력을 콘솔에서 찾기** — Express는 **이력을 기록하지 않습니다.** CloudWatch Logs를 켜야 합니다.
5. **`max_attempts` 의 두 의미** — 설정 파일·환경 변수는 총 시도, Config 객체는 재시도 횟수. 총 시도를 쓰려면 `total_max_attempts`.
6. **Paginator와 Waiter 혼동** — Paginator는 **다음 페이지 토큰**을 따라 끝까지 순회, Waiter는 **상태가 될 때까지 폴링**합니다.
7. **자격 증명 우선순위** — 코드의 매개변수가 환경 변수보다 **먼저**이고 EC2 인스턴스 메타데이터가 **마지막**입니다.
8. **EMR WAITING을 "끝난 상태"로 오해** — WAITING은 **활성**이며 과금됩니다. 종료 상태는 TERMINATED(정상)·TERMINATED_WITH_ERRORS(오류).
9. **`CANCEL_AND_WAIT` 와 `CONTINUE` 혼동** — "스텝이 실패해도 클러스터는 유지하고 **다음 스텝을 이어서**"는 `CONTINUE` 입니다.
10. **잡 북마크 Pause** — Enable(추적)·Disable(기본, 전체 처리)·Pause(상태를 **갱신하지 않고** 증분 처리). "재처리 방지"는 Enable입니다.
11. **Glue 잡 타임아웃을 "48시간"으로 암기** — 버전마다 다릅니다(**4.0 이하 2,880분 / 5.0 이상 480분**). 문항이 버전을 말하지 않으면 타임아웃 수치를 근거로 삼지 마세요.
12. **Redshift와 RDS Data API 한도 혼동** — Redshift는 **결과 500 MB·보존 24시간**, RDS(Aurora)는 **응답 1 MiB·라이터 전용·T 클래스 미지원**.
13. **Data API 재시도 = 중복 실행** — Step Functions에서 재시도를 켤 때 **`ClientToken` 을 고정하지 않으면** 같은 문장이 두 번 실행될 수 있습니다.
14. **워크그룹 설정을 강제하지 않음** — 강제하지 않으면 클라이언트가 자기 결과 위치를 쓰므로 **팀별 통제가 되지 않습니다.**
15. **스캔 한도를 걸면 비용이 0이 된다는 오해** — 한도를 넘겨 **취소된 쿼리도 요금이 청구**됩니다.
16. **파티션 프로젝션 + 크롤러 병행** — 프로젝션을 켜면 **카탈로그 파티션 메타데이터를 무시**하므로, 크롤러를 더 자주 돌려도 소용이 없습니다.
17. **"페더레이션 = 항상 Lambda"** — 2026-04-21부터 일부 신규 커넥터는 **Glue 데이터 카탈로그 자동 등록 방식**이라 계정 내 Lambda를 쓰지 않습니다.
18. **예약 동시성과 프로비저닝 동시성** — 예약은 **한도 확보(무료)**, 프로비저닝은 **콜드 스타트 감소(유료)**.
19. **스트림 소스를 비동기 호출로 착각** — 스트림은 **이벤트 소스 매핑**이고, 오류가 해결될 때까지 **샤드가 막힙니다.** 비동기의 "2회 재시도 후 DLQ" 모델이 아닙니다.
20. **예약 규칙으로 대규모 스케줄 운영** — 예약 규칙은 **레거시**입니다. 시간 기반은 **Scheduler**(시간대·유연 시간 창·DLQ).
21. **DST가 있는 시간대의 스케줄** — 봄에 존재하지 않는 시각은 **건너뛰고**, 가을에 반복되는 시각은 **한 번만** 실행됩니다.
22. **일회성 스케줄을 방치** — 완료된 일회성 스케줄도 **계정 할당량을 차지**합니다.

---

## 🧪 자가 점검

**Q1.** MWAA 환경의 DAG가 큐에 계속 쌓이고 끝나지 않습니다. 환경 메트릭에서 대기 작업이 늘고 있습니다. 가장 적절한 조치는?

<details><summary>정답 보기</summary>

**동시 실행 작업 수를 줄이고 최소 워커 수를 늘립니다.** 워커 자동 확장은 (실행 중 + 대기) ÷ 워커당 작업 수로 필요 워커를 산정하므로, 최소 워커를 올리면 대기 작업을 더 빨리 소화합니다. 환경 클래스를 무작정 올리는 것은 원인(워커 수 부족)을 확인하지 않은 비용 증가이고, 파싱 과부하(총 파싱 시간 증가)는 다른 증상입니다.
</details>

**Q2.** MWAA 환경을 업데이트해야 하는데, 진행 중인 장시간 작업이 실패하면 안 됩니다. 무엇을 해야 합니까?

<details><summary>정답 보기</summary>

**Graceful 워커 교체 전략을 사용합니다.** 기본값인 Forced는 활성 워커를 즉시 중지해 실행 중 작업이 실패합니다. Graceful은 워커가 최대 12시간 작업을 계속하게 하고 새 작업만 갱신된 워커로 보냅니다. 단 **Airflow 2.4.3 이상**이어야 하고 기존 환경은 Forced 업데이트를 한 번 거쳐야 합니다.
</details>

**Q3.** Express 워크플로를 운영 중인데 콘솔에서 실행 이력이 보이지 않습니다. 원인과 해법은?

<details><summary>정답 보기</summary>

**Express는 Step Functions에 실행 이력을 기록하지 않기 때문입니다.** 이력과 결과를 보려면 **CloudWatch Logs 로깅을 구성**해야 합니다(콘솔에서 만든 Express는 로깅이 기본 켜져 있고, Standard는 기본 꺼져 있습니다). 로그 전달은 best-effort지만 **로그 게시가 실행을 막거나 느리게 하지는 않습니다.**
</details>

**Q4.** Step Functions에서 Redshift Data API로 적재 문장을 실행하고 재시도를 설정했습니다. 재시도가 일어나면 같은 데이터가 두 번 적재될 수 있습니다. 어떻게 막습니까?

<details><summary>정답 보기</summary>

**`ClientToken`(멱등 토큰)을 지정하고 재시도 사이에 같은 값을 유지합니다.** 토큰은 8시간 후 만료됩니다. AWS SDK로 직접 호출할 때는 SDK가 재시도용 토큰을 자동 생성하므로 직접 지정할 필요가 없지만, **Step Functions 상태 머신은 기본적으로 재시도가 꺼져 있고** 재시도를 켜면 토큰을 직접 넣어야 합니다.
</details>

**Q5.** Athena를 쓰는 팀이 늘면서 각자 다른 S3 위치에 결과를 쓰고, 한 사람의 쿼리가 수 TB를 스캔해 비용이 튀었습니다. 두 문제를 한 번에 잡으려면?

<details><summary>정답 보기</summary>

**워크그룹을 만들어 결과 위치를 강제하고, 쿼리당 데이터 사용량 제어를 겁니다.** 워크그룹 전체 설정을 강제하면 클라이언트 설정이 무시되어 결과 위치가 통일됩니다. 스캔 한도는 10 MB ~ 7 EB에서 정하고 초과 쿼리는 취소됩니다(동작 변경 불가, **취소된 쿼리도 과금**). 워크그룹에는 쿼리당 한도를 1개만 둘 수 있습니다.
</details>

---

**Q6 (원리).** 왜 Task 3.1의 정답은 자주 **"기본값을 바꾸는 것"** 일까요?

<details><summary>정답 보기</summary>

**관리형 서비스의 기본값은 "가장 안전하고 가장 싸게 시작하는 값"이지 "운영에 맞는 값"이 아니기 때문입니다.** Glue 북마크가 기본 Disable인 것은 증분 처리가 틀리는 것보다 전체 재처리가 안전해서이고, MWAA가 기본 Forced인 것은 업데이트를 빨리 끝내기 위해서이며, Step Functions Standard의 로깅이 기본 꺼짐인 것은 로그 비용을 물리지 않기 위해서입니다. 그래서 운영 문항의 증상은 대개 **"기본값대로 두었더니 생긴 일"** 이고, 정답은 그 기본값을 요구사항에 맞게 바꾸는 쪽입니다. 보기를 보기 전에 **"지금 이 서비스의 기본 동작이 무엇인가"** 를 먼저 떠올리는 순서가 이 Task의 풀이법입니다.
</details>

---

### 📌 출처

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. (수집·대조: 2026-10-17 · 저작: 2026-10-20 · 사람 검수 전)

1. Accessing Airflow logs in Amazon CloudWatch (Amazon MWAA) — https://docs.aws.amazon.com/mwaa/latest/userguide/monitoring-airflow.html
2. Troubleshooting: DAGs, Operators, Connections, and other issues (Amazon MWAA) — https://docs.aws.amazon.com/mwaa/latest/userguide/t-apache-airflow-202.html
3. Troubleshooting: Creating and updating an Amazon MWAA environment — https://docs.aws.amazon.com/mwaa/latest/userguide/t-create-update-environment.html
4. Configuring Amazon MWAA worker automatic scaling — https://docs.aws.amazon.com/mwaa/latest/userguide/mwaa-autoscaling.html
5. Update an Amazon MWAA environment — https://docs.aws.amazon.com/mwaa/latest/userguide/update-environment.html
6. How do I resolve common issues with my scheduler in Amazon MWAA? (AWS re:Post) — https://repost.aws/knowledge-center/mwaa-scheduler-issues
7. Adding or updating DAGs (Amazon MWAA) — https://docs.aws.amazon.com/mwaa/latest/userguide/configuring-dag-folder.html
8. Using CloudWatch Logs to log execution history in Step Functions — https://docs.aws.amazon.com/step-functions/latest/dg/cw-logs.html
9. Monitoring Step Functions metrics using Amazon CloudWatch — https://docs.aws.amazon.com/step-functions/latest/dg/procedure-cw-metrics.html
10. Handling errors in Step Functions workflows — https://docs.aws.amazon.com/step-functions/latest/dg/concepts-error-handling.html
11. Retries (Boto3 guide) — https://docs.aws.amazon.com/boto3/latest/guide/retries.html
12. Announcing updated retry behavior for AWS SDKs and Tools (AWS Developer Tools Blog) — https://aws.amazon.com/blogs/developer/announcing-updated-retry-behavior-for-aws-sdks-and-tools/
13. Paginators (Boto3 guide) — https://docs.aws.amazon.com/boto3/latest/guide/paginators.html
14. Low-level clients (Boto3 guide) — https://docs.aws.amazon.com/boto3/latest/guide/clients.html
15. Credentials (Boto3 guide) — https://docs.aws.amazon.com/boto3/latest/guide/credentials.html
16. Amazon EMR FAQs — https://aws.amazon.com/emr/faqs/
17. Submit work to an Amazon EMR cluster — https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-work-with-steps.html
18. StepConfig (Amazon EMR API Reference) — https://docs.aws.amazon.com/emr/latest/APIReference/API_StepConfig.html
19. AutoTerminationPolicy (Amazon EMR API Reference) — https://docs.aws.amazon.com/emr/latest/APIReference/API_AutoTerminationPolicy.html
20. Creating a query schedule with query editor v2 (Amazon Redshift) — https://docs.aws.amazon.com/redshift/latest/mgmt/query-editor-v2-schedule-query-create.html
21. Overview of stored procedures in Amazon Redshift — https://docs.aws.amazon.com/redshift/latest/dg/stored-procedure-create.html
22. Refreshing a materialized view (Amazon Redshift) — https://docs.aws.amazon.com/redshift/latest/dg/materialized-view-refresh.html
23. AWS Glue triggers — https://docs.aws.amazon.com/glue/latest/dg/about-triggers.html
24. Tracking processed data using job bookmarks (AWS Glue) — https://docs.aws.amazon.com/glue/latest/dg/monitor-continuations.html
25. CreateJob (AWS Glue Web API Reference) — https://docs.aws.amazon.com/glue/latest/webapi/API_CreateJob.html
26. Using the Amazon Redshift Data API — https://docs.aws.amazon.com/redshift/latest/mgmt/data-api.html
27. Limitations for the Amazon RDS Data API — https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/data-api.limitations.html
28. AWS Glue DataBrew (AWS Prescriptive Guidance) — https://docs.aws.amazon.com/prescriptive-guidance/latest/serverless-etl-aws-glue/databrew.html
29. Creating and using AWS Glue DataBrew projects — https://docs.aws.amazon.com/databrew/latest/dg/projects.html
30. Visual ETL (Amazon SageMaker Unified Studio) — https://docs.aws.amazon.com/sagemaker-unified-studio/latest/userguide/visual-etl.html
31. Recommendations for choosing the right data preparation tool in SageMaker AI — https://docs.aws.amazon.com/sagemaker/latest/dg/data-prep.html
32. In-Scope AWS Services (DEA-C01 exam guide) — https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-in-scope-services.html
33. Use workgroups to control query access and costs (Amazon Athena) — https://docs.aws.amazon.com/athena/latest/ug/workgroups-manage-queries-control-costs.html
34. Configure per-query and per-workgroup data usage controls (Amazon Athena) — https://docs.aws.amazon.com/athena/latest/ug/workgroups-setting-control-limits-cloudwatch.html
35. Use partition projection with Amazon Athena — https://docs.aws.amazon.com/athena/latest/ug/partition-projection.html
36. Use Amazon Athena Federated Query — https://docs.aws.amazon.com/athena/latest/ug/federated-queries.html
37. How do I troubleshoot output location errors when I save Athena query results in an S3 bucket? (AWS re:Post) — https://repost.aws/knowledge-center/athena-invalid-s3-location-error
38. Lambda quotas — https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-limits.html
39. Understanding Lambda Event Function scaling (concurrency) — https://docs.aws.amazon.com/lambda/latest/dg/lambda-concurrency.html
40. Understanding retry behavior in Lambda Event Functions — https://docs.aws.amazon.com/lambda/latest/dg/invocation-retries.html
41. Invoking a Lambda Event Function asynchronously — https://docs.aws.amazon.com/lambda/latest/dg/invocation-async.html
42. Implementing AWS Lambda error handling patterns (AWS Compute Blog) — https://aws.amazon.com/blogs/compute/implementing-aws-lambda-error-handling-patterns/
43. How Lambda processes records from stream and queue-based event sources — https://docs.aws.amazon.com/lambda/latest/dg/invocation-eventsourcemapping.html
44. Creating and configuring an Amazon SQS event source mapping (Lambda) — https://docs.aws.amazon.com/lambda/latest/dg/services-sqs-configure.html
45. Rules in Amazon EventBridge — https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-rules.html
46. Schedule types in EventBridge Scheduler — https://docs.aws.amazon.com/scheduler/latest/UserGuide/schedule-types.html
47. Configuring a schedule's dead-letter queue in EventBridge Scheduler — https://docs.aws.amazon.com/scheduler/latest/UserGuide/configuring-schedule-dlq.html
48. Introducing Amazon EventBridge Scheduler (AWS Compute Blog) — https://aws.amazon.com/blogs/compute/introducing-amazon-eventbridge-scheduler/
49. How EventBridge retries delivering events — https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-rule-retry-policy.html
50. How do I resolve the "psycopg2.OperationalError" in Amazon MWAA? (AWS re:Post) — https://repost.aws/knowledge-center/mwaa-troubleshoot-error
51. CALL (Amazon Redshift SQL Reference) — https://docs.aws.amazon.com/redshift/latest/dg/r_CALL_procedure.html
52. DEA-C01 공식 시험 가이드 도메인 3 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain3.html
