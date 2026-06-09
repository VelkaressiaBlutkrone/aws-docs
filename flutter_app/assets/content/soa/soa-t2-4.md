---
examGuideTaskId: soa-t2-4
certCode: SOA-C03
domain: 2
domainName: 신뢰성 및 비즈니스 연속성
domainWeightPct: 22
title: DR·데이터 복원력 — RTO/RPO·S3 복제·리전 장애 대비
coversTasks:
  - "2.3"
sources:
  - title: 클라우드의 재해 복구 옵션 — AWS 백서 (공식)
    url: https://docs.aws.amazon.com/whitepapers/latest/disaster-recovery-workloads-on-aws/disaster-recovery-options-in-the-cloud.html
  - title: S3 객체 복제 (CRR·SRR) (공식)
    url: https://docs.aws.amazon.com/AmazonS3/latest/userguide/replication.html
  - title: RDS 교차 리전 읽기 전용 복제본 (공식)
    url: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_ReadRepl.XRgn.html
  - title: RDS 스냅샷 복사 (교차 리전) (공식)
    url: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_CopySnapshot.html
  - title: 신뢰성 기둥 — AWS Well-Architected Framework (공식)
    url: https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/welcome.html
lastVerified: 2026-06-09
---

# DR·데이터 복원력 — RTO/RPO·S3 복제·리전 장애 대비

> **커버하는 공식 Task** — SOA-C03 · 도메인 2 「신뢰성 및 비즈니스 연속성」(22%) · **Task 2.3 백업 및 복원 전략 구현** (`soa-t2-4`)
> 이 문서는 RTO/RPO 기반 DR 전략 선택과 리전 단위 데이터 복원력(S3 복제·RDS 교차 리전)에 집중합니다. 백업 메커니즘 자체는 `soa-t2-3`에서 다룹니다.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명하고, 전략을 역산해 구성할 수 있어야 합니다.

- [ ] **RTO/RPO 정의** — 두 지표의 의미를 구분하고 전략 선택에 어떻게 연결되는지 설명할 수 있다
- [ ] **DR 전략 4종** — Backup & Restore·Pilot Light·Warm Standby·Multi-Site를 비용·복구시간 축에 나열할 수 있다
- [ ] **Pilot Light vs Warm Standby** — "무엇이 상시 가동되는가"로 둘을 구분할 수 있다
- [ ] **S3 CRR vs SRR** — 교차 리전과 동일 리전 복제의 용도와 공통 전제(버전 관리)를 안다
- [ ] **RDS 교차 리전** — 읽기 전용 복제본 승격과 스냅샷 복사로 리전 장애에 대비할 수 있다
- [ ] **리전 장애 대비** — 멀티 리전 데이터 복제 수단을 상황별로 선택할 수 있다
- [ ] **운영 절차** — RTO/RPO 목표에서 전략을 역산해 구성·검증할 수 있다

---

## 🎯 왜 중요한가

- 도메인 2(22%) Task 2.3에서 DR은 "주어진 RTO·RPO 수치 → 가장 적합·비용효율적인 전략"을 고르는 유형으로 반복 출제됩니다.
- 4가지 전략은 **비용 ↔ 복구속도 트레이드오프**로 연결됩니다. 순서(저비용·느림 → 고비용·빠름)와 핵심 구분선을 외우면 대부분 풀립니다.
- SOA는 **운영자 관점의 역산**을 요구합니다. "RTO 15분·RPO 1분이면 무엇을 상시 가동하고 무엇을 복제해야 하는가?"를 데이터 복제 수단까지 내려가 결정해야 합니다.

---

## 📖 핵심 개념

### 1) RTO와 RPO 정의

| 지표 | 전체 이름 | 의미 | 핵심 질문 |
|---|---|---|---|
| **RTO** | Recovery Time Objective | 재해 후 **얼마나 빨리 복구**해야 하는가 | "허용 다운타임은?" |
| **RPO** | Recovery Point Objective | 재해 시 **얼마만큼의 데이터 손실**을 허용하는가 | "마지막 복구 지점 이후 잃어도 되는 시간은?" |

> RTO·RPO가 **0에 가까울수록** 고비용 전략이 필요합니다. 수 시간의 다운타임·손실을 허용하면 저비용 전략으로 충분합니다. **RPO는 복제 방식**(동기/비동기·복제 주기)이, **RTO는 상시 가동 범위**가 좌우합니다.

### 2) DR 전략 4종 (★ 단골 출제)

| 전략 | 상시 운영 구성 | RTO | RPO | 상대 비용 | 핵심 특징 |
|---|---|---|---|---|---|
| **Backup & Restore** | 백업 데이터만 보관 | 수 시간 | 마지막 백업 이후 | 최저 | 재해 시 인프라·앱·데이터 모두 새로 배포 |
| **Pilot Light** | 핵심 DB/데이터만 상시 복제, 앱 서버는 꺼둠 | 수십 분 | 낮음(연속 복제 시) | 낮음~중 | 재해 시 꺼진 서버를 기동·확장 |
| **Warm Standby** | 축소판 전체 스택 상시 가동 | 수 분 | 낮음 | 중~높음 | 재해 시 용량만 확장, 즉시 트래픽 처리 가능 |
| **Multi-Site Active-Active** | 여러 리전에서 동시 프로덕션 운영 | 거의 0 | 거의 0 | 최고 | 페일오버 개념 없음, 트래픽 자동 우회 |

```
저비용 / 느린 복구 ─────────────────────────► 고비용 / 빠른 복구
Backup & Restore → Pilot Light → Warm Standby → Multi-Site Active-Active
```

### 3) Pilot Light vs Warm Standby — 핵심 구분 (★ 혼동 주의)

> 공식 백서: **"Pilot Light는 추가 조치 없이 요청을 처리할 수 없으나, Warm Standby는 (축소 용량으로) 즉시 트래픽을 처리할 수 있다."**

| 비교 | Pilot Light | Warm Standby |
|---|---|---|
| **상시 가동 범위** | 핵심 데이터(DB)만 | 축소판 전체 스택(앱+DB) |
| **재해 시 조치** | 서버 기동 + 확장 | 용량 확장만 |
| **즉시 트래픽 처리** | 불가(서버 기동 필요) | 가능(축소 용량으로) |
| **RTO** | 더 큼 | 더 작음 |
| **비용** | 더 저렴 | 더 비쌈 |

### 4) S3 복제 — CRR vs SRR

> 공식: S3 복제는 버킷 간 객체를 **비동기로 자동 복제**하며, **소스·대상 버킷 모두 버전 관리가 활성화**되어 있어야 합니다.

| 유형 | 대상 | 용도 |
|---|---|---|
| **CRR**(Cross-Region Replication) | **다른 리전** 버킷 | 리전 장애 대비(DR), 지리적으로 가까운 사본, 규정상 데이터 격리 |
| **SRR**(Same-Region Replication) | **동일 리전** 다른 버킷 | 로그 집계, 운영·테스트 계정 간 복제, 동일 리전 내 규정 준수 |

| 특성 | 내용 |
|---|---|
| **전제 조건** | **양쪽 버킷 버전 관리 활성화**(필수) |
| **복제 방식** | 비동기. 활성화 이후 새로 추가/변경된 객체에 적용(기존 객체는 **배치 복제** 필요) |
| **선택 복제** | 접두사·태그로 일부만 복제 가능 |
| **교차 계정** | 다른 계정 버킷으로 복제 가능(소유권 재정의) |

> **핵심**: CRR이든 SRR이든 **버전 관리가 전제**입니다. RPO를 낮추려면 복제로 거의 실시간 사본을 다른 리전에 유지합니다.

### 5) RDS 교차 리전 복원력

| 수단 | 특성 | 용도 |
|---|---|---|
| **교차 리전 읽기 전용 복제본** | 다른 리전에 **비동기** 복제본 유지. 재해 시 **Primary로 승격**(수동) | 낮은 RPO 목표(연속 복제) + 리전 DR. Pilot Light/Warm Standby의 DB 계층 |
| **교차 리전 스냅샷 복사** | 스냅샷을 다른 리전으로 복사. 재해 시 그 스냅샷으로 새 인스턴스 복원 | Backup & Restore 수준 DR(RPO=마지막 스냅샷 이후) |
| **Aurora Global Database** | 전용 인프라, 보조 리전 복제 지연 보통 1초 미만, 빠른 승격 | 가장 낮은 RPO가 필요한 Aurora 워크로드 |

> 교차 리전 읽기 복제본은 비동기라 복제 지연만큼 데이터 손실 가능(RPO>0). 스냅샷 복사는 더 저렴하지만 RPO가 큽니다(마지막 스냅샷 시점). RPO 목표가 전략을 가릅니다.

### 6) 리전 장애 대비 — 데이터 복제 수단 정리

| 데이터 | 멀티 리전 수단 | 복제 |
|---|---|---|
| **S3 객체** | CRR | 비동기(버전 관리 전제) |
| **RDS(비-Aurora)** | 교차 리전 읽기 복제본 / 스냅샷 복사 | 비동기 / 스냅샷 시점 |
| **Aurora** | Global Database | 비동기(1초 미만 지연) |
| **DynamoDB** | Global Tables | 멀티 리전 활성·활성, 최종 일관성 |
| **통합 백업** | AWS Backup 교차 리전 복사 | 정책 기반 |

> 트래픽 전환은 **Route 53 장애 조치 라우팅**(헬스 체크 기반)으로 자동화합니다(상세는 `soa-t2-2`). DNS TTL 전파 지연을 줄이려면 짧은 TTL이나 Global Accelerator를 고려합니다.

### 7) 운영 절차 — RTO/RPO에서 전략 역산

1. **목표 수치 확정**: 비즈니스가 허용하는 RTO(다운타임)·RPO(데이터 손실)를 명시.
2. **RPO → 복제 수단 결정**: RPO 큼 → 정기 백업/스냅샷 복사. RPO 작음 → 연속 복제(CRR·교차 리전 읽기 복제본·Aurora Global DB).
3. **RTO → 상시 가동 범위 결정**: RTO 큼 → Backup & Restore. 수십 분 → Pilot Light. 수 분 → Warm Standby. 거의 0 → Multi-Site.
4. **트래픽 전환 구성**: Route 53 헬스 체크 + 장애 조치 라우팅.
5. **검증(★)**: 정기적으로 **DR 훈련(game day)**을 실시해 실제 복구 시간이 RTO를, 데이터 손실이 RPO를 충족하는지 측정.

---

## ✍️ 시험 포인트

| 시나리오 문구 | 정답 |
|---|---|
| 비용 최소, 복구 느려도 됨 | **Backup & Restore** |
| 핵심 DB만 켜두고 재해 시 앱 기동 | **Pilot Light** |
| 축소판 스택 상시 가동, 빠른 복구 | **Warm Standby** |
| RTO/RPO 거의 0 | **Multi-Site Active-Active** |
| 리전 간 S3 객체 복제 | **CRR**(버전 관리 전제) |
| 같은 리전 버킷 간 복제(로그 집계 등) | **SRR**(버전 관리 전제) |
| 리전 간 1초 미만 DB 복제 | **Aurora Global Database** |
| 헬스 체크 기반 자동 트래픽 전환 | **Route 53 장애 조치** |
| 데이터 손실 허용 = 0 | RPO=0 → 동기 복제 또는 Active-Active |

- **RTO=상시 가동 범위, RPO=복제 방식**으로 매핑해 역산.
- **CRR/SRR 모두 버전 관리 활성화가 전제**.
- **교차 리전 읽기 복제본은 비동기·수동 승격**, 스냅샷 복사는 RPO가 큼.

---

## ⚠️ 흔한 함정

1. **"RTO/RPO가 엄격하면 무조건 Active-Active."** → Active-Active가 가장 비쌉니다. RTO 수 분 허용 + 비용 제약이면 Warm Standby가 더 적합합니다.

2. **"Pilot Light = Warm Standby."** → 가장 빈번한 혼동입니다. Pilot Light는 앱 서버가 꺼져 있어 기동 시간이 필요하고, Warm Standby는 이미 실행 중이라 즉시 트래픽을 받습니다.

3. **"S3 복제는 버전 관리 없이도 된다."** → CRR·SRR 모두 **소스·대상 버킷 버전 관리가 필수**입니다.

4. **"S3 복제를 켜면 기존 객체도 자동 복제된다."** → 복제는 활성화 **이후 추가/변경된 객체**에 적용됩니다. 기존 객체는 **S3 배치 복제(Batch Replication)**로 따로 복제해야 합니다.

5. **"RPO=0이면 Backup & Restore로 된다."** → Backup & Restore는 RPO가 마지막 백업 이후(수 시간)입니다. RPO 0에는 동기 복제 또는 Active-Active가 필요합니다.

6. **"교차 리전 읽기 복제본은 자동으로 장애 조치된다."** → 비동기 복제본은 **수동 승격(promote)**이 필요합니다. 자동 전환이 아닙니다.

7. **"Route 53 장애 조치는 즉각적이다."** → DNS TTL만큼 전파 지연이 있습니다. 짧은 TTL이나 Global Accelerator로 완화합니다.

---

## 🧪 자가 점검

> 아래는 학습용 자가 점검입니다. (정식 검증 문항은 별도 문항 파일 참조)

**Q1.** 회사가 리전 장애 시 최대 4시간 다운타임·1시간 데이터 손실을 허용합니다. 비용을 최소화하는 DR 전략은?

<details><summary>정답 보기</summary>

**Backup & Restore**입니다. RTO 4시간·RPO 1시간이면 백업(예: 1시간 주기 스냅샷의 교차 리전 복사)을 보관하다가 재해 시 다른 리전에 인프라·앱·데이터를 새로 배포하는 방식으로 충분합니다. 4가지 전략 중 비용이 가장 낮습니다. Pilot Light 이상은 상시 운영 비용이 들어 과잉 투자입니다.
</details>

**Q2.** 금융 서비스가 리전 장애 시 RTO 15분·RPO 1분을 요구합니다. 비용 효율적 전략과 DB 복제 수단은?

<details><summary>정답 보기</summary>

전략은 **Warm Standby**가 적합합니다. RTO 15분은 Pilot Light(서버 기동 포함)로는 빠듯하고 Active-Active는 불필요하게 비쌉니다. Warm Standby는 축소판 스택이 상시 가동 중이라 빠른 확장으로 15분 내 복구가 가능합니다. DB는 RPO 1분을 위해 **교차 리전 읽기 전용 복제본**(연속 비동기 복제, 재해 시 승격) 또는 Aurora라면 **Aurora Global Database**(1초 미만 복제)를 사용합니다.
</details>

**Q3.** S3 버킷 데이터를 다른 리전에 거의 실시간으로 복제해 리전 장애에 대비하려 합니다. 무엇을 켜야 하며, 기존 객체도 복제되나요?

<details><summary>정답 보기</summary>

**교차 리전 복제(CRR)**를 구성합니다. 이때 **소스·대상 버킷 모두 버전 관리를 활성화**해야 합니다(전제 조건). CRR은 비동기로 동작하며, 활성화 **이후 추가/변경된 객체**만 복제합니다. **이미 존재하던 객체**는 자동 복제되지 않으므로, **S3 배치 복제(Batch Replication)**를 별도로 실행해 기존 객체를 복제해야 합니다.
</details>

**Q4.** Pilot Light와 Warm Standby 중 "재해 직후 즉시 트래픽을 받을 수 있는" 전략은 무엇이며 이유는?

<details><summary>정답 보기</summary>

**Warm Standby**입니다. 축소판 전체 스택(앱+DB)이 상시 실행 중이라 재해 직후 축소 용량으로 즉시 트래픽을 처리하고 이후 Auto Scaling 등으로 확장합니다. Pilot Light는 핵심 DB만 복제되고 앱 서버는 꺼져 있어, 재해 시 서버를 기동·배포하는 추가 시간이 필요하므로 즉시 트래픽 처리가 불가합니다.
</details>

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 AWS 자료를 기준으로 작성했습니다. (작성·대조: 2026-06-09)

1. 클라우드의 재해 복구 옵션 — AWS 백서 — https://docs.aws.amazon.com/whitepapers/latest/disaster-recovery-workloads-on-aws/disaster-recovery-options-in-the-cloud.html
2. S3 객체 복제(CRR·SRR) — https://docs.aws.amazon.com/AmazonS3/latest/userguide/replication.html
3. RDS 교차 리전 읽기 전용 복제본 — https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_ReadRepl.XRgn.html
4. RDS 스냅샷 복사(교차 리전) — https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_CopySnapshot.html
5. 신뢰성 기둥 — AWS Well-Architected Framework — https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/welcome.html
</content>
