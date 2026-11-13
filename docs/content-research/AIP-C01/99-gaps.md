---
생성: 2026-11-13
목적: AIP-C01 조사에서 **판정하지 못한 것**과 **저작 전에 다시 재야 할 것** (Phase 1)
조회일: 2026-11-13
---

# AIP-C01 — 99 갭

규율: 공식 문서로 확인되지 않은 것은 **본문에 쓰지 않고 여기 남긴다.** 추측으로 채우지 않는다.
닫힌 항목은 지우지 않고 **해소 근거와 함께** 남겨, 다음 작업자가 같은 측정을 반복하지 않게 한다.

## 해소된 것

### ✅ G-01. 시험 시간 — 가이드에 없고 인증 페이지에 있다

공식 가이드 본문에 시험 시간이 **없다**(`분`·`minute`·`시간` 전수 확인). 레포 JSON의
`durationMinutes: 180`은 **공식 인증 페이지** `Exam duration` 「180 minutes」로 확인됐다.
같은 페이지가 `Exam format` 「75 questions」(= 채점 65 + 비채점 10)와 응시 언어에 **한국어**가
드는 것도 적는다.

⚠️ AIF-C01에서는 이 자리가 **미확보**로 남아 `durationMinutes`를 가이드 근거로 적을 수 없었다 —
자격증마다 다르므로 **인증 페이지를 함께 읽는다.**

### ✅ G-04. 레포 JSON의 신뢰도 — 구조는 맞고 본문 4곳만 다르다

기계 대조 118항목에서 **구조 불일치 0 · 공백만 차이 0 · 본문 차이 4**다(97 §0).
「레포 JSON은 믿을 수 없다」는 AIF의 교훈은 **자격증마다 다르다**는 SCS 판정이 다시 확인됐다.

## 열린 것 — 저작 전에 판정해야 한다

### ⚠️⚠️ G-02. `기술 2.5.3`의 `Amazon Q Business` 구절이 왜 레포에만 있는지 확정할 수 없다

레포 JSON에는 공식 현행(ko·en 양쪽)에 **없는 예시 한 개**가 더 있다(97 §2-3).
가이드에 **개정(Revisions) 절이 없어** 「가이드가 지웠다」를 공식으로 확인할 길이 없다.

- 교체 자체는 막히지 않는다 — **공식 현행 전문으로 바꾼다**(P-02).
- 다만 노트·커밋 메시지에 「가이드가 개정됐다」를 **사실로 적지 않는다**. 적을 수 있는 것은
  「공식 현행 ko·en 어디에도 없다」와 「레포 수집분은 2026-06-09 커밋이다」뿐이다.
- ⚠️ **예시에서 빠진 것이 범위에서 빠진 것은 아니다** — `Amazon Q Business`·`Amazon Q Business Apps`는
  지금도 범위 내 목록에 있다.

### ⚠️ G-03. 공식 한국어 판 `기술 4.3.1`이 괄호를 닫지 않는다

영문 판은 `).`로 닫는다. **공식 ko의 오기**이고 고쳐 달라고 할 길이 없다.
처리는 D-06(전사 층은 공식 그대로)이고, **가드를 금지형으로 쓰면 안 된다**(접두사 관계).

### ⚠️ G-05. 공식 ko가 같은 제품을 **세 표기**로 쓰고 그중 하나는 영문과 다르다

`Strands 에이전트`(2.1.1) · **`Strand API`**(2.1.6) · `Strands Agents`(2.5.5).
영문은 `Strands Agents` 둘 + `Strands API` 하나로 **전부 `Strands`**이므로 **ko의 `Strand API`가 오기**다.
⚠️ 레포 JSON은 **그 오기까지 공식 ko와 같아** 대조 차이에 들지 않았다(97의 4건에 2.1.6은 없다).
저작 표기는 D-05에서 정했고, **표기나 개수를 묻는 문항은 쓰지 않는다**.

### ⚠️⚠️ G-06. 공식 **범위 내** 목록에 유지 관리 상태 서비스가 셋 있다

`Amazon Kendra`(2026-06-30) · `Amazon Q Business`(2026-06-30) · `AWS App Runner`(2026-03-31).
SCS-C03에서 최대 제약이었던 것과 같은 종류다. 처리는 D-07이고, **각 서비스의 전용 상태 페이지를
P-01에서 직접 읽어** 「신규 고객 차단인지 / 기존 고객은 계속인지 / 이전 대상이 무엇인지」를 확정한다.

### ⚠️⚠️ G-07. 상태 대조에서 **이름이 달라 비켜 가는 자리**가 두 번 나왔다

| 범위 내 목록 표기 | lifecycle 표 표기 | 이름으로 세면 |
|---|---|---|
| `Amazon Augmented AI` | `Amazon SageMaker AI – A2I` | **0건** |
| (`CloudTrail Lake`로 탐침) | `AWS CloudTrail – Lake` | **0건** |

en dash 구분 기호와 제품 계열 접두사(`Amazon SageMaker AI – …`)가 원인이다.
**대조는 양쪽 표기로 센다.** 그리고 이번 측정의 대조군 넷(`Simple AD` · `Mechanical Turk` ·
`AWS Audit Manager` · 없는 이름)이 통과한 뒤의 결과만 결과로 쓴다.

### ⚠️ G-08. **기능 단위**로 상태가 바뀐 것이 가이드 예시와 직결된다

Phase 1 대조에서 나온 것(공지일 기준, 전부 lifecycle 세 표 실측):

| 기능 | 표 | 공지 | 가이드와의 접점 |
|---|---|---|---|
| `Amazon Bedrock Agents Classic` | 유지 관리 | 2026-06-30 | 도메인 2 에이전틱 AI 전체 |
| `Amazon Comprehend – Topic Modeling, Event Detection, and Prompt Safety Classification` | 유지 관리 | 2026-03-31 | `기술 3.1.4`의 「Comprehend 사전 처리 필터」 |
| `Amazon SageMaker AI – A2I` · `Clarify` · `Ground Truth` · `Model Monitor` · `Debugger` · `Role Manager` · `GeoSpatial` · `Studio Lab` | 유지 관리 | 2026-06-30 | 범위 내 목록이 A2I·Clarify·Ground Truth·Model Monitor를 **각각 항목으로** 든다 |
| `Amazon SageMaker AI – Ground Truth Plus` | 완전 종료 | 2026-06-30 | 위와 짝 |
| `Amazon SageMaker AI – Profiler` | sunset | 2026-06-30 → 2027-06-30 | 도메인 4 성능 최적화 |
| `Amazon Q Developer IDE plugins` | sunset | 2026-04-30 → 2027-04-30 | `기술 2.5.4`·`2.5.6`의 Q Developer |
| `Amazon SNS – Message Data Protection (MDP)` | 유지 관리 | 2026-03-31 | 도메인 3 데이터 보호 |
| `AWS WAF Classic` | 완전 종료 | 2026-10-07 | 범위 내 `AWS WAF` |
| `Amazon S3 Object Lambda` · `S3 Select` · `Glacier Select` · `Glacier Direct` | 유지 관리 | 2024-07~2025-11 | 범위 내 `Amazon S3` 계열 |
| `AWS Glue – Ray jobs` | 유지 관리 | 2026-03-31 | `기술 1.3.1`의 Glue Data Quality와 **다른 기능** |
| `AWS Service Catalog – Application Registry` | 유지 관리 | 2026-06-30 | 범위 내 `AWS Service Catalog` |
| `AWS Systems Manager – Application Manager` · `Change Manager` · `Incident Manager` | 유지 관리 | 2025-11~2026-06 | 범위 내 `AWS Systems Manager` |
| `Amazon Cognito Sync` | 유지 관리 | 2026-06-30 | 범위 내 `Amazon Cognito` |
| `AWS CloudTrail – Lake` | 유지 관리 | 2026-03-31 | `기술 1.6.3`·`3.3.2`의 CloudTrail |
| `Amazon CloudWatch Evidently` | 완전 종료 | 2025-10-17 | 도메인 4 A/B 테스트 축 |
| `Amazon Rekognition – Streaming Events / Batch Image Content Moderation` | 유지 관리·완전 종료 | 2026-03-31 / 2025-10-31 | 도메인 3 콘텐츠 조정 |
| `Amazon Kinesis Data Analytics for SQL` | 완전 종료 | 2026-01-27 | 범위 내 `Amazon Kinesis` |
| `AWS DataSync Discovery` | 완전 종료 | 2025-05-20 | 범위 내 `AWS DataSync` |
| `Amazon Connect Customer Voice ID` | 완전 종료 | 2026-05-20 | 범위 내 `Amazon Connect` |
| `Amazon RDS Custom for Oracle` | sunset | 2026-03-31 → 2027-03-31 | 범위 내 `Amazon RDS` |

⚠️ **이 표는 「이름이 걸렸다」까지이고 각 기능의 전용 상태 페이지는 아직 읽지 않았다.**
P-01에서 읽고, **가르치는 층에서 드는 것만** 상태를 병기한다(D-07).

### ⚠️ G-09. 기술 본문이 드는 이름 중 **범위 목록 어디에도 없는 것**이 있다

실측(범위 내 0 · 범위 외 0 · 기술 본문 n):
`Strands`(2) · `AWS Agent Squad`(2) · `MCP`(5) · `AWS Lake Formation`(1) · `pgvector`(1) ·
`Amazon Bedrock Data Automation`(1) · `Amazon Bedrock Model Evaluations`(1) · 가드레일 계열(6).

- 뒤쪽 셋은 **`Amazon Bedrock`의 기능**이고 Bedrock은 범위 내다. ⚠️ 그런데 같은 목록이
  `Bedrock Knowledge Bases`·`Prompt Management`·`Prompt Flows`·`AgentCore`는 **각각 항목으로 들면서**
  `Guardrails`·`Data Automation`·`Model Evaluations`는 들지 않는다 — **목록의 입도가 일정하지 않다.**
  그래서 **「Bedrock 기능이 몇 개 범위 내인가」류는 묻지 않는다.**
- `Strands Agents`·`AWS Agent Squad`·`MCP`는 **기술 본문이 이름으로 직접 든다**(`기술 2.1.1`·`2.1.6`·
  `2.1.7`·`2.5.5`·`1.5.6`). AIF의 `Amazon Q`(개정 표에만 있고 본문에 없어 **정답 금지** 판정)와는
  상황이 다르다 — **출제 가능으로 보되 P-03에서 공식 문서 실재를 먼저 확인한다.**

### ⚠️ G-10. 범위 내에 `Amazon Quick`과 `Amazon Quick Sight`가 **둘 다** 있다

AIF-C01은 `Amazon Quick`만 있었고(AIF 95 §3.1 — Quick Sight는 Quick **안의 기능**),
DVA-C03에는 「Quick 범위 내 / Quick Sight 범위 밖」 짝이 기록돼 있다.
**AIP-C01은 둘 다 범위 내이고 카테고리가 갈린다**(`Amazon Quick Sight` = 분석 / `Amazon Quick` = 기계 학습).
⚠️ **포함 관계를 문항 축으로 쓰려면 이 자격증의 목록을 근거로 다시 세운다** — 다른 자격증의 짝을
옮겨 쓰면 틀린다.

### ⚠️ G-11. 범위 외 목록 96개 중 44개가 lifecycle 표에 걸린다

측정값만 남긴다(저작 대상이 아니다). 범위 외 목록이 **닫힌 서비스를 모아 둔 곳에 가깝다**는 뜻이고,
**범위 외 서비스를 정답으로 쓰지 않는다**는 D-08 규율의 근거가 된다.

### ⚠️ G-12. 가이드 개정 감시 수단이 없다

개정 절이 없어 **버전·발행일을 가이드에서 알 수 없다.** 그래서 「가이드가 바뀌었는지」는
**이 트랙의 기계 대조를 다시 돌리는 것**으로만 안다(97 §1). 저작 배치마다 그 배치가 쓰는
Task의 기술 전문을 **공식에서 다시 읽는다** — SCS가 P-03 교체 전에 70개를 재측정해
「차이가 정확히 2건」을 확인한 것과 같은 절차다.

### ⚠️ G-13. 「시험에 출제될 수 있는 기술 및 개념」 20항목에 **일반 개발 축이 섞여 있다**

서버리스 컴퓨팅 · 컨테이너 오케스트레이션 · IaC · CI/CD · 하이브리드 클라우드 · 엔터프라이즈 통합 ·
이벤트 기반 아키텍처 · API 설계가 GenAI 축과 나란히 있다.
⚠️ 「범위에 해당하지 않는 작업」은 **모델 개발·훈련 / 고급 ML 기술 / 데이터 엔지니어링·특성 추출**
셋뿐이므로, **일반 개발 주제를 범위 밖으로 다루면 안 된다.** 다만 **FM과 엮이는 축으로만** 출제한다
(가이드의 모든 기술이 FM·GenAI 맥락으로 쓰여 있다).
