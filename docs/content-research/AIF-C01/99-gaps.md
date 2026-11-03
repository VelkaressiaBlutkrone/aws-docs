---
생성: 2026-11-03
목적: AIF-C01 저작 착수 전 「판정 필요」·「상충」·「확인 필요」 전수
읽는 법: ⛔ = 저작을 막는 차단급 · ⚠️ = 저작 전 판정 필요 · ℹ️ = 기록만
---

# 99 — 갭과 판정 필요 항목 (AIF-C01)

> 이 레포의 규율: **공식 문서로 확인되지 않은 것은 학습문서·문항에 쓰지 않는다.** 확인되지 않은 항목을 "확인되지 않았다"는 가드로 거는 것도 하지 않는다 — 근거가 뒤에 확인되면 옳은 문장이 막힌다(SAA 갭 배치에서 얻은 교훈).

## ⚠️ 열린 확인 항목

### G-21 ⚠️ 도메인 1·2 6편은 **영문 가이드와 대조하지 않았다**

- 도메인 3에서 **한국어 판과 영문 판이 다른 자리**를 처음 찾았다(G-18 — 목표 3.2.1의 「모델 잠재 공간」이 영문에 없다). 지금까지 쓴 10편 중 **도메인 1·2 6편은 한국어 가이드만 보고** 썼다.
- **다음 할 일:** 도메인 4·5 배치에서 영문 판을 함께 읽고, 같은 배치에서 **도메인 1·2의 목표를 영문과 대조**한다. 차이가 나오면 G-18과 같은 규율로 처리한다(한국어 목표를 따라 소개하고 불일치를 ⚠️로 명시하되 **문항 근거로 쓰지 않는다**).
- ⚠️ 이 항목이 닫히기 전에는 **도메인 1·2 목표의 낱말을 문항 정답 근거로 삼지 않는다.**

## 해소된 것

### G-01 ✅ 시험 시간 (해소, 2026-11-03)

- **문제였던 것:** 시험 가이드 본문(한국어·영문 양쪽)에 시험 시간이 **없다**. 레포 `exam_guides/AIF-C01.json`의 `durationMinutes: 90`은 근거가 적혀 있지 않았다.
- **해소:** 공식 인증 페이지가 `Exam duration **90 minutes**` · `Exam format **65 questions**`를 적는다(https://aws.amazon.com/certification/certified-ai-practitioner/ , 2026-11-03). 65 = 채점 50 + 비채점 15로 가이드 본문과 맞는다.
- **판정:** 레포 JSON의 90분은 **옳다.** `exam_guides/AIF-C01.json`에 출처를 남긴다.
- ⚠️ DVA-C03은 같은 항목(G-03)이 **미해소**로 남아 있다 — 그쪽은 C03 인증 페이지가 아직 C02 수치를 적기 때문이다. AIF는 현행 버전이라 해소됐다.

## 저작 전 판정 필요 — ✅ 전부 해소 (2026-11-03)

> 아래 일곱 항목은 [98-authoring-decisions.md](98-authoring-decisions.md)의 저작 결정으로 닫혔다: **G-02 → D-05** · **G-03 → D-02** · **G-04 → D-03** · **G-05 → D-01·D-04** · **G-06 → D-06·D-09**(본문을 정본으로) · **G-14·G-15 → D-07**(닫힌 서비스는 설명용으로만). G-07·G-08·G-09는 조사 단계에서 이미 해소됐다. 본문은 판정 근거로 남겨 둔다.

### G-02 ✅ 공식 문항 유형 4종 vs 이 레포의 문항 스키마 (해소 — D-05)

- **사실:** 공식 가이드가 적는 문항 유형은 **선다형 · 복수 응답형 · 순서 배열 · 매칭형** 4종이다. 복수 응답형은 "정답을 모두 선택해야 득점", 순서 배열은 "3~5개를 올바른 순서로", 매칭형은 "3~7개 쌍을 모두 정확하게"다.
- **제약:** 이 레포의 문항 스키마는 `options` 4개 + `correct` **단일 인덱스**이고 러너도 단일 선택만 렌더한다(`exam_view.dart`·`OptionTile`). 나머지 3종은 **표현할 수 없다.**
- **판정 필요:** ① 선다형만 출제하고 학습문서에서 "실제 시험에는 네 유형이 있다"를 **설명으로** 다룰 것인가, ② 복수 응답형을 "다음 중 옳은 조합"식 단일 선택으로 **번역**할 것인가(다른 자격증에서 쓰는 방식인지 먼저 확인), ③ 스키마 확장은 범위 밖으로 둘 것인가.
- **참고:** CLF·SAA·SOA·DEA·MLA 전부 같은 스키마로 저작됐으므로 선례는 ①+②다. 저작 결정 문서에 명시한다.

### G-03 ✅ 도메인 3 한국어 이름이 공식 한 페이지 안에서 갈린다 (해소 — D-02, 가드가 `domainName` 문자열을 단정한다)

- 도메인 페이지 제목·Topics: "콘텐츠 도메인 3: 파운데이션 모델**의** 적용"
- 같은 가이드 「내용 개요」 목록: "콘텐츠 도메인 3: 파운데이션 모델 적용"
- **판정(제안):** DVA-C03에서 정한 규칙(**이름은 도메인 페이지 제목, 비중은 「내용 개요」**)을 그대로 쓴다 → `파운데이션 모델의 적용`. 레포 JSON도 이미 이 표기다.
- 선언 없이 저작하면 14편에 두 표기가 섞인다(DVA에서 실제로 가드를 붙여 막은 항목).

### G-04 ✅ 목표 번호는 공식 본문에 없다 (해소 — D-03)

- 도메인 본문은 Task 아래 "목표:" 뒤에 **불릿만** 적고 번호를 쓰지 않는다. 번호(`1.1.1` …)는 **개정 페이지**가 "목표 1.1.1" 식으로 부를 때만 등장한다.
- **판정(제안):** 개정 페이지의 호칭과 같은 규칙으로 **본문 순서대로** 번호를 매긴다. [00-overview.md](00-overview.md) §3이 그렇게 전사했고, 레포 JSON의 배열 순서와 **번호·순서가 완전히 일치**함을 기계로 확인했다([97-repo-json-diff.md](97-repo-json-diff.md) §1 대조군).
- 학습문서의 자가 점검·문항 `skill` 태그에 번호를 쓸 때 이 규칙을 명시한다.

### G-05 ✅ AIF 가이드에는 Skill 계층이 없다 (해소 — D-01 문서 단위 = Task 14편 · D-04 문항 `skill` = 목표 번호)

- DVA-C03·SOA-C03은 Task 아래 **Skill**(`지식`/`기술`) 계층을 두는데, AIF-C01은 Task 아래 **"목표(objectives)" 한 층**뿐이다. 레포 JSON도 `knowledge`만 채우고 `skills`는 **14 Task 전부 빈 배열**이다.
- **영향:** ① 학습문서 단위는 **Task = 14편**으로 자연스럽게 정해진다(공식 Task 1개 = `.md` 1개 레시피 그대로). ② 문항 가드의 "스킬 태그 실재·Task별 전 항목 커버리지" 설계(MLA 판)를 쓰려면 **태그의 대상이 Skill이 아니라 목표**가 된다.
- **판정 필요:** 문항 `skill` 필드에 목표 번호(`1.1.3`)를 쓸지, 목표 본문의 키워드를 쓸지. MLA 판 가드를 복제하려면 전자가 맞다.

### G-06 ✅ 공식 내부의 어긋남 — 개정 표와 본문이 다르다 (5계열 6곳, 해소 — 본문을 정본으로: D-06·D-09)

전수 표는 [97-repo-json-diff.md](97-repo-json-diff.md) §4다. 요약:

1. **`Amazon Q`** — 개정 표는 "범위 내 추가"로 적고 목표 1.3.4 예시에도 넣지만, **범위 내 서비스 목록 본문과 도메인 1 본문에는 없다.**
2. **`SageMaker Cartify`**(개정 표 4.2.2) — 도메인 4 본문에는 그 이름이 **없고** `Amazon Bedrock 모델 평가`가 있다. 레포 JSON은 또 다른 표기 `SageMaker Clarify`를 쓴다. → 세 소스가 다 다르다.
3. **범위 외 제거 4건**(DeepComposer · IAM Identity Center · Marketplace · Organizations) — 개정 표는 제거됐다고 적지만 **범위 외 목록 본문에 여전히 있다.**
4. **목표 2.2.3** — 개정 표 v1.1 칸에는 "비용, 대기 시간, 모델 복잡성"이 추가돼 있지만 **도메인 2 본문에는 없다.**
5. **목표 5.1.4** — 개정 표는 "**신속한 삽입**", 본문은 "**프롬프트 인젝션**"(`prompt injection`의 오역이 본문에서 교정된 것으로 읽힌다).
- **판정(제안):** **본문을 정본으로** 쓴다. 개정 표는 v1.1 게시 시점 스냅샷이고 본문이 그 뒤 교정된 상태로 보인다(5번이 그 증거다). 다만 **②·④는 "본문에 없으니 쓰지 않는다"로 끝내지 말고** 아래 G-07·G-08의 공식 확인 결과를 함께 본다.

### G-07 ✅ `Amazon Q`를 AIF 범위에서 어떻게 다루는가 (해소 — 판정: 정답 보기 금지)

- **범위 목록 실측:** `Amazon Q`는 **범위 내 목록에도, 범위 외 목록에도 없다**(개정 표에만 있다 — G-06).
- **공식 상태(조사 결과, [95-aws-ai-tools-naming.md](95-aws-ai-tools-naming.md)):** **`Amazon Q`의 양쪽 축이 모두 축소 중이다.** Q Business는 신규 고객에게 닫혔고 공식 이전 대상이 **Amazon Quick**이며, Q Developer IDE 플러그인·유료 구독은 **2027-04-30 종료**다. 레포에 남아 있던 "Q Developer 2027-04-30 종료" 기록은 맞지만 **절반이었다.**
- ⚠️ **"Q Developer가 전부 끝난다"고 쓰면 틀린다** — 공지가 AWS Management Console·문서 사이트·Console Mobile App·Chat Apps(Slack·Teams)는 "not impacted"로 명시한다.
- **판정:** v1.1이 추가한 `Amazon Quick`·`Kiro`가 **정확히 Q의 두 축을 잇는 후속**이다. 따라서 `Amazon Q`는 **문항 정답 보기로 쓰지 않고**, 학습문서에서 "Quick·Kiro의 전신"으로만 언급하며 종료·이전 상태를 병기한다(DVA의 Compute Optimizer 처리와 같은 규율: **"목록에 없다 ≠ 범위 밖"**이지만 보기로는 쓰지 않는다).

### G-08 ✅ 4.2.2의 서비스 이름 (해소 — `Cartify`는 오표기, 정본은 `Amazon Bedrock Model Evaluations`)

- **영문 가이드 본문 실측(2026-11-03):** 목표 4.2.2는 "(for example, **Amazon SageMaker Model Cards, Amazon Bedrock Model Evaluations**, open source models, data, licensing)"이다. **영문 본문에도 `Cartify`는 없다** → 개정 표에만 있는 표기이고, 한국어 본문의 "Amazon Bedrock 모델 평가"와 영문이 일치한다.
- **`SageMaker Cartify`는 존재하지 않는 서비스다.** 실제 서비스는 **`Amazon SageMaker Clarify`**이고(설명 가능성·편향 탐지·FM 평가), 개정 표의 `Cartify`는 그 오표기로 읽힌다.
- ⚠️ **그런데 Clarify를 "지금 쓰는 도구"로 가르치면 안 된다** → G-15.
- **판정:** 저작에는 **본문 표기 `Amazon SageMaker Model Cards` · `Amazon Bedrock Model Evaluations`(한국어 「Amazon Bedrock 모델 평가」)**를 쓴다. `Cartify`는 레포 어디에도 쓰지 않는다.

### G-09 ✅ 「컨텍스트 엔지니어링」 (해소 — 서비스 문서에 없다, 블로그 1곳)

- **실측:** `docs.aws.amazon.com`에 그 **용어가 없다.** 공식 정의는 AWS 블로그 1곳뿐이고("carefully selecting the right information to include in the context window at each step"), 같은 내용의 정본은 **Agentic AI Lens `AGENTPERF03-BP02`**("context window utilization")다. 근거는 [96-fm-cost-eval-guardrails.md](96-fm-cost-eval-guardrails.md).
- **판정:** 목표 2.1.5가 그 이름을 쓰므로 **학습문서에서는 그 이름으로 가르치되** 공식 정의가 블로그임을 각주로 남기고, **문항에서 서비스 기능명처럼 쓰지 않는다**(정답이 특정 서비스 이름으로 결정되는 문항을 만들지 않는다).

### G-15 ✅ `Amazon SageMaker Clarify`도 신규 고객에게 닫혔다 (해소 — D-07, 컨트롤러 직접 실측)

- **공식 원문:** "**Amazon SageMaker Clarify is no longer open to new customers.** Existing customers can continue to use the service as normal. AWS continues to invest in security and availability improvements for Clarify, but we do not plan to introduce new features."
  - https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-availability-change.html (2026-11-03)
- **대체 경로(같은 페이지):** FM(LLM) 평가는 **fmeval 라이브러리 · Amazon Bedrock Evaluations · Amazon Bedrock Guardrails**로 간다. ⚠️ 단 공식이 "**not a replacement for predictive (tabular/classical ML) bias detection or explainability**"라고 못박는다 — 표형 ML 편향 지표는 **공표된 산술**(DPL·DPPL·DI·CI)이라 pandas·scikit-learn으로 재현하고, 설명 가능성은 **Clarify가 내부적으로 쓰는 SHAP**을 직접 쓴다.
- **왜 중요한가:** **레포 JSON이 Clarify를 4.1.7·4.2.2 두 곳에서 예시로 들고 있다**([97-repo-json-diff.md](97-repo-json-diff.md) §2.1). 공식 v1.1 본문에는 그 이름이 **없고**, 서비스 자체가 신규 고객에게 닫혔다. JSON을 그대로 쓰면 **"지금 쓰면 되는 FM 평가 도구"를 틀리게 가르친다.**
- **판정:** Clarify는 **설명용으로만** 다루고(편향 지표·SHAP의 유래), "지금 선택하는 도구"를 묻는 문항의 정답으로 쓰지 않는다. 그 자리의 정답은 **Bedrock Evaluations / Guardrails**다.
- ⚠️ G-14(Bedrock Agents Classic)와 같은 계열이다 — **v1.1이 예시에서 지운 서비스가 실제로 닫히는 중**이라는 패턴이 두 번 반복됐다. 저작 시 "가이드가 예시를 뺀 서비스"는 먼저 상태를 확인한다.

### G-14 ✅ `Amazon Bedrock Agents`는 개명됐고 신규 고객에게 닫혔다 (해소 — D-07, 컨트롤러 직접 실측)

- **공식 원문:** "Amazon Bedrock Agents (launched November 2023) is now **Amazon Bedrock Agents Classic** and will no longer be open to new customers starting on **July 30, 2026**." 그리고 "Only the Amazon Bedrock Agents Classic service is no longer open to new customers as of July 30, 2026. Your existing Amazon Bedrock models, Knowledge Bases, and Guardrails are **not affected**."
  - https://docs.aws.amazon.com/bedrock/latest/userguide/agents-classic-maintenance-mode.html (2026-11-03)
  - 사용자 가이드 `agents.html`의 Note에도 같은 내용이 있고 "explore Amazon Bedrock AgentCore"를 권한다(2026-11-03).
- **왜 중요한가:** 공식이 목표 **3.1.6**에서 v1.0의 예시("Amazon Bedrock Agent, 에이전틱 AI, 모델 컨텍스트 프로토콜")를 **삭제하고** 서비스 중립 문구로 바꾼 것과 방향이 맞는다. 즉 v1.1의 에이전트 목표는 **AgentCore 쪽**을 전제로 읽어야 한다(범위 내 목록에도 `Amazon Bedrock AgentCore`가 새로 들어왔다).
- **판정:** 학습문서에서 `Amazon Bedrock Agents`를 "현재 권장 경로"로 쓰지 않는다. 다루더라도 **Agents Classic(유지 관리 모드)**임을 밝히고, 에이전트 구축의 정본은 **AgentCore**로 쓴다. `Amazon Bedrock` 자체·Knowledge Bases·Guardrails는 영향이 없으니 그 셋을 함께 깎아내리지 않는다.
- ⚠️ **중단일(서비스 종료일)은 공식 문서에 없다** — 확인된 것은 **신규 고객 차단일(2026-07-30)**과 "기존 고객은 계속 사용"뿐이다. 종료 예정일을 단정하지 않는다.
- 자세한 사실·마이그레이션 경로는 [94-agentic-ai-and-mcp.md](94-agentic-ai-and-mcp.md)에 있다.

## 기록만

### G-10 ℹ️ 범위 밖인데 다른 자격증 학습문서에 흔한 서비스들

AIF **범위 외** 목록에 있어 이 자격증 문항에 쓸 수 없는 것 중, 레포의 다른 자격증 문서에서 자주 쓰이는 것들이다. 재사용 시 사고가 나는 지점이라 적어 둔다.

`Amazon Cognito` · `AWS Organizations` · `AWS IAM Identity Center` · `Amazon GuardDuty` · `AWS Security Hub` · `Amazon Detective` · `Amazon Route 53` · `AWS X-Ray` · `AWS WAF` · `AWS Shield` · `AWS Backup` · `AWS DMS` · `Amazon CodeCatalyst` · `AWS Control Tower` · `AWS Health Dashboard`

### G-11 ℹ️ 범위 내인데 AI와 무관해 보이는 것들

`Amazon EMR` · `AWS Glue DataBrew` · `AWS Lake Formation` · `Amazon Redshift` · `AWS Data Exchange` · `Amazon DocumentDB` · `Amazon ElastiCache` · `Amazon S3 Glacier` · `Amazon CloudFront` · `AWS Budgets` · `AWS Cost Explorer` · `AWS Well-Architected Tool`

데이터 준비·비용·거버넌스 목표(1.3.x · 2.3.4 · 5.2.x)에서 묻힐 수 있으므로 **범위 내임을 전제로** 저작한다.

### G-12 ℹ️ `AWS Certified AI Business Strategist`가 공식에 존재한다

- 공식 인증 페이지의 FAQ가 AIF와의 차이를 설명하며 **`AWS Certified AI Business Strategist`**를 든다("validates business judgment for AI decisions … does not assess knowledge of AWS AI services", 2026-11-03).
- 이 자격증은 레포 `site_data.dart`의 12종에 **없다.** 콘텐츠 0 자격증 목록을 넓힐 때의 후보로만 기록한다 — 이 PR 범위 밖이다.

### G-20 ⚠️ 도메인 3 저작에서 **문서 간 모순을 두 건 잡았다** (같은 배치 안에서)

네 편을 **병렬**로 쓰면 **서로 어긋난 서술이 같은 PR에 들어올 수 있다.** 실제로 두 건이 나와 머지 전에 고쳤다. **다음 배치도 교차 대조를 반드시 한다.**

1. **「사용자 지정 모델은 PT 필수」 ↔ 「경로가 둘」** — `aif-t3-1`은 공식 추론 설정 페이지를 읽고 **두 경로**로 썼는데, `aif-t3-3`은 PT 페이지의 옛 문장을 그대로 받아 **"PT 없이는 쓸 수 없다"**를 세 곳에 적었다. G-19 판정대로 **t3-3의 세 곳을 두 경로 서술로 고쳤다**(요약 불릿 · 본문 인용 블록 · 시험 포인트).
2. **「계속 사전 훈련」 ↔ 「지속적인 사전 훈련」** — 공식 가이드 목표 3.3.1·3.3.2의 표기는 **「지속적인 사전 훈련」**이다. `aif-t3-3`은 그것을 썼지만 `aif-t2-1`(2곳)·`aif-t3-1`(5곳)이 **「계속 사전 훈련」**을 쓰고 있었다 → **공식 표기로 통일**(7곳 치환, `t3-3`의 용어표에 "「계속 사전 훈련」으로도 번역된다" 병기 1곳만 남겼다). ⚠️ `aif-t2-1`은 **이미 머지된 편**이라 이 PR에서 함께 고쳤다.
   - ⚠️ **치환 단정이 수를 바로잡았다** — `grep -n`이 4곳으로 보였는데 실제는 **5건**이었다(한 줄에 두 번 나온 곳이 있다). 단정이 없으면 "4건 고쳤다"는 거짓 기록이 남는다.

### G-18 ⚠️ 한국어 가이드와 영문 가이드가 다르다 — 목표 3.2.1 (컨트롤러 직접 실측)

**이 트랙에서 처음 나온 종류의 불일치다.** 지금까지는 「개정 표 ↔ 본문」이었는데(G-06), 이것은 **같은 목표의 한국어판과 영문판이 다르다**.

| 판 | 목표 3.2.1 예시 |
|---|---|
| 한국어 | "예: 컨텍스트, 명령, 네거티브 프롬프트, **모델 잠재 공간**" |
| 영문 | "(for example, context, instruction, **negative prompts**)" — **latent space가 없다** |

- https://docs.aws.amazon.com/ko_kr/aws-certification/latest/ai-practitioner-01/ai-practitioner-01-domain3.html · https://docs.aws.amazon.com/aws-certification/latest/ai-practitioner-01/ai-practitioner-01-domain3.html (둘 다 2026-11-03)
- ⚠️ 게다가 **`docs.aws.amazon.com`에 「모델 잠재 공간」의 정의 페이지가 없다**(AWS 블로그 서술만 있다).
- **판정:** `aif-t3-2`가 한국어 목표를 따라 그 낱말을 **소개**하되 **불일치를 ⚠️로 명시**하고, 수식·차원은 가이드가 **범위 밖**으로 적은 "수학·통계 분석"에 해당한다고 닫았다. ⚠️ **문항에서 이 항목을 정답 근거로 쓰지 않는다.**
- ⚠️ **다음 배치부터 영문 판도 함께 본다** — 한국어만 읽으면 한쪽에만 있는 낱말을 공식 요구로 착각한다. 지금까지 쓴 6편은 한국어 기준이고, 도메인 1·2에서 같은 종류의 차이가 있는지는 **아직 대조하지 않았다**(열린 확인 항목).

### G-19 ⚠️ "사용자 지정 모델은 프로비저닝 처리량 없이 못 쓴다"는 과도한 일반화다 (컨트롤러 직접 실측)

- `prov-throughput.html`은 *"If you customized a model, you must purchase Provisioned Throughput to be able to use it."*로 적는다.
- 그러나 **더 구체적인** `model-customization-use.html`(「Set up inference for a custom model」)이 선택지를 **둘**로 적는다: ① **Purchase Provisioned Throughput** ② **Deploy custom model for on-demand inference** — *"you only pay for what you use and **you don't need to set up provisioned compute resources**."* 온디맨드 배포에는 리전·기반 모델·사용자 지정 시점 제약이 있다(`deploy-custom-model-on-demand.html`).
- **판정:** 레포 규율(공식이 갈리면 **더 구체적인 쪽**)대로 **"PT 필수"로 단정하지 않는다.** 안전한 서술은 **"사용자 지정 모델은 전용 용량을 사거나 배포를 따로 만들어야 호출할 수 있다"**이고, 두 선택지를 함께 적는다. ⚠️ **문항에서 "PT가 유일한 경로"를 정답으로 쓰지 않는다.**
- 조사 노트 [96-fm-cost-eval-guardrails.md](96-fm-cost-eval-guardrails.md)의 해당 두 줄(요금 표 주석 · 자가 점검 Q2)을 같은 PR에서 **정정했다** — 노트를 고치지 않으면 다음 배치가 같은 오류를 다시 쓴다.

### G-17 ⚠️ 공식 「생성형 AI 수명 주기」 페이지가 단계 수를 자기모순으로 적는다 (컨트롤러 직접 실측)

- **공식 원문:** "The generative AI lifecycle consists of **seven key phases**: scoping, model selection, model customization, development and integration, deployment, and continuous improvement."
  - https://docs.aws.amazon.com/wellarchitected/latest/generative-ai-lens/generative-ai-lifecycle.html (2026-11-03)
- ⚠️ **"일곱"이라고 적고 **여섯 개**를 센다**(scoping · model selection · model customization · development and integration · deployment · continuous improvement). 페이지의 소절 제목도 여섯 개다.
- **판정:** **단계 수를 단정하지 않는다.** `aif-t2-1`이 목표 2.1.3을 쓸 때 단계 **이름**만 쓰고 "단계 수를 외우지 마세요"를 명시했다. 문항에서 "FM 수명 주기는 몇 단계인가"를 묻지 않는다.
- ⚠️ 목표 2.1.3이 드는 공식 예시는 **7개 낱말**(데이터 선택 · 모델 선택 · 사전 훈련 · 미세 조정 · 평가 · 배포 · 피드백)이고 **이 렌즈 페이지의 6단계와 다른 분해**다. 가이드 목표와 렌즈를 섞어 "공식 N단계"를 만들면 둘 다 틀린다.

### G-16 ℹ️ 은퇴한 가이드를 출처로 쓴 자리 1건 (`aif-t1-2`)

`aif-t1-2.md`가 **"ML을 언제 쓰는가"**의 근거로 `docs.aws.amazon.com/machine-learning/latest/dg/when-to-use-machine-learning.html`을 인용한다. 이 페이지는 **은퇴한 Amazon Machine Learning 개발자 안내서**에 있고 상단에 "서비스를 더 이상 업데이트하지 않고 신규 사용자를 받지 않는다"는 배너가 붙는다.

- 그대로 둔 이유: ① 지금도 `docs.aws.amazon.com`에 게시돼 있고 ② 인용한 두 문장("단순 규칙·계산으로 목표값을 정할 수 있으면 ML이 필요 없다" · "규칙을 코딩할 수 없다 / 확장할 수 없다")이 **현행 Well-Architected ML 렌즈 `MLCOST02-BP01`의 서술과 일치**해 교차 확인된다. ③ 학습문서 본문에 **`Amazon Machine Learning`이라는 서비스 이름은 0건**이라 닫힌 서비스를 권하는 서술이 아니다.
- ⚠️ **다음 세션이 알아야 할 것:** 이 URL이 사라지면 `MLCOST02-BP01`로 교체하면 된다. 다만 **스팸 메일 예시만 사라진다**(그 예시는 은퇴 가이드에만 있다).
- 이것이 G-14·G-15와 같은 계열은 **아니다** — 그 둘은 "닫힌 서비스를 지금 쓰는 도구로 가르치는" 문제이고, 이것은 "살아 있는 문장을 은퇴한 페이지에서 인용하는" 문제다.

### G-13 ℹ️ 저작 선결(갭이 아니라 작업 항목)

- `pubspec.yaml`에 **`- assets/content/aif/` 신규 디렉터리 등록**이 필요하다(MLA에서 확인된 레시피 정정 — pubspec은 디렉터리를 개별 등록한다).
- **새 자격증 전용 포맷 가드**(`test/aif_doc_format_test.dart`)를 신설해야 한다 — `content_enrichment_test`는 **명시 허용 목록**(clf 19 · saa 24 · soa 20)이라 신규 자격증을 강제하지 않는다.
- `content_index.dart`에 14줄 등재(questionCount는 문항 저작 전까지 **0**).
- `kExamReadinessRequirements`에 AIF 정책 추가가 **필요하다** — 정책이 없는 자격증은 `hasPolicy:false → ready:false`로 **fail closed**라, 사람이 전 문항을 flip해도 모의고사가 영원히 잠긴다(MLA가 #246, SOA·DEA가 #254 전까지 그랬다). 공식 비중 20/24/28/14/14를 65문항에 배분한 값으로 넣는다.
- ⚠️ **`verified:true` flip은 사람만** 한다. 문항은 전부 드래프트로 저작하고, `flipAllowlist`(`review.mjs`의 `CERTS`)와 Dart 쪽 허용 목록 가드를 **flip 전에** 준비해 둔다 — 없으면 사람의 첫 flip이 "전 문항 드래프트" 단정에서 레드로 끝난다(SOA·DEA가 #285에서 겪은 함정).

## 출처

| 제목 | URL | 조회일 |
|---|---|---|
| AWS Certified AI Practitioner (인증 페이지) | https://aws.amazon.com/certification/certified-ai-practitioner/ | 2026-11-03 |
| 시험 가이드 본문·도메인·범위·개정 | [00-overview.md](00-overview.md) §8의 URL 9건 | 2026-11-03 |
