---
examGuideTaskId: mla-t3-3
certCode: MLA-C01
domain: 3
domainName: ML 워크플로의 배포 및 오케스트레이션
domainWeightPct: 22
title: CI/CD 파이프라인 설정 (CodePipeline·CodeBuild·CodeDeploy·SageMaker Pipelines·재훈련)
coversTasks:
  - "3.3"
sources:
  - title: Continuous delivery and continuous integration (AWS CodePipeline 공식 문서)
    url: https://docs.aws.amazon.com/codepipeline/latest/userguide/concepts-continuous-delivery-integration.html
  - title: CodePipeline concepts — 파이프라인·스테이지·액션·실행 모드 (공식 문서)
    url: https://docs.aws.amazon.com/codepipeline/latest/userguide/concepts.html
  - title: Buildspec reference (AWS CodeBuild 공식 문서)
    url: https://docs.aws.amazon.com/codebuild/latest/userguide/build-spec-ref.html
  - title: What is CodeDeploy? (공식 문서)
    url: https://docs.aws.amazon.com/codedeploy/latest/userguide/welcome.html
  - title: Deployment configurations on an Amazon ECS compute platform (공식 문서)
    url: https://docs.aws.amazon.com/codedeploy/latest/userguide/deployment-configurations.html
  - title: Amazon SageMaker Pipelines (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/pipelines.html
  - title: Pipeline steps (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/build-and-manage-steps-types.html
  - title: Update the approval status of a model (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/model-registry-approve.html
  - title: Choosing a Git branching strategy (AWS 규범 가이드)
    url: https://docs.aws.amazon.com/prescriptive-guidance/latest/choosing-git-branch-approach/git-branching-strategies.html
  - title: MLOPS04-BP01 Establish MLOps practices (Machine Learning Lens)
    url: https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/mlops04-bp01.html
  - title: MLA-C01 공식 시험 가이드 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-01/machine-learning-engineer-associate-01.html
lastVerified: 2026-10-17
---

# CI/CD 파이프라인 설정 (CodePipeline·CodeBuild·CodeDeploy·SageMaker Pipelines·재훈련)

> **커버하는 공식 Task** — MLA-C01 · 도메인 3 「ML 워크플로의 배포 및 오케스트레이션」(22%) · **Task 3.3 자동화된 오케스트레이션 도구를 사용하여 지속적 통합 및 지속적 전달(CI/CD) 파이프라인 설정** (`mla-t3-3`)
> 이 문서는 위 한 Task에 1:1로 매핑됩니다. 3.1이 "무엇을 고르는가", 3.2가 "어떻게 선언하는가"였다면 3.3은 **"무엇이 그것을 자동으로 돌리는가"** — 커밋에서 프로덕션까지, 그리고 드리프트에서 재훈련까지의 배선입니다.

---

## ✅ 학습 목표 체크리스트

- [ ] CI와 CD의 공식 정의를 구분하고 **ML에서 추가로 추적해야 하는 것**을 말할 수 있다
- [ ] CodePipeline·CodeBuild·CodeDeploy·SageMaker Pipelines의 **역할 분담**을 혼동하지 않는다
- [ ] CodePipeline의 스테이지·액션·전환 구조와 **실행 모드 3종**의 차이를 안다
- [ ] V1과 V2 파이프라인 유형에서 **무엇이 V2에서만 되는지** 안다
- [ ] buildspec의 단계 4종과 `0.1`·`0.2` 버전 차이, 캐시 2종, 테스트 리포트 보존 기간을 안다
- [ ] CodeDeploy의 **컴퓨트 플랫폼 3종**과 플랫폼별 트래픽 이동 구성·AppSpec 형식을 구분한다
- [ ] CodeDeploy의 롤백이 **"이전 리비전의 재배포"**라는 성질을 안다
- [ ] 자주 나오는 실패 증상(Docker 데몬 연결 오류·환경 변수 유실·훅 타임아웃)의 원인을 짚는다
- [ ] 리포지토리 종류별 변경 감지 방식과 **Full clone의 제약**을 안다
- [ ] Trunk·GitHub Flow·Gitflow를 복잡도·팀 규모·릴리스 요구로 가르고 파이프라인 호출 방식에 연결한다
- [ ] SageMaker Pipelines의 DAG가 **무엇으로 결정되는지**와 캐싱·재시도 정책의 조건을 안다
- [ ] 승인 상태 전이 4종이 각각 어떤 동작을 일으키는지 안다
- [ ] 데이터 수집 이벤트를 파이프라인 시작으로 연결하는 경로를 안다
- [ ] SageMaker 가드레일과 CodeDeploy 배포 구성의 **대응 관계**를 안다
- [ ] CI/CD 안의 테스트 종류를 넣을 위치와 품질 게이트 수단에 매핑한다
- [ ] 재훈련 트리거 네 가지를 구성하고 **고정 일정 재훈련이 왜 안티패턴인지** 말한다

---

## 🎯 왜 중요한가

3.3은 도메인 3에서 가장 **도구 이름이 많은** Task입니다. 그래서 암기 과목처럼 보이지만, 실제로 묻는 것은 **"이 일을 누가 하는가"**입니다. 빌드와 단위 테스트는 CodeBuild, 단계 오케스트레이션은 CodePipeline, 컴퓨트 플랫폼 배포는 CodeDeploy, ML 작업의 DAG는 SageMaker Pipelines. 이 네 개가 보기에 함께 등장하고, 역할을 섞으면 틀립니다.

특히 **CodeDeploy는 SageMaker 엔드포인트를 컴퓨트 플랫폼으로 지원하지 않습니다.** 엔드포인트의 canary·linear는 SageMaker 배포 가드레일이 제공합니다. 이름이 같아서 가장 자주 섞이는 지점입니다.

두 번째 축은 **트리거**입니다. ML CI/CD에는 코드 커밋 외에도 신규 데이터 도착, 일정, 드리프트 경보, 모델 승인이라는 네 가지 출발점이 있습니다. 시나리오가 어느 출발점을 말하는지 읽으면 EventBridge 규칙인지 Model Registry 이벤트인지 CodePipeline 소스인지가 정해집니다.

---

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **스테이지 / 액션 / 전환** | CodePipeline의 구조. 스테이지는 환경을 격리하는 논리 단위, 액션은 그 안의 작업, 전환은 다음 스테이지로 넘어가는 지점 |
| **buildspec** | CodeBuild가 읽는 YAML 빌드 명세. 소스 루트의 기본 이름은 `buildspec.yml` |
| **AppSpec** | CodeDeploy가 읽는 배포 명세. 배포를 라이프사이클 이벤트 훅의 연속으로 관리한다 |
| **리비전(revision)** | CodeDeploy가 배포하는 애플리케이션 버전의 단위. 롤백은 이전 리비전의 **재배포**다 |
| **DAG** | 방향성 비순환 그래프. SageMaker 파이프라인의 단계 연결 구조 |
| **데이터 의존성** | 한 단계의 출력 속성을 다른 단계의 입력으로 넘기는 관계. Pipelines의 DAG는 이것으로 결정된다 |
| **baseline(기준선)** | 데이터·모델 품질과 편향의 기준 통계. 드리프트 검사는 이것과 비교한다 |
| **게이트** | 다음 단계로 넘어가기 전에 통과해야 하는 조건(수동 승인·조건 단계·스테이지 조건) |

---

## 📖 핵심 개념

### 1) CI/CD 원칙과 ML 적용 {#cicd-principles}

**공식 정의**

- **지속적 통합(CI)** — 팀이 버전 관리 시스템을 쓰며 같은 위치(예: `main` 브랜치)에 작업을 **자주 통합**하고, 각 변경을 빌드·검증해 통합 오류를 최대한 빨리 찾는 개발 관행. 초점은 **코드의 자동 빌드·테스트**입니다.
- **지속적 전달(CD)** — 릴리스 프로세스를 자동화하는 방법론. 모든 변경이 자동으로 빌드·테스트·배포되며, 프로덕션 최종 푸시 직전에 사람·자동 테스트·비즈니스 규칙이 시점을 결정합니다. **성공한 변경을 즉시 릴리스할 수 있다는 뜻이고, 모든 변경을 바로 릴리스해야 한다는 뜻은 아닙니다.**
- AWS 규범 가이드는 CI/CD 파이프라인이 sandbox·development·testing·staging·production 환경을 모두 포괄한다고 적고, **브랜치 전략이 복잡할수록 파이프라인도 복잡해지고 CI/CD의 중요성도 커진다**고 설명합니다.

**ML에서 달라지는 점** — ML용 CI/CD는 코드 변경만이 아니라 **데이터·모델 파라미터·훈련 구성**을 함께 추적해야 합니다. ML Lens(MLOPS04-BP01)가 제시하는 구성 요소는 다음 순서입니다: IaC/CaC로 환경 일관성 확보 → 코드·구성·인프라 정의·**모델 아티팩트의 버전 관리** → 오케스트레이션 도구 선택 → CodePipeline으로 빌드·테스트·배포 자동화(스테이징 → 프로덕션, 승인 게이트, Model Registry 연동) → 모니터링 → 품질 임계 미달 시 자동 롤백.

**ML CI/CD의 세 루프** (이 문서의 정리)

| 루프 | 시작시키는 것 | 주 도구 | 산출물·게이트 |
|---|---|---|---|
| **코드 루프(CI)** | 커밋·풀 리퀘스트·병합 같은 리포지토리 이벤트 | CodePipeline(source) → CodeBuild(build·test) | 테스트 리포트, 빌드 아티팩트 |
| **모델 루프(ML 파이프라인)** | 코드 변경·신규 데이터·일정·드리프트 경보 | SageMaker Pipelines(전처리 → 훈련 → 평가 → 조건 → 등록) | Model Registry의 모델 버전과 승인 상태 |
| **배포 루프(CD)** | **모델 버전 승인** | CodePipeline + CloudFormation / SageMaker 배포 가드레일 / CodeDeploy | 스테이징 → 수동 승인 → 프로덕션, 경보 기반 롤백 |

> 🧠 원리: SageMaker Projects 템플릿이 이 세 루프를 하나로 묶습니다. CodePipeline(또는 Jenkins)이 코드가 체크인될 때마다 SageMaker 파이프라인을 실행하고, 그 파이프라인이 만든 모델 버전을 승인하면 배포 파이프라인이 그 버전을 엔드포인트에 올립니다.

### 2) 개발자 도구 3종의 역할 분담 {#devtools-roles}

| 서비스 | 공식 정의(한 줄) | 파이프라인 안에서의 위치 |
|---|---|---|
| **AWS CodePipeline** | 소프트웨어 변경이 릴리스를 거치는 단계를 모델링·시각화·자동화하는 **지속적 전달 서비스** | 오케스트레이터. 스테이지 안에 액션을 둔다 |
| **AWS CodeBuild** | 완전관리형 **빌드 서비스**. 소스 컴파일, 단위 테스트 실행, 배포 가능한 아티팩트 생성 | 파이프라인의 build 또는 test 액션 |
| **AWS CodeDeploy** | **EC2 인스턴스·온프레미스 인스턴스·Lambda 함수·ECS 서비스**에 대한 배포 자동화 | 파이프라인의 deploy 액션 |
| **Amazon SageMaker Pipelines** | ML 개발 자동화를 위한 **목적 특화 워크플로 오케스트레이션 서비스** | ML 단계(전처리·훈련·평가·등록) 실행 |

⚠️ **CodeDeploy의 컴퓨트 플랫폼 3종에 SageMaker 엔드포인트는 없습니다.** 엔드포인트의 점진 배포는 SageMaker 배포 가드레일이 담당합니다(→ 12)).

**CodePipeline 액션 유형 6종과 대표 제공자**

| 액션 유형 | 대표 제공자 |
|---|---|
| **source** | CodeCommit, Amazon S3, Amazon ECR, 연결(Bitbucket Cloud·GitHub·GitHub Enterprise Server·GitLab.com·GitLab self-managed) |
| **build** | CodeBuild, Jenkins, CloudBees, TeamCity, ECR build and publish |
| **test** | CodeBuild, AWS Device Farm 등 |
| **deploy** | CodeDeploy, CloudFormation(StackSets 포함), Amazon ECS, Amazon S3, EKS, Elastic Beanstalk 등 |
| **approval** | 수동 승인(Amazon SNS 통합) |
| **invoke** | AWS Lambda, AWS Step Functions, Amazon Inspector |

> 이 통합 목록에서 SageMaker 전용 액션 제공자는 보이지 않았습니다. 다만 **목록에 없다는 사실 자체를 공식 문장으로 인용할 수는 없으므로** "전용 액션이 없다"고 단정하지 않습니다. 문서가 실제로 적는 연결 방식은, **SageMaker Projects의 모델 구축 템플릿이 CodeBuild 단계에서 SageMaker 파이프라인을 만들고 갱신한 뒤 실행을 시작해 완료까지 기다리는** 구조입니다(→ 10)).

### 3) AWS CodePipeline — 구조·유형·트리거·실행 모드 {#codepipeline}

**구조**

- **파이프라인**은 여러 **스테이지**로 이뤄집니다. 스테이지는 환경을 격리하고 동시에 들어오는 변경 수를 제한하는 논리 단위이며, 스테이지 안의 **액션**은 `runOrder`로 직렬 또는 병렬 실행됩니다.
- **전환(transition)**은 실행이 다음 스테이지로 넘어가는 지점입니다. 스테이지의 inbound transition을 비활성화하면 실행이 진입하지 못하고, 비활성 전환에 여러 실행이 쌓이면 **다시 켰을 때 가장 최근 실행만** 진행합니다.
- 액션끼리는 **파이프라인 아티팩트 버킷**을 통해 산출물을 넘깁니다.
- 실행이 실패하면 파이프라인은 끝까지 가지 못하고 멈춥니다. 실패한 실행은 재시도할 수 있고 **실패한 스테이지는 이전 성공 실행으로 롤백**할 수 있습니다.

> 🧠 원리: 스테이지는 한 번에 하나의 실행만 처리하도록 잠깁니다. 그래서 같은 스테이지 앞에서 기다리는 실행의 운명이 **실행 모드**로 갈립니다.

**실행 모드 3종**

| 모드 | 동작 |
|---|---|
| `SUPERSEDED`(**기본**) | 더 최근에 시작한 실행이 앞선 실행을 **추월**할 수 있고, 추월당한 실행은 `SUPERSEDED`로 멈춘다 |
| `QUEUED` | 실행이 대기하며 먼저 시작한 실행을 추월하지 않고 **순서대로** 처리된다 |
| `PARALLEL` | 실행이 서로 독립이며 다른 실행을 기다리지 않는다 |

**V1 vs V2** — `QUEUED`·`PARALLEL` 실행 모드, 파이프라인 수준 변수, **스테이지 롤백**, 스테이지 조건, **Git 태그·풀 리퀘스트·브랜치·파일 경로 트리거와 필터링**, Commands 액션, 소스 리비전 override, 스테이지 실패 시 자동 재시도는 **V2에서만** 지원됩니다. 액션 수준 변수는 양쪽 모두 지원합니다.

**트리거와 변경 감지**

| 트리거 유형 | 설명 | 해당 소스 |
|---|---|---|
| `CreatePipeline` | 파이프라인을 만들면 실행이 자동 시작 | 모든 소스 |
| `CloudWatchEvent` | 브랜치·커밋 코드 푸시를 **자동 변경 감지**로 인식. 일정으로 시작하는 경우도 이 유형 | S3, CodeCommit |
| `PollForSourceChanges` | **폴링. 권장되지 않으며** 자동 변경 감지로 이전해야 한다 | S3, CodeCommit |
| `Webhook` | 서드파티 코드 푸시를 웹훅으로 감지 | 연결(서드파티 Git) |
| `WebhookV2` | 파이프라인 정의의 트리거로 **Git 태그 릴리스**를 감지. 자동 변경 감지는 꺼진다 | 연결(Git 태그 구성) |
| `StartPipelineExecution` | 콘솔·CLI로 수동 시작 | 모든 소스 |
| `RollbackStage` | 스테이지 롤백(수동·자동) | — |

- **소스 액션 하나에는 트리거를 하나만** 지정할 수 있습니다.
- V2 트리거 필터: 코드 푸시는 Git 태그·브랜치·파일 경로로, 풀 리퀘스트는 이벤트(opened·updated·closed)·브랜치·파일 경로로 거릅니다.
- **폴링 파이프라인은 리전당 300개로 고정**이고(증액 불가), **30일 넘게 비활성이면 폴링이 꺼집니다.**
- **일정으로 시작** — EventBridge 규칙을 Schedule 유형으로 만들고 타깃을 CodePipeline으로 지정합니다. ⚠️ EventBridge 문서는 예약 규칙을 레거시로 분류하고 **Scheduler 사용을 권장**합니다. 두 경로가 모두 문서에 있으므로 어느 한쪽을 틀렸다고 보지 않습니다.

**스테이지 조건(V2)** — 조건은 규칙 묶음이며 '게이트'라고도 부릅니다. **진입(Entry)·실패 시(On Failure)·성공 시(On Success)** 3종이 있고 결과로 스테이지 실패 또는 스테이지 롤백을 걸 수 있습니다. 예를 들어 On Success 조건의 `CloudWatchAlarm` 규칙이 배포 환경의 경보를 발견하면 **성공한 스테이지를 롤백**합니다.

**할당량(구조 감각용)** — 파이프라인당 스테이지는 **최소 2·최대 50**, 스테이지당 액션은 최소 1·최대 50입니다. 액션 유형별 타임아웃은 CodeBuild 빌드 36시간 · 테스트 8시간 · 사용자 지정 24시간 · CloudFormation 배포 3일 · CodeDeploy 계열 배포 5일 · **수동 승인 기본 7일**입니다. ⚠️ 쿼터는 리전별이고 대부분 증액할 수 있지만 **폴링 파이프라인 상한은 고정**입니다. 수치 암기보다 **"증액 가능 / 고정"의 구분과 서비스 간 대소 관계**를 봅니다.

### 4) AWS CodeBuild — buildspec·컴퓨트·캐시·테스트 리포트 {#codebuild}

**buildspec**

- YAML 형식의 빌드 명령·설정 모음입니다. 소스에 포함하면 기본 이름은 소스 루트의 `buildspec.yml`이고, 이름·위치를 바꾸거나 프로젝트에 직접 정의할 수 있습니다. **한 프로젝트에 buildspec은 하나**입니다.
- ⚠️ 버전은 **`0.2`를 권장**합니다. `0.1`은 **명령마다 별도의 셸 인스턴스**에서 실행되어 앞선 명령의 디렉터리 이동·환경 변수가 이어지지 않습니다.
- 최상위 구조: `version`, `run-as`, `env`(`variables`/`parameter-store`/`secrets-manager`/`exported-variables`/`git-credential-helper`), `proxy`, `phases`, `reports`, `artifacts`, `cache`.

| 단계(`phases`) | 문서가 드는 용도 |
|---|---|
| `install` | 빌드 환경에 패키지 설치(예: 테스트 프레임워크). `runtime-versions`로 런타임 버전 지정 |
| `pre_build` | Amazon ECR 로그인, npm 의존성 설치 |
| `build` | 테스트·빌드 실행 |
| `post_build` | JAR·WAR 패키징, **Docker 이미지를 ECR로 푸시**, SNS 알림 |

- `on-failure` 값: `ABORT`(빌드 중단) / `CONTINUE`(다음 단계로) / `RETRY` 계열(재시도 횟수·오류 메시지 정규식 지정). Lambda 컴퓨트·예약 용량에서는 지원되지 않습니다.
- `finally` 블록은 **`commands`가 실패해도 실행**되며, 그 단계는 `commands`와 `finally`가 모두 성공해야 성공입니다.
- **환경 변수 우선순위**: start build 호출 값 > 빌드 프로젝트 정의 > buildspec 선언. 민감값은 평문 `variables`가 아니라 `parameter-store` 또는 `secrets-manager`로 가져옵니다(평문은 콘솔·CLI에 노출될 수 있음).
- `exported-variables`는 CodePipeline과 함께 **현재 빌드의 변수를 후속 스테이지로** 내보냅니다.

**컴퓨트** — **EC2와 AWS Lambda 2가지 모드**입니다. EC2는 유연성, Lambda는 빠른 시작과 자동 확장에 최적화됩니다. EC2 모드는 온디맨드(사전 정의 유형) 또는 **예약 용량 플릿**(vCPU·메모리·디스크를 직접 지정)으로 실행합니다.

**캐시**

| 캐시 | 저장 위치·공유 범위 | 비고 |
|---|---|---|
| **Amazon S3** | S3 버킷, **여러 빌드 호스트가 공유** | `cache`의 `key`는 정확 일치로 찾고 `fallback-keys`는 접두 검색 |
| **로컬(Local)** | **해당 빌드 호스트에서만** | 모드 3종: source cache · **Docker layer cache**(⚠️ Linux 전용, privileged 모드 필요) · custom cache |

`cache.action`은 `restore`(복원만) / `save`(저장만)이며 생략하면 둘 다 수행합니다.

**테스트 리포트** — 단위·구성·기능 테스트를 빌드 중에 실행하고 결과를 리포트로 남깁니다. 지원 형식은 Cucumber JSON · **JUnit XML** · NUnit XML · NUnit3 XML · TestNG XML · Visual Studio TRX이며, `file-format`을 생략하면 **`JUNITXML`**입니다. buildspec에 그룹 이름만 쓰면 CodeBuild가 `<프로젝트명>-<그룹명>` 형식으로 만들어 주고, 한 프로젝트에 리포트 그룹은 **최대 5개**입니다. ⚠️ **리포트는 생성 30일 후 만료**되며, 더 오래 보관하려면 원시 파일을 S3로 내보냅니다(내보낸 파일은 만료되지 않음).

**할당량** — 빌드 타임아웃은 5분~2160분(36시간)입니다. ⚠️ 동시 실행 빌드 쿼터는 컴퓨트 유형별로 다르고 **같은 페이지의 표와 주석이 서로 맞지 않습니다**(표는 대부분 1, 주석은 일부 플랫폼이 20). 구체적 동시 빌드 수는 외우지 않고 **"컴퓨트 유형별로 다르며 증액 요청 가능"**까지만 봅니다. 다만 **Linux GPU Small 환경의 기본 쿼터 0**은 표에서 직접 확인되므로, GPU 빌드는 **쓰기 전에 증액을 요청해야** 합니다.

### 5) AWS CodeDeploy — 플랫폼·AppSpec·배포 구성·롤백 {#codedeploy}

**컴퓨트 플랫폼 3종**

| 플랫폼 | 배포 대상 | 배포 유형 | AppSpec | 트래픽 이동 구성 |
|---|---|---|---|---|
| **EC2/온프레미스** | 인스턴스에 애플리케이션 리비전 | in-place 또는 blue/green(blue/green은 **EC2 인스턴스만**) | **항상 YAML** | 최소 정상 호스트 기반 구성(`AllAtOnce`/`HalfAtATime`/`OneAtATime` 또는 사용자 지정) |
| **AWS Lambda** | 함수의 새 버전 | blue/green(트래픽 이동) | YAML 또는 JSON | **canary / linear / all-at-once** |
| **Amazon ECS** | 새 task set | blue/green(트래픽 이동) | YAML 또는 JSON | **canary / linear / all-at-once** |

- in-place는 기존 인스턴스에서 이전 버전을 멈추고 새 버전을 설치하므로 가용성이 영향받을 수 있습니다. blue/green은 새 환경(green)에 설치하고 검증한 뒤 트래픽을 옮깁니다.
- **Lambda·ECS 배포에서는 CodeDeploy agent를 쓰지 않습니다.**
- DevOps 백서의 매트릭스는 EC2/온프레미스에서 canary·linear를 지원하지 않는다고 표시합니다. ⚠️ 같은 플랫폼에 `CodeDeployDefault.AllAtOnce`가 사전 정의 구성으로 있어 표기가 상충해 보이므로, 문항 판단은 **"EC2/온프레미스에는 canary·linear 트래픽 이동이 없다"**까지만 씁니다.

**AppSpec과 훅**

- AppSpec은 배포를 **라이프사이클 이벤트 훅의 연속**으로 관리합니다. EC2/온프레미스에서는 소스 파일을 인스턴스 위치로 매핑하고 권한을 지정하고 단계별 스크립트를 실행합니다. Lambda에서는 배포할 함수 버전과 검증 함수를, ECS에서는 서비스·컨테이너 이름과 포트, 검증 함수를 지정합니다.
- **EC2/온프레미스 훅**: `ApplicationStop` → `DownloadBundle` → `BeforeInstall` → `Install` → `AfterInstall` → `ApplicationStart` → **`ValidateService`(마지막 이벤트, 배포 성공 여부 검증)**, 그리고 로드 밸런서용 `BeforeBlockTraffic`/`BlockTraffic`/`AfterBlockTraffic`/`BeforeAllowTraffic`/`AllowTraffic`/`AfterAllowTraffic`. ⚠️ `DownloadBundle`·`Install`·`BlockTraffic`·`AllowTraffic`은 **agent 전용이라 스크립트를 걸 수 없고**, 첫 배포에는 AppSpec이 아직 없으므로 **`ApplicationStop` 훅이 실행되지 않습니다.**
- **Lambda 훅 2종**: `BeforeAllowTraffic`, `AfterAllowTraffic`. **ECS 훅 5종**: `BeforeInstall`, `AfterInstall`, `AfterAllowTestTraffic`, `BeforeAllowTraffic`, `AfterAllowTraffic`.
- ⚠️ Lambda·ECS 검증 함수는 `putLifecycleEventHookExecutionStatus`로 `Succeeded`/`Failed`를 알려야 하며, **1시간 안에 알리지 않으면 배포가 실패**합니다. ECS의 `BeforeInstall` 시점에는 롤백이 불가능합니다.

**배포 구성**

| 플랫폼 | 사전 정의 구성 |
|---|---|
| EC2/온프레미스 | `CodeDeployDefault.AllAtOnce` / `HalfAtATime` / `OneAtATime`. **지정하지 않으면 `OneAtATime`**. AllAtOnce는 한 인스턴스라도 성공하면 전체 성공, HalfAtATime은 절반 이상 성공해야 성공 |
| Amazon ECS | `ECSCanary10Percent5Minutes`·`ECSCanary10Percent15Minutes`·`ECSLinear10PercentEvery1Minutes`·`ECSLinear10PercentEvery3Minutes`·`ECSAllAtOnce`. ⚠️ **Network Load Balancer를 쓰면 `ECSAllAtOnce`만** 지원 |
| AWS Lambda | `LambdaCanary10Percent` + 5/10/15/30Minutes, `LambdaLinear10PercentEvery` + 1/2/3/10Minutes, `LambdaAllAtOnce`. canary는 **첫 증분에 10%**를 보내고 나머지 90%는 지정 시간 뒤에, linear는 **10%씩 지정 간격마다** 이동 |

영역(AZ)별 정상 호스트 수를 지정하는 zonal 구성은 사전 정의가 없어 직접 만듭니다. Lambda·ECS는 사용자 지정 canary·linear 구성을 만들 수 있습니다.

**롤백** — 배포 그룹(또는 개별 배포)에서 **배포 실패 또는 모니터링 임계 충족** 시 자동 롤백을 설정할 수 있고, 이때 **마지막 정상(last known good) 리비전**이 배포됩니다. 개별 배포에서 그룹의 롤백 설정을 덮어쓸 수 있고 자동 롤백 발생은 SNS로 알릴 수 있습니다.

> 🧠 원리: CodeDeploy의 "롤백"은 별도 기능이 아니라 **이전 리비전을 대상으로 한 새 배포**입니다. 그래서 롤백도 훅과 배포 구성의 영향을 받고 **자체 배포 ID를 가집니다.** 되돌리는 것이 아니라 다시 배포하는 것이라는 점이 중요합니다.

**할당량** — Lambda 배포의 최대 실행 시간은 50시간입니다. 배포 그룹당 동시 배포 수, 연결 경보 수, 라이프사이클 이벤트 제한 시간 같은 쿼터도 같은 페이지에 있으며 일부는 증액할 수 있습니다.

### 6) 문제 해결 체크리스트 {#troubleshooting}

| 서비스 | 증상 | 원인 → 조치 |
|---|---|---|
| CodeBuild | 로그에 `Cannot connect to the Docker daemon at unix:/var/run/docker.sock` | **privileged 모드를 쓰지 않음** → 프로젝트 환경에서 Privileged 플래그를 켜고, 필요하면 `install` 단계에서 Docker 데몬을 시작 |
| CodeBuild | 앞선 명령에서 설정한 환경 변수·디렉터리가 다음 명령에서 사라짐 | **buildspec `0.1`은 명령마다 별도 셸** → `0.2`를 쓴다 |
| CodeBuild | 경고 `Skipping install of runtimes. Runtime version selection is not supported by this build image` | `runtime-versions`를 지정했는데 지원 표준 이미지가 아님 → 지원 이미지를 쓰거나 `runtime-versions`를 뺀다 |
| CodePipeline | 소스 액션이 리포지토리에 접근하지 못한다는 오류 | **파이프라인 서비스 역할의 권한 부족** → 리포지토리 접근 권한을 부여 |
| CodePipeline | S3·ECR·CodeCommit 소스인데 자동 시작이 멈춤 | 콘솔에서 브랜치명·객체 키를 **끝부분만** 바꾸면 변경 감지 이벤트 규칙이 갱신되지 않을 수 있음 → 이름 앞부분을 바꾸거나 CLI·CloudFormation으로 규칙을 관리 |
| CodePipeline | 폴링 파이프라인이 더는 시작되지 않음 | **30일 넘게 비활성이면 폴링이 꺼짐** → 이벤트 기반 변경 감지로 이전 |
| CodePipeline | 실행 모드를 `QUEUED`·`PARALLEL`로 바꾼 뒤 실행이 실패 | 모드별 **동시 실행 한도**에 도달 → 한도를 확인해 그 안으로 조절 |
| CodeDeploy | 로그에 `Missing credentials - please check if this instance was started with an IAM instance profile` | 인스턴스에 **IAM 인스턴스 프로파일이 없거나 권한 부족** |
| CodeDeploy | "The deployment failed because a specified file already exists at this location" | 배포 시 **덮어쓰기(overwrite) 또는 유지(retain) 옵션**을 선택 |
| CodeDeploy | Lambda·ECS 배포가 훅 단계에서 시간 초과 | 검증 함수가 **1시간 안에** `putLifecycleEventHookExecutionStatus`로 결과를 알리지 않음 |
| CodeDeploy | "Validation of PKCS7 signed message failed" | SHA-1만 지원하는 **오래된 agent** → agent 업데이트 |
| SageMaker Pipelines | 일시적 오류로 단계 실패 | 단계에 **재시도 정책** 설정(→ 9)) |

CodeDeploy 배포 실패 원인은 로그 파일에서 찾을 수 있고, 인스턴스별로 보는 대신 **CloudWatch Logs로 모으길 권장**합니다. EC2/온프레미스 문제 해결을 자동화하는 Systems Manager 런북은 `AWSSupport-TroubleshootCodeDeploy`입니다.

### 7) 버전 관리와 리포지토리–파이프라인 연동 {#git-repo-pipeline}

**Git 기본** — 버전 관리는 소스 코드를 저장하고 변경을 추적하는 시스템이며, 변경이 버전으로 저장되어 비교하거나 되돌릴 수 있습니다. **커밋**은 브랜치에서 한 변경을 저장하는 것, **푸시**는 로컬 커밋을 호스팅 저장소로 복사하는 것, **풀 리퀘스트**는 병합 전에 다른 기여자가 검토하도록 요청하는 절차입니다.

**병합 전략 3종**

| 전략 | 동작 |
|---|---|
| **fast-forward** | 대상 브랜치 포인터를 소스 브랜치의 최신 커밋으로 옮긴다. **병합 커밋을 만들지 않고** 이력을 보존한다 |
| **squash** | 소스 브랜치 변경을 **커밋 하나로 합쳐** 적용하고 개별 이력은 남기지 않는다 |
| **three-way** | **병합 커밋을 만들면서** 소스 브랜치의 개별 커밋을 이력에 유지한다 |

ML 자산(코드·구성·인프라 정의·**모델 아티팩트**)도 버전 관리 대상입니다.

**리포지토리 → 파이프라인 연동**

| 소스 | 변경 감지 | 후속 액션에 넘기는 형태 |
|---|---|---|
| **AWS CodeCommit** | EventBridge 규칙(콘솔로 만들면 자동 생성, **권장**) | 기본: 커밋의 얕은 복사 ZIP / **Full clone: Git URL 참조(하위 CodeBuild 액션만 사용 가능)** |
| **GitHub·GitHub Enterprise Server·GitLab·Bitbucket Cloud** | **연결(connections)**이 변경 감지를 관리. GitHub App에 설치된 웹훅이 push 이벤트를 구독 | ZIP 또는 Full clone(CodeBuild 전용) |
| **Amazon S3** | EventBridge 규칙 + CloudTrail 또는 이벤트가 켜진 버킷 | 객체 버전(버전 관리가 켜진 버킷을 소스로 구성) |
| **Amazon ECR** | EventBridge 규칙 | 이미지 |

- 연결 하나가 해당 제공자의 모든 리포지토리를 지원합니다. GitHub의 OAuth app 액션은 비권장입니다.
- ⚠️ **명칭**: 연결 기능은 2024-03-29에 AWS CodeStar Connections에서 **AWS CodeConnections**로 개명됐습니다. SageMaker 프로젝트 문서는 아직 "AWS CodeStar connection"이라 적으므로 **두 이름을 같은 것으로** 읽습니다.
- ⚠️ **AWS CodeCommit**은 2024-07-25부터 신규 고객에게 닫혔다가 **2025-11-25부터 신규 고객에게 다시 열렸습니다.** 이 사실과 SageMaker Projects의 CodeCommit 템플릿 제거는 **별개**입니다(→ 10)).

**리포지토리 이벤트로 파이프라인을 시작하는 세 경로**(이 문서의 정리): ① 이벤트 기반(CodeCommit·S3·ECR의 EventBridge 규칙) ② 연결의 웹훅(서드파티 Git) ③ V2 파이프라인의 트리거 정의(push·PR, 태그·브랜치·파일 경로 필터).

### 8) 브랜치 전략과 파이프라인 호출 {#branch-strategy}

AWS 규범 가이드는 세 전략을 **복잡도 순(단순 → 복잡)으로 Trunk, GitHub Flow, Gitflow**라고 설명합니다.

| 항목 | **Trunk** | **GitHub Flow** | **Gitflow** |
|---|---|---|---|
| 핵심 | 모든 개발자가 **단일 브랜치**(trunk 또는 main)에서 작업, 하루 여러 번 소규모 커밋 | **단명 feature 브랜치**를 완료되면 main에 병합 | feature → 승인 후 **통합 브랜치(`develop`)** → 기능이 모이면 `release` 브랜치를 만들어 상위 환경에 배포 |
| 브랜치 | trunk(main) | main + 단명 feature | 영구 `main`·`develop` + `feature`·`release`·`hotfix` |
| 배포 시점 | 항상 릴리스 가능 상태를 유지하며 자주 통합 | main에 병합되는 즉시 배포 | 예정된 **릴리스 주기**에 맞춰 release 브랜치로 |
| 적합 | 자동 테스트와 CI에 의존하는 팀 | **작고 성숙한 팀**, 지속적 전달 지향 | **크고 분산된 팀**, 엄격한 릴리스·규정 준수 요구, 여러 프로덕션 버전 동시 유지 |
| 부적합 | — | 엄격한 규정 준수·릴리스 절차가 있는 팀, 병합 충돌이 잦음 | **지속적 전달을 지향하는 조직**, release 브랜치가 오래 살아 기술 부채 누적 |
| 파이프라인 호출(정리) | main push 시 빌드·테스트·배포 | main push는 배포, **PR 이벤트는 사전 검증** 파이프라인 | 브랜치별 파이프라인: develop·feature는 통합 환경, release·main·hotfix는 상위 환경 |

Gitflow는 세 전략 중 가장 복잡해 CI/CD 파이프라인에 **규정 준수용 단계가 더 필요**하고 여러 프로덕션 릴리스를 동시에 지원해야 합니다.

> 🧠 원리: 브랜치 전략이 복잡할수록 사람이 절차를 우회할 여지가 늘기 때문에 **CI/CD가 가드레일 역할**을 하며 그 중요성도 함께 커집니다.

### 9) SageMaker Pipelines — DAG·단계·캐싱·재시도 {#sagemaker-pipelines}

**정의** — ML 개발을 자동화하는 **목적 특화 워크플로 오케스트레이션 서비스**입니다. 오케스트레이션 인프라를 SageMaker AI가 자동으로 프로비저닝·확장·종료하고, 시각 편집기·SDK·API·JSON으로 만듭니다. 비용은 Studio 환경과 파이프라인이 오케스트레이션하는 **하위 작업**에 대해서만 냅니다. **내장 버전 관리와 ML Lineage Tracking**으로 실행 이력과 데이터 계보를 추적합니다. 오케스트레이터 선택 비교는 [`mla-t3-1` 13)](mla-t3-1.md#orchestrator-choice)이 정본입니다.

**DAG** — 파이프라인은 방향성 비순환 그래프로 연결된 단계 묶음이고, ⚠️ **DAG 구조는 한 단계의 출력 속성을 다른 단계의 입력으로 넘기는 데이터 의존성으로 결정**됩니다.

- 데이터 의존성이 없는 단계는 실행 즉시 시작되어 **병렬**로 돕니다. 동시 단계 수는 `ParallelismConfiguration`으로 제한합니다.
- 데이터 연결 없이 **시작 순서만** 강제하려면 `DependsOn`을 씁니다. 순환 의존성은 검증 예외를 일으킵니다.

**단계 유형(현재 문서 기준 18종)**

| 묶음 | 단계 |
|---|---|
| 데이터·훈련 | **Processing** · **Training** · **Tuning**(HPO) · **AutoML**(현재는 앙상블링 훈련 모드만) · **EMR** · **Notebook Job** · **Execute code** |
| 모델·배포 | **Create model** · **Register model**(Model Registry의 버전 있는 모델 패키지 그룹에 등록) · **Deploy model (endpoint)** · **Transform**(배치 변환) |
| 흐름 제어 | **Condition**(단계 속성을 평가해 분기. ⚠️ **중첩 불가**, 양 분기에 같은 단계 사용 불가) · **Fail**(실행 중단 + 사용자 지정 오류 메시지) · **Callback**(SQS 큐에 토큰 메시지를 보내고 응답 대기) · **Lambda**(기존 함수는 파이프라인과 **같은 리전**) |
| 품질 검사 ⚠️ | **QualityCheck**(데이터·모델 품질 baseline 제안과 드리프트 검사 — **Model Monitor 컨테이너** 사용) · **ClarifyCheck**(편향·설명 가능성 baseline 드리프트 검사 — **Clarify 컨테이너** 사용) |

⚠️ QualityCheck·ClarifyCheck가 기대는 **Model Monitor와 Clarify는 신규 고객에게 닫혀 있습니다**(상태·대안은 [`mla-t2-1` 8)](mla-t2-1.md#service-status)). 두 단계 자체의 향후 지원 변화를 알려 주는 공지는 확인되지 않았으므로, **"신규 고객에게 닫힌 기능에 의존한다"까지만** 알아 둡니다.

**파라미터** — `ParameterString` / `ParameterInteger` / `ParameterFloat` / `ParameterBoolean` 4종. 기본값을 두고 실행 시작 시 덮어쓸 수 있으며, 단계 정의에 쓰는 모든 파라미터는 파이프라인 정의에 선언해야 합니다.

**캐싱**

| 항목 | 내용 |
|---|---|
| 기본값 | **꺼짐(opt-in)** |
| 켤 때 필수 | **타임아웃** — 이전 실행이 재사용 후보로 남는 최대 나이 |
| 재사용 기준 | 단계 유형별 기본 cache key 속성이 같은 이전 실행(단계 서명) |
| 재사용 조건 | **성공한 실행만.** 타임아웃 안에 여러 개면 가장 최근 성공 실행 |
| 범위 | **개별 파이프라인 안**(다른 파이프라인의 단계는 재사용 불가) |
| 지원 단계 | Processing · Training · Tuning · AutoML · Transform · ClarifyCheck · QualityCheck · EMR |

**재시도 정책**

| 항목 | 내용 |
|---|---|
| 지원 단계 | Processing · Training · Tuning · AutoML · Create model · Register model · Transform · Notebook job |
| 예외 유형 | `Step.SERVICE_FAULT`·`Step.THROTTLING`(둘은 **기본으로 자동 재시도**하며 정책으로 덮어쓸 수 있음) · `SageMaker.JOB_INTERNAL_ERROR` · `SageMaker.CAPACITY_ERROR` · `SageMaker.RESOURCE_LIMIT` |
| 설정 필드 | `ExceptionType` · `IntervalSeconds` · `BackoffRate` · `MaxAttempts`(**기본 5, 최대 20**) · `ExpireAfterMin` |
| 제약 | ⚠️ **`MaxAttempts`와 `ExpireAfterMin`은 둘 중 하나만** 지정(둘 다 주면 검증 오류). 튜닝·AutoML 단계는 내부 재시도 때문에 `SageMaker.JOB_INTERNAL_ERROR`를 재시도하지 않는다 |

**실행 방법** — 수동·SDK 시작, **EventBridge 규칙의 타깃**(`StartPipelineExecution`), SDK의 파이프라인 일정(`PipelineSchedule`)으로 시작합니다. SageMaker 파이프라인은 EventBridge 타깃으로 지원되어 S3 신규 파일 업로드, 드리프트로 인한 엔드포인트 상태 변화, SNS 토픽 같은 이벤트로 시작할 수 있습니다. 파이프라인 실행·단계 상태 변화도 EventBridge 이벤트로 나갑니다(상태 변화마다 이벤트가 여러 번 올 수 있음).

**baseline 수명 주기** — QualityCheck·ClarifyCheck는 **항상 새 baseline을 계산**합니다. `skip_check=False`일 때 이전 baseline 대비 위반이 감지되면 **단계가 실패하고 파이프라인이 진행되지 않아 드리프트한 모델이 등록되지 않습니다.**

| 사용 사례 | `skip_check` / `register_new_baseline` |
|---|---|
| 정기 재훈련, 이전 baseline 유지 | False / False |
| 정기 재훈련, baseline 갱신 | False / True |
| Model Monitor 위반 때문에 재훈련, 해당 검사 건너뜀 | True / False |
| 최초 실행, 또는 위반 재훈련에서 검사 건너뛰고 baseline 갱신 | True / True |

파이프라인은 훈련 작업처럼 **독립 엔티티**라 Projects 없이도 노트북에서 SDK로 만들고 실행할 수 있습니다.

### 10) Projects와 Model Registry 승인 → 배포 자동화 {#projects-registry}

**SageMaker Projects** — 조직이 데이터 과학자 개발 환경과 MLOps 엔지니어용 CI/CD 시스템을 **표준화**하도록 돕습니다. 프로젝트 이름·ID가 모든 리소스에 태그로 붙어 파이프라인·등록 모델·엔드포인트·데이터셋·저장소를 함께 볼 수 있습니다. 템플릿 보관 위치와 선택 기준은 [`mla-t3-2` 8)](mla-t3-2.md#iac-choice)에 있습니다.

**템플릿 선택지** — 코드 저장소는 **서드파티 Git**(GitHub·Bitbucket 등), CI/CD 자동화는 **AWS CodePipeline 또는 Jenkins**, 파이프라인 단계는 모델 구축·훈련 / 모델 배포 / 둘 다.

| 템플릿 | 구성 요소 |
|---|---|
| **모델 구축·훈련** | 서드파티 Git 저장소(SageMaker 파이프라인을 만드는 샘플 코드), source·build 단계의 CodePipeline(**build가 SageMaker 파이프라인을 만들고 갱신하고 실행을 시작해 완료까지 대기**), 시드 코드용 CodeBuild, 아티팩트용 S3 버킷 |
| **모델 배포** | 스테이징·프로덕션 엔드포인트에 배포하는 샘플 코드, source·build·deploy-to-staging·deploy-to-production 단계의 CodePipeline(**build가 CloudFormation 스택 생성**), 스테이징과 프로덕션 사이 **수동 승인** |
| 모델 구축·훈련·배포 | 위 두 템플릿의 결합 |
| + Model Monitor ⚠️ | 위 + 데이터 품질·모델 품질·편향 드리프트 모니터링 |
| Monitor a deployed model ⚠️ | 레지스트리에서 baseline을 가져와 모니터를 배포. **스테이징 엔드포인트가 갱신될 때마다 EventBridge 규칙 2개**가 Model Monitor용 CodePipeline을 시작 |
| Jenkins 버전 | CodePipeline 대신 Jenkins. AWS와 Jenkins 연결은 수동 설정, **EventBridge 규칙으로 레지스트리의 신규 승인 모델 감시** |
| 이미지 빌드 + 모델 구축 + 배포 | ECR 저장소·SageMaker 이미지·Dockerfile 저장소·CodePipeline·CodeBuild·일정 EventBridge 규칙. 새 컨테이너 등록 → `ImageVersion` 추가 → 모델 구축 파이프라인 시작 → 배포 파이프라인 시작 |

⚠️ **CodeCommit 템플릿** — 두 공식 문서가 **날짜를 다르게** 적습니다(템플릿 문서는 2024-10-28 제거, 프로젝트 개요 문서는 2024-09-09부터 미지원). 정확한 일자를 근거로 쓰지 않고 **"2024년 가을부터 신규 프로젝트는 서드파티 Git 템플릿을 쓴다"**로 기억합니다. CodeCommit 서비스가 2025-11-25부터 신규 고객에게 다시 열린 것(→ 7))과 **템플릿 복원은 별개**이며, 복원을 알려 주는 문서는 확인되지 않았습니다.

서드파티 Git 템플릿은 CodeConnections(구 CodeStar Connections) 연결이 필요하고, 그 연결에 키 `sagemaker`·값 `true` **태그를 달아야** 합니다.

**승인 상태 전이 4종과 동작** — Model Registry의 모델 버전 기본 정보는 [`mla-t3-1` 7)](mla-t3-1.md#versioning-rollback)에 있습니다. 여기서는 전이가 **무엇을 시작시키는지**를 봅니다.

| 전이 | 동작 |
|---|---|
| `PendingManualApproval` → `Approved` | 승인된 모델 버전의 **CI/CD 배포 시작** |
| `PendingManualApproval` → `Rejected` | **동작 없음** |
| `Rejected` → `Approved` | 승인된 모델 버전의 CI/CD 배포 시작 |
| `Approved` → `Rejected` | **가장 최근 `Approved` 버전을 배포**하는 CI/CD 시작(= 롤백) |

승인은 SDK·Studio 콘솔로 하거나 파이프라인의 **Condition 단계로 자동 평가**할 수 있습니다. 모델 패키지 상태 변화는 EventBridge의 `SageMaker Model Package State Change` 이벤트로 전달되어 Lambda·배포 파이프라인을 시작시킬 수 있습니다.

> 🧠 원리: **승인 상태 전이가 곧 CI/CD 트리거**입니다. `Approved`로 바뀌는 순간 배포가 시작되고, `Approved` → `Rejected`는 직전 승인 버전으로 다시 배포하게 만듭니다. 그래서 "롤백 버튼"이 따로 없어도 거부가 롤백이 됩니다.

**표준 흐름**(이 문서의 정리): ① 모델 구축 파이프라인이 모델을 `PendingManualApproval`로 등록 → ② Condition 단계 또는 사람이 승인 → ③ 상태 변화 이벤트가 배포 파이프라인 시작 → ④ CloudFormation으로 스테이징 엔드포인트 배포 → ⑤ **수동 승인** → ⑥ 프로덕션 배포.

### 11) 데이터 수집 자동화를 파이프라인에 연결하기 {#ingestion-automation}

| 수집 이벤트 | 연결 방법 | 시작되는 것 |
|---|---|---|
| **S3에 새 객체 도착** | 버킷의 EventBridge 알림을 켜면 모든 이벤트가 EventBridge로 간다 → `Object Created` 이벤트 패턴 규칙 | SageMaker 파이프라인(타깃), Glue 워크플로, Lambda·Step Functions |
| **일정** | EventBridge Scheduler(권장) 또는 예약 규칙(레거시) | SageMaker 파이프라인, CodePipeline |
| **ETL 체인** | Glue 워크플로 시작 트리거 3종: **Schedule / On demand / EventBridge event** | Glue 크롤러·잡 |

- S3는 버킷 이벤트를 EventBridge로 보낼 수 있고, **켜면 모든 이벤트가 전송**되므로 규칙으로 걸러 타깃에 연결합니다.
- Glue 워크플로는 시작 트리거에 EventBridge 이벤트를 쓸 수 있고 이벤트를 배치로 모을 수 있으며, **배치 창의 기본값이자 최대값이 900초**입니다.
- ML Lens는 새 훈련 데이터가 생기면 **S3 이벤트 알림으로 Lambda 또는 Step Functions 워크플로를 실행**하라고 안내하고, 신규 데이터 탐지에 CloudTrail + CloudWatch Events를 조합해 Step Functions를 시작하는 방법도 듭니다.

### 12) 배포 전략·롤백 — 가드레일과 CodeDeploy의 대응 {#deploy-strategy-rollback}

**전략 정의** — in-place(기존 컴퓨트 자원에서 이전 버전을 멈추고 새 버전 설치) · blue/green(동일한 두 환경 사이 트래픽 전환) · canary(점진 노출 후 전체 교체) · linear(동일 증분·동일 간격) · all-at-once(전체 한 번에). **in-place는 all-at-once(서비스 중단 가정) 또는 롤링 업데이트로** 수행합니다.

**플랫폼별 지원**

| 전략 | Amazon ECS | AWS Lambda | EC2/온프레미스 |
|---|---|---|---|
| In-place | 지원 | 지원 | 지원 |
| Blue/green | 지원 | 지원 | 지원(**EC2 인스턴스만**) |
| Canary | 지원 | 지원 | **미지원** |
| Linear | 지원 | 지원 | **미지원** |
| All-at-once | 지원 | 지원 | 미지원(매트릭스 표기 — 5)의 ⚠️ 참조) |

**SageMaker 가드레일 ↔ CodeDeploy 대응**

| 개념 | CodeDeploy | SageMaker 엔드포인트 가드레일 |
|---|---|---|
| All-at-once | `LambdaAllAtOnce` / `ECSAllAtOnce` | `ALL_AT_ONCE`(**업데이트 정책을 지정하지 않을 때의 기본값**) |
| Canary | `LambdaCanary10Percent5Minutes` 등 — **값이 고정된 이름** | `CANARY`: 2단계, `CanarySize`(변형 전체 인스턴스 수의 **50% 이하**), `WaitIntervalInSeconds` |
| Linear | `LambdaLinear10PercentEvery1Minute` 등 | `LINEAR`: n단계, `LinearStepSize`(**10~50%**) |
| Rolling / in-place | EC2/온프레 in-place + `HalfAtATime`·`OneAtATime` | `RollingUpdatePolicy`: `MaximumBatchSize` **5~50%** |
| 롤백 트리거 | 배포 그룹에 연결한 경보·실패한 훅·자동 롤백 설정 → **마지막 정상 리비전 재배포** | `AutoRollbackConfiguration.Alarms`(**1~10개**) + 베이킹 기간 |
| 적용 대상 | EC2/온프레·Lambda·ECS | **비동기·실시간 엔드포인트** |

⚠️ 핵심 차이 둘: ① **CodeDeploy의 사전 정의 canary·linear는 비율과 시간이 이름에 박혀 있고**, SageMaker는 용량(인스턴스 수·비율)과 대기 시간을 **API 파라미터로 직접** 지정합니다. ② **CodeDeploy는 SageMaker 엔드포인트를 컴퓨트 플랫폼으로 지원하지 않습니다.**

가드레일의 방식별 장단점과 제외 대상은 [`mla-t3-1` 8)](mla-t3-1.md#deployment-guardrails)이 정본입니다. `BlueGreenUpdatePolicy`의 `MaximumExecutionTimeoutInSeconds` 범위는 600~28,800초, `TerminationWaitInSeconds` 기본값은 0입니다.

MLOps 체크리스트는 모델 승격 방식으로 **canary·shadow·blue/green·A/B 중 하나 이상**과 **롤백 수단 하나 이상**을 요구합니다.

### 13) CI/CD 안의 자동화된 테스트와 품질 게이트 {#automated-tests}

| 테스트·게이트 | 무엇을 검증 | 넣을 위치 | 도구 |
|---|---|---|---|
| 로컬 검사·정적 분석 | 커밋 전 기본 단위 테스트, 커밋 시 빠른 정적 분석(스타일·보안 취약점·버그) | 커밋 전, 커밋 시 | CodeBuild |
| **단위 테스트** | 모델·애플리케이션·인프라 코드 전체. ML 코드는 알고리즘 정확성 | 커밋 전과 커밋 시(소스 다음 build 스테이지) | CodeBuild `build` 단계 + 테스트 리포트 |
| **데이터 품질 테스트** | 최소한 고정 스키마 위반 여부, 더 나아가 수집 시 통계·제약을 계산해 검사 | 수집·전처리 시점 | Pipelines Processing 또는 QualityCheck ⚠️ |
| 특성·모델 기능 테스트 | 특성 중요도 불변 확인, 모델 입력·출력 기능 테스트 | 훈련 파이프라인 내부 | Pipelines |
| **통합 테스트** | 인프라 구성까지 포함해 파이프라인이 처음부터 끝까지 성공적으로 실행되는지 | 스테이징에서 SageMaker 파이프라인을 **실제 실행** | Projects 모델 구축 템플릿의 CodeBuild 단계가 실행을 시작하고 완료까지 대기 |
| **엔드투엔드 테스트** | 배포가 분리되어 있으면 배포가 제대로 동작하는지 | 스테이징 엔드포인트 배포 후, 프로덕션 승인 전 | CodePipeline의 deploy-to-staging 이후 |
| 스모크·부하 테스트 | 기능별 빠른 회귀, 처리량·지연 통계 | CI 또는 배포 전 | |
| 극단 입력 추론 테스트 | 모델 승격 전 극단적 입력에서의 동작 | 모델 승격 전 | |
| **모델 품질 게이트** | 평가 지표가 임계 이내인지 | 평가 단계 직후 | Pipelines **Condition** 단계(+ `Fail`). 미충족 시 실행이 멈춘다 |
| **승인 게이트** | 프로덕션 전 사람의 확인 | 스테이징과 프로덕션 사이 | Model Registry 승인 상태, CodePipeline **수동 승인** |

- ML Lens는 **데이터 품질·모델 성능·API 기능**에 대한 자동 테스트를 CI/CD에 포함하고, 프로덕션 전에 스테이징에 배포하며, 필요한 곳에 승인 게이트를 두고 Model Registry로 버전 관리를 하라고 적습니다. MLREL04-BP01은 파이프라인 테스트에 **단위 테스트·통합 테스트·모델 품질 평가**를 포함하라고 합니다.
- **실행 시점**: 테스트는 커밋 시 자동 실행하고 **긴 테스트는 고정 일정으로** 돌립니다.
- 게이트의 동작: 실행이 실패하면 파이프라인은 끝까지 가지 못하고 멈춥니다. SageMaker 예제 DAG에서는 평가 지표가 임계에 못 미치면 **등록 단계로 가지 않습니다.**
- ⚠️ buildspec의 `finally` 블록은 `commands`가 실패해도 실행되므로 **품질 게이트로 쓰기에 맞지 않습니다**(정리·알림 용도).

### 14) 모델 재훈련 메커니즘 {#retraining}

| 트리거 | 구성 |
|---|---|
| **일정 기반** | EventBridge Scheduler(권장) 또는 예약 규칙(레거시) → 타깃으로 SageMaker 파이프라인. ⚠️ **성능·데이터 패턴과 무관한 고정 일정 재훈련은 ML Lens가 드는 안티패턴**이다 |
| **신규 데이터 도착** | S3 EventBridge 알림 → `Object Created` 규칙 → SageMaker 파이프라인 / Glue 워크플로 / Lambda·Step Functions |
| **드리프트·품질 위반** | Model Monitor 일정 실행 → CloudWatch 지표 → 임계 초과 **CloudWatch 경보** → EventBridge 규칙 → 모델 구축 파이프라인 시작. ⚠️ **이 체인 전체를 한 공식 문서가 서술하지는 않습니다**(AWS 블로그 패턴 + ML Lens의 "CloudWatch 경보로 재훈련 워크플로 실행"·"드리프트로 인한 엔드포인트 상태 변화가 EventBridge 이벤트 예"를 엮은 것). Model Monitor는 신규 고객에게 닫혀 있다 |
| **모델 레지스트리 이벤트** | `SageMaker Model Package State Change` → 배포 파이프라인. **재훈련이 아니라 릴리스 자동화**다 |
| **코드 변경** | CodePipeline source(커밋·PR) → CodeBuild가 SageMaker 파이프라인 실행 |
| 수동·파라미터 | SDK로 파라미터를 주며 시작, 또는 EventBridge 타깃의 정적·동적 파라미터 |

**ML Lens의 재훈련 프레임워크** — ① 성능 지표 정의 ② Model Monitor로 모니터링(데이터 품질·모델 품질·편향 드리프트·특성 기여도 드리프트) ③ **재훈련 조건 정의**(일정 주기, 임계 이하 성능 저하, 데이터 드리프트, 신규 훈련 데이터) ④ Pipelines로 재훈련 파이프라인(배포 전 홀드아웃 검증 포함) ⑤ Model Registry 버전 관리 ⑥ 신규 데이터 자동 처리 ⑦ 오케스트레이션 ⑧ **blue/green·canary 같은 배포 안전장치와 성능 저하 시 자동 롤백** ⑨ 정답 데이터를 모으는 피드백 루프 ⑩ 재훈련 프로세스 문서화.

**"필요할 때만 재훈련"**(MLSUS06-BP02) — KPI에서 임계값을 정하고, 운영 모델을 평가하며, 임계 초과 시 울리는 CloudWatch 경보로 자동화된 파이프라인을 시작하고, 재훈련 모델은 canary 같은 방식으로 배포합니다.

Pipelines 쪽 설계: Model Monitor 위반 때문에 재훈련하는 경우 해당 검사 유형을 이전 baseline과 비교하지 않고(`skip_check=True`) 새 baseline을 레지스트리에 갱신(`register_new_baseline=True`)할 수 있습니다(→ 9)).

> 🧠 원리: Model Monitor가 일정에 따라 실행되며 CloudWatch에 지표를 게시하고, 임계 초과 경보가 EventBridge 규칙을 거쳐 모델 구축 파이프라인을 시작합니다. **같은 파이프라인을 일정 규칙으로도 시작할 수 있다**는 점이 중요합니다 — 트리거만 바꿔 끼우면 되는 구조입니다.

---

## ✍️ 시험 포인트

- **역할 분담을 먼저 가릅니다.** 빌드·단위 테스트 → CodeBuild. 단계 오케스트레이션·승인 → CodePipeline. EC2·Lambda·ECS 배포 → CodeDeploy. ML 작업 DAG → SageMaker Pipelines. **SageMaker 엔드포인트의 canary·linear → 배포 가드레일**(CodeDeploy 아님).
- **V2에서만 되는 것**이 문항이 됩니다: `QUEUED`·`PARALLEL` 실행 모드, 스테이지 롤백, 스테이지 조건, Git 태그·PR·브랜치·파일 경로 트리거.
- **폴링은 함정입니다.** 권장되지 않고, 리전당 300개로 **고정**이며, 30일 비활성 시 꺼집니다. 정답 방향은 **EventBridge 기반 자동 변경 감지**입니다.
- buildspec 함정 둘: **`0.1`은 명령마다 별도 셸**(상태가 안 이어짐) · **Docker 데몬 오류는 privileged 모드** 미사용.
- **테스트 리포트는 30일 후 만료**됩니다. 더 보관하려면 S3로 내보냅니다.
- **CodeDeploy 롤백은 "이전 리비전의 재배포"**입니다. 그래서 새 배포 ID가 생기고 훅과 배포 구성의 영향을 받습니다.
- **플랫폼별 구성 짝**: EC2/온프레는 `AllAtOnce`·`HalfAtATime`·`OneAtATime`(기본 `OneAtATime`), Lambda·ECS는 canary·linear·all-at-once. **ECS + NLB면 `ECSAllAtOnce`만.**
- **Pipelines의 DAG는 데이터 의존성으로 결정**됩니다. 순서만 강제하려면 `DependsOn`입니다. Condition 단계는 **중첩할 수 없습니다.**
- 캐싱은 **기본 꺼짐 + 타임아웃 필수 + 성공한 실행만 + 같은 파이프라인 안**. 재시도는 `MaxAttempts`(기본 5·최대 20)와 `ExpireAfterMin` **둘 중 하나만**.
- **승인 전이가 트리거입니다.** `Approved`로 가면 배포, `Approved` → `Rejected`면 **직전 승인 버전 재배포**, `PendingManualApproval` → `Rejected`는 **아무 일도 없음**.
- 브랜치 전략은 **팀 규모와 규정 준수 요구**로 갈립니다. 작고 성숙 + 지속적 전달 → GitHub Flow. 크고 분산 + 엄격한 릴리스 → Gitflow. 지속적 전달 지향 조직에 Gitflow는 맞지 않습니다.
- **고정 일정 재훈련은 안티패턴**입니다. 조건은 성능 저하·드리프트·신규 데이터로 정의합니다.

---

## ⚠️ 흔한 함정 {#pitfalls}

| 함정 | 바로잡기 |
|---|---|
| SageMaker 엔드포인트의 canary 배포를 CodeDeploy로 한다 | CodeDeploy의 컴퓨트 플랫폼은 **EC2/온프레미스·Lambda·ECS 3종**이고 SageMaker 엔드포인트는 없다. 엔드포인트의 점진 배포는 **배포 가드레일**이다 |
| CodePipeline과 SageMaker Pipelines를 같은 것으로 본다 | 전자는 **릴리스 단계를 모델링하는 지속적 전달 서비스**, 후자는 **ML 작업의 DAG**다. Projects 템플릿은 CodeBuild 단계에서 후자를 실행한다 |
| CodeBuild를 배포 서비스로 쓴다 | CodeBuild는 소스 컴파일·테스트 실행·아티팩트 생성을 하는 **빌드 서비스**다. 배포는 deploy 액션의 제공자가 한다 |
| 소스 변경 감지를 폴링으로 설정한다 | 권장되지 않고 리전당 **300개 고정**이며 30일 비활성 시 꺼진다. EventBridge 기반 자동 변경 감지로 간다 |
| buildspec `0.1`로 여러 명령에 걸쳐 환경 변수를 넘긴다 | `0.1`은 **명령마다 별도 셸**이라 디렉터리 이동·환경 변수가 이어지지 않는다. `0.2`를 쓴다 |
| 빌드에서 Docker 이미지를 만드는데 privileged 모드를 켜지 않는다 | Docker 데몬에 연결할 수 없다는 오류가 난다. Privileged 플래그를 켠다 |
| 테스트 리포트를 감사 기록으로 장기 보관한다 | **생성 30일 후 만료**된다. 오래 보관하려면 원시 파일을 S3로 내보낸다 |
| Docker 레이어 캐시를 Windows 빌드에 쓴다 | 로컬 캐시의 Docker layer cache 모드는 **Linux 환경 전용**이며 privileged 모드가 필요하다 |
| EC2/온프레미스 배포에 canary 구성을 지정한다 | 그 플랫폼의 사전 정의 구성은 `AllAtOnce`·`HalfAtATime`·`OneAtATime`이다. canary·linear 트래픽 이동은 Lambda·ECS 쪽이다 |
| 배포 구성을 생략하면 한 번에 다 배포된다고 본다 | EC2/온프레미스에서 생략 시 기본값은 **`OneAtATime`**이다 |
| ECS 배포에 NLB를 쓰면서 canary 구성을 고른다 | Network Load Balancer를 쓰면 **`ECSAllAtOnce`만** 지원된다 |
| Lambda·ECS 검증 함수에서 결과를 알리지 않아도 넘어간다고 본다 | `putLifecycleEventHookExecutionStatus`로 **1시간 안에** 알리지 않으면 배포가 실패한다 |
| 첫 배포에서 `ApplicationStop` 훅으로 정리 작업을 한다 | 첫 배포에는 AppSpec이 아직 없어 **이 훅이 실행되지 않는다** |
| Pipelines의 단계 순서를 코드 작성 순서가 정한다고 본다 | DAG는 **데이터 의존성**으로 결정된다. 의존성이 없으면 병렬로 돌고, 순서만 강제하려면 `DependsOn`을 쓴다 |
| 단계 캐싱이 기본으로 동작한다고 가정한다 | **기본 꺼짐**이고 켤 때 타임아웃이 필수다. 성공한 실행만, 같은 파이프라인 안에서만 재사용된다 |
| 재시도 정책에 `MaxAttempts`와 `ExpireAfterMin`을 함께 준다 | **둘 중 하나만** 지정할 수 있고 둘 다 주면 검증 오류가 난다 |
| 승인 대기 상태에서 거부하면 롤백이 일어난다고 본다 | `PendingManualApproval` → `Rejected`는 **동작이 없다.** 롤백을 일으키는 것은 `Approved` → `Rejected`다 |
| CodeCommit이 신규 고객에게 다시 열렸으니 Projects의 CodeCommit 템플릿도 돌아왔다고 본다 | 서비스 재개와 템플릿 제거는 **별개 사실**이고 템플릿 복원은 문서에서 확인되지 않는다 |
| 재훈련을 매주 고정 일정으로만 돌린다 | 성능·데이터 패턴과 무관한 고정 일정 재훈련은 **ML Lens의 안티패턴**이다. 조건은 성능 저하·드리프트·신규 데이터로 정의한다 |

---

## 🧪 자가 점검

1. CI와 CD의 공식 정의 차이는? 그리고 CD가 "모든 변경을 즉시 릴리스한다"는 뜻이 아닌 이유는? *(→ 1))*
2. 커밋 하나가 빌드·단위 테스트를 거쳐 스테이징 엔드포인트에 올라가고 사람 승인 후 프로덕션으로 가는 흐름에서, 각 구간을 담당하는 서비스를 짚어라. *(→ 2), 10))*
3. 실행이 몰릴 때 앞선 실행이 멈추지 않고 순서대로 처리되게 하려면 어떤 실행 모드이고, 그 모드는 어느 파이프라인 유형에서 되는가? *(→ 3))*
4. 빌드 로그에 Docker 데몬에 연결할 수 없다는 오류가 났다. 원인과 조치는? *(→ 4), 6))*
5. Lambda 함수를 10%씩 1분 간격으로 옮기는 사전 정의 배포 구성의 이름 형태는? EC2에 같은 방식을 쓸 수 있는가? *(→ 5), 12))*
6. CodeDeploy에서 자동 롤백이 일어나면 배포 ID와 훅은 어떻게 되는가? *(→ 5))*
7. CodeCommit 소스를 Full clone으로 설정했다. 어떤 액션에서만 쓸 수 있는가? *(→ 7))*
8. 크고 분산된 팀이 여러 프로덕션 버전을 동시에 유지해야 한다. 어떤 브랜치 전략이고, 그 전략이 CI/CD에 요구하는 추가 부담은? *(→ 8))*
9. 전처리와 특성 추출이 서로 독립인데 둘이 순서대로 돌고 있다. 왜일 수 있고 어떻게 병렬로 만드는가? *(→ 9))*
10. 모델 평가 지표가 임계에 못 미칠 때 등록을 막으려면 어떤 단계를 쓰는가? 그 단계의 제약 두 가지는? *(→ 9), 13))*
11. 프로덕션에 올린 모델을 직전 승인 버전으로 되돌리려면 레지스트리에서 어떤 전이를 하는가? *(→ 10))*
12. S3에 새 훈련 데이터가 올라올 때마다 재훈련 파이프라인을 시작하려면 무엇을 켜고 어떤 규칙을 만드는가? *(→ 11), 14))*
13. 드리프트 기반 재훈련 체인을 설명할 때 주의할 점은? *(→ 14))*

---

## 🔭 MLA-C02에서 달라지는 것 {#c02-delta}

> C01과 C02의 차이는 공식 비교 페이지가 정본입니다. 아래는 **이 Task에 추가된 항목**이며 C01 시험 범위가 아닙니다.

- **C02 대응 Task**: 3.3 「MLOps 및 AI 워크로드를 위한 자동화된 오케스트레이션과 지속적 통합 및 지속적 전달(CI/CD) 파이프라인을 구현합니다」
- **추가된 항목 3개**
  - `3.3.7` **AI 에이전트 워크플로**를 오케스트레이션합니다.
  - `3.3.8` 생성형 AI 애플리케이션을 위한 **프롬프트 버전 관리와 배포 전략**을 구현합니다.
  - `3.3.9` **FM 맞춤화 워크플로**를 자동화합니다.
- **삭제된 항목**: 이 Task에는 없음
- 읽는 법: C01의 3.3이 "코드 → 모델 → 배포의 세 루프 자동화"였다면 C02는 거기에 **에이전트 워크플로·프롬프트 버전 관리·FM 맞춤화 자동화**를 더합니다. 2)~6)의 개발자 도구와 9)~10)의 Pipelines·Registry 구조는 그대로 쓰이고, 그 위에 생성형 AI 자산(프롬프트·에이전트)의 버전 관리가 올라옵니다.

출처: [MLA-C01 및 MLA-C02 비교 (한국어 공식)](https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-02/mla-02-comparison.html) · 조회일 2026-10-17

---

### 📌 출처

- CodePipeline: [CI와 CD의 정의](https://docs.aws.amazon.com/codepipeline/latest/userguide/concepts-continuous-delivery-integration.html) · [개념(스테이지·액션·실행 모드)](https://docs.aws.amazon.com/codepipeline/latest/userguide/concepts.html) · [파이프라인 유형 V1·V2](https://docs.aws.amazon.com/codepipeline/latest/userguide/pipeline-types-planning.html) · [파이프라인 시작 방법](https://docs.aws.amazon.com/codepipeline/latest/userguide/pipelines-about-starting.html) · [소스 액션과 변경 감지 방법](https://docs.aws.amazon.com/codepipeline/latest/userguide/change-detection-methods.html) · [CodeCommit 소스 액션 레퍼런스](https://docs.aws.amazon.com/codepipeline/latest/userguide/action-reference-CodeCommit.html) · [통합 목록](https://docs.aws.amazon.com/codepipeline/latest/userguide/integrations-action-type.html) · [일정으로 시작](https://docs.aws.amazon.com/codepipeline/latest/userguide/pipelines-trigger-source-schedule.html) · [할당량](https://docs.aws.amazon.com/codepipeline/latest/userguide/limits.html) · [문제 해결](https://docs.aws.amazon.com/codepipeline/latest/userguide/troubleshooting.html)
- CodeBuild: [buildspec 레퍼런스](https://docs.aws.amazon.com/codebuild/latest/userguide/build-spec-ref.html) · [컴퓨트 유형](https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-compute-types.html) · [빌드 캐싱](https://docs.aws.amazon.com/codebuild/latest/userguide/build-caching.html) · [테스트 리포트](https://docs.aws.amazon.com/codebuild/latest/userguide/test-reporting.html) · [문제 해결](https://docs.aws.amazon.com/codebuild/latest/userguide/troubleshooting.html) · [할당량](https://docs.aws.amazon.com/codebuild/latest/userguide/limits.html) · [What is AWS CodeBuild?](https://docs.aws.amazon.com/codebuild/latest/userguide/welcome.html)
- CodeDeploy: [What is CodeDeploy](https://docs.aws.amazon.com/codedeploy/latest/userguide/welcome.html) · [배포 구성](https://docs.aws.amazon.com/codedeploy/latest/userguide/deployment-configurations.html) · [AppSpec 파일](https://docs.aws.amazon.com/codedeploy/latest/userguide/application-specification-files.html) · [훅 구조](https://docs.aws.amazon.com/codedeploy/latest/userguide/reference-appspec-file-structure-hooks.html) · [롤백과 재배포](https://docs.aws.amazon.com/codedeploy/latest/userguide/deployments-rollback-and-redeploy.html) · [배포 단계](https://docs.aws.amazon.com/codedeploy/latest/userguide/deployment-steps-server.html) · [문제 해결](https://docs.aws.amazon.com/codedeploy/latest/userguide/troubleshooting-deployments.html) · [할당량](https://docs.aws.amazon.com/codedeploy/latest/userguide/limits.html) · [DevOps 배포 전략](https://docs.aws.amazon.com/whitepapers/latest/introduction-devops-aws/deployment-strategies.html)
- Git·브랜치: [버전 관리 개요](https://aws.amazon.com/what-is/repo/) · [병합 전략](https://docs.aws.amazon.com/help-panel/codecommit/latest/helppanel/pull-requests.merge.html) · [브랜치 전략 선택](https://docs.aws.amazon.com/prescriptive-guidance/latest/choosing-git-branch-approach/git-branching-strategies.html) · [Gitflow](https://docs.aws.amazon.com/prescriptive-guidance/latest/choosing-git-branch-approach/gitflow-branching-strategy.html) · [GitHub Flow](https://docs.aws.amazon.com/prescriptive-guidance/latest/choosing-git-branch-approach/git-hub-flow-branching-strategy.html) · [Trunk](https://docs.aws.amazon.com/prescriptive-guidance/latest/choosing-git-branch-approach/trunk-branching-strategy.html) · [CodeConnections 개명](https://docs.aws.amazon.com/dtconsole/latest/userguide/rename.html) · [CodeCommit 이력](https://docs.aws.amazon.com/codecommit/latest/userguide/history.html)
- SageMaker Pipelines: [Pipelines](https://docs.aws.amazon.com/sagemaker/latest/dg/pipelines.html) · [개요·DAG](https://docs.aws.amazon.com/sagemaker/latest/dg/pipelines-overview.html) · [단계 유형](https://docs.aws.amazon.com/sagemaker/latest/dg/build-and-manage-steps-types.html) · [파라미터](https://docs.aws.amazon.com/sagemaker/latest/dg/build-and-manage-parameters.html) · [단계 캐싱](https://docs.aws.amazon.com/sagemaker/latest/dg/pipelines-caching.html) · [재시도 정책](https://docs.aws.amazon.com/sagemaker/latest/dg/pipelines-retry-policy.html) · [EventBridge로 시작](https://docs.aws.amazon.com/sagemaker/latest/dg/pipeline-eventbridge.html) · [baseline 수명 주기](https://docs.aws.amazon.com/sagemaker/latest/dg/pipelines-quality-clarify-baseline-lifecycle.html)
- Projects·Registry: [SageMaker Projects](https://docs.aws.amazon.com/sagemaker/latest/dg/sagemaker-projects-whatis.html) · [제공 템플릿](https://docs.aws.amazon.com/sagemaker/latest/dg/sagemaker-projects-templates-sm.html) · [Model Registry](https://docs.aws.amazon.com/sagemaker/latest/dg/model-registry.html) · [승인 상태](https://docs.aws.amazon.com/sagemaker/latest/dg/model-registry-approve.html) · [SageMaker EventBridge 이벤트](https://docs.aws.amazon.com/sagemaker/latest/dg/automating-sagemaker-with-eventbridge.html)
- 수집 자동화·테스트: [S3 → EventBridge](https://docs.aws.amazon.com/AmazonS3/latest/userguide/EventBridge.html) · [Glue 워크플로](https://docs.aws.amazon.com/glue/latest/dg/workflows_overview.html) · [EventBridge 규칙과 Scheduler](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-rules.html) · [MLOPS04-BP01](https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/mlops04-bp01.html) · [MLREL04-BP01](https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/mlrel04-bp01.html) · [MLSUS06-BP02](https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/mlsus06-bp02.html) · [MLOps 체크리스트 — 지속적 통합](https://docs.aws.amazon.com/prescriptive-guidance/latest/mlops-checklist/continuous-integration.html) · [지속적 배포](https://docs.aws.amazon.com/prescriptive-guidance/latest/mlops-checklist/continuous-deployment.html)
- [MLA-C01 공식 시험 가이드 (한국어)](https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-01/machine-learning-engineer-associate-01.html)

조사 노트: `docs/content-research/MLA-C01/tasks/3-3.md` (모든 사실에 공식 URL·조회일 2026-10-17 부착)
