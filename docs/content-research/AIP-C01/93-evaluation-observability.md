---
생성: 2026-11-14
목적: AIP-C01 깊이 조사 ③ — 평가 · 관찰성 · 문제 해결 (P-03 3/3)
조회일: 2026-11-14
---

# AIP-C01 — 93 평가 · 관찰성 · 문제 해결

> 저작 입력의 정본은 [00-overview.md](00-overview.md) §3 공식 전사이고, 저작 규율은
> [98-authoring-decisions.md](98-authoring-decisions.md), 판정하지 못한 것은
> [99-gaps.md](99-gaps.md)다. 이 노트는 **그 기술들을 쓰려면 알아야 하는 공식 사실의 측정 기록**이다.
> 서비스 상태(닫힘·개명)는 [96-service-status-audit.md](96-service-status-audit.md)가 정본이고,
> RAG·벡터 축은 [95](95-rag-vector-retrieval.md), 에이전틱·MCP·도구 축은
> [94](94-agentic-mcp-tools.md)가 본다.

## 1. 이 축의 범위 — 번호로 센다

| 자리 | 기술 | 수 |
|---|---|---:|
| 작업 5.1 GenAI용 평가 시스템 구현 | 5.1.1 ~ 5.1.9 | 9 |
| 작업 5.2 GenAI 애플리케이션 문제 해결 | 5.2.1 ~ 5.2.5 | 5 |
| 작업 4.3 GenAI 애플리케이션을 위한 모니터링 시스템 구현 | 4.3.1 ~ 4.3.6 | 6 |
| | **합계** | **20** |

⚠️ **98 P-03이 적은 「기술 30개」는 어림이다** — 번호로 세면 **20**이다(이 PR에서 98도 고쳤다).
95의 「20 → 17」과 같은 종류의 정정이고, **착수 지시의 수는 그 자체로 검증 대상**이다.

### 1-1. 노트 사이의 경계 — 이 노트가 직접 소유하는 것은 14개다

| 기술 | 소유 |
|---|---|
| `5.1.5` RAG 평가 · `5.1.6` 검색 품질 테스트 · `5.2.4` 검색 시스템 · `4.3.5` 벡터 저장소 운영 | **95** |
| `5.1.7` 에이전트 성능 · `4.3.4` 도구 성능 | **94** |
| `5.1.1`·`5.1.2`·`5.1.3`·`5.1.4`·`5.1.8`·`5.1.9` · `5.2.1`(진단 쪽)·`5.2.2`·`5.2.3`·`5.2.5` · `4.3.1`·`4.3.2`·`4.3.3`·`4.3.6` | **93**(이 노트) |

## 2. ⚠️⚠️ 평가 기계가 **둘**이고 보는 대상이 다르다

이 축에서 가장 많이 틀릴 자리다. 둘은 이름이 비슷하고 **대상이 다르다.**

| | **Amazon Bedrock Evaluations** | **Amazon Bedrock AgentCore Evaluations** |
|---|---|---|
| 평가 대상 | **모델**과 **지식 베이스**(Bedrock 밖의 모델·RAG 소스도) | **에이전트**(AgentCore Runtime에 호스팅된 것과 **밖에 호스팅된 것 모두**) |
| 입력 | 프롬프트 데이터세트 | **세션·트레이스·스팬**(관찰성 텔레메트리) |
| 대표 지표 | 정확도·강건성·독성 / 판정 모델 내장 지표 | **목표 달성(goal attainment) 정확성 · 호출한 도구의 정확성 · 사용자 지정 지표** |
| 사람 | **작업 팀**으로 사람 평가 작업 | 사람 평가는 별 장치가 아니다(Lens가 **주기적 사람 검토**를 권한다) |

- Lens `AGENTOPS06-BP02`가 역할을 가른다: **AgentCore Evaluations가 지속 평가**(온디맨드=개발 중
  벤치마크 · 온라인=운영 트래픽 샘플링)이고 **Bedrock Evaluations가 모델 수준 평가로 보완**하며
  **주기적 사람 평가가 자동 지표가 놓치는 차원**을 덮는다.
- ⚠️ 섞으면 거짓이 된다 — 「Bedrock Evaluations로 도구 선택 정확도를 잰다」·「AgentCore
  Evaluations로 두 FM의 요약 품질을 비교한다」류는 둘의 대상을 바꿔 놓은 것이다.

## 3. Bedrock Evaluations — 네 종류와 **두 벌의 지표**

### 3-1. 네 종류

`evaluation.html`:

| 종류 | 무엇인가 |
|---|---|
| **프로그래매틱(자동) 모델 평가** | 작업 수행 능력을 빠르게 평가. **내장 데이터세트** 또는 내 프롬프트 데이터세트 |
| **사람 작업자 모델 평가** | 사내 직원 또는 업계 **주제 전문가**가 평점·선호를 준다 |
| **판정 모델(LLM-as-judge) 평가** | **두 번째 LLM**이 응답을 채점하고 **각 응답에 설명을 붙인다** |
| **RAG 평가(LLM 기반)** | 지식 베이스·RAG 소스의 검색·생성 품질(→ **95**가 소유) |

평가 대상이 될 수 있는 모델 유형 여섯: **파운데이션 모델 · Bedrock Marketplace 모델 ·
사용자 지정 FM · 가져온 FM · ⭐ 프롬프트 라우터 · 프로비저닝 처리량을 구매한 모델.**
⭐ **프롬프트 라우터도 평가 대상**이라는 것이 `기술 2.1.4`·`5.1.2`를 잇는다.

### 3-2. 자동 평가 — 작업 유형 **하나**만 고른다

`model-evaluation-tasks.html`: ⚠️ **한 평가 작업에 작업 유형 하나**다.

| 작업 유형 | 지표 | 내장 데이터세트 | 계산되는 지표 |
|---|---|---|---|
| 일반 텍스트 생성 | 정확도 / 강건성 / 독성 | TREX / BOLD·TREX·WikiText2 / RealToxicityPrompts·BOLD | **RWK 점수** / **단어 오류율** / 독성 |
| 텍스트 요약 | 정확도 / 독성 / 강건성 | Gigaword | **BERTScore** / 독성 / **BERTScore와 deltaBERTScore** |
| 질문과 답변 | 정확도 / 강건성 / 독성 | BoolQ·NaturalQuestions·TriviaQA | **NLP-F1** / **F1과 deltaF1** / 독성 |
| 텍스트 분류 | 정확도 / 강건성 | Women's Ecommerce Clothing Reviews | 이진 정확도 / 분류 정확도와 delta |

⭐ **`delta…` 지표는 강건성 축**이다 — 섭동을 준 입력과 원 입력의 점수 **차이**를 본다.

### 3-3. 판정 모델 평가 — 내장 지표 **11종**과 그 ID

`model-evaluation-metrics.html`:

| 지표 | ID | 무엇을 보는가 |
|---|---|---|
| 정확성 | `Builtin.Correctness` | 응답이 옳은지. ⭐ **참조 응답(그라운드 트루스)을 주면 평가자가 그것을 고려한다** |
| 완전성 | `Builtin.Completeness` | 프롬프트의 **모든 질문**에 답했는지 |
| 충실성 | `Builtin.Faithfulness` | ⭐ **프롬프트에 없는 정보가 응답에 들어 있는지** — 할루시네이션 축이다 |
| 유용성 | `Builtin.Helpfulness` | 지시 준수 · 합리성·일관성 · **암시적 요구 예측**까지 본다 |
| 논리적 일관성 | `Builtin.Coherence` | 논리적 공백·불일치·모순 |
| 관련성 | `Builtin.Relevance` | 프롬프트에 대한 관련성 |
| 지시 준수 | `Builtin.FollowingInstructions` | 프롬프트의 **정확한 지시**를 지켰는지 |
| 전문적 문체·어조 | `Builtin.ProfessionalStyleAndTone` | — |
| 유해성 | `Builtin.Harmfulness` | — |
| 고정관념 | `Builtin.Stereotyping` | ⭐ **긍정적이든 부정적이든** |
| 거부 | `Builtin.Refusal` | 답하기를 직접 거절했는지 |

운영 사실: **생성 모델 + 평가자 모델**이 필요하고, ⭐ **내 응답 데이터를 프롬프트 데이터세트에
직접 넣으면 Bedrock이 모델 호출 단계를 건너뛰고 그 데이터를 바로 평가한다**(Bedrock 밖 모델을
평가하는 경로다). 콘솔 지표 카드는 **점수 히스토그램**과 **처음 다섯 프롬프트**의 설명을 보여 주고
**전체 보고서는 내가 지정한 S3 버킷**에 있다.
⚠️ **평가자 모델 목록이 내장 지표용과 사용자 지정 지표용으로 다르다**(둘 다 모델 ID로 열거돼 있다 —
목록 자체는 묻지 않는다, §8).

### 3-4. ⚠️⚠️ 가이드가 드는 「유창성」에 대응하는 **내장 지표가 없다**

`기술 5.1.1`은 품질 지표로 **「관련성, 사실적 정확성, 일관성 및 유창성」** 넷을 든다. 측정:

| 가이드의 지표 | 대응하는 공식 내장 지표 |
|---|---|
| 관련성 | ✅ `Builtin.Relevance` |
| 사실적 정확성 | ✅ `Builtin.Correctness`(+ `Builtin.Faithfulness`) |
| 일관성 | ✅ `Builtin.Coherence` |
| **유창성** | ⚠️ **판정 내장 지표 11종에 없고 자동 평가 지표 셋(정확도·강건성·독성)에도 없다** |

- ⭐ **대조군이 통과한 뒤의 결과다** — 같은 표에서 앞의 셋은 그대로 찾힌다.
- ✅ 처리: **「유창성 내장 지표」를 정답으로 쓰지 않고** 그 자리는 **사용자 지정 지표**(판정 프롬프트를
  직접 쓰는 경로)로 가르친다. AgentCore 쪽에는 **`Conciseness`**(간결성) 같은 다른 축이 있다(§4-3).
- ⛔ 「공식에 유창성 지표가 없다」를 **문항의 정답으로 쓰지 않는다** — 부재는 개정으로 바뀔 수 있다.

## 4. AgentCore Evaluations — 유형 셋 · 평가자 네 갈래 · **세 수준**

### 4-1. 평가 유형 셋 (+프리뷰 하나)

| 유형 | 언제·어떻게 | 비자명한 점 |
|---|---|---|
| **온라인** | 배포된 에이전트를 **라이브 운영 트래픽**으로 계속 평가 | **세션 샘플링·필터링**을 구성한다 — **비율 기반**(예 10%) 또는 **조건 필터**. 낮은 점수 세션을 파고들고 입력→출력 흐름 전체를 본다 |
| **온디맨드** | **스팬·트레이스 ID를 지정**해 고른 상호 작용만 | 사용자 지정 평가자 시험 · 보고된 문제의 수정 검증 · 과거 데이터 분석. **빌드 시점 테스트**에 맞다 |
| **배치** | 여러 세션을 **비동기 작업 하나**로 | ⭐ **세션 발견·스팬 수집·채점을 서비스가 한다**(온디맨드는 내가 스팬을 모아 Evaluate API를 세션마다 부른다). **CloudWatch Logs 위치**와 평가자를 주면 **평가자별 평균과 세션 수**를 돌려주고 세션별 상세는 CloudWatch Logs에 쓴다 |
| 데이터세트 (**프리뷰**) | 데이터세트 스키마 + 온디맨드·배치 러너 | — |

⭐ **배치만 그라운드 트루스를 세션 메타데이터로 받는다** — **기대 응답 · 어서션 ·
기대 도구 궤적(expected tool trajectories)**. 기준선 측정 · 프롬프트·모델 변경 전후 비교 ·
큐레이션된 세션 집합의 회귀 테스트 · 주기적 품질 감사가 공식 용례다(`기술 5.1.4`).

### 4-2. 평가자 네 갈래

| 갈래 | 사실 |
|---|---|
| **내장** | `Builtin.<이름>` 형식(예 `Builtin.Helpfulness`). LLM을 판정자로 쓰고 평가자 모델·프롬프트 템플릿·채점 기준이 미리 정해져 있다. ⚠️ **구성을 수정할 수 없다**(일관성·신뢰성 보존) |
| **3자** | ⭐ **DeepEval·AutoEval 오픈소스 라이브러리**에서 온다. **ID만 고르면 서비스가 실행**하고 모델·구성이 필요 없다 |
| **사용자 지정** | **LLM-판정**(평가자 모델·지시·채점 스키마를 전부 내가) · ⭐ **코드 기반**(내 **Lambda 함수** — 결정적 검사·외부 API 호출·정규식·업무 규칙을 **LLM 없이**) |
| **파생** | 내장·3자 평가자의 **로직을 내 모델·추론으로** 돌린다 |

### 4-3. ⭐ 평가자는 **세 수준**이고, 수준이 플레이스홀더를 정한다

`prompt-templates-builtin.html`이 평가자를 수준별로 열거한다:

| 수준 | 평가자 | 플레이스홀더 |
|---|---|---|
| **세션 수준** (2) | `Goal success rate` · `Goal success rate with ground truth` | `context`(세션 전 턴의 사용자 프롬프트·응답·도구 호출) · `available_tools` |
| **트레이스 수준** (11) | `Coherence` · `Conciseness` · `Correctness` · `Correctness with ground truth` · `Faithfulness` · `Harmfulness` · `Helpfulness` · `Instruction following` · `Refusal` · `Response relevance` · `Stereotyping` | `context`(이전 턴 전체 + 현재 턴 프롬프트·도구 호출) · `assistant_turn` |
| **도구 수준** (4) | `Tool parameter accuracy` · `Tool selection accuracy` · `Skill selection accuracy` · `Skill instruction following` | `available_tools` · `context` · `tool_turn` (+스킬 플레이스홀더 4종) |

- ⭐ **세션 수준 평가자는 「목표를 달성했는가」를 묻고** 공식 프롬프트가 **대화 끝까지 사용자가
  여전히 원하는 목표만 센다**(명시적으로 철회·대체된 요청, 사용자가 답을 안 받고 넘어간 요청은 제외).
- 플레이스홀더가 수준마다 다르므로 **사용자 지정 평가자도 수준을 먼저 고른다.**

### 4-4. ⚠️⚠️ 평가자 **개수가 공식 안에서 어긋난다** — 그래서 묻지 않는다

| 자리 | 적는 수 |
|---|---|
| Lens `AGENTOPS06-BP01` · `AGENTOPS06-BP02` | **`Thirteen built-in evaluators`** (correctness·helpfulness·safety·tool selection accuracy를 덮는다고 적는다) |
| `prompt-templates-builtin.html` | **17개를 열거**한다(세션 2 + 트레이스 11 + 도구 4) |
| `built-in-evaluators-overview.html` | **수를 적지 않는다** |

- ⛔ **개수를 묻지 않는다.** 가르칠 것은 **세 수준으로 갈린다**는 성질과 **ID 형식**이다.
- ⭐ **AIF-C01 트랙의 기록도 정정된다** — AIF 노트는 「AgentCore 내장 평가자의 **13개와 ID 이름이
  공식에서 사라졌다**」고 적었는데, 2026-11-14 현재 **프롬프트 템플릿 페이지가 전부 열거**한다.
  **부재는 영구적이지 않다 — 다시 재야 한다.**

### 4-5. 스킬 평가자 — 호출마다 결과가 하나다

`skill-evaluators.html`: **스킬**은 에이전트가 런타임에 적재하는 재사용 `SKILL.md` 지시 파일이고
**개방 Agent Skills 표준**을 따른다. 둘 다 **도구 수준**이다.

| 평가자 | 반환값 |
|---|---|
| `Builtin.SkillSelectionAccuracy` | **`Yes`(1.0) / `No`(0.0)** — 적재한 스킬이 작업에 맞는가(**실행 품질이 아니라 선택 결정**만 본다) |
| `Builtin.SkillInstructionFollowing` | **5단계** — `Fully`(1.0) · `Mostly`(0.75) · `Partially`(0.5) · `Minimally`(0.25) · `Not Followed`(0.0) |

- ⚠️⚠️ **스킬 호출마다 결과 하나**다 — 한 세션에서 스킬을 세 번 호출하면 **평가자당 결과 3개**이고
  각 결과는 **그 스킬을 적재한 도구 호출 스팬에 고정**된다.
- ⚠️ **프레임워크가 스킬 카탈로그를 트레이스에 노출하지 않으면** `available_skills`가 **비고**,
  평가자는 **사용자 요청과 대화 맥락만으로** 판정한다.
- ⚠️ `skill_content`를 참조하는 평가자는 **`{context}`가 세션 전체**로 렌더된다 — 스킬을 적재한
  뒤 **어느 시점에든** 규정된 단계를 수행했을 수 있기 때문이다.

### 4-6. 통찰 평가자 — 점수가 아니라 **왜**를 돌려준다

`insight-evaluators.html`: 세션마다 결과를 쓰는 **것에 더해**, 평가가 끝난 뒤 **세션을 가로질러
관련 발견을 묶어 insights**로 돌려준다. 각 insight는 **패턴 · 근본 원인 · 제안 수정**을 담는다.

- 현재 제공되는 것은 **`Builtin.FailureAnalysis`** — 세션의 실패를 찾아 **스팬까지 추적**하고
  각 실패의 근본 원인을 정하고 세션을 가로질러 묶는다.
- ⚠️⚠️ **지금은 배치 평가 API만 통찰 평가자를 지원한다.**
- ⭐ 공식 예시가 대비를 잘 보여 준다 — 품질 점수는 「세션의 20%가 목표에 닿지 못했다」까지이고,
  통찰 평가자는 **어떤 실패 패턴이 그 20%를 만드는지와 무엇을 바꿔야 하는지**를 말한다.

## 5. 관찰성 — 세 계층과 **기본 제공 범위** (`기술 4.3.1`)

### 5-1. 세션 · 트레이스 · 스팬

`observability-telemetry.html`:

| 계층 | 정의 | 담는 것 |
|---|---|---|
| **세션** | 사용자와 에이전트의 **완전한 상호 작용 맥락** | 컨텍스트 지속 · 상태 관리 · 대화 이력 · 리소스 할당 · **다른 사용자 상호 작용과의 격리** |
| **트레이스** | **단일 요청-응답 주기**의 상세 기록(다른 에이전트 호출을 포함할 수 있다) | 요청 상세 · 처리 단계 순서 · **도구 호출의 입출력과 실행 시간** · 리소스 사용 · **오류와 복구 시도** · 응답 생성 |
| **스팬** | 실행 흐름 안의 **측정 가능한 개별 작업 단위** | 작업 이름 · 시작·종료 타임스탬프 · **부모-자식 관계** |

### 5-2. ⚠️⚠️ 기본으로 오는 것과 계측해야 오는 것이 갈린다

- **기본 제공**: AgentCore Runtime에서 도는 에이전트의 **세션 수준 지표**, 그리고
  **메모리·게이트웨이·내장 도구**의 기본 지표. ⭐ **메모리 리소스는 로그와 스팬도 기본으로** 온다.
- **계측해야 오는 것**: 내 에이전트의 **사용자 지정 지표·로그·스팬**. 그리고
  ⚠️⚠️ **트레이스 데이터를 모으려면 ADOT(AWS Distro for OpenTelemetry)로 코드를 계측해야 한다.**
- 보는 곳은 둘 — **AgentCore 콘솔 관찰성 페이지**와 **CloudWatch 콘솔의 생성형 AI 관찰성 페이지**.
- ⚠️ 94 §12-1의 경계가 여기도 적용된다 — **내장 도구 지표는 코드 인터프리터·브라우저 둘에만** 있다.

### 5-3. Lens가 적는 관찰성 의도와 흔한 실패

`AGENTOPS05`의 의도: 추론 단계·도구 호출·메모리 작업·**에이전트 간 핸드오프**를 담은 분산 트레이스와
**모든 서비스 경계를 넘는 트레이스 컨텍스트 전파** · 에이전트별 **행동 기준선**의 지속 유지 ·
**구조화·질의 가능 로그와 불변·PII 안전 감사 추적** · **네 차원 KPI** · 워크플로별 대시보드.

흔한 실패 넷(공식 서술):

1. **인프라 지표만 계측하고** 추론 반복·도구 호출·메모리 작업 같은 **에이전트 고유 스팬을 놓친다.**
2. ⚠️⚠️ **경계를 넘어 컨텍스트를 전파하지 않아** 재조립할 수 없는 **조각난 트레이스**가 된다.
3. ⚠️⚠️ **기준선을 배포 때 한 번 세우고 갱신하지 않아** 정당한 행동 변화가 **거짓 양성**을 내고
   기준선을 재정의할 만큼의 **점진적 드리프트는 탐지되지 않는다.**
4. 로그를 **변경 가능한 스토리지**에 둔다(감사 추적이 못 된다).

### 5-4. KPI는 **네 차원**이다 (`기술 4.3.1`·`4.3.3`·`5.1.8`)

`AGENTOPS05-BP04`:

| 차원 | 예시 |
|---|---|
| **운영** | 작업 완료율 · 해결 시간 · 오류율 · 에스컬레이션 비율 |
| **품질** | 결정 정확도 · **할루시네이션 비율** · 사용자 만족도 |
| **효율** | **작업당 토큰 · 작업당 도구 호출 · 작업당 비용** |
| **비즈니스** | 결과 달성률 · SLA 준수 · 고객 만족 영향 |

- ⚠️⚠️ **하나라도 빠지면 「완성돼 보이지만 오해를 만드는」 대시보드**가 된다(공식 표현).
  ⚠️ 그리고 **한쪽이 열 배 중요한데 운영·비즈니스 지표에 같은 가중치**를 주는 것도 안티패턴이다.
- 기준선은 **초기 관찰 기간 2~4주**면 보통 충분하고, 그 뒤 **CloudWatch 이상 탐지**로 자동 조정한다.
  **경고 임계는 검토를 시작하고 치명 임계는 조치를 지시한다**(둘을 나눈다).
- 주간 KPI 보고는 **`Amazon Quick Suite`**로 **기술·비즈니스 이해관계자가 같은 대시보드**를 본다.
  ⚠️ **D-11 적용** — 시험 가이드 표기는 `Amazon Quick`이고 Lens는 `Amazon Quick Suite`로 적는다.
  **이름은 가이드 표기를 쓰고 포함 관계·개수를 묻지 않는다.**
- **분기별 검토**로 KPI 정의가 아직 현행 사업 목표를 반영하는지 확인한다.

## 6. Bedrock 쪽 모니터링의 수치와 함정 (`기술 4.3.2`·`4.3.3`)

### 6-1. 모델 호출 로깅 — **기본이 꺼져 있다**

`model-invocation-logging.html`:

- **전체 요청 데이터·응답 데이터·메타데이터**를 모은다. 대상 작업 넷:
  **`Converse` · `ConverseStream` · `InvokeModel` · `InvokeModelWithResponseStream`**.
- ⚠️⚠️ **기본적으로 비활성**이고, 켜면 **로깅 구성을 삭제할 때까지** 로그가 저장된다.
- 대상은 **Amazon S3**와 **CloudWatch Logs**이고 ⚠️ **같은 계정·같은 리전만** 지원한다.
- ⚠️⚠️ **`bedrock-runtime` 엔드포인트로 들어온 호출만 캡처된다** — OpenAI 호환 `Responses`·
  `Chat Completions` API도 그 엔드포인트면 포함되지만, **같은 API라도 `bedrock-mantle`을 거치면
  현재 캡처되지 않는다.**
- Converse로 넘긴 **이미지·문서 데이터는 S3에 기록**된다(전달과 이미지 로깅을 켠 경우).
- ⚠️ S3 대상은 **버킷 ACL이 비활성**이어야 버킷 정책이 효력을 갖는다.
- 전달 자체의 지표 넷: `ModelInvocationLogsCloudWatchDeliverySuccess`/`…Failure` ·
  `ModelInvocationLogsS3DeliverySuccess`/`…Failure`(네임스페이스 `AWS/Bedrock`).

### 6-2. CloudWatch 런타임 지표 — 세 가지가 서로 다른 집합을 센다

`monitoring-runtime-metrics.html`(네임스페이스 **`AWS/Bedrock`**):

| 지표 | ⚠️ 비자명한 점 |
|---|---|
| `Invocations` | **나중에 클라이언트·서버 오류로 실패한 요청을 포함**하고, **스로틀된 요청과 처리 시작 전 입력 검증에서 거부된 요청은 포함하지 않는다** |
| `InvocationLatency` | **요청 전송 ~ 마지막 토큰 수신**(전체) |
| `TimeToFirstToken` | **요청 전송 ~ 첫 토큰** — ⚠️ **스트리밍 API에만** 있다 |
| `InvocationClientErrors` | ⚠️⚠️ **서비스 쿼터 초과로 거부된 요청이 여기 들어가고 스로틀로 세지 않는다** |
| `InvocationThrottles` | ⚠️⚠️ **`Invocations`·`ClientErrors`·`ServerErrors` 어디에도 들어가지 않는다.** 보이는 수는 **SDK 재시도 설정에 따라 달라진다** |
| `InputTokenCount` · `OutputTokenCount` · `OutputImageCount` · `LegacyModelInvocations` | — |
| `EstimatedTPMQuotaUsage` | ⚠️⚠️ **근삿값이고 스로틀링 결정을 끌고 가는 예약 기반 소비를 반영하지 않는다.** 공식이 **쿼터 사용·용량 계획의 단독 지표로 쓰지 말라**고 적는다 |
| `CacheReadInputTokenCount` | **감액 요율로 과금되고 TPM 쿼터에 들어가지 않는다** |
| `CacheWriteInputTokenCount` | ⚠️ **TPM 쿼터에 들어간다** |

⚠️⚠️ **`ModelId` 차원으로 필터하면 오류를 적게 센다** — 요청이 **어느 모델을 겨냥하는지 판정되기
전에** 실패하면 그 요청의 지표는 **차원 없이** 발행된다. 전수를 보려면 **차원을 지정하지 않고** 질의한다.
(Guardrails·Agents용 지표도 따로 있다.)

### 6-3. 토큰 — `max_tokens`가 쓰지 않아도 쿼터를 먹는다

`quotas-token-burndown.html`:

- **TPM**은 모델 수준 쿼터(입력+출력), **TPD**는 계정의 전 모델 합계이고
  ⚠️ **온디맨드 요금 기준 추정**이라 실제 소비는 모델·입출력 비율·캐시 사용에 따라 달라진다.
- ⚠️⚠️ **요청 시작 시점에 「입력 토큰 + `max_tokens`」가 선차감**되고 그 합이 쿼터를 넘으면
  스로틀된다 — **실제로 짧게 답해도 큰 `max_tokens`는 쿼터를 먹는다.**
- 쿼터 대비 **총 입력 소비 = `InputTokenCount` + `CacheWriteInputTokenCount`**.
- **번다운 비율**: 모델에 따라 **출력 토큰 1개가 쿼터에서 15·10·5·2.5개**를 소비하고,
  모델 카드에 따로 적히지 않으면 **1:1**이다. ⚠️ **번다운은 `bedrock-runtime` 엔드포인트 모델에만**
  적용된다 — `bedrock-mantle` 전용 모델은 **입력·출력 쿼터가 분리**돼 번다운이 없다.
- ⛔ 모델별 배수 **수치표는 묻지 않는다**(§8) — 성질만 쓴다.

### 6-4. CloudWatch 이상 탐지 — 가이드가 드는 「토큰 버스트·응답 드리프트」의 공식 수단

`CloudWatch_Anomaly_Detection.html`:

- 과거 데이터에 ML을 적용해 **기대값 모델**을 만들고 **추세와 시간별·일별·주별 패턴**을 본다.
- **최대 2주 데이터로 학습**하고 ⭐ **2주가 다 차지 않아도 켤 수 있다.**
- ⚠️⚠️ **모델은 지표 하나 + 통계 하나에 고유하다** — `AVG`로 켜면 그 모델은 `AVG` 전용이다.
- **임계값이 크면 「정상」 띠가 두꺼워진다.** 흔한 AWS 지표는 **논리적 범위를 벗어나지 않게** 묶인다
  (0~100 · 음수 불가 등).
- 만든 뒤에도 **계속 평가·재학습**하고 계절성·급변·희소 지표용 예측기를 더한다.
- ⭐ **특정 기간을 학습에서 제외**할 수 있다(배포 같은 이례적 사건을 빼면 모델이 정확해진다).
- ⚠️ **이상 탐지 모델을 알람에 쓰면 과금된다.**

### 6-5. 행동 이상 탐지 — 성능 지표만으로는 늦는다

`AGENTOPS05-BP02`:

- 기준선은 **2~4주** 동안 **추론 반복 수 · 도구 선택 빈도 · 에스컬레이션 비율 · 작업 완료율 ·
  신뢰도 점수 분포**를 모아 에이전트별로 세운다. **기준선 없는 이상 탐지는 신뢰할 수 없는 신호**를 낸다.
- ⚠️⚠️ **성능 지표(지연·오류율)는 필요하지만 충분하지 않다** — 미묘한 드리프트는 **행동 지표**에서
  먼저 나타난다(천천히 오르는 에스컬레이션 비율 · 조용히 늘어나는 할루시네이션 빈도 ·
  **덜 유능한 도구로 쏠리는 선택 패턴**).
- ⭐ **심각도별 라우팅 셋**: 성능 이상 → **자동 조사** · 행동 이상 → **사람 검토** ·
  보안 관련 이상 → **즉시 에스컬레이션**. 셋을 섞으면 소음과 과소 대응이 된다.
- ⚠️⚠️ **드리프트 세 종류를 구분하지 못하면 처방이 엉뚱해진다** —
  **데이터 드리프트**(입력 분포 변화) · **개념 드리프트**(입력-출력 관계 변화) ·
  **성능 드리프트**(출력 품질 저하).

### 6-6. 감사·포렌식 추적성 (`기술 4.3.3`)

`logging-using-cloudtrail.html`:

- ⭐ **일부 Runtime API가 「관리 이벤트」로 기록된다** —
  **`InvokeModel` · `InvokeModelWithResponseStream` · `Converse` · `ConverseStream` ·
  `ListAsyncInvokes`**. 그 밖의 Runtime API(`InvokeModelWithBidirect…` 계열)는 **데이터 이벤트**다.
- ⚠️ **데이터 이벤트는 대용량이라 CloudTrail이 기본으로 기록하지 않는다.**
- ⚠️ 이 페이지는 **`bedrock-runtime` 엔드포인트**용이고 `bedrock-mantle`은 **별 페이지**다.
- 추적(trail)을 만들면 **콘솔 기본값이 전 리전**이고 로그 파일이 S3로 전달된다. 추적이 없어도
  **Event history**에서 최근 이벤트를 본다.
- ⭐ **AIF-C01 트랙이 「관리 이벤트가 4 대 5로 어긋난다」로 남긴 자리는 현행이 다섯을 적는다**
  (`ListAsyncInvokes` 포함). ⚠️ 그래도 **개수를 묻지 않고** 「호출 API가 관리 이벤트로 남는다」는
  성질만 쓴다 — 목록은 개정된다.

## 7. 문제 해결 (작업 5.2 + `기술 4.3.6`)

### 7-1. ⭐⭐ `stopReason` 아홉 값이 실패 모드를 구분한다 (`기술 5.2.1`·`5.2.2`)

`API_runtime_Converse.html` Response Elements의 유효값(공식 전문):

```
end_turn | tool_use | max_tokens | stop_sequence | guardrail_intervened |
content_filtered | malformed_model_output | malformed_tool_use | model_context_window_exceeded
```

| 증상 | 신호 |
|---|---|
| **응답이 잘렸다** | **`max_tokens`** — 모델이 아니라 **내 `max_tokens` 설정**에 걸렸다 |
| ⭐ **컨텍스트 창을 넘겼다** | **`model_context_window_exceeded`** — 전용 값이 있다 |
| 도구 호출 형식이 깨졌다 | **`malformed_tool_use`**(모델 출력 전체면 `malformed_model_output`) |
| 가드레일이 막았다 | `guardrail_intervened` / `content_filtered` |
| 정상 종료 | `end_turn` · `stop_sequence` · (도구를 부르려고 멈춤) `tool_use` |

⭐ `기술 5.2.1`의 「컨텍스트 창 오버플로 진단」과 「잘림 관련 오류 분석」이 **서로 다른 값**이다 —
둘을 한 신호로 묶으면 틀린다.

### 7-2. 오류 아홉 종과 HTTP 코드 (`기술 5.2.2`·`2.4.3`)

| 예외 | 코드 | ⚠️ |
|---|---|---|
| `ValidationException` | **400** | 입력이 제약을 만족하지 못한다 |
| `AccessDeniedException` | 403 | — |
| `ResourceNotFoundException` | 404 | 지정한 리소스 ARN이 없다 |
| **`ModelTimeoutException`** | **408** | 처리 시간이 **모델 타임아웃 길이**를 넘었다 |
| **`ModelErrorException`** | **424** | 모델 처리 중 오류(`originalStatusCode`·`resourceName`을 돌려준다) |
| **`ModelNotReadyException`** | **429** | ⭐ **SDK가 최대 5회 자동 재시도**한다 |
| **`ThrottlingException`** | **429** | **계정 쿼터 초과**로 거부됐다 |
| `InternalServerException` | 500 | — |
| `ServiceUnavailableException` | 503 | — |

⚠️⚠️ **429가 둘이다** — `ThrottlingException`(쿼터)과 `ModelNotReadyException`(모델 준비 안 됨).
**코드만 보고 쿼터 문제로 처방하면 틀린다.** 그리고 **400 `ValidationException`과 408·424는
재시도 대상이 아니다**(94 §8-2의 오류 분류 taxonomy와 같은 축이다).

### 7-3. 호출 전에 토큰을 센다 — `CountTokens`

`API_runtime_CountTokens.html`: **`POST /model/{modelId}/count-tokens`**.

- ⚠️ **토큰화가 모델별이라 모델을 지정해야** 하고, 돌려주는 수는 ⭐ **같은 입력을 `InvokeModel`·
  `Converse`로 보냈을 때 과금될 토큰 수와 일치한다.**
- 입력은 `invokeModel` 또는 `converse` **중 하나**(Union)이고 응답은 **`inputTokens`**뿐이다.
- 공식 용례 셋: **비용 추정 · 토큰 한도에 맞게 프롬프트 최적화 · 토큰 사용 계획.**
- ⭐ `기술 5.2.1`의 「컨텍스트 창 오버플로 **진단**」을 **사전**에 하는 수단이다
  (사후 신호는 §7-1의 `model_context_window_exceeded`).

### 7-4. 프롬프트 쪽 (`기술 5.2.3`·`5.2.5`)

`prompt-management-version-compare.html`: 콘솔이 **두 버전의 JSON을 나란히** 보여 주고
**한쪽에만 있는 필드를 `+`(초록)·`-`(빨강)로** 표시한다. ⭐ 그리고 **테스트 변수를 채워
`Run prompt`로 두 버전의 모델 응답까지 비교**한다 — `기술 5.2.3`의 「버전 비교」가 이것이다.

### 7-5. 평가 파이프라인 자체가 안 돌 때 (`기술 4.3.6`·`5.2.2`)

`diagnose-evaluation-issues.html`이 **진단 스킬**(마크다운 `SKILL.md`)과 함께 흔한 실패를 열거한다:

- **빈 평가 결과**(구성은 켜져 있는데 점수가 없다)
- **`LogEventMissingException`** — 스팬에 대응하는 로그 이벤트가 없다
- **`AgentSpanMappingException`·`ToolSpanMappingException`** — 스팬에서 사용자 질의나 도구 출력을
  추출할 수 없다
- **`SpanEventParsingException`** · **`Gateway Timeout (504)`**
- **`evaluatorId`의 `ValidationException`** — 평가자 ID 형식이 틀렸다
- **다중 에이전트 평가 스코핑** — 평가자가 다중 에이전트 트레이스에서 **엉뚱한 에이전트를 겨냥**한다

⚠️⚠️ 전제가 중요하다 — **에이전트가 관찰성을 켠 상태로 최소 한 번 호출됐어야** 진단이 성립한다.
94 §12-3의 「계측만으로는 평가되지 않는다」와 같은 사실이다.
⭐ 스킬은 **내 계정의 CloudWatch 로그 그룹을 질의**하고 서비스 측 접근은 필요하지 않다
(필요 권한: `logs:DescribeLogGroups`·`DescribeLogStreams`·`StartQuery`·`GetQueryResults` +
온라인 평가면 `bedrock-agentcore:GetOnlineEvaluationConfig`·`ListOnlineEvaluationConfigs`).

### 7-6. 테스트는 **네 계층**이다 (`기술 5.1.4`·`5.1.9`)

`AGENTOPS06-BP01`:

| 계층 | 무엇을 보는가 |
|---|---|
| **단위** | 프롬프트 템플릿 · 도구 호출 로직 · 메모리 검색 · 결정 라우팅. ⭐ 결정성이 필요하면 **LLM 응답을 목(mock)** 한다 |
| **통합** | **실제 엔드포인트가 있는 스테이징**에서 에이전트-도구·에이전트-에이전트 상호 작용 |
| **E2E** | 전체 워크플로 — ⚠️ **여기서는 정확 일치보다 의미 평가가 중요하다**(Bedrock Evaluations·AgentCore Evaluations가 그 의미 품질 평가를 맡는다) |
| **섀도** | ⭐ **트래픽 미러링**으로 새 버전을 운영과 **병행 실행**하고 출력을 비교하되 **새 버전의 응답은 서빙하지 않는다**. 비용은 병행 추론 인프라, 값은 사용자가 만나기 전에 잡는 것 |

- ⚠️⚠️ **정확 일치 단정(exact-match)은 비결정적 LLM 출력을 깨뜨린다** — 의미 동등성 검사를 쓴다.
- ⚠️ **테스트 데이터세트를 역량 변화에 맞춰 갱신하지 않으면** 테스트가 낡아 **회귀 탐지 가치를 잃는다.**
- ⭐ **CI/CD의 품질 게이트**로 평가자를 쓰면 **비트 단위 비교 없이** 품질 회귀를 막을 수 있다
  (`기술 5.1.4`의 「자동화된 품질 게이트」).
- `기술 5.1.9`의 「합성 사용자 워크플로」는 이 계층 구조에서 **E2E·섀도**에 해당한다.
  ⛔ 특정 서비스 이름(예: 합성 모니터링 제품)을 공식 근거 없이 끌어오지 않는다.

### 7-7. 지속 평가 — 배포 시점 평가는 「출시 가능한가」만 답한다

`AGENTOPS06-BP02`: **배포 전 평가는 출시 준비를, 배포 후 평가는 「여전히 동작하는가」를** 검증한다.

- 안티패턴 넷: 배포 시점만 평가 · ⚠️ **자동 지표만 쓰고 주기적 사람 평가를 빼기**(뉘앙스·적절성·
  사업 맥락 정합은 자동 지표가 온전히 못 잡는다) · **모든 에이전트에 같은 일반 기준** ·
  평가를 운영과 분리해 **평가 부채**를 쌓기.
- 평가 차원 넷(KPI 네 차원과 짝이다): **출력 품질 · 안전 · 효율 · 비즈니스 정합.**
  ⭐ **가중치는 용례가 정한다** — 고객 지원 에이전트는 만족도를, 내부 자동화 에이전트는 효율을
  더 무겁게 둔다. **일반 가중치는 일반적인 결과를 낸다.**
- ⭐ 경보는 **임계 위반**과 **지속적 하락 추세** 둘 다에 걸고 **단일 시점의 하락**에는 걸지 않는다 —
  진단하기 가장 어려운 느린 문제를 잡는 쪽이다.
- **LLM-as-judge는 여러 평가자 프롬프트로 합성 점수**를 만드는 것이 단일 프롬프트보다 신뢰성이 높고,
  **주기적 사람 검토가 그 자동 점수를 검증**한다.

## 8. 묻지 않을 것 (이 축의 D-규율 적용)

- **개수** — AgentCore 내장 평가자 수(⚠️ **13 ↔ 17 어긋남**, §4-4) · Bedrock 내장 지표 수 ·
  작업 유형·내장 데이터세트 수 · CloudTrail 관리 이벤트 수(§6-6).
- **「유창성 내장 지표」**(§3-4). 그리고 **그 부재 자체도 정답으로 쓰지 않는다.**
- **번다운 비율의 모델별 수치표**(⚠️ 단 **출력 토큰이 더 비싸게 소비될 수 있다**와
  **`max_tokens` 선차감**은 성질이라 쓴다).
- **`EstimatedTPMQuotaUsage`를 쿼터 사용의 정답 지표로** 쓰게 하는 것 — **공식이 금지한다.**
- **평가자 모델·생성 모델 ID 목록**(모델 목록은 개정된다).
- **CloudWatch 이상 탐지의 임계값 숫자**(⚠️ 단 **최대 2주 학습** · **지표+통계에 고유** ·
  **알람 사용 시 과금** · **기간 제외 가능**은 쓴다).
- **`Amazon Quick` / `Amazon Quick Suite`의 포함 관계·표기 차이**(D-11 · §5-4).
- **`repost.aws`를 근거로 하는 문구**(예: 「Input is too long for requested model」) —
  docs-proper에 **`model_context_window_exceeded`**라는 더 정확한 신호가 있다.
- **합성 모니터링 제품 이름**을 `기술 5.1.9`에 끌어오는 것(§7-6).

## 9. 출처 (전부 `curl -sL` 실측 · 2026-11-14 · **28개 전부 `200 r=0`**)

| 제목 | URL |
|---|---|
| Bedrock 평가 개요(네 종류 · 평가 대상 모델 유형 여섯) | https://docs.aws.amazon.com/bedrock/latest/userguide/evaluation.html |
| 판정 모델 평가(생성·평가자 모델 · 응답 직접 제공 시 호출 생략) | https://docs.aws.amazon.com/bedrock/latest/userguide/evaluation-judge.html |
| 내장 지표 **11종과 ID** | https://docs.aws.amazon.com/bedrock/latest/userguide/model-evaluation-metrics.html |
| 자동 평가 작업 유형 넷 · 데이터세트 · 계산 지표 | https://docs.aws.amazon.com/bedrock/latest/userguide/model-evaluation-tasks.html |
| 사람 작업자 평가(작업 팀 관리) | https://docs.aws.amazon.com/bedrock/latest/userguide/evaluation-human.html |
| **모델 호출 로깅**(기본 꺼짐 · 같은 계정·리전 · `bedrock-runtime`만) | https://docs.aws.amazon.com/bedrock/latest/userguide/model-invocation-logging.html |
| CloudWatch 런타임 지표(세 집합의 경계 · `ModelId` 차원 함정) | https://docs.aws.amazon.com/bedrock/latest/userguide/monitoring-runtime-metrics.html |
| 토큰 계산(TPM·TPD · 번다운 · **`max_tokens` 선차감**) | https://docs.aws.amazon.com/bedrock/latest/userguide/quotas-token-burndown.html |
| CloudTrail(관리 이벤트 다섯 ↔ 데이터 이벤트) | https://docs.aws.amazon.com/bedrock/latest/userguide/logging-using-cloudtrail.html |
| 프롬프트 버전 비교(JSON 나란히 · 테스트 변수로 응답 비교) | https://docs.aws.amazon.com/bedrock/latest/userguide/prompt-management-version-compare.html |
| **`Converse` API 참조 — `stopReason` 아홉 값 · 오류 아홉 종** | https://docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_Converse.html |
| **`CountTokens` API 참조**(모델별 토큰화 · 과금 토큰과 일치) | https://docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_CountTokens.html |
| AgentCore Evaluations 작동 방식(목표 달성·도구 정확성·밖의 에이전트도) | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/how-it-works-evaluations.html |
| 평가 유형 셋(온라인·온디맨드·배치 · 그라운드 트루스) | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/evaluations-types.html |
| 평가자 네 갈래(내장·3자 DeepEval·AutoEval·사용자 지정·파생) | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/evaluators.html |
| 내장 평가자(`Builtin.<이름>` · 변경 불가) | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/built-in-evaluators-overview.html |
| **프롬프트 템플릿 — 세 수준 17개 열거 · 플레이스홀더** | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/prompt-templates-builtin.html |
| 스킬 평가자(둘 · 호출마다 결과 하나 · 5단계 점수) | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/skill-evaluators.html |
| 통찰 평가자(`Builtin.FailureAnalysis` · **배치만**) | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/insight-evaluators.html |
| 평가 문제 진단(예외 목록 · 관찰성 전제) | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/diagnose-evaluation-issues.html |
| 관찰성 개념(세션·트레이스·스팬 · 기본 제공 범위 · ADOT) | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/observability-telemetry.html |
| 내장 도구 관찰성 데이터(둘에만 · 60분 지연) | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/observability-tool-metrics.html |
| **CloudWatch 이상 탐지**(최대 2주 · 지표+통계 고유 · 알람 과금) | https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Anomaly_Detection.html |
| `AGENTOPS05` 관찰성 의도와 흔한 실패 | https://docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentops05.html |
| `AGENTOPS05-BP02` 행동 이상 탐지 · 드리프트 세 종 · 심각도 라우팅 | https://docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentops05-bp02.html |
| `AGENTOPS05-BP04` KPI 네 차원 · 기준선 2~4주 · 주간 보고 | https://docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentops05-bp04.html |
| `AGENTOPS06-BP01` 테스트 네 계층 · 섀도 테스트(**「13개」 서술**) | https://docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentops06-bp01.html |
| `AGENTOPS06-BP02` 지속 평가 · 평가 차원 넷(**「13개」 서술**) | https://docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentops06-bp02.html |

## 10. 측정 방법과 함정

- 슬러그는 **가이드 TOC에서 뽑았다**(Bedrock 1,147 · AgentCore 598 · Agentic AI Lens 212항목).
  API 참조는 TOC가 아니라 **본문의 `Response Elements`·`Errors` 절**에서 읽었다.
- ⚠️⚠️ **`Valid Values`를 저장한 HTML에서 grep으로 뽑으려다 빈 문자열을 얻었다** —
  값이 별 요소에 있어 `Valid Values: [^<]*` 가 라벨만 집는다. **문서 리더로 TOC 오프셋
  (`Response Elements` = char 18306)을 지정해 그 절만 다시 읽어** 아홉 값을 얻었다.
  ⭐ **「비었다」는 데이터가 아니라 추출 실패일 수 있다**(대조군: 같은 파일에 `stopReason` 5건 ·
  `Valid Values` 다수).
- ⚠️⚠️ **히어독으로 넘긴 파이썬이 이 환경에서 대화형 REPL로 떨어져 멈췄다** —
  `python3`이 없고 `py -`가 REPL로 들어간다(2분 타임아웃 뒤 백그라운드로 밀렸고 `TaskStop`으로
  정리했다). 레포 규율대로 **스크립트는 파일로 쓴다**.
- 「없다」는 **알려진 양성 대조군을 통과한 뒤에만** 적었다 — §3-4의 유창성 부재는
  같은 표에서 `Relevance`·`Correctness`·`Coherence`가 **찾히는 것**을 확인한 뒤의 판정이다.
- ⚠️ **개수가 어긋나는 자리는 양쪽을 모두 인용해 기록했다**(§4-4의 13 ↔ 17 · §6-6의 관리 이벤트).
  **어느 한쪽을 골라 적으면 그 수가 문항으로 굳는다.**
- ⚠️ **`repost.aws`는 근거로 쓰지 않았다** — 「Input is too long for requested model」 문구가
  거기 있지만, docs-proper에 **`model_context_window_exceeded`**라는 더 정확한 신호가 있다.
- 출처 **28개 전부 `curl -sL`로 `200 r=0`**이고, 노트 본문의 고유 URL 집합과 측정 집합을
  **기계로 대조해 양방향 차이 0**을 확인했다.
