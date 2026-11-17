# MLA-C01 2단계 보정 — 2026-11-17

> **대상**: `content/phase2-fix-2026-11-17` · `flutter_app/assets/content/mla/` — 학습문서 12편 · 문항 **321개(전부 `verified: true` 라이브)**
> **집행한 1단계 보고서**: `docs/audits/2026-11-17-full-verify/mla.md`
> **계약**: `docs/audits/2026-11-17-full-verify/01-PHASE2-CONTRACT.md`
> **한 줄 결론**: 🔴 1건 · 🟡 23문항을 **전부** 닫았고 🟢 다섯 묶음을 함께 닫았다. **정답 인덱스는 한 건도 바뀌지 않았다**(전수 분포 224·78·14·5 불변). 사람 판정이 필요한 2문항은 손대지 않고 §5 로 넘긴다.

---

## 0. 요약

| | 수 |
|---|---|
| **채택** | **30항목 / 문항 32개 · 학습문서 본문 4자리** (1단계 🔴 1 · 🟡 23 · 🟢 12묶음 대비) |
| **기각** | **4항목** (§2-F `t4-1-q3` · §3-4 Clarify 6문항 · §3-9 정답 분포 · §3-9 Data Wrangler) |
| **범위 확장·보고 정정** | **7건** (§3 에 수치와 함께) |
| **사람 판정으로 넘김** | **2문항** (`t4-2-q32` · `t2-1-q18` — §5) |

- 손댄 파일: **문항 10파일 · md 7편 · 가드 1** (md 중 **본문**을 고친 것은 `mla-t3-1.md`·`mla-t4-2.md`·`mla-t4-3.md` 3편, 나머지 4편은 프런트매터 출처 등재)
- diff: **79 insertions / 59 deletions** — 서식 churn 0(바이트 블록 치환 + 치환 횟수 단정 57건 전부 통과)
- **정답 인덱스 변경: 0건** · **`verified` 는 치환 범위에서 제외**해 원본 값이 파일에 그대로 남았다(AI 가 그 값을 타이핑하지 않았다)
- 새 가드: `flutter_app/test/mla_v2_fix_test.dart` **20건**
- **민감도 확인 방법**: `git stash` 가 공유 트리에서 금지되므로 **콘텐츠 문구를 임시로 깨서 레드를 확인하고 sha256 으로 복구를 증명**했다 — 7자리 전부 `red=True · restore sha equal=True`(§6)
- 테스트: `flutter test test/mla_*` → **223 통과 / 1 실패**. 그 1건은 **설계대로 울린 트립와이어**다(§5)
- `flutter analyze test/mla_v2_fix_test.dart` → **No issues found**
- 남긴 것(다음 배치): §3-1 중복 7쌍 + 누출 9쌍 + 겹침 4묶음 · §3-5 길이 단서 16 + 반대 방향 39 · §3-6 메타 문구 60 · §3-8 잔여 5건 · G-84 부분집합 가드 도입 여부

### 재측정 방법 (2단계가 직접 한 것)

| 축 | 방법 | 대조군 |
|---|---|---|
| URL 생사 | `curl -sL -o … -w '%{http_code} %{num_redirects} %{url_effective}'` — 새로 제안·교체한 URL **22개 전부 `200 r=0`** | 없는 슬러그 `sagemaker/latest/dg/zz-bogus-control-page.html` → **`200 r=1`** 로 가이드 인덱스(본문 21자) |
| 「그 페이지가 그 사실을 담는가」 | `<div id="main-col-body">` 이후 태그 제거 → 정규식 탐침. **탐침마다 음성 대조군 `zz-not-present-xyz` 0건**을 함께 셌다 | 양성 대조군을 항목마다 뒀다(예: `inference-cost-optimization.html` 에서 `right-siz` 0건일 때 `Savings Plans` 2건) |
| 전수 개수 | md 12편 + 문항 12파일을 파이썬으로 걸어 문구별 자리 수를 셌다 | 치환 함수가 **횟수를 단정**해 0건·과다 모두 쓰기 **전에** 막는다 |

---

## 1. 채택 — 무엇을 어떻게 고쳤는가

### 1-1. 🔴 `mla-t3-2-q10` — 「실시간 엔드포인트는 최소 인스턴스가 1 이상」 거짓 일반화

- **공식 재확인**: `sagemaker/latest/dg/endpoint-auto-scaling-zero-instances.html`(`200 r=0` · 6,923자) — "It hosts one or more inference components. **An endpoint can scale to and from zero instances only if it hosts inference components.**"(`inference component` 14건 · 음성 대조군 0건) → **채택**
- **고친 것**(정답 인덱스 **0** 불변):
  - `wrongExplanations["3"]` → 「**추론 컴포넌트를 쓰지 않는 일반 프로덕션 변형은** 최소 인스턴스가 1 이상이어야 하고 … **0대까지 줄일 수 있는 것은 추론 컴포넌트를 호스팅하는 엔드포인트뿐입니다.** 온디맨드로 묶을 수 없습니다.」
  - `explanation` 끝 문장의 같은 거짓 전제(「0대까지 줄어드는지와」)를 「스케일링 정책이 필요한지와, 일반 프로덕션 변형이 유휴 시간에도 최소 1대를 유지하는지」로
  - ⭐ **출처를 하나 더했다** — 기존 두 출처(`serverless-endpoints` · `inference-cost-optimization`)에는 **0대 축소 규칙이 없다.** 이 레포가 반복해 밟은 「URL 은 200인데 그 페이지에 그 사실이 없다」를 같은 수정에서 닫았다.
- **전수**: `최소 인스턴스가 1|최소 용량은 1` — 문항 **3자리**(`t3-1-q9`·`t3-2-q10`·`t3-2-q13`) · md **0자리**. 보고 실측과 일치하고, 한정이 없던 것은 **q10 한 자리**였다(md 는 처음부터 옳게 적어 **역방향 잔존**).

### 1-2. 🟡 §2-A `mla-t3-1-q22` — Lambda 타임아웃 「상한 900초」에 Managed Instances 예외 누락

- **공식 재확인**: `lambda/latest/dg/gettingstarted-limits.html`(17,440자) — "Code can run for up to 15 minutes in a single invocation (**up to 90 minutes for Lambda Managed Instances functions invoked asynchronously or through any event source mapping** except Amazon MQ and Amazon DocumentDB)" + "Container image code package size **10 GB**" → **채택**
- **고친 것**(정답 **0** 불변): 지문을 「**표준(온디맨드) AWS Lambda 함수**에 올리려 한다」로 한정 · `explanation` 에 「Managed Instances … 최대 90분까지 갈 수 있지만 이 시나리오는 이미지 크기 한도에서 이미 걸립니다」 한 줄 · `W2` 를 「**표준 함수의** 상한이 900초」로
- **md 동시 수정**: `mla-t3-1.md:358` 표 셀 → 「타임아웃 **900초(15분)**(Managed Instances 함수의 비동기·이벤트 소스 매핑 호출은 **최대 90분**)」 — **문항 가드는 `.md` 를 보지 않는다.**

### 1-3. 🟡 §2-A `mla-t4-3-q22` — S3 인터페이스 엔드포인트도 공식 수단이라 보기 1을 거짓으로 만드는 문장이 없었다

- **공식 재확인**: `AmazonS3/latest/userguide/privatelink-interface-endpoints.html`(33,008자) — "You can use **two types of VPC endpoints** to access Amazon S3: gateway endpoints and interface endpoints" + "gateway endpoints, **which are not billed**". SageMaker `train-vpc.html`(8,558자)에 **`not supported` 0건**(인터페이스가 안 된다고 적지 않는다) → **채택**
- **고친 것**(정답 **0** 불변): 지문에 갈림길을 넣어 「**추가 요금 없이** SageMaker 문서가 안내하는 대로」 · `W1` 의 **회피형 반박**을 「S3 인터페이스 엔드포인트도 … 공식 수단입니다. 공식 S3 문서는 … **두 가지**라고 적고 그중 **과금되지 않는 쪽이 게이트웨이**라고 적습니다」로 · S3 PrivateLink 출처 추가
- ⚠️ **「인터페이스에는 시간·데이터 처리 요금이 붙는다」는 쓰지 않았다** — 공식이 적는 것은 「게이트웨이는 과금되지 않는다」까지다(그 반대는 따라오는 추론이다).
- **md 동시 수정**: `mla-t4-3.md:539` 의 배타 단정 → 「공식 S3 문서는 … **두 가지**라고 적으므로 S3가 인터페이스 엔드포인트를 지원하지 않는다고 외우면 틀립니다」

### 1-4. 🟡 §2-B 출처 교체 8문항 — 사실은 옳고 인용 페이지만 틀렸다

**정답 인덱스 8건 전부 불변**(실측 `1·2·1·1·0·0·0·0`). 전부 `curl -sL` 로 `200 r=0` 을 재고 **본문으로 그 사실을 확인**한 뒤 교체했다.

| 문항 | 내린 출처 | 올린 정본 | 공식 원문 |
|---|---|---|---|
| `t1-3-q8`·`t1-3-q24` | `mlrel03-bp04.html`(편향 유형을 **이름만** 든다) | `aws.amazon.com/what-is/ai-bias/` | "**Label AI bias** is when a data annotator unconsciously introduces bias…" · "**Selection AI bias** … do not use **random sampling** methods" · `Recall bias` 2건 · ⭐ **`Algorithm bias`("a misconfiguration of an AI system's model architecture")와 `Measurement bias`("stems from errors in the data collection process")까지 같은 페이지에 있어** 두 문항의 **오답 근거 네 개도 전부** 이 한 페이지로 덮인다 |
| `t2-2-q3` | `distributed-training-strategies.html`(`learning rate` 0건) | `data-parallel-config.html` | "as more nodes are added, **batch sizes should increase proportionally** … **increase the learning rate** … **Linear Scaling Rule**" |
| `t2-3-q11` | `mlperf04-bp02.html` | `machine-learning/latest/dg/evaluating_models.html` | "it **rewards models that can \"remember\" the training data, as opposed to generalizing from it**" ⚠️ 첫 문장이 "We are no longer updating the Amazon Machine Learning service" 라 **출처 제목에 「신규 사용자 중단된 구서비스 문서」 라벨**을 붙였다(기존 `§P2-A1` 가드가 그 라벨을 요구한다) |
| `t3-2-q5` | `target-tracking-scaling-policy-overview.html`(제목이 「SageMaker 사전 정의 지표 목록」인데 **`SageMakerVariantInvocationsPerInstance` 0건**) | `multi-model-endpoints-autoscaling.html` | "`SageMakerVariantInvocationsPerInstance` … **We strongly recommend using this metric.**" ⭐ 같은 페이지가 **`CPUUtilization` 을 사용자 지정 지표 예시**로 들어 `W2` 도 덮인다 |
| `t3-3-q15` | `dg/pipelines.html`(2,613자 · `DAG`·`data dependenc` **둘 다 0건**) | `build-and-manage-steps.html` | "When a step does not depend on any other step, **it runs immediately upon pipeline execution** … **`ParallelismConfiguration`**" · "specifying a step's **`DependsOn`**" |
| `t3-3-q16` | `pipelines-overview.html`(제목이 「데이터 의존성과 병렬 실행, DependsOn」인데 `Depends`·`parallel` 0건) | `build-and-manage-steps.html` | 위와 같음(`data dependenc` 12건이라 **DAG 사실까지 한 페이지로** 덮인다) |
| `t3-3-q24` | `mlops04-bp01.html`(`schedule` 0건) | `mlperf06-bp05.html` | 안티패턴 "**Retraining on a fixed schedule regardless of model performance or data patterns**" |

**md 등재 6건**(`mla-t1-3` 1 · `mla-t2-3` 1 · `mla-t3-2` 1 · `mla-t3-3` 2 · `mla-t4-3` 1) — 프런트매터 `sources:` 의 **목록 끝(`lastVerified:` 바로 앞)**에 넣었다. ⚠️ **목록 중간에 최상위 키가 끼면 파서가 뒤쪽 출처를 조용히 버린다**(2026-11-11 SCS 라이브 결함) — 새 가드가 **파서 루프를 재현해** 삽입 위치까지 단정한다.

### 1-5. 🟡 §2-C 귀속 2문항

- **`t4-3-q8`**(정답 **0** 불변) — `IAM/…/access-analyzer-policy-generation.html`(22,920자)에 **`30 days` 0건 · `representative` 0건**(양성 대조군 `90 days`·`broad` 2건)이고 공식 권고는 "We recommend that you choose the **shortest time period possible**" 다. 「권장 흐름은 … 대표 기간 30일에서 90일」을 **「최대 90일까지 고를 수 있고 공식은 … 가능한 한 짧은 기간을 고르라고 권합니다」**로. **md `mla-t4-3.md:197` 동시 수정.**
- **`t4-2-q33`**(정답 **0** 불변) — `inference-cost-optimization.html`(6,089자)에 **`right-siz`·`right siz`·`rightsiz`·`before` 전부 0건**(양성 대조군 `Savings Plans` 2건). 사실은 AWS 블로그에만 있다. 계약 §2「확인되지 않은 사실을 새로 단정하지 않는다 — 공식에 없으면 그 주장을 걷거나 측정된 범위로 좁힌다」에 따라 **수치를 지우지 않고 귀속만** 바꿨다(보고의 선택지 ⓐ): 지문 「**AWS 기계 학습 블로그**의 SageMaker 비용 분석 글이 …」 · 해설 「**블로그가** 제시하는 순서는 … 이 순서는 블로그에 있고 **SageMaker 추론 비용 최적화 문서는 적지 않습니다**」. ⭐ 레포 선례가 있다 — `mla-t4-1-q3` 이 지문에서 블로그 귀속을 정직하게 밝힌다.

### 1-6. 🟡 §2-D 닫힌 서비스 상태 표기 7문항 + **기준 명문화**

- **Debugger 2문항**(`t2-3-q14`·`q15`) — 인용 페이지 `debugger-built-in-rules.html` **자신의 첫 Note** 가 "Amazon SageMaker Debugger is **no longer open to new customers.** Existing customers can continue to use the service as normal." 를 적는데 문항만 빼먹고 있었다(같은 페이지가 `vanishing_gradient` · "maximum numbers of built-in rules … is **20**" · "**no additional cost** for using the built-in rules" 를 전부 담아 **사실은 옳았다**). 정본 문구 「⚠️ SageMaker Debugger는 신규 고객에게 닫혀 있습니다(기존 고객은 계속 사용).」을 `explanation` 에 달았다.
- **Role Manager 1문항**(`t4-3-q10`, 정답 **0** 불변) — `role-manager-availability-change.html` 이 "no longer open to new customers. **Existing customers can continue to use the service as normal.**" 라 **종료가 아니라 Maintenance** 다. 과거형(「제공하던」·「제공했습니다」)이 「사라졌다」로 읽히므로 **현재형으로 바꾸고** 상태 문구를 달았다. 전수 가드가 과거형 **0건**을 고정한다.
- ⭐⭐ **Model Monitor 4문항**(`t4-1-q12`·`q13`·`q17`·`q18`) — 보고가 「정책 결정이 하나 필요하다」고 남긴 자리다. **기준을 바꾸는 쪽으로 판정했다.**
  - 옛 기준은 「문항 JSON 어디에든 `Model Monitor` **문자열**이 나오는가」였고 그래서 **같은 기능을 문자열 없이 가르치는 네 문항**(위반 스키마 · 품질 스케줄 오프셋 · 정답 라벨 병합)이 모집단 **밖**에 있었다. 네 문항의 출처는 전부 `model-monitor-*` 계열이다.
  - 새 기준: **「가르치는 층이 이름을 들거나 출처가 `model-monitor-*` 계열이면 대상」** → **17문항**(13 + 4). 가드가 그 수를 대조군으로 고정해 **13으로 되돌아가면 레드**가 된다.
  - **명시 제외 5문항을 가드에 이유와 함께 적었다** — `q10`·`q11`(데이터 캡처는 Model Monitor 없이도 쓰는 독립 기능, 2026-10-27 판정) · `q19`·`q20`·`q21`(출처가 `clarify-model-monitor-*` 계열이라 **Clarify 상태가 더 정확한 층**이고 이미 붙어 있다, 2026-11-06 §P3-M2 판정 ②). 이제 기준이 암묵적이지 않다.
  - ⚠️ **`mla_questions_test` 의 `mmTaughtIds` 는 손대지 않았다** — 그 가드는 「목록에 있는 것은 문구가 있다」만 단정하므로 네 문항을 더해도 레드가 되지 않고, 전수 보장은 **새 가드가 더 넓게** 한다(§7 컨트롤러 요청에 선택지로 적는다).

### 1-7. 🟡 §2-E `mla-t4-2-q11` — Logs Insights 「계정당 동시 쿼리 100개」는 QL 한정

- **공식 재확인**: `AnalyzingLogData.html`(7,259자) — "You are limited to **100 concurrent CloudWatch Logs Insights QL** per account, including queries added to dashboards. **Additionally, you can run 15 concurrent queries for either OpenSearch Service PPL or OpenSearch Service SQL.**" → **채택**
- **고친 것**(정답 **0** 불변): 해설을 「**계정당 동시 쿼리 100개는 Logs Insights QL 기준**이고(대시보드에 올린 쿼리 포함) **OpenSearch PPL과 SQL은 각 15개**입니다」로 · 둘째 출처 제목 「StartQuery API — 계정당 동시 쿼리 100개」 → 「— 동시 쿼리 제한」
- **md `mla-t4-2.md:193` 동시 수정** → 「동시 쿼리 **QL 100개 / OpenSearch PPL·SQL 각 15개**」

### 1-8. 🟢 함께 닫은 다섯 묶음

| 묶음 | 문항 | 처리 |
|---|---|---|
| §3-2 저작 과정 메모 | `t2-2-q17`(출처 제목) · `t4-1-q23`(`W1`) · `t4-1-q27`(해설) · `t4-2-q14`(해설) | 메모를 지우거나 **사실 서술로 교체**. `t4-1-q23` 은 `monitoring-cloudwatch.html` 실측(`Invocation4XXErrors` "where the model returned a **4xx** HTTP response code" ↔ `InvocationModelErrors` "includes … **low-level socket errors** … and **request timeouts**")에 맞춰 「소켓 오류나 요청 타임아웃처럼 4xx 응답으로 돌아오지 않는 실패는 이 지표에 잡히지 않습니다」로 |
| §3-3 오답 근거의 상태 | `t3-3-q23`(`W2`) · `t4-2-q18`(`W2`) · `t4-2-q34`(`W1`) | 상태를 **그 보기가 틀린 이유로 드는 문장**을 걷고 **진짜 이유**로 바꿨다(「EventBridge가 받는 것은 추적이 기록한 API 호출 이벤트」 · 「Profiler 공지가 … 안내하는 것은 CloudWatch」). ⚠️ `t4-2-q18` 의 CloudTrail Lake 상태는 **md `mla-t4-3.md:477` 이 계속 적는다**(G-68 가드는 `aif-t5-2.md` 만 본다 — 영향 없음) |
| §3-7 범위 외 서비스 | `t4-3-q27`(AWS Artifact) · `t3-2-q20`(Amazon Inspector) | 공식 ko 「범위 외 AWS 서비스」 페이지 실측(둘 다 **「보안, ID 및 규정 준수」 범주에 실재** · `Amazon MSK`·`CodeCommit` 은 두 목록 어디에도 없다)로 확인한 뒤, 문항을 지우지 않고 **CLF 선례의 범위 메모 한 줄**을 `explanation` 에 달았다(md 에만 적으면 오답노트·모의고사 화면에서 보이지 않는다) |
| §3-8 담지 않는 세부 | `t4-3-q25`(해설 둘째 문장) · `t4-2-q34`(「100밀리초」) | 2026-11-17 백서 재소싱으로 근거가 사라진 문장과 **미확인 수치**를 걷었다. ⚠️ `t4-2-q34` 는 문장을 통째로 지우지 않고 「참고로 Debugger도 신규 고객에게 닫혀 있습니다」로 줄여 **가르치는 층의 상태 표기를 지키면서** 미확인 수치만 뺐다 |
| §3-9 상태 문구 통일 | `t1-2-q19`(A2I) | 「⚠️ A2I는 현재 신규 고객을 받지 않습니다**(기존 고객은 사용 가능)**.」 — 다른 18자리와 같은 형태로. 전수 가드가 `신규 고객을 받지 않습니다(?!\()` **0건**을 고정한다(탐지 집합 19) |

---

## 2. 기각 — 왜 고치지 않았는가

### 2-1. §2-F `mla-t4-1-q3`(블로그 단독 출처) — **유지**

보고 자신이 「사실 오류가 아니라 **출처 등급**」이고 「**지문이 귀속을 정직하게 밝힌다**」고 적었다. 실측해도 블로그 본문과 문항이 일치한다. 계약 §2「확인되지 않은 사실을 새로 단정하지 않는다」는 **귀속이 정직한 자리까지 지우라는 뜻이 아니고**, 반대로 §1-5 의 `t4-2-q33` 을 ⓐ 로 고친 것이 이 문항의 형태를 **정본으로 삼은 것**이다. 교체(ⓑ)는 공식 2분류 문항이 `t4-1-q1`·`q2` 와 겹치지 않아야 해서 **중복 배치(§3-1)와 함께** 보는 것이 싸다 → §4 로 넘긴다.

### 2-2. §3-4 Clarify 지표 정의 6문항 — **ⓑ(기준 명문화) 채택 = 콘텐츠 무변경**

보고는 「지금은 기준이 **문자열 우연**에 달려 있다」며 ⓐ(6문항에 상태 추가)와 ⓑ(기준을 적고 명시 제외)를 냈다. **ⓑ 로 판정했다.**

- **근거**: Clarify 가용성 변경 페이지와 라이브 `mla-t1-3.md:96` 이 「지표가 라벨 개수와 혼동 행렬로 계산되는 **공개된 표준 공식**이고 pandas·scikit-learn 으로 재현하면 Clarify 출력과 일치한다」고 적는다. **기능은 닫혔지만 공식은 닫히지 않았다** — 정의·공식만 묻는 문항에 서비스 상태를 달면 **학습 대상이 사라진 것처럼** 읽힌다.
- ⭐ 같은 판정이 §1-6 의 Model Monitor 4문항과 **모순되지 않는다**: 그 넷은 **그 기능 안에서만 존재하는 스키마·스케줄 의미**를 가르치므로 상태가 필요하고, 이 여섯은 **기능 밖에서도 성립하는 산술**을 묻는다. 가드 주석에 그 가름을 적었다.
- ⚠️ **기존 가드가 이 판정을 이미 못박고 있다** — `mla_aif_p2_review_fix_test` 의 대조군이 `teachingLayer(mla-t1-3-q1).contains('Clarify')` 를 **`isFalse`** 로 단정한다. ⓐ 를 택했다면 **그 공유 파일을 먼저 뒤집어야** 했다(계약 §1 금지). 새 가드가 **여섯 ID 를 명시 제외로 고정**하고 왜 그런지 적어, 기준이 문자열 우연으로 남지 않게 했다.

### 2-3. §3-9 정답 인덱스 분포 쏠림(0:224) — **재보고하지 않는다**

보고가 「**3회 기각된 항목**」으로 적었고 셔플 코드 경로를 재확인했다. 새 가드는 분포를 **불변식으로** 고정할 뿐 바꾸지 않는다.

### 2-4. §3-9 Data Wrangler 접근 경로 — **결정 사항**

보고가 「결함이 아니라 결정 사항」으로 적었다(Lifecycle 세 목록 어디에도 없고 가이드가 이름을 직접 든다). 손대지 않았다.

---

## 3. 범위 확장 — 보고가 하한·과대이던 자리 (전수 실측)

### 3-1. ⚠️⚠️ 보고의 §2-B 교체 대상 **한 건이 틀렸다** — `t3-3-q15` 는 다른 페이지를 내려야 했다

보고는 `t3-3-q15`·`q16` 둘 다 「`pipelines-overview.html` → `build-and-manage-steps.html` 교체」로 적었다. 그런데 본문을 받아 보면 **`pipelines-overview.html` 은 `q15` 의 핵심 사실을 실제로 담는다**:

> "**The structure of a pipeline's DAG is determined by the data dependencies between steps.** These data dependencies are created when the properties of a step's output are passed as the input to another step."

`q15` 의 정답은 **「단계 사이의 데이터 의존성」**이므로 그 페이지가 **정답의 근거**다. 그 문항에서 아무 사실도 담지 않는 쪽은 **둘째 출처 `dg/pipelines.html`**(2,613자 · `DAG`·`data dependenc`·`interconnected steps` **전부 0건**)이었다. → **`q15` 는 `pipelines.html` 을 내리고 `q16` 은 제목이 거짓인 `pipelines-overview.html` 을 내렸다.** 보고를 그대로 따랐다면 **정답의 근거를 지웠다.**

### 3-2. ⚠️ `mlperf04-bp02.html` 은 같은 파일의 다른 문항이 **정당하게** 인용한다 — 전수 치환이 불가능했다

보고가 적지 않은 함정이다. `mla-t2-3.questions.json` 에서 그 URL 은 **2자리**이고, `mla-t2-3-q10`(정답 0)이 「비교용 단순 모델 baseline」의 근거로 든다. 치환 함수의 **횟수 단정이 `want=1` 에서 `got=2` 로 막아** 발견했다 → `q11` 의 **마지막 오답 근거까지 앵커를 넓혀** q11 만 바꿨다. 같은 이유로 새 가드의 §2-B 는 **전수 0건이 아니라 문항별 쌍**으로 단정한다(전수 0 으로 셀 수 있는 것은 교체 뒤 한 건도 안 남는 `mlrel03-bp04.html`·`dg/pipelines.html` 둘뿐이다).

### 3-3. ⭐ 보고 §2-B 각주를 **해소**했다 — 재훈련 조건 네 가지가 `mlperf06-bp05` 에 다 있다

보고는 「`t3-3-q24` 해설의 네 항목 묶음은 `mlperf06-bp05` 에서 **둘까지만 확인**했다. 나머지 둘의 출처는 2단계가 `mlsus06-bp02` 본문에서 확인할 것」이라 남겼다. 실측하니 **`mlperf06-bp05` 가 네 개를 한 문장에** 적는다:

> "…**business requirements**, **performance degradation beyond defined thresholds**, **detection of data drift above acceptable limits**, and **availability of new training data**."

(교차 확인: `mlsus06-bp02` 에는 `new training data` **0건**이다.) → 출처 교체 하나로 해설의 네 항목이 전부 근거를 얻었고, **`mlsus06-bp02` 를 지울 이유도 없어** 둘째 출처로 유지했다.

### 3-4. ⚠️⚠️ **내가 만든 회귀 1건을 기존 가드가 잡았고, 그것이 가드 설계를 바꿨다**

§1-7 의 해설을 「동시 실행은 Logs Insights QL이 계정당 100개…」로 쓰자 `mla_questions_test` 의 「2차 검수 출처 교체 2건이 반영됐다」가 **레드**가 됐다 — 그 가드가 `explanation` 에 리터럴 **`동시 쿼리 100개`** 를 **요구**한다(2026-11-06 판정: 「수치를 고치는 것이 아니라 그 근거를 단다」, 지금도 참이다).

- **처리**: 그 공유 파일을 고치지 않고(계약 §1) **해설 어순을 바꿔** 두 요구를 함께 만족시켰다 — 「**계정당 동시 쿼리 100개는** Logs Insights QL 기준이고(…) OpenSearch PPL과 SQL은 각 15개입니다.」
- ⭐ **그리고 내 가드를 금지형에서 요구형으로 뒤집었다** — 「`계정당 동시 쿼리 100개` 0건」이 아니라 **「`동시 쿼리` + `Logs Insights` 문맥이면 `QL` 과 `각 15` 를 함께 적는다」**. 어형에도 둔감해지고 기존 가드와 충돌하지 않는다.
- ⚠️ 트리거를 `동시 쿼리` 만으로 두면 `mla-t1-1-q18` 의 **Athena 워크그룹 동시 쿼리 수**가 걸린다 → 문맥으로 좁히고 **그 문항이 대상이 아님을 대조군으로 고정**했다.

### 3-5. ⚠️⚠️ **민감도 측정이 내 가드의 범위 결함을 잡았다 — 문항 단위는 너무 넓다**

1차 🔴 가드는 「**문항 어딘가**에 `일반` 또는 `추론 컴포넌트` 가 있으면 통과」였다. 민감도 측정에서 한정구를 깨뜨렸는데 **레드가 나지 않았다** — 같은 문항의 **다음 문장과 새 출처 제목**이 `추론 컴포넌트` 를 담고 있었기 때문이다. → **문장 단위**(`(?<=다\.)` 분할)로 좁혀 재측정하니 레드가 됐다. 세 자리 전부 문장 안에 한정구가 있다(실측 출력을 가드 주석에 남겼다).

### 3-6. ⚠️ Lambda 「900초」 탐지기는 **문맥 없이 쓰면 네 가지 다른 사실을 걷는다**

`Lambda` + `900초` 로 넓히면 **Firehose 버퍼 간격 0–900초**(`mla-t1-1.md`·`mla-t1-2.md`) · `InvocationTimeoutSeconds` 기본 900초(`mla-t3-1.md:157`) · Glue 배치 창 900초(`mla-t3-3.md`) · 쿨다운 900초(`mla-t3-2-q8`)가 전부 걸린다. → 트리거를 **함수 타임아웃 단정**(`타임아웃 상한|상한이 900초|타임아웃 **900초`)으로 좁혀 탐지 집합이 정확히 **`mla-t3-1-q22` 와 `mla-t3-1.md` 둘**임을 대조군으로 고정했다.

### 3-7. ✅ 보고가 **정확했던** 전수 수치 (2단계가 다시 재서 확인)

`최소 인스턴스가 1` 문항 3자리 ✓ · `대표 기간 30~90일` 문항 1 + md 1 ✓ · `계정당 동시 쿼리 100개` 문항 1 + md 1 ✓ · `data-parallel-config` 가 **이미 `mla-t2-2.md` 에 있다** ✓ · 과거형 자리 1 ✓ · A2I 문구 1자리 ✓ · 「미세 조정」 표기 잔존 **0건** ✓ · 범위 외 정답 2문항 ✓.

---

## 4. 남긴 것 — 다음 배치

| 묶음 | 분량 | 왜 넘기는가 |
|---|---|---|
| §3-1 (a) 교차 Task 실중복 **7쌍** | 문항 7개 본문 교체 | 보고 §7 이 **3·6번 뒤에** 하라고 적었다(교체가 방금 붙인 상태 문구를 지운다). ⚠️ 이 배치가 `t3-3-q24` 를 `mlperf06-bp05` 로 바꿔 **`t4-1-q28` 과 출처를 공유하게 됐다**(③ 쌍) — `mla_duplicate_fix_test` 의 전수 불변식(출처 공유 쌍의 정답 자카드 < 0.33)은 **통과를 실측했다**(그 쌍은 0.095/0.167). |
| §3-1 (b) 같은 Task 정답 누출 **9쌍** · (c) 겹침 **4묶음** | 해설·오답 근거에서 상대 정답 문장 걷기 | 문항 교체 없이 닫히지만 분량이 크고, (a) 와 같은 파일을 건드린다 |
| §3-5 길이 단서 **16문항** + 반대 방향 **39문항** | 보기 문구 전수 손질 | 보고가 **별 배치 권고**(SCS 는 같은 작업을 7배치로 했다) |
| §3-6 메타 문구 **60문항** | 지문의 자기 프레임 크러치 걷기 | 같음. 우선순위는 `t2-3`·`t3-1`·`t2-2` |
| §3-8 잔여 **5건** | `t3-3-q6` · `t2-3-q24` · `t1-3-q2` · `t3-3-q4` 의 출처 세부 | 낮은 우선순위(사실은 옳고 md 에는 이미 있다). `t4-3-q25`·`t4-2-q34` 두 건은 이 배치에서 닫았다 |
| G-84 부분집합 가드 | 문항 출처 ⊄ 같은 Task md 출처 **41개**(+이 배치 교체분은 md 에 등재했다) | 가드를 걸지 말지는 레포 정책 결정이다(SCS·AIP 에만 있다) |

**flip 준비 상태**: MLA 는 **321/321 이 이미 공개**돼 있어 flip 대상이 없다. 이 배치는 **라이브 결함 수정**이고, 새 가드는 계약 §3 대로 **`verified` 상태를 단정하지 않는다**(구조 단정으로 대신했다).

---

## 5. 컨트롤러 요청

- [ ] **(필수)** `test/mla_aif_question_propagation_test.dart` 의 `registered` 집합에 **`'mla_v2_fix_test.dart'`** 를 더해 주세요.
  - **이유**: 그 파일의 트립와이어(「MLA·AIF 가드가 새로 생기면 이 파일의 규칙을 채운다」)가 **설계대로 울렸다**. `flutter test test/mla_*` 의 유일한 실패이고 결함이 아니다.
  - **옮길 금지 문장은 없다**: 새 가드의 사실 단정은 전부 **md 12편 + 문항 12파일을 함께** 쓸고 있으므로(`_factRules`·`_nameRules` 가 비어 있는 그 파일의 기존 이유와 같다), 등록 목록에 이름만 더하면 된다.
- [ ] (선택) `test/mla_questions_test.dart` 의 `mmTaughtIds` 를 13 → **17**(+`mla-t4-1-q12`·`q13`·`q17`·`q18`)로 확장.
  - **지금도 레드는 아니다**(그 가드는 목록에 있는 것만 본다). 전수 보장은 새 가드가 더 넓게 하므로 **하지 않아도 무해**하다. 다만 두 가드가 같은 기준을 쓰게 하려면 함께 올리는 것이 낫다.
- [ ] **정답 인덱스 변경이 필요한 문항: 0건.**
- [ ] **사람 판정으로 넘기는 문항 2개** (보고 §7 순서 5 — 「판정 전에는 손대지 않는다」)
  - **`mla-t4-2-q32`**(정답 **0**, 라이브) — 지문이 「정책이 어떤 지표를 쓰는지」를 말하지 않아 이미 인스턴스당 호출 수를 쓰는 정책이면 정답이 성립하지 않고, 「**점검**할 것」을 물으면서 정답이 「**바꾼다**」(조치)다. ⚠️ **2단계가 공식을 다시 뒤졌지만 근거를 못 찾았다** — `endpoint-auto-scaling.html`(1,874자 목차) · `endpoint-auto-scaling-add-code-define.html`(`scale in` **0건**) · `endpoint-auto-scaling-policy.html` 에 「CPU 기반 정책은 트래픽이 줄어도 scale-in 하지 않을 수 있다」가 없다. 그 주장은 **`repost.aws` 지식 센터에만** 있고, 계약 §3-7 이 `repost.aws` 를 근거로 쓰지 못하게 한다. 선택지는 ⓐ 지문에 「대상 추적 정책은 사용자 지정 지표 `CPUUtilization` 을 쓴다」를 넣고 **근거가 re:Post 뿐임을 감수** ⓑ 공식 docs 가 적는 사실로 **문항 교체**.
  - **`mla-t2-1-q18`**(정답 **1**, 라이브) — ① 첫 출처 `canvas-manage-cost.html`(5,500자)이 적는 것은 「Canvas 안에서 Ready-to-use 모델은 기반 서비스 요금, 사용자 지정 모델은 리소스 사용량」뿐이고 「건수가 늘면 자체 호스팅과 비교하라」는 **어느 인용 페이지에도 없다** ② `W3` 이 **지문에 없는 가정**(「새로 들어오는 사진이 대부분이면」)에 기댄다. **재작성 방향이 둘**이라(지문을 인용 페이지가 적는 사실로 좁히기 ↔ 지문에 조건을 넣어 보기 2·3을 배제하기) 보고가 사람 판정으로 남겼다.
- [ ] (참고) **교차 자격증 — MLA 쪽만 고쳤다.** 보고 §5 의 1·2·3번이 다른 자격증에서도 같은 문구를 쓴다(grep 실측은 1단계 보고에 있다):
  - **Lambda 타임아웃 예외** — `saa/saa-t3-4.questions.json:46` 이 「최대 900초(15분)」을 단정한다(MLA 와 같은 상태였다). `saa-t2-2.md` 는 이미 예외를 적는다. `dea`·`dva`·`scs` 는 미판정(`900초` 포함 파일 수: dea 7 · dva 2 · scs 2 — Lambda 문맥인지 미확인).
  - **Logs Insights 동시 쿼리** — `aip`·`dva`·`scs` 는 **이미 「QL 100 / PPL·SQL 각 15」로 적는다**(MLA 만 뒤처져 있었고 이 배치로 맞췄다).
  - **S3 VPC 엔드포인트 두 유형** — SAA 는 2026-10-28 에 이미 고쳤다. MLA 가 마지막이었다.

---

## 6. 민감도 측정 (계약 §3 — `git stash` 대신 「깨뜨리고 sha256 으로 복구 증명」)

| 깨뜨린 자리 | 레드 | 걸린 테스트 | 복구 sha256 동일 |
|---|---|---|---|
| 🔴 §1 0대 축소 한정(`mla-t3-2.questions.json`) | ✅ | 🔴 §1 전수: 「최소 인스턴스가 1」은 일반 변형 한정과 함께 쓴다 | ✅ |
| §2-B md 출처 등재(`mla-t3-3.md`) | ✅ | §2-B: 새 정본 URL 6개가 같은 Task md 프런트매터에 등재됐다 | ✅ |
| §2-B 문항 출처 교체 2자리(`mla-t1-3.questions.json`) | ✅ | §2-B: 그 사실을 담지 않던 출처가 정본으로 바뀌었다 (8문항) | ✅ |
| §2-C Access Analyzer 권고(`mla-t4-3.questions.json`) | ✅ | §2-C 전수: Access Analyzer 분석 기간은 공식 권고대로 적는다 | ✅ |
| §2-C `q33` 귀속을 옛 문구로 되돌림(`mla-t4-2.questions.json`) | ✅ | §2-C mla-t4-2-q33: 귀속을 문서에서 블로그로 바로잡았다 | ✅ |
| §2-D Role Manager 상태(`mla-t4-3.questions.json`) | ✅ | §2-D: Debugger 2문항 · Role Manager 1문항에 정본 문구가 있다 | ✅ |
| §3-7 범위 메모(`mla-t3-2.questions.json`) | ✅ | §3-7: 범위 외 서비스가 정답인 2문항에 범위 메모가 붙었다 | ✅ |
| 참고 — §2-D Model Monitor 상태(`mla-t4-1.questions.json`) | ✅ | §2-D Model Monitor 17문항 **+** §3-9 괄호 보충 전수 **2건 동시** | ✅ |

측정 전·후 모두 `flutter test test/mla_v2_fix_test.dart` → **20/20 통과**.

### 새 가드 20건의 구성

대조군 2(문항 321개·md 12편을 읽는다 / 구조 불변) · 🔴 2 · §2-A 2 · §2-B 3 · §2-C 2 · §2-E 1 · §2-D 2 · §3-9 1 · §3-2 1 · §3-3 1 · §3-4 1 · §3-7 1 · §3-8 1.

규율: **사실 단정은 전수 집계형**(문장·줄 단위까지 좁힘) · **출처 URL 은 문항별 쌍**(어형이 없다) · **「옛 문구 0건 + 새 공식 사실 있음」을 쌍으로** · **`verified` 를 단정하지 않고 구조로 대신** · **탐지기가 정정문·인접 사실을 걷지 않는지 대조군으로 고정**(Athena 동시 쿼리 · Firehose 900초 · 「단정할 수 없고」 · 「새로 만든 계정」 3문항 · md 의 정당한 `mlrel03-bp04` 인용).
