# SAA·SOA `[누락]`·`[부분]` 인벤토리 + 배치 계획 — 2026-10-20

> ✅ **B2 완료 — PR #172** https://github.com/VelkaressiaBlutkrone/aws-docs/pull/172
> 브랜치 `saa-review/gaps-db-migration` → base `develop`(`dd05bf0`에서 분기), 커밋 `eedeba1`. **머지 안 함.**
> 5항목 — `saa-t3-5` §10 DMS·SCT · §11 쓰기 집약 한계 / `saa-t3-6` §15 목적별 DB /
> `saa-t4-3` §6 마이그레이션 비용 · §7 시계열·열 기반 과금 축. 신규 가드 18 테스트.
> 게이트: `flutter test` **1,324 그린**(base 1,306 + 18) · `analyze` 0건 · `prescreen` 0건.
> 문항 대조 어긋남 **0건**(t3-5·t4-3은 라이브 15/15).
> 근거 제약 준수: **V-74**(열 기반 비용 우열 단정 금지) 가드로 못박음 · **V-72**(MemoryDB
> 범위 불확실) 시험 범위 주장 없이 선택 축으로만 · **G-3.3-09**는 블로그 근거 대신 Aurora
> 사용자 가이드로 1차 근거 새로 확보해 저작.
>
> ✅ **B1 완료 — PR #168 (머지됨)** https://github.com/VelkaressiaBlutkrone/aws-docs/pull/168
> 브랜치 `saa-review/gaps-hybrid-storage` → base `develop`, 커밋 `bdee35e`. **머지 안 함.**
> 4항목(G-3.1-01·G-3.5-06·G-4.1-04·G-2.1-04) 반영 — `saa-t3-2` §9 신설 ·
> `saa-t3-9` §10 보강 · `saa-t4-1` §8 신설. 신규 가드 16 테스트.
> 게이트 실측: `flutter test` **1,305 그린**(base develop 1,289 + 16) · `analyze` 0건 ·
> `saa_prescreen build` 플래그 0건. 문항 대조 어긋남 **0건**.
>
> **다음 세션이 알아야 할 것 3가지**
> 1. **조사 노트가 틀린 항목이 있다.** `G-2.1-04` 의 "Transfer Family 는 중지해도 과금
>    없음"은 공식 FAQ 와 반대다(중지해도 과금 계속, **삭제해야** 멈춤). 노트의 주장도
>    공식으로 재확인하고 쓸 것.
> 2. **FSx File Gateway 는 2024-10-28부터 신규 고객 이용 불가**(공식 Document history).
>    Storage Gateway 4유형을 쓸 때 ⚠️ 표기가 필요하다.
> 3. **`expectLastVerifiedAtLeast` 헬퍼를 `saa_t2_t4_facts_test.dart` 에 넣었다.**
>    같은 파일의 리터럴 단정 4곳(2.x·3.1·3.2·3.3~3.5·4.x)은 전부 단조 비교로 바뀌었으니,
>    다음 배치는 lastVerified 때문에 RED 를 만나지 않는다. `saa_t1_facts_test.dart`
>    (t1-1·t1-2)와 `saa_t12_t13_facts_test.dart` 의 t1-3·t1-4 단정은 **아직 리터럴**이다.

세션: stoic-wescoff-0bbe62 · 브랜치 `claude/stoic-wescoff-0bbe62`(HEAD `f8078f6`)
**판정 기준 스냅샷**: `origin/develop` = `4bec79b` (PR #164·#165·#166 머지 완료 상태).
워크트리 HEAD는 develop보다 6커밋 뒤라 `git show origin/develop:…`로 md를 꺼내 대조했다.
md 차이는 `saa-t1-5.md` 한 개뿐(나머지 23개는 HEAD == develop).

> ⚠️ 컨트롤러 브리핑의 "PR #166은 develop 미머지"는 **지금은 틀리다** — `4bec79b`로 머지됐다.
> 사이드 노트 `saa-aurora-naming-done.md`가 쓰인 시점 이후에 들어갔다.

> 📌 **2026-10-20 추가**: 워크트리 브랜치에 `origin/develop`을 머지했다(머지 커밋 `808d9aa`,
> 충돌 0). 판정은 머지 **전부터** `git show origin/develop:…`로 꺼낸 develop 사본으로 했고,
> 머지 후 워킹트리 md 24개를 그 사본과 전수 비교해 **내용 차이 0**(CRLF만 다름)을 확인했다 —
> 아래 판정은 그대로 유효하다. 머지로 들어온 새 가드 `saa_t1_5_facts_test.dart`에는
> `lastVerified` 단정이 **없다**(§3 공통 제약 4의 3파일 목록은 그대로다).

---

## 0. 전체 수치 (실측)

| 구분 | 노트 기록 | 실측(행 단위) | 이미 해소 | 근거 미확보 | 작업 불필요 | **실질 열림** |
|---|---|---|---|---|---|---|
| `[누락]` | 50 | **50** | 1 | 0 | 1 | **48** |
| `[부분]` | 84 | **84** | 2 | 1 | 0 | **81** |
| 합계 | 134 | **134** | 3 | 1 | 1 | **129** |

- 컨트롤러 브리핑의 52/86은 과다 집계다. 행 머리의 분류 코드로 집계하면 `[누락]` 50 ·
  `[부분]` 84이고, 태그가 둘째 칸에 오는 행은 없다(anywhere 집계도 같은 수).
- **실질 열림 129 중 18행은 「축소」** — 2026-10-19 PR #137~#140 / 2026-10-20 PR #164가 일부를
  이미 메웠고 잔여만 남았다. 배치 때 그 잔여만 쓰면 된다.

### 이미 해소된 3행 (노트 분류를 그대로 믿으면 안 되는 증거)

| ID | 원 분류 | 해소 경위 | 현재 위치 |
|---|---|---|---|
| `G-4.4-07` | `[누락]` 공용 IPv4 요금 — 24문서 0건 | PR #140 | `saa-t4-4.md:109-116` 2024-02-01 $0.005/IP/시간 + NAT 손익 계산식 |
| `G-2.1-12` | `[부분]`·`[구식]` Lambda 비동기 | PR #139 | `saa-t2-2.md:103,106` 이벤트 큐 6시간 · Destinations 성공/실패 분리 · S3는 on-failure 전용 |
| `G-1.3-04` | `[부분]` 교차 계정 KMS 키 | PR #140 | `saa-t1-5.md:118,145` AWS 관리형 키 공유 불가 → 교차 계정 EBS 스냅샷은 CMK · 교차 계정만 양쪽 필요 |

### 제외 2행

| ID | 사유 |
|---|---|
| `G-1.2-05` `[부분]` IMDSv2·Session Manager | 갭 노트 본문이 직접 "공식 근거를 확보하지 못함 → `99-gaps.md`"로 돌렸다. `99-gaps` **V-04**로 등재. **2단계에서 쓰지 않는다.** |
| `G-1.1-02` `[누락]` 공동 책임 모델 | 매핑 문서 `docs/plans/saa-c03-task-mapping.md:122`가 "배경지식(별도 학습문서 불필요)"로 이미 판정. 되살리려면 그 판정을 먼저 뒤집어야 한다 → **작업 불필요**로 분류. |

---

## 1. (a) Task별 열림/해소 — SAA

행수는 `98-existing-gap.md`의 행 단위. 「축소」는 일부가 메워져 잔여만 열린 행이다.

| Task | 문서 | 열린 `[누락]` | 열린 `[부분]` | 이미 해소 | 그중 축소 |
|---|---|---|---|---|---|
| 1.1 | t1-1, t1-2 | 2 (+1 작업 불필요) | 4 | 0 | 1 |
| 1.2 | t1-3, t1-4 | 2 | 4 (+1 근거 미확보) | 0 | 0 |
| 1.3 | t1-5 | 2 | 3 | **1** | 1 |
| 2.1 | t2-1, t2-2 | 2 | 7 | **1** | 1 |
| 2.2 | t2-3, t2-4, t2-5 | 6 | 6 | 0 | 0 |
| 3.1 | t3-1, t3-2 | 1 | 8 | 0 | 2 |
| 3.2 | t3-3, t3-4 | 2 | 8 | 0 | 0 |
| 3.3 | t3-5, t3-6 | 4 | 5 | 0 | 3 |
| 3.4 | t3-7, t3-8 | 1 | 8 | 0 | 2 |
| 3.5 | t3-9 | 3 | 5 | 0 | 2 |
| 4.1 | t4-1, t4-5 | 5 | 8 | 0 | 0 |
| 4.2 | t4-2 | 6 | 6 | 0 | 2 |
| 4.3 | t4-3 | 6 | 5 | 0 | 3 |
| 4.4 | t4-4 | 6 | 4 | **1** | 1 |
| **계** | | **48** | **81** | **3** | **18** |

### 축소된 18행 — 잔여만 쓰면 되는 것

| ID | 메워진 것 (출처 PR) | 남은 것 |
|---|---|---|
| G-1.1-01 | Directory Service 3종 명칭·Simple AD 미지원 (`t1-1:198,292`, #137) | 세 서비스 **선택 기준** |
| G-1.3-02 | S3 Bucket Key·DSSE-KMS (`t1-5:151`, #164) | Object Lock 모드(거버넌스/컴플라이언스/리걸홀드)·RTC |
| G-2.1-06 | 이벤트 큐 6시간·Destinations (#139) | `/tmp` 크기·동시성 1,000·확장 속도·페이로드 6MB/1MB·이미지 10GB·`ReportBatchItemFailures` |
| G-3.1-02 | io2 Block Express 256,000 IOPS (`t3-2:117,288`) | EBS 최적화 인스턴스·Nitro 조건·I/O 크기 기준·gp3 수식 |
| G-3.1-04 | EFS Max I/O = 이전 세대·Elastic 병용 불가 (`t3-2:198`, #140) | Elastic vs Provisioned 판단 기준(5%)·모드별 지연/IOPS·One Zone 차이 |
| G-3.3-03 | ElastiCache 엔진 3종 Valkey 포함 (`t3-6:196`, #140) | ElastiCache Serverless·복제 그룹 Multi-AZ·다운그레이드 불가·MemoryDB 구분 |
| G-3.3-04 | 스토리지 자동 확장 256TiB (`t3-5:182`) | PIOPS 범위·Aurora I/O-Optimized 25% 기준·Performance Insights |
| G-3.3-07 | 파티션당 3,000/1,000 (`t3-6:184`) | 항목 400KB·온디맨드 2배 규칙·신규 테이블 초기 처리량·적응형 용량 |
| G-3.4-04 | 고정 IP 패턴·GA 엔드포인트 4종 (`t3-7:186~252`, #140) | ALB 가중 대상 그룹·최소 미처리 요청·GENEVE 6081·소스 IP 보존 |
| G-3.4-05 | DX 복원력 SLA 99.99/99.9 (`t3-8:212`, #140) | 속도 범위·전용/호스팅·MACsec·SiteLink |
| G-3.5-04 | EFO 2MB/s·20·50 · 온디맨드 vs 프로비저닝 (`t3-9:100,327`, #140) | 보존 확장/장기 요금·MSK vs Kinesis 선택·Redshift 스트리밍 수집 |
| G-3.5-07 | SPICE (`t3-9:241`) | 직접 쿼리 비교·임베디드·ML 인사이트·VPC·Amazon Quick 명칭 |
| G-4.2-07 | Lambda 1ms·Fargate 초/최소 1분·프로비저닝 동시성 (`t4-2:239`, #140) | Fargate Spot 70%·break-even 비교 |
| G-4.2-11 | `price-capacity-optimized` (`t4-2:167,174`, #140) | 다양화(풀=AZ×유형)·속성 기반 선택·배치 점수·재조정 권고 |
| G-4.3-03 | Timestream for InfluxDB (`t4-3:81`, #140) | Redshift·Athena/Parquet 열 형식의 비용 관점 |
| G-4.3-06 | Database Savings Plans (`t4-3:61,248`, #140) | RPU·DynamoDB 예약 용량·Standard-IA 테이블 클래스·TTL·Aurora I/O-Optimized |
| G-4.3-11 | Compute Optimizer RDS 권고 (`t4-3:142`) | Trusted Advisor RDS 유휴·예약 최적화·Budgets RI 알림 |
| G-4.4-10 | TGW 경유 AZ 간 전송 무과금 (#140) · PrivateLink 요금 (`t4-4:142`) | 리전 간 TGW 피어링 처리+전송·공유 TGW 시간 요금 부담 주체 |

### 전역 0건이 유지되는 「큰 구멍」 (develop 기준 실측 grep)

`Storage Gateway` 0 · `DMS`/`Schema Conversion` 0 · `X-Ray` 0 · `Service Quotas` 0 ·
`Lambda@Edge`/`CloudFront Functions`/`Local Zone`/`Wavelength` 0 · `MemoryDB` 0 ·
`Requester Pays` 0 · `NAT 인스턴스` 0 · `RCP`/`리소스 제어 정책` 0 · `Cloud WAN` 0 ·
`ExternalId`/`혼동된 대리인` 0 · `GuardDuty` 0 · `MACsec` 0 · `IPAM` 0 · `ECMP` 0 ·
`App2Container` 0 · `백오프`/`지터` 0 · `Comprehend`/`Polly`/`Textract` 0.
(`Outposts`는 `t3-9:306,386`에 Snow 대안으로 한 줄 생겼다 — 컴퓨팅 맥락은 여전히 0.)

---

## 2. (b) SOA 쪽에 남은 「없음/부분」

SOA `98-existing-gap.md`는 대괄호 태그를 쓰지 않는다. 판정 축은 **§3 Skill별 커버리지(53개)**
= 충분 1 · **부분 45** · **없음 7** 이다. §4(v1.1 신규 주제)는 PR #159가 13항목 전부 소비했다.

### 「없음」 7개 중 남은 것 = **6개**

| Skill | 요지 | 현재 실측 | 판정 |
|---|---|---|---|
| 1.1.5 | SNS 구성(주제 액세스 정책·SSE-KMS·구독 확인·전송 재시도/DLQ·FIFO) | `주제 정책`·`구독 확인`·`FIFO` 전부 0건 | **열림** |
| 1.3.3 | S3 성능 전략(DataSync·Transfer Acceleration·멀티파트·수명 주기) | `DataSync`·`Transfer Acceleration`·`멀티파트`·`Intelligent-Tiering`·`Express One Zone` **전부 0건** | **열림(전무)** |
| ~~1.3.4~~ | 공유 스토리지(EFS·FSx·S3 Files) | PR #159가 `soa-t1-5.md:223-278`에 3축 비교표·EFS 수명 주기(30일 IA/90일 Archive)·FSx 4유형·S3 Files 신설 | **해소** |
| 3.1.6 | 서드파티 배포 도구(Terraform·Git) | `Terraform`·`CodeCommit`·`CodePipeline` 0건 | **열림(전무)** |
| 4.2.1 | 데이터 분류 체계 | `데이터 분류`·`ABAC` 0건, `태그 정책` 1건(백업 맥락) | **열림(전무)** |
| 5.1.3 | 네트워크 보호 서비스 감사(DNS Firewall·WAF·Shield·Network Firewall) | `Shield`·`Network Firewall`·`DNS Firewall`·`Firewall Manager` 0건, `WAF`는 `soa-t5-3` 한 줄 | **열림(거의 전무)** |
| 5.3.5 | CloudWatch 네트워크 모니터링 | `Internet Monitor`·`Network Monitor`·`Flow Monitor` 0건 | **열림(전무)** |

### 「부분」 45개에 대한 판정

**배치 대상으로 올리지 않기를 권한다.** 이 45는 SAA처럼 개별 사실 갭이 아니라
**Skill 단위 커버리지 등급**이다("일부만 다룸"). 53개 Skill 중 52개가 충분이 아닌 구조라,
45를 일감으로 치면 SOA 학습문서 20편 전면 재집필이 된다. 그중 8개(1.1.1·1.2.1·3.1.2·3.2.2·
4.1.3·4.1.5·4.2.5·5.1.2)는 PR #159가 이미 v1.1 축으로 한 번 보강했다.

→ **SOA의 실질 작업 대상은 「없음」 6개**다. SAA 129행이 끝난 뒤, 또는 SOA 문항 flip
(현재 `verified:true` **0개**, 20문서 전부 `questionCount: 0`) 준비와 묶어 잡는 게 맞다.

---

## 3. (c) 배치 계획

### 공통 제약

1. **1차 배치에서 `saa-t1-1`·`saa-t1-4`·`saa-t2-5` 제외.** 이 세 Task 45문항이 2차 재검수까지
   끝나 **사람의 flip만 남았다.** 지금 md를 늘리면 검수 기준이 흔들린다. → **B11**로 미룸.
2. 브랜치 `saa-review/gaps-<배치명>`, base `develop`. (`.saa-frozen` 없음 = 가드 dormant, 규약은 준수)
3. **md는 라이브 학습문서** — 모든 배치가 라이브 노출 변경. PR 본문에 명시.
4. **lastVerified 갱신 시 테스트가 깨진다.** `lastVerified: 2026-10-19`를 **리터럴로 못박은**
   단정이 3파일에 있다:
   - `saa_t1_facts_test.dart:141-143` → t1-1, t1-2
   - `saa_t12_t13_facts_test.dart:170-172` → t1-3, t1-4
   - `saa_t2_t4_facts_test.dart:98-101 / 184-187 / 326-335 / 534-543` → t2-1,2-2,2-3,2-5 /
     t3-1,3-2,3-3,3-4 / t3-5~t3-9 / t4-1~t4-5
   → **단조 비교로 바꾼다.** 선례가 develop에 이미 있다:
   `saa_t12_t13_facts_test.dart:161-172` (PR #164 — `lastVerified` 날짜를 정규식으로 뽑아
   `compareTo('2026-10-19') >= 0`). 같은 PR에서 해당 그룹만 바꾼다.
5. **라이브 문항이 있는 문서**(`verified:true` 15/15): **`saa-t2-1`·`saa-t3-2`·`saa-t3-4`·
   `saa-t3-5`·`saa-t4-2`·`saa-t4-3`**. 나머지 18문서는 0/15 드래프트(노출 0).
   라이브 문서를 건드리는 배치는 문항 대조를 더 깐깐히 한다.
6. 문항(`*.questions.json`)·`questionCount`·`verified`는 **건드리지 않는다.** 어긋나면 id만 적고 별건.

### 우선 배치 (근거 확실 + 학습 영향 큼)

| # | 배치 | 항목 | 문서 | 행 | 라이브 문항 |
|---|---|---|---|---|---|
| **B1** | 하이브리드 스토리지·전송 서비스 (Storage Gateway 4유형 · DataSync vs Transfer Family vs Snow 선택) | G-3.1-01 · G-3.5-06 · G-4.1-04 · G-2.1-04 | t3-2, t3-9, t4-1 | 4 | t3-2 |
| **B2** | DB 마이그레이션·목적별 DB (DMS·SCT·동종/이기종·CDC / DocumentDB·Neptune·Timestream·Keyspaces / 단일 라이터 한계) | G-3.3-01 · G-3.3-02 · G-4.3-01 · G-4.3-03 · G-3.3-09 | t3-5, t3-6, t4-3 | 5 | t3-5, t4-3 |
| **B3** | 운영 가시성·복원력 공식 예시 (X-Ray · Service Quotas · 불변 인프라 · 지수 백오프+지터 · 레거시 복원력) | G-2.2-01 ~ 06 | t2-3, t2-4 | 6 | 없음 |
| **B4** | 네트워크 비용 공식 예시 (NAT 인스턴스 비교 · Route 53 비용 · VPN 비용 · 스로틀링 · ELB LCU · GA 요금) | G-4.4-01~05 · G-4.4-08 · G-4.2-01 | t4-4, t4-2 | 7 | t4-2 |
| **B5** | 엣지·하이브리드 컴퓨팅 (CloudFront Functions vs Lambda@Edge · Local Zones · Wavelength · Outposts · Origin Shield/오리진 그룹) | G-3.2-01 · G-3.4-03 · G-3.4-08 · G-4.2-05 · G-4.2-06 | t3-4, t3-7, t4-2 | 5 | t3-4, t4-2 |
| **B6** | 거버넌스·데이터 보호 (RCP·선언적 정책 · SCP 수치 / Artifact·Config / Object Lock·RTC / 키 로테이션·키 표 / 서비스 엔드포인트·Gateway EP 제약) | G-1.1-05 · G-1.1-15 · G-1.3-01 · G-1.3-02 · G-1.3-03 · G-1.3-05 · G-1.3-15 · G-1.2-02 · G-1.2-15 | t1-2, t1-3, t1-5 | 9 | 없음 |

### 후속 배치 (수치 보강 — 개별 학습 영향은 작고 양이 많다)

| # | 배치 | 항목 | 문서 | 행 |
|---|---|---|---|---|
| B7 | 스토리지 수치 (EBS 성능·Elastic Volumes·EFS 모드·S3 Express·S3 성능·FSx·Multi-Attach·인스턴스 스토어) | G-3.1-02~08 · G-3.1-14 | t3-1, t3-2 | 8 |
| B8 | 스토리지 비용 (Requester Pays·배치 업로드·오토스케일링·백업 아카이브·HDD·FSx/EFS·수명 주기·크기·선택 매트릭스·비용 도구·Trusted Advisor·Storage Lens 티어) | G-4.1-01~03 · G-4.1-05~12 · G-4.1-16 | t4-1, t4-5 | 12 |
| B9 | 컴퓨트·오토스케일링 (SQS·Lambda·API GW·EKS 요금·purpose-built 표·App2Container·MQ/Pipes/AppFlow · 스케일링 지표·웜 풀·컨테이너·배치 그룹·T8i·ASG 운영) | G-2.1-01~03 · G-2.1-05~09 · G-3.2-02~09 · G-3.2-13 · G-2.2-11 | t2-1, t2-2, t2-3, t3-3, t3-4 | 18 |
| B10 | DB·네트워크 수치 (ElastiCache/용량/복제본/Proxy/DynamoDB/글로벌 · 서브넷·Cloud WAN·LB·DX·VPN·TGW·Route 53 · DB 비용 잔여 · CDN/피어링/DX 총비용) | G-3.3-03~08 · G-3.4-01·02·04~07·09 · G-4.3-02·04~11 · G-4.4-09~11 | t3-5~t3-8, t4-3, t4-4 | 25 |

### 마지막 배치 (사람 flip 완료 후에만)

| # | 배치 | 항목 | 문서 | 행 |
|---|---|---|---|---|
| B11 | flip 대기 3문서 잔여 | G-1.1-01·03·04·06 / G-1.2-01·03·04·11 / G-2.2-07~10·12 | t1-1, t1-3, t1-4, t2-5, t3-8 | 13 |

합계 4+5+6+7+5+9+8+12+18+25+13 = **112**. 나머지 17행은 「축소」분이라 각 배치 안에
잔여만 포함했다(§1 표). 전체 129행이 B1~B11에 배정된다.

### 각 배치의 문항 대조 점검 항목 (md 추가 ↔ 기존 문항)

PR #165의 전파 가드 `saa_question_propagation_test.dart`는 **"금지 문장이 문항에 없다"만**
검사한다 — md에 **추가**한 내용과 문항의 어긋남은 못 잡는다. 그래서 배치마다 직접 본다:

1. 그 배치가 건드리는 문서의 `*.questions.json`에서 **추가할 서비스·개념 이름**을 grep한다.
2. 히트가 있으면 `stem` / `options[correct]` / `explanation` / `wrongExplanations`를 읽고
   새 서술과 모순되는지 본다. **오답 보기(correct 아닌 `options`)는 제외** — 일부러 틀린
   서술이라 모순이 결함이 아니다(PR #165 교훈).
3. 절대화 표현(`유일`·`뿐`·`불가능`)을 함께 grep한다 — 새 수단을 추가하면 깨지는 문장이다.
4. 어긋나면 **문항 id만 PR 본문에 적고 고치지 않는다.**

**B1 사전 점검 결과 (이번 세션에서 이미 수행):**
- `유일` 전수: `t1-5`×1 · `t3-2`×2 · `t3-4`×1 · `t3-7`×1 · `t4-1`×1. B1 관련 3건을 읽었고
  모두 **충돌 아님**(`t3-2:47` gp2 IOPS↔용량, `t3-2:333` EBS AZ 종속, `t4-1:134`는 오답 보기).
- `Storage Gateway`·`DMS` → 문항 전역 **0건**(추가해도 충돌 없음).
- ⚠️ **기존 충돌 1건 발견 (이번 범위 밖, 별건)** — **`saa-t3-9-q11`**:
  정답(`correct: 0`)이 "AWS Snow 패밀리(Snowball Edge)"인데, 같은 문서 md
  `saa-t3-9.md:269,306`은 PR #140에서 **"신규 고객은 어떤 Snow Family 디바이스도 주문할 수
  없습니다"**로 정정됐다. 전파 가드는 `'Snowball Edge는 엣지 컴퓨팅도 가능합니다'`라는 특정
  문장만 금지해 이 문항을 놓쳤다. `verified: false`라 **라이브 노출 0**이지만 flip 전에
  반드시 처리해야 한다. 이 세션에서 고치지 않았다.

### 근거가 약해 **뒤로 미루거나 수치를 쓰지 말아야 할** 항목 (`99-gaps.md` §2 V 목록 대조)

| 항목 | 걸린 V | 처리 |
|---|---|---|
| G-1.2-05 IMDSv2·Session Manager | V-04 | **제외**(§0) |
| G-3.3-02 MemoryDB · G-3.4-02 Cloud WAN | **V-72** — 두 서비스가 공식 in/out-of-scope 목록 **어디에도 없음** | 범위 판정부터 불확실 → B2/B10에서 **이름 수준만**, 또는 제외 |
| G-2.1-01 App2Container | V-09 현재 제공 상태 블로그만 | 선택 기준만, 상태 단정 금지 |
| G-2.1-02 Amazon MQ | V-08 사용 사례 공식 문장 미확보 | in-scope 목록 사실만 |
| G-3.2-02 AWS Auto Scaling 스케일링 플랜 | V-22 지원 종료/신규 가용성 미확인 | 종료 단정 금지 |
| G-3.2-01·G-4.2-05 CloudFront Functions/Lambda@Edge | V-24 한도 수치 미확보 | 구조·선택 기준만, 수치 금지 |
| G-4.2-02 EC2 최대 절전 · G-4.2-03 비프로덕션 | V-55 | 과금 규칙만, "비프로덕션은 단일 AZ" 단정 금지 |
| G-4.2-06 Outposts · G-4.2-09 AMD/Graviton % | V-56 | 구성별 가격·% 수치 금지 |
| G-4.4-02 NAT 인스턴스 | V-65 손익분기·Regional NAT 요금 구조 미확보 | 비교축만, 손익분기 수치 금지 |
| G-4.4-03 VPN · G-4.4-09 CloudFront 요금제 | V-67 | 요율 금지 |
| G-4.4-05 WAF rate-based | V-68 현행 평가 창 미확인 | 5분/IP 단정 금지 |
| G-4.1-08 Standard-IA→Glacier 30일 | V-45 re:Post 근거만 | 규칙 서술 시 근거 재확보 필요 |
| G-4.1-12 Trusted Advisor 플랜 | V-48 플랜별 세부 미확보 | 개편 공지 수준만 |
| G-3.3-09 쓰기 집약 | 근거가 `3-3.md` F-05의 `[블로그]` | 1차 문서 재확보 후에만 |
| G-1.1-15 SCP 수치 | 공식 문서 간 상충(쿼터 10 vs Prescriptive Guidance 5) | 상충을 그대로 적거나 쿼터 페이지만 인용 |
| G-4.3-03 열 기반 DB 비용 | V-74 비용 비교 공식 기준 문장 미확보 | 유형 구분만 |

### B1·B2 공식 근거 사전 확인 (2026-10-20 AWS 문서 검색 실측)

- Storage Gateway 4유형 — https://aws.amazon.com/storagegateway/ (S3 File / FSx File / Tape /
  Volume) · 콘솔 도움말 https://docs.aws.amazon.com/help-panel/storagegateway/latest/console/hp-gateway-dashboard.html
  (File / Volume cached / Volume stored / Tape)
- DMS 동종·이기종 + SCT + CDC — https://docs.aws.amazon.com/dms/latest/userguide/Welcome.html ·
  https://docs.aws.amazon.com/SchemaConversionTool/latest/userguide/CHAP_GettingStarted.html ·
  참조 아키텍처 https://docs.aws.amazon.com/reference-architecture-diagrams/latest/change-data-capture-dms/change-data-capture-dms-migrate.html
- 둘 다 `99-gaps.md` V 목록에 없다 = 근거 미확보 항목이 아니다.
- **2단계에서 URL 실재를 다시 확인하고 적는다**(위는 검색 결과 기준).

---

## 4. 2단계 착수 시 바로 쓸 수 있는 사실

- 기준선은 **숫자를 믿지 말고 실측**한다. 참고로 사이드 노트 실측: `c231932`에서 1,288 →
  `05980fd`에서 1,289. `CLAUDE.md`의 1,185는 낡았다.
- `content_enrichment_test.dart`가 **핵심 개념 서브섹션마다 `> 🧠 원리:` 블록을 요구**한다
  (하한 = min(서브섹션, 8)). 절을 신설하면 원리 블록을 같이 써야 한다(SOA PR #159 교훈 —
  SAA에도 같은 가드가 걸리는지 2단계 첫 RED에서 확인할 것).
- 문서 내부 `(원리: §N — …)` 참조 때문에 **중간 삽입 대신 핵심 개념 맨 끝에 다음 번호로**
  절을 추가하는 편이 안전하다(SOA PR #159에서 실제로 설계를 바꾼 이유).
- 가드는 **금지만 고정하고 요구는 느슨하게**(핵심 키워드 수준).
