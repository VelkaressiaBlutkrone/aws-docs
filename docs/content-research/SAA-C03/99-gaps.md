# 99 — 상충·불확실·확인 필요 목록 + 레포 JSON 수정 제안

- **조회일**: 2026-10-17 ~ 2026-10-19. 각 항목의 근거는 해당 `tasks/<n-m>.md`의 F-xx 사실표(출처 URL 포함)와 `98-existing-gap.md`의 G-ID에 있다.
- **원칙**: 확인되지 않은 것은 연구 파일 본문에서 *단정하지 않고* 여기에 "확인 필요"로 모았다. 금액·할인율·한도 수치는 리전·시점에 따라 달라지므로 구조(관계)만 시험 대비에 쓰고 수치는 최신 가격/쿼터 페이지로 재확인한다.
- **ID 체계**: `C-nn`=공식 자료 간 **상충**, `V-nn`=**확인 필요**(공식 문장 미확보), `G-nn`=전 문서 공통 이슈, `J-n`=레포 JSON 수정 제안, `R-n`=이번 재개 단계에서 **해소**된 이전 미확보 항목.
- **건수 요약**: §7 참조 (열린 항목 106 = 상충 21 + 확인 필요 80 + 공통 이슈 5, 해소 8, JSON 수정 제안 4)

---

## 1. 공식 자료 간 상충 (C)

| ID | 주제 | 상충 내용 | 연구 파일 처리 | 시험 대비 권고 |
|---|---|---|---|---|
| C-01 | S3 단일 객체 최대 크기 | S3 FAQ·업로드 가이드 **50 TB**(멀티파트 5 MB~50 TB), 한도 페이지 **48.8 TiB**(10,000파트×5 GiB), Storage Gateway FAQ **5 TB** | `3-1.md` F-01·F-21: 50 TB 주 서술+상충 병기. 기존 `saa-t3-1`의 "5TB"는 구식(`98` G-3.1-09) | "단일 PUT 5 GB, 그 이상은 멀티파트" 구조를 중심으로 암기. 최대치 숫자는 문제 지문 기준 |
| C-02 | EFS IA 절감률 | 기능 페이지 "IA는 Standard 대비 **최대 95%**, Archive는 IA 대비 최대 50%" vs 2021~2022 블로그·EKS 문서 "**최대 92%**" | `4-1.md` F-21 | 수치 암기 금지, "IA→Archive로 갈수록 저렴·접근 요금·최소 보관(Archive 90일)" 구조 암기 |
| C-03 | S3 Express One Zone 요청비 절감률 | 사용자 가이드 "Standard보다 **50%** 저렴" vs `3-1.md` F-06의 출처(Express One Zone 제품 페이지·성능 가이드) "**요청 비용 최대 80%**" | `4-1.md` F-01·`3-1.md` F-06 병기 | 단일 AZ·한 자릿수 ms가 핵심, 요율은 가격 페이지 |
| C-04 | Glacier 접근 빈도·복원 시간 표기 | **사용자 가이드 한 페이지 안에서도 비교표와 본문이 다름**: 비교표 FR "반기(Semi-annually)"·DA "연 1회(Annually)"·DA "9 to 48 hours" ↔ 본문 FR "연 1~2회"·DA "연 1회 미만"·DA를 "최대 72시간 대기 가능한 데이터"로 설명·DA Standard 12시간(Batch Operations 9–12시간)/Bulk 48시간. 제품 페이지(storage-classes)는 FR "연 1~2회", Glacier 제품 페이지는 DA "12–48시간", FAQ는 DA Standard 12시간 이내(Batch Operations는 9시간 이내 시작), 2021 블로그는 DA "12 to 48 hours" | `4-1.md` F-02·F-03 | FR=연 1~2회·분~시간(Expedited 1–5분/Standard 3–5시간/Bulk 5–12시간·무료), DA=연 1회 미만·Standard 12시간/Bulk 48시간 구조로 암기. 기존 학습문서 `saa-t4-1.md:98-99`·`saa-t3-1.md:95-96`의 "FR 연 1회 수준"은 이 범위 안의 근사 표현이라 오류로 분류하지 않음 |
| C-05 | Savings Plans 유형 수 | 구 페이지는 "2종"·"3종"으로 서술(기존 학습문서 `saa-t4-2.md:107-113`도 3종: Compute·EC2 Instance·SageMaker), 현행 plan-types·FAQ는 **4종**(+Database) | `4-2.md` F-02 | 4종으로 학습. 구 서술은 `98` G-4.2-13·G-4.3-12 |
| C-06 | Fargate Savings Plans 절감률 | ECS 요금 페이지 "최대 **52%**(3년)·1년 약 17~26%", Fargate 요금 페이지 "최대 **50%**", 일반 Compute SP "최대 66%" | `4-2.md` F-14 | 수치 암기 금지 |
| C-07 | Lambda Compute SP 절감률 | Lambda 페이지 "기간·프로비저닝 동시성 **최대 17%**" vs SP 사용자 가이드 예시 15%(가정치), 요청 요금은 0% | `4-2.md` F-15 | "요청 요금은 할인 제외"만 확실 |
| C-08 | Database Savings Plans 수치 | plan-types "최대 35%(Aurora·RDS·DynamoDB·…·OpenSearch)" vs 블로그(서버리스 35%·프로비저닝 20%·DynamoDB/Keyspaces 온디맨드 18%) vs DynamoDB 가격 페이지(온디맨드 18%·프로비저닝 12%). OpenSearch Service 포함 여부는 plan-types에만 | `4-3.md` F-06 | "1년 약정·유연(엔진/리전)·RI와 병용 불가" 중심 |
| C-09 | RDS 읽기 복제본 상한·교차 리전 | RDS FAQ "Oracle·SQL Server 최대 5" vs 기능 페이지 SQL Server 15 서술; 교차 리전 지원 엔진 목록(SQL Server 포함) vs CLI 문서(SQL Server·RDS Custom 미지원) | `2-1.md` F-26, `3-3.md` F-08 | MySQL·MariaDB·PostgreSQL 15, 그 외는 보수적으로 5 |
| C-10 | RDS 스토리지 오토스케일링 조건 | 공식 "여유 ≤10%·5분·24시간 내 변경 4회 미만" vs 구 블로그 "마지막 변경 후 6시간" | `3-3.md` F-09 | 공식 조건 채택. 핵심은 "축소 불가·최대 임계값 설정" |
| C-11 | Aurora 복제 지연 | 공식 "보통 100 ms 미만" vs PostgreSQL 블로그 "수백 ms(최대 60초 시 리더 재시작)" | `3-3.md` F-05 | "비동기·일반적으로 매우 짧음, 쓰기 지연 시 증가" |
| C-12 | Aurora Global Database 보조 리전 수 | 사용자 가이드 **최대 10** vs 구 블로그 **최대 5** | `2-2.md` F-07: 10으로 정정(2026-10-19) | 기존 학습문서 24개에는 보조 리전 수 서술이 없음(Grep 확인; 지연 "1초 미만"만 있음). 구성 요건 자체의 누락은 `98` G-3.3-08 |
| C-13 | SQS 메시지 크기 기본값 | 최신 **1 MiB** vs 구 SDK 기본 **256 KiB** | `2-1.md` F-03 | 현행 1 MiB, 1 MiB 초과는 Extended Client(S3) |
| C-14 | NLB 처리량 서술 | 2017 블로그 "수천만 RPS" vs 현행 가이드 "수백만 RPS" | `3-4.md` F-16 | "수백만 RPS급" 구조 |
| C-15 | Transit Gateway VPC 어태치먼트 대역폭 | 공식 쿼터 표 **AZ당 100 Gbps(각 방향)** vs 구 블로그 **50 Gbps 버스트** | `3-4.md` F-12: 쿼터 표로 정정(2026-10-19) | 쿼터 표 채택. "VPN ECMP 합산 최대 50 Gbps"(TGW+ECMP)는 별개 사실(`3-4.md` F-18) |
| C-16 | FSx for OpenZFS 디스크 IOPS | 문서 "최대 400,000 IOPS(Single-AZ 2)" vs 제품 페이지 "350,000 IOPS". 기존 학습문서 `saa-t3-2.md:260,276`의 "최대 2,000,000 IOPS"는 확인한 공식 페이지에 없음(캐시 데이터 "millions of IOPS" 서술만) | `3-1.md`, `98` G-3.1-12 | 수치 암기 금지 |
| C-17 | Quick(QuickSight) 요금제 | 구 백서(Standard $9/사용자·Enterprise $18/작성자+독자 세션) vs 현행 FAQ(사용자당 월 정액) | `3-5.md` F-14 | 요금제 암기 금지, SPICE·임베딩·서버리스 BI 구조 중심 |
| C-18 | 영문 가이드의 "AWS managed services" 표기 | Task 2.1 지식 소문자 "AWS managed services" vs 2.2 "AWS Managed Services (AMS) with appropriate use cases (for example, Amazon Comprehend, Amazon Polly)" — 예시가 AMS와 무관해 의미 모호 | `2-2.md` | (해석) 공식 설명은 없음. 출제 범위는 "AWS 관리형 서비스 일반"으로 보는 것이 안전 |
| C-19 | Storage Class Analysis 권고 범위 | 콘솔 도움말 "Standard→Standard-IA 전환 시점" vs FAQ "IA·One Zone-IA 전환 또는 Glacier 아카이브 대상 식별" | `4-1.md` F-10 | 접근 패턴 분석 도구라는 점만 확실 |
| C-20 | EBS gp3 성능 상한 | 2022 블로그 "16,000 IOPS·1,000 MiB/s" vs 현행 표 **80,000 IOPS·2,000 MiB/s** | `4-1.md` F-15·`3-1.md` F-07: 현행 채택 | 구 수치는 구식. **2026-10-21 재확인(갭 배치 B7a)**: 공식 EBS 사용자 가이드가 기준 3,000 IOPS·125 MiB/s, 최대 **80,000 IOPS**(GiB당 500·160 GiB 이상)·**2,000 MiB/s**(IOPS당 0.25·8,000 IOPS 이상)로 적어 **현행 채택이 옳다.** ⚠️ 다만 일부 SDK 문서(ECS 관리형 볼륨 등)는 gp3 를 `3,000–16,000 IOPS` 로 적는다 — **서비스별 관리형 볼륨의 제약**이고 볼륨 자체 상한이 아니므로 구분해야 한다(`saa-t3-2` §3 에 그렇게 적었다) |
| C-21 | In-Scope 목록의 서비스 상태 | 목록에 "Amazon Aurora Serverless"(구 명칭)·"AWS Snow Family"(신규 주문 불가)가 남아 있음 | `00-overview.md` §5, `3-3.md` F-07, `3-5.md` F-09 | 목록=범위, 서비스 현황=별개로 구분해 학습 |

---

## 2. 확인 필요 — 공식 문장 미확보 (V)

> 번호는 추가한 순서이고, 표 안의 위치는 Task군 순이다(그래서 V-73·V-74는 V-62 뒤, V-75·V-76은 V-16 뒤, V-77~V-82는 V-69 뒤에 있다). 취소선 행(V-12·V-44)은 해소되어 §4로 옮겼다.

### Task 1.x
| ID | 확인할 내용 | 관련 | 현재 처리 |
|---|---|---|---|
| V-01 | WAF 개발자 가이드에서 **CloudFront용 웹 ACL(스코프 CLOUDFRONT)을 US East (N. Virginia)에서 생성**한다는 문장 | `1-2.md`, `98` G-1.2-06 | CDK/CloudFormation 문서를 근거로 사용 |
| V-02 | **Regional NAT gateway 도입 시점**(발표일) | `1-2.md` F-10 | 기능만 기록, 시점 단정 안 함 |
| V-03 | AWS Security Hub 명칭 개편(서비스 이름·범위) | `1-2.md` | 현행 표기만 사용 |
| V-04 | IMDSv2 강제·Session Manager 등 **애플리케이션 구성 보안**의 공식 근거 | `98` G-1.2-05 | **IMDSv2는 해소**(R-9, 2026-10-21) · Session Manager는 여전히 미확보 |
| V-05 | S3 **MFA Delete와 Object Lock 병용** 가능 여부 | `1-3.md`, `98` G-1.3-16·G-1.1-14 | 단정 안 함 |
| V-06 | KMS **grant**·`kms:ViaService` 조건 세부 | `1-3.md` | 개념 수준만 |
| V-07 | AWS Config 적합성 팩·CloudTrail 로그 파일 **무결성 검증** 세부 | `1-3.md` | 개념 수준만 |

### Task 2.x
| ID | 확인할 내용 | 관련 | 현재 처리 |
|---|---|---|---|
| V-08 | Amazon MQ **사용 사례** 공식 문장 | `2-1.md` | 일반 서술 |
| V-09 | ~~App2Container의 **현재 제공 상태**~~ — **해소(2026-10-21, 갭 배치 B5)**. 번호 유지를 위해 행만 남김 | `2-1.md` F-28 | 공식 사용자 가이드가 확정: **신규 고객 불가**("no longer open to new customers", 2025-11-07 이전 가입자만 계속 사용)·공식 대안은 **AWS Transform**. `saa-t2-2` §3 에 그 상태를 함께 저작했다. ⚠️ in-scope·out-of-scope 목록 어디에도 없어 **시험 범위 판정은 여전히 불확실**하다 |
| V-83 | API Gateway **캐싱이 REST API 전용**이라는 공식 문장(`98` G-2.1-07 이 그렇게 적었으나 2026-10-21 조회에서 해당 문장을 확보하지 못했다) | `98` G-2.1-07 | 미확인 — 배치 B5 는 캐싱 주장을 **본문에 쓰지 않았다** |
| V-10 | ALB **교차 영역 기본값(켜짐)** 의 공식 문서 문장(블로그로만 확인) | `2-1.md` F-25 | 블로그 표기 |
| V-11 | "ECS 컨트롤 플레인 **추가 비용 없음**" | `98` G-2.1-14 | 미확인 |
| V-12 | ~~ElastiCache Multi-AZ 공식 문장 미확보~~ — **해소(R-8)**. 번호 유지를 위해 행만 남김 | `2-2.md` 각주 | `3-3.md` F-12(공식 FAQ·AutoFailover 문서)로 확보 |
| V-13 | EC2 **Region-level SLA** 수치 | `2-2.md` | 미기재 |
| V-14 | RDS Proxy 장애 조치 단축 **"66%"** 수치(블로그는 "최소 3초"만) | `2-2.md` | 미기재 |
| V-15 | ~~ASG 수명 주기 훅 대기 **기본 1시간(확인)·최대 48시간(미확인)**~~ — **해소(2026-10-21, 갭 배치 B6)**. 번호 유지를 위해 행만 남김 | `3-2.md`, `98` G-2.2-19 | 공식 `LifecycleHook` API 레퍼런스가 확정: `HeartbeatTimeout` 기본 **3,600초**·범위 30~7,200초, `GlobalTimeout`은 **172,800초(48시간) 또는 `HeartbeatTimeout`의 100배 중 더 작은 값**. 기존 서술("최대 48시간")은 **틀린 게 아니라 조건이 빠진 것**이었다(기본 1시간이면 100배가 48시간보다 커서 48시간이 상한). `saa-t2-3` §8에 조건을 보강했다 → `98` G-2.2-19(`[의심]`)도 해소 |
| V-16 | AWS Elastic Disaster Recovery가 **RDS 같은 관리형 서비스에 사용 불가**인지 | `98` G-2.2-16 | 미확인 |
| V-75 | NLB **"연결 지연 < 1ms"** 수치의 공식 근거(공식 표현은 "초저지연·초당 수백만 요청"뿐); GWLB 계층 표기("L3/4" vs 공식 CLI 레퍼런스 "layer 3") | `98` G-2.2-14 | 수치 미기재, 공식 표현만 사용 |
| V-76 | Well-Architected Reliability Pillar가 "이중화를 통한 단일 실패점 제거"를 핵심 원칙으로 **명시**한다는 인용 문구의 원문 | `98` G-2.2-17 | 의역 가능성 — 단정 안 함 |

### Task 3.x
| ID | 확인할 내용 | 관련 | 현재 처리 |
|---|---|---|---|
| V-17 | io2 Block Express·io1의 **부팅 볼륨** 지원(공식 SSD 표는 gp3/gp2만 표기) | `3-1.md` | 표 기준만 |
| V-18 | FSx for Windows **AD 통합 "필수"** 단정 | `98` G-3.1-15 | "조인 가능"만 확인 |
| V-19 | FSx for Lustre 정확한 **IOPS 한도** 문장 | `3-1.md` | 미기재 |
| V-20 | 인스턴스 스토어 **NVMe 성능** 수치 | `3-1.md` | 미기재 |
| V-21 | EC2 **M·C 계열 vCPU:메모리 비율**(R 계열 1:8만 확인) | `98` G-3.2-12 | R만 기재 |
| V-22 | **AWS Auto Scaling 스케일링 플랜**의 지원 종료/신규 가용성 공지 | `3-2.md` F-12 | 마이그레이션 권고만 확인. ⚠️ **2026-10-21 (갭 배치 B7b) 재탐색에도 미해소** — 검색으로는 EC2 Auto Scaling **예측 스케일링**이 현행이라는 것과 ECS 오토스케일링 개선(20초 고해상도 지표)만 확인됐고, `autoscaling-plans` API 의 현행 제공 상태를 적은 공식 문장은 찾지 못했다. 그래서 `saa-t3-4` §8 은 **Application Auto Scaling 만** 다루고 스케일링 플랜은 언급하지 않는다(가드가 그 금지를 강제) |
| V-23 | **AWS Batch 작업 제한 시간 상한**(최소 60초만 확인) | `98` G-3.2-16 | "무제한" 서술은 미검증 |
| V-24 | ~~CloudFront Functions **실행 시간·메모리 한도**, Lambda@Edge 한도~~ — **해소(2026-10-21, 갭 배치 B7b)**. 번호 유지를 위해 행만 남김 | `3-2.md` F-23 | 공식 쿼터·제약 문서가 확정: **CloudFront Functions** = 계정당 함수 100개·**최대 함수 크기 10 KB(조정 불가)**·**최대 메모리 2 MB**·함수당 배포 100개, 로그 10 KB 절단, **요청 본문 접근 불가**, 런타임이 동적 코드 평가·네트워크·파일 시스템·환경 변수·타이머를 제한. ⚠️ **실행 시간 한도는 절대 수치가 아니라 "컴퓨팅 사용률(compute utilization) 0~100"으로만 적힌다** — 널리 인용되는 "최대 1 ms"는 현행 쿼터 표에 **없다**. **Lambda@Edge** = **함수 타임아웃 30초**(이벤트 유형으로 갈리는 항목은 **생성 응답 크기 40 KB / 1 MB** 뿐 — "뷰어 5초" 분기는 현행 문서에서 확인되지 않음), 압축 패키지 50 MB, 계정당 배포 500개·배포당 함수 100개·함수당 배포 500개, 리전당 동시 실행 1,000(인스턴스당 10 req/s, 총 호출 한도 = 동시성 × 10)·리전당 10,000 req/s, Include Body 절단 40 KB/1 MB·교체 한도 평문 40 KB/1 MB·base64 53.2 KB/1.33 MB·초과 시 **HTTP 502**. `saa-t3-4` §7 에 저작 |
| V-25 | ~~**Spread 배치 그룹 AZ당 7개**의 사용자 가이드 원문(블로그 표만)~~ — **해소(2026-10-21, 갭 배치 B7b)**. 번호 유지를 위해 행만 남김 | `3-2.md` F-06 | 공식 사용자 가이드 "Placement strategies" 본문이 확정: 랙 수준 분산 배치 그룹은 동일 리전 다중 AZ 를 걸칠 수 있으나 **각 AZ 에서 실행 인스턴스 최대 7개**(AZ 3개 리전이면 총 21개, 8번째는 시작 실패). 7개가 더 필요하면 **분산 배치 그룹을 여러 개** 쓰라는 권고까지 같은 문단에 있다. 호스트 수준 분산은 **Outposts 전용**. 기존 `saa-t3-3` §5 표의 "AZ당 최대 7개" 서술이 옳았다 |
| V-26 | ~~배치 그룹 "전용 호스트: 불가"·"Spot 중지/최대 절전: 불가"~~ — **부분 해소(2026-10-21, 갭 배치 B7b)**. 번호 유지를 위해 행만 남김 | `98` G-3.2-14 | 같은 "Placement strategies" 문서에서 **파티션 PG 와 전용 인스턴스(Dedicated Instances) 조합은 최대 2개 파티션**, **용량 예약은 파티션 PG 안의 용량을 예약하지 않음**, **Capacity Blocks 는 배치 그룹 미지원**, 클러스터 PG 는 **존 RI 로 용량 예약 불가(ODCR 권장)** 를 확보했다. ⚠️ **"Spot 중지·최대 절전 불가"의 직접 문장은 이번에도 확보하지 못했다** — `saa-t3-3` §5 표의 그 두 칸은 근거 보강 전까지 그대로 둔다 |
| V-27 | Lambda 콜드 스타트 "수십~수백 ms" 근거 | `98` G-3.2-17 | 근거 없음 |
| V-28 | **"Aurora serverless" 개명**의 공식 제품 문서 본문 확인, Aurora Serverless v1 종료 시점 | `3-3.md` F-07, `98` G-3.3-13 | 블로그 안내문만 확보 |
| V-29 | **QLDB 현행 상태** | `3-3.md` | 단정 안 함 |
| V-30 | **RDS Magnetic** 지원 중단 문장 | `98` G-3.3-14 | RDS API 레퍼런스는 여전히 서술 |
| V-31 | DynamoDB **계정당 테이블 처리량 쿼터**·DAX 클러스터 노드 한도 | `3-3.md` | 미기재 |
| V-32 | Redis **AOF**·단일 스레드·Memcached 암호화 비교 문장 | `98` G-3.3-17 | 미확인 |
| V-33 | DynamoDB **"3개 AZ"** 복제(공식은 "multiple") | `98` G-3.3-18 | 미확인 |
| V-34 | Direct Connect **구축 리드타임(수 주)**·VPN 구축 "수 분"·DX/VPN의 "일관 지연" 공식 문장 | `98` G-3.4-14, `3-4.md`·`4-4.md` 각주 | 미확인 (DX의 낮은 DTO는 `4-4.md` F-13에서 확보 → R-3) |
| V-35 | PrivateLink가 **소비자·제공자 CIDR 중복**을 허용하는지 | `98` G-3.4-15 | 미확인 |
| V-36 | **Geoproximity가 Traffic Flow 전용**인지(콘솔 구성 안내가 re:Post에 있음) | `98` G-3.4-12 | 미확인 |
| V-37 | Global Accelerator **IPv6(듀얼 스택) 주소 수**, Direct Connect **400 Gbps 지원 위치 범위** | `3-4.md` | 미기재 |
| V-38 | Quick(QuickSight) **현행 요금제**(C-17) — 과거 백서(Standard·Enterprise 에디션)와 현행 FAQ("사용자당 월 정액") 중 어느 쪽이 현행인지 | `3-5.md` F-14, `98` G-3.5-13 | 충돌 병기 |
| V-39 | Kinesis Data Streams **레코드 크기 한도**·GetRecords 5회/s 등 API 한도 공식 문장 | `3-5.md` | 미기재 |
| V-40 | Firehose **버퍼 크기·간격 허용 범위**, DataSync **태스크 최대 처리량** | `3-5.md` | 미기재 |
| V-41 | Glue **"70개 이상 데이터 소스"** 근거 | `98` G-3.5-14 | 미확인 |
| V-42 | Lake Formation **Governed Tables** 현행 상태, Redshift **서버리스/RG** 세부, OpenSearch Service 세부 | `3-5.md` | 미기재 |
| V-84 | **RDS Provisioned IOPS 범위**(갭 노트 `G-3.3-04`는 `1,000–256,000`을 적음) | `98` G-3.3-04 | 미확인 — 2026-10-21(B8a) 조회에서 공식 범위 문장을 확보하지 못해 `saa-t3-5` §6에 수치를 쓰지 않았다. 가드가 그 범위 표기를 금지한다 |
| V-86 | **EBS Snapshots Archive 절감률**(갭 노트 `G-4.1-05`는 "최대 75%"를 적음) | `98` G-4.1-05 | 미확인 — 2026-10-21(B9a) 조회에서 공식 절감률 문장을 확보하지 못해 `saa-t4-1` §4에 수치를 쓰지 않았다. 가드가 `최대 75%`·`75% 절감` 표기를 금지한다 |
| V-87 | **FSx for OpenZFS·Lustre 의 현행 스토리지 클래스**(Intelligent-Tiering·HDD 여부) | `98` G-4.1-07 | 미확인 — 2026-10-21(B9a)에서 **ONTAP 의 SSD·용량 풀 티어만** 공식 확인했다. OpenZFS·Lustre 쪽은 확보하지 못해 쓰지 않았고 가드가 `Lustre Intelligent-Tiering`·`OpenZFS HDD 클래스` 표기를 금지한다 |
| V-88 | **CUR 2.0 · Data Exports · FOCUS 1.0 세부** | `98` G-4.1-11 | 미확인 — 2026-10-21(B9a)에서 확보하지 못했고 2026-10-22(B9a-2) 저작에서도 쓰지 않았다(가드가 `FOCUS` 표기를 금지한다). 단 CUR 2.0·Data Exports의 **기본 서술은 이미 `saa-t4-5` §1 표·§4에 있다**(2026-10-19 정정분). ⚠️ 이 행에 함께 묶여 있던 **"비용 할당 태그 활성화 지연"은 V-89로 분리·해소**됐다 |
| V-89 | **비용 할당 태그 활성화 지연**(태그 부착 → 목록 등장 최대 24시간, 활성화까지 추가 최대 24시간) | `4-1.md` F-30, `98` G-4.1-11 | **해소(2026-10-22, B9a-2)** — V-88에 "미확인"으로 묶여 있었으나 공식 원문을 직접 확인했다: *"it can take up to 24 hours for the tag keys to appear on your cost allocation tags page for activation. It can then take up to 24 hours for tag keys to activate."* **F-30이 이미 같은 인용을 갖고 있었으므로 V-88의 미확인 판정 자체가 틀렸다.** `saa-t4-5` §6에 2단 지연으로 반영하고 가드로 고정했다 |
| V-90 | **Cost Explorer 시간·리소스 단위 세분화의 추가 과금 여부**(`4-1.md` F-33은 "추가 비용 가능"을 적음) | `4-1.md` F-33, `98` G-4.1-11 | 미확인 — 2026-10-22(B9a-2)에 공식 설정 문서(`ce-configuring-data`)를 전문 확인했으나 **과금 언급이 전혀 없다**(데이터 임계값 한도 안내만 있다). `saa-t4-5`에 쓰지 않았고 가드가 `추가 비용`·`추가 요금` 표기를 금지한다 |
| V-91 | **Cost Optimization Hub** | `98` G-4.1-11 | 미기재 — 갭 노트 `G-4.1-11`이 "없음" 항목으로 나열하지만 `4-1.md` F-30~F-36에 **근거 행 자체가 없다.** 2026-10-22(B9a-2)에서 쓰지 않았고 가드가 `Cost Optimization Hub` 표기를 금지한다. 쓰려면 공식 조회를 먼저 한다 |
| V-92 | **Trusted Advisor Basic 플랜의 점검 범위**(갭 노트 `G-4.1-12`는 "보안 6종 + 서비스 한도"를 적음) | `98` G-4.1-12, `4-1.md` F-35 | **공식과 불일치 — 공식을 따랐다(2026-10-22, B9a-2)** — 공식은 *"all checks in the Service Limits category and selected checks in the Security and Fault tolerance categories"*다. 갭 노트는 **내결함성을 빠뜨렸고** "6종"이라는 수치는 해당 문서에 없다. `saa-t4-5` §8은 공식 표현(서비스 한도 카테고리 전체 + 보안·내결함성 카테고리의 일부)으로 적고 가드가 `보안 6종` 표기를 금지한다 |
| V-85 | **RDS 연쇄 복제본 총수 "최대 155"**(갭 노트 `G-3.3-05`) | `98` G-3.3-05 | 공식과 불일치 가능 — 2026-10-21(B8a) 확인 결과 공식 문서는 **소스당 최대 15개**와 **PostgreSQL 14.1+ 체인 최대 3단계**만 적고 **155라는 총수를 두지 않는다.** 155가 3단계 누적 계산의 산물인지 확인되지 않아 쓰지 않았고 가드가 금지한다 |
| V-43 | Kinesis Data Analytics→Flink **개명 날짜**, Snowcone/Snowmobile **개별 종료 시점**, **Snow가 이전 가이드에서 제거됐는지** | `3-5.md`, `98` G-3.5-09 | 미확인 |

### Task 4.x
| ID | 확인할 내용 | 관련 | 현재 처리 |
|---|---|---|---|
| V-44 | ~~Glacier 복원 티어 시간의 단일 공식 문장 직접 인용 미확보~~ — **해소(R-7)**. 번호 유지를 위해 행만 남김 | `4-1.md` F-03 | 사용자 가이드 본문으로 확보 |
| V-45 | "**Standard-IA 객체는 30일 후 Glacier로**" 규칙의 사용자 가이드 Constraints 문장 | `4-1.md` F-08 | re:Post 근거 |
| V-46 | AWS Backup 가격표의 **저비용 웜 티어(최소 60일)** 대상 리소스·요금 | `4-1.md` F-25 | 미기재 |
| V-47 | AWS Budgets **무료 예산 개수·요금**, Cost Anomaly Detection **고객 관리형 모니터 값 한도**("최대 10개") | `98` G-4.1-26 | 미확인 |
| V-48 | Trusted Advisor 전체 점검의 **신규 플랜(Business Support+ 등)별 세부** | `4-1.md` F-35 | 플랜 개편 공지만 |
| V-49 | 비용 할당 태그 **backfill "최대 12개월"** | `98` G-4.1-27 | 콘솔 도움말만(24시간에 1회) |
| V-50 | CUR **"100만 행" 분할 기준**·Support 비용 CUR **반영 "6~7일"** | `98` G-4.1-23·24 | 미확인 |
| V-51 | EFS **Archive 접근 요금** 세부 | `4-1.md` F-22 | IA만 확인 |
| V-52 | **"SP는 Spot에 적용되지 않는다"** 공식 문장 | `98` G-4.2-15 | **해소(2026-10-24)** — `sp-ris` 전문 확인에서 확보했다: *"Savings Plans doesn't apply to spot usage or usage covered by RIs."* ⚠️ Spot 뿐 아니라 **RI가 커버한 사용량**도 함께 제외된다(할인 적용 순서 RI → SP와 맞물린다). `saa-t4-2` §3과 문항 q6에 반영하고 가드로 고정했다 |
| V-53 | **미사용 On-Demand Capacity Reservation의 과금** 방식 | `4-2.md` F-07 | 할인 적용 규칙만 |
| V-54 | ~~Spot 중단 시 **종료·중지·최대 절전 중 선택** 가능하다는 서술 — 최대 절전만 확보, 종료·중지 직접 문장 미확보~~ → **중단 동작 부분은 2026-10-24 해소**: `interruption-behavior` 가 *"the possible interruption behaviors: Stop, Hibernate, Terminate. The default behavior is that Amazon EC2 terminates…"* 로 세 선택지와 기본값을 한 문장에 담고 있다(앞선 조회는 Ruby SDK API 문서에 닿아 놓쳤다). ⚠️ **같은 행에 묶여 있던 Spot 할당 전략 현행 목록·웜 풀 상태별 과금은 그대로 미확보** — 이 행은 그 둘 때문에 열린 채로 둔다 | `4-2.md`, `98` G-4.2-21 | 중단 동작 ✅ / 할당 전략·웜 풀 미확보 |
| V-55 | "**비프로덕션은 단일 AZ 등 낮은 가용성**" 공식 문장, EC2 **최대 절전 지원 패밀리·RAM 한도·최대 60일** | `4-2.md` | 설계 판단으로 표기 |
| V-56 | Outposts **구성별 가격**·EBS gp2 외 볼륨 구성, NLB **"LB 비용 약 25%"** 근거(오픈소스 블로그 서술), AMD ~10%·Graviton ~20% 가격차(us-east-1 온디맨드 예시) 최신화 | `4-2.md` F-12·F-18·F-19, 각주 ⑦⑧⑩, `98` G-4.2-17("Graviton3 기준" 수식 근거 미확보) | 예시로 표기 |
| V-57 | **RDS RI 할인율(%)**(기존 학습문서의 25~60% 표 근거 없음) | `98` G-4.3-14 | 미확보 |
| V-58 | Database SP **발표일**(re:Invent 2025 서술만)·7세대 미만 인스턴스 처리, Aurora serverless **I/O 과금** | `4-3.md` F-06 | 서술만 |
| V-59 | RDS 중지 **7일 제한의 구성별 동일성**(Multi-AZ·복제본), ElastiCache **데이터 티어링 수치 현행**, **교차 리전 스냅샷 복사 과금** 문장(Aurora 교차 리전 복사 포함) | `4-3.md` 각주 ⑤⑦⑬, `98` G-4.3-22 | 미확인 |
| V-60 | DynamoDB **모드 전환 "24시간 내 재전환 제한"** | `98` G-4.3-19 | 미확인 |
| V-61 | RDS **T 인스턴스(db.t*) 크레딧/unlimited 동작** | `98` G-4.3-23 | 미재확인 |
| V-62 | 마케팅성 수치: RDS MySQL 앞단 캐시 "최대 55%"·SQL Server→오픈소스 "최대 80%/70%" 절감 | `4-3.md` F-13·F-18 | AWS 서술로 표기 |
| V-73 | Aurora 인스턴스 요금 문서의 "Storage … provisioned" 표현과 Aurora 자동 증감 스토리지(`3-3.md` F-03)의 관계 | `4-3.md` 각주 ④ | 관계 미확정 — 단정하지 않음 |
| V-74 | Redshift RG 노드 유형의 상세(가격 페이지가 RG 권장으로 변경), 열 기반 DB 비용 비교(Redshift vs Athena)의 공식 기준 문장 | `4-3.md` F-15, 각주 ⑪⑫ | 구조(컴퓨트·RMS 독립 과금)만 기재 |
| V-63 | **퍼블릭 IP/Elastic IP 경로의 AZ 내·AZ 간 별도 요율** | `98` G-4.1-19·G-4.4-13 | 미확보(종결) |
| V-64 | AZ 간 **$0.01/GB 각 방향**의 EC2 요금표 직접 인용(EKS 가이드 서술만), **리전 간 일반 요율**, **인터넷 DTO 계층 요율**($0.09/GB 등) | `98` G-4.4-14 | 구조만 기재 |
| V-65 | **Regional NAT gateway 요금 구조**, NAT instance가 더 싸지는 **손익분기**, VPC 피어링 **리전 간 요율** | `4-4.md` F-07 | 미기재 |
| V-66 | Direct Connect **포트 시간 요율**·위치별 DTO(예시 $0.02는 미국), Interface 엔드포인트 **시간 요율** | `98` G-4.4-15·16 | 예시만 |
| V-67 | Route 53 **Traffic Flow 정책 레코드·헬스 체크 요금**, CloudFront **요금 계층·flat-rate 플랜별 허용량**, VPN **연결 시간 요율**·5 Gbps VPN/Concentrator **지역 가용성** | `4-4.md` | 일부만 |
| V-68 | WAF **rate-based rule의 현행 평가 창·집계 키**(초기 블로그는 5분/IP) | `4-4.md` F-20 | 발표 블로그 기준 |
| V-69 | 엔드포인트 간 AZ 전송 **무과금**(EKS 가이드 서술)·서비스별 AZ 간 전송 예외·CloudFront↔EC2 **단가 비교 문장** | `98` G-4.4-18 | 미확인 |
| V-77 | Intelligent-Tiering에서 **128 KB 이상 객체의 모니터링 요금이 절감액을 넘는 임계**(확인된 것: 128 KB 미만은 자동 계층화 대상 아님·항상 Frequent Access 단가) | `98` G-4.1-14 | 임계 수치 미기재 |
| V-78 | **미연결 EBS 볼륨을 Cost Explorer로 탐지**한다는 서술의 문서화된 근거(문서화된 수단은 Trusted Advisor·Compute Optimizer) | `98` G-4.1-17 | 문서화된 수단만 기재 |
| V-79 | `AbortIncompleteMultipartUpload`를 **"7일 후 정리 권장"** 이라는 공식 권장값 문장(7일은 API 문서의 예시값) | `98` G-4.1-18 | 일수는 사용자 정의로 기재 |
| V-80 | 공식 문서가 **"Savings Plans를 RI보다 먼저 고려하라"** 고 명시한다는 문장 | `98` G-4.2-14 | **미확보 확정(2026-10-24)** — 문항이 출처로 달아 둔 바로 그 페이지(`sp-ris`)를 **전문 확인했으나 우선순위를 말하는 문장이 없다.** 그 페이지가 제시하는 것은 절감률·유연성 **비교 표**와 *"Savings Plans doesn't provide capacity reservations, but you can allocate On-Demand Capacity Reservation (ODCR) for your needs and your Savings Plans will apply."* 다. ⚠️ **용량 확보가 요건이면 SP는 답이 아니므로** 우선순위 단정은 과잉 일반화다 → `saa-t4-2` md 3곳(§2 표·§2 인용·시험 포인트)과 문항 q5를 **조건 서술**(유연성 → SP / 특정 AZ 용량 → Zonal RI·ODCR / 혼합)로 고치고 가드로 고정했다 |
| V-81 | DynamoDB **"기본 권장은 온디맨드"** 라는 공식 문장(확인된 서술은 "예측 불가=온디맨드 모범 사례, 일관·점진 증가=프로비저닝") | `98` G-4.3-18 | 조건부 서술로 기재 |
| V-82 | Gateway 엔드포인트의 **"S3·DynamoDB 같은 리전 전송 무료"** 중 DynamoDB 쪽 근거(S3는 확인, DynamoDB는 미확보) | `98` G-4.4-19 | DynamoDB 무료 여부는 단정 안 함 |

### 메타(00-overview)
| ID | 확인할 내용 | 현재 처리 |
|---|---|---|
| V-70 | 레거시 PDF 가이드 본문의 **"Version 1.1 SAA-C03"** 라벨(이번 세션 PDF 렌더 도구 없음; 메타데이터 날짜 2023-09-25만 확인) | `00-overview.md` §2에 구분 표기 |
| V-71 | **웹 가이드 발행일** 미표기, SAA-C03 **후속 버전 공지 미확인**(향후 일정 단정 금지) | `00-overview.md` §2 |
| V-72 | 연구 파일에서 다룬 **MemoryDB·Timestream·App Runner·Cloud WAN·Elastic Disaster Recovery**의 시험 범위 여부(두 목록 모두에 없음) | `00-overview.md` §5 |

---

## 3. 전 문서 공통 이슈 (G)

| ID | 이슈 | 규모 | 권고 |
|---|---|---|---|
| G-01 | **🧠 원리 블록의 근거 부재** — 설계 이유를 서술하나 공식 근거 URL이 없고 사실 진술과 설계 의도 추정이 섞임("지수적으로" 같은 정량 수사 포함) | 기존 24개 문서 전체에 **`> 🧠 원리` 164블록**(문서당 4~8개; Grep 실측). 근거 부재 자체를 다루는 `98` 행 13개: G-1.1-13·G-1.2-16·G-1.3-14·G-2.1-13·G-2.2-18·G-3.1-16·G-3.2-18·G-3.3-19·G-3.4-16·G-3.5-16·G-4.2-22·G-4.3-24·G-4.4-20. 블록 밖에서 설계 이유를 추정한 행: G-1.1-12(관리 계정이 SCP 영향을 받지 않는 이유). 블록 안 개별 서술을 문제 삼는 행: G-1.1-11(신뢰 성립 설명)·G-3.1-14(인스턴스 스토어 소실 사유)·G-3.3-10(gp3 버스트, `[오류]`)·G-3.4-15(PrivateLink CIDR)·G-4.3-17(0.5/0 ACU 표현) | 근거 URL 부착 또는 "추정" 표시. 틀린 *사실*이 원리 블록에 들어간 사례는 `98`의 `[오류]`(G-3.3-10 등) 참조. G-2.1-13은 "사실과 어긋난 추정이 섞임"으로 명시(G-2.1-10과 연결) |
| G-02 | **금액·수치 예시의 시점/리전 의존** — 요금($/GB 등)·할인율·한도 | 전 Task, 특히 4.x | 구조(경계·방향·약정 관계)를 학습하고 수치는 가격/쿼터 페이지로 재확인 |
| G-03 | **블로그/re:Post 단독 근거 항목** — 공식 사용자 가이드 문장이 아니라 AWS 블로그·re:Post로만 확인한 사실 | 각 Task의 `[블로그]`·`[re:Post]` 표기 | 중요 사실은 사용자 가이드로 재확인 후 승격 |
| G-04 | **기존 문서 sources 목록과 본문 불일치** — 일부 절(EFS/FSx 등)에 대응 URL 없음 | `98` G-4.1-28 | 절별 출처 보강 |
| G-05 | **기존 문서 내부 서술 상충 중 방향 미확정** — `saa-t4-3.md:89`의 TCO 표 "인스턴스 비용: 동일 수준" vs `:94` 결론 행 "인스턴스 비용은 소폭 높으나 운영 비용 절감으로 TCO 유리". 두 서술 모두 공식 근거 URL이 없어 어느 쪽이 맞는지 이번 조사로 확정하지 못함 | `98` G-4.3-21 (문서 내부 불일치는 8행: G-1.1-08·G-1.3-07·G-3.1-10·G-3.2-10·G-3.3-16·G-4.1-21·G-4.3-17·G-4.3-21 — 행별 판정은 98 참조) | 근거 확보 전까지 "동일 수준"/"소폭 높음" 중 하나를 단정하지 말고 표현 삭제 또는 출처 부착 |

---

## 4. 이번 재개 단계에서 해소된 이전 미확보 항목 (R)

| ID | 항목 | 해소 내용 | 위치 |
|---|---|---|---|
| R-1 | **MySQL vs PostgreSQL 공식 비교 문장**(`3-3.md` 머리말 미확보 항목) | AWS 공식 비교 페이지 확보(읽기 vs 쓰기 성능, 객체-관계형, ACID, 기능) | `4-3.md` F-18 |
| R-2 | **가속 VPN(Accelerated VPN) 정의 문장**(`3-4.md` 미확보) | "가속 VPN 생성 시 두 개의 가속기를 생성·관리, 시간당+전송 요금" 확보 | `4-4.md` F-14 |
| R-3 | **Direct Connect의 인터넷 대비 낮은 전송 단가**(`98` G-3.4-14의 일부로 미확보였음) | DX 인바운드 무료·낮은 DTO 요율·시드니 예시 확보(리드타임은 여전히 미확보 V-34) | `4-4.md` F-13 |
| R-4 | **Transit Gateway VPC 어태치먼트 대역폭**(블로그 50 Gbps만 확보) | 공식 쿼터 표(AZ당 100 Gbps 각 방향)로 정정 → 상충 C-15로 기록 | `3-4.md` F-12 |
| R-5 | **Aurora Global DB 보조 리전 수**(5 vs 10) | 사용자 가이드 10 채택 | `2-2.md` F-07 |
| R-6 | **Compute Optimizer의 RDS·Aurora 지원 여부**(기존 학습문서 서술 미재확인) | 지원 리소스 목록 확보(RDS·Aurora·EBS·Lambda·Fargate·유휴 권고 포함) | `4-2.md` F-13 |
| R-7 | **Glacier 복원 티어별 시간의 단일 공식 문장**(V-44) | 사용자 가이드 본문에서 FR(Expedited 1–5분/Standard 3–5시간/Bulk 5–12시간 무료)·DA(Standard 12시간/Bulk 48시간)를 직접 확보. 단 같은 페이지 비교표·제품 페이지와 표기가 달라 **새 상충 C-04로 기록** | `4-1.md` F-03 |
| R-8 | **ElastiCache Multi-AZ 공식 문장**(V-12; `2-2.md` 각주에서 미확보였음) | `3-3.md` F-12가 공식 FAQ·AutoFailover 문서로 확보: Multi-AZ=AZ 간 복제+장애 시 복제본 자동 승격(DNS 엔드포인트 유지), 복제 그룹=기본 1+읽기 복제본 최대 5, 노드 기반 Valkey/Redis OSS Multi-AZ·Serverless는 99.99% SLA 대상 | `3-3.md` F-12 |
| R-9 | **IMDSv2 강제의 공식 근거**(V-04; `1-2.md`·`98` G-1.2-05 에서 미확보였음) | EC2 API 레퍼런스로 확보(2026-10-21): `httpTokens=required` 면 세션 토큰 없이는 메타데이터를 가져올 수 없고 **IMDSv1 자격증명이 제공되지 않는다**; `optional` 이면 토큰 없는 요청에 IMDSv1 자격증명이 돌아온다. 기본값은 AMI `ImdsSupport` 와 계정 수준 기본값의 조합(AMI `v2.0` + 계정 `no-preference` → `required`, 계정이 "V1 or V2" → `optional`), AMI `v2.0` 은 `HttpPutResponseHopLimit` 2. 적용은 `run-instances --metadata-options HttpTokens=required` · `modify-instance-metadata-options --http-tokens required`. ⚠️ **Session Manager 쪽 근거는 이번에도 확보하지 못했다** — V-04 는 그 부분만 열린 상태로 남긴다 | `97-gap-batch-map.md` B11 (저작은 `saa-t1-4`, flip 이후) |
| R-10 | **엣지 함수 쿼터**(V-24; `3-2.md` F-23 에서 수치 미기재였음) | CloudFront 쿼터·제약 문서 3종으로 확보(2026-10-21). ⚠️ 통념 2건이 현행 문서와 달랐다 — CloudFront Functions 의 "**1 ms**"는 쿼터 표에 없고 **컴퓨팅 사용률(0~100)**로만 측정하며, Lambda@Edge 의 "**뷰어 5초 / 오리진 30초**" 분기도 없이 **함수 타임아웃 30초 하나**다(이벤트 유형으로 갈리는 항목은 생성 응답 크기뿐). 둘 다 **쓰지 않고** 공식 지표로 저작했다 | `saa-t3-4` §7 (갭 배치 B7b) |
| R-11 | **Spread 배치 그룹 AZ당 7개의 사용자 가이드 원문**(V-25; 블로그 표기만 있었음) | 공식 "Placement strategies" 본문으로 확보(2026-10-21): 랙 수준은 다중 AZ 가능하나 **AZ당 실행 인스턴스 7개**, 8번째는 시작 실패, 더 필요하면 그룹을 여러 개. 호스트 수준은 Outposts 전용. 기존 `saa-t3-3` §5 서술이 옳았음을 확인 | `saa-t3-3` §5 (갭 배치 B7b) |
| R-12 | **EMR 배포 형태의 개수**(통념 3종 vs 공식) | 공식 비용 최적화 백서가 **네 가지**로 확정(2026-10-21): EMR on EC2 · EMR on EKS · **EMR on Outposts** · EMR Serverless. 확장 단위도 갈린다(EC2=클러스터 / EKS=잡의 vCPU·메모리 / Serverless=관리 불필요). ⚠️ **Outposts 는 Spot 미제공·S3 만 지원(S3 on Outposts 미지원)** 이라 비용이 올라간다 | `saa-t3-4` §9 (갭 배치 B7b) |
| R-13 | **T 패밀리 기본 `unlimited` 목록**(기존 본문이 T3/T3a/T4g 로만 적어 **T8i 누락**) | 공식 unlimited 모드 문서로 확정(2026-10-21): **T8i·T4g·T3a·T3** 가 기본 `unlimited`. 더해 **전용 호스트의 T3 은 기본 `standard` 이고 `unlimited` 미지원**, Spot 은 크레딧 적립 유휴가 없어 **`standard` 권장**. 본문 3개소와 `saa-t3-3.questions.json` 드래프트 해설 1개소를 정정 | `saa-t3-3` §2 (갭 배치 B7b) |
| R-14 | **DynamoDB 온디맨드의 즉시 수용량 모델**(통념은 "이전 피크의 2배·30분 규칙") | 현행 공식 문서는 그 규칙 대신 **warm throughput**으로 설명함을 확인(2026-10-21): **새 온디맨드 테이블은 읽기 12,000·쓰기 4,000 단위/초**로 시작해 그 수준까지 즉시 수용하고, 초과하면 자동 상향된다. 값은 과거 사용량에 따라 얼마나 확장됐는지를 나타내며 모든 테이블·GSI에 기본·무료. 계획된 피크에는 **사전 웜업(pre-warming)**으로 선제 상향이 가능하되 ⚠️ **올린 값은 낮출 수 없고** 그 요청은 과금된다. "2배·30분"과 "프로비저닝 버스트 5분"은 쓰지 않았다 | `saa-t3-6` §5 (갭 배치 B8a) |
| R-15 | **Aurora Global Database의 1차 Replica 한도**(갭 노트는 "보조 클러스터 읽기 인스턴스 16"만 적어 트레이드오프를 빠뜨렸다) | 공식 구성 요건으로 확정(2026-10-21): **1차 클러스터의 Aurora Replica 수 = 15 − (보조 리전 수)** — "1차의 리더 수 + 보조 클러스터 수 ≤ 15". 보조 리전 10개면 1차는 5개만. 보조 리전 합계 읽기 전용 인스턴스는 16, 보조에는 라이터가 0. **메모리 최적화 클래스 필요(`db.r5` 이상 권장)**. ⚠️ Global DB는 **Backtrack·보조 클러스터 Aurora Auto Scaling·자동 마이너 업그레이드를 지원하지 않는다** | `saa-t3-5` §7 (갭 배치 B8a) |
| R-16 | **DynamoDB 글로벌 테이블 일관성 모드**(기존 본문·문항이 충돌 해소를 last-writer-wins로만 서술) | 공식이 두 모드로 확정(2026-10-21): **MREC**(기본·비동기·보통 1초 내·LWW)와 **MRSC**(동기·최소 1개 다른 리전 복제 후 반환·강력 일관성 읽기는 항상 최신). LWW는 **MREC의 동작**이고 MRSC에서는 충돌이 `ReplicatedWriteConflictException`으로 드러난다. MRSC의 값: **정확히 3리전**(복제본 3 또는 복제본 2+**증인** 1)·**트랜잭션 API 미지원**·쓰기·강력읽기 지연 증가·**생성 후 모드 변경 불가**·복제본별 다른 모드 불가 | `saa-t3-6` §7 (갭 배치 B8a) |
| R-17 | **Route 53 라우팅 정책 수**(기존 본문이 **7종**으로 적어 `IP 기반`이 빠져 있었다) | 공식 "Choosing a routing policy"로 확정(2026-10-21): **8종** — Simple · Failover · Geolocation · Geoproximity · Latency · **IP-based** · Multivalue answer · Weighted. 다중값 응답은 **최대 8개** 정상 레코드를 무작위 반환. 지연·지리 정책은 사용자 위치를 **DNS 리졸버 위치**로 추정하고 리졸버가 **EDNS0 클라이언트 서브넷**을 지원하면 더 정확해진다. `saa-t3-7.md` 4개소를 정정했고 **문항 뱅크에는 `7종`이 0건**이었다 | `saa-t3-7` §3 (갭 배치 B8b) |
| R-18 | **MACsec 선택지**(`G-3.4-05`·`G-1.2-03`; 기존 서술은 IPsec 오버레이만 제시) | 공식 Direct Connect 문서로 확보(2026-10-21): **IEEE 802.1AE**, **전용 연결 10·100·400 Gbps**의 **선택된 PoP**에서만. 10 Gbps는 GCM-AES-256/XPN-256, 100·400 Gbps는 **GCM-AES-XPN-256**이며 **100/400은 XPN 필수**(32비트 패킷 번호 공간 소진 때문). **256비트 키만**, CKN/CAK 쌍, **SCI 상시 활성**, **dot1q-in-clear 미지원**. ⚠️ **홉 단위로 링크를 보호하므로 고객 장비가 AWS DX 장비와 직접 2계층 인접이어야 하고, 따라서 종단 간 암호화가 아니다** | `saa-t3-8` §4 (갭 배치 B8b) |
| R-19 | **CloudFront 오리진 그룹 장애 조치의 좁은 조건** | 공식 확인(2026-10-21): 장애 조치는 **뷰어 요청 메서드가 `GET`·`HEAD`·`OPTIONS`일 때만** 일어난다(`POST`·`PUT` 등은 안 됨). 상태 코드별로 2xx는 캐시·반환, **3xx는 뷰어에 그대로 반환**, 4xx/5xx는 **장애 조치용으로 구성한 코드만** 보조로 넘긴다(연결 실패 503·타임아웃 504를 설정해야 잡힌다). ⚠️ CloudFront는 **들어오는 모든 요청을 언제나 프라이머리로** 보내므로 **보조가 프라이머리를 대체하는 전환이 아니다** | `saa-t3-7` §5 (갭 배치 B8b) |
| R-20 | **NLB 클라이언트 IP 보존의 기본값이 대상 그룹 유형마다 다름** | 공식 확인(2026-10-21): 인스턴스 타입 **활성**, IP 타입 UDP·TCP_UDP·QUIC·TCP_QUIC **활성(비활성화 불가)**, ⚠️ **IP 타입 TCP·TLS는 비활성**(`preserve_client_ip.enabled`로 켠다). 보존 시 트래픽이 NLB→대상으로 **직접** 흘러야 하고 같은 VPC 또는 같은 리전 피어링 VPC여야 한다. ⚠️ **Transit Gateway 경유 대상과 GWLB 엔드포인트 검사 구간에서는 미지원**이며 변경은 **새 TCP 연결에만** 적용된다 | `saa-t3-7` §8 (갭 배치 B8b) |
| R-21 | **QuickSight 의 현행 명칭과 상위·하위 구조**(갭 노트 `G-3.5-07`은 "서비스 명칭 Amazon Quick"으로만 적었다) | 공식 "What is Amazon Quick?"으로 확정(2026-10-21): **`Amazon Quick`** 이 AI 기반 **상위 서비스**이고, QuickSight 는 그 안의 **`Amazon Quick Sight`**(두 단어) **기능**으로 이어진다 — *"Amazon Quick evolved from Amazon QuickSight. QuickSight continues as Amazon Quick Sight, a feature within Quick."* ⚠️ **기존 QuickSight API·SDK·연동은 변경 없이 동작**하고 네임스페이스도 `quicksight` 그대로다. 문서 경로는 `/quick/` 으로 이동. 형제 기능: Quick Flows·Quick Automate·Quick Index·Quick Research·Apps in Amazon Quick. ⚠️ **옛 표기가 레포 전체 9파일 4자격증에 남아 있어 전역 통일은 별 트랙**(B8c 는 `saa-t3-9` 만) | `saa-t3-9` §8 (갭 배치 B8c) |
| R-22 | **Quick Sight VPC 연결의 데이터 소스 제약** | 공식 확인(2026-10-21): OpenSearch·Redshift·RDS·Aurora·Impala·Databricks·Exasol·MariaDB·SQL Server·MySQL·Oracle·PostgreSQL·Presto·Snowflake·Starburst·Teradata·Trino 는 VPC 연결 지원. ⚠️ **Athena · Google BigQuery · Apache Spark · Timestream 과 SaaS 커넥터(Salesforce·ServiceNow·Jira·GitHub)는 미지원**이며, 미지원 소스에 붙이면 요청이 **invalid parameter 오류로 실패**한다. "Athena 쿼리를 VPC 연결로 사설화"는 오답이고 Athena 쪽은 VPC 엔드포인트 문제다 | `saa-t3-9` §8 (갭 배치 B8c) |
| R-23 | **Kinesis Data Streams 보존 모델**(갭 노트는 "보존 확장 7일 / 장기 365일 요금 구조"로 적었다) | 공식 확정(2026-10-21): **기본 24시간**(생성 시) · **최소 24시간**(`DecreaseStreamRetentionPeriod`) · **최대 8,760시간 = 365일**(`IncreaseStreamRetentionPeriod`) · ⚠️ **24시간 초과분에 추가 요금**. **7일은 보존 한도가 아니다.** 늘리면 수 분 내 반영되지만 ⚠️ **이미 만료된 데이터는 되살아나지 않고**, 줄이면 새 기간보다 오래된 레코드가 **거의 즉시 접근 불가**가 된다. 기존 §3 표의 "최대 365일"은 옳았다 | `saa-t3-9` §3 (갭 배치 B8c) |
| R-24 | **Kinesis 향상된 팬아웃(EFO)의 정확한 효과** | 공식 비교표로 확정(2026-10-21): 공유 처리량 소비자는 **샤드당 총 2 MB/초를 나눠 쓰고**, EFO 소비자는 **각자 샤드당 최대 2 MB/초**를 독립적으로 받는다. 전파 지연은 공유가 소비자 1개 ≈ 200 ms·5개 ≈ 1,000 ms, EFO 는 **일정하게 ≈ 70 ms**. 전달은 `GetRecords` 풀 vs `SubscribeToShard` **HTTP/2 푸시**. 등록 한도는 **On-demand Advantage 50 / Standard·Provisioned 20**. ⚠️ **EFO 는 읽기 쪽 기능이라 샤드의 입력(쓰기) 처리량을 늘리지 않는다** | `saa-t3-9` §3 (갭 배치 B8c) |
| R-25 | **S3 소형 객체의 전환 비용 구조**(갭 노트 `G-4.1-02`가 "Glacier 객체당 40 KB 오버헤드"만 적었다) | 공식 수명 주기 문제 해결 문서로 내역까지 확정(2026-10-21): 객체당 **총 40 KB** 중 **8 KB(메타데이터·객체 이름)는 S3 Standard 요율**, **32 KB(인덱싱·메타데이터)는 Glacier FR/DA 요율**로 과금된다. 그래서 공식은 **작은 객체가 많으면 수명 주기 전환을 권장하지 않고** 큰 객체로 **집계**하라고 안내한다. 더해 IA·One Zone-IA 는 **128 KB 미만이면 128 KB 로 과금**되고, 전환은 **건당 전환 요청**으로 과금된다 | `saa-t4-1` §3 (갭 배치 B9a) |
| R-26 | **수명 주기 기본 최소 전환 크기**(2024-09 이후 동작) | `GetBucketLifecycleConfiguration` 의 **`x-amz-transition-default-minimum-object-size`** 로 확정(2026-10-21): **`all_storage_classes_128K`** 는 **128 KB 미만을 어떤 클래스로도 전환하지 않고**, `varies_by_storage_class` 는 **Glacier FR·DA 로만** 전환한다. 전환 규칙의 **`ObjectSizeGreaterThan`·`ObjectSizeLessThan` 커스텀 필터가 기본 동작보다 항상 우선**하며, ⚠️ 이 동작은 **일반 목적 버킷 전용**(디렉터리 버킷 미지원)이다 | `saa-t4-1` §3 (갭 배치 B9a) |
| R-27 | **EBS Snapshots Archive 의 비용 함정** | 공식 고려사항·제한으로 확정(2026-10-21): 최소 **90일** · 복원 **최대 72시간** · ⚠️ **아카이브 스냅샷은 항상 전체(full) 스냅샷**이라 원본 증분보다 클 수 있고, **단일 볼륨의 일별 증분 스냅샷을 아카이브하면 표준 티어보다 비싸질 수 있다**(월·분기·연 단위에 권장) · ⚠️ **블록 디바이스 매핑·볼륨 생성에 쓸 수 없다** · 계보가 참조하는 데이터는 표준 티어에 남아 **다음 스냅샷에 비용이 배분**된다 · Recycle Bin 규칙에 걸리면 **복구 → 복원 2단계** · DLM `RetentionArchiveTier` 는 **최소 90일**을 보장해야 한다. ⚠️ 갭 노트의 **"최대 75% 절감"은 확보하지 못해 쓰지 않았다** | `saa-t4-1` §4 (갭 배치 B9a) |
| R-28 | **Storage Lens 무료 vs 고급 티어 경계**(갭 노트 `G-4.1-16`) | 공식 지표 선택 문서로 확정(2026-10-21): 무료는 사용량 + **사용 사례 기반 지표(비용 최적화·데이터 보호)** 이고 쿼리 **14일**, 고급은 **활동 지표·상세 상태 코드·권장 사항·CloudWatch 퍼블리싱·접두어 집계**를 더해 쿼리 **15개월**이며 ⚠️ **추가 요금**이다. ⚠️ **Storage Lens 그룹에는 무료 티어 스토리지 지표만** 제공돼 **그룹 수준에서는 고급 지표를 쓸 수 없다**. 기존 본문·드래프트 해설이 "권장사항을 제공한다"를 티어 구분 없이 적고 있어 양쪽을 정밀화했다 | `saa-t4-1` §7 (갭 배치 B9a) |

---

## 5. 레포 JSON 수정 제안 (J)

**대상 파일**: `flutter_app/assets/exam_guides/SAA-C03.json`(한 줄 JSON). 공식 ko 원문과의 항목 단위 대조(189개 중 4개 불일치)는 `00-overview.md` §4. **이 문서에서는 파일을 수정하지 않았다**(쓰기 범위 밖). 적용은 별도 작업(브랜치 `develop` 기준 PR)에서 수행.

| ID | 위치 | 교체 전(`old`) | 교체 후(`new`) | 비고 |
|---|---|---|---|---|
| J-1 | Task 1.2 지식 5번째 | `적절한 사용 사례를 갖춘 보안 서비스(예: AWS Cognito, AWS GuardDuty, AWS Macie)` | `보안 서비스와 적합한 사용 사례(예: Amazon Cognito, Amazon GuardDuty, Amazon Macie)` | 문구 어순+서비스 접두어(Amazon). 문자열은 JSON 전체에서 1곳 |
| J-2 | Task 3.4 지식 3번째 | `로드 밸런싱 개념(예: Application Load Balancer)` | `로드 밸런싱 개념(예: Application Load Balancer(ALB))` | "(ALB)" 추가 |
| J-3 | Task 3.5 지식 1번째 | `…AWS Lake Formation, Amazon QuickSuite)` | `…AWS Lake Formation, Amazon Quick)` | `Amazon QuickSuite`→`Amazon Quick`. 문자열은 1곳 |
| J-4 | Task 4.4 지식 3번째 | `로드 밸런싱 개념(예: Application Load Balancer)` | `로드 밸런싱 개념(예: Application Load Balancer(ALB))` | J-2와 같은 문자열. **치환 시 JSON 전체에서 정확히 2곳(3.4·4.4)** 이 대상이며, Task 2.1은 이미 `…Application Load Balancer(ALB))`·2.2는 `…(예: ALB)`이므로 건드리지 않는다 |

**적용 전 확인(읽기 전용)**: ① `old` 문자열 출현 횟수가 각각 J-1=1·J-2/J-4=2(합산)·J-3=1인지 `Grep -c` 또는 `grep -o … | wc -l`로 확인(J-2/J-4 패턴은 닫는 따옴표까지 포함한 `Application Load Balancer)"`로 검색하면 2.1과 구분됨). ② 수정 후 항목 수(Knowledge 107·Skills 82)와 도메인 `weightPct`·`overview`는 그대로여야 한다.

**테스트 영향 점검(읽기 전용 확인)**: `flutter_app/test/content_index_test.dart:161-179`는 JSON의 `overview.scoredQuestions+unscoredQuestions`와 도메인 `no`/`weightPct`가 readiness 정책(65문항, 30/26/24/20)과 동기화되는지만 검사한다. J-1~J-4는 문구 표기만 바꾸므로 이 검사에 영향이 없다. `QuickSuite`·`AWS Cognito, AWS GuardDuty` 문자열은 `.dart` 코드에서 사용되지 않음(Grep 확인). 변경 후에는 사용자 환경에서 `flutter test`로 확인한다(이 연구에서는 실행하지 않음).

**선택 제안**: JSON `overview`의 `durationMinutes`(130)는 웹 가이드에 없고 인증 페이지에서만 확인되므로 출처 주석/문서화 시 인증 페이지 URL을 병기하는 것이 정확하다(`00-overview.md` §1).

---

## 6. 정정 우선순위 요약 (`98-existing-gap.md` 연동)

**① 사실이 틀린 항목 `[오류]` 6건** — 학습자가 오답을 외울 위험이 큼
| 98 ID | 요지 |
|---|---|
| G-1.1-07 | SCP 리전 제한 예시가 `Deny *`+`aws:RequestedRegion`이라 IAM·Organizations·Route 53 등 **글로벌 서비스 호출까지 차단** — NotAction 예외 필요 |
| G-1.2-06 | CloudFront용 WAF 웹 ACL은 **US East (N. Virginia)에서 생성** (문서는 "제한 없음") |
| G-1.3-06 | KMS 접근은 "IAM과 키 정책의 교집합"이 아님 — 기본 키 정책의 **계정 루트 위임 문장** 유무가 결정 |
| G-2.1-10 | SNS→Lambda/SQS는 서버 측 오류 시 대규모 재시도(최대 100,015회·23일)+구독 DLQ — "제한 횟수 후 폐기" 서술은 오류 |
| G-3.3-10 | **gp3에는 버스트 크레딧이 없음**(gp2만) |
| G-3.4-10 | **Global Accelerator의 엔드포인트에 CloudFront는 없음** — "GA 뒤 CloudFront"/"CloudFront에 GA 고정 IP" 조합은 성립하지 않음 |

**② 고영향 구식·부정확** (예)
| 98 ID | 요지 |
|---|---|
| G-3.1-09 | S3 단일 객체 최대 **5TB** → 현행 50 TB(C-01) |
| G-3.5-09 | **Snow 패밀리**를 현재 선택지로 서술 → 신규 주문 불가 |
| G-3.3-13 | "Aurora Serverless v2" → "Aurora serverless" 개명 |
| G-4.2-12·13 | Convertible RI "54%"→66%, Savings Plans **3종→4종**(Database 추가) |
| G-4.3-12·13 | "RDS는 RI뿐/구성이 바뀌면 RI 소멸" → Database SP 존재, RDS RI **사이즈 유연성**(SQL Server·Oracle LI 제외) |
| G-4.3-15 | Timestream "관계형의 1/10 비용" → LiveAnalytics **신규 불가** |
| G-4.4-12 | TGW "교차 AZ $0.01+$0.02" → **TGW 경유 AZ 간 추가 전송 요금 없음** |
| G-4.4-17 | 공용 IPv4 **시간당 과금(2024-02-01)** 미반영 |
| G-4.1-13 | "Terminate해야 EBS 요금 중단" → 추가 데이터 볼륨은 기본 보존 |
| G-4.1-22 | CUR만 서술 → Data Exports **CUR 2.0이 권장** |

**③ 누락이 큰 공식 항목** (Knowledge/Skill을 아예 다루지 않음)
| 98 ID | 요지 |
|---|---|
| G-4.1-01·02·03·04 | Requester Pays, 배치 vs 개별 업로드, 스토리지 오토 스케일링, 하이브리드 이전 서비스(DataSync·Transfer Family·Storage Gateway) |
| G-4.2-01·02·03 | 로드 밸런싱 비용(LCU), EC2 최대 절전·수평/수직, 프로덕션 vs 비프로덕션 가용성 |
| G-4.3-01·02·03·04 | DMS/SCT 마이그레이션(전 문서 0건), MySQL vs PostgreSQL, 시계열·열 기반 DB, RDS Proxy 비용 |
| G-4.4-01~07 | ALB 비용, NAT instance 비교, **VPN 전반**, Route 53, 스로틀링, 기존 워크로드 검토, 공용 IPv4 |
| G-1.1-01·02 | 디렉터리 서비스↔IAM 역할 연동, 공동 책임 모델 |
| G-3.1-01·G-3.5-06 | Storage Gateway(24개 문서 전체 0건) |

---

## 7. 건수 요약 (최종 검증 단계에서 `grep`으로 집계, 2026-10-19)

| 구분 | 건수 | 비고 |
|---|---|---|
| C — 공식 자료 간 상충 | **21** | §1 |
| V — 확인 필요(미확보) | **82행 중 80건 열림** | §2. 해소 표시 2행(V-12→R-8, V-44→R-7)은 번호 유지용. Task군별: 1.x=7, 2.x=11(열림 10), 3.x=27, 4.x=34(열림 33), 메타=3 |
| G — 전 문서 공통 이슈 | **5** | §3 |
| **열린 항목 합계(C+V+G)** | **106** | 21 + 80 + 5 |
| R — 이번 단계에서 해소된 이전 미확보 | 8 | §4 (R-1~R-8) |
| J — 레포 JSON 수정 제안 | 4 | §5. 공식 ko 원문 대조 189개 항목 중 불일치 4건 |
| `98-existing-gap.md`에서 이 파일을 가리키는 행 | 37 | 전부 이 파일에 인용됨(교차 검증 완료) |
| `98`의 `[오류]` 행 | 6 | §6 ① |

> 주의: 위 건수는 **항목(행) 단위**다. 한 행이 여러 사실을 묶는 경우(예: V-64, V-67)가 있어 사실 단위로 세면 더 많다.
