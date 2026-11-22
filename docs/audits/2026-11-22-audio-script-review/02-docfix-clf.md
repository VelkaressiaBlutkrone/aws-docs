# 02 — CLF 학습문서 지적 판정

- 판정일: 2026-11-22
- 입력: `clf-d12.md`·`clf-d34.md`의 `## 컨트롤러 요청` 절과, 항목 본문에 문서 쪽 의심이 적힌 자리
- 대상 문서: `flutter_app/assets/content/clf/*.md`, 같은 폴더 `*.questions.json`
- 고친 파일은 없다. 이 보고서 한 편만 썼다.

## 요약

| 판정 | 건수 | 자리 |
|---|---|---|
| 채택 | 4 | `t2-4.md:125` · `t2-4.md:134` · `t2-4.md:210` (Trusted Advisor 점검 카테고리, 한 주장 세 자리) · `t4-1.md:114` (절 제목 오기) |
| 기각 | 3 | `t2-4.md:128` (Support 플랜 이름) · `t2-2.md:225`와 `t1-3.md:98` (상태 메모 위치) · `t3-7.md:174` (Forecast 메모) |
| 보류 | 0 | — |

학습문서 내용에 대한 지적은 두 보고서를 합쳐 다섯 주제, 일곱 자리다.

대상이 아니어서 건수만 적는 요청은 11건이다.

- `clf-d12` 4번(제목 꼬리표 낭독) · 5번(영문 이름 발음) · 6번(검수 방법의 한계): 3건
- `clf-d34` 1번(Aurora·Kendra 재합성 채택 여부) · 3번(세그먼트 삽입 방식) · 4번(R3 우선순위) · 5번(표 요약 도구) · 6번(발음사전) · 7번(범위 외 이름 발화 범위) · 8번(`sourceExcerpt` 낡음): 7건
- 항목 본문의 대본 전용 지적(`clf-t3-5 seg037·seg041`의 「복습」 시제): 1건. 문서 제목 「(2.4 복습)」·「(3.2 복습)」은 옳고 발화만 어긋난다.

`clf-d34` 1번의 두 건은 문서를 탓하지 않는다. 문서 쪽 상태만 적는다.

- Aurora(`t3-4.md:113-114`): 문서는 이미 6배를 앞세우고 5배·3배를 함께 적는다. `CLAUDE.md`의 2026-11-07 CLF P3 기록에 「5배/3배는 거짓이 아니므로 금지하지 않는다」와 「그 발화는 재합성하지 않는다」는 판정이 있다. 문서 수정은 없다.
- Kendra(`t3-7.md:96`): 문서는 이미 상태 메모를 단다. `CLAUDE.md`의 2026-11-06 CLF P2 기록에 「기존 고객에게 계속 제공되므로 거짓이 아니다」는 사용자 판정이 있다. 문서 수정은 없다.

측정 기록(2026-11-22, `curl -sL`):

| URL | 결과 |
|---|---|
| `https://docs.aws.amazon.com/awssupport/latest/user/get-started-with-aws-trusted-advisor.html` | `200 r=0` |
| `https://docs.aws.amazon.com/awssupport/latest/user/trusted-advisor.html` | `200 r=0` |
| `https://docs.aws.amazon.com/awssupport/latest/user/aws-support-plans.html` | `200 r=0` |
| `https://docs.aws.amazon.com/forecast/latest/dg/what-is-forecast.html` | `200 r=0` |
| 대조군 `…/awssupport/latest/user/zz-bogus-control.html` | `200 r=1` → 가이드 인덱스 |

본문은 태그를 걷어 낸 텍스트에서 정규식으로 찾았다. 같은 추출에서 `Service limits`·`Fault tolerance`가 함께 잡혀 추출이 유효함을 확인했다.

## 항목

### t2-4.md:125 — 채택

- 지적: 점검 영역을 다섯으로만 든다. 공식 현행 카테고리에는 운영 우수성이 있다(`clf-d12` 컨트롤러 요청 1번).
- 현재 문장(그대로):

  `- 점검 영역: **비용 절감, 성능 개선, 보안 격차 해소, 내결함성(가용성), 서비스 한도(quota)** 등 모범 사례 카테고리.`

- 공식 근거: `https://docs.aws.amazon.com/awssupport/latest/user/get-started-with-aws-trusted-advisor.html`의 「View check categories」 목록이 Cost optimization · Performance · Security · Fault tolerance · Service limits 다음에 여섯째로 "Operational Excellence – Recommendations to help you operate your AWS environment effectively"를 든다.
- 판정 이유: 「등」이 있어 거짓은 아니다. 다만 같은 문서의 `:134`·`:210`이 「등」 없이 다섯을 닫힌 목록으로 적으므로 세 자리를 함께 여섯으로 맞춘다. 개수는 적지 않는다.
- 교체 문장(줄 전체):

  `- 점검 영역: **비용 절감, 성능 개선, 보안 격차 해소, 내결함성(가용성), 서비스 한도(quota), 운영 우수성** 등 모범 사례 카테고리.`

- 같은 주장의 다른 자리: `t2-4.md:134`, `t2-4.md:210`(아래 두 항목). 「등」·「같은」으로 열어 둔 자리는 고칠 필요가 없다: `t4-3.md:222`(「…서비스 한도 등 수백 개 항목」), `t2-4.questions.json:399`(「…서비스 한도 등 모범 사례 위반」), `t2-4.questions.json:112`(「…서비스 한도 같은」).
- 대본 연동: `clf-d12`의 `clf-t2-4 seg025·seg028·seg043` 제안 발화는 다섯을 나열하고 「같은」으로 닫는다. 문서를 여섯으로 고치면 그 세 제안에도 운영 우수성을 넣어야 한다.

### t2-4.md:134 — 채택

- 지적: 위와 같다. 이 줄은 「등」 없이 다섯 영역으로 닫는다.
- 현재 문장(그대로):

  `> Trusted Advisor는 AWS가 수십만 고객을 지원하며 쌓은 **모범 사례 패턴**을 규칙으로 만들어 비용·성능·보안·내결함성·서비스 한도 영역에서 개선 기회를 제안하는 역할에 집중합니다.`

- 공식 근거: `t2-4.md:125` 항목과 같다.
- 교체 문장(줄 전체):

  `> Trusted Advisor는 AWS가 수십만 고객을 지원하며 쌓은 **모범 사례 패턴**을 규칙으로 만들어 비용·성능·보안·내결함성·서비스 한도·운영 우수성 영역에서 개선 기회를 제안하는 역할에 집중합니다.`

- 같은 주장의 다른 자리: `t2-4.md:125` 항목에 적었다.

### t2-4.md:210 — 채택

- 지적: 위와 같다. 시험 직전 요약이 다섯을 괄호 안 닫힌 목록으로 적는다.
- 현재 문장(그대로):

  `- **Trusted Advisor** = AWS 환경을 모범 사례로 점검·권고(비용·성능·보안·내결함성·서비스 한도).`

- 공식 근거: `t2-4.md:125` 항목과 같다.
- 교체 문장(줄 전체):

  `- **Trusted Advisor** = AWS 환경을 모범 사례로 점검·권고(비용·성능·보안·내결함성·서비스 한도·운영 우수성).`

- 같은 주장의 다른 자리: `t2-4.md:125` 항목에 적었다.

### t4-1.md:114 — 채택

- 지적: 절 제목의 「4.x 스토리지와 연계」는 오기로 보인다. 스토리지 문서는 3.6이다(`clf-d34` 컨트롤러 요청 2번, `clf-t4-1 seg020`).
- 현재 문장(그대로):

  `### 3) 스토리지 계층별 요금 (4.x 스토리지와 연계) {#storage-pricing}`

- 근거(문서 내부, 단순 오기):
  - `t4-1.md:116`이 같은 절에서 「자세한 건 스토리지 3.6」이라고 적는다.
  - `t3-6.md:7`의 제목이 「스토리지 서비스 (객체·블록·파일)」이다. 도메인 4에는 스토리지 Task가 없다.
- 교체 문장(줄 전체):

  `### 3) 스토리지 계층별 요금 (3.6 스토리지와 연계) {#storage-pricing}`

- 같은 주장의 다른 자리: CLF `.md`·문항에는 0건이다(`4.x` 전수 검색 결과 이 한 줄).
- 주의: 앵커 `{#storage-pricing}`은 그대로 둔다. 같은 문자열이 `assets/audio/clf/clf-t4-1/script.json`과 `audio_meta.json`에 제목으로 들어 있다. 대본 쪽 처리는 `clf-d34`의 `clf-t4-1 seg020` 제안(꼬리표 삭제)에 따른다. `test/`와 `lib/`에는 이 문자열이 없다.

### t2-4.md:128 — 기각

- 지적: 「상위 Support 플랜(Business/Enterprise 급 이상) … 기본(Basic)·Developer 플랜」이 플랜 개편과 맞는지 확인 요청(`clf-d12` 컨트롤러 요청 2번).
- 현재 문장(그대로):

  `> ℹ️ 참고: Trusted Advisor의 **전체 점검**은 상위 Support 플랜(Business/Enterprise 급 이상)에서 제공되고, 기본(Basic)·Developer 플랜은 **서비스 한도 전체 + 보안·내결함성 일부**만 제공됩니다. (Support 플랜 자세한 내용은 도메인 4에서.)`

- 공식 근거: `https://docs.aws.amazon.com/awssupport/latest/user/trusted-advisor.html`
  - 점검 범위: "all checks in the Service Limits category and selected checks in the Security and Fault tolerance" — 문서의 「서비스 한도 전체 + 보안·내결함성 일부」와 일치한다.
  - 플랜 상태: "Developer Support will be discontinued January 1, 2027" — Developer 플랜은 지금도 유효하다. 같은 가이드의 `get-started-with-aws-trusted-advisor.html`도 "If you have a Developer or Basic Support plan"으로 둘을 함께 든다.
- 판정 이유:
  - 사실 오류가 없다. 점검 범위가 공식과 일치하고, 「Business/Enterprise 급 이상」은 전통 분류로 읽는 표현이다.
  - 이미 사용자 판정이 있다. `CLAUDE.md`의 2026-11-06 CLF P2 기록(P2-E)이 이 자리를 「`clf-t2-4` seg026」으로 세고, 「플랜 이름은 2027-01-01까지 유효하므로 거짓이 아니다」로 판정했다. 뒤집지 않는다.
  - 현행 명칭(Business Support+ · Enterprise Support · Unified Operations)과 단종일은 이 줄이 가리키는 도메인 4 문서가 적는다(`t4-3.md:77`·`:159`·`:165`).
- 같은 주장의 다른 자리: `t4-3.md:177`(「전체 점검은 Business/Enterprise 급 이상(Basic·Developer는 일부)」). 같은 이유로 고치지 않는다.
- 참고: `clf-d34`가 맞춰 보라고 한 `t4-3` 쪽 판정과 어긋나지 않는다. `t4-3.md:129`·`:144`·`:146`은 전통 명칭과 현행 명칭을 함께 적는다.

### t2-2.md:225 · t1-3.md:98 — 기각

- 지적: 상태 메모가 첫 언급보다 뒤에 온다. 「문서당 첫 언급에 한 번」을 엄격히 적용할지 판정 요청(`clf-d12` 컨트롤러 요청 3번). 문서도 같은 순서다.
- 현재 문장(앞부분 그대로):
  - `t2-2.md:225`: `> ℹ️ 정직성 메모: AWS Audit Manager는 **2026-04-30부터 신규 고객에게 열려 있지 않습니다**(기존 고객은 계속 사용).` — 첫 언급은 `t2-2.md:100`·`:114`다.
  - `t1-3.md:98`: `> ℹ️ 정직성 메모: **AWS Snowball Edge는 신규 고객에게 제공되지 않습니다**(공식 문서 — 공식 대안은 온…` — 첫 언급은 `t1-3.md:39`·`:48`이고, 서비스를 소개하는 표(`:94`) 바로 뒤에 메모가 온다.
- 근거(문서 내부·레포 관례): 사실 지적이 아니라 배치 문제다. 두 메모 모두 그 서비스를 **설명하는 절** 안에 있다. `CLAUDE.md`의 2026-11-18 기록이 CLF 문서의 관례를 「범위 메모는 표 바로 뒤 한 번」으로 적는다. 앞쪽 언급은 학습 목표·시험 맥락·비교 줄에서 이름만 드는 자리다.
- 판정 이유: 문서 내용은 옳고 배치도 레포 관례와 같다. 문서를 고치지 않는다. 발화에서 메모를 어느 세그먼트에 둘지는 대본 쪽 판정이다.
- 같은 주장의 다른 자리: 해당 없음(사실 주장이 아니다).

### t3-7.md:174 — 기각

- 지적: `clf-t3-7 seg031` 항목이 이 줄을 「문서 저작자의 방침」으로 지목한다. 대본이 그 방침을 강의 발화로 옮겼다는 지적이고, 문서 사실에 대한 의심은 약하다.
- 현재 문장(그대로):

  `> ℹ️ 정직성 메모: Amazon Forecast는 공식 문서상 **신규 고객에게 더 이상 제공되지 않습니다**. 기존 고객은 계속 사용할 수 있지만, 이 보강 문서에서는 레거시 상태를 명시하고 별도 신규 문항의 정답 서비스로는 기본 사용하지 않습니다.`

- 공식 근거: `https://docs.aws.amazon.com/forecast/latest/dg/what-is-forecast.html` — "Amazon Forecast is no longer available to new customers." 이어서 기존 고객은 계속 쓸 수 있다고 적는다.
- 판정 이유: 상태 서술은 공식과 일치한다. 뒷부분(「이 보강 문서에서는 … 기본 사용하지 않습니다」)은 사실 주장이 아니라 저작 방침이다. 학습자에게 보일 문장인지는 편집 판단이고 공식 문서로 가를 수 없어 이 판정의 범위 밖이다. 고치려면 별도 판정이 필요하다.
- 같은 주장의 다른 자리: 「기본 사용하지」·「레거시 상태를 명시」는 CLF `.md`·문항에 이 한 줄뿐이다. `test/`에 이 문구를 묶는 가드는 없다. CLF 문항 가운데 `Forecast`를 적는 것은 0건이다.

## 문항 수정 필요 여부

채택 4건 모두 문항 수정이 필요하지 않다. Trusted Advisor 카테고리를 드는 문항 두 자리(`t2-4.questions.json:112`·`:399`)는 열린 표현이고, 「4.x」는 문항에 없다.
