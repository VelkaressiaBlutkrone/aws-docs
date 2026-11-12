---
생성: 2026-11-13
목적: 레포 `flutter_app/assets/exam_guides/AIP-C01.json` ↔ 공식 AIP-C01 시험 가이드(ko_kr) 기계 대조
조회일: 2026-11-13
---

# AIP-C01 — 97 레포 JSON 기계 대조

## 0. 결론

| 구분 | 건수 |
|---|---:|
| 대조 항목 | **118** (도메인 이름 5 + 비중 5 + Task 제목 20 + 기술 전문 98, `knowledge` 공허 확인 포함) |
| **바이트 불일치(본문 차이)** | **4** |
| 공백만 차이 | **0** |
| 구조 불일치(도메인·Task·기술 수) | **0** |

**구조는 공식과 완전히 일치한다** — 5 도메인 · 20 Task · 98 기술 · 비중 31·26·20·12·11(합 100).
`overview`의 다섯 값(`Professional` · 750 · 65 · 10 · 180)도 전부 공식으로 확인됐다.
즉 이 자격증의 JSON은 **SCS-C03처럼 신뢰할 수 있는 수집분**이고, 본문 4곳만 고치면 전수 일치가 된다.

⚠️ 그래도 **본문 4건 중 1건은 단순 오기가 아니다**(§2-3) — 레포 JSON에는 **공식 현행에 없는 예시 서비스
한 개**가 들어 있다. AIF-C01에서 같은 종류의 결함이 「공식 범위에 없는 서비스 4개를 예시로 드는」
문제로 번졌으므로, 저작 입력은 JSON이 아니라 [00-overview.md](00-overview.md) §3 공식 전사를 쓴다.

## 1. 방법

AIF-C01 교훈(「공백을 제거해 비교하면 띄어쓰기 잔재만 다른 항목이 일치로 세어진다」)을 그대로 적용해
**바이트 기준과 공백 정규화 기준을 둘 다** 셌다.

1. 공식 ko_kr 페이지 10편을 `.md`로 내려받는다(`curl -sL`, 전부 `200 r=0`). 문서 리더가 보여 주는
   `.html → .md` 리다이렉트를 그대로 쓰면 **전사 오류 없이** 원문 바이트를 얻는다.
2. 정규식으로 `# 콘텐츠 도메인 N: 이름` · `## 작업 N.M: 제목` · `+ 기술 N.M.K: 본문`을 뽑는다.
   파싱되지 않은 `+ `·`## ` 줄은 경고로 찍어 **놓친 항목이 없음을 확인**한다(0건).
3. 비중은 메인 페이지의 `콘텐츠 도메인 N: …(채점되는 콘텐츠의 NN%)`에서 뽑는다.
4. JSON의 같은 번호 항목과 `==`로 비교하고, 다르면 공백 제거 후 다시 비교해
   **「본문 차이」와 「공백만 차이」를 가른다**. 첫 차이 지점의 문자 위치도 함께 찍는다.
5. 차이 4건은 **영문 판**(`ko_kr/` 없는 같은 경로)에서 같은 자리를 다시 읽어 교차 확인했다.

스크립트는 세션 스크래치패드에서 돌렸고(`compare.py`), 입력이 공식 페이지와 레포 파일뿐이라
언제든 재현된다. 재현 명령은 §4에 적었다.

## 2. 차이 4건의 정체와 판정

### 2-1. 기술 2.1.1 — `Stands` → `Strands` (레포 오기, 글자 한 개)

| | 본문 |
|---|---|
| 공식(ko) | …다중 에이전트 시스템에 **Strands** 에이전트 및 AWS Agent Squad… |
| 레포 | …다중 에이전트 시스템에 **Stands** 에이전트 및 AWS Agent Squad… |

영문 판도 `by using **Strands Agents** and AWS Agent Squad for multi-agent systems`로 적는다.
`Strands Agents`는 AIF-C01 조사가 이미 「v1.1이 범위 내 목록에 넣은 신규·개명 이름」으로 기록한
제품이다([AIF-C01/95-aws-ai-tools-naming.md](../AIF-C01/95-aws-ai-tools-naming.md)). **레포 쪽이 틀렸다.**

### 2-2. 기술 2.5.5 — `Stand Agent` → `Strands Agents` (같은 계열, 더 많이 틀렸다)

| | 본문 |
|---|---|
| 공식(ko) | …AWS 네이티브 오케스트레이션을 위한 **Strands Agents** 및 AWS Agent Squad 사용… |
| 레포 | …AWS 네이티브 오케스트레이션을 위한 **Stand Agent** 및 AWS Agent Squad 사용… |

영문 판 `by using **Strands Agents** and AWS Agent Squad for AWS native orchestration`.
⚠️ **같은 제품 이름이 레포 안에서 두 가지로 틀려 있다**(`Stands 에이전트` · `Stand Agent`) —
한쪽만 고치면 다른 쪽이 남는다. 저작 때 이 이름을 쓰는 자리는 **전수로 센다**.

### 2-3. ⚠️⚠️ 기술 2.5.3 — 레포에 **공식 현행에 없는 예시 한 개**가 더 있다

| | 본문 |
|---|---|
| 공식(ko) | …Step Functions 사용, 자동화된 데이터 처리 워크플로 관리에 Amazon Bedrock Data Automation 사용) |
| 레포 | …Step Functions 사용, **내부 지식 도구 제공에 Amazon Q Business 데이터 소스 사용,** 자동화된 데이터 처리 워크플로 관리에 Amazon Bedrock Data Automation 사용) |

영문 판에도 그 구절이 **없다**(`Lambda functions … Step Functions … Amazon Bedrock Data Automation`
셋뿐). 즉 레포에만 있는 네 번째 예시다.

**판정: 공식 현행 본문으로 교체한다.** 다만 「왜 레포에 있나」는 **추론**이고 공식으로 확정할 수 없다 —
근거와 한계를 함께 적는다(판정은 [99-gaps.md](99-gaps.md) G-02):

- 레포 JSON은 2026-06-06~06-10 수집분이고(`git log --follow`), 그중 2026-06-09 커밋이
  「exam_guides 12종을 공식 한국어 시험 가이드와 전수 대조·정렬」이다 — **당시에는 그 구절이 있었을** 가능성.
- `Amazon Q Business`는 **2026-06-30 공지로 유지 관리 상태**이고(신규 고객 차단) 이전 대상이
  `Amazon Quick`이다(AIF 조사의 공식 확인분 + AWS Lifecycle Changes `maintenance` 표 실측).
  가이드가 그 예시를 지울 이유와 방향이 맞는다.
- ⛔ **그런데 이 가이드에는 개정(Revisions) 절이 없다**(00-overview §1-1) — 개정 사실 자체를
  공식 페이지로 확인할 길이 없다. 그래서 「가이드가 지웠다」를 **사실로 적지 않는다.**
- ⚠️ 그리고 `Amazon Q Business`는 **지금도 범위 내 목록에 있다**(`Amazon Q Business` ·
  `Amazon Q Business Apps` 두 항목). 예시에서 빠진 것이 **범위에서 빠진 것은 아니다.**

### 2-4. 기술 4.3.1 — 공식 한국어 판이 **괄호를 닫지 않는다**

| | 본문 끝 |
|---|---|
| 공식(ko) | …비즈니스 영향 지표 사용 ← **닫는 `)`가 없다** |
| 공식(en) | …business impact metrics with custom dashboards**).** |
| 레포 | …비즈니스 영향 지표 사용**)** |

**한국어 판의 오기**이고 레포 쪽이 타이포그래피상 더 옳다. 그래도 **JSON은 가이드 전사**이므로
공식 한국어 전문을 그대로 넣는다 — SCS-C03에서 공식 쪽 오기 `(AWSRAM)`을 그대로 넣은 것과 같은 규율이고,
서비스를 부르는 층(학습문서·문항)과 전사하는 층(JSON)은 다르다.

⚠️⚠️ **이 건은 가드를 금지형으로 쓸 수 없다** — 공식 문구가 레포 문구의 **접두사**다
(`…사용` ⊂ `…사용)`). 「옛 문구 0건」으로 걸면 **교체한 공식 문구가 스스로 걸려 영원히 레드**가 된다.
SCS `기술 6.2.4`(마침표만 차이)와 같은 형태이므로 **정확한 일치로 고정**하고,
접두사 관계 자체를 대조군으로 단정한다.

## 3. 구조 대조에서 함께 확인한 것

- `knowledge`는 **20개 Task 전부 빈 배열**이고 기술 98개가 전부 `skills`에 있다.
  **SCS-C03과 같고 AIF-C01과 반대다** — AIF 판 가드를 베끼면 번호 집합이 빈 집합이 되어
  **문항이 0개인 선결 단계에서는 레드도 나지 않는다**(SCS G-77). Phase 3 선결에서
  「`knowledge` 합 0 · `skills` 합 98」을 **양방향 대조군**으로 둔다.
- `code`·`slug`·`sourceUrl`은 공식과 일치한다(`slug`는 `ai-professional-01`).
  ⚠️ 단 **범위 내/외 페이지만 슬러그 접두사가 `aip-01-`**이므로(00-overview §1-2)
  `slug`로 그 두 페이지 URL을 유도하면 틀린다.
- `guideVersion` 필드는 **없고, 넣지 않는다** — 12종 JSON 중 그 필드를 가진 것은 AIF·SOA 둘뿐이고
  이 가이드에는 개정 절이 없어 적을 값 자체가 없다.
- 파일은 **CRLF · 2칸 들여쓰기 다중 행 JSON**(288줄 · 35,269바이트 · CRLF 287)이다.
  SAA·AIF처럼 한 줄 압축이 아니므로 **치환 diff가 눈으로 검증된다.**

## 4. 교체 계획 (Phase 2 선결)

4곳을 공식 전문으로 바꾸고 동기화 가드를 신설한다. **이 조사 PR의 범위가 아니다**
(SCS가 P-03을 조사와 분리한 선례 — 가드가 늘면 CLAUDE.md 기준선도 함께 올려야 한다).

1. **치환은 바이트 블록으로** 한다(JSON 왕복 금지 — 메모리 `repo-toolchain-gotchas`).
   앵커는 닫는 따옴표까지 포함한다(본문만으로는 모호하다 — SCS 선례).
2. **쓰기 전 단정**: 각 치환이 정확히 1회 · 변경 줄이 정확히 4줄 · CRLF 287 불변 ·
   `json.loads` 왕복이 **손대지 않은 114항목을 바이트 단위로 재현**.
3. **가드** `flutter_app/test/aip_guide_sync_test.dart` 신설:
   - 구조 대조군 2건(기술 98개 유도 + **`knowledge` 합 0 · `skills` 합 98**)
   - 도메인 이름·비중·Task 제목 20 전수
   - 교체한 4건은 **정확한 일치**로 고정(2-4의 접두사 관계 때문에 금지형 금지)
   - 접두사 관계 대조군 1건(`기술 4.3.1`의 공식 문구가 레포 옛 문구의 접두사임을 단정)
   - `Stands`·`Stand Agent` 두 어형을 **전수 0건**으로 고정(어형이 갈리는 주장은 정규식으로 센다)
4. 재현 명령(조사 스크립트와 같은 입력):

```sh
# 공식 .md 10편을 내려받아 레포 JSON과 대조한다 (스크래치패드에서)
curl -sL -o d1.md https://docs.aws.amazon.com/ko_kr/aws-certification/latest/ai-professional-01/ai-professional-01-domain1.md
```

## 5. 출처

| 제목 | URL | 조회일 |
|---|---|---|
| 공식 가이드(ko_kr) 도메인 2 | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/ai-professional-01/ai-professional-01-domain2.html | 2026-11-13 |
| 공식 가이드(영문) 도메인 2 | https://docs.aws.amazon.com/aws-certification/latest/ai-professional-01/ai-professional-01-domain2.html | 2026-11-13 |
| 공식 가이드(ko_kr) 도메인 4 | https://docs.aws.amazon.com/ko_kr/aws-certification/latest/ai-professional-01/ai-professional-01-domain4.html | 2026-11-13 |
| 공식 가이드(영문) 도메인 4 | https://docs.aws.amazon.com/aws-certification/latest/ai-professional-01/ai-professional-01-domain4.html | 2026-11-13 |
| AWS Lifecycle Changes — Maintenance(`Amazon Q Business` 2026-06-30) | https://docs.aws.amazon.com/general/latest/gr/maintenance_services.html | 2026-11-13 |
| Q Business 신규 고객 차단 | https://docs.aws.amazon.com/amazonq/latest/qbusiness-ug/qbusiness-availability-change.html | 2026-11-03(AIF 조사 실측) |
