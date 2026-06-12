---
examGuideTaskId: soa-t3-3
certCode: SOA-C03
domain: 3
domainName: 배포, 프로비저닝 및 자동화
domainWeightPct: 22
title: Systems Manager 운영 자동화 (Run Command·Patch·State Manager·Parameter Store)
coversTasks:
  - "3.2"
sources:
  - title: AWS Systems Manager란 무엇인가 (공식)
    url: https://docs.aws.amazon.com/systems-manager/latest/userguide/what-is-systems-manager.html
  - title: Systems Manager Run Command (공식)
    url: https://docs.aws.amazon.com/systems-manager/latest/userguide/run-command.html
  - title: Systems Manager Session Manager (공식)
    url: https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html
  - title: Systems Manager State Manager (공식)
    url: https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-state.html
  - title: Systems Manager Parameter Store (공식)
    url: https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html
  - title: Parameter Store vs Secrets Manager 선택 (공식)
    url: https://docs.aws.amazon.com/systems-manager/latest/userguide/integration-ps-secretsmanager.html
lastVerified: 2026-06-09
---

# Systems Manager 운영 자동화 (Run Command·Patch·State Manager·Parameter Store)

> **커버하는 공식 Task** — SOA-C03 · 도메인 3 「배포, 프로비저닝 및 자동화」(22%) · **Task 3.2 기존 리소스 관리 자동화** (`soa-t3-3`)
> 이 문서는 Systems Manager로 인스턴스 플릿을 SSH 없이 일괄 운영·패치하는 절차에 집중합니다. EventBridge/Lambda 기반 자동화는 `soa-t3-4`에서 다룹니다.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명하고, 콘솔/CLI에서 직접 구성할 수 있어야 합니다.

- [ ] **관리형 인스턴스 조건** — SSM Agent + IAM 인스턴스 프로파일 + 엔드포인트 도달성을 설명할 수 있다
- [ ] **Run Command** — SSH 없이 명령을 일괄 실행하는 용도와 전제 조건을 안다
- [ ] **Session Manager** — 인바운드 포트·베이스천 없이 셸을 열고 감사 로깅하는 이점을 안다
- [ ] **Patch Manager** — 베이스라인·패치 그룹·유지 관리 기간으로 패치를 운영하는 절차를 안다
- [ ] **State Manager** — "원하는 상태"를 지속적으로 유지하는 용도를 안다
- [ ] **Automation 런북** — 다단계 운영 작업을 자동화하는 용도를 안다
- [ ] **Parameter Store** — 평문/SecureString·계층 구조, vs Secrets Manager(자동 교체·비용)를 구분한다
- [ ] **Inventory/Compliance** — 소프트웨어·패치 준수 상태를 수집·집계하는 용도를 안다

---

## 🎯 왜 중요한가

- Task 3.2의 본질은 **"이미 떠 있는 수십~수백 대 인스턴스를 어떻게 SSH 없이 안전하게 일괄 운영·패치하는가"**입니다. Systems Manager(SSM)는 SOA 운영의 중추이며, 시험에서 가장 자주 정답이 되는 서비스 묶음입니다.
- 시험은 **전제 조건**을 함정으로 냅니다. Run Command·Session Manager·Patch Manager가 동작하려면 인스턴스에 **SSM Agent**가 있어야 하고, **IAM 인스턴스 프로파일**(보통 `AmazonSSMManagedInstanceCore`)이 붙어야 하며, SSM 엔드포인트에 **도달 가능**해야 합니다. 이 셋이 빠지면 인스턴스가 콘솔의 관리형 목록에 안 보입니다.
- 보안 관점에서 SSM은 **인바운드 포트·베이스천·SSH 키를 없애는** 방향을 줍니다. Session Manager로 22번 포트를 열지 않고도 셸을 얻고, 모든 세션을 **감사 로깅**합니다. Parameter Store와 Secrets Manager의 선택(자동 교체가 필요한가, 비용은)도 단골 출제입니다.

---

## 🔤 먼저 알아야 할 용어

이 문서를 읽는 데 필요한 기초 용어입니다. 이미 알면 건너뛰세요.

| 용어 | 영문 | 한 줄 풀이 |
|---|---|---|
| **SSM Agent** | SSM Agent | 인스턴스에 설치되어 SSM 서비스와 통신하는 경량 프로세스 — 운전기사 없는 차처럼, 없으면 명령이 전달되지 않는다 |
| **IAM 인스턴스 프로파일** | IAM Instance Profile | EC2 인스턴스에 붙이는 IAM 역할 컨테이너 — 인스턴스가 AWS API를 호출할 때 쓸 자격증명을 제공한다 |
| **VPC 인터페이스 엔드포인트** | VPC Interface Endpoint | 프라이빗 서브넷에서 인터넷 없이 AWS 서비스에 접근하게 해주는 VPC 내부 ENI 기반 진입점 |
| **SecureString** | SecureString | Parameter Store의 파라미터 유형 중 KMS 키로 저장 시 암호화되는 값 — 평문 String과 달리 AWS KMS가 저장 데이터를 암호화한다 |
| **런북** | Runbook | SSM Automation에서 여러 단계의 운영 작업을 순서대로 기술한 YAML/JSON 문서 — 수동 절차서를 코드로 옮긴 것 |
| **유지 관리 기간** | Maintenance Window | 패치·업데이트 등 서비스 영향 작업을 허용할 정해진 시간 창 — 낮 업무 중 재부팅을 피하기 위한 스케줄 울타리 |
| **연결** | Association | State Manager가 인스턴스와 SSM 문서를 묶어 반복 적용 일정을 정의한 구성 항목 |

---

## 📖 핵심 개념

### 1) 관리형 인스턴스 — SSM이 동작하기 위한 전제

> 공식 정의: **"관리형 노드(managed node)는 Systems Manager용으로 구성된 인스턴스로, SSM Agent가 설치되어 있고 Systems Manager가 관리할 수 있는 상태다."**

**3가지 전제 조건:**

| 조건 | 내용 |
|---|---|
| **SSM Agent** | 인스턴스에 SSM Agent 설치·실행(최신 Amazon Linux·Windows AMI엔 기본 포함) |
| **IAM 인스턴스 프로파일** | SSM 권한 역할 연결(관리형 정책 **`AmazonSSMManagedInstanceCore`**) |
| **엔드포인트 도달성** | SSM 서비스 엔드포인트에 도달(NAT/IGW 또는 **VPC 인터페이스 엔드포인트**) |

> 셋 중 하나라도 빠지면 인스턴스가 **Fleet Manager의 관리형 노드 목록에 나타나지 않습니다.** "인스턴스가 SSM에 안 보인다"는 문제의 90%는 IAM 역할 누락 또는 엔드포인트 도달 불가입니다. 프라이빗 서브넷이면 인터넷 없이도 **VPC 인터페이스 엔드포인트**(ssm, ssmmessages, ec2messages)로 SSM을 쓸 수 있습니다.

> 🧠 원리: 세 조건 중 하나라도 빠지면 왜 인스턴스가 아예 목록에서 사라질까요?
> SSM의 연결 흐름은 인스턴스 → SSM 엔드포인트(네트워크) → AWS API 호출(IAM 권한) → Agent 응답의 체인으로 동작하며, 어느 링크 하나가 끊기면 서비스가 인스턴스 존재 자체를 확인할 수 없습니다.
> 네트워크가 막히면 등록 요청이 도달하지 않고, IAM이 없으면 요청이 도달해도 거부되므로, 결과는 동일하게 "연결 없음"으로 나타납니다.
> 이 구조 때문에 운영 현장에서는 "왜 안 보이냐"는 트러블슈팅을 세 조건 체크리스트 순서로 단계적으로 좁혀 나갑니다.

### 2) Run Command — SSH 없이 일괄 명령 실행

> 공식 정의: **"Run Command를 사용하면 관리형 노드의 구성을 원격으로·안전하게 관리할 수 있으며, SSH나 RDP로 로그인하지 않고 명령을 실행한다."**

- **SSM Agent를 통해** 명령을 실행하므로 **인바운드 포트·SSH 키가 필요 없습니다.**
- 대상은 **인스턴스 ID·태그·리소스 그룹**으로 지정해 한 번에 수백 대에 명령을 보냅니다(예: 패키지 설치, 스크립트 실행, 로그 수집).
- **속도 제어(concurrency)·오류 임계값(error threshold)**으로 점진적·안전하게 실행하고, 결과·출력을 S3/CloudWatch Logs에 남겨 감사합니다.

```
# 태그로 대상 지정해 셸 명령 일괄 실행 (SSH 불필요)
aws ssm send-command \
  --document-name "AWS-RunShellScript" \
  --targets "Key=tag:Role,Values=web" \
  --parameters 'commands=["yum -y update httpd"]' \
  --max-concurrency "10%" --max-errors "5"
```

> 🧠 원리: Run Command에서 concurrency와 error threshold를 따로 설정하는 이유는 무엇일까요?
> concurrency는 "한 번에 몇 대에 명령을 보낼 것인가"를 제어해 과부하 없이 점진적으로 배포하는 속도 조절 장치이고, error threshold는 "오류가 몇 건 나면 나머지 대상 실행을 멈출 것인가"를 제어하는 안전 차단 장치입니다.
> 두 설정이 분리된 이유는 속도와 안전성이 독립된 관심사이기 때문입니다 — 빠르게 실행하면서도 오류가 임계를 넘으면 즉시 멈출 수 있고, 느리게 실행하면서도 오류를 몇 건까지는 허용할 수도 있습니다.
> 이 분리 구조 덕분에 운영자는 플릿 규모와 위험 허용도에 맞게 두 값을 독립적으로 조정할 수 있습니다.

### 3) Session Manager — 포트·베이스천 없는 셸 + 감사

> 공식 정의: **"Session Manager는 인바운드 포트를 열거나 베이스천 호스트를 유지하거나 SSH 키를 관리할 필요 없이 관리형 노드에 대한 대화형 셸·원클릭 액세스를 제공한다."**

| 이점 | 설명 |
|---|---|
| **인바운드 포트 0** | 22/3389 포트를 열지 않음 → 공격 표면 축소 |
| **베이스천 불필요** | 점프 박스 없이 콘솔/CLI에서 바로 셸 |
| **SSH 키 불필요** | 키 배포·회전 관리 부담 제거 |
| **감사 로깅** | 세션 활동을 **CloudWatch Logs·S3**에 기록, **CloudTrail**로 시작/종료 감사 |
| **IAM 기반 접근 제어** | 누가 어느 인스턴스에 접속할지 IAM 정책으로 통제 |

> Session Manager는 **"베이스천을 없애라"**는 보안 단서가 나오면 거의 항상 정답입니다. 프라이빗 서브넷 인스턴스에도 인터넷·인바운드 없이(인터페이스 엔드포인트로) 안전하게 접속하고, 모든 명령을 로깅해 규정 준수를 만족합니다.

> 🧠 원리: Session Manager는 왜 인바운드 포트 없이도 인스턴스에 셸 채널을 열 수 있을까요?
> 전통적인 SSH는 클라이언트가 서버의 열린 포트에 연결을 시작하지만, Session Manager는 반대로 인스턴스의 SSM Agent가 SSM 서비스 엔드포인트로 아웃바운드 연결을 먼저 수립·유지하고, 사용자 요청이 오면 그 기존 채널을 통해 세션이 열립니다.
> 즉 인스턴스는 항상 나가는 방향으로만 통신하므로 인바운드 방화벽 규칙이 필요 없고, 공격자가 외부에서 포트를 스캔해도 열린 포트 자체가 없어 공격 표면이 사라집니다.
> 이 구조의 부산물로 세션 채널이 SSM을 경유하기 때문에 IAM 정책·CloudTrail·CloudWatch Logs가 일관되게 적용됩니다.

### 4) Patch Manager — 베이스라인·패치 그룹·유지 관리 기간

> 공식 정의: **"Patch Manager는 보안 관련 업데이트 및 기타 유형의 업데이트로 관리형 노드에 패치를 적용하는 작업을 자동화한다."**

| 구성요소 | 역할 |
|---|---|
| **패치 베이스라인(Patch Baseline)** | 승인/거부할 패치 규칙(분류·심각도·자동 승인 지연·예외) |
| **패치 그룹(Patch Group)** | **`Patch Group` 태그**로 인스턴스를 묶어 그룹별 베이스라인 적용 |
| **유지 관리 기간(Maintenance Window)** | 패치를 적용할 정해진 시간 창(서비스 영향 최소화) |

**운영 절차:**

```
① 인스턴스에 Patch Group 태그 부여 (예: Patch Group = prod-web)
② 같은 값을 패치 베이스라인에 등록(승인 규칙 정의)
③ 유지 관리 기간에 AWS-RunPatchBaseline 실행
   - Scan(스캔만, 설치 안 함) 또는 Install(설치+필요 시 재부팅)
④ Compliance에서 패치 준수 상태 확인
```

> 패치는 **언제(유지 관리 기간) · 무엇을(베이스라인) · 어디에(패치 그룹)**로 분리됩니다. dev는 빨리, prod는 검증 후 늦게 승인하는 식으로 환경별 정책을 다르게 운영합니다. 태그 키는 **`Patch Group`(공백·대소문자 정확히)**여야 인식됩니다.

> 🧠 원리: Patch Manager가 베이스라인·패치 그룹·유지 관리 기간을 세 요소로 분리한 이유는 무엇일까요?
> 세 요소는 각각 "무엇을 승인할 것인가(정책)", "어떤 인스턴스에 적용할 것인가(범위)", "언제 적용할 것인가(타이밍)"라는 독립된 관심사를 담고 있습니다.
> 만약 하나의 설정으로 합쳐 두면 dev와 prod에서 승인 규칙만 다르게 하거나, 같은 베이스라인을 유지하면서 배포 시간창만 바꾸는 식의 변경이 전체 재구성 없이 불가능합니다.
> 분리 구조 덕분에 환경이 늘어나도 필요한 요소만 바꿔 조합할 수 있어, 플릿 규모가 커질수록 관리 비용이 선형보다 느리게 증가합니다.

### 5) State Manager — 원하는 상태 유지

> 공식 정의: **"State Manager는 관리형 노드를 정의한 상태로 유지하도록 하는 안전하고 확장 가능한 구성 관리 서비스다."**

- **연결(association)**을 만들어 "이 인스턴스들은 항상 이 구성이어야 한다"를 선언하고, **일정에 따라 반복 적용**합니다(예: 에이전트가 항상 실행 중, 특정 포트 닫힘, 안티바이러스 설치됨).
- 인스턴스가 부팅되거나 드리프트되면 State Manager가 **원하는 상태로 다시 수렴**시킵니다.
- Run Command가 **일회성 명령**이라면, State Manager는 **지속적으로 상태를 강제**하는 구성 관리입니다.

> 🧠 원리: State Manager는 왜 일회성 명령이 아닌 반복 적용 연결 방식으로 설계됐을까요?
> 클라우드 환경에서는 인스턴스가 새로 시작되거나, 사람이 수동으로 설정을 바꾸거나, 패키지 업데이트가 구성을 되돌리는 "드리프트"가 지속적으로 발생합니다.
> 이런 환경에서 일회성 명령은 드리프트가 생긴 시점부터 원하는 상태와 실제 상태가 벌어지기 시작해, 감사 시점에 의도와 다른 상태가 발견될 수 있습니다.
> 반복 적용 연결 구조는 드리프트가 발생하더라도 다음 실행 주기에 자동으로 수렴시키므로, 플릿 규모가 커질수록 수동 개입 없이 준수 상태를 유지하는 비용이 선형보다 낮게 유지됩니다.

### 6) Automation 런북 — 다단계 작업 자동화

> 공식 정의: **"Automation을 사용하면 EC2 인스턴스·기타 AWS 리소스에 대한 일반적인 유지 관리·배포·교정 작업을 자동화하는 런북(runbook)을 정의할 수 있다."**

- **여러 단계로 이뤄진 운영 작업**(예: 인스턴스 중지 → 패치 → AMI 생성 → 재시작, 또는 비규정 리소스 교정)을 **런북(SSM 문서)**으로 정의해 한 번에 실행합니다.
- `AWS-*`로 시작하는 **사전 정의 런북**이 많고(예: `AWS-RestartEC2Instance`), 직접 만들 수도 있습니다.
- EventBridge·Config·CloudWatch 경보의 **자동 교정 대상**으로 자주 쓰입니다(상세는 `soa-t3-4`).

> 🧠 원리: Automation 런북이 여러 단계를 하나의 문서로 묶는 방식은 왜 운영 오류를 줄이는 데 유리할까요?
> 복잡한 운영 작업(예: 중지 → 패치 → AMI → 재시작)을 단계별 수동 절차로 수행하면 각 단계 사이에 사람이 개입해 순서 실수, 조건 미확인, 다음 단계 미실행 같은 오류가 발생할 수 있습니다.
> 런북은 선행 단계 성공 여부를 확인한 뒤 다음 단계로 진행하거나 실패 시 지정된 분기로 이동하는 로직을 문서 안에 내장해, 사람이 체크리스트를 직접 따라가는 부담을 제거합니다.
> 이 자동 순서 보장 덕분에 야간 배포나 비상 교정처럼 집중력이 떨어지는 상황에서도 절차가 일관되게 실행됩니다.

### 7) Parameter Store vs Secrets Manager

> 공식 정의: **"Parameter Store는 구성 데이터·비밀 관리를 위한 안전한 계층형 저장소를 제공한다."**

| 항목 | Parameter Store | Secrets Manager |
|---|---|---|
| **주 용도** | 구성값·비밀(평문 + SecureString) | 비밀(자격 증명) 전용 |
| **암호화** | **SecureString**(KMS로 암호화) | 항상 KMS 암호화 |
| **자동 교체(rotation)** | **기본 제공 안 함**(직접 Lambda 구성) | **기본 제공**(RDS 등 통합 자동 교체) |
| **계층 구조** | 경로형(`/app/prod/db/password`) | 태그·이름 기반 |
| **비용** | 표준 파라미터 **무료**(고급은 유료) | **비밀당 월 요금 + API 호출 요금** |

**핵심 사실:**

- **Parameter Store SecureString**은 **KMS로 암호화**된 값입니다. 단순 비밀 저장은 표준 파라미터로 무료에 가깝게 처리할 수 있습니다.
- **자동 교체(rotation)가 필요하면 Secrets Manager**입니다. RDS 자격 증명을 주기적으로 자동 회전하는 기능이 기본 내장입니다(Parameter Store는 직접 Lambda를 짜야 함).
- 비용에 민감하고 교체가 필요 없으면 Parameter Store, **자동 교체·교차 계정 비밀 공유가 핵심이면 Secrets Manager**를 선택합니다.

> 🧠 원리: Parameter Store와 Secrets Manager 중 어느 쪽을 쓸지 결정할 때 "자동 교체"가 핵심 분기가 되는 이유는 무엇일까요?
> 비밀 저장 자체는 Parameter Store SecureString도 KMS 암호화로 충분히 처리하지만, 자격증명의 생애주기 관리(주기적 교체, 교체 후 애플리케이션 갱신)는 단순 저장보다 훨씬 복잡한 오케스트레이션을 요구합니다.
> Secrets Manager는 이 교체 오케스트레이션을 내장 Lambda 로테이터와 RDS 통합으로 서비스화한 반면, Parameter Store는 저장·조회에만 집중해 그 복잡성을 사용자에게 위임합니다.
> 따라서 교체 주기와 연동이 필요한 시나리오에서는 Secrets Manager가 직접 구현 비용을 절약하고, 교체가 필요 없는 정적 설정값에는 Parameter Store가 비용과 관리 복잡도 면에서 유리합니다.

### 8) Inventory와 Compliance

- **Inventory**: 관리형 노드의 **설치된 소프트웨어·OS·네트워크 구성·업데이트** 등을 수집해 집계합니다(플릿 가시성).
- **Compliance**: 패치 적용 상태·State Manager 연결 상태가 **규정에 맞는지** 준수/비준수로 보고합니다. 패치 운영의 검증 단계가 여기서 닫힙니다.

> 🧠 원리: Inventory와 Compliance가 패치·구성 도구와 별도로 존재하는 이유는 무엇일까요?
> 패치나 구성 적용은 "실행했는가"를 추적하지만, 실행 결과가 의도한 상태로 반영됐는지는 별도로 검증해야 합니다 — 에이전트 오류, 재부팅 지연, 패키지 충돌로 실행이 성공해도 실제 상태가 다를 수 있기 때문입니다.
> Inventory는 인스턴스에서 실제 설치된 소프트웨어·OS 상태를 수집해 "지금 실제로 어떤가"를 기록하고, Compliance는 그 수집값을 베이스라인·연결 정책과 대조해 "원하는 상태와 일치하는가"를 판정합니다.
> 이 실행-검증 분리 구조 덕분에 Patch Manager 실행 후 Compliance 결과가 맞지 않으면 어느 인스턴스에서 무엇이 다른지 좁혀 재처리할 수 있습니다.

---

## ✍️ 시험 포인트

- **관리형 노드 3대 전제**: **SSM Agent + IAM 인스턴스 프로파일(`AmazonSSMManagedInstanceCore`) + 엔드포인트 도달성**. 안 보이면 보통 IAM 또는 엔드포인트 문제.
- **Run Command = SSH 없이 일괄 명령**. 대상은 인스턴스 ID·태그. concurrency·error threshold로 안전 실행.
- **Session Manager = 인바운드 포트 0 · 베이스천/SSH 키 불필요 + CloudWatch Logs/S3 감사 + CloudTrail**. "베이스천 제거" 단서면 정답.
- **Patch Manager = 베이스라인(무엇) + 패치 그룹(`Patch Group` 태그, 어디) + 유지 관리 기간(언제)**. `AWS-RunPatchBaseline`로 Scan/Install.
- **State Manager = 원하는 상태 지속 유지**(구성 관리). Run Command(일회성)와 구분.
- **Automation 런북 = 다단계 운영/교정 자동화**(SSM 문서).
- **Parameter Store SecureString(KMS)** vs **Secrets Manager(자동 교체 내장·비용 높음)**. **자동 교체 필요 → Secrets Manager**.
- 프라이빗 서브넷은 **VPC 인터페이스 엔드포인트(ssm·ssmmessages·ec2messages)**로 인터넷 없이 SSM 사용.

---

## ⚠️ 흔한 함정

1. **"SSM Agent만 깔면 Run Command가 된다."** → 에이전트뿐 아니라 **IAM 인스턴스 프로파일**(`AmazonSSMManagedInstanceCore`)과 **SSM 엔드포인트 도달성**이 모두 있어야 관리형 노드가 됩니다. 보통 누락된 것은 IAM 역할입니다.
   *(원리: §1 — SSM 연결은 네트워크·IAM·Agent 세 링크의 체인이며, 하나가 끊기면 목록에서 사라진다.)*

2. **"Session Manager를 쓰려면 22번 포트를 열어야 한다."** → 정반대입니다. Session Manager는 **인바운드 포트를 전혀 열지 않고** 셸을 제공합니다(에이전트가 아웃바운드로 SSM에 연결). 베이스천도 SSH 키도 필요 없습니다.
   *(원리: §3 — Agent가 아웃바운드로 SSM 채널을 유지하며 세션을 열므로 인바운드 포트가 필요 없다.)*

3. **"패치 그룹은 콘솔에서 그룹 객체를 만든다."** → 패치 그룹은 **`Patch Group` 태그**로 정의합니다. 태그 키 철자(공백 포함)가 정확해야 하며, 같은 값을 베이스라인에 등록해야 연결됩니다.
   *(원리: §4 — 세 요소는 독립된 관심사(정책·범위·타이밍)이며, 그룹은 태그로 인스턴스와 베이스라인을 연결한다.)*

4. **"Run Command로 구성을 한 번 맞추면 계속 유지된다."** → Run Command는 **일회성 실행**입니다. 부팅/드리프트 후에도 상태를 **지속적으로 강제**하려면 **State Manager**(연결)를 써야 합니다.
   *(원리: §5 — 드리프트는 지속 발생하며, 반복 적용 연결 구조가 다음 주기에 상태를 수렴시킨다.)*

5. **"비밀은 무조건 Secrets Manager여야 한다."** → 자동 교체가 필요 없고 비용을 아끼려면 **Parameter Store SecureString**(KMS 암호화)으로 충분합니다. **자동 교체(rotation)**가 핵심일 때만 Secrets Manager가 정답입니다.
   *(원리: §7 — 교체는 오케스트레이션이 필요하며, Secrets Manager가 이를 서비스로 내장한다.)*

6. **"프라이빗 서브넷에선 SSM을 못 쓴다."** → 인터넷이 없어도 **VPC 인터페이스 엔드포인트(ssm·ssmmessages·ec2messages)**를 만들면 SSM(Run Command·Session Manager·Patch)을 정상 사용할 수 있습니다.
   *(원리: §1 — VPC 인터페이스 엔드포인트로 도달성이 해결되면 프라이빗 서브넷에서도 SSM 체인이 완성된다.)*

---

## 🧪 자가 점검

> 아래는 학습용 자가 점검입니다. (정식 검증 문항은 별도 문항 파일 참조)

**Q1.** 새로 띄운 EC2 인스턴스가 Systems Manager 콘솔의 관리형 노드 목록에 나타나지 않습니다. 무엇을 점검해야 하나요?

<details><summary>정답 보기</summary>

세 가지를 점검합니다. ① **SSM Agent** 설치·실행 여부, ② **IAM 인스턴스 프로파일**에 `AmazonSSMManagedInstanceCore` 권한이 붙어 있는지, ③ 인스턴스가 **SSM 엔드포인트에 도달 가능한지**(퍼블릭은 IGW/NAT, 프라이빗은 ssm·ssmmessages·ec2messages **VPC 인터페이스 엔드포인트**). 가장 흔한 원인은 IAM 역할 누락 또는 엔드포인트 도달 불가입니다.
</details>

**Q2.** 보안팀이 "베이스천 호스트와 SSH 키를 모두 없애되, 운영자가 인스턴스 셸에 접속한 모든 활동을 감사 로깅하라"고 요구합니다. 어떤 기능을 쓰나요?

<details><summary>정답 보기</summary>

**Session Manager**를 사용합니다. 인바운드 포트를 열지 않고 베이스천·SSH 키 없이 셸을 제공하며, 접근은 **IAM 정책**으로 통제합니다. 세션 활동은 **CloudWatch Logs·S3**에 기록하고 시작/종료는 **CloudTrail**로 감사할 수 있어 규정 준수 요구를 만족합니다.
</details>

**Q3.** 수백 대 인스턴스를 환경별(dev/prod)로 다른 정책에 따라 정기 패치하고, 서비스 영향이 적은 시간대에만 설치되게 하려 합니다. 어떻게 구성하나요?

<details><summary>정답 보기</summary>

**Patch Manager**로 구성합니다. 인스턴스에 **`Patch Group` 태그**(예: dev/prod)를 부여하고, 각 그룹에 맞는 **패치 베이스라인**(승인 규칙)을 등록합니다. **유지 관리 기간(Maintenance Window)**을 서비스 영향이 적은 시간대로 잡아 `AWS-RunPatchBaseline`을 실행(Scan/Install)하고, **Compliance**에서 준수 상태를 확인합니다. 즉 무엇을(베이스라인)·어디에(패치 그룹)·언제(유지 관리 기간)를 분리해 환경별로 다르게 운영합니다.
</details>

**Q4.** 애플리케이션이 사용하는 RDS 자격 증명을 30일마다 자동으로 교체하려 합니다. Parameter Store와 Secrets Manager 중 무엇을 쓰고, 그 이유는?

<details><summary>정답 보기</summary>

**Secrets Manager**를 사용합니다. RDS 등과 통합된 **자동 교체(rotation)가 기본 제공**되어 Lambda를 직접 작성하지 않아도 주기적 회전이 가능합니다. Parameter Store의 SecureString은 KMS 암호화는 되지만 자동 교체가 내장돼 있지 않아 직접 구현해야 합니다. 비용은 Secrets Manager가 비밀당 요금이 있어 더 높지만, 자동 교체가 요구사항이면 이를 감수합니다.
</details>

**Q5 (원리).** 왜 State Manager 연결은 드리프트가 발생한 인스턴스에도 재실행 시 원하는 상태를 복원할 수 있을까요?

<details><summary>정답 보기</summary>

State Manager 연결은 일정 주기마다 지정된 SSM 문서를 인스턴스에 재적용합니다. 드리프트로 인해 실제 상태가 원하는 상태에서 벗어나더라도, 다음 실행 주기에 문서가 다시 적용되면서 상태가 수렴됩니다. 이 반복 적용 메커니즘 덕분에 드리프트가 발생해도 감사 시점까지 방치되지 않고 자동으로 교정됩니다.
</details>

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 AWS 자료를 기준으로 작성했습니다. (작성·대조: 2026-06-09)

1. AWS Systems Manager란 무엇인가 — https://docs.aws.amazon.com/systems-manager/latest/userguide/what-is-systems-manager.html
2. Run Command — https://docs.aws.amazon.com/systems-manager/latest/userguide/run-command.html
3. Session Manager — https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html
4. State Manager — https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-state.html
5. Parameter Store — https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html
6. Parameter Store vs Secrets Manager 선택 — https://docs.aws.amazon.com/systems-manager/latest/userguide/integration-ps-secretsmanager.html
