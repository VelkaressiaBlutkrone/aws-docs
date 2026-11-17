# DEA 전수 검증 — 2026-11-17

> 범위: `flutter_app/assets/content/dea/` 학습문서 **17편** · 문항 **256개(전부 `verified: true` — 라이브)** · 가이드 `flutter_app/assets/exam_guides/DEA-C01.json`.
> 이 세션은 콘텐츠·코드·테스트를 **고치지 않았다**. 쓴 파일은 이 보고서 하나다.
> 방법: ① md 17편·문항 256개 **통독** → ② 패턴 전수 스캔(34종) → ③ 후보를 공식 문서로 대조(AWS 문서 리더 + `curl -sL` 추출, 대조군 병행) → ④ 중복(원형·조사벗김 자카드 32,640쌍)·`prescreen`·범위·커버리지 실측.
> ⚠️ **대조 범위의 한계를 먼저 적는다** — 통독·패턴 스캔·중복·prescreen 은 **전수**다. 공식 문서 본문 대조는 **전수가 아니다**: 문항 출처 고유 URL 363개 가운데 본문까지 읽어 맞댄 것은 **36개**(소개류 출처 15개는 전수, 나머지는 통독에서 후보로 잡힌 자리)이고, 대조하지 못한 주장은 §6-3에 목록으로 남겼다.

## 0. 요약

| 판정 | 수 | 뜻 |
|---|---|---|
| 🔴 | **5** | 사실이 거짓 · 정답이 둘 · 정답이 틀림 (즉시 수정) |
| 🟡 | **16** | 불완전·모호·출처가 사실을 담지 않음 (수정 권고) |
| 🟢 | **9** | 품질(길이 단서·메타 문구·중복) — 사실은 옳다 |
| ✅ | **32** | 통과(공식 대조로 확인한 사실·구조 항목 — §0-1) |

- **공개 문항 중 🔴: 2건** (`dea-t1-1-q7` · `dea-t1-4-q13`) — 둘 다 **정답 인덱스는 불변**이고 결함은 해설·오답 근거의 사실 오류다. 나머지 🔴 3건은 **라이브 학습문서 쪽**(문항 0)이다. **「정답이 둘」·「정답이 틀림」은 0건**이다.
- `prescreen`(`node tool/prescreen.mjs build dea` 실측): 구조·정합성 플래그 **0건** · 뱅크 플래그 **0 Task** / qualityFlags — length-cue **111** · meta-phrasing **13** · authoring-memo **0** · explanation-long **0** (전체 256문항 중 신호 117문항, 46%) / Task 내 중복 후보 **0쌍**.
- 검증한 출처 URL: 본문을 읽어 맞댄 페이지 고유 **67개** — 문항이 인용한 것 **36개**(문항 출처 고유 363개 중) · 학습문서만 인용한 것 11개 · DEA 가 인용하지 않는 공식 근거 페이지 20개 / 그중 「그 사실을 담지 않음」 **2개**(`cdk/v2/guide/home.html` · `cdk/v2/guide/constructs.html` — 둘 다 `dea-t1-4-q10`).
- 지난 보고(2026-11-06) 항목의 현재 상태: P1-DEA-1 **수정됨** · P2-DEA-1(EFO) **미수정**(→ 🔴 R1) · P2-DEA-2(Multi-AZ) **미수정이고 범위가 더 넓다**(→ 🟡 Y1) · P2-DEA-3 **일부만 수정**(→ 🟡 Y16).

### 0-1. ✅ 통과 32항목 (공식 대조로 확인 — 손대지 말 것)

| # | 주장(자리) | 근거 |
|---|---|---|
| 1 | KDS 데이터 블롭 최대 10 MiB (`dea-t1-1.md:99`) | `streams/latest/dev/service-sizes-and-limits.html` "up to 10 MiB" |
| 2 | 온디맨드 기본 쓰기 4 MB/s·읽기 8 MB/s (`dea-t1-1.md:98`) | 같은 페이지 "4 MB/s of write and 8 MB/s of read" |
| 3 | 등록 소비자 기본 20 · Advantage 50 (`dea-t1-1.md:110`) | 같은 페이지(R1 인용문) |
| 4 | 모드 전환 24시간 2회 | 같은 페이지 "twice within 24 hours" |
| 5 | Zero-ETL VARCHAR 65,535바이트 · 앱 소스 최소 지연 1시간 (`dea-t1-2-q6` c=0) | `redshift/latest/mgmt/zero-etl.reqs-lims.html` 원문 일치 |
| 6 | Glue Flex 최대 35% (`dea-t1-2-q2` c=0) | 인용 출처 `aws.amazon.com/glue/faqs/` "by up to 35%" (§6-1 참고) |
| 7 | SQS ESM 5 → 분당 +300 → 1,250 · provisioned mode 100,000 · maximum concurrency 와 상호 배타 (`dea-t1-4-q4` c=0) | `lambda/latest/dg/services-sqs-scaling.html` · `with-sqs.html` |
| 8 | `MaxConcurrentRuns` 기본 1 · 잡 큐잉이 **잡 단위 한도도** 덮음 · 15분·10회 (`dea-t1-2-q9` c=0) | `glue/latest/webapi/API_ExecutionProperty.html` + 인용 블로그 "Max concurrent job runs per job exceeded (…the configured parameter on the job)" |
| 9 | boto3 adaptive = 실험적 · 클라이언트 측 속도 제한, standard 백오프 최대 20초 (`dea-t3-1-q5` c=2) | `boto3/latest/guide/retries.html` |
| 10 | VPC 엔드포인트 기본 정책 = 전체 허용, ID·리소스 정책을 대체하지 않음 (`dea-t4-1-q7` c=2) | 인용 페이지 `IAM/latest/UserGuide/access_policies.html` 의 「VPC endpoint policies」 절이 **두 사실을 모두 담는다** |
| 11 | DynamoDB PITR 35일·초 단위·복구 기간 1~35일 (`dea-t2-3-q15` c=0) | 인용 페이지 `amazondynamodb/…/Introduction.html` 「Resilience」 절에 원문 있음 |
| 12 | CodeDeploy Lambda 전환 = canary·linear·all-at-once (`dea-t1-4-q13` c=0 의 정답) | `codedeploy/latest/userguide/deployment-configurations.html` |
| 13 | Kinesis ESM 기본 설정이면 불량 레코드가 샤드를 최대 1주 막음 | `lambda/latest/dg/kinesis-on-failure-destination.html` "up to one week" |
| 14 | COPY 파일 1 MB~1 GB·슬라이스 수의 배수·128 MB 이상 자동 분할 | `redshift/latest/dg/t_splitting-data-files.html` · `c_best-practices-use-multiple-files.html` |
| 15 | COPY/UNLOAD 클라이언트 측 암호화 2025-04-30 / 2026-04-30 (`dea-t2-3.md:84`) | `redshift/latest/dg/r_COPY.html` 원문 일치 |
| 16 | Redshift Serverless 기본 128 RPU · 1 RPU = 16 GB | `redshift/latest/mgmt/serverless-capacity.html` |
| 17 | 동시성 스케일링 쓰기는 RG·RA3 만 · 하루 1시간·최대 30시간 누적 | `redshift/latest/dg/concurrency-scaling.html` · `aws.amazon.com/redshift/pricing/` |
| 18 | S3 Tables compaction 기본 512MB(64~512MB) · MinimumSnapshots 1 · MaximumSnapshotAge 120시간 | `AmazonS3/latest/userguide/s3-table-buckets-maintenance.html` · `s3-tables-maintenance.html` |
| 19 | Logs Insights 쿼리당 최대 50개 로그 그룹 (`dea-t3-3.md:212`) | `AmazonCloudWatchLogs/latest/APIReference/API_StartQuery.html` |
| 20 | IA(현 Essentials) 클래스: 구독 필터·메트릭 필터·Live Tail·`GetLogEvents`/`FilterLogEvents` 미지원 · 클래스 변경 불가 · 수집 비용만 차이 (`dea-t3-3-q14` c=2 · `dea-t4-4-q7` c=2 의 정답) | `AmazonCloudWatch/latest/logs/CloudWatch_Logs_Log_Classes.html` 기능 표 |
| 21 | Centralized Logging with OpenSearch 2026-12 종료 | `solutions/latest/centralized-logging-with-opensearch/solution-overview.html` "will retire in December 2026" |
| 22 | Glue for Ray 2026-04-30 신규 고객 차단 | `glue/latest/dg/awsglue-ray-jobs-availability-change.html` |
| 23 | Glue 6.0 = Spark 4.1.1 | `glue/latest/dg/release-notes.html` |
| 24 | Lambda S3 Files 는 버킷 버저닝 필수 (`dea-t1-4-q8` c=0) | `cdk/api/v2/docs/aws-cdk-lib.aws_lambda-readme.html` · `AmazonS3/latest/userguide/s3-files-mounting-lambda.html` |
| 25 | Access Points 계정·리전당 10,000 · 정책 20 KB (`dea-t4-1.md:203`) | R4 인용문 |
| 26 | KMS 자동 회전 주기 90~2560일 | `aws.amazon.com/kms/faqs/` |
| 27 | 소개류 출처 **15개 URL(20자리) 전수** 키워드 대조 — DataBrew 250 · Transfer Family AS2·3 AZ · Step Functions 실행률 · KDS SSE · SAM · S3 Welcome(리전) · MWAA Serverless · Lake Formation · SCT · EMR · Macie · Athena · Quick · DynamoDB · CDK | 14개 통과, **`cdk/v2/guide/home.html` 1개만 불통과**(→ 🟡 Y6. 같은 문항의 `constructs.html` 은 소개류가 아니지만 함께 불통과) |
| 28 | 지난 P1-DEA-1(`dea-t1-2-q14` c=0 · `dea-t1-2.md:189`) 수정 반영 | 본문 실측 |
| 29 | 지난 P2-DEA-3 중 `dea-t1-2-q1`(c=0) 둘째 출처 교체 | 현재 `lambda/latest/dg/gettingstarted-limits.html` |
| 30 | 범위 외 서비스가 **정답**인 문항 0건 | 공식 범위 외 목록 45종 × 256문항(지문·보기·해설·오답 근거) + md 대조(§4-3) |
| 31 | 구조·정합성(스키마·`section`·`skill` 번호) — 플래그 0건, 가이드에 없는 스킬 번호 0건 | prescreen + 가이드 대조 |
| 32 | `MB/s` ↔ `MiB/s` **한 문항 안 혼용 0건**(문항 `MB/s` 14 · `MiB/s` 0 / md `MB/s` 17 · `MiB/s` 0) | 전수 스캔. 표기 통일은 권고하지 않는다 |

---

## 1. 🔴 (문항·학습문서)

### R1. `dea-t1-1-q7` + `dea-t1-1.md:132` — EFO 등록 소비자 한도의 단위가 틀렸다(「샤드당」 → 「데이터 스트림당」)

- **공개 여부**: verified true
- **현재 정답 인덱스**: 1 (불변 — 결함은 해설)
- **결함**: 해설이 「EFO 소비자를 **샤드당** 최대 20개까지」로 적는다. md `dea-t1-1.md:132` 표의 행도 「EFO 사용 시 **샤드당** 최대 20」이다. 한도의 단위는 **데이터 스트림**이다. 같은 md 의 `:110` 은 「등록 수 | 기본 20 (On-demand Advantage에서 50)」으로 옳게 적어 **문서 내부에서 어긋난다**. 지난 보고 P2-DEA-1 이 지적했고 **미수정**이다.
- **공식 근거**: `https://docs.aws.amazon.com/streams/latest/dev/service-sizes-and-limits.html` — 표의 행 「Number of registered consumers per data stream」: "With Kinesis On-demand Advantage mode, you can create up to 50 registered consumers (Enhanced Fan-out). With Kinesis On-Demand Standard and Kinesis Provisioned modes, you can create up to 20 registered consumers (Enhanced Fan-out Limit) **for each data stream**." 같은 페이지 `RegisterStreamConsumer` 행: "You can register up to 20 consumers **per data stream**."
- **수정안**:
  - `dea-t1-1-q7` 해설: 「EFO 소비자를 샤드당 최대 20개까지 붙여」 → 「EFO 소비자를 **데이터 스트림당** 최대 20개(On-demand Advantage 모드는 50개)까지 등록해」. 정답 인덱스·보기 불변.
  - `dea-t1-1.md:132`: 「EFO 사용 시 샤드당 최대 20」 → 「EFO 사용 시 **데이터 스트림당** 등록 소비자 최대 20(Advantage 50)」.
- **전수**: `샤드당 최대 20|샤드당 20` — DEA md **1자리**(`dea-t1-1.md:132`) · 문항 **1자리**(`dea-t1-1-q7` 해설). 다른 자격증 0파일.

### R2. `dea-t1-4-q13` — 오답 근거가 `rolling with additional batch` 를 CodeDeploy EC2/온프레미스 구성이라고 적는다

- **공개 여부**: verified true
- **현재 정답 인덱스**: 0 (`linear` — 불변)
- **결함**: `wrongExplanations["3"]` 가 「rolling with additional batch는 **EC2/온프레미스 배포 구성**으로 Lambda 전환 유형이 아닙니다」라고 적는다. 「Lambda 전환 유형이 아니다」는 참이지만 귀속이 거짓이다 — 그것은 **AWS Elastic Beanstalk 의 배포 정책**이고, CodeDeploy 의 EC2/온프레미스 사전 정의 구성은 `AllAtOnce`·`HalfAtATime`·`OneAtATime` 셋이다. 문항이 인용한 바로 그 페이지가 그 셋을 적는다.
- **공식 근거**:
  - `https://docs.aws.amazon.com/codedeploy/latest/userguide/deployment-configurations.html` — 「Predefined deployment configurations for an EC2/on-premises compute platform」 표의 행이 `CodeDeployDefault.AllAtOnce` · `CodeDeployDefault.HalfAtATime` · `CodeDeployDefault.OneAtATime` 셋뿐이다(이 사실은 **표의 행**에 있다).
  - `https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/using-features.rolling-version-deploy.html` — "AWS Elastic Beanstalk provides several options for how deployments are processed, including deployment policies (*All at once*, *Rolling*, *Rolling with additional batch*, *Immutable*, and *Traffic splitting*)".
- **수정안**: `W3` → 「rolling with additional batch는 AWS Elastic Beanstalk의 배포 정책이며 CodeDeploy의 Lambda 트래픽 전환 구성이 아닙니다.」 보기 문구·정답 인덱스 불변. (Elastic Beanstalk 는 공식 **범위 외** 목록에 있다 — 오답 보기로 쓰는 것은 무방하다.)
- **전수**: `rolling with additional batch` — DEA md **0자리** · 문항 **1건**(`dea-t1-4-q13` 보기[3] + `W3`). 다른 자격증 0파일. 새 출처 URL 은 `200 r=0` 실측.

### R3. `dea-t1-2.md:93` · `dea-t3-3.md:182` — 「버전을 지정하지 않은 Glue 잡은 5.1」이 낡았다(공식 기본은 6.0)

- **공개 여부**: 라이브 학습문서(문항 0)
- **현재 정답 인덱스**: 해당 없음
- **결함**: `dea-t1-2.md:93` 「최신은 Glue 6.0(…)이고, 버전을 지정하지 않고 만든 잡은 **5.1**로 생성됩니다」 · `dea-t3-3.md:182` 「버전을 지정하지 않고 만든 작업의 **기본 Glue 버전은 5.1** 입니다」. 같은 문장 안에서 「최신 6.0」과 「기본 5.1」을 나란히 적는데, 공식은 이제 6.0 을 기본으로 적는다.
- **공식 근거**: `https://docs.aws.amazon.com/glue/latest/dg/release-notes.html` — "AWS Glue 6.0 is the default version for jobs created without specifying an AWS Glue version." (보조: AWS SDK for Kotlin `CreateJobRequest.glueVersion` 문서 "Jobs that are created without specifying a Glue version default to Glue 6.0.")
- **수정안**: 두 자리 모두 「버전을 지정하지 않고 만든 잡은 **6.0**으로 생성됩니다」. 같은 줄의 「5.0부터는 모든 작업이 실시간 로깅 기능」 등 다른 서술은 손대지 않는다.
- **전수**: Glue 기본 버전 서술 — DEA md **2자리** · 문항 **0자리**(`5\.1` 로 걸리는 문항 4건은 전부 스킬 번호 `(4.5.1)` 이다 — 거짓 양성). `dea-t3-1.md:198` 「Visual ETL … Glue 4.0·5.0·5.1을 사용」은 **다른 주장**(대화형 세션 지원 버전)이고 이번에 대조하지 못했다(§6-3).

### R4. `dea-t4-5.md:203` · `:211` — S3 Access Points 한도를 「버킷당 10,000개」로 적는다(공식은 계정·리전당)

- **공개 여부**: 라이브 학습문서(문항 0)
- **현재 정답 인덱스**: 해당 없음
- **결함**: `dea-t4-5.md:203` 「**버킷당 최대 10,000개**이며 …」 · `:211` 표 「**버킷당 10,000개**, 버킷 정책과 함께 평가」. 같은 자격증의 `dea-t4-1.md:203` 은 「정책 크기는 20 KB, **계정·리전당** 최대 10,000개」로 옳게 적어 **두 문서가 서로 어긋난다**.
- **공식 근거**: `https://docs.aws.amazon.com/AmazonS3/latest/userguide/access-points-restrictions-limitations-naming-rules.html` — "You can create a maximum of 10,000 access points **per AWS account per AWS Region**. If you need more than 10,000 access points for a single account in a single Region, you can request a service quota increase."
- **수정안**: 두 자리의 「버킷당」 → 「**계정·리전당**」(증액 요청 가능). `dea-t4-1.md:203` 은 그대로 둔다.
- **전수**: `버킷당 최대 10,000|버킷당 10,000` — DEA md **2자리**(둘 다 `dea-t4-5.md`) · 문항 **0자리**. 다른 자격증 0파일.

### R5. `dea-t3-1.md:145` — 「현행 boto3 문서는 legacy 를 기본으로 적는다」가 거짓이 됐다

- **공개 여부**: 라이브 학습문서(문항 0 — `dea-t3-1-q5`(c=2)는 기본값을 묻지 않아 영향 없음)
- **현재 정답 인덱스**: 해당 없음
- **결함**: `:145` 「⚠️ 기본 모드가 무엇인지는 시점에 따라 다릅니다. **현행 boto3 문서는 legacy를 기본으로 적지만**, AWS는 … **2026년 11월에 standard를 기본으로** 만든다고 공지했습니다.」 — 오늘(2026-11-17) 현행 문서는 standard 를 기본으로 적는다. 같은 문서 `:250` 의 「boto3 기본 재시도 모드 … 는 **자료마다 달라** …」도 같은 이유로 낡았다.
- **공식 근거**: `https://docs.aws.amazon.com/boto3/latest/guide/retries.html` — "**Standard mode is the default mode used by any Boto3 client you create.**" · "Legacy mode was the default mode for Boto3 clients **before standard mode became the default**." · "If no configuration options are set, the default retry mode value is `standard`, and the default `max_attempts` value is 3 (total attempts including initial request), or 4 for Amazon DynamoDB and Amazon DynamoDB Streams."
- **수정안**: `:145` → 「기본 모드는 **standard** 입니다(예전 기본은 legacy 였고, 계속 쓰려면 `retry_mode = legacy` 를 명시합니다).」 「시점에 따라 다르다」는 경고와 `:250` 의 「자료마다 달라」 구절은 걷는다. `:141` 표의 「legacy | 5 (최초 요청 포함)」은 공식과 일치하므로 유지. 표에 standard 의 기본 시도 횟수(3, DynamoDB 계열 4)가 다르게 적혀 있지 않은지 2단계에서 함께 본다.
- **전수**: `legacy를 기본|기본 모드는 legacy` — DEA md **1자리**(`:145`) + 관련 메모 1자리(`:250`) · 문항 **0자리**.

---

## 2. 🟡

### Y1. Multi-AZ 「스탠바이는 읽기 트래픽을 받지 못한다」가 배포 유형 한정 없이 쓰였다 (지난 P2-DEA-2 · 미수정 · 범위 확대)

- **공개 여부**: verified true (`dea-t2-1-q6`)
- **현재 정답 인덱스**: 2 (불변)
- **결함**: `dea-t2-1-q6` 의 `W3`(「Amazon RDS의 Multi-AZ 대기 복제본은 읽기 트래픽을 처리하지 않습니다」)와 둘째 출처 제목(「… Multi-AZ standby는 읽기 트래픽을 처리하지 않음」)이 무수식이다. md 도 같다 — `dea-t2-1.md:169` · `:282` · **`dea-t2-3.md:189`(표 행 「RDS Multi-AZ | … 대기 복제본은 읽기 트래픽을 처리하지 않음」) · `:228`(함정 15)**. 뒤 두 자리는 지난 보고에 없던 것이다. Multi-AZ **DB 클러스터** 배포에서는 스탠바이가 읽기를 처리하므로 한정이 필요하다. 정답(보기[2])에는 영향이 없다.
- **공식 근거**: `https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.MultiAZ.html` — "A Multi-AZ DB instance deployment has one standby DB instance that provides failover support, but doesn't serve read traffic. … A Multi-AZ DB cluster deployment has standby DB instances that provide failover support and **can also serve read traffic**."
- **수정안**: 다섯 자리 모두 「Multi-AZ **DB 인스턴스 배포**(스탠바이 1개)의 스탠바이는 읽기 트래픽을 받지 못한다 — **DB 클러스터 배포**(스탠바이 2개)는 읽기를 처리한다」로 한정. 보기[3] 문구(「Multi-AZ 대기 복제본을 추가해 읽기 트래픽을 보낸다」)는 오답 보기이므로 유지하되 `W3` 에서 배포 유형을 가른다.
- **전수**: DEA md **4자리** · 문항 **1건 2필드**(`W3` · `src1.title`). `dea-t2-3.md:318` 출처는 이미 `Concepts.MultiAZSingleStandby.html`(인스턴스 배포 페이지)라 한정만 본문에 옮기면 된다.

### Y2. Bedrock Provisioned Throughput — 「커스텀 모델에 필수」·「1·6개월 약정이 필요」

- **공개 여부**: verified true (`dea-t1-2-q12`)
- **현재 정답 인덱스**: 0 (불변)
- **결함**: `dea-t1-2.md:167` 「Provisioned Throughput(시간당 과금·1·6개월 약정, **커스텀 모델에 필수**)」 · `dea-t1-2-q12` `W2` 「Provisioned Throughput은 시간당 과금에 **1·6개월 약정이 필요**하며 커스텀 모델 사용 시의 선택지입니다」. ① 사용자 지정 모델의 추론 경로는 **둘**이고 ② 약정 없는 PT 가 있다.
- **공식 근거**:
  - `https://docs.aws.amazon.com/bedrock/latest/userguide/model-customization-use.html` — "After you create a custom model, you can set up inference using one of the following options: **Purchase Provisioned Throughput** … **Deploy custom model for on-demand inference** … With on-demand inference, you only pay for what you use and you don't need to set up provisioned compute resources."
  - `https://docs.aws.amazon.com/bedrock/latest/APIReference/API_CreateProvisionedModelThroughput.html` — "To request a no-commit Provisioned Throughput, omit this field. Custom models support all levels of commitment."
- **확신이 🔴 가 아닌 이유**: 문항이 인용한 AWS 블로그는 지금도 "If you customized a model, you must purchase Provisioned Throughput to be able to use it" 와 "commitment options of 1-month or 6-month terms" 로 적는다 — **공식 내부 어긋남**이다(§6-1). 더 구체적인 사용자 안내서·API 참조를 정본으로 본다(AIF·AIP 가 같은 판정을 내렸다 — §5).
- **수정안**: md → 「Provisioned Throughput(시간당 과금 · 약정 없음/1개월/6개월 · 사용자 지정 모델은 PT 구매 **또는** 온디맨드 배포 중 하나로 추론)」. `W2` → 「Provisioned Throughput은 전용 용량을 시간 단위로 사는 방식이라 일회성 대량 배치에는 과도합니다.」(약정 필수·커스텀 전용 서술 삭제).
- **전수**: DEA md **1자리** · 문항 **1건 1필드**.

### Y3. KMS 온디맨드 회전 「키당 평생 10회」 — 개발자 안내서 쿼터는 25회

- **공개 여부**: verified true (`dea-t4-3-q6`)
- **현재 정답 인덱스**: 0 (불변 — 수치는 정답·보기·해설에 없고 **출처 제목**에만 있다)
- **결함**: `dea-t4-3.md:138` 「온디맨드 회전은 **키당 평생 10회**까지」 · `dea-t4-3-q6` 둘째 출처 제목 「… 온디맨드 회전 키당 10회」.
- **공식 근거**: `https://docs.aws.amazon.com/kms/latest/developerguide/resource-limits.html` — "On-demand rotation: 25 — You can perform on-demand key rotation a maximum of **25 times per KMS key**. … This quota is not adjustable." · `https://docs.aws.amazon.com/kms/latest/developerguide/rotating-keys-on-demand.html` 도 "a maximum of 25 times per KMS key".
- **확신이 🔴 가 아닌 이유**: 문항이 인용한 `aws.amazon.com/kms/faqs/` 는 지금도 "lifetime limit of **10** on-demand rotations per key" 로 적는다(curl 추출 실측). **공식 내부 어긋남**이고, 조정 불가 쿼터를 명시한 쿼터 페이지가 더 구체적이다.
- **수정안**: md 의 수치를 **25회**(개발자 안내서 쿼터 페이지 기준)로 고치고 FAQ 와 다르다는 것을 한 줄로 적거나, 레포의 D-16 계열 판정대로 **횟수를 걷는다**(「온디맨드 회전에는 키당 평생 한도가 있다」). 출처 제목의 「키당 10회」는 지운다. 같은 줄의 「가져온 키 자료 … 자동 회전 불가」는 참이므로 유지(가져온 키는 **온디맨드** 회전은 된다).
- **전수**: `평생 10회|키당 10회` — DEA md **1자리** · 문항 **1건 1필드**(출처 제목). 「온디맨드 회전」 문자열은 dva 1파일·scs 2파일에도 있다(§5 — 수치는 확인하지 않았다).

### Y4. `dea-t3-2-q1` — 「구체화된 뷰는 Amazon Redshift의 객체 … 성립하지 않습니다」가 낡았다

- **공개 여부**: verified true
- **현재 정답 인덱스**: 1 (SPICE — 불변, **정답 유일성 유지**)
- **결함**: `W3` 「구체화된 뷰는 Amazon Redshift의 객체입니다. Athena 테이블을 구체화된 뷰로 바꾸는 선택지는 **성립하지 않습니다**.」 AWS Glue Data Catalog 에 Iceberg 구체화된 뷰가 생겼고 Athena 로 읽는다. 「성립하지 않는다」는 근거가 무너진다. 다만 구체화된 뷰를 써도 대시보드를 열 때마다 Athena 쿼리가 실행되므로 「반복 열람의 쿼리 비용」을 없애는 정답은 여전히 SPICE 하나다. `dea-t3-2-q9`(c=1) `W2` 「구체화된 뷰는 결과를 저장하는 Redshift 객체이며」도 같은 전제를 쓴다(그 문항은 뒤 문장 「저장된 사본이 생기는 점도 요구와 다릅니다」로 독립적으로 성립한다).
- **공식 근거**: `https://docs.aws.amazon.com/glue/latest/dg/materialized-views.html` — "You can query materialized views from AWS Glue using the same Spark SQL interfaces … The precomputed data is also accessible from other services including **Amazon Athena** and Amazon Redshift." · `https://docs.aws.amazon.com/lake-formation/latest/dg/materialized-views.html` — "Because materialized views are stored as Iceberg tables, you can read them directly from any Iceberg-compatible engine, including Amazon Athena, Amazon Redshift, …".
- **수정안**: `W3` → 「구체화된 뷰(Redshift 또는 Glue Data Catalog)를 쓰면 쿼리 한 번의 스캔량은 줄지만, 대시보드를 열 때마다 원본 쿼리가 실행되는 구조는 그대로입니다. 반복 열람의 쿼리 비용을 없애는 수단은 SPICE입니다.」 `dea-t3-2-q9` `W2` 는 「Redshift 객체이며」를 「결과를 저장하는 객체이며」로만 바꾼다. md `dea-t3-2.md:55`·`:117` 의 「네 가지 객체」 서술은 거짓이 아니다 — Glue Data Catalog 구체화된 뷰를 한 줄 보강할지는 2단계 판단.
- **전수**: `구체화된 뷰는 Amazon Redshift의 객체|Redshift 객체` — 문항 **2건 2필드**(`dea-t3-2-q1` W3 · `dea-t3-2-q9` W2) · md 0자리(`dea-t4-5.md:210` 의 「Redshift 객체」는 datashare 문맥이라 무관).

### Y5. `dea-t3-3-q2` `W3` — 「IA와 S3 내보내기의 조합은 공식 자료 간 서술이 엇갈려」(회피형 + 낡음) · 로그 클래스 개명

- **공개 여부**: verified true
- **현재 정답 인덱스**: 2 (불변)
- **결함 ①**: `W3` 「Infrequent Access 클래스는 구독 필터를 지원하지 않으며, **IA와 S3 내보내기의 조합은 공식 자료 간 서술이 엇갈려 설계 근거로 삼기에 적절하지 않습니다**.」 — 작성자의 검증 상태를 적은 문장(M2)이고, 현행 공식 기능 표는 내보내기를 **지원**으로 적는다(조사 노트 `99-gaps.md` G-3.3-03 이 기록한 상충의 한쪽은 2023년 News Blog 였다). 보기[3]이 오답인 이유는 「지원 여부 불명」이 아니라 **내보내기가 배치성 작업이라 지속 아카이브의 권장 방식이 아니고, IA 는 구독 필터를 못 쓰기 때문**이다.
- **결함 ②(명칭)**: 공식이 로그 클래스 이름을 **Essentials(formerly Infrequent Access)** 로 바꿨다. DEA 는 로그 클래스를 전부 「Infrequent Access(IA)」로만 적는다. API 값 `INFREQUENT_ACCESS` 는 계속 받으므로 거짓은 아니고 **병기 누락**이다.
- **공식 근거**: `https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CloudWatch_Logs_Log_Classes.html` — 기능 표 행 「Export to Amazon S3 | Yes ✓ | Yes ✓」 · 「Subscription filters | Yes ✓ | No」(둘 다 **표의 행**) · "The *Infrequent Access* log class has been renamed to *Essentials*. You can now create log groups with either `INFREQUENT_ACCESS` or `ESSENTIALS` as the log class value. … Starting December 2026, API responses … will return `ESSENTIALS` instead of `INFREQUENT_ACCESS`".
- **수정안**: `W3` → 「Infrequent Access(현 Essentials) 클래스는 구독 필터를 지원하지 않습니다. S3 내보내기는 되지만 비동기 배치 작업이어서, 문서가 지속 아카이브에 권하는 방식이 아닙니다.」 명칭은 md 의 로그 클래스 정의 줄(`dea-t3-3.md:200` · `dea-t4-4.md:121`)에 「현 명칭 Essentials — 2026-12 부터 API 응답도 `ESSENTIALS`」를 병기.
- **전수**: 로그 클래스 문맥의 IA 언급 — DEA md **9자리**(`dea-t3-3.md:200`·`:243`·`:294`·`:298` · `dea-t4-4.md:52`·`:84`·`:121`·`:191`·`:215`) · 문항 **4건**(`dea-t3-3-q2` c=2 · `dea-t3-3-q14` c=2 · `dea-t4-4-q7` c=2 · `dea-t4-4-q15` c=2). ⚠️ `dea-t2-1.md:171` · `dea-t2-3.md:120`·`:192`·`:218` · `dea-t2-3-q4`·`q6` 의 「IA」는 **S3 스토리지 클래스**라 대상이 아니다. `Essentials` 문자열은 DEA 전체 0건.

### Y6. `dea-t1-4-q10` — 정답의 핵심 사실(`cdk bootstrap`·CDKToolkit)을 두 출처가 모두 담지 않는다

- **공개 여부**: verified true
- **현재 정답 인덱스**: 0 (불변 — 사실은 옳다)
- **결함**: 출처 둘이 `cdk/v2/guide/home.html`(「What is the AWS CDK?」)과 `cdk/v2/guide/constructs.html` 이다. curl 추출로 세면 `bootstrap` **0건** · `CDKToolkit` **0건**(대조군 `CloudFormation` 34건 / 18건). md `dea-t1-4.md:137`·`:191` 이 같은 사실을 가르치는데 참고자료(#21·#22)도 그 두 페이지뿐이다.
- **공식 근거(새 출처)**: `https://docs.aws.amazon.com/cdk/v2/guide/bootstrapping.html` — `200 r=0`, `bootstrap` 77건 · `CDKToolkit` 1건.
- **수정안**: 문항 출처와 md 참고자료에 `bootstrapping.html` 을 **추가**한다(`home.html` 은 「CloudFormation 으로 프로비저닝」을 담으므로 유지, `constructs.html` 은 W3 의 L1/L2/L3 근거라 유지).
- **전수**: `cdk/v2/guide/bootstrapping` — DEA md **0자리** · 문항 **0자리**.

### Y7. 「Redshift Serverless 는 128의 배수」 — 근거가 `repost.aws` 하나뿐이고 공식 문서 두 페이지에 없다

- **공개 여부**: verified true (`dea-t2-3-q1`)
- **현재 정답 인덱스**: 0 (불변 — 정답 보기에는 이 구절이 없다)
- **결함**: `dea-t2-3-q1` 해설 「…(Redshift Serverless는 128의 배수 권장)」과 둘째 출처 제목, md `dea-t1-4.md:82` · `dea-t2-3.md:83`·`:203`·`:254` 가 이 권고를 적는다. 문구는 `repost.aws/knowledge-center/redshift-load-s3-data` 에 있다("For Amazon Redshift Serverless, it's a best practice to use a number files that's a multiple of 128"). 그런데 그 글이 근거로 링크하는 공식 `c_best-practices-use-multiple-files.html` 과 `t_splitting-data-files.html` 에는 **Serverless·128의 배수 서술이 없다**(두 페이지 전문을 문서 리더로 읽음 · 대조군: 같은 페이지에서 「multiple of the number of slices」「128MB」는 읽힌다).
- **공식 근거**: 위 두 페이지 — "make the number of files a multiple of the number of slices in your cluster" 까지만 적는다.
- **수정안(공식에서 확인되지 않음 — 사실 수정안은 내지 않는다)**: 2단계가 고를 선택지는 둘이다. ① 그 구절을 「AWS re:Post 지식 센터의 권고」로 **귀속**해 남긴다 ② 걷는다. 어느 쪽이든 문항 해설의 「권고합니다」 주어(공식 문서)와 섞이지 않게 한다.
- **전수**: `128의 배수` — DEA md **4자리** · 문항 **1건 2필드**(해설 · `src1.title`).

### Y8. `dea-t2-1.md:234` · `:263` — RDS Performance Insights 「2026-06-30 수명 종료」의 근거가 `repost.aws` 뿐이고 공식 요금 페이지는 다른 날짜를 적는다

- **공개 여부**: 라이브 학습문서(문항 0)
- **결함**: 날짜의 근거가 참고자료 #52(`repost.aws/knowledge-center/rds-mysql-slow-query`)다. 공식 사용자 안내서 `AmazonRDS/latest/UserGuide/USER_PerfInsights.html` 은 이제 제목이 「Monitoring DB load with Amazon CloudWatch Database Insights on Amazon RDS」이고 종료 날짜를 적지 않는다(curl 추출: `2026`·`end of life` 0건, 대조군 `Database Insights` 13건).
- **공식 근거**: `https://aws.amazon.com/rds/performance-insights/pricing/` — "The performance insights dashboard in the RDS Console will no longer be supported starting **July 31, 2026**. … If no action is taken, your database instances will default to the standard mode of Database Insights after that date."
- **확신이 🔴 가 아닌 이유**: re:Post 여러 글은 "end of life on June 30, 2026" 으로 적는다 — 날짜가 **두 가지**다(§6-1). 「Standard mode 가 기본이 되고 실행 계획·온디맨드 분석은 Advanced 전용」은 두 쪽이 일치한다.
- **수정안**: 날짜를 단정하지 않는다 — 「Performance Insights 는 CloudWatch Database Insights 로 이전됐다(공식 요금 페이지는 콘솔 대시보드 지원 종료를 2026-07-31 로 적는다)」. 참고자료에 요금 페이지를 추가.
- **전수**: `Performance Insights` — DEA md **3자리**(`:234`·`:263`·`:391`) · 문항 0. saa 1파일·soa 2파일에도 문자열이 있다(§5 — 확인하지 않았다).

### Y9. `dea-t2-1.md:242` — Glue Data Catalog Iceberg compaction 시작 조건 「기본 5개」

- **공개 여부**: 라이브 학습문서(문항 0)
- **결함**: 「compaction은 파일 수가 설정값(**기본 5개**)을 넘고 각 파일이 목표 크기의 75% 미만일 때 시작」. 75% 는 공식과 일치하지만 파일 수는 다르다.
- **공식 근거**: `https://docs.aws.amazon.com/glue/latest/dg/compaction-management.html` — "In the Data Catalog, the compaction process starts when a table or any of its partitions have **more than 100 files**. Each file must be smaller than 75% of the target file size. The target file size is defined by the `write.target-file-size-bytes` table property, which defaults to 512 MB if not explicitly set."
- **확신이 🔴 가 아닌 이유**: md 의 근거는 AWS Big Data Blog(#62)인데 그 글 본문을 추출하지 못해 「5」가 블로그의 서술인지 확인하지 못했다. `enable-compaction.html` 은 「Minimum input files」를 **설정 가능한 값**으로 적고 기본값을 적지 않는다.
- **수정안**: 「기본 5개」를 걷고 공식 문장(100개 초과 · 75% 미만 · 목표 512 MB 기본)으로 바꾼다. 참고자료에 `compaction-management.html`(`200 r=0`) 추가.
- **전수**: DEA md **1자리** · 문항 0.

### Y10. 「퍼블릭 서브넷의 NAT 게이트웨이를 경유해야」 — 영역형 NAT 에만 맞는 배타 서술 (교차 자격증 계열)

- **공개 여부**: verified true (`dea-t1-1-q16` · `dea-t4-1-q4`)
- **현재 정답 인덱스**: `dea-t1-1-q16` = 0 · `dea-t4-1-q4` = 3 (둘 다 불변 — 영역형 NAT 구성으로서 **지금도 정답**이다)
- **결함**: `dea-t1-1-q16` 해설 「…퍼블릭 서브넷의 NAT 게이트웨이를 **경유해야 하며**」 · `dea-t4-1-q4` 정답·해설 · md `dea-t1-1.md:183` · `dea-t2-2.md:169`(「퍼블릭 서브넷의 NAT 게이트웨이가 **있어야 하며**」) · `dea-t4-1.md:101` · `:102`. 2025-11 리전 NAT 게이트웨이는 퍼블릭 서브넷이 필요 없다.
- **공식 근거**: `https://docs.aws.amazon.com/vpc/latest/userguide/nat-gateways-regional.html` — "Unlike standard NAT gateways (referred to as zonal NAT gateways), which operate in a single Availability Zone, regional NAT gateways follow your workloads …" · "with a regional NAT Gateway, **you don't need to create a public subnet to host it**."
- **확신이 낮은 이유**: Lambda 공식 페이지 `lambda/latest/dg/configuration-vpc-internet.html`(`dea-t1-1-q16` 의 출처)은 지금도 프라이빗 서브넷 + 퍼블릭 서브넷 NAT 게이트웨이 절차만 적는다(`regional` 0건, 대조군 `NAT gateway` 20건). DEA 서술은 **인용 페이지와 일치**한다. 결함은 「해야」의 배타성뿐이다.
- **수정안**: 문항은 보기를 바꾸지 않고 해설에 「(영역형 NAT 게이트웨이 기준 — 리전 NAT 게이트웨이는 퍼블릭 서브넷이 필요 없다)」 한 줄. md 네 자리도 같은 한정.
- **전수**: 「퍼블릭/공용 서브넷의 NAT 게이트웨이」 필요 서술 — DEA md **4자리** · 문항 **2건**. NAT 를 언급하는 나머지 md 9줄·문항 5건은 경로 유무만 말하므로 대상이 아니다.

### Y11. MWAA 「스케줄러는 최소 2에서 최대 5」 — `mw1.micro` 예외가 빠졌다

- **공개 여부**: verified true (`dea-t1-3-q9`)
- **현재 정답 인덱스**: 0 (불변)
- **결함**: `dea-t1-3-q9` `W2` 「스케줄러는 최소 2에서 최대 5까지 구성되며」 · md `dea-t1-3.md:139`(「스케줄러(최소 2·최대 5)」) · `:169`(「스케줄러 최소 2」).
- **공식 근거**: `https://docs.aws.amazon.com/mwaa/latest/userguide/environment-class.html` — "For environments larger than mw1.micro, accepts values from `2` to `5`. Defaults to `2` for all environment sizes **except mw1.micro, which defaults to `1`**." (같은 페이지: "mw1.micro does not support auto-scaling.")
- **수정안**: 세 자리에 「(`mw1.micro` 는 1개)」 한정.
- **전수**: DEA md **2자리** · 문항 **1건 1필드**.

### Y12. Kinesis 이벤트 소스 매핑의 실패 대상을 「(SQS/SNS)」로만 적는다

- **공개 여부**: verified true (`dea-t1-1-q15`)
- **현재 정답 인덱스**: 0 (불변 — SQS·SNS 는 유효한 대상이다)
- **결함**: 정답 보기 「…실패 대상(SQS/SNS)을 지정한다」 · 해설 · md `dea-t1-1.md:180`. 공식은 대상을 넷으로 적는다. 「데이터를 잃지 않는다」는 지문 요구에는 **S3 대상**이 더 직접적이다(S3 는 호출 레코드 전체를 담는다).
- **공식 근거**: `https://docs.aws.amazon.com/lambda/latest/dg/kinesis-on-failure-destination.html` — "You can configure any Amazon SNS topic, Amazon SQS queue, **Amazon S3 bucket**, or Kafka as a destination." · "For Amazon S3 destinations, Lambda also sends the entire invocation record along with the metadata."
- **수정안**: 「실패 대상(SQS·SNS·S3 등)」으로 넓히고, 해설에 「SQS·SNS 대상에는 메타데이터만, S3 대상에는 호출 레코드 전체가 간다」를 덧붙인다.
- **전수**: `실패 대상(SQS/SNS)` — DEA md **1자리** · 문항 **1건 2필드**.

### Y13. 낡은 저작 상태 문구 — 「사람 검수 전이라 사이트에는 노출되지 않습니다」(전부 거짓이 됐다)

- **공개 여부**: 라이브 학습문서 17편 전부
- **결함**: DEA 는 256/256 이 공개인데 학습자가 읽는 md 에 저작 시점의 상태 문구가 남아 있다. ① 자가 점검 머리말 「(문항 뱅크는 `dea-tX-Y.questions.json` — **사람 검수 전이라 사이트에는 노출되지 않습니다**)」 — **8줄**(`dea-t1-1:218` · `t1-2:211` · `t1-3:221` · `t1-4:217` · `t2-1:288` · `t2-2:231` · `t2-3:234` · `t2-4:267`) ② 출처 절 머리말 「(수집·대조: … · 저작: … · **사람 검수 전**)」 — **17줄**(17편 전부).
- **공식 근거**: 해당 없음(사이트 자신의 상태). 레포 실측: 17개 문항 파일 전 문항 `verified: true`.
- **수정안**: ①은 괄호 구절 전체를 걷는다. ②는 「사람 검수 전」만 걷는다(수집·저작 날짜는 사실이므로 유지).
- **전수**: `사람 검수 전` — DEA md **25자리** · 문항 0. ⚠️ 가드로 굳힐 때는 **`verified` 상태를 단정하지 않는 형태**로 쓴다(낡은 문구 금지이지 공개 상태 단정이 아니다 — 2026-11-13 flip 교훈).

### Y14. 비공식 출처가 1차 근거인 문항 — 특히 `dea-t4-1-q4` 는 **유일한 출처가 `repost.aws`**

- **공개 여부**: verified true (전부)
- **현재 정답 인덱스**: `dea-t4-1-q4` = 3
- **결함**: 루브릭 C4. `repost.aws` 가 **첫 출처**인 문항 5건 — `dea-t2-2-q9`(c=1) · `dea-t2-2-q10`(c=0) · `dea-t4-1-q3`(c=2) · **`dea-t4-1-q4`(c=3, 단일 출처)** · `dea-t4-3-q10`(c=1). AWS 블로그가 첫 출처인 문항 6건 — `dea-t1-1-q7`(c=1) · `dea-t1-2-q3`(c=0) · `dea-t1-3-q10`(c=0) · `dea-t2-1-q10`(c=2) · `dea-t2-1-q14`(c=3) · `dea-t4-5-q7`(c=1). (둘째 이후 출처로 쓰는 문항까지 합치면 repost 6건 · 블로그 15건 · 백서 2건 = 23문항.)
- **공식 근거(새 출처 — `dea-t4-1-q4`)**: `https://docs.aws.amazon.com/lambda/latest/dg/configuration-vpc-internet.html` — `200 r=0`, 같은 자격증의 `dea-t1-1-q16` 이 이미 쓰는 페이지이고 `private subnet` 20건 · `NAT gateway` 20건.
- **수정안**: `dea-t4-1-q4` 에 위 공식 페이지를 **첫 출처로 추가**한다(repost 는 둘째로 내린다). 나머지 10건은 공식 문서 출처가 이미 둘째에 있으므로 **순서만** 바꾸는 것을 권한다(블로그·repost 만이 그 사실을 담는 자리가 있는지는 2단계에서 한 건씩 — Y7 이 그 예다).
- **전수**: 문항 출처 485자리 중 repost **6** · 블로그 **15** · 백서 **2**. md 참고자료의 repost **15줄** · 블로그 **21줄**.

### Y15. md ↔ md — 「작은 차원 테이블은 ALL 분산」 무수식(`dea-t3-4`) ↔ 「작은 디멘션 = 무조건 ALL 은 함정」(`dea-t2-4`)

- **공개 여부**: 라이브 학습문서(문항은 이 축을 정답으로 단정하지 않는다)
- **결함**: `dea-t3-4.md:153`(표 「분산 키 재선택, **작은 차원 테이블은 ALL 분산**」) · `:158` 이 처방으로 단정하는데, `dea-t2-4.md:93` · `:248` 은 같은 주장을 **❌ 함정**으로 가르친다(「재분산 비용이 낮은 작은 디멘션 테이블은 ALL 로 얻는 이점이 크지 않다」).
- **공식 근거**: 이번 패스에서 원문을 다시 읽지 않았다 — `dea-t2-4.md` 가 「같은 문서가 말한다」고 귀속한 공식 서술을 2단계가 확인한 뒤 `dea-t3-4` 쪽을 그 수준으로 맞춘다.
- **수정안**: `dea-t3-4.md:153`·`:158` 에 「colocate 할 수 없는 디멘션이면」 조건을 붙인다.
- **전수**: `dea-t3-4.md` 2자리 ↔ `dea-t2-4.md` 2자리(+ `dea-t2-1.md:125` 가 같은 주제).

### Y16. 백서 출처의 상태 메모 누락 (지난 P2-DEA-3 잔여)

- **공개 여부**: verified true (`dea-t1-2-q7`)
- **현재 정답 인덱스**: 0
- **결함**: `whitepapers/latest/big-data-analytics-options/amazon-athena.html` 은 curl 로 `200 r=1` → `athena/latest/ug/what-is.html` 이다(오늘 감사의 「사람 대상 서빙만 꺼진 백서」 계열 — 레포 정책은 **인용 유지 + 상태 명시**). `dea-t1-2.md:277`(#15)에는 그 메모가 있는데 **`:278`(#16)에는 없다**. `dea-t1-2-q7` 의 둘째 출처도 같은 URL 이다.
- **공식 근거**: 오늘 `docs/saa-review/2026-11-17-wa-restructure-source-audit.md` §3·§5 의 판정. (`tagging-best-practices/abac-for-individual-resources.html` 은 `200 r=0` 로 살아 있어 `dea-t4-2-q13`·`dea-t4-2.md:336` 은 대상이 아니다.)
- **수정안**: md `:278` 에 #15 와 같은 상태 메모. `dea-t1-2-q7` 은 첫 출처(`athena/latest/ug/federated-queries.html`)가 정답 사실을 이미 담으면 백서 줄을 **중복 삭제**(오늘 §5-3 선례), 아니면 유지.
- **전수**: DEA 의 `whitepapers/` — md **3자리** · 문항 **2건**. 그중 `r=1` 인 것은 `amazon-athena.html`(md 1 · 문항 1)과 이미 메모가 달린 `cost-modeling-data-lakes/…`(md 1).

---

## 3. 🟢 (품질 — 사실은 옳다)

### G1. 길이 단서 — 111문항(43%)

- prescreen `length-cue`(정답 > 최장 오답 × 1.3) **111건**. Task 별: t1-1 4 · t1-2 5 · t1-3 4 · t1-4 7 · t2-1 2 · t2-2 4 · t2-3 2 · t2-4 5 · t3-1 3 · t3-2 6 · t3-3 8 · t3-4 8 · t4-1 6 · t4-2 9 · t4-3 11 · **t4-4 13 · t4-5 14**. 도메인 4 가 53건으로 절반이다.
- 그중 **정답이 최장 오답의 2배 이상** **34건**: `dea-t1-2-q10` · `dea-t1-3-q2` · `dea-t1-4-q3` · `dea-t1-4-q7` · `dea-t2-1-q13` · `dea-t2-2-q14` · `dea-t3-3-q12` · `dea-t3-4-q14` · `dea-t4-1-q4` · `dea-t4-1-q7` · `dea-t4-2-q11` · `dea-t4-2-q15` · `dea-t4-3-q3`·`q4`·`q7`·`q15` · `dea-t4-4-q4`·`q5`·`q6`·`q8`·`q10`·`q11`·`q12`·`q15` · `dea-t4-5-q1`·`q4`·`q5`·`q6`·`q7`·`q9`·`q10`·`q12`·`q13`·`q14`. 가장 큰 것은 `dea-t4-4-q11`(정답 166자 · 오답 42~72자).
- **반대 방향**(정답이 최단 오답보다 짧다) **14건**: `dea-t1-1-q1`·`q6`·`q8` · `dea-t1-2-q1`·`q6`·`q13` · `dea-t2-3-q6` · `dea-t2-4-q8` · `dea-t3-1-q7` · `dea-t3-2-q7`·`q9` · `dea-t4-1-q5` · `dea-t4-3-q10`·`q11`.
- 수정안: SCS 선례(「정답 ÷ 1.3」을 계산해 오답을 같은 정밀도로 올린다 · 둘째 사실은 해설로 내린다). 보기 문구만 바꾸고 정답 인덱스는 건드리지 않는다. 우선순위는 2배 이상 34건.

### G2. 자기 프레임(「공식 문서가 …」) — prescreen 13건 (「공식」이 문항 어디든 나오는 것은 30건)

- prescreen `meta-phrasing`(지문·정답) **13건**: `dea-t1-1-q3`(c=1) · `q8`(c=0) · `q9`(c=0) · `q11`(c=0) · `dea-t1-2-q3`(c=0) · `q10`(c=0) · `dea-t1-3-q14`(c=0) · `dea-t1-4-q5`(c=0) · `dea-t3-3-q2`(c=2) · `dea-t4-4-q8`(c=1) · `q11`(c=2) · `q15`(c=2) · `dea-t4-5-q7`(c=1).
- 「공식」이 **문항 JSON 어디든**(지문·보기·해설·오답 근거·출처 제목) 나오는 문항은 30건이다(해설·출처 제목의 귀속은 정당한 층이라 결함이 아니다 — prescreen 이 지문·정답에서 잡은 13건이 손댈 대상).
- 수정안: 지문의 「공식 문서 기준으로 / 공식 권장에 맞는」을 걷는다(실질 질문은 이미 들어 있다).

### G3. 저작 메모(M2) — 문항 3건 · md 16줄

- 문항: `dea-t3-3-q2`(c=2) `W3`(→ Y5 에서 함께 닫는다) · `dea-t4-4-q7`(c=2) `W1` 「…Delivery 클래스에 대한 서술이며, **문서 간 일수 표현에 차이가 있습니다**」 · `dea-t2-1-q15`(c=0) `W3` 「제시된 공식 문서에서 … 서술은 **확인되지 않습니다**」(보기의 주장을 부정하는 형태라 루브릭상 정당 — 지난 보고도 같은 판정. 「FLAT은 양자화 방식이 아니라 전수 선형 비교입니다」로 단정해도 된다).
- `dea-t4-4-q7` `W1` 수정안: 「보존이 짧게 고정된 쪽은 Lambda 로그를 S3·Firehose 로 보내는 Delivery 클래스입니다.」(일수 상충은 §6-1 — 공식 내부 어긋남이라 수치를 적지 않는 판정은 옳다. 메모 문장만 걷는다.)
- md 16줄: `dea-t2-4:197`·`:257` · `dea-t3-1:250` · `dea-t3-2:96`(「요금 단가를 묻는 문항은 피하세요」) · `dea-t3-3:202`(「개수를 묻는 문항은 피하세요」) · `dea-t3-4:101`·`:144` · `dea-t4-1:235` · `dea-t4-3:122`·`:202` · `dea-t4-4:139` · `dea-t4-5:107`·`:135`·`:145`·`:151`·`:250`. 학습자에게 「문항은 피하세요」는 **저작자에게 하는 말**이다. 「공식 문서에서 확인되지 않았으므로 정답으로 고르지 않습니다」류의 시험 전략 서술은 의도된 것이므로 한 줄씩 판정해서 걷는다(일괄 금지 금지).

### G4. 날짜 고정 지문 — `dea-t4-4-q11` · `dea-t4-4.md:264`

- `dea-t4-4-q11`(c=2) 지문 「**2026-10 현재** 공식 문서를 근거로 고려해야 할 점은?」 · md 자가 점검 Q5 가 같은 문구. 지문이 날짜에 묶여 있어 시간이 지나면 어색해진다. 수정안: 「현행 공식 문서를 근거로」도 메타이므로 「신규 구축에서 고려해야 할 점은?」.

### G5. 오타 — `dea-t3-1.md:250` 「Glue **북반** Disable」 → 「북마크」 (1자리)

### G6. 중복 — 같은 주장을 정답으로 묻는 5묶음(11문항) · 부분 겹침 8쌍

32,640쌍을 원형·조사벗김 자카드로 재고 상위 쌍의 본문을 읽었다(정답 조사벗김 ≥ 0.33 **15쌍** · 원형 ≥ 0.33 **7쌍** · 지문+정답+해설 ≥ 0.33 **1쌍**). **수치가 아니라 본문으로 판정했다.**

| 묶음 | 문항(정답 인덱스) | 같은 주장 | 수치(정답 조사벗김 / 전체) |
|---|---|---|---|
| D1 | `dea-t3-3-q2`(2) ↔ `dea-t4-4-q8`(1) | 지속 아카이브에는 정기 내보내기가 아니라 **구독** | 0.333 / **0.444** (지문 0.529) |
| D2 | `dea-t3-3-q1`(1) ↔ `dea-t4-4-q1`(0) | 이벤트 기록은 현재 리전 **90일** 관리 이벤트 → trail 로 S3 전달 | 0.542 / 0.306 |
| D3 | `dea-t1-1-q11`(0) ↔ `dea-t2-3-q1`(0) | COPY 는 비슷한 크기로 나누고 **슬라이스 수의 배수** | 0.533 / 0.290 |
| D4 | `dea-t1-2-q10`(0) ↔ `dea-t2-2-q10`(0) ↔ `dea-t4-1-q1`(1) | Glue 연결 보안 그룹의 **자기참조 인바운드 규칙** (3문항) | 0.421·0.444·0.318 |
| D5 | `dea-t2-1-q3`(2) ↔ `dea-t4-2-q12`(0) | 다수 객체의 권한은 **LF-TBAC** | 0.400 / 0.191 |

- D1·D2 가 가장 강하다 — 지문 상황(8개월 전 기록 · 지속 아카이브)까지 같다. 원인은 공식 가이드가 **Task 3.3 과 4.4 에 같은 스킬을 두 번** 싣기 때문이다(「AWS CloudTrail을 사용하여 API 호출 추적」이 3.3.5 와 4.4.1). 통합 모의고사 한 회에 두 문항이 함께 나올 수 있다.
- 수정안: 「어느 Task 가 그 사실을 소유하나」로 가른다 — D1 은 3.3.1(감사를 위해 로그 추출)이 소유하고 `dea-t4-4-q8` 을 4.4.2 의 다른 축(보존 기간·암호화·교차 계정 구독 등)으로 돌린다. D2 는 4.4.1 소유 · `dea-t3-3-q1` 을 3.3.5 의 다른 축으로. D3 은 2.3.1 소유. D4 는 4.1.1(VPC 보안 그룹 업데이트) 소유 · 나머지 둘은 서브넷 여유 IP·NAT 경로 등으로. D5 는 4.2.4 소유. **문항 교체는 사람 승인 영역**이다(전부 `verified: true`).
- **부분 겹침 8쌍(각도가 달라 유지 가능)**: `dea-t3-3-q14`(2) ↔ `dea-t4-4-q7`(2)(IA 제약 — 메트릭 필터 대 구독 필터 · 정답 조사벗김 **0.579** 로 수치는 최고지만 묻는 기능이 다르다) · `dea-t2-1-q14`(3) ↔ `dea-t2-3-q13`(1)(Iceberg VACUUM) · `dea-t1-1-q14`(0) ↔ `dea-t3-1-q15`(3)(EventBridge Scheduler 시간대) · `dea-t3-3-q15`(0) ↔ `dea-t4-4-q13`(3)(Athena 로 CloudTrail 로그) · `dea-t1-1-q16`(0) ↔ `dea-t4-1-q4`(3)(VPC Lambda 와 NAT) · `dea-t3-3-q4`(3) ↔ `dea-t4-4-q2`(1)(조직 trail) · `dea-t1-2-q3`(0) ↔ `dea-t2-1-q8`(1)(EMR task 노드 Spot) · `dea-t4-2-q5`(2) ↔ `dea-t4-3-q1`(0)(Redshift 동적 데이터 마스킹).
- 수치만 높고 중복이 아닌 것: `dea-t2-3-q7` ↔ `q8`(0.500 — 수명 주기 액션 이름이 다르다) · `dea-t2-2-q8` ↔ `dea-t3-2-q9`(0.444 — 「Glue Data Catalog」 낱말만 겹친다).

### G7. 「Amazon Quick」 ↔ 제품 문서 「AWS Quick」 — 출처 제목이 실제 페이지 제목과 다르다

- `dea-t3-2-q3`(c=0) 출처 제목 「What is **Amazon** Quick? — …」. 실제 `quick/latest/userguide/what-is.html` 의 `<title>` 은 「What is **AWS** Quick?」이고 본문 `AWS Quick` 27건 · `Amazon Quick` 1건. 반면 DEA 공식 범위 내 목록은 「Amazon Quick」으로 적는다(§6-1). md 「Amazon Quick」 9줄 · 문항 6건(`dea-t3-2-q1`~`q6`).
- 수정안: 출처 제목은 페이지 제목 그대로(「What is AWS Quick?」). 본문 표기는 **시험 가이드 표기(Amazon Quick)를 유지**하고 md 용어 표에 「제품 문서 표기는 AWS Quick」 한 줄.

### G8. 문항 출처가 같은 Task 학습문서 참고자료에 없는 자리 — 20건 (참고)

DEA 에는 「문항 출처 ⊆ md 출처」 가드가 없다. 실측 20자리: `dea-t1-1-q4`·`q6`(`firehose/…/create-configure-backup.html`) · `q9` · `q10` · `q11` · `q12` · `q13` · `q14` · `q15` · `q16` · `dea-t1-2-q1` · `q6` · `q9`(2) · `q11` · `q12` · `dea-t1-3-q13` · `dea-t2-1-q9` · `dea-t4-1-q13` · `dea-t4-2-q11`. 결함이라기보다 「학습문서 저작 때 실측된 페이지가 아니었다」는 표식이다 — 이번에 그중 `dea-t1-1-q15`(통과) · `dea-t1-2-q1`(통과) · `dea-t1-2-q9`(통과)를 본문 대조했다.

### G9. 난이도 — `foundational` 이 1개뿐인 Task 3개

- 전체 applied 216 · foundational 40(15.6%). Task 별 foundational: **`dea-t2-1` 1 · `dea-t3-1` 1 · `dea-t3-3` 1**, 나머지는 2~5. 난이도는 내용 판단이라 라벨을 바꾸라고 권하지 않는다 — 검수자 판단 사항으로 적는다.

---

## 4. 커버리지·범위

### 4-1. 공식 스킬 커버리지 — 120개 중 114개(문항 0건 6개)

가이드 JSON 의 스킬 120개(Task 내 위치 번호)와 문항 `skill` 끝의 번호를 대조했다(파싱 실패 0 · 가이드에 없는 번호 0).

| 문항 0건 스킬 | 내용 |
|---|---|
| 1.1.12 | 스테이트풀 및 스테이트리스 데이터 트랜잭션 정의 |
| 1.2.1 | 성능 요구 사항에 맞게 컨테이너 사용 최적화(EKS·ECS) |
| 1.2.9 | 데이터의 볼륨·속도·다양성 정의 |
| 1.4.3 | 데이터 엔지니어링을 위한 프로그래밍 언어 및 프레임워크 사용 |
| 1.4.4 | 소프트웨어 엔지니어링 모범 사례 사용(버전 제어·테스트 등) |
| 1.4.5 | IaC 를 사용하여 데이터 엔지니어링 솔루션 배포 |

- 여섯 개가 전부 **도메인 1**(비중 34%로 최대)이다. `dea-t1-4` 는 스킬 11개에 15문항이라 구조적으로 빈다(1.4.5 는 1.4.8 과 주제가 겹친다).
- 문항 1건뿐인 스킬은 **38개**, 2건 이상은 76개다(1건뿐인 예: 1.1.2 · 1.1.4~1.1.11 · 2.1.4~2.1.8 · 3.1.5~3.1.9).
- `dea_questions_test` 는 스킬 전수 커버리지를 단정하지 않는다(구조·밀도 가드) — 그래서 지금 초록이다.

### 4-2. Task 별 문항 수·정답 인덱스

- 17 Task · 256문항(`dea-t1-1` 만 16). 정답 인덱스 0/1/2/3 = **109 / 67 / 52 / 28** — `dea-t1-2`·`t1-3`·`t1-4` 는 15/15 가 0 이고 `dea-t1-1` 은 13/16 이다. 루브릭대로 **결함이 아니다**(앱이 전 경로에서 보기를 섞는다). 기록만 남긴다.

### 4-3. 범위

- 공식 페이지(`aws-certification/latest/data-engineer-associate-01/dea-01-in-scope-services.html` · `…-out-of-scope-services.html`)를 읽어 대조했다. 레포 가이드 JSON 에는 서비스 목록이 없다.
- **범위 외 서비스가 정답인 문항: 0건.** 범위 외 목록 45종 가운데 DEA 에 이름이 나오는 것은 **AWS X-Ray** 하나다 — `dea-t1-4.md:130`(「관측은 CloudWatch + X-Ray」, md 1줄 · 문항 0). `IoT` 는 일반 명사로 3자리(범위 외 목록의 IoT 서비스가 아니다). `dea-t1-4-q13` 의 오답 보기 `rolling with additional batch` 는 범위 외인 Elastic Beanstalk 의 정책이다(오답으로 쓰는 것은 무방 — R2).
- **범위 내 목록에 있는데 md·문항 모두 0건**: Amazon Kendra · Amazon Managed Grafana · AWS Application Discovery Service · AWS Application Migration Service · Amazon CloudFront · AWS Shield · AWS Budgets · AWS Cost Explorer. **md 에만 있고 문항 0건**: Amazon S3 Tables(md 14줄) · AWS Batch · Amazon Keyspaces · Amazon Route 53 · Amazon EBS. 공식 목록이 스스로 non-exhaustive 라고 밝히므로 **결함으로 세지 않는다** — S3 Tables 는 범위 내 목록에 **두 번** 실려 있어 문항 후보로 적어 둔다.
- 공식 범위 내 목록은 「Amazon Kinesis Data Firehose」라는 옛 이름을 그대로 쓴다. DEA md 의 개명 안내(`dea-t1-1.md:197`)는 옳고, 문항은 전부 「Amazon Data Firehose」다.

---

## 5. 교차 자격증 — 다른 자격증과 어긋나는 자리 (고치지 않고 적기만)

| 주제 | DEA | 다른 자격증(레포 기록 기준) |
|---|---|---|
| RDS Multi-AZ 스탠바이의 읽기 | 무수식 5자리(Y1) | SAA·SOA 는 「Multi-AZ **DB 인스턴스** 배포(스탠바이 1개)」로 한정해 정정됨(2026-10-28 · 2026-11-06) |
| NAT 게이트웨이와 퍼블릭 서브넷 | 영역형 전제의 배타 서술 6자리(Y10) | SAA·SOA 는 영역형/리전형을 병기 |
| Bedrock 사용자 지정 모델과 PT | 「커스텀 모델에 필수」(Y2) | AIF·AIP 는 「경로가 둘」로 가르치고 전수 가드가 있다. 같은 패턴 문자열이 aif 1파일·aip 3파일에서도 걸리는데, 그쪽은 정정문·인용 줄일 가능성이 높다(확인하지 않았다) |
| Quick 명칭 | 「Amazon Quick」(시험 가이드 표기) | AIP 트랙은 「AWS Quick / AWS Quick Sight」(제품 문서 표기)로 기록 — 둘 다 공식에 근거가 있다(§6-1) |
| CloudWatch Logs 로그 클래스 이름 | 「Infrequent Access(IA)」만(Y5) | 같은 문자열이 saa 3파일·soa 1파일에 있다(S3 스토리지 클래스의 IA 가 섞여 있어 건수는 세지 않았다) — Essentials 개명은 **전 자격증 공통 사안** |
| KMS 온디맨드 회전 횟수 | 10회(Y3) | 「온디맨드 회전」이 dva 1파일·scs 2파일에 있다. 수치를 적는지는 확인하지 않았다 — 25/10 어긋남은 전역으로 볼 사안 |
| RDS Performance Insights 종료 | 2026-06-30(Y8) | saa 1파일·soa 2파일이 언급 — 날짜 표기는 확인하지 않았다 |
| boto3 재시도 기본 모드 | 「현행 문서는 legacy」(R5) | AIP 는 `AWS_NEW_RETRIES_2026` 옵트인 서술을 갖고 있다(레포 기록). 오늘 boto3 가이드는 standard 를 기본으로 적으므로 **AIP 쪽도 같은 날짜 기준으로 다시 볼 사안** |

---

## 6. 공식 내부 어긋남 / 「확인되지 않음」

### 6-1. 공식 내부 어긋남 (어느 쪽도 단정하지 않거나, 더 구체적인 쪽을 정본으로)

| 주제 | 한쪽 | 다른 쪽 | 이 보고의 처리 |
|---|---|---|---|
| KMS 온디맨드 회전 한도 | KMS FAQ "lifetime limit of 10 on-demand rotations per key" | 개발자 안내서 쿼터 "maximum of 25 times per KMS key … not adjustable" | Y3 — 쿼터 페이지가 정본 |
| Bedrock 사용자 지정 모델 | ML 블로그 "you must purchase Provisioned Throughput" | 사용자 안내서 `model-customization-use.html` 두 경로 | Y2 — 사용자 안내서가 정본 |
| RDS Performance Insights 종료일 | re:Post "end of life on June 30, 2026" | 요금 페이지 "no longer be supported starting July 31, 2026" | Y8 — 날짜를 단정하지 않는다 |
| Glue Flex 절감률 | Glue FAQ "by up to 35%" | Big Data Blog "by up to 34%" | DEA 는 FAQ 를 인용해 35% — **유지**(✅ 6) |
| API Gateway 교차 계정 호출 | `api-gateway-method-settings-method-request.html` "Users from a different AWS account can call the API methods **only if** allowed to assume a role within the API owner's AWS account" | `apigateway-resource-policies-examples.html` 「Allow roles in another AWS account to use an API」(리소스 정책 경로) | `dea-t4-1.md:179` 의 「…assume할 수 있을 때**만**」은 **인용 페이지(#21)에 글자 그대로 있다** — 결함으로 세지 않는다. 리소스 정책 경로를 한 줄 덧붙일지는 2단계 판단 |
| CloudWatch Logs Delivery 클래스 보존 | 로그 클래스 페이지 "kept in CloudWatch Logs for two days" | `CreateLogGroup` API 참조 "only one day"(조사 노트 G-4.4-06 기록 — 이번에 API 참조는 다시 읽지 않았다) | DEA 는 일수를 적지 않는다 — **옳은 판정**. `dea-t4-4-q7` `W1` 의 메모 문장만 걷는다(G3) |
| Quick 명칭 | DEA 범위 내 목록 「Amazon Quick」 | 제품 문서 제목 「What is AWS Quick?」 | G7 |
| Glue 잡 큐잉의 대상 한도 | Big Data Blog: 잡 단위 한도 포함 | CDK Glue readme: "monitors your **account level** quotas and limits" | `dea-t1-2-q9`(c=0) 정답은 블로그 서술과 일치 — **유지**(✅ 8). 근거가 블로그라는 점만 기록 |

### 6-2. 공식에서 확인되지 않은 주장 (수정안을 내지 않는다)

- 「Redshift Serverless 는 파일 수를 128의 배수로」 — `repost.aws` 에만 있다(Y7).
- Glue Data Catalog compaction 「기본 5개」 — 공식 페이지는 100개 초과로 적는다. 블로그 본문은 추출하지 못했다(Y9).

### 6-3. 이번 패스에서 **공식 대조를 하지 못한** 주장 (통독에서 후보로 잡았으나 시간 안에 닫지 못함 — 「통과」가 아니다)

| 자리 | 주장 |
|---|---|
| `dea-t1-2.md:93`·`:190` | Glue 1.0·2.0 2026-04-01 수명 종료 · Glue 6.0 의 Python 3.13 |
| `dea-t3-1.md:198` | Visual ETL 이 쓰는 Glue 버전 4.0·5.0·5.1 |
| `dea-t2-1.md:104~106` | RG 노드 유형 세부 · DC2 「압축 기준 1 TB 미만」 · DS2 제공 종료 |
| `dea-t2-4.md:138` | Schema Registry 하드 한도(레지스트리 100 · 스키마 버전 10,000 · 170 KB) — General Reference 추출 실패 |
| `dea-t1-1.md:148` | UNLOAD 권장 파일 크기 128~512 MB(근거 블로그) |
| `dea-t3-1.md:191`·`:267` | Redshift Data API 한도 · RDS Data API 응답 1 MiB |
| `dea-t4-1.md:232` | SageMaker Unified Studio 프로젝트 멤버 최대 20명 |
| `dea-t3-3-q13`(c=1) | EMR 자동 종료와 비 YARN 워크로드 |
| `dea-t3-1.md:211` | Athena 페더레이션 커넥터 공지(2026-04-21) |
| `dea-t2-4.md:225` | Bedrock Knowledge Bases 커넥터 공지(2026-09-30) |
| `dea-t1-2.md:81` 등 4자리 | Redshift Python UDF 2026-06-30 — 공지 문구는 오늘도 Redshift 문서 상단에 그대로 있다("We will start enforcing it in phases"). 날짜가 지났으므로 시제(「이후 지원 중단」)를 2단계에서 다듬을지 판단 |
| Firehose | Lambda 변환 재시도·버퍼 범위(지난 2026-11-06 검토가 5 MB/300초·0~900초는 확인) |
| 문항 출처 URL | 고유 363개 중 327개는 「그 페이지가 그 사실을 담는가」를 이번에 **읽지 않았다** |

---

## 7. 2단계에 넘기는 순서 제안

1. **🔴 공개 문항 2건** — R1(`dea-t1-1-q7` 해설 + md 1줄) · R2(`dea-t1-4-q13` `W3`). 둘 다 한 문장 치환이고 정답 인덱스·보기 불변. 가장 싸고 가장 급하다.
2. **🔴 학습문서 3건** — R3(Glue 기본 6.0, 2줄) · R4(Access Points 계정·리전당, 2줄) · R5(boto3 기본 standard, 2줄). `lastVerified` 를 함께 올린다.
3. **🟡 교차 자격증 계열** — Y1(Multi-AZ 5자리) · Y10(NAT 6자리) · Y2(PT 2자리). SAA·SOA·AIF 가 이미 쓴 문구를 그대로 가져온다.
4. **🟡 오답 근거·출처** — Y4(`dea-t3-2-q1` W3) · Y5(`dea-t3-3-q2` W3 + Essentials 병기) · Y6(CDK 출처 추가) · Y14(`dea-t4-1-q4` 공식 출처 추가) · Y16(백서 메모).
5. **🟡 수치·한도** — Y3(KMS 25) · Y9(compaction 100) · Y11(MWAA micro) · Y12(실패 대상) · Y8(PI 날짜) · Y7(128의 배수 귀속) · Y15(ALL 분산).
6. **🟡 Y13** — 「사람 검수 전」 25줄 일괄 정리(바이트 치환 + 횟수 단정 25).
7. **🟢** — G5 오타 · G4 날짜 지문 · G3 메모 → G2 자기 프레임 13건 → G1 길이 단서(2배 이상 34건부터) → G6 중복 5묶음(**문항 교체는 사람 승인**).
8. **§6-3 미대조 목록** — 보정 전에 한 번 더 재거나, 보정 범위에서 명시적으로 제외한다.

### 7-1. md 금지 문장 후보 (전파 가드 `soa_dea_question_propagation_test` 의 `_factRules`/`_nameRules` 용)

DEA 에는 md 사실 가드가 `dea_mla_p1_review_fix_test` 하나뿐이다. 이번 보정이 새 `test/dea_*` 가드를 만들면 그 파일의 **트립와이어가 울린다** — 아래를 함께 옮긴다. 규칙은 **사실 영역**(지문·스킬·정답 보기·해설·오답 근거)만 보고 오답 보기는 뺀다(일부러 틀린 서술이므로).

| 후보 문구(정규식 수준) | 문맥 조건 | 현재 md / 문항 |
|---|---|---|
| `샤드당 (최대 )?20` | EFO·등록 소비자 문맥 | 1 / 1 |
| `버킷당 (최대 )?10,000` | Access Points 문맥 | 2 / 0 |
| `rolling with additional batch는 EC2` | — | 0 / 1 |
| `기본 Glue 버전은 5\.1` · `5\.1\*{0,2}로 생성` | ⚠️ `5\.1` 단독은 스킬 번호 `(4.5.1)` 에 걸린다 — 문구로 좁힌다 | 2 / 0 |
| `legacy를 기본` | boto3 문맥 | 1 / 0 |
| `커스텀 모델에 필수` · `약정이 필요하며` | Provisioned Throughput 문맥 | 1 / 1 |
| `키당 (평생 )?10회` | 온디맨드 회전 문맥 | 1 / 1(출처 제목 — ⚠️ `sources[].title` 까지 보는 `_nameRules` 쪽이어야 잡힌다) |
| `구체화된 뷰는 Amazon Redshift의 객체입니다\. Athena` | 좁은 리터럴 | 0 / 1 |
| `Multi-AZ` + `읽기 트래픽` 이 같은 줄 | 「DB 인스턴스 배포」·「DB 클러스터」 한정이 없으면 위반(SOA 판 문맥 규칙과 같은 형태) | 4 / 1 |
| `공식 자료 간 서술이 엇갈려` · `문서 간 일수 표현에 차이` | M2 메모 | 0 / 2 |
| `2026-1[01] 현재` | 날짜 고정 지문 | 1 / 1 |
| `사람 검수 전` | md 전수 0건 불변식(상태 단정이 아니라 낡은 문구 금지) | 25 / 0 |
| `북반` | 오타 | 1 / 0 |

- ⚠️ 리터럴 가드는 어형 하나로 뚫린다(AIF 「PT 필수」) — 위 표의 한국어 문구는 **정규식 + 대조군**으로 건다.
- ⚠️ 금지하지 **않을** 것: `Infrequent Access`(API 값이 계속 유효 · S3 스토리지 클래스와 문자열이 같다) · `Amazon Quick`(시험 가이드 표기) · `퍼블릭 서브넷의 NAT 게이트웨이`(영역형으로는 참 — 「해야」의 배타성만 문제) · `128의 배수`(귀속을 붙여 남길 수 있다).

---

_측정 메모_: prescreen 산출물은 gitignored `flutter_app/build/dea_review/` 에만 있다. 중간 스크립트·추출물은 세션 scratchpad 에 두었고 레포에는 이 보고서 외에 쓴 파일이 없다. `flutter test`·`flutter build` 는 돌리지 않았다. git 상태를 바꾸는 명령은 쓰지 않았다(시작 시점의 untracked `docs/audits/2026-11-17-full-verify/` 그대로).
