# AIF-C01 전수 검증 — 2026-11-17

> 범위: `flutter_app/assets/content/aif/` 학습문서 14편 · 문항 210개(공개 15 = `aif-t1-1`, 드래프트 195) · `assets/exam_guides/AIF-C01.json`.
> 기준 HEAD `4b83461`(`develop`). 콘텐츠·코드·테스트는 한 글자도 고치지 않았다. 측정 산출물은 세션 scratchpad에만 있다.
>
> **어떻게 셌는가(2단계가 다시 재지 않도록)**
> - **문항 210개 전부**를 지문·보기 4개·해설·오답 근거까지 읽고, 인용한 페이지를 내려받아(`curl -sL`, md+문항 고유 URL **265개**) **본문에서 그 사실을 찾았다**. 「없다」는 판정은 본문 추출 + raw HTML + 양성 대조군 + 동의어까지 본 것만 적었다.
> - **학습문서 14편**은 「시험 직전 요약」과 「자가 점검」을 **전문 통독**해 같은 Task 문항의 정답과 맞댔고, 「시험 포인트」·「흔한 함정」·본문은 **정규식 전수 + 문항이 닿는 줄**로 봤다. ⚠️ **「핵심 개념」 본문 전체를 통독하지는 않았다** — 본문에만 있고 문항·요약·자가 점검에 닿지 않는 문장의 결함은 이 보고서 밖에 있을 수 있다.
> - 2026-11-17에 이미 닫힌 세 묶음(중복 3쌍 · 죽은 출처 2건 · G-84 19개)과 `99-gaps.md`가 「개수를 단정하지 않는다」·「확인되지 않았다」로 판정한 항목은 다시 적지 않았다. 다만 **오늘 닫은 「죽은 출처 2건」의 처리가 새 결함을 남긴 자리 둘**은 §2에 적는다(Y2·Y3).

## 0. 요약

| 판정 | 수 | 뜻 |
|---|---|---|
| 🔴 | **1** (학습문서 1자리 · 문항 0) | 사실이 거짓 · 정답이 둘 · 정답이 틀림 (즉시 수정) |
| 🟡 | **문항 21개 + 학습문서 6편** (11묶음) | 불완전·모호·출처가 사실을 담지 않음 (수정 권고) |
| 🟢 | 9묶음 | 품질(길이 단서·메타 문구·중복·문체) — 사실은 옳다 |
| ✅ | 문항 **189/210** | 사실·인용 통과(품질 신호는 🟢에서 따로 센다) |

- **공개 문항 중 🔴: 0건** ← 가장 중요한 수치. 공개 `aif-t1-1` 15문항은 🟡도 0건이다(15/15 사실·인용 일치).
- 🔴 1건은 **라이브 학습문서** `aif-t2-3.md:255`의 「PT(필수)」다 — 세 번 고쳤다고 보고된 주장이 **약어형**으로 가드를 비켜 남아 있다.
- 🟡의 큰 줄기는 **「측정의 유효 기간」** 셋이다: 공식 결정 가이드가 **2026-11-14에 재구성**돼 인용문이 사라졌고(Y1), 오늘 「중복 삭제」로 닫은 죽은 출처 두 건이 **인용문을 고아로** 남겼다(Y2·Y3).
- `prescreen` qualityFlags(전체 210문항): **length-cue 129 · meta-phrasing 174 · authoring-memo 2 · explanation-long 3**, 품질 신호 문항 193/210(92%). 구조·정합성 플래그 **0건**, Task 내 중복 후보 **0쌍**.
- 검증한 출처 URL: **고유 265개**(문항만 181개). 생사는 `200 r=0` 261개 + 기존 판정 4개(신규 죽은 URL **0**). 그중 **「그 사실을 담지 않음」 6개 페이지**(Y1·Y2·Y5·Y6·Y7 + Y4의 명칭) + **출처 없이 남은 사실 3자리**(Y3·Y8·Y1의 `t2-2-q1` W3).
- 0건으로 확인한 축: G-84 위반 0(파일별) · 앵커 누락 0 · 공식 범위 외 서비스(93종)가 정답 보기에 든 문항 **0** · 문항 안 `**굵게**` 0 · 「PT 필수」 정규식 문항 0 · 「계속 사전 훈련」 문항 0 · `CloudTrail Lake` 문항 0 · 정답 자카드 ≥ 0.33 쌍 **0**(21,945쌍, 원형·조사벗김 둘 다).

## 1. 🔴 (문항·학습문서)

### `aif-t2-3.md:255` — 「시험 포인트」가 「사용자 지정 모델 서빙이면 PT(필수)」로 적는다

- **공개 여부**: 라이브 학습문서(문항 아님). 같은 Task 문항 `aif-t2-3`은 드래프트.
- **현재 정답 인덱스**: 해당 없음(학습문서). 맞대는 문항은 `aif-t3-1-q13` **c=1**(「가능합니다 — 사용자 지정 모델 배포를 만들어 그 배포의 ARN으로 호출…」).
- **결함**: `:255` 「**비용 절충 문항**은 세 패턴입니다 — … **"사용자 지정 모델 서빙"**이면 PT(필수), …」. 같은 파일이 네 자리에서 정반대를 가르친다 — `:104` 요약 「사용자 지정 모델의 추론 설정은 **둘**」 · `:118` 용어 표 「**필수는 아닙니다**」 · `:268` 함정 ❌ 「반드시 사야 한다」 · `:294` 자가 점검 Q2 「**가능합니다**」. 문서 내부 자기모순이고, 이 줄대로 외우면 `aif-t3-1-q13`을 틀린다.
- **공식 근거**: `https://docs.aws.amazon.com/bedrock/latest/userguide/model-customization-use.html` — "After you create a custom model, you can set up inference using **one of the following options**: Purchase Provisioned Throughput … Deploy custom model for on-demand inference – … With on-demand inference, you only pay for what you use and **you don't need to set up provisioned compute resources**."
- **수정안**: `:255`의 `PT(필수)`를 「PT **또는 온디맨드 배포**(호출량이 적으면 온디맨드)」로. 정답 인덱스 변경 없음(문항이 아니다).
- **전수**: 「PT(필수)」 약어형 **md 1자리 · 문항 0**. 정규식 `프로비저닝(된)? ?처리량…(사야|구매해야|필수|반드시|없이는)` md 3줄(`aif-t2-3.md:268` · `aif-t3-1.md:248` · `aif-t3-3.md:170` — **셋 다 옛 문구를 인용해 정정하는 줄이라 정상**) · 문항 0.
- **왜 가드가 초록이었나**(읽기만 했다): `test/aif_facts_test.dart:192`의 금지 리터럴이 `'PT 필수'`(공백)이고 `:222`의 정규식이 `프로비저닝(된)? 처리량(\(PT\))?[을를] ?(사야|구매해야)`라 **`PT(필수)`(괄호·무공백·약어)** 가 둘 다 비켜 간다. 「된」 한 글자로 뚫렸던 것과 같은 계열의 **네 번째** 누출이다 — 2단계에서 가드에 약어형(`PT\s*\(?필수`)을 더할 것.

## 2. 🟡

> 공통: 아래 문항은 **전부 드래프트**(`verified: false`)이고 **정답 인덱스를 바꿔야 하는 것은 0건**이다. 결함은 해설·오답 근거·보기 문구·출처에 있다.

### Y1. 결정 가이드 `genai-guide.html`이 2026-11-14에 재구성 — 인용문이 사라졌다 (문항 7 · 학습문서 3편)

- **측정**: `https://docs.aws.amazon.com/decision-guides/latest/decision-guides/genai-guide.html` = `200 r=0`, 본문에 **"Last updated November 14, 2026"**(curl 본문 + AWS 문서 리더 일치). 2026-11-06 2차 검토(Fable)가 원문으로 인용했던 문장들이 **지금은 본문·raw HTML 모두 0건**이다(대조군: 같은 추출에서 "Quality of response" 1건).
- **사라진 것(0건)**: `50 billion` · `Model size`/`number of parameters` · `complex architectures`/`slower` · `compromis…depth or accuracy` · `expensive to train`/`computational resources` · `secure and managed` · `beyond their original training` · `predefined standard`/`baseline` · 절 제목 `Fine-tuning and continuous pre-training capability` · `critical factors`.
- **현행 원문**(FM 선택 요소): "**Quality of response**: Accuracy, relevance, robustness, toxicity, and fairness of outputs for your tasks. This is usually the most important criterion." · "**Inference latency**: How quickly the model responds. Smaller models are usually faster and cheaper; larger models might give more detailed responses." · "**Price**: … Smaller models can offer strong results at lower cost." · "**Customization support**: Whether the model supports the customization method you need." (그 밖에 Modality · Context window · **Reasoning and tool use** · **Lifecycle**). 사용자 지정: "Supervised fine-tuning: Train a model on your own labeled examples…" · "Continued pre-training: Train a model on your own unlabeled data to make it more domain-specific."
- **문항별**(정답은 전부 유지된다 — 요지는 현행 문구로도 성립한다):

| 문항 | c | 무엇이 근거를 잃었나 | 수정안 |
|---|---|---|---|
| `aif-t2-2-q10` | 1 | 해설의 인용 셋(「복잡한 아키텍처 때문에 추론이 느려질 수」·「즉각적 상호작용을 기대하는 사용자를 답답하게」·「응답의 깊이나 정확도를 양보」), W2(「훈련이 비쌀 뿐 아니라 운영에도 더 많은 연산 자원」), 출처 제목 「Inference latency와 Pricing 절」 | 해설·W2를 현행 두 문장(Inference latency · Price)으로 다시 쓴다 |
| `aif-t2-2-q11` | 0 | **정답 보기 문구** 「안전한 관리형 환경에서 … 더 견고한 도메인 지식과 적응성」, W3(「모델 크기를 파라미터 수로 … 복잡도의 지표」), 출처 제목의 절 이름 | 정답 보기를 「레이블 없는 자체 데이터로 모델을 훈련해 더 도메인에 특화시킨다」로(현행 원문). 인덱스 불변 |
| `aif-t2-2-q1` | 0 | W3 「공식은 파라미터가 많은 모델이 더 복잡한 패턴을 잡지만 운영에 더 많은 연산 자원을 쓴다고 적습니다」 — 이 문항의 유일한 출처(FM 설명 페이지)에도 없고 결정 가이드에서도 사라졌다 | 「공식이 적는다」 귀속을 걷고 현행 "larger models might give more detailed responses"로 |
| `aif-t2-2-q12` | 2 | 오답 보기[3]과 W3의 **「500억 개」**(W3: 「공식이 적는 500억 개는 … 기준선일 뿐」) | 보기·W3에서 수치를 걷는다(오답 보기라 정답 영향 없음) |
| `aif-t2-2-q15` | 0 | W3 「미리 정한 기준이나 베이스라인 대비」(옛 정확도 정의) | 현행 "Accuracy, relevance, robustness, toxicity, and fairness of outputs"로 |
| `aif-t3-1-q1` | 1 | 해설의 결정 가이드 귀속 한 줄(사양 사실 자체는 Nova 사양표로 검증됨) | 귀속 문장만 현행 문구로 |
| `aif-t3-1-q2` | 0 | 해설·출처 제목 「미세 조정과 지속적인 사전 훈련 역량을 FM 선택의 결정적 요소로」 | 「**Customization support**(필요한 사용자 지정 방법을 지원하는가)」로 |

- **학습문서**: `aif-t2-2.md` `:87`(요약 — 「모델 크기(파라미터 수)」 축은 현행에 없고 **Reasoning and tool use · Lifecycle**이 새로 있다) · `:88` · `:193`(「큰 모델은 흔히 500억 개 이상」 인용) · `:328~:333`(자가 점검 Q5의 영문 인용 넷) · `:375` / `aif-t2-3.md` `:178` · `:369` / `aif-t3-1.md` `:78`(「결정적 요소들」) · `:90`(요약) · `:108` · `:132`(「500억 개 이상」) · `:392`.
- **무결함 대조군**: `aif-t2-3-q7`(c=3)이 인용한 "Experiment faster: Test and iterate on more content variations and creative concepts than would be possible manually."는 **현행에도 그대로** 있다.
- **전수**: `genai-guide` URL 참조 — md 7줄(3편) · 문항 5줄(3파일). 「500억」 — md 3줄 · 문항 2줄.

### Y2. 벡터 DB 인용문이 고아가 됐다 — 오늘의 「죽은 출처 중복 삭제」가 남긴 자리 (`aif-t3-1` 문항 2 · md 6줄)

- **경위**: 오늘 `docs.aws.amazon.com/vector-databases/`(죽은 URL)를 「해설이 이미 정본을 인용한다」며 **중복 삭제**로 닫았다. 그런데 남은 출처 `https://docs.aws.amazon.com/decision-guides/latest/decision-guides/vector-database-guide.html`("Last updated October 30, 2026", 본문 18.5K)에는 인용문이 **없다**.
- **0건**(본문 + raw HTML, 대조군 `pgvector` 6 · `GraphRAG` 4): `RDS for PostgreSQL` · `ideal choice` · `already invested` · `higher-level understanding` · `fully managed relational` · `open-source`.
- **현행 원문**: "**Amazon Aurora PostgreSQL (pgvector)**: SQL-native vector search inside a relational database through pgvector. … Teams with PostgreSQL expertise who need SQL and vector queries together." · "**Amazon Neptune Analytics**: Graph and vector search combined. GraphRAG – retrieval that uses entity relationships." · "On AWS, vector search is a capability you can add to many of the databases and services you might already run, rather than a separate database you must adopt."
- **문항**:
  - `aif-t3-1-q9` **c=2** — 정답 보기[2] 「공식은 이미 관계형 데이터베이스, 특히 PostgreSQL에 투자한 경우의 **이상적인 선택지**로 적습니다」(json:262), 해설(json:266 「Aurora PostgreSQL-Compatible Edition과 Amazon RDS for PostgreSQL을 … 함께 적고 … 이상적인 선택지라고 명시」), W1(json:269 「더 높은 수준의 이해가 필요한 질의에 이상적」). 정답 방향은 현행으로도 맞다.
  - `aif-t3-1-q10` **c=1** — 해설(json:294 「…더 높은 수준의 이해가 필요한 질의에 이상적이라고 명시」), W2(「이미 관계형 데이터베이스에 투자한 경우에 이상적」). W0(MemoryDB는 지식 기반 열이 **No**)은 현행 표로 **검증됨**.
- **학습문서** `aif-t3-1.md`: `:96` · `:210` · `:211`(「같은 문단에서 함께 … 이상적인 선택지」) · `:212` · `:288` · `:347`(자가 점검 Q4의 직접 인용).
- **수정안**: 「이상적인 선택지」·「더 높은 수준의 이해」 인용을 걷고 현행 문구(「PostgreSQL 전문성이 있고 SQL과 벡터 질의를 함께 써야 하는 팀」·「엔터티 관계를 사용하는 검색」)로 바꾼다. **RDS for PostgreSQL도 pgvector를 쓴다**는 사실을 남기려면 출처를 더한다 — `https://aws.amazon.com/what-is/vector-databases/`(오늘 `200 r=0`): "Amazon Aurora PostgreSQL-Compatible Edition and Amazon Relational Database Service (Amazon RDS) for PostgreSQL support the pgvector extension to store embeddings…"(⚠️ 「ideal choice」는 이 페이지에도 없다). G-84 때문에 `aif-t3-1.md` 프런트매터에도 함께 넣어야 한다.
- **전수**: 「이상적인 선택」 — md 2줄 · 문항 3줄(전부 `aif-t3-1`). 다른 자격증 0.

### Y3. `sus_sus_region_a2`는 오기가 아니라 실재 슬러그였다 — 리전 선택 사실이 출처 없이 남았다 (`aif-t4-1` 문항 2 · md 3줄)

- **경위**: 오늘 `wellarchitected/latest/framework/sus_sus_region_a2.html`(`404 r=0`)을 「`sus_`가 두 번 = 오기」로 보고 출처를 삭제했다.
- **측정**: `https://docs.aws.amazon.com/wellarchitected/latest/sustainability-pillar/sus_sus_region_a2.html` = **`200 r=0`**(20,998B, 본문 3,701자). 원문: "You select the workload's Region based on your own location." · "You consolidate all workload resources into one geographic location." · "Placing a workload close to Amazon renewable energy projects or Regions with low published carbon intensity…". 죽은 것은 **`framework/` 가이드 쪽 사본**뿐이다.
- ⚠️ **그대로 되살리면 안 되는 이유 둘**: ① 그 페이지 배너가 "**This whitepaper is for historical reference only and will be deprecated in the future.** All updated guidance and best practices now live in the Well-Architected Framework whitepaper."다 ② 현행 `framework/sus01-bp01.html`은 **「SUS01-BP01 Understand your resource usage efficiency」**로 **번호가 재배정**됐다 — `aif-t4-1.md:264`가 적는 「`SUS01-BP01 Choose Region…`가 정본입니다」는 현행 번호와 어긋난다. `sustainability-pillar/region-selection.html`은 1,262자 **목차 페이지**라 사실 출처가 못 된다.
- **출처 없이 남은 사실**: `aif-t4-1-q6` **c=1** W3(json:178 「리전 선택은 별도 모범 사례로 있고 재생 에너지 프로젝트 근처와 낮은 탄소 집약도가 공식 근거」) · `aif-t4-1-q7` **c=2** W0(「모든 워크로드 자원을 한 지리적 위치에 통합하는 것은 리전 선택 모범 사례가 적는 안티패턴…」) · `aif-t4-1.md` `:125`(요약) · `:264` · `:417`.
- **수정안**: 둘 중 하나 — (a) `sustainability-pillar/sus_sus_region_a2.html`을 **「역사적 참조용」 상태를 적어** 출처로 되살리고 `:264`의 BP 번호 단정을 걷는다 (b) 현행 framework 가이드에서 리전 선택 모범 사례의 **대응 페이지를 찾아** 옮긴다. ⚠️ (b)의 대응 페이지는 **이번에 확인하지 못했다**(§6). 번호·제목으로 매핑하지 말 것.
- **전수**: `sus_sus_region_a2` — 콘텐츠 0건(삭제됨). `SUS01-BP01` — `aif-t4-1.md` 1줄(`:264`).

### Y4. `Amazon Quick` — 제품 사용자 가이드가 이제 「AWS Quick」으로 적는다 (문항 4 · md 2편)

- **측정**: `https://docs.aws.amazon.com/quick/latest/userguide/what-is.html` — `<title>What is AWS Quick? - AWS Quick</title>`, "**AWS Quick** is an AI-powered service for automating tasks, analyzing data, building web applications, and conducting research.", "AWS Quick evolved from Amazon QuickSight. QuickSight continues as **AWS Quick Sight**, a feature within Quick."(curl + 문서 리더 일치. raw HTML `AWS Quick` 17건, `Amazon Quick`은 `Amazon QuickSight` 안의 1건뿐).
- ⚠️ **공식 안에서 세 갈래다**(§6): 시험 가이드 본문과 **공식 범위 내 서비스 목록은 「Amazon Quick」**(오늘 `aif-01-in-scope-services.html` 실측), 제품 가이드는 「AWS Quick」, 결정 가이드(2026-11-14판)는 「Amazon Quick **Suite**」. 그래서 **이름 자체를 일괄 치환하라는 권고가 아니다.**
- **결함인 자리 = 「사용자 가이드가 이렇게 적는다」고 귀속·인용한 문장**:
  - `aif-t1-3-q9` **c=1** 해설(「공식 사용자 가이드는 Amazon Quick을 …로 정의하고, 그 기능인 Amazon Quick Sight를…」) · 출처 제목 「What is Amazon Quick?」
  - `aif-t2-3-q4` **c=3** 해설(「공식 사용자 가이드는 Amazon Quick을 … Amazon Quick Sight와 … Amazon Quick Flows를 듭니다」) · 출처 제목
  - 오답 근거: `aif-t1-3-q8` **c=0** W2 · `aif-t2-3-q3` **c=0** W1
  - `aif-t2-3.md` `:100` · `:327`(「공식 메모가 **"Amazon Quick은 Amazon QuickSight에서 진화했다…"**」 — 따옴표 인용인데 원문은 `AWS Quick`) · `:330`(기능 여섯의 이름) / `aif-t1-3.md`
- **수정안**: 시험 가이드 표기 「Amazon Quick」을 축으로 두되, **사용자 가이드를 인용하는 문장에는 「제품 문서는 AWS Quick으로 적는다」를 병기**하고 출처 제목을 현행 `<title>`로. 저작 결정 D-09의 근거가 바뀌었으므로 2단계에서 D-09부터 다시 판정할 것.
- **전수**: aif 「Amazon Quick」 **75건**(`aif-t1-3.md` 20 · `aif-t1-3.questions.json` 7 · `aif-t2-3.md` 37 · `aif-t2-3.questions.json` 11) / 「AWS Quick」 **0건**.

### Y5. `aif-t2-1-q10` — 오답 근거가 인용 페이지에 없는 문장을 「공식」으로 귀속

- **공개 여부**: false · **현재 정답 인덱스**: **2**
- **결함**: W0(json:280) 「공식은 컨텍스트 윈도에 많은 토큰을 지원하는 모델이라 해도 컨텍스트 양이 늘어날수록 추론의 효과가 감쇠한다고 적고…」. 이 문항의 **유일한 출처** `…/agentic-ai-lens/agentperf03-bp02.html`에는 그 문장이 없다(`decay|degrad|attenuat|diminish` 본문 0 · raw HTML `decay` 0, 대조군 `context window` 다수).
- **공식 근거**: 그 문장은 AWS Database Blog에 있다(같은 Task의 `q11`이 인용하고 `aif-t2-1.md` 프런트매터에 등재됨). BP 페이지 쪽 원문은 "Without this discipline, conversation history and tool schemas crowd out reasoning capacity and inflate latency on every iteration."
- **수정안**: W0를 BP 문장으로 다시 쓰거나, 블로그 출처를 `q10`에 더한다(md에 이미 있어 G-84 통과).
- **전수**: 「감쇠」 — `aif-t2-1.md` 2자리(`:115` · `:399`), 문항 `q10`·`q11`.

### Y6. `aif-t3-1-q12` — 「교사가 현저히 크고 유능해야 한다」의 출처가 빠졌다

- **공개 여부**: false · **현재 정답 인덱스**: **3**
- **결함**: W2(json:362) 「공식 전제 조건은 교사가 학생보다 현저히 크고 유능한 모델이어야 한다…」 — **사실은 참**이지만 인용한 두 페이지(`model-distillation.html` · `custom-models.html`)에 없다(`significantly larger` 0건).
- **공식 근거**: `https://docs.aws.amazon.com/bedrock/latest/userguide/prequisites-model-distillation.html`(`200 r=0`, ⚠️ 슬러그의 `prequisites`는 AWS 쪽 철자 그대로다) — "Choose a teacher model that's significantly larger and more capable than the student model, and whose accuracy you want to achieve for your use case."
- **수정안**: 그 URL을 `q12` 출처와 `aif-t3-1.md` 프런트매터에 더한다. `99-gaps.md` G-48의 「전제 조건 페이지를 찾지 못했다」가 이것으로 닫힌다.

### Y7. `aif-t3-4-q12` — 「내장 평가자 구성은 수정 불가」의 출처가 다른 페이지다

- **공개 여부**: false · **현재 정답 인덱스**: **3**
- **결함**: W0 「공식은 내장 평가자의 구성이 평가자 모델과 프롬프트 템플릿을 포함해 수정할 수 없다고도 적습니다」 — 참이지만 인용한 `AmazonCloudWatch/latest/monitoring/omni-agents-evaluators.html`에는 없다.
- **공식 근거**: `https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/built-in-evaluators-overview.html` — "Built-in evaluator configurations, including their evaluator models and prompt templates, cannot be modified."
- **수정안**: 그 URL을 `q12` 출처에 더한다(`aif-t3-4.md` 프런트매터에 이미 있어 G-84 통과).

### Y8. `aif-t4-1-q5` · `aif-t4-1.md:207` — 「가드레일 버전은 자체 ARN이 없다」의 출처가 어느 목록에도 없다

- **공개 여부**: false · **현재 정답 인덱스**: **0**
- **결함**: W2와 md `:207`이 「버전은 별개 리소스가 아니어서 자체 ARN이 없다」고 적는다 — 참이지만 AIF 출처 목록의 Guardrails 페이지 8개 어디에도 그 문장이 없다.
- **공식 근거**: `https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails-deploy.html`(`200 r=0`) — "Guardrail versions aren't separate resources and don't have their own ARN".
- **수정안**: 그 URL을 `aif-t4-1.md` 프런트매터와 `q5` 출처에 더한다.

### Y9. `aif-t3-3-q3` — FAQ의 주어가 Titan인데 「기본 모델」로 일반화

- **공개 여부**: false · **현재 정답 인덱스**: **0**
- **결함**: 정답·해설이 「먼저 지속적 사전 훈련을 하면 이후 미세 조정에 레이블 레코드가 훨씬 적게 든다」를 일반 사실처럼 적는다. 인용한 `https://aws.amazon.com/bedrock/faqs/`의 주어는 Titan이다 — "…This job will adapt the **Amazon Titan base model** to the new domain…". 학습문서 `aif-t3-3.md:164`는 G-65 판정대로 Titan 한정을 적는다(**문서가 옳고 문항이 거친 역방향 잔존**).
- **수정안**: 해설에 「FAQ가 이 수혜를 적는 대상은 Amazon Titan 모델이다」 한 줄. 정답 유지.

### Y10. `aif-t2-2-q9` — 영문·한국어 시험 가이드 본문의 차이 자체를 묻는 메타 문항

- **공개 여부**: false · **현재 정답 인덱스**: **2**
- **결함**: 지문이 「영문 공식 시험 가이드의 도메인 2 본문으로 이 주장을 검토하면」이고 정답이 「영문 본문은 … 모두 **여덟 가지**를 예로 듭니다」다. **사실은 검증됐다**(EN 도메인 2: "…compliance, cost, latency, model complexity", KO 판에는 없음). 그러나 시험이 묻는 것은 선택 기준이지 가이드 판본의 차이가 아니고, 예시 **개수**를 정답으로 삼는다(루브릭 C5). `prescreen`이 `authoring-memo: 출제`로도 집었다.
- **수정안**: 「비용·지연·모델 복잡도도 모델 선택 기준이다」를 묻는 내용 문항으로 다시 쓴다(같은 목표 2.2.3, 인덱스는 유지 가능).

### Y11. `aif-t5-2.md` — `CloudTrail Lake`를 **새로 만들라고 권하는 문장**에 상태가 없다

- **결함**: 상태 문구는 `:179` 한 곳에만 있다(「2026-05-31부터 신규 고객에게 닫혔습니다」). 그런데 자가 점검 Q1 정답 `:443`이 「지속 보관이 필요하면 **추적(S3) 또는 CloudTrail Lake를 만듭니다**」로, 함정 `:414`가 「더 길게는 추적(S3)이나 **CloudTrail Lake가 필요합니다**」로 **신규 고객이 만들 수 없는 것을 권한다.** (`:120` · `:505`의 「Lake 최대 3,653일」은 사실 서술이라 🟢.)
- **공식 근거**: 같은 문서 `:179`가 이미 인용한 CloudTrail Lake 가용성 변경 공지(신규 고객 차단, Trails·Insights·Aggregated Events는 영향 없음).
- **수정안**: `:414` · `:443`의 권유를 「**추적(S3)**(CloudTrail Lake는 신규 고객에게 열려 있지 않다)」로.
- **전수**: `CloudTrail Lake` — `aif-t5-2.md` 5줄 · **문항 0**.

## 3. 🟢 (사실은 옳다 — 묶어서)

### G1. 교차 Task 의미 중복 — 자동 지표는 전부 임계 아래다

- **측정**: 210문항 21,945쌍의 정답 보기 자카드를 **원형 + 조사벗김** 둘로 쟀다. `max ≥ 0.33` **0쌍** · `≥ 0.25` 1쌍 · `≥ 0.20` 7쌍 · `≥ 0.15` 32쌍(같은 Task 13쌍). **원형만으로는 `≥ 0.15`가 3쌍뿐**이라 조사벗김 없이는 거의 안 보인다. 정답 자카드 상위 26쌍과 지문+정답 합산 상위 34쌍의 **본문을 읽어** 가렸다(검수 노트가 「0.15~0.23대 16쌍은 읽지 않았다」고 남긴 구간 포함).
- **같은 사실을 묻는 쌍**(전부 임계 아래 — 지표는 하한이다):

| # | 쌍 (정답 인덱스) | 공유하는 것 | 자카드(max) / 지문 |
|---|---|---|---|
| 1 | `aif-t1-1-q1`(**공개**, c=1) ↔ `aif-t4-1-q12`(c=3) | 「훈련에서는 좋고 테스트에서 나쁘다 → 과적합·높은 분산/변동」, 같은 페이지 `what-is/overfitting` | 0.182 / 0.162 |
| 2 | `aif-t1-3-q7`(c=2) ↔ `aif-t2-3-q2`(c=2) | 「GPU 사용률·비용·지연·처리량을 직접 관리 → SageMaker AI」, 같은 페이지 `bedrock-or-sagemaker.html`, 시나리오까지 같다 | 0.200 / 0.262 |
| 3 | `aif-t1-2-q9`(c=0) ↔ `aif-t3-1-q7`(c=2) | 「사내 정책 문서 + 답변마다 출처 → 지식 기반 RAG(인용)」, 같은 페이지 `knowledge-base.html` | 0.097 / 0.263 |
| 4 | `aif-t2-1-q6`(c=2) ↔ `aif-t3-1-q11`(c=0) | 「도메인 용어·레이블 없음 → 프롬프트 엔지니어링부터」, 같은 BP `genops05-bp01` | 0.154 / 0.270 |
| 5 | `aif-t2-3-q11`(c=2) ↔ `aif-t4-1-q5`(c=0) | 「Bedrock 밖 모델에도 → `ApplyGuardrail`은 모델을 호출하지 않고 평가」 | 0.103 / 0.184 |
| 6 | `aif-t1-3-q5`(c=1) ↔ `aif-t4-1-q9`(c=0) | JumpStart 공개 모델의 라이선스 검토 책임(후자는 동의를 더한다) — 부분 | 0.114 / 0.233 |
| 7 | `aif-t1-2-q15`(c=2) ↔ `aif-t3-3-q2`(c=2) | 「사전 훈련 FM이 처음부터 훈련보다 빠르고 저렴」 — 부분. ⚠️ **오늘 교체한 `t3-3-q2`가 만든 겹침** | 0.172 / 0.082 |
| 8 | `aif-t3-3-q1`(c=1) ↔ `aif-t3-3-q4`(c=3) | 같은 Task·같은 목표 3.3.1에서 「교사 응답으로 학생을 훈련」 — 부분. ⚠️ **오늘 교체한 `t3-3-q1`** | 0.217 / 0.091 |
| 9 | `aif-t1-2-q10`(c=1) ↔ `aif-t2-3-q1`(c=1), `aif-t1-3-q4`(c=0) ↔ `aif-t2-3-q3`(c=0) | AgentCore 정의 / JumpStart 정의 — 부분 | 0.205 · 0.162 |

- **중복이 아닌 최고 쌍**: `aif-t1-2-q9` ↔ `aif-t3-2-q11` 0.250 — 「검색 증강 생성」·「지식 기반」 어휘만 공유한다(인용 ↔ 데이터 중독).
- **수정안**: 1번은 공개 문항이 걸려 있으므로 **드래프트 쪽 `aif-t4-1-q12`**를 목표 4.1.6의 미출제 축(인구통계 집단에 미치는 영향·부정확성)으로 돌린다. 2~5번은 「어느 목표가 그 사실을 소유하나」로 가른다(2: 1.3.3 ↔ 2.3.1 · 3: 1.2.4 ↔ 3.1.3 · 4: 2.1.3 ↔ 3.1.5 · 5: 2.3.3 ↔ **4.1.2**).

### G2. `variance`의 번역이 공개 문항과 나머지에서 갈린다

- 공개 `aif-t1-1-q1`(c=1): 「높은 **분산**」(`aif-t1-1.questions.json` 2건) ↔ `aif-t4-1` 학습문서 「높은 변동」 6 · 「편향과 변동」 7, 문항 「높은 변동」 6 · 「편향과 변동」 1. 공식 한국어 가이드 목표 4.1.6은 「편향과 **변동**의 영향」이다.
- 수정안: 공개 문항이라 사람 판단 — 「분산(변동)」 병기 정도가 가장 작다. 정답 무관.

### G3. `aif-t1-3`만 문체가 다르다

- 지문 어미: `aif-t1-3` **15/15가 반말체**(「~는 무엇인가?」), 나머지 13 Task는 195/195 합쇼체(「~무엇입니까?」). 해설: `aif-t1-3` 평서 반말 28문장 / 합쇼체 0, 나머지는 합쇼체뿐이다.

### G4. 저작 메모·레포 용어가 문항에 남은 자리

- `aif-t1-2-q10`(c=1) **지문**: 「에이전틱 AI를 AWS에서 다루는 **정본**은 Amazon Bedrock AgentCore입니다」.
- `aif-t5-1-q5`(c=0) W1: 「데이터 카탈로그화의 **정본**인 AWS Glue Data Catalog는…」(`prescreen` `authoring-memo: 정본`).
- `aif-t4-1-q11`(c=2) 해설: 「**시험에서** 갈라야 하는 것은 이 복제 ↔ 제거 ↔ 합성 구분이고…」 + `⚠️` 이모지(문항 해설·보기 가운데 유일).
- 전수: 문항 필드에서 「정본」 2 · 「시험에서」 1 · `⚠️` 3(그중 2건은 `aif-t1-2-q1`·`q3` **출처 제목**의 구서비스 상태 라벨이라 정상) · `**` 0 · 「교재」·「실측」·「레포」·「확인되지 않」 0.

### G5. 해설 길이(`explanation-long`, 임계 400자)

- `aif-t4-1-q4`(c=3) 431자 · `aif-t4-1-q8`(c=3) 404자 · `aif-t4-2-q10`(c=2) 422자.

### G6. 번역·전제 문구

- `aif-t2-3-q1`(c=1) 해설 · `aif-t2-3.md:285`: 「AWS가 **처음 공개한** 오픈소스 SDK」 — 원문은 "AWS **initially released** Strands Agents as an open-source SDK"(처음에 오픈소스 SDK로 공개했다)라 「AWS 최초의 오픈소스 SDK」로 읽힐 수 있다.
- `aif-t3-2-q9`(c=1, 오늘 교체): 「**기준선** 아래」 — 원문은 "below acceptable **thresholds**"(임계값).
- `aif-t4-2-q8`(c=3) 지문: 「그동안 쓰던 관리형 설명 기능을 **더 쓸 수 없게 되어**」 — 공식은 "Existing customers can continue to use the service as normal"이다. 신규 고객 차단이지 제거가 아니다(정답 무관).

### G7. 페이지·가이드 자체를 묻는 지문(메타 문구 계열)

- `aif-t3-1-q15`(c=3) 「공식 에이전틱 AI 개념 페이지가 사용 사례로 직접 싣는 업무」 · `aif-t2-2-q15`(c=0) 「공식 가이드가 목표 2.2.4의 예로 드는 지표」 · `aif-t1-2-q13`(c=0) 「목표 1.2.5가 이름을 드는 관리형 서비스 여섯 가운데」. (`aif-t2-2-q9`는 정도가 달라 Y10으로 올렸다.)

### G8. `prescreen` 품질 신호 — Task별

| Task | 신호 문항 | length-cue | meta-phrasing | 기타 |
|---|---|---|---|---|
| `aif-t1-1`(**공개**) | 15/15 | 12 | 15 | |
| `aif-t1-2` | 14/15 | 6 | 14 | |
| `aif-t1-3` | 12/15 | 8 | 12 | |
| `aif-t2-1` | 15/15 | 12 | 15 | |
| `aif-t2-2` | 14/15 | 6 | 11 | authoring-memo 1(`q9`) |
| `aif-t2-3` | 15/15 | 14 | 15 | |
| `aif-t3-1` | 15/15 | 10 | 14 | |
| `aif-t3-2` | 14/15 | 6 | 14 | |
| `aif-t3-3` | 14/15 | 11 | 14 | |
| `aif-t3-4` | 14/15 | 8 | 14 | |
| `aif-t4-1` | 13/15 | 9 | 12 | explanation-long 2 |
| `aif-t4-2` | 15/15 | 13 | 8 | explanation-long 1 |
| `aif-t5-1` | 10/15 | 5 | 8 | authoring-memo 1(`q5`) |
| `aif-t5-2` | 13/15 | 9 | 8 | |
| 합계 | 193/210 | 129 | 174 | 5 |

- 저작 스타일 신호이고 검수 노트 §4가 이미 판정했다(「공식 문서가 …라고 적는」 지문과 정답이 최장인 보기). 새로 고칠 결함으로 올리지 않는다. 구조·정합성 플래그는 **0건**.

### G9. 정답 인덱스 분포 — 관찰만

- 전체 55/56/57/42(인덱스 0~3). Task별 4/4/4/3이 기본이고 예외는 `aif-t2-3` 4/3/4/4 · `aif-t3-1` 3/5/4/3 · `aif-t3-4` 4/4/5/2. 어느 인덱스도 지배하지 않고 앱이 보기를 섞으므로 루브릭대로 **고치지 않는다**.

## 4. 커버리지·범위

- **커버리지**: 공식 목표 69개(`knowledge`에서 유도) **전부 최소 2문항**이 덮는다 — 미커버 0 · 가이드에 없는 `skill` 0. 목표당 2~5문항. **2문항뿐인 목표**: 1.2.1 · 1.2.4 · 1.2.6 · 1.3.2 · 1.3.3 · 1.3.4 · 2.1.1 · 2.1.2 · 2.1.3 · 3.1.3 · 3.1.4 · 3.1.6 · 4.1.1 · 4.1.3 · 4.1.4 · 4.1.5 · 4.1.6 · 4.1.7. **5문항인 목표**: 3.3.1 · 3.3.2 · 3.3.3 · 5.2.1 · 5.2.2 · 5.2.3.
- **얇은 자리 하나**: 목표 4.1.6의 두 문항(`aif-t4-1-q12`·`q13`)이 **둘 다 과적합 페이지**를 묻고, 목표가 예로 드는 「인구통계 집단에 미치는 영향·부정확성」은 문항이 없다(G1의 1번 로테이션으로 함께 닫힌다).
- **구성**: Task당 15문항 · 난이도 `foundational` 73 / `applied` 137(Task당 5~6) · `verified` 15(`aif-t1-1`) · `section` 앵커 누락 0 · G-84(문항 출처 ⊆ 그 Task md 출처) 위반 0.
- **범위**: 공식 목록 두 개를 오늘 받아 대조했다 — `https://docs.aws.amazon.com/aws-certification/latest/ai-practitioner-01/aif-01-in-scope-services.html`(`200 r=0`, **51개 서비스**) · `…/aif-01-out-of-scope-services.html`(`200 r=0`, **93개 서비스**). **범위 외 93종이 정답 보기에 든 문항 0 · 가르치는 층(skill·지문·정답·해설)에 든 문항 0.** 오답 보기·오답 근거에만 나오는 것은 `AWS Support`(`aif-t5-2-q4`·`q12` — Trusted Advisor 플랜 맥락) 하나다.
- **어느 목록에도 없는 이름**: `Amazon MemoryDB`가 `aif-t3-1-q10`의 **오답 보기**에 쓰인다(D-07·G-47 기판정, 결함 아님). ⚠️ 두 목록 모두 스스로 「전체가 아니다」라고 적으므로 「목록에 없다」를 범위 밖으로 단정하지 않았다.
- **가이드 JSON**: 목표 본문·구조는 이번에 다시 대조하지 않았다(`aif_guide_v11_test`가 바이트 일치를 고정). 범위 내 목록의 표기가 **「Amazon Quick」**인 것만 확인했다(Y4).

## 5. 교차 자격증 — 다른 자격증과 어긋나는 자리 (고치지 않고 적기만)

- **`Amazon Quick` 표기**(Y4): 다른 자격증도 전부 옛 표기다 — 「Amazon Quick」 clf 37 · mla 24 · dea 21 · saa 21 · dva 13 · aip 7 / 「AWS Quick」은 **aip 13**뿐. `quick/latest/userguide`를 인용하는 파일: clf 2 · dea 2 · mla 2 · aip 1 · dva 1 · saa 1. 제품 문서를 **인용·귀속하는 문장**이 있는지는 각 자격증 세션이 볼 일이다.
- **`agentic-ai-security` 가이드가 살아 있다**: AIF 5파일이 인용하는 `prescriptive-guidance/latest/agentic-ai-security/best-practices-data.html` · `best-practices-input-validation.html`이 오늘 **`200 r=0`**이고 인용문도 실재한다(`aif-t3-3-q14` 검증). SCS 트랙은 2026-11-10에 이 가이드를 「네 방법 모두 404」로 판정해 출처를 내렸다 — **측정에 유효 기간이 있었다.** SCS 쪽 재측정 대상이다.
- **`sustainability-pillar/` 가이드**: `clf/t1-2.questions.json:318`이 `…/sustainability-pillar/sustainability-pillar.html`을 인용한다. 같은 가이드의 BP 페이지에 "historical reference only … will be deprecated in the future" 배너가 붙어 있다(Y3). ⚠️ clf가 인용한 그 페이지 자체는 재지 않았다.
- **`bedrock-or-sagemaker.html`**: mla 2파일도 인용한다. 이 페이지는 "Last updated July 23, 2026"로 **변동이 없고** AIF가 인용한 문장은 전부 실재한다(`genai-guide.html`만 재구성됐다 — 그쪽을 인용하는 자격증은 aif뿐이다).
- **Conformance Packs 표기**: `aif-t5-2.md:489·:491`이 「적합성 팩」으로 적는다(SOA 「규정 준수 팩」 · SCS 「준수 팩」). AIF 시험 가이드에는 그 낱말이 없어 판정 기준이 없다 — 적기만 한다.

## 6. 공식 내부 어긋남 / 「확인되지 않음」 — 수정안을 낼 수 없는 것

1. **Quick의 이름이 공식 안에서 셋이다** — 시험 가이드·범위 내 목록 「Amazon Quick」 / 제품 사용자 가이드 「AWS Quick」 / 결정 가이드(2026-11-14) 「Amazon Quick Suite」. 어느 쪽이 정본인지 AWS가 밝힌 자리를 찾지 못했다.
2. **「사용자 지정 모델은 PT 필수」가 공식 한 페이지에 아직 있다** — `bedrock/latest/userguide/prov-throughput.html` "If you customized a model, you must purchase Provisioned Throughput to be able to use it."(오늘 실측, G-19·G-46과 같다). 레포 판정(추론 설정 전용 페이지가 정본 = 경로 둘)은 그대로 유효하다.
3. **Guardrails 유해 콘텐츠 범주** — 개요는 프롬프트 공격을 유해 범주에 넣고 정의 절은 다섯만 든다(G-23, 변동 없음). 문항·학습문서가 개수를 단정한 자리는 **0건**이다(정규식 전수).
4. **지속 가능성 「리전 선택」 모범 사례의 현행 위치를 확인하지 못했다** — `sustainability-pillar/sus_sus_region_a2.html`은 살아 있되 「역사적 참조용」이고, 현행 `framework/sus01-bp01.html`은 **다른 BP**(Understand your resource usage efficiency)다. framework 가이드 안의 대응 페이지는 docs 검색 1회로 찾지 못했다 — **Y3의 (b)안은 이 확인이 선행돼야 한다.**
5. **「싱글샷」은 공식 docs에 정의가 없다** — Bedrock 프롬프트 엔지니어링 페이지에 `one-shot|single-shot` 0건(대조군 `zero-shot`·`few-shot` 실재). `aif-t3-2-q4`(c=3)는 시험 가이드의 낱말 + 「한 샷 = 예시 짝 하나」 정의의 산술에 기대고 해설이 그 층을 가른다(G-48·G-65 기판정 — 결함으로 올리지 않는다).
6. **`aif-t2-1-q11`(c=0)의 정답 근거는 AWS Database Blog 문장**이다(「컨텍스트가 늘수록 추론의 효과가 감쇠」). docs 페이지에는 그 문장이 없다(G-09·G-42 기판정 — 출처 제목이 블로그임을 밝힌다).
7. **CloudTrail 소개 페이지에는 Lake 상태 문구가 없다** — 상태의 정본은 Lake 전용 페이지다. 소개 페이지만 보고 「상태가 없다」로 읽으면 안 된다.
8. **`NEEDS_CONTEXT`: 없음.** 막혀서 멈춘 판단은 없다. 다만 2단계에서 **사람·컨트롤러의 판정이 먼저 필요한 자리 둘** — Y3의 (a)/(b) 선택과 Y4의 저작 결정 D-09 재판정.

## 7. 2단계에 넘기는 순서 제안

**순서(의존 관계)**

1. **🔴 `aif-t2-3.md:255`** — 한 줄 수정 + `aif_facts_test`에 약어형(`PT\s*\(?필수`) 추가. 가드를 먼저 넓히면 이 줄에서 레드가 난다(민감도 확인을 겸한다).
2. **Y1(결정 가이드 재구성)** — `aif-t2-2`·`aif-t2-3`·`aif-t3-1` 세 Task가 같은 페이지를 나눠 쓰므로 **한 PR**로. 학습문서 줄을 먼저 고치고 문항을 따라 고친다(루브릭 T6). 정답 인덱스 불변.
3. **Y2 + Y6** — 둘 다 `aif-t3-1`이고 둘 다 **새 출처를 md 프런트매터에 먼저 등재**해야 한다(G-84). 삽입은 `lastVerified:` 바로 앞, 본문 「참고자료」 절도 함께.
4. **Y3 + Y8** — 둘 다 `aif-t4-1`. Y3은 §6-4 판정이 선행. ⚠️ `source_url_retired_test`가 금지하는 것은 `framework/sus_sus_region_a2.html`이라 `sustainability-pillar/` 쪽 URL은 문자열이 달라 걸리지 않는다.
5. **Y4** — D-09 재판정 뒤 `aif-t1-3`·`aif-t2-3`.
6. **단건**: Y5(`aif-t2-1-q10`) · Y7(`aif-t3-4-q12`) · Y9(`aif-t3-3-q3`) · Y10(`aif-t2-2-q9` 재작성) · Y11(`aif-t5-2.md` 2줄).
7. **🟢**: G1 로테이션(공개 문항이 걸린 1번 먼저) → G2~G6. 로테이션은 새 중복을 만들 수 있으므로 **끝나면 조사벗김 자카드로 전수를 다시 잰다**(오늘 교체 5문항 중 2건이 새 겹침을 만들었다).

**Task별 flip 준비 상태**(검증 관점. flip 자체는 사람의 일이다)

| Task | 문항 🟡 | 학습문서 | 상태 |
|---|---|---|---|
| `aif-t1-1` | 0 | 0 | **공개 중** — 🔴·🟡 0 |
| `aif-t1-2` | 0 | 0 | 준비됨(게이트에는 불필요). 🟢 `q10` 지문 「정본」 |
| `aif-t1-3` | `q8`·`q9`(Y4) | Y4 | Y4 뒤. 🟢 문체(G3) |
| `aif-t2-1` | `q10`(Y5) | 0 | **출처 1건만 고치면 준비** |
| `aif-t2-2` | `q1`·`q9`·`q10`·`q11`·`q12`·`q15` | Y1 | 보류 — 손볼 문항이 가장 많다 |
| `aif-t2-3` | `q3`·`q4`(Y4) | **🔴 `:255`** · Y1 · Y4 | 🔴와 Y4 뒤 준비 |
| `aif-t3-1` | `q1`·`q2`·`q9`·`q10`·`q12` | Y1 · Y2 | 보류 |
| `aif-t3-2` | 0 | 0 | **준비됨** |
| `aif-t3-3` | `q3`(Y9) | 0 | 해설 한 줄 뒤 준비 |
| `aif-t3-4` | `q12`(Y7) | 0 | **출처 1건만 고치면 준비** |
| `aif-t4-1` | `q5`·`q6`·`q7` | Y3 · Y8 | 보류 |
| `aif-t4-2` | 0 | 0 | **준비됨** |
| `aif-t5-1` | 0 | 0 | **준비됨** |
| `aif-t5-2` | 0 | Y11(2줄) | 문항은 준비됨 |

- **게이트 산술**(추가 6 Task 90문항 — D2·D3 각 2 Task, D4·D5 각 1 Task)에 가장 싸게 닿는 조합: **D2 = `aif-t2-1` + `aif-t2-3`** · **D3 = `aif-t3-2` + `aif-t3-4`** · **D4 = `aif-t4-2`** · **D5 = `aif-t5-1`**. 선결은 **🔴 1줄 + 문항 4개(Y5 `t2-1-q10` · Y4 `t2-3-q3`·`q4` · Y7 `t3-4-q12`)**뿐이다. `aif-t2-2`·`aif-t3-1`·`aif-t4-1`은 Y1~Y3이 몰려 있어 게이트 뒤로 미루는 편이 싸다.
- 이 조합 안에서는 **G1의 중복 쌍이 한 쌍도 함께 공개되지 않는다**(각 쌍의 상대가 드래프트로 남는다). 다른 조합을 고르면 G1 표를 다시 대조할 것 — 예: `aif-t4-1`을 열면 공개 `aif-t1-1-q1`과 `aif-t4-1-q12`가 함께 노출된다.
