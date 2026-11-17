# DEA 2단계 보정 — 2026-11-17

> 1단계 보고서: `docs/audits/2026-11-17-full-verify/dea.md` · 계약: `01-PHASE2-CONTRACT.md`(브랜치 `content/phase2-fix-2026-11-17` 의 커밋 `8884494` 에서 읽었다 — 이 브랜치 작업 트리에는 없다)
> 범위: `flutter_app/assets/content/dea/` md 17편 · 문항 256개(전부 라이브).
> ⛔ 커밋·브랜치 전환·flip 은 하지 않았다. `"verified"`·`"correct"` 줄은 diff 에 **0줄**이다.
> 방법: 1단계 항목마다 **공식 페이지를 다시 내려받아**(`curl -sL` → 태그 제거 → `\s+` 정규화) 인용 문장을 직접 읽고, 대조군(그 페이지에 분명히 있는 문구)을 함께 세어 판정했다. 1단계가 인용한 문장을 그대로 믿은 항목은 없다.

## 0. 요약

- **채택 26 / 기각 0(수정안 단위 기각 4) / 범위 확장 11** — 1단계의 🔴 **5** · 🟡 **16** 은 **전건 반영**했고 🟢 9 가운데 **5**(G2·G3·G4·G5·G7)를 반영했다.
  - 「채택」 가운데 **판정을 바꿔서** 반영한 것이 넷이다(§2): R1 의 등급 · Y7 의 처리 방식 · Y8 의 날짜와 근거 · Y14 의 범위.
- 손댄 파일: **md 17편 · 문항 12파일 · 가드 1** (콘텐츠 29 files changed, 177 insertions / 122 deletions)
- **정답 인덱스 변경: 0건** — 바꿔야 하는 문항도 **0건**이다(§5).
- 새 가드 테스트 수: **55건** (`flutter_app/test/dea_v2_fix_test.dart`)
  - 보정 전 실행: **10 통과 · 45 실패**(레드 확인) → 보정 후 **55 통과**.
  - 민감도 확인 방법: `git stash` 가 금지라 **다섯 자리의 문구를 임시로 깨서** 실행했다 → **8건 레드**(R1 2 · R4 2 · Y8 2 · Y13 1 · G2 1) → 백업으로 되돌린 뒤 **sha256 이 깨기 전과 같음**을 파일마다 확인했다(§6).
- DEA 관련 테스트(`dea_questions_test` · `dea_mla_p1_review_fix_test` · `dea_v2_fix_test` · `soa_dea_question_propagation_test`): **161 통과 · 1 실패**. 실패 1건은 **설계된 트립와이어**다(§5).
- `prescreen`(보정 후 실측): 구조·정합성 플래그 **0건** · 뱅크 플래그 0 Task · `meta-phrasing` **13 → 0** · `authoring-memo` 0 · `explanation-long` 0 · `length-cue` 111(불변 — 다음 배치).
- 남긴 것(다음 배치): 🟢 **G1**(길이 단서 111) · **G6**(중복 5묶음 — 문항 교체는 사람 승인) · **G8** · **G9** · Y14 의 출처 **순서 변경 10건** · 1단계 §6-3 미대조 목록의 잔여(§3-12).

---

## 1. 채택 — 무엇을 어떻게 고쳤는가

정답 인덱스는 전부 1단계 실측값 그대로다(가드가 31문항의 인덱스를 대조한다).

### 🔴

| # | 자리 | 공식 근거(직접 읽은 문장) | 고친 것 |
|---|---|---|---|
| R1 | `dea-t1-1-q7`(c=1) 해설 · `dea-t1-1.md` CDC 표 | `streams/latest/dev/service-sizes-and-limits.html` 행 `Number of registered consumers per data stream` — "you can create up to 20 registered consumers (Enhanced Fan-out Limit) **for each data stream**" · Advantage 는 50. `enhanced-consumers.html` — "register up to 20 consumers **per stream**" | 「샤드당 최대 20」 → 「**데이터 스트림당** 최대 20(On-demand Advantage 50)」. q7 에 쿼터 페이지를 출처로 추가. ⚠️ 등급 판정은 §2-1 |
| R2 | `dea-t1-4-q13`(c=0) `W3` | `codedeploy/…/deployment-configurations.html` — `additional batch` **0건**(대조군 `OneAtATime` 4건 · `Linear` 12건), EC2/온프레미스 사전 정의 구성은 `AllAtOnce`·`HalfAtATime`·`OneAtATime`. `elasticbeanstalk/…/using-features.rolling-version-deploy.html` — "deployment policies (All at once, Rolling, **Rolling with additional batch**, Immutable, and Traffic splitting)" | `W3` 을 Elastic Beanstalk 귀속 + CodeDeploy 의 실제 세 구성으로. Beanstalk 페이지를 출처로 추가. 보기 문구 불변 |
| R3 | `dea-t1-2.md` · `dea-t3-3.md` | `glue/latest/dg/release-notes.html` — "AWS Glue 6.0 is the default version for jobs created without specifying an AWS Glue version." | 두 자리 5.1 → **6.0** |
| R4 | `dea-t4-5.md` 2자리 | `AmazonS3/…/access-points-restrictions-limitations-naming-rules.html` — "a maximum of 10,000 access points **per AWS account per AWS Region** … you can request a service quota increase" (대조군 `per bucket` 0건) | 「버킷당」 → 「**계정·리전당**」(증액 요청 가능). 참고자료에 그 페이지 추가(`dea-t4-5.md` 에는 없었다) |
| R5 | `dea-t3-1.md` 2자리 | `boto3/latest/guide/retries.html` — "**Standard mode is the default mode** used by any Boto3 client you create." · "Legacy mode was the default mode … before standard mode became the default." · "the default retry mode value is standard, and the default max_attempts value is 3 …, or 4 for Amazon DynamoDB and Amazon DynamoDB Streams" · legacy "A default value of 5 for maximum attempts" | 「현행 문서는 legacy 를 기본으로」 문단을 현재 사실로 교체(+ 기본 시도 3 · DynamoDB 계열 4). `:250` 의 「자료마다 달라」에서 boto3 를 뺐다(Glue `MaxRetries` 보류는 유지 — `API_CreateJob` 이 기본값을 적지 않는다). 표의 `legacy 5`·`standard 3` 은 공식과 일치해 **보존 가드**로 고정 |

### 🟡

| # | 자리 | 공식 근거 | 고친 것 |
|---|---|---|---|
| Y1 | `dea-t2-1.md` 2 · `dea-t2-3.md` 2 · `dea-t2-1-q6`(c=2) `W3`+출처 | `AmazonRDS/…/Concepts.MultiAZ.html` — "A Multi-AZ DB instance deployment has one standby DB instance that … **doesn't serve read traffic** … A Multi-AZ DB cluster deployment has standby DB instances that … **can also serve read traffic**." | 다섯 자리에 **배포 유형 한정**. `W3` 은 「I/O 과금과 무관」을 앞세워 오답 이유가 배포 유형에 기대지 않게 했다. 오답 보기 문구는 불변(가드로 고정) |
| Y2 | `dea-t1-2.md` · `dea-t1-2-q12`(c=0) `W2`+출처 | `bedrock/…/model-customization-use.html` — "set up inference using one of the following options: Purchase Provisioned Throughput … Deploy custom model for on-demand inference". `prov-throughput.html` — "No commitment … 1 month … 6 months" · "You're billed hourly" | 「1·6개월 약정 필수·커스텀 모델에 필수」 → 「약정 없음·1개월·6개월 + 경로 둘」. q12 의 둘째 출처를 ML 블로그에서 `prov-throughput.html` 로 교체 |
| Y3 | `dea-t4-3.md` · `dea-t4-3-q6`(c=0) 출처 제목 | `kms/…/resource-limits.html` — "On-demand rotation: 25" · "All AWS KMS resource quotas are adjustable, except for the on-demand rotation resource quota". `rotating-keys-on-demand.html` — "a maximum of 25 times per KMS key". ↔ `aws.amazon.com/kms/faqs/` — "lifetime limit of 10 on-demand rotations per key"(지금도) | md: 「평생 한도가 있다(개발자 안내서 쿼터 25회·조정 불가 — FAQ 는 10회)」. 출처 제목에서 「키당 10회」 삭제 |
| Y4 | `dea-t3-2-q1`(c=1) `W3`+출처 · `q9`(c=1) `W2` · `dea-t3-2.md` | `glue/latest/dg/materialized-views.html` — "The precomputed data is also accessible from other services including **Amazon Athena** and Amazon Redshift." · `lake-formation/…/materialized-views.html` — "precomputed data stored as Apache Iceberg tables" | `W3` 을 「성립하지 않는다」에서 「미리 계산한 결과를 읽게 할 뿐 — 열 때마다 쿼리가 실행되는 구조는 그대로 → SPICE」로. md 에 Glue Data Catalog 구체화된 뷰 한 줄 추가 |
| Y5 | `dea-t3-3-q2`(c=2) `W3`+출처 · `q14`(c=2)·`dea-t4-4-q7`(c=2) 해설 · md 2줄 | `…/logs/CloudWatch_Logs_Log_Classes.html` — "The Infrequent Access log class has been **renamed to Essentials** … Both values are accepted as input … Starting December 2026, API responses … will return ESSENTIALS" · 기능 표 행 `Export to Amazon S3 Yes ✓ Yes ✓` · `Subscription filters Yes ✓ No` | `W3` 의 저작 메모를 걷고 사실로 교체. 로그 클래스를 **정의하는 md 두 줄**과 IA 를 **가르치는 세 문항**에 Essentials 병기 |
| Y6 | `dea-t1-4-q10`(c=0) 출처 · `dea-t1-4.md` | `cdk/v2/guide/bootstrapping.html` — "By default, the stack name is **CDKToolkit**" · 부트스트랩 리소스 S3·ECR·IAM. 기존 출처 둘은 `bootstrap`·`CDKToolkit` **0건** | `bootstrapping.html` 을 **첫 출처로 추가**(기존 둘은 다른 사실의 근거라 유지). md 참고자료 #41 |
| Y7 | `dea-t2-3-q1`(c=0) 해설+출처 · md 4자리 | `redshift/…/c_best-practices-use-multiple-files.html` · `t_splitting-data-files.html` — `Serverless` **0건**, 「multiple of the number of slices」까지만. 문서 검색(「Redshift Serverless COPY multiple of 128」)도 `repost.aws` 만 돌려준다 | **걷었다**(§2-2). q1 의 둘째 출처를 repost 에서 공식 `Loading data files` 로 교체(128 MB 자동 분할은 그 페이지에 있다) |
| Y8 | `dea-t2-1.md` 3자리 | `AmazonCloudWatch/…/monitoring/Database-Insights.html` — "AWS announced that the end-of-life date for Performance Insights was **July 31, 2026**, and has migrated Performance Insights users to Database Insights." · "Standard mode is the default" · 기능 표 `Analyze SQL execution plans … Not supported / Supported only for …` | 2026-06-30 → **2026-07-31**. 참고자료 #52 를 repost 에서 그 공식 페이지로 교체. 「온디맨드 분석」은 그 페이지에 0건이라 「SQL 실행 계획·잠금 분석」(표에 있는 것)으로 좁혔다(§2-3) |
| Y9 | `dea-t2-1.md` | `glue/latest/dg/compaction-management.html` — "more than 100 files. Each file must be smaller than 75% of the target file size … defaults to 512 MB" | 「기본 5개」 → 「100개 초과 · 목표(기본 512 MB)의 75% 미만」. 참고자료 추가 |
| Y10 | md 4줄 · `dea-t1-1-q16`(c=0)·`dea-t4-1-q4`(c=3) 해설 | `vpc/…/nat-gateways-regional.html` — "with a regional NAT Gateway, **you don't need to create a public subnet to host it**" · "No public subnets required" | 여섯 자리에 영역형/리전형 한정. 보기 문구는 불변(영역형 구성으로는 지금도 정답) |
| Y11 | `dea-t1-3.md` 2줄 · `dea-t1-3-q9`(c=0) `W2` | `mwaa/…/environment-class.html` — "For environments larger than mw1.micro, accepts values from 2 to 5. Defaults to 2 … except mw1.micro, which defaults to 1." | 세 자리에 `mw1.micro` 예외 |
| Y12 | `dea-t1-1-q15`(c=0) 정답 보기+해설 · `dea-t1-1.md` | `lambda/…/kinesis-on-failure-destination.html` — "any Amazon SNS topic, Amazon SQS queue, **Amazon S3 bucket**, or Kafka" · "For Amazon S3 destinations, Lambda also sends the entire invocation record along with the metadata." | 정답 보기에서 괄호 「(SQS/SNS)」를 걷고 전체 목록과 전달 내용의 차이를 해설로 내렸다 |
| Y13 | md 25줄 | 사이트 자신의 상태 | 「사람 검수 전」 **25자리 전부** 삭제(어형이 셋이라 치환을 셋으로 갈랐다 — 5 + 3 + 17) |
| Y14 | `dea-t4-1-q4`(c=3) | `lambda/…/configuration-vpc.html` — "When you attach your function to a VPC, it can only access resources available within that VPC." · "Connecting a function to a public subnet doesn't give it internet access or a public IP address." · `configuration-vpc-internet.html` · `privatelink-access-aws-services.html` — "without the use of an internet gateway" | 단일 `repost.aws` 출처를 **공식 넷**으로 교체 |
| Y15 | `dea-t3-4.md` 2줄 | `redshift/…/c_best-practices-best-dist-key.html` — "If a dimension table **cannot be collocated** with the fact table …" · `c_choosing_dist_sort.html` — "there isn't a significant benefit to define small dimension tables as DISTSTYLE ALL" | 두 줄에 colocate 조건. `dea-t2-4.md` 의 「함정」 서술이 공식과 일치함을 확인했다(그쪽은 손대지 않음) |
| Y16 | `dea-t1-2-q7`(c=0) 출처 · `dea-t1-2.md` #16 | 백서 URL 은 curl 로 `200 r=1` → `athena/latest/ug/what-is.html`, AWS 문서 리더로는 `redirected_url: null` 에 본문 7,300자(= 사람 대상 서빙만 꺼진 상태). `aws.amazon.com/athena/pricing/` — "Such queries also invoke AWS Lambda functions in your account, and you are charged for Lambda use at standard rates." | q7 의 백서 출처를 **요금 페이지**로 교체(첫 출처 `federated-queries.html` 은 요금을 요금 페이지로 넘긴다). md #16 에는 #15 와 같은 상태 메모 |

### 🟢

| # | 고친 것 |
|---|---|
| G2 | 지문의 자기 프레임 **13문항 전부** — 「공식 문서 기준으로 / 공식 권장에 맞는 / 공식 문서가 권장하는」을 걷었다. `dea-t4-5-q7` 은 근거가 실제로 보안 블로그의 참조 아키텍처라 「AWS 보안 블로그의 참조 아키텍처가」로 정확히 귀속했다. 256문항 전수에서 지문·정답 보기의 「공식」 **0건**(가드) |
| G3 | 문항 3건(`dea-t3-3-q2` W3 · `dea-t4-4-q7` W1 · `dea-t2-1-q15` W3)의 저작 메모를 사실 서술로. md 는 「문항은 피하세요」 2줄만 걷었다(나머지는 §2-4) |
| G4 | `dea-t4-4-q11`(c=2) 지문과 `dea-t4-4.md` Q5 의 「2026-10 현재 공식 문서를 근거로」 → 「신규 구축에서」 |
| G5 | `dea-t3-1.md` 「북반」 → 「북마크」 |
| G7 | `dea-t3-2-q3` 출처 제목 · md 프런트매터·참고자료 제목을 실제 페이지 제목 「What is AWS Quick?」으로. 본문 표기는 시험 가이드 표기(Amazon Quick) 유지 + 그 사실을 한 줄로 명시 |

---

## 2. 기각·판정 변경 — 1단계와 다르게 처리한 것

**전면 기각(고치지 않음)은 0건**이다. 수정안 단위로 다르게 판정한 것이 넷이고, 1단계가 「손대지 말 것」으로 적은 것은 그대로 뒀다.

### 2-1. R1 — 「거짓」이 아니라 **공식 내부 어긋남**이다 (등급 정정, 수정은 채택)
1단계는 「샤드당 최대 20」을 거짓으로 적었지만, **DynamoDB 개발자 안내서의 비교 표가 지금도 그렇게 적는다**:
`amazondynamodb/latest/developerguide/streamsmain.html` — "Number of consumers: Up to 5 simultaneous consumers per shard, or **up to 20 simultaneous consumers per shard with enhanced fan-out**."
`dea-t1-1.md` 의 그 줄은 바로 그 표(DynamoDB Streams ↔ Kinesis Data Streams for DynamoDB)를 옮긴 것이었다. 한도를 **정의하는** KDS 전용 페이지 둘이 「데이터 스트림당」으로 일치하고, 같은 md 의 `:110` 이 이미 「등록 수 기본 20(Advantage 50)」으로 적어 **문서 내부 단위를 맞추는 것**이 옳으므로 수정은 그대로 했다. 다만 **공개 문항의 사실 오류**로 셀 자리는 아니다(등록 소비자 20개가 각 샤드를 읽으므로 「샤드당 동시 소비자 20」도 틀린 말은 아니다).
> ⚠️ 가드는 「소비자마다 샤드당 전용 2 MB/s」(다른 사실이고 참)를 **보존**으로 고정했다 — 「샤드당」을 통째로 지우는 과잉 정정을 막는다.

### 2-2. Y7 — 「귀속해 남기기」 대신 **걷었다**
1단계는 ① re:Post 귀속 ② 걷기 둘을 제시했다. 계약 §2 가 「공식에 없으면 걷거나 측정된 범위로 좁힌다(`repost.aws` 를 근거로 쓰지 않는다)」이므로 ②를 골랐다. 공식 두 페이지와 문서 검색 모두에서 Serverless·128 은 `repost.aws` 한 곳에만 있다. md 참고자료의 그 re:Post 줄 둘(`dea-t1-4.md` #6 · `dea-t2-3.md` #7)은 번호 목록이라 **그대로 두었다**(본문이 더는 그 주장을 하지 않는다).

### 2-3. Y8 — 날짜를 「단정하지 않는다」가 아니라 **2026-07-31 로 확정**했다
1단계 수정안의 근거 `aws.amazon.com/rds/performance-insights/pricing/` 는 오늘 **`200 r=1` 로 `aws.amazon.com/cloudwatch/pricing/`** 로 가고 그 본문(162,892자)에 `July 31, 2026` 이 0건이다 → 그 URL 은 근거로 쓰지 않았다. 대신 **CloudWatch 사용자 안내서 `Database-Insights.html` 이 종료 날짜를 문장으로 적는다**(위 표). 학습문서의 2026-06-30 은 `repost.aws` 에서 온 값이었고 공식 문서와 달랐으므로, 이 항목은 「불완전」이 아니라 **날짜가 틀린 자리**였다.
같은 줄의 「실행 계획·**온디맨드 분석**은 Advanced 전용」에서 「온디맨드 분석」은 그 페이지에 0건이라, 기능 표에 실재하는 「SQL 실행 계획·잠금 분석」으로 좁혔다.

### 2-4. G3 — md 의 「확인되지 않았습니다」류 13줄은 **남겼다**
`dea-t2-4:197`·`:257` · `dea-t3-4:101`·`:144` · `dea-t4-1:235` · `dea-t4-3:122`·`:202` · `dea-t4-4:139` · `dea-t4-5:107`·`:135`·`:145`·`:151`·`:250`. 한 줄씩 읽었다 — 전부 **「공식 문서에 근거가 없으니 정답으로 고르지 말라」는 범위 한정**이거나 **공식 내부 어긋남의 고지**이고, 지우면 그 자리에 근거 없는 단정이 남는다. 저작자에게 하는 말(「…문항은 피하세요」)인 2줄만 걷었다.

### 2-5. 그대로 둔 것 (1단계도 「손대지 말 것」으로 적었다)
- `MB/s` 표기 통일 — 하지 않았다(한 문항 안 혼용 0건이 불변식이다).
- `dea-t4-1.md:179` API Gateway 교차 계정 — 인용 페이지에 글자 그대로 있다.
- `dea-t3-2.md` 의 「네 가지 객체」 틀 — 거짓이 아니다(Glue Data Catalog 구체화된 뷰는 한 줄만 보탰다).
- `tagging-best-practices` 백서(`dea-t4-2`) — `200 r=0` 으로 살아 있다.
- Y3 의 대안 「횟수를 걷는다」 — 고르지 않았다. docs 두 페이지가 25 로 일치하고 그중 하나가 전용 쿼터 페이지라 수치를 남기고 **FAQ 와 다르다는 사실을 함께** 적었다.
- Y14 의 「나머지 10문항 출처 순서 바꾸기」 — 이번에 하지 않았다(다음 배치). 순서만 바꾸는 것은 사실을 바꾸지 않고, 한 건씩 「블로그만 그 사실을 담는가」를 봐야 한다.

---

## 3. 범위 확장 — 보고가 하한이던 자리

| # | 1단계가 적은 범위 | 실측 | 더 고친 것 |
|---|---|---|---|
| 3-1 | Y1: `dea-t2-1-q6` 의 `W3`·출처 **제목** | 그 출처 **페이지**(`USER_ReadRepl.html`)에 「Multi-AZ 스탠바이는 읽기 미처리」가 **없다** — `standby` 는 Db2·Oracle 복제본 모드 이야기뿐(대조군 `read replica` 다수) | 출처를 `Concepts.MultiAZ.html` 로 **교체**(「URL 은 200인데 그 사실이 없다」) |
| 3-2 | Y5: `W3` + md 2줄 | IA 클래스를 **가르치는 층**에서 다루는 문항이 둘 더 있다(`dea-t3-3-q14` · `dea-t4-4-q7`) — 오답노트 화면은 md 를 보여 주지 않는다 | 두 문항 해설에 Essentials 한 줄. `dea-t4-4-q15` 는 IA 가 **오답 보기**에만 나와 달지 않았다 |
| 3-3 | Y7: 해설 + 출처 **제목** | 둘째 출처 자체가 `repost.aws` | 공식 페이지로 교체 |
| 3-4 | Y12: 「(SQS·SNS·S3 등)으로 넓힌다」 | 정답 보기가 이미 길이 단서였다 | 괄호를 걷어 보기를 줄이고 목록은 해설로(사실 보강과 길이가 같은 방향) |
| 3-5 | Y14: `dea-t4-1-q4` 에 공식 출처 **추가** | 공식 세 페이지가 정답의 세 사실을 각각 담는다 | repost 를 내리고 공식 넷으로 **교체** |
| 3-6 | Y16: 「중복이면 백서 줄 삭제」 | 첫 출처는 Lambda 요금을 적지 않고 요금 페이지로 넘긴다 → 중복이 아니었다 | 요금 페이지로 **재소싱** |
| 3-7 | R1·R2: 문구만 | 새로 적은 사실(Advantage 50 · Beanstalk)을 담는 출처가 문항에 없었다 | 출처 추가 2건 |
| 3-8 | R5: 2줄 | 표가 standard 의 기본 시도 횟수를 3으로 적는데 DynamoDB 계열 4 가 빠져 있었다 | 본문에 보탰다 |
| 3-9 | Y8: md 2줄 + 참고자료 추가 | 참고자료 #52 가 그 날짜의 유일한 근거였고 `repost.aws` | #52 를 공식 페이지로 **교체** |
| 3-10 | G7: 출처 제목 1 + md 용어 한 줄 | `dea-t3-2.md:86` 이 「공식 문서는 **Amazon Quick이** … **Amazon Quick Sight로**」라고 **제품 문서에 없는 표기를 공식 문서의 말로 귀속**하고 있었다(원문: "AWS Quick evolved from Amazon QuickSight. QuickSight continues as AWS Quick Sight") | 귀속 문장을 고치고 두 표기의 출처(제품 문서 ↔ 시험 가이드 범위 내 목록)를 적었다. md 프런트매터 제목도 함께 |
| 3-11 | Y13: 「사람 검수 전이라 사이트에는 노출되지 않습니다」 8줄 | 어형이 둘이다(「…노출되지 않습니다」 5 · 「…사이트 비노출」 3) | 치환을 갈라 25/25 |

### 3-12. 1단계 §6-3(미대조) 가운데 이번에 공식 대조로 닫은 것 — 전부 **현행 서술이 옳다**(수정 없음)

| 주장 | 공식 근거 |
|---|---|
| Glue 1.0·2.0 2026-04-01 수명 종료 | `glue-version-support-policy.html` 표 — 0.9·1.0·2.0 의 End of life `4/1/2026` |
| Glue 6.0 = Spark 4.1.1 · Python 3.13 | `release-notes.html` 표 |
| Schema Registry 레지스트리 100 · 스키마 버전 10,000 | `general/latest/gr/glue.html` — 둘 다 조정 불가(`170 KB` 는 그 페이지에서 확인하지 못했다) |
| Redshift Data API 결과 500 MB · 보존 24시간 | `redshift/latest/mgmt/data-api.html` |
| RDS Data API 응답 1 MiB · 라이터 전용 · T 클래스 미지원 | `AuroraUserGuide/data-api.limitations.html` |
| Redshift Python UDF 2026-06-30 이후 지원 중단 | `redshift/latest/dg/user-defined-functions.html` 상단 공지(오늘도 같은 문구) |
| EMR 자동 종료와 비 YARN 워크로드(`isbusy`) | `emr-auto-termination-policy.html` |
| Athena 커넥터 공지 2026-04-21 | `athena/latest/ug/federated-queries.html` — "Starting April 21, 2026, certain newly created connectors are automatically registered as Glue Data Catalogs" |
| Delivery 로그 클래스의 보존은 고정 | 로그 클래스 페이지 — "kept in CloudWatch Logs for two days. This retention period is fixed" (DEA 는 일수를 적지 않는다 — 유지) |

**여전히 미대조**: Visual ETL 의 Glue 버전(「4.0·5.0·5.1」 가운데 5.0 기본·5.1 지원은 SageMaker Unified Studio 문서로 확인, **4.0 은 확인하지 못했다**) · RG/DC2/DS2 노드 세부 · UNLOAD 128~512 MB(블로그) · Unified Studio 프로젝트 멤버 20명 · Bedrock Knowledge Bases 커넥터 공지 · Firehose 재시도·버퍼 · 문항 출처 URL 327개의 「그 사실을 담는가」.

---

## 4. flip 준비 상태

해당 없음 — DEA 는 256/256 이 이미 공개다. 이 배치는 `verified` 를 건드리지 않았다(치환 스크립트가 파일마다 `"verified"`·`"verified": true`·`"correct"` 출현 수가 전후 같음을 단정한다).

---

## 5. 컨트롤러 요청

- [ ] **`test/soa_dea_question_propagation_test.dart`** 의 `registered` 에 `'dea_v2_fix_test.dart'` 등재. 트립와이어가 설계대로 울린다(`DEA 사실 가드가 새로 생기면 이 파일의 규칙을 채운다` 1건 레드 — 결함 아님).
  - 옮길 규칙에 대해: 새 가드는 **md 17편과 문항 17파일을 같은 규칙으로** 세므로(`factUnits`·`nameUnits`) 전파 구멍은 없다. 그래도 전파 가드에 문구로 남기려면 아래가 후보다(전부 보정 후 DEA 문항에서 0건).

  | 종류 | 금지 문구 | 비고 |
  |---|---|---|
  | `_factRules` | `샤드당 최대 20개까지` | EFO 문맥. ⚠️ 「샤드당 전용 2 MB/s」는 참이므로 `샤드당` 단독 금지 금지 |
  | `_factRules` | `EC2/온프레미스 배포 구성으로` | `rolling with additional batch` 귀속 |
  | `_factRules` | `구체화된 뷰는 Amazon Redshift의 객체입니다` | |
  | `_factRules` | `약정이 필요하며` · `커스텀 모델에 필수` | Provisioned Throughput |
  | `_factRules` | `공식 자료 간 서술이 엇갈려` · `문서 간 일수 표현에 차이` | 저작 메모 |
  | `_nameRules` | `128의 배수` · `실패 대상(SQS/SNS)` · `키당 10회` · `What is Amazon Quick?` · `2026-10 현재` | 출처 제목·보기까지 봐야 잡힌다 |
  | 금지하지 **않을** 것 | `Infrequent Access`(API 값 유효 · S3 스토리지 클래스와 동일 문자열) · `Amazon Quick`(시험 가이드 표기) · `2026-06-30`(Redshift Python UDF 의 날짜) · `퍼블릭 서브넷의 NAT 게이트웨이`(영역형으로는 참) | |

- [ ] **`CLAUDE.md` 기준선**: DEA 분 **+55**(`dea_v2_fix_test.dart`).
- [ ] **교차 자격증**(전부 읽기 전용 grep 실측 — 상대 파일은 손대지 않았다):
  - `dva/dva-t1-1.md:159` — 「…Python…은 **legacy가 기본**(재시도 쿼터 없음)」. 오늘 boto3 가이드는 `Standard mode is the default mode` 를 조건 없이 적는다(그 페이지에 `AWS_NEW_RETRIES_2026`·`opt-in` 0건). `aip/aip-t2-4` 는 이미 standard 기본으로 적지만 **`AWS_NEW_RETRIES_2026` 옵트인 서술**(md 4줄 · 문항 1줄)이 있어 같은 날짜 기준으로 다시 볼 사안이다.
  - `saa/saa-t3-5.md`(`Performance Insights` 5줄) · `soa/soa-t1-5.md`(6줄 + 문항 1줄) — 측정 시점에 세 파일 모두 `Database Insights` **0건**이다(상태 없이 현행 도구로 가르친다). 공식: **2026-07-31 수명 종료 · Database Insights 로 이전**(위 Y8 인용). ⚠️ 같은 트리에서 SAA·SOA 보정 세션이 돌고 있으므로 합칠 때 다시 센다.
  - 출처 제목 **「What is Amazon Quick?」** — 실제 페이지 제목은 「What is AWS Quick?」: `aif-t1-3`(md 2 · 문항 1) · `aif-t2-3`(md 2 · 문항 1) · `dva-t1-1.md` 1 · `mla-t4-2`(md 1 · 문항 1) = **9자리**.
  - DEA 에서 고친 나머지 거짓 문구(EFO 샤드당 20 · Glue 기본 5.1 · Access Points 버킷당 10,000 · 128의 배수 · compaction 기본 5개 · rolling with additional batch · KMS 10회)는 **다른 자격증 0건**이다. 로그 클래스의 Essentials 는 `dva-t4-1`·`scs-t5-3` 이 이미 반영했다.
- [ ] **정답 인덱스 변경이 필요한 문항: 없음.**
- [ ] **사람 승인이 필요한 것**: G6 중복 5묶음(11문항)의 문항 교체 — 1단계 §3 G6 표 그대로. 이번 배치는 손대지 않았다.
- [ ] 참고: `01-PHASE2-CONTRACT.md` 가 이 브랜치(`content/phase2-fable-2026-11-17`)의 작업 트리에 없다(커밋 `8884494` 는 `content/phase2-fix-2026-11-17` 에만 있다).

---

## 6. 검증 기록

### 측정에 쓴 공식 페이지 (전부 2026-11-17 `curl -sL` · `200 r=0`)
`streams/…/service-sizes-and-limits.html` · `enhanced-consumers.html` · `amazondynamodb/…/streamsmain.html` · `codedeploy/…/deployment-configurations.html` · `elasticbeanstalk/…/using-features.rolling-version-deploy.html` · `glue/…/release-notes.html` · `glue-version-support-policy.html` · `compaction-management.html` · `enable-compaction.html` · `materialized-views.html`(Glue·Lake Formation) · `AmazonS3/…/access-points-restrictions-limitations-naming-rules.html` · `boto3/latest/guide/retries.html` · `AmazonRDS/…/Concepts.MultiAZ.html` · `USER_ReadRepl.html` · `USER_PerfInsights.html` · `AmazonCloudWatch/…/monitoring/Database-Insights.html` · `…/logs/CloudWatch_Logs_Log_Classes.html` · `Subscriptions.html` · `API_CreateExportTask.html` · `bedrock/…/model-customization-use.html` · `prov-throughput.html` · `API_CreateProvisionedModelThroughput.html` · `kms/…/resource-limits.html` · `rotating-keys-on-demand.html` · `aws.amazon.com/kms/faqs/` · `cdk/v2/guide/bootstrapping.html`·`home.html`·`constructs.html` · `redshift/…/c_best-practices-use-multiple-files.html` · `t_splitting-data-files.html` · `c_best-practices-best-dist-key.html` · `c_choosing_dist_sort.html` · `user-defined-functions.html` · `mgmt/data-api.html` · `vpc/…/nat-gateways-regional.html` · `privatelink-access-aws-services.html` · `lambda/…/configuration-vpc.html` · `configuration-vpc-internet.html` · `kinesis-on-failure-destination.html` · `mwaa/…/environment-class.html` · `athena/…/federated-queries.html` · `aws.amazon.com/athena/pricing/` · `quick/…/what-is.html` · `aws-certification/…/dea-01-in-scope-services.html` · `emr/…/emr-auto-termination-policy.html` · `general/latest/gr/glue.html` · `AuroraUserGuide/data-api.limitations.html`.
`r=1` 이었던 것 둘: `aws.amazon.com/rds/performance-insights/pricing/`(→ CloudWatch 요금 — 근거로 쓰지 않음) · `whitepapers/…/big-data-analytics-options/amazon-athena.html`(→ Athena what-is — 문서 리더로는 본문이 읽힌다).

### 치환
- 스크립트는 파일로 썼다(바이트 블록 치환 · **치환 횟수 단정** · `CR == LF == CRLF` 불변식 · `"verified"`/`"correct"` 출현 수 불변 단정 · **하나라도 어긋나면 아무 파일도 쓰지 않음**). json 왕복은 하지 않았다.
- 건식 실행에서 횟수 단정은 한 번에 전부 통과했다. 출처 추가는 기존 출처 블록의 꼬리(제목+URL 두 줄)를 앵커로 삼았다.
- `git diff -U0` 에서 `"verified"`·`"correct"`·`"skill"`·`"section"`·`"difficulty"`·`"id"` 가 든 변경 줄 **0줄**. 34파일 전부 `CR == LF`.
- 추가한 md 줄 99줄에서 굵게(`**`)·백틱 짝 불일치 0 · 홑별표 0 · `[텍스트](링크)` 0.
- `lastVerified` 는 사실을 고친 **15편**만 2026-11-17 로 올렸다. `dea-t2-4`·`dea-t4-2` 는 Y13 문구만 지워서 올리지 않았다(사실을 다시 대조하지 않은 문서의 날짜를 올리면 과대 표시다). DEA 의 `lastVerified` 를 고정하는 테스트는 없다(grep 실측).

### 민감도 (문구를 깨서 레드 확인 → sha256 으로 복구 증명)
| 깬 자리 | 레드가 된 테스트 |
|---|---|
| `dea-t1-1.questions.json` 「데이터 스트림당 최대 20개」 → 「샤드당 최대 20개」 | R1 2건 |
| `dea-t4-5.md` 「계정·리전당 최대 10,000개」 → 「버킷당 최대 10,000개」 | R4 2건 |
| `dea-t2-1.md` 「2026-07-31에 수명 종료」 → 「2026-06-30…」 | Y8 2건(대조군 포함) |
| `dea-t2-4.md` 출처 머리말에 「· 사람 검수 전」 재삽입 | Y13 1건 |
| `dea-t3-3.questions.json` 지문에 「공식 문서가 권장하는」 재삽입 | G2 1건 |
다섯 파일 모두 복구 뒤 sha256 이 깨기 전 값과 같았다(스크립트가 `assert` 로 확인).

### 가드 설계 메모
- 사실 규칙은 **md 전 줄 + 문항의 가르치는 층**(`skill`·지문·정답 보기·해설·오답 근거)을, 명칭·출처 규칙은 **문항 전체**(보기 넷 + 출처 제목)를 본다. 오답 보기는 일부러 틀린 서술이라 사실 규칙에서 뺐다.
- 탐지기마다 대조군을 뒀다 — `(4.5.1)` 스킬 번호가 「Glue 5.1」 규칙에 걸리지 않음 · 「버킷당 1,000개」(수명 주기)가 Access Points 규칙에 걸리지 않음 · S3 Intelligent-Tiering 의 `Infrequent Access` 가 로그 클래스 규칙의 대상이 아님 · `2026-06-30` 은 Python UDF 줄에만 남음.
- **`verified` 상태는 단정하지 않는다.** 구조(보기 4·오답 근거 3·출처 ≥1)와 손댄 31문항의 정답 인덱스만 고정했다.
