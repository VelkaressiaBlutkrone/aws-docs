# 2단 반박 검증 — V2 비용·전송 요금 — 2026-07

독립 검증자가 발견자 의심 항목의 오탐 여부를 AWS 공식 사실로 반박 검토. 판정 3값(REFUTED=발견이 오탐/원문이 맞음, CONFIRMED=발견이 정당/원문이 오류, UNCERTAIN). 각 항목 1회 판정.

## 조회 출처 (URL 목록)

- https://aws.amazon.com/about-aws/whats-new/2025/11/cost-explorer-18-month-forecasting-ai-powered-forecasts/ (Cost Explorer 18개월 예측 도입 공지, 2025-11)
- https://aws.amazon.com/blogs/aws-cloud-financial-management/introducing-18-month-forecasting-and-explainable-ai-insights-in-aws-cost-explorer/ (동 기능 상세)
- https://docs.aws.amazon.com/cost-management/latest/userguide/ce-what-is.html (CE 데이터 준비: 현재+과거 13개월 이력)
- https://aws.amazon.com/about-aws/whats-new/2022/04/aws-data-transfer-price-reduction-privatelink-transit-gateway-client-vpn-services/ (2022-04-01 TGW·PrivateLink·Client VPN 리전 내 교차 AZ 전송 무료화)
- https://aws.amazon.com/transit-gateway/pricing/ (TGW 처리요금 구조)
- https://aws.amazon.com/blogs/architecture/overview-of-data-transfer-costs-for-common-architectures/ (교차 AZ 과금·NAT 처리요금·Gateway Endpoint 무료)
- https://aws.amazon.com/vpc/pricing/ (교차 AZ $0.01/GB 방향당; 퍼블릭/EIP 동일)
- https://aws.amazon.com/s3/pricing/ (Intelligent-Tiering 128KB 미만 모니터링·자동화 요금 비대상, Frequent 고정)
- https://aws.amazon.com/s3/storage-classes/ (Intelligent-Tiering 소형 객체 처리)
- https://docs.aws.amazon.com/AmazonS3/latest/userguide/analytics-storage-class.html (Storage Class Analysis = S3 analytics, 버킷/프리픽스/태그 단위 별개 설정)
- https://aws.amazon.com/s3/storage-analytics-insights/ (Storage Class Analysis와 Storage Lens 별개 기능)
- https://docs.aws.amazon.com/awssupport/latest/user/cost-optimization-checks.html (Trusted Advisor 비용 최적화: 미활용 EBS 볼륨 점검)
- https://repost.aws/questions/QUSK0wffM5ThKE5jESeM2kLQ/... (같은 리전 EC2↔S3 전송 무료, NAT 경유해도 처리요금만)

## 판정

| ID | 판정 | 근거(3줄 이내) |
|---|---|---|
| DOC-CLF-308 + DOC-SAA-410 (CE 예측 18개월) | **REFUTED** | AWS가 2025-11 Cost Explorer 예측 기간을 12→**18개월**으로 확대 공지(과거 이력 준비 13개월은 그대로). 발견자 근거(공식 12개월)는 2025-11 이전 사실이라 현행 오탐. 원문 "향후 ~18개월 예측"은 현행 AWS 사실과 **일치** — 정정 불필요(오히려 12개월로 바꾸면 구식화). 발견자가 확신도 낮·Phase B로 회부한 판단이 옳았음. |
| DOC-SAA-401 (교차 AZ 프라이빗 IP "더 낮은 요율") | **CONFIRMED** | 리전 내 교차 AZ 전송은 프라이빗 IP·퍼블릭/EIP **모두 방향당 $0.01/GB 동일**. 프라이빗 IP의 요금 이점은 "같은 AZ 내"에서만(무료 vs 퍼블릭 과금) 성립하고 교차 AZ에는 요율 차 없음. 원문 §5 표 "(양방향, 더 낮은 요율)"은 오류 — 발견 정당. |
| DOC-SAA-402 (128KB 미만 모니터링 요금이 절감액 초과) | **CONFIRMED** | S3 공식: 128KB 미만 객체는 **모니터링·자동화 요금 비대상**이며 항상 Frequent Access 고정. 따라서 "소용량(128KB 미만) 객체 다수 버킷에서 모니터링 요금이 절감액 초과"는 성립 불가(그 객체엔 모니터링 요금 자체가 없음). 실 리스크는 "티어 미이동=절감 0". 발견 정당. |
| DOC-SAA-403 (Storage Class Analysis = Storage Lens 하위) | **CONFIRMED** | Storage Class Analysis는 **S3 analytics의 별개 기능**(버킷/프리픽스/태그 단위 개별 설정, 문서 URL analytics-storage-class.html). Storage Lens(조직 전체 집계 대시보드)와 독립 구성·독립 과금. 원문 §7이 Storage Lens 기능 목록에 넣은 것은 오분류 — 발견 정당. |
| DOC-SAA-408 (NAT 경유 same-region S3에 아웃바운드 가산) | **CONFIRMED** | 같은 리전 EC2↔S3 전송은 **경로 무관 무료**(NAT 경유 시 NAT↔S3 구간도 무료). 과금은 NAT 데이터 처리요금($0.045/GB)(+EC2↔NAT 교차 AZ 가능)뿐이고 "인터넷 아웃바운드 단가"는 붙지 않음. 원문 비교표·시나리오표의 "아웃바운드 요금 적용"은 오류 — 발견 정당(t4-1 §5와도 상호 불일치). |
| DOC-SAA-409 (TGW 교차 AZ $0.03/GB) | **CONFIRMED** | 2022-04-01부터 TGW·PrivateLink·Client VPN의 **리전 내 교차 AZ 전송 무료화**(리전 간·TGW 데이터 처리요금은 불변). 따라서 리전 내 TGW 트래픽은 처리 $0.02/GB만, 교차 AZ 전송 $0.01/GB 가산은 소멸. 원문 "$0.01+$0.02=$0.03/GB"는 2022-04 이후 구식 — 발견 정당. |
| DOC-SAA-404 (CE가 미연결 EBS 식별) | **CONFIRMED** | 미활용·미연결 EBS 볼륨의 리소스 단위 식별·권장은 **Trusted Advisor**(비용 최적화 점검)·Compute Optimizer·Cost Optimization Hub 담당. Cost Explorer는 비용 분석·시각화 도구로 특정 미연결 볼륨을 열거·식별하지 않음. 원문이 CE를 TA와 병기한 것은 과대 귀속 — 발견 정당(L). |

### 비고
- REFUTED 1건(교차 CLF-308·SAA-410 동일 오류로 1항목 처리)은 발견자 근거가 **2025-11 AWS 기능 확대**를 반영하지 못한 지식 컷오프 문제. 원문(18개월)은 현행 정확하므로 **정정하면 안 됨**(12개월 회귀는 구식화). 단 "과거 ~13개월" 표기는 두 판정 모두에서 여전히 정확.
- 나머지 6건 CONFIRMED는 모두 AWS 공식 요금·기능 문서로 원문 오류 확인. 그중 DOC-SAA-409는 2022-04 요금 개편 미반영(시점성), DOC-SAA-401/402/408는 요율·과금 구조 사실 오류, DOC-SAA-403은 기능 소속 오분류, DOC-SAA-404는 도구 역할 과대 귀속.
