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
lastVerified: 2026-06-07
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

## 📖 핵심 개념

### 1) Elastic Load Balancing — 종류와 선택

> 공식 정의: **"수신 트래픽을 여러 대상(EC2 인스턴스·컨테이너·IP 주소)에 자동으로 분산하고, 헬스 체크를 통해 정상 대상에만 트래픽을 보내는 관리형 서비스."**

ELB는 현재 세대 3종(ALB·NLB·GWLB)과 레거시 CLB로 구성됩니다.

| 유형 | OSI 계층 | 주요 프로토콜 | 대표 특징 | 대표 사용 사례 |
|---|---|---|---|---|
| **ALB** (Application LB) | L7 | HTTP / HTTPS / gRPC | 경로·호스트 기반 라우팅, WAF 연동, Lambda 대상, 컨테이너 친화 | 웹 앱, 마이크로서비스, API Gateway 대체 |
| **NLB** (Network LB) | L4 | TCP / UDP / TLS / QUIC | 초고성능(초당 수백만 요청), AZ당 **고정 Elastic IP**, 초저지연 | 게임 서버, 금융 거래, VoIP, IoT |
| **GWLB** (Gateway LB) | L3/4 | GENEVE(6081) | 서드파티 보안 어플라이언스(방화벽·IDS) 인라인 삽입 | 트래픽 검사·필터링 파이프라인 |
| **CLB** (Classic LB) | L4/L7 | HTTP / HTTPS / TCP | 레거시. 신규 사용 비권장 | 기존 EC2-Classic 환경만 |

> **선택 기준**: "HTTP 경로·호스트별 라우팅이 필요하다" → ALB. "UDP·고정 IP·초저지연이 필요하다" → NLB. "서드파티 방화벽을 모든 트래픽에 인라인으로 적용해야 한다" → GWLB.

### 2) ALB 핵심 구성 요소

ALB는 **리스너 → 리스너 규칙 → 대상 그룹** 계층으로 동작합니다.

| 구성 요소 | 역할 |
|---|---|
| **리스너(Listener)** | 클라이언트 연결 요청을 받을 포트·프로토콜 설정. 리스너당 기본 규칙 1개 필수 |
| **리스너 규칙(Listener Rule)** | 조건(경로·호스트·헤더·쿼리스트링·소스 IP)에 따라 요청을 대상 그룹으로 라우팅. 우선순위 순서로 평가 |
| **대상 그룹(Target Group)** | 실제 트래픽을 받을 대상 묶음. EC2 인스턴스·IP 주소·Lambda 함수·다른 ALB 등록 가능 |
| **헬스 체크(Health Check)** | 대상 그룹 단위로 설정. 비정상 대상은 자동 제외, 회복 시 자동 복귀 |

ALB의 경로 기반 라우팅 예:

```
리스너: HTTPS :443
  규칙 1) 경로=/api/*   → 대상그룹-API   (EC2 백엔드)
  규칙 2) 경로=/images/* → 대상그룹-정적  (EC2 또는 S3)
  기본  ) 나머지        → 대상그룹-웹    (EC2 프런트엔드)
```

### 3) NLB 핵심 특성

NLB는 L4에서 동작하며 ALB가 할 수 없는 두 가지 시나리오에서 선택합니다.

| 특성 | 설명 |
|---|---|
| **고정 IP** | AZ당 하나의 로드밸런서 노드 → Elastic IP 할당 가능. 방화벽 화이트리스트에 IP를 등록해야 하는 경우 필수 |
| **초고성능** | 초당 수백만 요청 처리, 연결 지연 < 1ms 수준 |
| **TCP 연결 유지** | 개별 TCP 연결은 수명 동안 동일한 대상으로 라우팅(플로우 해시) |
| **교차 영역 부하 분산** | 기본 비활성화(ALB와 다름). 활성화 시 추가 데이터 전송 비용 발생 가능 |

### 4) 교차 영역 부하 분산 (Cross-Zone Load Balancing)

| 설정 | 동작 |
|---|---|
| **비활성화(기본 — NLB·GWLB)** | 각 로드밸런서 노드는 자신이 속한 AZ의 대상에만 트래픽 분산 |
| **활성화(기본 — ALB)** | 각 로드밸런서 노드가 모든 AZ의 정상 대상에 균등 분산 |

교차 영역 부하 분산이 중요한 이유: AZ별 인스턴스 수가 다를 때(예: AZ-a에 2대, AZ-b에 8대) 비활성화 상태면 AZ-a의 인스턴스 2대가 전체 트래픽의 50%를 받아 과부하가 발생합니다. 활성화 시 10대 전체에 10%씩 균등 분산됩니다.

> ALB는 교차 영역 부하 분산이 **기본 활성화**되어 있으며 추가 요금이 없습니다. NLB와 GWLB는 기본 비활성화이며, 활성화 시 AZ 간 데이터 전송 요금이 발생할 수 있습니다.

### 5) 고정 세션 (Sticky Session)

고정 세션(Stickiness)은 동일한 클라이언트의 요청을 수명 동안 동일한 대상으로 라우팅합니다.

| 항목 | 내용 |
|---|---|
| **지원 유형** | ALB(기본 지원), NLB(TCP 플로우 해시로 자연스럽게 고정), CLB |
| **ALB 구현 방식** | 쿠키 기반. LB 생성 쿠키(`AWSALB`) 또는 애플리케이션 쿠키 선택 |
| **주의사항** | 고정 세션 활성화 시 대상 간 부하 불균형 발생 가능. 세션리스 아키텍처(ElastiCache 세션 외부화)가 권장 |

### 6) Auto Scaling Group (ASG) — 구성 요소

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

### 7) ASG 조정 정책 4종

| 정책 | 트리거 | 동작 방식 | 권장 시나리오 |
|---|---|---|---|
| **대상 추적(Target Tracking)** | CloudWatch 지표(CPU 사용률·요청 수 등)가 목표값에서 벗어남 | ASG가 목표값 유지를 위해 용량을 자동 계산·조정. 설정이 단순 | **권장 기본값**. 예: "CPU 50% 유지" |
| **단계(Step) / 단순(Simple)** | CloudWatch 경보 임계값 초과 | 임계값 구간별로 다른 크기로 증감. Step이 Simple보다 세밀 | 세밀한 단계별 제어가 필요할 때 |
| **예약(Scheduled)** | 지정한 날짜·시간(cron) | 예측 가능한 트래픽 패턴에 맞게 용량을 사전 설정 | 매일 오전 9시 트래픽 급증, 주말 축소 등 |
| **예측(Predictive)** | ML이 과거 패턴 분석해 미래 부하 예측 | 부하가 도달하기 전 선제적으로 용량 확장 | 주기적 패턴이 있는 트래픽, 워밍업 시간이 긴 애플리케이션 |

> **대상 추적이 기본 권장**인 이유: 목표 지표 하나만 설정하면 ASG가 스케일 아웃·인 모두를 알아서 처리합니다. 임계값과 증감 단계를 별도로 관리할 필요가 없습니다.

### 8) 수명 주기 훅 (Lifecycle Hooks)

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
| **대기 시간** | 기본 1시간(최대 48시간). 작업 완료 후 `CONTINUE` 또는 `ABANDON` 신호를 보내야 다음 단계 진행 |
| **연동** | EventBridge 이벤트, SQS 메시지, SNS 알림으로 훅 이벤트를 수신해 Lambda 등을 트리거 |

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

## ⚠️ 흔한 함정

1. **"ASG를 단일 AZ에만 구성했다."** → AZ 장애 시 전체 서비스 다운. 최소 2개 AZ에 분산해야 ASG가 AZ 내 인스턴스 수를 균등하게 유지하며 고가용성을 보장합니다.

2. **"NLB도 경로 기반 라우팅이 된다."** → NLB는 L4 — HTTP 헤더를 해석하지 않습니다. 경로(`/api/*`)·호스트(`api.example.com`) 기반 라우팅은 ALB만 가능합니다.

3. **"ELB가 스케일링을 담당한다."** → ELB는 트래픽 **분산**, ASG는 인스턴스 수 **조정**입니다. 부하 분산 = ELB, 용량 확장/축소 = ASG. 두 개는 역할이 다르며, 함께 써야 완전한 탄력성이 생깁니다.

4. **"대상 추적 정책은 스케일 아웃만 한다."** → 대상 추적은 스케일 아웃(용량 증가)과 스케일 인(용량 감소)을 모두 자동으로 처리합니다. 비용 절감을 위한 스케일 인도 포함됩니다.

5. **"교차 영역 부하 분산은 항상 활성화가 좋다."** → NLB에서 교차 영역 부하 분산을 활성화하면 AZ 간 데이터 전송 요금이 발생할 수 있습니다. 비용 민감 설계에서는 AZ별 대상 수를 균등하게 배치해 비활성화 상태를 유지하는 편이 나을 수 있습니다.

6. **"ASG 헬스 체크는 EC2 상태만 본다."** → 기본은 EC2 상태 체크이지만, ELB 헬스 체크를 추가로 활성화하면 애플리케이션 레벨 응답까지 확인합니다. ELB 헬스 체크를 활성화해야 애플리케이션이 다운된 인스턴스를 ASG가 교체합니다.

7. **"수명 주기 훅 없이도 인스턴스가 완전히 초기화된다."** → 훅 없이 시작하면 ASG가 인스턴스를 InService로 전환해 ELB가 트래픽을 바로 보냅니다. 초기화에 시간이 필요한 애플리케이션(소프트웨어 설치, DB 마이그레이션)은 시작 훅으로 초기화 완료 전까지 트래픽 수신을 막아야 합니다.

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

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. (작성·대조: 2026-06-07)

1. Elastic Load Balancing — 개요 (공식) — https://docs.aws.amazon.com/elasticloadbalancing/latest/userguide/what-is-load-balancing.html
2. Application Load Balancer — 소개 (공식) — https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html
3. Network Load Balancer — 소개 (공식) — https://docs.aws.amazon.com/elasticloadbalancing/latest/network/introduction.html
4. Amazon EC2 Auto Scaling — 개요 (공식) — https://docs.aws.amazon.com/autoscaling/ec2/userguide/what-is-amazon-ec2-auto-scaling.html
5. SAA-C03 공식 시험 가이드 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
