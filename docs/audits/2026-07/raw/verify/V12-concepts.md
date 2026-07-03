# 2단 반박 검증 — V12 CLF 개념 + 잔여 — 2026-07

독립 검증자가 각 의심 항목의 오탐 여부를 AWS 공식 사실로 반박 시도한 결과.
판정 3값: REFUTED(발견자 오탐, 문서 정확) / CONFIRMED(발견자 정확, 문서 오류) / UNCERTAIN.

## 조회 출처 (URL 목록)

- Automatic instance recovery — https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-recover.html
- Status checks for Amazon EC2 instances — https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/monitoring-system-instance-status-check.html
- Amazon EC2 status checks now support reachability health of attached EBS volumes (2024-08) — https://aws.amazon.com/about-aws/whats-new/2024/08/amazon-ec2-status-checks-reachability-health-ebs-volume/
- DynamoDB global tables MRSC GA (2025-06) — https://aws.amazon.com/about-aws/whats-new/2025/06/amazon-dynamo-db-global-tables-multi-region-strong-consistency-generally-available/
- Build the highest resilience apps with MRSC (AWS Blog) — https://aws.amazon.com/blogs/aws/build-the-highest-resilience-apps-with-multi-region-strong-consistency-in-amazon-dynamodb-global-tables/
- IAM policy evaluation (same-account union) — https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_evaluation-logic_policy-eval-basics.html
- Identity-based vs resource-based policies (union) — https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_identity-vs-resource.html
- CLF-C02 In-Scope AWS Services (공식 부록) — https://docs.aws.amazon.com/aws-certification/latest/cloud-practitioner-02/clf-02-in-scope-services.html
- DynamoDB Pricing (스토리지 GB-월 과금) — https://aws.amazon.com/dynamodb/pricing/
- Keep an EBS root volume after EC2 terminates (DeleteOnTermination 기본 true) — https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/configure-root-volume-delete-on-termination.html
- EKS 공동 책임 모델(Auto Mode 백서, 노드 패치 배포=고객) — https://docs.aws.amazon.com/whitepapers/latest/security-overview-amazon-eks-auto-mode/aws-shared-security-responsibility-model.html
- S3 11 9s 공식 예시("once every 10,000 years") — AWS RRS 블로그/공식 durability 표현 (다수 출처 교차확인)

## 판정

| ID | 판정 | 근거(3줄 이내) |
|---|---|---|
| DOC-CLF-201 | CONFIRMED | DynamoDB는 온디맨드에서 요청이 0이어도 저장 데이터에 스토리지 요금(Standard $0.25/GB-월)을 과금하며, 테이블 크기를 월 내내 연속 측정한다. 문서 §3(line 117) "트래픽 없으면 비용 없음"은 자동 확장(용량)엔 맞지만 스토리지엔 틀린 일반화. 발견자 지적이 정확. |
| DOC-CLF-202 | CONFIRMED | 루트 EBS 볼륨은 기본 DeleteOnTermination=true라 인스턴스 종료 시 자동 삭제된다(비루트 볼륨만 false). 문서 §3(line 140)·함정2(line 198) "중지·종료해도 데이터 유지"는 중지엔 맞지만 종료 시 루트 볼륨엔 틀림. 발견자 정확. |
| DOC-CLF-203 | CONFIRMED | 공식 11 9s 예시는 "1,000만 개 저장 시 평균 1만 년에 1개 손실"로 **기간(1만 년) 조건이 필수**다. 문서 용어표(line 63) "1,000만 개 중 1개 미만 손실"은 기간을 누락해 확률 규모를 왜곡. 발견자 정확. |
| DOC-CLF-204 | CONFIRMED | 대수(수평) 증감은 scale out/in, 사양(수직) 변경은 scale up/down이라는 표준 용어. 문서 §1(line 85)이 "가상 서버를 늘리고(scale up) 줄일(scale down)"로 대수 증감에 up/down을 붙인 것은 오표기(out/in이 맞음). 발견자 정확. |
| DOC-CLF-304 | REFUTED | 공식 CLF-C02 In-Scope 부록의 해당 범주명은 **"Customer Enablement"**(AWS Support 소속)이지 발견자가 주장한 "Customer Engagement(고객 참여)"가 아니다. 검증 핵심질문("공식명이 Customer Engagement인가")은 거짓 → REFUTED. (문서의 "고객 지원" 라벨도 부정확하나, 발견자가 제시한 정답 자체가 틀렸으므로 이 지적은 오탐.) |
| DOC-CLF-306 | CONFIRMED | S3 Glacier 계열에는 밀리초 복원(Glacier Instant Retrieval) 클래스가 실재하고 Deep Archive는 12~48h로 클래스별 상이. 문서 용어표(t4-1 line 62, t3-4 유사)의 Glacier "복원에 수 분~수 시간" 일반화는 Instant Retrieval에 틀림. 발견자 정확. |
| DOC-SAA-201 | CONFIRMED | 공식 IAM 평가는 동일 계정에서 identity 또는 resource 정책 중 **하나만 Allow면 충분(union)**이고 명시적 Deny가 최우선이다. 문서 §5(line 178-186)의 "①BPA→②IAM→③버킷정책→④ACL 순차 관문(모두 통과)"은 평가 모델을 오도. (BPA 최우선·ACL 레거시는 맞음.) 발견자 정확. |
| DOC-SOA-007 | CONFIRMED | 현재 EC2 상태 확인은 3종 — System·Instance·**Attached EBS status check**(2024-08 추가, Nitro 한정)로, 제3검사는 "연결된 EBS(단일)" 검사다. 문서 §3(line 102) "(추가로 EBS·연결 상태 확인 등)"은 EBS·연결을 2개처럼 읽히게 하고 정식 명칭·개수를 흐림. 발견자 정확. |
| DOC-SOA-008 | REFUTED | 공식상 자동 복구 중 **CloudWatch action based recovery는 인스턴스 스토어 볼륨 장착 인스턴스도 선택 인스턴스 타입에서 지원하며 그때 인스턴스 스토어 데이터가 유실**된다(간소화 복구만 미지원). 문서(line 215-216)는 인스턴스 스토어가 항상 복구된다고 주장하지 않고 "인메모리·인스턴스 스토어 데이터 유실 가능"만 경고 → 이는 공식 서술과 일치. 발견자 근거(복구=EBS 전용만)는 간소화 복구에만 참인 과일반화 → 문서 정확, REFUTED. |
| DOC-SOA-109 | CONFIRMED | DynamoDB Global Tables 멀티 리전 강한 일관성(MRSC)은 re:Invent 2024 프리뷰 후 **2025-06 GA**(RPO 0, 동기 복제)로 실재하는 옵션이다. 문서 표(line 164) "최종 일관성" 단정은 MRSC 옵션을 누락. 발견자 정확. |
| DOC-CLF-001 | CONFIRMED | EKS/ECS on EC2는 컨트롤 플레인만 AWS 책임이고, 워커 노드 OS/AMI 패치 배포는 고객 책임(관리형 노드그룹도 패치 AMI 배포는 고객; EKS Auto Mode만 예외). 문서 §5(line 131-134)가 ECS·EKS를 "패치·운영을 AWS가 대신"하는 관리형 예시로 뭉뚱그린 것은 부정확. 발견자 정확. |

### 요약
- CONFIRMED 9 (201·202·203·204·306·SAA-201·SOA-007·SOA-109·CLF-001)
- REFUTED 2 (CLF-304 발견자 정답 오류=Customer Enablement / SOA-008 문서 서술 정확)
- UNCERTAIN 0
