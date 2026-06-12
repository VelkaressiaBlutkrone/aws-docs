---
examGuideTaskId: saa-t2-2
certCode: SAA-C03
domain: 2
domainName: 복원력을 갖춘 아키텍처 설계
domainWeightPct: 26
title: 서버리스 패턴 — Lambda·API Gateway·Fargate·ECS/EKS
coversTasks:
  - "2.1"
sources:
  - title: AWS Lambda — 소개 (공식)
    url: https://docs.aws.amazon.com/lambda/latest/dg/welcome.html
  - title: Amazon API Gateway — 소개 (공식)
    url: https://docs.aws.amazon.com/apigateway/latest/developerguide/welcome.html
  - title: Amazon ECS — 소개 (공식)
    url: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html
  - title: AWS Fargate — 소개 (공식)
    url: https://docs.aws.amazon.com/AmazonECS/latest/userguide/what-is-fargate.html
  - title: SAA-C03 공식 시험 가이드 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
lastVerified: 2026-06-12
---

# 서버리스 패턴 — Lambda·API Gateway·Fargate·ECS/EKS

> **커버하는 공식 Task** — SAA-C03 · 도메인 2 「복원력을 갖춘 아키텍처 설계」(26%) · **Task 2.1 확장 가능하고 느슨하게 결합된 아키텍처 설계** (`saa-t2-2`)
> 이 문서는 위 한 Task에 1:1로 매핑됩니다. 서버리스와 컨테이너는 SAA에서 "운영 부담 최소 + 자동 확장"을 묻는 단골 주제입니다.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명할 수 있어야 합니다.

- [ ] **Lambda 이벤트 기반 모델** — 동기·비동기·스트림 호출 방식과 재시도·DLQ를 구분할 수 있다
- [ ] **Lambda 동시성** — Reserved Concurrency와 Provisioned Concurrency의 차이를 설명할 수 있다
- [ ] **Lambda 제한** — 최대 실행 시간(15분), 스테이트리스 특성, VPC 연결 조건을 안다
- [ ] **API Gateway 3종** — REST·HTTP·WebSocket API의 용도와 비용 차이를 선택 기준과 함께 설명할 수 있다
- [ ] **API Gateway 인증** — IAM·Cognito·Lambda Authorizer를 상황별로 선택할 수 있다
- [ ] **ECS vs EKS** — 두 컨테이너 오케스트레이터의 차이를 설명할 수 있다
- [ ] **EC2 시작 유형 vs Fargate** — 서버 관리 책임 소재를 기준으로 선택할 수 있다
- [ ] **선택 기준** — 서버리스(Lambda·Fargate) vs 컨테이너(ECS/EKS EC2) vs EC2를 요구사항에 따라 고를 수 있다

---

## 🎯 왜 중요한가

도메인 2(26%)에서 "확장 가능하고 느슨하게 결합된 아키텍처"를 묻는 문제의 상당수가 서버리스·컨테이너 선택 판단입니다. 시험은 구체적 시나리오를 주고 **운영 부담, 비용 모델, 실행 시간, 상태 관리** 조건에 맞는 컴퓨팅을 고르게 합니다.

핵심 대비 포인트는 세 가지입니다.

1. Lambda — 이벤트에 반응, 서버 없음, 15분 이하 단발 처리
2. Fargate — 컨테이너를 서버 없이 실행, 장시간·상태 유지 가능
3. ECS/EKS EC2 — 컨테이너지만 인프라 제어권이 필요할 때

셋 중 어느 것도 EC2 인스턴스를 직접 관리하지 않아도 되는 방향이 SAA의 "복원력 있는 아키텍처 설계" 핵심 방향입니다.

---

## 🔤 먼저 알아야 할 용어

이 문서를 읽는 데 필요한 기초 용어입니다. 이미 알면 건너뛰세요.

| 용어 | 영문 | 한 줄 풀이 |
|---|---|---|
| **서버리스** | Serverless | 서버 프로비저닝·관리 없이 코드·컨테이너를 실행하는 실행 모델 |
| **콜드 스타트** | Cold Start | Lambda 실행 환경이 처음 초기화될 때 발생하는 추가 지연 |
| **스테이트리스** | Stateless | 각 호출이 이전 호출의 메모리·상태를 공유하지 않는 설계 특성 |
| **오케스트레이터** | Orchestrator | 컨테이너의 배치·재시작·스케일링을 자동으로 관리하는 제어 레이어 |
| **이벤트 소스** | Event Source | Lambda를 트리거하는 발생원 — S3·SQS·API Gateway 등 |
| **ENI** | Elastic Network Interface | VPC 내 네트워크 인터페이스 — Lambda가 VPC 리소스에 접근할 때 생성 |
| **RDS Proxy** | RDS Proxy | Lambda↔RDS 간 커넥션 풀링 레이어 — 급증하는 연결 수를 흡수 |

---

## 📖 핵심 개념

### 1) AWS Lambda

> 공식 정의: "서버를 관리하지 않고 코드를 실행하는 컴퓨팅 서비스. 수요에 따라 자동 확장되며 사용한 만큼만 과금합니다."

Lambda는 **이벤트가 발생하면 코드를 실행**하는 서버리스 함수입니다. 서버·OS·런타임 관리는 AWS가 전담합니다.

**대표 이벤트 소스**

| 이벤트 소스 | 대표 예 |
|---|---|
| S3 | 객체 업로드 시 썸네일 생성·후처리 |
| DynamoDB Streams | 항목 변경 후속 처리 |
| SQS / Kinesis | 큐·스트림 메시지 소비 |
| SNS / EventBridge | 알림·이벤트 라우팅 |
| API Gateway | HTTP 요청 처리 |

**호출 방식 3종 (★ 재시도·실패 처리 차이)**

| 방식 | 대표 이벤트 소스 | 실패 처리 |
|---|---|---|
| **동기(Sync)** | API Gateway, SDK 직접 호출 | 호출자에게 즉시 에러 반환 |
| **비동기(Async)** | S3, SNS, EventBridge | 자동 재시도 2회 → DLQ 또는 Destinations |
| **스트림·큐 폴링** | SQS, Kinesis, DynamoDB Streams | 배치 폴링, 실패 시 재처리 또는 DLQ |

**동시성과 콜드 스타트**

| 개념 | 설명 |
|---|---|
| **Reserved Concurrency** | 함수별 동시 실행 상한을 예약. 초과 시 스로틀(429) |
| **Provisioned Concurrency** | 실행 환경을 미리 워밍업해 콜드 스타트 제거 |
| **콜드 스타트** | 새 실행 환경 초기화로 발생하는 첫 호출 지연 |

**실행 제한 및 기타 특성**

- 최대 실행 시간: **15분** (그 이상이면 Lambda 부적합)
- 메모리: 128 MB ~ 10,240 MB. 메모리 증가 시 CPU도 비례 증가
- 저장: `/tmp` 임시 디렉터리(함수 인스턴스 내에서만 유효)
- 레이어(Layers): 공통 라이브러리·의존성을 공유
- VPC 접근: ENI를 통해 VPC 내부 리소스(RDS 등) 접근 가능. 대량 동시 연결 시 RDS Proxy 권장
- **실행 역할(Execution Role)**: Lambda가 다른 AWS 서비스에 접근하기 위해 수임하는 IAM 역할. 함수 생성 시 반드시 지정

```
[이벤트 기반 예시]
S3 업로드 → (비동기) Lambda(이미지 리사이즈) → 결과 S3 저장
                      └ 실패 → DLQ(SQS)로 보관 → 재처리
```

> 🧠 원리: 왜 Lambda는 스테이트리스 설계를 강제할까요?
> 함수 인스턴스는 수요에 따라 수백 개가 동시에 생성·소멸되는데, 각 인스턴스가 로컬 상태를 가지면 어떤 인스턴스가 요청을 받느냐에 따라 결과가 달라집니다.
> 스테이트리스로 강제하면 모든 인스턴스가 동일하게 동작하므로, 오토스케일링이 호출자에게 투명하게 작동하고 인스턴스 수를 늘려도 정합성이 유지됩니다.
> 영속 상태가 필요한 경우 S3·DynamoDB·ElastiCache 같은 외부 저장소로 분리하면, 상태와 실행 로직의 수명 주기가 독립되어 실패·재시도 시에도 데이터 일관성을 확보할 수 있습니다.

---

### 2) Amazon API Gateway

> 공식 정의: "어떤 규모에서든 REST, HTTP, WebSocket API를 생성·게시·유지·모니터링·보안 처리하는 AWS 서비스."

API Gateway는 Lambda·백엔드 서비스 앞단의 **진입점(Front Door)**입니다. 라우팅·인증·스로틀링·캐싱을 중앙 관리합니다.

**API 유형 3종 비교 (★ 선택 기준)**

| 유형 | 특징 | 주요 용도 |
|---|---|---|
| **REST API** | 기능 풍부(캐싱·사용계획·요청 검증·WAF·CloudTrail 통합) | 세밀한 제어가 필요한 전통적 API |
| **HTTP API** | 더 저렴·단순·저지연. 기본 기능 위주 | 단순 Lambda 프록시, 비용 우선 |
| **WebSocket API** | 실시간 양방향(Full-duplex) 통신 | 채팅·실시간 알림·게임 |

**인증·인가 방식**

| 방식 | 설명 | 적합한 상황 |
|---|---|---|
| **IAM(SigV4)** | AWS 자격증명 서명 기반 | 서비스 간 호출, AWS 내부 |
| **Cognito 사용자 풀** | Cognito 로그인 토큰 검증 | 사용자 로그인 기반 앱 |
| **Lambda Authorizer** | 커스텀 토큰 검증 로직 함수 | JWT·OAuth 등 서드파티 토큰 |

**제어 기능**

| 기능 | 역할 |
|---|---|
| Throttling | 요청 속도 제한. 과부하·남용 방지 |
| Caching | 응답을 캐시해 백엔드 호출 감소 |
| Usage Plan + API Key | 클라이언트별 사용량 할당·과금 단위 |
| Stages | dev·prod 등 배포 단계 분리 |

```
[API Gateway 구성]
클라이언트 → API Gateway(인증·스로틀링·캐싱) → Lambda / HTTP 백엔드 / AWS 서비스
```

> 🧠 원리: 왜 Lambda 앞에 API Gateway 같은 진입점 레이어를 별도로 둘까요?
> Lambda 함수 URL로 직접 노출하면 스로틀링·인증·캐싱을 함수 코드나 별도 로직으로 구현해야 해, 비즈니스 로직과 인프라 관심사가 섞입니다.
> API Gateway가 인증·요청 검증·속도 제한을 중앙 처리하면 Lambda 함수는 순수한 비즈니스 로직만 담게 되고, 정책 변경 시 함수 코드를 건드리지 않아도 됩니다.
> 또한 스테이지(dev·prod) 분리와 사용 계획을 통해 동일 Lambda를 여러 클라이언트 계층에 다른 속도 제한으로 제공하는 유연성을 API 코드 변경 없이 얻을 수 있습니다.

---

### 3) 컨테이너 — ECS vs EKS, EC2 vs Fargate

컨테이너를 AWS에서 실행할 때 두 가지 축을 결정합니다.

- **오케스트레이터**: ECS(AWS 관리형) vs EKS(Kubernetes 관리형)
- **시작 유형(인프라)**: EC2(직접 관리) vs Fargate(서버리스)

**ECS vs EKS 비교**

| 항목 | Amazon ECS | Amazon EKS |
|---|---|---|
| 정의 | AWS 자체 완전 관리형 컨테이너 오케스트레이터 | AWS에서 실행하는 관리형 Kubernetes |
| 컨트롤 플레인 | AWS가 완전 관리 (추가 비용 없음) | AWS가 관리 (컨트롤 플레인 요금 발생) |
| 표준 | AWS 독자 방식 | Kubernetes 표준 API |
| 학습 곡선 | 낮음 | Kubernetes 지식 필요 |
| 적합한 상황 | AWS 통합 단순 컨테이너 워크로드 | Kubernetes 기반 멀티클라우드·기존 k8s 환경 |

**EC2 시작 유형 vs Fargate 비교**

| 항목 | EC2 시작 유형 | Fargate(서버리스) |
|---|---|---|
| 인프라 관리 | 직접(인스턴스 선택·패치·스케일링) | AWS가 전담 |
| 비용 모델 | EC2 인스턴스 과금 | vCPU·메모리 사용량 과금 |
| 제어 수준 | GPU·특수 인스턴스 등 세밀 제어 가능 | 제어 제한(OS 접근 불가) |
| 적합한 상황 | GPU 워크로드, 세밀한 인프라 제어 필요 | 서버 관리 최소화, 빠른 배포 |
| 격리 | 노드 공유 가능 | 태스크별 전용 커널·네트워크 인터페이스 |

> Fargate 공식 정의: "EC2 인스턴스나 클러스터를 관리하지 않고 컨테이너를 실행하는 기술. 서버 유형 선택, 클러스터 스케일 결정, 클러스터 패킹 최적화가 불필요합니다."

> 🧠 원리: 왜 Fargate는 오케스트레이터(ECS/EKS)와 인프라 레이어를 분리해 설계했을까요?
> 컨테이너 오케스트레이션(어떤 컨테이너를, 얼마나, 어떻게 배치할지)과 인프라 관리(서버 프로비저닝·패치·스케일링)는 책임 범위가 달라 함께 두면 어느 한쪽 변경이 다른 쪽에 영향을 줍니다.
> Fargate가 인프라 레이어를 가져가면 ECS/EKS는 오케스트레이션 로직에만 집중하고, 개발자는 EC2 인스턴스 유형·수량·패치 일정을 신경 쓰지 않아도 컨테이너를 배포할 수 있습니다.
> 이 분리로 EC2 시작 유형은 GPU·특수 인스턴스처럼 하드웨어 제어가 필요한 케이스를 그대로 커버하고, Fargate는 서버 관리를 원하지 않는 케이스를 담당해 단일 오케스트레이터에서 두 인프라 모델이 공존합니다.

---

### 4) 컴퓨팅 선택 기준 — Lambda vs Fargate vs ECS/EKS EC2 vs EC2

| 요구사항 | 권장 컴퓨팅 | 이유 |
|---|---|---|
| 이벤트에 반응, 15분 이하 단발 처리 | **Lambda** | 서버리스, 이벤트 트리거, 호출 기반 과금 |
| 15분 초과 또는 지속 실행 컨테이너 | **Fargate** | 서버 없이 장시간 컨테이너 실행 |
| Kubernetes 표준 필요 | **EKS** | k8s API 호환, 멀티클라우드 이식성 |
| GPU·특수 인스턴스 컨테이너 | **ECS/EKS EC2** | EC2 시작 유형으로 인스턴스 직접 선택 |
| OS·네트워크 완전 제어 필요 | **EC2** | 최고 수준의 인프라 제어 |

**Lambda vs Fargate 심층 비교**

| 항목 | Lambda | Fargate |
|---|---|---|
| 실행 모델 | 함수(Function), 이벤트 트리거 | 태스크(Task)/서비스, 지속 실행 가능 |
| 최대 실행 시간 | 15분 | 제한 없음 |
| 상태 유지 | 불가(스테이트리스) | 가능(EFS 마운트 등) |
| 과금 단위 | 호출 횟수 + 실행 ms | vCPU + 메모리 사용 시간 |
| 콜드 스타트 | 있음(Provisioned으로 완화) | 없음(컨테이너 이미지 풀 시간은 있음) |
| 패키지 방식 | 코드·ZIP·컨테이너 이미지 | 컨테이너 이미지 |
| 적합한 워크로드 | 간헐적 이벤트 처리, API 백엔드 | 장시간 배치, 마이크로서비스 |

> 🧠 원리: 왜 Lambda·Fargate·ECS EC2·EC2처럼 서버리스와 관리형 인프라 옵션을 별도로 유지할까요?
> 이벤트 기반 단발 처리는 ms 단위 호출당 과금이 최적이지만, 장시간 유지 프로세스는 인스턴스 비용 모델이 더 경제적입니다.
> 운영 부담을 완전히 위임(Fargate)할지, GPU처럼 특수 하드웨어를 직접 지정(EC2 시작 유형)할지는 같은 컨테이너 워크로드 안에서도 선택이 갈립니다.
> 하나의 서비스로 이 스펙트럼을 커버하려면 구성 복잡도가 폭발하므로, AWS는 책임 분리 수준을 축으로 서비스를 분화해 각 계층에서 최소 구성으로 최적 결과를 얻을 수 있게 합니다.

---

## ✍️ 시험 포인트

- **"S3 업로드 시 자동 처리"** → S3 이벤트 → Lambda(비동기 호출). 재시도 실패 시 DLQ 설정.
- **"콜드 스타트 지연 제거"** → Provisioned Concurrency. Reserved Concurrency는 상한만 예약할 뿐 워밍업 아님.
- **"15분 초과 작업"** → Lambda 부적합. Fargate 또는 AWS Batch.
- **"실시간 양방향 통신"** → API Gateway **WebSocket API**. REST API 폴링은 비효율.
- **"단순·저비용 Lambda 프록시"** → API Gateway **HTTP API**. REST API보다 저렴.
- **"캐싱·사용 계획·WAF 통합 필요"** → API Gateway **REST API**.
- **"커스텀 JWT 토큰 검증"** → API Gateway **Lambda Authorizer**.
- **"서버 없이 컨테이너 실행"** → Fargate. EC2 시작 유형은 인스턴스 직접 관리.
- **"Kubernetes 표준 유지"** → EKS. 기존 k8s 워크로드 이식 또는 멀티클라우드 시.
- **"Lambda → RDS 대량 동시 연결"** → RDS Proxy로 커넥션 풀 관리. Lambda는 연결이 급증하면 DB 커넥션을 소진할 수 있음.
- **"Lambda 실행 역할"** → Lambda가 S3·DynamoDB 등에 접근하려면 IAM 실행 역할이 필수. 액세스 키를 코드에 넣는 방법은 오답.

---

## ⚠️ 흔한 함정

1. **"Lambda는 15분 이상도 실행할 수 있다."** → 일반 Lambda 함수의 최대 실행 시간은 15분입니다. 이를 초과하는 워크로드는 Fargate, AWS Batch, Step Functions(Durable Lambda) 등을 사용해야 합니다.
   *(원리: §4 — Lambda는 단발 이벤트 처리에 최적화된 실행 모델이라 장시간 유지 프로세스는 Fargate·Batch 같은 다른 계층이 담당한다.)*

2. **"Reserved Concurrency를 설정하면 콜드 스타트가 없어진다."** → Reserved Concurrency는 동시 실행 상한을 예약하는 기능으로, 워밍업과 무관합니다. 콜드 스타트 제거는 Provisioned Concurrency를 사용해야 합니다.
   *(원리: §1 — 콜드 스타트는 실행 환경 초기화 지연이므로 환경을 미리 워밍업(Provisioned)해야 제거되고, 상한 예약(Reserved)과는 다른 축이다.)*

3. **"단순 Lambda 프록시에 REST API를 써야 한다."** → REST API는 캐싱·사용 계획·WAF 등 풍부한 기능을 제공하지만 더 비쌉니다. 단순 프록시라면 HTTP API가 더 저렴하고 지연도 낮습니다.
   *(원리: §2 — API Gateway 유형은 필요 기능과 비용의 트레이드오프로 선택하며, 기능을 쓰지 않는데 REST API를 고르면 비용만 증가한다.)*

4. **"Fargate를 쓰면 ECS가 필요 없다."** → Fargate는 ECS(또는 EKS)의 시작 유형입니다. ECS 없이 Fargate만 단독으로 존재하지 않습니다. ECS가 오케스트레이션을 담당하고, Fargate가 인프라(서버 없이 컨테이너 실행)를 담당합니다.
   *(원리: §3 — 오케스트레이터(ECS/EKS)와 인프라 레이어(Fargate/EC2)는 별도 책임이라 Fargate는 인프라 레이어이고 오케스트레이션은 여전히 ECS/EKS가 필요하다.)*

5. **"EKS는 ECS보다 항상 낫다."** → EKS는 Kubernetes 표준을 따르므로 학습 곡선이 있고 컨트롤 플레인 요금이 발생합니다. Kubernetes가 불필요한 단순 AWS 컨테이너 워크로드는 ECS가 더 단순하고 경제적입니다.
   *(원리: §4 — k8s 표준 이식성이 불필요하면 EKS의 추가 비용·복잡도를 감수할 이유가 없고, 서비스 선택은 요구사항 최소 충족 기준으로 한다.)*

6. **"Lambda는 VPC 내부 리소스에 접근할 수 없다."** → Lambda는 VPC 설정을 통해 ENI로 VPC 내부 리소스(RDS, ElastiCache 등)에 접근할 수 있습니다. 단, 외부 인터넷 접근이 필요하면 NAT Gateway 또는 VPC 엔드포인트가 추가로 필요합니다.
   *(원리: §1 — Lambda는 기본적으로 AWS 관리 VPC에서 실행되고, 고객 VPC 접근이 필요할 때만 ENI를 생성해 연결하는 opt-in 모델이다.)*

7. **"비동기 Lambda 실패는 그냥 두면 된다."** → 비동기 호출 실패 시 Lambda는 자동으로 2회 재시도합니다. 그래도 실패하면 이벤트가 소실되므로 반드시 DLQ(SQS) 또는 Destinations를 설정해야 합니다.
   *(원리: §1 — 비동기 호출은 호출자가 결과를 기다리지 않아 실패를 알 수 없으므로, DLQ/Destinations가 실패 이벤트를 보존하는 유일한 안전망이다.)*

---

## 🧪 자가 점검

> 아래는 학습용 자가 점검입니다. (정식 검증 문항은 별도 문항 파일 참조)

**Q1.** 사용자가 S3에 파일을 업로드하면 자동으로 이미지를 리사이즈해야 합니다. 처리 실패 시 이벤트를 보존해야 합니다. 어떻게 설계하나요?

<details><summary>정답 보기</summary>

S3 이벤트를 Lambda에 연결합니다(비동기 호출). Lambda 함수에 DLQ(SQS 큐)를 설정합니다. S3 → Lambda 호출은 비동기이므로 실패 시 Lambda가 자동으로 2회 재시도하고, 그래도 실패하면 이벤트를 DLQ에 보존합니다. 이후 DLQ의 메시지를 재처리하거나 알림을 설정할 수 있습니다.
</details>

**Q2.** Lambda 함수가 처음 호출될 때 지연이 발생합니다. 지연을 제거하려면 어떻게 해야 하나요?

<details><summary>정답 보기</summary>

Provisioned Concurrency를 설정합니다. Lambda 실행 환경을 미리 초기화(워밍업)해 두어 콜드 스타트 없이 즉시 요청을 처리합니다. Reserved Concurrency는 동시 실행 상한만 예약할 뿐 콜드 스타트를 제거하지 않습니다.
</details>

**Q3.** 채팅 기능이 필요한 앱에서 API Gateway를 사용하려 합니다. 어떤 API 유형을 선택해야 하나요?

<details><summary>정답 보기</summary>

WebSocket API를 선택합니다. WebSocket API는 클라이언트와 서버 간 실시간 양방향(Full-duplex) 통신을 지원합니다. REST API나 HTTP API는 요청-응답(단방향) 모델이므로 채팅처럼 서버가 먼저 메시지를 Push해야 하는 시나리오에 부적합합니다.
</details>

**Q4.** 한 팀은 컨테이너 기반 마이크로서비스를 배포하려 하는데, 서버 관리 없이 30분 이상 실행되는 배치 작업도 포함됩니다. 가장 적합한 선택은?

<details><summary>정답 보기</summary>

ECS + Fargate 시작 유형을 선택합니다. Fargate는 EC2 인스턴스 없이 컨테이너를 실행하며, 실행 시간 제한이 없어 장시간 배치 작업도 처리할 수 있습니다. Lambda는 최대 15분 제한이 있어 부적합합니다. 서버 관리가 불필요하므로 EC2 시작 유형보다 Fargate가 적합합니다.
</details>

**Q5 (원리).** 왜 Lambda를 RDS에 직접 연결하면 위험할까요?

<details><summary>정답 보기</summary>

**Lambda는 동시 호출마다 새 DB 커넥션을 생성하기 때문입니다.** RDS는 최대 동시 커넥션 수가 인스턴스 메모리에 비례해 고정돼 있습니다. Lambda가 트래픽 급증 시 수백 개 인스턴스로 확장되면, 각 인스턴스가 독립적으로 커넥션을 열어 DB의 커넥션 한도를 순식간에 소진합니다. RDS Proxy는 커넥션 풀을 중간에서 관리해 다수의 Lambda 인스턴스가 소수의 실제 DB 커넥션을 공유하게 하므로, Lambda의 수평 확장과 RDS의 커넥션 한도 사이의 구조적 불일치를 해소합니다.
</details>

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. (작성·대조: 2026-06-07 · 고도화 검수: 2026-06-12)

1. AWS Lambda — 소개 — https://docs.aws.amazon.com/lambda/latest/dg/welcome.html
2. Amazon API Gateway — 소개 — https://docs.aws.amazon.com/apigateway/latest/developerguide/welcome.html
3. Amazon ECS — 소개 — https://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html
4. AWS Fargate — 소개 — https://docs.aws.amazon.com/AmazonECS/latest/userguide/what-is-fargate.html
5. SAA-C03 공식 시험 가이드 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
