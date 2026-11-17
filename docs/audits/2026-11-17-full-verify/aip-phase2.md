# AIP-C01 2단계 보정 — 2026-11-17

> 1단계 보고서: `docs/audits/2026-11-17-full-verify/aip.md` · 계약: `01-PHASE2-CONTRACT.md`(이 브랜치 작업 트리에는 없어 커밋 `8884494` 에서 `git show` 로 읽었다)
> 범위: `flutter_app/assets/content/aip/` md 20편 · 문항 300개(**전부 드래프트** — 라이브 영향 없음).
> ⛔ 커밋·브랜치 전환·flip 은 하지 않았다. `"verified"`·`"correct"`·`"skill"`·`"section"`·`"id"`·`"difficulty"` 줄은 diff 에 **0줄**이다(`git diff -U0 | grep` 실측).
> 중단 전 턴(모델 교체 전)이 고친 파일은 **없었다** — 시작 시 `git status --porcelain -- …/aip …/aip_v2_fix_test.dart` 가 빈 출력이었다.
> 방법: 1단계 항목마다 **공식 페이지를 다시 내려받아**(`curl -sL` → 태그 제거 → `\s+` 정규화) 인용 문장을 직접 읽고, 0건이 나오면 같은 페이지의 알려진 양성을 함께 세었다. 1단계가 인용한 문장을 그대로 믿은 항목은 없다. 그 과정에서 **1단계와 판정이 갈린 것이 넷**이다(§2).

## 0. 요약

- **채택 19 / 기각 0(수정안 단위로 다르게 처리 4 — §2-1~2-4) / 범위 확장 9** — 1단계의 🔴 **0** · 🟡 **13묶음(Y1~Y13) 전건 반영** · 🟢 **6묶음(G1~G6) 전건 반영**(G2 의 「제안이 나왔습니다」 틀 9문항만 남김 — §4).
- 손댄 파일: **md 17편 · 문항 20파일 · 가드 1** (콘텐츠 `37 files changed, 605 insertions(+), 322 deletions(-)`)
  - 문항 **107개**: 재작성 12 · 보기 문구 6 · 해설·오답 근거 29 · 지문만 39 · 출처만 21. md 본문을 고친 것 12편 · 출처 목록만 늘린 것 5편.
- **정답 인덱스 변경: 0건** — 바꿔야 하는 문항도 **0건**이다(가드가 손댄 107문항의 인덱스를 전부 대조한다).
- 새 가드 테스트 수: **34건** (`flutter_app/test/aip_v2_fix_test.dart`, `flutter analyze` 0건)
  - 보정 **전 원본**에 돌리면 **28 실패 · 6 통과**(레드 확인) → 보정 후 **34 통과**.
  - 민감도 확인 방법: `git stash` 가 금지라 **작업 트리의 aip 40파일을 scratchpad 백업(수정 전 원본)으로 잠깐 덮어** 실행하고 되돌렸다. 되돌린 뒤 `sha256sum -c` 불일치 **0건**(§6).
- AIP 테스트(`aip_questions_test` · `aip_doc_format_test` · `aip_guide_sync_test` · `aip_v2_fix_test`): **244 통과 · 0 실패**(기존 210 + 신규 34). `all_content_parse_test --plain-name aip` 20 통과.
- `prescreen`(보정 후 실측): 구조·정합성 플래그 **0건** · 뱅크 플래그 0 Task · 품질 신호 **0/300**(length-cue 0 · meta-phrasing 0 · authoring-memo 0 · explanation-long 0) · Task 내 중복 후보 0쌍.
- 새로 단 출처 URL: md 고유 **23개**(32자리) · 문항 고유 **30개** — **전부 `200 r=0`** 재측정(대조군: 같은 가이드의 틀린 슬러그 `200 r=1` → 가이드 인덱스 · 없는 가이드 접두사 진짜 `404 r=0`).
- 남긴 것(다음 배치): G2 의 「~자는 제안이 나왔습니다」 틀 **9문항** · `aip-t1-4-q6`↔`q11` 의 ACL 절반 겹침 · 학습문서 20편 전문 통독(1단계의 사각 — 이번에 표적 대조로 2건을 더 찾았다) · 조사 노트(`docs/content-research/AIP-C01/`) 갱신은 소유 범위 밖이라 §5 요청.

---

## 1. 채택 — 무엇을 어떻게 고쳤는가

정답 인덱스는 전부 1단계 실측값 그대로다(`c=` 로 적는다).

### 1순위 — 정답 보기의 전제가 공식에서 확인되지 않던 셋

| # | 자리 | 공식 근거(직접 읽은 문장) | 고친 것 |
|---|---|---|---|
| **Y1** | `aip-t1-6-q15`(c=2) 전체 · `aip-t1-6.md` 2줄 | `prompt-management-deploy.html` — "A version is a snapshot of your prompt that you create at a point in time when you are iterating on the working draft" · `flows-nodes.html` — "You can use a prompt from Prompt management or define one inline in the node" · `API_agent_PromptFlowNodeResourceConfiguration.html` — `promptArn … Pattern: …prompt/[0-9a-zA-Z]{10}(?::[0-9]{1,5})?` · `flows.html` — "Versions are immutable because they act as a snapshot of the flow" · "Create an alias that points to the version". 전파 서술(`reus`·`automatically`·`copy|snapshot` in flows-nodes)은 **0건** | 문항을 「운영 플로가 어느 프롬프트 구성으로 도는지 **고정하려면**」으로 다시 썼다. 정답: 프롬프트 버전을 만들어 노드가 그 버전을 가리키게 + 플로 버전 게시·별칭 배포. 오답 셋은 전부 위 페이지로 거짓이 확인된다(인라인 전용 아님 · 초안은 고정되지 않음 · 변형은 스냅샷이 아님). 출처 4개 |
| **Y2** | `aip-t1-5-q8`(c=3) 전체 · `aip-t1-5.md` 5줄 | `knowledge-base-setup.html` — "(If you use an Amazon Aurora database and want to set up filtering on metadata) Fields for metadata … If you plan to set up filtering in other vector stores, you don't have to set up these fields" · "If you're using the custom metadata field, you must also create a GIN index" · "create a column for each metadata attribute … specify the data type (text, number, or boolean)" · Note "Without iterative scans, selective metadata filters can return fewer results than expected because filtering is applied after the HNSW index scan". `silently`·`empty`(필터 문맥) **0건** | 증상 진단형(「비어 온다 → 조용한 누락」)을 **설정 요건형**으로: 「Aurora 에 메타데이터 필터링을 붙이려 한다 — 다른 스토어와 달리 미리 준비할 것」. 해설이 `t4-2-q5` 와 **원인 둘을 가르는 기준**(필드가 없다 ↔ 필드는 있는데 모자란다 = 반복 인덱스 스캔)을 적는다. md 는 「조용한 누락」 4줄을 요건 + 방법 둘 + 반복 스캔 안내로 |
| **Y3** | `aip-t1-4-q11`(c=2) 전체 · `q6`(c=1) 해설 · `q10`(c=1) 해설+W0 · `aip-t1-4.md` | ⚠️ **등급 상향 — §2-1.** `kb-managed-ds-webcrawler.html` — "Authentication for protected sites: basic, form-based, or SAML" · "The Web Crawler does not support document-level access control (ACLs). All indexed content is accessible to any user who has access to the knowledge base. If you need ACL filtering, use a connector that supports it (for example, Amazon S3, SharePoint, or OneDrive)" · "Incremental sync model: The first sync performs a full crawl" · "defaults to disallow if a robots.txt file is not found" | `q11` 을 「이 커넥터에 대한 옳은 설명」으로. **정답: 로그인이 필요한 사이트도 크롤하지만 문서 수준 ACL 미지원**. 옛 오해(「로그인 사이트는 크롤 못 한다」)는 이제 **오답 보기 [1]** 이다. `q6`·`q10` 에서 그 구절을 걷었다. md 는 「접속이 아니라 권한에서 갈린다」로 |

### 사라졌거나 어긋난 공식 문장

| # | 자리 | 공식 근거 | 고친 것 |
|---|---|---|---|
| **Y4** | `aip-t3-1-q14`(c=1) 해설 · `aip-t3-1.md` **5줄** | `guardrails-tiers.html`(5,326자) — `specify a tier`·`uses Classic`·`default`·`If you do` **0건**(대조군 `re-tested` 1 · `1,000` 1 · `French` 3 · `Strict grounding` 2). `API_GuardrailContentFiltersTierConfig.html` 도 기본값 미기재 | 「지정하지 않으면 Classic」을 걷었다 — **대체 단정을 새로 쓰지 않았다.** 대신 현행 페이지에 있는 것으로 채웠다: Classic 의 문맥 근거 확인은 `Strict grounding only` · 지원 리전 밖에서 문맥 근거 확인에 Standard 를 지정하면 `fail with a validation error`(흔한 함정 줄을 이것으로 교체) |
| **Y5** | `aip-t3-4-q7`(c=2) 전체 · `aip-t5-1-q10`(c=1) 해설 · `aip-t3-4.md` 4줄 | `evaluation.html` — "The dataset must also include 'ground truth' or the expected retrieved texts and responses" ↔ `knowledge-base-evaluation-metrics.html` — Context coverage 행에만 "You must supply a ground truth in your prompt dataset to use this metric" | `q7` 을 **두 페이지 어느 쪽으로 읽어도 정답이 하나**가 되게: 「기대되는 검색 텍스트를 데이터세트에 담아 검색 결과와 맞대 볼 수 있는 유형」= RAG 평가(나머지 셋은 `evaluation.html` 이 **model** evaluation 으로 적는다). 해설이 두 페이지의 차이를 한 문장으로 적는다. `t5-1-q10` 의 「관련성은 그라운드 트루스 없이도 나옵니다」(부재 추론)는 「필수로 적힌 것은 커버리지 쪽」으로 |
| **Y9** | `aip-t1-1-q5`(c=0) 지문·보기[1]·해설·W1·출처 제목 · `q1`(c=0) W3·출처 제목 · `aip-t1-1.md` 4줄 | `generative-ai-lens.html`(6,461자) — `model training`·`exclud`·`out of scope` **0건**(대조군 `Machine Learning Lens` 1 · `customer-managed models` 1). 렌즈는 사용자 지정을 **다룬다**(`customization` 3건 — "determine when to execute model customization" · "Minimize computational resources for training, customization") | 「명시적으로 제외」→ 렌즈가 적는 문장("For traditional machine learning (ML) applications built using Amazon SageMaker AI, see Machine Learning Lens"). ⚠️ `q5` 의 오답 보기 [1] 「그 렌즈가 모델 훈련 모범 사례까지 함께 담고 있습니다」는 **부분적으로 참**이 돼 있어 「범위가 전통적인 ML 애플리케이션까지 포함합니다」로 바꿨다 |
| **Y10** | `aip-t1-1-q13`(c=0) 지문·보기[2]·해설·W1~W3 · `aip-t1-1.md` 2줄 | `userguide/well-architected.html`(2,674자, Last updated: November 16, 2026) — `free`·`charge`·`cost` **0건** · "AWS Well-Architected provides **two distinct ways**" · 비교표 "Automated, AI-powered analysis of your deployed resources and IaC templates" ↔ "Manual, guided self-review". `release-notes.html` — "AWS WA Agent is available to customers with a Business+, Enterprise On-Ramp, Enterprise Support, or Unified Operations support plan" | 오답 [2] 「유료 기능이어서」는 **참일 수 있는 보기**(유료 지원 플랜이 전제)라 과금과 무관한 거짓 보기(「수동 검토 전용이어서 리소스를 스스로 분석하지 못한다」)로 교체. 해설에서 과금 서술을 뺐다(§2-3). md 의 「워크로드 검토 서비스를 무료로 제공한다」(옛 페이지 문장)는 요금 페이지 문구로 |
| **Y11** | `aip-t3-3-q14`(c=1) · `aip-t2-3-q15`(c=2) · `aip-t5-1-q11`(c=2) | `clarify-availability-change.html` — "Amazon Bedrock Evaluations and Amazon Bedrock Guardrails are the AWS-managed path … They replace Clarify's foundation model evaluation (FMEval) capability" · "Option 1: fmeval library (recommended for SageMaker-hosted models)" / `gateway-rate-limits.html` — "Control tokens per minute (TPM) for inference targets" · "Limit concurrent connections to endpoints"(별 불릿) | 「셋이고 둘 모두」·「분당 토큰으로 엔드포인트의 동시 연결 수를」 문장 정정. `t5-1-q11` 은 **§2-2·§3-5**(1단계와 판정이 갈렸다) |

### 저작 메모·메타 문항·상태

| # | 자리 | 고친 것 |
|---|---|---|
| **Y6** | `aip-t3-4-q5`(c=0) 해설·W1·W2 · `q11`(c=2) 해설·W0 · `aip-t3-4.md` 4줄 | 「이 트랙에서 얻지 못했습니다」·「같은 추출에서 … 본문이 읽혔음이 확인됩니다」·「근거를 얻지 못했습니다」를 사실 서술로. md 의 「공식 문서에서 확인되지 않습니다」(의도된 시험 전략 서술 — 루브릭 §2)는 **남겼고 가드가 보존**한다. 전수 0건 가드(M2) 신설 |
| **Y7** | `aip-t2-2-q10`(c=1) · `aip-t3-3-q9`(c=0) · `aip-t2-2-q7`(c=2) · `aip-t1-4-q9`(c=0) | 네 문항을 **설계 상황**으로 재작성. `t2-2-q10` → LMI 컨테이너 문서가 안내하는 일(인스턴스 유형·백엔드 선택 → 구성·배포 → 최적화 → 벤치마크, `large-model-inference-container-docs.html` 불릿 다섯) · `t3-3-q9` → 진실성 ↔ 견고성(렌즈의 정의 "Veracity: Achieving factually correct system outputs" · "Robustness: … for both expected and unexpected inputs". 같은 Task `q8` 의 설명 가능성·투명성과 겹치지 않는 쌍) · `t2-2-q7` → Lambda 호출과 프로비저닝 처리량의 관계(다른 축이라 함께 쓴다) · `t1-4-q9` → `knn_vector` 차원 상한 단일 문항("configurable dimensions (up to 16,000)") |
| **Y8** | `aip-t1-4-q3`(c=2) 해설 · `aip-t1-4.md` 2줄 | `kendra-availability-change.html` — "Amazon Kendra is no longer open to new customers" · `maintenance_services.html` — `Amazon Kendra June 30, 2026`. 해설 끝에 상태 한 문장(오답 근거에는 달지 않았다 — D-07). 날짜는 적지 않았다(G-24) |
| **G1** | `t2-2-q4` · `t2-5-q10`(c=0) · `t2-4-q8`(c=3) · `t3-3-q14` · `t4-1-q7`(c=2) | 「이 사이트는」·「시험 포인트」·「시험 소재」 5자리 전부. `t2-5-q10` 은 정답 보기에서 **날짜(2027-04-30)도 뺐다**(G-24: 닫힌 서비스의 날짜를 묻지 않는다 — 나머지 오답이 상태 종류로 갈리므로 문항이 그대로 선다). 해설은 날짜를 그대로 적는다(두 인용 페이지에 있다) |
| **G2** | 지문 **44문항** | 「~에 비추어」 전부(9문항은 다른 항목으로 지문을 고치며 함께, 35문항은 꼬리 문장만 치환). 가드가 지문 0건으로 고정 |
| **G4** | 8행 | `t1-5-q1`(c=0) 지문을 「검색 결과로 돌아온 텍스트가 길다」로("During retrieval, a matching chunk is replaced") + 10,000자 조건 · `t2-2-q2`(c=1) + md 2줄 「약정 유무와 무관하게」("with commitment or no commitment") · `t4-1-q11`(c=2) 「권고되는 방식」 → 「폴링 대신 받을 수 있다」("instead of polling") · `t2-2-q11`(c=2) 라우팅은 **미리 예측**해 보낸다는 차이 한 문장 · `t1-6-q5`(c=0) W2·W3 기능 이유를 앞에 · `t4-3-q15`(c=2) W1 부재 서술 삭제 · `t4-2-q11`(c=2) 부재 서술 삭제 · 단어 필터: `t3-1-q2`(c=1) 해설·`q13` W3·`aip-t3-1.md` 에 「대소문자 무시 · 전체 단어·구 단위」 병기 |
| **G5** | `aip-t1-4-q12`(c=3) | 해설의 `⚠️` 제거. 문항 전수 이모지 0건 가드 |
| **G6** | 뱅크 20개 | 손댄 뱅크의 `lastVerified` 를 `2026-11-17` 로(20개 전부 손댔다). 뱅크 날짜를 고정하는 테스트는 **없다**(`test/aip_*` grep 실측) |

### 출처 — Y12·Y13

**Y12 (16문항 + `t5-1-q11`)**: 1단계 표의 제안 URL 을 전부 다시 받아 그 문장이 있는지 확인한 뒤 달았다.

| 문항 | 추가·교체한 출처 | 확인한 문장 |
|---|---|---|
| `t1-3-q6`(c=1)·`q7`(c=2) | + `build-your-own-processing-container.html` | "two JSON files— /opt/ml/config/processingjobconfig.json and /opt/ml/config/resourceconfig.json" · `"S3UploadMode": "EndOfJob"` |
| `t1-3-q15`(c=2) | + `general/latest/gr/maintenance_services.html`, 해설에서 날짜 삭제 | `Amazon Comprehend – Topic Modeling, Event Detection, and Prompt Safety Classification March 31, 2026`. 가용성 변경 페이지에는 날짜도 `maintenance` 라는 낱말도 **0건** |
| `t1-4-q1`(c=0)·`q4`(c=3) | + `kb-test-agentic-retrieve.html`, 「단일 검색 패스」 → 「에이전틱 검색은 관리형 전용」 | "Agentic retrieval only supports managed Amazon Bedrock knowledge bases." |
| `t1-4-q10`(c=1) | + `kb-direct-ingestion.html` | "connected to one of the following types of data sources: Amazon S3 Custom" · `KnowledgeBaseDocuments` 6건 |
| `t2-1-q4`(c=3) | + `devguide/harness.html` | "through the AgentCore InvokeHarness state in AWS Step Functions" |
| `t2-1-q7`(c=2) | + `agentperf02-bp01.html` | "Retrying a failed LLM call with the identical prompt and model" |
| `t2-1-q13`(c=0) | + `devguide/gateway.html` | "allowing agents to use thousands of tools while minimizing prompt size and reducing latency" |
| `t3-1-q13`(c=0) | + `guardrails-prompt-attack.html`(첫 출처), 인용문 교체 | "Jailbreaks — … Prompt Injection — … Prompt Leakage (Standard tier only)". 옛 해설의 따옴표 인용은 어느 페이지에도 없어 이 페이지의 정의로 바꿨다 |
| `t3-2-q6`(c=1) | + `full_shutdown_services.html` | `Governed Tables in AWS Lake Formation December 31, 2024` |
| `t3-3-q5`(c=0) | + `glue/…/components-overview.html` | "Each AWS account has one AWS Glue Data Catalog per AWS Region." |
| `t3-3-q7`(c=2) | + `cloudtrail-concepts.html`, 「파티션 전 리전」 삭제 | "All trails created using the CloudTrail console are multi-Region trails" · "captures activity in all enabled Regions" |
| `t4-2-q5`(c=0) | `kb-test-config.html` → `knowledge-base-setup.html` + `bp-sharding.html` | 반복 스캔 Note · "decide about shard count before indexing your first document" |
| `t4-3-q9`(c=0) | + `supported-frameworks-strands.html`, **Strands 한정** | "Strands sets the gen_ai.operation.name attribute on each span" · `gen_ai.tool.name` 7건 |
| `t5-1-q1`(c=0) | + `evaluations-types.html` | 세션·스팬·트레이스 ID 지정 서술 |
| `t5-1-q11`(c=2) | + `dataset-evaluations.html` | §2-2 |

**Y13 (18문항 + `t1-1-q1` → 전수로 3문항 더, 재작성한 `t2-2-q7` 까지 시험 안내서 출처 보유 23문항)**: 수정안 ⓐ(시험 안내서 도메인 페이지를 출처로)를 택했다. `…/ko_kr/aws-certification/latest/ai-professional-01/ai-professional-01-domain{1,2,3,5}.html` 네 페이지를 받아 **가이드 JSON 의 기술 본문 98개가 전부 그 페이지에 실재**함을 기계로 대조했다(도메인별 28/28 · 25/25 · 15/15 · 16/16 · 14/14, 대조군 `domain9` → `200 r=1`). 저작 추론으로 쓴 서열 표현은 귀속을 걷었다 — `t2-2-q15` 「가장 큰 레버입니다」 → 「이 상황에서 먼저 볼 것」 · `t2-3-q5` 「표준 경로」 → 「맞는 수단」 · `t2-3-q6` 「셋을 섞을 때의 흔한 실수」 → 서술문.

---

## 2. 기각·판정 변경 — 1단계와 다르게 처리한 것

**전면 기각(고치지 않음)은 0건**이다. 수정안 단위로 다르게 판정한 것이 다섯이다.

### 2-1. Y3 — 「확인되지 않는다」가 아니라 **공식과 반대**다 (등급 상향, 수정은 채택)
1단계는 `webcrawl-data-source-connector.html` 에서 `credential`·`authenticat`·`protected`·`login` 이 0건임을 근거로 「지원한다고도 안 한다고도 적지 않는다」고 판정했다. 그 측정은 재현된다. 그런데 그 페이지는 **고객 관리형** 지식 베이스의 커넥터 문서이고(배너: "Starting September 30, 2026, the creation of new connectors for … Web Crawler will no longer be supported on customer-managed knowledge bases"), **관리형 지식 베이스에는 전용 페이지가 따로 있다** — `kb-managed-ds-webcrawler.html`(`200 r=0`, 16,386자):
- "Authentication for protected sites: basic, form-based, or SAML"
- "The Web Crawler supports four authentication methods … `NO_AUTH` … `BASIC_AUTH` … `FORM` … `SAML`"
- "If your site requires authentication, store your credentials in an AWS Secrets Manager secret"

`aip-t1-4-q11` 은 **관리형** 지식 베이스를 전제로 묻는 문항이고 정답 보기의 앞절이 「자격 증명으로 보호된 콘텐츠에 보통 맞지 않고」였으므로, 실제 등급은 🟡(미확인)이 아니라 **정답 보기의 절반이 공식과 반대**다. 1단계가 🔴 로 올리지 않은 판단은 측정 범위(커넥터 페이지 하나) 안에서는 옳았다 — **같은 기능에 페이지가 둘**이라 생긴 사각이다.

### 2-2. Y11 셋째 행 — 「데이터세트 유형은 프리뷰」는 **근거 없는 단정이 아니다**
1단계는 `evaluations-types.html` 에 `preview`·`dataset` 이 0건이라 「근거 없는 상태 단정 · md·조사 노트에도 0건」으로 적었다. 실제로는
- `bedrock-agentcore/latest/devguide/dataset-evaluations.html`(`200 r=0`) — "**Dataset evaluation is in public preview.** Features and APIs may change before general availability." · "two dataset runners that share the same dataset schema and ground truth format"
- 그리고 **md 에도 있었다** — `aip-t5-1.md` 의 평가 유형 표에 `| 데이터세트 (**프리뷰**) | 데이터세트 스키마 + 온디맨드·배치 러너 |` 행(1단계 정규식 `데이터세트 유형` 이 `데이터세트 (**프리뷰**)` 를 비켜 갔다).

그래서 **그 행을 지우지 않았고**(가드가 보존한다) 출처에 그 페이지를 달았다. W3 은 D-07 대로 상태를 오답 이유로 쓰지 않게 고쳤다 — 「데이터세트 평가는 SDK 러너가 시나리오마다 에이전트를 새로 호출해 평가를 돌리는 방식」.

### 2-3. Y10 — 「무료」에 요금 페이지를 다는 대신 **그 문항에서 과금을 뺐다**
1단계 수정안의 한 갈래는 해설의 「그 도구는 무료입니다」에 요금 페이지를 출처로 추가하는 것이었다. `q13` 이 묻는 것은 **Agent 의 프리뷰 상태**이고 과금은 `q11`(c=2)이 이미 요금 페이지와 함께 묻는다. 같은 사실을 두 문항 해설에 두면 한쪽 출처만 낡는 일이 다시 생기므로(1단계가 지적한 바로 그 경위) `q13` 에서는 과금 서술을 걷었다.
⚠️ 덤으로 찾은 것 — 지문이 「WA Tool**의** Well-Architected Agent」였는데 what-is 페이지는 둘을 "**two distinct ways**"·"differences between the **two services**" 로 적는다. 지문 1자리 + md 1줄을 「별개의 서비스」로 고쳤다(§3-4).

### 2-4. Y5 — 지문을 「개요 페이지가 … 적는 유형」으로 좁히지 않았다
1단계 수정안은 지문을 「개요 페이지가 그라운드 트루스를 요구한다고 적는 유형」으로 좁히는 것이었다. 그 형태는 **문서가 무엇을 적는지를 묻는 메타 문항**(Y7 과 같은 결함)이 된다. 대신 두 페이지 어느 쪽으로 읽어도 답이 하나인 사실 — 「기대 검색 텍스트를 데이터세트에 담아 검색 결과와 맞대 보는 유형」 — 로 다시 썼다.

### 2-5. 교차 노트의 재시도 항목 — **AIP 는 고칠 것이 없다**
`fix-dea` 의 공유 노트가 「boto3 기본 재시도 모드는 standard 가 됐으니 AIP 의 `AWS_NEW_RETRIES_2026` 옵트인 서술을 다시 보라」고 적었다. AIP 가 인용하는 것은 boto3 가이드가 아니라 `sdkref/latest/guide/feature-retry-behavior.html` 이고, 그 페이지는 **지금도** 이렇게 적는다: "The behavior described on this page requires opting in until it becomes the default behavior. Set AWS_NEW_RETRIES_2026=true in your environment. Without this setting, your SDK uses pre-2026 retry behavior". `max_attempts` 3(초기 1 + 재시도 2) · DynamoDB 계열 4 · 25 ms / 50 ms 도 그 페이지와 일치한다. **수정 없음.**

### 2-6. 그대로 둔 것
- `99-gaps.md`·`98-authoring-decisions.md` 의 ⛔ 축(DynamoDB 벡터 검색 · 청킹 전략 개수 · Guardrails 유해 범주 개수 · 평가자 개수 · Flows 개명 · 스토어 속도 서열 · 유창성 부재를 **정답으로** 쓰지 않는다)은 건드리지 않았다. `t4-3-q15` 의 **해설**에 남은 「유창성에 대응하는 내장 지표가 목록에 없다」는 1단계도 W1 만 걷으라고 권고한 자리다(정답 보기는 그 부재에 기대지 않는다).
- md 의 「공식 문서에서 확인되지 않습니다」 6줄(`aip-t3-3.md` 1 · `aip-t3-4.md` 5) — 의도된 시험 전략 서술.
- `t5-1-q3` 해설의 델타 지표 정의(1단계 §6 — 🟡 로 세지 않은 자리)는 손대지 않았다.

---

## 3. 범위 확장 — 보고가 하한이던 자리

| # | 1단계가 적은 범위 | 전수로 센 결과 | 처리 |
|---|---|---|---|
| 3-1 | Y1 `함께 바뀝\|함께 바뀌` — md **0자리** | md **1자리**(`aip-t1-6.md` — `함께** 바뀝니다`. 굵게가 낱말 사이에 끼어 정규식을 비켜 갔다) | 고쳤고, 가드 탐지기에 `\*{0,2}` 를 넣어 그 어형을 대조군으로 고정 |
| 3-2 | Y3 — 문항 3 · md 1줄 | + 고객 관리형 커넥터의 **신규 생성 미지원 공지**(2026-09-30)가 md 에 없었다 · `q10` W0 의 「커넥터가 **여섯 종류** 있습니다」(개요 페이지 목록일 뿐 — 관리형 문서에는 Salesforce·Zendesk·Custom 페이지도 있다) | md 에 공지 한 줄 추가(DEA 는 이미 적는다) · 개수를 걷고 「개요 페이지가 드는 커넥터」로 |
| 3-3 | Y4 — md 3자리(L68·L187·L228) | md **5자리** — 「기본은 **Classic**입니다」(흔한 함정) · 출처 항목 제목의 「기본 Classic」 | 다섯 다 |
| 3-4 | Y10 — 문항 2 · md 4자리 | + 「WA Tool의 Well-Architected Agent」(문항 지문 1 · md 1) | §2-3 |
| 3-5 | Y11 — 문항 3(md 각 0) | ⚠️ **「그라운드 트루스는 배치만 받는다」가 거짓**이다: `aip-t5-1.md` 2줄(본문 `배치만 그라운드 트루스를 세션 메타데이터로` · 출처 제목 `배치만 그라운드 트루스`) + `t5-1-q11` 해설 「배치뿐이고」. 공식 `ground-truth-evaluations.html` — "you provide reference inputs alongside your session spans when calling the **Evaluate API**"(= 온디맨드) · "cannot be used in **online** evaluation configurations" | md 를 「배치는 세션 메타데이터로 · 온디맨드는 Evaluate API 참조 입력으로 · 온라인은 불가」로. ⚠️ 이 때문에 `q11` 의 오답 [1](「온디맨드 평가 — 내가 스팬을 모아 호출하면 궤적이 비교됩니다」)이 **참에 가까워져** 지문을 「세션 발견과 스팬 수집까지 서비스에 맡기려면」으로 좁혔다(정답 유일성) |
| 3-6 | Y12 — 문항 16 · md 출처 누락 8 | + md 의 **출처 항목 제목이 그 페이지에 없는 사실을 귀속**한 3줄: `aip-t5-2.md` 의 Aurora 안내서 항목 「반복 스캔과 0.8.0 · 필터가 HNSW 스캔 뒤에 적용」(`AuroraPostgreSQL.VectorDB.html` 에 `iterative`·`0.8.0` **0건**, 대조군 `ef_construction` 2 · `0.6.0` 1) · `aip-t4-3.md` 의 `supported-frameworks.html` 항목 「`gen_ai.operation.name` 세 값 · `gen_ai.tool.name` · `session.id` 주입」(그 페이지에 `gen_ai`·`session.id` 0건 — Strands 페이지에 있다) · `aip-t1-3.md` 2줄 「가용성 변경 페이지가 … 2026-03-31 공지로 적습니다」 | 제목에서 걷고 그 사실을 담는 페이지를 새 출처로 추가 |
| 3-7 | Y12 `t4-3-q9` md 5줄 | `gen_ai.*` 를 프레임워크 일반으로 적은 md **4줄**(다섯째는 출처 제목) | 전부 「Strands 는/Strands 라면」으로 한정. 가드가 `gen_ai.` 줄마다 Strands 를 요구한다 |
| 3-8 | Y13 — 18문항 | 「기술 N.M.K」를 부르는데 시험 안내서 출처가 없는 문항 **+3**(`t1-1-q6` · `t1-4-q8` · `t1-5-q14`) | 추가. 가드는 **전수 불변식**(번호를 부르면 그 도메인 페이지가 출처에 있다)으로 걸었다 |
| 3-9 | (1단계 범위 밖) | `aip-t2-2` 가 「사용자 지정 모델 추론 경로는 둘」을 가르치는데 **그 사실을 담는 페이지가 md 출처에 없었다**(`model-customization-use.html` — "set up inference using one of the following options: Purchase Provisioned Throughput … Deploy custom model for on-demand inference"). `t3-3-q7` + `aip-t3-3.md` 의 「파티션 전 리전의 이벤트」(공식은 "all enabled Regions") | 출처 추가 · 문구 정정 |

---

## 4. flip 준비 상태

**1단계가 든 🟡 54문항은 20 Task 전부에서 0건이 됐다.** 다만 「🟡 0」과 「검수 불필요」는 다르다 — 아래 표의 **재작성 열**은 문항이 통째로 새로 쓰였으므로 검수자가 새 문항으로 읽어야 한다.

| Task | 재작성 | 보기 문구 | 해설·오답 근거 | 지문만 | 출처만 | md | 남은 것 |
|---|---|---|---|---|---|---|---|
| `t1-1` | — | q5,q13 | q1 | q6,q9,q10,q12,q14,q15 | — | 본문 | — |
| **`t1-2`** | — | — | — | q2,q3,q13,q15 | — | — | ✅ 지문 꼬리 문장만 손댔다 |
| **`t1-3`** | — | — | q15 | q1,q3,q10,q11,q14 | q6,q7 | 본문 | ✅ |
| `t1-4` | q9,q11 | — | q1,q3,q4,q6,q10,q12 | q2 | q5,q8 | 본문 | `q6`↔`q11` ACL 절반 겹침(아래) |
| `t1-5` | q8 | q1 | — | q7,q11 | q13,q14,q15 | 본문 | — |
| `t1-6` | q15 | — | q5 | q8,q11,q12,q13,q14 | q4,q9 | 본문 | 틀 `q14` |
| `t2-1` | — | — | — | q2,q4,q7,q8,q10,q11 | q13 | — | 틀 `q2` |
| `t2-2` | q4,q7,q10 | — | q2,q11,q15 | q5,q8,q9 | — | 본문 | 틀 `q5` |
| `t2-3` | — | q5 | q6,q15 | q2,q14 | — | 출처만 | — |
| **`t2-4`** | — | — | q8 | q3,q11,q13 | q15 | 출처만 | 틀 `q3`·`q10`·`q13` |
| **`t2-5`** | — | q10 | — | — | q8,q9 | 출처만 | ✅ |
| `t3-1` | — | — | q2,q5,q13,q14 | — | — | 본문 | — |
| **`t3-2`** | — | — | — | — | q6 | 출처만 | ✅ 출처 한 줄 |
| `t3-3` | q4,q9 | — | q7,q14 | — | q5,q15 | 본문 | — |
| `t3-4` | q7 | — | q5,q11 | — | — | 본문 | — |
| **`t4-1`** | — | q11 | q7 | — | — | — | 틀 `q7` |
| `t4-2` | — | — | q11 | — | q5 | 출처만 | 틀 `q4` |
| `t4-3` | — | — | q9,q15 | q3,q4 | — | 본문 | 틀 `q14` |
| `t5-1` | — | — | q10,q11 | — | q1 | 본문 | — |
| **`t5-2`** | q3,q4 | — | — | — | q7,q11,q14 | 본문 | 재작성 2문항 검수 |

- **게이트(7 Task 105문항 — D1 2 · D2 2 · D3 1 · D4 1 · D5 1)를 가장 싸게 여는 조합**은 1단계와 같다: `t1-2` + `t1-3` · `t2-4` + `t2-5` · `t3-2` · `t4-1` · `t5-2`. 이 일곱 Task 에서 **재작성된 문항은 `t5-2-q3`·`q4` 둘뿐**이고 나머지는 지문 꼬리·출처·문구 수준이다. `t5-2` 대신 D5 의 다른 Task(`t5-1` — 재작성 0)를 고르면 **재작성 0문항으로 게이트를 열 수 있다.**
- ⚠️ **flip 직전에 그 Task 의 출처를 한 번 더 열어 본다** — 저작 뒤 사흘 사이에 공식 문장 둘이 사라졌고(Y4·Y10), 1단계와 2단계 사이 **하루**에도 인용 대상이 달랐다(§2-1·§2-2 는 페이지가 움직인 것이 아니라 다른 페이지가 있었던 경우지만, DEA 쪽은 실제로 하루 만에 리다이렉트됐다).
- **남은 것**
  - **G2 의 「~자는 제안이 나왔습니다」 틀 9문항**(`t1-6-q14` · `t2-1-q2` · `t2-2-q5` · `t2-4-q3` · `q10` · `q13` · `t4-1-q7` · `t4-2-q4` · `t4-3-q14`) — 전부 정답이 「성립하지 않는다」 쪽이라 틀만 보고 방향을 고를 수 있다. 사실 결함은 없다. 고치려면 몇 건을 **성립하는 제안**으로 뒤집어야 하므로(= 정답 내용 변경) 사람 판단과 함께 하는 편이 맞다. 12건 가운데 3건(`t1-1-q13` · `t1-4-q11` · `t2-2-q10`)은 이번에 다른 이유로 지문이 바뀌며 사라졌다. ⚠️ 어형을 넓혀 「계획이/설계가 올라왔습니다」까지 세면 **15문항**이다(+ `t1-6-q11` · `t2-2-q9` · `q12` · `t3-4-q5` · `t4-1-q15` · `t4-2-q7`) — 1단계의 12는 「제안이」 어형만 센 하한이다.
  - **`aip-t1-4-q6`(c=1) ↔ `q11`(c=2)** — 둘 다 「Web Crawler 에는 ACL 이 걸리지 않는다」가 정답의 일부다(지문+정답 자카드 0.22). `q11` 은 이제 인증 지원·증분 동기화·robots.txt 를 함께 가르는 문항이라 각도는 다르지만, 15문항 세트에서 한쪽이 다른 쪽의 힌트가 된다. 1단계 수정안 자체가 `q11` 에 ACL 절을 남기는 것이었고 이번에 그대로 따랐다.
  - **학습문서 전문 통독** — 1단계가 사각으로 적은 자리다. 이번에 문항 수정에 딸린 **표적 대조만으로 md 에서 1단계 밖의 결함 셋**(§3-5 의 「배치만」 · §3-6 의 출처 제목 귀속 · §3-2 의 커넥터 개수)이 나왔으므로, 「시험 직전 요약」·「자가 점검」 두 절을 같은 Task 문항 정답과 맞대는 별 패스를 권한다.

---

## 5. 컨트롤러 요청

- [ ] **`CLAUDE.md` 기준선 줄**: AIP 분 **+34**(`aip_v2_fix_test.dart`).
- [ ] **교차 자격증 — AIF(1단계 §5-1 그대로 유효, 이번에 재측정)**: `flutter_app/assets/content/aif/aif-t4-1.md:480` 이 `**"If you don't specify a tier, your guardrail uses Classic tier."**` 를 영문 직접 인용하고 `flutter_app/test/aif_facts_test.dart:503~515` 가 그 문장을 **보존 가드**로 고정한다. 현행 `guardrails-tiers.html` 에 그 문장이 없다(§1 Y4). ⚠️ **가드를 먼저 뒤집고** md 를 고쳐야 한다. `fix2-aif` 가 볼 수 있게 공유 노트(`aip-phase2-cross-cert.md` §1)에 남겼다.
- [ ] **교차 자격증 — CLF**: `clf/t1-4.questions.json`·`clf/t3-8.questions.json` 이 Kendra 를 2회씩 들면서 `신규 고객`·`유지 관리` 가 0건이다(레포 grep 실측. 가르치는 층인지 오답 보기인지는 재지 않았다).
- [ ] **교차 자격증 — Bedrock 지식 베이스·AgentCore 평가를 다루는 자격증(aif·dea·mla)**: §2-1(관리형 Web Crawler 의 인증 지원) · §3-5(그라운드 트루스는 배치 전용이 아니다) · §3-6(반복 인덱스 스캔 Note 는 Aurora 안내서에 없다)이 같은 서술을 갖고 있는지. 레포 grep 으로 `배치만 그라운드`·`데이터세트 유형은 프리뷰` 는 AIP 밖 **0건**, `Web Crawler` 는 `dea-t2-4.md:225`(커넥터 공지 — 옳다) 하나였다.
- [ ] **소유 범위 밖이라 손대지 않은 문서**(갱신 권고): `docs/content-research/AIP-C01/99-gaps.md` — 새 갭 넷(① 관리형 Web Crawler 는 인증을 지원한다 · 같은 기능에 페이지가 둘 ② `guardrails-tiers.html` 의 기본값 문장 소실 ③ 그라운드 트루스는 배치 전용이 아니다 · 데이터세트 평가의 프리뷰는 `dataset-evaluations.html` 에 있다 ④ `well-architected.html` 재구성과 Agent/Tool 「two distinct ways」) · `docs/saa-review/2026-11-16-aip-review-prep.md`(출처 수·문항 수치가 이 배치로 달라졌다) · `HANDOFF.md`·`WORKLIST.md`.
- [ ] **정답 인덱스 변경이 필요한 문항**: **0건**.
- [ ] 전역 가드 등재: **없음** — `soa_dea_`·`mla_aif_`·`scs_question_propagation_test` 에 `test/aip_*` 트립와이어가 없다(grep 0건). `source_url_retired_test` 의 `retiredUrls` 에 넣을 죽은 슬러그도 이번에는 없다(새 URL 33개 전부 `200 r=0`).

---

## 6. 검증 기록

### 측정에 쓴 공식 페이지 (전부 2026-11-17 `curl -sL` · `200 r=0`)
`bedrock/latest/userguide/` — `flows-nodes` · `flows` · `flows-version-create` · `prompt-management` · `prompt-management-deploy` · `prompt-management-version-create` · `knowledge-base-setup` · `knowledge-base` · `webcrawl-data-source-connector` · `kb-managed-ds-webcrawler` · `confluence-data-source-connector` · `kb-direct-ingestion` · `kb-test-agentic-retrieve` · `kb-test-config` · `kb-chunking` · `guardrails-tiers` · `guardrails-prompt-attack` · `guardrails-content-filters` · `guardrails-components` · `guardrails` · `guardrails-word-filters` · `evaluation` · `knowledge-base-evaluation-metrics` · `knowledge-base-build-kendra-genai-index` · `prov-throughput` · `prov-thru-purchase` · `model-customization-use` · `batch-inference` · `prompt-routing` / `bedrock/latest/APIReference/` — `API_agent_PromptFlowNodeResourceConfiguration` · `API_GuardrailContentFiltersTierConfig` · `API_runtime_Converse` / `bedrock-agentcore/latest/devguide/` — `harness` · `gateway` · `gateway-rate-limits` · `gateway-using-mcp-semantic-search` · `evaluations-types` · `dataset-evaluations` · `ground-truth-evaluations` · `how-it-works-evaluations` · `supported-frameworks` · `supported-frameworks-strands` · `observability-tool-metrics` / `sagemaker/latest/dg/` — `build-your-own-processing-container` · `byoc-input-and-output` · `large-model-inference-container-docs` · `model-cards` · `clarify-availability-change` / `wellarchitected/latest/` — `generative-ai-lens/generative-ai-lens` · `responsible-ai-lens/responsible-ai-lens` · `userguide/well-architected` · `userguide/release-notes` · `agentic-ai-lens/agentsec06-bp02` · `agentperf02-bp01` · `agentcost01-bp01` / 그 밖 — `kendra/…/kendra-availability-change` · `comprehend/…/comprehend-availability-change` · `general/latest/gr/maintenance_services` · `full_shutdown_services` · `glue/…/components-overview` · `catalog-and-crawler` · `awscloudtrail/…/cloudtrail-concepts` · `cloudtrail-user-guide` · `lake-formation/…/what-is-lake-formation` · `opensearch-service/…/vector-search` · `bp-sharding` · `AmazonRDS/…/AuroraPostgreSQL.VectorDB` · `sdkref/…/feature-retry-behavior` · `aws.amazon.com/well-architected-tool/pricing/` · `ko_kr/aws-certification/…/ai-professional-01-domain{1,2,3,4,5}`.
- 리다이렉트된 것 하나: 추측으로 넣어 본 `guardrails-create.html` → `200 r=1`(가이드 인덱스) — 콘텐츠에는 쓰지 않았다.
- 관리형 Web Crawler·데이터세트 평가·그라운드 트루스 평가 세 페이지는 AWS 문서 검색으로 찾은 뒤 `curl` 로 다시 받아 문장을 확인했다.

### 치환
- **멱등 스크립트**: 수정 전 40파일을 scratchpad 에 백업하고, 「백업 원본 + 전 배치(A~F)」를 매번 처음부터 적용해 작업 트리에 썼다. 쓰기 **전에** 단정한 것 — 문항 JSON 왕복 재현(20파일 전부 바이트 일치) · 보호 필드(`correct`·`skill`·`section`·`verified`·`id`·`examGuideTaskId`) 불변 · 길이 단서 양방향 · 지문/정답의 자기 프레임 0 · 평문 · 해설 ≤ 400자 · G-84(문항 출처 ⊆ md 프런트매터) · 파일당 4/4/4/3 · `foundational` ≥ 3 · md `CR 수 == LF 수` · 프런트매터 ↔ 「출처」 절 URL 집합 일치 · md 치환 횟수(45건 전부 기대 횟수와 일치). 하나라도 어긋나면 **아무 파일도 쓰지 않는다.**
- md 출처 삽입은 `lastVerified:` 바로 **앞**(목록 끝)이다. 본문을 고친 md 17편의 `lastVerified` 를 `2026-11-17` 로 올렸다.
- 재작성·교체한 12문항은 형제 문항 전수와 정답·지문+정답 자카드(원형·조사벗김)를 다시 쟀다 — 최고 0.22(`t1-4-q11`↔`q6`, §4), 임계 0.33 이상 0쌍.

### 민감도
- `aip_v2_fix_test.dart` 를 **수정 전 원본**에 실행: **28건 레드**(34건 중 통과 6건은 대조군·보존 단정). 복구 후 `sha256sum -c` 불일치 **0건**, `git diff --shortstat` 가 덮기 전과 같은 `37 files changed, 605 insertions(+), 322 deletions(-)`.
- ⚠️ 그 1분 남짓 동안 작업 트리의 aip 파일이 원본 상태였다(다른 세션은 `aip/` 를 읽지 않는다).

### 가드 설계 메모
- **`verified` 를 단정하지 않는다** — 구조(보기 4개 · Task 당 15)와 정답 인덱스 불변으로 대신했다.
- **탐지기가 정정문·의도된 서술을 걸지 않는지** 대조군으로 고정했다: M2 탐지기는 md 의 「공식 문서에서 확인되지 않습니다」(6줄)를 걸지 않고, 메타 문구 탐지기는 문항만 본다(md 의 절 제목 「시험 포인트」 20개가 대조군).
- **보존 가드 둘** — Y2 의 다른 쪽(`t4-2-q5` 의 반복 인덱스 스캔)과 Y11 의 데이터세트 프리뷰 행. 「틀렸다」는 보고를 따라 **참인 문장을 지우는 것**을 막는다.
- **전수 불변식 셋**을 새로 걸었다(AIP 에 없던 것): 「기술 N.M.K 를 부르면 그 도메인의 시험 안내서 페이지가 출처에 있다」 · 「프런트매터 ↔ 출처 절 URL 집합 일치 + `lastVerified` 가 sources 뒤」 · 「해설 ≤ 400자」.
- ⚠️ 대조군 하한 하나를 추측으로 적었다가 틀렸다(「번호를 부르는 문항 ≥ 20」 — 실측 14). 실측값 기준(≥ 12)으로 고쳤다.

### 환경 메모
- 한국어·이스케이프가 든 스크립트를 bash 히어독으로 넘기다 두 번 막혔다(셸 따옴표 파싱 1 · `'''…\\r\\n…'''` 안의 실제 CR 1). 배치 파일은 파일 쓰기 도구로 썼다.
- scratchpad(세션 밖으로 나가지 않는다)에 측정 스크립트·내려받은 페이지 본문·수정 전 백업이 있다. 저장소에 쓴 것은 `aip/` 37파일 · 가드 1 · 이 보고서 1 이고, 저장소 밖에는 공유 노트 폴더의 `aip-phase2-cross-cert.md` 하나다.
