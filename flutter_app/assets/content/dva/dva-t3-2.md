---
examGuideTaskId: dva-t3-2
certCode: DVA-C03
domain: 3
domainName: 테스트 및 배포
domainWeightPct: 22
title: 테스트 구현·자동화 (클라우드 테스트·모의·테스트 이벤트·환경·AI 테스트)
coversTasks:
  - "3.2"
sources:
  - title: How to test serverless functions and applications (Lambda)
    url: https://docs.aws.amazon.com/lambda/latest/dg/testing-guide.html
  - title: Mock integrations for REST APIs in API Gateway
    url: https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-mock-integration.html
  - title: Testing Lambda functions in the console
    url: https://docs.aws.amazon.com/lambda/latest/dg/testing-functions.html
  - title: Invoke (Lambda API Reference)
    url: https://docs.aws.amazon.com/lambda/latest/api/API_Invoke.html
  - title: Introduction to testing in the cloud with sam remote invoke
    url: https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/using-sam-cli-remote-invoke.html
  - title: Create an alias for a Lambda function
    url: https://docs.aws.amazon.com/lambda/latest/dg/configuration-aliases.html
  - title: Pattern-based feature branch deployments (AWS Amplify Hosting)
    url: https://docs.aws.amazon.com/amplify/latest/userguide/pattern-based-feature-branch-deployments.html
  - title: Testing state machines with TestState API (Step Functions)
    url: https://docs.aws.amazon.com/step-functions/latest/dg/test-state-isolation.html
  - title: DVA-C03 공식 시험 가이드 · 콘텐츠 도메인 3 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/developer-associate-03/developer-associate-03-domain3.html
lastVerified: 2026-11-01
---

# 테스트 구현·자동화 (클라우드 테스트·모의·테스트 이벤트·환경·AI 테스트)

> **커버하는 공식 Task** — DVA-C03 · 도메인 3 「테스트 및 배포」(22%) · **작업 3.2 AWS 환경에서 애플리케이션 테스트를 구현하고 자동화합니다** (`dva-t3-2`)
> 이 문서는 위 한 작업에 1:1로 매핑되고, 공식 기술 다섯 개(3.2.1~3.2.5)를 모두 덮습니다.

> ⚠️ **C03에서 두 Task가 하나로 통합됐습니다.** C02의 Task 3.2(테스트 구현)와 Task 3.3(테스트 자동화) **11개 기술이 C03의 3.2 다섯 개**로 묶였고, **기술 3.2.5 AI 도구로 테스트 생성·반복 워크플로 자동화가 신설**됐습니다. 그리고 **SAM 로컬 단위 테스트가 작업 1.1에서 이 작업으로** 왔습니다.
>
> ⚠️ **배포 전략·CodeDeploy·CodePipeline은 여기가 아닙니다** — 작업 3.3(`dva-t3-3`)입니다. 이 작업은 **테스트와 "환경을 만들어 두는 것"**까지입니다.

---

## ✅ 학습 목표 체크리스트

- [ ] 단위·통합·E2E를 구분하고 **왜 클라우드 테스트가 기준인지** 설명한다
- [ ] 클라우드 테스트·모의·SAM 로컬·에뮬레이션의 **한계**를 각각 말한다
- [ ] 배포된 코드를 테스트하는 도구를 **무엇을 확인하려는가**로 고른다
- [ ] API Gateway **MOCK 통합**으로 백엔드 없이 응답을 만들 수 있다
- [ ] 테스트 이벤트를 만드는 세 경로(콘솔·`generate-event`·공유 이벤트)를 안다
- [ ] Lambda 버전·별칭으로 **"승인된 버전" 환경**을 만든다
- [ ] 이미지 태그와 **다이제스트**의 차이로 배포를 고정할 수 있다
- [ ] 기술 3.2.5의 AI 테스트 자동화를 **범위 내 도구**로 설명한다

---

## 🎯 왜 중요한가

이 작업의 문항은 **"어디서 테스트하는가"**와 **"무엇이 검증되지 않는가"**를 묻습니다. 공식 문서의 입장이 분명해서 외우기도 쉽습니다 — **클라우드에 배포한 것을 테스트하는 것이 가장 정확하고**, 로컬·모의는 **IAM 권한·할당량·설정을 검증하지 못합니다.**

"환경"이라는 말도 서비스마다 단위가 달라 혼동이 큽니다. 그래서 **Lambda는 별칭 · 컨테이너는 이미지 태그·다이제스트 · Amplify는 브랜치 · API Gateway는 스테이지**라는 대응을 한 번 외워 두면 3.2.4 문항이 거의 풀립니다.

---

## ⚡ 시험 직전 요약

> 시험 직전에 이 열 줄만 다시 봅니다. 근거와 맥락은 아래 본문에 있습니다.

- ⭐ **클라우드 테스트가 기준입니다** — 큐·테이블·이벤트 버스·**보안 정책**은 로컬에서 완전히 복제할 수 없습니다. 순수 계산 함수도 **타임아웃·메모리·로그 권한(IAM)**이 결과를 좌우합니다
- **로컬·모의가 검증하지 못하는 것**: **IAM 권한·할당량·설정**. ⚠️ `sam local`의 AWS 호출은 **실제 리소스로 나갑니다**
- **`Invoke`의 `InvocationType`**: `RequestResponse`(동기, 200) · `Event`(비동기, 202) · ⭐ **`DryRun`**(권한·파라미터 검증만, 204). **`LogType=Tail`**이면 동기 응답에 실행 로그 **마지막 4 KB**가 들어옵니다
- **콘솔 테스트 이벤트는 함수당 10개**이고, **공유 가능 테스트 이벤트**는 EventBridge 스키마 레지스트리 **`lambda-testevent-schemas`**에 저장됩니다(`schemas:*` 권한 필요)
- **`sam local generate-event`**로 서비스별 샘플 이벤트를 만들고, **`sam remote invoke`**로 **배포된** 리소스를 호출합니다(Lambda·SQS·Kinesis·Step Functions)
- **백엔드 없이 응답을 돌려주려면 API Gateway MOCK 통합** — 통합 요청 템플릿이 `{"statusCode": 200}`을 만들고 **같은 상태 코드의 통합 응답 템플릿**이 본문을 만듭니다
- **로그를 남기려면** 실행 역할에 `logs:CreateLogGroup`·`CreateLogStream`·`PutLogEvents`(관리형 정책 **`AWSLambdaBasicExecutionRole`**)가 필요합니다
- **X-Ray 샘플링은 초당 1건 + 추가 요청의 5%**이고 ⚠️ **함수에서 바꿀 수 없습니다.** 추적 모드는 `Active`·`PassThrough`
- **환경 단위**: Lambda **별칭** · 컨테이너 **이미지 태그·다이제스트** · Amplify **브랜치** · API Gateway **스테이지**. ⚠️ **가중 별칭은 게시된 버전 2개만** 가리키고 `$LATEST`는 불가합니다
- ⚠️ **Lambda 컨테이너 함수는 배포 시 태그를 다이제스트로 해석**합니다 — ECR에서 태그를 옮겨도 **함수는 자동 갱신되지 않습니다**

---

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **모의(mock)** | 코드 안에서 외부 서비스를 흉내 내는 객체. 빠르지만 **IAM·할당량을 검증하지 못한다** |
| **에뮬레이션** | 서비스 API를 흉내 내는 독립 앱(서드파티). 서비스 업데이트에 뒤처진다 |
| **MOCK 통합** | API Gateway가 **백엔드 없이** 매핑 템플릿으로 응답을 직접 만드는 통합 유형 |
| **공유 가능 테스트 이벤트** | 같은 계정 사용자와 공유·편집하는 Lambda 테스트 이벤트. 스키마 레지스트리에 저장된다 |
| **`DryRun`** | 실행하지 않고 **권한·파라미터만** 검증하는 호출 유형(204) |
| **별칭(alias)** | 게시된 Lambda 버전을 가리키는 **갱신 가능한 포인터**. 고유 ARN을 가진다 |
| **다이제스트(digest)** | `@sha256:…` — **특정 이미지**를 가리키는 불변 식별자. 태그는 옮겨 다니는 라벨이다 |
| **변경 세트(change set)** | 스택 변경이 실행 중 리소스에 미칠 영향을 **적용 전에** 보여 주는 CloudFormation 기능 |

---

## 📖 핵심 개념

### 1) 테스트 유형과 기법 — 클라우드가 기준이다 (기술 3.2.1) {#test-types}

서버리스에서도 유형은 같습니다 — **단위**(격리된 코드 블록) · **통합**(둘 이상의 구성 요소가 상호작용, 보통 클라우드) · **E2E**(애플리케이션 전체).

⭐ **AWS는 클라우드에 배포한 코드·서비스를 대상으로 하는 테스트가 품질을 가장 정확하게 보여 준다고 안내합니다.** 이유가 둘입니다 — 큐·테이블·이벤트 버스·**보안 정책**은 로컬에서 완전히 복제할 수 없고, 로컬과 클라우드의 차이가 **버그 재현·수정 시간을 늘립니다.**

⚠️ **다른 서비스를 호출하지 않는 순수 계산 함수도** 클라우드에서 확인해야 합니다 — **타임아웃·메모리 설정과 CloudWatch Logs 기록 권한(IAM)**이 결과를 좌우하고, 이것들은 모의·에뮬레이션으로 정확히 재현되지 않습니다.

| 기법 | 장점 | ⚠️ 한계 |
|---|---|---|
| **클라우드 테스트** | 가장 정확 — 실제 서비스·**IAM**·할당량·설정까지 검증 | 배포 시간·비용, 격리 환경 필요(**SAM Accelerate·CDK watch**로 완화) |
| **모의(mock)** | 서드파티 대체, **실패 재현**, 빠름 | 설정·유지 부담, **IAM·할당량 검증 불가**, 로컬 통과 후 클라우드 실패 |
| **SAM CLI 로컬** | 빠른 반복, 로컬 디버깅 | Docker 필요, ⚠️ **AWS 호출은 실제 리소스로 나간다**, 클라우드 권한 미검증 |
| **에뮬레이션**(서드파티) | 요금 없는 로컬 반복 | 서비스 업데이트에 뒤처짐, 결과가 클라우드와 다를 수 있어 **드물게 사용** |

- **테스트하기 쉬운 코드**: 핸들러는 이벤트·컨텍스트에서 필요한 값만 꺼내 **비즈니스 로직 메서드에 넘기는 얇은 어댑터**로 둡니다.
- **CI는 승격 전에** 클라우드에 프로비저닝한 리소스를 대상으로 테스트를 돌려야 합니다.

> 🧠 **원리** — 서버리스 애플리케이션의 상당 부분이 **코드가 아니라 구성**(IAM 정책·이벤트 소스 매핑·타임아웃)입니다. 구성은 로컬에 없으므로, 로컬 테스트는 **코드의 논리**만 검증할 수 있습니다. 그래서 단위 테스트는 로컬, **통합 이상은 클라우드**가 공식 권장입니다.

### 2) 배포된 코드를 테스트하는 도구 (기술 3.2.1) {#tools}

| 도구 | 쓰임 | 핵심 사실 |
|---|---|---|
| **Lambda 콘솔 Test 탭** | JSON 테스트 이벤트로 즉시 호출 | 서비스 통합용 **샘플 이벤트** 제공. 테스트 이벤트는 **함수당 10개** |
| **`aws lambda invoke`** | CLI·SDK 호출 | `RequestResponse`(200) · `Event`(202) · ⭐ **`DryRun`(204, 권한·파라미터만)**. **`LogType=Tail`** → 실행 로그 **마지막 4 KB**(base64) |
| **`sam remote invoke`** | **배포된** 리소스를 SAM CLI로 호출 | Lambda·SQS·Kinesis·Step Functions. `--event`·`--test-event-name`(공유 이벤트), `--parameter`로 `InvocationType=DryRun`·`Qualifier` 전달 |
| **CloudWatch Logs · `sam logs`** | 실행 로그 | 로그에는 **`AWSLambdaBasicExecutionRole`** 권한이 필요. `sam logs`는 **스택 이름 + 논리 ID**로 조회하고 `--tail`·`--filter` 지원 |
| **AWS X-Ray** | 요청 경로·병목·오류 | 추적 모드 **`Active`**(Lambda가 세그먼트 생성)·**`PassThrough`**(컨텍스트만). ⚠️ 샘플링 **초당 1건 + 5%**이고 **함수에서 설정 불가** |
| **API Gateway 테스트 호출** | 메서드 단위 | `aws apigateway test-invoke-method` — 요청에 **스테이지 변수**를 넣어 시뮬레이션 |
| **CloudWatch Synthetics canary** | 예약 스크립트로 지속 점검 | 고객과 같은 경로를 수행하는 스크립트(**Lambda 함수로 실행**)로 **트래픽이 없어도** 가용성·지연을 확인 |

**로컬 도구 네 개**는 쓰임이 다릅니다 — `sam local invoke`(일회성 호출, **로그는 stderr·결과는 stdout**) · `sam local start-api`(로컬 HTTP 서버, ⚠️ **개발용이고 프로덕션 금지**) · `sam local start-lambda`(로컬 Lambda 호출 엔드포인트) · **`sam local generate-event`**(샘플 이벤트 생성).

⭐ **같은 테스트를 로컬·클라우드에 재사용**하는 방법이 있습니다 — `sam local start-lambda`가 `http://127.0.0.1:3001`에서 Lambda 호출 엔드포인트를 흉내 내므로, SDK 클라이언트의 **`endpoint_url`만 바꿔** 같은 테스트를 로컬 함수와 배포된 함수에 **수정 없이** 돌릴 수 있습니다.

> 🧠 **원리** — 도구는 **"무엇을 확인하려는가"**로 고릅니다. 코드 논리는 로컬 호출, **권한**은 `DryRun`, 실행 중 동작은 CloudWatch Logs·X-Ray, **사용자가 없을 때의 가용성**은 Synthetics canary입니다.

### 3) 통합 테스트와 외부 종속성 모의 (기술 3.2.2) {#mocking}

공식 입장은 **"통합 테스트에 집중하라"**입니다. 앱을 클라우드에 배포한 뒤 테스트가 시스템을 호출해 기대 동작을 검증합니다 — 예를 들어 **API Gateway 엔드포인트에 합성 HTTP 호출**을 보내 응답을 확인하면 Lambda 코드뿐 아니라 **각 서비스 구성과 서비스 간 IAM 권한까지** 검증됩니다.

- **자동화 패턴**: 테스트가 먼저 **배포된 스택의 출력**(API 엔드포인트·함수 ARN·역할)을 가져오고, 그다음 엔드포인트로 요청을 보냅니다.
- **격리된 환경**: 개발자별 전용 계정이 이상적이고, 계정을 공유하면 **스택 이름 접두사**나 브랜치별 스택으로 소유권을 나눕니다. 사전 프로덕션·프로덕션은 **계정 단위로** 경계를 둡니다(할당량 간섭·고객 데이터 접근 방지).
- **모의를 쓸 곳**: 복잡한 내부 로직의 빠른 단위 테스트 · **통제할 수 없는 서드파티 API** · 재현하기 어려운 **서비스 장애**. ⚠️ **통합 테스트에서는 효과가 줄고 E2E에는 쓰지 않습니다.**

| 모의 수단 | 용도 | 핵심 사실 |
|---|---|---|
| **API Gateway MOCK 통합** | **백엔드 없이** API Gateway가 응답을 직접 생성(미구현 API를 의존 팀에 먼저 제공) | 통합 **요청** 매핑 템플릿이 `{"statusCode": 200}`을 만들면 **같은 상태 코드의 통합 응답** 템플릿이 본문을 만든다. 쿼리 파라미터로 성공·오류를 분기할 수 있다. ⚠️ 큰 응답에는 부적합 → Lambda 통합 |
| 코드 수준 모의·페이크 | 단위 테스트에서 SDK 대체 | 코드 안의 객체(프레임워크가 생성) |
| **Step Functions `TestState` + 모의** | 상태 로직을 **실제 서비스 호출 없이** 테스트 | `mock.result`·`mock.errorOutput` **중 하나만** 지정. 검증 모드 **STRICT(기본)·PRESENT·NONE**. 모의를 주면 `roleArn`은 선택. ⚠️ **콘솔 Test state는 모의 미지원**(CLI·SDK 전용) |

> 🧠 **원리** — 모의는 **"내 코드가 무엇을 하는가"**를 검증하고, 클라우드 테스트는 **"그 호출이 실제로 통하는가"**를 검증합니다. 서비스 호출 구현이 맞는지는 모의로 알 수 없으므로, 모의는 **대체할 수 없는 것**(서드파티·장애)에만 씁니다.

### 4) 테스트 이벤트 만들기 (기술 3.2.3) {#test-events}

공식 문구는 "애플리케이션 테스트 이벤트를 만듭니다(예: **JSON 페이로드**를 사용하여 Lambda 함수 및 API Gateway API 테스트)"입니다. 경로가 셋입니다.

1. **콘솔 테스트 이벤트** — 서비스 통합용 **템플릿**이 제공됩니다. 비공개 이벤트는 **함수당 10개**이고 작성자 전용입니다.
2. **공유 가능 테스트 이벤트** — 같은 계정 사용자와 공유·편집하며, ⭐ **EventBridge 스키마 레지스트리 `lambda-testevent-schemas`**에 저장되어 **`schemas:*` 권한**이 필요합니다.
3. **`sam local generate-event`** — 서비스별 샘플 이벤트를 만들어(예: `sam local generate-event s3 put`) **단위 테스트 입력**이나 `sam remote invoke`의 `--event-file`로 씁니다.

- API Gateway 쪽은 **`aws apigateway test-invoke-method`**로 메서드를 호출하고 요청에 **스테이지 변수**를 넣어 배포된 스테이지를 시뮬레이션합니다.

> 🧠 **원리** — 핸들러의 입력은 결국 **이벤트 JSON**입니다. 그래서 실제 이벤트 모양을 `generate-event`로 받아 단위 테스트 입력으로 쓰면, 서비스를 띄우지 않고도 **파싱·분기 로직**을 정확한 입력으로 검증할 수 있습니다.

### 5) 애플리케이션 환경 만들기 — 서비스별 단위 (기술 3.2.4) {#environments}

공식 예시는 **Lambda 별칭 · 컨테이너 이미지 태그 · Amplify 브랜치 · AWS Copilot 환경 · API Gateway API**입니다.

**Lambda 버전과 별칭**

- ⚠️ **`$LATEST`는 배포할 때마다 덮어써집니다.** **게시(publish)**하면 복사본이 새 버전이 되고 **코드·런타임·아키텍처·메모리·계층이 불변**이 됩니다(바꾸려면 `$LATEST`를 고쳐 재게시). 버전 번호는 **단조 증가하고 재사용되지 않습니다.**
- **별칭**은 **버전을 가리키는 갱신 가능한 포인터**이고 고유 ARN을 가집니다. ⚠️ **별칭은 다른 별칭을 가리킬 수 없습니다.** 이벤트 소스 매핑·리소스 정책에 **별칭 ARN**을 쓰면 버전이 바뀌어도 고칠 필요가 없습니다.
- **가중 별칭(카나리)**: 별칭 하나가 **최대 2개 버전**을 가리키고 ⚠️ **둘 다 게시된 버전**이어야 하며(`$LATEST` 불가) **같은 실행 역할·같은 DLQ 구성**이어야 합니다. ⚠️ **낮은 트래픽에서는 실제 비율이 설정값과 크게 다를 수 있습니다**(확률 모델).
- 어느 버전이 응답했는지는 응답 헤더 **`x-amz-executed-version`**, 로그의 `START … Version: N`, 별칭 지표의 **`ExecutedVersion`** 차원으로 봅니다.
- SAM의 **`AutoPublishAlias: live`**는 새 코드를 감지해 버전을 게시하고 `live` 별칭을 옮깁니다(점진 이동은 작업 3.3).

**컨테이너 이미지 태그와 다이제스트**

- ⚠️ **Lambda 컨테이너 함수는 배포 시 태그를 다이제스트로 해석**합니다 — ECR에서 태그가 새 이미지를 가리키도록 바꿔도 **함수는 자동 갱신되지 않습니다**(`update-function-code --image-uri` 재실행).
- **재태깅으로 승격**할 수 있습니다 — `batch-get-image`로 매니페스트를 얻어 `put-image --image-tag <새 태그>`를 쓰면 **pull·push 없이** 태그를 붙입니다.

**Amplify 브랜치 = 환경**

- Git 브랜치를 연결할 때마다 **새 배포**가 생깁니다(`main`=프로덕션, `develop`=통합). 기본 도메인은 `https://<브랜치>.<appid>.amplifyapp.com` 형태입니다.
- **패턴 기반 자동 감지**(`*`·`release*`)로 맞는 브랜치를 자동 연결·배포하고 **접근 제어(비밀번호)**를 걸 수 있습니다. **환경 변수는 기본적으로 모든 브랜치에 적용**되고 브랜치별 override를 둘 수 있습니다.
- **풀 리퀘스트 프리뷰**는 고유 미리보기 URL로 배포되고 PR이 닫히면 임시 백엔드가 삭제됩니다.

**`AWS Copilot 환경`** — ⚠️ 가이드 예시에 남아 있지만 **C03 범위 내 서비스 목록에는 없고** CLI는 **2026-06-12 지원이 끝났습니다**(기존 배포는 계속 동작). 공식 이전 경로는 **ECS Express Mode** 또는 **CDK L3 constructs**입니다. 개념(환경 = 네트워크·클러스터 같은 **공유 인프라 집합**)만 읽고 넘깁니다.

**API Gateway** — **스테이지**가 환경 단위입니다(`dva-t3-1` 9절).

> 🧠 **원리** — 모든 환경 전략이 같은 모양입니다 — **불변 산출물을 만들어 두고 포인터만 옮깁니다.** Lambda는 게시 버전(불변)과 별칭(포인터), 컨테이너는 다이제스트(불변)와 태그(포인터), API Gateway는 배포(불변)와 스테이지(포인터)입니다. 그래서 승격이 **재빌드가 아니라 포인터 교체**가 됩니다.

### 6) 스택 업데이트로 환경 만들기 (기술 3.2.4) {#stack-update}

`sam deploy`가 하는 일은 셋입니다 — ① `.zip`은 S3에, 이미지는 ECR에 업로드 ② **CloudFormation 변경 세트**를 만들어 배포 ③ 템플릿의 `CodeUri`를 새 위치로 갱신.

| 옵션 | 의미 |
|---|---|
| `--config-env <이름>` | `samconfig`의 환경 선택 → 같은 템플릿에 staging·prod 값 분리 |
| `--parameter-overrides` | 템플릿 `Parameters` 덮어쓰기 |
| **`--capabilities`** | IAM 리소스를 만들면 `CAPABILITY_IAM`·**`CAPABILITY_NAMED_IAM`**(이름 지정 시), 중첩 앱은 `CAPABILITY_AUTO_EXPAND`. ⚠️ 빠지면 **`InsufficientCapabilities`** 오류 |
| `--confirm-changeset` / `--no-execute-changeset` | 적용 전 확인 / **만들고 적용하지 않음** |
| `--disable-rollback`·`--on-failure` | 기본은 오류 시 롤백. `--on-failure`는 `ROLLBACK`·`DELETE`·`DO_NOTHING` |

**변경 세트와 업데이트 동작**이 이 절의 핵심입니다.

- 변경 세트는 변경이 **실행 중 리소스에 미칠 영향**(추가·수정·삭제·**교체**, 속성 전후 비교)을 보여 주고 **실행을 결정할 때만** 스택을 바꿉니다. ⚠️ **업데이트 성공을 보장하지는 않습니다.**
- 리소스 업데이트 동작 셋: **중단 없음**(물리 ID 유지) · **일부 중단** · ⚠️ **교체**(새 리소스를 만들고 참조를 옮긴 뒤 이전 것을 삭제 — **새 물리 ID**).
- ⚠️ **교체는 데이터 손실로 이어질 수 있습니다** — RDS 인스턴스 이름을 바꾸면 새 DB를 만들고 이전 DB를 삭제합니다. 그래서 **변경 세트로 교체 여부를 미리 확인**합니다.
- **`UpdateReplacePolicy`는 교체될 때**, **`DeletionPolicy`는 삭제될 때** 적용됩니다 — **적용 시점이 다릅니다.**
- ⚠️ 업데이트 실패 후 **롤백까지 실패하면 `UPDATE_ROLLBACK_FAILED`**가 되고 그 스택은 업데이트할 수 없습니다 — 오류를 고친 뒤 **`ContinueUpdateRollback`**으로 되돌립니다.
- **`sam sync`(SAM Accelerate)**는 ⚠️ **개발 환경용**입니다 — 서비스 API로 갱신할 수 있는 리소스(Lambda 코드)는 **변경 세트 절차를 건너뛰고** 바로 갱신합니다. 프로덕션은 `sam deploy`나 CI/CD를 권장합니다.

> 🧠 **원리** — 변경 세트는 **"무엇이 교체되는가"를 적용 전에 보는 창**입니다. CloudFormation의 위험은 대개 **교체**에서 나오고(새 리소스 + 이전 삭제), 그래서 프로덕션 스택에는 변경 세트 확인이 사실상 필수입니다.

### 7) AI 도구로 테스트 생성·자동화 (기술 3.2.5) {#ai-testing}

🆕 **C03 신설 기술**입니다. 공식 문구는 "**AWS AI 도구**를 사용하여 테스트를 만들고 **반복적인 테스트 워크플로를 자동화**합니다(예: 자동화된 테스트 실행, 테스트 결과 분석, **회귀 테스트 자동화**, 테스트 범위)"입니다.

⚠️ **기술 문구가 서비스 이름을 적지 않습니다.** 범위 내 「기계 학습 및 인공 지능」은 **Bedrock · Bedrock AgentCore · Amazon Quick · Kiro** 넷이고, 그중 **개발·테스트 워크플로에 해당하는 것은 Kiro**입니다.

- **Kiro Hooks** — 파일 저장·커밋 같은 **이벤트에 걸리는 자동 트리거**로 표준을 강제하고 **테스트를 실행**합니다. 기술 3.2.5의 "반복적인 테스트 워크플로 자동화"에 대응합니다.
- **Kiro Specs** — 요구사항 → 설계 → 작업 목록으로 쪼갠 뒤 구현하므로, 테스트 케이스를 **사양에서** 끌어낼 수 있습니다.
- ⚠️ **`Amazon Q Developer`는 범위 내 목록에 없습니다.** C02 교재는 이 자리를 Q Developer의 단위 테스트 생성(옛 `/test`)으로 다뤘지만, 공식 문서가 **IDE 플러그인 지원 종료(2027-04-30)**를 알리며 대체재로 **Kiro**를 지목합니다.
- ⚠️ **`Amazon Quick`을 테스트 도구로 쓰지 않습니다** — 공식 정의가 "작업 자동화·데이터 분석·웹 앱 구축·리서치"이고 코드베이스를 다루는 도구가 아닙니다(그 BI 구성 요소 **Quick Sight는 범위 밖**입니다).

> 🧠 **원리** — 이 기술이 묻는 것은 "AI가 테스트를 써 준다"가 아니라 **테스트 수명 주기의 어느 단계를 자동화하는가**입니다. 생성(사양) · 실행(이벤트 트리거) · 분석(결과 해석)으로 나누면 작업 3.3의 AI CI/CD 기술과 같은 틀로 읽힙니다.

---

## ✍️ 시험 포인트

- **"로컬에서는 통과했는데 배포하면 실패한다"** → 로컬·모의는 **IAM 권한·할당량·설정을 검증하지 못합니다.** 공식 권장은 **클라우드 테스트**입니다.
- **"실행하지 않고 권한만 확인"** → **`InvocationType=DryRun`**(204). **"응답에 로그도 같이"** → **`LogType=Tail`**(마지막 4 KB).
- **"백엔드가 아직 없는데 API를 먼저 제공"** → **API Gateway MOCK 통합**.
- **"테스트 이벤트를 팀과 공유"** → **공유 가능 테스트 이벤트**(스키마 레지스트리 `lambda-testevent-schemas`, `schemas:*` 권한).
- **"트래픽이 없어도 가용성을 감시"** → **CloudWatch Synthetics canary**.
- **"테스트를 통과한 그 버전만 프로덕션에"** → **게시 버전(불변) + 별칭(포인터)**. 가중 별칭은 **게시 버전 2개**만, `$LATEST`는 불가.
- **"ECR에서 태그를 바꿨는데 함수가 그대로다"** → **배포 시 다이제스트로 해석**되므로 `update-function-code`를 다시 실행합니다.
- **"업데이트하면 DB가 교체되는지 미리 알고 싶다"** → **변경 세트**(교체 여부·속성 전후). `UpdateReplacePolicy`와 `DeletionPolicy`는 **적용 시점이 다릅니다.**
- **AI 테스트 자동화** → 범위 내에서는 **Kiro**(Hooks·Specs). ⚠️ **Q Developer·Quick은 범위 신호**입니다.

---

## ⚠️ 흔한 함정 {#pitfalls}

| 함정 | 바로잡기 |
|---|---|
| 로컬 테스트로 IAM 권한까지 검증된다고 본다 | **검증되지 않는다** — 권한·할당량·설정은 클라우드에서만 |
| `sam local`이 AWS 호출까지 흉내 낸다고 본다 | ⚠️ **실제 리소스로 나간다** |
| `sam local start-api`를 운영에 쓴다 | **개발용 서버**다(공식 경고) |
| `Invoke`의 상태 코드로 함수 성공을 판단한다 | 상태 코드는 **함수 오류를 반영하지 않는다**(작업 1.2) |
| 모의로 E2E를 대신한다 | **E2E에는 모의를 쓰지 않는다** |
| MOCK 통합에 큰 응답을 담는다 | **부적합** — Lambda 통합으로 간다 |
| MOCK 통합에서 통합 응답 템플릿을 빼놓는다 | 요청 템플릿의 `{"statusCode": 200}`에 **같은 상태 코드의 응답 템플릿**이 짝이다 |
| 콘솔 테스트 이벤트가 무제한이라고 본다 | **함수당 10개**(공유 이벤트는 스키마 레지스트리) |
| 별칭이 다른 별칭을 가리킬 수 있다고 본다 | **버전만** 가리킨다 |
| 가중 별칭에 `$LATEST`를 넣는다 | **게시된 버전 2개만** 가능하다 |
| 저트래픽에서 가중 비율이 정확하다고 본다 | **확률 모델**이라 크게 다를 수 있다 |
| 게시된 버전의 환경 변수를 바꾸려 한다 | **불변**이다 — `$LATEST`에서 바꿔 재게시 |
| ECR 태그를 옮기면 Lambda가 따라온다고 본다 | **배포 시 다이제스트로 해석**된다 — 재배포가 필요 |
| X-Ray 샘플링을 함수에서 조정하려 한다 | **함수에서 설정할 수 없다**(초당 1건 + 5%) |
| 변경 세트가 성공을 보장한다고 본다 | **영향을 보여 줄 뿐**이고 런타임 조건으로 실패할 수 있다 |
| `UpdateReplacePolicy`와 `DeletionPolicy`를 같은 것으로 본다 | **교체 시점** vs **삭제 시점** |
| `sam sync`를 프로덕션에 쓴다 | **개발 환경용**이다 |
| 기술 3.2.5를 Q Developer로 공부한다 | **범위 내 목록에 없다** — 범위 내 개발 도구는 **Kiro** |

---

## 🧪 자가 점검

**Q1.** 단위 테스트가 모두 통과하는데 배포하면 함수가 실패한다. 공식 문서가 권장하는 접근과, 로컬·모의가 검증하지 못하는 것은? (→ 1) 테스트 유형)

<details><summary>정답 보기</summary>

⭐ **클라우드에 배포한 것을 테스트하는 것**이 가장 정확하다고 안내합니다 — 큐·테이블·이벤트 버스·**보안 정책**은 로컬에서 완전히 복제할 수 없고, 로컬과 클라우드의 차이가 버그 재현·수정 시간을 늘립니다.

로컬·모의가 검증하지 못하는 것은 **IAM 권한·할당량·설정**입니다. ⚠️ 다른 서비스를 호출하지 않는 **순수 계산 함수조차** 타임아웃·메모리와 **CloudWatch Logs 기록 권한**이 결과를 좌우합니다. 그래서 통합 테스트에 집중하고, 예컨대 **API Gateway 엔드포인트에 합성 HTTP 호출**을 보내면 코드뿐 아니라 **서비스 구성과 서비스 간 IAM 권한까지** 한 번에 검증됩니다.
</details>

**Q2.** 배포된 함수에 대해 "호출 권한이 제대로 붙었는지"만 확인하고 싶고 실제 실행은 피하고 싶다. 그리고 응답과 함께 로그 꼬리도 보고 싶다면? (→ 2) 도구)

<details><summary>정답 보기</summary>

권한·파라미터만 확인하려면 **`InvocationType=DryRun`**입니다(상태 코드 **204**, 실행하지 않습니다). 응답과 함께 로그를 보려면 **`LogType=Tail`**을 주면 동기 호출 응답에 **실행 로그 마지막 4 KB**가 base64로 들어옵니다.

`sam remote invoke`에서는 `--parameter InvocationType=DryRun`처럼 **boto3 파라미터를 전달**할 수 있고, 로그는 `sam logs`를 **스택 이름 + 논리 ID**로 조회하며 `--tail`로 새 로그를 기다릴 수 있습니다. ⚠️ 로그가 아예 없다면 실행 역할의 **`AWSLambdaBasicExecutionRole`** 권한을 확인합니다.
</details>

**Q3.** 프런트엔드 팀이 아직 구현되지 않은 API에 의존해 작업을 시작해야 한다. 백엔드 없이 응답을 돌려주려면? 주의점은? (→ 3) 모의)

<details><summary>정답 보기</summary>

**API Gateway MOCK 통합**입니다 — API Gateway가 백엔드 없이 **매핑 템플릿으로 응답을 직접 생성**합니다. 구성은 짝으로 이뤄집니다: 통합 **요청** 매핑 템플릿이 `{"statusCode": 200}`을 만들고, **같은 상태 코드의 통합 응답** 매핑 템플릿이 본문을 만듭니다. 쿼리 파라미터 같은 조건으로 성공·오류 응답을 분기할 수 있습니다.

⚠️ 주의점은 **큰 응답 템플릿에는 부적합**하다는 것입니다 — 그때는 Lambda 통합으로 갑니다. 그리고 모의는 **통합 테스트에서 효과가 줄고 E2E에는 쓰지 않습니다.**
</details>

**Q4.** "테스트를 통과한 바로 그 버전"만 프로덕션에 두고, 5%만 새 버전으로 흘리고 싶다. 어떻게 구성하고 제약은? (→ 5) 환경)

<details><summary>정답 보기</summary>

**게시 버전 + 별칭**입니다. 게시하면 `$LATEST`의 복사본이 새 버전이 되고 **코드·런타임·메모리·계층이 불변**이므로 "통과한 그것"이 보존됩니다. 별칭은 **버전을 가리키는 갱신 가능한 포인터**이고, 5% 분배는 **가중 별칭**(`--routing-config AdditionalVersionWeights`)으로 합니다.

제약: ⚠️ 가중 별칭은 **최대 2개 버전**이고 **둘 다 게시된 버전**이어야 하며(`$LATEST` 불가) **같은 실행 역할·DLQ 구성**이어야 합니다. ⚠️ **낮은 트래픽에서는 실제 비율이 설정값과 크게 다를 수 있습니다**(확률 모델). 어느 버전이 응답했는지는 **`x-amz-executed-version`** 헤더나 별칭 지표의 **`ExecutedVersion`** 차원으로 확인합니다.
</details>

**Q5.** ECR에서 `prod` 태그를 새 이미지로 옮겼는데 Lambda 함수가 여전히 옛 이미지를 쓴다. 왜이고 어떻게 바꾸는가? (→ 5) 환경)

<details><summary>정답 보기</summary>

⚠️ **Lambda 컨테이너 이미지 함수는 배포 시 태그를 다이제스트로 해석**하기 때문입니다 — 함수는 그 시점의 **특정 이미지**에 고정되고, ECR에서 태그가 다른 이미지를 가리키게 바뀌어도 **자동 갱신되지 않습니다.** 바꾸려면 **`update-function-code --image-uri`**를 다시 실행합니다.

같은 성질을 승격에 활용할 수 있습니다 — **재태깅**(`batch-get-image` → `put-image --image-tag`)으로 pull·push 없이 태그만 붙이고, "승인된 이미지"를 고정하려면 **불변 태그**(`IMMUTABLE`) 또는 **`@sha256:` 다이제스트 참조**를 씁니다. 태그는 **옮겨 다니는 라벨**이고 다이제스트는 **특정 이미지**입니다.
</details>

**Q6.** 프로덕션 스택을 업데이트하기 전에 "DB가 교체되는지"를 확인하려 한다. 무엇을 쓰고, 그것이 보장하지 않는 것은? (→ 6) 스택 업데이트)

<details><summary>정답 보기</summary>

**CloudFormation 변경 세트**입니다 — 변경이 실행 중 리소스에 미칠 영향(추가·수정·삭제·**교체**, 속성 전후)을 **적용 전에** 보여 주고 **실행을 결정할 때만** 스택을 바꿉니다. ⚠️ **교체**는 새 리소스를 만들고 참조를 옮긴 뒤 이전 리소스를 삭제하므로(새 물리 ID) **백업이 없으면 데이터를 잃습니다.**

보장하지 않는 것은 **업데이트의 성공**입니다 — 런타임 조건으로 실패할 수 있습니다. 보호 장치로 **`UpdateReplacePolicy`**(교체 시점)와 **`DeletionPolicy`**(삭제 시점)를 구분해 둡니다. ⚠️ 업데이트 실패 후 **롤백까지 실패하면 `UPDATE_ROLLBACK_FAILED`**가 되어 그 스택은 업데이트할 수 없고, 오류를 고친 뒤 **`ContinueUpdateRollback`**으로 되돌립니다.
</details>

**Q7.** 기술 3.2.5의 "AWS AI 도구로 테스트 생성·자동화"를 공부하려 한다. 어떤 도구를 보고, 어떤 이름이 보이면 범위를 의심하는가? (→ 7) AI 테스트)

<details><summary>정답 보기</summary>

⚠️ **기술 문구가 서비스를 하나도 명시하지 않습니다.** 범위 내 ML/AI는 **Bedrock · Bedrock AgentCore · Amazon Quick · Kiro** 넷이고 그중 테스트 워크플로에 해당하는 것은 **Kiro**입니다 — **Hooks**(파일 저장·커밋 이벤트에 걸려 테스트 실행)가 "반복적인 테스트 워크플로 자동화"에, **Specs**가 사양에서 테스트를 끌어내는 쪽에 대응합니다.

범위를 의심할 이름: ⚠️ **`Amazon Q Developer`**(범위 내 목록에 없고 IDE 플러그인은 2027-04-30 지원 종료, 공식 대체재가 Kiro) · ⚠️ **`Amazon Quick`**(작업 자동화·데이터 분석·웹 앱 구축·리서치용이고 코드 도구가 아니며, 그 BI 구성 요소 **Quick Sight는 범위 밖**).
</details>

---

### 📌 출처

1. How to test serverless functions and applications (Lambda) — https://docs.aws.amazon.com/lambda/latest/dg/testing-guide.html
2. Testing Lambda functions in the console — https://docs.aws.amazon.com/lambda/latest/dg/testing-functions.html
3. Lambda quotas — https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-limits.html
4. Invoke (Lambda API Reference) — https://docs.aws.amazon.com/lambda/latest/api/API_Invoke.html
5. Introduction to testing in the cloud with sam remote invoke — https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/using-sam-cli-remote-invoke.html
6. sam logs (CLI reference) — https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/sam-cli-command-reference-sam-logs.html
7. Sending Lambda function logs to CloudWatch Logs — https://docs.aws.amazon.com/lambda/latest/dg/monitoring-cloudwatchlogs.html
8. Visualize Lambda function invocations using AWS X-Ray — https://docs.aws.amazon.com/lambda/latest/dg/services-xray.html
9. Synthetic monitoring (canaries) — https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Synthetics_Canaries.html
10. Introduction to testing with sam local invoke — https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/using-sam-cli-local-invoke.html
11. Introduction to testing with sam local start-api — https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/using-sam-cli-local-start-api.html
12. Introduction to testing with sam local generate-event — https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/using-sam-cli-local-generate-event.html
13. Mock integrations for REST APIs in API Gateway — https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-mock-integration.html
14. Testing state machines with TestState API (Step Functions) — https://docs.aws.amazon.com/step-functions/latest/dg/test-state-isolation.html
15. Manage Lambda function versions — https://docs.aws.amazon.com/lambda/latest/dg/configuration-versions.html
16. Create an alias for a Lambda function — https://docs.aws.amazon.com/lambda/latest/dg/configuration-aliases.html
17. Implement Lambda canary deployments using a weighted alias — https://docs.aws.amazon.com/lambda/latest/dg/configuring-alias-routing.html
18. Using Lambda aliases in event sources and permissions policies — https://docs.aws.amazon.com/lambda/latest/dg/using-aliases.html
19. Pattern-based feature branch deployments (AWS Amplify Hosting) — https://docs.aws.amazon.com/amplify/latest/userguide/pattern-based-feature-branch-deployments.html
20. Setting environment variables (AWS Amplify Hosting) — https://docs.aws.amazon.com/amplify/latest/userguide/setting-env-vars.html
21. Introduction to using sam sync to sync to AWS Cloud — https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/using-sam-cli-sync.html
22. Update CloudFormation stacks using change sets — https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-updating-stacks-changesets.html
23. Amazon Q Developer IDE 플러그인 지원 종료 — https://docs.aws.amazon.com/amazonq/latest/qdeveloper-ug/q-developer-ide-end-of-support.html
24. DVA-C03 공식 시험 가이드 · 콘텐츠 도메인 3 (한국어) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/developer-associate-03/developer-associate-03-domain3.html
25. DVA-C03 범위 내 AWS 서비스 (한국어) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/developer-associate-03/dva-03-in-scope-services.html
