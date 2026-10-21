---
examGuideTaskId: saa-t4-1
certCode: SAA-C03
domain: 4
domainName: 비용에 최적화된 아키텍처 설계
domainWeightPct: 20
title: 비용 최적화 스토리지 — S3 티어링·EBS 선택·수명주기·전송 비용
coversTasks:
  - "4.1"
sources:
  - title: S3 스토리지 클래스 비교 (공식)
    url: https://docs.aws.amazon.com/AmazonS3/latest/userguide/storage-class-intro.html
  - title: S3 Storage Lens — 기본 개념과 지표·권장사항 (공식)
    url: https://docs.aws.amazon.com/AmazonS3/latest/userguide/storage_lens_basics_metrics_recommendations.html
  - title: EBS 볼륨 타입 (공식)
    url: https://docs.aws.amazon.com/ebs/latest/userguide/ebs-volume-types.html
  - title: EBS General Purpose SSD (gp2·gp3) (공식)
    url: https://docs.aws.amazon.com/ebs/latest/userguide/general-purpose.html
  - title: EC2 데이터 전송 요금 (On-Demand 페이지 공식)
    url: https://aws.amazon.com/ec2/pricing/on-demand/
  - title: AWS Transfer Family FAQ — 요금 부과 방식 (공식)
    url: https://aws.amazon.com/aws-transfer-family/faqs/
  - title: AWS DataSync FAQ — DataSync와 Storage Gateway를 언제 쓰는가 (공식)
    url: https://aws.amazon.com/datasync/faqs/
  - title: S3 Transfer Acceleration — 추가 전송 요금 (공식)
    url: https://docs.aws.amazon.com/AmazonS3/latest/userguide/transfer-acceleration.html
  - title: SAA-C03 공식 시험 가이드 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
lastVerified: 2026-10-20
---

# 비용 최적화 스토리지 — S3 티어링·EBS 선택·수명주기·전송 비용

> **커버하는 공식 Task** — SAA-C03 · 도메인 4 「비용에 최적화된 아키텍처 설계」(20%) · **Task 4.1 비용 효율적인 스토리지 솔루션 설계** (`saa-t4-1`)
> 이 문서는 위 한 Task에 1:1로 매핑됩니다. S3 스토리지 클래스 선택은 saa-t3-1(성능 관점)에서도 다루지만, 이 문서는 **비용 절감**에 초점을 맞춥니다.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명할 수 있어야 합니다.

- [ ] **S3 비용 구조** — 스토리지·요청·검색 비용을 구분하고 클래스별 차이를 설명할 수 있다
- [ ] **Intelligent-Tiering 적합 조건** — 검색 요금이 없는 이유와 모니터링 요금이 드는 조건을 말할 수 있다
- [ ] **수명주기 정책 설계** — Transition·Expiration 규칙으로 비용을 낮추는 예시를 들 수 있다
- [ ] **EBS 볼륨 비용 비교** — gp3가 gp2보다 저렴한 이유와 rightsizing 방법을 안다
- [ ] **미사용 EBS 자원 정리** — 미사용 볼륨·오래된 스냅샷이 과금되는 이유를 설명할 수 있다
- [ ] **데이터 전송 비용 패턴** — 무료 경로와 과금 경로를 구분하고 S3 Gateway Endpoint로 NAT 비용을 회피하는 방법을 안다
- [ ] **S3 Storage Lens** — 조직 전체 스토리지 비용 최적화 기회를 탐지하는 도구임을 안다

---

## 🎯 왜 중요한가

- 도메인 4(20%)는 SAA에서 네 번째 비중입니다. "most cost-effective"는 시험 최빈출 키워드 — 요구를 충족하는 **가장 저렴한** 선택을 찾는 것이 목표입니다.
- 스토리지 비용은 크게 세 축입니다: **저장 요금**(어느 클래스에 얼마나 둘 것인가), **요청·검색 요금**(얼마나 자주 꺼낼 것인가), **데이터 전송 요금**(어느 경로로 이동하는가). 세 축을 모두 보지 않으면 의외의 청구가 발생합니다.
- EBS는 연결된 EC2 인스턴스가 꺼져 있어도 프로비전된 용량에 대해 계속 과금됩니다. 미사용 볼륨과 과잉 프로비전이 낭비의 주범입니다.

---

## 🔤 먼저 알아야 할 용어

이 문서를 읽는 데 필요한 기초 용어입니다. 이미 알면 건너뛰세요.

| 용어 | 영문 | 한 줄 풀이 |
|---|---|---|
| **프로비전** | Provision | 서비스에 필요한 용량·자원을 미리 할당하는 것 — 실제 사용량과 무관하게 비용이 발생하는 구조의 근거 |
| **가용 영역** | Availability Zone (AZ) | 리전 안에 물리적으로 분리된 데이터센터 묶음 — 하나가 장애 나도 다른 AZ는 독립 운영 |
| **IOPS** | Input/Output Operations Per Second | 디스크가 초당 처리할 수 있는 읽기·쓰기 횟수 — 크고 클수록 빠르지만 비용도 증가 |
| **NAT Gateway** | Network Address Translation Gateway | 프라이빗 서브넷의 인스턴스가 인터넷으로 나갈 수 있게 주소를 변환해주는 관리형 서비스 |
| **VPC** | Virtual Private Cloud | AWS 안에 논리적으로 격리된 가상 네트워크 — 서브넷·라우트 테이블·게이트웨이를 포함 |
| **멀티파트 업로드** | Multipart Upload | 대용량 객체를 여러 조각으로 나눠 병렬 업로드하는 방식 — 중단된 업로드가 완료되지 않으면 저장 요금 계속 발생 |

---

## 📖 핵심 개념 {#core-concepts}

### 1) S3 비용 구조 — 세 가지 요금 축 {#s3-cost-structure}

S3 비용은 단순히 "저장 요금"만이 아닙니다. 세 축을 같이 봐야 합니다.

| 비용 축 | 설명 | 클래스별 차이 |
|---|---|---|
| **스토리지 요금** | 저장된 GB·월 기준 | Standard > Standard-IA > One Zone-IA > Glacier 순으로 낮아짐 |
| **요청 요금** | PUT·GET·LIST 등 API 호출 수 | Glacier는 요청당 요금이 더 높음 |
| **검색(Retrieval) 요금** | 객체를 꺼낼 때 GB당 추가 과금 | Standard·Intelligent-Tiering = 없음. IA·Glacier 클래스 = 있음 |

> 핵심 트레이드오프: 저장 요금이 낮은 클래스일수록 검색 요금이 높습니다. 자주 꺼내는 데이터를 Glacier에 두면 도리어 비쌀 수 있습니다.

**Requester Pays — 요금 축의 일부를 요청자에게 넘기기 (★ 시험 포인트)**

기본적으로 **버킷 소유자가 스토리지·전송 비용을 전부** 냅니다. 버킷을 **Requester Pays** 로 구성하면 그 일부가 요청자에게 넘어갑니다.

| 비용 축 | Requester Pays 켰을 때 누가 내나 |
|---|---|
| **요청 요금** | **요청자** |
| **데이터 다운로드(전송)** | **요청자** |
| **스토리지(저장) 요금** | ⚠️ **항상 버킷 소유자** |

- 용도: 큰 데이터셋을 **공개하면서 접근 비용은 떠안지 않는** 것 — 공식 예시는 우편번호 디렉터리·참조 데이터·지리공간 정보·웹 크롤링 데이터입니다.
- ⚠️ **익명 접근이 허용되지 않습니다.** 과금 대상을 식별해야 하므로 **모든 요청을 인증**해야 합니다. "퍼블릭 읽기 + Requester Pays" 조합은 성립하지 않습니다.
- 요청자는 **과금을 인지했음을 표시**해야 합니다 — `DELETE`·`GET`·`HEAD`·`POST`·`PUT` 요청에 **`x-amz-request-payer` 헤더**(REST 는 `RequestPayer` 파라미터, CLI 는 `--request-payer`)를 넣지 않으면 요청이 거부됩니다.
- 요청자가 **IAM 역할을 가정**해 호출하면 **그 역할이 속한 계정**에 과금됩니다.
- **일반 목적 버킷 전용**입니다.

> 시험 신호: "데이터는 공개하되 **다운로드 비용은 사용자가 부담**하게 하라" → Requester Pays. 다만 "저장 비용도 넘긴다"는 선택지는 오답입니다.

> 🧠 원리: 왜 S3는 저장 요금과 검색 요금을 별도로 청구할까요?
> 자주 꺼내는 데이터일수록 빠르고 비싼 스토리지 계층에 두는 것이 합리적이고, 거의 꺼내지 않는 데이터는 느리더라도 저렴한 계층에 둘 수 있습니다.
> 두 비용 축을 분리하면 데이터 접근 빈도에 따라 최적 계층을 선택할 수 있는 신호가 되며, 접근 패턴이 바뀌면 클래스를 이동해 비용을 조정할 수 있습니다.
> 이 분리 구조 위에서 수명주기 정책은 시간 기반 전환을, Intelligent-Tiering은 접근 패턴 기반 자동 이동을 구현합니다.

### 2) S3 스토리지 클래스 — 비용 최적화 관점 {#s3-storage-classes}

| 클래스 | 저장 비용 수준 | 검색 요금 | 최소 보관 기간 | 비용 최적화 선택 기준 |
|---|---|---|---|---|
| **S3 Standard** | 높음 | 없음 | 없음 | 자주 접근(월 1회 이상) — 기본값 |
| **S3 Intelligent-Tiering** | 중간 (자동 조정) | **없음** | 없음 | 접근 패턴 불명확 — 모니터링 요금 있음 |
| **S3 Standard-IA** | 낮음 | GB당 과금 | 30일 | 가끔 접근, 재생성 불가 원본 |
| **S3 One Zone-IA** | 더 낮음 | GB당 과금 | 30일 | 가끔 접근, 재생성 가능 데이터 |
| **S3 Glacier Instant Retrieval** | 매우 낮음 | GB당 과금 | 90일 | 분기 1회 수준, 즉시 꺼내야 함 |
| **S3 Glacier Flexible Retrieval** | 매우 낮음 | GB당 과금 | 90일 | 연 1회 수준, 복원 수분~12시간 허용 |
| **S3 Glacier Deep Archive** | 최저 | GB당 과금 | 180일 | 연 1회 미만 초장기, 복원 12시간 내외 |

**S3 Intelligent-Tiering 비용 메커니즘:**

```
업로드 → Frequent Access (Standard와 동일 비용)
  30일 미접근 → Infrequent Access (저렴)
  90일 미접근 → Archive Instant Access (더 저렴, 즉시 접근)
  (선택 활성화) 90일 이상 → Archive Access
  (선택 활성화) 180일 이상 → Deep Archive Access
```

> 128 KB 미만 객체는 **모니터링 대상이 아니며** 자동 계층화 대상도 아니어서 항상 Frequent Access 계층에 머뭅니다. 즉 소용량 객체가 많은 버킷에서 Intelligent-Tiering은 **손해가 아니라 절감이 없는** 쪽입니다 — 그 객체들은 계층 이동이 일어나지 않습니다. (128 KB 이상 객체에서 모니터링 요금이 절감을 넘어서는 임계값을 제시하는 공식 문장은 확인하지 못했습니다.)

> 🧠 원리: 왜 S3 Intelligent-Tiering은 오브젝트당 모니터링 요금을 부과할까요?
> 계층 자동 이동은 각 객체의 접근 이력을 추적해야 가능하며, 이 추적 자체에 저장·연산 비용이 발생합니다.
> 모니터링 요금이 오브젝트 수에 비례하기 때문에, AWS는 128 KB 미만 객체를 추적 대상에서 아예 제외하고 항상 Frequent Access 단가로 저장합니다 — 추적 비용이 절감을 잠식하는 구간을 애초에 만들지 않는 설계입니다.
> 결국 Intelligent-Tiering이 유리한 조건은 객체 수가 적거나 객체 크기가 크면서 접근 패턴이 불규칙한 경우로 좁혀집니다.

### 3) S3 수명주기 정책 — 자동 비용 절감 {#s3-lifecycle}

수명주기 정책은 **시간 경과에 따라 자동으로 클래스를 전환하거나 객체를 삭제**해 수동 관리 없이 비용을 낮춥니다.

**전형적인 로그 비용 최적화 패턴:**

```
Day 0    → S3 Standard (자주 접근)
Day 30   → S3 Standard-IA (접근 감소)
Day 90   → S3 Glacier Flexible Retrieval (아카이브)
Day 365  → 만료(Expiration) — 자동 삭제
```

**수명주기 비용 주의 사항:**

- 최소 보관 기간 이전에 전환·삭제해도 **그 기간만큼 요금 청구** (Standard-IA·One Zone-IA = 30일, Glacier Instant/Flexible = 90일, Deep Archive = 180일).
- 미완성 멀티파트 업로드도 저장 요금이 발생합니다. 수명주기 규칙에 **AbortIncompleteMultipartUpload** 액션을 추가해 7일 후 자동 정리를 권장합니다.
- 전환 자체(Transition)에는 GB 검색 요금이 없지만, 전환 PUT 요청 요금은 발생합니다. 수명 주기 규칙이 객체를 전환할 때마다 **전환 요청 1건**으로 집계되므로, 대량 전환을 계획하면 **요청 비용을 따로 계산**해야 합니다.

**⚠️ 작은 객체에는 전환이 손해일 수 있습니다 (★ 시험 핵심)**

Glacier Flexible Retrieval·Deep Archive 로 전환되는 **객체마다 총 40 KB 의 오버헤드**가 붙습니다.

| 오버헤드 | 용도 | 과금 요율 |
|---|---|---|
| **8 KB** | 메타데이터와 객체 이름 저장 | **S3 Standard 요율** |
| **32 KB** | 인덱싱·관련 메타데이터 | **Glacier FR / Deep Archive 요율** |

- 그래서 공식 문서는 **작은 객체가 많으면 수명 주기 전환을 권장하지 않습니다.** 권고는 **작은 객체 다수를 더 적은 수의 큰 객체로 집계**(예: tar 로 묶기)한 뒤 S3 에 저장하는 것입니다.
- IA 쪽에도 같은 함정이 있습니다 — **Standard-IA·One Zone-IA 는 128 KB 를 넘는 객체에 적합**하고, ⚠️ **128 KB 미만이면 128 KB 로 과금**됩니다.
- 요약하면 "**전환 = 절감**"이 아니라 **객체 크기·개수·전환 요청 수**를 함께 봐야 합니다. 로그·썸네일처럼 작은 파일이 수억 개인 버킷은 **집계가 먼저**입니다.

**기본 최소 전환 크기 (★ 2024-09 이후 동작)**

수명 주기 구성에는 **기본 최소 객체 크기 동작**이 붙어 있고, `GetBucketLifecycleConfiguration` 응답의 **`x-amz-transition-default-minimum-object-size`** 헤더로 확인합니다.

| 값 | 동작 |
|---|---|
| **`all_storage_classes_128K`** | **128 KB 미만 객체는 어떤 스토리지 클래스로도 전환되지 않습니다** |
| `varies_by_storage_class` | 128 KB 미만도 **Glacier Flexible Retrieval·Deep Archive 로는 전환**되고, 그 밖의 클래스는 막힙니다 |

- 전환 규칙 본문에 **`ObjectSizeGreaterThan`** 또는 **`ObjectSizeLessThan`** 필터를 넣어 최소 크기를 직접 정할 수 있고, ⚠️ **커스텀 필터가 기본 동작보다 항상 우선**합니다.
- 범위를 둘로 지정하면 두 값은 **지정값을 제외**하며, 필터를 둘 이상 쓰면 **`<And>`** 로 묶어야 합니다.
- ⚠️ 이 기본 동작은 **일반 목적 버킷 전용**이고 **디렉터리 버킷 수명 주기에는 지원되지 않습니다.**

**버전 관리가 켜진 버킷의 비용**

버전 관리 버킷은 **비현행(noncurrent) 버전이 조용히 쌓여** 저장 요금을 먹습니다. 수명 주기로 정리합니다.

- **`NoncurrentVersionExpiration`** — 비현행이 된 뒤 지정 일수가 지나면 제거합니다.
- **`NewerNoncurrentVersions`** — 함께 쓰면 "**최근 N개는 남기고** 그보다 오래된 것만 제거"가 됩니다. ⚠️ 지정한 보관 수보다 **더 새로운 비현행 버전이 그만큼 존재해야** 특정 버전이 만료되며, 초과분은 **영구 삭제**됩니다.
- 삭제 마커만 남은 객체도 정리 대상입니다 — `ObjectSizeLessThan` 으로 데이터 없는 객체만 걸러낼 수 있습니다.

> 🧠 원리: 왜 수명주기 정책은 최소 보관 기간 요금을 부과할까요?
> IA·Glacier 클래스는 저장 단가가 낮은 대신, 최소 보관 기간이 충족되지 않은 채 삭제·전환이 일어나면 잔여 기간에 해당하는 저장 요금이 청구됩니다.
> 이 구조에서 30일 이전에 Standard-IA로 전환하면 절감이 아니라 오히려 비용이 늘어날 수 있습니다.
> 따라서 데이터의 실제 보관 주기를 먼저 파악한 뒤 수명주기 전환 시점을 설정해야 절감 효과가 납니다.

### 4) EBS 비용 최적화 {#ebs-cost}

EBS는 인스턴스가 중지(stop)된 상태에서도 **프로비전된 볼륨 용량에 대해 계속 과금**됩니다.

**gp3 vs gp2 비용 비교:**

| 항목 | gp2 | gp3 |
|---|---|---|
| GB당 요금 | 기준 | **약 20% 저렴** |
| 기본 IOPS | 3 IOPS/GB (최소 100, 최대 16,000) | **3,000 IOPS 고정** (크기와 무관) |
| 기본 처리량 | 128~250 MiB/s | **125 MiB/s 고정** |
| 버스트 구조 | I/O 크레딧 버스트 | 없음 — 항상 프로비전 성능 유지 |
| 추가 IOPS 독립 조정 | 불가 (크기 늘려야 함) | 가능 (크기와 독립) |

> gp3는 gp2보다 GB당 약 20% 저렴하면서 기본 IOPS(3,000)가 크기와 무관하게 제공됩니다. 소용량 gp2 볼륨은 기본 IOPS가 낮아 크기를 불필요하게 키우는 경우가 많습니다. gp3로 전환하면 크기는 줄이고 비용도 낮출 수 있습니다.

**SSD 밖의 선택지 — HDD 두 종 (★ 시험 포인트)**

SSD만 보면 비용 최적화의 한 축을 놓칩니다. HDD 계열은 성능을 **IOPS 가 아니라 처리량**으로 정의합니다.

| 타입 | 설계 의도 | 부팅 볼륨 |
|---|---|---|
| **st1**(Throughput Optimized HDD) | **크고 순차적인** 처리량 중심 워크로드 — 빅데이터·로그 처리·데이터 웨어하우스 | 불가 |
| **sc1**(Cold HDD) | `st1`보다 **낮은 처리량 한도**의 저비용 마그네틱 — **드물게 접근하는** 크고 순차적인 콜드 데이터 | ⚠️ **불가**(공식: "Bootable `sc1` volumes are not supported") |

- ⚠️ **작고 랜덤한 I/O 에는 HDD 가 비효율적**입니다. 공식은 그런 워크로드에 **범용 SSD 또는 Provisioned IOPS SSD** 를 권장합니다 — "싸니까 HDD" 는 OLTP·부팅 디스크에서 오답입니다.
- EBS 최적화 인스턴스에 연결된 `sc1` 은 **1년 중 99% 의 시간 동안 기대 처리량의 최소 90%** 를 제공하도록 설계됐습니다.

**스냅샷 아카이브와 Recycle Bin — 보관 비용을 더 내리는 층**

| 수단 | 핵심 |
|---|---|
| **EBS Snapshots Archive** | 스냅샷을 아카이브 티어로 옮겨 장기 보관 비용을 낮춥니다. ⚠️ **최소 아카이브 기간 90일** — 그 전에 삭제·영구 복원하면 잔여 일수를 **시간 단위로 반올림해** 과금합니다 |
| **Recycle Bin** | 보존 규칙(retention rule)에 맞는 스냅샷은 삭제해도 **규칙 기간 동안 보관**돼 실수 삭제를 되돌릴 수 있습니다 |

- 복원(아카이브 → 표준)에 **최대 72시간**이 걸립니다(크기에 따라). ⚠️ **아카이브된 스냅샷은 블록 디바이스 매핑에 쓸 수 없고 EBS 볼륨을 만들 수도 없습니다** — 먼저 표준 티어로 복원해야 합니다.
- ⚠️ **아카이브 스냅샷은 항상 전체(full) 스냅샷**입니다. 원본 증분 스냅샷보다 **클 가능성**이 높습니다(볼륨의 표준 티어 스냅샷이 하나뿐이면 같은 크기 — 첫 스냅샷은 항상 전체입니다).
- 그래서 **월·분기·연 단위 스냅샷에 적합**하고, ⚠️ **단일 볼륨의 일별 증분 스냅샷을 아카이브하면 표준 티어에 두는 것보다 오히려 비싸질 수 있습니다.** "아카이브 = 항상 절감" 이 아닙니다.
- 아카이브 시 계보(lineage)의 다른 스냅샷이 참조하는 데이터는 **표준 티어에 남고**, 그 비용은 **계보의 다음 스냅샷에 배분**됩니다 — 후속 스냅샷이 아카이브에 영향받지 않게 하는 설계입니다.
- Recycle Bin 규칙에 걸린 아카이브 스냅샷을 쓰려면 **Recycle Bin 복구 → 아카이브 복원** 2단계를 거칩니다.
- **DLM** 으로 자동화할 때 `RetentionArchiveTier` 는 **최소 90일 보관**을 보장해야 합니다 — 30일마다 스냅샷을 만든다면 **보관 수를 3 이상**으로 둬야 각 스냅샷이 90일을 채웁니다. AWS Backup 이 만든 스냅샷도 아카이브할 수 있습니다.

**EBS 비용 낭비 패턴 및 정리 방법:**

| 낭비 패턴 | 정리 방법 |
|---|---|
| 인스턴스 종료 후 남은 볼륨 | 콘솔·AWS Trusted Advisor·Cost Explorer로 미연결 볼륨 탐지 후 삭제 |
| 누적된 오래된 스냅샷 | Data Lifecycle Manager(DLM)로 보존 정책 설정, 오래된 스냅샷 자동 삭제 |
| 과잉 프로비전된 볼륨 | Amazon Compute Optimizer가 rightsizing 권장 |
| gp2 → gp3 전환 미적용 | Elastic Volumes로 무중단 타입 변경 가능 |

> 🧠 원리: 왜 gp2는 소용량 볼륨일수록 크기를 키워야 했을까요?
> gp2의 IOPS는 볼륨 크기(GB)에 비례해 계산되는 구조였으므로, 필요한 IOPS를 확보하려면 실제 데이터 저장에 필요한 것보다 더 큰 볼륨을 프로비전해야 했습니다.
> 이 연동 구조에서는 데이터가 적더라도 성능을 위해 빈 용량에 비용을 지불하게 되어 과잉 프로비전으로 이어질 수 있었습니다.
> gp3는 크기와 IOPS를 독립적으로 설정할 수 있어 이 연동을 끊고 실제 요구 사항에만 비용을 맞출 수 있게 합니다.

### 5) 데이터 전송 비용 {#data-transfer-cost}

데이터 전송 비용은 **경로**에 따라 무료 또는 유료로 나뉩니다. 시험에서 자주 간과되는 영역입니다.

| 전송 경로 | 요금 |
|---|---|
| 같은 AZ 내 EC2↔EC2 또는 EC2↔S3 (프라이빗 IP) | **무료** |
| 교차 AZ (같은 리전, 퍼블릭 IP 또는 Elastic IP) | **과금** (양방향) |
| 교차 AZ (같은 리전, 프라이빗 IP) | **과금** (양방향, 더 낮은 요율) |
| 교차 리전 전송 | **과금** |
| 인터넷 인바운드 (외부 → AWS) | 무료 |
| 인터넷 아웃바운드 (AWS → 외부) | **과금** (월 100 GB까지 무료) |
| AWS → CloudFront 오리진 전송 | **무료** |
| S3 Gateway Endpoint 경유 (VPC 내) | **무료** (NAT Gateway 처리 비용 발생 안 함) |

**NAT Gateway 데이터 처리 비용 회피 패턴:**

```
[일반 경로] VPC 프라이빗 서브넷 → NAT Gateway → S3
  → NAT Gateway 처리 요금(GB당) 발생

[최적화 경로] VPC 프라이빗 서브넷 → S3 Gateway Endpoint → S3
  → NAT Gateway 경유 없음 → 처리 요금 없음 + 보안 강화
```

> S3 Gateway Endpoint는 무료로 생성하며 라우트 테이블에 추가하는 것만으로 적용됩니다. NAT Gateway를 통한 S3 트래픽이 많은 환경에서는 즉각적인 비용 절감 효과가 있습니다.

**CloudFront로 인터넷 아웃바운드 비용 절감:**

S3에서 직접 인터넷으로 객체를 서비스하면 S3 아웃바운드 요금이 발생합니다. CloudFront를 앞에 두면 S3→CloudFront 전송은 무료이고, 캐시 히트 시 S3 요청·전송 자체가 발생하지 않아 비용과 성능을 동시에 개선합니다.

> 🧠 원리: 왜 같은 리전 안에서도 AZ를 넘는 전송에는 요금이 발생할까요?
> 같은 AZ 내 트래픽은 단일 물리 시설 안에서 처리되지만, AZ를 넘는 트래픽은 AWS가 관리하는 리전 내부 네트워크를 경유해야 하며 이 구간의 대역폭 비용이 청구됩니다.
> 고가용성을 위해 여러 AZ에 인스턴스를 분산하면 AZ 간 통신이 필연적으로 발생하므로, 아키텍처 설계 단계에서 이 비용 패턴을 인식해야 예상치 못한 청구를 피할 수 있습니다.
> 같은 AZ 내 프라이빗 IP 통신을 활용하거나 데이터 복제 범위를 최소화하면 AZ 간 전송 비용을 줄일 수 있습니다.

### 6) EFS·FSx 비용 계층 {#efs-fsx-cost}

| 서비스 | 스토리지 계층 | 비용 특성 |
|---|---|---|
| **Amazon EFS** | Standard | 기본, 자주 접근하는 파일 |
| **Amazon EFS** | Infrequent Access (IA) | Standard보다 저렴, 접근 시 GB당 검색 요금 |
| **Amazon EFS** | Archive | 거의 접근 안 하는 파일, 최저가 |
| **Amazon EFS Intelligent-Tiering** | — | 접근 패턴에 따라 Standard↔IA↔Archive 자동 전환 |
| **Amazon FSx for Windows** | SSD / HDD | HDD 계층이 저렴 — 처리량 중심 워크로드에 HDD 선택 |
| **Amazon FSx for Lustre** | Persistent / Scratch | Scratch는 임시·저렴, Persistent는 복제·내구성 제공 |

> EFS IA/Archive는 S3 IA와 유사한 구조입니다. 자주 접근하지 않는 파일을 EFS Intelligent-Tiering으로 설정하면 자동으로 저렴한 계층으로 이동합니다.

**FSx for NetApp ONTAP — 티어가 둘이고, 비용은 "볼륨별 정책"으로 정합니다 (★ 시험 포인트)**

| 티어 | 성격 |
|---|---|
| **SSD 티어**(기본 스토리지) | 사용자가 **프로비저닝**하는 고성능 SSD — 데이터셋의 **활성 부분** 전용 |
| **용량 풀(capacity pool) 티어** | **완전 탄력적**이며 **페타바이트 규모까지 자동 확장**. 드물게 접근하는 데이터에 **비용 최적화** |

- ONTAP 의 **볼륨은 폴더처럼 그 자체로 용량을 소비하지 않는 가상 리소스**입니다. 볼륨은 **씬 프로비저닝**이라 파일 시스템 스토리지를 미리 예약하지 않고, **SSD 와 용량 풀이 필요에 따라 동적으로 할당**됩니다.
- 비용을 가르는 것은 **볼륨 수준에서 설정하는 티어링 정책**입니다 — SSD 티어의 데이터가 **언제 용량 풀로 내려갈지**를 정하고, 정책의 **쿨링 기간**이 "비활성(콜드)" 판정 시점을 정합니다. 즉 **볼륨마다 요건에 맞는 정책을 고르는 것**이 절감 수단입니다.
- SSD 용량은 수요가 늘면 **늘릴 수 있고**, ⚠️ **2세대 파일 시스템에서는 줄일 수도 있습니다**(고성능 요건이 바뀔 때 비용을 되돌릴 수 있는 길).

> 그래서 "ONTAP 이 비싸다"는 진단에는 **SSD 티어를 과하게 프로비저닝했거나 티어링 정책이 콜드 데이터를 내려보내지 않고 있다**는 두 원인이 먼저 의심됩니다.

> 🧠 원리: 왜 EFS는 파일 단위 계층을 두고 S3와 다르게 블록 스토리지(EBS)는 계층 구조가 없을까요?
> EFS는 여러 인스턴스가 공유 파일시스템으로 접근하므로 개별 파일마다 접근 빈도를 추적해 계층을 이동하는 것이 가능합니다.
> EBS는 단일 EC2 인스턴스에 블록 장치로 연결되며, 블록 레벨에서는 어느 데이터가 자주 쓰이는지 파악하기 어려워 파일 단위 계층 이동이 적용되지 않습니다.
> 이 차이로 인해 EBS 비용 최적화는 계층 이동이 아닌 볼륨 타입 선택과 rightsizing을 통해 이루어집니다.

### 7) S3 Storage Lens — 조직 전체 비용 탐지 도구 {#s3-storage-lens}

S3 Storage Lens는 조직 전체 버킷의 스토리지 사용 현황과 활동 지표를 **일별로 집계해 대시보드와 권장사항**을 제공합니다.

비용 최적화 관련 주요 기능:

- **미완성 멀티파트 업로드 탐지** — 7일 이상 된 미완성 멀티파트 업로드가 있는 버킷을 식별해 수명주기 규칙 추가를 권장합니다.
- **수명주기 규칙 미적용 버킷 탐지** — Lifecycle 규칙이 없는 버킷을 찾아내 자동 전환·만료 적용 기회를 제안합니다.
- **비접근 객체 분포** — 오랫동안 접근하지 않은 객체 비율을 보여줘 클래스 전환 타깃을 찾는 데 활용합니다.
- **Storage Class Analysis** (별개 기능) — Standard vs Standard-IA 최적 전환 시점을 분석해 수명주기 정책 생성에 활용합니다. 단 이것은 **S3 분석(S3 analytics)의 기능이며 Storage Lens와 별개**입니다 — 버킷·접두어·태그 필터로 버킷마다 따로 설정합니다.

**⚠️ 무료 티어로는 어디까지 보이나 — 지표 선택이 둘입니다 (★ 시험 포인트)**

| 티어 | 포함 지표 | 쿼리 가능 기간 | 과금 |
|---|---|---|---|
| **무료(free) 지표** | 버킷·객체 수 같은 사용량 + **사용 사례 기반 지표(비용 최적화·데이터 보호)**. **매일 수집** | **14일** | 모든 대시보드에 무료 |
| **고급(advanced) 티어** | 무료 전부 + **고급 성능·고급 데이터 보호·고급 비용 최적화** 지표, **활동 지표**·**상세 상태 코드** 범주, 그리고 **권장 사항** | **15개월** | ⚠️ **추가 요금** |

고급 티어에서만 되는 것:

- **권장 사항(recommendations)** — 대시보드에서 **관련 지표 옆에 문맥으로** 배치됩니다. 위에 적은 "수명주기 규칙 미적용 버킷" 류의 제안이 여기에 속합니다.
- **CloudWatch 퍼블리싱** — Storage Lens 지표를 CloudWatch 로 보내 **알람·지표 수식·이상 탐지**를 걸 수 있습니다.
- **접두어 집계** — 상위 접두어 단위로 사용량·활동 추세를 봅니다.
- 내보내기는 S3 범용 버킷(CSV·Parquet) 또는 S3 테이블 버킷(**Parquet 만**)으로 합니다.

> ⚠️ **Storage Lens 그룹(Storage Lens groups)에는 무료 티어 스토리지 지표만** 제공됩니다 — **그룹 수준에서는 고급 티어 지표를 쓸 수 없습니다.** "그룹으로 묶어 고급 지표를 보자"는 설계는 성립하지 않습니다.

> 🧠 원리: 왜 스토리지 비용 최적화를 위해 별도 관측 도구가 필요할까요?
> 수십~수백 개 버킷에서 각각 접근 패턴, 수명주기 적용 여부, 미완성 업로드 존재 여부를 수동으로 점검하는 것은 현실적으로 어렵습니다.
> Storage Lens는 조직 전체 버킷의 활동 지표를 일별로 집계해 최적화 기회가 있는 버킷을 자동으로 식별하므로, 비용 낭비 지점을 빠르게 좁힐 수 있습니다.
> 정책 적용 전에 실제 데이터로 현황을 파악해야 불필요한 전환 비용 없이 효과가 큰 버킷부터 우선순위를 정할 수 있습니다.

---

### 8) 온프레미스 데이터를 옮기는 비용 — 전송·하이브리드 서비스 선택 {#transfer-service-cost}

"온프레미스 데이터를 AWS로 옮기는 가장 저렴한 방법"은 **옮기는 성격**에 따라 답이 갈립니다. 한 번 옮기고 끝인지, 계속 접근해야 하는지, 외부 파트너가 붙는지를 먼저 봅니다.

| 수단 | 과금 구조 | 언제 가장 싼가 |
|---|---|---|
| **AWS DataSync** | 복사한 데이터 **GB당** 과금 | 대역폭이 있고 **옮기기만** 하면 될 때(일회성·주기적 동기화) |
| **AWS Transfer Family** | **활성화한 프로토콜별 시간당** + 전송량(GB). AS2는 메시지 수 기준 | 외부 파트너가 SFTP·FTPS·FTP·AS2 클라이언트를 그대로 써야 할 때 |
| **AWS Storage Gateway** | 게이트웨이 + 클라우드에 저장된 용량·요청 | 이전이 끝난 뒤에도 온프레미스 앱이 **계속** 접근해야 할 때 |
| **S3 Transfer Acceleration** | S3 표준 전송 요금에 **추가 요금**, **가속된 전송에만** 과금 | 대륙 간 업로드처럼 거리·객체 크기 때문에 실제로 가속 효과가 날 때 |

**시험에서 자주 틀리는 두 가지**

- **Transfer Family 서버를 "중지"해도 요금은 멈추지 않습니다.** 과금은 엔드포인트를 만들어 프로토콜을 켠 시점부터 **삭제할 때까지** 이어집니다. 비용을 끊으려면 서버를 삭제해야 합니다.
- **Transfer Acceleration은 공짜 최적화가 아닙니다.** S3 전송 요금에 **더해지는** 요금이고, 가속이 실제로 일어난 전송에만 붙습니다. 거리가 가깝거나 객체가 작으면 효과 없이 비용만 늘 수 있습니다.

> 오프라인 물리 전송은 선택지에서 빠졌습니다 — **Snow 패밀리는 신규 고객이 주문할 수 없고**, 현행 물리 경로는 AWS Data Transfer Terminal입니다(`saa-t3-9` §10).

> 🧠 원리: 왜 "전송 도구"와 "접근 계층"은 과금 축이 다를까요?
> DataSync처럼 데이터를 옮기는 도구는 작업이 끝나면 역할도 끝나므로, 비용을 **옮긴 양**에 비례시키는 것이 쓰는 만큼 내는 구조에 맞습니다.
> 반면 Transfer Family나 Storage Gateway는 외부 클라이언트와 온프레미스 앱이 언제든 접속할 수 있도록 **엔드포인트를 상시 띄워 두는** 서비스라, 데이터가 흐르지 않는 시간에도 그 대기 상태 자체에 비용이 듭니다.
> 그래서 전송 도구는 "얼마나 옮겼나", 접근 계층은 "얼마나 오래 켜 두었나"가 요금의 주축이 되고, Transfer Family를 중지해도 과금이 계속되는 것도 같은 이유입니다.

### 9) 올바른 크기와 오토 스케일링이 필요한 시점 {#sizing-autoscaling}

과잉 프로비저닝은 스토리지 낭비의 1순위입니다. 그런데 **되돌릴 수 있는 방향이 서비스마다 다르기** 때문에, "나중에 줄이면 되지"가 통하지 않는 곳이 있습니다.

| 서비스 | 크기 지정 | 늘리기 | 줄이기 |
|---|---|---|---|
| **Amazon S3** | 없음 — **탄력** | 자동 | 자동(쓴 만큼) |
| **Amazon EFS** | 없음 — **탄력** | 자동 | 자동 |
| **Amazon EBS** | 지정 필요 | Elastic Volumes 로 가능 | ⚠️ **줄일 수 없습니다** — 더 작은 새 볼륨을 만들어 데이터를 옮겨야 합니다 |
| **FSx for Windows** | 지정 필요 | 가능 | ⚠️ **증가만** 가능합니다 |
| **FSx for NetApp ONTAP** | SSD 지정 + 용량 풀 탄력 | 가능 | **2세대 파일 시스템은 SSD 감소 가능**(§6) |
| **Amazon RDS** | 지정 필요 | **스토리지 오토 스케일링**으로 자동(`saa-t3-5` §6의 3조건) | ⚠️ 축소 불가 |

**그래서 오토 스케일링이 필요한 시점은 이렇게 갈립니다.**

- **S3·EFS 는 애초에 오토 스케일링 개념이 없습니다** — 크기를 지정하지 않으므로 "늘릴지" 고민할 일이 없고, 비용 관리는 **클래스·티어 선택**의 문제로 바뀝니다.
- **EBS·FSx·RDS 는 "증설 자동화"가 필요합니다.** 성장 속도를 예측하기 어렵고 **축소가 불가능하거나 번거로우므로**, 작게 시작해 자동으로 늘리는 쪽이 안전합니다.
- 반대로 **크게 잡아 두고 나중에 줄이는 전략은 EBS·FSx Windows·RDS 에서 성립하지 않습니다.** 이것이 "올바른 크기"를 **처음에** 따져야 하는 이유입니다.

> 🧠 원리: 왜 블록·파일 스토리지는 줄이기가 어렵고 객체 스토리지는 그런 개념이 없을까요?
> S3 는 객체를 넣은 만큼만 과금하는 **사용량 모델**이라, 고객이 "용량"을 선언할 필요가 없습니다. 지울 수 있으니 줄이는 것도 그냥 지우는 것입니다.
> EBS·FSx·RDS 는 **파일 시스템을 담는 블록 장치를 미리 할당**하는 모델입니다. 파일 시스템의 메타데이터와 데이터 배치가 그 크기를 전제로 만들어지므로, 장치를 뒤에서 잘라내면 이미 그 영역에 쓰인 데이터와 구조가 깨집니다. 그래서 **늘리기는 뒤에 붙이면 되지만 줄이기는 안전하게 할 방법이 없어** 새 볼륨으로 옮기는 수밖에 없습니다.
> 이 비대칭 때문에 비용 설계의 순서도 달라집니다 — 객체 스토리지는 **넣고 나서 클래스를 조정**하면 되지만, 블록·파일 스토리지는 **처음 크기를 보수적으로 잡고 자동 증설에 맡기는** 것이 정석입니다.

### 10) 스토리지 선택 매트릭스 — 요구에서 비용으로 {#storage-selection-matrix}

가장 저렴한 서비스를 먼저 고르면 틀립니다. 공식 순서는 **요구를 먼저 고정하고, 그 요구를 만족하는 후보 안에서 비용을 비교**하는 것입니다.

**1단계 — 요구로 후보를 좁힙니다**

| 요구 | S3 | EBS | EFS | FSx |
|---|---|---|---|---|
| **접근 방식** | HTTP API(객체) | 블록 장치(단일 인스턴스 연결) | **NFS**(POSIX) | **SMB**(Windows) · **Lustre** · ONTAP(NFS·SMB·iSCSI) |
| **공유** | 무제한 동시 접근 | ⚠️ 기본 단일 — Multi-Attach 는 io2 + Nitro 한정(`saa-t3-2`) | 다중 인스턴스 공유 | 다중 클라이언트 공유 |
| **지연** | 수십 ms | **한 자릿수 ms 미만** | 한 자릿수 ms | 한 자릿수 ms(Lustre 는 서브 ms급) |
| **기존 앱 호환** | 코드 수정 필요 | OS 그대로 | POSIX 그대로 | **Windows·HPC 앱 그대로** |

**2단계 — 좁혀진 후보 안에서 비용 축을 비교합니다**

| 비용 축 | 어디서 물리나 |
|---|---|
| **저장 단가** | 클래스·티어 선택 (S3 클래스 · EBS gp3/st1/sc1 · EFS IA/Archive · FSx HDD·용량 풀) |
| **최소 스토리지 기간** | S3 IA **30일** · Glacier FR·IR **90일** · Deep Archive **180일** · EBS 아카이브 **90일** |
| **최소 과금 크기·오버헤드** | S3 IA **128 KB** · Glacier 전환 **객체당 40 KB** |
| **검색·전환 요금** | IA·Glacier 의 GB 검색 요금, 수명 주기 **전환 요청** 건당 요금 |
| **상시 대기 비용** | Transfer Family·Storage Gateway 처럼 엔드포인트를 띄워 두는 서비스(§8) |

> **순서를 뒤집으면 생기는 전형적 오답**: "비용이 가장 낮으니 S3" — 그런데 요건이 **POSIX 파일 잠금**이면 S3 는 후보가 아닙니다. "HDD 가 싸니 sc1" — 그런데 **부팅 볼륨**이면 `sc1` 은 쓸 수 없습니다(§4). 요구를 먼저 고정해야 이런 선택지를 바로 걸러냅니다.

> 🧠 원리: 왜 "가장 싼 스토리지"를 먼저 고르면 거의 틀릴까요?
> 스토리지 서비스의 단가 차이는 **같은 일을 더 싸게 하는 것이 아니라 다른 일을 하기 때문**에 생깁니다. Glacier 가 싼 것은 즉시 꺼낼 필요가 없다는 전제를, `sc1` 이 싼 것은 순차 접근이라는 전제를 깔고 있습니다.
> 그래서 단가만 보고 고르면 전제를 어기게 되고, 그 대가가 **검색 요금·최소 기간 수수료·성능 미달**로 돌아옵니다. 비용 최적화가 아니라 비용 이전이 됩니다.
> 요구를 먼저 고정하면 후보 집합이 작아지고, 그 안에서는 단가 비교가 실제로 의미를 가집니다 — 같은 전제를 공유하는 선택지들끼리의 비교가 되기 때문입니다.

---

## ✍️ 시험 포인트

| 시나리오 | 정답 패턴 |
|---|---|
| 접근 패턴 불명확, 검색 요금 피하고 싶음 | S3 Intelligent-Tiering |
| 7년 규정 보관, 거의 안 꺼냄, 최저 비용 | S3 Glacier Deep Archive |
| 아카이브이지만 즉시(밀리초) 꺼내야 함 | S3 Glacier Instant Retrieval |
| 오래된 객체를 자동으로 저렴하게 | S3 수명주기 정책 (Transition) |
| 기한 지난 로그 자동 삭제 | S3 수명주기 Expiration |
| EBS 비용 절감, 볼륨 타입 변경 | gp2 → gp3 전환 (20% 저렴, 무중단) |
| EC2 종료 후 불필요 EBS 탐지 | Trusted Advisor·Cost Explorer → 미연결 볼륨 삭제 |
| 프라이빗 서브넷 → S3, NAT 비용 줄이기 | S3 Gateway Endpoint 추가 |
| 인터넷 아웃바운드 S3 비용 절감 | CloudFront 배포 앞에 두기 (S3→CF 전송 무료) |
| EFS 비용 자동 최적화 | EFS Intelligent-Tiering 활성화 |

---

## ⚠️ 흔한 함정 {#common-pitfalls}

1. **"Glacier는 무조건 저렴하다."** → 검색 요금이 GB당 과금되고 최소 보관 기간(90~180일)이 있습니다. 자주 꺼내는 데이터를 Glacier에 두면 Standard보다 비쌀 수 있습니다.
   *(원리: §1 🧠 — 저장 요금이 낮은 계층일수록 검색 요금이 있으며, 두 축을 분리해 접근 빈도에 따라 최적 계층을 선택해야 한다.)*

2. **"EC2를 Stop하면 EBS 요금도 안 낸다."** → EBS는 인스턴스가 중지 상태여도 프로비전된 용량에 대해 계속 과금됩니다. 단, **Terminate가 모든 볼륨을 지우는 것은 아닙니다** — 삭제 여부는 볼륨의 `DeleteOnTermination` 값에 따릅니다. 기본값은 **시작 시 연결된 루트 볼륨만 삭제**이고, 데이터 볼륨은 콘솔로 시작 시 연결하면 **보존**(CLI는 삭제), 시작 후 연결한 볼륨은 모두 보존입니다. 남은 볼륨은 계속 과금되므로 직접 삭제해야 합니다.
   *(원리: §4 본문 — EBS 과금은 볼륨 수명에 붙으므로, 인스턴스 수명과 볼륨 수명을 잇는 `DeleteOnTermination` 속성을 확인해야 비용이 멈춘다.)*

3. **"수명주기 전환은 언제 해도 최소 보관 기간 요금이 없다."** → Standard-IA는 30일, Glacier 계열은 90일(Deep Archive 180일) 미만 보관 시 해당 기간 요금이 청구됩니다. 30일 이전에 Standard-IA로 전환하면 절감이 아닙니다.
   *(원리: §3 🧠 — 최소 보관 기간 충족 전 삭제·전환이 일어나면 잔여 기간에 해당하는 저장 요금이 청구된다.)*

4. **"같은 리전이면 AZ 간 전송도 무료다."** → 같은 리전이라도 **AZ를 넘는 전송은 과금**됩니다. 고가용성 아키텍처에서 AZ 간 트래픽이 많으면 예상치 못한 비용이 발생합니다. 같은 AZ 내 프라이빗 IP 통신이 무료입니다.
   *(원리: §5 🧠 — AZ 간 전송은 AWS 리전 내부 네트워크를 경유하며 해당 구간 비용이 청구된다.)*

5. **"NAT Gateway는 보안 도구라 비용 최적화와 무관하다."** → NAT Gateway는 **데이터 처리 요금(GB당)** 이 별도로 청구됩니다. S3·DynamoDB는 Gateway Endpoint로 우회하면 NAT 처리 비용이 발생하지 않습니다.
   *(원리: §5 본문 — S3 Gateway Endpoint를 사용하면 트래픽이 NAT Gateway를 경유하지 않아 데이터 처리 요금이 발생하지 않는다.)*

6. **"gp3는 gp2보다 성능이 낮아 저렴한 것이다."** → gp3는 기본 IOPS(3,000)가 크기와 무관하게 제공되며 버스트 없이 일관된 성능을 냅니다. gp2는 소용량일수록 IOPS가 낮고 버스트 크레딧에 의존합니다. gp3가 성능과 비용 모두 유리한 경우가 대부분입니다.
   *(원리: §4 🧠 — gp2는 크기-IOPS 연동 구조 때문에 소용량에서 성능 확보를 위해 과잉 프로비전이 필요했으나, gp3는 이 연동을 분리했다.)*

7. **"Intelligent-Tiering은 모든 객체에 무조건 이득이다."** → 128 KB 미만 객체는 **모니터링 대상이 아니며 자동 계층화 대상도 아니라** 항상 Frequent Access 단가로 저장됩니다. 그래서 소용량 객체가 대부분인 버킷에서는 Intelligent-Tiering으로 바꿔도 **절감이 없습니다**(그 객체들은 계층이 이동하지 않습니다).
   *(원리: §2 🧠 — 모니터링 요금은 객체 수에 비례하므로, 계층 이동으로 얻는 절감이 작은 객체일수록 Intelligent-Tiering의 이득이 사라진다.)*

---

## 🧪 자가 점검

> 아래는 학습용 자가 점검입니다. (정식 검증 문항은 별도 문항 파일 참조)

**Q1.** 한 회사가 S3에 로그를 저장합니다. 처음 30일간은 운영팀이 자주 접근하고, 30~90일은 가끔 조회합니다. 90일 이후에는 규정상 1년간 보관 후 삭제해야 합니다. 가장 비용 효율적인 수명주기 설계는?

<details><summary>정답 보기</summary>

**수명주기 정책을 다음과 같이 설계합니다:**

- Day 0: S3 Standard (자주 접근)
- Day 30: S3 Standard-IA 전환 (검색 요금 있지만 저장 요금 절감)
- Day 90: S3 Glacier Flexible Retrieval 전환 (거의 접근 없음)
- Day 365: 만료(Expiration) — 객체 자동 삭제

Standard-IA 최소 보관 기간(30일)은 Day 30 전환과 일치하므로 추가 요금 없습니다. Glacier Flexible Retrieval 최소 보관 기간(90일)도 Day 90~365의 275일을 채우므로 문제없습니다.
</details>

**Q2.** 프라이빗 서브넷의 EC2 인스턴스가 NAT Gateway를 통해 S3에 대량 데이터를 쓰고 있습니다. 비용을 줄이면서 보안도 강화하는 방법은?

<details><summary>정답 보기</summary>

**S3 Gateway Endpoint를 VPC에 추가하고 프라이빗 서브넷 라우트 테이블에 등록합니다.**

Gateway Endpoint는 무료이며, 추가 후 S3 트래픽이 NAT Gateway를 우회해 AWS 내부 네트워크로 직접 전달됩니다. 결과적으로 NAT Gateway의 데이터 처리 요금(GB당 과금)이 발생하지 않고, S3 트래픽이 인터넷에 노출되지 않아 보안도 강화됩니다.
</details>

**Q3.** 100 GiB gp2 EBS 볼륨이 있습니다. 이 볼륨의 기본 IOPS는 얼마이며, gp3로 전환하면 어떤 이점이 있나요?

<details><summary>정답 보기</summary>

**gp2 100 GiB 기본 IOPS = 300 IOPS** (3 IOPS/GiB × 100 GiB).

gp3로 전환하면:
- **기본 IOPS 3,000** — 크기와 무관하게 고정 제공 (10배 향상)
- **기본 처리량 125 MiB/s** — 일관된 성능, 버스트 크레딧 없음
- **GB당 요금 약 20% 절감**

gp3 전환은 Elastic Volumes 기능으로 EC2 인스턴스를 중지하거나 재부팅하지 않고 실시간으로 적용할 수 있습니다.
</details>

**Q4.** 접근 패턴이 불규칙하고 예측하기 어려운 데이터를 S3에 저장합니다. 검색 요금을 피하면서 자동으로 비용을 최적화하는 방법은?

<details><summary>정답 보기</summary>

**S3 Intelligent-Tiering**을 사용합니다. 접근 패턴에 따라 자동으로 Frequent Access → Infrequent Access → Archive Instant Access 계층을 이동하며, **검색 요금이 없습니다.** 오브젝트당 소액의 모니터링 요금이 발생하지만, 128 KB 이상 객체가 많고 접근 패턴이 불규칙할수록 절감 효과가 큽니다. 최소 보관 기간도 없어 언제든 삭제·전환 가능합니다.
</details>

**Q5 (원리).** 왜 gp2 볼륨은 필요한 IOPS를 확보하려고 실제 데이터 저장에 필요한 것보다 더 큰 볼륨을 프로비전해야 하는 상황이 생겼나요?

<details><summary>정답 보기</summary>

gp2는 IOPS가 볼륨 크기(GB)에 연동되어 결정되는 구조였습니다. 소용량 볼륨에서는 크기에 비례한 기본 IOPS가 낮게 책정되므로, 원하는 성능을 얻으려면 실제 필요한 용량보다 더 크게 프로비전해야 했습니다. gp3는 크기와 IOPS를 독립적으로 설정할 수 있어 이 연동 구조가 없어졌고, 데이터 용량과 성능 요구를 각각 필요한 만큼만 프로비전해 비용을 낮출 수 있습니다.
</details>

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. 모든 URL은 WebFetch로 HTTP 200 응답을 확인했습니다. (작성·대조: 2026-06-07 · 고도화 검수: 2026-06-12)

1. S3 스토리지 클래스 비교 — https://docs.aws.amazon.com/AmazonS3/latest/userguide/storage-class-intro.html
2. S3 Storage Lens — 기본 개념과 지표·권장사항 — https://docs.aws.amazon.com/AmazonS3/latest/userguide/storage_lens_basics_metrics_recommendations.html
3. EBS 볼륨 타입 — https://docs.aws.amazon.com/ebs/latest/userguide/ebs-volume-types.html
4. EBS General Purpose SSD (gp2·gp3) — https://docs.aws.amazon.com/ebs/latest/userguide/general-purpose.html
5. EC2 On-Demand 데이터 전송 요금 — https://aws.amazon.com/ec2/pricing/on-demand/
6. 인스턴스 종료 시 데이터 보존(DeleteOnTermination 기본값 표) — https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/preserving-volumes-on-termination.html
7. S3 스토리지 클래스(Intelligent-Tiering 128 KB 미만은 모니터링·자동 계층화 제외) — https://docs.aws.amazon.com/AmazonS3/latest/userguide/storage-class-intro.html
8. S3 분석 — Storage Class Analysis — https://docs.aws.amazon.com/AmazonS3/latest/userguide/analytics-storage-class.html
9. SAA-C03 공식 시험 가이드 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
10. AWS Transfer Family FAQ(프로토콜별 시간당 + 전송량 과금, AS2는 메시지 수, 서버 중지해도 과금 계속·삭제해야 종료) — https://aws.amazon.com/aws-transfer-family/faqs/
11. AWS DataSync FAQ(옮기는 작업은 DataSync, 이후 지속 접근은 File Gateway) — https://aws.amazon.com/datasync/faqs/
12. S3 Transfer Acceleration(추가 데이터 전송 요금이 붙을 수 있음) — https://docs.aws.amazon.com/AmazonS3/latest/userguide/transfer-acceleration.html
13. Requester Pays 버킷(소유자는 항상 저장 비용 부담 · 익명 접근 불가 · `x-amz-request-payer` · IAM 역할 소속 계정 과금) — https://docs.aws.amazon.com/AmazonS3/latest/userguide/RequesterPaysBuckets.html (갭 배치 B9a: 2026-10-21)
14. S3 수명 주기 문제 해결 — **Glacier 전환 객체당 40 KB 오버헤드(8 KB Standard 요율 + 32 KB Glacier 요율)**·최소 기간 3단·전환 요청 비용·작은 객체 집계 권고 — https://docs.aws.amazon.com/AmazonS3/latest/userguide/troubleshoot-lifecycle.html (갭 배치 B9a: 2026-10-21)
15. S3 스토리지 클래스 이해(IA 는 **128 KB 초과에 적합**하고 미만은 **128 KB 로 과금**·30일 전 삭제는 30일분) — https://docs.aws.amazon.com/AmazonS3/latest/userguide/storage-class-intro.html (갭 배치 B9a: 2026-10-21)
16. `GetBucketLifecycleConfiguration` — `x-amz-transition-default-minimum-object-size`(`all_storage_classes_128K` / `varies_by_storage_class` · 커스텀 필터 우선 · 디렉터리 버킷 미지원) — https://docs.aws.amazon.com/AmazonS3/latest/API/API_GetBucketLifecycleConfiguration.html (갭 배치 B9a: 2026-10-21)
17. S3 수명 주기 구성 예시(`NoncurrentVersionExpiration`·`NewerNoncurrentVersions`·`ObjectSizeGreaterThan`/`LessThan` 은 지정값 제외·`<And>` 필요) — https://docs.aws.amazon.com/AmazonS3/latest/userguide/lifecycle-configuration-examples.html (갭 배치 B9a: 2026-10-21)
18. EBS 스냅샷 아카이브 고려사항·제한(최소 **90일** · 복원 **최대 72시간** · **항상 전체 스냅샷** · 일별 증분 아카이브는 더 비쌀 수 있음 · **볼륨 생성·블록 디바이스 매핑 불가** · Recycle Bin 2단계) — https://docs.aws.amazon.com/ebs/latest/userguide/snapshot-archive-considerations.html (갭 배치 B9a: 2026-10-21)
19. DLM `RetentionArchiveTier`(아카이브 보존은 **최소 90일** 보장 · count-based 는 `Count`, age-based 는 `Interval`+`IntervalUnit`) — https://docs.aws.amazon.com/dlm/latest/APIReference/API_RetentionArchiveTier.html (갭 배치 B9a: 2026-10-21)
20. EBS Throughput Optimized HDD·Cold HDD(`sc1` 은 **부팅 볼륨 불가** · 처리량 기준 성능 · 작은 랜덤 I/O 는 SSD 권장 · 99% 시간 90% 처리량) — https://docs.aws.amazon.com/ebs/latest/userguide/hdd-vols.html (갭 배치 B9a: 2026-10-21)
21. FSx for ONTAP 스토리지 용량 관리(SSD 티어 + **용량 풀 티어** · 볼륨은 **씬 프로비저닝** · **티어링 정책은 볼륨 수준**·쿨링 기간) — https://docs.aws.amazon.com/fsx/latest/ONTAPGuide/managing-storage-capacity.html (갭 배치 B9a: 2026-10-21)
22. FSx for ONTAP 동작 방식(**2세대 파일 시스템은 SSD 용량 감소 가능**) — https://docs.aws.amazon.com/fsx/latest/ONTAPGuide/how-it-works-fsx-ontap.html (갭 배치 B9a: 2026-10-21)
23. S3 Storage Lens 지표 선택(무료 **14일** vs 고급 **15개월**·**추가 요금** · CloudWatch 퍼블리싱·접두어 집계·권장 사항 · ⚠️ **Storage Lens 그룹은 무료 티어만**) — https://docs.aws.amazon.com/AmazonS3/latest/userguide/storage_lens_basics_metrics_recommendations.html (갭 배치 B9a: 2026-10-21)

> 📝 **2026-10-21 보강 (갭 배치 B9a — Task 4.1 스토리지 10행)**: ① §1에 **Requester Pays** 를 추가했습니다 — 요청·다운로드는 요청자가 내지만 ⚠️ **저장 비용은 항상 소유자**이고 **익명 접근이 불가**합니다(근거 13번). ② §3에 **작은 객체의 전환 손해**(Glacier 객체당 **40 KB** = 8 KB Standard 요율 + 32 KB Glacier 요율, 집계 권고, 전환 요청 건당 과금)와 **기본 최소 전환 크기**(`all_storage_classes_128K` · 커스텀 필터 우선 · 디렉터리 버킷 미지원), **버전 관리 비용**(`NoncurrentVersionExpiration`·`NewerNoncurrentVersions`)을 추가했습니다(근거 14·15·16·17번). ③ §4에 **HDD 두 종**(⚠️ `sc1` **부팅 불가**·작은 랜덤 I/O 부적합)과 **Snapshots Archive·Recycle Bin**(최소 90일·복원 72시간·**항상 전체 스냅샷**·**일별 증분 아카이브는 더 비쌀 수 있음**·**볼륨 생성 불가**·DLM 최소 90일)을 추가했습니다(근거 18·19·20번). ④ §6에 **FSx ONTAP 두 티어와 볼륨 수준 티어링 정책**(씬 프로비저닝·2세대 SSD 감소)을 추가했습니다(근거 21·22번). ⑤ §7에 **Storage Lens 무료 vs 고급 티어**(14일 vs 15개월·추가 요금·⚠️ **그룹은 무료 티어만**)를 추가했습니다(근거 23번). ⑥ 새 절 **§9 올바른 크기와 오토 스케일링이 필요한 시점**(서비스별 늘리기·줄이기 비대칭 표)과 **§10 스토리지 선택 매트릭스**(요구 → 후보 → 비용 축 순서)를 원리 블록과 함께 넣었습니다.
>
> **같은 배치의 나머지 2행은 `saa-t4-5` 소관**입니다(`G-4.1-11` 비용 관리 도구 세부 · `G-4.1-12` Trusted Advisor 지원 플랜 조건). 미머지 PR 이 같은 파일을 건드려 **순차로 미뤘습니다** — 겹치는 파일이 `saa-t4-5.md` 하나뿐이라 이 10행은 먼저 들어갑니다.
>
> **쓰지 않은 것**: ① **EBS Snapshots Archive 절감률(갭 노트의 "최대 75%")** — 공식 확인에 이르지 못했습니다. ② **FSx OpenZFS·Lustre 의 현행 스토리지 클래스**(Intelligent-Tiering·HDD 여부) — 미확보로 ONTAP 만 적었습니다. ③ **리전별 구체 요율 일체** — `99-gaps` **G-02** 규율대로 **과금 축만** 적었고, 가드가 `GB당 $` 같은 표기를 금지합니다.

> 📝 **2026-10-19 정정**: ① "Terminate해야 볼륨 요금이 멈춘다"를 **`DeleteOnTermination` 기본값**으로 고쳤습니다 — 루트(시작 시)만 기본 삭제, 데이터 볼륨은 콘솔 시작 시 보존·CLI 시작 시 삭제(근거 6번). ② Intelligent-Tiering의 128 KB 미만 객체를 "모니터링 비용이 절감을 초과"에서 **모니터링·자동 계층화 제외(절감이 없음)**로 고쳤습니다(근거 7번). ③ Storage Class Analysis가 **Storage Lens와 별개**인 S3 분석 기능임을 명시했습니다(근거 8번).

> 📝 **2026-10-20 보강**: 공식 가이드 Task 4.1 Knowledge 「하이브리드 스토리지·마이그레이션 서비스 선택」에 대응하는 서술이 없어 **§8**을 신설했습니다(근거 10~12번). DataSync·Transfer Family·Storage Gateway·Transfer Acceleration의 **과금 축 차이**와, **Transfer Family는 중지가 아니라 삭제해야 과금이 멈춘다**는 점을 공식 FAQ로 확인해 적었습니다.
