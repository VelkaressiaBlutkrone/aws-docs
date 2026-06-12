---
examGuideTaskId: soa-t1-4
certCode: SOA-C03
domain: 1
domainName: 모니터링, 로깅, 분석, 문제 해결 및 성능 최적화
domainWeightPct: 22
title: 가용성 지표 기반 문제 식별·해결 (Health Dashboard·상태 확인)
coversTasks:
  - "1.2"
sources:
  - title: AWS Health란 무엇인가 (Health Dashboard) (공식)
    url: https://docs.aws.amazon.com/health/latest/ug/what-is-aws-health.html
  - title: AWS Health를 EventBridge와 통합 (공식)
    url: https://docs.aws.amazon.com/health/latest/ug/cloudwatch-events-health.html
  - title: EC2 인스턴스 상태 확인 (시스템 vs 인스턴스) (공식)
    url: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/monitoring-system-instance-status-check.html
  - title: EC2 인스턴스 자동 복구 (공식)
    url: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-recovery.html
  - title: ELB 대상 상태 확인 (Application Load Balancer) (공식)
    url: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/target-group-health-checks.html
lastVerified: 2026-06-12
---

# 가용성 지표 기반 문제 식별·해결 (Health Dashboard·상태 확인)

> **커버하는 공식 Task** — SOA-C03 · 도메인 1 「모니터링, 로깅, 분석, 문제 해결 및 성능 최적화」(22%) · **Task 1.2 모니터링 및 가용성 지표를 사용하여 문제 식별 및 해결** (`soa-t1-4`)
> 이 문서는 가용성 신호(Health Dashboard·상태 확인)로 장애를 탐지하고 격리·복구하는 운영 절차에 집중합니다. 지표/경보 기초는 `soa-t1-1`을 참조하세요.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명하고, 콘솔/CLI에서 직접 구성할 수 있어야 합니다.

- [ ] **Health Dashboard 구분** — Service Health(전체 서비스) vs Account/Personal Health(내 계정)를 구분한다
- [ ] **Health API/EventBridge** — Health 이벤트를 자동화로 받아 대응을 연결할 수 있다
- [ ] **EC2 상태 확인 2종** — 시스템 상태 확인 vs 인스턴스 상태 확인의 책임 경계를 안다
- [ ] **자동 복구** — 시스템 상태 확인 실패에 대한 EC2 자동 복구를 구성할 수 있다
- [ ] **ELB 상태 확인** — healthy/unhealthy threshold로 비정상 대상을 트래픽에서 제외하는 원리를 안다
- [ ] **문제 진단 접근** — 지표 이상 → 로그 확인 → 근본 원인의 운영 흐름을 적용할 수 있다
- [ ] **탐지→격리→복구** — 장애 대응의 표준 운영 순서를 설명할 수 있다

---

## 🎯 왜 중요한가

- Task 1.2는 "지표를 보는 것"을 넘어 **"그래서 무엇이 문제인지 식별하고 고치는 것"**을 요구합니다. SOA는 운영 자격증이므로 장애 탐지부터 복구까지의 **절차**를 직접 수행할 수 있어야 합니다.
- 장애의 원인은 크게 두 갈래입니다 — **AWS 인프라 쪽 문제**(이때 AWS Health Dashboard가 진실의 출처)와 **내 리소스 구성 문제**(이때 상태 확인·지표·로그로 진단). 둘을 혼동하면 엉뚱한 곳을 디버깅합니다.
- 상태 확인(EC2 status check, ELB health check)은 **자동 복구와 자동 트래픽 격리**의 트리거입니다. 어떤 확인이 무엇을 점검하고, 실패 시 무엇을 자동화할 수 있는지가 반복 출제됩니다.

---

## 🔤 먼저 알아야 할 용어

이 문서를 읽는 데 필요한 기초 용어입니다. 이미 알면 건너뛰세요.

| 용어 | 영문 | 한 줄 풀이 |
|---|---|---|
| **이벤트 버스** | Amazon EventBridge | AWS 서비스에서 발생하는 이벤트를 받아 규칙에 따라 대상으로 라우팅하는 서버리스 이벤트 버스 |
| **Auto Scaling 그룹** | Auto Scaling Group (ASG) | 수요·상태 변화에 따라 EC2 인스턴스 수를 자동으로 늘리거나 줄이는 논리적 인스턴스 집합 |
| **CloudWatch 경보** | CloudWatch Alarm | 지표 값이 임계값을 넘으면 알림·자동 조치를 트리거하는 모니터링 규칙 |
| **Elastic IP** | Elastic IP Address (EIP) | 계정에 고정 할당되는 공인 IPv4 주소 — 인스턴스를 교체해도 동일 IP를 유지할 수 있음 |
| **Amazon SNS** | Simple Notification Service | 토픽에 발행된 메시지를 이메일·Lambda·SQS 등 구독자에게 즉시 전달하는 퍼블리시-구독 알림 서비스 |

---

## 📖 핵심 개념

### 1) AWS Health Dashboard — 두 가지를 구분하라

> 공식 정의: **"AWS Health는 AWS 리소스·서비스·계정의 상태에 대한 지속적인 가시성을 제공한다."** 두 대시보드를 구분하는 것이 시험의 핵심입니다.

| 대시보드 | 보는 대상 | 용도 |
|---|---|---|
| **Service Health Dashboard**(현 AWS Health Dashboard – Service health) | **AWS 전체 서비스의 일반 상태**(모든 고객 공통) | "지금 도쿄 리전 S3가 전체적으로 장애인가?" 공개 상태 페이지 |
| **Personal/Account Health Dashboard**(AWS Health Dashboard – Your account) | **내 계정·내 리소스에 영향을 주는** 이벤트 | "이 이벤트가 *내* EC2/RDS에 영향을 주는가", 예정된 유지 관리·중단·권장 조치 |

**핵심 사실:**

- **Service Health**는 모두에게 동일한 "서비스가 전반적으로 정상인가" 뷰입니다. **Account(Personal) Health**는 **나에게만 보이는** 개인화된 뷰로, 영향받는 리소스 ID·예정된 유지 관리·필요 조치를 알려줍니다.
- 장애 의심 시 **첫 단계는 AWS Health Dashboard 확인**입니다. AWS 측 광역 장애라면 내 구성을 고쳐도 소용없습니다.

> 🧠 원리: 왜 Service Health와 Account Health를 별도 뷰로 나눌까요?
> AWS 인프라 문제 중 일부는 특정 리소스 구성·서비스 이용 조합에서만 나타나서 모든 고객에게 동일하게 드러나지 않습니다.
> Account Health는 내 계정에서 실행 중인 리소스 ID와 이벤트를 교차 참조해 "이 장애가 내게 영향을 주는가"만 필터링하고, 예정된 유지 관리와 권장 조치도 계정 맥락에 맞게 보여줍니다.
> 두 뷰를 분리하면 운영자는 서비스 전반 현황(Service Health)과 자신의 워크로드 영향(Account Health)을 혼동 없이 파악하고, AWS 측 문제와 자체 구성 문제를 빠르게 분류할 수 있습니다.

### 2) AWS Health API·EventBridge 연동

- **AWS Health API**로 계정에 영향을 주는 이벤트를 프로그래밍 방식으로 조회할 수 있습니다(상위 지원 플랜에서 제공).
- **EventBridge 연동**: AWS Health 이벤트는 EventBridge로 들어와 **규칙으로 자동 대응**을 트리거할 수 있습니다. 예: "특정 서비스 운영 이슈 이벤트 발생 → SNS로 운영팀 알림", "EC2 예정된 유지 관리(재부팅) 이벤트 → 사전 조치 자동화".

> 운영 절차: 수동으로 대시보드를 들여다보는 대신, **Health → EventBridge → SNS/Lambda**로 영향 이벤트를 자동 수신·대응하도록 구성하는 것이 모범 사례입니다.

> 🧠 원리: 왜 Health 이벤트에 EventBridge를 끼워 자동 대응 파이프라인을 구성할까요?
> AWS Health 이벤트는 발생 시점이 불규칙하고, 운영자가 대시보드를 항상 보고 있을 수 없어 수동 확인은 대응 지연으로 이어집니다.
> EventBridge는 Health 이벤트를 스트림으로 수신해 규칙이 일치하는 즉시 SNS 알림·Lambda 함수 등 후속 작업을 트리거하므로, 운영자 개입 없이 이벤트 발생과 대응 사이의 간격을 좁힐 수 있습니다.
> 이 패턴은 단순 알림에 그치지 않고, 예정된 유지 관리 이벤트를 사전에 감지해 트래픽 전환이나 스냅샷 생성 같은 준비 작업도 자동화할 수 있게 합니다.

### 3) EC2 상태 확인 — 시스템 vs 인스턴스 (책임 경계)

> 공식: EC2는 **자동화된 상태 확인 2종**을 수행하며, 각 확인은 60초(1분)마다 실행되어 `pass`/`fail`을 보고합니다(추가로 EBS·연결 상태 확인 등도 제공).

| 확인 종류 | 점검 대상 | 실패 원인 예시 | 누구 책임 |
|---|---|---|---|
| **시스템 상태 확인(System status check)** | 인스턴스를 실행하는 **AWS 인프라/호스트** | 호스트 하드웨어 장애, 호스트 네트워크/전원, AZ 차원 문제 | **AWS** (사용자는 인스턴스 **중지/시작**으로 다른 호스트 이전 또는 **복구**) |
| **인스턴스 상태 확인(Instance status check)** | **인스턴스 자체의 OS·구성** | 잘못된 네트워크 구성, 메모리 고갈, 손상된 파일시스템, 부팅 실패 | **사용자** (구성 수정·재부팅 등) |

**핵심 구분(시험 빈출):**

- 시스템 상태 확인 실패 = **AWS 호스트 문제** → 인스턴스를 **다른 정상 호스트로 이전**해야 함(중지 후 시작, 또는 자동 복구).
- 인스턴스 상태 확인 실패 = **내 인스턴스 내부 문제** → 재부팅으로는 안 풀릴 수 있고 **OS/구성을 직접 수정**해야 함.
- 대응 지표: `StatusCheckFailed_System`, `StatusCheckFailed_Instance`, `StatusCheckFailed`(둘 중 하나라도 실패).

> 🧠 원리: 왜 EC2는 상태 확인을 시스템과 인스턴스 두 층으로 나눌까요?
> 물리 호스트 문제는 사용자가 접근할 수 없는 AWS 인프라 영역이어서, 이를 OS 내부 문제와 동일한 확인으로 묶으면 원인이 어느 층인지 운영자가 알 수 없습니다.
> 두 확인을 분리하면 시스템 상태 확인 실패 시 "AWS 인프라 문제이므로 호스트 이전"을, 인스턴스 상태 확인 실패 시 "내 OS·구성을 직접 수정"을 즉시 판단할 수 있어 불필요한 OS 점검 시간을 줄입니다.
> 이 책임 경계 분리가 자동 복구(시스템 층)와 수동 수정(인스턴스 층)이라는 대응 수단의 분기 근거이기도 합니다.

### 4) EC2 자동 복구(Auto Recovery)

> 공식: **"인스턴스 복구(recover)는 기본 하드웨어 또는 시스템에 영향을 주는 문제로 손상된 인스턴스를 자동으로 복구한다."** 복구된 인스턴스는 **동일한 인스턴스 ID·프라이빗 IP·Elastic IP·메타데이터**를 유지합니다.

- **시스템 상태 확인 실패**(`StatusCheckFailed_System`)에 대해 **CloudWatch 경보의 EC2 복구 작업**을 걸거나, EC2의 **간소화된 자동 복구**로 자동 이전합니다.
- 복구는 인스턴스를 **새 호스트로 이전**하는 것이지 새 인스턴스를 만드는 게 아닙니다 → ID·IP가 보존됩니다. (단, 인메모리 데이터는 유실될 수 있습니다.)
- **자동 복구는 시스템 상태 확인(인프라) 문제**에 대응합니다. **인스턴스 상태 확인(OS 내부)** 문제는 복구로 풀리지 않을 수 있어 직접 수정이 필요합니다.

```
# 시스템 상태 확인 실패 시 자동 복구하는 CloudWatch 경보 (개념 예시)
# 지표: StatusCheckFailed_System, 작업: arn:aws:automate:<region>:ec2:recover
aws cloudwatch put-metric-alarm \
  --alarm-name "ec2-system-recover" \
  --namespace "AWS/EC2" --metric-name StatusCheckFailed_System \
  --dimensions Name=InstanceId,Value=i-1234 \
  --statistic Maximum --period 60 --evaluation-periods 2 \
  --threshold 1 --comparison-operator GreaterThanOrEqualToThreshold \
  --alarm-actions arn:aws:automate:ap-northeast-2:ec2:recover
```

> 🧠 원리: 왜 자동 복구는 인스턴스 ID와 Elastic IP를 그대로 유지할까요?
> 복구 작업은 새 인스턴스를 생성하는 것이 아니라 기존 인스턴스를 다른 정상 호스트로 이전(마이그레이션)하는 방식으로 동작합니다.
> 인스턴스 ID·프라이빗 IP·Elastic IP·메타데이터는 인스턴스 객체에 귀속된 식별자여서, 호스트가 바뀌어도 인스턴스 객체가 유지되는 한 식별자도 그대로 이어집니다.
> 이 덕분에 DNS 이름·보안 그룹 참조·탄력적 IP 연결 등 기존 구성을 변경하지 않고도 복구 후 즉시 정상 운영이 가능합니다.

### 5) ELB 대상 상태 확인(Health Check)

> 공식: **"로드 밸런서는 등록된 대상에 주기적으로 상태 확인 요청을 보내고, healthy인 대상에만 트래픽을 라우팅한다."**

| 설정 | 의미 |
|---|---|
| **HealthyThreshold** | 연속 몇 번 성공해야 **healthy**로 전환되는지 |
| **UnhealthyThreshold** | 연속 몇 번 실패해야 **unhealthy**로 전환되는지 |
| **Interval** | 상태 확인 주기(초) |
| **Timeout** | 응답 대기 시간(초) |
| **경로/포트/성공 코드** | HTTP(S) 상태 확인의 검사 경로와 정상 응답 코드(예: 200) |

**핵심 동작:**

- 대상이 **unhealthy로 판정되면 로드 밸런서가 트래픽 라우팅을 중단**해, 비정상 인스턴스를 자동으로 격리합니다. 다시 healthy가 되면 라우팅을 재개합니다.
- **Auto Scaling 그룹의 상태 확인을 ELB 기준으로** 설정하면, ELB가 unhealthy로 본 인스턴스를 ASG가 **종료하고 새 인스턴스로 교체**합니다(자가 치유).
- 상태 확인 경로는 애플리케이션이 실제로 살아있는지 검사하도록 설계해야 합니다(예: DB 연결까지 확인하는 `/health` 엔드포인트).

> 🧠 원리: 왜 ELB는 트래픽 제외만 하고 인스턴스 교체는 Auto Scaling에 위임할까요?
> ELB의 역할은 트래픽 분산이고, 인스턴스 수명 주기 관리는 Auto Scaling의 역할입니다. 두 관심사를 분리해야 각 서비스가 독립적으로 확장·조정될 수 있습니다.
> ELB가 직접 인스턴스를 종료·교체하면 스케일 정책·용량 설정·시작 템플릿 같은 Auto Scaling 구성이 우회되어 의도치 않은 용량 변동이 생길 수 있습니다.
> ASG 상태 확인 유형을 ELB로 설정하면, ELB의 unhealthy 판정이 ASG의 상태 확인 실패로 전달되어 ASG가 자체 교체 논리에 따라 인스턴스를 안전하게 종료·재생성합니다.

### 6) 문제 진단 접근 — 탐지 → 격리 → 복구

운영에서 가용성 문제를 다루는 표준 흐름:

```
① 탐지(Detect)   지표 경보(CloudWatch) / 상태 확인 실패 / Health 이벤트
② 분류(Triage)   AWS 인프라 문제? → Health Dashboard 확인
                 내 리소스 문제?  → 상태 확인 종류로 시스템 vs 인스턴스 구분
③ 격리(Isolate)  ELB가 unhealthy 대상 라우팅 제외 / ASG가 교체
④ 진단(Diagnose) 지표 이상 → 로그(CloudWatch Logs/Logs Insights) 확인 → 근본 원인
⑤ 복구(Recover)  자동 복구(시스템) / 구성 수정(인스턴스) / 재배포 / 스케일 조정
```

> 핵심은 **"지표 이상 → 로그 확인 → 근본 원인"**의 순서입니다. 지표는 증상(느림·오류율 상승)을 알려주고, 로그는 원인(특정 예외·의존성 실패)을 알려줍니다. 그리고 **AWS 측 문제와 내 측 문제를 먼저 가른 뒤** 적절한 복구 수단(자동 복구 vs 직접 수정)을 고릅니다.

> 🧠 원리: 왜 지표만으로는 장애 원인을 특정하기 어려울까요?
> 지표는 집계된 수치(평균 응답 시간, 오류 비율)여서 어느 요청·어느 코드 경로에서 문제가 발생했는지 세부 맥락이 없습니다.
> 로그는 개별 요청 단위의 예외 메시지·스택 트레이스·의존성 응답을 기록해, 지표의 이상 신호가 어떤 구체적 원인에서 비롯됐는지 좁혀줍니다.
> "지표 이상 → 로그 확인 → 근본 원인" 순서는 이 두 신호의 역할 차이를 반영하며, Health Dashboard 확인을 먼저 끼워 AWS 측 문제를 먼저 배제해야 로그 분석이 올바른 레이어에서 이루어집니다.

---

## ✍️ 시험 포인트

- **Service Health = 전체 서비스 공개 상태**, **Account/Personal Health = 내 계정·내 리소스 영향**(예정 유지 관리·권장 조치).
- 장애 의심 시 **AWS Health Dashboard 먼저 확인** — AWS 광역 장애면 내 구성 수정은 무의미.
- **AWS Health → EventBridge → SNS/Lambda**로 영향 이벤트 자동 수신·대응.
- **시스템 상태 확인 = AWS 인프라/호스트 문제** → 중지·시작(다른 호스트 이전) 또는 **자동 복구**.
- **인스턴스 상태 확인 = 인스턴스 OS·구성 문제** → 직접 수정(재부팅으로 안 풀릴 수 있음).
- **자동 복구는 `StatusCheckFailed_System`(시스템) 대상**. 복구 후 **인스턴스 ID·프라이빗 IP·EIP 유지**(인메모리는 유실 가능).
- **ELB 상태 확인**: UnhealthyThreshold 연속 실패 → 트래픽 제외(격리), HealthyThreshold 연속 성공 → 복귀.
- **ASG 상태 확인을 ELB로** 설정하면 unhealthy 인스턴스를 **종료·교체**(자가 치유).
- 진단 순서: **지표 이상 → 로그 확인 → 근본 원인**. AWS 측 vs 내 측 문제를 먼저 분리.

---

## ⚠️ 흔한 함정

1. **"서비스가 느리면 곧장 내 인스턴스를 디버깅한다."** → 먼저 **AWS Health Dashboard(특히 Account/Personal Health)**로 AWS 측 이벤트가 있는지 확인합니다. 광역 인프라 문제라면 내 구성을 고쳐도 해결되지 않습니다.
   *(원리: §1 — Account Health는 내 리소스에 영향을 주는 이벤트만 필터링해, AWS 측 문제와 자체 구성 문제를 빠르게 분류할 수 있게 한다.)*

2. **"시스템 상태 확인 실패는 내가 OS를 고쳐야 한다."** → 시스템 상태 확인은 **AWS 호스트/인프라** 문제입니다. 사용자는 **중지 후 시작(다른 호스트로 이전)**하거나 **자동 복구**로 대응합니다. OS를 고치는 것은 **인스턴스 상태 확인** 실패 때입니다.
   *(원리: §3 — 시스템 확인 실패는 인프라 층, 인스턴스 확인 실패는 OS 층으로 분리해 대응 수단(호스트 이전 vs 직접 수정)을 즉시 결정하게 한다.)*

3. **"인스턴스 상태 확인 실패는 자동 복구로 해결된다."** → 자동 복구는 **시스템(인프라) 문제**에 대응합니다. 인스턴스 상태 확인(잘못된 OS 구성·파일시스템 손상 등)은 복구로 해결되지 않을 수 있어 **직접 수정**해야 합니다.
   *(원리: §3 본문 — 자동 복구는 시스템 상태 확인(인프라 층) 실패를 대상으로 하며, 인스턴스 상태 확인(OS 층) 실패에는 적용되지 않는다.)*

4. **"자동 복구는 새 인스턴스를 만든다."** → 복구는 **같은 인스턴스를 새 정상 호스트로 이전**하는 것입니다. 인스턴스 ID·프라이빗 IP·EIP가 보존됩니다(인메모리·인스턴스 스토어 데이터는 유실될 수 있음). 새 인스턴스 생성·교체는 Auto Scaling의 역할입니다.
   *(원리: §4 — 복구는 인스턴스를 다른 정상 호스트로 이전하는 방식이어서, 인스턴스 객체가 유지되는 한 ID·IP 등 식별자도 이어진다.)*

5. **"ELB 상태 확인만 켜면 비정상 인스턴스가 교체된다."** → ELB는 unhealthy 대상에 **트래픽만 보내지 않을 뿐**, 인스턴스를 교체하지는 않습니다. **교체(종료 후 신규 시작)**까지 하려면 **Auto Scaling 그룹의 상태 확인 유형을 ELB로** 설정해야 합니다.
   *(원리: §5 — ELB는 트래픽 분산, 수명 주기 관리는 ASG로 역할이 분리되어 있어, 교체까지 하려면 ASG가 ELB의 unhealthy 판정을 전달받아야 한다.)*

6. **"지표만 보면 원인을 알 수 있다."** → 지표는 증상(지연·오류율)만 보여줍니다. 근본 원인은 **로그(CloudWatch Logs / Logs Insights)**에서 특정 예외·의존성 실패를 찾아야 좁혀집니다. 진단은 "지표 이상 → 로그 확인 → 근본 원인" 순서입니다.
   *(원리: §6 — 지표는 집계 수치로 증상만 드러내고, 로그는 개별 요청 맥락으로 구체적 원인을 담아 두 신호의 역할이 다르다.)*

---

## 🧪 자가 점검

> 아래는 학습용 자가 점검입니다. (정식 검증 문항은 별도 문항 파일 참조)

**Q1.** 여러 리전의 워크로드가 동시에 느려졌습니다. 내 애플리케이션 코드를 디버깅하기 전에 무엇을 먼저 확인해야 하나요?

<details><summary>정답 보기</summary>

**AWS Health Dashboard**, 특히 **Account/Personal Health(Your account)**를 먼저 확인합니다. 여기서 AWS 측 서비스 중단이나 내 리소스에 영향을 주는 이벤트가 있는지 봅니다. AWS 광역 인프라 문제라면 내 코드·구성을 고쳐도 소용없으므로, "AWS 측 문제인가 vs 내 측 문제인가"를 먼저 분류하는 것이 핵심입니다.
</details>

**Q2.** EC2 인스턴스의 **시스템 상태 확인**이 실패했습니다. 가장 적절한 자동 대응은 무엇이며, 복구 후 인스턴스 식별 정보는 어떻게 되나요?

<details><summary>정답 보기</summary>

시스템 상태 확인 실패는 **AWS 호스트/인프라** 문제이므로 **EC2 자동 복구**(또는 `StatusCheckFailed_System` 지표 경보 + recover 작업)로 대응합니다. 복구는 인스턴스를 **새 정상 호스트로 이전**하며, **인스턴스 ID·프라이빗 IP·Elastic IP가 보존**됩니다(인메모리 데이터는 유실될 수 있음). 이는 새 인스턴스를 만드는 것이 아닙니다.
</details>

**Q3.** Auto Scaling 그룹 뒤의 한 인스턴스에서 애플리케이션이 죽어 ELB 상태 확인이 계속 실패합니다. 트래픽 제외를 넘어 인스턴스를 자동 교체하려면 어떻게 설정하나요?

<details><summary>정답 보기</summary>

**Auto Scaling 그룹의 상태 확인 유형(Health Check Type)을 ELB로** 설정합니다. 그러면 ELB가 unhealthy로 판정한 인스턴스를 ASG가 **종료하고 새 인스턴스로 교체**합니다(자가 치유). ELB만으로는 unhealthy 대상에 트래픽을 보내지 않을 뿐 교체는 하지 않습니다. UnhealthyThreshold 설정으로 몇 번 연속 실패 시 비정상으로 볼지 조정합니다.
</details>

**Q4.** CloudWatch 경보로 응답 지연(p99 latency) 상승은 감지했지만 원인을 모릅니다. 다음 진단 단계는?

<details><summary>정답 보기</summary>

지표는 증상만 보여주므로, **CloudWatch Logs / Logs Insights에서 해당 시간대의 로그를 확인**해 근본 원인을 찾습니다(특정 예외, 다운스트림 의존성 타임아웃 등). 분산 시스템이면 **X-Ray 서비스 맵**으로 어느 구간이 느린지 좁힙니다. 진단 흐름은 "지표 이상 → 로그 확인 → 근본 원인"이며, 동시에 AWS Health로 인프라 측 문제 여부도 배제합니다.
</details>

**Q5 (원리).** 왜 ELB 상태 확인 유형만 설정하는 것으로는 비정상 인스턴스가 교체되지 않고, Auto Scaling 그룹의 상태 확인 유형도 함께 변경해야 할까요?

<details><summary>정답 보기</summary>

ELB는 트래픽 라우팅 담당이고 인스턴스 수명 주기 관리는 Auto Scaling 그룹의 역할입니다. ASG의 상태 확인 유형이 기본(EC2)이면 EC2 수준 실행 상태만 보기 때문에, ELB가 unhealthy로 판정해도 ASG는 해당 인스턴스가 정상이라고 봅니다. ASG의 상태 확인 유형을 ELB로 바꿔야 ELB의 unhealthy 결과가 ASG의 상태 판단 입력이 되어, ASG가 자체 교체 논리에 따라 인스턴스를 종료하고 새 인스턴스를 시작합니다.
</details>

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 AWS 자료를 기준으로 작성했습니다. (작성·대조: 2026-06-09 · 고도화 검수: 2026-06-12)

1. AWS Health란 무엇인가(Health Dashboard) — https://docs.aws.amazon.com/health/latest/ug/what-is-aws-health.html
2. AWS Health를 EventBridge와 통합 — https://docs.aws.amazon.com/health/latest/ug/cloudwatch-events-health.html
3. EC2 인스턴스 상태 확인(시스템 vs 인스턴스) — https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/monitoring-system-instance-status-check.html
4. EC2 인스턴스 자동 복구 — https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-recovery.html
5. ELB 대상 상태 확인(ALB) — https://docs.aws.amazon.com/elasticloadbalancing/latest/application/target-group-health-checks.html
</content>
