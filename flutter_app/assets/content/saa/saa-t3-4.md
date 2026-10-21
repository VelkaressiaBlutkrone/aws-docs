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
    url: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html
  - title: Amazon EKS — Simplify compute management with AWS Fargate (공식)
    url: https://docs.aws.amazon.com/eks/latest/userguide/fargate.html
  - title: Amazon EKS — What is Amazon EKS (공식)
    url: https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html
  - title: AWS Batch — What is AWS Batch (공식)
    url: https://docs.aws.amazon.com/batch/latest/userguide/what-is-batch.html
  - title: AWS Lambda — Lambda quotas (공식)
    url: https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-limits.html
  - title: AWS Lambda — Configure function memory (공식)
    url: https://docs.aws.amazon.com/lambda/latest/dg/configuration-memory.html
  - title: AWS Lambda — Provisioned concurrency (공식)
    url: https://docs.aws.amazon.com/lambda/latest/dg/provisioned-concurrency.html
  - title: Amazon EC2 — Placement strategies (공식)
    url: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/placement-strategies.html
  - title: Amazon EC2 — Elastic Fabric Adapter (공식)
    url: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/efa.html
  - title: Amazon FSx for Lustre — What is FSx for Lustre (공식)
    url: https://docs.aws.amazon.com/fsx/latest/LustreGuide/what-is.html
  - title: SAA-C03 공식 시험 가이드 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
lastVerified: 2026-10-19
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

## 🔤 먼저 알아야 할 용어

이 문서를 읽는 데 필요한 기초 용어입니다. 이미 알면 건너뛰세요.

| 용어 | 영문 | 한 줄 풀이 |
|---|---|---|
| **컨테이너** | Container | 앱과 실행에 필요한 라이브러리·설정을 하나의 패키지로 묶어 어디서든 동일하게 실행되게 하는 단위 (이사 짐 박스처럼) |
| **오케스트레이션** | Orchestration | 다수의 컨테이너를 자동으로 배포·스케줄·복구·확장하는 관리 체계 |
| **프로비저닝** | Provisioning | 필요한 컴퓨팅·스토리지·네트워크 자원을 자동 또는 수동으로 할당·준비하는 과정 |
| **Kubernetes** | Kubernetes (K8s) | 컨테이너 오케스트레이션의 CNCF 표준 오픈소스 플랫폼 — 멀티클라우드·온프레미스에서 이식 가능 |
| **이벤트 기반** | Event-driven | 특정 이벤트(HTTP 요청·메시지 도착 등) 발생 시에만 실행 환경이 깨어나는 아키텍처 패턴 |
| **워크로드** | Workload | AWS 위에서 특정 비즈니스 목적을 수행하는 애플리케이션·서비스의 집합 |

---

## 📖 핵심 개념 {#core-concepts}

### 1) 컴퓨팅 선택 결정 트리 {#compute-decision-tree}

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

> 🧠 원리: 왜 AWS 컴퓨팅 서비스들은 "제어 범위"와 "운영 부담"이 반비례 관계를 이룰까요?
> AWS가 더 많이 관리할수록 사용자가 결정할 수 없는 영역(OS 버전·패치 일정·인프라 배치 등)이 늘어나고, 그만큼 사용자의 운영 작업이 줄어드는 구조입니다.
> 반대로 EC2처럼 인프라를 직접 제어하면 패치·스케일링·복구 모두 사용자가 책임지므로 운영 부담이 커집니다.
> 이 트레이드오프는 서비스가 아니라 "어느 계층까지 AWS가 추상화하느냐"의 차이이며, 워크로드의 특수 요구사항이 없을수록 스펙트럼 오른쪽이 유리할 수 있습니다.

### 2) 컴퓨팅 옵션 비교표 (★ 시험 핵심) {#compute-options}

| 옵션 | 상태 유지 | 최대 실행 시간 | 확장 방식 | 운영 부담 | 대표 시나리오 |
|---|---|---|---|---|---|
| **EC2** | O (Stateful 가능) | 무제한 | ASG 수동/자동 | 최대 | OS 커스텀, 특수 인스턴스 필요 |
| **ECS (EC2 시작)** | O | 무제한 | Cluster/Service AS | 중간 | 컨테이너 + EC2 노드 직접 제어 |
| **ECS / EKS + Fargate** | 제한적 | 무제한 (태스크 단위) | 태스크 자동 스케일 | 낮음 | 노드 관리 없이 컨테이너 |
| **Lambda** | X (스테이트리스) | **최대 15분** | 자동(동시 실행) | 최소 | 이벤트성, 짧은 실행 |
| **AWS Batch** | 작업 단위 상태 | 무제한 | 자동 Compute Env | 낮음 | 대규모 배치, 완료 후 종료 |
| **EC2 HPC (클러스터 PG + EFA)** | O | 무제한 | 수동/ASG | 높음 | MPI 과학연산, ML 분산 학습 |

> 🧠 원리: 왜 Lambda만 "상태 유지 X"로 표기되고 다른 서비스들은 상태를 유지할 수 있을까요?
> Lambda의 실행 환경(컨테이너)은 요청 처리 후 언제든지 종료·재생성될 수 있어 실행 간 메모리 상태가 보존된다는 보장이 없습니다.
> 반면 EC2·ECS·EKS는 프로세스가 지속 실행 중인 서버 위에서 동작하므로 메모리·디스크·연결 상태를 유지할 수 있습니다.
> 실행 환경이 재생성되면 이전 인스턴스에 기록된 인메모리 상태는 사라지고, 다음 요청이 해당 상태를 가정하고 동작하면 데이터 불일치가 발생합니다.

### 3) 컨테이너: ECS vs EKS vs Fargate {#containers-ecs-eks-fargate}

**Amazon ECS(Elastic Container Service)**

> 공식 정의: "완전 관리형 컨테이너 오케스트레이션 서비스로, 컨테이너화된 애플리케이션의 배포·관리·확장을 지원합니다."

ECS는 세 계층으로 구성됩니다.

| 계층 | 역할 |
|---|---|
| **Capacity** | 컨테이너가 실행되는 인프라 (ECS Managed Instances, EC2 인스턴스, Fargate, ECS Anywhere 등) |
| **Controller** | 스케줄러 — 태스크·서비스를 배포·관리 |
| **Provisioning** | AWS 콘솔·CLI·SDK·CDK — 스케줄러와 인터페이스 |

ECS의 핵심 리소스:

| 리소스 | 설명 |
|---|---|
| **Task Definition** | 컨테이너 설계도(이미지, CPU/메모리, 포트, IAM 역할) |
| **Task** | Task Definition의 실행 인스턴스 — 실행 후 종료되는 일회성 작업 |
| **Service** | 지정된 수의 Task를 지속 실행 — 장기 상주 앱(웹 서버 등) |
| **Cluster** | Task/Service가 실행되는 논리 단위 |

**ECS 용량 공급자(Capacity Provider) — "어디서 실행할지"를 전략으로 적는 층 (★ 시험 핵심)**

| 용량 공급자 | 대상 | 특징 |
|---|---|---|
| `FARGATE` | 서버리스 | 온디맨드 Fargate 용량 |
| `FARGATE_SPOT` | 서버리스 | 여유 컴퓨팅 용량으로 할인 — ⚠️ AWS가 용량을 회수하면 **2분 경고** 뒤 태스크가 중단됩니다(중단을 견디는 워크로드만) |
| Auto Scaling 그룹 용량 공급자 | EC2 | ASG를 붙여 ECS가 컨테이너 인스턴스 수까지 관리 |

전략(capacity provider strategy)의 제약:

- 한 전략에는 **Fargate 계열 또는 ASG 계열 중 한 쪽만** 넣을 수 있습니다. 클러스터는 두 계열을 함께 가질 수 있지만, 전략 하나가 둘을 동시에 담지는 못합니다.
- 전략 하나에 용량 공급자는 최대 **20개**입니다.
- `weight` 기본값이 경로마다 갈립니다 — **콘솔 1 / API·CLI 0**. 모든 용량 공급자의 weight가 0이면 `RunTask`·`CreateService`가 실패합니다.
- `base`를 지정할 수 있는 용량 공급자는 **전략 안에 하나**뿐입니다(미지정 시 0).
- ASG 용량 공급자를 쓰는 서비스를 **Fargate 용량 공급자로 변경할 수 없습니다**(반대도 불가).

**클러스터 오토스케일링(관리형 스케일링)** — ASG 용량 공급자를 만들 때 관리형 스케일링을 켜고 `targetCapacity`(목표 인스턴스 사용률)를 주면, ECS가 해당 ASG에 **CloudWatch 알람 2개와 대상 추적 조정 정책을 대신 만들어 붙입니다.**

> 판단 기준은 `CapacityProviderReservation` 지표(네임스페이스 `AWS/ECS/ManagedScaling`)이고, 공식 산식은 **`(필요한 인스턴스 수) / (실행 중인 인스턴스 수) × 100`**입니다. `targetCapacity`를 80%로 두면 "항상 20%는 여유로 비워 두라"는 뜻이 되어, 태스크가 새 인스턴스 부팅을 기다리지 않고 바로 뜹니다 — 대가는 유휴 용량 비용입니다.
>
> ⚠️ 이때 생성된 대상 추적 정책을 **직접 수정하지 않습니다.** 바꿀 것은 **용량 공급자의 관리형 스케일링 설정**입니다.

**Amazon EKS(Elastic Kubernetes Service)**

> 공식 정의: "Kubernetes 클러스터 운영의 복잡성을 제거하는 완전 관리형 Kubernetes 서비스."

EKS는 표준 모드에서 Kubernetes 컨트롤 플레인을 AWS가 관리합니다. 현행 문서에는 노드 데이터 플레인까지 자동화하는 **EKS Auto Mode**도 별도 접근으로 소개됩니다. ECS와의 핵심 차이는 여전히 **표준성**입니다.

| 비교 항목 | ECS | EKS |
|---|---|---|
| 오케스트레이션 표준 | AWS 독자 | Kubernetes (CNCF 표준) |
| 러닝커브 | 낮음 | 높음 (K8s 지식 필요) |
| 이식성 | AWS 한정 | 온프레미스·멀티클라우드 호환 |
| 선택 기준 | AWS 네이티브 스택, 빠른 도입 | 기존 K8s 워크로드, 표준 도구 필요 |

**EKS의 컴퓨트(노드) 선택지 — 공식이 드는 다섯 가지**

| 선택지 | 노드를 누가 관리하나 | 고르는 이유 |
|---|---|---|
| **EKS Auto Mode** | AWS가 **데이터 플레인까지** | 컴퓨팅 오토스케일링·네트워킹·로드 밸런싱·DNS·스토리지·GPU 지원을 내장 구성요소로 받고 운영 부담을 최소화 |
| **AWS Fargate** | AWS (관리할 인스턴스 없음) | 자원 요구만 적고 프로비저닝·확장·유지를 맡김 |
| **Karpenter** | 사용자가 컨트롤러를 운영 | 바뀌는 부하에 맞춰 **적정 크기** 노드를 즉시(just-in-time) 띄움 |
| **관리형 노드 그룹** | AWS가 패치·갱신·스케일링, 사용자가 `kubelet` 인수 등 | 자동화와 커스터마이즈의 중간 — 고급 CPU·메모리 관리 정책까지 손댈 수 있음 |
| **자체 관리 노드** | 전부 사용자 | 기반 인프라를 세밀하게 통제해야 할 때 |

> 시험에 "쿠버네티스"가 등장하면 EKS, "노드 관리 없이" + "쿠버네티스"이면 EKS + Fargate 또는 EKS Auto Mode입니다. "노드 유형을 워크로드마다 자동으로 골라 띄워라"가 핵심이면 **Karpenter**입니다.

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

> ⚠️ **Fargate가 못 가는 곳이 있습니다**: Amazon ECS on AWS Fargate 워크로드는 **Local Zones·Wavelength Zones·AWS Outposts에서 지원되지 않습니다.** 저지연 엣지 위치나 온프레미스에서 컨테이너를 돌려야 하면 **EC2 시작 유형**을 골라야 합니다 — 리전 밖 배치 선택지는 §7에서 다룹니다.

> 🧠 원리: 왜 Fargate는 독립 서비스가 아닌 ECS 또는 EKS의 "실행 모드"로 설계됐을까요?
> 컨테이너를 실행하려면 스케줄링(어떤 태스크를 언제 어디서 실행할지)과 인프라(실제로 실행할 컴퓨팅 자원)가 분리돼야 합니다.
> ECS와 EKS는 스케줄링 계층을 담당하고, Fargate는 그 아래 인프라 계층을 대체하는 역할이므로 오케스트레이터 없이 단독으로 존재할 수 없는 구조입니다.
> 이 분리 덕분에 사용자는 ECS를 유지하면서 인프라 관리 부담만 Fargate로 위임하거나, EKS와 Fargate를 조합해 Kubernetes 호환성과 노드 무관리를 동시에 얻을 수 있습니다.

### 4) Lambda 성능 튜닝 {#lambda-performance}

Lambda는 saa-t2-2에서 이벤트 기반 패턴으로 다뤘습니다. 여기서는 **성능·동시성·제약** 관점만 정리합니다.

| 개념 | 핵심 |
|---|---|
| **메모리 ↔ CPU** | 설정 범위 **128 MB ~ 10,240 MB**(1 MB 단위). 메모리를 올리면 CPU도 비례 증가(**1,769 MB = 1 vCPU**) — 공식 서술상 성능 제어의 **주된(principal) 손잡이** |
| **최대 실행 시간** | **15분** — 이보다 긴 작업은 Lambda 부적합 |
| **동시성(Concurrency)** | 계정·리전당 기본 1,000 동시 실행 제한 (조정 가능) |
| **예약 동시성(Reserved)** | 특정 함수에 동시성 할당 보장 + 상한선 설정 |
| **Provisioned Concurrency** | 미리 초기화된 실행 환경 유지 → **콜드 스타트 제거** |
| **콜드 스타트** | 첫 호출 또는 유휴 후 컨테이너 초기화 지연 (수십~수백 ms) |

> **성능 제약 요약**: 15분 초과·상태 유지·지속 연결(WebSocket 서버) → Lambda 부적합. 이 경우 ECS/Fargate 또는 EC2로 이동합니다.

**명령어 세트 아키텍처 — arm64(Graviton) 선택**

Lambda는 `x86_64`와 `arm64`(AWS Graviton) 중 하나를 고릅니다. 공식 문서는 전환을 "해 보고 비교하라"는 **절차**로 안내하며, 이득 폭을 수치로 못박지 않습니다.

| 단계 | 할 일 |
|---|---|
| 1 | 함수가 쓰는 라이브러리·패키지, 빌드·배포·테스트 도구(컴파일러·CI/CD·프로비저닝 스크립트), Lambda 확장·서드파티 모니터링 도구까지 **의존성 목록**을 만든다 |
| 2 | 각 의존성의 버전을 확인하고 **arm64 빌드가 있는지** 확인한다 |
| 3 | 마이그레이션 환경을 만들어 부트스트랩·테스트·디버깅 |
| 4 | **성능을 x86_64 버전과 비교** |
| 5 | 인프라 파이프라인이 arm64를 지원하도록 고친 뒤 단계적으로 배포 |

> 전환 검증의 실전 수단은 **별칭 라우팅 구성(alias routing configuration)**입니다 — 트래픽을 x86 버전과 arm64 버전으로 나눠 보내 성능·지연을 같은 부하에서 비교합니다.

**Fargate 태스크 크기 — 조합이 정해져 있습니다 (★ 시험 포인트)**

Fargate는 태스크 정의에서 **태스크 수준 CPU·메모리를 반드시** 지정하며, 아래 조합만 유효합니다.

| CPU | 메모리 | 지원 OS |
|---|---|---|
| 256 (**.25 vCPU**) | 512 MiB · 1 GB · 2 GB | Linux |
| 512 (.5 vCPU) | 1 ~ 4 GB (1 GB 단위) | Linux |
| 1024 (1 vCPU) | 2 ~ 8 GB (1 GB 단위) | Linux, Windows |
| 2048 (2 vCPU) | 4 ~ 16 GB (1 GB 단위) | Linux, Windows |
| 4096 (4 vCPU) | 8 ~ 30 GB (1 GB 단위) | Linux, Windows |
| 8192 (8 vCPU) | 16 ~ 60 GB (**4 GB 단위**) | Linux (플랫폼 `1.4.0`+) |
| 16384 (16 vCPU) | 32 ~ **120 GB** (**8 GB 단위**) | Linux (플랫폼 `1.4.0`+) |
| 32768 (32 vCPU) | 60 GB · 120 GB · 244 GB | Linux (플랫폼 `1.4.0`+) |

> 임시 스토리지는 최대 **200 GiB**까지 지정할 수 있습니다(Fargate 호스팅 태스크 전용). CPU 값은 CPU 단위(`1024`) 또는 vCPU 문자열(`1 vCPU`)로, 메모리는 MiB(`3072`) 또는 GB(`3 GB`)로 적을 수 있습니다.
>
> 시험에서 "2 vCPU에 3 GB"처럼 **표에 없는 조합**을 주고 배포 실패 원인을 묻는 유형이 나옵니다. 세로(CPU)를 먼저 고르면 가로(메모리) 범위가 따라 정해지는 구조입니다.

**SQS 이벤트 소스 매핑(ESM)은 어떤 속도로 늘어나는가 (★ 시험 핵심)**

Lambda가 SQS를 **폴링**하는 쪽이라, 동시성은 호출량이 아니라 **ESM의 스케일링 규칙**이 정합니다.

| 단계 | 표준 큐 동작 |
|---|---|
| 시작 | 메시지가 보이면 **다섯 배치를 동시에** 처리 — 동시 호출 5개로 출발 |
| 증가 | 메시지가 계속 있으면 배치를 읽는 프로세스를 **분당 최대 300개 동시 호출씩** 늘림 |
| 상한 | 한 ESM이 동시에 처리할 수 있는 최대 호출 수는 **1,250** |
| 감소 | 트래픽이 줄면 동시 호출 5개로 되돌리고, 비용을 줄이려 **최소 2개**까지 더 내려갑니다(⚠️ **최대 동시성 설정을 쓰면 이 최적화가 적용되지 않습니다**) |

- **최대 동시성(maximum concurrency)**은 **이벤트 소스 단위** 설정이라, 한 함수에 여러 SQS 이벤트 소스를 붙이면 각각 따로 줄 수 있습니다. 한 큐가 함수의 예약 동시성이나 계정 할당량을 전부 먹는 것을 막는 용도이며 **설정 자체는 무료**입니다.
- ⚠️ **최대 동시성과 예약 동시성은 서로 독립된 두 설정**입니다. 최대 동시성을 함수의 예약 동시성보다 **높게 두면 안 됩니다** — 그러면 Lambda가 메시지를 스로틀할 수 있습니다.
- **프로비저닝 모드**를 켜면 전용 이벤트 폴러를 최소·최대로 두어 **약 3배 빠른 스케일링과 최대 16배 처리 용량**을 얻고, 동시 호출 상한이 **100,000**까지 올라갑니다(폴러 1개당 1 MB/초 또는 동시 호출 10개 또는 SQS 폴링 API 10회/초). ⚠️ 최대 동시성 설정과는 **함께 쓸 수 없습니다.**
- **FIFO 큐**는 동시 호출이 **메시지 그룹 ID 수와 최대 동시성 설정 중 작은 쪽**으로 묶입니다 — 메시지 그룹이 6개면 최대 동시성을 10으로 줘도 동시 호출은 6개입니다.
- `BatchSize` 기본값은 **10**이고, 상한은 표준 큐 **10,000** / FIFO 큐 **10**입니다. 배치 윈도(`MaximumBatchingWindowInSeconds`)는 **FIFO 큐에서 지원되지 않습니다.**

> 🧠 원리: 왜 Lambda는 메모리 설정 하나로 CPU 성능까지 함께 조정될까요?
> 메모리가 연산 용량 전체를 함께 움직이므로 CPU·네트워크·메모리 병목 모두 메모리를 올려 완화할 수 있습니다. 다만 공식 서술은 메모리를 **주된(principal)** 손잡이로 표현하며, 병목을 넘어서면 이득이 줄어듭니다 — 아키텍처(arm64)·임시 스토리지 같은 다른 요소도 영향을 주고, 변곡점은 **AWS Lambda Power Tuning**으로 찾습니다.
> 이 구조는 성능·비용 튜닝을 1차원 탐색으로 단순화합니다 — 메모리를 올리면 처리 속도가 빨라져 실행 시간이 줄고, 메모리 단가 상승과 실행 시간 단축이 상쇄되는 최적점을 단일 파라미터 조정으로 찾을 수 있습니다.
> 사용자 관점에서는 "메모리 하나만 조정하면 연산 자원이 함께 따라온다"는 예측 가능성이 운영 단순성으로 이어집니다.

### 5) AWS Batch — 배치 워크로드 전용 오케스트레이터 {#aws-batch}

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

> 🧠 원리: 왜 AWS Batch는 Job 제출량에 따라 Compute Environment를 자동으로 늘렸다 줄이는 구조로 설계됐을까요?
> 배치 워크로드는 제출 시점에 몰렸다가 처리 완료 후 수요가 사라지는 특성이 있어, 고정된 컴퓨팅 용량을 상시 유지하면 유휴 비용이 발생합니다.
> Job Queue가 작업을 버퍼링하는 동안 Compute Environment가 실제 대기 중인 Job 수에 맞춰 인스턴스를 프로비저닝하고, 작업 완료 후 다시 축소하는 방식으로 이 낭비를 줄입니다.
> 이 탄력적 프로비저닝 구조가 Spot 인스턴스와 결합될 때 비용 효과가 커지는 이유이기도 합니다.

### 6) HPC — 고성능 컴퓨팅 아키텍처 {#hpc-architecture}

HPC(High Performance Computing)는 노드 간 초저지연 통신이 필요한 과학연산·ML 분산 학습에 사용됩니다.

**핵심 구성요소:**

| 구성요소 | 역할 | 선택 이유 |
|---|---|---|
| **클러스터 배치 그룹** | EC2 인스턴스를 동일 물리 랙/AZ 내에 배치 | 노드 간 네트워크 지연 최소화 |
| **EFA (Elastic Fabric Adapter)** | OS-bypass 고대역폭 네트워크 인터페이스 | MPI 워크로드의 인터노드 통신 가속 |
| **FSx for Lustre** | 고성능 병렬 파일 시스템 | HPC 클러스터의 공유 스토리지, S3 연동 |
| **EC2 Hpc 인스턴스** | 고주파수 CPU + 고성능 네트워크 최적화 인스턴스 | 과학연산·ML 훈련 |

> **HPC 결정 신호**: "MPI", "분산 학습", "초저지연 인터노드", "과학연산" → 클러스터 배치 그룹 + EFA + FSx for Lustre 조합이 정답입니다.

> 🧠 원리: 왜 HPC에서 물리적 근접 배치(클러스터 배치 그룹)만으로는 부족하고 EFA가 별도로 필요할까요?
> 클러스터 배치 그룹은 인스턴스들을 물리적으로 가까운 위치에 배치해 네트워크 경로를 단축하지만, 여전히 OS 네트워크 스택(커널 소켓, 프로토콜 처리)을 통해 데이터가 전달됩니다.
> MPI 같은 HPC 통신 패턴은 수천 번의 소규모 메시지를 주고받는 방식이라 OS 스택 처리 오버헤드가 누적되면 지연이 커집니다.
> EFA는 OS-bypass 방식으로 메시지를 네트워크 인터페이스까지 직접 전달해 커널 오버헤드를 제거하므로, 배치 그룹의 물리적 근접성과 EFA의 통신 효율이 함께 있어야 초저지연 인터노드 통신이 가능합니다.

### 7) 엣지 컴퓨팅 — 리전 밖에서 코드를 돌리는 선택지 {#edge-compute}

여기까지는 전부 **리전 안**의 컴퓨팅이었습니다. 사용자와의 물리적 거리 자체가 병목이면 리전 안에서 인스턴스를 키워도 지연이 줄지 않습니다. 그때 고르는 층이 둘 있습니다 — **엣지에서 코드를 실행**하거나, **AWS 인프라를 사용자 쪽으로 가져오는** 것입니다.

**① 엣지 함수 — CloudFront 위에서 코드 실행**

| 항목 | CloudFront Functions | Lambda@Edge |
|---|---|---|
| 실행 위치 | CloudFront 엣지 로케이션 | CloudFront 리전 엣지 캐시·엣지 로케이션 |
| 실행 시간 한도 | 절대 시간이 아니라 **컴퓨팅 사용률(compute utilization) 0~100**으로 측정 — 100이 허용 시간 전부 | **함수 타임아웃 30초** |
| 최대 코드 크기 | **10 KB** (⚠️ 조정 불가 — 더 담아야 하면 CloudFront KeyValueStore) | 압축 패키지 **50 MB** |
| 최대 메모리 | **2 MB** | Lambda 쿼터와 동일 |
| 요청 본문 | ⚠️ **접근 불가** | Include Body 옵션으로 접근 가능(크기 제한 있음) |
| 네트워크 호출 | ⚠️ 런타임이 **네트워크·파일 시스템·환경 변수·타이머 접근을 제한**하고 동적 코드 평가도 막습니다 | S3 버킷·DynamoDB 테이블·EC2 등 **리전 자원 호출 가능** |
| 계정당 함수 수 | 100 | 배포당 100 (함수 쓸 수 있는 배포 500) |
| 한 함수에 연결 가능한 배포 | 100 | 500 |
| 동시성·처리량 | — | 리전당 동시 실행 **1,000**(인스턴스당 10 요청/초, 총 호출 한도 = 동시성 × 10), 리전당 **10,000 요청/초** |

> 공식 쿼터 표에서 **이벤트 유형(뷰어 / 오리진)에 따라 갈리는 항목은 "함수가 생성한 응답 크기"뿐**입니다 — 뷰어 이벤트 **40 KB**, 오리진 이벤트 **1 MB**. 본문을 노출하거나 교체할 때도 같은 경계가 쓰입니다: 평문은 뷰어 40 KB / 오리진 1 MB, base64 인코딩은 뷰어 **53.2 KB** / 오리진 **1.33 MB**. 이 한도를 넘는 본문을 반환하면 요청이 **HTTP 502**(Lambda 검증 오류)로 실패합니다.
>
> **선택 지도**: 헤더 조작·URL 재작성·간단한 리다이렉트·토큰 검증처럼 **짧고 자족적인 변환**이면 CloudFront Functions가 맞습니다. **외부 자원을 조회**해야 하거나(세션 DB 조회, S3 직접 읽기) **요청 본문**을 봐야 하면 Lambda@Edge만 가능합니다. CloudFront Functions의 로그는 **10 KB에서 잘립니다.**

**② AWS 인프라를 사용자 쪽으로 — 세 가지 배치 선택지**

| 선택지 | 무엇인가 | 고르는 신호 |
|---|---|---|
| **AWS Local Zones** | 리전의 확장으로, 컴퓨팅·스토리지·DB 등 **일부 서비스를 대도시·산업 중심지 가까이** 배치. 로컬 인터넷 입·출구를 갖고, 부모 리전과는 AWS 전용 고대역폭 네트워크로 연결 | "특정 도시 사용자에게 한 자릿수 ms 지연", 하이브리드 마이그레이션 단순화 |
| **AWS Wavelength Zones** | 표준 AWS 컴퓨팅·스토리지를 **통신사 5G 네트워크의 엣지**에 배치 | "5G 기기", "모바일 초저지연" |
| **AWS Outposts** | 네이티브 AWS 서비스·인프라·운영 모델을 **고객의 데이터센터·코로케이션·온프레미스**로 가져옴 | "데이터가 건물 안에 있어야 한다", 온프레미스 시스템과의 저지연 결합 |

> ⚠️ 세 곳 모두 **ECS on Fargate를 지원하지 않습니다**(§3 참고). 엣지 위치에서 컨테이너를 돌리려면 EC2 시작 유형입니다.

> 🧠 원리: 왜 CloudFront Functions는 네트워크 호출조차 막아 둘까요?
> CloudFront Functions는 모든 뷰어 요청·응답 경로에 끼어들어 **초당 수백만 건 규모**로 실행되는 것을 전제로 설계됐습니다. 그 규모에서 외부 호출 한 번의 대기 시간은 전체 응답 지연에 그대로 더해지고, 호출 대상이 느려지면 CDN 전체가 같이 느려집니다.
> 그래서 런타임이 네트워크·파일 시스템·타이머를 아예 제거해, 함수가 **자기 입력만 보고 즉시 끝나는 변환**만 할 수 있게 강제합니다. 10 KB 코드·2 MB 메모리 한도도 같은 취지의 울타리입니다.
> 반대로 Lambda@Edge는 호출 빈도가 낮은 오리진 이벤트까지 포함해 **외부 조회가 필요한 로직**을 맡으므로 30초 타임아웃과 리전 자원 접근을 허용합니다 — 두 서비스의 제약 차이는 성능 등급이 아니라 **실행 빈도에 맞춘 역할 분담**입니다.

### 8) 컴퓨팅 스케일링 지표 — 무엇을 보고 늘릴 것인가 {#compute-scaling-metrics}

컴퓨팅을 고른 다음 문제는 **"몇 대로 둘지"를 무엇이 결정하느냐**입니다. EC2 Auto Scaling은 `saa-t2-3`에서 다뤘고, 여기서는 **Application Auto Scaling**(ECS 서비스·Lambda·DynamoDB 등 ASG가 아닌 자원)과 **큐를 완충재로 쓰는 패턴**을 봅니다.

**Application Auto Scaling의 사전 정의 지표 (ECS 서비스)**

| 사전 정의 지표 유형 | 보는 CloudWatch 지표 |
|---|---|
| `ECSServiceAverageCPUUtilization` | `CPUUtilization` |
| `ECSServiceAverageMemoryUtilization` | `MemoryUtilization` |
| `ECSServiceAverageCPUUtilizationHighResolution` | `CPUUtilization` (**20초** 고해상도) |
| `ECSServiceAverageMemoryUtilizationHighResolution` | `MemoryUtilization` (**20초** 고해상도) |
| `ALBRequestCountPerTarget` | `RequestCountPerTarget` |

- 사전 정의 지표는 기본적으로 **1분 평균**을 백분율로 봅니다. `...HighResolution` 두 가지는 **20초 간격** 지표를 써서 20초마다 판단하며, ⚠️ **ECS에서 고해상도 지표를 먼저 활성화**해야 정책을 만들 수 있습니다.
- ⚠️ `ALBRequestCountPerTarget`은 **Spot Fleet과 ECS 서비스에만** 적용되는 지표 유형입니다.

**대상 추적이 "안 하는 일"을 알아야 합니다 (★ 시험 포인트)**

| 동작 | 공식 규칙 |
|---|---|
| 방향 | 지표가 목표값을 **넘을 때 확장**합니다. 목표값보다 **낮을 때 확장하는 용도로는 쓸 수 없습니다** |
| **데이터 부족** | 지표에 데이터가 없으면 **아무 조정도 하지 않습니다** — 데이터 부족을 "사용률 낮음"으로 해석해 축소하지 않습니다 |
| 오차 | 용량을 올림·내림으로 **보수적으로 반올림**하므로 목표값과 실제 지표에 틈이 보이는 것이 정상입니다 |
| 비대칭 | 가용성을 위해 **확장은 가능한 빠르게, 축소는 완만하게** 합니다 |
| ⚠️ 배포 중 | **ECS 배포가 진행되는 동안 Application Auto Scaling은 축소를 끕니다**(확장은 계속). 외부 배포 컨트롤러를 쓰는 서비스에는 적용되지 않습니다 |
| 복수 정책 | 지표가 서로 다르면 여러 개를 둘 수 있고, 가용성 우선 원칙에 따라 **어느 하나라도 확장을 원하면 확장**합니다 |

**큐를 완충재로 — "태스크당 백로그"로 조정하기**

생산자와 소비자 사이에 큐를 두면 스파이크를 큐가 흡수하고 소비자는 자기 속도로 처리합니다(큐 자체는 `saa-t2-1` §2 참고). 이때 **무엇을 지표로 삼느냐**가 핵심입니다.

- SQS는 큐 깊이를 `ApproximateNumberOfMessagesVisible`로 CloudWatch에 올립니다. 그러나 이 값을 지표로 **직접** 쓰면 안 됩니다 — 큐에 쌓인 메시지 수는 **실행 중인 태스크 수에 비례해 변하지 않기** 때문에, 큰 큐를 "비례해서 더 많은 태스크가 필요하다"로 해석해 필요 이상으로 확장하고 비용을 키웁니다.
- 대신 **태스크당 백로그 = 큐 깊이 ÷ 실행 중인 태스크 수**를 씁니다. CloudWatch **지표 수식(metric math)**으로 큐 깊이를 실행 태스크 수로 나눠 계산합니다. 이 값은 태스크 1개가 지는 부하에 비례하므로 조정 지표로 적합합니다.
- 목표값 = **허용 가능한 태스크당 백로그 = 허용 지연 ÷ 메시지 1건 평균 처리 시간**.

```
예) 허용 지연 10초, 평균 처리 시간 0.1초
    → 목표값 = 10 / 0.1 = 100 (메시지/태스크)

    현재 큐 1,500건 · 실행 태스크 10개
    → 태스크당 백로그 = 1,500 / 10 = 150  (목표 100 초과)
    → 태스크 5개 확장해 15개로 → 1,500 / 15 = 100
```

> EC2 Auto Scaling에서는 같은 계산을 **인스턴스당 백로그**로 합니다 — `saa-t2-3` §9를 보세요. 나누는 분모가 "실행 태스크 수"에서 "`InService` 인스턴스 수"로 바뀌는 것뿐, 사고 방식은 동일합니다.

> 🧠 원리: 왜 큐 길이 자체가 아니라 "나눈 값"이어야 조정 지표가 될까요?
> 대상 추적 정책은 "지표를 목표값에 붙여 두기 위해 용량을 몇으로 해야 하는가"를 역산합니다. 이 역산이 성립하려면 **용량을 늘렸을 때 지표가 그만큼 내려가는 관계**가 있어야 합니다.
> 큐 길이는 그 관계가 없습니다 — 태스크를 두 배로 늘려도 지금 큐에 쌓인 1,500건은 그 순간 1,500건 그대로입니다. 그래서 정책은 "아직 목표에 못 닿았다"며 계속 확장하고, 큐가 비워질 무렵에는 필요 없는 태스크가 잔뜩 남습니다.
> 큐 깊이를 실행 태스크 수로 나누면 용량이 분모로 들어가 **용량을 늘리는 즉시 지표가 내려가는** 관계가 생깁니다. 목표값을 "허용 지연 ÷ 처리 시간"으로 잡는 것도 같은 맥락입니다 — 지표의 단위를 시간(지연)으로 환산할 수 있어야 비즈니스 요구를 숫자로 번역할 수 있습니다.

### 9) 데이터 처리 컴퓨팅 — EMR 배포 선택 {#emr-deployment}

Spark·Hadoop 같은 분산 처리를 돌릴 때는 인스턴스를 직접 묶는 대신 Amazon EMR을 고릅니다. 시험에서는 **"어느 배포 형태인가"**와 **"어느 노드에 Spot을 쓰는가"**가 반복됩니다.

| 배포 | 확장 단위 | 특징·고르는 신호 |
|---|---|---|
| **EMR on Amazon EC2** | **클러스터 단위** | 노드 수를 직접 정의. 코어 노드는 적게 두고 **태스크 노드를 늘렸다 줄여** 맞춥니다. **EMR 관리형 스케일링** 또는 사용자 지정 오토스케일링 정책으로 최소·최대 노드 수만 주고 맡길 수 있습니다 |
| **EMR on Amazon EKS** | **잡(job) 단위** — 할당 vCPU·메모리에 비례 | 이미 EKS를 쓰고 있고 쿠버네티스 위에서 배치 잡을 돌리고 싶을 때 |
| **EMR on AWS Outposts** | 제약 큼 | 온프레미스 데이터·앱 **옆에서** 돌려야 하는 저지연 워크로드. ⚠️ Outposts의 EC2 용량이 한정돼 확장이 어렵고, **Spot 인스턴스를 쓸 수 없어** 비용이 올라갑니다. 스토리지는 **S3만** 지원되며 **S3 on Outposts는 지원되지 않습니다** |
| **EMR Serverless** | 신경 쓸 필요 없음 | **예측하기 어려운 워크로드**에 비용 효율적 — 용량 산정 자체가 없습니다 |

> 공식 비용 최적화 문서는 EMR 배포를 위 **네 가지**로 셉니다. "EC2 / EKS / Serverless 세 가지"로 외우면 Outposts 선택지가 빠집니다.

**태스크 노드에 Spot을 쓰는 이유 (★ 시험 핵심)**

- 태스크 노드는 데이터를 처리하지만 **HDFS에 영구 데이터를 보관하지 않습니다.** 그래서 Spot 가격 상승으로 종료돼도 **데이터 손실이 없고** 클러스터 영향이 최소입니다.
- 프라이머리·코어 인스턴스 그룹을 **온디맨드**로 두면 클러스터 수명 동안 용량이 보장되고, 피크 처리나 가속이 필요할 때 태스크 노드를 덧붙입니다.
- 태스크 인스턴스 그룹을 Spot으로 6대 요청했는데 최대 Spot 가격 이하로 5대만 있으면, EMR은 **5대로 시작하고 나머지 1대를 나중에 가능해지면 추가**합니다.
- ⚠️ 태스크 노드는 콘솔·CLI·API로 추가·제거할 수 있고 **태스크 그룹도 추가**할 수 있지만, **한 번 만든 태스크 그룹은 제거할 수 없습니다.**

> 🧠 원리: 왜 Spot을 코어 노드가 아니라 태스크 노드에만 권할까요?
> EMR 클러스터의 노드는 역할이 셋으로 갈립니다 — 프라이머리는 클러스터를 조율하고, 코어 노드는 **HDFS 데이터 블록을 보관**하며, 태스크 노드는 계산만 합니다.
> Spot의 전제는 "언제든 회수될 수 있다"입니다. 코어 노드가 회수되면 그 위의 HDFS 블록이 사라져 복제 수준이 깨지고, 최악에는 잡 전체가 데이터 유실로 실패합니다. 반면 태스크 노드가 사라지면 그 노드가 맡던 계산만 다른 노드로 재시도되면 끝입니다.
> 즉 "Spot을 어디에 쓸 수 있는가"는 가격 문제가 아니라 **상태를 들고 있는가**의 문제입니다. 같은 기준이 ECS의 `FARGATE_SPOT`, EC2 Auto Scaling 혼합 인스턴스 정책에도 그대로 적용됩니다 — 상태 없는 계산 계층에 Spot을 붙이는 것이 일관된 패턴입니다.

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

## ⚠️ 흔한 함정 {#common-pitfalls}

1. **"Lambda로 15분 이상 작업을 처리한다."** → Lambda의 최대 실행 시간은 15분입니다. 초과 시 강제 종료됩니다. 장시간 배치 작업은 AWS Batch, 장기 실행 컨테이너는 ECS/Fargate를 사용합니다.
   *(원리: §4 본문 — Lambda의 최대 실행 시간은 15분으로 고정되어 있어, 이를 초과하는 작업은 강제 종료된다.)*

2. **"메모리를 늘려도 CPU는 그대로다."** → Lambda는 메모리와 CPU가 비례합니다. 메모리를 두 배 늘리면 vCPU도 비례해 증가합니다(1,769 MB에서 1 vCPU). 공식 문서가 메모리를 성능 제어의 **주된(principal) 손잡이**로 설명하는 이유입니다 — 단, CPU 병목을 넘어서면 이득이 줄어듭니다.
   *(원리: §4 — Lambda는 메모리 크기에 비례해 연산 용량이 결정되는 구조라 CPU가 독립 설정값으로 존재하지 않는다.)*

3. **"Fargate는 독립 서비스다."** → Fargate는 ECS 또는 EKS의 **시작 유형(실행 모드)**입니다. 독립적으로 사용하지 않으며, 오케스트레이터(ECS/EKS) 위에서 동작합니다.
   *(원리: §3 — 스케줄링 계층(ECS/EKS)과 인프라 계층(Fargate)이 분리된 구조이므로 Fargate는 오케스트레이터 없이 단독 존재가 불가하다.)*

4. **"ECS와 EKS는 같다."** → ECS는 AWS 독자 오케스트레이터, EKS는 관리형 Kubernetes입니다. 기존 Kubernetes 워크로드·도구 호환성이 필요하면 EKS, AWS 네이티브 스택으로 빠르게 시작하려면 ECS를 선택합니다.
   *(원리: §3 본문 — ECS는 AWS 독자 오케스트레이터, EKS는 Kubernetes 표준을 따라 멀티클라우드 이식성을 제공하며, 이 표준성 차이가 선택 기준이 된다.)*

5. **"콜드 스타트는 메모리를 늘리면 해결된다."** → 콜드 스타트는 컨테이너 초기화 지연이 원인입니다. 메모리 증가는 실행 속도를 높이지만 콜드 스타트를 없애지 않습니다. 근본 해결책은 **Provisioned Concurrency**입니다.
   *(원리: §4 본문 — 콜드 스타트의 원인은 실행 환경(컨테이너) 초기화 지연이며, 메모리 증가는 함수 실행 속도만 높이므로 초기화 자체를 없애지 않는다.)*

6. **"AWS Batch는 Lambda와 같은 이벤트 기반이다."** → AWS Batch는 Job 제출(API 호출·스케줄)로 트리거되는 **배치 오케스트레이터**입니다. 실행 시간 제한이 없고, 작업 완료 후 컴퓨팅 환경이 종료됩니다.
   *(원리: §5 — Batch는 Job Queue 버퍼링과 Compute Environment 탄력적 프로비저닝 구조로 설계되어 이벤트 즉시 응답이 아닌 배치 처리에 최적화돼 있다.)*

7. **"HPC에서 배치 그룹만 있으면 충분하다."** → 클러스터 배치 그룹은 물리적 배치를 보장하지만, 인터노드 초저지연 통신에는 **EFA**가 추가로 필요합니다. 공유 스토리지에는 **FSx for Lustre**를 함께 구성합니다.
   *(원리: §6 — 배치 그룹은 물리적 근접성을 제공하지만 OS 네트워크 스택 오버헤드는 줄이지 못하며, EFA의 OS-bypass로 커널 오버헤드를 제거해야 초저지연이 실현된다.)*

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

**Q5 (원리).** 왜 Lambda 함수의 전역 변수에 저장한 캐시나 상태는 다음 호출에서 반드시 사용할 수 있다고 보장되지 않나요?

<details><summary>정답 보기</summary>

Lambda의 실행 환경은 요청 처리 후 언제든 종료·재생성될 수 있습니다. 재생성된 환경은 이전 인스턴스와 다른 컨테이너이므로 전역 변수에 기록된 인메모리 상태를 이어받지 않습니다. 전역 변수 캐시가 유지되는 것은 동일 실행 환경이 재사용되는 "웜 인스턴스" 경우뿐이며, 이 재사용은 보장된 동작이 아니라 최적화 결과입니다.
</details>

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. (작성·대조: 2026-06-07 · 고도화 검수: 2026-06-12 · 출처 보강: 2026-08-06)

1. Amazon ECS — What is Amazon Elastic Container Service — https://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html
2. AWS Fargate — Architect for AWS Fargate for Amazon ECS — https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html
3. Amazon EKS — Simplify compute management with AWS Fargate — https://docs.aws.amazon.com/eks/latest/userguide/fargate.html
4. Amazon EKS — What is Amazon EKS — https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html
5. AWS Batch — What is AWS Batch — https://docs.aws.amazon.com/batch/latest/userguide/what-is-batch.html
6. AWS Lambda — Lambda quotas — https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-limits.html
7. AWS Lambda — Configure function memory — https://docs.aws.amazon.com/lambda/latest/dg/configuration-memory.html
8. AWS Lambda — Provisioned concurrency — https://docs.aws.amazon.com/lambda/latest/dg/provisioned-concurrency.html
9. EC2 배치 전략 상세 — https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/placement-strategies.html
10. Elastic Fabric Adapter — https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/efa.html
11. Amazon FSx for Lustre — https://docs.aws.amazon.com/fsx/latest/LustreGuide/what-is.html
12. SAA-C03 공식 시험 가이드 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
13. ECS 클러스터 오토스케일링(관리형 스케일링·`CapacityProviderReservation`) — https://docs.aws.amazon.com/AmazonECS/latest/developerguide/cluster-auto-scaling.html (갭 배치 B7b: 2026-10-21)
14. ECS Fargate 용량 공급자(FARGATE·FARGATE_SPOT·전략 제약) — https://docs.aws.amazon.com/AmazonECS/latest/developerguide/fargate-capacity-providers.html (갭 배치 B7b: 2026-10-21)
15. EKS 아키텍처 — 컴퓨트(노드) 유형 — https://docs.aws.amazon.com/eks/latest/userguide/eks-architecture.html (갭 배치 B7b: 2026-10-21)
16. ECS — 공유 서브넷·Local Zones·Wavelength Zones(Fargate 미지원) — https://docs.aws.amazon.com/AmazonECS/latest/developerguide/cluster-regions-zones.html (갭 배치 B7b: 2026-10-21)
17. Fargate 태스크 정의 차이 — 태스크 CPU·메모리 조합 — https://docs.aws.amazon.com/AmazonECS/latest/developerguide/fargate-tasks-services.html (갭 배치 B7b: 2026-10-21)
18. Lambda — 명령어 세트 아키텍처 선택(arm64 마이그레이션) — https://docs.aws.amazon.com/lambda/latest/dg/foundation-arch.html (갭 배치 B7b: 2026-10-21)
19. Lambda — SQS 이벤트 소스 매핑 스케일링 동작 — https://docs.aws.amazon.com/lambda/latest/dg/services-sqs-scaling.html (갭 배치 B7b: 2026-10-21)
20. Lambda — SQS 이벤트 소스 매핑 파라미터(`BatchSize`·`ProvisionedPollerConfig`) — https://docs.aws.amazon.com/lambda/latest/dg/services-sqs-parameters.html (갭 배치 B7b: 2026-10-21)
21. CloudFront 쿼터 — CloudFront Functions·Lambda@Edge — https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/cloudfront-limits.html (갭 배치 B7b: 2026-10-21)
22. CloudFront Functions 제약(런타임·본문·컴퓨팅 사용률) — https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/cloudfront-function-restrictions.html (갭 배치 B7b: 2026-10-21)
23. Lambda@Edge 제약(Include Body 크기 한도) — https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-at-edge-function-restrictions.html (갭 배치 B7b: 2026-10-21)
24. VPC를 Local Zone·Wavelength Zone·Outpost로 확장 — https://docs.aws.amazon.com/vpc/latest/userguide/Extend_VPCs.html (갭 배치 B7b: 2026-10-21)
25. Application Auto Scaling — CloudWatch 사전 정의 지표 — https://docs.aws.amazon.com/autoscaling/application/userguide/monitoring-cloudwatch.html (갭 배치 B7b: 2026-10-21)
26. ECS 서비스 대상 추적 조정 정책(동작 규칙) — https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service-autoscaling-targettracking.html (갭 배치 B7b: 2026-10-21)
27. SQS 큐 기반 ECS 서비스 조정(태스크당 백로그) — https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service-autoscaling-queue.html (갭 배치 B7b: 2026-10-21)
28. 분석 서비스 비용 최적화 — EMR 배포 네 가지 — https://docs.aws.amazon.com/whitepapers/latest/cost-modeling-data-lakes/cost-optimization-in-analytics-services.html (갭 배치 B7b: 2026-10-21)
29. EMR 인스턴스 유형 구성·Spot 베스트 프랙티스(태스크 노드) — https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-plan-instances-guidelines.html (갭 배치 B7b: 2026-10-21)

> 📝 **2026-10-21 보강 (갭 배치 B7b — Task 3.2)**: §3에 **ECS 용량 공급자·전략 제약·클러스터 관리형 스케일링**과 **EKS 컴퓨트 다섯 선택지**, Fargate의 **Local Zones·Wavelength·Outposts 미지원**을 추가했습니다(근거 13·14·15·16번). §4에 **Lambda 메모리 범위 128~10,240 MB·arm64 마이그레이션 절차·Fargate 태스크 CPU·메모리 조합표·SQS 이벤트 소스 매핑 스케일링**(5배치 시작 → 분당 +300 → 상한 1,250)을 추가했습니다(근거 17·18·19·20번). 새 절 **§7 엣지 컴퓨팅 · §8 컴퓨팅 스케일링 지표 · §9 EMR 배포 선택**을 원리 블록과 함께 넣었습니다(근거 21~29번).
>
> **쓰지 않은 것**: ① **CloudFront Functions의 "최대 실행 시간 1 ms"** — 현행 공식 쿼터 표에 그 항목이 없고, 실행 시간은 **컴퓨팅 사용률(0~100)**로만 측정하도록 서술돼 있어 밀리초 수치를 쓰지 않았습니다. ② **Lambda@Edge "뷰어 이벤트 5초 / 오리진 30초"** — 현행 쿼터 표는 **함수 타임아웃을 30초 하나**로 적고, 이벤트 유형으로 갈리는 항목은 생성 응답 크기(40 KB / 1 MB)뿐입니다. 널리 인용되는 5초 분기는 현행 문서에서 확인되지 않아 싣지 않았습니다. ③ **arm64의 가격-성능 우위 퍼센트** — 공식 Lambda 아키텍처 문서는 수치 대신 "x86_64와 성능을 비교하라"는 절차만 제시하므로 수치를 쓰지 않았습니다. ④ **Lambda 콜드 스타트 구간 수치**(`99-gaps` V-27)와 **AWS Batch 잡 타임아웃 상한**(V-23)은 공식 확인 전이라 비워 두었습니다. ⑤ **AWS Auto Scaling 조정 계획(scaling plans)의 현행 제공 상태**(V-22)도 확인되지 않아 Application Auto Scaling만 다뤘습니다.

> 📝 **2026-10-19 정정**: Lambda 메모리를 성능 튜닝의 "유일한" 손잡이로 적었던 표현을 공식 서술("Memory is the principal lever")에 맞춰 **주된 손잡이**로 고쳤습니다. 병목을 넘어서면 이득이 줄고 아키텍처·임시 스토리지도 영향을 주므로 변곡점은 Lambda Power Tuning으로 확인합니다(근거 7번).
