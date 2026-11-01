---
examGuideTaskId: dva-t3-1
certCode: DVA-C03
domain: 3
domainName: 테스트 및 배포
domainWeightPct: 22
title: 배포 아티팩트 준비 (패키지·Dockerfile·ECR·환경별 구성·API Gateway 스테이지)
coversTasks:
  - "3.1"
sources:
  - title: Lambda quotas
    url: https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-limits.html
  - title: Managing Lambda dependencies with layers
    url: https://docs.aws.amazon.com/lambda/latest/dg/chapter-layers.html
  - title: Optimizing performance for Amazon ECR
    url: https://docs.aws.amazon.com/AmazonECR/latest/userguide/performance.html
  - title: Amazon ECR lifecycle policies
    url: https://docs.aws.amazon.com/AmazonECR/latest/userguide/LifecyclePolicies.html
  - title: Amazon ECS task and container security best practices
    url: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/security-tasks-containers.html
  - title: What is AWS AppConfig?
    url: https://docs.aws.amazon.com/appconfig/latest/userguide/what-is-appconfig.html
  - title: Set up a stage for a REST API in API Gateway
    url: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-stages.html
  - title: Set up an API Gateway canary release deployment
    url: https://docs.aws.amazon.com/apigateway/latest/developerguide/canary-release.html
  - title: DVA-C03 공식 시험 가이드 · 콘텐츠 도메인 3 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/developer-associate-03/developer-associate-03-domain3.html
lastVerified: 2026-11-01
---

# 배포 아티팩트 준비 (패키지·Dockerfile·ECR·환경별 구성·API Gateway 스테이지)

> **커버하는 공식 Task** — DVA-C03 · 도메인 3 「테스트 및 배포」(22%) · **작업 3.1 AWS에 배포할 애플리케이션 아티팩트를 준비합니다** (`dva-t3-1`)
> 이 문서는 위 한 작업에 1:1로 매핑되고, 공식 기술 다섯 개(3.1.1~3.1.5)를 모두 덮습니다.

> ⚠️ **C03에서 이 작업에 둘이 들어왔습니다** — **기술 3.1.2 컨테이너 이미지 빌드·관리가 신설**되고(ECR · Docker 파일 · 태깅 · 수명 주기 정책), **기술 3.1.5 API Gateway 기능·리소스가 C02의 Task 3.4에서 이동**했습니다. ⚠️ **C02의 Task 3.4는 C03에 없습니다**(도메인 3이 4 Task → **3 Task**로 줄었고 내용이 3.1·3.3으로 흩어졌습니다).
>
> ⚠️ **도메인 이름도 바뀌었습니다** — C02의 `배포` → C03의 **`테스트 및 배포`**이고 비중은 24% → **22%**입니다.

---

## ✅ 학습 목표 체크리스트

- [ ] `.zip`과 컨테이너 이미지를 **크기·빌드 방식**으로 고를 수 있다
- [ ] 계층·번들링으로 의존성을 분리하고 **런타임별 폴더 규칙**을 안다
- [ ] 배포 번들의 **구조 규칙**(핸들러 위치·`appspec.yml`·`buildspec.yml`)을 안다
- [ ] AWS 문서가 적는 **Dockerfile 사실**(레이어 캐시·체이닝·멀티스테이지)을 적용한다
- [ ] ECR **태그 불변성**과 **수명 주기 정책의 평가 방식**을 설명한다
- [ ] 소스·의존성·배포 단위의 저장소를 **역할별로** 구분한다
- [ ] 구성을 둘 위치를 **"값을 바꿀 때 무엇이 필요한가"**로 고른다
- [ ] API Gateway 배포와 스테이지를 구분하고 **재배포가 필요한 변경**을 안다

---

## 🎯 왜 중요한가

이 작업은 **"배포 전에 무엇을 만들어 두는가"**입니다. 그래서 문항도 "어떻게 배포하는가"(작업 3.3)가 아니라 **"이 아티팩트가 왜 안 올라가는가 / 왜 커지는가 / 왜 덮어써지는가"**를 묻습니다.

세 축으로 정리하면 외울 것이 줄어듭니다 — **패키지**(.zip·이미지·계층), **이미지 저장**(ECR의 태그·수명 주기), **구성**(패키지 안 · 환경 변수 · Parameter Store · Secrets Manager · AppConfig). 그리고 C03에서 들어온 API Gateway 스테이지는 **"배포는 스냅샷, 스테이지는 그 스냅샷을 가리키는 이름"** 한 문장이 전부에 가깝습니다.

---

## ⚡ 시험 직전 요약

> 시험 직전에 이 열 줄만 다시 봅니다. 근거와 맥락은 아래 본문에 있습니다.

- **패키지 한도**: `.zip`은 콘솔·API 업로드 **50 MB**(더 크면 S3 경유)·**압축 해제 합계 250 MB**(계층 포함), 컨테이너 이미지는 **10 GB**. 계층은 함수당 **5개**
- ⚠️ **`.zip`은 핸들러와 의존성이 루트에** 있어야 합니다. **계층은 런타임별 규정 폴더**(`python/`·`nodejs/node_modules`)에 둡니다
- **`appspec.yml`은 리비전 루트**에 있어야 하고(아니면 배포 실패) 리비전당 **하나**입니다. CodeBuild는 기본 **소스 루트의 `buildspec.yml`**이고 프로젝트당 하나만 지정합니다
- **Dockerfile은 각 줄이 레이어**입니다 — ⭐ **변경이 가장 적은 의존성을 앞쪽에** 두고(한 레이어가 바뀌면 **뒤 레이어가 모두 재빌드**), ⭐ **명령을 체이닝**합니다(중간 파일은 뒤에서 지워도 **그 레이어에 남습니다**)
- **멀티스테이지 빌드**로 빌드 도구를 최종 이미지에서 떼어 **크기와 공격 표면**을 줄입니다. **Dockerfile 린팅**은 보안 모범 사례입니다
- ⚠️ **ECR `ImageTagMutability` 기본값은 `MUTABLE`**이라 같은 태그를 **덮어쓸 수 있습니다.** `IMMUTABLE`로 두면 변경마다 새 태그가 필요합니다(`latest` 재사용과 정면 충돌)
- **수명 주기 정책**: 조건 충족 후 **24시간 이내** 처리, **숫자가 작을수록 우선**, ⚠️ **이미지 하나는 정확히 0개 또는 1개 규칙**에만 걸립니다. `tagPatternList`와 `tagPrefixList`는 **한 규칙에 함께 쓸 수 없습니다**
- **구성 위치는 "바꿀 때 무엇이 필요한가"로** 고릅니다 — 패키지 안(**재배포**) · 환경 변수(**새 버전 게시**, 합계 4 KB) · Parameter Store·Secrets Manager(**갱신**) · AppConfig(**배포 + 검증 + 경보 롤백**)
- **AppConfig 계층**: Application → Environment(**CloudWatch 경보 연결**) → Configuration profile(**검증기 최대 2개**) → Deployment strategy(**베이크 타임**) → Deployment
- **API Gateway**: **배포는 API의 스냅샷**, **스테이지는 그 배포를 가리키는 이름 있는 참조**입니다. ⚠️ **리소스 변경은 재배포가 필요**하고 **구성 변경은 필요 없습니다.** 롤백은 **이전 배포를 다시 활성화**합니다

---

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **배포 패키지** | Lambda에 올리는 코드 묶음 — `.zip` 아카이브 또는 컨테이너 이미지 |
| **계층(layer)** | 의존성·공용 코드를 담아 여러 함수가 공유하는 `.zip`. `/opt`에 추출된다 |
| **레이어(image layer)** | 컨테이너 이미지의 중간 빌드 단계. **Dockerfile의 각 줄이 하나를 만든다** |
| **멀티스테이지 빌드** | 빌드 도구가 든 예비 이미지에서 만들고 **산출물만 최종 이미지로 복사**하는 기법 |
| **태그 불변성** | ECR 리포지토리의 `ImageTagMutability` — `IMMUTABLE`이면 같은 태그를 덮어쓸 수 없다 |
| **수명 주기 정책** | ECR 프라이빗 리포지토리의 이미지를 규칙에 따라 만료·보관하는 정책 |
| **배포(deployment)** | API Gateway에서 **API의 스냅샷**. 그 자체로는 호출되지 않는다 |
| **스테이지(stage)** | 특정 배포를 가리키는 **이름 있는 참조**. 캐시·스로틀링·로깅·스테이지 변수·카나리가 붙는다 |

---

## 📖 핵심 개념

### 1) 배포 패키지 — `.zip`과 컨테이너 이미지 (기술 3.1.1) {#package}

| 항목 | `.zip` 아카이브 | 컨테이너 이미지 |
|---|---|---|
| 크기 한도 | 업로드 **50 MB**(더 크면 S3 경유) · **압축 해제 합계 250 MB** | **10 GB** |
| 계층 사용 | **가능**(함수당 5개, 250 MB 한도에 포함) | ⚠️ **불가**(이미지 안에 포함한다) |
| 저장 위치 | 콘솔·S3 | **ECR**(함수와 **같은 리전**) |
| 런타임 변경 | 설정 업데이트 | **이미지를 새로 만든다** |

> 🧠 **원리** — 둘의 갈림길은 **크기와 빌드 통제**입니다. 250 MB로 부족하거나 OS 패키지·네이티브 바이너리를 직접 통제해야 하면 이미지로 가고, 그 대가로 **계층을 쓸 수 없고 런타임 변경이 재빌드**가 됩니다.

### 2) 의존성 번들링과 계층 (기술 3.1.1) {#deps}

- **계층의 용도**: 배포 패키지 축소, 로직과 의존성 분리, 여러 함수 간 공유, 콘솔 코드 편집기 사용, 내장 SDK 버전 고정.
- ⚠️ **런타임별 규정 폴더**에 의존성을 둬야 인식됩니다 — Python은 `python/`, Node.js는 `nodejs/node_modules`.
- 계층 버전은 **변경 불가능한 스냅샷**이라 ARN에 **버전 번호까지** 지정합니다.
- **SAM `sam build`**는 의존성 매니페스트(`requirements.txt`·`package.json`)나 함수의 `Layers` 속성으로 의존성을 모아 **`.aws-sam` 빌드 디렉터리**에 배치합니다. 결과 형식은 함수의 **`PackageType`**(Zip 또는 Image)이 정합니다.
- 주요 옵션: **`--use-container`**(네이티브 컴파일 의존성을 Lambda 유사 컨테이너에서 빌드) · `--cached`(변경 없는 산출물 재사용, **기본은 캐시 안 함**) · `--parallel` · `--build-in-source`.
- ⚠️ **`--cached`는 버전을 고정하지 않은 서드파티 모듈의 최신 버전 변경을 감지하지 못합니다** — 비캐시 빌드로 갱신합니다.
- 아키텍처를 지정하지 않으면 **`x86_64`**로 빌드합니다.

> 🧠 **원리** — 계층은 "파일을 `/opt`에 풀어 주는 것"이고, 번들링은 "패키지 안에 넣는 것"입니다. 공유가 필요하면 계층, **네이티브 의존성이 런타임과 맞아야 하면** 컨테이너 빌드(`--use-container`)가 답입니다.

### 3) 배포 번들의 구조 규칙 (기술 3.1.1) {#bundle-structure}

| 대상 | 구조 규칙 |
|---|---|
| **Lambda `.zip`** | 핸들러 파일과 모든 의존성을 **zip 루트**에 둔다(루트에 없으면 실행 불가). 파일 권한 **644**, 디렉터리·실행 파일 **755** |
| **Lambda 계층** | 런타임별 규정 폴더(`python/`·`nodejs/node_modules`) |
| **Elastic Beanstalk 소스 번들** | 단일 ZIP 또는 WAR, **500 MB 이하**, ⚠️ **최상위 부모 폴더 없이** 압축. `.ebextensions` 같은 숨김 폴더가 GUI 압축에서 빠질 수 있어 **명령줄 `zip` 권장** |
| **CodeDeploy 리비전** | ⚠️ **`appspec.yml`을 리비전 루트**에 둔다(아니면 배포 실패). 리비전당 AppSpec은 **하나**. tar 계열은 **Windows Server 미지원** |
| **CodeBuild** | 기본은 **소스 루트의 `buildspec.yml`**. 이름·위치 재정의 가능하지만 **프로젝트당 하나** |
| **SAM 프로젝트** | 루트에 `template.yaml`·`samconfig.toml`, 함수 코드 폴더(`CodeUri`), `events/`, `tests/`. Image 패키지를 고르면 함수 폴더에 **`Dockerfile`** |

> 🧠 **원리** — 이 규칙들은 전부 **"서비스가 파일을 어디서 찾는가"**입니다. 그래서 "잘 만들었는데 배포가 실패한다"는 문항의 답은 대개 **위치**이고, 압축 방식(부모 폴더 포함)처럼 사람이 흔히 틀리는 지점이 그대로 출제 지점이 됩니다.

### 4) 컨테이너 이미지 — AWS 문서가 적는 Dockerfile 사실 (기술 3.1.2) {#dockerfile}

🆕 **C03 신설 기술**입니다. ⚠️ 여기서는 **AWS 문서가 자기 사실로 적는 것만** 다룹니다 — `COPY` vs `ADD` 같은 **Docker 문법 레퍼런스는 AWS 문서의 범위가 아닙니다.**

**ECR 성능 최적화 페이지가 적는 네 가지**

1. **Dockerfile의 각 줄이 새 레이어를 만듭니다.** Docker 1.10 이상은 **가능한 많은 레이어를 동시에 업로드**해 ECR 푸시가 빨라집니다.
2. **더 작은 베이스 이미지**를 씁니다 — 공개 이미지에는 앱이 쓰지 않는 의존성이 많을 수 있습니다.
3. ⭐ **변경이 가장 적은 의존성을 Dockerfile 앞쪽에** 둡니다. Docker가 레이어를 캐시하지만 **각 레이어는 앞 레이어에 의존**하므로, 한 레이어가 바뀌면 **그 뒤 레이어가 모두 다시 빌드**됩니다. 자주 바뀌는 **애플리케이션 소스는 뒤쪽**에 둡니다.
4. ⭐ **명령을 체이닝**합니다 — ⚠️ 한 레이어에서 만든 중간 파일은 **뒤 레이어에서 지워도 그 레이어에 남습니다.** 내려받고 풀고 지우는 과정을 한 `RUN`으로 묶어야 이미지가 작아집니다.

**Well-Architected Container Build Lens가 적는 세 가지**

- **멀티스테이지 빌드**로 빌드 도구·의존성을 최종 이미지에서 분리합니다 — 크기가 줄고 **공격 표면이 줄며** 빌드가 재현 가능해집니다. 최종 이미지에는 **실행에 필요한 바이너리·구성만** 남깁니다.
- **Dockerfile 린팅**(예: hadolint)을 **보안 모범 사례**로 둡니다 — 덤으로 **쓰이지 않는·낡은 의존성**을 찾아냅니다.
- **골든 부모 이미지** 패턴 — 조직 공통 구성을 담은 이미지를 모든 이미지의 부모로 삼습니다. ⚠️ **부모가 바뀌면 자식 이미지를 다시 빌드**해야 반영됩니다.

> 🧠 **원리** — 레이어는 **쌓인 변경 기록**입니다. 그래서 "지웠다"가 "없어졌다"가 아니고(체이닝이 필요한 이유), "앞을 바꿨다"가 "뒤도 다시"입니다(순서가 중요한 이유). 이미지 크기·푸시 시간·공격 표면이 모두 이 한 성질에서 나옵니다.

### 5) ECR — 태그 불변성과 수명 주기 정책 (기술 3.1.2) {#ecr}

⚠️ **`ImageTagMutability`의 기본값은 `MUTABLE`**이고, 이 경우 **같은 태그를 덮어쓸 수 있습니다.**

> 원문: "This prevents pushing an altered or updated version of an image to your image repository with an identical tag." (ECS 보안 모범 사례)

- **`IMMUTABLE`**로 두면 리포지토리의 모든 태그를 덮어쓸 수 없고 **변경마다 새 태그를 밀어야** 합니다. 목적은 공격자가 **같은 태그로 오염된 이미지를 덮어쓰는 것**을 막는 것입니다.
- CloudFormation에서는 `AWS::ECR::Repository`의 `ImageTagMutability: IMMUTABLE`.
- ⚠️ **`latest` 태그 재사용과 정면으로 부딪힙니다** — 불변 태그를 켜면 `latest`를 계속 밀 수 없습니다. "롤백 가능한 배포"와 묶여 나오기 좋은 지점입니다.

**수명 주기 정책**은 평가 방식이 비자명합니다.

- 조건을 만족한 이미지는 **24시간 이내**에 처리되고 결과는 **CloudTrail 이벤트**로 남습니다. 적용 전 **미리 보기(preview)**가 권장 절차입니다.
- ⚠️ **우선순위 숫자가 작을수록 높은 우선순위**입니다(1이 2보다 우선).
- ⚠️ 모든 규칙이 **동시에 평가**된 뒤 우선순위로 적용되고, **이미지 하나는 정확히 0개 또는 1개 규칙**에만 처리됩니다 — 높은 우선순위 규칙이 표시한 이미지를 낮은 규칙이 가져갈 수 없습니다.
- 만료 순서는 항상 `pushed_at_time` 기준 **오래된 것부터**입니다.
- ⚠️ **`tagPatternList`와 `tagPrefixList`는 한 규칙에 함께 쓸 수 없고**(정책 전체에는 섞일 수 있습니다), 둘 다 **`tagStatus`가 `tagged`일 때만** 씁니다. `tagPatternList`의 와일드카드는 **문자열당 최대 4개**입니다(`prod*`는 `prod`·`prod1`·`production-team1`에 걸립니다).
- `countType`은 `imageCountMoreThan`·`sinceImagePushed`·`sinceImagePulled`·`sinceImageTransitioned`이고, `countUnit`은 **뒤의 세 가지에만** 씁니다.
- ⚠️ **매니페스트 목록이 참조하는 이미지**는 그 목록을 먼저 지우거나 보관하지 않으면 **만료되지 않습니다.**

> 🧠 **원리** — "0개 또는 1개 규칙"이 수명 주기 정책의 핵심입니다. 규칙은 **겹쳐서 누적되지 않고** 우선순위로 **배타적으로** 적용되므로, "두 규칙을 걸었는데 하나만 먹는다"는 정상 동작입니다.

### 6) 코드·아티팩트 저장소 (기술 3.1.3) {#repos}

배포 환경은 **"소스·의존성·배포 단위가 각각 어디 있는지"**를 알아야 합니다.

| 저장소 | 저장 대상 | 배포 환경에서의 쓰임 |
|---|---|---|
| **AWS CodeConnections** | 외부 Git(GitHub·GitLab·Bitbucket) | **"연결(connection)" 리소스 ARN**을 CodePipeline·CodeBuild·CodeDeploy에 부여 — 템플릿에 비밀을 두지 않는다. 옛 이름 CodeStar Connections |
| **AWS CodeArtifact** | 패키지(npm·PyPI·Maven·NuGet 등) | 빌드 시 의존성 조회, 사내 패키지 공유 |
| **Amazon ECR** | 컨테이너 이미지 | Lambda 이미지 함수·컨테이너 서비스의 이미지 소스(**함수와 같은 리전**) |
| **Amazon S3** | `.zip` 번들·CodeDeploy 리비전 | CodePipeline 소스 액션, CodeDeploy 리비전 위치 |

- ⚠️ **CodeCommit은 C03 in-scope 서비스 목록에 없습니다**(Developer Tools는 Amplify · CloudShell · CodeArtifact · CodeBuild · CodeDeploy · CodePipeline · X-Ray). 외부 Git + **CodeConnections**가 기본 경로입니다.
- **CodeArtifact 개념**: 리포지토리는 하나의 **도메인**에 속하고, 도메인이 패키지 자산·메타데이터를 **한 번만 저장**하며 같은 KMS 키로 암호화합니다. **업스트림**을 걸면 상위 리포지토리의 패키지가 하위에서 보이고, **공개 저장소 외부 연결**을 만들면 요청 시 가져와 저장해 둡니다. ⚠️ **CodeArtifact의 패키지는 공개할 수 없습니다.**
- **CodeArtifact 인증**: AWS 자격 증명으로 **권한 토큰**을 발급합니다(`aws codeartifact login`). 토큰 기본 유효 **12시간**(15분~12시간), ⚠️ **루트 사용자는 `GetAuthorizationToken`을 호출할 수 없습니다.**

> 🧠 **원리** — 세 질문으로 나누면 보기에서 헷갈리지 않습니다 — **"소스를 어디서 가져오나"**(외부 Git + CodeConnections · S3 · ECR), **"의존성을 어디서 가져오나"**(CodeArtifact), **"무엇을 배포 단위로 보관하나"**(S3 `.zip` · ECR 이미지).

### 7) 환경별 구성 — 어디에 둘까 (기술 3.1.4) {#config-where}

고르는 기준은 하나입니다 — **"값을 바꿀 때 무엇이 필요한가."**

| 위치 | 값을 바꿀 때 | 한도 | 적합한 용도 |
|---|---|---|---|
| 패키지 안 구성 파일 | **새 패키지 빌드·배포** | 250 MB 안 | 환경과 무관한 고정 기본값 |
| Lambda 환경 변수 | `$LATEST` 변경 후 **새 버전 게시**(게시 버전은 불변) | 합계 **4 KB** | 환경별 단순 값(DB 호스트·로그 수준) |
| **Parameter Store** | **파라미터 갱신**(앱이 조회) | 표준 **4 KB**·1만 개 / 고급 8 KB·10만 개 | 이름 경로로 정리한 구성(`/myapp/dev/log-level`) |
| **Secrets Manager** | **시크릿 갱신** | **64 KB** | DB 자격 증명·API 키 |
| **AppConfig** | **배포**(점진·검증·경보 롤백) | 호스팅 기본 2 MB·최대 4 MB | **기능 플래그·동적 구성**·허용/차단 목록·스로틀링 한도 |

**같은 템플릿으로 여러 환경**을 다루는 수단도 함께 묻습니다.

| 도구 | 역할 |
|---|---|
| **Parameters** | 스택 생성·업데이트 시 값 주입. 템플릿당 최대 **200개**, 값 최대 4,096바이트 |
| **Mappings** | 키-값 조회표(`Fn::FindInMap`)로 환경·리전별 값 선택. 템플릿당 최대 200개 |
| **Conditions** | 조건이 참일 때만 리소스·출력을 만들거나 속성을 분기. ⚠️ **리소스 논리 ID·속성은 참조할 수 없습니다** |
| **SSM 파라미터 타입** | 템플릿 파라미터가 Parameter Store 값을 가리킨다. ⚠️ `AWS::SSM::Parameter::Name`은 **존재 확인용**이고 값을 가져오지 않는다 |
| **`samconfig.toml`** | 환경 이름별 SAM CLI 인자 묶음(`[prod.deploy.parameters]`) |

- ⚠️ **우선순위**: 명령줄 값 > 설정 파일 값 > 템플릿 `Parameters` 기본값. 설정 파일 안에서는 **명령별 항목이 `global`보다 우선**합니다.

> 🧠 **원리** — 환경 차이는 **"코드"가 아니라 "값"**입니다. 같은 템플릿·같은 아티팩트에 다른 값을 주입하게 만들면 환경마다 템플릿을 복제하지 않아도 됩니다. 그래서 "환경마다 스택을 따로 만든다"가 아니라 "파라미터를 따로 준다"가 정답 방향입니다.

### 8) AppConfig — 재배포 없이 바꾸기 (기술 3.1.4) {#appconfig}

운영 중인 동작을 **코드 재배포 없이** 안전하게 바꾸는 서비스입니다. 기능 플래그와 자유 형식 동적 구성을 다룹니다.

**리소스 계층**: **Application**(네임스페이스) → **Environment**(배포 대상의 논리 그룹. ⭐ **CloudWatch 경보를 연결하면 배포 중 경보 시 자동 롤백**) → **Configuration profile**(데이터 위치 URI + 유형 + 선택적 **검증기**) → **Deployment strategy**(속도·베이크 타임) → **Deployment**.

- **프로파일 유형**: **Feature flags**는 **호스팅 구성 저장소만**, **Free-form**은 호스팅·S3·Secrets Manager·Parameter Store·SSM 문서·CodePipeline을 쓸 수 있습니다. 호스팅 저장소를 **가능하면 우선** 쓰라고 권장합니다(기능이 가장 많습니다).
- **검증기**: 프로파일당 **최대 2개**이고 **프로파일보다 먼저** 만들어야 합니다. 유형은 **Lambda 함수**(둘 다 지원)와 **JSON Schema**(free-form). ⚠️ 배포 때 평가해 **실패하면 자동 롤백**합니다.
- **배포 전략 구성 요소**: 배포 유형(**Linear** / **Exponential**) · 단계 비율 · 배포 시간(⚠️ **타임아웃이 아니라 시간 창**) · ⭐ **베이크 타임**(100% 배포 후 경보를 감시하는 시간, 이 안에 울리면 롤백).
- 사전 정의 전략 예: `AppConfig.Linear20PercentEvery6Minutes`(6분마다 20%, 30분 배포, 30분 감시) · `AppConfig.Canary10Percent20Minutes`.

> 🧠 **원리** — **베이크 타임이 있어야** 100% 배포 직후가 아니라 **시간이 지나서 드러나는 오류**도 자동 롤백으로 잡힙니다. 그래서 AppConfig의 가치는 "빨리 바꾸기"가 아니라 **"안전하게 바꾸고 자동으로 되돌리기"**입니다.

### 9) API Gateway 스테이지와 엔드포인트 (기술 3.1.5) {#stages}

⚠️ **C02의 Task 3.4에서 이동해 온 기술**입니다. 공식 문구는 "API Gateway 기능 및 리소스를 사용합니다(예: **단계별 URL**·엔드포인트)"입니다.

- ⭐ **배포(deployment)는 API의 스냅샷**이고, **스테이지(stage)는 특정 배포를 가리키는 이름 있는 참조**입니다. 스테이지에 **캐시·스로틀링·로깅·WAF·클라이언트 인증서·스테이지 변수·카나리**를 붙입니다.
- ⚠️ **REST API는 변경을 반영하려면 재배포**해야 하고, **롤백은 이전 배포를 다시 활성화**하는 것입니다. HTTP API도 배포해야 반영되며 **자동 배포**를 켤 수 있고 **`$default` 스테이지는 URL 루트**에서 서비스됩니다.
- ⚠️ **재배포가 필요한 것과 아닌 것**: 메서드·통합·리소스·권한 부여자 같은 **리소스 업데이트는 필요**, **구성 업데이트는 불필요**합니다.
- 스테이지 세부: 이름은 영숫자·하이픈·밑줄 **최대 128자**. ⚠️ **스로틀링은 최선 노력**이고(비용·차단 수단이 아닙니다) 스테이지 값은 **계정 한도를 넘길 수 없습니다.** 캐시는 **프리티어 비대상**입니다.
- **카나리 릴리스(스테이지 수준)**: 스테이지가 운영 릴리스이고 거기에 `canarySettings`(배포 ID · 트래픽 비율 **0.0~100.0** · 카나리 전용 스테이지 변수 · 캐시 사용 여부)를 붙여 요청을 **무작위로** 나눕니다. 카나리 요청은 **`/Canary` 접미어 로그 그룹**으로 따로 쌓입니다. ⚠️ **승격**은 ① 스테이지의 배포 ID를 카나리 것으로 교체 ② 스테이지 변수 갱신 ③ 비율 0.0%이고, **승격만으로 카나리가 해제되지는 않습니다.**
- **스테이지 변수**: HTTP 통합 URI · **Lambda 함수 이름·버전·별칭** · 매핑 템플릿 · Cognito 사용자 풀 등에 `${stageVariables.이름}`으로 넣습니다. ⚠️ **통합 유형 자체를 바꿀 수는 없습니다.** ⚠️ Lambda 이름을 스테이지 변수로 지정하면 **Lambda의 리소스 기반 권한을 직접 설정**해야 하고, 그 Lambda는 API와 **같은 계정**이어야 합니다. ⚠️ **민감 정보를 스테이지 변수에 넣지 않습니다.**
- **커스텀 도메인**: **엣지 최적화**는 REST만·ACM 인증서가 **us-east-1**, **Regional**은 REST·HTTP 모두·인증서가 **같은 리전**, **프라이빗**은 프라이빗 API용입니다. ⚠️ **엣지↔Regional 마이그레이션은 되지만 퍼블릭 → 프라이빗은 불가**합니다.

> 🧠 **원리** — "배포는 스냅샷, 스테이지는 포인터"라는 구조 덕분에 **롤백이 재배포가 아니라 포인터 교체**가 됩니다. 스테이지 변수는 그 포인터에 **환경별 값**을 달아, 같은 API 정의로 여러 백엔드를 가리키게 해 줍니다.

---

## ✍️ 시험 포인트

- **"패키지가 250 MB를 넘는다"** → **컨테이너 이미지**(10 GB). 그 대가로 **계층을 쓸 수 없습니다.**
- **"이미지 푸시가 느리고 커진다"** → **베이스 이미지 축소 · 명령 체이닝 · 변경 적은 의존성을 앞쪽 · 멀티스테이지**.
- **"같은 태그로 덮어쓴 이미지가 배포됐다"** → **`ImageTagMutability: IMMUTABLE`**(기본은 `MUTABLE`).
- **"규칙을 둘 걸었는데 하나만 먹는다"** → 정상입니다. **이미지 하나는 0 또는 1개 규칙**에만 걸리고 **작은 숫자가 우선**입니다.
- **"코드 재배포 없이 기능을 끄고, 문제가 생기면 자동으로 되돌리기"** → **AppConfig**(환경에 CloudWatch 경보 + **베이크 타임**).
- **"DB 자격 증명"** → Secrets Manager. **"로그 수준"** → 환경 변수나 Parameter Store. **"기능 플래그"** → AppConfig.
- **"API를 수정했는데 호출 결과가 그대로다"** → **재배포**가 필요한 리소스 변경입니다. 롤백은 **이전 배포 재활성화**.
- **"스테이지마다 다른 Lambda 별칭을 호출"** → **스테이지 변수**(`…function:이름:${stageVariables.alias}`) + **Lambda 리소스 기반 권한 직접 설정**.
- **"CodeCommit을 고르는 보기"** → ⚠️ C03 **in-scope 목록에 없습니다.** 외부 Git + **CodeConnections**가 기본입니다.

---

## ⚠️ 흔한 함정 {#pitfalls}

| 함정 | 바로잡기 |
|---|---|
| 핸들러를 하위 폴더에 넣고 `.zip`을 만든다 | 핸들러와 의존성은 **zip 루트**에 둔다 |
| 계층 의존성을 루트에 둔다 | **런타임별 규정 폴더**(`python/`·`nodejs/node_modules`)여야 인식된다 |
| 컨테이너 이미지 함수에 계층을 붙이려 한다 | 계층은 **`.zip` 함수 전용**이다 |
| `appspec.yml`을 하위 폴더에 둔다 | **리비전 루트**가 아니면 배포가 실패한다 |
| Beanstalk 번들을 부모 폴더째 압축한다 | **최상위 폴더 없이** 압축한다(숨김 폴더 누락 때문에 명령줄 `zip` 권장) |
| Dockerfile에서 지운 파일이 이미지에서 사라진다고 본다 | **그 레이어에 남는다** — 명령을 체이닝한다 |
| 자주 바뀌는 소스를 Dockerfile 앞쪽에 둔다 | 뒤 레이어가 **매번 다시 빌드**된다 — 변경 적은 것을 앞에 |
| ECR 태그가 기본적으로 불변이라고 본다 | 기본은 **`MUTABLE`**(덮어쓰기 허용) |
| 수명 주기 규칙이 누적 적용된다고 본다 | **0 또는 1개 규칙**만 적용되고 **작은 숫자가 우선** |
| 한 규칙에 `tagPatternList`와 `tagPrefixList`를 함께 쓴다 | **함께 쓸 수 없다**(둘 다 `tagStatus: tagged` 전용) |
| 게시된 Lambda 버전의 환경 변수를 바꾸려 한다 | 게시 버전은 **불변** — `$LATEST`에서 바꾸고 새 버전을 게시한다 |
| AppConfig 검증기를 프로파일 뒤에 만든다 | **프로파일보다 먼저** 만들어야 한다(최대 2개) |
| AppConfig "배포 시간"을 타임아웃으로 본다 | **간격을 두고 배포하는 시간 창**이다 |
| API Gateway 구성 변경에 재배포가 필요하다고 본다 | **리소스 변경만** 필요하다 |
| 카나리를 승격하면 카나리가 꺼진다고 본다 | **승격만으로 해제되지 않는다** — 설정을 따로 제거한다 |
| 스테이지 변수로 통합 유형을 바꾸려 한다 | **유형 자체는 바꿀 수 없다**(엔드포인트·이름·별칭만) |
| 스테이지 변수에 자격 증명을 넣는다 | **민감 정보 금지** — 권한 부여자 출력으로 전달한다 |

---

## 🧪 자가 점검

**Q1.** 이미지 빌드가 매번 처음부터 돌고 이미지가 1.2 GB까지 커졌다. Dockerfile에서 무엇을 고치는가? (→ 4) Dockerfile)

<details><summary>정답 보기</summary>

세 가지입니다. ① ⭐ **변경이 가장 적은 의존성을 앞쪽으로** 옮깁니다 — Docker가 레이어를 캐시하지만 **각 레이어는 앞 레이어에 의존**해서, 자주 바뀌는 소스가 앞에 있으면 **그 뒤 전부가 다시 빌드**됩니다. ② ⭐ **명령을 체이닝**합니다 — 한 레이어에서 만든 중간 파일은 **뒤 레이어에서 지워도 그 레이어에 남습니다.** ③ **멀티스테이지 빌드**로 빌드 도구를 최종 이미지에서 떼고 **더 작은 베이스 이미지**를 씁니다(크기와 **공격 표면**이 함께 줄어듭니다).

덤으로 **Dockerfile 린팅**은 보안 모범 사례이면서 **쓰이지 않는·낡은 의존성**을 찾아 줍니다.
</details>

**Q2.** ECR에 수명 주기 규칙 둘을 걸었는데 한쪽만 동작하는 것처럼 보인다. 정상인가? 규칙 작성에서 함께 쓸 수 없는 것은? (→ 5) ECR)

<details><summary>정답 보기</summary>

**정상입니다.** 모든 규칙이 동시에 평가된 뒤 우선순위로 적용되는데, ⚠️ **이미지 하나는 정확히 0개 또는 1개 규칙**에만 처리됩니다 — 높은 우선순위 규칙이 표시한 이미지를 낮은 규칙이 가져갈 수 없습니다. **우선순위는 숫자가 작을수록 높습니다.**

함께 쓸 수 없는 것은 ⚠️ **한 규칙 안의 `tagPatternList`와 `tagPrefixList`**입니다(정책 전체에는 둘을 쓰는 규칙이 섞일 수 있습니다). 둘 다 **`tagStatus`가 `tagged`일 때만** 쓰고, 와일드카드는 **문자열당 최대 4개**입니다. 처리는 조건 충족 후 **24시간 이내**이고 적용 전 **미리 보기**가 권장 절차입니다.
</details>

**Q3.** 운영 중 특정 기능을 즉시 끄고, 오류율이 오르면 자동으로 되돌리고 싶다. 코드 재배포는 피해야 한다. 무엇을 어떻게 구성하는가? (→ 8) AppConfig)

<details><summary>정답 보기</summary>

**AWS AppConfig의 기능 플래그**입니다. 계층은 **Application → Environment → Configuration profile → Deployment strategy → Deployment**이고, 자동 롤백의 두 축은 ① **Environment에 CloudWatch 경보를 연결**하고 ② 배포 전략의 ⭐ **베이크 타임**(100% 배포 후 경보를 감시하는 시간)을 두는 것입니다.

⚠️ **기능 플래그는 호스팅 구성 저장소만** 쓸 수 있습니다(free-form은 S3·Parameter Store·Secrets Manager 등도 가능). **검증기**는 프로파일당 **최대 2개**이고 **프로파일보다 먼저** 만들어야 하며, 배포 때 검증에 실패하면 역시 자동 롤백합니다. "배포 시간"은 타임아웃이 아니라 **간격을 두고 배포하는 시간 창**입니다.
</details>

**Q4.** REST API의 Lambda 통합을 바꿨는데 호출 결과가 그대로다. 원인과, 문제가 생겼을 때 되돌리는 방법은? (→ 9) 스테이지)

<details><summary>정답 보기</summary>

**재배포하지 않았기** 때문입니다. **배포는 API의 스냅샷**이고 **스테이지는 그 배포를 가리키는 이름 있는 참조**라서, 메서드·통합·리소스·권한 부여자 같은 **리소스 업데이트는 재배포가 필요**합니다(반면 **구성 업데이트는 필요 없습니다**).

롤백은 **이전 배포를 다시 활성화**하는 것입니다 — 포인터를 되돌리는 일이라 재빌드가 필요 없습니다. 점진적으로 내보내려면 스테이지에 **`canarySettings`**를 붙여 트래픽 비율(0.0~100.0)로 나누고, 카나리 요청은 **`/Canary` 접미어 로그 그룹**에 따로 쌓입니다. ⚠️ **승격만으로 카나리가 해제되지 않습니다.**
</details>

**Q5.** dev·staging·prod가 같은 아티팩트를 쓰되 DB 호스트와 로그 수준만 달라야 한다. 어디에 두고, 우선순위는? (→ 7) 환경별 구성)

<details><summary>정답 보기</summary>

**"값을 바꿀 때 무엇이 필요한가"**로 고릅니다. 단순 환경별 값은 **Lambda 환경 변수**(합계 4 KB, ⚠️ 게시 버전은 불변이라 `$LATEST`에서 바꿔 새 버전을 게시)나 **Parameter Store**(갱신만으로 반영, 표준 4 KB)입니다. DB **자격 증명**은 Secrets Manager, **기능 플래그·동적 구성**은 AppConfig입니다. 패키지 안 구성 파일은 **재배포**가 필요하므로 환경과 무관한 기본값에만 씁니다.

템플릿 쪽은 **Parameters·Mappings·Conditions**와 `samconfig.toml`의 환경별 묶음으로 주입하고, ⚠️ 우선순위는 **명령줄 값 > 설정 파일 값 > 템플릿 기본값**이며 설정 파일 안에서는 **명령별 항목이 `global`보다 우선**합니다.
</details>

**Q6.** 외부 GitHub 저장소를 CodePipeline 소스로 쓰려 한다. 무엇을 만들고, C03에서 CodeCommit을 고르면 안 되는 이유는? (→ 6) 저장소)

<details><summary>정답 보기</summary>

**AWS CodeConnections의 "연결(connection)" 리소스**를 만들고 그 **ARN**을 CodePipeline·CodeBuild·CodeDeploy에 부여합니다 — 그래서 템플릿에 비밀·파라미터를 따로 두지 않습니다(옛 이름 CodeStar Connections).

⚠️ **CodeCommit은 DVA-C03의 in-scope 서비스 목록에 없습니다.** C03의 Developer Tools는 **Amplify · CloudShell · CodeArtifact · CodeBuild · CodeDeploy · CodePipeline · X-Ray**뿐입니다. 의존성은 **CodeArtifact**에서 가져오고(토큰 기본 유효 **12시간**, ⚠️ 루트 사용자는 `GetAuthorizationToken` 호출 불가), 배포 단위는 **S3 `.zip`** 또는 **ECR 이미지**로 보관합니다.
</details>

**Q7.** `.zip` 함수를 배포했는데 `Unable to import module` 류로 실패한다. 구조에서 무엇을 확인하는가? 그리고 계층은 어떻게 다른가? (→ 3) 번들 구조)

<details><summary>정답 보기</summary>

⚠️ **핸들러 파일과 모든 의존성이 zip 루트에 있는지**를 확인합니다 — 루트에 없으면 실행되지 않습니다. 파일 권한은 **644**, 디렉터리·실행 파일은 **755**여야 합니다.

**계층은 규칙이 다릅니다** — 런타임별 **규정 폴더**(Python은 `python/`, Node.js는 `nodejs/node_modules`)에 둬야 인식되고, 내용은 **`/opt`에 추출**됩니다. 계층 버전은 **변경 불가능한 스냅샷**이라 ARN에 **버전 번호까지** 지정하며, 함수당 **5개**이고 **압축 해제 합계 250 MB 한도에 포함**됩니다.
</details>

---

### 📌 출처

1. Lambda quotas — https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-limits.html
2. Create a Lambda function using a container image — https://docs.aws.amazon.com/lambda/latest/dg/images-create.html
3. Managing Lambda dependencies with layers — https://docs.aws.amazon.com/lambda/latest/dg/chapter-layers.html
4. Packaging your layer content — https://docs.aws.amazon.com/lambda/latest/dg/packaging-layers.html
5. Working with .zip file archives for Python Lambda functions — https://docs.aws.amazon.com/lambda/latest/dg/python-package.html
6. Default build with AWS SAM — https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-using-build.html
7. AWS SAM CLI configuration file — https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-config.html
8. AWS SAM template anatomy — https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/sam-specification-template-anatomy.html
9. Optimizing performance for Amazon ECR — https://docs.aws.amazon.com/AmazonECR/latest/userguide/performance.html
10. Improving containerized CI/CD pipelines (Well-Architected Container Build Lens) — https://docs.aws.amazon.com/wellarchitected/latest/container-build-lens/improving-containerized-cicd-pipelines-from-performance-efficiency-and-cost-perspective.html
11. Amazon ECR lifecycle policies — https://docs.aws.amazon.com/AmazonECR/latest/userguide/LifecyclePolicies.html
12. Amazon ECS task and container security best practices (불변 태그) — https://docs.aws.amazon.com/AmazonECS/latest/developerguide/security-tasks-containers.html
13. Integrations with CodePipeline action types — https://docs.aws.amazon.com/codepipeline/latest/userguide/integrations-action-type.html
14. What is AWS CodeArtifact? — https://docs.aws.amazon.com/codeartifact/latest/ug/welcome.html
15. AWS CodeArtifact authentication and tokens — https://docs.aws.amazon.com/codeartifact/latest/ug/tokens-authentication.html
16. What is AWS AppConfig? — https://docs.aws.amazon.com/appconfig/latest/userguide/what-is-appconfig.html
17. Working with deployment strategies (AppConfig) — https://docs.aws.amazon.com/appconfig/latest/userguide/appconfig-creating-deployment-strategy.html
18. Using predefined deployment strategies (AppConfig) — https://docs.aws.amazon.com/appconfig/latest/userguide/appconfig-creating-deployment-strategy-predefined.html
19. Working with Lambda environment variables — https://docs.aws.amazon.com/lambda/latest/dg/configuration-envvars.html
20. Set up a stage for a REST API in API Gateway — https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-stages.html
21. Updates to REST APIs that require redeployment — https://docs.aws.amazon.com/apigateway/latest/developerguide/updating-api.html
22. Stages for HTTP APIs in API Gateway — https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-stages.html
23. Set up an API Gateway canary release deployment — https://docs.aws.amazon.com/apigateway/latest/developerguide/canary-release.html
24. Promote a canary release — https://docs.aws.amazon.com/apigateway/latest/developerguide/promote-canary-deployment.html
25. Custom domain name for public REST APIs in API Gateway — https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-custom-domains.html
26. DVA-C03 공식 시험 가이드 · 콘텐츠 도메인 3 (한국어) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/developer-associate-03/developer-associate-03-domain3.html
27. DVA-C03 범위 내 AWS 서비스 (한국어) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/developer-associate-03/dva-03-in-scope-services.html
