---
examGuideTaskId: dva-t3-3
certCode: DVA-C03
domain: 3
domainName: 테스트 및 배포
domainWeightPct: 22
title: CI/CD로 코드 배포 (패키징·컨테이너·IaC·CodeDeploy·CodePipeline·전략·롤백)
coversTasks:
  - "3.3"
sources:
  - title: What is CodeDeploy?
    url: https://docs.aws.amazon.com/codedeploy/latest/userguide/welcome.html
  - title: Working with deployment configurations in CodeDeploy
    url: https://docs.aws.amazon.com/codedeploy/latest/userguide/deployment-configurations.html
  - title: AppSpec 'hooks' section
    url: https://docs.aws.amazon.com/codedeploy/latest/userguide/reference-appspec-file-structure-hooks.html
  - title: Redeploy and roll back a deployment with CodeDeploy
    url: https://docs.aws.amazon.com/codedeploy/latest/userguide/deployments-rollback-and-redeploy.html
  - title: Deploy Amazon ECS services by replacing tasks
    url: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/deployment-type-ecs.html
  - title: AWS::ECS::Service DeploymentConfiguration (CloudFormation)
    url: https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/aws-properties-ecs-service-deploymentconfiguration.html
  - title: CodePipeline concepts
    url: https://docs.aws.amazon.com/codepipeline/latest/userguide/concepts.html
  - title: Understand update behaviors of stack resources (CloudFormation)
    url: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-updating-stacks-update-behaviors.html
  - title: DVA-C03 공식 시험 가이드 · 콘텐츠 도메인 3 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/developer-associate-03/developer-associate-03-domain3.html
lastVerified: 2026-11-01
---

# CI/CD로 코드 배포 (패키징·컨테이너·IaC·CodeDeploy·CodePipeline·전략·롤백)

> **커버하는 공식 Task** — DVA-C03 · 도메인 3 「테스트 및 배포」(22%) · **작업 3.3 AWS 지속적 통합 및 지속적 전달(CI/CD) 서비스를 사용하여 코드를 배포합니다** (`dva-t3-3`)
> 이 문서는 위 한 작업에 1:1로 매핑되고, 공식 기술 아홉 개(3.3.1~3.3.9)를 모두 덮습니다. 도메인 3에서 **가장 기술이 많은 작업**입니다.

> ⚠️ **C03에서 둘이 신설됐습니다** — **기술 3.3.2 컨테이너 오케스트레이션 배포**(ECS 작업 정의 · EKS 매니페스트 · Fargate 시작 유형 · 순차 업데이트)와 **기술 3.3.9 AI 도구로 CI/CD 지원**(배포 승인 자동화 · 환경 프로비저닝 · 배포 후 검증). 그리고 **소스 제어로 버전·릴리스 관리**가 C02의 Task 3.4에서 이 작업으로 왔습니다.

---

## ✅ 학습 목표 체크리스트

- [ ] Lambda 패키징 세 형태를 **배포 단위로서** 구분한다
- [ ] ECS 롤링 업데이트를 **배포 유형 × 시작 유형**으로 이해한다
- [ ] EKS 매니페스트 배포가 ECS와 **모델이 다르다**는 것을 설명한다
- [ ] CodeDeploy의 **플랫폼 3종과 훅**을 구분하고 AppSpec 위치 규칙을 안다
- [ ] CodePipeline의 **단계·작업·아티팩트**와 변경 감지 방식을 안다
- [ ] 배포 전략(all-at-once·롤링·블루/그린·카나리·선형)을 **서비스별 구현**과 잇는다
- [ ] 롤백 방식이 **"되감기"가 아니라 "재배포 또는 트래픽 전환"**임을 구분한다
- [ ] 불변 식별자(버전·다이제스트)와 가변 참조(태그·`$LATEST`)로 릴리스를 관리한다

---

## 🎯 왜 중요한가

배포 문항은 **"무엇이 교체되고, 실패하면 무엇이 남는가"**를 묻습니다. 그래서 전략 이름을 외우는 것보다 **되돌리는 방법**을 기준으로 묶는 것이 빠릅니다 — in-place는 **이전 리비전을 새 배포로 다시 내보내고**(부수 효과가 남을 수 있습니다), 블루/그린은 **옛 환경을 살려 둔 채 트래픽만 돌립니다**(그래서 되돌림이 단순합니다).

그리고 C03에서 컨테이너가 들어오면서 **배포 유형과 시작 유형을 함께 보는 습관**이 필요해졌습니다. 같은 파라미터가 **롤링에서는 쓰이고 블루/그린 + Fargate에서는 쓰이지 않는** 경우가 있어서입니다.

---

## ⚡ 시험 직전 요약

> 시험 직전에 이 열 줄만 다시 봅니다. 근거와 맥락은 아래 본문에 있습니다.

- **CodeDeploy 플랫폼 3종**: EC2·온프레미스 / Lambda / ECS. ⚠️ **Lambda·ECS 배포는 항상 블루/그린**이고 **in-place는 EC2·온프레미스 전용**입니다
- ⚠️ **`appspec.yml`은 리비전 루트**여야 하고(아니면 실패) **Lambda·ECS의 리비전은 AppSpec 파일 자체**입니다
- **훅**: Lambda는 **`BeforeAllowTraffic`·`AfterAllowTraffic`**(검증 함수가 **`putLifecycleEventHookExecutionStatus`**로 통지, **1시간** 안에 없으면 실패) · ECS는 ⚠️ **`BeforeInstall`에서는 롤백 불가** · EC2의 **`ApplicationStop`은 첫 배포에서 실행되지 않습니다**
- **ECS 롤링**: `minimumHealthyPercent`(**기본 100%**, 올림)·`maximumPercent`(**기본 200%**, 내림). ⚠️ **"Fargate에서는 최소 정상 비율이 무시된다"는 과도한 일반화**입니다 — **`CODE_DEPLOY`·`EXTERNAL` 배포 유형 + Fargate**일 때만 쓰이지 않습니다
- **ECS 실패 감지 둘**: **배포 회로 차단기**(작업이 시작되지 못할 때, ⚠️ **롤링 전용**)와 **CloudWatch 경보**(애플리케이션 지표). 함께 쓰면 **먼저 충족한 쪽**이 실패 처리하고 둘 다 **이전 서비스 리비전으로 롤백**합니다
- **EKS는 작업 정의가 없습니다** — `kind: Deployment`·`Service` **매니페스트를 `kubectl apply -f`**로 적용하고, ⚠️ **Fargate는 시작 유형이 아니라 네임스페이스로 고르는 Fargate 프로필**입니다
- **CodePipeline**: 파이프라인 = **단계**, 단계 = **작업**(`source`·`build`·`test`·`deploy`·`approval`·`invoke` **6종**). 작업 사이 산출물은 **아티팩트 버킷**을 거칩니다. ⚠️ **수동 승인은 7일** 안에 응답이 없으면 실패입니다
- **변경 감지**: S3·ECR은 **EventBridge**(폴링 비권장), 외부 Git은 **연결(connection)**이 관리합니다. ⚠️ **소스 작업당 트리거는 1개**입니다
- **롤백은 되감기가 아닙니다** — CodeDeploy는 **이전 리비전을 새 배포(새 배포 ID)로** 다시 내보내므로 ⚠️ EC2 in-place에서는 **스크립트가 만든 부수 효과가 남습니다**
- **릴리스 관리는 불변 식별자로** — **게시 버전·다이제스트는 불변**, **태그·`$LATEST`는 가변**입니다. ECS는 ⭐ **`versionConsistency`로 태그를 다이제스트로 해석**해 서비스의 모든 작업이 같은 이미지를 씁니다

---

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **리비전(revision)** | CodeDeploy가 배포하는 단위. EC2는 번들, **Lambda·ECS는 AppSpec 파일 자체** |
| **배포 구성(deployment configuration)** | 트래픽을 어떤 속도로 옮길지 정한 규칙(`CodeDeployDefault.` 접두의 사전 정의본) |
| **작업 세트(task set)** | ECS에서 CodeDeploy 블루/그린이 만드는 작업 묶음. 전환 후 원래 세트를 종료한다 |
| **배포 회로 차단기** | ECS 롤링에서 **작업이 시작되지 못할 때** 배포를 실패 처리하는 기능 |
| **bake time** | 전환 후 **옛 리비전을 살려 두고 감시하는 시간**. 그 사이 롤백이 빠르다 |
| **아티팩트 버킷** | CodePipeline 작업 사이의 산출물이 지나가는 S3 버킷 |
| **`versionConsistency`** | ECS가 이미지 태그를 **다이제스트로 해석**해 서비스 전체를 같은 이미지로 고정하는 동작 |
| **단계 조건(stage conditions)** | V2 파이프라인에서 단계 진입·종료를 규칙으로 통제하는 기능 |

---

## 📖 핵심 개념

### 1) Lambda 패키징과 배포 (기술 3.3.1) {#lambda-packaging}

공식 문구는 "**Lambda 배포 패키징 방법**을 사용하여 배포 효율성을 최적화합니다(예: `.zip` 파일, 컨테이너 이미지, 계층)"입니다. 세 형태의 **한도와 제약**은 `dva-t3-1` 1~2절이 정본이고, 여기서는 **배포 관점**만 봅니다.

- **게시 버전은 불변 스냅샷**이고 `$LATEST`만 바뀝니다. 번호는 **재사용되지 않습니다.**
- **별칭**은 버전을 가리키는 포인터이고, **가중 별칭**(최대 2개 게시 버전)이 **카나리 배포의 기반**입니다 — CodeDeploy와 SAM의 점진 배포가 모두 이 기능 위에서 동작합니다.

| 방법 | 자동 롤백 | 사전·사후 검증 |
|---|---|---|
| 가중 별칭 직접 조작 | ⚠️ **없음** — `update-alias`로 직접 되돌린다 | 직접 구현 |
| **SAM `DeploymentPreference`** | 경보·훅 실패 시 **CodeDeploy가 롤백** | `Hooks`의 `PreTraffic`·`PostTraffic` |
| CodeDeploy 직접 | 배포 그룹의 자동 롤백 설정 | AppSpec `hooks` |
| CodePipeline Lambda 배포 작업 | 경보(**최대 10개**)가 `ALARM`이면 작업 실패 | — |

- ⚠️ CodePipeline Lambda 배포 작업의 **`FunctionAlias`는 작업 시작 시 이미 존재하고 버전이 하나 있어야** 합니다(롤백 대상). 생략하면 `$LATEST`에 배포하고 새 버전을 만듭니다.

> 🧠 **원리** — Lambda의 점진 배포는 전부 **"게시 버전(불변) + 별칭(포인터) + 가중치"** 조합입니다. 그래서 CodeDeploy·SAM·CodePipeline은 **같은 기반 기능에 자동화와 검증을 덧붙인 것**이고, 수동으로 `update-alias`를 쓰면 그 자동 롤백만 없어집니다.

### 2) 컨테이너 오케스트레이션 배포 (기술 3.3.2) {#containers}

🆕 **C03 신설 기술**입니다. 공식 예시는 **ECS 작업 정의 · EKS 매니페스트 · Fargate 시작 유형 · 순차(롤링) 업데이트**입니다.

**ECS 롤링 업데이트**

| 파라미터 | 뜻 | 기본값 |
|---|---|---|
| **`minimumHealthyPercent`** | 배포 중 `RUNNING`을 유지해야 하는 최소 비율(**올림**) | replica **100%** (⚠️ `DAEMON`은 CLI·SDK·API **0%** / 콘솔 **50%**) |
| **`maximumPercent`** | 원하는 개수 위로 추가 실행할 수 있는 상한(**내림**) | replica **200%** |

- 최소 정상 작업 수 = **`desiredCount` × 비율/100을 올림**합니다. 무중단 롤링 권장값은 **100 / 200**입니다.
- ⚠️ **"Fargate에서는 `minimumHealthyPercent`가 쓰이지 않는다"는 과도한 일반화입니다.** 정본은 **"`CODE_DEPLOY`(블루/그린) 또는 `EXTERNAL` 배포 유형 + Fargate 시작 유형"**일 때 쓰이지 않는다고 적습니다(describe 응답에는 값이 그대로 돌아옵니다). **롤링 업데이트(`ECS`) 배포 유형에서는 Fargate에서도 쓰입니다.**
- ⚠️ **`CODE_DEPLOY`·`EXTERNAL` + EC2에서는 사용자 지정 값을 지정할 수 없습니다**(기본값으로 설정되어 `DRAINING` 중 하한으로 쓰입니다).
- **실패 감지 둘**: **배포 회로 차단기**(작업이 시작되지 못할 때. ⚠️ **롤링 전용**)와 **CloudWatch 경보**(애플리케이션 지표). 함께 쓰면 **먼저 충족한 쪽**이 실패로 처리하고 둘 다 **이전 서비스 리비전으로 롤백**할 수 있습니다.
- ⚠️ **ECS는 배포를 관리하지만 트래픽 라우팅은 하지 않습니다** — 로드 밸런서를 쓰면 라우팅을 따로 구성합니다.
- 작업이 교체되는 경우는 둘입니다 — **`UpdateService`로 새 배포가 시작될 때**, **활성 배포 안의 작업이 비정상이 될 때**.
- ⭐ 이미지 태그는 기본으로 **다이제스트로 해석**되어(**`versionConsistency`**) 서비스의 **모든 작업이 같은 이미지**를 씁니다.

**EKS 매니페스트 배포 — 모델이 다릅니다**

- ⚠️ **EKS에는 "작업 정의"가 없습니다.** **Kubernetes 매니페스트**(YAML)를 클러스터에 적용합니다 — 배포 단위는 `apiVersion: apps/v1`·**`kind: Deployment`**이고 노출은 **`kind: Service`**이며, 적용은 **`kubectl apply -f <파일>`**입니다.
- `Deployment`의 **`spec.replicas`·`selector.matchLabels`·`template`**이 ECS 서비스의 원하는 개수·작업 정의 자리에 해당합니다.
- `Service`에 **주석(annotation)**으로 AWS 로드 밸런서를 지정합니다(예: `service.beta.kubernetes.io/aws-load-balancer-type: nlb`).
- IaC로는 CDK의 **`KubernetesManifest`**나 `cluster.addManifest`를 씁니다.
- ⚠️ **EKS의 Fargate는 ECS와 지정 방식이 다릅니다** — ECS는 서비스·작업의 **시작 유형**이지만 EKS는 **Fargate 프로필**을 만들어 **네임스페이스**(+선택적 레이블)로 고릅니다. 프로필 생성에는 **네임스페이스가 필수**이고 와일드카드를 쓸 수 있습니다.
- ⚠️ **AWS Load Balancer Controller를 쓸 때 대상 파드가 Fargate에 있으면 대상 유형을 `IP`로** 해야 하고, ingress·service 객체가 있는 **네임스페이스에 Fargate 프로필이 있어야** 합니다.

> 🧠 **원리** — ECS는 **"서비스가 작업 정의를 돌린다"**는 AWS 모델이고 EKS는 **"컨트롤러가 선언된 매니페스트를 수렴시킨다"**는 Kubernetes 모델입니다. 그래서 같은 단어(배포·Fargate)가 서로 다른 것을 가리키고, 그 차이가 그대로 문항이 됩니다.

### 3) IaC 템플릿 (기술 3.3.3) {#iac}

- **SAM은 CloudFormation의 확장**입니다 — `Transform: AWS::Serverless-2016-10-31`이 필수이고, SAM 리소스는 배포 시 **CloudFormation 리소스로 변환**됩니다. 그래서 `Parameters`·`Mappings`·`Conditions`를 그대로 씁니다(`Globals`와 `Transform`만 SAM 전용).
- **`sam deploy`는 변경 세트를 만들어** 배포하고, `--capabilities`(IAM 리소스는 `CAPABILITY_IAM`·이름 지정 시 **`CAPABILITY_NAMED_IAM`**·중첩 앱은 `CAPABILITY_AUTO_EXPAND`)가 빠지면 **`InsufficientCapabilities`** 오류가 납니다.
- **업데이트 동작 3종**: **중단 없음**(물리 ID 유지) · **일부 중단** · ⚠️ **교체**(새 리소스 생성 → 참조 이동 → 이전 삭제, **새 물리 ID**).
- ⚠️ **`UpdateReplacePolicy`는 교체될 때**, **`DeletionPolicy`는 삭제될 때** 적용됩니다.
- ⚠️ 업데이트 실패 후 **롤백까지 실패하면 `UPDATE_ROLLBACK_FAILED`**가 되어 그 스택은 업데이트할 수 없고, 오류를 고친 뒤 **`ContinueUpdateRollback`**으로 되돌립니다.
- 환경별 주입은 CodePipeline **CloudFormation 작업의 `TemplateConfiguration`·`ParameterOverrides`**로도 합니다.

> 🧠 **원리** — IaC 배포의 위험은 거의 전부 **교체**에서 나옵니다. 그래서 파이프라인에서도 **변경 세트를 만들고(`CHANGE_SET_REPLACE`) 승인 뒤 실행(`CHANGE_SET_EXECUTE`)**하는 두 단계 패턴이 흔하고, 데이터 리소스에는 `UpdateReplacePolicy`를 붙입니다.

### 4) CodeDeploy — 플랫폼·AppSpec·훅 (기술 3.3.4) {#codedeploy}

**플랫폼 3종**: EC2·온프레미스 / Lambda / ECS. ⚠️ **배포 유형은 in-place와 블루/그린**이고 **Lambda·ECS는 항상 블루/그린**입니다(in-place는 EC2·온프레미스 전용, EC2 블루/그린은 **EC2 인스턴스만** 되고 온프레미스는 불가).

- **EC2·온프레미스**는 인스턴스의 **CodeDeploy 에이전트**가 CodeDeploy를 폴링해 S3·GitHub의 리비전을 가져와 AppSpec대로 배포합니다(블루/그린 요건으로 **에이전트 실행과 IAM 인스턴스 프로파일**이 명시됩니다).
- **AppSpec**: EC2·온프레미스는 ⚠️ **`appspec.yml`을 리비전 루트**에 두고(아니면 실패) 구조는 `version`(**0.0 고정**)·`os`·`files`·`permissions`·`hooks`입니다. Lambda·ECS는 **`Resources` 섹션 + `hooks`**이고 ⚠️ **리비전이 AppSpec 파일 자체**입니다.

| 플랫폼 | 훅 | 메모 |
|---|---|---|
| **EC2·온프레미스** | `ApplicationStop` → (`DownloadBundle`) → `BeforeInstall` → (`Install`) → `AfterInstall` → `ApplicationStart` → `ValidateService` (+로드 밸런서 사용 시 `Before/AfterBlockTraffic`·`Before/AfterAllowTraffic`) | 괄호는 에이전트 예약. ⚠️ **`ApplicationStop`은 이전 성공 리비전의 스크립트를 쓰므로 첫 배포에서는 실행되지 않는다.** 훅 `timeout` 기본 **3600초** |
| **Lambda** | **`BeforeAllowTraffic`·`AfterAllowTraffic`**(각 검증 함수 1개, 배포당 1회) | ⚠️ 검증 함수가 **`putLifecycleEventHookExecutionStatus`**로 Succeeded·Failed를 알려야 하고 **1시간** 안에 통지가 없으면 배포 실패 |
| **ECS** | `BeforeInstall`·`AfterInstall`·**`AfterAllowTestTraffic`**·`BeforeAllowTraffic`·`AfterAllowTraffic` | ⚠️ **`BeforeInstall` 시점에는 롤백 불가**, 나머지 훅 결과는 롤백을 유발할 수 있다 |

- **ECS용 CodeDeploy**: AppSpec에 **작업 정의 전체 ARN**과 컨테이너 이름·포트를 적고, ALB 또는 NLB에 **프로덕션 리스너(+선택적 테스트 리스너)**와 대상 그룹이 필요합니다. **새 작업 세트**로 트래픽을 옮기고 성공하면 원래 세트를 종료합니다.
- **배포 그룹의 모니터링·롤백**: CloudWatch 경보 **최대 10개**, SNS 알림, 자동 롤백 **두 조건**(배포 실패 시 / 경보 임계 충족 시), 경보 상태를 못 읽을 때 계속할지 선택(`ignorePollAlarmFailure`).

> 🧠 **원리** — CodeDeploy는 **"리비전을 어디에 어떻게 올릴지"**만 관리하고 검증은 **훅에 위임**합니다. 그래서 Lambda·ECS에서는 훅이 곧 품질 게이트이고, 훅이 통지하지 않으면(1시간) 배포가 실패하는 설계가 됩니다.

### 5) CodePipeline — 오케스트레이션 (기술 3.3.5) {#codepipeline}

- **구조**: 파이프라인 = **단계(stage)**, 단계 = **직렬·병렬 작업(action)**. 작업 유형은 **`source`·`build`·`test`·`deploy`·`approval`·`invoke` 6가지**이고, 작업 사이 산출물은 **아티팩트 버킷**을 거칩니다. 소스 리비전은 Git이면 **커밋**, S3면 **객체 버전**입니다.
- **변경 감지**: S3·ECR은 **EventBridge**(폴링은 비권장), **외부 Git은 연결(connection)이 관리**해 웹훅·폴링 설정이 필요 없습니다. ⚠️ **소스 작업당 트리거는 1개**이고, 그 밖에 수동 시작·일정·리비전 재지정·**단계 롤백 트리거**가 있습니다.
- **V2 트리거 필터**: push는 **Git 태그·브랜치·파일 경로**, 풀 리퀘스트는 **이벤트(opened·updated·closed)·브랜치·파일 경로**로 필터합니다.
- **단계는 한 번에 하나의 실행만** 처리하고(잠금), 기본 실행 모드 **`SUPERSEDED`**에서는 새 실행이 **대기 중 실행을 대체**합니다(다른 모드: `QUEUED`·`PARALLEL`).
- **수동 승인 작업**: 파이프라인이 멈추고 같은 리전의 **SNS 주제**로 알림·검토 URL을 보냅니다. ⚠️ **거부하거나 7일 안에 응답이 없으면 실패**입니다.
- **CodeBuild `buildspec`**: 기본은 소스 루트의 `buildspec.yml`(프로젝트당 1개). 구조는 `version`(**0.2 권장**)·`env`·`phases`·`reports`·`artifacts`·`cache`이고 phase는 **`install`·`pre_build`·`build`·`post_build`**입니다. phase마다 **`on-failure`**(`ABORT`·`CONTINUE`)와 **`finally`**(앞 명령이 실패해도 실행)가 있습니다. ⚠️ 같은 환경 변수가 여러 곳에 있으면 **`StartBuild` 호출 > 프로젝트 정의 > buildspec** 순으로 우선합니다.
- `env`의 **`parameter-store`**를 쓰면 서비스 역할에 **`ssm:GetParameters`**가 필요하고, **`secrets-manager`**·`exported-variables`도 있습니다.

> 🧠 **원리** — **단계가 환경 경계**입니다. 단계가 한 번에 하나의 실행만 처리하므로 "dev 통과 → 승인 → prod" 같은 **순차 승격이 파이프라인 구조로 표현**되고, 그 경계에서 **승인·조건·롤백**을 걸 수 있습니다.

### 6) 배포 전략 (기술 3.3.6) {#strategies}

| 전략 | 정의 | 서비스별 구현 |
|---|---|---|
| **All-at-once** | 전체를 한 번에 교체(짧은 중단 가능) | Beanstalk `AllAtOnce`(환경 기본) · CodeDeploy EC2 `AllAtOnce` · Lambda·ECS `AllAtOnce` |
| **롤링 / in-place** | 배치 단위로 기존 인스턴스에 순차 배포 | Beanstalk `Rolling` · CodeDeploy EC2 in-place(`OneAtATime`·`HalfAtATime`) · **ECS 롤링** |
| 추가 배치 롤링 | 먼저 새 배치를 띄워 **용량 유지** | Beanstalk `RollingWithAdditionalBatch` |
| Immutable | **새 Auto Scaling 그룹**에 새 인스턴스 전체 | Beanstalk `Immutable` |
| **블루/그린** | 새 환경을 병렬로 만들고 **트래픽만 전환** | CodeDeploy(EC2는 대체 인스턴스, **Lambda·ECS는 항상**) · **ECS 내장** · Beanstalk **CNAME 교체** |
| **카나리** | 소량 먼저 → 대기 → 나머지 일괄 | CodeDeploy Lambda·ECS · SAM · **Lambda 가중 별칭** · API Gateway 스테이지 카나리 · Beanstalk 트래픽 분할 · ECS 내장 |
| **선형(linear)** | 같은 비율을 같은 간격으로 반복 | CodeDeploy Lambda·ECS · SAM · ECS 내장 |

**사전 정의 배포 구성**(`CodeDeployDefault.` 접두)

| 플랫폼 | 값 |
|---|---|
| EC2·온프레미스 | `AllAtOnce` · `HalfAtATime` · **`OneAtATime`(미지정 시 기본)** |
| Lambda | `LambdaCanary10Percent5/10/15/30Minutes` · `LambdaLinear10PercentEvery1/2/3/10Minutes` · `LambdaAllAtOnce` |
| ECS | `ECSCanary10Percent5/15Minutes` · `ECSLinear10PercentEvery1/3Minutes` · ⚠️ **`ECSAllAtOnce`**(Network Load Balancer는 **이것만 지원**) |

- SAM의 **`DeploymentPreference.Type`**은 같은 이름 체계를 씁니다(`Canary10Percent5Minutes`·`Linear10PercentEvery1Minute`·`AllAtOnce`).
- **ECS 내장 블루/그린**: green 서비스 리비전을 병렬로 띄워 **테스트 트래픽으로 검증**한 뒤 전환하고, ⭐ **bake time 동안 blue를 유지**해 빠르게 롤백합니다. 수명 주기 훅으로 **Lambda 훅과 일시 중지(pause) 훅**이 있고, ⚠️ **배포 중 자원 사용이 일시적으로 2배**가 될 수 있습니다. ECS 개발자 가이드의 CodeDeploy 방식 페이지는 첫머리에서 **내장 블루/그린 사용을 권장**합니다.
- CloudFormation의 `AWS::ECS::Service`에는 **`Strategy`**(`ROLLING`·`BLUE_GREEN`·`LINEAR`·`CANARY`)와 **`BakeTimeInMinutes`**(⚠️ 블루/그린·선형·카나리는 **기본 15분**, **롤링은 기본 없음**), `LifecycleHooks`, `EarlySuccessCriteria`가 있고 ⚠️ **`DeploymentCircuitBreaker`는 롤링 전용**입니다.

> 🧠 **원리** — 전략은 **"옛 것을 언제 버리는가"**로 갈립니다. in-place는 **즉시 덮어쓰고**, 블루/그린은 **전환 후에도 잠시 살려 두며**(bake time), 카나리·선형은 **조금씩 옮깁니다.** 그래서 **롤백 비용이 전략 선택의 핵심 기준**입니다.

### 7) 롤백 — 되감기가 아니다 (기술 3.3.7) {#rollback}

| 대상 | 롤백 방식 |
|---|---|
| **CodeDeploy 공통** | ⚠️ **이전에 배포한 리비전을 새 배포(새 배포 ID)로 재배포**한다. 자동(배포 실패·경보)·수동 |
| CodeDeploy EC2 **in-place** | 직전 성공 설치가 만든 파일을 정리한 뒤 재배포. ⚠️ **스크립트가 만든 파일은 되돌리지 않는다** |
| CodeDeploy EC2 **블루/그린** | 원래 인스턴스가 종료 전이면 **트래픽을 되돌려** 더 빠르고 안정적 |
| CodeDeploy Lambda·ECS | 훅 실패나 경보로 롤백. ⚠️ ECS **`BeforeInstall`에서는 불가** |
| **ECS 롤링** | **회로 차단기·경보**가 **이전 서비스 리비전**으로 롤백 |
| **ECS 내장 블루/그린** | **bake time 동안 blue 유지** → 다운타임 없는 롤백 |
| Beanstalk | 정책별로 수동 재배포 / 새 인스턴스 종료 / 트래픽 복귀 / **URL 교체** |
| **Lambda 별칭** | 별칭을 **이전 버전으로** 되돌린다 |
| **API Gateway** | **이전 배포를 다시 활성화**하고 카나리는 **끈다** |
| **CloudFormation** | 실패 시 롤백 · `UPDATE_ROLLBACK_FAILED` → **`ContinueUpdateRollback`** · 롤백 트리거(경보) |
| **CodePipeline(V2)** | 단계를 **이전의 성공 실행으로** 롤백(수동·자동). ⚠️ 자동 롤백은 **현재 파이프라인 구조 버전에서 시작된 성공 실행**이 있어야 한다 |

> 🧠 **원리** — CodeDeploy는 롤백을 **상태 되감기가 아니라 "이전 리비전을 새 배포로 다시 내보내는 것"**으로 구현합니다. 그래서 EC2 in-place에서는 **스크립트의 부수 효과가 남습니다.** 반대로 블루/그린·bake time·URL 교체는 **옛 것을 살려 둔 채 트래픽만 돌리므로** 되돌림이 단순합니다 — 이 차이가 "안전한 롤백"을 요구하는 문항의 정답을 정합니다.

### 8) 소스 제어로 버전·릴리스 관리 (기술 3.3.8) {#source-control}

공식 문구는 "**소스 제어 기능**을 사용하여 애플리케이션 버전 및 릴리스를 관리합니다(예: **레이블**, 브랜치)"입니다.

- **Git 브랜치·태그 → 배포**: V2 파이프라인은 **Git 태그·브랜치·파일 경로**로 시작을 필터하고, CodeBuild 웹훅은 **`HEAD_REF`·`BASE_REF`**(예: `^refs/heads/main$`)·이벤트로 필터하며 **`excludeMatchedPattern`**으로 태그 이벤트를 제외할 수 있습니다.
- **Amplify Hosting**은 브랜치를 연결할 때마다 **새 배포**를 만들고(main=운영·develop=통합), **패턴 기반 기능 브랜치 배포**를 지원합니다.
- **컨테이너 이미지 태그**: ECR 태그 불변성을 켜면 같은 태그로 푸시할 때 ⚠️ **`ImageTagAlreadyExistsException`**이 납니다. ⚠️ **`latest`처럼 덮어써지는 태그보다 커밋 해시 같은 서술적 태그**가 낫고, **Lambda·ECS는 태그를 다이제스트로 해석**해 고정합니다.
- **Lambda**: 새 코드마다 **버전을 게시하고 별칭을 옮겨** 릴리스합니다(SAM **`AutoPublishAlias`**가 자동화).
- **Elastic Beanstalk**: **애플리케이션 버전 = 라벨이 붙은 배포 가능한 반복**(소스 번들은 S3). 수명 주기 정책으로 개수·기간을 정해 정리하되 ⚠️ **S3 소스 번들은 자동 삭제되지 않습니다.**

> 🧠 **원리** — **태그와 `$LATEST`는 덮어쓸 수 있는 가변 참조**이고 **버전 번호와 다이제스트는 불변 식별자**입니다. 추적·롤백이 필요한 릴리스는 **불변 식별자를 기준으로** 배포해야 "그때 돌던 그것"을 다시 세울 수 있습니다.

### 9) AI 도구로 CI/CD 지원 (기술 3.3.9) {#ai-cicd}

🆕 **C03 신설 기술**입니다. 공식 문구는 "**AWS AI 도구**를 사용하여 CI/CD 워크플로를 지원합니다(예: **자동화된 배포 승인**, 환경 프로비저닝, **배포 후 유효성 확인**)"입니다.

⚠️ **기술 문구가 서비스를 명시하지 않습니다.** 범위 내 ML/AI 넷(**Bedrock · Bedrock AgentCore · Amazon Quick · Kiro**) 중 개발·배포 워크플로에 해당하는 것은 **Kiro**이고, 배포 후 **오류 분석·조사** 쪽은 **CloudWatch의 생성형 AI 기능**입니다.

- **Kiro Hooks** — 커밋·저장 같은 **이벤트에 걸리는 자동 트리거**로 표준을 강제하고 테스트를 실행합니다(기술 3.2.5와 같은 기능이 CI/CD 쪽에서 쓰이는 것입니다).
- **CloudWatch 자연어 쿼리 생성** — 배포 후 검증·조사에서 Logs Insights·Metrics Insights 쿼리를 평문 설명에서 만들어 줍니다. ⚠️ 권한은 `CloudWatchLogsFullAccess`·`CloudWatchLogsReadOnlyAccess` 같은 정책이거나 **`cloudwatch:GenerateQuery`**가 필요합니다.
- ⚠️ **"어떤 AWS AI 서비스가 배포를 자동 승인해 주는가"처럼 단일 서비스를 고르게 하는 문항은 공식 근거가 없습니다** — 확인된 사실(권한 이름·기능 범위)을 묻는 쪽이 정확합니다.
- ⚠️ 범위 신호: **`Amazon Q Developer`**(범위 내 목록에 없고 IDE 플러그인은 2027-04-30 지원 종료) · **`Amazon Quick`**(개발 도구가 아니고 **Quick Sight는 범위 밖**).

> 🧠 **원리** — AI 기술 네 개(1.1.9 개발 · 3.2.5 테스트 · 3.3.9 CI/CD · 4.1.5 오류 분석)는 **같은 도구가 수명 주기의 다른 단계에 붙은 것**입니다. 그래서 "무엇을 쓰는가"보다 **"어느 단계를 자동화하는가"**로 읽으면 네 기술이 한 틀에 들어옵니다.

---

## ✍️ 시험 포인트

- **"Lambda를 10%씩 10분마다"** → CodeDeploy **`LambdaLinear10PercentEvery10Minutes`** 또는 SAM `DeploymentPreference`. 기반은 **가중 별칭**입니다.
- **"NLB를 쓰는 ECS 블루/그린"** → CodeDeploy 쪽은 ⚠️ **`ECSAllAtOnce`만** 지원합니다.
- **"ECS 배포가 실패했는데 자동으로 되돌리고 싶다"** → **배포 회로 차단기**(작업이 안 뜰 때, 롤링 전용) + **CloudWatch 경보**(지표). 둘 다 **이전 서비스 리비전**으로 돌립니다.
- **"Fargate이므로 최소 정상 비율이 무시된다"** → ⚠️ **배포 유형을 먼저 봅니다.** 롤링이면 **쓰입니다.**
- **"EKS에 배포"** → 작업 정의가 아니라 **매니페스트 + `kubectl apply`**, Fargate는 **프로필 + 네임스페이스**.
- **"첫 배포인데 `ApplicationStop` 스크립트가 안 돌았다"** → 정상입니다. **이전 성공 리비전의 스크립트**를 쓰기 때문입니다.
- **"Lambda 검증 함수를 붙였는데 배포가 1시간 뒤 실패"** → **`putLifecycleEventHookExecutionStatus`** 통지를 빼먹은 것입니다.
- **"승인 단계에서 멈춘 채 방치"** → **7일**이면 실패 처리됩니다.
- **"롤백했는데 스크립트가 만든 파일이 남아 있다"** → CodeDeploy 롤백은 **이전 리비전의 재배포**이고 되감기가 아닙니다.
- **"릴리스를 추적·롤백해야 한다"** → **불변 식별자**(게시 버전·다이제스트)를 기준으로 배포합니다.

---

## ⚠️ 흔한 함정 {#pitfalls}

| 함정 | 바로잡기 |
|---|---|
| Lambda·ECS에 in-place 배포가 있다고 본다 | ⚠️ **항상 블루/그린**이다(in-place는 EC2·온프레미스 전용) |
| `appspec.yml`을 하위 폴더에 둔다 | **리비전 루트**가 아니면 배포 실패 |
| Lambda·ECS 리비전을 번들로 본다 | **AppSpec 파일 자체**가 리비전이다 |
| ECS `BeforeInstall` 훅에서 롤백을 기대한다 | **그 시점에는 롤백할 수 없다** |
| Lambda 훅에서 통지를 생략한다 | **`putLifecycleEventHookExecutionStatus`**가 없으면 1시간 뒤 실패 |
| "Fargate면 `minimumHealthyPercent` 무시"로 외운다 | ⚠️ **`CODE_DEPLOY`·`EXTERNAL` + Fargate**일 때만 — 롤링에서는 쓰인다 |
| 회로 차단기를 블루/그린에도 쓸 수 있다고 본다 | ⚠️ **롤링(`ECS`) 전용**이다 |
| ECS가 트래픽 라우팅까지 한다고 본다 | **배포만** 관리한다 — 라우팅은 로드 밸런서 구성 |
| EKS에 작업 정의를 만들려 한다 | **매니페스트**(`Deployment`·`Service`)를 적용한다 |
| EKS Fargate를 시작 유형으로 지정하려 한다 | **Fargate 프로필 + 네임스페이스**로 고른다 |
| NLB에 ECS 카나리·선형 CodeDeploy 구성을 쓴다 | **`ECSAllAtOnce`만** 지원한다 |
| 소스 작업에 트리거를 여러 개 붙인다 | **소스 작업당 1개**다 |
| 승인 작업을 무기한 대기로 본다 | **7일**이면 실패 |
| CodeDeploy 롤백이 상태를 되감는다고 본다 | **이전 리비전을 새 배포로** 내보낸다(부수 효과가 남을 수 있다) |
| `latest` 태그로 릴리스를 추적하려 한다 | 태그는 **가변 참조**다 — 다이제스트·버전 번호로 고정 |
| Beanstalk 애플리케이션 버전을 정리하면 S3도 비워진다고 본다 | ⚠️ **S3 소스 번들은 자동 삭제되지 않는다** |
| 기술 3.3.9에서 단일 "AI 배포 승인 서비스"를 고른다 | **공식 근거가 없다** — 확인된 사실(예: `cloudwatch:GenerateQuery`)을 본다 |

---

## 🧪 자가 점검

**Q1.** ECS 서비스를 Fargate로 돌리는데 "Fargate라서 `minimumHealthyPercent`가 무시된다"는 말을 들었다. 사실인가? 기본값은? (→ 2) 컨테이너)

<details><summary>정답 보기</summary>

⚠️ **과도한 일반화입니다.** 정본은 **"`CODE_DEPLOY`(블루/그린) 또는 `EXTERNAL` 배포 유형이고 작업이 Fargate 시작 유형일 때"** 최소 정상 비율이 쓰이지 않는다고 적습니다(describe 응답에는 값이 그대로 돌아옵니다). **롤링 업데이트(`ECS`) 배포 유형에서는 Fargate에서도 쓰입니다.**

기본값은 replica 서비스가 **`minimumHealthyPercent` 100% · `maximumPercent` 200%**이고, `DAEMON`은 **CLI·SDK·API에서 0% / 콘솔에서 50%**입니다. 최소 정상 작업 수는 **`desiredCount` × 비율/100을 올림**합니다. ⚠️ 그리고 **`CODE_DEPLOY`·`EXTERNAL` + EC2에서는 사용자 지정 값을 지정할 수 없습니다.**
</details>

**Q2.** Lambda에 사전 검증을 붙인 카나리 배포를 구성했는데 배포가 1시간 뒤 실패로 끝난다. 원인과, 훅 이름 두 개는? (→ 4) CodeDeploy)

<details><summary>정답 보기</summary>

검증 함수가 ⚠️ **`putLifecycleEventHookExecutionStatus`로 Succeeded·Failed를 통지하지 않았기** 때문입니다 — **1시간 안에 통지가 없으면 배포가 실패**합니다.

훅은 **`BeforeAllowTraffic`**(트래픽 전환 전)과 **`AfterAllowTraffic`**(전환 후)이고 각각 검증 Lambda **1개**, 배포당 **1회** 실행됩니다. 자동 롤백은 배포 그룹에서 **배포 실패 시**와 **경보 임계 충족 시** 두 조건으로 설정하며 CloudWatch 경보는 **최대 10개**를 붙일 수 있습니다. SAM에서는 같은 구성을 `DeploymentPreference`의 **`Hooks.PreTraffic`·`PostTraffic`**으로 선언합니다.
</details>

**Q3.** EC2 in-place 배포를 롤백했는데 배포 스크립트가 만든 파일이 그대로 남아 있다. 왜인가? 더 안전한 대안은? (→ 7) 롤백)

<details><summary>정답 보기</summary>

⚠️ **CodeDeploy 롤백은 상태를 되감는 것이 아니라 "이전에 배포한 리비전을 새 배포(새 배포 ID)로 다시 내보내는 것"**입니다. in-place는 직전 성공 설치가 만든 파일을 정리한 뒤 재배포하지만 **스크립트가 만든 파일은 되돌리지 않습니다.**

더 안전한 대안은 **옛 것을 살려 두고 트래픽만 돌리는 방식**입니다 — **EC2 블루/그린**(원래 인스턴스가 종료 전이면 트래픽 복귀), **ECS 내장 블루/그린**(⭐ **bake time 동안 blue 유지**), **Lambda 별칭 되돌리기**, **API Gateway 이전 배포 재활성화**. 이들은 부수 효과가 남지 않습니다.
</details>

**Q4.** 파이프라인을 dev → 승인 → prod로 구성했다. 승인 단계의 제약과, 단계가 동시에 여러 실행을 받으면 어떻게 되는가? (→ 5) CodePipeline)

<details><summary>정답 보기</summary>

**수동 승인 작업**은 파이프라인을 멈추고 같은 리전의 **SNS 주제**로 알림·검토 URL·코멘트를 보냅니다. ⚠️ **거부하거나 7일 안에 응답이 없으면 실패 처리**됩니다.

단계는 ⚠️ **한 번에 하나의 실행만** 처리합니다(잠금). 기본 실행 모드 **`SUPERSEDED`**에서는 **새 실행이 대기 중 실행을 대체**하고, 다른 모드로 `QUEUED`·`PARALLEL`이 있습니다. 작업 유형은 **`source`·`build`·`test`·`deploy`·`approval`·`invoke` 6가지**이고 작업 사이 산출물은 **아티팩트 버킷**을 거칩니다. ⚠️ 소스 작업당 **트리거는 1개**입니다.
</details>

**Q5.** 같은 애플리케이션을 ECS와 EKS에 배포한다. 두 경로의 배포 단위와 Fargate 지정 방식은 어떻게 다른가? (→ 2) 컨테이너)

<details><summary>정답 보기</summary>

**ECS**는 **작업 정의**를 서비스가 돌리고 **Fargate는 시작 유형(launch type)**으로 지정합니다. 롤링 업데이트는 `minimumHealthyPercent`·`maximumPercent`로 조절하고 ⭐ 이미지 태그는 **`versionConsistency`로 다이제스트로 해석**되어 모든 작업이 같은 이미지를 씁니다.

**EKS**는 ⚠️ **작업 정의가 없습니다** — `kind: Deployment`·`Service` **매니페스트를 `kubectl apply -f`**로 적용하고, `spec.replicas`·`selector.matchLabels`·`template`이 ECS의 개수·작업 정의 자리에 해당합니다. 로드 밸런서는 **`Service` 주석**으로 지정합니다. ⚠️ **Fargate는 시작 유형이 아니라 Fargate 프로필**이고 **네임스페이스**(+선택적 레이블)로 고릅니다 — Load Balancer Controller를 쓰면 대상 유형이 **`IP`**여야 합니다.
</details>

**Q6.** 릴리스를 추적하고 언제든 특정 릴리스로 되돌릴 수 있게 하려면 무엇을 기준으로 배포해야 하는가? (→ 8) 소스 제어)

<details><summary>정답 보기</summary>

⭐ **불변 식별자**입니다 — Lambda의 **게시 버전 번호**(불변, 재사용되지 않음)와 컨테이너의 **다이제스트**(`@sha256:`)입니다. 반대로 **`latest` 같은 태그와 `$LATEST`는 덮어쓸 수 있는 가변 참조**라 "그때 돌던 그것"을 다시 세울 수 없습니다.

운영 방법: ECR **태그 불변성**을 켜면 같은 태그 푸시에 `ImageTagAlreadyExistsException`이 나고, **커밋 해시 같은 서술적 태그**를 권장합니다. Lambda는 **새 코드마다 버전 게시 + 별칭 이동**(SAM `AutoPublishAlias`)으로, Beanstalk는 **라벨이 붙은 애플리케이션 버전**으로 관리합니다(⚠️ 수명 주기 정책으로 정리해도 **S3 소스 번들은 자동 삭제되지 않습니다**).
</details>

**Q7.** 기술 3.3.9의 "AI 도구로 배포 승인 자동화·배포 후 검증"을 어떻게 공부하는가? 보기에서 무엇을 의심하는가? (→ 9) AI CI/CD)

<details><summary>정답 보기</summary>

⚠️ **기술 문구가 서비스를 명시하지 않습니다.** 범위 내 ML/AI 넷 중 개발·배포 워크플로에 해당하는 것은 **Kiro**(**Hooks**로 커밋·저장 이벤트에 테스트·표준 검사를 걸어 둠)이고, 배포 후 검증·조사는 **CloudWatch의 생성형 AI 기능**(자연어 쿼리 생성 — 권한은 **`cloudwatch:GenerateQuery`**)입니다.

⚠️ **단일 "AI 배포 승인 서비스"를 고르게 하는 문항은 공식 근거가 없습니다.** 의심할 이름은 **`Amazon Q Developer`**(범위 내 목록에 없고 IDE 플러그인은 2027-04-30 지원 종료)와 **`Amazon Quick`**(개발 도구가 아니고 그 BI 구성 요소 **Quick Sight는 범위 밖**)입니다.
</details>

---

### 📌 출처

1. What is CodeDeploy? — https://docs.aws.amazon.com/codedeploy/latest/userguide/welcome.html
2. Working with deployment configurations in CodeDeploy — https://docs.aws.amazon.com/codedeploy/latest/userguide/deployment-configurations.html
3. CodeDeploy AppSpec file reference — https://docs.aws.amazon.com/codedeploy/latest/userguide/reference-appspec-file.html
4. AppSpec 'hooks' section — https://docs.aws.amazon.com/codedeploy/latest/userguide/reference-appspec-file-structure-hooks.html
5. Redeploy and roll back a deployment with CodeDeploy — https://docs.aws.amazon.com/codedeploy/latest/userguide/deployments-rollback-and-redeploy.html
6. Configure advanced options for a deployment group — https://docs.aws.amazon.com/codedeploy/latest/userguide/deployment-groups-configure-advanced-options.html
7. Deploy Amazon ECS services by replacing tasks (롤링) — https://docs.aws.amazon.com/AmazonECS/latest/developerguide/deployment-type-ecs.html
8. Amazon ECS blue/green deployments (내장) — https://docs.aws.amazon.com/AmazonECS/latest/developerguide/deployment-type-blue-green.html
9. CodeDeploy blue/green deployments for Amazon ECS — https://docs.aws.amazon.com/AmazonECS/latest/developerguide/deployment-type-bluegreen.html
10. AWS::ECS::Service DeploymentConfiguration (CloudFormation) — https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/aws-properties-ecs-service-deploymentconfiguration.html
11. Getting started with AWS Fargate on Amazon EKS — https://docs.aws.amazon.com/eks/latest/userguide/fargate-getting-started.html
12. CodePipeline concepts — https://docs.aws.amazon.com/codepipeline/latest/userguide/concepts.html
13. Add a manual approval action to a stage — https://docs.aws.amazon.com/codepipeline/latest/userguide/approvals.html
14. Source actions and change detection methods — https://docs.aws.amazon.com/codepipeline/latest/userguide/change-detection-methods.html
15. Start a pipeline in CodePipeline — https://docs.aws.amazon.com/codepipeline/latest/userguide/pipelines-about-starting.html
16. Configure a stage for automatic rollback — https://docs.aws.amazon.com/codepipeline/latest/userguide/stage-rollback-auto.html
17. AWS Lambda deploy action reference (CodePipeline) — https://docs.aws.amazon.com/codepipeline/latest/userguide/action-reference-LambdaDeploy.html
18. Understand update behaviors of stack resources (CloudFormation) — https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-updating-stacks-update-behaviors.html
19. Update CloudFormation stacks using change sets — https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-updating-stacks-changesets.html
20. Implement Lambda canary deployments using a weighted alias — https://docs.aws.amazon.com/lambda/latest/dg/configuring-alias-routing.html
21. Managing application versions (Elastic Beanstalk) — https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/applications-versions.html
22. Amazon ECR lifecycle policies — https://docs.aws.amazon.com/AmazonECR/latest/userguide/LifecyclePolicies.html
23. CloudWatch Logs 자연어 쿼리 생성(`cloudwatch:GenerateQuery`) — https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CloudWatchLogs-Insights-Query-Assist.html
24. DVA-C03 공식 시험 가이드 · 콘텐츠 도메인 3 (한국어) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/developer-associate-03/developer-associate-03-domain3.html
25. DVA-C03 범위 내 AWS 서비스 (한국어) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/developer-associate-03/dva-03-in-scope-services.html
