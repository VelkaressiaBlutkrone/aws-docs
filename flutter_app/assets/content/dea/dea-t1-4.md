---
examGuideTaskId: dea-t1-4
certCode: DEA-C01
domain: 1
domainName: 데이터 수집 및 변환
domainWeightPct: 34
title: 프로그래밍 개념 (코드 최적화·Lambda·IaC·CI/CD)
coversTasks:
  - "1.4"
sources:
  - title: Understanding Lambda Event Function scaling (공식 문서)
    url: https://docs.aws.amazon.com/lambda/latest/dg/lambda-concurrency.html
  - title: Optimize shuffles — tuning AWS Glue for Apache Spark (공식 문서)
    url: https://docs.aws.amazon.com/prescriptive-guidance/latest/tuning-aws-glue-for-apache-spark/optimize-shuffles.html
  - title: Configuring file system access for Lambda Event Functions (공식 문서)
    url: https://docs.aws.amazon.com/lambda/latest/dg/configuration-filesystem.html
  - title: What is the AWS Serverless Application Model (AWS SAM)? (공식 문서)
    url: https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/what-is-sam.html
  - title: Working with deployment configurations in CodeDeploy (공식 문서)
    url: https://docs.aws.amazon.com/codedeploy/latest/userguide/deployment-configurations.html
  - title: DEA-C01 공식 시험 가이드 도메인 1 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain1.html
lastVerified: 2026-10-19
---

# 프로그래밍 개념 (코드 최적화·Lambda·IaC·CI/CD)

> **커버하는 공식 Task** — DEA-C01 · 도메인 1 「데이터 수집 및 변환」(34%) · **Task 1.4 프로그래밍 개념 적용** (`dea-t1-4`)
> Skill이 **11개**로 도메인 1에서 가장 넓습니다. 공식 가이드는 **언어 중립적 개념과 SQL**을 요구하고 **언어별 구문 시연은 범위 밖**으로 못박았으니, 구문 암기가 아니라 "어떤 서비스에서 무엇을 어떻게 설정하는가"로 읽어야 합니다.
> **Skill 1.4.8은 v1.1에서 개정**됐습니다(v1.0의 지식 항목이 Skill로 승격 — CloudFormation·CDK 예시).

---

## ✅ 학습 목표 체크리스트

- [ ] 런타임을 줄이는 **세 방향**(읽는 양 ↓ · 셔플 ↓ · 재사용)을 서비스별 설정으로 연결한다
- [ ] Lambda의 **메모리=CPU** 관계와 **동시성 한도 3종**을 구분한다
- [ ] **예약 동시성 vs 프로비저닝 동시성 vs 기본**을 목적별로 고른다
- [ ] **SQS·Kinesis 이벤트 소스 스케일링**(최대 동시성·ParallelizationFactor)을 설정한다
- [ ] **CloudFormation·CDK·SAM**의 관계와 각 도구의 고유 기능을 설명한다
- [ ] Lambda의 **파일 저장소 3종**(`/tmp`·EFS·S3 Files)과 택일 규칙을 안다
- [ ] **CI/CD 3단**(CodePipeline·CodeBuild·CodeDeploy)과 Lambda 트래픽 전환 방식을 구분한다
- [ ] **분산 컴퓨팅**(MapReduce·Spark 드라이버/익스큐터·셔플·지연 평가)을 설명한다
- [ ] **그래프·트리** 데이터가 AWS에서 어디에 나타나는지(Neptune·재귀 CTE·인접 리스트) 안다

---

## 🎯 왜 중요한가

- 1.4는 "코드"를 묻지만 실제로는 **설정값과 한도**를 묻습니다. Lambda 동시성처럼 **세 가지 다른 한도**가 섞이는 주제가 가장 자주 틀립니다.
- 성능 문항은 **증상 → 처방** 매핑입니다. 작은 파일·셔플·스큐는 처방이 다릅니다(§1).
- IaC·CI/CD는 데이터 파이프라인을 **반복 가능하게** 만드는 축이라, v1.1에서 Skill로 승격될 만큼 비중이 올라갔습니다.

---

## 🔤 먼저 알아야 할 용어

| 용어 | 영문 | 한 줄 풀이 |
|---|---|---|
| **푸시다운** | pushdown | 필터를 소스 가까이로 내려 **읽는 양 자체**를 줄이는 기법 |
| **셔플** | shuffle | 파티션 사이로 데이터를 재분배하는 비싼 단계(조인·groupBy에서 발생) |
| **브로드캐스트 조인** | broadcast join | 작은 쪽 테이블을 모든 익스큐터에 복사해 **셔플 없이** 조인 |
| **콜드 스타트** | cold start | 새 실행 환경을 초기화하는 데 걸리는 추가 지연 |
| **ESM** | event source mapping | Lambda가 SQS·Kinesis 등에서 레코드를 읽어 호출하게 하는 매핑 |
| **스택** | stack | CloudFormation이 한 단위로 만들고 갱신·삭제하는 리소스 모음 |
| **construct** | — | CDK의 구성 요소. L1(1:1) · L2(의도 기반) · L3(패턴) |
| **지연 평가** | lazy evaluation | Spark 변환이 **액션을 호출할 때** 실제로 실행되는 성질 |

---

## 📖 핵심 개념

### 1) 코드 최적화 — 증상에서 처방으로 {#code-optimization}

| 증상 | 처방 | 서비스 |
|---|---|---|
| 작은 S3 파일 수만 개, 드라이버 메모리 부족·느림 | **`groupFiles=inPartition`**(+`groupSize`) — 입력 5만 개 초과 시 Glue가 자동 적용 | Glue |
| 특정 파티션만 필요한데 전체를 읽음 | **`push_down_predicate`** · 파티션이 수백만이면 **파티션 인덱스 + `catalogPartitionPredicate`**(서버 측 프루닝) · JDBC는 `sampleQuery` | Glue |
| 큰 테이블 조인이 느리고 셔플이 큼 | 조인 전 **행·열 제거** → 작은 쪽이 메모리에 들어가면 **브로드캐스트 해시 조인** · 같은 키로 자주 조인하면 **버킷팅** · 반복 사용 DataFrame은 `cache()` | Glue·EMR(Spark) |
| 소수 태스크만 매우 오래 걸림(스큐) | **AQE**(Glue 4.0+ 기본 활성: 파티션 병합·조인 전환·스큐 조인 분할) · **카디널리티 높은 키/복합 키** | Glue·EMR(Spark) |
| Athena가 너무 많이 스캔함 | **파티션 키 설계**(너무 많으면 작은 파일 조각, 없으면 과다 스캔) + 컬럼너·정렬 | Athena |
| Redshift 적재가 느림 | **여러 파일을 한 COPY**로 병렬 적재, 크기 1 MB~1 GB·개수는 슬라이스 수의 배수(Serverless는 **128의 배수**) | Redshift |
| 호출마다 연결·클라이언트를 새로 만듦 | SDK 클라이언트·DB 연결을 **핸들러 밖**에서 초기화, 정적 자산은 `/tmp` 캐시, **keep-alive** | Lambda |

> 🧠 원리: 왜 "DynamicFrame 조인 대신 DataFrame·Spark SQL"이 성능 조언이 될까요?
> Spark SQL과 DataFrame은 Catalyst 옵티마이저의 최적화 대상이라 조인 순서 변경·필터 푸시다운·브로드캐스트 전환 같은 재작성을 엔진이 자동으로 해 줍니다.
> DynamicFrame은 스키마가 유연한 대신 그 최적화 경로를 일부 비켜가므로, 스키마가 안정된 구간에서는 DataFrame으로 바꿔 엔진의 최적화를 받는 편이 빠릅니다.

### 2) Lambda 동시성·성능 {#lambda-concurrency}

- **메모리 = CPU**: 메모리는 **128~10,240 MB**(1 MB 단위)이고 CPU는 메모리에 비례합니다(**1,769 MB에서 1 vCPU**). 별도 CPU 설정은 없습니다. 한 번의 호출은 **최대 15분**입니다.
- **동시성 계산**: `동시성 = 평균 초당 요청 수 × 평균 처리 시간(초)`. 처리 시간을 줄이면 필요한 동시성도 줄어듭니다.
- **섞이기 쉬운 한도 3종**
  1. **계정 동시 실행** 기본 **1,000**(리전별, 증설 요청 가능)
  2. **함수별 스케일링 속도**: **10초마다 실행 환경 최대 1,000개** 추가
  3. **초당 요청 한도**: 동시성 쿼터의 **10배**(기본 계정이면 초당 10,000건)

| 구분 | 예약 동시성(Reserved) | 프로비저닝 동시성(Provisioned) | 설정 안 함 |
|---|---|---|---|
| 의미 | 그 함수의 **전용 몫**(최대·최소) | **미리 초기화된** 실행 환경 수 | 계정 풀(1,000) 공유 |
| 콜드 스타트 | 있음 | **없음** | 있음 |
| 요금 | **추가 요금 없음** | 추가 요금 | 없음 |
| 시험 단서 | "다른 함수 때문에 스로틀링", "DB 연결 보호용 상한" | "콜드 스타트 지연 감소" | — |

> 함수별 예약은 기본 **900까지**이며 **100은 예약 없는 함수 몫으로 항상 남습니다.** 예약 동시성을 **0**으로 두면 의도적으로 모든 호출을 스로틀링할 수 있습니다.
> **SnapStart**는 콜드 스타트를 줄이는 다른 방법으로 **Java 11+·Python 3.12+·.NET 8+ 의 발행된 버전**에만 적용되며(미발행 `$LATEST` 불가), **프로비저닝 동시성·EFS·S3 Files와 함께 쓸 수 없습니다.**

### 3) 이벤트 소스 스케일링 — SQS·Kinesis {#esm-scaling}

- **SQS 표준 큐**: 동시 호출 **5개로 시작**해 **분당 최대 300개**씩 늘리며 **ESM당 최대 1,250개** 동시 호출까지 갑니다. 한 큐가 계정 동시성을 독점하지 못하게 하려면 ESM의 **maximum concurrency(2~1,000)** 를 설정합니다. 이 값은 함수 예약 동시성과 **별개**라, 예약 동시성이 모든 SQS 소스의 최대 동시성 합 이상이어야 스로틀링을 피합니다. 더 높은 처리량은 **provisioned mode**(최대 100,000 동시 호출, 추가 비용)이며 maximum concurrency와 **함께 쓸 수 없습니다**.
- **SQS FIFO**: 메시지 그룹 단위로 순서를 지키며, 동시 호출은 **메시지 그룹 ID 수와 maximum concurrency 중 낮은 값**으로 제한됩니다.
- **Kinesis**: **샤드당 한 번에 한 배치**를 순서대로 처리합니다. 처리량을 올리려면 **샤드를 늘리거나 `ParallelizationFactor`(1~10, 기본 1)** 로 샤드당 동시 배치를 늘립니다(파티션 키 단위 순서는 유지). 호출 시점은 **배치가 차거나 · 배칭 윈도우 만료 · 페이로드 6 MB 도달** 중 하나입니다.

### 4) 언어·프레임워크 {#languages}

| 서비스 | 쓸 수 있는 언어 |
|---|---|
| **AWS Glue(Spark ETL)** | **Python(PySpark) · Scala** |
| **Amazon EMR(Spark)** | **Scala · Python · Java** 네이티브 |
| **AWS Lambda** | 관리형 런타임 **Node.js · Python · Java · .NET(C#) · Ruby**, 그 밖(Go·Rust 등)은 **사용자 지정 런타임**. **PowerShell**은 AWSLambdaPSCore 모듈로, **Bash**는 사용자 지정 런타임 `bootstrap`으로 |
| **Athena·Redshift** | **SQL** |
| **AWS CDK** | TypeScript · JavaScript · Python · Java · C#/.NET · Go |

> 공식 가이드가 **언어별 구문 시연을 범위 밖**으로 명시했으므로, "이 코드의 출력은?" 같은 문제보다 **"이 서비스에서 이 언어를 쓸 수 있나"** 를 가르는 문제로 나옵니다.

### 5) 소프트웨어 공학 모범 사례 {#engineering-practices}

- **버전 관리(Git)**: 메인 저장소를 직접 고치지 않고 **작업 브랜치**에서 작업합니다. 원격을 로컬로 가져오는 것이 **clone**, 브랜치 전환이 **checkout**, 저장이 **commit**, 공유가 **push**이며 병합 충돌은 개발자가 해결합니다. IaC 구성도 **소스 관리 시스템에 저장**하는 것이 공식 권고입니다.
- **테스트**: Glue 잡은 **AWS 제공 Docker 이미지로 로컬 개발·테스트**합니다. Lambda는 **핸들러와 핵심 로직을 분리**해야 단위 테스트가 쉽고, 배포 파이프라인에는 **CodeBuild 기반 자동 테스트 단계**를 둡니다.
- **로깅·모니터링**: Lambda는 **JSON 구조화 로그**를 지원하며 **로그 레벨 필터링을 쓰려면 JSON 형식**이어야 합니다. **Powertools for AWS Lambda**가 구조화 로깅·EMF 메트릭·분산 트레이싱을 제공하고, 관측은 **CloudWatch + X-Ray**로 구성합니다.

### 6) IaC — CloudFormation과 CDK {#iac}

| 도구 | 정의 방식 | 고유 기능 | 배포 경로 |
|---|---|---|---|
| **CloudFormation** | 선언형 템플릿, **스택** 단위 | **변경 세트**(미리보기 후 실행) vs 직접 업데이트 · **드리프트 감지** · **StackSets**(여러 계정·리전) · 실패 시 **롤백** | 자체 |
| **AWS CDK** | 범용 프로그래밍 언어 | **construct L1/L2/L3** · `cdk synth`(클라우드 어셈블리 생성) · **환경마다 `cdk bootstrap`**(CDKToolkit 스택: S3·ECR) | CloudFormation |
| **AWS SAM** | CloudFormation 확장 약식 문법 | 서버리스 전용 · `Transform` · `sam local`·`sam sync` | CloudFormation |

- **드리프트 감지**: CloudFormation **밖에서 바뀐 구성**을 찾아 줍니다. 지원하지 않는 리소스는 **NOT_CHECKED**로 표시됩니다.
- **construct 3단**: **L1** = `Cfn` 접두어, CloudFormation 리소스와 1:1 / **L2** = 의도 기반 API + 기본값·보안 모범 설정 / **L3** = 여러 리소스를 묶은 패턴.

### 7) SAM — 서버리스 파이프라인 패키징·배포 {#sam}

- 템플릿 최상위에 **`Transform: AWS::Serverless-2016-10-31`** 을 선언하면 CloudFormation이 SAM 문법을 일반 CloudFormation으로 변환합니다.
- 주요 리소스: **`AWS::Serverless::Function`** · **`AWS::Serverless::StateMachine`** · **`AWS::Serverless::SimpleTable`**(단일 속성 기본 키 DynamoDB 테이블 — 복잡한 키는 `AWS::DynamoDB::Table`).
- CLI 흐름: **`sam build` → `sam deploy`**. **`sam sync`** 는 로컬 변경을 빠르게 반영하는 **개발용**이고, 운영에는 `sam deploy`나 CI/CD를 씁니다.
- **점진 배포**: 함수에 **`AutoPublishAlias`** 와 **`DeploymentPreference`**(전환 유형·경보·사전/사후 검증 함수)를 두면 **CodeDeploy**가 새 버전으로 트래픽을 점진 전환하고 **CloudWatch 경보 발생 시 자동 롤백**합니다.
- **선호 기준**: 선언적 접근은 **SAM**, 프로그래밍 방식은 **CDK**.

### 8) Lambda 파일 저장소 3종 {#lambda-storage}

| 구분 | 성격 | 요건 | 특성 |
|---|---|---|---|
| **`/tmp`** | 실행 환경별 **임시** 스토리지 | 추가 인프라 없음 | **512~10,240 MB** |
| **Amazon EFS** | 공유 NFS 파일 시스템 | VPC · **AZ마다 마운트 타깃** · 액세스 포인트 · **NFS 2049 허용** · 마운트 경로 **`/mnt/`** | 성능 모드는 **생성 후 변경 불가** |
| **Amazon S3 Files** | S3 버킷을 **파일처럼** 노출 | 같은 요건(액세스 포인트 없으면 **자동 생성**) | **버킷 버저닝 필수**, 충돌 시 S3 버킷이 기준, 메모리 512 MB 이상이면 direct read 기본 |

> **택일 규칙**: 한 함수는 **EFS 또는 S3 Files 중 하나만** 씁니다. 그리고 **SnapStart는 두 파일 시스템 모두와 호환되지 않습니다.**

### 9) CI/CD {#cicd}

- **용어**: **CI** = 변경을 자주 병합하고 자동 빌드·테스트 / **지속적 전달** = 배포 가능한 상태까지 준비(수동 승인 가능) / **지속적 배포** = 승인 없이 운영까지 자동.
- **CodePipeline**: 파이프라인 = **스테이지의 연속**, 스테이지 = 직렬·병렬 **액션**. 액션 유형은 source·build·test·deploy·**approval**·invoke.
- **CodeBuild**: **`buildspec`(YAML)** 이 빌드 명령·설정을 정의하고 단계는 **install → pre_build → build → post_build**.
- **CodeDeploy(Lambda)**: 트래픽 전환은 **canary · linear · all-at-once** 중 선택(Lambda·ECS 배포는 모두 blue/green). canary는 일부를 먼저, linear는 일정 간격마다 같은 비율씩, all-at-once는 한 번에.
- **소스 저장소**: 외부 Git(GitHub·GitLab·Bitbucket 등)은 **CodeConnections 기반 소스 액션**으로 연결합니다. 시험 범위상 **v1.1 in-scope 목록에서 CodeCommit이 제거**됐고, Developer Tools 항목은 CLI·CloudFormation·CDK·CodeBuild·CodeDeploy·CodePipeline·Amazon Q입니다(목록은 비포괄적).
- **데이터 파이프라인 패턴**(Glue 예시): ① 소스 관리(ETL 코드 + CloudFormation 템플릿) → ② **LiveTest**(템플릿으로 리소스 배포 → CodeBuild로 크롤러·잡 실행·검증 → 필요 시 수동 승인 → 테스트 리소스 정리) → ③ 운영 배포.

### 10) 분산 컴퓨팅 {#distributed}

- **MapReduce**: 작업을 여러 노드에 **매핑**해 병렬 처리하고 출력을 단일 노드에서 **리듀스**합니다. EMR의 Hadoop이 이 알고리즘을 구현합니다.
- **EMR 노드 역할**: **프라이머리(마스터)** = 클러스터 관리·태스크 분배 조율 / **코어** = 태스크 실행 + **HDFS 저장** / **태스크** = 태스크만 실행(HDFS 없음, 선택).
- **Spark**: **드라이버**가 애플리케이션을 태스크로 쪼개 실행 계획·스케줄링을 맡고, **익스큐터**가 데이터를 보유하며 태스크를 실행합니다. 데이터는 **RDD 파티션**으로 나뉘고 **태스크는 파티션마다** 만들어집니다.
- **셔플·지연 평가·내결함성**: 셔플은 파티션 간 재분배로 비쌉니다. 변환은 **지연 평가**되어 **액션** 호출 시 실행됩니다. **RDD는 불변이며 복제**되어 노드 장애에서 자동 복구됩니다.

### 11) 그래프·트리 데이터 {#graph-tree}

- **그래프**: 노드(엔티티)·엣지(관계)·속성으로 표현합니다. **Amazon Neptune**은 관계를 데이터 모델의 일급 요소로 저장해 순회가 빠르며 소셜·추천·사기 탐지에 쓰입니다. **Neptune Analytics**는 경로 탐색(BFS)·중심성(PageRank)·유사도·커뮤니티 탐지 알고리즘을 내장합니다. 그래프 DB 없이도 **DynamoDB는 인접 리스트 패턴**(파티션 키=노드, 정렬 키=대상 노드)으로 다대다를 모델링합니다.
- **트리**: **B-tree 인덱스**는 정렬 데이터를 유지하는 자기 균형 트리로 동등·범위 질의를 처리합니다(PostgreSQL 기본 인덱스). 조직도·BOM 같은 **계층 데이터는 Redshift 재귀 CTE**로 질의하며, **무한 재귀를 막으려면 재귀 깊이를 WHERE로 제한**해야 합니다.

---

## ✍️ 시험 포인트

- Lambda 한도 구분: **계정 동시성 1,000** / **10초마다 +1,000 환경** / **초당 요청 = 동시성 × 10**. 셋을 섞지 마세요.
- "다른 함수 때문에 스로틀링" → **예약 동시성**(무료). "콜드 스타트" → **프로비저닝 동시성**(유료) 또는 **SnapStart**(런타임·발행 버전 제약).
- SQS ESM: 시작 **5** → 분당 **+300** → 최대 **1,250**. 독점 방지는 **maximum concurrency(2~1,000)**, 초고처리량은 **provisioned mode**(둘은 동시 사용 불가).
- Kinesis 처리량: **샤드 증설** 또는 **ParallelizationFactor 1~10**. 호출 트리거는 배치 충족·윈도 만료·**6 MB**.
- `/tmp` **512~10,240 MB** · EFS/S3 Files는 **둘 중 하나만** · **SnapStart와 파일 시스템 비호환**.
- IaC: **변경 세트**=미리보기, **드리프트 감지**=외부 변경 탐지(미지원 리소스는 NOT_CHECKED), **StackSets**=여러 계정·리전, **`cdk bootstrap`** =환경 준비.
- SAM: `Transform: AWS::Serverless-2016-10-31` · `SimpleTable`은 **단일 속성 기본 키** · 점진 배포는 **AutoPublishAlias + DeploymentPreference**.
- CodeDeploy Lambda 전환: **canary / linear / all-at-once**.
- Spark: 변환은 **지연 평가**, 태스크는 **파티션마다**, 코어 노드만 **HDFS**.
- 계층 질의는 **재귀 CTE + 깊이 제한**.

---

## ⚠️ 흔한 함정 {#pitfalls}

1. **"예약 동시성을 올리면 콜드 스타트가 줄어든다."** → ❌. 예약은 **전용 몫 지정**이고 콜드 스타트 제거는 **프로비저닝 동시성**(또는 SnapStart)입니다.
2. **"SnapStart를 켜면 어떤 함수든 빨라진다."** → ❌. **Java 11+·Python 3.12+·.NET 8+ 의 발행된 버전**만 가능하고, **프로비저닝 동시성·EFS·S3 Files와 함께 쓸 수 없습니다.**
3. **"ESM maximum concurrency만 올리면 처리량이 올라간다."** → ⚠️ **함수 예약 동시성이 모든 SQS 소스의 최대 동시성 합 이상**이어야 스로틀링을 피합니다. 두 설정은 별개입니다.
4. **"Kinesis는 소비자를 늘리면 샤드당 처리량이 늘어난다."** → ❌. 샤드당 한 번에 한 배치가 순서대로 처리되므로 **샤드 증설 또는 ParallelizationFactor**가 답입니다.
5. **"Lambda에 CPU를 따로 할당한다."** → ❌. CPU는 **메모리에 비례**해 배분됩니다(1,769 MB에서 1 vCPU).
6. **"EFS와 S3 Files를 함께 마운트해 쓰면 된다."** → ❌. 한 함수는 **둘 중 하나만** 씁니다.
7. **"드리프트 감지는 모든 리소스를 검사한다."** → ❌. 지원하지 않는 리소스는 **NOT_CHECKED**입니다.
8. **"CDK는 CloudFormation을 대체한다."** → ❌. CDK는 코드로 정의한 뒤 **CloudFormation으로 프로비저닝**합니다(`cdk synth` → 템플릿).
9. **"`sam sync`를 운영 배포에 쓰면 편하다."** → ❌. `sam sync`는 **개발용**이고 운영에는 `sam deploy`나 CI/CD를 권장합니다.
10. **"Glue 북마크처럼 스트리밍도 북마크로 위치를 추적한다."** → ❌(1.2와 교차): 스트리밍은 **체크포인트**입니다.
11. **"재귀 CTE는 알아서 종료된다."** → ❌. **재귀 깊이를 WHERE로 제한**하지 않으면 무한 재귀 위험이 있습니다.

---

## 🧪 자가 점검

> 학습용 자가 점검입니다. (문항 뱅크 `dea-t1-4.questions.json` — 사람 검수 전이라 사이트 비노출)

**Q1.** 한 Lambda 함수가 트래픽을 몰아 쓰면서 같은 계정의 다른 함수들이 스로틀링된다. 추가 비용 없이 막는 방법은?

<details><summary>정답 보기</summary>

**예약 동시성(Reserved concurrency)** 을 그 함수에 설정합니다. 함수의 동시 인스턴스 상한이 되어 계정 풀을 독점하지 못하게 하고 추가 요금이 없습니다(다운스트림 DB 연결 보호용 상한으로도 씁니다). 콜드 스타트 제거가 목적이라면 그때는 프로비저닝 동시성입니다.
</details>

**Q2.** Glue 잡이 S3의 작은 파일 수만 개를 읽다가 드라이버 메모리 부족으로 느려진다. 처방은?

<details><summary>정답 보기</summary>

**파일 그룹화**(`groupFiles=inPartition`, 필요하면 `groupSize`)를 씁니다. 각 태스크가 파일 묶음을 하나의 인메모리 파티션으로 읽어 태스크 폭증을 막습니다. 입력이 50,000개를 넘으면 Glue가 자동으로 켭니다.
</details>

**Q3.** SQS 표준 큐를 소스로 하는 Lambda의 동시 호출이 예상보다 낮게 유지된다. 확인할 설정 두 가지는?

<details><summary>정답 보기</summary>

**① ESM의 maximum concurrency**(2~1,000) **② 함수의 예약 동시성**입니다. 두 설정은 별개이며, 예약 동시성이 모든 SQS 소스의 최대 동시성 합보다 작으면 스로틀링이 발생합니다. 참고로 표준 큐는 동시 호출 5로 시작해 분당 300개씩 ESM당 1,250까지 늘어납니다.
</details>

**Q4.** 운영 스택에 누군가 콘솔에서 직접 변경을 가했는지 확인하려면 CloudFormation의 어떤 기능을 쓰나요?

<details><summary>정답 보기</summary>

**드리프트 감지(drift detection)** 입니다. CloudFormation 밖에서 변경된 구성을 찾아 줍니다. 단, 드리프트 감지를 지원하지 않는 리소스는 `NOT_CHECKED`로 보고되므로 전수 보장은 아닙니다. 배포 전 변경 영향을 미리 보려면 **변경 세트**를 씁니다.
</details>

**Q5.** SAM으로 배포한 Lambda를 새 버전으로 **일부 트래픽부터** 전환하고, 문제가 생기면 자동 롤백하려 한다. 무엇을 설정하나요?

<details><summary>정답 보기</summary>

함수에 **`AutoPublishAlias`** 와 **`DeploymentPreference`**(canary 또는 linear 전환 유형, CloudWatch 경보, 사전·사후 트래픽 검증 함수)를 설정합니다. SAM이 CodeDeploy와 연동해 점진 전환하고 경보가 울리면 자동 롤백합니다.
</details>

---

**Q6 (원리).** 왜 Lambda에서 "메모리를 올리는 것"이 때로 비용을 **낮추는** 선택이 될 수 있나요?

<details><summary>정답 보기</summary>

**CPU가 메모리에 비례해 배분되기 때문입니다.** 메모리를 올리면 단위 시간당 단가는 오르지만 CPU가 늘어 실행 시간이 짧아질 수 있고, Lambda 과금은 (메모리 × 실행 시간)에 비례하므로 총액이 줄어들 수 있습니다. 또 동시성 = RPS × 처리 시간이므로 실행 시간이 짧아지면 필요한 동시성까지 줄어 스로틀링 위험도 함께 내려갑니다.
</details>

---

### 📌 출처

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. (수집·대조: 2026-10-17 · 저작: 2026-10-19 · 사람 검수 전)

1. Reading input files in larger groups (AWS Glue) — https://docs.aws.amazon.com/glue/latest/dg/grouping-input-files.html
2. Optimizing reads with pushdown in AWS Glue ETL — https://docs.aws.amazon.com/glue/latest/dg/aws-glue-programming-pushdown.html
3. Optimize shuffles (tuning AWS Glue for Apache Spark) — https://docs.aws.amazon.com/prescriptive-guidance/latest/tuning-aws-glue-for-apache-spark/optimize-shuffles.html
4. Key topics in Apache Spark (tuning AWS Glue for Apache Spark) — https://docs.aws.amazon.com/prescriptive-guidance/latest/tuning-aws-glue-for-apache-spark/key-topics-apache-spark.html
5. Optimize data (Amazon Athena performance tuning) — https://docs.aws.amazon.com/athena/latest/ug/performance-tuning-data-optimization-techniques.html
6. Load data from S3 into Amazon Redshift — https://repost.aws/knowledge-center/redshift-load-s3-data
7. Define Lambda Event Function handler in Python — https://docs.aws.amazon.com/lambda/latest/dg/python-handler.html
8. Lambda quotas — https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-limits.html
9. Understanding Lambda Event Function scaling — https://docs.aws.amazon.com/lambda/latest/dg/lambda-concurrency.html
10. Configuring reserved concurrency for an Event Function — https://docs.aws.amazon.com/lambda/latest/dg/configuration-concurrency.html
11. Configure Lambda Event Function memory — https://docs.aws.amazon.com/lambda/latest/dg/configuration-memory.html
12. Improving startup performance with Lambda SnapStart — https://docs.aws.amazon.com/lambda/latest/dg/snapstart.html
13. Configuring scaling behavior for SQS event source mappings — https://docs.aws.amazon.com/lambda/latest/dg/services-sqs-scaling.html
14. Using Lambda to process records from Amazon Kinesis Data Streams — https://docs.aws.amazon.com/lambda/latest/dg/with-kinesis.html
15. Lambda Event Function runtimes — https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtimes.html
16. Develop and test AWS Glue jobs locally using a Docker image — https://docs.aws.amazon.com/glue/latest/dg/develop-local-docker-image.html
17. Log and monitor Python Lambda Event Functions — https://docs.aws.amazon.com/lambda/latest/dg/python-logging.html
18. Managing AWS resources as a single unit with CloudFormation stacks — https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/stacks.html
19. Detect unmanaged configuration changes with drift detection — https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-stack-drift.html
20. Managing stacks across accounts and Regions with StackSets — https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/what-is-cfnstacksets.html
21. What is the AWS CDK? — https://docs.aws.amazon.com/cdk/v2/guide/home.html
22. AWS CDK Constructs — https://docs.aws.amazon.com/cdk/v2/guide/constructs.html
23. What is the AWS Serverless Application Model (AWS SAM)? — https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/what-is-sam.html
24. AWS::Serverless transform — https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/transform-aws-serverless.html
25. AWS SAM resources and properties — https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/sam-specification-resources-and-properties.html
26. Deploying serverless applications gradually with AWS SAM — https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/automating-updates-to-serverless-apps.html
27. Configure ephemeral storage for Lambda Event Functions — https://docs.aws.amazon.com/lambda/latest/dg/configuration-ephemeral-storage.html
28. Configuring file system access for Lambda Event Functions — https://docs.aws.amazon.com/lambda/latest/dg/configuration-filesystem.html
29. Configuring Amazon EFS file system access (Lambda) — https://docs.aws.amazon.com/lambda/latest/dg/configuration-filesystem-efs.html
30. Configuring Amazon S3 Files access (Lambda) — https://docs.aws.amazon.com/lambda/latest/dg/configuration-filesystem-s3files.html
31. CodePipeline concepts — https://docs.aws.amazon.com/codepipeline/latest/userguide/concepts.html
32. Getting started with CodeBuild — https://docs.aws.amazon.com/codebuild/latest/userguide/getting-started-overview.html
33. Working with deployment configurations in CodeDeploy — https://docs.aws.amazon.com/codedeploy/latest/userguide/deployment-configurations.html
34. CodeStarSourceConnection source action (CodePipeline) — https://docs.aws.amazon.com/codepipeline/latest/userguide/action-reference-CodestarConnectionSource.html
35. Implement CI/CD of serverless AWS Glue ETL applications — https://aws.amazon.com/blogs/big-data/implement-continuous-integration-and-delivery-of-serverless-aws-glue-etl-applications-using-aws-developer-tools/
36. Amazon EMR FAQs — https://aws.amazon.com/emr/faqs/
37. Processing DynamoDB data with Apache Hive on Amazon EMR — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/EMRforDynamoDB.html
38. Getting Started with Amazon Neptune — https://aws.amazon.com/neptune/getting-started/
39. WITH clause (Amazon Redshift SQL reference) — https://docs.aws.amazon.com/redshift/latest/dg/r_WITH_clause.html
40. DEA-C01 공식 시험 가이드 도메인 1 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain1.html
