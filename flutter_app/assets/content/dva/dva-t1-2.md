---
examGuideTaskId: dva-t1-2
certCode: DVA-C03
domain: 1
domainName: AWS 서비스를 통한 개발
domainWeightPct: 30
title: AWS Lambda용 코드 개발 (VPC 접근·구성 파라미터·수명 주기·통합)
coversTasks:
  - "1.2"
sources:
  - title: Giving Lambda functions access to resources in an Amazon VPC
    url: https://docs.aws.amazon.com/lambda/latest/dg/configuration-vpc.html
  - title: Lambda quotas
    url: https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-limits.html
  - title: Working with Lambda environment variables
    url: https://docs.aws.amazon.com/lambda/latest/dg/configuration-envvars.html
  - title: Understanding Lambda function scaling
    url: https://docs.aws.amazon.com/lambda/latest/dg/lambda-concurrency.html
  - title: Capturing records of Lambda asynchronous invocations
    url: https://docs.aws.amazon.com/lambda/latest/dg/invocation-async-retain-records.html
  - title: How Lambda processes records from stream and queue-based event sources
    url: https://docs.aws.amazon.com/lambda/latest/dg/invocation-eventsourcemapping.html
  - title: Handling errors for an SQS event source in Lambda
    url: https://docs.aws.amazon.com/lambda/latest/dg/services-sqs-errorhandling.html
  - title: Managing Lambda dependencies with layers
    url: https://docs.aws.amazon.com/lambda/latest/dg/chapter-layers.html
  - title: DVA-C03 공식 시험 가이드 · 콘텐츠 도메인 1 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/developer-associate-03/developer-associate-03-domain1.html
lastVerified: 2026-11-01
---

# AWS Lambda용 코드 개발 (VPC 접근·구성 파라미터·수명 주기·통합)

> **커버하는 공식 Task** — DVA-C03 · 도메인 1 「AWS 서비스를 통한 개발」(30%) · **작업 1.2 AWS Lambda용 코드를 개발합니다** (`dva-t1-2`)
> 이 문서는 위 한 작업에 1:1로 매핑되고, 공식 기술 네 개(1.2.1~1.2.4)를 모두 덮습니다.

> ⚠️ **C03에서 이 작업은 좁아졌습니다.** C02의 Task 1.2는 Lambda 전반(VPC·구성·트리거·오류·이벤트 소스 매핑·멱등성·테스트·**성능 튜닝**·준실시간 처리)이었지만, **C03의 1.2는 기술 네 개**뿐이고 **성능 튜닝(메모리·컴퓨팅 최적화)은 작업 4.3으로 갔습니다.** Lambda **로컬 단위 테스트**는 작업 3.2, **Lambda 배포 패키징**(.zip·컨테이너 이미지·계층)은 작업 3.3입니다. 그래서 이 문서는 **"돌아가게 만들고, 실패를 어디로 보낼지 정하는 것"**까지만 다룹니다.
>
> ⚠️ **용어**: 현행 Lambda 개발자 가이드는 전통적인 Lambda 함수를 **Event Function**이라고 부릅니다(콘솔 라벨도 그렇습니다). 다만 API(`CreateFunction`·`Invoke`)·SDK·CLI·`AWS::Lambda::Function`·ARN은 계속 `function`을 쓰고, **공식 시험 가이드도 "Lambda 함수"로 적습니다.** 이 문서는 가이드 표기를 따릅니다.

---

## ✅ 학습 목표 체크리스트

- [ ] VPC 연결 함수의 구조(Hyperplane ENI)와 **실행 역할에 필요한 권한**을 말할 수 있다
- [ ] VPC에 연결한 함수가 인터넷·AWS 서비스로 나가는 **경로 세 가지**를 구분한다
- [ ] 메모리·타임아웃·`/tmp`·환경 변수·계층의 **범위와 기본값**을 안다
- [ ] 예약 동시성과 프로비저닝된 동시성을 **목적·비용·적용 대상**으로 가른다
- [ ] 동기·비동기·ESM의 **재시도 규칙과 실패 보존 위치**가 다르다는 것을 설명한다
- [ ] DLQ와 Destinations를 **적용 대상·전달 내용·설정 단위**로 가른다
- [ ] ESM 파라미터(배치 크기·윈도·부분 배치 응답)로 **배치 실패를 좁힐** 수 있다
- [ ] 트리거(push)와 이벤트 소스 매핑(poll)의 **권한이 어디서 나오는지** 구분한다

---

## 🎯 왜 중요한가

Lambda 문항은 "Lambda가 무엇인가"를 묻지 않습니다. **"왜 안 되는가"**와 **"실패한 이벤트는 어디 있는가"**를 묻습니다. 그 두 질문의 답이 전부 이 작업 안에 있습니다 — VPC에 붙였는데 외부 API 호출이 타임아웃되는 이유, 비동기 호출이 조용히 사라지는 이유, 스트림 소비가 한 레코드 때문에 멈추는 이유.

그리고 숫자가 많습니다. 하지만 외울 숫자는 **쌍으로** 묶이는 것들입니다 — 메모리 128/10,240 · 타임아웃 3초/900초 · 페이로드 6 MB/1 MB · 계층 5개 · 환경 변수 4 KB. 쌍으로 외우면 보기에서 한쪽만 바꿔 놓은 오답이 바로 보입니다.

---

## ⚡ 시험 직전 요약

> 시험 직전에 이 열 줄만 다시 봅니다. 근거와 맥락은 아래 본문에 있습니다.

- **VPC 연결에 필요한 것**: 프라이빗 서브넷 + 보안 그룹, 그리고 실행 역할에 **`AWSLambdaVPCAccessExecutionRole`**(ENI 생성 권한). ⚠️ 이 권한은 **호출 자체에는 필요 없습니다**
- ⚠️ **VPC에 연결하면 인터넷이 끊깁니다** — 외부 API를 부르려면 **프라이빗 서브넷 + 퍼블릭 서브넷의 NAT 게이트웨이 + `0.0.0.0/0 → NAT` 라우팅**. 경로가 없으면 `Task timed out`으로 끝납니다
- **퍼블릭 서브넷에 연결해도 인터넷이 생기지 않습니다**(퍼블릭 IP가 붙지 않습니다)
- **구성 범위**: 메모리 **128~10,240 MB**(기본 128, CPU는 메모리에 비례, **1,769 MB ≈ 1 vCPU**) · 타임아웃 기본 **3초**·최대 **900초** · `/tmp` **512~10,240 MB** · 환경 변수 합계 **4 KB** · 계층 **5개** · 압축 해제 합계 **250 MB**
- **동시성**: 계정 기본 리전당 **1,000**. 필요량 ≈ 초당 요청 수 × 평균 실행 시간(초). **예약은 무료·상한 겸 하한**, **프로비저닝은 유료이고 $LATEST에 걸 수 없습니다**
- **비동기 재시도**: 함수 오류는 **기본 2회 추가**(1분·2분 대기), 스로틀·시스템 오류는 큐로 되돌려 **기본 최대 6시간**. 소진되면 **DLQ 또는 Destinations**
- ⚠️ **`Invoke`의 StatusCode는 함수 오류를 반영하지 않습니다** — 함수 오류는 **`X-Amz-Function-Error` 헤더와 응답 본문**으로 옵니다
- **DLQ vs Destinations**: DLQ는 **실패만** + 이벤트 본문, 대상은 **SQS·SNS 표준만**(FIFO 불가). Destinations는 **on-success도** 되고 **요청·응답이 든 호출 레코드**를 보냅니다
- **스트림 ESM의 기본값은 위험합니다** — 재시도가 **무한(-1)**이라 문제 레코드가 그 샤드를 **최대 1주일** 막을 수 있습니다. `MaximumRetryAttempts`·`MaximumRecordAgeInSeconds`를 설정합니다
- **부분 배치 응답**: `ReportBatchItemFailures` + `{"batchItemFailures":[{"itemIdentifier":"…"}]}`. ⚠️ 함수가 **예외를 던지면 배치 전체가 실패**입니다

---

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **Hyperplane ENI** | Lambda가 보안 그룹:서브넷 **조합마다** 만들어 여러 실행 환경이 공유하는 네트워크 인터페이스 |
| **실행 환경(execution environment)** | 함수 코드를 담아 돌리는 격리 공간. 한 환경은 **한 번에 이벤트 하나만** 처리한다 |
| **동시성** | 동시에 처리 중인 요청 수. 곧 **동시에 일하는 실행 환경 수**다 |
| **트리거(push)** | S3·SNS·API Gateway처럼 **서비스가 Lambda를 직접 호출**하는 연결 |
| **이벤트 소스 매핑(ESM, poll)** | **Lambda가 큐·스트림을 폴링**해 배치로 함수를 호출하는 Lambda 리소스 |
| **Destinations** | 비동기 호출·ESM의 결과를 보낼 대상. 성공·실패를 **각각** 지정할 수 있다 |
| **부분 배치 응답** | 배치 중 실패한 항목만 되돌리는 기능(`ReportBatchItemFailures`) |
| **멱등 키** | 같은 이벤트를 두 번 처리하지 않도록 쓰는 고유 식별자(거래 ID·페이로드 해시 등) |

---

## 📖 핵심 개념

### 1) VPC 연결 — 구조와 권한 (기술 1.2.1) {#vpc}

**모든 Lambda 함수는 Lambda 서비스가 소유·관리하는 VPC에서 실행됩니다**(고객에게 보이지 않습니다). 계정의 VPC에 연결해도 그 관리형 VPC에는 영향이 없습니다. 계정 VPC의 프라이빗 리소스(RDS·ElastiCache·EC2)에 닿으려면 **프라이빗 서브넷 + 보안 그룹**에 함수를 연결합니다.

| 주체 | 필요한 것 | 메모 |
|---|---|---|
| **함수 실행 역할** | 관리형 정책 **`AWSLambdaVPCAccessExecutionRole`**(또는 `ec2:CreateNetworkInterface`·`DescribeNetworkInterfaces`·`DescribeSubnets`·`DeleteNetworkInterface`·`AssignPrivateIpAddresses`·`UnassignPrivateIpAddresses`) | **ENI를 만들기 위한** 권한이고 호출 자체에는 필요 없다. 콘솔에서 VPC 함수를 만들면 자동으로 붙는다 |
| 함수를 **구성하는** 사용자·역할 | `ec2:DescribeSecurityGroups`·`DescribeSubnets`·`DescribeVpcs`·`GetSecurityGroupsForVpc` | VPC 연결 시 Lambda가 네트워크 리소스를 검증한다 |
| 최소 권한 | 실행 역할에 `lambda:SourceFunctionArn` 조건을 건 EC2 API Deny 문 | 위 EC2 권한이 **함수 코드에도 암묵적으로** 부여되므로, 코드가 EC2 API를 못 부르게 막는 용도 |
| 조직 통제 | IAM 조건 키 `lambda:VpcIds`·`lambda:SubnetIds`·`lambda:SecurityGroupIds` | `CreateFunction`·`UpdateFunctionConfiguration`에 적용(예: VPC 연결 함수만 배포 허용) |

**ENI 수명 주기**가 콜드 스타트 오해의 출발점입니다.

- ENI는 **함수 생성·VPC 설정 변경 시점에 미리 만들어집니다.** 준비되는 동안 함수는 **`Pending`**(호출 불가, 수 분 소요 가능)이고 `Active`가 되면 호출할 수 있습니다. ⚠️ 그래서 **"VPC 연결이 콜드 스타트를 늘린다"는 2019년 이전 모델**입니다 — 호출 때는 터널만 연결합니다.
- **14일간 호출이 없으면** 미사용 ENI를 회수해 함수가 `Inactive`가 되고, 다음 호출은 실패한 뒤 다시 `Pending`을 거칩니다.
- VPC 설정을 제거하면 ENI 삭제에 **최대 20분**이 걸리고, ⚠️ **실행 역할을 먼저 지우면 Lambda가 ENI를 지우지 못합니다.**
- ENI 하나는 최대 **65,000개 연결/포트**를 지원하고 넘으면 Lambda가 ENI를 자동으로 늘립니다.
- 같은 보안 그룹:서브넷 조합을 쓰는 **계정 내 다른 함수도 같은 ENI를 재사용**합니다.

제약과 오류: **dedicated tenancy VPC에는 직접 연결할 수 없고**(기본 tenancy VPC와 피어링), 다른 계정 VPC의 리소스는 **VPC 피어링**으로 접근합니다. VPC 관련 호출 오류는 `ENILimitReachedException`·`ENINotReadyException`·`EC2AccessDeniedException` 등 **HTTP 502**로 나타납니다.

> 🧠 **원리** — Lambda는 실행 환경을 수없이 만들고 버리는데, 그때마다 ENI를 만들면 VPC의 ENI 한도가 먼저 터집니다. 그래서 **조합당 하나의 공유 ENI**를 미리 만들고 환경들이 그것을 함께 씁니다. "미리 만든다"가 `Pending` 상태의 이유이고, "공유한다"가 다른 함수와 ENI를 재사용하는 이유입니다.

### 2) VPC 연결 후 나가는 경로 (기술 1.2.1) {#vpc-egress}

| 가려는 곳 | 필요한 구성 | 함정 |
|---|---|---|
| 같은 VPC의 RDS·ElastiCache | 프라이빗 서브넷 연결 + **보안 그룹 규칙** | 함수와 DB가 같은 SG면 그 SG를 인바운드 source·아웃바운드 destination으로 지정 |
| 퍼블릭 인터넷의 외부 API | **프라이빗** 서브넷 + 퍼블릭 서브넷의 **NAT 게이트웨이** + 프라이빗 라우팅 테이블의 `0.0.0.0/0 → NAT` | ⚠️ **퍼블릭 서브넷에 연결해도 인터넷·퍼블릭 IP가 생기지 않는다.** 경로가 없으면 `Task timed out` |
| AWS 서비스(S3·DynamoDB) | **VPC 엔드포인트** — 게이트웨이 엔드포인트는 추가 요금이 없다(S3·DynamoDB) | 온프레미스·다른 리전 피어링·Transit Gateway 경유가 필요하면 **인터페이스 엔드포인트**(추가 요금) |
| IPv6 | **이중 스택 서브넷**만 선택 + `Ipv6AllowedForDualStack=true`, IPv6 인터넷은 **egress-only 인터넷 게이트웨이** | IPv6 전용 서브넷과 VPC 미연결 함수는 IPv6 아웃바운드 미지원 |
| EFS | VPC 연결 **필수**, 같은 VPC의 접근 지점, 마운트 경로는 `/mnt/`로 시작, NFS(2049) 허용 | — |
| DB 연결 폭주 | **RDS Proxy**(연결 풀링) | 짧은 연결을 반복하는 Lambda에 적합 |

> 🧠 **원리** — VPC에 연결하지 않은 함수는 **인터넷이 열려 있는 Lambda 관리형 VPC**에서 나가므로 외부에 닿습니다. VPC에 연결하면 **그 VPC의 규칙**을 따르게 되므로, 밖으로 나가는 길을 VPC 쪽에 직접 만들어야 합니다. "연결했더니 안 된다"의 정체는 거의 항상 이것입니다.

### 3) 구성 파라미터 — 메모리·타임아웃·스토리지 (기술 1.2.2) {#config}

| 설정 | 범위 / 기본값 | 메모 |
|---|---|---|
| **메모리** | **128~10,240 MB**(1 MB 단위), 기본 **128 MB** | CPU는 **메모리에 비례해서만** 늘어난다(별도 CPU 설정이 없다). **1,769 MB ≈ 1 vCPU** |
| **타임아웃** | 기본 **3초**, 최대 **900초**(15분) | 평균 실행 시간에 너무 가까우면 간헐적 타임아웃 위험 |
| 임시 스토리지 `/tmp` | **512~10,240 MB** | 실행 환경별이고 **동결 중에도 유지**되어 호출 간 캐시로 쓸 수 있다 |
| 환경 변수 | 전체 합계 **4 KB** | 아래 4) 절 |
| 계층(layers) | 함수당 최대 **5개** | 아래 6) 절 |
| 배포 패키지(.zip) | API·콘솔 업로드 **50 MB**(더 크면 S3 경유) · **압축 해제 합계 250 MB**(계층·확장·커스텀 런타임 포함) | 컨테이너 이미지는 **10 GB** |
| 아키텍처 | `x86_64` / `arm64` | 모든 지원 런타임이 둘 다 지원 |
| 호출 페이로드 | 동기 **6 MB**(요청·응답 각각) · 비동기 **1 MB** · 스트리밍 응답 **200 MB** | 콘솔 테스트 이벤트는 함수당 10개 |

- ⚠️ **메모리를 올리는 것이 곧 CPU를 올리는 것**입니다. "CPU가 부족하다"는 지문의 처방은 vCPU 설정이 아니라 **메모리 상향**입니다. 다만 **얼마로 올릴지를 측정으로 정하는 일**은 작업 4.3(최적화)입니다.
- 함수당 스케일링 속도는 **10초마다 실행 환경 1,000개**이고, 동기 호출 요청 한도는 동시성의 **10배**(초당)입니다.

> 🧠 **원리** — Lambda의 설정은 **가격·성능·한도가 한 손잡이에 묶여** 있습니다. 메모리 하나로 CPU·네트워크·가격이 함께 움직이기 때문에, 튜닝은 "메모리를 몇으로 둘 때 총비용이 최소인가"를 재는 일이 됩니다.

### 4) 환경 변수와 비밀 값 (기술 1.2.2) {#envvars}

- 환경 변수는 코드를 바꾸지 않고 동작을 조정하는 **문자열 쌍**이며 함수의 **버전별 설정**에 저장됩니다. 미게시 버전(`$LATEST`)에서 정의하고 **버전을 게시하면 그 버전에 잠깁니다.**
- 값은 **평가·확장되지 않는 리터럴 문자열**입니다(치환은 코드에서). 키는 영문자로 시작하는 2자 이상, 영문·숫자·`_`만, Lambda 예약 키는 쓸 수 없고 **전체 합계 4 KB** 이하입니다.
- ⚠️ CLI `update-function-configuration --environment`는 `Variables` **전체를 교체**합니다 — 기존 값을 함께 보내지 않으면 사라집니다.
- 런타임이 설정하는 예약 키: `_HANDLER`·`AWS_REGION`·`AWS_LAMBDA_FUNCTION_NAME`·`AWS_LAMBDA_FUNCTION_MEMORY_SIZE`·`AWS_LAMBDA_FUNCTION_VERSION`·`AWS_LAMBDA_INITIALIZATION_TYPE`·`AWS_ACCESS_KEY_ID`·`AWS_SECRET_ACCESS_KEY`·`AWS_SESSION_TOKEN`(실행 역할 자격 증명)·`LAMBDA_TASK_ROOT`. **함수 설정으로 바꿀 수 없습니다.**
- 저장 시 암호화되며 다른 KMS 키를 지정할 수 있습니다. 그래도 **DB 자격 증명·API 키 같은 민감 정보는 환경 변수 대신 Secrets Manager**를 쓰라고 권장합니다. Parameters and Secrets Lambda Extension은 기본으로 비밀을 **300초** 캐시합니다.

> 🧠 **원리** — 환경 변수는 **설정이고 비밀이 아닙니다.** 암호화되어 저장되지만 함수를 읽을 수 있는 사람이 값을 볼 수 있고 버전에 박히므로, 교체(rotation)가 필요한 값은 바깥(Secrets Manager·Parameter Store)에 두고 **참조만** 넘깁니다.

### 5) 런타임·핸들러 (기술 1.2.2) {#runtime-handler}

- 런타임은 언어별 실행 환경이고 **주 언어 버전마다 식별자**가 따로 있습니다(`nodejs24.x`·`python3.14`). Lambda가 주 버전 간 호환성을 보장하지 않으므로 **버전 상향은 식별자를 바꾸는 고객 작업**입니다. `.zip`은 설정 업데이트로 바꾸고, **컨테이너 이미지는 이미지를 새로 만들어야** 합니다.
- Lambda는 **LTS 단계에 이른** 언어 버전만 관리형 런타임으로 제공하고, 지원 종료는 단계적입니다(새 함수 생성 차단 → 이후 기존 함수 업데이트 차단). ⚠️ **지원 종료 후에도 호출은 계속 동작**합니다.
- SDK: Node.js·Python·Ruby 런타임에 AWS SDK가 포함돼 있지만, **호환성과 의존성 통제를 위해 코드가 쓰는 SDK를 배포 패키지나 계층에 직접 포함**하라고 권장합니다(런타임 포함 SDK는 콘솔 편집기처럼 패키지를 못 넣을 때만).
- **핸들러**는 함수 설정의 `handler` 값이 가리키는 진입점입니다(예: `function.handler` = 파일 이름.메서드 이름). ⚠️ **핸들러 밖의 정적 코드는 실행 환경당 한 번** 실행되고, **한 환경은 한 번에 이벤트 하나만** 처리합니다 — 그래서 **동시에 처리 중인 환경 수가 곧 동시성**입니다.

> 🧠 **원리** — 핸들러 밖과 안의 구분이 Lambda 코드 설계의 전부에 가깝습니다. 밖은 **환경당 한 번**이니 DB 연결·SDK 클라이언트 생성을 두어 초기화 비용을 여러 호출에 나누고, 안은 **호출마다**이니 호출별 데이터를 둡니다. ⚠️ 호출별 데이터를 밖에 두면 **다른 호출에 새어 나갑니다.**

### 6) 계층과 확장 (기술 1.2.2) {#layers-extensions}

- **계층(layer)**은 보충 코드·데이터를 담은 `.zip`입니다(의존성 라이브러리·커스텀 런타임·설정 파일). 용도는 배포 패키지 축소, 로직과 의존성 분리, 여러 함수 간 공유, 콘솔 코드 편집기 사용, 내장 SDK 버전 고정입니다.
- 제약: 함수당 **최대 5개**, **`.zip` 배포 함수에서만**(컨테이너 이미지는 이미지 안에 포함), 내용은 **`/opt`에 추출**, 계층 버전은 **변경 불가능한 스냅샷**이라 ARN에 **버전 번호까지** 지정합니다. 계층도 **250 MB 압축 해제 한도에 포함**됩니다.
- **확장(extension)**은 **외부**(별도 프로세스, 함수 호출이 끝난 뒤에도 실행, 다른 언어로 작성 가능)와 **내부**(런타임 프로세스의 일부)로 나뉘고, 계층으로 `/opt/extensions/`에 두면 **Init 단계에서 병렬로** 시작합니다.
- ⚠️ 확장은 함수와 **CPU·메모리·스토리지를 공유**해 실행 시간이 늘 수 있고, **확장 초기화가 끝나야 함수가 호출**됩니다. 확장이 쓴 시간도 과금되며 `PostRuntimeExtensionsDuration` 지표로 봅니다. Shutdown 단계 한도는 **확장 없음 0 ms · 내부 500 ms · 외부 2,000 ms**이고 초과하면 SIGKILL입니다.

> 🧠 **원리** — 계층은 "파일을 `/opt`에 풀어 주는 것"뿐이고, 확장은 "같은 환경 안에서 함께 도는 프로세스"입니다. 그래서 계층은 **크기** 문제를 풀고 확장은 **관측·비밀 캐시** 문제를 풀지만, 확장은 같은 자원을 나눠 쓰므로 **비용과 지연**이 따라옵니다.

### 7) 동시성 — 예약과 프로비저닝 (기술 1.2.2) {#concurrency}

동시성은 **동시에 처리 중인 요청 수**이고 요청마다 별도 실행 환경이 필요합니다. 계정 기본 한도는 **리전당 1,000**이며, 필요량은 **초당 요청 수 × 평균 실행 시간(초)**입니다(예: 5,000 rps × 0.2초 = 1,000).

| 구분 | 예약 동시성 | 프로비저닝된 동시성 | SQS ESM 최대 동시성 |
|---|---|---|---|
| 목적 | 함수 전용 용량 보장 **+ 상한**(하류 DB 보호) | **미리 초기화된 환경**으로 콜드 스타트 제거 | 큐 하나가 함수·계정 동시성을 **독점하지 못하게** |
| 비용 | **무료** | **추가 요금** | 무료 |
| 적용 대상 | 함수 | **버전·별칭**(⚠️ `$LATEST` 불가) | 이벤트 소스 매핑(2~1,000) |
| 제약 | 미예약 풀 − 100까지. **0이면 호출 차단** | 예약 동시성 이하, 이벤트 소스가 그 별칭·버전을 가리켜야 함 | 프로비저닝 모드와 **동시 사용 불가** |

- ⚠️ **예약 동시성은 하한이자 상한**입니다 — 그 용량을 다른 함수가 못 쓰고, 그 이상으로 확장되지도 않습니다. 계정 한도가 1,000이면 **한 함수에 1,000 전부를 예약할 수 없습니다**(100은 예약 없는 함수용으로 남깁니다).
- 프로비저닝된 동시성 **초과분은 on-demand 환경**이 처리하고, 필요량에 **10% 버퍼**를 권장하며 Application Auto Scaling으로 자동 조정할 수 있습니다. 초기화 코드를 핸들러 밖에 두면 **할당 시점에** 실행됩니다.
- 호출이 폭주하면(재귀 호출 등) **예약 동시성을 0으로 두어 즉시 차단**하고 코드를 고칩니다.

> 🧠 **원리** — 두 동시성은 **방향이 다릅니다.** 예약은 "이 함수가 쓸 수 있는 칸을 못 박는 것"(격리·보호)이고, 프로비저닝은 "칸을 미리 데워 두는 것"(지연 제거)입니다. 그래서 하류 DB를 보호하려면 예약, 첫 호출 지연이 문제면 프로비저닝입니다.

### 8) 호출 유형별 수명 주기와 오류 처리 (기술 1.2.3) {#lifecycle}

| 호출 유형 | 대표 호출자 | 오류 시 재시도 | 실패 이벤트 보존 |
|---|---|---|---|
| **동기**(`RequestResponse`) | API Gateway·ALB·Cognito·Firehose·SDK `Invoke` | **Lambda는 자동 재시도하지 않는다.** 직접 호출이면 호출자가, 서비스 경유면 그 서비스가 재시도 여부를 정한다 | **호출자 책임** |
| **비동기**(`Event`) | S3·SNS·EventBridge·CloudWatch Logs | **함수 오류**(코드·런타임 오류·타임아웃)는 기본 **2회 추가**(1분·2분 대기). **스로틀(429)·시스템 오류(5xx)**는 이벤트를 큐로 되돌려 **기본 최대 6시간**(간격 1초→최대 5분 지수 증가) | 재시도 소진·연령 초과 시 **DLQ 또는 Destinations** |
| **ESM — 큐(SQS)** | SQS | 배치 오류 시 **가시성 제한 시간이 지나면 다시 보인다**(기본은 배치 전체) | **큐의 DLQ** |
| **ESM — 스트림** | Kinesis·DynamoDB Streams | **배치 전체를 재시도**하며, 오류가 해결되거나 레코드가 만료될 때까지 **그 샤드 처리가 멈춘다**(순서 보장) | **ESM의 on-failure 대상** |

- 비동기 재시도는 조정할 수 있습니다 — 재시도 **0~2회**, 최대 이벤트 연령 **60~21,600초**.
- ⚠️ **`Invoke`의 StatusCode는 함수 오류를 반영하지 않습니다**(`RequestResponse` 200 · `Event` 202 · `DryRun` 204). 함수 오류는 **`X-Amz-Function-Error` 헤더와 응답 본문**으로 오고, 상태 코드 오류는 권한·할당량처럼 **실행 자체를 막는** 문제입니다(예: `TooManyRequestsException`).
- **스트림이 막히는 이유**: 샤드 안에서 순서대로 처리하므로 오류가 나면 뒤 레코드로 넘어가지 못하고 같은 배치를 다시 시도합니다. ⚠️ **샤드를 늘리면 영향 범위가 줄 뿐 막힌 샤드는 풀리지 않습니다.** `IteratorAge` 지표로 감지합니다.
- **중복은 기본 가정입니다** — 비동기 내부 큐는 eventually consistent라 오류가 없어도 같은 이벤트를 여러 번 받을 수 있고, ESM은 각 이벤트를 **최소 한 번** 처리합니다. 그래서 **멱등성**이 필요합니다: 이벤트의 고유 속성을 키로 DynamoDB에 **조건부 쓰기**(상태 `IN_PROGRESS` + 만료 시각) → `ConditionalCheckFailedException`이면 이미 처리 중·완료 → 끝나면 `COMPLETE`, TTL로 만료.
- ⚠️ **중복 이벤트는 오류 없이 정상 종료**해야 합니다. 오류로 끝내면 호출 서비스가 **추가 재시도**를 합니다.

> 🧠 **원리** — 세 호출 유형은 **"누가 이벤트를 들고 있는가"**가 다릅니다. 동기는 호출자가, 비동기는 Lambda의 내부 큐가, ESM은 소스(큐·스트림)가 들고 있습니다. 그래서 실패를 보존할 자리도 각각 호출자·DLQ/Destinations·소스 쪽 DLQ로 달라집니다.

### 9) Destinations와 DLQ (기술 1.2.3) {#destinations-dlq}

| 비교 | **DLQ** | **Destinations**(비동기) | ESM 실패 대상(스트림) |
|---|---|---|---|
| 적용 대상 | 비동기 호출 | 비동기 호출 | 이벤트 소스 매핑 |
| 대상 종류 | **SQS 표준 큐·SNS 표준 토픽만**(FIFO 불가) | SQS(표준)·SNS(표준)·**Lambda 함수**·**EventBridge 버스**·S3 버킷(실패 전용) | SNS·SQS·S3·Kafka 토픽 |
| 조건 | **실패만**(재시도 소진·연령 초과) | **on-success / on-failure 각각** | on-failure만 |
| 전달 내용 | **이벤트 본문만** + 속성(RequestID·ErrorCode·ErrorMessage 첫 1 KB) | **요청·응답 세부가 든 JSON 호출 레코드**(`condition`·`approximateInvokeCount`·`responsePayload`) | 실패 호출의 메타데이터 |
| 설정 단위 | **함수 레벨만** | 함수·**버전·별칭** | ESM 단위 |
| 실행 역할 권한 | `sqs:SendMessage` / `sns:Publish` | 대상에 따라 `sqs:SendMessage`·`sns:Publish`·`lambda:InvokeFunction`·`events:PutEvents`·`s3:PutObject` | 대상에 따라 동일 |
| 전달 실패 지표 | `DeadLetterErrors`(전달 못 하면 **이벤트 삭제**) | `DestinationDeliveryFailures` | — |

- ⚠️ **예약 동시성을 0으로 두면** 비동기 이벤트는 **재시도 없이 곧바로** DLQ·on-failure 대상으로 갑니다(나중에 거기서 꺼내 처리).
- ⚠️ **SNS 대상은 메시지 최대 256 KB**라, 비동기 페이로드가 1 MB에 가까우면 호출 레코드가 한도를 넘습니다 — 큰 페이로드는 **SQS·S3 대상**을 씁니다.
- ⚠️ **SQS를 이벤트 소스로 쓰면 DLQ는 함수가 아니라 큐에 설정**합니다. 함수 DLQ는 **비동기 호출**용입니다.
- S3 대상 버킷을 삭제하고 설정을 남기면 다른 계정이 같은 이름으로 버킷을 만들어 실패 기록을 받을 위험이 있어, **`s3:ResourceAccount` 조건**으로 같은 계정 버킷만 허용합니다.

> 🧠 **원리** — DLQ는 **"실패한 이벤트를 잃지 않기"** 하나만 합니다. Destinations는 **"호출의 결과를 흐름으로 잇기"**까지 합니다 — 성공도 보낼 수 있고 요청·응답이 함께 담기므로 다음 단계(함수·이벤트 버스)가 그것을 입력으로 쓸 수 있습니다. 그래서 새 설계에는 Destinations, 단순 보존에는 DLQ입니다.

### 10) 이벤트 소스 매핑과 부분 배치 응답 (기술 1.2.3·1.2.4) {#esm}

| 파라미터 | SQS 표준 | SQS FIFO | Kinesis | DynamoDB Streams |
|---|---|---|---|---|
| `BatchSize` 기본/최대 | **10 / 10,000** | 10 / **10** | 100 / 10,000 | 100 / 10,000 |
| `MaximumBatchingWindowInSeconds` | 기본 0, 0~300 | **미지원** | 기본 0, 0~300 | 기본 0, 0~300 |
| `ParallelizationFactor` | — | — | 기본 1, 최대 **10** | 기본 1, 최대 10 |
| `BisectBatchOnFunctionError` | — | — | 기본 false | 기본 false |
| `MaximumRetryAttempts` | — | — | **기본 -1(무한)** | **기본 -1(무한)** |
| `MaximumRecordAgeInSeconds` | — | — | 기본 -1, 최대 604,800 | 기본 -1, 최대 604,800 |
| 실패 대상 | 큐의 redrive(DLQ) | 큐의 redrive(DLQ) | `DestinationConfig` | `DestinationConfig` |
| `StartingPosition` | — | — | `AT_TIMESTAMP`·`TRIM_HORIZON`·`LATEST` | `TRIM_HORIZON`·`LATEST` |

- **ESM은 함수를 동기로 호출**하며, **배치 윈도 도달 · 배치 크기 도달 · 페이로드 6 MB 도달** 중 먼저 만족하는 조건에서 호출합니다(**6 MB는 변경 불가**).
- **SQS 표준 스케일링**: 처음 5개 배치로 시작해 **분당 최대 300 동시 호출**씩 늘리며, ESM 하나가 동시에 처리할 수 있는 호출은 최대 **1,250**입니다. FIFO는 **메시지 그룹 ID 수와 최대 동시성 중 작은 값**으로 제한됩니다.
- **부분 배치 응답(SQS)**: ESM에 `ReportBatchItemFailures`를 켜고 함수가 `{"batchItemFailures":[{"itemIdentifier":"<messageId>"}]}`를 반환하면 **그 메시지만** 큐에 다시 보입니다. ⚠️ **함수가 예외를 던지면 배치 전체가 실패**로 간주됩니다. FIFO는 첫 실패 이후 처리를 멈추고 **실패·미처리 메시지를 모두 반환**해야 순서가 유지됩니다.
- **부분 배치 응답(스트림)**: `itemIdentifier`는 레코드의 **SequenceNumber**이고, 여러 개를 반환하면 **가장 낮은 sequence number가 체크포인트**가 됩니다. `BisectBatchOnFunctionError`를 켜면 배치를 이등분해 재시도하며 **이등분은 재시도 횟수를 소모하지 않습니다.**
- ⚠️ **스트림 기본값이 위험한 이유**: 재시도가 **무한(-1)**이라 문제 레코드가 그 샤드를 **최대 1주일**(레코드 만료까지) 막을 수 있습니다. 공식 문서가 `MaximumRetryAttempts`와 `MaximumRecordAgeInSeconds`를 **설정하라고 권장**합니다.
- **SQS 구성 팁**: 큐 **가시성 제한 시간을 함수 타임아웃의 6배 이상**으로 둡니다(함수 타임아웃은 가시성 제한 시간 이하여야 하며 **Lambda가 검증**합니다). redrive `maxReceiveCount`는 **5 이상**.
- **필터링**: ESM당 기본 **5개 필터**를 OR로 결합하고 **EventBridge 패턴 문법**을 씁니다. ⚠️ 필터에서 걸러진 **SQS 메시지는 큐에서 자동 삭제**되고, Kinesis·DynamoDB는 iterator가 그냥 넘어갑니다.

> 🧠 **원리** — ESM의 파라미터는 전부 **"실패의 범위를 좁히는 다이얼"**입니다. 배치 크기는 한 번에 걸리는 양을, 부분 배치 응답은 되돌릴 항목을, 이등분은 재시도 범위를, 최대 연령·재시도는 막힘의 상한을 정합니다. 기본값은 **처리량에 유리하고 복구에 불리**하므로 운영에서는 손대야 합니다.

### 11) 통합 — 트리거·ESM·함수 URL (기술 1.2.4) {#integration}

공식 문구는 "**코드, 이벤트 소스 매핑 및 대상**을 사용하여 Lambda 함수를 AWS 서비스와 통합합니다(예: API Gateway, DynamoDB)"입니다. 그래서 **연결의 종류와 권한이 어디서 나오는지**가 핵심입니다.

| 연결 | 누가 호출하는가 | 설정은 어디에 | 권한은 어디서 |
|---|---|---|---|
| **트리거(push)** | **서비스가 Lambda를 호출**(S3·SNS·API Gateway·EventBridge) | 이벤트를 만드는 **서비스 쪽**에 저장·관리 | 함수의 **리소스 기반 정책**(콘솔에서 만들면 자동 추가) |
| **이벤트 소스 매핑(poll)** | **Lambda가 소스를 폴링** (SQS·Kinesis·DynamoDB Streams·MSK·MQ·DocumentDB) | **Lambda 리소스**(ESM) | 함수 **실행 역할**(예: SQS는 `ReceiveMessage`·`DeleteMessage`·`GetQueueAttributes`) |
| **함수 URL** | 클라이언트가 HTTPS로 직접 | 함수(별칭 또는 `$LATEST`) | 인증 `AWS_IAM` 또는 `NONE` |

- 함수 하나에 트리거를 **여러 개** 둘 수 있고, **한 호출의 이벤트에는 한 트리거의 데이터만** 들어갑니다.
- **함수 URL**은 전용 HTTPS 엔드포인트(`https://<url-id>.lambda-url.<region>.on.aws`)이고 CORS를 설정할 수 있으며 IPv4·IPv6 듀얼스택입니다. ⚠️ **PrivateLink는 지원하지 않습니다.**
- Destinations는 콘솔에서 Source를 **"Asynchronous invocation"** 또는 **"Event source mapping invocation"**으로 골라 설정하고(CLI는 `update-function-event-invoke-config`), **DLQ는 `update-function-configuration --dead-letter-config`**로 설정합니다 — **다른 명령**입니다.

> 🧠 **원리** — 권한의 방향이 연결의 방향을 따릅니다. **밖에서 Lambda를 부르면**(push) Lambda 쪽에 "불러도 된다"는 **리소스 기반 정책**이 필요하고, **Lambda가 밖을 읽으면**(poll) Lambda의 **실행 역할**에 읽기 권한이 필요합니다. 문항에서 "권한을 어디에 주는가"가 나오면 이 방향을 먼저 봅니다.

---

## ✍️ 시험 포인트

- **"VPC에 붙인 뒤 외부 API 호출이 타임아웃된다"** → 프라이빗 서브넷 + **NAT 게이트웨이** + `0.0.0.0/0` 라우팅. **퍼블릭 서브넷에 붙이는 것은 해결이 아닙니다.**
- **"S3·DynamoDB만 부르면 된다"** → **게이트웨이 VPC 엔드포인트**(추가 요금 없음). NAT는 과금되므로 비용 문항의 정답이 아닙니다.
- **"하류 RDS가 Lambda 폭주로 죽는다"** → **예약 동시성**(상한 역할). "첫 호출이 느리다"면 **프로비저닝된 동시성**($LATEST 불가).
- **"비동기 호출이 조용히 사라진다"** → 재시도 소진·연령 초과 → **DLQ 또는 Destinations** 설정. `DeadLetterErrors`는 **전달 자체가 실패**해 이벤트가 삭제된 신호입니다.
- **"SQS 배치에서 한 건만 실패하는데 전체가 다시 온다"** → **`ReportBatchItemFailures` + `batchItemFailures` 반환**. 함수가 예외를 던지면 전체 실패입니다.
- **"Kinesis 소비가 특정 샤드에서 멈췄다"** → 독약 레코드. `MaximumRetryAttempts`·`MaximumRecordAgeInSeconds`·`BisectBatchOnFunctionError`와 **on-failure 대상**. `IteratorAge`로 감지합니다.
- **"CPU가 부족하다"** → Lambda에는 CPU 설정이 없습니다 — **메모리 상향**(1,769 MB ≈ 1 vCPU). 최적값을 **측정으로 고르는 것은 작업 4.3**입니다.
- 권한 방향을 먼저 봅니다 — **push는 리소스 기반 정책**, **poll은 실행 역할**.

---

## ⚠️ 흔한 함정 {#pitfalls}

| 함정 | 바로잡기 |
|---|---|
| 퍼블릭 서브넷에 연결하면 인터넷이 된다고 본다 | 퍼블릭 IP가 붙지 않는다. **프라이빗 서브넷 + NAT**가 공식 경로 |
| VPC 연결이 콜드 스타트를 늘린다고 외운다 | ENI는 **생성·설정 변경 시점에 미리** 만들어진다(준비 전에는 함수가 `Pending`) — 2019년 이전 모델이다 |
| `AWSLambdaVPCAccessExecutionRole`을 호출 권한으로 본다 | **ENI 생성** 권한이다. 호출 자체에는 필요 없다 |
| `Invoke`가 200이면 성공으로 본다 | StatusCode는 **함수 오류를 반영하지 않는다** — `X-Amz-Function-Error` 헤더와 본문을 본다 |
| 함수 DLQ를 SQS 이벤트 소스의 실패 보존으로 쓴다 | SQS를 **이벤트 소스**로 쓰면 DLQ는 **큐에** 설정한다. 함수 DLQ는 **비동기 호출**용 |
| DLQ 대상에 FIFO 큐·토픽을 고른다 | **SQS·SNS 표준만** 지원한다 |
| Destinations와 DLQ를 같은 것으로 본다 | DLQ는 실패만·이벤트 본문만·함수 레벨. Destinations는 **성공도**·**호출 레코드**·버전·별칭 단위 |
| 스트림 ESM을 기본값으로 둔다 | 재시도가 **무한(-1)**이라 한 레코드가 샤드를 **최대 1주일** 막는다 |
| 배치에서 예외를 던져 "실패만 재시도"를 기대한다 | 예외는 **배치 전체 실패**다. `batchItemFailures`로 **보고**해야 한다 |
| 큐 가시성 제한 시간을 함수 타임아웃과 같게 둔다 | **6배 이상** 권장. 함수 타임아웃이 가시성보다 크면 Lambda가 거부한다 |
| 환경 변수에 DB 비밀번호를 둔다 | 암호화되지만 **Secrets Manager 권장**. 환경 변수는 버전에 잠기고 교체가 어렵다 |
| `--environment`로 변수 하나만 보낸다 | `Variables` **전체가 교체**된다 — 기존 값을 함께 보낸다 |
| 계층을 컨테이너 이미지 함수에 붙이려 한다 | 계층은 **`.zip` 배포 함수에서만** 쓴다 |
| 호출별 데이터를 핸들러 밖에 둔다 | 핸들러 밖은 **환경당 한 번**이라 다른 호출에 새어 나간다 |

---

## 🧪 자가 점검

**Q1.** VPC에 연결한 Lambda가 사내 RDS는 잘 읽는데 외부 결제 API 호출만 `Task timed out`으로 끝난다. 원인과 처방은? (→ 2) 나가는 경로)

<details><summary>정답 보기</summary>

VPC에 연결하면 함수가 **그 VPC의 네트워크 규칙**을 따르게 되어, 밖으로 나가는 경로가 없으면 인터넷에 닿지 못합니다(연결하지 않은 함수는 인터넷이 열린 **Lambda 관리형 VPC**에서 나갑니다). 처방은 **프라이빗 서브넷에 연결 + 퍼블릭 서브넷의 NAT 게이트웨이 + 프라이빗 라우팅 테이블의 `0.0.0.0/0 → NAT`**입니다. ⚠️ **퍼블릭 서브넷에 연결하는 것은 해결이 아닙니다** — 퍼블릭 IP가 붙지 않습니다. S3·DynamoDB만 필요하면 **게이트웨이 VPC 엔드포인트**(추가 요금 없음)가 더 쌉니다.
</details>

**Q2.** 비동기로 호출되는 함수가 간헐적으로 실패하는데 실패한 이벤트를 찾을 수 없다. 재시도 규칙과 보존 설정을 설명하라. (→ 8) 수명 주기 · 9) Destinations)

<details><summary>정답 보기</summary>

비동기 호출에서 **함수 오류**(코드·런타임 오류·타임아웃)는 Lambda가 **기본 2회 추가 실행**(1분·2분 대기)하고, **스로틀(429)·시스템 오류(5xx)**는 이벤트를 내부 큐로 되돌려 **기본 최대 6시간** 재시도합니다(간격 1초에서 최대 5분까지 지수 증가). 재시도가 소진되거나 최대 이벤트 연령을 넘으면 **폐기**되므로, **DLQ 또는 Destinations(on-failure)**를 설정해야 이벤트가 남습니다.

DLQ는 **이벤트 본문만** 보내고 대상이 **SQS·SNS 표준만**이며 **함수 레벨** 설정입니다. Destinations는 **on-success도** 지정할 수 있고 **요청·응답이 든 호출 레코드**를 보내며 **버전·별칭 단위**로 설정합니다. `DeadLetterErrors` 지표가 오르면 **전달 자체가 실패**해 이벤트가 삭제된 것입니다.
</details>

**Q3.** Kinesis를 소비하는 함수가 특정 샤드에서 몇 시간째 진척이 없다. 무엇이 일어났고 어떤 파라미터로 푸는가? (→ 10) ESM)

<details><summary>정답 보기</summary>

**독약 레코드(poison record)**가 샤드를 막았습니다. 스트림 ESM은 **순서를 지키려고 배치 전체를 재시도**하므로 오류가 해결될 때까지 뒤 레코드로 넘어가지 못합니다. ⚠️ **기본값이 `MaximumRetryAttempts = -1`(무한)**이라 레코드 만료까지(최대 1주일) 막힐 수 있습니다.

처방은 **`MaximumRetryAttempts`와 `MaximumRecordAgeInSeconds`를 설정**하고 **on-failure 대상**(`DestinationConfig`)을 두는 것, 그리고 **`BisectBatchOnFunctionError`**로 배치를 이등분해 범위를 좁히는 것입니다(이등분은 재시도 횟수를 소모하지 않습니다). 감지는 **`IteratorAge`** 지표로 합니다. ⚠️ **샤드를 늘려도 막힌 샤드는 풀리지 않습니다.**
</details>

**Q4.** 예약 동시성과 프로비저닝된 동시성의 목적·비용·적용 대상은? 계정 한도가 1,000일 때 한 함수에 1,000을 예약할 수 있는가? (→ 7) 동시성)

<details><summary>정답 보기</summary>

**예약 동시성**은 함수 전용 용량을 보장하면서 **동시에 상한**으로도 작동합니다(하류 DB 보호). **무료**이고 **함수**에 설정하며, **0으로 두면 호출이 차단**됩니다. **프로비저닝된 동시성**은 환경을 **미리 초기화**해 콜드 스타트를 없애고 **추가 요금**이 들며 **버전·별칭**에만 설정합니다(⚠️ `$LATEST` 불가).

**1,000 전부는 예약할 수 없습니다** — 예약은 "미예약 풀 − 100"까지만 가능해 **100은 예약 없는 함수용으로 남겨야** 합니다.
</details>

**Q5.** SQS 배치 10건 중 3건만 실패했는데 10건이 모두 다시 처리된다. 원인과 처방은? 그리고 큐 가시성 제한 시간은 어떻게 잡는가? (→ 10) ESM)

<details><summary>정답 보기</summary>

함수가 **예외를 던졌기** 때문입니다 — 그러면 배치 **전체**가 실패로 간주됩니다. 처방은 ESM에 **`ReportBatchItemFailures`**를 켜고 함수가 모든 예외를 잡아 **`{"batchItemFailures":[{"itemIdentifier":"<messageId>"}]}`**로 실패 항목만 보고하는 것입니다(그러면 그 메시지만 큐에 다시 보입니다). FIFO는 첫 실패 이후 처리를 멈추고 **실패·미처리 메시지를 모두 반환**해야 순서가 유지됩니다.

가시성 제한 시간은 **함수 타임아웃의 6배 이상**을 권장하며, 함수 타임아웃이 가시성 제한 시간보다 크면 **Lambda가 거부**합니다. redrive `maxReceiveCount`는 5 이상으로 둡니다.
</details>

**Q6.** 같은 이벤트가 두 번 처리되어 결제가 중복됐다. 왜 중복이 생기고, 공식 문서가 제시하는 멱등성 패턴은? (→ 8) 수명 주기)

<details><summary>정답 보기</summary>

비동기 호출의 내부 큐는 **eventually consistent**라 오류가 없어도 같은 이벤트를 여러 번 받을 수 있고, **ESM은 각 이벤트를 최소 한 번** 처리합니다. 동기 직접 호출도 재시도하면 코드가 일부 실행된 뒤 다시 돌 수 있습니다.

패턴은 이벤트의 **고유 속성(거래·구매 ID)**을 키로 **DynamoDB에 조건부 쓰기**를 하는 것입니다 — 상태 `IN_PROGRESS`와 만료 시각(현재 + 남은 실행 시간)을 기록하고, `ConditionalCheckFailedException`이면 다른 호출이 처리 중이거나 이미 끝난 것으로 보고, 처리 후 `COMPLETE`로 갱신하며 TTL로 만료합니다. ⚠️ **중복 이벤트는 오류 없이 정상 종료**해야 합니다 — 오류로 끝내면 호출 서비스가 추가 재시도를 합니다.
</details>

**Q7.** 트리거(push)와 이벤트 소스 매핑(poll)은 권한이 각각 어디서 나오는가? 그리고 Destinations와 DLQ는 어떤 명령으로 설정하는가? (→ 11) 통합)

<details><summary>정답 보기</summary>

**push(S3·SNS·API Gateway)**는 서비스가 Lambda를 부르므로 함수의 **리소스 기반 정책**에 호출 권한이 필요합니다(콘솔에서 트리거를 만들면 자동 추가). **poll(SQS·Kinesis·DynamoDB Streams)**은 Lambda가 소스를 읽으므로 함수 **실행 역할**에 읽기 권한이 필요합니다(SQS는 `ReceiveMessage`·`DeleteMessage`·`GetQueueAttributes`).

명령은 다릅니다 — **Destinations는 `update-function-event-invoke-config`**, **DLQ는 `update-function-configuration --dead-letter-config`**입니다.
</details>

---

### 📌 출처

1. Giving Lambda functions access to resources in an Amazon VPC — https://docs.aws.amazon.com/lambda/latest/dg/configuration-vpc.html
2. Lambda quotas — https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-limits.html
3. Configure Lambda function memory — https://docs.aws.amazon.com/lambda/latest/dg/configuration-memory.html
4. Configure Lambda function timeout — https://docs.aws.amazon.com/lambda/latest/dg/configuration-timeout.html
5. Working with Lambda environment variables — https://docs.aws.amazon.com/lambda/latest/dg/configuration-envvars.html
6. Lambda function runtimes — https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtimes.html
7. Managing Lambda dependencies with layers — https://docs.aws.amazon.com/lambda/latest/dg/chapter-layers.html
8. Augment Lambda functions using Lambda extensions — https://docs.aws.amazon.com/lambda/latest/dg/lambda-extensions.html
9. Understanding Lambda function scaling — https://docs.aws.amazon.com/lambda/latest/dg/lambda-concurrency.html
10. Configuring reserved concurrency — https://docs.aws.amazon.com/lambda/latest/dg/configuration-concurrency.html
11. Configuring provisioned concurrency — https://docs.aws.amazon.com/lambda/latest/dg/provisioned-concurrency.html
12. Capturing records of Lambda asynchronous invocations — https://docs.aws.amazon.com/lambda/latest/dg/invocation-async-retain-records.html
13. Lambda API Reference: Invoke — https://docs.aws.amazon.com/lambda/latest/api/API_Invoke.html
14. How Lambda processes records from stream and queue-based event sources — https://docs.aws.amazon.com/lambda/latest/dg/invocation-eventsourcemapping.html
15. Handling errors for an SQS event source in Lambda — https://docs.aws.amazon.com/lambda/latest/dg/services-sqs-errorhandling.html
16. Configuring scaling behavior for SQS event source mappings — https://docs.aws.amazon.com/lambda/latest/dg/services-sqs-scaling.html
17. Retain discarded batch records for a Kinesis event source — https://docs.aws.amazon.com/lambda/latest/dg/kinesis-on-failure-destination.html
18. Creating and managing Lambda function URLs — https://docs.aws.amazon.com/lambda/latest/dg/urls-configuration.html
19. DVA-C03 공식 시험 가이드 · 콘텐츠 도메인 1 (한국어) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/developer-associate-03/developer-associate-03-domain1.html
