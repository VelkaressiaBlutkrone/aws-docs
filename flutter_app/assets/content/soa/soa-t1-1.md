---
examGuideTaskId: soa-t1-1
certCode: SOA-C03
domain: 1
domainName: 모니터링, 로깅, 분석, 문제 해결 및 성능 최적화
domainWeightPct: 22
title: CloudWatch 지표·경보·대시보드
coversTasks:
  - "1.1"
sources:
  - title: CloudWatch 개념 (네임스페이스·차원·기간·통계) (공식)
    url: https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/cloudwatch_concepts.html
  - title: 지표 작업 (공식)
    url: https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/working_with_metrics.html
  - title: 이메일을 보내는 경보 생성 (경보 개념) (공식)
    url: https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/AlarmThatSendsEmail.html
  - title: 다른 경보를 기반으로 하는 복합 경보 (공식)
    url: https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Create_alarm_on_alarm.html
  - title: CloudWatch 대시보드 (공식)
    url: https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Dashboards.html
  - title: EC2 인스턴스 모니터링 (기본 vs 세부) (공식)
    url: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-cloudwatch.html
lastVerified: 2026-06-09
---

# CloudWatch 지표·경보·대시보드

> 커버하는 공식 Task — SOA-C03 · 도메인 1 「모니터링, 로깅, 분석, 문제 해결 및 성능 최적화」(22%) · **Task 1.1 AWS 모니터링 및 로깅 서비스를 사용하여 지표, 경보 및 필터 구현** (`soa-t1-1`)
> 이 문서는 CloudWatch의 지표·경보·대시보드에 집중합니다. 로그/감사/추적은 `soa-t1-2`, `soa-t1-3`에서 다룹니다.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명하고, 콘솔/CLI에서 직접 구성할 수 있어야 합니다.

- [ ] **지표 식별 4요소** — 네임스페이스·차원·기간·통계를 구분하고, 차원이 다르면 별개 지표임을 설명할 수 있다
- [ ] **해상도와 보존** — 표준(1분) vs 고해상도(1초) 지표의 차이와 데이터 보존 기간을 안다
- [ ] **모니터링 수준** — EC2 기본(5분) vs 세부(1분) 모니터링을 구분하고 활성화할 수 있다
- [ ] **경보 구성** — 임계값·평가 기간(M out of N)·상태 전이·누락 데이터 처리를 설정할 수 있다
- [ ] **경보 작업** — SNS·EC2 작업·Auto Scaling·Systems Manager 등 작업 대상을 연결할 수 있다
- [ ] **복합 경보** — AND/OR로 여러 경보를 결합해 알림 노이즈를 줄이는 패턴을 안다
- [ ] **대시보드** — 교차 리전 위젯과 리전 단위 경보/지표의 경계를 이해한다

---

## 🎯 왜 중요한가

- 도메인 1(22%)은 SOA에서 가장 비중이 큰 영역이며, 그 출발점이 CloudWatch입니다. 운영(Operations) 자격증인 SOA는 "어떤 서비스를 고를까"보다 **"어떻게 지표를 수집하고, 경보를 어떻게 평가하며, 문제를 어떻게 잡아내는가"**를 묻습니다.
- 시험은 단순히 "CloudWatch가 무엇인가"가 아니라 **구체적인 설정값**을 묻습니다. 평가 기간 "M out of N", 누락 데이터 처리 옵션 4종, 표준/고해상도 경보의 최소 주기, 어떤 지표는 에이전트가 있어야만 수집되는지 등이 함정 형태로 반복 출제됩니다.
- CLF/SAA에서 CloudWatch를 "모니터링 서비스" 수준으로 봤다면, SOA는 **운영자 관점의 절차**(세부 모니터링 켜기, PutMetricData로 사용자 지정 지표 게시, 경보 작업으로 자동 복구 트리거)를 직접 구성하도록 요구합니다.

---

## 📖 핵심 개념

### 1) 지표의 구조 — 네임스페이스·차원·기간·통계

> 공식 정의: **"지표(Metric)는 시간 순서가 있는 데이터 포인트의 집합이며, 모니터링할 변수를 나타낸다."** 지표는 네임스페이스·이름·차원·타임스탬프·값으로 식별됩니다.

CloudWatch 지표를 고유하게 식별하는 4가지 요소:

| 요소 | 의미 | 예시 |
|---|---|---|
| **네임스페이스(Namespace)** | 지표의 컨테이너. 서비스/애플리케이션별로 분리 | `AWS/EC2`, `AWS/RDS`, 사용자 지정 `MyApp` |
| **차원(Dimension)** | 지표를 구분하는 이름/값 쌍. 최대 30개 | `InstanceId=i-1234`, `AutoScalingGroupName=asg-web` |
| **기간(Period)** | 데이터 포인트를 집계하는 시간 단위(초) | 60, 300, 3600 (또는 고해상도 1·5·10·30) |
| **통계(Statistic)** | 기간 내 데이터를 집계하는 방식 | `Average`, `Sum`, `Minimum`, `Maximum`, `SampleCount`, `pNN.NN`(백분위수) |

**핵심 사실:**

- **차원이 다르면 완전히 별개의 지표입니다.** `InstanceId=A`의 CPUUtilization과 `InstanceId=B`의 CPUUtilization은 서로 다른 지표입니다. 차원 조합을 가로질러 자동 집계되지 않습니다.
- **통계는 측정값이 아니라 집계 방식**입니다. 같은 CPUUtilization 지표라도 `Average`로 볼지 `Maximum`으로 볼지에 따라 의미가 달라집니다. 경보는 "어떤 통계를, 어떤 기간으로 볼지"를 반드시 지정합니다.
- **백분위수(percentile, p90/p99 등)**는 꼬리 지연(tail latency)을 볼 때 유용합니다. 평균은 이상치를 가려버리므로 지연 모니터링에는 p99를 자주 씁니다.
- **사용자 지정 지표**는 `PutMetricData` API로 게시합니다. 애플리케이션 내부 지표(메모리 사용량, 큐 깊이, 비즈니스 KPI 등)는 기본 제공되지 않으므로 직접 게시해야 합니다.

```
# 사용자 지정 지표 게시 (AWS CLI)
aws cloudwatch put-metric-data \
  --namespace "MyApp" \
  --metric-name "QueueDepth" \
  --dimensions "Service=Worker" \
  --value 42 \
  --unit Count
```

### 2) 표준 vs 고해상도 지표와 보존

| 구분 | 해상도 | 경보 최소 주기 | 용도 |
|---|---|---|---|
| **표준 지표** | 1분(60초) | **60초의 배수** (60, 300, ...) | 대부분의 AWS 서비스 기본 지표 |
| **고해상도 지표** | **1초까지** | **10초 또는 30초** 가능 | 빠른 변동을 잡아야 하는 사용자 지정 지표 |

> 고해상도 지표는 `PutMetricData`에서 `StorageResolution=1`로 게시합니다. 기본값은 60(표준)입니다.

**데이터 보존 기간 (집계 후 자동 롤업):**

| 데이터 해상도 | 보존 기간 |
|---|---|
| **60초 미만**(고해상도) | **3시간** |
| **60초(1분)** | **15일** |
| **300초(5분)** | **63일** |
| **3600초(1시간)** | **455일(15개월)** |

> CloudWatch는 오래된 데이터를 더 낮은 해상도로 **롤업(집계)**합니다. 즉 60초 데이터는 15일 후 사라지지만, 그 기간 동안 집계된 5분/1시간 데이터는 더 오래 남습니다. 1초 단위 원본은 3시간만 유지되므로 장기 분석에는 부적합합니다.

**EC2 모니터링 수준:**

| 수준 | 지표 게시 주기 | 비용 | 활성화 |
|---|---|---|---|
| **기본 모니터링** | **5분** | 무료 | 기본값 |
| **세부 모니터링** | **1분** | 인스턴스당 추가 비용 | 명시적으로 활성화 |

> 경보를 1분 단위로 빠르게 반응시키려면 세부 모니터링(1분)을 켜야 합니다. 기본(5분) 상태에서 60초 기간 경보를 만들면 평가할 데이터가 부족해 `INSUFFICIENT_DATA`가 자주 발생합니다.

### 3) 경보 — 임계값·평가·상태 전이

> 공식 정의: **"경보(Alarm)는 단일 지표(또는 지표 계산식의 결과)를 정의된 기간 동안 임계값과 비교하여 하나 이상의 작업을 수행한다."**

**경보의 3가지 상태:**

| 상태 | 의미 |
|---|---|
| **OK** | 지표가 임계값 범위 안에 있음(정상) |
| **ALARM** | 지표가 임계값을 위반함 |
| **INSUFFICIENT_DATA** | 데이터가 부족하거나 막 시작됨(에러 아님) |

**평가 — "M out of N" (M개 위반 / N개 데이터 포인트):**

- **평가 기간(Evaluation Periods, N)**: 경보가 들여다보는 데이터 포인트 개수.
- **경보 데이터 포인트(Datapoints to Alarm, M)**: 그중 몇 개가 위반해야 ALARM으로 전이되는지.
- 예: `M=3, N=5`이면 최근 5개 데이터 포인트 중 3개가 임계값을 위반하면 ALARM. 일시적 스파이크로 인한 오탐(false alarm)을 줄이는 핵심 설정입니다.

**누락 데이터 처리(Treat missing data) — 4가지 옵션:**

| 옵션 | 동작 |
|---|---|
| **missing** (기본값) | 누락 데이터를 평가에서 제외(있는 것만으로 판단) |
| **notBreaching** | 누락을 "정상(임계값 미위반)"으로 간주 |
| **breaching** | 누락을 "위반"으로 간주 → ALARM 유발 가능 |
| **ignore** | 현재 상태를 유지(상태 전이 안 함) |

> 트래픽이 없을 때 지표 자체가 보고되지 않는 경우(예: 요청 수)에 누락 처리 옵션이 결과를 크게 바꿉니다. "데이터가 없으면 문제"라고 보려면 `breaching`, "데이터가 없으면 한가한 것"이라고 보려면 `notBreaching`를 선택합니다.

```
# 경보 생성 (AWS CLI) — CPU 평균 80% 초과, 3 out of 3
aws cloudwatch put-metric-alarm \
  --alarm-name "web-cpu-high" \
  --namespace "AWS/EC2" --metric-name CPUUtilization \
  --dimensions Name=InstanceId,Value=i-1234 \
  --statistic Average --period 60 --evaluation-periods 3 \
  --datapoints-to-alarm 3 --threshold 80 \
  --comparison-operator GreaterThanThreshold \
  --treat-missing-data notBreaching \
  --alarm-actions arn:aws:sns:ap-northeast-2:123456789012:ops-alerts
```

### 4) 복합 경보와 경보 작업 대상

**경보 작업 대상 — ALARM/OK/INSUFFICIENT_DATA 전이 시 실행:**

| 대상 | 용도 |
|---|---|
| **SNS 주제** | 이메일·SMS·Lambda·HTTP 등으로 알림 팬아웃 |
| **EC2 작업** | 인스턴스 **중지·종료·재부팅·복구(recover)** |
| **Auto Scaling 정책** | 스케일 아웃/인 트리거(단순/단계 조정 정책) |
| **Systems Manager** | OpsItem 생성·자동화 런북 실행 |
| **EventBridge** | 경보 상태 변경 이벤트를 규칙으로 라우팅 |

> **EC2 복구 작업**은 하드웨어/호스트 장애 시 같은 인스턴스를 정상 호스트로 이전(동일 인스턴스 ID·프라이빗 IP 유지)합니다. `StatusCheckFailed_System` 지표 경보와 함께 자주 씁니다.

**복합 경보(Composite Alarm):**

> 공식: **"복합 경보는 다른 경보들의 규칙 표현식(AND/OR/NOT)에 따라 상태가 결정되는 경보."**

- 여러 개별 경보를 `ALARM("a") AND ALARM("b")` 같은 식으로 결합합니다.
- **목적은 알림 노이즈 감소**입니다. 개별 경보 수십 개가 각각 SNS를 쏘는 대신, "여러 조건이 동시에 위반될 때만" 하나의 복합 경보로 알립니다.
- 개별 경보는 SNS 작업을 끄고 복합 경보에만 작업을 붙여, 근본 원인 하나당 알림 하나가 가도록 설계합니다.

```
# 복합 경보 규칙 예시
ALARM("web-cpu-high") AND ALARM("web-latency-high")
```

### 5) 대시보드

> 공식 정의: **"대시보드는 단일 뷰에 지표와 경보를 모아 보여주는 사용자 지정 가능한 홈 페이지."**

- **위젯(Widget)**: 선 그래프·누적 영역·숫자·게이지·경보 상태·텍스트(마크다운)·로그 테이블 등.
- **교차 리전·교차 계정**: 대시보드 위젯은 **여러 리전의 지표를 한 화면에** 표시할 수 있습니다(글로벌 뷰). 반면 **경보와 지표 자체는 리전 단위 리소스**입니다 — 서울 리전에서 만든 경보는 도쿄 리전 콘솔에 보이지 않습니다.
- **자동 새로 고침**과 시간 범위 선택, 대시보드를 JSON으로 내보내/가져와 IaC로 관리 가능.

| 구분 | 리전 경계 |
|---|---|
| **지표·경보** | **리전 단위**(생성한 리전에서만 보임/평가됨) |
| **대시보드 위젯** | **교차 리전 표시 가능**(여러 리전 지표를 한 위젯에) |

---

## ✍️ 시험 포인트

- **지표 식별 = 네임스페이스 + 이름 + 차원**. 차원 조합이 다르면 별개 지표. 자동으로 가로질러 합산되지 않는다.
- **통계 vs 기간**을 혼동하지 말 것. 통계(Average/Sum/Max/p99…)는 "집계 방식", 기간(Period)은 "집계 시간 단위".
- **표준 경보 최소 주기 = 60초의 배수**, **고해상도 경보 = 10초 또는 30초**. 고해상도 지표는 1초까지 게시 가능.
- **보존**: 1분=15일, 5분=63일, 1시간=455일(15개월), **고해상도(60초 미만)=3시간**.
- **EC2 기본=5분(무료), 세부=1분(유료)**. 1분 경보를 원하면 세부 모니터링을 켜야 함.
- **경보 상태 3종**: OK / ALARM / **INSUFFICIENT_DATA**(에러가 아님).
- **M out of N**(Datapoints to Alarm / Evaluation Periods)으로 오탐 억제.
- **누락 데이터 4종**: missing(기본·제외) / notBreaching / breaching / ignore.
- **경보 작업 대상**: SNS, EC2(중지·종료·재부팅·복구), Auto Scaling, Systems Manager, EventBridge.
- **복합 경보**는 AND/OR/NOT로 결합 → **알림 노이즈 감소**가 목적.
- **사용자 지정 지표는 PutMetricData로 게시**. 메모리·디스크 사용량 등은 기본 지표가 아님 → **CloudWatch agent 필요**.
- **대시보드는 교차 리전**, **경보·지표는 리전 단위**.

---

## ⚠️ 흔한 함정

1. **"차원이 같은 이름이면 합쳐서 본다."** → 차원 값이 다르면(InstanceId가 다르면) **별개의 지표**입니다. 전체를 보려면 지표 계산식(Metric Math)이나 집계된 지표(예: ASG 단위)를 따로 써야 합니다.

2. **"경보는 전역(글로벌)이다."** → 경보와 지표는 **리전 단위 리소스**입니다. 멀티 리전 운영이면 각 리전마다 경보를 만들어야 하며, 한 화면에서 보려면 **교차 리전 대시보드**를 씁니다.

3. **"EC2를 만들면 메모리·디스크 사용량 지표가 바로 나온다."** → CloudWatch 기본 EC2 지표는 CPU·네트워크·디스크 I/O·상태 점검 등 **하이퍼바이저에서 보이는 것**뿐입니다. **메모리·디스크 여유 공간·EBS 파일시스템 사용률**은 게스트 OS 내부 값이라 **CloudWatch agent를 설치**해야 수집됩니다.

4. **"기본 모니터링(5분)으로 1분 주기 경보를 만든다."** → 데이터가 5분마다 들어오므로 60초 기간 경보는 대부분 `INSUFFICIENT_DATA` 상태가 됩니다. 1분 경보를 원하면 **세부 모니터링**을 켜야 합니다.

5. **"고해상도(1초) 지표면 데이터가 오래 남는다."** → 정반대입니다. **60초 미만 해상도 데이터는 3시간만** 보존됩니다. 장기 추세는 자동 롤업된 5분/1시간 데이터로 봅니다. 또한 고해상도 지표·고해상도 경보는 **추가 비용**이 발생합니다.

6. **"트래픽이 0일 때 경보가 알아서 정상으로 본다."** → 지표가 보고되지 않으면 **누락 데이터 처리 옵션**에 따라 결과가 달라집니다. 기본값 `missing`은 누락을 무시하지만, `breaching`을 선택하면 데이터 없음을 위반으로 보아 의도치 않게 ALARM이 울릴 수 있습니다.

7. **"INSUFFICIENT_DATA는 장애다."** → 데이터가 아직 충분히 쌓이지 않았거나 보고되지 않았다는 **중립 상태**입니다. 경보를 막 만든 직후나 트래픽이 없을 때 정상적으로 나타납니다.

---

## 🧪 자가 점검

> 아래는 학습용 자가 점검입니다. (정식 검증 문항은 별도 문항 파일 참조)

**Q1.** EC2 인스턴스의 CPUUtilization에 대해 1분 단위로 빠르게 반응하는 경보를 만들었는데, 경보가 자주 `INSUFFICIENT_DATA`에 머뭅니다. 가장 가능성 높은 원인과 해결책은?

<details><summary>정답 보기</summary>

인스턴스가 **기본 모니터링(5분 주기)** 상태일 가능성이 높습니다. 기본 모니터링은 5분마다 데이터를 게시하므로, 60초 기간 경보는 평가할 데이터 포인트가 부족해 `INSUFFICIENT_DATA`가 됩니다. **세부 모니터링(Detailed Monitoring)을 활성화**해 1분 주기로 지표를 게시하게 하면 해결됩니다(인스턴스당 추가 비용 발생).
</details>

**Q2.** 야간에 트래픽이 0이 되는 API의 "요청 수" 지표로 경보를 만들었습니다. 트래픽이 없을 때는 정상으로 보고, 실제 오류율이 높을 때만 알림을 받고 싶습니다. 어떤 설정이 핵심인가요?

<details><summary>정답 보기</summary>

**누락 데이터 처리(Treat missing data) 옵션**이 핵심입니다. 트래픽이 0이면 지표가 보고되지 않아 데이터가 누락됩니다. 이때 `notBreaching`(누락=정상)으로 설정하면 한가한 시간대에 오탐이 발생하지 않습니다. 반대로 `breaching`을 골랐다면 데이터 없음을 위반으로 간주해 잘못된 ALARM이 울립니다. 또한 평가 기간을 **M out of N**으로 설정해 일시적 스파이크에 의한 오탐도 줄입니다.
</details>

**Q3.** 여러 마이크로서비스 경보가 각자 SNS로 알림을 쏴서 인시던트 한 건에 알림이 수십 개씩 옵니다. 알림 노이즈를 줄이려면?

<details><summary>정답 보기</summary>

**복합 경보(Composite Alarm)**를 사용합니다. 개별 경보에서는 SNS 작업을 제거하고, `ALARM("a") AND ALARM("b")` 같은 규칙 표현식으로 묶은 복합 경보에만 알림 작업을 붙입니다. 그러면 여러 조건이 동시에 위반되는 "진짜" 인시던트일 때 하나의 알림만 발송되어 노이즈가 줄어듭니다.
</details>

**Q4.** 애플리케이션 인스턴스의 **메모리 사용률**을 CloudWatch 경보로 감시하려는데, 기본 지표 목록에 메모리가 없습니다. 어떻게 해야 하나요?

<details><summary>정답 보기</summary>

메모리 사용률은 게스트 OS 내부 값이라 기본 EC2 지표에 포함되지 않습니다. **CloudWatch agent를 설치·구성**해 메모리·디스크 등 OS 지표를 사용자 지정 지표로 게시해야 합니다(내부적으로 `PutMetricData` 사용). 게시된 사용자 지정 지표에 대해 일반 경보를 만들면 됩니다.
</details>

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 AWS 자료를 기준으로 작성했습니다. (작성·대조: 2026-06-09)

1. CloudWatch 개념(네임스페이스·차원·기간·통계·해상도) — https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/cloudwatch_concepts.html
2. 지표 작업 — https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/working_with_metrics.html
3. 이메일을 보내는 경보 생성(경보 상태·평가·누락 데이터) — https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/AlarmThatSendsEmail.html
4. 다른 경보를 기반으로 하는 복합 경보 — https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Create_alarm_on_alarm.html
5. CloudWatch 대시보드 — https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Dashboards.html
6. EC2 인스턴스 모니터링(기본 vs 세부) — https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-cloudwatch.html
