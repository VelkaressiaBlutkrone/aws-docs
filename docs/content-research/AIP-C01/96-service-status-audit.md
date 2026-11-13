---
생성: 2026-11-13
목적: AIP-C01 **P-01** — 범위 내 106개 서비스 상태 전수 확인 (98 P-01 / 99 G-06·G-07·G-08·G-10을 닫는다)
조회일: 2026-11-13
---

# AIP-C01 — 96 범위 내 106개 서비스 상태 전수 확인

> 범위 목록의 정본은 [00-overview.md](00-overview.md) §5·§6, 저작 처리의 정본은
> [98-authoring-decisions.md](98-authoring-decisions.md) **D-07**, 열린 판정은
> [99-gaps.md](99-gaps.md)다. 이 노트는 **측정 기록**이고, 저작 때 인용할 URL과 상태 문구를 함께 남긴다.
> SCS-C03의 [96-service-status-audit.md](../SCS-C03/96-service-status-audit.md)와 같은 방법을 쓴다.

## 1. 결론

| 물음 | 답 |
|---|---|
| 공식 목록이 Phase 1 이후 바뀌었나 | **아니다** — 범위 내 13 카테고리 **106**, 범위 외 22 카테고리 **96**, lifecycle 세 표 **134**행이 전부 그대로다(G-12 재측정) |
| 범위 내에서 **서비스 자체**가 상태 변경 | **3개** — D-07의 셋과 **정확히 같다**. 신규 추가 0건 |
| 범위 내에서 **기능·에디션**이 상태 변경 | **35개 행 / 22개 서비스**(§5). G-08이 「이름이 걸렸다」까지 적어 둔 것을 **공식 상태 페이지 URL까지** 확정했다 |
| 표가 잡지 못한 상태·개명 | **6건**(§6) — 그중 **`Amazon Quick Sight` 문서가 `AWS Quick`으로 통합된 것**과 **`Amazon SageMaker Clarify` 신규 고객 차단**이 저작을 직접 제약한다 |
| 문서를 찾지 못한 범위 내 항목 | **2개** — `Kiro`(AWS docs에 가이드가 없다. 공식이 `kiro.dev`를 가리킨다) · `Amazon Q Business Apps`(가이드 TOC에 해당 항목 0건) |
| 내가 추정한 문서 URL이 틀렸던 것 | **7개**(§4). 그중 **2개는 은퇴한 슬러그**여서 레포 가드에 등재했다 |

⚠️⚠️ **이 전수 확인의 값은 「셋이 그대로였다」가 아니라 §6의 6건에 있다.** lifecycle 세 표는
**서비스·기능 단위 열거**이고, **문서가 통합되거나 제품 이름이 바뀐 것은 거기 오르지 않는다.**
`Amazon Quick Sight`는 세 표 어디에도 없는데 **사용자 안내서가 통째로 `AWS Quick`으로 리다이렉트**된다.

## 2. 측정 방법

G-06이 지시한 두 방법을 모두 썼고, SCS에서처럼 **둘이 서로를 교정했다.**

| | 방법 | 범위 | 산출 |
|---|---|---|---|
| **1차** | 서비스별 공식 문서(`what-is`·`welcome`)를 `curl -sL`로 받아 **상태 문구 정규식 탐침** + `http_code`·`num_redirects`·바이트 수 기록 | 내가 만든 **106개** URL 목록 | §4 · §6 |
| **2차** | 공식 **AWS Lifecycle Changes** 세 표 — 내 URL 목록과 **무관한 독립 열거** | AWS 전체 **134**개 항목 | §3 · §5 |

- 1차만으로는 기능 단위를 거의 못 잡는다(기능 공지는 **그 기능 페이지**에 있고 서비스 what-is에는 없다).
- 2차만으로는 **문서 통합·개명**을 못 잡는다(§6). `Kiro`처럼 **표에도 없고 문서도 없는** 자리도 1차만 본다.
- 입력은 공식 페이지와 레포 파일뿐이라 언제든 재현된다(§9).

### 대조군 (전부 실측 통과)

| 종류 | 대조군 | 쓰임 |
|---|---|---|
| **양성(서비스)** | `Amazon Kendra` · `Amazon Q Business` · `AWS App Runner` | 2차 탐지기가 서비스 단위를 잡는가 |
| **양성(기능)** | `Amazon Bedrock`→`Agents Classic` · `AWS WAF`→`Classic` · `AWS DataSync`→`Discovery` · `Amazon SNS`→`MDP` · `Amazon Augmented AI`→`SageMaker AI – A2I` · `Amazon Cognito`→`Sync` · `Amazon Kinesis`→`Data Analytics for SQL` | ⚠️ **v1에 없던 층** — §3이 이것 때문에 두 배가 됐다 |
| **혼합 표기** | `AWS Systems Manager` 세 행(en dash 1 + 복합 이름 2) | 표가 한 서비스에 두 규칙을 섞어 쓰는가 |
| **음성(이름)** | 없는 이름 `Zzz Bogus Service Name` → 0건 | 매칭이 아무 것이나 집지 않는가 |
| **음성(경계)** | `Amazon Connect`가 `AWS Service Management **Connector**`에 안 걸린다 | 부분 문자열 과잉 |
| **음성(한 낱말)** | `Amazon Connect`가 **`AWS Direct Connect`**에 안 걸린다 | 접두사 제거 변이형 과잉 |
| **양성(그래도)** | 그러면서 `Amazon Connect Customer Voice ID`는 걸린다 | 위 두 음성을 막다가 기능까지 막지 않았는가 |
| **탐지기(1차)** | 세 양성 문서에서 `new-customers` 신호가 **나온다** · `Amazon S3` 문서에서는 **0건** | 1차 정규식 민감도·특이도 |
| **본문 유무** | `200`이고 2.5KB 초과인 문서 **90편** | 「문구 0건 = 깨끗함」이 공허하지 않은가 |

**민감도를 확인하기 전의 0건은 결과가 아니다** — 이 규율이 아래 §3에서 네 번 값을 했다.

## 3. ⚠️⚠️⚠️ 탐지기가 네 번 조용히 실패했고, 그중 하나는 **대조군을 전부 통과한 채**였다

이 배치에서 가장 값진 것은 결과가 아니라 **매칭이 틀리는 네 방식**이다.

### 3-1. 「서비스 – 기능」이라는 가정 — 대조군 7개가 전부 통과하는데 **24건을 놓쳤다**

1차 매처는 lifecycle 행 이름이 `서비스 + en dash + 기능` 꼴이라고 가정하고
`행이름.startswith(서비스 + " - ")`로 셌다. 결과 **기능 단위 16건**. 대조군(서비스 양성 3 ·
표 존재 3 · 음성 1)은 **전부 통과했다** — 전부 **서비스 단위**였기 때문이다.

실제 표는 같은 표 안에서 **네 가지 형태**를 섞어 쓴다(전수 실측):

| 형태 | 예 |
|---|---|
| en dash 구분 | `AWS Systems Manager – Application Manager` |
| **구분자 없는 복합 이름** | `AWS Systems Manager Change Manager` · `Amazon Bedrock Agents Classic` · `AWS WAF Classic` |
| **서비스 이름이 뒤에 온다** | `Fleet Hub for AWS IoT Device Management` · `Governed Tables in AWS Lake Formation` |
| 정식명 + 괄호 약칭 | `Amazon Simple Notification Service (Amazon SNS) – Message Data Protection (MDP)` |

→ **경계 인식 포함 관계**로 바꾸고 **기능 단위 알려진 양성 7개**를 대조군에 넣었다. 그러자 **35행**이 나왔다.
⚠️ **대조군은 자기가 덮는 층만 보증한다.** 서비스 단위 양성만으로 「매칭이 된다」고 읽은 것이 결함이었다.

### 3-2. 변이형 집합의 순회 순서 — **서비스 단위가 기능 단위로 오분류**됐다

변이형을 하나씩 돌면서 `==`(서비스)와 `포함`(기능)을 **함께** 판정하자, `Amazon Q Business` 행이
접두사를 뗀 변이형 `q business`의 **포함**으로 먼저 걸려 **기능 단위로 분류**됐다(서비스 단위가 3 → 2).
집합 순회 순서에 따라 결과가 달라지는 상태였다.
→ **동등 비교를 전 변이형에 먼저** 돌리고, 그 뒤에만 포함을 본다.

### 3-3. 별칭에 길이 제한을 걸어 **`A2I`가 조용히 사라졌다** — G-07 그 자리

G-07이 「`Amazon Augmented AI`는 표에 `Amazon SageMaker AI – A2I`로 적혀 이름으로는 0건」이라고
적어 둬서 별칭 표에 `A2I`를 넣었는데, 파생 변이형에 쓰던 `len >= 4` 필터가 **별칭에도 적용돼**
`a2i`(3글자)가 걸러졌다. **G-07이 경고한 자리가 경고를 반영한 코드에서 다시 비켜 갔다.**
→ 필터는 **파생 변이형에만** 적용하고 **큐레이션한 별칭은 길이 제한 없이** 쓴다.

### 3-4. 접두사를 뗀 **한 낱말** 변이형 — `Amazon Connect`가 `AWS Direct Connect`에 걸렸다

경계 인식(`connect`가 `connector`에 안 걸린다)만으로는 막히지 않는다 — `Direct Connect`의
`Connect`는 **낱말 경계가 맞다**. 그리고 `AWS Direct Connect`는 **범위 외** 서비스다.
→ 접두사(`Amazon `·`AWS `)를 뗀 변이형은 **두 낱말 이상**일 때만 쓴다(`q business`·`systems manager`는
남고 `connect`·`bedrock`·`waf`는 빠진다 — 뒤의 셋은 접두사가 붙은 전체 이름으로 이미 걸린다).

## 4. ⚠️ 1차에서 문서를 받지 못한 7개 — 신호가 두 갈래다

| 범위 내 항목 | 내가 추정한 경로 | 결과 | 정체 |
|---|---|---|---|
| `Amazon Quick Sight` | `quicksight/latest/user/welcome.md` | **404 r=0** | ⚠️ `.md`가 없을 뿐 — `.html`은 **200 r=2**로 **`quick/latest/userguide/what-is.html`**에 도착한다(§6-1) |
| `Amazon Quick` | `quicksight/latest/user/amazon-quick-suite.md` | 404 r=0 | 정본은 **`quick/latest/userguide/what-is.md`**(200 r=0). `quicksuite/…`는 거기로 r=1 |
| `Amazon SageMaker Clarify` | `sagemaker/latest/dg/clarify-fairness-and-explainability.md` | 404 r=0 | **은퇴한 슬러그** — `.html`은 **200 r=1**로 가이드 인덱스(2,281B). 정본은 `clarify-availability-change.html`(§6-2) |
| `AWS Auto Scaling` | `autoscaling/plans/userguide/what-is-aws-auto-scaling.md` | 404 r=0 | **은퇴한 슬러그** — `.html`은 **200 r=1**로 `migrate-scaling-plan.html`(§6-5) |
| `AWS Well-Architected Tool` | `wellarchitected/latest/userguide/intro.md` | 404 r=0 | **은퇴한 슬러그**(레포 가드에 이미 등재돼 있다) — 현행 기본 페이지는 `well-architected.html`(§6-6) |
| `Kiro` | `kiro/latest/userguide/what-is.md` | 404 r=0 | **AWS docs에 가이드가 없다**(`.html`도 404, `docs.aws.amazon.com/kiro/`도 404). §6-4 |
| `Amazon Q Business Apps` | `amazonq/latest/qbusiness-ug/purpose-built-apps.md` | 404 r=0 | 그 가이드 **TOC에 `app`을 담은 항목이 0건**이다(54KB `toc-contents.json` 전수). §6-7 |

### ⚠️⚠️ 측정 신호를 두 가지 고쳤다

1. **`.md` 404는 「페이지 없음」이 아니다.** `quicksight/…/welcome.md`는 404인데 `.html`은 200이고
   본문이 16KB다. **`.md` 렌디션은 보편적이지 않다** — `.md`가 404면 **반드시 `.html`로 다시 잰다.**
   (`.md` 엔드포인트의 장점은 남아 있다: **있는 가이드의 없는 슬러그도 진짜 `404 r=0`**을 줘서
   `.html`의 「`200 r=1` → 인덱스」보다 읽기 쉽다. 두 신호를 함께 쓴다.)
2. **「`200`이고 2.5KB 이하면 측정이 공허」는 `r >= 1`일 때만 맞다.** `r=0`인 짧은 `.md`는
   **정상적으로 짧은 페이지**다 — 이번에 9편(`Athena` 1,520B · `EMR` 1,354B · `Lambda@Edge` 1,901B ·
   `CodePipeline` 1,175B · `SageMaker Model Registry` 1,817B · `SageMaker Unified Studio` 2,038B ·
   `Titan` 713B · `KMS` 2,388B · `S3 Intelligent-Tiering` 2,162B)을 전수로 열어 **전부 본문이 있는
   정상 페이지**임을 확인했다. SCS의 2.5KB 규칙을 `r=0`에 적용하면 멀쩡한 측정을 버린다.

⭐ 그리고 **인덱스로 튕긴 2.2~2.5KB 응답은 버릴 것이 아니라 오라클이다** — 그 HTML stub이
`myDefaultPage = "…"`로 **그 가이드의 현행 기본 페이지 이름을 알려 준다**(Well-Architected →
`well-architected.html`, SageMaker AI → `whatis.html`, AWS Auto Scaling → `what-is-a-scaling-plan.html`).

## 5. 범위 내 — 상태 변경 전수

### 5-1. 서비스 자체 (3개) — 이전 대상까지 확정했다

| 서비스 | 단계 | 공지 | 공식 문구(실측) | **공식이 권하는 대안** |
|---|---|---|---|---|
| **Amazon Kendra** | maintenance | 2026-06-30 | `Amazon Kendra is no longer open to new customers.` | ⭐ **Amazon Bedrock Knowledge Bases** |
| **Amazon Q Business** | maintenance | 2026-06-30 | `Amazon Q Business is no longer open to new customers.` | **Amazon Quick** |
| **AWS App Runner** | maintenance | 2026-03-31 | `AWS App Runner is no longer open to new customers. Existing customers can continue to use the service as normal. This guide applies only to existing customers.` | **Amazon ECS Express Mode** |

⚠️⚠️ **Kendra의 대안이 이 자격증의 RAG 축 그 자체다** — 공식이 「Kendra와 비슷한 기능은 Bedrock
Knowledge Bases를 보라」고 적고, `Amazon Bedrock Knowledge Bases`는 **범위 내 별 항목**이다.
`작업 1.4`·`1.5`(기술 11개)의 검색 소재를 Kendra로 쓰면 **공식이 권하지 않는 쪽을 가르친다.**

### 5-2. 기능·에디션 (35개 행 / 22개 서비스)

| lifecycle 행 | 단계 | 공지(→ 종료) | 범위 내 항목 | 공식 상태 페이지 |
|---|---|---|---|---|
| `AWS CloudTrail – Lake` | maintenance | March 31, 2026 | AWS CloudTrail | https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-lake-service-availability-change.html |
| `AWS DataSync Discovery` | full_shutdown | — | AWS DataSync | — |
| `AWS Glue – Ray jobs` | maintenance | March 31, 2026 | AWS Glue | https://docs.aws.amazon.com/glue/latest/dg/awsglue-ray-jobs-availability-change.html |
| `AWS Service Catalog – Application Registry` | maintenance | June 30, 2026 | AWS Service Catalog | https://docs.aws.amazon.com/servicecatalog/latest/arguide/app-registry-availability-change.html |
| `AWS Systems Manager Change Manager` | maintenance | November 7, 2025 | AWS Systems Manager | https://docs.aws.amazon.com/systems-manager/latest/userguide/change-manager-availability-change.html |
| `AWS Systems Manager Incident Manager` | maintenance | November 7, 2025 | AWS Systems Manager | https://docs.aws.amazon.com/incident-manager/latest/userguide/incident-manager-availability-change.html |
| `AWS Systems Manager – Application Manager` | maintenance | June 30, 2026 | AWS Systems Manager | https://docs.aws.amazon.com/systems-manager/latest/userguide/application-manager-availability-change.html |
| `AWS WAF Classic` | full_shutdown | — | AWS WAF | — |
| `Amazon Bedrock Agents Classic` | maintenance | June 30, 2026 | Amazon Bedrock | https://docs.aws.amazon.com/bedrock/latest/userguide/agents-classic-maintenance-mode.html |
| `Amazon CloudWatch Evidently` | full_shutdown | — | Amazon CloudWatch | — |
| `Amazon Cognito Sync` | maintenance | June 30, 2026 | Amazon Cognito | https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-sync-availability-change.html |
| `Amazon Comprehend – Topic Modeling, Event Detection, and Prompt Safety Classification` | maintenance | March 31, 2026 | Amazon Comprehend | https://docs.aws.amazon.com/comprehend/latest/dg/comprehend-availability-change.html |
| `Amazon Connect Customer Voice ID` | full_shutdown | — | Amazon Connect | — |
| `Amazon Kinesis Data Analytics for SQL` | full_shutdown | — | Amazon Kinesis | — |
| `Amazon Q Developer IDE plugins` | sunset | April 30, 2026 / April 30, 2027 | Amazon Q Developer | https://aws.amazon.com/blogs/devops/amazon-q-developer-end-of-support-announcement/ |
| `Amazon RDS Custom for Oracle` | sunset | March 31, 2026 / March 31, 2027 | Amazon RDS | https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/RDS-Custom-for-Oracle-end-of-support.html |
| `Amazon RDS on VMware` | full_shutdown | — | Amazon RDS | — |
| `Amazon Rekognition Person Pathing` | full_shutdown | — | Amazon Rekognition | — |
| `Amazon Rekognition – Streaming Events and Batch Image Content Moderation` | maintenance | March 31, 2026 | Amazon Rekognition | https://docs.aws.amazon.com/rekognition/latest/dg/rekognition-streaming-video-analysis-availability-change.html |
| `Amazon S3 Glacier Direct` | maintenance | October 7, 2025 | Amazon S3 | https://aws.amazon.com/solutions/guidance/data-transfer-from-amazon-s3-glacier-vaults-to-amazon-s3/ |
| `Amazon S3 Glacier Select` | maintenance | July 25, 2024 | Amazon S3 | https://aws.amazon.com/blogs/storage/how-to-optimize-querying-your-data-in-amazon-s3/ |
| `Amazon S3 Object Lambda` | maintenance | November 7, 2025 | Amazon S3 | https://docs.aws.amazon.com/AmazonS3/latest/userguide/amazons3-ol-change.html |
| `Amazon S3 Select` | maintenance | July 25, 2024 | Amazon S3 | https://aws.amazon.com/blogs/storage/how-to-optimize-querying-your-data-in-amazon-s3/ |
| `Amazon SageMaker AI – A2I` | maintenance | June 30, 2026 | Amazon Augmented AI · Amazon SageMaker AI | https://docs.aws.amazon.com/sagemaker/latest/dg/a2i-use-augmented-ai-a2i-human-review-loops.html |
| `Amazon SageMaker AI – Clarify` | maintenance | June 30, 2026 | Amazon SageMaker AI · Amazon SageMaker Clarify | https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-availability-change.html |
| `Amazon SageMaker AI – Debugger` | maintenance | June 30, 2026 | Amazon SageMaker AI | https://docs.aws.amazon.com/sagemaker/latest/dg/model-debugger-change.html |
| `Amazon SageMaker AI – GeoSpatial` | maintenance | June 30, 2026 | Amazon SageMaker AI | https://docs.aws.amazon.com/sagemaker/latest/dg/geospatial.html |
| `Amazon SageMaker AI – Ground Truth Plus` | full_shutdown | — | Amazon SageMaker AI · Amazon SageMaker Ground Truth | — |
| `Amazon SageMaker AI – Ground Truth` | maintenance | June 30, 2026 | Amazon SageMaker AI · Amazon SageMaker Ground Truth | https://docs.aws.amazon.com/sagemaker/latest/dg/sms.html |
| `Amazon SageMaker AI – Model Monitor` | maintenance | June 30, 2026 | Amazon SageMaker AI · Amazon SageMaker Model Monitor | https://docs.aws.amazon.com/sagemaker/latest/dg/model-monitor-availability-change.html |
| `Amazon SageMaker AI – Profiler` | sunset | June 30, 2026 / June 30, 2027 | Amazon SageMaker AI | https://docs.aws.amazon.com/sagemaker/latest/dg/profiler-availability-change.html |
| `Amazon SageMaker AI – Role Manager` | maintenance | June 30, 2026 | Amazon SageMaker AI | https://docs.aws.amazon.com/sagemaker/latest/dg/role-manager-availability-change.html |
| `Amazon SageMaker AI – Studio Lab` | maintenance | June 30, 2026 | Amazon SageMaker AI | https://docs.aws.amazon.com/sagemaker/latest/dg/studio-lab-availability-change.html |
| `Amazon Simple Notification Service (Amazon SNS) – Message Data Protection (MDP)` | maintenance | March 31, 2026 | Amazon SNS | https://docs.aws.amazon.com/sns/latest/dg/sns-message-data-protection-availability-change.html |
| `Amazon Simple Notification Service – Email Subscriptions (China Regions)` | sunset | June 30, 2026 / June 30, 2027 | Amazon SNS | https://docs.aws.amazon.com/sns/latest/dg/sns-email-subscriptions-china-availability-change.html |

⚠️ `Amazon SageMaker AI`가 **9행**으로 가장 많고, 그중 `A2I`·`Clarify`·`Ground Truth`·`Model Monitor`는
**범위 내 목록이 각각 별 항목으로 드는 것**이다(= 그 넷은 「서비스처럼 출제될 수 있는데 닫혀 있다」).
`Ground Truth`는 **본체가 maintenance이고 `Ground Truth Plus`가 full shutdown**이라 둘을 섞으면 거짓이 된다.

## 6. ⚠️⚠️ 2차 표가 잡지 못한 6건 — 1차 탐침만이 본 것

### 6-1. ⚠️⚠️⚠️ `Amazon Quick Sight` 문서가 `AWS Quick`으로 통합됐고 **접두사까지 바뀌었다**

- `quicksight/latest/user/welcome.html` → **`quick/latest/userguide/what-is.html`**(200 **r=2**, 16KB)
- 그 페이지 제목은 **`What is AWS Quick?`**이고 기능을 이렇게 적는다(실측):
  **`AWS Quick Sight`**(시각화·BI) · **`AWS Quick Flows`** · **`AWS Quick Automate`** · …
- 즉 **공식 현행 명칭은 `Amazon Quick`이 아니라 `AWS Quick`이고, Quick Sight는 Quick의 기능**이다.

⚠️ 그런데 **공식 시험 가이드는 둘을 다른 카테고리의 별 항목으로 든다**(`Amazon Quick Sight` = 분석 /
`Amazon Quick` = 기계 학습). **G-10이 열어 둔 물음에 대한 측정 답**이고, 저작 규율은 아래와 같다:

- 학습문서·문항에서 **포함 관계를 사실로 쓰지 않는다**(가이드와 문서가 다르게 말한다).
- **개수를 묻지 않는다**(「범위 내 분석 서비스는 몇 개」류).
- 이름은 **가이드 표기**(`Amazon Quick Sight`)를 쓰고, 공식 문서 인용이 필요한 자리에서만
  **문서 표기**(`AWS Quick Sight`)를 그대로 옮긴다 — SCS D-11(자격증별 표기)과 같은 규율이다.

### 6-2. `Amazon SageMaker Clarify`도 **신규 고객에게 열려 있지 않다**

`sagemaker/latest/dg/clarify-availability-change.html`(200 r=0, 11.6KB) 실측:

> `Amazon SageMaker Clarify is no longer open to new customers. Existing customers can continue to use
> the service as normal. AWS continues to invest in security and availability improvements for Clarify,
> but we do not plan to introduce new features.`

같은 페이지가 대안을 **「AWS가 공개한 오픈소스 모니터링 솔루션 + 표준 편향 지표 + SHAP 라이브러리 +
Amazon Bedrock Evaluations」의 조합**으로 적는다. ⚠️ **MLA-C01이 이 서비스로 문항을 많이 쓴다** —
이 자격증에서는 **D-07대로 가르치는 층에 상태를 병기**하고, 공정성·설명가능성 소재는
**Bedrock Evaluations 쪽**을 기본 축으로 둔다.

### 6-3. `Amazon Q Developer`는 **콘솔 쪽이 개명**됐고 IDE 플러그인은 2027-04-30 지원 종료다

`amazonq/latest/qdeveloper-ug/what-is.html` 실측 두 문장:

> `On April 30, 2027, AWS will discontinue support for Amazon Q Developer IDE plugins. For capabilities
> similar to Amazon Q Developer IDE plugins, explore Kiro…`
> **`Amazon Q Developer in the AWS Management Console is now the AWS assistant`**

즉 **IDE 플러그인 = sunset(대안 Kiro)** · **콘솔의 Q Developer = `AWS assistant`로 개명**이다.
⚠️ 범위 내 목록은 `Amazon Q Developer`와 `Kiro`를 **둘 다** 든다 — 둘의 관계를 모르고 쓰면
「대체된 쪽」을 정답으로 가르치게 된다.

### 6-4. `Kiro`는 AWS docs에 가이드가 없고, **공식이 `kiro.dev`를 가리킨다**

- `docs.aws.amazon.com/kiro/…` → **404 r=0**(`.md`·`.html` 양쪽) · `docs.aws.amazon.com/kiro/` → 404
- `aws.amazon.com/kiro/` → **404**
- `kiro.dev/docs/` → **200**

⭐ **AWS 공식 문서 자신이 그쪽을 정본으로 링크한다** —
`amazonq/latest/qdeveloper-ug/q-developer-ide-end-of-support.html`(200 r=0)의 본문이
`Migrating from Amazon Q Developer to Kiro`를 **`https://kiro.dev/docs/upgrade-guides/migrating-from-q-developer/`**로
건다. 그 페이지에 있는 **유일한 외부 링크**다.

→ 저작 처리: `Kiro`를 소재로 쓸 때 **출처는 AWS docs의 그 EOS 페이지**를 쓰고, 제품 세부가 필요하면
`kiro.dev`를 **공식이 가리키는 문서**로서 인용한다(레포 관례는 출처를 AWS 공식 문서로 두는 것이므로,
AWS docs가 그 URL을 직접 링크한다는 사실을 함께 적는다).

### 6-5. `AWS Auto Scaling`의 what-is 슬러그가 은퇴하고 **마이그레이션 안내로 리다이렉트**된다

`autoscaling/plans/userguide/what-is-aws-auto-scaling.html` → **`migrate-scaling-plan.html`**(200 r=1, 67KB).
그 페이지는 **「조정 계획(scaling plan)을 EC2 Auto Scaling·Application Auto Scaling 정책으로 옮기는 절차」**다.

⚠️ **그래도 「닫힌 서비스」가 아니다** — 그 문서에 `new customers`·`end of support`·`maintenance`가
**각 0건**이고, 가이드 현행 기본 페이지는 `what-is-a-scaling-plan.html`(200 r=0, 6.9KB)로 살아 있으며
lifecycle 세 표에도 **없다**. 측정된 사실은 **「추정 슬러그가 은퇴했고 공식이 정책 기반으로의 이전을
안내한다」**까지다. **상태 메모를 달지 않는다.**

### 6-6. `AWS Well-Architected Tool` — 진입 페이지가 바뀌고 **Agent는 프리뷰**다

`wellarchitected/latest/userguide/intro.html` → 가이드 인덱스(200 r=1, 2,459B)이고 현행 기본 페이지는
**`well-architected.html`**(200 r=0, `Last updated: October 1, 2026`)다. 첫 줄이
`AWS Well-Architected Agent is in preview release and is subject to change.`이고 본문이
**Tool과 Agent 두 가지**를 가른다 — **SCS D-17과 같은 판정이 이 자격증에서도 성립한다**(묻는 쪽은 Tool).

### 6-7. `Amazon Q Business Apps`는 그 가이드에 **독립 문서가 없다**

`amazonq/latest/qbusiness-ug/toc-contents.json`(200 r=0, 54.7KB) 전수에서 제목·경로에 `app`을 담은
항목이 **0건**이다. 범위 내 목록은 `Amazon Q Business`와 `Amazon Q Business Apps`를 **두 항목**으로
들지만 문서는 하나다. ⚠️ **둘을 다른 서비스처럼 묻지 않는다.**

### 6-8. 거짓 양성으로 판정한 것

| 자리 | 1차 신호 | 판정 |
|---|---|---|
| `Amazon OpenSearch Service` | `end of support` ×3 · `legacy` ×3 | **버전 지원 일정**이다(`End of Standard Support` 표와 `legacy Elasticsearch versions`). 서비스 상태가 아니다 |
| `AWS Glue` | `end of support` ×1 | 본문의 **Ray jobs EOS 링크**다(§5-2에 이미 있다) |
| `Amazon RDS` | `deprecated` ×2 · `Amazon SQS` `legacy` ×1 · `Amazon SageMaker AI` `legacy` ×2 | 기능·용어 설명이고 상태 공지가 아니다 |

## 7. 저작 처리 (D-07 적용)

1. **상태 메모는 가르치는 층에만** — `skill`·지문·정답 보기·`explanation`. 오답 보기·출처 제목에 달면
   「그 보기가 틀린 이유」처럼 읽혀 거짓이 된다(AIF Model Monitor · MLA Clarify · SCS Audit Manager에서
   세 번 확인된 판정).
2. **메모는 `explanation`에 둔다** — md에만 적으면 오답노트·모의고사 화면에서 보이지 않는다.
3. **가드 트리거는 기능으로 좁힌다** — `Amazon S3`·`Amazon Rekognition`·`Amazon Comprehend`처럼
   **본체는 정상이고 일부 기능만 닫힌** 서비스가 이번 표에 15개다. 서비스 이름을 트리거로 두면
   정상인 부분까지 닫힌 것으로 가르친다(SCS: `S3 Glacier 저장소 잠금`은 닫혔지만 스토리지 클래스는 정상).
4. **개수·포함 관계를 묻지 않는다** — `Amazon Quick`/`Quick Sight`(§6-1)와
   `Q Business`/`Q Business Apps`(§6-7)가 가이드와 문서에서 다르게 묶인다.
5. 날짜는 **공지일**이고 종료일이 아니다(sunset만 둘을 함께 적는다).

## 8. 측정하지 않은 것 (정직성)

- **범위 외 96개의 개별 상태 페이지** — 2차 표 대조만 했다(52행 / 42개 서비스가 걸린다. G-11 측정값 갱신).
  D-08대로 범위 외는 정답으로 쓰지 않으므로 더 재지 않았다.
- **35개 기능 행의 상태 페이지 본문** — `A2I`·`Clarify`·`Ground Truth`·`Model Monitor`·`Agents Classic`처럼
  **저작에서 쓸 다섯**은 읽었고, 나머지(`S3 Select`·`IoT`·`WorkSpaces` 계열 등)는 **URL만** 확정했다.
  그 기능을 소재로 쓰는 배치가 그때 읽는다.
- **`kiro.dev` 본문** — 링크의 실재(200)만 확인했다. 제품 세부를 쓰는 배치가 읽는다.
- lifecycle 세 표에 **어느 목록에도 안 걸린 44행**은 이 자격증의 범위 밖이라 보지 않았다.

## 9. 재현

```sh
# 1) 공식 범위 목록·lifecycle 세 표 (전부 200 r=0)
curl -sL -o in_scope.md  https://docs.aws.amazon.com/ko_kr/aws-certification/latest/ai-professional-01/aip-01-in-scope-services.md
curl -sL -o lc_maint.md  https://docs.aws.amazon.com/general/latest/gr/maintenance_services.md
# 2) 서비스별 문서 — `.md`가 404면 `.html`로 다시 잰다(§4)
curl -sL -o /dev/null -w '%{http_code} r=%{num_redirects} %{size_download} %{url_effective}\n' \
  https://docs.aws.amazon.com/kendra/latest/dg/what-is-kendra.md
```

⚠️ 매칭은 **Python으로** 한다 — 이 환경의 `grep -iF`는 en dash가 든 파일에서 **SIGABRT로 죽고**(rc=134)
루프 안에서는 그것이 「0건」처럼 보인다(SCS 3-2). `grep -c`는 0건에서 **exit 1**이다(SCS 3-3).

## 10. 출처

| 제목 | URL | 조회일 |
|---|---|---|
| 범위 내 AWS 서비스(ko_kr) | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/ai-professional-01/aip-01-in-scope-services.html | 2026-11-13 |
| 범위 외 AWS 서비스(ko_kr) | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/ai-professional-01/aip-01-out-of-scope-services.html | 2026-11-13 |
| AWS Lifecycle Changes — Maintenance | https://docs.aws.amazon.com/general/latest/gr/maintenance_services.html | 2026-11-13 |
| AWS Lifecycle Changes — Sunset | https://docs.aws.amazon.com/general/latest/gr/sunset_services.html | 2026-11-13 |
| AWS Lifecycle Changes — Full shutdown | https://docs.aws.amazon.com/general/latest/gr/full_shutdown_services.html | 2026-11-13 |
| Amazon Kendra 가용성 변경 | https://docs.aws.amazon.com/kendra/latest/dg/kendra-availability-change.html | 2026-11-13 |
| Amazon Q Business 가용성 변경 | https://docs.aws.amazon.com/amazonq/latest/qbusiness-ug/qbusiness-availability-change.html | 2026-11-13 |
| AWS App Runner 가용성 변경 | https://docs.aws.amazon.com/apprunner/latest/dg/apprunner-availability-change.html | 2026-11-13 |
| SageMaker Clarify 가용성 변경 | https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-availability-change.html | 2026-11-13 |
| What is AWS Quick?(= 구 QuickSight 사용자 안내서 도착지) | https://docs.aws.amazon.com/quick/latest/userguide/what-is.html | 2026-11-13 |
| What is Amazon Q Developer?(콘솔 개명 · IDE 플러그인 EOS) | https://docs.aws.amazon.com/amazonq/latest/qdeveloper-ug/what-is.html | 2026-11-13 |
| Amazon Q Developer IDE plugins end of support(→ `kiro.dev`) | https://docs.aws.amazon.com/amazonq/latest/qdeveloper-ug/q-developer-ide-end-of-support.html | 2026-11-13 |
| What is AWS Well-Architected?(Agent 프리뷰) | https://docs.aws.amazon.com/wellarchitected/latest/userguide/well-architected.html | 2026-11-13 |
| Migrate your scaling plan(구 what-is 슬러그 도착지) | https://docs.aws.amazon.com/autoscaling/plans/userguide/migrate-scaling-plan.html | 2026-11-13 |
| What is a scaling plan?(현행 기본 페이지) | https://docs.aws.amazon.com/autoscaling/plans/userguide/what-is-a-scaling-plan.html | 2026-11-13 |
| Kiro 문서(공식 EOS 페이지가 가리키는 정본) | https://kiro.dev/docs/upgrade-guides/migrating-from-q-developer/ | 2026-11-13 |
