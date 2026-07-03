# ③ 학습문서 사실성 감사 샤드 — 03-docs-saa-e (t4-1~t4-5) — 2026-07

## 요약 (3~5줄)
- SAA 도메인 4(비용 최적화) 5개 문서(t4-1 스토리지 · t4-2 컴퓨팅 · t4-3 DB · t4-4 네트워크 · t4-5 도구) 전문 정독. 지시된 중점 항목 — Compute SP(최대 66%) vs EC2 Instance SP(최대 72%) 구분, Spot 2분 중단 통지, 인바운드 무료, NAT Gateway 과금 구조(시간+GB 처리), Cost Explorer/Budgets/CUR 역할 구분 — 은 모두 정확했고, CLF 감사에서 발견된 SP 유형 혼동 오류는 재현되지 않음. t4-2는 발견 0건.
- 발견 12건(H 2 · M 6 · L 4), 사실의심 Y 11건. 핵심 H 2건: ① t4-3 "Aurora 스토리지 최대 256TiB(2025년 상향)" — 표준 한도 128TiB(구엔진 64TiB)와 어긋나는 환각 의심, SAA 정답 관례도 128TiB. ② t4-5 Budget Actions 3종을 "IAM·SNS·SSM Automation"으로 오기(공식: IAM 정책 적용 · SCP 적용 · EC2/RDS 인스턴스 중지).
- 요금 구조 M 4건: 교차 AZ 프라이빗 IP "더 낮은 요율"(t4-1, 실제는 퍼블릭 경유와 동일 $0.01/GB/방향), NAT 경유 same-region S3에 아웃바운드 요금 가산(t4-4 — t4-1 기술과 샤드 내 상호 불일치), TGW 교차 AZ $0.01/GB 가산(2022-04 무료화 이후 구식 의심), Cost Explorer 예측 "18개월"(공식 12개월).
- 자주 변하는 요금·한도 수치(Aurora 한도·TGW 요금·CE 예측 기간·CUR 세부치)는 확신도를 보수적으로 표기했으며 Phase B(2단 검증) 4건으로 분류.

## 발견 항목

| ID | 위치 | 발견 내용 | 심각도(H/M/L) | 확신도(높/중/낮) | 권장 조치 | Phase(A/B) | 사실의심(Y/N) |
|---|---|---|---|---|---|---|---|
| DOC-SAA-401 | assets/content/saa/saa-t4-1.md#5-데이터-전송-비용 (표) | 교차 AZ 프라이빗 IP 전송을 퍼블릭 IP 경유 대비 "더 낮은 요율"로 표기. 근거: EC2 요금상 리전 내 교차 AZ 전송과 퍼블릭/EIP 경유 전송 모두 방향당 $0.01/GB로 동일 — 요율 차이 없음 | M | 높 | "동일 요율(방향당 $0.01/GB)"로 정정하거나 두 행을 통합 | A | Y |
| DOC-SAA-402 | assets/content/saa/saa-t4-1.md#2-s3-스토리지-클래스 (128KB 노트·🧠원리) + 흔한 함정 7 | 128KB 미만 소용량 객체가 많은 버킷에서 "오브젝트당 모니터링 요금이 절감액을 초과"한다고 설명. 근거: 2021-09 이후 128KB 미만 객체는 모니터링 비대상이며 모니터링 요금도 비과금(공식) — 실제 리스크는 "티어 미이동으로 절감 0"이고, 모니터링 요금이 절감액을 상회하는 케이스는 128KB 이상의 소형 객체에 해당 | M | 높 | 이유 재서술: "128KB 미만=모니터링 과금 없음·Frequent 고정(절감 없음), 128KB 이상 소형 객체=모니터링 요금이 절감액 상회 가능" | A | Y |
| DOC-SAA-403 | assets/content/saa/saa-t4-1.md#7-s3-storage-lens (기능 목록) | Storage Class Analysis를 Storage Lens의 하위 기능으로 나열. 근거: Storage Class Analysis는 S3 Analytics의 별개 기능(버킷/프리픽스 단위 설정)으로 Storage Lens 기능이 아님 — Standard→IA 전환 시점 분석 도구를 묻는 도구 구분 문항에서 혼동 유발 소지 | M | 높 | 별개 기능(S3 Analytics)으로 분리 서술 | A | Y |
| DOC-SAA-404 | assets/content/saa/saa-t4-1.md#시험-포인트 (표 "EC2 종료 후 불필요 EBS 탐지" 행) + §4 표 | 미연결 EBS 볼륨 탐지 도구로 Cost Explorer를 Trusted Advisor와 병기. 근거: 미사용·저활용 EBS 식별은 Trusted Advisor 비용 점검 항목이며 Cost Explorer는 비용 분석·시각화 도구로 미연결 볼륨 식별 기능이 아님(t4-5 §8의 역할 구분과도 결이 어긋남) | L | 중 | Trusted Advisor(+콘솔 볼륨 필터) 중심으로 정정 | A | Y |
| DOC-SAA-405 | assets/content/saa/saa-t4-1.md#5-데이터-전송-비용 (표 1행) | "같은 AZ 내 EC2↔EC2 또는 EC2↔S3 무료" — S3는 리전 서비스라 같은 리전이면 AZ와 무관하게 EC2↔S3 전송이 무료인데, 같은 AZ 조건에 묶여 "교차 AZ면 S3 전송 과금"으로 오독할 여지 | L | 높 | EC2↔S3를 "같은 리전 무료" 별도 행으로 분리 | A | N |
| DOC-SAA-406 | assets/content/saa/saa-t4-3.md#3-용량-계획 (Storage Auto Scaling 절) | "Aurora 최대 256TiB(2025년 상향 — 구버전 엔진 128TiB)". 근거: 공지 기준 Aurora 클러스터 볼륨 한도는 128TiB(구엔진 64TiB, 2020년 64→128 상향)이며 256TiB 상향 공지는 확인되지 않음 — 2020년 변경 패턴을 한 단계 올린 환각 또는 Aurora Limitless(샤딩으로 128TiB 초과)와의 혼동 의심. SAA 시험 정답 관례도 128TiB라 수치 문항 오답 유발 가능 | H | 중 | 2단 검증 후 "최대 128TiB(구버전 엔진 64TiB)"로 정정 | B | Y |
| DOC-SAA-407 | assets/content/saa/saa-t4-3.md#2-rds-예약-인스턴스 (🧠원리) + 자가점검 Q5 | "구성 속성이 하나라도 달라지면 RDS RI 할인이 적용되지 않는다"는 절대 단정. 근거: MySQL·MariaDB·PostgreSQL 등 일부 엔진의 RDS RI는 동일 인스턴스 패밀리 내 사이즈 유연성(size flexibility)이 있어 사이즈 변경 시 비례 적용됨 | L | 중 | "일부 엔진은 동일 패밀리 내 사이즈 유연성 예외" 각주 추가 | B | Y |
| DOC-SAA-408 | assets/content/saa/saa-t4-4.md#2-nat-gateway (NAT vs Gateway Endpoint 비교표 "데이터 전송 요금" 행) + #데이터-전송-비용-시나리오 (1행) | NAT 경유 same-region S3 경로에 "인터넷 아웃바운드 단가 적용"·"NAT $0.045/GB + 아웃바운드 요금"으로 기재. 근거: 같은 리전 EC2↔S3 전송은 경로(NAT/IGW 경유 포함)와 무관하게 무료 — 실제 과금은 NAT 처리요금(+시간요금·교차 AZ)뿐. t4-1 §5 동일 시나리오("NAT 처리 요금 발생"만 기재)와 샤드 내 상호 불일치 | M | 높 | 해당 칸을 "무료(같은 리전 S3) — 과금은 NAT 처리요금뿐"으로 정정 | A | Y |
| DOC-SAA-409 | assets/content/saa/saa-t4-4.md#5-vpc-피어링-vs-transit-gateway (표 "교차 AZ 전송" 행) + #데이터-전송-비용-시나리오 (마지막 행 $0.03/GB) | TGW 경유 교차 AZ 트래픽에 전송요금 $0.01/GB를 가산해 합계 $0.03/GB로 제시. 근거: 2022-04 AWS가 TGW·PrivateLink·Client VPN 트래픽의 리전 내 교차 AZ 전송요금을 무료화 — 이후로는 TGW 처리요금 $0.02/GB만 적용될 가능성 높음(요금 구조 변동 잦아 확신도 보수) | M | 중 | 요금 2단 검증 후 가산 항목 제거·정정 | B | Y |
| DOC-SAA-410 | assets/content/saa/saa-t4-5.md#학습-목표-체크리스트 + #1-비용-관리-도구-비교 (표) + #2-aws-cost-explorer + 자가점검 Q1 | Cost Explorer가 "미래 18개월 예측"을 제공한다고 4곳에서 반복 기술. 근거: 공식 문서 기준 이력 13개월(문서의 13개월은 정확) · 예측은 12개월 — 18개월 근거 확인 안 됨 | M | 중 | "향후 12개월 예측"으로 정정(2단 검증 병행) | A | Y |
| DOC-SAA-411 | assets/content/saa/saa-t4-5.md#3-aws-budgets (Budget Actions 코드블록) + 흔한 함정 7 | Budget Actions의 조치 3종을 "IAM 정책 연결 · SNS 토픽 알림 · SSM Automation 문서 실행"으로 서술. 근거: 공식 액션 유형 3종은 ①IAM 정책 적용 ②SCP 적용 ③실행 중 EC2/RDS 인스턴스 중지 — SNS는 액션이 아닌 일반 알림 채널이고 SSM Automation은 액션 유형이 아님. "예산 초과 시 EC2/RDS 자동 중지 가능" 여부를 묻는 문항에서 오답 유발 가능 | H | 높 | 액션 3종 목록 정정(IAM 정책·SCP·EC2/RDS 중지) + SNS 알림은 별도 서술 | A | Y |
| DOC-SAA-412 | assets/content/saa/saa-t4-5.md#4-aws-cost-and-usage-report-cur | "Developer·Business·Enterprise Support 비용은 해당 월 6~7일에 반영", "100만 행 초과 시 자동 분할" 등 오프라인 대조가 어려운 세부 수치. 근거: 공식 문서 재대조가 필요한 비정형 세부치(시험 출제 가능성은 낮으나 사실성 확인 필요) | L | 낮 | 2단 검증(CUR 공식 문서 대조) 후 유지·완화·삭제 결정 | B | Y |

### 이상 없음 확인(중점 점검 항목)
- **Savings Plans/RI 구분**(t4-2): Compute SP 최대 66% · EC2 Instance SP 최대 72% · Standard RI 72% · Convertible RI 54% · SP는 Spot 미적용 · Standard RI만 Marketplace 판매 — 모두 공식 문서와 일치. CLF 감사 유형(Compute SP vs EC2 Instance SP 혼동) 미발견.
- **Spot**(t4-2): 2분 인터럽트 통지, 종료·중지·동면 선택, 현행(비입찰) 스팟 가격 모델 서술 — 정확.
- **전송 비용 방향성**: 인바운드 무료·아웃바운드 과금·월 100GB 무료·같은 AZ 프라이빗 IP 무료 — t4-1·t4-4 간 일관, 정확.
- **NAT Gateway 과금 구조**: 시간당 $0.045 + 처리 $0.045/GB + 교차 AZ 가산 — 정확(단, DOC-SAA-408의 S3 아웃바운드 가산만 오류).
- **Cost Explorer/Budgets/CUR/Anomaly Detection 역할 구분**(t4-5 §1): 분석·예측/예산·차단/감사·BI/자동 이상감지 — 정확. Budgets 갱신 주기(하루 최대 3회, 8~12시간)·CE 활성화 후 비활성화 불가·태그 backfill 최대 12개월 — 정확.
- **S3 수명주기·최소 보관 기간**(t4-1): IA 30일·Glacier IR/FR 90일·Deep Archive 180일, 조기 전환·삭제 시 잔여기간 과금 — 정확. gp2/gp3 수치(3 IOPS/GB vs 3,000 고정, 약 20% 저렴) — 정확.
