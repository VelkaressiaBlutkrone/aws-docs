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

### ✅ G-06. 범위 내 유지 관리 서비스 셋 — **전수 확인에서 그대로였고 이전 대상까지 확정했다**

`Amazon Kendra`(2026-06-30) · `Amazon Q Business`(2026-06-30) · `AWS App Runner`(2026-03-31).
P-01 전수 확인에서 **신규 추가 0건**이고, 각 서비스의 전용 상태 페이지를 읽어 공식 문구와 대안을 확정했다
([96-service-status-audit.md](96-service-status-audit.md) §5-1):

| 서비스 | 공식 문구 | 공식이 권하는 대안 |
|---|---|---|
| Amazon Kendra | `no longer open to new customers` | ⭐ **Amazon Bedrock Knowledge Bases** |
| Amazon Q Business | 같음 | **Amazon Quick** |
| AWS App Runner | 같음 + `This guide applies only to existing customers.` | **Amazon ECS Express Mode** |

⚠️⚠️ **Kendra의 대안이 이 자격증의 RAG 축 그 자체다** — `작업 1.4`·`1.5`의 검색 소재를 Kendra로 쓰면
공식이 권하지 않는 쪽을 가르친다.

### ✅ G-07. 이름이 달라 비켜 가는 자리 — **별칭 표로 닫았고, 그 별칭이 한 번 더 비켜 갔다**

P-01에서 `Amazon Augmented AI` ↔ `Amazon SageMaker AI – A2I` 같은 자리를 **별칭 표**로 처리했다.
⚠️⚠️ 그런데 파생 변이형에 쓰던 `len >= 4` 필터가 **별칭에도 적용돼 `A2I`(3글자)가 조용히 걸러졌다** —
**G-07이 경고한 자리가, G-07을 반영한 코드에서 다시 비켜 갔다.** 필터는 파생 변이형에만 적용한다
(96 §3-3). 매칭이 틀리는 네 방식은 96 §3이 정본이다.

### ✅ G-08. 기능 단위 상태 변경 — **35개 행 / 22개 서비스**로 확정했다

Phase 1의 표는 「이름이 걸렸다」까지였다. P-01에서 **공식 상태 페이지 URL까지** 확정했고
(96 §5-2), 수가 Phase 1보다 늘었다 — 1차 매처가 `서비스 – 기능` 꼴만 가정해 **24건을 놓치고 있었고
대조군 7개가 전부 통과하는 상태였다**(96 §3-1). `Amazon SageMaker AI`가 9행으로 가장 많다.

### ✅ G-10. `Amazon Quick`과 `Amazon Quick Sight` — **문서가 하나로 통합됐다**

`quicksight/latest/user/welcome.html`이 **`quick/latest/userguide/what-is.html`로 리다이렉트**되고
(200 r=2) 그 페이지 제목은 **`What is AWS Quick?`**이며 **`AWS Quick Sight`를 Quick의 기능**으로 적는다.
즉 **공식 현행 명칭은 `AWS Quick`**(Amazon → AWS)이고 포함 관계도 문서 쪽에 있다 — 그런데
**시험 가이드는 둘을 다른 카테고리의 별 항목으로 든다.** 처리는 D-11이다(96 §6-1).

## 열린 것 — 저작 전에 판정해야 한다

### ⚠️⚠️ G-02. `기술 2.5.3`의 `Amazon Q Business` 구절이 왜 레포에만 있는지 확정할 수 없다

레포 JSON에는 공식 현행(ko·en 양쪽)에 **없는 예시 한 개**가 더 있다(97 §2-3).
가이드에 **개정(Revisions) 절이 없어** 「가이드가 지웠다」를 공식으로 확인할 길이 없다.

- ✅ **2026-11-13 교체했다**(P-02). 공식 현행 전문으로 바꿨고, 가드는 그 구절
  `Amazon Q Business 데이터 소스` 하나만 0건으로 센다(⚠️ `Amazon Q Business` 자체는 범위 내다).
- 다만 노트·커밋 메시지에 「가이드가 개정됐다」를 **사실로 적지 않는다**. 적을 수 있는 것은
  「공식 현행 ko·en 어디에도 없다」와 「레포 수집분은 2026-06-09 커밋이다」뿐이다.
- ⚠️ **예시에서 빠진 것이 범위에서 빠진 것은 아니다** — `Amazon Q Business`·`Amazon Q Business Apps`는
  지금도 범위 내 목록에 있다.

### ⚠️ G-03. 공식 한국어 판 `기술 4.3.1`이 괄호를 닫지 않는다

영문 판은 `).`로 닫는다. **공식 ko의 오기**이고 고쳐 달라고 할 길이 없다.
처리는 D-06(전사 층은 공식 그대로)이고, **가드를 금지형으로 쓰면 안 된다**(접두사 관계).
✅ 2026-11-13 공식 전문으로 교체하고 **정확한 일치 + 접두사 관계 대조군**으로 고정했다(P-02).

### ⚠️ G-05. 공식 ko가 같은 제품을 **세 표기**로 쓰고 그중 하나는 영문과 다르다

`Strands 에이전트`(2.1.1) · **`Strand API`**(2.1.6) · `Strands Agents`(2.5.5).
영문은 `Strands Agents` 둘 + `Strands API` 하나로 **전부 `Strands`**이므로 **ko의 `Strand API`가 오기**다.
⚠️ 레포 JSON은 **그 오기까지 공식 ko와 같아** 대조 차이에 들지 않았다(97의 4건에 2.1.6은 없다).
저작 표기는 D-05에서 정했고, **표기나 개수를 묻는 문항은 쓰지 않는다**.
✅ 레포 쪽 오기 둘(`Stands 에이전트`·`Stand Agent`)은 2026-11-13에 교체하고 전수 0건으로
고정했다(P-02). ⚠️ 공식 ko 의 `Strand API`(2.1.6)는 **레포도 같아** 대조 차이에 들지 않았고
그대로 둔다 — JSON 은 전사 층이다.

### (옮김) G-07 원문 — 측정 근거

| 범위 내 목록 표기 | lifecycle 표 표기 | 이름으로 세면 |
|---|---|---|
| `Amazon Augmented AI` | `Amazon SageMaker AI – A2I` | **0건** |
| (`CloudTrail Lake`로 탐침) | `AWS CloudTrail – Lake` | **0건** |

en dash 구분 기호와 제품 계열 접두사(`Amazon SageMaker AI – …`)가 원인이다.
**대조는 양쪽 표기로 센다.** 그리고 이번 측정의 대조군 넷(`Simple AD` · `Mechanical Turk` ·
`AWS Audit Manager` · 없는 이름)이 통과한 뒤의 결과만 결과로 쓴다.

### (옮김) G-08 원문 — Phase 1 대조 표(P-01에서 35행으로 갱신됐다)

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

### (옮김) G-10 원문 — 측정 전 기록

AIF-C01은 `Amazon Quick`만 있었고(AIF 95 §3.1 — Quick Sight는 Quick **안의 기능**),
DVA-C03에는 「Quick 범위 내 / Quick Sight 범위 밖」 짝이 기록돼 있다.
**AIP-C01은 둘 다 범위 내이고 카테고리가 갈린다**(`Amazon Quick Sight` = 분석 / `Amazon Quick` = 기계 학습).
⚠️ **포함 관계를 문항 축으로 쓰려면 이 자격증의 목록을 근거로 다시 세운다** — 다른 자격증의 짝을
옮겨 쓰면 틀린다.

### ⚠️ G-11. 범위 외 목록 96개 중 44개가 lifecycle 표에 걸린다

측정값만 남긴다(저작 대상이 아니다). ⚠️ P-01의 넓힌 매처로 다시 세면 **52행 / 42개 서비스**다(44 → 52. 96 §8).
범위 외 목록이 **닫힌 서비스를 모아 둔 곳에 가깝다**는 뜻이고,
**범위 외 서비스를 정답으로 쓰지 않는다**는 D-08 규율의 근거가 된다.

### ⚠️⚠️ G-14. `Amazon SageMaker Clarify`도 신규 고객에게 열려 있지 않다

`clarify-availability-change.html` 실측: `Amazon SageMaker Clarify is no longer open to new customers.`
대안은 **「오픈소스 모니터링 솔루션 + 표준 편향 지표 + SHAP + Amazon Bedrock Evaluations」 조합**이다.
⚠️ MLA-C01은 이 서비스로 문항을 많이 쓴다 — 이 자격증에서는 D-07대로 상태를 병기하고
공정성·설명가능성 축은 **Bedrock Evaluations**를 기본으로 둔다(96 §6-2).

### ⚠️⚠️ G-15. `Amazon Q Developer`는 콘솔 쪽이 **개명**됐고 IDE 플러그인은 2027-04-30 EOS다

공식 what-is 두 문장: IDE 플러그인 지원 종료(대안 **Kiro**) · **`Amazon Q Developer in the AWS
Management Console is now the AWS assistant`**. 범위 내 목록은 `Amazon Q Developer`와 `Kiro`를
**둘 다** 들어서, 관계를 모르면 **대체된 쪽을 정답으로** 가르치게 된다(96 §6-3).

### ⚠️ G-16. `Kiro`는 AWS docs에 가이드가 없다 — 공식이 `kiro.dev`를 가리킨다

`docs.aws.amazon.com/kiro/…`·`aws.amazon.com/kiro/`가 모두 **404**이고 `kiro.dev/docs/`가 200이다.
⭐ **AWS 공식 EOS 페이지 본문이 그 URL을 직접 링크한다**(유일한 외부 링크). 처리는 D-12다(96 §6-4).

### ⚠️ G-17. `Amazon Q Business Apps`는 독립 문서가 없다

`qbusiness-ug/toc-contents.json` 54.7KB 전수에서 `app`을 담은 제목·경로가 **0건**이다.
범위 내 목록은 두 항목으로 들지만 문서는 하나다 — **둘을 다른 서비스처럼 묻지 않는다**(96 §6-7).

### ⚠️ G-18. `AWS Auto Scaling`의 what-is 슬러그가 은퇴하고 마이그레이션 안내로 간다

`what-is-aws-auto-scaling.html` → `migrate-scaling-plan.html`(200 r=1). ⚠️ **닫힌 서비스가 아니다** —
그 문서에 상태 문구가 0건이고 현행 기본 페이지(`what-is-a-scaling-plan.html`)가 살아 있고 lifecycle
세 표에도 없다. **상태 메모를 달지 않는다**(96 §6-5).

### ⚠️ G-19. 측정 신호 두 가지를 고쳤다 — 다음 트랙이 그대로 밟을 자리

1. **`.md` 404는 「페이지 없음」이 아니다.** `.md` 렌디션은 보편적이지 않다(`quicksight/…/welcome.md`
   404인데 `.html`은 200·16KB). **`.md`가 404면 반드시 `.html`로 다시 잰다.**
2. **「`200`이고 2.5KB 이하면 공허」는 `r >= 1`일 때만 맞다.** `r=0`인 짧은 `.md` 9편을 전수로 열어
   **전부 정상 페이지**임을 확인했다. ⭐ 그리고 인덱스로 튕긴 2.2~2.5KB stub은 버릴 것이 아니라
   **`myDefaultPage`로 현행 기본 페이지를 알려 주는 오라클**이다(96 §4).

### ⚠️ G-23. `기술 1.4.1`의 「벡터 데이터베이스를 갖춘 Amazon DynamoDB」를 공식으로 확정할 수 없다

공식 가이드가 예시로 드는데, 측정 결과 **Bedrock Knowledge Bases 지원 벡터 스토어 8종에
DynamoDB 는 없고**(탭 전수 — 0건) DynamoDB 개발자 안내서 소개 페이지에 **`vector`·`embedding`이
각 0건**이다(대조군: 같은 페이지 `table` 48건 — 탐지기는 작동한다).

- ✅ **Bedrock KB 의 벡터 스토어로 DynamoDB 를 고르는 보기를 정답으로 쓰지 않는다**(판정 완료).
- ⛔ 그러나 **「DynamoDB 에 벡터 검색이 없다」고 단정하지 않는다** — 한 소개 페이지의 부재는
  제품 전체의 부재가 아니다(「목록에 없다 ≠ 없다」). 가이드 문구는 **직접 구축하는 아키텍처에서
  메타데이터·임베딩을 DynamoDB 에 담는다**는 읽기가 가능하고, 그 읽기를 공식으로 확정할 근거를
  찾지 못했다. **그 축으로는 문항을 쓰지 않는다.**
- 측정 기록은 [95-rag-vector-retrieval.md](95-rag-vector-retrieval.md) §9 다.

### ⚠️⚠️ G-22. 이 자격증만 연습 세트가 **75문항**이다 — 65를 베끼면 게이트가 틀어진다

레포 `practiceQuestionCount`는 가이드 `overview`의 `scoredQuestions + unscoredQuestions`이고
**AIP-C01은 `65 + 10 = 75`**인데 **나머지 일곱 자격증은 전부 `50 + 15 = 65`**다(전수 실측).

- 배분: **23 · 20 · 15 · 9 · 8**(75 기준). 65를 쓰면 20 · 17 · 13 · 8 · 7로 **전부 달라진다.**
- ⚠️ **D3이 정확히 15**라 Task 하나로 간신히 충족된다 → 게이트 **7 Task 105문항**.
- `mock_exam_test`가 두 N의 배분을 함께 고정해 「다른 줄을 베껴 65를 쓰는」 실수를 잡는다.
- ⚠️ Phase 1 노트(00-overview §2 · 98 P-04)가 **65로 적고 있었다** — P-04에서 정정했다.
  **다른 자격증의 상수는 그 자격증의 가이드에서 다시 읽는다.**

### ⚠️ G-12. 가이드 개정 감시 수단이 없다

개정 절이 없어 **버전·발행일을 가이드에서 알 수 없다.** 그래서 「가이드가 바뀌었는지」는
**이 트랙의 기계 대조를 다시 돌리는 것**으로만 안다(97 §1). ⭐ **P-01에서 한 번 돌렸고 목록은 그대로였다**(범위 내 13/106 · 범위 외 22/96 · lifecycle 134).
저작 배치마다 그 배치가 쓰는
Task의 기술 전문을 **공식에서 다시 읽는다** — SCS가 P-03 교체 전에 70개를 재측정해
「차이가 정확히 2건」을 확인한 것과 같은 절차다.

### ⚠️⚠️ G-20. 이 자격증의 `skills` 본문은 **`기술 N.M.K: ` 접두사를 포함한다**

레포 12종 중 **이 파일만** 그렇다(SCS·SOA 는 접두사 없음 · AIF 는 `knowledge` 사용).
⚠️ 재측정 스크립트가 접두사를 떼지 않아 **「98건 전부 불일치」**를 돌려준 적이 있다 —
**「전부 불일치」는 데이터가 아니라 파서를 의심할 신호다.** P-04 의 `skill` 번호 유도도
여기 걸린다: 본문에서 파싱한 번호와 **배열 위치에서 유도한 번호**가 같은지 대조군으로 둔다
(`aip_guide_sync_test.dart` 가 이미 98건 전수로 단정한다).

### ⚠️⚠️ G-21. 전사를 손으로 적으면 틀린다 — 20줄 중 **17줄**이 틀렸다

P-02 가드 1차 초안에서 Task 제목 20줄을 손으로 적었고 **17개가 공식과 달랐다**(테스트가 잡았다).
구조 수치(도메인 이름·비중·Task별 기술 수)는 Phase 1 에서 **기계 추출**한 것이라 전부 통과했다.
**전사는 기계로 하고, 손으로 적은 표는 그 자체로 결함 후보다.**

### ⚠️ G-13. 「시험에 출제될 수 있는 기술 및 개념」 20항목에 **일반 개발 축이 섞여 있다**

서버리스 컴퓨팅 · 컨테이너 오케스트레이션 · IaC · CI/CD · 하이브리드 클라우드 · 엔터프라이즈 통합 ·
이벤트 기반 아키텍처 · API 설계가 GenAI 축과 나란히 있다.
⚠️ 「범위에 해당하지 않는 작업」은 **모델 개발·훈련 / 고급 ML 기술 / 데이터 엔지니어링·특성 추출**
셋뿐이므로, **일반 개발 주제를 범위 밖으로 다루면 안 된다.** 다만 **FM과 엮이는 축으로만** 출제한다
(가이드의 모든 기술이 FM·GenAI 맥락으로 쓰여 있다).
