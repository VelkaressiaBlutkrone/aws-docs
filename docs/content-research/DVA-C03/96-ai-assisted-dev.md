# 96 — AI 보조 개발 6 Skill (C03 신설, 4개 Task에 흩어져 있다)

> **원자료 노트(저작 재료)** · 조회일 **2026-11-01**. 사실마다 URL을 붙였고, 확인하지 못한 것은 `## 확인 필요`에 남겼다.
> 이 6개 Skill은 **Task 하나에 모여 있지 않다.** 그래서 Task 노트가 아니라 주제 노트로 묶는다 — Phase 3에서 각 Task 학습문서로 흩어 넣는다.

| Skill | Task | 요구 |
|---|---|---|
| **1.1.9** | 1.1 개발 | AI 보조 개발 도구로 **코드 생성·리뷰·최적화** — 스펙 기반 생성, 자동 코드 리뷰, 지능형 자동 완성, 리팩터링 제안, 보안 스캔 |
| **1.1.10** | 1.1 개발 | **관리형 AWS AI 서비스를 애플리케이션에 통합** |
| **3.2.5** | 3.2 테스트 | AI 도구로 **테스트 생성·반복 워크플로 자동화** — 자동 실행, 결과 분석, 회귀 테스트, 커버리지 |
| **3.3.9** | 3.3 배포 | AI 도구로 **CI/CD 지원** — 배포 승인 자동화, 환경 프로비저닝, 배포 후 검증 |
| **4.1.5** | 4.1 원인 분석 | AI 도구로 **오류 분석·문제 해결 제안 생성** |
| **4.3.6** | 4.3 최적화 | AI 도구로 **최적화 기회 식별** — 병목 탐지, 리소스 사용 최적화, 코드 효율 개선 |

---

## 0. ⚠️ 먼저 — "AWS AI 도구"가 무엇인지부터 틀리기 쉽다

가이드 **in-scope 「Machine Learning and Artificial Intelligence」는 4개뿐**이다.

> Amazon Bedrock · Amazon Bedrock AgentCore · **Amazon Quick** · **Kiro**

여기서 두 가지를 바로잡아야 한다.

### ⚠️ `Amazon Q Developer`는 in-scope 목록에 없다 — 그리고 지원 종료 예정이다

C02 노트(`1-1.md` Skill 1.1.11, `3-3.md` Skill 3.3.6)는 AI 보조 개발을 **Q Developer**로 다뤘다. C03에서는 그 이름이 **목록에 없다.**

| 대상 | 지원 종료 | 신규 차단 |
|---|---|---|
| Q Developer **IDE 플러그인 + 유료 구독** | **2027-04-30** | 신규 가입 **2026-05-15** |
| Q Developer **for GitHub 앱** | **2027-01-30** | 신규 설치 **2026-11-18** |

공식 문서가 대체재를 직접 지목한다 — *"explore Kiro to access the latest models and features"*. **문항은 Kiro로 쓴다.**

### ⚠️ `Amazon Quick`은 개발 도구가 아니다

Amazon Quick(Quick Suite)은 **업무용 에이전트 워크스페이스**다 — Research(Quick Research) · BI(**Quick Sight**) · 자동화(Quick Flows·Quick Automate) · 지식 기반(Quick Index)을 한 작업 공간에 묶은 것이고, 코딩 도구가 아니다. 문서는 `docs.aws.amazon.com/quick/latest/userguide/`다.

> ⚠️ **기묘한 짝**: `Amazon Quick`은 **in-scope**인데 그 BI 구성 요소인 **`Amazon Quick Sight`는 out-of-scope**다(가이드 Analytics 범위 밖 목록). 둘을 같은 것으로 묶어 쓰면 안 된다.

**따라서 이 6개 Skill에서 실제로 쓸 도구는 Kiro(개발·테스트·CI/CD)와 CloudWatch의 AI 기능(문제 해결)이다.** Bedrock·AgentCore는 1.1.10(통합 대상)과 Task 2.3(보안)의 재료다.

---

## 1. Kiro — 1.1.9 · 3.2.5 · 3.3.9의 중심

Kiro는 **스펙 기반 개발(spec-driven development)**을 위해 만들어진 **에이전틱 개발 환경**이다. 프롬프트에 반응하는 대신 **구조화된 명세에서 출발해** 코드베이스 전반을 계획·구현·검증한다.

### 핵심 구성 요소

| 요소 | 하는 일 | 걸리는 Skill |
|---|---|---|
| **Specs(스펙)** | 만들 것을 구조화된 자연어 요구사항으로 정의하고, Kiro가 그것으로 구현을 끝까지 끌고 간다. 프롬프트를 **요구사항 → 시스템 설계 → 작업 목록**으로 쪼갠 뒤에야 코드를 쓴다 | **1.1.9** "스펙 기반 코드 생성" |
| **Hooks(훅)** | 파일 저장·커밋 등 **이벤트에 걸리는 자동 트리거** — 표준 강제, 테스트 실행, 문서 갱신 | **3.2.5** 반복 테스트 자동화 |
| **Steering files** | 아키텍처·규약·제약을 담는 **프로젝트 수준 영속 컨텍스트** | 1.1.9 |
| **Custom subagents** | 도메인 전용 에이전트 — **보안 리뷰**, API 계약 검증, 인프라 프로비저닝 | **1.1.9** 자동 코드 리뷰·보안 스캔 |
| **Powers** | 에이전트 동작을 확장하는 조합형 기능 모듈 | — |
| **MCP 통합** | Model Context Protocol 서버에 연결해 도구를 확장 | — |

### 형태 3가지

- **Kiro IDE** — Code OSS(VS Code와 같은 기반) 위에 올린 통합 환경. 기존 확장을 그대로 쓴다
- **Kiro CLI** — 터미널에서 쓰는 에이전틱 기능
- **Kiro Crew** — 한 세션을 넘어 이어지며 **스스로 개선되는 영속 작업 공간**

### CI/CD에서 쓰는 법 (3.3.9 · 3.2.5)

개발자가 없는 상태로 돌아야 하므로 **Kiro CLI를 파이프라인에 넣는다.** 브라우저 로그인을 쓸 수 없으므로 인증이 갈린다.

- **API 키 인증**: `KIRO_API_KEY`에 `ksk_`로 시작하는 유효한 키를 넣는다. CLI는 **활성 브라우저 세션을 먼저 보고 그다음 `KIRO_API_KEY`**를 본다. 활성 ID는 `kiro-cli whoami`로 본다
- **비대화형(헤드리스) 실행**: `kiro-cli chat --no-interactive <프롬프트>`
- 관리자가 구독을 관리하면 **"사용자 제공 API 키"를 관리자가 먼저 활성화**해야 한다

> ⚠️ 이 셋은 AWS 공식 지식 센터(repost) 기준이고, 세부는 `kiro.dev` 문서를 가리킨다. **`docs.aws.amazon.com`에 같은 내용이 있는지는 확인하지 못했다**(§확인 필요).

---

## 2. CloudWatch investigations — 4.1.5의 중심

**생성형 AI 기반 인시던트 대응 보조 기능**이다. 시스템 텔레메트리를 훑어 관련 데이터와 제안을 꺼내 준다.

- 꺼내는 것: **AI가 만든 관찰·제안·가설**, 다중 리소스 가설의 **시각적 표현**, 자연어 설명과 근본 원인 분석
- 분석 대상 텔레메트리: 지표 · 로그 · **배포 이벤트** · AWS Health 이벤트 · CloudTrail 변경 이벤트 · **X-Ray 추적** · Logs Insights 쿼리
- **추가 구성 없이** 시작할 수 있다. 시작하면 **로그인한 사용자의 권한으로** 경보·지표·쿼리에 연결된 리소스를 조사한다
- **리소스를 만들지 않고**, 모든 동작이 **CloudTrail에 기록**된다
- 구성하면 추가 기능이 열린다 — 제안 **수락/폐기**(조사를 반복 정련), **교차 계정** 수집(CloudWatch cross-account observability), 텔레메트리 소스 추가(CloudTrail 이력·X-Ray·Application Signals)
- API·CLI 네임스페이스는 **`aiops`**이고, 그것으로 하는 일은 **조사 그룹(investigation group)과 그룹 정책의 생성·관리·삭제**다. ⚠️ **조사 자체의 시작·관리는 콘솔에서만** 한다

> ⭐ 이 기능은 **경보 작업과도 이어진다** — CloudWatch 경보 작업 목록에 "조사 시작"이 있다(SOA 쪽 `soa-t1-1.md` §4와 같은 사실).

---

## 2-b. Skill 4.3.6 — **단일 "AI 최적화 서비스"는 없다** (G-01 판정)

조사 결론부터: **가이드가 특정 서비스를 지목하지 않고, 흔히 떠올리는 후보들이 in-scope 목록에 없다.**

| 후보 | 판정 |
|---|---|
| **AWS Compute Optimizer** | Lambda 메모리 권장의 정본이지만(옵트인 필요) **in-scope 목록에 없다** |
| **Amazon CodeGuru Profiler** | in-scope 목록에 없다 |
| **AWS Lambda Power Tuning** | AWS 서비스가 아니라 **오픈 소스 도구**다(Step Functions 기반) |

> ⚠️ **"목록에 없다"와 "범위 밖이다"는 다르다.** in-scope 목록은 공식적으로 *non-exhaustive*이고, 위 셋은 **out-of-scope 목록에도 없다.** 그러니 "범위 밖"으로 단정하지 말고, **우리가 정답 보기로 쓰지 않는다**로 운영한다.

**그래서 4.3.6을 받칠 수 있는 in-scope AI 기능은 둘이다.**

1. **CloudWatch의 생성형 AI 기능** — 병목을 찾는 분석을 돕는다
   - **자연어 쿼리 생성**: Logs Insights · Metrics Insights · OpenSearch PPL/SQL용 쿼리를 평문 영어 설명에서 만들어 주고, **줄 단위 설명**과 **유도식 수정**도 제공한다. 권한은 `CloudWatchLogsFullAccess`·`CloudWatchLogsReadOnlyAccess`·`AdministratorAccess`·`ReadOnlyAccess` 중 하나이거나 **`cloudwatch:GenerateQuery`**가 필요하다. **리전 서비스**이고 일부 리전은 프롬프트 처리를 위해 미국 리전으로 교차 호출한다
   - **쿼리 결과 자연어 요약**: Logs Insights 결과를 요약해 준다
2. **Kiro** — 코드 효율 개선·리팩터링 제안(§1). 다만 "최적화 기회 식별"을 명시한 공식 문장은 찾지 못했다

### 저작 규칙 (이 판정의 쓸모)

- **"어떤 AWS AI 서비스가 최적화 기회를 알려 주는가"처럼 단일 서비스를 고르게 하는 문항을 쓰지 않는다.** 공식 근거가 없다.
- 대신 **"CloudWatch에서 쿼리를 자연어로 만들려면 어떤 권한이 필요한가"**(`cloudwatch:GenerateQuery`)처럼 **확인된 사실**을 묻는다.
- **Compute Optimizer를 정답 보기로 쓰지 않는다**(오답 보기로도 쓰지 않는다 — 목록에 없을 뿐 틀린 서비스가 아니라 판단이 갈린다).

> 덤으로 확인한 4.3.2(메모리·컴퓨팅 최적화) 사실: Lambda 메모리는 **128 MB ~ 10,240 MB**이고 기본은 **128 MB**다. CPU는 메모리에 **선형 비례**하며 **1,769 MB에서 1 vCPU**에 해당한다. ⚠️ 그리고 현행 Lambda 문서의 페이지 제목이 **"Configure Lambda Event Function memory"**다 — C02 노트가 경고한 **"Event Function" 용어 변경이 실제로 반영돼 있다.**

## 3. 1.1.10 — 관리형 AI 서비스 통합

이 Skill은 "AI로 개발하기"가 아니라 **"AI를 애플리케이션 기능으로 넣기"**다. in-scope 기준 대상은 **Bedrock**(모델 호출)과 **Bedrock AgentCore**(에이전트 런타임·ID)다.

통합의 보안 측면은 **Task 2.3이 통째로 담당**한다([`tasks/2-3.md`](tasks/2-3.md)) — 모델 접근, 사설 연결, 입출력 필터링, 에이전트 상호작용, 로그 보호. **1.1.10은 "어떻게 붙이는가", 2.3은 "안전하게 붙이는가"**로 가른다.

⚠️ **out-of-scope 주의** — `Amazon SageMaker AI`·`Amazon Polly`·`Amazon Rekognition`·`Strands Agents`는 범위 **밖**이다. "관리형 AI 서비스 통합"을 Rekognition 예시로 쓰면 범위를 벗어난다.

---

## 4. 시험에서 묻는 방식 (추정이 아니라 Skill 문구에서 끌어낸 것)

- "요구사항 문서에서 바로 구현까지 끌고 가려면?" → Kiro **Specs**
- "커밋할 때마다 테스트·문서 갱신을 자동으로" → Kiro **Hooks**
- "보안 리뷰를 에이전트에게 맡기려면" → Kiro **Custom subagents**
- "파이프라인에서 브라우저 없이 에이전트를 돌리려면" → **Kiro CLI 헤드리스 + `KIRO_API_KEY`**
- "장애가 났는데 어디서부터 볼지 모르겠다" → **CloudWatch investigations**(추가 구성 없이 시작, 로그인 사용자 권한)
- "조사를 자동화로 만들고 싶다" → ⚠️ **조사 시작은 콘솔 전용**이고 API는 그룹·정책만 다룬다

## 5. 흔한 함정·혼동 짝

| 혼동 | 가르는 기준 |
|---|---|
| **Amazon Q Developer** vs **Kiro** | C03 in-scope는 **Kiro**다. Q Developer는 목록에 없고 2027-04-30 지원 종료 |
| **Amazon Quick** vs **Quick Sight** | Quick은 **in-scope**(업무용 에이전트 워크스페이스), Quick **Sight**는 **out-of-scope** |
| Kiro IDE vs CLI vs Crew | 사람이 함께 / 자동화·파이프라인 / 세션을 넘는 영속 작업 공간 |
| CloudWatch investigations **시작** vs **그룹 관리** | 시작은 **콘솔만**, 그룹·정책은 `aiops` API |
| 1.1.10 vs Task 2.3 | **붙이는 법** vs **안전하게 붙이는 법** |
| "AI 보조 개발" vs 범위 밖 | 도구를 **쓰는 것**은 범위 안. **FM 선택·프롬프트 엔지니어링·RAG 설계·AI 거버넌스**는 범위 밖 |

## 6. 사실·숫자

- Q Developer IDE 플러그인·유료 구독 지원 종료 **2027-04-30** · 신규 가입 차단 **2026-05-15**
- Q Developer for GitHub 앱 지원 종료 **2027-01-30** · 신규 설치 차단 **2026-11-18**
- Kiro API 키 접두어 **`ksk_`**
- CloudWatch investigations API 네임스페이스 **`aiops`**

## 7. 출처 목록

조회일 전부 **2026-11-01**.

1. 가이드 in-scope 서비스 — https://docs.aws.amazon.com/aws-certification/latest/developer-associate-03/dva-03-in-scope-services.html
2. 가이드 out-of-scope 서비스 — https://docs.aws.amazon.com/aws-certification/latest/developer-associate-03/dva-03-out-of-scope-services.html
3. Q Developer IDE 플러그인 지원 종료 — https://docs.aws.amazon.com/amazonq/latest/qdeveloper-ug/q-developer-ide-end-of-support.html
4. Q Developer for GitHub 지원 종료 — https://docs.aws.amazon.com/amazonq/latest/qdeveloper-ug/amazon-q-for-github.html
5. (AWS 블로그) Q Developer 지원 종료 공지 · Kiro 구성 요소 — https://aws.amazon.com/blogs/devops/amazon-q-developer-end-of-support-announcement/
6. (AWS 블로그) Kiro IDE·CLI·Crew — https://aws.amazon.com/blogs/modernizing-with-aws/augment-your-windows-management-tools-with-agentic-ai-using-kiro-cli/
7. (AWS 지식 센터) Kiro CI/CD 인증·헤드리스 — https://repost.aws/knowledge-center/kiro-iam-identity-center-auth
8. CloudWatch investigations — https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Investigations.html
9. `aiops` CLI 레퍼런스 — https://docs.aws.amazon.com/cli/latest/reference/aiops/index.html
10. Amazon Quick 에이전트 — https://docs.aws.amazon.com/quick/latest/userguide/agents-desktop.html
11. (AWS 뉴스 블로그) Amazon Quick Suite 발표 — https://aws.amazon.com/blogs/aws/reimagine-the-way-you-work-with-ai-agents-in-amazon-quick-suite/
12. CloudWatch Logs 자연어 쿼리 생성(`cloudwatch:GenerateQuery`) — https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CloudWatchLogs-Insights-Query-Assist.html
13. Logs Insights 쿼리 결과 자연어 요약 — https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CloudWatchLogs-Insights-Query-Results-Summary.html
14. Lambda 메모리 구성(128~10,240 MB · 1,769 MB = 1 vCPU · Compute Optimizer 옵트인) — https://docs.aws.amazon.com/lambda/latest/dg/configuration-memory.html

## 확인 필요

- ~~**Skill 4.3.6에 대응하는 AWS 도구를 특정하지 못했다**~~ → ✅ **판정했다(2026-11-01, G-01). §2-b 참조** — 단일 서비스는 **없는 것이 답**이다.
- **Kiro 공식 문서가 `docs.aws.amazon.com`에 있는지** 확인하지 못했다. 현재 근거는 AWS 블로그·repost이고 세부는 `kiro.dev`를 가리킨다. 학습문서에 CLI 플래그·키 형식을 쓰려면 정본을 다시 찾는다.
- **`Amazon Quick`이 DVA 문항에 어떤 모습으로 나올지** 단정하지 못했다. 개발 도구가 아닌데 ML/AI in-scope에 있다 — 1.1.10의 "관리형 AI 서비스" 예시로 나올 가능성만 있고 근거는 없다.
- **Kiro Crew·Powers의 공식 정의** — 블로그 수준 서술만 확보했다.
- 블로그 출처 3건(5·6·11)은 **제품 구성·날짜 서술에만** 썼다. 동작·수치 단정은 공식 문서(3·4·8·9)에서만 가져왔다.
