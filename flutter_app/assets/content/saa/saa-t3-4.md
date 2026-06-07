---
examGuideTaskId: saa-t3-4
certCode: SAA-C03
domain: 3
domainName: 고성능 아키텍처 설계
domainWeightPct: 24
title: 컨테이너·서버리스·배치 컴퓨팅 선택
coversTasks:
  - "3.2"
sources:
  - title: Amazon ECS — What is Amazon Elastic Container Service (공식)
    url: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html
  - title: AWS Fargate — Architect for AWS Fargate for Amazon ECS (공식)
    url: https://docs.aws.amazon.com/AmazonECS/latest/userguide/what-is-fargate.html
  - title: Amazon EKS — What is Amazon EKS (공식)
    url: https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html
  - title: AWS Batch — What is AWS Batch (공식)
    url: https://docs.aws.amazon.com/batch/latest/userguide/what-is-batch.html
  - title: SAA-C03 공식 시험 가이드 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
lastVerified: 2026-06-07
---

# 컨테이너·서버리스·배치 컴퓨팅 선택

> **커버하는 공식 Task** — SAA-C03 · 도메인 3 「고성능 아키텍처 설계」(24%) · **Task 3.2 고성능 컴퓨팅 솔루션 선택** (`saa-t3-4`)
> 이 문서는 워크로드 성격에 따른 컴퓨팅 서비스 선택(EC2 · 컨테이너 · 서버리스 · 배치 · HPC)을 다룹니다. saa-t2-2(서버리스 패턴)와는 달리 "고성능·워크로드 적합성" 관점의 결정 트리에 집중합니다.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명할 수 있어야 합니다. (공식 시험 가이드 Task 3.2의 Skill 항목 기반)

- [ ] **EC2 vs 컨테이너 vs Lambda vs Batch** — 상태 유지·실행 시간·확장 패턴 기준으로 선택 기준을 설명할 수 있다
- [ ] **ECS vs EKS** — AWS 네이티브 오케스트레이터와 관리형 Kubernetes의 선택 기준을 안다
- [ ] **EC2 시작 유형 vs Fargate** — 노드 관리 책임의 분기를 그릴 수 있다
- [ ] **Lambda 성능 튜닝** — 메모리-CPU 비례 관계, 동시성 제한, Provisioned Concurrency의 역할을 안다
- [ ] **AWS Batch 구성요소** — Job, Job Queue, Compute Environment 3계층을 설명할 수 있다
- [ ] **HPC 구성** — EFA, 클러스터 배치 그룹, FSx for Lustre의 조합 이유를 설명할 수 있다
- [ ] **결정 트리 적용** — 시험 시나리오에서 "least operational overhead", "HPC", "배치" 키워드를 컴퓨팅 선택으로 변환할 수 있다

---

## 🎯 왜 중요한가

- 도메인 3(24%)은 SAA 시험 비중 2위입니다. Task 3.2는 컴퓨팅 서비스 선택을 직접 묻는 시나리오로 출제됩니다.
- 시험은 "이 워크로드에 가장 적합한 컴퓨팅 옵션은?"이라는 형태로, **운영 부담·실행 시간·확장 패턴·비용** 네 축을 동시에 평가합니다.
- CLF·saa-t2-2에서 서버리스 개념을 봤다면, 여기서는 **고성능·배치·컨테이너 오케스트레이션**까지 포괄하는 전체 컴퓨팅 선택 결정 트리를 익힙니다. "least operational overhead"가 나오면 서버리스 방향, "HPC/초저지연"이 나오면 클러스터 배치 그룹+EFA 방향이 정답입니다.

---

## 📖 핵심 개념

### 1) 컴퓨팅 선택 결정 트리

워크로드 선택의 첫 질문은 세 가지입니다: **상태를 유지하는가(Stateful)**, **얼마나 오래 실행되는가(Duration)**, **어떤 확장 패턴인가(Scale pattern)**.

```
워크로드
├── 서버·OS 직접 제어 필요?  → EC2
│
├── 컨테이너 기반?
│   ├── 쿠버네티스 표준 필요?  → EKS
│   ├── AWS 네이티브, 낮은 러닝커브?  → ECS
│   └── 노드 관리 없이 컨테이너?  → Fargate (ECS or EKS 위에서)
│
├── 이벤트 기반, 짧은 실행(<15분), 스테이트리스?  → Lambda
│
├── 대량 배치 작업, 완료 후 종료?  → AWS Batch
│
└── 노드 간 초저지연, 과학연산·ML?  → EC2 + 클러스터 배치 그룹 + EFA
```

> **운영 부담 스펙트럼**: EC2(최대 제어·최대 책임) → ECS EC2 시작 유형 → EKS → Fargate → Lambda(최소 제어·최소 책임). "least operational overhead"는 항상 스펙트럼의 오른쪽(서버리스)을 가리킵니다.

### 2) 컴퓨팅 옵션 비교표 (★ 시험 핵심)

| 옵션 | 상태 유지 | 최대 실행 시간 | 확장 방식 | 운영 부담 | 대표 시나리오 |
|---|---|---|---|---|---|
| **EC2** | O (Stateful 가능) | 무제한 | ASG 수동/자동 | 최대 | OS 커스텀, 특수 인스턴스 필요 |
| **ECS (EC2 시작)** | O | 무제한 | Cluster/Service AS | 중간 | 컨테이너 + EC2 노드 직접 제어 |
| **ECS / EKS + Fargate** | 제한적 | 무제한 (태스크 단위) | 태스크 자동 스케일 | 낮음 | 노드 관리 없이 컨테이너 |
| **Lambda** | X (스테이트리스) | **최대 15분** | 자동(동시 실행) | 최소 | 이벤트성, 짧은 실행 |
| **AWS Batch** | 작업 단위 상태 | 무제한 | 자동 Compute Env | 낮음 | 대규모 배치, 완료 후 종료 |
| **EC2 HPC (클러스터 PG + EFA)** | O | 무제한 | 수동/ASG | 높음 | MPI 과학연산, ML 분산 학습 |

### 3) 컨테이너: ECS vs EKS vs Fargate

**Amazon ECS(Elastic Container Service)**

> 공식 정의: "완전 관리형 컨테이너 오케스트레이션 서비스로, 컨테이너화된 애플리케이션의 배포·관리·확장을 지원합니다."

ECS는 세 계층으로 구성됩니다.

| 계층 | 역할 |
|---|---|
| **Capacity** | 컨테이너가 실행되는 인프라 (EC2 인스턴스 또는 Fargate) |
| **Controller** | 스케줄러 — 태스크·서비스를 배포·관리 |
| **Provisioning** | AWS 콘솔·CLI·SDK·CDK — 스케줄러와 인터페이스 |

ECS의 핵심 리소스:

| 리소스 | 설명 |
|---|---|
| **Task Definition** | 컨테이너 설계도(이미지, CPU/메모리, 포트, IAM 역할) |
| **Task** | Task Definition의 실행 인스턴스 — 실행 후 종료되는 일회성 작업 |
| **Service** | 지정된 수의 Task를 지속 실행 — 장기 상주 앱(웹 서버 등) |
| **Cluster** | Task/Service가 실행되는 논리 단위 |

**Amazon EKS(Elastic Kubernetes Service)**

> 공식 정의: "Kubernetes 클러스터 운영의 복잡성을 제거하는 완전 관리형 Kubernetes 서비스."

EKS는 Kubernetes 컨트롤 플레인을 AWS가 관리합니다. ECS와의 핵심 차이는 **표준성**입니다.

| 비교 항목 | ECS | EKS |
|---|---|---|
| 오케스트레이션 표준 | AWS 독자 | Kubernetes (CNCF 표준) |
| 러닝커브 | 낮음 | 높음 (K8s 지식 필요) |
| 이식성 | AWS 한정 | 온프레미스·멀티클라우드 호환 |
| 선택 기준 | AWS 네이티브 스택, 빠른 도입 | 기존 K8s 워크로드, 표준 도구 필요 |

> 시험에 "쿠버네티스"가 등장하면 EKS, "노드 관리 없이" + "쿠버네티스"이면 EKS + Fargate입니다.

**AWS Fargate — 서버리스 컨테이너 실행 모드**

> 공식 정의: "Amazon ECS(또는 EKS)와 함께 사용하는 서버리스 컴퓨팅 엔진으로, EC2 인스턴스를 관리하지 않고 컨테이너를 실행합니다."

Fargate는 독립 서비스가 아니라 **ECS 또는 EKS의 실행 모드(시작 유형)**입니다.

| 항목 | EC2 시작 유형 | Fargate 시작 유형 |
|---|---|---|
| 인스턴스 관리 | 직접 (프로비저닝·패치·스케일링) | AWS 자동 관리 |
| 비용 단위 | EC2 인스턴스 시간 | vCPU + 메모리 사용량 (초 단위) |
| 세밀한 제어 | O (GPU, 특수 인스턴스) | 제한적 |
| 운영 부담 | 중간 | 낮음 |
| 보안 격리 | 공유 노드 | **태스크별 독립 격리 경계** |

> Fargate의 각 Task는 자체 격리 경계를 가집니다 — 커널·CPU·메모리·네트워크 인터페이스를 다른 Task와 공유하지 않습니다.

### 4) Lambda 성능 튜닝

Lambda는 saa-t2-2에서 이벤트 기반 패턴으로 다뤘습니다. 여기서는 **성능·동시성·제약** 관점만 정리합니다.

| 개념 | 핵심 |
|---|---|
| **메모리 ↔ CPU** | 메모리를 올리면 CPU도 비례 증가 — 성능 튜닝의 유일한 손잡이 |
| **최대 실행 시간** | **15분** — 이보다 긴 작업은 Lambda 부적합 |
| **동시성(Concurrency)** | 계정·리전당 기본 1,000 동시 실행 제한 (조정 가능) |
| **예약 동시성(Reserved)** | 특정 함수에 동시성 할당 보장 + 상한선 설정 |
| **Provisioned Concurrency** | 미리 초기화된 실행 환경 유지 → **콜드 스타트 제거** |
| **콜드 스타트** | 첫 호출 또는 유휴 후 컨테이너 초기화 지연 (수십~수백 ms) |

> **성능 제약 요약**: 15분 초과·상태 유지·지속 연결(WebSocket 서버) → Lambda 부적합. 이 경우 ECS/Fargate 또는 EC2로 이동합니다.

### 5) AWS Batch — 배치 워크로드 전용 오케스트레이터

> 공식 정의: "AWS Batch는 완전 관리형 서비스로, 배치 컴퓨팅 워크로드를 효율적으로 실행·스케줄링합니다. 인프라 프로비저닝을 자동화해 용량 제약 없이 결과를 빠르게 도출합니다."

AWS Batch는 제출된 Job 수·규모에 따라 컴퓨팅 리소스를 자동 프로비저닝합니다. 내부적으로 ECS, EKS, Fargate를 실행 엔진으로 사용합니다.

**3계층 구성:**

| 계층 | 설명 | 예시 |
|---|---|---|
| **Job** | 실행 단위 (Docker 컨테이너 기반) | 유전체 분석 스크립트, 렌더링 태스크 |
| **Job Queue** | Job이 대기하는 큐 — 우선순위 설정 가능 | 고우선순위 큐 / 일반 큐 |
| **Compute Environment** | Job을 실행하는 컴퓨팅 풀 (EC2 On-Demand/Spot 또는 Fargate) | Spot 인스턴스 풀 (비용 절감) |

**AWS Batch vs Lambda 비교 (배치 관점):**

| 항목 | Lambda | AWS Batch |
|---|---|---|
| 실행 시간 제한 | 15분 | **무제한** |
| 상태 유지 | X | O (컨테이너 내) |
| 트리거 | 이벤트 | Job 제출 (API/콘솔/스케줄) |
| 대표 용도 | 실시간 이벤트 처리 | 유전체 분석, 재무 보고, 3D 렌더링 |

> "대규모 배치", "완료 후 종료", "가변 컴퓨팅 필요", "Spot 인스턴스 활용"이 보이면 AWS Batch를 고릅니다.

### 6) HPC — 고성능 컴퓨팅 아키텍처

HPC(High Performance Computing)는 노드 간 초저지연 통신이 필요한 과학연산·ML 분산 학습에 사용됩니다.

**핵심 구성요소:**

| 구성요소 | 역할 | 선택 이유 |
|---|---|---|
| **클러스터 배치 그룹** | EC2 인스턴스를 동일 물리 랙/AZ 내에 배치 | 노드 간 네트워크 지연 최소화 |
| **EFA (Elastic Fabric Adapter)** | OS-bypass 고대역폭 네트워크 인터페이스 | MPI 워크로드의 인터노드 통신 가속 |
| **FSx for Lustre** | 고성능 병렬 파일 시스템 | HPC 클러스터의 공유 스토리지, S3 연동 |
| **EC2 Hpc 인스턴스** | 고주파수 CPU + 고성능 네트워크 최적화 인스턴스 | 과학연산·ML 훈련 |

> **HPC 결정 신호**: "MPI", "분산 학습", "초저지연 인터노드", "과학연산" → 클러스터 배치 그룹 + EFA + FSx for Lustre 조합이 정답입니다.

---

## ✍️ 시험 포인트

| 시나리오 키워드 | 정답 방향 |
|---|---|
| "least operational overhead" + 컨테이너 | Fargate |
| "쿠버네티스" 또는 "K8s 호환" | EKS |
| "노드 관리 없이 컨테이너" | Fargate (ECS 또는 EKS 위에서) |
| "이벤트 기반", "짧은 처리", "스테이트리스" | Lambda |
| "15분 초과" 또는 "장시간 배치" | AWS Batch 또는 ECS/Fargate |
| "콜드 스타트 제거" | Provisioned Concurrency |
| "Lambda 성능 개선" | **메모리** 증가 (CPU 비례 증가) |
| "대규모 배치", "Spot 활용", "완료 후 종료" | AWS Batch |
| "MPI", "초저지연 인터노드", "과학연산" | 클러스터 배치 그룹 + EFA |
| "HPC 공유 스토리지" | FSx for Lustre |
| "OS·네트워크 직접 제어" | EC2 |

---

## ⚠️ 흔한 함정

1. **"Lambda로 15분 이상 작업을 처리한다."** → Lambda의 최대 실행 시간은 15분입니다. 초과 시 강제 종료됩니다. 장시간 배치 작업은 AWS Batch, 장기 실행 컨테이너는 ECS/Fargate를 사용합니다.

2. **"메모리를 늘려도 CPU는 그대로다."** → Lambda는 메모리와 CPU가 비례합니다. 메모리를 두 배 늘리면 vCPU도 비례해 증가합니다. 성능 튜닝의 유일한 손잡이가 메모리임을 기억합니다.

3. **"Fargate는 독립 서비스다."** → Fargate는 ECS 또는 EKS의 **시작 유형(실행 모드)**입니다. 독립적으로 사용하지 않으며, 오케스트레이터(ECS/EKS) 위에서 동작합니다.

4. **"ECS와 EKS는 같다."** → ECS는 AWS 독자 오케스트레이터, EKS는 관리형 Kubernetes입니다. 기존 Kubernetes 워크로드·도구 호환성이 필요하면 EKS, AWS 네이티브 스택으로 빠르게 시작하려면 ECS를 선택합니다.

5. **"콜드 스타트는 메모리를 늘리면 해결된다."** → 콜드 스타트는 컨테이너 초기화 지연이 원인입니다. 메모리 증가는 실행 속도를 높이지만 콜드 스타트를 없애지 않습니다. 근본 해결책은 **Provisioned Concurrency**입니다.

6. **"AWS Batch는 Lambda와 같은 이벤트 기반이다."** → AWS Batch는 Job 제출(API 호출·스케줄)로 트리거되는 **배치 오케스트레이터**입니다. 실행 시간 제한이 없고, 작업 완료 후 컴퓨팅 환경이 종료됩니다.

7. **"HPC에서 배치 그룹만 있으면 충분하다."** → 클러스터 배치 그룹은 물리적 배치를 보장하지만, 인터노드 초저지연 통신에는 **EFA**가 추가로 필요합니다. 공유 스토리지에는 **FSx for Lustre**를 함께 구성합니다.

---

## 🧪 자가 점검

> 아래는 학습용 자가 점검입니다. (정식 검증 문항은 별도 문항 파일 참조)

**Q1.** 한 회사가 유전체 데이터 분석 파이프라인을 AWS로 마이그레이션하려 합니다. 각 분석 작업은 수 시간이 걸리고, 작업 수가 수천 개에 달하며 완료 후 결과를 S3에 저장합니다. 운영 부담을 최소화하면서 가변 컴퓨팅 수요를 처리하려면?

<details><summary>정답 보기</summary>

**AWS Batch**를 사용합니다. AWS Batch는 Job 제출량에 따라 Compute Environment를 자동으로 프로비저닝·종료하며, 실행 시간 제한이 없습니다. Spot 인스턴스를 Compute Environment로 구성하면 비용도 절감됩니다. Lambda는 15분 제한으로 부적합하고, EC2 직접 관리는 운영 부담이 큽니다.
</details>

**Q2.** 회사가 마이크로서비스를 Kubernetes로 운영 중이며 AWS로 이전합니다. 기존 Kubernetes 매니페스트와 도구를 그대로 사용하고, 노드 관리 부담을 없애고 싶습니다. 가장 적합한 선택은?

<details><summary>정답 보기</summary>

**Amazon EKS + Fargate**입니다. EKS는 관리형 Kubernetes로 기존 K8s 워크로드·도구와 호환됩니다. Fargate를 시작 유형으로 선택하면 EC2 노드 프로비저닝·패치·스케일링을 AWS가 처리해 운영 부담이 없어집니다. ECS는 Kubernetes 표준을 지원하지 않으므로 부적합합니다.
</details>

**Q3.** Lambda 함수의 응답 속도가 간헐적으로 느려지는 문제가 보고됩니다. 분석 결과 유휴 후 첫 호출에서 지연이 발생합니다. 어떻게 해결하나요?

<details><summary>정답 보기</summary>

**Provisioned Concurrency**를 활성화합니다. 콜드 스타트는 Lambda가 유휴 상태에서 새 실행 환경(컨테이너)을 초기화하는 시간입니다. Provisioned Concurrency는 지정된 수의 실행 환경을 미리 초기화 상태로 유지해 콜드 스타트를 제거합니다. 메모리 증가는 함수 실행 속도를 높이지만 초기화 지연 자체를 없애지 않습니다.
</details>

**Q4.** 금융 회사가 기상 시뮬레이션 HPC 클러스터를 AWS에 구축하려 합니다. 수백 개의 노드가 MPI로 긴밀하게 통신하며, 공유 파일 시스템도 필요합니다. 어떤 조합을 선택해야 하나요?

<details><summary>정답 보기</summary>

**EC2 클러스터 배치 그룹 + EFA + FSx for Lustre** 조합을 선택합니다. 클러스터 배치 그룹은 인스턴스를 동일 물리 랙 근처에 배치해 네트워크 지연을 최소화합니다. EFA(Elastic Fabric Adapter)는 OS-bypass 방식으로 MPI 인터노드 통신을 가속합니다. FSx for Lustre는 고성능 병렬 파일 시스템으로 HPC 클러스터의 공유 스토리지를 제공하며 S3와 연동됩니다.
</details>

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. (작성·대조: 2026-06-07)

1. Amazon ECS — What is Amazon Elastic Container Service — https://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html
2. AWS Fargate — Architect for AWS Fargate for Amazon ECS — https://docs.aws.amazon.com/AmazonECS/latest/userguide/what-is-fargate.html
3. Amazon EKS — What is Amazon EKS — https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html
4. AWS Batch — What is AWS Batch — https://docs.aws.amazon.com/batch/latest/userguide/what-is-batch.html
5. SAA-C03 공식 시험 가이드 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
