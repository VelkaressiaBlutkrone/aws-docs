# 00. DEA-C01 시험 개요 (원자료 노트)

> **상태**: 원자료 노트 (AI 수집 · 미검수) · **조회일 2026-10-17** · 작성: DEA-C01 리서치 세션
> 용도: 취합 세션이 학습문서·문항을 저작할 때 쓰는 재료. 모든 사실에 출처 URL을 붙였고, 확인되지 않은 항목은 `99-gaps.md`에 있다.
> 이 파일 안의 표(§1·§2·§4·§5·§6의 인용 열)는 인용문을 출처 페이지 원문과 문자열 대조해 검증했다.

## 한눈에 보기

| 항목 | 값 |
|---|---|
| 공식 자격증명 | **AWS Certified Data Engineer - Associate** (시험 코드 **DEA-C01**) |
| 레벨 | Associate |
| 문항 | 65문항 = **채점 50 + 비채점 15** (선다형 + 복수응답형) |
| 시간 | **130분** |
| 합격선 | **720** / 1,000 (환산 점수 100–1,000, 보상형 채점) |
| 현행 공식 가이드 | **v1.1 — 2025-12-12 게시** (v1.0 = 첫 릴리스). 후속 코드(DEA-C02 등) 공지는 확인되지 않음 |
| 구조 | 도메인 4 · Task 17 · Skill 120 (Knowledge/Skill 통합형) |
| 도메인 비중 | D1 데이터 수집 및 변환 **34%** · D2 데이터 스토어 관리 **26%** · D3 데이터 운영 및 지원 **22%** · D4 데이터 보안 및 거버넌스 **18%** |

## 1. 시험 메타 (실측)

표 형식: `# | 항목 | 값 | 인용(영어 원문, 큰따옴표) | 출처(평문 URL)`

| # | 항목 | 값 | 인용 | 출처 |
|---|---|---|---|---|
| M1 | 공식 자격증명·시험 코드 | AWS Certified Data Engineer - Associate, DEA-C01 | "AWS Certified Data Engineer - Associate (DEA-C01) exam validates" | https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01.html |
| M2 | 레벨(Category) | Associate | "Category Associate" | https://aws.amazon.com/certification/certified-data-engineer-associate/ |
| M3 | 총 문항·유형 | 65문항, 선다형 또는 복수응답형 | "65 questions; either multiple choice or multiple response" | https://aws.amazon.com/certification/certified-data-engineer-associate/ |
| M4 | 선다형 정의 | 정답 1개 + 오답 3개 | "Multiple choice: Has one correct response and three incorrect responses (distractors)" | https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01.html |
| M5 | 복수응답형 정의 | 5개 이상 보기 중 정답 2개 이상 | "Multiple response: Has two or more correct responses out of five or more response options" | https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01.html |
| M6 | 채점 문항 수 | 50 | "The exam includes 50 questions that affect your score." | https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01.html |
| M7 | 비채점 문항 수 | 15 (시험 중 식별되지 않음) | "The exam includes 15 unscored questions that do not affect your score." | https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01.html |
| M8 | 시험 시간 | 130분 | "130 minutes" | https://aws.amazon.com/certification/certified-data-engineer-associate/ |
| M9 | 합격 최소 점수 | 720 | "The minimum passing score is 720." | https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01.html |
| M10 | 점수 척도 | 100–1,000 환산 점수 | "reported as a scaled score of 100–1,000" | https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01.html |
| M11 | 채점 모델 | 보상형(compensatory): 영역별 합격 불필요, 전체 합격만 필요 | "The exam uses a compensatory scoring model" | https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01.html |
| M12 | 오답 감점 | 없음(무응답은 오답 처리) | "Unanswered questions are scored as incorrect; there is no penalty for guessing." | https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01.html |
| M13 | 응시료 | 150 USD (환율 등은 Exam pricing 페이지) | "150 USD" | https://aws.amazon.com/certification/certified-data-engineer-associate/ |
| M14 | 응시 방식 | Pearson VUE 센터 또는 온라인 감독 시험 | "Pearson VUE testing center or online proctored exam" | https://aws.amazon.com/certification/certified-data-engineer-associate/ |
| M15 | 제공 언어 | 영어·일본어·**한국어**·중국어 간체 | "English, Japanese, Korean, and Simplified Chinese" | https://aws.amazon.com/certification/certified-data-engineer-associate/ |
| M16 | 자격 유효 기간 | 3년, 최신 버전 시험 합격으로 갱신 | "This certification is valid for 3 years." | https://aws.amazon.com/certification/certified-data-engineer-associate/ |
| M17 | 시험 개시일 | 2024-03-12부터 응시 가능 | "available to schedule and take starting March 12, 2024" | https://aws.amazon.com/blogs/training-and-certification/aws-certification-retirements-and-launches/ |
| M18 | 대상 응시자 | 데이터 엔지니어링 2–3년 상당 + AWS 실무 1–2년 | "equivalent of 2–3 years of experience in data engineering" | https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01.html |
| M19 | 시험 내 서비스 약칭 사용 | 일부 서비스는 약칭으로 출제, 시험 중 Help 버튼에서 약칭↔전체명 목록 제공(영문판 먼저, 타 언어는 순차 적용) | "This exam uses short names of some AWS services." | https://aws.amazon.com/certification/certified-data-engineer-associate/ |
| M20 | 한국어 가이드의 합격선 표기 | 합격 최소 점수 720점 (영문과 동일) | "합격 최소 점수는 720점입니다" | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01.html |

> 인증 페이지에는 합격 점수가 적혀 있지 않다 — 합격선은 시험 가이드(M9)가 출처다. 약칭 목록(M19)은 공개 페이지에 없고 시험 화면 Help 버튼에서만 제공된다고 안내되어 있다.

## 2. 공식 가이드: 버전·발행일·개정 상태

| # | 항목 | 내용 | 인용 | 출처 |
|---|---|---|---|---|
| V1 | 개정 이력 표 | v1.0 = 첫 릴리스, **v1.1 = 2025-12-12** (최신 행) | "December 12, 2025" | https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-revisions.html |
| V2 | v1.1의 구조 변경 | v1.0의 개별 Knowledge/Skill이 Task별 **하나의 Skill 목록**으로 통합 | "consolidated into one list of skills under each task" | https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-revisions.html |
| V3 | 한국어판 개정 이력 | 한국어 가이드도 동일하게 v1.1 / 2025년 12월 12일 | "2025년 12월 12일" | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/data-engineer-associate-01/dea-01-revisions.html |
| V4 | 개정 공지 정책 | 변경은 시험에 반영되기 최소 1개월 전에 게시 | "published at least one month before changes are reflected on your exam" | https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01.html |
| V5 | v1.1에서 삭제된 Skill | 없음(기존 Skill과 중복되던 v1.0 Knowledge 항목만 제거) | "no knowledge and skills removed on Version 1.1" | https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-revisions.html |

**개정 상태 요약 (2026-10-17 시점)**
- 현행 가이드는 **v1.1(2025-12-12)** — 개정 이력 표의 마지막 행. v1.1 이후 개정 행은 EN/KO 두 페이지 모두 없다.
- 후속 시험 코드(예: DEA-C02)·단종·자격증명 변경 공지: **가이드 메인, 인증 페이지, 웹 검색(AWS 도메인 한정)에서 확인되지 않음.** 인증 페이지에는 "recertify by passing the latest version of this exam" 문구만 있다(= 최신 버전 응시로 갱신).
- **2026-10-19 재확인**: EN 개정 이력 표는 여전히 v1.0(첫 릴리스)·v1.1(December 12, 2025) 두 행뿐이다. 또한 17개 Task 노트 머리의 Skill 원문 표(EN·KO 각 120개)를 라이브 가이드 도메인 1~4 페이지(`.md`)와 프로그램으로 대조한 결과 **문자 단위로 동일**했다(불일치 0건). 즉 2026-10-17 수집 이후 가이드 본문 변경은 없다.
- 가이드는 HTML이 정본이다: EN `…/data-engineer-associate-01/data-engineer-associate-01.html`, KO는 `/ko_kr/` 경로. 모든 페이지에 `.md` 형태가 있다(자동화 시 유용).
- PDF 렌더: EN `https://docs.aws.amazon.com/pdfs/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01.pdf`, KO `https://docs.aws.amazon.com/ko_kr/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01.pdf` (HTTP 200, Last-Modified 각 2026-10-16 / 2026-10-15 — 문서 빌드 갱신 시각이며 버전 번호 변화를 뜻하는지는 확인 못 함, `99-gaps.md` 참조).
- ⚠️ **구 PDF가 아직 살아 있다**: `https://d1.awsstatic.com/training-and-certification/docs-data-engineer-associate/AWS-Certified-Data-Engineer-Associate_Exam-Guide.pdf` (HTTP 200, Last-Modified 2025-02-14, 19쪽). v1.1(2025-12-12)보다 이전 파일이므로 **v1.1 내용(신규 Skill 8개 등)을 담을 수 없다.** 인증 페이지는 이 PDF가 아니라 HTML 가이드를 링크한다. 이 레포의 CLF 매핑 문서(`clf-c02-task-mapping.md`)처럼 PDF를 출처로 삼지 말 것.

## 3. 공식 가이드 URL (조회일 2026-10-17)

| 페이지 | EN | KO |
|---|---|---|
| 메인 | https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01.html | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01.html |
| 도메인 1 | …/data-engineer-associate-01-domain1.html | …/ko_kr/…/data-engineer-associate-01-domain1.html |
| 도메인 2 | …/data-engineer-associate-01-domain2.html | …/ko_kr/…/data-engineer-associate-01-domain2.html |
| 도메인 3 | …/data-engineer-associate-01-domain3.html | …/ko_kr/…/data-engineer-associate-01-domain3.html |
| 도메인 4 | …/data-engineer-associate-01-domain4.html | …/ko_kr/…/data-engineer-associate-01-domain4.html |
| 범위 내 서비스 | …/dea-01-in-scope-services.html | …/ko_kr/…/dea-01-in-scope-services.html |
| 범위 외 서비스 | …/dea-01-out-of-scope-services.html | …/ko_kr/…/dea-01-out-of-scope-services.html |
| 개정 | …/dea-01-revisions.html | …/ko_kr/…/dea-01-revisions.html |

(생략 `…` = `https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01`.)
- 인증 페이지(EN): https://aws.amazon.com/certification/certified-data-engineer-associate/ — 응시 정보(M2~M16)와 가이드 링크.
- 레포 `flutter_app/assets/exam_guides/DEA-C01.json`의 `sourceUrl`은 KO 메인 페이지(위 표)다.

## 4. 도메인·Task·Skill 구조 (v1.1 기준, 총 120 Skill)

| 도메인(비중) | Task | 제목 (EN / KO) | Skill 수 | v1.1 신규 | v1.1 개정 | 노트 |
|---|---|---|---|---|---|---|
| **D1 데이터 수집 및 변환 (34%)** | 1.1 | Perform data ingestion / 데이터 수집 수행 | 12 | – | – | `tasks/1-1.md` |
| | 1.2 | Transform and process data / 데이터 변환 및 처리 | 10 | 1.2.10 | – | `tasks/1-2.md` |
| | 1.3 | Orchestrate data pipelines / 데이터 파이프라인 오케스트레이션 | 4 | – | – | `tasks/1-3.md` |
| | 1.4 | Apply programming concepts / 프로그래밍 개념 적용 | 11 | – | 1.4.8 | `tasks/1-4.md` |
| **D2 데이터 스토어 관리 (26%)** | 2.1 | Choose a data store / 데이터 스토어 선택 | 8 | 2.1.7, 2.1.8 | 2.1.3 | `tasks/2-1.md` |
| | 2.2 | Understand data cataloging systems / 데이터 카탈로그 시스템 이해 | 6 | 2.2.6 | 2.2.2 | `tasks/2-2.md` |
| | 2.3 | Manage the lifecycle of data / 데이터의 수명 주기 관리 | 6 | – | – | `tasks/2-3.md` |
| | 2.4 | Design data models and schema evolution / 데이터 모델 및 스키마 진화 설계 | 6 | 2.4.6 | 2.4.4 | `tasks/2-4.md` |
| **D3 데이터 운영 및 지원 (22%)** | 3.1 | Automate data processing by using AWS services / AWS 서비스를 사용하여 데이터 처리 자동화 | 9 | – | 3.1.6 | `tasks/3-1.md` |
| | 3.2 | Analyze data by using AWS services / AWS 서비스를 사용하여 데이터 분석 | 6 | – | 3.2.3 | `tasks/3-2.md` |
| | 3.3 | Maintain and monitor data pipelines / 데이터 파이프라인 유지 관리 및 모니터링 | 8 | – | – | `tasks/3-3.md` |
| | 3.4 | Ensure data quality / 데이터 품질 보장 | 5 | – | – | `tasks/3-4.md` |
| **D4 데이터 보안 및 거버넌스 (18%)** | 4.1 | Apply authentication mechanisms / 인증 메커니즘 적용 | 7 | 4.1.7 | – | `tasks/4-1.md` |
| | 4.2 | Apply authorization mechanisms / 권한 부여 메커니즘 적용 | 6 | – | 4.2.5, 4.2.6 | `tasks/4-2.md` |
| | 4.3 | Ensure data encryption and masking / 데이터 암호화 및 마스킹 보장 | 4 | – | 4.3.4 | `tasks/4-3.md` |
| | 4.4 | Prepare logs for audit / 감사용 로그 준비 | 5 | – | – | `tasks/4-4.md` |
| | 4.5 | Understand data privacy and governance / 데이터 프라이버시 및 거버넌스 이해 | 7 | 4.5.6, 4.5.7 | 4.5.4, 4.5.5 | `tasks/4-5.md` |
| **합계** | **17** | | **120** (D1 37 · D2 26 · D3 28 · D4 29) | **8** | **11** | |

도메인 비중 인용(채점 콘텐츠 기준):

| # | 항목 | 값 | 인용 | 출처 |
|---|---|---|---|---|
| D1 | 도메인 1 비중 | 34% | "Content Domain 1: Data Ingestion and Transformation (34% of scored content)" | https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01.html |
| D2 | 도메인 2 비중 | 26% | "Content Domain 2: Data Store Management (26% of scored content)" | https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01.html |
| D3 | 도메인 3 비중 | 22% | "Content Domain 3: Data Operations and Support (22% of scored content)" | https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01.html |
| D4 | 도메인 4 비중 | 18% | "Content Domain 4: Data Security and Governance (18% of scored content)" | https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01.html |

> 비중이 큰 순서: D1(34%) > D2(26%) > D3(22%) > D4(18%). Task 단위 비중은 가이드에 없다 — 도메인 비중을 Task 수로 나눈 값은 **추정**일 뿐 공식 값이 아니다(사용 금지).

## 5. v1.0 → v1.1 변경 (2025-12-12)

출처: https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-revisions.html (EN), https://docs.aws.amazon.com/ko_kr/aws-certification/latest/data-engineer-associate-01/dea-01-revisions.html (KO), 조회일 2026-10-17.

### 5.1 신규 Skill 8개 — v1.0에 없던 내용 (신규 영역: LLM · 벡터 · 오픈 테이블 · SageMaker 거버넌스)

| Skill | English | 한국어 |
|---|---|---|
| 1.2.10 | Integrate Large Language Models (LLM) for data processing. | 데이터 처리를 위한 대규모 언어 모델(LLM) 통합 |
| 2.1.7 | Manage open table formats (for example Apache Iceberg). | 오픈 테이블 형식 관리(예: Apache Iceberg) |
| 2.1.8 | Describe vector index types (for example, HNSW, IVF). | 벡터 인덱스 유형 설명(예: HNSW, IVF) |
| 2.2.6 | Create and manage business data catalogs (for example Amazon SageMaker Catalog). | 비즈니스 데이터 카탈로그 만들기 및 관리(예: Amazon SageMaker Catalog) |
| 2.4.6 | Describe vectorization concepts (for example, Amazon Bedrock knowledge base). | 벡터화 개념 설명(예: Amazon Bedrock Knowledge Base) |
| 4.1.7 | Use domain, domain units, and projects for SageMaker Unified Studio. | SageMaker Unified Studio의 도메인, 도메인 단위 및 프로젝트 사용 |
| 4.5.6 | Manage data access through Amazon SageMaker Catalog projects. | Amazon SageMaker Catalog 프로젝트를 통해 데이터 액세스 관리 |
| 4.5.7 | Describe governance data framework and data sharing patterns. | 거버넌스 데이터 프레임워크 및 데이터 공유 패턴 설명 |

### 5.2 개정 Skill 11개 — 문구 변화 (v1.0 원문 → v1.1)

| Skill | v1.0 (Knowledge/Skills 원문) | v1.1 | 변화 요점 |
|---|---|---|---|
| 1.4.8 | Knowledge of: Infrastructure as code (IaC) for repeatable deployments (for example, AWS CDK, AWS CloudFormation) | Use infrastructure as code (IaC) for repeatable resource deployment (CloudFormation, CDK) | Knowledge → Skill 승격 |
| 2.1.3 | Skills in: Applying storage services to appropriate use cases (for example, Amazon S3) | Apply storage services to appropriate use cases (for example, using indexing algorithms like HNSW with Amazon Aurora PostgreSQL and using Amazon MemoryDB for fast key/value pair access) | 예시가 S3 → Aurora PostgreSQL HNSW / MemoryDB로 교체 |
| 2.2.2 | Skills in: Building and referencing a data catalog | Build and reference a **technical** data catalog (AWS Glue Data Catalog, Apache Hive metastore) | "technical" 명시 — 2.2.6 비즈니스 카탈로그와 대비 |
| 2.4.4 | Skills in: Establishing data lineage by using AWS tools (for example, Amazon SageMaker ML Lineage Tracking) | …(for example, Amazon SageMaker ML Lineage Tracking and Amazon SageMaker Catalog) | 예시에 SageMaker Catalog 추가 |
| 3.1.6 | Skills in: Preparing data transformation (for example, AWS Glue DataBrew) | Prepare data for transformation (for example, AWS Glue DataBrew and Amazon SageMaker Unified Studio) | 예시에 SageMaker Unified Studio 추가 |
| 3.2.3 | Skills in: Using Athena to query data or to create views | Use SQL in Redshift and Athena to query data or to create views | Athena → Redshift + Athena |
| 4.2.5 | Knowledge of: Authorization methods (role-based, policy-based, tag-based, and attribute based) | Apply authorization methods that address business needs (role-based, tag-based, and attribute-based) | "policy-based" 삭제, Knowledge → Skill |
| 4.2.6 | Knowledge of: Principle of least privilege as it applies to AWS security | Construct custom policies that meet the principle of least privilege | Knowledge → Skill(정책 작성) |
| 4.3.4 | Skills in: Enabling encryption in transit for data | Enable encryption in transit or before transit for data | "or before transit"(전송 전 = 클라이언트 측 암호화 뉘앙스) 추가 |
| 4.5.4 | Skills in: Managing configuration changes that have occurred in an account (for example, AWS Config) | Viewing configuration changes that have occurred in an account (for example, AWS Config) | Managing → Viewing |
| 4.5.5 | Knowledge of: Data sovereignty | Maintain data sovereignty | Knowledge → Skill |

### 5.3 범위 내/외 서비스 변경 (EN revisions 페이지)

| 구분 | 서비스 |
|---|---|
| 범위 내 목록에 **추가** | Amazon Aurora · Amazon Q · Amazon Bedrock · Amazon Kendra · AWS Data Exchange · Amazon S3 Tables |
| 범위 내 목록에서 **제거** | AWS Cloud9 · AWS CodeCommit · AWS Schema Conversion Tool (AWS SCT) |
| 범위 외 목록에 추가 | (없음) |
| 범위 외 목록에서 제거(서비스 변경·지원 중단에 따름) | Amazon Honeycode · Amazon WorkDocs · Amazon Timestream · Amazon CodeWhisperer |

| # | 항목 | 내용 | 인용 | 출처 |
|---|---|---|---|---|
| R1 | 신규 Skill 예시(마지막 항목) | Skill 4.5.7 신규 | "Skill 4.5.7: Describe governance data framework and data sharing patterns." | https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-revisions.html |
| R2 | SCT 범위 제거 | 범위 내 목록에서 제거(그러나 Skill 2.4.3 예시에는 여전히 AWS SCT 언급 — §6.2·`99-gaps.md` 참조) | "AWS Schema Conversion Tool (AWS SCT)" | https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-revisions.html |

## 6. 범위 내 AWS 서비스 (공식 목록 그대로) + 명칭 메모

출처: https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-in-scope-services.html (EN), https://docs.aws.amazon.com/ko_kr/aws-certification/latest/data-engineer-associate-01/dea-01-in-scope-services.html (KO) · 조회일 2026-10-17. 목록 자체가 "non-exhaustive and is subject to change"(비전수·변경 가능)라고 명시한다.

### 6.1 공식 목록 (카테고리별, 원문 표기)

- **Analytics**: Amazon Athena · Amazon EMR · AWS Glue · AWS Glue DataBrew · AWS Lake Formation · Amazon Kinesis Data Firehose · Amazon Kinesis Data Streams · Amazon Managed Service for Apache Flink · Amazon Managed Streaming for Apache Kafka (Amazon MSK) · Amazon OpenSearch Service · Amazon Quick · Amazon SageMaker AI
- **Application Integration**: Amazon AppFlow · Amazon EventBridge · Amazon Managed Workflows for Apache Airflow (Amazon MWAA) · Amazon SNS · Amazon SQS · AWS Step Functions
- **Cloud Financial Management**: AWS Budgets · AWS Cost Explorer
- **Compute**: AWS Batch · Amazon EC2 · AWS Lambda · AWS SAM
- **Containers**: Amazon ECR · Amazon ECS · Amazon EKS
- **Database**: Amazon DocumentDB · Amazon DynamoDB · Amazon Keyspaces · Amazon MemoryDB for Redis · Amazon Neptune · Amazon RDS · Amazon Aurora · Amazon Redshift
- **Developer Tools**: AWS CLI · AWS CloudFormation · AWS CDK · AWS CodeBuild · AWS CodeDeploy · AWS CodePipeline · Amazon Q
- **Web and Mobile**: Amazon API Gateway
- **Machine Learning**: Amazon SageMaker AI · Amazon Bedrock · Amazon Kendra
- **Management and Governance**: AWS CloudTrail · Amazon CloudWatch · Amazon CloudWatch Logs · AWS Config · Amazon Managed Grafana · AWS Systems Manager · AWS Well-Architected Tool · AWS Data Exchange
- **Migration and Transfer**: AWS Application Discovery Service · AWS Application Migration Service · AWS DMS · AWS DataSync · AWS Snow Family · AWS Transfer Family
- **Networking and Content Delivery**: Amazon CloudFront · AWS PrivateLink · Amazon Route 53 · Amazon VPC
- **Security, Identity, and Compliance**: IAM · AWS KMS · Amazon Macie · AWS Secrets Manager · AWS Shield · AWS WAF
- **Storage**: AWS Backup · Amazon EBS · Amazon EFS · Amazon S3 · Amazon S3 Tables · Amazon S3 Glacier · Amazon S3 Tables *(원문에 "Amazon S3 Tables"가 두 번 나옴 — EN·KO 동일)*

범위 외 목록(공식, 요약): Analytics — Amazon FinSpace · Business Applications — Alexa for Business, Amazon Chime, Amazon Connect, AWS IQ, Amazon WorkMail · Compute — AWS App Runner, AWS Elastic Beanstalk, Amazon Lightsail, AWS Outposts, AWS Serverless Application Repository · Containers — ROSA · Developer Tools — AWS FIS, AWS X-Ray · Frontend Web and Mobile — AWS Amplify, AWS AppSync, AWS Device Farm, Amazon Location Service, Amazon Pinpoint, Amazon SES · IoT 전반(FreeRTOS, IoT 1-Click·Device Defender·Device Management·Events·FleetWise·RoboRunner·SiteWise·TwinMaker) · Machine Learning — Amazon DevOps Guru · Management and Governance — AWS Activate, AWS Managed Services (AMS) · Media Services 전반 · Migration and Transfer — AWS Mainframe Modernization, AWS Migration Hub · Storage — EC2 Image Builder. 출처: https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-out-of-scope-services.html

> **학습 범위 힌트**: 범위 내 목록에 **없는** 서비스(예: Amazon DataZone·SageMaker Unified Studio를 별도 항목으로 두지 않음, AWS Clean Rooms, IAM Identity Center, Amazon Kinesis Video Streams, Amazon Timestream)는 Skill 문구에 직접 등장하지 않는 한 우선순위를 낮춘다. 단 Skill 문구가 우선이다 — 예: Skill 4.1.7·2.2.6·4.5.6이 SageMaker Unified Studio/Catalog를 직접 요구한다(범위 내 목록에는 "Amazon SageMaker AI"만 있음).

### 6.2 명칭 불일치·현행화 메모 (가이드 표기 vs 현행 공식 표기)

| # | 항목 | 내용 | 인용 | 출처 |
|---|---|---|---|---|
| N1 | Kinesis Data Firehose | 가이드 목록은 "Amazon Kinesis Data Firehose"지만 2024-02-12에 **Amazon Data Firehose**로 개명 | "Amazon Kinesis Data Firehose has been renamed to Amazon Data Firehose." | https://aws.amazon.com/blogs/compute/amazon-kinesis-firehose-data-transformation-with-aws-lambda/ |
| N2 | QuickSight → Quick | 가이드 목록은 "Amazon Quick", Skill 3.2.1 문구는 "Amazon QuickSight". 공식 문서: Quick은 QuickSight에서 진화했고 QuickSight는 Quick 안의 **Amazon Quick Sight** 기능으로 계속됨 | "Amazon Quick evolved from Amazon QuickSight." | https://docs.aws.amazon.com/quick/latest/userguide/what-is.html |
| N3 | 가이드 목록의 표기 | 범위 내 목록에는 구명칭 "Amazon Kinesis Data Firehose"와 "Amazon MemoryDB for Redis"가 그대로 남아 있음(Skill 2.1.3 문구는 "Amazon MemoryDB") | "Amazon Kinesis Data Firehose" | https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-in-scope-services.html |
| N4 | MemoryDB 엔진 | MemoryDB는 2024-10-08부터 Valkey 지원(현행 제품명 표기는 2.1 노트에서 확인) | "MemoryDB now supports Valkey." | https://docs.aws.amazon.com/memorydb/latest/devguide/doc-history.html |

- 시험은 일부 서비스를 **약칭**으로 출제한다(M19). 따라서 학습문서에는 "공식 전체 명칭 + 시험 약칭" 병기를 권장한다(예: Amazon Data Firehose = "Firehose").
- AWS SCT: v1.1에서 범위 내 목록에서 제거됐지만 Skill 2.4.3 본문 예시에는 남아 있다 → Task 2.4 노트와 `99-gaps.md` 참조.

## 7. 레포 `flutter_app/assets/exam_guides/DEA-C01.json` ↔ 공식 가이드 불일치 목록

비교 방법: 공식 KO 가이드(도메인 1~4 페이지의 `.md` 원문)와 EN 가이드를 프로그램으로 파싱해 JSON과 대조(최초 2026-10-17, 2026-10-19 재대조에서 결과 동일 — 스크립트는 레포 밖 임시 경로, 레포 무변경).
**결론: 대조 결과 구조·수치는 일치하고, 문구 불일치는 아래 8건뿐이다(빈 목록이 아님). "일치"로 적은 항목은 실제 대조한 것이고, 대조하지 못한 항목은 따로 적었다.**

**일치 (불일치 없음)**
- 시험 개요: level `Associate`, passingScore `720`, scoredQuestions `50`, unscoredQuestions `15`, durationMinutes `130` — 공식 가이드·인증 페이지와 일치.
- 도메인 4개의 번호·한글명·비중(34/26/22/18) — KO 가이드와 일치, EN 비중과도 일치.
- Task 17개의 번호·한글 제목 — KO 가이드와 일치.
- Skill 개수(1.1:12 · 1.2:10 · 1.3:4 · 1.4:11 · 2.1:8 · 2.2:6 · 2.3:6 · 2.4:6 · 3.1:9 · 3.2:6 · 3.3:8 · 3.4:5 · 4.1:7 · 4.2:6 · 4.3:4 · 4.4:5 · 4.5:7 = 120)와 순서 — KO·EN 가이드와 일치. `knowledge: []`는 v1.1의 통합형 구조와 부합.
- `sourceUrl` — KO 메인 가이드 페이지.
- `code` = `DEA-C01`, `slug` = `data-engineer-associate-01` — 가이드 URL 경로의 시험 식별자와 동일.

**대조하지 못한(= JSON에 대응 필드가 없어 비교 불가) 항목**: 가이드 버전/게시일, v1.1 신규·개정 표시, Skill 번호(JSON은 번호 없이 배열 순서만 가짐 — 순서·개수로 대응시켰고 모두 일치). 이 셋은 "일치"가 아니라 "비교 대상 아님"이다.

**불일치 8건 — 모두 "서비스명 약칭 vs 전체명" 문구 차이(의미 동일)**: JSON은 서비스명을 전체명으로 풀어 쓴 문구이고, 현행 공식 KO 페이지는 약칭을 쓴다(인증 페이지 M19의 "short names" 방침과 부합).

| Skill | 현행 공식 KO 가이드 | 레포 JSON | 차이 |
|---|---|---|---|
| 1.1.1 | …AWS DMS, AWS Glue, Amazon Redshift). | …AWS Database Migration Service(AWS DMS), AWS Glue, Amazon Redshift) | DMS 전체명 / 끝 마침표 |
| 1.2.1 | (예: Amazon EKS, Amazon ECS) | (예: Amazon Elastic Kubernetes Service(Amazon EKS), Amazon Elastic Container Service(Amazon ECS)) | EKS·ECS 전체명 |
| 1.3.4 | 알림 서비스를 사용하여 **알림을 전송**(예: Amazon SNS, Amazon SQS) | 알림 서비스를 사용하여 **알림 전송**(예: Amazon Simple Notification Service(Amazon SNS), Amazon Simple Queue Service(Amazon SQS)) | 조사 "을" + SNS·SQS 전체명 |
| 1.4.6 | AWS SAM을 사용하여 … | AWS Serverless Application Model(AWS SAM)을 사용하여 … | SAM 전체명 |
| 1.4.8 | AWS CloudFormation 및 AWS CDK | AWS CloudFormation 및 AWS Cloud Development Kit(AWS CDK) | CDK 전체명 |
| 2.4.3 | (예: AWS SCT 및 AWS DMS 스키마 변환 사용) | (예: AWS 스키마 변환 도구(AWS SCT) 및 AWS Database Migration Service(AWS DMS) 스키마 변환 사용) | SCT·DMS 전체명 |
| 4.1.2 | IAM 그룹, 역할, 엔드포인트, 서비스 생성 및 업데이트 | AWS Identity and Access Management(AWS IAM) 그룹, 역할, 엔드포인트 및 서비스 생성 및 업데이트 | IAM 전체명 / "및" 위치 |
| 4.3.2 | 암호화 키를 사용하여 데이터 **암호화 또는 해독**(예: AWS KMS) | 암호화 키를 사용하여 데이터 **암호화하거나 암호 해독**(예: AWS Key Management Service(AWS KMS)) | KMS 전체명 + 표현 차이 |

**JSON에 없는 정보(제안)**: 가이드 버전(1.1)·게시일(2025-12-12) 필드가 없다 — `guideVersion`/`guidePublished` 추가를 제안한다(`99-gaps.md`에 수정 제안으로 기록). 8건의 문구는 기능 영향이 없고, 학습 사이트에서는 풀네임이 오히려 유용할 수 있으므로 **수정 필수는 아님**(선택).

## 8. 학습 자원 메모 (공식, 접근 불가 항목 포함)

- 인증 페이지는 AWS Skill Builder의 4단계 시험 준비 계획(공식 연습문제 세트·프리테스트·공식 연습 시험)을 안내한다. 이 자원은 로그인 필요 — 본 노트 작업에서는 열람하지 않았고, 시험 덤프류 사이트도 사용하지 않았다.
- 인증 페이지의 관련 자격: "AWS Data Streaming Demonstrated", "AWS Data Lakehouse Demonstrated", "AWS Data Visualization Demonstrated"(시험 범위와 무관). 다음 단계 추천은 Security - Specialty.

## 9. 노트 산출물 현황 (Task별 출처·사실·검증, 2026-10-19 최종 자동 검증)

`tasks/<n>.md` 17개 전부 6개 섹션(핵심 개념 · 시험에서 묻는 방식 · 흔한 함정·혼동 짝 · 사실·숫자 · 자가 점검 문항 후보 · 출처 목록)이 채워져 있다. 항목별 gaps는 `99-gaps.md`.

| Task | 제목 (EN / KO) | Skill | 출처 | 사실·숫자 행 | 인용 | 원문 대조 일치 | 문항 후보 | gaps | 자동 검증 |
|---|---|---|---|---|---|---|---|---|---|
| 1.1 | Perform data ingestion / 데이터 수집 수행 | 12 | 56 | 124 | 187 | 187 | 5 | 26 | 통과 |
| 1.2 | Transform and process data / 데이터 변환 및 처리 | 10 | 61 | 97 | 163 | 163 | 5 | 26 | 통과 |
| 1.3 | Orchestrate data pipelines / 데이터 파이프라인 오케스트레이션 | 4 | 38 | 96 | 120 | 120 | 5 | 11 | 통과 |
| 1.4 | Apply programming concepts / 프로그래밍 개념 적용 | 11 | 63 | 84 | 136 | 136 | 5 | 13 | 통과 |
| 2.1 | Choose a data store / 데이터 스토어 선택 | 8 | 66 | 97 | 163 | 163 | 5 | 26 | 통과 |
| 2.2 | Understand data cataloging systems / 데이터 카탈로그 시스템 이해 | 6 | 32 | 91 | 96 | 96 | 5 | 11 | 통과 |
| 2.3 | Manage the lifecycle of data / 데이터의 수명 주기 관리 | 6 | 34 | 144 | 150 | 150 | 5 | 18 | 통과 |
| 2.4 | Design data models and schema evolution / 데이터 모델 및 스키마 진화 설계 | 6 | 38 | 78 | 124 | 124 | 5 | 14 | 통과 |
| 3.1 | Automate data processing by using AWS services / AWS 서비스를 사용하여 데이터 처리 자동화 | 9 | 51 | 151 | 181 | 181 | 5 | 14 | 통과 |
| 3.2 | Analyze data by using AWS services / AWS 서비스를 사용하여 데이터 분석 | 6 | 25 | 39 | 73 | 73 | 5 | 13 | 통과 |
| 3.3 | Maintain and monitor data pipelines / 데이터 파이프라인 유지 관리 및 모니터링 | 8 | 39 | 52 | 68 | 68 | 5 | 16 | 통과 |
| 3.4 | Ensure data quality / 데이터 품질 보장 | 5 | 20 | 30 | 56 | 56 | 5 | 8 | 통과 |
| 4.1 | Apply authentication mechanisms / 인증 메커니즘 적용 | 7 | 43 | 63 | 99 | 99 | 5 | 13 | 통과 |
| 4.2 | Apply authorization mechanisms / 권한 부여 메커니즘 적용 | 6 | 25 | 40 | 71 | 71 | 5 | 13 | 통과 |
| 4.3 | Ensure data encryption and masking / 데이터 암호화 및 마스킹 보장 | 4 | 40 | 66 | 120 | 120 | 5 | 15 | 통과 |
| 4.4 | Prepare logs for audit / 감사용 로그 준비 | 5 | 23 | 35 | 60 | 60 | 5 | 11 | 통과 |
| 4.5 | Understand data privacy and governance / 데이터 프라이버시 및 거버넌스 이해 | 7 | 28 | 44 | 78 | 78 | 5 | 15 | 통과 |
| **합계** | | **120** | **682** | **1331** | **1945** | **1945** | **85** | **263** (+전역 11) | |

- **"원문 대조 일치"의 뜻**: 사실·숫자 표의 인용문(영어 원문, ≤15단어)이 해당 URL의 현재 페이지 텍스트(docs.aws.amazon.com은 `.md` 원문, 그 외는 HTML 텍스트)에 공백·마크다운 서식 정규화 후 **문자열로 포함**됨을 프로그램으로 확인한 건수다. 인용이 "값·내용" 열의 주장을 **의미상** 뒷받침하는지는 기계로 검증하지 않았고 표본 점검만 했다(문항화 전 사람 검수 필수).
- **자동 검증 항목**: ① 노트 머리의 Skill 원문 표(EN·KO 120개)가 스켈레톤과 같고 2026-10-19 라이브 가이드와 문자 단위로 동일 ② TODO 0·섹션 6개·순서 ③ 본문 `[S번호]` ↔ 출처 목록 일치(참조되지 않는 출처 0) ④ 모든 출처에 URL·조회일 ⑤ 모든 사실 행에 인용+URL ⑥ 인용 15단어 이내 ⑦ 모든 출처 URL 도달 가능 ⑧ 문항 후보 3~5개(각각 A~D 보기·정답·근거 URL) ⑨ 노트 머리의 모든 Skill 번호가 "핵심 개념"에 등장. 17개 노트 모두 오류·경고 0건.
- **조회일**: 노트 머리의 조회일 2026-10-17은 최초 수집일이다. 2026-10-19 재개 후 새로 조회한 출처는 각 노트 "출처 목록"에 2026-10-19로 적혀 있다(출처별 날짜가 정확한 값).
- **문항 후보 85개는 모두 미검수 재료**다(정답·근거 URL은 있으나 `verified:false` 취급, 취합 세션이 문항을 쓰고 사람이 검수).
- 출처 수가 브리프 권장(12~30개)을 넘는 노트가 많은 것은 Skill이 서비스 여러 개에 걸치기 때문이며, 분할 제안은 `99-gaps.md` §2.

## 10. 출처 목록

| 번호 | 제목 | URL | 조회일 | 유형 |
|---|---|---|---|---|
| S1 | AWS Certified Data Engineer - Associate (DEA-C01) 시험 가이드 (EN, v1.1) | https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01.html | 2026-10-17 | 공식 |
| S2 | 시험 가이드 (KO) | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01.html | 2026-10-17 | 공식 |
| S3 | Revisions (EN) | https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-revisions.html | 2026-10-17 | 공식 |
| S4 | 개정 (KO) | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/data-engineer-associate-01/dea-01-revisions.html | 2026-10-17 | 공식 |
| S5 | Content Domain 1 (EN) | https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain1.html | 2026-10-17 | 공식 |
| S6 | Content Domain 2 (EN) | https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain2.html | 2026-10-17 | 공식 |
| S7 | Content Domain 3 (EN) | https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain3.html | 2026-10-17 | 공식 |
| S8 | Content Domain 4 (EN) | https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain4.html | 2026-10-17 | 공식 |
| S9 | In-Scope AWS Services (EN) | https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-in-scope-services.html | 2026-10-17 | 공식 |
| S10 | 범위 내 AWS 서비스 (KO) | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/data-engineer-associate-01/dea-01-in-scope-services.html | 2026-10-17 | 공식 |
| S11 | Out-of-Scope AWS Services (EN) | https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-out-of-scope-services.html | 2026-10-17 | 공식 |
| S12 | AWS Certified Data Engineer - Associate (인증 페이지) | https://aws.amazon.com/certification/certified-data-engineer-associate/ | 2026-10-17 | 공식 |
| S13 | AWS Certification retirements and launches (블로그) | https://aws.amazon.com/blogs/training-and-certification/aws-certification-retirements-and-launches/ | 2026-10-17 | 공식블로그 |
| S14 | Amazon Kinesis Firehose Data Transformation with AWS Lambda (개명 공지 포함) | https://aws.amazon.com/blogs/compute/amazon-kinesis-firehose-data-transformation-with-aws-lambda/ | 2026-10-17 | 공식블로그 |
| S15 | What is Amazon Quick? | https://docs.aws.amazon.com/quick/latest/userguide/what-is.html | 2026-10-17 | 공식 |
| S16 | Document history for the MemoryDB User Guide | https://docs.aws.amazon.com/memorydb/latest/devguide/doc-history.html | 2026-10-17 | 공식 |
| S17 | (구) 시험 가이드 PDF — 잔존, v1.1 이전 | https://d1.awsstatic.com/training-and-certification/docs-data-engineer-associate/AWS-Certified-Data-Engineer-Associate_Exam-Guide.pdf | 2026-10-17 | 공식(구버전) |
| S18 | 시험 가이드 PDF 렌더 (EN) | https://docs.aws.amazon.com/pdfs/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01.pdf | 2026-10-17 | 공식 |
| S19 | 시험 가이드 PDF 렌더 (KO) | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01.pdf | 2026-10-17 | 공식 |
