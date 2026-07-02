# 2단 반박 검증 — V10 VPC·네트워크·WAF·SCP — 2026-07

검증자: 독립 검증 서브에이전트. 방식: 각 의심 항목을 "오탐이라 가정"하고 AWS 공식 문서로 적극 반박 시도.
반박 실패(= 의심이 사실) 시 CONFIRMED, 반박 성공(= 원문이 옳음) 시 REFUTED, 근거 불충분 시 UNCERTAIN.
대상 원문 5개 문서 전문 확인 + AWS 공식 문서 조회.

## 조회 출처 (URL 목록)

- AWS services that integrate with AWS PrivateLink — https://docs.aws.amazon.com/vpc/latest/privatelink/aws-services-privatelink-support.html
- Access an AWS service using an interface VPC endpoint (Prerequisites: private DNS) — https://docs.aws.amazon.com/vpc/latest/privatelink/vpce-interface.html
- Service control policies (SCPs) — https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps.html
- Using rule actions in AWS WAF (terminating/non-terminating) — https://docs.aws.amazon.com/waf/latest/developerguide/waf-rule-action.html
- Rate-based rule high-level settings (evaluation window) — https://docs.aws.amazon.com/waf/latest/developerguide/waf-rule-statement-type-rate-based-high-level-settings.html
- NAT gateway basics (bandwidth) — https://docs.aws.amazon.com/vpc/latest/userguide/nat-gateway-basics.html
- Resources you can protect / WAF CloudFront scope (us-east-1) — https://docs.aws.amazon.com/waf/latest/developerguide/how-aws-waf-works-resources.html · AWS: Denies access based on requested Region (global service NotAction) — https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_examples_aws_deny-requested-region.html · Control Tower Region deny — https://docs.aws.amazon.com/controltower/latest/controlreference/primary-region-deny-policy.html

## 판정

| ID | 판정 | 근거(3줄 이내) |
|---|---|---|
| DOC-SAA-006 + DOC-SOA-311 | **CONFIRMED** | PrivateLink 지원 목록에 `com.amazonaws.{region}.s3` **및** `com.amazonaws.{region}.dynamodb` 인터페이스 엔드포인트가 명시됨 — S3(2021~)·DynamoDB 모두 Interface Endpoint 지원. saa-t1-3(L180)·soa-t5-1(L179-180)의 "Interface=S3·DynamoDB 외" 진술은 오류. (Gateway가 S3·DDB 전용인 것은 맞으나 Interface가 그 둘을 배제한다는 부분이 틀림.) |
| DOC-SOA-308 | **CONFIRMED** | 공식 인터페이스 엔드포인트 사전조건: "To use private DNS, you must enable **DNS hostnames and DNS resolution** for your VPC" — enableDnsHostnames + enableDnsSupport **둘 다** 필요. soa-t5-1(L197)이 프라이빗 DNS/엔드포인트 요건을 enableDnsSupport 단독으로 축소한 것은 불완전(오류). |
| DOC-SOA-309 | **CONFIRMED** | NAT gateway basics: "supports 5 Gbps of bandwidth and automatically **scales up to 100 Gbps**." soa-t5-1(L149) "최대 수십 Gbps"는 구식·부정확(100Gbps는 '수십'이 아님). 참고: saa-t1-3(L132)은 이미 "최대 100 Gbps"로 정확 — 오류는 soa-t5-1에 국한. |
| DOC-SAA-005 | **CONFIRMED** | NAT gateway는 "created in a specific AZ and implemented with redundancy **in that zone**"; AZ 장애 시 타 AZ 인터넷 끊김 → AZ별 생성 권장. saa-t1-3(L132)의 "자동 고가용성" 표기는 단일 AZ 내 이중화를 다중 AZ HA로 오해하게 함(발견자 지적 타당). |
| DOC-SAA-001 | **CONFIRMED** | 공식: "SCPs don't affect **users or roles** in the management account" + "no effect on users or roles in the management account" — 관리 계정의 **모든** IAM 사용자·역할·루트가 예외. saa-t1-1(L207)이 예외를 "관리 계정의 루트"로 축소한 것은 부정확. (saa-t1-2 L124는 올바르게 서술.) |
| DOC-SAA-003 | **CONFIRMED** | 공식 리전 거부 SCP 예시는 `NotAction`으로 cloudfront·iam·organizations·route53·support 등 글로벌 서비스를 제외 — 이들은 단일 엔드포인트가 us-east-1에 있어 미제외 시 전부 거부됨. saa-t1-2(L140-156) 예시는 `Action:"*"` 하드 거부·NotAction 부재 → IAM/STS/CloudFront 차단(실무 결함). |
| DOC-SAA-007 | **CONFIRMED** | 공식: CloudFront용 WAF는 글로벌이나 "you must use the Region **US East (N. Virginia)**"에서 웹 ACL(CLOUDFRONT 스코프) 생성. saa-t1-4(L282) "us-east-1 제한 없음"은 오류 — 리전 제약이 실재함. |
| DOC-SAA-008 | **CONFIRMED** | 공식: "**Count** ... This is a **non-terminating action**. AWS WAF continues processing the remaining rules." Allow·Block만 terminating. saa-t1-4(L60,89,L99)의 "첫 매칭 규칙 액션 실행(Count 포함)"은 Count를 종결로 오인 → 오류. |
| DOC-SAA-009 | **CONFIRMED** | 공식 evaluation window: "Valid settings are **60(1분), 120(2분), 300(5분), 600(10분)**, default 300." saa-t1-4(L99) "5분 또는 1분"은 구식(2·10분 누락) → 오류. |
