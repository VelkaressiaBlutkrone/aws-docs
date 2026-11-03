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

## 5. 레포 JSON 수정 제안

> ⚠️ **이 PR에서는 JSON을 고치지 않는다**(조사 단계). 저작 PR에서 아래를 한 번에 반영한다.

1. **목표 본문 69건을 공식 v1.1 본문으로 교체** — 특히 §2.1의 실질 차이 9건. 공식에 없는 `AWS Audit Manager` · `Amazon A2I` · `SageMaker Model Monitor` · `Amazon Q` 예시를 **지운다**(범위 내 목록에도 없다).
2. **서비스명 한글 음차를 제거** — `아마존 베드락` → `Amazon Bedrock`, `아마존 퀵` → `Amazon Quick`. 레포 전체가 영문 서비스명을 쓰므로 이 둘은 명백한 기계번역 잔재다.
3. **오표기 교정** — `AgentCore ID` → `AgentCore Identity`, `Amazon BedRock Guardrail` → `Amazon Bedrock Guardrails`, `신속한 삽입` → `프롬프트 인젝션`, `기초 모델` → `파운데이션 모델`, `환각` → `할루시네이션`.
4. **메타 필드 추가** — SOA-C03.json과 같은 스키마로 `guideVersion: 1.1` · `guidePublished: "2026-04-30"` · `officialName` · `lastVerified: "2026-11-03"`.
5. **`durationMinutes: 90`의 출처를 확정하거나 제거** — [99-gaps.md](99-gaps.md) G-01.
6. **`skills` 빈 배열 처리 방침 결정** — AIF 가이드는 Task 아래 "목표"만 두고 **Skill 계층이 없다**(DVA·SOA와 구조가 다르다). 빈 배열을 유지할지 키를 없앨지는 다른 자격증 JSON 스키마와 함께 판정한다.

## 6. 출처

| 제목 | URL | 조회일 |
|---|---|---|
| 개정 (AIF-C01) | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/ai-practitioner-01/aif-01-revisions.html | 2026-11-03 |
| 범위 내 AWS 서비스 | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/ai-practitioner-01/aif-01-in-scope-services.html | 2026-11-03 |
| 범위 외 AWS 서비스 | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/ai-practitioner-01/aif-01-out-of-scope-services.html | 2026-11-03 |
| 도메인 1~5 본문 | [00-overview.md](00-overview.md) §8의 URL 5건 | 2026-11-03 |
| 레포 가이드 JSON | `flutter_app/assets/exam_guides/AIF-C01.json`(2026-06-11 수집) | 2026-11-03 |
