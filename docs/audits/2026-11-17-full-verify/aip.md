# AIP-C01 전수 검증 — 2026-11-17

> 범위: `flutter_app/assets/content/aip/` 학습문서 20편 · 문항 300개(**전부 드래프트 · `verified: true` 0건**) · `assets/exam_guides/AIP-C01.json`.
> 기준 HEAD `4b83461`(`develop`). **콘텐츠·코드·테스트는 한 글자도 고치지 않았다**(`git status`·`git diff --stat` 실측: 추적 파일 변경 0, 새 파일은 이 보고서뿐). 측정 스크립트·내려받은 페이지 본문은 세션 scratchpad에 있다. ⚠️ **예외 둘**: 읽기 전용 측정 스크립트 `/tmp/fix.py`·`/tmp/fix2.py`(Git Bash 의 `/tmp` — 저장소 밖)를 scratchpad 밖에 만들었다. 둘 다 `aip/*.md` 를 **읽어** 프런트매터 ↔ 「출처」 절을 대조하고 결과를 scratchpad 에 쓰는 스크립트이고 저장소에는 아무것도 쓰지 않는다. 지우지 않고 그대로 뒀다.
> 이 세션은 도중에 모델이 교체돼(Opus 5 → Fable 5.2) 교체 뒤 **300문항 대조를 처음부터 다시 했다.** 교체 전 턴이 저장소 파일을 고친 것은 없다.
>
> **어떻게 셌는가 (2단계가 다시 재지 않도록)**
> - **문항 300개 전부**를 지문·보기 4개·해설·오답 근거·출처까지 읽고, 문항이 인용한 **고유 URL 166개를 전부 열어**(142개는 `curl -sL` 본문 추출 + 탐침, 24개는 AWS 문서 리더로 전문) **그 문항이 단정하는 사실을 본문에서 찾았다.** 탐침은 영문 원문 낱말로 넣었고, **0건이 나오면 같은 페이지의 다른 표현·알려진 양성 대조군을 다시 넣은 뒤에만** 「없다」로 적었다(§6에 대조군을 함께 적었다).
> - **학습문서 20편은 전문 통독하지 않았다.** 문항 대조에서 결함이 나온 주장마다 **md 20편 + 문항 20파일을 정규식 전수**로 다시 세어 줄 번호를 적었다(문항 가드는 `.md`를 보지 않는다). 즉 **「문항에 한 번도 닿지 않는 md 전용 서술」은 이 검증의 사각**이다 — §7 끝에 적었다.
> - 구조 수치(커버리지·정답 인덱스·난이도·G-84·앵커·평문)는 **독립 스크립트로 다시 재서** 착수 노트 `2026-11-16-aip-review-prep.md`와 대조했다. 전부 일치했다.
> - `99-gaps.md`(G-01~G-69)·`98-authoring-decisions.md`가 「묻지 않는다」·「단정하지 않는다」로 판정한 축(DynamoDB 벡터 검색 · 청킹 전략 개수 · Guardrails 유해 범주 개수 · 평가자 개수 · Flows 개명 · 스토어 속도 서열 등)은 **결함으로 적지 않았다.** 그 축을 문항이 지켰는지는 정규식 14종으로 따로 쟀다(§4).
> - URL 생사는 계약대로 다시 재지 않았다. **새로 제안하는 출처 URL만** `curl -sL`로 쟀고 전부 `200 r=0`이다(대조군: 같은 가이드의 틀린 슬러그 `bedrock/latest/userguide/zz-bogus-control.html` → `200 r=1`).

## 0. 요약

| 판정 | 수 | 뜻 |
|---|---|---|
| 🔴 | **0** | 사실이 거짓 · 정답이 둘 · 정답이 틀림 (즉시 수정) |
| 🟡 | **문항 54개 + 학습문서 본문 9편** (13묶음) | 불완전·모호·출처가 사실을 담지 않음 (수정 권고) |
| 🟢 | 6묶음 | 품질(문구·중복·틀 반복·정밀도) — 사실은 옳다 |
| ✅ | 문항 **246/300** | 사실·인용 통과 |

- **공개 문항 중 🔴: 0건** (공개 문항 자체가 0개다 — 전부 드래프트).
- 🔴는 없다. **정답 인덱스를 바꿔야 하는 문항은 한 건도 찾지 못했다.** 다만 🟡 가운데 **정답 보기의 전제가 공식에서 확인되지 않는 것이 셋**이다(Y1 `t1-6-q15` · Y2 `t1-5-q8` · Y3 `t1-4-q11`) — flip 전에 반드시 닫아야 하고 §7의 1순위다.
- 🟡 54문항의 분해: **핵심 36문항**(Y1~Y12 — 미확인 전제·사라진 공식 문장·저작 메모·메타 문항·상태 누락·출처 교체)과 **가벼운 18문항**(Y13 — 정답 근거가 시험 가이드 예시 목록인데 출처는 다른 페이지를 단 것). 본문 서술을 고쳐야 하는 학습문서는 9편(`aip-t1-1`·`t1-4`·`t1-5`·`t3-1`·`t3-4`·`t4-2`·`t4-3`·`t5-1`·`t5-2`)이고, 출처 목록만 늘리면 되는 편은 여기에 세지 않았다.
- 줄기는 셋이다. ① **「URL 은 200인데 그 페이지에 그 사실이 없다」가 인용 페이지 23개에서 나왔다**(이 레포의 반복 결함이 가장 새 자격증에도 그대로 있다). 대부분 사실은 참이고 **옆 페이지에 있다** — 16문항은 출처 한 줄 추가로 닫힌다(Y12). ② **측정의 유효 기간**: 저작(11-14~16) 뒤 공식 페이지가 움직여 **인용 문장이 사라진 자리가 둘**이다(Y4 Guardrails tier 기본값 · Y10 Well-Architected 개요 페이지). ③ **저작 과정 메모가 학습자 문장에 남았다**(Y6 — 「이 트랙에서 얻지 못했습니다」·「같은 추출에서 … 본문이 읽혔음이 확인됩니다」). MLA 에만 있는 M2 기계 가드가 AIP 에는 없어서 통과했다.
- `prescreen` qualityFlags(전체 300문항, `node tool/prescreen.mjs build aip` 실측): **length-cue 0 · meta-phrasing 0 · authoring-memo 0 · explanation-long 0**, 품질 신호 문항 0/300(0%). 구조·정합성 플래그 **0건**, 뱅크 플래그 0 Task, Task 내 중복 후보 **0쌍**. ⚠️ 그 0은 **탐지기가 아는 문구에 대한 0**이다 — 탐지기 밖의 어형으로 메타 문구 8종 70여 자리를 찾았다(Y6·Y7·G1~G3).
- 검증한 출처 URL: **문항 고유 166개 전부**(md 프런트매터 고유 188개 중 문항이 쓰는 166개). 그중 **「그 사실을 담지 않음」 23개 페이지**(§6 목록).
- 0건으로 확인한 축(셈법은 §4): 구조 플래그 0 · 정답 인덱스 80/80/80/60 · `foundational` Task 마다 3 · 공식 기술 98/98 커버 · `skill` 접두사 불일치 0 · G-84 위반 0(파일별·전역 둘 다) · md 프런트매터 ↔ 「출처」 절 불일치 0/20 · `section` 앵커 누락 0 · 문항 평문 위반 0 · 길이 단서 양방향 0 · 범위 외 서비스가 정답인 문항 0 · ⛔ 축 위반 0.

## 1. 🔴 (문항·학습문서)

**0건.** 300문항의 정답 보기를 인용 페이지와 대조해 「정답이 거짓」·「오답 보기가 참이라 정답이 둘」인 자리를 찾지 못했다. 정답 유일성을 깨뜨릴 수 있는 후보는 🟡 Y1·Y2·Y3·Y5 이고 각 항목에 **왜 🔴로 올리지 않았는지**를 적었다.

## 2. 🟡

### Y1. `aip-t1-6-q15` — 「프롬프트를 고치면 그것을 쓰는 플로들이 함께 바뀐다」는 공식에서 확인되지 않는다
- **공개 여부**: verified false
- **현재 정답 인덱스**: 2
- **결함**: 정답 보기 「그 프롬프트를 쓰는 플로들이 함께 바뀌므로, 버전을 고정해 …」와 해설 첫 문장 「Prompt management의 프롬프트를 프롬프트 노드로 넣으면 한 프롬프트를 고쳤을 때 그것을 쓰는 플로들이 함께 바뀝니다」, W0 「사본을 들고 있는 것이 아니라 함께 바뀌는 쪽」이 **인용한 두 페이지 어디에도 없다.** 오답 보기 [0]·[3](「사본」·「복사」)을 틀리게 만드는 근거도 같은 문장 하나뿐이라, 그 문장이 무너지면 정답 유일성이 함께 무너진다.
- **공식 근거**:
  - `bedrock/latest/userguide/flows-nodes.html` — 「A prompt node defines a prompt to use in the flow. You can use a prompt from Prompt management or define one inline in the node.」 「If you use a prompt from Prompt management, the object should be in the following general structure: { "resource": { "promptArn": "string" } }」 (전파 서술 없음)
  - `bedrock/latest/APIReference/API_agent_PromptFlowNodeResourceConfiguration.html`(200 r=0) — `promptArn` 「Pattern: … prompt/[0-9a-zA-Z]{10}(?::[0-9]{1,5})?」 → **ARN 에 프롬프트 버전을 붙여 고정할 수 있다.** 버전을 붙인 노드는 프롬프트 초안이 바뀌어도 그대로다.
  - `bedrock/latest/userguide/flows.html` — 「deploying immutable workflows to move from testing to production」 (인용 페이지. `reus` 0건)
- **왜 🔴가 아닌가**: 버전을 붙이지 않은 ARN 이 초안을 따라가는지는 공식 문장으로 확인하지 못했다(가능성은 있다). 거짓이라고 단정할 근거도 없다.
- **수정안**: 지문·정답을 **공식이 적는 것**으로 다시 쓴다(정답 인덱스 2 유지 가능). 예 — 지문: 「여러 플로가 Prompt management 의 같은 프롬프트를 프롬프트 노드로 씁니다. 운영 플로가 어느 구성을 쓰는지 고정하려면 무엇을 합니까?」 / 정답: 「프롬프트 노드가 가리키는 프롬프트 ARN 에 버전을 지정하고, 플로는 버전으로 배포합니다」. 해설에서 「함께 바뀝니다」·「그것이 재사용의 실체」를 걷고 `promptArn` 의 버전 접미사와 불변 워크플로 배포를 적는다. 출처에 위 API 참조 페이지 추가(G-84: `aip-t1-6.md` 프런트매터·「출처」 절에도 함께).
- **전수**: `함께 바뀝|함께 바뀌` — md **0자리** · 문항 **1문항**(q15 의 정답 보기·해설·W0).

### Y2. `aip-t1-5-q8` + `aip-t1-5.md` — 「Aurora 에서 필터 필드를 지정하지 않으면 결과가 조용히 빠진다」는 확인되지 않고, 인용 페이지가 적는 원인은 다른 것이다
- **공개 여부**: verified false
- **현재 정답 인덱스**: 3
- **결함**: 정답 「필터에 쓰는 필드를 벡터 스토어 설정에서 지정했는지 봅니다. 지정하지 않으면 결과가 조용히 빠집니다」의 뒷절(조용한 누락)이 인용 페이지에 없다. **그 페이지가 「필터를 걸면 결과가 적다」의 원인으로 적는 것은 반복 인덱스 스캔**이고, 같은 증상을 `aip-t4-2-q5`(정답 인덱스 0)와 `aip-t4-2`·`t4-3`·`t5-2` md 가 **반복 스캔으로** 가르친다. 학습자는 「Aurora + 필터 + 오류 없이 결과가 준다」에 두 Task 에서 다른 답을 배운다(계약 축 ④).
- **공식 근거**: `bedrock/latest/userguide/knowledge-base-setup.html`(q8 의 인용 페이지)
  - 「(If you use an Amazon Aurora database and want to set up filtering on metadata) Fields for metadata that you associate with your source files. If you plan to set up filtering in other vector stores, you don't have to set up these fields for filtering.」 — **설정 요건**까지만 적는다.
  - 「custom_metadata JSONB Custom metadata field customMetadataField **Optional** field …」 「If you're using the custom metadata field, you must also create a GIN index on this column.」
  - 「Note If you use metadata filtering with your knowledge base, we recommend enabling HNSW iterative index scans (requires pgvector 0.8.0 or later). **Without iterative scans, selective metadata filters can return fewer results than expected because filtering is applied after the HNSW index scan.**」
- **왜 🔴가 아닌가**: 메타데이터 열 없이 필터를 걸었을 때의 실제 동작(빈 결과인지 오류인지)을 공식이 적지 않아 거짓이라고 단정할 수 없다. 지문은 「비어 온다」, `t4-2-q5` 는 「적게 온다」로 증상도 한 낱말 다르다.
- **수정안**: 「조용히 빠진다」를 걷고 **공식이 적는 요건**으로 좁힌다 — 정답: 「필터에 쓸 메타데이터 필드(열)를 벡터 스토어에 만들어 두었는지 봅니다. Aurora 는 다른 스토어와 달리 그 필드를 직접 준비해야 합니다」. 해설에 반복 스캔 Note 를 한 문장 더해 `t4-2-q5` 와 **원인 둘을 가르는 기준**(필드가 없다 ↔ 필드는 있는데 결과가 모자란다)을 적는다. md 도 같이 고친다.
- **전수**: `필터 필드|필터에 쓰는 필드` — md **5자리**(`aip-t1-5.md` L75·L129·L177·L191·L247) · 문항 **1문항**(q8 의 정답·해설·W1·W2·출처 제목). 그중 「조용」과 함께 단정하는 줄은 L75·L129·L191.

### Y3. `aip-t1-4-q11`·`q6`·`q10` + `aip-t1-4.md` — 「Web Crawler 는 자격 증명으로 보호된 내부 콘텐츠에 보통 맞지 않는다」는 확인되지 않는다
- **공개 여부**: 셋 다 verified false
- **현재 정답 인덱스**: q11 **2** · q6 **1** · q10 **1**
- **결함**: `q11` 은 「Web Crawler 의 두 가지 한계」를 묻고 정답이 「자격 증명으로 보호된 콘텐츠에 보통 맞지 않고, 검색 시점 필터링도 그 소스에는 걸리지 않습니다」다. **뒷절(ACL 필터링 제외)만 공식에 있고 앞절은 인용 페이지에도, 커넥터 전용 페이지에도, 조사 노트(`95`·`99`)에도 없다.** `q6` 은 해설에서, `q10` 은 W0 에서 같은 문장을 쓴다(둘의 정답은 영향받지 않는다).
- **공식 근거**:
  - `bedrock/latest/userguide/knowledge-base.html`(전문 통독) — 「connectors for Amazon S3, SharePoint, Confluence, Google Drive, OneDrive, Web Crawler, along with document-level permission filtering using Access Control Lists (except for Web Crawler) at retrieval time.」
  - `bedrock/latest/userguide/webcrawl-data-source-connector.html` — 탐침 `credential`·`authenticat`·`protected`·`login`·`password`·`internal`·`sign in` **전부 0건**(대조군: `permission` 3건 · `robots` 12건). 실재하는 문장: 「you must only use the Web Crawler to index your own web pages, or web pages that you have authorization to crawl and must respect robots.txt configurations」 · 「All data that you sync from your data source becomes available to anyone with bedrock:Retrieve permissions」
- **수정안**: `q11` — 지문 「자격 증명으로 보호된 사내 위키」를 「팀마다 열람 권한이 다른 사내 위키」로, 정답을 **확인된 둘**로 바꾼다: 「검색 시점 ACL 문서 수준 필터링이 그 소스에는 걸리지 않고, 동기화한 내용은 `bedrock:Retrieve` 권한이 있는 누구나 검색합니다」(정답 인덱스 2 유지). `q6` 해설·`q10` W0 에서 그 구절을 걷는다. 출처에 `webcrawl-data-source-connector.html` 추가.
- **전수**: `자격 증명(으로| 기반으로)? ?보호` — md **1자리**(`aip-t1-4.md` L157) · 문항 **3문항**(q6 해설 · q10 W0 · q11 지문+정답+해설).

### Y4. `aip-t3-1-q14` + `aip-t3-1.md` — 「tier 를 지정하지 않으면 Classic」이 인용 페이지에서 사라졌다
- **공개 여부**: verified false
- **현재 정답 인덱스**: 1 (정답 보기 자체는 영향 없다 — 결함은 해설 한 절)
- **결함**: 해설 「tier를 지정하지 않으면 Classic이고」의 근거 문장이 `guardrails-tiers.html` 에 **지금은 없다.** 레포 기록(`aif_facts_test.dart` L503~515 · `aif-t4-1.md` L474)이 2026-11-06 에 그 페이지에서 `If you don't specify a tier, your guardrail uses Classic tier.` 를 글자 그대로 확인했으므로 **페이지가 개정된 것**이다(측정의 유효 기간).
- **공식 근거**: `bedrock/latest/userguide/guardrails-tiers.html` — `curl` 본문 4,528자 + AWS 문서 리더 전문 4,815자 **두 방법 모두** `specify a tier`·`uses Classic`·`If you do`·`default` 0건(대조군: `re-tested` 1 · `1,000` 1 · `200` 1 · `French` 2). API 참조 `API_GuardrailContentFiltersTierConfig.html`·`API_GuardrailContentPolicyConfig.html` 도 기본값을 적지 않는다(`tierConfig … Required: No` 까지).
- **현행 페이지에 새로 있는 것**(보강 재료): Classic 의 문맥 근거 확인은 「Strict grounding only」 · 「Standard tier for contextual grounding checks is available in the following Regions」(11개 리전) · 그 밖의 리전에서 Standard 를 지정하면 「fail with a validation error」.
- **수정안**: 「지정하지 않으면 Classic」 문장을 q14 해설과 md 3자리에서 걷는다(공식에 없으면 수정안을 내지 않는다는 계약 규율 — **대체 단정을 새로 쓰지 않는다**). 필요하면 위 「Strict grounding only」를 Classic 의 성질로 대신 적는다.
- **전수**: `지정하지 않으면 Classic` — md **3자리**(`aip-t3-1.md` L68·L187·L228) · 문항 **1문항**(q14 해설). ⚠️ 다른 자격증에도 있다 → §5.

### Y5. `aip-t3-4-q7` ↔ `aip-t5-1-q10` — 「그라운드 트루스가 필수인가」를 두 문항이 다르게 가르친다 (공식 내부 어긋남)
- **공개 여부**: 둘 다 verified false
- **현재 정답 인덱스**: `t3-4-q7` **2** · `t5-1-q10` **1**
- **결함**: `t3-4-q7` 은 「작업 유형 넷 가운데 LLM 기반 RAG 평가만 데이터세트에 그라운드 트루스가 있어야 합니다」로, `t5-1-q10` 은 「(Retrieve only 에서) 커버리지는 그라운드 트루스가 있어야 계산됩니다. 관련성은 그라운드 트루스 없이도 나옵니다」로 가르친다. 앞 문항대로면 뒤 문항의 상황(그라운드 트루스 없이 RAG 평가를 구성했다)이 성립하지 않는다.
- **공식 근거**: 두 페이지가 실제로 다르게 적는다.
  - `bedrock/latest/userguide/evaluation.html`(q7 인용) — 「The dataset **must also include 'ground truth'** or the expected retrieved texts and responses for the queries」
  - `bedrock/latest/userguide/knowledge-base-evaluation-metrics.html`(q10 인용) — Context coverage 행에만 「You must supply a ground truth in your prompt dataset to use this metric.」(나머지 11개 지표 행에는 그 문장이 없다)
- **왜 🔴가 아닌가**: 두 문항 모두 **자기 인용 페이지와는 일치**한다.
- **수정안**: 더 구체적인 **지표 페이지를 정본**으로 삼아 `t3-4-q7` 해설에 한 문장을 더한다 — 「개요 페이지는 RAG 평가 데이터세트가 그라운드 트루스를 담아야 한다고 적고, 지표 페이지는 그 요구를 컨텍스트 커버리지 지표에 붙여 적습니다」. 지문도 「반드시 담아야 하는 것」 → 「개요 페이지가 그라운드 트루스를 요구한다고 적는 유형」으로 좁힌다(정답 인덱스 2 유지). md 10자리는 같은 방향으로 정렬.
- **전수**: `그라운드 트루스 … (필수|있어야|반드시)|정답지를 반드시` — md **10자리**(`aip-t3-4.md` L73·L144·L202 · `aip-t5-1.md` L275·L296·L387·L406·L458 · `aip-t5-2.md` L190·L324) · 문항 **2문항**.

### Y6. `aip-t3-4-q5`·`aip-t3-4-q11` + `aip-t3-4.md` — 저작 과정 메모(M2)가 학습자 문장에 남았다
- **공개 여부**: 둘 다 verified false
- **현재 정답 인덱스**: q5 **0** · q11 **2** (정답은 영향 없다)
- **결함**: 루브릭 §2 「작성자 메모 금지(M2)」가 금지하는 종류다 — 확인되지 않은 것은 해설에서 빼고 판단 보류는 승인 로그에 남긴다.
  - `q5` 해설: 「… 근거는 **이 트랙에서 얻지 못했습니다**」 / W1 「… 근거를 얻지 못했습니다」 / W2 「… 근거를 얻지 못한 전제입니다」
  - `q11` 해설: 「프롬프트 관리·Flows·Bedrock 평가 **문서 전수에서** 공정성·편향에 해당하는 서술이 잡히지 않았고, **같은 추출에서 variant·node·metric은 정상적으로 잡혀 본문이 읽혔음이 확인됩니다**」(측정 방법론·대조군이 그대로 해설에 들어갔다) / W0 「… 전제 자체가 근거를 얻지 못했습니다」
- **근거**: `docs/saa-review/review-rubric.md` §2 — 「"공식 문서에서 확인되지 않으므로" … 같은 **작성 과정 메모를 학습자용 문장에 남기지 않는다.**」 ⚠️ 같은 절이 학습문서의 「공식 문서에서 확인되지 않았으므로 정답으로 고르지 않습니다」는 **의도된 시험 전략 서술이라 대상이 아니다**라고 적는다 — 그래서 md 의 「공식 문서에서 확인되지 않습니다」(`aip-t3-3.md` L141·L287 · `aip-t3-4.md` L62·L76·L204·L230)는 **결함으로 세지 않았다.** 센 것은 「이 트랙」(저작 프로젝트 지칭)과 「같은 추출에서 … 본문이 읽혔음」(측정 방법론) 둘뿐이다.
- **수정안**: `q5` — 「Bedrock 응답에 표준 신뢰도 점수 필드가 있다고 전제하지 않습니다. 애플리케이션이 신뢰도로 쓸 값을 정해 …」로 사실 서술만 남긴다. W1 「응답에 그런 표준 필드가 있다고 전제할 수 없습니다」, W2 「로그 확률 합산 값을 신뢰도로 돌려주는 계약도 전제할 수 없습니다」. `q11` — 해설 첫 문장을 「프롬프트 관리와 Flows 가 주는 것은 공정성 지표가 아니라 A/B 테스트의 틀입니다」로 바꾸고 추출·대조군 서술을 통째로 걷는다. W0 「그 셋이 표형 전용 지표를 준다는 전제가 성립하지 않습니다」. md 는 「이 트랙에서」 → 「공식 문서에서」, 괄호 속 「같은 추출에서 … 확인됩니다」 삭제.
- **전수**: `이 트랙` — md **2자리**(`aip-t3-4.md` L127·L251) · 문항 **1문항**(q5 해설) / `같은 추출|본문이 읽혔` — md **2자리**(L154·L230) · 문항 **1문항**(q11 해설) / `근거 … 얻지 못` — md 0 · 문항 **2문항**(q5 해설+W1+W2 · q11 W0).
- **2단계 가드 제안**: MLA 의 M2 가드(`mla_questions_test.dart` 마지막)와 같은 전수 집계를 AIP 문항+md 에 건다. 금지 어형은 위 셋(`이 트랙` · `같은 추출` · `근거[^.]{0,12}얻지 못`). ⚠️ `prescreen` 의 `authoring-memo` 가 0을 준 것은 이 어형을 모르기 때문이다.

### Y7. 메타 문항 4건 — AWS 가 아니라 「이 사이트가 문항을 어떻게 쓰는가」를 묻는다
SCS 외부 검수(보고 §4 1단계)가 `scs-t3-2-q12` 를 재작성시킨 것과 같은 종류다. 넷 다 **정답의 사실은 참**이고 결함은 **묻는 층**이다.

| ID | 정답 | 지문 | 해당 기술이 실제로 요구하는 것 |
|---|---|---|---|
| `aip-t2-2-q10` | **1** | 「대규모 모델 추론 컨테이너의 내부 구현 수치를 **문항으로 내자는 제안**이 나왔습니다. 그 상세 서술이 어디에 있고 따라서 무엇까지 다룰 수 있습니까?」 | 2.2.2 — LLM 배포의 메모리·GPU·컨테이너 패턴 |
| `aip-t3-3-q9` | **0** | 「**교재에** 책임 있는 AI 차원을 여덟으로 적을지 열로 적을지 팀 의견이 갈립니다. 어떻게 처리합니까?」 | 3.3.3 — 조직 거버넌스 프레임워크 |
| `aip-t2-2-q7` | **2** | 「기술 2.2.1이 드는 … 셋을 두고 「셋 중 무엇이 가장 빠른가」를 물었습니다. **이 질문의 문제는 무엇입니까?**」 | 2.2.1 — 요구에 맞는 배포 경로 선택 |
| `aip-t1-4-q9` | **0** | 「… 함께 「어느 벡터 스토어가 가장 빠른지」를 **표로 적으려 합니다.** 올바른 판단은 무엇입니까?」 (앞절 16,000 차원 상한은 정상) | 1.4.3 — 확장 가능한 벡터 스토어 아키텍처 |

- **근거**: `t2-2-q10` 해설 「그래서 이 사이트는 특정 라이브러리 이름이나 수치를 묻지 않고 …」, `t3-3-q9` 오답 보기 「교재 전체에 그 수를 일관되게 적용」 — 저작 결정(⛔ 「개수를 묻지 않는다」·「속도로 서열화하지 않는다」)이 **문항의 소재가 됐다.** `99-gaps.md` 의 ⛔ 는 「그 축으로 문항을 쓰지 않는다」이지 「그 판정을 문제로 낸다」가 아니다.
- **인용 사실은 확인했다**: `t3-3-q9` — 렌즈 페이지가 차원 **열 개**를 열거하고 「we define Responsible AI using a core set of dimensions that we update over time as AI evolves」를 적는다(같은 페이지가 「eight focus areas」도 적는다 — 차원이 아니라 초점 영역이다). `t1-4-q9` — `opensearch-service/.../vector-search.html` 「configurable dimensions (up to 16,000)」. `t2-2-q10` — LMI 페이지에 `Deep Java Library`·`quantization`·`tensor parallelism`·`continuous batching` 실재.
- **수정안**: 같은 사실을 **설계 상황**으로 다시 묻는다(정답 자리 유지 가능).
  - `t2-2-q10` → 「가속기 하나에 들어가지 않는 LLM 을 SageMaker AI 에 올리려 합니다. LMI 컨테이너 문서가 적는 결정 순서는?」(인스턴스 유형·백엔드 선택 → 구성·배포 → 최적화 → 벤치마크). ⚠️ 같은 Task 의 `q8` 이 최적화 기능 셋을 이미 물으므로 겹치지 않게 **결정 축** 쪽으로.
  - `t3-3-q9` → 「거버넌스 문서에 책임 있는 AI 통제를 매핑하려 합니다. 「사용자에게 근거를 보여 준다」와 「왜 그렇게 답했는지 추적한다」는 각각 어느 차원입니까?」 — ⚠️ 같은 Task `q8`(설명 가능성 ↔ 투명성)과 겹치지 않게 **제어 가능성·견고성·진실성** 같은 다른 차원 쌍으로.
  - `t2-2-q7` → 「트래픽이 일정하지 않은 호출을 가장 싸게 받으려 합니다. Lambda 온디맨드 호출 · 프로비저닝 처리량 · SageMaker AI 엔드포인트 가운데 어느 것이고 감내할 것은?」(해설에 이미 있는 「온디맨드는 … 피크에 스로틀링이 보일 수 있습니다」가 정답 재료다).
  - `t1-4-q9` → 뒷절을 걷고 차원 상한 단일 문항으로 줄인다.
- **전수**: `교재|문항|출제` — 문항 **2문항**(`t2-2-q10` 지문 · `t3-3-q9` 지문+오답 보기). 「이 질문의 문제는」 1문항, 「표로 적으려」 1문항.

### Y8. `aip-t1-4-q3` + `aip-t1-4.md` — Kendra GenAI 인덱스를 현행 경로로 가르치면서 상태를 적지 않는다
- **공개 여부**: verified false
- **현재 정답 인덱스**: 2
- **결함**: 정답 「Neptune Analytics 그래프와 Kendra GenAI 인덱스는 … 다른 종류의 지식 베이스를 만드는 경로입니다」와 W0 「둘 다 Bedrock 지식 베이스에서 쓰는 공식 경로입니다」가 **Amazon Kendra 의 신규 고객 비개방을 적지 않는다.** 저작 결정 D-07 이 Kendra 를 「서비스 단위 유지 관리 셋」의 첫째로 들고 「상태 메모는 가르치는 층에 단다」고 정했는데, 그 서비스를 유일하게 다루는 문항·문서에 메모가 없다(`aip_doc_format_test` 규율 표에도 Kendra 행이 없다 — 가드 공백).
- **공식 근거**: `kendra/latest/dg/kendra-availability-change.html`(200 r=0) — 「Amazon Kendra is no longer open to new customers. For capabilities similar to Amazon Kendra, explore Amazon Bedrock Knowledge Bases.」 / `general/latest/gr/maintenance_services.html`(200 r=0) — 「Amazon Kendra | June 30, 2026」. ⚠️ `knowledge-base-build-kendra-genai-index.html` 자신은 상태를 적지 않는다(`no longer`·`new customers`·`maintenance` 0건).
- **수정안**: q3 **해설 끝**에 한 문장 — 「다만 Amazon Kendra 는 신규 고객에게 열려 있지 않아 새 설계에서 그 경로를 새로 고르지는 않습니다」(오답 근거에는 달지 않는다 — D-07). md L118·L233 에 같은 메모. 출처에 가용성 변경 페이지 추가(G-84: md 도). 날짜는 묻지 않는다(G-24 규율).
- **전수**: `Kendra` — md **7자리**(`aip-t1-4.md` L19·L51·L72·L118·L209·L233·L272, 상태 표기 0) · 문항 **1문항**.

### Y9. `aip-t1-1-q5`·`aip-t1-1-q1` + `aip-t1-1.md` — 「Generative AI Lens 가 모델 훈련·고급 사용자 지정을 범위에서 명시적으로 제외한다」는 인용 페이지에 없다
- **공개 여부**: 둘 다 verified false
- **현재 정답 인덱스**: q5 **0** · q1 **0** (두 정답 모두 영향 없다)
- **결함**: `q5` 해설 「… 모델 훈련과 고급 모델 사용자 지정 기법의 모범 사례는 범위에서 **명시적으로 제외**합니다」·W1, `q1` W3 「Generative AI Lens도 모델 훈련과 고급 사용자 지정 기법을 범위에서 제외합니다」, 출처 제목 「렌즈 범위와 제외」. **그 문장은 렌즈 문서가 아니라 AWS Architecture Blog 에 있다.**
- **공식 근거**:
  - `wellarchitected/latest/generative-ai-lens/generative-ai-lens.html` — 문서 리더 전문 + `curl` 본문 6,653자. 탐침 `model training`·`exclud`·`not cover`·`out of scope`·`does not`·`beyond`·`fine-tun` 0건(대조군: `Machine Learning Lens` 1 · `scoping, model selection` 1). Scope 절이 적는 것: 「generative AI applications that use foundation models on Amazon Bedrock or customer-managed models on Amazon SageMaker AI」 · 「For traditional machine learning (ML) applications built using Amazon SageMaker AI, see Machine Learning Lens.」
  - 렌즈 자신은 사용자 지정을 **다룬다**: 같은 페이지 「lifecycle stages of scoping, model selection, **customization**, …」 · 운영 우수성 「determine when to execute model customization」 · `genperf01-bp02.html` 「This is true not just for model inference, but **model training and customization workloads** as well.」
  - 제외 문장의 실제 위치(블로그 — 계약 규율 7에 따라 근거로 쓰지 않는다): `aws.amazon.com/blogs/architecture/announcing-the-updated-aws-well-architected-generative-ai-lens/` 「Specifically excluded from the Generative AI Lens are best practices associated with model training and advanced model customization techniques.」
- **수정안**: 「명시적으로 제외」를 **문서가 적는 문장**으로 바꾼다 — `q5` 해설: 「Generative AI Lens 의 범위는 Bedrock 의 FM 또는 SageMaker AI 의 고객 관리형 모델을 쓰는 GenAI 애플리케이션이고, 전통적인 ML 애플리케이션은 Machine Learning Lens 를 보라고 적습니다」. W1: 「전통적 ML 워크로드는 그 렌즈가 Machine Learning Lens 로 보냅니다」. `q1` W3 는 앞절(시험 가이드의 범위 외 작업)만 남긴다. 출처 제목 「렌즈 범위」로.
- **전수**: `명시적으로 제외|범위에서 제외|범위와 제외` — md **4자리**(`aip-t1-1.md` L85·L128·L239·L261) · 문항 **2문항**(q1 W3+출처 제목 · q5 해설+W1+출처 제목).

### Y10. `aip-t1-1-q13` — 「무료」의 근거 페이지가 재구성됐고, Agent 에는 그 근거가 없다
- **공개 여부**: verified false
- **현재 정답 인덱스**: 0 (정답 「프리뷰 릴리스」는 영향 없다)
- **결함**: 해설 「그 도구는 무료입니다」와 W2 「AWS는 워크로드 검토 서비스를 무료로 제공합니다. 공식 서술에 유료라는 내용은 없습니다」의 유일한 출처 `wellarchitected/latest/userguide/well-architected.html` 이 **2026-11-16 에 재구성돼 요금 서술이 없다.** 오전 WA 수선이 `q11` 에는 요금 페이지를 달았는데 **같은 사실을 쓰는 `q13` 은 빠졌다.** 그리고 W2 는 **WA Tool 의 무료를 Well-Architected Agent 에 옮겨** 「Agent 는 유료 기능이어서」(오답 [2])를 반박하는데, Agent 의 과금을 적는 공식 문장은 찾지 못했다.
- **공식 근거**:
  - `well-architected.html` — 전문 2,182자(「Last updated: November 16, 2026」), `free`·`charge` 0건. 실재하는 것: 「AWS Well-Architected Agent is in preview release and is subject to change.」 · Agent/Tool 비교표.
  - `aws.amazon.com/well-architected-tool/pricing/`(200 r=0) — 「There is no additional charge for the AWS Well-Architected Tool.」 (**Tool** 한정)
  - `wellarchitected/latest/userguide/release-notes.html` — 「AWS WA Agent is available to customers with a Business+, Enterprise On-Ramp, Enterprise Support, or Unified Operations support plan.」 → Agent 는 **유료 지원 플랜이 전제**다.
- **수정안**: 해설의 「그 도구는 무료입니다」에 요금 페이지를 출처로 추가(md 는 이미 갖고 있다 — G-84 통과). W2 를 「Agent 의 요금을 이 문항이 판단할 근거로 삼지 않습니다. 짚어야 할 것은 프리뷰 상태이고, 이용 조건은 지원 플랜 쪽에 있습니다」 식으로 바꾸거나, 오답 [2]를 과금과 무관한 거짓 보기로 교체한다(참일 수 있는 보기를 오답으로 두지 않는다).
- **전수**: `무료|at no charge` — md **4자리**(`aip-t1-1.md` L67·L91·L156·L253. L156 「AWS는 워크로드 검토 서비스를 무료로 제공한다」는 옛 페이지 문장의 번역이다 → 「추가 요금이 없다」로) · 문항 **2문항**(q11 정답 보기 · q13 해설+W2).

### Y11. 해설·오답 근거의 문장 오류 3건
| ID | 정답 | 현재 문장 | 무엇이 틀렸나 | 공식 | 수정안 |
|---|---|---|---|---|---|
| `aip-t3-3-q14` | **1** | 해설 「FM 평가 쪽 선택지는 fmeval 라이브러리와 Bedrock Evaluations와 Bedrock Guardrails **셋이고 둘 모두** 신규 고객에게 열려 있습니다」 | 셋이라 하고 둘이라 한다 | `clarify-availability-change.html` 「Amazon Bedrock Evaluations and Amazon Bedrock Guardrails are the AWS-managed path for LLM and generative AI evaluation. They replace Clarify's foundation model evaluation (FMEval) capability.」 | 「FM 평가의 AWS 관리형 경로는 Bedrock Evaluations 와 Bedrock Guardrails 이고 Clarify 의 FM 평가 기능을 대체합니다」 |
| `aip-t2-3-q15` | **2** | 해설 「추론 타깃을 **분당 토큰으로 엔드포인트의 동시 연결 수를 제한**합니다」 | 서로 다른 두 항목이 한 문장으로 붙었다 | `bedrock-agentcore/.../gateway-rate-limits.html` 「Control tokens per minute (TPM) for inference targets」 / 「Limit concurrent connections to endpoints」 (별 불릿) | 「추론 타깃의 분당 토큰을 제어하고 엔드포인트의 동시 연결 수를 제한합니다」. 그 페이지는 q15 출처에도 `aip-t2-3.md` 출처에도 없다 → 양쪽에 추가(200 r=0) |
| `aip-t5-1-q11` | **2** | W3 「**데이터세트 유형은 프리뷰이고** 궤적 비교의 그라운드 트루스를 받는 것은 배치입니다」 | 근거 없는 상태 단정. 해설의 「평가 유형이 셋」과도 어긋난다 | `bedrock-agentcore/.../evaluations-types.html` 「provides three evaluation types … Online evaluation · On-demand evaluation · Batch evaluation」 (`preview`·`dataset` 0건. md·조사 노트에도 0건) | W3 「평가 유형은 온라인·온디맨드·배치 셋이고 그라운드 트루스를 세션 메타데이터로 받는 것은 배치입니다」. 오답 [3]의 「데이터세트 평가」는 그대로 거짓 보기로 둘 수 있다 |

- **전수**: `셋이고 둘 모두` 문항 1 · `분당 토큰으로` 문항 1 · `데이터세트 유형` 문항 1 (md 각 0).

### Y12. 사실은 참인데 인용 페이지가 그 사실을 담지 않는다 — 출처 추가·교체 16문항
전부 **정답·보기·해설 사실은 공식과 일치**한다. 고칠 것은 `sources`(와 G-84 때문에 그 Task md 의 프런트매터·「출처」 절)뿐이다. 제안 URL 은 전부 `curl -sL` → `200 r=0` 실측.

| ID | 정답 | 인용 페이지에 없는 서술 | 실제로 있는 페이지 (원문) | md 출처에 이미 있나 |
|---|---|---|---|---|
| `t1-3-q6` | 1 | 「두 개의 JSON 파일 — `/opt/ml/config/processingjobconfig.json` 과 `resourceconfig.json`」 (`byoc-input-and-output.html` 1,387자에 0건) | `sagemaker/latest/dg/build-your-own-processing-container.html` 「through environment variables and two JSON files— /opt/ml/config/processingjobconfig.json and /opt/ml/config/resourceconfig.json」 | 없음 → 추가 |
| `t1-3-q7` | 2 | 「`S3UploadMode` … `EndOfJob`」 (같은 페이지 0건) | 위와 같은 페이지 「"S3UploadMode": "EndOfJob"」 | 없음 → 추가 |
| `t1-3-q15` | 2 | 「공식 가용성 변경 페이지가 … **2026-03-31 공지로** 적습니다」 — 그 페이지에 날짜가 없다 | `general/latest/gr/maintenance_services.html` 「Amazon Comprehend – Topic Modeling, Event Detection, and Prompt Safety Classification | March 31, 2026」(열 이름 Announcement Date). 가용성 변경 페이지가 적는 것은 「no longer available to new customers」 · 「accounts that have used these features within the last 12 months … will continue to have access」 | 없음 → 추가하거나 날짜를 걷는다 |
| `t1-4-q10` | 1 | 「사용자 지정 데이터 소스 … KnowledgeBaseDocuments 작업」 (`knowledge-base.html` 에 0건) | `bedrock/latest/userguide/kb-direct-ingestion.html` 「connected to one of the following types of data sources: Amazon S3 · Custom」 | 있음(`aip-t1-4.md`) |
| `t1-4-q1` · `t1-4-q4` | 0 · 3 | 「고객 관리형은 단일 검색 패스」 (`knowledge-base.html` `single` 0건) | `bedrock/latest/userguide/kb-test-agentic-retrieve.html` 「Agentic retrieval only supports managed Amazon Bedrock knowledge bases.」 — 「단일 패스」라는 표현은 공식에 없으니 「에이전틱 검색은 관리형 지식 베이스에서만 지원됩니다」로 바꾸는 편이 정확하다 | 없음(`aip-t1-5.md` 에는 있음) → 추가 |
| `t2-1-q4` | 3 | 「harness를 Step Functions의 InvokeHarness 상태로」 (`agentsec06-bp02.html` 0건) | `bedrock-agentcore/latest/devguide/harness.html` (`InvokeHarness` 실재) | 있음 |
| `t2-1-q7` | 2 | 「실패한 호출을 같은 프롬프트와 같은 모델로 재시도하는 것도 안티패턴」 (`agentcost01-bp01.html` 안티패턴 목록 5개 전문 확인 — 없음) | `wellarchitected/latest/agentic-ai-lens/agentperf02-bp01.html` 「Retrying a failed LLM call with the identical prompt and model, rather than re-prompting semantically, rephrasing the instruction, simplifying the task, or falling back to a more capable model」 | 있음 |
| `t2-1-q13` | 0 | 「수천 개의 도구를 쓰면서 프롬프트 크기를 최소화하고 지연을 줄인다」 (`gateway-using-mcp-semantic-search.html` `thousands`·`latency`·`prompt size` 0건) | `bedrock-agentcore/latest/devguide/gateway.html` 「allowing agents to use thousands of tools while minimizing prompt size and reducing latency」 | 있음 |
| `t3-1-q13` | 0 | 「탈옥과 프롬프트 인젝션과 프롬프트 누출」과 그 정의 인용 (`guardrails-content-filters.html` `jailbreak`·`injection`·`bypass`·`override` 0건 / `guardrails-tiers.html` 에는 표의 「Prompt leakage detection」 행만) | `bedrock/latest/userguide/guardrails-prompt-attack.html` 「Jailbreaks — … Prompt Injection — … Prompt Leakage (Standard tier only) — …」 | **없음** → md 와 문항 양쪽에 추가 |
| `t3-2-q6` | 1 | 「Governed Tables … 완전 종료」 (`what-is-lake-formation.html` `Governed` 0건) | `general/latest/gr/full_shutdown_services.html` 「Governed Tables in AWS Lake Formation | December 31, 2024」 | 없음 → 추가 |
| `t3-3-q5` | 0 | 「각 계정이 리전마다 하나」 (`catalog-and-crawler.html` `Region` 0건) | `glue/latest/dg/components-overview.html` 「Each AWS account has one AWS Glue Data Catalog per AWS Region.」 | 있음 |
| `t3-3-q7` | 2 | 「콘솔에서 만든 추적은 기본적으로 모든 리전에 적용」 (`cloudtrail-user-guide.html` `Regions` 0건) | `awscloudtrail/latest/userguide/cloudtrail-concepts.html` 「All trails created using the CloudTrail console are multi-Region trails.」 | 없음 → 추가 |
| `t4-2-q5` | 0 | 「반복 인덱스 스캔 … 필터가 HNSW 인덱스 스캔 뒤에 적용」과 「샤드 수는 첫 문서를 색인하기 전에」 (`kb-test-config.html` `iterative`·`shard`·`first document` 0건. `AuroraPostgreSQL.VectorDB.html` 에도 `iterative`·`0.8.0` 0건) | `bedrock/latest/userguide/knowledge-base-setup.html` 「we recommend enabling HNSW iterative index scans (requires pgvector 0.8.0 or later). Without iterative scans, selective metadata filters can return fewer results than expected because filtering is applied after the HNSW index scan.」 / 샤드 문장은 `opensearch-service/.../bp-sharding.html` | **없음**(`aip-t4-2`·`t4-3`·`t5-2` md 셋 다 — 그 사실을 12줄에서 쓴다) → 세 md 에 추가 |
| `t4-3-q9` | 0 | 「스팬 분류는 `gen_ai.operation.name` 이 invoke_agent·execute_tool·chat … 도구 이름은 `gen_ai.tool.name`」 (`observability-tool-metrics.html`·`supported-frameworks.html`·`observability-telemetry.html` 모두 `gen_ai` 0건) | `bedrock-agentcore/latest/devguide/supported-frameworks-strands.html` 「Strands sets the gen_ai.operation.name attribute on each span … invoke_agent · execute_tool · chat」 「the tool name from the gen_ai.tool.name attribute」 — ⚠️ **Strands 한정 서술**이다. 「프레임워크가 내는 스팬」으로 일반화하지 말고 Strands 로 한정한다 | 없음 → 추가(md 5줄: `aip-t4-3.md` L239·L254·L414·L442·L495) |
| `t5-1-q1` | 0 | 「(AgentCore Evaluations 는) 입력이 세션과 트레이스와 스팬」 (`how-it-works-evaluations.html` 은 **742자짜리 얇은 페이지**이고 `session`·`trace`·`span` 0건) | `bedrock-agentcore/latest/devguide/evaluations-types.html`(세션·스팬·트레이스 ID 지정 서술) | 있음 |

- **2단계 주의**: 위 표에서 그 Task 의 md 출처에 없는 URL 8개(`build-your-own-processing-container` · `maintenance_services` · `kb-test-agentic-retrieve`(t1-4) · `guardrails-prompt-attack` · `full_shutdown_services` · `cloudtrail-concepts` · `knowledge-base-setup`(t4-2·t4-3·t5-2) · `supported-frameworks-strands`)은 **md 를 먼저 늘려야** G-84 가드가 초록이다. md 삽입은 `lastVerified:` 바로 **앞**(목록 끝)에 한다 — 목록 중간에 최상위 키가 끼면 파서가 뒤 출처를 버린다(2026-11-11 사고).

### Y13. 정답 근거가 「시험 가이드 예시 목록」 또는 저작 추론인데 출처는 다른 페이지 — 18문항(+Y9 `t1-1-q1`)
정답은 전부 그럴듯하고 유일하다. 결함은 **C4(출처 뒷받침)**다 — 인용 페이지에 그 대응·서열이 없고, 근거는 공식 시험 가이드 기술 본문의 「예:」 목록이거나 저작자의 설계 추론이다.

| ID | 정답 | 지문·해설이 기대는 것 | 인용 페이지 실측 |
|---|---|---|---|
| `t1-1-q1` | 0 | 「공식 기술 1.1.1 본문이 … 예시로 적습니다 — 적절한 FM, 통합 패턴, 배포 전략」 | 렌즈 페이지에 그 셋 없음 |
| `t1-4-q5` | 0 | 「기술 1.4.2가 예시로 드는 세 수단」(S3 객체 메타데이터=타임스탬프 등) | `kb-metadata.html` `timestamp` 0건 |
| `t1-5-q7` · `q13` · `q15` | 2 · 0 · 2 | 「기술 1.5.3 / 1.5.5 / 1.5.6이 드는 …」 | 각 인용 페이지에 그 대응 없음 |
| `t1-6-q4` · `q9` | 3 · 0 | 「기술 1.6.2 / 1.6.4가 드는 수단에 올바르게 대응」 | `how-document-classification.html`·`prompt-management.html` 에 그 대응 없음 |
| `t2-2-q15` | 2 | 「기술 2.2.3이 드는 수단 셋 … 적절한 모델 선택이 **가장 큰 레버**」 | 서열 서술 없음 |
| `t2-3-q5` · `q6` | 0 · 1 | 「Lambda 웹훅 핸들러 … 표준 경로」 · 「셋을 섞을 때 흔한 실수」 | `apigateway/.../welcome.html` `webhook`·`asynchron` 0건(대조군 `Lambda authorizer`·`WAF`·`canary` 적중) |
| `t2-4-q13` · `q15` | 0 · 2 | 「라우팅은 정적에서 동적으로, 지표 기반으로 올라갈수록 비싸고 복잡」 · 「매 요청 판단은 지연」 | 세 인용 페이지에 서열 없음 |
| `t2-5-q8` · `q9` | 0 · 3 | 「단일 요청·응답은 Lambda, 여러 단계는 Step Functions, 구조화는 전용 서비스」 | `bda.html`·Step Functions 오류 처리 페이지에 없음 |
| `t3-1-q5` | 0 | 「결정적 결과를 보장하는 수단으로 드는 것이 텍스트-SQL 변환」 | `structured-output.html` `SQL` 0건 |
| `t3-3-q15` | 2 | 「정책 필터는 한 요청 · 드리프트는 분포 · 오용은 사용 패턴」 | 인용 두 페이지에 없음 |
| `t5-2-q7` · `q11` · `q14` | 2 · 2 · 1 | 「순서가 네 단계」 · 「층이 넷이고 순서대로」 · 「진단 단위는 최종 프롬프트」 | 인용 페이지에 순서 서술 없음 |

- **수정안**(둘 중 하나, 묶어서 처리): ⓐ 출처에 **공식 시험 가이드 도메인 페이지**를 추가한다 — 루브릭 C4 가 Exam Guide 를 1순위 출처로 인정한다. `https://docs.aws.amazon.com/ko_kr/aws-certification/latest/ai-professional-01/ai-professional-01-domain{1,2,3,5}.html`(넷 다 `200 r=0` 실측, 영문 판도 `200 r=0`). ⚠️ G-84 때문에 해당 md 프런트매터에도 추가해야 한다. ⓑ 해설의 「공식이 적습니다」를 걷고 추론임이 드러나게 쓴다(예: 「세 수단을 섞을 때 동기 경로에 긴 작업을 두면 …」).
- **전수**: `기술 \d+\.\d+\.\d+` 언급 — 문항 **13문항 21자리**(지문 8문항: `t1-4-q5`·`t1-5-q7`·`q13`·`q15`·`t1-6-q4`·`q9`·`t2-2-q7`·`q15`). 지문에서 기술 번호를 부르는 것 자체는 G3 에서 따로 다룬다.

## 3. 🟢 (묶음)

### G1. 사이트 자기 언급·시험 예측 문구가 해설에 남았다 — 5문항
| ID | 정답 | 문구 |
|---|---|---|
| `t2-2-q4` | 3 | 「그래서 **이 사이트는** 어느 한쪽으로 단정하지 않고 두 경로를 함께 가르칩니다」 · 「**문서 사이가 갈리는 자리**입니다」 · W1 「한쪽만 남기면 문서가 갈리는 자리를 지웁니다」 |
| `t2-5-q10` | 0 | 「… **이 사이트는** Kiro의 기능 수와 가격과 모델 목록을 다루지 않습니다」 |
| `t2-4-q8` | 3 | 「연결 수명이 **시험 포인트**입니다」 |
| `t3-3-q14` | 1 | 「대체 범위의 경계가 **시험 포인트**입니다」 |
| `t4-1-q7` | 2 | 「제약 셋이 전부 **시험 소재**이고」 |

- `t2-2-q4` 의 사실(PT 페이지가 아직 「If you customized a model, you must purchase Provisioned Throughput to be able to use it.」로 적는다 · 「for custom models, pricing is the same as the base model」)은 **현행 페이지에서 확인했다.** 고칠 것은 「이 사이트는」 한 문장이다 — ⚠️ `aip_doc_format_test` 가 요구하는 것은 「경로가 둘」이라는 **사실**이지 그 문장이 아니므로 걷어도 가드는 초록이다.
- `시험 포인트` 는 md 28자리에서 **절 제목**(`## ✍️ 시험 포인트`)으로 쓰는 낱말이라 md 는 대상이 아니다. 문항 해설의 3자리만 SCS §4 2단계가 걷은 「시험이 묻는」 계열이다.
- **전수**: `이 사이트` — 문항 3문항(위 둘 + Y7 `t2-2-q10`) · md 16자리(시험 전략 서술이라 대상 아님).

### G2. 지문의 자기 프레임 잔재 — `prescreen` 이 모르는 어형
- **「~에 비추어」 44문항**(전부 지문): `t1-1-q5·q6·q9·q10·q12·q14·q15` · `t1-2-q2·q3·q13·q15` · `t1-3-q1·q3·q10·q11·q14` · `t1-4-q2·q4` · `t1-5-q7·q11` · `t1-6-q8·q11·q12·q13·q14` · `t2-1-q2·q4·q7·q8·q10·q11` · `t2-2-q5·q8·q9·q15` · `t2-3-q2·q14` · `t2-4-q3·q11·q13` · `t3-3-q7` · `t4-3-q3·q4·q9`. 저작 중 걷어낸 「공식 서술에 비추어」(G-47, 58%)의 **주어만 바뀐 형태**다(「렌즈 구성에 비추어」·「지원 벡터 스토어 목록에 비추어」·「Converse 의 성질에 비추어」). 도메인 1·2 에 39건, 도메인 3~5 에 5건 — 뒤 배치로 갈수록 사라졌다. 대부분 그 구절을 지워도 질문이 선다.
- **지문이 시험 가이드 기술 번호를 부른다 — 8문항**(Y13 표와 같은 목록). 학습자는 「기술 1.6.2가 드는 수단」이 무엇인지 모른다.
- **「~자는 제안이 나왔습니다/올라왔습니다」 12문항**(지문 틀): `t1-1-q13` · `t1-4-q11` · `t1-6-q14` · `t2-1-q2` · `t2-2-q5` · `t2-2-q10` · `t2-4-q3` · `t2-4-q10` · `t2-4-q13` · `t4-1-q7` · `t4-2-q4` · `t4-3-q14`. 열두 건 전부 정답이 「그 제안은 성립하지 않는다」 쪽이다 → **틀만 보고 답의 방향을 고를 수 있다.**
- 수정은 선택이다(사실 결함 없음). 손댄다면 「~에 비추어」는 삭제, 「제안이 나왔습니다」는 절반쯤을 「~하려 합니다」로 바꾸고 몇 건은 **성립하는 제안**으로 뒤집으면 틀 단서가 사라진다.

### G3. 중복·겹침 — 읽어서 판정한 것
독립 스크립트로 300문항 44,850쌍을 **원형·조사벗김 두 토크나이저** × **정답·지문·지문+정답 세 필드**로 쟀다(대조군: 정답 문자열 완전 동일 0쌍). 임계 0.33 이상은 정답 필드 1쌍(`t2-2-q12`↔`t4-1-q15` 0.333) · 지문 필드 5쌍. 상위 쌍을 읽어 아래로 판정했다. ⚠️ 착수 노트 §4 ① 표는 정답 필드만 봐서 **A·B 를 놓쳤다**(둘 다 지문+정답 필드에서 올라왔다).

| 쌍 | 정답 | 판정 | 무엇이 겹치나 |
|---|---|---|---|
| A. `t4-3-q4` ↔ `t5-2-q4` | 3 · 3 | **실제 중복** | 지문이 사실상 같다(「오류 지표가 0인데 사용자는 실패를 본다」) · 정답의 실질이 같다(스로틀은 호출 수·오류 어느 집합에도 들지 않는다). `t5-2-q4` 가 「쿼터 초과는 클라이언트 오류」를 더할 뿐이다 |
| B. `t2-5-q3` ↔ `t5-2-q3` (↔ `t4-1-q4`) | 2 · 2 · 3 | **실제 중복** | 둘 다 「토큰 수 세기 API 의 응답은 입력 토큰뿐이고 출력은 모른다」. `t4-1-q4` 는 mantle 엔드포인트 각도라 겹치지 않는다 |
| C. `t1-2-q13` ↔ `t2-2-q4` | 0 · 3 | **실제 중복** | 둘 다 「사용자 지정 모델 추론 경로는 PT 구매 또는 온디맨드 배포 둘」. q13 이 리전 제약을 더한다 |
| D. `t3-3-q4` ↔ `t3-3-q12` | 3 · 3 | 같은 Task · 같은 결정 사실 | 상황은 다르지만(모델 카드 자동 파싱 ↔ 편향 주간 측정) 둘 다 「Clarify·Model Monitor 가 신규 고객에게 닫혔다」 한 사실로 풀린다. 15문항 세트에서 함께 나온다 |
| E. `t2-2-q12` ↔ `t4-1-q15` | 3 · 2 | 중복 아님(틀 동일) | 배치 추론 × 프로비저닝 ↔ 배치 × 캐싱. 지문 틀이 같다(「야간 … 하자는 계획이 올라왔습니다」 → 「성립하지 않습니다」) |
| F. `t3-4-q2` ↔ `t3-4-q4` | 1 · 3 | 중복 아님(틀 동일) | OrchestrationTrace ↔ PreProcessingTrace. 「어느 추적을 읽습니까」 |
| G. `t3-1-q10` ↔ `t3-4-q13` · `t1-6-q4` ↔ `t1-6-q9` ↔ `t1-5-q13` | 1·0 · 3·0·0 | 중복 아님(틀 동일) | 「각 층/수단을 올바르게 짝지은 것」 — 전부 서비스 이름 순열 고르기 |

- **수정안**: A 는 `t5-2-q4` 를 5.2.2 가 소유하는 다른 축(예: 로깅 전달 실패 지표, 통합 오류의 400 ↔ 424 구분)으로 돌린다. B 는 `t5-2-q3` 을 5.2.1 의 다른 축으로. C 는 `t2-2-q4` 를 2.2.1 고유 사실(GovCloud 약정 제약 · MU 요청 절차)로. D 는 `t3-3-q4` 를 모델 카드 평가 세부의 JSON 구조 쪽으로. 교체 방향은 「어느 기술이 그 사실을 소유하나」로 가른다(G-50).
- E·F·G 는 고치지 않아도 된다. G2 의 틀 단서와 같은 계열이다.

### G4. 정밀도 — 사실은 맞지만 공식보다 거칠다
| ID | 정답 | 현재 | 공식 | 권고 |
|---|---|---|---|---|
| `t1-5-q1` | 0 | 「일부 **청크가** 그보다 훨씬 깁니다 … 청크가 더 넓은 맥락으로 교체」 | `kb-chunking.html` 「**During retrieval**, a matching chunk is replaced with this broader context」 · 「Context is attached only when the full page text or the full table is 10,000 characters or fewer」 · 마크다운으로 처리된 문서에 한정 | 지문을 「검색 결과로 돌아온 텍스트가 설정한 최대 토큰보다 깁니다」로 |
| `t2-2-q2` | 1 | 해설 「**약정이 있는 모델을** 프로비저닝하려면 먼저 Support 에 MU 증액」 | `prov-thru-purchase.html` 「Before you can purchase a Provisioned Throughput **(with commitment or no commitment)**, you must first visit the AWS support center to request MUs」 | 「약정 유무와 무관하게」로. md `aip-t2-2.md` L109·L178 도 |
| `t4-1-q11` | 2 | 정답 「폴링하지 않는 것이 **권고되는 방식**」 | `batch-inference.html` 「To receive notifications when batch inference jobs complete or change state instead of polling, see …」 — 대안 제시이지 권고가 아니다 | 「폴링 대신 EventBridge 알림을 받을 수 있습니다」 |
| `t2-2-q11` | 2 | 「모델 캐스케이딩이고, 관리형 수단은 지능형 프롬프트 라우팅」 | 라우팅은 요청마다 품질을 **미리 예측**해 보낸다(실패·저신뢰 시 승격이 아니다) | 해설에 그 차이 한 문장 |
| `t1-6-q5` | 0 | W2 「프롬프트 안전 분류는 유지 관리 상태로 공지된 기능이므로 새 설계에서 고르지 않습니다」 — **상태가 유일한 오답 이유** | D-07: 상태를 오답 이유로 쓰면 「그 상태가 그 보기를 틀리게 만든 이유」처럼 읽힌다 | 기능 이유를 앞에: 「프롬프트의 안전성을 가르는 기능이고 발화를 업무 의도로 분류하지 않습니다」 |
| `t4-3-q15` | 2 | 해설 「유창성에 대응하는 내장 지표가 판정 지표 목록에 없다」 · W1 「유창성 내장 지표는 목록에 없습니다」 | 현행 `model-evaluation-metrics.html` 내장 지표 11개에 Fluency 없음(**지금은 참**). G-29 는 「부재를 정답으로 쓰지 않는다 — 개정으로 바뀐다」고 판정했다. 정답 보기는 깨끗하다 | W1 은 앞절(「참조 응답을 고려하는 지표가 있습니다」)만으로 충분하다 — 뒷절 삭제 |
| `t4-2-q11` | 2 | 해설 「세 파라미터 사이의 상호작용을 공식이 규정하지 않으므로」 | 부재 서술(`interact`·`combin` 0건으로 지금은 참) | 「한 모델의 조합을 그대로 옮기지 않습니다」만 남긴다 |
| 단어 필터 일치 방식 | — | `t1-6-q3`(정답 2): 「대소문자를 구분하지 않는 전체 단어·전체 구 일치」 ↔ `t3-1-q2`(1)·`q13`(0)·`q15`(2): 「정확히 일치」 | 둘 다 공식 표기다 — `guardrails.html` 「case-insensitive whole-word and whole-phrase matching」 / `guardrails-components.html` 「(exact match)」 | `t3-1` 쪽 해설에 「(대소문자 무시 · 전체 단어·구 단위)」 병기. md 는 `aip-t1-6` 3자리 ↔ `aip-t3-1` 3자리 |

### G5. `aip-t1-4-q12` 해설에 `⚠️` 가 들어 있다
- 정답 인덱스 3. 문항 렌더 경로는 평문이라 이모지가 그대로 글자로 나온다. 300문항 가운데 해설에 `⚠️` 를 쓴 것은 이 한 건이다(11-16 수선 때 들어갔다). 해설 길이 388자로 `explanation-long` 임계 400 바로 아래다. 사실(CSV 는 항상 재수집 · 메타데이터 전용 최적화 조건 셋)은 현행 `kb-data-source-sync-ingest.html` 과 일치한다.

### G6. `lastVerified` 가 내용 변경을 따라가지 않은 뱅크 둘
- 문항 뱅크 20개의 `lastVerified` 는 전부 `2026-11-15` 다. 그 뒤에 내용이 바뀐 뱅크가 둘이다 — `aip-t1-1.questions.json`(2026-11-17 `c182fd3`, WA 출처 수선) · `aip-t1-4.questions.json`(2026-11-16 `0286e22`, q12 수선). md 쪽은 두 편 다 날짜를 올렸다(`aip-t1-1.md` 11-17 · `aip-t1-4.md` 11-16). 뱅크 날짜를 고정하는 테스트가 있는지는 확인하지 않았다 — 2단계에서 확인.

## 4. 커버리지·범위

**커버리지** (`exam_guides/AIP-C01.json` 의 `skills` 에서 `기술 N.M.K: ` 접두사로 번호 98개 유도 — 접두사 일치 98/98 · `knowledge` 합 0)
- 미커버 **0** · 가이드에 없는 번호를 쓰는 문항 **0** · `skill` 파싱 불가 0.
- 1문항뿐인 기술 **6개**: `2.1.6` · `4.2.3` · `4.2.6` · `5.1.2` · `5.1.6` · `5.1.8`. ⚠️ Y12 로 `4.2.6` 의 유일 문항(`t4-2-q15`)은 무관하지만, 중복 해소(G3)에서 `t5-2-q3`·`q4` 를 돌릴 때 **5.1.x 가 아니라 5.2.x 안에서** 돌려야 한다.
- 가장 두꺼운 기술: `2.2.1` 7문항 · `1.1.1`·`3.2.1`·`3.2.2`·`3.4.1`·`3.4.2` 각 6문항.
- 정답 인덱스 전수 80/80/80/60, Task 마다 4/4/4/3. `difficulty` foundational 60/300, Task 마다 정확히 3.

**범위** (`00-overview.md` §6 의 공식 범위 외 서비스 96항목 중 이름 94개를 문항 전수와 대조)
- 범위 외 서비스가 **정답의 주어**인 문항 **0**. 이름이 걸린 4건은 전부 공식 문장의 일부다 — `t3-2-q3`(정답 2: PrivateLink 이점 문장 속 「Direct Connect 없이」) · `t3-2-q5`(Lake Formation 적용 범위의 Redshift Spectrum) · `t2-5-q15`(X-Ray 데몬이 포함된 플랫폼의 Elastic Beanstalk) · `t2-3-q10` 오답 근거(Local Zone). 결함 아님.
- 「범위에 해당하지 않는 작업」 셋(모델 개발·훈련 / 고급 ML / 데이터 엔지니어링·특성 추출)을 **묻는** 문항 0. 낱말이 걸린 2건(`t1-1-q1` W3 · `t3-3-q2` W2)은 오답을 반박하는 자리다.

**⛔ 축 준수** (정규식 14종 × 문항 300 + md 20)
- 위반 **0**: DynamoDB 벡터 검색 부재 단정 0 · 청킹 전략 개수 0 · Guardrails 유해 범주 개수 0 · AgentCore 평가자 개수 0 · 정책 언어 개수 0 · Flows 개명 단정 0 · 공정성 지표 내장 단정 0 · Agent Squad 내부 구성요소 0.
- 경계에 있는 것 3건은 위에서 다뤘다: 책임 있는 AI 차원 개수(`t3-3-q9` → Y7) · 스토어 속도 서열(`t1-4-q9` → Y7) · 유창성 부재(`t4-3-q15` → G4).
- 상태 날짜를 **지문·정답이 묻는** 문항: `t2-5-q10` 하나(정답 0 「2027-04-30에 지원 종료되고 …」). 날짜는 두 인용 페이지 모두에 글자 그대로 있다(`q-developer-ide-end-of-support.html`·`what-is.html` 「On April 30, 2027, AWS will discontinue support for Amazon Q Developer IDE plugins. For capabilities similar …, explore Kiro」). G-24 규율(「닫힌 서비스의 날짜를 묻지 않는다」)과 어긋나는지는 저작자 판정 사항이다 — 다른 세 오답이 날짜가 아니라 상태 종류로 갈리므로 정답에서 날짜를 빼도 문항이 선다.

## 5. 교차 자격증 — 다른 자격증과 어긋나는 자리 (고치지 않고 적기만)

1. **AIF: 「tier 미지정 시 Classic」 보존 가드가 사라진 공식 문장을 붙들고 있다** (Y4 와 같은 사실)
   - `flutter_app/assets/content/aif/aif-t4-1.md` L474 — 「**지정하지 않으면 Classic**입니다 — **"If you don't specify a tier, your guardrail uses Classic tier."**」 (영문 직접 인용)
   - `flutter_app/test/aif_facts_test.dart` L503~515 — 그 영문 문장을 **보존 가드**로 고정(지우면 레드).
   - 현행 `guardrails-tiers.html` 에 그 문장이 없다(Y4 의 두 방법 + 대조군). 2단계가 AIP 에서 이 문장을 걷으면 **AIF 는 인용문이 고아가 되고 가드는 계속 그 문장을 요구한다.** 같은 날 쓰인 `aif.md` 보고서에는 이 항목이 없다. ⚠️ 가드는 판정을 굳히므로 **가드를 먼저 뒤집고** 콘텐츠를 고쳐야 한다.
   - 전수(레포 `assets/content/**`): `지정하지 않으면 Classic|don't specify a tier` — `aif/aif-t4-1.md` 1 · `aip/aip-t3-1.md` 3 · `aip/aip-t3-1.questions.json` 1.
2. **AIF·AIP 공통: `prompt-templates-builtin.html` 에서 `Builtin` 문자열이 사라졌다** — G-30 이 2026-11-14 에 「17개를 `Builtin.<이름>` 으로 열거」로 기록한 페이지가 지금은 평가자를 「Goal success rate (Session-level evaluator)」 식 **이름**으로만 적는다(본문 56,737자 · `Builtin` 0건). ID 형식 자체는 `built-in-evaluators-overview.html`(「Builtin.EvaluatorName, such as Builtin.Helpfulness」)·`skill-evaluators.html`·`insight-evaluators.html` 에 그대로 있어 **AIP 콘텐츠에 결함은 없다**(AIP 문항은 AgentCore `Builtin.` ID 를 쓰지 않고, md 가 쓰는 `Builtin.SkillSelectionAccuracy`·`SkillInstructionFollowing`·`FailureAnalysis` 는 `skill-evaluators.html`(5건·4건)·`insight-evaluators.html`(1건)에서 실재를 확인했다). AIF 트랙의 「13개와 ID 이름이 사라졌다」 → AIP G-30 의 「다시 열거한다」 → 오늘 「그 페이지에서 또 빠졌다」로 **세 번 뒤집힌 자리**이니 어느 자격증도 그 페이지의 개수·ID 열거에 기대면 안 된다.
3. **SCS·CLF·AIP: Kendra 상태** — AIP 는 Kendra 를 한 Task 에서만 쓰고 상태가 0건이다(Y8). 다른 자격증의 Kendra 표기는 재지 않았다(범위 밖). 2단계가 Y8 을 닫을 때 `grep -rn Kendra flutter_app/assets/content` 로 함께 세는 편이 싸다.

## 6. 공식 내부 어긋남 / 「확인되지 않음」 — 수정안을 낼 수 없는 것

**공식 내부 어긋남**
| 자리 | 한쪽 | 다른 쪽 | AIP 처리 |
|---|---|---|---|
| RAG 평가의 그라운드 트루스 | `evaluation.html` 「The dataset must also include 'ground truth'」 | `knowledge-base-evaluation-metrics.html` — Context coverage 행에만 필수 | Y5 |
| 사용자 지정 모델 추론 경로 | `prov-throughput.html` 「If you customized a model, you must purchase Provisioned Throughput」 | `model-customization-use.html` 「one of the following options: Purchase Provisioned Throughput … Deploy custom model for on-demand inference」 | 이미 「경로 둘」로 가르친다(가드 있음). 결함 아님 |
| Guardrails 단어 필터 | `guardrails-components.html` 「(exact match)」 | `guardrails.html`·`guardrails-word-filters.html` 「case-insensitive whole-word and whole-phrase matching」 | G4 |
| Agents Classic 차단일 | `maintenance_services.html` 「June 30, 2026」(공지일) | `agents-classic-maintenance-mode.html` 「starting on July 30, 2026」 | 날짜를 묻지 않는다(G-24). 문항에 날짜 0건 — 결함 아님 |
| 책임 있는 AI 「여덟」 | 렌즈 페이지의 「eight focus areas」(초점 영역) | 같은 페이지의 차원 열 개 열거 / AWS 다른 면의 여덟 차원 | `t3-3-q9` 가 「열 ↔ 여덟 **차원**」으로 적는다. 렌즈 페이지 안의 「eight」 는 차원이 아니라 초점 영역이라는 점을 해설에 더하면 혼동이 준다 |

**확인되지 않음** (수정안을 「걷는다」로만 냈다)
- Y1: 버전 없는 `promptArn` 이 프롬프트 초안 변경을 따라가는지.
- Y2: Aurora 에서 메타데이터 필드 없이 필터를 걸었을 때의 실제 동작.
- Y3: Web Crawler 의 인증 콘텐츠 지원 여부(지원한다고도, 안 한다고도 커넥터 페이지가 적지 않는다).
- Y4: Guardrails tier 미지정 시 기본값(사라진 문장. API 참조도 기본값 미기재).
- Y10: Well-Architected Agent(프리뷰)의 과금.
- `t5-1-q3` 해설 「델타가 붙은 지표는 섭동을 준 입력과 원 입력의 점수 차이」 — `model-evaluation-tasks.html` 은 Robustness 행에 `deltaBERTScore`·`deltaF1` 을 적을 뿐 정의는 없다(`perturb`·`noise` 0건). 정답(「델타 지표는 강건성 축」)은 표로 확인된다. 정의 한 절의 출처가 비어 있다 — 🟡로 세지 않았다.

**「그 사실을 담지 않는」 인용 페이지 23개** (2단계가 출처를 고칠 때의 체크리스트. Y13 의 예시-대응 페이지는 `welcome.html`·`structured-output.html` 둘만 넣었다)
`generative-ai-lens.html`(Y9) · `userguide/well-architected.html`(Y10) · `byoc-input-and-output.html`(Y12) · `comprehend-availability-change.html`(날짜, Y12) · `knowledge-base.html`(Y3·Y12 ×3) · `knowledge-base-setup.html`(Y2) · `flows.html`+`prompt-management.html`(Y1) · `agentcost01-bp01.html` · `gateway-using-mcp-semantic-search.html` · `agentsec06-bp02.html`(Y12) · `apigateway/.../welcome.html`(Y13) · `guardrails-tiers.html`(Y4·Y12) · `guardrails-content-filters.html`(Y12) · `structured-output.html`(Y13) · `what-is-lake-formation.html` · `cloudtrail-user-guide.html` · `catalog-and-crawler.html` · `kb-test-config.html` · `observability-tool-metrics.html`+`supported-frameworks.html` · `how-it-works-evaluations.html`(Y12) · `evaluations-types.html`(Y11).

## 7. 2단계에 넘기는 순서 제안

**의존 관계**
- Y2 ↔ Y12 `t4-2-q5` — **같은 페이지(`knowledge-base-setup.html`)의 같은 Note** 를 두 Task 가 나눠 쓴다. 한 번에 고친다(md 는 `aip-t1-5`·`t4-2`·`t4-3`·`t5-2` 넷).
- Y4 ↔ §5-1 — **AIF 의 보존 가드를 먼저** 뒤집지 않으면 AIF 쪽이 고아 인용 + 레드 위험이다. 교차 자격증 작업으로 묶는다.
- Y12·Y13·Y8·Y10 의 출처 추가는 **md 프런트매터 + 「출처」 절을 먼저** 늘린다(G-84 · 프런트매터 ↔ 출처 절 동기). 삽입 위치는 `lastVerified:` 바로 앞.
- Y7·G3 의 문항 교체는 **그 Task 의 형제 14문항 주제를 먼저 세고** 한다(G-50·G-52: 중복을 해소하며 새 중복을 만든 선례). 정답은 원래 자리에 두고 `skill`·`section`·`difficulty`·`verified` 는 원본 값을 옮긴다.
- Y6 을 고친 뒤 M2 가드를 건다(가드를 먼저 걸면 레드로 시작한다 — 그것도 TDD 로는 맞다).

**권장 순서**
1. **정답 전제 미확인 3건** — Y1 `t1-6-q15` · Y2 `t1-5-q8` · Y3 `t1-4-q11`(+`q6`·`q10`). flip 을 막는 유일한 묶음이다.
2. **사라진·어긋난 공식 문장** — Y4(+§5-1 AIF) · Y5 · Y10.
3. **저작 메모·문장 오류** — Y6 · Y11 · G1. (문구만 바뀌고 정답 불변. M2 가드 신설.)
4. **상태 누락** — Y8(Kendra). 가드 규율 표에 Kendra 행 추가를 함께 검토.
5. **출처 일괄** — Y9 · Y12(16문항) · Y13(18문항). 기계적이고 양이 가장 많다.
6. **메타 문항 재작성·중복 해소** — Y7(4문항) · G3 A~D(4문항).
7. 선택 — G2(지문 틀) · G4 · G5 · G6.

**Task 별 flip 준비도** (🟡 문항 수. 「핵심」= Y1~Y12, 「전체」= Y13 포함)

| Task | 핵심 | 전체 | 걸린 문항 | 비고 |
|---|---|---|---|---|
| `t1-1` | 3 | 3 | q1 · q5 · q13 | 출처·귀속만 |
| **`t1-2`** | **0** | **0** | — | ✅ **15/15 통과.** G3-C(`q13`↔`t2-2-q4`)만 남는다 |
| `t1-3` | 3 | 3 | q6 · q7 · q15 | 출처 추가 3줄이면 닫힌다 |
| `t1-4` | 7 | 8 | q1 · q3 · q4 · q5 · q6 · q9 · q10 · q11 | 가장 무겁다 |
| `t1-5` | 1 | 4 | q7 · q8 · q13 · q15 | Y2 |
| `t1-6` | 1 | 3 | q4 · q9 · q15 | Y1 |
| `t2-1` | 3 | 3 | q4 · q7 · q13 | 출처 추가뿐(md 에 이미 있는 URL) |
| `t2-2` | 2 | 3 | q7 · q10 · q15 | 메타 문항 둘 |
| `t2-3` | 1 | 3 | q5 · q6 · q15 | |
| **`t2-4`** | **0** | 2 | q13 · q15 | 핵심 0. Y13 출처만 |
| **`t2-5`** | **0** | 2 | q8 · q9 | 핵심 0. G1 `q10` 한 문장 |
| `t3-1` | 2 | 3 | q5 · q13 · q14 | Y4 |
| **`t3-2`** | 1 | 1 | q6 | 출처 한 줄(Governed Tables) |
| `t3-3` | 4 | 5 | q5 · q7 · q9 · q14 · q15 | |
| `t3-4` | 3 | 3 | q5 · q7 · q11 | Y6·Y5 |
| **`t4-1`** | **0** | **0** | — | ✅ **15/15 통과.** G1 `q7` · G4 `q11` 문구만 |
| `t4-2` | 1 | 1 | q5 | 출처 교체 |
| `t4-3` | 1 | 1 | q9 | 출처 추가 + Strands 한정 |
| `t5-1` | 3 | 3 | q1 · q10 · q11 | |
| **`t5-2`** | **0** | 3 | q7 · q11 · q14 | 핵심 0. G3 A·B 로 `q3`·`q4` 교체 권고 |

**게이트(7 Task 105문항 — D1 2 · D2 2 · D3 1 · D4 1 · D5 1)를 가장 싸게 여는 조합**: `t1-2` + `t1-3` (D1) · `t2-4` + `t2-5` (D2) · `t3-2` (D3) · `t4-1` (D4) · `t5-2` (D5). 이 일곱 Task 의 수정량은 **출처 추가 4문항(`t1-3-q6·q7·q15` · `t3-2-q6`) + Y13 출처 7문항 + 문구 3자리(G1·G4) + 선택 교체 2문항(`t5-2-q3·q4`)** 이고 정답 전제 미확인(1순위 묶음)은 **한 건도 걸리지 않는다.** ⚠️ flip 직전에 그 Task 의 출처를 한 번 더 열어 본다 — 저작 뒤 사흘 사이에 공식 문장 둘이 사라졌다(Y4·Y10).

**이 검증이 보지 못한 것**
- 학습문서 20편의 **전문 통독은 하지 않았다**(약 800KB). 문항에 닿는 주장은 300문항 대조로 간접 검증됐지만, 문항이 한 번도 쓰지 않는 md 전용 서술(용어 표·「흔한 함정」의 일부·자가 점검 해설)은 사각이다. `aif.md` 가 「시험 직전 요약」·「자가 점검」 통독에서 🔴 1건을 찾은 선례가 있으므로, 2단계 또는 별 패스에서 **md 의 「시험 직전 요약」·「자가 점검」 두 절만이라도** 같은 Task 문항 정답과 맞대는 것을 권한다.
- 인용 페이지 대조는 **탐침 방식**이다(문항이 단정하는 수치·고유명·핵심 구절을 영문으로 넣어 적중 여부를 봤다). 적중한 문구 주변을 읽어 확인했지만 페이지 전문을 통독한 것은 24개(문서 리더)와 소형 페이지 몇 개뿐이다. 「적중했는데 문맥이 다른」 경우를 전부 걸렀다고 보장하지는 못한다.
- `review.mjs build aip`(검수 뷰어)와 `flutter test` 는 돌리지 않았다(계약 §5-6).
