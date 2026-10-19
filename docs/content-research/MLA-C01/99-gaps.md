# MLA-C01 gaps — 상충·불확실·확인 필요, 레포 JSON 수정 제안

- **조회일**: 2026-10-17
- **구성**: A. 시험·가이드 공통 항목(리서치 세션 직접 조사) / B. Task별 항목(12개 노트 섹션 9 취합) / C. 레포 `MLA-C01.json` 수정 제안
- **우선순위 표시**: 🔴 저작 방향에 영향 · 🟠 정확성·표기에 영향 · 🟡 참고 · ✅ 해소됨

---

## A. 시험·가이드 공통 항목

### G-0-1 🔴 [확인 요청] C01 문서의 수명 — 한국어 C01도 2027-01-14에 모든 언어에서 종료
- **상황**: 사용자 결정(C01 12 Task + C02 델타 부록)은 유효하다. 다만 한국어 C01도 **2027-01-14(C02 GA)** 에 종료된다(2026-10-17 기준 89일 남음). 그 이후 한국어 응시자는 C02만 볼 수 있다.
- **근거**: `00-overview.md` 〔C2, C17〕 — 공식 블로그 "January 14, 2027 – GA delivery begins (all languages); MLA-C01 retired in all languages".
- **제안**: 학습문서 머리말에 'MLA-C01 응시 가능 기간 ~2027-01-14' 표기, 말미 부록에 C02 델타(`97-c02-delta.md`) 반영. C02 완전 대응이 필요해지면 C02 12 Task 노트를 별도 위임.

### G-0-2 ✅ [해소됨] C02 한국어 가이드 문서 공개 여부
- **경위**: README 초안은 "C02 공식 가이드는 영문만 공개"였다. 2026-10-17에 **한국어 C02 가이드·비교 페이지가 docs에 이미 공개**돼 있음을 MLA 세션이 일반 HTTP 200으로 확인했고, 컨트롤러 세션도 직접 열어 확인한 뒤 README를 정정했다.
- **구분**: 가이드 **문서**의 한국어판은 공개, 시험 **응시 언어**의 한국어는 GA 시점(공식: "Additional languages … will be available at general availability"). 둘은 서로 모순이 아니다. 〔`00-overview.md` C18~C19, `97-c02-delta.md` D1~D2, D7〕

### G-0-3 🟠 [상충] 문항 유형 서술이 판본마다 다르다
- **상황**: 영문 PDF v1.0은 5종(선다형·복수 응답·순서 배열·매칭·**Case study**), ko HTML 가이드는 4종(Case study 없음), C02 가이드는 2종(선다형·복수 응답). 현행 C01 시험에서 어떤 유형이 나오는지 공식 자료로 확정할 수 없다.
- **근거**: `00-overview.md` 〔M13, M14, C12〕.
- **제안**: 사이트의 '시험 형식' 안내는 "선다형·복수 응답 중심, 순서 배열·매칭 등 가능" 정도로 쓰고 Case study는 단정하지 않는다. 문항 저작은 4지선다 단일 정답(레포 규칙)으로 충분.

### G-0-4 🟠 [미확인] 공식 가이드 판본·발행일
- **상황**: ko HTML 가이드에 버전·개정일 표기가 없다. 영문 PDF는 'Version 1.0' 이나 발행일이 본문에 없다(HTTP `Last-Modified` 2025-02-13만 확인, 공식 발행일 아님). ko HTML은 PDF v1.0 이후 갱신된 흔적이 있다(서비스 표기 SageMaker AI·Amazon Quick, 문항 유형 차이). 영문 HTML C01 가이드는 404이며 사유는 확인하지 못했다(ja_jp·zh_cn·ko_kr C01 페이지는 존재).
- **시도했으나 실패**: 웹 아카이브(archive.org)로 영문 C01 HTML의 과거 본문을 확인하려 했으나 HTTP 429로 거절됨(같은 호출을 반복하지 않음).
- **제안**: 사이트 출처 표기는 "공식 시험 가이드 ko_kr (조회일 2026-10-17)"로 하고, 가이드 갱신 여부는 저작 시점에 다시 확인.

### G-0-5 🔴 [상충] 유효 기간 표기 — 공식 비교 페이지 vs 블로그·자격증 페이지 (언어별 일정)
- **상황**: 공식 **비교 페이지**(한국어·영문)는 C01을 "2026-09-28까지", C02를 "2026-09-29부터"라고 **언어 구분 없이** 적는다. 반면 **블로그와 자격증 페이지**는 **한국어·일본어·중국어 C01은 C02 GA(2027-01-14)까지 유지**된다고 명시한다. 두 공식 문서가 표면상 불일치한다.
- **해석 제안**: 비교 페이지의 날짜는 영문 시험 기준으로 읽어야 일관되나, 비교 페이지가 이를 명시하지는 않는다(해석이며 공식 설명은 없음).
- **제안(컨트롤러 지시 반영)**: **학습문서는 블로그의 언어별 일정을 기준으로 쓰고, 각주로 비교 페이지와의 차이를 명시한다.**

| # | 항목 | 값/내용 | 인용(원문 15단어 이하) | 출처 URL | 조회일 |
|---|---|---|---|---|---|
| X1 | 비교 페이지(한국어) | C01 '2026-09-28까지 사용' — 언어 구분 없음 | "MLA-C01 시험(2026년 9월 28일까지 사용)" | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-02/mla-02-comparison.html | 2026-10-17 |
| X2 | 비교 페이지(영문) | 위와 동일 | "the MLA-C01 exam (in use until September 28, 2026)" | https://docs.aws.amazon.com/aws-certification/latest/machine-learning-engineer-associate-02/mla-02-comparison.html | 2026-10-17 |
| X3 | 블로그 September 2026 | 한·일·중 C01은 베타 기간 동안 유지 | "will remain available in Japanese, Korean, and Simplified Chinese during the beta period" | https://aws.amazon.com/blogs/training-and-certification/september-2026-new-offerings/ | 2026-10-17 |
| X4 | 자격증 페이지 | 한·일·중 C01은 C02 GA까지 | "MLA-C01 in Korean, Japanese, and Simplified Chinese remains available until general availability of MLA-C02." | https://aws.amazon.com/certification/certified-machine-learning-engineer-associate/ | 2026-10-17 |
| X5 | 블로그 September 2026 | GA 2027-01-14에 전 언어 C01 종료 | "January 14, 2027 – GA delivery begins (all languages); MLA-C01 retired in all languages" | https://aws.amazon.com/blogs/training-and-certification/september-2026-new-offerings/ | 2026-10-17 |

### G-0-6 🟠 [상충] C02 GA 일정 표현이 공식 문서마다 다르다
- **상황**: 블로그 September 2026 = **2027-01-14** / 블로그 'Updates to … (MLA-C02)' = '2027년 초(early 2027)' / 자격증 페이지 = GA 'TBD'.
- **근거**: `00-overview.md` 〔C2~C4〕, `97-c02-delta.md` §1.
- **제안**: 가장 구체적인 September 2026 블로그를 따르되 "공식 일정 변경 가능"을 표기.

### G-0-7 🟠 [상충] Mechanical Turk 폐쇄일이 하루 다르다
- **상황**: SageMaker 문서 "will permanently close on September 30, 2026" vs What's New(2026-09-29 게시) "no longer available as of September 29, 2026".
- **제안**: 문서에는 "2026년 9월 말(29~30일) 폐쇄"로 쓰고 두 근거를 병기.

### G-0-8 🟠 [미확인] Amazon QuickSight → Quick Suite → Quick 개명의 공식 공지
- **상황**: QuickSight→Quick Suite(2025-10)는 블로그로 확인했다. 이후 공식 문서가 'Amazon Quick'(QuickSight는 그 안의 'Quick Sight' 기능)으로 표기하는 것도 확인했지만 **Quick Suite→Quick 개명 공지 자체는 찾지 못했다**.
- **영향**: 가이드 표기가 세 가지(ko Skill 'Amazon Quick Sight', ko 범위 목록 'Amazon Quick', 영문 PDF 'Amazon QuickSight')라 문항 보기·해설에서 이름이 흔들린다.
- **제안**: 해설에 "Amazon Quick(구 QuickSight)" 형태로 병기하고, 개명 공지는 저작 시점에 재확인.

### G-0-9 🟠 [미확인] SageMaker AI '신규 고객 중단' 묶음의 개별 확인 범위
- **상황**: 공식 단일 공지(aws.amazon.com/sagemaker/ai/features/)가 10개 기능(Mechanical Turk, Ground Truth, A2I, Studio Lab, Model Monitor, Clarify, Debugger, Role Manager, Geospatial, Profiler)을 명시한다. 개별 공지 문구는 Clarify·Model Monitor·Role Manager·Debugger·Ground Truth·A2I·Profiler까지 확인했고 **Studio Lab·Geospatial 개별 문구는 읽지 않았다**(페이지는 존재, HTTP 200).
- **링크 오류**: What's New(2026-06-30)가 Debugger 공지로 링크한 `…/model-debugger-change.html` 은 실제로는 SageMaker 문서 목차로 리다이렉트된다. 올바른 페이지는 `…/debugger-availability-change.html`.
- **표기 차이**: SageMaker AI features 페이지는 'SageMaker Ground Plus'로, What's New는 'Ground Truth Plus'로 적는다(같은 서비스를 가리키는지는 문서에 명시돼 있지 않다 — What's New 표기를 사용).

### G-0-10 🟡 [한계] 서비스 수명 목록의 포괄성
- **상황**: AWS 'Lifecycle Changes' 페이지(https://docs.aws.amazon.com/general/latest/gr/service-lifecycle.html)는 용어 정의만 제공하고 서비스 목록은 가져오지 못했다. 그래서 `00-overview.md` §7 은 What's New 공지 4건(2025-10-13 · 2026-03-31 · 2026-06-30 · 2026-09-29)과 개별 서비스 페이지에 근거한다. 이 4건에 없는 서비스에 별도 공지가 있을 수 있다.
- **제안**: 문항 저작 시 해당 서비스의 공식 페이지 상단 'availability' 안내를 한 번 더 확인(특히 Lex·Polly·Textract·Transcribe·Translate·Personalize·DataBrew·Glue Data Quality).

### G-0-11 🟡 [참고] 한국어 가이드 번역 문제 — 공식 문구를 바꿀 수 없다
- **상황**: "quantizing"→"정량화"(양자화), 3.2 기술 문구가 영문의 나열 형식을 한 문장으로 합쳐 모호해짐, 1.2 지식 문장 문법 오류 등(`00-overview.md` §8).
- **제안**: 문항 `skill` 필드에는 한국어 원문을 그대로 쓰고, 학습문서 해설에서 영문 의미를 보조 설명.

### G-0-12 🟡 [참고] 시험은 일부 서비스를 공식 약칭으로 표기한다
- **상황**: 자격증 페이지는 "This exam uses short names of some AWS services." 라고 안내한다(예: Amazon Simple Notification Service → Amazon SNS). 문항 보기에서 서비스명을 쓸 때 약칭을 쓰는 편이 시험 표기와 맞다.
- **근거**: https://aws.amazon.com/certification/certified-machine-learning-engineer-associate/ , https://docs.aws.amazon.com/aws-certification/latest/machine-learning-engineer-associate-02/mla-02-service-mentions.html

### G-0-13 🟡 [참고] docs 페이지는 `.md` 렌디션으로 리다이렉트된다
- **상황**: AWS 문서 MCP로 `.html` 을 열면 `.md` 로 리다이렉트된 본문이 반환된다. 사람이 열 수 있는 URL은 `.html` 이다. 이 노트의 출처 URL은 모두 `.html`(또는 공식 정식 URL)로 적었고 인용은 HTML 텍스트로 자동 대조했다.

### G-0-14 🟡 [한계] 번호가 건너뛰는 C02 스킬의 대응 미설명
- **상황**: 비교 페이지는 '추가' 스킬만 번호로 나열(예: 1.1.7, 1.1.8)하고 나머지(1.1.1~1.1.6)가 C01의 어느 항목인지 설명하지 않는다. C02 12 Task의 Skill 전문은 이번 범위에서 수집하지 않았다(`97-c02-delta.md` §9).

---

## B. Task별 항목 (각 노트 섹션 9 취합)

### Task 1.1 (15건) — `tasks/1-1.md` 섹션 9

- [G-1.1-1] 가이드 K1 의 "유효성이 검증된 형식 및 검증되지 않은 형식"(영문 "validated and non-validated formats")을 공식 문서가 어떻게 정의하는가? — AWS 문서 검색(검증 형식·스키마 검증 관련 질의), SageMaker 공통 데이터 형식 페이지, Firehose 형식 변환, Glue Schema Registry(KDS) 문서를 읽었으나 이 용어를 정의한 페이지는 찾지 못함. 겹칠 수 있는 메커니즘(2.3 (4))만 정리했고 같은 개념이라고 단정하지 않음 — 학습문서에서는 "공식 정의 없음"을 밝히고 2.3 (4)의 세 메커니즘을 예시로만 제시. 문항에는 이 용어를 직접 묻는 선택지를 만들지 말 것.
- [G-1.1-2] FSx for NetApp ONTAP 이 SageMaker 학습·Studio 의 직접 데이터 소스인가? — SageMaker "Setting up training jobs to access datasets"(S3·EFS·FSx for Lustre 만 명시), FSx for ONTAP S3 access point 문서(S3 API 로 접근, 데이터는 ONTAP 에 유지)와 AWS 뉴스 블로그(SageMaker 학습에 사용 가능하다고 소개)를 확인. SageMaker 문서에서 ONTAP 을 학습 채널로 직접 마운트한다는 서술은 찾지 못함 — 학습문서에는 "S3 access point 경유(S3 호환 경로)"로 쓰고, 문항은 "직접 마운트"를 정답으로 두지 말 것.
- [G-1.1-3] Kinesis Data Streams 레코드 크기와 쓰기 한도 수치가 문서마다 다른가? — Quotas 페이지는 "base64 인코딩 전 데이터 페이로드 최대 10 MiB", `PutRecord` 행은 샤드당 "최대 10 MiB/s", `PutRecords` 행은 "1 MB/s" 로 적고, Terminology 페이지는 "데이터 blob 최대 1 MB" 와 "샤드 쓰기 1 MB/s" 로 적음. 어느 쪽이 최신인지 문서에 표시가 없는 서술 불일치 — 문항에는 샤드당 1 MB/s·1,000 records/s(여러 페이지 일치)만 쓰고, 레코드 최대 크기는 출제 근거로 쓰지 말 것.
- [G-1.1-4] Firehose 버퍼 간격의 하한은 0초인가 60초인가? — 버퍼 힌트 표(S3 대상 0–900초, 기본 300)와 FAQ(0–900초)는 0초부터, Quota 페이지("buffer interval hints range from 60 seconds to 900 seconds")와 백업 설정 본문(60–900초)은 60초부터로 적음. 제로 버퍼링은 "애플리케이션 대상용이며 S3 백업 대상에는 불가"라는 문장도 있어 S3 주 대상에서의 적용 범위가 모호함 — 학습문서에는 "S3 기본 5 MB·300초, 간격 0–900초(문서에 따라 60초부터)"로 병기.
- [G-1.1-5] S3 최대 객체 크기는 5 TB 인가 50 TB 인가? — 현재 S3 문서(객체 개요·멀티파트 한도)는 "객체당 최대 50 TB(실제 한도 53.7 TB=48.8 TiB)"이고 AWS Storage 블로그 등 이전 자료는 5 TB 로 적음 — 2025년 이전에 만들어진 시험 대비 자료는 5 TB 를 쓸 수 있으므로, 문항은 이 수치를 정답 근거로 삼지 말고 학습문서에 "최신 문서 기준 50 TB" 주석을 달 것.
- [G-1.1-6] SageMaker 알고리즘 입력 채널 이름은 모두 `train` 인가? — "Common Data Formats for Training" 은 "모든 알고리즘에서 ChannelName 이 train 이어야 한다"고 적지만 "Parameters for Built-in Algorithms" 표는 AutoGluon-Tabular·CatBoost·LightGBM·TabTransformer 등의 채널을 `training` 으로 적음 — 알고리즘별 표를 우선하고 문항에서 채널 이름을 정답 근거로 쓰지 말 것.
- [G-1.1-7] EFS 성능 모드 권장이 자료마다 다른가? — 현재 EFS 성능 문서는 Max I/O 를 이전 세대 유형으로 두고 모든 파일 시스템에 General Purpose 를 권장함(Elastic 처리량 파일 시스템은 Max I/O 미지원). 2022년 AWS 머신러닝 블로그(https://aws.amazon.com/blogs/machine-learning/choose-the-best-data-source-for-your-amazon-sagemaker-training-job/)는 I/O worker 가 많은 학습에 Max I/O 를 선택지로 설명 — 현재 문서를 따르고 Max I/O 를 정답으로 하는 문항은 피할 것.
- [G-1.1-8] Kinesis Data Streams 의 "data delivery"(S3·Iceberg 스트리밍 테이블로 직접 전달, on-demand 모드 필요)가 시험 범위인가? — KDS Terminology 페이지와 Quotas 페이지(2026-10-17 조회)에서 확인했고 MLA-C01 가이드 Version 1.0 에는 없는 최신 기능 — 학습문서에는 각주로만 두고, 문항에서는 "KDS 단독으로 S3 적재" 를 정답으로 삼지 말 것.
- [G-1.1-9] Feature Store SDK 수집 함수 이름이 `ingest` 인가 `ingest_dataframe` 인가? — 예제 노트북(fraud detection)은 `feature_group.ingest(data_frame=..., max_workers=3, wait=True)`, 소개 노트북(introduction)은 `from sagemaker.mlops.feature_store import ingest_dataframe` 를 사용(SageMaker Python SDK 버전별 표기 차이) — 시험 용어는 `ingest`/`PutRecord` 이므로 학습문서에 두 표기를 병기.
- [G-1.1-10] Amazon MSK 가 시험 범위인가? — 가이드 K3 는 "Apache Kafka" 를 예로 들지만 부록의 범위 내 서비스 목록(Analytics 등)에는 Amazon MSK 가 없고 Kinesis·Amazon Data Firehose·Amazon Managed Service for Apache Flink 만 있음(영문 PDF Version 1.0 부록 확인) — 목록이 "non-exhaustive" 이므로 MSK 는 'Kafka 관리형 서비스'로 간략히 다루고 심화 문항은 피할 것.
- [G-1.1-11] Canvas 안의 Data Wrangler 가 가져올 수 있는 소스의 단일 정리 페이지가 있는가? — Studio Classic 문서(`data-wrangler-import`)는 S3·Athena·Redshift·Snowflake·Databricks(+EMR·Salesforce Data Cloud·SaaS)를 나열하고, Canvas 문서는 "Connect to data sources"(S3·Athena·RDS·Redshift 프로비저닝·DocumentDB·JDBC·Snowflake·Salesforce Data Cloud·SaaS 40개 이상)를 참조하라고 함. Canvas 데이터 흐름이 이 목록 전부를 그대로 지원한다고 한 문장으로 확정한 페이지는 찾지 못함 — 학습문서에는 두 목록을 구분해 적고 문항은 S3·Athena·Redshift·Snowflake 같은 공통 소스에 한정할 것.
- [G-1.1-12] FastFile 모드를 SageMaker 내장 알고리즘이 지원하는가? — "Parameters for Built-in Algorithms" 표의 입력 모드 열은 File·Pipe 만 적고 FastFile 지원 여부는 표에 없음. FastFile 일반 설명은 S3 prefix 입력에 모드 지정으로 전환 가능하다고만 함 — 문항에서 "내장 알고리즘 + FastFile" 조합을 정답으로 삼지 말 것.
- [G-1.1-13] EBS gp3/gp2 의 최대 IOPS·처리량 수치는 어디서 인용하는가? — EBS volume types 표의 해당 셀이 각주 번호와 붙어 있어 15단어 이하 원문 인용으로 안전하게 분리하지 못함(io1·io2 수치는 Provisioned IOPS 페이지에서 인용) — 학습문서에서 gp3 수치가 필요하면 표 원문을 직접 확인.
- [G-1.1-14] Firehose 개명 시점(2024-02-09)은 어느 문서로 확인하는가? — 컨트롤러 공지(N4)의 날짜를 따름. 인용한 AWS CLI 문서 문장("previously known as")에는 날짜가 없음 — 날짜를 쓰려면 AWS 공지 페이지를 추가로 확인.
- [G-1.1-15] 후보 문항이 SK1·SK4·SK6 을 덮지 않는다 — 후보 5개 한도 내에서 K1·K2·K3·SK2·SK3·SK5 를 선택함 — 학습문서 작성 시 2.6(SK6)·2.7(SK1)·2.9(SK4)와 섹션 5 사실 행(S3 Transfer Acceleration, EBS Provisioned IOPS, Glue/Athena/EMR)으로 추가 문항을 만들 것.
- 레포 `MLA-C01.json` 수정 제안: 없음 (Task 1.1 의 지식·기술 문구는 공식 ko_kr 가이드와 일치).

### Task 1.2 (17건) — `tasks/1-2.md` 섹션 9

- [G-1.2-1] DataBrew 의 2026-10-17 현재 신규 고객 가능 여부는? — 2025-10·2026-03·2026-06·2026-09 What's New 4건의 서비스 목록을 직접 읽음(DataBrew 항목 없음, Glue 는 Ray 작업 기능만 〔S97〕) + DataBrew 문서 이력 검색(가용성 변경 항목 미발견). 목록 부재는 긍정 확인이 아니다 — 학습문서에는 "공지 목록에 없음"으로만 쓰고 '정상 제공'으로 단정하지 말 것. 필요하면 컨트롤러가 AWS 수명 안내(S88)와 함께 재확인.
- [G-1.2-2] DataBrew 사전 구축 변환 수는 250인가 350인가? — 공식 DataBrew 가이드는 "over 250"(S10), 일부 AWS Big Data 블로그 본문은 "over 350"으로 서술 — 공식 문서 수치 250 만 쓰고 블로그 350 은 쓰지 않는다.
- [G-1.2-3] Data Wrangler "over 300 built-in transformations"(S5)와 DataBrew "over 250"(S10)을 비교해도 되는가? — 두 문서 모두 집계 기준을 제시하지 않는다. 수치 비교형 문항 금지, 각각 서술형 사실로만 쓴다.
- [G-1.2-4] Data Wrangler 에 이름이 binning·bucketize 인 내장 변환이나 로그 전용 변환이 있는가? — 변환 문서 목차(S2·S3)에서 확인하지 못했고 Custom formula(Spark SQL)·사용자 지정 변환·Canvas 구 노코드 함수 Log/Ln(S5)만 확인. DataBrew BUCKETIZATION·SKEWNESS 가 문서상 명확한 대응 — 학습문서는 "Data Wrangler 변환 목록에 binning 그룹 없음"으로 표현.
- [G-1.2-5] 'binary encoding'·'label encoding' 의 AWS 공식 정의나 동명 변환이 있는가? — Data Wrangler Encode categorical(S2), DataBrew 데이터 과학 단계 7종(S13), 문서 검색 결과 모두 없음. Ordinal encode(S2)와 CATEGORICAL_MAPPING(S17)이 가장 가깝지만 공식 대응표는 없다 — 일반 ML 개념으로 서술하되 AWS 변환 이름과 1:1 로 단정하지 말고, 정의 출처가 필요하면 별도 확보.
- [G-1.2-6] Ground Truth·A2I·Mechanical Turk 의 공식 대체 서비스는 무엇인가? — SageMaker AI features 공지(S85)의 "similar capabilities" 링크는 기능 목록 페이지(https://docs.aws.amazon.com/sagemaker/latest/dg/whatis-features.html, 링크 대상은 WebFetch 로만 확인)로 연결되며 구체 서비스명을 지정하지 않는다. MTurk 문서(S79)는 "대체 작업 인력 옵션으로 전환"만 안내 — 대체 서비스명은 단정하지 말고 이 두 사실만 서술.
- [G-1.2-7] Mechanical Turk 종료일 — SageMaker 문서는 9월 30일(S79), What's New 는 9월 29일 지원 종료(S84)로 하루 차이 — 학습문서에 둘 다 표기.
- [G-1.2-8] Well-Architected ML Lens 가 Ground Truth Plus 를 여전히 권장(S91)하는데 What's New 는 2026-06-30 지원 종료(S83) — 문서끼리 상충. 공지를 우선하고 Ground Truth Plus 관련 문항은 ⚠️ 와 함께 출제.
- [G-1.2-9] Feature Store SDK 메서드 이름을 무엇으로 쓸까? — 개발자 가이드 안에서 `feature_group.ingest`(S68)와 `ingest_dataframe`(https://docs.aws.amazon.com/sagemaker/latest/dg/feature-store-introduction-notebook.html)가 함께 보이고 "SDK for Python (Boto3)" 문구가 SageMaker Python SDK 와 Boto3 에 섞여 쓰인다. 시점 정확 조인 메서드도 가이드는 `point_time_accurate_join`(S62), AWS ML 블로그는 `point_in_time_accurate_join`(https://aws.amazon.com/blogs/machine-learning/build-machine-learning-ready-datasets-from-the-amazon-sagemaker-offline-feature-store-using-the-amazon-sagemaker-python-sdk/) — 문항에서 메서드명 단정 금지, 개념(ingest, point-in-time 조인) 중심.
- [G-1.2-10] Standard_V2·UpdateRecord 가 시험 가이드(Version 1.0) 범위인가? — 최신 문서(S52·S57)에 있으나 가이드 Skill 문장에는 언급이 없다 — 학습문서에는 '참고'로만 두고 문항화는 보류.
- [G-1.2-11] k-NN·k-means 등 개별 알고리즘의 스케일 민감성은? — SageMaker 알고리즘 문서 검색(https://docs.aws.amazon.com/sagemaker/latest/dg/k-nearest-neighbors.html, https://docs.aws.amazon.com/sagemaker/latest/dg/k-means.html 포함)에서 스케일 민감성 서술을 찾지 못했다. 근거가 있는 것은 Linear Learner 정규화(S90), Data Wrangler Handle outliers 문장(S2), Featurize date/time 임베딩 모드 권장(S2)뿐 — 그 밖의 알고리즘 문항은 만들지 말 것.
- [G-1.2-12] Firehose 버퍼 힌트 두 종류 — Lambda 변환 버퍼(0.2–3 MB·0–900초, S41)와 목적지 버퍼 간격 힌트(60–900초, S42)는 문서에서 따로 서술되지만 수치가 비슷해 혼동을 부른다. 6 MB 는 Lambda 동기 호출 페이로드 한도로 버퍼 상한(3 MB)과 별개 — 문항에서 어느 한도인지 명시.
- [G-1.2-13] Feature Store 온라인 스토어의 구체 지연 수치(ms)는? — S50·S52 는 low millisecond·very low latency 같은 정성 표현만 쓰고 수치가 없다 — 수치형 문항 금지.
- [G-1.2-14] Data Wrangler 문서 두 계열(Studio Classic 계열 S1·S2, Canvas 계열 S3·S4)의 차이는? — 변환 그룹 목차를 비교한 결과 이름이 같다. Canvas 문서에만 Chat for data prep 과 Canvas 처리 흐름(S6)이 추가된다. 현행 제공 위치는 Canvas 이므로 학습문서는 Canvas 기준으로 쓰고 Studio Classic 명칭을 병기.
- [G-1.2-15] A2I 유지 모드 날짜의 출처 — A2I 개요(S81)는 "no longer open to new customers" 만 서술하고 '2026-07 유지 모드'는 Textract API 문서(S82), 2026-07-30 신규 고객 불가는 What's New 2026-06 목록(S83)에서 확인 — 학습문서에는 두 근거를 병기.
- [G-1.2-16] ko_kr 번역 품질 — S92~S95 는 기계 번역(영문 우선 고지)이다. 예: Ground Truth 개요(S93)는 "MTurk, 공급업체, 비공개 인력" 중 선택 문장을 "선택한 공급업체인 Amazon Mechanical Turk 의 워커"로 옮겨 의미가 흐려진다. 한국어 용어는 S92~S95 표기(이상치 처리하기, 누락된 값 처리, 카테고리 인코딩·서수·원-핫·유사성 인코딩, 특성 저장소, 프라이빗 작업 인력)를 참고하되 서술은 영문 기준.
- [G-1.2-17] 가이드 K6 한국어 문장("만들기하는")이 어색하다 — 컨트롤러가 공식 ko_kr 가이드와 글자 단위로 일치함을 확인한 원문이다 — `MLA-C01.json` 은 수정하지 말고 학습문서에서 자연스러운 한국어로 풀어 쓴다.

### Task 1.3 (16건) — `tasks/1-3.md` 섹션 9

- [G-1.3-1] 가이드 K1은 "숫자, 텍스트 및 이미지 데이터에 대한 사전 훈련 편향 지표"를 말하는데, 텍스트·이미지 데이터에서 facet과 레이블을 어떻게 정의하고 사전 훈련 지표를 어떻게 적용하는지 설명한 공식 문서를 찾지 못했다. Clarify 문서에서 사전 훈련 편향 분석 예시는 표 형식(CSV·JSON Lines·JSON·Parquet)이고, NLP·컴퓨터 비전 구성은 SHAP 설명가능성용으로만 제시된다 — 확인한 곳: S11, S12, S13 — 제안: 학습 문서에는 "지표 정의는 facet 열과 레이블 열 기준"까지만 쓰고 텍스트·이미지 적용 방법은 쓰지 않는다.
- [G-1.3-2] Clarify 요약표(S2)와 개별 지표 페이지의 값 범위 표기가 다르다. 요약표는 KL·JS·LP·TVD를 모두 "0 ~ +∞", DPL을 [−1, +1]로 적었고, 개별 페이지는 JS [0, ln 2), LP [0, √2), TVD [0, 1), DPL (−1, 1)로 적는다. KS 페이지의 범위 문장은 "LP values"로 오기되어 있다 — 확인한 곳: S2, S4, S6~S9 — 제안: 학습 문서는 개별 지표 페이지 값을 쓰고 불일치를 각주로 남기며, 문항에서는 범위 숫자를 정답 근거로 삼지 않는다.
- [G-1.3-3] 시험 가이드 Version 1.0은 Clarify를 명시하지만 Clarify는 신규 고객에게 닫힌 Maintenance 상태다. 이 상태가 실제 출제(예: Clarify 대신 다른 도구를 묻는지)에 어떻게 반영되는지는 공식 문서로 확인할 수 없다 — 확인한 곳: S1, S19, S77 및 가이드 PDF 텍스트 — 제안: 학습 문서와 문항 해설에 ⚠️ 상태를 병기하고, 컨트롤러가 섹션 8(MLA-C02 비교)에서 MLA-C02의 대응 Task 1.3 "Validate data quality and manage bias"와 함께 서술한다.
- [G-1.3-4] Data Wrangler(Canvas) Bias Report의 지표 목록과 "기본 선택 지표"에 대해 공식 문서는 "지표를 선택한다"까지만 서술하고, 기본 지표가 CI·DPL·JS라는 설명은 AWS 블로그(S22)에만 있다. Balance data의 target column·desired ratio·이웃 수 옵션도 블로그(S25)에만 있고 공식 문서(S23)에는 연산자 설명만 있다 — 확인한 곳: S14, S15, S16, S22, S23, S25 — 제안: 해당 UI 세부는 [블로그] 근거로 표기한다.
- [G-1.3-5] SageMaker 작업 출력의 "기본 암호화" 서술이 문서마다 다르다. S43은 "AWS managed key for Amazon S3 (SSE-S3)"로 자동 암호화한다고 하고, S44·S46은 KMS 키를 주지 않으면 "역할 계정의 S3 기본 KMS 키"를 쓴다고 한다 — 확인한 곳: S43, S44, S46 — 제안: 문항에서는 "KMS 키를 지정하지 않으면 기본 암호화가 적용된다" 수준으로만 출제하고 SSE-S3 대 aws/s3 구분은 피한다.
- [G-1.3-6] SageMaker Debugger는 2026-06-30 공지의 유지보수 목록(Amazon SageMaker AI Features)에 있으나, 그 공지가 가리키는 개별 페이지(model-debugger-change.html)는 SageMaker AI 소개 페이지로 리디렉션되어 Debugger 자체의 상태 문구를 확인하지 못했다 — 확인한 곳: S77, 개별 페이지 직접 열람 — 제안: Debugger `ClassImbalance`는 혼동 짝 정도로만 다룬다.
- [G-1.3-7] "데이터 레지던시"를 한 문장으로 정의한 AWS 공식 문장을 찾지 못했다. 확인된 것은 Region 선택권·고객 동의 없는 이동 금지 약속(S73)과 Region 제한 통제(S74, S75, Control Tower 문서가 이를 "data residency controls"로 부름)다 — 확인한 곳: S73, S74, S75 — 제안: 학습 문서에 "AWS가 Region 선택과 SCP 등으로 설명하는 방식"으로 서술한다.
- [G-1.3-8] Comprehend PII 문서가 언급하는 S3 Object Lambda는 2025-10-13 공지에서 유지보수 대상(2025-11-07부터 신규 고객 불가)이다. 공지가 가리키는 개별 페이지(amazon3-ol-change.html)는 S3 소개 페이지로 리디렉션되어 개별 문구는 확인하지 못했다 — 확인한 곳: S63, S76 — 제안: 본 Task에서 S3 Object Lambda를 정답 선택지로 쓰지 않는다.
- [G-1.3-9] 본 Task에서 다룬 Macie·Comprehend(PII)·Comprehend Medical·Glue Data Quality·Glue Sensitive Data Detection·DataBrew·Lake Formation·EFS·FSx for Lustre는 확인한 공지 4건(2025-10-13, 2026-03-31, 2026-06-30, 2026-09-29)의 목록에 나타나지 않는다. 2026-03-31 공지에는 Comprehend의 토픽 모델링·이벤트 탐지·프롬프트 안전 분류 기능과 AWS Glue Ray Jobs 기능이 유지보수로 올라 있으나 PII 탐지·편집이나 Data Quality는 해당하지 않는다 — 확인한 곳: S76, S77, 2026-03-31·2026-09-29 공지, DataBrew·Macie 대상 검색 — 제안: 학습 문서에 별도 수명 경고 없이 쓰되 집필 시점에 공지 목록을 한 번 더 확인한다.
- [G-1.3-10] CreateEndpointConfig의 `KmsKeyId`와 Nitro 로컬 스토리지 인스턴스의 관계: 현재 SageMaker API 레퍼런스(S49)는 "로컬 스토리지는 이 파라미터로 암호화되지 않는다"고 서술하지만, AWS CDK API 레퍼런스(https://docs.aws.amazon.com/cdk/api/v1/dotnet/api/Amazon.CDK.AWS.Sagemaker.CfnEndpointConfig.html)는 "KmsKeyId를 지정하면 호출이 실패한다"는 이전 문구를 담고 있다. 학습(S45)·처리(S47)는 "VolumeKmsKeyId를 요청할 수 없다"로 서술된다 — 확인한 곳: S45, S47, S49, CDK 문서 — 제안: 문항은 S49(현행 API 레퍼런스) 기준으로만 쓴다.
- [G-1.3-11] Glue Detect Sensitive Data는 국가별 카테고리에 Korea를 포함하지만 개별 엔터티(예: 한국 주민등록번호) 목록 페이지('Managed data types')는 열람하지 못했다. DataBrew PII 엔터티 유형은 USA_* 중심이다 — 확인한 곳: S67, S70 — 제안: 한국 PII 사례 문항은 쓰지 않거나 목록 페이지를 확인한 뒤 작성한다.
- [G-1.3-12] Glue Data Quality와 DataBrew data quality rules를 직접 비교한 공식 문장이 없다. 섹션 2.14의 "선택 기준"은 각 문서에 명시된 기능 차이(DQDL, 이상 탐지, 동적 규칙의 ETL 전용, 불량 레코드 식별의 ETL 전용, 프로파일 작업 연계)에서 도출한 정리다 — 확인한 곳: S78~S82 — 제안: 문항은 문서에 명시된 개별 기능 차이만 정답 근거로 삼는다.
- [G-1.3-13] Lake Formation 데이터 필터가 값 자체를 가리는(마스킹) 기능인지는 문서에 서술이 없고 열·행·셀 노출 제한만 서술된다 — 확인한 곳: S72 — 제안: 학습 문서는 "노출 제한"까지만 쓴다.
- [G-1.3-14] SSE-C는 2026-04부터 신규 범용 버킷에서 기본 차단되지만 시험 가이드 Version 1.0(2024)은 이보다 앞선 문서다. 시험이 SSE-C를 "고객 제공 키" 옵션으로 계속 출제하는지는 확인할 수 없다 — 확인한 곳: S38, S39 — 제안: 네 옵션의 정의를 그대로 서술하되 SSE-C 기본 차단 변경을 ⚠️로 병기한다.
- [G-1.3-15] Comprehend PII의 지원 언어(영어·스페인어)는 pii.html과 redact-api-pii.html 두 페이지 기준이며 별도의 언어 지원 목록 페이지와는 교차 확인하지 못했다 — 확인한 곳: S63, S64 — 제안: 문항은 영어 텍스트 사례로 작성한다.
- [G-1.3-16] 레포 `MLA-C01.json` 수정 제안: 없음 (Skill 원문은 ko_kr 공식 가이드와 일치).

### Task 2.1 (17건) — `tasks/2-1.md` 섹션 9

- [G-2.1-1] LightGBM 의 분산 학습·인스턴스 표기가 문서마다 다르다 — Tabular 개요 표는 "CPU (single instance only) / Parallelizable No", Parameters 표는 "CPU / Yes", LightGBM 알고리즘 페이지는 "single-instance and multi-instance CPU training" 이라고 쓴다.〔S4〕〔S9〕〔S14〕 — 제안: 알고리즘 개별 페이지를 정본으로 보되 문항에서 LightGBM 의 분산 가능 여부를 정답 근거로 쓰지 않는다.
- [G-2.1-2] BlazingText 인스턴스 표기 불일치 — Text 개요 표는 "GPU (single instance only) or CPU", Parameters 표는 "CPU or GPU (single instance only)", 알고리즘 페이지는 cbow·skipgram·supervised 는 단일 CPU/GPU, batch_skipgram 은 단일·다중 CPU 라고 모드별로 쓴다.〔S5〕〔S9〕〔S25〕 — 제안: 모드별 설명을 정본으로 하고 "병렬화 불가"를 단정하지 않는다.
- [G-2.1-3] DeepAR 컨테이너 보안 패치 종료 시점 상충 — 같은 지원 정책 페이지가 본문에서는 "2024-08 이후 보안 패치·업데이트 중단"이라 하고 내장 알고리즘 표에서는 forecasting-deepar 의 end of patch 를 2025-08-26 으로 적는다. 또한 표의 나머지 내장 알고리즘 이미지 대부분은 end of patch 2024-05-15 로 적히는데, 같은 페이지는 내장 알고리즘 이미지가 in-place 업데이트이며 latest 태그를 권장한다고 쓴다.〔S32〕 — 확인한 곳: 지원 정책 페이지 전문 — 제안: 학습문서에서 "DeepAR 폐기" 같은 단정을 하지 말고 "컨테이너 보안 패치 중단 공지(MXNet end-of-maintenance)"까지만 서술. 표의 날짜가 알고리즘 사용 불가를 뜻하는지는 컨트롤러가 AWS 문의/콘솔로 확인.
- [G-2.1-4] MXNet 기반 내장 알고리즘(Image Classification·Object Detection·Semantic Segmentation·DeepAR)과 "MXNet 은 SageMaker Python SDK v3 미지원" 공지의 관계를 설명한 문서를 찾지 못했다.〔S33〕〔S29〕〔S32〕 — 확인한 곳: mxnet.html, 각 알고리즘 페이지 — 제안: "24종이 현재 카탈로그에 존재" 사실까지만 쓰고 SDK v3 에서의 사용 가능 여부는 단정하지 않는다.
- [G-2.1-5] XGBoost 버전 표기 불일치 — 내장 알고리즘 표의 "0.90-1, 0.90-2, 1.0-1, 1.2-1, 1.2-21"과 XGBoost 페이지의 지원 버전 "1.2-1 ~ 3.0-5"(0.90 은 deprecated), 지원 정책 페이지의 현재 버전 3.2-0 이 서로 다르다.〔S9〕〔S10〕〔S32〕 — 제안: 버전 번호는 문항 근거로 쓰지 않는다.
- [G-2.1-6] JumpStart 솔루션 템플릿을 신규 계정이 쓸 수 있는지 — "JumpStart Solutions 는 Studio Classic 에서만 사용 가능"과 "Studio Classic 은 신규 앱 생성 불가" 두 문장은 있으나 이를 합친 직접 서술 문장은 찾지 못했다.〔S41〕〔S40〕 — 제안: 학습문서에서는 두 문장을 병기하고 "신규 계정 사용 불가" 단정은 콘솔 확인 뒤에 한다. 가이드 SK3 의 "솔루션 템플릿"이 정확히 이 기능을 가리키는지도 확인 필요.
- [G-2.1-7] Lookout for Equipment 는 문서 배너가 아직 미래형("On October 7, 2026, AWS will discontinue support …")이다 — 조회일(2026-10-17)은 그 날짜 이후라 실제 종료 후 상태(콘솔 접근 불가)를 확인하지 못했다.〔S101〕〔S102〕 — 제안: "2026-10-07 지원 종료 예정일이 지남"으로 서술하고, 종료 후 문구가 반영된 페이지가 나오면 갱신.
- [G-2.1-8] Rekognition 일부 기능(스트리밍 비디오 분석·배치 이미지 콘텐츠 중재) 공지의 개별 가용성 변경 페이지(rekognition-streaming-video-analysis-availability-change.html)는 What is Amazon Rekognition 페이지로 리다이렉트되어 열람 불가였다 — 제품 페이지 배너·streaming-video-detect-labels 문서의 노트·2026-03 공지로 대신 확인했다.〔S87〕〔S88〕〔S73〕 — 제안: 컨트롤러 LIFECYCLE 표 L13 에 위 URL 을 보강.
- [G-2.1-9] Bedrock 사용자 정의 모델 추론 방식 — Provisioned Throughput 문서는 "커스터마이즈한 모델을 쓰려면 PT 를 구매해야 한다"고 쓰고, "Set up inference for a custom model" 문서는 PT 구매 또는 온디맨드 배포 두 가지를 제시한다.〔S64〕〔S65〕 — 제안: 학습문서에서는 두 설명을 병기(구 규칙과 최신 문서). 시험 문항이 구 규칙(PT 필수)을 전제할 수 있음을 주석.
- [G-2.1-10] AWS 의사결정 가이드 "Choosing an AWS machine learning service"는 최종 갱신일이 2024-05-03 이라 이후 상태가 바뀐 서비스(Forecast·Kendra·DevOps Guru·Fraud Detector 등)를 그대로 나열한다.(F117)〔S46〕 — 제안: 이 가이드를 서비스 목록의 현재성 근거로 쓰지 않는다.
- [G-2.1-11] 내장 알고리즘별 해석 가능성 — 알고리즘 페이지가 직접 서술하는 곳은 TabTransformer 뿐이다. 2.6 의 "Linear Learner = 내재적, 트리 앙상블 = 사후 해석" 배정은 백서·Prescriptive Guidance 의 분류에 알고리즘 설명을 적용한 해석이다.〔S52〕〔S55〕〔S11〕〔S17〕 — 제안: 문항에서는 "선형 모델·결정 트리가 내재적 해석 가능, 복잡 모델은 사후 해석" 수준의 일반 원칙으로만 쓰고 특정 내장 알고리즘의 해석 가능성을 정답으로 삼지 않는다.
- [G-2.1-12] "ML 에 충분한 데이터량"의 보편적 수치 기준을 서술한 공식 문서는 찾지 못했다 — 서비스별 최소 요건(Personalize 1,000건·25명, DeepAR 관측치 300, Lookout for Equipment 6개월)만 확인했다.〔S47〕〔S48〕〔S85〕〔S28〕〔S101〕 — 제안: 수치 암기형 문항을 피하고 "데이터 부족 → 사전학습·전이학습·규칙 기반" 방향성 문항으로 출제.
- [G-2.1-13] 가이드의 "범위 내 서비스" 목록(영문 PDF Version 1.0 Appendix)은 웹 페이지가 아닌 PDF 라 검증기로 인용 대조를 못 했다. 이 노트의 "가이드 범위 내" 표기는 로컬 추출 텍스트(Appendix)를 읽은 결과다. Appendix 에 "Amazon Q"는 있으나 Q Developer/Q Business 구분은 없고, Forecast 는 없다. — 확인한 곳: mla-c01-guide.txt — 제안: 컨트롤러가 PDF 원문으로 재확인.
- [G-2.1-14] 한국어(ko_kr) 내장 알고리즘 문서는 기계 번역본이라 표기가 어색하다(예: Semantic Segmentation = "의미 체계 분할", Linear Learner = "선형 학습자", topic modeling = "주제 모델링", speech-to-text = "음성을 텍스트로 변환") — 페이지 상단에 영어판 우선이라 명시.〔S3〕 — 제안: 학습문서는 영문 용어를 병기.
- [G-2.1-15] 가용성 변경 확인 범위 — Translate·Transcribe·Polly·Textract·Lex·Personalize·Comprehend Medical·HealthLake·CodeGuru Profiler 는 2025-10~2026-09 공지 4건과 각 소개 페이지에서 변경을 찾지 못했을 뿐, 2025-10 이전 공지는 Forecast·Lookout 계열 외에는 전수 조회하지 않았다.〔S72〕〔S73〕〔S74〕〔S75〕 — 제안: LIFECYCLE 정본이 갱신되면 반영.
- [G-2.1-16] Amazon Q Developer 는 IDE 플러그인 지원 종료(2027-04-30) 배너가 있으나 Q Developer 서비스 전체의 상태(채팅·AWS 콘솔 내 어시스턴트 등)는 문서에서 구분해 서술하지 않는다.〔S92〕 — 제안: "IDE 플러그인 종료 예고"로만 서술.
- [G-2.1-17] 레포 MLA-C01.json 수정 제안: 없음 — 섹션 1 은 JSON 원문과 일치.

### Task 2.2 (24건) — `tasks/2-2.md` 섹션 9

- [G-2.2-1] 관리형 스팟 훈련의 `MaxWaitTimeInSeconds`와 `MaxRuntimeInSeconds` 관계가 '커야 한다(larger)'인가 '같거나 커야 한다(equal to or greater)'인가 — 관리형 스팟 훈련 가이드(S10)는 "must be larger than", StoppingCondition API 레퍼런스(S11)는 "equal to or greater than" (F49, F50) — 경계값(두 값이 같을 때)에 의존하는 문항은 만들지 말고 '대기 시간 ≥ 실행 시간 상한' 수준으로만 출제.
- [G-2.2-2] AMT 튜닝 작업당 훈련 작업 최대 수가 750인가 500인가 — 한도 표(S37)는 Bayesian·Random·Hyperband·Grid 모두 기본 750(Random만 10000까지 상향), 웜 스타트 문서(S36)는 "500 maximum training jobs" (F118, F125) — 전용 한도 표를 우선하되 숫자 자체를 정답으로 요구하는 문항은 피하고, 필요하면 두 문서의 불일치를 해설에 명시.
- [G-2.2-3] AMT 튜닝 작업당 지표 수가 20인가 40인가 — 한도 표(S37)는 "정의 가능한 지표 20", 지표 정의 문서(S39)는 "최대 40개 모니터링" (F120, F121) — 확정 불가. 문항화하지 말 것.
- [G-2.2-4] 가이드 SK5 '자동화된 하이퍼파라미터 최적화 기능 통합'이 가리키는 공식 기능이 무엇인가 — 가이드 영문 원문 "Integrating automated hyperparameter optimization capabilities"는 기능명을 특정하지 않음. 후보는 AMT의 Autotune(S34), SageMaker Pipelines 튜닝 스텝(S43), Autopilot의 HPO 모드(S44), Canvas AutoML(S47). 공식 문서에서 이 문구를 직접 설명한 페이지는 찾지 못함 — 컨트롤러는 네 후보를 모두 SK5 재료로 쓰되 하나를 정답으로 단정하지 말 것.
- [G-2.2-5] Amazon Bedrock 사용자 지정 방법에 '연속 사전 훈련(Continued pre-training)'이 현재도 있는가 — 사용자 가이드 개요(S72)는 지도 미세 조정·강화 미세 조정·증류 3종만 열거하지만 콘솔 도움말 패널(S77)과 Boto3 API(S78)는 연속 사전 훈련을 포함 (F172, F176, F177) — 가이드(Version 1.0)는 2024년 기준이라 '미세 조정·연속 사전 훈련·증류'가 정답 후보였을 가능성이 있으므로 문항에서는 연속 사전 훈련을 쓰되 해설에 개요 페이지의 열거 차이를 적을 것.
- [G-2.2-6] Bedrock 사용자 지정 모델 추론에 Provisioned Throughput가 필수인가 — 콘솔 도움말(S77)은 "you need to purchase Provisioned Throughput", 사용자 가이드(S75)는 Provisioned Throughput 또는 온디맨드 배포 두 옵션이며 온디맨드는 2025-07-16 이후 사용자 지정한 모델·지원 모델(Nova·Llama 3.3 70B)·두 리전으로 제한 (F183–F186) — 일반 경로는 Provisioned Throughput, 온디맨드는 조건부 옵션으로 서술.
- [G-2.2-7] 스크립트가 부수 출력을 쓰는 환경 변수가 `SM_OUTPUT_DIR`인가 `SM_OUTPUT_DATA_DIR`인가 — 공식 표(S14)는 `/opt/ml/output/data`를 `SM_OUTPUT_DIR`로 표기하고, AWS 블로그 예제(S65)는 `SM_OUTPUT_DATA_DIR`를 사용하며 훈련 툴킷 문서(S66)는 두 변수 모두 별도 항목이 없음 (F153) — 경로(`/opt/ml/output/data`)와 모델 경로(`/opt/ml/model`, `SM_MODEL_DIR`)의 구분만 출제하고 변수명 철자는 묻지 말 것.
- [G-2.2-8] 시험에서 스크립트 모드를 Estimator(SDK v2) 표기로 묻는가 ModelTrainer(SDK v3) 표기로 묻는가 — 공식 문서 본문은 'Estimator'를 'ModelTrainer'로 바꾸는 중이고(S63·S62·S71), 블로그(S64)가 v2→v3 대응표를 제공. 가이드 Version 1.0(2024)은 SageMaker AI 스크립트 모드로만 서술 (F157, F158) — 보기에 두 표기를 병기하고 `entry_point`(v2)·`SourceCode`(v3) 대응을 해설에 포함.
- [G-2.2-9] 영문 가이드의 steps(단계)가 SageMaker 문서에서 iteration(반복)과 같은 개념으로 정의된 문장이 있는가 — 분산 훈련 문서(S1)는 iteration만 정의하고 steps는 정의하지 않으며, Bedrock `stepCount`(S73)는 '각 배치에 노출되는 횟수'로 따로 정의 (F2, F14) — 학습문서에서는 '훈련 루프에서 가중치를 갱신하는 1회 = iteration/step'으로 설명하되 문서가 명시한 등식이 아님을 밝힐 것.
- [G-2.2-10] AMT 조기 중지를 지원하는 내장 알고리즘 목록이 최신인가 — 문서 스스로 2018-12-13 기준이라 밝히고 알고리즘이 에포크별 지표를 내면 지원한다고 설명 (F17, F16) — 목록 암기 문항은 피하고 '에포크별 목표 지표 발행' 조건을 묻는 문항으로.
- [G-2.2-11] 구현 옵션이 '세 가지'인가 네 가지인가 — 알고리즘 구현 선택 문서(S22)는 "three implementation options"라 쓰지만 목록은 사전 훈련 모델·내장 알고리즘·사전 제작 프레임워크 이미지·사용자 지정 Docker 이미지 네 개 (F148) — '노력 수준이 낮은 순: 사전 훈련 모델 < 내장 < 프레임워크 스크립트 모드 < 사용자 지정 이미지' 순서만 사용하고 개수는 묻지 말 것.
- [G-2.2-12] 가이드 SK8의 '정리(pruning)'가 모델 압축(가중치·파라미터 제거)인가 특성 선택인가 — 한국어 가이드는 '정리', 영문은 pruning. GenAI Lens(S56)는 파라미터 제거로, AWS 'What is Overfitting?'(S51)은 '특성 선택 — 또는 pruning'으로 설명 (F67, F75) — 보기에서 pruning이 나오면 제거 대상(파라미터 vs 특성)을 지문에서 확인해야 한다고 해설.
- [G-2.2-13] 치명적 망각(catastrophic forgetting)의 정의와 완화법을 설명한 [공식] 문서가 있는가 — 정의 문장은 [블로그](S52·S55)에서만 확인. [공식]은 PEFT가 '치명적인 언어 능력 손실'을 막는다는 문장(S53)과 Nova 데이터 믹싱 문서(S54)뿐 (F96–F99) — 문항 해설에 [블로그] 출처 표기를 유지하고, 완화법은 PEFT·데이터 믹싱·과거 데이터 재사용을 '문서에 언급된 방법'으로 한정.
- [G-2.2-14] L1/L2·과적합 처방·모델 크기 설명의 근거가 서비스 신규 사용자 중단된 레거시 Amazon Machine Learning 문서(S48·S49·S50)에 있다 — 현행 SageMaker 문서는 Linear Learner `l1`·`wd`, XGBoost `alpha`·`lambda` 파라미터 설명만 있고 효과 서술은 짧음 (F64, F77–F80) — 개념 설명 근거로만 쓰고 서비스 기능 문항(Amazon ML)은 만들지 말 것.
- [G-2.2-15] SMDDP 지원 인스턴스에 P5가 포함되는가 — SMDDP 지원 인스턴스 표(S4)는 ml.p3dn.24xlarge·ml.p4d.24xlarge·ml.p4de.24xlarge만 나열하고 SMP v2 문서는 P4·P5를 언급 (F29, F32) — SMDDP 인스턴스 목록을 정답 근거로 삼는 문항은 최신 문서 재확인 후 출제.
- [G-2.2-16] JumpStart로 미세 조정 가능한 모델 목록과 모델별 훈련 인스턴스 — 미세 조정 문서(S67)의 목록은 Llama 2·Mistral 7B 등 비교적 구형 위주이고 Studio는 모델별 호환 인스턴스만 선택하게 함(S70). 'Available foundation models' 표의 Fine-tunable 열이 최신 정본일 수 있으나 이번에 전체 대조는 하지 않음 (F167–F171) — 모델 이름 암기 문항은 피하고 '도메인 적응(CSV·JSON·TXT) vs 명령 기반(JSON Lines+`template.json`)' 구분을 출제.
- [G-2.2-17] 트리 모델의 트리 수·깊이가 모델 아티팩트 '크기'에 미치는 영향을 직접 서술한 공식 문서가 있는가 — XGBoost 문서(S25)는 `max_depth`·`num_round`를 복잡도·훈련 라운드 수로만 설명하고 크기는 말하지 않음 (F87) — K3 문항에서는 '파라미터 수·정밀도·체크포인트 포함'처럼 문서가 직접 말하는 요인만 쓰고 트리 수와 크기의 관계는 해설에서 일반 상식으로 분리해 표기.
- [G-2.2-18] 배깅의 SageMaker 사례(예: Random Forest)가 공식 문서에 있는가 — 배깅·부스팅 정의는 AWS 개념 페이지(S51), 부스팅 사례는 XGBoost·LightGBM·CatBoost(S23·S24), 스태킹 사례는 AutoGluon·Autopilot(S30·S44). scikit-learn Random Forest 예제는 블로그(S64)에 있으나 '배깅'이라는 설명은 SageMaker 문서에서 확인하지 못함 (F139–F144) — 문항에서 Random Forest=배깅이라는 일반 ML 지식을 SageMaker 문서 근거처럼 서술하지 말 것.
- [G-2.2-19] 공식 ko_kr 문서의 용어 — ko_kr 문서는 기계 번역이며 영문이 우선(S85–S89). 한 페이지 안에서 '조기 중지'와 '초기 중지'가 섞이고(S87), Bedrock 증류의 제목이 '추출'로 번역되며(S88), random search가 '임의 검색'(가이드는 '무작위 검색')이고(S86), 승인 상태 전이 목록의 마지막 줄이 'Rejected > Approved'로 중복 표기됨(영문은 Approved→Rejected)(S89) — 학습문서에서는 가이드 표기를 기본으로 하고 영문 용어를 병기.
- [G-2.2-20] SageMaker Pipelines 모델 등록 스텝의 현재 명칭 — Model Registry 문서(S82)는 `RegisterModel` 스텝을 안내하지만 블로그 예제는 `ModelStep`+`model.register()`를 사용 — 문서 표기인 `RegisterModel`을 따르되 SDK 버전에 따라 `ModelStep`일 수 있음을 보기·해설에 주의.
- [G-2.2-21] AMT `Strategy` 기본값 — 튜닝 설정 API 레퍼런스(S41)는 `Strategy`를 필수(Required: Yes)로 표기하고 값은 Bayesian·Random·Hyperband·Grid — 이전 문서·SDK의 'Bayesian 기본값' 서술은 이번에 현행 문서로 확인하지 못함 — 기본 전략을 묻는 문항은 피할 것.
- [G-2.2-22] (해소 보고) LIFECYCLE-NOTICES의 L5 중 Debugger 개별 페이지 문구 — "Amazon SageMaker Debugger is no longer open to new customers"(S20)로 확인함 (F60) — 공지 파일의 '미확인' 항목 갱신 제안. 한편 Ground Truth·A2I는 이 Task 범위가 아니라 확인하지 않음.
- [G-2.2-23] SK8 '특성 선택 업데이트'를 구체 SageMaker 기능(예: Data Wrangler의 특성 중요도·Autopilot의 특성 선택)으로 설명한 문서 — 이번에는 일반 개념(S51)과 PCA(S23)·Autopilot 개요(S45)만 확인하고 기능별 근거는 수집하지 않음 — 컨트롤러가 Task 1.2 노트와 대조해 필요 시 보강.
- [G-2.2-24] K4 '모델 성능을 개선하는 방법'을 한 곳에서 정의한 공식 페이지 — 찾지 못해 레거시 'Improving Model Accuracy'(S50)·What is Overfitting?(S51)·AMT·미세 조정·앙상블 문서를 조합해 정리 (F93–F95) — 학습문서에서는 '데이터·특성·하이퍼파라미터·전이학습·앙상블·증분 훈련' 범주 표로 제시하고 출처를 각각 표기.
- 레포 `MLA-C01.json` 수정 제안: 없음 (섹션 1 원문은 변경하지 않았고 K·SK 항목 번호 체계와 일치).

### Task 2.3 (11건) — `tasks/2-3.md` 섹션 9

- [G-2.3-1] Clarify 사후 편향 지표는 11개인가 13개인가? — https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-measure-post-training-bias.html 본문은 "eleven"이라 쓰지만 같은 페이지의 요약표·주제 목록은 13개(DPPL, DI, CDDPL, FT, AD, RD, DCAcc, DAR, SD, DCR, DRR, TE, GE)다. 사전 8개 + 사후 13개 = 21개는 블로그의 "21 different metrics"와 일치한다 — 제안: 학습문서는 사후 13개(총 21개)로 쓰고 "문서 본문 표기와 불일치"를 주석으로 남기며, 문항에서 개수를 정답 근거로 삼지 않는다.
- [G-2.3-2] DCAcc·DCR·TE 의 부호 해석과 정의가 페이지마다 같은가? — 요약표(clarify-measure-post-training-bias.html)와 개별 페이지(clarify-post-training-bias-metric-dcacc.html, -dcr.html, -te.html)를 대조했다. 예: DCAcc 양수를 요약표는 "possible bias against the qualified applicants from the disfavored facet d" 로, 개별 페이지는 facet a 에 대한 편향으로 설명한다. TE 는 요약표가 FP 대 FN 비율의 차로, 개별 페이지가 FNd/FPd − FNa/FPa 로 쓰고 "이전 버전은 FPa/FNa − FPd/FNd" 라는 주석을 단다 — 제안: 이 세 지표는 이름·비교 대상(관측 대 예측, FP 대 FN 비율)·범위만 쓰고 부호 해석을 정답 근거로 쓰지 않는다.
- [G-2.3-3] 가이드 K1 의 '히트 맵(heat maps)'은 어떤 평가 기법을 가리키는가? — 가이드 원문(섹션 1)은 설명 없이 나열한다. 공식 문서 확인 결과 Autopilot 지표·성능 보고서 페이지에는 "heat map"이라는 단어가 없고(혼동 행렬을 색 막대로 설명), 이 단어는 Clarify 컴퓨터 비전 설명(슈퍼픽셀 SHAP)과 Debugger Insights 시스템 사용률 문서에 나온다. AWS 블로그 예제 코드는 혼동 행렬을 seaborn `heatmap` 으로 그린다 — 제안: 학습문서에 두 의미(혼동 행렬의 색 농도, SHAP 히트 맵)를 병기하고 출제 의도는 미확정으로 표기한다. 컨트롤러가 섹션 8 에서 MLA-C02 가이드에 같은 단어가 있는지 비교한다.
- [G-2.3-4] K2 '성능 기준선'의 현행 공식 정의가 있는가? — 현행 문서에서 "기준 모델" 개념은 ML Lens(MLPERF04-BP02·BP05)에 있고, 지표 기준값(AUC 0.5, 평균을 예측하는 모델의 RMSE, 최빈 클래스 예측의 macro-F1)은 이번 조사 범위에서는 구서비스 Amazon Machine Learning 문서에서만 찾았다(문서 상단에 갱신·신규 사용자 중단 공지). Model Monitor baseline 은 ⚠️ 신규 고객 중단이다 — 제안: 학습문서에서 기준선의 세 의미(성능·운영·SHAP)를 구분하고 Amazon ML 출처는 "구서비스 문서"로 표기한다. 시험이 어느 의미를 묻는지는 가이드에 명시가 없다.
- [G-2.3-5] SK3 '재현 가능한 실험'의 정답 서비스는 Experiments 인가 MLflow 인가? — experiments.html 은 Experiments Python SDK 추적이 Studio Classic 에서만 가능하고 MLflow 통합을 권장한다고 쓰며, lineage-tracking.html 은 Studio Classic 이 신규 온보딩 불가라고 쓴다. 가이드 문구는 서비스 이름 없이 "AWS 서비스를 사용하여 재현 가능한 실험 수행"이다 — 제안: Experiments(Classic)·MLflow·Model Registry·ML Lineage Tracking·시드를 모두 다루고, 문항은 "추적·비교·버전·계보" 개념으로 출제하며 서비스 하나만 정답으로 못 박지 않는다.
- [G-2.3-6] Autopilot 성능 보고서의 정밀도·재현율 가중 지침이 정확한가? — autopilot-model-insights.html 의 "If your problem has a low penalty for false negative values, but a high penalty for missing a true negative results, give more weight to precision over recall." 는 "missing a true negative"의 의미가 모호하다. 같은 문서군의 지표 페이지는 "Precision is an important metric when the cost of a false positive is high" 로 일관되게 설명한다 — 제안: 학습문서에는 FP 비용 기준 설명만 쓰고 앞 문장은 인용하지 않는다.
- [G-2.3-7] Debugger `save_interval` 기본값은? — debugger-built-in-rules.html·debugger-save-tensors.html·debugger-configure-hook.html 에서는 예제가 값을 500 으로 지정할 뿐 기본값을 명시한 문장을 찾지 못했다(AWS 블로그 "Training, debugging and running time series forecasting models with the GluonTS toolkit on Amazon SageMaker"는 기본 500 단계라고 쓰지만 공식 개발자 가이드에서는 미확인) — 제안: 학습문서에서 기본값을 단정하지 않는다.
- [G-2.3-8] SageMaker AI MLflow 의 요금·"추가 비용 없음" 서술은 확인되는가? — debugger-availability-change.html 은 서버리스 MLflow 기능이 추가 비용 없이 제공된다고 쓰지만, mlflow.html·mlflow-app-setup.html 에서는 요금 문장을 찾지 못해 본문에 쓰지 않았다 — 제안: 요금 문항은 만들지 않고, 필요하면 동적 페이지인 SageMaker AI 요금 페이지를 별도로 확인한다.
- [G-2.3-9] Clarify 온라인 설명 문서에 신규 고객 중단 배너가 없는 이유는? — clarify-online-explainability.html 본문(2026-10-17 조회)에는 다른 Clarify 페이지에 붙은 "no longer open to new customers" 배너가 없다 — 제안: 기능 상태는 페이지별 배너가 아니라 Clarify availability change(clarify-availability-change.html)를 기준으로 ⚠️ 처리한다.
- [G-2.3-10] Profiler 지원 종료가 Debugger 의 시스템 모니터링·프로파일링(ProfilerConfig, ProfilerReport 규칙, Insights 대시보드)에도 적용되는가? — profiler-availability-change.html 은 `ProfilerConfig` 제거 절차를 안내하고 Debugger Insights 문서에도 Profiler 지원 종료 배너가 붙어 있으나, Debugger 프로파일링 기능의 종료일을 명시한 문장은 찾지 못했다 — 제안: 학습문서는 "SageMaker Profiler 2027-06-30 지원 종료"만 쓰고 Debugger 프로파일링의 종료일은 단정하지 않는다.
- [G-2.3-11] R2 의 범위는 −1~1 인가? — autopilot-metrics-validation.html 은 "Values range from one (1) to negative one (-1)"이라고 쓴다. 이 노트는 문서 표기를 그대로 옮겼고 범위가 엄밀한지는 확인하지 않았다 — 제안: 학습문서에서는 "문서 표기"를 붙이고 문항에서 R2 하한값을 정답 근거로 쓰지 않는다.
- 레포 `MLA-C01.json` 수정 제안: 없음.

### Task 3.1 (16건) — `tasks/3-1.md` 섹션 9

- [G-3.1-1] 실시간 엔드포인트 페이로드 한도가 25 MB인가 6 MB인가? — 25 MB: 공식 비교 페이지(deploy-model-options.html)와 호스팅 FAQ(hosting-faqs.html)〔S1〕〔S3〕. 6 MB: InvokeEndpoint API 레퍼런스의 `Body` 길이 6,291,456 〔S18〕, aws.amazon.com FAQ 〔S92〕. 어느 쪽이 최신인지 문서에 날짜가 없다. — 제안: 학습문서는 "25 MB(개발자 가이드 기준, API 레퍼런스는 6 MiB로 표기)"로 병기하고 문항에서는 이 수치에 의존하지 않는다.
- [G-3.1-2] 비동기 추론의 처리 시간 한도는 1시간인가 15분인가? — 1시간: 비교 페이지·호스팅 FAQ·`InvocationTimeoutSeconds` 최대 3600초 〔S1〕〔S3〕〔S11〕. 15분: aws.amazon.com FAQ 〔S92〕(요청 기본값 900초와 일치). — 제안: "기본 15분, 최대 60분"으로 서술.
- [G-3.1-3] 비동기 요청 페이로드를 반드시 S3에 둬야 하는가? — 개발자 가이드는 S3 배치를 요구 〔S8〕, API 레퍼런스는 128,000 bytes 이하 인라인 `Body`를 허용(`InputLocation`과 상호 배타) 〔S11〕. — 제안: 두 표기를 병기하고 문항은 "대용량은 S3"로 한정.
- [G-3.1-4] 스케일 투 제로 서술이 문서마다 다르다 — 비동기 문서는 "Unlike other hosted models…"로 비동기만 0 스케일이라고 쓰지만 〔S9〕, 추론 컴포넌트를 호스팅하는 실시간 엔드포인트도 0 인스턴스까지 줄일 수 있다고 한다 〔S28〕. 서버리스도 0까지 줄어든다 〔S5〕. — 제안: 시험용 기본 답은 "서버리스·비동기", 추론 컴포넌트는 예외로 병기.
- [G-3.1-5] Trainium의 역할 표기가 상충한다 — 제품 페이지는 "AI training and inference" 〔S46〕, 블로그는 "mainly for … training" 〔S91〕, DLAMI Trainium 페이지는 inference 워크로드용으로 서술 〔S48〕, Neuron SDK 문장은 Trainium에서 훈련 〔S45〕. — 제안: 학습문서는 "Inf = 추론 특화, Trn = 훈련 중심(현재 제품 페이지는 추론도 표방)"으로 쓰고, 문항에서 Trn과 Inf를 오답 짝으로 쓸 때는 훈련 vs 추론 구분 단서를 명시.
- [G-3.1-6] Elastic Inference의 최종 종료일은? — SDK 문서는 2023-04-15 이후 신규 온보딩 중단 〔S54〕, ECS 콘솔 문서는 "no longer available" 〔S55〕만 확인했다. 참고로 `https://docs.aws.amazon.com/sagemaker/latest/dg/ei.html`은 `whatis.html`로, `https://docs.aws.amazon.com/elastic-inference/latest/developerguide/what-is-ei.html`은 `deploy-model.html`로 2026-10-17 현재 리다이렉트된다(MCP 열람 결과). — 제안: "신규 고객 불가(사실상 종료)"로 표기하고 날짜를 단정하지 않는다.
- [G-3.1-7] BYOC `/ping` 호출 방식 — 요구사항 목록은 `/invocations`와 `/ping`에 POST를 수용한다고 쓰고, 헬스체크 절은 주기적 GET 요청이라고 쓴다 〔S57〕. — 제안: "추론은 POST /invocations, 헬스체크는 GET /ping(200 응답)"으로 서술하되 원문 불일치를 메모.
- [G-3.1-8] Hugging Face TGI와 LMI 컨테이너의 공식 SageMaker 개발자 가이드 전용 페이지 — TGI는 AWS 블로그 〔S63〕만 확인, LMI는 SageMaker 가이드의 목차 페이지 〔S61〕와 DJL Serving 페이지 〔S60〕만 확인했고 상세 문서는 외부(docs.djl.ai)다. — 제안: 학습문서에서 TGI·LMI는 "대형 모델 추론용 사전 빌드 컨테이너 예시" 수준으로만 다룬다.
- [G-3.1-9] Lambda가 GPU를 지원하지 않는다는 공식 문서 문장을 찾지 못했다 — AWS ML 블로그가 GPU가 필요하면 ECS·Kubernetes·SageMaker 엔드포인트를 고려하라고 안내 〔S85〕할 뿐이다. Lambda Managed Instances 등 신규 기능의 가속기 지원 여부도 미확인. — 제안: 문항에서 "Lambda는 GPU 불가"를 정답 근거로 쓰지 말고 한도(10 GB·15분·6 MB)로 판단하게 한다.
- [G-3.1-10] 비동기 추론의 "제외 기능(Exclusions)" 목록 — 비동기 개발자 가이드가 링크한 Exclusions 페이지가 현재 `whatis.html`로 리다이렉트되어 열람할 수 없었다 〔S8〕. 비동기와 MME·추론 파이프라인 등의 호환 여부는 미확인. — 제안: 해당 호환성 문항은 만들지 않는다.
- [G-3.1-11] 요금 수치 — SageMaker 요금 페이지는 동적이라 단가를 수집하지 않았다(과금 구조만 〔S4〕〔S5〕). — 제안: 문항은 단가 대신 구조(인스턴스 시간 / ms + 데이터 / 잡 기간)로 출제.
- [G-3.1-12] Compute Optimizer가 SageMaker 엔드포인트 인스턴스를 분석하는지 — CLI 레퍼런스 설명은 EC2·ASG·Lambda·EBS·ECS(Fargate)만 나열 〔S90〕. SageMaker 지원 여부를 단정하는 문서는 찾지 못했다. — 제안: 오답 선택지로 쓸 때 "SageMaker 엔드포인트 추천은 Inference Recommender"만 근거로 삼는다.
- [G-3.1-13] 한국어 공식 표기가 기계 번역이라 페이지마다 다르다 — "일괄 변환"〔S94〕 / "배치 변환"(일부 페이지·가이드 Skill의 "배치 추론"), "섀도우 테스트"(ko_kr shadow-tests.html), "다중 모델/다중 컨테이너 엔드포인트"(multi-model-endpoints.html, multi-container-endpoints.html), "추론 구성 요소"(realtime-endpoints-deploy-models.html, 헤딩에는 "추론 구성 요쇼" 오타), "캐너리/카나리"(deployment-guardrails.html), "프로비저닝된 동시성"(serverless-endpoints.html), "SageMaker Edge Manager 수명 종료"(edge-eol.html). — 제안: 학습문서에서 영문 용어를 병기하고 한국어 표기는 가이드 Skill 문장("배치 추론", "서버리스 엔드포인트")을 우선한다.
- [G-3.1-14] IoT Greengrass는 가이드 범위 외인데 Neo 문서·Edge Manager 대안 안내가 Greengrass를 전제로 한다 〔S88〕〔S64〕〔S69〕. — 제안: 문항은 Neo(컴파일·DLR)까지만 묻고 Greengrass 운영 세부는 출제하지 않는다.
- [G-3.1-15] Trn1 네트워크 대역폭 수치 — DLAMI 페이지는 Trn1을 "100 Gbps"로 적고 〔S48〕 EC2 사양표는 trn1.32xlarge를 8 × 100 Gigabit으로 적어 〔S44〕 상충한다. 이 노트는 Trn1 대역폭 수치를 사실 행에 쓰지 않았다. — 제안: 대역폭 문항은 EC2 사양표(`ac.html`) 기준 수치만 사용.
- [G-3.1-16] MLA-C01.json 수정 제안 — 없음(K1–K7·SK1–SK6 원문은 공식 가이드와 일치).

### Task 3.2 (13건) — `tasks/3-2.md` 섹션 9

- [G-3.2-1] 가이드 SK1의 예시 구절 "dynamically adding Spot Instances, by using Amazon EC2 instances, by using Lambda behind the endpoints"(영문 PDF) / "엔드포인트 뒤에서 Lambda 사용으로 스팟 인스턴스 동적 추가"(한국어판)가 가리키는 단일 공식 아키텍처·패턴은 무엇인가? — 확인한 곳: SageMaker 개발자 가이드(inference-cost-optimization, deployment-best-practices, model-managed-spot-training), EC2 Spot 사용 설명서, ML Lens MLREL05-BP01, Generative AI Lens GENSUS01-BP01, EKS 모범 사례(CPU 추론·Spot), AWS ML 블로그(API Gateway→Lambda→엔드포인트, Lambda 컨테이너 추론). 세 구절을 하나의 구성으로 묶어 설명하는 문서는 찾지 못했다. 영문 PDF는 세 항목을 쉼표로 나열하고 한국어판은 한 문장으로 합쳐 쓴다 — 제안: 학습문서는 2.7 B 표처럼 구절을 분리해 *개별 패턴*으로 설명하고 "공식 문서가 이 구성을 하나의 아키텍처로 설명한다"고 쓰지 않는다. `MLA-C01.json` 은 공식 ko_kr 가이드와 일치하므로 수정하지 말고 영문 구절 병기만 권장.
- [G-3.2-2] 서버리스 프로비저닝된 동시성의 Application Auto Scaling을 CloudFormation으로 선언할 수 있는가? — 확인한 곳: 서버리스 추론 문서(serverless-endpoints.html: "현재 CloudFormation에서 지원되지 않음")와 CloudFormation `AWS::ApplicationAutoScaling::ScalableTarget` 레퍼런스(허용 `ScalableDimension` 에 `sagemaker:variant:DesiredProvisionedConcurrency` 포함) — 두 문서가 상충(F39·F40). 실제 배포로 검증하지 않았다 — 제안: 학습문서에는 두 서술을 병기하고 CloudFormation 지원 여부를 문항 정답 근거로 쓰지 않는다.
- [G-3.2-3] "최소값은 1 이상"(오토 스케일링 정책 개요)과 "0까지 scale-in"(비동기·추론 컴포넌트)은 어떻게 양립하는가? — 확인한 곳: endpoint-auto-scaling-policy(최소 1 이상, 예외 미기재) vs async-inference-autoscale(`MinCapacity` 0)·endpoint-auto-scaling-zero-instances(`MinInstanceCount` 0, 추론 컴포넌트)·Application Auto Scaling SageMaker 통합 페이지(추론 컴포넌트 최소 0 예시) — 제안: "일반 실시간 변형 1 이상, 추론 컴포넌트 기반·비동기는 0 허용, 서버리스 프로비저닝된 동시성은 1 이상"으로 정리해 서술.
- [G-3.2-4] 가이드 SK6의 "model latency" 예시를 대상 추적 정책의 스케일링 지표로 쓰라는 공식 권고가 있는가? — 확인한 곳: Application Auto Scaling 사전 정의 지표 목록(SageMaker 항목에 `ModelLatency` 없음), Inference Recommender 오토 스케일링 추천(`InvocationsPerInstance`·`ModelLatency` 기준), ML Lens("request latency" 예시), CDK alpha의 `metric_model_latency()` 알람 예시. 정책 지표로 쓰라는 명시 문장은 찾지 못했다 — 제안: 문항은 `InvocationsPerInstance`(SageMaker 권장)·CPU 사용률·백로그를 정답 방향으로 두고, 지연 시간은 모니터링·알람·부하 테스트 판정 지표로 설명.
- [G-3.2-5] SageMaker 엔드포인트에 Application Auto Scaling 예측(predictive) 스케일링을 쓸 수 있는가? — 확인한 곳: Application Auto Scaling "What is" 페이지(예측 스케일링을 기능으로 소개), CloudFormation `PredictiveScalingPolicyConfiguration`("ECS 서비스에서 지원"), SageMaker 정책 개요(대상 추적·단계·예약만 소개). SageMaker 미지원을 명시한 문장은 없다(부재 근거) — 제안: "공식 문서가 ECS만 명시하고 SageMaker 소개 목록에는 없다"로 서술하고 "SageMaker는 지원하지 않는다"고 단정하지 않는다.
- [G-3.2-6] SageMaker 호스팅 엔드포인트 인스턴스에 Spot을 쓸 수 있는가? — 확인한 곳: SageMaker 문서에서 Spot은 관리형 스팟 훈련(자동 모델 튜닝 포함)만 확인. 엔드포인트 구성 문서(CloudFormation `EndpointConfig`·`ProductionVariant`)에서 Spot 옵션을 찾지 못했고 가능·불가를 명시한 문장도 없다 — 제안: 단정하지 말고 문항은 "훈련 = 관리형 스팟 훈련"으로 한정.
- [G-3.2-7] SageMaker AI Savings Plans가 서버리스·비동기 추론 사용에도 적용되는가? — 확인한 곳: inference-cost-optimization 문서의 적용 대상 열거(노트북·Processing·Data Wrangler·훈련·실시간 추론·배치 변환)에 서버리스·비동기가 없다. aws.amazon.com 요금 페이지 원문은 이 노트에서 대조하지 않았다 — 제안: 서버리스·비동기와 Savings Plans의 관계를 정답 근거로 쓰지 말 것.
- [G-3.2-8] MLA-C01 시험(가이드 v1.0)이 전제하는 SageMaker Python SDK 버전과 현재 공식 문서(v3)의 차이는? — 확인한 곳: 개발자 가이드 실시간 추론 배포 문서(v3 `ModelBuilder`·`Endpoint`), SDK 1.x→3.x 업그레이드 안내(xgboost-version-0.90), GitHub README("Estimator, Model, Predictor and all their subclasses will not be supported in V3", `pip install sagemaker==2.*`), SDK v3 문서. v2의 지원 종료 일정은 문서에서 찾지 못했고 가이드 v1.0은 SDK 버전을 명시하지 않는다 — 제안: 학습문서에 v2 용어와 v3 대응을 병기(2.13 표), 문항은 API 흐름(`CreateModel → CreateEndpointConfig → CreateEndpoint`)·서비스 선택 중심.
- [G-3.2-9] "SageMaker Projects = Service Catalog 기반"이 여전히 정답 프레임인가? — 확인한 곳: What is a SageMaker AI Project?(S3 사용자 지정 템플릿·Service Catalog·SageMaker 제공 템플릿 병행, S3 권장, CodeCommit 템플릿은 2024-09-09부터 미지원), MLOps Project Templates(SageMaker 제공 템플릿 = Service Catalog 제품). 가이드 범위 내 서비스 목록에는 AWS Service Catalog가 있다 — 제안: "템플릿은 S3 또는 Service Catalog, 제공 템플릿은 Service Catalog 제품"으로 둘 다 서술.
- [G-3.2-10] 서버리스 엔드포인트의 콜드 스타트 지연을 보는 지표는 `OverheadLatency` 인가 `ModelSetupTime` 인가? — 확인한 곳: 서버리스 추론 문서(`OverheadLatency` 가 새 컴퓨트 시작 시간을 추적한다고 서술) vs SageMaker CloudWatch 지표 문서(`ModelSetupTime` = 서버리스의 새 컴퓨트 시작 시간, `OverheadLatency` = SageMaker 오버헤드). 두 문서가 다르다. 본 Task 직접 범위가 아니라 Task 4.2 영역 — 제안: 4.2 노트·학습문서에서는 CloudWatch 지표 문서를 기준으로 서술.
- [G-3.2-11] 한국어판 용어를 그대로 시험 대비 용어로 써도 되는가? — 확인한 곳: ko_kr 오토 스케일링 정책 개요·서버리스 추론·네트워크 격리 페이지는 "기계 번역으로 제공… 영어 버전이 우선"이라 표기하며, "Feature exclusions"를 "독점 기능"으로, cooldown을 "휴지 기간"으로 옮긴다 — 제안: 학습문서는 영문 용어를 병기하고 "독점 기능"은 "제외 기능(Feature exclusions)"으로 풀어 쓴다.
- [G-3.2-12] 가이드 범위 내 서비스 목록의 "AWS Auto Scaling"은 SageMaker 엔드포인트용 Application Auto Scaling을 가리키는가? — 확인한 곳: 영문 시험 가이드 PDF 서비스 목록("AWS Auto Scaling", Management and Governance), Application Auto Scaling 문서(대상 추적 제한 사항에 "AWS Auto Scaling scaling plan"을 별도 대상으로 언급). 목록의 정확한 지칭과 현재 서비스 상태를 알려 주는 공지는 찾지 못했다 — 제안: 학습문서는 SageMaker 엔드포인트에는 Application Auto Scaling, EC2에는 EC2 Auto Scaling으로 구분해 서술하고, 목록상 "AWS Auto Scaling"의 지칭은 컨트롤러가 추가 확인.
- [G-3.2-13] 변형 대상 추적 정책의 경보 평가 기간(scale-out 3분, scale-in 15분)이 공식 문서에 명시되는가? — 확인한 곳: AWS ML 블로그의 추론 컴포넌트 수준 예시에서만 확인(2.4 마지막 항목). 개발자 가이드·Application Auto Scaling 문서에서는 수치를 찾지 못했다 — 제안: 해당 수치는 블로그 예시로만 언급하고 문항 정답 근거로 쓰지 말 것.

### Task 3.3 (15건) — `tasks/3-3.md` 섹션 9

- [G-3.3-1] SageMaker Projects의 CodeCommit 템플릿 종료 시점이 두 공식 문서에서 다르다 — 프로젝트 개요 문서(S49)는 "2024-09-09부터 CodeCommit 저장소를 쓰는 템플릿은 지원하지 않는다", 템플릿 문서(S50)는 "2024-10-28에 CodeCommit 템플릿이 제거되었다"고 적는다 — 학습문서·문항에는 정확한 일자를 정답 근거로 쓰지 말고 "2024년 가을부터 신규 프로젝트는 서드파티 Git 템플릿을 쓴다"로 서술한다.
- [G-3.3-2] CodeCommit이 2025-11-25부터 신규 고객을 다시 받기 시작했는데(S38) SageMaker Projects의 CodeCommit 템플릿이 복원되었는가 — S49·S50에서 복원 언급을 찾지 못했다 — 복원 여부를 단정하지 말고, CodeCommit 재개(S38)와 템플릿 제거(S49·S50)를 별개 사실로 병기한다.
- [G-3.3-3] Well-Architected ML Lens(S64·S65)가 권하는 "AWS Step Functions Data Science SDK"의 현재 지원 상태 — ML Lens 원문은 계속 언급한다. 해당 SDK의 GitHub 저장소 첫 화면에서는 보관(archive)·지원 중단 표시를 찾지 못했으나(웹 요약 도구 확인이라 신뢰도 낮음) 공식 수명 공지는 찾지 못했다 — Step Functions 서비스 자체만 다루고 이 SDK를 정답 근거로 쓰지 않는다.
- [G-3.3-4] SageMaker Pipelines · Step Functions · MWAA · CodePipeline을 직접 비교하는 공식 표가 있는가 — 없었다. S48(SageMaker AI Workflows 개요), S64(ML Lens MLOPS04-BP01), S72(MWAA FAQ)만 확인했다 — 2.11 비교표는 "(정리)"임을 학습문서에 밝히고, 문항 정답 근거는 ML Lens의 선택 문장(Pipelines: SDK·감사 추적 / Step Functions: 더 복잡하거나 SageMaker 밖 통합 / MWAA: 기존 Airflow 통합)으로 한정한다.
- [G-3.3-5] CodePipeline에 SageMaker 파이프라인을 직접 실행하는 전용 액션 제공자가 있는가 — S79의 통합 목록(Source·Build·Test·Deploy·Approval·Invoke의 제공자 제목 전체)에서 SageMaker 전용 항목을 찾지 못했다. 부재 자체는 공식 문장으로 인용할 수 없다 — "전용 액션이 없다"를 단정 사실로 쓰지 말고, SageMaker Projects 템플릿이 CodeBuild 단계(S50)로 파이프라인을 만들고 실행·대기한다는 문서 내용만 쓴다.
- [G-3.3-6] SageMaker Pipelines 단계 문서(S41)의 단계 목록(18종)에는 없는데 본문 목차에는 "Fine-tuning step" 절이 있다 — 해당 절의 내용은 조사하지 않았다 — 학습문서는 목록의 18종을 기준으로 삼고 Fine-tuning 단계를 문항 소재로 쓰지 않는다.
- [G-3.3-7] CodeBuild 동시 빌드 기본 쿼터 — S11의 표는 대부분 1(Linux GPU는 0)로 보이는데 같은 페이지 주석은 "기본값은 내부 지표로 정해지며 일부 플랫폼·컴퓨트 유형은 기본이 20"이라고 적어 서로 맞지 않는다 — 구체 동시 빌드 수를 문항·학습문서에 쓰지 말고 "컴퓨트 유형별로 다르며 증액 요청 가능"만 서술한다(GPU Small 0은 표에서 직접 인용했다).
- [G-3.3-8] 쿼터 수치(S1·S11·S18)는 리전별이고 항목마다 증액 가능 여부가 다르며 바뀔 수 있다 — 수치를 암기시키는 문항은 피하고 "증액 가능 / 고정(예: 폴링 파이프라인 상한)" 구분과 서비스 간 대소 관계 중심으로 출제한다.
- [G-3.3-9] 일정 기반 시작을 안내하는 문서가 서로 다르다 — CodePipeline 일정 문서(S77)는 EventBridge 규칙(Schedule), SageMaker Python SDK 일정(S46)은 EventBridge Scheduler 서비스 주체(`scheduler.amazonaws.com`)를 쓰고, EventBridge 문서(S71)는 예약 규칙을 레거시로 분류하며 Scheduler를 권장한다 — 문항 정답은 "EventBridge(Scheduler 또는 규칙)"로 열어 두고 한쪽을 오답으로 단정하지 않는다.
- [G-3.3-10] 명칭 불일치 — SageMaker 프로젝트 문서(S50)는 아직 "AWS CodeStar connection"이라 쓰는데 서비스는 2024-03-29에 AWS CodeConnections로 개명되었다(S9) — 학습문서는 "AWS CodeConnections(구 CodeStar Connections)"로 병기한다.
- [G-3.3-11] Model Monitor·Clarify의 신규 고객 중단(S74·S75)이 Pipelines의 `QualityCheck`·`ClarifyCheck` 단계(각각 Model Monitor·Clarify 컨테이너 사용, S41)에 미치는 영향 — 확인한 범위(두 단계 절의 앞부분과 baseline 수명 주기 문서 S47)에는 중단 공지 문구가 없고 단계 자체의 향후 지원 변화도 확인하지 못했다 — 시험 범위 기능이므로 다루되 ⚠️를 병기하고 "신규 고객에게 닫힌 기능에 의존한다"까지만 쓴다.
- [G-3.3-12] Model Monitor 위반 → CloudWatch 경보 → EventBridge 규칙 → 파이프라인 시작이라는 전체 체인을 한 공식 문서가 서술하는가 — 찾지 못했다. 체인은 블로그(S73)와 공식 문서의 조각(S65: CloudWatch 경보로 재훈련 워크플로 실행, S46: 드리프트로 인한 엔드포인트 상태 변화가 EventBridge 이벤트 예)의 조합이다 — 학습문서에 체인을 쓸 때 블로그 출처임을 밝히고, 문항에서는 "경보 → EventBridge → 파이프라인" 구조를 정답 방향으로만 쓴다.
- [G-3.3-13] 블로그 근거 3건(S35 CodePipeline 브랜치 기반 개발, S73 드리프트 재훈련, S80 CodeBuild 캐시 전략)은 공식 문서가 아니다 — 정답을 확정하는 유일한 근거로 쓰지 않고 공식 문서(S2·S3·S4 / S65·S78 / S14)와 병용한다.
- [G-3.3-14] Amazon MWAA의 트리거·스케줄링 방식(센서 등)은 조사하지 않았다 — 가이드 Skill이 MWAA를 직접 요구하지 않고 이 Task의 질문이 선택 기준 비교로 한정되어 S64·S72의 선택 기준 문장만 사용했다 — 필요하면 MWAA 사용자 가이드를 추가로 확인한다.
- [G-3.3-15] EC2/온프레미스의 all-at-once 표기가 두 공식 문서에서 달라 보인다 — DevOps 백서 매트릭스(S27)는 Canary·Linear·All-at-once를 EC2/온프레미스에서 지원하지 않는다고 표시하는데, CodeDeploy 배포 구성 문서(S19)는 EC2/온프레미스 사전 정의 구성으로 `CodeDeployDefault.AllAtOnce`를 나열한다 — 이 노트는 매트릭스의 all-at-once를 Lambda·ECS의 트래픽 이동 구성(canary·linear·all-at-once)으로, EC2/온프레미스의 `AllAtOnce`·`HalfAtATime`·`OneAtATime`을 최소 정상 호스트 기반의 배포 속도 구성으로 읽었으나 이 구분을 명시한 공식 문장은 찾지 못했다 — 문항에서는 "EC2/온프레미스에는 canary·linear 트래픽 이동이 없다"까지만 정답 근거로 쓴다.

### Task 4.1 (17건) — `tasks/4-1.md` 섹션 9

> 확인 필요 항목: 본문에 단정해서 쓸 수 없었던 불확실·상충·미확인 사항이다. 형식은 `[G-4.1-n] 질문 — 확인한 곳 — 제안`.

- [G-4.1-1] "특성 기여도 드리프트"의 한국어 공식 표기는 무엇인가 — ko_kr Model Monitor 개요·기여도 드리프트 페이지(둘 다 기계 번역 고지가 붙음)에서 확인: 목차 표기는 "프로덕션 환경의 모델에 대한 특성 어트리뷰션 드리프트", 본문 서술은 "특징 속성 드리프트", 편향은 "바이어스 드리프트"이다〔S61〕〔S62〕. 위임 지시문의 "특성 기여도 드리프트"는 이 페이지들에 나오지 않는다 — 제안: 학습문서는 영문(Feature attribution drift)을 병기하고 ko_kr 표기가 기계 번역임을 감안해 용어를 한 가지로 통일.
- [G-4.1-2] 예측(레이블) 드리프트(prediction drift)의 공식 정의가 있는가 — Model Monitor 개요·데이터 품질·모델 품질 페이지, ML Lens 모니터링 단계와 MLPERF06-BP03·BP04 원문을 확인했으나 별도 정의가 없다. ML Lens는 데이터 드리프트·개념 드리프트 2종, AWS 블로그는 공변량 이동·레이블 이동·개념 이동 3종이다〔S52〕〔S56〕〔S60〕. 검색 결과에서 Accenture 이름이 붙은 백서(AWS 백서 경로에 게시)가 "Prediction drift and Feedback drift"를 이름만 나열하는 것을 봤지만 정의가 없어 인용하지 않았다 — 제안: 예측 드리프트 정의를 정답 근거로 쓰지 말고, 레이블 이동은 [블로그] 근거의 보조로만 사용.
- [G-4.1-3] Model Monitor가 지원하는 드리프트 척도는 무엇인가(출처 상충) — ML Lens MLPERF06-BP03은 Model Monitor가 KL 발산·Jensen-Shannon 발산·PSI 같은 통계 척도를 지원한다고 쓴다〔S55〕. 그러나 constraints.json 스키마 문서는 L∞(`linf_simple`·`linf_robust`)와 범주형 `LInfinity`·`ChiSquared`만 나열하고, Model Monitor 개요·데이터 품질·제약 스키마 페이지 원문에는 KL·Jensen-Shannon·PSI·Wasserstein 용어가 없다(2026-10-17 원문 대조)〔S12〕〔S19〕. PSI·KS는 대체 경로(Evidently) 문서에 나온다〔S2〕 — 제안: Model Monitor 내장 척도의 종류·개수를 정답 근거로 쓰는 문항 금지.
- [G-4.1-4] 모니터링 스케줄의 "최소 간격" 공식 수치가 있는가 — ScheduleConfig API는 지원 표현식(매시간, 매일, N시간 간격 `cron(0 [00-23]/[01-24] ? * * *)`, `NOW`)만 나열하고 "minimum interval"이라는 문구는 없다〔S17〕. 1시간 미만 반복이 지원된다는 문장도, 금지된다는 문장도 없다 — 제안: "문서의 지원 표현식 중 반복 최단 단위는 1시간"으로만 서술하고 "최소 간격은 1시간"이라 단정하는 문항 회피.
- [G-4.1-5] 데이터 캡처 샘플링 기본값은 얼마인가 — 기본 20%는 Python SDK `DataCaptureConfig`(`sampling_percentage`) 설명에만 나오고〔S7〕, API의 `InitialSamplingPercentage`는 정수 0~100의 필수 파라미터로 기본값 표기가 없다〔S9〕 — 제안: 20% 기본값은 "Python SDK 기준"으로 한정해 서술.
- [G-4.1-6] Model Monitor 비용 문장의 적용 범위 — (a) FAQ의 "인스턴스 리소스가 스케줄 삭제 전까지 예약된다"는 문장은 배치 변환 모니터링을 설명한 단락에 있어, 실시간 엔드포인트 스케줄에도 같은 방식으로 적용되는지 문서가 구분하지 않는다〔S18〕. (b) 요금 페이지의 "내장 규칙은 최대 30시간 무료"는 Real-Time Inference 항목 아래 문장이며, 같은 페이지 프리 티어 표(첫 2개월)와의 관계와 현행 적용 범위를 확인하지 못했다〔S48〕 — 제안: 요금 수치를 단정하는 문항은 피하고 "스케줄이 처리 작업 인스턴스를 반복 기동해 비용이 생기며 스케줄 삭제로 멈춘다" 수준으로만 사용.
- [G-4.1-7] 서버리스·비동기 추론 엔드포인트에서 데이터 캡처와 Model Monitor가 지원되는가 — Model Monitor 개요·데이터 캡처·FAQ, `DataCaptureConfig` API에서 해당 문장을 찾지 못했다. 섀도 테스트 문서만 서버리스·비동기 추론을 사용 불가로 명시한다〔S45〕 — 제안: 지원 여부를 정답 근거로 쓰지 말 것.
- [G-4.1-8] "비동기 배치 변환 작업"의 의미 — Model Monitor 개요가 "On-schedule monitoring for asynchronous batch transform jobs"라 쓰면서 같은 목록에서 "정기적으로 실행되는 배치 변환 작업의 지속 모니터링"을 따로 적지만 둘의 차이를 정의하지 않는다〔S1〕 — 제안: 원문 용어를 그대로 쓰고 해석을 덧붙이지 말 것.
- [G-4.1-9] 가이드 K3의 "ML 렌즈의 설계 원칙"이 가리키는 문서 — 현행 ML Lens(2025-11-19 새 버전, 모든 모범 사례를 새 구조로 갱신)에는 "Well-Architected machine learning design principles" 10개가 있고, 문장에 monitoring이 직접 나오는 것은 "Enable continuous improvement" 하나다〔S51〕〔S50〕. 구버전(2023-07-05 이전)의 번호 체계·원칙 문구와의 대응은 확인하지 못했다 — 제안: 설계 원칙 문항은 "지속적 개선 = 지속적인 모니터링·분석·학습" 수준으로만 쓰고, 필러별 모범 사례 ID(MLOPS06-BP02, MLPERF06-BP03·BP04·BP05)를 보조 근거로 사용.
- [G-4.1-10] 서비스 중단 공지가 시험에 미치는 영향 — Model Monitor·Clarify(및 A2I·Ground Truth)가 신규 고객에게 닫혔지만 가이드(Version 1.0)는 SK1·SK3에 두 서비스를 예로 들고 있다〔S1〕〔S4〕. MLA-C02 개정 영향은 컨트롤러가 섹션 8에서 다룬다. 이 노트는 가이드 기준으로 모두 다루고 ⚠️를 병기했다. 대체 경로(Evidently, MLflow, QuickSight)가 시험에 출제되는지는 확인할 수 없다 — 제안: 문항 정답 근거는 가이드 기준 서비스로 쓰되 상태를 병기.
- [G-4.1-11] FAQ "Merge job" 단락의 Ground Truth 용법 — 그 단락은 병합 작업이 "Amazon SageMaker Ground Truth를 사용하는 경우에만 해당"한다고 쓰지만, 모델 품질 병합 문서는 사용자가 라벨을 JSON Lines로 S3에 올리면 된다고만 설명하고 서비스 요건을 언급하지 않는다〔S18〕〔S23〕 — 제안: 병합 요건은 모델 품질 병합 페이지(라벨 JSONL, `inferenceId`/`eventId`, `yyyy/mm/dd/hh` 경로)를 기준으로 서술.
- [G-4.1-12] 4xx·5xx 지표의 원인 해석 — 공식 문서는 "모델이 반환한 4xx/5xx 응답 수"만 정의하고 각각의 전형적 원인(요청 형식 오류 vs 컨테이너 내부 오류)은 서술하지 않는다〔S32〕. 이 노트도 원인 해석을 쓰지 않았다 — 제안: 4xx=클라이언트 오류 같은 일반 HTTP 해석을 정답 근거로 쓰지 말 것.
- [G-4.1-13] Model Monitor 실행 자체가 EventBridge 이벤트를 내는가 — 스케줄이 처리 작업을 시작한다는 문장은 확인했지만〔S16〕, 모니터링 실행의 상태 변경이 "SageMaker Processing Job State Change" 이벤트로 오는지는 문서에서 확인하지 못했다〔S34〕 — 제안: 그런 문항을 쓰지 말고, 위반 감지는 `CompletedWithViolations` 상태·보고서·CloudWatch 지표로 서술.
- [G-4.1-14] A/B 테스트 중 변형별로 Model Monitor를 쓰는 공식 절차 — 문서의 A/B 예시는 변형별 CloudWatch 지표와 노트북 평가 코드(정확도·F1 등)를 쓰고, 캡처 경로에 변형 이름이 들어간다는 사실만 확인된다〔S40〕〔S7〕. 변형별 모델 품질 모니터링을 Model Monitor로 구성하는 절차는 찾지 못했다 — 제안: A/B 문항은 변형 가중치·`TargetVariant`·`UpdateEndpointWeightsAndCapacities`·변형별 CloudWatch 지표 범위로 한정.
- [G-4.1-15] 건강·생명과학 ML 모범 사례 백서의 모델 모니터링 페이지 — AWS 문서 MCP로는 본문이 열렸지만, 검증기와 같은 방식(페이지 원문 HTML 텍스트 대조)에서는 그 페이지에서 뽑은 인용 4건이 모두 일치하지 않았다. 원인은 확인하지 않았고, 대조를 통과시킬 수 없어 이 노트에서 인용하지 않았다 — 제안: 필요하면 컨트롤러가 `[수동]` 방식으로 별도 확인.
- [G-4.1-16] 오프셋 예시의 문서 간 불일치 — 스케줄 페이지의 계산 예시는 실행 시각 2020-01-09T13:00, `StartTimeOffset=-P8D`, `EndTimeOffset=-P1D`일 때 2020-01-01T13:00부터 2020-01-08T13:00까지를 분석한다고 밝혀, 분석 창이 [실행 시각 − 시작 오프셋, 실행 시각 − 종료 오프셋]임을 보여 준다〔S22〕. 이 규칙을 FAQ 예시에 적용하면(정답이 예측 3일 뒤 도착, `-P3D`/`-P1D` → 창 [T−3일, T−1일]; 정답이 6시간 뒤 도착, `-PT6H`/`-PT1H` → 창 [T−6시간, T−1시간]) 창 안의 예측 대부분은 정답이 도착하기 전 데이터가 된다〔S18〕 — 제안: 오프셋 문항은 스케줄 페이지의 계산 예시를 근거로 쓰고 FAQ 예시의 수치는 정답 근거로 쓰지 말 것. FAQ 문장이 "도착 시점"이 아니라 다른 의미로 쓰였는지는 문서에서 확인하지 못했다.
- [G-4.1-17] 레포 `MLA-C01.json` 수정 제안 — 없음. Task 4.1의 K1~K3·SK1~SK4 원문은 영문 PDF(Version 1.0)의 용어와 대응하며 수정할 부분을 찾지 못했다.

### Task 4.2 (15건) — `tasks/4-2.md` 섹션 9

- [G-4.2-1] K1의 5개 지표(활용률·처리량·가용성·확장성·내결함성)를 한 문장으로 정의한 공식 문서가 있는가 — ML Lens(MLOPS05-BP01·설계 원칙·성능 효율성/신뢰성 필러 정의)와 SageMaker CloudWatch 지표 문서를 확인했으나 5개를 함께 정의한 문장은 없었다. ML Lens가 직접 언급하는 것은 지연·처리량·자원 활용률(MLOPS05-BP01)과 내결함성·복구 가능성(설계 원칙)뿐이다 — 제안: 학습문서는 2.1의 표를 '학습용 정리'로 밝히고, 문항은 개념 정의 암기가 아니라 '어떤 지표·설정이 어떤 개념을 보여 주는가'를 묻는 형태로 만든다.
- [G-4.2-2] AWS Compute Optimizer가 SageMaker 엔드포인트에 적정 규모(rightsizing) 권장을 제공하는가 — Compute Optimizer 사용자 가이드(what-is, supported-resources, view-idle-recommendations, requirements)가 SageMaker에 대해 명시하는 것은 '엔드포인트 유휴 권장'(14일 호출 0건)뿐이고 rightsizing 권장 서술은 찾지 못했다. 반면 FAQ의 권장 대상 나열에는 'SageMaker Endpoint'가 들어 있고 권장 유형은 구분되지 않는다. 가이드 SK5는 'Inference Recommender 및 Compute Optimizer 사용'을 예로 든다 — 제안: 'Compute Optimizer로 SageMaker 엔드포인트를 사이징한다'를 문항의 정답·오답 근거로 단정하지 말고, 사이징의 정답은 Inference Recommender, Compute Optimizer는 유휴·EC2 등으로 한정한다. 레포 `MLA-C01.json`은 가이드 원문이므로 수정 제안 없음.
- [G-4.2-3] SageMaker 엔드포인트가 X-Ray 세그먼트를 자체적으로 내보내는가 — X-Ray 개발자 가이드(what-is, integrating with services, concepts)의 통합 서비스 목록은 '예시'이며 SageMaker는 기재돼 있지 않고, ML Lens는 'ML 애플리케이션 구성요소 간 요청 추적'에 X-Ray를 권한다. 엔드포인트 내부 트레이싱 지원 여부는 확인하지 못했다 — 제안: 'X-Ray = 앞단 애플리케이션 체인(API Gateway·Lambda 등)의 구간별 지연 추적'으로 서술하고 '엔드포인트가 자동으로 세그먼트를 보낸다'는 단정은 피한다.
- [G-4.2-4] `InvokeEndpoint`의 CloudTrail 기록 서술이 자료마다 다른가 — SageMaker 개발자 가이드의 영문판과 ko_kr 기계 번역판 모두 현재는 '데이터 이벤트로 기록 가능, 기본 미기록'으로 서술한다. 과거 서술은 확인하지 못했다(현재 문서만 확인) — 제안: 문항은 '기본값은 미기록, 데이터 이벤트(`AWS::SageMaker::Endpoint`)로 옵트인'으로 써서 어느 서술과도 모순되지 않게 한다.
- [G-4.2-5] Trusted Advisor 전체 점검의 지원 플랜 요건 — 현재 문서는 Business Support+·Enterprise Support·Unified Operations 플랜이고 Developer Support·Business Support·Enterprise On-Ramp는 2027-01-01 종료 공지다. 시험 가이드(v1.0) 시점의 플랜 명칭과 다를 수 있으나 과거 서술은 확인하지 못했다 — 제안: 문항은 '유료 지원 플랜에서 전체 점검, Basic은 Service Limits 중심'으로 쓰고 플랜 명칭은 쓰지 않는다.
- [G-4.2-6] SageMaker 인스턴스에 예약 인스턴스(RI)가 적용되는가 — Savings Plans 문서(plan-types, sp-ris), How AWS Pricing Works, SageMaker 비용 최적화 문서를 확인했으나 RI는 EC2·RDS 등으로만 서술되고, SageMaker에 RI를 적용한다는 문장도 적용되지 않는다는 문장도 찾지 못했다. 가이드 SK10은 RI를 예로 든다 — 제안: 학습문서는 'SageMaker AI의 약정 할인 수단 = SageMaker AI Savings Plans(용량 예약은 훈련 플랜)'로 쓰고 'SageMaker는 RI 불가'는 단정하지 않는다. RI를 오답 선택지로 쓸 때의 근거는 '문서가 SageMaker 비용 절감 수단으로 지목하는 것은 SageMaker Savings Plans'로 한정한다.
- [G-4.2-7] 서버리스 콜드 스타트를 재는 지표가 `OverheadLatency`인가 `ModelSetupTime`인가 — 서버리스 문서는 콜드 스타트 시간이 `OverheadLatency`에 포함된다고 서술하고, 지표 참조 문서는 `ModelSetupTime`을 '서버리스 엔드포인트의 새 컴퓨트 기동 시간'으로 별도 정의한다(서로 다른 지표를 가리키는 것처럼 읽히는 중복 서술) — 제안: 두 지표를 함께 서술('콜드 스타트 시간은 OverheadLatency에 포함, ModelSetupTime은 컴퓨트 기동 시간')하고 단일 지표만 정답으로 두지 않는다.
- [G-4.2-8] 오토 스케일링 반응 시간 수치 — 스케일 아웃 경보 3분(1분 데이터 포인트 3개)·스케일 인 15분은 AWS Machine Learning 블로그에만 있고 공식 SageMaker 개발자 가이드에서 같은 수치를 찾지 못했다. 기본 쿨다운 값도 공식 문서로 확인하지 못했다 — 제안: 수치는 단정하지 말고 '경보 평가 기간+지표 게시·반응 지연+쿨다운이 스케일 반응 시간을 이룬다' 수준으로 서술한다.
- [G-4.2-9] 시점 의존 수치 — Cost Explorer 13개월 조회·18개월 예측, Budgets 하루 최대 3회 갱신 등은 2026-10-17 문서 기준이다. CUR 문서는 한 페이지 안에서 '하루 한 번 갱신'·'하루 최소 한 번'·'하루 최대 세 번'이 섞여 있다 — 제안: 갱신 횟수·예측 개월 수 같은 수치를 문항의 정답 근거로 쓰지 않는다.
- [G-4.2-10] 비용 할당 태그의 소급 적용(backfill) — `cost-alloc-tags` 문서 하위 주제에 'Backfill cost allocation tags'가 있으나 본문은 읽지 않았다 — 제안: '활성화한 시점부터만 추적된다'고 단정하지 말고, 필요하면 해당 페이지를 추가 확인한다.
- [G-4.2-11] SageMaker AI Savings Plans의 서버리스·비동기 추론 적용 여부 — 문서의 적용 목록(Studio Classic 노트북·On-Demand 노트북·Processing·Data Wrangler·Training·Real-Time Inference·Batch Transform)에 서버리스·비동기 추론은 없으나 'including'으로 서술돼 비배타 여부를 단정할 수 없다 — 제안: 서버리스·비동기 추론에 대한 적용 여부를 묻는 문항은 만들지 않는다.
- [G-4.2-12] Quick Sight가 CloudWatch 지표를 직접 데이터 소스로 읽는지 — 확인한 예는 CUR→Athena→Quick 데이터셋, Model Monitor 대체 구성의 Athena Iceberg→QuickSight 대시보드 등 S3/Athena 경유뿐이다 — 제안: 'Quick Sight = Athena/S3 등 데이터셋 기반 BI'로 서술하고 'CloudWatch 지표를 Quick Sight에 직접 연결'은 단정하지 않는다.
- [G-4.2-13] 'Amazon Quick'이 현재 정식 명칭인가 — Quick 사용자 가이드(what-is)와 Q Business 이전 문서가 'Amazon Quick', QuickSight의 BI 기능을 'Amazon Quick Sight'로 부르고, AWS BI 블로그 제목은 'Quick Suite'를 쓴다(시기별 표기 공존, 컨트롤러 N6와 일치) — 제안: 학습문서는 'Amazon Quick(구 Amazon QuickSight, 중간 표기 Quick Suite)'로 병기하고 한국어판 'Amazon Quick Sight'는 Quick 안의 BI 기능명으로 설명한다. 가이드 원문 JSON은 수정 제안 없음.
- [G-4.2-14] 훈련 플랜(flexible training plans)의 세부 — 훈련 플랜이 존재하고 훈련 잡·HyperPod·추론 엔드포인트·Studio 앱에 쓰인다는 것만 확인했다. 지원 인스턴스·리전·요금은 문서의 별도 표에 있으며 조사하지 않았다. 가이드는 훈련 플랜을 직접 언급하지 않는다 — 제안: 학습문서는 '용량을 예약하는 수단이 있다' 수준으로만 다룬다.
- [G-4.2-15] 채팅 앱으로 예산·경보 알림 받기(AWS Chatbot → Amazon Q Developer in chat applications) — Budgets 문서의 하위 주제에 'Receiving budget alerts in chat applications'가 있다는 것만 확인했고, AWS Chatbot의 현재 명칭·상태는 확인하지 못했다(컨트롤러의 미확인 수명 항목) — 제안: 다루려면 별도 확인 후 사용한다.

### Task 4.3 (15건) — `tasks/4-3.md` 섹션 9

- [G-4.3-1] 조건 키 이름 — `sagemaker:VolumeKmsKey`(구)와 `sagemaker:VolumeKmsKeyArn`(현재) 중 시험 보기가 쓰는 이름은? — 확인한 곳: Service Authorization Reference는 구 키를 deprecated로 표시하고 `...Arn`을 대체 키로 명시〔S11〕. 예제 페이지는 본문에 `VolumeKmsKey`, JSON에는 `VolumeKmsKeyArn`을 쓰고〔S3〕, 백서는 `VolumeKmsKey`를 쓴다〔S12〕 — 제안: 학습문서·문항에서 두 이름을 병기하고, 키 이름 자체를 정답 근거로 삼지 않는다.
- [G-4.3-2] CloudTrail `InvokeEndpoint` 기록 — 현재 SageMaker 문서는 `AWS::SageMaker::Endpoint` 데이터 이벤트로 선택 기록할 수 있다고 명시한다〔S28〕. 과거 문서나 시험 대비 자료가 "InvokeEndpoint는 기록되지 않는다"고 서술했는지, 데이터 이벤트 지원 시작 시점이 언제인지는 확인하지 못했다 — 확인한 곳: 현재판 CloudTrail 문서, What's New 검색(해당 공지 미발견) — 제안: 문항은 "데이터 이벤트를 별도로 켜야 기록된다"를 정답 조건으로 명시하고, 구판 서술을 따르는 시험 지문 가능성은 컨트롤러가 MLA-C02 비교와 함께 판단한다.
- [G-4.3-3] Role Manager 신규 고객 중단 날짜 — 개별 공지 페이지(`role-manager-availability-change.html`)에는 날짜가 없고〔S8〕, 날짜(2026-07-30)는 SageMaker AI 기능 묶음 공지에서 확인했다〔S55〕 — 제안: 학습문서는 두 페이지를 함께 인용한다(컨트롤러 공지 L3와 일치).
- [G-4.3-4] 새 "IAM role manager"(AWS Security Blog) — 게시일과 IAM User Guide 문서 위치를 확인하지 못했다. MLA-C01 가이드 범위가 아니다〔S10〕 — 제안: SageMaker Role Manager와의 혼동 주의 한 줄로만 다룬다.
- [G-4.3-5] VPC 모드 SageMaker 작업의 ECR 인터페이스 엔드포인트 요구 여부 — SageMaker 훈련·처리 문서는 SageMaker가 컨테이너 이미지를 ECR에서 자동으로 가져온다고만 서술한다〔S20〕〔S93〕. 백서는 데이터 과학자 환경에 ECR 엔드포인트를 권장하고〔S13〕, Studio `VpcOnly` 필수 엔드포인트 목록에는 ECR이 없으며〔S23〕, ECR 문서는 ECR을 직접 쓰는 클라이언트의 엔드포인트 구성을 안내한다〔S78〕 — 제안: "ECR 엔드포인트 필수"를 정답이나 오답의 근거로 쓰지 않는다.
- [G-4.3-6] VPC 모드 훈련 실패의 정확한 오류 문구(예: S3 데이터 다운로드 실패 메시지) — 확인한 SageMaker 공식 문서에서 찾지 못했다. 본문은 원인(S3 엔드포인트·NAT·라우트 테이블·보안 그룹)만 서술한다〔S20〕 — 제안: 오류 문구를 정답 단서로 쓰지 않는다.
- [G-4.3-7] re:Post 문서의 표기 오류 — S3 AccessDenied 문서가 `CreateTrainingJob`에 필요한 권한을 "s3:ListObject"로 적었으나〔S59〕, SageMaker 문서의 정책 예시는 `s3:ListBucket`이다〔S1〕 — 제안: 학습문서는 S1의 `s3:ListBucket`을 쓴다.
- [G-4.3-8] Studio `VpcOnly` 포트 규칙의 적용 범위 — 해당 문서는 Jupyter Server·Kernel Gateway(Studio Classic 구조) 용어로 TCP 8192–65535를 설명하며〔S23〕, 새 Studio(JupyterLab·Code Editor 공간)에도 같은 범위가 적용되는지 구분하지 않는다. NFS 2049는 `CreateDomain` API 문서가 Studio 앱 실행에 필수라고 명시한다〔S25〕 — 제안: 포트 범위를 문항 근거로 쓸 때 "문서 기준"임을 밝힌다.
- [G-4.3-9] 규정 준수 프로그램 목록 — SageMaker AI의 Compliance validation 문서는 개별 프로그램(HIPAA·PCI DSS·SOC 등)을 나열하지 않는다〔S48〕. HIPAA 적격 여부만 HIPAA 목록에서 확인했고(갱신일 2026-10-15)〔S49〕, 그 밖의 프로그램은 게시일을 확인하지 못한 오래된 블로그에만 있어 본문에 쓰지 않았다 — 제안: 규정 준수 문항은 "범위 확인은 AWS Services in Scope by Compliance Program, 보고서는 AWS Artifact, HIPAA는 적격 서비스 목록"까지만 출제한다.
- [G-4.3-10] CodeBuild 보안 모범 사례 단일 페이지 — 해당 URL(`.../codebuild/latest/userguide/security-best-practices.html`)이 CodeBuild 개요 페이지로 리다이렉트되어 전용 페이지를 확인하지 못했다 — 제안: 데이터 보호〔S71〕·VPC〔S72〕·서비스 역할〔S73〕·환경 변수 API〔S70〕 문서와 AWS Security Blog〔S74〕를 개별 근거로 쓴다.
- [G-4.3-11] Config 관리형 규칙의 나머지 — 규칙 목록에는 `sagemaker-` 접두 규칙이 더 있다(이름만 확인: 데이터 품질·모델 편향·모니터링 스케줄의 격리 규칙, Feature Group 암호화 규칙 등)〔S90〕. 세부 동작과 트리거는 2.12 표의 8개 규칙만 확인했다 — 제안: Config 문항은 그 8개 범위에서 출제한다.
- [G-4.3-12] 범위 외 서비스 목록의 출처 — MLA-C01 가이드 부록(영문 PDF Version 1.0)의 범위 외 목록(AWS Artifact·AWS Audit Manager·Amazon GuardDuty·Amazon Inspector·AWS Security Hub·AWS WAF·AWS Resource Access Manager 등)은 로컬 PDF 추출본에서 확인했고 공개 URL을 출처로 달지 않았다 — 제안: 컨트롤러가 가이드 PDF URL로 출처를 보완한다. Model Registry 공유에 쓰이는 AWS RAM은 범위 외라 본문에서 다루지 않았다.
- [G-4.3-13] 한국어 표기 — ko_kr 문서는 기계 번역 페이지이며 영어판이 우선한다는 고지가 붙어 있다. 확인한 표기: 실행 역할, 역할 전달, SageMaker 역할 관리자(Role Manager), 네트워크 격리, 컨테이너 간 트래픽 암호화, 프라이빗 서브넷, `VPC only`(VPC 전용 모드), 관리 이벤트·데이터 이벤트, 이벤트 기록(Event history), 추적(trail). 확인한 ko_kr 페이지: sagemaker-roles, role-manager, mkt-algo-model-internet-free, train-encrypt, studio-notebooks-and-internet-access, logging-using-cloudtrail — 제안: 학습문서는 영어 용어를 병기한다.
- [G-4.3-14] 교차 계정 모델 배포 예제 정책의 범위 — 문서의 예제 코드는 ECR에 `ecr:*`, S3에 `s3:*`처럼 넓은 권한을 상대 계정에 준다〔S56〕. 이를 더 좁힐 수 있는지는 문서에 없다 — 제안: 문항에서 "예제 그대로가 최소 권한"이라고 단정하지 않는다.
- [G-4.3-15] 레포 `MLA-C01.json` 수정 제안 — 없음.

> Task별 합계: **191건** (A 공통 14건 별도, 그중 ✅ 해소 1건).

---

## C. 레포 `flutter_app/assets/exam_guides/MLA-C01.json` 수정 제안

**본문(도메인·Task·지식·기술)은 수정할 것이 없다** — 공식 ko_kr 가이드와 문자열 완전 일치, `overview` 수치(채점 50·비채점 15·합격 720·130분·도메인 비중 28/26/22/24)도 일치(`00-overview.md` §4). 아래는 **메타 필드 보강** 제안이며 모두 선택 사항이다.

1. **`overview` 확장** — 현재 `level/passingScore/scoredQuestions/unscoredQuestions/durationMinutes` 만 있다. 추가 후보:
   - `examCode: "MLA-C01"`, `totalQuestions: 65`, `priceUsd: 150`, `validityYears: 3`
   - `questionTypes`: 가이드 판본 차이가 있으므로 `["multiple-choice","multiple-response","ordering","matching"]` (+ PDF v1.0은 `"case-study"` 포함) — 단정이 부담스러우면 `notes` 로.
   - `languages`: `{"ko": true, "ja": true, "zh-CN": true, "en": false}` (영문 2026-09-28 종료) — 값 자체가 2027-01-14 이후 모두 false 가 되므로 날짜 필드 권장.
2. **개정 공지 필드 신설** — 예: `"revision": {"successor": "MLA-C02", "englishEndDate": "2026-09-28", "allLanguagesEndDate": "2027-01-14", "sources": [...]}`. 이 레포는 SOA-C03 v1.1 개정을 놓친 전례가 있으므로 JSON에 개정 상태를 명시적으로 두는 편이 안전하다. 단 **G-0-5(유효 기간 표기 상충)** 때문에 날짜 출처는 비교 페이지가 아니라 블로그·자격증 페이지로 적을 것.
3. **출처 URL 분리** — `durationMinutes: 130` 의 근거는 시험 가이드가 아니라 자격증 소개 페이지다. `sourceUrl`(가이드) 외에 `overviewSourceUrl` 을 추가하거나 `sources[]` 배열로 확장.
4. **서비스 수명 메모(선택)** — Skill 문구는 그대로 두고, 별도 메타(예: `skillNotes[taskNo]`)로 'Clarify·Model Monitor·Debugger·Role Manager·Ground Truth·A2I 신규 고객 중단, Mechanical Turk 폐쇄' 같은 상태를 달아 두면 학습문서·문항 해설과 일관되게 쓸 수 있다.
5. **원문 표기 보존 원칙** — 도메인 4 Skill의 'Amazon Quick Sight', Task 3.1 제목의 문장형 어미(…선택합니다.) 등은 **공식 원문 그대로**이므로 정정하지 않는다. 표시 단계에서 보조 주석으로만 처리.
