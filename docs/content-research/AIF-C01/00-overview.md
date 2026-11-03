---
생성: 2026-11-03
목적: AIF-C01 학습문서 저작을 위한 공식 시험 가이드 전수 실측 + 레포 `exam_guides/AIF-C01.json` 대조
공식 가이드: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/ai-practitioner-01/ai-practitioner-01.html (조회 2026-11-03)
가이드 버전: **1.1 (2026-04-30 게시)**
---

# AIF-C01 — 공식 가이드 실측 개요

> 이 문서는 **공식 가이드를 직접 읽어 적은 것**이다. 수치·문구는 공식 한국어판(`ko_kr`) 본문에서 그대로 옮겼고, 추측은 넣지 않았다. 확인되지 않은 것은 [99-gaps.md](99-gaps.md)에 있다.

## 1. 시험 메타 (공식 본문 실측)

| 항목 | 공식 값 | 비고 |
|---|---|---|
| 공식 명칭 | AWS Certified AI Practitioner (AIF-C01) | 한국어판 제목도 같은 표기 |
| 레벨 | Foundational | |
| 가이드 버전 | **1.1** (게시 2026-04-30) | 1.0은 2026-03-26 |
| 채점 문항 | **50** | "시험에는 점수에 반영되는 50개의 문항이 포함되어 있습니다" |
| 비채점 문항 | **15** | 시험에서 식별되지 않음 |
| 합격 최소 점수 | **700** | 변환 점수 100~1,000 |
| 채점 모델 | 보상 점수 모델 | "각 섹션에서 합격 점수를 얻을 필요는 없으며, 전체 시험에만 합격" |
| 시험 시간 | **90분** | ⚠️ **가이드 본문에는 없다** — 공식 인증 페이지의 "Exam duration 90 minutes"가 근거다(§8). 레포 JSON의 `durationMinutes: 90`이 옳다 |
| 총 문항(응시 화면) | **65** | 인증 페이지 "Exam format 65 questions" = 채점 50 + 비채점 15 |
| 응시 비용 | 100 USD | 인증 페이지 |
| 유효 기간 | 3년 | 인증 페이지. MLA-C01 취득으로 자동 재인증 가능 |
| 한국어 응시 | **가능** | 인증 페이지 제공 언어 목록에 Korean. ⚠️ 이탈리아어·독일어는 2026-10-15 이후 종료 |
| 대상 응시자 | "최대 6개월 동안 AWS의 AI/ML 기술을 접한 경험" | "AI/ML 솔루션을 사용해야 하지만, 반드시 구축할 필요는 없다" |

### 문항 유형 4종 (공식 본문 전수)

1. **선다형** — 정답 1개 + 오답 3개
2. **복수 응답형** — 5개 이상의 응답 중 정답 2개 이상, **모두 선택해야 득점**
3. **순서 배열** — 3~5개 응답을 **올바른 순서로 배열**해야 득점
4. **매칭형** — 3~7개 프롬프트와 응답을 **모두 정확히 매칭**해야 득점

> ⚠️ **이 레포의 모의고사 러너는 선다형(단일 정답 4지선다)만 렌더한다.** 순서 배열·매칭형·복수 응답형은 현재 문항 스키마(`options` 4개 + `correct` 단일 인덱스)로 표현할 수 없다. 저작 단계에서 "출제 형식"을 어떻게 다룰지 판정이 필요하다 — [99-gaps.md](99-gaps.md) G-02.

## 2. 도메인 비중과 Task 수 (공식 본문 실측)

| 도메인 | 공식 한국어 이름 | 비중 | Task 수 |
|---|---|---:|---:|
| 1 | AI 및 ML의 기초 | **20%** | 3 |
| 2 | GenAI의 기초 | **24%** | 3 |
| 3 | 파운데이션 모델의 적용 | **28%** | 4 |
| 4 | 책임 있는 AI에 대한 가이드라인 | **14%** | 2 |
| 5 | AI 솔루션의 보안, 규정 준수 및 거버넌스 | **14%** | 2 |
| | **합계** | **100%** | **14** |

- 도메인 3이 최대 비중(28%)이고 Task도 4개로 가장 많다.
- ⚠️ **도메인 3 이름이 공식 한 페이지 안에서 갈린다**: 도메인 페이지 제목·Topics는 "파운데이션 모델의 **적용**"인데 「내용 개요」 목록은 "파운데이션 모델 **적용**"으로 적는다(조사 `의`). DVA-C03에서 같은 종류의 분기를 겪었으므로 **이름은 도메인 페이지 제목을 정본으로** 쓴다 — [99-gaps.md](99-gaps.md) G-03.
- 비중 합이 100%이고 레포 JSON의 `weightPct`와 **일치**한다(§5).

## 3. Task·목표 전수 (공식 v1.1 한국어 본문)

> 공식 본문은 각 Task 아래 "목표:" 뒤에 불릿만 적고 **번호를 표기하지 않는다.** 아래 번호(1.1.1 …)는 공식 **개정 페이지**가 목표를 그렇게 부르므로(예: "목표 1.1.1") 같은 규칙으로 **본문 순서대로** 매긴 것이다.

### 도메인 1 — AI 및 ML의 기초 (20%)

**작업 설명 1.1: 기본 AI 개념과 용어 설명** (목표 5)

- 1.1.1 기본 AI 용어(예: AI, ML, 딥 러닝, 신경망, 컴퓨터 비전, 자연어 처리(NLP), 모델, 알고리즘, 훈련 및 추론, 편향, 공정성, 적합성, 대규모 언어 모델(LLM), 생성형 AI(GenAI), 에이전틱 AI) 정의
- 1.1.2 AI, ML, GenAI, 딥 러닝, 에이전틱 AI 간의 유사점과 차이점 설명
- 1.1.3 다양한 유형의 추론을 설명(예: 배치, 실시간, 비동기, 서버리스)
- 1.1.4 AI 모델의 다양한 데이터 유형 설명(예: 레이블이 지정된 데이터와 레이블이 지정되지 않은 데이터, 테이블 형식, 시계열, 이미지, 텍스트, 정형 및 비정형)
- 1.1.5 다양한 유형의 AI/ML 학습 설명(예: 지도 학습, 비지도 학습, 강화 학습 방법)

**작업 설명 1.2: AI의 실제 사용 사례 파악** (목표 6)

- 1.2.1 AI/ML이 가치를 제공할 수 있는 적용 사례 이해(예: 인간의 의사 결정 지원, 솔루션 확장성, 자동화)
- 1.2.2 AI/ML 솔루션이 적절하지 않은 경우 판단(예: 비용-이점 분석, 예측 대신 특정 결과가 필요한 상황)
- 1.2.3 특정 사용 사례에 적합한 AI/ML 기법 선택(예: 회귀, 분류, 클러스터링)
- 1.2.4 실제 AI 애플리케이션의 예시 식별(예: 컴퓨터 비전, NLP, 음성 인식, 추천 시스템, 사기 행위 탐지, 예측, 지식 기반, 에이전틱 AI)
- 1.2.5 AWS 관리형 AI/ML 서비스의 기능 설명(예: Amazon SageMaker AI, Amazon Transcribe, Amazon Translate, Amazon Comprehend, Amazon Lex, Amazon Polly)
- 1.2.6 기존 ML 모델 또는 파운데이션 모델(FM)이 특정 사용 사례에 적합한 경우 식별(예: 규제 문제, 설명 가능성 요구 사항, 운영 제약 조건)

**작업 설명 1.3: ML 개발 수명 주기 설명** (목표 6)

- 1.3.1 AI/ML 파이프라인의 구성 요소 설명 및 구분
- 1.3.2 ML 모델의 소스 설명(예: 사전 훈련된 오픈 소스 모델, 사용자 지정 모델 훈련)
- 1.3.3 프로덕션 환경에서 모델을 사용하는 방법 설명(예: 관리형 API 서비스, 자체 호스팅 API)
- 1.3.4 AI/ML 파이프라인의 각 단계에 대한 관련 AWS 서비스 및 기능 식별(예: Amazon Bedrock, Amazon Quick, Kiro, SageMaker AI)
- 1.3.5 ML 운영(MLOps)의 기본 개념 설명(예: 실험, 반복 가능한 프로세스, 확장 가능한 시스템, 기술 부채 관리, 프로덕션 준비 상태 달성, 모델 모니터링, 모델 재훈련)
- 1.3.6 모델을 평가하기 위한 모델 성능 지표 설명(예: 정확도, 정밀도, 재현율, F1 점수) 및 비즈니스 지표(예: 사용자당 비용, 개발 비용, 고객 피드백, 투자 수익률(ROI))

### 도메인 2 — GenAI의 기초 (24%)

**작업 설명 2.1: 생성형 AI(Gen AI)의 기본 개념을 설명합니다.** (목표 6)

- 2.1.1 GenAI의 기본적인 개념(예: 토큰, 청킹, 임베딩, 벡터, 프롬프트 엔지니어링, 트랜스포머 기반 LLM, 파운데이션 모델(FM), 멀티모달 모델, 확산 모델)을 설명
- 2.1.2 GenAI 모델의 잠재적 사용 사례를 파악(예: 이미지, 비디오 및 오디오 생성, 요약, AI 어시스턴트, 번역, 코드 생성, 고객 서비스 에이전트, 검색, 추천 엔진)
- 2.1.3 파운데이션 모델 수명 주기 설명(예: 데이터 선택, 모델 선택, 사전 훈련, 미세 조정, 평가, 배포, 피드백)
- 2.1.4 추론을 위해 토큰 기반 가격 책정 모델과 비용 및 성능에 미치는 영향을 설명
- 2.1.5 FM 애플리케이션에서 컨텍스트 엔지니어링의 역할을 설명
- 2.1.6 기본 에이전트 AI 개념(예: 복잡한 AI 애플리케이션을 위한 다중 에이전트 시스템 패턴, 모델 컨텍스트 프로토콜(MCP) 및 에이전트를 외부 시스템에 연결하는 역할, 다중 에이전트 통신 패턴, 메모리 관리, 도구 사용, 워크플로 오케스트레이션)을 정의

**작업 설명 2.2: 비즈니스 문제 해결을 위한 GenAI의 기능과 한계 이해** (목표 4)

- 2.2.1 GenAI의 장점(예: 적응성, 반응성, 대화 기능, 콘텐츠 생성 능력)을 설명
- 2.2.2 GenAI 솔루션의 단점 파악(예: 할루시네이션, 해석 가능성, 부정확성, 비결정성)
- 2.2.3 GenAI 모델을 선택할 때 고려할 요소 파악(예: 모델 유형, 성능 요구 사항, 기능, 제약 조건, 규정 준수)
- 2.2.4 GenAI 애플리케이션의 비즈니스 가치와 지표 결정(예: 크로스 도메인 성능, 효율성, 전환율, 사용자당 평균 수익, 정확도, 고객 평생 가치)

**작업 설명 2.3: GenAI 애플리케이션을 구축하기 위한 AWS 인프라 및 기술 설명** (목표 4)

- 2.3.1 GenAI 애플리케이션 개발을 위한 AWS 서비스 및 기능 식별(예: Amazon Bedrock, Amazon SageMaker AI, SageMaker JumpStart, Amazon Quick, Kiro, Strands Agents, Amazon Bedrock AgentCore)
- 2.3.2 AWS GenAI 서비스를 사용하여 애플리케이션을 구축할 때의 이점 설명(예: 접근성, 낮은 진입 장벽, 효율성, 비용 효과, 출시 소요 시간, 비즈니스 목표 달성 능력)
- 2.3.3 GenAI 애플리케이션을 위한 AWS 인프라의 이점 설명(예: 보안, 규정 준수, 책임, 안전)
- 2.3.4 AWS GenAI 서비스의 비용 절충점 설명(예: 응답성, 가용성, 중복성, 성능, 리전 적용 범위, 토큰 기반 요금, 프로비저닝 처리량, 사용자 지정 모델)

### 도메인 3 — 파운데이션 모델의 적용 (28%)

**작업 설명 3.1: 파운데이션 모델(FM)을 사용하는 애플리케이션의 설계 고려 사항 설명** (목표 6)

- 3.1.1 사전 훈련된 모델을 선택하기 위한 선택 기준 설명(예: 비용, 모달리티, 지연 시간, 다국어, 모델 크기, 모델 복잡도, 사용자 지정, 입력/출력 길이, 프롬프트 캐싱)
- 3.1.2 추론 파라미터가 모델 응답에 미치는 영향 설명(예: 온도, 입력/출력 길이)
- 3.1.3 검색 증강 생성(RAG)을 정의하고 비즈니스에서의 RAG 적용 사례 설명(예: Amazon Bedrock Knowledge Base)
- 3.1.4 벡터 데이터베이스 내에 임베딩을 저장하는 데 도움이 되는 AWS 서비스 파악(예: Amazon OpenSearch Service, Amazon Aurora, Amazon Neptune, Amazon RDS for PostgreSQL)
- 3.1.5 FM 사용자 지정에 대한 다양한 접근 방식의 비용 절충점 설명(예: 사전 훈련, 미세 조정, 컨텍스트 내 학습, RAG, 모델 증류)
- 3.1.6 AI 에이전트의 역할을 정의하고 AI 에이전트의 비즈니스 애플리케이션을 설명

**작업 설명 3.2: 효과적인 프롬프트 엔지니어링 기법 선택** (목표 5)

- 3.2.1 프롬프트 엔지니어링의 개념과 구성(예: 컨텍스트, 명령, 네거티브 프롬프트, 모델 잠재 공간)을 설명
- 3.2.2 프롬프트 엔지니어링을 위한 기법을 정의(예: 생각의 사슬, 제로샷, 싱글샷, 퓨샷, 프롬프트 템플릿)
- 3.2.3 프롬프트 엔지니어링의 이점과 모범 사례 파악 및 설명(예: 응답 품질 개선, 실험, 가드레일, 발견, 구체성 및 간결성, 여러 코멘트 사용)
- 3.2.4 프롬프트 엔지니어링의 잠재적 위험과 한계 정의(예: 노출, 중독, 하이재킹, 탈옥)
- 3.2.5 Amazon Bedrock 프롬프트 관리를 사용하는 프롬프트 버전 관리 및 관리 전략을 설명

**작업 설명 3.3: 파운데이션 모델의 훈련과 미세 조정 프로세스 설명** (목표 3)

- 3.3.1 FM 훈련의 주요 요소 설명(예: 사전 훈련, 미세 조정, 지속적인 사전 훈련, 증류)
- 3.3.2 FM을 미세 조정하는 방법 정의(예: 명령 튜닝, 특정 도메인에 맞춰 모델 조정, 전이 학습, 지속적인 사전 훈련)
- 3.3.3 FM을 미세 조정하기 위해 데이터를 준비하는 방법 설명(예: 데이터 큐레이션, 거버넌스, 크기, 레이블 지정, 대표성, 사용자 피드백을 통한 강화 학습(RL))

**작업 설명 3.4: FM 성능을 평가하는 방법 설명** (목표 5)

- 3.4.1 FM 성능을 평가하기 위한 접근 방식 결정(예: 인간 평가, 벤치마크 데이터세트, Amazon Bedrock 모델 평가)
- 3.4.2 FM 성과를 평가하기 위한 관련 지표 파악(예: Recall-Oriented Understudy for Gisting Evaluation(ROUGE), Bilingual Evaluation Understudy(BLEU), BERTScore, LLM-as-a-judge)
- 3.4.3 FM이 비즈니스 목표에 효과적으로 부합하는지 판단(예: 생산성, 사용자 참여, 태스크 엔지니어링)
- 3.4.4 FM(예: RAG, 에이전트, 워크플로)로 구축된 애플리케이션의 성능을 평가하는 접근 방식 파악
- 3.4.5 AI 애플리케이션의 비즈니스 목표 조정 지표(예: 작업 완료율, 사용자 만족도, 상호 작용당 비용)를 식별

### 도메인 4 — 책임 있는 AI에 대한 가이드라인 (14%)

**작업 설명 4.1: 책임감 있는 AI 시스템 개발 설명** (목표 7)

- 4.1.1 책임 있는 AI의 특징 파악(예: 편향성, 공정성, 포용성, 견고성, 안전성, 진실성)
- 4.1.2 도구(예: Amazon Bedrock Guardrails)를 사용하여 책임 있는 AI의 특징을 파악하는 방법 설명
- 4.1.3 모델을 선택할 때의 책임 있는 관행 정의(예: 환경적 고려 사항, 지속 가능성)
- 4.1.4 생성형 AI(GenAI) 사용에 따른 법적 위험 식별(예: 지적 재산권 침해 클레임, 편향된 모델 출력, 고객 신뢰 상실, 최종 사용자 위험, 할루시네이션)
- 4.1.5 데이터세트의 특징 파악(예: 포용성, 다양성, 큐레이팅된 데이터 소스, 균형 잡힌 데이터세트)
- 4.1.6 편향과 변동의 영향 설명(예: 인구통계학적 그룹에 미치는 영향, 부정확성, 과적합, 과소적합)
- 4.1.7 편향, 신뢰성 및 진실성을 감지하고 모니터링하는 도구 설명(예: 라벨 품질 분석, 인간 감사, 하위 그룹 분석)

**작업 설명 4.2: 투명하고 설명 가능한 모델의 중요성 이해** (목표 4)

- 4.2.1 투명하고 설명 가능한 모델과 투명하지 않고 설명 불가능한 모델의 차이점 설명
- 4.2.2 투명하고 설명 가능한 모델을 식별하는 도구를 설명(예: Amazon SageMaker Model Cards, Amazon Bedrock 모델 평가, 오픈 소스 모델, 데이터, 라이선스)
- 4.2.3 모델 안전성과 투명성 간의 절충점 파악(예: 해석 가능성과 성능 측정)
- 4.2.4 설명 가능한 AI를 위한 인간 중심 설계 원칙 설명(예: 사용자 피드백 메커니즘, AI 의사 결정 투명성)

### 도메인 5 — AI 솔루션의 보안, 규정 준수 및 거버넌스 (14%)

**작업 설명 5.1: AI 시스템의 보안 방법 설명** (목표 5)

- 5.1.1 AI 시스템 보안을 위한 AWS 서비스 및 기능 식별(예: IAM 역할, 정책 및 권한, 암호화, Amazon Macie, AWS PrivateLink, AWS 공동 책임 모델, Amazon Bedrock AgentCore Identity, AgentCore의 정책, Amazon Bedrock Guardrails)
- 5.1.2 소스 인용의 개념과 데이터 출처 문서화 설명(예: 데이터 계보, 데이터 카탈로그화, Amazon SageMaker Model Cards)
- 5.1.3 보안 데이터 엔지니어링의 모범 사례 설명(예: 데이터 품질 평가, 프라이버시 강화 기술 구현, 데이터 액세스 제어, 데이터 무결성)
- 5.1.4 AI 시스템의 보안 및 개인 정보 보호 고려 사항 설명(예: 애플리케이션 보안, 위협 탐지, 취약성 관리, 인프라 보호, 프롬프트 인젝션, 저장 및 전송 중 암호화, 데이터 유출 방지, 출력 필터링 및 검증, AI 상호 작용에 대한 감사 추적 및 로깅 요구 사항, 독성)
- 5.1.5 출력 정확도를 개선하기 위한 할루시네이션 감지 방법 및 접지 기법 설명(예: 검색 증강 생성(RAG) 근거 기반, 출력 유효성 검사, 신뢰도 점수)

**작업 설명 5.2: AI 시스템의 거버넌스 및 규정 준수 이해** (목표 3)

- 5.2.1 거버넌스 및 규정 준수를 지원하는 AWS 서비스 및 기능 파악(예: AWS Config, Amazon Inspector, AWS Artifact, AWS CloudTrail, AWS Trusted Advisor)
- 5.2.2 데이터 거버넌스 전략 설명(예: 데이터 수명 주기, 로깅, 레지던시, 모니터링, 관찰, 보존)
- 5.2.3 거버넌스 프로토콜을 준수하기 위한 프로세스 설명(예: 정책, 검토 주기, 검토 전략, 생성형 AI Security Scoping Matrix와 같은 거버넌스 프레임워크, 투명성 표준, 팀 교육 요구 사항)

### 목표 수 집계

| 도메인 | Task별 목표 수 | 합 |
|---|---|---:|
| 1 | 1.1=5 · 1.2=6 · 1.3=6 | 17 |
| 2 | 2.1=6 · 2.2=4 · 2.3=4 | 14 |
| 3 | 3.1=6 · 3.2=5 · 3.3=3 · 3.4=5 | 19 |
| 4 | 4.1=7 · 4.2=4 | 11 |
| 5 | 5.1=5 · 5.2=3 | 8 |
| | **합계** | **69** |

## 4. 범위 내 / 범위 외 서비스 (공식 전수)

> 두 목록 모두 공식이 **"이 목록은 전체 목록이 아니며 변경될 수 있습니다"**라고 적는다. 따라서 **"목록에 없다" ≠ "범위 밖"**이다(이 레포의 DVA-C03 트랙에서 확립된 규율).

### 4.1 범위 내 (11개 범주)

| 범주 | 서비스 |
|---|---|
| 분석 | AWS Data Exchange · Amazon EMR · AWS Glue · AWS Glue DataBrew · AWS Lake Formation · Amazon OpenSearch Service · **Amazon Quick** · Amazon Redshift |
| 클라우드 재무 관리 | AWS Budgets · AWS Cost Explorer |
| 컴퓨팅 | Amazon EC2 · AWS Lambda |
| 컨테이너 | Amazon ECS · Amazon EKS |
| 데이터베이스 | **Amazon Aurora** · Amazon DocumentDB(MongoDB 호환) · Amazon DynamoDB · Amazon ElastiCache · Amazon Neptune · Amazon RDS |
| 개발자 도구 | **Kiro** · **Strands Agents** |
| 기계 학습 | Amazon Bedrock · **Amazon Bedrock AgentCore** · Amazon Comprehend · Amazon Lex · Amazon Nova · Amazon Personalize · Amazon Polly · Amazon Rekognition · Amazon SageMaker AI · **Amazon SageMaker JumpStart** · Amazon Textract · Amazon Transcribe · Amazon Translate · **AWS Transform** |
| 관리 및 거버넌스 | AWS CloudTrail · Amazon CloudWatch · AWS Config · AWS Trusted Advisor · AWS Well-Architected Tool |
| 네트워킹 및 콘텐츠 전송 | Amazon CloudFront · Amazon VPC |
| 보안, ID 및 규정 준수 | AWS Artifact · AWS IAM · Amazon Inspector · AWS KMS · Amazon Macie · AWS Secrets Manager |
| 스토리지 | Amazon S3 · Amazon S3 Glacier |

**굵게** 표시한 7개가 v1.1에서 추가된 것이다(§6).

### 4.2 범위 외 (19개 범주)

| 범주 | 서비스 |
|---|---|
| 분석 | AWS Clean Rooms · Amazon CloudSearch · Amazon MSK |
| 애플리케이션 통합 | Amazon AppFlow · Amazon MQ · Amazon SWF |
| 비즈니스 애플리케이션 | Amazon Chime · Amazon Pinpoint · Amazon SES · AWS Supply Chain · AWS Wickr |
| 클라우드 재무 관리 | AWS Application Cost Profiler · AWS Billing Conductor · AWS Marketplace |
| 컴퓨팅 | AWS App Runner · AWS Elastic Beanstalk · EC2 Image Builder · Amazon Lightsail |
| 컨테이너 | Red Hat OpenShift Service on AWS(ROSA) |
| 고객 지원 | AWS IQ · AWS Managed Services(AMS) · AWS re:Post Private · AWS Support |
| 데이터베이스 | Amazon Keyspaces · Amazon QLDB · Amazon Timestream |
| 개발자 도구 | AWS AppConfig · AWS Application Composer · AWS CloudShell · Amazon CodeCatalyst · AWS CodeStar · AWS Fault Injection Service · AWS X-Ray |
| 최종 사용자 컴퓨팅 | Amazon AppStream 2.0 · Amazon WorkSpaces · Amazon WorkSpaces Thin Client · Amazon WorkSpaces Web |
| 프런트엔드 웹 및 모바일 | AWS Amplify · AWS Device Farm · Amazon Location Service |
| 사물 인터넷(IoT) | AWS IoT Analytics · AWS IoT Core · AWS IoT Device Defender · AWS IoT Device Management · AWS IoT Events · AWS IoT FleetWise · FreeRTOS · AWS IoT Greengrass · AWS IoT 1-Click · AWS IoT RoboRunner · AWS IoT SiteWise · AWS IoT TwinMaker |
| 기계 학습 | AWS DeepComposer · AWS HealthImaging · AWS HealthOmics · Amazon Monitron · AWS Panorama |
| 관리 및 거버넌스 | AWS Control Tower · AWS Health Dashboard · AWS Launch Wizard · AWS License Manager · Amazon Managed Grafana · Amazon Managed Service for Prometheus · AWS OpsWorks · AWS Organizations · AWS Proton · AWS Resilience Hub · AWS Resource Explorer · AWS Resource Groups · AWS Systems Manager Incident Manager · AWS Service Catalog · Service Quotas · AWS Telco Network Builder · AWS User Notifications |
| 미디어 | Amazon Elastic Transcoder · AWS Elemental MediaConnect · MediaConvert · MediaLive · MediaPackage · MediaStore · MediaTailor · Amazon IVS · Amazon Nimble Studio |
| 마이그레이션 및 전송 | AWS Application Discovery Service · AWS Application Migration Service · AWS DMS · AWS DataSync · AWS Mainframe Modernization · AWS Migration Hub · AWS Transfer Family |
| 네트워킹 및 콘텐츠 전송 | AWS App Mesh · AWS Cloud Map · AWS Direct Connect · AWS Global Accelerator · AWS Private 5G · Amazon Route 53 · Amazon Route 53 ARC · Amazon VPC IPAM |
| 보안, ID 및 규정 준수 | AWS ACM · AWS CloudHSM · Amazon Cognito · Amazon Detective · AWS Directory Service · AWS Firewall Manager · Amazon GuardDuty · AWS IAM Identity Center · AWS Payment Cryptography · AWS Private CA · AWS RAM · AWS Security Hub · Amazon Security Lake · AWS Shield · AWS Signer · Amazon Verified Permissions · AWS WAF |
| 스토리지 | AWS Backup · AWS Elastic Disaster Recovery |

> ⚠️ **AWS DeepComposer는 v1.1에서 "범위 외 목록에서 제거"된 것으로 개정 표가 적는데, 범위 외 목록 본문에는 여전히 있다**(둘 다 2026-11-03 실측). 이 어긋남은 [99-gaps.md](99-gaps.md) G-06으로 넘긴다.
> ⚠️ 저작 시 자주 쓰게 될 서비스 중 **Amazon Cognito · AWS Organizations · AWS IAM Identity Center · Amazon GuardDuty · AWS Security Hub · Amazon Route 53 · AWS X-Ray는 범위 외**다. 다른 자격증 학습문서에서 가져오면 안 된다.

## 5. 레포 `exam_guides/AIF-C01.json` 대조

> 레포 JSON은 2026-06-11에 수집됐다(파일 타임스탬프). 기계 대조 결과는 [97-repo-json-diff.md](97-repo-json-diff.md)가 정본이고, 아래는 요약이다.

### 일치하는 것

| 항목 | 레포 JSON | 공식 v1.1 |
|---|---|---|
| 도메인 수 | 5 | 5 |
| 도메인 비중 | 20 / 24 / 28 / 14 / 14 | 20 / 24 / 28 / 14 / 14 |
| Task 수 | 3 / 3 / 4 / 2 / 2 = 14 | 3 / 3 / 4 / 2 / 2 = 14 |
| 목표 수 | 17 / 14 / 19 / 11 / 8 = 69 | 17 / 14 / 19 / 11 / 8 = 69 |
| 합격선 · 채점 · 비채점 | 700 · 50 · 15 | 700 · 50 · 15 |
| 도메인 이름 | 공식 한국어와 동일 | — |

구조는 **v1.1과 같다**(v1.0에서 추가된 목표 7개가 레포 JSON에도 있다 — 예: `1.2.6`).

### 어긋나는 것

1. **목표 본문 69건 중 17건이 공식 v1.1 본문과 다르다**(기계 대조 — 번호 집합·순서 일치를 대조군으로 먼저 확인했다). 레포 JSON은 v1.0 스냅샷이 **아니고**, ① v1.0 잔재(`1.1.1`에 생성형 AI·에이전틱 AI 누락, `1.3.6`에 v1.0 지표 AUC) ② **공식 개정 표에만 있는 문구**(`Amazon Q`, "신속한 삽입") ③ **공식에 없는 서비스 예시**(`AWS Audit Manager`·`Amazon A2I`·`SageMaker Model Monitor`) ④ 기계번역 잔재(`아마존 베드락`·`아마존 퀵`)가 섞인 **하이브리드**다. 실질 차이 9건 · 문체 차이 8건의 전수 표는 [97-repo-json-diff.md](97-repo-json-diff.md) §2.
2. **`guideVersion`·`guidePublished`·`lastVerified` 필드가 없다.** SOA-C03.json은 `guideVersion: 1.1`·`guidePublished`·`officialName`을 갖고 있어 **스키마가 자격증마다 다르다.**
3. **`skills` 배열이 전부 비어 있다**(`knowledge`만 채워져 있다). MLA·SOA 등 다른 자격증 JSON과의 스키마 비교가 필요하다.
4. **`durationMinutes: 90`의 근거가 가이드 본문에 없다**([99-gaps.md](99-gaps.md) G-01).
5. **범위 내·범위 외 서비스 목록이 JSON에 없다**(키는 `code`·`slug`·`overview`·`domains`·`sourceUrl`뿐).

## 6. v1.0 → v1.1 변경 (2026-04-30)

전문은 [97-repo-json-diff.md](97-repo-json-diff.md) §2에 옮겼다. 저작에 영향을 주는 요점만:

- **목표 본문 변경 19건 · 목표 추가 7건**(1.2.6 · 2.1.4 · 2.1.5 · 2.1.6 · 3.2.5 · 3.4.5 · 5.1.5). 삭제된 목표는 없다.
- 추가된 7개의 성격이 이 시험의 방향이다: **토큰 기반 요금 · 컨텍스트 엔지니어링 · 에이전틱 AI/MCP · 프롬프트 버전 관리 · 비즈니스 목표 지표 · 할루시네이션 접지**.
- **범위 내 추가 7**: Amazon Aurora · Amazon Bedrock AgentCore · Kiro · Strands Agents · Amazon Q · Amazon SageMaker JumpStart · AWS Transform
- **범위 내 제거 1**: Amazon MemoryDB
- **범위 외 제거 7**: AWS DeepComposer · Amazon FinSpace · Amazon Honeycode · AWS IAM Identity Center · AWS Marketplace · AWS Organizations · Amazon WorkDocs
- ⚠️ 개정 표가 **범위 내 추가로 적은 `Amazon Q`가 범위 내 목록 본문에는 없고**, **범위 외 제거로 적은 4개(DeepComposer · IAM Identity Center · Marketplace · Organizations)는 범위 외 목록 본문에 여전히 있다**. 개정 표와 목록 본문이 어긋난다 — [99-gaps.md](99-gaps.md) G-06.

## 7. 깊이 조사 노트

가이드가 새로 넣은 영역은 레포에 선례가 없어 별도 노트로 뺐다.

- [94-agentic-ai-and-mcp.md](94-agentic-ai-and-mcp.md) — 에이전틱 AI · MCP · Bedrock Agents/AgentCore · Strands Agents
- [95-aws-ai-tools-naming.md](95-aws-ai-tools-naming.md) — Amazon Quick · Kiro · AWS Transform · Amazon Nova · Amazon Q의 정체와 표기
- [96-fm-cost-eval-guardrails.md](96-fm-cost-eval-guardrails.md) — 토큰 요금 · 프롬프트 캐싱 · 모델 증류 · 평가 · Guardrails

## 8. 출처

| 제목 | URL | 조회일 |
|---|---|---|
| AWS Certified AI Practitioner(AIF-C01) | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/ai-practitioner-01/ai-practitioner-01.html | 2026-11-03 |
| 콘텐츠 도메인 1: AI 및 ML의 기초 | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/ai-practitioner-01/ai-practitioner-01-domain1.html | 2026-11-03 |
| 콘텐츠 도메인 2: GenAI의 기초 | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/ai-practitioner-01/ai-practitioner-01-domain2.html | 2026-11-03 |
| 콘텐츠 도메인 3: 파운데이션 모델의 적용 | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/ai-practitioner-01/ai-practitioner-01-domain3.html | 2026-11-03 |
| 콘텐츠 도메인 4: 책임 있는 AI에 대한 가이드라인 | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/ai-practitioner-01/ai-practitioner-01-domain4.html | 2026-11-03 |
| 콘텐츠 도메인 5: AI 솔루션의 보안, 규정 준수 및 거버넌스 | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/ai-practitioner-01/ai-practitioner-01-domain5.html | 2026-11-03 |
| 범위 내 AWS 서비스 | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/ai-practitioner-01/aif-01-in-scope-services.html | 2026-11-03 |
| 범위 외 AWS 서비스 | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/ai-practitioner-01/aif-01-out-of-scope-services.html | 2026-11-03 |
| 개정 | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/ai-practitioner-01/aif-01-revisions.html | 2026-11-03 |
| AWS Certified AI Practitioner (인증 페이지 — 시험 시간·문항 수·비용·언어의 정본) | https://aws.amazon.com/certification/certified-ai-practitioner/ | 2026-11-03 |

> ⚠️ 위 `.html` URL은 모두 같은 경로의 `.md`로 리다이렉트된다(AWS 문서 사이트의 정상 동작, 2026-11-03 실측). 콘텐츠·앵커는 동일하므로 레포에는 `.html`을 쓴다.
