# 2단 반박 검증 — V8 CloudWatch·ASG — 2026-07

## 조회 출처 (URL 목록)

- https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/AlarmThatSendsEmail.html (경보 작업 종류 — SNS/EC2/ASG/OpsItem·인시던트)
- https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/cloudwatch_concepts.html (고해상도 지표·경보 과금, 해상도 정의)
- https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-health-checks.html (상태 확인 시작·유예 기간)
- https://docs.aws.amazon.com/autoscaling/ec2/userguide/lifecycle-hooks.html (수명주기 훅 기본 1h·글로벌 48h)
- https://docs.aws.amazon.com/autoscaling/ec2/APIReference/API_CreateAutoScalingGroup.html (HealthCheckGracePeriod 기본값·DefaultInstanceWarmup)
- https://docs.aws.amazon.com/autoscaling/ec2/APIReference/API_PutLifecycleHook.html (HeartbeatTimeout 범위 30~7200s)
- https://docs.aws.amazon.com/elasticloadbalancing/latest/application/how-elastic-load-balancing-works.html (ALB 교차영역·전 대상 비정상 시 동작)

## 판정

| ID | 판정 | 근거(3줄 이내) |
|---|---|---|
| DOC-SOA-002 (H) | CONFIRMED | 공식 경보 작업 목록은 SNS·EC2 작업·EC2 Auto Scaling 작업·CloudWatch 조사·SSM OpsItem/인시던트뿐. EventBridge는 경보 작업 대상이 아니라 경보 상태 변경을 자동 발행받는 통합(EventBridge 규칙이 이벤트를 수신)이므로 문서의 "경보 작업 대상: EventBridge" 표기는 부정확. Lambda도 직접 작업 아님(SNS 경유)이라 발견자 지적대로 문서에 직접 작업 오분류가 존재. |
| DOC-SOA-003 (M) | CONFIRMED | 공식: 경보의 직접 SSM 작업은 "creating an OpsItem or incident in Systems Manager". 자동화(Automation) 런북 실행은 직접 경보 작업이 아님(EventBridge 등 간접 경유). 문서의 "SSM: OpsItem 생성·자동화 런북 실행"은 자동화 런북을 직접 작업으로 오기. |
| DOC-SOA-004 (L) | CONFIRMED | 공식: 고해상도 지표는 PutMetricData 호출당 과금이라 호출을 자주 하면 비용↑일 뿐 지표당 단가 인상은 명시 없음. 명시적 "higher charge"는 10/30초 고해상도 "경보"에 대한 것. 문서의 "고해상도 지표…추가 비용"은 지표 자체 단가 인상으로 읽혀 부정확(경보만 고가). |
| DOC-SOA-101 (M) | CONFIRMED | 공식(DefaultInstanceWarmup): 워밍업은 스케일링용 CloudWatch 지표 집계에서 신규 인스턴스를 유예할 뿐. 상태 확인 유예는 별도 HealthCheckGracePeriod가 담당. 문서의 워밍업이 "상태 확인 제외"까지 한다는 표기는 두 기능 혼동. |
| DOC-SOA-102 (L) | CONFIRMED | 공식 PutLifecycleHook HeartbeatTimeout: "range is from 30 to 7200 seconds, default 3600(1h)". 즉 훅 파라미터 최대는 2시간. 48h는 하트비트 기록으로 연장되는 글로벌 상한(48h 또는 100×하트비트 중 작은 값). 문서의 "최대 48시간"을 훅 대기 설정 상한처럼 서술한 것은 부정확. |
| DOC-SOA-103 (L) | CONFIRMED | 공식 CreateAutoScalingGroup: HealthCheckGracePeriod "Default: 0 seconds". API/CLI 기본은 0초이며 300초는 콘솔 생성 마법사 기본값. 문서의 "기본 300초"는 API 기준으로 틀림(콘솔 한정 값을 무조건적 기본으로 서술). |
| DOC-SOA-106 (M) | CONFIRMED | 공식(ALB): 교차영역 기본 활성 시 각 AZ 노드는 "모든 AZ의 정상 대상"으로 라우팅 → 특정 AZ 대상이 전부 비정상이어도 그 AZ 노드는 타 AZ 정상 대상으로 계속 서빙(트래픽 계속 수신). 문서의 "그 AZ 노드는 트래픽을 안 받음"은 교차영역 비활성 전제의 서술이라 ALB 기본과 불일치. |

<!-- 검증자 주: 7개 항목 모두 발견자 근거가 AWS 공식 문서로 재확인됨. 오탐 반박 시도했으나 반박 근거를 찾지 못함(전부 실제 부정확). DOC-SOA-004/106은 문서 표현이 "완전 오류"라기보다 "부정확/전제 누락"에 가까우나, 시험 학습문서 기준으로는 수정 대상이 맞음. -->
