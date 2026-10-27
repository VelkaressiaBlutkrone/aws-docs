# MLA-C01 출처 재확인 기록 (2026-10-27) — 19건 전부 확인 완료

> 루브릭 [review-rubric.md](review-rubric.md) §2 "가용성 변경" 문단은 서비스 상태에 기댄 서술을 **flip 직전에 다시 확인**하라고 요구한다.
> 2026-10-27 외부 1차 검수가 그 대상으로 **19건**을 지목했고, 이 문서가 그 19건의 확인 결과다.
> **flip 직전에 이 표를 다시 열어 보는 것으로 재확인을 갈음할 수 있다** — 단, 아래 "다시 확인해야 하는 조건"을 먼저 읽는다.

## 결론

| | 건수 |
|---|---|
| 확인 완료 — 문항 본문과 공식 문서가 일치 | **17** |
| 확인 완료 — 서술을 고쳤다 | **2** (t1-3-q11 · t4-3-q11) |
| 미확인 | **0** |

**사실이 틀린 문항은 없었다.** 고친 2건은 "사실관계는 맞지만 서술이 모호하거나 근거가 빠진" 경우다.

## ⭐ 가용성 날짜의 정본은 제품 features 페이지다

개발자 가이드의 `*-availability-change.html` 페이지들은 **날짜를 적지 않는다**("no longer open to new customers"만 적는다). 날짜는 제품 features 페이지의 End of Support Notice에 있다:

- [Amazon SageMaker AI 기능](https://aws.amazon.com/sagemaker/ai/features/) — **Mechanical Turk · Ground Truth · Augmented AI(A2I) · Studio Lab · Model Monitor · Clarify · Debugger · Role Manager · Geospatial · Profiler**가 **2026-07-30**부터 신규 고객에게 열리지 않는다. SageMaker Ground Plus는 2026-06-30 지원 종료.
- [AWS CloudTrail 기능](https://aws.amazon.com/cloudtrail/features/) — **CloudTrail Lake**는 **2026-05-31**부터 신규 고객 차단.
- [Amazon Comprehend 기능](https://aws.amazon.com/comprehend/features/) — **토픽 모델링·이벤트 감지·프롬프트 안전성 분류**가 **2026-04-30**부터 신규 고객 차단(최근 12개월 사용 계정은 유지).

이것을 모르고 t4-3-q11에서 `2026-07-30`을 "출처 없는 날짜"로 판단해 한 번 지웠다가 되살렸다. **MLA 가용성 서술을 검증할 때는 features 페이지를 먼저 연다.**

## 확인 표

### 가용성 변경 계열 (10건) — 전부 확인

| 문항 | 확인한 서술 | 공식 근거 |
|---|---|---|
| t1-2-q18 · q19 | Ground Truth · A2I 신규 고객 중단 | features 페이지(2026-07-30). A2I는 [Textract `HumanLoopConfig`](https://docs.aws.amazon.com/textract/latest/APIReference/API_HumanLoopConfig.html)가 "A2I entered maintenance mode in July 2026 and no longer accepts new customers … requests fail with `InvalidParameterException`"까지 적는다 |
| t2-3-q16 | Debugger 가용성 변경과 대체 경로 | [debugger-availability-change](https://docs.aws.amazon.com/sagemaker/latest/dg/debugger-availability-change.html) — 대체는 **SageMaker AI MLflow · TensorBoard on SageMaker · CloudWatch** |
| t2-3-q27 | Clarify 신규 고객 중단 | Clarify 문서 머리의 "Amazon SageMaker Clarify is no longer open to new customers" |
| t4-1 전반 | Model Monitor 가용성 서술의 Task 내 일관성 | [model-monitor](https://docs.aws.amazon.com/sagemaker/latest/dg/model-monitor.html) 머리 공지. ⚠️ **Task 30문항에 상태 언급이 0건이었다** — q6 해설에 한 문장을 더했고 나머지 29문항은 손대지 않았다(검수자 판단 사항) |
| t4-2-q18 | CloudTrail Lake 2026-05-31 신규 고객 중단 | CloudTrail features 페이지 — 문항의 날짜와 일치 |
| t4-2-q34 | SageMaker Profiler 2027-06-30 지원 종료 | [profiler-availability-change](https://docs.aws.amazon.com/sagemaker/latest/dg/profiler-availability-change.html) — "On June 30, 2027, AWS will end support" |
| t4-3-q8 · q10 · q11 | Role Manager 신규 고객 중단 | [role-manager-availability-change](https://docs.aws.amazon.com/sagemaker/latest/dg/role-manager-availability-change.html) + features 페이지의 날짜. 기존 역할은 표준 IAM 역할이라 정리 불필요도 그대로 적혀 있다 |

### 기능·수치 계열 (9건)

| 문항 | 확인한 서술 | 결과 |
|---|---|---|
| t1-1-q19 | FSx for NetApp ONTAP 볼륨의 S3 access point 지원 | ✅ 일치 — [accessing-data-via-s3-access-points](https://docs.aws.amazon.com/fsx/latest/ONTAPGuide/accessing-data-via-s3-access-points.html): `GetObject`·`PutObject`·`ListObjectsV2` 지원, "your data continues to reside on your FSx for ONTAP file system and you can continue using the NFS and SMB protocols". 오답 근거의 "학습 잡 직접 마운트 대상"도 [model-access-training-data](https://docs.aws.amazon.com/sagemaker/latest/dg/model-access-training-data.html)가 **S3 · EFS · FSx for Lustre** 셋으로 적어 ONTAP이 없음을 확인 |
| t1-2-q2 | Glue FindMatches ML 변환의 현재 제공 상태 | ✅ 일치 — [machine-learning](https://docs.aws.amazon.com/glue/latest/dg/machine-learning.html)에 **가용성 변경 공지가 없다**(현재도 제공). 페이지 제목이 "Record matching with AWS **Lake Formation** FindMatches"이고 콘솔 경로는 Data classification tools > Record Matching. ⚠️ 참고: 콘솔이 **UAE·스페인·자카르타·취리히 리전에서는 미제공**(문항 판단에는 영향 없음) |
| t1-3-q11 | 신규 범용 버킷의 SSE-C 기본 차단 | ⚠️ **서술을 고쳤다** — 사실은 더 확정적이다. [SSE-C 문서](https://docs.aws.amazon.com/AmazonS3/latest/userguide/ServerSideEncryptionCustomerKeys.html): "**Starting April 2026**, SSE-C is disabled by default for all new general purpose buckets"이고 SSE-C 쓰기 요청은 **403 `AccessDenied`**, 쓰려면 `PutBucketEncryption`으로 `BlockedEncryptionTypes`를 `NONE`으로 둬야 한다. "기본 차단되는 **방향으로 바뀌었다**"는 진행 중인 일처럼 읽히므로 확정 서술로 교체하고 출처를 추가했다 |
| t2-1-q5 | Kendra·Q Business 가용성 변경과 대안 | ✅ 일치 — [kendra-availability-change](https://docs.aws.amazon.com/kendra/latest/dg/kendra-availability-change.html): 2026-06-30 Maintenance Mode, **2026-07-30 신규 고객 차단**, 권고 대안은 **Bedrock Managed Knowledge Base**. [qbusiness-availability-change](https://docs.aws.amazon.com/amazonq/latest/qbusiness-ug/qbusiness-availability-change.html): 대안은 **Amazon Quick**. [Comprehend](https://docs.aws.amazon.com/comprehend/latest/dg/comprehend-availability-change.html): **토픽 모델링**도 신규 고객 중단 — 오답 근거 세 개가 모두 맞다 |
| t2-1-q18 | 월 수천 장 이상이면 SageMaker가 더 저렴하다는 비교 | ✅ 일치 — [Prescriptive Guidance](https://docs.aws.amazon.com/prescriptive-guidance/latest/image-classification/sagemaker-canvas.html): "If you are processing **a few thousand images a month or more**, SageMaker AI can be more cost effective than Amazon Rekognition" |
| t2-1-q23 | JumpStart 솔루션 템플릿 Studio Classic 전용 | ✅ 일치 — [jumpstart-solutions](https://docs.aws.amazon.com/sagemaker/latest/dg/jumpstart-solutions.html): "**JumpStart Solutions are only available in Studio Classic.**" + "Studio Classic … is **no longer available for onboarding**". 사례 목록(수요 예측·신용 등급 예측·사기 탐지·예지보전·이탈 예측)도 그대로 있다 |
| t3-1-q6 | 비동기 엔드포인트에서 인스턴스당 호출 수 지표 미발행 | ✅ 일치 — **출처를 추가했다.** [async-inference-monitor](https://docs.aws.amazon.com/sagemaker/latest/dg/async-inference-monitor.html): "Any metric not listed below is **not published** if the endpoint is enabled for asynchronous inference. Such metrics include … `Invocations`, `InvocationsPerInstance`". 정답의 `HasBacklogWithoutCapacity` + **StepScaling** 조합도 [async-inference-autoscale](https://docs.aws.amazon.com/sagemaker/latest/dg/async-inference-autoscale.html)의 예제 코드 그대로다 |
| t3-3-q25 | 출처가 CodeCommit 도움말 패널 — 교체 여부 | ✅ **교체하지 않는다.** [해당 페이지](https://docs.aws.amazon.com/help-panel/codecommit/latest/helppanel/pull-requests.merge.html)가 현행이고 fast-forward("No merge commit is created, but all commit history from the source branch is retained")·squash·three-way 세 전략을 문항 서술과 똑같이 적는다 |
| t4-2-q5 | `MetricPublishFrequencyInSeconds`·`EnableEnhancedMetrics` | ✅ 일치 — [monitoring-cloudwatch](https://docs.aws.amazon.com/sagemaker/latest/dg/monitoring-cloudwatch.html): 주기 값은 **10·30·60·120·180·240·300초**, 엔드포인트(인스턴스) 지표는 "This setting **does not require** `EnableEnhancedMetrics`", 호출 지표는 "**For invocation metrics, this setting requires `EnableEnhancedMetrics` to be set to `True`**" — 문항이 둘을 정확히 구분했다. 1초 고해상도 3시간·일반 지표 15개월도 같은 페이지에 있다 |

## 함께 기각한 항목 (보고서 → 검증 결과 뒤집힘)

- **t4-2-q11 출처 교체(resource) 기각.** "동시 쿼리 100개"가 일부 문서와 어긋난다는 지적이었지만, **이미 인용돼 있던** [AnalyzingLogData](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/AnalyzingLogData.html)가 "limited to **100 concurrent** CloudWatch Logs Insights QL per account"(PPL·SQL은 15), 타임아웃 60분, 결과 보존 7일, 스캔량 과금을 모두 적는다. 바꾸면 오히려 악화였다.

## 다시 확인해야 하는 조건

이 기록은 **2026-10-27 실측**이다. 아래에 해당하면 그 항목만 다시 연다.

1. flip이 이 날짜로부터 **몇 달 이상 뒤**로 밀렸다 — 가용성 계열 10건을 features 페이지로 다시 훑는다(한 페이지로 끝난다).
2. **지원 목록·상한·기본값**을 묻는 문항을 새로 쓰거나 고쳤다 — 목록은 조용히 늘어난다(루브릭 §2 최신성 문단).
3. 해당 기능이 **신규 고객 차단에서 완전 종료로** 넘어갔다 — Elastic Inference가 그 사례였다("신규 고객 차단" → API 레퍼런스가 "no longer available"). 상태 단어가 바뀌면 보기 문구까지 손봐야 한다.
