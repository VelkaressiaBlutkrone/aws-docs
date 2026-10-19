---
cert: SOA-C03
doc: 97-guide-v11-diff
retrieved: 2026-10-17
from: "1.0 (2025-09-30)"
to: "1.1 (2026-06-01)"
---

# 97 — SOA-C03 공식 시험 가이드 v1.0 → v1.1 변경 전문

> 최우선 과제 산출물. **공식 Revisions 표(정본)** 를 출발점으로 삼고, v1.0 원문(공식 PDF의 Wayback 캡처)과 v1.1 현행 docs 페이지(EN/KO)를 **53개 Skill 전수 기계 비교**해 표에 나오지 않는 차이까지 확인했다. 표의 「원문 인용」은 URL 페이지와 기계 대조해 검증했다(조회일 2026-10-17).

## 0. 결론 요약

| 구분 | 건수 | 비고 |
|---|---|---|
| **공식 Revisions 표의 Skill 변경** | **10건** | 1.1.1 · 1.2.1 · 1.3.4 · 2.3.4 · 3.1.2 · 3.2.2 · 4.1.3 · 4.1.5 · 4.2.5 · 5.1.2. **감사 GUIDE-001의 「11건」은 오기** (공식 표는 10행) |
| 위 외 EN 문구가 서비스 이름 표기만 바뀐 Skill | 7건 | 1.1.2 · 1.1.5 · 1.3.2 · 1.3.5 · 2.1.2 · 4.1.1 · 4.2.2 (+ PDF 줄바꿈 아티팩트 1건 2.3.2는 변경 아님) |
| 위 외 KO 문구가 레포 JSON(v1.0)과 다른 Skill | 20건 | 서비스 짧은 이름·어순 정비. 의미 변화 없음 |
| **in-scope 서비스 추가** | **5건** (82 → 87) | Amazon Bedrock · AWS DevOps Agent · AWS Health Dashboard · Kiro · AWS Security Agent |
| **out-of-scope 목록에서 제거** | **6건** (57 → 52, 표에 없는 신규 1건 포함) | AppStream 2.0 · A2I · AppSync · Cloud Directory · Kendra · Q Developer. 단 AppStream 2.0은 새 이름으로 여전히 out-of-scope |
| 불변 | — | 도메인 5개(이름·비중 22/22/22/16/18) · Task 13개(제목) · Skill 53개(번호 체계, 신설·삭제·이동 0) · 시험 형식(65문항=50+15, 130분, 합격선 720) · 대상 응시자·범위 밖 직무 문구 |
| 발행 / 시험 반영 | 2026-06-01 발행 | 반영은 발행 최소 1개월 후 — 2026-10-17 현재는 v1.1 기준이라고 보는 것이 안전 |

한 줄 요약: **v1.1은 신규 Skill을 만든 개정이 아니라, 기존 Skill에 최신 서비스·DR 전략·멀티 계정 도구 같은 예시를 덧붙인 점진적 개정이다.** 학습 영향이 큰 변경은 1.1.1(AI 워크로드 모니터링) · 1.2.1/3.2.2(AWS DevOps Agent·Kiro) · 1.3.4(Amazon S3 Files) · 2.3.4(DR 전략 4종) · 4.1.3/4.1.5(Organizations/SCP/Identity Center/conformance packs) · 4.2.5(AWS Security Agent) · 5.1.2(엔드포인트·PrivateLink·피어링)이다.

## 1. 방법과 근거

| 역할 | 자료 | URL / 식별 | 신뢰 |
|---|---|---|---|
| 개정 정본 | docs 사이트 Revisions 페이지 (이력표 · Skill 변경표 · 범위 목록 변경) | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/soa-03-revisions.html | 1차(공식) |
| v1.1 현행 원문(EN) | docs 도메인 1~5 페이지 | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain1.html ~ `-domain5.html` | 1차(공식) |
| v1.1 현행 원문(KO) | ko_kr 도메인 1~5 페이지 | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain1.html ~ `-domain5.html` | 1차(공식) |
| v1.0 원문(EN) 기준선 | 공식 PDF 가이드의 Wayback 캡처 2025-12-01 (2025-09-10 캡처와 본문 동일) | https://web.archive.org/web/20251201150423id_/https://d1.awsstatic.com/onedam/marketing-channels/website/aws/en_US/certification/approved/pdfs/docs-cloudops-associate/AWS-Certified-CloudOps-Engineer-Associate_Exam-Guide.pdf | 공식 PDF의 `[3자-아카이브]` 사본 |
| v1.0 원문(KO) | 레포 `flutter_app/assets/exam_guides/SOA-C03.json` (감사 문서가 v1.0과 일치함을 확인) | 읽기 전용 | 레포 |
| 서비스 범위 목록 v1.1 | in-scope / out-of-scope 페이지 | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/soa-03-in-scope-services.html · `.../soa-03-out-of-scope-services.html` | 1차(공식) |
| 서비스 범위 목록 v1.0 | 위 PDF의 Appendix A | (PDF 캡처, 위와 동일) | 공식 PDF 사본 |

**기계 비교 결과**: 53 Skill 중 EN 문구가 정확히 같은 것 35건, 서비스 이름 표기만 다른 것 8건(그중 2.3.2는 PDF 줄바꿈 하이픈 아티팩트), 실질 변경 10건 = **공식 Revisions 표 10건과 정확히 일치**. 즉 **표 밖의 숨은 실질 변경은 없다**. 또한 Revisions 표의 v1.1 칸 문구는 현행 도메인 페이지(EN)의 문구와 글자 단위로 같다.

> ⚠️ **PDF 주의**: 공식 PDF(d1.awsstatic.com, 2026-10-17 현재 `Last-Modified: 2026-09-01`)는 **v1.0 문구 그대로**이며 푸터만 「Version 1.1」로 적혀 있다(2025-09-10 캡처부터 동일). docs 사이트의 v1.1(2026-06-01)과 무관한 PDF 자체 번호다. v1.0 기준선으로는 쓸 수 있으나 **현행 정본이 아니다**. 상세는 `00-overview.md` §5.2.

## 2. Skill 변경 10건 — 번호별 전/후

### 2.1 EN 전/후 (공식 Revisions 표 인용)

| Skill | 변경 유형 | v1.0 (원문 인용) | v1.1 (원문 인용) | URL | 조회일 |
|---|---|---|---|---|---|
| 1.1.1 | 문구 재구성 + **워크로드 범위 명시(서버리스·컴퓨팅·AI)** | "Configure AWS monitoring and logging by using AWS services" | "to configure monitoring and logging for workloads (for example, serverless, compute, AI)" | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/soa-03-revisions.html | 2026-10-17 |
| 1.2.1 | **예시 교체**: 삭제 = AWS User Notifications · auto scaling / 추가 = Kiro · AWS DevOps Agent | "CloudWatch, AWS User Notifications, AWS Lambda, AWS Systems Manager, CloudTrail, auto scaling" | "CloudWatch, Lambda, AWS Systems Manager, CloudTrail, Kiro, AWS DevOps Agent" | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/soa-03-revisions.html | 2026-10-17 |
| 1.3.4 | **예시 추가**: Amazon S3 Files | "Amazon Elastic File System [Amazon EFS], Amazon FSx" | "Amazon EFS, Amazon FSx, Amazon S3 Files" | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/soa-03-revisions.html | 2026-10-17 |
| 2.3.4 | **문구 확장**: 「DR 절차」 → 「DR 절차 및 모범 사례」 + **DR 전략 4종 예시** | "Follow disaster recovery procedures." | "pilot light, warm standby, active/active" | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/soa-03-revisions.html | 2026-10-17 |
| 3.1.2 | **재서술**: 「리소스 스택」 → 「AWS 리소스」, 서비스명 약칭화 (C02→C03 비교 페이지가 이 Skill을 C03 신규 항목으로 명시) | "Create and manage stacks of resources by using AWS CloudFormation" | "Create and manage AWS resources by using CloudFormation and the AWS CDK." | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/soa-03-revisions.html | 2026-10-17 |
| 3.2.2 | **예시 추가**: EventBridge · AWS DevOps Agent | "AWS Lambda, Amazon S3 Event Notifications" | "Lambda, S3 Event Notifications, EventBridge, AWS DevOps Agent" | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/soa-03-revisions.html | 2026-10-17 |
| 4.1.3 | **예시 추가**: AWS Organizations · SCP · IAM Identity Center | "Implement multi-account strategies securely." | "AWS Organizations, service control policies, IAM Identity Center" | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/soa-03-revisions.html | 2026-10-17 |
| 4.1.5 | **문구 확장**: 「지속적 모니터링」 추가 + 예시에 AWS Config conformance packs (「AWS Region」 → 「Region」) | "Enforce compliance requirements (for example, AWS Region and service selections)" | "Enforce compliance requirements and continuous monitoring" · "AWS Config conformance packs" | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/soa-03-revisions.html | 2026-10-17 |
| 4.2.5 | **예시 추가**: AWS Security Agent | "AWS Config, Amazon Inspector)." | "Amazon Inspector, AWS Security Agent" | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/soa-03-revisions.html | 2026-10-17 |
| 5.1.2 | **예시 추가**: VPC endpoints · AWS PrivateLink · VPC peering | "Configure private networking connectivity." | "VPC endpoints, AWS PrivateLink, VPC peering" | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/soa-03-revisions.html | 2026-10-17 |

### 2.2 KO 전/후 — `SOA-C03.json` 반영용 (공식 ko_kr 현행 문구)

아래 「v1.0 KO」는 레포 JSON의 현재 값, 「v1.1 KO」는 ko_kr 도메인 페이지 현행 문구다(스크립트 추출, 수정·재번역 없음).

| Skill | v1.0 KO (레포 SOA-C03.json 현재 값) | v1.1 KO (공식 ko_kr 페이지 현행) |
|---|---|---|
| 1.1.1 | AWS 서비스를 사용하여 AWS 모니터링 및 로깅 구성(예: Amazon CloudWatch, AWS CloudTrail, Amazon Managed Service for Prometheus) | AWS 서비스(예: Amazon CloudWatch, AWS CloudTrail, Amazon Managed Service for Prometheus)를 사용하여 워크로드(예: 서버리스, 컴퓨팅, AI)에 대한 모니터링 및 로깅 구성 |
| 1.2.1 | AWS 서비스 및 기능을 사용하여 성능 지표를 분석하고 문제 해결 전략 자동화(예: CloudWatch, AWS 사용자 알림, AWS Lambda, AWS Systems Manager, CloudTrail, 오토 스케일링) | AWS 서비스 및 기능을 사용하여 성능 지표를 분석하고 문제 해결 전략 자동화(예: CloudWatch, Lambda, AWS Systems Manager, CloudTrail, Kiro, AWS DevOps Agent) |
| 1.3.4 | 공유 스토리지 솔루션(예: Amazon Elastic File System(Amazon EFS), Amazon FSx)을 평가 및 선택하고 특정 사용 사례 및 요구 사항에 맞게 솔루션(예: EFS 수명 주기 정책) 최적화 | 공유 스토리지 솔루션(예: Amazon EFS, Amazon FSx, Amazon S3 Files)을 평가 및 선택하고 특정 사용 사례 및 요구 사항에 맞게 솔루션(예: EFS 수명 주기 정책) 최적화 |
| 2.3.4 | 재해 복구 절차 준수 | 재해 복구 절차 및 모범 사례(예: 백업 및 복원, 파일럿 라이트, 예열 대기 방식, 액티브/액티브) 준수 |
| 3.1.2 | AWS CloudFormation과 AWS Cloud Development Kit(AWS CDK)를 사용하여 리소스 스택을 만들고 관리 | CloudFormation 및 AWS CDK를 사용하여 AWS 리소스를 만들고 관리 |
| 3.2.2 | AWS 서비스 및 기능(예: AWS Lambda, Amazon S3 이벤트 알림)을 사용하여 이벤트 기반 자동화 구현 | AWS 서비스 및 기능(예: Lambda, S3 이벤트 알림, EventBridge, AWS DevOps Agent)을 사용하여 이벤트 기반 자동화 구현 |
| 4.1.3 | 다중 계정 전략을 안전하게 구현 | 다중 계정 전략을 안전하게 구현(예: AWS Organizations, 서비스 제어 정책, IAM Identity Center) |
| 4.1.5 | 규정 준수 요구 사항 적용(예: AWS 리전 및 서비스 선택) | 규정 준수 요구 사항 및 지속적인 모니터링 적용(예: 리전 및 서비스 선택, AWS Config 규정 준수 팩) |
| 4.2.5 | 보고서 구성 및 AWS 서비스의 조사 결과 발견된 문제 해결(AWS Security Hub, Amazon GuardDuty, AWS Config, Amazon Inspector) | 보고서를 구성하고 AWS 서비스(예: AWS Security Hub, Amazon GuardDuty, AWS Config, Amazon Inspector, AWS Security Agent)의 조사 결과 발견된 문제 해결 |
| 5.1.2 | 프라이빗 네트워킹 연결 구성 | 프라이빗 네트워킹 연결 구성(예: VPC 엔드포인트, AWS PrivateLink, VPC 피어링) |

### 2.3 변경별 해설 (학습 영향)

1. **1.1.1** — 「워크로드(서버리스·컴퓨팅·AI)」가 명시되어 **AI 워크로드(예: Amazon Bedrock)의 모니터링·로깅**이 출제 후보에 들어왔다. Bedrock은 이번 개정에서 in-scope에도 추가됐다(§4.1). 학습: Task 1.1 파일(`tasks/1-1.md`).
2. **1.2.1** — **AWS User Notifications와 auto scaling이 예시에서 빠졌다**(범위 목록에는 원래 없던 User Notifications). 대신 **Kiro와 AWS DevOps Agent**가 들어왔다. 「자동 교정」의 도구 목록이 전통 서비스(CloudWatch·Lambda·Systems Manager·CloudTrail)에 AI 에이전트 계열이 더해진 형태. 학습: `tasks/1-2.md`.
3. **1.3.4** — 공유 스토리지 선택 후보에 **Amazon S3 Files**(S3 버킷을 파일 시스템처럼 노출)가 추가. EFS·FSx 비교축에 S3 Files를 포함해야 한다. 학습: `tasks/1-3.md`.
4. **2.3.4** — DR 「절차」만 있던 Skill이 **백업·복원 / 파일럿 라이트 / 웜 스탠바이 / 액티브-액티브**를 명시. RTO·RPO·비용 트레이드오프로 전략을 고르는 문항이 가능. 학습: `tasks/2-3.md`.
5. **3.1.2** — 표현 변경이 주. 단 C02→C03 비교 페이지가 「CloudFormation·AWS CDK로 스택을 만들고 관리」를 C03 **추가** 내용으로 명시하므로 CDK(앱·스택·컨스트럭트·bootstrap)까지 범위로 본다. 학습: `tasks/3-1.md`.
6. **3.2.2** — 이벤트 기반 자동화의 예시에 **EventBridge**(규칙·대상)와 **AWS DevOps Agent**가 추가. 학습: `tasks/3-2.md`.
7. **4.1.3** — 다중 계정 전략의 구체 도구가 명시: **Organizations · SCP · IAM Identity Center**. 학습: `tasks/4-1.md`.
8. **4.1.5** — 「규정 준수 + **지속적 모니터링**」, 예시에 **AWS Config conformance packs**. 학습: `tasks/4-1.md`.
9. **4.2.5** — 결과(finding) 소스에 **AWS Security Agent** 추가. 학습: `tasks/4-2.md`.
10. **5.1.2** — 프라이빗 연결의 구체 예: **VPC 엔드포인트 · AWS PrivateLink · VPC 피어링**. 학습: `tasks/5-1.md`.

## 3. 표기만 달라진 Skill (공식 Revisions 표에는 없음)

배경: 시험은 읽기 부담을 줄이려 **서비스 공식 짧은 이름**을 쓴다(`00-overview.md` §5 #1). v1.1 문구가 그 정책에 맞게 정리되면서, 의미는 같으나 표기가 달라진 Skill이 표 밖에 있다.
- 시점 근거: 이 정책을 설명하는 「Mentions of AWS services on the exam」 페이지(그리고 「Comparison」·「Revisions」 페이지)는 v1.1 **이전**의 docs 메인 페이지 목차(Wayback 2026-05-02 캡처: Introduction · Target candidate description · Exam content · Content outline · Domain 1~5 · In-Scope · Out-of-Scope · Survey)에는 없고, 현행 목차에는 있다 → 정책 페이지는 v1.1 시점에 도입된 것으로 보인다 `[3자-아카이브]`. https://web.archive.org/web/20260502001827id_/https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03.html

### 3.1 EN (7건 + PDF 아티팩트 1건)

| Skill | v1.0 EN (공식 PDF, Wayback 2025-12-01) | v1.1 EN (docs 현행) | 성격 |
|---|---|---|---|
| 1.1.2 | Configure and manage the CloudWatch agent to collect metrics and logs from EC2 instances, Amazon ECS clusters, or Amazon Elastic Kubernetes Service (Amazon EKS) clusters. | Configure and manage the CloudWatch agent to collect metrics and logs from EC2 instances, Amazon ECS clusters, or Amazon EKS clusters. | 서비스 이름 표기만 변경 |
| 1.1.5 | Configure AWS services to send notifications to Amazon Simple Notification Service (Amazon SNS) and to invoke alarms that send notifications to Amazon SNS. | Configure AWS services to send notifications to Amazon SNS and to invoke alarms that send notifications to Amazon SNS. | 서비스 이름 표기만 변경 |
| 1.3.2 | Analyze Amazon Elastic Block Store (Amazon EBS) performance metrics, troubleshoot issues, and optimize volume types to improve performance and reduce cost. | Analyze Amazon EBS performance metrics, troubleshoot issues, and optimize volume types to improve performance and reduce cost. | 서비스 이름 표기만 변경 |
| 1.3.5 | Monitor Amazon RDS metrics (for example, Amazon RDS Performance Insights, CloudWatch alarms), and modify configurations to increase performance efficiency (for example, Performance Insights proactive recommendations, RDS Proxy). | Monitor Amazon RDS metrics (for example, Amazon RDS Performance Insights, CloudWatch alarms) and modify configurations to increase performance efficiency (for example, Performance Insights proactive recommendations, RDS Proxy). | 서비스 이름 표기만 변경 |
| 2.1.2 | Implement caching by using AWS services to enhance dynamic scalability (for example, CloudFront, Amazon ElastiCache). | Implement caching by using AWS services to enhance dynamic scalability (for example, Amazon CloudFront, Amazon ElastiCache). | 서비스 이름 표기만 변경 |
| 2.3.2 | Use various methods to restore databases (for example, point-in- time restore) to meet recovery time objective (RTO), recovery point objective (RPO), and cost requirements. | Use various methods to restore databases (for example, point-in-time restore) to meet recovery time objective (RTO), recovery point objective (RPO), and cost requirements. | PDF 줄바꿈 하이픈 아티팩트(실제 변경 아님) |
| 4.1.1 | Implement AWS Identity and Access Management (IAM) features (for example, password policies, multi-factor authentication [MFA], roles, federated identity, resource policies, policy conditions). | Implement IAM features (for example, password policies, multi-factor authentication [MFA], roles, federated identity, resource policies, policy conditions). | 서비스 이름 표기만 변경 |
| 4.2.2 | Implement, configure, and troubleshoot encryption at rest (for example, AWS Key Management Service [AWS KMS]). | Implement, configure, and troubleshoot encryption at rest (for example, AWS KMS). | 서비스 이름 표기만 변경 |

### 3.2 KO — 레포 JSON(v1.0 번역) vs 공식 v1.1 번역 20건

의미 변화는 없다(서비스 풀네임 → 짧은 이름, 「예:」 추가, 어순·종결어미 정비). **JSON 동기화 시 함께 반영하면 공식 ko_kr과 글자 단위로 일치**한다.

| Skill | v1.0 KO (레포 SOA-C03.json 현재 값) | v1.1 KO (공식 ko_kr 페이지 현행) |
|---|---|---|
| 1.1.2 | Amazon EC2 인스턴스, Amazon Elastic Container Service(Amazon ECS) 클러스터 또는 Amazon Elastic Kubernetes Service(Amazon EKS) 클러스터에서 지표와 로그를 수집하도록 CloudWatch 에이전트 구성 및 관리 | EC2 인스턴스, Amazon ECS 클러스터 또는 Amazon EKS 클러스터에서 지표와 로그를 수집하도록 CloudWatch 에이전트를 구성하고 관리합니다. |
| 1.1.5 | Amazon Simple Notification Service(Amazon SNS)에 알림을 보내고 Amazon SNS로 알림을 보내는 경보를 간접적으로 호출하도록 AWS 서비스 구성 | Amazon SNS에 알림을 보내고 Amazon SNS로 알림을 보내는 경보를 간접적으로 호출하도록 AWS 서비스 구성 |
| 1.3.2 | Amazon Elastic Block Store(Amazon EBS) 성능 지표를 분석하고, 문제를 해결하고, 볼륨 유형을 최적화하여 성능 개선 및 비용 절감 | Amazon EBS 성능 지표를 분석하고, 문제를 해결하고, 볼륨 유형을 최적화하여 성능 개선 및 비용 절감 |
| 1.3.3 | Amazon S3 성능 전략을 구현하고 최적화하여 데이터 전송, 스토리지 효율성 및 액세스 패턴 향상(예: AWS DataSync, S3 Transfer Acceleration, 멀티파트 업로드, S3 수명 주기 정책) | S3 성능 전략(예: AWS DataSync, S3 Transfer Acceleration, 멀티파트 업로드, S3 수명 주기 정책)을 구현하고 최적화하여 데이터 전송, 스토리지 효율성 및 액세스 패턴 향상 |
| 2.1.3 | AWS 관리형 데이터베이스(예: Amazon RDS, Amazon DynamoDB)에서 스케일링을 구성 및 관리 | AWS 관리형 데이터베이스(예: Amazon RDS, DynamoDB)에서 스케일링을 구성 및 관리 |
| 2.3.1 | AWS 서비스(예: AWS Backup)를 사용하여 AWS 리소스(예: Amazon EC2 인스턴스, RDS DB 인스턴스, Amazon Elastic Block Store(Amazon EBS) 볼륨, Amazon S3 버킷, DynamoDB 테이블)의 스냅샷 생성 및 백업 자동화 | AWS 서비스(예: AWS Backup)를 사용하여 AWS 리소스(예: EC2 인스턴스, RDS DB 인스턴스, EBS 볼륨, S3 버킷, DynamoDB 테이블)의 스냅샷 생성 및 백업 자동화 |
| 2.3.3 | 스토리지 서비스의 버전 관리 구현(예: Amazon S3, Amazon FSx) | 스토리지 서비스(예: Amazon S3, Amazon FSx)의 버전 관리 구현 |
| 3.1.1 | AMI와 컨테이너 이미지를 만들고 관리(예: Amazon EC2 Image Builder) | AMI와 컨테이너 이미지(예: EC2 Image Builder)를 만들고 관리 |
| 3.1.3 | 배포 문제 식별 및 해결(예: 서브넷 크기 조정 문제, CloudFormation 오류, 권한 문제) | 배포 문제(예: 서브넷 크기 조정 문제, CloudFormation 오류, 권한 문제) 식별 및 해결 |
| 3.1.4 | 여러 AWS 리전 및 계정에 걸쳐 리소스 프로비저닝 및 공유(예: AWS Resource Access Manager(AWS RAM), CloudFormation StackSets) | 여러 리전 및 계정에 걸쳐 리소스 프로비저닝 및 공유(예: AWS Resource Access Manager(AWS RAM), CloudFormation StackSets) |
| 3.1.6 | 타사 도구(예: Terraform, Git)를 사용하고 관리하여 리소스 배포 자동화 | 서드 파티 도구(예: Terraform, Git)를 사용하고 관리하여 리소스 배포 자동화 |
| 3.2.1 | AWS 서비스(예: AWS Systems Manager)를 사용하여 운영 프로세스 자동화 | AWS 서비스(예: Systems Manager)를 사용하여 운영 프로세스 자동화 |
| 4.1.1 | AWS Identity and Access Management(AWS IAM) 기능 구현(암호 정책, 다중 인증(MFA), 역할, 페더레이션 ID, 리소스 정책, 정책 조건) | IAM 기능 구현(예: 암호 정책, 다중 인증(MFA), 역할, ID 페더레이션, 리소스 정책, 정책 조건) |
| 4.1.2 | AWS 도구를 사용하여 액세스 문제 해결 및 감사(AWS CloudTrail, IAM Access Analyzer, IAM 정책 시뮬레이터) | AWS 도구(예: CloudTrail, IAM Access Analyzer, IAM 정책 시뮬레이터)를 사용하여 액세스 문제 해결 및 감사 |
| 4.2.2 | 저장 시 암호화 구현, 구성 및 문제 해결(AWS Key Management Service(AWS KMS)) | 저장 시 암호화 구현, 구성 및 문제 해결(예: AWS KMS) |
| 4.2.3 | 전송 중 암호화 구현, 구성 및 문제 해결(AWS Certificate Manager(ACM)) | 전송 중 암호화 구현, 구성 및 문제 해결(예: AWS Certificate Manager(ACM)) |
| 5.1.3 | 단일 계정의 감사 AWS 네트워크 보호 서비스(예: Amazon Route 53 Resolver DNS 방화벽, AWS WAF, AWS Shield, AWS Network Firewall) | 단일 계정의 감사 AWS 네트워크 보호 서비스(예: Route 53 Resolver DNS 방화벽, AWS WAF, AWS Shield, AWS Network Firewall) |
| 5.2.3 | 콘텐츠 및 서비스 배포 구성(예: Amazon CloudFront, AWS Global Accelerator) | 콘텐츠 및 서비스 배포 구성(예: CloudFront, AWS Global Accelerator). |
| 5.3.2 | 네트워킹 로그를 수집하고 해석하여 문제 해결(예: VPC 흐름 로그, Elastic Load Balancing(ELB) 액세스 로그, AWS WAF 웹 ACL 로그, CloudFront 로그, 컨테이너 로그) | 네트워킹 로그를 수집하고 해석하여 문제 해결(예: VPC 흐름 로그, ELB 액세스 로그, AWS WAF 웹 ACL 로그, CloudFront 로그, 컨테이너 로그) |
| 5.3.5 | Amazon CloudWatch 네트워크 모니터링 서비스 구성 및 분석 | CloudWatch 네트워크 모니터링 서비스 구성 및 분석 |

## 4. 서비스 범위 목록 변경

### 4.1 in-scope 추가 5건 (82 → 87) — 공식 제품 설명

| 서비스 | 카테고리 | 공식 설명 (원문 인용) | URL | 관련 Skill / 학습 파일 | 조회일 |
|---|---|---|---|---|---|
| Amazon Bedrock | Machine Learning and Artificial Intelligence | "is a fully managed service that offers a choice of industry leading foundation models" | https://aws.amazon.com/bedrock/faqs/ | 1.1.1 (AI 워크로드 모니터링) · `tasks/1-1.md` | 2026-10-17 |
| AWS DevOps Agent | Management and Governance | "AWS DevOps Agent is an AI-powered, always-available agent that spans release management and production operations" | https://docs.aws.amazon.com/devopsagent/latest/userguide/about-aws-devops-agent.html | 1.2.1 · 3.2.2 · `tasks/1-2.md` · `tasks/3-2.md` | 2026-10-17 |
| AWS Health Dashboard | Management and Governance | "You can use your AWS Health Dashboard to learn about AWS Health events." | https://docs.aws.amazon.com/health/latest/ug/getting-started-health-dashboard.html | 어떤 Skill 문구에도 직접 언급 없음 — 1.2 「가용성 지표」 맥락 · `tasks/1-2.md` | 2026-10-17 |
| Kiro | Developer Tools | "Kiro is an agentic development environment (IDE, CLI)" | https://aws.amazon.com/blogs/devops/amazon-q-developer-end-of-support-announcement/ | 1.2.1 · `tasks/1-2.md` | 2026-10-17 |
| AWS Security Agent | Security, Identity, and Compliance | "is a frontier agent that proactively secures your applications throughout the development lifecycle" | https://docs.aws.amazon.com/securityagent/latest/userguide/what-is.html | 4.2.5 · `tasks/4-2.md` | 2026-10-17 |

| # | 사실 | 원문 인용 | URL | 조회일 |
|---|---|---|---|---|
| 1 | 공식 Revisions 페이지는 위 5종을 「in-scope 목록에 추가된 서비스」로 명시한다. | "Services added to the in-scope list" | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/soa-03-revisions.html | 2026-10-17 |
| 2 | AWS DevOps Agent와 AWS Security Agent는 서로 다른, 상호 보완적 에이전트이다(릴리스 준비도·운영 조사 vs 위협 모델링·침투 테스트). | "AWS DevOps Agent and AWS Security Agent are different but complementary." | https://aws.amazon.com/devops-agent/faqs/ | 2026-10-17 |
| 3 | AWS Security Agent의 현행 문서 제목에는 「(now part of AWS Continuum)」이 병기된다 — 시험 문항이 어느 이름을 쓸지는 공식 확인 불가(`99-gaps.md`). | "AWS Security Agent (now part of AWS Continuum)" | https://docs.aws.amazon.com/securityagent/latest/userguide/what-is.html | 2026-10-17 |

- v1.0 PDF의 in-scope 목록과 v1.1 목록을 비교하면 **삭제·카테고리 이동은 0건**, 추가 5건뿐이다(82 → 87).

### 4.2 out-of-scope 제거 6건 (57 → 52)

| 서비스 | v1.0 카테고리 | 해석 메모 |
|---|---|---|
| Amazon AppStream 2.0 | End User Computing | **v1.1 목록에 「Amazon WorkSpaces applications」(End User Computing)가 새로 등장**(Revisions 표에는 없음). AppStream 2.0의 현행 제품명(문서 제목)으로 보이므로 「제거」가 아니라 **이름 교체 — 여전히 out-of-scope**로 취급한다. 명시적 개명 공지 문구는 직접 확인하지 못했다(`99-gaps.md`) |
| Amazon Q Developer | Developer Tools | 2026-05-15 신규 가입 중단 · **2027-04-30 IDE 플러그인·유료 구독 지원 종료**, 후속은 Kiro. 같은 개정에서 Kiro가 in-scope로 올라왔다 |
| AWS AppSync | Frontend Web and Mobile | 제거 사유 공식 미설명. in-scope에도 없음 |
| Amazon Augmented AI (Amazon A2I) | Machine Learning | 제거 사유 공식 미설명. in-scope에도 없음 |
| Amazon Kendra | Machine Learning | 제거 사유 공식 미설명. in-scope에도 없음 |
| Amazon Cloud Directory | Storage | 제거 사유 공식 미설명. in-scope에도 없음 |

| # | 사실 | 원문 인용 | URL | 조회일 |
|---|---|---|---|---|
| 1 | Revisions 페이지는 위 6종을 「out-of-scope 목록에서 제거된 서비스」로 명시한다. | "Services removed from the out-of-scope list" | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/soa-03-revisions.html | 2026-10-17 |
| 2 | v1.1 out-of-scope(End User Computing)에 「Amazon WorkSpaces applications」가 올라 있다. | "Amazon WorkSpaces applications" | https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/soa-03-out-of-scope-services.html | 2026-10-17 |
| 3 | AppStream 2.0 문서(경로 /appstream2/)의 현행 제목은 「What Is Amazon WorkSpaces Applications?」이다. | "Amazon WorkSpaces Applications is a fully managed application streaming service" | https://docs.aws.amazon.com/appstream2/latest/developerguide/what-is-appstream.html | 2026-10-17 |
| 4 | GovCloud 문서는 제목은 WorkSpaces Applications이고 본문은 아직 AppStream 2.0 표기여서 개명 정황을 보여준다. | "Amazon AppStream 2.0 is a fully managed application streaming service" | https://docs.aws.amazon.com/govcloud-us/latest/UserGuide/govcloud-appstream2.html | 2026-10-17 |
| 5 | Amazon Q Developer IDE 플러그인은 2027-04-30에 지원이 종료된다. | "On April 30, 2027, AWS will discontinue support for Amazon Q Developer IDE plugins." | https://docs.aws.amazon.com/amazonq/latest/qdeveloper-ug/doc-history.html | 2026-10-17 |

### 4.3 해석상 주의
- **「out-of-scope에서 제거」 ≠ 「in-scope 편입」**. 제거된 6종은 v1.1 in-scope 목록에도 없다. 두 목록은 모두 비망라적이므로(「This list is non-exhaustive」) 이 6종은 「더 이상 명시적으로 제외되지 않음」일 뿐 출제 여부는 불명이다.
- **AWS User Notifications**: v1.0의 Skill 1.2.1 예시였고 v1.1에서 삭제됐으며, v1.0·v1.1 어느 in-scope 목록에도 없다(PDF 부록·현행 페이지 비교). 다만 AWS Health 문서는 알림 채널로 이를 언급한다(「Manage AWS Health notifications in AWS User Notifications」). 시험 범위로는 보지 않되 실무 연결 지식으로 한 줄 언급하는 수준을 권장.
- **카테고리 이름**: out-of-scope 목록의 「Machine Learning」 카테고리가 v1.1에서 「Machine Learning and Artificial Intelligence」로 바뀜(내용 이동 없음).

## 5. 불변 확인 (v1.0 PDF vs v1.1 docs, 기계 비교)

| 항목 | 결과 |
|---|---|
| 도메인 5개 — 영문 이름 | 5/5 동일 |
| 도메인 비중 (22/22/22/16/18) | 동일 (`00-overview.md` §3) |
| Task 13개 — 영문 제목 | 13/13 동일 |
| Task 13개 — 한국어 제목 (레포 JSON vs 공식 v1.1) | 13/13 동일 |
| Skill 번호 체계 (53개) | 신설·삭제·이동 0건 |
| 시험 형식·채점·합격선 문구 | 동일 (소개/채점/목표 응시자 본문 문장 비교에서 의미 차이 0, 표기 1곳: ECS 풀네임 → Amazon ECS) |
| 범위 밖 직무 목록 | 동일 |
| SOA-C02 vs C03 비교 부록 | 동일 |

## 6. 시험 반영 시점
- 공식 규칙: 「published at least 1 month before changes are reflected on your exam」(Revisions 페이지). v1.1 발행 2026-06-01 → **시험 반영은 2026-07-01 이후**이며 정확한 날짜는 공식 페이지에 없다.
- 오늘(2026-10-17)은 발행 후 4.5개월 경과 — **v1.1 기준으로 준비하는 것이 안전하다.** v1.0 기준 자료(기존 학습문서의 근거, 서드파티 자료)는 위 10건 + 범위 목록 변경분이 비어 있다.

## 7. 레포 `SOA-C03.json` 동기화 체크리스트 (상세는 `99-gaps.md`)
1. §2.2 의 KO 문구 10건으로 `tasks[].skills[]` 교체 (필수 — 의미가 달라진 변경).
2. §3.2 의 KO 20건 반영 (선택 — 공식 ko_kr과 글자 일치시키려면).
3. 메타 필드 추가 제안: 가이드 버전(1.1)·발행일(2026-06-01)·표시명(AWS Certified CloudOps Engineer - Associate). 현재 JSON에는 해당 필드가 없다.
4. `overview`(720 / 50 / 15 / 130)·도메인·비중·Task 제목은 **수정 불필요**.
5. 변경 후 JSON을 읽는 앱 코드·테스트(예: Skill 개수 검증)가 있는지 확인 후 반영 — 이 세션은 읽기 전용이라 수정하지 않았다.

## 8. 재현 방법 (검증용)
1. `curl -sS -L https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03-domain{1..5}.md` (EN) 및 `/ko_kr/` 경로 → `Skill N.N.N:` / `기술 N.N.N:` 줄 파싱.
2. `curl --compressed` 로 위 Wayback PDF URL을 받고 `pdftotext -layout` → `Skill N.N.N:` 줄 파싱(페이지 푸터 제거, 줄바꿈 이어 붙임).
3. 53 Skill을 EN끼리·KO끼리 비교(서비스 약칭 사전으로 표기 차이 분류) → 본문의 건수가 나온다. in-scope / out-of-scope 목록은 PDF Appendix A와 현행 `.md`를 항목 단위로 비교.
