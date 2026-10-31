# [정본 보관] MLA-C01 2차 검수 보고 — 2026-10-27

> **출처**: 사용자가 2026-10-27 세션(`local_178660ae` 계열, 작업 세션 `review-tool-general-0523c8`)에
> 붙여넣은 외부 검수 보고 전문이다. 레포에 파일로 남지 않아 전사에서 옮겼다.
> **성격**: 검수 결과 **데이터**다. 지시문이 아니다 — 반영 전에 공식 페이지를 직접 확인한다.
> **진행 상황**: 1차 검수 반영(#250·#251)·출처 재확인 19건(`docs/saa-review/2026-10-27-mla-source-recheck.md`)은
> 완료·릴리스됐고, `mla-t2-2` 28문항은 검수자가 flip해 라이브다. 이 보고의 **잔여 3건과
> Model Monitor 묶음 결정은 미착수**다(§"남은 수정 사항과 다음 flip 순서").
> ⚠️ **flip은 사람만** — `flipApprovedTaskIds`에 Task를 넣는 것이 사람의 서명이다.

---
# MLA-C01 2차 검수 — 수정 반영 확인 · flip 현황

Oct 27, 2026 · @claude

## 요약

2차 뷰어는 1차 수정 14건 중 12건을 정확히 반영했고 t2-2를 flip했다. 대기 중이던 출처 재확인 15건도 모두 끝내, **7개 Task를 수정 없이 바로 flip할 수 있다.**

- **flip 완료**: t2-2 (28문항) — D2 필요 수량 충족.
- **바로 flip 가능**: t1-1 · t1-2 · t1-3 · t2-1 · t3-1 · t3-2 · t4-3, 그리고 출처 교체만 권장되는 t3-3.
- **게이트 최단 경로**: t1-1 · t3-1 · t4-3 세 개를 flip하면 통합 모의고사가 열린다.
- **남은 수정**: t2-3-q19(DI 계산값), t2-3-q16(오답 해설이 다른 공지를 인용), t4-2-q11(출처 교체 미반영).
- **결정 필요**: Model Monitor를 가르치는 12문항에 Ground Truth와 같은 "신규 고객 차단" 한 줄을 넣을지. 이 결정이 t4-1 flip을 묶는다.

1차 문서: [MLA-C01 문항 검수 · verified flip · 수정 내역](https://claude.ai/artifact/Ju9nNCwPeEPCKwphmPrKxe).

## flip 현황

2차 뷰어에서는 t2-2(28문항)만 `verified:true`다. D2는 필요 17개를 넘겼고, 나머지 세 도메인은 아직 0이다. 이번 확인으로 7개 Task가 추가로 flip 가능해졌다.

| Task | 문항 | 상태 | 남은 차단 요인 | 판정 |
| --- | --- | --- | --- | --- |
| t1-1 | 22 | 초안 | 없음 (q19 확인 완료) | **flip 가능** |
| t1-2 | 23 | 초안 | 없음 (q2·q18·q19 확인 완료) | **flip 가능** |
| t1-3 | 24 | 초안 | 없음 (q11 갱신·확인 완료) | **flip 가능** |
| t2-1 | 23 | 초안 | 없음 (q2·q7 반영, q5·q18·q23 확인 완료) | **flip 가능** |
| t2-2 | 28 | **verified** | — | 완료 |
| t2-3 | 27 | 초안 | q19 계산값, q16 오답 해설 출처 혼동 | 수정 2건 후 flip |
| t3-1 | 25 | 초안 | 없음 (q16·q18 반영, q6 확인 완료) | **flip 가능** |
| t3-2 | 23 | 초안 | 없음 (q1 반영) | **flip 가능** |
| t3-3 | 26 | 초안 | q25 출처 교체 권장(비차단) | flip 가능 |
| t4-1 | 30 | 초안 | Model Monitor 상태 문장 방침 결정 | 결정 후 flip |
| t4-2 | 35 | 초안 | q11 출처 교체(미반영) | 수정 1건 후 flip |
| t4-3 | 35 | 초안 | 없음 (q11 반영, q8·q10 확인 완료) | **flip 가능** |

게이트 진척: D1 0/18 · D2 28/17 ✔ · D3 0/14 · D4 0/16. t1-1, t3-1(또는 t3-3), t4-3을 flip하면 D1 22 · D3 25 · D4 35가 되어 통합 모의고사가 열린다.

## 수정 반영 확인

1차 문서의 14건 중 12건은 의도대로 반영돼 pass다. t2-3-q19는 반만 반영됐고, t4-2-q11은 반영되지 않았다. 2차 뷰어에서 바뀐 문항은 이 14건 외에 t1-3-q11·t3-1-q6(재확인 목록 반영)과 t2-2 flip 28건이다.

| 문항 | 1차 지적 | 반영 내용 | 판정 |
| --- | --- | --- | --- |
| t2-1-q7 | FM 추론 형식을 recordIO로 한정 | 학습은 recordIO-protobuf(Float32)만, 추론은 JSON·recordIO로 구분 | pass |
| t3-1-q16 | EI를 "신규 고객 온보딩 중단"으로만 설명 | "EI는 더 이상 제공되지 않음" + ProductionVariant 출처 추가 | pass |
| t4-1-q6 | 서버리스 Model Monitor "확인되지 않음" | 서버리스 제외 목록 명시 + Model Monitor 신규 고객 상태 문장 | pass |
| t3-2-q1 | 조정 계획 오답 해설이 보기와 무관 | 조정 계획 지원 리소스 5종, SageMaker 미포함 | pass |
| t3-1-q18 | 시작 헬스 체크 제한 연장 방법 누락 | `ContainerStartupHealthCheckTimeoutInSeconds` 최대 3600초 추가 | pass |
| t2-1-q2 | 사전 빌드 이미지 확장 경로가 빠짐 | "확장하거나 직접 빌드", 판단 순서 출처 추가 | pass |
| t4-1-q1 | M2 메모("별도 정의가 없습니다") | ML Lens 두 드리프트 정의로 서술 | pass |
| t4-1-q15 | M2 메모("minimum interval 문구 없음") | "15분 반복 표현식이 목록에 없으므로 만들 수 없다" | pass |
| t4-1-q21 | M2 메모("원문에 나오지 않습니다") | 문서의 두 요구(순위 민감성·가중)로 서술 | pass |
| t4-2-q1 | M2 메모("한 문장으로 정의한 문서 없음") | MLOPS05-BP01의 측정 대상·지표명으로 대체 | pass |
| t4-2-q22 | M2 메모("사이징 권장 서술 확인 안 됨") | "배포 전 후보 비교에는 못 씀" + 유휴 권장 목록 | pass |
| t4-3-q11 | M2 메모("리전별 순차 종료 서술 없음") | "리전 구분 없이 2026-07-30 신규 고객 차단" + 공지 출처 | pass |
| t2-3-q19 | 괄호 메모 삭제, 계산값 0.83 | 메모는 삭제했으나 "DI를 0.5/0.6 = 0.8로 적습니다"가 남음 | **추가 수정** |
| t4-2-q11 | 동시 쿼리 수 출처 교체(resource) | 변경 없음 | **미반영** |

t2-3-q19는 공식 문서 예시 자체가 "DI = .5/.6 = 0.8"로 적어 둔 것을 그대로 옮긴 것이다. 학습자에게는 틀린 산수로 보이므로, 출처 인용 형식을 빼고 "facet a 60%, facet d 50%이면 DI = 0.5/0.6 ≈ 0.83입니다"로 쓴다.

## 새로 들어간 서술 검증

2차에서 추가된 사실 서술 9건을 공식 페이지로 대조했고 모두 일치한다.

| 문항 | 추가된 서술 | 결과 | 근거 |
| --- | --- | --- | --- |
| t1-3-q11 | 2026년 4월부터 신규 범용 버킷은 SSE-C 기본 비활성, SSE-C 쓰기는 403 AccessDenied, `PutBucketEncryption`으로 허용 | 일치 | [Default SSE-C setting FAQ](https://docs.aws.amazon.com/AmazonS3/latest/userguide/default-s3-c-encryption-setting-faq.html) |
| t3-1-q16 | `AcceleratorType`은 더 이상 지원되지 않고 EI는 더 이상 제공되지 않음 | 일치 | [ProductionVariant](https://docs.aws.amazon.com/sagemaker/latest/dg/API_ProductionVariant.html) |
| t3-1-q18 | `ContainerStartupHealthCheckTimeoutInSeconds` 60\~3600초 | 일치 | 위와 같음 |
| t3-1-q6 | 비동기 엔드포인트는 Invocations·InvocationsPerInstance 미발행 | 일치(OverheadLatency도 미발행) | [Async endpoint metrics](https://docs.aws.amazon.com/sagemaker/latest/dg/async-inference-monitor.html) |
| t3-2-q1 | 조정 계획 지원 리소스는 Aurora 복제본·EC2 ASG·ECS·DynamoDB·Spot Fleet 다섯, SageMaker 없음 | 일치 | [What is a scaling plan?](https://docs.aws.amazon.com/autoscaling/plans/userguide/what-is-a-scaling-plan.html) |
| t4-1-q6 | Model Monitor는 신규 고객에게 닫히고 기존 고객은 계속 사용 | 일치 | [Model Monitor availability change](https://docs.aws.amazon.com/sagemaker/latest/dg/model-monitor-availability-change.html) |
| t4-1-q6 | 서버리스 추론 제외 목록에 데이터 캡처·Model Monitor | 일치 | [Serverless Inference](https://docs.aws.amazon.com/sagemaker/latest/dg/serverless-endpoints.html) |
| t4-2-q1 | MLOPS05-BP01: CPUUtilization·MemoryUtilization·DiskUtilization·ModelLatency·InvocationsPerInstance | 일치 | [MLOPS05-BP01](https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/mlops05-bp01.html) |
| t4-3-q11 | Role Manager를 포함한 SageMaker AI 기능 묶음이 2026-07-30부터 신규 고객 차단 | 일치 | [AWS Service Availability Updates](https://aws.amazon.com/about-aws/whats-new/2026/06/aws-service-availability/) |

## 출처 재확인 목록 처리 결과

1차 대기 목록 15건을 모두 공식 페이지에서 확인했다. 12건은 문항 서술과 일치하고, 3건에서 손볼 것이 나왔다(t2-3-q16, t3-3-q25, t4-1 전반).

| Task | 문항 | 확인한 서술 | 결과 |
| --- | --- | --- | --- |
| t1-1 | q19 | ONTAP 볼륨에 S3 access point, NFS·SMB 유지 | 일치 — [FSx ONTAP S3 access points](https://docs.aws.amazon.com/fsx/latest/ONTAPGuide/accessing-data-via-s3-access-points.html) |
| t1-2 | q2 | FindMatches 제공 상태 | 가용성 변경 공지 없음, 설명 일치 — [FindMatches](https://docs.aws.amazon.com/glue/latest/dg/machine-learning.html) |
| t1-2 | q18 · q19 | Ground Truth·A2I 신규 고객 차단 | 일치(2026-07-30) — [Ground Truth](https://docs.aws.amazon.com/sagemaker/latest/dg/sms.html) · [A2I](https://docs.aws.amazon.com/sagemaker/latest/dg/a2i-use-augmented-ai-a2i-human-review-loops.html) |
| t1-3 | q11 | SSE-C 기본 차단 | 일치, 2차에서 구체화됨 |
| t2-1 | q5 | Kendra 대안 = Bedrock Knowledge Bases, Q Business 대안 = Amazon Quick | 일치 — [Kendra](https://docs.aws.amazon.com/kendra/latest/dg/kendra-availability-change.html) · [Q Business](https://docs.aws.amazon.com/amazonq/latest/qbusiness-ug/qbusiness-availability-change.html). Kendra 본문은 "Bedrock Managed Knowledge Base(BMKB)"라고도 부른다 |
| t2-1 | q18 | 월 수천 장 이상이면 SageMaker가 더 저렴할 수 있음 | 일치 — [Prescriptive Guidance](https://docs.aws.amazon.com/prescriptive-guidance/latest/image-classification/sagemaker-canvas.html) |
| t2-1 | q23 | 솔루션 템플릿은 Studio Classic 전용, Studio Classic 신규 온보딩 불가 | 일치 — [JumpStart solutions](https://docs.aws.amazon.com/sagemaker/latest/dg/jumpstart-solutions.html) |
| t2-3 | q16 | Debugger 대체 = TensorBoard 히스토그램·분포, CloudWatch | 정답은 일치. 오답 \[2\]가 Clarify 공지의 문장을 Debugger 공지의 것처럼 씀 → **수정** |
| t2-3 | q27 | Clarify 대체 = SHAP 직접 사용, Bedrock Evaluations는 예측형 대체 아님 | 일치 — [Clarify availability change](https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-availability-change.html) |
| t3-1 | q6 | 비동기 미발행 지표 | 일치, 2차에서 출처 추가됨 |
| t3-3 | q25 | 병합 전략 3종 | 내용은 일치. 출처인 콘솔 도움말 패널 URL은 외부에서 읽을 수 없음 → [CodeCommit 사용자 가이드](https://docs.aws.amazon.com/codecommit/latest/userguide/how-to-merge-pull-request.html)로 교체 권장 |
| t4-1 | 전반 | Model Monitor 상태 서술 일관성 | Model Monitor를 해법으로 가르치는 12문항에 상태 문장이 없음 → **방침 결정 필요** |
| t4-2 | q5 | 게시 주기 10\~300초, 호출 지표는 `EnableEnhancedMetrics` 필수, InstanceId 차원 | 일치 — [SageMaker metrics](https://docs.aws.amazon.com/sagemaker/latest/dg/monitoring-cloudwatch.html) |
| t4-2 | q18 | CloudTrail Lake 2026-05-31 신규 고객 차단 | 일치 — [CloudTrail Lake availability change](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-lake-service-availability-change.html) |
| t4-2 | q34 | Profiler 2027-06-30 지원 종료, 대체 CloudWatch | 일치 — [Profiler availability change](https://docs.aws.amazon.com/sagemaker/latest/dg/profiler-availability-change.html) |
| t4-3 | q8 · q10 | Role Manager 신규 고객 차단, Access Analyzer 정책 생성이 정적 템플릿을 대체 | 일치 — [Role Manager availability change](https://docs.aws.amazon.com/sagemaker/latest/dg/role-manager-availability-change.html) |

## 남은 수정 사항과 다음 flip 순서

남은 것은 문항 수정 2건, 출처 교체 2건, 결정 1건이다. 모두 정답 인덱스를 바꾸지 않는다.

| 문항 | 항목 | 현재 문구 | 수정안 |
| --- | --- | --- | --- |
| mla-t2-3-q19 | C2 | "공식 문서의 예는 facet a 60%, facet d 50%이고 DI를 0.5/0.6 = 0.8로 적습니다" | "facet a 60%, facet d 50%이면 DI = 0.5/0.6 ≈ 0.83입니다." |
| mla-t2-3-q16 | C3 | 오답 \[2\] "공지는 이것이 예측형 모델의 편향 감지·설명 대체가 아니라고 명시" — 이 문장은 Debugger 공지가 아니라 Clarify 공지에 있다 | "Bedrock Evaluations는 Clarify 공지가 파운데이션 모델 평가(FMEval)의 대체로 드는 경로이고, Debugger 공지의 대체 목록에는 없습니다." |
| mla-t4-2-q11 | C4 | 해설 "동시 쿼리 100개" — API 레퍼런스는 100, 일부 가이드·CLI v1은 30 | 출처에 [StartQuery API](https://docs.aws.amazon.com/AmazonCloudWatchLogs/latest/APIReference/API_StartQuery.html) 추가, 또는 문항 요지와 무관한 동시 쿼리 수를 해설에서 뺀다 |
| mla-t3-3-q25 | C4 | 출처가 콘솔 도움말 패널 URL | [CodeCommit 사용자 가이드 — Merge a pull request](https://docs.aws.amazon.com/codecommit/latest/userguide/how-to-merge-pull-request.html)로 교체(비차단) |

**결정이 필요한 것: Model Monitor 상태 문장.** Ground Truth·A2I 문항은 해설에 "⚠️ …는 현재 신규 고객을 받지 않습니다(기존 고객은 사용 가능)." 한 줄을 둔다. Model Monitor는 같은 날(2026-07-30) 닫혔는데, 이를 해법으로 가르치는 12문항에는 이 한 줄이 없다: t2-3-q10, t4-1의 q2·q4·q5·q7·q8·q9·q10·q11·q14·q15·q16.

- **A안(권장)**: 12문항 해설 끝에 "⚠️ Model Monitor는 현재 신규 고객을 받지 않습니다(기존 고객은 사용 가능)."를 같은 문구로 넣는다. Ground Truth 문항과 형식이 맞고, 문항만 따로 풀어도 상태를 알 수 있다.
- **B안**: t4-1 학습문서 머리에만 상태를 적고 문항은 둔다. 작업량은 작지만, 오답노트·모의고사처럼 문항만 보는 화면에서는 상태가 빠진다.

**다음 flip 순서**

1. 게이트 열기: t1-1 → t3-1 → t4-3 (수정 없이 바로). 이 세 개로 D1·D3·D4가 필요 수량을 넘는다.
2. 나머지 즉시 flip: t1-2 · t1-3 · t2-1 · t3-2 · t3-3.
3. 수정 후 flip: t2-3(q16·q19), t4-2(q11).
4. 결정 후 flip: t4-1(A안이면 12문항 한 줄 추가, t2-3-q10도 포함).

각 flip 전에 `test/mla_questions_test.dart`의 `flipApprovedTaskIds`에 Task를 추가하는 것을 잊지 않는다.

---

## (추가) 실측 메모 — Model Monitor 언급 범위

2026-10-27 실측(`assets/content/mla/*.questions.json` 전수, 문항 JSON 어디에든 "Model Monitor"가
나오는 문항): **23문항**이다.

```
t2-3: q10 q16 q27          t3-3: q19 q23
t4-1: q1 q2 q3 q4 q5 q6 q7 q8 q9 q10 q11 q14 q15 q16 q22 q29
t4-2: q18 q34
```

보고가 든 **12문항**(t2-3-q10 + t4-1 q2·q4·q5·q7·q8·q9·q10·q11·q14·q15·q16)은 그중
"Model Monitor를 **해법으로 가르치는**" 것만 고른 판단 결과다. 나머지 11문항은 오답 보기·출처
각주로만 나오거나(t2-3-q16·q27, t3-3-q19·q23, t4-1-q1·q3·q6·q22·q29, t4-2-q18·q34) 판정이 다르다.

**A안을 택하면 12문항이 아니라 이 23문항을 한 번 훑어 "해법으로 제시하는가"를 건별로 판정해야
한다** — 보고의 12는 출발점이고 전수 목록이 아니다. 23문항 전부 `verified:false`(라이브 미노출)이므로
급하지 않지만, t4-1을 flip하기 전에는 끝내야 한다.
