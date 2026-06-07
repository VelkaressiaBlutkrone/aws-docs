# SAA-C03 Task 매핑 + 학습문서 진척

> 식별자 `saa-t{도메인}-{순번}`. `coversTasks` = 공식 Task 앵커(1:1 또는 복수).
> files.zip 출처는 본문 초안용 원재료 — 사이트 게시 전 공식 Exam Guide 기준으로 재검증 필요.
> verified 문항은 본 범위 밖(CLF 합격 후 단계). 학습문서는 `questionCount:0`으로 등록.

---

## 도메인 (SAA-C03 공식)

| D | 이름 | 비중 | 공식 Task |
|---|---|---|---|
| 1 | 보안 아키텍처 설계 | 30% | 1.1 · 1.2 · 1.3 |
| 2 | 복원력을 갖춘 아키텍처 설계 | 26% | 2.1 · 2.2 |
| 3 | 고성능 아키텍처 설계 | 24% | 3.1 · 3.2 · 3.3 · 3.4 · 3.5 |
| 4 | 비용에 최적화된 아키텍처 설계 | 20% | 4.1 · 4.2 · 4.3 · 4.4 |

---

## 학습문서 (진척: ☐ 미작성 / ☑ 작성·배포)

총 **24개** 학습문서 (D1: 5, D2: 5, D3: 9, D4: 5)

| taskId | 제목 | domain | coversTasks | files.zip 출처 | 상태 |
|---|---|---|---|---|---|
| saa-t1-1 | IAM — 자격증명·권한·페더레이션 | 1 | 1.1 | Phase-02-Step-1-IAM.md | ☐ |
| saa-t1-2 | 다중 계정 보안 — Organizations·Control Tower·SCP | 1 | 1.1 | (신규 작성 필요) | ☐ |
| saa-t1-3 | VPC 보안 네트워크 — 서브넷·SG·NACL·NAT·엔드포인트 | 1 | 1.2 | Phase-01-Step-2-네트워크-기초.md · Phase-04-Step-1-VPC-심화.md | ☐ |
| saa-t1-4 | 애플리케이션 보안 — Shield·WAF·Cognito·Secrets Manager | 1 | 1.2 | Phase-05-Step-1-암호화.md | ☐ |
| saa-t1-5 | 데이터 보안 제어 — KMS·CloudHSM·ACM·백업·거버넌스 | 1 | 1.3 | Phase-05-Step-1-암호화.md · Phase-05-Step-2-모니터링-감사.md | ☐ |
| saa-t2-1 | 느슨한 결합 아키텍처 — SQS·SNS·EventBridge·Step Functions | 2 | 2.1 | Phase-09-Step-3-SQS-SNS-EventBridge.md | ☐ |
| saa-t2-2 | 서버리스 패턴 — Lambda·API Gateway·Fargate·ECS/EKS | 2 | 2.1 | Phase-09-Step-1-Lambda.md · Phase-09-Step-2-API-Gateway.md | ☐ |
| saa-t2-3 | ELB + Auto Scaling — 탄력적 확장 설계 | 2 | 2.1 · 2.2 | Phase-02-Step-4-ELB-AutoScaling.md | ☐ |
| saa-t2-4 | 고가용성 패턴 — Multi-AZ·단일 실패점 제거 | 2 | 2.2 | Phase-06-Step-1-고가용성-패턴.md | ☐ |
| saa-t2-5 | DR 전략 — RTO·RPO·Pilot Light·Warm Standby·Active-Active | 2 | 2.2 | Phase-06-Step-2-DR-전략.md | ☐ |
| saa-t3-1 | S3 스토리지 성능 — 스토리지 클래스·수명주기·접근 제어 | 3 | 3.1 | Phase-02-Step-3-S3.md | ☐ |
| saa-t3-2 | 블록·파일 스토리지 — EBS 볼륨 타입·EFS·FSx 선택 | 3 | 3.1 | Phase-07-Step-2-Storage-스트리밍.md | ☐ |
| saa-t3-3 | EC2 컴퓨팅 성능 — 인스턴스 패밀리·구매 옵션·배치 전략 | 3 | 3.2 | Phase-02-Step-2-EC2.md | ☐ |
| saa-t3-4 | 컨테이너·서버리스·배치 컴퓨팅 선택 | 3 | 3.2 | Phase-07-Step-1-Compute-성능.md | ☐ |
| saa-t3-5 | RDS·Aurora 고성능 — Multi-AZ·Read Replica·프록시 | 3 | 3.3 | Phase-03-Step-1-RDS-Aurora.md | ☐ |
| saa-t3-6 | DynamoDB·ElastiCache — NoSQL 성능·캐싱 전략 | 3 | 3.3 | Phase-03-Step-2-DynamoDB.md · Phase-03-Step-3-ElastiCache.md | ☐ |
| saa-t3-7 | 네트워크 성능 — Route 53·CloudFront·Global Accelerator·로드밸런서 | 3 | 3.4 | Phase-04-Step-2-Route53.md · Phase-04-Step-3-CloudFront.md | ☐ |
| saa-t3-8 | 하이브리드 네트워크 — VPC 심화·VPN·Direct Connect·PrivateLink | 3 | 3.4 | Phase-04-Step-1-VPC-심화.md · Phase-04-Step-4-하이브리드.md | ☐ |
| saa-t3-9 | 데이터 수집·변환·분석 — Kinesis·Glue·Athena·EMR·Lake Formation | 3 | 3.5 | Phase-07-Step-2-Storage-스트리밍.md | ☐ |
| saa-t4-1 | 비용 최적화 스토리지 — S3 티어링·EBS 선택·수명주기·전송 비용 | 4 | 4.1 | Phase-08-Step-1-비용절감-패턴.md · Phase-02-Step-3-S3.md | ☐ |
| saa-t4-2 | 비용 최적화 컴퓨팅 — Savings Plans·RI·Spot·오토스케일링·rightsizing | 4 | 4.2 | Phase-08-Step-1-비용절감-패턴.md · Phase-02-Step-2-EC2.md | ☐ |
| saa-t4-3 | 비용 최적화 데이터베이스 — DB 서비스 선택·용량 계획·서버리스 옵션 | 4 | 4.3 | Phase-08-Step-2-비용-시험전략.md · Phase-03-Step-1-RDS-Aurora.md | ☐ |
| saa-t4-4 | 비용 최적화 네트워크 — NAT 전략·전송 비용·CDN·피어링·PrivateLink | 4 | 4.4 | Phase-08-Step-2-비용-시험전략.md | ☐ |
| saa-t4-5 | 비용 관리 도구 — Cost Explorer·Budgets·CUR·태그·Well-Architected | 4 | 4.1 · 4.2 · 4.3 · 4.4 | Phase-08-Step-1-비용절감-패턴.md · Phase-11-Well-Architected.md | ☐ |

---

## 제외 (학습문서 아님)

개인 취업·면접 맥락:
- `DIO-면접-1페이지-요약.md` — DIO Implant 인프라 직무 면접용 개인 요약, 학습문서 범위 외

모의고사 문항 파일 (CLF 합격 후 verified 단계에서 처리):
- `종합모의고사-1회분.md` ~ `종합모의고사-5회분.md` (65문항×5 = 325문항)
- `Mock-Phase-01-클라우드-네트워크.md` ~ `Mock-Phase-11-Well-Architected.md` (약 110문항)

앱·스크립트:
- `SAA-모의고사-앱.html` — 단일 HTML 랜덤 출제 앱, 사이트 외부 도구
- `shuffle_md.py` — 보기 셔플 재사용 스크립트

로드맵 문서 (사이트 학습문서 아님):
- `AWS-SAA-C03-학습로드맵.md` — 전체 로드맵 개요/2주 플랜, 학습문서 원재료 참고용

---

## 신규 작성 필요 (files.zip 초안 없음)

| taskId | 이유 |
|---|---|
| saa-t1-2 | 다중 계정(Organizations·Control Tower·SCP)은 공식 Task 1.1의 핵심이나 files.zip에 전용 문서 없음. Phase-01-Step-1(클라우드 개념)에 일부 언급 수준 |
| saa-t3-9 | Kinesis 스트리밍은 Phase-07-Step-2에 일부 포함되나, Glue·Athena·EMR·Lake Formation·QuickSight 등 분석 스택은 별도 초안 없음 |

---

## 생산 순서

비중 큰 순: **D1(30%) → D2(26%) → D3(24%) → D4(20%)**

### D1 보안 (5개 문서)
1. `saa-t1-1` IAM — Phase-02-Step-1 초안 있음
2. `saa-t1-3` VPC 보안 네트워크 — Phase-01-Step-2 + Phase-04-Step-1 초안 있음
3. `saa-t1-4` 애플리케이션 보안 — Phase-05-Step-1 초안 있음
4. `saa-t1-5` 데이터 보안 제어 — Phase-05-Step-1·Step-2 초안 있음
5. `saa-t1-2` 다중 계정 보안 — **신규 작성 필요** (초안 없음)

### D2 복원력 (5개 문서)
6. `saa-t2-4` 고가용성 패턴 — Phase-06-Step-1 초안 있음
7. `saa-t2-5` DR 전략 — Phase-06-Step-2 초안 있음
8. `saa-t2-3` ELB + Auto Scaling — Phase-02-Step-4 초안 있음
9. `saa-t2-1` 느슨한 결합 — Phase-09-Step-3 초안 있음
10. `saa-t2-2` 서버리스 패턴 — Phase-09-Step-1·Step-2 초안 있음

### D3 고성능 (9개 문서)
11. `saa-t3-5` RDS·Aurora — Phase-03-Step-1 초안 있음
12. `saa-t3-6` DynamoDB·ElastiCache — Phase-03-Step-2·Step-3 초안 있음
13. `saa-t3-1` S3 스토리지 성능 — Phase-02-Step-3 초안 있음
14. `saa-t3-2` 블록·파일 스토리지 — Phase-07-Step-2 초안 있음
15. `saa-t3-3` EC2 컴퓨팅 성능 — Phase-02-Step-2 초안 있음
16. `saa-t3-4` 컨테이너·서버리스·배치 — Phase-07-Step-1 초안 있음
17. `saa-t3-7` 네트워크 성능 — Phase-04-Step-2·Step-3 초안 있음
18. `saa-t3-8` 하이브리드 네트워크 — Phase-04-Step-1·Step-4 초안 있음
19. `saa-t3-9` 데이터 수집·변환·분석 — **신규 작성 필요** (분석 스택 초안 없음)

### D4 비용 (5개 문서)
20. `saa-t4-2` 비용 최적화 컴퓨팅 — Phase-08-Step-1·Phase-02-Step-2 초안 있음
21. `saa-t4-1` 비용 최적화 스토리지 — Phase-08-Step-1·Phase-02-Step-3 초안 있음
22. `saa-t4-3` 비용 최적화 DB — Phase-08-Step-2·Phase-03-Step-1 초안 있음
23. `saa-t4-4` 비용 최적화 네트워크 — Phase-08-Step-2 초안 있음
24. `saa-t4-5` 비용 관리 도구 — Phase-08-Step-1·Phase-11 초안 있음

---

## 메모 — files.zip Phase 문서 재배치 요약

| files.zip Phase | 주요 내용 | 배치된 saa-t |
|---|---|---|
| Phase-01-Step-1 클라우드 기본개념 | 공동 책임 모델, 글로벌 인프라 | 배경지식 (별도 학습문서 불필요) |
| Phase-01-Step-2 네트워크 기초 | VPC·CIDR·서브넷·SG·NACL·NAT | saa-t1-3 (보안 VPC) |
| Phase-02-Step-1 IAM | 사용자·그룹·역할·정책·STS | saa-t1-1 |
| Phase-02-Step-2 EC2 | 인스턴스 타입·구매옵션·EBS | saa-t3-3, saa-t4-2 |
| Phase-02-Step-3 S3 | 스토리지 클래스·수명주기·접근 제어 | saa-t3-1, saa-t4-1 |
| Phase-02-Step-4 ELB-AutoScaling | ALB/NLB·ASG·스케일링 정책 | saa-t2-3 |
| Phase-03-Step-1 RDS-Aurora | Multi-AZ·Read Replica·Aurora | saa-t3-5, saa-t4-3 |
| Phase-03-Step-2 DynamoDB | 키 설계·GSI/LSI·DAX·Global Tables | saa-t3-6 |
| Phase-03-Step-3 ElastiCache | Redis vs Memcached·캐싱 전략 | saa-t3-6 |
| Phase-04-Step-1 VPC 심화 | Peering·Transit GW·Endpoint·Flow Logs | saa-t1-3, saa-t3-8 |
| Phase-04-Step-2 Route53 | 라우팅 정책 7종·Alias·헬스체크 | saa-t3-7 |
| Phase-04-Step-3 CloudFront | CDN·OAC·Signed URL·Global Accelerator | saa-t3-7 |
| Phase-04-Step-4 하이브리드 | VPN·Direct Connect·Storage Gateway | saa-t3-8 |
| Phase-05-Step-1 암호화 | KMS·CloudHSM·ACM·Secrets Manager | saa-t1-4, saa-t1-5 |
| Phase-05-Step-2 모니터링-감사 | CloudWatch·CloudTrail·Config·GuardDuty·Macie | saa-t1-5 |
| Phase-06-Step-1 고가용성 패턴 | SPOF 제거·Multi-AZ 설계 패턴 | saa-t2-4 |
| Phase-06-Step-2 DR 전략 | RTO/RPO·4가지 DR 전략 | saa-t2-5 |
| Phase-07-Step-1 Compute 성능 | EC2/컨테이너/서버리스/배치/HPC 선택 | saa-t3-4 |
| Phase-07-Step-2 Storage-스트리밍 | EBS 타입·EFS·FSx·Kinesis 4종 | saa-t3-2, saa-t3-9 (부분) |
| Phase-08-Step-1 비용절감 패턴 | Savings Plans·RI·Spot·비용 도구 | saa-t4-1, saa-t4-2, saa-t4-5 |
| Phase-08-Step-2 비용 시험전략 | 키워드 매핑·오답 제거 프레임 | saa-t4-3, saa-t4-4 |
| Phase-09-Step-1 Lambda | 이벤트 소스·호출방식·동시성·실패처리 | saa-t2-2 |
| Phase-09-Step-2 API-Gateway | REST/HTTP/WebSocket·인증·스로틀링 | saa-t2-2 |
| Phase-09-Step-3 SQS-SNS-EventBridge | 메시징·이벤트 라우팅·Step Functions | saa-t2-1 |
| Phase-10-Step-1 DB 마이그레이션 | DMS·SCT·최소 다운타임 전략 | saa-t3-9 (마이그레이션 부분) |
| Phase-10-Step-2 데이터전송-스토리지 | DataSync·Snow·Storage GW·Transfer Family | saa-t3-9 |
| Phase-11-Well-Architected | 6 Pillars·판단 프레임워크 | saa-t4-5 (비용 기둥) + 횡단 참고 |
