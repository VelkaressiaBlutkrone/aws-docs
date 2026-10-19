# MLA-C01 → MLA-C02 델타 (97-c02-delta)

- **조회일**: 2026-10-17
- **성격**: C01 12개 Task 학습문서 말미에 붙일 'C02 추가분 부록'의 근거 지도. 출처는 AWS 공식 문서(영문·한국어)이며, 표의 항목은 공식 원문을 그대로 옮겼다(기계 대조 완료).
- **작성 경위**: 공용 `docs/content-research/README.md` 가 이 파일(`MLA-C01/97-c02-delta.md`)을 MLA 세션 산출물로 명시했다(최초 지시문에는 없던 추가분). 내용은 README가 정한 범위 — C01↔C02 대응표·추가 스킬·신규 in-scope 서비스·언어별 일정 — 로 한정했다.
- **범위 밖(미수집)**: C02 Task별 Skill **전문**(영문 도메인 페이지 12개)은 수집하지 않았다. 비교 페이지가 '추가'로 표시한 스킬만 다룬다. C02용 Task 노트가 필요하면 별도 위임이 필요하다(§9).

## 0. 정정 — C02 한국어 가이드는 이미 공개돼 있다

README는 'MLA-C02 공식 가이드는 영문만 공개(한국어는 GA 시점 제공)'로 기록했으나, 2026-10-17에 **한국어 C02 가이드와 한국어 C01↔C02 비교 페이지가 docs에 이미 존재**함을 확인했다. 따라서 부록은 공식 한국어 원문으로 쓸 수 있다. 시험 자체는 한국어판이 아직 없다(C02 한국어 응시는 GA부터). 〔D1, D2, D7〕

| # | 항목 | 값/내용 | 인용(원문 15단어 이하) | 출처 URL | 조회일 |
|---|---|---|---|---|---|
| D1 | C02 한국어 가이드 | ko_kr C02 가이드 페이지 열람 가능 | "AWS Certified Machine Learning Engineer - Associate(MLA-C02)" | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-02/machine-learning-engineer-associate-02.html | 2026-10-17 |
| D2 | C01↔C02 한국어 비교 페이지 | ko_kr 비교 페이지 열람 가능(§4~§6의 한국어 문구 출처) | "MLA-C01 및 MLA-C02 비교" | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-02/mla-02-comparison.html | 2026-10-17 |

## 1. 언어별 일정

| 언어 | MLA-C01 | MLA-C02 |
|---|---|---|
| 영어 | **2026-09-28 종료** | 베타 등록 2026-09-01, 베타 시험 2026-09-29~ (영문만), **GA 2027-01-14** |
| 한국어 | **GA(2027-01-14)까지** 응시 가능, 이후 종료 | 베타 없음, **GA 2027-01-14부터** |
| 일본어 | 한국어와 동일 | 한국어와 동일 |
| 중국어(간체) | 한국어와 동일 | 한국어와 동일 |

| # | 항목 | 값/내용 | 인용(원문 15단어 이하) | 출처 URL | 조회일 |
|---|---|---|---|---|---|
| D3 | C01 영문 종료 | 2026-09-28 | "MLA-C01 in English is available through September 28, 2026." | https://aws.amazon.com/certification/certified-machine-learning-engineer-associate/ | 2026-10-17 |
| D4 | C01 한·일·중 | C02 GA까지 응시 가능 | "MLA-C01 in Korean, Japanese, and Simplified Chinese remains available until general availability of MLA-C02." | https://aws.amazon.com/certification/certified-machine-learning-engineer-associate/ | 2026-10-17 |
| D5 | C02 GA·C01 전 언어 종료 | 2027-01-14(전 언어) | "January 14, 2027 – GA delivery begins (all languages); MLA-C01 retired in all languages" | https://aws.amazon.com/blogs/training-and-certification/september-2026-new-offerings/ | 2026-10-17 |
| D6 | C02 베타 언어 | 영문만 | "The beta is available in English only." | https://aws.amazon.com/certification/certified-machine-learning-engineer-associate/ | 2026-10-17 |
| D7 | C02 추가 언어 시점 | 일본어·한국어·중국어(간체)는 GA 시점에 제공 | "Additional languages (Japanese, Korean, and Simplified Chinese) will be available at general availability" | https://aws.amazon.com/certification/certified-machine-learning-engineer-associate/ | 2026-10-17 |
| D8 | 비교 페이지(한국어)의 C01 사용 기간 표기 — 언어 구분 없음 | '2026년 9월 28일까지 사용'이라고만 적음 | "MLA-C01 시험(2026년 9월 28일까지 사용)" | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-02/mla-02-comparison.html | 2026-10-17 |
| D9 | 비교 페이지(영문)의 C01 사용 기간 표기 — 언어 구분 없음 | '2026-09-28까지 사용'이라고만 적음 | "the MLA-C01 exam (in use until September 28, 2026)" | https://docs.aws.amazon.com/aws-certification/latest/machine-learning-engineer-associate-02/mla-02-comparison.html | 2026-10-17 |

> **유효 기간 표기 상충(gaps)**: 공식 비교 페이지(한국어 D8·영문 D9)는 'C01은 2026-09-28까지, C02는 2026-09-29부터'라고 **언어 구분 없이** 적지만, 블로그(D5)와 자격증 페이지(D4)는 **한국어·일본어·중국어 C01이 C02 GA(2027-01-14)까지 유지**된다고 명시한다. 비교 페이지의 날짜는 영문 시험 기준으로 읽어야 한다. **학습문서는 블로그의 언어별 일정을 기준으로 쓰고 각주로 이 차이를 밝힌다.**
> GA 일정 표현 불일치(gaps): 블로그 September 2026은 **2027-01-14**, 블로그 'Updates to … (MLA-C02)'는 '2027년 초(early 2027)', 자격증 페이지는 GA를 'TBD'로 적는다. 가장 구체적인 September 2026 블로그를 따르되 변경 가능성을 표기한다.

## 2. 시험 사양 비교

| 항목 | MLA-C01 | MLA-C02 (현재 공개분 = 베타) |
|---|---|---|
| 시험 코드 | MLA-C01 | 베타 코드 ME1-C02 |
| 문항 수 | 65 (채점 50 + 비채점 15) | 85 (베타) — GA 사양 미공지 |
| 시험 시간 | 130분 | 170분 (베타) |
| 응시료 | 150 USD | 75 USD (베타 가격) |
| 합격 점수 | 720 / 1,000 | 가이드상 720 (베타는 합격/불합격 미적용) |
| 문항 유형 | ko 가이드 4종(선다형·복수 응답·순서 배열·매칭) / 영문 PDF v1.0은 Case study 포함 5종 | 가이드에 선다형·복수 응답 2종만 기재 |
| 도메인 구성 | 4개 | 4개 — **구성(도메인 4개·Task 12개)은 같다**. 도메인 이름만 AI/FM 반영 |
| **도메인 비중** | **28 / 26 / 22 / 24** (D1~D4, %) | **28 / 24 / 24 / 24** — D2 −2%p · D3 +2%p (구성은 같지만 **비중은 다르다**) |

| # | 항목 | 값/내용 | 인용(원문 15단어 이하) | 출처 URL | 조회일 |
|---|---|---|---|---|---|
| P1 | 시험 코드(표: C02 베타 열 → C01 열) | ME1-C02 / MLA-C01 | "Exam code ME1-C02 MLA-C01" | https://aws.amazon.com/certification/certified-machine-learning-engineer-associate/ | 2026-10-17 |
| P2 | C02 베타 문항 수 | 85 | "Number of questions: 85" | https://aws.amazon.com/blogs/training-and-certification/september-2026-new-offerings/ | 2026-10-17 |
| P3 | C02 베타 시험 시간 | 170분 | "Duration: 170 minutes" | https://aws.amazon.com/blogs/training-and-certification/september-2026-new-offerings/ | 2026-10-17 |
| P4 | C02 베타 응시료 | 75 USD | "Price: $75 USD" | https://aws.amazon.com/blogs/training-and-certification/september-2026-new-offerings/ | 2026-10-17 |
| P5 | C01 문항 수·형식 | 65 | "65 questions; multiple choice and multiple response" | https://aws.amazon.com/certification/certified-machine-learning-engineer-associate/ | 2026-10-17 |
| P6 | C02 채점 사양(가이드) | 채점 50문항 | "The exam includes 50 questions that affect your score." | https://docs.aws.amazon.com/aws-certification/latest/machine-learning-engineer-associate-02/machine-learning-engineer-associate-02.html | 2026-10-17 |
| P7 | C02 비채점 문항 | 15문항 | "The exam includes 15 unscored questions that do not affect your score." | https://docs.aws.amazon.com/aws-certification/latest/machine-learning-engineer-associate-02/machine-learning-engineer-associate-02.html | 2026-10-17 |
| P8 | C02 합격 점수 | 720 | "The minimum passing score is 720." | https://docs.aws.amazon.com/aws-certification/latest/machine-learning-engineer-associate-02/machine-learning-engineer-associate-02.html | 2026-10-17 |

## 3. 도메인 비중

| 도메인 | C01 | C02 |
|---|---:|---:|
| 1 데이터 준비 (C02: ML 및 AI를 위한 데이터 준비) | 28% | 28% |
| 2 모델 개발 (C02: ML 모델 및 파운데이션 모델(FM) 개발) | 26% | **24%** |
| 3 배포·오케스트레이션 (C02: ML 및 AI 워크플로의 배포 및 오케스트레이션) | 22% | **24%** |
| 4 모니터링·유지 관리·보안 (C02: ML 및 AI 솔루션 운영, 모니터링 및 보안) | 24% | 24% |

| # | 항목 | 값/내용 | 인용(원문 15단어 이하) | 출처 URL | 조회일 |
|---|---|---|---|---|---|
| W1 | C02 도메인 1 | 28% | "Content Domain 1: Data Preparation for ML and AI (28% of scored content)" | https://docs.aws.amazon.com/aws-certification/latest/machine-learning-engineer-associate-02/machine-learning-engineer-associate-02.html | 2026-10-17 |
| W2 | C02 도메인 2 | 24% | "Content Domain 2: ML Model and Foundation Model (FM) Development (24% of scored content)" | https://docs.aws.amazon.com/aws-certification/latest/machine-learning-engineer-associate-02/machine-learning-engineer-associate-02.html | 2026-10-17 |
| W3 | C02 도메인 3 | 24% | "Content Domain 3: Deployment and Orchestration of ML and AI Workflows (24% of scored content)" | https://docs.aws.amazon.com/aws-certification/latest/machine-learning-engineer-associate-02/machine-learning-engineer-associate-02.html | 2026-10-17 |
| W4 | C02 도메인 4 | 24% | "Content Domain 4: Operating, Monitoring, and Securing ML and AI Solutions (24% of scored content)" | https://docs.aws.amazon.com/aws-certification/latest/machine-learning-engineer-associate-02/machine-learning-engineer-associate-02.html | 2026-10-17 |

## 4. Task 대응표 (C01 → C02) 와 추가·삭제 건수

공식 비교 페이지: 영문 https://docs.aws.amazon.com/aws-certification/latest/machine-learning-engineer-associate-02/mla-02-comparison.html · 한국어 https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-02/mla-02-comparison.html

| C01 Task | C02 Task (영문) | C02 Task (한국어) | 추가 | 삭제 |
|---|---|---|---:|---:|
| 1.1 데이터를 수집 및 저장 | 1.1 Collect and store data. | 1.1 데이터를 수집하고 저장합니다. | 2 | 0 |
| 1.2 데이터 변환 및 특성 추출 수행 | 1.2 Perform data transformation, feature engineering, and pre-processing. | 1.2 데이터 변환, 특성 추출 및 사전 처리를 수행합니다. | 5 | 0 |
| 1.3 데이터 무결성을 보장하고 모델링을 위한 데이터 준비 | 1.3 Validate data quality and manage bias. | 1.3 데이터 품질을 검증하고 편향을 관리합니다. | 3 | 1 |
| 2.1 모델링 접근 방식 선택 | 2.1 Choose appropriate modeling approaches for ML and AI solutions. | 2.1 ML 및 AI 솔루션에 적합한 모델링 접근 방식을 선택합니다. | 5 | 0 |
| 2.2 모델 훈련 및 개선 | 2.2 Train, fine-tune, and customize models for ML and AI solutions. | 2.2 ML 및 AI 솔루션을 위한 모델을 학습, 미세 조정 및 사용자 지정합니다. | 2 | 2 |
| 2.3 모델 성능 분석 | 2.3 Analyze and evaluate the performance of ML and AI systems. | 2.3 ML 및 AI 시스템의 성능을 분석하고 평가합니다. | 4 | 0 |
| 3.1 배포 인프라 선택 | 3.1 Manage deployment infrastructure for ML and AI model types. | 3.1 ML 및 AI 모델 유형의 배포 인프라를 관리합니다. | 5 | 1 |
| 3.2 인프라 만들기 및 스크립팅 | 3.2 Provision and configure resources for ML and AI workloads based on existing architecture and requirements. | 3.2 기존 아키텍처 및 요구 사항을 기반으로 ML 및 AI 워크로드를 위한 리소스를 프로비저닝하고 구성합니다. | 5 | 1 |
| 3.3 CI/CD 파이프라인 설정 | 3.3 Implement automated orchestration and continuous integration and continuous delivery (CI/CD) pipelines for MLOps and AI workloads. | 3.3 MLOps 및 AI 워크로드를 위한 자동화된 오케스트레이션, 지속적 통합 및 지속적 전달(CI/CD) 파이프라인을 구현합니다. | 5 | 0 |
| 4.1 모델 추론 모니터링 | 4.1 Monitor ML and AI model inference and performance. | 4.1 ML 및 AI 모델 추론 및 성능을 모니터링합니다. | 2 | 0 |
| 4.2 인프라 및 비용 모니터링·최적화 | 4.2 Optimize and manage ML and AI infrastructure costs and performance. | 4.2 ML 및 AI 인프라 비용 및 성능을 최적화하고 관리합니다. | 4 | 2 |
| 4.3 AWS 리소스 보호 | 4.3 Secure ML and AI workloads and model endpoints. | 4.3 ML 및 AI 워크로드와 모델 엔드포인트를 보호합니다. | 3 | 0 |
| **합계** | | | **45** | **7** |

- 비교 페이지는 '추가'된 스킬만 번호(예: 1.1.7)로 나열한다. 번호가 건너뛰는 스킬(예: 1.1.1~1.1.6)이 C01 항목과 어떻게 대응하는지는 **설명하지 않는다**. 따라서 '추가' 목록은 C02의 신규분 지도일 뿐 C02 스킬 전체가 아니다.
- 1.3.7 '데이터 정리(이상값 감지·결측 대체·중복 제거)'는 C02에서 1.3 아래 '추가'로 표시된다. C01에서는 같은 취지의 내용이 Task 1.2 지식('데이터 정리 및 변환 기법')에 있었다 — 위치 이동 여부를 비교 페이지는 설명하지 않는다.

## 5. C02에서 추가된 스킬 전체 (영문 원문 / 한국어 원문)

### Task 1.1 데이터를 수집 및 저장 → C02 1.1 Collect and store data.

**붙일 C01 문서: Task 1.1 「데이터를 수집 및 저장」 (`tasks/1-1.md`)** — 아래 2개 항목 전부.

- 1.1.7 Configure scalable vector databases for AI applications (for example, OpenSearch Service, Amazon RDS with pgvector, Amazon S3) based on specifications.
  - 한국어: 1.1.7 사양에 따라 AI 애플리케이션을 위한 확장 가능한 벡터 데이터베이스를 구성합니다(예: OpenSearch Service, pgvector 기반 Amazon RDS, Amazon S3).
- 1.1.8 Ingest and store diverse data types (for example, text, images, audio) for AI and ML applications.
  - 한국어: 1.1.8 AI 및 ML 애플리케이션을 위한 다양한 데이터 유형을 수집하고 저장합니다(예: 텍스트, 이미지, 오디오).

### Task 1.2 데이터 변환 및 특성 추출 수행 → C02 1.2 Perform data transformation, feature engineering, and pre-processing.

**붙일 C01 문서: Task 1.2 「데이터 변환 및 특성 추출 수행」 (`tasks/1-2.md`)** — 아래 5개 항목 전부.

- 1.2.5 Configure and use embedding models to transform text and image data into numerical representations.
  - 한국어: 1.2.5 임베딩 모델을 구성하고 사용하여 텍스트 및 이미지 데이터를 수치 표현으로 변환합니다.
- 1.2.6 Apply advanced text pre-processing techniques (for example, tokenization, domain-specific augmentation).
  - 한국어: 1.2.6 고급 텍스트 사전 처리 기법을 적용합니다(예: 토큰화, 도메인별 증강).
- 1.2.7 Prepare documents for Retrieval Augmented Generation (RAG) applications (for example, chunking strategies, metadata extraction).
  - 한국어: 1.2.7 검색 증강 생성(RAG) 애플리케이션에 사용할 문서를 준비합니다(예: 청킹 전략, 메타데이터 추출).
- 1.2.8 Mask, redact, and anonymize data.
  - 한국어: 1.2.8 데이터를 마스킹, 편집 및 익명화합니다.
- 1.2.9 Prepare data for FM fine-tuning, continuous pre-training, and model distillation.
  - 한국어: 1.2.9 FM 미세 조정, 지속적인 사전 훈련 및 모델 증류를 위한 데이터를 준비합니다.

### Task 1.3 데이터 무결성을 보장하고 모델링을 위한 데이터 준비 → C02 1.3 Validate data quality and manage bias.

**붙일 C01 문서: Task 1.3 「데이터 무결성을 보장하고 모델링을 위한 데이터 준비」 (`tasks/1-3.md`)** — 아래 3개 항목 전부.

- 1.3.4 Optimize multimodal data distributions by applying bias metrics across numeric, text, and image assets.
  - 한국어: 1.3.4 숫자, 텍스트 및 이미지 자산에 편향 지표를 적용하여 멀티모드 데이터 배포를 최적화합니다.
- 1.3.6 Validate AI training data integrity (for example, prompt-response pair validation, content safety screening).
  - 한국어: 1.3.6 AI 학습 데이터 무결성을 검증합니다(예: 프롬프트-응답 쌍 검증, 콘텐츠 안전 검사).
- 1.3.7 Clean data (for example, by detecting outliers, imputing missing data, deduplication).
  - 한국어: 1.3.7 데이터를 정리합니다(예: 이상값 감지, 누락된 데이터 입력, 중복 제거).

### Task 2.1 모델링 접근 방식 선택 → C02 2.1 Choose appropriate modeling approaches for ML and AI solutions.

**붙일 C01 문서: Task 2.1 「모델링 접근 방식 선택」 (`tasks/2-1.md`)** — 아래 5개 항목 전부.

- 2.1.1 Evaluate and select appropriate FMs from Amazon Bedrock based on task requirements and performance criteria.
  - 한국어: 2.1.1 작업 요구 사항 및 성능 기준에 따라 Amazon Bedrock에서 적절한 FM을 평가하고 선택합니다.
- 2.1.2 Identify fine-tuning strategies for pre-trained FMs to meet business needs.
  - 한국어: 2.1.2 사전 교육을 받은 FM이 비즈니스 요구 사항을 충족할 수 있는 미세 조정 전략을 파악합니다.
- 2.1.4 Evaluate tradeoffs between custom solutions, managed services, pre-trained models, and FMs to meet business needs.
  - 한국어: 2.1.4 비즈니스 요구 사항을 충족하기 위해 맞춤형 솔루션, 관리 서비스, 사전 학습된 모델 및 FM 간의 장단점을 평가합니다.
- 2.1.5 Select Retrieval Augmented Generation (RAG) architecture patterns based on use case requirements.
  - 한국어: 2.1.5 사용 사례 요구 사항에 따라 검색 증강 생성(RAG) 아키텍처 패턴을 선택합니다.
- 2.1.7 Assess tradeoffs between AI model performance, latency, and cost.
  - 한국어: 2.1.7 AI 모델 성능, 지연 시간, 비용 간의 절충점을 평가합니다.

### Task 2.2 모델 훈련 및 개선 → C02 2.2 Train, fine-tune, and customize models for ML and AI solutions.

**붙일 C01 문서: Task 2.2 「모델 훈련 및 개선」 (`tasks/2-2.md`)** — 아래 2개 항목 전부.

- 2.2.8 Apply customization techniques for AI solutions (for example, task-specific prompt engineering, fine-tuning).
  - 한국어: 2.2.8 AI 솔루션에 사용자 지정 기술을 적용합니다(예: 작업별 프롬프트 엔지니어링, 미세 조정).
- 2.2.9 Optimize retrieval components and embedding models.
  - 한국어: 2.2.9 검색 구성 요소 및 임베딩 모델을 최적화합니다.

### Task 2.3 모델 성능 분석 → C02 2.3 Analyze and evaluate the performance of ML and AI systems.

**붙일 C01 문서: Task 2.3 「모델 성능 분석」 (`tasks/2-3.md`)** — 아래 4개 항목 전부.

- 2.3.7 Implement integrated human evaluation frameworks (for example, human-in-the-loop workflows, text generation quality assessment).
  - 한국어: 2.3.7 통합형 인적 평가 프레임워크를 구현합니다(예: HITL(Human-in-the-Loop) 워크플로, 텍스트 생성 품질 평가).
- 2.3.8 Apply natural language processing (NLP) evaluation metrics (for example, bilingual evaluation understudy [BLEU], Recall-Oriented Understudy for Gisting Evaluation [ROUGE], BERTScore, semantic similarity).
  - 한국어: 2.3.8 자연어 처리(NLP) 평가 지표 적용(예: 이중 언어 평가 언더스터디(BLEU), Recall-Oriented Understudy for Gisting Evaluation(ROUGE), BertScore, 시맨틱 유사성).
- 2.3.9 Perform AI evaluation (for example, model output assessment, content quality validation, bias detection, LLM-as-a-judge frameworks).
  - 한국어: 2.3.9 AI 평가를 수행합니다(예: 모델 출력 평가, 콘텐츠 품질 검증, 편향 탐지, 평가형 LLM 프레임워크).
- 2.3.10 Configure RAG system monitoring, including retrieval accuracy assessment.
  - 한국어: 2.3.10 검색 정확도 평가를 포함하여 RAG 시스템 모니터링을 구성합니다.

### Task 3.1 배포 인프라 선택 → C02 3.1 Manage deployment infrastructure for ML and AI model types.

**붙일 C01 문서: Task 3.1 「배포 인프라 선택」 (`tasks/3-1.md`)** — 아래 5개 항목 전부.

- 3.1.4 Evaluate and select appropriate foundation model (FM) deployment options.
  - 한국어: 3.1.4 적절한 파운데이션 모델(FM) 배포 옵션을 평가하고 선택합니다.
- 3.1.5 Deploy models that were built outside of AWS into AWS environments (for example, Amazon SageMaker AI, Amazon Bedrock Custom Model Import).
  - 한국어: 3.1.5 AWS 외부에서 구축한 모델을 AWS 환경에 배포합니다(예: Amazon SageMaker AI, Amazon Bedrock Custom Model Import).
- 3.1.6 Deploy and configure agents for specific tasks, integration with other services and tools, and agent communication protocols.
  - 한국어: 3.1.6 특정 작업, 다른 서비스 및 도구와의 통합, 에이전트 통신 프로토콜을 위한 에이전트를 배포 및 구성합니다.
- 3.1.7 Configure FM deployment, model hosting, and resource allocation.
  - 한국어: 3.1.7 FM 배포, 모델 호스팅 및 리소스 할당을 구성합니다.
- 3.1.8 Apply Retrieval Augmented Generation (RAG) system configurations (for example, retrieval strategies, reranking).
  - 한국어: 3.1.8 검색 증강 생성(RAG) 시스템 구성을 적용합니다(예: 검색 전략, 순위 조정).

### Task 3.2 인프라 만들기 및 스크립팅 → C02 3.2 Provision and configure resources for ML and AI workloads based on existing architecture and requirements.

**붙일 C01 문서: Task 3.2 「인프라 만들기 및 스크립팅」 (`tasks/3-2.md`)** — 아래 5개 항목 전부.

- 3.2.7 Create and manage Amazon Bedrock knowledge bases with vector database configurations, document indexing, and retrieval optimization.
  - 한국어: 3.2.7 벡터 데이터베이스 구성, 문서 인덱싱 및 검색 최적화를 통해 Amazon Bedrock 지식 기반을 만들고 관리합니다.
- 3.2.8 Implement retrieval pipelines to meet business needs.
  - 한국어: 3.2.8 비즈니스 요구 사항을 충족하기 위해 검색 파이프라인을 구현합니다.
- 3.2.9 Implement agent state management systems.
  - 한국어: 3.2.9 에이전트 상태 관리 시스템을 구현합니다.
- 3.2.10 Implement AI-specific resource scaling for GPU workloads.
  - 한국어: 3.2.10 GPU 워크로드를 위한 AI 전용 리소스 스케일링을 구현합니다.
- 3.2.11 Deploy agentic workflow infrastructure.
  - 한국어: 3.2.11 에이전틱 워크플로 인프라를 배포합니다.

### Task 3.3 CI/CD 파이프라인 설정 → C02 3.3 Implement automated orchestration and continuous integration and continuous delivery (CI/CD) pipelines for MLOps and AI workloads.

**붙일 C01 문서: Task 3.3 「CI/CD 파이프라인 설정」 (`tasks/3-3.md`)** — 아래 5개 항목 전부.

- 3.3.7 Manage prompts (for example, Amazon Bedrock Prompt Management).
  - 한국어: 3.3.7 프롬프트를 관리합니다(예: Amazon Bedrock Prompt Management).
- 3.3.8 Implement automated agent deployment pipelines and agent version management.
  - 한국어: 3.3.8 자동화된 에이전트 배포 파이프라인과 에이전트 버전 관리를 구현합니다.
- 3.3.9 Implement AI model testing frameworks, including prompt testing.
  - 한국어: 3.3.9 프롬프트 테스트를 포함한 AI 모델 테스트 프레임워크를 구현합니다.
- 3.3.10 Configure FM deployment automation with fine-tuned model versioning.
  - 한국어: 3.3.10 미세 조정 모델 버전 관리로 FM 배포 자동화를 구성합니다.
- 3.3.11 Configure AI-specific pipeline orchestration for RAG system updates and knowledge base refresh cycles.
  - 한국어: 3.3.11 RAG 시스템 업데이트 및 지식 기반 업데이트 주기를 위한 AI 관련 파이프라인 오케스트레이션을 구성합니다.

### Task 4.1 모델 추론 모니터링 → C02 4.1 Monitor ML and AI model inference and performance.

**붙일 C01 문서: Task 4.1 「모델 추론 모니터링」 (`tasks/4-1.md`)** — 아래 2개 항목 전부.

- 4.1.5 Monitor and automate the management of agent performance and coordination (for example, coordination failure detection, truncated streaming, tool failures).
  - 한국어: 4.1.5 에이전트 성능 및 조정 관리를 모니터링하고 자동화합니다(예: 조정 실패 감지, 잘린 스트리밍, 도구 실패).
- 4.1.6 Configure AI-specific performance monitoring for foundation models (FMs), such as Amazon Bedrock evaluations.
  - 한국어: 4.1.6 Amazon Bedrock 평가 도구 세트와 같은 파운데이션 모델(FM)에 대한 AI 관련 성능 모니터링을 구성합니다.

### Task 4.2 인프라 및 비용 모니터링·최적화 → C02 4.2 Optimize and manage ML and AI infrastructure costs and performance.

**붙일 C01 문서: Task 4.2 「인프라 및 비용 모니터링·최적화」 (`tasks/4-2.md`)** — 아래 4개 항목 전부.

- 4.2.7 Evaluate cost implications of using FMs for inference in production.
  - 한국어: 4.2.7 프로덕션 환경에서 추론에 FM을 사용할 경우 비용에 미치는 영향을 평가합니다.
- 4.2.8 Monitor agent resource consumption patterns.
  - 한국어: 4.2.8 에이전트 리소스 사용 패턴을 모니터링합니다.
- 4.2.9 Manage FM inference costs with usage optimization.
  - 한국어: 4.2.9 사용 최적화를 통해 FM 추론 비용을 관리합니다.
- 4.2.10 Monitor AI-specific cost patterns (for example, token usage optimization, embedding computation costs, vector database storage optimization).
  - 한국어: 4.2.10 AI 관련 비용 패턴을 모니터링합니다(예: 토큰 사용 최적화, 임베딩 계산 비용, 벡터 데이터베이스 스토리지 최적화).

### Task 4.3 AWS 리소스 보호 → C02 4.3 Secure ML and AI workloads and model endpoints.

**붙일 C01 문서: Task 4.3 「AWS 리소스 보호」 (`tasks/4-3.md`)** — 아래 3개 항목 전부.

- 4.3.1 Secure continuous integration and continuous delivery (CI/CD) pipelines by checking for code and image vulnerabilities (for example, by using Amazon CodeGuru, Amazon Inspector).
  - 한국어: 4.3.1 코드 및 이미지 취약성을 검사하여 지속적 통합 및 지속적 전달(CI/CD) 파이프라인을 보호합니다(예: Amazon CodeGuru, Amazon Inspector 사용).
- 4.3.8 Select the appropriate credential type to access FMs (for example, Amazon Bedrock API keys, IAM credentials).
  - 한국어: 4.3.8 FM에 액세스하기 위한 적절한 자격 증명 유형을 선택합니다(예: Amazon Bedrock API 키, IAM 자격 증명).
- 4.3.9 Implement safeguards and sensitive data protection to meet application requirements and responsible AI policies (for example, by using Amazon Bedrock Guardrails).
  - 한국어: 4.3.9 애플리케이션 요구 사항 및 책임 있는 AI 정책을 충족하도록 보호 및 민감한 데이터 보호를 구현합니다(예: Amazon Bedrock Guardrails 사용).

## 6. C02에서 삭제된 내용 (영문 원문 / 한국어 원문)

### Task 1.3 데이터 무결성을 보장하고 모델링을 위한 데이터 준비

- Configuring data to load into the model training resource (for example, Amazon EFS, Amazon FSx)
  - 한국어: 모델 훈련 리소스에 로드할 데이터 구성(예: Amazon EFS, Amazon FSx)

### Task 2.2 모델 훈련 및 개선

- Using custom datasets to fine-tune pre-trained models (for example, Amazon Bedrock, SageMaker JumpStart)
  - 한국어: 사용자 지정 데이터세트를 사용하여 사전 훈련된 모델 미세 조정(예: Amazon Bedrock, SageMaker JumpStart)
- Reducing model size (for example, by altering data types, pruning, updating feature selection, compression)
  - 한국어: 모델 크기 축소(예: 데이터 유형 변경, 정리, 특성 선택 업데이트, 압축)

### Task 3.1 배포 인프라 선택

- Methods to optimize models on edge devices (for example, SageMaker Neo)
  - 한국어: 엣지 디바이스에서 모델을 최적화하는 방법(예: SageMaker Neo)

### Task 3.2 인프라 만들기 및 스크립팅

- Bring your own container (BYOC) with SageMaker
  - 한국어: SageMaker를 통한 BYOC(Bring Your Own Container)

### Task 4.2 인프라 및 비용 모니터링·최적화

- Monitoring infrastructure (for example, by using Amazon EventBridge events)
  - 한국어: 인프라 모니터링(예: Amazon EventBridge 이벤트 사용)
- Troubleshooting capacity concerns that involve cost and performance (for example, provisioned concurrency, service quotas, auto scaling)
  - 한국어: 비용 및 성능과 관련된 용량 문제 해결(예: 프로비저닝된 동시성, 서비스 할당량, 오토 스케일링)

## 7. 범위 내·외 서비스 목록의 변화

**산출 방법**: C01 한국어 가이드의 목록(https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-01/mla-01-in-scope-services.html , https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-01/mla-01-out-of-scope-services.html)과 C02 영문 가이드의 목록(https://docs.aws.amazon.com/aws-certification/latest/machine-learning-engineer-associate-02/mla-02-in-scope-services.html , https://docs.aws.amazon.com/aws-certification/latest/machine-learning-engineer-associate-02/mla-02-out-of-scope-services.html)을 2026-10-17에 파싱해 집합 차이를 계산했다. 표기만 다른 항목(괄호 앞 공백, 대소문자, 'Private CA'↔'Private Certificate Authority' 등)은 같은 서비스로 보고 제외했다.

### 7-1. 범위 **내** 목록 변화와 붙일 C01 Task

개수: C01 88 → C02 81 (88 − 11 빠짐 + 4 추가 = 81, SageMaker→SageMaker AI는 이름 변경이라 개수 불변). **근거 수준** 열: '스킬 원문'은 공식 가이드 스킬 문장에 서비스명이 실제로 나온다는 뜻이고, '제안'은 범위 목록에만 있어 취합 세션이 붙일 곳을 정해야 한다는 뜻이다(공식 문서가 연결해 주지 않음).

| 서비스 | 변화(C01→C02) | 붙일 C01 Task | 근거 수준 |
|---|---|---|---|
| Amazon Bedrock AgentCore | **C02 신규** | 3.1 · 3.2 · 3.3 · 4.1 · 4.2 (에이전트 관련 C02 추가 스킬 3.1.6 · 3.2.9 · 3.2.11 · 3.3.8 · 4.1.5 · 4.2.8 이 붙는 Task) | 제안 — 비교 페이지는 AgentCore와 이 스킬들을 직접 연결하지 않음 |
| AWS CodeCommit | **C02 신규** | 3.3 (C01 3.3 에 'Git'·'코드 리포지토리' 항목: 3.3K3 · 3.3K6 · 3.3S2) | 제안 — C01 스킬 원문에는 CodeCommit 이름이 없음. 참고: CodeCommit은 2025-11-25 신규 고객 재개(`00-overview.md` L21) |
| AWS CodeConnections | **C02 신규** | 3.3 | 제안 — 위와 동일 |
| Amazon Inspector | 범위 외 → **범위 내** | 4.3 (C02 스킬 4.3.1 'CodeGuru, Inspector'로 CI/CD 취약점 점검) | 스킬 원문(C02 4.3.1) |
| Amazon SageMaker → **SageMaker AI** | 이름 변경 | 전 Task (`00-overview.md` N1) | 공식 문서 |
| Amazon Bedrock | **변화 없음 — C01 범위 내에도 있었음**. C02에서 사용 범위가 크게 확대 | 2.1 · 2.2 (C01 스킬 원문: 2.1K2 · 2.1S3 · 2.2S3) + C02 추가 스킬은 §7-2 표 | 스킬 원문 |
| Amazon Augmented AI(A2I) | C02 목록에서 빠짐 | 1.2 · 2.1 (사람 검토·레이블링 맥락) | 제안 — C01 스킬 원문에 A2I 이름 없음 |
| Amazon Mechanical Turk | C02 목록에서 빠짐 | **1.2** (C01 스킬 원문: 1.2S3 'SageMaker Ground Truth, Amazon Mechanical Turk') | 스킬 원문 |
| Amazon Fraud Detector · Amazon Kendra · Amazon Lookout for Equipment/Metrics/Vision · Amazon Q | C02 목록에서 빠짐 | 2.1 (AI 서비스 선택) | 제안 — C01 스킬 원문에 이름 없음 |
| AWS Chatbot | C02 목록에서 빠짐 | 4.2 (알림·모니터링 연동 맥락) | 제안 — C01 스킬 원문에 이름 없음 |
| Amazon CloudWatch Logs | C02 목록에서 빠짐('Amazon CloudWatch'만 남음 — 로그가 포함되는지 설명 없음) | 4.1 · 4.2 (C01 스킬 원문: 4.2K2 'CloudWatch Logs Insights', 4.2S1 'CloudWatch 로그') | 스킬 원문 |
| AWS Serverless Application Repository | C02 목록에서 빠짐 | 해당 Task 없음 | C01 스킬 원문에 이름 없음 |

- 관찰: 빠진 서비스 중 A2I·Fraud Detector·Kendra·Lookout 3종·Mechanical Turk·Amazon Q(Business)는 `00-overview.md` §7 에서 확인한 **신규 고객 중단·종료 서비스와 겹친다**. 이것이 목록 변경의 이유인지는 공식 문서에 명시돼 있지 않다.
- 주의: 레포 JSON에서 'Amazon Q' 문자열이 4.2S3 에 보이지만 이는 'Amazon Quick Sight' 의 부분 문자열이다(Amazon Q 서비스가 아님).

### 7-2. C02 추가 스킬에 이름이 나오는 서비스·기능 (공식 원문 기준)

C02 Task는 C01 Task와 번호가 1:1이므로 **붙일 C01 Task = 해당 스킬이 속한 Task** 다.

| 서비스·기능 | C02 스킬 번호 | 붙일 C01 Task |
|---|---|---|
| Amazon OpenSearch Service · Amazon RDS(pgvector) · Amazon S3 — 벡터 데이터베이스 용도 | 1.1.7 | 1.1 |
| 임베딩 모델 | 1.2.5 · 2.2.9 | 1.2 · 2.2 |
| Amazon Bedrock — FM 평가·선택 | 2.1.1 | 2.1 |
| BLEU · ROUGE · BERTScore — NLP 평가 지표 | 2.3.8 | 2.3 |
| Amazon Bedrock Custom Model Import · Amazon SageMaker AI — AWS 외부 모델 배포 | 3.1.5 | 3.1 |
| Amazon Bedrock 지식 기반(knowledge bases) | 3.2.7 | 3.2 |
| Amazon Bedrock Prompt Management | 3.3.7 | 3.3 |
| Amazon Bedrock 평가(evaluations) | 4.1.6 | 4.1 |
| Amazon CodeGuru · Amazon Inspector — CI/CD 취약점 점검 | 4.3.1 | 4.3 |
| Amazon Bedrock API 키 · IAM 자격 증명 — FM 접근 자격 증명 유형 | 4.3.8 | 4.3 |
| Amazon Bedrock Guardrails | 4.3.9 | 4.3 |

### 7-3. 범위 **외** 목록

- **C02에서 추가**: AWS Security Hub CSPM · AWS Infrastructure Composer(C01 범위 외 목록의 'AWS Application Composer'가 같은 자리에서 사라지고 이 항목이 나타남 — 개명 여부는 이번 조사에서 확인하지 않음)
- **C02에서 빠짐**: AWS AppSync · AWS Directory Service · AWS Migration Hub · AWS Panorama · Amazon Chime · Amazon Monitron · Amazon Pinpoint · AWS Application Composer · Amazon Inspector(→ 범위 **내**로 이동)
- 보안 도메인 혼동 짝 주의: C02에서는 **Amazon Inspector가 범위 내**이고 GuardDuty·Security Hub·WAF·Shield 등은 여전히 범위 외다.

| # | 항목 | 값/내용 | 인용(원문 15단어 이하) | 출처 URL | 조회일 |
|---|---|---|---|---|---|
| R1 | C02 범위 내: Bedrock AgentCore | 신규 | "Amazon Bedrock AgentCore" | https://docs.aws.amazon.com/aws-certification/latest/machine-learning-engineer-associate-02/mla-02-in-scope-services.html | 2026-10-17 |
| R2 | C02 범위 내: CodeCommit | 신규 | "AWS CodeCommit" | https://docs.aws.amazon.com/aws-certification/latest/machine-learning-engineer-associate-02/mla-02-in-scope-services.html | 2026-10-17 |
| R3 | C02 범위 내: CodeConnections | 신규 | "AWS CodeConnections" | https://docs.aws.amazon.com/aws-certification/latest/machine-learning-engineer-associate-02/mla-02-in-scope-services.html | 2026-10-17 |
| R4 | C02 범위 내: Inspector | 범위 외 → 범위 내 | "Amazon Inspector" | https://docs.aws.amazon.com/aws-certification/latest/machine-learning-engineer-associate-02/mla-02-in-scope-services.html | 2026-10-17 |
| R5 | C02 범위 내: SageMaker AI | 이름 변경 반영 | "Amazon SageMaker AI" | https://docs.aws.amazon.com/aws-certification/latest/machine-learning-engineer-associate-02/mla-02-in-scope-services.html | 2026-10-17 |
| R6 | C02 범위 외: Security Hub CSPM | 신규(범위 외) | "AWS Security Hub CSPM" | https://docs.aws.amazon.com/aws-certification/latest/machine-learning-engineer-associate-02/mla-02-out-of-scope-services.html | 2026-10-17 |
| R7 | C01 범위 내: Fraud Detector | C02 목록에서 빠짐 | "Amazon Fraud Detector" | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-01/mla-01-in-scope-services.html | 2026-10-17 |
| R8 | C01 범위 내: Kendra | C02 목록에서 빠짐 | "Amazon Kendra" | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-01/mla-01-in-scope-services.html | 2026-10-17 |
| R9 | C01 범위 내: Mechanical Turk | C02 목록에서 빠짐 | "Amazon Mechanical Turk" | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-01/mla-01-in-scope-services.html | 2026-10-17 |
| R10 | C01 범위 내: Bedrock | C01 범위 내 목록에도 이미 있음(C02 '신규'가 아님) | "Amazon Bedrock" | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-01/mla-01-in-scope-services.html | 2026-10-17 |

## 8. C01 학습문서 부록 작성 시 참고 (Task별 한 줄 — 공식 추가 항목의 요약, 제안)

| C01 문서 | 부록에 담을 C02 추가 영역(요약) | 추가 스킬 수 |
|---|---|---:|
| 1.1 데이터를 수집 및 저장 | 벡터 DB(OpenSearch·RDS pgvector·S3) 구성, 텍스트·이미지·오디오 등 다양한 데이터 유형 수집·저장 | 2 |
| 1.2 데이터 변환 및 특성 추출 수행 | 임베딩 모델, 고급 텍스트 전처리, RAG용 문서 준비(청킹·메타데이터), 마스킹·편집·익명화, FM 미세 조정·지속 사전 훈련·증류용 데이터 준비 | 5 |
| 1.3 데이터 무결성을 보장하고 모델링을 위한 데이터 준비 | 멀티모달 편향 지표, AI 학습 데이터 무결성(프롬프트-응답 쌍·콘텐츠 안전 검사), 데이터 정리(이상값·결측·중복 — C01 1.2에서 이동한 성격) | 3 |
| 2.1 모델링 접근 방식 선택 | Bedrock FM 선택·평가, FM 미세 조정 전략, 맞춤형 vs 관리형 vs 사전 학습 vs FM 절충, RAG 아키텍처 패턴, 성능·지연·비용 절충 | 5 |
| 2.2 모델 훈련 및 개선 | 프롬프트 엔지니어링·미세 조정 등 사용자 지정 기법, 검색 구성 요소·임베딩 모델 최적화 | 2 |
| 2.3 모델 성능 분석 | 인적 평가(HITL), NLP 지표(BLEU·ROUGE·BERTScore·시맨틱 유사성), AI 평가(LLM-as-a-judge), RAG 모니터링 | 4 |
| 3.1 배포 인프라 선택 | FM 배포 옵션, AWS 외부 모델 배포(Bedrock Custom Model Import), 에이전트 배포·통신 프로토콜, FM 호스팅·리소스 할당, RAG 구성(검색 전략·순위 조정) | 5 |
| 3.2 인프라 만들기 및 스크립팅 | Bedrock 지식 기반(벡터 DB·인덱싱·검색 최적화), 검색 파이프라인, 에이전트 상태 관리, GPU 워크로드 스케일링, 에이전틱 워크플로 인프라 | 5 |
| 3.3 CI/CD 파이프라인 설정 | 프롬프트 관리, 에이전트 배포 파이프라인·버전 관리, 프롬프트 테스트 포함 AI 테스트, FM 배포 자동화, RAG·지식 기반 갱신 오케스트레이션 | 5 |
| 4.1 모델 추론 모니터링 | 에이전트 성능·조정 모니터링, Bedrock 평가 등 FM 성능 모니터링 | 2 |
| 4.2 인프라 및 비용 모니터링·최적화 | FM 추론 비용 평가·관리, 에이전트 리소스 사용 모니터링, 토큰·임베딩·벡터 DB 비용 패턴 | 4 |
| 4.3 AWS 리소스 보호 | CI/CD 취약점 점검(CodeGuru·Inspector), FM 접근 자격 증명 유형(Bedrock API 키·IAM), Bedrock Guardrails | 3 |

- 부록은 **'C02 대비 참고(시험 범위 밖일 수 있음)'** 로 표시하는 편이 정직하다. 한국어 학습자가 현재 응시하는 시험(C01)에는 나오지 않고, 2027-01-14 이후에만 해당한다.
- 삭제 항목(§6)은 C01 문항에서만 유효하다. C02 전환 후에는 학습 비중을 낮춰도 된다.

## 9. 한계·후속 후보

1. C02 Task별 Skill 전문(영문/한국어 도메인 페이지 12개)은 수집하지 않았다. 부록을 '추가분' 수준을 넘어 C02 완전 대응으로 쓰려면 C02 12 Task 노트가 필요하다(별도 위임 필요).
2. 번호가 건너뛰는 스킬의 C01↔C02 대응은 공식 문서에 설명이 없다(§4).
3. C02 GA 사양(문항 수·시간·응시료)은 미공지다. 표의 C02 열은 베타 값이다(§2).
4. Bedrock·RAG·에이전트 등 C02 추가 영역의 **내용 자체**(개념·한도·요금)는 이 파일에 없다.
