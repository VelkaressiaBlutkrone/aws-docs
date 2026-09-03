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
  - title: SAA-C03 공식 시험 가이드 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
lastVerified: 2026-06-12
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

> 128 KB 미만 객체는 모니터링 대상이 아니어서 항상 Frequent Access에 머뭅니다. 소용량 객체가 많은 버킷에서는 Intelligent-Tiering의 모니터링 비용이 절감액을 초과할 수 있습니다.

> 🧠 원리: 왜 S3 Intelligent-Tiering은 오브젝트당 모니터링 요금을 부과할까요?
> 계층 자동 이동은 각 객체의 접근 이력을 추적해야 가능하며, 이 추적 자체에 저장·연산 비용이 발생합니다.
> 모니터링 요금을 오브젝트 수에 비례해 부과하면, 소용량 객체가 수백만 개인 버킷은 추적 비용이 절감액을 초과하는 구조이므로 사용자가 직접 트레이드오프를 판단할 수 있습니다.
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
- 전환 자체(Transition)에는 GB 검색 요금이 없지만, 전환 PUT 요청 요금은 발생합니다.

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
- **Storage Class Analysis** — 버킷별로 Standard vs Standard-IA 최적 전환 시점을 분석해 수명주기 정책 생성에 활용합니다.

> 🧠 원리: 왜 스토리지 비용 최적화를 위해 별도 관측 도구가 필요할까요?
> 수십~수백 개 버킷에서 각각 접근 패턴, 수명주기 적용 여부, 미완성 업로드 존재 여부를 수동으로 점검하는 것은 현실적으로 어렵습니다.
> Storage Lens는 조직 전체 버킷의 활동 지표를 일별로 집계해 최적화 기회가 있는 버킷을 자동으로 식별하므로, 비용 낭비 지점을 빠르게 좁힐 수 있습니다.
> 정책 적용 전에 실제 데이터로 현황을 파악해야 불필요한 전환 비용 없이 효과가 큰 버킷부터 우선순위를 정할 수 있습니다.

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

2. **"EC2를 Stop하면 EBS 요금도 안 낸다."** → EBS는 인스턴스가 중지 상태여도 프로비전된 용량에 대해 계속 과금됩니다. 완전히 삭제(Terminate)해야 볼륨 요금이 멈춥니다.
   *(원리: §4 본문 — EBS는 인스턴스 중지 상태에서도 프로비전된 볼륨 용량에 대해 계속 과금되므로, 필요 없는 볼륨은 삭제해야 한다.)*

3. **"수명주기 전환은 언제 해도 최소 보관 기간 요금이 없다."** → Standard-IA는 30일, Glacier 계열은 90일(Deep Archive 180일) 미만 보관 시 해당 기간 요금이 청구됩니다. 30일 이전에 Standard-IA로 전환하면 절감이 아닙니다.
   *(원리: §3 🧠 — 최소 보관 기간 충족 전 삭제·전환이 일어나면 잔여 기간에 해당하는 저장 요금이 청구된다.)*

4. **"같은 리전이면 AZ 간 전송도 무료다."** → 같은 리전이라도 **AZ를 넘는 전송은 과금**됩니다. 고가용성 아키텍처에서 AZ 간 트래픽이 많으면 예상치 못한 비용이 발생합니다. 같은 AZ 내 프라이빗 IP 통신이 무료입니다.
   *(원리: §5 🧠 — AZ 간 전송은 AWS 리전 내부 네트워크를 경유하며 해당 구간 비용이 청구된다.)*

5. **"NAT Gateway는 보안 도구라 비용 최적화와 무관하다."** → NAT Gateway는 **데이터 처리 요금(GB당)** 이 별도로 청구됩니다. S3·DynamoDB는 Gateway Endpoint로 우회하면 NAT 처리 비용이 발생하지 않습니다.
   *(원리: §5 본문 — S3 Gateway Endpoint를 사용하면 트래픽이 NAT Gateway를 경유하지 않아 데이터 처리 요금이 발생하지 않는다.)*

6. **"gp3는 gp2보다 성능이 낮아 저렴한 것이다."** → gp3는 기본 IOPS(3,000)가 크기와 무관하게 제공되며 버스트 없이 일관된 성능을 냅니다. gp2는 소용량일수록 IOPS가 낮고 버스트 크레딧에 의존합니다. gp3가 성능과 비용 모두 유리한 경우가 대부분입니다.
   *(원리: §4 🧠 — gp2는 크기-IOPS 연동 구조 때문에 소용량에서 성능 확보를 위해 과잉 프로비전이 필요했으나, gp3는 이 연동을 분리했다.)*

7. **"Intelligent-Tiering은 모든 객체에 무조건 이득이다."** → 128 KB 미만 객체는 모니터링 대상이 아니며 항상 Frequent Access에 머뭅니다. 소용량 객체가 수백만 개 있는 버킷은 오브젝트당 모니터링 요금이 절감액을 초과할 수 있습니다.
   *(원리: §2 🧠 — 모니터링 요금은 객체 수에 비례하므로, 절감액보다 추적 비용이 커지는 임계점이 존재한다.)*

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
6. SAA-C03 공식 시험 가이드 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
