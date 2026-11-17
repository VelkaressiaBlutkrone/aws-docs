# MLA-C01 2단계 보정 — 2026-11-17

> 집행한 1단계 보고서: `mla.md` · 계약: `01-PHASE2-CONTRACT.md` · 세션: `fix2-mla`(Fable 5.2)
> 브랜치 `content/phase2-fable-2026-11-17` 의 **작업 트리 변경**이다. 커밋·flip 은 하지 않았다.
> ⚠️ `01-PHASE2-CONTRACT.md` 는 **이 브랜치에 없다**(커밋 `8884494`, `content/phase2-fix-2026-11-17` 에만 있다). `git show 8884494:…` 로 읽었다 — §5 컨트롤러 요청 참조.

## 0. 요약

- **1단계의 🔴 1 · 🟡 23문항 대비**: 🔴 **1/1 채택** · 🟡 **22/23 채택**(그중 6건은 수정안을 바꿔서 채택 — §2) · **1건 유지**(`mla-t4-1-q3`, 사람 판정) · **범위 확장 2계열**(문항 +2 · md +3자리 — §3)
- 🟢: §3-2 메모 **4** · §3-3 오답 근거의 상태 **3** · §3-7 범위 **2** · §3-8 출처 세부 **5** · §3-4 곁가지 **1** 을 닫았다. 남긴 것은 맨 아래.
- **손댄 파일**: 문항 **11파일 39문항 54필드** · md **7편** · 가드 **1**(`test/mla_v2_fix_test.dart`)
- **정답 인덱스 변경: 0건** · `verified`·`options`·`skill`·`section`·`difficulty`·`id` 변경 0줄 (`git diff -U0 | grep` 실측 0)
- **새 가드 테스트 수: 44건** · 민감도: ① 수정 전 콘텐츠에서 **8 통과 / 36 실패**(통과 8건은 전부 대조군) ② 수정 후 문구 8곳을 임시로 깨서 **12건 레드** 확인 → 복구 후 `mla/*` 24파일 sha256 전부 동일
- **테스트**: `test/mla_*` 7파일 **247 통과 · 1 실패**(실패 1 = `mla_aif_question_propagation_test` 트립와이어 — 설계된 장치, §5) · 내 콘텐츠를 읽는 공유 가드 5파일(`dea_mla_p1_review_fix` · `whitepaper_resourcing` · `content_format` · `all_content_parse` · `source_url_retired`) **255 통과** · `flutter analyze test/mla_v2_fix_test.dart` **0건**
- `node tool/prescreen.mjs build mla`(보정 후): 구조·정합성 **0건** · 품질 신호 **74/321**(보정 전 75) — `length-cue` 16 · `meta-phrasing` 59(−1) · `authoring-memo` 0 · `explanation-long` 0. **내 문구가 새로 만든 신호 0건.**
- **남긴 것(다음 배치)**: 🟢 §3-1 중복·누출 전부(교차 Task 실중복 7쌍 · 같은 Task 누출 9쌍 · 교차 겹침 4묶음) · §3-4 Clarify 6문항(기준 결정 필요) · §3-5 길이 단서 · §3-6 메타 문구 59문항 · §3-8 `mla-t1-3-q2` · §3-9 전부 · 사람 판정 4건

### 치환 방법 (계약 §2 「치환 기법」 준수 기록)

- 문항 JSON 은 **왕복 재직렬화하지 않았다.** 바뀌는 필드의 원시 텍스트만 잘라 끼웠다(문항 span 안에서 치환 횟수 == 1 단정).
- **대조군을 먼저 통과시켰다** — 12파일 **321문항 전부**에서 `skill`·`section`·`difficulty`·`stem`·`explanation`·`wrongExplanations` 각 항목·`sources` 블록(다중 행)이 내 렌더러로 **바이트 단위 재현**됨을 확인한 뒤에만 썼다.
- 사후 검증: 다시 파싱해 **바뀐 (문항, 필드) 집합 == 의도한 54개**(초과·누락 0) · CR 수 == LF 수 · 고립 CR/LF 0 · `"verified"` 는 치환 범위 밖.
- 하나라도 어긋나면 **아무 파일도 쓰지 않게** 짰다(dry-run → scratchpad staged 본 → 실제 쓰기 → staged 본과 `cmp` 일치).
- 손댄 문항 파일 11개는 `lastVerified` 를 `2026-10-26` → `2026-11-17` 로 올렸다(1단계가 오늘 382개 출처 본문을 전부 받아 대조했고, 내가 고친 자리는 다시 쟀다). md 7편도 올렸다.

---

## 1. 채택 — 무엇을 어떻게 고쳤는가

공식 근거는 전부 2026-11-17 에 `curl -sL` 로 본문을 받아 **공백을 `\s+` 로 접은 텍스트**에 정규식으로 다시 쟀다(전부 `200 r=0`). 대조군: 없는 슬러그 `sagemaker/latest/dg/zz-bogus-control.html` → `200 r=1`·본문 21자.

### 🔴 `mla-t3-2-q10` (정답 0 불변) — 「실시간 엔드포인트는 최소 1대」의 거짓 일반화

- 공식 `sagemaker/latest/dg/endpoint-auto-scaling-zero-instances.html`: "It hosts one or more inference components. **An endpoint can scale to and from zero instances only if it hosts inference components.**"
- `W3` → 「추론 컴포넌트를 쓰지 않는 **일반 프로덕션 변형**은 최소 인스턴스가 1 이상이어야 하고 … (0대까지 줄일 수 있는 것은 추론 컴포넌트를 호스팅하는 엔드포인트뿐입니다). 온디맨드로 묶을 수 없습니다.」
- `explanation` 끝 문장 → 「이 차이가 스케일링 정책을 직접 관리해야 하는지를 갈라 놓습니다. 요청이 없을 때 서버리스는 0으로 줄어들지만 실시간 엔드포인트의 일반 프로덕션 변형은 최소 1대를 유지하며, 0대까지 줄일 수 있는 것은 추론 컴포넌트를 호스팅하는 엔드포인트뿐입니다.」
- 출처에 그 사실을 담는 페이지(`endpoint-auto-scaling-zero-instances.html`)를 **추가**했다(1단계 수정안에는 없던 것 — 고친 문장의 근거가 기존 두 출처에 없다).
- 전수(문항 사실 필드 + md): 「최소 1」 단정 **문항 4필드 · md 2줄**, 전부 「일반」 또는 「추론 컴포넌트」 한정이 붙어 있다.

### 🟡 2-A 정답 유일성·지문 조건

| 문항(정답) | 판정 | 고친 것 | 공식 근거(실측 인용) |
|---|---|---|---|
| `mla-t4-3-q22`(0) | 채택 | 지문에 가름 조건 「**엔드포인트 자체에 추가 요금이 붙지 않는 방식으로** S3 경로를 열려면」. `W1` → 「S3는 인터페이스 엔드포인트도 지원하지만 그쪽은 추가 요금이 붙습니다. 추가 요금이 없는 것은 라우트 테이블에 연결하는 게이트웨이 엔드포인트이고, SageMaker 훈련용 VPC 문서가 안내하는 구성도 이쪽입니다.」 md `mla-t4-3.md` 시험 포인트 1줄(「둘을 바꿔 고르면 틀립니다」)도 완화 | **문항이 이미 달고 있던 둘째 출처** `vpc/latest/privatelink/vpc-endpoints-s3.html`: "There is no additional charge for using gateway endpoints. **Amazon S3 supports both gateway endpoints and interface endpoints.** … you must use an interface endpoint, which is **available for an additional cost**." |
| `mla-t3-1-q22`(0) | 채택 | 지문 「표준 AWS Lambda 함수(Lambda Managed Instances가 아닌 함수)」 · 해설에 예외 한 줄 · `W2` 「표준 Lambda 함수의 상한이 900초」 · md `mla-t3-1.md` 표 1칸 | `lambda/latest/dg/gettingstarted-limits.html`: "Function timeout 900 seconds (15 minutes). For functions using AWS Lambda Managed Instances, asynchronous invocations and event source mapping invocations (except Amazon MQ and Amazon DocumentDB) support a maximum allowed value of **5,400 seconds (90 minutes)**." |
| `mla-t4-2-q32`(0) | 채택(수정안 변경 — §2-②) | 지문에 「대상 추적 정책은 사용자 지정 지표인 CPUUtilization을 쓰고 있고, 트래픽이 줄어든 뒤에도 이 값은 목표값 아래로 내려가지 않았다. 가장 먼저 **검토할 조치**는」. 해설을 **공식 문서 두 개로** 다시 세움. 출처 4개(docs 3 + re:Post 「보조 출처」) | `autoscaling/application/userguide/target-tracking-scaling-policy-overview.html`: "The metric must be a valid utilization metric and describe how busy a scalable target is. The metric value must increase or decrease proportionally to the capacity of the scalable target" · `sagemaker/latest/dg/multi-model-endpoints-autoscaling.html`: "We strongly recommend using this metric." |
| `mla-t2-1-q18`(1) | 채택(최소 수정) | 지문에 「사진은 모두 새로 촬영된 것이어서 같은 이미지를 다시 분석하는 일은 없다」(오답 근거 `W3` 의 전제를 지문에 넣음) · 해설에서 근거 없는 일반화 「호출당 과금은 소량이고 변동이 큰 수요에서 유리」 삭제 · `W3` 를 지문 조건에 맞춤 | `canvas-manage-cost.html`: "When you use a Ready-to-use model, you are charged by the respective service" · `aws.amazon.com/rekognition/pricing/`: "Usage is billed based on a tiered pricing model tied to volume of images processed per month" |

### 🟡 2-B 「URL 은 200인데 그 페이지에 그 사실이 없다」 — 8문항 전부 채택

1단계가 적은 「옛 페이지 0건 · 새 페이지에 있음」을 **8건 모두 다시 재서 같은 결과**를 얻었다(대조군 포함).

| 문항(정답) | 걷은 출처 → 단 출처 | 재측정 |
|---|---|---|
| `mla-t1-3-q8`(1) · `q24`(2) | `mlrel03-bp04` → `aws.amazon.com/what-is/ai-bias/` | 옛: `label bias`·`recall`·`unconscious` 0건(대조군 `selection bias` 1). 새: "Label AI bias is when a data annotator unconsciously introduces bias…" · "Selection AI bias occurs when…" · "Recall bias occurs when…" · "Algorithm bias is a misconfiguration of an AI system's model architecture" |
| `mla-t2-2-q3`(1) | `distributed-training-strategies` → `data-parallel-config.html` | 옛: `learning rate`·`proportion` 0(대조군 `batch size` 9). 새: "as more nodes are added, batch sizes should increase proportionally … increase the learning rate … Linear Scaling Rule" |
| `mla-t2-3-q11`(1) | `mlperf04-bp02` → `machine-learning/latest/dg/evaluating_models.html`(**구서비스 라벨**) | 새: "…it rewards models that can "remember" the training data, as opposed to generalizing from it." 첫머리 "We are no longer updating the Amazon Machine Learning service or accepting new users for it" |
| `mla-t3-2-q5`(0) | 두 출처 **모두** 교체 — §2-③ | `multi-model-endpoints-autoscaling.html`: "We strongly recommend using this metric." · `endpoint-auto-scaling-add-code-define.html`: "Standard metrics, such as the InvocationsPerInstance metric, emit data once every minute." |
| `mla-t3-3-q15`(0) | **교체가 아니라 추가** — §2-④ | `build-and-manage-steps.html`: "When a step does not depend on any other step, it runs immediately upon pipeline execution … `ParallelismConfiguration`" · "You create a custom dependency by specifying a step's `DependsOn` attribute." |
| `mla-t3-3-q16`(0) | 같은 페이지 추가 + 첫 출처 **제목**에서 그 페이지에 없는 「병렬 실행, DependsOn」 삭제 | 같은 페이지: "Pipelines throws a validation exception if the dependency would create a cyclic dependency."(`W2` 의 근거) |
| `mla-t3-3-q24`(0) | `mlops04-bp01` → `mlperf06-bp05.html` | "Retraining on a fixed schedule regardless of model performance or data patterns." · ⭐ **1단계가 남긴 확인 항목을 닫았다** — 네 조건이 **전부 이 페이지에** 있다: "These can include **scheduled intervals** based on business requirements, **performance degradation** beyond defined thresholds, detection of **data drift** above acceptable limits, and **availability of new training data**." |

교체 정본 URL 은 같은 Task 학습문서의 「📌 출처」 번호 목록 끝에 덧붙였다(`mla-t1-3` 45 · `mla-t2-3` 58 · `mla-t3-2` 44 · `mla-t3-3` 57·58 · `mla-t4-2` 76·77. `mla-t2-2` 는 이미 있었다). ⚠️ 프런트매터 `sources:` 는 9~15개짜리 **선별 목록**이고 본문 목록(43~81개)과 원래 동기되어 있지 않아 **건드리지 않았다**(1단계는 「둘 다에 추가」를 권했다 — §2-⑤).

### 🟡 2-C 귀속

| 문항(정답) | 판정 | 고친 것 |
|---|---|---|
| `mla-t4-3-q8`(0) | 채택 | 해설 끝 → 「공식 문서는 정책 생성 시간을 줄이도록 분석 기간을 가능한 한 짧게 고르라고 권합니다. 넓은 정책을 이렇게 생성한 정책으로 교체해 권한을 좁힙니다.」 md `mla-t4-3.md` 1줄. 공식: "You can choose a range of up to 90 days. **We recommend that you choose the shortest time period possible** to reduce the policy generation time." (`30 days`·`representative` 0건, 대조군 `90 days` 2) |
| `mla-t4-2-q33`(0) | 채택(**1단계 「확인되지 않음」을 뒤집음** — §2-①) | 지문에서 거짓 귀속 「SageMaker 추론 비용 최적화 모범 사례에서」 삭제(시나리오형). 해설 「문서가 제시하는 순서는」 → 「AWS 규범 가이드는 …」. 출처 첫 자리에 공식 근거, 블로그는 「보조 출처」 |

### 🟡 2-D 닫힌 기능의 상태 — 7문항 전부 채택

**정책 결정 하나를 내렸다**: Model Monitor 4문항(`mla-t4-1-q12`·`q13`·`q17`·`q18`)에 상태를 **단다.** 근거 — 네 문항이 인용하는 페이지(`model-monitor-interpreting-violations` · `model-monitor-model-quality-schedule` · `model-monitor-model-quality-merge`)가 **각자 첫머리 Note** 로 "…is no longer open to new customers" 를 적는다(4페이지 전부 실측 1건). 같은 층의 `q9` 는 이미 달려 있었다. 기준은 가드에 **출처 URL 규칙**으로 적었다(문자열 규칙은 이 4건을 영원히 못 본다).

| 문항(정답) | 붙인 문구 |
|---|---|
| `mla-t2-3-q14`(1) · `q15`(1) | 「⚠️ Debugger는 현재 신규 고객을 받지 않습니다(기존 고객은 사용 가능).」 — 인용 페이지 `debugger-built-in-rules.html` 자신의 Note |
| `mla-t4-1-q12`·`q13`·`q17`·`q18`(0) | 「⚠️ Model Monitor는 현재 신규 고객을 받지 않습니다(기존 고객은 사용 가능).」 — 기존 13문항과 **글자 그대로 같은** 정본 문구 |
| `mla-t4-3-q10`(0) | 지문 「제공하던」→「제공하는」 · 해설 「제공했습니다」→「제공합니다」 + 「⚠️ Role Manager는 현재 신규 고객을 받지 않습니다(기존 고객은 사용 가능).」 — `role-manager-personas.html` 이 지금도 세 페르소나를 싣고 Note 로 상태를 적는다 |

⚠️ `mla-t2-3-q14` 는 `2.3 K5` 의 유일한 문항 — 해설 끝에 한 줄만 붙였고 본문은 그대로다. `q15` 는 기존 `mla_duplicate_fix_test` 가 요구하는 `20`·`추가 비용` 을 유지한다(새 가드가 다시 단정).

### 🟡 2-E `mla-t4-2-q11`(0) — 채택(문구 변경 — §2-⑥)

해설 → 「Logs Insights는 **Logs Insights QL 기준** 계정당 동시 쿼리 100개(**OpenSearch PPL·SQL은 각 15개**), …」 · 둘째 출처 제목 「StartQuery API — Logs Insights 동시 쿼리 100개」 · md `mla-t4-2.md` 표 1칸. 공식 `AnalyzingLogData.html`(이 문항의 첫 출처): "You are limited to 100 concurrent CloudWatch Logs Insights QL per account, including queries added to dashboards. Additionally, you can run 15 concurrent queries for either OpenSearch Service PPL or OpenSearch Service SQL."

### 🟢 닫은 것

| 절 | 문항(정답) | 고친 것 |
|---|---|---|
| 3-2 | `mla-t2-2-q17`(1) | 출처 제목의 저작 메모 삭제 → 「…Renate — 보조 출처(AWS 블로그), 치명적 망각의 정의」 |
| 3-2 | `mla-t4-1-q23`(0) | `W1` 둘째 문장 → 「소켓 오류나 요청 타임아웃처럼 4xx 응답으로 돌아오지 않는 실패는 여기에 잡히지 않습니다.」(공식 `monitoring-cloudwatch.html`: Invocation4XXErrors = "requests where the model returned a 4xx HTTP response code") |
| 3-2 | `mla-t4-1-q27`(0) · `mla-t4-2-q14`(0) | 메모 문장 삭제(「…이 수준까지만 봅니다」 · 「확인된 연동 예는 …」 — 뒤쪽은 인용 두 페이지에 `Athena` 0건 재확인) |
| 3-3 | `mla-t3-3-q23`(0) | `W2` 의 「게다가 이 단계는 신규 고객에게 닫힌 Model Monitor 컨테이너를 씁니다.」 삭제 |
| 3-3 | `mla-t4-2-q18`(0) | `W2` → 「CloudTrail Lake는 이 경로의 전제 조건이 아닙니다. EventBridge가 받는 것은 추적이 기록한 API 호출 이벤트이므로 필요한 것은 추적입니다.」 |
| 3-3 · 3-8 | `mla-t4-2-q34`(0) | `W1` → 「Profiler 공지의 역량 대응표가 시스템 자원 모니터링의 대체로 드는 것은 CloudWatch이며 Debugger는 그 표에 없습니다.」(`profiler-availability-change.html` 실측: `Debugger` 2건은 코드 import 경로뿐) · 해설의 「100밀리초 단위 프로파일링」 삭제(인용 두 페이지 0건). 상태는 해설에 남겼다 |
| 3-4 | `mla-t1-2-q19`(1) | 「⚠️ A2I는 현재 신규 고객을 받지 않습니다**(기존 고객은 사용 가능)**.」 — 인용 페이지 Note: "Existing customers can continue to use the service as normal." 이로써 이 문구 22자리가 전부 같은 형식 |
| 3-7 | `mla-t4-3-q27`(0) · `mla-t3-2-q20`(0) | 해설 끝에 범위 메모 한 줄(공식 ko 「범위 외 AWS 서비스」에 `AWS Artifact`·`Amazon Inspector` 실재 재확인). 문항은 지우지 않았다 |
| 3-8 | `mla-t4-3-q25`(0) | 근거가 사라진 둘째 문장(「…CloudTrail과 Config가 함께 쓰입니다」) → 「API 호출 기록이나 구성 변경 이력은 실제 트래픽을 보여 주지 않습니다.」(인용 페이지 `CloudTrail` 0건 · `flow logs` 3건 재확인) |
| 3-8 | `mla-t3-3-q6`(0) · `mla-t3-3-q4`(0) · `mla-t2-3-q24`(0) | 세부를 담는 페이지를 출처에 **추가**: `codepipeline/…/limits.html`("…polling for source changes, per AWS Region 300 … This quota is fixed and cannot be changed") · `codepipeline/…/approvals.html`(SNS 19건) · `shadow-tests-create.html`("The default duration is 7 days and the maximum is 30 days" · "The minimum duration is 1 hour") |

---

## 2. 기각·변경 — 1단계 수정안을 그대로 쓰지 않은 자리

**통째로 기각한 🔴·🟡 는 없다**(1단계의 사실 판정은 전부 재현됐다). 수정안을 바꾼 자리와 이유:

1. **`mla-t4-2-q33` — 「공식 docs 에서 확인되지 않았다」를 뒤집었다.** 1단계는 「Savings Plans 전에 right-size」가 블로그에만 있다고 보고 ⓐ(귀속을 「블로그가」로) / ⓑ(문항 교체)를 사람 판정으로 넘겼다. AWS 문서 검색으로 **공식 docs 문장을 찾았다** — `docs.aws.amazon.com/prescriptive-guidance/latest/optimize-costs-microsoft-workloads/savings-plans.html`(200 r=0 · 20,029자): "We recommend that you do the following before you purchase Savings Plans: Use AWS Trusted Advisor to identify and remove idle Amazon EC2 resources. **Right size your resources before you purchase Savings Plans.** Establish an hourly usage rate that you consistently maintain for 30–60 days." 그래서 귀속을 「AWS 규범 가이드는」으로 고치고 이 페이지를 첫 출처로 달았다. ⚠️ **한계** — 이 가이드는 「Windows on Amazon EC2」 비용 최적화 문서다(같은 페이지가 Savings Plans 유형에 SageMaker AI 를 든다). 문장은 Savings Plans 일반 권고지만 **SageMaker 전용 문서의 문장은 여전히 없다.** 유지·교체는 사람 판정으로 남긴다(§5).
2. **`mla-t4-2-q32` — 조건만 넣지 않고 근거를 공식 문서로 옮겼다.** 「CPU 활용률 기반 정책은 트래픽이 줄어도 scale-in 하지 않을 수 있다」는 지금도 re:Post 에만 있다(AWS 문서 검색 재확인 — 1위가 그 re:Post). 그래서 그 **주장을 걷고**, 지문이 관측 사실(「이 값은 목표값 아래로 내려가지 않았다」)을 주게 한 뒤 해설을 공식 두 문장(대상 추적 지표의 요건 + SageMaker 의 강력 권장 지표)으로 세웠다. re:Post 는 「보조 출처」로 강등. re:Post 에만 있던 세부(「워밍업 중인 인스턴스는 집계 지표에 포함되지 않는다」)와 인용 페이지가 담지 않는 비동기 지표 문장은 삭제했다.
3. **`mla-t3-2-q5` — 둘째 출처도 교체했다.** 1단계는 첫 출처만 교체하라고 했지만 둘째(`target-tracking-scaling-policy-overview`, 제목 「SageMaker 사전 정의 지표 목록」)에도 `SageMakerVariantInvocationsPerInstance` 가 **0건**이다(1단계 본문도 그렇게 적었다). 사전 정의·사용자 지정 지표와 「표준 지표 1분 주기」를 실제로 담는 `endpoint-auto-scaling-add-code-define.html` 로 바꿨다.
4. **`mla-t3-3-q15` — 「교체」가 아니라 「추가」다.** 첫 출처 `pipelines-overview.html` 은 **정답의 근거를 담는다**("The structure of a pipeline's DAG is determined by the data dependencies between steps"). 틀린 것은 해설 뒷부분(병렬·`DependsOn`·`ParallelismConfiguration`)의 근거가 없다는 것뿐이라 그 페이지를 **더했다.** 교체했다면 정답의 출처를 지웠다.
5. **md 프런트매터 `sources:` 에는 추가하지 않았다.** 1단계는 「프런트매터와 본문 목록에 함께」를 권했으나 실측하면 프런트매터는 선별 목록(9~15개)이고 본문 번호 목록(43~81개)의 부분집합이다 — 문항 출처를 프런트매터에 넣는 관례가 이 자격증에 없다. 본문 목록 끝에만 붙였다.
6. **`mla-t4-2-q11` — 수정안 문구를 그대로 쓰면 기존 가드가 깨진다.** `mla_questions_test.dart` 가 해설에 `동시 쿼리 100개` 문자열을 요구한다(2026-10-29 「수치를 고치지 말고 근거를 달라」는 판정). 그 문자열을 유지한 채 QL 한정과 15개를 넣었다.
7. **`mmTaughtIds` 13 → 17 은 하지 않았다.** 그 목록은 `test/mla_questions_test.dart` 에 있고 계약 §1 의 「고쳐도 되는 것」(콘텐츠 + 새 가드 1파일) 밖이다. 대신 새 가드가 **URL 규칙**으로 4문항을 고정한다. 목록까지 맞추려면 §5 요청.
8. **§3-4 ⓐ(Clarify 6문항에 상태 붙이기)는 집행할 수 없다.** `mla_aif_p2_review_fix_test.dart` 의 대조군이 「`mla-t1-3-q1` 의 가르치는 층에 `Clarify` 가 없다」를 고정한다 — 그 문항 해설에 Clarify 상태 문구를 붙이면 그 대조군이 깨진다. 기준(ⓐ/ⓑ)은 사람 판정이고, ⓐ를 고르면 그 가드부터 고쳐야 한다(공유 파일은 아니지만 기존 판정을 뒤집는 일이라 손대지 않았다).

**유지(고치지 않음)**: `mla-t4-1-q3`(0) — 지문이 「AWS 블로그가 …」로 귀속을 정직하게 밝히고 본문이 블로그와 일치한다. 공식 docs 에서 covariate/label/concept shift 3분류의 정의를 다시 찾아봤지만(AWS 문서 검색) 결과는 블로그 2건뿐이었다. 사실 오류가 아니라 출처 등급 문제이고 유지·교체는 사람 판정이다.

---

## 3. 범위 확장 — 보고가 하한이던 자리

| 계열 | 1단계 | 전수 실측 | 추가로 고친 것 |
|---|---|---|---|
| **지문이 「문서가」로 귀속하는데 1차 근거가 re:Post** | `t4-2-q32` 1문항(+블로그 `q33`) | re:Post 를 인용하는 문항 **8개**, 그중 re:Post 가 첫 출처이면서 지문이 「문서가/공식 문서가」로 귀속하던 것 **+2** | `mla-t4-2-q7`(0): 지문 「문서가 제시하는」 삭제 + 공식 근거를 첫 출처로 추가 — `monitoring-cloudwatch.html` 의 OverheadLatency 정의 "can vary depending on multiple factors, including request and response payload sizes, request frequency, and authentication/authorization of the request" · `mla-t3-1-q24`(0): 지문 「공식 문서가 안내하는」 삭제(로컬 모드 절차는 re:Post 지식 센터에만 있다 — 둘째 출처 `inference-cost-optimization.html` 에 `local mode`·`notebook instance` 0건) |
| **「Savings Plans 전에 right-size」 md** | md 1자리(자가 점검 Q7) | **4자리**(`mla-t4-2.md` :407 · :474 · :561 · Q7) | 「**문서의** 순서는」으로 귀속하던 :561 을 「AWS 규범 가이드의 권고 순서는」으로. 나머지 3자리는 귀속 없이 사실만 적어 그대로 두고, 근거 URL 을 md 출처에 추가 |
| **Lambda 900초** | 문항 1 · md 1 | 같다(문항 1 · md 1). ⚠️ 문항 단위로 「900초 + Lambda」를 세면 `mla-t3-2-q8`(쿨다운 보기 900초 + 오답 근거의 Lambda 프로비저닝된 동시성)이 걸린다 — **거짓 양성**이라 가드를 필드 단위(「900초」+「타임아웃」)로 좁히고 대조군으로 고정 | — |
| **닫힌 서비스 상태** | 7문항 | Lifecycle 세 페이지(maintenance·sunset·full shutdown, 오늘 재수집)의 ML 관련 이름으로 **가르치는 층 전수 재스캔** — 추가 누락 **0**. 후보로 걸린 `t4-3-q5·q6·q9`(`skill` 에만 Role Manager) · `t4-3-q3`(Role Manager FAQ 를 IAM 개념 출처로) · `t2-1-q23`(상태 있음: 「신규 온보딩이 불가」) · Comprehend 3문항(유지 관리는 Topic Modeling·Event Detection·Prompt Safety 뿐, PII 는 정상) · `t3-3-q6` CodeCommit(세 목록에 없음)은 읽고 **대상 아님**으로 판정 | — |

---

## 4. flip 준비 상태

해당 없음 — MLA 는 321/321 이 이미 공개 상태다(이 배치는 flip 을 건드리지 않았다). 고친 39문항은 **지금 라이브에 노출되는 문항의 핫픽스**이므로 머지·배포되면 바로 학습자에게 보인다.

---

## 5. 컨트롤러 요청

- [ ] **`test/mla_aif_question_propagation_test.dart` 의 `registered` 에 `mla_v2_fix_test.dart` 등재** — 트립와이어가 설계대로 레드다(`test/mla_*` 247 통과 · 1 실패의 그 1건). 새 가드의 금지 규칙은 **전부 문항까지 함께 쓴다**(md 줄 + 문항 사실 필드를 한 단정에서 센다: 최소 인스턴스 · Lambda 900초 · Logs Insights 동시 쿼리 · 「대표 기간」 · S3 인터페이스 엔드포인트 부정) → `_factRules` 로 옮길 규칙은 없고 **등록만** 하면 된다. 그러면 그 파일의 「대조군: 지금 옮겨 온 규칙이 없다」도 그대로 통과한다.
- [ ] **`CLAUDE.md` 기준선 +44**(`mla_v2_fix_test.dart` 44건).
- [ ] **`docs/audits/2026-11-17-full-verify/01-PHASE2-CONTRACT.md` 를 이 브랜치로 가져오기** — 커밋 `8884494`(`content/phase2-fix-2026-11-17`)에만 있다. 이 브랜치는 `f9f2609` 에서 갈라져 그 파일이 없다.
- [ ] (선택) `test/mla_questions_test.dart` 의 `mmTaughtIds` 에 `mla-t4-1-q12`·`q13`·`q17`·`q18` 추가(13 → 17) + 그 주석의 「대상은 … 23문항 … 문자열」 서술 갱신. 추가해도 기존 테스트는 통과한다(네 문항 모두 정본 문구를 갖는다).
- [ ] **교차 자격증 — Lambda 타임아웃 「최대 900초」 무한정 단정**(2026-11-17 17시대 작업 트리 스냅샷 grep, 다른 세션이 이미 고쳤을 수 있다): `saa/saa-t3-4.questions.json` :50(오답 근거) · :102 · :200(출처 제목 「함수 제한 시간 최대 900초(15분)」) · `dea/dea-t1-2.questions.json` :33(출처 제목). `dea/dea-t3-1.md:221` 은 「**일반** Lambda 함수」로 이미 한정돼 있다. `dva/dva-t1-2.md:60` 은 짝 암기 줄(「타임아웃 3초/900초」)이라 판정하지 않았다.
- [ ] **교차 자격증 — 다른 세션이 쓸 수 있는 공식 근거**: 「Savings Plans 구매 전에 right-size」의 docs 문장(위 §2-①의 규범 가이드 URL) · 「대상 추적 지표는 용량에 비례해 오르내려야 한다」(Application Auto Scaling 사용자 가이드).
- [ ] **정답 인덱스 변경이 필요한 문항: 없음.**
- [ ] **사람 판정으로 남긴 것**
  - `mla-t4-1-q3` — 블로그 단독 출처. 유지(귀속이 정직) / 공식 2분류(데이터·개념 드리프트, `mlperf06-bp04`)를 묻는 문항으로 교체.
  - `mla-t4-2-q33` — 공식 근거를 달았지만 Windows on EC2 규범 가이드다(§2-①). 이대로 유지 / `inference-cost-optimization.html` 이 직접 적는 사실로 교체.
  - `mla-t4-2-q32` — 공식 원리 두 개로 세웠지만 「CPU 지표가 트래픽을 따라 내려가지 않는」 상황 자체는 지문이 준 관측이다. 유지 / 교체.
  - `mla-t2-1-q18` — 최소 수정으로 닫았다. 1단계가 제안한 「Canvas 과금 기준을 묻는 문항으로 재작성」을 할지.
  - §3-4 Clarify 6문항의 상태 기준(ⓐ 붙인다 → `mla_aif_p2_review_fix_test` 대조군 수정 필요 / ⓑ 명시 제외).
  - §3-9 Data Wrangler 접근 경로 메모 · MLA 에 「문항 출처 ⊆ md 출처」 가드를 둘지.

---

## 6. 남긴 것 (다음 배치) — 집행하지 않은 🟢

| 절 | 분량 | 왜 남겼나 |
|---|---|---|
| §3-1 (a) 교차 Task 실중복 7쌍 | 7문항 본문 교체 | **라이브 문항의 본문을 새로 쓰는 일**이다(2026-11-06 3쌍 때는 사용자 승인을 받았다). 새 소재·새 출처 실측이 필요하고 교체 쪽 선택(소유 Task)도 판정이다 — 별 배치 |
| §3-1 (b) 같은 Task 누출 9쌍 · (c) 교차 겹침 4묶음 | 해설·오답 근거 문장 걷기 | 문항 교체는 아니지만 13묶음을 하나씩 읽어 「어느 문장이 상대의 정답인가」를 가려야 한다. 이번 배치는 🔴·🟡 와 값싼 🟢 까지 |
| §3-4 Clarify 6문항 | 상태 문구 | 기준 결정이 먼저(§5) |
| §3-5 길이 단서 | 16 + 39문항 | 오답을 정답과 같은 정밀도로 올리는 작업 — 분량이 커서 1단계도 별 배치를 권했다 |
| §3-6 메타 문구 | 59문항 | 위와 같다. 이번에 3문항(`t4-2-q7`·`t3-1-q24`·`t4-2-q33`)은 귀속이 **거짓**이라 고쳤다 |
| §3-8 `mla-t1-3-q2` | 해설의 `CDDL`·`group_variable` 표기 | 인용 페이지에 없는 세부 표기. 그 표기를 담는 Clarify 분석 구성 페이지를 이번에 실측하지 않았다 |
| §3-9 | ML 용어 3갈래 · 「적합성 팩」 2자리 · 단일 출처 85문항 등 | 표기·정보 항목(MLA 가이드에 정본 표기가 없는 것 포함) |

## 7. 측정에서 얻은 것 (다음 세션용)

- ⚠️ **「docs 에 없다」가 「못 찾았다」였던 자리가 실제로 있었다**(§2-①). 1단계가 검색어 `right-size instances before purchasing Savings Plans SageMaker` 로 못 찾은 문장이, `SageMaker` 를 뺀 검색에서 1위로 나왔다 — 자격증 전용 문서 밖(규범 가이드)에 같은 권고가 있는지까지 본다.
- ⚠️ **인용 페이지가 이미 가름 조건을 적고 있었다**(`mla-t4-3-q22`). 1단계는 S3 사용자 가이드에서 근거를 가져왔지만, 문항의 둘째 출처 `vpc-endpoints-s3.html` 이 「둘 다 지원 · 인터페이스는 추가 요금」을 같은 문단에 적는다. 출처를 바꿀 필요가 없었다.
- ⚠️ **리터럴 규칙은 자기가 본 문자열만 안다** — Model Monitor 4문항은 `Model Monitor` 문자열이 없어 2026-10-27 선정에서 빠졌다. 새 가드는 출처 URL(`/dg/model-monitor-`, 데이터 캡처 제외)로 센다(실측 14문항).
- ⚠️ `py - <<EOF`(stdin)는 이 세션에서도 한 번 REPL 로 떨어져 2분 타임아웃까지 멈췄다(파일은 건드리기 전이었다). 스크립트는 파일로.
- 이전 실행(`content/phase2-fix-2026-11-17`, 커밋 `55d8443`)과 **문항 id 수준으로만** 교차 확인했다: 그 브랜치가 고친 MLA 문항은 전부 이 배치의 39문항 안에 있고(밖 0건), md 는 같은 7편이다. 문구는 대조하지 않았다 — 이 배치의 판정은 위 실측에서 독립적으로 나왔다.
