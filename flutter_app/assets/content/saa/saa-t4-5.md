---
examGuideTaskId: saa-t4-5
certCode: SAA-C03
domain: 4
domainName: 비용에 최적화된 아키텍처 설계
domainWeightPct: 20
title: 비용 관리 도구 — Cost Explorer·Budgets·CUR·태그·Well-Architected
coversTasks:
  - "4.1"
  - "4.2"
  - "4.3"
  - "4.4"
sources:
  - title: AWS Cost Explorer — 공식 문서
    url: https://docs.aws.amazon.com/cost-management/latest/userguide/ce-what-is.html
  - title: AWS Budgets — 공식 문서
    url: https://docs.aws.amazon.com/cost-management/latest/userguide/budgets-managing-costs.html
  - title: AWS Cost and Usage Report (CUR) — 공식 문서
    url: https://docs.aws.amazon.com/cur/latest/userguide/what-is-cur.html
  - title: AWS Cost Anomaly Detection — 공식 문서
    url: https://docs.aws.amazon.com/cost-management/latest/userguide/getting-started-ad.html
  - title: Well-Architected 비용 최적화 기둥 — 설계 원칙 (공식)
    url: https://docs.aws.amazon.com/wellarchitected/latest/cost-optimization-pillar/design-principles.html
  - title: SAA-C03 공식 시험 가이드 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
  - title: 비용 할당 태그 Backfill — 공식 문서 (게이트 검수 반영: 2026-06-12)
    url: https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/cost-allocation-backfill.html
  - title: 비용 할당 태그 활성화 — 공식 문서 (게이트 검수 반영: 2026-06-12)
    url: https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/activating-tags.html
lastVerified: 2026-10-22
---

# 비용 관리 도구 — Cost Explorer·Budgets·CUR·태그·Well-Architected

> **커버하는 공식 Task** — SAA-C03 · 도메인 4 「비용에 최적화된 아키텍처 설계」(20%) · **Task 4.1~4.4** (`saa-t4-5`)
> 비용 가시성·거버넌스·Well-Architected 비용 최적화 기둥을 다룹니다. 도메인 4는 시험 비중 4위(20%)이며, "most cost-effective"가 최빈출 키워드입니다.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명할 수 있어야 합니다.

- [ ] **Cost Explorer** — 비용·사용량 시각화, 13개월 이력·18개월 예측, RI/Savings Plans 구매 추천 기능을 안다
- [ ] **AWS Budgets** — 6가지 예산 유형, 실제·예측 알림, Budget Actions(IAM 정책 자동 적용)를 설명할 수 있다
- [ ] **Cost and Usage Report(CUR)** — S3 전달, 시간·일·월 단위 세분화, Athena·Redshift 분석 파이프라인을 안다
- [ ] **Cost Anomaly Detection** — ML 기반 이상 비용 자동 감지, 모니터·알림 구독 구조를 안다
- [ ] **비용 할당 태그** — 태그 정책, Organizations 통합 결제, 볼륨 할인 공유 메커니즘을 안다
- [ ] **Compute Optimizer / Trusted Advisor** — 각각의 비용 최적화 관점에서의 역할 차이를 안다
- [ ] **Well-Architected 비용 최적화 기둥** — 5가지 설계 원칙을 이름과 내용으로 설명할 수 있다
- [ ] **도구 선택 기준** — Cost Explorer vs Budgets vs CUR 중 상황에 맞는 도구를 고를 수 있다

---

## 🎯 왜 중요한가

- 도메인 4(20%)는 SAA 시험 4개 도메인 중 "most cost-effective solution"이라는 구문이 가장 자주 등장하는 영역입니다.
- 시험은 단순 가격 비교가 아니라 **요구 사항을 충족하면서 비용을 최소화하는 설계 결정**을 묻습니다.
- 비용 관리 도구는 "어떤 도구가 어느 질문에 답하는가"를 구분하는 것이 핵심입니다. Cost Explorer는 분석, Budgets는 거버넌스, CUR는 감사·심층 분석 — 역할이 다릅니다.
- Well-Architected 비용 최적화 기둥은 도구 선택과 아키텍처 설계 결정 모두에 판단 기준을 제공합니다.

---

## 🔤 먼저 알아야 할 용어

이 문서를 읽는 데 필요한 기초 용어입니다. 이미 알면 건너뛰세요.

| 용어 | 영문 | 한 줄 풀이 |
|---|---|---|
| **라인 아이템** | Line Item | 청구서에서 서비스·리소스·태그별로 개별 기재된 한 줄 항목 — 영수증의 각 품목과 같음 |
| **인보이스** | Invoice | AWS가 월말에 발행하는 공식 청구서 — 확정(finalize) 전까지는 예상치 |
| **IAM 정책** | IAM Policy | AWS 리소스에 대한 허용·거부 규칙을 JSON으로 정의한 문서 |
| **Amazon SNS** | Simple Notification Service | 구독자에게 이메일·HTTP·Lambda 등으로 메시지를 전달하는 알림 중계 서비스 |
| **볼륨 할인 티어** | Volume Discount Tier | 사용량이 누적될수록 단가가 낮아지는 구간별 가격 구조 |
| **드릴다운** | Drill-down | 집계 데이터에서 더 세분화된 하위 항목으로 내려가 원인을 추적하는 분석 방식 |

---

## 📖 핵심 개념 {#core-concepts}

### 1) 비용 관리 도구 비교 (★ 시험 핵심) {#cost-tools-comparison}

| 도구 | 핵심 질문 | 데이터 범위 | 주요 출력 |
|---|---|---|---|
| **AWS Cost Explorer** | "지금까지 얼마를 어디에 썼나? 앞으로 얼마나 쓸까?" | 과거 13개월 + 미래 18개월 예측 | 인터랙티브 그래프·CSV·RI/SP 구매 추천 |
| **AWS Budgets** | "예산을 초과하거나 초과할 것 같으면 알려줘 / 막아줘" | **하루 최대 3회 갱신**(보통 8~12시간 간격) | 이메일·SNS 알림, Budget Actions(IAM·SCP·인스턴스 중지) |
| **Cost and Usage Report (CUR)** | "서비스·리소스·태그 단위로 최상세 내역이 필요하다" | 시간·일·월 단위 라인 아이템 | S3 파일(CSV·Parquet) → Athena·Redshift·Quick Sight 쿼리. 신규는 **Data Exports의 CUR 2.0** |
| **Cost Anomaly Detection** | "예상치 못한 비용 급등을 자동으로 잡아줘" | ML 모델이 지속 학습 | 이상 감지 알림(이메일·SNS), 루트 코즈 분석 |

> **한 줄 원칙**: "분석·예측 = Cost Explorer, 예산·경보·차단 = Budgets, 감사·BI = CUR, 자동 이상 감지 = Cost Anomaly Detection"

### 2) AWS Cost Explorer {#cost-explorer}

> **공식 정의**: "비용과 사용량을 보고 분석하는 도구." 과거 13개월 이력 조회, 향후 18개월 예측, RI 구매 추천을 제공합니다.

주요 특성:

- 콘솔 UI 사용은 **무료**. 프로그래밍 방식 API 호출은 요청당 $0.01.
- Cost Explorer를 활성화하면 비활성화 불가.
- Cost Explorer가 사용하는 데이터셋은 CUR과 동일한 소스.
- 서비스·계정·리전·태그·인스턴스 유형 등 다차원 필터·그룹핑 지원.
- **RI / Savings Plans 구매 추천** 내장 — 현재 사용 패턴 기반으로 비용 절감 기회를 제안.

**조회 범위와 세분화** — 기본 조회 범위는 당월을 포함한 **14개월**(과거 13개월 + 당월)이고 단위는 **일·월**입니다. 더 길게 보거나 더 촘촘히 보려면 **관리 계정**이 Billing and Cost Management 콘솔의 *Cost Management 환경설정*에서 옵션을 켜야 합니다.

| 옵션 | 범위·단위 | 제약 |
|---|---|---|
| **다년 데이터** | 월 단위로 **최대 38개월** — 조직 전체에 적용 | **Cost Explorer에서만** 보임 — Savings Plans·예약의 **사용률·커버리지 보고서**는 이 데이터를 지원하지 않음 |
| **시간 단위** | 전 서비스를 시간 단위로, 또는 **EC2 인스턴스를 리소스 단위**로 | 시간 단위 데이터와 일 단위 리소스 데이터는 **최근 14일**만 |
| **일 단위 리소스 데이터** | 서비스를 골라 리소스 단위로 | 선택 목록에는 **최근 6개월간 사용한 서비스만** 나오고 비용이 큰 순으로 정렬됨 |

- 설정 변경이 Cost Explorer에 반영되기까지 **최대 48시간**이 걸리고, 저장한 뒤 **48시간** 동안은 다시 바꿀 수 없습니다.
- 조직 안의 누구도 **3개월 연속** 다년 데이터를 열어보지 않으면 AWS가 **자동으로 비활성화**합니다 — 필요하면 환경설정에서 다시 켭니다.
- 세분화 데이터는 **과금 대상 비용을 보여주는 결제 뷰**에서만 보입니다. Billing Conductor의 표준·이전(transfer) 결제 그룹 계정으로 쓰는 경우에는 조회할 수 없습니다.

> 💡 시험에서 "연도별 비용 추세"·"인스턴스 단위 시간대별 비용"이 나오면 **Cost Explorer를 쓸 수 있는지**가 아니라 **관리 계정이 그 옵션을 켰는지**가 쟁점입니다. 기본 상태로는 둘 다 보이지 않습니다.

> 🧠 원리: 왜 Cost Explorer와 CUR은 같은 데이터셋을 공유하면서도 별개의 도구로 존재할까요?
> CUR은 라인 아이템 단위의 원시 데이터를 S3에 전달하는 파이프라인이고, Cost Explorer는 그 위에 집계·필터·그룹핑을 미리 계산해 대화형 뷰로 제공하는 분석 레이어입니다.
> 원시 데이터가 필요한 Athena·Redshift 파이프라인은 CUR을 직접 사용하고, 빠른 시각적 탐색이 필요한 경우에는 Cost Explorer를 사용하는 방식으로 역할이 분리됩니다.
> 두 도구가 공존하는 이유는 사용 목적(심층 감사 vs. 즉각 분석)이 달라 단일 도구로 통합하면 어느 쪽 사용성도 충족하기 어렵기 때문입니다.

### 3) AWS Budgets {#budgets}

> **공식 정의**: "AWS 비용과 사용량을 추적하고 조치를 취하는 서비스." 예산 설정, 초과 알림, 자동 조치(Budget Actions)를 제공합니다.

6가지 예산 유형:

| 유형 | 추적 대상 | 알림 조건 |
|---|---|---|
| **비용 예산(Cost)** | 지출 금액 | 실제·예측 비용이 임계값 초과 |
| **사용량 예산(Usage)** | 서비스 사용량 | 사용량이 임계값 초과 |
| **RI 사용률 예산** | RI 활용도 | 사용률이 임계값 미달 |
| **RI 커버리지 예산** | RI로 커버된 비율 | 커버리지가 임계값 미달 |
| **Savings Plans 사용률 예산** | SP 활용도 | 사용률이 임계값 미달 |
| **Savings Plans 커버리지 예산** | SP로 커버된 비율 | 커버리지가 임계값 미달 |

**Budget Actions** — 임계값 초과 시 조치(**자동 실행** 또는 **수동 승인 후 실행** 중 선택):

```
예산 초과 감지
  → IAM 정책 연결 (추가 리소스 생성 차단)
  → 서비스 제어 정책(SCP) 적용 (조직 단위 차단)
  → 실행 중 인스턴스 대상 지정 (EC2·RDS 중지)
```

> SNS는 조치(action) 유형이 아니라 **알림 채널**입니다. 관리 계정에서 다른 계정에 SCP를 적용할 수는 있지만, 다른 계정의 EC2·RDS 인스턴스를 대상으로 지정할 수는 없습니다.

> 알림 지연: Budgets 정보는 **하루 최대 3회** 갱신되고, 갱신은 보통 이전 갱신으로부터 8~12시간 뒤에 일어납니다 — 실시간이 아니므로 초과 발생 후 알림까지 지연이 있습니다.

> 🧠 원리: 왜 Budget Actions는 알림만 보내는 대신 IAM 정책을 자동으로 연결하는 방식을 선택할까요?
> AWS에서 리소스 생성 여부는 IAM 정책의 허용·거부 규칙으로 제어되므로, 예산 초과 시 Deny 정책을 연결하면 추가 리소스 생성이 즉시 차단됩니다.
> 알림만으로는 관리자가 수동으로 개입해야 하지만, IAM 정책 연결은 사람 없이 자동으로 제어 상태를 변경하므로 야간·주말 초과 상황에도 즉각 반응합니다.
> 이 설계 덕분에 개발 환경 비용 급증을 운영자가 자리를 비운 사이에도 자동으로 억제할 수 있습니다.

### 4) AWS Cost and Usage Report (CUR) {#cur}

> **공식 정의**: "AWS에서 제공하는 가장 포괄적인 비용·사용량 데이터 세트." 사용자 소유 S3 버킷으로 CSV 파일을 전달합니다.

주요 특성:

- 제품·리소스·태그별 **라인 아이템** 단위 세분화 — 시간·일·월 단위 선택 가능.
- 보고서 크기가 100만 행을 초과하면 자동으로 여러 파일로 분할.
- 통합 분석 파이프라인:

```
CUR / Data Exports CUR 2.0 (S3: CSV·GZIP·Parquet)
  → Amazon Athena (SQL 쿼리)
  → Amazon Redshift (DW 적재)
  → Amazon Quick Sight (시각화)
```

> ℹ️ **정직성 메모 — BI 서비스 이름이 바뀌었습니다.** 공식 문서는 **`Amazon Quick`** 을 상위 서비스로 두고, 기존 **QuickSight** 를 그 안의 **`Amazon Quick Sight`**(두 단어) 기능으로 잇습니다 — *"QuickSight continues as Amazon Quick Sight, a feature within Quick."* ⚠️ **기존 QuickSight API·SDK·연동은 변경 없이 그대로 동작**하고 네임스페이스도 `quicksight` 입니다. 시험 문항과 과거 자료는 아직 **QuickSight** 로 적을 수 있으니 **두 이름을 같은 것으로** 알아 두세요. 개명의 전모는 `saa-t3-9` §8에 있습니다.

- **현행 방식은 Data Exports의 CUR 2.0**입니다. 기존 CUR과 같은 정보를 제공하면서 ① **고정 스키마**(기존 CUR은 사용 서비스·태그에 따라 열이 매월 달라짐), ② `resource_tags`·`cost_category`·`product`·`discount`의 **중첩 열**, ③ **SQL로 열 선택·행 필터·열 별칭** 지정을 지원합니다. 기존 파이프라인과 하위 호환되는 내보내기도 만들 수 있습니다.

- 월말 인보이스 발행 후 확정(finalize). 이후 환불·크레딧 반영 시 소급 업데이트.
- **AWS Support 비용**은 월말 인보이스 확정 과정에서 소급 반영됩니다(월중 CUR은 아직 반영 전인 잠정치). 참고로 현행 Support 플랜 목록은 **Basic · Business Support+ · Enterprise · Unified Operations**이며, 과거 자료의 Developer·Business·Enterprise On-Ramp 명칭과 다릅니다.

> 🧠 원리: 왜 CUR은 월중에 생성되는 파일과 월말 확정 인보이스 이후 파일이 다를 수 있을까요?
> AWS는 월중에도 현재까지의 사용량을 집계해 CUR 파일을 주기적으로 갱신하는데, 이 시점의 데이터는 아직 환불·크레딧·Support 비용이 반영되지 않은 잠정치입니다.
> 인보이스가 확정(finalize)되면 해당 항목들이 소급 반영되어 파일이 업데이트되므로, 월말 확정 전에 집계한 값과 확정 후 값이 달라질 수 있습니다.
> 정확한 비용 배분과 감사를 위해서는 인보이스 확정 이후의 CUR 데이터를 기준으로 삼아야 합니다.

### 5) AWS Cost Anomaly Detection {#cost-anomaly-detection}

> 머신러닝 모델이 계정의 지출 패턴을 학습하고, **정상 범위를 벗어난 이상 비용을 자동 감지**합니다.

구성 요소:

| 구성 요소 | 설명 |
|---|---|
| **비용 모니터(Cost Monitor)** | 무엇을 감시할지 정의 — AWS 서비스·연결 계정·태그·비용 카테고리 단위 |
| **알림 구독(Alert Subscription)** | 누구에게, 어떤 임계값으로 알릴지 설정 — 이메일·SNS, 즉시·일별·주별 |

모니터 방식:

- **AWS 관리형 모니터**: 새 계정·태그·서비스를 자동 포함. 유지 관리 최소.
- **고객 관리형 모니터**: 특정 값(최대 10개) 수동 선택. 고유 임계값 설정 가능.

> 이상 감지 후 Cost Explorer와 연동해 시계열 그래프로 루트 코즈(계정·리전·사용 유형)를 드릴다운할 수 있습니다.

> 🧠 원리: 왜 Cost Anomaly Detection은 고정 임계값 알림 대신 머신러닝 기반 이상 감지를 사용할까요?
> 클라우드 비용은 계절성·업무 주기·성장 추세 등으로 정상 지출 자체가 시간에 따라 달라지므로, 고정 임계값은 정상 변동을 오탐하거나 진짜 이상을 놓치는 상충 문제가 생깁니다.
> 머신러닝 모델은 계정별 지출 패턴을 지속적으로 학습해 "이 서비스의 이번 주 이 수준 지출은 정상 범위인가"를 동적으로 판단하므로, 고정 임계값보다 오탐·누락이 적습니다.
> 이 동적 기준선이 Budgets의 고정 알림과 Cost Anomaly Detection이 보완 관계에 있는 이유입니다.

### 6) 비용 할당 태그와 태그 정책 {#cost-allocation-tags}

태그는 AWS 리소스에 붙이는 키-값 쌍으로, 비용 가시성의 토대입니다.

| 개념 | 설명 |
|---|---|
| **비용 할당 태그 활성화** | Billing Console에서 태그를 활성화해야 CUR·Cost Explorer 필터에 나타남 |
| **AWS 생성 태그** | `aws:createdBy` 등 AWS가 자동 붙이는 태그 |
| **사용자 정의 태그** | `env:production`, `team:finance` 등 직접 설계 |
| **태그 정책(Tag Policy)** | AWS Organizations에서 태그 키·값 규칙 강제 — 대소문자·허용 값 표준화 |

태그 기반 비용 분류 흐름:

```
리소스에 태그 부착
  → Billing Console에서 비용 할당 태그 활성화
  → Cost Explorer에서 태그로 필터·그룹핑
  → CUR에서 태그 컬럼으로 팀·프로젝트별 배분
```

**활성화는 두 번 기다립니다.** 리소스에 사용자 정의 태그를 붙인 뒤 비용 할당 태그 페이지에 **그 키가 나타나기까지 최대 24시간**, 거기서 활성화를 누르고 **실제로 활성화되기까지 다시 최대 24시간**이 걸립니다. 태그를 붙인 당일에 Cost Explorer 필터가 될 것으로 기대하면 안 됩니다.

- 활성화·비활성화는 **키 단위**입니다 — 한 키를 활성화하면 그 키를 공유하는 **모든 태그 값**에 적용됩니다.
- `UpdateCostAllocationTagsStatus` API로 여러 키를 **일괄 활성화**할 수 있습니다.
- **AWS 생성 태그**(`aws:createdBy` 등)는 **관리 계정이 활성화하면** 조직의 모든 멤버 계정에 적용되며, 결제 콘솔과 비용 보고서에서만 보입니다.
- **`awsApplication` 태그**는 Service Catalog **AppRegistry**에 등록된 애플리케이션에 연결된 리소스에 자동으로 붙고 **비용 할당 태그로 자동 활성화**됩니다. 비활성화할 수는 있지만 그러면 그 애플리케이션의 비용 보고가 끊기고 **자동으로 다시 켜지지 않습니다**. 이 태그는 비용 할당 태그 **쿼터에 포함되지 않습니다**.

> 🧠 원리: 왜 리소스에 태그를 붙이는 것만으로는 충분하지 않고 Billing Console에서 별도 활성화가 필요할까요?
> AWS 리소스 태그는 운영 목적(검색·자동화·접근 제어)으로 폭넓게 사용되고, 모든 태그를 자동으로 청구 데이터에 포함하면 관련 없는 태그까지 CUR 컬럼으로 추가되어 데이터가 과도하게 커집니다.
> Billing Console에서 비용 할당 태그를 명시적으로 활성화하는 단계는 "이 태그 키를 청구 분류 기준으로 사용하겠다"는 의도를 선언하는 것으로, 이후 생성되는 CUR 데이터부터 해당 컬럼이 포함됩니다.
> 활성화 이전 기간의 데이터는 기본적으로 소급 반영되지 않지만, **backfill 요청으로 최대 12개월까지 소급 적용**할 수 있습니다 — backfill은 Cost Explorer·Data Exports·CUR을 자동으로 갱신합니다(단, 리소스에 해당 태그가 실제로 붙어 있었던 기간에 한합니다).

### 7) AWS Organizations 통합 결제와 볼륨 할인 {#consolidated-billing}

| 기능 | 내용 |
|---|---|
| **통합 결제(Consolidated Billing)** | 조직 내 모든 멤버 계정의 청구를 관리 계정이 일괄 수령 |
| **볼륨 할인 공유** | EC2·S3 등 사용량 기반 가격 책정 서비스에서 멤버 전체 합산 사용량으로 할인 티어 적용 |
| **RI·Savings Plans 공유** | 기본적으로 조직 전체에 할인 공유 (계정별 차단 가능) |

> 다계정 환경에서 RI나 Savings Plans를 특정 계정에서 구매하면, 공유가 활성화된 경우 조직 전체가 할인 혜택을 받습니다.

> 🧠 원리: 왜 통합 결제는 계정을 분리해서 사용할 때보다 볼륨 할인 티어에서 유리할까요?
> AWS의 사용량 기반 서비스는 사용량 구간이 높을수록 단가가 낮아지는 구조를 가지는데, 계정이 분리되면 각 계정의 사용량이 낮은 구간에 머물러 할인 효과가 제한됩니다.
> 통합 결제는 멤버 계정 전체의 사용량을 합산해 단일 사용량으로 간주하므로, 개별 계정이 높은 구간에 도달하지 못해도 합산 결과가 더 높은 할인 티어를 충족할 수 있습니다.
> 이 합산 효과는 동일 사용량·동일 아키텍처에서도 청구 구조 변경만으로 실질 비용을 줄일 수 있는 거버넌스 수단입니다.

### 8) Compute Optimizer와 Trusted Advisor — 비용 최적화 관점 {#compute-optimizer-trusted-advisor}

| 도구 | 비용 관점 역할 | 분석 기반 |
|---|---|---|
| **AWS Compute Optimizer** | 인스턴스 과/저프로비저닝 감지 → **적정 크기(Rightsizing) 추천** | CloudWatch 지표 **기본 룩백 14일** — 유료 *향상된 인프라 지표*를 켜면 **32일**·**93일**로 늘릴 수 있음 |
| **AWS Trusted Advisor** | 미사용 리소스, 유휴 로드밸런서, 저사용 EC2 등 비용 낭비 항목 탐지 | 계정 스냅샷 기반 규칙 점검 |

> **Compute Optimizer** = "이 인스턴스 크기가 맞나?" / **Trusted Advisor** = "이 리소스를 아직도 쓰고 있나?" — 질문이 다릅니다.

**Trusted Advisor 전체 점검에는 지원 플랜 조건이 붙습니다.** 비용 점검을 포함한 전체 목록은 무료로 열리지 않습니다.

| 플랜 | 쓸 수 있는 점검 | 접근 방식 |
|---|---|---|
| **Basic** | **서비스 한도 카테고리** 전체 + **보안·내결함성 카테고리의 일부** 점검 | 콘솔만. **자동 점검 갱신**이 없어 보안 점검은 직접 새로고침해야 함 |
| **Business Support+** · **Enterprise Support** · **Unified Operations** | **전체 점검** | 콘솔 + Trusted Advisor API + EventBridge로 점검 결과 모니터링 |

비용 카테고리에서 자주 나오는 점검은 저사용 EC2 인스턴스, 유휴 로드밸런서, 과다 프로비저닝된 EBS 볼륨(Compute Optimizer 연계), S3 수명 주기 미구성 등입니다.

> ⚠️ **플랜 개편 — 2027-01-01**: Developer Support와 Business Support는 **2027-01-01에 종료**되고, **Enterprise On-Ramp**도 같은 날 종료되면서 2026년 중 계약 갱신이나 일괄 처리로 **Enterprise Support로 자동 승급**됩니다. 단 **AWS GovCloud (US)** 리전에서는 Developer·Business·Enterprise On-Ramp가 **계속 제공**됩니다. 시험 문항과 과거 자료에는 옛 플랜 이름이 남아 있을 수 있으니 두 체계를 함께 알아 두세요.

> 🧠 원리: 왜 Compute Optimizer는 CloudWatch 지표를 기반으로 하고, Trusted Advisor는 규칙 기반 스냅샷 점검을 사용할까요?
> 인스턴스 적정 크기 판단은 순간 스냅샷이 아닌 시간 경과에 따른 실제 부하 패턴을 봐야 과/저프로비저닝을 구분할 수 있어, 지속 수집된 CloudWatch 지표가 필요합니다.
> 반면 Trusted Advisor가 탐지하는 항목(미사용 EIP, 빈 로드밸런서, 유휴 RDS)은 현재 구성 상태만 점검해도 파악 가능하므로, 실시간 지표보다 규칙 기반 스냅샷이 더 간단하고 빠릅니다.
> 두 도구의 분석 기반 차이는 각자가 답하는 질문의 성격(트렌드 분석 vs. 현재 상태 점검)에서 비롯됩니다.

### 9) Well-Architected 비용 최적화 기둥 — 5가지 설계 원칙 (★ 시험 필수) {#well-architected-cost}

> 비용 최적화 기둥 공식 정의: "기능 요구사항을 충족하면서 최저 가격으로 결과를 달성하는 워크로드."

| 원칙 | 핵심 내용 |
|---|---|
| **클라우드 재무 관리 실천** | 비용 효율성을 조직 역량으로 구축. 보안·운영과 동급의 전담 인력·프로세스 투자 |
| **소비 모델 채택** | 사용한 만큼만 지불. 개발·테스트 환경을 업무 외 시간에 중단하면 최대 75% 절감(주 40시간 vs 168시간) |
| **전반적 효율성 측정** | 워크로드의 비즈니스 산출물과 비용을 함께 측정. 출력 증가·기능 향상·비용 절감의 복합 이득을 데이터로 파악 |
| **미분화된 무거운 작업 중단** | 데이터 센터 운영(랙·전원·OS 관리)은 AWS에 위임. 비즈니스와 고객에 집중 |
| **지출 분석 및 귀속** | 클라우드에서는 워크로드별 비용을 정확히 식별·귀속 가능. ROI 측정과 소유자 단위 최적화 가능 |

5가지 실천 영역(Practice Areas):

1. 클라우드 재무 관리 실천
2. 지출·사용량 인식
3. 비용 효율적 리소스
4. 수요·공급 리소스 관리
5. 시간 경과에 따른 최적화

> 🧠 원리: 왜 Well-Architected 비용 최적화 기둥은 "단순히 아끼는 것"이 아니라 기능 요구사항을 충족하는 범위에서 최저 비용을 추구하도록 정의할까요?
> 보안·안정성·성능을 희생해 비용만 낮추면 다른 기둥의 원칙을 위반하게 되므로, 5개 기둥은 서로 균형을 맞추도록 설계되어 있습니다.
> "기능 요구사항 충족"이라는 전제가 없으면 비용 최소화가 다른 품질 속성을 잠식하는 수단이 될 수 있어, 이 조건이 비용 최적화의 합법적 경계를 정의합니다.
> 시험에서 "most cost-effective" 선택지는 항상 요구사항을 충족하는 옵션 중에서 고르는 것임을 이 원칙이 뒷받침합니다.

---

## ✍️ 시험 포인트

| 상황 | 정답 |
|---|---|
| 지난 3개월 EC2 비용 추세 분석 + RI 구매 추천 확인 | AWS Cost Explorer |
| 월 예산 $1,000 초과 시 이메일 알림 + 추가 EC2 생성 차단 | AWS Budgets (Budget Actions) |
| 팀·프로젝트별 시간 단위 비용 세분화, Athena로 SQL 쿼리 필요 | Cost and Usage Report (CUR) |
| 특정 서비스에서 갑자기 비용이 3배 급등했는데 원인을 모름 | AWS Cost Anomaly Detection |
| 인스턴스 CPU 10% 미만 — 더 작은 타입으로 변경 추천 | AWS Compute Optimizer |
| 6개월째 사용하지 않는 EBS 볼륨, 유휴 로드밸런서 감지 | AWS Trusted Advisor |
| 다계정 환경에서 RI 할인을 조직 전체에 공유 | AWS Organizations 통합 결제 + RI 공유 |
| 태그 키를 `Env`·`env`·`ENV` 혼용 — 일관화 강제 | AWS Organizations 태그 정책 |
| "사용한 만큼만 지불, 미사용 시 중단"은 어느 Well-Architected 원칙? | 소비 모델 채택(Adopt a consumption model) |
| 작년 대비 올해 비용을 비교해야 하는데 Cost Explorer에 24개월 전 데이터가 없음 | 관리 계정이 **다년 데이터**(월 단위, 최대 38개월) 활성화 |
| 특정 EC2 인스턴스의 지난주 시간대별 비용을 봐야 함 | 관리 계정이 **시간 단위 + EC2 리소스 단위** 활성화(최근 14일) |
| Basic 플랜 계정에서 Trusted Advisor 비용 점검 전체를 보려면? | Business Support+ · Enterprise Support · Unified Operations 중 하나로 업그레이드 |

---

## ⚠️ 흔한 함정 {#common-pitfalls}

1. **"Cost Explorer로 예산 초과를 막을 수 있다."** → Cost Explorer는 분석·시각화 도구이고, 알림·차단은 AWS Budgets입니다. 예산 초과 알림이 필요하면 Budgets를 써야 합니다.
   *(원리: §1 본문 — 비교표에서 Cost Explorer의 출력은 그래프·예측·추천이며, 알림·차단은 Budgets의 역할로 분리된다.)*

2. **"CUR은 Cost Explorer와 같다."** → CUR은 S3에 저장되는 CSV 원시 데이터(라인 아이템), Cost Explorer는 그 위에 올라간 인터랙티브 UI입니다. 둘은 같은 데이터셋을 공유하지만 용도가 다릅니다. 시간 단위 세분화·Athena 쿼리가 필요하면 CUR입니다.
   *(원리: §2 — CUR은 심층 감사·파이프라인용 원시 데이터이고, Cost Explorer는 즉각 분석용 집계 레이어로 역할이 분리된다.)*

3. **"Compute Optimizer와 Trusted Advisor는 같은 것이다."** → Compute Optimizer는 CloudWatch 지표 기반의 **적정 크기 추천**에 집중합니다. Trusted Advisor는 여러 카테고리(비용·보안·성능·내결함성·서비스 한도)를 포괄하는 **광범위한 모범 사례 점검** 도구입니다.
   *(원리: §8 — 두 도구는 답하는 질문이 달라 분석 기반도 다르다: Compute Optimizer는 시간 경과 지표, Trusted Advisor는 현재 상태 스냅샷.)*

4. **"통합 결제를 사용하면 비용이 합산되어 볼륨 할인을 받지 못한다."** → 반대입니다. 통합 결제는 멤버 계정의 사용량을 **합산**해 볼륨 할인 티어를 유리하게 적용받습니다.
   *(원리: §7 — 합산 사용량이 더 높은 할인 티어를 충족해 개별 계정 분리보다 단가가 낮아질 수 있다.)*

5. **"비용 할당 태그는 붙이면 바로 CUR에 나온다."** → Billing Console에서 해당 태그 키를 **비용 할당 태그로 활성화**해야 합니다. 활성화 이전 기간 데이터는 기본적으로 소급 반영되지 않으나, backfill 요청으로 최대 12개월 소급이 가능합니다.
   *(원리: §6 — 활성화 단계가 "이 태그를 청구 분류 기준으로 사용"하겠다는 선언이며, 활성화 전 기간은 기본적으로 미반영이지만 backfill 요청으로 소급 적용할 수 있다.)*

6. **"Well-Architected 비용 최적화 원칙은 단순히 '아끼는 것'이다."** → 비용 최적화는 기능 요구사항을 **충족하는 범위에서** 비용을 최소화하는 것입니다. 보안·안정성을 희생하는 비용 절감은 Well-Architected 원칙 위반입니다.
   *(원리: §9 — 5개 기둥은 균형을 맞추도록 설계되어 있어, 비용 최적화는 다른 기둥 원칙을 지키는 범위 안에서만 유효하다.)*

7. **"Budget Actions의 조치에 SNS 알림이 포함된다."** → 조치 유형은 **IAM 정책 연결 · SCP 적용 · 실행 중 EC2/RDS 인스턴스 대상 지정** 세 가지이고, SNS는 조치가 아니라 알림 채널입니다. 각 조치는 자동 실행 또는 승인 후 실행을 고를 수 있습니다.
   *(원리: §3 — IAM·SCP 연결은 사람 개입 없이 리소스 생성을 차단하는 제어 수단이고, 알림은 사람을 호출하는 통지 수단이라 역할이 다르다.)*

8. **"Basic 플랜에서도 Trusted Advisor 비용 점검을 전부 볼 수 있다."** → Basic은 **서비스 한도 카테고리** 전체와 **보안·내결함성 카테고리의 일부**만 열리고, 자동 점검 갱신도 없습니다. 비용 점검을 포함한 전체 목록과 API 접근은 **Business Support+ · Enterprise Support · Unified Operations** 플랜이 필요합니다.
   *(원리: §8 — 전체 점검은 유료 지원 플랜의 제공 범위에 묶여 있고, Basic은 콘솔에서 제한된 카테고리만 본다.)*

9. **"Cost Explorer는 켜면 바로 몇 년 치든 시간 단위든 다 볼 수 있다."** → 기본은 **14개월·일·월 단위**입니다. 다년(최대 38개월)·시간 단위·리소스 단위는 **관리 계정이 따로 켜야** 하고, 반영까지 최대 48시간이 걸립니다. 시간 단위·일 단위 리소스 데이터는 **최근 14일**만 남습니다.
   *(원리: §2 — 세분화 데이터는 저장·집계 부담이 커서 기본값이 아니라 조직 차원의 선택 항목으로 분리돼 있다.)*

---

## 🧪 자가 점검

> 아래는 학습용 자가 점검입니다. (정식 검증 문항은 별도 문항 파일 참조)

**Q1.** 팀장이 "지난 6개월간 우리 계정의 서비스별 비용 추세를 보고, 앞으로 3개월 예측도 보고 싶다"고 합니다. 어떤 도구를 사용합니까?

<details><summary>정답 보기</summary>

**AWS Cost Explorer**를 사용합니다. Cost Explorer는 과거 13개월 이력 조회와 향후 18개월 예측을 서비스·계정·리전·태그별로 시각화합니다. 콘솔 UI 사용은 무료이며, 별도 설정 없이 필터와 그룹핑으로 원하는 뷰를 구성할 수 있습니다.
</details>

**Q2.** 월 AWS 지출이 $5,000을 초과하면 재무팀에 이메일로 알리고, $7,000을 초과하면 추가 EC2 인스턴스 시작을 자동으로 차단해야 합니다. 어떻게 구성합니까?

<details><summary>정답 보기</summary>

**AWS Budgets**로 월 비용 예산을 생성합니다. 첫 번째 알림은 $5,000(실제 비용) 임계값에 이메일 알림을 설정합니다. 두 번째 조치는 **Budget Actions**로 $7,000 초과 시 `ec2:RunInstances`를 Deny하는 IAM 정책을 자동 연결합니다. SNS 토픽을 통해 추가 채널 알림도 가능합니다.
</details>

**Q3.** 데이터 엔지니어링 팀이 AWS 비용 데이터를 Amazon Athena로 SQL 쿼리해 프로젝트별·리소스별 시간 단위로 분석하고 싶습니다. 무엇을 설정해야 합니까?

<details><summary>정답 보기</summary>

**AWS Cost and Usage Report(CUR)**를 S3 버킷으로 전달하도록 설정하고, Athena 통합을 활성화합니다. CUR은 시간·일·월 단위 라인 아이템 데이터를 CSV로 S3에 저장하며, Athena 통합을 선택하면 Glue 크롤러와 Athena 테이블이 자동 생성되어 SQL로 직접 쿼리할 수 있습니다.
</details>

**Q4.** 지난주 특정 계정에서 EC2 비용이 평소의 4배로 급등했으나 아무도 눈치채지 못했습니다. 앞으로 이런 상황을 자동으로 감지하려면 어떤 서비스를 사용합니까?

<details><summary>정답 보기</summary>

**AWS Cost Anomaly Detection**을 사용합니다. 계정별 비용 모니터를 생성하고 알림 구독(이메일 또는 SNS)을 설정하면, 머신러닝 모델이 정상 지출 패턴을 학습하고 이상 급등을 자동 감지해 알립니다. 이상 감지 후 Cost Explorer 연동으로 루트 코즈(서비스·리전·사용 유형)를 드릴다운할 수 있습니다.
</details>

**Q5 (원리).** 왜 비용 할당 태그를 리소스에 미리 붙여뒀어도, 과거 3개월 치 CUR 데이터에서 그 태그로 필터링이 안 되는 상황이 발생할 수 있나요?

<details><summary>정답 보기</summary>

CUR에서 태그 컬럼이 포함되려면 Billing Console에서 해당 태그 키를 비용 할당 태그로 활성화해야 합니다. 활성화 이전 기간의 데이터는 기본적으로 소급 반영되지 않으므로, 리소스에 태그가 존재하더라도 활성화 전 기간의 태그 필터링이 되지 않는 상황이 발생합니다. 단, backfill 요청을 통해 최대 12개월까지 소급 적용이 가능하며, 이 경우 Cost Explorer·Data Exports·CUR이 자동으로 갱신됩니다(리소스에 해당 태그가 실제로 붙어 있었던 기간에 한함). 또한 태그를 붙인 직후에도 즉시 활성화되지 않습니다 — 키가 비용 할당 태그 페이지에 나타나기까지 최대 24시간, 활성화되기까지 다시 최대 24시간이 걸립니다.
</details>

**Q6.** 재무팀이 "작년 대비 올해 비용 추세를 보고 싶다"며 Cost Explorer에서 24개월 전 데이터를 찾는데 보이지 않습니다. 같은 팀이 "지난주 특정 EC2 인스턴스의 시간대별 비용"도 요청했습니다. 각각 무엇을 해야 합니까?

<details><summary>정답 보기</summary>

둘 다 **관리 계정**이 Cost Management 환경설정에서 옵션을 켜야 합니다. 연도 비교는 **다년 데이터**(월 단위, 최대 38개월)를, 인스턴스 시간대별 비용은 **시간 단위 + EC2 인스턴스 리소스 단위** 데이터를 활성화합니다. 설정은 반영까지 **최대 48시간**이 걸리고 저장 후 48시간은 다시 바꿀 수 없습니다. 주의할 점이 둘 있습니다 — 시간 단위·일 단위 리소스 데이터는 **최근 14일**만 남으므로 "지난주"는 조회되지만 24개월 전 시간대별 데이터는 **어떤 설정으로도 볼 수 없습니다**. 그리고 다년 데이터는 Cost Explorer에서만 보이고 Savings Plans·예약의 **사용률·커버리지 보고서**에는 적용되지 않습니다. 조직에서 **3개월 연속** 아무도 열어보지 않으면 다년 데이터는 자동 비활성화됩니다.
</details>

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. (작성·대조: 2026-06-07 · 고도화 검수: 2026-06-12)

1. AWS Cost Explorer — https://docs.aws.amazon.com/cost-management/latest/userguide/ce-what-is.html
2. AWS Budgets — https://docs.aws.amazon.com/cost-management/latest/userguide/budgets-managing-costs.html
3. AWS Cost and Usage Report (CUR) — https://docs.aws.amazon.com/cur/latest/userguide/what-is-cur.html
4. AWS Cost Anomaly Detection — https://docs.aws.amazon.com/cost-management/latest/userguide/getting-started-ad.html
5. Well-Architected 비용 최적화 기둥 설계 원칙 — https://docs.aws.amazon.com/wellarchitected/latest/cost-optimization-pillar/design-principles.html
6. SAA-C03 공식 시험 가이드 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
7. 비용 할당 태그 Backfill — https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/cost-allocation-backfill.html (게이트 검수 반영: 2026-06-12)
8. 비용 할당 태그 활성화 — https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/activating-tags.html (게이트 검수 반영: 2026-06-12)
9. 예산 조치 구성(IAM·SCP·EC2/RDS 대상, 자동 또는 승인 후 실행) — https://docs.aws.amazon.com/cost-management/latest/userguide/budgets-controls.html
10. CUR → Data Exports CUR 2.0 마이그레이션(고정 스키마·중첩 열·SQL 선택) — https://docs.aws.amazon.com/cur/latest/userguide/dataexports-migrate.html
11. Compute Optimizer 향상된 인프라 지표(기본 14일 → 최대 93일, 유료) — https://docs.aws.amazon.com/compute-optimizer/latest/ug/enhanced-infrastructure-metrics.html
12. AWS Support 플랜(현행 목록) — https://aws.amazon.com/premiumsupport/plans/
13. Cost Explorer 다년 데이터(월 단위 최대 38개월 · 48시간 내 제공 · 3개월 연속 미접근 시 비활성화 · SP/예약 보고서 미지원) — https://docs.aws.amazon.com/cost-management/latest/userguide/ce-multi-year-data.html
14. 다년·세분화 데이터 설정(관리 계정이 활성화 · 시간/일 리소스 단위는 최근 14일 · 반영 최대 48시간 · 저장 후 48시간 변경 불가 · Billing Conductor 제약) — https://docs.aws.amazon.com/cost-management/latest/userguide/ce-configuring-data.html
15. 비용 할당 태그 활성화(목록 등장 최대 24시간 + 활성화 최대 24시간 · 키 단위가 모든 값에 적용 · `UpdateCostAllocationTagsStatus` 일괄 활성화 · `awsApplication` 자동 활성화와 쿼터 예외) — https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/activating-tags.html
16. AWS 생성 비용 할당 태그(관리 계정이 활성화하면 멤버 계정 전체 적용) — https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/activate-built-in-tags.html
17. Trusted Advisor 지원 플랜 조건(Basic은 서비스 한도 전체 + 보안·내결함성 일부 · 전체 점검은 Business Support+/Enterprise/Unified Operations · 2027-01-01 플랜 종료 · GovCloud 존치) — https://docs.aws.amazon.com/awssupport/latest/user/trusted-advisor.html
18. Compute Optimizer 룩백 기간(14·32·93일) — https://docs.aws.amazon.com/help-panel/compute-optimizer/latest/console/rightsizing-lookback.html

> 📝 **2026-10-19 정정**: ① Budget Actions 조치 3종을 **IAM 정책·SCP·실행 중 EC2/RDS 인스턴스 대상**으로 고쳤습니다 — SNS는 조치가 아닌 알림 채널이고, 자동 실행/승인 후 실행을 선택합니다(근거 9번). ② Budgets 데이터 범위를 "실시간"에서 **하루 최대 3회 갱신**으로 바로잡았습니다. ③ CUR 절에 **Data Exports의 CUR 2.0**(고정 스키마·중첩 열·SQL 선택·Parquet)을 반영했습니다(근거 10번). ④ 근거를 찾지 못한 "Support 비용은 해당 월 6~7일 반영" 문장을 삭제하고 **현행 Support 플랜 명칭**으로 갱신했습니다(근거 12번). ⑤ Compute Optimizer를 "지표 14일 이상 수집"에서 **기본 룩백 14일 / 향상된 인프라 지표 최대 93일**로 고쳤습니다(근거 11번).

> 📝 **2026-10-22 보강 — 갭 배치 B9a-2(`G-4.1-11`·`G-4.1-12`)**: ① §2에 Cost Explorer의 **기본 14개월(과거 13개월 + 당월)·일·월 단위**와, 관리 계정이 켜는 **다년(월 단위 최대 38개월)·시간 단위·일 단위 리소스 데이터**를 넣었습니다(근거 13·14번) — 시간·일 리소스 데이터는 **최근 14일**, 설정 반영 **최대 48시간**, **3개월 연속** 미접근 시 다년 데이터 자동 비활성화, 다년 데이터는 SP·예약 **사용률·커버리지 보고서** 미지원. ② §6에 태그 **활성화 2단 지연(각 최대 24시간)**·키 단위 활성화가 **모든 태그 값**에 적용·`UpdateCostAllocationTagsStatus` 일괄 활성화·**AWS 생성 태그는 관리 계정이 활성화**·`awsApplication` 자동 활성화와 쿼터 예외를 넣었습니다(근거 15·16번). ③ §8에 **Trusted Advisor 전체 점검의 지원 플랜 조건**과 **2027-01-01 플랜 개편·GovCloud(US) 존치**를 넣고(근거 17번), Compute Optimizer 룩백에 **32일**을 추가했습니다(근거 18번). ④ ⚠️ **갭 노트 정정**: `98-existing-gap.md`의 `G-4.1-12`는 Basic 플랜을 "보안 6종 + 서비스 한도"로 적었지만, 공식은 **서비스 한도 카테고리 전체 + 보안·내결함성 카테고리의 일부**입니다 — 내결함성이 빠져 있었고 "6종"이라는 수치는 해당 문서에 없습니다. 본문은 공식을 따랐습니다. ⑤ **쓰지 않은 것 4건**(근거 미확보): Cost Explorer 세분화의 추가 과금(설정 문서에 과금 언급이 없음) · Cost Optimization Hub(`4-1.md` F-30~F-36에 근거 행 부재) · CUR 2.0·FOCUS 1.0 세부(`99-gaps` V-88 — 기본 서술은 §1 표·§4에 이미 있음) · Support 플랜 월 최소 요금(시험 범위 밖·휘발성). 네 건 모두 `test/saa_gaps_b9a2_test.dart`가 금지합니다.
