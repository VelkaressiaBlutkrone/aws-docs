---
examGuideTaskId: saa-t3-1
certCode: SAA-C03
domain: 3
domainName: 고성능 아키텍처 설계
domainWeightPct: 24
title: S3 스토리지 성능 — 스토리지 클래스·수명주기·접근 제어
coversTasks:
  - "3.1"
sources:
  - title: Amazon S3 소개 (공식)
    url: https://docs.aws.amazon.com/AmazonS3/latest/userguide/Welcome.html
  - title: S3 스토리지 클래스 비교 (공식)
    url: https://docs.aws.amazon.com/AmazonS3/latest/userguide/storage-class-intro.html
  - title: S3 수명 주기 관리 (공식)
    url: https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lifecycle-mgmt.html
  - title: S3 성능 최적화 모범 사례 (공식)
    url: https://docs.aws.amazon.com/AmazonS3/latest/userguide/optimizing-performance.html
  - title: SAA-C03 공식 시험 가이드 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
lastVerified: 2026-06-07
---

# S3 스토리지 성능 — 스토리지 클래스·수명주기·접근 제어

> **커버하는 공식 Task** — SAA-C03 · 도메인 3 「고성능 아키텍처 설계」(24%) · **Task 3.1 고성능·확장 가능 스토리지 솔루션 결정** (`saa-t3-1`)
> 이 문서는 위 한 Task에 1:1로 매핑됩니다. S3는 도메인 3의 출발점이자 시험 최빈출 스토리지 서비스입니다.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명할 수 있어야 합니다.

- [ ] **S3 기본 구조** — 버킷·객체·키·내구성 11 nine의 의미를 설명할 수 있다
- [ ] **스토리지 클래스 선택** — 접근 빈도·복원 시간·비용을 기준으로 7개 클래스를 선택할 수 있다
- [ ] **수명 주기 정책** — 전환(Transition)과 만료(Expiration) 액션의 차이를 설명하고 예시를 들 수 있다
- [ ] **성능 최적화** — 프리픽스 병렬화·멀티파트 업로드·Transfer Acceleration·바이트 범위 요청의 용도를 안다
- [ ] **접근 제어 계층** — IAM·버킷 정책·ACL·Block Public Access·프리사인 URL 각각의 역할을 구분할 수 있다
- [ ] **버전 관리와 복제** — Versioning·CRR·SRR의 용도와 전제 조건을 안다

---

## 🎯 왜 중요한가

- 도메인 3(24%)은 SAA에서 두 번째로 높은 비중입니다. S3는 정적 호스팅·로그·백업·데이터 레이크·아카이브 등 사실상 모든 영역에 등장합니다.
- 시험은 **"어떤 스토리지 클래스를 선택할 것인가"** 형태의 비용 최적화 문제와 **"어떤 접근 제어 방식을 써야 하는가"** 형태의 보안 문제를 반복 출제합니다.
- CLF에서 S3를 "객체 스토리지" 수준으로 봤다면, SAA는 **7개 스토리지 클래스의 비용 구조·최소 보관 기간·복원 시간 차이**와 **접근 제어 4계층의 선택 기준**을 묻습니다.

---

## 🔤 먼저 알아야 할 용어

이 문서를 읽는 데 필요한 기초 용어입니다. 이미 알면 건너뛰세요.

| 용어 | 영문 | 한 줄 풀이 |
|---|---|---|
| **객체 스토리지** | Object Storage | 파일을 계층 구조 없이 키-값 형태로 저장하는 방식. 폴더 대신 버킷+키로 위치를 나타냅니다. |
| **강력한 일관성** | Strong Consistency | 쓰기 직후 읽어도 항상 최신 값을 반환하는 데이터 일관성 수준 |
| **엣지 로케이션** | Edge Location | CloudFront·Transfer Acceleration이 사용하는 AWS 글로벌 거점. 사용자 가까이에서 요청을 처리합니다. |
| **OAC** | Origin Access Control | CloudFront에서 S3 오리진에 접근할 때 신원을 증명하는 제어 방식. S3를 비공개로 유지하면서 CDN 경유 접근만 허용할 때 사용합니다. |
| **리소스 기반 정책** | Resource-based Policy | 리소스(버킷·큐 등)에 직접 붙여 "누가 이 리소스를 쓸 수 있는가"를 정의하는 IAM 정책 유형 |
| **CDN** | Content Delivery Network | 전 세계 엣지 로케이션에 콘텐츠를 캐싱해 사용자와 가까운 곳에서 전달하는 네트워크 |

---

## 📖 핵심 개념

### 1) S3 기본 구조

> 공식 정의: **"Amazon S3는 객체를 버킷 안에 저장하는 객체 스토리지 서비스."** 업계 최고 수준의 확장성·가용성·보안·성능을 제공합니다.

핵심 사실:

- **버킷(Bucket)**: 전역(글로벌) 고유 이름. 생성 후 이름·리전 변경 불가.
- **객체(Object)**: 파일 + 메타데이터. 단일 객체 최대 5TB. 키(Key)로 고유 식별.
- **내구성**: **99.999999999% (11 nine)** — 모든 클래스 동일.
- **강력한 일관성(Strong Consistency)**: PUT/DELETE 요청 직후 GET이 최신 데이터를 반환. (2020년 12월부터 모든 리전에서 보장)
- **기본 상태**: 버킷과 객체는 기본적으로 **비공개(private)**. 공개는 명시적으로 설정해야 합니다.

> 🧠 원리: 왜 S3는 "11 nine" 내구성을 단일 AZ가 아닌 여러 AZ에 걸쳐 달성할까요?
> 단일 시설의 전원·냉각·네트워크 장애는 동시에 해당 AZ 전체에 영향을 줄 수 있습니다.
> 여러 AZ에 자동으로 분산 저장하면 AZ 하나가 통째로 손실되더라도 나머지 복제본이 데이터를 보존할 수 있어, 극단적인 내구성 목표 달성이 가능해집니다.
> 이 다중 AZ 중복 저장이 S3 내구성의 물리적 근거이며, One Zone-IA가 단일 AZ로 내려가는 순간 이 안전망을 포기한다는 뜻이기도 합니다.

### 2) 스토리지 클래스 — 접근 빈도 × 복원 시간 × 비용

| 클래스 | 설계 목적 | 가용성 | AZ 수 | 최소 보관 | 복원 시간 | 검색 요금 |
|---|---|---|---|---|---|---|
| **S3 Standard** | 자주 접근 (월 1회 이상) | 99.99% | 3 이상 | 없음 | 밀리초 | 없음 |
| **S3 Intelligent-Tiering** | 접근 패턴 불명확·변동 | 99.9% | 3 이상 | 없음 | 밀리초(Frequent/Infrequent) | 없음 (모니터링 요금 별도) |
| **S3 Standard-IA** | 가끔 접근 (월 1회 미만), 재생성 불가 원본 | 99.9% | 3 이상 | **30일** | 밀리초 | GB당 과금 |
| **S3 One Zone-IA** | 가끔 접근, **재생성 가능** 데이터 | 99.5% | **1** | **30일** | 밀리초 | GB당 과금 |
| **S3 Glacier Instant Retrieval** | 분기 1회 수준 아카이브, 즉시 접근 필요 | 99.9% | 3 이상 | **90일** | 밀리초 | GB당 과금 |
| **S3 Glacier Flexible Retrieval** | 연 1회 수준 아카이브 | 99.99% (복원 후) | 3 이상 | **90일** | 분~12시간 | GB당 과금 |
| **S3 Glacier Deep Archive** | 연 1회 미만 초장기 보관 | 99.99% (복원 후) | 3 이상 | **180일** | **12시간 이내** | GB당 과금 |

> **클래스 선택 공식** (시험 핵심):
> - 접근 패턴 모름 → **Intelligent-Tiering**
> - 가끔 접근·재생성 불가 → **Standard-IA**
> - 가끔 접근·재생성 가능 → **One Zone-IA** (비용 더 낮음)
> - 아카이브인데 즉시 꺼내야 함 → **Glacier Instant Retrieval**
> - 아카이브·수분~수시간 대기 가능 → **Glacier Flexible Retrieval**
> - 7년 이상 보관·거의 안 봄 → **Glacier Deep Archive** (최저가)

**S3 Intelligent-Tiering 계층 이동 규칙:**

```
업로드 → Frequent Access (기본)
  30일 미접근 → Infrequent Access
  90일 미접근 → Archive Instant Access
  (선택 활성화 시) 90일 이상 → Archive Access / 180일 이상 → Deep Archive Access
```

> 128 KB 미만 객체는 모니터링 대상이 아니며 항상 Frequent Access에 유지됩니다.

> 🧠 원리: 왜 저비용 스토리지 클래스에는 최소 보관 기간이 존재할까요?
> AWS는 각 클래스를 특정 보관 기간을 전제로 설계하고, 그 기간 동안 발생하는 고정 비용(메타데이터 관리·인덱싱 등)을 저장 단가에 반영합니다.
> 최소 기간 이전에 객체를 삭제하면 고정 비용은 이미 발생했는데 회수할 저장 요금이 없으므로, AWS는 해당 기간치 요금을 청구해 원가를 보전합니다.
> 이 구조 때문에 최소 보관 기간보다 짧게 쓸 데이터는 더 저렴한 클래스가 오히려 비용이 높아질 수 있습니다.

### 3) 수명 주기 정책 (S3 Lifecycle)

수명 주기 정책은 객체를 자동으로 **전환하거나 삭제**해 비용을 절감합니다. 규칙은 기존 객체와 이후 업로드 객체 모두에 적용됩니다.

**두 가지 액션 유형:**

| 액션 유형 | 설명 | 예시 |
|---|---|---|
| **Transition(전환)** | 지정 기간 후 더 저렴한 클래스로 이동 | 30일 후 Standard→Standard-IA, 90일 후 →Glacier |
| **Expiration(만료)** | 지정 기간 후 객체 자동 삭제 | 365일 후 로그 파일 삭제 |

**전환 방향 제약**: 클래스 전환은 **더 저렴한 방향으로만** 가능합니다 (Standard → Standard-IA → Glacier 순서). 역방향 전환은 불가합니다.

**수명 주기 예시 (일반적인 로그 관리):**

```
Day 0    업로드 → S3 Standard
Day 30   → S3 Standard-IA (전환)
Day 90   → S3 Glacier Flexible Retrieval (전환)
Day 365  → 객체 삭제 (만료)
```

> 수명 주기 전환 자체에는 데이터 검색 요금이 없지만, PUT/COPY 요청 요금은 발생합니다. 최소 보관 기간(30일·90일·180일) 이전에 전환하면 해당 기간만큼 요금이 청구됩니다.

> 🧠 원리: 왜 수명 주기 전환은 더 저렴한 방향으로만 가능하고 역방향은 안 될까요?
> S3의 수명 주기는 "시간이 지날수록 접근 빈도가 낮아진다"는 데이터 냉각 패턴을 자동화하는 도구입니다.
> 더 저렴한 클래스는 검색 시 추가 요금이나 복원 지연이 따르므로, 역방향 전환(아카이브→Standard)은 의도적 복원 작업으로 분리해 설계되어 있습니다.
> 단방향 제약이 있어야 실수로 아카이브된 데이터를 자동으로 고비용 클래스로 끌어올리는 오작동을 막을 수 있습니다.

### 4) 성능 최적화

> 공식 기준: S3는 프리픽스당 초당 **3,500 PUT/DELETE** 또는 **5,500 GET/HEAD** 요청을 지원합니다. 프리픽스 수에는 제한이 없습니다.

| 기법 | 원리 | 사용 시점 |
|---|---|---|
| **프리픽스 병렬화** | 여러 프리픽스에 분산 저장 → 각 프리픽스가 독립적으로 처리량 한도를 가짐 | 대용량 데이터 읽기/쓰기 |
| **멀티파트 업로드** | 단일 파일을 여러 파트로 나눠 병렬 업로드 후 서버에서 조립 | 100 MB 이상 파일 권장, 5 GB 이상 필수 |
| **S3 Transfer Acceleration** | CloudFront 엣지 로케이션을 경유해 원거리 업로드를 가속 | 업로더가 S3 리전에서 지리적으로 멀 때 |
| **바이트 범위 요청(Byte-Range Fetch)** | 하나의 객체에서 특정 바이트 범위만 GET | 대용량 파일의 부분 읽기·병렬 다운로드 |

**멀티파트 업로드 흐름:**

```
1. CreateMultipartUpload → uploadId 발급
2. UploadPart × N (각 파트 최소 5 MB, 마지막 파트 제외)
3. CompleteMultipartUpload → S3가 파트를 조립해 단일 객체로 저장
```

> 업로드 실패 시 미완성 파트가 과금됩니다. 수명 주기 규칙에 **AbortIncompleteMultipartUpload** 액션을 추가해 자동 정리를 권장합니다.

> 🧠 원리: 왜 멀티파트 업로드는 대용량 파일의 신뢰성과 속도를 동시에 높일 수 있을까요?
> 단일 스트림으로 전송하면 어느 지점에서 오류가 발생해도 파일 전체를 처음부터 재전송해야 합니다.
> 멀티파트로 나누면 오류가 발생한 파트만 재전송하면 되므로, 네트워크 불안정 환경에서 실제 재전송 데이터량이 크게 줄어듭니다.
> 또한 파트들을 병렬로 동시에 전송하면 가용 대역폭을 여러 스트림이 나눠 쓰게 되어 단일 스트림보다 전체 전송 시간을 단축할 수 있습니다.

### 5) 접근 제어

S3의 접근 제어는 여러 계층이 겹쳐서 작동합니다. 요청은 아래 순서로 평가됩니다.

```
요청 도착
  → ① Block Public Access (계정/버킷 수준 최우선 안전장치)
  → ② IAM 정책 (요청자 신원 기반)
  → ③ 버킷 정책 (리소스 기반, 교차 계정·공개 제어)
  → ④ ACL (레거시 — 현재 기본 비활성화)
```

**각 계층 상세:**

| 계층 | 설명 | 핵심 특성 |
|---|---|---|
| **Block Public Access** | 버킷/계정 단위로 공개 접근을 일괄 차단 | **기본값: ON**. 버킷 정책·ACL보다 우선. 공개가 필요해도 이 설정을 먼저 확인 |
| **IAM 정책** | 요청자(사용자·역할)에게 붙은 아이덴티티 기반 정책 | 같은 계정 내 접근 제어의 기본 수단 |
| **버킷 정책** | 버킷에 붙은 리소스 기반 JSON 정책, 최대 20 KB | 교차 계정 접근, 특정 IP/VPC 허용, 공개 읽기 허용 시 사용 |
| **ACL** | 버킷·객체별 읽기/쓰기 권한을 AWS 계정 또는 그룹에 부여 | **레거시**. Object Ownership = Bucket owner enforced 설정 시 기본 비활성화. 신규 설계에서 비권장 |
| **프리사인 URL(Pre-signed URL)** | 서명된 URL로 시간 제한 임시 접근 부여 | SDK/CLI로 생성, 만료 시간 설정 가능. 인증 없는 사용자에게 일시적 다운로드 허용 |
| **S3 액세스 포인트** | 버킷에 연결된 전용 네트워크 엔드포인트, 자체 정책 보유 | 공유 데이터셋의 대규모 접근 관리·VPC 전용 접근 설정에 활용 |

**버킷 정책 예시 (CloudFront OAC를 통한 접근만 허용):**

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "Service": "cloudfront.amazonaws.com"
    },
    "Action": "s3:GetObject",
    "Resource": "arn:aws:s3:::my-bucket/*",
    "Condition": {
      "StringEquals": {
        "AWS:SourceArn": "arn:aws:cloudfront::123456789012:distribution/DIST_ID"
      }
    }
  }]
}
```

> 정적 웹사이트를 S3로 서비스할 때 버킷 자체를 퍼블릭으로 여는 것은 권장하지 않습니다. **CloudFront + OAC(Origin Access Control)** 조합을 사용하면 S3는 비공개로 유지하면서 CDN을 통해서만 콘텐츠를 전달할 수 있습니다.

> 🧠 원리: 왜 Block Public Access는 버킷 정책이나 ACL보다 먼저 평가되는 설계를 택했을까요?
> 버킷 정책과 ACL은 관리자가 의도적으로 설정하지만, 정책 실수나 권한 오·남용으로 의도치 않게 공개 접근이 허용될 가능성이 있습니다.
> Block Public Access를 최우선 평가 지점에 두면, 하위 정책에 무엇이 쓰여 있든 계정·버킷 수준에서 공개 접근을 일괄 차단할 수 있어 실수에 대한 안전망이 됩니다.
> 이 설계 덕분에 팀 규모가 커져 버킷 정책 관리가 복잡해져도, Block Public Access 설정 하나로 전체 공개 노출을 방어하는 단일 제어점을 유지할 수 있습니다.

### 6) 버전 관리와 복제

**버전 관리(Versioning):**

- 활성화하면 덮어쓰기·삭제 시에도 이전 버전이 보존됩니다.
- 삭제는 실제 삭제가 아니라 **삭제 마커(Delete marker)**를 추가합니다. 마커를 삭제하면 객체가 복원됩니다.
- **MFA Delete**: 버전을 영구 삭제할 때 MFA 인증을 추가로 요구. 실수·랜섬웨어 방어.
- 복제(CRR/SRR) 기능을 사용하려면 Versioning이 **소스·대상 버킷 모두** 활성화돼야 합니다.

**복제(Replication):**

| 종류 | 설명 | 주요 용도 |
|---|---|---|
| **CRR (Cross-Region Replication)** | 다른 AWS 리전의 버킷으로 복제 | 재해 복구, 지리적 지연 단축, 규정 준수 |
| **SRR (Same-Region Replication)** | 같은 리전 내 다른 버킷으로 복제 | 테스트/스테이징 환경 분리, 로그 집계 |

> 복제는 **신규 객체**에만 적용됩니다. 기존 객체는 **S3 Batch Replication**으로 별도 복제해야 합니다. 복제된 객체는 대상 버킷에서 독립적으로 관리됩니다.

> 🧠 원리: 왜 버전 관리에서 삭제 요청이 객체를 실제로 지우지 않고 삭제 마커를 추가할까요?
> 파일을 즉시 삭제하면 삭제 시점 이전의 모든 버전도 접근 경로가 끊겨 실질적으로 복구 불가 상태가 됩니다.
> 삭제 마커를 추가하는 방식은 기존 버전을 그대로 남기면서 "현재 최신 버전이 삭제됨"을 표시하는 것이므로, 마커만 제거하면 이전 버전이 다시 최신으로 복원됩니다.
> 이 방식은 실수에 의한 삭제와 의도적 영구 삭제를 구분해, 우발적 손실을 막는 안전 계층을 제공합니다.

---

## ✍️ 시험 포인트

- **스토리지 클래스 선택 3원칙**: 접근 빈도(자주/가끔/거의 없음) → 복원 시간(즉시/분/시간) → 재생성 가능 여부(One Zone-IA 여부).
- **Intelligent-Tiering**: 접근 패턴이 불명확할 때 유일한 올바른 선택. 검색 요금 없음(단, 오브젝트당 모니터링 요금).
- **최소 보관 기간**: Standard-IA·One Zone-IA = 30일, Glacier Instant/Flexible = 90일, Deep Archive = 180일. 이 기간 전에 삭제·전환해도 해당 기간 요금 청구.
- **Block Public Access**: 버킷 정책이 공개 허용이어도 Block Public Access가 ON이면 공개 접근 불가. **항상 최우선**.
- **정적 웹 + 글로벌 배포**: S3 + CloudFront + OAC. S3 직접 공개(Bucket public) 금지.
- **멀티파트 업로드**: 5 GB 초과 단일 파일은 API 상 멀티파트 필수. 100 MB 이상부터 권장.
- **Transfer Acceleration**: S3와 클라이언트가 지리적으로 멀 때. 엣지 로케이션 경유. 활성화 후 별도 엔드포인트(`s3-accelerate.amazonaws.com`) 사용.
- **프리사인 URL**: 사용자 인증 없이 한시적 접근 부여. 권한은 **서명한 IAM 주체의 권한 이하**로만 부여됨.
- **CRR 전제 조건**: 소스·대상 버킷 모두 Versioning 활성화 필수.
- **수명 주기 → Glacier**: 데이터를 아카이브하는 가장 일반적인 비용 최적화 패턴. 날짜·경과 일수(Days) 기준으로 규칙 지정.

---

## ⚠️ 흔한 함정

1. **"One Zone-IA에 유실 불가 원본을 저장한다."** → 단일 AZ 장애 시 데이터 영구 유실 가능. One Zone-IA는 재생성 가능한 데이터(예: CRR 복제본, 캐시)에만 사용합니다.
   *(원리: §1 — 다중 AZ 중복 저장이 내구성의 물리적 근거이며, One Zone-IA는 이 안전망을 포기한 설계다.)*

2. **"공개 접근이 필요하면 버킷 전체를 퍼블릭으로 연다."** → Block Public Access를 끄고 버킷을 공개하면 실수로 민감한 객체가 노출될 위험이 있습니다. CloudFront + OAC를 사용해 S3는 비공개로 유지합니다.
   *(원리: §5 — Block Public Access가 최우선 평가되는 이유는 하위 정책 실수를 계정 단위에서 차단하기 위한 단일 제어점 설계이기 때문이다.)*

3. **"Glacier에 저장하면 바로 꺼낼 수 있다."** → Glacier Flexible Retrieval과 Deep Archive는 아카이브 상태로 저장되며 **복원(Restore) 요청** 후에야 접근 가능합니다. 즉시 접근이 필요하면 **Glacier Instant Retrieval**을 사용합니다.
   *(원리: §2 — 복원 시간은 클래스 선택 기준의 하나이며, 클래스마다 밀리초~12시간으로 다르다.)*

4. **"수명 주기 전환 후 언제든 삭제해도 된다."** → Standard-IA·One Zone-IA는 30일, Glacier 클래스는 90일(Deep Archive는 180일) 미만 보관 시 **최소 보관 기간에 해당하는 요금이 청구**됩니다.
   *(원리: §2 — 최소 보관 기간은 클래스 고정 비용을 회수하기 위한 비용 구조적 장치다.)*

5. **"ACL을 적극 활용해 객체별 권한을 정밀하게 관리한다."** → ACL은 레거시입니다. 현재 S3는 Object Ownership = Bucket owner enforced가 기본값이며 ACL이 비활성화됩니다. 버킷 정책과 IAM 정책으로 관리하는 것이 권장 방식입니다.
   *(원리: §5 본문 — 접근 제어는 IAM·버킷 정책으로 관리하고, ACL은 신규 설계에서 비권장 레거시다.)*

6. **"복제 설정 후 기존 객체도 자동으로 복제된다."** → 복제는 설정 이후 생성·업데이트되는 **신규 객체**에만 적용됩니다. 기존 객체는 S3 Batch Replication을 별도 실행해야 합니다.
   *(원리: §6 — 삭제 마커 방식과 마찬가지로, 복제도 설정 이전 상태는 자동 소급 적용되지 않는다.)*

---

## 🧪 자가 점검

> 아래는 학습용 자가 점검입니다. (정식 검증 문항은 별도 문항 파일 참조)

**Q1.** 사용자들이 업로드하는 미디어 파일은 처음 한 달간 자주 접근하고, 이후에는 거의 접근하지 않지만 간혹 꺼낼 일이 있습니다. 3년 후에는 삭제해도 됩니다. 가장 비용 효율적인 수명 주기 설계는?

<details><summary>정답 보기</summary>

**S3 Standard → (30일 후) S3 Standard-IA → (365일 후) S3 Glacier Flexible Retrieval → (3년 후) 만료(삭제)** 순서의 수명 주기 정책을 적용합니다. 처음 한 달간은 Standard로 빠른 접근을 보장하고, 이후에는 Standard-IA로 저장 비용을 절감하며, 장기 보관 구간에서는 Glacier로 아카이브합니다. 최종적으로 만료 액션으로 자동 삭제해 관리 부담을 줄입니다.
</details>

**Q2.** 글로벌 사용자에게 S3에 저장된 정적 웹 자산을 빠르게 서비스하되, S3 버킷 자체는 외부에서 직접 접근할 수 없게 하려 합니다. 어떻게 설계하나요?

<details><summary>정답 보기</summary>

**CloudFront 배포를 생성하고 S3 버킷을 오리진으로 설정한 뒤, OAC(Origin Access Control)를 구성**합니다. 버킷 정책에는 CloudFront 서비스 주체만 `s3:GetObject`를 허용하고, 버킷의 Block Public Access는 ON으로 유지합니다. 이 조합은 S3를 완전히 비공개로 두면서 CloudFront를 통해서만 콘텐츠를 전달합니다.
</details>

**Q3.** 4 GB 크기의 파일을 S3에 업로드하려 합니다. 권장 방식과 그 이유는?

<details><summary>정답 보기</summary>

**멀티파트 업로드(Multipart Upload)**를 사용합니다. 5 GB 초과 파일은 멀티파트 업로드가 필수이지만, 100 MB 이상부터는 권장됩니다. 4 GB는 권장 범위에 해당합니다. 멀티파트 업로드는 파일을 여러 파트로 나눠 병렬 업로드한 뒤 서버에서 조립하므로, 대역폭을 최대한 활용하고 네트워크 오류 발생 시 해당 파트만 재전송할 수 있어 신뢰성이 높습니다.
</details>

**Q4.** 접근 패턴을 예측하기 어려운 데이터를 S3에 저장합니다. 불필요한 비용 없이 자동으로 비용을 최적화하는 스토리지 클래스는?

<details><summary>정답 보기</summary>

**S3 Intelligent-Tiering**입니다. 접근 패턴에 따라 자동으로 Frequent Access, Infrequent Access, Archive Instant Access 등의 계층으로 객체를 이동합니다. 검색 요금이 없고 최소 보관 기간도 없어, 접근 패턴이 불규칙하거나 불명확한 데이터에 가장 적합합니다. 단, 128 KB 미만 객체는 모니터링 대상이 아니며 항상 Frequent Access 계층에 유지됩니다.
</details>

**Q5 (원리).** 왜 S3 Transfer Acceleration은 S3 리전에서 멀리 있는 클라이언트의 업로드 속도를 높이는 데 효과적인가요?

<details><summary>정답 보기</summary>

클라이언트가 S3 리전에서 먼 곳에 있을 때 인터넷 경로는 홉 수가 많아 지연과 패킷 손실이 발생하기 쉽습니다. Transfer Acceleration은 클라이언트와 가까운 엣지 로케이션까지만 일반 인터넷으로 전송하고, 이후 엣지에서 S3까지는 AWS 내부의 최적화된 백본 네트워크를 경유합니다. 불안정한 공용 인터넷 구간을 최소화함으로써 장거리 업로드의 지연과 재전송을 줄일 수 있습니다.
</details>

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. 모든 URL은 WebFetch로 HTTP 200 응답을 확인했습니다. (작성·대조: 2026-06-07)

1. Amazon S3 소개 — https://docs.aws.amazon.com/AmazonS3/latest/userguide/Welcome.html
2. S3 스토리지 클래스 비교 — https://docs.aws.amazon.com/AmazonS3/latest/userguide/storage-class-intro.html
3. S3 수명 주기 관리 — https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lifecycle-mgmt.html
4. S3 성능 최적화 모범 사례 — https://docs.aws.amazon.com/AmazonS3/latest/userguide/optimizing-performance.html
5. SAA-C03 공식 시험 가이드 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
