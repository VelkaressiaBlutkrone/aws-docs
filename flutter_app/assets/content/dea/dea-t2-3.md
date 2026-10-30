---
examGuideTaskId: dea-t2-3
certCode: DEA-C01
domain: 2
domainName: 데이터 스토어 관리
domainWeightPct: 26
title: 데이터 수명 주기 관리 (COPY/UNLOAD·S3 수명 주기·보존·복원성)
coversTasks:
  - "2.3"
sources:
  - title: COPY (Amazon Redshift Database Developer Guide) (공식 문서)
    url: https://docs.aws.amazon.com/redshift/latest/dg/r_COPY.html
  - title: Understanding and managing Amazon S3 storage classes (공식 문서)
    url: https://docs.aws.amazon.com/AmazonS3/latest/userguide/storage-class-intro.html
  - title: Transitioning objects using Amazon S3 Lifecycle (공식 문서)
    url: https://docs.aws.amazon.com/AmazonS3/latest/userguide/lifecycle-transition-general-considerations.html
  - title: Expiring objects (Amazon S3 Lifecycle) (공식 문서)
    url: https://docs.aws.amazon.com/AmazonS3/latest/userguide/lifecycle-expire-general-considerations.html
  - title: Locking objects with Object Lock (Amazon S3) (공식 문서)
    url: https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lock.html
  - title: Using time to live (TTL) in DynamoDB (공식 문서)
    url: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/TTL.html
  - title: DEA-C01 공식 시험 가이드 도메인 2 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain2.html
lastVerified: 2026-10-20
---

# 데이터 수명 주기 관리 (COPY/UNLOAD·S3 수명 주기·보존·복원성)

> **커버하는 공식 Task** — DEA-C01 · 도메인 2 「데이터 스토어 관리」(26%) · **Task 2.3 데이터의 수명 주기 관리** (`dea-t2-3`)
> 데이터가 **들어오고(적재) · 식어 가고(계층화) · 사라지고(만료·삭제) · 지켜지는(보존·복원)** 전 구간을 다룹니다.
> 숫자가 가장 많이 나오는 Task입니다 — 최소 보관 기간, 버전 동작, 백업 보존이 그대로 보기를 가릅니다.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명할 수 있어야 합니다. (공식 시험 가이드 Task 2.3의 Skill 항목)

- [ ] **Redshift COPY/UNLOAD**의 병렬 설계·오류 허용·암호화·형식별 제약을 안다
- [ ] **S3 스토리지 클래스 7종**을 최소 보관 기간·최소 청구 크기·조회 특성으로 구분한다
- [ ] **수명 주기 전환의 제약**(폭포 모델·128 KB 규칙·최소 보관 기간 연쇄)을 설명한다
- [ ] **버전 상태별 `Expiration` 동작**과 noncurrent 정리·삭제 마커·불완전 업로드 정리를 구분한다
- [ ] **S3 버전 관리·MFA Delete**와 **DynamoDB TTL**의 동작·한계를 안다
- [ ] 법적·비즈니스 요구에 맞는 **보존·삭제 수단**(Object Lock 3종·Vault Lock·Iceberg DELETE+VACUUM)을 고른다
- [ ] **복제·백업·다중 AZ**(CRR/SRR·RTC·AWS Backup·스냅샷·PITR·Multi-AZ)를 복구 요구사항으로 고른다

---

## 🎯 왜 중요한가

- 수명 주기는 **비용 문항의 본진**입니다. "로그를 30일은 자주, 1년 뒤에는 감사용으로만" 같은 시나리오는 거의 매번 나오고, 정답은 **최소 보관 기간과 전환 제약**이 결정합니다.
- **"삭제했는데 왜 비용이 그대로인가"** 류의 함정이 많습니다 — 버전 관리 버킷의 `Expiration`, Redshift `DELETE` 후 `VACUUM`, Iceberg의 merge-on-read 삭제가 모두 **"논리적 삭제 ≠ 물리적 제거"** 를 묻습니다.
- 보존(WORM)과 삭제(erasure)는 **반대 방향 요구**인데 한 Skill에 함께 있습니다. "루트도 못 지우게"와 "고객의 삭제 요청 처리"를 같은 도구로 풀려 하면 틀립니다.

---

## 🔤 먼저 알아야 할 용어

이 문서를 읽는 데 필요한 기초 용어입니다. 이미 알면 건너뛰세요.

| 용어 | 영문 | 한 줄 풀이 |
|---|---|---|
| **슬라이스** | slice | Redshift 노드 안의 병렬 처리 단위. COPY 파일 수를 여기에 맞춘다 |
| **매니페스트** | manifest | 적재할 파일 목록을 명시한 JSON — 서로 다른 버킷·폴더의 파일도 지정 가능 |
| **폭포 모델** | waterfall model | S3 클래스 전환이 한 방향(아래)으로만 가능한 구조 |
| **최소 보관 기간** | minimum storage duration | 그 전에 지우거나 옮기면 남은 기간만큼 요금이 붙는 기간 |
| **noncurrent 버전** | noncurrent version | 새 버전이 올라와 현재가 아니게 된 이전 버전 |
| **삭제 마커** | delete marker | 버전 관리 버킷에서 삭제 시 실제 삭제 대신 얹히는 표식 |
| **WORM** | write once read many | 한 번 쓰면 바꿀 수 없는 보존 방식 |
| **merge-on-read** | merge-on-read | 데이터 파일을 다시 쓰지 않고 삭제 표식 파일만 써서 읽을 때 반영하는 방식 |
| **PITR** | point-in-time recovery | 지정한 과거 시점으로 되돌리는 복구 |
| **RTC** | Replication Time Control | S3 복제에 시간 목표와 SLA를 붙이는 옵션 |

---

## 📖 핵심 개념

### 1) Redshift COPY — S3에서 적재하기 {#redshift-copy}

`COPY`는 S3·EMR·SSH 호스트·DynamoDB의 데이터를 테이블에 적재하며 **테이블 이름·데이터 소스·인가(IAM 역할)** 세 요소만 있으면 실행됩니다. 기존 행에 **append**하고, **Redshift Spectrum 외부 테이블은 읽기 전용이라 COPY 대상이 될 수 없습니다.** S3 파일 적재에는 **INSERT보다 COPY**가 효율적입니다(MPP로 여러 파일을 동시에 읽음).

- **병렬 로드 설계** — 테이블 데이터를 **여러 파일로 나누고 파일 수를 슬라이스 수의 배수**로 맞춥니다. Redshift는 파일 크기를 고려해 분배하지 않으므로 **압축 후 1 MB~1 GB의 비슷한 크기**로 맞춥니다. 공통 접두사(폴더)로 지정하면 폴더 전체를, **매니페스트**로 명시하면 서로 다른 버킷·폴더의 파일을 적재합니다. **Serverless는 128의 배수**를 권장하고, 압축하지 않은 단일 CSV·Parquet·ORC가 **128 MB보다 크면 Redshift가 자동 분할**합니다.
- **인가·암호화** — **SSE-S3·SSE-KMS로 암호화된 파일은 COPY가 자동 인식**해 적재하고 **SSE-C는 지원하지 않습니다.** ⚠️ **클라이언트 측 암호화**(`ENCRYPTED` + `MASTER_SYMMETRIC_KEY`)는 신규 고객에게 **2025-04-30부터 닫혔고 2026-04-30 이후에는 쓸 수 없습니다** — 서버 측 암호화로 전환이 권고됩니다.
- **오류 허용·검증** — `MAXERROR`는 허용 오류 수(**기본 0, 상한 100000**), `NOLOAD`는 **적재 없이 파일 유효성만 검사**합니다.
- **통계** — `STATUPDATE`를 쓰지 않으면 **테이블이 처음 비어 있을 때만** 통계가 자동 갱신됩니다. 크기가 크게 바뀌면 `ANALYZE` 또는 `STATUPDATE ON`을 권장합니다.
- **컬럼형(ORC·Parquet)** — S3 버킷이 **Redshift 데이터베이스와 같은 리전**이어야 하고, **`MAXERROR`를 지원하지 않으며**, 압축 인코딩이 자동 적용되지 않고, COPY가 내부적으로 Redshift Spectrum을 씁니다.
- **자동 수집(auto-copy)** — **S3 이벤트 통합 + COPY JOB**을 만들면 지정 경로에 새 파일이 생길 때 자동으로 COPY가 실행됩니다. 어떤 파일을 로드했는지 Redshift가 추적합니다.

### 2) Redshift UNLOAD — S3로 내보내기 {#redshift-unload}

- **기본 동작** — SELECT 결과를 **슬라이스 수에 따라 여러 파일로 병렬 기록**합니다. **`PARALLEL OFF`는 순차(직렬) 기록**이며, 데이터 파일 **최대 크기는 6.2 GB**(초과 시 파일이 추가로 생성)이고 `MAXFILESIZE` 기본값도 **6.2 GB**입니다.
- **암호화** — UNLOAD는 **기본으로 SSE-S3**로 암호화해 기록합니다(SSE-KMS도 가능).
- **Parquet** — 파일 수준 압축 없이 **row group마다 SNAPPY**로 압축하고, **32 MB row group**을 맞추려고 `MAXFILESIZE`를 32 MB의 배수로 내림합니다. **밑줄(`_`)이나 점(`.`)으로 시작하는 파일은 Redshift Spectrum이 숨김 파일로 보고 무시**합니다.

| 항목 | COPY | UNLOAD |
|---|---|---|
| 방향 | S3 등 → Redshift 테이블 | Redshift 쿼리 결과 → S3 |
| 병렬성 | 입력 파일 수가 **슬라이스 수의 배수**일 때 균등 분배 | 기본 슬라이스 수만큼 여러 파일, `PARALLEL OFF`면 순차 |
| 오류·크기 | `MAXERROR` 기본 0, **컬럼형은 `MAXERROR` 미지원** | 파일 최대 **6.2 GB**, Parquet는 32 MB 배수 |
| 암호화 | SSE-S3·SSE-KMS 자동, **SSE-C 미지원** | 기본 **SSE-S3** |

### 3) S3 스토리지 클래스와 수명 주기 전환 {#s3-classes}

수명 주기 구성은 **버킷 단위로 하나**이며 **최대 1,000개 규칙(조정 불가)** 을 담습니다. 규칙은 필터(prefix·태그·객체 크기·조합)와 전환/만료 액션으로 구성되고 **기존 객체와 이후 추가되는 객체 모두**에 적용됩니다. 클래스 전환은 **폭포(waterfall) 모델이라 아래 방향으로만** 갑니다.

| 클래스 | 설계 용도 | 가용성·AZ | 최소 보관 | 최소 청구 크기 | 조회 | 시험 단서 |
|---|---|---|---|---|---|---|
| **S3 Standard** | 자주 접근, 밀리초 | 99.99%, ≥3 AZ | 없음 | 없음 | 즉시 | "기본 클래스" |
| **S3 Standard-IA** | 드물게 접근, 밀리초 | 99.9%, ≥3 AZ | **30일** | **128 KB** | GB당 조회 요금 | "유일한 사본인데 드물게 접근" |
| **S3 One Zone-IA** | **재생성 가능**·드물게 접근 | 99.5%, **1 AZ** | **30일** | **128 KB** | GB당 조회 요금, **AZ 손실 시 데이터 손실** | "재생성 가능한 데이터" |
| **S3 Intelligent-Tiering** | 접근 패턴을 **모르거나 변함** | 99.9%, ≥3 AZ | 없음 | 없음(**128 KB 미만은 자동 티어링 제외**) | **조회 요금 없음**, 모니터링·자동화 요금 | "접근 패턴 불명" |
| **S3 Glacier Instant Retrieval** | 분기 1회 아카이브, **밀리초** | 99.9%, ≥3 AZ | **90일** | 128 KB | GB당 조회 요금 | "아카이브인데 **즉시** 조회" |
| **S3 Glacier Flexible Retrieval** | 연 1회, 분~시간 복원 | 99.99%(복원 후), ≥3 AZ | **90일** | 객체당 **40 KB** 메타 추가 | Expedited **1–5분**, Standard **3–5시간**, Bulk(무료) **5–12시간** | "분~시간 복원 허용" |
| **S3 Glacier Deep Archive** | 연 1회 미만, 시간 단위 복원 | 99.99%(복원 후), ≥3 AZ | **180일** | 객체당 **40 KB** 메타 추가 | 옵션 2가지, **12–48시간** | "연 1회 미만", "하루 걸려도 됨" |

- **128 KB 규칙** — **2024-09부터 기본으로 128 KB 미만 객체는 어떤 클래스로도 전환되지 않습니다**(전환 요청 비용이 절감액보다 클 수 있어서). 허용하려면 객체 크기 필터(`ObjectSizeGreaterThan`/`ObjectSizeLessThan`)를 둡니다. 2024-09 이전에 만든 구성은 변경하기 전까지 이전 동작을 유지합니다.
- **최소 보관 기간 연쇄** — 최소 보관 기간이 있는 클래스에서 그 전에 전환·삭제하면 **남은 기간만큼 요금**이 붙습니다. 한 규칙으로 최소 기간 이전의 연쇄 전환을 정의할 수 없습니다 — 예: Glacier Instant Retrieval로 4일 후 전환했다면 **Deep Archive 전환은 최소 94일 이후**여야 합니다.
- **Glacier 전환 방향** — **Flexible Retrieval은 Deep Archive로만** 전환되고 **Deep Archive는 일방향**입니다. 객체당 **40 KB 오버헤드**(8 KB는 Standard 요금, 32 KB는 Glacier 요금)가 붙고, 아카이브 객체는 **먼저 복원해야** 읽을 수 있으며 복원 중에는 아카이브와 임시 복사본 비용을 함께 냅니다.
- **Intelligent-Tiering 자동 계층** — Frequent Access → **30일 미접근 시 Infrequent Access** → **90일 미접근 시 Archive Instant Access**. 선택적으로 Archive Access(90일 이상)·Deep Archive Access(180일 이상)를 켤 수 있습니다.
- **Reduced Redundancy Storage**는 **사용하지 않기를 권고**합니다(Standard가 더 비용 효율적).
- 용어 정리: **S3 Glacier 클래스의 객체는 S3 안에 남습니다** — 별도 "Amazon Glacier" 볼트 서비스와 다른 것입니다.

### 4) 만료와 정리 — 버전 상태가 모든 것을 바꾼다 {#s3-expiration}

| 액션 | 비버전 버킷 | **버전 활성 버킷** | 버전 중지 버킷 |
|---|---|---|---|
| `Transition` | 지정 클래스로 전환 | **현재 버전만** 전환 | 활성과 동일 |
| `Expiration` | **영구 삭제(복구 불가)** | **삭제 마커를 만들고 기존 버전은 noncurrent로 보존** | `null` 버전 ID 삭제 마커 생성, 현재 버전 ID가 `null`이면 영구 삭제 |
| `NoncurrentVersionTransition` | 효과 없음 | noncurrent 버전을 전환 | 활성과 동일 |
| `NoncurrentVersionExpiration` | 효과 없음 | **noncurrent 버전 영구 삭제(복구 불가)** | 활성과 동일 |

- **noncurrent 정리** — `NoncurrentVersionExpiration`은 noncurrent가 된 뒤 일수(`NoncurrentDays`)와 **유지할 최신 noncurrent 버전 수**(`NewerNoncurrentVersions`, **1~100**)를 함께 쓸 수 있고 **둘 다 초과해야** 삭제됩니다. 유지할 버전 수를 지정하려면 **`Filter`가 있어야** 하며 없으면 `InvalidRequest` 오류가 납니다. noncurrent 일수는 **후속 버전이 생성된 시점부터** 셉니다.
- **삭제 마커 정리** — noncurrent 버전이 **0개인 삭제 마커**가 expired object delete marker이며 `ExpiredObjectDeleteMarker` 액션으로 제거합니다. 이 액션과 `AbortIncompleteMultipartUpload`는 **객체 태그 필터가 있는 규칙에 쓸 수 없습니다.**
- **불완전 멀티파트 업로드** — **객체 만료 규칙은 불완전 멀티파트 업로드를 지우지 못하므로** `AbortIncompleteMultipartUpload`로 일수 상한을 둡니다.
- **충돌·예외** — 객체는 **하루에 하나의 수명 주기 액션**만 대상이 되며 **영구 삭제가 전환보다 우선**합니다. **S3 Object Lock이 적용된 noncurrent 버전에는 아무 동작도 하지 않고, 버킷 정책으로 수명 주기 삭제·전환을 막을 수 없습니다.** 만료된 객체의 저장 요금은 부과되지 않지만 **실제 삭제까지 지연될 수 있습니다.**
- 일수 계산은 생성 시각 + 일수를 **다음 날 자정(UTC)으로 올림**합니다.

### 5) S3 버전 관리·MFA Delete와 DynamoDB TTL {#versioning-ttl}

**S3 버전 관리**

- 버킷 상태는 **비버전(기본)·버전 활성·버전 중지** 세 가지이고, **한 번 활성화하면 비버전으로 돌아갈 수 없으며 중지만** 가능합니다. 삭제하면 영구 삭제 대신 **삭제 마커가 현재 버전**이 됩니다.
- **버전마다 객체 전체가 저장**되므로(diff 아님) 3개 버전이면 **객체 3개로 청구**됩니다.
- 비버전 버킷에 만료 규칙이 있었다면, 버전 활성화 후 같은 영구 삭제 동작을 유지하려면 **noncurrent 만료 규칙을 추가**해야 합니다.
- **MFA Delete** — **버킷 버전 상태 변경**과 **객체 버전의 영구 삭제**에 추가 인증을 요구합니다. **버킷 소유자(루트 계정)만 활성화**할 수 있고 **콘솔이 아니라 CLI/API**로 설정하며, **수명 주기 구성과 함께 쓸 수 없습니다.**

**DynamoDB TTL**

- 항목별 만료 타임스탬프 속성을 지정하면 DynamoDB가 만료 항목을 자동 삭제하며, **삭제에 쓰기 처리량을 쓰지 않는** 비용 효율적인 방법입니다. TTL 속성은 **Number 타입의 Unix epoch 초 단위**여야 하고, Number가 아니면 TTL 프로세스가 **무시**합니다.
- **삭제는 만료 후 보통 며칠 이내이고 정확한 시각이 보장되지 않습니다.** 만료됐지만 삭제 전인 항목은 **Scan·Query 결과에 남으므로 필터 표현식으로 제외**합니다. TTL을 미래 시각으로 갱신하거나 속성을 제거하면 삭제되지 않습니다.
- TTL 삭제는 DynamoDB Streams에 **사용자 삭제가 아닌 서비스 삭제**로 기록되고, LSI·GSI에서도 일반 삭제처럼 제거되며, **글로벌 테이블에서는 모든 복제본으로 복제**됩니다.

### 6) 법적·비즈니스 요구에 따른 보존과 삭제 {#retention-deletion}

| 수단 | 적용 대상 | 동작·제약 | 시험 단서 |
|---|---|---|---|
| **Object Lock — Governance** | 객체 버전 | 대부분의 사용자는 삭제·잠금 변경 불가, **특별 권한(`s3:BypassGovernanceRetention`)이 있으면 우회 가능** | "일부 관리자는 삭제 가능" |
| **Object Lock — Compliance** | 객체 버전 | **루트 포함 누구도** 보존 기간 내 덮어쓰기·삭제 불가, 모드·기간 단축 불가 | "**루트도 삭제 불가**" |
| **Object Lock — Legal hold** | 객체 버전 | **만료일 없이** 명시적으로 제거할 때까지 보호, 보존 기간과 **독립** | "소송·감사, **기간 미정**" |
| **AWS Backup Vault Lock** | 백업 볼트 | Governance는 권한자가 해제 가능, **Compliance는 grace time(최소 3일) 이후 변경·삭제 불가**, 락된 볼트의 백업은 수명 주기 종료 전 삭제 불가 | "백업 WORM" |
| **S3 수명 주기 만료** | 객체 | 기간 경과 시 삭제(버전 상태에 따라 삭제 마커 또는 영구 삭제) | "N년 후 자동 삭제" |
| **Iceberg `DELETE` + `VACUUM`**(Athena) | Iceberg 행 | `DELETE`는 **position delete 파일을 쓰는 merge-on-read** 삭제, `VACUUM`이 스냅샷 만료·고아 파일 제거 | "특정 사용자 행 삭제" |
| **S3 Tables 유지 관리** | S3 Tables | 스냅샷 관리가 **기본 120시간 초과 스냅샷**을 만료·제거, **noncurrent 객체 삭제는 영구**(복구 불가) | "관리형 Iceberg" |
| **Redshift `DELETE` + `VACUUM`** | 테이블 행 | 삭제 행은 **표시만 되고 즉시 제거되지 않으며** 백그라운드 VACUUM DELETE가 회수 | "삭제했는데 디스크가 안 줄어듦" |
| **DynamoDB TTL** | 항목 | 만료 후 **며칠 이내** 삭제(시각 보장 없음) | "자동 만료, 쓰기 비용 없음" |

- **Object Lock 전제** — **버전 관리가 켜진 버킷에서만** 동작하며 잠금은 **지정한 객체 버전에만** 적용됩니다. **새 버전 생성과 삭제 마커 추가는 막지 않습니다.** 보존 기간은 고정(retain-until-date) 또는 가변(이벤트 보류 + 기간)이며 버킷 기본 보존 기간도 둘 수 있습니다.
- **삭제 요청 처리 시 고려** — 개인정보 삭제 요청은 **백업·원천 시스템을 포함한 모든 저장소**를 대상으로 하며, 삭제 대신 **되돌릴 수 없는 마스킹**도 방법입니다. 데이터 레이크에서는 **해당 행을 제거한 새 버전을 쓰고 이전 버전을 삭제**해야 합니다. Athena Iceberg `DELETE`는 데이터 파일을 다시 쓰지 않으므로 **물리적 제거는 `VACUUM`(또는 S3 Tables 스냅샷 관리)에 달려 있습니다.**
- **복제본·백업** — S3 복제는 **버전 ID를 지정한 삭제를 대상 버킷에 복제하지 않습니다.** 락된 AWS Backup 볼트의 백업은 **수명 주기 종료 전 삭제 불가**이고, Redshift 수동 스냅샷은 **직접 삭제하거나 지정한 보존 기간이 끝날 때까지** 유지됩니다. 삭제 요청은 이런 사본까지 범위에 넣어야 합니다.

> 🧠 원리: 왜 "삭제"가 한 번의 명령으로 끝나지 않을까요?
> 분석 시스템은 **복구 가능성을 위해 사본을 늘리도록 설계**돼 있기 때문입니다 — 버전, 스냅샷, 복제본, 백업, 그리고 테이블 포맷의 과거 스냅샷까지.
> 그래서 "지웠다"는 보통 **현재 상태에서 안 보이게 됐다**는 뜻이고(논리적 삭제), 물리적 제거는 **보존 창이 끝난 뒤 별도 작업**(`VACUUM`, noncurrent 만료, 스냅샷 만료)이 합니다.
> 법적 삭제 요구를 다루는 문항은 거의 항상 **"그 두 단계를 모두 밟았는가"** 를 묻습니다.

### 7) 복원성과 가용성 — 복제·백업·다중 AZ {#resiliency}

| 수단 | 보호 범위 | 복구 특성 | 제약 | 시험 단서 |
|---|---|---|---|---|
| **S3 CRR / SRR** | 버킷 간 비동기 복사(다른/같은 리전) | **새·변경 객체만** 복제 | **소스·대상 모두 버전 관리 필요**, 소스가 Object Lock이면 대상도 필요. **기존 객체는 Batch Replication** | "리전 간 복제", "규정상 거리" |
| **S3 RTC** | 위 복제에 시간 목표 추가 | **새 객체의 99.99%를 15분 이내** 복제 | **Batch Replication에는 적용되지 않음** | "15분 이내" |
| **AWS Backup** | 중앙 정책 기반 백업 | 정책 스케줄 기준 복구 지점 | 교차 리전·교차 계정 복사, 콜드 스토리지 전환, **백업 내용은 불변**, Vault Lock으로 WORM | "여러 서비스 백업 중앙 관리" |
| **Redshift 스냅샷** | 클러스터 자동·수동 스냅샷 | 자동은 **약 8시간 또는 노드당 5 GB 변경마다** 중 먼저 오는 쪽 | **자동 기본 보존 1일**, 수동은 직접 삭제할 때까지(또는 지정 기간) | "장기 보존하려면 수동" |
| **DynamoDB PITR** | 테이블 연속 백업 | **최근 35일 내 초 단위** 시점 복원(보존 1~35일) | — | "실수로 삭제한 항목 복구" |
| **DynamoDB 온디맨드 백업** | 테이블 전체 백업 | 백업 시점 | **장기 보존·규정 준수용** | "7년 보관" |
| **DynamoDB 글로벌 테이블** | 다중 리전 복제 | 다중 리전 복원성 | **99.999% 가용성 SLA** | "다중 리전" |
| **RDS 자동 백업** | DB 인스턴스 | 보존 기간 동안 유지 | **0~35일**(콘솔 기본 7일, API 기본 1일), **0이면 비활성** | "백업 보존 기간" |
| **RDS Multi-AZ** | 다른 AZ의 **동기식** 대기 복제본 | AZ 장애 시 전환 | **대기 복제본은 읽기 트래픽을 처리하지 않음** | "고가용성이지 읽기 확장 아님" |

- S3 복제는 **버전 ID를 지정한 삭제를 전파하지 않아** 악의적 삭제로부터 보호하는 효과가 있고, 최신 복제 구성에서는 **삭제 마커도 기본으로 복제하지 않습니다**(따로 추가 가능).
- DynamoDB는 기본으로 **3개 AZ에 복제**해 99.99% 가용성 SLA를 제공합니다. S3 클래스는 **One Zone-IA와 Express One Zone을 제외하고** AZ 손실에 견디도록 설계됐습니다.

---

## ✍️ 시험 포인트

- "**처음 30일 자주 → 이후 드물게 → 1년 뒤 감사용**" → 수명 주기로 Standard → **Standard-IA**(유일한 사본) 또는 **One Zone-IA**(재생성 가능) → **Glacier Flexible Retrieval / Deep Archive** → `Expiration`.
- "**접근 패턴을 모른다**" → **Intelligent-Tiering**(조회 요금 없음, 모니터링·자동화 요금, **128 KB 미만은 자동 티어링 제외**).
- "**아카이브인데 밀리초 조회**" → **Glacier Instant Retrieval**. "**하루 걸려도 된다**" → **Deep Archive**(12–48시간).
- "**버전 관리 버킷인데 스토리지가 계속 늘어난다**" → `Expiration`만으로는 **삭제 마커만** 얹힙니다. **`NoncurrentVersionExpiration`**(+ `NewerNoncurrentVersions`는 `Filter` 필수), **`ExpiredObjectDeleteMarker`**, **`AbortIncompleteMultipartUpload`** 세트.
- "**MFA Delete를 켜고 수명 주기도 쓰겠다**" → **불가능**합니다. MFA Delete는 **루트만, CLI/API로만**.
- "**적재가 느리다**" → 큰 단일 파일 대신 **슬라이스 수의 배수**(Serverless는 128의 배수)로 나눈 **1 MB~1 GB** 파일 + `COPY`. "**불량 행 몇 개는 건너뛰기**" → `MAXERROR`(단, **Parquet·ORC는 미지원**).
- "**루트도 못 지우게 N년**" → **Object Lock Compliance**. "**기간 미정 동결**" → **Legal hold**. "**일부 관리자는 우회 가능**" → **Governance**. 백업이면 **Vault Lock Compliance**.
- "**삭제했는데 S3에 데이터 파일이 남아 있다**" → Iceberg `DELETE`는 **merge-on-read**. 물리 제거는 **`VACUUM`**(또는 S3 Tables 스냅샷 관리). Redshift도 `DELETE` 후 **VACUUM DELETE**가 회수합니다.
- "**15분 이내 리전 간 복제**" → **CRR + RTC**(단 **기존 객체는 Batch Replication**이고 **RTC는 Batch에 적용되지 않음**).
- "**어제 실수로 지운 DynamoDB 항목**" → **PITR**(최근 35일, 초 단위). "**규정상 7년 보관**" → **온디맨드 백업**.
- 숫자: IA 최소 **30일**, Glacier IR·FR **90일**, Deep Archive **180일**, 수명 주기 규칙 **버킷당 1,000개**, `NewerNoncurrentVersions` **1~100**, UNLOAD 파일 **6.2 GB**, `MAXERROR` 상한 **100000**, RDS 백업 **0~35일**, PITR **1~35일**.

---

## ⚠️ 흔한 함정 {#pitfalls}

1. **"버전 관리 버킷에서 `Expiration`을 걸면 용량이 준다."** → ❌. 현재 버전에 **삭제 마커만 얹히고 기존 버전은 noncurrent로 남습니다.** 영구 삭제는 **`NoncurrentVersionExpiration`** 입니다.
2. **"객체 만료 규칙이 불완전 멀티파트 업로드도 치운다."** → ❌. **별도로 `AbortIncompleteMultipartUpload`** 가 필요합니다(태그 필터 규칙에는 쓸 수 없음).
3. **"버킷 정책으로 수명 주기 삭제를 막으면 된다."** → ❌. **버킷 정책으로는 막을 수 없습니다.** 막으려면 **Object Lock**입니다(수명 주기는 Object Lock이 적용된 noncurrent 버전을 건드리지 않습니다).
4. **"MFA Delete와 수명 주기를 같이 쓴다."** → ❌. **함께 쓸 수 없습니다.** 또 **콘솔에서 켤 수 없고 루트 계정만** 활성화할 수 있습니다.
5. **"작은 객체도 IA로 옮기면 싸진다."** → ❌. **128 KB 미만은 기본적으로 전환되지 않고**, IA 클래스는 **128 KB로 청구**되며 **30일 최소 보관**이 붙습니다. 오히려 비용이 늘 수 있습니다.
6. **"Glacier Instant Retrieval에서 4일 뒤 Deep Archive로 보낸다."** → ❌. 최소 보관 기간 때문에 **Deep Archive 전환은 최소 94일 이후**여야 합니다. **Flexible Retrieval은 Deep Archive로만** 전환되고 **Deep Archive는 일방향**입니다.
7. **"One Zone-IA가 싸니까 백업 1차 사본에 쓴다."** → ❌. **1개 AZ**라 AZ 손실 시 데이터를 잃습니다. **재생성 가능한 데이터**에만 씁니다.
8. **"DynamoDB TTL은 만료 즉시 항목을 지운다."** → ❌. **보통 며칠 이내**이고 시각이 보장되지 않습니다. 만료 항목이 조회에 보이면 안 되면 **필터 표현식**으로 제외합니다.
9. **"TTL 속성을 문자열 타임스탬프로 넣었다."** → ❌. **Number 타입의 Unix epoch 초**가 아니면 TTL 프로세스가 **무시**합니다.
10. **"Governance 모드면 아무도 못 지운다."** → ❌. **특별 권한(`s3:BypassGovernanceRetention`)이 있으면 우회**됩니다. 루트까지 막으려면 **Compliance**입니다.
11. **"복제를 켜면 기존 객체도 복사된다."** → ❌. 라이브 복제는 **설정 이후 새·변경 객체만**입니다. 기존 객체는 **Batch Replication**이고, **RTC는 Batch에 적용되지 않습니다.**
12. **"Redshift에서 `DELETE` 했으니 디스크가 바로 줄어든다."** → ❌. 행은 **삭제 표시만** 되고 **백그라운드 VACUUM DELETE**가 공간을 회수합니다.
13. **"Parquet COPY에서도 `MAXERROR`로 불량 행을 넘긴다."** → ❌. **컬럼형(ORC·Parquet) COPY는 `MAXERROR`를 지원하지 않고**, 버킷이 **같은 리전**이어야 합니다.
14. **"COPY에 클라이언트 측 암호화를 쓰면 된다."** → ❌. **2026-04-30 이후 사용할 수 없습니다.** SSE-S3·SSE-KMS로 전환이 권고됩니다(**SSE-C는 COPY가 지원하지 않음**).
15. **"Multi-AZ 대기 복제본으로 읽기를 분산한다."** → ❌. **대기 복제본은 읽기 트래픽을 처리하지 않습니다.**

---

## 🧪 자가 점검

> 아래는 학습용 자가 점검입니다. (문항 뱅크는 `dea-t2-3.questions.json` — 사람 검수 전이라 사이트에는 노출되지 않습니다)

**Q1.** 버전 관리가 켜진 버킷의 저장 비용이 계속 늘어납니다. 수명 주기 규칙에 `Expiration`을 30일로 걸어 뒀는데도 줄지 않습니다. 왜이고, 어떻게 고치나요?

<details><summary>정답 보기</summary>

버전 활성 버킷에서 `Expiration`은 **현재 버전에 삭제 마커를 얹을 뿐 이전 버전은 noncurrent로 남습니다.** 저장 비용은 **버전마다 객체 전체가 저장**되므로 그대로입니다. **`NoncurrentVersionExpiration`**(`NoncurrentDays` + 필요하면 `NewerNoncurrentVersions` 1~100, 이때 `Filter` 필수)을 추가하고, 쌓인 삭제 마커는 **`ExpiredObjectDeleteMarker`**, 미완료 업로드는 **`AbortIncompleteMultipartUpload`** 로 정리합니다.
</details>

**Q2.** 규정상 거래 기록을 **7년간 아무도(루트 포함) 삭제하거나 덮어쓸 수 없게** 해야 합니다. 어떤 구성인가요?

<details><summary>정답 보기</summary>

**S3 Object Lock을 Compliance 모드**로 걸고 보존 기간을 7년으로 둡니다. Compliance 모드는 **루트 사용자를 포함해 누구도** 보존 기간 내 삭제·덮어쓰기를 할 수 없고 모드·기간 단축도 불가능합니다. 전제로 **버킷의 버전 관리가 켜져** 있어야 합니다. Governance 모드는 특별 권한이 있으면 우회되고, Legal hold는 기간이 아니라 **명시적 해제 전까지** 보호하는 수단입니다. 백업 쪽이라면 **AWS Backup Vault Lock(Compliance)** 이 대응됩니다.
</details>

**Q3.** 50 GB의 gzip CSV 파일 **하나**를 Redshift로 적재하는데 너무 느립니다. 어떻게 바꾸나요?

<details><summary>정답 보기</summary>

파일을 **여러 개로 나누어 `COPY`** 합니다. 파일 수를 **클러스터 슬라이스 수의 배수**(Redshift Serverless는 **128의 배수**)로 맞추고, **압축 후 1 MB~1 GB의 비슷한 크기**로 분할합니다. Redshift는 파일 크기를 고려해 분배하지 않으므로 크기를 맞추는 것이 중요합니다. 공통 접두사나 **매니페스트**로 지정하고, `INSERT` 대신 `COPY`를 씁니다(MPP 병렬 읽기).
</details>

**Q4.** 사용자가 개인정보 삭제를 요청했습니다. 데이터는 Athena로 쿼리하는 Iceberg 테이블에 있습니다. `DELETE`를 실행했는데 S3 사용량이 줄지 않았습니다.

<details><summary>정답 보기</summary>

Athena의 Iceberg `DELETE`는 **position delete 파일을 쓰는 merge-on-read 삭제**라 **데이터 파일을 다시 쓰지 않습니다.** 물리적 제거는 **`VACUUM`**(스냅샷 만료 + 고아 파일 제거 — 현재 테이블 상태에 없고 보존 기간보다 오래된 파일 대상)이 수행하며, S3 Tables라면 **스냅샷 관리**가 대신합니다. 더불어 삭제 요청의 범위에는 **백업·복제본·원천 시스템**까지 포함해야 하고, 삭제 대신 **되돌릴 수 없는 마스킹**도 선택지입니다.
</details>

**Q5.** 재해 복구를 위해 다른 리전으로 **15분 이내** 복제하려 합니다. 버킷에는 **이미 수백만 개의 기존 객체**가 있습니다.

<details><summary>정답 보기</summary>

**CRR + S3 Replication Time Control(RTC)** 을 구성합니다. RTC는 **새 객체의 99.99%를 15분 이내** 복제합니다. 다만 **라이브 복제는 설정 이후의 새·변경 객체만** 대상이므로, **기존 객체는 Batch Replication(온디맨드 복제)** 으로 따로 복제해야 하고 **RTC는 Batch Replication에 적용되지 않습니다.** 전제로 **소스·대상 버킷 모두 버전 관리**가 켜져 있어야 합니다.
</details>

---

**Q6 (원리).** 왜 S3 클래스 선택 문항에서 "최소 보관 기간"이 거의 항상 결정적일까요?

<details><summary>정답 보기</summary>

**저렴한 클래스는 "싸게 오래 두는 대신 일찍 빼면 위약금을 받는" 구조이기 때문입니다.** Standard-IA 30일, Glacier IR·FR 90일, Deep Archive 180일은 단순한 숫자가 아니라 **그 기간 전에 지우거나 옮기면 남은 기간만큼 요금을 낸다**는 계약입니다. 그래서 "30일 뒤 삭제하는 데이터를 Glacier로 보내자" 같은 보기는 **비용이 오히려 늘어** 탈락하고, 연쇄 전환도 **앞 클래스의 최소 기간을 채운 뒤**에야 가능합니다(Glacier IR 4일 → Deep Archive는 최소 94일 이후). 수명 주기 설계는 **데이터의 수명이 각 클래스의 최소 기간보다 긴가**를 먼저 따지는 일입니다.
</details>

---

### 📌 출처

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. (수집·대조: 2026-10-17 · 저작: 2026-10-20 · 사람 검수 전)

1. COPY (Amazon Redshift Database Developer Guide) — https://docs.aws.amazon.com/redshift/latest/dg/r_COPY.html
2. Data load operations (COPY parameter reference) — https://docs.aws.amazon.com/redshift/latest/dg/copy-parameters-data-load.html
3. Loading data from compressed and uncompressed files (Amazon Redshift) — https://docs.aws.amazon.com/redshift/latest/dg/t_splitting-data-files.html
4. Loading encrypted data files from Amazon S3 (Amazon Redshift) — https://docs.aws.amazon.com/redshift/latest/dg/c_loading-encrypted-files.html
5. COPY from columnar data formats (Amazon Redshift) — https://docs.aws.amazon.com/redshift/latest/dg/copy-usage_notes-copy-from-columnar.html
6. Create an S3 event integration to automatically copy files from Amazon S3 buckets — https://docs.aws.amazon.com/redshift/latest/dg/loading-data-copy-job.html
7. How do I efficiently load data from Amazon S3 into Amazon Redshift? — https://repost.aws/knowledge-center/redshift-load-s3-data
8. Unloading data to Amazon S3 (Amazon Redshift) — https://docs.aws.amazon.com/redshift/latest/dg/t_Unloading_tables.html
9. UNLOAD (Amazon Redshift Database Developer Guide) — https://docs.aws.amazon.com/redshift/latest/dg/r_UNLOAD.html
10. Understanding and managing Amazon S3 storage classes — https://docs.aws.amazon.com/AmazonS3/latest/userguide/storage-class-intro.html
11. Transitioning objects using Amazon S3 Lifecycle — https://docs.aws.amazon.com/AmazonS3/latest/userguide/lifecycle-transition-general-considerations.html
12. Lifecycle configuration elements (Amazon S3) — https://docs.aws.amazon.com/AmazonS3/latest/userguide/intro-lifecycle-rules.html
13. Secure archive storage – Amazon S3 Glacier storage classes — https://aws.amazon.com/s3/storage-classes/glacier/
14. Expiring objects (Amazon S3 Lifecycle) — https://docs.aws.amazon.com/AmazonS3/latest/userguide/lifecycle-expire-general-considerations.html
15. Retaining multiple versions of objects with S3 Versioning — https://docs.aws.amazon.com/AmazonS3/latest/userguide/Versioning.html
16. Configuring MFA delete (Amazon S3) — https://docs.aws.amazon.com/AmazonS3/latest/userguide/MultiFactorAuthenticationDelete.html
17. Using time to live (TTL) in DynamoDB — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/TTL.html
18. Locking objects with Object Lock (Amazon S3) — https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lock.html
19. DELETE (Athena Iceberg) — https://docs.aws.amazon.com/athena/latest/ug/querying-iceberg-delete.html
20. Optimize Iceberg tables (Amazon Athena) — https://docs.aws.amazon.com/athena/latest/ug/querying-iceberg-data-optimization.html
21. Maintenance for tables (Amazon S3 Tables) — https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-tables-maintenance.html
22. Vacuuming tables (Amazon Redshift) — https://docs.aws.amazon.com/redshift/latest/dg/t_Reclaiming_storage_space202.html
23. AWS Backup Vault Lock — https://docs.aws.amazon.com/aws-backup/latest/devguide/vault-lock.html
24. Best practice 3.1 – Privacy by Design (AWS Well-Architected Data Analytics Lens) — https://docs.aws.amazon.com/wellarchitected/latest/analytics-lens/best-practice-3.1-privacy-by-design..html
25. Handling data erasure requests in your data lake with Amazon S3 Find and Forget (AWS Big Data Blog) — https://aws.amazon.com/blogs/big-data/handling-data-erasure-requests-in-your-data-lake-with-amazon-s3-find-and-forget/
26. Replicating objects within and across Regions (Amazon S3) — https://docs.aws.amazon.com/AmazonS3/latest/userguide/replication.html
27. Requirements and considerations for replication (Amazon S3) — https://docs.aws.amazon.com/AmazonS3/latest/userguide/replication-requirements.html
28. What does Amazon S3 replicate? — https://docs.aws.amazon.com/AmazonS3/latest/userguide/replication-what-is-isnot-replicated.html
29. What is AWS Backup? — https://docs.aws.amazon.com/aws-backup/latest/devguide/whatisbackup.html
30. Amazon Redshift snapshots and backups — https://docs.aws.amazon.com/redshift/latest/mgmt/working-with-snapshots.html
31. What is Amazon DynamoDB? — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Introduction.html
32. Backup retention period (Amazon RDS) — https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_WorkingWithAutomatedBackups.BackupRetention.html
33. Multi-AZ DB instance deployments for Amazon RDS — https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.MultiAZSingleStandby.html
34. Save on storage costs using Amazon S3 (스토리지 클래스 성능 비교표) — https://aws.amazon.com/s3/cost-optimization/
35. DEA-C01 공식 시험 가이드 도메인 2 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain2.html
