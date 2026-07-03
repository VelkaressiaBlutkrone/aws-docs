# 2단 반박 검증 — V5 SNS·메시징·ELB — 2026-07

독립 검증자: 아래 발견 항목이 오탐(false positive)임을 적극적으로 반박 시도. 근거는 AWS 공식 문서·공지만. 판정 3값(REFUTED=오탐 확정 / CONFIRMED=진짜 오류 재확인 / UNCERTAIN). 각 항목 1회 판정.

## 조회 출처 (URL 목록)
- https://docs.aws.amazon.com/sns/latest/dg/sns-message-delivery-retries.html  (SNS 재시도 정책: 총 50회, 4단계)
- https://docs.aws.amazon.com/sns/latest/dg/sns-dead-letter-queues.html  (SNS 구독별 DLQ)
- https://docs.aws.amazon.com/sns/latest/dg/sns-configure-dead-letter-queue.html
- https://aws.amazon.com/blogs/compute/designing-durable-serverless-apps-with-dlqs-for-amazon-sns-amazon-sqs-aws-lambda/
- https://docs.aws.amazon.com/sns/latest/dg/sns-subscription-filter-policies.html  (구독 필터 정책)
- https://docs.aws.amazon.com/sns/latest/dg/sns-message-filtering.html  (속성 기반, 2017~)
- https://aws.amazon.com/about-aws/whats-new/2022/11/amazon-sns-payload-based-message-filtering/  (페이로드 기반, 2022-11)
- https://docs.aws.amazon.com/lambda/latest/dg/invocation-retries.html  (Lambda 비동기 재시도: 함수오류 2회, 스로틀/시스템오류 최대 6h)
- https://docs.aws.amazon.com/lambda/latest/dg/with-sns.html  (SNS→Lambda 비동기)
- https://docs.aws.amazon.com/lambda/latest/dg/durable-functions.html  (Lambda durable functions = "Durable Lambda" 공식 실재)
- https://aws.amazon.com/about-aws/whats-new/2025/12/lambda-durable-multi-step-applications-ai-workflows/  (2025-12 공지)
- https://docs.aws.amazon.com/lambda/latest/dg/durable-step-functions.html  (durable functions vs Step Functions — 별개)
- https://docs.aws.amazon.com/elasticloadbalancing/latest/network/load-balancer-listeners.html  (NLB 리스너 프로토콜: TCP·TLS·UDP·TCP_UDP·QUIC·TCP_QUIC)
- https://docs.aws.amazon.com/elasticloadbalancing/latest/network/application-load-balancer-target.html  (ALB를 NLB의 대상으로; alb 타입 대상그룹은 NLB 기능)
- https://aws.amazon.com/blogs/networking-and-content-delivery/application-load-balancer-type-target-group-for-network-load-balancer/
- https://docs.aws.amazon.com/elasticloadbalancing/latest/network/edit-target-group-attributes.html  (NLB stickiness.enabled 기본 false, type=source_ip)
- https://docs.aws.amazon.com/prescriptive-guidance/latest/load-balancer-stickiness/target-group-stickiness.html

## 판정

| ID | 판정 | 근거(3줄 이내) |
|----|------|----------------|
| DOC-CLF-301 | CONFIRMED | SNS는 프로토콜별 전달 재시도 정책(총 50회, 4단계: 무지연→최소지연→백오프→최대지연)과 구독별 DLQ(SQS)를 공식 지원. "저장·재시도 메커니즘 없이 전달"은 사실과 반대. 발견자 정정 근거가 옳음 → 진짜 오류. |
| DOC-SAA-101 | CONFIRMED | SNS 구독 필터 정책 실재: 속성 기반(FilterPolicyScope=MessageAttributes, 2017~)·페이로드 기반(MessageBody, 2022-11~). 정책 불일치 구독자에겐 전달 안 함(선별 전달). "조건 필터링 없이 전체 구독자 Push"는 오류 → 발견자 옳음. |
| DOC-SAA-102 | CONFIRMED | SNS→Lambda 비동기에서 동시성 한도(스로틀) 시 유실 지점은 Lambda 비동기 이벤트 큐(스로틀/시스템오류 지수백오프 최대 6h, 함수오류 2회 재시도)이며 SNS가 아님. "SNS가 제한 횟수 재시도 후 버림" 귀속은 부정확 → 발견자 핵심 지적 옳음. |
| DOC-SAA-104 | REFUTED | 발견자 핵심 질문("'Durable Lambda' 공식 명칭 실재하는가")의 답은 YES. AWS Lambda durable functions(통칭 Durable Lambda)는 2025-12 정식 출시된 실재 기능(공식 문서·공지 확인). 명칭 부재 전제가 틀렸으므로 오탐. (주: Step Functions와 durable functions는 별개 기능이라 문서의 병기 표현은 다소 느슨하나, 제시된 검증 질문 기준으론 오탐.) |
| DOC-SAA-105 | REFUTED | NLB 공식 리스너 프로토콜은 현재 TCP·TLS·UDP·TCP_UDP·**QUIC·TCP_QUIC**(공식 리스너 문서 verbatim). QUIC 리스너 정식 지원(QUIC v1). 발견자 근거("TCP·UDP·TCP_UDP·TLS 4종뿐")는 구식. 문서가 QUIC 포함한 것이 오히려 현행 정답 → 오탐. |
| DOC-SAA-106 | CONFIRMED | ALB 대상그룹 대상유형은 instance·ip·lambda뿐. "다른 ALB를 대상으로 등록"은 **NLB**의 alb-타입 대상그룹 기능(ALB→ALB 아님). 문서는 ALB 대상그룹 행에 "다른 ALB 등록 가능"이라 서술 → 오귀속. 발견자 옳음(그건 NLB 기능). |
| DOC-SAA-107 | CONFIRMED | 플로우 해시는 **개별 연결 1개 수명 내** 동일 대상 고정일 뿐, 재연결 시 동일 대상 보장(세션 고정)은 별개 opt-in(NLB stickiness.enabled 기본 false, type=source_ip). 문서가 플로우 해시를 "자연스러운 세션 고정"으로 서술한 것은 두 개념 혼동 → 발견자 핵심 지적 옳음(정밀도 결함). |
