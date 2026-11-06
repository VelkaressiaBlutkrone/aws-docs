---
생성: 2026-11-03
목적: 레포 `flutter_app/assets/exam_guides/AIF-C01.json` vs 공식 가이드 v1.1 기계 대조 + v1.0→v1.1 개정 전문
방법: 공식 전사([00-overview.md](00-overview.md) §3)와 레포 JSON의 `knowledge` 배열을 **번호 단위로 전수 비교**(공백 무시)
---

# 97 — 레포 JSON 대조와 v1.0→v1.1 개정

## 1. 대조 방법과 대조군

- 레포 JSON의 목표는 번호를 갖지 않으므로 **도메인 → Task → `knowledge` 배열 순서**대로 `d.t.k` 번호를 매겼다.
- 공식 쪽은 [00-overview.md](00-overview.md) §3의 전사(`- 1.1.1 …` 형태)를 기계로 읽었다.
- **대조군:** 비교 전에 "번호 집합과 순서가 양쪽에서 동일한가"를 단정했고 **통과**했다. 이것이 없으면 한 항목이 밀렸을 때 뒤의 전부가 거짓 불일치로 보인다.
- 정규화는 **공백 제거만** 했다(문체·조사 차이를 일부러 남겨 눈으로 분류했다).

**결과: 목표 69건 중 일치 52 · 불일치 17.**

불일치 번호: `1.1.1` `1.1.2` `1.2.4` `1.2.5` `1.2.6` `1.3.1` `1.3.4` `1.3.6` `2.3.1` `4.1.4` `4.1.7` `4.2.1` `4.2.2` `5.1.1` `5.1.4` `5.1.5` `5.2.1`

## 2. 불일치 분류

### 2.1 실질 차이 — 서비스·지표 목록이 다르다 (9건, 저작에 영향)

| 번호 | 레포 JSON | 공식 v1.1 본문 | 판정 |
|---|---|---|---|
| 1.1.1 | … 대규모 언어 모델(LLM)) 정의 | … LLM), **생성형 AI(GenAI), 에이전틱 AI**) 정의 | 레포에 **v1.0 잔재** |
| 1.1.2 | AI, ML, GenAI, 딥 러닝 간의 … | AI, ML, GenAI, 딥 러닝, **에이전틱 AI** 간의 … | 레포에 **v1.0 잔재** |
| 1.3.4 | 예: 아마존 베드락, **아마존 Q**, 아마존 퀵, Kiro, SageMaker AI | 예: Amazon Bedrock, Amazon Quick, Kiro, SageMaker AI | ⚠️ **Amazon Q가 공식 본문에 없다**(§4) + 서비스명 한글 음차 |
| 1.3.6 | 예: 정확도, **곡선 밑부분 면적(AUC)**, F1 점수 | 예: 정확도, **정밀도, 재현율**, F1 점수 | 레포에 **v1.0 지표**(AUC) |
| 4.1.7 | 예: 레이블 품질 분석, 인간의 감사, 하위 그룹 분석, **Amazon SageMaker Clarify, SageMaker Model Monitor, Amazon Augmented AI(Amazon A2I)** | 예: 라벨 품질 분석, 인간 감사, 하위 그룹 분석 | ⚠️ 레포가 **공식에 없는 서비스 3개**를 예시로 든다 |
| 4.2.2 | 예: Amazon SageMaker 모델 카드, **SageMaker Clarify**, Amazon 기반 모델 평가, … | 예: **Amazon SageMaker Model Cards, Amazon Bedrock 모델 평가**, 오픈 소스 모델, … | ⚠️ 세 소스가 다 다르다(§4) |
| 5.1.1 | … **AgentCore ID**, AgentCore의 정책, **Amazon BedRock Guardrail** | … **AgentCore Identity**, AgentCore의 정책, **Amazon Bedrock Guardrails** | 서비스명 오표기 |
| 5.1.4 | … 인프라 보호, **신속한 삽입**, 저장 및 전송 중 암호화 … | … 인프라 보호, **프롬프트 인젝션**, 저장 및 전송 중 암호화 … | ⚠️ `prompt injection`의 **기계번역 오역**(§4) |
| 5.2.1 | 예: AWS Config, Amazon Inspector, **AWS Audit Manager**, AWS Artifact, AWS CloudTrail, AWS Trusted Advisor | 예: AWS Config, Amazon Inspector, AWS Artifact, AWS CloudTrail, AWS Trusted Advisor | ⚠️ 레포가 **공식에 없는 서비스 1개**를 든다 |

> ⚠️ **`AWS Audit Manager` · `Amazon A2I` · `SageMaker Model Monitor` 는 v1.1 범위 내 서비스 목록에도 없다**([00-overview.md](00-overview.md) §4.1 전수 실측). 레포 JSON만 보고 저작하면 **범위 밖 서비스를 정답 보기로 쓰게 된다.**

### 2.2 표기·문체 차이 (8건, 사실은 같다)

| 번호 | 차이 |
|---|---|
| 1.2.4 | "예를 식별" ↔ "예시 식별" · "사기 탐지" ↔ "**사기 행위 탐지**" |
| 1.2.5 | 괄호 위치(서비스 목록이 "기능" 앞 ↔ 뒤) |
| 1.2.6 | "**기초 모델**(FM)" ↔ "**파운데이션 모델**(FM)" · 괄호 위치 |
| 1.3.1 | "구성 요소를 설명하고 구분" ↔ "구성 요소 설명 및 구분" |
| 2.3.1 | **문장 끝 마침표 유무뿐**(공식 본문에 마침표 없음) |
| 4.1.4 | "생성형 AI" ↔ "생성형 AI(**GenAI**)" |
| 4.2.1 | "차이점을 설명" ↔ "차이점 설명" |
| 5.1.5 | "**환각**" ↔ "**할루시네이션**" · "출력 검증" ↔ "출력 유효성 검사" · "RAG 접지" ↔ "RAG **근거 기반**" |

> 5.1.5의 "환각 ↔ 할루시네이션"은 문체 차이로 분류했지만 **학습문서 용어 통일 대상**이다. 공식 한국어 본문이 도메인 2(`2.2.2`)·도메인 4(`4.1.4`)·도메인 5(`5.1.5`)에서 모두 **「할루시네이션」**을 쓰므로 레포 콘텐츠도 그 표기를 쓴다.

## 3. v1.0 → v1.1 개정 전문 (공식 개정 페이지, 2026-04-30)

### 3.1 변경 기록

| 버전 | 게시 날짜 |
|---|---|
| 1.0 | 2026년 3월 26일 |
| 1.1 | 2026년 4월 30일 |

공식은 "시험 안내서 업데이트는 업데이트가 시험에 반영되기 **약 1개월 전**에 게시됩니다"라고 적는다. → v1.1 내용은 **2026-05-30경부터 시험에 반영**됐다고 읽는다(공식이 날짜를 직접 적지는 않는다).

### 3.2 목표 본문 변경 (공식 표 19행)

공식 개정 표가 `버전 1.0` → `버전 1.1`로 짝지어 적는 목표는 다음 19개다.

`1.1.1` `1.1.2` `1.1.3` `1.1.5` `1.2.4` `1.3.1` `1.3.4` `1.3.6` `2.2.1` `2.2.3` `2.2.4` `2.3.1` `3.1.5` `3.1.6` `3.4.1` `3.4.2` `4.2.2` `5.1.1` `5.1.4`

저작에 영향이 큰 변경만:

- **1.1.3** 추론 유형에 **비동기·서버리스** 추가(v1.0은 배치·실시간뿐)
- **1.3.1** v1.0의 긴 ML 파이프라인 단계 열거(데이터 수집·EDA·전처리·특성 엔지니어링·훈련·하이퍼파라미터 조정·평가·배포·모니터링)가 **"AI/ML 파이프라인의 구성 요소 설명 및 구분"으로 축약**됐다 — 단계 이름을 외우는 문제에서 **구분하는** 문제로 바뀐 신호다
- **1.3.4** 예시가 SageMaker 하위 기능(Data Wrangler·Feature Store·Model Monitor)에서 **Amazon Bedrock·Amazon Quick·Kiro·SageMaker AI**로 교체
- **2.2.3** 모델 선택 고려 요소에 **비용·대기 시간·모델 복잡성** 추가 ⚠️ **단, 도메인 2 본문의 2.2.3에는 그 셋이 없다**(§4)
- **2.3.1** 예시에서 **PartyRock·Amazon Bedrock Data Automation 삭제**, **Strands Agents·AgentCore·Amazon Quick·Kiro·JumpStart 추가**
- **3.1.5** FM 사용자 지정 비용 절충에 **모델 증류** 추가
- **3.1.6** v1.0 "다단계 작업에서 에이전트의 역할 설명(예: Amazon Bedrock Agent, 에이전틱 AI, 모델 컨텍스트 프로토콜)" → v1.1 **"AI 에이전트의 역할을 정의하고 AI 에이전트의 비즈니스 애플리케이션을 설명"**(서비스 예시가 **빠지고** 비즈니스 적용으로 이동)
- **3.4.2** 평가 지표에 **LLM-as-a-judge** 추가
- **4.2.2** v1.0 "Amazon SageMaker Model Cards, 오픈 소스 모델, 데이터, 라이선싱" → v1.1은 개정 표에 **"Amazon SageMaker 모델 카드, SageMaker Cartify, Amazon 기반 모델 평가, 오픈 소스 모델, 데이터, 라이선스"**로 적힌다(§4)
- **5.1.1** AI 보안 서비스 예시에 **AgentCore Identity · AgentCore의 정책 · Bedrock Guardrails** 추가
- **5.1.4** 보안·프라이버시 고려에 **데이터 유출 방지 · 출력 필터링 및 검증 · 감사 추적/로깅 요구 사항 · 독성** 추가

### 3.3 목표 추가 (7건, 삭제 0건)

| 번호 | 추가된 목표 |
|---|---|
| 1.2.6 | 기존 ML 모델 또는 FM이 특정 사용 사례에 적합한 경우 식별 |
| 2.1.4 | 추론을 위한 **토큰 기반 가격 책정 모델**과 비용·성능 영향 |
| 2.1.5 | FM 애플리케이션에서 **컨텍스트 엔지니어링**의 역할 |
| 2.1.6 | 기본 **에이전트 AI** 개념(다중 에이전트 패턴 · **MCP** · 메모리 관리 · 도구 사용 · 워크플로 오케스트레이션) |
| 3.2.5 | **Amazon Bedrock 프롬프트 관리**를 사용하는 프롬프트 버전 관리 전략 |
| 3.4.5 | AI 애플리케이션의 **비즈니스 목표 조정 지표**(작업 완료율 · 사용자 만족도 · 상호 작용당 비용) |
| 5.1.5 | **할루시네이션 감지·접지 기법**(RAG 근거 기반 · 출력 유효성 검사 · 신뢰도 점수) |

**추가된 7개가 모두 레포 JSON에 이미 있다** — 그래서 레포 JSON은 v1.0 스냅샷이 아니다(§4).

### 3.4 범위 내·외 서비스 변경

- **범위 내 추가(7):** Amazon Aurora · Amazon Bedrock AgentCore · Kiro · Strands Agents · **Amazon Q** · Amazon SageMaker JumpStart · AWS Transform
- **범위 내 제거(1):** Amazon MemoryDB
- **범위 외 제거(7):** AWS DeepComposer · Amazon FinSpace · Amazon Honeycode · AWS IAM Identity Center · AWS Marketplace · AWS Organizations · Amazon WorkDocs

## 4. ⚠️ 공식 내부의 어긋남 6곳 / 5계열 (개정 표 ↔ 본문)

같은 가이드 안에서 **개정 표와 도메인/서비스 목록 본문이 다르게 적는 것**을 네 군데 찾았다(둘 다 2026-11-03 실측). 저작은 **본문을 정본으로** 쓰고, 이 사실을 [99-gaps.md](99-gaps.md)에 남긴다.

| # | 개정 표 | 본문 | 레포 JSON은 어느 쪽 |
|---|---|---|---|
| 1 | 범위 내 추가에 **`Amazon Q`** | 범위 내 목록에 `Amazon Q` **없음** | 1.3.4 예시에 `아마존 Q` 포함 → **개정 표 쪽** |
| 2 | 목표 1.3.4 예시에 **`Amazon Q`** 포함 | 도메인 1 본문의 1.3.4에 **없음** | 위와 같음 |
| 3 | 목표 4.2.2 예시에 **`SageMaker Cartify`** | 도메인 4 본문에 **없음**(대신 `Amazon Bedrock 모델 평가`) | **`SageMaker Clarify`** → 세 번째 표기 |
| 4 | 범위 외 제거에 DeepComposer · IAM Identity Center · Marketplace · Organizations | 범위 외 목록에 **네 개 모두 여전히 있음** | JSON에 서비스 목록 없음 |
| 5 | 목표 2.2.3 v1.1 칸에 **비용·대기 시간·모델 복잡성** 추가 | 도메인 2 본문의 2.2.3에 **그 셋이 없다** | 본문과 동일(일치 판정) |
| 6 | 목표 5.1.4 v1.1 칸이 **"신속한 삽입"** | 본문은 **"프롬프트 인젝션"** | **"신속한 삽입"** → 개정 표 쪽 |

> **읽는 방법:** 개정 표는 v1.1 게시 시점(2026-04-30)의 스냅샷이고, 본문은 그 뒤 **번역 교정·예시 정리**가 반영된 현재 상태로 보인다(5.1.4의 "신속한 삽입" → "프롬프트 인젝션"이 그 증거다). 레포 JSON(2026-06-11 수집)이 개정 표 쪽 문구를 여럿 담고 있는 것도 이 가설과 맞는다.

## 5. 레포 JSON 수정 — ✅ 전부 반영됐다 (2026-11-05)

> ✅ **6항목 전부 닫혔다.** 가드는 `flutter_app/test/aif_guide_v11_test.dart`(49건)이고 교체 근거는 [00-overview.md](00-overview.md) §3 전사다. 아래 목록은 **무엇을 했는지의 기록**이다.
>
> ⚠️ **이 절의 「불일치 17건」은 공백을 제거한 대조였다 — 바이트로 세면 19건이다.** §1이 "정규화는 공백 제거만 했다"고 적은 그대로이고, 그래서 **공백만 다른 2건이 일치로 세어졌다**: `2.1.6`(`개념 (예:` · `프로토콜 (MCP)`)과 `2.2.1`(`능력) 을`). 둘 다 기계번역 띄어쓰기 잔재다. 교체는 공식 전문을 **그대로** 넣는 것이므로 바이트 기준이 맞고, 그 잔재 패턴(` (` · `) 을` · `) 를` · `) 이` · `) 에` · 연속 공백)은 공식 전사 83건(목표 69 + 제목 14)에서 **0건**이라 금지 가드로 고정했다.
>
> ⚠️ **Task 제목 전수 대조는 이때 처음 했다** — 이 문서의 기계 대조는 **목표 본문만** 봤다. 제목 14개 중 차이는 **`2.1`의 마침표 하나**였다(공식 "…설명합니다." — 서술형 종결이라 마침표가 있고, 나머지 13개는 명사형 종결이라 없다).
>
> ⚠️ **이 파일은 한 줄 compact JSON이다**(SAA-C03.json도 같다. SOA·DEA·MLA·CLF는 2칸 들여쓰기 다중 행). diff가 `+1/−1`로만 보여 눈으로 검증되지 않으므로 ① 직렬화 왕복이 원본을 바이트 단위로 재현하는지 ② 바뀐 경로가 **정확히** 목표 19 + 제목 1 + 메타 3키인지 ③ 금지·필수 문구가 양방향으로 맞는지를 기계로 단정한 뒤 썼다. **서식 변환(pretty-print)은 하지 않았다** — 레포가 format 게이트를 쓰지 않아 서식 churn이 리뷰 불가 diff를 만든다.

1. ✅ **목표 본문을 공식 v1.1로 교체** — 바이트 기준 **19건**(§2.1의 실질 차이 9 + §2.2의 표기 8 + 공백 잔재 2). 공식에 없는 `AWS Audit Manager` · `Amazon A2I` · `SageMaker Model Monitor` · `Amazon Q` 예시를 지웠고, 함께 들어 있던 `SageMaker Clarify`도 사라졌다(4.1.7·4.2.2). 다섯 이름 모두 **0건 금지 가드**로 고정했다.
2. ✅ **서비스명 한글 음차 제거** — `아마존 베드락` → `Amazon Bedrock`, `아마존 퀵` → `Amazon Quick`, `아마존 Q`는 **삭제**(공식 본문에 없다). `아마존` 자체를 0건으로 고정했다.
3. ✅ **오표기 교정** — `AgentCore ID` → `AgentCore Identity`, `Amazon BedRock Guardrail` → `Amazon Bedrock Guardrails`, `신속한 삽입` → `프롬프트 인젝션`, `기초 모델` → `파운데이션 모델`, `환각` → `할루시네이션`, `곡선 밑부분 면적(AUC)` → `정밀도, 재현율`, `사기 탐지` → `사기 행위 탐지`. ⚠️ **`Amazon Q`와 `AgentCore ID`는 공식 문구의 접두사**(`Amazon Quick`·`AgentCore Identity`)라 `contains`로 세면 교체한 공식 문구가 스스로 걸린다 — 음성 전방탐색(`Amazon Q(?![A-Za-z])` · `AgentCore ID(?!entity)`)으로 가르고 그 가름이 되는지 대조군으로 먼저 단정했다.
4. ✅ **메타 필드 추가** — SOA-C03.json과 같은 키 순서로 `guideVersion: "1.1"` · `guidePublished: "2026-04-30"` · `officialName: "AWS Certified AI Practitioner"`. ⚠️ **`lastVerified`는 넣지 않았다** — `exam_guides/*.json` **12개 전수에서 그 키는 0건**이다(SOA-C03도 없다. 실측). 이 자격증만 넣으면 스키마가 갈리고, 검증 시점은 이 문서와 가드 테스트가 들고 있다. 교체 후 AIF의 키 순서는 **SOA-C03과 완전히 같다**(`code · slug · guideVersion · guidePublished · officialName · overview · domains · sourceUrl`) — 메타 3키를 가진 가이드는 이제 그 둘뿐이다.
5. ✅ **`durationMinutes: 90` 확정** — 지우지 않았다. [99-gaps.md](99-gaps.md) G-01이 해소돼 값이 옳음이 확인됐다(**가이드 본문에는 없고** 공식 인증 페이지의 "Exam duration 90 minutes"가 근거다). 가드가 `채점 50 + 비채점 15 = 65`와 함께 고정한다.
6. ✅ **`skills: []` 유지** — SOA-C03.json이 **반대로** `knowledge: []`를 비워 두므로 빈 배열을 남기는 것이 이 레포의 관례이고, `ExamTask.fromJson`이 양쪽 다 `const []`로 기본값을 준다. 키를 없애면 모델은 견디지만 자격증마다 구조가 갈린다. 가드가 "Task마다 `knowledge`는 비지 않고 `skills`는 비어 있다"를 14 Task 전수로 단정한다.

## 6. 출처

| 제목 | URL | 조회일 |
|---|---|---|
| 개정 (AIF-C01) | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/ai-practitioner-01/aif-01-revisions.html | 2026-11-03 |
| 범위 내 AWS 서비스 | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/ai-practitioner-01/aif-01-in-scope-services.html | 2026-11-03 |
| 범위 외 AWS 서비스 | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/ai-practitioner-01/aif-01-out-of-scope-services.html | 2026-11-03 |
| 도메인 1~5 본문 | [00-overview.md](00-overview.md) §8의 URL 5건 | 2026-11-03 |
| 레포 가이드 JSON | `flutter_app/assets/exam_guides/AIF-C01.json`(2026-06-11 수집) | 2026-11-03 |
