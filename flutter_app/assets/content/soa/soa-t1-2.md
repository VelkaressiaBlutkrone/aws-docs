---
examGuideTaskId: soa-t1-2
certCode: SOA-C03
domain: 1
domainName: 모니터링, 로깅, 분석, 문제 해결 및 성능 최적화
domainWeightPct: 22
title: CloudWatch Logs·Logs Insights·구독 필터·에이전트
coversTasks:
  - "1.1"
sources:
  - title: CloudWatch Logs란 무엇인가 (공식)
    url: https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/WhatIsCloudWatchLogs.html
  - title: 로그 그룹과 로그 스트림 작업 (공식)
    url: https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/Working-with-log-groups-and-streams.html
  - title: 지표 필터로 로그 이벤트에서 지표 생성 (공식)
    url: https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/MonitoringLogData.html
  - title: 구독 필터를 사용한 실시간 로그 처리 (공식)
    url: https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/Subscriptions.html
  - title: CloudWatch Logs Insights 쿼리 구문 (공식)
    url: https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CWL_QuerySyntax.html
  - title: CloudWatch 에이전트 설치 (공식)
    url: https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/install-CloudWatch-Agent-on-EC2-Instance.html
lastVerified: 2026-06-12
---

# CloudWatch Logs·Logs Insights·구독 필터·에이전트

> **커버하는 공식 Task** — SOA-C03 · 도메인 1 「모니터링, 로깅, 분석, 문제 해결 및 성능 최적화」(22%) · **Task 1.1 AWS 모니터링 및 로깅 서비스를 사용하여 지표, 경보 및 필터 구현** (`soa-t1-2`)
> 이 문서는 로그 수집·검색·실시간 전송과 CloudWatch 에이전트에 집중합니다. 지표·경보·대시보드는 `soa-t1-1`, 감사·이벤트·추적은 `soa-t1-3`에서 다룹니다.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명하고, 콘솔/CLI에서 직접 구성할 수 있어야 합니다.

- [ ] **로그 구조** — 로그 그룹 / 로그 스트림 / 로그 이벤트의 계층 관계를 설명할 수 있다
- [ ] **보존 정책** — 기본 보존이 "무기한"이며 그룹 단위로 보존 기간을 설정해야 함을 안다
- [ ] **지표 필터** — 로그 패턴을 CloudWatch 지표로 변환해 경보로 연결하는 흐름을 구성할 수 있다
- [ ] **구독 필터** — 로그를 Kinesis Data Streams·Firehose·Lambda·OpenSearch로 실시간 전송하는 용도를 안다
- [ ] **Logs Insights** — 기본 쿼리 구문(`fields`/`filter`/`stats`/`sort`)으로 로그를 분석할 수 있다
- [ ] **CloudWatch 에이전트** — OS 지표(메모리·디스크)와 로그를 수집하는 구성→배포→검증 절차를 안다
- [ ] **EMF** — 임베디드 지표 형식이 로그 한 줄로 구조화 지표를 게시하는 방식임을 안다

---

## 🎯 왜 중요한가

- 로그는 SOA 운영의 1차 증거물입니다. 지표가 "무언가 잘못됐다"를 알려준다면, **로그는 "정확히 무엇이 어떻게 잘못됐나"**를 알려줍니다. 도메인 1(22%)에서 로그 수집·검색·실시간 처리 흐름은 반복 출제됩니다.
- 시험은 "로그를 어떻게 보관·검색·전달하는가"의 **구체적 설정**을 묻습니다. 보존 기간 기본값, 지표 필터로 에러를 경보화하는 절차, 구독 필터의 대상(Lambda/Kinesis/Firehose), 그리고 **메모리·디스크 지표는 에이전트가 있어야 수집된다**는 점이 함정으로 자주 나옵니다.
- SOA는 운영 자격증이므로 단순 개념이 아니라 **운영 절차**를 요구합니다. 에이전트 구성 파일을 작성하고 SSM으로 배포한 뒤 로그 그룹에서 수집을 검증하는 순서, 지표 필터로 패턴을 잡아 경보로 연결하는 파이프라인을 직접 그릴 수 있어야 합니다.

---

## 🔤 먼저 알아야 할 용어

이 문서를 읽는 데 필요한 기초 용어입니다. 이미 알면 건너뛰세요.

| 용어 | 영문 | 한 줄 풀이 |
|---|---|---|
| **IAM 역할** | IAM Role | AWS 리소스에 임시 권한을 부여하는 자격 증명 단위 — 인스턴스에 연결해 API 호출 권한을 위임 |
| **하이퍼바이저** | Hypervisor | 물리 서버 위에서 여러 가상 머신을 격리·관리하는 가상화 레이어 |
| **게스트 OS** | Guest OS | 하이퍼바이저 위에서 실행되는 가상 머신 내부의 운영 체제 — 메모리·디스크 상태를 직접 관리 |
| **SSM** | AWS Systems Manager | 에이전트 기반으로 EC2·온프레미스 서버를 원격 관리하는 운영 자동화 서비스 |
| **네임스페이스** | Namespace | CloudWatch에서 지표를 논리적으로 분류하는 그룹 이름 — 서비스·에이전트별로 구분 |
| **Parameter Store** | SSM Parameter Store | 구성 값·비밀 정보를 안전하게 저장·조회하는 SSM 내 키-값 저장소 |
| **Lambda** | AWS Lambda | 서버 프로비저닝 없이 코드를 실행하는 이벤트 기반 컴퓨팅 서비스 |

---

## 📖 핵심 개념

### 1) 로그 그룹·로그 스트림·로그 이벤트

> 공식 정의: **"로그 이벤트(log event)는 모니터링되는 애플리케이션·리소스가 기록한 활동 레코드이며, 같은 소스를 공유하는 이벤트들이 로그 스트림으로, 보존·모니터링·접근 제어 설정을 공유하는 스트림들이 로그 그룹으로 묶인다."**

| 계층 | 의미 | 예시 |
|---|---|---|
| **로그 그룹(Log group)** | 보존·권한·지표 필터 설정을 공유하는 스트림의 컨테이너 | `/aws/lambda/my-func`, `/var/log/app` |
| **로그 스트림(Log stream)** | 같은 소스(한 인스턴스·한 컨테이너 등)에서 온 이벤트의 시퀀스 | `i-1234abcd`, `2026/06/09/[$LATEST]…` |
| **로그 이벤트(Log event)** | 타임스탬프 + 원시 메시지 한 줄 | `1718000000 ERROR NullPointer…` |

**핵심 사실:**

- **보존·지표 필터·구독 필터·암호화·권한은 모두 로그 그룹 단위로 설정**합니다. 로그 스트림 단위로는 설정하지 않습니다.
- 로그 이벤트는 **타임스탬프 기준으로 정렬**되며, 스트림은 보통 소스 인스턴스/컨테이너 하나에 대응합니다.
- 로그 그룹 이름은 슬래시 규칙(`/aws/<service>/...`)을 자주 따르지만 강제는 아닙니다.

> 🧠 원리: 왜 보존·지표 필터·권한 같은 설정은 스트림이 아닌 그룹 단위로 적용될까요?
> 로그 스트림은 인스턴스 하나·컨테이너 하나에 대응하며, 인스턴스가 교체되거나 재배포될 때마다 새로운 스트림이 생성됩니다.
> 스트림 단위로 설정을 붙이면 인스턴스가 늘어날 때마다 동일 설정을 반복해야 해 관리 부담이 커집니다.
> 그룹은 서비스나 애플리케이션이라는 논리적 경계를 나타내므로, 그룹 단위로 한 번 설정하면 그 안에 생성되는 모든 스트림이 일관된 정책을 따릅니다.

### 2) 보존 기간 — 기본은 "무기한"

> **중요(시험 빈출):** 로그 그룹의 **기본 보존 기간은 "만료되지 않음(Never expire)" — 즉 무기한 보관**입니다. 명시적으로 보존 기간을 설정하지 않으면 로그가 계속 쌓여 비용이 증가합니다.

- 보존 기간은 **로그 그룹 단위**로 1일 ~ 10년 범위의 정해진 값(1, 3, 5, 7, 14, 30, 60, 90, … 일) 중에서 선택합니다.
- 운영 모범 사례: 그룹 생성 시 **반드시 보존 기간을 명시**해 무기한 누적을 막습니다.

```
# 로그 그룹 보존 기간을 30일로 설정 (AWS CLI)
aws logs put-retention-policy \
  --log-group-name "/var/log/app" \
  --retention-in-days 30
```

> 장기 보관·저비용 아카이브가 필요하면 **구독 필터나 Firehose로 S3에 내보내기**(또는 내보내기 작업)를 구성합니다. CloudWatch Logs 자체에 무기한 보관하는 것은 비용 비효율적입니다.

> 🧠 원리: 왜 CloudWatch Logs는 보존 기간을 "무기한"으로 기본 설정했을까요?
> 로그를 임의로 삭제하면 운영 기록이 사라져 사후 감사나 장애 원인 분석에 필요한 증거가 없어지는 상황이 발생할 수 있습니다.
> 서비스마다 규정 준수·감사 요건이 달라 AWS가 일률적인 기간을 강제하기 어렵고, 기본값 "Never expire"는 로그 손실 없이 운영자가 직접 필요 기간을 선택하게 합니다.
> 실제로는 보존 기간을 설정하지 않으면 로그가 무기한 누적돼 비용이 커지므로, 그룹마다 보존 기간을 명시해 의도적으로 제한하는 것이 운영 모범 사례입니다.

### 3) 지표 필터(Metric Filter) — 로그 패턴 → 지표 → 경보

> 공식 정의: **"지표 필터는 로그 이벤트에서 찾을 용어·패턴을 정의하고, 일치하는 이벤트를 CloudWatch 지표의 수치 데이터로 변환한다."**

- 로그 그룹에 들어오는 이벤트를 **필터 패턴**으로 검사해, 일치하면 지정한 CloudWatch **지표값을 증가/게시**합니다(예: `ERROR` 문자열 발생 횟수를 카운트).
- 이렇게 만든 지표에 일반 CloudWatch 경보를 걸어 **로그 기반 알림**을 구성합니다.
- **지표 필터는 적용 시점 이후의 신규 로그 이벤트에만 적용**됩니다 — 과거 로그를 소급해 채우지 않습니다.

**운영 절차 — 에러 로그를 경보로 연결하는 흐름:**

```
① 로그 그룹에 지표 필터 생성
   필터 패턴: "ERROR"  →  지표: MyApp/ErrorCount (값 1 게시)
② 신규 로그에 "ERROR"가 나타날 때마다 ErrorCount += 1
③ ErrorCount 지표에 CloudWatch 경보 생성
   (예: 5분 합계 ≥ 10 이면 ALARM → SNS 알림)
```

> 차원이 없는 단순 카운트 외에, JSON 로그에서 필드값을 추출해 지표 차원/값으로 게시할 수도 있습니다(예: `{ $.statusCode = 500 }`).

> 🧠 원리: 왜 지표 필터는 생성 이전 로그를 소급해 집계하지 않을까요?
> CloudWatch 지표는 시간축 위의 연속 데이터 포인트로 구성되며, 각 포인트는 "해당 시각에 측정된 값"을 나타냅니다.
> 과거 로그를 소급해 집계하면 필터 생성 이전 기간에 갑자기 값이 나타나고, 경보는 "언제부터 조건이 충족됐는가"를 정확히 판단할 수 없게 됩니다.
> 필터 생성 시점을 측정 시작점으로 삼아야 지표의 시계열 연속성이 유지되고, 경보 조건과 실제 발생 시각이 1:1로 대응됩니다.
> 과거 로그를 분석할 필요가 있을 때는 Logs Insights를 사용합니다.

### 4) 구독 필터(Subscription Filter) — 실시간 로그 전송

> 공식 정의: **"구독(subscription)은 로그 그룹에 도착하는 로그 이벤트의 실시간 피드에 접근하여 지정한 대상으로 전달하는 메커니즘."**

| 대상 | 용도 |
|---|---|
| **Kinesis Data Streams** | 대량 로그를 실시간 스트림으로 — 커스텀 컨슈머·분석 파이프라인 |
| **Kinesis Data Firehose** | S3·OpenSearch·Redshift 등으로 거의 실시간 적재(버퍼링·변환) |
| **Lambda** | 로그 이벤트를 즉시 함수로 전달 — 커스텀 처리·알림·전달 |
| **OpenSearch Service** | 로그를 색인해 Kibana/Dashboards로 검색·시각화 |

- **지표 필터 vs 구독 필터의 차이(핵심):** 지표 필터는 패턴을 **숫자 지표로 변환**(경보용)하고, 구독 필터는 로그 이벤트 **자체를 실시간으로 다른 서비스에 전달**합니다.
- 구독 필터에도 **필터 패턴**을 지정해 일치하는 이벤트만 전달할 수 있습니다(빈 패턴 = 전체 전달).
- 장기 아카이브·중앙 집중 로깅·실시간 분석을 구성할 때 가장 자주 등장합니다.

> 🧠 원리: 왜 구독 필터는 로그를 숫자로 요약하지 않고 이벤트 원문 그대로 전달할까요?
> Kinesis Data Streams의 컨슈머, Lambda 함수, OpenSearch Service는 각자의 처리 방식으로 로그를 분석·색인·변환합니다.
> 이 서비스들이 제 기능을 발휘하려면 원본 이벤트 내용이 있어야 하며, 숫자 지표로 요약되면 원문 정보가 손실돼 다운스트림 처리가 불가능합니다.
> 지표 필터는 "경보를 위한 요약"이고, 구독 필터는 "다운스트림 활용을 위한 원문 전달"이라는 설계 목적의 차이가 이 동작 방식의 차이로 이어집니다.

### 5) CloudWatch Logs Insights — 쿼리 기반 로그 분석

> 공식 정의: **"Logs Insights는 CloudWatch Logs의 로그 데이터를 대화형으로 검색·분석하게 해주는 쿼리 기능."**

기본 쿼리 명령:

| 명령 | 역할 |
|---|---|
| `fields` | 표시할 필드 선택 |
| `filter` | 조건으로 이벤트 필터링 |
| `stats` | 집계(count, sum, avg, percentile 등) |
| `sort` | 정렬 |
| `limit` | 결과 개수 제한 |
| `parse` | 비정형 메시지에서 필드 추출 |

```
# 최근 5분간 ERROR 로그를 시간 역순으로 20건
fields @timestamp, @message
| filter @message like /ERROR/
| sort @timestamp desc
| limit 20
```

```
# 상태 코드별 요청 수 집계 (JSON 로그)
fields @timestamp, statusCode
| stats count(*) as cnt by statusCode
| sort cnt desc
```

> Logs Insights는 **자동 추출 필드**(`@timestamp`, `@message`, `@logStream` 등)를 제공하며, JSON 로그의 필드는 점 표기(`statusCode`, `level`)로 바로 참조됩니다. 쿼리는 선택한 **시간 범위**에 대해 실행되며 스캔한 데이터량에 따라 과금됩니다.

> 🧠 원리: 왜 Logs Insights는 쿼리 실행 시 스캔한 데이터량을 기준으로 과금할까요?
> Logs Insights는 쿼리가 실행될 때 선택한 시간 범위와 로그 그룹의 실제 데이터를 읽어 결과를 반환합니다.
> 공식 문서가 명시하듯, 쿼리마다 실제로 스캔한 데이터양이 과금 기준이 되기 때문에 어떤 필드 조합이든 유연하게 분석할 수 있는 대신 쿼리 범위가 비용을 결정합니다.
> 이 과금 구조 때문에 시간 범위를 좁히거나 로그 그룹 수를 줄이면 같은 쿼리도 비용이 낮아집니다.

### 6) CloudWatch 에이전트 — OS 지표·로그 수집

> 공식: **"통합 CloudWatch 에이전트는 EC2 인스턴스·온프레미스 서버에서 시스템 수준 지표와 로그를 수집한다."** 기본 EC2 지표에 없는 **메모리·디스크 사용량·스왑·프로세스** 등을 수집하는 핵심 도구입니다.

**왜 필요한가:** CloudWatch 기본 EC2 지표는 하이퍼바이저에서 보이는 CPU·네트워크·디스크 I/O뿐입니다. **메모리 사용률, 디스크 여유 공간, 파일시스템 사용률** 같은 게스트 OS 내부 값은 에이전트를 설치해야 수집됩니다. 애플리케이션 로그 파일을 CloudWatch Logs로 보내는 것도 에이전트의 역할입니다.

**설치 대상:** EC2, 온프레미스 서버, 그리고 ECS·EKS(컨테이너 환경, CloudWatch Agent / Container Insights 형태).

**운영 절차 — 구성 → 배포 → 검증:**

```
① 구성 파일 작성
   - 마법사(amazon-cloudwatch-agent-config-wizard)로 JSON 생성
   - metrics 블록: mem, disk, swap 등 수집 지표 지정
   - logs 블록: 수집할 로그 파일 경로 → 로그 그룹/스트림 매핑
② 구성 배포·에이전트 시작
   - 구성을 SSM Parameter Store에 저장(선택)
   - SSM Run Command(AmazonCloudWatch-ManageAgent)로
     다수 인스턴스에 일괄 배포·시작
③ 검증
   - CloudWatch 지표에서 CWAgent 네임스페이스의 mem/disk 확인
   - 지정한 로그 그룹에 로그 스트림이 생성·수신되는지 확인
```

> 에이전트가 게시하는 OS 지표는 기본적으로 **`CWAgent` 네임스페이스**에 들어갑니다. SSM을 쓰면 인스턴스마다 수동 설치하지 않고 **플릿 전체에 구성을 일괄 배포**할 수 있어 운영에서 표준 방식입니다. 에이전트 실행에는 CloudWatch 게시·로그 전송·(SSM 사용 시) SSM 권한을 가진 **IAM 역할**이 필요합니다.

> 🧠 원리: 왜 메모리·디스크 사용률은 하이퍼바이저가 아닌 게스트 OS 에이전트가 수집해야 할까요?
> CloudWatch 기본 EC2 지표는 하이퍼바이저가 외부에서 볼 수 있는 CPU·네트워크·디스크 I/O에 한정됩니다.
> 메모리 사용률이나 디스크 여유 공간은 게스트 OS 내부에서 관리되는 값이라 기본 지표에 포함되지 않으며, 이 값을 수집하려면 에이전트를 게스트 OS 안에서 실행해야 합니다.
> 에이전트가 OS 안에서 직접 값을 읽어 CloudWatch로 전송하면 `CWAgent` 네임스페이스에 나타납니다.

### 7) 임베디드 지표 형식(EMF) — 간단 언급

> **EMF(Embedded Metric Format)**: 애플리케이션이 **구조화된 JSON 로그 한 줄**을 CloudWatch Logs에 기록하면, CloudWatch가 그 로그에서 **고대수(custom) 지표를 자동 추출**하는 형식입니다.

- 로그와 지표를 한 번의 기록으로 동시에 남길 수 있어, 별도의 `PutMetricData` 호출 없이 고해상도·고카디널리티 지표를 게시할 때 유용합니다.
- 서버리스(Lambda)·컨테이너 환경에서 애플리케이션 내부 지표를 효율적으로 내보내는 패턴으로 쓰입니다.

> 🧠 원리: 왜 EMF는 별도 API 호출 없이 로그 기록만으로 사용자 지정 지표를 게시할 수 있을까요?
> CloudWatch 서비스 측에서 수신된 로그를 검사해 EMF 형식(특정 메타데이터 구조를 포함한 JSON)을 감지하면 자동으로 지표를 추출합니다.
> Lambda나 컨테이너 환경에서는 표준 출력에 쓰는 것이 이미 설정된 경로이므로, EMF 형식 JSON을 표준 출력에 내보내는 것만으로 로그와 지표를 동시에 기록할 수 있습니다.
> 지표 전송을 위한 별도 API 호출이 없어 함수 실행 시간이나 네트워크 오버헤드가 추가되지 않는다는 점이 서버리스 환경에서의 실용적 이점입니다.

---

## ✍️ 시험 포인트

- **로그 계층 = 로그 그룹 ⊃ 로그 스트림 ⊃ 로그 이벤트**. 보존·지표 필터·구독 필터·권한은 **로그 그룹 단위**.
- **로그 보존 기본값 = 무기한(Never expire)**. 비용 관리를 위해 그룹마다 보존 기간을 명시해야 함.
- **지표 필터 = 로그 패턴 → CloudWatch 지표**(경보용). 적용 후 **신규 이벤트에만** 적용, 과거 소급 안 됨.
- **구독 필터 = 로그 이벤트 → Kinesis Data Streams / Firehose / Lambda / OpenSearch 실시간 전송**.
- **지표 필터 vs 구독 필터** 혼동 금지: 전자는 "숫자 지표화", 후자는 "이벤트 자체 전달".
- **Logs Insights 핵심 구문**: `fields | filter | stats … by … | sort | limit`. 자동 필드 `@timestamp`, `@message`.
- **메모리·디스크 지표는 기본 EC2 지표가 아님 → CloudWatch 에이전트 필요**. 게시 네임스페이스는 `CWAgent`.
- **에이전트 배포는 SSM Run Command + Parameter Store**로 플릿에 일괄. 에이전트엔 IAM 역할 필요.
- **장기/저비용 로그 보관**은 구독 필터·Firehose로 **S3 내보내기**가 정석.
- **EMF**는 구조화 로그 한 줄로 사용자 지정 지표를 게시하는 형식(서버리스에서 유용).

---

## ⚠️ 흔한 함정

1. **"로그는 기본적으로 일정 기간 후 자동 삭제된다."** → 반대입니다. **기본 보존은 무기한(Never expire)**입니다. 보존 기간을 설정하지 않으면 로그가 계속 쌓여 비용이 증가합니다.
   *(원리: §2 — 로그 삭제 위험보다 누적 위험을 기본 선택, 운영자가 그룹별로 명시 설정해야 한다.)*

2. **"지표 필터를 만들면 과거 로그도 지표로 집계된다."** → 지표 필터는 **생성 이후 들어오는 신규 로그 이벤트에만** 적용됩니다. 이미 저장된 과거 로그를 소급 집계하지 않습니다(과거 분석은 Logs Insights로).
   *(원리: §3 — 필터 생성 시점이 측정 시작점이어야 시계열 연속성이 유지되고 경보 조건이 실제 발생 시각과 대응된다.)*

3. **"로그를 실시간으로 OpenSearch/Lambda에 보내려면 지표 필터를 쓴다."** → 그것은 **구독 필터**의 역할입니다. 지표 필터는 패턴을 숫자 지표로 바꿔 경보에 쓰는 것이고, 이벤트 자체를 전달하는 것은 구독 필터입니다.
   *(원리: §4 — 다운스트림 서비스는 원문 이벤트를 필요로 하며, 숫자 요약은 정보를 손실시켜 각 서비스의 처리 기능을 제한한다.)*

4. **"EC2를 만들면 메모리 사용률이 CloudWatch에 바로 나온다."** → 메모리·디스크 여유 공간은 게스트 OS 내부 값이라 기본 지표에 없습니다. **CloudWatch 에이전트**를 설치·구성해야 `CWAgent` 네임스페이스로 수집됩니다.
   *(원리: §6 — 메모리·디스크 여유 공간은 게스트 OS 내부 값이라 기본 지표에 없으며, 에이전트가 OS 안에서 직접 값을 읽어 전송한다.)*

5. **"에이전트는 인스턴스마다 콘솔에서 수동 설치해야 한다."** → 운영에서는 **SSM Run Command + Parameter Store**로 구성을 일괄 배포·시작합니다. 또한 에이전트가 지표·로그를 게시하려면 적절한 **IAM 역할**이 인스턴스에 연결돼야 합니다.
   *(원리: §6 본문 — SSM을 쓰면 플릿 전체에 구성을 일괄 배포할 수 있고, 에이전트 실행에는 IAM 역할이 필요하다.)*

6. **"CloudWatch Logs에 무기한 보관하는 것이 가장 저렴하다."** → 장기 보관은 **S3로 내보내기(구독 필터·Firehose 또는 내보내기 작업)**가 비용 효율적입니다. CloudWatch Logs 장기 누적은 저장 비용이 큽니다.
   *(원리: §2 본문 — 구독 필터나 Firehose로 S3에 내보내기가 장기 저비용 아카이브 방식이다.)*

---

## 🧪 자가 점검

> 아래는 학습용 자가 점검입니다. (정식 검증 문항은 별도 문항 파일 참조)

**Q1.** 애플리케이션 로그에 `ERROR`가 일정 빈도 이상 나타나면 운영팀에 알림을 보내려 합니다. 어떤 구성요소를 어떤 순서로 연결하나요?

<details><summary>정답 보기</summary>

로그 그룹에 **지표 필터(Metric Filter)**를 만들어 패턴 `ERROR`를 CloudWatch 지표(예: `ErrorCount`)로 변환합니다. 그 지표에 **CloudWatch 경보**를 걸어(예: 5분 합계가 임계값 초과 시 ALARM) **SNS**로 알림을 보냅니다. 즉 `로그 → 지표 필터 → 지표 → 경보 → SNS` 순서입니다. 단, 지표 필터는 생성 이후의 신규 로그에만 적용됩니다.
</details>

**Q2.** 여러 마이크로서비스의 로그를 실시간으로 한곳에 모아 OpenSearch에서 검색하고, 동시에 S3에 장기 보관하려 합니다. CloudWatch Logs에서 무엇을 사용하나요?

<details><summary>정답 보기</summary>

**구독 필터(Subscription Filter)**를 사용합니다. 로그 그룹의 구독 필터로 로그 이벤트를 실시간 전달하되, OpenSearch로 보내 검색을 제공하고, **Kinesis Data Firehose**를 거쳐 **S3**로 적재해 저비용 장기 보관을 구성합니다. 지표 필터가 아니라 구독 필터인 이유는, 숫자 지표가 아니라 로그 이벤트 자체를 다른 서비스로 전달해야 하기 때문입니다.
</details>

**Q3.** EC2 웹 서버의 **메모리 사용률**과 **/var/log/nginx/error.log**를 CloudWatch에서 보고 싶습니다. 수백 대 인스턴스에 어떻게 일괄 적용하나요?

<details><summary>정답 보기</summary>

**CloudWatch 에이전트**를 설치하고 구성 파일을 작성합니다(metrics에 mem, logs에 nginx 에러 로그 경로 지정). 구성을 **SSM Parameter Store**에 저장하고, **SSM Run Command(AmazonCloudWatch-ManageAgent)**로 수백 대 인스턴스에 구성을 일괄 배포·시작합니다. 에이전트에는 지표·로그 게시 권한을 가진 IAM 역할이 필요합니다. 검증은 `CWAgent` 네임스페이스의 메모리 지표와 지정한 로그 그룹의 수신을 확인합니다.
</details>

**Q4.** 지난 1시간 동안 상태 코드 500이 가장 많이 발생한 API 경로를 찾으려 합니다. 어떤 도구를 쓰나요?

<details><summary>정답 보기</summary>

**CloudWatch Logs Insights**를 사용합니다. JSON 로그라면 `filter statusCode = 500 | stats count(*) as cnt by path | sort cnt desc` 형태로 쿼리합니다. Logs Insights는 선택한 시간 범위에 대해 로그를 대화형으로 분석하며, 지표 필터(신규 이벤트만 집계)와 달리 **과거 로그를 소급 분석**할 수 있습니다.
</details>

**Q5 (원리).** 왜 CloudWatch 에이전트를 설치하지 않으면 EC2의 메모리 사용률을 CloudWatch에서 볼 수 없나요?

<details><summary>정답 보기</summary>

CloudWatch의 기본 EC2 지표는 하이퍼바이저가 외부에서 관찰할 수 있는 CPU·네트워크·디스크 I/O에 한정됩니다. 메모리 사용률은 게스트 OS 커널이 프로세스 메모리를 관리하면서 유지하는 내부 값으로, 하이퍼바이저는 이 정보에 접근할 수 없습니다. 에이전트를 게스트 OS 안에서 실행해야 메모리 값을 읽어 CloudWatch로 전송할 수 있고, 그 결과가 `CWAgent` 네임스페이스에 나타납니다.
</details>

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 AWS 자료를 기준으로 작성했습니다. (작성·대조: 2026-06-09 · 고도화 검수: 2026-06-12)

1. CloudWatch Logs란 무엇인가 — https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/WhatIsCloudWatchLogs.html
2. 로그 그룹과 로그 스트림 작업 — https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/Working-with-log-groups-and-streams.html
3. 지표 필터로 로그 이벤트에서 지표 생성 — https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/MonitoringLogData.html
4. 구독 필터를 사용한 실시간 로그 처리 — https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/Subscriptions.html
5. CloudWatch Logs Insights 쿼리 구문 — https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CWL_QuerySyntax.html
6. CloudWatch 에이전트 설치 — https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/install-CloudWatch-Agent-on-EC2-Instance.html
</content>
</invoke>
