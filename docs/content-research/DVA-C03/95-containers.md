# 95 — 컨테이너 2 Skill (C03 신설)

> **원자료 노트(저작 재료)** · 조회일 **2026-11-01**. 사실마다 URL을 붙였고, 확인하지 못한 것은 `## 확인 필요`에 남겼다.

| Skill | Task | 요구 |
|---|---|---|
| **3.1.2** | 3.1 아티팩트 준비 | 배포용 **컨테이너 이미지 빌드·관리** — ECR · Dockerfile · 이미지 태깅 · **수명 주기 정책** |
| **3.3.2** | 3.3 CI/CD 배포 | **컨테이너 오케스트레이션 서비스로 배포** — ECS 작업 정의 · EKS 매니페스트 · **Fargate 시작 유형** · 롤링 업데이트 |

in-scope Containers는 **ECR · ECS · EKS** 셋이다(Fargate는 별도 항목이 아니라 시작 유형으로 등장한다).

C02 노트의 인접 재료: `3-1.md` §컨테이너 이미지·ECR · `3-3.md` §이미지 태그 · `3-4.md` §ECS 배포 전략. **EKS·Fargate 배포 절차 중심의 노트는 없다.**

---

## 1. 이미지 태그 불변성 — 보안 기본값처럼 다룬다 (3.1.2)

ECR 리포지토리의 **`ImageTagMutability`**는 기본이 **`MUTABLE`**이고, 이 경우 같은 태그를 **덮어쓸 수 있다.**

> "This prevents pushing an altered or updated version of an image to your image repository with an identical tag." (ECS 보안 모범 사례)

- **`IMMUTABLE`**로 두면 리포지토리의 모든 이미지 태그를 덮어쓸 수 없고, **변경마다 새 태그를 밀어야 한다.**
- 공격자가 같은 태그로 오염된 이미지를 덮어쓰는 것을 막는 것이 목적이다.
- CloudFormation에서는 `AWS::ECR::Repository`의 `ImageTagMutability: IMMUTABLE`.

> ⚠️ **`latest` 태그 재사용과 정면으로 부딪힌다** — 불변 태그를 켜면 `latest`를 계속 밀 수 없다. 시험에서 "롤백 가능한 배포"와 묶여 나오기 좋은 지점이다.

## 2. 수명 주기 정책 — 규칙 평가 방식이 비자명하다 (3.1.2)

ECR **수명 주기 정책**은 규칙 하나 이상으로 **프라이빗 리포지토리**의 이미지를 만료(expire)·보관(archive)한다.

- 조건을 만족한 이미지는 **24시간 이내**에 처리된다. 처리 결과는 **CloudTrail 이벤트**로 남는다.
- 적용 전에 **미리 보기(preview)**로 어떤 이미지가 사라질지 확인하는 것이 권장 절차다.
- **우선순위 숫자가 작을수록 높은 우선순위**다(1이 2보다 우선).
- 모든 규칙은 **동시에 평가**된 뒤 우선순위에 따라 적용된다. **이미지 하나는 정확히 0개 또는 1개 규칙**에 의해 처리된다. 더 높은 우선순위 규칙이 표시한 이미지는 낮은 규칙이 가져갈 수 없다.
- 만료 순서는 항상 `pushed_at_time`(또는 `transitioned_at_time`) 기준이고 **오래된 것부터**다.
- **`tagPatternList`와 `tagPrefixList`는 한 규칙에 함께 쓸 수 없다**(정책 전체에는 둘을 쓰는 규칙이 섞일 수 있다). 둘 다 **`tagStatus`가 `tagged`일 때만** 쓴다.
- `tagPatternList`는 와일드카드 필터다 — `prod*`는 `prod`·`prod1`·`production-team1`에 걸린다. **문자열당 와일드카드 최대 4개.**
- `countType`: `imageCountMoreThan`(개수 초과분) · `sinceImagePushed` · `sinceImagePulled` · `sinceImageTransitioned`. `countUnit`은 뒤의 세 가지에만 쓴다.
- **매니페스트 목록이 참조하는 이미지는** 그 목록을 먼저 지우거나 보관하지 않으면 만료되지 않는다.
- 특정 스토리지 클래스를 고르는 규칙 집합은 **접두사가 서로 달라야** 하고, **태그 없는 이미지를 고르는 규칙은 클래스당 하나**만 허용된다.

## 3. 롤링 업데이트 — Fargate에서 달라지는 지점 (3.3.2)

ECS 롤링 업데이트(`ECS` 배포 유형)는 두 값으로 조절한다.

| 파라미터 | 뜻 |
|---|---|
| **`minimumHealthyPercent`** | 배포 중 `RUNNING`을 유지해야 하는 작업의 최소 비율. **기본 100%** |
| **`maximumPercent`** | 원하는 개수 위로 추가 실행할 수 있는 상한. 200%·원하는 개수 8이면 최대 16 |

> ⚠️ **이 줄은 2026-11-01에 정정됐다(G-05 → 판정 D-05).** 이전 서술 "Fargate 시작 유형에서는 `minimumHealthyPercent`가 쓰이지 않는다"는 **과도한 일반화**였다. 정본(`AWS::ECS::Service DeploymentConfiguration`)은 **"`CODE_DEPLOY`(블루/그린) 또는 `EXTERNAL` 배포 유형 + Fargate 시작 유형"**일 때 쓰이지 않는다고 적는다(describe 응답에는 값이 돌아온다). **롤링 업데이트(`ECS`) 배포 유형에서는 Fargate에서도 쓰인다.** 판정과 저작 규칙은 [98-authoring-decisions.md](98-authoring-decisions.md) D-05.
>
> 같은 페이지에서 확보한 기본값: replica 서비스 `minimumHealthyPercent` **100%** · `maximumPercent` **200%**, `DAEMON`은 CLI·SDK·API **0%** / 콘솔 **50%**. 최소 정상 작업 수는 `desiredCount` × 비율/100을 **올림**한다. `CODE_DEPLOY`·`EXTERNAL` + **EC2**에서는 **사용자 지정 값을 지정할 수 없다**(기본값으로 설정되어 `DRAINING` 중 하한으로 쓰인다).

- 무중단 롤링 배포 권장값은 **최소 100% · 최대 200%**다.
- ⚠️ **ECS는 컨테이너 배포 과정을 관리하지만 트래픽 라우팅은 하지 않는다** — 로드 밸런서를 쓰면 라우팅은 따로 구성해야 하고, CodeDeploy 블루/그린이면 트래픽 관리 설정을 본다.
- 작업 교체가 일어나는 경우는 둘이다 — **`UpdateService` 호출로 새 배포가 시작될 때**, 그리고 **활성 배포 안의 작업이 비정상이 될 때**.

## 3-b. EKS 매니페스트 배포 — ECS와 모델이 다르다 (3.3.2)

EKS에는 "작업 정의"가 없다. **Kubernetes 매니페스트**(YAML)를 클러스터에 적용한다.

- 배포 단위는 `apiVersion: apps/v1` · `kind: Deployment`이고, 노출은 `kind: Service`다. 적용은 **`kubectl apply -f <파일>`**.
- `Deployment`의 `spec.replicas`·`selector.matchLabels`·`template`이 ECS 서비스의 원하는 개수·작업 정의 자리에 해당한다.
- `Service`에 **주석(annotation)**으로 AWS 로드 밸런서를 지정한다 — 예: `service.beta.kubernetes.io/aws-load-balancer-type: nlb`, 내부용이면 `...-internal: "true"`.
- IaC로는 CDK의 **`KubernetesManifest`** 구문이나 `cluster.addManifest`로 같은 매니페스트를 올린다.

### ⚠️ EKS의 Fargate는 ECS의 Fargate와 지정 방식이 다르다

| | ECS | EKS |
|---|---|---|
| Fargate 쓰는 법 | 서비스·작업의 **시작 유형(launch type)** | **Fargate 프로필**을 만들어 **네임스페이스**(+선택적 레이블)로 선택 |
| 선택 단위 | 서비스 | 프로필 셀렉터에 걸리는 **파드** |

- 프로필 생성에는 **네임스페이스 지정이 필수**이고 `--labels`는 선택이다(`eksctl create fargateprofile --cluster <c> --name <p> --namespace <ns>`).
- 네임스페이스·레이블에 **와일드카드**를 쓸 수 있다.
- ⚠️ **AWS Load Balancer Controller를 쓸 때 대상 파드가 Fargate에 있으면 대상 유형을 `IP`로 해야 한다.** 그리고 ingress·service 객체가 있는 **네임스페이스에 Fargate 프로필이 있어야** 한다.

## 4. 시험에서 묻는 방식

- "같은 태그로 덮어쓴 이미지가 배포됐다" → **`ImageTagMutability: IMMUTABLE`**
- "오래된 이미지가 쌓여 비용이 는다" → **수명 주기 정책** + 적용 전 **미리 보기**
- "규칙을 둘 걸었는데 하나만 먹는다" → 이미지는 **0 또는 1개 규칙**에만 걸리고 **낮은 숫자가 우선**
- "Fargate 서비스인데 최소 정상 비율을 낮춰도 동작이 같다" → **배포 유형을 먼저 본다**(D-05) — `CODE_DEPLOY`·`EXTERNAL`이면 그 값을 쓰지 않고, **롤링 업데이트면 Fargate에서도 쓰인다**
- "배포는 됐는데 트래픽이 새 작업으로 안 간다" → **라우팅은 ECS가 하지 않는다**

## 5. 흔한 함정·혼동 짝

| 혼동 | 가르는 기준 |
|---|---|
| `MUTABLE`(기본) vs `IMMUTABLE` | 기본이 **덮어쓰기 허용**이다 |
| 수명 주기 규칙 우선순위 | **작은 숫자가 우선** |
| `tagPatternList` vs `tagPrefixList` | **한 규칙에 둘 다 못 쓴다**, `tagStatus: tagged`에서만 |
| `minimumHealthyPercent` | ⚠️ **"Fargate 미사용"은 과도한 일반화다** — `CODE_DEPLOY`·`EXTERNAL` **배포 유형 + Fargate**일 때만 미사용이고 **롤링 업데이트에서는 쓰인다**(D-05) |
| ECS 배포 vs 트래픽 라우팅 | ECS는 **배포만** |

## 6. 사실·숫자

- 수명 주기 처리 **24시간 이내** · 와일드카드 **문자열당 최대 4개**
- `minimumHealthyPercent` 기본 **100%** · 무중단 권장 **100/200**
- in-scope Containers **3종**(ECR · ECS · EKS)

## 7. 출처 목록

조회일 전부 **2026-11-01**.

1. ECR 수명 주기 정책 — https://docs.aws.amazon.com/AmazonECR/latest/userguide/LifecyclePolicies.html
2. ECS 작업·컨테이너 보안 모범 사례(불변 태그) — https://docs.aws.amazon.com/AmazonECS/latest/developerguide/security-tasks-containers.html
3. Control Tower ECR 통제(`ImageTagMutability` CFN 예시) — https://docs.aws.amazon.com/controltower/latest/controlreference/ecr-rules.html
4. `minimumHealthyPercent` 정의(Fargate 미사용) — https://docs.aws.amazon.com/sdk-for-kotlin/api/latest/securityhub/aws.sdk.kotlin.services.securityhub.model/-aws-ecs-service-deployment-configuration-details/-builder/minimum-healthy-percent.html
5. (AWS 지식 센터) 무중단 ECS 배포 — https://repost.aws/knowledge-center/ecs-deploy-tasks-no-downtime
6. (AWS 블로그) ECS 작업 상태·교체 심층 — https://aws.amazon.com/blogs/containers/a-deep-dive-into-amazon-ecs-task-health-and-task-replacement/

## 확인 필요

- ~~**`minimumHealthyPercent`의 Fargate 미사용 서술을 다시 확인한다**~~ → ✅ **닫았다(2026-11-01, G-05 → 판정 D-05).** 정본은 `AWS::ECS::Service DeploymentConfiguration`이고, ⚠️ **옛 서술이 과도한 일반화였다** — 미사용 조건은 "Fargate"가 아니라 **`CODE_DEPLOY`·`EXTERNAL` 배포 유형 + Fargate**다. §3 주석 참조.
- ~~**EKS 매니페스트 배포 절차**~~ → ✅ **닫았다(2026-11-01, G-02).** §3-b 참조. ⚠️ 다만 `kubectl apply` 예시의 출처가 **처방적 지침(prescriptive-guidance)**이라, 학습문서에 명령을 그대로 실을 때는 EKS 사용자 가이드 쪽 대응 페이지를 한 번 더 확인한다.
- ~~**Dockerfile 작성 모범 사례를 AWS 공식 문서 기준으로 찾지 못했다**~~ → ✅ **닫았다(2026-11-01, G-10 → 판정 D-04).** ⚠️ **검색 범위 문제였다** — `docs.aws.amazon.com` 본문에 두 곳이 있다: **ECR 성능 최적화**(레이어 캐시 순서·명령 체이닝·베이스 이미지 크기·동시 업로드)와 **Well-Architected Container Build Lens**(멀티스테이지·Dockerfile 린팅·골든 부모 이미지). 경계 규칙은 D-04.
- 블로그·지식 센터 출처(5·6)는 **권장값·동작 설명에만** 썼다.

### 추가 출처 (§3-b)

7. (처방적 지침) EKS 매니페스트 배포·NLB 주석 — https://docs.aws.amazon.com/prescriptive-guidance/latest/patterns/access-container-applications-privately-on-amazon-eks-using-aws-privatelink-and-a-network-load-balancer.html
8. EKS Fargate 시작하기(프로필·네임스페이스·와일드카드) — https://docs.aws.amazon.com/eks/latest/userguide/fargate-getting-started.html
9. (AWS 지식 센터) Load Balancer Controller — Fargate 대상은 `IP` 유형 — https://repost.aws/knowledge-center/load-balancer-troubleshoot-creating
