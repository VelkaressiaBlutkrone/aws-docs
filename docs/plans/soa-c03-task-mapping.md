# SOA-C03 Task 매핑 + 학습문서 진척

> 식별자 `soa-t{도메인}-{순번}`. `coversTasks` = 공식 Task 앵커(1:1 또는 복수).
> **files.zip 없음** — SAA와 달리 사전 초안 자료가 없어 전부 공식 Exam Guide `skills[]` + AWS 공식 문서로 신규 집필.
> 각 문서 `📌 출처`에 실제 AWS 공식 문서 URL 기록(게이트 규율). verified 문항은 본 범위 밖(CLF 합격 후 단계).
> 학습문서는 `questionCount:0`으로 등록 → 모의고사·약점 리포트·오답노트는 잠금 유지.

---

## 도메인 (SOA-C03 공식)

| D | 이름 | 비중 | 공식 Task |
|---|---|---|---|
| 1 | 모니터링, 로깅, 분석, 문제 해결 및 성능 최적화 | 22% | 1.1 · 1.2 · 1.3 |
| 2 | 신뢰성 및 비즈니스 연속성 | 22% | 2.1 · 2.2 · 2.3 |
| 3 | 배포, 프로비저닝 및 자동화 | 22% | 3.1 · 3.2 |
| 4 | 보안 및 규정 준수 | 16% | 4.1 · 4.2 |
| 5 | 네트워킹 및 콘텐츠 전송 | 18% | 5.1 · 5.2 · 5.3 |

시험: Associate · 합격 720/1000 · 채점 50문항(+비채점 15) = 65문항.
출처: `flutter_app/assets/exam_guides/SOA-C03.json`.

---

## 학습문서 (진척: ☐ 미작성 / ☑ 작성·배포)

총 **20개** 학습문서 (D1: 5, D2: 4, D3: 4, D4: 3, D5: 4). 전부 `questionCount:0`.

| taskId | 제목 | domain | coversTasks | 상태 |
|---|---|---|---|---|
| soa-t1-1 | CloudWatch 지표·경보·대시보드 | 1 | 1.1 | ☑ |
| soa-t1-2 | CloudWatch Logs·Logs Insights·구독 필터·에이전트 | 1 | 1.1 | ☑ |
| soa-t1-3 | CloudTrail·EventBridge·X-Ray (감사·이벤트·추적) | 1 | 1.1 | ☑ |
| soa-t1-4 | 가용성 지표 기반 문제 식별·해결 (Health Dashboard) | 1 | 1.2 | ☑ |
| soa-t1-5 | 컴퓨팅·스토리지·DB 성능 최적화 (EC2·EBS·RDS·ElastiCache) | 1 | 1.3 | ☑ |
| soa-t2-1 | Auto Scaling·ELB로 확장성·탄력성 구현 | 2 | 2.1 | ☑ |
| soa-t2-2 | Multi-AZ·고가용성·복원력 설계 | 2 | 2.2 | ☑ |
| soa-t2-3 | 백업·복원 전략 (AWS Backup·스냅샷·수명주기) | 2 | 2.3 | ☑ |
| soa-t2-4 | DR·데이터 복원력 (RTO/RPO·S3 복제) | 2 | 2.3 | ☑ |
| soa-t3-1 | CloudFormation 프로비저닝 (템플릿·스택·StackSets·드리프트) | 3 | 3.1 | ☑ |
| soa-t3-2 | AMI·리소스 배포·유지 관리·패치 전략 | 3 | 3.1 | ☑ |
| soa-t3-3 | Systems Manager 운영 자동화 (Run Command·Patch·State Manager·Parameter Store) | 3 | 3.2 | ☑ |
| soa-t3-4 | 자동화 패턴 (EventBridge·Lambda·자동 복구) | 3 | 3.2 | ☑ |
| soa-t4-1 | IAM·계정 보안 운영 (정책·역할·MFA·자격증명 보고서) | 4 | 4.1 | ☑ |
| soa-t4-2 | 규정 준수·거버넌스 (Config·Security Hub·GuardDuty·Inspector) | 4 | 4.1 | ☑ |
| soa-t4-3 | 데이터·인프라 보호 (KMS·암호화·Secrets Manager·ACM) | 4 | 4.2 | ☑ |
| soa-t5-1 | VPC 네트워킹 구현 (서브넷·라우팅·SG·NACL·NAT) | 5 | 5.1 | ☑ |
| soa-t5-2 | 하이브리드·연결 (피어링·TGW·VPN·Direct Connect·엔드포인트) | 5 | 5.1 | ☑ |
| soa-t5-3 | Route 53 DNS·CloudFront 콘텐츠 전송 | 5 | 5.2 | ☑ |
| soa-t5-4 | 네트워크 문제 해결 (Flow Logs·Reachability Analyzer) | 5 | 5.3 | ☑ |

---

## 생산 순서 (실제)

**D1 → D5 → D2 → D3 → D4** — D1(정체성·최빈출) 먼저, D5(네트워킹, SAA 자산 재활용) 다음, D2·D3(SOA 고유 운영), D4(CLF·SAA와 개념 중복) 마지막.

집필: 서브에이전트 구동 개발(`subagent-driven-development`). 도메인별 1 커밋. 구조 검증 테스트(`test/soa_content_structure_test.dart`)로 매 배치 green 확인.

---

## 검수 대기 — 출처 재대조 필요 (집필 시 서브에이전트가 플래그한 저신뢰 수치)

> 구조·핵심 개념은 견고. 아래는 "기억 기반 수치"라 공식 문서 클릭 1회로 확정할 항목.
> 본인 검수(출처 대조)에서 우선 확인 → 맞으면 그대로, 다르면 수정. CLF 합격 후 문항 제작 단계 전에 끝내면 됨.

- **soa-t1-2** — CloudWatch Logs 보존 기간 enum(1·3·5·7·14·30·60·90일 … 최대 10년) 정확 목록.
- **soa-t1-5** — gp2 무버스트 구간/16,000 IOPS 상한 도달 GB 임계값(개념 "3 IOPS/GB·버스트 3,000·최대 16,000"은 확정).
- **soa-t1-4 / 전반** — AWS Health Dashboard 현행 콘솔 명칭(레거시 Service/Personal Health Dashboard ↔ 현행 명칭).
- **soa-t2-1** — 예측 스케일링 최소 데이터 요건(24시간/14일 권장), ASG 헬스체크 유예 기본 300초, 수명주기 후크 하트비트 기본 1시간/최대 48시간.
- **soa-t2-4** — RDS 자동 백업 보존 최대 35일(표준값, 확인).
- **soa-t3-1** — DeletionPolicy Snapshot 지원 리소스 전체 목록(대표 예시만 기재).
- **soa-t4-3** — KMS 고객 관리형 키 자동 교체 주기 구성 가능 범위(현행 min/max 일수).
- **soa-t5-2** — VPN 터널 대역폭 수치(개념만 기재, 수치 미기재).

URL: 전부 canonical 안정 `docs.aws.amazon.com` 경로. WebFetch 라이브 검증은 미실행(`lastVerified: 2026-06-09`은 집필일). 본인 검수 시 라이브 200 확인하면 진짜 verified.

---

## 범위 밖

- **verified 문항 제작** — CLF 합격 후. 현재 `questionCount:0` 게이트만.
- **모의고사/리포트 활성화** — 문항 생기기 전까지 잠금(코드 변경 없음).
- **SOA-C03.json 공식 가이드** — 기존 파일, 미수정.
