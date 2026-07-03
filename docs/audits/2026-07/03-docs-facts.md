# ③ 학습문서 사실성 감사 종합 — 2026-07

> 입력: `docs/audits/2026-07/raw/` 샤드 14건 — 03-docs-clf-a~d(4) · 03-docs-saa-a~e(5) · 03-docs-soa-a~d(4) · 03-exam-guides(1).
> 본 문서는 기존 발견의 재구성(중복 통합·정렬·집계)이며 새 발견을 추가하지 않았다. 원 ID는 전건 보존.

## 요약

- **총 134건(원 ID 기준) — H 13 · M 54 · L 67. 중복·교차 통합 후 121건(9계열 22 ID → 9건). 사실의심 Y 109건**(통합 시 102계열)이 2단 반박 검증(P12) 대상.
- H 13건(통합 후 12계열)의 분포: CLF 2(Support 플랜 루트 전용 단정 CLF-102 · Enterprise "프로덕션 15분 응답" CLF-309), SAA 8(NAT GW 자동 HA 005 · Interface EP에서 S3/DDB 제외 006 · SNS 필터링 부정 101 · **Aurora 256TiB 2개 샤드 독립 발견 209+406** · gp3 버스트 크레딧 210 · GA→CloudFront 체이닝 301 · Budget Actions 3종 오기 411), SOA 3(경보 작업 대상 오분류 002 · gp2 도달 용량 3,334GB 009 · Flow Log REJECT/SG 역방향 교육 315).
- 교차 패턴 최중요 2계열은 **cert 경계를 넘는 동일 수치 오류**: Aurora "256TiB(2025년 상향)"(SAA-209+SAA-406, 둘 다 H)와 Cost Explorer "18개월 예측"(CLF-308+SAA-410) — 동일 생성 파이프라인發 환각 의심. 그 외 KMS 교집합(SAA-010+SOA-305), S3/DDB Interface EP 부재 프레임(SAA-006+SOA-311), Geoproximity Traffic Flow 전제(SAA-302+SOA-312), "DX over VPN" 표기 역전(SAA-304+SOA-310), Data Firehose 구명칭(SOA-006+SOA-316), "(원리: §N)" 참조 깨짐(CLF 4 ID+SAA-103, 7개 문서), 단종 메모 비일관(CLF-106+CLF-205+SAA-306).
- 음성 교차 검증(오류 비전파 확인): NAT GW "자동 HA"·CRR "버전 관리 지원"은 SOA에서 무결 확인(soa-b·soa-d), SP 72%/66% 혼동은 SAA에서 무결 확인(saa-e) — cert 간 오류 전파는 제한적.
- 시험 가이드: **3종 모두 2026-07-02 기준 현행 버전 — 사용자의 2~4주 내 CLF-C02 응시에 버전 리스크 없음.** 단 SOA-C03.json은 공식 v1.1(2026-06-01) 개정 미반영(GUIDE-001)·자격증명 CloudOps 개명(GUIDE-002).
- Phase 분포: A(자구 정정 즉시 반영 가능) 82건 / B(2단 검증·사람 결정 필요) 52건.

## 통계

### cert × 심각도 (원 ID 기준)

| cert | H | M | L | 계 | 사실의심 Y |
|---|---|---|---|---|---|
| CLF | 2 | 9 | 15 | **26** | 19 |
| SAA | 8 | 22 | 28 | **58** | 48 |
| SOA | 3 | 21 | 23 | **47** | 39 |
| GUIDE(시험 가이드) | 0 | 2 | 1 | **3** | 3 |
| **계** | **13** | **54** | **67** | **134** | **109** |

### Phase 분포

| cert | Phase A | Phase B | 계 |
|---|---|---|---|
| CLF | 16 | 10 | 26 |
| SAA | 32 | 26 | 58 |
| SOA | 33 | 14 | 47 |
| GUIDE | 1 | 2 | 3 |
| **계** | **82** | **52** | **134** |

### 샤드별 발견 수

| 샤드 | 대상 | 건수 | 내역 |
|---|---|---|---|
| 03-docs-clf-a | clf t1-1~t2-1 | 3 | M1 L2 |
| 03-docs-clf-b | clf t2-2~t3-2 | 6 | H1 M1 L4 |
| 03-docs-clf-c | clf t3-3~t3-7 | 6 | M4 L2 |
| 03-docs-clf-d | clf t3-8·t4-1~t4-3 | 11 | H1 M3 L7 |
| 03-docs-saa-a | saa t1-1~t1-5 | 15 | H2 M4 L9 |
| 03-docs-saa-b | saa t2-1~t2-5 | 10 | H1 M5 L4 |
| 03-docs-saa-c | saa t3-1~t3-5 | 13 | H2 M5 L6 |
| 03-docs-saa-d | saa t3-6~t3-9 | 8 | H1 M2 L5 |
| 03-docs-saa-e | saa t4-1~t4-5 | 12 | H2 M6 L4 |
| 03-docs-soa-a | soa t1-1~t1-5 | 9 | H2 M3 L4 |
| 03-docs-soa-b | soa t2-1~t2-4 | 9 | M3 L6 |
| 03-docs-soa-c | soa t3-1~t3-4·t4-1 | 13 | M5 L8 |
| 03-docs-soa-d | soa t4-2·t4-3·t5-1~t5-4 | 16 | H1 M10 L5 |
| 03-exam-guides | exam_guides JSON 3종 | 3 | M2 L1 |

### 중복 통합 산식

원 134건 − 통합 13건 = **121건**. 통합 9계열(상세는 「교차 패턴」):
P1 Aurora 256TiB(2→1) · P2 CE 18개월(2→1) · P3 KMS 교집합(2→1) · P4 S3/DDB Interface EP(2→1) · P5 Geoproximity(2→1) · P6 DX over VPN(2→1) · P7 Data Firehose(2→1) · P8 §N 참조 깨짐(5→1) · P9 단종 메모 부재(3→1).
사실의심 Y는 원 ID 기준 109건, 통합 시 102계열(P1·P2·P3·P4·P5·P7·P9에서 각 −1; P6·P8은 전건 N).

## H 전건 (13 ID · 통합 후 12행)

| ID(통합 병기) | cert | 위치 | 내용 | 확신도 | Phase | Y |
|---|---|---|---|---|---|---|
| DOC-CLF-102 | CLF | clf/t2-3#root-user(본문·시험 포인트·Q1, 3개소) | "AWS Support 플랜 변경·취소=루트 전용" 단정 — 현행 IAM root-only 목록(2026-07 실측)에 없음, 2022-09 Support Plans IAM 제어 도입으로 IAM 주체도 가능. 레거시 기출 관례와의 충돌 판단 필요. questions.json 동일 단정 문항 교차 점검 권고 | 높 | B | Y |
| DOC-CLF-309 | CLF | clf/t4-3#support-plans(표·시험 포인트) | Enterprise "프로덕션 중요 케이스 15분 응답" — 공식은 **비즈니스 크리티컬** 다운 <15분, 프로덕션 다운은 Enterprise도 <1시간(문서 자신의 #health-dashboard와도 긴장). 시험 단골 수치 | 높 | A | Y |
| DOC-SAA-005 | SAA | saa/saa-t1-3 §2(NAT 표·Q1) | NAT GW "자동 고가용성" — 실제는 단일 AZ 내 이중화뿐, AZ 장애 대비는 AZ별 배치+라우팅(단골 출제). "이미 HA라 조치 불필요" 오답 유도 | 높 | A | Y |
| DOC-SAA-006 〔동계열 M: DOC-SOA-311 — P4〕 | SAA | saa/saa-t1-3 §4(유형 표) | "Interface Endpoint 대상: S3·DynamoDB **외**" — S3(2021)·DynamoDB(2024) Interface 지원, 같은 문서 Q3 답과 내부 모순. 온프레미스→S3 사설 접근 문항(정답=Interface)에서 오답 유발 | 높 | A | Y |
| DOC-SAA-101 | SAA | saa/saa-t2-1 자가 점검 Q3 해설 | "SNS는 조건 필터링 없이 전체 구독자에게 Push" — 구독 필터 정책(속성·페이로드 기반) 공식 존재 부정, §7 원리와 문서 내 모순. "SNS 팬아웃+필터 정책" 정답 문항에서 오답 유발 | 높 | A | Y |
| DOC-SAA-209 · DOC-SAA-406 〔P1 통합 — 2샤드 독립 발견〕 | SAA | saa/saa-t3-5 §7·§8 + saa/saa-t4-3 §3 | Aurora 스토리지 상한 "256TiB(2025년 상향, 구버전 128TiB)" — 공식 상한 128TiB(구엔진 64TiB), 256TiB 상향 공지 미확인. 2020년 64→128 패턴을 한 단계 올린 환각 또는 Aurora Limitless 혼동 의심. 시험 정답 관례도 128TiB — 수치 문항 오답 직결. ※컨트롤러 지시 컨텍스트: 문항(questions.json) 감사 차원에서도 동일 수치 침투 보고됨(본 차원 밖) | 중 | B | Y |
| DOC-SAA-210 | SAA | saa/saa-t3-5 §6 원리 | "gp2/gp3는 버스트 크레딧 방식" — gp3는 크레딧 없음(기준 3,000 IOPS 고정), 버스트 버킷은 gp2 전용. 같은 샤드 saa-t3-2 §3과 정면 모순. 'gp2→gp3 전환으로 버스트 의존 제거' 기출 패턴에서 오답 유발 | 높 | A | Y |
| DOC-SAA-301 | SAA | saa/saa-t3-7 §7+시험 포인트 | "CloudFront 앞에 Global Accelerator를 붙여 고정 IP+CDN 캐싱" 조합 가능 단정 — GA 엔드포인트 유형(ALB·NLB·EC2·EIP)에 CloudFront 없음(불가능한 아키텍처), 같은 문서 §6 목록과 내부 모순. 고정 IP 요구는 별도 기능(CloudFront Anycast Static IP, 2024-11) 영역 | 높 | B | Y |
| DOC-SAA-411 | SAA | saa/saa-t4-5 §3(코드블록·함정 7) | Budget Actions 3종을 "IAM 정책·SNS·SSM Automation"으로 오기 — 공식 3종은 ①IAM 정책 적용 ②SCP 적용 ③EC2/RDS 중지. "예산 초과 시 EC2/RDS 자동 중지 가능?" 문항 오답 유발 | 높 | A | Y |
| DOC-SOA-002 | SOA | soa/soa-t1-1 §4(표·시험 포인트) | EventBridge를 경보 작업(alarm action) 대상으로 오분류(실제는 자동 발행 통합) + Lambda 직접 작업(2022-12 추가) 누락. t1-3 §5와 문서 간 불일치. "직접 구성 가능한 경보 작업" 문항 오답 유발 | 높 | A | Y |
| DOC-SOA-009 | SOA | soa/soa-t1-5 §2 "시험 빈출 수치" | gp2 16,000 IOPS 도달 용량 "≈3,334GB" — 3 IOPS/GiB이므로 ≈5,334GiB(3,334는 구세대 10,000 IOPS 상한 시절 수치). "반드시 기억" 절에 위치해 오답 직결 | 높 | A | Y |
| DOC-SOA-315 | SOA | soa/soa-t5-4 전반(체크리스트·§2·§3·시험 포인트·함정 2·Q1) | "SG 거부는 Flow Log에 REJECT로 안 남는다"를 ★결정적 뉘앙스로 반복 교육 — 공식 정의는 REJECT=SG **또는** NACL 불허(SG 인바운드 불허 시 단일 REJECT 기록 예시 명시). 추론 패턴("REJECT 부재=SG 의심")이 역방향 오류. §3 전면 재작성 필요, Q2(NACL 시그니처)와 문서 내 긴장 | 높 | B | Y |

## M 전건 (54 ID · 통합 후 51행)

| ID(통합 병기) | cert | 위치 | 내용 | 확신도 | Phase | Y |
|---|---|---|---|---|---|---|
| DOC-CLF-002 | CLF | clf/t2-1 「왜 중요한가」 | "도메인 2가 30%로 가장 큼" — 최대는 D3 34%(24/30/34/12). ※03-exam-guides 샤드가 공식 비중 24/30/34/12를 축자 확인 — 교차 지지 | 높 | A | Y |
| DOC-CLF-101 | CLF | clf/t2-2#audit-trio §6 정직성 메모 | Audit Manager 신규 중단 "2024년 이후" — 공식 공지는 2026-04-30(유지보수 모드). 취지는 유효, 연도만 오류 | 높 | A | Y |
| DOC-CLF-201 | CLF | clf/t3-4#dynamodb | "(0까지 — 트래픽 없으면 비용 없음)" — 요청 비용만 0, 스토리지는 계속 과금 | 높 | A | Y |
| DOC-CLF-202 | CLF | clf/t3-6#ebs(+시험 포인트·Q3) | "중지·종료해도 데이터 유지" — 종료 시 루트 볼륨은 기본 삭제(DeleteOnTermination=true) | 높 | A | Y |
| DOC-CLF-203 | CLF | clf/t3-6 용어표 내구성 행 | 11 9s를 "1,000만 개 중 1개 미만 손실"로 — "평균 1만 년에 1개" 기간 누락으로 사실상 7 9s 수준으로 왜곡 | 높 | A | Y |
| DOC-CLF-204 | CLF | clf/t3-3#ec2 | "가상 서버를 늘리고(scale up) 줄일(scale down)" — 대수 증감은 out/in(수평), up/down은 수직. 용어 오매핑 | 중 | B | Y |
| DOC-CLF-301 | CLF | clf/t3-8#messaging 원리 | "SNS는 저장·재시도 메커니즘 없이 전달" — 프로토콜별 재시도 정책(최대 23일)·DLQ 공식 존재 | 높 | A | Y |
| DOC-CLF-305 | CLF | clf/t4-1#purchase-options(표·시험 포인트·Q1) | SP "최대 72% + 패밀리·리전 무관"을 한 플랜 속성처럼 결합 — 72%=EC2 Instance SP(고정), 완전 유연=Compute SP(최대 66%) | 높 | A | Y |
| DOC-CLF-308 · DOC-SAA-410 〔P2 통합 — CLF·SAA 양쪽 발견〕 | CLF+SAA | clf/t4-2#cost-tools 표 + saa/saa-t4-5(체크리스트·표·§2·Q1, 4곳) | Cost Explorer "향후 ~18개월 예측" — 공식은 이력 13개월+예측 12개월. 두 cert에 동일 수치 오류 침투 | 높/중 | A | Y |
| DOC-SAA-001 | SAA | saa/saa-t1-1 §7 | SCP 관리 계정 예외를 "루트만"으로 축소 — 관리 계정은 모든 주체(IAM 사용자·역할 포함) 미적용. t1-2 §3과 뉘앙스 불일치 | 높 | A | Y |
| DOC-SAA-002 | SAA | saa/saa-t1-2 자가 점검 Q1 | 질문(us-east-1 외 금지)·답변(ap-northeast-2 허용) 리전 불일치 — 문서 내부 모순 | 높 | A | N |
| DOC-SAA-007 | SAA | saa/saa-t1-4 시험 포인트 | WAF×CloudFront "us-east-1 제한 없음" — 사실과 반대: CLOUDFRONT 스코프 웹 ACL은 us-east-1에서 생성 | 높 | A | Y |
| DOC-SAA-010 · DOC-SOA-305 〔P3 통합 — SAA·SOA 양쪽 발견〕 | SAA+SOA | saa/saa-t1-5 §2(+함정 3·Q2) + soa/soa-t4-3 §1(+시험 포인트·함정 7) | KMS 접근을 "IAM 정책과 키 정책의 교집합/둘 다 Allow"로 단정 — 키 정책이 직접 허용하면 IAM 없이도 가능(키 정책 단독 충분), IAM은 키 정책의 위임 문 전제. "키 정책에 사용자 추가"가 단독 정답인 문항에서 배제 오답 | 높 | B/A | Y |
| DOC-SAA-104 | SAA | saa/saa-t2-2 함정 1 | "Step Functions(Durable Lambda)" — 그런 공식 명칭 확인 불가, 괄호가 혼동 유발 | 중 | A | Y |
| DOC-SAA-105 | SAA | saa/saa-t2-3 §1 표 NLB 행 | NLB 프로토콜에 "QUIC" — 공식 리스너 목록은 TCP·UDP·TCP_UDP·TLS | 중 | A | Y |
| DOC-SAA-106 | SAA | saa/saa-t2-3 §2 표 | ALB 대상 그룹에 "다른 ALB 등록 가능" — 방향 오류: ALB를 대상으로 두는 것은 NLB의 기능 | 높 | A | Y |
| DOC-SAA-107 | SAA | saa/saa-t2-3 §5 표 | "NLB(TCP 플로우 해시로 자연스럽게 고정)" — 세션 고정은 source_ip 스티키니스(opt-in) 별도 기능 | 높 | A | Y |
| DOC-SAA-109 | SAA | saa/saa-t2-5 §4 표 S3 행 | CRR "버전 관리 지원" — 지원이 아니라 원본·대상 모두 활성화 필수 전제(시험 단골) | 높 | A | Y |
| DOC-SAA-201 | SAA | saa/saa-t3-1 §5 | S3 접근 제어 "①BPA→②IAM→③버킷 정책→④ACL" 순차 관문 — 실제는 union 평가(같은 계정은 어느 한쪽 Allow로 충분)+명시적 Deny 우선 | 높 | B | Y |
| DOC-SAA-202 | SAA | saa/saa-t3-2 §3(+Q2·시험 포인트) | gp3 64TiB·80,000 IOPS·2,000 MiB/s 상향 수치 단독 제시 — 시험 문항 관례는 16K/1,000/16TiB 전제, 병기 필요 | 중 | B | Y |
| DOC-SAA-206 | SAA | saa/saa-t3-3 Q4 | r7g 적합을 "메모리 대비 CPU 비율 높음"으로 — 방향 반전(R 패밀리=1:8), §2 표와 자기모순 | 높 | A | N |
| DOC-SAA-208 | SAA | saa/saa-t3-5 §3·§4·§8·Q1 | RDS Read Replica "최대 5개" 반복 — 현행 MySQL·MariaDB·PostgreSQL 15개(Oracle·SQL Server 5개) | 중 | B | Y |
| DOC-SAA-212 | SAA | saa/saa-t3-5 §1 | OS 접근 필요 시 대안을 "EC2 직접 설치"로 단정 — RDS Custom(Oracle·SQL Server) 누락 | 중 | B | N |
| DOC-SAA-302 · DOC-SOA-312 〔P5 통합 — SAA·SOA 양쪽 발견〕 | SAA+SOA | saa/saa-t3-7 §3(3회) + soa/soa-t5-3(용어표·§4, 3곳) | "Geoproximity는 Traffic Flow에서만 사용 가능" 단정 — 일반 레코드 직접 지원으로 현행과 불일치. **주의: 두 샤드의 근거 시점 상이(SAA=2024-02 일반 레코드 지원 vs SOA=2023-11 콘솔 직접 지원) — 2단 검증에서 시점 확정 필요** | 중 | B | Y |
| DOC-SAA-305 | SAA | saa/saa-t3-9 함정 6+§2 | "샤드 수는 자동 증가하지 않음" 무조건 단정 — 프로비저닝 모드 한정 사실, 온디맨드 모드(2021-11) 누락 | 높 | B | Y |
| DOC-SAA-401 | SAA | saa/saa-t4-1 §5 표 | 교차 AZ 프라이빗 IP "더 낮은 요율" — 퍼블릭 경유와 동일(방향당 $0.01/GB) | 높 | A | Y |
| DOC-SAA-402 | SAA | saa/saa-t4-1 §2(+함정 7) | 128KB 미만 객체 "모니터링 요금이 절감액 초과" — 2021-09 이후 128KB 미만은 모니터링 비대상·비과금(실 리스크는 절감 0) | 높 | A | Y |
| DOC-SAA-403 | SAA | saa/saa-t4-1 §7 | Storage Class Analysis를 Storage Lens 하위 기능으로 — 별개 기능(S3 Analytics), 도구 구분 문항 혼동 | 높 | A | Y |
| DOC-SAA-408 | SAA | saa/saa-t4-4 §2 표+시나리오 | NAT 경유 same-region S3에 "아웃바운드 요금 가산" — 같은 리전 EC2↔S3는 경로 무관 무료(NAT 처리요금만). t4-1 §5와 샤드 내 상호 불일치 | 높 | A | Y |
| DOC-SAA-409 | SAA | saa/saa-t4-4 §5 표+시나리오 | TGW 교차 AZ 전송 $0.01/GB 가산(합계 $0.03/GB) — 2022-04 리전 내 교차 AZ 무료화 이후 구식 의심 | 중 | B | Y |
| DOC-SOA-001 | SOA | soa/soa-t1-1 §1 | 기간·통계를 지표 "고유 식별 4요소"에 포함 — 식별=네임스페이스+이름+차원. 같은 문서 시험 포인트와 자기모순 | 높 | A | N |
| DOC-SOA-003 | SOA | soa/soa-t1-1 §4 SSM 행 | 경보 작업으로 "자동화 런북 실행" — 직접 작업은 OpsItem·인시던트 생성 2종, 런북은 간접 | 중 | A | Y |
| DOC-SOA-008 | SOA | soa/soa-t1-4 함정 4·§4 | "(인스턴스 스토어 데이터 유실 가능)" — 자동 복구(recover)는 EBS 전용 인스턴스만 지원, 인스턴스 스토어 장착 시 복구 자체 미지원 | 중 | B | Y |
| DOC-SOA-101 | SOA | soa/soa-t2-1 §4 표 | 워밍업 효과에 "상태 확인 제외" 혼입 — 상태 확인 보류는 유예 기간(§6)의 역할, 두 설정 혼동 | 중 | A | Y |
| DOC-SOA-106 | SOA | soa/soa-t2-2 §4 원리 | "AZ 전체 비정상 시 그 AZ 노드가 트래픽 안 받음" — cross-zone 비활성 전제 메커니즘, ALB 기본(활성)과 불일치. t2-1 §7과 샤드 내 긴장 | 중 | B | Y |
| DOC-SOA-108 | SOA | soa/soa-t2-4 §4·§7-2 | S3 복제 "거의 실시간" 단정 + RTC(15분 SLA 유료 옵션) 부재 — 복제 완료 시간은 무보증 | 높 | B | N |
| DOC-SOA-201 | SOA | soa/soa-t3-1 §3(+Q5) | 스택 생성 실패 기본 동작이 "스택 제거"로 읽힘 — 기본(ROLLBACK)은 ROLLBACK_COMPLETE 잔존(수동 삭제 필요), 제거는 OnFailure=DELETE 지정 시만 | 높 | A | Y |
| DOC-SOA-203 | SOA | soa/soa-t3-1 §7(함정 2·Q4) | RDS DeletionPolicy "기본=삭제" 무조건 단정 — DBCluster 등은 기본 Snapshot 예외. 표("대부분" 헤지)와 문서 내 온도차 | 중 | B | Y |
| DOC-SOA-206 | SOA | soa/soa-t3-2 §2(+함정 3·Q1) | "암호화 AMI 공유엔 KMS 키 공유" — AWS 관리형 기본 키(aws/ebs) 암호화본은 공유 자체 불가(CMK 재암호화 필요) 전제 누락 | 높 | A | Y |
| DOC-SOA-211 | SOA | soa/soa-t4-1 §1 표 | 인라인 정책 부착 대상 "사용자·역할" — 그룹 누락(PutGroupPolicy 존재). 표 구조가 "그룹 불가" 오개념을 명시적으로 심음 | 높 | A | Y |
| DOC-SOA-212 | SOA | soa/soa-t4-1 §7 | 루트 전용 작업에 "특정 S3/SCP 우회" — 루트가 SCP를 우회한다고 오독됨. 같은 문서 "SCP는 루트 포함 적용"(시험 최다 출제 포인트)과 정면 모순 | 높 | A | Y |
| DOC-SOA-301 | SOA | soa/soa-t4-2 §1 원리 | Config가 "변경 시가 아니라 지속적으로 평가" 프레임 — 공식은 변경 트리거·주기 2유형, 같은 절 운영 흐름과 상충 | 높 | A | Y |
| DOC-SOA-302 | SOA | soa/soa-t4-2 §3 | GuardDuty 심각도 "Low/Medium/High" 3단 — 현행 Critical 포함 4단(2024-12 이후) | 중 | B | Y |
| DOC-SOA-304 | SOA | soa/soa-t4-2 체크리스트·§5·시험 포인트(3곳) | Trusted Advisor "5개 범주" 단정 — 현행 6범주(운영 우수성 2022-11 추가) | 높 | B | Y |
| DOC-SOA-306 | SOA | soa/soa-t4-3 §7 원리 | 가져온 인증서 갱신 불가 사유를 "개인 키가 ACM 외부"로 — import는 개인 키 업로드 필수(전제 오류), 실사유는 제3자 CA 재발급 불가 | 높 | A | Y |
| DOC-SOA-307 | SOA | soa/soa-t4-3 §7(+시험 포인트) | "자동 갱신(DNS/이메일 검증 유효 시)" 병렬 — 이메일 검증은 소유자 메일 대응 필요(무개입 자동은 DNS만). "DNS 검증 권장" 정답 포인트 훼손 | 높 | A | Y |
| DOC-SOA-308 | SOA | soa/soa-t5-1 §7 ↔ soa-t5-3 §1 | 프라이빗 DNS 요건을 enableDnsSupport만으로 — enableDnsHostnames도 필요. t5-3은 옳게 기술(샤드 내 상호 불일치) | 높 | A | Y |
| DOC-SOA-311 〔P4 — H DOC-SAA-006 동계열〕 | SOA | soa/soa-t5-2 §5·함정 4(+체크리스트) | "게이트웨이=S3·DDB 전용, 나머지=인터페이스" 프레임 — S3(2021)·DDB(2024) 인터페이스 EP 존재 + 게이트웨이의 VPC 내부 전용 제약 누락("S3엔 인터페이스가 없다" 오개념) | 높 | A | Y |
| DOC-SOA-313 | SOA | soa/soa-t5-3 체크리스트·§4·시험 포인트 | "라우팅 정책 7종" 단정 — 현행 IP-based(2022-06) 포함 8종, 문서가 인용한 공식 페이지 자체가 8종. ※saa-d 샤드는 saa-t3-7의 "7종"을 무결 판정 — **샤드 간 판단 불일치, 검증 확정 결과를 saa-t3-7에도 공유 필요** | 높 | B | Y |
| GUIDE-001 | GUIDE | assets/exam_guides/SOA-C03.json | 공식 가이드 v1.1(2026-06-01) 개정 미반영 — 스킬 11건 변경 + in-scope에 Bedrock·Kiro·DevOps Agent 등 5종 추가(JSON은 v1.0 문구). 도메인 구성·비중·합격선은 v1.1에서도 불변 확인 | 높 | B | Y |
| GUIDE-002 | GUIDE | SOA-C03 자격증 명칭 | 공식명 "AWS Certified CloudOps Engineer - Associate"로 개명(2025-09-30 발효) — JSON 자체는 무결, 앱 표시명이 구명(SysOps)이면 갱신 필요 | 높 | B | Y |

## L 전건 (67 ID · 통합 후 59행)

| ID(통합 병기) | cert | 위치 | 내용(요지) | 확신도 | Phase | Y |
|---|---|---|---|---|---|---|
| DOC-CLF-001 | CLF | clf/t1-4#managed-services | 관리형 예시에 ECS·EKS 묶어 "패치를 AWS가 대신" 일반화(EC2 기반 워커 노드는 고객 책임) | 중 | B | Y |
| DOC-CLF-003 | CLF | clf/t2-1 용어표 | 서버리스를 "함수 단위 실행"으로 협소 정의(Fargate·S3 등 비함수형 누락) | 중 | A | Y |
| DOC-CLF-103 · DOC-CLF-104 · DOC-CLF-206 · DOC-CLF-303 · DOC-SAA-103 〔P8 통합 — 7개 문서 공통〕 | CLF+SAA | clf/t2-2·t2-3·t3-3·t3-5·t3-7·t3-8 각 #pitfalls + saa/saa-t2-1 함정 1 | "(원리: §N)" 각주가 무번호 보강 절 또는 오번호를 가리킴 — 섹션 번호 누락에서 파생된 내부 참조 불일치(사실 오류 아님, 생산 파이프라인 공통 결함). 수정 방식 통일 권장(절 번호 부여 또는 절 이름 참조) | 높 | A/B | N |
| DOC-CLF-105 | CLF | clf/t3-1#connectivity 표·시험 포인트 | VPN "빠르고 저렴" — '구축이 빠름'으로 정밀화 필요(성능 오독 소지) | 높 | A | N |
| DOC-CLF-106 · DOC-CLF-205 · DOC-SAA-306 〔P9 통합 — 단종·신규중단 메모 비일관〕 | CLF+SAA | clf/t3-1(CodeCommit 행)·clf/t3-6#hybrid-backup(FSx File GW)·saa/saa-t3-9 §10(Snowmobile·Snowcone) | 신규 고객 중단(CodeCommit 2024-07)·중단 파악(FSx File GW)·단종(Snowmobile·Snowcone 2024) 서비스에 정직성 메모 부재 — 같은 문서군이 Audit Manager·Forecast에는 메모를 단 관례와 비대칭. 편집 방침 일괄 결정 사안 | 높/중 | B | Y(205·306)·N(106) |
| DOC-CLF-302 | CLF | clf/t3-8#appstream-mq | "AppStream 2.0 = Amazon WorkSpaces Applications 개명" — 감사자 컷오프(2026-01) 밖 주장, 라이브 확인 필요(신·구 병기라 시험 위험 낮음) | 낮 | B | Y |
| DOC-CLF-304 | CLF | clf/t3-8#other-services | 묶음명 "고객 지원" — C02 가이드 공식 범주명은 "고객 참여(Customer Engagement)" | 중 | A | Y |
| DOC-CLF-306 | CLF | clf/t4-1 용어표 Glacier 행 | "복원에 수 분~수 시간" 일반화 — Instant Retrieval(밀리초)·Deep Archive(12~48h) 클래스 한정 필요 | 높 | A | Y |
| DOC-CLF-307 | CLF | clf/t4-1#purchase-options | Dedicated Instances 미언급(누락) — Hosts vs Instances 구분이 CLF 단골 함정 | 높 | B | N |
| DOC-CLF-310 | CLF | clf/t4-3#support-plans 정직성 메모 | "Business Support+·2027-01-01 단종 재편" — 컷오프 밖 주장, 실재 확인 필요(오류 단정 아님) | 낮 | B | Y |
| DOC-CLF-311 | CLF | clf/t4-3#support-plans·학습 목표 | "가이드가 전통 4분류 명시" 확정 불가 + Enterprise On-Ramp 미취급 | 낮 | B | Y |
| DOC-SAA-003 | SAA | saa/saa-t1-2 §3 | 리전 차단 SCP 예시에 글로벌 서비스 NotAction 예외 부재(IAM 호출까지 차단되는 부작용 승인) | 높 | B | Y |
| DOC-SAA-004 | SAA | saa/saa-t1-2 §2 | Audit 계정 "읽기 전용" — Control Tower 정의는 read/write | 중 | B | Y |
| DOC-SAA-008 | SAA | saa/saa-t1-4 §1 | "첫 매칭 규칙 액션 실행" 일반화 — Count는 비종결 액션(계속 평가) | 높 | A | Y |
| DOC-SAA-009 | SAA | saa/saa-t1-4 §1 표 | Rate-based "5분 또는 1분" — 현행 평가 윈도우 1·2·5·10분 4종 | 중 | B | Y |
| DOC-SAA-011 | SAA | saa/saa-t1-5 §2 인용부 | "암호화된 상태로 KMS를 벗어나지 않음" — 원문 "never leave unencrypted"의 방향 뒤집힌 번역 | 높 | A | Y |
| DOC-SAA-012 | SAA | saa/saa-t1-5 §2 표 | AWS 관리형 키 행 "(AWS 소유)" — 별도 유형 'AWS 소유 키'와 용어 충돌 | 높 | A | Y |
| DOC-SAA-013 | SAA | saa/saa-t1-5 §4 | "FIPS Level 3 → CloudHSM" 결정 규칙 — KMS도 140-3 L3(표 기재)와 상충, 변별 키워드는 전용 HW | 중 | B | Y |
| DOC-SAA-014 | SAA | saa/saa-t1-5 §7 | Vault Lock 쿨다운 "기본 3일" — ChangeableForDays는 최소 3일 지정 필수 파라미터(기본값 아님) | 중 | B | Y |
| DOC-SAA-015 | SAA | saa/saa-t1-5 §7 | AWS Backup 지원 목록에 EKS — 공식 목록에서 미확인(2단 검증 필수) | 낮 | B | Y |
| DOC-SAA-102 | SAA | saa/saa-t2-1 §4·함정 3 | "SNS가 제한된 횟수만 재시도 후 버림" — 유실 지점은 Lambda 비동기 큐(재시도 2회·6h), SNS 재시도는 23일 | 중 | B | Y |
| DOC-SAA-108 | SAA | saa/saa-t2-3 §1 표 CLB 행 | "기존 EC2-Classic 환경만" — EC2-Classic은 2023년 완전 폐지된 환경 | 높 | A | Y |
| DOC-SAA-110 | SAA | saa/saa-t2-4 §4·§5 | "스탠바이 읽기 불가" 무조건 서술 — Multi-AZ DB 클러스터(읽기 가능 스탠바이 2) 별도 존재 | 중 | B | N |
| DOC-SAA-203 | SAA | saa/saa-t3-2 §6 표 | EFS 클래스 구 4분류 — 2023-11 Archive 출시 후 재편 미반영 | 중 | B | Y |
| DOC-SAA-204 | SAA | saa/saa-t3-2 §7(+§8 표) | FSx for OpenZFS 클라이언트 "Linux·macOS" — Windows 누락(공식은 3종 모두) | 중 | A | Y |
| DOC-SAA-205 | SAA | saa/saa-t3-3 §2 표 | Hpc8a·M8i·R8i·X8i 등 실재 미확인 인스턴스명 — 신뢰성 문제(시험 영향 없음) | 낮 | B | Y |
| DOC-SAA-207 | SAA | saa/saa-t3-4 §3 표 | ECS Task "일회성 작업" 단정 — 바로 아래 Service 행과 상충(standalone 한정 사실) | 높 | A | N |
| DOC-SAA-211 | SAA | saa/saa-t3-5 §5 표 | "수냔샷(수동)" 오타 | 높 | A | N |
| DOC-SAA-213 | SAA | saa/saa-t3-5 §9 원리 | "실행마다 새 프로세스 기동" 과장 — 웜 실행 환경 재사용, 같은 문서 Q5와 불일치 | 높 | A | N |
| DOC-SAA-303 | SAA | saa/saa-t3-8 §3 | "TGW 연결 시 터널당 최대 5Gbps" — 표준은 1.25Gbps+ECMP 집계, 신기능 실재 확인 필요 | 낮 | B | Y |
| DOC-SAA-304 · DOC-SOA-310 〔P6 통합 — SAA·SOA 양쪽 발견〕 | SAA+SOA | saa/saa-t3-8 §4·§6·시험 포인트·함정 2(4곳) + soa/soa-t5-2 §4·시험 포인트·함정 6·Q4(4곳) | 암호화 패턴 명칭 "DX over VPN" — 설명("DX 위에 VPN")과 명칭의 층위가 반대. 관례 명칭은 "VPN over Direct Connect". 두 cert 합계 8곳 일괄 자구 통일 | 높 | A | N |
| DOC-SAA-306 → P9 통합(상단 CLF-106 행 참조) | — | — | — | — | — | — |
| DOC-SAA-307 | SAA | saa/saa-t3-6 Q5 | "프로비저닝 처리량이 파티션 수로 균등 분배" — adaptive capacity가 자동 재배분(구형 모델), 실원인은 파티션당 하드 한도 | 중 | B | Y |
| DOC-SAA-308 | SAA | saa/saa-t3-8 §6 표 | DX "일관됨(SLA 보장)" — SLA는 가용성 기준, 대역폭·지연 보장 아님 | 높 | A | Y |
| DOC-SAA-404 | SAA | saa/saa-t4-1 시험 포인트·§4 표 | 미연결 EBS 탐지 도구로 Cost Explorer 병기 — TA 비용 점검 항목(CE는 분석·시각화) | 중 | A | Y |
| DOC-SAA-405 | SAA | saa/saa-t4-1 §5 표 1행 | "같은 AZ 내 EC2↔S3 무료" — S3는 리전 서비스(같은 리전 무료), AZ 조건 묶음이 오독 유발 | 높 | A | N |
| DOC-SAA-407 | SAA | saa/saa-t4-3 §2(+Q5) | RDS RI "속성 하나라도 다르면 미적용" 절대 단정 — 일부 엔진 사이즈 유연성 예외 | 중 | B | Y |
| DOC-SAA-412 | SAA | saa/saa-t4-5 §4 | CUR 세부 수치(Support 비용 월 6~7일 반영·100만 행 분할) 오프라인 대조 불가 — 재대조 필요 | 낮 | B | Y |
| DOC-SOA-004 | SOA | soa/soa-t1-1 함정 5 | "고해상도 지표·경보는 추가 비용" — 경보만 고가(0.10→0.30 USD), 지표 단가는 동일 | 중 | A | Y |
| DOC-SOA-005 | SOA | soa/soa-t1-2 §7 | "고대수(custom)" 의미 불명 오탈자 → "사용자 지정(custom)" | 높 | A | N |
| DOC-SOA-006 · DOC-SOA-316 〔P7 통합 — SOA 2개 문서〕 | SOA | soa/soa-t1-2 §4 표·시험 포인트 + soa/soa-t5-4 §1 표 | "Kinesis Data Firehose" 구명칭 — 2024-02 "Amazon Data Firehose"로 리브랜딩. SOA-C03(2025-09 출시) 문항은 신명칭 가능성 — "Amazon Data Firehose(구 Kinesis Data Firehose)" 병기 | 중/높 | A | Y |
| DOC-SOA-007 | SOA | soa/soa-t1-4 §3 | "EBS·연결 상태 확인" — 가운뎃점 탓에 2개 검사로 읽힘(실제는 Attached EBS 단일 검사) | 중 | A | Y |
| DOC-SOA-102 | SOA | soa/soa-t2-1 §5 | 수명주기 훅 "기본 1시간(최대 48시간)" — 타임아웃 설정 상한은 2시간, 48h는 하트비트 연장 총상한 | 중 | A | Y |
| DOC-SOA-103 | SOA | soa/soa-t2-1 §6 | 유예 기간 "기본 300초" — 콘솔 기본 300초, CLI/API 기본 0초 | 중 | A | Y |
| DOC-SOA-104 | SOA | soa/soa-t2-1 용어표 | "Connection Draining"은 CLB 용어 — ALB/NLB 공식 명칭 deregistration delay 병기 필요 | 높 | A | N |
| DOC-SOA-105 | SOA | soa/soa-t2-1 §7 표 | "GLB" 약칭 — 공식 약칭 GWLB | 높 | A | N |
| DOC-SOA-107 | SOA | soa/soa-t2-3 §1 | Backup 일정 "(cron/rate)" — ScheduleExpression은 cron(+콘솔 프리셋), rate 지원 미확인 | 중 | A | Y |
| DOC-SOA-109 | SOA | soa/soa-t2-4 §6 표 | Global Tables "최종 일관성" 단정 — 멀티 리전 강한 일관성(MRSC, 2025 GA) 옵션으로 구식화 가능 | 낮 | B | Y |
| DOC-SOA-202 | SOA | soa/soa-t3-1 §7 원리 | "Snapshot 미지원 리소스 지정 시 오류 반환" 단정 — 공식 문서에서 명시 확인 안 됨 | 낮 | B | Y |
| DOC-SOA-204 | SOA | soa/soa-t3-1 §5(+시험 포인트·함정 3) | "StackSets = 다중 계정 × 다중 리전 (전용)" — 단일 계정×다중 리전도 표준 사용 | 높 | A | Y |
| DOC-SOA-205 | SOA | soa/soa-t3-1 §7 인용 | 인용 번역 자구 훼손("보존하거나(백업) 백업할지") — 원문 "preserve, and in some cases, backup" | 높 | A | N |
| DOC-SOA-207 | SOA | soa/soa-t3-3 §4 + soa-t3-2 §5 | 태그 키 "`Patch Group`만 인식" 배타 단정 — 공백 없는 `PatchGroup`도 지원(2개 문서 공통) | 중 | A | Y |
| DOC-SOA-208 | SOA | soa/soa-t3-3 §7 | "교차 계정 공유가 핵심이면 Secrets Manager" — Parameter Store 고급 파라미터 RAM 공유(2024) 지원으로 차별점 약화 | 중 | B | Y |
| DOC-SOA-209 | SOA | soa/soa-t3-4 용어표 | cron 5필드 정의 — 이 문서 유일 맥락인 EventBridge는 연도 포함 6필드(5필드는 생성 실패) | 높 | A | Y |
| DOC-SOA-210 | SOA | soa/soa-t3-4 §5 예 3 | 루트 로그인 이벤트 파이프라인에 리전 전제 누락 — aws.signin은 us-east-1 버스에만 도착 | 중 | B | Y |
| DOC-SOA-213 | SOA | soa/soa-t4-1 Q5 답 | 관리 계정을 "루트 계정"으로 지칭 — 루트 사용자와 용어 충돌(SCP 맥락이라 위험 상대적 큼) | 높 | A | N |
| DOC-SOA-303 | SOA | soa/soa-t4-2 §3 | GuardDuty 기본 소스 "CloudTrail(관리/데이터 이벤트)" — S3 데이터 이벤트는 S3 Protection 플랜 소속(기본/플랜 경계 흐림) | 중 | A | Y |
| DOC-SOA-309 | SOA | soa/soa-t5-1 §5 표 | NAT GW "최대 수십 Gbps" — 현행 공식 100Gbps(구 45Gbps 시절 흔적) | 중 | B | Y |
| DOC-SOA-314 | SOA | soa/soa-t5-3 §6·함정 5 | "잦은 전체 무효화는 비용 큼" — `/*` 와일드카드는 1경로 과금(월 1,000경로 무료), 실 문제는 캐시 적중률·오리진 부하 | 높 | A | Y |
| GUIDE-003 | GUIDE | assets/exam_guides/CLF-C02.json task 3.7 | 예시 "Amazon SageMaker" — 현행 공식 가이드는 "Amazon SageMaker AI"로 갱신됨(그 외 CLF 전 태스크 1:1 일치) | 높 | A | Y |

## 교차 패턴 (여러 샤드 공통 발견 계열)

### 통합 계열 (중복 카운트 제거 대상, 9계열 22 ID → 9건)

| # | 계열명 | 관련 ID(심각도) | 성격 |
|---|---|---|---|
| P1 | **Aurora 최대 스토리지 256TiB** | DOC-SAA-209(H) + DOC-SAA-406(H) | saa-c(t3-5)·saa-e(t4-3) **2개 샤드 독립 발견** — 동일 문구 "(2025년 상향, 구버전 128TiB)" 동반, 동일 환각 소스(생성 시점 공통 오류) 의심. 공식 128TiB. 컨트롤러 지시 컨텍스트상 questions.json에도 동일 수치 침투 보고(문항 감사 차원). 2단 검증 최우선 |
| P2 | **Cost Explorer 예측 18개월** | DOC-CLF-308(M) + DOC-SAA-410(M) | **cert 경계를 넘어** CLF t4-2와 SAA t4-5(4곳)에 동일 수치 오류 — 공식 12개월. cert 간 콘텐츠 생성 공통 오류의 두 번째 물증 |
| P3 | **KMS 키 정책·IAM "교집합/둘 다 Allow"** | DOC-SAA-010(M) + DOC-SOA-305(M) | SAA t1-5(3개소)·SOA t4-3(3개소) 동일 오개념 모델 — 키 정책 단독 허용 가능이 정확. 두 문서 동일 방향 재서술 필요 |
| P4 | **S3·DynamoDB Interface Endpoint 부재 프레임** | DOC-SAA-006(H) + DOC-SOA-311(M) | "Interface는 S3·DDB 외"/"게이트웨이=S3·DDB 전용, 나머지 인터페이스" — S3(2021)·DDB(2024) Interface 지원 + 게이트웨이 VPC 내부 전용 제약 누락. soa-d 샤드가 "병렬 SAA 감사 지적과 동일 계열"로 자체 인지 |
| P5 | **Geoproximity = Traffic Flow 전용 단정** | DOC-SAA-302(M) + DOC-SOA-312(M) | SAA t3-7(3회)·SOA t5-3(3곳) 공통 — 현행은 일반 레코드 직접 지원. **단 두 샤드의 근거 시점이 상이(SAA: 2024-02 일반 레코드 / SOA: 2023-11 콘솔 직접 지원) → 2단 검증에서 정확한 변경 시점을 확정해 두 문서에 일관 반영** |
| P6 | **"DX over VPN" 표기 역전** | DOC-SAA-304(L) + DOC-SOA-310(L) | SAA t3-8(4곳)·SOA t5-2(4곳) — 설명은 옳고 명칭 층위만 반대. 관례 명칭 "VPN over Direct Connect"로 8곳 일괄 자구 통일 |
| P7 | **Kinesis Data Firehose 구명칭** | DOC-SOA-006(L) + DOC-SOA-316(L) | SOA t1-2·t5-4 — 2024-02 "Amazon Data Firehose" 개명. 신·구 병기로 일괄 처리 |
| P8 | **"(원리: §N)" 참조 깨짐 — 무번호 보강 절 패턴** | DOC-CLF-103(L)·DOC-CLF-104(L)·DOC-CLF-206(L, 3문서)·DOC-CLF-303(L) + DOC-SAA-103(L) | clf t2-2·t2-3·t3-3·t3-5·t3-7·t3-8 + saa t2-1 = **7개 문서 공통 생산 파이프라인 결함**(번호 없는 보강 절 삽입 → 함정 각주의 §번호 어긋남). 사실 오류 아님 — 수정 방식(절 번호 부여 vs 절 이름 참조)을 한 번 정해 일괄 적용 |
| P9 | **단종·신규중단 서비스 정직성 메모 비일관** | DOC-CLF-106(L)·DOC-CLF-205(L) + DOC-SAA-306(L) | CodeCommit(메모 부재)·FSx File Gateway(무주석)·Snowmobile/Snowcone(단종 미반영) — Audit Manager·Forecast에는 메모를 단 관례와 비대칭. 편집 방침(메모 형식·범위) 일괄 결정 사안. ※연도 오류인 DOC-CLF-101(M)은 사실 정정 건이라 별도 유지 |

### 느슨한 계열 (통합 카운트 미포함 — 검증·수정 시 함께 다루면 효율적)

- **루트 사용자·SCP 적용 경계**: DOC-CLF-102(H, Support 플랜 루트 전용) · DOC-SAA-001(M, 관리 계정 예외 축소) · DOC-SOA-212(M, "SCP 우회" 오독) — 셋 다 "루트 전용 작업 목록/SCP 적용 범위"의 경계 서술 문제. 현행 root-only 공식 목록 1회 확정으로 3건 동시 처리 가능.
- **EBS gp2/gp3 수치·모델**: DOC-SAA-202(M, gp3 상향 수치 vs 시험 관례) · DOC-SAA-210(H, gp3 버스트 크레딧 오기) · DOC-SOA-009(H, gp2 도달 용량 3,334GB) — gp2/gp3 스펙 표 하나로 교차 검증 가능.
- **감사자 컷오프(2026-01) 밖 최신 주장 — 확신도 '낮' 그룹**: DOC-CLF-302(WorkSpaces Applications 개명) · DOC-CLF-310/311(Business Support+ 재편·On-Ramp) · DOC-SAA-303(터널당 5Gbps) — 오류 단정이 아닌 검증 불가 건. 2단 검증에서 라이브 확인 시 오히려 문서가 옳을 수 있음(문서 lastVerified가 컷오프 이후).
- **2023~2025 신기능·변경 미반영(구식화) 클러스터**: KDS 온디맨드(SAA-305) · GuardDuty Critical(SOA-302) · TA 6범주(SOA-304) · Route 53 8종(SOA-313) · RDS RR 15개(SAA-208) · EFS Archive(SAA-203) · Patch Group 태그(SOA-207) · Parameter Store RAM 공유(SOA-208) · TGW 교차 AZ 무료화(SAA-409) · EC2-Classic 폐지(SAA-108) · NAT 100Gbps(SOA-309) · MRSC(SOA-109) · Multi-AZ DB 클러스터(SAA-110) — "현행 사실 vs 시험 관례" 병기 방침을 한 번 정해 일괄 적용 권장.

### 샤드 간 판단 불일치·교차 지지 (2단 검증 참고)

- **Route 53 라우팅 정책 개수**: soa-d는 "7종" 단정을 M(현행 8종)으로 지적(DOC-SOA-313), 반면 saa-d는 saa-t3-7의 "라우팅 정책 7종"을 이상 없음으로 판정 — 검증 확정 결과에 따라 saa-t3-7 재점검 여부 결정 필요(새 발견 아님, 기존 판정 간 대조).
- **CLF 도메인 비중(DOC-CLF-002)**: 03-exam-guides 샤드가 공식 가이드 24/30/34/12를 축자 대조로 확인 — 발견의 근거를 독립 샤드가 교차 지지(확신도 상향 근거).
- **음성 교차 검증(오류 비전파 확인)**: NAT GW "자동 HA"(SAA-005)는 soa-b·soa-d에서 SOA 문서 무결 확인 / CRR "버전 관리 지원"(SAA-109)은 soa-b에서 SOA 무결 확인 / SP 72%/66% 결합(CLF-305)은 saa-e에서 SAA 무결 확인 — cert 간 오류 전파는 제한적이나, P1·P2처럼 cert를 넘는 동일 오류 2계열이 실존.

## 사실의심 Y 전수 목록 (2단 반박 검증 P12 입력)

**총 109건**(CLF 19 · SAA 48 · SOA 39 · GUIDE 3). 통합 계열 소속은 〔P#〕로 표기. 확신도 분포: 높 66 · 중 33 · 낮 10.

| ID | 심각도 | 위치 | 주장 요지(문서 주장 → 의심 논점) | 발견자 근거 | 확신도 |
|---|---|---|---|---|---|
| DOC-CLF-001 | L | clf/t1-4#managed-services | ECS·EKS 포함 "패치·백업 등을 AWS가 대신" → EC2 기반 워커 노드 OS 패치는 고객 책임 | 공동 책임·EKS/ECS 보안 문서 — AWS 담당은 컨트롤 플레인(Fargate만 노드 패치 이동) | 중 |
| DOC-CLF-002 | M | clf/t2-1 「왜 중요한가」 | "도메인 2가 30%로 최대" → 최대는 D3 34% | C02 공식 비중 24/30/34/12 (exam-guides 샤드 축자 확인으로 교차 지지) | 높 |
| DOC-CLF-003 | L | clf/t2-1 용어표 | 서버리스="함수 단위 실행 모델" → FaaS 협소 정의 | AWS serverless 페이지가 Fargate·SQS·SNS·DynamoDB·S3 등 비함수형 포함 | 중 |
| DOC-CLF-101 | M | clf/t2-2#audit-trio §6 | Audit Manager 신규 중단 "2024년 이후" → 2026-04-30 | 공식 availability change 페이지 명시(2024-07 중단 배치와 혼동 추정) | 높 |
| DOC-CLF-102 | H | clf/t2-3#root-user(3개소) | "Support 플랜 변경·취소=루트 전용" → 현행 목록에 없음 | IAM id_root-user.html 2026-07 실측 + 2022-09 Support Plans IAM 제어 공지. 레거시 기출 관례는 별도 판단 | 높 |
| DOC-CLF-201 | M | clf/t3-4#dynamodb | "트래픽 없으면 비용 없음" → 스토리지 과금 지속 | DynamoDB 요금: 요청과 스토리지 별도 항목 | 높 |
| DOC-CLF-202 | M | clf/t3-6#ebs | "중지·종료해도 데이터 유지" → 종료 시 루트 볼륨 기본 삭제 | EC2 공식 — DeleteOnTermination 기본 true(루트) | 높 |
| DOC-CLF-203 | M | clf/t3-6 용어표 | 11 9s="1,000만 개 중 1개 미만 손실" → 기간(1만 년) 누락 왜곡 | S3 공식 durability 예시 "once every 10,000 years" | 높 |
| DOC-CLF-204 | M | clf/t3-3#ec2 | 서버 대수 증감을 "scale up/down"으로 → out/in(수평) 오매핑 | AWS 원문은 '용량' 목적어("scale capacity"), 이 문장은 '가상 서버' 목적어 | 중 |
| DOC-CLF-205 | L | clf/t3-6#hybrid-backup 〔P9〕 | Storage Gateway 유형에 FSx File Gateway 무주석 나열 → 신규 고객 중단 의심 | 2024 신규 중단 물결 포함 기억 — 정확 시점·현행 표기 검증 필요 | 중 |
| DOC-CLF-301 | M | clf/t3-8#messaging | "SNS는 저장·재시도 메커니즘 없음" → 재시도 정책·DLQ 존재 | SNS 공식 — SQS·Lambda 엔드포인트 최대 23일 재시도, 전달 완료까지 다중 AZ 보관 | 높 |
| DOC-CLF-302 | L | clf/t3-8#appstream-mq | "AppStream 2.0 = WorkSpaces Applications 개명" → 컷오프 밖 확인 불가 | 2026-01까지 학습 데이터에 개명 공지 부재(문서 lastVerified 2026-06-21은 컷오프 이후 — 문서가 옳을 수 있음) | 낮 |
| DOC-CLF-304 | L | clf/t3-8#other-services | 범주명 "고객 지원" → 공식 범주명 "고객 참여(Customer Engagement)" | C02 가이드 부록 범주명 | 중 |
| DOC-CLF-305 | M | clf/t4-1#purchase-options | SP "최대 72%+패밀리·리전 무관" 결합 → 72%=EC2 Instance SP(고정)·유연=Compute SP 66% | SP 공식 구분(Compute 66% 유연 / EC2 Instance 72% 고정) | 높 |
| DOC-CLF-306 | L | clf/t4-1 용어표 | Glacier "복원 수 분~수 시간" 일반화 → Instant(밀리초)·Deep Archive(12~48h) 존재 | S3 스토리지 클래스 공식 — Glacier 3개 클래스 검색 특성 | 높 |
| DOC-CLF-308 | M | clf/t4-2#cost-tools 〔P2〕 | Cost Explorer "향후 ~18개월 예측" → 공식 12개월 | CE 공식 문서·제품 페이지(과거 13개월+예측 12개월) | 높 |
| DOC-CLF-309 | H | clf/t4-3#support-plans | Enterprise "프로덕션 중요 케이스 15분" → 비즈니스 크리티컬 다운 <15분(프로덕션 다운은 <1h) | Support 플랜 공식 응답 목표 + 문서 자신의 #health-dashboard와 긴장 | 높 |
| DOC-CLF-310 | L | clf/t4-3#support-plans | "Business Support+·2027-01-01 단종 재편" → 컷오프 밖 확인 불가 | 2026-01까지 해당 재편 공지 부재(오류 단정 아님) | 낮 |
| DOC-CLF-311 | L | clf/t4-3#support-plans | "가이드가 전통 4분류 명시" + On-Ramp 미취급 → 가이드 원문 확인 필요 | On-Ramp는 2022 출시로 C02 출제 가능 플랜 | 낮 |
| DOC-SAA-001 | M | saa/saa-t1-1 §7 | SCP 예외="관리 계정의 루트" → 관리 계정 전 주체 미적용 | Organizations 공식 "SCPs do not affect users or roles in the management account" | 높 |
| DOC-SAA-003 | L | saa/saa-t1-2 §3 | 리전 차단 SCP 예시에 글로벌 서비스 예외 부재 → IAM·STS 등 차단 부작용 | Organizations example_scps의 NotAction 예외 관례 | 높 |
| DOC-SAA-004 | L | saa/saa-t1-2 §2 | Audit 계정 "읽기 전용" → read and write | Control Tower userguide accounts 절 | 중 |
| DOC-SAA-005 | H | saa/saa-t1-3 §2 | NAT GW "자동 고가용성" → 단일 AZ 내 이중화뿐 | VPC 공식 "redundancy in that zone" — AZ별 배치가 출제 포인트 | 높 |
| DOC-SAA-006 | H | saa/saa-t1-3 §4 〔P4〕 | "Interface EP 대상: S3·DDB 외" → S3(2021)·DDB(2024) Interface 지원 | PrivateLink for S3 GA 2021-02·DDB PrivateLink 2024 + 문서 내 Q3와 모순 | 높 |
| DOC-SAA-007 | M | saa/saa-t1-4 시험 포인트 | WAF×CloudFront "us-east-1 제한 없음" → CLOUDFRONT 스코프는 us-east-1 생성 | WAF 공식 "must use the Region US East (N. Virginia)" | 높 |
| DOC-SAA-008 | L | saa/saa-t1-4 §1 | "첫 매칭 규칙 액션 실행"(Count 포함) → Count는 비종결 | WAF rule action terminating/non-terminating 구분 | 높 |
| DOC-SAA-009 | L | saa/saa-t1-4 §1 표 | Rate-based "5분 또는 1분" → 현행 1·2·5·10분 | evaluation window 60/120/300/600초 | 중 |
| DOC-SAA-010 | M | saa/saa-t1-5 §2(3개소) 〔P3〕 | "IAM·키 정책 교집합" → 키 정책 단독 허용 가능 | KMS key-policies "with the key policy alone" + t1-1 §3 원리와 모순 | 높 |
| DOC-SAA-011 | L | saa/saa-t1-5 §2 인용 | "암호화된 상태로 벗어나지 않음" → 원문 "never leave unencrypted" 방향 뒤집힘 | KMS 공식 원문 대조 | 높 |
| DOC-SAA-012 | L | saa/saa-t1-5 §2 표 | 관리형 키 "(AWS 소유)" → 별도 유형과 용어 충돌 | KMS 키 3분류 공식(관리형은 사용자 계정 내 리소스) | 높 |
| DOC-SAA-013 | L | saa/saa-t1-5 §4 | "FIPS L3 → CloudHSM" 규칙 → KMS도 140-3 L3 | 2023 KMS FIPS 140-3 L3 인증(문서 자신의 표와 상충) | 중 |
| DOC-SAA-014 | L | saa/saa-t1-5 §7 | Vault Lock 쿨다운 "기본 3일" → 최소 3일 지정 파라미터 | Backup Vault Lock ChangeableForDays min 3 days | 중 |
| DOC-SAA-015 | L | saa/saa-t1-5 §7 | Backup 지원 목록에 EKS → 공식 목록 미확인 | supported-resources 목록에 EKS 부재(최근 추가 여부 불확실) | 낮 |
| DOC-SAA-101 | H | saa/saa-t2-1 Q3 해설 | "SNS는 조건 필터링 없이 Push" → 구독 필터 정책 존재 | SNS Subscription filter policies 공식 + §7과 문서 내 모순 | 높 |
| DOC-SAA-102 | L | saa/saa-t2-1 §4·함정 3 | "SNS가 제한 횟수 재시도 후 버림" → 유실 지점은 Lambda 비동기 큐 | SNS 재시도 10만+회/23일 vs Lambda async 재시도 2회·6h | 중 |
| DOC-SAA-104 | M | saa/saa-t2-2 함정 1 | "Step Functions(Durable Lambda)" → 공식 명칭 부재 | AWS 서비스 목록에 해당 명칭 없음(신기능 지칭 여부 확인) | 중 |
| DOC-SAA-105 | M | saa/saa-t2-3 §1 표 | NLB 프로토콜에 QUIC → 리스너 목록에 없음 | NLB Listeners 공식(TCP·UDP·TCP_UDP·TLS) — 2026 신규 지원 여부 확인 | 중 |
| DOC-SAA-106 | M | saa/saa-t2-3 §2 표 | ALB 대상 그룹에 "다른 ALB" → NLB의 기능(방향 오류) | ALB target type=instance/ip/lambda, "ALB as target"은 NLB 가이드 소속 | 높 |
| DOC-SAA-107 | M | saa/saa-t2-3 §5 표 | NLB "플로우 해시로 자연 고정" → 세션 고정은 source_ip 스티키니스 opt-in | NLB target group attributes stickiness.type=source_ip | 높 |
| DOC-SAA-108 | L | saa/saa-t2-3 §1 표 | CLB "EC2-Classic 환경만" → 2023년 폐지된 환경 | EC2-Classic retirement(2023) 공지 | 높 |
| DOC-SAA-109 | M | saa/saa-t2-5 §4 표 | CRR "버전 관리 지원" → 양측 활성화 필수 전제 | S3 Replication requirements | 높 |
| DOC-SAA-201 | M | saa/saa-t3-1 §5 | S3 접근 "①BPA→②IAM→③버킷 정책→④ACL" 순차 → union 평가+Deny 우선 | IAM 정책 평가 로직(동일 계정 identity OR resource Allow) | 높 |
| DOC-SAA-202 | M | saa/saa-t3-2 §3 | gp3 64TiB·80K IOPS·2,000MiB/s → 현행 여부+시험 관례(16K) 충돌 | re:Invent 2024 상향 발표 기억, 출제 스냅샷은 16K 시절 | 중 |
| DOC-SAA-203 | L | saa/saa-t3-2 §6 표 | EFS 구 4분류 → Archive 포함 재편(2023-11) 미반영 | EFS Archive 출시로 클래스 체계 개편 | 중 |
| DOC-SAA-204 | L | saa/saa-t3-2 §7 | FSx OpenZFS "Linux·macOS" → Windows 누락 | 공식 "accessible from Linux, Windows, and macOS via NFS" | 중 |
| DOC-SAA-205 | L | saa/saa-t3-3 §2 표 | Hpc8a·M8i·R8i·X8i 실재 여부 → 발표 확인 기억 없음 | 2026-01 기준 Hpc7g/7a·M8g·R8g까지 확인 | 낮 |
| DOC-SAA-208 | M | saa/saa-t3-5 §3·§4·§8·Q1 | RDS Read Replica "최대 5개" → 오픈소스 엔진 15개 | RDS User Guide 갱신(MySQL·MariaDB·PostgreSQL 15) — 구 관례 병기 판단 | 중 |
| DOC-SAA-209 | H | saa/saa-t3-5 §7·§8 〔P1〕 | Aurora "256TiB(2025년 상향)" → 공식 128TiB, 상향 근거 미확인 | Aurora 클러스터 볼륨 상한 128TiB·Limitless 혼동 가능성 | 중 |
| DOC-SAA-210 | H | saa/saa-t3-5 §6 | "gp2/gp3 버스트 크레딧" → gp3는 크레딧 없음(3,000 고정) | EBS 공식 — 버스트 버킷 gp2 전용 + saa-t3-2와 샤드 내 모순 | 높 |
| DOC-SAA-301 | H | saa/saa-t3-7 §7+시험 포인트 | "GA를 CloudFront 앞에 붙여 고정 IP+CDN" → GA 엔드포인트에 CloudFront 없음 | GA 엔드포인트 유형(ALB·NLB·EC2·EIP) + CloudFront Anycast Static IP(2024-11) 별도 출시가 방증 | 높 |
| DOC-SAA-302 | M | saa/saa-t3-7 §3(3회) 〔P5〕 | "Geoproximity=Traffic Flow 전용" → 2024-02부터 일반 레코드 직접 지원 | AWS What's New 2024-02 + 현행 문서에 전제 문구 없음(SOA-312와 시점 대조 필요) | 중 |
| DOC-SAA-303 | L | saa/saa-t3-8 §3 | "TGW 연결 시 터널당 최대 5Gbps" → 표준 1.25Gbps+ECMP 집계 | S2S VPN 공식 한도 — 대형 터널 신기능 실재·GA 여부 미확인 | 낮 |
| DOC-SAA-305 | M | saa/saa-t3-9 함정 6+§2 | "샤드 자동 확장 불가" 무조건 → 온디맨드 모드(2021-11) 자동 확장 | KDS capacity mode 공식 — 문서 전체에 온디맨드 언급 없음 | 높 |
| DOC-SAA-306 | L | saa/saa-t3-9 §10 〔P9〕 | Snowcone→Snowball→Snowmobile 현행 라인업 제시 → Snowmobile·Snowcone 2024 단종 | 단종 보도·제품 페이지 개편(기출 관례 가치는 별도) | 중 |
| DOC-SAA-307 | L | saa/saa-t3-6 Q5 | "처리량이 파티션 수로 균등 배분" → adaptive capacity 자동 재배분 | DynamoDB burst/adaptive capacity 문서(균등 분배는 구버전 잔재) | 중 |
| DOC-SAA-308 | L | saa/saa-t3-8 §6 표 | DX "일관됨(SLA 보장)" → SLA는 가용성만(대역폭·지연 아님) | DX SLA 문서 Monthly Uptime Percentage 한정 | 높 |
| DOC-SAA-401 | M | saa/saa-t4-1 §5 표 | 교차 AZ 프라이빗 IP "더 낮은 요율" → 퍼블릭 경유와 동일 | EC2 요금 — 양쪽 모두 방향당 $0.01/GB | 높 |
| DOC-SAA-402 | M | saa/saa-t4-1 §2 | "128KB 미만은 모니터링 요금이 절감액 초과" → 미만은 비대상·비과금 | 2021-09 이후 128KB 미만 모니터링 제외 공식(리스크 주체는 128KB 이상 소형 객체) | 높 |
| DOC-SAA-403 | M | saa/saa-t4-1 §7 | Storage Class Analysis=Storage Lens 하위 기능 → 별개(S3 Analytics) | S3 Analytics 별도 기능(버킷/프리픽스 단위 설정) | 높 |
| DOC-SAA-404 | L | saa/saa-t4-1 시험 포인트·§4 | 미연결 EBS 탐지에 Cost Explorer → TA 비용 점검 항목 | CE는 분석·시각화 도구(식별 기능 없음), t4-5 §8 역할 구분과 어긋남 | 중 |
| DOC-SAA-406 | H | saa/saa-t4-3 §3 〔P1〕 | Aurora "256TiB(2025년 상향)" → 128TiB(구엔진 64TiB) | 2020년 64→128 패턴 한 단계 상향 환각 또는 Limitless 혼동 의심 | 중 |
| DOC-SAA-407 | L | saa/saa-t4-3 §2 | RDS RI "속성 하나라도 다르면 미적용" → 사이즈 유연성 예외 | 오픈소스 엔진 RI의 동일 패밀리 size flexibility | 중 |
| DOC-SAA-408 | M | saa/saa-t4-4 §2+시나리오 | NAT 경유 same-region S3 "아웃바운드 요금 가산" → 무료(NAT 처리요금만) | 같은 리전 EC2↔S3 경로 무관 무료 + t4-1 §5와 샤드 내 불일치 | 높 |
| DOC-SAA-409 | M | saa/saa-t4-4 §5+시나리오 | TGW 교차 AZ $0.01/GB 가산($0.03 합계) → 2022-04 무료화 | TGW·PrivateLink·Client VPN 리전 내 교차 AZ 전송 무료화 공지 | 중 |
| DOC-SAA-410 | M | saa/saa-t4-5(4곳) 〔P2〕 | CE "미래 18개월 예측" → 공식 12개월(이력 13개월은 정확) | CE 공식 문서 기준 | 중 |
| DOC-SAA-411 | H | saa/saa-t4-5 §3 | Budget Actions "IAM·SNS·SSM Automation" → 공식은 IAM 정책·SCP·EC2/RDS 중지 | Budgets actions 공식 3유형(SNS는 알림 채널, SSM은 액션 아님) | 높 |
| DOC-SAA-412 | L | saa/saa-t4-5 §4 | CUR "Support 비용 월 6~7일 반영"·"100만 행 분할" → 대조 필요 세부치 | 오프라인 대조 불가 비정형 수치 | 낮 |
| DOC-SOA-002 | H | soa/soa-t1-1 §4 | EventBridge=경보 작업 대상 + Lambda 직접 작업 누락 → ARN 목록과 불일치 | PutMetricAlarm AlarmActions 허용 ARN(EC2·ASG·SNS·SSM·Lambda), EventBridge는 자동 발행 통합 | 높 |
| DOC-SOA-003 | M | soa/soa-t1-1 §4 SSM 행 | 경보 작업 "런북 실행" → 직접 작업은 OpsItem·인시던트 2종 | CloudWatch 경보 SSM 작업 ARN opsitem·response-plan | 중 |
| DOC-SOA-004 | L | soa/soa-t1-1 함정 5 | "고해상도 지표·경보 추가 비용" → 지표 단가는 해상도 무관 동일 | CW 요금표 — 경보만 0.10→0.30 USD 차등 | 중 |
| DOC-SOA-006 | L | soa/soa-t1-2 §4 〔P7〕 | "Kinesis Data Firehose" → 2024-02 Amazon Data Firehose 개명 | AWS 공식 리브랜딩 공지 — SOA-C03 문항 신명칭 가능성 | 중 |
| DOC-SOA-007 | L | soa/soa-t1-4 §3 | "EBS·연결 상태 확인" 2개처럼 표기 → Attached EBS 단일 검사 | EC2 상태 확인 3종(system/instance/attached EBS) | 중 |
| DOC-SOA-008 | M | soa/soa-t1-4 함정 4·§4 | "인스턴스 스토어 데이터 유실 가능"(복구 전제) → recover는 EBS 전용 인스턴스만 | EC2 인스턴스 복구 요구사항(EBS-only) | 중 |
| DOC-SOA-009 | H | soa/soa-t1-5 §2 | gp2 16,000 IOPS 도달 "≈3,334GB" → ≈5,334GiB | 산술 3,334×3≈10,000≠16,000 + EBS 볼륨 유형 문서 | 높 |
| DOC-SOA-101 | M | soa/soa-t2-1 §4 표 | 워밍업이 "상태 확인 제외"까지 → 유예 기간의 역할(별도 설정) | default instance warmup 문서 — 집계 지표 제외만, grace period 비대체 명시 | 중 |
| DOC-SOA-102 | L | soa/soa-t2-1 §5 | 훅 "기본 1시간(최대 48시간)" → 타임아웃 상한 2시간, 48h는 하트비트 연장 | PutLifecycleHook HeartbeatTimeout 30–7200s | 중 |
| DOC-SOA-103 | L | soa/soa-t2-1 §6 | 유예 기간 "기본 300초" → CLI/API 기본 0초 | CreateAutoScalingGroup HealthCheckGracePeriod "Default: 0" | 중 |
| DOC-SOA-106 | M | soa/soa-t2-2 §4 원리 | "AZ 전체 비정상 → 그 AZ 노드 트래픽 중단" → cross-zone 비활성 전제 메커니즘 | ALB 기본 cross-zone 활성 시 노드가 타 AZ로 우회 라우팅 + t2-1 §7과 긴장 | 중 |
| DOC-SOA-107 | L | soa/soa-t2-3 §1 | Backup 일정 "(cron/rate)" → rate 지원 미확인 | ScheduleExpression "A cron expression in UTC" — rate 언급 없음 | 중 |
| DOC-SOA-109 | L | soa/soa-t2-4 §6 표 | Global Tables "최종 일관성" 단정 → MRSC(2025 GA) 옵션 존재 | Global Tables 강한 일관성 옵션 인지 — 시점·시험 반영 확인 필요 | 낮 |
| DOC-SOA-201 | M | soa/soa-t3-1 §3+Q5 | 생성 실패 기본="스택 제거" → ROLLBACK_COMPLETE 잔존 | CLI --on-failure 기본 ROLLBACK, 실패 스택 삭제만 가능 | 높 |
| DOC-SOA-202 | L | soa/soa-t3-1 §7 | "Snapshot 미지원 리소스 지정 시 오류" 단정 → 공식 명시 미확인 | DeletionPolicy 문서에 해당 단정 문장 기억 부재 | 낮 |
| DOC-SOA-203 | M | soa/soa-t3-1 §7·함정 2·Q4 | RDS 기본 DeletionPolicy=Delete 단정 → DBCluster 등 기본 Snapshot 예외 | CFN DeletionPolicy 공식 RDS 예외 노트 + 문서 내 표("대부분")와 온도차 | 중 |
| DOC-SOA-204 | L | soa/soa-t3-1 §5 | "StackSets=다중 계정×다중 리전 전용" → 단일 계정 다중 리전도 표준 | StackSets 공식 정의 + 셀프 관리형 자기 계정 배포 지원 | 높 |
| DOC-SOA-206 | M | soa/soa-t3-2 §2 | "암호화 AMI 공유=키 공유" → 기본 관리형 키 암호화본은 공유 불가 | EC2 공식 "can't share an AMI backed by snapshots encrypted with the default AWS managed key" | 높 |
| DOC-SOA-207 | L | soa/soa-t3-3 §4+t3-2 §5 | 태그 키 "`Patch Group`만" → `PatchGroup`도 지원 | SSM patch groups 공식 병기 | 중 |
| DOC-SOA-208 | L | soa/soa-t3-3 §7 | "교차 계정 공유=Secrets Manager 차별점" → Parameter Store RAM 공유(2024) | 2024-02 advanced tier cross-account sharing 출시 | 중 |
| DOC-SOA-209 | L | soa/soa-t3-4 용어표 | cron 5필드 → EventBridge는 6필드(연도)+`?` 규칙 | EventBridge 스케줄 표현식 공식(6필드 필수) | 높 |
| DOC-SOA-210 | L | soa/soa-t3-4 §5 예 3 | 루트 로그인 규칙 리전 무관 서술 → aws.signin은 us-east-1 버스 한정 | 지식 센터 루트 활동 모니터링 가이드(us-east-1 규칙 안내) — 사양 변동 확인 | 중 |
| DOC-SOA-211 | M | soa/soa-t4-1 §1 표 | 인라인 정책 대상 "사용자·역할" → 그룹 포함 | IAM 공식 "user, group, or role" + PutGroupPolicy API | 높 |
| DOC-SOA-212 | M | soa/soa-t4-1 §7 | 루트 전용에 "특정 S3/SCP 우회" → 루트도 SCP 적용(문서 내 정면 모순) | Organizations 공식 "including the root user" — 의도는 S3 MFA Delete 등으로 추정 | 높 |
| DOC-SOA-301 | M | soa/soa-t4-2 §1 | Config "지속 평가"(변경 시 아님) 프레임 → 변경/주기 2유형 | Config 규칙 trigger type 구분 + 같은 절 운영 흐름과 상충 | 높 |
| DOC-SOA-302 | M | soa/soa-t4-2 §3 | GuardDuty "Low/Medium/High" → Critical 포함 4단(2024-12~) | findings severity levels 문서 Critical 존재 | 중 |
| DOC-SOA-303 | L | soa/soa-t4-2 §3 | 기본 소스 "CloudTrail(관리/데이터)" → 데이터 이벤트는 S3 Protection 소속 | foundational 소스=관리 이벤트·Flow Logs·DNS 로그 | 중 |
| DOC-SOA-304 | M | soa/soa-t4-2(3곳) | TA "5개 범주" → 운영 우수성 포함 6범주(2022-11~) | check reference 카테고리 6종 — 구 관례 유지 여부 사람 결정 | 높 |
| DOC-SOA-305 | M | soa/soa-t4-3 §1(3개소) 〔P3〕 | "키 정책+IAM 둘 다 Allow(교집합)" → 키 정책 직접 허용이면 IAM 불요 | KMS key-policies — "IAM 단독 불충분"은 참이나 교집합 아님 | 높 |
| DOC-SOA-306 | M | soa/soa-t4-3 §7 | 갱신 불가 사유="개인 키가 ACM 외부" → import는 키 업로드 필수 | ACM 가져오기 절차(개인 키 필수 입력) — 실사유는 외부 CA 재발급 불가 | 높 |
| DOC-SOA-307 | M | soa/soa-t4-3 §7 | "자동 갱신(DNS/이메일 유효 시)" → 이메일 검증은 소유자 대응 필요 | ACM managed renewal — email-validated 소유자 응답 요건 | 높 |
| DOC-SOA-308 | M | soa/soa-t5-1 §7 | 프라이빗 DNS 요건=enableDnsSupport만 → enableDnsHostnames도 필요 | Route 53 PHZ·PrivateLink 프라이빗 DNS 요건(두 속성 모두 true) + t5-3과 불일치 | 높 |
| DOC-SOA-309 | L | soa/soa-t5-1 §5 표 | NAT GW "최대 수십 Gbps" → 현행 100Gbps | vpc-nat-gateway "scales up to 100 Gbps"(구 45Gbps 흔적) | 중 |
| DOC-SOA-311 | M | soa/soa-t5-2 §5·함정 4 〔P4〕 | "게이트웨이=S3·DDB 전용, 나머지 인터페이스" → S3·DDB 인터페이스 EP 존재+게이트웨이 VPC 전용 누락 | PrivateLink S3/DDB 인터페이스 EP 문서 + 게이트웨이 온프레미스 확장 불가 제약 | 높 |
| DOC-SOA-312 | M | soa/soa-t5-3(3곳) 〔P5〕 | "Geoproximity=Traffic Flow에서만" → 2023-11부터 콘솔 직접 생성 지원 | What's New 2023-11 + 현행 문서 전제 없음(SAA-302와 시점 대조 필요) | 중 |
| DOC-SOA-313 | M | soa/soa-t5-3(3곳) | "라우팅 정책 7종" → IP-based(2022-06) 포함 8종 | 문서가 인용한 routing-policy.html 자체가 8항목 나열 | 높 |
| DOC-SOA-314 | L | soa/soa-t5-3 §6·함정 5 | "전체 무효화=고비용" → `/*`는 1경로 과금(월 1,000경로 무료) | CloudFront Invalidation 과금 — 단일 파일과 `/*` 제출 비용 동일 명시 | 높 |
| DOC-SOA-315 | H | soa/soa-t5-4 전반 | "SG 거부는 REJECT로 안 남음" → REJECT=SG 또는 NACL 불허 | 공식 action 정의 + flow-logs-records-examples의 SG 거부 REJECT 기록 예시 | 높 |
| DOC-SOA-316 | L | soa/soa-t5-4 §1 표 〔P7〕 | "Kinesis Data Firehose" → Amazon Data Firehose(2024-02) | AWS 개명 공지 | 높 |
| GUIDE-001 | M | assets/exam_guides/SOA-C03.json | JSON이 v1.0 문구 → 공식 v1.1(2026-06-01) 개정(스킬 11건+in-scope 5종) | 공식 soa-03-revisions 페이지 diff 전문 확보(발행 ≥1개월 후 시험 반영 원칙) | 높 |
| GUIDE-002 | M | SOA-C03 자격증 명칭 | 구명 SysOps 표시 가능성 → "CloudOps Engineer - Associate" 개명(2025-09-30) | 공식 자격증 페이지·T&C 블로그 교차 확인(앱 표시명 소스는 샤드 대상 밖) | 높 |
| GUIDE-003 | L | CLF-C02.json task 3.7 | "Amazon SageMaker" → 공식 가이드 "Amazon SageMaker AI" 갱신됨 | 현행 공식 영문 가이드 축자 대조 | 높 |

---
*집계 검산: H 13 + M 54 + L 67 = 134(원 ID) · 통합 −13 = 121 · Y = CLF 19 + SAA 48 + SOA 39 + GUIDE 3 = 109 · Phase A 82/B 52.*
