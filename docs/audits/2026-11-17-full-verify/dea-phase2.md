# DEA 2단계 보정 — 2026-11-17

> 1단계 보고서: `docs/audits/2026-11-17-full-verify/dea.md` · 계약: `01-PHASE2-CONTRACT.md`
> 범위: `flutter_app/assets/content/dea/` md 17편 · 문항 256개(**전부 `verified: true` — 라이브**).
> ⛔ 커밋·브랜치 전환·flip 은 하지 않았다. `verified` 를 쓴 곳은 **0건**이다.

## 0. 요약

- **채택 25 / 기각 0 / 범위 확장 2** (1단계 보고의 🔴 **5** · 🟡 **16** 대비 — 🔴·🟡 **전건 반영** + 🟢 4건)
- 손댄 파일: **md 17편 · 문항 11파일 · 가드 1** (28 files changed, **112 insertions / 100 deletions**)
- **정답 인덱스 변경: 0건** — `git diff -U0` 의 변경 줄에서 `"correct"`·`"verified"` 가 **0건**임을 기계로 확인했다(손댄 18문항의 인덱스를 가드가 1단계 실측값과 대조한다).
- 새 가드 테스트 수: **28건** (`flutter_app/test/dea_v2_fix_test.dart`)
  - 민감도 확인 방법: `git stash` 가 공유 트리에서 금지이므로 **문구를 임시로 깨서** 레드를 확인하고 **sha256 으로 복구를 증명**했다. 4개 대표 자리 전부 레드 → 복구 후 해시 동일 → 최종 그린(아래 §6).
- `prescreen`(실측): 구조·정합성 플래그 **0건** 유지 · 뱅크 플래그 0 Task · `authoring-memo` 0 · `explanation-long` 0 · **`meta-phrasing` 13 → 12**(G4 지문 정정분) · `length-cue` 111(불변 — §7 다음 배치)
- **남긴 것(다음 배치)**: 🟢 G1(길이 단서 111) · G2(자기 프레임 12) · G6(중복 5묶음 — **문항 교체는 사람 승인**) · G8 · G9 · Y14 의 출처 **순서 변경 10건** · 1단계 §6-3 의 미대조 13항목

### 측정에 쓴 공식 페이지 (전부 2026-11-17 `curl -sL` 실측 · `200 r=0`)

`service-sizes-and-limits.html`(KDS) · `release-notes.html`(Glue) · `access-points-restrictions-limitations-naming-rules.html` · `retries.html`(boto3) · `deployment-configurations.html`(CodeDeploy) · `using-features.rolling-version-deploy.html`(Beanstalk) · `Concepts.MultiAZ.html` · `model-customization-use.html` · `API_CreateProvisionedModelThroughput.html` · `resource-limits.html`·`rotating-keys-on-demand.html`(KMS) · `materialized-views.html`(Glue) · `CloudWatch_Logs_Log_Classes.html` · `bootstrapping.html`(CDK) · `compaction-management.html` · `nat-gateways-regional.html` · `environment-class.html`(MWAA) · `kinesis-on-failure-destination.html` · `configuration-vpc-internet.html` · `c_best-practices-best-dist-key.html`·`c_choosing_dist_sort.html`(Redshift) · `federated-queries.html`(Athena) · `what-is.html`(Quick) · `USER_PerfInsights.html`

---

## 1. 채택 — 무엇을 어떻게 고쳤는가

### 🔴 R1 `dea-t1-1-q7` + `dea-t1-1.md` — EFO 등록 소비자 한도의 단위
공식 `service-sizes-and-limits.html` 의 행 제목이 `Number of registered consumers per data stream` 이고 본문이 `up to 20 registered consumers (Enhanced Fan-out Limit) **for each data stream**`, `RegisterStreamConsumer` 행이 `You can register up to 20 consumers **per data stream**` 다. md 표 행과 문항 해설의 「샤드당 최대 20」을 **「데이터 스트림당 최대 20(On-demand Advantage 모드 50)」**으로 고쳤다. 정답 인덱스 **1 불변**.

> ⚠️ **같은 md 의 「소비자마다 샤드당 전용 2 MB/s」는 다른 사실이고 참이다** — 함께 지우면 안 된다. 가드가 그 문장의 **존재**를 단정해 과잉 정정을 막는다.

### 🔴 R2 `dea-t1-4-q13` `W3` — `rolling with additional batch` 의 귀속
문항이 인용한 `deployment-configurations.html` 에 그 문자열이 **0건**이고 EC2/온프레미스 사전 정의 구성은 표의 행으로 `CodeDeployDefault.AllAtOnce`·`HalfAtATime`·`OneAtATime` **셋뿐**이다. Beanstalk `using-features.rolling-version-deploy.html` 이 `All at once, Rolling, **Rolling with additional batch**, Immutable, and Traffic splitting` 으로 자기 배포 정책으로 적는다. `W3` 을 **Elastic Beanstalk 귀속 + CodeDeploy 의 실제 세 구성**으로 바꿨다. 정답 **0 불변**.

### 🔴 R3 `dea-t1-2.md` · `dea-t3-3.md` — 버전 미지정 Glue 잡의 기본 버전
`release-notes.html` — `AWS Glue 6.0 is the default version for jobs created without specifying an AWS Glue version.` 두 자리의 **5.1 → 6.0**. 같은 줄의 「최신은 Glue 6.0(Spark 4.1.1·Python 3.13)」은 공식 표와 일치해 그대로 뒀다.

### 🔴 R4 `dea-t4-5.md` 2자리 — S3 Access Points 한도
`access-points-restrictions-limitations-naming-rules.html` — `You can create a maximum of 10,000 access points **per AWS account per AWS Region**. If you need more than 10,000 ... you can request a service quota increase.` **「버킷당」 → 「계정·리전당」**(증액 요청 가능). 이미 옳던 `dea-t4-1.md:203` 은 손대지 않았다.

### 🔴 R5 `dea-t3-1.md` 2자리 — boto3 기본 재시도 모드
`retries.html` — `**Standard mode is the default mode** used by any Boto3 client you create.` · `Legacy mode was the default mode for Boto3 clients **before standard mode became the default**.` · `the default retry mode value is **standard**, and the default max_attempts value is **3** ..., or **4** for Amazon DynamoDB and Amazon DynamoDB Streams.`
「현행 문서는 legacy를 기본으로 적지만 … 2026년 11월에 standard로」라는 예고 문장을 **현재 사실**로 바꾸고, `:250` 의 「boto3 기본 재시도 모드는 자료마다 달라 단정하지 않는다」를 걷었다(Glue `MaxRetries` 쪽 보류는 유지). 표의 `legacy | 5` · `standard | 3` 은 공식과 일치해 그대로 뒀다.

### 🟡 Y1 Multi-AZ 배포 유형 한정 — **5자리** (지난 P2-DEA-2 미수정분)
`Concepts.MultiAZ.html` — `A Multi-AZ **DB instance deployment** has one standby DB instance ... but **doesn't serve read traffic**. ... A Multi-AZ **DB cluster deployment** has standby DB instances ... and **can also serve read traffic**.`
`dea-t2-1.md`(2) · `dea-t2-3.md`(2) · `dea-t2-1-q6`(`W3` + 출처 제목)에 **배포 유형 한정**을 넣었다. ⭐ SAA·SOA 는 이미 같은 한정으로 정정돼 있어 **자격증 간 불일치**였다. 오답 보기 `options[3]` 문구는 **그대로 뒀다**(일부러 틀린 서술에 한정을 넣으면 그 보기가 참이 되어 정답이 둘이 된다). 정답 **2 불변**.

### 🟡 Y2 Bedrock Provisioned Throughput — `dea-t1-2.md` + `q12` `W2`
`model-customization-use.html` 가 사용자 지정 모델의 추론 경로를 **둘**로 적고(`Purchase Provisioned Throughput` / `Deploy custom model for on-demand inference ... you don't need to set up provisioned compute resources`), `API_CreateProvisionedModelThroughput` 이 `To request a **no-commit** Provisioned Throughput, omit this field. Custom models support **all levels of commitment**.` 로 적는다. 「1·6개월 약정이 필요」·「커스텀 모델에 필수」를 걷고 **약정 없음/1개월/6개월 + 경로 둘**로 바꿨다. 정답 **0 불변**.
(문항이 인용한 ML 블로그는 지금도 「PT 필수」로 적는 **공식 내부 어긋남**이고, 더 구체적인 사용자 안내서·API 참조를 정본으로 봤다 — AIF·AIP 와 같은 판정.)

### 🟡 Y3 KMS 온디맨드 회전 — `dea-t4-3.md` + `q6` 출처 제목
`resource-limits.html` 쿼터 표가 `On-demand rotation | **25** | Customer managed keys | **No**(조정 불가)` 이고 본문이 `a maximum of **25 times per KMS key**. ... This quota is **not adjustable**.`, `rotating-keys-on-demand.html` 도 25 다. **10회 → 25회**로 고치고 **FAQ 와 어긋난다는 사실을 한 줄로 명시**했다(개수를 지우지 않은 이유: docs 두 페이지가 일치하고 그중 하나가 전용 쿼터 페이지다). 출처 제목의 「온디맨드 회전 키당 10회」는 지웠다. 정답 **0 불변**.

### 🟡 Y4 구체화된 뷰 — `dea-t3-2-q1` `W3` · `q9` `W2`
`glue/latest/dg/materialized-views.html` — `The precomputed data is also accessible from other services including **Amazon Athena** and Amazon Redshift.` 「Redshift 의 객체라 성립하지 않는다」는 근거가 무너지므로 **「스캔량은 줄지만 열 때마다 원본 쿼리가 실행된다 → 반복 열람 비용을 없애는 것은 SPICE」**로 바꿨다. `q9` 은 「Redshift 객체」를 「객체」로만 좁혔다. 정답 **1·1 불변**(SPICE 유일성 유지).

### 🟡 Y5 로그 클래스 — `dea-t3-3-q2` `W3` + md 2자리
`CloudWatch_Logs_Log_Classes.html` **기능 표**가 `Export to Amazon S3 | Yes | Yes` · `Subscription filters | Yes | No` 이고(⚠️ **표의 행**이라 산문 검색으로는 안 잡힌다), `The *Infrequent Access* log class has been **renamed to *Essentials***. ... **Starting December 2026**, API responses ... will return `ESSENTIALS`` 다. M2 메모(「공식 자료 간 서술이 엇갈려」)를 걷고 **「S3 내보내기는 되지만 비동기 배치라 지속 아카이브의 권장 방식이 아니다」**로 바꿨다. 로그 클래스를 정의하는 두 자리(`dea-t3-3.md`·`dea-t4-4.md`)에 **Essentials 개명 + 2026-12 API 응답**을 병기했다. 정답 **2 불변**.
> ⚠️ `Infrequent Access` **자체는 금지하지 않았다** — API 값이 계속 유효하고 **S3 스토리지 클래스의 IA 와 문자열이 같다**.

### 🟡 Y6 `dea-t1-4-q10` — 정답의 핵심 사실을 담는 출처 추가
기존 출처 둘(`cdk/v2/guide/home.html`·`constructs.html`)에 `bootstrap` **0건** · `CDKToolkit` **0건**(대조군 `CloudFormation` 은 잡힌다). 새 출처 `cdk/v2/guide/bootstrapping.html` 실측 **`200 r=0` · `bootstrap` 23건 · `CDKToolkit` 1건** → **첫 출처로 추가**하고 기존 둘은 각각 다른 사실의 근거라 유지했다. `dea-t1-4.md` 의 **프런트매터 `sources` + 「출처」 절(#41)** 에도 함께 넣었다.

### 🟡 Y7 「Redshift Serverless 는 128의 배수」 — 귀속(걷지 않음) · md 4 + 문항 2필드
공식 `c_best-practices-use-multiple-files.html`·`t_splitting-data-files.html` 에 **Serverless·128의 배수 서술이 없다**(근거가 `repost.aws` 뿐). 레포 규율(`repost.aws` 를 **공식 근거로** 쓰지 않는다)에 맞춰 **① 귀속**을 골랐다 — 다섯 자리 전부 「**AWS re:Post 지식 센터** 권고」로 주어를 바꾸고, 공식 문서의 서술은 **슬라이스 수의 배수까지**라고 적었다. 정답 **0 불변**.

### 🟡 Y8 RDS Performance Insights 종료일 — 날짜를 단정하지 않는다
⚠️⚠️ **1단계가 인용한 요금 페이지가 오늘은 살아 있지 않다** — `aws.amazon.com/rds/performance-insights/pricing/` 는 **`r=1` 로 `aws.amazon.com/cloudwatch/pricing/`** 로 가고 그 본문에 `July 31, 2026` 이 **0건**이다(165,780자 추출). 사용자 안내서 `USER_PerfInsights.html` 은 제목이 **Database Insights** 로 바뀌었고 `2026`·`no longer` 가 **0건**(대조군 `Database Insights` **10건**)이다.
→ **날짜를 적는 공식 페이지가 없다.** CLF 「레거시 12개월」·SAA 「us-east-1 DX 단가」 선례대로 **날짜를 걷고** 「CloudWatch Database Insights 로 이전됐다 · 종료 날짜는 공식 문서에서 확인되지 않아 단정하지 않는다」로 바꿨다. 참고자료에 `USER_PerfInsights.html`(`200 r=0`)을 **#53으로 추가**하고 re:Post 항목에는 그 상태를 적었다. `Standard mode 기본 · 실행 계획·온디맨드 분석은 Advanced 전용` 은 양쪽이 일치해 유지.

### 🟡 Y9 Glue Data Catalog compaction — `dea-t2-1.md`
`compaction-management.html` — `the compaction process starts when a table or any of its partitions have **more than 100 files**. Each file must be smaller than **75%** of the target file size. The target file size is defined by the `write.target-file-size-bytes` table property, which **defaults to 512 MB**`. 「기본 5개」를 걷고 공식 수치 셋으로 바꿨다.

### 🟡 Y10 NAT 게이트웨이 — 영역형 전제의 배타 서술 · md 4 + 문항 2
`nat-gateways-regional.html` — `with a regional NAT Gateway, **you don't need to create a public subnet to host it**.` · `Enhanced security – **No public subnets required**.`
「퍼블릭 서브넷의 NAT 게이트웨이를 **경유해야/있어야**」의 **배타성만** 걷고 영역형/리전형을 병기했다. ⚠️ **정답 보기는 바꾸지 않았다** — 영역형 구성으로서 지금도 정답이고, `dea-t4-1-q4` 의 정답 보기는 이미 **최장**(2배 이상 길이 단서 목록)이라 거기에 글을 더하면 G1 이 악화된다. 그래서 **한정은 `explanation` 에만** 넣었다(계약의 「상태·한계 메모는 explanation 에」). 정답 **0·3 불변**.

### 🟡 Y11 MWAA 스케줄러 — `mw1.micro` 예외 · md 2 + `q9` `W2`
`environment-class.html` — `For environments larger than **mw1.micro**, accepts values from 2 to 5. Defaults to 2 for all environment sizes **except mw1.micro, which defaults to 1**.`(같은 페이지: `mw1.micro does not support auto-scaling.`) 세 자리에 예외를 넣었다. 정답 **0 불변**.

### 🟡 Y12 Kinesis ESM 실패 대상 — `dea-t1-1.md` + `q15`
`kinesis-on-failure-destination.html` — `You can configure any Amazon SNS topic, Amazon SQS queue, **Amazon S3 bucket**, or Kafka as a destination.` · `For Amazon S3 destinations, Lambda also sends the **entire invocation record** along with the metadata.`
⭐ **정답 보기에서 괄호를 걷어 길이 단서가 함께 줄었다**(54자 → 45자). 네 대상과 「S3 대상만 호출 레코드 전체」라는 갈림길은 **해설과 md** 로 내렸다(지문 요구가 「데이터를 잃지 않는다」이므로 그 비대칭이 교육의 핵심이다). 정답 **0 불변**.

### 🟡 Y13 낡은 저작 상태 문구 「사람 검수 전」 — **25자리** 전수 0건
DEA 는 256/256 이 공개인데 학습자가 읽는 md 에 저작 시점의 상태 문구가 남아 있었다. 자가 점검 머리말 **8줄** + 출처 절 머리말 **17줄**을 걷고 수집·저작 날짜는 유지했다.
⚠️ **어형이 둘이었다** — 「사람 검수 전이라 **사이트에는 노출되지 않습니다**」(t1-1·t2-1~t2-4) ↔ 「사람 검수 전이라 **사이트 비노출**」(t1-2·t1-3·t1-4). 1단계 보고가 전자 하나로 적었고 **치환 횟수 단정이 쓰기 전에 막아** 드러났다. 가드는 **낡은 문구 금지**이고 `verified` 를 보지 않는다.

### 🟡 Y14 `dea-t4-1-q4` — **유일한 출처가 `repost.aws`** 였다
공식 `lambda/latest/dg/configuration-vpc-internet.html` 실측 **`200 r=0` · `private subnet` 20건 · `NAT gateway` 20건**(같은 자격증 `dea-t1-1-q16` 이 이미 쓰는 페이지) → **첫 출처로 추가**하고 repost 를 둘째로 내렸다.
**나머지 10건의 순서 변경은 다음 배치로 넘긴다** — 순서를 바꾸려면 **그 공식 페이지가 그 사실을 담는지 본문 확인이 선행**돼야 하고(이 레포가 반복해 밟은 결함이다), 10개 페이지 본문 대조는 이 배치의 예산을 넘었다. 목록은 1단계 보고 Y14 에 있다.

### 🟡 Y15 「작은 차원 테이블은 ALL 분산」 — `dea-t3-4.md` 2자리
공식 조건은 「작다」가 아니라 **colocate 불가**다. `c_best-practices-best-dist-key.html` — `If a dimension table **cannot be collocated** with the fact table or other important joining tables, you can improve query performance significantly by distributing the entire table to all of the nodes.` 그리고 `c_choosing_dist_sort.html` — `Because the cost of redistributing small tables during a query is low, **there isn't a significant benefit to define small dimension tables as DISTSTYLE ALL**.`
⭐ **같은 자격증 `dea-t2-4.md` 가 이미 그 둘을 옳게 적어 문서끼리 어긋나 있었다** — `dea-t3-4` 쪽을 그 수준으로 맞췄다(`:153` 표 행 + `:158` 본문).

### 🟡 Y16 백서 출처의 상태 메모 (지난 P2-DEA-3 잔여)
`whitepapers/latest/big-data-analytics-options/amazon-athena.html` 은 **`200 r=1`** 로 `athena/latest/ug/what-is.html` 로 간다(사람 대상 서빙만 꺼진 백서 계열 — 레포 정책은 **인용 유지 + 상태 명시**).
⚠️ **중복 삭제 선택지는 기각했다** — `dea-t1-2-q7` 의 첫 출처 `federated-queries.html` 은 `charge`·`cost` 가 **0건**이고 요금을 **링크로만** 가리켜(`Pricing – For pricing information, see Amazon Athena pricing`) 커넥터 Lambda 요금 사실을 담지 않는다. 그래서 **백서 줄을 지우지 않고** md `#16` 과 문항 출처 제목에 상태 메모를 달았다.

### 🟢 함께 닫은 것 4건
- **G3** 저작 메모 — `dea-t4-4-q7` `W1` 의 「문서 간 일수 표현에 차이가 있습니다」를 **사실 서술**로 바꿨고(일수는 여전히 적지 않는다 — 공식 내부 어긋남), md 2줄의 「**문항은 피하세요**」(저작자에게 하는 말)를 「외우지 않아도 됩니다」로 바꿨다. ⚠️ 「공식 문서에서 확인되지 않았으므로 정답으로 고르지 않습니다」류 **시험 전략** 서술은 의도된 것이라 **금지하지 않았다**(md 14줄은 한 줄씩 판정이 필요해 다음 배치).
- **G4** 날짜 고정 지문 — `dea-t4-4-q11` 지문과 `dea-t4-4.md` 자가 점검 Q5 의 「2026-10 현재 공식 문서를 근거로」를 「신규 구축에서」로. ⭐ 이것으로 `prescreen` `meta-phrasing` 이 13 → 12 가 됐다.
- **G5** 오타 — `Glue 북반` → `Glue 북마크`(1자리, R5 와 같은 줄이라 함께).
- **G7** Quick 출처 제목 — 실제 `<title>` 이 **`What is AWS Quick? - AWS Quick`**(본문 `AWS Quick` 20건 · `Amazon Quick` 1건)이라 출처 제목 **3자리**를 페이지 제목으로 맞췄다. **본문 표기는 시험 가이드 표기(Amazon Quick)를 유지**하고 md 에 「제품 문서 표기는 AWS Quick」 한 줄을 넣었다.

---

## 2. 기각 — 0건

1단계 보고의 🔴 5 · 🟡 16 은 **전부 공식 문서로 재확인돼 채택**됐다(과대 보고 0건). 다만 **수정 방향을 보고와 달리 판정한 자리가 셋**이다:

| 자리 | 보고 | 이 배치의 판정 | 근거 |
|---|---|---|---|
| **Y8** | 요금 페이지를 참고자료에 추가하고 2026-07-31 을 적는다 | **날짜를 단정하지 않고 그 페이지도 인용하지 않는다** | 그 URL 이 오늘 `r=1` 로 CloudWatch 요금 페이지로 가고 거기에 `July 31, 2026` 0건 |
| **Y16** | 첫 출처가 사실을 담으면 백서 줄을 **중복 삭제** | **유지 + 상태 메모** | `federated-queries.html` 에 `charge`·`cost` 0건 — 그 사실을 담지 않는다 |
| **Y3** | 25회로 고치거나 **횟수를 걷는다** | **25회로 고치고 어긋남을 명시** | docs **두 페이지**가 25 로 일치하고 그중 하나가 「조정 불가」를 적는 전용 쿼터 페이지다 |

그리고 보고가 **2단계 판단으로 남긴 둘**은 손대지 않기로 판정했다:
- `dea-t3-2.md:55`·`:117` 의 「구체화된 뷰는 네 가지 객체」 — **거짓이 아니다**(Redshift 쪽 서술이고 Glue 구체화된 뷰 보강은 Y4 의 결함과 무관하다).
- `dea-t4-1.md:179` 의 「…assume 할 수 있을 때**만**」 — **인용 페이지에 글자 그대로 있다**(1단계 §6-1). 리소스 정책 경로를 덧붙이는 것은 사실 정정이 아니라 보강이라 다음 배치로 남긴다.

---

## 3. 범위 확장 — 보고가 하한이던 자리 (전수 실측)

| 항목 | 보고 범위 | 전수 실측 | 무엇이 더 있었나 |
|---|---|---|---|
| **Y13** | 자가 점검 머리말 **8줄**(한 가지 어형) | **8줄 · 어형 둘** | 「사이트에는 노출되지 않습니다」 5편 ↔ **「사이트 비노출」 3편**(`t1-2`·`t1-3`·`t1-4`). 보고의 단일 문구로 치환하면 **3편이 조용히 남았다** — 치환 횟수 단정이 쓰기 전에 막았다 |
| **G7** | 출처 제목 **1자리**(`dea-t3-2-q3`) | **3자리** | 문항 출처 제목 1 + `dea-t3-2.md` **프런트매터 `sources` 1** + **「출처」 절 #2 1**. 전수 가드가 마지막 자리를 잡아 레드를 냈다 |

그 밖의 항목은 보고의 전수 수치가 실측과 **일치**했다(R1 1/1 · R4 2/0 · Y1 4/1 · Y7 4/1 · Y10 4/2 · Y11 2/1 · Y12 1/1 · Y13 25/0).

---

## 4. flip 준비 상태

**해당 없음** — DEA 는 256/256 이 이미 `verified: true` 라이브다. 이 배치는 **해설·오답 근거·출처·학습문서만** 바꿨고 `verified` 를 한 글자도 쓰지 않았다.

⚠️ 가드는 계약대로 **`verified` 상태를 단정하지 않는다**(2026-11-13 검수자의 첫 flip 을 레드로 끝낸 함정). 대신 **구조 단정**(보기 4개 · 문항 256개 · 정답 인덱스 불변)을 썼다.

---

## 5. 컨트롤러 요청

- [ ] **`CLAUDE.md` 기준선 줄** — 새 가드 `test/dea_v2_fix_test.dart` **28건** 추가(순증 **+28**. `test/dea_*` 와 자기 가드만 돌렸으므로 **합산 기준선은 컨트롤러가 전체 스위트로 확정**해 주세요).
- [ ] ⚠️⚠️ **`test/soa_dea_question_propagation_test.dart` 의 트립와이어가 설계대로 울렸다**(실측 **48 pass · 1 fail**). 메시지: *"DEA 가드가 새로 생겼다 — 그 금지 문장을 `_factRules` 에 옮기고 이 목록에 등록해라: [dea_v2_fix_test.dart]"*. **그 파일은 공유 파일이라 손대지 않았다.** 두 가지를 해 주세요:
  1. `registered` 집합에 **`'dea_v2_fix_test.dart'`** 추가(주석: 2026-11-17 2단계 보정 — md 정정의 문항 전파 금지 문구를 아래로 옮겼다).
  2. `_factRules` 에 아래를 추가(⚠️ `_factRules` 는 **`stem`·`skill`·`options[correct]`·`explanation`·`wrongExplanations`** 만 보고 **오답 보기를 제외**한다 — 그 계약이 이 목록의 전제다. 모두 **현재 DEA·SOA 문항 전수 0건**이라 추가해도 즉시 레드가 나지 않는다):

| `text` | `why`(정본) |
|---|---|
| `샤드당 최대 20` | EFO 등록 소비자 한도는 **데이터 스트림당** 20(Advantage 50)이다 — `service-sizes-and-limits.html` |
| `버킷당 최대 10,000` | S3 Access Points 는 **계정·리전당** 10,000(증액 가능) — `access-points-restrictions-limitations-naming-rules.html` |
| `rolling with additional batch는 EC2` | 그것은 **Elastic Beanstalk 의 배포 정책**이고 CodeDeploy EC2/온프레미스 구성은 AllAtOnce·HalfAtATime·OneAtATime 셋이다 |
| `기본 Glue 버전은 5.1` | 버전 미지정 잡의 기본은 **6.0** — `glue/latest/dg/release-notes.html` |
| `legacy를 기본` | boto3 기본 재시도 모드는 **standard**(`max_attempts` 3 · DynamoDB 계열 4) — `boto3/latest/guide/retries.html` |
| `커스텀 모델에 필수` | 사용자 지정 모델의 추론 경로는 **PT 구매 / 온디맨드 배포 둘** — `model-customization-use.html` |
| `평생 10회` | KMS 온디맨드 회전 쿼터는 **25회·조정 불가** — `kms/.../resource-limits.html` |
| `구체화된 뷰는 Amazon Redshift의 객체` | Glue Data Catalog 의 Iceberg 구체화된 뷰를 **Athena 로 읽는다** — `glue/latest/dg/materialized-views.html` |
| `공식 자료 간 서술이 엇갈려` | 현행 기능 표는 **S3 내보내기를 지원**으로 적는다(M2 저작 메모) — `CloudWatch_Logs_Log_Classes.html` |
| `실패 대상(SQS/SNS)` | Kinesis ESM 실패 대상은 **SNS·SQS·S3·Kafka 넷**이고 **S3 만 호출 레코드 전체** — `kinesis-on-failure-destination.html` |
| `파일 수가 설정값(기본 5개)` | Glue Data Catalog compaction 은 **100개 초과**·75% 미만·목표 512 MB — `compaction-management.html` |
| `2026-06-30 수명 종료` | RDS Performance Insights 종료 날짜는 **공식 문서에서 확인되지 않는다**(요금 페이지가 리다이렉트됐다) |
| `사람 검수 전` | 낡은 저작 상태 문구(⚠️ **공개 상태 단정이 아니다** — `verified` 를 보지 않는다) |

- [ ] **교차 자격증** — 1단계 §5 의 항목 가운데 **DEA 쪽은 전부 닫았다**. 상대 쪽은 손대지 않았으니 다른 보정 세션·다음 배치가 함께 봐야 한다:
  - **CloudWatch Logs 로그 클래스 `Essentials` 개명** — **전 자격증 공통 사안**이다. `Infrequent Access` 문자열이 **saa 3파일 · soa 1파일**에 있다(⚠️ **S3 스토리지 클래스의 IA 와 문자열이 같아** 문맥으로 갈라야 한다. DEA 전체에 `Essentials` 는 이 배치 전까지 0건이었다).
  - **KMS 온디맨드 회전 25/10 어긋남** — 「온디맨드 회전」이 **dva 1파일 · scs 2파일**에 있다(수치를 적는지는 확인하지 않았다).
  - **RDS Performance Insights 종료 날짜** — **saa 1파일 · soa 2파일**이 언급한다. 오늘 측정으로 **그 날짜를 적는 공식 페이지가 없다**(위 Y8) → 그쪽도 날짜를 걷어야 한다.
  - **boto3 재시도 기본 모드** — AIP 가 `AWS_NEW_RETRIES_2026` 옵트인 서술을 갖고 있다(레포 기록). 오늘 boto3 가이드는 **standard 를 기본으로** 적으므로 AIP 쪽도 같은 날짜 기준으로 다시 볼 사안이다.
  - **Multi-AZ · NAT 게이트웨이 · Bedrock PT** — SAA·SOA·AIF·AIP 는 이미 정정돼 있고 **DEA 만 낡아 있었다**(이 배치로 해소).
- [ ] **정답 인덱스 변경이 필요한 문항: 0건.** 1단계 보고의 「정답이 둘·정답이 틀림 0건」을 재확인했다.
- [ ] **문항 교체는 사람 승인 영역** — 1단계 G6 의 중복 **5묶음(11문항)** 은 전부 `verified: true` 라이브다. 보고의 소유 판정(D1 → 3.3.1 · D2 → 4.4.1 · D3 → 2.3.1 · D4 → 4.1.1 · D5 → 4.2.4)까지만 전달하고 **손대지 않았다**. 원인이 **공식 가이드가 Task 3.3 과 4.4 에 같은 스킬을 두 번 싣는 것**이라 통합 모의고사 한 회에 함께 나올 수 있다.
- [ ] **`dea_questions_test` 는 스킬 전수 커버리지를 단정하지 않는다** — 1단계 §4-1 의 **문항 0건 스킬 6개**(1.1.12 · 1.2.1 · 1.2.9 · 1.4.3 · 1.4.4 · 1.4.5, 전부 도메인 1)는 **신규 저작**이라 이 보정의 범위가 아니다.

---

## 6. 측정 기록

### 민감도 — 가드가 실제로 레드가 되는가
`git stash` 가 공유 트리에서 금지이므로 **문구를 임시로 깨서** 확인하고 **sha256 으로 복구를 증명**했다(스크립트가 쓰기·복구·해시 비교를 한 번에 한다):

| 깨뜨린 자리 | 결과 | 복구 |
|---|---|---|
| `dea-t1-1.md` 를 「EFO 사용 시 샤드당 최대 20」으로 되돌림 | **R1 레드** | sha256 동일 ✅ |
| `dea-t2-3.md` 표 행에서 배포 유형 한정 제거 | **Y1 레드** | sha256 동일 ✅ |
| `dea-t4-5.md` 를 「버킷당 10,000개」로 되돌림 | **R4 레드** | sha256 동일 ✅ |
| `dea-t3-4.md` 를 「작은 차원 테이블은 ALL 분산」으로 되돌림 | **Y15 레드** | sha256 동일 ✅ |

복구 후 `flutter test test/dea_v2_fix_test.dart` → **28 All tests passed**.

### 돌린 것 / 돌리지 않은 것
- ✅ `flutter test test/dea_v2_fix_test.dart` — **28 pass**
- ✅ `flutter test test/dea_questions_test.dart test/dea_mla_p1_review_fix_test.dart` — **58 pass**
- ⚠️ `flutter test test/soa_dea_question_propagation_test.dart` — **48 pass · 1 fail(트립와이어, 설계대로)** → §5
- ✅ `flutter analyze test/dea_v2_fix_test.dart` — **No issues found**
- ✅ `node tool/prescreen.mjs build dea` — 구조·정합성 플래그 **0건** 유지
- ⛔ **전체 스위트·웹 빌드는 돌리지 않았다**(계약 §5). `all_content_parse_test`·`content_format_test` 는 공유 파일이라 돌리지 않았고, 대신 **그 가드의 축을 스크립트로 재현**해 확인했다: md 전수 `[텍스트](링크)` **0건** · 문항 JSON `**굵게**` **0건** · **프런트매터 `sources` 목록이 최상위 키로 끊기지 않는다**(17편 전부 파싱 수 == 선언 수 — 2026-11-11 SCS 에서 **출처 7개가 조용히 사라졌던** 결함의 축).

### 불변식 (기계 확인)
- 문항 **256개** · 보기 **전부 4개** · 정답 인덱스 분포 **109/67/52/28**(1단계 §4-2 와 동일)
- `git diff -U0` 의 변경 줄에 `"correct"`·`"verified"` **0건**
- **`HEAD` 와 문항 단위로 맞댄 결과 바뀐 문항은 정확히 18개**이고(`dea-t1-1-q7`·`q15`·`q16` · `dea-t1-2-q7`·`q12` · `dea-t1-3-q9` · `dea-t1-4-q10`·`q13` · `dea-t2-1-q6` · `dea-t2-3-q1` · `dea-t3-2-q1`·`q3`·`q9` · `dea-t3-3-q2` · `dea-t4-1-q4` · `dea-t4-3-q6` · `dea-t4-4-q7`·`q11`), 그 18개 전부에서 `correct` 와 `verified` 가 **같은 값임을 단정으로 증명**했다. 나머지 **238문항은 JSON 수준에서 완전히 동일**하다
- 작업 트리 **CRLF** 유지 — 모든 치환 전후로 **CR 수 == LF 수**를 단정했다
- 손댄 파일 **28개가 전부 `assets/content/dea/`** 안이다(다른 자격증·공유 파일 0건)

### 이 배치에서 비싸게 배운 것
1. ⚠️⚠️ **1단계가 인용한 URL 이 하루 만에 움직였다**(Y8 의 요금 페이지 `r=1`). **보고의 인용을 그대로 쓰기 전에 다시 잰다** — 「측정에는 유효 기간이 있다」가 또 확인됐다.
2. ⚠️⚠️ **보고의 단일 문구로 치환하면 어형 차이로 조용히 남는다**(Y13 의 3편). **치환 횟수 단정이 쓰기 전에** 막았다.
3. ⚠️ **굵게가 수치를 감싸면 정규식이 비켜 간다** — `계정·리전당 최대 **10,000개**` 를 `\*{0,2}` 없이 세서 **이미 옳던 `dea-t4-1.md` 자리를 놓쳤다**(가드가 2 vs 3 으로 레드를 냈다).
4. ⚠️ **여러 줄 앵커를 `\n` 으로 적으면 0건으로 막힌다**(작업 트리 CRLF) — 실제로 세 패턴이 막혔고 치환 함수에 **줄 끝 정규화**를 넣어 닫았다.
5. ⚠️ **`py -`(stdin 스크립트)가 또 REPL 로 떨어져 멈췄다** — 스크립트는 **파일로** 쓴다.
6. ⭐ **길이 단서와 사실 보강이 같은 방향인 자리가 있다** — Y12 는 정답 보기에서 괄호를 걷고 네 대상을 해설로 내려 **사실은 완전해지고 길이 단서는 줄었다**(54 → 45자).
