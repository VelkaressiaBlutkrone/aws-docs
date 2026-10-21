---
examGuideTaskId: saa-t2-3
certCode: SAA-C03
domain: 2
domainName: 복원력을 갖춘 아키텍처 설계
domainWeightPct: 26
title: ELB + Auto Scaling — 탄력적 확장 설계
coversTasks:
  - "2.1"
  - "2.2"
sources:
  - title: Gateway Load Balancer — 소개(L3·모든 IP 패킷) (공식)
    url: https://docs.aws.amazon.com/elasticloadbalancing/latest/gateway/introduction.html
  - title: Classic Load Balancer — 소개(이전 세대) (공식)
    url: https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/introduction.html
  - title: Elastic Load Balancing — 개요 (공식)
    url: https://docs.aws.amazon.com/elasticloadbalancing/latest/userguide/what-is-load-balancing.html
  - title: Application Load Balancer — 소개 (공식)
    url: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html
  - title: Network Load Balancer — 소개 (공식)
    url: https://docs.aws.amazon.com/elasticloadbalancing/latest/network/introduction.html
  - title: Amazon EC2 Auto Scaling — 개요 (공식)
    url: https://docs.aws.amazon.com/autoscaling/ec2/userguide/what-is-amazon-ec2-auto-scaling.html
  - title: SAA-C03 공식 시험 가이드 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
  - title: ASG 헬스 체크 유예 기간 — 콘솔 300초·CLI 0초 (공식)
    url: https://docs.aws.amazon.com/autoscaling/ec2/userguide/health-check-grace-period.html
  - title: ASG 동적 조정 — 복수 정책은 큰 용량 우선 (공식)
    url: https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-scale-based-on-demand.html
  - title: ASG 조정 쿨다운 — 기본 300초 (공식)
    url: https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-scaling-cooldowns.html
  - title: ASG 웜 풀 — 부팅이 긴 앱의 지연 줄이기 (공식)
    url: https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-warm-pools.html
  - title: 인스턴스 새로 고침 동작·제한 (공식)
    url: https://docs.aws.amazon.com/autoscaling/ec2/userguide/instance-refresh-overview.html
  - title: 인스턴스 유지관리 정책 (공식)
    url: https://docs.aws.amazon.com/autoscaling/ec2/userguide/instance-maintenance-policy-overview-and-considerations.html
  - title: LifecycleHook API — GlobalTimeout·HeartbeatTimeout (공식)
    url: https://docs.aws.amazon.com/autoscaling/ec2/APIReference/API_LifecycleHook.html
  - title: 불변 인프라로 배포 — Well-Architected REL08-BP04 (공식)
    url: https://docs.aws.amazon.com/wellarchitected/2022-03-31/framework/rel_tracking_change_management_immutable_infrastructure.html
  - title: EC2 자동 인스턴스 복구 — 보존·상실 항목 (공식)
    url: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-recover.html
lastVerified: 2026-10-21
---

# ELB + Auto Scaling — 탄력적 확장 설계

> **커버하는 공식 Task** — SAA-C03 · 도메인 2 「복원력을 갖춘 아키텍처 설계」(26%) · **Task 2.1 확장 가능 아키텍처 설계 + Task 2.2 고가용성 아키텍처 설계** (`saa-t2-3`)
> 이 문서는 위 두 Task에 매핑됩니다. 도메인 2는 시험 비중 2위(26%) — ELB와 ASG는 그 핵심 설계 도구입니다.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명할 수 있어야 합니다. (공식 시험 가이드 Task 2.1·2.2의 Skill 항목 기반)

- [ ] **ELB 종류 선택** — ALB(L7), NLB(L4), GWLB, CLB 각각의 적합 시나리오를 설명할 수 있다
- [ ] **ALB 구성 요소** — 리스너·리스너 규칙·대상 그룹·헬스 체크의 관계를 그릴 수 있다
- [ ] **교차 영역 부하 분산** — 활성화 시 트래픽 분배 방식이 어떻게 달라지는지 설명할 수 있다
- [ ] **고정 세션** — 어떤 계층에서 작동하고 어느 LB에서 지원되는지 안다
- [ ] **ASG 구성 요소** — 시작 템플릿·원하는/최소/최대 용량·헬스 체크 교체의 역할을 설명할 수 있다
- [ ] **조정 정책 4종** — 대상 추적·단계·예약·예측 정책을 시나리오별로 선택할 수 있다
- [ ] **수명 주기 훅** — 인스턴스 시작·종료 시 사용자 정의 작업을 삽입하는 원리를 안다
- [ ] **ELB + ASG 고가용성 패턴** — Route 53 → ALB → ASG(멀티 AZ) → RDS Multi-AZ 조합을 설명할 수 있다

---

## 🎯 왜 중요한가

- 도메인 2(26%)는 "트래픽이 늘어도, 인스턴스가 죽어도 서비스가 살아 있어야 한다"는 복원력 질문의 본고장입니다.
- 시험은 "갑자기 트래픽 10배, 비용 효율적으로"·"AZ 하나가 다운돼도 서비스 유지"·"EC2 장애 자동 복구" 같은 시나리오를 주고 **올바른 ELB 유형·ASG 정책·조합 설계**를 고르게 합니다.
- CLF에서 "로드밸런서가 트래픽을 분산한다"는 수준을 배웠다면, SAA는 **어떤 LB를 언제 쓰는지, ASG를 어떻게 연결해 자가 복구까지 구현하는지**를 묻습니다.
- ELB와 ASG는 단독이 아니라 항상 함께 묶어서 설계합니다. 이 조합이 AWS 고가용성 아키텍처의 표준 패턴입니다.

---

## 🔤 먼저 알아야 할 용어

이 문서를 읽는 데 필요한 기초 용어입니다. 이미 알면 건너뛰세요.

| 용어 | 영문 | 한 줄 풀이 |
|---|---|---|
| **로드밸런서** | Load Balancer | 수신 트래픽을 여러 대상에 분산해 단일 장애점을 제거하는 중간 레이어 |
| **대상 그룹** | Target Group | ELB가 트래픽을 보내는 대상 묶음 — EC2·IP·Lambda 등록 가능, 헬스 체크 단위 |
| **리스너** | Listener | 로드밸런서가 클라이언트 연결을 받을 포트·프로토콜을 정의하는 규칙 |
| **헬스 체크** | Health Check | 대상의 응답 상태를 주기적으로 확인해 비정상 대상을 트래픽 풀에서 제외 |
| **교차 영역 분산** | Cross-Zone LB | 로드밸런서 노드가 다른 AZ의 대상에도 트래픽을 균등 분배하는 설정 |
| **고정 세션** | Sticky Session | 동일 클라이언트 요청을 수명 동안 같은 대상으로 라우팅하는 쿠키 기반 기법 |
| **시작 템플릿** | Launch Template | ASG가 새 인스턴스를 만들 때 참조하는 AMI·유형·보안그룹 등 구성 청사진 |
| **수명 주기 훅** | Lifecycle Hook | ASG가 인스턴스 시작·종료 직전에 사용자 정의 작업을 삽입할 수 있는 대기 구간 |
| **자가 복구** | Self-healing | 비정상 인스턴스를 ASG가 자동 종료·재생성해 서비스 용량을 유지하는 동작 |

---

## 📖 핵심 개념 {#core-concepts}

### 1) Elastic Load Balancing — 종류와 선택 {#elb-types}

> 공식 정의: **"수신 트래픽을 여러 대상(EC2 인스턴스·컨테이너·IP 주소)에 자동으로 분산하고, 헬스 체크를 통해 정상 대상에만 트래픽을 보내는 관리형 서비스."**

ELB는 현재 세대 3종(ALB·NLB·GWLB)과 레거시 CLB로 구성됩니다.

| 유형 | OSI 계층 | 주요 프로토콜 | 대표 특징 | 대표 사용 사례 |
|---|---|---|---|---|
| **ALB** (Application LB) | L7 | HTTP / HTTPS / gRPC | 경로·호스트 기반 라우팅, WAF 연동, Lambda 대상, 컨테이너 친화 | 웹 앱, 마이크로서비스, API Gateway 대체 |
| **NLB** (Network LB) | L4 | TCP / UDP / TLS / QUIC | 초고성능(초당 수백만 요청), AZ당 **고정 Elastic IP**, 초저지연 | 게임 서버, 금융 거래, VoIP, IoT |
| **GWLB** (Gateway LB) | L3 | GENEVE(6081) | **모든 IP 패킷·모든 포트**를 수신해 서드파티 보안 어플라이언스(방화벽·IDS) 인라인 삽입 | 트래픽 검사·필터링 파이프라인 |
| **CLB** (Classic LB) | L4/L7 | HTTP / HTTPS / TCP | **이전 세대** LB. AWS가 현행 세대로 마이그레이션 권고 | 기존에 CLB로 구성된 환경의 유지보수 |

> **선택 기준**: "HTTP 경로·호스트별 라우팅이 필요하다" → ALB. "UDP·고정 IP·초저지연이 필요하다" → NLB. "서드파티 방화벽을 모든 트래픽에 인라인으로 적용해야 한다" → GWLB.

> 🧠 원리: 왜 ELB는 단일 서비스로 통합하지 않고 OSI 계층별로 ALB·NLB·GWLB를 분리했을까요?
> L7 파싱(HTTP 헤더·경로 분석)은 L4 포워딩(패킷 헤더만 확인)보다 CPU 비용이 크므로, 두 기능을 하나로 묶으면 초저지연·초고성능이 필요한 L4 워크로드에 불필요한 오버헤드가 생깁니다.
> 계층별 분리 덕분에 ALB는 콘텐츠 기반 라우팅에, NLB는 수백만 TPS 처리에 각각 최적화된 내부 구현을 유지할 수 있습니다.
> GWLB는 보안 어플라이언스 인라인 삽입이라는 별도 목적을 위해 GENEVE 프로토콜을 사용하므로, 이 세 서비스를 합치면 어떤 계층도 제 기능을 발휘하기 어렵습니다.

### 2) ALB 핵심 구성 요소 {#alb-components}

ALB는 **리스너 → 리스너 규칙 → 대상 그룹** 계층으로 동작합니다.

| 구성 요소 | 역할 |
|---|---|
| **리스너(Listener)** | 클라이언트 연결 요청을 받을 포트·프로토콜 설정. 리스너당 기본 규칙 1개 필수 |
| **리스너 규칙(Listener Rule)** | 조건(경로·호스트·헤더·쿼리스트링·소스 IP)에 따라 요청을 대상 그룹으로 라우팅. 우선순위 순서로 평가 |
| **대상 그룹(Target Group)** | 실제 트래픽을 받을 대상 묶음. EC2 인스턴스·IP 주소·Lambda 함수 등록 가능 |
| **헬스 체크(Health Check)** | 대상 그룹 단위로 설정. 비정상 대상은 자동 제외, 회복 시 자동 복귀 |

ALB의 경로 기반 라우팅 예:

```
리스너: HTTPS :443
  규칙 1) 경로=/api/*   → 대상그룹-API   (EC2 백엔드)
  규칙 2) 경로=/images/* → 대상그룹-정적  (EC2 또는 S3)
  기본  ) 나머지        → 대상그룹-웹    (EC2 프런트엔드)
```

> 🧠 원리: 왜 ALB는 리스너 → 리스너 규칙 → 대상 그룹의 3계층 구조를 가질까요?
> 리스너 하나에 모든 라우팅 로직을 평탄하게 넣으면, 조건이 늘어날수록 순서 충돌과 변경 범위가 커져 관리하기 어렵습니다.
> 규칙(우선순위 평가)과 대상 그룹(트래픽 실체)을 분리하면, 동일한 대상 그룹을 여러 규칙에서 재사용하거나 대상만 교체해도 라우팅 로직을 건드리지 않아도 됩니다.
> 헬스 체크가 대상 그룹 단위로 작동하므로, 특정 서비스 대상이 비정상이어도 다른 경로의 대상 그룹은 독립 운영됩니다.

### 3) NLB 핵심 특성 {#nlb-features}

NLB는 L4에서 동작하며 ALB가 할 수 없는 두 가지 시나리오에서 선택합니다.

| 특성 | 설명 |
|---|---|
| **고정 IP** | AZ당 하나의 로드밸런서 노드 → Elastic IP 할당 가능. 방화벽 화이트리스트에 IP를 등록해야 하는 경우 필수 |
| **초고성능** | 초당 수백만 요청 처리(공식 서술 "millions of requests per second"). 구체적 밀리초 수치는 공식 문서에 없음 |
| **TCP 연결 유지** | 개별 TCP 연결은 수명 동안 동일한 대상으로 라우팅(플로우 해시) |
| **교차 영역 부하 분산** | 기본 비활성화(ALB와 다름). 활성화 시 추가 데이터 전송 비용 발생 가능 |

> 🧠 원리: 왜 NLB는 L4에서 고정 IP를 제공할 수 있지만 ALB는 그렇지 않을까요?
> ALB는 내부적으로 L7 파싱을 위해 여러 노드가 동적으로 확장·축소되며 IP가 바뀌는 구조여서, 단일 고정 IP를 노출하면 스케일 아웃 시 그 IP 뒤 처리 용량이 제한됩니다.
> NLB는 AZ당 하나의 로드밸런서 노드를 두고 그 노드에 Elastic IP를 고정 할당하는 방식이라, 클라이언트 입장에서 IP가 변하지 않으면서도 노드 내부에서 대상들에게 분산합니다.
> 이 차이가 "방화벽 화이트리스트에 IP 등록이 필요한 금융·IoT 환경"에서 NLB를 선택하는 결정적 이유입니다.

### 4) 교차 영역 부하 분산 (Cross-Zone Load Balancing) {#cross-zone}

| 설정 | 동작 |
|---|---|
| **비활성화(기본 — NLB·GWLB)** | 각 로드밸런서 노드는 자신이 속한 AZ의 대상에만 트래픽 분산 |
| **활성화(기본 — ALB)** | 각 로드밸런서 노드가 모든 AZ의 정상 대상에 균등 분산 |

교차 영역 부하 분산이 중요한 이유: AZ별 인스턴스 수가 다를 때(예: AZ-a에 2대, AZ-b에 8대) 비활성화 상태면 AZ-a의 인스턴스 2대가 전체 트래픽의 50%를 받아 과부하가 발생합니다. 활성화 시 10대 전체에 10%씩 균등 분산됩니다.

> ALB는 교차 영역 부하 분산이 **기본 활성화**되어 있으며 추가 요금이 없습니다. NLB와 GWLB는 기본 비활성화이며, 활성화 시 AZ 간 데이터 전송 요금이 발생할 수 있습니다.

> 🧠 원리: 왜 ALB는 교차 영역 분산이 기본 활성화이고 NLB는 기본 비활성화일까요?
> ALB는 HTTP 연결을 LB 노드에서 종료하고 새 연결로 대상에 전달하므로, AZ를 넘어 대상을 선택해도 추가 비용이 내부에서 흡수됩니다.
> NLB는 TCP 연결을 종단 간 유지(passthrough)하는 방식이라, AZ를 넘는 트래픽이 실제 AZ 간 데이터 전송으로 과금되어 비용에 직접 영향을 줍니다.
> 따라서 NLB에서는 AZ별 대상 수를 의도적으로 균등하게 배치해 교차 분산 없이도 균형을 맞추는 설계가 비용 절감에 유리합니다.

### 5) 고정 세션 (Sticky Session) {#sticky-sessions}

고정 세션(Stickiness)은 동일한 클라이언트의 요청을 수명 동안 동일한 대상으로 라우팅합니다.

| 항목 | 내용 |
|---|---|
| **지원 유형** | ALB(쿠키 기반), NLB(대상 그룹 stickiness 선택 지원), CLB |
| **ALB 구현 방식** | 쿠키 기반. LB 생성 쿠키(`AWSALB`) 또는 애플리케이션 쿠키 선택 |
| **주의사항** | 고정 세션 활성화 시 대상 간 부하 불균형 발생 가능. 세션리스 아키텍처(ElastiCache 세션 외부화)가 권장 |

> 🧠 원리: 왜 고정 세션은 가용성 관점에서 안티패턴으로 분류될까요?
> 특정 인스턴스에 세션이 고정되면, 그 인스턴스에 트래픽이 몰려 다른 인스턴스는 유휴 상태가 되어 ASG의 균등 분산 효과가 희석됩니다.
> 해당 인스턴스가 장애로 교체되면 그 인스턴스에 고정됐던 세션이 소실돼 사용자 경험이 단절됩니다.
> ElastiCache 같은 외부 세션 저장소를 쓰면 어떤 인스턴스도 요청을 처리할 수 있어, 고정 세션 없이도 세션 연속성이 유지되고 ASG 스케일 인·아웃이 세션 손실 없이 가능합니다.

### 6) Auto Scaling Group (ASG) — 구성 요소 {#asg-components}

> 공식 정의: **"EC2 인스턴스 모음으로, 올바른 수의 인스턴스를 유지하고 부하 변화에 따라 자동으로 늘리거나 줄입니다."**

| 구성 요소 | 역할 |
|---|---|
| **시작 템플릿(Launch Template)** | 새 인스턴스 설정 청사진(AMI·인스턴스 유형·보안 그룹·키 페어·사용자 데이터). 버전 관리 지원. 시작 구성(Launch Configuration)은 레거시 |
| **원하는 용량(Desired Capacity)** | ASG가 유지하려는 인스턴스 수. 조정 정책이 이 값을 변경함 |
| **최소 용량(Min)** | ASG가 절대로 내려가지 않는 하한선 |
| **최대 용량(Max)** | ASG가 절대로 넘지 않는 상한선 |
| **헬스 체크** | EC2 상태 체크(기본) + ELB 헬스 체크(선택) 결합. 비정상 인스턴스 자동 종료 후 교체 → 자가 복구(Self-healing) |

ASG + ALB 연동 흐름:

```
Route 53 (DNS)
     |
    ALB (리스너 규칙)
     |
대상 그룹 ←── ASG 자동 등록/해제
     |
EC2  EC2  EC2   ← 시작 템플릿 기반 자동 생성
(AZ-a)  (AZ-b)  ← 멀티 AZ 분산
```

ASG에 ELB를 연결하면 인스턴스가 시작될 때 자동으로 대상 그룹에 등록되고, 종료될 때 자동으로 해제됩니다.

> 🧠 원리: 왜 ASG는 최소·원하는·최대 용량이라는 세 숫자를 별도로 관리할까요?
> 하한(Min)은 트래픽이 없어도 절대 내려가지 않는 가용성 보장선이고, 상한(Max)은 비용 폭발을 막는 지출 상한선입니다.
> 원하는 용량(Desired)은 이 두 경계 안에서 조정 정책이 실시간으로 움직이는 목표값으로, 현재 부하에 맞는 인스턴스 수를 나타냅니다.
> 세 값을 분리함으로써 비용 통제(Max)·가용성 보장(Min)·탄력적 조정(Desired)이라는 세 관심사를 독립적으로 설정할 수 있습니다.

### 7) ASG 조정 정책 4종 {#asg-scaling-policies}

| 정책 | 트리거 | 동작 방식 | 권장 시나리오 |
|---|---|---|---|
| **대상 추적(Target Tracking)** | CloudWatch 지표(CPU 사용률·요청 수 등)가 목표값에서 벗어남 | ASG가 목표값 유지를 위해 용량을 자동 계산·조정. 설정이 단순 | **권장 기본값**. 예: "CPU 50% 유지" |
| **단계(Step) / 단순(Simple)** | CloudWatch 경보 임계값 초과 | 임계값 구간별로 다른 크기로 증감. Step이 Simple보다 세밀 | 세밀한 단계별 제어가 필요할 때 |
| **예약(Scheduled)** | 지정한 날짜·시간(cron) | 예측 가능한 트래픽 패턴에 맞게 용량을 사전 설정 | 매일 오전 9시 트래픽 급증, 주말 축소 등 |
| **예측(Predictive)** | ML이 과거 패턴 분석해 미래 부하 예측 | 부하가 도달하기 전 선제적으로 용량 확장 | 주기적 패턴이 있는 트래픽, 워밍업 시간이 긴 애플리케이션 |

> **대상 추적이 기본 권장**인 이유: 목표 지표 하나만 설정하면 ASG가 스케일 아웃·인 모두를 알아서 처리합니다. 임계값과 증감 단계를 별도로 관리할 필요가 없습니다.

> 🧠 원리: 왜 대상 추적 정책은 단계·단순 정책보다 운영 부담이 적을까요?
> 단계·단순 정책은 임계값 구간과 증감 단위를 사전에 수동 정의해야 하므로, 트래픽 패턴이 바뀌면 정책을 다시 튜닝해야 합니다.
> 대상 추적은 ASG가 목표 지표와 현재값의 차이를 계산해 필요한 인스턴스 수를 자동으로 도출하기 때문에, 사람이 "얼마를 늘릴지"를 결정할 필요가 없습니다.
> 예측 정책은 과거 데이터를 ML로 분석해 부하 도달 전에 미리 확장하므로, 워밍업 시간이 긴 애플리케이션에서 스케일 아웃 지연으로 인한 응답 저하를 선제적으로 방지합니다.

### 8) 수명 주기 훅 (Lifecycle Hooks) {#lifecycle-hooks}

수명 주기 훅은 인스턴스 시작·종료 과정에 사용자 정의 작업을 삽입합니다.

```
[시작 훅]
인스턴스 시작 요청
    → Pending:Wait  ← 훅 실행 구간 (예: 소프트웨어 설치, 설정 주입)
    → Pending:Proceed
    → InService (ELB 대상 그룹 등록, 트래픽 수신 시작)

[종료 훅]
인스턴스 종료 요청
    → Terminating:Wait  ← 훅 실행 구간 (예: 로그 수집, 상태 저장, 연결 드레이닝)
    → Terminating:Proceed
    → Terminated
```

| 항목 | 내용 |
|---|---|
| **시작 훅** | 인스턴스가 트래픽을 받기 전 초기화 작업. 예: 설정 파일 다운로드, 에이전트 설치 |
| **종료 훅** | 인스턴스가 실제 종료되기 전 정리 작업. 예: 세션 저장, 로그 플러시, 알림 발송 |
| **대기 시간** | `HeartbeatTimeout` 기본 **3,600초(1시간)**, 설정 범위 **30~7,200초**. 작업 완료 후 `CONTINUE` 또는 `ABANDON` 신호를 보내야 다음 단계 진행 |
| **최대 대기(`GlobalTimeout`)** | **172,800초(48시간) 또는 `HeartbeatTimeout`의 100배 중 더 작은 값**. 기본 1시간이면 100배가 360,000초라 48시간이 상한이지만, `HeartbeatTimeout`을 줄이면 상한도 함께 줄어듭니다 |
| **타임아웃 시 동작** | `DefaultResult`에 지정한 값(`CONTINUE` \| `ABANDON`)을 수행. `RecordLifecycleActionHeartbeat` API로 타임아웃을 늦출 수 있습니다 |
| **연동** | EventBridge 이벤트, SQS 메시지, SNS 알림으로 훅 이벤트를 수신해 Lambda 등을 트리거 |

> 🧠 원리: 왜 수명 주기 훅은 ASG 외부에서 완료 신호(`CONTINUE`/`ABANDON`)를 받기 전까지 대기할까요?
> ASG는 인스턴스가 준비됐는지 직접 판단할 수 없어, 외부 스크립트나 Lambda가 초기화 작업을 완료했음을 알릴 방법이 필요합니다.
> 대기 상태(`Pending:Wait` / `Terminating:Wait`)를 두면 초기화·정리 작업이 완료되기 전에 ELB가 트래픽을 보내거나 인스턴스가 강제 종료되는 경쟁 조건을 방지할 수 있습니다.
> `ABANDON` 신호는 초기화 실패 시 해당 인스턴스를 교체 흐름으로 넘겨 불완전하게 준비된 인스턴스가 트래픽을 받지 않도록 합니다.

---

### 9) ASG 운영 세부 — 타이밍 설정과 교체 동작 {#asg-operations}

ASG는 "용량을 정하는 것"이 아니라 **언제 판단하고 얼마를 기다릴지**가 실제 동작을 가릅니다.

| 설정 | 값·동작 |
|---|---|
| **헬스 체크 유예 기간** | ⚠️ **기본값이 생성 경로에 따라 갈립니다** — **콘솔 300초 / AWS CLI·SDK 0초**(0은 유예 비활성). 새로 시작된 인스턴스가 ELB 헬스 체크를 즉시 통과하지 못해 불필요하게 종료되는 것을 막습니다 |
| 유예 적용 대상 | 새로 시작된 인스턴스 · standby에서 복귀한 인스턴스 · 수동으로 연결(attach)한 인스턴스 |
| ⚠️ 유예 중 예외 | 유예 기간 중이라도 인스턴스가 EC2 **`running` 상태가 아니면 즉시 `Unhealthy`로 표시하고 교체**합니다(예: 인스턴스를 중지하면 바로 교체) |
| **기본 쿨다운** | **300초** — 단순 조정 정책이 쓰는 기본값. 정책별 쿨다운을 지정하면 기본값을 덮어씁니다 |
| **기본 인스턴스 워밍업** | 인스턴스가 `InService`에 도달한 뒤 자원 사용이 안정되는 시간. **워밍업이 끝나기 전에는 집계 CloudWatch 지표에 포함되지 않습니다** — 그래서 동적 조정이 "아직 몸을 안 푼" 인스턴스를 세어 과소 확장하는 일을 막습니다 |

**축소 정책의 쿨다운은 따로 줄이는 것이 보통입니다** — 종료는 시작보다 훨씬 빠른 작업이라 기본 300초가 너무 길고, 축소 정책에 더 짧은 값을 주면 더 빨리 줄여 비용을 아낄 수 있습니다.

**무엇을 보고 조정하나 — 사전 정의 지표 네 가지 (★ 시험 포인트)**

대상 추적 조정 정책은 **사전 정의 지표** 또는 **사용자 지정 지표** 중 하나를 씁니다. 사전 정의 지표는 네 가지뿐입니다.

| 사전 정의 지표 | 보는 값 |
|---|---|
| `ASGAverageCPUUtilization` | Auto Scaling 그룹의 평균 CPU 사용률 |
| `ASGAverageNetworkIn` | 그룹 전체 네트워크 인터페이스가 **받은** 평균 바이트 수 |
| `ASGAverageNetworkOut` | 그룹 전체 네트워크 인터페이스가 **보낸** 평균 바이트 수 |
| `ALBRequestCountPerTarget` | 그룹의 **대상(target)당** Application Load Balancer 평균 요청 수 |

- ⚠️ `ALBRequestCountPerTarget`을 쓸 때는 **`ResourceLabel`을 함께 지정**해야 합니다(어느 로드 밸런서·대상 그룹인지 지목하는 값).
- ⚠️ **메모리 사용률은 사전 정의 지표에 없습니다.** 메모리로 조정하려면 CloudWatch 에이전트로 지표를 올린 뒤 **사용자 지정 지표**로 지정해야 합니다.
- 지표는 **1분 이하 간격**을 권장합니다. EC2 지표는 기본이 5분 간격이므로, CPU 같은 사전 정의 지표를 쓸 때는 **상세 모니터링을 켜서 1분**으로 내리는 것이 권장 사항입니다. 더 짧은 주기가 필요하면 **고해상도 지표**를 사용자 지정 지표로 쓸 수 있습니다.

**사용자 지정 지표의 정석 — 인스턴스당 백로그 (SQS 큐)**

큐 길이로 조정하려 할 때 `ApproximateNumberOfMessages`를 **그대로** 목표로 삼으면 안 됩니다. 큐에 쌓인 메시지 수만 보는 정책은 **지금 몇 대가 돌고 있는지를 고려하지 않아**, 큐가 비워지는 동안에도 필요 이상으로 인스턴스를 붙입니다.

```
인스턴스당 백로그 = ApproximateNumberOfMessages ÷ (InService 상태 인스턴스 수)

허용 백로그(목표값) = 허용 지연 ÷ 메시지 1건 평균 처리 시간

예) 허용 지연 10초, 평균 처리 0.1초  → 목표값 = 10 / 0.1 = 100
    인스턴스 10대 · 큐 1,500건       → 백로그 = 1,500 / 10 = 150  (목표 초과)
    → 5대 확장해 15대로              → 1,500 / 15 = 100
```

> 분모에 **그룹의 실제 처리 용량**(`InService` 인스턴스 수)이 들어가야 "용량을 늘리면 지표가 내려간다"는 관계가 생기고, 그래야 대상 추적이 역산할 수 있습니다. ECS 서비스에서는 같은 계산을 **태스크당 백로그**로 합니다 — `saa-t3-4` §8 참고.

**예측 스케일링 — 쓰려면 전제를 알아야 합니다**

| 항목 | 공식 값·동작 |
|---|---|
| 최소 데이터 | 감시할 CloudWatch 지표에 **최소 24시간** 분량의 데이터가 있어야 예측을 시작합니다 |
| 분석 범위 | 최대 **과거 14일** 데이터로 패턴을 찾습니다(14일 전부 있으면 예측이 더 정확) |
| 예측 구간 | 향후 **48시간**에 대한 **시간별** 용량 예측 |
| 갱신 주기 | 최신 CloudWatch 데이터로 **6시간마다** 예측을 갱신 |
| 첫 모드 | **예측 전용(forecast only)** — 예측만 만들고 실제로 조정하지 않습니다. `GetPredictiveScalingForecast` API나 콘솔로 정확도를 먼저 평가합니다 |
| 전환 후 | **예측 후 조정(forecast and scale)** — 부하 증가 예측에는 확장합니다. ⚠️ **감소 예측에는 용량을 줄이지 않습니다** — 축소는 **동적 조정 정책**을 따로 만들어야 합니다 |
| 실행 시점 | 기본은 **매 시간 시작 시점**에 그 시간의 예측대로 조정. `SchedulingBufferTime`(콘솔의 **인스턴스 사전 시작**)으로 더 일찍 띄워 부팅 시간을 벌 수 있습니다 |
| 권장 조합 | 사전 시작을 쓸 때는 **기본 인스턴스 워밍업**을 켜는 것이 강력히 권장됩니다 |

> 시험 신호: **"주기적이고 반복되는 트래픽 패턴"**(매일 아침 급증, 주간 주기) → 예측 스케일링 + 동적 조정 **병행**. 예측만으로는 축소가 안 되므로 "예측 스케일링만 두면 된다"는 선택지는 오답입니다.

**복수 동적 조정 정책이 동시에 발동하면 (★ 시험 포인트)**

대상 추적 여러 개, 단계 조정 여러 개, 또는 둘을 섞어 쓸 수 있습니다. 두 정책이 같은 순간에 발동하면 **Amazon EC2 Auto Scaling은 가장 큰 용량을 제공하는 정책을 택합니다** — 스케일 아웃과 스케일 인 양쪽 모두에 적용됩니다.

예: CPU 기반 정책이 1대를 시작하고 SQS 큐 기반 정책이 2대를 시작한다면 → **SQS 정책이 우선**해 2대를 시작합니다. 축소에서도 기준이 서로 달라도(3대 종료 vs 25% 감소) **더 큰 용량을 남기는 쪽**을 택합니다.

**웜 풀 — 부팅이 긴 애플리케이션의 지연 줄이기**

- ASG 옆에 두는 **사전 초기화된 EC2 인스턴스 풀**입니다. 스케일 아웃이 필요하면 ASG가 웜 풀에서 끌어와 희망 용량을 채웁니다(**warm start**). 풀에서 나온 인스턴스는 희망 용량에 계산됩니다.
- 기본 크기는 **ASG 최대 용량 − 희망 용량**입니다(희망 6·최대 10이면 웜 풀 4). `MaxGroupPreparedCapacity`로 따로 지정할 수 있습니다.
- 웜 풀에 있는 동안에는, 조정 정책이 **`InService` 인스턴스의 지표만** 보고 스케일 아웃을 판단합니다.

**인스턴스 새로 고침 — 제한을 알아야 쓸 수 있습니다**

- 교체를 계속 진행할 수 있는 **최대 총 기간은 14일**입니다.
- standby·스케일 인 보호 인스턴스를 기다리거나 새 인스턴스가 헬스 체크를 통과하지 못해 진행이 막히면 **1시간 동안 재시도**하고 상태 메시지를 남깁니다. 1시간 뒤에도 해결되지 않으면 작업이 **실패**합니다.
- ⚠️ **skip matching은 사용자 데이터 스크립트로 배포한 코드 변경을 감지하지 못합니다.** 사용자 데이터로 새 코드를 끌어오는 구성이면 skip matching을 끄세요.
- 인스턴스 새로 고침이 활성인 동안에는 시작 템플릿·시작 구성·혼합 인스턴스 정책을 **업데이트할 수 없습니다**.

**인스턴스 유지관리 정책** — 교체 시 용량을 어떻게 다룰지 고르는 설정입니다.

| 옵션 | 동작 | 적합 |
|---|---|---|
| **시작 후 종료**(Launch before terminating) | 새 인스턴스를 먼저 띄운 뒤 기존 것을 종료 | 비용보다 **가용성** 우선 |
| **종료와 동시 시작**(Terminate and launch) | 기존 종료와 동시에 새로 시작 | 가용성보다 **비용** 우선 · 현재 용량 이상으로 늘리지 말아야 할 때 |
| **커스텀** | 교체 중 유지할 용량의 최소·최대 범위를 직접 지정 | 비용·가용성 절충 |

정책을 두지 않는 것이 ASG의 기본이고, 그때의 기본 동작은 헬스 체크 실패·인스턴스 새로 고침·최대 수명 도달·재조정 모두 **"종료와 동시 시작"** 입니다.

> 🧠 원리: 왜 유예 기간·쿨다운·워밍업이 따로 있을까요?
> 세 값이 가리키는 **판단 주체와 질문**이 다릅니다.
> 유예 기간은 "이 인스턴스를 **죽일지**"(헬스 체크)를, 쿨다운은 "**또 조정할지**"(단순 조정 정책)를, 워밍업은 "이 인스턴스를 **지표에 셀지**"(집계)를 묻습니다.
> 하나로 합치면 "부팅이 느린 앱"과 "지표가 늦게 안정되는 앱"을 구분할 수 없게 됩니다 — 전자는 유예를, 후자는 워밍업을 늘려야 하는데 그 둘은 서로 다른 시간입니다.
> 공식이 "유예 기간을 너무 높게 잡으면 헬스 체크의 효과가 떨어진다"고 경고하는 것도 이 분리 때문입니다 — 유예로 워밍업 문제를 덮으면 진짜 고장도 못 잡습니다.

---

### 10) 불변 인프라와 배포 전략 {#immutable-infrastructure}

**불변 인프라(immutable infrastructure)** 는 운영 워크로드에 **업데이트·보안 패치·구성 변경을 제자리(in-place)에서 하지 않는다**는 모델입니다(Well-Architected `REL08-BP04`). 변경이 필요하면 **새 인프라에 구축해 배포**합니다.

- 가장 흔한 구현은 **불변 서버** — SSH로 들어가 버전을 올리는 대신, 모든 변경이 **코드 저장소 푸시**에서 시작합니다.
- 변경이 허용되지 않으므로 **배포된 시스템의 상태를 확신**할 수 있습니다. 그래서 불변 인프라는 본질적으로 더 **일관·신뢰·예측 가능**합니다.
- ASG의 **인스턴스 새로 고침**(§9)이 이 모델의 실행 수단입니다 — 인스턴스를 고치지 않고 새 시작 템플릿 버전으로 교체합니다.

**불변 인프라에 배포할 때 쓰는 두 전략**

| 전략 | 방식 | 되돌리기 |
|---|---|---|
| **카나리** | 소수 고객을 새 버전(보통 단일 인스턴스 = 카나리)으로 보내고 동작 변화·오류를 깊이 관찰. 문제가 없으면 원하는 속도로 계속 배포 | 치명적 문제 시 카나리에서 트래픽을 빼고 이전 버전으로 돌림 |
| **블루/그린** | 전체 플릿을 **병렬로** 배포하고 두 스택(blue·green)을 번갈아 씀. 보통 한 번에 전환하지만 **Route 53 가중 라우팅**으로 비율을 올려가며 전환할 수도 있음 | 이전 스택이 그대로 있어 되돌리기가 빠름 |

CodeDeploy는 카나리·블루/그린 배포 구성을, Elastic Beanstalk은 블루/그린 구성을 지원합니다.

---

### 11) 앱을 바꿀 수 없는 워크로드의 신뢰성 {#legacy-reliability}

공식 Task 2.2 Skill에 "**애플리케이션을 변경할 수 없을 때** 신뢰성을 개선하는 방법"이 있습니다. 코드를 손댈 수 없으면 **인프라 계층에서** 복원력을 만듭니다.

**EC2 자동 복구** — 하드웨어·호스트 소프트웨어 장애로 인스턴스 가용성이 깨질 때 AWS가 **다른 하드웨어로 마이그레이션을 시도**합니다. 두 가지 메커니즘이 있습니다.

| 메커니즘 | 활성화 |
|---|---|
| **단순 자동 복구** | 지원 인스턴스에서 **기본 활성** |
| **CloudWatch 액션 기반 복구** | **수동 구성** — `StatusCheckFailed_System` 지표를 감시하는 경보를 만들고, 값이 **1**(시스템 상태 점검 실패)일 때 **복구 작업**을 수행하게 지정 |

- ⚠️ **시스템 상태 점검**이 실패해야 동작합니다. **인스턴스 상태 점검만 실패하면 자동 복구는 동작하지 않습니다** — 시스템 점검 실패는 호스트의 하드웨어·소프트웨어 문제이고, 인스턴스 점검 실패는 게스트 OS·구성 문제라 복구 대상이 다릅니다.
- **복구 후 보존되는 것**: 인스턴스 ID · 퍼블릭·프라이빗·탄력적 IP · 인스턴스 메타데이터 · 배치 그룹 · 연결된 EBS 볼륨 · 가용 영역
- ⚠️ **상실되는 것**: 휘발성 메모리(RAM) 데이터 · **인스턴스 스토어 볼륨의 데이터**(CloudWatch 액션 기반 복구에 해당) · OS 가동 시간이 0으로 리셋

**단일 인스턴스 ASG(`min=max=desired=1`)** — 수평 확장이 불가능한 앱도 ASG에 넣으면 **헬스 체크 실패 시 자동 교체**를 얻습니다. 확장은 못 해도 **자가 복구**는 생깁니다. 상태를 인스턴스 밖(EFS·RDS·ElastiCache)으로 빼 두면 교체가 안전해집니다(§8 스테이트리스 전제와 같은 이유).

> **시험 신호**: "앱을 수정할 수 없다 / 레거시다 / 수평 확장이 안 된다" + "가용성을 높여야" → **단일 인스턴스 ASG + 자동 복구 + 상태 외부화**. 코드 변경을 요구하는 답(마이크로서비스 분해·재작성)은 전제를 어깁니다.

---

## ✍️ 시험 포인트

- **고가용 웹 서비스 표준 답안**: Route 53 → ALB → ASG(멀티 AZ) → RDS Multi-AZ. 이 4계층 조합이 "복원력·탄력성"을 묻는 시나리오의 정석 구조입니다.
- **ALB vs NLB 선택**: "HTTP 경로·호스트 기반 라우팅" → ALB. "UDP·고정 IP·초저지연·초고성능" → NLB. 두 키워드를 동시에 외우세요.
- **ASG 자가 복구**: ASG는 헬스 체크 실패 인스턴스를 자동 종료·교체합니다. "인스턴스 장애 자동 복구" 시나리오의 답이 ASG인 이유입니다.
- **조정 정책 선택**: "지표에 따라 자동 조절, 설정 단순" → 대상 추적. "시간대 예측 트래픽" → 예약. "과거 패턴 기반 선제 확장" → 예측.
- **교차 영역 부하 분산**: ALB는 기본 활성화(추가 요금 없음), NLB는 기본 비활성화(활성화 시 요금 가능). 시험에서 AZ 간 불균형 시나리오가 나오면 이 설정을 확인하세요.
- **고정 세션의 함정**: 고정 세션은 가용성에서 불균형을 초래할 수 있습니다. 시험에서 "세션 공유 없이 고정 세션 사용 → 특정 인스턴스 과부하"는 안티패턴입니다.
- **수명 주기 훅 + 연결 드레이닝**: 종료 훅으로 진행 중인 요청이 끊기지 않게 하고, ALB 연결 드레이닝(등록 해제 지연)으로 기존 연결을 완료까지 허용합니다.
- **시작 템플릿 vs 시작 구성**: 시작 구성(Launch Configuration)은 레거시. 버전 관리·혼합 인스턴스 정책(Spot + On-Demand)이 필요하면 반드시 시작 템플릿을 사용합니다.

---

## ⚠️ 흔한 함정 {#common-pitfalls}

1. **"ASG를 단일 AZ에만 구성했다."** → AZ 장애 시 전체 서비스 다운. 최소 2개 AZ에 분산해야 ASG가 AZ 내 인스턴스 수를 균등하게 유지하며 고가용성을 보장합니다.
   *(원리: §6 — ASG는 헬스 체크 실패 인스턴스를 교체하지만 AZ 자체가 다운되면 해당 AZ 전체 용량이 사라지므로, 멀티 AZ 분산이 자가 복구의 전제 조건이다.)*

2. **"NLB도 경로 기반 라우팅이 된다."** → NLB는 L4 — HTTP 헤더를 해석하지 않습니다. 경로(`/api/*`)·호스트(`api.example.com`) 기반 라우팅은 ALB만 가능합니다.
   *(원리: §1 — L4는 패킷 헤더(IP·포트)만 보고 전달하므로 HTTP 경로 같은 L7 페이로드를 읽는 것은 구조적으로 불가능하다.)*

3. **"ELB가 스케일링을 담당한다."** → ELB는 트래픽 **분산**, ASG는 인스턴스 수 **조정**입니다. 부하 분산 = ELB, 용량 확장/축소 = ASG. 두 개는 역할이 다르며, 함께 써야 완전한 탄력성이 생깁니다.
   *(원리: §1·§6 — ELB는 대상 선택 책임, ASG는 대상 수 결정 책임으로 관심사가 분리되어 있어 각자 독립 확장된다.)*

4. **"대상 추적 정책은 스케일 아웃만 한다."** → 대상 추적은 스케일 아웃(용량 증가)과 스케일 인(용량 감소)을 모두 자동으로 처리합니다. 비용 절감을 위한 스케일 인도 포함됩니다.
   *(원리: §7 — 대상 추적은 목표 지표와 현재값 차이로 필요 인스턴스 수를 양방향 계산하므로 스케일 아웃과 인 모두를 포함한다.)*

5. **"교차 영역 부하 분산은 항상 활성화가 좋다."** → NLB에서 교차 영역 부하 분산을 활성화하면 AZ 간 데이터 전송 요금이 발생할 수 있습니다. 비용 민감 설계에서는 AZ별 대상 수를 균등하게 배치해 비활성화 상태를 유지하는 편이 나을 수 있습니다.
   *(원리: §4 — NLB는 TCP 연결을 종단 간 유지해 AZ 교차 트래픽이 실제 전송 비용으로 직결되므로, 균등 배치로 교차 없이도 균형을 맞추는 설계가 비용 효율적이다.)*

6. **"ASG 헬스 체크는 EC2 상태만 본다."** → 기본은 EC2 상태 체크이지만, ELB 헬스 체크를 추가로 활성화하면 애플리케이션 레벨 응답까지 확인합니다. ELB 헬스 체크를 활성화해야 애플리케이션이 다운된 인스턴스를 ASG가 교체합니다.
   *(원리: §6 — EC2 상태 체크는 하이퍼바이저 레벨 확인이라 앱 프로세스 크래시는 감지 못하므로, ELB 헬스 체크 결합이 애플리케이션 수준 자가 복구를 완성한다.)*

7. **"수명 주기 훅 없이도 인스턴스가 완전히 초기화된다."** → 훅 없이 시작하면 ASG가 인스턴스를 InService로 전환해 ELB가 트래픽을 바로 보냅니다. 초기화에 시간이 필요한 애플리케이션(소프트웨어 설치, DB 마이그레이션)은 시작 훅으로 초기화 완료 전까지 트래픽 수신을 막아야 합니다.
   *(원리: §8 — 수명 주기 훅의 대기 상태가 완료 신호 수신 전까지 ELB 등록을 지연시켜, 불완전 초기화 인스턴스로의 트래픽 유입이라는 경쟁 조건을 차단한다.)*

---

## 🧪 자가 점검

> 아래는 학습용 자가 점검입니다. (정식 검증 문항은 별도 문항 파일 참조)

**Q1.** 전자상거래 사이트가 `/api/*` 요청은 백엔드 EC2, `/static/*` 요청은 별도 EC2로 분리해야 합니다. 어떤 ELB 유형을 사용해야 하나요?

<details><summary>정답 보기</summary>

**Application Load Balancer (ALB)**를 사용합니다. ALB는 HTTP 경로 기반 라우팅을 지원해 리스너 규칙에서 `/api/*` → 백엔드 대상 그룹, `/static/*` → 정적 대상 그룹으로 분리할 수 있습니다. NLB는 L4에서 동작해 HTTP 경로를 해석하지 못하므로 이 요구사항을 충족할 수 없습니다.
</details>

**Q2.** 금융 거래 시스템이 방화벽 화이트리스트에 로드밸런서의 IP를 등록해야 합니다. 어떤 ELB 유형을 선택해야 하나요?

<details><summary>정답 보기</summary>

**Network Load Balancer (NLB)**를 선택합니다. NLB는 AZ당 하나의 고정 Elastic IP를 할당받을 수 있어 방화벽 화이트리스트 등록이 가능합니다. ALB는 내부적으로 IP가 변경될 수 있어 고정 IP를 보장하지 않습니다.
</details>

**Q3.** ASG가 CPU 70% 이상일 때 자동으로 인스턴스를 추가하고, 30% 이하일 때 줄이도록 설정하려 합니다. 가장 간단한 방법은?

<details><summary>정답 보기</summary>

**대상 추적(Target Tracking) 정책**으로 CPU 사용률 목표를 50%(또는 적절한 값)로 설정합니다. 대상 추적은 지정한 목표 지표를 기준으로 ASG가 스케일 아웃과 스케일 인을 자동으로 계산하므로, 별도 임계값·증감량·경보를 설정할 필요가 없습니다.
</details>

**Q4.** 애플리케이션 인스턴스 종료 시 30초간 진행 중인 DB 쓰기 작업을 완료하고 로그를 S3에 저장한 뒤 종료해야 합니다. 어떻게 구현하나요?

<details><summary>정답 보기</summary>

**ASG 수명 주기 훅(종료 훅)**을 사용합니다. 종료 훅이 `Terminating:Wait` 상태로 인스턴스를 붙잡는 동안, EventBridge 이벤트로 Lambda를 트리거해 DB 작업 완료 대기와 S3 로그 저장을 수행합니다. 작업이 완료되면 `CONTINUE` 신호를 보내 종료를 진행합니다. 대기 시간은 기본 1시간이며, 30초 이상 충분히 확보됩니다.
</details>

**Q5 (원리).** 왜 ALB에서 고정 세션(Sticky Session)을 활성화하면 ASG의 자동 복구 효과가 줄어들까요?

<details><summary>정답 보기</summary>

**ASG의 자가 복구는 인스턴스를 교체하지만, 쿠키로 종료된 인스턴스에 묶인 세션 데이터까지 이전하지는 않기 때문입니다.** 새 인스턴스가 정상 기동돼 트래픽을 받을 수 있어도, 클라이언트의 `AWSALB` 쿠키는 이미 사라진 대상을 가리키므로 ALB는 해당 사용자를 새 인스턴스로 자연스럽게 연결하지 못하고 세션이 끊깁니다. ElastiCache 같은 외부 세션 저장소를 도입하면 세션 데이터가 인스턴스 수명 주기와 분리되어, 교체된 어떤 인스턴스든 동일 세션 키로 데이터를 읽어 처리할 수 있으므로 ASG 자가 복구가 사용자에게 투명하게 작동합니다.
</details>

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. (작성·대조: 2026-06-07 · 고도화 검수: 2026-06-12)

1. Elastic Load Balancing — 개요 (공식) — https://docs.aws.amazon.com/elasticloadbalancing/latest/userguide/what-is-load-balancing.html
2. Application Load Balancer — 소개 (공식) — https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html
3. Network Load Balancer — 소개 (공식) — https://docs.aws.amazon.com/elasticloadbalancing/latest/network/introduction.html
4. Amazon EC2 Auto Scaling — 개요 (공식) — https://docs.aws.amazon.com/autoscaling/ec2/userguide/what-is-amazon-ec2-auto-scaling.html
5. Gateway Load Balancer — 소개("operates at the third layer... the network layer", 모든 IP 패킷·모든 포트) — https://docs.aws.amazon.com/elasticloadbalancing/latest/gateway/introduction.html
6. Classic Load Balancer — 소개("the previous generation of load balancers") — https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/introduction.html
7. SAA-C03 공식 시험 가이드 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
8. ASG 헬스 체크 유예 기간(콘솔 300초·CLI/SDK 0초·유예 중 `running` 아니면 즉시 교체·적용 대상 3종) — https://docs.aws.amazon.com/autoscaling/ec2/userguide/health-check-grace-period.html
9. ASG 동적 조정 — 복수 정책 동시 발동 시 **가장 큰 용량을 제공하는 정책** 우선 — https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-scale-based-on-demand.html
10. ASG 조정 쿨다운 — 단순 조정 정책 **기본 300초**·정책별 쿨다운이 기본값을 덮어씀 — https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-scaling-cooldowns.html
11. ASG 웜 풀(기본 크기 = 최대 − 희망·`MaxGroupPreparedCapacity`·warm start·`InService` 지표만으로 판단) — https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-warm-pools.html
12. 인스턴스 새로 고침(최대 총 기간 **14일**·1시간 타임아웃·skip matching의 사용자 데이터 한계·활성 중 템플릿 업데이트 불가) — https://docs.aws.amazon.com/autoscaling/ec2/userguide/instance-refresh-overview.html
13. 인스턴스 유지관리 정책(3옵션·정책 없을 때 기본은 "종료와 동시 시작") — https://docs.aws.amazon.com/autoscaling/ec2/userguide/instance-maintenance-policy-overview-and-considerations.html
14. `LifecycleHook` API — `HeartbeatTimeout` 기본 3,600초·범위 30~7,200초, `GlobalTimeout` **172,800초(48시간) 또는 HeartbeatTimeout의 100배 중 더 작은 값**, `DefaultResult`·`RecordLifecycleActionHeartbeat` — https://docs.aws.amazon.com/autoscaling/ec2/APIReference/API_LifecycleHook.html
15. 불변 인프라로 배포 — Well-Architected `REL08-BP04`(in-place 변경 금지·불변 서버·카나리/블루그린·Route 53 가중 라우팅) — https://docs.aws.amazon.com/wellarchitected/2022-03-31/framework/rel_tracking_change_management_immutable_infrastructure.html
16. EC2 자동 인스턴스 복구(단순 자동 복구 기본 활성·CloudWatch 액션 기반·시스템 점검만 해당·보존/상실 항목·`StatusCheckFailed_System` 0/1) — https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-recover.html
17. ASG 대상 추적 조정 정책 — 사전 정의 지표 4종·`ResourceLabel`·1분 이하 간격 권장·상세 모니터링 — https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-scaling-target-tracking.html (갭 배치 B7b: 2026-10-21)
18. SQS 기반 조정 정책 — 인스턴스당 백로그·허용 백로그 계산 — https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-using-sqs-queue.html (갭 배치 B7b: 2026-10-21)
19. 예측 스케일링 동작(최소 24시간·과거 14일·48시간 시간별 예측·6시간 갱신·예측 전용 모드·축소하지 않음·`SchedulingBufferTime`) — https://docs.aws.amazon.com/autoscaling/ec2/userguide/predictive-scaling-policy-overview.html (갭 배치 B7b: 2026-10-21)

> 📝 **2026-10-21 보강(갭 `G-3.2-03`, 배치 B7b)**: §9에 **조정 지표** 계층을 추가했습니다 — 사전 정의 지표 네 가지와 `ResourceLabel` 요구, **메모리는 사전 정의 지표에 없다**는 점, 지표 간격 권장(EC2 기본 5분 → 상세 모니터링 1분), 사용자 지정 지표의 정석인 **인스턴스당 백로그** 계산, 그리고 **예측 스케일링의 전제**(최소 24시간·과거 14일·48시간 예측·6시간 갱신·예측 전용 모드·축소하지 않음)입니다(근거 17·18·19번). 기존 §9의 타이밍 설정·복수 정책·웜 풀 서술은 그대로 두고 그 앞에 끼워 넣었습니다.
>
> **쓰지 않은 것**: `ASGAverageMemoryUtilization` 같은 메모리 사전 정의 지표는 공식 목록에 없어 쓰지 않았습니다. **AWS Auto Scaling 조정 계획(scaling plans)**의 현행 제공 상태는 공식 문서로 확인되지 않아(`99-gaps` V-22) 다루지 않았습니다.

> 📝 **2026-10-21 보강(갭 `G-2.2-03`·`G-2.2-06`·`G-2.2-11`, 배치 B6)**: ① **§9 신설** — 유예 기간의 **콘솔/CLI 기본값 분기**·기본 쿨다운 300초·기본 워밍업·복수 정책의 **큰 용량 우선**·웜 풀·인스턴스 새로 고침 제한·인스턴스 유지관리 정책(근거 8~13번). ② **§10 신설** — 불변 인프라와 카나리·블루/그린(근거 15번). ③ **§11 신설** — 앱 변경 불가 워크로드의 EC2 자동 복구와 단일 인스턴스 ASG(근거 16번). ④ **§8 수명 주기 훅 보강 — `99-gaps` V-15 해소**: 기존 "기본 1시간(최대 48시간)"은 조건이 빠져 있었습니다. 공식 `GlobalTimeout`은 **48시간 또는 `HeartbeatTimeout`의 100배 중 더 작은 값**이라 조건을 함께 적었습니다(근거 14번). 기존 §1~§8의 번호·앵커는 바꾸지 않았습니다.

> 📝 **2026-10-19 정정**: ① GWLB 계층을 `L3/4` → **L3(네트워크 계층)**으로 고치고 "모든 IP 패킷·모든 포트 수신"을 명시했습니다(근거 5번). ② CLB 사용 사례 칸을 **이전 세대 LB(현행 세대로 마이그레이션 권고)**로 정정했습니다 — EC2-Classic 전용 LB가 아닙니다(근거 6번). ③ NLB의 "연결 지연 1ms 미만" 수치는 공식 근거를 찾지 못해 삭제했습니다(공식 서술은 초당 수백만 요청).
