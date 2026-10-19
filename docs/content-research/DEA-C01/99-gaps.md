# 99. DEA-C01 gaps — 상충·불확실·확인 필요·수정 제안·분할 제안

> **상태**: 원자료 노트 (AI 수집 · 미검수) · 조회일 2026-10-17(재확인 2026-10-19 포함) · 작성: DEA-C01 리서치 세션  
> 이 파일은 **노트 본문에 쓰지 않은 것**을 모은다: (a) 공식 문서 간 상충, (b) 확인하지 못해 본문에 넣지 않은 사실, (c) 레포 `flutter_app/assets/exam_guides/DEA-C01.json` 수정 제안, (d) 학습문서 분할 제안(제안만 — 결정은 취합 세션). 항목마다 근거 URL과 "확인 시도 / 후속"이 붙어 있다.  
> 항목 ID `G-<Task>-<번호>` — `G-0-xx`는 가이드·레포 JSON 등 전역 항목(컨트롤러 확인), 그 외는 해당 Task 노트(`tasks/<n>.md`)의 담당 리서처가 적은 항목이다. 본문에 "사실 #n"·"S번호"로 적힌 참조는 해당 Task 노트의 "사실·숫자" 행 번호와 "출처 목록" 번호를 가리킨다.

## 0. 요약

- 총 **274건** (유형별: 확인필요 88, 상충 53, 개명·종료 51, 불확실 49, 분할제안 18, 수정제안 13, 정보 1, 해결됨 1)
- **분할 제안 18건**, **레포 JSON 수정 제안 13건**

### 0.1 Task × 유형 건수

| Task | 제목 | 합계 | 확인필요 | 상충 | 개명·종료 | 불확실 | 분할제안 | 수정제안 | 정보 | 해결됨 |
|---|---|---|---|---|---|---|---|---|---|---|
| 전역 | 가이드·레포 JSON·서비스 목록 (컨트롤러 확인) | 11 | 3 |  | 1 | 3 |  | 2 | 1 | 1 |
| 1.1 | Perform data ingestion (데이터 수집 수행) | 26 | 8 | 7 | 3 | 5 | 1 | 2 |  |  |
| 1.2 | Transform and process data (데이터 변환 및 처리) | 26 | 8 | 4 | 6 | 5 | 1 | 2 |  |  |
| 1.3 | Orchestrate data pipelines (데이터 파이프라인 오케스트레이션) | 11 | 2 | 1 | 4 | 3 | 1 |  |  |  |
| 1.4 | Apply programming concepts (프로그래밍 개념 적용) | 13 | 4 | 4 | 2 | 1 | 1 | 1 |  |  |
| 2.1 | Choose a data store (데이터 스토어 선택) | 26 | 6 | 9 | 5 | 3 | 2 | 1 |  |  |
| 2.2 | Understand data cataloging systems (데이터 카탈로그 시스템 이해) | 11 | 4 | 3 | 1 | 2 | 1 |  |  |  |
| 2.3 | Manage the lifecycle of data (데이터의 수명 주기 관리) | 18 | 5 | 7 | 3 | 1 | 2 |  |  |  |
| 2.4 | Design data models and schema evolution (데이터 모델 및 스키마 진화 설계) | 14 | 4 | 1 | 3 | 4 | 1 | 1 |  |  |
| 3.1 | Automate data processing by using AWS services (AWS 서비스를 사용하여 데이터 처리 자동화) | 14 | 3 | 1 | 4 | 4 | 1 | 1 |  |  |
| 3.2 | Analyze data by using AWS services (AWS 서비스를 사용하여 데이터 분석) | 13 | 4 | 1 | 4 | 3 | 1 |  |  |  |
| 3.3 | Maintain and monitor data pipelines (데이터 파이프라인 유지 관리 및 모니터링) | 16 | 3 | 5 | 5 | 2 | 1 |  |  |  |
| 3.4 | Ensure data quality (데이터 품질 보장) | 8 | 4 | 1 | 1 | 2 |  |  |  |  |
| 4.1 | Apply authentication mechanisms (인증 메커니즘 적용) | 13 | 4 | 2 | 1 | 4 | 1 | 1 |  |  |
| 4.2 | Apply authorization mechanisms (권한 부여 메커니즘 적용) | 13 | 7 | 1 | 2 | 2 | 1 |  |  |  |
| 4.3 | Ensure data encryption and masking (데이터 암호화 및 마스킹 보장) | 15 | 8 | 1 | 2 | 3 | 1 |  |  |  |
| 4.4 | Prepare logs for audit (감사용 로그 준비) | 11 | 1 | 4 | 3 | 1 | 1 | 1 |  |  |
| 4.5 | Understand data privacy and governance (데이터 프라이버시 및 거버넌스 이해) | 15 | 10 | 1 | 1 | 1 | 1 | 1 |  |  |
| **합계** | | **274** | **88** | **53** | **51** | **49** | **18** | **13** | **1** | **1** |

## 1. 먼저 볼 항목 (컨트롤러 선별 — 상세는 §4의 같은 ID)

> 아래 표는 17개 Task 노트를 쓴 리서처들의 gaps 항목을 컨트롤러가 주제별로 다시 묶은 **색인**이다. 사실 판단은 각 항목(§4)의 근거 URL을 따른다.

### 1.1 "무엇을 묻는지" 공식 근거로 확정할 수 없는 Skill (출제 범위 불확실)

v1.1 가이드는 Skill마다 한 줄만 적고 정의·예시가 거의 없다(Knowledge 항목이 사라졌다). 아래 Skill은 노트 작성자가 **가장 가까운 공식 근거로 해석**했을 뿐 출제 범위를 확정하지 못했다 — 문항화·학습문서 비중 결정 전에 사람 판단이 필요하다.

| Skill | 불확실한 점 | 항목 |
|---|---|---|
| 1.1.1 · 1.1.2 | 예시 목록이 "데이터 소스"와 "읽는 도구"를 섞어 씀 | G-1.1-04 |
| 1.1.3 | "배치 수집 구성 옵션"이 어느 서비스의 무슨 옵션인지 불명 | G-1.1-05 |
| 1.1.4 · 3.1.5 | "데이터 API 사용/유지 관리"의 정의 없음 | G-1.1-02, G-3.1-10 |
| 1.1.9 | 예시의 "Amazon RDS" 제한이 연결 수/요청 속도/IOPS 중 무엇인지 불명 | G-1.1-06 |
| 1.1.12 | "스테이트풀/스테이트리스 데이터 트랜잭션"의 정의 없음 | G-1.1-03 |
| 1.2.1 | 컨테이너 사용 최적화(EKS/ECS)의 범위 | G-1.2-10 |
| 1.2.9 | 3V(볼륨·속도·다양성)를 직접 정의하는 공식 근거가 얇음 | G-1.2-11 |
| 1.2.10 | LLM 통합이 묻는 범위; Athena·Glue가 Bedrock을 네이티브 호출하는 기능은 미확인 | G-1.2-12, G-1.2-08 |
| 1.3.2 · 1.3.3 | "성능·확장성", 서버리스 워크플로 "유지 관리"의 범위 | G-1.3-06, G-1.3-07 |
| 1.4.11 | 그래프·트리 자료구조가 시험에서 무엇을 묻는지 | G-1.4-06 |
| 2.1.2 · 2.1.6 · 2.1.8 | Lake Formation 구성 범위, 잠금 관리(DB 잠금 vs 객체 잠금), 서비스별 벡터 인덱스 지원 범위 | G-2.1-17, G-2.1-18, G-2.1-19 |
| 2.2.2 | "technical data catalog 구축·참조"가 묻는 활동(Hive 메타스토어 마이그레이션 비중 등) | G-2.2-04, G-2.2-05 |
| 2.3.5 | "비즈니스·법적 요구 삭제"의 범위(삭제 vs 보존) | G-2.3-08 |
| 2.4.1 · 2.4.2 | Lake Formation 스키마 설계, "데이터 특성 변경 해결" | G-2.4-03, G-2.4-02 |
| 3.1.6 | SageMaker Unified Studio "데이터 준비" 기능 범위 | G-3.1-06 |
| 3.2.2 · 3.2.6 | Lambda로 검증·정리하는 공식 예시, 롤링 평균 용어 | G-3.2-08, G-3.2-04 |
| 3.3.1 · 3.3.2 · 3.3.4 | 감사용 로그 추출, 로깅·모니터링 솔루션, 성능 문제 해결의 서비스·증상 | G-3.3-14, G-3.3-15 |
| 3.4.4 · 3.4.5 | 샘플링 기법, "데이터 스큐 메커니즘" | G-3.4-01, G-3.4-02 |
| 4.1.2 · 4.1.5 · 4.1.6 | "endpoints, and services"가 가리키는 것, 관리형 vs 비관리형 서비스 쌍 | G-4.1-03, G-4.1-04 |
| 4.2.1 · 4.2.3 | 사용자 지정 정책의 범위, "데이터베이스 사용자·그룹·역할" | G-4.2-11, G-4.2-04 |
| 4.3.1 · 4.3.4 | key salting의 공식 정의, "before transit"의 의미 | G-4.3-04, G-4.3-09 |
| 4.4.5 | EMR(대용량 로그) 예시가 가리키는 것 | G-4.4-10 |
| 4.5.2 · 4.5.3 · 4.5.5 | Macie+Lake Formation 연동 근거, 리전 간 백업 복사 통제, 주권 개정 의도 | G-4.5-01, G-4.5-03, G-4.5-07 |

### 1.2 서비스 개명·종료·신규 고객 중단 — 학습문서·문항에서 최신성 주의

가이드 Skill 문구와 범위 내 서비스 목록은 2025-12 기준이지만 공식 문서(2026-10 조회)는 이미 바뀐 것이 많다. **구명칭은 병기**하고, 신규 고객 중단(maintenance)·종료 대상은 정답 근거로 쓰지 말고 오답/최신성 함정으로만 쓰는 것을 권한다.

| 대상 | 상태(요지) | 영향 Task | 항목 |
|---|---|---|---|
| Amazon Kinesis Data Firehose | → Amazon Data Firehose (2024-02-12 개명). 가이드 범위 목록은 구명칭 | 1.1 · 1.2 · 3.2 · 4.4 | G-0-03, G-1.1-14, G-1.2-22, G-3.2-11, G-4.4-08 |
| Kinesis Data Analytics | → Managed Service for Apache Flink, KDA for SQL 단종 | 1.1 | G-1.1-15 |
| Amazon QuickSight | → Amazon Quick (Quick Sight는 Quick 안의 기능). Skill 3.2.1은 구명칭 | 3.2 · 4.2 | G-0-03, G-3.2-01, G-4.2-12 |
| Amazon MemoryDB for Redis | 현행 명칭 MemoryDB(Valkey 지원 2024-10-08). 가이드 목록은 구명칭 | 2.1 | G-0-03 |
| AWS SCT | 가이드가 범위 목록에서 제거했으나 Skill 2.4.3 예시에는 잔존 | 2.4 | G-0-04, G-2.4-01 |
| AWS CloudTrail Lake | 2026-05-31부터 신규 고객 중단(maintenance)인데 Skill 4.4.3은 Lake를 그대로 요구 | 3.3 · 4.4 | G-4.4-01, G-4.4-03 |
| AWS Glue | Ray 작업 신규 고객 중단(2026-04-30), Glue 1.0·2.0 수명 종료, Glue 6.0 GA·기본 버전 5.1 | 1.2 · 3.1 · 3.3 | G-1.2-01, G-1.2-02, G-3.1-03, G-3.3-08 |
| Redshift Python UDF | 2026-06-30 이후 지원 중단(단계 적용) — Redshift 문서 상단 배너 | 1.2 · 2.1 · 2.3 · 2.4 · 3.1 · 3.2 · 3.3 · 4.2 · 4.3 | G-1.2-06, G-2.1-05, G-2.3-16, G-2.4-08, G-3.1-13, G-3.2-09, G-3.3-11, G-4.2-13, G-4.3-06 |
| Redshift 노드·암호화 | RG(Graviton) 노드 신규, COPY/UNLOAD 클라이언트 측 암호화 종료 | 2.1 · 2.3 | G-2.1-05, G-2.3-14, G-2.3-07 |
| RDS Performance Insights | 2026-06-30 수명 종료 → Database Insights | 2.1 | G-2.1-07 |
| Service Availability Updates 대상 | Snowball Edge, Amazon Glacier(독립 서비스), S3 Object Lambda, SNS Message Data Protection, (범위 내) Kendra·Q Business·Bedrock Agents Classic 등 신규 고객 중단 | 1.2 · 1.3 · 2.1 · 4.3 | G-2.1-03, G-2.1-04, G-4.3-05, G-1.3-11, G-1.2-07 |
| S3 Reduced Redundancy Storage | 사용 비권장 | 2.3 | G-2.3-15 |
| Centralized Logging with OpenSearch | 솔루션 2026-12 종료 예정(OpenSearch Service 자체는 아님) | 3.3 · 4.4 | G-3.3-07, G-4.4-07 |
| Amazon Athena | 페더레이션 신규 커넥터가 Glue 카탈로그에 자동 등록(2026-04-21~); Spark: PySpark engine v3 수명 2027-04-01·Spark 3.5는 콘솔 노트북 미지원 | 1.2 · 3.1 · 3.2 | G-1.2-05, G-3.1-09, G-3.2-02 |
| Amazon EventBridge | 예약 규칙은 legacy → Scheduler 권장; 새 Custom Event Bus vs Classic(재시도 기본값 다름) | 1.1 · 1.3 · 3.1 | G-1.1-16, G-1.3-01, G-3.1-04 |
| AWS Lambda | "Lambda Event Functions" 용어, durable functions, Managed Instances(비동기 최대 90분 — "15분 절대 상한" 단정 주의) | 1.1 · 1.2 · 1.3 · 1.4 | G-1.3-04, G-1.4-02, G-1.1-19, G-1.2-14 |
| Amazon MWAA | MWAA Serverless 신규 옵션(시험 범위 불명) | 1.3 | G-1.3-03 |
| Amazon EMR | 7.10.0부터 S3A가 EMRFS를 대체(시험은 "EMRFS" 용어 가능) | 2.1 | G-2.1-06 |
| Amazon Bedrock Knowledge Bases | 2026-09-30부터 일부 커넥터 신규 생성 불가 | 2.4 | G-2.4-07 |
| SageMaker 계열 명칭 | Unified Studio · Catalog(DataZone 기반) · Lakehouse 표기 혼재 | 2.2 · 2.4 · 4.1 | G-2.2-08, G-2.4-06, G-4.1-09 |
| AWS Security Hub | Macie 문서가 "Security Hub CSPM"으로 표기 | 4.5 | G-4.5-05 |
| Amazon S3 암호화 | 객체 SSE 유형 변경 API(2026-01), 버킷 수준 암호화 유형 강제(2025-11) — 범위 내 여부 불명 | 4.3 | G-4.3-14 |
| AWS CodeCommit | 가이드 범위 목록에서 제거, 가용성 서술이 공식 페이지끼리 엇갈림 | 1.4 | G-1.4-03 |
| 지표·표기 잔재 | "CloudWatch Events" 표기, Kinesis `PutRecords.Records` 지표 deprecated | 3.3 | G-3.3-09, G-3.3-10 |

### 1.3 공식 문서 간 수치·서술 상충 — "수치 암기형" 문항으로 내지 말 것

노트 본문에는 1차 문서의 값만 싣고 상충은 표시했다. 문항에서 이 수치를 정답 근거로 쓰려면 Service Quotas 콘솔 등 최신 값을 먼저 확인해야 한다.

| 영역 | 상충 내용(요지) | 항목 |
|---|---|---|
| Kinesis Data Streams | 샤드당 쓰기 1 MB/s vs 10 MiB/s, 온디맨드 확장 상한, 기본 샤드 할당량의 적용 단위(스트림 vs 계정), EFO 한도, 보존 최대 7일 vs 365일 | G-1.1-07, G-1.1-09, G-1.1-10, G-1.1-11, G-2.1-11, G-3.3-04 |
| Amazon Data Firehose | Direct PUT 기본 수집 한도 5,000 vs 500,000 records/s | G-1.1-08 |
| AWS Glue | 트리거 유형 3종 vs 이벤트 트리거, 워커 타입 목록, 동시 실행 쿼터, 자동 재시도 기본값 0 vs 3, 크롤러 과금·최소 청구 시간, Data Catalog 객체 정의 | G-1.1-12, G-1.2-03, G-1.2-18, G-1.3-05, G-3.1-02, G-2.2-01, G-2.2-02 |
| Redshift | 기본 격리 수준, 구체화된 뷰 자동 새로 고침 우선순위, Serverless 최대 base capacity(512/1024), 작은 디멘션 테이블 ALL 분산 권고, auto-copy 상태(preview 여부), datashare "읽기 전용" 서술 | G-2.1-08, G-2.1-09, G-2.1-15, G-2.4-05, G-1.1-13, G-4.5-02 |
| Aurora · RDS | Aurora 볼륨 최대 크기(256 vs 128 vs 64 TiB), 읽기 복제본 수, pgvector 성능 향상 배수(8× vs 9×) | G-2.1-10, G-2.1-12, G-2.1-13 |
| 벡터·Bedrock | Bedrock Knowledge Bases 벡터 스토어 목록에 "EMR Serverless" 오기, S3 Tables 기본 compaction 전략 | G-2.1-14, G-2.1-16 |
| 통합·성능 | Zero-ETL 지원 범위, EMR Graviton 절감률(30% vs 35%), API Gateway 통합 타임아웃(29초 vs 30초), EventBridge Scheduler 일정 한도 | G-1.2-04, G-1.2-17, G-1.2-15, G-1.3-02 |
| Lambda · SQS | SQS 이벤트 소스 매핑 스케일링 수치(구 블로그 vs 현행), on-demand 확장 속도, provisioned 폴러 범위 | G-1.4-05, G-1.4-09, G-1.4-10 |
| Amazon S3 | Standard→IA "30일 선행" 조건, 128KB 규칙, 클래스 비교표(40KB·가용성·조회 요금), RTC SLA, DynamoDB TTL 삭제 시점, Access Points 개수(1,000 vs 10,000), Glacier 명칭 혼용 | G-2.3-01, G-2.3-02, G-2.3-03, G-2.3-04, G-2.3-05, G-4.1-06, G-2.3-06 |
| CloudWatch · CloudTrail | 구독 필터 5 vs 2, Logs Insights 동시 쿼리 100 vs 30, IA 클래스의 S3 내보내기, Delivery 클래스 보존, 메트릭 필터 정규식, Lake 보존 2,557 vs 2,555일, CloudTrail 로그 기본 암호화(SSE vs SSE-KMS), Lake 상태 서술 | G-3.3-01, G-3.3-02, G-3.3-03, G-4.4-06, G-3.3-05, G-4.4-04, G-4.4-05, G-4.4-03 |
| 보안 | KMS 요청 쿼터(같은 페이지 내 불일치), IAM 관리형 정책 연결 한도, Redshift 스냅샷 공유 시 "default KMS key", Redshift DDM 제약, SageMaker 구독 승인 주체·IAM 도메인 개수 한도 | G-4.3-01, G-4.2-07, G-4.3-02, G-4.3-08, G-4.5-08, G-2.2-09, G-4.1-02 |
| 기타 | DataBrew 프로파일 행 수, Quick Sight 요금, boto3 기본 재시도 모드, Glue Schema Registry 기본 호환성 모드 | G-3.4-05, G-3.2-03, G-3.1-01, G-2.4-11 |

### 1.4 학습문서 분할 제안 요약 (제안만 — 결정은 취합 세션)

17 Task·Skill 120개는 CLF(19 Task)보다 Task당 표면이 훨씬 넓다. 노트를 쓴 리서처들이 출처·소제목·사실 행 규모를 근거로 제안한 분할을 모으면 다음과 같다.

| Task | Skill 수 | 제안 문서 수 | 분할 요지 | 항목 |
|---|---|---|---|---|
| 1.1 | 12 | 3 | A 스트리밍 / B1 배치·데이터 API·스케줄러 / B2 이벤트 트리거·IP·제한·재처리 | G-1.1-01 |
| 1.2 | 10 | 3 | A 컴퓨트·엔진 선택·비용 / B 연결·통합·변환 실무 / C 데이터 API·3V·LLM | G-1.2-25 |
| 1.3 | 4 | 2 | 오케스트레이션 선택+Step Functions / 복원력+알림 | G-1.3-08 |
| 1.4 | 11 | 5 (D2·D3를 합치면 4) | D1 Lambda 구성·스토리지(1.4.2+1.4.7) / D2 최적화+분산 컴퓨팅(1.4.1+1.4.10) / D3 언어+자료구조(1.4.3+1.4.11) / D4 IaC·SAM(1.4.5+1.4.6+1.4.8) / D5 SW 공학·CI/CD(1.4.4+1.4.9) | G-1.4-01 |
| 2.1 | 8 | 5 | 분석 저장소 / 운영·NoSQL·스트림 / 벡터·인메모리 / 마이그레이션·원격 액세스 / 잠금·오픈 테이블 | G-2.1-01, G-2.1-02 |
| 2.2 | 6 | 2 (+교차 묶음) | Glue 카탈로그·크롤러·파티션·연결 / SageMaker Catalog(4.1.7·4.5.6과 묶기) | G-2.2-07 |
| 2.3 | 6 | 3 | Redshift COPY/UNLOAD / S3 수명 주기·버전·TTL / 보존·삭제·복원성 | G-2.3-17, G-2.3-18 |
| 2.4 | 6 | 3 | 모델 설계·최적화 / 스키마 진화·변환 / 계보·벡터화 | G-2.4-13 |
| 3.1 | 9 | 3 | MWAA·Step Functions 운영+EventBridge / EMR·Redshift·Glue·데이터 API·준비·Athena / SDK+Lambda | G-3.1-12 |
| 3.2 | 6 | 1 | 분할 불필요(출처 25·사실 39행). 3.2.5 범위 메모만 | G-3.2-07 |
| 3.3 | 8 | 3 (4.4와 공통 문서화) | 모니터링·알림·성능 / Glue·EMR 유지 관리 / 감사·로그 수집·분석(4.4와 합본) | G-3.3-16 |
| 3.4 | 5 | 1 | 분할 제안 없음 | – |
| 4.1 | 7 | 3 | 네트워크·접근 경로 / 자격 증명 회전·서비스 역할 / 관리형 vs 비관리형+SageMaker Unified Studio | G-4.1-01 |
| 4.2 | 6 | 2 | IAM 정책·권한 방식·최소 권한 / 자격 증명 저장·DB 권한·Lake Formation | G-4.2-01 |
| 4.3 | 4 | 2 | 마스킹·PII / 암호화(저장·교차 계정·전송) | G-4.3-13 |
| 4.4 | 5 | (3.3과 합본) | 3.3과 겹치는 4.4.1·4.4.2·4.4.4·4.4.5는 공통 문서 | G-4.4-11 |
| 4.5 | 7 | 3 | 데이터 공유·거버넌스 패턴 / 프라이버시·상주·주권 / 구성 변경(AWS Config, 4.4와 합본 대안) | G-4.5-14 |
| **합계** | **120** | **약 44편 (17 Task 대비 약 2.6배)** | 제안을 모두 받아들인 경우의 단순 합 — 권고가 아니라 규모 추정 | |

**Task를 가로지르는 묶음 후보**
- SageMaker Unified Studio/Catalog: Skill 2.2.6 + 4.1.7 + 4.5.6 (+2.4.4 일부) → G-2.2-07, G-4.1-01, G-4.5-14
- 로그·감사: Skill 3.3.5 = 4.4.1, 3.3.7 ≈ 4.4.2, 3.3.8 ≈ 4.4.4(+4.4.5 EMR 예시) → G-3.3-16, G-4.4-11
- 마스킹·PII: Skill 4.3.1 + 4.5.2 → G-4.3-13, G-4.5-14
- 스토리지 클래스 비교표 중복 관리(2.1.3 ↔ 2.3.2·2.3.3) → G-2.3-18, G-2.1-02; Redshift 분산 스타일·정렬 키(2.1.2 ↔ 2.4.1·2.4.5) → G-2.1-02
- 1.4.5 ≈ 1.4.8(IaC가 사실상 중복) → G-1.4-07

### 1.5 레포 `DEA-C01.json` 수정 제안 요약

| 구분 | 내용 | 항목 |
|---|---|---|
| 문구 | 서비스명 약칭 ↔ 전체명 8건(의미 동일, 수정 필수 아님) | G-0-01 (+ G-1.1-25, G-1.2-26, G-1.4-07에서 개별 확인) |
| 필드 추가(선택) | 가이드 버전·게시일(`guideVersion`, `guidePublished`), v1.1 신규/개정 표시, Skill ID, 서비스 범위 목록 | G-0-02, G-1.2-26, G-1.4-07, G-2.4-14 |
| 수정 불필요 확인 | Task 2.1 등은 공식 v1.1과 일치, `knowledge: []`는 v1.1 구조와 부합, Skill 3.1.6·4.4.3은 가이드 원문 그대로 유지(대신 학습문서에서 범위·상태 표시) | G-2.1-26, G-3.1-05, G-4.4-02 |
| 번역 어감 | 1.1.4·1.1.11·1.1.12의 공식 한국어가 영문 뜻을 흐림(JSON은 공식 번역과 일치 — 수정 비권장, 학습문서에 영문 병기) | G-1.1-26 |

> `[수정제안]` 태그가 붙어 있어도 JSON이 아니라 **노트 자체의 보강·인용 교체 후보**인 항목이 있다: G-1.2-23(본문 보강 후보), G-4.1-13·G-4.5-15(4-1.md·4-3.md 인용 중 서식 의존 행의 대체 인용 제안 — 컨트롤러 자동 대조(공백·서식 정규화)는 두 노트 모두 전수 통과했지만, 더 엄격한 문자열 대조를 쓸 경우 대비용).

### 1.6 문항 작성 시 공통 주의 (gaps에서 반복된 지침)

- 위 §1.3의 수치는 정답 근거로 쓰지 말고 개념("조정 가능", "기본값은 …")으로만 출제한다.
- §1.2의 신규 고객 중단·종료 대상은 정답 근거가 아니라 최신성 함정/오답 선택지로 쓴다. 현행 명칭과 가이드 표기(구명칭)를 병기한다.
- §1.1의 Skill은 "공식 해석 근거"를 먼저 확보한 뒤 문항화한다. 노트의 문항 후보 5개/Task는 모두 **미검수 재료**다(`verified:false` 취급, 사람 검수 필요).
- 시험은 일부 서비스를 약칭으로 출제한다(00-overview M19): 공식 전체명+약칭 병기.

## 2. 학습문서 분할 제안 색인 (제안만 — 결정은 취합 세션)

| 항목 | Task | 요약 |
|---|---|---|
| G-1.1-01 | 1.1 | Task 1.1(Skill 12개, 서비스 20여 개)은 학습문서 1개로는 과하다. 1-1.md는 출처 56개(브리프 권장 12~30), 사실 행 124개, 개념 소제목 12개, 비교 표 5개다. 3분할을 제안한다(제안만, 결정은 취합 세션).… |
| G-1.2-25 | 1.2 | Task 1.2는 Skill 10개, 서비스 15개 이상, 본문 출처 61개, 사실표 97행으로 학습문서 1개에는 과하다. 3개 문서를 제안한다. (A) 컴퓨트·엔진 선택·비용 = Skill 1.2.1 + 1.2.4 + 1.2.5 (컨테이너, Glue… |
| G-1.3-08 | 1.3 | Task 1.3은 Skill 4개에 서비스 10여 개(Step Functions, MWAA, EventBridge, Glue 워크플로, Lambda, SNS, SQS, Well-Architected)가 걸려 학습문서 1개로는 길다. 제안: (a) "오… |
| G-1.4-01 | 1.4 | Skill 11개를 학습문서 1개로 쓰기엔 과하다. 5개 문서로 나누기를 제안한다(D2와 D3를 합치면 4개). 결정은 취합 세션 몫이다.… |
| G-2.1-01 | 2.1 | Task 2.1은 Skill 8개·소제목 15개·비교 표 8개·사실 97행·출처 66개로 학습문서 1개로는 과하다(컨트롤러 목표 출처 20~30개를 넘긴 것도 Skill 8개 규모 때문). 아래 5개 문서 분할을 제안한다(결정은 취합 세션).… |
| G-2.1-02 | 2.1 | 인접 Task와의 경계 중복(노트는 2.1 관점으로 최소 기술).… |
| G-2.2-07 | 2.2 | Skill 2.2.6을 SageMaker Unified Studio 관련 Skill과 묶는 안… |
| G-2.3-17 | 2.3 | Task 2.3을 학습문서 3편으로 나누는 안… |
| G-2.3-18 | 2.3 | 스토리지 클래스 비교표의 중복 저작 방지… |
| G-2.4-13 | 2.4 | Task 2.4는 Skill 6개가 서로 거의 겹치지 않는 서비스 군(Redshift·DynamoDB·Lake Formation / Glue·Athena·DMS / SageMaker·DataZone / Bedrock)에 걸쳐 노트가 길다(사실 78행·… |
| G-3.1-12 | 3.1 | Task 3.1은 Skill 9개에 서비스가 15개 안팎(MWAA, Step Functions, boto3, EMR, Redshift, Glue, Data API, DataBrew, SageMaker Unified Studio, Athena, Lamb… |
| G-3.2-07 | 3.2 | Skill 3.2.5(프로비저닝 vs 서버리스)는 서비스 범위가 열려 있다. 노트는 Redshift·EMR·Kinesis Data Streams·Athena만 다뤘고, MSK Serverless vs Provisioned와 DynamoDB 용량 모드는… |
| G-3.3-16 | 3.3 | Task 3.3은 Skill 8개가 CloudTrail·CloudWatch·EventBridge·Glue·EMR·Redshift·Athena·Kinesis·Lambda·DynamoDB·S3·OpenSearch에 걸쳐 학습문서 1개로는 과하다. 제안(결… |
| G-4.1-01 | 4.1 | Task 4.1은 Skill 7개·서비스 10여 개(보안 그룹·Glue·IAM·엔드포인트·Secrets Manager·Lambda·API Gateway·CLI·CloudFormation·Redshift·EMR·S3 Access Points·SageMa… |
| G-4.2-01 | 4.2 | Task 4.2는 Skill 6개·출처 25개·사실 40행으로 학습문서 1개도 가능하지만 IAM 정책 영역과 데이터 계층(저장소·DB·Lake Formation) 영역이 갈려 2개 분할을 제안한다(결정은 취합 세션).… |
| G-4.3-13 | 4.3 | Task 4.3은 Skill 4개지만 분량이 커서 학습문서 1개는 과하다. 제안: (문서 A) "마스킹·PII 보호" = 4.3.1 + 4.5.2(PII 식별: Macie) 일부, (문서 B) "암호화 — 저장 시(KMS·S3·서비스별)·교차 계정·전… |
| G-4.4-11 | 4.4 | 4.4의 Skill 4.4.1·4.4.2·4.4.4·4.4.5는 3.3의 3.3.5·3.3.7·3.3.8과 겹친다. 학습문서 경계 제안은 G-3.3-16 참조. 4-4.md는 "감사 준비·보존·무결성·중앙화" 관점, 3-3.md는 "운영·알림·분석" … |
| G-4.5-14 | 4.5 | Skill 7개를 학습문서 1개에 담기에는 주제가 이질적이다. 제안: (문서 A) "데이터 공유·거버넌스 패턴" = 4.5.1 + 4.5.6 + 4.5.7 — Redshift 데이터 공유, Lake Formation 관리 datashare, SageM… |

(상세는 §4 각 Task 절의 해당 항목.)

## 3. 레포 `DEA-C01.json` 수정 제안 색인

| 항목 | Task | 요약 |
|---|---|---|
| G-0-01 | 0 | 레포 `flutter_app/assets/exam_guides/DEA-C01.json`의 Skill 8건이 현행 공식 KO 가이드와 문구가 다르다(모두 서비스명 약칭 ↔ 전체명 차이, 의미 동일): 1.1.1(AWS DMS), 1.2.1(Amazon … |
| G-0-02 | 0 | JSON에 가이드 버전·게시일 필드가 없다. 현행 공식 가이드는 v1.1(2025-12-12)이며 v1.0과 구조가 다르다(Knowledge+Skill 통합). `guideVersion: "1.1"`, `guidePublished: "2025-12-1… |
| G-1.1-25 | 1.1 | `flutter_app/assets/exam_guides/DEA-C01.json`의 Task 1.1 Skill 12개를 공식 KO 가이드 문구(1-1.md 헤더 표 — 컨트롤러가 2026-10-19에 라이브 대조했다고 G-0-05에 기록)와 문자열 비… |
| G-1.1-26 | 1.1 | 공식 한국어 번역이 영어 원문의 뜻을 흐리는 Skill이 있다. 1.1.4 "Consume data APIs" → "데이터 API 사용"(소비하는 쪽임이 덜 드러남), 1.1.11 "Describe replayability" → "반복 재생 가능성 설… |
| G-1.2-23 | 1.2 | 본문 보강 후보 — 확인했지만 분량·범위 때문에 본문 사실표에 넣지 않은 사실(필요 시 사실표에 행 추가). (1) RDS Proxy pinning: 연결을 멀티플렉싱할 수 없으면 클라이언트가 세션 내내 같은 프록시 연결을 쓰는 pinning이 되어 … |
| G-1.2-26 | 1.2 | DEA-C01.json (Task 1.2): `flutter_app/assets/exam_guides/DEA-C01.json`의 Task 1.2 Skill 10개 문구는 공식 KO 가이드와 일치하지만 Skill 1.2.1만 서비스명을 풀어 쓴다(JSO… |
| G-1.4-07 | 1.4 | Skill 1.4.5와 1.4.8이 사실상 중복이다. 1.4.8("반복 가능한 리소스 배포를 위한 IaC, 예: CloudFormation·CDK")은 v1.0의 지식 항목("Infrastructure as code (IaC) for repeatabl… |
| G-2.1-26 | 2.1 | `flutter_app/assets/exam_guides/DEA-C01.json`의 Task 2.1은 skills 8개·knowledge [] 모두 공식 영문 가이드 v1.1 domain2 페이지와 일치한다(수정 불필요).… |
| G-2.4-14 | 2.4 | flutter_app/assets/exam_guides/DEA-C01.json(읽기 전용): Skill 2.4.3 "스키마 변환 수행(예: AWS 스키마 변환 도구(AWS SCT) 및 AWS Database Migration Service(AWS DM… |
| G-3.1-05 | 3.1 | 시험 가이드 in-scope 서비스 목록과 Skill 3.1.6의 불일치. Skill 3.1.6 원문은 "AWS Glue DataBrew and Amazon SageMaker Unified Studio"를 예로 들지만, DEA-C01 in-scope … |
| G-4.1-13 | 4.1 | 코디네이터 지침(표 셀·링크/코드 서식·문장부호 주변 공백이 대조 실패의 주원인)에 따라 4-1.md 사실 표와 문항 후보의 인용 104개를 원문 .md(docs.aws.amazon.com 페이지는 URL의 .html을 .md로 바꿔 curl로 읽음)… |
| G-4.4-02 | 4.4 | 레포 `flutter_app/assets/exam_guides/DEA-C01.json`의 Task 4.4 `skills[2]` "중앙 집중식 로깅 쿼리에 AWS CloudTrail Lake 사용"은 공식 번역 정본이므로 문구를 바꾸지 않는 것을 권한다… |
| G-4.5-15 | 4.5 | (4.3 노트 사후 점검 — 4-3.md는 이번 지시 범위 밖이라 수정하지 않았다) 라이브 페이지(.md 또는 HTML 텍스트)에 공백 정규화 후 문자열 포함 검사를 한 결과 4-3.md 인용 124개 중 다음 9개가 서식 때문에 자동 대조에서 실패할… |

## 4. Task별 gaps 전체 (원문 취합)

### 전역 — 가이드·레포 JSON·서비스 목록 (컨트롤러 확인)

- G-0-01 [수정제안] 레포 `flutter_app/assets/exam_guides/DEA-C01.json`의 Skill 8건이 현행 공식 KO 가이드와 문구가 다르다(모두 서비스명 약칭 ↔ 전체명 차이, 의미 동일): 1.1.1(AWS DMS), 1.2.1(Amazon EKS·ECS), 1.3.4(SNS·SQS + "알림을 전송"), 1.4.6(AWS SAM), 1.4.8(AWS CDK), 2.4.3(AWS SCT·AWS DMS), 4.1.2(IAM), 4.3.2(AWS KMS). JSON은 전체명으로 풀어 쓴 문구, 공식 페이지는 약칭. 비교표는 `00-overview.md` §7.
  - 확인 시도: 공식 KO 가이드 도메인 1·2·4 페이지(`.md` 원문)를 프로그램으로 파싱해 JSON과 문자열 대조(2026-10-17 최초, 2026-10-19 재대조 동일). https://docs.aws.amazon.com/ko_kr/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain1.html · …-domain2.html · …-domain4.html
  - 후속: 수정은 필수가 아니다(기능 영향 없음, 풀네임이 학습용으로 유용). 공식 문구에 맞출지 취합 세션이 결정. 맞춘다면 위 8건만 바꾸면 된다.

- G-0-02 [수정제안] JSON에 가이드 버전·게시일 필드가 없다. 현행 공식 가이드는 v1.1(2025-12-12)이며 v1.0과 구조가 다르다(Knowledge+Skill 통합). `guideVersion: "1.1"`, `guidePublished: "2025-12-12"` 같은 필드를 추가하면 다음 개정 때 비교가 쉽다. JSON의 `knowledge: []`는 v1.1 구조와 부합하므로 수정 불필요.
  - 확인 시도: https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-revisions.html (EN), …/ko_kr/…/dea-01-revisions.html (KO) — 개정 이력 표.
  - 후속: 취합 세션 결정. 추가 시 `00-overview.md` §2·§5의 개정 요약을 근거로 삼는다.

- G-0-03 [개명·종료] 가이드 "In-Scope AWS Services" 목록(EN·KO 동일)이 구명칭을 쓴다: "Amazon Kinesis Data Firehose"(공식 개명: Amazon Data Firehose, 2024-02-12), "Amazon MemoryDB for Redis"(Skill 2.1.3 문구는 "Amazon MemoryDB"; MemoryDB는 2024-10-08부터 Valkey 지원). 또 Skill 3.2.1은 "Amazon QuickSight"인데 같은 목록은 "Amazon Quick"이다 — 공식 문서: "Amazon Quick evolved from Amazon QuickSight", QuickSight는 Quick 안의 "Amazon Quick Sight" 기능으로 계속.
  - 근거: https://aws.amazon.com/blogs/compute/amazon-kinesis-firehose-data-transformation-with-aws-lambda/ ("Amazon Kinesis Data Firehose has been renamed to Amazon Data Firehose.") · https://docs.aws.amazon.com/cli/latest/reference/firehose/index.html · https://docs.aws.amazon.com/quick/latest/userguide/what-is.html · https://docs.aws.amazon.com/memorydb/latest/devguide/doc-history.html · 목록: https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-in-scope-services.html
  - 확인 시도: 목록 페이지(EN·KO)·개명 공지 직접 읽음. 시험 문항이 어느 명칭을 쓰는지는 확인 불가(인증 페이지: 시험은 일부 서비스를 약칭으로 출제, 약칭 목록은 시험 Help 버튼에서만 제공).
  - 후속: 학습문서에는 "현행 명칭(구명칭/시험 표기)" 병기를 권장.

- G-0-04 [불확실] Skill 2.4.3 예시에 "AWS SCT"가 남아 있는데 v1.1 개정 이력은 AWS Schema Conversion Tool(AWS SCT)을 **범위 내 서비스 목록에서 제거**했다고 적는다(같은 개정에서 Cloud9·CodeCommit도 제거). 어느 쪽이 시험 출제 기준인지 공식 문서로 확정할 수 없다.
  - 근거: https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-revisions.html (Services removed from the in-scope list) · https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain2.html (Skill 2.4.3)
  - 확인 시도: 두 페이지 직접 읽음(EN·KO 동일).
  - 후속: 문항에서 SCT를 정답으로 단정하지 말고 "SCT 또는 DMS Schema Conversion" 형태로 서술하거나 DMS Schema Conversion을 중심에 둘 것(2-4 노트 gaps 참조).

- G-0-05 [불확실] 가이드 PDF 렌더(EN `https://docs.aws.amazon.com/pdfs/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01.pdf`, KO `https://docs.aws.amazon.com/ko_kr/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01.pdf`)의 HTTP Last-Modified가 각각 2026-10-16, 2026-10-15이다. 개정 이력(v1.1 = 2025-12-12)과 별개로 문서 빌드가 갱신된 것인지, 내용 변경인지 확인하지 못했다. 이 환경에는 PDF 텍스트 추출 도구가 없어 PDF 본문은 읽지 못했다.
  - 확인 시도: curl HEAD로 응답 헤더 확인. HTML 가이드(정본) 도메인 1~4 페이지는 2026-10-19에 라이브 대조해 노트 17개의 Skill 표와 문자 단위로 동일함을 확인.
  - 후속: HTML이 정본이므로 영향 없음으로 판단(추정). 필요하면 사람이 PDF 첫 쪽의 버전 표기를 확인.

- G-0-06 [확인필요] 구 시험 가이드 PDF가 아직 서빙된다: `https://d1.awsstatic.com/training-and-certification/docs-data-engineer-associate/AWS-Certified-Data-Engineer-Associate_Exam-Guide.pdf` (HTTP 200, Last-Modified 2025-02-14, 약 163 KB, PDF 메타 19쪽·생성일 2023-10-31). v1.1(2025-12-12)보다 이전 파일이라 v1.1 신규 Skill을 담을 수 없다. 인증 페이지는 이 PDF가 아닌 HTML 가이드를 링크한다. 본문은 파싱하지 못했다(도구 없음) → v1.0이라는 것은 날짜로 추정한 것이다.
  - 확인 시도: curl HEAD, WebFetch(PDF 본문 추출 실패, 메타데이터만).
  - 후속: DEA 학습문서의 출처로 이 PDF를 쓰지 말 것(레포 CLF 매핑 문서는 PDF를 출처로 썼으나 DEA는 HTML 가이드가 정본).

- G-0-07 [불확실] 범위 내 서비스 목록의 Storage 항목에 "Amazon S3 Tables"가 두 번 나온다(EN·KO 동일: S3, S3 Tables, S3 Glacier, S3 Tables). 오탈자로 추정되나 확인 불가.
  - 근거: https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-in-scope-services.html
  - 후속: 영향 없음(S3 Tables는 Skill 2.1.7 관련 신규 범위 내 서비스).

- G-0-08 [확인필요] 시험 화면 Help 버튼의 "약칭↔전체명 목록"은 공개 페이지에 없다. 시험이 어떤 약칭을 쓰는지 공식 근거로 확인할 수 없다(영문판에 먼저 적용, 타 언어는 순차 적용).
  - 근거: https://aws.amazon.com/certification/certified-data-engineer-associate/ ("This exam uses short names of some AWS services.")
  - 후속: 한국어판에서 어느 표기가 쓰이는지는 응시자 경험으로만 확인 가능(사람 작업).

- G-0-09 [정보] Task 단위 출제 비중은 가이드에 없다(도메인 비중만: 34/26/22/18). 도메인 비중을 Task 수로 나눈 값은 공식 값이 아니다.
  - 근거: https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01.html

- G-0-10 [확인필요] 범위 내 서비스 목록에 없지만 Skill이 직접 요구하는 서비스가 있다: Skill 4.1.7(SageMaker Unified Studio 도메인·프로젝트), 2.2.6/2.4.4/4.5.6(Amazon SageMaker Catalog) — 목록에는 "Amazon SageMaker AI"만 있다. 반대로 목록에 없는 AWS Clean Rooms·IAM Identity Center·Amazon Kinesis Video Streams·Amazon Timestream 등은 Skill에 직접 등장하지 않는다(단 다른 서비스 문서에서 언급될 수 있음). 우선순위는 Skill 문구 > 서비스 목록으로 두었다.
  - 근거: 가이드 domain2·domain4 페이지와 in-scope 페이지(위 URL).
  - 후속: 취합 세션이 문서 범위를 정할 때 Skill 문구 기준을 유지.
  - 근거 URL 보강(컨트롤러, 2026-10-19 열람·인용문 원문 확인): https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain2.html · https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain4.html · https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-in-scope-services.html

- G-0-11 [해결됨] 2-1 노트 gaps G-2.1-22("In-Scope AWS Services 페이지 URL 미확보")는 컨트롤러가 해결했다. URL = https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-in-scope-services.html (KO: …/ko_kr/…). 확인 결과 DocumentDB·Neptune·Keyspaces·MemoryDB for Redis 모두 Database 카테고리에 포함, Redshift도 Database 카테고리에 있다. 전체 목록은 `00-overview.md` §6.

### Task 1.1 — Perform data ingestion (데이터 수집 수행)

- G-1.1-01 [분할제안] Task 1.1(Skill 12개, 서비스 20여 개)은 학습문서 1개로는 과하다. 1-1.md는 출처 56개(브리프 권장 12~30), 사실 행 124개, 개념 소제목 12개, 비교 표 5개다. 3분할을 제안한다(제안만, 결정은 취합 세션).
  - 문서 A "스트리밍 수집·소비·상태" = Skill 1.1.1, 1.1.7, 1.1.10, 1.1.12 + 1.1.9의 Kinesis 부분 + 1.1.11의 스트림 재생 부분(KDS 보존·시작 위치, Kafka 오프셋, Firehose는 재생 수단이 아님). 1-1.md 소제목: 스트리밍 수집 서비스 선택 / Kinesis Data Streams / Amazon Data Firehose / CDC·기타 스트리밍 소스 / Kinesis → Lambda / 스테이트풀·스테이트리스 / 팬인·팬아웃·재생 가능성 중 스트림 부분. 출처 25개. (Firehose 버퍼링은 Skill 1.1.3 내용이지만 Firehose 절에 있으므로 A에 두고 B1에서 교차 참조.)
  - 문서 B1 "배치 수집·데이터 API·스케줄러" = Skill 1.1.2, 1.1.3, 1.1.4, 1.1.5. 소제목: 배치 소스·배치 구성 옵션·데이터 API / 스케줄러. 출처 18개.
  - 문서 B2 "이벤트 트리거·IP 허용 목록·속도 제한·재처리" = Skill 1.1.6, 1.1.8, 1.1.9의 DynamoDB·RDS 부분, 1.1.11의 배치·이벤트 재생 부분(Glue 북마크 rewind, EventBridge Archive, SQS DLQ redrive). 소제목: 이벤트 트리거 / IP 허용 목록 / 쓰로틀링·속도 제한 극복 / 팬인·팬아웃·재생 가능성 중 SNS→SQS·EventBridge·재생 부분. 출처 22개.
  - 합집합은 56개이고 문서 간 중복은 적다(S21은 세 문서 공통, S1·S8·S11은 A·B2, S25·S30·S31·S32는 B1·B2). 2분할이면 A 24개 / 나머지 35개로 둘째 문서가 30개 상한을 넘는다.
  - 문항 후보 대응: 후보 1·2·5(Skill 1.1.1·1.1.7·1.1.9) → A, 후보 3·4(Skill 1.1.6·1.1.8) → B2. B1(Skill 1.1.2~1.1.5)에 해당하는 후보는 현재 없다.
  - 확인 시도: 1-1.md 개념 절의 소제목별 [S#]를 읽기 전용 스크립트로 집계(2026-10-19). Skill 12개의 범위는 가이드 도메인 1 페이지 기준 https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain1.html . 분할 자체는 구조 판단이라 외부 URL 근거가 따로 없다.
  - 후속: 취합 세션이 결정. 분할하면 사실 행·함정 짝·문항 후보를 Skill 기준으로 재배분하고, B1용 문항 후보를 새로 만들어야 한다(현 후보 5개는 Skill 1.1.1·1.1.6·1.1.7·1.1.8·1.1.9만 다룸).

- G-1.1-02 [불확실] Skill 1.1.4 "Consume data APIs"(KO "데이터 API 사용")가 무엇을 가리키는지 공식 근거로 확정할 수 없다. 가이드는 이 한 문장만 적고 정의·예시가 없으며 v1.1에는 Knowledge 항목도 없다(레포 JSON도 knowledge []). 같은 도메인의 Task 1.2에 "Create data APIs to make data available to other systems…"(Skill 1.2.8)가 따로 있어 1.1.4는 만드는 쪽이 아니라 소비하는 쪽으로 읽힌다(추정).
  - 본문에 쓴 근거(가장 가까운 공식 문서): Amazon Redshift Data API(S30, #83~#85) https://docs.aws.amazon.com/redshift/latest/mgmt/data-api.html ; AWS Glue REST API 커넥터(S26, #124) https://docs.aws.amazon.com/glue/latest/dg/connecting-to-data-rest-api.html
  - 본문에 넣지 않은 후보(재확인 10-19): RDS Data API — Aurora DB 클러스터에 SQL을 실행하는 HTTP 엔드포인트, 응답 크기 한도 1 MiB https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/data-api.limitations.html ; AWS Data Exchange for APIs — 서드파티 API를 AWS SDK로 동기 호출 https://aws.amazon.com/blogs/aws/data-exchange-for-apis-find-subscribe-use-third-party-apis-consistent-authentication/ . Athena·AppFlow 사용자 지정 커넥터·API Gateway 호출 등 다른 해석은 조사하지 않았다.
  - 확인 시도: 가이드 도메인 1 페이지의 1.1.4 문구 https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain1.html , 1-2.md 스켈레톤의 Skill 1.2.8, AWS 문서 검색(RDS Data API, Data Exchange for APIs).
  - 후속: 취합 세션이 1.1.4 문항 범위를 "드라이버·연결 관리 없이 호출하는 Data API(Redshift)"와 "REST 소스 수집(Glue)" 수준으로 한정할지 결정. 정답 근거로 쓰기 전 사람 검수.

- G-1.1-03 [불확실] Skill 1.1.12 "Define stateful and stateless data transactions"(KO "스테이트풀 및 스테이트리스 데이터 트랜잭션 정의")의 의도를 공식 근거로 확정할 수 없다. 가이드는 정의·예시를 주지 않고 레포 JSON의 knowledge도 비어 있다. 본문은 공식 문서의 stateless/stateful 용례를 모아 "레코드·호출 사이에 기억해야 하는 정보(윈도 집계 상태, 체크포인트·오프셋, 북마크)가 있는가"로 귀납했다(귀납 요약이며 공식 정의가 아님 — 1-1.md 해당 절에 명시).
  - 가장 가까운 공식 근거(모두 본문 사용): Lambda 호출은 기본 무상태, 텀블링 윈도 상태는 샤드당 최대 1 MB(S7, #29·#30) https://docs.aws.amazon.com/lambda/latest/dg/services-kinesis-windows.html ; KDS 서비스 관리형 분배는 순서가 필요 없는 무상태 워크로드용(S3, #14) https://docs.aws.amazon.com/streams/latest/dev/service-managed-record-distribution.html ; Managed Service for Apache Flink의 체크포인트·스냅샷(S50, #111) https://docs.aws.amazon.com/managed-flink/latest/java/how-fault.html ; Flink 개명 발표문의 "stateful stream processing"(S51, #112) https://aws.amazon.com/blogs/aws/announcing-amazon-managed-service-for-apache-flink-renamed-from-amazon-kinesis-data-analytics/ ; Glue 잡 북마크 = 상태 정보(S21, #71) https://docs.aws.amazon.com/glue/latest/dg/monitor-continuations.html ; MSK Serverless + Flink의 stateful 스트림 처리(S14, #57) https://aws.amazon.com/msk/faqs/
  - 다른 해석 후보(본문 미수록, 재확인 10-19): API Gateway에서 REST/HTTP API는 stateless 클라이언트-서버 통신, WebSocket API는 stateful 양방향 통신이며 "stateful frontend"로 서술된다 https://docs.aws.amazon.com/help-panel/apigateway/latest/console/choose-api-type.html , https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-websocket-api-overview.html . DB 트랜잭션(ACID) 의미로 읽는 해석은 조사하지 않았다.
  - 확인 시도: 가이드 도메인 1 페이지의 1.1.12 문구 확인, AWS 문서 검색으로 stateful/stateless 용례 수집(Lambda·KDS·Flink·Glue·MSK·API Gateway).
  - 후속: 취합 세션이 이 Skill의 문항을 용례 수준(Lambda 무상태/텀블링 윈도 상태, Flink 체크포인트/스냅샷)으로 한정하고 정의형 문항은 피한다. 공식 정의를 확정할 문서는 찾지 못했다.
  - 근거 URL 보강(컨트롤러, 2026-10-19 열람·인용문 원문 확인): https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain1.html (Skill 1.1.12 원문)

- G-1.1-04 [불확실] Skill 1.1.1·1.1.2의 예시 목록이 "소스"와 "읽는 도구"를 섞어 쓴다. 1.1.1은 스트리밍 소스 예시에 AWS Glue·Amazon Redshift를, 1.1.2는 배치 소스 예시에 Glue·EMR·Lambda·Redshift를 든다. 이들은 데이터가 나오는 소스라기보다 스트림/배치를 읽어 들이는 쪽이다. 본문은 "스트림을 읽는 기능"(Glue 스트리밍 ETL S20, Redshift 스트리밍 수집 S27)과 "배치로 읽는 방법"(Glue 북마크 S21·파일 그룹화 S54·JDBC 병렬 읽기 S55, EMR S3DistCp S34, Lambda 제한 시간 S33)으로 해석했으나 출제 의도는 공식 근거로 확정할 수 없다. 특히 EMR(S3DistCp 한 건)과 Lambda(제한 시간 한 건)는 근거가 얇다.
  - URL: https://docs.aws.amazon.com/glue/latest/dg/add-job-streaming.html ; https://docs.aws.amazon.com/redshift/latest/dg/materialized-view-streaming-ingestion.html ; https://docs.aws.amazon.com/emr/latest/ReleaseGuide/UsingEMR_s3distcp.html ; https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-limits.html
  - 확인 시도: 가이드 문구와 1-1.md 해당 절(CDC·기타 스트리밍 소스 / 배치 소스) 대조.
  - 후속: 취합 세션이 해석 유지 여부 결정. EMR·Lambda를 배치 소스로 쓰는 추가 공식 근거는 미조사 — 필요하면 후속 조사.

- G-1.1-05 [불확실] Skill 1.1.3 "Implement appropriate configuration options for batch ingestion"(KO "배치 수집을 위한 적절한 구성 옵션 구현")은 어떤 서비스의 어떤 옵션인지 가이드가 밝히지 않는다. 본문은 서비스별 문서에서 확인된 구성 항목을 모아 "구성 옵션 체크리스트"로 묶었다(파일 크기·형식·압축·파티션·증분·병렬도·스케줄 간격: Firehose 버퍼링 S8·S9, Redshift COPY/UNLOAD S28·S29, Glue 북마크·그룹화·JDBC 병렬 S21·S54·S55, DMS MaxFullLoadSubTasks S53, AppFlow 증분 S31). 즉 범위는 추정이며 서비스별로 빠진 옵션이 있을 수 있다(예: DMS의 S3 대상 파일 크기 속성은 G-1.1-23에 따로 기록).
  - URL: 가이드 https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain1.html ; 본문이 모은 옵션의 근거 — Firehose 버퍼링 https://docs.aws.amazon.com/firehose/latest/dev/create-configure-backup.html ; Redshift COPY https://docs.aws.amazon.com/redshift/latest/dg/c_best-practices-use-multiple-files.html ; Glue 북마크 https://docs.aws.amazon.com/glue/latest/dg/monitor-continuations.html ; DMS 전체 로드 https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Tasks.CustomizingTasks.TaskSettings.FullLoad.html ; AppFlow 트리거 https://docs.aws.amazon.com/appflow/latest/userguide/flow-triggers.html
  - 확인 시도: 가이드 문구, 1-1.md "구성 옵션 체크리스트" 불릿 대조.
  - 후속: 취합 세션이 문항 범위를 "서비스 선택 + 대표 옵션 한두 개" 수준으로 한정할지 결정.

- G-1.1-06 [불확실] Skill 1.1.9 "throttling and overcoming rate limits (for example, DynamoDB, Amazon RDS, Kinesis)"의 "Amazon RDS"가 가리키는 제한(연결 수 / API 요청 속도 / IOPS 등)을 공식 근거로 확정할 수 없다. 본문은 RDS Proxy의 연결 풀링·멀티플렉싱(S47, #107)만 다뤘다. RDS API 요청 속도 제한, 인스턴스 연결 수 한도 등은 조사하지 않았다.
  - URL: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/rds-proxy.howitworks.html
  - 확인 시도: S47 읽음, 가이드 문구 확인.
  - 후속: 취합 세션이 1.1.9의 RDS 문항을 "연결 폭증 → RDS Proxy"로 한정할지 결정. 다른 해석이 필요하면 RDS 문서에서 추가 조사.
  - 근거 URL 보강(컨트롤러, 2026-10-19 열람·인용문 원문 확인): https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain1.html (Skill 1.1.9 원문)

- G-1.1-07 [상충] KDS 샤드당 쓰기 처리량이 페이지마다 다르다(1 MB/s vs 10 MiB/s).
  - 1 MB/s(= 1,000 records/s): KDS FAQ(S1) https://aws.amazon.com/kinesis/data-streams/faqs/ , 할당량 페이지(S2)의 프로비저닝 열과 PutRecords 행 https://docs.aws.amazon.com/streams/latest/dev/service-sizes-and-limits.html
  - 10 MiB/s: 같은 S2 페이지의 PutRecord 행, 그리고 PutRecord API 레퍼런스("a maximum data write total of 10 MiB per second") https://docs.aws.amazon.com/kinesis/latest/APIReference/API_PutRecord.html
  - 설명 문서: 대용량 레코드(최대 10 MiB) 지원 뒤에도 샤드 쓰기 1 MB/s·읽기 2 MB/s 한도는 그대로이고, 10 MiB/s는 간헐적 대용량 레코드를 위한 순간 버스트라는 설명 https://docs.aws.amazon.com/streams/latest/dev/large-records.html , https://aws.amazon.com/blogs/big-data/amazon-kinesis-data-streams-now-supports-10x-larger-record-sizes-simplifying-real-time-data-processing/ ("bursts up to 10MiB/s, eventually averaging out to 1MiB per second")
  - 본문 처리: 행 1·11은 1 MB/s를 사용하고 10 MiB/s는 쓰지 않았다(행 4의 10 MiB는 레코드 크기).
  - 확인 시도: S1, S2 전문, PutRecord API 레퍼런스, 대용량 레코드 페이지, 블로그(재확인 10-19).
  - 후속: 문항·해설에서 샤드 쓰기 한도는 1 MB/s·1,000 records/s로 쓰고 10 MiB/s를 근거로 삼지 말 것(설명 문서가 버스트라고 밝힘).

- G-1.1-08 [상충] Amazon Data Firehose Direct PUT 기본 수집 한도가 FAQ와 할당량 페이지에서 다르다(records/s 기준 5,000 vs 500,000).
  - FAQ(S8) https://aws.amazon.com/firehose/faqs/ 와 Firehose API 레퍼런스 PutRecord https://docs.aws.amazon.com/firehose/latest/APIReference/API_PutRecord.html : 스트림당 기본 "2,000 transactions/second, 5,000 records/second, and 5 MB/second".
  - 할당량 페이지(S11) https://docs.aws.amazon.com/firehose/latest/dev/limits.html : US East (N. Virginia)·US West (Oregon)·Europe (Ireland)는 500,000 records/s · 2,000 requests/s · 5 MiB/s, 그 밖의 리전은 100,000 records/s · 1,000 requests/s · 1 MiB/s.
  - 레코드 크기 표기도 다르다: FAQ는 Direct PUT·KDS 소스 1024 KB, MSK 소스 10 MB / 할당량 페이지는 1,000 KiB, MSK 소스 10 MB(Lambda 변환을 켜면 6 MB).
  - 본문 처리: 행 38·39는 할당량 페이지(S11) 값을 사용했고 FAQ의 5,000 records/s 값은 쓰지 않았다.
  - 확인 시도: S8 FAQ, S11 할당량 페이지, Firehose API 레퍼런스를 직접 읽음(재확인 10-19). 어느 쪽이 현행인지 문서만으로는 판정 불가(FAQ가 낡았을 가능성은 추정).
  - 후속: 문항에서 Firehose 수치형 한도는 피하고 "리전별로 다르며 증액 가능" 수준으로 서술하거나 S11만 기준으로 쓴다. 현행 여부를 가리려면 Service Quotas의 Firehose 기본값 조회로 대조(가능 여부는 미확인).

- G-1.1-09 [상충] KDS 온디맨드 모드의 확장 상한이 FAQ와 할당량 페이지에서 다르다.
  - FAQ(S1): 새 스트림은 쓰기 4 MB/s · 4,000 records/s에서 시작해 기본적으로 쓰기 200 MB/s · 200,000 records/s까지 자동 확장된다("automatically scale up to 200 MB/second and 200,000 records per second for writes") https://aws.amazon.com/kinesis/data-streams/faqs/ . 비용 최적화 백서도 200 MB/s(200K records/s)까지 버스트로 적는다 https://docs.aws.amazon.com/whitepapers/latest/cost-modeling-data-lakes/cost-optimization-in-analytics-services.html
  - 할당량 페이지(S2): N. Virginia·Oregon·Ireland는 쓰기 10 GB/s · 읽기 20 GB/s까지, 그 밖의 리전은 쓰기 200 MB/s · 읽기 400 MB/s까지(10 GB/s로 올리려면 지원 티켓) https://docs.aws.amazon.com/streams/latest/dev/service-sizes-and-limits.html . On-demand Advantage 발표문은 10 GB 또는 초당 1,000만 이벤트까지라고 적는다 https://aws.amazon.com/about-aws/whats-new/2025/11/amazon-kinesis-data-streams-ondemand-advantage/
  - 본문 처리: 기본 한도 4/8 MB/s(행 6)와 2배 규칙(행 7)만 기록하고 최대 상한은 쓰지 않았다.
  - 확인 시도: S1 FAQ 청크, S2 전문, 백서·발표문(재확인 10-19).
  - 후속: 문항에서 온디맨드 최대 처리량을 정답 근거로 쓰지 말 것(리전별로 다르고 FAQ와 불일치). 쓰려면 S2 기준 + 리전 조건을 명시.

- G-1.1-10 [상충] KDS 기본 샤드 할당량의 적용 단위가 FAQ는 "per stream", 할당량 페이지는 "per AWS account"로 다르다.
  - FAQ(S1): "default shard quota is 20,000 shards per stream"(N. Virginia·Oregon·Ireland), 그 밖의 리전은 1,000 또는 6,000 per stream https://aws.amazon.com/kinesis/data-streams/faqs/
  - 할당량 페이지(S2): 같은 숫자를 per AWS account로 서술 https://docs.aws.amazon.com/streams/latest/dev/service-sizes-and-limits.html . General Reference는 "Shards per Region"(현재 리전에서 이 계정이 만들 수 있는 샤드 수, 리전별 표: us-east-1 20,000, us-east-2 6,000, … 기타 1,000)로 적는다 https://docs.aws.amazon.com/general/latest/gr/ak.html
  - 본문 처리: 샤드 할당량은 쓰지 않았다.
  - 확인 시도: S1 FAQ 청크, S2 전문, General Reference 청크(재확인 10-19).
  - 후속: 학습문서·문항에서는 "계정·리전 기준"(S2, General Reference)만 사용하고 "스트림당"은 쓰지 말 것(FAQ 표기는 오기로 추정).

- G-1.1-11 [상충] KDS 향상된 팬아웃(EFO) 소비자 한도의 단위·값이 문서마다 어긋난다.
  - (a) 본문 비교 표 E와 행 63은 DynamoDB 블로그(S17)의 표현 "up to 20 simultaneous consumers per shard"(샤드당 20)를 그대로 옮겼으나, 할당량 페이지(S2)와 FAQ(S1)는 데이터 스트림당 등록 소비자 20으로 적는다(행 9).
  - (b) S2 안에서도 본표는 On-demand Advantage 50 / 그 외 20이라 적는데, RegisterStreamConsumer 행은 "You can register up to 20 consumers per data stream."만 적어 ODA 50이 반영돼 있지 않다(갱신 누락으로 추정). ODA 50은 발표문이 확인한다.
  - URL: S17 https://aws.amazon.com/blogs/database/choose-the-right-change-data-capture-strategy-for-your-amazon-dynamodb-applications/ ; S2 https://docs.aws.amazon.com/streams/latest/dev/service-sizes-and-limits.html ; S1 https://aws.amazon.com/kinesis/data-streams/faqs/ ; ODA 50 발표 https://aws.amazon.com/about-aws/whats-new/2025/11/amazon-kinesis-data-streams-enhanced-fan-out-consumers/
  - 확인 시도: S2 전문(재확인 10-19), S1 FAQ 청크, 발표문.
  - 후속: 학습문서·문항에서는 "EFO 등록 소비자: 스트림당 기본 20, On-demand Advantage 50"(행 9)만 쓰고 "샤드당 20"은 쓰지 말 것. 1-1.md 표 E·행 63의 해당 칸에 주석을 달지는 취합 세션이 결정.

- G-1.1-12 [상충] Glue 트리거 유형 수가 문서마다 다르다. Glue 트리거 페이지(S22)는 "There are three types of triggers"로 Scheduled·Conditional·On-demand 셋만 설명한다. 그러나 Glue API 레퍼런스(TriggerUpdate의 EventBatchingCondition: "before EventBridge event trigger fires")에는 EventBridge 이벤트 트리거가 있고, Big Data 블로그는 유형이 "EventBridge event"인 이벤트 기반 트리거를 보여 준다.
  - 본문 처리: 비교 표 C가 scheduled / conditional / on-demand 셋만 나열하고 유형 개수는 단정하지 않았다(행 72·73). 이벤트 트리거 유형은 누락돼 있다.
  - URL: https://docs.aws.amazon.com/glue/latest/dg/about-triggers.html ; https://aws.amazon.com/blogs/big-data/build-a-serverless-event-driven-workflow-with-aws-glue-and-amazon-eventbridge/ ; https://docs.aws.amazon.com/glue/latest/webapi/API_TriggerUpdate.html
  - 확인 시도: S22 전문, 블로그·Glue API 레퍼런스 청크(재확인 10-19). 이벤트 트리거의 사용 조건은 확인하지 못했다.
  - 후속: 학습문서에서 "트리거는 세 가지"로 단정하지 말 것. Skill 1.1.5·1.1.6 서술에 "EventBridge 이벤트 트리거도 존재"를 한 줄 추가할지 취합 세션이 결정(근거 보강 필요).

- G-1.1-13 [상충] Redshift auto-copy(COPY JOB)의 출시 상태가 페이지마다 다르다. Redshift POC 플레이북은 "Autocopy (in preview)"이며 "currently in preview and supported only in provisioned clusters"라고 적는 반면, "Create an S3 event integration…" 페이지는 프로비저닝 클러스터와 Serverless 네임스페이스를 모두 전제로 서술하고 지원 리전 표에서 대부분의 리전을 Available로 표기한다(읽은 범위: 서두·전제 조건 일부·고려 사항·지원 리전 절에서 preview 표기를 찾지 못함). POC 플레이북이 낡은 것으로 추정한다.
  - 본문 처리: Redshift 적재는 COPY 중심으로만 다뤘고 auto-copy는 쓰지 않았다(Skill 1.1.2·1.1.3 관련 후보).
  - URL: https://docs.aws.amazon.com/redshift/latest/dg/proof-of-concept-playbook.html ; https://docs.aws.amazon.com/redshift/latest/dg/loading-data-copy-job.html ; https://docs.aws.amazon.com/redshift/latest/dg/r_COPY-JOB.html ; https://aws.amazon.com/redshift/faqs/
  - 확인 시도: 위 페이지 청크·일부 전문 읽기(재확인 10-19).
  - 후속: auto-copy를 학습문서에 넣는다면 loading-data-copy-job 페이지를 정본으로 삼고 "preview"로 쓰지 말 것. 넣기 전에 현행 GA 공지를 추가 확인.

- G-1.1-14 [개명·종료] Amazon Kinesis Data Firehose → Amazon Data Firehose. 공식 CLI 레퍼런스: "Amazon Data Firehose was previously known as Amazon Kinesis Data Firehose."(S12, #47). Firehose 개발자 가이드(S9~S11)는 신명칭을 쓰지만 일부 AWS 블로그(예: S39)와 시험 가이드의 서비스 목록(컨트롤러 G-0-03)에는 구명칭이 남아 있다. 시험 문항이 어느 명칭을 쓰는지는 확인 불가.
  - URL: https://docs.aws.amazon.com/cli/latest/reference/firehose/index.html
  - 확인 시도: S12 읽음(본문 행 47에 인용).
  - 후속: 학습문서·문항에서 "Amazon Data Firehose(구 Amazon Kinesis Data Firehose)"를 병기.

- G-1.1-15 [개명·종료] Amazon Kinesis Data Analytics → Amazon Managed Service for Apache Flink(개명 발표문: S51, #112), 그리고 Kinesis Data Analytics for SQL 애플리케이션 단종. 단종 계획(S52): 2025-09-01부터 버그 수정 없음, 2025-10-15부터 신규 SQL 애플리케이션 생성 불가(기존 애플리케이션은 중지돼 READY 상태가 되고 재시작 가능), 2026-01-27부터 애플리케이션 삭제. 본문 행 113은 2026-01-27만 기록했고 2025-10-15 단계는 쓰지 않았다. 같은 페이지에서 "READY 상태로 중지"와 "기존 애플리케이션은 정상 실행"이 함께 서술돼 문구가 어긋나 보이나 재시작 가능이라는 점에서 모순은 아니다. 가이드 Skill 문구에는 Kinesis Data Analytics가 등장하지 않는다.
  - URL: https://aws.amazon.com/blogs/aws/announcing-amazon-managed-service-for-apache-flink-renamed-from-amazon-kinesis-data-analytics/ ; https://docs.aws.amazon.com/kinesisanalytics/latest/dev/discontinuation.html
  - 확인 시도: S52 전문 청크(재확인 10-19), S51(본문 인용).
  - 후속: 학습문서에서 구명칭을 병기하고 "SQL 애플리케이션은 단종, 상태 있는 스트림 처리는 Managed Service for Apache Flink"로 정리. 시험이 구명칭으로 출제될 가능성은 확인 불가.

- G-1.1-16 [개명·종료] EventBridge 예약 규칙(scheduled rules)은 legacy이고 EventBridge Scheduler가 권장 수단이다. 공식 문서: "Scheduled rules are a legacy feature of EventBridge."(S36, #92) 및 "We recommend that you use Scheduler to invoke targets on a schedule."(재확인 10-19). EventBridge FAQ는 예약 규칙이 계속 제공된다고 적으므로 종료(end of support)는 아니다. 시험 가이드 Skill 1.1.5는 "Amazon EventBridge"라고만 적어 두 방식 중 어느 쪽을 가리키는지 알 수 없다. 참고: 1.3 노트(dea-gaps-1-3_3-1.md)의 G-1.3-01에 EventBridge 이벤트 버스 명칭 변화가 따로 기록돼 있으나 본 노트에서는 확인하지 않았다.
  - URL: https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-create-rule-schedule.html ; https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-scheduled-rule-pattern.html ; https://aws.amazon.com/eventbridge/faqs/ ; https://docs.aws.amazon.com/scheduler/latest/UserGuide/schedule-types.html
  - 확인 시도: S35·S36(본문 인용), 예약 규칙 패턴 페이지·FAQ 청크.
  - 후속: 학습문서는 두 방식을 함께 설명하되 신규 구축은 Scheduler 권장임을 명시.

- G-1.1-17 [확인필요] 시험 가이드 v1.1(2025-12-12)에 이름이 없는 신규 기능·서비스가 공식 문서에 존재한다. 시험 범위 포함 여부는 확인할 수 없다.
  - Kinesis Data Streams On-demand Advantage(활성화 시 모든 온디맨드 스트림 합산 최소 25MB/s 수집·25MB/s 조회, 낮은 단가) https://aws.amazon.com/about-aws/whats-new/2025/11/amazon-kinesis-data-streams-ondemand-advantage/ — 본문 행 12
  - EFO 소비자 50개(ODA 스트림) https://aws.amazon.com/about-aws/whats-new/2025/11/amazon-kinesis-data-streams-enhanced-fan-out-consumers/ — 본문 행 9
  - KDS 대용량 레코드(최대 10 MiB) https://docs.aws.amazon.com/streams/latest/dev/large-records.html — 본문 행 4는 상한만 기록(G-1.1-18)
  - KDS 스트리밍 테이블(Apache Iceberg on S3 Tables)·범용 S3 버킷 직접 전달 https://aws.amazon.com/about-aws/whats-new/2026/08/kinesis/data-delivery-s3-tables/ , https://aws.amazon.com/about-aws/whats-new/2026/08/kinesis/data-delivery-general-purpose-s3-buckets/ — 본문 행 13은 "온디맨드 모드 필요"만 기록, 동작·한도는 미조사
  - MSK Express 브로커의 스트리밍 테이블(Iceberg on S3 Tables)·범용 S3 전달 https://docs.aws.amazon.com/msk/latest/developerguide/msk-data-delivery-iceberg.html — 본문 미수록
  - Amazon MWAA Serverless https://aws.amazon.com/about-aws/whats-new/2025/11/mwaa-serverless-deployment-apache-airflow-workflows/ — 본문 미수록(G-1.1-20, 1.3 노트 G-1.3-03과 같은 주제)
  - Lambda Managed Instances — G-1.1-19 참조(1.3 노트 G-1.3-04와 같은 주제)
  - 확인 시도: 위 URL을 검색·읽기(재확인 10-19).
  - 후속: 취합 세션이 "신규 기능" 서술의 분량을 결정. 문항 정답 근거로 쓰기 전에 사람 검수.

- G-1.1-18 [확인필요] KDS 레코드 크기: 본문 행 4와 개념 절은 FAQ(S1)의 상한 "10 MiB"만 적었으나, 대용량 레코드 페이지는 스트림의 기본 최대 레코드 크기가 1 MiB이고 10 MiB까지 쓰려면 스트림의 최대 레코드 크기 설정(UpdateMaxRecordSize, 1~10 MiB)을 올려야 한다고 설명한다. 샤드 처리량 한도(쓰기 1 MB/s · 읽기 2 MB/s)는 그대로이며 대용량 레코드는 간헐적 사용을 전제로 한다(G-1.1-07). FAQ(S1)와 할당량 페이지(S2)는 상한 10 MiB만 적는다.
  - 본문 보강 제안(1-1.md 행 4, 개념 절 "쓰기 경로" 불릿): "기본 최대 레코드 크기 1 MiB, 설정 시 최대 10 MiB". 제안 인용문(원문 그대로, 재확인 10-19): "default maximum record size for existing, and newly created streams is set to 1 MiB" / "Individual shard throughput limit of 1 MB/s for writes, and 2 MB/s for reads" — 출처 https://docs.aws.amazon.com/streams/latest/dev/large-records.html (1-1.md 출처 목록에 새 항목으로 추가해야 함).
  - URL: https://docs.aws.amazon.com/streams/latest/dev/large-records.html ; https://docs.aws.amazon.com/kinesis/latest/APIReference/API_UpdateMaxRecordSize.html ; https://aws.amazon.com/kinesis/data-streams/faqs/
  - 확인 시도: 대용량 레코드 페이지, UpdateMaxRecordSize API 레퍼런스, FAQ 청크.
  - 후속: 취합 세션이 1-1.md 보강 여부 결정. 보강 전까지 문항에서 레코드 최대 크기를 물을 때는 "기본 1 MiB, 설정 시 최대 10 MiB"로 서술.

- G-1.1-19 [확인필요] Lambda 제한 시간: 본문 행 89와 개념 절은 "900초(15분)"만 기록했다. 현행 할당량 페이지(S33)는 같은 칸에 Lambda Managed Instances를 쓰는 함수의 비동기·이벤트 소스 매핑 호출(Amazon MQ·DocumentDB 제외)은 최대 5,400초(90분)까지 허용된다고 덧붙인다. 이벤트 소스 매핑은 Skill 1.1.7(Kinesis → Lambda)과 직결된다.
  - 본문 보강 제안(행 89, 기존 출처 S33 사용): 표준(기본) 함수는 900초, Managed Instances의 비동기·이벤트 소스 매핑 호출은 최대 5,400초. 제안 인용문: "support a maximum allowed value of 5,400 seconds (90 minutes)"
  - 관련: 1.3 노트 G-1.3-04(dea-gaps-1-3_3-1.md)와 같은 주제.
  - URL: https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-limits.html ; https://docs.aws.amazon.com/lambda/latest/dg/durable-invoking-esm.html
  - 확인 시도: S33 전문 청크, durable-invoking-esm 청크(재확인 10-19).
  - 후속: 문항·해설은 "일반(기본 용량) Lambda 함수는 최대 15분"으로 한정하고 15분이 절대 상한이라고 단정하지 말 것.

- G-1.1-20 [확인필요] Skill 1.1.5 "Apache Airflow" 스케줄링 근거가 얇다. 본문 행 93은 AWS 블로그(S37)의 "schedule_interval … cron syntax" 한 줄뿐이며 MWAA 개발자 가이드의 스케줄링 설명은 수집하지 못했다. 또 MWAA Serverless는 DAG의 schedule_interval이 아니라 워크플로의 ScheduleConfiguration(cron 표현식)을 쓰고 EventBridge Scheduler와 통합되며 시간대를 지원한다고 서술한다(본문 미수록). MWAA가 지원하는 Airflow 버전별 DAG 스케줄 인자 이름 차이는 확인하지 못했다. 관련: 1.3 노트 G-1.3-03(MWAA Serverless), G-1.3-09(지원 Airflow 버전).
  - URL: https://aws.amazon.com/blogs/big-data/choosing-the-right-workflow-orchestration-service-for-your-use-case-amazon-mwaa-and-aws-step-functions/ ; https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/aws-properties-mwaaserverless-workflow-scheduleconfiguration.html
  - 확인 시도: S37 청크, MWAA Serverless ScheduleConfiguration 청크(재확인 10-19).
  - 후속: 문항은 "크론 기반 DAG 스케줄" 개념 수준으로 한정. 필요하면 MWAA 개발자 가이드(스케줄링·Airflow 버전)를 추가 조사.

- G-1.1-21 [확인필요] 오래된 블로그에서 가져온 수치·권장치가 현행 문서와 일치하는지 확인하지 못했다.
  - S39(S3 → EventBridge 출시 블로그, 행 98·비교 표 D): "최대 18개 AWS 서비스" — 같은 문장에 구명칭 "Kinesis Firehose"가 있어 출시 시점 문구로 보이며(추정) 현행 EventBridge 대상 수는 확인하지 않았다. https://aws.amazon.com/blogs/aws/new-use-amazon-s3-event-notifications-with-amazon-eventbridge/
  - S29(Redshift → 데이터 레이크 블로그, 행 82): UNLOAD 권장 파일 크기 128~512 MB — 검색된 현행 UNLOAD 레퍼런스 구간에서는 이 권장치를 찾지 못했다. 레퍼런스는 MAXFILESIZE 미지정 시 기본 최대 6.2 GB, 지정 범위 5 MB~6.2 GB, Parquet은 32 MB 행 그룹 기준이라고 서술한다. https://docs.aws.amazon.com/redshift/latest/dg/r_UNLOAD.html
  - S17(DynamoDB CDC 블로그)의 EFO "샤드당 20" 표현은 G-1.1-11 참조.
  - 확인 시도: S39 앞부분 전문, UNLOAD 레퍼런스 청크(재확인 10-19). UNLOAD 레퍼런스는 전체를 읽지 않았다.
  - 후속: 문항에서 이 수치들을 정답 근거로 쓰지 말고 정성적 설명에만 쓰거나, 공식 개발자 가이드에서 재확인한 뒤 사용.

- G-1.1-22 [확인필요] MSK 기본 보존 "7일"(본문 행 80)은 Redshift 문서(S27)의 문구에만 근거한다. MSK Serverless는 MSK 문서에서 직접 확인됐다(재확인 10-19): 토픽 retention.ms 기본 7일, retention.bytes 기본 250 GiB, 최대 무제한. MSK Provisioned의 기본 보존은 MSK 문서에서 확인하지 못했다(기본 구성 페이지는 표에 없는 속성은 Apache Kafka 버전의 기본값을 따른다고만 적음). 같은 날 MSK Serverless 처리량(쓰기 200 / 읽기 400 MBps, 파티션당 5 / 10 MBps)을 FAQ(S14, 행 55)와 할당량 페이지에서 대조해 일치함을 확인했다(상충 없음).
  - URL: https://docs.aws.amazon.com/msk/latest/developerguide/serverless-config.html ; https://docs.aws.amazon.com/msk/latest/developerguide/msk-default-configuration.html ; https://docs.aws.amazon.com/msk/latest/developerguide/limits.html ; https://docs.aws.amazon.com/redshift/latest/dg/materialized-view-streaming-ingestion.html
  - 확인 시도: 위 MSK 페이지 청크.
  - 후속: 문항에서 "MSK 기본 보존 7일"을 쓰려면 Serverless로 한정하거나, Provisioned의 Kafka 기본값(log.retention.*)을 별도 확인.

- G-1.1-23 [확인필요] 재확인 10-19에 공식 페이지에서 확인했지만 본문(사실·숫자 표)에 넣지 않은 수치. 문항에서 쓰려면 사실 행으로 승격하고 인용을 붙여야 한다.
  - DMS → S3 대상 CDC 파일(Skill 1.1.3 후보): cdcMaxBatchInterval 기본 60초, cdcMinFileSize 기본 32000 KB(둘 중 먼저 충족되는 쪽에서 파일 기록), maxFileSize 기본 1 GB, WriteBufferSize 기본 1000 KB https://repost.aws/knowledge-center/dms-cdc-files-target-s3
  - Lambda 이벤트 소스 매핑(Skill 1.1.7): BatchSize 기본 100(최대 10,000), MaximumBatchingWindowInSeconds 기본 0 https://docs.aws.amazon.com/lambda/latest/dg/services-kinesis-parameters.html ; 배치 윈도 범위 0~300초는 CLI 레퍼런스에만 나오며 개발자 가이드(S4)의 "최대 5분"과 일치 https://docs.aws.amazon.com/cli/latest/reference/lambda/create-event-source-mapping.html
  - NAT 게이트웨이(Skill 1.1.8): 퍼블릭 NAT 게이트웨이당 Elastic IP 기본 2개, 8개까지 증액 요청 가능(본문 행 101의 기본값 2와 일치) https://docs.aws.amazon.com/vpc/latest/userguide/amazon-vpc-limits.html
  - Redshift UNLOAD(Skill 1.1.3): 기본 최대 파일 크기 6.2 GB https://docs.aws.amazon.com/redshift/latest/dg/r_UNLOAD.html (G-1.1-21 참조)
  - RDS Data API 응답 크기 한도 1 MiB(G-1.1-02 참조)
  - 확인 시도: 위 페이지 청크(재확인 10-19).
  - 후속: 취합 세션이 필요한 것만 사실 행으로 추가.

- G-1.1-24 [확인필요] 본문에서 다루지 못한(조사하지 않은) 하위 주제. 문항이 이 부분을 물으면 근거가 없다.
  - Skill 1.1.11: Kafka/MSK 소비자 오프셋 되돌리기(재처리) 절차, DMS 태스크의 CDC 재시작·재개(체크포인트·시작 위치) — 공식 절차 문서를 수집하지 못했다(MSK 재생은 블로그 S15의 "오프셋 순차 읽기" 수준).
  - Skill 1.1.2: EMR을 배치 소스로 쓰는 방법은 S3DistCp 한 건뿐이고, Lambda를 배치 소스로 쓰는 패턴은 미조사(G-1.1-04).
  - Skill 1.1.1·1.1.7: KCL/KPL/Kinesis Agent의 구성 세부, DynamoDB Streams를 Lambda 이벤트 소스로 읽을 때의 설정은 미조사. Firehose 목적지 전체 목록의 최신화는 확인하지 않았다(본문은 "등"으로 표기).
  - Skill 1.1.3: 서비스별 구성 옵션 중 본문에 없는 항목은 미조사(G-1.1-05).
  - URL(현재 본문이 쓰는 근거의 수준): 가이드 https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain1.html ; MSK 재생(블로그 S15) https://aws.amazon.com/blogs/big-data/amazon-msk-service-101-how-many-partitions-does-an-amazon-msk-topic-need/ ; EMR S3DistCp(S34) https://docs.aws.amazon.com/emr/latest/ReleaseGuide/UsingEMR_s3distcp.html ; DMS CDC(S18) https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Task.CDC.html
  - 확인 시도: 본문 작성 시 검색 범위를 Skill 문구와 1차 비교 대상(KDS·Firehose·MSK·DynamoDB Streams·DMS·Glue·Redshift·AppFlow·EventBridge·S3 이벤트)에 한정했다.
  - 후속: 취합 세션이 문서 범위를 정한 뒤 필요한 항목만 추가 조사.

- G-1.1-25 [수정제안] `flutter_app/assets/exam_guides/DEA-C01.json`의 Task 1.1 Skill 12개를 공식 KO 가이드 문구(1-1.md 헤더 표 — 컨트롤러가 2026-10-19에 라이브 대조했다고 G-0-05에 기록)와 문자열 비교한 결과, 1.1.2~1.1.12는 완전히 일치하고 1.1.1 한 건만 다르다. JSON은 "AWS Database Migration Service(AWS DMS)", 공식 KO는 "AWS DMS"이며 공식 문장 끝에는 마침표가 있다(의미 동일). 컨트롤러 G-0-01(8건 중 1건)과 같은 항목이다. `knowledge: []`는 v1.1 구조와 부합한다(컨트롤러 G-0-02).
  - URL: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain1.html
  - 확인 시도: 읽기 전용 스크립트로 JSON(17~35행의 Task 1.1 객체)과 1-1.md 헤더의 KO 열을 항목별 비교(2026-10-19).
  - 후속: 수정은 필수가 아니다(기능 영향 없음, 풀네임이 학습용으로 유용). 취합 세션이 G-0-01과 함께 결정.

- G-1.1-26 [수정제안] 공식 한국어 번역이 영어 원문의 뜻을 흐리는 Skill이 있다. 1.1.4 "Consume data APIs" → "데이터 API 사용"(소비하는 쪽임이 덜 드러남), 1.1.11 "Describe replayability" → "반복 재생 가능성 설명"(데이터 재처리·재수집 가능성을 뜻하는 용어가 미디어 재생처럼 읽힘), 1.1.12 "Define stateful and stateless data transactions" → "스테이트풀 및 스테이트리스 데이터 트랜잭션 정의". 레포 JSON은 공식 번역과 일치하므로 JSON 수정은 권하지 않는다(판단은 번역 어감에 대한 것이며 공식 근거는 없음). 학습문서에서 영문 원문과 풀어 쓴 설명(재처리·리플레이 가능성 등)을 병기하고, 앱 UI에서 Skill 원문을 보여 줄 계획이라면 영문 원문 필드 추가를 취합 세션이 검토.
  - URL: EN https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain1.html ; KO https://docs.aws.amazon.com/ko_kr/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain1.html
  - 확인 시도: 1-1.md 헤더의 EN/KO 대조표와 JSON 비교(G-1.1-25와 같은 스크립트).
  - 후속: 취합 세션 결정.

### Task 1.2 — Transform and process data (데이터 변환 및 처리)

- G-1.2-01 [개명·종료] AWS Glue for Ray가 2026-04-30부터 신규 고객에게 닫혔다(유지보수 모드: 기존 고객은 계속 사용, 보안·가용성 개선 외 신규 기능 없음, 대안으로 EKS + KubeRay 안내). 본문(Skill 1.2.5 소제목, 사실표 #34, S18)에 반영했다. 시험 가이드 Skill 1.2.5는 Glue 작업 유형을 열거하지 않으므로 학습문서에서는 "레거시/신규 중단"으로만 다루길 제안한다. Ray 전용 워커 Z.2X는 CreateJob API 레퍼런스에만 남아 있다(G-1.2-03).
  - 확인 시도: https://docs.aws.amazon.com/glue/latest/dg/awsglue-ray-jobs-availability-change.html (S18, 2026-10-17). AWS Service Availability Updates(2026-03-31 게시) https://aws.amazon.com/about-aws/whats-new/2026/03/aws-service-availability/ — "no longer be accessible to new customers starting April 30, 2026" 목록에 "AWS Glue - Ray Jobs Feature" (재확인 2026-10-19).
  - 후속: 취합 세션이 학습문서에 "신규 고객 중단" 주석으로 넣을지 결정.

- G-1.2-02 [개명·종료] Glue 버전 현황: 최신은 Glue 6.0(Spark 4.1.1, Python 3.13, Scala 2.13.17, Java 17), 버전 미지정 시 5.1(CreateJob), Glue 1.0·2.0은 2026-04-01 수명 종료 — 본문 반영(S17, S25, 사실표 #31–33). 2026-08-21 What's New는 "AWS Glue 6.0 is now generally available, delivering a 30% price reduction …"로 가격 인하를 알리는데, 가격 변경은 본문에 쓰지 않았다(시험 범위 밖일 가능성, 추정). 시험 문항은 구버전(3.0/4.0) 기준일 수 있으므로 학습문서는 "현행"과 "기출 기준"을 구분해 적을 필요가 있다.
  - 확인 시도: https://docs.aws.amazon.com/glue/latest/dg/release-notes.html (S17), https://docs.aws.amazon.com/glue/latest/webapi/API_CreateJob.html (S25) (이상 2026-10-17). https://aws.amazon.com/about-aws/whats-new/2026/08/aws-glue-6-0-price-reduction-iceberg-v3/ (Posted on: Aug 21, 2026, 재확인 2026-10-19).
  - 후속: 요금표 https://aws.amazon.com/glue/pricing/ 는 미조회 — 가격 수치를 문항에 쓰려면 확인 필요.

- G-1.2-03 [상충] Glue 워커 타입 목록이 페이지마다 다르다. worker-types 페이지(S24)는 G.1X(1 DPU·4 vCPU·16 GB, 디스크 94 GB), G.2X, G.4X, G.8X, G.12X, G.16X와 메모리 최적화 R.1X/R.2X/R.4X/R.8X를 나열하고 G.025X·Z.2X는 언급하지 않는다. CreateJob API 레퍼런스(S25)의 WorkerType 유효값은 "Standard | G.1X | G.2X | G.025X | G.4X | G.8X | Z.2X"로 G.12X·G.16X·R.*가 없고, G.025X(0.25 DPU, 저용량 스트리밍용)와 Z.2X(Ray용)가 있다. 오래된 블로그 표는 G.1X 디스크를 64 GB로 적어 worker-types 페이지(94 GB)와도 다르다. 본문은 worker-types를 기준으로 G.1X/G.2X·R 워커·시작 지연을 쓰고, G.025X는 S25에서만 가져와 엔진 표(Streaming 행)에 언급했다.
  - 확인 시도: https://docs.aws.amazon.com/glue/latest/dg/worker-types.html (S24), https://docs.aws.amazon.com/glue/latest/webapi/API_CreateJob.html (S25), 구형 블로그 https://aws.amazon.com/blogs/big-data/automate-alerting-and-reporting-for-aws-glue-job-resource-usage/ (표의 G.1X 행 디스크 64) (이상 2026-10-17).
  - 후속: 시험 범위의 워커 타입은 가이드에 없다 → 학습문서는 G.1X/G.2X(대부분)와 R(OOM) 위주로, 나머지는 "존재" 수준으로. API 레퍼런스가 갱신 지연인지(추정)는 확인 불가.

- G-1.2-04 [상충] Zero-ETL 지원 범위(소스·타깃)가 페이지마다 다르다. (a) Redshift 관리 가이드(S12): 소스는 Aurora MySQL/PostgreSQL, DynamoDB, RDS for MySQL/Oracle/PostgreSQL, Oracle Database@AWS, 애플리케이션(Salesforce, Salesforce Marketing Cloud Account Engagement, SAP, ServiceNow, Instagram ads, Meta ads, Zendesk), 자체 관리 MySQL/PostgreSQL/SQL Server/Oracle이고 대상은 Redshift 데이터 웨어하우스다. (b) Glue 개발자 가이드: 소스는 DynamoDB, Oracle at AWS, Facebook Ads, Instagram Ads, Salesforce, Salesforce Marketing Cloud Account Engagement, SAP OData, ServiceNow, Zendesk, Zoho CRM, 자체 관리 Oracle/SQL Server/MySQL/PostgreSQL이고, 대상은 범용 S3 버킷·S3 Tables·Redshift Managed Storage(모두 SageMaker lakehouse 경유)와 Redshift 웨어하우스이며 "For self-managed database sources, you can replicate data only to an Amazon Redshift data warehouse. Other targets are not supported."라고 쓴다. (c) Aurora FAQ는 대상을 Amazon Redshift와 Amazon SageMaker Lakehouse 두 가지로 설명한다. "Meta ads"(Redshift 페이지) ↔ "Facebook Ads"(Glue 페이지), Zoho CRM·SAP OData 표기 차이도 있다. 본문(S12, S13)은 Redshift 대상만 반영했다.
  - 확인 시도: https://docs.aws.amazon.com/redshift/latest/mgmt/zero-etl-using.html (S12, 2026-10-17); https://docs.aws.amazon.com/glue/latest/dg/zero-etl-using.html (재확인 2026-10-19); https://docs.aws.amazon.com/rds/latest/auroraextendedcontent/aurora-faq-developer-tools.html 와 https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/zero-etl.html (2026-10-17 검색 발췌).
  - 후속: 학습문서는 공통 개념(복제 자동화, 기본 키, 지연)과 "소스·타깃은 계속 확장 중" 표기에 집중하고 전체 목록은 암기 대상으로 삼지 않는 것을 제안한다.

- G-1.2-05 [개명·종료] Athena Federated Query 관련 공지 2건이 본문에 불완전하다. (1) S10은 "Starting April 21, 2026, certain newly created connectors are automatically registered as Glue Data Catalogs and do not use a Lambda function in your AWS account"라고만 하며 어떤 커넥터인지 밝히지 않는다. 이를 나열하는 'Connector type support by data source' 표는 확인하지 못했다(본문 사실표 #12는 문장 그대로만 반영). (2) 'Available data source connectors' 페이지에는 "The AthenaJdbcConnector (latest version 2022.4.1) has been deprecated. Instead, use a database-specific connector like those for MySQL, Redshift, or PostgreSQL." 공지(deprecated)가 있으나 본문에 반영하지 않았다.
  - 확인 시도: https://docs.aws.amazon.com/athena/latest/ug/federated-queries.html (S10, 2026-10-17); https://docs.aws.amazon.com/athena/latest/ug/connectors-available.html (재확인 2026-10-19, 커넥터 목록 아래 Note).
  - 후속: 'Connector type support by data source' 페이지를 찾아 대상 커넥터를 확인한다(URL 미조회).

- G-1.2-06 [개명·종료] Redshift Python UDF 지원 중단: 본문(사실표 #35, S51)은 "2026-06-30 이후 지원 중단(단계적 적용)"까지만 반영했다. 페이지 배너는 2025-06-30 블로그에 마이그레이션 옵션이 있다고 안내하나 그 URL을 얻지 못해 읽지 못했다. 오늘(2026-10-19)은 이미 날짜가 지났으므로 단계적 적용의 현재 상태와 대체 수단은 미확인이다.
  - 확인 시도: https://docs.aws.amazon.com/redshift/latest/dg/query-super.html (S51; 배너 "Amazon Redshift will no longer support the use of Python UDFs after June 30, 2026. We will start enforcing it in phases.", 2026-10-17).
  - 후속: Redshift를 다루는 Task 노트(예: 3.2) 담당이 배너가 가리키는 블로그와 대체 수단을 확인한다.

- G-1.2-07 [개명·종료] 시험 범위(in-scope) 서비스의 maintenance 이동 — Task 1.2 밖의 영향. AWS Service Availability Updates(2026-06-30 게시)는 Amazon Kendra, Amazon Q Business, Amazon Bedrock Agents(→ Amazon Bedrock Agents Classic) 등이 "no longer be accessible to new customers starting July 30, 2026"인 maintenance로 이동한다고 알린다. DEA-C01 v1.1 in-scope 목록에는 Amazon Bedrock·Amazon Kendra(Machine Learning)와 Amazon Q(Developer Tools)가 있고 개정 이력 페이지가 이들을 v1.1에서 추가된 서비스로 적는다. in-scope의 "Amazon Q"가 Q Business를 가리키는지는 불명이다. 2025-10 공지(maintenance 시작 2025-11-07)에도 in-scope 목록에 있는 AWS Application Discovery Service가 포함돼 있다(10-17 검색 발췌, 10-19 미재조회). 시험 가이드가 v1.1 이후 갱신됐다는 공지는 확인하지 못했다.
  - 확인 시도: https://aws.amazon.com/about-aws/whats-new/2026/06/aws-service-availability/ (재확인 2026-10-19); https://aws.amazon.com/about-aws/whats-new/2025/10/aws-service-availability/ (2026-10-17 검색 발췌); https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-in-scope-services.html 와 https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-revisions.html (재확인 2026-10-19).
  - 후속: 컨트롤러가 00-overview §6.2(명칭 불일치·현행화 메모)에 반영할지 결정한다.

- G-1.2-08 [확인필요] Athena·Glue가 Amazon Bedrock을 직접(네이티브로) 호출하는 기능은 공식 문서에서 확인하지 못했다(본문 참조 ID). 본문은 Skill 1.2.10의 ETL 통합 지점으로 Lambda(Step Functions 통합 이전 방식), Step Functions 최적화 통합, Redshift ML 외부 모델, Bedrock Data Automation만 반영했다. 가장 가까운 공식 근거: Athena는 사용자 정의 함수(UDF)와 SageMaker AI 머신러닝 모델 호출만 릴리스 노트(2021-04-05)에서 확인되고(해당 발췌는 UDF가 Lambda 기반이라고 적지 않는다), Glue에는 "Amazon Q data integration in AWS Glue"(Chat, Data integration code generation, Troubleshoot)가 있으나 이는 LLM이 Glue 코드·진단을 돕는 기능이지 Glue 잡이 LLM을 호출하는 통합이 아니다. 확인한 범위에서 Athena와 Bedrock의 관계는 LLM이 Athena용 SQL을 생성하는 블로그 예제뿐이다. 문항에서 "Athena UDF가 Bedrock을 호출한다"는 식의 선택지를 정답으로 쓰지 말 것.
  - 확인 시도: 검색 "AWS Glue ETL job call Amazon Bedrock …", "Amazon Athena generative AI Bedrock … UDF" (2026-10-17); https://docs.aws.amazon.com/athena/latest/ug/release-notes.html ; https://docs.aws.amazon.com/glue/latest/dg/q.html ; https://aws.amazon.com/blogs/big-data/enriching-metadata-for-accurate-text-to-sql-generation-for-amazon-athena/ .
  - 후속: 취합 세션이 Skill 1.2.10 학습문서에 "Athena/Glue 네이티브 호출은 확인되지 않음"을 명시하거나 별도 리서치를 배정한다.

- G-1.2-09 [불확실] Bedrock 배치 추론의 최소 레코드 수: 사용자 가이드의 코드 예제는 JSONL이 "at least the minimum number of records"를 포함해야 한다며 모델별 쿼터("Minimum number of records per batch inference job for {Model}")를 가리키는 반면, AWS Compute 블로그는 "needing a minimum of 100 inference requests"라고 설명한다. 모델별로 다를 수 있어 본문에는 숫자를 쓰지 않았다.
  - 확인 시도: https://docs.aws.amazon.com/bedrock/latest/userguide/batch-inference-example.html (재확인 2026-10-19); https://aws.amazon.com/blogs/compute/orchestrating-large-scale-document-processing-with-aws-step-functions-and-amazon-bedrock-batch-inference/ (2026-10-17 검색 발췌).
  - 후속: AWS General Reference의 Bedrock 쿼터 표에서 모델별 값을 확인한다.

- G-1.2-10 [불확실] Skill 1.2.1 "컨테이너 사용 최적화"의 출제 범위(본문 참조 ID). 공식 가이드는 한 줄(예: Amazon EKS, Amazon ECS)만 제시한다. 본문은 일반 ECS/Fargate/EKS/EMR on EKS 문서에서 크기·시작 시간·Spot·스케일링 레버만 정리했고, 데이터 엔지니어링 맥락(이미지 크기, 사이드카, 노드 오토스케일링 등)의 출제 폭은 근거가 없다. 본문에 쓰지 않은 확인 사실: 신규 컴퓨트 옵션 Amazon ECS Managed Instances(AWS Batch 가이드는 GPU 필요, 32 vCPU/244 GiB 초과, 특정 인스턴스 유형 필요 시 선택하고 Fargate는 "up to 32 vCPUs, 244 GiB memory" 한도라고 안내 — 본문 사실표 #1의 Fargate 최대 크기와 일치), EKS Fargate의 제약(EKS 사용자 가이드: "Daemonsets aren't supported on Fargate", "GPUs aren't currently available on Fargate"), EKS 노드 오토스케일링(Karpenter, Cluster Autoscaler — 고객 사례 블로그의 서술이며 가이드 문서 근거는 확인하지 못함).
  - 확인 시도: https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain1.html (Skill 1.2.1 원문, 2026-10-17); https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ManagedInstances.html 와 https://docs.aws.amazon.com/batch/latest/userguide/when-to-use-ecs-managed-instances.html (2026-10-17 검색 발췌); https://docs.aws.amazon.com/eks/latest/userguide/fargate.html (Daemonset·GPU 제약); https://docs.aws.amazon.com/eks/latest/best-practices/cost-opt-compute.html (Fargate에서 DaemonSet 미지원, 사이드카로 전환); https://aws.amazon.com/blogs/containers/life360s-journey-to-a-multi-cluster-amazon-eks-architecture-to-improve-resiliency/ (Karpenter·Cluster Autoscaler 서술) (이상 2026-10-17 검색 발췌).
  - 후속: 공식 연습 문제(Skill Builder, 로그인 필요)에서 컨테이너 출제 사례를 확인할 수 있으면 범위를 확정한다.

- G-1.2-11 [불확실] Skill 1.2.9 "볼륨·속도·다양성 정의"의 공식 근거가 얇다. 3V를 직접 정의하는 공식 페이지는 What is big data?(S49)와 블로그·가이던스의 짧은 언급뿐이고(블로그는 "The first dimensions to consider are the venerable three Vs of big data: Velocity, Variety, and Volume", 자동차 데이터 플랫폼 가이던스는 Veracity·Value까지 5V로 나열), 백서·Well-Architected에서 3V를 정의하고 서비스 선택과 연결한 표는 찾지 못했다. 본문 "서비스 선택에 미치는 영향" 목록은 각 서비스 문서의 사실을 이어 붙인 정리이며 공식 매핑표가 아니다. Skill 문구는 3V와 정형/비정형 예시만 명시한다.
  - 확인 시도: https://aws.amazon.com/what-is/big-data/ (S49), https://aws.amazon.com/blogs/startups/picking-the-right-data-store-for-your-workload/ , https://docs.aws.amazon.com/guidance/latest/automotive-data-platform-on-aws/data-mesh-strategy.html (이상 2026-10-17).
  - 후속: 학습문서는 정의 3줄 + 정형/반정형/비정형 비교로 짧게 쓰고, 서비스 매핑은 "정리"임을 밝힌다.

- G-1.2-12 [불확실] Skill 1.2.10 "데이터 처리를 위한 LLM 통합"이 무엇을 묻는지 공식 근거로 확정할 수 없다. 가이드 Domain 1 페이지는 "Skill 1.2.10: Integrate large language models (LLMs) for data processing." 한 줄뿐이고, 개정 이력 페이지는 같은 Skill을 "Integrate Large Language Models (LLM) for data processing."(대소문자·복수형만 다름)로 신규 Skill에 적는다. 모델 호출 방식·배치·쿼터·ETL 통합 지점 중 무엇을 묻는지, Knowledge Bases(벡터화는 별도 Skill 2.4.6)·Guardrails(유해 콘텐츠·PII 차단)·Agents·Amazon Q/Kendra(v1.1 in-scope에 추가됐으나 G-1.2-07 참고)가 포함되는지는 알 수 없다. 본문은 Converse/InvokeModel, 배치 추론, 쿼터·쓰로틀링, 비용, Step Functions, Redshift ML, Bedrock Data Automation을 정리했다. 확인했으나 본문에 쓰지 않은 항목: 교차 리전 추론(런타임 쿼터 표에 "Cross-Region InvokeModel tokens per minute" 행), 프롬프트 캐싱과 지연 최적화 추론, 추론 서비스 티어(Reserved/Priority/Standard/Flex, 요약), Amazon Q data integration in AWS Glue.
  - 확인 시도: https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain1.html (2026-10-17); https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-revisions.html ("New skills added" 절, 그리고 "Services added to the in-scope list" 절의 항목 Amazon Aurora, Amazon Q, Amazon Bedrock, Amazon Kendra, AWS Data Exchange, Amazon S3 Tables, 재확인 2026-10-19); https://docs.aws.amazon.com/bedrock/latest/userguide/quotas-runtime.html (S61); https://docs.aws.amazon.com/prescriptive-guidance/latest/gen-ai-inference-architecture-and-best-practices-on-aws/amazon-bedrock.html ; https://aws.amazon.com/blogs/publicsector/how-to-estimate-amazon-bedrock-costs-for-public-sector-applications/ ; https://docs.aws.amazon.com/glue/latest/dg/q.html (이상 2026-10-17 검색 발췌).
  - 후속: Task 2.4(벡터화)·Task 4.x(거버넌스·PII) 노트와 경계를 맞춘 뒤 1.2.10에 어디까지 넣을지 취합 세션이 결정한다.

- G-1.2-13 [확인필요] Spark 표준 JDBC 병렬 읽기 옵션(partitionColumn, lowerBound, upperBound, numPartitions)은 본문에 쓰지 않았다. 본문은 Glue 전용 hashfield/hashexpression/hashpartitions(S6)만 반영했다. Glue API 레퍼런스의 JDBCConnectorOptions에는 PartitionColumn("The name of an integer column that is used for partitioning", lowerBound·upperBound·numPartitions와 함께일 때만 동작, "works the same way as in the Spark SQL JDBC reader")이 있으나 개발자 가이드 서술형 문서에서는 확인하지 못했다.
  - 확인 시도: https://docs.aws.amazon.com/glue/latest/dg/aws-glue-api-visual-job-api.html (2026-10-17 검색 발췌); https://docs.aws.amazon.com/glue/latest/dg/aws-glue-programming-etl-connect-jdbc-home.html (JDBC 연결 페이지, 커스텀 드라이버 예제 확인).
  - 후속: Glue "JDBC connection option reference" 절에서 옵션 정의를 확인한 뒤 필요하면 사실표에 추가한다.

- G-1.2-14 [확인필요] Lambda 최대 실행 시간: 본문은 백서(S20)의 "Each Lambda function must complete within 900 seconds"를 쓴다. Lambda 문서는 표준 함수의 최대 900초(15분)에 더해, Lambda Managed Instances 사용 함수의 비동기 호출과 이벤트 소스 매핑 호출(Amazon MQ·DocumentDB 제외)은 최대 5,400초(90분)라고 명시한다. 시험이 표준 15분을 전제할 가능성이 크지만 문항에는 "표준 Lambda 함수"라는 단서를 붙이는 편이 안전하다. Task 1.4(Lambda 구성) 노트와 값이 일치하는지 교차 확인이 필요하다.
  - 확인 시도: https://docs.aws.amazon.com/lambda/latest/dg/configuration-timeout.html (재확인 2026-10-19); https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-limits.html (2026-10-17 검색 발췌).
  - 후속: 컨트롤러의 파일 간 값 일치 grep(Lambda 15분/메모리)에 포함한다.
  - 근거 URL 보강(컨트롤러, 2026-10-19 열람·인용문 원문 확인): https://docs.aws.amazon.com/whitepapers/latest/big-data-analytics-options/aws-lambda.html ("Each Lambda function must complete within 900 seconds." 확인)

- G-1.2-15 [상충] API Gateway 통합 타임아웃 서술이 문서마다 다르다. 본문 사실표 #74(S46, 콘솔 도움말)는 기본 29초, 50~29,000 ms 설정, 쿼터 상향 시 29초 초과 가능(Regional·private REST API만)이다. AWS CDK API 레퍼런스도 같은 취지(기본 29초, regional·private REST만 상향, 계정 스로틀 쿼터 감소가 필요할 수 있음)로 쓴다. 반면 Solutions 가이드(Dynamic Image Transformation for Amazon CloudFront)의 "Amazon API Gateway quotas"는 "API Gateway sets the maximum integration timeout at 30 seconds for all integration types, including Lambda."라고 써서 29초·상향 가능과 어긋난다(오래된 서술로 추정). 개발자 가이드 "Amazon API Gateway quotas"(limits.html)는 2026-10-19 기준 계정 단위 스로틀과 관리 API 쿼터만 담고 있어 통합 타임아웃 행을 직접 확인하지 못했다.
  - 확인 시도: https://docs.aws.amazon.com/help-panel/apigateway/latest/console/rest-timeout.html (S46), https://docs.aws.amazon.com/cdk/api/v2/docs/aws-cdk-lib.aws_apigateway.IntegrationOptions.html , https://docs.aws.amazon.com/solutions/latest/dynamic-image-transformation-for-amazon-cloudfront/amazon-api-gateway-quotas.html , https://docs.aws.amazon.com/apigateway/latest/developerguide/limits.html (이상 재확인 2026-10-19).
  - 후속: REST API 쿼터를 담은 정식 페이지에서 통합 타임아웃 행을 확인한다. 문항에서는 "기본 29초(조정 가능)"로 표기한다.

- G-1.2-16 [확인필요] Zero-ETL의 DB 소스 복제 지연은 본문에 쓰지 않았다(본문은 SaaS 애플리케이션 소스의 최소 지연 1시간(S13)만 수치로 사용). Aurora zero-ETL 문서는 "available in Amazon Redshift or an Amazon SageMaker AI lakehouse in near real-time"이라 하고 Database 블로그는 "Within seconds of transactional data being written into Aurora …"라고 하지만 보증 수치(SLA)는 확인하지 못했다. DynamoDB·RDS 소스의 지연 수치도 미확인이다.
  - 확인 시도: https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/zero-etl.html ; https://aws.amazon.com/blogs/database/binary-logging-optimizations-in-amazon-aurora-mysql-version-3/ (이상 2026-10-17 검색 발췌).
  - 후속: 학습문서는 "DB 소스 근실시간 vs 앱 소스 최소 1시간" 대비만 서술하고 초 단위 수치는 쓰지 않는다.

- G-1.2-17 [상충] EMR Graviton2 비용 절감률: 비용 모델링 백서(S27)는 "additional cost savings of up to 30% and improved performance of up to 15%"(Spark 런타임, 이전 세대 대비)이고 AWS Big Data 블로그 제목도 "up to 30% lower cost and up to 15% improved performance"인 반면, Big Data Analytics Options 백서의 EMR 페이지는 "Amazon EMR provides up to 35% lower cost and up to 15% improved performance for Spark workloads on Graviton2-based instances versus previous generation instances."(M6g 언급)라고 쓴다. 비교 기준 인스턴스 세대나 측정 시점 차이로 추정(추정). 본문은 S27의 30%만 사용했다.
  - 확인 시도: https://docs.aws.amazon.com/whitepapers/latest/cost-modeling-data-lakes/cost-optimization-in-analytics-services.html (S27), https://docs.aws.amazon.com/whitepapers/latest/big-data-analytics-options/amazon-emr.html (전문 읽기, 2026-10-17), https://aws.amazon.com/blogs/big-data/amazon-emr-now-provides-up-to-30-lower-cost-and-up-to-15-improved-performance-for-spark-workloads-on-graviton2-based-instances/ .
  - 후속: 문항에서는 비율 수치를 정답 근거로 쓰지 말고 "Graviton이 비용·성능 이점" 수준으로만 쓴다.

- G-1.2-18 [불확실] Glue 동시 실행·DPU 쿼터를 본문에 쓰지 않았고 값의 정합성이 의심스럽다. Glue General Reference(재확인 2026-10-19)에서 "Max concurrent job runs per account" 기본 2,000(조정 가능)인데 "Max concurrent job runs per job"은 기본 4,000(조정 가능)으로 잡 단위 쿼터가 계정 단위보다 크다(설명 문구만으로는 의미 확인 불가). "Max task DPUs per account"는 us-east-1, us-east-2, us-west-2, ap-northeast-1, ap-southeast-2, eu-west-1에서 1,000, 그 밖의 리전은 500(조정 가능)이고, "Maximum number of queued job runs"는 1,000, "Max jobs per account"는 2,000이다. 본문은 ExecutionProperty의 MaxConcurrentRuns 기본 1(S42)과 잡 큐잉(S41)만 사용했다.
  - 확인 시도: https://docs.aws.amazon.com/general/latest/gr/glue.html (재확인 2026-10-19); https://docs.aws.amazon.com/glue/latest/webapi/API_ExecutionProperty.html (S42).
  - 후속: Service Quotas 콘솔이나 AWS CLI로 실제 값을 확인하거나, 문항에서 수치 사용을 피한다.

- G-1.2-19 [확인필요] Redshift Data API의 "비동기" 서술에 대한 1차 개발자 문서 근거가 부족하다. 본문은 비동기·쿼리 ID·결과 24시간 보존을 블로그(S45)로 근거 삼았다. 개발자 문서(S44)의 확인된 발췌에는 한도(쿼리 24시간, 클러스터당 활성 500, 결과 500 MB, 보존 24시간, 문 크기 200 KB)와 인증 방식만 있고 "asynchronous" 문장은 확인하지 못했다(Knowledge Center에는 "Amazon Redshift Data API is asynchronous." 문구가 있으나 repost.aws 페이지라 출처 목록에서 제외). 쿼리 문 크기 200 KB 한도도 사실표에 넣지 않았다.
  - 확인 시도: https://docs.aws.amazon.com/redshift/latest/mgmt/data-api.html (2026-10-17 검색 발췌); https://repost.aws/knowledge-center/redshift-identify-data-api-errors .
  - 후속: data-api.html 전문에서 비동기 문장을 확인한 뒤 근거를 1차 문서로 교체한다.

- G-1.2-20 [확인필요] Glue 5.0 이상의 로깅 설정: S39(콘솔 도움말)는 "Glue 4.0 이하에서는 continuous logging이 선택 기능이었고 5.0부터 모든 잡이 실시간 로깅 기능을 갖는다"고만 하며 5.0 이상의 설정 옵션은 "Logging for AWS Glue jobs" 문서를 보라고 안내한다. 그 문서를 읽지 못해 `--enable-continuous-cloudwatch-log` 같은 파라미터가 5.0+에서 여전히 의미가 있는지는 미확인이다.
  - 확인 시도: https://docs.aws.amazon.com/help-panel/glue/latest/console/edit-job-details-contlogging-hp.html (S39, 2026-10-17).
  - 후속: "Logging for AWS Glue jobs" 문서(URL 미조회)를 확인한다.

- G-1.2-21 [확인필요] Athena 요금: 본문 사실표 #50의 "$5/TB, 최소 10 MB"는 Big Data Analytics Options 백서(S21) 기준이다. Athena FAQ는 쿼리당(스캔량) 과금 외에 Capacity Reservations("you pay an hourly price for query processing capacity, not data scanned")도 안내하나 본문은 반영하지 않았다. 현행 요금 페이지는 미조회이고 단가는 리전별로 다를 수 있다.
  - 확인 시도: https://docs.aws.amazon.com/whitepapers/latest/big-data-analytics-options/amazon-athena.html (S21), https://aws.amazon.com/athena/faqs/ (2026-10-17 검색 발췌).
  - 후속: AWS의 Athena 요금 페이지(이번 조사에서 URL을 조회하지 못함)에서 현행 단가를 확인한 뒤 수치를 갱신한다.

- G-1.2-22 [개명·종료] Kinesis Data Firehose → Amazon Data Firehose: 본문(S35, 사실표 #58–60, 문항 후보 2)은 현행명 "Amazon Data Firehose"를 쓴다. 시험 가이드 in-scope 목록은 구명칭 "Amazon Kinesis Data Firehose"를 그대로 적고 있어(재확인 2026-10-19) 학습문서·문항에서는 구명·현행명을 병기하는 편이 안전하다. 개명일(2024-02-12)은 00-overview.md §6.2 N1에서 확인된 값을 따른다.
  - 확인 시도: https://docs.aws.amazon.com/firehose/latest/dev/record-format-conversion.html (S35); https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-in-scope-services.html (재확인 2026-10-19); D:/workspace/awc-docs/docs/content-research/DEA-C01/00-overview.md §6.2.
  - 후속: 컨트롤러의 G-0-03과 통합한다.

- G-1.2-23 [수정제안] 본문 보강 후보 — 확인했지만 분량·범위 때문에 본문 사실표에 넣지 않은 사실(필요 시 사실표에 행 추가). (1) RDS Proxy pinning: 연결을 멀티플렉싱할 수 없으면 클라이언트가 세션 내내 같은 프록시 연결을 쓰는 pinning이 되어 재사용 효율이 떨어진다(https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/rds-proxy-best-practices.workload-considerations.html). (2) Redshift Data API 쿼리 문 크기 200 KB(S44). (3) Athena 페더레이션의 병렬 호출 수는 계정 Lambda 동시성 한도에 좌우된다(https://aws.amazon.com/blogs/big-data/query-any-data-source-with-amazon-athenas-new-federated-query/). (4) Firehose의 Lambda 변환은 버퍼링 크기 힌트 0.2~3 MB, 동기 호출 페이로드 6 MB 한도가 있어 CSV→JSON 선변환 설계에 영향(https://docs.aws.amazon.com/firehose/latest/dev/data-transformation.html). (5) EMR Serverless 워커 크기(vCPU 1·2·4·8·16·32, 기본 워커 4 vCPU·16 GB)와 사전 초기화 워커 유휴 종료 기본 15분(https://docs.aws.amazon.com/emr/latest/EMR-Serverless-UserGuide/app-behavior.html , https://aws.amazon.com/blogs/big-data/top-10-best-practices-for-amazon-emr-serverless/).
  - 확인 시도: 위 URL들의 검색 발췌(2026-10-17). 재조회는 하지 않았다.
  - 후속: 취합 세션이 문항 소재로 쓸 항목만 골라 원문 인용을 다시 검증한 뒤 사실표에 추가한다.

- G-1.2-24 [확인필요] 콘솔 도움말(help-panel) 출처 3건은 정식 개발자 가이드와 대조하지 못했다. S39(Glue 로깅), S46(API Gateway 통합 타임아웃), S59(Bedrock Data Automation 정의)는 `docs.aws.amazon.com/help-panel/...` 페이지다. S46은 CDK 레퍼런스와 취지가 같음을 확인했으나(G-1.2-15) 정식 쿼터 페이지와는 대조하지 못했다. S59는 BDA 사용자 가이드의 blueprint 설명(문서 blueprint 최대 40개 등)과 취지가 같지만 정식 페이지를 출처로 쓰지는 않았다.
  - 확인 시도: https://docs.aws.amazon.com/help-panel/glue/latest/console/edit-job-details-contlogging-hp.html , https://docs.aws.amazon.com/help-panel/apigateway/latest/console/rest-timeout.html , https://docs.aws.amazon.com/help-panel/bedrock/latest/console/hp-bdx-data-automation.html , https://docs.aws.amazon.com/bedrock/latest/userguide/bda-custom-output-idp.html (2026-10-17 검색 발췌).
  - 후속: 학습문서 작성 시 개발자 가이드 URL로 교체할 수 있으면 교체한다.

- G-1.2-25 [분할제안] Task 1.2는 Skill 10개, 서비스 15개 이상, 본문 출처 61개, 사실표 97행으로 학습문서 1개에는 과하다. 3개 문서를 제안한다. (A) 컴퓨트·엔진 선택·비용 = Skill 1.2.1 + 1.2.4 + 1.2.5 (컨테이너, Glue/EMR/Lambda/Redshift/Athena 선택표, 비용 레버, Glue 버전·종료 공지). (B) 연결·통합·변환 실무 = Skill 1.2.2 + 1.2.3 + 1.2.6 + 1.2.7 (JDBC/ODBC, 페더레이션·Zero-ETL·AppFlow, 형식 변환, 트러블슈팅). (C) 데이터 API·데이터 특성·LLM = Skill 1.2.8 + 1.2.9 + 1.2.10 (Data API, 3V, Bedrock). 이유: (A)는 엔진 비교표와 비용 사실을 공유하고, (B)는 Glue·Athena·Redshift 운영 사실을 공유하며, (C)는 서비스 노출·정의·v1.1 신규 주제를 묶는다. 결정은 취합 세션이 한다.
  - 확인 시도: tasks/1-2.md 구조(소제목 10개, 비교표 5개, 함정 짝 28개, 사실표 97행, 문항 후보 5개, 출처 61개) 대조.
  - 후속: 취합 세션이 분할 여부와 문서별 문항 배분을 결정한다.
  - 근거 URL (컨트롤러 보강): 구조·범위 판단 항목(외부 문서 인용 없음). 근거 기준: 공식 가이드 https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain1.html 및 tasks/1-2.md 출처 목록

- G-1.2-26 [수정제안] DEA-C01.json (Task 1.2): `flutter_app/assets/exam_guides/DEA-C01.json`의 Task 1.2 Skill 10개 문구는 공식 KO 가이드와 일치하지만 Skill 1.2.1만 서비스명을 풀어 쓴다(JSON: "Amazon Elastic Kubernetes Service(Amazon EKS), Amazon Elastic Container Service(Amazon ECS)", 공식 KO: "Amazon EKS, Amazon ECS"). 00-overview.md §7과 같은 건이며 기능 영향이 없어 선택 사항이다. 추가로 JSON에는 v1.1 신규/개정 표시 필드가 없다(2026-10-19 Grep "신규|개정|isNew|revised|v1.1|guideVersion|\"new\"" 일치 0건). Skill 1.2.10이 v1.1 신규인데 UI에서 구분할 수 없으므로, 선택 사항으로 Skill 단위 메타 필드(예: v1.1 신규/개정 표시)를 추가하는 안을 G-0-02의 guideVersion 제안과 함께 검토하길 제안한다.
  - 확인 시도: D:/workspace/awc-docs/flutter_app/assets/exam_guides/DEA-C01.json 의 Task 1.2 skills(41~50행) ↔ tasks/1-2.md의 "공식 Skill 항목 원문" 한국어 열; https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-revisions.html (신규 Skill 목록, 재확인 2026-10-19).
  - 후속: 레포 소유자가 데이터 파일 수정 여부를 결정한다(코드 변경 아님, 이 작업에서는 수정하지 않았다).

### Task 1.3 — Orchestrate data pipelines (데이터 파이프라인 오케스트레이션)

- G-1.3-01 [개명·종료] EventBridge 이벤트 버스 명칭이 바뀐 것으로 보임. 현재 User Guide는 "Custom Event Bus"와 "Custom Event Bus - Classic" 두 종류를 설명하고 "For new applications, start with the Custom Event Bus"라고 안내한다. 기존 자료의 "default/custom/partner event bus + rules" 용어와 다를 수 있다. 본문에는 "이벤트 버스"로만 서술했다.
  - 확인 시도: https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-what-is.html 전문 읽음. 규칙(rules)/타깃 중심의 Classic 설명은 같은 가이드에 남아 있다고만 언급되어 있고, 시험이 어느 용어를 쓰는지는 확인 불가.
  - 후속: 취합 세션이 학습문서에서 "이벤트 버스(규칙+타깃)" 서술을 유지하되 신규 용어를 한 줄 병기할지 결정.

- G-1.3-02 [상충] EventBridge Scheduler 일정 개수 한도. 2022년 출시 블로그는 Scheduler "1 million per account" vs EventBridge 규칙 "300 rule limit per account per Region"이라 적었고, 현재 Scheduler 할당량 페이지는 "Number of schedules (default 10,000,000 per Region, adjustable to billions)"라고 적는다.
  - 확인 시도: https://aws.amazon.com/blogs/compute/introducing-amazon-eventbridge-scheduler/ , https://docs.aws.amazon.com/scheduler/latest/UserGuide/scheduler-quotas.html
  - 후속: 1-3.md 본문에는 개수 한도를 넣지 않았다. 3-1.md는 현행 할당량 페이지 값을 사용. 학습문서·문항에서는 현행 페이지 값만 쓰고 블로그 값은 쓰지 말 것.

- G-1.3-03 [개명·종료] Amazon MWAA Serverless가 신규 배포 옵션으로 공식 문서에 존재한다(Airflow v3, YAML DAG factory 정의, 사용 시간 과금, 워크플로별 실행 역할, Airflow UI 직접 접근 없음). 시험 가이드 v1.1 문구는 "Amazon MWAA"만 언급하므로 시험 범위 포함 여부는 불확실하다.
  - 확인 시도: https://docs.aws.amazon.com/mwaa/latest/mwaa-serverless-userguide/what-is-mwaa-serverless.html 전문, MWAA 요금 페이지의 "MWAA Serverless Pricing" 절.
  - 후속: 취합 세션이 학습문서에서 비교 표 한 줄 정도로 다룰지 결정. 문항 정답 근거로 쓰기 전에 사람 검수 필요.

- G-1.3-04 [개명·종료] Lambda 문서 용어가 바뀌었다. 표준 함수를 "Lambda Event Functions"로 부르고 신규로 "Lambda durable functions"(체크포인트·재생, 최대 1년), "Lambda Managed Instances"를 설명한다. Lambda 할당량 페이지는 "Code can run for up to 15 minutes in a single invocation (up to 90 minutes for Lambda Managed Instances functions invoked asynchronously or through any event source mapping ...)"라고 적는다. 시험은 여전히 "Lambda 최대 15분"을 전제로 출제될 가능성이 높지만 선지 작성 시 "15분이 절대 상한"이라고 단정하면 현행 문서와 어긋날 수 있다.
  - 확인 시도: https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-limits.html , https://docs.aws.amazon.com/lambda/latest/dg/configuration-timeout.html , https://docs.aws.amazon.com/lambda/latest/dg/durable-functions.html
  - 후속: 문항에서는 "일반 Lambda 함수는 최대 15분" 식으로 한정해 서술.

- G-1.3-05 [불확실] Glue 잡의 자동 재시도 기본값. Glue FAQ는 "AWS Glue also provides default retry behavior that will retry all failures three times before sending an error notification"라고 적지만, Glue 잡 속성(CDK/CloudFormation 문서)의 MaxRetries 기본값은 0으로 표기된다. 문맥이 다른지(크롤러/내부 재시도 vs 잡 속성) 확정하지 못했다. 본문에는 쓰지 않았다.
  - 확인 시도: https://aws.amazon.com/glue/faqs/ 검색 chunk, CDK aws_glue 문서(JobProps maxRetries default: 0), Glue Studio 블로그의 "Number of retries" 항목.
  - 후속: Glue Web API 레퍼런스(Jobs)의 MaxRetries 설명과 콘솔 기본값을 확인해 3-1 Task의 Glue 항목에서 확정.

- G-1.3-06 [불확실] Skill 1.3.2의 "성능·확장성"을 직접 서술하는 단일 공식 문서를 찾지 못했다. Data Analytics Lens 신뢰성 Pillar의 BP 6(복원력 설계)은 확인했으나, 성능 Pillar는 BP 8(최고 성능 컴퓨팅 선택) 요약만 확인했다. 본문에서는 서비스별 문서(MWAA 워커 오토스케일, Distributed Map 동시성, Express 시작률, SQS 처리량)로 대체했다.
  - 확인 시도: https://docs.aws.amazon.com/wellarchitected/latest/analytics-lens/design-principle-8.html 요약 chunk까지만.
  - 후속: 필요하면 Lens 성능 효율 BP 8~10 세부 페이지를 추가 조사.

- G-1.3-07 [불확실] Skill 1.3.3 "서버리스 워크플로 구현 및 유지 관리"의 범위가 공식 정의로 확정되지 않는다. 가장 가까운 공식 근거로 Step Functions 상태 머신 버전·별칭, 로깅, 오류 처리, redrive를 묶어 해석했다. SAM/CDK 배포·패키징은 별도 Skill(Domain 4)로 보인다.
  - 확인 시도: https://docs.aws.amazon.com/step-functions/latest/dg/concepts-state-machine-alias.html , https://docs.aws.amazon.com/step-functions/latest/dg/redrive-executions.html
  - 후속: 취합 세션이 1.3.3의 문항을 "Step Functions 통합·오류 처리 중심"으로 쓸지 결정.

- G-1.3-08 [분할제안] Task 1.3은 Skill 4개에 서비스 10여 개(Step Functions, MWAA, EventBridge, Glue 워크플로, Lambda, SNS, SQS, Well-Architected)가 걸려 학습문서 1개로는 길다. 제안: (a) "오케스트레이션 서비스 선택과 Step Functions"(Skill 1.3.1, 1.3.3) (b) "파이프라인 복원력과 알림(SNS/SQS)"(Skill 1.3.2, 1.3.4)로 2분할. 결정은 취합 세션.
  - 확인 시도: 1-3.md 작성 중 소제목 11개·비교 표 5개로 분량이 상한에 근접.
  - 후속: 취합 세션.
  - 근거 URL (컨트롤러 보강): 구조·범위 판단 항목(외부 문서 인용 없음). 근거 기준: 공식 가이드 https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain1.html 및 tasks/1-3.md 출처 목록

- G-1.3-09 [확인필요] MWAA 지원 Airflow 버전 표(조회일 기준 가용 최신 버전은 v3.3.1, 2026-09-01 가용)는 변경이 잦다. 본문에는 특정 최신 버전 번호를 쓰지 않고 지원 정책(최소 3개 마이너 버전, 종료 180일 전 공지)과 종료된 3개 버전만 적었다.
  - 확인 시도: https://docs.aws.amazon.com/mwaa/latest/userguide/airflow-versions.html (표에는 v3.3.1, v3.2.1, v2.11.2, v2.11.0, v3.0.6, v2.10.3 등이 보였다).
  - 후속: 학습문서에도 특정 버전 번호는 피하고 "공식 표 확인"으로 안내 권장.

- G-1.3-10 [확인필요] 사실·숫자 표 일부 항목은 인용 규칙(마크업·줄바꿈이 낀 문장은 인용 불가) 때문에 본문 설명만 있고 표 인용이 없다. 예: Glue·Athena·EMR Serverless의 .sync 지원 서비스 목록(S3 페이지 표), Distributed Map의 Express 미지원(S1 비교 표), Standard/Express의 정확한 실행 의미론 표 문구. 사실 자체는 해당 페이지의 표로 확인했다.
  - 확인 시도: https://docs.aws.amazon.com/step-functions/latest/dg/connect-to-resource.html , https://docs.aws.amazon.com/step-functions/latest/dg/choosing-workflow-type.html 전문 읽음.
  - 후속: 컨트롤러가 표 항목의 인용을 요구하면 해당 페이지 표를 직접 대조.

- G-1.3-11 [개명·종료] AWS Service Availability Updates(2026-03 공지)에 따르면 Amazon SNS의 Message Data Protection(MDP) 기능이 2026-04-30부터 신규 고객 대상 maintenance로 이동한다(기존 고객은 계속 사용). 1-3.md의 SNS 설명(필터 정책·FIFO 토픽·DLQ)에는 영향이 없다.
  - 확인 시도: https://aws.amazon.com/about-aws/whats-new/2026/03/aws-service-availability/ (검색 chunk, 조회 2026-10-17; 2026-10-19에 페이지 전문으로 재확인: "Services moving to maintenance will no longer be accessible to new customers starting April 30, 2026." 목록에 "Amazon Simple Notification Service (SNS) - Message Data Protection (MDP) Feature"와 "AWS Glue - Ray Jobs Feature"가 있음)
  - 후속: 문항에서 SNS Message Data Protection을 정답 근거로 쓰지 말 것. G-1.3-05(Glue 재시도 기본값)는 3.1 조사에서도 확정하지 못했다 — G-3.1-02 참조.

### Task 1.4 — Apply programming concepts (프로그래밍 개념 적용)

- G-1.4-01 [분할제안] Skill 11개를 학습문서 1개로 쓰기엔 과하다. 5개 문서로 나누기를 제안한다(D2와 D3를 합치면 4개). 결정은 취합 세션 몫이다.
  - D1 "Lambda 구성·스토리지": Skill 1.4.2 + 1.4.7. 동시성(예약·프로비저닝·SnapStart), ESM 스케일링(SQS·Kinesis), 메모리·타임아웃, `/tmp`·EFS·S3 Files가 모두 "Lambda 함수 설정" 한 덩어리다. 1-4.md 출처 S8–S13, S37–S41, S61, S62(13개).
  - D2 "수집·변환 코드 최적화와 분산 컴퓨팅": 1.4.1 + 1.4.10. 둘 다 Spark(셔플·파티션·태스크)와 EMR·MapReduce 개념을 공유한다. 출처 S1–S7, S50, S51(9개).
  - D3 "프로그래밍 언어·자료구조": 1.4.3 + 1.4.11. 둘 다 시험 범위 근거가 약하다(가이드가 언어 구문을 범위 밖으로 명시, 1.4.11은 G-1.4-06). 출처 S14–S18, S52–S56, S59(11개).
  - D4 "IaC: CloudFormation·CDK·SAM": 1.4.5 + 1.4.6 + 1.4.8. 1.4.8은 v1.0 지식 항목이 v1.1에서 Skill로 바뀐 것이라 1.4.5와 사실상 겹친다(G-1.4-07). 도구 선택형 문항이 많아 한 문서에서 비교하는 편이 맞다. 출처 S23–S36, S57, S58(16개).
  - D5 "소프트웨어 공학·CI/CD": 1.4.4 + 1.4.9. 버전 관리·테스트·로깅이 파이프라인(CodePipeline·CodeBuild·CodeDeploy)의 단계로 이어진다. 출처 S19–S22, S42–S49, S60, S63(14개). S57(CodeCommit 범위 제외)과 S59(Git 문장)는 D4·D3와 공유한다.
  - 대안: D2(9개)와 D3(11개)는 출처가 적다. 합치면 20개 출처의 "코드·언어·분산·자료구조" 문서 1개가 된다(주제 연결은 약함).
  - 확인 시도: 1-4.md 핵심 개념 소제목별 [S#] 사용처로 Skill별 출처 군집을 계산했다(S14–S18은 1.4.3 절, S50·S51은 1.4.10 절, S52–S56은 1.4.11 절에서 사용). 합계 13+9+11+16+14 = 63.
  - 후속: 취합 세션이 문서 수·순서를 결정한다. 학습문서 1개당 출처 12~18개를 기준으로 삼았다.
  - 근거 URL: https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-revisions.html (1.4.8의 v1.0 지식 항목 → v1.1 Skill 전환)

- G-1.4-02 [개명·종료] Lambda 용어 변경. 런타임 페이지는 일반 Lambda 함수를 "AWS Lambda Event Functions (previously known as Lambda functions)"라 부른다. 쿼터 페이지는 durable functions·Lambda MicroVMs·Lambda Web Functions를 별도 절로 두고, Lambda Managed Instances 함수는 비동기·ESM 호출 시 최대 90분이라고 적는다. 시험 가이드 Skill 문구는 여전히 "Lambda functions"다.
  - 확인 시도: lambda-runtimes, gettingstarted-limits의 `.md` 원문을 2026-10-17에 읽고 2026-10-19에 다시 대조.
  - 후속: 학습문서는 "Lambda 함수(문서상 Event Function)"로 병기하고, 15분 한도는 "일반(Event Function) 기준"임을 명시.
  - 근거 URL: https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtimes.html · https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-limits.html

- G-1.4-03 [상충] CodeCommit 신규 고객 가용성 표기가 공식 페이지끼리 엇갈린다.
  - (a) "다시 열림": CodeCommit 사용자 가이드 문서 이력 표에 "AWS CodeCommit is now available to new customers." 항목이 2025-11-25로 올라 있다(같은 표에 2024-07-25 "no longer available" 항목). 공식 DevOps 블로그 "The Future of AWS CodeCommit"(게시 표기 24 NOV 2025)는 "CodeCommit is returning to full General Availability, effective immediately."라고 발표했다. 게시일 24일과 이력 25일은 하루 차이다(시간대 차이일 수 있음, 미확인).
  - (b) "여전히 불가": CloudFormation 템플릿 레퍼런스 `AWS::CodeCommit::Repository`의 Important 상자와 CodeCommit 요금 페이지 상단 배너가 "AWS CodeCommit is no longer available to new customers."를 그대로 싣고 있다. AMS 사용자 가이드의 Note는 "closed new customer access ... effective July 25, 2024"라고 적는다. CodeCommit 제품 페이지와 FAQ의 HTML 본문에는 신규 고객 관련 문구가 없다(2026-10-19 확인: "new customers"·"no longer available" 검색 0건).
  - (c) 시험 범위: 시험 가이드 개정 이력은 v1.1(2025-12-12)이 AWS CodeCommit을 in-scope 서비스 목록에서 제거했다고 적는다("Services removed from the in-scope list": AWS Cloud9, AWS CodeCommit, AWS SCT). 현재 in-scope Developer Tools는 AWS CLI·CloudFormation·CDK·CodeBuild·CodeDeploy·CodePipeline·Amazon Q다.
  - 확인 시도: 문서 이력·블로그·CFN 레퍼런스·AMS 문서를 2026-10-17에 읽고, 2026-10-19에 요금·제품·FAQ 페이지까지 다시 열어 문구를 대조.
  - 후속: 학습문서는 "가용성 표기가 상충하며 v1.1 시험 범위에서는 제외"로만 쓰고 날짜는 출처별로 병기하거나 생략. 취합 시 AWS 공지를 재확인.
  - 근거 URL: https://docs.aws.amazon.com/codecommit/latest/userguide/history.html · https://aws.amazon.com/blogs/devops/aws-codecommit-returns-to-general-availability/ · https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/aws-resource-codecommit-repository.html · https://aws.amazon.com/codecommit/pricing/ · https://docs.aws.amazon.com/managedservices/latest/userguide/codecommit.html · https://aws.amazon.com/codecommit/ · https://aws.amazon.com/codecommit/faqs/ (직접) · https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-revisions.html · https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-in-scope-services.html

- G-1.4-04 [확인필요] Skill 1.4.3의 예시 언어 R과, 조사 주제로 받은 AWS SDK for pandas의 근거가 약하다.
  - R: 개발자 가이드에서 R을 지원 언어로 설명한 페이지를 찾지 못했다. EMR Release Guide의 Spark 페이지는 "Spark natively supports applications written in Scala, Python, and Java"라고 적고, EMR 시작하기 페이지도 Python(PySpark)·SQL·Java·Scala만 든다. R이 나오는 공식 자료는 SageMaker AI의 내장 R 커널·RStudio 문서, 그리고 EMR 공식 블로그 두 편(SparkR 2016-03-29, sparklyr 2016-10-18 게시·2021-07-07 갱신)뿐이다.
  - AWS SDK for pandas: 시험 가이드 페이지 5개(본문, 도메인 1~4)와 개정 이력·in-scope 목록에 pandas 언급이 없다(2026-10-19 확인). 서비스 문서에는 라이브러리 이름 awswrangler로 나온다: Glue Python shell의 지원 라이브러리 표(analytics 세트)와 `library-set` 설명, Glue 노트북 세션의 `%additional_python_modules awswrangler` 예제, Glue 파이썬 라이브러리 문서의 requirements.txt 예제. "AWS SDK for pandas (awswrangler)"라는 표기는 ML 블로그(2023-12-14)에서 확인했다. awswrangler를 쓰는 코드 예제는 Big Data 블로그(2023-07-06)에도 있다.
  - 시험 가이드는 "Demonstrate knowledge of programming language-specific syntax"를 범위 밖 직무로 명시한다.
  - 확인 시도: 2026-10-17 검색(SparkR·EMR, R language support, AWS SDK for pandas)과 2026-10-19 재검색(SparkR·EMR, AWS SDK for pandas 문서, Glue Python shell awswrangler) 후 페이지 원문 대조. AWS SDK for pandas의 라이브러리 참조 문서 자체는 검색에 나오지 않았다.
  - 후속: 학습문서는 R을 "가이드가 든 예시 언어"로만 쓰고 서비스별 R 지원을 단정하지 말 것. awswrangler는 필요하면 Glue Python shell 사전 패키지 라이브러리로만 언급.
  - 근거 URL: https://docs.aws.amazon.com/emr/latest/ReleaseGuide/emr-spark.html · https://aws.amazon.com/emr/getting-started/ · https://docs.aws.amazon.com/sagemaker/latest/dg/r-guide.html · https://docs.aws.amazon.com/sagemaker/latest/dg/rstudio.html · https://aws.amazon.com/blogs/big-data/crunching-statistics-at-scale-with-sparkr-on-amazon-emr/ · https://aws.amazon.com/blogs/big-data/running-sparklyr-rstudios-r-interface-to-spark-on-amazon-emr/ · https://docs.aws.amazon.com/glue/latest/dg/add-job-python.html · https://docs.aws.amazon.com/glue/latest/dg/manage-notebook-sessions.html · https://docs.aws.amazon.com/glue/latest/dg/aws-glue-programming-python-libraries.html · https://aws.amazon.com/blogs/machine-learning/streamlining-etl-data-processing-at-talent-com-with-amazon-sagemaker/ · https://aws.amazon.com/blogs/big-data/extract-time-series-from-satellite-weather-data-with-aws-lambda/ · https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01.html

- G-1.4-05 [상충] SQS 이벤트 소스 매핑 스케일링 수치가 구 블로그와 현재 문서에서 다르다. Compute Blog(2023-01-12)는 "adding up to 60 functions per minute, up to 1,000 functions"라 하고, 현재 개발자 가이드는 분당 최대 300개 증가·ESM당 동시 호출 최대 1,250이라고 한다(re:Post 지식 센터도 300/1,250). 1-4.md는 현재 개발자 가이드 값만 사용했다.
  - 확인 시도: services-sqs-scaling `.md` 원문, 블로그, re:Post 지식 센터를 2026-10-19에 대조.
  - 후속: 학습문서에서 구 블로그 수치(60/1,000)를 쓰지 말 것.
  - 근거 URL: https://docs.aws.amazon.com/lambda/latest/dg/services-sqs-scaling.html · https://aws.amazon.com/blogs/compute/introducing-maximum-concurrency-of-aws-lambda-functions-when-using-amazon-sqs-as-an-event-source/ · https://repost.aws/knowledge-center/lambda-sqs-scaling

- G-1.4-06 [불확실] Skill 1.4.11(데이터 구조·알고리즘: 그래프·트리)이 시험에서 무엇을 묻는지 공식 근거로 확정하지 못했다. 가이드 문구는 "Describe data structures and algorithms (for example, graph data structures and tree data structures)"뿐이다. 가장 가까운 공식 근거로 Neptune 그래프 모델, Neptune Analytics 그래프 알고리즘(breadth-first search 등), PostgreSQL B-tree 인덱스("A balanced tree (B-tree) is a self-balancing tree data structure"), Redshift 재귀 CTE(계층 데이터), DynamoDB 인접 리스트(그래프 데이터를 노드와 엣지로 표현)를 1-4.md에 정리했다.
  - 확인 시도: 검색 5회 — Neptune 그래프 모델, Neptune Analytics 알고리즘, B-tree 인덱스, Redshift 재귀 CTE, DynamoDB 인접 리스트. 시험 문항을 확인할 수단은 없다(덤프 접근 금지).
  - 후속: 사람 검수 시 출제 범위를 판단. 근거 없는 일반 CS 설명(트리 순회, 정렬 알고리즘 등)은 학습문서에 넣지 말 것.
  - 근거 URL: https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain1.html · https://aws.amazon.com/neptune/getting-started/ · https://docs.aws.amazon.com/neptune-analytics/latest/userguide/algorithms.html · https://aws.amazon.com/blogs/database/index-types-supported-in-amazon-aurora-postgresql-and-amazon-rds-for-postgresql-b-tree/ · https://docs.aws.amazon.com/redshift/latest/dg/r_WITH_clause.html · https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/bp-adjacency-graphs.html

- G-1.4-07 [수정제안] Skill 1.4.5와 1.4.8이 사실상 중복이다. 1.4.8("반복 가능한 리소스 배포를 위한 IaC, 예: CloudFormation·CDK")은 v1.0의 지식 항목("Infrastructure as code (IaC) for repeatable deployments")이 v1.1에서 Skill로 바뀐 것이고, 1.4.5("IaC로 데이터 엔지니어링 솔루션 배포")와 내용이 겹친다. 레포 `DEA-C01.json`의 1.4.6·1.4.8 문구는 가이드 한국어판의 약칭(AWS SAM, AWS CDK) 대신 전체명(AWS Serverless Application Model(AWS SAM), AWS Cloud Development Kit(AWS CDK))을 쓴다(컨트롤러 G-0-01과 같은 유형). JSON에는 Skill ID(1.4.1…) 필드가 없어 학습문서와 Skill 단위 매핑이 불가하다.
  - 확인 시도: `D:/workspace/awc-docs/flutter_app/assets/exam_guides/DEA-C01.json`의 1.4(65–81행)·3.4(195–205행) 문구를 스켈레톤 한국어 열과 문자열 비교(2026-10-19). 3.4의 5개 문구는 일치, 1.4는 11개 중 1.4.6·1.4.8만 다르다.
  - 후속: 취합 세션이 JSON 정정 여부 결정(Skill ID 필드 추가 포함).
  - 근거 URL: https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-revisions.html · https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain1.html

- G-1.4-08 [확인필요] 1-4.md 본문(사실 표)에 넣지 않은 수치. 아래 값은 공식 페이지에서 확인했지만 표 셀·링크 서식 문장이라 자동 대조에 불리하거나 Skill 범위 밖의 부차 한도라서 뺐다. 학습문서에서 필요하면 해당 URL에서 평문 문장을 골라 인용할 것(2026-10-19에 아래 인용을 원문과 대조함).
  - SQS ESM BatchSize 최대(표준 큐 10,000 / FIFO 10) — 표 셀: "For standard queues, the maximum is 10,000. For FIFO queues, the maximum is 10." https://docs.aws.amazon.com/lambda/latest/dg/services-sqs-parameters.html
  - Lambda 환경 변수 합계 4 KB — 평문: "The total size of all environment variables doesn't exceed 4 KB." https://docs.aws.amazon.com/lambda/latest/dg/configuration-envvars.html (직접)
  - 컨테이너 이미지 최대 10 GB — 평문: "Lambda supports a maximum uncompressed image size of 10 GB, including all layers." https://docs.aws.amazon.com/lambda/latest/dg/images-create.html (직접)
  - .zip 업로드 50 MB — 평문: "If the file is larger than 50 MB, upload the file to the function from an Amazon S3 bucket." https://docs.aws.amazon.com/lambda/latest/dg/configuration-function-zip.html (직접)
  - SnapStart 비호환(프로비저닝 동시성·EFS·S3 Files·512 MB 초과 임시 스토리지) — 문장에 링크 서식이 낀다: "or ephemeral storage greater than 512 MB" https://docs.aws.amazon.com/lambda/latest/dg/snapstart.html
  - CodeDeploy 사전 정의 Lambda 구성(예: LambdaCanary10Percent5Minutes, LambdaLinear10PercentEvery1Minute) — 표 셀: "Shifts 10 percent of traffic every minute until all traffic is shifted." (Linear 계열 설명) https://docs.aws.amazon.com/codedeploy/latest/userguide/deployment-configurations.html
  - Spark 태스크는 기본적으로 vCPU 코어당 1개 — Note 상자 안 문장: "Spark supports one task for each virtual CPU (vCPU) core by default." https://docs.aws.amazon.com/prescriptive-guidance/latest/tuning-aws-glue-for-apache-spark/key-topics-apache-spark.html
  - CodeCommit 문서 이력의 날짜(2024-07-25 중단, 2025-11-25 재개) — 표 셀: https://docs.aws.amazon.com/codecommit/latest/userguide/history.html
  - 확인 시도: `.md` 원문에서 표 행·링크 서식 여부를 판별하고 평문 문장만 본문 인용으로 채택.
  - 후속: 취합 세션 판단.

- G-1.4-09 [상충] Lambda 확장 속도 서술이 한 페이지 안에서도 다르다. Understanding Lambda Event Function scaling은 한쪽에서 "burst increase of 500 concurrency every 10 seconds, or by 5,000 requests per second every 10 seconds"라 하고, 다른 쪽에서는 함수별 확장 속도를 "1,000 execution environment instances every 10 seconds"라 한다. 스케일링 동작 페이지(scaling-behavior)와 쿼터 페이지도 1,000/10초다. 1-4.md는 1,000/10초만 사용했다.
  - 확인 시도: lambda-concurrency, scaling-behavior, gettingstarted-limits `.md` 원문을 2026-10-19에 대조.
  - 후속: 학습문서에서 500/10초는 쓰지 말고, 필요하면 최신 문서·AWS Support로 재확인.
  - 근거 URL: https://docs.aws.amazon.com/lambda/latest/dg/lambda-concurrency.html · https://docs.aws.amazon.com/lambda/latest/dg/scaling-behavior.html (직접) · https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-limits.html

- G-1.4-10 [상충] SQS provisioned mode 폴러 수 범위가 페이지마다 다르다. with-sqs·invocation-eventsourcemapping 페이지는 최소 폴러 2–200(기본 2), 최대 폴러 2–10,000(기본 200)이라 하고, services-sqs-parameters 표의 ProvisionedPollerConfig는 최소 2–200, 최대 2–2000이라 한다. 1-4.md에는 폴러 수치를 쓰지 않았다(provisioned mode의 동시 호출 최대 100,000만 인용).
  - 확인 시도: with-sqs, invocation-eventsourcemapping, services-sqs-parameters `.md` 원문을 2026-10-19에 대조.
  - 후속: 학습문서에서 폴러 수 범위는 생략하거나 최신 API 레퍼런스(CreateEventSourceMapping)로 재확인.
  - 근거 URL: https://docs.aws.amazon.com/lambda/latest/dg/with-sqs.html (직접) · https://docs.aws.amazon.com/lambda/latest/dg/invocation-eventsourcemapping.html (직접) · https://docs.aws.amazon.com/lambda/latest/dg/services-sqs-parameters.html

- G-1.4-11 [확인필요] Lambda의 S3 파일 시스템 마운트(Amazon S3 Files)는 최신 기능이다. Lambda 구성 페이지(configuration-filesystem-s3files)가 있고, Compute Blog "Serverless ICYMI Q2 2026"에 "Amazon S3 Files and Lambda integration" 항목이 있다. Lambda 파일 시스템 페이지는 "A Lambda function can use either Amazon EFS or Amazon S3 Files, but not both."라 하고, S3 Files 동기화 페이지는 연결 버킷에 S3 버저닝이 필수라고 한다. 그러나 DEA-C01 in-scope 목록의 Storage에는 Amazon EFS·Amazon S3 등이 있고 S3 Files는 없다. 시험 출제 여부는 불확실하다. 1-4.md는 위임 지시의 조사 주제("EFS·S3 마운트")에 따라 EFS와 나란히 정리했다.
  - 확인 시도: configuration-filesystem, configuration-filesystem-s3files, s3-files-synchronization 원문 통독, 검색으로 Compute Blog 확인, in-scope 목록 대조(2026-10-19 재대조).
  - 후속: 학습문서에서 S3 Files는 "신규 기능, 시험 범위 불확실" 박스로 분리.
  - 근거 URL: https://docs.aws.amazon.com/lambda/latest/dg/configuration-filesystem.html · https://docs.aws.amazon.com/lambda/latest/dg/configuration-filesystem-s3files.html · https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-files-synchronization.html · https://aws.amazon.com/blogs/compute/serverless-icymi-q2-2026/ · https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-in-scope-services.html

- G-1.4-12 [확인필요] 1-4.md 출처 63개 중 12개(S12, S27–S31, S33–S35, S58, S61, S63)는 검색 도구가 반환한 URL이 아니다. 브리프 §2.3("도구가 실제로 반환한 URL만")에서 벗어나므로 목록과 확인 경로를 남긴다. 나머지 51개는 검색 결과에 나온 URL이다.
  - S58 `dea-01-in-scope-services.html`: 검색은 MLA-C01의 in-scope 페이지(machine-learning-engineer-associate-02/mla-02-in-scope-services.html)만 반환했다. DEA 쪽 페이지는 그 형제 파일명 패턴으로 read_documentation에 직접 요청해 SUCCESS를 받았다.
  - S27–S31, S33–S35(CDK 가이드 4개, SAM 개발자 가이드 4개): read_documentation으로 직접 요청해 SUCCESS를 받은 URL이다.
  - S12(invocation-eventsourcemapping), S61(configuration-memory), S63(CodeDeploy welcome): 2026-10-19 인용 보강 때 `.md`를 직접 요청해 HTTP 200과 인용문 일치를 확인했다.
  - 확인 시도: 전사 기록에서 출처 URL이 검색 결과에 처음 나타난 지점을 대조.
  - 후속: 컨트롤러가 이 12개를 그대로 둘지 판단(전부 HTTP 200·인용 일치). S58은 00-overview §6에서 확보한 in-scope URL과 같은지도 대조.
  - 근거 URL: https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-in-scope-services.html · https://docs.aws.amazon.com/aws-certification/latest/machine-learning-engineer-associate-02/mla-02-in-scope-services.html

- G-1.4-13 [개명·종료] 용어 혼재(참고). EMR 클러스터의 관리 노드를 EMR FAQ는 "master node", Prescriptive Guidance(EMR 하드웨어 선택)는 "primary node", DynamoDB의 EMR 문서는 "leader node"라 부른다. 같은 개념이다. CodePipeline의 외부 Git 연결은 서비스명이 AWS CodeConnections이고, 액션 유형 이름은 `CodeStarSourceConnection`으로 남아 있다.
  - 확인 시도: EMR FAQ, amazon-emr-hardware 가이드, EMRforDynamoDB, action-reference-CodestarConnectionSource를 2026-10-19에 대조.
  - 후속: 학습문서는 "primary(구 master) 노드"로 병기.
  - 근거 URL: https://aws.amazon.com/emr/faqs/ · https://docs.aws.amazon.com/prescriptive-guidance/latest/amazon-emr-hardware/select.html · https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/EMRforDynamoDB.html · https://docs.aws.amazon.com/codepipeline/latest/userguide/action-reference-CodestarConnectionSource.html

---

### Task 2.1 — Choose a data store (데이터 스토어 선택)

- G-2.1-01 [분할제안] Task 2.1은 Skill 8개·소제목 15개·비교 표 8개·사실 97행·출처 66개로 학습문서 1개로는 과하다(컨트롤러 목표 출처 20~30개를 넘긴 것도 Skill 8개 규모 때문). 아래 5개 문서 분할을 제안한다(결정은 취합 세션).
  - 문서 ① 분석 저장소 선택·구성 — Skill 2.1.1 + 2.1.2 중 Redshift·EMR·Lake Formation: 노트 소제목 2~5·표 B·C, 사실 #1~#22, 출처 S1~S12.
  - 문서 ② 운영·NoSQL·스트림 저장소 선택·구성 — Skill 2.1.1 + 2.1.2 중 DynamoDB·KDS/MSK·RDS/Aurora·OpenSearch·S3 클래스·기타 DB: 소제목 1(표 A)·6~9·표 D, 사실 #23~#45·#94, 출처 S13~S28.
  - 문서 ③ 벡터·인메모리 — Skill 2.1.3 + 2.1.8: 소제목 10·15·표 H, 사실 #46~#57, 출처 S29~S36(+S18).
  - 문서 ④ 마이그레이션·원격 액세스 — Skill 2.1.4 + 2.1.5: 소제목 11·12·표 E·F, 사실 #58~#72·#95~#96, 출처 S37~S46·S61·S65.
  - 문서 ⑤ 잠금·오픈 테이블 형식 — Skill 2.1.6 + 2.1.7: 소제목 13·14·표 G, 사실 #73~#93·#97, 출처 S47~S64·S66.
  - 이유: 문서당 출처 약 10~16개·사실 약 12~25행으로 CLF 학습문서 규모와 비슷해지고, 시험 패턴(저장소 선택 / 이동·원격 접근 / 잠금 / 오픈 테이블·벡터)이 문서 경계와 맞는다. 대안으로 ①②를 하나로 합치면 한 문서에 출처 28개가 몰려 권장하지 않는다.
  - 여러 문서에서 재사용되는 출처: S1(Redshift 전반)·S18(DAX: ②·③)·S33(벡터 DB 선택: ③·④)·S61(Spectrum·S3 Tables: ④·⑤)·S55·S60(Iceberg·S3 Tables: ⑤).
  - 문항 후보 재배치 제안: 후보 1→②, 후보 2→③, 후보 3→④, 후보 4·5→⑤. 후보가 없는 Skill(2.1.2 Redshift/EMR/LF, 2.1.4, 2.1.8)은 사실 행에서 취합 세션이 파생.
  - 확인 시도: 노트 소제목별 출처·사실 행 매핑 점검. 후속: 취합 세션이 분할 확정 후 문서별 출처 재번호 부여.
  - 근거 URL (컨트롤러 보강): 구조·범위 판단 항목(외부 문서 인용 없음). 근거 기준: 공식 가이드 https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain2.html 및 tasks/2-1.md 출처 목록

- G-2.1-02 [분할제안] 인접 Task와의 경계 중복(노트는 2.1 관점으로 최소 기술).
  - Redshift 분산 스타일·정렬 키(2.1.2) ↔ Skill 2.4.1(스키마 설계)·2.4.5(인덱싱·파티셔닝). DynamoDB 키·인덱스 설계(2.1.2) ↔ 2.4.1.
  - S3 스토리지 클래스(노트에는 Intelligent-Tiering·Standard-IA만 2행) ↔ 2.3.2·2.3.3. DynamoDB TTL·S3 버전 관리 ↔ 2.3.4. Redshift COPY/UNLOAD ↔ 2.3.1. Glue Data Catalog·크롤러 ↔ 2.2. Bedrock Knowledge Base 벡터화 ↔ 2.4.6(2.1.8 "벡터 인덱스 유형"과 인접).
  - 확인 시도: 가이드 domain2 페이지(https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain2.html)의 Task 2.1~2.4 Skill 전문 대조.
  - 후속: 2.2·2.3·2.4 담당 노트와 취합할 때 중복 정리.

- G-2.1-03 [개명·종료] AWS Snowball Edge는 신규 고객에게 더 이상 제공되지 않고 Snow Family 장치를 신규로 주문할 수 없다(노트 사실 #63, S40). 2025-10-13 "AWS Service Availability Updates"가 Snowball Edge Compute Optimized·Storage Optimized를 "Nov 7, 2025부터 신규 고객 접근 불가(maintenance)" 목록에 올렸다(노트 사실 #95~#96, S65: https://aws.amazon.com/about-aws/whats-new/2025/10/aws-service-availability/).
  - 상충 위험: 오래된 AWS 백서(https://docs.aws.amazon.com/whitepapers/latest/overview-aws-cloud-data-migration-services/aws-managed-migration-tools.html)는 Snow Family를 여전히 일반 마이그레이션 도구로 소개한다(인터넷 전송이 1주 이상 걸리면 Snow 고려). 가이드 Skill 2.1.4의 예시는 Transfer Family뿐이고 Snow는 Skill 문구에 없다.
  - 확인 시도: What's New 원문과 Snowball Edge availability change 문서를 직접 읽음.
  - 후속: 문항에서 Snow를 정답으로 쓰지 말고 오답/최신성 함정으로만 사용.

- G-2.1-04 [개명·종료] 독립 서비스 "Amazon Glacier"도 같은 공지(2025-10-13)에서 2025-11-07부터 신규 고객 접근 불가(maintenance) 목록에 올랐다. 공지 목록에 S3 스토리지 클래스 항목은 없다. 노트에는 목록 포함 사실만 기록(사실 #95~#96, S65). "Amazon Glacier 서비스 vs S3 Glacier 스토리지 클래스" 설명은 Task 2.3 영역이라 미기재.
  - 확인 시도: What's New 페이지 원문 직접 읽음.
  - 후속: Task 2.3 담당 노트와 용어 구분 합의.
  - 근거 URL 보강(컨트롤러, 2026-10-19 열람·인용문 원문 확인): https://aws.amazon.com/about-aws/whats-new/2025/10/aws-service-availability/ (maintenance 목록에 Amazon Glacier·Amazon S3 Object Lambda 포함 확인)

- G-2.1-05 [개명·종료] Redshift 노드 체계 변경. (a) RG(Graviton) 노드 신규 — 2026-05 발표(https://aws.amazon.com/about-aws/whats-new/2026/05/amazon-redshift-rg-instances-powered-by-graviton/: "up to 2.4x as fast as previous generation RA3 instances, at 30% lower price per vCPU", 통합 데이터 레이크 엔진으로 Spectrum 별도 per-TB 과금 불필요), 2026-07 rg.large·rg.12xlarge 추가(https://aws.amazon.com/about-aws/whats-new/2026/07/amazon-redshift-adds-rg-large-12xlarge-instance-sizes/). (b) DS2 제공 종료. (c) Python UDF는 2026-06-30 이후 지원 중단 예고(문서 상단 배너, 사실 #4).
  - 노트는 RG를 "신규"로 표기(사실 #5·#69). 시험 문항·시판 교재는 RA3·DC2·Serverless만 다룰 수 있다.
  - 확인 시도: Redshift 클러스터 문서·What's New 검색 결과 읽음(What's New 2건은 검색 chunk만 사용, 노트 인용에는 미사용).
  - 후속: 문항에서 RG를 정답 근거로 삼을지는 취합 세션이 판단(시험 반영 시점 불명).

- G-2.1-06 [개명·종료] EMR 7.10.0부터 S3A가 EMRFS를 대체하는 기본 S3 커넥터(사실 #17, S8). 시험 문항은 여전히 "EMRFS" 용어를 쓸 가능성이 있다(추정).
  - 확인 시도: EMR 아키텍처 문서·EMRFS 문서 읽음. 후속: 학습문서에서 "EMRFS=EMR의 S3 접근" 개념을 병기.
  - 근거 URL 보강(컨트롤러, 2026-10-19 열람·인용문 원문 확인): https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-overview-arch.html ("Starting with the Amazon EMR 7.10.0 release, the S3A File System is the default file system" 확인)

- G-2.1-07 [개명·종료] RDS Performance Insights는 2026-06-30에 end of life이며 Database Insights Advanced mode로 전환하라는 안내(노트 사실 #97, S66: https://repost.aws/knowledge-center/rds-mysql-slow-query). 락 대기 모니터링(Skill 2.1.6)에서 Performance Insights를 언급하는 자료(RDS PostgreSQL 복제 지연 KC, 슬로우 쿼리 KC 등)는 구버전일 수 있다.
  - 확인 시도: KC 2건 읽음. 노트에는 공지 사실만 기록하고 대체 제품(Database Insights) 상세는 미조사.
  - 후속: 필요하면 CloudWatch Database Insights 공식 문서 추가 조사.

- G-2.1-08 [상충] Redshift 격리 수준 기본값. c_serial_isolation.html: "SNAPSHOT isolation is the default isolation level when creating provisioned clusters and serverless workgroups"(노트 사실 #76 사용). r_BEGIN.html(https://docs.aws.amazon.com/redshift/latest/dg/r_BEGIN.html): "Though you can use any of the four transaction isolation levels, Amazon Redshift processes all isolation levels as serializable."
  - 확인 시도: 두 페이지 모두 읽음. BEGIN 문서가 오래된 문구일 가능성(추정).
  - 후속: 문항에서 "Redshift 기본 격리 = serializable"을 정답으로 쓰지 말 것.
  - 근거 URL 보강(컨트롤러, 2026-10-19 열람·인용문 원문 확인): https://docs.aws.amazon.com/redshift/latest/dg/c_serial_isolation.html (SNAPSHOT 기본 서술) · https://docs.aws.amazon.com/redshift/latest/dg/r_BEGIN.html (모든 격리 수준을 serializable로 처리한다는 서술)

- G-2.1-09 [상충] Redshift 구체화된 뷰 자동 새로 고침 우선순위. 같은 페이지(materialized-view-refresh.html)에 "Amazon Redshift prioritizes your workloads over autorefresh and might stop autorefresh"와 "Starting February 27, 2026, Auto REFRESH queries … are executed as user queries rather than background autonomic processes … same priority"가 공존(노트 사실 #67에 병기).
  - 확인 시도: 페이지 chunk 2회 확인. 후속: 문항은 "자동 새로 고침이 지연될 수 있다" 수준으로만 출제하거나 제외.
  - 근거 URL 보강(컨트롤러, 2026-10-19 열람·인용문 원문 확인): https://docs.aws.amazon.com/redshift/latest/dg/materialized-view-refresh.html (두 인용문 모두 같은 페이지에서 확인)

- G-2.1-10 [상충] Aurora 클러스터 볼륨 최대 크기. aurora-features-scalability.html: "up to a maximum of 256 TiB". AWS Database Blog(https://aws.amazon.com/blogs/database/is-amazon-rds-for-postgresql-or-amazon-aurora-postgresql-a-better-choice-for-me/): 128 TiB. DMS 마이그레이션 플레이북(High availability essentials): 64 TiB. 본문 미사용.
  - 확인 시도: 검색 chunk로 3개 출처 확인. 후속: 최신 공식 페이지 기준 256 TiB로 보이나 단정 보류, 문항에서 제외.
  - 근거 URL 보강(컨트롤러, 2026-10-19 열람·인용문 원문 확인): https://docs.aws.amazon.com/rds/latest/auroraextendedcontent/aurora-features-scalability.html (256 TiB) · https://docs.aws.amazon.com/dms/latest/sql-server-to-aurora-postgresql-migration-playbook/chap-sql-server-aurora-pg.hadr.essentials.html (64 TiB)

- G-2.1-11 [상충] Kinesis on-demand 처리량. quotas 페이지(service-sizes-and-limits.html): 신규 on-demand 스트림 기본 쓰기 4 MB/s·읽기 8 MB/s, 일부 리전은 최대 쓰기 10 GB/s·읽기 20 GB/s, 그 외 리전 200 MB/s·400 MB/s(노트 사실 #36은 기본값만 사용). Kinesis FAQ(https://aws.amazon.com/kinesis/data-streams/faqs/)는 "automatically scale up to 200 MB/second and 200,000 records per second for writes"(구버전 추정). 비용 백서(cost-modeling-data-lakes)도 200 MB/s burst.
  - 확인 시도: quotas·FAQ·백서 chunk 대조. 후속: 문항에서 on-demand 최대치는 쓰지 말고 기본값(4/8 MB/s)만 사용.

- G-2.1-12 [상충] RDS 읽기 복제본 최대 개수. RDS FAQ(https://aws.amazon.com/rds/faqs/)·CLI 문서: MySQL·MariaDB·PostgreSQL 15개, Oracle·SQL Server 5개. RDS 기능 페이지(https://aws.amazon.com/rds/features/read-replicas/): MySQL·PostgreSQL·MariaDB·SQL Server 15개, Oracle 5개. 본문 미사용(Aurora Replica 15개만 사용).
  - 확인 시도: 검색 chunk 3건 대조. 후속: 엔진별 개수는 문항에서 제외.

- G-2.1-13 [상충] pgvector optimized reads QPS 향상. "Retrievers for RAG workflows"(Prescriptive Guidance): up to 8 times. Aurora FAQ(aurora-faq-agentic-ai.html): up to 9x. 본문 미사용.
  - 확인 시도: 검색 chunk 2건. 후속: 문항에서 제외.
  - 근거 URL 보강(컨트롤러, 2026-10-19 열람·인용문 원문 확인): https://docs.aws.amazon.com/prescriptive-guidance/latest/retrieval-augmented-generation-options/rag-custom-retrievers.html ("up to 8 times") · https://docs.aws.amazon.com/rds/latest/auroraextendedcontent/aurora-faq-agentic-ai.html ("up to 9x")

- G-2.1-14 [상충] Prescriptive Guidance "Vector database options"(S33)는 Bedrock Knowledge Bases 지원 벡터 스토어 목록에 "Amazon EMR Serverless"를 넣었지만 Bedrock API 레퍼런스 StorageConfiguration(S36)의 허용값에는 없다. 같은 시리즈 "Retrievers for RAG workflows"도 OpenSearch Serverless를 "vector engine for Amazon EMR Serverless"로 표기. 오기로 추정(추정).
  - 확인 시도: 두 문서 직접 읽음. 후속: 노트는 S36 기준 사용. 문항에서 EMR Serverless를 벡터 스토어로 쓰지 말 것.
  - 근거 URL 보강(컨트롤러, 2026-10-19 열람·인용문 원문 확인): https://docs.aws.amazon.com/prescriptive-guidance/latest/choosing-an-aws-vector-database-for-rag-use-cases/vector-db-options.html · https://docs.aws.amazon.com/prescriptive-guidance/latest/retrieval-augmented-generation-options/rag-custom-retrievers.html ("vector engine for Amazon EMR Serverless") · https://docs.aws.amazon.com/bedrock/latest/APIReference/API_agent_StorageConfiguration.html

- G-2.1-15 [상충] Redshift Serverless 최대 base capacity. 용량 문서(S2): 1024는 5개 리전 한정, 그 외 512. 가격 페이지(S3): "adjust this capacity from 4 to 1024 RPUs"(리전 한정 언급 없음). 노트 사실 #7은 용량 문서 사용.
  - 확인 시도: 두 페이지 직접 읽음. 후속: 문항에서 최대 RPU는 제외하거나 "리전에 따라 512 또는 1024"로 서술.
  - 근거 URL 보강(컨트롤러, 2026-10-19 열람·인용문 원문 확인): https://docs.aws.amazon.com/redshift/latest/mgmt/serverless-capacity.html · https://aws.amazon.com/redshift/pricing/ ("You can adjust this capacity from 4 to 1024 RPUs." 확인)

- G-2.1-16 [상충] S3 Tables 기본 compaction 전략. S3 FAQ: "By default, S3 Tables uses binpack compaction strategy". AWS Storage Blog(https://aws.amazon.com/blogs/storage/optimize-data-management-on-s3-tables-with-intelligent-tiering/): "Auto (Default)" — 정렬 순서가 정의된 테이블은 sort compaction, 없으면 binpack. 본문은 목표 파일 크기·스냅샷 기본값(사실 #88)만 사용.
  - 확인 시도: 검색 chunk 2건. 후속: 문항에서 기본 전략은 제외.
  - 근거 URL 보강(컨트롤러, 2026-10-19 열람·인용문 원문 확인): https://aws.amazon.com/s3/faqs/ ("By default, S3 Tables uses binpack compaction strategy." 확인)

- G-2.1-17 [불확실] Skill 2.1.8 "서비스별 벡터 인덱스 지원"의 범위. 공식 문서로 확인된 것: pgvector(IVFFlat·HNSW), DocumentDB(HNSW·IVFFlat), OpenSearch(HNSW: NMSLIB·Faiss·Lucene / IVF: Faiss), MemoryDB(FLAT·HNSW). 확인하지 못한 것: S3 Vectors·Neptune Analytics·Bedrock Knowledge Bases·OpenSearch Serverless 벡터 컬렉션의 인덱스 알고리즘 노출 여부 → 노트 표 H의 해당 칸은 "—".
  - 확인 시도: vector-db-options, OpenSearch Serverless 개요·벡터 검색 페이지, Bedrock StorageConfiguration 읽음.
  - 후속: 필요 시 S3 Vectors·Neptune Analytics 사용자 가이드 추가 조사.
  - 근거 URL 보강(컨트롤러, 2026-10-19 열람·인용문 원문 확인): 근거 출처: tasks/2-1.md 출처 목록 S29~S36(각 URL 수록) · https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain2.html

- G-2.1-18 [불확실] IVF vs HNSW의 메모리·인덱싱 시간 트레이드오프를 서술한 AWS 공식 prose를 확인하지 못했다. OpenSearch 프로젝트 문서(3자, https://docs.opensearch.org/latest/search-plugins/knn/knn-index/)에 "If you want to use less memory and increase indexing speed as compared to HNSW while maintaining similar query quality, you should evaluate IVF."와 "If memory is not a concern, HNSW offers a strong query latency/query quality trade-off."가 있다 [3자, 숫자 근거 아님]. AWS Big Data Blog(S35) 표(Faiss-IVF: Training Required Yes·Indexing latency Lowest·Query Latency & Quality "Low latency & low quality"·Memory Medium / Faiss-HNSW: Memory High)는 표 형식이라 인용 불가. Well-Architected Generative AI Lens(https://docs.aws.amazon.com/wellarchitected/latest/generative-ai-lens/genperf04-bp01.html)는 "hierarchical navigable small world (HNSW) for high accuracy, inverted file index (IVF) for balance, and product quantization (PQ) for compact storage"로 요약(본문 미사용).
  - 확인 시도: 위 4개 문서 chunk 대조. 노트는 AWS 문서로 확인되는 항목만 사용: HNSW(메모리 상주 부담·구축 느림·훈련 불필요·recall/성능 우수), IVFFlat(데이터 선적재·probes로 recall 조정).
  - 후속: 문항에서 "IVF는 메모리가 적다/HNSW는 메모리가 많다"를 정답 근거로 삼을 때는 추가 AWS 공식 근거 확보 필요.

- G-2.1-19 [불확실] Skill 문구가 모호해 "무엇을 묻는지" 공식 근거로 확정할 수 없는 항목.
  - Skill 2.1.2 "Lake Formation 구성(액세스 패턴별)": 가장 가까운 근거는 권한 모델·LF-TBAC·hybrid access mode(S11·S12). 데이터 필터(행/셀) 설정 절차·교차 계정 공유 설정 상세는 요약만 기술.
  - Skill 2.1.6 "데이터 액세스 방지하기 위해 잠금 관리(예: Redshift·RDS)": 가장 가까운 근거는 Redshift LOCK·격리 수준·STV_LOCKS(S47~S51), RDS PostgreSQL Lock:transactionid(S52), MySQL error 1205(S53). 다른 해석(예: S3 Object Lock 등 객체 잠금)은 조사하지 않았다.
  - Skill 2.1.1 안의 "Lake Formation / EMR" 포지션: 공식 문서상 Lake Formation은 저장소가 아니라 거버넌스(S11), EMR은 처리 클러스터이며 스토리지 선택(HDFS vs S3)이 쟁점(S8·S9).
  - 확인 시도: 가이드 domain2 페이지(Knowledge 항목 없음)·관련 서비스 문서 대조. 후속: 취합 세션이 문항 범위 확정.
  - 근거 URL 보강(컨트롤러, 2026-10-19 열람·인용문 원문 확인): https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain2.html (Skill 2.1.1·2.1.2·2.1.6 원문)

- G-2.1-20 [확인필요] RDS/Aurora "인덱스"(Skill 2.1.2 구성 요소): 인덱스 설계 일반 지침을 공식 문서에서 찾지 못했다(슬로우 쿼리 KC https://repost.aws/knowledge-center/rds-mysql-slow-query가 원인 목록에 "inadequate indexing"을 언급하는 수준). 노트 본문 미기재.
  - 확인 시도: RDS 모범 사례·슬로우 쿼리 KC 검색. 후속: 필요 시 RDS for MySQL/PostgreSQL 모범 사례 문서 추가 조사.

- G-2.1-21 [확인필요] Transfer Family AS2의 대상 저장소: "Configuring AS2"(https://docs.aws.amazon.com/transfer/latest/userguide/create-b2b-server.html) 표에 "Support for Amazon S3 Yes / Support for Amazon EFS No"로 되어 있으나 표 셀이라 인용 불가. 노트는 S37 원문 그대로 "S3 또는 EFS ↔ 프로토콜"로만 기술.
  - 확인 시도: AS2 구성 문서 chunk 확인. 후속: 문항에서 AS2↔EFS 조합 금지.

- G-2.1-22 [확인필요] 가이드 "In-Scope AWS Services" 페이지는 URL을 확보하지 못해 읽지 못했다. 컨트롤러 프롬프트의 "범위 내 목록의 DocumentDB·Neptune·Keyspaces·MemoryDB" 포함 여부는 미검증이며, 해당 4개 서비스 포지션은 각 서비스 공식 소개(S27·S28·S29·S33)만 사용했다.
  - 확인 시도: 가이드 appendix URL 추정 호출(메인 가이드로 리다이렉트됨)·검색 2회. 후속: 컨트롤러가 가이드 In-Scope 페이지 URL을 알고 있으면 대조.
  - 근거 URL 보강(컨트롤러, 2026-10-19 열람·인용문 원문 확인): https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-in-scope-services.html (컨트롤러가 확보 — G-0-11 참조)

- G-2.1-23 [확인필요] 조사했으나 노트에 넣지 않은(보류) 사실 — 출처는 확보됨, 필요하면 취합 세션이 추가.
  - MSK Express brokers: "Express brokers eliminate the need to provision or manage any storage resources."(https://docs.aws.amazon.com/msk/latest/developerguide/msk-broker-types-express.html).
  - OpenSearch Serverless 컬렉션 유형 3종(검색·시계열·벡터 검색), 생성 후 변경 불가(https://docs.aws.amazon.com/opensearch-service/latest/developerguide/serverless-overview.html).
  - Lake Formation 데이터 필터(열·행·셀 수준)(https://docs.aws.amazon.com/lake-formation/latest/dg/data-filtering.html).
  - Redshift 페더레이션 버전 요건(RDS/Aurora PostgreSQL 9.6 이상, MySQL 5.6 이상)은 S42에 있으나 노트 미기재.
  - Keyspaces 용량 모드(on-demand 기본 / provisioned): https://docs.aws.amazon.com/help-panel/keyspaces/latest/console/hp-resource-mgmt-read-write-capacity.html.
  - 조사하지 못한 항목: Aurora 외 소스(RDS·DynamoDB)별 zero-ETL, Redshift 인터리브 정렬 키 선택 기준, Redshift MV의 Spectrum·스트리밍 수집 제약.
  - 확인 시도: 각 URL chunk 확인. 후속: 문서 분할 시 해당 문서에 필요한 것만 추가.

- G-2.1-24 [확인필요] 표 형식·리전별 가격이라 노트에서 제외한 수치: S3 Tables 유지 관리 기본값 표(https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-tables-considerations.html: targetFileSizeMB 512MB/최소 64MB, minimumSnapshots 1, maximumSnapshotAge 120 hours/최소 1 hour, unreferencedDays 3 days, nonCurrentDays 10 days)는 표 셀이라 인용 불가 → S3 FAQ 문장(사실 #88·#89)으로 대체. unreferencedDays·nonCurrentDays 값은 노트에 없음. Redshift Serverless RPU 단가는 리전별이라 제외.
  - 확인 시도: 해당 페이지 chunk 확인. 후속: 필요하면 취합 세션이 FAQ·Big Data Blog 문장으로 보강.

- G-2.1-25 [확인필요] 인용 자체 점검 메모(컨트롤러 자동 대조 참고): 노트의 인용 168개를 각 URL의 HTML을 가져와 태그 제거·공백 정규화한 텍스트와 대조해 전부 일치함을 확인했다(15단어 이하 확인 포함). 링크 텍스트에 걸쳐 문장 부호 앞뒤 공백이 달라질 수 있는 구간은 인용에서 피했다(예: 사실 #93·#94). 표 셀 정보는 인용하지 않았다.
  - 후속: 컨트롤러 대조에서 불일치가 나오면 해당 행만 삭제해도 본문 서술은 다른 행·출처로 유지됨(핵심 개념은 [S번호]로만 연결).
  - 근거 URL (컨트롤러 보강): 구조·범위 판단 항목(외부 문서 인용 없음). 근거 기준: 공식 가이드 https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain2.html 및 tasks/2-1.md 출처 목록

- G-2.1-26 [수정제안] `flutter_app/assets/exam_guides/DEA-C01.json`의 Task 2.1은 skills 8개·knowledge [] 모두 공식 영문 가이드 v1.1 domain2 페이지와 일치한다(수정 불필요).
  - 참고: 공식 문구는 "Hierarchical Navigable Small Worlds [HNSW]"(복수)이고 AWS 서비스 문서는 "Hierarchical Navigable Small World (HNSW)"(단수)로 표기한다.
  - 확인 시도: 가이드 domain2 페이지 직접 읽어 JSON과 대조. 후속: 학습문서에서 표기를 통일할 때 유의(수정 필요 아님).
  - 근거 URL (컨트롤러 보강): 구조·범위 판단 항목(외부 문서 인용 없음). 근거 기준: 공식 가이드 https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain2.html 및 tasks/2-1.md 출처 목록

### Task 2.2 — Understand data cataloging systems (데이터 카탈로그 시스템 이해)

- G-2.2-01 [상충] 크롤러 과금 단위·최소 청구 시간
  - 확인 시도: Glue 가격 페이지(https://aws.amazon.com/glue/pricing/)는 "billed by the second"와 "$0.44 per DPU-hour"만 있고 크롤러 최소 청구 시간은 읽은 범위에 없음. Glue FAQ(https://aws.amazon.com/glue/faqs/)는 "You will pay an hourly rate, billed per second, for the crawler run with a 10-minute minimum." 백서 "Cost optimization in analytics services"(https://docs.aws.amazon.com/whitepapers/latest/cost-modeling-data-lakes/cost-optimization-in-analytics-services.html)도 "10-minute minimum duration for each crawl". EMR 문서(https://docs.aws.amazon.com/emr/latest/ReleaseGuide/emr-hive-metastore-glue.html)는 "an hourly rate billed per minute for AWS Glue ETL jobs and crawler runtime".
  - 후속: 가격 페이지 Crawlers 탭의 최신 문구로 확정. 본문에는 $0.44/DPU-hour(초 단위)만 사용했고 최소 청구 시간은 쓰지 않았다.

- G-2.2-02 [상충] Data Catalog 과금 "메타데이터 객체" 정의
  - 확인 시도: EMR 문서(emr-hive-metastore-glue.html)는 "An object in the Data Catalog is a table, partition, or database." 가격 페이지(https://aws.amazon.com/glue/pricing/)는 "a table, table version, partition, partition indexes, statistics, database, or catalog".
  - 후속: 가격 페이지가 더 최신·상세하다고 판단해 본문은 가격 페이지 기준. EMR 문서는 갱신이 늦은 것으로 보이나 확정하지 못함.
  - 근거 URL 보강(컨트롤러, 2026-10-19 열람·인용문 원문 확인): https://docs.aws.amazon.com/emr/latest/ReleaseGuide/emr-hive-metastore-glue.html ("An object in the Data Catalog is a table, partition, or database." 확인) · https://aws.amazon.com/glue/pricing/

- G-2.2-03 [확인필요] 크롤러 지원 오픈 테이블 포맷의 버전 숫자
  - 확인 시도: https://docs.aws.amazon.com/glue/latest/dg/crawler-data-stores.html 표에 Delta Lake 4.0, Apache Iceberg 1.10, Apache Hudi 0.14로 표기.
  - 후속: 버전 숫자는 자주 바뀔 수 있어 본문에서 인용하지 않았다. 학습문서 저작 시 "Delta/Iceberg/Hudi 지원" 수준으로만 쓰거나 저작 시점에 재확인.

- G-2.2-04 [불확실] Skill 2.2.2 "Build and reference a technical data catalog"가 정확히 묻는 활동
  - 확인 시도: dea-01-revisions 페이지(https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-revisions.html)는 문구가 "data catalog"에서 "technical data catalog"로 바뀐 사실만 보여주고 의도는 설명하지 않는다. 가장 가까운 공식 근거는 Glue Data Catalog를 EMR Hive 메타스토어로 지정(emr-hive-metastore-glue.html), Athena 외부 Hive 메타스토어 커넥터(connect-to-data-source-hive-connecting-athena-to-an-apache-hive-metastore.html), Redshift Spectrum 외부 스키마(c-spectrum-external-schemas.html). Hive 메타스토어를 Glue Data Catalog로 마이그레이션하는 절차는 공식 블로그(https://aws.amazon.com/blogs/big-data/upgrade-amazon-emr-hive-metastore-from-5-x-to-6-x/)에서만 확인했고 개발자 가이드 페이지는 찾지 못했다.
  - 후속: 취합 세션이 "마이그레이션" 비중을 정하려면 Glue 개발자 가이드의 Hive 메타스토어 마이그레이션 페이지를 별도로 확인.

- G-2.2-05 [불확실] Glue ETL 잡이 외부 Hive 메타스토어를 직접 참조하는 방식
  - 확인 시도: Glue 연결 유형 문서(connection-properties.html)에서 Hive 메타스토어용 연결 유형을 찾지 못함. 크롤러 지원 목록에도 없음.
  - 후속: 시험 범위에서 중요하면 Glue 문서에서 Hive 메타스토어 연동 항목을 재검색.
  - 근거 URL (컨트롤러 보강): 구조·범위 판단 항목(외부 문서 인용 없음). 근거 기준: 공식 가이드 https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain2.html 및 tasks/2-2.md 출처 목록

- G-2.2-06 [확인필요] SageMaker Catalog 세부 기능을 본문에 넣지 않음
  - 확인 시도: AWS News Blog "New business metadata features in Amazon SageMaker Catalog…"(https://aws.amazon.com/blogs/aws/new-business-metadata-features-in-amazon-sagemaker-catalog-to-improve-discoverability-across-organizations/)에서 컬럼 수준 메타데이터 폼, 용어 메타데이터 강제 규칙(glossary term enforcement), AI 생성 메타데이터 제안을 확인했다. 또한 "Manage and govern the catalog"(catalog-iam-manage-govern.html)와 access control patterns(https://docs.aws.amazon.com/sagemaker-unified-studio/latest/adminguide/security-accesss-control-patterns.html)에서 관리형 자산(Lake Formation 관리 Glue 테이블·Redshift 테이블/뷰)의 구독 자동 승인과 수동 승인 시 EventBridge 워크플로를 확인했다. 출처 수를 줄이려 본문에는 반영하지 않았다.
  - 후속: 취합 세션이 2.2.6/4.5.6 문서를 쓸 때 위 두 페이지를 근거로 추가.

- G-2.2-07 [분할제안] Skill 2.2.6을 SageMaker Unified Studio 관련 Skill과 묶는 안
  - 확인 시도: revisions 페이지의 신규 Skill 목록에 2.2.6, 4.1.7(도메인·도메인 유닛·프로젝트), 4.5.6(SageMaker Catalog 프로젝트로 데이터 접근 관리)이 있고 2.4.4도 SageMaker Catalog를 언급한다.
  - 후속: 2.2.6 + 4.1.7 + 4.5.6(+2.4.4 일부)을 'SageMaker Unified Studio / Catalog' 문서 1개로 묶고, 2.2.1~2.2.5는 'Glue Data Catalog·크롤러·파티션·연결' 문서 1개로 두는 안을 제안(개념 중복 감소). 분량이 크면 2.2.3~2.2.4(크롤러·파티션)를 따로 떼는 것도 가능. 결정은 취합 세션.
  - 근거 URL (컨트롤러 보강): 구조·범위 판단 항목(외부 문서 인용 없음). 근거 기준: 공식 가이드 https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain2.html 및 tasks/2-2.md 출처 목록

- G-2.2-08 [개명·종료] 서비스명 표기 불일치
  - 확인 시도: Glue 가격 페이지는 "Amazon SageMaker Lakehouse"를 언급("The Data Catalog can be accessed from Amazon SageMaker Lakehouse…"), Glue 연결 문서(glue-connections.html)는 "Amazon SageMaker AI Unified Studio", SageMaker Unified Studio 문서는 "Amazon SageMaker Unified Studio"와 "lakehouse architecture"로 표기.
  - 후속: 개명 여부를 확인한 뒤 학습문서의 표기를 통일. 이 노트는 SageMaker Unified Studio 문서의 표기를 따랐다.
  - 근거 URL 보강(컨트롤러, 2026-10-19 열람·인용문 원문 확인): https://aws.amazon.com/glue/pricing/ ("The Data Catalog can be accessed from Amazon SageMaker Lakehouse" 확인) · https://docs.aws.amazon.com/glue/latest/dg/glue-connections.html ("Amazon SageMaker AI Unified Studio" 확인)

- G-2.2-09 [상충] IAM 기반 도메인 개수 제한의 범위
  - 확인 시도: https://docs.aws.amazon.com/sagemaker-unified-studio/latest/adminguide/working-with-domains.html은 "Only one IAM-based domain is available per AWS Account.", https://docs.aws.amazon.com/sagemaker-unified-studio/latest/adminguide/iam-based-domains.html은 "Only one IAM-based domain is available per AWS Account per region."
  - 후속: Skill 2.2.6 범위 밖(4.1.7 관련). 4.1.7 담당 세션에 전달. 본문 2-2.md에는 이 숫자를 쓰지 않았다.

- G-2.2-10 [확인필요] Glue Data Catalog의 Iceberg REST 엔드포인트·카탈로그 페더레이션·멀티 카탈로그 계층
  - 확인 시도: connect-glu-iceberg-rest.html, emr-multi-catalog.html, 카탈로그 페더레이션 블로그를 검색 결과로 확인했으나 DEA-C01 시험 범위(특히 2.2.2/2.1.7)에 해당하는지 판단할 근거가 없어 본문에 반영하지 않았다.
  - 후속: Skill 2.1.7(오픈 테이블 포맷) 담당 세션과 범위 조율.
  - 근거 URL (컨트롤러 보강): 구조·범위 판단 항목(외부 문서 인용 없음). 근거 기준: 공식 가이드 https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain2.html 및 tasks/2-2.md 출처 목록

- G-2.2-11 [확인필요] Athena 파티션 프로젝션의 타입·설정 상세
  - 확인 시도: https://docs.aws.amazon.com/athena/latest/ug/partition-projection-supported-types.html에서 enum·integer·date·injected 4가지 타입과 projection.columnName.* 속성을 확인했으나 출처 수를 줄이려 본문에는 반영하지 않았다.
  - 후속: 학습문서에서 프로젝션 설정 예시가 필요하면 이 페이지를 추가.

### Task 2.3 — Manage the lifecycle of data (데이터의 수명 주기 관리)

- G-2.3-01 [상충] Standard → Standard-IA/One Zone-IA 전환에 "30일 선행" 조건이 있는가
  - 확인 시도: re:Post Knowledge Center(https://repost.aws/knowledge-center/s3-lifecycle-configuration-rule)는 "You can't transition objects that you store for less than 30 days to the S3 Standard-IA or S3 One Zone-IA storage classes."라고 쓴다. S3 사용자 가이드 전환 페이지(https://docs.aws.amazon.com/AmazonS3/latest/userguide/lifecycle-transition-general-considerations.html)는 읽은 범위에서 이 조건 없이 128KB 기본 제외와 소스 클래스의 최소 보관 기간 과금만 서술하고, 스토리지 클래스 비교표(https://docs.aws.amazon.com/AmazonS3/latest/userguide/storage-class-intro.html)는 S3 Standard의 최소 보관 기간을 None으로 표기한다. 다른 KC(https://repost.aws/knowledge-center/s3-lifecycle-rule-glacier-storage)의 "must be in this class for 30 days before they transition to S3 Glacier"(Standard-IA → Glacier)는 사용자 가이드의 최소 보관 기간 규칙과 일치한다.
  - 후속: Standard → IA의 30일 선행 조건이 현행 규칙인지 확정하기 전까지 문항에서 단정하지 말 것. 2-3.md 본문에는 쓰지 않았다.

- G-2.3-02 [상충] 128KB 미만 객체 전환 제한의 적용 기준
  - 확인 시도: 사용자 가이드 전환 페이지(위 lifecycle-transition-general-considerations.html)는 "Starting September 2024, the default behavior prevents objects smaller than 128 KB from being transitioned to any storage class."와 "Configurations created before September 2024 retain the previous transition behavior unless you modify them."(구성 기준, 이전 동작은 Glacier Flexible Retrieval·Deep Archive만 허용)로 쓴다. KC(https://repost.aws/knowledge-center/s3-lifecycle-configuration-rule)는 "You can't transition objects that are smaller than 128 KB that you created after September 2024."(객체 생성 시점 기준)라고 쓴다. Lifecycle 문제 해결 페이지(https://docs.aws.amazon.com/AmazonS3/latest/userguide/troubleshoot-lifecycle.html)는 "doesn't transition objects that are smaller than 128 KB from the S3 Standard or S3 Standard-IA storage class to …"로 Intelligent-Tiering·Standard-IA·One Zone-IA 대상의 더 좁은 범위로 쓴다.
  - 후속: 본문은 사용자 가이드 전환 페이지(구성 생성·수정 시점 기준)로 작성했다. 문항에서는 "2024-09 이후 기본값이며 크기 필터로 허용 가능" 수준만 쓰고 객체 생성일 기준 표현은 피할 것.
  - 근거 URL 보강(컨트롤러, 2026-10-19 열람·인용문 원문 확인): https://docs.aws.amazon.com/AmazonS3/latest/userguide/lifecycle-transition-general-considerations.html (앞의 두 인용문을 원문에서 확인)

- G-2.3-03 [상충] 스토리지 클래스 비교표의 표기 차이: Glacier Flexible Retrieval·Deep Archive의 40KB·가용성·조회 요금
  - 확인 시도: S3 비용 최적화 페이지(https://aws.amazon.com/s3/cost-optimization/)의 표는 "Minimum capacity charge per object … 128 KB 128 KB 128 KB 40 KB 40 KB"로 40KB를 최소 용량 청구로, Flexible Retrieval·Deep Archive 가용성을 99.99%로만 적는다. 사용자 가이드(위 storage-class-intro.html)의 표는 두 클래스의 최소 청구 객체 크기를 NA로 두고 "S3 Glacier Flexible Retrieval requires 40 KB of additional metadata for each archived object."(32KB는 Glacier 요금, 8KB는 Standard 요금)로 설명하며 가용성은 "99.99% (after you restore objects)"로 적는다. 또 사용자 가이드 표는 Flexible Retrieval에 "Per-GB retrieval fees apply."라고 쓰는데, Glacier 제품 페이지(https://aws.amazon.com/s3/storage-classes/glacier/)는 "free bulk retrievals"라고 쓴다. 반면 복원(검색) 시간은 Glacier 제품 페이지, S3 SDK의 RestoreObject 설명(https://docs.aws.amazon.com/sdk-for-kotlin/api/latest/s3/aws.sdk.kotlin.services.s3/-s3-client/restore-object.html: Expedited 1–5분, Standard 3–5시간(Flexible Retrieval)·12시간(Deep Archive)), 레거시 Glacier 볼트 문서 사이에서 수치 상충을 찾지 못했다.
  - 후속: 2-3.md 사실 행 41·44·51·136·139가 두 서술을 모두 기록했다. 문항은 "객체당 40KB 오버헤드"로 쓰고 "최소 청구 크기 40KB"는 피하며, Bulk 복원 무료 여부는 Glacier 제품 페이지를 근거로 쓸 것.
  - 근거 URL 보강(컨트롤러, 2026-10-19 열람·인용문 원문 확인): https://docs.aws.amazon.com/AmazonS3/latest/userguide/storage-class-intro.html (40 KB 주석·"99.99% (after you restore objects)"·"Per-GB retrieval fees apply." 표 셀 확인)

- G-2.3-04 [상충] S3 Replication Time Control(RTC)의 SLA 수치
  - 확인 시도: 복제 개요(https://docs.aws.amazon.com/AmazonS3/latest/userguide/replication.html)는 "S3 RTC replicates 99.99 percent of new objects stored in Amazon S3 within 15 minutes (backed by a service-level agreement)"라고 써서 99.99%가 SLA 대상처럼 읽힌다. S3 FAQ(https://aws.amazon.com/s3/faqs/)는 설계 목표를 "99.99% of objects within 15 minutes"로, SLA 약정을 "backed by a Service Level Agreement (SLA) commitment that 99.9% of objects will be replicated in 15 minutes for each replication region pair during any billing month"로 구분한다.
  - 후속: 2-3.md 사실 행 108은 복제 개요 문구를 인용했다. 학습문서·문항에서는 "목표 99.99%, SLA 약정 99.9%"를 구분하고, SLA 수치를 정답 근거로 쓰려면 FAQ를 근거로 쓸 것.

- G-2.3-05 [상충] DynamoDB TTL 삭제 시점: "곧(Shortly after)" vs "며칠 이내"
  - 확인 시도: 개발자 가이드(https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/TTL.html)는 "typically within a few days after their expiration"이라고 쓴다. 콘솔 도움말(https://docs.aws.amazon.com/help-panel/amazondynamodb/latest/console/hp-ttl.html)은 "Shortly after the date and time of the specified timestamp, DynamoDB deletes the item from your table"와 "Expired items are typically deleted within a few days of their expiration time"를 같은 페이지에 함께 쓴다. KC(https://repost.aws/knowledge-center/dynamodb-expired-ttl-not-deleted)는 best-effort 삭제와 "with an expiration of no more than five years in the past" 조건을 덧붙인다.
  - 후속: 본문은 "만료 후 보통 며칠 이내, 시각 보장 없음"으로 썼다. 문항에서 "만료 즉시/수 분 이내 삭제"를 정답 근거로 쓰지 말 것.

- G-2.3-06 [상충] 'Amazon Glacier'(별도 서비스) vs 'S3 Glacier'(스토리지 클래스) 명칭 혼용
  - 확인 시도: 사용자 가이드 storage-class-intro.html은 "When you use S3 Glacier storage classes, your objects remain in Amazon S3."라며 별도 Amazon Glacier 서비스와 구분한다. 같은 가이드의 전환 페이지(lifecycle-transition-general-considerations.html)는 "Deleting data that is archived to Amazon Glacier doesn't incur charges …"처럼 S3 클래스를 "Amazon Glacier"로 부른다. 시험 가이드 서비스 목록(https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-in-scope-services.html)은 Storage에 "Amazon S3 Glacier"를 적고(같은 목록에 "Amazon S3 Tables"가 두 번 나온다), 별도 Glacier 볼트 API 문서(https://docs.aws.amazon.com/amazonglacier/latest/dev/api-initiate-job-post.html)는 Expedited를 "typically made available within 1–5 minutes"로 설명하며 계속 존재한다.
  - 후속: 학습문서는 "S3 Glacier Instant Retrieval / Flexible Retrieval / Deep Archive = S3 스토리지 클래스"로 통일하고 별도 Glacier 볼트 서비스는 범위 밖으로 명시할 것. 시험 가이드의 "Amazon S3 Glacier"가 클래스 총칭인지는 공식 근거로 확정하지 못했다.
  - 근거 URL 보강(컨트롤러, 2026-10-19 열람·인용문 원문 확인): https://docs.aws.amazon.com/AmazonS3/latest/userguide/storage-class-intro.html ("your objects remain in Amazon S3") · https://docs.aws.amazon.com/AmazonS3/latest/userguide/lifecycle-transition-general-considerations.html ("Deleting data that is archived to Amazon Glacier doesn't incur charges")

- G-2.3-07 [상충] Redshift COPY/UNLOAD 클라이언트 측 암호화: 종료 공지 vs 계속 서술하는 하위 문서
  - 확인 시도: COPY 페이지(https://docs.aws.amazon.com/redshift/latest/dg/r_COPY.html) 상단 공지는 2026-04-30 이후 클라이언트 측 암호화를 쓸 수 없다고 한다. 반면 암호화 로드 페이지(https://docs.aws.amazon.com/redshift/latest/dg/c_loading-encrypted-files.html)는 여전히 "provide the root key value using the MASTER_SYMMETRIC_KEY parameter and include the ENCRYPTED option"으로 사용법을 안내하고 지원 목록에도 클라이언트 측 대칭 루트 키를 둔다.
  - 후속: 본문은 종료 공지를 우선해 기록했다(사실 행 3·4·5). 문항에서 클라이언트 측 암호화를 정답으로 쓰지 말 것.

- G-2.3-08 [불확실] Skill 2.3.5 "비즈니스 및 법적 요구 사항을 충족하기 위해 데이터 삭제"가 정확히 묻는 범위
  - 확인 시도: 시험 가이드 Skill 문구(https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain2.html)에는 세부 설명이 없고, 데이터 레이크 전 계층(S3·카탈로그·Iceberg·Redshift·백업)에 걸친 삭제 절차를 한 곳에서 정의한 공식 가이드는 찾지 못했다(Well-Architected Lens 3.1은 원칙 수준이다). 본문은 다음 공식 근거를 조합했다: S3 Object Lock(https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lock.html), AWS Backup Vault Lock(https://docs.aws.amazon.com/aws-backup/latest/devguide/vault-lock.html), Athena Iceberg DELETE(https://docs.aws.amazon.com/athena/latest/ug/querying-iceberg-delete.html)와 VACUUM(https://docs.aws.amazon.com/athena/latest/ug/querying-iceberg-data-optimization.html), S3 Tables 유지 관리(https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-tables-maintenance.html), Redshift VACUUM(https://docs.aws.amazon.com/redshift/latest/dg/t_Reclaiming_storage_space202.html), Well-Architected Data Analytics Lens 3.1(https://docs.aws.amazon.com/wellarchitected/latest/analytics-lens/best-practice-3.1-privacy-by-design..html), S3 Find and Forget 블로그. 보존(WORM) 중심인지 삭제(erasure) 중심인지, GDPR 같은 규정 이름이 시험에 나오는지는 공식 근거로 확정할 수 없다.
  - 후속: 취합 세션은 문항을 Object Lock·Lifecycle·Iceberg DELETE+VACUUM처럼 공식 문서가 직접 뒷받침하는 항목 중심으로 만들고, 규정 이름(SEC 17a-4 등)을 정답 근거로 쓰지 말 것.

- G-2.3-09 [확인필요] S3 Find and Forget 솔루션의 현행 상태
  - 확인 시도: AWS Big Data Blog(https://aws.amazon.com/blogs/big-data/handling-data-erasure-requests-in-your-data-lake-with-amazon-s3-find-and-forget/)에는 "This post was reviewed and updated for accuracy."(2024년 2월 표기)만 있고 솔루션의 지원·버전 상태는 확인하지 못했다. 2-3.md 사실 행 106은 이 블로그의 삭제 절차 서술(행 제거 → 새 버전 쓰기 → 이전 버전 삭제)만 인용했다.
  - 후속: 학습문서에서 솔루션 이름을 선택지로 쓰기 전에 현행 상태를 확인.

- G-2.3-10 [확인필요] S3 관련 사실 중 본문에 넣지 않은 것
  - 확인 시도: (1) Lifecycle 규칙 변경 반영 지연: 전환 페이지의 "rule policy updates can take up to 15 minutes to propagate"(https://docs.aws.amazon.com/AmazonS3/latest/userguide/lifecycle-transition-general-considerations.html). (2) 디렉터리 버킷(S3 Express One Zone)의 Lifecycle 제한: S3 SDK 문서 "Lifecyle configurations for directory buckets only support expiring objects and cancelling multipart uploads."(https://docs.aws.amazon.com/sdk-for-kotlin/api/latest/s3/aws.sdk.kotlin.services.s3/-s3-client/put-bucket-lifecycle-configuration.html). (3) S3 Tables 유지 관리 기본값 표(https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-tables-considerations.html): 컴팩션 targetFileSizeMB 512MB(최소 64MB), unreferencedDays 3일, nonCurrentDays 10일. 본문에는 스냅샷 관리 기본값(최소 1개, 120시간)만 넣었다. (4) Intelligent-Tiering 월 모니터링·자동화 요금의 금액은 확인하지 않았다.
  - 후속: 취합 세션이 2.3.2/2.3.5 문서에서 필요하면 위 URL을 근거로 추가.

- G-2.3-11 [확인필요] Redshift·RDS·DynamoDB 관련 사실 중 본문에 넣지 않은 것
  - 확인 시도: (1) COPY는 원자적·트랜잭션: "The COPY command is atomic and transactional."(https://docs.aws.amazon.com/redshift/latest/dg/copy-usage_notes-multiple-files.html). (2) UNLOAD의 `PARTITION BY`·Parquet 예제(https://docs.aws.amazon.com/redshift/latest/dg/r_UNLOAD_command_examples.html). (3) Redshift Multi-AZ: 관리 가이드의 "RPO is typically is zero"(https://docs.aws.amazon.com/redshift/latest/mgmt/test-cluster-multi-az.html)와 FAQ의 "RTO with Amazon Redshift Multi-AZ deployments is under 60 seconds or less"(https://aws.amazon.com/redshift/faqs/; 출시 전 테스트 기준 표현). (4) RDS 시점 복구: "restore your database to any second within your backup retention period"(https://docs.aws.amazon.com/AmazonRDS/latest/gettingstartedguide/managing-backup-restore.html). (5) DynamoDB TTL의 5년 이전 타임스탬프 조건과 best-effort(G-2.3-05의 KC).
  - 후속: 취합 세션이 해당 문서를 쓸 때 위 URL을 근거로 추가.

- G-2.3-12 [확인필요] 삭제·보존 프로세스 관련 사실 중 본문에 넣지 않은 것
  - 확인 시도: Well-Architected Data Analytics Lens 15.4(https://docs.aws.amazon.com/wellarchitected/latest/analytics-lens/best-practice-15.4-implement-data-retention-processes-to-remove-redundant-data-from-your-analytics-environment..html)는 "The data retention removal process should remove data from all buckets, sub-directories and prefixes."라며 삭제 감사 이력을 변경 불가 로그로 남기고 운영·UAT·개발 환경을 모두 포함하라고 권고한다. Athena Iceberg `VACUUM`의 기본값은 사용자 가이드 VACUUM 문 페이지(https://docs.aws.amazon.com/athena/latest/ug/vacuum-statement.html)에 명시돼 있다: "By default, this property is set to 432000 seconds (5 days)."(`vacuum_max_snapshot_age_seconds`), `vacuum_min_snapshots_to_keep` 기본 1, `vacuum_max_metadata_files_to_keep` 기본 100이며 고아 파일도 `vacuum_max_snapshot_age_seconds`보다 오래된 것만 제거한다. 2-3.md 본문은 Optimize Iceberg tables 페이지의 "files not in the current table state … older than the retention period" 표현까지만 인용했고 이 기본값은 넣지 않았다.
  - 후속: 삭제 요청 문항에서 Iceberg 물리 삭제 시점(기본 5일 보존)을 다루려면 위 VACUUM 문 페이지를 출처로 추가.
  - 근거 URL 보강(컨트롤러, 2026-10-19 열람·인용문 원문 확인): https://docs.aws.amazon.com/athena/latest/ug/querying-iceberg-data-optimization.html ("remove files not in the current table state that are also older than the retention period specified for the table" 확인)

- G-2.3-13 [확인필요] Redshift 노드 유형 "RG"
  - 확인 시도: 스냅샷 페이지(https://docs.aws.amazon.com/redshift/latest/mgmt/working-with-snapshots.html)가 "You can't disable automated snapshots for RG or RA3 node types."라고 쓰지만, "RG" 노드 유형의 정의·출시 여부는 확인하지 못했다.
  - 후속: Redshift 노드 유형 최신 목록 확인. 2-3.md 사실 행에는 RA3/RG 보존 범위를 쓰지 않았다.

- G-2.3-14 [개명·종료] Redshift COPY/UNLOAD 클라이언트 측 암호화 종료
  - 확인 시도: https://docs.aws.amazon.com/redshift/latest/dg/r_COPY.html 상단 공지: 신규 고객에게는 2025-04-30부터 닫혔고, 기존 사용자도 2026-04-30까지만 사용할 수 있으며, 서버 측 암호화 전환을 권고한다. 2-3.md 핵심 개념과 사실 행 3·4·5에 반영했다.
  - 후속: 학습문서에 "2026-04-30 이후 사용 불가"로 명시.

- G-2.3-15 [개명·종료] S3 Reduced Redundancy Storage 사용 비권장
  - 확인 시도: https://docs.aws.amazon.com/AmazonS3/latest/userguide/storage-class-intro.html: "We recommend not using this storage class. The S3 Standard storage class is more cost-effective." 2-3.md 핵심 개념과 사실 행 140에 반영했다.
  - 후속: 학습문서에서는 비교표에 넣지 않거나 비권장으로만 언급.

- G-2.3-16 [개명·종료] Amazon Redshift Python UDF 지원 종료 공지
  - 확인 시도: 모든 Redshift 문서 상단 공지 "Amazon Redshift will no longer support the use of Python UDFs after June 30, 2026."(예: https://docs.aws.amazon.com/redshift/latest/dg/r_COPY.html). 단계적으로 적용한다고 한다. Task 2.3 Skill과 직접 관련이 없어 본문에는 쓰지 않았다.
  - 후속: 변환·SQL 관련 Skill(1.x, 3.x) 담당 세션에 전달.

- G-2.3-17 [분할제안] Task 2.3을 학습문서 3편으로 나누는 안
  - 확인 시도: 2-3.md는 Skill 6개에 사실 144행·출처 34개로, 서비스 범위가 Redshift·S3·DynamoDB·RDS·AWS Backup·Athena Iceberg·S3 Tables에 걸친다.
  - 후속: (A) 2.3.1 Redshift COPY/UNLOAD를 소형 단독 문서(또는 Redshift 적재 문서에 병합), (B) 2.3.2+2.3.3+2.3.4 "S3 수명 주기·버전 관리·DynamoDB TTL"(스토리지 클래스 표 중심), (C) 2.3.5+2.3.6 "보존·삭제·복원성"(Domain 4 거버넌스 문서와 상호 링크). 결정은 취합 세션.
  - 근거 URL (컨트롤러 보강): 구조·범위 판단 항목(외부 문서 인용 없음). 근거 기준: 공식 가이드 https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain2.html 및 tasks/2-3.md 출처 목록

- G-2.3-18 [분할제안] 스토리지 클래스 비교표의 중복 저작 방지
  - 확인 시도: revisions 페이지(https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-revisions.html)에 Skill 2.1.3 "Apply storage services to appropriate use cases"가 있어 S3 스토리지 클래스 선택이 Task 2.1 문서와 겹칠 수 있다.
  - 후속: 클래스 비교표(2-3.md 핵심 개념, 사실 행 27–45·136–139)를 2.1.3 문서와 한 곳에서 관리하고 상호 링크.

### Task 2.4 — Design data models and schema evolution (데이터 모델 및 스키마 진화 설계)

- G-2.4-01 [불확실] Skill 2.4.3 예시에 "AWS SCT"가 남아 있으나 v1.1 개정 이력은 AWS Schema Conversion Tool(AWS SCT)을 범위 내 서비스 목록에서 제거된 서비스로 적는다. 범위 밖(out-of-scope) 목록에도 SCT는 없다(Migration and Transfer 범위 밖 항목은 AWS Mainframe Modernization, AWS Migration Hub). 범위 내 목록의 Migration and Transfer에는 AWS DMS(→ DMS Schema Conversion 포함)가 있다. 즉 "SCT를 시험이 직접 묻는가"는 공식 근거만으로 확정할 수 없다.
  - 확인 시도: 개정 이력 https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-revisions.html ("Services removed from the in-scope list" 항목에 SCT), 범위 내 https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-in-scope-services.html, 범위 밖 https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-out-of-scope-services.html, Skill 문구 https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain2.html#data-engineer-associate-01-domain2-task4
  - 후속: 취합 세션이 학습문서에서 DMS Schema Conversion을 중심으로 쓰고 SCT는 "DMS SC의 기반 엔진·DW 소스 변환 보조 도구" 정도로 가볍게 다룰지 결정. 노트 2.4.3 소제목은 두 도구를 모두 정리해 두었다.

- G-2.4-02 [불확실] Skill 2.4.2 "Address changes to the characteristics of data(데이터 특성에 대한 변경 사항 해결)"가 무엇을 묻는지 공식 문구만으로 확정 불가. 노트는 스키마 진화·드리프트(크롤러 정책, Schema Registry 호환성, Athena 포맷별 스키마 변경, Iceberg, Redshift ALTER TABLE, DynamoDB 스키마리스, DMS DDL 처리)로 해석했다. 가장 가까운 공식 근거는 시험 가이드 "Target Candidate Description"의 "volume, variety, and velocity on … schema design" 문구(데이터 양·다양성·속도 변화가 스키마 설계에 미치는 영향).
  - 확인 시도: https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01.html (Target Candidate Description), 도메인 2 Task 2.4 페이지(위 URL)에서 Skill 한 줄 외 부연 설명 없음.
  - 후속: 취합 세션이 "데이터 특성 = 스키마·볼륨·형식 변화" 해석을 확정. 볼륨·속도 변화 쪽(예: 파티션 재설계, 용량 모드)을 보강할지 결정.

- G-2.4-03 [불확실] Skill 2.4.1 "Lake Formation을 위한 스키마 설계"의 범위. Lake Formation은 자체 스키마가 없고 Glue Data Catalog(데이터베이스·테이블)에 메타데이터를 저장하며, 설계 대상은 LF-Tag 온톨로지·권한 구조에 가깝다. 노트는 LF-TBAC와 LF-Tag 제약(키당 값 하나, 리소스 생성 시 동시 부여 불가, 사전 정의 필요)을 정리했다.
  - 확인 시도: https://docs.aws.amazon.com/lake-formation/latest/dg/how-it-works-terminology.html ("Lake Formation uses the AWS Glue Data Catalog to store metadata…"), https://docs.aws.amazon.com/lake-formation/latest/dg/tag-based-access-control.html, https://docs.aws.amazon.com/lake-formation/latest/dg/lf-tag-considerations.html
  - 후속: 취합 세션이 이 Skill을 "Data Catalog 객체 구조 + LF-Tag 설계"로 둘지 확정.

- G-2.4-04 [확인필요] Skill 2.4.4 — Lake Formation이 데이터 계보 기능을 제공한다는 공식 문서는 찾지 못했다(Lake Formation 감사는 CloudTrail GetDataAccess 이벤트 기반). Glue Spark 잡(AWS Glue 5.0+)은 계보 이벤트를 DataZone/SageMaker Catalog로 보내도록 설정할 수 있다. DataBrew에도 별도 "data lineage" 화면이 있다(노트 본문 미반영).
  - 확인 시도: "Lake Formation data lineage" 검색(문서 hit 없음), 감사: https://aws.amazon.com/blogs/machine-learning/controlling-and-auditing-data-exploration-activities-with-amazon-sagemaker-studio-and-aws-lake-formation/ ; Glue 5.0: https://aws.amazon.com/blogs/big-data/introducing-aws-glue-5-0-for-apache-spark/ ; DataBrew: https://docs.aws.amazon.com/help-panel/databrew/latest/hp/page-data-lineage.html ("Use the data lineage to find the origins of the data in your dataset.")
  - 후속: 학습문서에 "Lake Formation은 계보 기능을 제공한다"고 쓰지 말 것. DataBrew 계보를 선택지로 다룰지 취합 세션이 결정.

- G-2.4-05 [상충] Redshift "작은 디멘션 테이블 → ALL" 가이드가 문서마다 다르다. 분산 스타일 개요 문서는 "there isn't a significant benefit to define small dimension tables as DISTSTYLE ALL"(작은 디멘션은 재분산 비용이 낮아 이점 크지 않음)이라 하고, "Choose the best distribution style" 문서는 colocate할 수 없는 디멘션에 ALL을 권하며(저장·적재 비용 경고), AWS Big Data 블로그(Vertica 마이그레이션)는 "Use ALL distribution for small dimension tables"라고 쓴다.
  - 확인 시도: https://docs.aws.amazon.com/redshift/latest/dg/c_choosing_dist_sort.html , https://docs.aws.amazon.com/redshift/latest/dg/c_best-practices-best-dist-key.html , https://aws.amazon.com/blogs/big-data/migrating-from-vertica-to-amazon-redshift/
  - 후속: 문항에서 "작은 디멘션 = ALL"만을 단독 정답으로 삼지 말고 AUTO/KEY/ALL 조건(갱신 빈도, colocate 가능성)을 명시. 노트는 공식 문서 문구대로 양쪽을 병기했다.

- G-2.4-06 [개명·종료] (a) Amazon SageMaker Catalog는 Amazon DataZone 기반이다("Amazon SageMaker Catalog, built on Amazon DataZone") — DataZone 경험은 그대로 유지된다. (b) SageMaker ML Lineage Tracking 문서 머리말: 2023-11-30부터 이전 SageMaker Studio 경험은 SageMaker Studio Classic으로 개명, "Studio Classic is still maintained for existing workloads but is no longer available for onboarding". (c) SageMaker Data Wrangler는 SageMaker Canvas로 통합(3.2.2 노트에 반영).
  - 확인 시도: https://docs.aws.amazon.com/datazone/latest/userguide/sagemaker-datazone.html , https://docs.aws.amazon.com/sagemaker/latest/dg/lineage-tracking.html , https://docs.aws.amazon.com/sagemaker/latest/dg/data-wrangler.html
  - 후속: 학습문서에서 "DataZone"과 "SageMaker Catalog"를 혼동 없이 병기. 시험 가이드 Skill 2.4.4는 이미 SageMaker Catalog 표기.

- G-2.4-07 [개명·종료] Bedrock Knowledge Bases: 2026-09-30부터 customer-managed 지식 베이스에서 Confluence·Microsoft SharePoint·Salesforce·Web Crawler 커넥터를 새로 만들 수 없다(기존 커넥터는 계속 동작). 문서는 "Amazon Bedrock Managed Knowledge Base"를 권장한다(관리형 파서·벡터 스토어·임베딩 모델). 시험이 이 신규 옵션을 다루는지는 불명.
  - 확인 시도: https://docs.aws.amazon.com/bedrock/latest/userguide/data-source-connectors.html , https://docs.aws.amazon.com/bedrock/latest/userguide/kb-data-source-sync-ingest.html , https://docs.aws.amazon.com/bedrock/latest/userguide/kb-how-it-works.html 의 help-panel 버전(https://docs.aws.amazon.com/help-panel/bedrock/latest/console/hp-kb-how-it-works.html — Managed / Customer-managed(unstructured) / Customer-managed(structured, Redshift) 구분)
  - 후속: Skill 2.4.6은 "개념 설명" 수준(시험 가이드 "Recommended general IT knowledge"에 "General concepts of vectors" 명시: https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01.html). Managed KB 세부는 깊이 다루지 말 것.

- G-2.4-08 [개명·종료] Redshift 문서 상단 공지: "Amazon Redshift will no longer support the use of Python UDFs after June 30, 2026." (단계적 시행). 2.4 범위와는 거리가 있으나 Redshift 문항(UDF 선택지) 출제 시 주의.
  - 확인 시도: https://docs.aws.amazon.com/redshift/latest/dg/c_Compression_encodings.html (페이지 상단 배너; 다른 Redshift 페이지에도 동일)
  - 후속: 취합 세션이 Redshift UDF 관련 오답/정답 설계 시 반영.

- G-2.4-09 [확인필요] DynamoDB 벡터 인덱스(신규): "Vector indexes are a type of index in Amazon DynamoDB that enable similarity search on vector embeddings stored in your table items", SearchVectors API로 조회, GSI/LSI의 Query/Scan과 다름. 노트에는 넣지 않았다(2.4.6 예시가 Bedrock KB이고 출처 수 절제).
  - 확인 시도: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/VectorSearch.html , https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/SecondaryIndexes.html (머리말에 "Vector indexes" 구분)
  - 후속: 2.4.6 또는 2.1.8(벡터 인덱스 유형, 다른 Task)에서 다룰지 취합 세션이 결정.

- G-2.4-10 [확인필요] 벡터 스토어별 선택 기준(Aurora PostgreSQL pgvector, Neptune Analytics, OpenSearch Serverless, S3 Vectors, Pinecone, Redis Enterprise Cloud 등)은 이 노트에서 다루지 않았다. 공식 비교 문서가 있다.
  - 확인 시도: https://docs.aws.amazon.com/prescriptive-guidance/latest/choosing-an-aws-vector-database-for-rag-use-cases/vector-db-comparison.html (검색 chunk만 확인, 본문 전체 미독)
  - 후속: Skill 2.1.8(벡터 인덱스 HNSW·IVF, Task 2.1)과 함께 다루는 편이 자연스러움.

- G-2.4-11 [불확실] Glue Schema Registry의 기본 호환성 모드. 개발자 가이드는 BACKWARD를 "recommended"라고만 하고 기본값을 명시하지 않는다. AWS Big Data 블로그는 "The default option is backward compatibility"라고 쓴다.
  - 확인 시도: https://docs.aws.amazon.com/glue/latest/dg/schema-registry.html , https://aws.amazon.com/blogs/big-data/aws-glue-streaming-application-to-process-amazon-msk-data-using-aws-glue-schema-registry/
  - 후속: CreateSchema API 레퍼런스(Compatibility 기본값)로 확정하기 전에는 "기본값 = BACKWARD"를 단정하지 말 것. 노트는 "권장"까지만 기록.

- G-2.4-12 [확인필요] 표 셀·서식 인용 제약 때문에 "사실·숫자" 표에 인용하지 못한(그러나 본문에서 서술한) 내용. 취합 시 원 페이지에서 직접 확인: (1) Athena 포맷별 스키마 변경 가능 여부 전체 표와 "Parquet·ORC는 데이터 타입 변경이 파티션된 테이블에서만 동작" — https://docs.aws.amazon.com/athena/latest/ug/handling-schema-updates-chapter.html , (2) DynamoDB GSI vs LSI 비교 표(키 구성·처리량·프로젝션 속성 등) — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/SecondaryIndexes.html , (3) 계보 지원 매트릭스(Glue 잡·EMR 기본 비자동, Glue 크롤러·Redshift 기본 자동, Visual ETL fineGrained 모드 미지원) — https://docs.aws.amazon.com/sagemaker-unified-studio/latest/userguide/datazone-support-matrix.html , (4) Bedrock 임베딩 모델별 벡터 유형·차원(Titan Text Embeddings V2: 부동소수점·이진, 256/512/1024 등) — https://docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base-supported.html , (5) DMS SC 지원 변환 경로 표 — https://docs.aws.amazon.com/dms/latest/userguide/CHAP_SchemaConversion.html , (6) SCT 변환 지원 표(OLTP·DW·NoSQL·ETL·빅데이터) — https://docs.aws.amazon.com/SchemaConversionTool/latest/userguide/CHAP_Welcome.html
  - 확인 시도: 2026-10-17 읽기 + 2026-10-19 .md 버전 대조(표 셀은 컨트롤러 자동 대조에서 자주 실패하는 유형이라 인용에서 제외).
  - 후속: 최종 문항에 이 수치·표 내용을 쓰면 해당 URL에서 사람이 직접 대조.

- G-2.4-13 [분할제안] Task 2.4는 Skill 6개가 서로 거의 겹치지 않는 서비스 군(Redshift·DynamoDB·Lake Formation / Glue·Athena·DMS / SageMaker·DataZone / Bedrock)에 걸쳐 노트가 길다(사실 78행·출처 38개). 학습문서 3개로 나눌 것을 제안: (A) 2.4.1+2.4.5 — 테이블·데이터 모델 설계와 최적화(Redshift, DynamoDB, Lake Formation LF-Tag, Athena 파티셔닝·압축), (B) 2.4.2+2.4.3 — 스키마 진화와 스키마 변환(크롤러 정책, Schema Registry, Iceberg, DMS DDL, DMS SC/SCT), (C) 2.4.4+2.4.6 — 계보와 벡터화(SageMaker ML Lineage·Catalog, Bedrock Knowledge Bases). 결정은 취합 세션.
  - 확인 시도: 노트 소제목 구성과 서비스 중복도 검토.
  - 후속: 취합 세션이 문서 단위 확정.
  - 근거 URL (컨트롤러 보강): 구조·범위 판단 항목(외부 문서 인용 없음). 근거 기준: 공식 가이드 https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain2.html 및 tasks/2-4.md 출처 목록

- G-2.4-14 [수정제안] flutter_app/assets/exam_guides/DEA-C01.json(읽기 전용): Skill 2.4.3 "스키마 변환 수행(예: AWS 스키마 변환 도구(AWS SCT) 및 AWS Database Migration Service(AWS DMS) 스키마 변환 사용)"과 2.4.4·2.4.6 문구는 공식 가이드 번역과 일치하므로 수정 불필요. 다만 JSON에는 범위 내 서비스 목록 필드가 없다(grep 확인). 앱에서 서비스 범위를 노출할 계획이면 v1.1 변경(SCT 제거, Amazon Bedrock·Amazon Q·Amazon Kendra·AWS Data Exchange·Amazon S3 Tables 추가, Amazon Quick 표기)을 반영해야 한다.
  - 확인 시도: JSON grep(SCT·Catalog·Bedrock 등), 개정 이력 https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-revisions.html
  - 후속: 취합 세션이 필요 시 별도 Task로 처리(이 서브에이전트는 JSON 수정 금지).

### Task 3.1 — Automate data processing by using AWS services (AWS 서비스를 사용하여 데이터 처리 자동화)

- G-3.1-01 [상충] boto3 기본 재시도 모드. 현행 boto3 가이드는 "Legacy mode is the default mode used by any Boto3 client you create."라고 적고 legacy 최대 5회·standard 최대 3회(둘 다 최초 요청 포함)·adaptive는 실험적 모드라고 한다. 반면 AWS Developer Tools Blog는 SDK 재시도 동작 갱신을 2026년 11월에 기본값으로 만든다고 공지했고, 현재 legacy가 기본인 SDK(Python 포함)는 기본이 standard로 바뀌며 재시도 쿼터가 추가된다고 한다. 시험(가이드 v1.1, 2025-12-12 게시)이 어느 시점 동작을 기준으로 하는지 확인할 수 없다. 3-1.md는 현행 문서(legacy 기본)를 서술하고 변경 예정을 병기했다.
  - 확인 시도: https://docs.aws.amazon.com/boto3/latest/guide/retries.html 전문, https://aws.amazon.com/blogs/developer/announcing-updated-retry-behavior-for-aws-sdks-and-tools/ 전문.
  - 후속: 문항은 "기본값이 무엇인가"보다 모드별 특성(standard=서킷 브레이킹·재시도 쿼터, adaptive=클라이언트 측 속도 제한·실험적)을 중심으로 출제하고, 기본값을 묻는다면 근거 날짜를 명시.

- G-3.1-02 [불확실] Glue 잡 자동 재시도(MaxRetries, 콘솔 'Number of retries') 기본값 — G-1.3-05의 후속이며 확정하지 못했다. 확인된 것: Glue 콘솔 잡 속성 문서(2026-10-19 재조회)는 "Specify the number of times, from 0 to 10, that AWS Glue should automatically restart the job if it fails. Jobs that reach the timeout limit are not restarted."라고 범위(0~10)와 타임아웃 도달 잡은 재시작하지 않는다는 점만 적고 기본값은 적지 않는다. CreateJob API 레퍼런스의 MaxRetries 설명("The maximum number of times to retry this job if it fails.")에도 기본값이 없다. 한편 CDK L2 문서는 default 0, Glue FAQ는 "retry all failures three times"라고 적어 서로 다르다. 3-1.md에는 MaxRetries의 정의만 썼고 기본값은 쓰지 않았다.
  - 확인 시도: https://docs.aws.amazon.com/glue/latest/dg/add-job.html (2026-10-19), https://docs.aws.amazon.com/glue/latest/webapi/API_CreateJob.html , https://aws.amazon.com/glue/faqs/ , https://docs.aws.amazon.com/cdk/api/v2/docs/aws-cdk-lib.aws_glue.JobProps.html
  - 후속: Glue 재시도 기본값을 정답 근거로 삼는 문항은 만들지 말 것. 확정하려면 콘솔에서 새 잡의 'Number of retries' 초기값을 실측하는 사람 작업이 필요.

- G-3.1-03 [개명·종료] Glue 버전·타임아웃 기본값 변화. 2026-10-19에 재조회한 잡 속성 문서의 버전 표에는 Glue 6.0(Spark 4.1.1, Python 3.13)이 있고 "Jobs that are created without specifying a AWS Glue version default to AWS Glue 5.1."이라고 적는다. 잡 타임아웃 기본은 Glue 4.0 이하 2,880분, 5.0 이상 480분이며 구 자료의 "기본 48시간"과 다르다. 또 AWS Service Availability Updates(2026-03 공지)는 AWS Glue의 Ray Jobs 기능이 2026-04-30부터 신규 고객 대상 maintenance로 이동한다고 공지했다.
  - 확인 시도: https://docs.aws.amazon.com/glue/latest/dg/add-job.html (2026-10-19), https://docs.aws.amazon.com/glue/latest/webapi/API_CreateJob.html , https://aws.amazon.com/about-aws/whats-new/2026/03/aws-service-availability/
  - 후속: 학습문서·문항에 "Glue 잡 타임아웃 기본 48시간"을 단정하지 말고 Glue 버전별로 쓸 것. Ray 잡은 Task 3.1 범위 밖으로 보이며 문항에 쓰지 말 것.

- G-3.1-04 [개명·종료] EventBridge 새 Custom Event Bus는 재시도 기본값이 다르다. 새 버스의 subscriber는 기본 5회·300초(MaxRetryAttempts 기본 5, MaxEventAgeInSeconds 기본 300)이고, Custom Event Bus - Classic의 규칙 대상과 EventBridge Scheduler는 기본 24시간·최대 185회이다. 3-1.md 사실 표에는 규칙(Classic)·Scheduler 기준 24시간·185회만 넣었다(G-1.3-01의 용어 변경과 같은 맥락).
  - 확인 시도: https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-custom-bus-retry.html (전문), https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-rule-retry-policy.html , https://aws.amazon.com/blogs/compute/introducing-amazon-eventbridge-scheduler/
  - 후속: "EventBridge 재시도 기본 24시간·185회"를 문항에 쓸 때 대상(규칙·Scheduler)을 명시하고 새 Custom Event Bus는 제외.

- G-3.1-05 [수정제안] 시험 가이드 in-scope 서비스 목록과 Skill 3.1.6의 불일치. Skill 3.1.6 원문은 "AWS Glue DataBrew and Amazon SageMaker Unified Studio"를 예로 들지만, DEA-C01 in-scope 목록(Analytics, Machine Learning)에는 "AWS Glue DataBrew"와 "Amazon SageMaker AI"만 있고 "Amazon SageMaker Unified Studio" 항목은 없다. 같은 목록에는 구 명칭 "Amazon Kinesis Data Firehose"와 신 명칭 "Amazon Quick"이 섞여 있고 MWAA Serverless 항목은 없다(G-1.3-03과 연결).
  - 확인 시도: https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-in-scope-services.html 전문. 레포 flutter_app/assets/exam_guides/DEA-C01.json 160행이 가이드 원문(예: DataBrew, Unified Studio)과 같은 문구임을 확인했다(읽기만 함).
  - 후속: DEA-C01.json은 가이드 원문 그대로 유지 권장(수정 불필요). 학습문서에서 Unified Studio는 Visual ETL 수준으로 비중을 낮추고 범위 밖일 가능성을 표시.
  - 근거 URL 보강(컨트롤러, 2026-10-19 열람·인용문 원문 확인): https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain3.html · https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-in-scope-services.html

- G-3.1-06 [불확실] SageMaker Unified Studio의 "데이터 준비" 기능 범위. 공식 근거로 확인한 것: Visual ETL(드래그 앤 드롭, AWS Glue 대화형 세션 위에서 동작, Glue 4.0·5.0·5.1), 노트북·SQL 쿼리 편집기, 2025-07-15 릴리스 노트의 데이터 처리 잡(jobs: ETL 스크립트·노트북·Visual ETL 편집기로 만들고 온디맨드·스케줄·워크플로로 실행)과 MWAA 기반 Visual Workflows. SageMaker Data Wrangler는 현재 SageMaker Canvas의 기능으로 문서화되어 있고 Unified Studio 안의 기능이라는 문서는 찾지 못했다. 시험이 Unified Studio에서 무엇을 묻는지는 확정할 수 없다.
  - 확인 시도: https://docs.aws.amazon.com/sagemaker-unified-studio/latest/userguide/visual-etl.html , https://docs.aws.amazon.com/sagemaker-unified-studio/latest/userguide/what-is-sagemaker-unified-studio.html , https://docs.aws.amazon.com/sagemaker/latest/dg/data-prep.html , https://docs.aws.amazon.com/sagemaker-unified-studio/latest/userguide/release-notes.html (검색 chunk)
  - 후속: 학습문서는 Visual ETL 중심으로 서술하고 Data Wrangler는 "Canvas 안에서 제공"으로만 언급.

- G-3.1-07 [확인필요] Redshift 구체화된 뷰 Auto REFRESH 동작 변경. 문서는 2026-02-27부터 Auto REFRESH 쿼리가 백그라운드 자동 프로세스가 아니라 사용자 쿼리로 실행되어 다른 사용자 쿼리와 같은 우선순위를 갖는다고 공지한다. 같은 문서에 "워크로드를 우선하며 자동 새로 고침을 중단할 수 있다"는 기존 문구도 남아 있어 현재 동작의 조합이 불명확하다. 3-1.md는 두 문장을 모두 인용했다.
  - 확인 시도: https://docs.aws.amazon.com/redshift/latest/dg/materialized-view-refresh.html (검색 chunk)
  - 후속: 문항은 "결정적 갱신이 필요하면 수동·예약 REFRESH" 수준으로만 출제하고, 자동 새로 고침의 지연 가능성을 정답 근거로 단정하지 말 것.

- G-3.1-08 [불확실] Athena DML 쿼리 타임아웃 기본값·활성 쿼리 한도. 서비스 쿼터 페이지는 DML 쿼리 타임아웃을 "최대 240분까지 증액 요청 가능"이라고만 적고, 기본값(분)과 리전별 활성 DDL/DML 쿼리 수는 General Reference로 넘긴다. 이번 조사에서 기본값을 확인하지 못해 3-1.md에 해당 숫자를 넣지 않았다.
  - 확인 시도: https://docs.aws.amazon.com/athena/latest/ug/service-limits.html (검색 chunk)
  - 후속: 필요하면 AWS General Reference의 Athena endpoints and quotas 페이지에서 확인.

- G-3.1-09 [개명·종료] Athena 페더레이션 구조 변경. 2026-04-21부터 일부 신규 커넥터는 Glue 데이터 카탈로그에 자동 등록되고 계정 내 Lambda 함수를 쓰지 않는다. 문서는 커넥터를 Glue 데이터 카탈로그 페더레이션 커넥터(Lake Formation 연동)와 Athena 데이터 카탈로그 커넥터(계정 내 Lambda 필요, Query Federation SDK 커스텀 커넥터) 2종으로 구분한다. "페더레이션은 항상 Lambda 위에서 실행"이라는 기존 설명과 다르다.
  - 확인 시도: https://docs.aws.amazon.com/athena/latest/ug/federated-queries.html (검색 chunk)
  - 후속: 학습문서에서 두 유형을 구분하고 "페더레이션=항상 Lambda"라고 단정하지 말 것.

- G-3.1-10 [불확실] Skill 3.1.5 "데이터 API 사용 및 유지 관리"의 정의가 모호하다. 가장 가까운 공식 근거로 Redshift Data API(한도·멱등성·인증)와 RDS Data API(한도)를 정리했다. API Gateway 등으로 데이터 API를 제공하는 쪽(Task 1.1.4, 1.2.8)과의 경계는 확정할 수 없다.
  - 확인 시도: https://docs.aws.amazon.com/redshift/latest/mgmt/data-api.html , https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/data-api.limitations.html
  - 후속: 1.1.4/1.2.8 문서의 "데이터 API" 용어와 맞춘다(3-1.md는 "영속 연결 없이 HTTPS/SDK로 SQL을 실행하는 API"로 정의).

- G-3.1-11 [확인필요] Lambda 최대 실행 시간 "15분"은 일반(Event) 함수 기준이다. 현행 Lambda 할당량 문서는 Lambda Managed Instances 함수가 비동기·이벤트 소스 매핑으로 호출될 때 최대 5,400초(90분)를 허용한다고 적는다(G-1.3-04와 같은 사안). 3-1.md는 15분(900초)을 일반 함수 기준으로 서술했다.
  - 확인 시도: https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-limits.html
  - 후속: 3.1.8 문항에는 "일반 Lambda 함수는 최대 900초(15분)"로 한정해 서술.

- G-3.1-12 [분할제안] Task 3.1은 Skill 9개에 서비스가 15개 안팎(MWAA, Step Functions, boto3, EMR, Redshift, Glue, Data API, DataBrew, SageMaker Unified Studio, Athena, Lambda, EventBridge)이라 학습문서 1개로는 과하다(3-1.md는 소제목 11개·표 7개(Skill 커버리지 표 포함)·사실 151행·출처 51개). 제안 3분할: (A) Skill 3.1.1·3.1.2·3.1.9 — MWAA·Step Functions 운영·트러블슈팅과 EventBridge 규칙·Scheduler, (B) Skill 3.1.4·3.1.5·3.1.6·3.1.7 — EMR·Redshift·Glue 기능, 데이터 API, 변환 준비(DataBrew·Unified Studio), Athena, (C) Skill 3.1.3·3.1.8 — SDK(boto3) 호출과 Lambda 자동화. 결정은 취합 세션.
  - 확인 시도: 3-1.md 작성 중 분량 점검(소제목·표·출처 수 집계).
  - 후속: 취합 세션.
  - 근거 URL (컨트롤러 보강): 구조·범위 판단 항목(외부 문서 인용 없음). 근거 기준: 공식 가이드 https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain3.html 및 tasks/3-1.md 출처 목록

- G-3.1-13 [개명·종료] Redshift 개발자 가이드 페이지 상단에 공통 공지가 붙어 있다: "Amazon Redshift will no longer support the use of Python UDFs after June 30, 2026." 이어서 단계적 적용(enforcing it in phases)과 2025-06-30 블로그 링크가 나온다. Python UDF는 Task 3.1 Skill 범위 밖이라 3-1.md 본문에는 쓰지 않았다. 다만 Redshift에서 변환 로직을 어디에 둘지(저장 프로시저·UDF) 고르는 문항에 영향을 줄 수 있다.
  - 확인 시도: https://docs.aws.amazon.com/redshift/latest/dg/r_CALL_procedure.html , https://docs.aws.amazon.com/redshift/latest/dg/materialized-view-refresh.html (2026-10-19, 두 페이지 상단에서 같은 문구 확인). 공지가 가리키는 블로그: https://aws.amazon.com/blogs/big-data/amazon-redshift-python-user-defined-functions-will-reach-end-of-support-after-june-30-2026/ (페이지 본문의 링크이며 내용은 읽지 않음)
  - 후속: Redshift UDF를 다루는 다른 Task 노트(변환·쿼리 쪽)와 대조해 학습문서에 "Python UDF 지원 종료" 한 줄을 넣을지 취합 세션이 결정.

- G-3.1-14 [확인필요] 3-1.md 사실·숫자 표 인용 정리 상태(2026-10-19 점검). 표의 인용 181개(151행)를 각 URL 페이지의 HTML 본문 텍스트(공백 정규화)와 문자열 대조했고, docs.aws.amazon.com .html 페이지는 마크다운 원문(.md)과도 대조해 불일치 0건이다. 링크·코드·굵게·이탤릭이나 표 셀 경계에 걸쳐 .md 원문과 어긋나던 인용 11개는 일반 문장의 연속 구간으로 교체했다. .md 형태가 없는 페이지(boto3 가이드 4, aws.amazon.com FAQ·블로그 4, re:Post 3)의 인용 31개(26행)는 HTML 텍스트로만 대조했고 인라인 태그에 걸치는 인용은 없었다(휴리스틱). 교체의 부작용: MWAA 워커 필요량 계산식 "(tasks running + tasks queued) / (tasks per worker) = (required workers)"는 이탤릭·링크·이스케이프가 낀 문장이라 표에 인용하지 못했고 본문(핵심 개념, [S4])에만 서술했다. 같은 이유로 Redshift CALL 근거는 S21 대신 CALL 명령 페이지(S51, 조회 2026-10-19)로 바꿨고, Lambda 스트림 정체 감시 지표(Iterator Age)는 별도 행(151번)으로 분리했다.
  - 확인 시도: 인라인 스크립트로 각 URL을 fetch해 비교(파일은 만들지 않음). 대조 대상은 사실 표 인용과 문항 후보의 근거 인용.
  - 후속: 컨트롤러 자동 대조가 마크다운 변환본 기준이라면 .md가 없는 26개 행(출처 S6·S11·S12·S13·S14·S15·S16·S37·S42·S48·S50)만 재확인하면 된다.
  - 근거 URL (컨트롤러 보강): 구조·범위 판단 항목(외부 문서 인용 없음). 근거 기준: 공식 가이드 https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain3.html 및 tasks/3-1.md 출처 목록

### Task 3.2 — Analyze data by using AWS services (AWS 서비스를 사용하여 데이터 분석)

- G-3.2-01 [개명·종료] Amazon QuickSight → Amazon Quick. 현재 공식 문서는 "Amazon Quick evolved from Amazon QuickSight. QuickSight continues as Amazon Quick Sight, a feature within Quick."이라고 설명하고 기존 API·SDK·통합은 그대로 동작한다고 한다. 시험 가이드 범위 내 서비스 목록은 Analytics에 "Amazon Quick"을 적지만 Skill 3.2.1·3.2.2 문구는 아직 "Amazon QuickSight"/"QuickSight"를 쓴다.
  - 확인 시도: https://docs.aws.amazon.com/quick/latest/userguide/what-is.html , https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-in-scope-services.html , Skill 문구 https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain3.html#data-engineer-associate-01-domain3-task2
  - 후속: 학습문서·문항에서 "Amazon Quick(Quick Sight)"을 병기하고 선택지 표기가 QuickSight여도 같은 BI 기능으로 취급. DEA-C01.json의 "Amazon QuickSight"는 공식 번역 그대로이므로 수정 불필요.

- G-3.2-02 [개명·종료] Athena for Apache Spark의 릴리스 버전 분리와 수명: PySpark engine version 3(이전, Athena 콘솔 노트북 에디터·노트북 API 지원)은 2027-04-01에 수명이 끝나며, Apache Spark version 3.5(현재)는 Athena 콘솔 노트북·노트북 API를 지원하지 않고 SageMaker Unified Studio 노트북·Spark Connect 클라이언트를 쓴다. 두 버전 사이 워크그룹 업그레이드는 불가. Skill 3.2.4 "Athena 노트북으로 Spark 탐색"이 어느 버전을 전제로 하는지 공식 근거로 확정 불가.
  - 확인 시도: https://docs.aws.amazon.com/athena/latest/ug/notebooks-spark-migration-v3-to-v35.html , https://docs.aws.amazon.com/athena/latest/ug/notebooks-spark.html , https://docs.aws.amazon.com/athena/latest/ug/notebooks-spark-considerations-and-limitations.html , https://docs.aws.amazon.com/athena/latest/ug/notebooks-spark-getting-started.html , 버전 설명 https://docs.aws.amazon.com/athena/latest/ug/notebooks-spark-release-versions.html (PySpark engine version 3 = Apache Spark 3.2.1, Apache Spark version 3.5 = EMR 7.12 기반·Spark 3.5.6 — 노트 본문 미반영)
  - 후속: 취합 세션이 "시험은 Athena 콘솔 노트북(PySpark engine v3) 절차를 묻는다"고 가정할지, 현재 버전(SageMaker Unified Studio)까지 설명할지 결정. 노트는 둘 다 기록.

- G-3.2-03 [상충] Quick(Quick Sight) 요금 숫자가 자료마다 다르고 현재 공식 Quick 문서의 가입·프로비저닝 모델(Free·Plus 플랜, 사용자별 구독)과도 맞지 않는다: 백서(Standard $9/사용자/월, Enterprise 작성자 $18 등)와 BI 블로그(작성자 $24, 리더 $3, Author Pro $50, Reader Pro $20)의 값이 다르다. 노트에는 요금 숫자를 싣지 않았다.
  - 확인 시도: https://docs.aws.amazon.com/whitepapers/latest/big-data-analytics-options/amazon-quicksight.html , https://aws.amazon.com/blogs/business-intelligence/amazon-q-in-quicksight-brings-new-user-roles-and-pricing-to-amazon-quicksight-enterprise-edition/ , https://docs.aws.amazon.com/quick/latest/userguide/what-is.html
  - 후속: 요금 단가는 문항에 쓰지 말고 구조(작성자/리더·세션·SPICE 용량 구매)만 사용. 필요하면 사람이 현재 요금 페이지에서 확인.

- G-3.2-04 [불확실] Skill 3.2.6 "롤링 평균" 정의: 공식 용어 정의 페이지를 찾지 못했다. Redshift AVG 윈도 함수 문서의 "rolling average" 예제와 윈도 프레임 절 설명으로 대체했다. "Athena에서의 피벗 방법"도 공식 근거를 찾지 못했다 — Athena SELECT 레퍼런스에 PIVOT 절 설명이 없다(문서 내 "pivot" 0건). Athena 함수는 Trino 기반(https://docs.aws.amazon.com/athena/latest/ug/functions-env3.html).
  - 확인 시도: https://docs.aws.amazon.com/redshift/latest/dg/r_WF_AVG.html , https://docs.aws.amazon.com/redshift/latest/dg/c_Window_functions.html , https://docs.aws.amazon.com/athena/latest/ug/select.html , 검색 "Athena pivot unpivot"(공식 문서 hit 없음; Glue Studio에는 "Unpivot Columns To Rows" 변환이 있음: https://docs.aws.amazon.com/glue/latest/dg/transforms-unpivot-columns-to-rows.html)
  - 후속: Athena 피벗(CASE 조건부 집계 등)을 정답 근거로 쓰지 말 것. 피벗 문항은 Redshift PIVOT/UNPIVOT·Quick Pivot 단계·Glue Studio Unpivot 중심으로.

- G-3.2-05 [확인필요] 표준 Athena 뷰의 저장 위치·제약. Athena 뷰는 "logical table"이고 Glue Data Catalog 뷰는 정의가 Glue Data Catalog에 저장된다는 점은 확인했으나, 표준 Athena 뷰의 저장 위치와 제약 사항(예: 지원되지 않는 구문)을 공식 문서 문구로 확인하지 못했다.
  - 확인 시도: https://docs.aws.amazon.com/athena/latest/ug/views.html , https://docs.aws.amazon.com/athena/latest/ug/create-view.html , https://docs.aws.amazon.com/athena/latest/ug/views-console.html
  - 후속: "Athena 뷰는 Glue Data Catalog에 저장된다"를 단정하지 말 것. 필요하면 views-glue.html·views-console.html을 추가로 읽어 확정.

- G-3.2-06 [확인필요] DataBrew 프로파일 잡 상세(통계 구성, 상관 행렬, 중복 행 탐지, 결과가 S3로 출력)는 노트에 넣지 않았다(출처 상한). 노트는 프로젝트 워크스페이스의 값 분포·차트 시각화(What is DataBrew)만 반영.
  - 확인 시도: https://docs.aws.amazon.com/databrew/latest/dg/jobs.profile.html ("Profile jobs run a series of evaluations on a dataset and output the results to Amazon S3"), https://docs.aws.amazon.com/databrew/latest/dg/profile.configuration.html
  - 후속: Skill 3.2.1에서 "프로파일 잡 vs 레시피 잡" 문항을 쓰려면 위 페이지를 추가 조사.

- G-3.2-07 [분할제안] Skill 3.2.5(프로비저닝 vs 서버리스)는 서비스 범위가 열려 있다. 노트는 Redshift·EMR·Kinesis Data Streams·Athena만 다뤘고, MSK Serverless vs Provisioned와 DynamoDB 용량 모드는 다른 Task(스트리밍·스토어) 노트와 겹쳐 제외했다. MSK 근거: https://docs.aws.amazon.com/msk/latest/developerguide/serverless.html ("MSK Serverless offers a throughput-based pricing model, so you pay only for what you use."), https://docs.aws.amazon.com/msk/latest/developerguide/msk-provisioned.html ("allows you to manually configure and scale your Apache Kafka clusters").
  - 확인 시도: 위 두 페이지 .md 확인(노트 미반영).
  - 후속: 취합 세션이 스트리밍 Task 노트와 3.2.5를 함께 보고 MSK·DynamoDB를 포함할지 결정. Kinesis On-demand Advantage(계정 수준, 최소 약정 등)는 신규 모드이며 시험 포함 여부 불명.

- G-3.2-08 [불확실] Skill 3.2.2 "Lambda로 데이터 확인·정리"의 구체적 공식 예시를 찾지 못했다. 노트의 Lambda 근거는 S3 이벤트 호출 방식과 재귀 호출 경고뿐이다. 데이터 품질 규칙·검증은 Task 3.3 영역(Glue Data Quality·DataBrew 규칙)에서 다룰 가능성이 크다. SageMaker Data Wrangler의 현재 상태(Canvas 통합)는 확인.
  - 확인 시도: https://docs.aws.amazon.com/lambda/latest/dg/with-s3.html , https://docs.aws.amazon.com/lambda/latest/dg/welcome.html (Lambda Event Functions 명칭 정리 포함), https://docs.aws.amazon.com/sagemaker/latest/dg/data-wrangler.html
  - 후속: Lambda 검증 시나리오는 "S3 이벤트 → Lambda" 패턴까지만 근거로 사용.

- G-3.2-09 [개명·종료] Redshift Python UDF 지원 종료 공지(2026-06-30 이후 미지원, 단계적 시행)가 Redshift 문서 상단(구체화된 뷰·CREATE VIEW 등)에 있다. 노트 3.2.3 본문에 사실 행으로 기록.
  - 확인 시도: https://docs.aws.amazon.com/redshift/latest/dg/materialized-view-overview.html
  - 후속: 2.4 G-2.4-08과 동일 항목.

- G-3.2-10 [확인필요] 노트에 넣지 않은 Quick Sight 한도·쿼터: SPICE 데이터셋 한도(Standard 25 million 행/25 GB, Enterprise 2 billion 행/2 TB), 직접 쿼리는 시각화 생성 시 2분 후 타임아웃(Redshift 드라이버는 2분 타임아웃에 반응하지 않을 수 있음), 필드·열 이름 길이 한도 등. 출처 25개 상한 때문에 제외(Enterprise/Standard "edition" 용어가 새 Quick 요금 모델과 맞는지도 불명).
  - 확인 시도: https://docs.aws.amazon.com/quick/latest/userguide/data-source-limits.html (목록 형식이라 인용 가능)
  - 후속: 한도 수치 문항이 필요하면 이 페이지를 출처로 추가하고 edition 표기를 재확인.

- G-3.2-11 [개명·종료] (타 Task 확인용) 시험 가이드 범위 내 서비스 목록은 Analytics에 "Amazon Kinesis Data Firehose"(개명 전 이름)와 "Amazon Managed Service for Apache Flink"를 그대로 적는다. 현재 공식 서비스명(Amazon Data Firehose)과 다르다.
  - 확인 시도: https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-in-scope-services.html
  - 후속: Task 1.x(수집) 노트 담당이 [개명·종료]로 확정.

- G-3.2-12 [확인필요] Skill 3.2.3(v1.1 개정)의 변경 내용: 개정 이력 페이지에 따르면 v1.0 문구는 "Skills in: Using Athena to query data or to create views"였고 v1.1은 "Use SQL in Redshift and Athena to query data or to create views"다. 즉 Redshift가 추가되어 Redshift 뷰·구체화된 뷰·SQL이 출제 범위에 들어온 것으로 읽힌다(노트 3.2.3에 Redshift 뷰·MV를 상세히 정리). 같은 이력 페이지에 Skill 2.4.4(SageMaker Catalog 예시 추가) 개정과 Skill 2.4.6 신규도 있다.
  - 확인 시도: https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-revisions.html ("Changes to knowledge and skills" 표, "New skills added")
  - 후속: 3.2.3 문항은 Redshift 쪽 비중(뷰 vs 구체화된 뷰, late-binding, autorefresh)을 충분히 반영.

- G-3.2-13 [불확실] Athena SQL vs Athena Spark를 직접 비교한 공식 표는 찾지 못했다. 노트 비교 표 ③은 Spark 개요·시작 가이드·고려사항·용량 관리 페이지를 조합한 정리다. 요금 모델 차이(스캔 데이터 기준 vs DPU 시간 기준)는 문서 페이지가 아닌 요금 페이지에만 있어 반영하지 않았다.
  - 확인 시도: https://docs.aws.amazon.com/athena/latest/ug/notebooks-spark.html , https://docs.aws.amazon.com/athena/latest/ug/capacity-management.html , https://docs.aws.amazon.com/athena/latest/ug/what-is.html
  - 후속: 요금 비교 문항은 쓰지 않는 것을 권장.

### Task 3.3 — Maintain and monitor data pipelines (데이터 파이프라인 유지 관리 및 모니터링)

- G-3.3-01 [상충] 로그 그룹당 구독 필터 개수가 문서마다 다르다. 사용자 가이드 Subscriptions는 "Each log group can have up to five subscription filters associated with it."이라 하고 quotas 표도 "Subscription filters per log group"을 기본 5·조정 불가로 적는다. 반면 API 레퍼런스 PutSubscriptionFilter는 "Each log group can have up to two subscription filters associated with it."이라 한다. 3-3.md(3.3.7 구독 필터 문단, 사실 행 14)는 사용자 가이드의 5를 적고 상충을 표시했다.
  - 확인 시도: 원문 조회 — https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/Subscriptions.html , https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/cloudwatch_limits_cwl.html , https://docs.aws.amazon.com/AmazonCloudWatchLogs/latest/APIReference/API_PutSubscriptionFilter.html
  - 후속: 개수를 문항 정답 근거로 쓰지 말 것. 꼭 써야 하면 사람이 Service Quotas 콘솔(CloudWatch Logs)에서 현재 값을 확인.

- G-3.3-02 [상충] Logs Insights 동시 쿼리 한도 100 vs 30. StartQuery API 레퍼런스는 "You can have up to 100 concurrent CloudWatch Logs insights queries, including queries" 이고 "View running queries or query history" 문서도 계정당 100개(IA 로그 그룹은 별도로 5개로 제한)로 적는다. 반면 re:Post Knowledge Center 문답은 Standard 클래스 로그 그룹에서 "maximum of 30 concurrent CloudWatch Logs Insights queries"라 하고 AWS SDK for JavaScript v2 문서의 StartQuery 설명도 30이다. AWS Cloud Operations Blog(Jan-May 2026)는 "Concurrent query limit for Logs Insights QL increased from 30 to 100."이라 적어 30은 이전 값으로 보인다. 3-3.md 사실 행 21은 100을 적고 상충을 표시했다.
  - 확인 시도: https://docs.aws.amazon.com/AmazonCloudWatchLogs/latest/APIReference/API_StartQuery.html , https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CloudWatchLogs-Insights-Query-History.html , https://repost.aws/knowledge-center/cloudwatch-logs-query-errors , https://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/CloudWatchLogs.html , https://aws.amazon.com/blogs/mt/aws-observability-icymi-jan-may-2026/
  - 후속: 숫자를 정답 근거로 쓰지 말 것(쓰면 100과 출처 병기). re:Post 문답이 갱신됐는지는 확인하지 못했다.

- G-3.3-03 [상충] Infrequent Access(IA) 로그 클래스의 S3 내보내기 지원 여부. 로그 클래스 문서 기능 표(열: Feature / Standard / Infrequent Access)는 "Export to Amazon S3"를 Standard·IA 둘 다 Yes로 적는다. 반면 AWS News Blog(2023-11-26) "New – Amazon CloudWatch log class for infrequent access logs at a reduced price"의 비교 표는 "Subscription filters / Export to S3"를 IA 열에서 "Not available"로 적는다. 문서 표가 더 최신으로 보이나 확정하지 못했다. 3-3.md 3.3.7 로그 클래스 문단은 IA의 내보내기 지원 여부를 확정하지 않고 상충만 표시했다.
  - 확인 시도: https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CloudWatch_Logs_Log_Classes.html (원문 표), https://aws.amazon.com/blogs/aws/new-amazon-cloudwatch-log-class-for-infrequent-access-logs-at-a-reduced-price/ , 내보내기 문서 https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/S3Export.html (로그 클래스 언급 없음)
  - 후속: IA와 S3 내보내기 조합을 묻는 문항은 만들지 말 것. 구독 필터·메트릭 필터·Live Tail는 IA 불가로 문서 표가 일관되므로 그쪽은 사용 가능.

- G-3.3-04 [상충] Kinesis Data Streams 보존 기간 최대값 7일 vs 365일. Kinesis 모니터링 문서(3-3.md S31)의 IteratorAgeMilliseconds 설명은 "by default, 24 hours, configurable up to 7 days"라 한다. 반면 소비자 문제 해결 문서(S38)는 "by default, 24 hours, configurable up to 365 days"이고, "Change the data retention period" 문서도 기본 24시간~최대 8760시간(365일)이라 적는다. 3-3.md는 365일(S38)을 쓴다(사실 행 47).
  - 확인 시도: https://docs.aws.amazon.com/streams/latest/dev/monitoring-with-cloudwatch.html , https://docs.aws.amazon.com/streams/latest/dev/troubleshooting-consumers.html , https://docs.aws.amazon.com/streams/latest/dev/kinesis-extended-retention.html
  - 후속: S31의 "7 days"는 오래된 서술로 보인다. "최대 7일"을 오답 보기로 쓰려면 검수자가 이 상충을 알고 있어야 한다.

- G-3.3-05 [상충] 메트릭 필터의 정규식 지원. CloudWatch FAQ는 "Amazon CloudWatch Metric Filters does not support regular expressions."라 하는데, PutMetricFilter API 레퍼런스는 "Using regular expressions in filter patterns is supported."이고(단일 필터 패턴당 정규식 2개·로그 그룹당 5개 한도 서술) 필터 패턴 구문 문서도 정규식 사용을 설명한다. 3-3.md는 이 주제를 본문에 싣지 않았다.
  - 확인 시도: https://aws.amazon.com/cloudwatch/faqs/ , https://docs.aws.amazon.com/AmazonCloudWatchLogs/latest/APIReference/API_PutMetricFilter.html , https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/FilterAndPatternSyntax.html
  - 후속: 정규식 가능 여부를 묻는 문항은 만들지 말 것(FAQ가 오래된 서술로 보이나 확정하지 못함).

- G-3.3-06 [확인필요] CreateExportTask 동시 활성 작업 수 한도(1개)를 본문에 숫자로 싣지 않았다. API 레퍼런스는 "Each account can only have one active" 뒤에 코드 서식(`RUNNING`/`PENDING`)이 이어지는 문장이고, quotas 표는 "Active export task | Each supported Region: 1 | No"(조정 불가)로 적는다. 값이 코드 서식·표 셀 안에 있어 자동 인용 대조 위험 때문에 3-3.md 3.3.1은 "한도가 있다"까지만 적었다.
  - 확인 시도: https://docs.aws.amazon.com/AmazonCloudWatchLogs/latest/APIReference/API_CreateExportTask.html , https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/cloudwatch_limits_cwl.html
  - 후속: 취합 세션이 필요하면 S6의 평문 부분 "Each account can only have one active"를 인용으로 사실 행을 추가한다.

- G-3.3-07 [개명·종료] Centralized Logging with OpenSearch 솔루션이 2026년 12월 종료 예정이다. 솔루션 개요 페이지: "This AWS Solution will retire in December 2026." 문서는 CloudWatch의 통합 데이터 관리·분석 기능을 권고한다. 본문의 OpenSearch Service 적합성 인용(3-3.md S36, 4-4.md S20)은 이 솔루션의 service-logs 페이지에서 가져왔고 그 페이지에는 종료 배너가 없다. 본문 반영: 3-3.md S39·사실 행 52·3.3.8 OpenSearch 문단, 4-4.md S23·사실 행 35·4.4.4/4.4.5 문단. 종료되는 것은 솔루션이며 OpenSearch Service 자체가 아니다.
  - 확인 시도: https://docs.aws.amazon.com/solutions/latest/centralized-logging-with-opensearch/solution-overview.html (종료 배너 확인), https://docs.aws.amazon.com/solutions/latest/centralized-logging-with-opensearch/aws-service-logs.html (배너 없음). OpenSearch Service 서비스 가이드에서 같은 적합성 문장을 찾는 것은 하지 않았다.
  - 후속: 이 솔루션 자체를 학습·출제 대상으로 삼지 말 것. "실시간·빈번 쿼리·전문 검색" 근거를 OpenSearch Service 가이드에서 교차 확인하면 더 안전하다.

- G-3.3-08 [개명·종료] Glue 버전·필드 변화. 연속 로깅(`--enable-continuous-cloudwatch-log`)은 4.0 이하 대상이고 5.0부터는 모든 작업이 실시간 로깅 기능을 가진다(S17). 버전을 지정하지 않고 만든 작업의 기본 버전은 5.1이고, 타임아웃 기본값이 4.0 이하 2,880분·5.0 이상 480분으로 다르며, `AllocatedCapacity` 필드는 deprecated라 `MaxCapacity`를 쓰라고 한다(S21). 시험이 어느 Glue 버전을 전제로 묻는지는 가이드로 확정할 수 없다.
  - 확인 시도: https://docs.aws.amazon.com/glue/latest/dg/monitor-continuous-logging-enable.html , https://docs.aws.amazon.com/glue/latest/dg/aws-glue-api-jobs-job.html
  - 후속: 문항에는 Glue 버전 전제를 문장에 명시한다. 구버전(4.0 이하) 전제 문항은 그렇게 한정해서 쓴다.

- G-3.3-09 [개명·종료] Kinesis 지표 `PutRecords.Records`는 deprecated, 대체는 `PutRecords.SuccessfulRecords`(모니터링 문서 지표 표에 "This metric is deprecated."로 표시). 3-3.md는 이 지표를 쓰지 않았다.
  - 확인 시도: https://docs.aws.amazon.com/streams/latest/dev/monitoring-with-cloudwatch.html
  - 후속: 오답 보기·함정으로 쓸 때만 참고.

- G-3.3-10 [개명·종료] "CloudWatch Events" 표기가 여러 문서에 남아 있다. CloudTrail FAQ(S1)는 trail 전달 대상을 "Amazon CloudWatch Events"로 적고, Glue(S13)·EMR(S22)·S3 로깅 옵션(S34) 문서에도 CloudWatch Events 표기가 있다. 공식 CloudWatch 문서 첫 페이지는 "Amazon CloudWatch Events is now Amazon EventBridge"이며 같은 Events API를 쓴다고 설명한다. 3-3.md는 EventBridge로 쓰고 필요한 곳에 "CloudWatch Events(EventBridge)"로 병기했다.
  - 확인 시도: https://docs.aws.amazon.com/cloudwatch/ , https://aws.amazon.com/cloudtrail/faqs/
  - 후속: 보기에 구명칭이 나와도 같은 서비스로 취급한다.

- G-3.3-11 [개명·종료] (범위 밖 참고) Redshift 관리 가이드 페이지(S15, S26) 상단 배너: "Amazon Redshift will no longer support the use of Python UDFs after June 30, 2026." Task 3.3·4.4 본문과 무관하다.
  - 확인 시도: https://docs.aws.amazon.com/redshift/latest/mgmt/db-auditing.html
  - 후속: Redshift UDF를 다루는 Task 담당에게 전달.

- G-3.3-12 [확인필요] 숫자의 근거가 AWS Big Data Blog 한 편뿐인 항목: Redshift 동시성 확장 기본 꺼짐·최대 1~10(S27), Athena 분할 약 128 MB 지침(S28). Redshift 쪽은 개발자 가이드 `max_concurrency_scaling_clusters` 문서가 "The maximum number of concurrency scaling clusters is an adjustable quota."라 하고 re:Post 문답이 기본값 1이라 적어 모순은 없다. Athena 128 MB는 다른 자료로 교차 확인하지 못했다.
  - 확인 시도: https://docs.aws.amazon.com/redshift/latest/dg/r_max_concurrency_scaling_clusters.html , https://repost.aws/knowledge-center/redshift-choose-cluster-size , https://aws.amazon.com/blogs/big-data/top-10-performance-tuning-tips-for-amazon-athena/
  - 후속: 문항에서 이 숫자를 정답 근거로 쓰기 전에 사람이 한 번 더 확인.

- G-3.3-13 [확인필요] EMR 7.13.0 이상의 `S3LoggingConfiguration`을 본문에 싣지 않았다. EMR 로깅 문서에 "Control S3 logging behavior (Amazon EMR 7.13.0 and later)" 절이 있고 로그 유형(system-logs, application-logs, persistent-ui-logs)별 업로드 정책 emr-managed(기본)·on-customer-s3only·disabled를 설명한다. Skill 3.3.6의 "Troubleshoot and maintain pipelines (for example, AWS Glue, Amazon EMR)"가 이 세부까지 요구하는지는 가이드로 알 수 없다.
  - 확인 시도: https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-plan-debugging.html
  - 후속: 검수자가 시험 범위 여부를 판단.
  - 근거 URL 보강(컨트롤러, 2026-10-19 열람·인용문 원문 확인): https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain3.html (Skill 3.3.6 원문)

- G-3.3-14 [불확실] Skill 3.3.1 "Extract logs for audits."와 3.3.2 "Deploy logging and monitoring solutions to facilitate auditing and traceability."는 어떤 서비스·수단을 묻는지 가이드 문구만으로 확정할 수 없다. 가장 가까운 공식 근거: CloudTrail Event history·trail(S1), CloudWatch Logs 내보내기·구독(S6·S5), S3 로깅 옵션(S34), Redshift 감사 로깅(S26), AWS Config(S35). 본문은 "원천별 추출·배포 경로 선택"으로 해석했다.
  - 확인 시도: 공식 가이드 Task 3.3 Skill 문구 https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain3.html 에는 서비스 예시가 없다.
  - 후속: 취합 세션이 해석(감사 증거 추출 = CloudTrail·CloudWatch Logs 중심)을 확정.

- G-3.3-15 [불확실] Skill 3.3.4 "Troubleshoot performance issues."는 서비스·증상이 지정되지 않았다. 본문은 서비스별 "먼저 볼 신호"로 정리했다: Athena(S28·S29), Redshift(S27), Glue(S20), EMR(S23), Kinesis(S31·S38), Lambda(S32), DynamoDB(S33). 시험이 다루는 서비스 범위는 가이드로 확정할 수 없다. Skill 3.3.8의 "big data application logs"도 의미가 모호하여 EMR 로그(S22·S23)와 대규모 로그 분석(S37)으로 해석했다.
  - 확인 시도: 같은 가이드 페이지(위 URL). 예시 서비스는 3.3.6(Glue, EMR)과 3.3.8(Athena, EMR, OpenSearch Service, CloudWatch Logs Insights)에만 있다.
  - 후속: 다른 Task 문서(성능·최적화 계열)와 중복·누락을 취합 때 점검.
  - 근거 URL (컨트롤러 보강): 구조·범위 판단 항목(외부 문서 인용 없음). 근거 기준: 공식 가이드 https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain3.html 및 tasks/3-3.md 출처 목록

- G-3.3-16 [분할제안] Task 3.3은 Skill 8개가 CloudTrail·CloudWatch·EventBridge·Glue·EMR·Redshift·Athena·Kinesis·Lambda·DynamoDB·S3·OpenSearch에 걸쳐 학습문서 1개로는 과하다. 제안(결정은 취합 세션): (A) 3.3.3+3.3.4 "모니터링·알림·성능 문제 해결" — CloudWatch 경보·누락 데이터 처리·EventBridge 상태 이벤트·서비스별 신호 지표, (B) 3.3.6 "Glue·EMR 파이프라인 유지 관리" — 로그·북마크·재시도/타임아웃·ActionOnFailure·자동 종료, (C) 3.3.1+3.3.2+3.3.5+3.3.7+3.3.8 "감사·애플리케이션 로그 수집과 분석" — 4.4와 Skill이 겹친다. 3.3.5의 영문 원문은 4.4.1과 똑같고("Use AWS CloudTrail to track API calls."), 3.3.7은 4.4.2와, 3.3.8은 4.4.4와, 3.3.8의 Amazon EMR 예시는 4.4.5와 겹친다. 따라서 (C)는 4.4 문서와 합쳐 공통 문서 1~2개(CloudTrail 감사 / CloudWatch Logs·로그 분석)로 두고, Task별 문서는 관점 차이(운영 vs 감사)만 서술하는 안이다. 3-3.md의 AWS Config 소절은 가이드상 Task 4.5 Skill 4.5.4("Viewing configuration changes that have occurred in an account (for example, AWS Config).")와 겹치므로 그 문서와 정리가 필요하다.
  - 확인 시도: 공식 가이드 Skill 문구 대조 https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain3.html , https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain4.html
  - 후속: 취합 세션이 문서 경계를 결정.

### Task 3.4 — Ensure data quality (데이터 품질 보장)

- G-3.4-01 [불확실] Skill 3.4.4("데이터 샘플링 기법 설명")가 무엇을 묻는지 확정하지 못했다. Skill 문구에 서비스 예시가 없다. 3-4.md는 서비스별 샘플링 기능(DataBrew 프로젝트 샘플·프로파일 잡 JobSample, 크롤러 S3 대상 SampleSize, Athena TABLESAMPLE BERNOULLI|SYSTEM)만 담았고, 이 4개 페이지에는 "stratified"·"systematic" 표현이 없다(2026-10-19 확인).
  - 무작위·층화 같은 일반 기법명은 SageMaker Data Wrangler 문서에 있다: "Randomized: Takes a random sample of a size that you specify." / "Stratified: Takes a stratified random sample." Canvas 문서는 같은 방식을 FirstK·Random·Stratified로 부르고, SageMaker FAQ는 "top-K, random, and stratified sampling"이라 쓴다. Data Wrangler는 시험 가이드 Skill 3.2.2의 예시로 명시돼 있어 범위 밖은 아니지만, 3.4.4 문구와 직접 이어지는지는 알 수 없다. "체계적(systematic)" 샘플링은 검색(2026-10-19, "systematic sampling" 포함)에서 어느 문서도 반환되지 않았다.
  - Glue Data Catalog 컬럼 통계 실행에도 샘플 크기 옵션(`--sample-size`)이 있다: "The percentage of rows used to generate statistics."
  - 확인 시도: 2026-10-17 DataBrew 프로젝트 샘플·크롤러 샘플 크기·Athena TABLESAMPLE 검색. 2026-10-19 "stratified sampling"·"systematic sampling" 키워드 검색과 위 페이지 원문 대조.
  - 후속: 학습문서에서 일반 기법명을 쓰려면 Data Wrangler 근거를 인용하되 "서비스별 지원 방식" 틀을 유지하고, 3.4.4 출제 범위는 사람 검수에서 판단.
  - 근거 URL: https://docs.aws.amazon.com/databrew/latest/dg/projects.html (직접) · https://docs.aws.amazon.com/athena/latest/ug/select.html (직접) · https://docs.aws.amazon.com/sagemaker/latest/dg/data-wrangler-transform.html · https://docs.aws.amazon.com/sagemaker/latest/dg/canvas-data-flow-edit-sampling.html · https://aws.amazon.com/sagemaker/ai/faqs/ · https://aws.amazon.com/blogs/machine-learning/create-random-and-stratified-samples-of-data-with-amazon-sagemaker-data-wrangler/ · https://docs.aws.amazon.com/cli/latest/reference/glue/start-column-statistics-task-run.html · https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain3.html

- G-3.4-02 [불확실] Skill 3.4.5("데이터 스큐 메커니즘 구현")가 가리키는 대상을 공식 근거로 확정하지 못했다. 가이드 문구에 서비스 예시가 없다. 공식 문서에서 "skew"/"hot"이 쓰이는 영역(Spark/Glue 스큐·AQE·솔팅, Redshift 분산 스큐와 `SVV_TABLE_INFO`, DynamoDB 핫 파티션·write sharding, Kinesis 핫 샤드·split)을 3-4.md에 영역별로 정리했다. 이 중 시험이 어느 쪽을 주로 묻는지는 알 수 없다. Kinesis 핫 샤드에 대해 리샤딩 문서는 split 중심이고, "change the partition key scheme to increase its distribution"이라는 파티션 키 변경 대안은 Big Data 블로그에만 있다.
  - 확인 시도: Glue/Spark 스큐와 Kinesis 핫 샤드는 검색으로, Redshift 분산 스타일·`SVV_TABLE_INFO`와 DynamoDB 파티션 키 설계 문서는 직접 열어 확인.
  - 후속: 사람 검수 시 우선순위 판단(Glue/Spark 스큐 + Redshift 분산 키가 가장 데이터 엔지니어링 서비스 중심).
  - 근거 URL: https://docs.aws.amazon.com/prescriptive-guidance/latest/tuning-aws-glue-for-apache-spark/optimize-shuffles.html · https://docs.aws.amazon.com/redshift/latest/dg/c_best-practices-best-dist-key.html (직접) · https://docs.aws.amazon.com/streams/latest/dev/kinesis-using-sdk-java-resharding-strategies.html · https://aws.amazon.com/blogs/big-data/optimize-write-throughput-for-amazon-kinesis-data-streams/

- G-3.4-03 [확인필요] Glue Studio의 규칙 실패 시 잡 실패 옵션 설명이 옵션명과 어긋나 보인다. 튜토리얼은 "Fail job after loading data to target"에 대해 "The job fails and no data is saved."라고 적고(적재 후 실패인데 "no data is saved"), 바로 뒤 문장에서 결과를 저장하려면 Amazon S3 위치를 고르라고 한다. "no data"가 데이터 대상 적재가 아니라 DQ 결과를 뜻할 가능성도 있으나 문서에 명시가 없다. 3-4.md는 문구가 명확한 "None"(기본)과 "Fail job without loading to target data"만 사용했다.
  - 확인 시도: tutorial-data-quality `.md` 원문의 해당 단계를 2026-10-19에 재확인.
  - 후속: 콘솔에서 실제 동작을 확인하거나 문서 개정을 기다릴 것.
  - 근거 URL: https://docs.aws.amazon.com/glue/latest/dg/tutorial-data-quality.html

- G-3.4-04 [확인필요] Glue Data Quality 규칙 유형 정의를 규칙 유형별 페이지에서 확인했지만 출처 수 한도(20)로 3-4.md에는 IsComplete만 넣었다. 학습문서에서 필요하면 아래 평문 문장을 인용할 수 있다(2026-10-19에 각 페이지 `.md` 원문과 대조해 일치 확인).
  - ReferentialIntegrity: "Checks to what extent the values of a set of columns in the primary dataset are a subset of the values of a set of columns in a reference dataset." https://docs.aws.amazon.com/glue/latest/dg/dqdl-rule-types-ReferentialIntegrity.html (직접)
  - DatasetMatch: "Checks if the data in the primary dataset matches the data in a reference dataset." https://docs.aws.amazon.com/glue/latest/dg/dqdl-rule-types-DatasetMatch.html (직접)
  - Completeness: "Checks the percentage of complete (non-null) values in a column against a given expression." https://docs.aws.amazon.com/glue/latest/dg/dqdl-rule-types-Completeness.html (직접)
  - Uniqueness: "Checks the percentage of unique values in a column against a given expression." https://docs.aws.amazon.com/glue/latest/dg/dqdl-rule-types-Uniqueness.html (직접)
  - DetectAnomalies: "Detects anomalies for a given data quality rule." https://docs.aws.amazon.com/glue/latest/dg/dqdl-rule-types-DetectAnomalies.html (직접)
  - 제약: "DQDL doesn't currently support nested or list-type column data." https://docs.aws.amazon.com/glue/latest/dg/dqdl-rule-types.html (직접) · DynamicRules 관련 서술은 https://docs.aws.amazon.com/glue/latest/dg/dqdl.html
  - 확인 시도: 2026-10-17에는 DQDL 참조(dqdl)와 IsComplete 페이지를 읽었고, 위 5개 규칙 유형 페이지는 2026-10-19에 직접 열어 문장을 확인했다.
  - 후속: 취합 세션이 필요하면 추가.

- G-3.4-05 [상충] DataBrew 프로파일 잡의 대상 행 수. JobSample API 문서는 기본 CUSTOM_ROWS·20,000행이고 FULL_DATASET 모드(전체 데이터셋)도 있다고 한다. AWS for SAP 블로그(2021-02-19)는 "기본적으로 첫 20,000행으로 제한되며 더 큰 데이터셋은 서비스 한도 증설을 요청한다"고 적어 구 동작일 가능성이 있다. 3-4.md는 API 문서 값만 사용했다. DataBrew 서비스 쿼터 페이지는 확인하지 않았다.
  - 확인 시도: API_JobSample `.md`와 블로그 비교.
  - 후속: 쿼터 페이지(DataBrew endpoints and quotas) 확인 후 필요하면 보강.
  - 근거 URL: https://docs.aws.amazon.com/databrew/latest/APIReference/API_JobSample.html · https://aws.amazon.com/blogs/awsforsap/implementing-a-continual-learning-machine-learning-pipeline-with-amazon-sagemaker-aws-glue-databrew-and-sap-s-4hana/

- G-3.4-06 [확인필요] 시험 범위상 Glue Data Quality의 위치. DEA-C01 in-scope 목록의 Analytics에는 "AWS Glue"와 "AWS Glue DataBrew"가 있고 "AWS Glue Data Quality"라는 별도 항목은 없다(MLA-C01 in-scope 목록은 AWS Glue Data Quality를 별도로 적는다). Skill 3.4.2·3.4.3의 예시는 DataBrew다. Glue Data Quality가 AWS Glue에 포함되는 것으로 보이나 확정 근거는 없다.
  - 확인 시도: DEA in-scope 목록과 MLA in-scope 목록 대조(2026-10-19 재대조).
  - 후속: 학습문서는 DataBrew(3.4.2·3.4.3)와 Glue Data Quality(3.4.1)를 모두 다루되, 사람 검수에서 출제 가능성 판단.
  - 근거 URL: https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-in-scope-services.html · https://docs.aws.amazon.com/aws-certification/latest/machine-learning-engineer-associate-02/mla-02-in-scope-services.html

- G-3.4-07 [개명·종료] 표기 참고. Glue Data Quality 문서는 기반 프레임워크를 "DeeQu"로 적고, Big Data 블로그(set-up-alerts…)는 "the underlying open-source project Deequ"로 적는다. 3-4.md는 Glue 문서 표기를 따랐다. 또 Glue Data Quality 알림의 EventBridge 이벤트 source 값은 EventBridge 이벤트 레퍼런스와 Glue 알림 문서에서 `aws.glue-dataquality`인데, 블로그 본문은 "aws-glue-dataquality"라고 적는다.
  - 확인 시도: glue-data-quality `.md`, data-quality-alerts, EventBridge 이벤트 레퍼런스, 블로그를 2026-10-19에 대조.
  - 후속: 학습문서에서 이벤트 패턴 예시를 쓸 때 EventBridge 이벤트 레퍼런스 값을 기준으로 할 것.
  - 근거 URL: https://docs.aws.amazon.com/glue/latest/dg/glue-data-quality.html (직접) · https://docs.aws.amazon.com/glue/latest/dg/data-quality-alerts.html · https://docs.aws.amazon.com/eventbridge/latest/ref/events-ref-glue-dataquality.html · https://aws.amazon.com/blogs/big-data/set-up-alerts-and-orchestrate-data-quality-rules-with-aws-glue-data-quality/

- G-3.4-08 [확인필요] 3-4.md 출처 20개 중 11개(S1, S5, S6, S8, S10, S12, S13, S16, S17, S18, S19)는 검색 도구가 반환한 URL이 아니다. 문서 파일명을 구성해 `.md`를 직접 요청하고 HTTP 200과 인용문 일치를 확인했다. 나머지 9개(S2, S3, S4, S7, S9, S11, S14, S15, S20)는 검색 결과에 나온 URL이다. 브리프 §2.3("도구가 실제로 반환한 URL만")에서 벗어나므로 남긴다.
  - 확인 시도: 전사 기록에서 출처 URL이 검색 결과에 처음 나타난 지점을 대조.
  - 후속: 컨트롤러가 이 11개를 그대로 둘지 판단(전부 HTTP 200, 56개 인용 전부 원문 일치).
  - 근거 URL: https://docs.aws.amazon.com/glue/latest/dg/glue-data-quality.html (직접) · https://docs.aws.amazon.com/databrew/latest/dg/projects.html (직접) · https://docs.aws.amazon.com/athena/latest/ug/select.html (직접) · https://docs.aws.amazon.com/redshift/latest/dg/c_best-practices-best-dist-key.html (직접)

### Task 4.1 — Apply authentication mechanisms (인증 메커니즘 적용)

- G-4.1-01 [분할제안] Task 4.1은 Skill 7개·서비스 10여 개(보안 그룹·Glue·IAM·엔드포인트·Secrets Manager·Lambda·API Gateway·CLI·CloudFormation·Redshift·EMR·S3 Access Points·SageMaker Unified Studio)를 다루어 출처 43개·사실 63행으로 목표 규모(출처 15~25개)를 넘겼다. 학습문서는 3개로 나누길 제안한다(결정은 취합 세션).
  - 문서 ① 네트워크·접근 경로(Skill 4.1.1 + 4.1.2의 VPC 엔드포인트 + 4.1.5의 엔드포인트 정책·S3 Access Points): 노트 소제목 1·3·5 일부, 사실 #1~#12·#16~#19·#43~#45·#63, 출처 S1~S6·S10~S12·S30~S32.
  - 문서 ② 자격 증명 회전과 서비스용 역할(Skill 4.1.3 + 4.1.4 + 4.1.2의 IAM 그룹·역할 + 4.1.5의 정책 평가): 소제목 2·4·5 일부, 사실 #13~#15·#20~#42, 출처 S7~S9·S13~S29.
  - 문서 ③ 관리형 vs 비관리형 + SageMaker Unified Studio(Skill 4.1.6 + 4.1.7): 소제목 6·7, 사실 #46~#62, 출처 S33~S43. 4.1.7은 Skill 4.5.6(SageMaker Catalog 프로젝트로 데이터 액세스 관리)·2.2.6(비즈니스 데이터 카탈로그)과 거버넌스 문서로 묶는 방안도 가능.
  - 이유: 문서당 출처 약 12~16개로 CLF 학습문서 규모와 비슷해지고, 시험 패턴(경로 진단 / 회전·역할 / 도메인 설계)이 문서 경계와 맞는다. 중복 출처: S12(엔드포인트 정책: ①·②), S25(EMR 역할)·S7(그룹).
  - 인접 Task 경계: IAM 정책 작성·최소 권한(4.1.5) ↔ 4.2.1·4.2.6, Secrets Manager 회전(4.1.3) ↔ 4.2.2(Secrets Manager vs Parameter Store), Redshift COPY용 역할(4.1.4) ↔ 4.2.3, EMR 런타임 역할 ↔ 4.2.4(Lake Formation).
  - 확인 시도: 노트 소제목별 출처·사실 행 매핑 점검. 후속: 취합 세션이 분할 확정 후 문항 후보 재배치(후보 1·3·4→①, 후보 2→②, 후보 5→③).
  - 근거 URL (컨트롤러 보강): 구조·범위 판단 항목(외부 문서 인용 없음). 근거 기준: 공식 가이드 https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain4.html 및 tasks/4-1.md 출처 목록

- G-4.1-02 [상충] SageMaker Unified Studio IAM 기반 도메인 개수 한도 표현이 문서마다 다르다. "Domains in Amazon SageMaker Unified Studio"(https://docs.aws.amazon.com/sagemaker-unified-studio/latest/adminguide/working-with-domains.html)는 "Only one IAM-based domain is available per AWS Account." 라고 쓰고, "IAM-based domains and projects"(https://docs.aws.amazon.com/sagemaker-unified-studio/latest/adminguide/iam-based-domains.html)는 "Only one IAM-based domain is available per AWS Account per region." 라고 쓴다(노트 사실 #51·#52에 둘 다 기록).
  - 확인 시도: 두 페이지 원문을 직접 읽음. 후속: 콘솔/Service Quotas 또는 문서 수정 확인 전까지 문항에서 "리전당/계정당" 구분을 정답 근거로 쓰지 말 것.

- G-4.1-03 [불확실] Skill 4.1.2 "endpoints, and services"와 Skill 4.1.5 "endpoints, and services"가 무엇을 가리키는지 공식 근거로 확정할 수 없다. 노트는 "endpoints = VPC 엔드포인트(Gateway/Interface)", "services = 서비스 역할·서비스 연결 역할(및 서비스 리소스 정책)"로 해석했다. PrivateLink "엔드포인트 서비스"(NLB 뒤 서비스를 공급자가 노출)를 만드는 작업일 가능성도 있으나 가이드 문구로는 구분되지 않는다.
  - 가장 가까운 근거: https://docs.aws.amazon.com/vpc/latest/privatelink/gateway-endpoints.html, https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create-service-linked-role.html. 후속: 취합 세션 판단. 엔드포인트 서비스(공급자 측)는 노트에서 다루지 않음.

- G-4.1-04 [불확실] Skill 4.1.6 "관리형 vs 비관리형 서비스의 차이"는 어떤 서비스 쌍을 묻는지 가이드만으로 확정할 수 없다. 노트는 공동 책임 모델(https://aws.amazon.com/compliance/shared-responsibility-model/)과 Prescriptive Guidance(https://docs.aws.amazon.com/prescriptive-guidance/latest/strategy-accelerating-security-maturity/understanding-the-security-scope.html)로 일반 원칙만 기록했다. 시험은 EC2 자가 관리 DB/Hadoop vs RDS/EMR 같은 운영 오버헤드 시나리오로 나올 것으로 추정(추정).
  - 본문 미반영 후보 근거: RDS는 "To deliver a managed service experience, Amazon RDS doesn't provide shell access to DB instances."(https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/MySQL.Concepts.FeatureSupport.html). 후속: 필요 시 RDS·Redshift·Glue의 관리 범위를 별도 수집.

- G-4.1-05 [불확실] 보안 그룹 서비스별 요건 중 EMR·MSK·Redshift·RDS 고유 규칙(포트, EMR 관리형 SG 규칙)은 본문에 담지 못했다. 본문은 Glue·Lambda(VPC)·회전 Lambda 중심이다.
  - 확인된 EMR 후보 사실(본문 미반영): "You can apply up to 15 additional security groups for the primary instance"(https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-additional-sec-groups.html), "An additional managed security group for service access is required when you create a cluster in a private subnet."(https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-man-sec-groups.html). 후속: MSK·Redshift 포트 규칙은 해당 Task(1.x/2.x) 노트에서 다루는지 확인 후 필요 시 추가.

- G-4.1-06 [상충] S3 액세스 포인트 개수 한도: 공식 문서는 계정·리전당 10,000(https://docs.aws.amazon.com/AmazonS3/latest/userguide/access-points-restrictions-limitations-naming-rules.html)이고 "A bucket can have up to 10,000 access points attached"(https://docs.aws.amazon.com/AmazonS3/latest/userguide/access-management.html)다. 오래된 AWS Public Sector 블로그(https://aws.amazon.com/blogs/publicsector/creating-access-control-mechanisms-highly-distributed-datasets/)는 "up to 1,000 Amazon S3 Access Points per Region"으로 쓰여 있다. 공식 문서 2건을 우선해 본문(사실 #43·#44)에 10,000을 사용했고 블로그 값은 구버전으로 판단한다.
  - 확인 시도: 세 페이지 비교. 후속: 문항에서 이 수치를 정답 근거로 쓸 때 Service Quotas 최신값 재확인.

- G-4.1-07 [확인필요] "IAM-based domains do not support Trusted identity propagation"는 블로그(https://aws.amazon.com/blogs/big-data/using-amazon-sagemaker-unified-studio-identity-center-idc-and-iam-based-domains-together/)의 "at the time of writing this blog" 시점 기준 문구라 현재 지원 여부를 확인하지 못했다. 본문에는 쓰지 않았다. 공식 문서에는 Identity Center 기반 도메인의 "Trusted identity propagation" 토픽이 있다(https://docs.aws.amazon.com/sagemaker-unified-studio/latest/adminguide/identity-center-based-domains.html). 후속: 공식 관리자 가이드에서 IAM 기반 도메인의 TIP 지원 여부 확인.

- G-4.1-08 [불확실] "Set up projects within an Identity Center-based domain"(https://docs.aws.amazon.com/sagemaker-unified-studio/latest/adminguide/setup-projects-idc-based-domains.html) 페이지는 제목과 달리 본문이 IAM 기반 도메인 프로젝트를 설명한다(검색 chunk: "Projects in IAM-based domains provide isolated environments for data analytics and AI/ML development work." / "All members of a project within an IAM-based domain have the same access to data and compute."). 제목/본문 불일치로 보여 본문에서는 이 페이지를 인용하지 않고 블로그(S43)로 같은 취지(프로젝트 사용자가 같은 역할 권한 공유)를 기록했다. 후속: 문서 수정 여부 확인.

- G-4.1-09 [개명·종료] SageMaker 도메인 명칭이 둘로 나뉜다. 관리 콘솔에서 두 가지 도메인을 만들 수 있다: "There are two types of domains that your admin can create in the Amazon SageMaker Unified Studio management console. If your admin grants you access to an Amazon DataZone domain, see Amazon DataZone projects and environments in the Amazon DataZone User Guide."(https://docs.aws.amazon.com/sagemaker-unified-studio/latest/userguide/projects.html). Identity Center 기반 도메인 문서의 토픽에는 "Create an Amazon DataZone domain"과 "Upgrade Amazon DataZone domains to Amazon SageMaker unified domains"가 있다(https://docs.aws.amazon.com/sagemaker-unified-studio/latest/adminguide/identity-center-based-domains.html). 노트는 Skill의 "SageMaker Unified Studio의 도메인"을 "Amazon SageMaker unified domain"으로 해석했다.
  - 개정 가이드는 "Amazon SageMaker Catalog"(Skill 2.2.6·2.4.4·4.5.6)라는 이름을 쓴다(https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-revisions.html). 구 명칭과의 정확한 대응(SageMaker Lakehouse/Data Catalog 등)은 확인하지 못했다. 후속: 4.5·2.2 담당 노트와 용어 합의.

- G-4.1-10 [확인필요] Secrets Manager 회전 최신 변경(본문 미반영): re:Post는 "In December 2024, Secrets Manager changed how it validates entities that call the PutSecretValue API action as part of the rotation process."라며 교차 계정·assume role 회전 함수가 rotation token을 전달해야 한다고 안내한다(https://repost.aws/knowledge-center/secrets-manager-secret-rotation). 또 회전 Lambda 리소스 정책은 Secrets Manager 서비스 주체에 lambda:InvokeFunction 권한을 주고 aws:SourceAccount 조건을 권장한다("permission to the Secrets Manager service principal in the resource policy of the Lambda function", https://docs.aws.amazon.com/secretsmanager/latest/userguide/rotate-secrets_turn-on-for-other.html). 출제 가능성은 낮다고 판단(추정). 후속: 필요 시 노트에 추가.

- G-4.1-11 [확인필요] AWS PrivateLink 인터페이스 엔드포인트 요금 숫자는 본문에 넣지 않았다. 가격 페이지(https://aws.amazon.com/privatelink/pricing/)에서 GB당 처리 요금 구간("First 1 PB $0.01", "Next 4 PB $0.006", "Anything over 5 PB $0.004")은 확인했으나 시간당 요금은 수집하지 못했고, 시험은 숫자가 아니라 "게이트웨이 무료 vs 인터페이스 유료" 구분을 묻는다고 판단(추정). 후속: 필요 시 가격 페이지에서 시간당 요금까지 확인해 추가.

- G-4.1-12 [확인필요] 교차 계정 비밀 접근에서 효력이 있는 작업은 20여 개로 제한된다(예: GetSecretValue, PutResourcePolicy, RotateSecret 등). 본문 미반영(https://docs.aws.amazon.com/secretsmanager/latest/userguide/auth-and-access_examples_cross.html). 후속: 필요 시 목록 추가.

- G-4.1-13 [수정제안] 코디네이터 지침(표 셀·링크/코드 서식·문장부호 주변 공백이 대조 실패의 주원인)에 따라 4-1.md 사실 표와 문항 후보의 인용 104개를 원문 .md(docs.aws.amazon.com 페이지는 URL의 .html을 .md로 바꿔 curl로 읽음)와 대조했다(공백 정규화 후 포함 여부). 4-1.md는 완성본이라 수정하지 않았고, 아래는 컨트롤러 대조에서 실패할 것으로 예상되는 인용과 검증된 대체 인용이다. 나머지 86개는 .md 원문과 일치했다.
  - (a) 원문 .md에 링크 서식이 있어 불일치: 행 #10 두 번째 인용 "To access Amazon S3 from within your VPC, a VPC endpoint is required."(원문은 "a [VPC endpoint](...) is required") → 인용 삭제 권장(본문 서술 유지). 행 #23 두 인용 "createSecret: Create a new version of the secret", "finishSecret: Finish the rotation"(원문은 링크·백틱 제목) → 대체 "Four steps in a rotation function" 또는 "Finally, the Lambda rotation function moves the label"(둘 다 .md에서 일치 확인, https://docs.aws.amazon.com/secretsmanager/latest/userguide/rotate-secrets_lambda-functions.html). 행 #24 첫 인용 "uses staging labels to identify secret versions during rotation"(원문은 "uses [staging labels](...) to identify") → 대체 "to identify secret versions during rotation". 행 #47 두 번째 인용 "Using managed services is a best practice in the AWS Well-Architected Framework."(링크) → 대체 "Using managed services is a best practice in the"(https://docs.aws.amazon.com/prescriptive-guidance/latest/strategy-accelerating-security-maturity/understanding-the-security-scope.html). 행 #58 "A project profile is a collection of blueprints which are configurations used to create projects."(blueprints 링크) → 대체 "which are configurations used to create projects"(https://docs.aws.amazon.com/sagemaker-unified-studio/latest/adminguide/project-profiles.html).
  - (b) .md가 없어(HTTP 404) 대조 방법이 불명한 페이지: 행 #22(https://docs.aws.amazon.com/help-panel/secretsmanager/latest/console/rotation-separate-creds-rds-pane.html), 행 #35(https://docs.aws.amazon.com/cli/latest/topic/config-vars.html). 두 행은 MCP 검색 chunk 원문으로 확인했다.
  - (c) docs.aws.amazon.com 밖이라 .md 대조를 못 한 인용: 행 #11·#12·#42(repost.aws), #46(aws.amazon.com 공동 책임 모델), #62(AWS Big Data Blog). MCP 검색 chunk 원문으로 확인했다.
  - 확인 시도: 인라인 점검 스크립트로 4-1.md 인용 104개를 원문 .md와 문자열 대조(저장 파일 없음). 후속: 컨트롤러가 대조 실패 시 해당 행의 인용만 위 대체 인용으로 교체하거나 행을 삭제.

### Task 4.2 — Apply authorization mechanisms (권한 부여 메커니즘 적용)

- G-4.2-01 [분할제안] Task 4.2는 Skill 6개·출처 25개·사실 40행으로 학습문서 1개도 가능하지만 IAM 정책 영역과 데이터 계층(저장소·DB·Lake Formation) 영역이 갈려 2개 분할을 제안한다(결정은 취합 세션).
  - 문서 ① IAM 정책·권한 부여 방식·최소 권한(Skill 4.2.1 + 4.2.5 + 4.2.6): 노트 소제목 1·5·6, 사실 #1~#6·#31~#40, 출처 S1~S4·S22~S24.
  - 문서 ② 자격 증명 저장·DB 권한·Lake Formation(Skill 4.2.2 + 4.2.3 + 4.2.4): 소제목 2·3·4, 사실 #7~#30, 출처 S5~S21·S25. LF-TBAC(S17)는 문서 ①의 4.2.5(태그 기반)에서도 재사용.
  - 인접 Task 경계: 4.2.2의 Secrets Manager 회전·교차 계정·VPC 엔드포인트 ↔ 4.1.3(4-1.md), 4.2.1·4.2.6의 정책 평가·ID 기반 vs 리소스 기반 ↔ 4.1.5(4-1.md), 4.2.4의 데이터 필터·LF-Tag ↔ Task 4.5(Skill 4.5.6 SageMaker Catalog 프로젝트로 데이터 액세스 관리).
  - 확인 시도: 노트 소제목별 출처·사실 행 매핑 점검. 후속: 취합 세션이 분할을 확정한 뒤 문항 후보를 재배치(후보 1·2·3은 ②, 후보 5는 ①, 후보 4는 LF-TBAC 소재라 ②에 두거나 ①·②에 중복 배치).
  - 근거 URL (컨트롤러 보강): 구조·범위 판단 항목(외부 문서 인용 없음). 근거 기준: 공식 가이드 https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain4.html 및 tasks/4-2.md 출처 목록

- G-4.2-02 [확인필요] Skill 4.2.5의 v1.1 개정은 사실만 기록하고 이유는 확인하지 못했다. 개정 페이지 표는 v1.1 "Skill 4.2.5: Apply authorization methods that address business needs (role-based, tag-based, and attribute-based)."와 v1.0 "Knowledge of: Authorization methods (role-based, policy-based, tag-based, and attribute based)"를 나란히 보여 주어 'policy-based'가 빠진 점을 확인해 준다. 페이지는 변경 이유를 설명하지 않고 "Knowledge items in Version 1.0 that overlapped with existing skills were removed in Version 1.1."이라는 일반 문구만 있다. 표 셀 문장이라 인용 대조 위험이 커서 사실 표에는 넣지 않고 본문 서술(출처 S24)과 이 항목에만 기록했다.
  - 확인 시도: https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-revisions.html 전체 읽음(2026-10-17). 후속: 시험에서 policy-based가 더 이상 평가 대상이 아닌지는 알 수 없으므로 문항에서 policy-based를 정답 근거로 쓰지 말 것.

- G-4.2-03 [확인필요] Skill 4.2.6의 v1.1 개정도 문구 변경만 확인했다: v1.0 "Knowledge of: Principle of least privilege as it applies to AWS security" → v1.1 "Skill 4.2.6: Construct custom policies that meet the principle of least privilege."(같은 페이지의 표 셀). 변경 이유는 적혀 있지 않다.
  - 확인 시도: 위 개정 페이지. 후속: 취합 세션이 "개념 이해 → 정책 구성"으로 문항 난이도를 올릴지 판단(추정이므로 근거 없이 단정하지 말 것).
  - 근거 URL 보강(컨트롤러, 2026-10-19 열람·인용문 원문 확인): https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-revisions.html · https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain4.html

- G-4.2-04 [불확실] Skill 4.2.3 "database users, groups, and roles ... (for example, for Amazon Redshift)"가 정확히 무엇을 묻는지 공식 근거로 확정할 수 없다. 노트는 Redshift RBAC·열 수준 권한·RLS·DDM·IAM 임시 자격 증명(GetClusterCredentials)과 RDS IAM 인증으로 해석했다. 사용자 그룹(CREATE GROUP)과 GRANT 구문, Redshift의 IAM Identity Center 연동(IdC 그룹이 Redshift 역할 이름과 매칭됨: "these match up with role names in Redshift", https://docs.aws.amazon.com/redshift/latest/mgmt/redshift-iam-access-control-idp-connect-console.html), 신규 Redshift federated permissions(https://docs.aws.amazon.com/redshift/latest/dg/federated-permissions-onboarding.html)는 본문에서 다루지 않았다.
  - 확인 시도: Redshift RBAC·RLS·DDM·GRANT·GetClusterCredentials·IdC 페이지 검색/읽기(2026-10-17). 후속: 취합 세션이 IdC 연동·federated permissions를 4.2.3에 넣을지 Task 4.5로 보낼지 결정.
  - 근거 URL 보강(컨트롤러, 2026-10-19 열람·인용문 원문 확인): https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain4.html (Skill 4.2.3 원문)

- G-4.2-05 [확인필요] "Parameter Store에는 내장 자동 회전이 없다"를 명시한 공식 문장은 찾지 못했다. 노트의 비교 표는 PutParameter가 지원하는 정책 유형을 Expiration·ExpirationNotification·NoChangeNotification으로 나열한 사실(https://docs.aws.amazon.com/systems-manager/latest/APIReference/API_PutParameter.html)에서 '회전 유형의 정책 없음'만 적었다. 공식 Secrets Manager vs Parameter Store 비교 페이지도 찾지 못했다.
  - 확인 시도: Parameter Store tier·policies·KMS·공유 페이지와 Secrets Manager 소개·요금 페이지 읽음. 후속: 문항에서 "Parameter Store는 회전을 지원하지 않는다"를 정답 근거로 쓰기 전에 공식 비교 문서를 확인.

- G-4.2-06 [확인필요] 표 셀·서식 때문에 인용 대조가 위험해 본문에 넣지 않은 수치(출처 URL만 기록): (a) Secrets Manager 단가 "$0.40 / secret / month"와 "$0.05/10,000 calls"(https://aws.amazon.com/secrets-manager/pricing/ 의 예시 계산 표), (b) Secrets Manager 한도 — 비밀 500,000개, 비밀당 버전 100개, 스테이징 레이블 20개, 리소스 정책 20,480자, GetSecretValue 초당 10,000건(https://docs.aws.amazon.com/general/latest/gr/asm.html 의 표), (c) Parameter Store 처리량 기본 40 TPS와 높은 처리량(https://docs.aws.amazon.com/systems-manager/latest/userguide/parameter-store-throughput.html 의 표), (d) Parameter Store 티어 비교 표(https://docs.aws.amazon.com/systems-manager/latest/userguide/parameter-store-advanced-parameters.html; 본문 수치는 PutParameter 문장으로 대체).
  - 확인 시도: 위 페이지를 직접 읽어 값을 확인(2026-10-17). 후속: 필요하면 취합 세션이 사실 행으로 추가(표 셀 문자열만 따로 인용하면 대조될 가능성이 있으나 서식 유무를 확인할 것).

- G-4.2-07 [상충] IAM 자격 증명당 관리형 정책 연결 한도 표현이 문서마다 다르다. IAM 정책 검사 참조는 "You can attach up to 20 managed policies to an IAM identity (user, group of users, or role)."(https://docs.aws.amazon.com/IAM/latest/UserGuide/access-analyzer-reference-policy-checks.html)라고 쓰지만, AWS General Reference의 IAM 한도 표는 사용자 10(조정 가능)·그룹 10(조정 불가)·역할 20(조정 가능)(https://docs.aws.amazon.com/general/latest/gr/iam-service.html)이고, re:Post는 한도 상향 후 "up to 25 managed policies to IAM roles and 20 managed policies for IAM users"(https://repost.aws/knowledge-center/iam-increase-policy-size)라고 쓴다. 관리형 정책 길이는 6,144자(같은 표·정책 검사 참조). 4.2.1 본문에는 이 수치를 쓰지 않았다.
  - 확인 시도: 세 페이지 비교(2026-10-17). 후속: Service Quotas 최신값 확인 후 문항 사용 여부 결정.

- G-4.2-08 [확인필요] Lake Formation 명명된 리소스 vs LF-TBAC 선택 기준의 명시 문장은 별도 튜토리얼에 있다: "We recommend using named resources if the data lake administrator prefers granting permissions explicitly to individual resources."(https://docs.aws.amazon.com/lake-formation/latest/dg/share-dl-tbac-tutorial.html). 출처 수 상한 때문에 4-2.md에는 넣지 않고 비교 표에서 "LF-TBAC 권장 조건의 대안"으로 해석했다. 교차 계정 공유 v3(LF-Tag를 Organizations 수준으로 공유, 특정 IAM 주체에게 직접 공유)는 블로그(https://aws.amazon.com/blogs/big-data/aws-lake-formation-2022-year-in-review/)에서만 확인했다.
  - 확인 시도: LF 교차 계정·TBAC 페이지와 튜토리얼 검색. 후속: 필요 시 튜토리얼 페이지를 출처로 추가.

- G-4.2-09 [확인필요] Lake Formation 통합 서비스별 지원 범위 표(예: Athena Spark·EMR on EKS 미지원, Hive on EMR(EC2)는 행·셀 수준 미지원, Glue는 5.0 이상에서 열·행 읽기 지원)는 표 셀이라 본문에 넣지 않았다(https://docs.aws.amazon.com/lake-formation/latest/dg/working-with-services.html). 시험이 서비스별 제약을 묻는지는 불확실하다.
  - 확인 시도: 해당 페이지 검색 chunk 확인(2026-10-19). 후속: 필요 시 취합 세션이 반영.

- G-4.2-10 [확인필요] 하이브리드 접근 모드 세부 — 기본 집행 범위("The hybrid access mode enforces only CREATE_TABLE, CREATE_PARTITION, UPDATE_TABLE permissions by default."), IAMAllowedPrincipals 그룹 권한, 위치를 등록하지 않으면 옵트인해도 자격 증명 공급(credential vending)이 안 됨 — 은 코드 서식이 낀 문장이라 사실 표에서 제외했다(https://docs.aws.amazon.com/lake-formation/latest/dg/hybrid-access-mode.html, https://docs.aws.amazon.com/lake-formation/latest/dg/hybrid-access-workflow.html).
  - 확인 시도: 두 페이지 검색 chunk 확인(2026-10-19). 후속: 필요 시 서술형으로 보강.

- G-4.2-11 [불확실] Skill 4.2.1 "managed policy가 요구를 충족하지 못할 때 사용자 지정 IAM 정책 만들기"가 JSON 정책 문법(조건 연산자, NotAction, 리소스 수준 권한, 정책 변수)까지 묻는지 공식 근거로 확정할 수 없다. 노트는 정책 유형 선택·조건 평가·권한 경계·SCP/RCP 위주로 썼고 리소스 수준 권한·정책 변수·Principal 요소 규칙·정책 크기 한도는 다루지 않았다(Principal·정책 평가는 4-1.md). 가장 가까운 근거: https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements_condition.html, https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html.
  - 확인 시도: 정책 유형·조건·권한 경계 페이지 읽음. 후속: 취합 세션 판단.

- G-4.2-12 [개명·종료] Amazon QuickSight → Amazon Quick: Lake Formation 통합 서비스 페이지는 현재 "Amazon Quick Enterprise Edition"으로 표기한다(https://docs.aws.amazon.com/lake-formation/latest/dg/service-integrations.html). 구 FAQ(https://aws.amazon.com/lake-formation/faqs/)는 "Amazon QuickSight"로 쓴다. 4-2.md 본문은 QuickSight/Quick을 다루지 않았다.
  - 확인 시도: 두 페이지의 검색 chunk 대조. 후속: 문항에서 QuickSight를 쓸 때 현재 명칭을 확인.

- G-4.2-13 [개명·종료] Redshift 문서 상단 배너가 "Amazon Redshift will no longer support the use of Python UDFs after June 30, 2026."이라고 알린다(예: https://docs.aws.amazon.com/redshift/latest/dg/r_roles-default.html). 반면 DDM 페이지는 마스킹을 "user-defined functions written in SQL, Python, or with AWS Lambda"로 구현할 수 있다고 쓴다(https://docs.aws.amazon.com/redshift/latest/dg/t_ddm.html). 4-2.md 본문은 UDF 언어를 다루지 않았다.
  - 확인 시도: 두 페이지 검색 chunk 대조(2026-10-17). 후속: DDM 문항에서 Python UDF 마스킹을 정답 근거로 쓰지 말 것.

### Task 4.3 — Ensure data encryption and masking (데이터 암호화 및 마스킹 보장)

- G-4.3-01 [상충] KMS 요청 쿼터 수치가 같은 페이지 안에서 다르다. "Request quotas for each AWS KMS API operation" 표는 대칭 암호화 연산 기본값을 10,000(shared) / 20,000(shared, us-east-2·ap-southeast-1·ap-southeast-2·ap-northeast-1·eu-central-1·eu-west-2·eu-south-2) / 100,000(shared, us-east-1·us-west-2·eu-west-1)로 적었고, "API requests made on your behalf" 문단의 S3 SSE-KMS 예시는 "5,500 (or 10,000 or 50,000 depending upon your AWS Region)"로 적었다.
  - 확인 시도: https://docs.aws.amazon.com/kms/latest/developerguide/requests-per-second.html 전문 read_documentation (표와 문단이 같은 페이지).
  - 후속: Service Quotas 콘솔 값을 최종 근거로 삼고, 문항은 숫자 암기형을 피하고 "쿼터는 조정 가능, SSE-KMS/서비스 대행 요청도 합산, AWS 소유 키는 미산입" 개념으로만 출제.

- G-4.3-02 [불확실] Redshift 암호화 스냅샷 공유 문서(working-with-snapshot-share-snapshot.html)는 "고객 관리형 키를 복원 계정과 공유해야 한다"고 쓰면서 같은 절의 Note에서 "If you're using a default KMS key, you don't need to take action or change anything in AWS KMS in order to share a snapshot"라고 쓴다. 반면 re:Post의 Aurora/RDS 스냅샷 공유 문서는 "기본 KMS 키로 암호화된 스냅샷은 공유할 수 없다"고 쓴다. Redshift에서 "default KMS key"가 무엇을 가리키는지(AWS 소유 키? AWS 관리형 키?) 문서만으로 확정할 수 없다.
  - 확인 시도: Redshift Sharing a snapshot 페이지 chunk, re:Post "How do I share an encrypted Amazon Aurora snapshot with another account?" chunk.
  - 후속: Redshift 스냅샷 공유 문서 전문(및 데이터 공유 vs 스냅샷 공유 구분) 확인 전까지 "default KMS key" 관련 문항화 금지. 본문 4-3.md는 "고객 관리형 키 공유 필요, 미공유 시 access-denied"만 기록.
  - 근거 URL 보강(컨트롤러, 2026-10-19 열람·인용문 원문 확인): https://docs.aws.amazon.com/redshift/latest/mgmt/working-with-snapshot-share-snapshot.html ("If you're using a default KMS key, you don't need to take action or change anything in AWS KMS in order to share a snapshot." 확인) · https://repost.aws/knowledge-center/aurora-share-encrypted-snapshot ("You can't share a snapshot that's encrypted with the default AWS KMS key." 확인) · https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/share-encrypted-snapshot.html

- G-4.3-03 [확인필요] Athena 해시 함수(md5·sha256·xxhash64 등) 목록은 AWS 문서에서 확인하지 못했다. "Athena engine version 3 functions" 페이지는 "Functions in Athena engine version 3 are based on Trino"라고만 쓰고 목록은 Trino 문서로 위임한다. AWS 페이지에서 확인된 해시 관련 항목은 engine version 3 reference의 murmur3(binary) 하나와, Hive view 문맥의 "md5(binary) 지원 / md5(varchar) 미지원" 뿐이다.
  - 확인 시도: https://docs.aws.amazon.com/athena/latest/ug/functions-env3.html , engine-versions-reference-0003.html , hive-views.html.
  - 후속: Trino 공식 문서 또는 Athena 실제 쿼리로 확인. 그 전까지 문항에서는 "Athena SQL 해시 함수로 컬럼 해시" 수준 이상으로 출제 금지. 본문 4-3.md에는 Athena 해시를 넣지 않았다.

- G-4.3-04 [확인필요] "key salting"(솔트) 정의를 AWS 공식 문서에서 확인하지 못했다. 공식 문서에서 확인된 것은 Redshift DDM 예제 `sha2(credit_card + 'testSalt', 256)`와 `ALTER ... 'otherTestSalt'` 코드뿐이고, Well-Architected 데이터 분석 렌즈 3.1(익명화·가명처리·토큰화)에도 'salt' 정의는 없다. 비AWS 자료(OpenSearch 프로젝트 문서)에 "the salt (a random string used to hash your data)"라는 정의가 있다 [3자] https://docs.opensearch.org/latest/security/access-control/field-masking/ . 또한 v1.1 가이드 페이지(domain4)는 Skill 문구만 있고 Knowledge 목록이 없어 salting의 출제 범위를 가이드로 확인할 수 없다.
  - 확인 시도: search_documentation(salt hash pseudonymization 등 3회), Well-Architected 3.1 전문(앞 9,000자), domain4 가이드 페이지.
  - 후속: 취합 세션이 salting을 다룰지 결정. 다룬다면 Redshift DDM 예제 + 일반 정의는 [3자] 표기 또는 AWS 블로그 근거 추가 필요.

- G-4.3-05 [개명·종료] S3 Object Lambda(PII 읽기 시점 마스킹/삭제 패턴): S3 사용자 가이드 튜토리얼 상단 공지에 "As of November 7th, 2025, S3 Object Lambda is available only to existing customers that are currently using the service as well as to select AWS Partner Network (APN) partners." 신규 고객에게는 닫힘. 4.3.1 노트 본문에는 넣지 않았다(가이드 범위 밖).
  - 확인 시도: https://docs.aws.amazon.com/AmazonS3/latest/userguide/tutorial-s3-object-lambda-redact-pii.html chunk, https://aws.amazon.com/about-aws/whats-new/2025/10/aws-service-availability/ chunk(maintenance 목록에 S3 Object Lambda).
  - 후속: "읽을 때 PII 가리기" 보기 중 S3 Object Lambda가 등장하면 오답/구식 선택지로 취급할지 취합 세션이 결정.

- G-4.3-06 [개명·종료] Redshift Python UDF: Redshift 문서 상단 배너 "Amazon Redshift will no longer support the use of Python UDFs after June 30, 2026. We will start enforcing it in phases." 본문 4-3.md에 반영(S22). DDM 문서는 아직 UDF를 "SQL, Python, or with AWS Lambda"로 설명하므로 DDM 해시 정책의 Python UDF 영향 범위와 권장 대체(SQL UDF/Lambda)는 공식 마이그레이션 블로그(2025-06-30)에서 확인 필요.
  - 확인 시도: t_ddm.html, t_ddm-conditional.html, serverless-workgroups-and-namespaces-rotate-kms-key.html 배너.
  - 후속: Python UDF 종료 상세 블로그 확인 후 DDM 항목 보강.
  - 근거 URL 보강(컨트롤러, 2026-10-19 열람·인용문 원문 확인): https://docs.aws.amazon.com/redshift/latest/dg/t_ddm.html (배너 문구와 "SQL, Python, or with AWS Lambda" 모두 확인)

- G-4.3-07 [확인필요] Glue DataBrew 수명주기: 조회한 "AWS Service Availability Updates" 요약 4건(2025-10, 2026-03, 2026-06, 2026-09)의 maintenance/sunset 목록에는 DataBrew가 없었지만 요약본이 전체 목록인지 확인하지 못했다. 같은 요약에서 "AWS Glue - Ray Jobs Feature", "AWS CloudTrail Lake", "Amazon SNS - Message Data Protection (MDP) Feature", "Amazon S3 Object Lambda" 등이 maintenance로 표기됨(타 Task 관련 메모).
  - 확인 시도: aws.amazon.com/about-aws/whats-new/.../aws-service-availability/ 4건 chunk, docs.aws.amazon.com/general/latest/gr/service-lifecycle.html (Maintenance 정의).
  - 후속: AWS Product Lifecycle 페이지(aws.amazon.com/product-lifecycle) 전체 목록을 직접 확인.
  - 근거 URL 보강(컨트롤러, 2026-10-19 열람·인용문 원문 확인): https://aws.amazon.com/about-aws/whats-new/2025/10/aws-service-availability/ · https://aws.amazon.com/about-aws/whats-new/2026/03/aws-service-availability/ (SNS Message Data Protection·CloudTrail Lake 포함) · https://aws.amazon.com/about-aws/whats-new/2026/06/aws-service-availability/ (Kendra·Q Business·Bedrock Agents Classic 포함) · https://aws.amazon.com/about-aws/whats-new/2026/09/aws-service-availability/ (게시 Sep 29, 2026)

- G-4.3-08 [불확실] Redshift DDM 제약 서술이 문서마다 다르다. 구 AWS Big Data Blog(2022, "How dynamic data masking support in Amazon Redshift helps achieve data privacy and compliance")는 "그룹 미지원, 뷰·머터리얼라이즈드 뷰·외부 테이블에 마스킹 정책 생성 불가"를 적었고, 현행 개발자 가이드 t_ddm-considerations.html은 정책을 붙일 수 없는 relation 목록(시스템 테이블, 외부 테이블, 데이터셰어링 테이블, 교차 DB, 임시 테이블, 상관 쿼리)에 뷰를 포함하지 않으며 "뷰를 조회하면 조회자의 마스킹 정책이 적용된다"고 적었다. 본문은 현행 가이드만 인용했다.
  - 확인 시도: 블로그 chunk, t_ddm-considerations.html chunk.
  - 후속: 그룹 지원 여부·뷰에 정책 연결 가능 여부는 현행 CREATE/ATTACH MASKING POLICY 레퍼런스에서 재확인.
  - 근거 URL 보강(컨트롤러, 2026-10-19 열람·인용문 원문 확인): https://aws.amazon.com/blogs/big-data/how-dynamic-data-masking-support-in-amazon-redshift-helps-achieve-data-privacy-and-compliance/ ("groups are not supported" 확인) · https://docs.aws.amazon.com/redshift/latest/dg/t_ddm-considerations.html

- G-4.3-09 [불확실] "before transit"(전송 전 암호화)라는 표현 자체는 AWS 공식 문서에서 찾지 못했다(전용 검색 1회 + S3/DynamoDB/Kinesis/EMR 문서 확인). 노트는 이를 "클라이언트 측 암호화(데이터를 보내기 전에 로컬에서 암호화)"로 해석했다. 가장 가까운 공식 설명은 AWS 보안 블로그 "Encryption in transit over external networks: AWS guidance for NYDFS and beyond"의 소제목 "Pre-encryption of data to be sent to AWS"이고, 문서 근거 문구는 S3 "To encrypt your objects before you send them to Amazon S3", DynamoDB "you encrypt your table data before you send it to your database", Kinesis "encrypt data on the client side before putting the data into Kinesis", EMR "Objects are encrypted before being uploaded to Amazon S3"이다. 즉 "해석은 근거 있음, 가이드 문구와의 1:1 대응은 미확정".
  - 확인 시도: search_documentation("encrypt data before transit ...") 상위 결과(AWS 보안 블로그, Prescriptive Guidance), UsingClientSideEncryption.html, client-server-side.html(Database Encryption SDK), Kinesis FAQ, EMR encryption options.
  - 후속: 시험 가이드 v1.1 개정 근거(`dea-01-revisions`)에서 "before transit"의 의도를 확인할 수 있는지 컨트롤러 확인. 문항에서는 "전송 전 = 클라이언트 측 암호화"로 쓰되 용어 해설을 함께 제시 권장.
  - 근거 URL 보강(컨트롤러, 2026-10-19 열람·인용문 원문 확인): https://aws.amazon.com/blogs/security/encryption-in-transit-over-external-networks-aws-guidance-for-nydfs-and-beyond/ · https://docs.aws.amazon.com/AmazonS3/latest/userguide/UsingClientSideEncryption.html · https://docs.aws.amazon.com/database-encryption-sdk/latest/devguide/client-server-side.html · https://aws.amazon.com/kinesis/data-streams/faqs/ · https://docs.aws.amazon.com/emr/latest/ReleaseGuide/emr-emrfs-encryption-cse.html

- G-4.3-10 [확인필요] Glue Studio Detect PII 문서는 Glue 2.0 / 3.0 / 4.0 차이만 설명하고 "Fine-grained actions is only available in AWS Glue 3.0 and 4.0"라고 쓴다. 최신 Glue 버전(5.x)에서의 지원 여부는 확인하지 못했다.
  - 확인 시도: detect-PII.html 전문, sensitive-data-fine-grained-actions.html chunk.
  - 후속: Glue 최신 버전 지원 표 확인.
  - 근거 URL 보강(컨트롤러, 2026-10-19 열람·인용문 원문 확인): https://docs.aws.amazon.com/glue/latest/dg/sensitive-data-fine-grained-actions.html ("Fine-grained actions is only available in AWS Glue 3.0 and 4.0." 확인) · https://docs.aws.amazon.com/glue/latest/dg/detect-PII.html

- G-4.3-11 [확인필요] Macie 기능 페이지(aws.amazon.com/macie/features) chunk에 "Amazon Macie is available both as a standalone service and as a core capability within AWS Security Hub (Preview)"라는 문구가 있다. Preview 상태·현행 제공 형태를 확인하지 못했다(4.5.2와 연계).
  - 확인 시도: aws.amazon.com/macie/features chunk.
  - 후속: Security Hub 통합 Macie의 GA 여부 확인.
  - 근거 URL 보강(컨트롤러, 2026-10-19 열람·인용문 원문 확인): https://aws.amazon.com/macie/features/ ("standalone service and as a core capability within AWS Security Hub" 확인)

- G-4.3-12 [확인필요] AWS Encryption SDK 자체 개발자 가이드(docs.aws.amazon.com/encryption-sdk)는 직접 읽지 못했다. 노트는 KMS 문서(cryptography essentials, 요청 쿼터)의 언급과 AWS 블로그/Prescriptive Guidance 문구만 근거로 삼았다(본문에는 KMS 문서 인용만 사용).
  - 확인 시도: search_documentation에서 Encryption SDK 전용 페이지가 상위 결과로 나오지 않음.
  - 후속: Encryption SDK 개발자 가이드에서 data key caching 보안 임계값, 지원 언어, 키링 개념 확인.
  - 근거 URL (컨트롤러 보강): 구조·범위 판단 항목(외부 문서 인용 없음). 근거 기준: 공식 가이드 https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain4.html 및 tasks/4-3.md 출처 목록

- G-4.3-13 [분할제안] Task 4.3은 Skill 4개지만 분량이 커서 학습문서 1개는 과하다. 제안: (문서 A) "마스킹·PII 보호" = 4.3.1 + 4.5.2(PII 식별: Macie) 일부, (문서 B) "암호화 — 저장 시(KMS·S3·서비스별)·교차 계정·전송 중/전 암호화" = 4.3.2 + 4.3.3 + 4.3.4. 결정은 취합 세션.
  - 확인 시도: 해당 없음(분량 판단).
  - 후속: 취합 세션.
  - 근거 URL (컨트롤러 보강): 구조·범위 판단 항목(외부 문서 인용 없음). 근거 기준: 공식 가이드 https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain4.html 및 tasks/4-3.md 출처 목록

- G-4.3-14 [확인필요] 최신 S3 암호화 변경(참고, 본문 미반영): (a) 2026-01 UpdateObjectEncryption API로 데이터 이동 없이 객체의 서버 측 암호화 유형 변경 가능(https://aws.amazon.com/about-aws/whats-new/2026/01/change-the-server-side-encryption-type-of-s3-objects/), (b) 2025-11 버킷 수준 설정으로 쓰기 요청의 암호화 유형 강제(SSE-S3/SSE-KMS 허용, SSE-C 차단) (https://aws.amazon.com/about-aws/whats-new/2025/11/amazon-s3-bucket-level-standardize-encryption-types/). 시험 가이드(2025-12 게시) 범위 안인지 불명.
  - 확인 시도: search_documentation(current_awareness) 결과 chunk.
  - 후속: 문항화 여부는 취합 세션 판단.

- G-4.3-15 [확인필요] 본 노트에서 다루지 않은 항목(범위 밖/미조사): KMS 키 삭제 대기 기간, kms:ViaService 조건 키(검색은 했으나 본문 미반영), Glue Data Catalog 암호화 설정(Metadata encryption, Encrypt connection passwords), Lake Formation 데이터 필터 제한 사항(data-filtering-notes.html), Redshift 암호화 클러스터의 HSM 연동 세부, Athena 쿼리 결과 암호화. 필요하면 후속 조사.
  - 확인 시도: 각 항목은 검색 chunk만 확인(전문 미독).
  - 후속: 취합 세션이 필요 항목을 지정하면 추가 조사.
  - 근거 URL (컨트롤러 보강): 구조·범위 판단 항목(외부 문서 인용 없음). 근거 기준: 공식 가이드 https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain4.html 및 tasks/4-3.md 출처 목록

### Task 4.4 — Prepare logs for audit (감사용 로그 준비)

- G-4.4-01 [개명·종료] CloudTrail Lake는 2026-05-31부터 신규 고객에게 닫혔다. 가용성 변경 문서: Lake는 신규 고객에게 열리지 않고, 기존 고객은 계속 사용하며 Lake에는 중요한 버그 수정·보안 업데이트만 제공되고, trail·Insights·집계 이벤트는 영향이 없으며, CloudWatch로 이전을 권고하고 2023년 이전 데이터는 이전되지 않는다. 그런데 공식 가이드 v1.1 Skill 4.4.3은 "Use AWS CloudTrail Lake for centralized logging queries."로 Lake를 그대로 포함한다. 본문 반영: 4-4.md 4.4.3 소절·시험 패턴 3·함정 5/10·사실 행 20~23·문항 후보 3.
  - 확인 시도: https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-lake-service-availability-change.html , https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-lake.html , https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain4.html
  - 후속: Lake 개념(이벤트 데이터 스토어·SQL·보존·조직 통합·비용 모델)은 다루되 "현재 신규 고객 중단"을 병기한다. "지금 새로 만들 수 있다"는 전제의 문항은 피한다. 가이드가 앞으로 개정되어 Lake를 빼는지는 확인하지 못했다.

- G-4.4-02 [수정제안] 레포 `flutter_app/assets/exam_guides/DEA-C01.json`의 Task 4.4 `skills[2]` "중앙 집중식 로깅 쿼리에 AWS CloudTrail Lake 사용"은 공식 번역 정본이므로 문구를 바꾸지 않는 것을 권한다. 대신 앱의 학습문서 머리말이나 Skill 안내에 Lake 신규 고객 중단 상태를 병기하는 방안을 제안한다. 참고: JSON `skills`에는 Skill 번호가 없고 배열 순서로만 식별되며, `knowledge` 배열은 Task 3.3·4.4 모두 비어 있다(공식 v1.1 페이지도 두 Task에 Skill만 나열하므로 일치함).
  - 확인 시도: `flutter_app/assets/exam_guides/DEA-C01.json` 251~262행(읽기 전용), 공식 가이드 domain4 페이지.
  - 후속: 취합 세션이 앱 안내 방식을 결정.
  - 근거 URL (컨트롤러 보강): 구조·범위 판단 항목(외부 문서 인용 없음). 근거 기준: 공식 가이드 https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain4.html 및 tasks/4-4.md 출처 목록

- G-4.4-03 [상충] CloudTrail Lake 관련 공식 문서 사이에 상태 서술이 어긋난다. (a) 가용성 변경 문서(S8)는 중단과 CloudWatch 이전을 권고한다. (b) Lake 개요 페이지(S9)의 상단 Note는 "AWS CloudTrail Lake will no longer be open to new customers starting May 31, 2026."와 "If you would like to use CloudTrail Lake, sign up prior to that date."로, 날짜가 지난 지금도 미래형이다. (c) Athena "Query AWS CloudTrail logs"(S11)는 중단 언급 없이 SQL 쿼리에 Lake 사용을 권한다("consider using CloudTrail Lake"). (d) CloudTrail concepts 페이지에는 "CloudTrail Lake and event data stores" 절이 있고 중단 공지가 없다. 4-4.md는 S8을 기준으로 쓰고 S11의 시차를 본문에 표시했다.
  - 확인 시도: https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-lake-service-availability-change.html , https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-lake.html , https://docs.aws.amazon.com/athena/latest/ug/cloudtrail-logs.html , https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-concepts.html
  - 후속: S8을 우선하고, Athena 쪽 문장을 근거로 "Lake를 권장"하는 문항은 만들지 말 것.

- G-4.4-04 [상충] CloudTrail Lake 이벤트 데이터 스토어 최대 보존 7년형 2,557일 vs 2,555일. 사용자 가이드 Lake 페이지와 CreateEventDataStore API 레퍼런스는 "up to 2557 days"(약 7년)이라 하고, re:Post Knowledge Center 문답 "How do I use CloudTrail to review what API calls and actions have occurred in my AWS account?"는 "up to seven years, or 2,555 days"라 한다. 4-4.md는 2,557일을 쓴다(사실 행 24).
  - 확인 시도: https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-lake.html , https://docs.aws.amazon.com/awscloudtrail/latest/APIReference/API_CreateEventDataStore.html , https://repost.aws/knowledge-center/cloudtrail-track-api
  - 후속: 정확한 일수를 정답 근거로 쓰지 말 것(7년/약 10년 수준으로만).

- G-4.4-05 [상충] CloudTrail이 S3에 전달하는 로그 파일의 기본 암호화 방식. CloudTrail FAQ는 "By default, CloudTrail will encrypt log files delivered to your S3 bucket using S3 server-side encryption."이라 하는데, 보안 모범 사례 문서는 "By default, the log files delivered by CloudTrail to your S3 bucket are encrypted by using server-side encryption with a KMS key (SSE-KMS)."라 한다. 4-4.md는 FAQ 쪽(기본 SSE, SSE-KMS는 추가 계층)을 적고 상충을 표시했다(핵심 개념 4.4.1·사실 행 7).
  - 확인 시도: https://aws.amazon.com/cloudtrail/faqs/ , https://docs.aws.amazon.com/awscloudtrail/latest/userguide/best-practices-security.html
  - 후속: "기본 암호화가 SSE-S3인가 SSE-KMS인가"를 직접 묻는 문항은 피한다. "KMS 키 비활성·정책 오류 시 로그 전달 실패"처럼 합의된 사실만 쓴다.

- G-4.4-06 [상충] CloudWatch Logs Delivery 로그 클래스의 보존 기간. 로그 클래스 문서는 "kept in CloudWatch Logs for two days"(고정, 변경 불가)라 하고, CreateLogGroup API 레퍼런스는 "kept in CloudWatch Logs for only one day"라 한다. 4-4.md는 Delivery 클래스의 보존 일수를 적지 않았다.
  - 확인 시도: https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CloudWatch_Logs_Log_Classes.html , https://docs.aws.amazon.com/AmazonCloudWatchLogs/latest/APIReference/API_CreateLogGroup.html
  - 후속: Delivery 클래스 일수를 묻는 문항은 만들지 말 것. 용도(Lambda 로그를 S3·Firehose로 전달, Logs Insights 불가)만 사용.

- G-4.4-07 [개명·종료] Centralized Logging with OpenSearch 솔루션 종료 예정은 G-3.3-07과 같다. 4-4.md는 S23(솔루션 개요 페이지)·사실 행 35·4.4.4 표와 4.4.5 문단·함정 12에 반영했다.
  - 확인 시도: https://docs.aws.amazon.com/solutions/latest/centralized-logging-with-opensearch/solution-overview.html
  - 후속: G-3.3-07 참조.

- G-4.4-08 [개명·종료] Kinesis Data Firehose는 Amazon Data Firehose로 개명됐다(Firehose API 레퍼런스: "Amazon Data Firehose was previously known as Amazon Kinesis Data Firehose."). 일부 문서에는 구명칭이 남아 있다(예: CloudWatch FAQ의 "Amazon Kinesis Data Firehose HTTP endpoint"). 4-4.md와 3-3.md는 신명칭을 쓴다.
  - 확인 시도: https://docs.aws.amazon.com/firehose/latest/APIReference/Welcome.html , https://aws.amazon.com/cloudwatch/faqs/
  - 후속: 보기에 구명칭이 나와도 같은 서비스로 취급.

- G-4.4-09 [확인필요] VPC Flow Logs 게시 대상(CloudWatch Logs·S3·Amazon Data Firehose) 근거를 CloudTrail FAQ의 비교 문답(S1, 사실 행 34)에서 인용했다. 더 직접적인 VPC 사용 설명서 페이지가 있으나 출처 수 상한 때문에 채택하지 않았다: https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs-firehose.html ("Publish flow logs to Amazon Data Firehose"), https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs-s3.html ("Publish flow logs to Amazon S3"). CloudWatch Logs 게시 페이지 URL은 확인하지 못했다.
  - 확인 시도: 문서 검색으로 위 두 페이지 확인.
  - 후속: 취합 시 직접 근거로 교체 가능.

- G-4.4-10 [불확실] Skill 4.4.5 "Integrate various AWS services to perform logging (for example, Amazon EMR in cases of large volumes of log data)"의 EMR 예시가 무엇을 가리키는지 가이드 문구로 확정할 수 없다. (a) EMR 클러스터로 대용량 로그를 분석·처리한다는 뜻인지, (b) EMR 클러스터 자체의 로그를 수집한다는 뜻인지 불분명하다. 4-4.md는 (a)로 해석했고 근거는 Well-Architected REL06-BP05의 한 문장이다(사실 행 33). 3-3.md는 EMR 클러스터 로그(S22·S23)도 다룬다.
  - 확인 시도: 공식 가이드 domain4 페이지에 예시 이상의 설명이 없다. https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/rel_monitor_aws_resources_storage_analytics.html
  - 후속: 취합 세션이 해석을 확정.
  - 근거 URL 보강(컨트롤러, 2026-10-19 열람·인용문 원문 확인): https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain4.html (Skill 4.4.5 원문)

- G-4.4-11 [분할제안] 4.4의 Skill 4.4.1·4.4.2·4.4.4·4.4.5는 3.3의 3.3.5·3.3.7·3.3.8과 겹친다. 학습문서 경계 제안은 G-3.3-16 참조. 4-4.md는 "감사 준비·보존·무결성·중앙화" 관점, 3-3.md는 "운영·알림·분석" 관점으로 나눠 썼고 겹치는 부분은 서로 참조하되 각 파일 안의 사실에 자체 출처와 인용을 달았다.
  - 확인 시도: 두 가이드 페이지의 Skill 문구 대조(위 URL).
  - 후속: 취합 세션이 공통 문서 여부를 결정.
  - 근거 URL (컨트롤러 보강): 구조·범위 판단 항목(외부 문서 인용 없음). 근거 기준: 공식 가이드 https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain4.html 및 tasks/4-4.md 출처 목록

### Task 4.5 — Understand data privacy and governance (데이터 프라이버시 및 거버넌스 이해)

- G-4.5-01 [확인필요] "Amazon Macie with Lake Formation"(Skill 4.5.2)의 공식 근거: 제품 문서에서 Macie finding을 Lake Formation이 직접 소비하는 연동 설정은 확인하지 못했다. 확인된 공식 근거는 AWS 보안 블로그의 참조 아키텍처 하나뿐이다 — Macie가 S3 객체를 분석해 민감 값 식별 → EventBridge → Firehose → S3 → Glue 워크플로가 마스킹·암호화 → Lake Formation이 LF-Tag에 권한을 매핑. 본문 4-5.md는 이 구조를 "참조 아키텍처"로만 서술했다.
  - 확인 시도: search_documentation("Macie Lake Formation PII LF-tags") 상위 결과, 블로그 전문 앞 9,000자. 근거 URL: https://aws.amazon.com/blogs/security/data-masking-and-granular-access-control-using-amazon-macie-and-aws-lake-formation/
  - 후속: 블로그 이후의 신규 통합(예: Macie 결과를 Lake Formation 태그로 자동 반영)이 있는지 확인. 확인 전까지 문항에서 "Macie가 Lake Formation에 직접 통합" 같은 서술 금지.

- G-4.5-02 [상충] Redshift datashare "읽기 전용" 서술이 문서 간·문서 내에서 다르다. datashare-overview.html 도입부는 "secure, read-only access"라고 하면서 같은 페이지 다음 문단은 "both reads and writes"·"read and write data across Regions"라고 적었고, across-account.html은 "You can share data for read purposes across AWS accounts."만 말한다. datashare-considerations.html은 "Previously, objects in datashares were read only in all circumstances. Writing to an object in a datashare is a new feature."라고 적는다. 본문은 considerations 서술(쓰기 가능, 프로듀서가 쓰기 권한 부여 시)을 따랐다.
  - 확인 시도: https://docs.aws.amazon.com/redshift/latest/dg/datashare-overview.html (전문), https://docs.aws.amazon.com/redshift/latest/dg/across-account.html , https://docs.aws.amazon.com/redshift/latest/dg/datashare-considerations.html , https://docs.aws.amazon.com/redshift/latest/dg/getting-started-datashare-writes.html (chunk: 쓰기 공유는 provisioned patch 186 / Serverless 1.0.78890 이상 노트).
  - 후속: "datashare는 읽기 전용" 보기를 오답/구식으로 처리할지 취합 세션 결정. 쓰기 공유의 세부 제약("Unsupported SQL statements for data sharing writes on consumers" 등)은 미조사.

- G-4.5-03 [확인필요] "허용되지 않는 리전으로의 AWS Backup 복사 방지"(Skill 4.5.3): 교차 리전 복사를 특정 리전으로 제한·차단하는 방법을 직접 서술한 공식 문구를 확인하지 못했다. 확인한 것은 백업 계획의 복사 규칙(대상 리전·대상 볼트), Organizations 백업 정책의 regions·copy_actions 구문, 볼트 액세스 정책 동작 이름(backup:CopyFromBackupVault / backup:CopyIntoBackupVault)까지이며, backup:CopyTargets 조건 키 검색은 결과가 없었다. 추측을 피해 본문에는 "공식 통제 문구 미확인"으로만 적었다.
  - 확인 시도: https://docs.aws.amazon.com/aws-backup/latest/devguide/cross-region-backup.html , https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_backup_syntax.html , https://docs.aws.amazon.com/aws-backup/latest/devguide/logicallyairgappedvault.html (chunk)
  - 후속: AWS Backup 서비스 인가 참조(IAM 조건 키)와 Prescriptive Guidance(데이터 상주 가드레일)에서 확인.

- G-4.5-04 [확인필요] S3 복제 대상을 "특정 리전만 허용"하는 세분 통제: 본문 근거는 Control Tower 선택적 컨트롤(AWS-GR_RESTRICT_S3_CROSS_REGION_REPLICATION — 복제 구성 작업 s3:PutReplicationConfiguration을 막는 SCP)뿐이다. 복제 대상 리전·버킷을 조건으로 제한하는 조건 키는 확인하지 못했다. aws:RequestedRegion 문서는 s3:CreateBucket에 s3:LocationConstraint 조건 키를 쓸 수 있다고만 언급한다.
  - 확인 시도: https://docs.aws.amazon.com/controltower/latest/controlreference/elective-preventive-controls.html , https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_condition-keys.html
  - 후속: S3 복제 구성 관련 서비스 인가 참조·Prescriptive Guidance 확인.

- G-4.5-05 [개명·종료] Macie 문서가 결과 게시 대상을 "AWS Security Hub CSPM"으로 표기한다(이전 "AWS Security Hub"에서의 개명으로 보이나 공식 개명 공지는 이번에 확인하지 못함). 또 Macie 기능 페이지 chunk에 "Amazon Macie is available both as a standalone service and as a core capability within AWS Security Hub (Preview)" 문구가 있다.
  - 확인 시도: https://docs.aws.amazon.com/macie/latest/user/findings-monitor.html (전문), https://aws.amazon.com/macie/features/ (chunk)
  - 후속: 문항 서비스명 표기를 "Security Hub CSPM"으로 할지 결정, Security Hub 통합형 Macie의 GA 여부 확인(4.3 G-4.3-11과 연계).

- G-4.5-06 [확인필요] Control Tower OU Region deny 컨트롤(CT.MULTISERVICE.PV.1)의 경고 — "If you enforce this control, the configurations for the OU can conflict with the landing zone version of this control." — 와 "You must always include your AWS Control Tower home Region."는 출처 상한 때문에 본문에서 제외했다. SCP 컨트롤 정책 평가 순서("Policy evaluation of SCP controls")는 미조사.
  - 확인 시도: https://docs.aws.amazon.com/controltower/latest/controlreference/ou-region-deny.html (chunk), https://docs.aws.amazon.com/controltower/latest/controlreference/primary-region-deny-policy.html (chunk)
  - 후속: 랜딩존 컨트롤과 OU 컨트롤을 함께 쓰는 시나리오를 문항화할 때만 추가 조사.

- G-4.5-07 [확인필요] Skill 4.5.5(v1.1 개정) 데이터 주권: 가이드가 가리키는 공식 문서가 Well-Architected Digital Sovereignty Lens, AWS Digital Sovereignty Pledge, AWS European Sovereign Cloud 중 무엇인지 확정할 수 없다. 이번 조사는 용어 정의(Digital Sovereignty Lens), Data Privacy FAQ, S3 리전 격리, Control Tower 컨트롤까지다.
  - 확인 시도: search_documentation(digital sovereignty data residency), https://aws.amazon.com/what-is/data-sovereignty/ (chunk: Pledge 4개 영역), https://docs.aws.amazon.com/controltower/latest/controlreference/digital-sovereignty-controls.html (chunk)
  - 후속: `dea-01-revisions` 페이지로 4.5.5 개정 의도 확인 후 필요하면 Pledge·주권 통제 문서 추가.

- G-4.5-08 [불확실] SageMaker Catalog 구독 승인 주체가 도메인 유형별 문서에서 다르게 서술된다. IAM Identity Center 기반 흐름(approve-reject-subscription-request.html)은 "소유 프로젝트 멤버가 승인", IAM 기반 도메인(catalog-iam-manage-access.html)은 Domain management 관리자 포털의 Subscriptions > Requests에서 승인한다. 본문 4-5.md는 소유 프로젝트 멤버 승인(IDC 기반 흐름)을 기술했다.
  - 확인 시도: https://docs.aws.amazon.com/sagemaker-unified-studio/latest/userguide/approve-reject-subscription-request.html , https://docs.aws.amazon.com/sagemaker-unified-studio/latest/userguide/catalog-iam-manage-access.html (chunk)
  - 후속: 문항에서 도메인 유형을 명시하지 않으면 시비 소지가 있으므로 문항 지문에 도메인 유형을 쓰거나 승인 주체를 묻지 않는다. tasks/2-2.md도 같은 차이를 다룬다.

- G-4.5-09 [확인필요] SageMaker Catalog 비관리형(unmanaged) 자산 이행(승인 시 EventBridge 이벤트로 커스텀 grant 구성), 구독 요청 메타데이터 강제 규칙, 구독 해지(revoke)·취소, 데이터 제품 구독 승인은 출처 상한으로 본문에서 제외했다. 도메인·프로젝트·프로젝트 프로필 구조는 tasks/2-2.md, tasks/4-1.md와 중복을 피해 제외했다.
  - 확인 시도: https://docs.aws.amazon.com/sagemaker-unified-studio/latest/userguide/grant-access-to-unmanaged-asset.html (chunk), https://docs.aws.amazon.com/sagemaker-unified-studio/latest/userguide/discover-data.html (chunk), https://docs.aws.amazon.com/sagemaker-unified-studio/latest/userguide/review-grant-subscription-to-data-product.html (chunk)
  - 후속: 필요 시 추가 조사.

- G-4.5-10 [확인필요] Redshift 데이터 공유의 일반 고려사항(지원 노드 유형 RA3/Serverless, DC·DS 미지원, 정렬 키 요건, 공유 가능 객체)을 공식 "General considerations" 페이지에서 직접 확인하지 못했다(인덱스 페이지 datashare-considerations.html과 AWS 블로그 chunk만). 본문은 공식 페이지에서 확인한 암호화 요건(across-account.html)과 Lake Formation 제약(lake-formation-considerations.html)만 인용했다. 블로그 chunk에는 "Data sharing is supported for all provisioned RA3 instance types ... and Redshift Serverless. It isn't supported for clusters with DC and DS node types."가 있다.
  - 확인 시도: https://docs.aws.amazon.com/redshift/latest/dg/datashare-considerations.html (인덱스), https://aws.amazon.com/blogs/big-data/harness-zero-copy-data-sharing-from-salesforce-data-cloud-to-amazon-redshift-for-unified-analytics-part-2/ (chunk)
  - 후속: General considerations 하위 페이지 URL 확인 후 노드 유형·공유 객체 제약 보강.

- G-4.5-11 [확인필요] AWS Config의 규칙(managed/custom, 평가 트리거), 적합성 팩(conformance pack)·조직 적합성 팩, 기록 방식(연속/주기), 요금, 고급 쿼리 구문·API는 출처 상한으로 본문에서 제외했다. 적합성 팩은 "규칙과 교정 작업을 하나의 단위로 묶어 조직 전체에 배포"라는 검색 chunk만 확인했다.
  - 확인 시도: https://docs.aws.amazon.com/config/latest/developerguide/conformance-pack-organization-apis.html (chunk), https://docs.aws.amazon.com/config/latest/APIReference/API_SelectAggregateResourceConfig.html (chunk)
  - 후속: Skill 4.5.4 문항에 규칙·적합성 팩이 필요하면 추가 조사.

- G-4.5-12 [확인필요] Macie 부가 수치·한도(본문 미반영): findings 90일 보존(Macie stores findings for 90 days), 사용자 지정 식별자 regex 최대 512자, 압축·아카이브 분석 한도(최대 1,000,000개 파일·중첩 10단계), 30일 무료 체험.
  - 확인 시도: https://docs.aws.amazon.com/macie/latest/user/findings-monitor-events-eventbridge.html , https://docs.aws.amazon.com/macie/latest/user/cdis-options.html , https://docs.aws.amazon.com/macie/latest/user/discovery-supported-storage.html , https://docs.aws.amazon.com/macie/latest/user/account-mgmt-free-trial.html (모두 chunk)
  - 후속: 수치형 문항이 필요하면 전문 확인.

- G-4.5-13 [확인필요] Redshift 교차 리전 데이터 공유 비용(소비자가 교차 리전 전송 요금 부담, 쿼리당 10MB 최소 과금, 사용 한도 설정으로 로그·알림·교차 리전 공유 중단)은 출처 상한으로 본문에서 제외했다.
  - 확인 시도: https://docs.aws.amazon.com/redshift/latest/dg/cross-region-billing.html (chunk)
  - 후속: 비용 관련 문항이 필요하면 추가.

- G-4.5-14 [분할제안] Skill 7개를 학습문서 1개에 담기에는 주제가 이질적이다. 제안: (문서 A) "데이터 공유·거버넌스 패턴" = 4.5.1 + 4.5.6 + 4.5.7 — Redshift 데이터 공유, Lake Formation 관리 datashare, SageMaker Catalog 구독·승인·이행, Lake Formation 교차 계정 공유, S3 Access Points, Data Exchange. 이유: 모두 "누가 어떤 수단으로 어떤 권한을 부여해 공유하는가"로 묶이고, 4.5.6의 Redshift 이행이 datashare·Lake Formation에 의존한다. (문서 B) "프라이버시·상주·주권" = 4.5.2 + 4.5.3 + 4.5.5 — Macie PII 식별, 리전 통제(SCP·Control Tower·S3 복제·Backup), 데이터 주권. 이유: "민감 데이터를 찾고 → 허용되지 않은 리전으로 못 나가게 → 주권 요건 충족" 흐름. (문서 C) "구성 변경 조회" = 4.5.4(AWS Config) — 단독으로는 작으므로 Task 4.4(감사용 로그: CloudTrail 등) 문서와 합쳐 "감사·변경 추적" 문서로 묶는 대안도 검토. 4.3 분할제안(G-4.3-13)과 연동: 4.3.1+4.5.2를 "마스킹·PII" 문서로 따로 만들면 B에서 4.5.2를 그쪽으로 옮긴다.
  - 확인 시도: 해당 없음(분량·주제 판단).
  - 후속: 취합 세션이 결정.
  - 근거 URL (컨트롤러 보강): 구조·범위 판단 항목(외부 문서 인용 없음). 근거 기준: 공식 가이드 https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain4.html 및 tasks/4-5.md 출처 목록

- G-4.5-15 [수정제안] (4.3 노트 사후 점검 — 4-3.md는 이번 지시 범위 밖이라 수정하지 않았다) 라이브 페이지(.md 또는 HTML 텍스트)에 공백 정규화 후 문자열 포함 검사를 한 결과 4-3.md 인용 124개 중 다음 9개가 서식 때문에 자동 대조에서 실패할 위험이 있다. fact#20(S10: boto3 reference는 .md가 404이고 HTML에서 "Amazon Web Services managed KMS keys"가 링크라 마침표 앞 공백 문제), fact#26·#28·#29(S14 KMS 요청 한도: 링크·목록 서식), fact#40(S23 DynamoDB), fact#47(S38 S3 복제), fact#52(S31 멀티 리전 키), fact#55(S32 S3 버킷 정책 예시), fact#63(S16 KMS cryptography essentials). 추가로 서식 유형상 위험하나 위 스크립트는 통과한 행: fact#6(코드 sha2 예제), fact#27(표 셀), fact#9(페이지 상단 배너), fact#65(소제목). 같은 방법으로 4-5.md 인용 83개는 전부 원문과 그대로 일치했다(실패 0, 서식 의존 0).
  - 확인 시도: 인라인 PowerShell로 각 출처의 .md(또는 HTML 텍스트)를 받아 대조(파일 생성 없음).
  - 후속: 컨트롤러가 위 행의 인용을 서식 없는 일반 문단 문장으로 교체하거나 행을 삭제.
  - 근거 URL (컨트롤러 보강): 구조·범위 판단 항목(외부 문서 인용 없음). 근거 기준: 공식 가이드 https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain4.html 및 tasks/4-5.md 출처 목록
