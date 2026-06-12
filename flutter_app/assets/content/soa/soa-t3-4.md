---
examGuideTaskId: soa-t3-4
certCode: SOA-C03
domain: 3
domainName: 배포, 프로비저닝 및 자동화
domainWeightPct: 22
title: 자동화 패턴 (EventBridge·Lambda·자동 복구)
coversTasks:
  - "3.2"
sources:
  - title: Amazon EventBridge란 무엇인가 (공식)
    url: https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-what-is.html
  - title: EventBridge 규칙 (이벤트 패턴·스케줄) (공식)
    url: https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-rules.html
  - title: CloudWatch 경보 작업으로 EC2 자동 복구·중지·종료 (공식)
    url: https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/UsingAlarmActions.html
  - title: Auto Scaling 상태 확인으로 비정상 인스턴스 교체 (공식)
    url: https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-health-checks.html
  - title: AWS Config 규칙으로 자동 교정 (공식)
    url: https://docs.aws.amazon.com/config/latest/developerguide/remediation.html
  - title: Lambda로 운영 작업 자동화 (공식)
    url: https://docs.aws.amazon.com/lambda/latest/dg/welcome.html
lastVerified: 2026-06-09
---

# 자동화 패턴 (EventBridge·Lambda·자동 복구)

> **커버하는 공식 Task** — SOA-C03 · 도메인 3 「배포, 프로비저닝 및 자동화」(22%) · **Task 3.2 기존 리소스 관리 자동화** (`soa-t3-4`)
> 이 문서는 이벤트 기반 "탐지 → 자동 대응" 파이프라인에 집중합니다. SSM 일괄 운영은 `soa-t3-3`, Config 상세는 도메인 4(`soa-t4-2`)에서 다루며 여기서는 자동화 관점만 봅니다.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명하고, 콘솔/CLI에서 직접 구성할 수 있어야 합니다.

- [ ] **EventBridge 규칙** — 이벤트 패턴 규칙과 스케줄 규칙의 차이를 설명할 수 있다
- [ ] **대상(Target)** — 규칙이 Lambda·SSM Automation·SNS 등으로 라우팅하는 흐름을 안다
- [ ] **EC2 자동 복구** — `StatusCheckFailed_System` 경보로 복구하는 동작을 안다
- [ ] **ASG 자동 교체** — 상태 확인 실패 인스턴스가 종료·재시작되는 자가 치유를 안다
- [ ] **이벤트 기반 교정** — 탐지(비규정 리소스 등) → Lambda/Automation 교정 파이프라인을 그릴 수 있다
- [ ] **Config 자동 교정** — Config 규칙 + SSM Automation 교정의 자동화 관점을 안다
- [ ] **Lambda 운영 자동화** — 서버 없이 운영 작업을 코드로 자동화하는 패턴을 안다

---

## 🎯 왜 중요한가

- Task 3.2의 다른 축은 **"사람이 보고 있지 않아도, 무언가 일어나면 자동으로 대응하라"**입니다. 운영자는 탐지(이벤트/경보)와 대응(Lambda/Automation/교체)을 파이프라인으로 엮어 **무인 자가 치유(self-healing)**를 구성합니다.
- 시험은 **"무엇이 트리거이고 무엇이 대상인가"**를 묻습니다. 상태/이벤트 변화는 EventBridge 규칙(이벤트 패턴)으로, 주기적 작업은 EventBridge 스케줄로, 지표 임계값 위반은 CloudWatch 경보로 잡습니다. 그 뒤 대상으로 Lambda·SSM Automation·SNS·ASG를 연결하는 조합이 핵심입니다.
- 자가 치유의 대표 함정도 출제됩니다. **EC2 자동 복구**는 하드웨어/호스트 장애(시스템 상태 점검)에 대응해 **같은 인스턴스를 이전**하지만, **ASG는 비정상 인스턴스를 종료하고 새로 띄웁니다**(다른 인스턴스). 둘은 동작과 적용 상황이 다릅니다.

---

## 🔤 먼저 알아야 할 용어

이 문서를 읽는 데 필요한 기초 용어입니다. 이미 알면 건너뛰세요.

| 용어 | 영문 | 한 줄 풀이 |
|---|---|---|
| **서버리스** | Serverless | 서버를 직접 관리하지 않고 코드만 배포하면 클라우드가 실행 환경을 자동 제공하는 컴퓨팅 모델 |
| **이벤트 버스** | Event Bus | EventBridge에서 이벤트가 흘러다니는 채널; AWS 서비스 이벤트는 기본(default) 이벤트 버스로 도착 |
| **IAM 역할** | IAM Role | AWS 서비스가 다른 서비스를 호출할 수 있도록 권한을 위임하는 자격 증명; 사람 계정이 아닌 서비스용 열쇠 |
| **게스트 OS** | Guest OS | EC2 인스턴스 위에서 실행되는 운영체제; AWS 호스트 인프라와 구분되는 사용자 영역 |
| **무상태** | Stateless | 인스턴스가 교체되어도 잃어버릴 데이터를 내부에 보관하지 않는 설계 방식 |
| **cron 식** | cron expression | "분 시 일 월 요일" 형태로 반복 실행 시각을 나타내는 스케줄 문법 |

---

## 📖 핵심 개념

### 1) EventBridge 규칙 — 이벤트 패턴 vs 스케줄

> 공식 정의: **"EventBridge는 이벤트를 사용해 애플리케이션 구성 요소를 연결하는 서버리스 서비스이며, 규칙(rule)이 들어오는 이벤트를 대상(target)으로 라우팅한다."**

| 규칙 유형 | 트리거 | 예 |
|---|---|---|
| **이벤트 패턴 규칙** | AWS 서비스/앱이 발생시킨 **이벤트가 패턴에 일치**할 때 | EC2 상태 `stopped`, Config 비규정, GuardDuty 발견 |
| **스케줄 규칙** | **cron/rate 식**에 따라 주기적으로 | 매일 02:00 정리 작업, 5분마다 점검 |

```
# 이벤트 패턴 예: EC2가 stopped 상태가 되면 트리거
{
  "source": ["aws.ec2"],
  "detail-type": ["EC2 Instance State-change Notification"],
  "detail": { "state": ["stopped"] }
}
```

> 이벤트 패턴 규칙은 **"무언가 일어났을 때(reactive)"**, 스케줄 규칙은 **"정해진 시각에(proactive)"** 동작합니다. AWS 서비스 이벤트 대부분은 기본 이벤트 버스(default event bus)로 흘러들어옵니다.

> 🧠 원리: EventBridge는 왜 이벤트 패턴과 스케줄을 하나의 규칙 모델로 합치지 않고 두 종류로 나눌까요?
> 이벤트 패턴 규칙은 "이벤트가 실제로 도착했을 때"만 평가되므로 트리거가 없으면 규칙 엔진이 관여하지 않지만, 스케줄 규칙은 이벤트 없이도 내부 타이머가 지정한 시각에 독립적으로 동작해야 합니다.
> 두 메커니즘이 서로 다른 내부 경로를 거치기 때문에, 단일 모델로 합치면 어느 쪽 사용자도 불필요한 복잡도를 떠안게 됩니다.
> 따라서 AWS는 두 경로를 규칙 유형으로 명시적으로 분리하고, 운영자가 의도에 따라 선택하도록 설계했습니다.

### 2) 대상(Target) — 무엇을 실행하나

| 대상 | 용도 |
|---|---|
| **Lambda 함수** | 커스텀 로직으로 즉시 처리·교정·알림 |
| **SSM Automation 런북** | 다단계 운영/교정 작업 자동 실행(예: 인스턴스 재시작·태그 강제) |
| **SSM Run Command** | 대상 인스턴스에 명령 실행 |
| **SNS 주제** | 이메일·SMS·팬아웃 알림 |
| **Step Functions** | 복잡한 워크플로 오케스트레이션 |

> 하나의 규칙에 **여러 대상**을 붙일 수 있습니다(예: Lambda로 교정 + SNS로 알림 동시에). 대상 호출에는 EventBridge가 사용할 **IAM 역할/리소스 권한**이 필요합니다.

> 🧠 원리: EventBridge 규칙이 Lambda나 SSM Automation을 실행하려면 왜 별도 IAM 역할이 필요할까요?
> EventBridge는 사용자를 대신해 다른 서비스 API를 호출하는 구조이므로, 그 호출이 허용된 주체임을 AWS가 확인할 수 있어야 합니다.
> IAM 역할을 EventBridge 서비스 주체에 위임하면, AWS가 서명된 자격 증명으로 대상 API를 호출하고 감사 로그에도 역할 ARN이 남아 추적이 가능해집니다.
> 권한이 규칙마다 명시적으로 연결되기 때문에, 의도하지 않은 대상 호출을 최소 권한 원칙으로 제한할 수 있습니다.

### 3) CloudWatch 경보 → 자동 작업 (EC2 자동 복구)

> 공식 정의: **"경보 작업을 사용하면 EC2 인스턴스를 자동으로 중지·종료·재부팅·복구할 수 있다."**

| 작업 | 의미 |
|---|---|
| **복구(Recover)** | **시스템 상태 점검 실패**(호스트/하드웨어 장애) 시 **같은 인스턴스를 정상 호스트로 이전** — **인스턴스 ID·프라이빗 IP·EBS 유지** |
| **재부팅/중지/종료** | 정책에 따른 자동 조치 |

**핵심 사실:**

- **EC2 자동 복구**는 `StatusCheckFailed_System` 지표 경보 + **복구 작업**으로 구성합니다. **기반 하드웨어 장애**에 대응하며, 새 인스턴스를 만드는 게 아니라 **동일 인스턴스를 옮깁니다**(상태·IP 보존).
- 인스턴스 **내부(게스트 OS) 문제**는 `StatusCheckFailed_Instance`로 잡히며, 보통 **재부팅**이나 ASG 교체로 대응합니다. 둘(System vs Instance 상태 점검)을 혼동하지 않는 것이 시험 포인트입니다.

> 🧠 원리: EC2 자동 복구는 왜 새 인스턴스를 만들지 않고 같은 인스턴스를 정상 호스트로 옮기는 방식을 취할까요?
> 자동 복구의 대상은 호스트(하드웨어·하이퍼바이저) 장애이며, 인스턴스 자체의 EBS·설정·메모리 상태는 문제가 없습니다.
> 인스턴스를 새로 만들면 인스턴스 ID와 프라이빗 IP가 바뀌어 해당 정보에 의존하는 연동(고정 IP 설정, 인스턴스 ID 참조 정책 등)이 모두 깨집니다.
> 반면 같은 인스턴스를 정상 호스트로 이전하면 인스턴스 식별 정보가 유지되어 추가 재설정 없이 서비스가 재개됩니다.

### 4) Auto Scaling 자동 교체 — 자가 치유

> 공식: **"Auto Scaling 그룹은 상태 확인에서 비정상으로 판정된 인스턴스를 종료하고 새 인스턴스로 교체한다."**

- ASG는 **EC2 상태 점검** 또는 **ELB 상태 점검**을 사용해 인스턴스 건강을 판단합니다. 비정상이면 **종료 후 새 인스턴스 시작**으로 원하는 용량을 유지합니다.
- EC2 자동 복구가 **같은 인스턴스를 살리는** 것과 달리, ASG는 **비정상 인스턴스를 버리고 새것으로 대체**합니다. 상태가 인스턴스에 묶이지 않는 무상태(stateless) 워크로드에 적합합니다.

> 시험 단서 구분: "하드웨어 장애 시 **같은 인스턴스** 유지(IP·EBS 보존)" → **EC2 자동 복구**. "비정상 인스턴스를 **교체**해 용량 유지" → **ASG 상태 확인 + 교체**.

> 🧠 원리: ASG는 왜 비정상 인스턴스를 복구하지 않고 종료 후 새 인스턴스로 교체하는 방식을 선택했을까요?
> ASG의 설계 전제는 인스턴스를 교체 가능한 소모품으로 취급하는 것이며, 문제의 원인이 OS·앱 구성일 때 복구를 시도하면 같은 장애가 재발할 수 있습니다.
> 새 인스턴스는 시작 템플릿·AMI로부터 깨끗한 상태로 시작하므로 일시적 OS 오염이나 앱 상태 오염을 원천 차단합니다.
> 원하는 용량 유지가 목표이므로, 비정상 인스턴스의 회복 가능성을 기다리는 것보다 즉시 교체하는 편이 가용성 확보에 유리합니다.

### 5) 이벤트 기반 자동 교정 파이프라인

**대표 패턴 — 탐지 → 대응:**

```
[탐지]                          [대응]
Config 비규정 / GuardDuty 발견  → EventBridge 규칙  → Lambda(교정 로직)
 / 특정 API 호출(CloudTrail)                         또는 SSM Automation 런북
                                                    + SNS(알림)
```

- 예 1: **퍼블릭 S3 버킷 탐지** → EventBridge → Lambda가 퍼블릭 액세스 차단 적용 + SNS 알림.
- 예 2: **태그 누락 리소스 생성** → EventBridge(또는 Config 규칙) → SSM Automation 런북이 태그 강제.
- 예 3: **루트 계정 로그인(CloudTrail 이벤트)** → EventBridge → SNS 즉시 경보.

> 핵심은 **"무엇이 탐지를 발생시키나(Config/GuardDuty/CloudTrail/지표) → 무엇이 라우팅하나(EventBridge/경보) → 무엇이 교정하나(Lambda/Automation)"**의 3단 구조입니다.

> 🧠 원리: 이벤트 기반 교정 파이프라인은 왜 탐지·라우팅·교정을 하나의 서비스로 합치지 않고 3단 구조로 분리할까요?
> 탐지 소스는 Config·GuardDuty·CloudTrail 등 각기 다른 서비스가 담당하고, 라우팅은 EventBridge가 패턴 매칭과 팬아웃을 처리하며, 교정 로직은 Lambda나 SSM Automation이 수행합니다.
> 각 레이어가 독립적으로 교체 가능하면, 교정 로직만 바꾸거나 탐지 소스를 추가해도 다른 레이어에 영향을 주지 않습니다.
> 이 느슨한 결합 덕분에 하나의 탐지 이벤트를 여러 교정 대상으로 동시에 라우팅하거나, 동일 교정 Lambda를 여러 탐지 규칙이 공유하는 구성이 가능합니다.

### 6) AWS Config 규칙 + 자동 교정 (자동화 관점)

> Config의 평가·규칙 상세는 도메인 4(`soa-t4-2`)에서 다룹니다. 여기서는 **자동 교정 연결**만 봅니다.

- **Config 규칙**이 리소스를 평가해 **준수(COMPLIANT)/비준수(NON_COMPLIANT)**로 판정합니다.
- 비준수 리소스에 **교정 작업(Remediation)**을 연결하면, 보통 **SSM Automation 런북**을 실행해 자동으로 바로잡습니다(예: 비암호화 EBS 볼륨 탐지 → 교정 런북).
- **자동 교정(automatic remediation)**으로 설정하면 사람 개입 없이 비준수 발견 즉시 교정이 실행됩니다.

> 운영 관점에서 "비규정 리소스를 자동으로 바로잡고 싶다"는 단서는 **Config 규칙 + SSM Automation 교정**으로 이어집니다. EventBridge로 Config 변경 이벤트를 받아 커스텀 Lambda 교정을 붙이는 변형도 있습니다.

> 🧠 원리: Config 자동 교정은 왜 SSM Automation 런북을 교정 실행 레이어로 사용할까요?
> Config는 리소스가 규칙을 준수하는지 평가하는 역할만 담당하며, 실제 변경 작업을 수행하는 실행 엔진을 내장하지 않습니다.
> SSM Automation 런북은 AWS 리소스를 변경하는 다단계 작업을 사전 정의된 문서로 표현할 수 있고, IAM 권한 범위 안에서 재사용·감사가 가능합니다.
> 역할 분리 덕분에 동일한 교정 런북을 Config 교정, EventBridge 트리거, 수동 실행 등 여러 경로에서 공통으로 호출할 수 있습니다.

### 7) Lambda로 운영 작업 자동화

- **서버를 관리하지 않고** 운영 로직을 코드로 실행합니다. EventBridge 규칙·경보·Config·S3 이벤트 등 다양한 소스가 Lambda를 트리거합니다.
- 운영 예: 스냅샷 정리, 미사용 리소스 태깅/종료, 비용 알림, 교정 로직, 슬랙/SNS 통지.
- **SSM Automation 런북**이 AWS 표준 작업에 적합하다면, **Lambda**는 표준 런북으로 표현하기 어려운 **커스텀 로직**에 적합합니다. 둘을 EventBridge 대상으로 함께 쓰는 경우가 많습니다.

> 🧠 원리: Lambda는 왜 EventBridge·Config·경보 등 다양한 트리거 소스와 자연스럽게 연결될까요?
> Lambda의 실행 모델은 "이벤트 페이로드를 받아 코드를 실행하고 종료"이며, 트리거가 누구인지에 무관하게 동일한 핸들러 인터페이스로 호출됩니다.
> 이 인터페이스 표준화 덕분에 Lambda는 이벤트 스키마만 맞으면 어떤 소스에서든 호출될 수 있고, 운영자는 트리거마다 별도 실행 환경을 준비할 필요가 없습니다.
> 결과적으로 Lambda 하나가 교정 로직·알림·태깅 등 다양한 운영 작업을 맥락에 따라 처리하는 범용 자동화 단위가 됩니다.

---

## ✍️ 시험 포인트

- **EventBridge 규칙 2종**: **이벤트 패턴**(반응형, 서비스 이벤트 일치) vs **스케줄**(cron/rate, 주기적).
- **대상**: Lambda · **SSM Automation 런북** · Run Command · SNS · Step Functions(한 규칙에 다중 대상 가능).
- **EC2 자동 복구 = `StatusCheckFailed_System`(호스트 장애) → 같은 인스턴스 이전(ID·IP·EBS 보존)**.
- **인스턴스 상태 점검(`StatusCheckFailed_Instance`)** = 게스트 OS 문제 → 재부팅/교체.
- **ASG 상태 확인 + 교체** = 비정상 인스턴스 **종료 후 새로 시작**(자가 치유, stateless). 복구(같은 인스턴스 유지)와 구분.
- **탐지→대응 파이프라인**: Config/GuardDuty/CloudTrail/지표 → **EventBridge(또는 경보)** → **Lambda/SSM Automation** (+ SNS 알림).
- **Config 자동 교정 = Config 규칙(비준수) + SSM Automation 런북**. 자동 교정 시 사람 개입 없이 즉시 교정.
- **Lambda = 커스텀 운영 로직**, **Automation 런북 = AWS 표준 다단계 작업**. 상황에 맞게 선택/병행.

---

## ⚠️ 흔한 함정

1. **"EC2 자동 복구는 새 인스턴스를 만든다."** → 아닙니다. 자동 복구는 **같은 인스턴스를 정상 호스트로 이전**하며 **인스턴스 ID·프라이빗 IP·EBS 볼륨을 유지**합니다. 새 인스턴스로 교체하는 것은 **ASG**입니다.
   *(원리: §3 — 장애 원인이 호스트이고 인스턴스 상태는 정상이므로, 인스턴스 식별 정보를 유지한 채 이전한다)*

2. **"시스템 상태 점검과 인스턴스 상태 점검은 같다."** → `StatusCheckFailed_System`은 **AWS 측 호스트/하드웨어** 문제(→ 복구로 대응), `StatusCheckFailed_Instance`는 **게스트 OS/구성** 문제(→ 재부팅/교체)입니다.
   *(원리: §3 — 장애 위치가 호스트면 인스턴스 이전, 게스트 OS면 재부팅·교체로 대응 경로가 나뉜다)*

3. **"주기적 작업도 이벤트 패턴 규칙으로 만든다."** → 주기적·시간 기반 작업은 **스케줄 규칙(cron/rate)**입니다. 이벤트 패턴 규칙은 서비스 이벤트가 발생했을 때 반응합니다.
   *(원리: §1 — 이벤트 패턴은 이벤트 도착 시에만 동작하고, 스케줄은 이벤트 없이 내부 타이머로 동작하는 별도 경로다)*

4. **"비규정 리소스를 자동으로 고치려면 Lambda를 직접 짜야만 한다."** → 많은 경우 **Config 규칙 + SSM Automation 교정 런북**으로 코드 없이 자동 교정할 수 있습니다. 표준 런북으로 안 되는 커스텀 로직에만 Lambda를 씁니다.
   *(원리: §6 — Config는 평가만 하고 실행은 SSM Automation 런북이 담당하므로, 표준 작업은 런북으로 충분하다)*

5. **"규칙 하나엔 대상 하나만 붙는다."** → EventBridge 규칙에는 **여러 대상**을 붙일 수 있습니다(예: 교정 Lambda + 알림 SNS 동시 실행).
   *(원리: §2 — EventBridge가 IAM 역할 범위 안에서 각 대상을 독립 호출하므로 팬아웃이 가능하다)*

6. **"ASG는 인스턴스 내부 앱이 죽어도 교체한다."** → 기본 **EC2 상태 점검만**으로는 앱 장애를 못 잡습니다. 애플리케이션 수준 장애로 교체하려면 **ELB 상태 점검**을 ASG에 연결해야 합니다.
   *(원리: §4 — ASG는 연결된 상태 점검 소스가 인식한 장애만 교체 트리거로 삼으므로, 앱 응답은 ELB 상태 점검을 추가해야 감지된다)*

---

## 🧪 자가 점검

> 아래는 학습용 자가 점검입니다. (정식 검증 문항은 별도 문항 파일 참조)

**Q1.** 단일(비ASG) EC2 인스턴스가 **기반 호스트 하드웨어 장애**를 겪을 때, 인스턴스 ID와 프라이빗 IP·데이터를 유지한 채 자동으로 정상 호스트로 옮기고 싶습니다. 어떻게 구성하나요?

<details><summary>정답 보기</summary>

`StatusCheckFailed_System` 지표에 **CloudWatch 경보**를 만들고 **EC2 복구(Recover) 작업**을 연결합니다. 자동 복구는 새 인스턴스를 만드는 것이 아니라 **같은 인스턴스를 정상 호스트로 이전**하며 **인스턴스 ID·프라이빗 IP·EBS 볼륨을 보존**합니다. 게스트 OS 문제(`StatusCheckFailed_Instance`)는 재부팅으로, 무상태 워크로드의 용량 유지는 ASG 교체로 처리한다는 점과 구분합니다.
</details>

**Q2.** 매일 새벽 2시에 오래된 EBS 스냅샷을 정리하는 작업을 서버 없이 자동화하려 합니다. 무엇을 어떻게 연결하나요?

<details><summary>정답 보기</summary>

**EventBridge 스케줄 규칙**(cron 식, 매일 02:00)을 만들어 대상으로 **Lambda 함수**(또는 SSM Automation 런북)를 연결합니다. Lambda가 오래된 스냅샷을 찾아 삭제하는 로직을 수행합니다. 시간 기반 주기 작업이므로 이벤트 패턴이 아니라 **스케줄 규칙**을 쓰는 것이 핵심입니다.
</details>

**Q3.** S3 버킷이 실수로 퍼블릭으로 설정되면 즉시 자동으로 차단하고 보안팀에 알리고 싶습니다. 어떤 파이프라인을 구성하나요?

<details><summary>정답 보기</summary>

탐지는 **AWS Config 규칙**(예: s3-bucket-public-read 금지) 또는 GuardDuty/EventBridge 이벤트로 합니다. 비준수 발견을 **EventBridge 규칙**(또는 Config 자동 교정)으로 라우팅해 **Lambda 또는 SSM Automation 런북**이 퍼블릭 액세스 차단을 적용하고, 동시에 **SNS**로 보안팀에 알립니다. 즉 "탐지(Config/GuardDuty) → 라우팅(EventBridge) → 교정(Lambda/Automation) + 알림(SNS)"의 3단 파이프라인입니다.
</details>

**Q4.** Auto Scaling 그룹의 인스턴스에서 웹 애플리케이션 프로세스가 죽었는데도 인스턴스가 교체되지 않습니다. 왜이고 어떻게 해결하나요?

<details><summary>정답 보기</summary>

ASG가 기본 **EC2 상태 점검만** 사용하면 인스턴스(VM)는 정상으로 보여 앱 장애를 감지하지 못합니다. ASG에 **ELB(로드밸런서) 상태 점검**을 연결해 애플리케이션 응답을 기준으로 건강을 판단하게 하면, 앱이 응답하지 않는 인스턴스를 비정상으로 보고 **종료 후 새 인스턴스로 교체**합니다.
</details>

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 AWS 자료를 기준으로 작성했습니다. (작성·대조: 2026-06-09)

1. Amazon EventBridge란 무엇인가 — https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-what-is.html
2. EventBridge 규칙(이벤트 패턴·스케줄) — https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-rules.html
3. CloudWatch 경보 작업으로 EC2 자동 복구·중지·종료 — https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/UsingAlarmActions.html
4. Auto Scaling 상태 확인으로 비정상 인스턴스 교체 — https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-health-checks.html
5. AWS Config 규칙으로 자동 교정 — https://docs.aws.amazon.com/config/latest/developerguide/remediation.html
6. Lambda로 운영 작업 자동화 — https://docs.aws.amazon.com/lambda/latest/dg/welcome.html
