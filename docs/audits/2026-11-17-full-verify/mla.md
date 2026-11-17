# MLA-C01 전수 검증 — 2026-11-17

> **대상**: `develop` @ `4b83461` · `flutter_app/assets/content/mla/` — 학습문서 12편 · 문항 **321개(321/321 `verified: true`, 전부 라이브)** · 가이드 `exam_guides/MLA-C01.json`
> **이 문서의 성격**: 1단계 검증 보고서다. **콘텐츠·코드·테스트를 한 글자도 고치지 않았고** git 상태도 바꾸지 않았다. 2단계가 그대로 집행할 수 있도록 항목마다 **문항 ID · 정답 인덱스 실측값 · 공식 원문 인용 · 수정안 · 전수 개수**를 적는다.
> **한 줄 결론**: 정답이 틀리거나 정답 인덱스를 바꿔야 하는 문항은 **0건**이다. 라이브 🔴는 **1건**(오답 근거의 거짓 일반화)이고, 가장 큰 덩어리는 **「URL 은 200인데 그 페이지에 그 사실이 없다」 8문항**과 **상태 표기 누락 7문항**, **교차 Task 실중복 7쌍**이다.

---

## 0. 요약

| 판정 | 수 | 뜻 |
|---|---|---|
| 🔴 | **1문항** | 사실이 거짓 (정답 인덱스는 불변) |
| 🟡 | **23문항** + 학습문서 6자리 | 불완전·모호·출처가 사실을 담지 않음·상태 누락 |
| 🟢 | 12묶음 | 품질(중복·저작 메모·길이 단서·메타 문구·범위) — 사실은 옳다 |
| ✅ | **297문항** | 🔴·🟡 없음(🟢 신호만 붙은 문항 포함) |

- **공개 문항 중 🔴: 1건** (`mla-t3-2-q10`) ← 가장 중요한 수치. 정답이 둘이거나 틀린 문항은 0건.
- `prescreen` (`node tool/prescreen.mjs build mla`, 2026-11-17 실행): 구조·정합성 플래그 **0건** · 품질 신호 **75/321문항(23%)** — `length-cue` **16** · `meta-phrasing` **60** · `authoring-memo` **0** · `explanation-long` **0** · Task 내 중복 후보 **0쌍**(임계 기준. 임계 아래 실중복은 §3-1)
- 검증한 출처 URL: 문항 고유 **382개 전부 본문을 받아** 대조했다(`200 r=0` 380 · `200 r=1` 2 = 이미 상태 메모가 달린 백서 2종). 그중 **「그 사실을 담지 않음」 9문항 · 고유 URL 10개**(§2-B 8문항 + §2-C `t4-2-q33`. 주 출처 7개 + 함께 인용된 둘째 출처 3개 — 둘째 출처도 그 사실을 담지 않는다).
- 정독량: **문항 321개 전문** · 학습문서 12편의 「시험 직전 요약」 120줄과 자가 점검 **94문답 전문** · 공식 페이지 **약 470개**(문항 출처 382 + 대조용 88).

### 측정 방법 (2단계가 다시 재지 않도록)

| 축 | 방법 | 대조군 |
|---|---|---|
| 본문 추출 | `curl -sL` → `<div id="main-col-body">` 이후 태그 제거 → 정규식 탐침. 두 번째 방법은 AWS 문서 검색·리더(`aws___search_documentation`) | 없는 슬러그 `sagemaker/latest/dg/zz-bogus-control.html` → `200 r=1 len=19`(인덱스로 튕김) |
| 인용 정확성 | ① 해설·정답 보기의 **라틴 식별자와 2자리 이상 수치**가 인용 페이지 합집합에 있는지 321문항 전수 기계 대조 → 55문항 72토큰이 걸렸고 전부 읽어 가렸다 ② 정독하며 의심한 주장은 인용 페이지를 열어 탐침 | 탐침마다 「그 페이지에 분명히 있는 낱말」을 함께 셌다(예: `distributed-training-strategies.html` 에서 `learning rate` 0건일 때 `batch size` 8건·`model parallel` 6건) |
| 닫힌 서비스 | 공식 Lifecycle 하위 세 페이지(maintenance 6,843자 · sunset 2,680자 · full shutdown 3,474자)를 받아 **61개 트리거**로 md·문항 전수 스캔 | 세 페이지에서 `Amazon SageMaker AI – Clarify`·`Amazon Mechanical Turk`·`Amazon SageMaker AI – Profiler` 가 각각 잡힌다 |
| 중복 | 51,360쌍 전수. 정답 보기 자카드(원형)·**조사 벗김 변형**·지문 자카드·출처 공유 여부. 같은 Task 쌍은 0.15 이상 **27쌍 전부**, 교차 Task 는 상위 약 110쌍의 본문을 읽었다 | 문자열 완전 동일 0쌍(그래서 자카드가 필요하다) |
| 범위 | 공식 ko `범위 외 AWS 서비스` 페이지에서 이름 **102개**를 뽑아 정답 보기·지문·해설과 대조 | 같은 페이지에서 `AWS Artifact`·`Amazon Inspector` 가 목록에 실재 |
| 가이드 동기 | 레포 JSON 의 지식·기술 **133문장**을 공식 ko 도메인 4쪽과 공백 무시 대조 | **133/133 일치** |

⚠️ 탐침에서 얻은 교훈 하나 — `8 minutes` 는 0건이었고 실제 문구는 `8 min` 이었다(`deploy-model-options.html`). **「없다」는 다른 표현까지 본 뒤에만 적었다.**

---

## 1. 🔴 (문항·학습문서)

### mla-t3-2-q10 — 「실시간 엔드포인트는 최소 인스턴스가 1 이상」은 거짓 일반화다

- **공개 여부**: verified **true**
- **현재 정답 인덱스**: **0** (`서버리스는 온디맨드이고 실시간은 프로비저닝이다`) — **정답은 불변**
- **결함**: `wrongExplanations["3"]` 이 「실시간 엔드포인트는 **최소 인스턴스가 1 이상이어야 하고** 유휴 시간에도 인스턴스 요금이 듭니다. 온디맨드로 묶을 수 없습니다.」로 한정 없이 단정한다. `explanation` 끝 문장도 「이 차이가 **0대까지 줄어드는지**와 스케일링 정책이 필요한지를 갈라 놓습니다」로 같은 전제를 쓴다. 추론 컴포넌트를 호스팅하는 실시간 엔드포인트는 0대까지 줄어든다.
- **같은 Task 가 스스로 반박한다**: `mla-t3-2-q9`(정답 0)가 「추론 컴포넌트를 호스팅하는 엔드포인트를 인스턴스 0대까지 줄여 두었다」를 가르치고, `mla-t3-2-q13` `W1` 과 `mla-t3-1-q9` `W2` 는 **「일반 프로덕션 변형의」**로 올바르게 한정한다. 학습문서도 옳다(`mla-t3-2.md:62` 「일반 실시간 변형은 최소 1대」 · `mla-t3-1.md` 요약 「실시간은 추론 컴포넌트를 호스팅할 때만 0. 일반 변형은 최소 1」). → **md 는 옳고 문항만 거친 역방향 잔존.**
- **공식 근거**: `https://docs.aws.amazon.com/sagemaker/latest/dg/endpoint-auto-scaling-zero-instances.html` (200 r=0 · 6,849자) — "It hosts one or more inference components. **An endpoint can scale to and from zero instances only if it hosts inference components.**"
- **수정안** (보기·정답 불변):
  - `W3` → 「추론 컴포넌트를 쓰지 않는 **일반 프로덕션 변형**은 최소 인스턴스가 1 이상이어야 하고 유휴 시간에도 인스턴스 요금이 듭니다(0대까지 줄일 수 있는 것은 추론 컴포넌트를 호스팅하는 엔드포인트뿐입니다). 온디맨드로 묶을 수 없습니다.」
  - `explanation` 끝 문장 → 「이 차이가 **스케일링 정책이 필요한지**와, 일반 변형이 유휴 시간에도 최소 1대를 유지하는지를 갈라 놓습니다.」
- **전수**: `최소 인스턴스가 1|최소 용량은 1|1 이상이어야` — MLA 문항 **3자리**(한정 없는 것은 이 **1자리**뿐) · md 0자리(md 는 다른 문구로 옳게 적는다).

---

## 2. 🟡

### 2-A. 정답 유일성·지문 조건 (4문항)

#### mla-t4-3-q22 — S3 인터페이스 엔드포인트도 공식 수단이라 보기 1을 거짓으로 만드는 문장이 없다

- **공개 여부**: true · **정답 인덱스**: **0** (`S3 게이트웨이 엔드포인트를 만들어 라우트 테이블에 연결한다`)
- **결함**: 지문은 「인터넷이 없는 사설 서브넷의 훈련 작업이 S3 데이터를 가져오지 못한다. 어떤 엔드포인트를 어떻게 구성하는가?」뿐이고, 보기 1(`S3 인터페이스 엔드포인트를 만들고 사설 DNS를 켠다`)의 오답 근거는 「**문서가 S3에 안내하는 것은** 게이트웨이 엔드포인트입니다. 라우트 테이블 연결이 핵심입니다.」 — 보기가 왜 틀렸는지 말하지 않는 **회피형 반박**이다.
- **공식 근거**: `https://docs.aws.amazon.com/AmazonS3/latest/userguide/privatelink-interface-endpoints.html` (200 r=0 · 33,429자) — "**You can use two types of VPC endpoints to access Amazon S3: gateway endpoints and interface endpoints** (by using AWS PrivateLink)." · "With private DNS names enabled, Regional S3 DNS queries resolve to the private IP addresses of AWS PrivateLink" · "...by using gateway endpoints, **which are not billed**, for your in-VPC traffic." SageMaker 쪽 `train-vpc.html` 은 게이트웨이 구성 절차만 적고 **인터페이스 엔드포인트가 안 된다고 적지 않는다**(`train-vpc.html` 에서 `Gateway` 4건 · 인터페이스 금지 문장 0건).
- **왜 🔴 가 아닌가**: 「SageMaker 훈련 작업의 S3 다운로드가 S3 인터페이스 엔드포인트로도 된다」고 적은 SageMaker 문장을 찾지 못했다. S3 문서의 일반 서술에서 따라오는 추론이라 🟡 로 둔다.
- **수정안**: 지문에 가름 조건을 넣는다 — 「…가져오지 못한다. **추가 요금 없이** SageMaker 문서가 안내하는 대로 구성하려면 어떤 엔드포인트를 어떻게 만드는가?」. `W1` → 「S3 인터페이스 엔드포인트도 S3에 닿는 공식 수단이지만 시간·데이터 처리 요금이 붙습니다. 추가 요금이 없고 SageMaker 문서가 안내하는 것은 라우트 테이블에 연결하는 게이트웨이 엔드포인트입니다.」
- **전수(같은 주장)**: 학습문서 `mla-t4-3.md:539` 「**S3는 게이트웨이, SageMaker API·Runtime은 인터페이스 엔드포인트.** 둘을 바꿔 고르면 틀립니다」 **1자리**(단정) · `:90` 요약 줄 1자리(「S3는 게이트웨이 엔드포인트(라우트 테이블 연결, 추가 요금 없음)」— 이쪽은 참인 서술). → `:539` 는 「SageMaker 문서가 S3에 안내하는 것은 게이트웨이(추가 요금 없음)이고, S3 자체는 인터페이스 엔드포인트도 지원한다」로 완화 권고. §5-3 참조(SAA 는 같은 단정을 2026-10-28에 이미 고쳤다).

#### mla-t3-1-q22 — Lambda 타임아웃 「상한 900초」에 Managed Instances 예외가 빠졌다

- **공개 여부**: true · **정답 인덱스**: **0** (`이미지 크기와 타임아웃 한도를 둘 다 넘어 Lambda로는 불가하다`)
- **결함**: `explanation` 「함수 타임아웃 상한은 900초, 즉 15분입니다」와 `W2` 「상한이 900초여서 20분이 걸리는 처리는 완료되기 전에 중단됩니다」가 한정 없이 단정한다. 보기 2(`타임아웃은 괜찮지만 이미지 크기 한도를 넘어 불가하다`)가 Managed Instances 비동기 호출에서는 참에 가까워진다. 결론(Lambda 불가)은 이미지 10 GB 한도 때문에 그대로다.
- **공식 근거**: `https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-limits.html` (200 r=0 · 17,667자) — "Function timeout: 900 seconds (15 minutes). **For functions using AWS Lambda Managed Instances, asynchronous invocations and event source mapping invocations (except Amazon MQ and Amazon DocumentDB)**…" · "Code can run for up to 15 minutes in a single invocation (**up to 90 minutes for Lambda Managed Instances functions invoked asynchronously or through any event source mapping** except Amazon MQ and Amazon DocumentDB)" · "Container image code package size: 10 GB (maximum uncompressed image size, including all layers)".
- **수정안**: 지문을 「…**표준(온디맨드) AWS Lambda 함수**에 올리려 한다」로 한정하고, 해설에 한 줄을 더한다 — 「(Lambda Managed Instances 함수의 비동기·이벤트 소스 매핑 호출은 최대 90분이지만, 이 시나리오는 이미지 크기 한도에서 이미 걸립니다.)」. `W2` 는 「표준 Lambda 함수의 상한이 900초여서…」.
- **전수**: MLA 에서 Lambda 타임아웃을 단정하는 자리 — 문항 **1개**(이 문항의 해설 + `W2`) · md **1자리**(`mla-t3-1.md:358` 표 「타임아웃 **900초(15분)**」). `Managed Instances` 예외를 적은 자리 **0**.

#### mla-t4-2-q32 — 지문이 「정책이 어떤 지표를 쓰는지」를 말하지 않는다

- **공개 여부**: true · **정답 인덱스**: **0** (`스케일링 지표를 InvocationsPerInstance로 바꾼다`)
- **결함**: 지문은 「트래픽이 줄었는데 실시간 엔드포인트의 인스턴스가 줄어들지 않는다. 가장 먼저 점검할 것은?」인데 해설의 근거는 「**CPU 활용률 기반 정책은** 트래픽이 줄어도 스케일 다운하지 않을 수 있습니다」다. 지문에 「정책이 CPU 활용률을 쓴다」가 없어, 이미 인스턴스당 호출 수를 쓰는 정책이라면 정답이 성립하지 않는다. 또 「점검할 것」을 물으면서 정답은 「바꾼다」(조치)다.
- **출처 등급**: 이 주장의 1차 근거가 `repost.aws/knowledge-center/sagemaker-endpoints-scaling-issues` 뿐이다(AWS 문서 검색으로 재확인: "A policy that scales based on the CPU utilization metric might not scale down when traffic decreases" 는 이 re:Post 글에만 있다). 둘째 출처 `endpoint-auto-scaling-add-code-define.html` 에는 그 문장이 없다(`scale.?in|scale down` 3건은 쿨다운 파라미터 설명).
- **수정안**: 지문에 조건을 넣는다 — 「…인스턴스가 줄어들지 않는다. **대상 추적 정책은 사용자 지정 지표 `CPUUtilization` 을 쓰고 있다.** 가장 먼저 검토할 조치는?」. ⚠️ 근거가 re:Post 하나라는 점은 그대로 남는다 — **공식 docs 에서는 확인되지 않았다**(§6-4). 유지·교체는 사람 판정.

#### mla-t2-1-q18 — 정답의 근거가 인용 페이지에 없고, 오답 근거가 지문에 없는 가정에 기댄다

- **공개 여부**: true · **정답 인덱스**: **1** (`SageMaker 엔드포인트로 자체 모델을 호스팅하는 쪽과 비교한다`)
- **결함 ①(출처)**: 지문은 「관리형 이미지 분석 API」의 비용을 묻는데 첫 출처는 **SageMaker Canvas 과금 페이지**다. 그 페이지가 적는 것은 Canvas 안에서 Ready-to-use 모델은 기반 서비스 요금, 사용자 지정 모델은 리소스 사용량으로 과금된다는 것뿐이고(`canvas-manage-cost.html` 200 r=0 · 5,500자 — `Ready-to-use` 4건), **「건수가 늘면 자체 호스팅과 비교하라」·「호출당 과금은 소량·변동 수요에 유리」는 어느 인용 페이지에도 없다**(저작자의 추론이다).
- **결함 ②(오답 근거)**: `W3` 「캐시는 같은 이미지를 반복 분석할 때 효과가 있습니다. **새로 들어오는 사진이 대부분이면** 절감 폭이 작습니다」— 지문에 「새 사진이 대부분」이라는 조건이 없다. 보기 3(`결과를 캐시해 같은 이미지를 다시 분석하지 않는다`)은 그 자체로 유효한 비용 조치다.
- **수정안**: 🟡 `rewrite` 후보. 가장 작은 수정은 지문을 인용 페이지가 실제로 적는 사실로 좁히는 것이다 — 「SageMaker Canvas 에서 Ready-to-use 모델과 사용자 지정 모델의 과금 기준은 각각 무엇인가」(정답: 기반 AI 서비스 요금 / 예측에 쓴 리소스). 현 지문을 유지하려면 지문에 「이미지는 전부 새 사진이고 요청은 이미 건별로 보낸다」를 넣어 보기 2·3을 지문 안에서 배제해야 한다. **어느 쪽인지는 사람 판정.**

### 2-B. 「URL 은 200인데 그 페이지에 그 사실이 없다」 (8문항)

전부 **사실은 옳고 인용 페이지만 틀렸다.** 정답 인덱스·본문 불변, 출처 교체만 필요하다. ⚠️ 교체 URL 은 **같은 Task 학습문서의 출처 목록에도** 있어야 한다(문항 가드는 `.md` 를 보지 않는다) — 표의 마지막 열이 그 상태다.

| 문항 | 정답 | 문항이 단정하는 것 | 현재 출처(실측) | 그 사실이 실제로 있는 페이지 (`curl -sL` 실측) | 같은 Task md 에 있나 |
|---|---|---|---|---|---|
| `mla-t1-3-q8` | **1** | 「주석자·심사자가 무의식적으로 편향을 주입하는 것이 레이블 편향」+ 선택·알고리즘·측정 편향의 정의 | `mlrel03-bp04.html` — 편향 유형을 **이름만** 든다: "selection bias, measurement bias, aggregation bias, and evaluation bias". `label bias`·`recall bias`·`algorithm` **0건** | `https://aws.amazon.com/what-is/ai-bias/` (200 r=0 · 15,123자) — "Label AI bias is when a data annotator unconsciously introduces bias into the data labeling process." | ❌ **`mla-t1-3.md` 출처에 없다**(본문 `:162` 표가 이 정의를 쓴다) |
| `mla-t1-3-q24` | **2** | 선택 편향 정의(「무작위 샘플링을 쓰지 않거나…」) · 회상 편향 정의 | 같은 `mlrel03-bp04.html` | 같은 `what-is/ai-bias/` — "Selection AI bias occurs when the overall dataset scientists collect does not represent the general population directly. This form of bias occurs when researchers do not use random sampling methods…" · "Recall bias occurs when a model's ability to identify a specific class correctly is influenced by the uneven representation or attention given to that class during the training process." | ❌ 위와 같음 |
| `mla-t2-2-q3` | **1** | 「노드를 늘리면 배치 크기를 비례해 늘리고 학습률도 올린다 … 선형 스케일링 규칙」 | `distributed-training-strategies.html` (5,303자) — `learning rate` **0** · `proportion` **0** (대조군 `batch size` 8 · `model parallel` 6) | `https://docs.aws.amazon.com/sagemaker/latest/dg/data-parallel-config.html` (200 r=0 · 7,003자) — "as more nodes are added, batch sizes should increase proportionally. To improve convergence speed … increase the learning rate. … Linear Scaling Rule where each time the mini-batch size is multiplied by k, the learning rate is also multiplied by k." | ✅ (`mla-t2-2.md` 참고자료에 이미 있다) |
| `mla-t2-3-q11` | **1** | 「학습에 쓴 데이터로 재면 일반화가 아니라 **암기를 보상**」 | `mlperf04-bp02.html` — `generaliz|remember|training data|holdout|unseen` **0** · `autopilot-metrics-validation.html` — `memoriz|remember|generaliz` **0** | `https://docs.aws.amazon.com/machine-learning/latest/dg/evaluating_models.html` (200 r=0 · 5,040자 · ⚠️ **갱신 중단된 구서비스 Amazon ML 문서**) — "Evaluating the predictive accuracy of an ML model with the same data that was used for training is not useful, because it **rewards models that can "remember" the training data, as opposed to generalizing from it.**" | ❌ `mla-t2-3.md` 에 없다. 달 때는 `mla-t2-3-q12` 처럼 「보조 출처(Amazon Machine Learning, 신규 사용자 중단된 구서비스 문서)」 라벨을 붙인다 |
| `mla-t3-2-q5` | **0** | 「SageMaker 가 `SageMakerVariantInvocationsPerInstance` 를 **강력히 권장**」 | `endpoint-auto-scaling-policy.html` — `strongly recommend` **0** · `target-tracking-scaling-policy-overview.html` — `SageMakerVariantInvocationsPerInstance` **0** | `https://docs.aws.amazon.com/sagemaker/latest/dg/multi-model-endpoints-autoscaling.html` (200 r=0 · 6,484자) — "`SageMakerVariantInvocationsPerInstance` is the average number of times per minute that each instance for a variant is invoked. **We strongly recommend using this metric.**" (조사 노트 `3-2.md` F15 도 이 URL 을 적는다) | ❌ `mla-t3-2.md` 에 없다 |
| `mla-t3-3-q15` | **0** | 「의존성이 없는 단계는 실행 즉시 시작되어 병렬로 돌며 … 순서만 강제하려면 `DependsOn`」·`ParallelismConfiguration` | `pipelines-overview.html` (3,146자) — `Depends` **0** · `parallel` **0** (대조군 `data dependenc` 3) · `pipelines.html` — 0 | `https://docs.aws.amazon.com/sagemaker/latest/dg/build-and-manage-steps.html` (200 r=0 · 6,234자) — "When a step does not depend on any other step, it runs immediately upon pipeline execution. … Control the number of concurrent steps … with `ParallelismConfiguration`." · "You create a custom dependency by specifying a step's `DependsOn` attribute." | ❌ `mla-t3-3.md` 에 없다(`build-and-manage-steps-types.html` 만 있다 — 다른 페이지다) |
| `mla-t3-3-q16` | **0** | 위와 같은 사실(출처 제목이 「Pipelines overview — 데이터 의존성과 병렬 실행, DependsOn」) | `pipelines-overview.html` — 위와 같음 | 같은 `build-and-manage-steps.html` | ❌ 위와 같음 |
| `mla-t3-3-q24` | **0** | 「성능·데이터 패턴과 무관한 고정 일정 재훈련은 안티패턴」(첫 출처 제목 「Machine Learning Lens — 재훈련 프레임워크와 안티패턴」) | `mlops04-bp01.html`(MLOps·CI/CD BP) — `schedule` **0**, 안티패턴 목록은 수동 배포·버전 미관리 쪽이다. 둘째 출처 `mlsus06-bp02.html` 에는 있다("Retraining models on a fixed schedule regardless of performance.") | `https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/mlperf06-bp05.html` (200 r=0 · 8,298자) — 안티패턴 "**Retraining on a fixed schedule regardless of model performance or data patterns.**"(문항 해설의 문구와 글자 단위로 대응) · "automated model re-training at scheduled intervals or when performance metrics reach defined thresholds" | ❌ `mla-t3-3.md` 에 없다(`mla-t4-1` 쪽에만 있다) |

- **수정안 공통**: 틀린 출처 항목을 표의 정본 URL 로 **교체**(제목도 그 페이지 `h1` 에 맞춘다). `mla-t3-3-q24` 는 첫 출처만 교체하고 둘째(`mlsus06-bp02`)는 유지. ❌ 표시된 5개 URL 은 해당 `.md` 의 프런트매터 `sources:` 와 본문 참고자료 목록에 **함께** 추가한다(프런트매터에는 `lastVerified:` **앞**에 넣는다).
- ⚠️ `mla-t3-3-q24` 해설의 「재훈련 조건을 일정 주기, 임계 이하 성능 저하, 데이터 드리프트, 신규 훈련 데이터로 정의」 네 항목 묶음은 `mlperf06-bp05` 에서 「일정 주기·성능 임계」 둘까지만 확인했다. 나머지 둘의 출처는 2단계가 `mlsus06-bp02` 본문에서 확인할 것(이 보고서는 단정하지 않는다).
- **전수**: 위 8문항이 이번 전수 대조에서 확정한 전부다. 수치·식별자 토큰 대조에서 걸린 나머지는 §3-8(오답 근거의 세부 수치가 다른 페이지에 있는 🟢 급)과 정상(시나리오 수치·약어)이었다.

### 2-C. 공식 근거가 다른 층에 있거나 공식과 어긋나는 귀속 (2문항)

#### mla-t4-3-q8 — 「대표 기간 30일에서 90일」은 공식 권고가 아니다 (2026-11-06 2차 패스 N4 — **미반영 잔존**)

- **공개 여부**: true · **정답 인덱스**: **0**
- **결함**: `explanation` 「**권장 흐름은** 넓은 정책으로 대표 기간 30일에서 90일 운영한 뒤 생성된 정책으로 교체하는 것입니다」. 공식은 상한 90일과 「가능한 한 짧게」를 적는다.
- **공식 근거**: `https://docs.aws.amazon.com/IAM/latest/UserGuide/access-analyzer-policy-generation.html` (200 r=0 · 23,258자) — "You can choose a range of up to 90 days. **We recommend that you choose the shortest time period possible** to reduce the policy generation time." · `30 days` **0건** · `representative` **0건** (대조군 `90 days` 2 · `broad` 2).
- **수정안**: 해설 끝 문장 → 「분석 기간은 최대 90일까지 고를 수 있고 공식은 정책 생성 시간을 줄이도록 **가능한 한 짧은 기간**을 권합니다. 넓은 정책을 생성된 정책으로 교체해 권한을 좁힙니다.」
- **전수**: `30~90일|30일에서 90일|대표 기간` — 문항 **1** · md **1**(`mla-t4-3.md:197` 「넓은 정책으로 **대표 기간 30~90일** 워크로드를 돌린 뒤…」). 둘 다 고친다.

#### mla-t4-2-q33 — 「Savings Plans 전에 먼저 적정 규모 조정」은 SageMaker 문서에 없다(블로그에만 있다)

- **공개 여부**: true · **정답 인덱스**: **0** (`인스턴스를 먼저 적정 규모로 조정한다`)
- **결함**: 지문 「**SageMaker 추론 비용 최적화 모범 사례에서** 약정 할인을 구매하기 전에 해야 할 일로 제시된 것」, 해설 「**문서가 제시하는 순서는**…」. 첫 출처 `inference-cost-optimization.html` (5,990자)에는 `right.?siz` **0건** · `before` **0건**(대조군 `Savings Plans` 2 · `64` 1). 그 문장은 둘째 출처인 **AWS 블로그**에만 있다 — "You should right-size the SageMaker compute instances before purchasing a Savings Plan".
- **공식 확인**: AWS 문서 검색(`right-size instances before purchasing Savings Plans SageMaker`)으로도 docs 에서는 못 찾았다(1위가 그 블로그, 3위가 위 SageMaker 페이지). → **공식 docs 에서는 확인되지 않았다**(§6-4).
- **수정안**: 계약 §3-7 에 따라 사실 수정안은 내지 않는다. 선택지는 둘이고 사람 판정이다 — ⓐ 귀속만 정직하게 고친다(지문 「AWS 기계 학습 블로그가 SageMaker 비용 최적화 순서로 제시하는 것은」, 해설 「문서가」→「블로그가」) ⓑ 문항을 `inference-cost-optimization.html` 이 실제로 적는 사실로 교체한다.
- **전수**: 같은 주장 md **1자리** — `mla-t4-2.md` 자가 점검 Q7 정답 끝 「순서상 **약정 전에 right-size**가 먼저입니다」(조사 노트 `4-2.md` 는 이 사실을 〔S88〕 블로그로 정확히 적어 뒀다 — 문항으로 옮겨지며 귀속이 「문서」로 바뀌었다).

### 2-D. 닫힌 서비스 상태 표기 누락 (7문항)

상태 표기가 **달린 자리**부터 적는다(전부 정상이다):

| 서비스 (공식 상태) | 상태가 달린 문항 (가르치는 층) |
|---|---|
| Model Monitor (Maintenance · 2026-07-30부터 신규 불가) | `t2-3-q10` · `t4-1-q1·q2·q4·q5·q6·q7·q8·q9·q14·q15·q16·q29` = **13** (`mla_questions_test` 의 `mmTaughtIds` 와 일치) |
| Clarify (Maintenance) | `t2-3-q17·q18·q19·q21·q22` · `t4-1-q19·q20·q21` = **8** · `t2-3-q27` 은 지문 자체가 상태를 전제 |
| Ground Truth · A2I · Mechanical Turk | `t1-2-q18`(Ground Truth + MTurk) · `t1-2-q19`(A2I) |
| Role Manager | `t4-3-q11`(상태 자체를 묻는다) |
| Kendra · Q Business · Edge Manager · Elastic Inference · K8s Operators 원 버전 · Profiler · KDA for SQL · CloudTrail Lake | `t2-1-q5` · `t3-1-q20` · `t3-1-q16` · `t3-1-q23` · `t4-2-q34` · `t1-1-q10` · `t4-2-q18` |

공식 근거는 전부 오늘 받은 Lifecycle 세 페이지와 각 가용성 변경 페이지에서 재확인했다(`aws.amazon.com/sagemaker/ai/features/` End of Support Notice: "…(Mechanical Turk, Ground Truth, Augmented AI, Studio Lab, Model Monitor, Clarify, Debugger, Role Manager, Geospatial, and Profiler) will no longer be open to new customers starting on **July 30, 2026**" · `cloudtrail-lake-service-availability-change.html`: "…starting on **May 31, 2026**" · full shutdown 목록: `Amazon Mechanical Turk | September 29, 2026`). **날짜가 틀린 자리는 0건이다.**

**누락 7문항** — 닫힌 기능을 **현재 쓸 수 있는 해법으로 가르치면서** 상태가 없다:

| 문항 | 정답 | 가르치는 것 | 왜 누락인가 |
|---|---|---|---|
| `mla-t2-3-q14` | **1** | 「해당 Debugger 규칙은 무엇인가」→ `vanishing_gradient` | Debugger 는 Maintenance("Amazon SageMaker Debugger is no longer open to new customers" — 인용 페이지 `debugger-built-in-rules.html` **자신의 첫머리 Note**). 같은 Task 의 `q16`·`mla-t2-3.md` 는 상태를 적는다 |
| `mla-t2-3-q15` | **1** | Debugger 내장 규칙 최대 20개 · 추가 비용 없음 | 위와 같음. 이 문항은 2026-11-06 중복 해소 때 **새로 쓴 본문**인데 상태가 빠졌다 |
| `mla-t4-1-q12` | **0** | `baseline_drift_check` · `comparison_threshold` | Model Monitor 제약 위반 스키마(출처 `model-monitor-interpreting-violations.html`). 본문에 「Model Monitor」 **문자열이 없어서** `mmTaughtIds` 선정에서 빠졌다 |
| `mla-t4-1-q13` | **0** | `categorical_values_check` · `domain_content_threshold` | 위와 같음 |
| `mla-t4-1-q17` | **0** | 모델 품질 스케줄의 `StartTimeOffset`·`EndTimeOffset` | 출처 `model-monitor-model-quality-schedule.html`. 문자열 없음 |
| `mla-t4-1-q18` | **0** | 정답 라벨 병합(`inferenceId`·`eventId`) | 출처 `model-monitor-model-quality-merge.html`. 문자열 없음 |
| `mla-t4-3-q10` | **0** | Role Manager 페르소나 세 가지 | 「제공**하던**」·「제공**했습니다**」 과거형만 있고 상태가 없다 — Role Manager 는 종료가 아니라 Maintenance 라 **기존 고객은 지금도 쓴다**. 과거형이 「사라졌다」로 읽힌다 |

- **원인**: 2026-10-27 의 Model Monitor 13문항 선정이 「문항 JSON 어디에든 **`Model Monitor` 문자열**이 나오는 23건」을 모집단으로 삼았다. 같은 기능을 문자열 없이 가르치는 4문항(`t4-1-q9` 는 달렸는데 같은 층인 `q12·q13·q17·q18` 은 안 달렸다)이 그 모집단 밖에 있었다. 리터럴 탐지는 자기가 본 문자열만 안다.
- ⚠️ `mla-t4-1-q10`·`q11`(데이터 캡처)은 **대상이 아니다** — 「데이터 캡처는 Model Monitor 없이도 쓰는 독립 기능」이라는 기존 판정이 가드 주석에 있고, `q5` 해설도 그렇게 가르친다. 그 판정을 뒤집지 않는다.
- **수정안**: 각 `explanation` 끝에 기존 정본 문구를 그대로 붙인다(문구를 새로 만들지 않는다).
  - `t2-3-q14`·`q15` → 「⚠️ SageMaker Debugger는 신규 고객에게 닫혀 있습니다(기존 고객은 계속 사용).」 (`t4-2-q34` 가 「Debugger도 신규 고객에게 닫혀 있습니다」로 이미 적는다)
  - `t4-1-q12·q13·q17·q18` → 「⚠️ Model Monitor는 현재 신규 고객을 받지 않습니다(기존 고객은 사용 가능).」 + `mla_questions_test.dart` 의 `mmTaughtIds` 13 → **17**
  - `t4-3-q10` → 「⚠️ Role Manager는 신규 고객에게 닫혀 있습니다(기존 고객은 계속 사용).」 그리고 과거형 「제공하던·제공했습니다」를 현재형으로.
- **확신도**: Debugger 2건·Role Manager 1건은 높다(루브릭 §2 「가이드에 남아 있어도 신규 고객이 쓸 수 없는 기능은 상태를 명시한다 … 같은 기능의 상태를 두 문항이 다르게 적으면 그것만으로 결함」). Model Monitor 4건은 **정책 결정이 하나 필요하다** — 「문자열이 나올 때만 단다」를 유지하겠다면 그 기준을 가드 주석에 적고 이 4건을 명시 제외로 고정해야 한다. 어느 쪽이든 지금처럼 기준이 암묵적인 상태는 닫아야 한다.

### 2-E. 불완전한 수치 (1문항)

#### mla-t4-2-q11 — Logs Insights 「계정당 동시 쿼리 100개」는 QL 한정이다

- **공개 여부**: true · **정답 인덱스**: **0** — 정답 보기(결과 7일 · 스캔량 과금)는 옳다
- **결함**: `explanation` 「계정당 동시 쿼리 100개 … 쿼리 언어는 Logs Insights QL과 OpenSearch PPL, OpenSearch SQL 세 가지를 지원」 — 세 언어를 나란히 들면서 한도는 하나만 적어 PPL·SQL 에도 100이 적용되는 것처럼 읽힌다.
- **공식 근거**: `https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/AnalyzingLogData.html` (200 r=0 · 7,178자 — 이 문항의 첫 출처다) — "You are limited to **100 concurrent CloudWatch Logs Insights QL** per account, including queries added to dashboards. **Additionally, you can run 15 concurrent queries for either OpenSearch Service PPL or OpenSearch Service SQL.**"
- **수정안**: 「동시 실행은 Logs Insights QL 이 계정당 100개(대시보드 쿼리 포함)이고 PPL·SQL 은 각 15개」. 둘째 출처 제목 「StartQuery API — 계정당 동시 쿼리 100개」도 「…Logs Insights 동시 쿼리」로.
- **전수**: 문항 **1**(해설 + 출처 제목) · md **1**(`mla-t4-2.md:193` 표 「계정당 **동시 쿼리 100개**」). §5-2(AIP·DVA·SCS 는 이미 「QL 100 / PPL·SQL 각 15」로 적는다) · §6-2(공식 API 레퍼런스는 100만 적는다).

### 2-F. 블로그 단독 출처 (1문항)

#### mla-t4-1-q3 — 유일한 출처가 AWS 블로그다

- **공개 여부**: true · **정답 인덱스**: **0**
- **내용**: 지문이 「**AWS 블로그가** 데이터 드리프트를 세분화한 세 가지 용어 중 공변량 이동의 정의는」으로 귀속을 정직하게 밝힌다. 블로그 본문과 문항은 일치한다(실측: "In a covariate shift, the distribution of inputs changes over time, but the conditional distribution P(y|x) d[oesn't change]" · `W1` 의 예시도 원문 그대로 — "if the spam to non-spam ratio of emails in our training set is 50%, but in reality, 10% of our emails are non-spam").
- **결함**: 사실 오류가 아니라 **출처 등급**이다. 루브릭 C4 는 「블로그·re:Post 는 보조 근거로만」인데 이 문항은 `docs.aws.amazon.com` 출처가 **0개**인 유일한 블로그 단독 문항이다(전수: docs 출처가 없는 문항 4개 — 이 문항과, `what-is` + 구 Amazon ML 조합인 `t2-2-q15`·`t2-2-q25`·`t2-3-q12`). 공식 ML Lens 가 정의하는 드리프트는 **데이터 드리프트·개념 드리프트 둘**이다(`mlperf06-bp04.html`: "data drift (changes in the distribution of input data) or concept drift (changes in the relationship between inputs and target variables)").
- **수정안**: 사람 판정 — ⓐ 유지(귀속이 정직하므로) ⓑ 공식 2분류를 묻는 문항으로 교체. ⓑ를 고르면 `mla-t4-1-q1`·`q2` 와 겹치지 않는 각도여야 한다.

---

## 3. 🟢 (품질 — 사실은 옳다)

### 3-1. 중복·겹침

`prescreen` 은 Task 내 중복 후보 **0쌍**을 냈다. 지표는 하한이었다 — 아래 **교차 Task 실중복 7쌍**은 본문을 읽어 확정했고, 그중 4쌍은 조사를 벗긴 자카드로도 0.2 이하다.

**(a) 교차 Task 실중복 — 같은 사실 · 같은 정답 (7쌍, 전부 라이브)**

| # | 쌍 (정답 인덱스) | 같은 사실 | 정답 자카드 원형/조사벗김 | 출처 공유 |
|---|---|---|---|---|
| ① | `t1-3-q12`(0) ↔ `t4-3-q18`(0) | 분산 훈련 노드 간 암호화 = `EnableInterContainerTrafficEncryption` + UDP 500·ESP 50. 지문까지 거의 같다(「규정상 … 노드 간 통신을 암호화해야 한다」) | 0.200 / **0.385** | ✅ |
| ② | `t4-2-q15`(0) ↔ `t4-3-q32`(0) | `InvokeEndpoint` 는 데이터 이벤트라 기본 미기록·이벤트 기록에도 없음. 해설 첫 문장이 **글자 그대로 같다** | 0.308 / **0.417** | ✅ |
| ③ | `t3-3-q24`(0) ↔ `t4-1-q28`(0) | 고정 일정 재훈련은 ML Lens 안티패턴(월요일 vs 일요일만 다르다) | 0.095 / **0.167** | ❌ |
| ④ | `t1-3-q11`(1) ↔ `t4-3-q16`(0) | 교차 계정 출력 버킷 → AWS 관리형 키는 키 정책을 편집할 수 없어 불가, 고객 관리형 키 | 0.043 / **0.043** | ✅ |
| ⑤ | `t2-2-q27`(3) ↔ `t3-2-q19`(0) | 훈련 스크립트의 모델 저장 경로 `/opt/ml/model` | 0.375 / 0.375 | ❌ |
| ⑥ | `t1-3-q4`(1) ↔ `t2-3-q17`(0) | 사전 편향 지표는 모델 출력에 의존하지 않는다(사후는 예측 필요) | 0.200 / 0.200 | ❌ |
| ⑦ | `t3-2-q12`(0) ↔ `t4-2-q29`(0) | Savings Plans 는 가격 약정이고 용량을 보장하지 않는다 → 용량은 훈련 플랜 | 0.000 / **0.059** | ✅ |

⚠️ ④·⑦은 **자카드 0.06 이하**다 — 「출처 공유 + 정답 자카드 ≥ 0.33」 재발 가드(`mla_duplicate_fix_test`)로는 영원히 안 잡힌다. ③은 계약이 예로 든 「0.167 이 실중복」과 같은 값이다.

- **수정안**: 정답 인덱스를 유지한 본문 교체(2026-11-06 3쌍 해소와 같은 방식). 어느 쪽을 남길지는 **그 사실을 소유하는 Task** 로 가른다 — 권고: ① 4.3(SK5 격리·K2 암호화)이 소유 → `t1-3-q12` 교체 / ② 4.2(SK2 CloudTrail 추적)가 소유 → `t4-3-q32` 교체 / ③ 3.3(SK6 재훈련 메커니즘)이 소유 → `t4-1-q28` 교체(단 `t4-1` K3 「모니터링 관련 ML 렌즈 설계 원칙」 문항이 `q27`·`q28` 둘뿐이라 **같은 K3 로 다시 써야 한다**) / ④ 1.3(K3 암호화)과 4.3(SK1 아티팩트 최소 권한) 중 4.3 이 소유 → `t1-3-q11` 교체 / ⑤ 2.2(SK2 스크립트 모드)가 소유 → `t3-2-q19` 를 「`/opt/ml` 이하는 예약 경로」만 묻게 좁힘 / ⑥ 1.3(K1)이 소유 → `t2-3-q17` 교체 / ⑦ 4.2(SK10 구매 옵션)가 소유 → `t3-2-q12` 교체.
- ⚠️ **교체 전에 그 문항 id 를 직접 참조하는 가드를 먼저 센다** — `t2-3-q17` 은 Clarify 상태 가드(`mla_aif_p2_review_fix_test`)의 대상이고, `t4-3-q18` 은 `prescreen` length-cue 대상이다.

**(b) 같은 Task 안 겹침·정답 누출 (9쌍)** — 한 문항의 해설·오답 근거가 다른 문항의 정답을 그대로 말한다.

| 쌍 | 겹치는 방식 |
|---|---|
| `t1-1-q7`(0) ↔ `t1-1-q19`(0) | `q7` 의 `W1` 이 「ONTAP 볼륨에 S3 access point를 붙여 S3 호환 경로로 읽는 방식이 문서화돼 있으므로」— `q19` 의 정답 그대로다 |
| `t1-3-q16`(0) ↔ `t1-3-q23`(0) | `q16` 의 `W1` 「IAM 태그와 LF-Tags는 다르고 서로 바꿔 쓸 수 없습니다」= `q23` 의 정답 |
| `t1-3-q7`(0) ↔ `t1-3-q22`(1) | 둘 다 「증강은 원본과 같은 편향을 만든다 → 원본 편향부터」(조사벗김 0.312 · 출처 공유) |
| `t2-3-q3`(1) ↔ `t2-3-q7`(1) | 둘 다 「AUPRC 는 참 음성을 고려하지 않아 양성이 드문 데이터에 맞는다」. `q3` 해설이 `q7` 정답을 말한다 |
| `t3-3-q3`(0) ↔ `t3-3-q22`(0) | `q3` 해설이 「SageMaker 엔드포인트는 이 목록에 없고 … 배포 가드레일이 담당」= `q22` 의 정답 |
| `t3-2-q3`(0) ↔ `t3-2-q9`(0) | 「0대에서 깨우려면 단계 스케일링」(`q3`)이 `q9` 정답의 절반이다 |
| `t4-3-q13`(0) ↔ `t4-3-q21`(0) | `q13` 해설이 `AppNetworkAccessType` 기본값 `PublicInternetOnly`·`VpcOnly` 동작을 말한다 = `q21` 정답의 앞 절반 |
| `t4-2-q24`(0) ↔ `t4-2-q25`(0) | `q24` 정답 「Budgets 는 임계값으로 알림과 작업을 건다」가 `q25` 정답의 핵심 |
| `t4-1-q2`(0) ↔ `t4-1-q8`(0) | 둘 다 「모델 품질 모니터링은 정답 라벨을 쓴다」에 걸린다 |

**(c) 교차 Task 겹침 (4묶음, 같은 문서 표를 나눠 묻는다)** — `t2-2-q23` ↔ `t3-1-q12` ↔ `t3-3-q18`(Model Registry 승인 전이 네 줄을 세 문항이 나눠 묻는다) · `t3-1-q6` ↔ `t3-2-q3`(0대 → 단계 스케일링, 조사벗김 **0.500** 이지만 비동기 지표 vs 일반 규칙이라 겹침으로 본다) · `t2-2-q12` ↔ `t3-1-q15`(XGBoost / LightGBM 「메모리 바운드 → 범용 인스턴스」, 지문 자카드 0.389) · `t2-3-q23` ↔ `t4-1-q26`(섀도 테스트는 프로덕션 응답만 반환).

- **(b)(c) 수정안**: 누출하는 쪽의 해설·오답 근거에서 **상대 문항의 정답 문장을 걷는다**(문항 교체는 불필요). 예: `t1-1-q7` `W1` → 「학습 잡이 직접 마운트하는 소스 목록(S3·EFS·FSx for Lustre)에 ONTAP 은 없습니다. 여기서는 이미 EFS 에 있는 데이터를 굳이 옮길 이유가 없습니다.」
- **전수 기록**: 정답 자카드(원형·조사벗김 중 큰 값) ≥ 0.33 **11쌍**(같은 Task 2) · ≥ 0.25 **25쌍** · ≥ 0.20 **54쌍** · ≥ 0.15 **122쌍**(같은 Task 27). 위 표에 없는 상위 쌍은 읽고 **다른 사실**로 판정했다(예: `t1-2-q9` ↔ `t1-3-q10` 「고유값 10개」 vs 「100개」 0.333 · `t4-1-q9` ↔ `t4-2-q3` 네임스페이스 0.333 · `t3-1-q9` ↔ `t3-1-q13` 0.375).

### 3-2. 저작 과정 메모 (4문항) — `mla_questions_test` 의 M2 가드 패턴 밖

| 문항 | 정답 | 자리 | 현재 문구 | 수정안 |
|---|---|---|---|---|
| `mla-t2-2-q17` | **1** | `sources[1].title` | 「…Renate — 보조 출처(AWS 블로그). **치명적 망각의 정의 문장은 공식 문서가 아니라 이 블로그에서 확인됨**」 | 「…Renate (AWS 블로그) — 치명적 망각의 정의」 |
| `mla-t4-1-q23` | **0** | `W1` | 「…4xx를 반환한 호출만 셉니다. **공식 문서는 4xx의 전형적 원인을 서술하지 않으므로 클라이언트 오류 전체라고 해석하지 않습니다.**」 | 둘째 문장을 「소켓 오류·요청 타임아웃처럼 4xx 응답으로 돌아오지 않는 실패는 여기에 잡히지 않습니다.」로 (공식: `InvocationModelErrors` "…This includes 4XX, 5XX status codes, low-level socket errors, malformed HTTP responses, and request timeouts") |
| `mla-t4-1-q27` | **0** | `explanation` | 「**가이드가 말하는 모니터링 관련 설계 원칙이 10개 중 어느 것인지는 문서가 지정하지 않으므로 이 수준까지만 봅니다.**」 | 문장 삭제 |
| `mla-t4-2-q14` | **0** | `explanation` | 「**확인된 연동 예는** CUR을 Athena로 쿼리해 데이터셋으로 쓰는 구성입니다.」(인용 두 페이지에 `Athena` 0건이기도 하다) | 문장 삭제 또는 「비용 데이터는 CUR 을 Athena 로 쿼리한 결과를 데이터셋으로 쓸 수 있습니다」+ 그 사실을 담는 출처 추가 |

- ⚠️ `t2-2-q15·q16·q25`·`t2-3-q12` 출처 제목의 「보조 출처(Amazon Machine Learning, 신규 사용자 중단된 구서비스 문서)」는 메모가 아니라 **상태 라벨**이라 대상이 아니다(공식 페이지 첫머리: "We are no longer updating the Amazon Machine Learning service or accepting new users for it").
- **가드 권고**: M2 패턴에 `에서 확인됨`·`확인된 연동`·`이 수준까지만`·`서술하지 않으므로 .* 해석하지 않` 을 더하고 **`sources[].title` 도 본다**.
- **전수**: 17개 메모 패턴 × 전 필드(지문·보기·해설·오답 근거·`skill`·출처 제목) 스캔에서 위 4문항이 전부다. `mla-t4-3-q22` `W3` 「…ECR 엔드포인트가 필수라고 **단정할 수 없고**」는 보기의 주장을 부정하는 정당한 문장이라 대상이 아니다.

### 3-3. 상태가 오답 근거에서 「그 보기가 틀린 이유」처럼 읽히는 자리 (3문항)

지문이 신규 계정 상황이 아닌데 오답 근거가 상태를 이유로 든다(계약 §2-⑥).

| 문항 | 정답 | 현재 | 수정안 |
|---|---|---|---|
| `mla-t3-3-q23` | **0** | `W2` 「…목적이 다릅니다. **게다가 이 단계는 신규 고객에게 닫힌 Model Monitor 컨테이너를 씁니다.**」 | 둘째 문장 삭제(첫 문장이 이유로 충분하다) |
| `mla-t4-2-q18` | **0** | `W2` 「**CloudTrail Lake는 2026-05-31부터 신규 고객에게 닫혔고** 이 경로의 전제 조건도 아닙니다. 필요한 것은 추적입니다.」 | 「CloudTrail Lake 는 이 경로의 전제 조건이 아닙니다. EventBridge 가 받는 것은 추적이 기록한 API 호출 이벤트입니다.」 |
| `mla-t4-2-q34` | **0** | `W1` 「**Debugger는 신규 고객에게 닫혀 있어 대체 경로가 될 수 없습니다.**」(상태가 유일한 이유다 — 기존 고객은 Debugger 를 쓸 수 있으므로 이유로 성립하지 않는다) | 「Profiler 공지가 시스템 자원 모니터링의 대체로 안내하는 것은 CloudWatch 입니다.」(상태는 `explanation` 에 이미 있다) |

- **대상이 아닌 것(읽고 판정)**: `t2-1-q5` `W0`·`W2`, `t2-3-q27` `W1`·`W2` — 지문이 「새로 만든 계정」이라 상태가 **실제 이유**다. `t3-1-q20`(Edge Manager 중단)·`t1-1-q10`(KDA for SQL 폐지)·`t3-1-q16` — 누구에게나 종료된 서비스라 이유로 성립한다. `t2-3-q16` `W3`·`t4-3-q8` `W2` — 기능 차이를 먼저 적고 상태를 덧붙였다. `t1-2-q18` `W3`(MTurk 한 줄) — 2026-11-06 의도적으로 넣은 자리다.

### 3-4. 상태 표기 일관성 — Clarify 지표 문항 (6문항 · 정책 결정 필요)

Clarify 상태는 **`skill` 문자열이나 본문에 `Clarify` 가 있는 문항에만** 달려 있다. 같은 지표를 가르치는데 문자열이 없는 문항은 비어 있다.

| 달렸다 | 안 달렸다(같은 층) |
|---|---|
| `t2-3-q18`(CI 부호 해석) · `t2-3-q19`(DI) | `t1-3-q1`(CI 정의, 정답 **0**) · `t2-3-q20`(DPL ↔ DPPL 비교, 정답 **1**) |
| `t2-3-q17`(사전 vs 사후) | `t1-3-q4`(사전 지표는 모델 없이, 정답 **1**) |
| — | `t1-3-q2`(CDD, **1**) · `t1-3-q3`(JS, **1**) · `t1-3-q8`(DPL, **1**) |

- 2026-11-06 판정은 「지표의 정의·공식만 묻는 문항에 상태를 달면 틀린 설명이 된다」였고, 그 뒤 붙은 정본 문구는 「…신규 고객에게 닫혀 있습니다 — **지표의 정의와 공식 계산식은 그대로 유효합니다**」다. 이 문구는 정의 문항에도 거짓이 되지 않는다.
- **수정안**: 사람 판정 — ⓐ 6문항에 같은 문구를 붙여 일관성을 맞춘다 ⓑ 「`skill` 이 Clarify 를 명시하는 문항에만 단다」를 가드 주석에 기준으로 적고 6문항을 명시 제외로 고정한다. **지금은 기준이 문자열 우연에 달려 있다.**
- 곁가지: `mla-t1-2-q19`(정답 **1**)의 A2I 문구만 「⚠️ A2I는 현재 신규 고객을 받지 않습니다.」로 **「(기존 고객은 사용 가능)」이 빠져** 다른 15자리와 다르다.

### 3-5. 길이 단서 (`length-cue`)

- **정답 > 최장 오답 × 1.3: 16문항** — `t1-1-q21` · `t1-2-q15` · `t1-3-q6` · `t1-3-q12` · `t2-3-q3` · `t2-3-q26` · `t3-2-q14` · `t4-1-q6` · `t4-2-q5` · `t4-2-q9` · `t4-2-q19` · `t4-2-q20` · `t4-3-q1` · `t4-3-q10` · `t4-3-q18` · `t4-3-q30` (기존 가드는 1.4배라 통과한다).
- **반대 방향 — 정답 < 최단 오답: 39문항(12%)**. 서비스 이름 하나가 정답인 문항이 대부분이다(예: `t1-1-q20` 정답 16자 vs 오답 37~54자 · `t1-2-q23` 10자 vs 19~30자 · `t1-3-q13` 12자 vs 21~36자 · `t1-3-q1` 19자 vs 31~40자). 전체 39개 목록은 `prescreen` 이 내지 않으므로 2단계가 「정답 길이 < 오답 최소 길이」로 다시 뽑는다.
- **정답이 네 보기 중 가장 긴 문항: 139/321(43%)** — 우연이면 25%다.
- **수정안**: 정답을 깎지 말고 **오답을 정답과 같은 정밀도로** 올린다(SCS 5단계에서 확인된 방식). 39문항 쪽은 반대로 오답을 줄이거나 정답에 한정어를 붙인다.

### 3-6. 메타 문구 (`meta-phrasing`) — 60문항

- Task 별: `t1-1` 1 · `t1-3` 1 · `t2-1` 5 · `t2-2` 11 · **`t2-3` 16** · **`t3-1` 13** · `t3-2` 5 · `t3-3` 4 · `t4-1` 2 · `t4-2` 2 (`t1-2`·`t4-3` 0). 문항 번호는 `build/mla_review/*.prescreen.json` 에 있다.
- 형태는 거의 전부 지문의 「**공식 문서가** …로 적는/드는 것은 무엇인가」다(넓은 정규식으로 다시 세면 지문·정답 보기에 귀속 표현이 든 문항은 84개 — `공식 문서` 50 · `문서가` 13 · `ML Lens`/`Machine Learning Lens` 7 · `공지가` 3 등).
- **이 가운데 결함으로 이어진 것**이 §2-B·§2-C 다 — 「문서가 적는다」고 지문에 박아 두면 인용 페이지가 그 사실을 담지 않을 때 문항 전체가 근거를 잃는다. `t2-2-q25`(「공식 문서가 반복 개선의 **첫 단계**로 드는 것」)와 `t4-1-q27`(「설계 원칙 10개 가운데」)은 사실은 옳았지만(구 Amazon ML 문서의 목록 첫 항목 · 원칙 10개 실측 일치) **목록 순서·개수를 묻는 형태**라 페이지가 바뀌면 바로 깨진다.
- **수정안**: 지문에서 「공식 문서가」를 걷고 시나리오로 묻는다(귀속은 해설에 남긴다 — 정당한 층이다). 우선순위는 `t2-3`·`t3-1`·`t2-2`.

### 3-7. 범위 외 서비스가 정답에 든 문항 (2문항)

공식 ko 「범위 외 AWS 서비스」(`…/machine-learning-engineer-associate-01/mla-01-out-of-scope-services.html` · 200 r=0) 목록 102개와 대조했다.

| 문항 | 정답 | 범위 외 서비스 | 상태 |
|---|---|---|---|
| `mla-t4-3-q27` | **0** (`범위는 Services in Scope 목록, 보고서는 AWS Artifact`) | **AWS Artifact** (보안, ID 및 규정 준수) | 같은 문항 `W2` 는 「Audit Manager는 이 시험 가이드의 범위 외 서비스」라고 적는데 **정답에 든 Artifact 도 범위 외**라는 말은 없다. 학습문서는 옳게 적는다(`mla-t4-3.md:434` 「AWS Artifact·Audit Manager는 가이드의 범위 외 서비스」) |
| `mla-t3-2-q20` | **0** (`강화 스캔을 켜서 Amazon Inspector 연동으로 지속 스캔한다`) | **Amazon Inspector** | ECR(범위 내)의 강화 스캔을 묻지만 정답 보기와 해설이 Inspector 를 든다 |

- 사실은 둘 다 옳다. **수정안**(CLF 선례): 문항을 지우지 않고 `explanation` 끝에 범위 메모 한 줄 — 「⚠️ AWS Artifact(또는 Amazon Inspector)는 공식 가이드의 범위 외 서비스 목록에 있습니다. 이름과 역할만 알아 둡니다.」
- **0건이었던 것**: 나머지 100개 이름은 정답 보기에 없다. 걸린 나머지는 오답 보기·출처 제목뿐이다(`Audit Manager` — `t4-3-q27` 오답 · `IoT Greengrass` — `t3-1-q20` 오답 근거 · `Control Tower` — `t1-3-q20` 출처 제목 · `Route 53` — `t1-3-q20` 해설의 글로벌 서비스 예시).
- ⚠️ `Amazon MSK`(`t1-1-q20` 정답)·`AWS CodeCommit` 은 **범위 내·범위 외 어느 목록에도 없다.** 두 목록 모두 스스로 「전체 목록이 아니다」라고 적으므로 범위 밖으로 단정하지 않는다(가이드 1.1 K3 가 「Apache Kafka」를 예로 든다).

### 3-8. 출처 세부 (사실은 옳고, 인용 페이지에 그 세부가 없다 — 낮은 우선순위)

| 문항 | 정답 | 인용 페이지에 없는 세부 | 그 세부가 있는 곳(실측) |
|---|---|---|---|
| `mla-t3-3-q6` | **0** | `W1` 「폴링 파이프라인 상한은 리전당 **300개** … 고정」— `concepts.html` 에 `300` 0건 | `codepipeline/latest/userguide/limits.html`: "Maximum number of pipelines set to polling … 300 … This quota is fixed and cannot be changed" (md 에는 이미 있다) |
| `mla-t2-3-q24` | **0** | `W2` 「기본 7일 · 최소 1시간 · 최대 30일」, 해설의 「Data Capture」 — 인용 두 페이지에 0건 | `shadow-tests-create.html`: "The default duration is 7 days and the maximum is 30 days" · "The minimum duration is 1 hour" (md 에 이미 있다) |
| `mla-t4-2-q34` | **0** | 해설 「지표 문서가 **100밀리초** 단위 프로파일링에 권하는 Debugger」— 인용 두 페이지에 `100|millisecond` 0건 | 미확인(삭제해도 정답 근거에 영향 없음) |
| `mla-t4-3-q25` | **0** | 해설 둘째 문장 「심층 방어에서 관측 층을 담당하며 CloudTrail과 Config가 함께 쓰입니다」— 2026-11-17 백서 재소싱으로 출처가 `security_iam_id-based-policy-examples.html` 로 바뀐 뒤 근거가 사라졌다(`CloudTrail` 0건). 첫 문장은 그 페이지에 있다: "use VPC flow logs to monitor all traffic to and from the training cluster" | 둘째 문장 삭제 권고 |
| `mla-t1-3-q2` | **1** | 해설의 `CDDL`·`group_variable` — 인용 페이지(`clarify-data-bias-metric-cddl.html`)에 0건 | Clarify 분석 구성 문서 쪽 표기 |
| `mla-t3-3-q4` | **0** | 해설 「approval … Amazon SNS와 통합」— 인용 두 페이지에 `SNS` 0건 | `approvals.html`(`t4-3-q29` 의 출처) |

### 3-9. 그 밖의 표기·구조

- **「미세 조정」 통일 — 잔존 0건.** `미세조정` md 0·문항 0 · `파인튜닝` md 0·문항 0 · `미세 조정` md 45·문항 20 · 앵커 `{#fine-tuning}` 1개와 `section: fine-tuning` 문항 1개 짝 유지. 유일하게 남은 `파인 튜닝`(띄어 씀) 1건은 `mla-t2-2-q21` 의 `skill` 이고 **공식 가이드 2.2 SK3 원문 그대로**다(§6-1) — 고치지 않는다.
- **ML 용어 3갈래**: `기계 학습`(md 6 · 문항 0) · `머신 러닝`(md 1 · 문항 5) · `머신러닝`(md 1 · 문항 2). 공식 가이드 ko 는 「기계 학습(ML)」이다. 고유명 「Machine Learning Lens」의 음차가 섞인 것이라 급하지 않다.
- **「적합성 팩」**: 문항 2자리(`mla-t4-3-q27` 오답 보기 + `W2`) · md 0. §5-4.
- **학습문서 `lastVerified`**: `mla-t1-2.md` 는 2026-11-06에 본문(Mechanical Turk 3자리)이 고쳐졌는데 프런트매터가 `2026-10-17` 그대로다. 문항 파일 12개는 전부 `2026-10-26`(그 뒤 여러 배치가 고쳤다). 가드 대상이 아니라 정보로만 적는다.
- **Data Wrangler 접근 경로**: Data Wrangler 를 가르치는 층에서 드는 문항 **13개**(`t1-1-q15` · `t1-2-q1·q4·q5·q6·q7·q8·q13·q20·q22` · `t1-3-q6·q10` · `t3-2-q11`) 중 「새 Studio 에서는 Canvas 로만 접근」을 적은 문항은 `t1-2-q13`(「Canvas 처리 또는 Processing 잡」) 하나다. 학습문서는 적는다(`mla-t1-2.md:99`). Data Wrangler 는 Lifecycle 세 목록 어디에도 없고(닫힌 서비스가 아니다) 가이드가 이름을 직접 든다(1.1 SK3 · 1.2 K4 · SK1) — **결함이 아니라 결정 사항**으로 적는다. 인용 페이지 `data-wrangler-transform.html` (87,587자)은 절차를 「Choose Open Studio Classic」으로 적고 `Canvas` 는 0건이다.
- **문항 출처 ⊄ 같은 Task md 출처**: 문항이 인용하는데 같은 Task 학습문서에 없는 URL **41개**(Task 별 7·3·4·3·1·2·11·4·4·2·6·5). MLA 에는 이 부분집합 가드가 없다(SCS·AIP 에만 있다). §2-B 교체분 5개를 더하면 46개가 된다. 2단계가 가드를 걸지 말지 정한다.
- **정답 인덱스 분포**: 0:224 · 1:78 · 2:14 · 3:5. `t3-1`~`t4-3` 6파일 174문항이 전부 0이다. **3회 기각된 항목이고 재보고하지 않는다** — 셔플 코드가 그대로 있는 것만 재확인했다(`cert_exam_page.dart:193` · `exam_page.dart:101` · `quiz_page.dart:41` · `review_page.dart:77` → `randomOptionOrders` → `question.dart:84` `withOptionOrder`). 해설이 보기 위치를 가정하는 문구는 **0건**.
- **단일 출처 문항**: 85개(26%). 출처 수 분포 1:85 · 2:226 · 3:9 · 4:1.

### 3-10. 0건이었던 축 (다시 재지 않아도 된다)

| 축 | 결과 | 어떻게 셌나 |
|---|---|---|
| 구조·정합성 | 0건 | `prescreen` |
| 문항 필드의 마크다운 | `**` 0 · 백틱 0 · 링크 0 · 단일 이탤릭 0 · HTML 0 | 전 필드 정규식 |
| 학습문서 평문 규율 | `[텍스트](링크)` 0 · 단일 `*이탤릭*` 0 · `####` 0 · `<details>` 열림/닫힘 12편 모두 일치(94/94) | 코드 스팬 마스킹 후 정규식 |
| 프런트매터 `sources` | 12편 모두 목록 뒤에 `lastVerified` 가 온다(목록 중간에 끼어든 키 0) | 줄 단위 파싱 |
| md `title:` ↔ `content_index.dart` | 12/12 일치 | 문자열 대조 |
| 가이드 JSON ↔ 공식 ko | 도메인 이름 4/4 · 비중 28·26·22·24 · 지식·기술 **133/133** | 공백 무시 포함 대조 |
| 자가 점검·요약 ↔ 문항 | **정반대인 자리 0건**(94문답 + 요약 120줄을 문항 정답과 대조) | 정독 |
| 닫힌 서비스의 날짜·상태 서술 | 틀린 자리 0건 | Lifecycle 세 페이지 + 가용성 변경 페이지 5종 |
| 2026-11-06 중복 3쌍 | 재발 0 | 해당 6문항 재독 |
| Mechanical Turk 상태 | md 8줄 전부 상태 동반 · 문항 1자리 상태 있음 | 줄 단위 |

---

## 4. 커버리지·범위

- **커버리지**: 12 Task 의 지식·기술 **133개 전부가 최소 1문항에 덮인다**(누락 0 · 가이드에 없는 태그 0 · 태그 없는 문항 0).
- **쏠림**(같은 번호에 6문항 이상): `1.2 SK1` **9** · `4.1 SK1` **8** · `2.3 SK1` **7** · `4.1 K2` **7** · `2.2 K2` **6** · `1.3 K4` **6** · `4.3 K2` **6**.
- **1문항뿐인 번호가 41개(133개 중 31%)** — `1.1 K4·SK3·SK4·SK6` · `1.3 SK1` · `2.1 SK1` · `2.2 K3·K4·K5·K6·K7·K8·SK1·SK2·SK3·SK5·SK7·SK8·SK9` · `2.3 K5·SK2·SK3` · `3.1 K2·K4·K7·SK3·SK5·SK6` · `3.2 K3·K4·SK5` · `3.3 K2·K3·K6·SK4·SK6` · `4.2 K3·K4·K6·SK7·SK9` (`1.2`·`4.1`·`4.3` 은 0개). **`2.2` 는 17개 번호 중 13개가 1문항**이다. §3-1 의 중복 교체 때 이 번호들을 보강하면 두 문제가 함께 닫힌다(예: ⑤에서 `t3-2-q19` 를 좁히고, ⑥·⑦의 교체 소재를 `2.2`·`3.1` 의 1문항 번호로 돌린다 — 단 교체 문항의 `skill` 은 **원 Task 안에서** 유지해야 Task 별 커버리지 가드가 깨지지 않는다).
- ⚠️ `2.3 K5`(수렴 문제)의 유일한 문항이 `mla-t2-3-q14` 다 — §2-D 에서 상태만 붙이고 **교체하지 않는다.**
- **난이도**: Task 당 `foundational` 5~10개(21~43%), 하한 가드(5개) 전부 충족. 전체 applied 226 · foundational 95.
- **범위**: §3-7 의 2문항. 범위 외 서비스가 정답 **전체**인 문항은 0건.

---

## 5. 교차 자격증 — 다른 자격증과 어긋나는 자리 (고치지 않고 적기만)

| # | 사실 | MLA | 다른 자격증 (grep 실측) |
|---|---|---|---|
| 1 | Lambda 타임아웃 예외 | `mla-t3-1-q22` · `mla-t3-1.md:358` — 「상한 900초」 단정, 예외 0자리 | `saa/saa-t2-2.md:15·359·431` 이 「Managed Instances 비동기·이벤트 소스 매핑 5,400초」를 적고 `saa-t2-2` 문항(`:70`)은 「기본(온디맨드) 용량 모드에서 최대 15분」으로 한정한다. `saa-t3-4.questions.json:46` 은 「최대 900초(15분)」 단정(MLA 와 같은 상태). `dva`·`dea`·`scs` 는 이번에 판정하지 않았다(`900초` 포함 파일 수: dea 7 · dva 2 · saa 3 · scs 2 — Lambda 문맥인지는 미확인) |
| 2 | Logs Insights 동시 쿼리 | `mla-t4-2-q11` · `mla-t4-2.md:193` — 「계정당 100개」만 | `aip/aip-t2-5.md:216` · `dva/dva-t4-1.md:80` · `scs/scs-t1-2.md:77·244·286` · `scs/scs-t2-2.md:132·301` — 전부 「QL 100 / PPL·SQL 각 15」 |
| 3 | S3 VPC 엔드포인트 유형 | `mla-t4-3.md:539` 「S3는 게이트웨이 … 둘을 바꿔 고르면 틀립니다」 · `mla-t4-3-q22` | SAA 는 같은 단정을 2026-10-28에 고쳤다(`CLAUDE.md` 기록: 「S3·DynamoDB는 Gateway와 Interface 엔드포인트를 둘 다 지원한다」) |
| 4 | Conformance Packs 한국어 표기 | 문항 2자리 「적합성 팩」(`mla-t4-3-q27`) | `aif/aif-t5-2.md` 12자리 「적합성 팩」 · `scs/scs-t1-1.md` 1자리(표기 메모) · SOA 는 「규정 준수 팩」, SCS 는 「준수 팩」. MLA 가이드에는 이 용어가 없어 정본을 정할 근거가 없다 → **단정하지 않는다** |
| 5 | Fine-tuning 한국어 표기 | 본문은 「미세 조정」(2026-11-07 통일), `skill` 1자리는 가이드 원문 「파인 튜닝」 | AIF 는 가이드·본문 모두 「미세 조정」. **두 공식 가이드가 서로 다르다**(§6-1) |
| 6 | CodeGuru Reviewer 의 대안 | `mla-t4-3.md:461·657` — 대안으로 「Amazon Q Developer」를 든다(공식 가용성 변경 페이지 그대로) | DVA 트랙은 「Amazon Q Developer 는 in-scope 가 아니다 — Kiro 로 쓴다」로 정리돼 있다. Q Developer **IDE 플러그인은 Sunset**(공지 2026-04-30 · 종료 2027-04-30). §6-3 |

---

## 6. 공식 내부 어긋남 / 「확인되지 않음」 — 수정안을 낼 수 없는 것

1. **MLA 공식 가이드(ko)는 「파인 튜닝」, 제품 문서(ko)와 AIF 가이드는 「미세 조정」.** `…/machine-learning-engineer-associate-01-domain2.html` 본문에서 `파인 튜닝` 1건 · `미세 조정` 0건(2.2 SK3 「사전 훈련된 모델 파인 튜닝」). 레포의 `skill` 문자열은 가이드 전사라 그대로 두는 것이 맞고, 본문 통일(「미세 조정」)과 공존한다. 2026-11-07 기록의 「공식 시험 가이드 JSON도 미세 조정으로 적는다」는 **AIF 가이드 이야기**이고 MLA 가이드에는 해당하지 않는다.
2. **Logs Insights 동시 쿼리 한도**: 사용자 가이드(`AnalyzingLogData.html`)는 「QL 100 + PPL·SQL 15」, API 레퍼런스(`API_StartQuery.html`)는 "You can have up to 100 concurrent CloudWatch Logs insights queries" 만 적는다. 더 구체적인 사용자 가이드를 정본으로 삼았다(§2-E).
3. **CodeGuru Reviewer 가용성 변경 페이지가 아직 Amazon Q Developer 를 대안으로 권한다**(`codeguru-reviewer-availability-change.html` — `Q Developer` 4건 · `Kiro` 0건). 그런데 Lifecycle Sunset 목록에 `Amazon Q Developer IDE plugins`(2026-04-30 공지 · 2027-04-30 종료)가 있다. 학습문서(`mla-t4-3.md:461·657`)는 공식 페이지를 그대로 옮긴 것이라 거짓이 아니다. **「Q Developer 의 코드 검토가 어느 표면에서 남는가」는 확인하지 못했다** — 수정안을 내지 않고, md 에 「IDE 플러그인은 지원 종료 예정」 한 줄을 더할지 사람이 정한다.
4. **공식 docs 에서 확인되지 않은 주장 2건**(둘 다 문항이 사실처럼 쓴다): ⓐ 「Savings Plans 구매 전에 먼저 right-size」— AWS 블로그에만 있다(`mla-t4-2-q33` · md 자가 점검 Q7) ⓑ 「CPU 활용률 기반 정책은 트래픽이 줄어도 scale-in 하지 않을 수 있다」— re:Post 지식 센터에만 있다(`mla-t4-2-q32`). 두 번 다 AWS 문서 검색으로 docs 결과를 확인했고 못 찾았다. **「docs 에 없다」가 아니라 「못 찾았다」다.**
5. **Model Monitor·Clarify 등의 날짜가 둘로 보이는 것은 어긋남이 아니다** — Lifecycle Maintenance 표의 `June 30, 2026` 은 **공지일**이고 제품 페이지의 `July 30, 2026` 은 **신규 고객 차단일**이다. 레포는 차단일을 쓴다(일관).
6. **실시간 추론 페이로드 25 MB vs 6 MB** 는 학습문서가 이미 「문서 간 불일치」로 적어 뒀다(`mla-t3-1.md:122`). 문항은 수치를 묻지 않는다 — 재보고하지 않는다.
7. **범위 목록과 서비스 기능의 경계**: `Amazon Inspector` 는 범위 외 목록에 있는데 범위 내인 `Amazon ECR` 의 강화 스캔이 Inspector 로 동작한다. 그래서 §3-7 의 `t3-2-q20` 은 삭제가 아니라 범위 메모가 맞다.

**이번에 판정을 유보한 것 (`NEEDS_CONTEXT` 아님 — 사람이 정하면 되는 결정)**: §2-A `t2-1-q18` 의 재작성 방향 · §2-C `t4-2-q33` 의 ⓐ/ⓑ · §2-D Model Monitor 4문항의 기준 · §2-F `t4-1-q3` 유지 여부 · §3-4 Clarify 6문항의 기준 · §3-9 Data Wrangler 경로 메모 · §3-9 G-84 가드 도입 여부.

---

## 7. 2단계에 넘기는 순서 제안

의존 관계가 있는 것은 ⚠️ 로 적는다. **정답 인덱스를 바꾸는 항목은 없다.**

| 순서 | 묶음 | 대상 | 작업 | 주의 |
|---|---|---|---|---|
| 1 | 🔴 | `t3-2-q10` | `W3`·`explanation` 한정어 | 가드: 「`최소 인스턴스가 1` 은 `일반`·`추론 컴포넌트` 한정과 함께」 |
| 2 | 🟡 출처 교체 | §2-B 8문항 | 출처 URL·제목 교체 + md 5편에 URL 추가 | ⚠️ md 프런트매터는 `lastVerified:` **앞**에 삽입. MLA `sources` 는 **다중 행** 형식이다(`{` / `"title"` / `"url"` / `}` 각 한 줄) — 한 줄 압축 렌더러를 쓰면 파일 전체가 흔들린다. ⚠️ `t2-3-q11` 은 구서비스 문서라 라벨을 붙인다 |
| 3 | 🟡 상태 | §2-D 7문항 | 정본 문구 붙이기 + `mmTaughtIds` 갱신 | ⚠️ Model Monitor 4건은 **기준을 먼저 정한 뒤** 집행. ⚠️ `t2-3-q14` 는 `2.3 K5` 의 유일한 문항이다 — 교체 금지 |
| 4 | 🟡 귀속·수치 | `t4-3-q8`(+md `:197`) · `t4-2-q11`(+md `:193`) · `t3-1-q22`(+md `:358`) · `t4-3-q22`(+md `:539`) | 해설·지문 한정 + md 동시 수정 | ⚠️ **문항 가드는 `.md` 를 보지 않는다** — 네 건 모두 md 를 같은 PR 에서 고친다. 본문을 고친 md 는 `lastVerified` 를 올린다 |
| 5 | 🟡 사람 판정 | `t4-2-q32` · `t2-1-q18` · `t4-2-q33` · `t4-1-q3` | 지문 조건 추가 / 재작성 / 귀속 변경 | 판정 전에는 손대지 않는다 |
| 6 | 🟢 메모·상태 문구 | §3-2 4문항 · §3-3 3문항 · §3-8 `t4-3-q25` | 문장 삭제·치환 + M2 가드 패턴 확장(`sources[].title` 포함) | — |
| 7 | 🟢 누출 | §3-1 (b) 9쌍 | 누출하는 쪽 해설·오답 근거에서 상대 정답 문장 걷기 | 문항 교체 없이 닫힌다 |
| 8 | 🟢 중복 | §3-1 (a) 7쌍 | 한쪽 본문 교체(정답 자리·`skill`·`section`·`difficulty`·`verified` 보존) | ⚠️ 3·6번 **뒤에** 한다(교체가 방금 붙인 상태 문구를 지운다). ⚠️ 교체 소재는 §4 의 1문항 번호로 돌리되 `skill` 은 원 Task 안에서. ⚠️ `verified` 는 치환 범위에서 제외해 원본 값이 그대로 남게 한다(AI 는 `verified: true` 를 쓰지 않는다). ⚠️ 재발 가드는 「출처 공유 + 자카드」만으로는 ④·⑦을 못 잡는다 — 교체한 쌍을 **쌍별 단정**으로 고정한다 |
| 9 | 🟢 범위 | `t4-3-q27` · `t3-2-q20` | 해설에 범위 메모 한 줄 | CLF 선례의 탐지 집합 가드를 MLA 에도 둘 수 있다 |
| 10 | 🟢 길이·메타 | §3-5 · §3-6 | 오답 길이 맞추기 · 지문 크러치 걷기 | 분량이 크다(16 + 39 + 60문항). 별 배치 권고. ⚠️ 8번에서 교체한 문항은 처음부터 맞춰 쓴다 |

- **교차 자격증(§5)**: 1·2·3번은 MLA 수정과 함께 SAA·DEA 등에서 같은 문구를 전수로 다시 세어 닫는 것이 싸다. 이 보고서는 MLA 밖 파일을 판정하지 않았다.
- **이 보고서의 한계**: ① 학습문서 12편(약 770KB)의 **본문 전문은 읽지 않았다** — 요약·자가 점검 전문, 문항에서 역추적한 자리, 축별 전수 스캔만 봤다. 문항으로 파생되지 않은 md 단독 사실 오류는 남아 있을 수 있다. ② 인용 정확성은 **수치·식별자는 전수**, 한국어로만 서술된 주장은 **정독하며 의심한 자리만** 페이지를 열었다 — §2-B 의 8문항이 상한이라는 보장은 없다(특히 단일 출처 85문항). ③ `aws.amazon.com/*/pricing/` 요율 표는 본문 추출로 검증되지 않는다(`t2-1-q16·q17·q18` 의 둘째 출처).
