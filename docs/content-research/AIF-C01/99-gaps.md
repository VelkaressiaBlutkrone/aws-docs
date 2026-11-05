---
생성: 2026-11-03
목적: AIF-C01 저작 착수 전 「판정 필요」·「상충」·「확인 필요」 전수
읽는 법: ⛔ = 저작을 막는 차단급 · ⚠️ = 저작 전 판정 필요 · ℹ️ = 기록만
---

# 99 — 갭과 판정 필요 항목 (AIF-C01)

> 이 레포의 규율: **공식 문서로 확인되지 않은 것은 학습문서·문항에 쓰지 않는다.** 확인되지 않은 항목을 "확인되지 않았다"는 가드로 거는 것도 하지 않는다 — 근거가 뒤에 확인되면 옳은 문장이 막힌다(SAA 갭 배치에서 얻은 교훈).

## 해소된 것

### G-21 ✅ 도메인 1·2의 영문 가이드 대조 (해소 — 2026-11-03, 컨트롤러 직접 실측)

도메인 3에서 **한국어 판과 영문 판이 다른 자리**를 처음 찾은 뒤(G-18), 도메인 4·5 배치에서 **도메인 1·2의 목표 31건을 영문판과 전수 대조**했다. 양쪽을 직접 열어 읽었다(한국어 `ko_kr/.../ai-practitioner-01-domain1.html`·`-domain2.html`, 영문은 같은 경로에서 `ko_kr/`을 뺀 것).

**실질 차이 3건 · 표기 차이 2건**이고, **본문 내용은 세 건 모두 이미 덮고 있었다.**

| # | 자리 | 한국어판 | 영문판 | 판정 |
|---|---|---|---|---|
| ① | 목표 **1.3.2** | 「**ML 모델**의 소스 설명」 | "Describe sources of **FM models**" | ⚠️ **실질.** 한국어만 보면 전통 ML 모델 이야기로 좁게 읽힌다 |
| ② | 목표 **2.2.3** | 예시 **5개**(모델 유형·성능 요구 사항·기능·제약 조건·규정 준수) | 그 뒤에 **`cost, latency, model complexity` 3개를 더** 든다 | ⚠️ **실질.** 영문 기준이면 8개다 |
| ③ | 목표 **2.2.4** | 예시 목록에 **ROI가 없다** | **ROI가 있다**(공식 개정 표도 "추가"로 적는다) | ⚠️ **실질.** 한국어 본문이 개정 표와도 어긋난다 |
| ④ | 작업 **1.3** 제목 | 「**ML** 개발 수명 주기 설명」 | "Describe the **AI/ML** development lifecycle." | 표기. 한국어가 `AI/`를 떨어뜨렸다 |
| ⑤ | 목표 **2.1.6** | 「**에이전트** AI 개념」 | "foundational **agentic** AI concepts" | 표기. **영문은 1.1.1·1.1.2·1.2.4·2.1.6 전편에서 일관되게 `agentic AI`**다 |

**처리 (G-18과 같은 규율 — 한국어 목표로 소개 + 불일치 ⚠️ 명시):**

- ① → `aif-t1-3`의 목표 1.3.2 절에 주의 블록을 넣었다. 이미 그 절의 표 가운데 칸이 **관리형 FM API(Amazon Bedrock)**여서 내용은 FM을 덮고 있었다. 절 제목은 한국어 목표를 따르되 **"범위는 영문 쪽으로 읽는 것이 안전하다"**를 명시했다.
- ② → `aif-t2-2`의 목표 2.2.3 절에 주의 블록을 넣었다. 셋 다 이미 다섯 축 표 안에 있었다 — **요금·모델 복잡도는 「제약 조건」**, **추론 지연은 「성능 요구 사항」**. 포개져 있다는 사실만 밝혔다.
- ③ → `aif-t2-2`의 「v1.1에서 바뀐 것」 블록이 이미 **"목표 2.2.4의 지표 목록에는 ROI가 추가됐다"**고 적고 있었다(개정 표 근거). 거기에 **한국어 본문 예시 목록에는 빠져 있다**는 단서를 붙였다.
- ④⑤ → 본문 수정 없음. ⑤는 **D-09의 「에이전틱 AI」 판정이 옳았음을 영문이 확인**해 준 것이다(한국어판의 2.1.6만 흔들린다).

⚠️ **이로써 「도메인 1·2 목표의 낱말을 문항 정답 근거로 삼지 않는다」 제약이 풀린다.** 단 위 다섯 자리는 **문항 지문·정답 근거로 쓸 때 영문 쪽 범위로 읽는다** — 특히 ①(FM 포함)과 ②(예시 8개)다.

⚠️ **교훈:** 이 대조에서 바뀐 것은 **본문이 아니라 범위 인식**이었다. 한국어판만 보고 쓴 6편의 사실은 한 건도 틀리지 않았는데, **한국어 목표의 낱말로 문항을 만들면 ①·②에서 범위를 좁게 출제**했을 것이다. 영문 대조의 값은 사실 교정이 아니라 **출제 범위 확정**에 있다. 도메인 3·4·5는 저작 배치에서 영문을 함께 읽었다.

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

## 도메인 4·5 저작에서 얻은 것 (2026-11-03)

> 네 편을 병렬 저작하면서 **공식 문서를 직접 읽어** 찾은 것들이다. 조사 노트에 없던 자리이고 **문항 저작(Phase 3)에서 쓰인다.** 공식 내부가 어긋나는 것이 이 배치에서 다섯 건 나왔다 — 전부 **더 구체적인 쪽을 정본**으로 처리했다.

### G-22 ⚠️ 책임 있는 AI 「차원」 개수가 공식 안에서 8과 10으로 갈린다

- **Responsible AI Lens**(2025-11-19 게시)는 **10개**로 가른다 — 프라이버시와 보안을 갈라 둘, 진실성과 견고성을 갈라 둘.
- **Generative AI Lens `responsible-ai.html`**과 **AWS 책임 있는 AI 페이지**, **AWS AI 서비스 카드 용어집**은 **8개**로 묶는다.
- 교차 확인: Lens 안의 `RAIBR02`(유해 사건)·`RAIRC03`(측정) 모범 사례 목록에서도 **실제로 갈려 있다.** 그리고 가이드 **목표 4.1.1이 「견고성」과 「진실성」을 나란히 따로 든다** — 10개 분해에서만 자연스럽다.
- ⚠️ **처리:** 세 편(`aif-t4-1`·`aif-t4-2`·`aif-t5-2`)이 분기를 명시하고 **"개수를 묻는 문항은 성립하지 않는다"**로 적었다. 라이브였던 **`aif-t2-3`만 「여덟 차원으로 정의합니다」로 단정**하고 있어 같은 PR에서 고쳤다(G-20 규율 — 이미 머지된 편까지 통일).
- ⚠️ **설명 가능성의 정의도 두 자리가 다르다**(렌즈 "시스템 행동을 이해할 메커니즘" ↔ 서비스 카드 "시스템 출력을 이해하고 평가하는 것"). **투명성 정의만 글자까지 같다** → 투명성 문장은 외우고 개수는 외우지 않는다.
- ⚠️ **가이드 4.1.1의 여섯 낱말 중 둘은 AWS 차원 이름이 아니다** — **편향성**은 공정성 차원에서 **재는 대상**이고(`RAIRC03-BP02` 제목이 "Measure fairness as unwanted bias"), **포용성**은 `docs.aws.amazon.com`에 책임 있는 AI 용어 정의가 **없다**(정의를 지어내지 않았다).

### G-23 ⚠️ Guardrails 유해 범주 수가 공식 안에서 5와 6으로 갈린다

- `guardrails.html` 개요는 **6종**(Hate · Insults · Sexual · Violence · Misconduct · **Prompt Attack**)으로 묶는데, `guardrails-content-filters.html`은 정의를 **5종만** 싣고 그 페이지의 API `type` 열거에도 `PROMPT_ATTACK`이 없다.
- **전용 페이지 `guardrails-prompt-attack.html`이 `type: "PROMPT_ATTACK"`을 직접 적는다** → 더 구체적인 전용 페이지를 정본으로 **6종**을 쓴다. `aif-t4-1`(정책 카탈로그 정본)과 `aif-t5-1`(독성 축)이 **같은 판정으로 일치**한다(머지 전 대조 확인).
- ⚠️ **프롬프트 공격은 세 종류**이고 **「프롬프트 누출(Prompt Leakage)」은 Standard 계층 전용**이다.
- ⚠️ **가장 시험에 쓸 만한 운영 사실:** 프롬프트 공격 필터는 **입력 태그가 없으면 아예 동작하지 않는다** — "If there are no tags, prompt attacks for those use cases will not be filtered."
- ⚠️ **Guardrails의 PII 마스킹은 로그에 적용되지 않는다**(CloudWatch Logs의 `input`은 **항상 원본**, 트레이스의 `match`도 원래 PII 값 — **의도된 설계**). 대책은 CloudWatch Logs 데이터 보호 정책이고 **소급 적용되지 않는다.**
- ⚠️ **지식 기반에서 검색된 참조에는 Guardrails가 적용되지 않는다**(`kb-test-retrieve-generate.html` 맨 앞 Important).
- ⚠️ **Guardrails 미지원 모델이 있고 유형으로 추론해서는 안 된다** — 공식 경고 원문 "Don't infer guardrail support from the model type." `bedrock-mantle` 엔드포인트 미지원이고, **같은 요청에서 가드레일 파라미터만 빼면 성공**해 원인을 오진하기 쉽다.
- ⚠️ **안전 조치 계층(Standard·Classic)은 세 정책에만 있다**(콘텐츠 필터 · 거부 주제 · 문맥 근거 확인). **자동 추론 검사의 「못 하는 것」 6종**이 조사 노트에 전혀 없었다 — 프롬프트 인젝션 미방어 · 인코딩·난독화 시 **제출 전체가 평가되지 않을 수 있음** · 주제 이탈 미탐지 · **스트리밍 미지원** · **영어(미국) 전용** · `VALID`가 정책 변수 범위만 보장("위조 진단서" 공식 반례).

### G-24 ⚠️ 공식 문서가 아직 닫힌 서비스를 권하는 자리들 (배치마다 늘어난다 — 총 수를 단정하지 않는다)

- **머신 러닝 렌즈 `MLPERF06-BP02`** — 설명 가능성 평가 구현 9단계 중 **4단계가 `SageMaker Clarify`를 처방**한다(게다가 9단계에 `Amazon A2I`가 있다).
- **머신 러닝 렌즈 `MLCOST02-BP01`**(2026-11-05 추가, 컨트롤러 직접 실측) — 「Analyze model explainability」 단계가 **`SageMaker AI Clarify`**를 처방한다(`SageMaker AI Clarify` **2건** / `SageMaker Clarify` 0건). ⚠️ **이 페이지는 `aif-t1-2`가 가장 많이 인용하는 근거다** — 비용 항목·안티패턴·사기 탐지 대 재고 관리 예시는 유효하므로 그 세 부분만 인용하고 Clarify 단계는 쓰지 않았다.
- **머신 러닝 렌즈 `MLPERF06-BP03`·`MLSUS06-BP02`**(2026-11-05 추가) — 구현 단계가 Clarify·`SageMaker Model Monitor`를 든다. `aif-t1-3`은 **그 서비스 이름이 들어가지 않는 문장만** 인용했다.
- **Responsible AI Lens `RAIMON01-BP02`**(2025-11-19 게시) — 드리프트 탐지에 Clarify와 `SageMaker Model Monitor`를 든다.
- **`what-is/ai-bias`의 "How can AWS help?"** 절 — Clarify를 권한다.
- ⚠️ **교훈: 게시일이 최신이어도 서비스 상태는 따로 확인해야 한다.** 레포 규율대로 **서비스 자신의 가용성 변경 페이지를 정본**으로 잡고, 렌즈의 **방법론은 유효하지만 구현 수단의 이름이 낡았다**고 적었다. `aif-t4-1`의 자가 점검 Q8과 `aif-t4-2`의 함정에 고정돼 있다.

### G-25 ⚠️ `AWS Audit Manager`가 **유지 관리 모드**다 (D-07 네 번째 사례)

- 공식: "transitioning to maintenance mode and from April 30th 2026 customers will no longer be able to set up the service in new accounts" — 신규 기능·프레임워크·리전 추가 없음.
- ⚠️ **공식 범위 목록 양쪽에 아예 없고 레포 `exam_guides/AIF-C01.json`에만 있다**(97 §2의 "공식에 없는 서비스 예시" 계열). 저작 결정 **D-07 표에 추가**했다.
- **공식 내부 어긋남 1건이 여기 딸려 있다** — Audit Manager 가용성 변경 페이지의 매핑 표는 Config 대응물을 **`Operational Best Practices for AI and ML`**로 적는데, **AWS Config 샘플 템플릿 목록에 그 이름이 없다**(대신 **`Security and Governance Best Practices for ...` 네 개** — Amazon Bedrock · Amazon SageMaker AI · AI/ML Supporting Infrastructure · Self-Hosted AI/ML). **Config 쪽 이름을 정본**으로 썼다.

### G-26 ⚠️ 죽은 슬러그 2건 (회귀 가드 후보)

- **`bedrock/latest/userguide/guardrails-grounding.html`** — 실측하면 `num_redirects 1`로 Bedrock 사용자 가이드 인덱스로 간다. ⚠️ **에이전틱 AI 렌즈 `AGENTSEC01-BP03`의 「Related documents」가 접지 검사 페이지로 이 슬러그를 걸어 두었다** — 공식 링크를 그대로 인용하면 엉뚱한 페이지를 가리킨다. 정본은 `guardrails-contextual-grounding-check.html`이다.
- **`docs.aws.amazon.com/ai/responsible-ai/overview/overview.html`** — **404**다(AI 서비스 카드 색인을 추측 슬러그로 찾다가 실측). 그래서 **카드의 총 개수·전체 목록을 단정하지 않았다.**
- ⚠️ SOA·DEA에서 한 것처럼 **`source_url_retired_test.dart` 계열의 회귀 가드로 걸 후보**다. 다만 지금 레포에 그 두 슬러그는 **0건**이므로(실측) 가드는 Phase 3에서 AIF 출처가 늘어난 뒤에 함께 세운다.

### G-27 ℹ️ `AgentCore의 정책` 한국어 명칭 확인 — 조사 노트 94의 「확인 필요 3」 닫힘

- 한국어 가이드 본문이 **「AgentCore의 정책」**, 영문이 **`Policy in AgentCore`**다(어순만 다르고 같은 기능). 노트 `94`가 한국어 명칭을 못 찾았다고 적어 둔 항목이 닫혔다.
- **AgentCore 「Core services」는 13개**가 맞다(Harness · Runtime · Memory · Gateway · Identity · Code Interpreter · Browser · Observability · Payments · Evaluations · Optimization · Policy · Registry — 직접 실측). 노트 `94` §3.2가 정확하다.
- ⚠️ **정책 언어 서술이 공식 안에서 갈린다** — `policy.html`은 "Cedar로 구성하고 **Dogwood도 지원**", AgentCore 개요 표는 "정책 언어 **Dogwood**, Cedar와 **호환**". 어느 쪽을 주 언어로 **단정하지 않고 「두 언어」로만** 썼다.

### G-28 ℹ️ Well-Architected AI 렌즈 네 개의 **지위가 갈린다**

- **Generative AI · Machine Learning**은 **WA Tool 렌즈 카탈로그**에 있는 공식 렌즈다(설치 불필요).
- **Responsible AI(2025-11-19) · Agentic AI(2026-06-10)**는 **사용자 지정 렌즈**라 GitHub에서 JSON을 가져와야 한다. 카탈로그 전수를 읽어 **그 둘이 카탈로그에 없음**을 확인했다.
- 이 사실이 목표 5.2.1·5.2.3에서 쓰인다(`aif-t5-2`의 거버넌스 프레임워크 표).

### G-29 ℹ️ 「생성형 AI Security Scoping Matrix」의 정본은 docs가 아니라 블로그다

- **범위 5개**이고 두 묶음으로 갈린다 — 사는 쪽: 범위 1 소비자 앱 · 범위 2 엔터프라이즈 앱 / 만드는 쪽: 범위 3 사전 훈련된 모델 · 범위 4 미세 조정된 모델 · 범위 5 자체 훈련 모델. **보안 분야도 5개**(거버넌스와 규정 준수 · 법무와 프라이버시 · 위험 관리 · 통제 · 복원력).
- ⚠️ **`docs.aws.amazon.com`에 이 매트릭스를 정의한 페이지가 없다.** 정본은 **AWS 보안 블로그**이고, AWS SRA가 링크로 참조하며 "defines security scope and disciplines for different use cases"로만 적는다. `aif-t3-4`의 BLEU 처리 방식대로 **출처에 블로그임을 명시**했다.
- **다만 범위 번호는 docs 본문에서 실제로 쓰인다** — SRA `gen-ai-model-inference.html`이 "This use case corresponds to **Scope 3**…"로 적고 범위 4·5까지 언급한다. 그 문장을 범위 3의 정의 근거로 썼다.
- **매트릭스가 둘이다** — 같은 SRA 페이지가 **「Agentic AI Security Scoping Matrix」**를 "에이전트에게 부여되는 자율성과 대행 권한을 정의한다"로 소개한다(역시 블로그 정본).
- ⚠️ **Generative AI 렌즈 보안 절에는 이 매트릭스가 없다**(GENSEC01~06은 엔드포인트·응답 검증·이벤트 모니터링·프롬프트 보안·과도한 대행·데이터 중독). 렌즈에서 찾으면 못 찾는다.

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

### G-13 ✅ 저작 선결 — 전부 완료 (2026-11-05)

착수 시점의 작업 항목 목록이었고 **다섯 항목이 모두 닫혔다.** 아래는 무엇이 그것을 닫았는지의 기록이다.

| 선결 | 상태 |
|---|---|
| `pubspec.yaml`에 `- assets/content/aif/` 등록 | ✅ 도메인 1 배치에서 완료(pubspec은 디렉터리를 개별 등록한다 — MLA에서 확인된 레시피 정정) |
| 새 자격증 전용 포맷 가드 `test/aif_doc_format_test.dart` | ✅ 도메인 1 배치에서 신설 — `content_enrichment_test`는 **명시 허용 목록**(clf 19 · saa 24 · soa 20)이라 신규 자격증을 강제하지 않는다 |
| `content_index.dart` 14줄 등재 | ✅ 배치마다 누적해 14/14 완료(`questionCount`는 문항 flip 전까지 **0**) |
| `kExamReadinessRequirements`에 AIF 정책 | ✅ **Phase 3 선결 셋에서 완료** — `{1: 20, 2: 24, 3: 28, 4: 14, 5: 14}`, 65문항 배분 **13·16·18·9·9** |
| `flipAllowlist` + Dart 허용 목록 가드 | ✅ **Phase 3 선결 셋에서 완료** — `review.mjs`의 `CERTS.aif.flipAllowlist` + `aif_questions_test.dart`의 `flipApprovedTaskIds` |

⚠️ **왜 「정책 없는 cert는 fail closed」가 선결이었나**는 기록해 둔다 — 정책이 없으면 `hasPolicy:false → ready:false`라 **사람이 전 문항을 flip해도 모의고사가 영원히 잠긴다**(MLA가 #246, SOA·DEA가 #254 전까지 그랬다). 같은 이유로 **허용 목록이 없으면 사람의 첫 flip이 「전 문항 드래프트」 단정에서 레드로 끝난다**(SOA·DEA가 #285에서 겪었다).

⚠️ **선결 함정이 이 목록보다 둘 더 있었다** — 둘 다 `tool/review.test.mjs`다: 하드코딩 자격증 목록과 **「등록된 자격증은 문항 파일이 있어야 한다」** 단정(저작 전 등록이 전제에 없었다 → `preAuthoring` 명시 집합으로 갈랐다). **문항을 넣을 때 그 집합에서 `aif`를 지워야 한다.** 경위는 HANDOFF §0-2026-11-05.

⚠️ **`verified:true` flip은 사람만** 한다. 문항은 전부 드래프트로 저작하고, flip은 `node tool/review.mjs flip aif <taskId>`가 허용 목록 추가까지 대신 해 준다.

## 출처

| 제목 | URL | 조회일 |
|---|---|---|
| AWS Certified AI Practitioner (인증 페이지) | https://aws.amazon.com/certification/certified-ai-practitioner/ | 2026-11-03 |
| 시험 가이드 본문·도메인·범위·개정 | [00-overview.md](00-overview.md) §8의 URL 9건 | 2026-11-03 |

---

## 도메인 1 문항 저작에서 새로 드러난 것 (2026-11-05, 컨트롤러 직접 실측)

### G-30 ⚠️ 측정 도구의 결함 — `curl`에 `-L`이 없으면 `num_redirects`는 **항상 0**이다

위임 지시문이 `curl -s -o /dev/null -w "%{http_code} %{num_redirects} ..."`를 「리다이렉트 실측」 명령으로 줬는데 **그 형태로는 아무것도 잴 수 없다.** `-L`이 없으면 curl이 리다이렉트를 따라가지 않아 `num_redirects`가 0으로 고정된다.

- **실측 대조군:** 일부러 틀린 슬러그 `sagemaker/latest/dg/zz-bogus-control.html` → `-L` 없이 **`302 redirects=0`** / `-L` 있으면 **`200 redirects=1`**(가이드 인덱스 도착).
- 즉 **`-L` 없이 쓸 때의 판정 신호는 상태 코드**(200 존재 / 302 부재)이고, **`num_redirects`를 쓰려면 `-sL`이 필수**다.
- ⚠️ **저작 에이전트 셋이 모두 스스로 이 결함을 찾아 재측정했다**(각자 대조군까지 세웠다). 그래도 **컨트롤러가 43개 URL을 전부 다시 쟀다** — 보고는 데이터이고 검증이 아니다. 결과: t1-1 12 · t1-2 16 · t1-3 12 + 공통 3, 고유 **43개 전부 200 · redirects 0**.
- 다음 배치 지시문과 자체 점검기의 출력에서 고쳤다. **CLAUDE.md·메모리의 「판정 신호는 상태 코드가 아니라 `num_redirects`」도 `-L` 전제가 붙는다.**

### G-31 ⚠️ 결정 가이드가 2026-07-23 갱신으로 과금 서술을 바꿨다 (✅ md 정정)

`decision-guides/.../bedrock-or-sagemaker.html`이 이제 이렇게 적는다 — **"SageMaker AI offers per-token pricing for serverless model customization, providing the same pricing simplicity as Amazon Bedrock."** 그리고 **"For managed training jobs, inference, and HyperPod, SageMaker AI follows usage-based pricing for compute resources, storage, and other services..."**

- `aif-t1-3.md`가 SageMaker AI 과금을 **「컴퓨팅 리소스 사용량 기준」으로만** 적어 **서버리스 커스터마이징이 토큰당이라는 것을 가르치지 못했다.** 비교 표·흔한 함정·자가 점검 정답 **세 자리**를 고쳤다(가드 `aif_facts_test.dart`).
- 같은 갱신으로 바뀐 다른 자리: Bedrock 과금에 **Priority · Flex · Reserved 서비스 계층**이 추가됐고, 필요 전문성 칸이 SageMaker AI 쪽에서 **"Guided UI and AI agent-assisted workflows simplify customization"**으로 완화됐다(md의 "고급 훈련 작업에는 더 깊은 전문성"은 여전히 맞다).
- 저작 에이전트는 이 자리를 **피해서** 문항을 썼다(공식과 md가 갈리는 지점을 출제하지 않는 것이 옳은 처리다). 문서를 먼저 고치는 것이 루브릭 T6다.

### G-32 ⚠️ Autopilot 기본 목표 지표의 정본은 개발자 안내서가 아니라 **API 참조**다 (✅ md 정정)

`aif-t1-3.md`가 「이진 분류 기본값 `F1` · 다중 클래스 기본값 `Accuracy`」의 근거로 `sagemaker/latest/dg/autopilot-metrics-validation.html`을 걸고 있었는데, **그 페이지는 그 수치를 적지 않는다** — "Autopilot uses the default validation metric for each problem type that it handles, unless you specify otherwise"까지만 적고 지표 목록으로 링크한다(전문 실측).

- **정본은 `sagemaker/latest/APIReference/API_AutoMLJobObjective.html`**이고 거기에 **"Default objective metrics: ... Binary classification: F1"**, 다중 클래스 **"Accuracy"**, **"Regression: MSE"**가 직접 적혀 있다. 출처를 교체했다(주장 자체는 옳았다).
- ⚠️ **`sagemaker/latest/dg/autopilot-metrics.html`은 죽은 슬러그다**(redirects 1 → `sagemaker/latest/dg/`). 그쪽으로 교체하면 안 된다.
- ⚠️ **저작 에이전트 보고 1건은 거짓이었다** — "md의 `o = 3*i + 4` 예시를 현재 `what-is/machine-learning/`에서 찾지 못했다"고 왔지만 **실측하면 그 페이지에 그대로 있다**(`(2,10), (5,19), and (9,31)` · `o=3*i+4` · 입력 7 → 25). 에이전트의 본문 추출이 놓친 것이다. **보고된 「없음」은 「못 찾음」일 수 있다 — 대조군 없이 삭제·정정하면 옳은 문장을 지운다.**

### G-33 ⚠️ 공식 표기 내부 어긋남이 백서뿐 아니라 **ML 렌즈**에도 있다

`MLCOST02-BP01`이 **`SageMaker AI JumpStart`**로 적는다(2건 / `SageMaker JumpStart` 0건 — 실측). 조사 노트 95 §3.6의 판정(**개명은 기능 이름에 적용되지 않는다 → `SageMaker JumpStart`가 맞다**)과 어긋난다.

- 처리: **「무엇이 맞는 표기인가」를 묻는 문항을 만들지 않는다.** 공식 내부가 갈리는 지점 위에 정답을 세우게 된다. 저작 에이전트가 그 대신 **SageMaker AI의 성격**(모델을 직접 만드는 쪽 ↔ 사전 훈련 기능을 호출하는 쪽)을 묻는 쪽으로 돌렸다.

### G-34 ℹ️ `bedrock/latest/userguide/knowledge-base.html`이 재구성됐다 (md 보강 후보)

지금 이 페이지는 지식 기반을 **두 종류**(`Managed Knowledge Base` / `Customer-managed Knowledge Base`)로 가르고 상단에 "For optimized retrieval accuracy and a managed experience, we recommend Amazon Bedrock Managed Knowledge Base"라는 Important 블록을 둔다. `aif-t1-2.md` §4는 단일한 2단계 흐름만 적는다 — **틀린 것은 아니지만 더 이상 전부가 아니다.**

- 문항(`aif-t1-2-q9`)은 **두 종류와 무관하게 참인 사실**(RAG 정의 · 인용 · 청크→임베딩→벡터 DB)로만 썼다.
- ⚠️ 같은 계열로 `rag-fully-managed-bedrock.html`에 **지식 기반을 Bedrock agent에 붙이는 문장**이 있다(D-07에서 정답 보기 금지로 묶은 Agents Classic 계열) — 그 문장은 인용하지 않았다.

### G-35 ℹ️ 드리프트 두 종류를 한 문장에 적는 정본은 `MLSUS06-BP02`다

`MLPERF06-BP03`은 **데이터 드리프트만** 정의한다. 두 정의를 함께 적는 것은 `MLSUS06-BP02` — "you can detect both **concept drift (changes in the relationship between input and output variables)** and **data drift (changes in the distribution of input data)**". `aif-t1-3.md`는 둘을 다 출처로 들고 있어 **모순은 아니고 귀속 문제**다(§5 서술이 어느 쪽에서 왔는지 모호하다).

### G-36 ℹ️ `prescriptive-guidance/latest/ml-operations-planning/`에 성숙도 모델 페이지가 없다

가이드 목차는 `introduction`·`data`·`training`·`deployment`·`monitoring` 다섯뿐이다(추측 슬러그 3종 전부 redirects 1). MLOps **성숙도 레벨 0·1·2의 정본은 `aws.amazon.com/what-is/mlops/`**다 — `aif-t1-3-q10`을 그쪽으로 달았다.

---

## 도메인 2 문항 저작에서 새로 드러난 것 (2026-11-05, 컨트롤러 직접 실측)

### G-37 ⚠️⚠️ G-19의 「PT 필수」 오류가 라이브 `aif-t2-3.md`에 **다섯 자리** 남아 있었다 (✅ 정정)

G-19(2026-11-03)가 "사용자 지정 모델은 프로비저닝 처리량 없이 못 쓴다"를 과도한 일반화로 판정하고 `aif-t3-3`의 세 곳을 고쳤는데, **`aif-t2-3.md`는 라이브인 채로 남았다**(그 뒤 G-22 작업에서 같은 파일의 「차원 8개」만 고쳤다). 조사 노트 `96-fm-cost-eval-guardrails.md` §3에도 한 줄 남아 있었다.

- **공식**(`bedrock/latest/userguide/model-customization-use.html`, 실측 redirects 0): 설정이 **둘**이다 — ① "Purchase Provisioned Throughput" ② "Deploy custom model for on-demand inference ... With on-demand inference, **you only pay for what you use and you don't need to set up provisioned compute resources**."
- 고친 자리 **다섯**: 시험 직전 요약 · 용어 표 · §4 「서빙 비용」 · §4 「숨은 비용」 · 흔한 함정 · 자가 점검 Q2 정답(**「불가능합니다」 → 「가능합니다」**). 가드는 `aif_facts_test.dart`.
- ⚠️ **저작 에이전트는 네 자리로 보고했고 실제로는 다섯이었다** — 용어 표의 "사용자 지정 모델에는 **필수**입니다"를 놓쳤다. **보고의 개수를 그대로 믿지 않고 `grep`으로 전수 센 것이 이것을 잡았다.**
- ⚠️ **노트를 고치지 않으면 다음 배치가 같은 오류를 다시 쓴다** — G-19가 적어 둔 그 문장이 바로 이 사례로 증명됐다. 정정은 **md와 조사 노트 양쪽**에 한다.

⚠️⚠️ **추가(2026-11-05, 도메인 3 착수 직전 전역 `grep`): 같은 오류가 `aif-t2-1.md`에도 한 줄 있었다** — 「시험 직전 요약」의 "비용 문항은 조합의 가능 여부를 묻습니다 — … 사용자 지정 모델은 **PT 필수**". **저작 에이전트 보고에는 없던 자리**이고, t2-3을 고친 뒤 **레포 전역을 다시 쓸어서** 찾았다.

- 그래서 가드를 **한 파일이 아니라 `assets/content/aif` 전수 집계형**으로 바꿨다(`aif_facts_test.dart` — 대상 14편을 대조군으로 먼저 단정한다). 금지 문구는 `PT 필수` · `프로비저닝 처리량 없이 쓸 수 없` · `프로비저닝 처리량을 구매해야 한다` 셋이다.
- **교훈: 한 파일에서 오류를 찾으면 그 문구로 레포 전역을 쓸고, 가드도 전역으로 건다.** 같은 판정이 한 번 내려졌는데 다른 파일에 남는 일이 G-19 → G-37에서 두 번 반복됐다.
- 같은 사통으로 **표기 회귀 한 건**도 잡았다 — `aif-t2-2.md`가 「계속 사전 훈련」을 용어 자체로 쓰고 있었다(D-09·G-20의 정본은 「지속적인 사전 훈련」). ⚠️ 다만 `aif-t3-3.md` 용어 표의 "「계속 사전 훈련」으로도 번역됩니다"는 **의도된 병기**라 0건이 아니라 **그 한 곳만**으로 고정했다.
- 함께 쓸어 본 다른 위험 단정 셋은 **전부 올바르게 처리돼 있었다**(실측): 책임 있는 AI 차원 **8/10 분기 명시**(G-22) · Guardrails 유해 범주 수 단정 **0건**(G-23) · 생성형 AI 수명 주기 **단계 수 경고 존재**(G-17. ⚠️ `aif-t1-3.md`의 "공식 수명 주기는 6단계"는 **Well-Architected ML 렌즈의 ML 수명 주기**로 G-17의 GenAI 수명 주기와 **다른 대상**이다 — 오류가 아니다).

### G-38 ⚠️ 측정 신호가 도메인마다 다르다 — `aws.amazon.com`은 없는 슬러그에 **진짜 404**를 준다

G-30이 `docs.aws.amazon.com`에서 "없는 페이지도 200 + redirects 1"임을 적었는데, **`aws.amazon.com`(마케팅·개념 페이지)은 다르다** — 없는 슬러그에 `404 redirects=0`을 준다(저작 에이전트 실측: `aws.amazon.com/what-is/zz-bogus-control/` → 404).

- 따라서 판정 규칙이 둘이다: **`docs.aws.amazon.com`은 `redirects`로**, **`aws.amazon.com`은 상태 코드로** 본다. 둘 다 `-sL`로 재야 한다.
- **대조군을 도메인별로 하나씩** 넣는 것이 옳다(한 도메인의 대조군만으로 다른 도메인의 측정을 보증하지 못한다).

### G-39 ⚠️ 은퇴 URL 1건 — `bedrock/latest/userguide/model-evaluation.html` (도메인 3 배치의 함정)

실측하면 `200 redirects=1`로 Bedrock 사용자 가이드 인덱스로 간다. **정본은 `bedrock/latest/userguide/evaluation.html`**("Evaluate the performance of Amazon Bedrock resources", redirects 0).

- 도메인 2에서는 평가 세부가 **3.4 소관**이라 인용하지 않았다. ⚠️ **도메인 3 배치(`aif-t3-4` 성능 평가)에서 옛 슬러그를 쓰면 출처가 엉뚱한 페이지를 가리킨다.** 레포에 현재 0건이다(실측).

### G-40 ⚠️ `what-is-bedrock.html`이 Quickstart 페이지로 재구성됐다 (md 귀속 보강 후보)

`aif-t2-3.md`가 그 페이지에 귀속시킨 두 표현이 **더 이상 거기 없다** — 「모델 독립적인 단일 API 접근」·「서버리스이므로 인프라를 관리하지 않아도 된다」.

- **두 방법 + 대조군으로 확인했다**(컨트롤러 재실측): 태그 제거 본문과 **원문 HTML 양쪽에서** `serverless` 0 · `single API` 0 · `model-independent` 0이고, 같은 페이지에 실재하는 `fully managed service`는 1/1로 잡힌다. **추출 실패가 아니라 그 표현이 없다.**
- **현행 정본**(둘 다 이미 이 문서의 출처 목록에 있다): 「서버리스」는 `decision-guides/.../bedrock-or-sagemaker.html`("Amazon Bedrock is serverless, meaning you do not have to manage infrastructure") · 「모델 독립적인 단일 API」는 `decision-guides/.../genai-guide.html`("model-independent, single API access"). `what-is-bedrock.html`의 **「완전관리형」 정의는 여전히 유효**하다.
- 저작 에이전트는 이 Task의 출처 15개에 `what-is-bedrock.html`을 **넣지 않았다**(그 대신 결정 가이드를 달았다).

### G-41 ℹ️ md가 덮지 않아 **출제하지 않은** 공식 사실들 (보강 후보, 금지 가드는 걸지 않는다)

전부 공식에 실재하지만 학습문서가 적지 않아, **문서만 보고는 풀 수 없으므로** 문항으로 만들지 않았다. ⚠️ **금지 가드를 걸지 않는다** — md에 들어오면 옳은 문장이 막힌다.

- **`what-is/generative-ai`의 한계 목록은 넷이다**(Security · **Creativity** · Cost · Explainability). `aif-t2-2.md`는 비용·설명 가능성만 적는다. Creativity는 "훈련 데이터에 제한되어 반복적·파생적 출력이 나올 수 있다".
- **`AGENTPERF03-BP02`의 안티패턴은 5개**다(`aif-t2-1.md` §7과 노트 96은 4개로 열거). 다섯째는 "버전 관리·나란히 비교 없이 프롬프트 변경을 내보내 롤아웃 뒤에야 품질·토큰 비용 회귀가 드러나는 것".
- **프롬프트 캐싱 TTL이 5분만은 아니다** — 같은 페이지가 "5-minute default TTL, or a **1-hour TTL** on Claude Opus 4.5, Haiku 4.5, and Sonnet 4.5"를 적는다.
- **명시적 캐싱에 서버 지역성 제약이 있다** — 캐시 항목은 그 요청을 처리한 서버에 저장되고 다른 서버(예: 다른 리전)가 처리하면 **읽지 않고 새로 쓴다.** md는 "히트는 보장되지 않는다"까지만 적는다.
- **「반환 결과 수가 요청보다 적을 수 있다」는 계층형 청킹 전용이 아니다** — `kb-chunking.html`의 `Tables and figures in parsed content` 절이 **최대 토큰 한도를 두는 모든 전략**에 적용한다(「청킹 없음」 제외, 10,000자 이하). `aif-t2-1.md` §1은 계층형에만 귀속한다.
- **결정 가이드의 「필요 전문성」 칸이 완화됐다**(G-31 계열) — SageMaker AI 쪽이 "**Guided UI and AI agent-assisted workflows simplify customization**; deeper ML expertise helpful for advanced training jobs"이고 본문은 서버리스 커스터마이징에 "**require no ML expertise**"까지 적는다. `aif-t2-3.md`는 뒷절만 적어 **틀리지는 않았지만 절반이다.**
- **`what-is/large-language-model/`이 코드 생성 예시로 은퇴 제품명 `Amazon CodeWhisperer`를 든다** — 그 문장은 인용하지 않는다.

### G-42 ℹ️ 「없다」 보고 1건이 **낱말 차이**였다 (G-32의 반대 사례)

저작 에이전트가 블로그 원문에서 `attenuat*`를 두 방법으로 0건 확인했는데, **같은 사실이 `decays`라는 낱말로 그 페이지에 실재한다** — "the effectiveness of inferences **decays** as the amount of context increases". 즉 **낱말이 없고 사실은 있었다.** `aif-t2-1.md`의 「추론의 효과가 감쇠」 번역은 옳다.

- G-32(보고된 「없음」이 「못 찾음」이었던 사례)와 짝이 되는 교훈이다: **「없다」를 보고할 때는 ① 추출 방법 둘 ② 대조군 ③ 같은 사실의 다른 표현까지 찾아본 결과를 함께 적는다.**

---

## 도메인 3 문항 저작에서 새로 드러난 것 (2026-11-05, 컨트롤러 직접 실측)

이 배치에서 **라이브 학습문서의 출처가 죽거나 그 사실을 더 이상 담지 않는 경우가 다섯 건** 나왔다. 문항 60개는 네 Task 모두 이 영역을 **피해서** 썼고(전수 0건 확인), 그중 **둘은 이 PR에서 고쳤다.**

### G-43 ⚠️⚠️ `AWS CAF for AI` 가이드가 **통째로 은퇴했다** (라이브 `aif-t3-3.md` 2곳 — 부분 처리)

`whitepapers/latest/aws-caf-for-ai/` 아래 **모든** 슬러그가 `200 redirects=1`로 Well-Architected 머신 러닝 렌즈 인덱스로 간다.

- ⚠️ **대조군이 판정을 바꿨다** — 일부러 틀린 슬러그(`aws-caf-for-ai/zz-bogus-control.html`)도 **같은 곳으로 간다.** 즉 **페이지 이름 변경이 아니라 가이드 자체의 소멸**이다(대조군이 없으면 "리다이렉트 도착지로 교체하면 된다"고 잘못 판단한다).
- 그 리다이렉트 도착지(ML 렌즈 인덱스, 5.5K자)에는 **md가 인용하는 문장이 없다**(실측: `acquire, label` 0 · `cleanse` 0 · `data catalog` 0 · `last 1%` 0 / 대조군 `governance` 1). 대안 슬러그 `aws-caf-for-artificial-intelligence/`는 **404**다.
- 영향 범위: **`aif-t3-3.md`에만 4줄**(프런트매터 `sources` 2 + 참고자료 2). 레포 전역 `grep`으로 다른 자격증 콘텐츠에는 **0건** 확인.
- 그 두 출처가 §5 **① 데이터 큐레이션**·**② 거버넌스**의 인용 문장을 받치고 있어, **URL 교체만으로는 닫히지 않는다**(인용 문장의 새 집을 찾거나 서술을 줄여야 한다).
- **이 PR에서 한 것:** 참고자료 18·19에 **은퇴 사실과 근거를 명시**하고, 살아 있는 인접 출처(`MLSEC03-BP04` 데이터 계보 · `model-customization-submit.html` KMS 키·VPC, 둘 다 실측 `200`·0)를 적어 후속 작업을 돕게 했다. 죽은 링크를 아무 표시 없이 두면 학습자가 그 페이지를 찾으러 간다.
- **후속 과제:** §5 ①·② 인용 문장의 대체 출처 확정 또는 서술 축소. 가드는 "은퇴 경고가 붙어 있다"까지만 고정한다.

### G-44 ⚠️⚠️ AgentCore **내장 평가자의 개수(13개)와 ID 이름이 공식에서 사라졌다** (✅ md 정정)

`bedrock-agentcore/latest/devguide/built-in-evaluators-overview.html`은 살아 있지만(`200`·0) **목록을 싣지 않는 1,521자 소개 문서로 재구성**됐다.

- **「없다」의 셋**(G-42 규율): ① 추출 둘 — 원문 HTML의 `Builtin\.[A-Za-z]+`와 태그 제거 본문 양쪽에서 `GoalSuccessRate`·`ToolSelectionAccuracy`·`ToolParameterAccuracy` **0건** ② 대조군 — 같은 추출이 `Builtin.Helpfulness`(개요)와 **새 갈래** `Builtin.SkillSelectionAccuracy`·`Builtin.SkillInstructionFollowing`(`skill-evaluators.html`)을 잡아낸다 ③ 다른 표현 — **개념은 살아 있다**(`how-it-works-evaluations.html`의 "end-to-end task completion (**goal attainment**) correctness" · "the accuracy of a **tool invoked**" · "any **custom metric**", `omni-agents-evaluators.html`의 **trace·session·tool call** 세 수준).
- **이 PR에서 한 것:** `aif-t3-4.md` §4의 **13개 선언과 ID 표를 지우고** 공식이 현재 적는 **세 축**(목표 달성 정확성 · 호출한 도구의 정확성 · 사용자 지정 지표)으로 바꿨다. 세 수준과 텔레메트리 주의는 **그대로 유효**하다(실측). 「작업 완료율」 절과 흔한 함정의 `GoalSuccessRate` 인용 2곳도 함께 걷어냈다.
- ⚠️ **공식 내부가 갈린다** — `evaluators.html`은 내장 평가자가 "**use LLMs as judges**"라고 적는데 `omni-agents-evaluators.html`은 **일부는 심사 모델, 일부는 규칙 기반**이라고 적는다. **"내장 평가자가 전부 심사 모델인가"를 묻는 문항을 만들지 않는다**(G-22 계열).
- ⚠️ AIF는 **Foundational** 시험이라 평가자 ID 이름은 애초에 출제 수준이 아니다 — 축만 쥔다.

### G-45 ⚠️ `custom-models.html` 재구성 — **지속적인 사전 훈련이 그 페이지에서 빠졌다**

현재 그 페이지가 적는 사용자 지정 방법은 **세 가지**다(`Supervised fine-tuning` · `Reinforcement fine-tuning` · `Distillation`). `aif-t3-3.md`는 이 페이지를 미세 조정·지속적 사전 훈련의 근거로 걸고 있다.

- **CPT의 살아 있는 정본**: 콘솔 도움말 `help-panel/bedrock/latest/console/hp-custom-models-create-continued-pre-training-job.html`(md가 이미 출처 8로 들고 있다)과 **boto3 `customizationType` 유효값**(`FINE_TUNING | CONTINUED_PRE_TRAINING | DISTILLATION | REINFORCEMENT_FINE_TUNING | IMPORTED`).
- ⚠️ 사용자 가이드 쪽 CPT·미세 조정 **전용 슬러그 8종이 전부 죽었다**(`continued-pretraining` · `model-customization-cpt` · `custom-models-continued-pre-training` · `fine-tuning` · `custom-models-fine-tuning` · `model-customization` · `distillation-prereq` · `model-distillation-prereq`).
- 같은 재구성으로 **새로 생긴 사실**: 훈련 요금이 "처리된 토큰 수(코퍼스 토큰 × 에폭) + 월별 모델 스토리지"로 적힌다(md에 없어 출제하지 않았다).

### G-46 ⚠️ 공식 내부 모순 — `hp-custom-models.html`에 **「PT 필수」 옛 문장이 아직 살아 있다**

콘솔 도움말이 지금도 *"To run inference using a custom model (including copied models), you need to purchase Provisioned Throughput for it."*로 적는 반면, `model-customization-use.html`은 선택지를 **둘**로 적는다(G-37). **더 구체적인 쪽(설정 페이지)을 정본으로** 쓰고, 콘솔 도움말의 그 문장은 **출처로 쓰지 않는다.**

- ⚠️ 이것이 G-19 → G-37 → 이 배치까지 **같은 오류가 세 번 새어 나온 이유**다: 공식 자신이 두 가지로 적는다. 그래서 레포 가드를 **문구 전수 금지**로 걸었다(`aif_facts_test.dart`).

### G-47 ℹ️ 벡터 저장소·지식 기반 쪽 보강 후보 (md 수정 안 함)

- **`bedrock/latest/userguide/knowledge-base.html` 재구성**(G-34 확인) — `aif-t3-1.md` §3이 귀속시킨 「수집부터 검색과 프롬프트 증강까지 RAG 워크플로 전체를 구현하는 완전 관리형 기능」 문구가 **현행 페이지에 없다**(두 방법 + 대조군 `Managed Knowledge Base` 1/1로 확인). 현행은 RAG 정의 한 문장과 **Managed / Customer-managed 두 유형** 서술이다.
- **`docs.aws.amazon.com/vector-databases/`의 H1이 다르다** — 실제 제목은 **「Choosing a database for your generative AI applications」**다(md 참고자료 10번은 「Vector databases on AWS」로만 적는다).
- **그 페이지의 서비스 목록이 md보다 넓다** — `Amazon MemoryDB` · `Amazon DocumentDB` · `Amazon DynamoDB`(`SearchVectors` API로 네이티브 벡터 인덱스)도 절 제목으로 싣는다. ⚠️ 다만 **공식 목표 3.1.4의 예시 목록에는 없으므로 문항에는 쓰지 않는다**(D-08 운영).
- ⭐ **MemoryDB 갈림길의 더 좋은 정본을 찾았다** — 95 §5는 `StorageConfiguration` 유효값으로 갈랐는데, **그 의사 결정 가이드 비교 표에 「Amazon Bedrock Knowledge Bases」 열이 있고 MemoryDB 행이 `No`**다. 한 페이지가 "벡터 검색은 있다 + KB 저장소는 아니다"를 **동시에** 적는다.

### G-48 ℹ️ 작은 정밀화 여섯 (전부 문항에 쓰지 않았다)

- **「싱글샷 = 예시 1개」를 못박는 문장은 공식 docs에 없다** — `prompt-engineering-guidelines.html`은 제로샷·퓨샷만 가르고, 처방적 지침은 `one-shot or few-shot`을 **묶어** "하나 이상의 예시"로 적는다. 1개 = 싱글샷은 **공식 시험 가이드가 둘을 따로 드는 것 + 명칭의 산술**에서 나온다.
- **간접 프롬프트 인젝션의 「외부 소스에 심는다」 서술은 보안 백서가 아니라 블로그 쪽**이다(백서 본문은 "seemingly benign user inputs"까지).
- **FAQ의 "significantly fewer labeled training records" 문장은 `Amazon Titan` 기본 모델 한정**이다(md는 일반 기본 모델로 패러프레이즈한다).
- **증류 교사·학생 전제 조건 페이지를 찾지 못했다** — 노트 96 `[5]`가 가리키는 "지원 조합 표에서 짝지어진 모델"의 정본 슬러그 둘이 죽었다. 살아 있는 정의 문장("larger more intelligent model (teacher) → smaller, faster, cost-efficient model (student)")만 쓴다.
- **`aws.amazon.com/what-is/agentic-ai/`에 오타가 있다** — 코드 전환 절 첫 문장이 `Agentc AI`다(인용 금지).
- **`lifecycle.html`은 `continuous` pre-training으로 적는다**(`continued`가 아니다). 사실은 같아 md 정정 사안은 아니고, **본문 표기는 D-09대로 「지속적인 사전 훈련」**만 쓴다.

## 도메인 4·5 문항 저작 (2026-11-06)

### G-49 ⚠️⚠️ 「없다」 규율 3부를 다 해도 **표 구조로 표현된 사실**은 못 잡는다

이 배치에서 에이전트 보고 중 **「공식에 없다」가 네 건이었고 그중 두 건이 거짓**이었다. 둘 다 추출 둘·대조군·다른 표현을 **규율대로 적용한 뒤에** 나온 오판이라, 규율의 구멍 자체가 드러났다.

- **① `glue-data-quality.html`의 진입점별 지원 차이** — `aif-t5-1.md`가 "실패한 레코드 식별은 ETL 쪽만, 규칙 추천은 Data Catalog 쪽만"으로 적고, 에이전트는 `failed record`·`records that failed`·`filter out`을 본문·원시 HTML 양쪽에서 0건으로 보고했다(대조군 `DeeQu`는 2건이라 추출은 작동했다). 그런데 **컨트롤러 실측은 `records that failed`를 1건**으로 셌고, 그 자리는 **Data Catalog 열과 ETL 열을 가진 비교 표**였다:

  ```
  Data Quality rule recommendations            Supported      Not supported
  Identifying records that failed … checks     Not supported  Supported
  ```

  **md가 옳다.** 산문 문구로는 "ETL 쪽만"이 어디에도 없고 사실이 **표의 열 구조**에 들어 있어, 문구 검색은 영원히 0건이다. ⚠️ **보고를 믿고 md를 고쳤다면 참인 문장을 지웠을 자리다.**

- **② 안전 조치 계층의 기본값** — `aif-t4-1.md`가 **"If you don't specify a tier, your guardrail uses Classic tier."**를 영문으로 직접 인용하는데, 에이전트는 `If you do not`·`defaults to`·`Classic tier is` 세 탐침으로 0건을 얻고 "근거 없음"으로 보고했다. **그 문장은 에이전트가 찾아본 바로 그 페이지**(`guardrails-contextual-grounding-check.html`)에 **글자 그대로** 있다 — 실제 문구가 `If you don't specify a tier`여서 탐침 셋이 모두 빗나갔다.

  ⚠️ **md가 영문을 직접 인용하고 있으면 그 인용문 자체로 먼저 검색한다.** 패러프레이즈한 탐침부터 쓰면 「없다」가 쉽게 거짓이 된다.
  ⚠️ 함께 확인한 것: API 참조의 `tierName`은 **`Required: Yes`**(유효값 `CLASSIC | STANDARD`)인데 위 문장과 **모순이 아니다** — 필수인 것은 `TierConfig` **안쪽** 필드이고 그 객체를 통째로 빼면 Classic이 된다. 한쪽만 보고 "미지정 상태는 없다"로 결론 내리면 틀린다(컨트롤러가 한 번 그렇게 결론 내렸다가 더 찾아 바로잡았다).

→ **처리:** 둘 다 **보존 가드**로 고정했다(`aif_facts_test.dart`의 「표에만 있는 참인 사실을 지우지 않는다」 그룹). **금지 가드가 아니라 보존 가드**라는 점이 중요하다 — 앞으로의 거짓 「없다」가 참인 문장을 지우는 것을 막는다.

### G-50 ⚠️ `docs.aws.amazon.com`의 판정 신호는 **세 갈래**다 (G-38 보강)

기록된 규칙은 "없는 페이지에도 404를 주지 않으니 `num_redirects`로 판정한다"였는데, 실측하면 그것은 **포함 가이드가 실재할 때만** 맞다.

| 경우 | 신호 | 실측 예 |
|---|---|---|
| 살아 있는 페이지 | `200 r=0` | `bedrock/…/guardrails.html` |
| **있는 가이드 안**의 없는 슬러그 | `200 r=1`(그 가이드 인덱스로) | `sagemaker/latest/dg/zz-bogus-control.html` → `…/dg/` |
| **가이드·접두사 자체가 없음** | **진짜 `404 r=0`** | `zz-bogus-guide/latest/dg/zz-bogus.html` · `ai/responsible-ai/zz-bogus-card/overview.html` |
| 제공되지 않는 디렉터리 인덱스 | **`403`** + AWS 오류 페이지 | `ai/responsible-ai/` |

⚠️ **그래서 상태 코드와 `num_redirects`를 함께 본다**(`200 r=0`만 통과). `-sL`은 여전히 필수다(G-30).
⚠️ **403이 봇 차단인지 실제 미제공인지는 상태 코드로 갈라지지 않는다** — `repost.aws`의 403은 **봇 차단**이었다(SOA·DEA 출처 감사). 그래서 이번에는 **내장 브라우저로 직접 열어** AWS의 "the web address you entered is not a functioning page on our site" 오류 페이지를 확인했다.

### G-51 ⚠️ `docs.aws.amazon.com/ai/responsible-ai/`는 **목록 페이지가 아니다** (✅ md 정정)

라이브 `aif-t4-1.md`가 학습자에게 그 접두사를 "아래에 모델·서비스별로 게시된다"고 안내하고 있었다. **개별 카드는 전부 `200 r=0`**인데(`nova-2-lite/overview.html` 등) **접두사 자체는 403**이다(G-50). 카드 형태(`…/<모델·서비스>/overview.html`)를 적고 **그 경로를 목록으로 열 수 없다는 경고**를 넣었다. G-26의 "카드 총 개수·전체 목록을 단정하지 않는다"와 같은 계열이고, 이제 그 **이유**가 문서에 적혀 있다.

### G-52 ⚠️ `RAIBR02`·`RAIRC03`은 **「차원 하나당 모범 사례 하나」가 아니다** (✅ md 정정)

라이브 `aif-t4-1.md`가 그렇게 단정하고 있었다. 컨트롤러 직접 실측(2026-11-06):

- **`raibr02.html`** — `BP01`~`BP09`. 차원별은 **`BP01`~`BP08` 여덟 개**(공정성·진실성·견고성·프라이버시·**시스템과 데이터 보안**·설명 가능성·투명성 + 안전성)이고 **`BP09 Choose multiple strategies to identify potential harmful events`는 차원이 아닌 교차 전략**이다.
- **`rairc03.html`** — `BP01`~`BP05`·**`BP07`~`BP10`**. **아홉 항목이고 `BP06`이 번호에서 빈다**(공식 목록 자체의 공백이라 「어느 쪽이 정본이냐」를 고를 성격이 아니다).

⚠️ **그래서 「모범 사례가 몇 개인가」류 문항은 양쪽에서 성립하지 않는다** — 차원 개수를 묻지 않는 판정(G-22)이 **모범 사례 개수까지 확장된다.**
⭐ **md의 다른 세 주장은 참이었다** — "프라이버시·보안과 진실성·견고성이 갈려 있다"(10개 분해의 증거) · "유해 사건에는 제어 가능성·거버넌스가 없다" · "측정에는 거버넌스가 없다". 마지막 것은 **측정 쪽에 제어 가능성은 있다**는 뜻이고 맞다(`RAIRC03-BP07 Measure user controllability of system behavior`). 거꾸로 읽히지 않게 그 BP 제목을 본문에 넣었다.

### G-53 ⚠️ 태그 접두사의 「예측 불가능」은 공식 문구가 아니다 (✅ md 층 정정)

`guardrails-prompt-attack.html` · `guardrails-use-independent-api.html` · `guardrails-use-converse-api.html` 세 페이지 전부에서 `tagSuffix` · `unpredictable` · `guess` · `random`이 본문·원시 HTML 양쪽 **0건**이고, 대조군 **"If there are no tags, prompt attacks for those use cases will not be filtered"**는 **1건**이다(추출은 작동했다).

`aif-t5-1.md`의 **🧠 원리 블록은 올바른 층**이었는데 **시험 직전 요약과 자가 점검 Q2가 사실처럼** 적고 있었다. 세 자리를 "공식이 적는 것은 여기까지이고, 예측 불가능하게 두라는 것은 이 구조에서 따라오는 **원리**"로 고쳤다.

⚠️ **공식 태그 예시에는 접미사 자리가 실제로 있다** — `amazon-bedrock-guardrails-guardContent_xyz`. 「예측 불가능하게 두라」는 권고가 없을 뿐이다.
✅ 함께 정밀화: 미평가 필드를 공식 경로 표기 그대로 바꿨다 — **`messages[].content[].toolResult`**와 **`toolConfig.tools[].toolSpec`**(md는 `toolSpec`만 적어 상위 경로가 빠져 있었다. 틀린 서술은 아니었다).

### G-54 ⚠️ 공식 내부 어긋남 — `policy.html`의 정책 언어 서열

같은 페이지가 "describe rules in plain English instead of writing formal policy code in **Cedar**"(Cedar를 정식 정책 코드로 전제)와 "Policy in AgentCore **also supports** authoring policies in **Dogwood**"를 함께 적는다. AgentCore 개요 표는 거꾸로 "정책 언어 **Dogwood**, Cedar와 **호환**"이다(G-27). **어느 쪽도 주 언어로 단정하지 않고 「두 언어」로만** 쓴다 — `aif-t5-1`의 문항은 언어를 아예 언급하지 않고 정책 조건 축(주체·도구·리소스·입력 파라미터)만 썼다.

### G-55 ⚠️ 공식 내부 어긋남 — Bedrock 관리 이벤트 목록이 한 페이지 안에서 4와 5로 갈린다

`bedrock/latest/userguide/logging-using-cloudtrail.html`이 두 문장을 싣는다 — `such as`가 붙은 쪽은 `ListAsyncInvokes`를 더해 **5개**, 다른 문장은 **4개**다(`InvokeModel` · `InvokeModelWithResponseStream` · `Converse` · `ConverseStream`). 세 번째 문장이 "logs the remainder of Amazon Bedrock API operations as management events"로 받으므로 **열린 목록**이라 모순은 아니다. **판정: 목록 수를 단정하지 않는다** — `aif-t5-2`의 문항은 `InvokeModel`이 관리 이벤트라는 단일 사실만 쓴다.

### G-56 ℹ️ 보강 후보 — 공동 책임 모델의 **세 번째 묶음**이 md에 없다

공식은 **Inherited Controls · Shared Controls · Customer Specific** 셋을 적고 Customer Specific 예로 "Service and Communications Protection or Zone Security"를 든다. `aif-t5-1.md`는 상속·공유 둘만 적는다. **오류가 아니라 누락**이므로 md를 고치지 않았고, 문항에도 쓰지 않았다(쓰면 학습자가 본 적 없는 묶음이 된다).

### G-57 ℹ️ 미래의 「없다」 함정 — `what-is/explainable-ai/`에 오타가 있다

소제목이 **`Transparency and audibility`**다(`auditability`가 아니다 — AWS 쪽 오타). 본문이 "Internal and external auditors should be able to assess AI models…"라서 `aif-t4-2.md`의 한국어 표기 「투명성과 감사 가능성」은 의도에 맞고 md는 영문을 인용하지 않으므로 **정정 대상이 아니다.** ⚠️ 다만 **영문 제목으로 재검색하면 0건이 나와** 다음 검수에서 「없다」 오판을 부를 자리다.

### G-58 ℹ️ 차원 8/10 분기는 **단순 모순이 아니라 갱신되는 집합**이다 (G-22 보강)

Responsible AI Lens가 직접 적는다 — **"we define Responsible AI using a core set of dimensions that we update over time as AI evolves"**(실측). 그래서 개수를 외우지 않는 판정이 더 단단해진다. md §1 각주에 한 줄 보강할 가치가 있다(선택, 이번에 넣지 않았다).

### G-59 ℹ️ 죽은 슬러그 1건 (레포 0건)

**`glue/latest/dg/data-quality-how-it-works.html`** → `200 r=1`로 가이드 인덱스로 간다. 레포에는 **0건**이라 회귀 가드는 세우지 않았다(G-26과 같은 처리).

### G-60 ℹ️ 범위 내 페이지가 **범위 밖 서비스를 끌고 오는** 자리

`Amazon Macie`의 `what-is` 페이지가 통합 대상으로 **`AWS Security Hub CSPM`**을 싣는다(AIF 공식 범위 **밖**). Macie 문항을 쓸 때 그 문장을 그대로 인용하면 범위 밖 이름이 학습 경로에 들어온다 — `aif-t5-1`은 쓰지 않았다. G-10 목록과 같은 계열의 운영 주의다.
