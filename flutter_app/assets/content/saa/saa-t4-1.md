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
lastVerified: 2026-06-07
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

## 📖 핵심 개념

### 1) S3 비용 구조 — 세 가지 요금 축

S3 비용은 단순히 "저장 요금"만이 아닙니다. 세 축을 같이 봐야 합니다.

| 비용 축 | 설명 | 클래스별 차이 |
|---|---|---|
| **스토리지 요금** | 저장된 GB·월 기준 | Standard > Standard-IA > One Zone-IA > Glacier 순으로 낮아짐 |
| **요청 요금** | PUT·GET·LIST 등 API 호출 수 | Glacier는 요청당 요금이 더 높음 |
| **검색(Retrieval) 요금** | 객체를 꺼낼 때 GB당 추가 과금 | Standard·Intelligent-Tiering = 없음. IA·Glacier 클래스 = 있음 |

> 핵심 트레이드오프: 저장 요금이 낮은 클래스일수록 검색 요금이 높습니다. 자주 꺼내는 데이터를 Glacier에 두면 도리어 비쌀 수 있습니다.

### 2) S3 스토리지 클래스 — 비용 최적화 관점

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

### 3) S3 수명주기 정책 — 자동 비용 절감

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

### 4) EBS 비용 최적화

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

### 5) 데이터 전송 비용

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

### 6) EFS·FSx 비용 계층

| 서비스 | 스토리지 계층 | 비용 특성 |
|---|---|---|
| **Amazon EFS** | Standard | 기본, 자주 접근하는 파일 |
| **Amazon EFS** | Infrequent Access (IA) | Standard보다 저렴, 접근 시 GB당 검색 요금 |
| **Amazon EFS** | Archive | 거의 접근 안 하는 파일, 최저가 |
| **Amazon EFS Intelligent-Tiering** | — | 접근 패턴에 따라 Standard↔IA↔Archive 자동 전환 |
| **Amazon FSx for Windows** | SSD / HDD | HDD 계층이 저렴 — 처리량 중심 워크로드에 HDD 선택 |
| **Amazon FSx for Lustre** | Persistent / Scratch | Scratch는 임시·저렴, Persistent는 복제·내구성 제공 |

> EFS IA/Archive는 S3 IA와 유사한 구조입니다. 자주 접근하지 않는 파일을 EFS Intelligent-Tiering으로 설정하면 자동으로 저렴한 계층으로 이동합니다.

### 7) S3 Storage Lens — 조직 전체 비용 탐지 도구

S3 Storage Lens는 조직 전체 버킷의 스토리지 사용 현황과 활동 지표를 **일별로 집계해 대시보드와 권장사항**을 제공합니다.

비용 최적화 관련 주요 기능:

- **미완성 멀티파트 업로드 탐지** — 7일 이상 된 미완성 멀티파트 업로드가 있는 버킷을 식별해 수명주기 규칙 추가를 권장합니다.
- **수명주기 규칙 미적용 버킷 탐지** — Lifecycle 규칙이 없는 버킷을 찾아내 자동 전환·만료 적용 기회를 제안합니다.
- **비접근 객체 분포** — 오랫동안 접근하지 않은 객체 비율을 보여줘 클래스 전환 타깃을 찾는 데 활용합니다.
- **Storage Class Analysis** — 버킷별로 Standard vs Standard-IA 최적 전환 시점을 분석해 수명주기 정책 생성에 활용합니다.

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

## ⚠️ 흔한 함정

1. **"Glacier는 무조건 저렴하다."** → 검색 요금이 GB당 과금되고 최소 보관 기간(90~180일)이 있습니다. 자주 꺼내는 데이터를 Glacier에 두면 Standard보다 비쌀 수 있습니다.

2. **"EC2를 Stop하면 EBS 요금도 안 낸다."** → EBS는 인스턴스가 중지 상태여도 프로비전된 용량에 대해 계속 과금됩니다. 완전히 삭제(Terminate)해야 볼륨 요금이 멈춥니다.

3. **"수명주기 전환은 언제 해도 최소 보관 기간 요금이 없다."** → Standard-IA는 30일, Glacier 계열은 90일(Deep Archive 180일) 미만 보관 시 해당 기간 요금이 청구됩니다. 30일 이전에 Standard-IA로 전환하면 절감이 아닙니다.

4. **"같은 리전이면 AZ 간 전송도 무료다."** → 같은 리전이라도 **AZ를 넘는 전송은 과금**됩니다. 고가용성 아키텍처에서 AZ 간 트래픽이 많으면 예상치 못한 비용이 발생합니다. 같은 AZ 내 프라이빗 IP 통신이 무료입니다.

5. **"NAT Gateway는 보안 도구라 비용 최적화와 무관하다."** → NAT Gateway는 **데이터 처리 요금(GB당)** 이 별도로 청구됩니다. S3·DynamoDB는 Gateway Endpoint로 우회하면 NAT 처리 비용이 발생하지 않습니다.

6. **"gp3는 gp2보다 성능이 낮아 저렴한 것이다."** → gp3는 기본 IOPS(3,000)가 크기와 무관하게 제공되며 버스트 없이 일관된 성능을 냅니다. gp2는 소용량일수록 IOPS가 낮고 버스트 크레딧에 의존합니다. gp3가 성능과 비용 모두 유리한 경우가 대부분입니다.

7. **"Intelligent-Tiering은 모든 객체에 무조건 이득이다."** → 128 KB 미만 객체는 모니터링 대상이 아니며 항상 Frequent Access에 머뭅니다. 소용량 객체가 수백만 개 있는 버킷은 오브젝트당 모니터링 요금이 절감액을 초과할 수 있습니다.

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

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. 모든 URL은 WebFetch로 HTTP 200 응답을 확인했습니다. (작성·대조: 2026-06-07)

1. S3 스토리지 클래스 비교 — https://docs.aws.amazon.com/AmazonS3/latest/userguide/storage-class-intro.html
2. S3 Storage Lens — 기본 개념과 지표·권장사항 — https://docs.aws.amazon.com/AmazonS3/latest/userguide/storage_lens_basics_metrics_recommendations.html
3. EBS 볼륨 타입 — https://docs.aws.amazon.com/ebs/latest/userguide/ebs-volume-types.html
4. EBS General Purpose SSD (gp2·gp3) — https://docs.aws.amazon.com/ebs/latest/userguide/general-purpose.html
5. EC2 On-Demand 데이터 전송 요금 — https://aws.amazon.com/ec2/pricing/on-demand/
6. SAA-C03 공식 시험 가이드 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
