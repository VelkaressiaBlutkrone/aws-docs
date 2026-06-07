---
examGuideTaskId: saa-t2-5
certCode: SAA-C03
domain: 2
domainName: 복원력을 갖춘 아키텍처 설계
domainWeightPct: 26
title: DR 전략 — RTO·RPO·Pilot Light·Warm Standby·Active-Active
coversTasks:
  - "2.2"
sources:
  - title: 클라우드의 재해 복구 옵션 — AWS 백서 (공식)
    url: https://docs.aws.amazon.com/whitepapers/latest/disaster-recovery-workloads-on-aws/disaster-recovery-options-in-the-cloud.html
  - title: AWS Elastic Disaster Recovery란? (공식)
    url: https://docs.aws.amazon.com/drs/latest/userguide/what-is-drs.html
  - title: 신뢰성 기둥 — AWS Well-Architected Framework (공식)
    url: https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/welcome.html
  - title: SAA-C03 공식 시험 가이드 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
lastVerified: 2026-06-07
---

# DR 전략 — RTO·RPO·Pilot Light·Warm Standby·Active-Active

> **커버하는 공식 Task** — SAA-C03 · 도메인 2 「복원력을 갖춘 아키텍처 설계」(26%) · **Task 2.2 재해 복구(DR) 솔루션 설계** (`saa-t2-5`)
> 이 문서는 위 한 Task에 1:1로 매핑됩니다.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명할 수 있어야 합니다. (공식 시험 가이드 Task 2.2의 Skill 항목 기반)

- [ ] **RTO와 RPO를 구분**하고, 각 지표가 전략 선택에 어떻게 연결되는지 설명할 수 있다
- [ ] **4가지 DR 전략**(Backup & Restore · Pilot Light · Warm Standby · Multi-Site Active-Active)을 비용·복구속도 축에서 순서대로 나열할 수 있다
- [ ] **Pilot Light와 Warm Standby의 차이**를 "무엇이 상시 가동되는가"로 명확히 구분할 수 있다
- [ ] **리전 간 데이터 복제 수단**(S3 CRR, RDS 교차 리전 Read Replica, Aurora Global Database)을 상황별로 선택할 수 있다
- [ ] **Route 53 페일오버**가 자동 트래픽 전환에 어떻게 사용되는지 설명할 수 있다
- [ ] **AWS Elastic Disaster Recovery(DRS)**의 역할과 어떤 DR 전략을 사용하는지 안다

---

## 🎯 왜 중요한가

- 도메인 2(26%)는 SAA 시험 비중 2위입니다. Task 2.2는 "주어진 RTO·RPO 수치 → 가장 적합한 전략"을 고르는 문제 유형이 반복 출제됩니다.
- 4가지 전략은 비용과 복구속도 사이의 트레이드오프로 연결됩니다. 전략의 순서(저비용·느림 → 고비용·빠름)와 핵심 차별점을 외우면 대부분의 문제를 풀 수 있습니다.
- Pilot Light와 Warm Standby는 공식 백서에서도 "구분이 어렵다"고 언급할 만큼 단골 혼동 포인트입니다. "즉시 처리 가능한가"가 핵심 구분선입니다.

---

## 📖 핵심 개념

### 1) RTO와 RPO 정의

| 지표 | 전체 이름 | 의미 | 핵심 질문 |
|---|---|---|---|
| **RTO** | Recovery Time Objective | 재해 발생 후 **얼마나 빨리 서비스를 복구**해야 하는가 | "허용 가능한 다운타임은?" |
| **RPO** | Recovery Point Objective | 재해 발생 시 **얼마만큼의 데이터 손실**을 허용할 수 있는가 | "마지막 백업 이후 잃어도 되는 시간은?" |

> RTO와 RPO가 **0에 가까울수록** 고비용 전략이 필요합니다. 반대로 수 시간의 다운타임·데이터 손실을 허용할 수 있으면 저비용 전략으로 충분합니다.

### 2) 4가지 DR 전략 비교 (★ 단골 출제)

| 전략 | 상시 운영 구성 | RTO | RPO | 상대 비용 | 핵심 특징 |
|---|---|---|---|---|---|
| **Backup & Restore** | 백업 데이터만 보관 | 수 시간 | 마지막 백업 이후 | 최저 | 재해 시 인프라·앱·데이터 모두 새로 배포 |
| **Pilot Light** | 핵심 DB/데이터만 상시 복제, 앱 서버는 꺼둠 | 수십 분 | 낮음(연속 복제 시) | 낮음~중 | 재해 시 꺼진 서버를 기동·확장 |
| **Warm Standby** | 축소판 전체 스택 상시 가동 | 수 분 | 낮음 | 중~높음 | 재해 시 용량만 확장, 즉시 트래픽 처리 가능 |
| **Multi-Site Active-Active** | 여러 리전에서 동시 프로덕션 운영 | 거의 0 | 거의 0 | 최고 | 페일오버 개념 없음, 트래픽이 자동 우회 |

비용 ↔ 복구속도 스펙트럼:

```
저비용 / 느린 복구 ─────────────────────────► 고비용 / 빠른 복구
Backup & Restore → Pilot Light → Warm Standby → Multi-Site Active-Active
```

### 3) Pilot Light vs Warm Standby — 핵심 구분 (★ 혼동 주의)

공식 백서 설명: "Pilot Light는 추가 조치 없이 요청을 처리할 수 없으나, Warm Standby는 즉시(축소 용량으로) 트래픽을 처리할 수 있다."

| 비교 항목 | Pilot Light | Warm Standby |
|---|---|---|
| **상시 가동 범위** | 핵심 데이터(DB)만 | 축소판 전체 스택 (앱+DB) |
| **재해 시 조치** | 서버 기동 + 확장 | 용량 확장만 |
| **즉시 트래픽 처리** | 불가 (서버 기동 필요) | 가능 (축소 용량으로) |
| **RTO** | 더 큼 | 더 작음 |
| **비용** | 더 저렴 | 더 비쌈 |

### 4) 리전 간 데이터 복제 수단

| 대상 | 수단 | 특징 |
|---|---|---|
| S3 | Cross-Region Replication (CRR) | 비동기 연속 복제, 버전 관리 지원 |
| RDS | 교차 리전 Read Replica | 비동기, 페일오버 시 Primary로 승격 필요 |
| Aurora | **Global Database** | 전용 인프라, 보조 리전 복제 지연 **1초 미만**, 장애 시 1분 내 승격 |
| DynamoDB | Global Tables | 멀티 리전 읽기·쓰기, 최종 일관성 |
| 통합 백업 | **AWS Backup** | 다중 서비스·리전·계정, 정책 기반 중앙 관리 |

> Aurora Global Database는 RPO를 가장 낮추고 싶을 때 최선택입니다. "리전 간 1초 미만 복제"가 시험 문구로 자주 등장합니다.

### 5) 페일오버 자동화 — Route 53

Route 53은 Pilot Light / Warm Standby / Active-Active 모두에서 트래픽 전환에 사용됩니다.

- **Failover 라우팅 정책**: 기본(Primary) 엔드포인트에 헬스 체크를 설정하고, 장애 감지 시 보조(Secondary) 엔드포인트로 자동 전환
- **헬스 체크**: 데이터 플레인 작업으로 동작 — 고가용성
- **AWS Global Accelerator**: AnyCast IP 기반, 엣지 네트워크를 통한 더 낮은 지연시간, DNS 캐싱 문제 없음 (Route 53의 대안)
- **Amazon Application Recovery Controller (ARC)**: 수동 페일오버 스크립트 제어용 스위치 역할

### 6) 동기 복제 vs 비동기 복제

| 복제 방식 | RPO | 성능 영향 | 사용 예 |
|---|---|---|---|
| **동기(Synchronous)** | 거의 0 (데이터 손실 없음) | 레이턴시 증가 가능 | 같은 리전 내 Multi-AZ(RDS Multi-AZ) |
| **비동기(Asynchronous)** | 복제 지연만큼의 손실 가능 | 성능 영향 최소 | 교차 리전 복제(CRR, Aurora Global DB 보조 클러스터) |

> RDS Multi-AZ는 같은 리전 내 **동기** 복제(AZ 장애 대응), 교차 리전 Read Replica는 **비동기** 복제(리전 장애 대응).

### 7) AWS Elastic Disaster Recovery (DRS)

> 공식 정의: "저렴한 스토리지와 최소한의 컴퓨팅으로 온프레미스 및 클라우드 기반 애플리케이션의 다운타임과 데이터 손실을 최소화하는 서비스."

- **블록 레벨 복제**: 서버 OS·앱·DB를 통째로 AWS로 지속 복제
- **스테이징 영역**: 저비용 스토리지+최소 컴퓨팅으로 상시 유지 — **Pilot Light 전략** 사용
- **페일오버 시**: 스테이징 리소스로 AWS 내 전체 용량 인스턴스를 수 분 안에 자동 생성
- **대상**: 온프레미스 서버 또는 EC2 기반 앱(RDS 제외). 타 클라우드 → AWS 이전 DR에도 활용 가능
- **복원**: 문제 해결 후 원본 사이트로 페일백(Failback) 지원

---

## ✍️ 시험 포인트

| 시나리오 문구 | 정답 전략 또는 서비스 |
|---|---|
| 비용 최소, 복구 느려도 됨 | **Backup & Restore** |
| 핵심 DB만 켜두고 재해 시 앱 기동 | **Pilot Light** |
| 축소판 전체 스택 상시 가동, 빠른 복구 | **Warm Standby** |
| RTO/RPO 거의 0 | **Multi-Site Active-Active** |
| 리전 간 1초 미만 DB 복제 | **Aurora Global Database** |
| 헬스 체크 기반 자동 트래픽 전환 | **Route 53 Failover** |
| 온프레미스 서버 → AWS DR | **AWS Elastic Disaster Recovery (DRS)** |
| 다중 서비스·리전 백업 중앙 관리 | **AWS Backup** |
| 데이터 손실 허용치 = 0 | RPO=0 → 동기 복제 또는 Active-Active |

---

## ⚠️ 흔한 함정

1. **"RTO/RPO가 엄격하면 무조건 Active-Active."** → Active-Active는 가장 비쌉니다. RTO 수 분 허용 + 비용 제약이 있으면 Warm Standby가 더 적합합니다.

2. **"Pilot Light = Warm Standby."** → 가장 빈번한 혼동입니다. Pilot Light는 앱 서버가 꺼져 있어 재해 시 기동 시간이 필요합니다. Warm Standby는 이미 실행 중이므로 즉시 트래픽을 받을 수 있습니다.

3. **"RDS Multi-AZ와 교차 리전 Read Replica는 같다."** → Multi-AZ는 동일 리전 내 동기 복제(AZ 장애 대응), Read Replica는 비동기 교차 리전 복제(리전 장애 DR). 목적과 복제 방식이 다릅니다.

4. **"RPO=0이면 Backup & Restore로 된다."** → Backup & Restore는 RPO가 마지막 백업 이후(수 시간)입니다. RPO 0 요구에는 동기 복제 또는 Active-Active가 필요합니다.

5. **"AWS DRS는 RDS 관리형 DB에도 사용한다."** → DRS는 서버 기반(EC2) 앱과 DB에만 적용됩니다. RDS 같은 관리형 서비스는 교차 리전 Read Replica·Aurora Global Database를 사용합니다.

6. **"Route 53 페일오버는 즉각적이다."** → DNS TTL만큼의 전파 지연이 있습니다. AWS Global Accelerator는 DNS 캐싱 문제가 없어 더 빠른 전환이 가능합니다.

---

## 🧪 자가 점검

> 아래는 학습용 자가 점검입니다. (정식 검증 문항은 별도 문항 파일 참조)

**Q1.** 전자상거래 회사가 장애 시 최대 4시간의 다운타임과 1시간의 데이터 손실을 허용할 수 있습니다. 비용을 최소화하는 DR 전략은?

<details><summary>정답 보기</summary>

**Backup & Restore**입니다. RTO 4시간·RPO 1시간이면 백업만 보관하다가 재해 시 복원하는 방식으로 충분합니다. 4가지 전략 중 비용이 가장 낮으며, 1시간마다 백업을 수행하면 RPO 1시간 목표도 달성 가능합니다. Pilot Light 이상은 상시 운영 비용이 발생하므로 과잉 투자입니다.
</details>

**Q2.** 금융 서비스 회사가 리전 장애 시 RTO 15분, RPO 1분을 요구합니다. 비용 효율적인 전략과 Aurora DB 복제 수단은?

<details><summary>정답 보기</summary>

전략은 **Warm Standby**가 적합합니다. RTO 15분은 Pilot Light(서버 기동 포함)로는 빠듯하고, Active-Active는 불필요하게 비쌉니다. Warm Standby는 축소판 스택이 상시 가동 중이므로 빠른 확장으로 15분 이내 복구가 가능합니다. DB는 **Aurora Global Database**를 사용합니다. 전용 인프라로 보조 리전 복제 지연이 1초 미만이므로 RPO 1분을 충족하며, 장애 시 1분 내 보조 리전을 Primary로 승격할 수 있습니다.
</details>

**Q3.** 회사가 온프레미스 서버에서 실행 중인 애플리케이션의 DR을 AWS에 구성하려 합니다. 서버 단위로 지속 복제하고 수 분 내 AWS에서 기동할 수 있는 서비스는?

<details><summary>정답 보기</summary>

**AWS Elastic Disaster Recovery (DRS)**입니다. DRS는 온프레미스 서버를 블록 레벨로 지속 복제하여 AWS의 스테이징 영역에 유지합니다. 페일오버 이벤트 시 스테이징 리소스를 사용해 AWS에서 수 분 안에 전체 용량 인스턴스를 자동 생성합니다. Pilot Light 전략을 기반으로 하되, 수동 인프라 구성 없이 관리형으로 제공합니다.
</details>

**Q4.** Pilot Light와 Warm Standby 중 "재해 발생 직후 즉시 트래픽을 받을 수 있는" 전략은 무엇이며, 그 이유는?

<details><summary>정답 보기</summary>

**Warm Standby**입니다. Warm Standby는 축소판 전체 스택(앱+DB)이 상시 실행 중이므로 재해 발생 직후 축소된 용량으로 즉시 트래픽을 처리할 수 있습니다. 이후 Auto Scaling 등으로 용량을 확장합니다. Pilot Light는 핵심 DB만 복제되고 앱 서버는 꺼져 있어 재해 시 서버를 기동·배포하는 추가 시간이 필요하므로 즉시 트래픽 처리가 불가합니다.
</details>

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. (작성·대조: 2026-06-07)

1. 클라우드의 재해 복구 옵션 — AWS 백서 — https://docs.aws.amazon.com/whitepapers/latest/disaster-recovery-workloads-on-aws/disaster-recovery-options-in-the-cloud.html
2. AWS Elastic Disaster Recovery란? — https://docs.aws.amazon.com/drs/latest/userguide/what-is-drs.html
3. 신뢰성 기둥 — AWS Well-Architected Framework — https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/welcome.html
4. SAA-C03 공식 시험 가이드 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
