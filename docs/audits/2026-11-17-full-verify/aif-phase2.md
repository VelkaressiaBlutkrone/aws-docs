# AIF-C01 2단계 보정 — 2026-11-17

> 집행한 보고서: `docs/audits/2026-11-17-full-verify/aif.md`(1단계). 범위: `flutter_app/assets/content/aif/` 학습문서 14편 · 문항 210개(공개 15 = `aif-t1-1` · 드래프트 195).
> 작업 브랜치 `content/phase2-fable-2026-11-17`(공유 워킹트리). **커밋·flip은 하지 않았다.** 측정 산출물과 치환 스크립트는 세션 scratchpad에만 있다.
>
> ⚠️ **계약 파일이 이 브랜치의 작업 트리에 없다.** `01-PHASE2-CONTRACT.md`는 커밋 `8884494`(브랜치 `content/phase2-fix-2026-11-17`)에만 있어 `git show 8884494:docs/audits/2026-11-17-full-verify/01-PHASE2-CONTRACT.md`로 읽었다(브랜치는 바꾸지 않았다).

## 0. 요약

- **채택 12 / 기각 1(부분) / 범위 확장 5** — 1단계 보고의 🔴 1 · 🟡 11묶음(Y1~Y11) 대비. 🔴 1건과 🟡 11묶음을 **전부 닫았다**(Y1 안의 문항 1건만 기각). 🟢은 9묶음 중 **3묶음을 닫고**(G4 일부 · G6 · G1의 1번 쌍) 나머지는 §0 「남긴 것」에 적었다.
- 손댄 파일: **md 7편**(`aif-t1-3` · `aif-t2-2` · `aif-t2-3` · `aif-t3-1` · `aif-t3-2` · `aif-t4-1` · `aif-t5-2`) · **문항 12파일 26문항** · **가드 1**. `git diff --stat` 19 files, +166 / −125.
- **공개 문항(`aif-t1-1` 15문항)은 한 글자도 바뀌지 않았다**(파일 무변경).
- **정답 인덱스 변경: 0건.** `git diff -U0`에서 `verified`·`correct`·`skill`·`section`·`difficulty`·`id` 줄이 **0줄**이다. 바꿔야 하는 문항도 없다.
- 새 가드 `flutter_app/test/aif_v2_fix_test.dart` **47건**. `flutter analyze` 0건.
- **민감도 확인 방법:** 콘텐츠를 고치기 **전** 원본(기준선 sha와 바이트 동일)에 가드를 돌려 **34건 레드 · 9건 그린**(대조군·구조 불변식만 그린)을 확인한 뒤 반영했다. 뒤에 더한 G1-1 그룹도 반영 전 **3건 레드**를 먼저 봤다. `git stash`는 쓰지 않았다.
- 실행 결과(반영 후): `aif_v2_fix_test` 포함 AIF 관련 14파일 **595 통과 · 3 실패**. 실패 3건은 전부 §5에 있다 — 트립와이어 1(설계된 레드) + `aif_facts_test`의 **낡은 리터럴 2건**(내 정정이 기존 가드가 굳힌 판정과 어긋난 자리).
- `prescreen`(보정 뒤): 구조·정합성 플래그 **0건** · Task 내 중복 0쌍 · 품질 신호 193 → **190/210** (length-cue 129 → 126 · meta-phrasing 174 → 173 · **authoring-memo 2 → 0** · explanation-long 3).
- 중복(원형 + 조사벗김, 21,945쌍): 정답 자카드 ≥ 0.33 **0쌍**(변동 없음), ≥ 0.15 **31 → 29쌍**(이 세션의 토크나이저로 보정 전후를 같은 방법으로 쟀다 — 1단계는 자기 토크나이저로 32쌍). 재작성한 두 문항(`aif-t2-2-q9` · `aif-t4-1-q12`)은 **어느 쌍도 0.15에 닿지 않는다**(417쌍).
- **남긴 것(다음 배치):** 🟢 G1의 2~9번 쌍(교차 Task 의미 중복 8묶음) · G2(`variance` 번역 — **공개 문항**이라 사람 판단) · G3(`aif-t1-3` 15문항 반말체) · G4의 `aif-t4-1-q11`(「시험에서」+ ⚠️ — `aif_p1b_a4_fix_test`가 그 문항의 필수 문구를 묶고 있어 손대지 않았다) · G5(해설 400자 초과 3건) · G7(페이지·가이드 자체를 묻는 지문 3건). 1단계가 밝힌 한계도 그대로다 — **「핵심 개념」 본문 전체 통독은 하지 않았다.**

### 손댄 26문항 — 정답 인덱스 실측(전부 불변)

| 문항 | c | 묶음 | 문항 | c | 묶음 |
|---|---|---|---|---|---|
| `aif-t1-2-q10` | 1 | 🟢 G4 | `aif-t3-1-q9` | 2 | Y2 |
| `aif-t1-3-q8` | 0 | Y4 | `aif-t3-1-q10` | 1 | Y2 |
| `aif-t1-3-q9` | 1 | Y4 | `aif-t3-1-q12` | 3 | Y6 |
| `aif-t2-1-q10` | 2 | Y5 | `aif-t3-2-q9` | 1 | 🟢 G6 |
| `aif-t2-2-q1` | 0 | Y1 | `aif-t3-3-q3` | 0 | Y9 |
| `aif-t2-2-q9` | 2 | Y10 | `aif-t3-4-q12` | 3 | Y7 |
| `aif-t2-2-q10` | 1 | Y1 | `aif-t4-1-q5` | 0 | Y8 |
| `aif-t2-2-q11` | 0 | Y1 | `aif-t4-1-q6` | 1 | Y3 |
| `aif-t2-2-q12` | 2 | Y1 | `aif-t4-1-q7` | 2 | Y3 |
| `aif-t2-3-q1` | 1 | 🟢 G6 | `aif-t4-1-q12` | 3 | 🟢 G1-1 |
| `aif-t2-3-q3` | 0 | Y4 | `aif-t4-2-q8` | 3 | 🟢 G6 |
| `aif-t2-3-q4` | 3 | Y4 | `aif-t5-1-q5` | 0 | 🟢 G4 |
| `aif-t3-1-q1` | 1 | Y1 | | | |
| `aif-t3-1-q2` | 0 | Y1 | | | |

## 1. 채택 — 무엇을 어떻게 고쳤는가

> 측정은 전부 2026-11-17 `curl -sL`(본문은 태그 제거 후 `\s+` 정규화) + 필요한 곳은 AWS 문서 리더. 아래 URL은 모두 `200 r=0`이다(대조군: 같은 가이드의 틀린 슬러그 `bedrock/latest/userguide/zz-bogus-control.html` → `200 r=1`).

### 🔴 `aif-t2-3.md` 「시험 포인트」의 「PT(필수)」 — 채택

- **재확인:** `bedrock/latest/userguide/model-customization-use.html` — "After you create a custom model, you can set up inference using **one of the following options**: Purchase Provisioned Throughput … Deploy custom model for on-demand inference … you only pay for what you use and **you don't need to set up provisioned compute resources**."
- **수정:** `"사용자 지정 모델 서빙"이면 PT(필수)` → `PT 구매 또는 온디맨드 추론용 배포(처리량 보장이 필요하면 PT, 호출량이 적으면 온디맨드 배포)`. `lastVerified` 2026-11-06 → 2026-11-17.
- **전수:** 넓은 정규식 `(PT|프로비저닝(된)?\s?처리량).{0,25}필수|필수.{0,25}(PT|…)`로 md + 문항을 세면 **이 한 줄뿐**이었다(1단계 수치와 일치). 「사야·구매해야·반드시」 쪽 4줄은 전부 옛 문구를 인용해 정정하는 줄이라 그대로다.
- **가드:** 약어 + 괄호가 기존 리터럴과 정규식을 둘 다 비켜 갔으므로, 새 가드는 **「PT·프로비저닝 처리량」과 「필수」가 25자 안에 있는 줄**을 md + 문항 전수에서 세고(부정문 `필수는 아닙`·`아직`은 예외), 네 번의 누출 어형을 합성 입력 대조군으로 고정했다. ⚠️ 1단계는 `aif_facts_test`에 약어형을 더하라고 했지만 그 파일은 이 세션의 소유 범위 밖이라 **새 가드 파일에** 넣었다.

### Y1 `genai-guide.html` 2026-11-14 개정 — 채택(문항 6 · md 3편) / 문항 1건 기각(§2)

- **재확인:** 본문에 "Last updated November 14, 2026". 옛 인용 `50 billion` · `parameters` · `compromis` · `slower` · `secure and managed` · `baseline` **각 0건**, 대조군 `Quality of response` 1건. 현행 「Choosing a foundation model」 절의 요소는 Modality · Quality of response("This is usually the most important criterion.") · Inference latency("Smaller models are usually faster and cheaper; larger models might give more detailed responses.") · Context window · Reasoning and tool use · Price("Smaller models can offer strong results at lower cost.") · Customization support · Lifecycle, 그리고 훈련 데이터의 Quality·Quantity.
- **문항:**
  - `aif-t2-2-q10` — 정답 보기·해설·W0·W2·W3·출처 제목을 현행 두 문장(Inference latency · Price)으로 다시 썼다. 정답 보기가 95자 → 59자가 되어 길이 단서도 줄었다(최장 오답 46자 대비 1.28배).
  - `aif-t2-2-q11` — 정답 보기를 「레이블이 없는 자체 데이터로 모델을 훈련해 모델을 그 도메인에 더 특화시킵니다」로("Train a model on your own unlabeled data to make it more domain-specific"), 해설·W3·출처 제목도 현행 문구로.
  - `aif-t2-2-q1` W3 — 「공식은 파라미터가 많은 모델이 …라고 적습니다」 귀속을 걷고 지문의 성질(적응성)로 반박하게 했다.
  - `aif-t2-2-q12` 오답 보기[3]·W3 — 「500억 개」를 걷었다.
  - `aif-t3-1-q1` 출처 제목 · `aif-t3-1-q2` 해설·출처 제목 — 「결정적 요소」 → 「FM 선택 요소의 Context window / Customization support 항목」.
- **학습문서:** 아래 §3-1 참조(1단계가 든 줄보다 넓다).

### Y2 벡터 DB 인용문 — 채택(`aif-t3-1` 문항 2 · md)

- **재확인:** 옛 `docs.aws.amazon.com/vector-databases/`는 `301`로 `decision-guides/…/vector-database-guide.html`("Last updated October 30, 2026")로 **영구 이동**했다. 현행 본문에 `RDS for PostgreSQL` · `ideal` · `already invested` · `higher-level` **각 0건**(대조군 `pgvector` 6 · `GraphRAG` 4).
- ⚠️ **AWS 문서 리더는 옛 URL에서 옛 본문을 아직 돌려준다**("These are ideal options if you are already invested in relational databases, particularly PostgreSQL" 포함). `AWS CAF for AI`(302 · 인용 유지)와 달리 이쪽은 **301이고 대체 페이지가 실재**하므로 「사람이 열 수 없다」가 아니라 **교체됐다**로 판정했다. 학습자가 출처를 따라가면 도착하는 곳은 현행 가이드다.
- **수정:** 현행 표의 문구로 바꿨다 — Aurora PostgreSQL(pgvector) "SQL-native vector search inside a relational database through pgvector … Teams with PostgreSQL expertise who need SQL and vector queries together." · Neptune Analytics "Graph and vector search combined. GraphRAG – retrieval that uses entity relationships."
- **RDS for PostgreSQL:** 의사 결정 가이드에 **0건**이라 그 사실의 출처로 `aws.amazon.com/what-is/vector-databases/`를 더했다("Amazon Aurora PostgreSQL-Compatible Edition and Amazon Relational Database Service (Amazon RDS) for PostgreSQL support the pgvector extension to store embeddings … and to perform efficient similarity searches."). 프런트매터 + 참고자료 21번.

### Y3 리전 선택 모범 사례 — 채택, **1단계가 못 찾은 현행 정본을 찾았다**

- **재확인:** 현행 Framework의 대응 페이지는 `wellarchitected/latest/framework/sus01-bp03.html` — **「SUS01-BP03 Select Regions that align to your sustainability goals」**. 본문: "Choose an AWS Region by first evaluating essential requirements such as cost, latency, service availability, and compliance. Then, from the shortlisted Regions that meet these criteria, consider the carbon intensity of each Region's power grid…" / 안티패턴 "Selecting Regions based solely on proximity to team location." · "Deploying all workloads in a single Region without consideration for the specific needs of a given workload." 등 / "Level of risk … : **High**".
- **찾은 방법:** 번호·제목으로 매핑하지 않았다. `framework/sus01-bp01`~`bp04`를 차례로 받아 **본문을 읽고** 확인했다(`sus01-bp01` = Understand your resource usage efficiency · `bp02` = Create dashboards… · `bp03` = Select Regions… · `bp04`는 `r=1` 부재).
- **1단계의 (a)·(b) 중 (b)를 골랐다.** 옛 `sustainability-pillar/sus_sus_region_a2.html`은 살아 있지만 배너가 "for historical reference only and will be deprecated in the future"다. 현행 정본이 있으므로 그쪽으로 옮겼다.
- **수정:** `aif-t4-1.md` 본문 문단을 현행 BP로 다시 쓰고(위험 등급 Medium → **High**, 안티패턴 교체), **BP 번호가 재배정됐다는 경고**를 한 줄 더했다(옛 `SUS01-BP01`은 "역사적 참조용", 현행 `SUS01-BP01`은 다른 모범 사례). 요약·시험 포인트 줄도 맞췄다. `aif-t4-1-q6` 오답 보기[3]·W3, `aif-t4-1-q7` 오답 보기[0]·W0를 현행 문구로 바꾸고 **두 문항에 출처를 더했다**. 프런트매터 + 참고자료 34번.

### Y4 `Amazon Quick` 표기 — 채택(일괄 개명 아님)

- **재확인:** `quick/latest/userguide/what-is.html`의 `<title>`은 "What is AWS Quick? - AWS Quick", 본문 "AWS Quick evolved from Amazon QuickSight. QuickSight continues as AWS Quick Sight, a feature within Quick." 기능 목록은 AWS Quick Sight · AWS Quick Flows · AWS Quick Automate · AWS Quick Index · AWS Quick Research · Apps in AWS Quick. 한편 공식 범위 내 서비스 목록(`aif-01-in-scope-services.html`, 영문·한국어)은 **「Amazon Quick」**이다.
- **판정:** 서비스 이름은 **시험 가이드 표기 `Amazon Quick`을 그대로** 두고(자격증별로 그 시험 가이드 표기를 따르는 레포 관례), **사용자 가이드를 인용·귀속하는 문장**과 **사용자 가이드만이 정의하는 기능 이름**을 현행 표기로 고쳤다. 두 학습문서에 **「표기가 공식 안에서 갈립니다」 블록**을 넣었다.
- **수정:** `aif-t1-3.md` · `aif-t2-3.md`의 따옴표 인용("Amazon Quick은 …에서 진화했다" → "AWS Quick은 …"), 기능 이름 여섯, 출처 제목(`What is Amazon Quick?` → `What is AWS Quick?`, 프런트매터 + 참고자료). 문항은 `aif-t1-3-q9` · `aif-t2-3-q4` 해설·출처 제목, `aif-t1-3-q8` W2 · `aif-t2-3-q3` W1. ⚠️ `aif-t2-3-q4` 해설의 「AWS 서비스 개요 백서는 Kiro를 …」 문장은 `whitepaper_resourcing_test`가 세는 자리라 **그대로 뒀다**(통과 확인).
- `aif-t2-3.md` 요약의 「`Amazon Quick`은 Amazon QuickSight의 **개명**」은 원문("evolved from", QuickSight는 기능으로 이어진다)과 어긋나 「발전한 서비스」로 바꿨다.

### Y5 `aif-t2-1-q10` W0 — 채택(1단계의 두 안 중 「BP 문장으로 다시 쓰기」)

- **재확인:** `agentic-ai-lens/agentperf03-bp02.html`에 `decay|degrad|attenuat|diminish` 0건, "Without this discipline, conversation history and tool schemas **crowd out reasoning capacity and inflate latency on every iteration**." 1건.
- **수정:** W0의 「추론의 효과가 감쇠한다고 적고」를 그 BP 문장으로 바꿨다. 블로그 출처를 더하는 안은 고르지 않았다(블로그를 새 근거로 늘리지 않는다).

### Y6 `aif-t3-1-q12` · Y7 `aif-t3-4-q12` · Y8 `aif-t4-1-q5` — 채택(출처 추가)

| 문항 | 더한 출처 | 원문 |
|---|---|---|
| `aif-t3-1-q12` | `bedrock/latest/userguide/prequisites-model-distillation.html` | "Choose a teacher model that's significantly larger and more capable than the student model…" |
| `aif-t3-4-q12` | `bedrock-agentcore/latest/devguide/built-in-evaluators-overview.html` | "Built-in evaluator configurations, including their evaluator models and prompt templates, cannot be modified." |
| `aif-t4-1-q5` | `bedrock/latest/userguide/guardrails-deploy.html` | "Guardrail versions aren't separate resources and don't have their own ARN." |

- Y6·Y8은 G-84 때문에 md 프런트매터와 참고자료 절에도 등재했다(`aif-t3-1.md` 22번 · `aif-t4-1.md` 35번). Y7의 URL은 `aif-t3-4.md`에 이미 있었다.

### Y9 `aif-t3-3-q3` — 채택

- **재확인:** `aws.amazon.com/bedrock/faqs/` — "This job will adapt the **Amazon Titan base model** to the new domain. Then the customer may fine-tune … using significantly fewer labeled training records…".
- **수정:** 해설 끝에 「FAQ가 이 수혜를 적는 대상은 Amazon Titan 기본 모델이므로 다른 기본 모델에서도 같은 폭의 이득이 난다고 단정하지는 않습니다」 한 문장.

### Y10 `aif-t2-2-q9` — 채택(내용 문항으로 재작성 · c=2 불변)

- 「영문 시험 가이드 본문은 여덟 가지를 든다」를 정답으로 삼던 메타 문항을, **요금이 모델 선택 단계의 요소임**을 묻는 문항으로 바꿨다(같은 목표 2.2.3 · `section` · `difficulty` 불변). 근거는 현행 결정 가이드의 Price 항목 + 영문 가이드의 목표 2.2.3(cost, latency, model complexity — 오늘 재확인).
- ⚠️ **첫 초안의 시나리오가 `aif-t2-3-q12`(야간 리뷰 분류 → 배치 추론)와 거의 같았다.** 자카드로는 0.183(지문 + 정답)이라 임계 아래였고 **본문을 읽어 잡았다.** 「사내 문서 요약 도구 · 두 모델 모두 품질 기준 충족 · 월 예산 고정」으로 바꿨고, 지금은 어느 쌍도 0.15에 닿지 않는다.
- ⚠️ **새 문항이므로 사람의 T2 검수가 필요하다**(§4).

### Y11 `aif-t5-2.md` — 채택

- **재확인:** CloudTrail Lake 가용성 변경 페이지 — "AWS CloudTrail Lake will no longer be open to new customers starting on May 31, 2026." · "Only AWS CloudTrail Lake is no longer open to new customers. Your AWS CloudTrail Trails, Insights and Aggregated Events are not affected."
- **수정:** 권유 문장 두 줄(함정 · 자가 점검 Q1 정답)을 「추적(S3)」 중심으로 바꾸고 Lake에는 상태를 달았다.

### 🟢 닫은 것

- **G4(2/3):** `aif-t1-2-q10` 지문 · `aif-t5-1-q5` W1의 레포 용어 「정본」 → 문항 전수 0건.
- **G6(3/3):** Strands Agents 「AWS가 처음 공개한 오픈소스 SDK」(md 2 · 문항 1) → 「처음에 오픈소스 SDK로 공개」("AWS initially released Strands Agents as an open-source SDK") · `aif-t3-2-q9`와 `aif-t3-2.md`의 「기준선」 → 「허용 임계값」("plateau below acceptable thresholds") · `aif-t4-2-q8` 지문의 「더 쓸 수 없게 되어」 → 「신규 고객에게 더는 열려 있지 않아」("Existing customers can continue to use the service as normal").
- **G1의 1번 쌍:** 공개 `aif-t1-1-q1`과 같은 사실(과적합 = 높은 분산/변동)을 묻던 `aif-t4-1-q12`를 목표 4.1.6의 미출제 축 **「인구통계 집단에 미치는 영향」**으로 돌렸다(c=3 불변). 근거는 `aws.amazon.com/what-is/overfitting/`의 공식 예시 — "the prediction accuracy of this overfit algorithm drops for public universities, as their student demographics aren't reflected in the training data." 이 소재는 문항 전수에서 **0건**이었고 `aif-t4-1.md` §6이 이미 가르치고 있다. 1단계 §4가 적은 **「목표 4.1.6의 두 문항이 둘 다 과적합 페이지의 같은 축」**도 함께 닫힌다. ⚠️ **새 문항이므로 사람의 T2 검수가 필요하다.**

## 2. 기각 — 왜 고치지 않았는가

- **Y1의 `aif-t2-2-q15`(c=0) W3 「미리 정한 기준이나 베이스라인 대비」** — 고치지 않았다. 그 문장은 **「공식이 적는다」로 귀속하지 않고**, 이 문항의 출처에 결정 가이드가 없으며, 정확도의 통상적 뜻풀이로 참이다. 옛 페이지에서 온 표현이라는 것만으로 고치면 멀쩡한 문장을 건드리게 된다. (같은 뜻풀이가 「공식 서술」이라는 **표 머리 아래** 있던 `aif-t2-2.md`의 응답 품질 표는 귀속이 걸리므로 머리를 「뜻」으로 고쳤다 — §3-1.)
- **1단계 Y5의 「블로그 출처를 q10에 더한다」 안** · **Y3의 (a)안(역사적 참조용 백서를 되살린다)** — 둘 다 대안을 골랐다(위 §1).

## 3. 범위 확장 — 보고가 하한이던 자리

1. **Y1 학습문서 — 1단계가 든 12줄보다 넓었다.** 결정 가이드 옛 문구에 기댄 낱말(`파라미터` · `베이스라인` · `복잡도` · `본질적` · `결정적 요소` · `예산 친화` · `연산 자원`)로 세 편을 전수로 다시 세어 고쳤다.
   - `aif-t2-2.md` **14자리**: 요약 2줄 · §3 도입 · 영문 가이드 주의 블록(「모델 복잡도는 제약 조건 칸」이 표 개정으로 거짓이 될 자리) · 다섯 축 표의 4행 · **응답 품질 표의 귀속**(「공식 그대로 옮기면」·머리 「공식 서술」 → 공식은 다섯 낱말의 이름만 든다) · 주의 블록 · 함정 2줄 · 자가 점검 Q5 정답 · 참고자료 10번.
   - `aif-t3-1.md` **8자리**: 도입 · 요약 · 용어 표 · 아홉 축 표의 **4행**(1단계는 `:132` 한 줄만 들었다 — 「모델 복잡도」·「지연 시간」의 「즉시 번역」·「비용」의 「제공자의 가격 구조」도 옛 판 문구다) · 참고자료 4번.
   - `aif-t2-3.md` **2자리**: `:178`의 리터럴 인용 `model-independent, single API access`가 현행 페이지에 **0건**이다(현행은 "through a single API"와 "Because Amazon Bedrock offers model-independent API access" 두 문장). ⚠️ 이 리터럴은 **기존 가드 `aif_facts_test.dart:597`이 필수 문구로 묶고 있다** → §5.
2. **Y2 — 「이상적인 선택」 외에 같은 옛 페이지에서 온 문구가 더 있었다.** 「벡터 인덱스를 **수평 확장**해야 할 때」(md 1 · 문항 2) · 「**분석 그래프 데이터베이스 엔진**」(md 2 · 문항 1) · 「**Aurora Serverless v2** 배포에서도」(md 1). 전부 현행 가이드에 없어 함께 걷었다.
3. **Y3 — 위험 등급과 안티패턴 목록이 바뀌었다**(Medium → High, 안티패턴 2개 → 현행 5개 중 셋을 실었다). 1단계는 URL만 문제 삼았다.
4. **Y4 — 기능 이름 35자리.** aif의 「Amazon Quick」 75건 중 **35건이 기능 이름·사용자 가이드 인용**이어서 `AWS Quick …`으로 바꿨고, 서비스 이름으로 쓴 **40건은 그대로**다(가드가 「일괄 개명하지 않았다」를 하한 30으로 고정).
5. **Y11 — 「시험 직전 요약」의 기록 방식 3종 줄**(1단계는 🟢로 분류)에도 상태를 달았다. 요약만 읽는 학습자가 Lake를 현행 선택지로 읽는 자리다.

## 4. flip 준비 상태

> 검증 관점의 준비 상태다. **flip 자체는 사람의 일이다.** 게이트는 추가 **6 Task 90문항**(D2 · D3 각 2 Task, D4 · D5 각 1 Task)으로 열린다.

| Task | 1단계 🟡 | 이번 처리 | 상태 |
|---|---|---|---|
| `aif-t1-1` | 0 | 무변경 | **공개 중** |
| `aif-t1-2` | 0 | 🟢 `q10` 지문 | **준비됨** |
| `aif-t1-3` | `q8`·`q9` | Y4 닫음 | **준비됨**. 🟢 문체(G3)는 남아 있다 |
| `aif-t2-1` | `q10` | Y5 닫음 | **준비됨** |
| `aif-t2-2` | `q1`·`q9`·`q10`·`q11`·`q12`·`q15` | Y1 닫음(`q15` 기각) · Y10 재작성 | **준비됨** — ⚠️ `q9`는 **새 문항**이라 T2에서 읽을 것 |
| `aif-t2-3` | `q3`·`q4` + md 🔴 | 🔴 · Y1 · Y4 닫음 | **준비됨** |
| `aif-t3-1` | `q1`·`q2`·`q9`·`q10`·`q12` | Y1 · Y2 · Y6 닫음 | **준비됨** |
| `aif-t3-2` | 0 | 🟢 `q9` 번역 | **준비됨** |
| `aif-t3-3` | `q3` | Y9 닫음 | **준비됨** |
| `aif-t3-4` | `q12` | Y7 닫음 | **준비됨** |
| `aif-t4-1` | `q5`·`q6`·`q7` | Y3 · Y8 닫음 · G1-1 로테이션 | **준비됨** — ⚠️ `q12`는 **새 문항**이라 T2에서 읽을 것 |
| `aif-t4-2` | 0 | 🟢 `q8` 지문 | **준비됨** |
| `aif-t5-1` | 0 | 🟢 `q5` W1 | **준비됨** |
| `aif-t5-2` | 0 (md 2줄) | Y11 닫음 | **준비됨** |

- **1단계가 권한 가장 싼 조합은 그대로 유효하다** — D2 = `aif-t2-1` + `aif-t2-3` · D3 = `aif-t3-2` + `aif-t3-4` · D4 = `aif-t4-2` · D5 = `aif-t5-1`. 이 조합 안에서는 **남은 G1 쌍(2~9번)이 한 쌍도 함께 공개되지 않는다**(각 쌍의 상대가 드래프트로 남는다).
- ⚠️ **다른 조합을 고르면 1단계 G1 표를 다시 대조할 것.** 이번에 닫은 것은 1번 쌍뿐이다 — 이제 `aif-t4-1`을 열어도 공개 `aif-t1-1-q1`과 겹치지 않지만, 5번(`aif-t2-3-q11` ↔ `aif-t4-1-q5`) · 6번(`aif-t1-3-q5` ↔ `aif-t4-1-q9`)은 남아 있다. 8번(`aif-t3-3-q1` ↔ `q4`)은 **같은 Task 안**이라 `aif-t3-3`을 열면 조합과 무관하게 함께 나간다.
- flip 선결(가드 쪽): 새 가드는 **`verified`를 단정하지 않는다**(구조·정답 인덱스·문구만 본다). 파일명이 `aif_`로 시작해 `review.mjs`의 `flipTestFiles()`가 flip 때 함께 돌린다.

## 5. 컨트롤러 요청

- [ ] **`test/mla_aif_question_propagation_test.dart`의 `registered`(180행)에 `'aif_v2_fix_test.dart'` 등재.** 트립와이어가 설계대로 레드다. **`_factRules`·`_nameRules`로 옮길 금지 문구는 없다** — 새 가드의 금지 단정은 전부 **aif md + 문항 전수**를 직접 훑는다(`scanLines` / `allQuestions`).
- [ ] **`test/aif_facts_test.dart` 낡은 리터럴 2건**(이 세션의 소유 범위 밖이라 손대지 않았다. 지금 레드다):
  1. **261행** `['aif-t3-1.md:248', 'aif-t3-3.md:170']` → `['aif-t3-1.md:252', 'aif-t3-3.md:170']`. `aif-t3-1.md` 프런트매터에 출처 두 항목(네 줄)을 더해 줄 번호가 밀렸다. **내용은 그대로다**(2026-11-17 오전 `168 → 170`과 같은 계열).
  2. **597행** `contains('genai-guide.html`의 `model-independent, single API access')` → `contains('genai-guide.html`의 `through a single API` · `model-independent API access`')`. 그 리터럴은 **현행 페이지에 0건**이다(2026-11-14 개정). 가드가 굳힌 판정이 페이지와 어긋난 자리이고, 새 가드는 반대로 옛 리터럴을 **금지**한다.
- [ ] **`CLAUDE.md` 기준선 +47**(`aif_v2_fix_test.dart` 47건).
- [ ] **`docs/content-research/AIF-C01/` 노트 갱신**(소유 범위 밖):
  - `98-authoring-decisions.md` **D-09** — 「Quick 사용자 가이드가 접두어 붙인 전체 표기를 쓴다」의 근거가 바뀌었다. 지금 판정: **서비스 이름 = 시험 가이드 표기 `Amazon Quick`** · **기능 이름 = 제품 가이드 표기 `AWS Quick Sight` 등** · 사용자 가이드 인용은 원문 그대로.
  - `99-gaps.md` — ① **G-48 「증류 전제 조건 페이지를 찾지 못했다」가 닫혔다**(`prequisites-model-distillation.html`, 슬러그 철자는 AWS 쪽 그대로) ② `genai-guide.html` 2026-11-14 개정(G-40의 인용 `model-independent, single API access`가 그 개정으로 사라졌다) ③ 「PT 필수」 **다섯 번째** 누출과 약어형 ④ 지속 가능성 BP 번호 재배정(`SUS01-BP03`) ⑤ 옛 벡터 DB 안내 페이지의 301과 문서 리더의 옛 본문.
- [ ] **교차 자격증 — Quick 표기**(다른 자격증 파일은 읽기만 했다. grep 실측, 파일 수):
  - 출처 제목 `What is Amazon Quick` — **dva 1 · mla 2**(현행 `<title>`은 `What is AWS Quick?`).
  - 기능 이름 `Amazon Quick Sight|Flows|Automate|Index|Research` — **clf 4 · saa 3 · mla 2 · dva 1 · dea 1**.
  - `quick/latest/userguide`를 인용하는 파일 — clf 2 · dea 2 · mla 2 · aip 1 · dva 1 · saa 1.
  - ⚠️ 각 자격증의 **시험 가이드가 어느 표기를 쓰는지**에 따라 판정이 갈린다. 일괄 치환 대상이 아니다.
- [ ] **교차 자격증 — 1단계 §5의 나머지 항목은 그대로 유효하다**(SCS의 `agentic-ai-security` 재측정 · clf `t1-2.questions.json:318`의 `sustainability-pillar/` 페이지 — 같은 가이드의 BP 페이지에 "historical reference only" 배너가 붙어 있다). `genai-guide.html`과 `vector-database-guide.html`을 인용하는 자격증은 **aif뿐**이다(grep 0건).
- [ ] **정답 인덱스 변경이 필요한 문항: 없음.**

## 부록 — 과정에서 생긴 일(숨기지 않고 적는다)

- ⚠️ **치환 도구가 한 번 사본이 아닌 실제 파일에 먼저 쓰였다.** 반영 후 상태를 사본에서 미리 재려고 도구의 경로를 `sed`로 매개변수화했는데 그 치환이 먹지 않았고(백슬래시), 도구가 원래 경로로 **가드 작성 전에** 19파일을 썼다. 내용은 의도한 수정 그대로였고 소유 범위 안이었지만 **테스트 우선 순서가 깨졌으므로**, 미리 떠 둔 원본 사본으로 되돌리고 **28파일 sha256이 기준선과 전부 같음**을 확인한 뒤 가드 → 레드 확인 → 반영 순서로 다시 했다. `git` 명령으로 되돌리지 않았다. 이후 도구는 `ROOT=REAL/COPY`를 찍게 고쳤다.
- **치환 기법:** 계약대로 **바이트 블록 치환 + 횟수 단정**(문항별 블록 안에서만 일치를 센다) · 하나라도 어긋나면 아무 파일도 쓰지 않는다 · 쓰기 전 사후 조건(JSON 파싱 · 보존 필드 7종 불변 · 손대지 않은 문항 dict 동일 · CR 수 == LF 수 · 프런트매터 `sources` 연속성 · G-84). 횟수 단정이 실제로 **한 번 막았다** — `aif-t4-1-q12`의 옛 보기 문구가 해설에도 있어 2회 일치였다(순서를 고쳐 재실행).
- **가드 하한을 추측했다가 고쳤다** — 「`Amazon Quick` 40건 초과」로 썼는데 실측이 정확히 40이었다. 실측에서 하한을 잡는다는 레포 규율 그대로다.
- **첫 테스트 실행이 `ShaderCompilerException`으로 죽었다**(다른 세션과의 동시 실행 충돌). 계약대로 한 번 재시도해 정상이었다.
